#!/bin/bash
# =============================================================================
# 第17回ハンズオン：マージの内部を追跡する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: git
# 推奨環境: docker run -it --rm ubuntu:24.04 bash
#            apt update && apt install -y git
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-17"

echo "=== 第17回ハンズオン：マージの内部を追跡する ==="
echo ""

# 既存ディレクトリのクリーンアップ
if [ -d "${WORKDIR}" ]; then
  rm -rf "${WORKDIR}"
fi
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# gitの設定（Docker環境用）
git config --global user.email "handson@example.com" 2>/dev/null || true
git config --global user.name "Handson User" 2>/dev/null || true
git config --global init.defaultBranch main 2>/dev/null || true

# --- 演習1: コンフリクト時の内部状態を観察する ---
echo "[演習1] コンフリクト時の内部状態を観察する"
echo ""

git init --quiet conflict-demo
cd conflict-demo

# 共通祖先（base）を作成
cat > app.py << 'PYEOF'
# app.py - バージョン管理デモ
def greet(name):
    return f"Hello, {name}!"

def calculate(x, y):
    return x + y

if __name__ == "__main__":
    print(greet("World"))
    print(calculate(1, 2))
PYEOF
git add app.py
git commit --quiet -m "Base version"

# mainブランチで変更
cat > app.py << 'PYEOF'
# app.py - バージョン管理デモ
def greet(name):
    return f"Hi, {name}! Welcome!"

def calculate(x, y):
    return x + y

if __name__ == "__main__":
    print(greet("World"))
    print(calculate(1, 2))
PYEOF
git add app.py
git commit --quiet -m "Change greeting message (main)"

# featureブランチで同じ箇所を異なる内容に変更
git checkout --quiet -b feature HEAD~1
cat > app.py << 'PYEOF'
# app.py - バージョン管理デモ
def greet(name):
    return f"Good morning, {name}!"

def calculate(x, y):
    return x + y

if __name__ == "__main__":
    print(greet("World"))
    print(calculate(1, 2))
PYEOF
git add app.py
git commit --quiet -m "Change greeting message (feature)"

# mainに戻ってマージ（コンフリクトが発生する）
git checkout --quiet main
echo "--- マージを実行（コンフリクトが発生する）---"
git merge feature || true
echo ""

echo "--- .git/MERGE_HEAD の内容 ---"
cat .git/MERGE_HEAD
echo "-> マージ対象のコミットSHA-1"
echo ""

echo "--- .git/MERGE_MSG の内容 ---"
cat .git/MERGE_MSG
echo ""

echo "--- インデックスのstage番号（git ls-files -u）---"
git ls-files -u
echo ""
echo "-> stage 1=共通祖先, stage 2=ours(HEAD), stage 3=theirs(MERGE_HEAD)"
echo ""

echo "--- 各stageの内容 ---"
echo "[stage 1: 共通祖先（base）]"
git show :1:app.py | head -4
echo "..."
echo ""
echo "[stage 2: ours（HEAD / main）]"
git show :2:app.py | head -4
echo "..."
echo ""
echo "[stage 3: theirs（MERGE_HEAD / feature）]"
git show :3:app.py | head -4
echo "..."
echo ""

echo "--- 作業ディレクトリのコンフリクトマーカー ---"
cat app.py
echo ""
echo "-> <<<<<<< HEAD と >>>>>>> feature の間がコンフリクト箇所"

# コンフリクトを解消
echo ""
echo "--- コンフリクトを解消する ---"
cat > app.py << 'PYEOF'
# app.py - バージョン管理デモ
def greet(name):
    return f"Hi, {name}! Good morning!"

def calculate(x, y):
    return x + y

if __name__ == "__main__":
    print(greet("World"))
    print(calculate(1, 2))
PYEOF
git add app.py

echo "--- 解消後のインデックス（git ls-files -s app.py）---"
git ls-files -s app.py
echo ""
echo "-> stage 0に統合された（コンフリクト解消完了）"

git commit --quiet --no-edit
echo ""
echo "--- マージコミットの親 ---"
git cat-file -p HEAD | grep parent
echo "-> 2つのparentを持つマージコミットが作成された"

# --- 演習2: cherry-pickが3-way mergeであることを確認する ---
echo ""
echo "============================================================"
echo "[演習2] cherry-pickが3-way mergeであることを確認する"
echo ""

cd "${WORKDIR}"
git init --quiet cherry-demo
cd cherry-demo
git config user.email "handson@example.com"
git config user.name "Handson User"

# ベースとなるコードを作成
cat > util.py << 'PYEOF'
# util.py
def add(a, b):
    return a + b

def multiply(a, b):
    return a * b
PYEOF
git add util.py
git commit --quiet -m "Initial util.py"

# featureブランチでmultiplyを変更
git checkout --quiet -b feature
cat > util.py << 'PYEOF'
# util.py
def add(a, b):
    return a + b

def multiply(a, b):
    """Multiply two numbers."""
    return a * b
PYEOF
git add util.py
git commit --quiet -m "Add docstring to multiply"
FEATURE_COMMIT=$(git rev-parse HEAD)

# さらにfeatureでaddも変更
cat > util.py << 'PYEOF'
# util.py
def add(a, b):
    """Add two numbers."""
    return a + b

def multiply(a, b):
    """Multiply two numbers."""
    return a * b
PYEOF
git add util.py
git commit --quiet -m "Add docstring to add"

# mainに戻り、独自の変更を加える
git checkout --quiet main
cat > util.py << 'PYEOF'
# util.py
def add(a, b):
    return a + b

def multiply(a, b):
    return a * b

