#!/bin/bash
# =============================================================================
# 第22回ハンズオン：Jujutsuを体験する——Gitとの違いを手で確かめる
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: git, curl (jjバイナリのダウンロード用)
# 推奨環境: Docker (ubuntu:24.04)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-22"

echo "=== 第22回ハンズオン：Jujutsuを体験する ==="
echo ""

# --- 前提条件の確認 ---
echo "[前提条件の確認]"

if ! command -v git &> /dev/null; then
  echo "  git が見つかりません。インストールしてください。"
  exit 1
fi
echo "  git: $(git --version)"

if ! command -v jj &> /dev/null; then
  echo "  jj が見つかりません。インストールを試みます..."
  if command -v curl &> /dev/null; then
    curl -fsSL https://github.com/jj-vcs/jj/releases/latest/download/jj-x86_64-unknown-linux-gnu.tar.gz \
      | tar xz -C /usr/local/bin 2>/dev/null || {
      echo "  jj のダウンロードに失敗しました。"
      echo "  手動でインストールしてください: https://github.com/jj-vcs/jj/releases"
      exit 1
    }
  else
    echo "  curl が見つかりません。jj を手動でインストールしてください。"
    exit 1
  fi
fi
echo "  jj: $(jj version 2>/dev/null || echo 'バージョン不明')"
echo ""

# 作業ディレクトリの準備
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"

# gitの設定
git config --global user.email "developer@example.com" 2>/dev/null || true
git config --global user.name "Developer" 2>/dev/null || true
git config --global init.defaultBranch main 2>/dev/null || true

# jjの設定
jj config set --user user.name "Developer" 2>/dev/null || true
jj config set --user user.email "developer@example.com" 2>/dev/null || true

# --- 演習1: リポジトリの初期化とGitバックエンドの確認 ---
echo "[演習1] リポジトリの初期化とGitバックエンドの確認"
echo ""

cd "${WORKDIR}"
jj git init jj-demo
cd "${WORKDIR}/jj-demo"

echo "  --- jjのリポジトリ構造 ---"
ls -la
echo ""
echo "  --- .jj ディレクトリ（jj固有の管理データ）---"
ls -la .jj/ 2>/dev/null || echo "  (.jjディレクトリの内容)"
echo ""

echo "  --- jj log: 初期状態 ---"
jj log
echo ""
echo "  -> jjはGitリポジトリをバックエンドとして使用する"
echo "     gitコマンドでも操作可能な.gitディレクトリが内部に存在する"
echo ""

# --- 演習2: ステージングエリアのないワークフロー ---
echo "[演習2] ステージングエリアのないワークフロー"
echo ""

cd "${WORKDIR}/jj-demo"

cat > hello.py << 'PYEOF'
def greet(name: str) -> str:
    return f"Hello, {name}!"

if __name__ == "__main__":
    print(greet("World"))
PYEOF

echo "  --- ファイル作成後のjj status ---"
jj status
echo ""

echo "  --- ファイル作成後のjj log ---"
jj log
echo ""

echo "  -> Gitなら 'git add hello.py && git commit' が必要"
echo "     jjでは作業コピーが自動的にスナップショットされる"
echo "     ステージングエリア（index）という概念がない"
echo ""

# コミットにメッセージを設定
jj describe -m "Add greeting function"

echo "  --- describe後のjj log ---"
jj log
echo ""

# 新しい変更を開始
jj new

echo "  --- jj new後のlog ---"
jj log
echo ""

echo "  -> jj describeでコミットメッセージを設定"
echo "     jj newで新しい変更セットを開始（=現在のコミットを確定）"
echo ""

# --- 演習3: オペレーションログと操作の取り消し ---
echo "[演習3] オペレーションログと操作の取り消し"
echo ""

cd "${WORKDIR}/jj-demo"

# ファイルを追加
cat > utils.py << 'PYEOF'
from datetime import datetime, timezone

def now_utc() -> str:
    return datetime.now(timezone.utc).isoformat()
PYEOF

jj describe -m "Add utility functions"
jj new

