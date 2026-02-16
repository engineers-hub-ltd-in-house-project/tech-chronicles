#!/bin/bash
# =============================================================================
# 第14回ハンズオン：gitの最初のコミットに触れる——1,000行のコードが変えた世界
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: git, curl
# 推奨環境: docker run -it --rm ubuntu:24.04 bash
#            apt update && apt install -y git curl
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-14"

echo "=== 第14回ハンズオン：gitの最初のコミットに触れる ==="
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

# --- 演習1: gitの最初のコミットを読む ---
echo "[演習1] gitの最初のコミットを読む"
echo ""

# git自身のリポジトリをクローン
echo "gitの公式リポジトリをクローン中（--bare で最小限のデータのみ）..."
git clone --bare https://github.com/git/git.git git-source.git 2>&1 | tail -3
echo ""

# 最初のコミットのハッシュを取得
FIRST_COMMIT=$(git --git-dir=git-source.git rev-list --max-parents=0 HEAD | tail -1)
echo "gitの最初のコミット:"
git --git-dir=git-source.git log --format="  ハッシュ: %H%n  著者: %an <%ae>%n  日付: %ai%n  メッセージ: %s" "${FIRST_COMMIT}"
echo ""

# 最初のコミットに含まれるファイル一覧
echo "--- 最初のコミットに含まれるファイル ---"
git --git-dir=git-source.git ls-tree --name-only "${FIRST_COMMIT}"
echo ""
echo "-> わずか10ファイル。これがgitの全てだった"
echo ""

# READMEの内容を表示
echo "--- 最初のREADMEの内容 ---"
git --git-dir=git-source.git show "${FIRST_COMMIT}:README" | head -30
echo ""
echo "-> 'GIT - the stupid content tracker' という冒頭に注目"
echo "-> gitの名前の由来を自嘲的に説明している"
echo "-> この「愚直さ」がgitの設計哲学"
echo ""

# 最初の1ヶ月の開発速度
echo "--- 2005年4月のコミット活動 ---"
APRIL_COUNT=$(git --git-dir=git-source.git log --oneline --after="2005-04-01" --before="2005-05-01" | wc -l)
echo "2005年4月のコミット数: ${APRIL_COUNT}"
echo ""

# --- 演習2: 低レベルコマンドでgitオブジェクトを手動作成する ---
echo "[演習2] 低レベルコマンドでgitオブジェクトを手動作成する"
echo ""

# 新しいリポジトリを初期化
mkdir -p "${WORKDIR}/manual-git"
cd "${WORKDIR}/manual-git"
git init --quiet

echo "--- Step 1: blobオブジェクトの作成 ---"
echo "gitの初期コマンド 'update-cache' に相当する操作を、低レベルで行う"
echo ""

# ファイルの内容からblobオブジェクトを作成
BLOB_HASH=$(echo "Hello, this is the content of my file." | git hash-object -w --stdin)
echo "作成されたblobオブジェクト: ${BLOB_HASH}"
echo ""

# blobの内容を確認（初期の cat-file に相当）
echo "--- blobの内容（git cat-file -p で表示）---"
git cat-file -p "${BLOB_HASH}"
echo ""

echo "--- blobの種類（git cat-file -t で確認）---"
git cat-file -t "${BLOB_HASH}"
echo ""
echo "-> 内容のSHA-1ハッシュがオブジェクトの識別子になる"
echo "-> 同じ内容なら、いつ・どこで作成しても同じハッシュ値"
echo ""

echo "--- Step 2: treeオブジェクトの作成 ---"
echo "gitの初期コマンド 'write-tree' に相当する操作を行う"
echo ""

# blobをインデックスに追加
git update-index --add --cacheinfo 100644 "${BLOB_HASH}" hello.txt

# インデックスからtreeオブジェクトを作成
TREE_HASH=$(git write-tree)
echo "作成されたtreeオブジェクト: ${TREE_HASH}"
echo ""

