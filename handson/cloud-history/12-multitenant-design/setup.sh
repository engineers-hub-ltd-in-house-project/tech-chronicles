#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-12"

echo "============================================"
echo " クラウドの考古学 第12回 ハンズオン"
echo " マルチテナント設計"
echo " cgroupsとnamespaceで簡易マルチテナント環境を構築する"
echo "============================================"
echo ""

# -----------------------------------------------
echo ">>> 環境セットアップ"
# -----------------------------------------------
apt-get update -qq && apt-get install -y -qq util-linux cgroup-tools stress-ng procps iproute2 > /dev/null 2>&1
echo "必要なパッケージをインストールしました"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# -----------------------------------------------
echo ">>> 演習1: namespacesによるプロセス隔離"
# -----------------------------------------------
echo "新しいPID名前空間でプロセス一覧を確認します..."
unshare --pid --mount --fork bash -c '
  mount -t proc proc /proc
  echo "PID名前空間内のプロセス:"
  ps aux
  echo ""
  echo "シェルのPIDは1になっている。この名前空間ではinitプロセスだ。"
  echo "ホスト側のプロセスは一切見えない。これがプロセス隔離の本質。"
'
echo ""

# -----------------------------------------------
echo ">>> 演習2: cgroupsによるリソース制限"
# -----------------------------------------------
echo "テナントA/B用のcgroupを作成します..."

# cgroups v2の確認
if mount | grep -q cgroup2; then
  echo "cgroups v2が有効です"
else
  echo "ERROR: cgroups v2が有効ではありません。このハンズオンはcgroups v2が必要です。"
  exit 1
fi

mkdir -p /sys/fs/cgroup/tenant-a
mkdir -p /sys/fs/cgroup/tenant-b

# テナントA: CPU 50%, メモリ 128MB
echo "50000 100000" > /sys/fs/cgroup/tenant-a/cpu.max
echo $((128 * 1024 * 1024)) > /sys/fs/cgroup/tenant-a/memory.max

# テナントB: CPU 50%, メモリ 256MB
echo "50000 100000" > /sys/fs/cgroup/tenant-b/cpu.max
echo $((256 * 1024 * 1024)) > /sys/fs/cgroup/tenant-b/memory.max

echo "テナントA: CPU 50%, メモリ 128MB"
echo "テナントB: CPU 50%, メモリ 256MB"
echo ""

# -----------------------------------------------
echo ">>> 演習3: Noisy Neighborの再現"
# -----------------------------------------------
echo "テナントAとテナントBで同時にCPU負荷をかけます..."

cgexec -g cpu,memory:tenant-a stress-ng --cpu 2 --timeout 15s &
TENANT_A_PID=$!
sleep 2
cgexec -g cpu,memory:tenant-b stress-ng --cpu 2 --timeout 13s &
TENANT_B_PID=$!

for i in 1 2 3; do
  sleep 4
  echo "--- 計測 ${i} ---"
  echo "テナントA CPU統計:"
  cat /sys/fs/cgroup/tenant-a/cpu.stat | head -3
  echo "テナントB CPU統計:"
  cat /sys/fs/cgroup/tenant-b/cpu.stat | head -3
  echo ""
done

wait $TENANT_A_PID 2>/dev/null || true
wait $TENANT_B_PID 2>/dev/null || true
echo "cgroupsのcpu.maxにより、各テナントはCPU 50%に制限されている。"
echo "制限がなければ先行テナントがCPUを占有し、後発テナントが影響を受ける。"
echo ""

# -----------------------------------------------
echo ">>> 演習4: メモリ制限とOOMキラー"
# -----------------------------------------------
echo "テナントA（128MB制限）で200MBのメモリ確保を試みます..."

cgexec -g memory:tenant-a stress-ng --vm 1 --vm-bytes 200M --timeout 5s 2>&1 &
sleep 6
wait 2>/dev/null || true

echo "テナントAのOOMイベント:"
cat /sys/fs/cgroup/tenant-a/memory.events
echo ""
echo "テナントBのOOMイベント:"
cat /sys/fs/cgroup/tenant-b/memory.events
echo ""
echo "テナントAのOOMキラーが発動しても、テナントBには影響しない。"
echo ""

# -----------------------------------------------
echo ">>> 演習5: ネットワーク名前空間によるテナント分離"
# -----------------------------------------------
echo "テナントA/B用のネットワーク名前空間を作成します..."

ip netns add tenant-a-ns
ip netns add tenant-b-ns

# テナントA用vethペア
ip link add veth-a-host type veth peer name veth-a-tenant
ip link set veth-a-tenant netns tenant-a-ns
ip addr add 10.100.1.1/24 dev veth-a-host
ip link set veth-a-host up
ip netns exec tenant-a-ns ip addr add 10.100.1.2/24 dev veth-a-tenant
ip netns exec tenant-a-ns ip link set veth-a-tenant up
ip netns exec tenant-a-ns ip link set lo up

# テナントB用vethペア
ip link add veth-b-host type veth peer name veth-b-tenant
ip link set veth-b-tenant netns tenant-b-ns
ip addr add 10.100.2.1/24 dev veth-b-host
ip link set veth-b-host up
ip netns exec tenant-b-ns ip addr add 10.100.2.2/24 dev veth-b-tenant
ip netns exec tenant-b-ns ip link set veth-b-tenant up
ip netns exec tenant-b-ns ip link set lo up

echo "テナントA → テナントB への直接通信を試行:"
ip netns exec tenant-a-ns ping -c 2 -W 1 10.100.2.2 2>/dev/null || echo "到達不可（期待通り）"
echo ""
echo "ネットワーク名前空間により、テナント間は完全に隔離されている。"
echo ""

# クリーンアップ
ip netns del tenant-a-ns
ip netns del tenant-b-ns
ip link del veth-a-host 2>/dev/null || true
ip link del veth-b-host 2>/dev/null || true

# -----------------------------------------------
echo ">>> クリーンアップ"
# -----------------------------------------------
rmdir /sys/fs/cgroup/tenant-a 2>/dev/null || true
rmdir /sys/fs/cgroup/tenant-b 2>/dev/null || true

echo ""
echo "============================================"
echo " 全演習完了"
echo ""
echo " 学んだこと:"
echo "  - PID名前空間によるプロセス隔離"
echo "  - cgroupsのcpu.maxとmemory.maxによるリソース制限"
echo "  - Noisy Neighbor問題の再現と緩和"
echo "  - OOMキラーによるテナント間メモリ保護"
echo "  - ネットワーク名前空間によるテナント間通信の遮断"
echo ""
echo " これらはクラウドのマルチテナンシーの基盤技術である。"
echo "============================================"
