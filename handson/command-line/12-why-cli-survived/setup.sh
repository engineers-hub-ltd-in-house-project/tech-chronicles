#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/command-line-handson-12"

echo "=============================================="
echo " 第12回ハンズオン: なぜCLIは死ななかったのか"
echo " 自動化・再現性・組み合わせの力"
echo "=============================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ==============================================
# 演習1: 100個のMarkdownファイルからメタデータを抽出しCSVに変換
# ==============================================

echo ""
echo "=============================================="
echo "[演習1] 100個のMarkdownからメタデータ抽出 → CSV変換"
echo "=============================================="
echo ""

mkdir -p "${WORKDIR}/docs"
cd "${WORKDIR}/docs"
rm -f doc_*.md 2>/dev/null || true

echo "--- 100個のMarkdownファイルを生成 ---"
CATEGORIES=("frontend" "backend" "infrastructure" "testing")
STATUSES=("draft" "review" "published")

for i in $(seq -w 1 100); do
    cat_idx=$((RANDOM % 4))
    category="${CATEGORIES[$cat_idx]}"
    priority=$((RANDOM % 3 + 1))
    stat_idx=$((RANDOM % 3))
    status="${STATUSES[$stat_idx]}"
    month=$(printf '%02d' $((RANDOM % 12 + 1)))
    day=$(printf '%02d' $((RANDOM % 28 + 1)))

    cat > "doc_${i}.md" << INNEREOF
---
title: Document ${i}
category: ${category}
priority: ${priority}
status: ${status}
date: 2026-${month}-${day}
---

# Document ${i}: Sample Content

This is a sample document for the ${category} category.
Priority level: ${priority}
Current status: ${status}
INNEREOF
done

echo "生成完了:"
ls doc_*.md | head -5
echo "...（合計 $(ls doc_*.md | wc -l) 個）"
echo ""

echo "--- メタデータを抽出してCSVに変換 ---"
echo ""

cd "${WORKDIR}"
{
    echo "filename,title,category,priority,status,date"
    for f in docs/doc_*.md; do
        fname=$(basename "$f")
        title=$(grep "^title:" "$f" | sed 's/^title: //')
        category=$(grep "^category:" "$f" | sed 's/^category: //')
        priority=$(grep "^priority:" "$f" | sed 's/^priority: //')
        status=$(grep "^status:" "$f" | sed 's/^status: //')
        date_val=$(grep "^date:" "$f" | sed 's/^date: //')
        echo "${fname},${title},${category},${priority},${status},${date_val}"
    done
} > metadata.csv

echo "生成されたCSV（先頭10行）:"
head -11 metadata.csv
echo ""
echo "合計行数: $(wc -l < metadata.csv)"
echo ""
echo "GUIで同じタスクを行う場合:"
echo "  100個のファイルを手動で開き、frontmatterをコピーしてExcelに貼り付ける"
echo "  1ファイル30秒 × 100 = 約50分"
echo "  CLIなら数秒で完了"

# ==============================================
# 演習2: 抽出データの分析パイプライン
# ==============================================

echo ""
echo "=============================================="
echo "[演習2] 抽出データの分析パイプライン"
echo "=============================================="
echo ""

echo "--- カテゴリ別文書数 ---"
tail -n +2 metadata.csv | cut -d',' -f3 | sort | uniq -c | sort -rn
echo ""

echo "--- ステータス別文書数 ---"
tail -n +2 metadata.csv | cut -d',' -f5 | sort | uniq -c | sort -rn
echo ""

echo "--- 優先度1（最高）のdraft文書（要対応）---"
tail -n +2 metadata.csv | awk -F',' '$4 == 1 && $5 == "draft" {print $1, $2}' || echo "(該当なし)"
echo ""

echo "--- カテゴリ別・ステータス別クロス集計 ---"
echo "category,draft,review,published"
for cat in frontend backend infrastructure testing; do
    draft=$(tail -n +2 metadata.csv | awk -F',' -v c="$cat" '$3==c && $5=="draft"' | wc -l)
    review=$(tail -n +2 metadata.csv | awk -F',' -v c="$cat" '$3==c && $5=="review"' | wc -l)
    published=$(tail -n +2 metadata.csv | awk -F',' -v c="$cat" '$3==c && $5=="published"' | wc -l)
    echo "${cat},${draft},${review},${published}"
done
echo ""

