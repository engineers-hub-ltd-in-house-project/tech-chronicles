#!/bin/bash
# =============================================================================
# 第2回ハンズオン：コマンドライン以前の世界――パンチカードとバッチ処理
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: awk, bc, sort, head, wc, grep (通常プリインストール済み)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/cli-handson-02"

echo "=== 第2回ハンズオン：コマンドライン以前の世界――パンチカードとバッチ処理 ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}/input"
mkdir -p "${WORKDIR}/output"
mkdir -p "${WORKDIR}/jobs"

# --- 入力データの準備 ---
echo "[準備] 入力デッキ（売上データ）を作成中..."

cat > "${WORKDIR}/input/input_deck.dat" << 'EOF'
SALES 2025-01-15 TOKYO     150000
SALES 2025-01-20 OSAKA     98000
SALES 2025-02-03 TOKYO     210000
SALES 2025-02-14 NAGOYA    75000
SALES 2025-03-01 OSAKA     180000
SALES 2025-03-10 TOKYO     320000
SALES 2025-03-22 NAGOYA    60000
SALES 2025-04-05 TOKYO     195000
SALES 2025-04-18 OSAKA     145000
SALES 2025-04-30 NAGOYA    88000
EOF

echo "  10件の売上データを作成: input/input_deck.dat"
echo ""

# =======================================================================
echo "================================================================"
echo "[演習1] 非対話的パイプライン――バッチ処理の「入力→処理→出力」"
echo "================================================================"
echo ""

# ジョブスクリプトの作成（JCLに相当）
cat > "${WORKDIR}/jobs/job_sales_report.sh" << 'ENDJOB'
#!/bin/bash
# JOB: SALES_REPORT
# CLASS: A
# PROGRAMMER: SATO
# DATE: 2025-04-30
set -euo pipefail

INPUT_FILE="${1:?入力ファイルが指定されていません}"
OUTPUT_DIR="${2:?出力ディレクトリが指定されていません}"
mkdir -p "$OUTPUT_DIR"

echo "*** JOB SALES_REPORT STARTED ***"
echo "*** INPUT: $INPUT_FILE ***"
echo ""

# STEP1: データ検証（入力カードの読み取り）
echo "--- STEP1: DATA VALIDATION ---"
TOTAL_CARDS=$(wc -l < "$INPUT_FILE")
VALID_CARDS=$(grep -c '^SALES' "$INPUT_FILE" || true)
echo "TOTAL CARDS READ: $TOTAL_CARDS"
echo "VALID CARDS: $VALID_CARDS"
if [ "$TOTAL_CARDS" -ne "$VALID_CARDS" ]; then
    echo "*** WARNING: INVALID CARDS DETECTED ***"
fi
echo ""

# STEP2: 地域別集計
echo "--- STEP2: REGIONAL SUMMARY ---"
awk '{region[$3]+=$4; count[$3]++}
     END{
       printf "%-12s %8s %6s %10s\n", "REGION", "TOTAL", "COUNT", "AVERAGE"
       printf "%-12s %8s %6s %10s\n", "--------", "------", "-----", "-------"
       for(r in region){
         printf "%-12s %8d %6d %10d\n", r, region[r], count[r], region[r]/count[r]
       }
     }' "$INPUT_FILE" > "$OUTPUT_DIR/regional_summary.txt"
cat "$OUTPUT_DIR/regional_summary.txt"
echo ""

# STEP3: 月別集計
echo "--- STEP3: MONTHLY SUMMARY ---"
awk '{
       split($2, d, "-")
       month=d[1]"-"d[2]
       monthly[month]+=$4
       mcount[month]++
     }
     END{
       n=asorti(monthly, sorted)
       printf "%-10s %10s %6s\n", "MONTH", "TOTAL", "COUNT"
       printf "%-10s %10s %6s\n", "-------", "------", "-----"
       for(i=1;i<=n;i++){
         printf "%-10s %10d %6d\n", sorted[i], monthly[sorted[i]], mcount[sorted[i]]
       }
     }' "$INPUT_FILE" > "$OUTPUT_DIR/monthly_summary.txt"
cat "$OUTPUT_DIR/monthly_summary.txt"
echo ""

# STEP4: 総合計
echo "--- STEP4: GRAND TOTAL ---"
GRAND_TOTAL=$(awk '{sum+=$4} END{print sum}' "$INPUT_FILE")
echo "GRAND TOTAL: $GRAND_TOTAL"
echo "$GRAND_TOTAL" > "$OUTPUT_DIR/grand_total.txt"
echo ""

