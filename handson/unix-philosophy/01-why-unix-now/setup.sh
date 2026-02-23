#!/bin/bash
# =============================================================================
# 第1回ハンズオン：UNIXコマンドだけで構築するデータ処理パイプライン
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 推奨環境: docker run -it --rm ubuntu:24.04 bash
# 必要なツール: cat, grep, sort, uniq, wc, cut, tr, sed, awk, head, tail, diff
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-01"

echo "=== 第1回ハンズオン：UNIXコマンドだけで構築するデータ処理パイプライン ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- サンプルデータ生成 ---
echo "[準備] 疑似アクセスログの生成"

cat > "${WORKDIR}/access.log" << 'EOF'
192.168.1.10 - - [23/Feb/2026:10:15:32 +0900] "GET /api/users HTTP/1.1" 200 1234
10.0.0.5 - - [23/Feb/2026:10:15:33 +0900] "POST /api/login HTTP/1.1" 200 567
192.168.1.10 - - [23/Feb/2026:10:15:34 +0900] "GET /api/users/42 HTTP/1.1" 200 890
172.16.0.100 - - [23/Feb/2026:10:15:35 +0900] "GET /api/products HTTP/1.1" 200 2345
10.0.0.5 - - [23/Feb/2026:10:15:36 +0900] "POST /api/orders HTTP/1.1" 201 678
192.168.1.10 - - [23/Feb/2026:10:15:37 +0900] "DELETE /api/users/42 HTTP/1.1" 204 0
172.16.0.100 - - [23/Feb/2026:10:15:38 +0900] "GET /api/products/7 HTTP/1.1" 404 123
10.0.0.5 - - [23/Feb/2026:10:15:39 +0900] "POST /api/login HTTP/1.1" 401 234
192.168.1.20 - - [23/Feb/2026:10:15:40 +0900] "GET /api/users HTTP/1.1" 200 1234
10.0.0.5 - - [23/Feb/2026:10:15:41 +0900] "POST /api/login HTTP/1.1" 200 567
172.16.0.100 - - [23/Feb/2026:10:15:42 +0900] "GET /api/products HTTP/1.1" 200 2345
192.168.1.10 - - [23/Feb/2026:10:15:43 +0900] "GET /api/users HTTP/1.1" 200 1234
10.0.0.5 - - [23/Feb/2026:10:15:44 +0900] "PUT /api/users/5 HTTP/1.1" 200 890
172.16.0.200 - - [23/Feb/2026:10:15:45 +0900] "GET /api/products HTTP/1.1" 500 456
192.168.1.10 - - [23/Feb/2026:10:15:46 +0900] "GET /api/health HTTP/1.1" 200 12
EOF

echo "  ${WORKDIR}/access.log を作成しました（15行）"
echo ""

# --- 演習1: IPアドレス別アクセス数 ---
echo "[演習1] IPアドレス別アクセス数の集計"
echo "  コマンド: cut -d' ' -f1 access.log | sort | uniq -c | sort -rn"
echo "  結果:"
cut -d' ' -f1 "${WORKDIR}/access.log" | sort | uniq -c | sort -rn | sed 's/^/    /'
echo ""

# --- 演習2: HTTPステータスコード別集計 ---
echo "[演習2] HTTPステータスコード別の集計"
echo "  コマンド: awk '{print \$9}' access.log | sort | uniq -c | sort -rn"
echo "  結果:"
awk '{print $9}' "${WORKDIR}/access.log" | sort | uniq -c | sort -rn | sed 's/^/    /'
echo ""

# --- 演習3: エラーリクエストの抽出 ---
echo "[演習3] エラーリクエスト（4xx/5xx）の詳細"
echo "  コマンド: awk '\$9 >= 400 {print \$1, \$7, \$9}' access.log"
echo "  結果:"
awk '$9 >= 400 {printf "    %s %s → %s\n", $1, $7, $9}' "${WORKDIR}/access.log"
echo ""

# --- 演習4: HTTPメソッド別集計 ---
echo "[演習4] HTTPメソッド別アクセス数"
echo "  コマンド: awk '{print \$6}' access.log | tr -d '\"' | sort | uniq -c | sort -rn"
echo "  結果:"
awk '{print $6}' "${WORKDIR}/access.log" | tr -d '"' | sort | uniq -c | sort -rn | sed 's/^/    /'
echo ""

# --- 演習5: プロセス置換による比較 ---
echo "[演習5] GETとPOSTリクエスト送信元の比較（プロセス置換）"
echo "  コマンド: diff <(grep '\"GET ' ... | cut -d' ' -f1 | sort -u) <(grep '\"POST ' ... | cut -d' ' -f1 | sort -u)"
echo "  結果:"
diff <(grep '"GET ' "${WORKDIR}/access.log" | cut -d' ' -f1 | sort -u) \
     <(grep '"POST ' "${WORKDIR}/access.log" | cut -d' ' -f1 | sort -u) | sed 's/^/    /' || true
echo ""

# --- 演習6: 総合レポート ---
echo "[演習6] 総合レポートの生成"
echo ""
echo "    === Access Log Report ==="
echo ""
echo "    --- Total Requests ---"
printf "    %s\n" "$(wc -l < "${WORKDIR}/access.log")"
echo ""
echo "    --- Top Endpoints ---"
awk '{print $7}' "${WORKDIR}/access.log" | sort | uniq -c | sort -rn | head -5 | sed 's/^/    /'
echo ""

echo "=== ハンズオン完了 ==="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "ログファイル: ${WORKDIR}/access.log"
echo ""
echo "自分でコマンドを組み合わせて、さらなる分析を試してみてください。"
echo "例: 時間帯別アクセス数、エンドポイント別エラー率など"
