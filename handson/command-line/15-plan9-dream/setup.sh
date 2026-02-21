#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/command-line-handson-15"

echo "============================================"
echo " 第15回ハンズオン: Plan 9の夢"
echo " ――UNIXの先にあったもの"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================
# 演習1: LinuxにおけるPlan 9の痕跡
# ============================================

echo ""
echo "============================================"
echo " 演習1: LinuxにおけるPlan 9の痕跡"
echo "============================================"
echo ""

echo "--- /proc: Plan 9由来のファイルシステム ---"
echo ""
echo "プロセス一覧（/procディレクトリ）:"
ls /proc/ | head -20
echo "..."
echo ""

echo "プロセス情報をファイルとして読む:"
echo '$ cat /proc/1/status | head -10'
cat /proc/1/status 2>/dev/null | head -10 || echo "(権限がないため読み取り不可)"
echo ""

echo "Plan 9では、プロセスの制御もファイルへの書き込みで行った。"
echo "例: echo stop > /proc/42/ctl"
echo "例: echo kill > /proc/42/ctl"
echo ""
echo "Linuxの /proc はPlan 9の影響を受けているが、"
echo "Plan 9ほど徹底していない。"
echo ""

echo "--- /proc 配下のカーネル情報 ---"
echo ""
echo '$ cat /proc/version'
cat /proc/version
echo ""

if [ -f /proc/cpuinfo ]; then
    echo '$ cat /proc/cpuinfo | head -5'
    head -5 /proc/cpuinfo
    echo ""
fi

echo "→ Linuxの /proc はプロセス情報だけでなく"
echo "  カーネルパラメータも含む雑多な構造。"
echo "  Plan 9の /proc はプロセス専用で一貫性が高い。"

# ============================================
# 演習2: UTF-8の設計原則を体感する
# ============================================

echo ""
echo "============================================"
echo " 演習2: UTF-8の設計原則を体感する"
echo "============================================"
echo ""

echo "--- ASCII互換性の確認 ---"
echo ""
echo "ASCII文字は1バイト（Plan 9チームの要件: ASCII互換）:"
printf "A → "; echo -n "A" | xxd -p
printf "z → "; echo -n "z" | xxd -p
echo ""

echo "日本語は3バイト（可変長エンコーディング）:"
printf "あ → "; echo -n "あ" | xxd -p
printf "漢 → "; echo -n "漢" | xxd -p
echo ""

echo "--- 自己同期性の確認 ---"
echo ""
echo "UTF-8のバイトパターン:"
echo "  0xxxxxxx         → 1バイト文字（ASCII、0x00-0x7F）"
echo "  110xxxxx 10xxxxxx → 2バイト文字"
echo "  1110xxxx 10xxxxxx 10xxxxxx → 3バイト文字"
echo "  11110xxx 10xxxxxx 10xxxxxx 10xxxxxx → 4バイト文字"
echo ""
echo "先頭バイトを見れば文字の長さがわかる。"
echo "継続バイト（10xxxxxx）は先頭バイトと区別できる。"
echo "→ ストリームの途中からでも文字境界を特定可能。"
echo ""

echo "--- ヌルバイト非含有の確認 ---"
echo ""
echo "UTF-8では、U+0000以外の文字にヌルバイト（0x00）は現れない:"
echo -n "Hello世界" | xxd
echo ""
echo "→ C言語の文字列関数（strlen, strcmp等）がそのまま動作する。"
echo "  これがPlan 9チームがUTF-16を拒否した主要な理由だ。"

echo ""
echo "--- ソート順保存の確認 ---"
echo ""
cat > "${WORKDIR}/utf8-sort-test.txt" << 'EOF'
C
A
B
a
b
c
EOF
echo "バイト列としてのソート:"
echo '$ LC_ALL=C sort utf8-sort-test.txt'
LC_ALL=C sort "${WORKDIR}/utf8-sort-test.txt"
echo ""
echo "→ UTF-8ではバイト列のソートがコードポイント順と一致する。"

# ============================================
# 演習3: 9Pプロトコルの概念をLinuxで確認する
# ============================================

