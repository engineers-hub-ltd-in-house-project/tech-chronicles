#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-05"

echo "============================================================"
echo " クラウドの考古学 第5回 ハンズオン"
echo " cgroupsでVPSのリソース制限を体感する"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "注意: このスクリプトはDocker内で --privileged 付きで実行してください"
echo ""
echo "  docker run -it --rm --privileged --name vps-handson ubuntu:24.04 bash"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo "============================================================"
echo " 環境セットアップ"
echo "============================================================"
echo ""

apt-get update -qq && apt-get install -y -qq cgroup-tools stress-ng procps bc python3 > /dev/null 2>&1
echo "必要なパッケージをインストールしました"

# cgroup v2の確認
if mount | grep -q cgroup2; then
    echo "cgroup v2が有効です"
else
    echo "警告: cgroup v2が検出されません。演習が正しく動作しない可能性があります"
fi

# ============================================================
echo ""
echo "============================================================"
echo " 演習1: cgroupsによるCPU制限 — リソースの切り売り"
echo "============================================================"
echo ""
echo "VPS事業者は1台の物理サーバのCPUリソースをcgroupsで分配する。"
echo "ここでは2つのテナント（VPS-AとVPS-B）を作成し、CPU重みを設定する。"
echo ""

# テナント用のcgroupを作成
mkdir -p /sys/fs/cgroup/vps-a
mkdir -p /sys/fs/cgroup/vps-b

# CPU重みの設定
echo 100 > /sys/fs/cgroup/vps-a/cpu.weight
echo 50 > /sys/fs/cgroup/vps-b/cpu.weight

echo "VPS-A cpu.weight: $(cat /sys/fs/cgroup/vps-a/cpu.weight) (標準)"
echo "VPS-B cpu.weight: $(cat /sys/fs/cgroup/vps-b/cpu.weight) (VPS-Aの半分)"
echo ""
echo "→ VPS-AはVPS-Bの2倍のCPU時間を受け取る"
echo ""

echo "--- CPU負荷テスト開始（10秒間）---"
echo ""

# VPS-AでCPU負荷を発生
stress-ng --cpu 1 --timeout 10s --metrics-brief 2>/dev/null &
VPS_A_PID=$!
echo $VPS_A_PID > /sys/fs/cgroup/vps-a/cgroup.procs

# VPS-BでCPU負荷を発生
stress-ng --cpu 1 --timeout 10s --metrics-brief 2>/dev/null &
VPS_B_PID=$!
echo $VPS_B_PID > /sys/fs/cgroup/vps-b/cgroup.procs

echo "VPS-A (PID: $VPS_A_PID) → cpu.weight=100"
echo "VPS-B (PID: $VPS_B_PID) → cpu.weight=50"
echo ""

sleep 5
echo "--- 5秒後のCPU統計 ---"
echo "VPS-A:"
cat /sys/fs/cgroup/vps-a/cpu.stat | head -3 | sed 's/^/  /'
echo "VPS-B:"
cat /sys/fs/cgroup/vps-b/cpu.stat | head -3 | sed 's/^/  /'

wait 2>/dev/null
echo ""
echo "演習1完了"

# ============================================================
echo ""
echo "============================================================"
echo " 演習2: メモリ制限 — 契約プランのリソース上限"
echo "============================================================"
echo ""
echo "VPSの「メモリ2GBプラン」の実体は、cgroupsのmemory.maxパラメータ。"
echo "ここでは64MBに制限し、超過時の挙動を確認する。"
echo ""

# メモリ制限を設定
echo $((64 * 1024 * 1024)) > /sys/fs/cgroup/vps-a/memory.max

echo "VPS-A memory.max: $(cat /sys/fs/cgroup/vps-a/memory.max) bytes (64MB)"
echo ""

# 制限内でのメモリ確保
echo "--- テスト1: 制限内(32MB)のメモリ確保 ---"
bash -c '
  echo $$ > /sys/fs/cgroup/vps-a/cgroup.procs
  python3 -c "
