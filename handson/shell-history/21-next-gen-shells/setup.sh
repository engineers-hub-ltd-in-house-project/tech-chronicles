#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-21"

echo "============================================================"
echo " 第21回ハンズオン：次世代シェルの挑戦"
echo " Nushell、Oil/YSH、Elvish、その先へ"
echo "============================================================"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo ">>> 基本パッケージのインストール"
# ============================================================
apt-get update -qq && apt-get install -y -qq curl wget jq git build-essential > /dev/null 2>&1
echo "基本パッケージのインストール完了"

# ============================================================
echo ""
echo ">>> Nushellのインストール"
# ============================================================
NUSHELL_VERSION="0.101.0"
NUSHELL_TARBALL="nu-${NUSHELL_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
NUSHELL_URL="https://github.com/nushell/nushell/releases/download/${NUSHELL_VERSION}/${NUSHELL_TARBALL}"

if ! command -v nu > /dev/null 2>&1; then
  echo "Nushell ${NUSHELL_VERSION} をダウンロード中..."
  wget -qO "/tmp/${NUSHELL_TARBALL}" "${NUSHELL_URL}"
  tar xzf "/tmp/${NUSHELL_TARBALL}" -C /tmp
  cp "/tmp/nu-${NUSHELL_VERSION}-x86_64-unknown-linux-gnu/nu" /usr/local/bin/
  chmod +x /usr/local/bin/nu
  echo "Nushell ${NUSHELL_VERSION} インストール完了"
else
  echo "Nushell は既にインストール済み: $(nu --version)"
fi

# ============================================================
echo ""
echo ">>> サンプルデータの作成"
# ============================================================

cat > "${WORKDIR}/servers.json" << 'EOF'
[
  {"name": "web-01", "region": "us-east", "cpu": 45.2, "memory": 72.1, "status": "running"},
  {"name": "web-02", "region": "us-east", "cpu": 78.9, "memory": 88.3, "status": "running"},
  {"name": "db-01", "region": "us-west", "cpu": 23.1, "memory": 95.7, "status": "running"},
  {"name": "db-02", "region": "us-west", "cpu": 12.4, "memory": 45.2, "status": "stopped"},
  {"name": "api-01", "region": "eu-west", "cpu": 67.3, "memory": 62.8, "status": "running"},
  {"name": "api-02", "region": "eu-west", "cpu": 91.2, "memory": 78.5, "status": "running"},
  {"name": "cache-01", "region": "us-east", "cpu": 34.5, "memory": 50.1, "status": "running"},
  {"name": "worker-01", "region": "ap-east", "cpu": 55.8, "memory": 83.2, "status": "running"}
]
EOF
echo "servers.json 作成完了"

cat > "${WORKDIR}/access.log" << 'EOF'
2024-01-15 10:23:45 GET /api/users 200 45ms
2024-01-15 10:23:46 POST /api/users 201 120ms
2024-01-15 10:23:47 GET /api/products 200 32ms
2024-01-15 10:23:48 GET /api/users 500 5023ms
2024-01-15 10:23:49 GET /api/products 200 28ms
2024-01-15 10:23:50 DELETE /api/users/42 204 67ms
2024-01-15 10:23:51 GET /api/users 200 41ms
2024-01-15 10:23:52 POST /api/orders 201 230ms
2024-01-15 10:23:53 GET /api/products 500 8012ms
2024-01-15 10:23:54 GET /api/users 200 39ms
EOF
echo "access.log 作成完了"

# ============================================================
echo ""
echo ">>> 演習1: bash + jq vs Nushell ―― JSON処理の比較"
# ============================================================

echo ""
echo "--- bash + jq: CPUが70%以上のrunningサーバを地域ごとに集計 ---"
jq '[.[] | select(.status == "running" and .cpu > 70)] | group_by(.region) | map({region: .[0].region, count: length, avg_cpu: (map(.cpu) | add / length)})' "${WORKDIR}/servers.json"

echo ""
echo "--- Nushell: 同じタスク ---"
nu -c "
open ${WORKDIR}/servers.json
  | where status == 'running' and cpu > 70
  | group-by region
  | transpose region servers
  | each {|row| {
      region: \$row.region,
      count: (\$row.servers | length),
      avg_cpu: (\$row.servers | get cpu | math avg)
    }}
  | sort-by count --reverse
"

# ============================================================
echo ""
echo ">>> 演習2: bash + awk vs Nushell ―― ログ解析の比較"
# ============================================================

echo ""
echo "--- bash + awk: エンドポイントごとのエラー率と平均レスポンス時間 ---"
awk '{
  endpoint=$4;
  status=$5;
  gsub(/ms/, "", $6);
  time=$6;
  total[endpoint]++;
  sum_time[endpoint]+=time;
  if (status >= 500) errors[endpoint]++;
}
END {
  for (ep in total) {
    err = (ep in errors) ? errors[ep] : 0;
    printf "%s: %d reqs, %.1f%% errors, avg %.0fms\n",
      ep, total[ep], err/total[ep]*100, sum_time[ep]/total[ep]
  }
}' "${WORKDIR}/access.log" | sort

echo ""
echo "--- Nushell: 同じログ解析 ---"
nu -c "
open ${WORKDIR}/access.log
  | lines
  | where \$it != ''
  | parse '{date} {time} {method} {endpoint} {status} {duration}'
  | update duration {|row| \$row.duration | str replace 'ms' '' | into int}
  | update status {|row| \$row.status | into int}
  | group-by endpoint
  | transpose endpoint requests
  | each {|row| {
      endpoint: \$row.endpoint,
      total: (\$row.requests | length),
      error_pct: ((\$row.requests | where status >= 500 | length) / (\$row.requests | length) * 100),
      avg_duration_ms: (\$row.requests | get duration | math avg | math round --precision 0)
    }}
  | sort-by endpoint
"

# ============================================================
echo ""
echo ">>> 演習3: bash構文 vs YSH構文の比較"
# ============================================================

cat > "${WORKDIR}/deploy-check-bash.sh" << 'SCRIPT'
#!/bin/bash
# bash版: サービスチェックスクリプト
declare -a services=("web" "api" "worker")

for svc in "${services[@]}"; do
  case "$svc" in
    web)    port=80 ;;
    api)    port=8080 ;;
    worker) port=9090 ;;
  esac

  echo "Checking ${svc} on port ${port}..."

  if [[ "${svc}" == "web" ]]; then
    echo "  → Primary service"
  fi
done

echo "All checks complete."
SCRIPT
chmod +x "${WORKDIR}/deploy-check-bash.sh"

echo ""
echo "--- bash版の実行 ---"
bash "${WORKDIR}/deploy-check-bash.sh"

# ============================================================
echo ""
echo ">>> Nushellの基本操作デモ"
# ============================================================

echo ""
echo "--- Nushell: ls の構造化出力 ---"
nu -c "ls ${WORKDIR} | select name type size"

echo ""
echo "--- Nushell: sys コマンドによるシステム情報 ---"
nu -c "sys host | select name os_version"

# ============================================================
echo ""
echo "============================================================"
echo " ハンズオン完了"
echo ""
echo " 作業ディレクトリ: ${WORKDIR}"
echo " Nushell対話モード: nu"
echo ""
echo " 試してみよう:"
echo "   nu              # Nushellを起動"
echo "   ls | where type == 'dir'  # ディレクトリだけ表示"
echo "   open servers.json         # JSONをテーブルで開く"
echo "   sys host                  # システム情報を構造化表示"
echo "============================================================"