echo ""
echo "============================================"
echo " 演習3: 9Pプロトコルの現代での利用"
echo "============================================"
echo ""

echo "--- Linuxカーネルの9Pサポート ---"
echo ""
if [ -f /proc/filesystems ]; then
    echo '$ grep 9p /proc/filesystems'
    grep 9p /proc/filesystems 2>/dev/null || \
        echo "(このカーネルでは9pモジュールが未ロード)"
fi
echo ""

echo "9Pプロトコルは現代でも使われている:"
echo ""
echo "  1. WSL (Windows Subsystem for Linux)"
echo "     → WindowsとLinux間のファイル共有に9Pを使用"
echo "     → /mnt/c/ でWindowsのCドライブにアクセスする裏側"
echo ""
echo "  2. QEMU VirtFS"
echo "     → ホストとゲスト間のフォルダ共有に9Pを使用"
echo ""
echo "  3. Container runtimes"
echo "     → 一部の実装でファイル共有に9Pが使われる"
echo ""

echo "--- Plan 9の /net をLinuxのソケットと比較 ---"
echo ""
echo "Plan 9 でのTCP接続:"
echo '  $ cat /net/tcp/clone   → コネクション番号取得'
echo '  $ echo "connect 10.0.0.1!80" > /net/tcp/5/ctl'
echo '  $ cat /net/tcp/5/data  → データ受信'
echo ""
echo "Linux でのTCP接続:"
echo '  fd = socket(AF_INET, SOCK_STREAM, 0);'
echo '  connect(fd, &addr, sizeof(addr));'
echo '  read(fd, buf, sizeof(buf));'
echo ""
echo "→ Linuxではネットワークは依然としてsocket APIが主流。"
echo "  Plan 9の「ネットワークもファイル」は実現されていない。"

# ============================================
# 演習4: Linux namespaces と Plan 9の関係
# ============================================

echo ""
echo "============================================"
echo " 演習4: Linux namespaces — Plan 9の遺産"
echo "============================================"
echo ""

echo "--- 現在のnamespace情報 ---"
echo ""
echo '$ ls -la /proc/self/ns/'
ls -la /proc/self/ns/ 2>/dev/null || echo "(namespace情報の取得に失敗)"
echo ""

echo "各namespaceの説明:"
echo "  cgroup  → cgroup namespace"
echo "  ipc     → IPC namespace"
echo "  mnt     → mount namespace（Plan 9: per-process namespace由来）"
echo "  net     → network namespace（Plan 9: /net のbind相当）"
echo "  pid     → PID namespace（Plan 9: /proc のbind相当）"
echo "  user    → user namespace"
echo "  uts     → UTS namespace（ホスト名等）"
echo ""

echo "--- Dockerコンテナの正体 ---"
echo ""
echo "docker run は以下のLinux機能を組み合わせる:"
echo ""
echo "  1. namespaces（Plan 9由来の概念）"
echo "     → プロセスに独立した名前空間を提供"
echo "  2. cgroups"
echo "     → リソース使用量を制限"
echo "  3. union filesystem"
echo "     → 層状のファイルシステム（Plan 9のbindに類似）"
echo ""
echo "Plan 9のper-process namespacesは、"
echo "30年以上の時を経て、コンテナ技術の基盤となった。"

# ============================================
# まとめ
# ============================================

echo ""
echo "============================================"
echo " まとめ"
echo "============================================"
echo ""
echo "1. /proc はPlan 9が生んだ「プロセスをファイルとして扱う」思想"
echo "2. UTF-8 はPlan 9チームが1992年に設計した文字エンコーディング"
echo "3. 9P プロトコルはWSLやQEMUで現在も使われている"
echo "4. Linux namespaces はPlan 9のper-process namespacesに影響を受けた"
echo "5. Docker のコンテナ分離は、間接的にPlan 9の設計思想に由来する"
echo ""
echo "Plan 9は「失敗した未来」ではなく、"
echo "「実現されなかった正解」として現代に生き続けている。"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "クリーンアップ: rm -rf ${WORKDIR}"
