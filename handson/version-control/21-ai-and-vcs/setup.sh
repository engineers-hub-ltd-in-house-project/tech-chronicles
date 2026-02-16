#!/bin/bash
# =============================================================================
# 第21回ハンズオン：AI支援開発のワークフローをgitで追跡可能にする
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: git
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-21"

echo "=== 第21回ハンズオン：AI支援開発のワークフローをgitで追跡可能にする ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# gitの設定
git config --global user.email "developer@example.com"
git config --global user.name "Developer"
git config --global init.defaultBranch main

# --- 演習1: gitトレーラーの基本 ---
echo "[演習1] gitトレーラーの基本"
echo ""

# リポジトリを作成
git init --quiet ai-workflow-repo
cd ai-workflow-repo

# 手書きのコードをコミット（従来のワークフロー）
cat > app.py << 'PYEOF'
def hello():
    return "Hello, World!"
PYEOF

git add app.py
git commit --quiet -m "Add hello function (hand-written)"

# git logでAuthor情報を確認
echo "--- 従来のコミット ---"
git log --format='Author:  %an <%ae>%nMessage: %s%n' -1
echo ""

# Co-authored-byトレーラー付きのコミット（AI協同作業）
cat > app.py << 'PYEOF'
def hello(name: str = "World") -> str:
    """Generate a greeting message."""
    if not name or not name.strip():
        raise ValueError("Name cannot be empty")
    return f"Hello, {name.strip()}!"
PYEOF

git add app.py
git commit --quiet -m "$(cat <<'EOF'
Enhance hello function with validation and type hints

Added parameter validation and type annotations.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

echo "--- AI協同作業のコミット ---"
git log --format='Author:  %an <%ae>%nMessage: %s%n%b' -1
echo ""

# git interpret-trailersでトレーラーを解析
echo "--- トレーラーの解析 ---"
git log --format='%B' -1 | git interpret-trailers --parse
echo ""
echo "-> Co-authored-byはgitのトレーラー機構で解析可能"
echo "   ただし、AIの貢献度や生成方法は記録されていない"
echo ""

# --- 演習2: カスタムトレーラーによるAIメタデータの記録 ---
echo "[演習2] カスタムトレーラーによるAIメタデータの記録"
echo ""

cd "${WORKDIR}/ai-workflow-repo"

# AIメタデータをカスタムトレーラーで記録するコミット
cat > auth.py << 'PYEOF'
import hashlib
import secrets

def generate_token(user_id: str) -> str:
    """Generate a secure authentication token."""
    random_bytes = secrets.token_bytes(32)
    payload = f"{user_id}:{random_bytes.hex()}"
    return hashlib.sha256(payload.encode()).hexdigest()

def validate_token(token: str) -> bool:
    """Validate token format."""
    if not token or len(token) != 64:
        return False
    try:
        int(token, 16)
        return True
    except ValueError:
        return False
PYEOF

git add auth.py

# 構造化されたトレーラーでAIの関与を詳細に記録
git commit --quiet -m "$(cat <<'EOF'
Add authentication token generation and validation

Implemented secure token generation using secrets module
and SHA-256 hashing. Token validation checks format and
hex encoding.

AI-Tool: claude-code/1.0
AI-Model: claude-sonnet-4-5
AI-Contribution: high
Human-Review: detailed
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

echo "--- カスタムトレーラー付きコミット ---"
git log --format='%B' -1
echo ""

# トレーラーを解析
echo "--- 全トレーラーの解析 ---"
git log --format='%B' -1 | git interpret-trailers --parse
echo ""

echo "-> AI-Tool, AI-Model, AI-Contribution, Human-Reviewなどの"
echo "   カスタムトレーラーでAIの関与を構造化して記録できる"
echo "   ただし、これは標準化されておらず、組織ごとの規約に依存する"
echo ""

# --- 演習3: git logによるAI関与の分析 ---
echo "[演習3] git logによるAI関与の分析"
echo ""

cd "${WORKDIR}/ai-workflow-repo"

# さらにいくつかのコミットを追加（混在ワークフロー）
cat > config.py << 'PYEOF'
import os

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///app.db")
DEBUG = os.getenv("DEBUG", "false").lower() == "true"
PYEOF
git add config.py
git commit --quiet -m "Add configuration module (hand-written)"

cat > utils.py << 'PYEOF'
from datetime import datetime, timezone

def now_utc() -> datetime:
    return datetime.now(timezone.utc)

def format_iso(dt: datetime) -> str:
    return dt.isoformat()
PYEOF
git add utils.py
git commit --quiet -m "$(cat <<'EOF'
Add utility functions for datetime handling

AI-Tool: copilot
AI-Contribution: medium
Co-Authored-By: GitHub Copilot <noreply@github.com>
EOF
)"

cat > test_app.py << 'PYEOF'
from app import hello

def test_hello_default():
    assert hello() == "Hello, World!"

def test_hello_with_name():
    assert hello("Alice") == "Hello, Alice!"

def test_hello_strips_whitespace():
    assert hello("  Bob  ") == "Hello, Bob!"
PYEOF
git add test_app.py
git commit --quiet -m "$(cat <<'EOF'
Add tests for hello function

AI-Tool: claude-code/1.0
AI-Model: claude-sonnet-4-5
AI-Contribution: high
Human-Review: detailed
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

echo "--- 全コミット履歴 ---"
git log --oneline
echo ""

# AI関与のあるコミットを抽出
echo "--- AI関与のあるコミット（Co-authored-byで検索）---"
git log --all --grep="Co-Authored-By" --oneline
echo ""

