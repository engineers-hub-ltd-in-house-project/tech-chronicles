#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-09"

echo "============================================"
echo " 第9回ハンズオン: シェルの二つの文化"
echo " スクリプティングと対話の乖離"
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
if command -v dash > /dev/null 2>&1; then
    echo "  dash: インストール済み"
else
    echo "  dash: 未インストール（apt-get install -y dash でインストールしてください）"
fi

if command -v checkbashisms > /dev/null 2>&1; then
    echo "  checkbashisms: インストール済み"
else
    echo "  checkbashisms: 未インストール（apt-get install -y devscripts でインストールしてください）"
fi

if command -v shellcheck > /dev/null 2>&1; then
    echo "  shellcheck: インストール済み"
else
    echo "  shellcheck: 未インストール（apt-get install -y shellcheck でインストールしてください）"
fi
echo ""

# -------------------------------------------
# セクション3: bashism デモスクリプトの作成
# -------------------------------------------
echo "--- セクション3: bashism デモスクリプトの作成 ---"

cat > "${WORKDIR}/bashism-demo.sh" << 'SCRIPT'
#!/bin/sh
# このスクリプトは #!/bin/sh と宣言しているが、
# 実際にはbash固有の機能に依存している

echo "=== bashism デモスクリプト ==="

# bashism 1: [[ ]] 条件式
name="report.txt"
if [[ "$name" == *.txt ]]; then
    echo "1. テキストファイルを検出: $name"
fi

# bashism 2: 配列
fruits=(apple banana cherry)
echo "2. 果物の数: ${#fruits[@]}"
echo "   最初の果物: ${fruits[0]}"

# bashism 3: ブレース展開
echo "3. 連番: $(echo {1..5})"

# bashism 4: ヒアストリング
read -r line <<< "hello world"
echo "4. ヒアストリング: $line"

# bashism 5: source コマンド
echo 'MY_VAR="sourced"' > /tmp/bashism-vars.sh
source /tmp/bashism-vars.sh
echo "5. source結果: $MY_VAR"

echo "=== 完了 ==="
SCRIPT
chmod +x "${WORKDIR}/bashism-demo.sh"
echo "  作成: bashism-demo.sh"

# -------------------------------------------
# セクション4: POSIX準拠版スクリプトの作成
# -------------------------------------------
echo "--- セクション4: POSIX準拠版スクリプトの作成 ---"

cat > "${WORKDIR}/posix-demo.sh" << 'SCRIPT'
#!/bin/sh
# POSIX準拠版: dashでもashでも動く

echo "=== POSIX準拠 デモスクリプト ==="

# 修正1: [[ ]] → case文
name="report.txt"
case "$name" in
    *.txt)
        echo "1. テキストファイルを検出: $name"
        ;;
esac

# 修正2: 配列 → ポジショナルパラメータ
set -- apple banana cherry
echo "2. 果物の数: $#"
echo "   最初の果物: $1"

# 修正3: ブレース展開 → seqコマンド
echo "3. 連番: $(seq 1 5 | tr '\n' ' ')"

# 修正4: ヒアストリング → パイプ
line=$(echo "hello world")
echo "4. パイプ代替: $line"

# 修正5: source → . (ドットコマンド)
echo 'MY_VAR="sourced"' > /tmp/posix-vars.sh
. /tmp/posix-vars.sh
echo "5. ドットコマンド結果: $MY_VAR"

echo "=== 完了 ==="
SCRIPT
chmod +x "${WORKDIR}/posix-demo.sh"
echo "  作成: posix-demo.sh"

# -------------------------------------------
# セクション5: 起動速度計測スクリプトの作成
# -------------------------------------------
echo "--- セクション5: 起動速度計測スクリプトの作成 ---"

cat > "${WORKDIR}/benchmark-startup.sh" << 'SCRIPT'
#!/bin/sh
# dashとbashの起動速度を比較する

ITERATIONS=1000

echo "=== シェル起動速度ベンチマーク (${ITERATIONS}回) ==="
echo ""

if command -v bash > /dev/null 2>&1; then
    echo "--- bash ---"
    time for i in $(seq 1 ${ITERATIONS}); do
        bash -c 'exit 0'
    done
    echo ""
fi

if command -v dash > /dev/null 2>&1; then
    echo "--- dash ---"
    time for i in $(seq 1 ${ITERATIONS}); do
        dash -c 'exit 0'
    done
    echo ""
fi

echo "=== ベンチマーク完了 ==="
SCRIPT
chmod +x "${WORKDIR}/benchmark-startup.sh"
echo "  作成: benchmark-startup.sh"

# -------------------------------------------
# セクション6: /bin/sh 調査スクリプトの作成
# -------------------------------------------
echo "--- セクション6: /bin/sh 調査スクリプトの作成 ---"

cat > "${WORKDIR}/check-binsh.sh" << 'SCRIPT'
#!/bin/sh
# /bin/sh の正体を調査する

echo "=== /bin/sh の正体調査 ==="
echo ""

echo "1. /bin/sh のリンク先:"
ls -la /bin/sh
echo ""

echo "2. /bin/sh のバージョン情報:"
/bin/sh --version 2>/dev/null || echo "   バージョン情報なし（dashまたはash）"
echo ""

echo "3. /bin/sh のシェルオプション:"
/bin/sh -c 'echo "   フラグ: $-"'
echo ""

echo "4. 利用可能なシェル一覧 (/etc/shells):"
if [ -f /etc/shells ]; then
    cat /etc/shells
else
    echo "   /etc/shells が存在しない"
fi
echo ""

echo "=== 調査完了 ==="
SCRIPT
chmod +x "${WORKDIR}/check-binsh.sh"
echo "  作成: check-binsh.sh"

# -------------------------------------------
# セクション7: 演習手順の表示
# -------------------------------------------
echo ""
echo "============================================"
echo " セットアップ完了"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "演習手順:"
echo ""
echo "  演習1: bashismsの観察"
echo "    bash ${WORKDIR}/bashism-demo.sh    # bash では動く"
echo "    dash ${WORKDIR}/bashism-demo.sh    # dash では壊れる"
echo ""
echo "  演習2: checkbashisms で検出"
echo "    checkbashisms ${WORKDIR}/bashism-demo.sh"
echo ""
echo "  演習3: POSIX準拠版を確認"
echo "    dash ${WORKDIR}/posix-demo.sh      # dash でも動く"
echo "    checkbashisms ${WORKDIR}/posix-demo.sh  # 警告なし"
echo ""
echo "  演習4: /bin/sh の正体確認"
echo "    sh ${WORKDIR}/check-binsh.sh"
echo ""
echo "  演習5: 起動速度比較"
echo "    bash ${WORKDIR}/benchmark-startup.sh"
echo ""
echo "  演習6: ShellCheck活用"
echo "    shellcheck --shell=sh ${WORKDIR}/bashism-demo.sh"
echo "    shellcheck --shell=bash ${WORKDIR}/bashism-demo.sh"
echo ""
