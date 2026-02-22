#!/bin/bash
# =============================================================================
# 第18回ハンズオン：fishの世界を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 前提: Docker環境（ubuntu:24.04）またはapt-getが使えるLinux環境
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-18"

echo "=== 第18回ハンズオン：fishの世界を体験する ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# --- パッケージのインストール ---
echo "[準備] 必要なパッケージをインストール中..."

if command -v apt-get > /dev/null 2>&1; then
  apt-get update -qq
  apt-get install -y -qq fish dash time >/dev/null 2>&1
  echo "  fish, dash, time をインストールしました"
else
  echo "  apt-getが利用できません。手動でfishとdashをインストールしてください。"
fi

echo ""

# =============================================================================
# 演習1: fishの対話的機能を体験する
# =============================================================================
echo "=============================================="
echo " 演習1: fishの対話的機能を体験する"
echo "=============================================="
echo ""

fish -c "echo 'fishが動作しています。バージョン:'; fish --version"

echo ""
echo "fishの対話的機能を体験するには、fishを起動してください:"
echo "  fish"
echo ""
echo "以下の操作を試してください:"
echo "  1. 存在しないコマンドを入力（赤く表示される）: asdfgh"
echo "  2. 存在するコマンドを入力（色が変わる）: echo hello"
echo "  3. パスを入力（存在するパスは下線付き）: ls /etc"
echo "  4. コマンド実行後、同じ先頭文字を入力（サジェスチョンが表示される）"
echo "  5. 右矢印キーでサジェスチョンを確定"
echo ""
echo "=> これらすべてが設定ファイルなしで動作する"
echo ""

# =============================================================================
# 演習2: bashとfishの構文比較
# =============================================================================
echo "=============================================="
echo " 演習2: bashとfishの構文比較"
echo "=============================================="
echo ""

echo "--- bash版 ---"
bash << 'BASH_SCRIPT'
# 変数代入
greeting="Hello, World"
echo "bash: $greeting"

# 環境変数のエクスポート
export MY_ENV="from_bash"
echo "bash env: $MY_ENV"

# 配列
arr=(apple banana cherry)
echo "bash array[1]: ${arr[1]}"

# forループ
for fruit in "${arr[@]}"; do
    echo "  bash fruit: $fruit"
done

