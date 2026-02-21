#!/bin/bash
# =============================================================================
# 第6回ハンズオン：パイプとUNIX哲学を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 前提: Docker環境（ubuntu:24.04）またはbashが使えるLinux環境
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-06"

echo "=== 第6回ハンズオン：パイプとUNIX哲学を体験する ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# jqのインストール確認
if command -v jq > /dev/null 2>&1; then
  echo "jq: インストール済み ($(jq --version))"
else
  echo "jq をインストールします..."
  if command -v apt-get > /dev/null 2>&1; then
    apt-get update -qq && apt-get install -y -qq jq
  else
    echo "警告: jqを自動インストールできません。"
    echo "演習2, 3, 5の一部はスキップされます。"
  fi
fi
echo ""

# --- サンプルデータの作成 ---
echo "サンプルデータを作成しています..."

# テキスト形式のアクセスログ
cat > "${WORKDIR}/access.log" << 'EOF'
192.168.1.10 - - [21/Feb/2026:10:15:30] "GET /index.html HTTP/1.1" 200 1234
192.168.1.20 - - [21/Feb/2026:10:15:31] "GET /api/users HTTP/1.1" 200 5678
192.168.1.30 - - [21/Feb/2026:10:15:32] "POST /api/login HTTP/1.1" 401 89
192.168.1.10 - - [21/Feb/2026:10:15:33] "GET /style.css HTTP/1.1" 200 2345
192.168.1.40 - - [21/Feb/2026:10:15:34] "GET /api/data HTTP/1.1" 500 123
192.168.1.20 - - [21/Feb/2026:10:15:35] "GET /index.html HTTP/1.1" 200 1234
192.168.1.50 - - [21/Feb/2026:10:15:36] "DELETE /api/users/5 HTTP/1.1" 403 45
192.168.1.10 - - [21/Feb/2026:10:15:37] "GET /favicon.ico HTTP/1.1" 404 0
192.168.1.30 - - [21/Feb/2026:10:15:38] "POST /api/login HTTP/1.1" 200 3456
192.168.1.40 - - [21/Feb/2026:10:15:39] "GET /api/data HTTP/1.1" 500 123
EOF

# JSON形式のアクセスログ
cat > "${WORKDIR}/access.json" << 'EOF'
{"timestamp":"2026-02-21T10:15:30Z","ip":"192.168.1.10","method":"GET","path":"/index.html","status":200,"bytes":1234}
{"timestamp":"2026-02-21T10:15:31Z","ip":"192.168.1.20","method":"GET","path":"/api/users","status":200,"bytes":5678}
{"timestamp":"2026-02-21T10:15:32Z","ip":"192.168.1.30","method":"POST","path":"/api/login","status":401,"bytes":89}
{"timestamp":"2026-02-21T10:15:33Z","ip":"192.168.1.10","method":"GET","path":"/style.css","status":200,"bytes":2345}
{"timestamp":"2026-02-21T10:15:34Z","ip":"192.168.1.40","method":"GET","path":"/api/data","status":500,"bytes":123}
{"timestamp":"2026-02-21T10:15:35Z","ip":"192.168.1.20","method":"GET","path":"/index.html","status":200,"bytes":1234}
{"timestamp":"2026-02-21T10:15:36Z","ip":"192.168.1.50","method":"DELETE","path":"/api/users/5","status":403,"bytes":45}
{"timestamp":"2026-02-21T10:15:37Z","ip":"192.168.1.10","method":"GET","path":"/favicon.ico","status":404,"bytes":0}
{"timestamp":"2026-02-21T10:15:38Z","ip":"192.168.1.30","method":"POST","path":"/api/login","status":200,"bytes":3456}
{"timestamp":"2026-02-21T10:15:39Z","ip":"192.168.1.40","method":"GET","path":"/api/data","status":500,"bytes":123}
EOF

