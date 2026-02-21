#!/bin/bash
# =============================================================================
# 第8回ハンズオン：テキスト処理の系譜――ed, grep, sed, awk
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: bash, ed, grep, sed, awk, sort, uniq, wc, head, cat, seq
#               (通常プリインストール済み)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/cli-handson-08"

echo "=== 第8回ハンズオン：テキスト処理の系譜 ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# =============================================================================
echo "=============================================="
echo "[演習1] edを使ったテキスト編集"
echo "=============================================="
echo ""

echo "--- edでファイルを作成する ---"
echo ""

# edコマンドをスクリプト的に実行する
ed "${WORKDIR}/history.txt" <<'EDSCRIPT'
a
The ed editor was written by Ken Thompson in 1969.
It is a line-oriented text editor for UNIX.
The command g/re/p became the grep command.
The substitute command (s) became the core of sed.
AWK added programming capabilities to text processing.
.
w
q
EDSCRIPT

echo "history.txt の内容:"
cat -n "${WORKDIR}/history.txt"
echo ""

echo "--- edのg/re/pコマンドを使う ---"
echo ""
echo "edの中で g/re/p を実行:"
echo "  g/command/p → \"command\" を含む行を全表示"
echo ""

ed "${WORKDIR}/history.txt" <<'EDSCRIPT'
g/command/p
q
EDSCRIPT

echo ""
echo "→ これがgrepの語源: g(lobal) / re(gular expression) / p(rint)"
echo ""

echo "--- edのsコマンドを使う ---"
echo ""
echo "edの中で置換を実行:"
echo '  1,$s/UNIX/Unix/g → 全行でUNIXをUnixに置換'
echo ""

ed "${WORKDIR}/history.txt" <<'EDSCRIPT'
1,$s/UNIX/Unix/g
w
q
EDSCRIPT

echo "置換後の内容:"
cat -n "${WORKDIR}/history.txt"
echo ""
echo "→ これがsedの語源: s(tream) + ed(itor)"
echo ""

# =============================================================================
echo "=============================================="
echo "[演習2] grep / sed / awk のパイプライン"
echo "=============================================="
echo ""

# サンプルのアクセスログを生成
RANDOM=42
for i in $(seq 1 200); do
    IP="10.0.0.$((RANDOM % 30 + 1))"
    CODES=(200 200 200 200 200 200 200 301 404 404 500)
    CODE=${CODES[$((RANDOM % 11))]}
    METHODS=("GET" "GET" "GET" "POST" "PUT" "DELETE")
    METHOD=${METHODS[$((RANDOM % 6))]}
    PATHS=("/index.html" "/api/users" "/api/orders" "/api/products" "/login" "/static/app.js" "/health" "/api/v2/items")
    URLPATH=${PATHS[$((RANDOM % 8))]}
    HOUR=$((RANDOM % 24))
    MIN=$((RANDOM % 60))
    SEC=$((RANDOM % 60))
    SIZE=$((RANDOM % 5000 + 100))
    printf "%s - - [15/Jan/2025:%02d:%02d:%02d +0900] \"%s %s HTTP/1.1\" %d %d\n" \
        "$IP" "$HOUR" "$MIN" "$SEC" "$METHOD" "$URLPATH" "$CODE" "$SIZE" \
        >> "${WORKDIR}/access.log"
done

echo "access.log を生成した（200行）"
echo ""

echo "--- Step 1: grep で行を絞り込む ---"
echo ""
echo '  grep " 404 " access.log | head -5'
grep " 404 " "${WORKDIR}/access.log" | head -5 | sed 's/^/  /'
echo "  ..."
COUNT_404=$(grep -c " 404 " "${WORKDIR}/access.log")
echo ""
echo "  → 404エラーの行: ${COUNT_404}件"
echo ""

echo "--- Step 2: sed で不要部分を変換 ---"
echo ""
echo "  sedで日時フォーマットからブラケットを除去:"
echo '  sed "s/\[//; s/\]//" でブラケット除去'
grep " 404 " "${WORKDIR}/access.log" | head -3 | sed 's/\[//; s/\]//' | sed 's/^/  /'
echo "  ..."
echo ""

