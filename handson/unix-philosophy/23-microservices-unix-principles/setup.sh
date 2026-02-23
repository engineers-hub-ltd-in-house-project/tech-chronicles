#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-23"

echo "============================================"
echo " 第23回ハンズオン"
echo " マイクロサービスとUNIX原則――思想の転生"
echo "============================================"
echo ""
echo "作業ディレクトリ: $WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習1: UNIXパイプラインによるデータ処理"
echo "============================================"
echo ""

echo "--- テストデータ: Webアクセスログ（簡易版） ---"
cat > "$WORKDIR/access.log" << 'EOF'
2026-02-23T10:00:01 GET /api/users 200 45ms
2026-02-23T10:00:02 GET /api/products 200 120ms
2026-02-23T10:00:03 POST /api/orders 201 340ms
2026-02-23T10:00:04 GET /api/users 200 42ms
2026-02-23T10:00:05 GET /api/products 500 5ms
2026-02-23T10:00:06 GET /api/users 200 50ms
2026-02-23T10:00:07 POST /api/orders 201 280ms
2026-02-23T10:00:08 GET /api/products 200 115ms
2026-02-23T10:00:09 GET /api/users 404 3ms
2026-02-23T10:00:10 DELETE /api/orders/42 204 90ms
2026-02-23T10:00:11 GET /api/products 200 130ms
2026-02-23T10:00:12 POST /api/orders 500 2ms
EOF

cat "$WORKDIR/access.log"
echo ""

echo "--- エンドポイント別リクエスト数 ---"
echo "コマンド: cat access.log | awk '{print \$3}' | sort | uniq -c | sort -rn"
echo ""
cat "$WORKDIR/access.log" | awk '{print $3}' | sort | uniq -c | sort -rn
echo ""
echo "→ 各コマンドの責務:"
echo "  cat   : ファイルを読む"
echo "  awk   : 3列目（エンドポイント）を抽出する"
echo "  sort  : アルファベット順にソートする（uniqの前準備）"
echo "  uniq -c: 連続する重複行を数える"
echo "  sort -rn: 数値の降順でソートする"
echo "  → 「一つのことをうまくやれ」の実践"
echo ""

echo "--- ステータスコード500のリクエスト ---"
echo "コマンド: cat access.log | grep ' 500 ' | awk '{print \$1, \$2, \$3}'"
echo ""
cat "$WORKDIR/access.log" | grep " 500 " | awk '{print $1, $2, $3}'
echo ""

echo "--- 平均レスポンスタイム（エンドポイント別） ---"
cat "$WORKDIR/access.log" | awk '{
  endpoint=$3;
  gsub(/ms/, "", $5);
  time=$5;
  sum[endpoint]+=time;
  count[endpoint]++;
}
END {
  for (e in sum) {
    printf "%s: %.1fms (%d requests)\n", e, sum[e]/count[e], count[e]
  }
}' | sort
echo ""

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習2: マイクロサービス的なプロセス分割"
echo "============================================"
echo ""

echo "--- サービスの作成 ---"
echo ""

# サービス1: ログ収集サービス
cat > "$WORKDIR/log_collector.sh" << 'SCRIPT'
#!/bin/bash
# Log Collector Service: 生ログをJSONに変換する
# 責務: データフォーマットの変換のみ
INPUT="$1"
while IFS=' ' read -r timestamp method endpoint status latency; do
    latency_num="${latency%ms}"
    printf '{"timestamp":"%s","method":"%s","endpoint":"%s","status":%s,"latency_ms":%s}\n' \
        "$timestamp" "$method" "$endpoint" "$status" "$latency_num"
done < "$INPUT"
SCRIPT
chmod +x "$WORKDIR/log_collector.sh"
echo "サービス1: log_collector.sh（生ログ → JSON変換）"

# サービス2: フィルタサービス
cat > "$WORKDIR/filter_service.sh" << 'SCRIPT'
#!/bin/bash
# Filter Service: 条件に基づくフィルタリング
# 責務: データのフィルタリングのみ
FIELD="$1"
VALUE="$2"
jq -c "select(.${FIELD} == ${VALUE})"
SCRIPT
chmod +x "$WORKDIR/filter_service.sh"
echo "サービス2: filter_service.sh（条件フィルタリング）"

# サービス3: 集計サービス
cat > "$WORKDIR/aggregator_service.sh" << 'SCRIPT'
#!/bin/bash
# Aggregator Service: エンドポイント別の統計を計算する
# 責務: データの集計のみ
jq -s '
  group_by(.endpoint)
  | map({
      endpoint: .[0].endpoint,
      count: length,
      avg_latency_ms: (map(.latency_ms) | add / length | . * 10 | round / 10),
      error_count: map(select(.status >= 500)) | length
    })
  | sort_by(-.count)
'
SCRIPT
chmod +x "$WORKDIR/aggregator_service.sh"
echo "サービス3: aggregator_service.sh（エンドポイント別集計）"
echo ""

echo "--- マイクロサービス的パイプライン ---"
echo ""

echo "Step 1: ログ収集サービスの出力（先頭3件）:"
bash "$WORKDIR/log_collector.sh" "$WORKDIR/access.log" | head -3
echo "..."
echo ""

echo "Step 2: ログ収集 → 集計パイプライン:"
bash "$WORKDIR/log_collector.sh" "$WORKDIR/access.log" | bash "$WORKDIR/aggregator_service.sh"
echo ""

echo "Step 3: ログ収集 → エラーフィルタ:"
bash "$WORKDIR/log_collector.sh" "$WORKDIR/access.log" | bash "$WORKDIR/filter_service.sh" "status" "500"
echo ""