# さらにファイルを追加
cat > config.py << 'PYEOF'
import os

DEBUG = os.getenv("DEBUG", "false").lower() == "true"
PYEOF

jj describe -m "Add configuration module"
jj new

echo "  --- 現在のjj log ---"
jj log
echo ""

# オペレーションログを確認
echo "  --- オペレーションログ（直近5件）---"
jj op log --limit 5
echo ""

echo "  -> jjは全ての操作を記録する"
echo "     Gitのreflogに近いが、より体系的"
echo ""

# 直前の操作を取り消す
echo "  --- jj undoで直前の操作を取り消し ---"
jj undo
echo ""

echo "  --- undo後のjj log ---"
jj log
echo ""

echo "  -> jj undoで任意の操作を安全に取り消せる"
echo "     Gitの 'git reset' と異なり、データが失われない"
echo ""

# --- 演習4: Gitとの相互運用 ---
echo "[演習4] Gitとの相互運用"
echo ""

cd "${WORKDIR}/jj-demo"

# 状態を戻す
jj new
jj describe -m "Add configuration module"
jj new

echo "  --- Git側から見たコミットログ ---"
git log --oneline --all 2>/dev/null || echo "  (Gitブランチ未作成)"
echo ""

# ブックマークを作成してGitに反映
jj bookmark create main -r @- 2>/dev/null || jj bookmark set main -r @- 2>/dev/null || true
jj git export 2>/dev/null || true

echo "  --- ブックマーク作成・エクスポート後のgit log ---"
git log --oneline --all 2>/dev/null || echo "  (エクスポート結果)"
echo ""

echo "  -> jjの変更はGitバックエンドに保存される"
echo "     jj git exportでブックマークをGitブランチに反映"
echo "     GitHub/GitLabへのpushはgitコマンドまたはjj git pushで可能"
echo ""

# --- 演習5: コンフリクトのファーストクラスサポート ---
echo "[演習5] コンフリクトのファーストクラスサポート"
echo ""

cd "${WORKDIR}"
jj git init conflict-demo
cd "${WORKDIR}/conflict-demo"

# ベースとなるコミットを作成
cat > shared.py << 'PYEOF'
def process(data):
    result = data.strip()
    return result
PYEOF

jj describe -m "Add shared processing function"
jj new

# 変更Aを作成
cat > shared.py << 'PYEOF'
def process(data):
    result = data.strip().upper()
    return result
PYEOF

jj describe -m "Change A: convert to uppercase"

# 変更Aのリビジョンを記録
CHANGE_A=$(jj log --no-graph -T 'change_id.shortest()' -r @)

# ベースに戻って変更Bを作成
jj new @--
cat > shared.py << 'PYEOF'
def process(data):
    result = data.strip().lower()
    return result
PYEOF

jj describe -m "Change B: convert to lowercase"

CHANGE_B=$(jj log --no-graph -T 'change_id.shortest()' -r @)

echo "  --- コンフリクト前のjj log ---"
jj log
echo ""

# AとBをマージ
echo "  --- AとBのマージを試みる ---"
jj new "${CHANGE_A}" "${CHANGE_B}" -m "Merge A and B" 2>&1 || true
echo ""

echo "  --- マージ後のjj status ---"
jj status
echo ""

echo "  --- マージ後のjj log ---"
jj log
echo ""

echo "  -> Gitではマージコンフリクトが発生すると操作が中断される"
echo "     jjではコンフリクトがコミットに記録され、操作は成功する"
echo "     コンフリクトは後から解決できる"
echo ""

# コンフリクトの内容を確認
echo "  --- コンフリクトの内容 ---"
cat shared.py 2>/dev/null || echo "  (コンフリクトマーカーを含むファイル)"
echo ""

echo "  -> コンフリクトは「エラー」ではなく「まだ解決されていない状態」"
echo "     解決結果は子孫コミットに自動伝播する"
echo ""

# --- 完了 ---
echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ディレクトリ構成:"
ls -1 "${WORKDIR}/"
