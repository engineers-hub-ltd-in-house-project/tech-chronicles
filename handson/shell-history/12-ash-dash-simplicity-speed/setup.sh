#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-12"

echo "============================================"
echo " 第12回ハンズオン: ash/dash"
echo " POSIX原理主義と単純さの速度"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

# -------------------------------------------
# セクション1: 作業ディレクトリの準備
# -------------------------------------------
echo "--- セクション1: 作業ディレクトリの準備 ---"
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# -------------------------------------------
# セクション2: 必要パッケージの確認
# -------------------------------------------
echo "--- セクション2: 必要パッケージの確認 ---"
if command -v bash > /dev/null 2>&1; then
    echo "  bash: インストール済み ($(bash --version | head -1))"
else
    echo "  bash: 未インストール"
fi

if command -v dash > /dev/null 2>&1; then
    echo "  dash: インストール済み"
else
    echo "  dash: 未インストール（apt-get install -y dash でインストールしてください）"
fi

if command -v docker > /dev/null 2>&1; then
    echo "  docker: インストール済み ($(docker --version))"
else
    echo "  docker: 未インストール（演習4-5にはDockerが必要です）"
fi

echo ""

# -------------------------------------------
# セクション3: バイナリサイズと依存ライブラリの比較
# -------------------------------------------
echo "--- セクション3: バイナリサイズと依存ライブラリの比較 ---"

echo ""
echo "=== バイナリサイズ ==="
if [ -f /bin/bash ]; then
    echo "  bash: $(ls -lh /bin/bash | awk '{print $5}')"
fi
if [ -f /bin/dash ]; then
    echo "  dash: $(ls -lh /bin/dash | awk '{print $5}')"
fi

echo ""
echo "=== dash の依存ライブラリ ==="
if command -v dash > /dev/null 2>&1 && command -v ldd > /dev/null 2>&1; then
    ldd /bin/dash 2>/dev/null | sed 's/^/  /' || echo "  (ldd 実行不可)"
else
    echo "  (dash または ldd が未インストール)"
fi

echo ""
echo "=== bash の依存ライブラリ ==="
if command -v bash > /dev/null 2>&1 && command -v ldd > /dev/null 2>&1; then
    ldd /bin/bash 2>/dev/null | sed 's/^/  /' || echo "  (ldd 実行不可)"
else
    echo "  (bash または ldd が未インストール)"
fi

# -------------------------------------------
# セクション4: 起動速度ベンチマーク
# -------------------------------------------
echo ""
echo "--- セクション4: 起動速度ベンチマーク（1,000回起動） ---"

if command -v dash > /dev/null 2>&1; then
    echo ""
    echo "=== dash 1,000回起動 ==="
    time for i in $(seq 1 1000); do
        /bin/dash -c 'true'
    done
fi

if command -v bash > /dev/null 2>&1; then
    echo ""
    echo "=== bash 1,000回起動 ==="
    time for i in $(seq 1 1000); do
        /bin/bash -c 'true'
    done
fi

# -------------------------------------------
# セクション5: スクリプト実行速度の比較
# -------------------------------------------
echo ""
echo "--- セクション5: スクリプト実行速度の比較 ---"

cat << 'SCRIPT' > "${WORKDIR}/bench_script.sh"
#!/bin/sh
# ファイル処理シミュレーション（POSIX準拠）
count=0
total=0
i=0
while [ "$i" -lt 500 ]; do
    count=$((count + 1))
    total=$((total + i))
    i=$((i + 1))
done
echo "count=$count total=$total"
SCRIPT
chmod +x "${WORKDIR}/bench_script.sh"
echo "  作成: bench_script.sh"

if command -v dash > /dev/null 2>&1; then
    echo ""
    echo "=== dash でスクリプト実行 100回 ==="
    time for i in $(seq 1 100); do
        /bin/dash "${WORKDIR}/bench_script.sh" > /dev/null
    done
fi

if command -v bash > /dev/null 2>&1; then
    echo ""
    echo "=== bash でスクリプト実行 100回 ==="
    time for i in $(seq 1 100); do
        /bin/bash "${WORKDIR}/bench_script.sh" > /dev/null
    done
fi

# -------------------------------------------
# セクション6: POSIX準拠スクリプトの作成と実行
# -------------------------------------------
echo ""
echo "--- セクション6: POSIX準拠スクリプトの作成 ---"

cat << 'SCRIPT' > "${WORKDIR}/sysinfo.sh"
#!/bin/sh
set -eu

