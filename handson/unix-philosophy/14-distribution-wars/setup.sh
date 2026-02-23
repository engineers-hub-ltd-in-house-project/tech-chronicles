#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-14"

echo "============================================"
echo " UNIXという思想 第14回 ハンズオン"
echo " ディストリビューション戦争"
echo "============================================"
echo ""

# -----------------------------------------------
echo "[1/6] 作業ディレクトリの作成"
# -----------------------------------------------
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"
echo "  作業ディレクトリ: ${WORKDIR}"

# -----------------------------------------------
echo ""
echo "[2/6] Dockerイメージの取得"
# -----------------------------------------------
echo "  Alpine Linux 3.21..."
docker pull alpine:3.21
echo "  Debian Bookworm (slim)..."
docker pull debian:bookworm-slim
echo "  Fedora 41..."
docker pull fedora:41
echo "  Arch Linux (latest)..."
docker pull archlinux:latest

# -----------------------------------------------
echo ""
echo "[3/6] 演習1: システムの基本情報を比較する"
# -----------------------------------------------
echo ""
echo "--- Alpine Linux ---"
docker run --rm alpine:3.21 sh -c '
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
echo "カーネル: $(uname -r)"
echo "シェル: $(ls -la /bin/sh | awk "{print \$NF}")"
echo "ls の実体: $(ls -la /bin/ls | awk "{print \$NF}")"
echo "Cライブラリ: musl"
'

echo ""
echo "--- Debian ---"
docker run --rm debian:bookworm-slim sh -c '
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d\" -f2)"
echo "カーネル: $(uname -r)"
echo "シェル: $(ls -la /bin/sh | awk "{print \$NF}")"
echo "ls の実体: $(ls -la /bin/ls | awk "{print \$NF}")"
echo "Cライブラリ: $(ldd --version 2>&1 | head -1)"
'

echo ""
echo "--- Fedora ---"
docker run --rm fedora:41 sh -c '
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d\" -f2)"
echo "カーネル: $(uname -r)"
echo "シェル: $(ls -la /bin/sh | awk "{print \$NF}")"
echo "ls の実体: $(file /bin/ls | head -1)"
echo "Cライブラリ: $(ldd --version 2>&1 | head -1)"
'

# -----------------------------------------------
echo ""
echo "[4/6] 演習2: curlのインストールを比較する"
# -----------------------------------------------
echo ""
echo "--- Alpine: apk ---"
docker run --rm alpine:3.21 sh -c '
apk update > /dev/null 2>&1
apk add curl > /dev/null 2>&1
echo "インストール完了"
echo "パッケージ数: $(apk list --installed 2>/dev/null | wc -l)"
curl --version | head -1
'

echo ""
echo "--- Debian: apt ---"
docker run --rm debian:bookworm-slim sh -c '
apt-get update > /dev/null 2>&1
apt-get install -y curl > /dev/null 2>&1
echo "インストール完了"
echo "パッケージ数: $(dpkg -l | grep "^ii" | wc -l)"
curl --version | head -1
'

echo ""
echo "--- Fedora: dnf ---"
docker run --rm fedora:41 sh -c '
dnf install -y curl > /dev/null 2>&1
echo "インストール完了"
echo "パッケージ数: $(rpm -qa | wc -l)"
curl --version | head -1
'

# -----------------------------------------------
echo ""
echo "[5/6] 演習3: パッケージの依存関係を確認する"
# -----------------------------------------------
echo ""
echo "--- Alpine: curlの依存関係 ---"
docker run --rm alpine:3.21 sh -c '
apk update > /dev/null 2>&1
apk info -R curl 2>/dev/null
'

echo ""
echo "--- Debian: curlの依存関係 ---"
docker run --rm debian:bookworm-slim sh -c '
apt-get update > /dev/null 2>&1
apt-cache depends curl 2>/dev/null | head -15
'

# -----------------------------------------------
echo ""
echo "[6/6] 演習5: イメージサイズの比較"
# -----------------------------------------------
echo ""
echo "=== ディストリビューション別イメージサイズ ==="
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | \
  grep -E "alpine|debian|fedora|archlinux" | sort

echo ""
echo "============================================"
echo " ハンズオン完了"
echo " 作業ディレクトリ: ${WORKDIR}"
echo "============================================"
