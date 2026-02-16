#!/bin/bash
# =============================================================================
# 第19回ハンズオン：メーリングリスト方式のパッチ送付を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: git
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-19"

echo "=== 第19回ハンズオン：メーリングリスト方式のパッチ送付を体験する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# gitの設定
git config --global user.email "maintainer@example.com"
git config --global user.name "Maintainer"
git config --global init.defaultBranch main

# --- 演習1: git format-patchでパッチファイルを生成する ---
echo "[演習1] git format-patchでパッチファイルを生成する"
echo ""

# 「上流」リポジトリを作成（メンテナーのリポジトリ）
git init --quiet upstream-project
cd upstream-project

# 初期コミット
cat > calculator.py << 'PYEOF'
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

if __name__ == "__main__":
    print(f"1 + 2 = {add(1, 2)}")
    print(f"5 - 3 = {subtract(5, 3)}")
PYEOF
git add calculator.py
git commit --quiet -m "Initial commit: basic calculator with add and subtract"

echo "--- 上流リポジトリを作成 ---"
git log --oneline
echo ""

# 「貢献者」のクローンを作成
cd "${WORKDIR}"
git clone --quiet upstream-project contributor-fork
cd contributor-fork
git config user.email "contributor@example.com"
git config user.name "Contributor"

# 貢献者が機能を追加（2つのコミット）
cat > calculator.py << 'PYEOF'
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

def multiply(a, b):
    return a * b

if __name__ == "__main__":
    print(f"1 + 2 = {add(1, 2)}")
    print(f"5 - 3 = {subtract(5, 3)}")
    print(f"4 * 3 = {multiply(4, 3)}")
PYEOF
git add calculator.py
git commit --quiet -m "Add multiply function

Implement multiplication as a new arithmetic operation.
This completes the basic four arithmetic operations (part 1 of 2)."

cat > calculator.py << 'PYEOF'
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

def multiply(a, b):
    return a * b

def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

if __name__ == "__main__":
    print(f"1 + 2 = {add(1, 2)}")
    print(f"5 - 3 = {subtract(5, 3)}")
    print(f"4 * 3 = {multiply(4, 3)}")
    print(f"10 / 3 = {divide(10, 3)}")
PYEOF
git add calculator.py
git commit --quiet -m "Add divide function with zero-division guard

Implement division with explicit zero-division error handling.
This completes the basic four arithmetic operations (part 2 of 2)."

echo "--- 貢献者のコミット履歴 ---"
git log --oneline
echo ""

# git format-patch でパッチファイルを生成
echo "--- git format-patch でパッチファイルを生成 ---"
git format-patch origin/main --output-directory "${WORKDIR}/patches"
echo ""

echo "生成されたパッチファイル:"
ls -la "${WORKDIR}/patches/"
echo ""

echo "--- パッチファイルの内容（1つ目）---"
cat "${WORKDIR}/patches/0001-Add-multiply-function.patch"
echo ""
echo "-> パッチファイルはメールのRFC 2822形式で生成される"
echo "   From, Date, Subject, メッセージ本文、そしてdiffが含まれる"
echo "   これをそのままメーリングリストに送信できる"

# --- 演習2: git amでパッチを適用する ---
echo ""
echo "[演習2] git amでパッチを適用する"
echo ""

# メンテナー側でパッチを適用
cd "${WORKDIR}/upstream-project"

echo "--- 適用前のコミット履歴 ---"
git log --oneline
echo ""

echo "--- パッチを適用（git am）---"
git am "${WORKDIR}/patches/"*.patch
echo ""

echo "--- 適用後のコミット履歴 ---"
git log --oneline
echo ""

echo "--- 適用後のファイル内容 ---"
cat calculator.py
echo ""

echo "-> git am はパッチのメタデータ（著者、日時、コミットメッセージ）を"
echo "   そのまま保持してコミットを作成する"
echo "   Author は貢献者のまま維持される:"
git log --format="%h %an <%ae> %s" -2

# --- 演習3: カバーレターを付けたパッチセット ---
echo ""
echo "[演習3] カバーレターを付けたパッチセットを生成する"
echo ""

cd "${WORKDIR}/contributor-fork"

# カバーレター付きでパッチを再生成
git format-patch origin/main \
  --cover-letter \
  --output-directory "${WORKDIR}/patches-with-cover"

echo "--- カバーレター付きのパッチファイル ---"
ls -la "${WORKDIR}/patches-with-cover/"
echo ""

echo "--- カバーレターの内容 ---"
cat "${WORKDIR}/patches-with-cover/0000-cover-letter.patch"
echo ""
echo "-> カバーレター（0000-cover-letter.patch）はパッチセット全体の"
echo "   概要を説明するためのものである"
echo "   *** SUBJECT HERE *** と *** BLURB HERE *** を"
echo "   実際の説明に置き換えてからメーリングリストに送信する"
echo ""
echo "   Linuxカーネル開発では、カバーレターに以下を記載する:"
echo "   - パッチセットの目的と設計意図"
echo "   - 代替案の検討内容"
echo "   - テスト方法と結果"
echo "   - 前回のバージョンからの変更点（v2, v3...）"

# --- 演習4: Pull Request方式との操作フロー比較 ---
echo ""
echo "[演習4] Pull Request方式との操作フロー比較"
echo ""

cd "${WORKDIR}"

echo "--- メーリングリスト方式のワークフロー ---"
echo "  1. git clone <upstream>           # リポジトリをクローン"
echo "  2. git checkout -b feature        # ブランチを作成"
echo "  3. （コードを変更してコミット）"
echo "  4. git format-patch main          # パッチファイルを生成"
echo "  5. git send-email *.patch         # メーリングリストに送信"
echo "  6. （レビュー: メール上でインラインコメント）"
echo "  7. メンテナー: git am *.patch     # パッチを適用"
echo ""
echo "--- Pull Request方式のワークフロー ---"
echo "  1. Fork（Webブラウザ）             # リポジトリをフォーク"
echo "  2. git clone <fork>               # フォークをクローン"
echo "  3. git checkout -b feature        # ブランチを作成"
echo "  4. （コードを変更してコミット）"
echo "  5. git push origin feature        # フォークにプッシュ"
echo "  6. Pull Request作成（Webブラウザ） # PRを作成"
echo "  7. （レビュー: Web上でdiffコメント）"
echo "  8. Mergeボタン（Webブラウザ）      # マージ"
echo ""

# パッチのサイズを確認
echo "--- パッチファイルのサイズ（メーリングリスト方式）---"
du -sh "${WORKDIR}/patches/"
echo "-> パッチはテキストファイルとしてメールに添付される"
echo "   ネットワーク接続が不安定な環境でも扱える"
echo ""
echo "--- 比較のまとめ ---"
echo "メーリングリスト方式:"
echo "  + プラットフォーム非依存（メールがあれば動作する）"
echo "  + オフラインでパッチの作成・レビューが可能"
echo "  + パッチセットとカバーレターで設計意図を構造的に伝達"
echo "  - 学習コストが高い（メールの作法、パッチ形式の理解）"
echo "  - 視覚的なdiffビューがない（テキストベース）"
echo ""
echo "Pull Request方式:"
echo "  + 視覚的で直感的なインターフェース"
echo "  + CI/CD統合、コードオーナー自動割り当て"
echo "  + 初心者でも参加しやすい"
echo "  - プラットフォーム依存（GitHubがダウンすると停止）"
echo "  - Gitの分散型の利点を一部犠牲にしている"

echo ""
echo "=== 全演習完了 ==="
echo ""
echo "クリーンアップ: rm -rf ${WORKDIR}"
