#!/bin/bash
# =============================================================================
# 第10回ハンズオン：Subversionのブランチ・マージとGitの比較体験
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: subversion (svn, svnadmin), git
# 推奨環境: docker run -it --rm ubuntu:24.04 bash
#            apt update && apt install -y subversion git
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-10"

echo "=== 第10回ハンズオン：Subversionのブランチ・マージとGitの比較体験 ==="
echo ""

# 既存ディレクトリのクリーンアップ
if [ -d "${WORKDIR}" ]; then
  rm -rf "${WORKDIR}"
fi
mkdir -p "${WORKDIR}"

# --- 演習1: Subversionでブランチを作成し、マージする ---
echo "[演習1] Subversionでブランチを作成する"

svnadmin create "${WORKDIR}/svnrepo"
REPO_URL="file://${WORKDIR}/svnrepo"

# 標準ディレクトリ構造の作成
svn mkdir -m "Create standard layout" \
  "${REPO_URL}/trunk" \
  "${REPO_URL}/branches" \
  "${REPO_URL}/tags" --quiet

# trunkにファイルを追加
svn checkout "${REPO_URL}/trunk" "${WORKDIR}/svn-wc" --quiet
cd "${WORKDIR}/svn-wc"

cat > util.c << 'EOF'
#include <stdio.h>

void greet(const char *name) {
    printf("Hello, %s!\n", name);
}

int add(int a, int b) {
    return a + b;
}
EOF

cat > main.c << 'EOF'
#include <stdio.h>

extern void greet(const char *name);
extern int add(int a, int b);

int main(void) {
    greet("Subversion");
    printf("1 + 2 = %d\n", add(1, 2));
    return 0;
}
EOF

svn add util.c main.c --quiet
svn commit -m "Add initial source files" --quiet

echo "--- ブランチの作成（svn copy）---"
svn copy "${REPO_URL}/trunk" "${REPO_URL}/branches/feature-x" \
  -m "Create feature-x branch" --quiet
echo "-> ブランチ作成完了（cheap copy: 定数時間）"
echo ""

echo "--- ブランチの作業コピーをチェックアウト ---"
svn checkout "${REPO_URL}/branches/feature-x" \
  "${WORKDIR}/svn-branch" --quiet
echo "-> チェックアウト完了"
echo ""

# --- 演習2: 並行開発とマージ ---
echo "[演習2] 並行開発とマージ"

# ブランチでの変更
cd "${WORKDIR}/svn-branch"
cat > util.c << 'EOF'
#include <stdio.h>
#include <string.h>

void greet(const char *name) {
    printf("Hello, %s! Welcome to branch.\n", name);
}

int add(int a, int b) {
    return a + b;
}

int multiply(int a, int b) {
    return a * b;
}
EOF
svn commit -m "Add multiply function in feature-x" --quiet

# trunkでの変更
cd "${WORKDIR}/svn-wc"
svn update --quiet
cat > main.c << 'EOF'
#include <stdio.h>

extern void greet(const char *name);
extern int add(int a, int b);

int main(void) {
    greet("Subversion user");
    printf("1 + 2 = %d\n", add(1, 2));
    printf("3 + 4 = %d\n", add(3, 4));
    return 0;
}
EOF
svn commit -m "Update main.c with additional calculation" --quiet

# trunkにブランチをマージ
echo ""
echo "--- trunkにfeature-xブランチをマージ ---"
svn update --quiet
svn merge "${REPO_URL}/branches/feature-x" --quiet
echo ""
echo "--- マージ後のsvn status ---"
svn status
echo ""
echo "--- マージで設定されたsvn:mergeinfo ---"
svn propget svn:mergeinfo .
echo ""
echo "-> svn:mergeinfo がディレクトリに設定されている"
echo "-> マージ済みリビジョンが記録されている"
svn commit -m "Merge feature-x into trunk" --quiet
echo ""

# --- 演習3: リネームを含むマージ（ツリーコンフリクト）---
echo "[演習3] リネームを含むマージ（ツリーコンフリクトの再現）"

# 新しいブランチを作成
svn copy "${REPO_URL}/trunk" "${REPO_URL}/branches/refactor" \
  -m "Create refactor branch" --quiet
svn checkout "${REPO_URL}/branches/refactor" \
  "${WORKDIR}/svn-refactor" --quiet