# ネストされたJSONデータ
cat > "${WORKDIR}/servers.json" << 'EOF'
{
  "servers": [
    {
      "name": "web-01",
      "region": "ap-northeast-1",
      "status": "running",
      "resources": {
        "cpu_percent": 45.2,
        "memory_mb": 2048,
        "disk_gb": 50
      },
      "tags": ["production", "web"]
    },
    {
      "name": "api-01",
      "region": "ap-northeast-1",
      "status": "running",
      "resources": {
        "cpu_percent": 78.5,
        "memory_mb": 4096,
        "disk_gb": 100
      },
      "tags": ["production", "api"]
    },
    {
      "name": "db-01",
      "region": "us-east-1",
      "status": "running",
      "resources": {
        "cpu_percent": 92.1,
        "memory_mb": 8192,
        "disk_gb": 500
      },
      "tags": ["production", "database"]
    },
    {
      "name": "dev-01",
      "region": "ap-northeast-1",
      "status": "stopped",
      "resources": {
        "cpu_percent": 0,
        "memory_mb": 1024,
        "disk_gb": 20
      },
      "tags": ["development"]
    }
  ]
}
EOF

echo "サンプルデータ作成完了"
echo ""

# --- 演習1: パイプの基本動作 ---
echo "================================================================"
echo "[演習1] パイプの基本動作"
echo "================================================================"
echo ""
echo "テキスト行がパイプを通じて段階的に変換される様子を確認する。"
echo ""

echo "--- ステップ1: 元データ（先頭5行） ---"
head -5 "${WORKDIR}/access.log"
echo "..."
echo ""

echo "--- ステップ2: レスポンスコード列を抽出（awk） ---"
awk '{print $9}' "${WORKDIR}/access.log"
echo ""

echo "--- ステップ3: ソート ---"
awk '{print $9}' "${WORKDIR}/access.log" | sort
echo ""

echo "--- ステップ4: 重複カウント ---"
awk '{print $9}' "${WORKDIR}/access.log" | sort | uniq -c
echo ""

echo "--- ステップ5: 降順ソート ---"
awk '{print $9}' "${WORKDIR}/access.log" | sort | uniq -c | sort -rn
echo ""

echo "各段階で、テキスト行が次のコマンドに渡されている。"
echo "各コマンドは前段の出力形式（テキスト行）を前提としている。"
echo ""

# --- 演習2: テキストパイプの限界 ---
echo "================================================================"
echo "[演習2] テキストパイプの限界――JSONとの格闘"
echo "================================================================"
echo ""
echo "同じタスクをgrep/awkとjqで比較する。"
echo ""

echo "--- 方法1: grepで無理やり抽出（脆弱） ---"
grep -o '"status":[0-9]*' "${WORKDIR}/access.json" \
  | cut -d':' -f2 \
  | sort \
  | uniq -c \
  | sort -rn
echo ""
echo "grepはJSONの構造を理解しない。"
echo "キー名に'status'を含む別のフィールドがあれば誤抽出する。"
echo ""

if command -v jq > /dev/null 2>&1; then
  echo "--- 方法2: jqで構造的に抽出（堅牢） ---"
  jq -r '.status' "${WORKDIR}/access.json" \
    | sort \
    | uniq -c \
    | sort -rn
  echo ""
  echo "jqはJSONの構造を理解する。.statusで正確にフィールドを指定できる。"
  echo ""

  echo "--- 方法3: jqだけで完結（テキストツール不要） ---"
  jq -s 'group_by(.status) | map({status: .[0].status, count: length}) | sort_by(-.count)' \
    "${WORKDIR}/access.json"
  echo ""
  echo "jqの-sオプションで全行をスラープし、内部でグループ化と集計を行う。"
  echo "出力はJSON形式。型情報が保持されている。"
  echo ""
else
  echo "jqが見つかりません。方法2, 3はスキップします。"
  echo ""
fi

# --- 演習3: jqの構造化フィルタリング ---
echo "================================================================"
echo "[演習3] jqの構造化フィルタリング"
echo "================================================================"
echo ""

if ! command -v jq > /dev/null 2>&1; then
  echo "jqが見つかりません。この演習はスキップします。"
  echo ""