data = bytearray(32 * 1024 * 1024)
print(\"  32MB確保成功: メモリ制限(64MB)内\")
"
'

echo ""
echo "--- テスト2: 制限超過(128MB)のメモリ確保 ---"
bash -c '
  echo $$ > /sys/fs/cgroup/vps-a/cgroup.procs
  python3 -c "
try:
    data = bytearray(128 * 1024 * 1024)
    print(\"  128MB確保成功（想定外）\")
except MemoryError:
    print(\"  MemoryError: メモリ制限(64MB)を超過。確保に失敗\")
    print(\"  → これがVPSのメモリプラン制限の実体\")
" 2>/dev/null
' 2>/dev/null

echo ""
echo "演習2完了"

# ============================================================
echo ""
echo "============================================================"
echo " 演習3: Noisy Neighbor問題の再現と緩和"
echo "============================================================"
echo ""
echo "共有ホスティングでリソース制限が不十分な場合に何が起きるか。"
echo "cgroupsによる制限の有無で、隣人の暴走が及ぼす影響を比較する。"
echo ""

# 基準性能の測定
echo "--- 基準測定: 単独実行 ---"
TIME_ALONE=$(bash -c '
  start=$(date +%s%N)
  for i in $(seq 1 100); do echo "scale=10; a(1)*4" | bc -l > /dev/null 2>&1; done
  end=$(date +%s%N)
  echo $(( (end - start) / 1000000 ))
')
echo "  単独実行時間: ${TIME_ALONE}ms"
echo ""

# Noisy Neighbor（制限なし）
echo "--- Noisy Neighbor: 制限なし（共有ホスティング相当）---"
stress-ng --cpu 2 --timeout 15s 2>/dev/null &
NOISY_PID=$!
sleep 2

TIME_NOISY=$(bash -c '
  start=$(date +%s%N)
  for i in $(seq 1 100); do echo "scale=10; a(1)*4" | bc -l > /dev/null 2>&1; done
  end=$(date +%s%N)
  echo $(( (end - start) / 1000000 ))
')
echo "  Noisy Neighbor存在時: ${TIME_NOISY}ms"
kill $NOISY_PID 2>/dev/null
wait $NOISY_PID 2>/dev/null

echo ""

# Noisy Neighbor（cgroup制限あり）
echo "--- Noisy Neighbor: cgroup制限あり（VPS相当）---"
mkdir -p /sys/fs/cgroup/noisy-tenant
echo 20 > /sys/fs/cgroup/noisy-tenant/cpu.weight

stress-ng --cpu 2 --timeout 15s 2>/dev/null &
NOISY_PID2=$!
echo $NOISY_PID2 > /sys/fs/cgroup/noisy-tenant/cgroup.procs
sleep 2

TIME_ISOLATED=$(bash -c '
  start=$(date +%s%N)
  for i in $(seq 1 100); do echo "scale=10; a(1)*4" | bc -l > /dev/null 2>&1; done
  end=$(date +%s%N)
  echo $(( (end - start) / 1000000 ))
')
echo "  cgroup制限下: ${TIME_ISOLATED}ms"
kill $NOISY_PID2 2>/dev/null
wait $NOISY_PID2 2>/dev/null

echo ""
echo "=== 結果比較 ==="
echo "  単独実行:           ${TIME_ALONE}ms"
echo "  Noisy Neighbor:     ${TIME_NOISY}ms (制限なし=共有ホスティング相当)"
echo "  cgroup制限あり:     ${TIME_ISOLATED}ms (VPS相当)"
echo ""
echo "→ cgroupsによるリソース制限がNoisy Neighbor問題を緩和する"
echo "  これがVPSが共有ホスティングより信頼性が高い技術的理由"
echo ""
echo "演習3完了"

# ============================================================
echo ""
echo "============================================================"
echo " 全演習完了"
echo "============================================================"
echo ""
echo "このハンズオンで体感したこと:"
echo ""
echo "  1. cgroupsはリソースの「切り売り」の技術的基盤"
echo "     VPS事業者はcgroupsのパラメータでプランの差異を実現する"
echo ""
echo "  2. メモリ制限はハード制限として機能する"
echo "     プラン上限を超えるとOOM Killer/MemoryErrorが発生する"
echo ""
echo "  3. リソース隔離がNoisy Neighbor問題を緩和する"
echo "     共有ホスティング→VPS→専用サーバの隔離レベルの違いの本質"
echo ""
echo "次回（第6回）では、VMwareの仮想化技術を探る。"
echo "「1台の物理マシンで複数のOSを動かす」という革命が"
echo "クラウドコンピューティングの直接的な基盤となった過程を追う。"
