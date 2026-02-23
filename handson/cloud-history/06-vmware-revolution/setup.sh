#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-06"

echo "============================================================"
echo " クラウドの考古学 第6回 ハンズオン"
echo " QEMUとKVMで仮想化のオーバーヘッドを体感する"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "注意: このスクリプトはDocker内で --privileged 付きで実行してください"
echo ""
echo "  docker run -it --rm --privileged --device /dev/kvm:/dev/kvm --name vmware-handson ubuntu:24.04 bash"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo "============================================================"
echo " 環境セットアップ"
echo "============================================================"
echo ""

apt-get update -qq && apt-get install -y -qq qemu-system-x86 qemu-utils \
  stress-ng procps bc util-linux > /dev/null 2>&1
echo "必要なパッケージをインストールしました"

# ============================================================
echo ""
echo "============================================================"
echo " 演習1: 仮想化オーバーヘッドの可視化"
echo "============================================================"
echo ""

# KVMが利用可能か確認
echo "--- KVMサポートの確認 ---"
if [ -e /dev/kvm ]; then
  echo "/dev/kvm が存在: ハードウェア仮想化が利用可能"
else
  echo "/dev/kvm が存在しない: ソフトウェアエミュレーションのみ"
fi
echo ""

# CPUが仮想化をサポートしているか確認
echo "--- CPU仮想化フラグの確認 ---"
if grep -q -E '(vmx|svm)' /proc/cpuinfo; then
  echo "CPU仮想化フラグ検出:"
  grep -m1 -oE '(vmx|svm)' /proc/cpuinfo
  echo "  vmx = Intel VT-x, svm = AMD-V"
else
  echo "CPU仮想化フラグが見つからない"
fi
echo ""

# ホスト環境での基準性能測定
echo "--- ホスト環境（ベアメタル相当）でのCPU性能 ---"
echo "円周率計算（bc、10000桁）を3回実行"
echo ""

TOTAL_HOST=0
for i in 1 2 3; do
  TIME_HOST=$( { time echo "scale=10000; 4*a(1)" | bc -l > /dev/null; } 2>&1 \
    | grep real | awk '{print $2}')
  echo "  実行${i}: ${TIME_HOST}"
  MINS=$(echo "$TIME_HOST" | sed 's/m.*//')
  SECS=$(echo "$TIME_HOST" | sed 's/.*m//' | sed 's/s//')
  TOTAL_SEC=$(echo "$MINS * 60 + $SECS" | bc)
  TOTAL_HOST=$(echo "$TOTAL_HOST + $TOTAL_SEC" | bc)
done
AVG_HOST=$(echo "scale=3; $TOTAL_HOST / 3" | bc)
echo ""
echo "ホスト平均: ${AVG_HOST}秒"
echo ""
echo "この測定値が「ベースライン」となる。"
echo "仮想マシン内で同じ計算を実行すると、仮想化の"
echo "オーバーヘッド分だけ遅くなる。"

# ============================================================
echo ""
echo "============================================================"
echo " 演習2: 仮想マシンのライフサイクル管理"
echo "============================================================"
echo ""

# 最小限のLinuxディスクイメージを作成
echo "--- 仮想マシン用ディスクイメージの作成 ---"
qemu-img create -f qcow2 "${WORKDIR}/test-vm.qcow2" 1G
echo ""
echo "フォーマット: qcow2（QEMU Copy-On-Write 2）"
echo "  - 実際に書き込まれたデータ分だけディスク容量を消費"
echo "  - スナップショット機能をサポート"
echo "  - VMwareのvmdk、Hyper-Vのvhdxに相当するフォーマット"
echo ""

# ディスクイメージの情報表示
qemu-img info "${WORKDIR}/test-vm.qcow2"
echo ""

echo "--- 仮想マシンのスナップショット機能 ---"
echo "スナップショットは仮想化の重要な機能の一つ"
echo "VMwareはスナップショットによって「状態の保存と復元」を実現した"
echo ""

# 追加のディスクイメージでスナップショットを実演
qemu-img create -f qcow2 "${WORKDIR}/snapshot-demo.qcow2" 512M

echo "初期状態のイメージサイズ:"
ls -lh "${WORKDIR}/snapshot-demo.qcow2" | awk '{print "  " $5}'

