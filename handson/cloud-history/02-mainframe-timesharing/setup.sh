#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-02"

echo "============================================================"
echo " クラウドの考古学 第2回 ハンズオン"
echo " タイムシェアリングの原理を体感する"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo "============================================================"
echo " 演習1: カーネルのスケジューラ設定を確認する"
echo "============================================================"
echo ""

echo "--- Linuxカーネルのスケジューリングパラメータ ---"
echo ""

if [ -f /proc/sys/kernel/sched_min_granularity_ns ]; then
  GRAN=$(cat /proc/sys/kernel/sched_min_granularity_ns)
  echo "sched_min_granularity_ns: ${GRAN} ($(( GRAN / 1000000 )) ミリ秒)"
  echo "  → 各プロセスに割り当てられる最小CPUタイムスライス"
else
  echo "sched_min_granularity_ns: 読み取り不可（コンテナ設定を確認）"
fi

if [ -f /proc/sys/kernel/sched_latency_ns ]; then
  LAT=$(cat /proc/sys/kernel/sched_latency_ns)
  echo "sched_latency_ns: ${LAT} ($(( LAT / 1000000 )) ミリ秒)"
  echo "  → 全プロセスが1回ずつ実行される最大周期"
else
  echo "sched_latency_ns: 読み取り不可（コンテナ設定を確認）"
fi

echo ""
echo "1960年代のCTSSでは約200ミリ秒のタイムスライスが使われていた。"
echo "現代のLinuxでは数ミリ秒単位にまで細かくなっている。"

# ============================================================
echo ""
echo "============================================================"
echo " 演習2: 複数プロセスのCPU時間分配を観察する"
echo "============================================================"
echo ""

echo "1つのCPUコアで3つのプロセスを同時実行し、CPU時間の分配を観察する..."
echo ""

taskset -c 0 stress-ng --cpu 1 --timeout 10s &
PID1=$!
taskset -c 0 stress-ng --cpu 1 --timeout 10s &
PID2=$!
taskset -c 0 stress-ng --cpu 1 --timeout 10s &
PID3=$!

echo "起動したプロセス: PID1=${PID1}, PID2=${PID2}, PID3=${PID3}"
echo "5秒後にCPU時間の分配を確認する..."
sleep 5

echo ""
echo "--- 各プロセスのCPU使用時間（clock ticks）---"
for PID in ${PID1} ${PID2} ${PID3}; do
  if [ -d "/proc/${PID}" ]; then
    UTIME=$(awk '{print $14}' "/proc/${PID}/stat")
    STIME=$(awk '{print $15}' "/proc/${PID}/stat")
    TOTAL=$((UTIME + STIME))
    echo "  PID ${PID}: user=${UTIME}, system=${STIME}, total=${TOTAL}"
  fi
done

echo ""
echo "3つのプロセスのCPU時間がほぼ均等に分配されていることを確認してほしい。"
echo "これがCFS（Completely Fair Scheduler）の効果であり、"
echo "1960年代のタイムシェアリングが目指した「公平な分配」の現代版だ。"

kill ${PID1} ${PID2} ${PID3} 2>/dev/null || true
wait 2>/dev/null || true

# ============================================================
echo ""
echo "============================================================"
echo " 演習3: Noisy Neighbor 問題を再現する"
echo "============================================================"
echo ""

echo "--- ベースライン（CPU独占）---"
BASELINE_START=$(date +%s%N)
taskset -c 0 bash -c '
for i in $(seq 1 500000); do
  : # 何もしないループ
done
'
BASELINE_END=$(date +%s%N)
BASELINE_MS=$(( (BASELINE_END - BASELINE_START) / 1000000 ))
echo "所要時間: ${BASELINE_MS} ミリ秒"

echo ""
echo "--- Noisy Neighbor あり（3プロセスとCPU共有）---"
taskset -c 0 stress-ng --cpu 1 --timeout 30s &
NP1=$!
taskset -c 0 stress-ng --cpu 1 --timeout 30s &
NP2=$!
taskset -c 0 stress-ng --cpu 1 --timeout 30s &
NP3=$!

sleep 2

NOISY_START=$(date +%s%N)
taskset -c 0 bash -c '
for i in $(seq 1 500000); do
  : # 何もしないループ
done
'
NOISY_END=$(date +%s%N)
NOISY_MS=$(( (NOISY_END - NOISY_START) / 1000000 ))
echo "所要時間: ${NOISY_MS} ミリ秒"

echo ""
if [ "${BASELINE_MS}" -gt 0 ]; then
  RATIO=$(( NOISY_MS * 100 / BASELINE_MS ))
  echo "パフォーマンス低下: 約 ${RATIO}%（ベースライン比）"
fi
echo ""
echo "CPUを4プロセスで共有しているため、理論的には約4倍の時間がかかる。"
echo "これは1960年代のタイムシェアリングでユーザー数が増えると"
echo "レスポンスが悪化した問題と同じ構造だ。"

kill ${NP1} ${NP2} ${NP3} 2>/dev/null || true
wait 2>/dev/null || true

# ============================================================
echo ""
echo "============================================================"
echo " 演習4: コンテキストスイッチを計測する"
echo "============================================================"
echo ""

echo "--- 低負荷時のコンテキストスイッチ ---"
CS1=$(awk '/ctxt/ {print $2}' /proc/stat)
sleep 1
CS2=$(awk '/ctxt/ {print $2}' /proc/stat)
CS_LOW=$((CS2 - CS1))
echo "1秒間のコンテキストスイッチ: ${CS_LOW} 回"

echo ""
echo "--- 高負荷時のコンテキストスイッチ ---"
for i in $(seq 1 10); do
  taskset -c 0 stress-ng --cpu 1 --timeout 10s &
done

sleep 2
CS3=$(awk '/ctxt/ {print $2}' /proc/stat)
sleep 1
CS4=$(awk '/ctxt/ {print $2}' /proc/stat)
CS_HIGH=$((CS4 - CS3))
echo "1秒間のコンテキストスイッチ: ${CS_HIGH} 回"

echo ""
if [ "${CS_LOW}" -gt 0 ]; then
  CS_RATIO=$(( CS_HIGH * 100 / CS_LOW ))
  echo "コンテキストスイッチ増加率: 約 ${CS_RATIO}%（低負荷時比）"
fi
echo ""
echo "プロセス数が増えるとコンテキストスイッチの回数も増え、"
echo "各切り替えに数マイクロ秒のオーバーヘッドがかかる。"
echo "1960年代のCTSSでも、ユーザー数の増加に伴い"
echo "このオーバーヘッドが顕在化した。"

pkill stress-ng 2>/dev/null || true
wait 2>/dev/null || true

# ============================================================
echo ""
echo "============================================================"
echo " ハンズオン完了"
echo "============================================================"
echo ""
echo "このハンズオンで体感したこと："
echo ""
echo "1. タイムシェアリングの原理は現代のLinuxカーネルにそのまま生きている"
echo "2. CPU共有にはNoisy Neighbor問題という構造的なコストがある"
echo "3. コンテキストスイッチはタイムシェアリングの「見えないコスト」である"
echo "4. これらの問題構造は1960年代から60年間変わっていない"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