# コマンド置換
file_count=$(ls /etc/*.conf 2>/dev/null | wc -l)
echo "bash file_count: $file_count"

# 条件分岐
if [ -d /etc ]; then
    echo "bash: /etc exists"
fi
BASH_SCRIPT

echo ""
echo "--- fish版 ---"
fish << 'FISH_SCRIPT'
# 変数代入
set greeting "Hello, World"
echo "fish: $greeting"

# 環境変数のエクスポート
set -gx MY_ENV "from_fish"
echo "fish env: $MY_ENV"

# リスト（fishの配列）
set arr apple banana cherry
echo "fish arr[2]: $arr[2]"

# forループ
for fruit in $arr
    echo "  fish fruit: $fruit"
end

# コマンド置換
set file_count (ls /etc/*.conf 2>/dev/null | wc -l)
echo "fish file_count: $file_count"

# 条件分岐
if test -d /etc
    echo "fish: /etc exists"
end
FISH_SCRIPT

echo ""
echo "=> 主な違い:"
echo "   変数代入: VAR=value → set VAR value"
echo "   配列インデックス: 0-indexed → 1-indexed"
echo "   制御構造: do/done/fi → end"
echo "   コマンド置換: \$(cmd) → (cmd)"
echo ""

# =============================================================================
# 演習3: ワード分割の違い
# =============================================================================
echo "=============================================="
echo " 演習3: ワード分割の違い"
echo "=============================================="
echo ""

mkdir -p /tmp/word-split-test

echo "--- bash: ワード分割が起きる ---"
bash << 'BASH_SCRIPT'
cd /tmp/word-split-test
myvar="hello world"

# クォートなしで変数を使う
echo "引数の数（クォートなし）:"
printf "  %d個の引数\n" "$(echo $myvar | wc -w)"

# ファイル作成の違い
touch $myvar 2>/dev/null || true
echo "touchの結果（クォートなし）:"
ls -1 /tmp/word-split-test/ | while read -r f; do echo "  '$f'"; done
rm -f hello world

touch "$myvar" 2>/dev/null || true
echo "touchの結果（クォートあり）:"
ls -1 /tmp/word-split-test/ | while read -r f; do echo "  '$f'"; done
rm -f "hello world"
BASH_SCRIPT

echo ""
echo "--- fish: ワード分割が起きない ---"
fish << 'FISH_SCRIPT'
cd /tmp/word-split-test
set myvar "hello world"

# クォートなしでも変数は一つの引数
echo "変数の値: '$myvar'"

# ファイル作成
touch $myvar 2>/dev/null; or true
echo "touchの結果（クォートなし）:"
for f in (ls -1 /tmp/word-split-test/)
    echo "  '$f'"
end
rm -f "hello world"
FISH_SCRIPT

echo ""
echo "=> bashでは \$myvar がスペースで分割されて2つの引数になる"
echo "   fishでは \$myvar は常に1つの引数として扱われる"
echo "   第5回で見た「クォーティング地獄」の根本原因がここにある"
echo ""

rm -rf /tmp/word-split-test

# =============================================================================
# 演習4: Universal Variables
# =============================================================================
echo "=============================================="
echo " 演習4: Universal Variables"
echo "=============================================="
echo ""

fish << 'FISH_SCRIPT'
echo "--- ユニバーサル変数の設定と確認 ---"

# ユニバーサル変数の設定
set -U my_test_greeting "Hello from universal"
echo "設定: set -U my_test_greeting 'Hello from universal'"
echo "値: $my_test_greeting"

echo ""
echo "--- 変数スコープの確認 ---"

# ローカル変数でオーバーライド
function test_scope
    set -l my_test_greeting "Hello from local"
    echo "関数内（local）: $my_test_greeting"
end
test_scope
echo "関数外（universal）: $my_test_greeting"

echo ""
echo "--- 保存先の確認 ---"
echo "ファイル: ~/.config/fish/fish_variables"
if test -f ~/.config/fish/fish_variables
    echo "内容（my_test_greetingを含む行）:"
    grep "my_test_greeting" ~/.config/fish/fish_variables; or echo "  （見つかりません）"
else
    echo "（ファイルはfishの初回起動時に作成されます）"
end

echo ""
echo "=> set -U で設定した変数は:"
echo "   1. すべてのfishセッションで共有される"
echo "   2. シェルを終了しても永続する"
echo "   3. ~/.config/fish/fish_variables に保存される"

# クリーンアップ
set -e -U my_test_greeting 2>/dev/null; or true
FISH_SCRIPT

echo ""

# =============================================================================
# 演習5: 起動速度の比較
# =============================================================================
echo "=============================================="
echo " 演習5: 起動速度の比較"
echo "=============================================="
echo ""

echo "--- bash（設定なし）---"
for i in 1 2 3 4 5; do
    /usr/bin/time -f "  %e秒" bash --norc --noprofile -c "exit" 2>&1
done

echo ""
echo "--- fish（設定なし）---"
for i in 1 2 3 4 5; do
    /usr/bin/time -f "  %e秒" fish -N -c "exit" 2>&1
done

echo ""
echo "--- dash（比較用）---"
if command -v dash > /dev/null 2>&1; then
    for i in 1 2 3 4 5; do
        /usr/bin/time -f "  %e秒" dash -c "exit" 2>&1
    done
else
    echo "  dashがインストールされていません"
fi

echo ""
echo "=> fishの起動速度はbashと同等か、やや遅い傾向がある"
echo "   dashは最速（機能を削ぎ落とした設計の恩恵）"
echo "   fishは豊富な対話的機能の代償として起動コストがある"
echo ""

# =============================================================================
# 完了
# =============================================================================
echo "=============================================="
echo " ハンズオン完了"
echo "=============================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "次のステップ:"
echo "  1. fish を起動して対話的機能を体験する"
echo "  2. fish_config を実行してWeb-based configurationを試す"
echo "  3. bashスクリプトをfish構文に書き換える練習をする"
echo ""
echo "fishを終了するには exit と入力してください"
