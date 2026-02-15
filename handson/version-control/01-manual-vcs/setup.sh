#!/bin/bash
# =============================================================================
# 第1回ハンズオン：gitを使わずにバージョン管理する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: diff, patch, diff3 (通常プリインストール済み)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson"

echo "=== 第1回ハンズオン：gitを使わずにバージョン管理する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}/project"
mkdir -p "${WORKDIR}/patches"

# --- 演習1: スナップショットの手動管理 ---
echo "[演習1] スナップショットの手動管理"

# 最初のバージョンを作成
cat > "${WORKDIR}/project/hello.sh" << 'SCRIPT'
#!/bin/bash
# hello.sh - 挨拶スクリプト v1
echo "Hello, World!"
SCRIPT
chmod +x "${WORKDIR}/project/hello.sh"

# v1のスナップショットを取得
cp -r "${WORKDIR}/project" "${WORKDIR}/project_v1"
echo "  v1 スナップショット作成完了"

# v2に変更
cat > "${WORKDIR}/project/hello.sh" << 'SCRIPT'
#!/bin/bash
# hello.sh - 挨拶スクリプト v2
NAME=${1:-"World"}
echo "Hello, ${NAME}!"
echo "Today is $(date +%Y-%m-%d)"
SCRIPT

# 差分を確認・保存
diff -u "${WORKDIR}/project_v1/hello.sh" "${WORKDIR}/project/hello.sh" \
  > "${WORKDIR}/patches/v1_to_v2.patch" || true
echo "  v1→v2 パッチ作成完了"
echo ""

# --- 演習2: patchで変更を適用 ---
echo "[演習2] patchで変更を適用"

cp -r "${WORKDIR}/project_v1" "${WORKDIR}/project_restored"
cd "${WORKDIR}/project_restored"
patch < "${WORKDIR}/patches/v1_to_v2.patch"

if diff -q "${WORKDIR}/project/hello.sh" "${WORKDIR}/project_restored/hello.sh" > /dev/null 2>&1; then
  echo "  パッチ適用成功: v2と完全一致"
else
  echo "  パッチ適用結果: 差異あり（要確認）"
fi
echo ""

# --- 演習3: 手動マージ ---
echo "[演習3] 手動マージの準備"

# Alice: エラーハンドリング追加
cp -r "${WORKDIR}/project_v1" "${WORKDIR}/work_alice"
cat > "${WORKDIR}/work_alice/hello.sh" << 'SCRIPT'
#!/bin/bash
# hello.sh - 挨拶スクリプト（Alice版）
if [ -z "$BASH_VERSION" ]; then
  echo "Error: This script requires bash" >&2
  exit 1
fi
echo "Hello, World!"
SCRIPT

# Bob: 多言語対応追加
cp -r "${WORKDIR}/project_v1" "${WORKDIR}/work_bob"
cat > "${WORKDIR}/work_bob/hello.sh" << 'SCRIPT'
#!/bin/bash
# hello.sh - 挨拶スクリプト（Bob版）
LANG=${1:-"en"}
case $LANG in
  ja) echo "こんにちは、世界！" ;;
  en) echo "Hello, World!" ;;
  *)  echo "Hello, World!" ;;
esac
SCRIPT

echo "  Alice版とBob版を作成完了"
echo ""

echo "=== Aliceの変更 ==="
diff -u "${WORKDIR}/project_v1/hello.sh" "${WORKDIR}/work_alice/hello.sh" || true
echo ""

echo "=== Bobの変更 ==="
diff -u "${WORKDIR}/project_v1/hello.sh" "${WORKDIR}/work_bob/hello.sh" || true
echo ""

echo "=== 3-way merge (diff3) ==="
echo "以下がマージ結果です。コンフリクトマーカー (<<<<<<<, =======, >>>>>>>) を"
echo "手動で解消してください。"
echo ""
diff3 -m "${WORKDIR}/work_alice/hello.sh" \
         "${WORKDIR}/project_v1/hello.sh" \
         "${WORKDIR}/work_bob/hello.sh" || true

echo ""
echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ディレクトリ構成:"
ls -1 "${WORKDIR}/"