# treeの内容を確認
echo "--- treeの内容 ---"
git cat-file -p "${TREE_HASH}"
echo ""
echo "-> treeはディレクトリ構造を表現する"
echo "-> 各エントリは（パーミッション、種類、ハッシュ、ファイル名）の組"
echo ""

echo "--- Step 3: commitオブジェクトの作成 ---"
echo "gitの初期コマンド 'commit-tree' に相当する操作を行う"
echo ""

# commitオブジェクトを作成
COMMIT_HASH=$(echo "My first manual commit" | git commit-tree "${TREE_HASH}")
echo "作成されたcommitオブジェクト: ${COMMIT_HASH}"
echo ""

# commitの内容を確認
echo "--- commitの内容 ---"
git cat-file -p "${COMMIT_HASH}"
echo ""
echo "-> commitはtreeへのポインタ、著者情報、メッセージを持つ"
echo "-> これがgitの履歴の最小単位"
echo ""

echo "--- Step 4: ブランチポインタの更新 ---"
echo ""

# mainブランチをこのcommitに向ける
git update-ref refs/heads/main "${COMMIT_HASH}"

# 結果を確認
echo "--- git log で確認 ---"
git log --oneline
echo ""
echo "-> 低レベルコマンドだけで、完全なgitコミットを作成した"
echo "-> git add + git commit は、上記の操作を自動化したもの"
echo "-> gitの「陶器（porcelain）」コマンドの裏では、"
echo "   「配管（plumbing）」コマンドが動いている"
echo ""

# --- 演習3: 内容アドレッシングの体験 ---
echo "[演習3] 内容アドレッシングの体験——同じ内容は同じハッシュ"
echo ""

cd "${WORKDIR}/manual-git"

echo "--- 同じ内容のファイルが同じハッシュを持つことを確認 ---"
echo ""

# 同じ内容で異なるファイル名のblobを作成
HASH_A=$(echo "Identical content" | git hash-object -w --stdin)
HASH_B=$(echo "Identical content" | git hash-object -w --stdin)
HASH_C=$(echo "Different content" | git hash-object -w --stdin)

echo "ファイルA（'Identical content'）のハッシュ: ${HASH_A}"
echo "ファイルB（'Identical content'）のハッシュ: ${HASH_B}"
echo "ファイルC（'Different content'）のハッシュ: ${HASH_C}"
echo ""

if [ "${HASH_A}" = "${HASH_B}" ]; then
  echo "-> A と B は同じハッシュ（同一内容 = 同一オブジェクト）"
else
  echo "-> A と B は異なるハッシュ（予期しない結果）"
fi

if [ "${HASH_A}" != "${HASH_C}" ]; then
  echo "-> A と C は異なるハッシュ（異なる内容 = 異なるオブジェクト）"
fi

echo ""
echo "--- .git/objects の中身を覗く ---"
echo ""
echo ".git/objects ディレクトリの構造:"
find .git/objects -type f | head -10 | while read -r path; do
  echo "  ${path}"
done
echo ""
echo "-> ハッシュの先頭2文字がディレクトリ名、残りがファイル名"
echo "-> これがgitの「内容アドレス可能ストレージ」の実体"
echo "-> ファイルシステムのディレクトリ操作だけで実装されている"
echo "-> データベースは使わない（Monotoneとの決定的な違い）"

echo ""
echo "=== ハンズオン完了 ==="
echo ""
echo "このハンズオンで確認したこと:"
echo "  1. gitの最初のコミットは10ファイル・約1,000行のCコード"
echo "  2. 低レベルコマンド（plumbing）でblob/tree/commitを手動作成できる"
echo "  3. git add/commitは低レベル操作を自動化した「陶器（porcelain）」"
echo "  4. 同じ内容は同じSHA-1ハッシュ=内容アドレス可能ストレージ"
echo "  5. .git/objectsはファイルシステムで実装（データベース不要）"
