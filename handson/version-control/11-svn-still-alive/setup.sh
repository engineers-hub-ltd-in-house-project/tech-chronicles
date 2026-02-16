#!/bin/bash
# =============================================================================
# 第11回ハンズオン：svn:externalsとgit submoduleの比較体験
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

WORKDIR="${HOME}/vcs-handson-11"

echo "=== 第11回ハンズオン：svn:externalsとgit submoduleの比較体験 ==="
echo ""

# 既存ディレクトリのクリーンアップ
if [ -d "${WORKDIR}" ]; then
  rm -rf "${WORKDIR}"
fi
mkdir -p "${WORKDIR}"

# --- 演習1: svn:externals で外部リポジトリを組み込む ---
echo "[演習1] svn:externals で外部リポジトリを組み込む"

# 共有ライブラリ用リポジトリの作成
svnadmin create "${WORKDIR}/shared-repo"
SHARED_URL="file://${WORKDIR}/shared-repo"

svn mkdir -m "Create trunk" "${SHARED_URL}/trunk" --quiet
svn checkout "${SHARED_URL}/trunk" "${WORKDIR}/shared-wc" --quiet
cd "${WORKDIR}/shared-wc"

# 共有ライブラリにモジュールを追加
mkdir -p utils math
cat > utils/string-helpers.sh << 'LIBEOF'
#!/bin/bash
to_upper() { echo "$1" | tr '[:lower:]' '[:upper:]'; }
to_lower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }
LIBEOF

cat > math/calc.sh << 'LIBEOF'
#!/bin/bash
add() { echo $(( $1 + $2 )); }
multiply() { echo $(( $1 * $2 )); }
LIBEOF

svn add utils math --quiet
svn commit -m "Add shared library modules" --quiet

# メインプロジェクト用リポジトリの作成
svnadmin create "${WORKDIR}/main-repo"
MAIN_URL="file://${WORKDIR}/main-repo"

svn mkdir -m "Create trunk" "${MAIN_URL}/trunk" --quiet
svn checkout "${MAIN_URL}/trunk" "${WORKDIR}/main-wc" --quiet
cd "${WORKDIR}/main-wc"

cat > app.sh << 'APPEOF'
#!/bin/bash
source lib/utils/string-helpers.sh
echo "Hello from main project"
echo "Upper: $(to_upper 'hello world')"
APPEOF

svn add app.sh --quiet
svn commit -m "Add main application" --quiet

# svn:externals の設定（サブディレクトリだけを参照）
echo "--- svn:externals を設定 ---"
svn propset svn:externals \
  "${SHARED_URL}/trunk/utils lib/utils" . --quiet
svn commit -m "Add externals for shared utils" --quiet

# svn update で外部リポジトリが自動取得される
echo ""
echo "--- svn update で外部リポジトリを取得 ---"
svn update --quiet
echo ""
echo "--- ディレクトリ構造 ---"
find . -not -path '*/.svn/*' -type f | sort
echo ""
echo "-> lib/utils/ に共有ライブラリのutils部分だけが取得された"
echo "-> math/ は取得されていない（サブディレクトリ単位の参照）"
echo ""

# --- 演習2: svn:externals の自動更新 ---
echo "[演習2] svn:externals の自動更新"

# 共有ライブラリを更新
cd "${WORKDIR}/shared-wc"
cat >> utils/string-helpers.sh << 'LIBEOF'
trim() { echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'; }
LIBEOF
svn commit -m "Add trim function to string-helpers" --quiet

# メインプロジェクトでsvn update
cd "${WORKDIR}/main-wc"
echo ""
echo "--- svn update を実行 ---"
svn update 2>&1
echo ""
echo "--- 更新後の string-helpers.sh ---"
cat lib/utils/string-helpers.sh
echo ""
echo "-> svn update だけで外部リポジトリの最新変更が自動取得された"
echo "-> 追加の操作（submodule update等）は不要"
echo ""

# --- 演習3: git submodule で同じことを試みる ---
echo "[演習3] git submodule で同じことを試みる"

# 共有ライブラリ用Gitリポジトリ
mkdir -p "${WORKDIR}/git-shared"
cd "${WORKDIR}/git-shared"
git init --bare --quiet

mkdir -p "${WORKDIR}/git-shared-wc"
cd "${WORKDIR}/git-shared-wc"
git init --quiet
git config user.email "handson@example.com"
git config user.name "Handson User"

mkdir -p utils math
cat > utils/string-helpers.sh << 'LIBEOF'
#!/bin/bash
to_upper() { echo "$1" | tr '[:lower:]' '[:upper:]'; }
to_lower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }
LIBEOF

cat > math/calc.sh << 'LIBEOF'
#!/bin/bash
add() { echo $(( $1 + $2 )); }
multiply() { echo $(( $1 * $2 )); }
LIBEOF

git add -A && git commit -m "Add shared library modules" --quiet
git remote add origin "${WORKDIR}/git-shared"
git push origin HEAD --quiet 2>/dev/null

# メインプロジェクト用Gitリポジトリ
mkdir -p "${WORKDIR}/git-main"
cd "${WORKDIR}/git-main"
git init --quiet
git config user.email "handson@example.com"
git config user.name "Handson User"

cat > app.sh << 'APPEOF'
#!/bin/bash
echo "Hello from main project"
APPEOF

git add app.sh && git commit -m "Add main application" --quiet

# git submodule でリポジトリ全体を追加
echo "--- git submodule add で共有リポジトリを追加 ---"
git submodule add "${WORKDIR}/git-shared" lib/shared --quiet 2>&1
git commit -m "Add shared library as submodule" --quiet

echo ""
echo "--- ディレクトリ構造 ---"
find lib/ -type f -not -path '*/.git/*' | sort
echo ""
echo "-> リポジトリ全体（utils/ と math/ の両方）が取得された"
echo "-> svn:externals のようにサブディレクトリだけを参照することはできない"
echo ""

# --- 演習4: git submodule の手動更新 ---
echo "[演習4] git submodule の手動更新"

# 共有ライブラリを更新
cd "${WORKDIR}/git-shared-wc"
cat >> utils/string-helpers.sh << 'LIBEOF'
trim() { echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'; }
LIBEOF
git add -A && git commit -m "Add trim function" --quiet
MAIN_BRANCH=$(git branch --show-current)
git push origin "${MAIN_BRANCH}" --quiet 2>/dev/null

# メインプロジェクトで確認
cd "${WORKDIR}/git-main"
echo "--- git pull をしても submodule は更新されない ---"
cat lib/shared/utils/string-helpers.sh
echo ""
echo "-> trim 関数がまだ存在しない"

echo ""
echo "--- git submodule update --remote を実行 ---"
git submodule update --remote --quiet 2>/dev/null
echo ""
cat lib/shared/utils/string-helpers.sh
echo ""
echo "-> trim 関数が取得された"
echo ""
echo "--- しかし、この変更を親リポジトリにコミットする必要がある ---"
git status
echo ""
echo "-> lib/shared に 'new commits' がある"
echo "-> git add && git commit で親リポジトリの参照を更新する必要がある"

echo ""
echo "=== ハンズオン完了 ==="
echo ""
echo "このハンズオンで確認したこと:"
echo "  1. svn:externals はサブディレクトリ単位で外部リポジトリを参照できる"
echo "  2. svn update だけで外部リポジトリの最新変更が自動取得される"
echo "  3. git submodule はリポジトリ全体の参照のみ（サブディレクトリ不可）"
echo "  4. git submodule の更新には明示的な操作と親リポジトリのコミットが必要"
echo "  5. どちらが正しいかではなく、プロジェクト要件に応じた選択が重要"
