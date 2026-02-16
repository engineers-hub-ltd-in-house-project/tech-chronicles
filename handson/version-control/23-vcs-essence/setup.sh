#!/bin/bash
# =============================================================================
# 第23回ハンズオン：バージョン管理の本質を「三つの問い」で再評価する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: git (2.x以降)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-23"

echo "=== 第23回ハンズオン：バージョン管理の本質を三つの問いで再評価する ==="
echo ""

# 作業ディレクトリの作成
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"

# gitの設定
git config --global user.email "developer@example.com" 2>/dev/null || true
git config --global user.name "Developer" 2>/dev/null || true
git config --global init.defaultBranch main 2>/dev/null || true

# --- 演習1: 変更の記録を検証する ---
echo "[演習1] 変更の記録を検証する -- git diffの解剖"
echo ""

git init "${WORKDIR}/eval-project" --quiet
cd "${WORKDIR}/eval-project"

# 初期ファイルを作成
cat > app.py << 'PYEOF'
class UserService:
    def __init__(self, db):
        self.db = db

    def get_user(self, user_id):
        return self.db.query(f"SELECT * FROM users WHERE id = {user_id}")

    def list_users(self):
        return self.db.query("SELECT * FROM users")
PYEOF

git add app.py
git commit -m "Add initial UserService implementation" --quiet

# 変更を加える（SQLインジェクション対策）
cat > app.py << 'PYEOF'
class UserService:
    def __init__(self, db):
        self.db = db

    def get_user(self, user_id):
        return self.db.query("SELECT * FROM users WHERE id = %s", (user_id,))

    def list_users(self, limit=100):
        return self.db.query("SELECT * FROM users LIMIT %s", (limit,))
PYEOF

echo "--- git diff: 何が変わったかを確認 ---"
git diff
echo ""

echo "-> diffが示すのは「何が変わったか（What changed?）」"
echo "   行6: SQLインジェクション対策としてパラメータ化クエリに変更"
echo "   行9: list_usersにlimit引数を追加"
echo ""
echo "-> 問い: この差分から「なぜ変えたか」は読み取れるか？"
echo "   diff自体は「What」を示すが「Why」は示さない"
echo ""

# コミットメッセージで「Why」を記録する
git add app.py
git commit --quiet -m "$(cat <<'COMMITEOF'
Fix SQL injection vulnerability in UserService

The get_user method was using f-string interpolation to build SQL queries,
which is vulnerable to SQL injection attacks. Changed to parameterized
queries using placeholder syntax.

Also added a limit parameter to list_users to prevent unbounded queries
that could cause performance issues with large user tables.
COMMITEOF
)"

echo "--- git log: Whyを含む完全な記録 ---"
git log -1 --format="%H%n%nAuthor: %an%nDate: %ad%n%n%B"
echo ""

echo "-> コミットメッセージの本文が「Why（なぜ変えたか）」を記録する"
echo "   1行目: 変更の要約（What）"
echo "   本文: 変更の理由と背景（Why）"
echo "   コード: 変更の実装方法（How）"
echo ""

# --- 演習2: 協調の仕組みを検証する ---
echo "============================================================"
echo "[演習2] 協調の仕組みを検証する -- マージの本質"
echo ""

cd "${WORKDIR}/eval-project"

# 開発者A: 認証機能を追加
git checkout -b feature/auth --quiet
cat > auth.py << 'PYEOF'
import hashlib

class AuthService:
    def __init__(self, user_service):
        self.user_service = user_service

    def authenticate(self, username, password):
        user = self.user_service.get_user_by_name(username)
        if user and self.verify_password(password, user['password_hash']):
            return True
        return False

    def verify_password(self, password, password_hash):
        return hashlib.sha256(password.encode()).hexdigest() == password_hash
PYEOF

cat > app.py << 'PYEOF'
class UserService:
    def __init__(self, db):
        self.db = db

    def get_user(self, user_id):
        return self.db.query("SELECT * FROM users WHERE id = %s", (user_id,))

    def get_user_by_name(self, username):
        return self.db.query("SELECT * FROM users WHERE name = %s", (username,))

    def list_users(self, limit=100):
        return self.db.query("SELECT * FROM users LIMIT %s", (limit,))
PYEOF

git add -A
git commit --quiet -m "Add authentication service with password verification"

# 開発者B: ロギング機能を追加（mainブランチから分岐）
git checkout main --quiet
git checkout -b feature/logging --quiet

cat > app.py << 'PYEOF'
import logging

logger = logging.getLogger(__name__)

class UserService:
    def __init__(self, db):
        self.db = db

    def get_user(self, user_id):
        logger.info("Fetching user: %s", user_id)
        return self.db.query("SELECT * FROM users WHERE id = %s", (user_id,))

    def list_users(self, limit=100):
        logger.info("Listing users with limit: %s", limit)
        return self.db.query("SELECT * FROM users LIMIT %s", (limit,))
PYEOF

git add -A
git commit --quiet -m "Add logging to UserService for observability"

echo "--- 二つのブランチの状態 ---"
git log --oneline --all --graph
echo ""

echo "-> 二人の開発者が同じファイル（app.py）を同時に変更した"
echo "   開発者A: 認証用メソッドを追加"
echo "   開発者B: ロギングを追加"
echo ""

