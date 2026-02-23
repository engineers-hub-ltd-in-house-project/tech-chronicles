#!/bin/bash
# =============================================================================
# 第20回ハンズオン：Dockerなしでコンテナを手動構築する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 推奨環境: docker run -it --privileged ubuntu:24.04 bash
# 必要な権限: CAP_SYS_ADMIN（--privilegedで付与）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-20"

echo "=== 第20回ハンズオン：Dockerなしでコンテナを手動構築する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- 演習1: namespacesによるプロセス隔離 ---
echo "============================================================"
echo "[演習1] namespacesによるプロセス隔離"
echo "============================================================"
echo ""
echo "unshare コマンドで新しい namespace を作成し、"
echo "プロセスを隔離された環境に配置する。"
echo ""

echo "--- 現在の環境 ---"
echo "ホスト名: $(hostname)"
echo "PID: $$"
echo ""

echo "--- unshare で新しい namespace を作成 ---"
echo ""
echo "unshare のオプション:"
echo "  --uts    : UTS namespace（ホスト名）を分離"
echo "  --pid    : PID namespace（プロセスID空間）を分離"
echo "  --mount  : Mount namespace（マウントポイント）を分離"
echo "  --fork   : 新しい PID namespace で fork してから実行"
echo ""

unshare --uts --pid --mount --fork /bin/bash -c '
  echo "=== 隔離された環境 ==="

  # UTS namespace が分離されているのでホスト側には影響しない
  hostname container-demo
  echo "ホスト名: $(hostname)"

  # PID namespace を正しく反映させるため proc を再マウント
  mount -t proc proc /proc

  echo ""
  echo "--- PID namespace 内のプロセス ---"
  ps aux 2>/dev/null || echo "(ps が利用できない環境)"
  echo ""
  echo "注目: PID 1 が /bin/bash になっている。"
  echo "通常の Linux では PID 1 は init/systemd だ。"
  echo "PID namespace を分離したことで、"
  echo "このシェルが「この世界の init」になった。"
  echo ""
  echo "これがコンテナの本質だ。"
  echo "Docker は裏でこれと同じことをしている。"

  umount /proc 2>/dev/null
'

echo ""
echo "--- ホスト側に戻った ---"
echo "ホスト名: $(hostname)"
echo "(UTS namespace が分離されていたので、"
echo " ホスト側のホスト名は変わっていない)"
echo ""

# --- 演習2: cgroupsによるリソース制限 ---
echo "============================================================"
echo "[演習2] cgroups によるリソース制限"
echo "============================================================"
echo ""
echo "cgroups を使ってプロセスのメモリ使用量を制限する。"
echo "Docker の --memory オプションの裏で動いている仕組みだ。"
echo ""

CGROUP_BASE="/sys/fs/cgroup"
CGROUP_PATH="${CGROUP_BASE}/demo-container"

echo "--- cgroup の確認 ---"
if mount | grep -q "cgroup2"; then
    echo "cgroup v2 が有効"
    echo ""

    # 既存の cgroup があれば削除
    if [ -d "$CGROUP_PATH" ]; then
        rmdir "$CGROUP_PATH" 2>/dev/null || true
    fi

    mkdir -p "$CGROUP_PATH"

    # サブツリー制御を有効化
    echo "+memory" > "$CGROUP_BASE/cgroup.subtree_control" 2>/dev/null || true

    # メモリ制限を 50MB に設定
    echo "52428800" > "$CGROUP_PATH/memory.max" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "メモリ制限を設定: $(cat "$CGROUP_PATH/memory.max") bytes (50MB)"
    else
        echo "メモリ制限の設定に失敗（権限不足の可能性）"
    fi
    echo ""

    echo "--- cgroup ディレクトリの中身 ---"
    ls "$CGROUP_PATH/" 2>/dev/null | head -10
    echo ""

    echo "=== cgroup の仕組み ==="
    echo ""
    echo "Docker の --memory=50m オプションは、内部で以下を実行する:"
    echo "  1. 新しい cgroup ディレクトリを作成"
    echo "  2. memory.max に制限値を書き込む"
    echo "  3. コンテナの PID を cgroup.procs に書き込む"
    echo ""
    echo "つまり、Docker のリソース制限は"
    echo "cgroups のファイル操作に過ぎない。"
    echo "\"Everything is a file\" の原則が"
    echo "ここでも生きている。"

    # クリーンアップ
    rmdir "$CGROUP_PATH" 2>/dev/null || true
else
    echo "cgroup v1 環境（演習の cgroup v2 部分はスキップ）"
fi
echo ""

