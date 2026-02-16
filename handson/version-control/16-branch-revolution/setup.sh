#!/bin/bash
# =============================================================================
# 第16回ハンズオン：ブランチの革命——低レベルコマンドでブランチを操作する
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

WORKDIR="${HOME}/vcs-handson-16"

echo "=== 第16回ハンズオン：低レベルコマンドでブランチを操作する ==="
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

# --- 演習1: ブランチの正体を確認する ---
echo "[演習1] ブランチの正体を確認する"
echo ""

git init --quiet branch-demo
cd branch-demo

# 最初のコミット
echo "Hello, World!" > hello.txt
git add hello.txt
git commit --quiet -m "Initial commit"

echo "--- .git/HEAD の内容 ---"
cat .git/HEAD
echo ""
echo "-> HEADはsymbolic reference: refs/heads/mainを指している"
echo ""

echo "--- .git/refs/heads/main の内容 ---"
cat .git/refs/heads/main
echo ""
MAIN_HASH=$(cat .git/refs/heads/main)
echo "-> mainブランチはcommit ${MAIN_HASH} を指す41バイトのファイル"
echo ""

echo "--- mainブランチのファイルサイズ ---"
wc -c .git/refs/heads/main
echo "-> 41バイト = SHA-1(40文字) + 改行(1文字)"
echo ""

# 低レベルコマンドでブランチ作成
echo "--- 低レベルコマンドでブランチを作成 ---"
cp .git/refs/heads/main .git/refs/heads/feature-manual
echo "refs/heads/feature-manual を直接作成"
echo ""

echo "--- git branch の出力 ---"
git branch
echo ""
echo "-> ファイルを書くだけでブランチが作れる"
echo "   git branchはrefs/heads/以下のファイルを列挙しているに過ぎない"
echo ""

# --- 演習2: HEADの動きを追跡する ---
echo "============================================"
echo "[演習2] HEADの動きを追跡する"
echo ""

echo "--- ブランチ切り替え前のHEAD ---"
cat .git/HEAD
echo ""

git checkout --quiet feature-manual

echo "--- ブランチ切り替え後のHEAD ---"
cat .git/HEAD
echo ""
echo "-> HEADの参照先がmainからfeature-manualに変わった"
echo ""

# feature-manualでコミット
echo "Feature work" >> hello.txt
git add hello.txt
git commit --quiet -m "Add feature work"

echo "--- feature-manualの指す先 ---"
cat .git/refs/heads/feature-manual
echo ""
echo "--- mainの指す先（変わっていない）---"
cat .git/refs/heads/main
echo ""
echo "-> コミットによりfeature-manualのポインタだけが進んだ"
echo "   mainは元のコミットを指したまま"
echo ""

# detached HEADを体験
MAIN_HASH=$(cat .git/refs/heads/main)
git checkout --quiet "${MAIN_HASH}"

echo "--- detached HEAD状態 ---"
cat .git/HEAD
echo ""
echo "-> HEADがsymbolic referenceではなく、SHA-1を直接格納している"
echo "   これがdetached HEAD状態"
echo ""

git checkout --quiet main

# --- 演習3: 3-way mergeを手動で確認する ---
echo "============================================"
echo "[演習3] 3-way mergeを手動で確認する"
echo ""

cd "${WORKDIR}"
git init --quiet merge-demo
cd merge-demo
git config user.email "handson@example.com"
git config user.name "Handson User"

# 共通祖先を作成
cat > app.py << 'EOF'
# app.py - サンプルアプリケーション
def main():
    print("Hello, World!")
    print("Version 1.0")

def helper():
    return 42

if __name__ == "__main__":
    main()
EOF
git add app.py
git commit --quiet -m "Base version"
BASE_HASH=$(git rev-parse HEAD)

# main で変更
cat > app.py << 'EOF'
# app.py - サンプルアプリケーション
def main():
    print("Hello, World!")
    print("Version 2.0")

def helper():
    return 42

if __name__ == "__main__":
    main()
EOF
git add app.py
git commit --quiet -m "Update version to 2.0"

