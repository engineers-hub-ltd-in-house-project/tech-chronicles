#!/bin/bash
# =============================================================================
# 第7回ハンズオン：パイプの発明――1973年1月のコンピュータサイエンス史
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: bash, grep, awk, sort, uniq, wc, head, seq, mkfifo
#               (通常プリインストール済み)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/cli-handson-07"

echo "=== 第7回ハンズオン：パイプの発明 ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# =============================================================================
echo "=============================================="
echo "[演習1] パイプなしでログ分析を行う"
echo "=============================================="
echo ""

# テスト用のアクセスログを生成
cd "${WORKDIR}"

for i in $(seq 1 100); do
    IP="192.168.1.$((RANDOM % 20 + 1))"
    CODE=$( [ $((RANDOM % 10)) -lt 2 ] && echo 404 || echo 200 )
    URLS=("/index.html" "/api/users" "/api/orders" "/about" "/contact" "/api/v2/items" "/login" "/static/style.css")
    URL=${URLS[$((RANDOM % 8))]}
    echo "$IP - - [15/Jan/2025:10:$((RANDOM % 60)):$((RANDOM % 60)) +0900] \"GET $URL HTTP/1.1\" $CODE 1234" >> access.log
done

echo "access.logを生成した（100行）"
echo ""
echo "--- タスク: 404エラーのURL別出現回数を集計する ---"
echo ""
echo "パイプがない場合、一時ファイルを使って段階的に処理する:"
echo ""

echo "Step 1: 404を含む行を抽出して一時ファイルに書き出す"
grep " 404 " access.log > "${WORKDIR}/step1_filtered.txt"
echo "  grep \" 404 \" access.log > step1_filtered.txt"
echo "  → $(wc -l < "${WORKDIR}/step1_filtered.txt") 行抽出"
echo ""

echo "Step 2: URL列（7番目のフィールド）を抽出して一時ファイルに書き出す"
awk '{print $7}' "${WORKDIR}/step1_filtered.txt" > "${WORKDIR}/step2_urls.txt"
echo "  awk '{print \$7}' step1_filtered.txt > step2_urls.txt"
echo "  → $(wc -l < "${WORKDIR}/step2_urls.txt") 行"
echo ""

echo "Step 3: ソートして一時ファイルに書き出す"
sort "${WORKDIR}/step2_urls.txt" > "${WORKDIR}/step3_sorted.txt"
echo "  sort step2_urls.txt > step3_sorted.txt"
echo ""

echo "Step 4: 重複をカウントして一時ファイルに書き出す"
uniq -c "${WORKDIR}/step3_sorted.txt" > "${WORKDIR}/step4_counted.txt"
echo "  uniq -c step3_sorted.txt > step4_counted.txt"
echo ""

echo "Step 5: 降順ソートして結果を表示"
sort -rn "${WORKDIR}/step4_counted.txt"
echo ""
echo "  sort -rn step4_counted.txt"
echo ""

echo "作成された一時ファイル:"
ls -la "${WORKDIR}"/step*.txt 2>/dev/null | awk '{print "  " $NF " (" $5 " bytes)"}'
echo ""

echo "Step 6: 一時ファイルを手動で削除"
rm "${WORKDIR}"/step*.txt
echo "  rm step*.txt"
echo ""
echo "→ 6ステップ、4つの一時ファイルが必要だった"
echo ""

# =============================================================================
echo "=============================================="
echo "[演習2] パイプで同じタスクを一行で実行する"
echo "=============================================="
echo ""

echo "パイプを使って一行で実行する:"
echo ""
echo "  grep \" 404 \" access.log | awk '{print \$7}' | sort | uniq -c | sort -rn"
echo ""
echo "結果:"
grep " 404 " access.log | awk '{print $7}' | sort | uniq -c | sort -rn | sed 's/^/  /'
echo ""
echo "→ 一時ファイルは一切作られない"
echo "→ 5つのプログラムが同時に実行される"
echo "→ データはメモリ上のカーネルバッファを流れる"
echo ""

