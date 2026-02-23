#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-07"

echo "============================================================"
echo " クラウドの考古学 第7回 ハンズオン"
echo " KVM + libvirtで仮想マシンのライフサイクル管理を体験する"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "注意: このスクリプトはDocker内で --privileged 付きで実行してください"
echo ""
echo "  docker run -it --rm --privileged --device /dev/kvm:/dev/kvm --name kvm-handson ubuntu:24.04 bash"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo "============================================================"
echo " 環境セットアップ"
echo "============================================================"
echo ""

apt-get update -qq && apt-get install -y -qq \
  qemu-system-x86 qemu-utils libvirt-daemon-system \
  libvirt-clients virtinst cpu-checker procps \
  bridge-utils iproute2 bc > /dev/null 2>&1
echo "必要なパッケージをインストールしました"

# ============================================================
echo ""
echo "============================================================"
echo " 演習1: KVM環境の確認"
echo "============================================================"
echo ""

echo "--- ハードウェア仮想化サポートの確認 ---"

if [ -e /dev/kvm ]; then
  echo "/dev/kvm が存在: KVMが利用可能"
  ls -la /dev/kvm
else
  echo "/dev/kvm が存在しない"
  echo "ホストでKVMが有効化されているか確認してください"
fi
echo ""

echo "--- CPU仮想化拡張の確認 ---"
if grep -q vmx /proc/cpuinfo; then
  echo "Intel VT-x (vmx) 検出"
  echo "  2005年11月にIntelが初めてリリースした"
  echo "  x86ハードウェア仮想化支援技術"
elif grep -q svm /proc/cpuinfo; then
  echo "AMD-V (svm) 検出"
  echo "  2006年にAMDがリリースした"
  echo "  x86ハードウェア仮想化支援技術"
else
  echo "仮想化拡張が見つからない"
fi
echo ""

echo "--- KVMカーネルモジュール ---"
lsmod | grep kvm 2>/dev/null || echo "(コンテナ環境ではlsmodが制限される場合があります)"
echo ""
echo "KVMはLinux 2.6.20（2007年2月）でカーネルにマージされた。"
echo "現在のLinuxカーネルには標準で含まれている。"

# ============================================================
echo ""
echo "============================================================"
echo " 演習2: virshによるVM管理（クラウドAPIの原型）"
echo "============================================================"
echo ""

echo "--- libvirtデーモンの起動 ---"
mkdir -p /run/libvirt
libvirtd -d 2>/dev/null || echo "libvirtd起動（エラーは無視可）"
sleep 2

echo "--- virsh接続確認 ---"
virsh version 2>/dev/null || echo "virshの接続に失敗（libvirtd未起動の可能性）"
echo ""

echo "--- 仮想マシンのディスクイメージ作成 ---"
mkdir -p /var/lib/libvirt/images
qemu-img create -f qcow2 /var/lib/libvirt/images/test-vm.qcow2 1G
echo ""
echo "qcow2フォーマット:"
echo "  - QEMU Copy-On-Write version 2"
echo "  - 実際に使用した分だけディスクを消費（シンプロビジョニング）"
echo "  - スナップショットをサポート"
echo ""

echo "--- 仮想マシンのXML定義 ---"
echo "  クラウドAPIの原型: VMを宣言的に定義する"
echo ""

cat > "${WORKDIR}/test-vm.xml" << 'XMLEOF'
<domain type='kvm'>
  <name>test-vm</name>
  <memory unit='MiB'>256</memory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64' machine='pc'>hvm</type>
    <boot dev='hd'/>
  </os>
  <devices>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/test-vm.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <interface type='network'>
      <source network='default'/>
      <model type='virtio'/>
    </interface>
  </devices>
</domain>
XMLEOF

echo "定義ファイルの内容:"
cat "${WORKDIR}/test-vm.xml"
echo ""
echo ""
echo "注目すべきポイント:"
echo "  - type='kvm' → KVMハイパーバイザを使用"
echo "  - bus='virtio' → 準仮想化I/Oドライバ（高速）"
echo "  - model type='virtio' → ネットワークもvirtio"
echo "  - memory/vcpu → リソース割り当ての宣言"

# ============================================================
echo ""
echo "============================================================"
echo " 演習3: VMのライフサイクル管理"
echo "============================================================"
echo ""

echo "--- Step 1: VMの定義（virsh define） ---"
virsh define "${WORKDIR}/test-vm.xml" 2>/dev/null || echo "  (virsh define失敗、libvirtdが未起動の可能性)"
echo ""
echo "define = VMの設定を永続化する"
echo "  → AWSで言えば: LaunchTemplateの作成"
echo ""