# feature で別の変更
git checkout --quiet -b feature "${BASE_HASH}"
cat > app.py << 'EOF'
# app.py - サンプルアプリケーション
def main():
    print("Hello, World!")
    print("Version 1.0")

def helper():
    return 100

if __name__ == "__main__":
    main()
EOF
git add app.py
git commit --quiet -m "Update helper return value"

echo "--- マージ前の状態 ---"
echo "main: Version 2.0に変更（行4）"
echo "feature: helperの戻り値を100に変更（行7）"
echo "共通祖先: ${BASE_HASH:0:7}"
echo ""

echo "--- 共通祖先の確認 ---"
MERGE_BASE=$(git merge-base main feature)
echo "git merge-base main feature = ${MERGE_BASE:0:7}"
echo ""

git checkout --quiet main
echo "--- マージ実行 ---"
git merge --no-edit feature
echo ""

echo "--- マージ結果 ---"
cat app.py
echo ""
echo "-> 行4: Version 2.0（mainの変更が採用）"
echo "   行7: return 100（featureの変更が採用）"
echo "   3-way mergeにより、競合しない変更が自動統合された"
echo ""

echo "--- マージコミットの親 ---"
git cat-file -p HEAD | grep parent
echo ""
echo "-> マージコミットは2つのparentを持つ"
echo "   これがgitのDAG構造にマージ追跡が内在する仕組み"
echo ""

# --- 演習4: rebaseの内部動作を確認する ---
echo "============================================"
echo "[演習4] rebaseの内部動作を確認する"
echo ""

cd "${WORKDIR}"
git init --quiet rebase-demo
cd rebase-demo
git config user.email "handson@example.com"
git config user.name "Handson User"

# 共通の履歴を作成
echo "Line 1" > file.txt
git add file.txt
git commit --quiet -m "Commit A"

echo "Line 2" >> file.txt
git add file.txt
git commit --quiet -m "Commit B"

# featureブランチを作成
git checkout --quiet -b feature

echo "Feature line 1" >> file.txt
git add file.txt
git commit --quiet -m "Commit D (feature)"
D_HASH=$(git rev-parse HEAD)

echo "Feature line 2" >> file.txt
git add file.txt
git commit --quiet -m "Commit E (feature)"
E_HASH=$(git rev-parse HEAD)

# mainを進める
git checkout --quiet main
echo "Main line 1" > main.txt
git add main.txt
git commit --quiet -m "Commit C (main)"

echo "--- rebase前の状態 ---"
echo "main:    A - B - C"
echo "feature: A - B - D - E"
echo ""
echo "D のSHA-1: ${D_HASH:0:12}"
echo "E のSHA-1: ${E_HASH:0:12}"
echo ""

# rebaseを実行
git checkout --quiet feature
git rebase --quiet main

D_NEW=$(git rev-parse HEAD~1)
E_NEW=$(git rev-parse HEAD)

echo "--- rebase後の状態 ---"
echo "feature: A - B - C - D' - E'"
echo ""
echo "D' のSHA-1: ${D_NEW:0:12}"
echo "E' のSHA-1: ${E_NEW:0:12}"
echo ""
echo "--- SHA-1の比較 ---"
echo "D  (rebase前): ${D_HASH:0:12}"
echo "D' (rebase後): ${D_NEW:0:12}"
echo ""
if [ "${D_HASH}" != "${D_NEW}" ]; then
  echo "-> SHA-1が異なる。rebaseは元のコミットの「コピー」を作成する"
  echo "   内容は同じだが、parentが異なるため、別のオブジェクトになる"
  echo "   これが「履歴の書き換え」の正体"
else
  echo "-> （一致した場合：予期しない結果）"
fi
echo ""

echo "--- D'の内容を確認 ---"
echo "tree:"
git cat-file -p "${D_NEW}" | head -1
echo "parent:"
git cat-file -p "${D_NEW}" | grep parent
echo ""
echo "-> parentがmainのCommit C を指している"
echo "   元のDはCommit Bをparentとしていた"
echo "   parentが変わったので、SHA-1も変わった"
echo ""

echo "============================================"
echo "全演習完了"
echo "作業ディレクトリ: ${WORKDIR}"