echo "*** JOB SALES_REPORT COMPLETED ***"
echo "*** OUTPUT FILES IN: $OUTPUT_DIR ***"
ENDJOB
chmod +x "${WORKDIR}/jobs/job_sales_report.sh"

echo "ジョブスクリプトを作成: jobs/job_sales_report.sh"
echo ""
echo "--- ジョブを「提出」します ---"
echo ""
bash "${WORKDIR}/jobs/job_sales_report.sh" \
  "${WORKDIR}/input/input_deck.dat" \
  "${WORKDIR}/output"
echo ""
echo "--- 出力ファイル一覧 ---"
ls -la "${WORKDIR}/output/"
echo ""
echo "ポイント: ジョブを提出したら途中で方針変更はできない。"
echo "         すべての処理を事前に定義しておく必要がある。"
echo ""

# =======================================================================
echo "================================================================"
echo "[演習2] ターンアラウンドタイムの疑似体験"
echo "================================================================"
echo ""

cat > "${WORKDIR}/jobs/batch_simulator.sh" << 'ENDSIM'
#!/bin/bash
set -euo pipefail

echo "================================================"
echo "  BATCH PROCESSING SIMULATOR"
echo "  Simulating 1960s turnaround time (compressed)"
echo "================================================"
echo ""

# ジョブ提出
echo "[$(date +%H:%M:%S)] JOB SUBMITTED TO QUEUE"
echo "  Waiting for available resources..."
sleep 3

# カード読み取り
echo "[$(date +%H:%M:%S)] CARD READER: READING INPUT DECK"
for i in $(seq 1 5); do
    echo "  Reading card $i of 5..."
    sleep 1
done

# コンパイル
echo "[$(date +%H:%M:%S)] COMPILER: FORTRAN IV"
echo "  Compiling source..."
sleep 2

# ここでエラーを発生させる
echo "[$(date +%H:%M:%S)] *** COMPILATION ERROR ***"
echo "  ERROR ON CARD 3: UNDEFINED VARIABLE 'TOTL'"
echo "  (Did you mean 'TOTAL'?)"
echo ""
echo "[$(date +%H:%M:%S)] JOB TERMINATED WITH ERRORS"
echo ""
echo "================================================"
echo "  To fix this error in 1965, you would:"
echo "  1. Walk to cubbyhole to pick up printout"
echo "  2. Read the error message"
echo "  3. Find card 3 in your deck"
echo "  4. Retype the corrected card on a keypunch"
echo "  5. Resubmit the entire deck"
echo "  6. Wait again..."
echo ""
echo "  Estimated turnaround: 2-4 hours"
echo "  In your terminal today: ~2 seconds"
echo "================================================"
ENDSIM
chmod +x "${WORKDIR}/jobs/batch_simulator.sh"

echo "バッチ処理シミュレーターを実行します..."
echo "(待ち時間は圧縮しています。実際の1960年代は数時間でした)"
echo ""
bash "${WORKDIR}/jobs/batch_simulator.sh"
echo ""

# =======================================================================
echo "================================================================"
echo "[演習3] 対話的処理との比較――探索的データ分析"
echo "================================================================"
echo ""

echo "--- 対話的処理の利点：段階的な探索 ---"
echo ""

echo "Step 1: データの概観"
cat "${WORKDIR}/input/input_deck.dat"
echo ""

echo "Step 2: TOKYOのデータだけ見る（対話的判断）"
grep "TOKYO" "${WORKDIR}/input/input_deck.dat"
echo ""

echo "Step 3: TOKYOの売上合計（前の結果を見て判断）"
grep "TOKYO" "${WORKDIR}/input/input_deck.dat" | awk '{sum+=$4} END{printf "TOKYO TOTAL: %d\n", sum}'
echo ""

echo "Step 4: TOKYOの最高売上月（さらに深掘り）"
grep "TOKYO" "${WORKDIR}/input/input_deck.dat" | sort -k4 -rn | head -1
echo ""

echo "=== 比較 ==="
echo "バッチ処理: 全ての分析を事前に設計し、一括実行して結果を待つ"
echo "対話的処理: 結果を見ながら次の分析を決める。探索的な作業が可能"
echo ""

# =======================================================================
echo "================================================================"
echo "=== ハンズオン完了 ==="
echo "================================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ポイント:"
echo "  1. バッチ処理は入力と出力が時間的に分離している"
echo "  2. 対話的処理ではフィードバックループが短く、探索的作業が可能"
echo "  3. 1960年代はコンピュータの時間 > 人間の時間だった"
echo "  4. 経済的価値判断の逆転が、対話的コンピューティングを生んだ"
