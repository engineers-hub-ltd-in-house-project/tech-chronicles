#!/bin/bash
# =============================================================================
# 第24回ハンズオン：VCS評価マトリクスと技術選定の記録
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: git (2.x以降), bc
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-24"

echo "=== 第24回ハンズオン：VCS評価マトリクスと技術選定の記録 ==="
echo ""

# 作業ディレクトリの作成
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"

# gitの設定
git config --global user.email "developer@example.com" 2>/dev/null || true
git config --global user.name "Developer" 2>/dev/null || true
git config --global init.defaultBranch main 2>/dev/null || true

# --- 演習1: プロジェクトの現状を定量的に把握する ---
echo "[演習1] プロジェクトの現状を定量的に把握する"
echo ""

git init "${WORKDIR}/sample-project" --quiet
cd "${WORKDIR}/sample-project"

# 現実的な履歴を構築する
# 初期開発フェーズ
cat > main.py << 'PYEOF'
class App:
    def __init__(self):
        self.config = {}

    def run(self):
        print("App running")
PYEOF

cat > config.json << 'JSONEOF'
{
    "version": "1.0.0",
    "debug": false,
    "database": {
        "host": "localhost",
        "port": 5432
    }
}
JSONEOF

git add -A
git commit --quiet -m "Initial project setup with App class and config"

# 機能追加フェーズ
cat > auth.py << 'PYEOF'
class AuthManager:
    def __init__(self, secret_key):
        self.secret_key = secret_key

    def authenticate(self, token):
        return self.verify(token, self.secret_key)

    def verify(self, token, key):
        # Simplified verification
        return token is not None and len(token) > 0
PYEOF

git add auth.py
git commit --quiet -m "Add authentication module"

# バグ修正
cat > main.py << 'PYEOF'
import logging

logger = logging.getLogger(__name__)

class App:
    def __init__(self):
        self.config = {}
        self.running = False

    def run(self):
        if self.running:
            logger.warning("App is already running")
            return
        self.running = True
        logger.info("App started")
PYEOF

git add main.py
git commit --quiet -m "$(cat <<'EOF'
Fix duplicate run prevention and add logging

The App class could be started multiple times without any guard,
causing resource leaks. Added a running state flag and logging
for better observability.
EOF
)"

# ブランチ作業
git checkout -b feature/api --quiet
cat > api.py << 'PYEOF'
class APIHandler:
    def __init__(self, app):
        self.app = app

    def handle_request(self, method, path, body=None):
        if method == "GET":
            return self.handle_get(path)
        elif method == "POST":
            return self.handle_post(path, body)
        return {"status": 405, "error": "Method not allowed"}

    def handle_get(self, path):
        return {"status": 200, "path": path}

    def handle_post(self, path, body):
        return {"status": 201, "path": path, "body": body}
PYEOF

git add api.py
git commit --quiet -m "Add API handler with GET/POST support"
git checkout main --quiet
git merge feature/api --quiet -m "Merge feature/api: REST API handler"

# さらに履歴を積む
echo "# Sample Project" > README.md
echo "" >> README.md
echo "A demonstration project for VCS evaluation." >> README.md
git add README.md
git commit --quiet -m "Add project README"

cat > tests.py << 'PYEOF'
import unittest

class TestApp(unittest.TestCase):
    def test_app_creation(self):
        from main import App
        app = App()
        self.assertIsNotNone(app)

    def test_app_config(self):
        from main import App
        app = App()
        self.assertEqual(app.config, {})

class TestAuth(unittest.TestCase):
    def test_auth_with_valid_token(self):
        from auth import AuthManager
        auth = AuthManager("secret")
        self.assertTrue(auth.authenticate("valid-token"))

    def test_auth_with_empty_token(self):
        from auth import AuthManager
        auth = AuthManager("secret")
        self.assertFalse(auth.authenticate(""))
PYEOF

git add tests.py
git commit --quiet -m "Add unit tests for App and AuthManager"

echo "--- リポジトリの定量データ ---"
echo ""