# ブランチでファイルをリネーム
cd "${WORKDIR}/svn-refactor"
svn move util.c helper.c --quiet
svn commit -m "Rename util.c to helper.c" --quiet

# trunkでリネーム前のファイルを変更
cd "${WORKDIR}/svn-wc"
svn update --quiet
cat > util.c << 'EOF'
#include <stdio.h>
#include <string.h>

void greet(const char *name) {
    printf("Hello, %s! Welcome to branch.\n", name);
}

int add(int a, int b) {
    return a + b;
}

int multiply(int a, int b) {
    return a * b;
}

int subtract(int a, int b) {
    return a - b;
}
EOF
svn commit -m "Add subtract function to util.c" --quiet

# マージを試みる → ツリーコンフリクト発生
echo ""
echo "--- refactorブランチをtrunkにマージ ---"
svn update --quiet
svn merge "${REPO_URL}/branches/refactor" 2>&1 || true
echo ""
echo "--- svn status でコンフリクトを確認 ---"
svn status
echo ""
echo "-> 'C' はコンフリクト（ツリーコンフリクト）"
echo "-> Subversionはリネームを追跡できないため、"
echo "   util.cの変更とhelper.cへのリネームを自動的に統合できない"
echo ""
echo "--- コンフリクトを解消してクリーンな状態に戻す ---"
svn revert -R . --quiet 2>/dev/null || true
echo ""

# --- 演習4: 同じシナリオをGitで実行 ---
echo "[演習4] 同じシナリオをGitで実行"

mkdir -p "${WORKDIR}/gitrepo"
cd "${WORKDIR}/gitrepo"
git init --quiet
git config user.email "handson@example.com"
git config user.name "Handson User"

# 初期ファイルの作成
cat > util.c << 'EOF'
#include <stdio.h>
#include <string.h>

void greet(const char *name) {
    printf("Hello, %s! Welcome to branch.\n", name);
}

int add(int a, int b) {
    return a + b;
}

int multiply(int a, int b) {
    return a * b;
}
EOF

cat > main.c << 'EOF'
#include <stdio.h>

extern void greet(const char *name);
extern int add(int a, int b);

int main(void) {
    greet("Git user");
    printf("1 + 2 = %d\n", add(1, 2));
    return 0;
}
EOF

git add util.c main.c
git commit -m "Initial commit" --quiet

# ブランチでファイルをリネーム
git checkout -b refactor --quiet
git mv util.c helper.c
git commit -m "Rename util.c to helper.c" --quiet

# mainブランチでリネーム前のファイルを変更
MAIN_BRANCH=$(git branch --list main master | head -1 | tr -d ' *')
git checkout "${MAIN_BRANCH}" --quiet
cat > util.c << 'EOF'
#include <stdio.h>
#include <string.h>

void greet(const char *name) {
    printf("Hello, %s! Welcome to branch.\n", name);
}

int add(int a, int b) {
    return a + b;
}

int multiply(int a, int b) {
    return a * b;
}

int subtract(int a, int b) {
    return a - b;
}
EOF
git add util.c
git commit -m "Add subtract function to util.c" --quiet

# マージ
echo ""
echo "--- refactorブランチをmainにマージ ---"
git merge refactor --no-edit 2>&1 || true
echo ""
echo "--- git status ---"
git status
echo ""
echo "--- マージ結果の確認 ---"
if [ -f helper.c ]; then
  echo "helper.c が存在する（リネームが追跡された）"
  echo ""
  echo "--- helper.c の内容 ---"
  cat helper.c
  echo ""
  echo "-> Gitはリネームをヒューリスティックに検出し、"
  echo "   util.cへの変更をhelper.cに自動的に適用した"
else
  echo "コンフリクトが発生（手動解決が必要）"
  git status
fi

echo ""
echo "=== ハンズオン完了 ==="
echo ""
echo "このハンズオンで確認したこと:"
echo "  1. Subversionのブランチ作成はcheap copy（定数時間）"
echo "  2. svn:mergeinfo によるマージ追跡の仕組み"
echo "  3. リネームを含むマージでSubversionはツリーコンフリクトが発生する"
echo "  4. Gitはリネームをヒューリスティックに検出し、マージを自動解決できる"
echo "  5. この差は、ブランチを多用する開発スタイルで決定的な意味を持つ"