echo "--- Step 3: awk でフィールドを抽出・集計 ---"
echo ""
echo "  404エラーのURL別集計:"
echo '  grep " 404 " access.log | awk '"'"'{print $7}'"'"' | sort | uniq -c | sort -rn'
echo ""
grep " 404 " "${WORKDIR}/access.log" | awk '{print $7}' | sort | uniq -c | sort -rn | sed 's/^/  /'
echo ""

echo "--- Step 4: awk 単体での高度な分析 ---"
echo ""
echo "  全ステータスコードの分布とバイト数合計:"
echo ""
awk '{
    code[$9]++
    bytes[$9] += $10
}
END {
    printf "  %-8s %-10s %-15s\n", "Code", "Count", "Total Bytes"
    printf "  %-8s %-10s %-15s\n", "----", "-----", "-----------"
    for (c in code)
        printf "  %-8s %-10d %-15d\n", c, code[c], bytes[c]
}' "${WORKDIR}/access.log" | sort -k1
echo ""

echo "--- 比較: 同じタスクを各ツールで ---"
echo ""
echo "  タスク: 404エラーの行を表示する"
echo ""
echo '  grep版:  grep " 404 " access.log'
echo '  sed版:   sed -n "/ 404 /p" access.log'
echo "  awk版:   awk '/ 404 /{print}' access.log"
echo ""
echo "  → 結果は同じだが、grepが最も簡潔で高速"
echo "  → 各ツールには最適な用途がある"
echo ""

# =============================================================================
echo "=============================================="
echo "[演習3] edのg/re/pからgrepへ"
echo "=============================================="
echo ""

# テスト用ファイルを作成
cat > "${WORKDIR}/federalist.txt" <<'TEXTEOF'
Federalist No. 1: General Introduction (Hamilton)
Federalist No. 2: Concerning Dangers from Foreign Force (Jay)
Federalist No. 10: The Utility of the Union as a Safeguard (Madison)
Federalist No. 51: The Structure of the Government (Madison)
Federalist No. 68: The Mode of Electing the President (Hamilton)
Federalist No. 70: The Executive Department Further Considered (Hamilton)
Federalist No. 78: The Judiciary Department (Hamilton)
Federalist No. 84: Certain General and Miscellaneous Objections (Hamilton)
TEXTEOF

echo "テストファイル（Federalist Papersの一部）:"
cat -n "${WORKDIR}/federalist.txt"
echo ""

echo "--- edの g/re/p コマンド ---"
echo ""
echo "  edで Hamilton を含む行を全表示:"
echo "  g/Hamilton/p"
echo ""

ed "${WORKDIR}/federalist.txt" <<'EDSCRIPT'
g/Hamilton/p
q
EDSCRIPT

echo ""

echo "--- grepコマンド（edから独立したツール）---"
echo ""
echo "  grep Hamilton federalist.txt"
echo ""
grep Hamilton "${WORKDIR}/federalist.txt" | sed 's/^/  /'
echo ""

echo "→ 結果は同じ。grepはedの g/re/p を"
echo "  スタンドアロンのフィルタとして切り出したもの"
echo ""

echo "--- grepの利点: パイプラインで使える ---"
echo ""
echo "  grep Hamilton federalist.txt | wc -l"
HAMILTON_COUNT=$(grep -c Hamilton "${WORKDIR}/federalist.txt")
echo "  → Hamilton が著者の論文: ${HAMILTON_COUNT}篇"
echo ""
echo "  grep Madison federalist.txt | wc -l"
MADISON_COUNT=$(grep -c Madison "${WORKDIR}/federalist.txt")
echo "  → Madison が著者の論文: ${MADISON_COUNT}篇"
echo ""
echo "  edではこの「パイプに流す」操作ができない"
echo "  フィルタとして独立したからこそ、組み合わせが可能になった"
echo ""

# =============================================================================
# クリーンアップ
echo "--- クリーンアップ ---"
rm -rf "${WORKDIR}"
echo "作業ディレクトリを削除しました: ${WORKDIR}"
echo ""
echo "=== ハンズオン完了 ==="