# AIツール別の集計
echo "--- AIツール別の集計 ---"
echo "Claude Code:"
git log --all --grep="AI-Tool: claude-code" --oneline
echo ""
echo "GitHub Copilot:"
git log --all --grep="AI-Tool: copilot" --oneline
echo ""
echo "手書き（AIトレーラーなし）:"
git log --all --invert-grep --grep="Co-Authored-By" --oneline
echo ""

# 比率の計算
TOTAL=$(git rev-list --count HEAD)
AI_COMMITS=$(git log --all --grep="Co-Authored-By" --oneline | wc -l)
HUMAN_ONLY=$((TOTAL - AI_COMMITS))

echo "--- AI関与の比率 ---"
echo "全コミット数:       ${TOTAL}"
echo "AI関与あり:         ${AI_COMMITS}"
echo "手書きのみ:         ${HUMAN_ONLY}"
echo ""
echo "-> git logのgrep機能でAI関与を追跡できる"
echo "   ただし、トレーラーの記述が一貫していることが前提"
echo ""

# --- 演習4: git blameとAI帰属の可視化 ---
echo "[演習4] git blameとAI帰属の可視化"
echo ""

cd "${WORKDIR}/ai-workflow-repo"

echo "--- app.pyのgit blame ---"
git blame app.py
echo ""

echo "--- 各行のコミットメッセージを表示 ---"
# 各行のコミットハッシュを取得し、トレーラーの有無を確認
git blame --porcelain app.py | grep "^[0-9a-f]\{40\}" | sort -u | while read hash rest; do
    MSG=$(git log --format='%s' -1 "${hash}")
    HAS_AI=$(git log --format='%B' -1 "${hash}" | grep -c "Co-Authored-By" || true)
    if [ "${HAS_AI}" -gt 0 ]; then
        echo "  ${hash:0:7}: [AI] ${MSG}"
    else
        echo "  ${hash:0:7}: [Human] ${MSG}"
    fi
done
echo ""

echo "-> git blameのAuthor欄は常に人間の名前を表示する"
echo "   AI関与の有無はコミットメッセージのトレーラーから推定する必要がある"
echo "   行単位でのAI帰属は、現在のgitの仕組みでは記録できない"
echo ""

# --- 演習5: commit-msg hookによるトレーラーの自動検証 ---
echo "[演習5] commit-msg hookによるトレーラーの自動検証"
echo ""

cd "${WORKDIR}/ai-workflow-repo"

# commit-msg hookを作成
mkdir -p .git/hooks
cat > .git/hooks/commit-msg << 'HOOKEOF'
#!/bin/bash
# commit-msg hook: AI関与トレーラーの検証
#
# Co-Authored-By トレーラーが存在する場合、
# AI-Tool トレーラーも存在することを要求する

COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Co-Authored-Byの存在を確認
HAS_COAUTHOR=$(echo "$COMMIT_MSG" | grep -ci "Co-Authored-By" || true)
HAS_AI_TOOL=$(echo "$COMMIT_MSG" | grep -ci "AI-Tool" || true)

if [ "$HAS_COAUTHOR" -gt 0 ] && [ "$HAS_AI_TOOL" -eq 0 ]; then
    echo ""
    echo "[WARN] Co-Authored-By trailer detected but AI-Tool trailer is missing."
    echo "       Please add AI-Tool trailer to identify the AI tool used."
    echo "       Example: AI-Tool: claude-code/1.0"
    echo ""
    echo "       Commit will proceed, but consider adding AI-Tool for traceability."
    echo ""
fi

exit 0
HOOKEOF
chmod +x .git/hooks/commit-msg

echo "--- commit-msg hookを設定 ---"
echo "AI関与のあるコミットにAI-Toolトレーラーが含まれていない場合に警告する"
echo ""

# hookが動作するコミットを実行
cat > logger.py << 'PYEOF'
import logging

def setup_logger(name: str) -> logging.Logger:
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    ))
    logger.addHandler(handler)
    return logger
PYEOF
git add logger.py

echo "--- AI-Toolトレーラーなしのコミット（警告あり）---"
git commit --quiet -m "$(cat <<'EOF'
Add logging utility

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
echo ""

echo "--- AI-Toolトレーラーありのコミット（警告なし）---"
cat >> logger.py << 'PYEOF'

def get_logger(name: str) -> logging.Logger:
    return logging.getLogger(name)
PYEOF
git add logger.py
git commit --quiet -m "$(cat <<'EOF'
Add get_logger convenience function

AI-Tool: claude-code/1.0
AI-Contribution: low
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
echo ""

echo "-> commit-msg hookでトレーラーの一貫性を自動検証できる"
echo "   組織のルールに合わせてhookをカスタマイズすることで"
echo "   AI関与のトレーサビリティを強制できる"
echo ""

# --- まとめ ---
echo "=========================================="
echo "ハンズオン完了"
echo ""
echo "このハンズオンで体験したこと:"
echo "  1. Co-authored-byトレーラーの基本とgit interpret-trailersによる解析"
echo "  2. カスタムトレーラー（AI-Tool, AI-Model等）によるメタデータの構造化"
echo "  3. git logのgrep機能によるAI関与の抽出と集計"
echo "  4. git blameの限界とAI帰属の推定"
echo "  5. commit-msg hookによるトレーラーの自動検証"
echo ""
echo "現在のgitの仕組みでも、トレーラー・grep・hookを組み合わせることで"
echo "ある程度のトレーサビリティは確保できる。"
echo "ただし、行単位のAI帰属やプロンプトの記録は対応できない。"
echo "=========================================="
