#!/bin/bash
# =============================================================================
# 第18回ハンズオン：Gitのトレードオフを体感する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: git, git-lfs, python3
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-18"

echo "=== 第18回ハンズオン：Gitのトレードオフを体感する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# gitの設定
git config --global user.email "handson@example.com"
git config --global user.name "Handson User"
git config --global init.defaultBranch main

# --- 演習1: バイナリファイルによるリポジトリ肥大化 ---
echo "[演習1] バイナリファイルによるリポジトリ肥大化"
echo ""

git init --quiet binary-demo
cd binary-demo

# テキストファイルを作成して10回変更
echo "--- テキストファイル（約1KB）を10回変更 ---"
python3 -c "print('line ' * 100)" > textfile.txt
git add textfile.txt
git commit --quiet -m "Text v1"

for i in $(seq 2 10); do
  python3 -c "print('line-v${i} ' * 100)" > textfile.txt
  git add textfile.txt
  git commit --quiet -m "Text v${i}"
done

# バイナリファイル（疑似）を作成して10回変更
echo "--- バイナリファイル（1MB）を10回変更 ---"
dd if=/dev/urandom of=binary.dat bs=1024 count=1024 2>/dev/null
git add binary.dat
git commit --quiet -m "Binary v1"

for i in $(seq 2 10); do
  dd if=/dev/urandom of=binary.dat bs=1024 count=1024 2>/dev/null
  git add binary.dat
  git commit --quiet -m "Binary v${i}"
done

# gc実行前のサイズ
echo ""
echo "--- gc実行前のリポジトリサイズ ---"
du -sh .git/
git count-objects -v

# gc実行
git gc --quiet

echo ""
echo "--- gc実行後のリポジトリサイズ ---"
du -sh .git/
git count-objects -v

echo ""
echo "-> テキストファイルはデルタ圧縮で効率的に格納される"
echo "   バイナリファイルはデルタ圧縮の効果が低く、サイズが大きいまま"
echo "   これがGitで巨大バイナリを管理する問題の本質"
echo ""

# --- 演習2: Git LFSの動作を確認する ---
echo "[演習2] Git LFSの動作を確認する"
echo ""

cd "${WORKDIR}"
git init --quiet lfs-demo
cd lfs-demo
git config user.email "handson@example.com"
git config user.name "Handson User"

# Git LFSを初期化
git lfs install --local

echo "--- .gitattributesでLFS追跡パターンを設定 ---"
git lfs track "*.bin"
cat .gitattributes
echo ""

git add .gitattributes
git commit --quiet -m "Add LFS tracking"

# バイナリファイルを追加
dd if=/dev/urandom of=large-asset.bin bs=1024 count=512 2>/dev/null
git add large-asset.bin
git commit --quiet -m "Add large binary asset"

echo "--- Gitオブジェクトストアの内容（LFS管理下）---"
echo "ポインタファイルの内容:"
git show HEAD:large-asset.bin
echo ""

echo "--- ポインタファイルのサイズ ---"
echo "$(git cat-file -s HEAD:large-asset.bin) バイト"
echo "（実体は512KBだが、Gitには約130バイトのポインタだけが格納される）"
echo ""

echo "--- ローカルLFSストアの内容 ---"
if [ -d ".git/lfs/objects" ]; then
  find .git/lfs/objects -type f | head -5
  echo ""
  du -sh .git/lfs/objects/
  echo "（実体ファイルはここに格納されている）"
else
  echo "（ローカルLFSストアは空、またはまだ作成されていない）"
fi

echo ""
echo "--- .gitオブジェクトストアのサイズ ---"
du -sh .git/objects/
echo "（ポインタファイルだけなので小さい）"
echo ""

# --- 演習3: shallow cloneの効果を体験する ---
echo "[演習3] shallow cloneの効果を体験する"
echo ""

cd "${WORKDIR}"

# テスト用のリポジトリを作成（多数のコミットを持つ）
git init --quiet --bare origin-repo.git
git clone --quiet origin-repo.git work-repo
cd work-repo
git config user.email "handson@example.com"
git config user.name "Handson User"

echo "--- 100コミットのリポジトリを作成 ---"
for i in $(seq 1 100); do
  echo "content version ${i}" > "file-${i}.txt"
  git add "file-${i}.txt"
  git commit --quiet -m "Commit ${i}: add file-${i}.txt"
done
git push --quiet origin main

cd "${WORKDIR}"

echo ""
echo "--- 通常のclone ---"
git clone --quiet origin-repo.git full-clone
echo "コミット数: $(cd full-clone && git rev-list --count HEAD)"
echo "サイズ: $(du -sh full-clone/.git/ | cut -f1)"
echo ""

echo "--- shallow clone (depth=1) ---"
git clone --quiet --depth 1 origin-repo.git shallow-clone
echo "コミット数: $(cd shallow-clone && git rev-list --count HEAD)"
echo "サイズ: $(du -sh shallow-clone/.git/ | cut -f1)"
echo ""

echo "--- shallow clone (depth=10) ---"
git clone --quiet --depth 10 origin-repo.git shallow-clone-10
echo "コミット数: $(cd shallow-clone-10 && git rev-list --count HEAD)"
echo "サイズ: $(du -sh shallow-clone-10/.git/ | cut -f1)"
echo ""

echo "-> 深さを制限するほど、サイズが小さくなる"
echo "   ただし、過去のコミットへのアクセスは制限される"
echo ""

# --- 演習4: sparse-checkoutで作業ディレクトリを絞り込む ---
echo "[演習4] sparse-checkoutで作業ディレクトリを絞り込む"
echo ""

cd "${WORKDIR}"

# モノレポ風のリポジトリを作成
git init --quiet --bare monorepo-origin.git
git clone --quiet monorepo-origin.git monorepo-work
cd monorepo-work
git config user.email "handson@example.com"
git config user.name "Handson User"

# ディレクトリ構造を作成
mkdir -p src/frontend src/backend src/shared docs/api docs/guide
echo "import React from 'react'" > src/frontend/app.tsx
echo "from flask import Flask" > src/backend/app.py
echo "export const VERSION = '1.0'" > src/shared/constants.ts
echo "# API Reference" > docs/api/README.md
echo "# User Guide" > docs/guide/README.md
echo "# Monorepo Root" > README.md

git add .
git commit --quiet -m "Initial monorepo structure"
git push --quiet origin main

cd "${WORKDIR}"

# sparse-checkoutでクローン
echo "--- sparse-checkoutでフロントエンドだけを展開 ---"
git clone --quiet --sparse monorepo-origin.git sparse-monorepo
cd sparse-monorepo

echo "クローン直後の作業ディレクトリ:"
find . -not -path './.git/*' -not -path './.git' | sort
echo ""

echo "--- sparse-checkout set で src/frontend と src/shared を指定 ---"
git sparse-checkout set src/frontend src/shared

echo "sparse-checkout後の作業ディレクトリ:"
find . -not -path './.git/*' -not -path './.git' | sort
echo ""

echo "--- sparse-checkout list ---"
git sparse-checkout list
echo ""

echo "-> src/frontend と src/shared だけが展開された"
echo "   src/backend と docs は作業ディレクトリに存在しない"
echo "   モノレポで自分の担当部分だけを扱える"

echo ""
echo "--- 全ファイルを復元する ---"
git sparse-checkout disable
echo "復元後:"
find . -not -path './.git/*' -not -path './.git' | sort

echo ""
echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