echo "--- Step 2: VM一覧の確認（virsh list --all） ---"
virsh list --all 2>/dev/null || echo "  (virsh list失敗)"
echo ""
echo "list --all = 全VM（停止中含む）を表示"
echo "  → AWSで言えば: aws ec2 describe-instances"
echo ""

echo "--- Step 3: VM情報の確認（virsh dominfo） ---"
virsh dominfo test-vm 2>/dev/null || echo "  (virsh dominfo失敗)"
echo ""
echo "dominfo = VMの詳細情報"
echo "  → AWSで言えば: インスタンスのDescribe"
echo ""

echo "--- Step 4: VMの起動試行（virsh start） ---"
virsh start test-vm 2>/dev/null || \
  echo "  (OSが未インストールのため起動エラーは想定内)"
echo ""
echo "start = VMの起動"
echo "  → AWSで言えば: aws ec2 start-instances"
echo ""

echo "--- Step 5: VMの定義解除（virsh undefine） ---"
virsh undefine test-vm 2>/dev/null || echo "  (virsh undefine失敗)"
echo ""
echo "undefine = VMの定義を削除"
echo "  → AWSで言えば: aws ec2 terminate-instances"
echo ""

echo "--- Step 6: 削除確認 ---"
virsh list --all 2>/dev/null || echo "  (確認失敗)"
echo ""

echo "--- virshコマンドとクラウドAPIの対応 ---"
echo ""
echo "  virshコマンド          AWS CLI相当"
echo "  ─────────────────────────────────────"
echo "  virsh define           LaunchTemplate作成"
echo "  virsh start            ec2 run-instances"
echo "  virsh list             ec2 describe-instances"
echo "  virsh shutdown         ec2 stop-instances"
echo "  virsh destroy          ec2 stop-instances（強制）"
echo "  virsh undefine         ec2 terminate-instances"
echo "  virsh snapshot-create  ec2 create-snapshot"
echo "  virsh migrate          (内部的にライブマイグレーション)"

# ============================================================
echo ""
echo "============================================================"
echo " 演習4: virtioの設計思想を理解する"
echo "============================================================"
echo ""

echo "--- エミュレーションデバイス vs virtioデバイス ---"
echo ""
echo "仮想マシンのXML定義で、I/Oデバイスの指定方法が"
echo "性能を大きく左右する。"
echo ""

echo "[パターンA: エミュレーションデバイス（低速だが互換性が高い）]"
echo '    <target dev="hda" bus="ide"/>   ← IDEコントローラをエミュレーション'
echo '    <model type="e1000"/>           ← Intel e1000 NICをエミュレーション'
echo ""
echo "  → ゲストOSの既存ドライバで動作（追加ドライバ不要）"
echo "  → 各I/O操作でVMExitが発生し、QEMUがソフトウェアで処理"
echo "  → I/O性能が低い"
echo ""

echo "[パターンB: virtioデバイス（高速、推奨）]"
echo '    <target dev="vda" bus="virtio"/>  ← virtioバスを使用'
echo '    <model type="virtio"/>            ← virtio NICを使用'
echo ""
echo "  → ゲストOSにvirtioドライバが必要"
echo "    （Linux 2.6.25以降は標準搭載、Windowsは要追加）"
echo "  → 共有メモリのリングバッファで効率的にデータ転送"
echo "  → VMExitの回数を大幅に削減"
echo "  → I/O性能がエミュレーション比で数倍向上"
echo ""

echo "--- virtioの歴史的意義 ---"
echo ""
echo "2008年、IBMのRusty Russellがvirtioを発表した。"
echo "virtioは「仮想化環境に最適化されたI/O」という"
echo "準仮想化の考え方をI/Oレイヤーに適用したものだ。"
echo ""
echo "Xenの準仮想化がCPU命令レベルの最適化だったのに対し、"
echo "virtioはI/Oレベルの準仮想化と言える。"

# ============================================================
echo ""
echo "============================================================"
echo " ハンズオン完了"
echo "============================================================"
echo ""
echo "この演習で体験したこと:"
echo "  1. KVMはLinuxカーネルの標準機能として仮想化を提供する"
echo "  2. virshのXML定義はクラウドAPIの原型である"
echo "  3. VMのライフサイクル管理（define/start/shutdown/undefine）は"
echo "     AWS CLIのインスタンス管理に直結する"
echo "  4. virtioは準仮想化の思想をI/Oに適用し、性能を改善した"
echo ""
echo "次回（第8回）: AWS EC2（2006年）——「サーバを借りる」概念が変わった日"
