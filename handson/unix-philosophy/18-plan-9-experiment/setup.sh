#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-18"

echo "============================================"
echo " 第18回ハンズオン: Plan 9の世界を体験する"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================
# 演習1: Linux namespacesでPlan 9のper-process名前空間を体験する
# ============================================
echo ""
echo "=== 演習1: Linux namespacesでPlan 9のper-process名前空間を体験する ==="
echo ""

docker run --rm --privileged ubuntu:24.04 bash -c '
echo "--- Plan 9のper-process名前空間 → Linux namespaces ---"
echo ""
echo "Plan 9では各プロセスが独自のファイルシステム名前空間を持つ。"
echo "Linuxのunshare(2)は、この概念を実装したシステムコールだ。"
echo ""

echo "--- 現在のnamespace情報 ---"
ls -la /proc/self/ns/ 2>/dev/null || echo "(情報取得不可)"
echo ""

echo "--- Linux namespaceの種類とPlan 9との対応 ---"
echo ""
echo "Linux namespace   導入時期        Plan 9との対応"
echo "─────────────────────────────────────────────────────────"
echo "mount (mnt)       2002 (2.4.19)   per-process名前空間の直接的実装"
echo "UTS               2006 (2.6.19)   (UNIXの機能)"
echo "IPC               2006 (2.6.19)   Plan 9では9Pで代替"
echo "PID               2008 (2.6.24)   Plan 9のrfork(RFPROC)に対応"
echo "network (net)     2009 (2.6.29)   Plan 9の/netに対応"
echo "user              2013 (3.8)      (Plan 9には直接対応なし)"
echo "cgroup            2016 (4.6)      (Plan 9には直接対応なし)"
echo "time              2020 (5.6)      (Plan 9には直接対応なし)"
echo ""

echo "--- rfork() vs clone() vs unshare() ---"
echo ""
echo "Plan 9: rfork(flags)"
echo "  RFNAMEG  名前空間を共有     RFCNAMEG  名前空間をコピー"
echo "  RFFDG    FDテーブルをコピー  RFMEM     メモリを共有"
echo "  RFPROC   新プロセスを作成    RFNOWAIT  親がwaitしない"
echo ""
echo "Linux: clone(flags, ...)"
echo "  CLONE_NEWNS    新しいmount namespace"
echo "  CLONE_NEWPID   新しいPID namespace"
echo "  CLONE_NEWNET   新しいnetwork namespace"
echo "  CLONE_NEWUSER  新しいuser namespace"
echo ""
echo "Linux: unshare(flags)"
echo "  → 既存プロセスの名前空間を分離（rforkのコピー操作に相当）"
'

echo ""
echo "演習1完了"

# ============================================
# 演習2: mount namespaceの分離を体験する
# ============================================
echo ""
echo "=== 演習2: mount namespaceの分離を体験する ==="
echo ""

docker run --rm --privileged ubuntu:24.04 bash -c '
echo "--- mount namespaceの分離体験 ---"
echo ""

mkdir -p /tmp/plan9-demo

echo "--- 通常のマウント（グローバルに見える）---"
mount -t tmpfs none /tmp/plan9-demo
echo "Plan 9 was here" > /tmp/plan9-demo/hello.txt
echo "マウント内容: $(cat /tmp/plan9-demo/hello.txt)"
umount /tmp/plan9-demo

echo ""
echo "--- unshareによるmount namespace分離 ---"

unshare --mount bash -c "
    mount -t tmpfs none /tmp/plan9-demo
    echo \"Private namespace content\" > /tmp/plan9-demo/secret.txt
    echo \"namespace内: \$(cat /tmp/plan9-demo/secret.txt)\"
    echo \"この/tmp/plan9-demoは、このプロセスにしか見えない\"
"

echo ""
echo "namespace外: /tmp/plan9-demo の内容 = $(ls /tmp/plan9-demo 2>/dev/null || echo "(空)")"
echo "→ unshare内のマウントは外部に影響しない。これがper-process名前空間だ。"
'

echo ""
echo "演習2完了"