COMMIT_COUNT=$(git rev-list --count HEAD)
echo "コミット数: ${COMMIT_COUNT}"

FILE_COUNT=$(git ls-files | wc -l)
echo "追跡ファイル数: ${FILE_COUNT}"

TOTAL_LINES=$(git ls-files | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
echo "総行数: ${TOTAL_LINES}"

REPO_SIZE=$(du -sh .git | awk '{print $1}')
echo "リポジトリサイズ (.git): ${REPO_SIZE}"

CONTRIBUTOR_COUNT=$(git shortlog -sn | wc -l)
echo "貢献者数: ${CONTRIBUTOR_COUNT}"

BRANCH_COUNT=$(git branch -a | wc -l)
echo "ブランチ数: ${BRANCH_COUNT}"

MERGE_COUNT=$(git log --merges --oneline | wc -l)
echo "マージコミット数: ${MERGE_COUNT} / ${COMMIT_COUNT}"

echo ""
echo "-> これらの数値が評価マトリクスの「重み付け」を決める基礎データ"
echo "   ファイル数が少なく貢献者が1名なら「協調の仕組み」の重みは低い"
echo "   バイナリファイルが多いなら「バイナリ対応」の重みが高くなる"
echo ""

# --- 演習2: コミットメッセージの品質を測定する ---
echo "============================================================"
echo "[演習2] コミットメッセージの品質を測定する"
echo ""

cd "${WORKDIR}/sample-project"

echo "--- 全コミットメッセージの一覧 ---"
git log --format="%h %s" --no-merges
echo ""

TOTAL_COMMITS=$(git log --no-merges --format="%s" | wc -l)
SHORT_COMMITS=$(git log --no-merges --format="%s" | awk 'length < 20' | wc -l)

echo "--- コミットメッセージの分析 ---"
echo "非マージコミット数: ${TOTAL_COMMITS}"
echo "件名20文字未満のコミット: ${SHORT_COMMITS}"
echo ""

echo "--- 本文（body）を含むコミットの詳細 ---"
git log --no-merges --format="--- %h ---%n件名: %s%n本文: %b"
echo ""

echo "-> 「歴史の保存」の品質は、コミットメッセージの質で決まる"
echo "   良い例: 件名で「何を」、本文で「なぜ」を説明"
echo "   悪い例: 'fix bug', 'update', 'WIP'"
echo ""
echo "-> あなたのプロジェクトのgit logを同様に分析してみよう"
echo "   「なぜ」が記録されているコミットは何割あるだろうか？"
echo ""

# --- 演習3: VCS評価マトリクスを作成する ---
echo "============================================================"
echo "[演習3] VCS評価マトリクスを作成する"
echo ""

cat << 'MATRIX'
以下のマトリクスを、あなたのプロジェクトに合わせて記入してください。
各項目を1-5で評価し、重みを1-3で設定してください。

重み:  1=あまり重要でない  2=重要  3=非常に重要
評価:  1=不適合  2=やや不適合  3=普通  4=適合  5=最適

評価項目                       重み  Git  jj   SVN
─────────────────────────────────────────────────
【変更の記録】
 コミットの粒度制御            ___   ___  ___  ___
 バイナリファイル対応          ___   ___  ___  ___
 大規模リポジトリ性能          ___   ___  ___  ___

【協調の仕組み】
 ブランチ/マージの効率         ___   ___  ___  ___
 オフライン作業対応            ___   ___  ___  ___
 アクセス制御の粒度            ___   ___  ___  ___
 コードレビュー統合            ___   ___  ___  ___

【歴史の保存】
 履歴の追跡性                  ___   ___  ___  ___
 操作の取り消し容易性          ___   ___  ___  ___
 監査/コンプライアンス対応     ___   ___  ___  ___

【エコシステム】
 CI/CD統合                     ___   ___  ___  ___
 IDE/エディタ統合              ___   ___  ___  ___
 ホスティングサービス          ___   ___  ___  ___

【チーム】
 学習コスト                    ___   ___  ___  ___
 人材の確保しやすさ            ___   ___  ___  ___
 ドキュメント/コミュニティ     ___   ___  ___  ___
─────────────────────────────────────────────────
加重合計                             ___  ___  ___

記入のポイント:
  1. まず「重み」を全項目記入する（プロジェクトの特性を反映）
  2. 次に各ツールの評価を記入する
  3. 加重合計 = 合計(重み x 評価) で計算する
  4. 合計が最も高いツールが「最適」候補

注意:
  マトリクスは意思決定の補助であって、決定そのものではない
  定量化できない要因（チームの士気、将来の戦略）も考慮する
  結果はADRとして記録し、将来の再評価に備える
MATRIX

echo ""
echo "-> このマトリクスの最大の価値は「重み付け」のプロセスにある"
echo "   重みを決める議論の中で、チームが何を重視しているかが明確になる"
echo ""

# --- 演習4: ADRを書いてみる ---
echo "============================================================"
echo "[演習4] ADRを書いてみる"
echo ""

cd "${WORKDIR}/sample-project"

mkdir -p docs/decisions

cat > docs/decisions/001-vcs-selection.md << 'ADREOF'
# ADR-001: バージョン管理システムの選定

## ステータス

承認済

## コンテキスト

本プロジェクトのバージョン管理システムを選定する必要がある。

プロジェクトの特性:
- テキストファイル中心（ソースコード + 設定ファイル）
- チーム規模: 現在4名、1年後に8名の見込み
- リモートワーク中心（3拠点に分散）
- CI/CDにGitHub Actionsを使用予定

検討した選択肢:
1. Git + GitHub
2. Jujutsu (jj) + GitHub
3. Subversion + 自前サーバー

## 決定

Git + GitHub を採用する。

## 理由

- チーム全員がGitの実務経験を有している（学習コスト最小）
- GitHub ActionsによるCI/CDとのネイティブ統合が可能
- リモートワーク中心のため分散型VCSが適している
- Jujutsuは技術的に魅力的だが、バージョン1.0未達で
  プロダクション利用のリスクがある
- プロジェクト規模ではGitのスケーリング限界に達しない見込み

## 結果

- GitHub Flowをブランチ戦略として採用する
- コミットメッセージはConventional Commits形式に準拠する
- 年1回、VCS選定の妥当性を再評価する
- Jujutsuの1.0リリース時に再評価を実施する

## 再評価のトリガー

- リポジトリサイズが10GBを超えた場合
- チーム規模が20名を超えた場合
- バイナリアセットの管理が主要な課題になった場合
- Jujutsuが安定版に達した場合
ADREOF

git add docs/
git commit --quiet -m "$(cat <<'EOF'
Add ADR-001: Version control system selection

Document the decision to use Git + GitHub, including context,
alternatives considered, rationale, and re-evaluation triggers.
EOF
)"

echo "--- 作成したADR ---"
cat docs/decisions/001-vcs-selection.md
echo ""

echo "-> ADRは「なぜその技術を選んだか」を記録する"
echo "   将来のチームメンバーが判断の理由を理解できる"
echo ""
echo "-> 重要なのは「再評価のトリガー」の項目"
echo "   条件が変わったときに、惰性ではなく"
echo "   合理的な判断で技術選定を見直せる"
echo ""

echo "=== ハンズオン完了 ==="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "このハンズオンで確認したこと:"
echo "  1. リポジトリの定量データが評価マトリクスの「重み」を決める"
echo "  2. コミットメッセージの品質はツールではなく運用で決まる"
echo "  3. VCS評価マトリクスは「重み付け」のプロセスに最大の価値がある"
echo "  4. ADRは技術選定の「なぜ」を記録し、再評価を可能にする"
echo ""
echo "連載全24回のハンズオンを完走された方へ:"
echo "  あなたは今、バージョン管理について「選べる」人間になっている"
echo "  その知識を、チームに持ち帰ってほしい"
