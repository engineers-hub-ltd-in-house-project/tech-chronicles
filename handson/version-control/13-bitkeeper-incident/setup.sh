#!/bin/bash
# =============================================================================
# 第13回ハンズオン：BitKeeper事件のアーカイブを読む——一次ソースに触れる
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: curl, git
# 推奨環境: docker run -it --rm ubuntu:24.04 bash
#            apt update && apt install -y curl git
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-13"

echo "=== 第13回ハンズオン：BitKeeper事件のアーカイブを読む——一次ソースに触れる ==="
echo ""

# 既存ディレクトリのクリーンアップ
if [ -d "${WORKDIR}" ]; then
  rm -rf "${WORKDIR}"
fi
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- 演習1: LKMLアーカイブから「Kernel SCM saga」を読む ---
echo "[演習1] LKMLアーカイブから「Kernel SCM saga」を読む"

# 主要アーカイブURLを記録
cat > lkml-references.txt << 'EOF'
BitKeeper事件 主要メーリングリストアーカイブ:

1. Linus Torvalds, "Kernel SCM saga..." (2005-04-06)
   https://lkml.org/lkml/2005/4/6/121
   -> BitKeeperとの決別を公表した歴史的メール

2. Richard Stallman, "Bitkeeper outrage, old and new" (2002-10-13)
   https://lkml.org/lkml/2002/10/13/201
   -> StallmanによるBitKeeper使用への抗議

3. LWN.net, "The kernel and BitKeeper part ways" (2005-04-06)
   https://lwn.net/Articles/130746/
   -> BitKeeper離脱の経緯を報じた記事

4. LWN.net, "How Tridge reverse engineered BitKeeper" (2005-04-19)
   https://lwn.net/Articles/132938/
   -> Tridgellのリバースエンジニアリング手法の解説
EOF

echo "主要アーカイブURLを lkml-references.txt に記録した"
echo ""

# gitの初期コミットログを確認する
echo "--- gitの初期コミットログを確認 ---"
echo ""
echo "gitのGitHub公式リポジトリには、2005年4月の初期コミットが含まれている。"
echo "git自身のリポジトリをクローンして、最初期のコミットを見てみよう。"
echo ""

git clone --bare https://github.com/git/git.git git-history.git 2>&1 | tail -3
echo ""

echo "--- gitの最初の10コミット ---"
git --git-dir=git-history.git log --oneline --reverse | head -10
echo ""
echo "-> 最初のコミットの日付とメッセージに注目"
echo "-> BitKeeperとの決別から数日でgitの原型が作られた"
echo ""

# --- 演習2: gitの「誕生日」を確認する ---
echo "[演習2] gitの「誕生日」を確認する"

# gitの最初のコミットの詳細
FIRST_COMMIT=$(git --git-dir=git-history.git rev-list --max-parents=0 HEAD | tail -1)
echo "gitの最初のコミット:"
echo ""
git --git-dir=git-history.git log --format="  ハッシュ: %H%n  著者: %an <%ae>%n  日付: %ai%n  メッセージ: %s" "${FIRST_COMMIT}"
echo ""
echo "-> Linus Torvaldsが2005年4月にgitの最初のコミットを行った"
echo "-> BitKeeper問題が表面化してから驚くべき速度で開発が進んだ"
echo ""

