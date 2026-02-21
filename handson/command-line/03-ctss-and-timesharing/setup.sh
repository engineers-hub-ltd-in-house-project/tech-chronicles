#!/bin/bash
# =============================================================================
# 第3回ハンズオン：対話的コンピューティングの原体験
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: grep, awk, sort, uniq, wc (通常プリインストール済み)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/cli-handson-03"

echo "=== 第3回ハンズオン：対話的コンピューティングの原体験 ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}/logs"

# --- 演習2用: タイムシェアリングシミュレーター ---
echo "================================================================"
echo "[演習2] タイムシェアリングシミュレーター"
echo "================================================================"
echo ""

cat > "${WORKDIR}/timesharing_sim.sh" << 'ENDSIM'
#!/bin/bash
set -euo pipefail

echo "=============================================="
echo "  CTSS-STYLE TIMESHARING SIMULATOR"
echo "  Demonstrating CPU time-slicing (200ms quantum)"
echo "=============================================="
echo ""

# 4人のユーザーのジョブを定義
declare -a USERS=("CORBATO" "DAGGETT" "DALEY" "MCCARTHY")
declare -a JOBS=(
  "MAD compiler: matrix multiplication"
  "EDIT: thesis chapter 3"
  "FAP assembler: I/O routine"
  "LISP interpreter: symbolic computation"
)
declare -a REMAINING=(5 3 4 2)

QUANTUM_MS=200
TOTAL_SWITCHES=0

echo "[SUPERVISOR] System initialized. Quantum: ${QUANTUM_MS}ms"
echo "[SUPERVISOR] ${#USERS[@]} users logged in via Flexowriter terminals"
echo ""

ROUND=1
while true; do
    ALL_DONE=true
    echo "--- Round $ROUND (Time: $((ROUND * QUANTUM_MS))ms) ---"

    for i in "${!USERS[@]}"; do
        if [ "${REMAINING[$i]}" -gt 0 ]; then
            ALL_DONE=false
            echo "  [CPU -> ${USERS[$i]}] Running: ${JOBS[$i]}"
            echo "    Context switch: save registers, load user $i memory"
            sleep 0.3

            REMAINING[$i]=$((REMAINING[$i] - 1))
            TOTAL_SWITCHES=$((TOTAL_SWITCHES + 1))

            if [ "${REMAINING[$i]}" -eq 0 ]; then
                echo "    *** JOB COMPLETED for ${USERS[$i]} ***"
            else
                echo "    Quantum expired (${QUANTUM_MS}ms). Preempting."
            fi
        fi
    done

    if $ALL_DONE; then
        break
    fi

    ROUND=$((ROUND + 1))
    echo ""
done

echo ""
echo "=============================================="
echo "  SIMULATION COMPLETE"
echo "  Total context switches: $TOTAL_SWITCHES"
echo "  Total simulated time: $((ROUND * QUANTUM_MS * ${#USERS[@]}))ms"
echo ""
echo "  Key insight:"
echo "  Each user experienced responsive interaction"
echo "  despite sharing a single CPU."
echo "  MCCARTHY's short job finished first (2 quanta)"
echo "  CORBATO's long job finished last (5 quanta)"
echo "  This is the multilevel feedback queue in action."
echo "=============================================="
ENDSIM
chmod +x "${WORKDIR}/timesharing_sim.sh"

echo "タイムシェアリングシミュレーターを実行中..."
echo ""
bash "${WORKDIR}/timesharing_sim.sh"
echo ""

# --- 演習3用: ログデータの生成と対話的探索 ---
echo "================================================================"
echo "[演習3] 対話的な問題解決 vs バッチ的な問題解決"
echo "================================================================"
echo ""

echo "[準備] テスト用ログファイルを生成中..."

SERVICES=("auth" "api" "db" "cache" "worker")
LEVELS=("INFO" "INFO" "INFO" "WARN" "ERROR")
MESSAGES=(
  "Request processed successfully"
  "Connection established"
  "Query executed in 45ms"
  "Response time exceeded threshold: 2100ms"
  "Connection refused: max connections reached"
  "Authentication failed for user admin"
  "Cache hit ratio: 0.87"
  "Worker process restarted"
  "Database connection pool exhausted"
  "TLS handshake timeout"
)

