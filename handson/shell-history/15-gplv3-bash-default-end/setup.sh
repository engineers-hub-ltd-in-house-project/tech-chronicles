#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-15"

echo "============================================"
echo " 第15回ハンズオン: GPLv3とbashデフォルト時代の終焉"
echo " bash 3.2の制約とPOSIX準拠の実践"
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

# 必要なパッケージのインストール
echo "必要なパッケージをインストール中..."
apt-get update -qq && apt-get install -y -qq devscripts dash zsh >/dev/null 2>&1
echo "パッケージインストール完了"
echo ""

# -------------------------------------------
# セクション2: bash バージョン間の機能差異
# -------------------------------------------
echo "=== 演習1: bash バージョン間の機能差異 ==="
echo ""

echo "--- 現在のbashバージョン ---"
echo "bash: ${BASH_VERSION}"

# 連想配列（bash 4.0+）
echo ""
echo "--- 連想配列（bash 4.0で追加）---"

if (( BASH_VERSINFO[0] >= 4 )); then
    declare -A fruits
    fruits[apple]="red"
    fruits[banana]="yellow"
    fruits[grape]="purple"
    echo "連想配列が使用可能:"
    for key in "${!fruits[@]}"; do
        echo "  ${key} -> ${fruits[$key]}"
    done
    unset fruits
else
    echo "bash ${BASH_VERSION}: 連想配列は使用不可（bash 4.0以降が必要）"
fi

# globstar（bash 4.0+）
echo ""
echo "--- globstar（bash 4.0で追加）---"

mkdir -p "${WORKDIR}/globtest/sub1/sub2"
touch "${WORKDIR}/globtest/a.txt" "${WORKDIR}/globtest/sub1/b.txt" "${WORKDIR}/globtest/sub1/sub2/c.txt"

if (( BASH_VERSINFO[0] >= 4 )); then
    shopt -s globstar
    echo "globstar有効: 再帰的にファイルを検索"
    for f in "${WORKDIR}"/globtest/**/*.txt; do
        echo "  ${f}"
    done
    shopt -u globstar
else
    echo "bash ${BASH_VERSION}: globstarは使用不可"
fi

echo "findによる代替（どのバージョンでも動作）:"
find "${WORKDIR}/globtest" -name "*.txt" | sort | while read -r f; do
    echo "  ${f}"
done

rm -rf "${WORKDIR}/globtest"

# nameref変数（bash 4.3+）
echo ""
echo "--- nameref変数（bash 4.3で追加）---"

if (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 3) )); then
    target="world"
    declare -n ref=target
    echo "nameref: ref -> target = ${ref}"
    ref="hello"
    echo "refを変更 -> target = ${target}"
    unset -n ref
    unset target
else
    echo "bash ${BASH_VERSION}: namerefは使用不可（bash 4.3以降が必要）"
fi

# パラメータ変換（bash 4.4+）
echo ""
echo "--- パラメータ変換（bash 4.4で追加）---"

if (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4) )); then
    sample="hello world"
    echo "元の値: ${sample}"
    echo "大文字変換 @U: ${sample@U}"
    echo "クォート @Q: ${sample@Q}"
    unset sample
else
    echo "bash ${BASH_VERSION}: パラメータ変換は使用不可（bash 4.4以降が必要）"
fi

# EPOCHSECONDS（bash 5.0+）
echo ""
echo "--- エポック秒変数（bash 5.0で追加）---"

if (( BASH_VERSINFO[0] >= 5 )); then
    echo "EPOCHSECONDS: ${EPOCHSECONDS}"
    echo "EPOCHREALTIME: ${EPOCHREALTIME}"
else
    echo "bash ${BASH_VERSION}: EPOCHSECONDS/EPOCHREALTIMEは使用不可（bash 5.0以降が必要）"
fi
echo "代替: date +%s = $(date +%s)"

echo ""

# -------------------------------------------
# セクション3: bash依存コードのPOSIX準拠化
# -------------------------------------------
echo "=== 演習2: bash依存コードのPOSIX準拠への書き換え ==="
echo ""

# bash依存スクリプト
cat << 'BASH_SCRIPT' > "${WORKDIR}/bash_dependent.sh"
#!/bin/bash
# bash依存の機能を使ったスクリプト

# bash拡張: [[ ]] による条件評価
filename="test file.txt"
if [[ -n "$filename" && "$filename" == *.txt ]]; then
    echo "テキストファイル: $filename"
fi

# bash拡張: 配列
files=(one.txt two.txt three.txt)
echo "ファイル数: ${#files[@]}"
for f in "${files[@]}"; do
    echo "  $f"
done

# bash拡張: here string <<<
read -r first_word <<< "hello world"
echo "最初の単語: $first_word"

# bash拡張: {1..5} ブレース展開
for i in {1..5}; do
    echo "  カウント: $i"
done
BASH_SCRIPT

echo "--- bash依存スクリプトのcheckbashisms結果 ---"
checkbashisms "${WORKDIR}/bash_dependent.sh" 2>&1 || true

echo ""
echo "--- POSIX準拠に書き換えたスクリプト ---"

