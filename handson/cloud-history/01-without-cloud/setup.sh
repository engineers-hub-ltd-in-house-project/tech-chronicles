#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-01"

echo "============================================"
echo " 第1回ハンズオン：クラウドなしでサーバを立てられるか"
echo " QEMUで仮想マシンを手動構築する"
echo "============================================"
echo ""

# -------------------------------------------
# セクション1：作業ディレクトリの準備
# -------------------------------------------
echo "[1/5] 作業ディレクトリを作成..."
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"
echo "  -> ${WORKDIR}"

# -------------------------------------------
# セクション2：必要なパッケージのインストール
# -------------------------------------------
echo ""
echo "[2/5] 必要なパッケージをインストール..."
apt-get update -qq
apt-get install -y -qq qemu-system-x86 qemu-utils wget bridge-utils iproute2 > /dev/null 2>&1
echo "  -> qemu-system-x86, qemu-utils, wget, bridge-utils, iproute2"

# -------------------------------------------
# セクション3：仮想ディスクの作成
# -------------------------------------------
echo ""
echo "[3/5] 仮想ディスクを作成..."
qemu-img create -f qcow2 "${WORKDIR}/disk.qcow2" 2G
echo "  -> ${WORKDIR}/disk.qcow2 (qcow2形式, 2GB)"
echo ""
echo "  補足: qcow2はQEMU Copy On Write形式。"
echo "  実際のディスク使用量は書き込んだデータ分だけ。"
echo "  EC2のEBSボリュームも、内部的にはシンプロビジョニングで"
echo "  同様のcopy-on-write戦略を採用している。"

# -------------------------------------------
# セクション4：Alpine Linux ISOのダウンロード
# -------------------------------------------
echo ""
echo "[4/5] Alpine Linux ISOをダウンロード..."
ALPINE_ISO="alpine-virt-3.21.3-x86_64.iso"
ALPINE_URL="https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/${ALPINE_ISO}"

if [ ! -f "${WORKDIR}/${ALPINE_ISO}" ]; then
    wget -q --show-progress -O "${WORKDIR}/${ALPINE_ISO}" "${ALPINE_URL}"
else
    echo "  -> 既にダウンロード済み: ${ALPINE_ISO}"
fi
echo "  -> ${WORKDIR}/${ALPINE_ISO}"

# -------------------------------------------
# セクション5：演習の準備完了
# -------------------------------------------
echo ""
echo "============================================"
echo " セットアップ完了"
echo "============================================"
echo ""
echo "以下の演習を実行できます："
echo ""
echo "--- 演習1：仮想マシンの起動 ---"
echo ""
echo "  qemu-system-x86_64 \\"
echo "    -m 512 \\"
echo "    -smp 1 \\"
echo "    -hda ${WORKDIR}/disk.qcow2 \\"
echo "    -cdrom ${WORKDIR}/${ALPINE_ISO} \\"
echo "    -boot d \\"
echo "    -nographic \\"
echo "    -serial mon:stdio"
echo ""
echo "  起動後、rootでログイン（パスワードなし）"
echo "  終了するには: Ctrl+A, X"
echo ""
echo "--- 演習2：リソース変更（メモリ1024MB, CPU 2コア）---"
echo ""
echo "  qemu-system-x86_64 \\"
echo "    -m 1024 \\"
echo "    -smp 2 \\"
echo "    -hda ${WORKDIR}/disk.qcow2 \\"
echo "    -boot c \\"
echo "    -nographic \\"
echo "    -serial mon:stdio"
echo ""
echo "--- 演習3：仮想ネットワークの構築 ---"
echo ""
echo "  # ブリッジとTAPデバイスの作成"
echo "  ip link add br0 type bridge"
echo "  ip addr add 192.168.100.1/24 dev br0"
echo "  ip link set br0 up"
echo "  ip tuntap add tap0 mode tap"
echo "  ip link set tap0 master br0"
echo "  ip link set tap0 up"
echo ""
echo "  # 仮想NICを接続して起動"
echo "  qemu-system-x86_64 \\"
echo "    -m 512 \\"
echo "    -smp 1 \\"
echo "    -hda ${WORKDIR}/disk.qcow2 \\"
echo "    -boot c \\"
echo "    -nographic \\"
echo "    -serial mon:stdio \\"
echo "    -netdev tap,id=net0,ifname=tap0,script=no,downscript=no \\"
echo "    -device virtio-net-pci,netdev=net0"
echo ""
echo "============================================"