for i in $(seq 1 200); do
  hour=$(printf '%02d' $((RANDOM % 24)))
  minute=$(printf '%02d' $((RANDOM % 60)))
  second=$(printf '%02d' $((RANDOM % 60)))
  service=${SERVICES[$((RANDOM % ${#SERVICES[@]}))]}
  level=${LEVELS[$((RANDOM % ${#LEVELS[@]}))]}
  msg=${MESSAGES[$((RANDOM % ${#MESSAGES[@]}))]}
  echo "2025-03-15 ${hour}:${minute}:${second} [${level}] ${service}: ${msg}"
done | sort > "${WORKDIR}/logs/server.log"

echo "  200行のサーバーログを生成: logs/server.log"
echo ""

# --- バッチ的アプローチ ---
echo "=== アプローチA: バッチ的（事前に全分析を設計） ==="
echo ""
echo "バッチ処理では、実行前にすべての分析を設計する必要がある。"
echo "結果を見てから次の分析を決めることはできない。"
echo ""

LOG="${WORKDIR}/logs/server.log"

echo "--- BATCH JOB: LOG ANALYSIS ---"
echo "STEP1: Level counts"
for level in INFO WARN ERROR; do
  count=$(grep -c "\[${level}\]" "$LOG" || true)
  echo "  ${level}: ${count}"
done
echo ""

echo "STEP2: Service counts"
for svc in auth api db cache worker; do
  count=$(grep -c "${svc}:" "$LOG" || true)
  echo "  ${svc}: ${count}"
done
echo ""

echo "STEP3: Hourly distribution (top 5)"
awk '{split($2,t,":"); print t[1]":00"}' "$LOG" | sort | uniq -c | sort -rn | head -5
echo ""
echo "--- END BATCH JOB ---"
echo ""

# --- 対話的アプローチ ---
echo "=== アプローチB: 対話的（結果を見ながら探索） ==="
echo ""

echo "--- Step 1: 全体像の把握 ---"
echo '$ wc -l logs/server.log'
wc -l "$LOG"
echo ""

echo "--- Step 2: ERRORを見てみる ---"
echo '$ grep "\[ERROR\]" logs/server.log | head -5'
grep "\[ERROR\]" "$LOG" | head -5
echo ""

echo "--- Step 3: ERRORのサービス別集計（前の結果を見て判断） ---"
echo '$ grep "\[ERROR\]" logs/server.log | awk ... | sort | uniq -c | sort -rn'
grep "\[ERROR\]" "$LOG" | awk '{for(i=1;i<=NF;i++) if($i ~ /:$/) print $i}' | sort | uniq -c | sort -rn
echo ""

echo "--- Step 4: db関連のERRORに焦点（さらに深掘り） ---"
echo '$ grep "\[ERROR\]" logs/server.log | grep "db:"'
grep "\[ERROR\]" "$LOG" | grep "db:" || echo "  (該当なし)"
echo ""

echo "=============================================="
echo "  比較:"
echo "  バッチ的: 事前にすべての分析手順を設計。"
echo "           実行してみないとどこに問題があるかわからない。"
echo "  対話的:  結果を見て -> 仮説を立て -> 次の分析を決める。"
echo "           探索的な問題解決が可能。"
echo ""
echo "  CTSSが実現したのは、まさにこの「対話的探索」だった。"
echo "  1961年以前、プログラマはこの贅沢を持っていなかった。"
echo "=============================================="
echo ""

echo "================================================================"
echo "=== ハンズオン完了 ==="
echo "================================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ポイント:"
echo "  1. タイムシェアリングは「CPUの時間を分割共有する」技術"
echo "  2. 多段フィードバックキューにより対話的操作の応答性を確保"
echo "  3. 対話的処理の真価は「結果を見て次の行動を変えられる」こと"
echo "  4. CTSSの設計思想は現代のOSスケジューラに引き継がれている"