echo "--- パイプラインの各段階を確認する ---"
echo ""

echo "Stage 1: grep で404行を抽出"
echo "  grep \" 404 \" access.log | head -3"
grep " 404 " access.log | head -3 | sed 's/^/  /'
echo "  ..."
echo ""

echo "Stage 2: awk でURL列を抽出"
echo "  grep \" 404 \" access.log | awk '{print \$7}' | head -5"
grep " 404 " access.log | awk '{print $7}' | head -5 | sed 's/^/  /'
echo "  ..."
echo ""

echo "Stage 3: sort で整列"
echo "  ... | sort | head -5"
grep " 404 " access.log | awk '{print $7}' | sort | head -5 | sed 's/^/  /'
echo "  ..."
echo ""

echo "Stage 4: uniq -c で集計"
echo "  ... | sort | uniq -c"
grep " 404 " access.log | awk '{print $7}' | sort | uniq -c | sed 's/^/  /'
echo ""

echo "Stage 5: sort -rn で降順ソート（最終結果）"
echo "  ... | sort | uniq -c | sort -rn"
grep " 404 " access.log | awk '{print $7}' | sort | uniq -c | sort -rn | sed 's/^/  /'
echo ""

# =============================================================================
echo "=============================================="
echo "[演習3] パイプのバッファと並行実行の観察"
echo "=============================================="
echo ""

echo "--- 1. パイプバッファサイズの確認 ---"
echo ""

echo "PIPE_BUF（アトミック書き込み保証サイズ）:"
echo "  $(getconf PIPE_BUF /)"
echo ""

echo "パイプの容量（capacity）:"
echo "  デフォルト: 65536 bytes (64 KiB)"
echo "  = 16ページ x 4096 bytes/ページ"
echo ""
echo "  PIPE_BUFとパイプ容量は異なる概念:"
echo "  - PIPE_BUF (4096 bytes): これ以下の書き込みは"
echo "    アトミック（他のプロセスの書き込みと混ざらない）"
echo "  - 容量 (65536 bytes): バッファが満杯になると"
echo "    書き込み側がブロックされる閾値"
echo ""

echo "--- 2. パイプの並行実行を確認 ---"
echo ""
echo "sleep 2 | sleep 2 を実行:"
echo "  シーケンシャルなら4秒、並行なら2秒かかる"
echo ""
START=$(date +%s)
sleep 2 | sleep 2
END=$(date +%s)
ELAPSED=$((END - START))
echo "  実行時間: ${ELAPSED}秒"
if [ $ELAPSED -le 2 ]; then
    echo "  → 2秒で完了 = 並行実行されている"
else
    echo "  → ${ELAPSED}秒 = シーケンシャル実行"
fi
echo ""

echo "--- 3. パイプでのデータ受け渡しを可視化 ---"
echo ""
echo "  seq 1 5 | while read n; do echo \"received: \$n\"; done"
echo ""
seq 1 5 | while read n; do echo "  received: $n"; done
echo ""
echo "  seqが1〜5を出力し、パイプを通じてwhileループが受け取る"
echo "  各行がテキストストリームとして流れている"
echo ""

echo "--- 4. 名前付きパイプ（FIFO）の作成 ---"
echo ""
mkfifo "${WORKDIR}/test_fifo" 2>/dev/null || true
ls -la "${WORKDIR}/test_fifo"
echo ""
echo "  ファイルタイプが p（パイプ）になっている"
echo "  ファイルシステム上に名前があるが、データはメモリ上"
echo ""
rm -f "${WORKDIR}/test_fifo"

echo "=============================================="
echo ""

# =============================================================================
# クリーンアップ
echo "--- クリーンアップ ---"
rm -rf "${WORKDIR}"
echo "作業ディレクトリを削除しました: ${WORKDIR}"
echo ""
echo "=== ハンズオン完了 ==="
