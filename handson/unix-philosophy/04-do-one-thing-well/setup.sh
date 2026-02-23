#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-04"

echo "============================================"
echo " 第4回ハンズオン: Do one thing and do it well"
echo "============================================"
echo ""

# --- 作業ディレクトリの作成 ---
echo ">>> 作業ディレクトリを作成: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- 必要なツールのインストール ---
echo ""
echo ">>> 必要なツールをインストール"
apt-get update -qq && apt-get install -y -qq python3 > /dev/null 2>&1
echo "    python3: $(python3 --version)"

# --- サンプルデータの生成 ---
echo ""
echo ">>> サンプルアクセスログを生成（10,000行）"

cat << 'SCRIPT' > gen_log.sh
#!/bin/bash
set -euo pipefail

METHODS=("GET" "POST" "PUT" "DELETE")
PATHS=("/api/users" "/api/posts" "/api/comments" "/health" "/api/auth/login" "/api/search" "/static/main.css" "/static/app.js")
CODES=(200 200 200 200 200 201 204 301 302 400 401 403 404 404 500 502 503)

for i in $(seq 1 10000); do
    method=${METHODS[$((RANDOM % ${#METHODS[@]}))]}
    path=${PATHS[$((RANDOM % ${#PATHS[@]}))]}
    code=${CODES[$((RANDOM % ${#CODES[@]}))]}
    ms=$((RANDOM % 2000))
    printf "2026-02-23T%02d:%02d:%02d %s %s %d %dms\n" \
        $((RANDOM % 24)) $((RANDOM % 60)) $((RANDOM % 60)) \
        "$method" "$path" "$code" "$ms"
done
SCRIPT
chmod +x gen_log.sh
bash gen_log.sh > access.log
echo "    生成完了: $(wc -l < access.log) 行"
echo "    サンプル:"
head -3 access.log | sed 's/^/    /'

# --- Python分析スクリプトの作成 ---
echo ""
echo ">>> Python分析スクリプトを作成"

cat << 'EOF' > analyze.py
"""アクセスログのステータスコード集計 -- Python版"""
import sys
from collections import Counter

def main():
    counter = Counter()

    for line in sys.stdin:
        parts = line.strip().split()
        if len(parts) >= 4:
            status_code = parts[3]
            counter[status_code] += 1

    for code, count in counter.most_common(10):
        print(f"{count:>7} {code}")

if __name__ == "__main__":
    main()
EOF
echo "    analyze.py を作成"

# --- 演習1: UNIXパイプライン ---
echo ""
echo "============================================"
echo " 演習1: UNIXパイプラインによる分析"
echo "============================================"
echo ""
echo "コマンド: awk '{print \$4}' access.log | sort | uniq -c | sort -rn | head -10"
echo ""
echo "--- ステータスコード別集計（上位10件）---"
awk '{print $4}' access.log | sort | uniq -c | sort -rn | head -10

echo ""
echo "--- 各段階の出力 ---"
echo ""
echo "[Step 1] awk '{print \$4}' — 第4フィールドを抽出:"
awk '{print $4}' access.log | head -3
echo "..."

echo ""
echo "[Step 2] | sort — ソート:"
awk '{print $4}' access.log | sort | head -5
echo "..."

echo ""
echo "[Step 3] | uniq -c — 重複を畳んでカウント:"
awk '{print $4}' access.log | sort | uniq -c
echo ""

echo "[Step 4] | sort -rn — 出現回数の降順:"
awk '{print $4}' access.log | sort | uniq -c | sort -rn

echo ""
echo "[Step 5] | head -10 — 上位10件に絞る:"
awk '{print $4}' access.log | sort | uniq -c | sort -rn | head -10

# --- 演習2: Pythonスクリプト ---
echo ""
echo "============================================"
echo " 演習2: Pythonスクリプトによる分析"
echo "============================================"
echo ""
echo "コマンド: cat access.log | python3 analyze.py"
echo ""
cat access.log | python3 analyze.py

# --- 演習3: 性能比較 ---
echo ""
echo "============================================"
echo " 演習3: 設計思想の比較"
echo "============================================"
echo ""
echo "--- UNIXパイプライン ---"
time (awk '{print $4}' access.log | sort | uniq -c | sort -rn | head -10 > /dev/null)

echo ""
echo "--- Pythonスクリプト ---"
time (cat access.log | python3 analyze.py > /dev/null)

# --- 演習4: パイプラインの応用 ---
echo ""
echo "============================================"
echo " 演習4: パイプラインの応用"
echo "============================================"
echo ""

echo "--- ステータスコード別集計 ---"
awk '{print $4}' access.log | sort | uniq -c | sort -rn

echo ""
echo "--- HTTPメソッド別集計 ---"
awk '{print $2}' access.log | sort | uniq -c | sort -rn

echo ""
echo "--- エンドポイント別エラー率（4xx/5xx）---"
awk '$4 >= 400 {print $3}' access.log | sort | uniq -c | sort -rn | head -5

echo ""
echo "--- 時間帯別リクエスト数（時間単位）---"
cut -dT -f2 access.log | cut -d: -f1 | sort | uniq -c | sort -k2

echo ""
echo "--- レスポンスタイム1000ms超のリクエスト ---"
awk '{gsub(/ms/,"",$5); if($5+0 > 1000) print $2, $3, $4, $5"ms"}' access.log | head -10

echo ""
echo "============================================"
echo " ハンズオン完了"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ポイント:"
echo "  - 5つのコマンドが独立したプロセスとして並行動作する"
echo "  - 同じコマンド群の組み合わせを変えるだけで、異なる分析ができる"
echo "  - 各コマンドは「何をやらないか」が明確に定義されている"
echo "  - パイプラインの柔軟性 vs スクリプトの表現力、どちらが適切かは文脈による"