cat << 'POSIX_SCRIPT' > "${WORKDIR}/posix_compliant.sh"
#!/bin/sh
# POSIX準拠: dashやashでも動作する

# POSIX: [ ] による条件評価（testコマンド）
filename="test file.txt"
if [ -n "$filename" ]; then
    case "$filename" in
        *.txt) echo "テキストファイル: $filename" ;;
    esac
fi

# POSIX: 配列の代替（位置パラメータ）
set -- one.txt two.txt three.txt
echo "ファイル数: $#"
for f in "$@"; do
    echo "  $f"
done

# POSIX: here stringの代替（パイプ）
first_word=$(echo "hello world" | cut -d' ' -f1)
echo "最初の単語: $first_word"

# POSIX: ブレース展開の代替（whileループ）
i=1
while [ "$i" -le 5 ]; do
    echo "  カウント: $i"
    i=$((i + 1))
done
POSIX_SCRIPT

echo ""
echo "--- POSIX準拠スクリプトのcheckbashisms結果 ---"
checkbashisms "${WORKDIR}/posix_compliant.sh" 2>&1 && echo "checkbashisms: 問題なし"

echo ""
echo "--- POSIX準拠スクリプトをdashで実行 ---"
dash "${WORKDIR}/posix_compliant.sh"

echo ""

# -------------------------------------------
# セクション4: /bin/shの実体と挙動差異
# -------------------------------------------
echo "=== 演習3: /bin/shの実体と挙動差異 ==="
echo ""

echo "--- /bin/sh の実体 ---"
ls -la /bin/sh
readlink -f /bin/sh 2>/dev/null || echo "(readlinkが使えない環境)"

cat << 'TEST_SCRIPT' > "${WORKDIR}/sh_test.sh"
#!/bin/sh

# テスト1: [[ ]] （bash拡張）
echo "テスト1: [[ ]] 条件式"
if eval '[[ "hello" == h* ]]' 2>/dev/null; then
    echo "  [[ ]] は使用可能（bashまたは互換シェル）"
else
    echo "  [[ ]] は使用不可（純粋なPOSIXシェル）"
fi

# テスト2: $RANDOM（POSIX未規定）
echo "テスト2: \$RANDOM"
if [ -n "$RANDOM" ]; then
    echo "  RANDOM=${RANDOM}（使用可能）"
else
    echo "  RANDOMは未定義（純粋なPOSIXシェル）"
fi

# テスト3: local変数（POSIXでは未規定だが広く実装）
echo "テスト3: local変数"
test_local() {
    local var="local_value" 2>/dev/null
    if [ "$var" = "local_value" ]; then
        echo "  localは使用可能"
    else
        echo "  localは使用不可"
    fi
}
test_local
TEST_SCRIPT

echo ""
echo "--- /bin/bash で実行 ---"
/bin/bash "${WORKDIR}/sh_test.sh"

echo ""
echo "--- dash で実行（POSIX準拠シェル）---"
dash "${WORKDIR}/sh_test.sh"

echo ""

# -------------------------------------------
# セクション5: ソフトウェアライセンスの確認
# -------------------------------------------
echo "=== 演習4: ソフトウェアライセンスの確認 ==="
echo ""

echo "--- bash のライセンス ---"
bash --version | head -2
echo ""
if [ -f /usr/share/doc/bash/copyright ]; then
    echo "ライセンスファイル:"
    head -15 /usr/share/doc/bash/copyright
elif [ -f /usr/share/licenses/bash/COPYING ]; then
    head -5 /usr/share/licenses/bash/COPYING
else
    echo "  bash ${BASH_VERSION} は GPLv3+ でライセンスされている"
fi

echo ""
echo "--- dash のライセンス ---"
if [ -f /usr/share/doc/dash/copyright ]; then
    echo "ライセンスファイル:"
    head -15 /usr/share/doc/dash/copyright
else
    echo "  dash は BSD 3-Clause でライセンスされている"
fi

echo ""
echo "--- zsh のライセンス ---"
if [ -f /usr/share/doc/zsh-common/copyright ]; then
    echo "ライセンスファイル:"
    head -20 /usr/share/doc/zsh-common/copyright
elif [ -f /usr/share/doc/zsh/copyright ]; then
    echo "ライセンスファイル:"
    head -20 /usr/share/doc/zsh/copyright
else
    echo "  zsh は MIT-like ライセンスでライセンスされている"
fi

echo ""
echo "--- ライセンス比較サマリ ---"
echo "  bash 3.2以前: GPLv2"
echo "  bash 4.0以降: GPLv3"
echo "  dash:         BSD 3-Clause"
echo "  zsh:          MIT-like"
echo "  fish:         GPLv2"
echo ""
echo "  Apple が受け入れ可能: GPLv2, BSD, MIT, Apache 2.0"
echo "  Apple が拒否:         GPLv3"

echo ""

# -------------------------------------------
# クリーンアップ
# -------------------------------------------
echo "============================================"
echo " ハンズオン完了"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "作成されたファイル:"
find "${WORKDIR}" -type f | sort | while read -r f; do
    echo "  ${f}"
done
echo ""
echo "クリーンアップ: rm -rf ${WORKDIR}"