# マージを試みる
git checkout main --quiet
git merge feature/auth -m "Merge authentication feature" --quiet

echo "--- feature/loggingのマージを試みる ---"
if git merge feature/logging -m "Merge logging feature" 2>&1; then
    echo ""
    echo "-> マージが自動的に成功した場合: ツールが協調を完全に仲介した"
else
    echo ""
    echo "-> コンフリクトが発生: ツールだけでは解決できない協調の限界点"
    echo "   人間の判断（コミュニケーション）が必要になる"
    echo ""

    # コンフリクト解消
    echo "--- コンフリクトを解消する ---"
    cat > app.py << 'PYEOF'
import logging

logger = logging.getLogger(__name__)

class UserService:
    def __init__(self, db):
        self.db = db

    def get_user(self, user_id):
        logger.info("Fetching user: %s", user_id)
        return self.db.query("SELECT * FROM users WHERE id = %s", (user_id,))

    def get_user_by_name(self, username):
        logger.info("Fetching user by name: %s", username)
        return self.db.query("SELECT * FROM users WHERE name = %s", (username,))

    def list_users(self, limit=100):
        logger.info("Listing users with limit: %s", limit)
        return self.db.query("SELECT * FROM users LIMIT %s", (limit,))
PYEOF

    git add app.py
    git commit --quiet -m "Merge logging feature (resolved: integrated auth methods with logging)"
fi

echo ""
echo "-> バージョン管理は通信コストの大部分を吸収するが"
echo "   コンフリクトという形で「人間の判断が必要な場面」を可視化する"
echo ""

# --- 演習3: 歴史の保存を検証する ---
echo "============================================================"
echo "[演習3] 歴史の保存を検証する -- git blameとgit log"
echo ""

cd "${WORKDIR}/eval-project"

# 追加の変更
cat >> app.py << 'PYEOF'

    def delete_user(self, user_id):
        logger.warning("Deleting user: %s", user_id)
        return self.db.query("DELETE FROM users WHERE id = %s", (user_id,))
PYEOF

git add app.py
git commit --quiet -m "$(cat <<'COMMITEOF'
Add delete_user method with warning log

Added at the request of the admin dashboard team (ticket #1234).
Includes warning-level logging because user deletion is an
irreversible operation that should be auditable.
COMMITEOF
)"

echo "--- git blame: 各行の「誰が」「いつ」「なぜ」 ---"
git blame app.py
echo ""

echo "-> git blameは各行に対して以下を表示する:"
echo "   - コミットハッシュ（識別）"
echo "   - 著者名（誰が）"
echo "   - 日時（いつ）"
echo "   - コミットメッセージ（なぜ）への参照"
echo ""

echo "--- git log --oneline: 変更の時系列 ---"
git log --oneline
echo ""

echo "--- git shortlog: 貢献者ごとの要約 ---"
git shortlog -sn
echo ""

echo "-> 「歴史の保存」が機能するかどうかは"
echo "   コミットメッセージの質に依存する"
echo "   'fix bug'と書かれた履歴は、歴史として役に立たない"
echo "   'Fix SQL injection in get_user'と書かれた履歴は、将来の開発者を助ける"
echo ""

# --- 演習4: 自己評価ワークシート ---
echo "============================================================"
echo "[演習4] 三つの本質の自己評価ワークシート"
echo ""

cat << 'WORKSHEET'
以下の質問に回答し、自分のワークフローの強み・弱みを把握する。

【変更の記録 (What changed?)】
  [ ] コミットは論理的に一つの変更単位にまとまっているか？
  [ ] コミットの粒度は適切か？（レビュー可能なサイズか）
  [ ] 差分（diff）を見て、変更の範囲が理解できるか？
  [ ] バイナリファイルの変更も追跡できているか？

【協調の仕組み (Who changed it, and how do we integrate?)】
  [ ] ブランチ戦略は明文化されているか？
  [ ] マージ/リベースの方針はチーム内で統一されているか？
  [ ] コードレビューのプロセスが定義されているか？
  [ ] コンフリクト解消の手順が共有されているか？
  [ ] CIがマージ前に自動テストを実行しているか？

【歴史の保存 (Why did it change?)】
  [ ] コミットメッセージに「なぜ」が記録されているか？
  [ ] git blameの結果が有用な情報を提供するか？
  [ ] 半年前の変更の理由を、git logから特定できるか？
  [ ] チケット番号やPRリンクがコミットに含まれているか？
  [ ] コミットメッセージの書き方がチーム内で統一されているか？

【総合評価】
  あなたのワークフローで最も弱い領域はどれか？
  その弱さは「ツールの問題」か「プロセスの問題」か「習慣の問題」か？
WORKSHEET

echo ""
echo "=== ハンズオン完了 ==="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "このハンズオンで確認したこと:"
echo "  1. git diffは「What」を自動計算する（ツールの仕事）"
echo "  2. コミットメッセージは「Why」を記録する（人間の仕事）"
echo "  3. マージは「協調」を仲介するが、コンフリクトは人間の判断を要求する"
echo "  4. git blame/logは「歴史」を保存するが、歴史の質は人間が決める"
echo "  5. バージョン管理の本質は、ツールが提供するが活かすかは人間次第"