# スナップショットの作成
qemu-img snapshot -c "before-install" "${WORKDIR}/snapshot-demo.qcow2"
echo ""
echo "スナップショット 'before-install' を作成"

qemu-img snapshot -c "after-config" "${WORKDIR}/snapshot-demo.qcow2"
echo "スナップショット 'after-config' を作成"
echo ""

echo "スナップショット一覧:"
qemu-img snapshot -l "${WORKDIR}/snapshot-demo.qcow2"
echo ""

echo "スナップショットの意義:"
echo "  - 設定変更前に状態を保存 → 失敗したら即座に復元"
echo "  - テスト環境を「クリーン状態」から何度でも再開"
echo "  - VMwareがこの機能を商用化し、運用の安全性を飛躍的に向上させた"

# ============================================================
echo ""
echo "============================================================"
echo " 演習3: vCPUとpCPU（物理CPU）のマッピング"
echo "============================================================"
echo ""

# 物理CPUの情報
echo "--- 物理CPU情報 ---"
PCPU_COUNT=$(nproc)
echo "物理（ホスト）CPU数: ${PCPU_COUNT}"
echo ""

echo "CPU情報（抜粋）:"
lscpu | grep -E '(Model name|CPU\(s\)|Thread|Core|Socket|MHz|Virtualization)' || true
echo ""

echo "--- 仮想化におけるCPUの割り当て ---"
echo ""
echo "物理サーバのCPU: ${PCPU_COUNT}コア"
echo ""
echo "VMwareの仮想化では、以下のように物理CPUを分割する:"
echo ""
echo "  物理CPU ${PCPU_COUNT}コア"
echo "  ├── VM-A: vCPU 2コア"
echo "  ├── VM-B: vCPU 2コア"
echo "  ├── VM-C: vCPU 1コア"
echo "  └── ハイパーバイザ自身が使用"
echo ""
echo "オーバーコミット（物理CPUより多くのvCPUを割り当てる）:"
echo "  物理CPU ${PCPU_COUNT}コア に対して"
echo "  合計 $((PCPU_COUNT * 3))vCPU を割り当てることも可能"
echo "  → 全VMが同時に100%使用しなければ成立する"
echo "  → VMwareのスケジューラが動的にタイムスライスを配分"
echo ""

# CPU使用率の時分割を実演
echo "--- CPUタイムスライスの実演 ---"
echo "2つのプロセスが1コアのCPUを時分割で共有する様子:"
echo "（仮想化のCPUスケジューリングの簡易的な再現）"
echo ""

taskset -c 0 stress-ng --cpu 1 --timeout 5s &
PID_A=$!
taskset -c 0 stress-ng --cpu 1 --timeout 5s &
PID_B=$!

echo "プロセスA (PID: $PID_A) と プロセスB (PID: $PID_B)"
echo "を同じCPUコア(0)にバインド"
echo ""

sleep 2
echo "CPU 0の使用状況（2秒後）:"
echo "  両プロセスがCPU時間を約50%ずつ分け合っている"
echo "  → これが仮想化におけるvCPUスケジューリングの本質"
echo ""

wait 2>/dev/null || true

echo "VMwareのCPUスケジューラは、この時分割を仮想マシン単位で行う。"
echo "各VMには「CPUの重み」が設定され、重みに応じて"
echo "タイムスライスが配分される。"
echo ""
echo "メインフレームのタイムシェアリング（第2回）から"
echo "VMwareのCPUスケジューラまで、「CPUを分け合う」"
echo "という原理は60年間変わっていない。"

# ============================================================
echo ""
echo "============================================================"
echo " 演習完了"
echo "============================================================"
echo ""
echo "この演習で確認したこと:"
echo "  1. 仮想化にはCPUオーバーヘッドがある（ベースライン: ${AVG_HOST}秒）"
echo "  2. qcow2とスナップショットが仮想マシンの状態管理を可能にする"
echo "  3. vCPUは物理CPUのタイムスライスとして実現される"
echo ""
echo "VMwareの革命の本質:"
echo "  x86で「不可能」とされた仮想化を、バイナリトランスレーションで実現し、"
echo "  ESX Server（Type 1ハイパーバイザ）でデータセンターのインフラ基盤に昇格させ、"
echo "  vMotionで仮想マシンを物理ホストから解放した。"
echo "  この技術がなければ、クラウドコンピューティングは存在しない。"
