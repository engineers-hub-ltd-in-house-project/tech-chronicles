#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-02"

echo "============================================"
echo " 第2回ハンズオン: PDP-7時代の制約を疑似体験する"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================
echo ""
echo "=== 演習1: 9KBの世界を体感する ==="
echo ""

echo "PDP-7の全メモリ: 9 KB (9,216 bytes)"
echo "---"

echo "現代のコマンドのサイズ:"
for cmd in /bin/ls /bin/bash /bin/grep; do
  if [ -f "$cmd" ]; then
    size=$(stat -c %s "$cmd" 2>/dev/null || stat -f %z "$cmd" 2>/dev/null)
    kb=$(echo "scale=1; $size / 1024" | bc)
    echo "  $cmd: ${size} bytes (${kb} KB)"
  fi
done

echo ""
echo "→ 現代のlsコマンド1つすら、PDP-7の全メモリに収まらない"
echo "→ ThompsonはこのメモリにOS全体を収めた"

# ============================================
echo ""
echo "=== 演習2: 極小メモリでのファイルシステム操作 ==="
echo ""

PDP7_DIR="${WORKDIR}/pdp7-unix"
rm -rf "${PDP7_DIR}"
mkdir -p "${PDP7_DIR}"

mkdir -p "${PDP7_DIR}/dd/root"
mkdir -p "${PDP7_DIR}/dd/usr"
mkdir -p "${PDP7_DIR}/dd/bin"
mkdir -p "${PDP7_DIR}/dd/tmp"

cat << 'PROG' > "${PDP7_DIR}/dd/bin/cat"
#!/bin/sh
cat "$@"
PROG
chmod +x "${PDP7_DIR}/dd/bin/cat"

cat << 'PROG' > "${PDP7_DIR}/dd/bin/ls"
#!/bin/sh
ls "$@"
PROG
chmod +x "${PDP7_DIR}/dd/bin/ls"

echo "PDP-7 UNIX 疑似ファイルシステム構造:"
find "${PDP7_DIR}/dd" -type f -o -type d | sort | sed "s|${PDP7_DIR}/||"

echo ""
echo "→ このシンプルなツリー構造がMulticsから受け継がれた本質"

# ============================================
echo ""
echo "=== 演習3: プロセスの分離を体験する ==="
echo ""

PARENT_VAR="I am the parent"
echo "親プロセス (PID: $$): PARENT_VAR=${PARENT_VAR}"

(
  echo "子プロセス (PID: ${BASHPID}): PARENT_VAR=${PARENT_VAR}"
  PARENT_VAR="I am the child"
  echo "子プロセス 変更後: PARENT_VAR=${PARENT_VAR}"
)

echo "親プロセス 子終了後: PARENT_VAR=${PARENT_VAR}"
echo ""
echo "→ 子プロセスの変更は親に影響しない"
echo "→ これがUNIXのプロセス分離の基本原則"

# ============================================
echo ""
echo "=== 演習4: パイプの原型——プロセス間通信 ==="
echo ""

FIFO_PATH="${WORKDIR}/pdp7_pipe"
rm -f "${FIFO_PATH}"
mkfifo "${FIFO_PATH}"

(
  echo "[Reader] パイプからの読み取りを開始..."
  while IFS= read -r line; do
    echo "[Reader] 受信: ${line}"
  done < "${FIFO_PATH}"
  echo "[Reader] パイプが閉じられた"
) &
READER_PID=$!

sleep 1
(
  echo "[Writer] パイプへの書き込みを開始..."
  echo "Hello from writer" > "${FIFO_PATH}"
  echo "Process communication" >> "${FIFO_PATH}"
  echo "Via named pipe" >> "${FIFO_PATH}"
  echo "[Writer] 書き込み完了"
)

wait ${READER_PID} 2>/dev/null
rm -f "${FIFO_PATH}"

echo ""
echo "→ 二つの独立したプロセスがパイプを介してデータを交換した"

# ============================================
echo ""
echo "=== 演習5: MulticsとUNIXの設計思想を比較する ==="
echo ""

TEST_DIR="${WORKDIR}/design_compare"
rm -rf "${TEST_DIR}"
mkdir -p "${TEST_DIR}"

echo "error: disk full" > "${TEST_DIR}/system.log"
echo "info: startup complete" >> "${TEST_DIR}/system.log"
echo "error: connection refused" >> "${TEST_DIR}/system.log"
echo "warning: memory low" >> "${TEST_DIR}/system.log"
echo "error: timeout" >> "${TEST_DIR}/system.log"

echo "def calculate(): pass" > "${TEST_DIR}/app.py"
echo "# error handling" >> "${TEST_DIR}/app.py"

echo "SELECT * FROM users;" > "${TEST_DIR}/query.sql"
echo "-- error: fix this query" >> "${TEST_DIR}/query.sql"

echo "--- UNIX的アプローチ: 単機能コマンドの組み合わせ ---"
echo ""
echo "Step 1: grep で 'error' を含む行を抽出"
grep -rn "error" "${TEST_DIR}"

echo ""
echo "Step 2: .log ファイルに絞り込み"
grep -rn "error" "${TEST_DIR}" | grep "\.log:"

echo ""
echo "Step 3: 件数をカウント"
echo "全ファイルのerror件数: $(grep -rn "error" "${TEST_DIR}" | wc -l)"
echo "logファイルのerror件数: $(grep -rn "error" "${TEST_DIR}" | grep "\.log:" | wc -l)"

rm -rf "${TEST_DIR}"

echo ""
echo "→ 各コマンドは一つの仕事に専念し、パイプで組み合わさる"
echo "→ Multicsの万能コマンドより柔軟性が高い"

# ============================================
echo ""
echo "============================================"
echo " 全演習完了"
echo "============================================"
echo ""
echo "この演習で体験したこと:"
echo "  1. 9KBのメモリ制約がUNIXの設計をどう形成したか"
echo "  2. 階層型ファイルシステム——Multicsから受け継いだ本質"
echo "  3. プロセスの分離——UNIXの基本原則"
echo "  4. パイプによるプロセス間通信——組み合わせ可能性の基盤"
echo "  5. 単機能コマンドの組み合わせ——UNIX哲学の核心"
