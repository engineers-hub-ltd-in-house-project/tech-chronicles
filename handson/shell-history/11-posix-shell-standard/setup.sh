#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-11"

echo "============================================"
echo " 第11回ハンズオン: POSIXシェル標準"
echo " 誰も読まない契約書"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

# -------------------------------------------
# セクション1: 作業ディレクトリの準備
# -------------------------------------------
echo "--- セクション1: 作業ディレクトリの準備 ---"
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# -------------------------------------------
# セクション2: 必要パッケージの確認
# -------------------------------------------
echo "--- セクション2: 必要パッケージの確認 ---"
if command -v bash > /dev/null 2>&1; then
    echo "  bash: インストール済み ($(bash --version | head -1))"
else
    echo "  bash: 未インストール"
fi

if command -v dash > /dev/null 2>&1; then
    echo "  dash: インストール済み"
else
    echo "  dash: 未インストール"
fi

if command -v shellcheck > /dev/null 2>&1; then
    echo "  shellcheck: インストール済み ($(shellcheck --version | grep '^version:' | awk '{print $2}'))"
else
    echo "  shellcheck: 未インストール（apt-get install -y shellcheck でインストールしてください）"
fi

if command -v checkbashisms > /dev/null 2>&1; then
    echo "  checkbashisms: インストール済み"
else
    echo "  checkbashisms: 未インストール（apt-get install -y devscripts でインストールしてください）"
fi

echo ""

# -------------------------------------------
# セクション3: bashismsを含むスクリプトの作成
# -------------------------------------------
echo "--- セクション3: bashismsを含むスクリプトの作成 ---"

cat << 'SCRIPT' > "${WORKDIR}/bashisms_demo.sh"
#!/bin/sh
# このスクリプトは /bin/sh を宣言しているが、bashisms を含む

# bashism 1: [[ ]]
if [[ -f /etc/passwd ]]; then
    echo "passwd found"
fi

# bashism 2: 配列
files=(one.txt two.txt three.txt)
echo "Count: ${#files[@]}"

# bashism 3: function キーワード
function greet {
    echo "hello"
}
greet

# bashism 4: source
echo 'echo sourced' > /tmp/helper_11.sh
source /tmp/helper_11.sh

# bashism 5: == in test
if [ "$USER" == "root" ]; then
    echo "root user"
fi
SCRIPT
chmod +x "${WORKDIR}/bashisms_demo.sh"
echo "  作成: bashisms_demo.sh"

# -------------------------------------------
# セクション4: POSIX準拠版スクリプトの作成
# -------------------------------------------
echo "--- セクション4: POSIX準拠版スクリプトの作成 ---"

cat << 'SCRIPT' > "${WORKDIR}/posix_demo.sh"
#!/bin/sh
# POSIX準拠版

# 修正1: [[ ]] → [ ]
if [ -f /etc/passwd ]; then
    echo "passwd found"
fi

# 修正2: 配列 → 位置パラメータ
set -- one.txt two.txt three.txt
echo "Count: $#"

# 修正3: function キーワード → name() 構文
greet() {
    echo "hello"
}
greet

# 修正4: source → .（ドットコマンド）
echo 'echo sourced' > /tmp/helper_11.sh
. /tmp/helper_11.sh

# 修正5: == → =
if [ "$USER" = "root" ]; then
    echo "root user"
fi
SCRIPT
chmod +x "${WORKDIR}/posix_demo.sh"
echo "  作成: posix_demo.sh"

# -------------------------------------------
# セクション5: bash依存デプロイスクリプト
# -------------------------------------------
echo "--- セクション5: bash依存デプロイスクリプト ---"

cat << 'SCRIPT' > "${WORKDIR}/deploy_bash.sh"
#!/bin/bash
set -euo pipefail

TARGETS=(web01 web02 web03)
DEPLOY_DIR="/var/www/app"
LOG_FILE="/tmp/deploy_$(date +%Y%m%d_%H%M%S).log"

function log {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" | tee -a "$LOG_FILE"
}

function deploy_to {
    local target=$1
    log "Deploying to ${target}..."

    if [[ -z "$target" ]]; then
        log "ERROR: target is empty"
        return 1
    fi

    log "  rsync to ${target}:${DEPLOY_DIR}"
    log "  Restarting service on ${target}"
    log "  Deploy to ${target} completed"
}

log "=== Deploy started ==="
log "Targets: ${TARGETS[*]}"

for target in "${TARGETS[@]}"; do
    deploy_to "$target"
done

log "=== Deploy finished ==="
echo "Log: $LOG_FILE"
SCRIPT
chmod +x "${WORKDIR}/deploy_bash.sh"
echo "  作成: deploy_bash.sh"

# -------------------------------------------
# セクション6: POSIX準拠デプロイスクリプト
# -------------------------------------------
echo "--- セクション6: POSIX準拠デプロイスクリプト ---"

