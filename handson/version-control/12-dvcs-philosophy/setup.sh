#!/bin/bash
# =============================================================================
# 第12回ハンズオン：Monotoneを体験する——Gitの「前夜」に触れる
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: monotone (mtn)
# 推奨環境: docker run -it --rm ubuntu:24.04 bash
#            apt update && apt install -y monotone
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-12"

echo "=== 第12回ハンズオン：Monotoneを体験する——Gitの「前夜」に触れる ==="
echo ""

# 既存ディレクトリのクリーンアップ
if [ -d "${WORKDIR}" ]; then
  rm -rf "${WORKDIR}"
fi
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- 演習1: Monotoneデータベースの作成とリビジョンの記録 ---
echo "[演習1] Monotoneデータベースの作成とリビジョンの記録"

# RSA鍵ペアの生成（空パスフレーズ）
echo ""
echo "--- RSA鍵ペアを生成 ---"
mtn genkey handson@example.com --db=project.mtn 2>&1 <<'PASSEOF'


PASSEOF
echo "-> MonotoneではRSA鍵による認証が必須"
echo "-> 「誰がこの変更を行ったか」が暗号学的に検証可能"

# ワークスペースの作成とファイルの追加
echo ""
echo "--- ワークスペースを初期化 ---"
mtn setup --branch=com.example.project --db=project.mtn workspace
cd workspace

cat > hello.c << 'EOF'
#include <stdio.h>

int main(void) {
    printf("Hello from Monotone!\n");
    return 0;
}
EOF

mtn add hello.c
echo ""
echo "--- 最初のコミット ---"
mtn commit -m "Add hello.c" --author=handson@example.com 2>&1 || true
echo ""
echo "--- リビジョン一覧 ---"
mtn log --brief 2>&1 | head -5
echo ""
echo "-> リビジョンがSHA-1ハッシュで識別されている"
echo "-> Subversionの連番（r1, r2, ...）とは根本的に異なるモデル"
echo ""

# --- 演習2: ブランチとDAGの構造を確認する ---
echo "[演習2] ブランチとDAGの構造を確認する"

# 二つ目のコミット
cat > hello.c << 'EOF'
#include <stdio.h>

int main(void) {
    printf("Hello from Monotone!\n");
    printf("Revision control with cryptographic integrity.\n");
    return 0;
}
EOF

mtn commit -m "Add description line" --author=handson@example.com 2>&1 || true

echo ""
echo "--- リビジョン一覧（DAGの確認）---"
mtn log --brief 2>&1 | head -10
echo ""
echo "--- 特定リビジョンの詳細 ---"
LATEST=$(mtn automate heads 2>/dev/null | head -1)
if [ -n "${LATEST}" ]; then
  mtn log --to "${LATEST}" --last=1 2>&1
fi
echo ""
echo "-> 各リビジョンが親リビジョンのハッシュを参照"
echo "-> これがDAG（有向非巡回グラフ）の構造"
echo "-> Git の git log --graph と同じ概念"
echo ""

# --- 演習3: MonotoneとGitの概念的対応 ---
echo "[演習3] MonotoneとGitの概念的対応"

echo ""
echo "Monotoneの設計思想とGitの対応:"
echo ""
echo "  Monotone                    Git"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SHA-1リビジョン識別   →    SHA-1コミットハッシュ"
echo "  RSA署名による認証     →    GPG署名（オプション）"
echo "  SQLiteバックエンド    →    ファイルシステム直接"
echo "  netsyncプロトコル     →    git://, ssh://, https://"
echo "  DAGベースの履歴       →    DAGベースの履歴"
echo ""
echo "Gitが変えたこと:"
echo "  - SQLiteの代わりにファイルシステムを直接使用（性能重視）"
echo "  - 暗号署名を必須ではなくオプションに（参入障壁の低減）"
echo "  - Linuxカーネル規模での性能を最優先に設計"
echo ""
echo "-> Monotoneのアイデアの多くがGitに受け継がれた"
echo "-> 最大の違いは「性能へのこだわり」"

echo ""
echo "=== ハンズオン完了 ==="
echo ""
echo "このハンズオンで確認したこと:"
echo "  1. MonotoneはRSA鍵による暗号学的認証を必須とした"
echo "  2. リビジョンはSHA-1ハッシュで識別される（Gitと同じ概念）"
echo "  3. 履歴はDAG（有向非巡回グラフ）で表現される"
echo "  4. Monotoneの設計思想の多くがGitに受け継がれた"
echo "  5. Gitは性能を最優先に再設計し、Monotoneを超えた"
