#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-07"

echo "========================================"
echo " 第7回ハンズオン: テキストストリーム"
echo " ——万能インタフェースとしてのテキスト"
echo "========================================"
echo ""

# -------------------------------------------
# 環境準備
# -------------------------------------------
echo "[1/6] 環境を準備しています..."
apt-get update -qq && apt-get install -y -qq jq curl gawk > /dev/null 2>&1
mkdir -p "$WORKDIR"
cd "$WORKDIR"
echo "  作業ディレクトリ: $WORKDIR"
echo ""

# -------------------------------------------
# 演習1: sedによるテキストストリーム変換
# -------------------------------------------
echo "[2/6] 演習1: sedによるテキストストリーム変換"
echo "-------------------------------------------"

cat << 'EOF' > httpd.conf
ServerRoot "/etc/httpd"
Listen 80
MaxClients 150
ServerName www.example.com
DocumentRoot "/var/www/html"
MaxClients 150
EOF

echo "  元の設定ファイル:"
cat httpd.conf | sed 's/^/    /'
echo ""

echo "  sedで MaxClients 150 → 256 に変更:"
sed 's/MaxClients 150/MaxClients 256/' httpd.conf | sed 's/^/    /'
echo ""

echo "  複数の変換を組み合わせ (Listen変更 + MaxClients変更):"
sed -e 's/Listen 80/Listen 8080/' \
    -e 's/MaxClients 150/MaxClients 256/' \
    httpd.conf | sed 's/^/    /'
echo ""

# -------------------------------------------
# 演習2: awkによるテキストデータ集計
# -------------------------------------------
echo "[3/6] 演習2: awkによるテキストデータ集計"
echo "-------------------------------------------"

cat << 'EOF' > access.log
192.168.1.10 - - [01/Jan/2026:10:00:01] "GET /index.html HTTP/1.1" 200 1234
192.168.1.20 - - [01/Jan/2026:10:00:02] "GET /about.html HTTP/1.1" 200 5678
192.168.1.10 - - [01/Jan/2026:10:00:03] "POST /api/data HTTP/1.1" 201 90
192.168.1.30 - - [01/Jan/2026:10:00:04] "GET /index.html HTTP/1.1" 200 1234
192.168.1.10 - - [01/Jan/2026:10:00:05] "GET /style.css HTTP/1.1" 200 456
192.168.1.20 - - [01/Jan/2026:10:00:06] "GET /index.html HTTP/1.1" 304 0
192.168.1.10 - - [01/Jan/2026:10:00:07] "GET /favicon.ico HTTP/1.1" 404 0
192.168.1.30 - - [01/Jan/2026:10:00:08] "GET /about.html HTTP/1.1" 200 5678
EOF

echo "  サンプルログ (access.log):"
cat access.log | sed 's/^/    /'
echo ""

echo "  IPアドレスごとのアクセス数:"
awk '{count[$1]++} END {for (ip in count) print ip, count[ip]}' access.log | sort -k2 -rn | sed 's/^/    /'
echo ""

echo "  HTTPステータスコード別の集計:"
awk '{status[$9]++} END {for (s in status) print s, status[s]}' access.log | sort | sed 's/^/    /'
echo ""

echo "  IPアドレスごとのレスポンスバイト数合計:"
awk '{bytes[$1] += $10} END {for (ip in bytes) print ip, bytes[ip]}' access.log | sort -k2 -rn | sed 's/^/    /'
echo ""

# -------------------------------------------
# 演習3: 正規表現 (BRE/ERE)
# -------------------------------------------
echo "[4/6] 演習3: 正規表現によるパターンマッチ"
echo "-------------------------------------------"

echo "  IPアドレスのパターンマッチ (ERE):"
grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' access.log | sort -u | sed 's/^/    /'
echo ""

echo "  sedでタイムスタンプを抽出:"
sed -n 's/.*\[\([^]]*\)\].*/\1/p' access.log | sed 's/^/    /'
echo ""

echo "  BRE vs ERE の比較:"
echo "    BRE: echo '2026-01-15' | grep '\\([0-9]\\{4\\}\\)-\\([0-9]\\{2\\}\\)'"
echo "2026-01-15" | grep '\([0-9]\{4\}\)-\([0-9]\{2\}\)' | sed 's/^/      結果: /'
echo "    ERE: echo '2026-01-15' | grep -E '([0-9]{4})-([0-9]{2})'"
echo "2026-01-15" | grep -E '([0-9]{4})-([0-9]{2})' | sed 's/^/      結果: /'
echo ""

# -------------------------------------------
# 演習4: jqによるJSON処理
# -------------------------------------------
echo "[5/6] 演習4: jqによるJSON処理"
echo "-------------------------------------------"

cat << 'EOF' > access.json
[
  {"ip":"192.168.1.10","path":"/index.html","method":"GET","status":200,"bytes":1234},
  {"ip":"192.168.1.20","path":"/about.html","method":"GET","status":200,"bytes":5678},
  {"ip":"192.168.1.10","path":"/api/data","method":"POST","status":201,"bytes":90},
  {"ip":"192.168.1.30","path":"/index.html","method":"GET","status":200,"bytes":1234},
  {"ip":"192.168.1.10","path":"/style.css","method":"GET","status":200,"bytes":456},
  {"ip":"192.168.1.20","path":"/index.html","method":"GET","status":304,"bytes":0},
  {"ip":"192.168.1.10","path":"/favicon.ico","method":"GET","status":404,"bytes":0},
  {"ip":"192.168.1.30","path":"/about.html","method":"GET","status":200,"bytes":5678}
]
EOF

echo "  jqでIPアドレスごとのアクセス数を集計:"
jq 'group_by(.ip) | map({ip: .[0].ip, count: length}) | sort_by(-.count)' access.json | sed 's/^/    /'
echo ""

echo "  200以外のステータスを抽出:"
jq '.[] | select(.status != 200)' access.json | sed 's/^/    /'
echo ""

echo "  IPアドレスごとのバイト数合計:"
jq 'group_by(.ip) | map({ip: .[0].ip, total_bytes: (map(.bytes) | add)})' access.json | sed 's/^/    /'
echo ""

# -------------------------------------------
# 演習5: テキストとJSONの橋渡し
# -------------------------------------------
echo "[6/6] 演習5: テキストとJSONの橋渡し"
echo "-------------------------------------------"

echo "  jq → テキスト → UNIXツール:"
echo "  (jqの出力をプレーンテキストに変換し、awkで再集計)"
jq -r '.[] | "\(.ip) \(.status) \(.bytes)"' access.json | \
  awk '{bytes[$1] += $3} END {for (ip in bytes) print ip, bytes[ip]}' | \
  sort -k2 -rn | sed 's/^/    /'
echo ""

echo "  テキスト → JSON → jq:"
echo "  (awkでテキストログをJSON化し、jqで集計)"
awk '{print "{\"ip\":\""$1"\",\"status\":"$9",\"bytes\":"$10"}"}' access.log | \
  jq -s 'group_by(.ip) | map({ip: .[0].ip, count: length})' | sed 's/^/    /'
echo ""

echo "========================================"
echo " 全演習完了"
echo " 作業ディレクトリ: $WORKDIR"
echo "========================================"