cat << 'SCRIPT' > "${WORKDIR}/deploy_posix.sh"
#!/bin/sh
set -eu

TARGETS="web01 web02 web03"
DEPLOY_DIR="/var/www/app"
LOG_FILE="/tmp/deploy_$(date +%Y%m%d_%H%M%S).log"

log() {
    _log_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${_log_timestamp}] $*" | tee -a "$LOG_FILE"
}

deploy_to() {
    _deploy_target=$1
    log "Deploying to ${_deploy_target}..."

    if [ -z "$_deploy_target" ]; then
        log "ERROR: target is empty"
        return 1
    fi

    log "  rsync to ${_deploy_target}:${DEPLOY_DIR}"
    log "  Restarting service on ${_deploy_target}"
    log "  Deploy to ${_deploy_target} completed"
}

log "=== Deploy started ==="
log "Targets: ${TARGETS}"

for target in $TARGETS; do
    deploy_to "$target"
done

log "=== Deploy finished ==="
echo "Log: $LOG_FILE"
SCRIPT
chmod +x "${WORKDIR}/deploy_posix.sh"
echo "  作成: deploy_posix.sh"

# -------------------------------------------
# セクション7: 実行テスト
# -------------------------------------------
echo ""
echo "--- セクション7: 実行テスト ---"

echo ""
echo "=== bashisms_demo.sh を bash で実行 ==="
if command -v bash > /dev/null 2>&1; then
    bash "${WORKDIR}/bashisms_demo.sh" 2>&1 || true
fi

echo ""
echo "=== bashisms_demo.sh を dash で実行（エラーが出る） ==="
if command -v dash > /dev/null 2>&1; then
    dash "${WORKDIR}/bashisms_demo.sh" 2>&1 || true
else
    echo "  dash が未インストールのためスキップ"
fi

echo ""
echo "=== posix_demo.sh を dash で実行（正常動作する） ==="
if command -v dash > /dev/null 2>&1; then
    dash "${WORKDIR}/posix_demo.sh" 2>&1 || true
else
    /bin/sh "${WORKDIR}/posix_demo.sh" 2>&1 || true
fi

# -------------------------------------------
# セクション8: checkbashisms による検出
# -------------------------------------------
echo ""
echo "--- セクション8: checkbashisms による検出 ---"
if command -v checkbashisms > /dev/null 2>&1; then
    echo "=== bashisms_demo.sh のチェック ==="
    checkbashisms "${WORKDIR}/bashisms_demo.sh" 2>&1 || true
    echo ""
    echo "=== posix_demo.sh のチェック ==="
    checkbashisms "${WORKDIR}/posix_demo.sh" 2>&1 || true
else
    echo "  checkbashisms が未インストールのためスキップ"
    echo "  apt-get install -y devscripts でインストール可能"
fi

# -------------------------------------------
# セクション9: ShellCheck による検証
# -------------------------------------------
echo ""
echo "--- セクション9: ShellCheck による検証 ---"
if command -v shellcheck > /dev/null 2>&1; then
    echo "=== bashisms_demo.sh を POSIX sh としてチェック ==="
    shellcheck --shell=sh "${WORKDIR}/bashisms_demo.sh" 2>&1 || true
    echo ""
    echo "=== posix_demo.sh を POSIX sh としてチェック ==="
    shellcheck --shell=sh "${WORKDIR}/posix_demo.sh" 2>&1 || true
    echo ""
    echo "=== deploy_posix.sh を POSIX sh としてチェック ==="
    shellcheck --shell=sh "${WORKDIR}/deploy_posix.sh" 2>&1 || true
else
    echo "  shellcheck が未インストールのためスキップ"
    echo "  apt-get install -y shellcheck でインストール可能"
fi

# -------------------------------------------
# セクション10: まとめ
# -------------------------------------------
echo ""
echo "============================================"
echo " ハンズオン完了"
echo "============================================"
echo ""
echo "作成されたファイル:"
echo "  ${WORKDIR}/bashisms_demo.sh    -- bashisms を含むスクリプト"
echo "  ${WORKDIR}/posix_demo.sh       -- POSIX準拠版"
echo "  ${WORKDIR}/deploy_bash.sh      -- bash依存デプロイスクリプト"
echo "  ${WORKDIR}/deploy_posix.sh     -- POSIX準拠デプロイスクリプト"
echo ""
echo "追加演習:"
echo "  1. deploy_bash.sh を dash で実行し、エラーを確認する"
echo "  2. deploy_posix.sh を bash と dash の両方で実行し、同一結果を確認する"
echo "  3. 自分のスクリプトに checkbashisms と shellcheck --shell=sh を適用する"
echo ""
echo "Docker で Alpine Linux 環境を試す:"
echo "  docker run -it alpine:3.21 /bin/sh"
echo "  # コンテナ内で /bin/sh が BusyBox ash であることを確認"
echo "  # bash 非依存のスクリプトが正常に動作することを検証"
