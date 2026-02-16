#!/bin/bash
# =============================================================================
# 第20回ハンズオン：簡易GitOpsパイプラインを構築する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: git, jq
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-20"

echo "=== 第20回ハンズオン：簡易GitOpsパイプラインを構築する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# gitの設定
git config --global user.email "operator@example.com"
git config --global user.name "Platform Operator"
git config --global init.defaultBranch main

# --- 演習1: 宣言的な状態定義とGitリポジトリ ---
echo "[演習1] 宣言的な状態定義とGitリポジトリ"
echo ""

# 「GitOpsリポジトリ」を作成
git init --quiet gitops-repo
cd gitops-repo

# 宣言的な状態定義ファイルを作成
cat > desired-state.json << 'EOF'
{
  "app": {
    "name": "web-frontend",
    "version": "1.0.0",
    "replicas": 2,
    "port": 8080,
    "env": {
      "LOG_LEVEL": "info",
      "MAX_CONNECTIONS": "100"
    }
  }
}
EOF

git add desired-state.json
git commit --quiet -m "Initial desired state: web-frontend v1.0.0 with 2 replicas"

echo "--- 望ましい状態（Desired State）---"
cat desired-state.json
echo ""
echo "-> Gitリポジトリに「望ましい状態」を宣言的に定義した"
echo "   これがGitOpsにおけるSingle Source of Truthとなる"
echo ""

# --- 演習2: Reconciliation Loopの実装 ---
echo "[演習2] Reconciliation Loopの実装"
echo ""

cd "${WORKDIR}"

# 「実際の状態」を保持するディレクトリ（本番環境のシミュレーション）
mkdir -p live-state

# 初期状態: 本番環境は空（まだデプロイされていない）
echo '{}' > live-state/current-state.json

# Reconciliation Loopスクリプトを作成
cat > reconcile.sh << 'RECONCILE_EOF'
#!/bin/bash
# 簡易Reconciliation Loop
# GitOpsエージェント（Flux/ArgoCD）の動作原理を再現する

REPO_DIR="$1"
LIVE_DIR="$2"

echo "[Reconcile] === リコンシリエーション開始 ==="

# Step 1: Observe - Gitリポジトリの望ましい状態を取得
DESIRED=$(cat "${REPO_DIR}/desired-state.json")
echo "[Reconcile] Step 1 (Observe): Gitリポジトリから望ましい状態を取得"

# Step 2: Diff - 望ましい状態と実際の状態を比較
CURRENT=$(cat "${LIVE_DIR}/current-state.json")

if [ "$DESIRED" = "$CURRENT" ]; then
    echo "[Reconcile] Step 2 (Diff): 差異なし -- 望ましい状態と一致"
    echo "[Reconcile] === リコンシリエーション完了（変更なし）==="
    exit 0
fi

echo "[Reconcile] Step 2 (Diff): 差異を検出"
echo ""
echo "  望ましい状態 (Git):"
echo "$DESIRED" | head -5
echo "  ..."
echo ""
echo "  実際の状態 (Live):"
echo "$CURRENT" | head -5
echo "  ..."
echo ""

# Step 3: Act - 差異を修正（望ましい状態を適用）
echo "[Reconcile] Step 3 (Act): 望ましい状態を適用中..."
cp "${REPO_DIR}/desired-state.json" "${LIVE_DIR}/current-state.json"

# デプロイ結果の記録（監査ログ）
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_HASH=$(cd "${REPO_DIR}" && git rev-parse --short HEAD)
echo "${TIMESTAMP} Applied commit ${COMMIT_HASH}" >> "${LIVE_DIR}/deploy-log.txt"

echo "[Reconcile] === リコンシリエーション完了（変更を適用）==="
echo "[Reconcile] 適用元コミット: ${COMMIT_HASH}"
RECONCILE_EOF
chmod +x reconcile.sh

# 初回のリコンシリエーションを実行
echo "--- 初回リコンシリエーション ---"
bash reconcile.sh gitops-repo live-state
echo ""

echo "--- 適用後の本番環境の状態 ---"
cat live-state/current-state.json
echo ""

echo "--- デプロイログ ---"
cat live-state/deploy-log.txt
echo ""

# 再度リコンシリエーションを実行（差異なし）
echo "--- 2回目のリコンシリエーション（差異なし）---"
bash reconcile.sh gitops-repo live-state
echo ""
echo "-> 差異がなければ何もしない。これがReconciliation Loopの基本動作"
echo ""