echo "--- UNIXパイプラインとの対比 ---"
echo ""
echo "UNIX的アプローチ:"
echo "  cat access.log | grep ' 500 ' | awk '{print \$3}'"
echo ""
echo "マイクロサービス的アプローチ:"
echo "  log_collector.sh | filter_service.sh status 500 | jq .endpoint"
echo ""
echo "共通点:"
echo "  - 各コンポーネントは一つの責務のみを持つ"
echo "  - パイプ（|）でデータが流れる"
echo "  - コンポーネントの入れ替え・組み合わせが自由"
echo ""
echo "相違点:"
echo "  - データフォーマット: テキスト行 vs JSON"
echo "  - 型安全性: 暗黙的 vs 明示的（jqによるフィールドアクセス）"
echo "  - 再利用性: JSON版はフィールド名を指定するため、より汎用的"

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習3: 分散システムの困難を模擬する"
echo "============================================"
echo ""

# --- 模擬1: レイテンシの影響 ---
echo "--- 模擬1: レイテンシの影響 ---"
echo ""

echo "UNIXパイプライン（カーネル内通信）:"
UNIX_START=$(date +%s%N)
UNIX_RESULT=$(cat "$WORKDIR/access.log" | grep "500" | wc -l)
UNIX_END=$(date +%s%N)
UNIX_DURATION=$(( (UNIX_END - UNIX_START) / 1000000 ))
echo "  結果: $UNIX_RESULT件のエラー"
echo "  所要時間: ${UNIX_DURATION}ms"
echo ""

echo "マイクロサービス模擬（各サービスに100ms遅延）:"
MS_START=$(date +%s%N)
# サービス1: ログ読み取り
sleep 0.1
cat "$WORKDIR/access.log" > "$WORKDIR/step1_out.txt"
# サービス2: フィルタリング
sleep 0.1
grep "500" "$WORKDIR/step1_out.txt" > "$WORKDIR/step2_out.txt"
# サービス3: カウント
sleep 0.1
MS_RESULT=$(wc -l < "$WORKDIR/step2_out.txt")
MS_END=$(date +%s%N)
MS_DURATION=$(( (MS_END - MS_START) / 1000000 ))
echo "  結果: $MS_RESULT件のエラー"
echo "  所要時間: ${MS_DURATION}ms"
echo ""
echo "→ 同じ処理でも、ネットワーク遅延が加算される"
echo "  3サービス x 100ms = 約300msのオーバーヘッド"
echo "  UNIXパイプにはこの遅延が存在しない"
echo ""

# --- 模擬2: 部分障害 ---
echo "--- 模擬2: 部分障害 ---"
echo ""

cat > "$WORKDIR/unreliable_service.sh" << 'SCRIPT'
#!/bin/bash
# 50%の確率で障害を起こすサービス
if (( RANDOM % 2 == 0 )); then
    echo "ERROR: Service unavailable" >&2
    exit 1
fi
cat
SCRIPT
chmod +x "$WORKDIR/unreliable_service.sh"

echo "信頼性の低いサービスを5回呼び出す:"
SUCCESS=0
FAILURE=0
for i in $(seq 1 5); do
    result=$(echo "test data" | bash "$WORKDIR/unreliable_service.sh" 2>/dev/null) || true
    status=$?
    if [ $status -eq 0 ] && [ -n "$result" ]; then
        echo "  試行$i: 成功"
        SUCCESS=$((SUCCESS + 1))
    else
        echo "  試行$i: 失敗（サービス障害）"
        FAILURE=$((FAILURE + 1))
    fi
done
echo ""
echo "成功: ${SUCCESS}回 / 失敗: ${FAILURE}回"
echo ""

# --- 模擬3: リトライパターン ---
echo "--- 模擬3: リトライパターン ---"
echo ""
echo "サーキットブレーカー的なリトライを実装する:"

MAX_RETRIES=3
RETRY_DELAY=0.1

call_with_retry() {
    local attempt=1
    while [ $attempt -le $MAX_RETRIES ]; do
        result=$(echo "$1" | bash "$WORKDIR/unreliable_service.sh" 2>/dev/null) || true
        if [ -n "$result" ]; then
            echo "  試行$attempt: 成功 → '$result'"
            return 0
        fi
        echo "  試行$attempt: 失敗 → ${RETRY_DELAY}s後にリトライ"
        sleep "$RETRY_DELAY"
        attempt=$((attempt + 1))
    done
    echo "  全${MAX_RETRIES}回失敗 → フォールバック値を返す"
    return 1
}

call_with_retry "重要なデータ"
echo ""
echo "→ UNIXのパイプでは不要なリトライロジックが、"
echo "  マイクロサービスでは必須となる"
echo "  これが分散システムの「代償」だ"

# -------------------------------------------------
echo ""
echo "============================================"
echo " まとめ"
echo "============================================"
echo ""
echo "UNIXパイプラインとマイクロサービスの構造的アナロジー:"
echo ""
echo "  UNIX哲学                → マイクロサービス原則"
echo "  ─────────────────────   ─────────────────────────"
echo "  一つのことをうまくやれ   → Single Responsibility"
echo "  パイプ                  → API / メッセージキュー"
echo "  テキストストリーム       → JSON / gRPC"
echo "  stdin/stdout            → HTTP/REST / イベント"
echo ""
echo "決定的な違い:"
echo "  - UNIXパイプはカーネル内通信（信頼・低遅延・順序保証）"
echo "  - マイクロサービスはネットワーク通信（不信頼・高遅延・順序不定）"
echo "  - 原則は転生できるが、環境の差異が新たな困難を生む"
echo ""

# クリーンアップ
echo "--- クリーンアップ ---"
rm -rf "$WORKDIR"
echo "作業ディレクトリを削除しました: $WORKDIR"
echo ""
echo "ハンズオン完了"
