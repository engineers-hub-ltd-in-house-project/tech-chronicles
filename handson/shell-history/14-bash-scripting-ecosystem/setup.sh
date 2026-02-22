#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-14"

echo "============================================"
echo " 第14回ハンズオン: bashスクリプティングの生態系"
echo " .bashrcからCI/CDまで"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

# -------------------------------------------
# セクション1: 作業ディレクトリの準備
# -------------------------------------------
echo "--- セクション1: 作業ディレクトリの準備 ---"
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# -------------------------------------------
# セクション2: set -euo pipefail の挙動
# -------------------------------------------
echo "--- セクション2: set -euo pipefail の挙動 ---"
echo ""

echo "--- set -e: エラーで即座終了 ---"
bash -e -c '
echo "1. この行は実行される"
false
echo "2. この行は実行されない"
' 2>&1 || echo "(スクリプトがエラーで終了した)"

echo ""
echo "--- set -e が無視される場面 ---"
bash -e -c '
if false; then echo "yes"; else echo "if: -e は無視された"; fi
true && false || echo "&&/||: -e は無視された"
! false
echo "!: -e は無視された"
echo "スクリプトはまだ実行中"
'

echo ""
echo "--- set -u: 未定義変数の検知 ---"
bash -u -c '
echo "定義済み: ${HOME}"
echo "未定義参照の試み..."
echo "${UNDEFINED_VAR}"
' 2>&1 || echo "(未定義変数でエラーになった)"

echo ""
echo "デフォルト値を使えばエラーを回避:"
bash -u -c '
echo "デフォルト値: ${UNDEFINED_VAR:-safe_default}"
echo "成功"
'

echo ""
echo "--- pipefail: パイプラインの失敗検知 ---"
echo "pipefail OFF:"
bash -c '
echo "data" | grep "missing" | cat
echo "  終了ステータス: $?"
'

echo "pipefail ON:"
bash -c '
set -o pipefail
echo "data" | grep "missing" | cat
echo "  終了ステータス: $?"
' 2>/dev/null || echo "  (pipefail でパイプラインが失敗として検知された)"

# -------------------------------------------
# セクション3: trap によるクリーンアップ
# -------------------------------------------
echo ""
echo "--- セクション3: trap によるクリーンアップ ---"

cat << 'SCRIPT' > "${WORKDIR}/trap_demo.sh"
#!/bin/bash
set -euo pipefail

TMPDIR=""

cleanup() {
    local exit_code=$?
    echo "[cleanup] 終了コード: ${exit_code}"
    if [[ -n "${TMPDIR}" && -d "${TMPDIR}" ]]; then
        rm -rf "${TMPDIR}"
        echo "[cleanup] 一時ディレクトリを削除: ${TMPDIR}"
    fi
    echo "[cleanup] クリーンアップ完了"
}

trap cleanup EXIT

TMPDIR=$(mktemp -d)
echo "一時ディレクトリ: ${TMPDIR}"
echo "test data" > "${TMPDIR}/test.txt"
echo "ファイル作成: ${TMPDIR}/test.txt"

case "${1:-normal}" in
    normal)
        echo "正常終了のケース"
        ;;
    error)
        echo "エラー発生のケース"
        false
        ;;
    *)
        echo "Usage: $0 [normal|error]"
        ;;
esac

echo "スクリプト完了"
SCRIPT
chmod +x "${WORKDIR}/trap_demo.sh"

echo "--- 正常終了 ---"
bash "${WORKDIR}/trap_demo.sh" normal

echo ""
echo "--- エラー終了 ---"
bash "${WORKDIR}/trap_demo.sh" error 2>/dev/null || true

echo ""
echo "--- ERRトラップ（bash拡張）のデモ ---"
bash -c '
trap '\''echo "[ERR] エラー発生: 行 $LINENO, コマンド: $BASH_COMMAND"'\'' ERR
echo "コマンド1: 成功"
true
echo "コマンド2: 失敗を発生させる"
false
echo "この行は実行される（set -e がないため）"
' 2>&1 || true

# -------------------------------------------
# セクション4: bats-core によるテスト
# -------------------------------------------
echo ""
echo "--- セクション4: bats-core によるテスト ---"

if command -v git >/dev/null 2>&1; then
    echo "bats-core をインストール中..."
    git clone --depth 1 https://github.com/bats-core/bats-core.git "${WORKDIR}/bats-core" 2>/dev/null
    "${WORKDIR}/bats-core/install.sh" /usr/local 2>/dev/null || true

    if command -v bats >/dev/null 2>&1; then
        echo "bats バージョン: $(bats --version)"

        # テスト対象のスクリプト
        cat << 'LIBRARY' > "${WORKDIR}/string_utils.sh"