else
  echo "ネストされたJSONをパイプライン的フィルタで処理する。"
  echo ""

  echo "--- 稼働中サーバの名前とCPU使用率 ---"
  jq '.servers[] | select(.status == "running") | {name, cpu: .resources.cpu_percent}' \
    "${WORKDIR}/servers.json"
  echo ""

  echo "--- CPU使用率80%超のサーバ（アラート対象） ---"
  jq '.servers[] | select(.resources.cpu_percent > 80) | .name' \
    "${WORKDIR}/servers.json"
  echo ""

  echo "--- リージョン別のサーバ数 ---"
  jq '[.servers[] | .region] | group_by(.) | map({region: .[0], count: length})' \
    "${WORKDIR}/servers.json"
  echo ""

  echo "--- productionタグを持つサーバのメモリ合計 ---"
  TOTAL_MEM=$(jq '[.servers[] | select(.tags | index("production")) | .resources.memory_mb] | add' \
    "${WORKDIR}/servers.json")
  echo "${TOTAL_MEM} MB"
  echo ""

  echo "grepやawkではネストされたJSONの処理は事実上不可能だ。"
  echo "jqはJSONの構造を理解し、パイプライン的なフィルタで処理する。"
  echo ""
fi

# --- 演習4: パイプのバッファと背圧 ---
echo "================================================================"
echo "[演習4] パイプのバッファと背圧"
echo "================================================================"
echo ""
echo "パイプのカーネル実装を確認する。"
echo ""

echo "--- パイプバッファの確認 ---"
if [ -f /proc/sys/fs/pipe-max-size ]; then
  echo "パイプ最大容量: $(cat /proc/sys/fs/pipe-max-size) バイト"
fi

echo "--- PIPE_BUFの確認 ---"
echo "POSIX PIPE_BUF（アトミック書き込み保証）: 最低512バイト"
if command -v getconf > /dev/null 2>&1; then
  echo "この環境のPIPE_BUF: $(getconf PIPE_BUF /) バイト"
fi
echo ""

echo "--- 背圧のデモ: 高速な書き手と低速な読み手 ---"
echo "yesは毎秒数百万行を生成するが、headが1行読んで終了すると"
echo "パイプが閉じ、yesはSIGPIPEを受けて停止する。"
echo ""
yes "hello" 2>/dev/null | head -1
echo ""
echo "パイプの読み手が終了すると、書き手はSIGPIPEシグナルを受けて停止する。"
echo "これがパイプの「背圧」の一形態だ。"
echo ""

# --- 演習5: 伝統的パイプ vs jq ---
echo "================================================================"
echo "[演習5] 伝統的パイプ vs jq――同じタスクの比較"
echo "================================================================"
echo ""
echo "IPアドレス別のアクセス数とバイト合計を集計する。"
echo ""

echo "--- 伝統的パイプ（テキストログ） ---"
echo "IPアドレス別アクセス数:"
awk '{print $1}' "${WORKDIR}/access.log" | sort | uniq -c | sort -rn
echo ""
echo "IPアドレス別バイト合計:"
awk '{bytes[$1]+=$10} END {for(ip in bytes) print bytes[ip], ip}' \
  "${WORKDIR}/access.log" | sort -rn
echo ""

if command -v jq > /dev/null 2>&1; then
  echo "--- jqパイプ（JSONログ） ---"
  echo "IPアドレス別アクセス数:"
  jq -r '.ip' "${WORKDIR}/access.json" | sort | uniq -c | sort -rn
  echo ""
  echo "IPアドレス別バイト合計（jqで完結）:"
  jq -s 'group_by(.ip) | map({ip: .[0].ip, total_bytes: (map(.bytes) | add), count: length}) | sort_by(-.total_bytes)' \
    "${WORKDIR}/access.json"
  echo ""
fi

echo "=== 比較結果 ==="
echo "テキストパイプ: フィールド番号でアクセス。ログ形式に依存。"
echo "jqパイプ: フィールド名でアクセス。構造変更に強い。"
echo ""

# --- 完了 ---
echo "================================================================"
echo " 演習完了"
echo "================================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "パイプは天才的な発明だった。"
echo "だが「すべてはテキスト」の前提は、構造化データの時代に揺らいでいる。"
echo "変わるべきは、パイプの中を流れるものの「前提」のほうだ。"

# 掃除
rm -rf "${WORKDIR}"