# 最初の1ヶ月のコミット数を数える
echo "--- 最初の1ヶ月のコミット活動 ---"
echo ""
echo "2005年4月のコミット数:"
git --git-dir=git-history.git log --oneline --after="2005-04-01" --before="2005-05-01" --reverse | wc -l
echo "コミット"
echo ""
echo "日ごとの内訳:"
for day in $(seq -w 3 30); do
  next_day=$((10#$day + 1))
  if [ "${next_day}" -le 30 ]; then
    next_day_padded=$(printf "%02d" "${next_day}")
    count=$(git --git-dir=git-history.git log --oneline --after="2005-04-${day}" --before="2005-04-${next_day_padded}" 2>/dev/null | wc -l)
    if [ "${count}" -gt 0 ]; then
      echo "  4月${day}日: ${count}コミット"
    fi
  fi
done
echo ""
echo "-> BitKeeperとの決別直後の集中的な開発が見て取れる"
echo ""

# --- 演習3: BitKeeperの設計思想がgitに受け継がれた点を確認する ---
echo "[演習3] BitKeeperの設計思想がgitに受け継がれた点を確認する"

# gitリポジトリを作成し、BitKeeperが先駆けた機能を試す
mkdir -p "${WORKDIR}/demo"
cd "${WORKDIR}/demo"
git init --quiet

echo ""
echo "--- 機能1: 分散リポジトリ ---"
echo "BitKeeperの核心: 各開発者がリポジトリの完全なコピーを保持"
echo ""
cat > README.md << 'FILEEOF'
# BitKeeper Legacy Demo
This repository demonstrates features that BitKeeper pioneered.
FILEEOF
git add README.md
git commit -m "Initial commit" --quiet
echo "-> git commitはローカルで完結する（サーバ不要）"
echo "-> これはBitKeeperが実現し、CVS/SVNにはなかった特徴"
echo ""

echo "--- 機能2: リネーム追跡 ---"
echo "BitKeeperの強み: ファイルの移動・改名を履歴として追跡"
echo ""
mkdir -p src
git mv README.md src/README.md
git commit -m "Move README to src/" --quiet
git log --follow --oneline -- src/README.md
echo ""
echo "-> git log --follow でリネーム前の履歴も追跡可能"
echo "-> CVSではリネーム追跡が不可能だった"
echo "-> BitKeeperはこの問題を解決した最初のVCSの一つ"
echo ""

echo "--- 機能3: 高速な分岐とマージ ---"
echo "BitKeeperの設計: サブシステムの独立開発とマージを効率化"
echo ""
git checkout -b feature-a --quiet
echo "Feature A" >> src/README.md
git add src/README.md
git commit -m "Add feature A" --quiet

git checkout main --quiet
git checkout -b feature-b --quiet
echo "Feature B" >> src/README.md
git add src/README.md
git commit -m "Add feature B" --quiet

git checkout main --quiet
git merge feature-a --no-edit --quiet
echo ""
echo "-> ブランチの作成・マージが軽量な操作として実行される"
echo "-> BitKeeperは「サブグループの独立開発→メインツリーへのマージ」"
echo "   というワークフローをLinuxカーネルに導入した"
echo "-> gitはこのワークフローをさらに洗練させた"
echo ""

echo "--- まとめ ---"
echo ""
echo "BitKeeperが先駆けた主要機能とgitの対応:"
echo ""
echo "  BitKeeper                    git"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  分散リポジトリ          →  分散リポジトリ"
echo "  リネーム追跡            →  リネーム検出（ヒューリスティック）"
echo "  全履歴マージ            →  3-way merge + recursive"
echo "  アトミックチェンジセット →  コミットオブジェクト"
echo "  チェックサム検証        →  SHA-1ハッシュによる完全性保証"
echo "  プロプライエタリ        →  GPL v2（フリーソフトウェア）"
echo ""
echo "-> BitKeeperの技術的遺産はgitに受け継がれた"
echo "-> だが、ライセンスは根本的に変わった"
echo "-> gitはフリーソフトウェアとして生まれた"

echo ""
echo "=== ハンズオン完了 ==="
echo ""
echo "このハンズオンで確認したこと:"
echo "  1. LKMLアーカイブにBitKeeper事件の一次ソースが残っている"
echo "  2. gitの最初のコミットは2005年4月（BitKeeper離脱直後）"
echo "  3. BitKeeperの分散リポジトリ、リネーム追跡、高速マージはgitに継承された"
echo "  4. 技術的遺産は受け継がれたが、ライセンスはフリーソフトウェアに変わった"
echo "  5. 歴史を一次ソースから読むことの重要性"