#!/bin/bash

to_upper() {
    echo "${1}" | tr '[:lower:]' '[:upper:]'
}

is_empty() {
    [[ -z "${1:-}" ]]
}

count_lines() {
    local file="${1}"
    if [[ ! -f "${file}" ]]; then
        echo "Error: file not found: ${file}" >&2
        return 1
    fi
    wc -l < "${file}"
}
LIBRARY

        # bats テストファイル
        cat << 'TEST' > "${WORKDIR}/test_string_utils.bats"
#!/usr/bin/env bats

setup() {
    source "${BATS_TEST_DIRNAME}/string_utils.sh"
}

@test "to_upper: 小文字を大文字に変換" {
    result=$(to_upper "hello world")
    [ "$result" = "HELLO WORLD" ]
}

@test "to_upper: 既に大文字の文字列" {
    result=$(to_upper "HELLO")
    [ "$result" = "HELLO" ]
}

@test "is_empty: 空文字列" {
    run is_empty ""
    [ "$status" -eq 0 ]
}

@test "is_empty: 非空文字列" {
    run is_empty "hello"
    [ "$status" -eq 1 ]
}

@test "count_lines: 既存ファイル" {
    tmpfile=$(mktemp)
    printf "line1\nline2\nline3\n" > "$tmpfile"
    result=$(count_lines "$tmpfile")
    rm -f "$tmpfile"
    [ "$result" -eq 3 ]
}

@test "count_lines: 存在しないファイル" {
    run count_lines "/nonexistent/file"
    [ "$status" -eq 1 ]
    [[ "$output" == *"file not found"* ]]
}
TEST

        echo ""
        echo "--- テスト実行 ---"
        bats "${WORKDIR}/test_string_utils.bats"
    else
        echo "(bats のインストールに失敗。git は使えるが install.sh が失敗)"
    fi
else
    echo "(git が見つからないため bats-core のインストールをスキップ)"
fi

# -------------------------------------------
# セクション5: ShellCheck による静的解析
# -------------------------------------------
echo ""
echo "--- セクション5: ShellCheck による静的解析 ---"

if command -v shellcheck >/dev/null 2>&1; then
    echo "ShellCheck バージョン: $(shellcheck --version | head -2)"

    cat << 'BADSCRIPT' > "${WORKDIR}/bad_script.sh"
#!/bin/bash

filename=$1
cat $filename

current_date=`date`

files=$(ls *.txt)

arr=(one two three)
echo $arr

if [ "$filename" == "test" ]; then
    echo "match"
fi
BADSCRIPT

    echo ""
    echo "--- 問題のあるスクリプトの解析 ---"
    shellcheck "${WORKDIR}/bad_script.sh" || true

    cat << 'GOODSCRIPT' > "${WORKDIR}/good_script.sh"
#!/bin/bash
set -euo pipefail

filename="${1}"
cat "${filename}"

current_date=$(date)

shopt -s nullglob
files=(*.txt)

arr=(one two three)
echo "${arr[@]}"

if [ "${filename}" = "test" ]; then
    echo "match"
fi
GOODSCRIPT

    echo ""
    echo "--- 修正後のスクリプトの解析 ---"
    shellcheck "${WORKDIR}/good_script.sh" && echo "ShellCheck: 問題なし"
else
    echo "(shellcheck が見つからないためスキップ)"
    echo "インストール: apt-get install shellcheck"
fi

# -------------------------------------------
# セクション6: bash vs Python 実装比較
# -------------------------------------------
echo ""
echo "--- セクション6: bash vs Python 実装比較 ---"

cat << 'DATA' > "${WORKDIR}/access.log"
2024-01-15 10:00:01 GET /api/users 200
2024-01-15 10:00:02 POST /api/users 201
2024-01-15 10:00:03 GET /api/users/1 200
2024-01-15 10:00:04 GET /api/products 200
2024-01-15 10:00:05 POST /api/orders 500
2024-01-15 10:00:06 GET /api/users 200
2024-01-15 10:00:07 GET /api/products 404
2024-01-15 10:00:08 DELETE /api/users/1 200
2024-01-15 10:00:09 GET /api/orders 200
2024-01-15 10:00:10 POST /api/users 500
DATA

cat << 'BASH_VER' > "${WORKDIR}/analyze_bash.sh"
#!/bin/bash
set -euo pipefail

file="${1:?Usage: $0 <logfile>}"

if [[ ! -f "${file}" ]]; then
    echo "Error: ${file} not found" >&2
    exit 1