# システム情報の収集（POSIX準拠）
gather_info() {
    _hostname=$(hostname 2>/dev/null || echo "unknown")
    _kernel=$(uname -r 2>/dev/null || echo "unknown")
    _arch=$(uname -m 2>/dev/null || echo "unknown")
    _uptime=$(cat /proc/uptime 2>/dev/null | cut -d' ' -f1 || echo "unknown")

    echo "Hostname : ${_hostname}"
    echo "Kernel   : ${_kernel}"
    echo "Arch     : ${_arch}"
    echo "Uptime   : ${_uptime}s"
}

# ディスク使用量の表示（POSIX準拠）
show_disk() {
    echo ""
    echo "=== Disk Usage ==="
    df -h / 2>/dev/null | while IFS= read -r line; do
        echo "  $line"
    done
}

# メモリ情報の表示（POSIX準拠）
show_memory() {
    echo ""
    echo "=== Memory ==="
    if [ -f /proc/meminfo ]; then
        _total=$(grep '^MemTotal:' /proc/meminfo | awk '{print $2}')
        _free=$(grep '^MemFree:' /proc/meminfo | awk '{print $2}')
        _avail=$(grep '^MemAvailable:' /proc/meminfo | awk '{print $2}')
        echo "  Total     : $((_total / 1024)) MB"
        echo "  Free      : $((_free / 1024)) MB"
        echo "  Available : $((_avail / 1024)) MB"
    else
        echo "  /proc/meminfo not available"
    fi
}

echo "=== System Information ==="
gather_info
show_disk
show_memory
SCRIPT
chmod +x "${WORKDIR}/sysinfo.sh"
echo "  作成: sysinfo.sh"

echo ""
echo "=== dash で sysinfo.sh を実行 ==="
if command -v dash > /dev/null 2>&1; then
    /bin/dash "${WORKDIR}/sysinfo.sh" 2>&1 || true
else
    /bin/sh "${WORKDIR}/sysinfo.sh" 2>&1 || true
fi

echo ""
echo "=== bash で sysinfo.sh を実行 ==="
if command -v bash > /dev/null 2>&1; then
    /bin/bash "${WORKDIR}/sysinfo.sh" 2>&1 || true
fi

# -------------------------------------------
# セクション7: Dockerイメージサイズ比較
# -------------------------------------------
echo ""
echo "--- セクション7: Dockerイメージサイズ比較 ---"

if command -v docker > /dev/null 2>&1; then
    echo "Dockerイメージを取得中..."
    docker pull -q alpine:3.21 > /dev/null 2>&1 || true
    docker pull -q ubuntu:24.04 > /dev/null 2>&1 || true
    docker pull -q debian:bookworm-slim > /dev/null 2>&1 || true
    docker pull -q busybox:latest > /dev/null 2>&1 || true

    echo ""
    echo "=== イメージサイズ比較 ==="
    docker images --format "  {{.Repository}}:{{.Tag}}\t{{.Size}}" | \
        grep -E '(alpine:3\.21|ubuntu:24\.04|debian:bookworm-slim|busybox:latest)' | \
        sort -k2 -h || true

    echo ""
    echo "=== Alpine Linux で /bin/sh の正体を確認 ==="
    docker run --rm alpine:3.21 ls -la /bin/sh 2>&1 || true
    docker run --rm alpine:3.21 /bin/sh -c 'echo "Shell: $0"' 2>&1 || true
else
    echo "  Docker が未インストールのためスキップ"
    echo "  Docker をインストールして再実行してください"
fi

# -------------------------------------------
# セクション8: まとめ
# -------------------------------------------
echo ""
echo "============================================"
echo " ハンズオン完了"
echo "============================================"
echo ""
echo "作成されたファイル:"
echo "  ${WORKDIR}/bench_script.sh   -- ベンチマーク用POSIX準拠スクリプト"
echo "  ${WORKDIR}/sysinfo.sh        -- システム情報収集POSIX準拠スクリプト"
echo ""
echo "追加演習:"
echo "  1. Alpine コンテナ内で sysinfo.sh を実行する:"
echo "     docker run --rm -v ${WORKDIR}:/work alpine:3.21 /bin/sh /work/sysinfo.sh"
echo ""
echo "  2. bench_script.sh の反復回数を変えて速度差を計測する"
echo ""
echo "  3. Docker Alpine コンテナで bash をインストールし、サイズ変化を確認する:"
echo "     docker run --rm alpine:3.21 /bin/sh -c '"
echo "       echo \"Before: \$(du -sh /bin/sh)\"; "
echo "       apk add --no-cache bash > /dev/null 2>&1; "
echo "       echo \"bash: \$(du -sh /usr/bin/bash)\"'"
