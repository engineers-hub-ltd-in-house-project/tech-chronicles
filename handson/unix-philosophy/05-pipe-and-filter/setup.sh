#!/bin/bash
set -euo pipefail
WORKDIR="${HOME}/unix-philosophy-handson-05"

echo "============================================"
echo " 第5回ハンズオン: パイプとフィルタ"
echo " ソフトウェア合成の原点"
echo "============================================"
echo ""

# --------------------------------------------------
echo ">>> セットアップ: 必要パッケージのインストール"
# --------------------------------------------------
apt-get update -qq && apt-get install -y -qq strace gcc > /dev/null 2>&1
echo "    strace, gcc インストール完了"
echo ""

mkdir -p "$WORKDIR"
cd "$WORKDIR"

# --------------------------------------------------
echo ">>> 演習1: straceでパイプの内部を観察する"
# --------------------------------------------------
echo ""
echo "--- パイプに関連するシステムコールを追跡 ---"
echo '$ strace -f -e trace=pipe,pipe2,dup2 bash -c "echo hello | cat"'
echo ""
strace -f -e trace=pipe,pipe2,dup2 bash -c 'echo hello | cat' 2>&1 || true
echo ""
echo "  pipe([3, 4])  → カーネルがパイプを作成（fd[0]=3:読, fd[1]=4:書）"
echo "  dup2(4, 1)    → 書き込み側をstdoutに接続"
echo "  dup2(3, 0)    → 読み出し側をstdinに接続"
echo ""

# --------------------------------------------------
echo ">>> 演習2: パイプバッファのブロッキング体験"
# --------------------------------------------------
echo ""
echo "--- パイプバッファのサイズ ---"
echo "  デフォルトバッファサイズ: $(cat /proc/sys/fs/pipe-max-size) bytes (max)"
echo ""
echo "  yes コマンドがパイプバッファを満たすと write がブロックされる"
echo "  2秒後に wc -c が読み出しを開始するとデータが流れ始める"
echo ""
BYTES=$(timeout 3 bash -c 'yes | (sleep 2; wc -c)' 2>/dev/null || true)
echo "  3秒間で転送されたバイト数: $BYTES"
echo ""

# --------------------------------------------------
echo ">>> 演習3: Cで自作フィルタを書く"
# --------------------------------------------------
echo ""
cat << 'CEOF' > "$WORKDIR/lineinfo.c"
/* lineinfo: 各行に行番号と文字数を付加するフィルタ */
#include <stdio.h>
#include <string.h>

int main(void) {
    char buf[4096];
    int lineno = 0;

    while (fgets(buf, sizeof(buf), stdin) != NULL) {
        lineno++;
        size_t len = strlen(buf);
        if (len > 0 && buf[len - 1] == '\n') {
            len--;
        }
        printf("%4d [%3zu chars] %s", lineno, len, buf);
    }

    return 0;
}
CEOF
gcc -o "$WORKDIR/lineinfo" "$WORKDIR/lineinfo.c"
echo "--- 自作フィルタ lineinfo をコンパイル ---"
echo ""
echo "--- /etc/passwd の先頭5行にフィルタを適用 ---"
head -5 /etc/passwd | "$WORKDIR/lineinfo"
echo ""
echo "--- パイプラインに組み込む: grep → lineinfo → sort ---"
grep -E '^(root|nobody)' /etc/passwd | "$WORKDIR/lineinfo" | sort -t'[' -k2 -n
echo ""

# --------------------------------------------------
echo ">>> 演習4: 名前付きパイプ（FIFO）"
# --------------------------------------------------
echo ""
FIFO_PATH="$WORKDIR/myfifo"
rm -f "$FIFO_PATH"
mkfifo "$FIFO_PATH"
echo "--- 名前付きパイプを作成 ---"
ls -l "$FIFO_PATH"
echo "  先頭の 'p' が名前付きパイプであることを示す"
echo ""

echo "--- 名前付きパイプでメッセージを送受信 ---"
cat "$FIFO_PATH" &
READER_PID=$!
echo "Hello from writer process" > "$FIFO_PATH"
wait $READER_PID 2>/dev/null || true
rm -f "$FIFO_PATH"
echo ""

# --------------------------------------------------
echo ">>> 演習5: パイプラインの並行動作を視覚化"
# --------------------------------------------------
echo ""
echo "--- Producer と Consumer の並行動作 ---"
slow_producer() {
    for i in 1 2 3; do
        echo "line $i"
        echo "  [Producer] Sent line $i at $(date +%H:%M:%S)" >&2
        sleep 1
    done
}

slow_consumer() {
    while IFS= read -r line; do
        echo "  [Consumer] Got '$line' at $(date +%H:%M:%S)" >&2
        sleep 1
    done
}

slow_producer | slow_consumer 2>&1 > /dev/null
echo ""

# --------------------------------------------------
echo "============================================"
echo " ハンズオン完了"
echo ""
echo " 作成されたファイル:"
echo "   $WORKDIR/lineinfo.c  -- 自作フィルタのソース"
echo "   $WORKDIR/lineinfo    -- コンパイル済みバイナリ"
echo "============================================"