# ============================================
# 演習3: 9Pプロトコルの概念をLinux上で確認する
# ============================================
echo ""
echo "=== 演習3: 9Pプロトコルの概念をLinux上で確認する ==="
echo ""

docker run --rm --privileged ubuntu:24.04 bash -c '
echo "--- /proc: Plan 9由来のプロセスファイルシステム ---"
echo ""

PID=$$
echo "PID $PID のプロセス情報:"
echo "  /proc/$PID/comm    = $(cat /proc/$PID/comm 2>/dev/null)"
echo "  /proc/$PID/cmdline = $(tr "\0" " " < /proc/$PID/cmdline 2>/dev/null)"
echo "  /proc/$PID/status（抜粋）:"
head -5 /proc/$PID/status 2>/dev/null | sed "s/^/    /"
echo ""

echo "--- Linux カーネルの9Pサポート ---"
echo "CONFIG_9P_FS: Plan 9の9Pプロトコルのネイティブサポート"
echo "用途: KVM/QEMU VirtFS, WSL2ファイルアクセス"
echo ""
modinfo 9p 2>/dev/null && echo "→ 9Pモジュールが利用可能" || \
  echo "→ 9Pモジュール情報取得不可（コンテナ内のため）"
'

echo ""
echo "演習3完了"

# ============================================
# 演習4: ユニオンマウントの概念をoverlayfsで体験する
# ============================================
echo ""
echo "=== 演習4: ユニオンマウントの概念をoverlayfsで体験する ==="
echo ""

docker run --rm --privileged ubuntu:24.04 bash -c '
echo "--- Plan 9のユニオンマウント → Linux overlayfs ---"
echo ""

mkdir -p /tmp/overlay-demo/{lower,upper,work,merged}

echo "original content" > /tmp/overlay-demo/lower/base.txt
echo "will be hidden" > /tmp/overlay-demo/lower/override.txt
echo "overridden content" > /tmp/overlay-demo/upper/override.txt
echo "new file" > /tmp/overlay-demo/upper/added.txt

echo "下位レイヤ（lower）:"
ls /tmp/overlay-demo/lower/
echo ""

echo "上位レイヤ（upper）:"
ls /tmp/overlay-demo/upper/
echo ""

mount -t overlay overlay \
  -o lowerdir=/tmp/overlay-demo/lower,upperdir=/tmp/overlay-demo/upper,workdir=/tmp/overlay-demo/work \
  /tmp/overlay-demo/merged

echo "統合結果（merged）:"
for f in /tmp/overlay-demo/merged/*; do
    echo "  $(basename $f): $(cat $f)"
done
echo ""
echo "→ 上位レイヤの同名ファイルが下位レイヤを覆い隠す。"
echo "  これがDockerイメージレイヤの仕組みの基盤だ。"

umount /tmp/overlay-demo/merged 2>/dev/null
'

echo ""
echo "演習4完了"

# ============================================
# 演習5: UTF-8の自己同期性を確認する
# ============================================
echo ""
echo "=== 演習5: UTF-8の自己同期性を確認する ==="
echo ""

docker run --rm ubuntu:24.04 bash -c '
echo "--- UTF-8: Plan 9が世界に贈った文字エンコーディング ---"
echo ""

echo "文字とUTF-8バイト列:"
printf "A (U+0041):   "; echo -n "A" | xxd -p
printf "あ (U+3042):  "; echo -n "あ" | xxd -p
printf "漢 (U+6F22):  "; echo -n "漢" | xxd -p
printf "Glenda (U+1F430): "; echo -n "🐰" | xxd -p
echo ""

echo "UTF-8の自己同期性:"
echo "  先頭バイト:  0xxxxxxx → 1バイト文字 (ASCII)"
echo "               110xxxxx → 2バイト文字の開始"
echo "               1110xxxx → 3バイト文字の開始"
echo "               11110xxx → 4バイト文字の開始"
echo "  継続バイト:  10xxxxxx → 文字の途中"
echo ""
echo "→ どのバイトからでも文字境界を検出できる。"
echo "  これが1992年のダイナーで設計された文字エンコーディングだ。"
'

echo ""
echo "演習5完了"

# ============================================
echo ""
echo "============================================"
echo " 全演習完了"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
