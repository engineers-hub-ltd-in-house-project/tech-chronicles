#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-20"

echo "=========================================="
echo "クラウドの考古学 第20回 ハンズオン"
echo "CDN、エッジコンピューティング"
echo "=========================================="

# === 作業ディレクトリの作成 ===
echo ""
echo "--- 作業ディレクトリの作成 ---"
mkdir -p "${WORKDIR}/src"
cd "${WORKDIR}"
echo "作業ディレクトリ: ${WORKDIR}"

# === Node.jsプロジェクトの初期化 ===
echo ""
echo "--- プロジェクトの初期化 ---"
npm init -y > /dev/null 2>&1
npm install wrangler --save-dev

# === 演習1: エッジ関数のコード ===
echo ""
echo "--- 演習1: エッジ関数の作成 ---"

cat > src/index.js << 'JS_EOF'
export default {
  async fetch(request, env, ctx) {
    const start = Date.now();

    // Cloudflareが付与するリクエストメタ情報
    const cf = request.cf || {};
    const clientInfo = {
      country: cf.country || "unknown",
      city: cf.city || "unknown",
      colo: cf.colo || "unknown",
      region: cf.region || "unknown",
      latitude: cf.latitude || "unknown",
      longitude: cf.longitude || "unknown",
    };

    const now = new Date();
    const response = {
      message: "Hello from the Edge!",
      timestamp: now.toISOString(),
      processing_location: {
        datacenter: clientInfo.colo,
        country: clientInfo.country,
        city: clientInfo.city,
      },
      client: {
        country: clientInfo.country,
        region: clientInfo.region,
      },
      performance: {
        edge_processing_ms: Date.now() - start,
        note: "この処理はあなたに最も近いエッジで実行された",
      },
      explanation: {
        what_happened: [
          "1. あなたのリクエストはDNSで最寄りのCloudflare PoPに到達",
          `2. ${clientInfo.colo}のエッジサーバーでV8 Isolateが起動`,
          "3. このJavaScript関数がエッジで実行された",
          "4. オリジンサーバーへの通信は発生していない",
          "5. レスポンスがエッジから直接返された",
        ],
      },
    };

    return new Response(JSON.stringify(response, null, 2), {
      headers: {
        "Content-Type": "application/json",
        "X-Edge-Location": clientInfo.colo,
        "X-Processing-Time": `${Date.now() - start}ms`,
      },
    });
  },
};
JS_EOF

cat > wrangler.toml << 'TOML_EOF'
name = "cloud-history-edge-demo"
main = "src/index.js"
compatibility_date = "2024-01-01"
TOML_EOF

echo "エッジ関数を作成しました: src/index.js"

# === 演習2: レイテンシー計測スクリプト ===
echo ""
echo "--- 演習2: レイテンシー計測スクリプトの作成 ---"

cat > measure-latency.sh << 'SCRIPT_EOF'
#!/bin/bash
set -euo pipefail

URL="${1:?Usage: $0 <URL> <count>}"
COUNT="${2:-10}"

echo "=== レイテンシー計測: ${URL} ==="
echo "計測回数: ${COUNT}"
echo ""

total=0
min=999999
max=0

for i in $(seq 1 "${COUNT}"); do
  time_ms=$(curl -s -o /dev/null -w "%{time_starttransfer}" "${URL}" | awk '{printf "%.0f", $1 * 1000}')

  if [ "${time_ms}" -lt "${min}" ]; then min=${time_ms}; fi
  if [ "${time_ms}" -gt "${max}" ]; then max=${time_ms}; fi
  total=$((total + time_ms))

  printf "  #%2d: %4d ms (TTFB)\n" "${i}" "${time_ms}"
  sleep 0.5
done

avg=$((total / COUNT))
echo ""
echo "結果:"
echo "  最小: ${min} ms"
echo "  最大: ${max} ms"
echo "  平均: ${avg} ms"
SCRIPT_EOF
chmod +x measure-latency.sh

echo "レイテンシー計測スクリプトを作成しました: measure-latency.sh"

# === 演習3: Workers KVカウンターの例 ===
echo ""
echo "--- 演習3: Workers KVカウンターの作成 ---"

cat > src/counter.js << 'JS_EOF'
export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;

    if (path === "/count") {
      const currentStr = await env.PAGE_VIEWS.get("total");
      const current = parseInt(currentStr || "0", 10);

      const next = current + 1;
      await env.PAGE_VIEWS.put("total", next.toString());

      const cf = request.cf || {};
      return new Response(JSON.stringify({
        page_views: next,
        served_by: cf.colo || "local",
        note: "Workers KVは結果整合性。別のPoPから即座に読むと古い値が返る可能性がある。",
        consistency_model: "eventually_consistent",
        propagation_delay: "通常数秒以内",
      }, null, 2), {
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({
      endpoints: {
        "/count": "カウンターを+1して現在値を返す",
      },
      explanation: {
        kv_behavior: [
          "Workers KVは結果整合性（Eventually Consistent）",
          "書き込みは数秒で全PoPに伝播する",
          "高頻度の書き込みでは競合（race condition）が発生しうる",
          "厳密なカウンターにはDurable Objectsが必要",
        ],
      },
    }, null, 2), {
      headers: { "Content-Type": "application/json" },
    });
  },
};
JS_EOF

cat > wrangler-kv.toml << 'TOML_EOF'
name = "cloud-history-edge-counter"
main = "src/counter.js"
compatibility_date = "2024-01-01"

# Workers KVネームスペースのバインディング
# デプロイ前に以下のコマンドでKVネームスペースを作成:
#   npx wrangler kv namespace create PAGE_VIEWS
# 出力されたidをここに記入する
[[kv_namespaces]]
binding = "PAGE_VIEWS"
id = "<YOUR_KV_NAMESPACE_ID>"
TOML_EOF

echo "Workers KVカウンターを作成しました: src/counter.js"

# === 完了 ===
echo ""
echo "=========================================="
echo "セットアップ完了"
echo "=========================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "--- 演習1: エッジ関数のデプロイ ---"
echo "  cd ${WORKDIR}"
echo "  npx wrangler dev            # ローカル開発サーバー起動"
echo "  curl -s http://localhost:8787 | python3 -m json.tool"
echo ""
echo "  デプロイする場合:"
echo "  npx wrangler login"
echo "  npx wrangler deploy"
echo ""
echo "--- 演習2: レイテンシー計測 ---"
echo "  ./measure-latency.sh <デプロイしたURL> 10"
echo ""
echo "--- 演習3: Workers KV ---"
echo "  npx wrangler kv namespace create PAGE_VIEWS"
echo "  # wrangler-kv.toml のidを更新"
echo "  npx wrangler dev -c wrangler-kv.toml"
echo "  curl -s http://localhost:8787/count | python3 -m json.tool"
echo ""
echo "--- クリーンアップ ---"
echo "  npx wrangler delete          # デプロイしたWorkerを削除"
echo "  rm -rf ${WORKDIR}            # 作業ディレクトリを削除"