# --- 演習3: ファイルシステム隔離の手動構築 ---
echo "============================================================"
echo "[演習3] ファイルシステム隔離の手動構築"
echo "============================================================"
echo ""
echo "chroot と mount namespace を組み合わせて、"
echo "独自のルートファイルシステムを持つ隔離環境を作る。"
echo ""

ROOTFS="${WORKDIR}/mini-rootfs"
mkdir -p "${ROOTFS}"/{bin,lib,lib64,proc,sys,dev,etc,tmp}

echo "--- 最小限のルートファイルシステムを構築 ---"

# 必要なバイナリをコピー
for bin in bash ls cat echo hostname ps; do
    if [ -f "/bin/$bin" ]; then
        cp "/bin/$bin" "${ROOTFS}/bin/" 2>/dev/null || true
    elif [ -f "/usr/bin/$bin" ]; then
        cp "/usr/bin/$bin" "${ROOTFS}/bin/" 2>/dev/null || true
    fi
done

# 動的ライブラリをコピー
for bin in "${ROOTFS}"/bin/*; do
    if [ -f "$bin" ]; then
        ldd "$bin" 2>/dev/null | grep -o '/[^ ]*' | while read -r lib; do
            dir=$(dirname "${ROOTFS}${lib}")
            mkdir -p "$dir"
            cp "$lib" "${ROOTFS}${lib}" 2>/dev/null || true
        done
    fi
done

# ld-linux をコピー
if [ -f /lib64/ld-linux-x86-64.so.2 ]; then
    mkdir -p "${ROOTFS}/lib64"
    cp /lib64/ld-linux-x86-64.so.2 "${ROOTFS}/lib64/" 2>/dev/null || true
fi
if [ -f /lib/ld-linux-aarch64.so.1 ]; then
    mkdir -p "${ROOTFS}/lib"
    cp /lib/ld-linux-aarch64.so.1 "${ROOTFS}/lib/" 2>/dev/null || true
fi

echo "ルートFS の構造:"
ls "${ROOTFS}"
echo ""

echo "--- 隔離環境に入る ---"
unshare --uts --pid --mount --fork \
    /usr/sbin/chroot "${ROOTFS}" /bin/bash -c '
    echo "=== 手動構築した隔離環境 ==="
    echo "ルートFS: $(ls /)"
    echo "ホスト側のファイルシステムは見えない。"
    echo ""
    echo "この環境は:"
    echo "  - 独自のルートファイルシステムを持つ (chroot)"
    echo "  - 独自の PID 空間を持つ (PID namespace)"
    echo "  - 独自のホスト名を持つ (UTS namespace)"
    echo "  - 独自のマウントポイントを持つ (mount namespace)"
    echo ""
    echo "これが「コンテナ」の本質だ。"
    echo "Docker はこれに、イメージ管理と"
    echo "開発者向けインタフェースを加えたものにすぎない。"
' 2>/dev/null || echo "(chroot 環境の実行に問題が発生した場合は環境依存)"
echo ""

# --- 演習4: コンテナの「層」を可視化 ---
echo "============================================================"
echo "[演習4] コンテナの「層」を可視化"
echo "============================================================"
echo ""

echo "--- /proc/self/ns: 自プロセスの namespace 情報 ---"
ls -la /proc/self/ns/ 2>/dev/null || echo "/proc/self/ns が利用できない"
echo ""
echo "各ファイルが namespace の ID を示す。"
echo "同じ namespace ID を持つプロセスは同じ「世界」にいる。"
echo ""

echo "--- /proc/self/cgroup: 自プロセスの cgroup 情報 ---"
cat /proc/self/cgroup 2>/dev/null || echo "/proc/self/cgroup が利用できない"
echo ""

echo "============================================================"
echo "[まとめ]"
echo "============================================================"
echo ""
echo "コンテナの本質:"
echo "  1. namespaces: リソースの「可視範囲」を制限"
echo "  2. cgroups: リソースの「使用量」を制限"
echo "  3. chroot/pivot_root: ルート FS を差し替え"
echo ""
echo "これらはすべて Linux カーネルの機能であり、"
echo "Docker はその上に「使いやすさ」を加えたツールだ。"
echo "UNIX の「すべてはファイルである」原則の通り、"
echo "namespaces も cgroups も /proc や /sys 配下の"
echo "ファイル操作で制御される。"
echo ""
echo "1979 年の chroot から 2013 年の Docker まで、"
echo "プロセス分離の技術は UNIX の設計哲学の上に"
echo "段階的に積み重ねられてきた。"
echo ""

# クリーンアップ
rm -rf "${WORKDIR}"
echo "[完了] 作業ディレクトリをクリーンアップしました。"