fi

total=$(wc -l < "${file}")
echo "Total requests: ${total}"

echo ""
echo "Status code distribution:"
awk '{print $NF}' "${file}" | sort | uniq -c | sort -rn | \
    while read -r count code; do
        printf "  %s: %d (%.1f%%)\n" "${code}" "${count}" \
            "$(echo "scale=1; ${count} * 100 / ${total}" | bc)"
    done

echo ""
echo "HTTP method distribution:"
awk '{print $3}' "${file}" | sort | uniq -c | sort -rn | \
    while read -r count method; do
        printf "  %s: %d\n" "${method}" "${count}"
    done

echo ""
echo "Error requests (4xx/5xx):"
awk '$NF >= 400 {print "  " $0}' "${file}"
BASH_VER
chmod +x "${WORKDIR}/analyze_bash.sh"

echo ""
echo "--- bash版: アクセスログ解析 ---"
bash "${WORKDIR}/analyze_bash.sh" "${WORKDIR}/access.log"

if command -v python3 >/dev/null 2>&1; then
    cat << 'PYTHON_VER' > "${WORKDIR}/analyze_python.py"
#!/usr/bin/env python3
import sys
from collections import Counter
from pathlib import Path

def analyze_log(filepath):
    path = Path(filepath)
    if not path.exists():
        print(f"Error: {filepath} not found", file=sys.stderr)
        sys.exit(1)

    lines = path.read_text().strip().split("\n")
    total = len(lines)
    print(f"Total requests: {total}")

    entries = []
    for line in lines:
        parts = line.split()
        entries.append({
            "date": parts[0],
            "time": parts[1],
            "method": parts[2],
            "path": parts[3],
            "status": int(parts[4]),
        })

    print("\nStatus code distribution:")
    status_counts = Counter(e["status"] for e in entries)
    for code, count in status_counts.most_common():
        pct = count * 100 / total
        print(f"  {code}: {count} ({pct:.1f}%)")

    print("\nHTTP method distribution:")
    method_counts = Counter(e["method"] for e in entries)
    for method, count in method_counts.most_common():
        print(f"  {method}: {count}")

    print("\nError requests (4xx/5xx):")
    for i, e in enumerate(entries):
        if e["status"] >= 400:
            print(f"  {lines[i]}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 analyze.py <logfile>", file=sys.stderr)
        sys.exit(1)
    analyze_log(sys.argv[1])
PYTHON_VER

    echo ""
    echo "--- Python版: 同じアクセスログ解析 ---"
    python3 "${WORKDIR}/analyze_python.py" "${WORKDIR}/access.log"
else
    echo ""
    echo "(python3 が見つからないため Python版はスキップ)"
fi

echo ""
echo "=== 比較のポイント ==="
echo "bash版:   パイプとawk/sortの連携で簡潔。だがパースが脆い"
echo "Python版: 構造化されたデータ処理。テスト・拡張が容易"

# -------------------------------------------
# セクション7: まとめ
# -------------------------------------------
echo ""
echo "============================================"
echo " ハンズオン完了"
echo "============================================"
echo ""
echo "作成されたファイル:"
echo "  ${WORKDIR}/trap_demo.sh            -- trap デモスクリプト"
if [ -f "${WORKDIR}/string_utils.sh" ]; then
echo "  ${WORKDIR}/string_utils.sh         -- テスト対象の関数ライブラリ"
echo "  ${WORKDIR}/test_string_utils.bats  -- bats テストファイル"
fi
if [ -f "${WORKDIR}/bad_script.sh" ]; then
echo "  ${WORKDIR}/bad_script.sh           -- ShellCheck 解析対象（問題あり）"
echo "  ${WORKDIR}/good_script.sh          -- ShellCheck 解析対象（修正済み）"
fi
echo "  ${WORKDIR}/access.log              -- テスト用アクセスログ"
echo "  ${WORKDIR}/analyze_bash.sh         -- bash版ログ解析"
if [ -f "${WORKDIR}/analyze_python.py" ]; then
echo "  ${WORKDIR}/analyze_python.py       -- Python版ログ解析"
fi
echo ""
echo "追加演習:"
echo "  1. trap_demo.sh の ERR トラップ版を作ってみる"
echo "  2. string_utils.sh にテストケースを追加する"
echo "  3. analyze_bash.sh を POSIX sh 準拠に書き換えてみる"
echo "  4. analyze_bash.sh を Alpine コンテナで実行してみる:"
echo "     docker run --rm -v ${WORKDIR}:/work alpine:3.21 /bin/sh /work/analyze_bash.sh /work/access.log"