# --- 演習3: git commitによるデプロイ ---
echo "[演習3] git commitによるデプロイ"
echo ""

cd "${WORKDIR}/gitops-repo"

# 変更をコミット: バージョンアップとレプリカ数の変更
cat > desired-state.json << 'EOF'
{
  "app": {
    "name": "web-frontend",
    "version": "1.1.0",
    "replicas": 3,
    "port": 8080,
    "env": {
      "LOG_LEVEL": "info",
      "MAX_CONNECTIONS": "200"
    }
  }
}
EOF

git add desired-state.json
git commit --quiet -m "Update web-frontend to v1.1.0, scale to 3 replicas"

echo "--- 変更内容（git diff）---"
git log --oneline -2
echo ""
git diff HEAD~1 -- desired-state.json
echo ""

# リコンシリエーションを実行
echo "--- リコンシリエーション実行 ---"
cd "${WORKDIR}"
bash reconcile.sh gitops-repo live-state
echo ""

echo "--- 更新後の本番環境の状態 ---"
cat live-state/current-state.json
echo ""

echo "-> git commitが「デプロイ」として機能する"
echo "   変更の記録（誰が、いつ、なぜ）はgit logに残る"
echo ""

# --- 演習4: git revertによるロールバック ---
echo "[演習4] git revertによるロールバック"
echo ""

cd "${WORKDIR}/gitops-repo"

echo "--- ロールバック前のコミット履歴 ---"
git log --oneline
echo ""

# git revert で直前の変更を取り消す
git revert --no-edit HEAD

echo "--- ロールバック後のコミット履歴 ---"
git log --oneline
echo ""

echo "--- revert後の望ましい状態 ---"
cat desired-state.json
echo ""

# リコンシリエーションを実行
cd "${WORKDIR}"
bash reconcile.sh gitops-repo live-state
echo ""

echo "--- ロールバック後の本番環境の状態 ---"
cat live-state/current-state.json
echo ""

echo "--- 全デプロイログ ---"
cat live-state/deploy-log.txt
echo ""

echo "-> git revertが「ロールバック」として機能する"
echo "   ロールバックの履歴もgit logに監査証跡として残る"
echo ""

# --- 演習5: ドリフト検知と自動修復 ---
echo "[演習5] ドリフト検知と自動修復"
echo ""

cd "${WORKDIR}"

echo "--- 現在の本番環境の状態 ---"
echo "  version: $(cat live-state/current-state.json | jq -r '.app.version')"
echo ""

# 誰かが手動で本番環境を変更してしまった（ドリフト）
echo "--- 手動変更によるドリフトをシミュレート ---"
cat > live-state/current-state.json << 'EOF'
{
  "app": {
    "name": "web-frontend",
    "version": "1.0.0-hotfix",
    "replicas": 1,
    "port": 8080,
    "env": {
      "LOG_LEVEL": "debug",
      "MAX_CONNECTIONS": "50"
    }
  }
}
EOF

echo "手動変更後の状態:"
echo "  version: $(cat live-state/current-state.json | jq -r '.app.version')"
echo "  replicas: $(cat live-state/current-state.json | jq -r '.app.replicas')"
echo ""

# リコンシリエーションを実行
echo "--- リコンシリエーション実行（ドリフト検知）---"
bash reconcile.sh gitops-repo live-state
echo ""

echo "--- 修復後の本番環境の状態 ---"
echo "  version: $(cat live-state/current-state.json | jq -r '.app.version')"
echo "  replicas: $(cat live-state/current-state.json | jq -r '.app.replicas')"
echo ""

echo "-> 手動変更（ドリフト）はReconciliation Loopにより自動修復される"
echo "   これがGitOpsの「自己修復（Self-Healing）」特性"
echo ""

# --- まとめ ---
echo "=========================================="
echo "ハンズオン完了"
echo ""
echo "このハンズオンで体験したこと:"
echo "  1. 宣言的な状態定義（Single Source of Truth）"
echo "  2. Reconciliation Loop（Observe / Diff / Act）"
echo "  3. git commitによるデプロイ"
echo "  4. git revertによるロールバック"
echo "  5. ドリフト検知と自動修復（Self-Healing）"
echo ""
echo "実際のGitOps環境では、Flux CDやArgoCDがこのループを"
echo "Kubernetesクラスタ内で継続的に実行している"
echo "=========================================="
