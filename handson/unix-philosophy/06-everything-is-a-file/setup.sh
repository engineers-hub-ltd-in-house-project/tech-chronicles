#!/bin/bash
set -euo pipefail
WORKDIR="${HOME}/unix-philosophy-handson-06"

echo "============================================"
echo " 第6回ハンズオン: Everything is a file"
echo " 抽象化の極致"
echo "============================================"
echo ""

# --------------------------------------------------
echo ">>> セットアップ: 必要パッケージのインストール"
# --------------------------------------------------
apt-get update -qq && apt-get install -y -qq gcc strace python3 > /dev/null 2>&1
echo "    gcc, strace, python3 インストール完了"
echo ""

mkdir -p "$WORKDIR"
cd "$WORKDIR"

# --------------------------------------------------
echo ">>> 演習1: /procからプロセスの内部を覗く"
# --------------------------------------------------
echo ""
echo "--- 現在のシェルプロセスの情報 ---"
echo "  PID: $$"
echo ""
echo '$ cat /proc/$$/status | head -10'
cat /proc/$$/status | head -10
echo ""

echo "--- プロセスが開いているファイルディスクリプタ ---"
echo '$ ls -l /proc/$$/fd'
ls -l /proc/$$/fd 2>/dev/null || echo "  (権限不足でアクセスできない場合があります)"
echo ""

echo "--- カーネルパラメータの読み取り ---"
echo '$ cat /proc/sys/kernel/hostname'
cat /proc/sys/kernel/hostname
echo ""

# --------------------------------------------------
echo ">>> 演習2: デバイスファイルの動作確認"
# --------------------------------------------------
echo ""
echo "--- /dev/null: すべてを飲み込む ---"
echo '$ echo "このテキストは消える" > /dev/null'
echo "このテキストは消える" > /dev/null
echo '$ cat /dev/null'
cat /dev/null
echo "  (何も出力されない -- 読むと即座にEOF)"
echo ""

echo "--- /dev/zero: 無限のゼロバイト ---"
echo '$ dd if=/dev/zero bs=16 count=1 | od -A x -t x1'
dd if=/dev/zero bs=16 count=1 2>/dev/null | od -A x -t x1
echo ""

echo "--- /dev/urandom: 擬似乱数のストリーム ---"
echo '$ dd if=/dev/urandom bs=16 count=1 | od -A x -t x1'
dd if=/dev/urandom bs=16 count=1 2>/dev/null | od -A x -t x1
echo ""

echo "--- デバイスファイルの種類を確認 ---"
echo '$ ls -l /dev/null /dev/zero /dev/urandom'
ls -l /dev/null /dev/zero /dev/urandom
echo "  すべて先頭が 'c' -- キャラクタデバイス"
echo ""

echo "--- /dev/urandomを使ったランダムパスワード生成 ---"
echo '$ cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16'
PASS=$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 16)
echo "  生成されたパスワード: $PASS"
echo ""

# --------------------------------------------------
echo ">>> 演習3: Cプログラムでファイルディスクリプタの統一性を検証"
# --------------------------------------------------
echo ""
cat << 'CEOF' > "$WORKDIR/fd_demo.c"
/* fd_demo: 異なるファイルタイプに同じread()を適用する */
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

void read_and_show(const char *label, int fd) {
    char buf[64];
    ssize_t n = read(fd, buf, sizeof(buf) - 1);
    if (n > 0) {
        buf[n] = '\0';
        char *nl = strchr(buf, '\n');
        if (nl) *nl = '\0';
        if (strlen(buf) > 40) buf[40] = '\0';
        printf("  %-20s fd=%d  data: %s\n", label, fd, buf);
    } else {
        printf("  %-20s fd=%d  (no data or error)\n", label, fd);
    }
}

int main(void) {
    printf("同じ read() で異なるファイルタイプを読む:\n\n");

    /* 通常ファイル */
    int fd1 = open("/etc/hostname", O_RDONLY);
    if (fd1 >= 0) {
        read_and_show("/etc/hostname", fd1);
        close(fd1);
    }

    /* procfs (仮想ファイル) */
    int fd2 = open("/proc/loadavg", O_RDONLY);
    if (fd2 >= 0) {
        read_and_show("/proc/loadavg", fd2);
        close(fd2);
    }

    /* デバイスファイル */
    int fd3 = open("/dev/urandom", O_RDONLY);
    if (fd3 >= 0) {
        unsigned char rbuf[4];
        read(fd3, rbuf, 4);
        printf("  %-20s fd=%d  data: %02x%02x%02x%02x\n",
               "/dev/urandom", fd3, rbuf[0], rbuf[1], rbuf[2], rbuf[3]);
        close(fd3);
    }

    /* パイプ */
    int pipefd[2];
    if (pipe(pipefd) == 0) {
        write(pipefd[1], "hello from pipe\n", 16);
        close(pipefd[1]);
        read_and_show("pipe", pipefd[0]);
        close(pipefd[0]);
    }

    printf("\n全て同じ read() システムコールで読み取った。\n");
    printf("fd番号は異なるが、操作は同一だ。\n");
    return 0;
}
CEOF
gcc -o "$WORKDIR/fd_demo" "$WORKDIR/fd_demo.c"
echo "--- fd_demo をコンパイル・実行 ---"
echo ""
"$WORKDIR/fd_demo"
echo ""

# --------------------------------------------------
echo ">>> 演習4: straceでVFS層を観察する"
# --------------------------------------------------
echo ""
echo "--- 通常ファイルの読み取り ---"
echo '$ strace -e trace=openat,read,close cat /etc/hostname'
strace -e trace=openat,read,close cat /etc/hostname 2>&1 | tail -6
echo ""

echo "--- procfsの読み取り ---"
echo '$ strace -e trace=openat,read,close cat /proc/loadavg'
strace -e trace=openat,read,close cat /proc/loadavg 2>&1 | tail -6
echo ""

echo "--- デバイスファイルの読み取り ---"
echo '$ strace -e trace=openat,read,close dd if=/dev/urandom bs=4 count=1'
strace -e trace=openat,read,close dd if=/dev/urandom bs=4 count=1 2>&1 | tail -8
echo ""
echo "  どの場合も openat() -> read() -> close() の同じシーケンス"
echo "  VFS層がファイルタイプの違いを吸収している"
echo ""

# --------------------------------------------------
echo "============================================"
echo " ハンズオン完了"
echo ""
echo " 作成されたファイル:"
echo "   $WORKDIR/fd_demo.c   -- fdデモのソース"
echo "   $WORKDIR/fd_demo     -- コンパイル済みバイナリ"
echo ""
echo " 注: FUSE演習（演習5）は追加パッケージが必要なため"
echo "     記事本文のコードを手動で実行してください"
echo "============================================"