echo "使用したツール: tail, cut, sort, uniq, awk, wc"
echo "→ 6つのツールの組み合わせで複合分析を実現"

# ==============================================
# 演習3: 分析スクリプトの作成と再利用
# ==============================================

echo ""
echo "=============================================="
echo "[演習3] 再現可能な分析スクリプトの作成"
echo "=============================================="
echo ""

cat > "${WORKDIR}/analyze-docs.sh" << 'SCRIPTEOF'
#!/bin/bash
set -euo pipefail

# ドキュメント分析スクリプト
# 使い方: ./analyze-docs.sh <docs_directory> [output_directory]

DOCS_DIR="${1:?使い方: $0 <docs_directory> [output_directory]}"
OUTPUT_DIR="${2:-./analysis-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$OUTPUT_DIR"

echo "=== ドキュメント分析レポート ==="
echo "対象: ${DOCS_DIR}"
echo "日時: $(date)"
echo "出力: ${OUTPUT_DIR}"
echo ""

# Step 1: メタデータ抽出
echo "filename,title,category,priority,status,date" > "${OUTPUT_DIR}/metadata.csv"
for f in "${DOCS_DIR}"/doc_*.md; do
    [ -f "$f" ] || continue
    fname=$(basename "$f")
    title=$(grep "^title:" "$f" | sed 's/^title: //')
    category=$(grep "^category:" "$f" | sed 's/^category: //')
    priority=$(grep "^priority:" "$f" | sed 's/^priority: //')
    status=$(grep "^status:" "$f" | sed 's/^status: //')
    date_val=$(grep "^date:" "$f" | sed 's/^date: //')
    echo "${fname},${title},${category},${priority},${status},${date_val}"
done >> "${OUTPUT_DIR}/metadata.csv"

total=$(($(wc -l < "${OUTPUT_DIR}/metadata.csv") - 1))

# Step 2: サマリ生成
{
    echo "=== ドキュメント分析サマリ ==="
    echo "生成日時: $(date)"
    echo "対象ディレクトリ: ${DOCS_DIR}"
    echo "総文書数: ${total}"
    echo ""
    echo "--- カテゴリ別 ---"
    tail -n +2 "${OUTPUT_DIR}/metadata.csv" | cut -d',' -f3 | sort | uniq -c | sort -rn
    echo ""
    echo "--- ステータス別 ---"
    tail -n +2 "${OUTPUT_DIR}/metadata.csv" | cut -d',' -f5 | sort | uniq -c | sort -rn
    echo ""
    echo "--- 要対応（優先度1 + draft）---"
    tail -n +2 "${OUTPUT_DIR}/metadata.csv" | awk -F',' '$4 == 1 && $5 == "draft" {print $1, $2}'
} > "${OUTPUT_DIR}/summary.txt"

cat "${OUTPUT_DIR}/summary.txt"
echo ""
echo "出力ファイル:"
ls -la "${OUTPUT_DIR}/"
SCRIPTEOF

chmod +x "${WORKDIR}/analyze-docs.sh"

echo "--- スクリプトを作成 ---"
echo "ファイル: ${WORKDIR}/analyze-docs.sh"
echo ""

echo "--- スクリプトを実行 ---"
"${WORKDIR}/analyze-docs.sh" "${WORKDIR}/docs" "${WORKDIR}/output"
echo ""

echo "=============================================="
echo " このスクリプトがGUIに対して持つ優位性"
echo "=============================================="
echo ""
echo "1. 再現性:       いつ実行しても同じ手順で分析"
echo "2. 共有性:       チームメンバーにファイルを渡すだけ"
echo "3. バージョン管理: git commitで変更を追跡可能"
echo "4. CI/CD統合:    GitHub Actionsから自動実行可能"
echo "5. スケール:     100個でも10,000個でも同じスクリプト"
echo ""
echo "GUIの優位性:"
echo "  - 結果の可視化（グラフ、チャート）"
echo "  - 対話的なデータ探索"
echo "  - 操作の学習コストが低い"
echo ""

echo "=============================================="
echo " 全演習完了"
echo "=============================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "生成されたファイル:"
echo "  ${WORKDIR}/docs/         -- 100個のMarkdownファイル"
echo "  ${WORKDIR}/metadata.csv  -- 抽出されたメタデータ"
echo "  ${WORKDIR}/analyze-docs.sh -- 再利用可能な分析スクリプト"
echo "  ${WORKDIR}/output/       -- 分析結果"
