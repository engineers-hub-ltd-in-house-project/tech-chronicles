#!/bin/bash
# =============================================================================
# 第20回ハンズオン：PowerShell――テキストパイプラインへの根本的批判
#   テキスト vs オブジェクト vs 構造化データパイプラインの比較
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: procps, jq
# 推奨環境: Docker (ubuntu:24.04)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/command-line-handson-20"

echo "=== 第20回ハンズオン：PowerShell――テキストパイプラインへの根本的批判 ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# 依存パッケージのインストール
echo "[準備] 必要なパッケージをインストール"
apt-get update -qq && apt-get install -y -qq procps jq > /dev/null 2>&1
echo "  procps, jq をインストールしました。"
echo ""

# --- 演習1: テキストパイプラインの強さと脆さ ---
echo "[演習1] テキストパイプラインの強さと脆さ"
echo ""

echo "  --- psの出力（先頭5行） ---"
ps aux | head -5
echo ""

echo "  --- awkで特定列を抽出 ---"
ps aux | awk 'NR>1 {printf "  PID=%-8s CPU=%-6s MEM=%-6s CMD=%s\n", $2, $3, $4, $11}' | head -10
echo ""

echo "  --- テキストパイプラインの脆弱性 ---"
echo "  ps aux | awk '{print \$11}' の結果（先頭10行）:"
ps aux | awk '{print $11}' | head -10
echo ""
echo "  → \$11はCOMMAND列の最初の単語のみ。引数を含むコマンド名では"
echo "    情報が失われる。列番号ベースのパースは出力フォーマットに依存する。"
echo "    これがSnoverの言う'prayer-based parsing'だ。"
echo ""

echo "  --- ps -oで出力フォーマットを明示指定（堅牢なアプローチ） ---"
ps -eo pid,pcpu,pmem,comm --sort=-pcpu | head -10
echo ""

# --- 演習2: オブジェクトパイプラインの疑似体験 ---
echo "[演習2] PowerShellのオブジェクトパイプラインを疑似体験"
echo ""

echo "  --- プロセス情報をJSON構造として取得 ---"
ps -eo pid,pcpu,pmem,comm --no-headers | head -5 | awk '{
  printf "  {\"pid\": %s, \"cpu\": %s, \"mem\": %s, \"name\": \"%s\"}\n", $1, $2, $3, $4
}' | jq -s '.'
echo ""

echo "  --- jqによる構造化データのフィルタリング ---"
echo "  CPU使用率が0より大きいプロセス上位5件:"
ps -eo pid,pcpu,pmem,comm --no-headers | awk '{
  printf "{\"pid\": %s, \"cpu\": %s, \"mem\": %s, \"name\": \"%s\"}\n", $1, $2, $3, $4
}' | jq -s '[.[] | select(.cpu > 0)] | sort_by(-.cpu) | .[:5]'
echo ""
echo "  → jqならプロパティ名でアクセスし、型付き比較が可能。"
echo "    PowerShellの Where-Object { \$_.CPU -gt 0 } と同等の操作だ。"
echo ""

# --- 演習3: テキスト vs 構造化データの堅牢性比較 ---
echo "[演習3] テキスト vs 構造化データの堅牢性比較"
echo ""

# テストデータを作成
cat > "${WORKDIR}/data.json" << 'JSONEOF'
[
  {"name": "Alice Johnson", "age": 32, "department": "Engineering", "salary": 95000},
  {"name": "Bob Smith", "age": 45, "department": "Sales", "salary": 78000},
  {"name": "Carol Williams", "age": 28, "department": "Engineering", "salary": 88000},
  {"name": "David Lee", "age": 51, "department": "Management", "salary": 120000},
  {"name": "Eve Brown", "age": 35, "department": "Engineering", "salary": 102000},
  {"name": "Frank O'Brien", "age": 42, "department": "Sales", "salary": 82000}
]
JSONEOF

cat > "${WORKDIR}/data.csv" << 'CSVEOF'
name,age,department,salary
Alice Johnson,32,Engineering,95000
Bob Smith,45,Sales,78000
Carol Williams,28,Engineering,88000
David Lee,51,Management,120000
Eve Brown,35,Engineering,102000
Frank O'Brien,42,Sales,82000
CSVEOF

echo "  テストデータを ${WORKDIR} に作成しました。"
echo ""

echo "  --- Engineeringの平均給与を求める ---"
echo ""
echo "  [テキストパイプライン（CSV + awk）]:"
grep "Engineering" "${WORKDIR}/data.csv" | awk -F, '{sum+=$4; n++} END {printf "  平均給与: %.0f\n", sum/n}'
echo ""

echo "  [構造化データパイプライン（JSON + jq）]:"
printf "  平均給与: "
jq '[.[] | select(.department=="Engineering")] | map(.salary) | add / length' "${WORKDIR}/data.json"
echo ""

echo "  → テキストパイプラインでは、grepがヘッダーや他のフィールドの"
echo "    'Engineering'にもマッチするリスクがある。"
echo "    構造化データではフィールド名で厳密にフィルタする。"
echo ""

# --- 演習4: 三つの設計思想の総合比較 ---
echo "[演習4] 三つの設計思想の総合比較"
echo ""

echo "  タスク: /etcの下でサイズが1KBを超えるファイル上位5件"
echo ""

echo "  [UNIXテキストパイプライン]:"
find /etc -type f -exec ls -la {} + 2>/dev/null | awk '$5 > 1024' | sort -k5 -rn | head -5
echo ""

echo "  [構造化データパイプライン（jq）]:"
find /etc -type f -exec stat --format='{"name":"%n","size":%s}' {} + 2>/dev/null | jq -s '[.[] | select(.size > 1024)] | sort_by(-.size) | .[:5] | .[] | "\(.size)\t\(.name)"'
echo ""

echo "  → テキストパイプラインは簡潔だが列番号に依存する。"
echo "    構造化データパイプラインは冗長だがフィールド名で明示的にアクセスする。"
echo "    どちらが適切かは文脈による。正解は一つではない。"
echo ""

echo "=== 演習完了 ==="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "テストデータ: ${WORKDIR}/data.json, ${WORKDIR}/data.csv"