def subtract(a, b):
    return a - b
PYEOF
git add util.py
git commit --quiet -m "Add subtract function"

echo "--- cherry-pick前のmainのutil.py ---"
cat util.py
echo ""

echo "--- cherry-pickするコミット（multiplyにdocstring追加）---"
echo "コミット: ${FEATURE_COMMIT:0:12}"
git log --oneline -1 "${FEATURE_COMMIT}"
echo ""

# cherry-pickを実行
echo "--- cherry-pickを実行 ---"
git cherry-pick "${FEATURE_COMMIT}"
echo ""

echo "--- cherry-pick後のutil.py ---"
cat util.py
echo ""
echo "-> multiplyへのdocstring追加がcherry-pickされた"
echo "   mainで追加したsubtract関数はそのまま残っている"
echo "   これは単純なパッチ適用ではなく、3-way mergeの結果"
echo ""
echo "   内部動作:"
echo "   - base: cherry-pickコミットの親（Initial util.py）"
echo "   - ours: 現在のHEAD（subtract追加済み）"
echo "   - theirs: cherry-pickコミット（docstring追加済み）"
echo "   -> baseからoursへの変更（subtract追加）と"
echo "      baseからtheirsへの変更（docstring追加）を3-way mergeで統合"

# --- 演習3: merge-baseの動作を確認する ---
echo ""
echo "============================================================"
echo "[演習3] merge-baseの動作を確認する"
echo ""

cd "${WORKDIR}"
git init --quiet mergebase-demo
cd mergebase-demo
git config user.email "handson@example.com"
git config user.name "Handson User"

# 共通の履歴を構築
echo "v1" > file.txt
git add file.txt
git commit --quiet -m "Commit A"
A=$(git rev-parse HEAD)

echo "v2" > file.txt
git add file.txt
git commit --quiet -m "Commit B"
B=$(git rev-parse HEAD)

# 2つのブランチに分岐
git checkout --quiet -b branch-1
echo "v3-branch1" > file.txt
git add file.txt
git commit --quiet -m "Commit C (branch-1)"
C=$(git rev-parse HEAD)

git checkout --quiet main
echo "v3-main" > file.txt
git add file.txt
git commit --quiet -m "Commit D (main)"
D=$(git rev-parse HEAD)

echo "--- コミットグラフ ---"
echo "  A($(echo "${A}" | cut -c1-7)) <- B($(echo "${B}" | cut -c1-7)) <- D($(echo "${D}" | cut -c1-7))  [main]"
echo "                                     +-- C($(echo "${C}" | cut -c1-7))  [branch-1]"
echo ""

echo "--- merge-base main branch-1 ---"
MERGE_BASE=$(git merge-base main branch-1)
echo "${MERGE_BASE}"
echo ""
if [ "${MERGE_BASE}" = "${B}" ]; then
  echo "-> merge-baseはB（分岐点）= $(echo "${B}" | cut -c1-7)"
  echo "   これが3-way mergeの共通祖先として使用される"
else
  echo "-> 予期しない結果"
fi
echo ""

# マージしてからさらにmerge-baseを確認
echo "--- マージ後のmerge-base ---"
git merge --quiet --no-edit -X ours branch-1
M=$(git rev-parse HEAD)

echo "マージ後:"
echo "  A <- B <- D <- M($(echo "${M}" | cut -c1-7))  [main]"
echo "             +-- C --+             [branch-1]"
echo ""

# branch-1をさらに進める
git checkout --quiet branch-1
echo "v4-branch1" > file.txt
git add file.txt
git commit --quiet -m "Commit E (branch-1)"
E=$(git rev-parse HEAD)

git checkout --quiet main
echo "v4-main" > file.txt
git add file.txt
git commit --quiet -m "Commit F (main)"
F=$(git rev-parse HEAD)

echo "さらに進めた後:"
echo "  ... <- D <- M <- F($(echo "${F}" | cut -c1-7))  [main]"
echo "         +-- C --+  <- E($(echo "${E}" | cut -c1-7))  [branch-1]"
echo ""

NEW_BASE=$(git merge-base main branch-1)
echo "新しいmerge-base: $(echo "${NEW_BASE}" | cut -c1-7)"
echo ""
echo "-> 一度マージした後は、共通祖先がマージポイントに進む"
echo "   これがgitのDAG構造によるマージ追跡の仕組み"

# --- 演習4: diff3スタイルのコンフリクト表示 ---
echo ""
echo "============================================================"
echo "[演習4] diff3スタイルのコンフリクト表示"
echo ""

cd "${WORKDIR}"
git init --quiet diff3-demo
cd diff3-demo
git config user.email "handson@example.com"
git config user.name "Handson User"

# diff3スタイルを設定
git config merge.conflictStyle diff3

# コンフリクトを生成
echo "original content" > readme.txt
git add readme.txt
git commit --quiet -m "Base"

git checkout --quiet -b feature
echo "feature content" > readme.txt
git add readme.txt
git commit --quiet -m "Feature change"

git checkout --quiet main
echo "main content" > readme.txt
git add readme.txt
git commit --quiet -m "Main change"

echo "--- diff3スタイルでマージ（コンフリクト発生）---"
git merge feature || true
echo ""

echo "--- コンフリクトマーカー（diff3スタイル）---"
cat readme.txt
echo ""
echo '-> ||||||| で区切られた箇所が「共通祖先の内容」'
echo "   共通祖先が見えることで、両者が何を変更したかが明確になる"
echo "   git config merge.conflictStyle diff3 を設定することを推奨する"

echo ""
echo "============================================================"
echo "全演習完了"
echo "============================================================"
