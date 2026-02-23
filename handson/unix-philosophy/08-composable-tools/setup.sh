#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-08"

echo "========================================"
echo " 第8回ハンズオン: 小さなツールの組み合わせ"
echo " ——合成可能性の設計"
echo "========================================"
echo ""

# -------------------------------------------
# 環境準備
# -------------------------------------------
echo "[1/7] 環境を準備しています..."
apt-get update -qq && apt-get install -y -qq coreutils gawk > /dev/null 2>&1
mkdir -p "$WORKDIR"
cd "$WORKDIR"
echo "  作業ディレクトリ: $WORKDIR"
echo ""

# -------------------------------------------
# サンプルデータ作成
# -------------------------------------------
echo "[2/7] サンプルデータを作成しています..."

cat << 'EOF' > servers.txt
web01 192.168.1.10 running 45
web02 192.168.1.11 running 72
db01 192.168.1.20 stopped 0
web03 192.168.1.12 running 91
db02 192.168.1.21 running 38
cache01 192.168.1.30 running 65
web04 192.168.1.13 stopped 0
EOF

cat << 'EOF' > access.log
2026-01-15 10:00:01 192.168.1.10 GET /index.html 200 1234
2026-01-15 10:00:02 192.168.1.20 GET /about.html 200 5678
2026-01-15 10:00:03 192.168.1.10 POST /api/data 201 90
2026-01-15 10:00:04 192.168.1.30 GET /index.html 200 1234
2026-01-15 10:00:05 192.168.1.10 GET /style.css 200 456
2026-01-15 10:00:06 192.168.1.20 GET /index.html 304 0
2026-01-15 10:00:07 192.168.1.10 GET /favicon.ico 404 0
2026-01-15 10:00:08 192.168.1.30 GET /about.html 200 5678
2026-01-15 10:00:09 192.168.1.10 GET /api/users 500 0
2026-01-15 10:00:10 192.168.1.40 GET /index.html 200 1234
EOF

echo "  servers.txt と access.log を作成しました"
echo ""

# -------------------------------------------
# 演習1: 合成可能性の四条件を確認する
# -------------------------------------------
echo "[3/7] 演習1: 合成可能性の四条件を確認する"
echo "-------------------------------------------"

echo "条件1: stdin/stdout -- パイプで接続"
echo "  コマンド: cat servers.txt | grep 'running' | awk '{print \$1, \$4}' | sort -k2 -rn"
cat servers.txt | grep "running" | awk '{print $1, $4}' | sort -k2 -rn
echo ""

echo "条件3: 終了コード -- 成功/失敗が伝播する"
grep "running" servers.txt > /dev/null
echo "  grep 'running' -> Exit code: $? (パターン発見)"
grep "maintenance" servers.txt > /dev/null 2>&1 || true
echo "  grep 'maintenance' -> Exit code: 1 (パターン未発見)"
echo ""

echo "条件4: 副作用の最小化 -- grepは入力ファイルを変更しない"
before=$(md5sum servers.txt | awk '{print $1}')
grep "running" servers.txt > /dev/null
after=$(md5sum servers.txt | awk '{print $1}')
echo "  処理前ハッシュ: $before"
echo "  処理後ハッシュ: $after"
if [ "$before" = "$after" ]; then
    echo "  -> ファイル未変更（副作用なし）"
fi
echo ""

# -------------------------------------------
# 演習2: 合成可能なフィルタをシェル関数で作る
# -------------------------------------------
echo "[4/7] 演習2: 合成可能なフィルタをシェル関数で作る"
echo "-------------------------------------------"

high_cpu() {
    local threshold="${1:-80}"
    local found=0
    while IFS= read -r line; do
        cpu=$(echo "$line" | awk '{print $4}')
        if [ "$cpu" -gt "$threshold" ] 2>/dev/null; then
            echo "$line"
            found=1
        fi
    done
    return $((1 - found))
}

format_cpu() {
    awk '{printf "%s\t%s%%\n", $1, $4}'
}

add_alert_prefix() {
    sed 's/^/[ALERT] /'
}

echo "パイプライン: cat servers.txt | grep running | high_cpu 60 | format_cpu | add_alert_prefix"
cat servers.txt | grep "running" | high_cpu 60 | format_cpu | add_alert_prefix || true
echo ""

# -------------------------------------------
# 演習3: 終了コードの活用
# -------------------------------------------
echo "[5/7] 演習3: 終了コードの活用"
echo "-------------------------------------------"

echo "デフォルト: パイプラインの終了コードは最後のコマンドの終了コード"
false | true
echo "  false | true -> Exit code: $?"

echo ""
echo "pipefail: パイプラインの途中の失敗も検出"
set -o pipefail
false | true || true
echo "  false | true (with pipefail) -> Exit code: 1 (falseが伝播)"
set +o pipefail
echo ""

# -------------------------------------------
# 演習4: stderrの正しい使い方
# -------------------------------------------
echo "[6/7] 演習4: stderrの正しい使い方"
echo "-------------------------------------------"

bad_filter() {
    while IFS= read -r line; do
        cpu=$(echo "$line" | awk '{print $4}')
        if [ "$cpu" -gt 80 ] 2>/dev/null; then
            echo "$line"
        fi
        echo "Processing: $line"
    done
}

good_filter() {
    while IFS= read -r line; do
        cpu=$(echo "$line" | awk '{print $4}')
        if [ "$cpu" -gt 80 ] 2>/dev/null; then
            echo "$line"
        fi
        echo "Processing: $line" >&2
    done
}

bad_count=$(cat servers.txt | bad_filter 2>/dev/null | wc -l)
good_count=$(cat servers.txt | good_filter 2>/dev/null | wc -l)

echo "  bad_filter  | wc -l -> $bad_count 行（ステータスメッセージ混入）"
echo "  good_filter | wc -l -> $good_count 行（データのみ）"
echo "  -> stderrにステータスを出力することで、stdoutの純粋性を保つ"
echo ""

# -------------------------------------------
# 演習5-6: シェルの接続パターンと実践的組み立て
# -------------------------------------------
echo "[7/7] 演習5-6: シェルの接続パターンと実践的組み立て"
echo "-------------------------------------------"

echo "プロセス置換: diff <(running) <(stopped)"
diff <(grep "running" servers.txt | awk '{print $1}') \
     <(grep "stopped" servers.txt | awk '{print $1}') || true
echo ""

echo "tee: パイプラインの途中経過を分岐して保存"
running_count=$(cat servers.txt | grep "running" | tee running_servers.txt | wc -l)
echo "  runningサーバ: $running_count 台（running_servers.txt に保存）"
echo ""

echo "実践: アクセスログからエラー応答を集計"
echo "  コマンド: awk '\$6 >= 400' access.log | awk '{print \$3, \$5}' | sort | uniq -c | sort -rn"
awk '$6 >= 400 {print $3, $5}' access.log | sort | uniq -c | sort -rn
echo ""

echo "実践: IPアドレスごとの転送バイト数"
awk '{bytes[$3] += $7} END {for (ip in bytes) print ip, bytes[ip]}' access.log | sort -k2 -rn
echo ""

echo "========================================"
echo " ハンズオン完了"
echo " 作業ディレクトリ: $WORKDIR"
echo "========================================"
