#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/command-line-handson-17"

echo "============================================"
echo " 第17回ハンズオン: Rust製CLIツールの波"
echo " ripgrep, fd, bat, eza"
echo "============================================"
echo ""

# --------------------------------------------------
echo ">>> 環境セットアップ"
# --------------------------------------------------
apt-get update -qq && apt-get install -y -qq grep ripgrep fd-find bat git curl time > /dev/null 2>&1
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "  ripgrep: $(rg --version | head -1)"
echo "  fd:      $(fdfind --version)"
echo "  bat:     $(batcat --version)"
echo ""

# --------------------------------------------------
echo ">>> 演習1: ripgrep対grepのベンチマーク"
# --------------------------------------------------
echo ""

echo "--- テスト用ファイルの生成（500ファイル）---"
mkdir -p "${WORKDIR}/bench/src"
for i in $(seq 1 500); do
    cat > "${WORKDIR}/bench/src/file_${i}.txt" << 'CONTENT'
This is a sample file for benchmarking.
Each file contains multiple lines of text.
Some lines contain the word ERROR that we want to find.
Other lines contain WARNING messages.
The quick brown fox jumps over the lazy dog.
Another ERROR occurred in the processing pipeline.
DEBUG: entering function process_request
INFO: request completed successfully
ERROR: connection timeout after 30 seconds
This line is just filler text for the benchmark.
CONTENT
done
echo "  500ファイル生成完了"
echo ""

echo "--- grep: 再帰検索 ---"
time grep -rn "ERROR" "${WORKDIR}/bench/src/" > /dev/null 2>&1
echo ""

echo "--- ripgrep: 再帰検索 ---"
time rg "ERROR" "${WORKDIR}/bench/src/" > /dev/null 2>&1
echo ""

echo "--- 出力フォーマットの比較 ---"
echo ""
echo "[grepの出力（先頭3行）]"
grep -rn "ERROR" "${WORKDIR}/bench/src/" | head -3
echo ""
echo "[ripgrepの出力（先頭3行）]"
rg "ERROR" "${WORKDIR}/bench/src/" | head -3
echo ""

echo "→ ripgrepはファイル名をグループ化し、マッチ部分をハイライト表示する。"
echo ""

# --------------------------------------------------
echo ">>> 演習2: fd対findの比較"
# --------------------------------------------------
echo ""

mkdir -p "${WORKDIR}/project"/{src,tests,docs,build,vendor,.hidden}
touch "${WORKDIR}/project/src"/{main.rs,lib.rs,utils.rs}
touch "${WORKDIR}/project/tests"/{test_main.rs,test_lib.rs}
touch "${WORKDIR}/project/docs"/{README.md,CHANGELOG.md}
touch "${WORKDIR}/project/build"/{output.o,debug.log}
touch "${WORKDIR}/project/vendor"/{dep1.rs,dep2.rs}
touch "${WORKDIR}/project/.hidden"/secret.txt

echo "--- find: .rsファイルを検索 ---"
find "${WORKDIR}/project" -name "*.rs" -type f
echo ""

echo "--- fdfind: .rsファイルを検索 ---"
fdfind -e rs . "${WORKDIR}/project"
echo ""

echo "→ fdは隠しファイルをデフォルトでスキップし、出力を色付きで表示する。"
echo "  findの高度な機能（-exec, -perm等）が必要な場面ではfindを使えばよい。"
echo ""

# --------------------------------------------------
echo ">>> 演習3: bat対catの比較"
# --------------------------------------------------
echo ""

cat > "${WORKDIR}/sample.py" << 'PYTHON'
#!/usr/bin/env python3
"""Sample script for bat demonstration."""

import sys
from pathlib import Path

def process_file(path: Path) -> list[str]:
    """Read a file and return non-empty lines."""
    if not path.exists():
        raise FileNotFoundError(f"No such file: {path}")

    with open(path) as f:
        return [line.strip() for line in f if line.strip()]

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: script.py <file>", file=sys.stderr)
        sys.exit(1)

    result = process_file(Path(sys.argv[1]))
    for line in result:
        print(line)
PYTHON

echo "--- catの出力 ---"
cat "${WORKDIR}/sample.py"
echo ""

echo "--- batcatの出力（シンタックスハイライト付き）---"
batcat --paging=never "${WORKDIR}/sample.py"
echo ""

echo "--- パイプ時の振る舞い ---"
echo "  batcat sample.py | grep 'def' → プレーンテキストに戻る"
batcat --paging=never "${WORKDIR}/sample.py" | grep "def"
echo ""
echo "→ batはパイプ出力時に自動的にプレーンテキストに戻る。"
echo "  UNIX哲学の「テキストストリーム」との互換性を保つ設計だ。"
echo ""

# --------------------------------------------------
echo ">>> 演習4: デフォルト値の違いを体験する"
# --------------------------------------------------
echo ""

mkdir -p "${WORKDIR}/gitproject"/{src,node_modules/dep,build}
cd "${WORKDIR}/gitproject"
git init -q

echo "ERROR in main source" > src/main.txt
echo "ERROR in dependency" > node_modules/dep/index.txt
echo "ERROR in build output" > build/output.txt
echo "ERROR in root" > root.txt

cat > .gitignore << 'GIT'
node_modules/
build/
GIT

git add -A && git commit -q -m "init"

echo "--- grepの結果（全ファイルを検索）---"
grep -rn "ERROR" .
echo ""

echo "--- ripgrepの結果（.gitignoreを尊重）---"
rg "ERROR" .
echo ""

echo "→ grepはnode_modules/とbuild/も検索する。"
echo "  ripgrepは.gitignoreを読み、これらを自動的にスキップする。"
echo ""

cd "${WORKDIR}"

# --------------------------------------------------
echo ">>> 演習5: モダンCLIツールの組み合わせ"
# --------------------------------------------------
echo ""

echo "--- fdで見つけたファイルをripgrepで検索 ---"
echo '  fdfind -e py . | xargs rg "import"'
fdfind -e py . "${WORKDIR}" | xargs rg "import" 2>/dev/null || echo "  (マッチなし)"
echo ""

echo "--- 実践的なワークフロー例 ---"
echo ""
echo "  1. 特定の拡張子のファイルを検索:"
echo "     rg --type py 'pattern'"
echo ""
echo "  2. 置換のプレビュー:"
echo "     rg 'old_name' --replace 'new_name'"
echo ""
echo "  3. JSON形式で出力:"
echo "     rg --json 'pattern'"
echo ""
echo "  4. fdの結果をバッチ処理:"
echo "     fdfind -e log --changed-within 1d . | xargs wc -l"
echo ""

# --------------------------------------------------
echo "============================================"
echo " まとめ"
echo "============================================"
echo ""
echo "1. ripgrepはSIMD最適化、並列走査、.gitignore互換で高速検索を実現"
echo "2. fdは日常的なファイル検索を簡潔な構文で実現する"
echo "3. batはシンタックスハイライト付きのcat代替でパイプ互換性を保持"
echo "4. デフォルト値の再設計が、タイプ量と認知的負荷を大幅に削減"
echo "5. coreutilsを排除するのではなく、対話的使用での体験を改善する"
