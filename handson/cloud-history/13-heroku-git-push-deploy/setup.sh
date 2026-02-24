#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-13"

echo "============================================"
echo " クラウドの考古学 第13回 ハンズオン"
echo " Heroku——「git pushでデプロイ」が変えたもの"
echo " PaaSの処理フローを手動で再現する"
echo "============================================"
echo ""

# -----------------------------------------------
echo ">>> 環境セットアップ"
# -----------------------------------------------
apt-get update -qq && apt-get install -y -qq git curl nodejs npm python3 python3-pip python3-venv > /dev/null 2>&1
echo "必要なパッケージをインストールしました"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# -----------------------------------------------
echo ">>> 演習1: サンプルアプリケーションの作成"
# -----------------------------------------------
echo "Python Flaskアプリケーションを作成します..."

mkdir -p "${WORKDIR}/myproject"
cd "${WORKDIR}/myproject"

cat > app.py << 'PYEOF'
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return f"Hello from my PaaS! Running on port {os.environ.get('PORT', '5000')}"

@app.route('/health')
def health():
    return "OK"

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
PYEOF

cat > requirements.txt << 'EOF'
flask==3.1.0
gunicorn==23.0.0
EOF

cat > Procfile << 'EOF'
web: gunicorn app:app --bind 0.0.0.0:$PORT
worker: python3 -c "print('Worker process started')"
EOF

echo "アプリケーション構造:"
ls -la
echo ""

# -----------------------------------------------
echo ">>> 演習2: PaaSビルドパイプラインの手動再現"
# -----------------------------------------------

# Phase 1: 言語検出（Detect）
echo "--- Phase 1: 言語検出 ---"
if [ -f "requirements.txt" ]; then
    echo "検出: Python（requirements.txt が存在）"
    DETECTED_LANG="python"
elif [ -f "Gemfile" ]; then
    echo "検出: Ruby（Gemfile が存在）"
    DETECTED_LANG="ruby"
elif [ -f "package.json" ]; then
    echo "検出: Node.js（package.json が存在）"
    DETECTED_LANG="nodejs"
else
    echo "言語を検出できません"
    exit 1
fi
echo ""

# Phase 2: 依存解決（Compile）
echo "--- Phase 2: 依存解決 ---"
python3 -m venv "${WORKDIR}/venv"
"${WORKDIR}/venv/bin/pip" install -r requirements.txt 2>&1 | tail -5
echo ""

# Phase 3: Procfileパース
echo "--- Phase 3: Procfile パース ---"
echo "定義されたプロセスタイプ:"
while IFS=: read -r ptype cmd; do
    ptype=$(echo "$ptype" | xargs)
    cmd=$(echo "$cmd" | xargs)
    echo "  - $ptype: $cmd"
done < Procfile
echo ""

# Phase 4: 環境変数の注入
echo "--- Phase 4: 環境変数の注入 ---"
export PORT=8080
export DATABASE_URL="postgres://user:pass@db-host:5432/myapp"
export REDIS_URL="redis://redis-host:6379/0"
echo "PORT=$PORT"
echo "DATABASE_URL=$DATABASE_URL"
echo "REDIS_URL=$REDIS_URL"
echo "PaaSではアドオン追加時にこれらが自動注入される"
echo ""

# Phase 5: プロセス起動
echo "--- Phase 5: webプロセス起動 ---"
WEB_CMD=$(grep "^web:" Procfile | cut -d: -f2- | xargs)
echo "実行コマンド: $WEB_CMD"
echo "（実際のPaaSではここでDyno/コンテナが起動する）"
echo ""

# -----------------------------------------------
echo ">>> 演習3: Twelve-Factor Appの原則を体験"
# -----------------------------------------------

echo "--- 原則III: Config ---"
echo "悪い例: db_host = 'production-db.example.com'  # ハードコード"
echo "良い例: db_url = os.environ['DATABASE_URL']    # 環境変数から取得"
echo "→ 開発/ステージング/本番で同じコード、異なる設定"
echo ""

echo "--- 原則VI: Processes（ステートレス） ---"
TMPDIR_DEMO=$(mktemp -d)
echo "session_data_12345" > "$TMPDIR_DEMO/session.txt"
echo "Dyno Aでセッションを保存: $(cat "$TMPDIR_DEMO/session.txt")"
rm -rf "$TMPDIR_DEMO"
echo "Dyno Aが再起動 → セッションデータ消失"
echo "→ セッションはRedis等の外部ストアに保存すべき"
echo ""

echo "--- 原則IX: Disposability ---"
echo "Dynoはデプロイ時、日次再起動、スケール変更で再作成される"
echo "→ 高速起動、SIGTERMでグレースフルシャットダウン、が必須"
echo ""

echo "--- 原則X: Dev/prod parity ---"
echo "最小化すべき3つのギャップ:"
echo "  時間: 数週間 → 数分（git push）"
echo "  人:   開発者と運用者の分離 → 開発者がデプロイ"
echo "  ツール: macOS+SQLite/Linux+PostgreSQL → 統一"
echo ""

# -----------------------------------------------
echo ">>> 演習4: PaaSの制約を体験"
# -----------------------------------------------

echo "--- 制約1: 揮発性ファイルシステム ---"
DEPLOY_DIR=$(mktemp -d)
echo "upload.jpg" > "$DEPLOY_DIR/upload.jpg"
echo "デプロイv1: $(ls "$DEPLOY_DIR")"
rm -rf "$DEPLOY_DIR" && DEPLOY_DIR=$(mktemp -d)
echo "デプロイv2: $(ls "$DEPLOY_DIR" 2>/dev/null || echo '空 — 消えた')"
echo "→ ファイルはS3等の外部ストレージに保存すべき"
rm -rf "$DEPLOY_DIR"
echo ""

echo "--- 制約2: リソース制限 ---"
echo "Webリクエスト: 30秒タイムアウト / Dyno起動: 60秒以内"
echo "メモリ上限: 512MB(Standard-1X), 1GB(Standard-2X)"
echo "→ 長時間処理はWorker Dynoに委譲する設計が必須"
echo ""

echo "--- 制約3: 障害時の可視性 ---"
echo "IaaSでできること → PaaSではできないこと:"
echo "  SSH接続 → 不可  /  strace,tcpdump → 不可"
echo "  カーネルパラメータ変更 → 不可"
echo "  ログ: heroku logs --tail のみ"
echo "→ PaaS最大のトレードオフ: 障害がプラットフォーム内部にあると無力"
echo ""

# -----------------------------------------------
echo ">>> クリーンアップ"
# -----------------------------------------------
echo "作業ディレクトリ: ${WORKDIR}"
echo "削除する場合: rm -rf ${WORKDIR}"
echo ""

echo "============================================"
echo " ハンズオン完了"
echo "============================================"
