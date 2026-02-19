#!/bin/bash
# =============================================================================
# 第1回ハンズオン：GUI vs CLI――同じタスクで比べてみる
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: grep, awk, sort, uniq, wc, mv, tr (通常プリインストール済み)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/cli-handson-01"

echo "=== 第1回ハンズオン：GUI vs CLI――同じタスクで比べてみる ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}/logs"
mkdir -p "${WORKDIR}/data"
mkdir -p "${WORKDIR}/scripts"

# --- 演習1用: ログファイルの生成 ---
echo "[準備] テスト用ログファイルを生成中..."

SERVERS=("server-0" "server-1" "server-2" "server-3" "server-4" "server-5" "server-6" "server-7" "server-8" "server-9")
SEVERITIES=("INFO" "INFO" "INFO" "WARN" "WARN" "ERROR")
MESSAGES=("Process completed with status 0" "Connection established" "Request processed" "Timeout waiting for response" "Disk usage above threshold" "Failed to connect to database" "Memory allocation failed" "Permission denied" "Service restarted" "Health check passed")

for i in $(seq 1 100); do
  month=$(printf '%02d' $((RANDOM % 12 + 1)))
  day=$(printf '%02d' $((RANDOM % 28 + 1)))
  hour=$(printf '%02d' $((RANDOM % 24)))
  minute=$(printf '%02d' $((RANDOM % 60)))
  second=$(printf '%02d' $((RANDOM % 60)))
  severity=${SEVERITIES[$((RANDOM % ${#SEVERITIES[@]}))]}
  server=${SERVERS[$((RANDOM % ${#SERVERS[@]}))]}
  message=${MESSAGES[$((RANDOM % ${#MESSAGES[@]}))]}
  echo "2025-${month}-${day} ${hour}:${minute}:${second} ${severity} ${server} ${message}" >> "${WORKDIR}/logs/app.log"
done

echo "  100行のログファイルを生成: logs/app.log"
echo ""

# --- 演習2用: スペース入りファイル名の生成 ---
echo "[準備] テスト用データファイルを生成中..."

for i in $(seq 1 50); do
  num=$(printf '%03d' "$i")
  echo "Report data for entry ${i}. Generated at $(date +%Y-%m-%d)." > "${WORKDIR}/data/report ${num} final.txt"
done

echo "  50個のデータファイルを生成: data/"
echo ""

# --- 演習1: ファイル検索とログ分析 ---
echo "================================================================"
echo "[演習1] ファイル検索とログ分析"
echo "================================================================"
echo ""

echo "--- ERRORを含むログ行を検索 ---"
echo '$ grep "ERROR" logs/app.log'
grep "ERROR" "${WORKDIR}/logs/app.log" || echo "  (ERRORなし)"
echo ""

echo "--- ERROR件数のカウント ---"
echo '$ grep "ERROR" logs/app.log | wc -l'
error_count=$(grep "ERROR" "${WORKDIR}/logs/app.log" | wc -l)
echo "  ${error_count} 件"
echo ""

echo "--- サーバ別ERRORランキング ---"
echo '$ grep "ERROR" logs/app.log | awk '"'"'{print $4}'"'"' | sort | uniq -c | sort -rn | head -5'
grep "ERROR" "${WORKDIR}/logs/app.log" | awk '{print $4}' | sort | uniq -c | sort -rn | head -5 || echo "  (データなし)"
echo ""

echo "GUIで同じことをするなら:"
echo "  1. テキストエディタでapp.logを開く"
echo "  2. Ctrl+Fで\"ERROR\"を検索し、ヒット数を手動カウント"
echo "  3. サーバ別集計にはスプレッドシートにコピーしてピボットテーブルが必要"
echo ""

# --- 演習2: 一括リネーム ---
echo "================================================================"
echo "[演習2] 一括リネーム（スペース → アンダースコア）"
echo "================================================================"
echo ""

echo "--- リネーム前 ---"
ls "${WORKDIR}/data/" | head -5
echo "  ... (全50ファイル)"
echo ""

echo "--- CLIで一括リネーム ---"
echo '$ for f in data/*.txt; do mv "$f" "$(echo "$f" | tr '"'"' '"'"' '"'"'_'"'"')"; done'
cd "${WORKDIR}"
for f in data/*.txt; do
  mv "$f" "$(echo "$f" | tr ' ' '_')"
done

echo "--- リネーム後 ---"
ls "${WORKDIR}/data/" | head -5
echo "  ... (全50ファイル)"
echo ""

echo "GUIで同じことをするなら:"
echo "  ファイルマネージャで50個のファイルを1つずつ右クリック→名前変更"
echo ""

# --- 演習3: 再現性の検証 ---
echo "================================================================"
echo "[演習3] 再現性の検証――操作をスクリプト化する"
echo "================================================================"
echo ""

cat > "${WORKDIR}/scripts/log-analysis.sh" << 'SCRIPT'
#!/bin/bash
# log-analysis.sh -- ログ分析スクリプト
set -euo pipefail

LOG_FILE="${1:-logs/app.log}"

if [ ! -f "$LOG_FILE" ]; then
  echo "Error: ${LOG_FILE} not found" >&2
  exit 1
fi

echo "=== ログ分析レポート ==="
echo "対象ファイル: ${LOG_FILE}"
echo "総行数: $(wc -l < "$LOG_FILE")"
echo ""

echo "--- 重要度別件数 ---"
for level in INFO WARN ERROR; do
  count=$(grep -c "$level" "$LOG_FILE" || true)
  echo "  ${level}: ${count} 件"
done
echo ""

echo "--- サーバ別ERROR件数（上位5） ---"
grep "ERROR" "$LOG_FILE" | awk '{print $4}' | sort | uniq -c | sort -rn | head -5 || echo "  (ERRORなし)"
echo ""

echo "--- 時間帯別アクティビティ ---"
awk '{split($2, t, ":"); print t[1] ":00"}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -5
SCRIPT
chmod +x "${WORKDIR}/scripts/log-analysis.sh"

echo "分析スクリプトを作成しました: scripts/log-analysis.sh"
echo ""
echo "--- スクリプトの実行結果 ---"
cd "${WORKDIR}"
bash "${WORKDIR}/scripts/log-analysis.sh" "${WORKDIR}/logs/app.log"

echo ""
echo "================================================================"
echo "=== ハンズオン完了 ==="
echo "================================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ポイント:"
echo "  1. CLIの操作はすべてテキストとして記録・共有・再実行できる"
echo "  2. パイプライン（|）で小さなコマンドを組み合わせて複雑な処理を構築できる"
echo "  3. スクリプト化すれば、同じ分析を誰でも・いつでも再現できる"
echo "  4. GUIでは「操作手順書（スクリーンショット付き）」が必要になる"
