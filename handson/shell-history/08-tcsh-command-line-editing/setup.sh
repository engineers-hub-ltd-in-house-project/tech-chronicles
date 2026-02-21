#!/bin/bash
# =============================================================================
# 第8回ハンズオン：tcshとコマンドライン編集――シェルがUIになった瞬間
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 前提: Docker環境（ubuntu:24.04）またはbashが使えるLinux環境
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-08"

echo "=== 第8回ハンズオン：tcshとコマンドライン編集 ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# 必要なパッケージのインストール確認
install_if_missing() {
  local cmd="$1"
  local pkg="$2"
  if command -v "$cmd" > /dev/null 2>&1; then
    echo "${cmd}: インストール済み"
  else
    echo "${cmd} をインストールします..."
    if command -v apt-get > /dev/null 2>&1; then
      apt-get update -qq && apt-get install -y -qq "$pkg"
    else
      echo "警告: ${cmd}を自動インストールできません。手動でインストールしてください。"
    fi
  fi
}

install_if_missing tcsh tcsh
install_if_missing dash dash
install_if_missing zsh zsh
echo ""

# bash-completionのインストール確認
if [ -f /usr/share/bash-completion/bash_completion ]; then
  echo "bash-completion: インストール済み"
else
  echo "bash-completion をインストールします..."
  if command -v apt-get > /dev/null 2>&1; then
    apt-get update -qq && apt-get install -y -qq bash-completion
  fi
fi
echo ""

# =============================================================================
echo "=========================================="
echo " 演習1: 補完なし（dash）の世界"
echo "=========================================="
echo ""

# テスト用のディレクトリ構造を作成
mkdir -p "${WORKDIR}/project-alpha/src/components"
mkdir -p "${WORKDIR}/project-alpha/src/utils"
mkdir -p "${WORKDIR}/project-beta/docs"
echo '<header>Hello</header>' > "${WORKDIR}/project-alpha/src/components/header.tsx"
echo '<footer>Footer</footer>' > "${WORKDIR}/project-alpha/src/components/footer.tsx"
echo 'export function format() {}' > "${WORKDIR}/project-alpha/src/utils/format.ts"
echo '# Project Beta' > "${WORKDIR}/project-beta/docs/readme.md"

echo "テスト用ディレクトリ構造を作成しました:"
echo ""
echo "${WORKDIR}/"
echo "  project-alpha/"
echo "    src/"
echo "      components/"
echo "        header.tsx"
echo "        footer.tsx"
echo "      utils/"
echo "        format.ts"
echo "  project-beta/"
echo "    docs/"
echo "      readme.md"
echo ""

echo "--- dashでの操作（補完なし）---"
echo ""
echo "dashにはコマンドライン補完がありません。"
echo "以下のコマンドを dash 内で手入力して体験してください:"
echo ""
echo "  dash"
echo "  ls ${WORKDIR}/project-alpha/src/components/"
echo "  cat ${WORKDIR}/project-alpha/src/components/header.tsx"
echo "  exit"
echo ""
echo "TABキーを押しても何も起こらないことを確認してください。"
echo "すべてのパスを手入力する必要があります。"
echo ""

# =============================================================================
echo "=========================================="
echo " 演習2: tcshの補完を体験する"
echo "=========================================="
echo ""

echo "tcshではTABキーでファイル名/コマンド名が補完されます。"
echo "以下の操作を tcsh 内で試してください:"
echo ""
echo "  tcsh"
echo "  ls ${WORKDIR}/pro<TAB>"
echo "  # → 候補が表示される（project-alpha/ project-beta/）"
echo ""
echo "  ls ${WORKDIR}/project-a<TAB>"
echo "  # → project-alpha/ と補完される"
echo ""
echo "  ls ${WORKDIR}/project-alpha/sr<TAB>/co<TAB>/"
echo "  # → src/components/ と補完される"
echo ""
echo "  whi<TAB>"
echo "  # → which と補完される（コマンド名補完）"
echo ""
echo "  exit"
echo ""

# =============================================================================
echo "=========================================="
echo " 演習3: Readlineの設定と編集モード"
echo "=========================================="
echo ""

# inputrcサンプルの作成
cat > "${WORKDIR}/inputrc-emacs" << 'EOF'
# Emacs モード（デフォルト）の設定例
set editing-mode emacs

# 曖昧な場合に全候補を即座に表示
set show-all-if-ambiguous on

# 補完で大文字小文字を区別しない
set completion-ignore-case on

# ファイルタイプに応じて色を付ける
set colored-stats on

# 補完候補にファイルタイプを示すマークを付ける
set visible-stats on

# Ctrl-P/Ctrl-N で入力中の文字列に基づくヒストリ検索
"\C-p": history-search-backward
"\C-n": history-search-forward
EOF

cat > "${WORKDIR}/inputrc-vi" << 'EOF'
# Vi モードの設定例
set editing-mode vi

# 現在のモードをプロンプトに表示
set show-mode-in-prompt on

# 挿入モードのカーソル表示
set vi-ins-mode-string \1\e[5 q\2
# コマンドモードのカーソル表示
set vi-cmd-mode-string \1\e[2 q\2

# 曖昧な場合に全候補を即座に表示
set show-all-if-ambiguous on

# 補完で大文字小文字を区別しない
set completion-ignore-case on
EOF

echo "inputrcサンプルファイルを作成しました:"
echo "  ${WORKDIR}/inputrc-emacs  (Emacsモード)"
echo "  ${WORKDIR}/inputrc-vi     (Viモード)"
echo ""

echo "--- Readlineの編集モードを試す ---"
echo ""
echo "Emacsモードの主要キーバインド:"
echo "  Ctrl-A : 行頭に移動"
echo "  Ctrl-E : 行末に移動"
echo "  Ctrl-F : 1文字右に移動"
echo "  Ctrl-B : 1文字左に移動"
echo "  Ctrl-D : カーソル位置の文字を削除"
echo "  Ctrl-K : カーソルから行末まで削除"
echo "  Ctrl-Y : 削除したテキストを貼り付け"
echo "  Ctrl-R : ヒストリの逆方向検索"
echo ""
echo "Viモードに切り替えるには:"
echo "  set -o vi"
echo ""
echo "inputrcを適用して試すには:"
echo "  INPUTRC=${WORKDIR}/inputrc-emacs bash"
echo "  INPUTRC=${WORKDIR}/inputrc-vi bash"
echo ""

# =============================================================================
echo "=========================================="
echo " 演習4: bash補完関数の作成"
echo "=========================================="
echo ""

cat > "${WORKDIR}/custom-completion.bash" << 'BASHEOF'
#!/bin/bash
# カスタム補完関数のデモ

# greetコマンドの定義
greet() {
  if [ -z "$1" ]; then
    echo "使い方: greet <名前>"
    return 1
  fi
  echo "Hello, $1!"
}

# greetコマンド用の補完関数
_greet_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local names="Alice Bob Charlie Diana Eve Frank"
  COMPREPLY=( $(compgen -W "$names" -- "$cur") )
}

# 補完関数の登録
complete -F _greet_completion greet

# deployコマンドの定義
deploy() {
  echo "Deploying to $1 environment (${2:-latest} version)..."
}

# deployコマンド用の補完関数（引数の位置に応じた補完）
_deploy_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local prev="${COMP_WORDS[COMP_CWORD-1]}"

  case $COMP_CWORD in
    1)
      # 第1引数: 環境名
      COMPREPLY=( $(compgen -W "development staging production" -- "$cur") )
      ;;
    2)
      # 第2引数: バージョン
      COMPREPLY=( $(compgen -W "latest v1.0.0 v1.1.0 v2.0.0" -- "$cur") )
      ;;
  esac
}

complete -F _deploy_completion deploy

echo "カスタム補完関数をロードしました。"
echo ""
echo "以下のコマンドで補完を試してください:"
echo "  greet <TAB><TAB>    → 名前の候補一覧"
echo "  greet A<TAB>        → Alice と補完"
echo "  deploy <TAB><TAB>   → 環境名の候補一覧"
echo "  deploy staging <TAB><TAB> → バージョンの候補一覧"
BASHEOF
chmod +x "${WORKDIR}/custom-completion.bash"

echo "カスタム補完関数スクリプトを作成しました:"
echo "  ${WORKDIR}/custom-completion.bash"
echo ""
echo "以下のコマンドで補完関数をロードして試してください:"
echo "  source ${WORKDIR}/custom-completion.bash"
echo "  greet <TAB><TAB>"
echo "  deploy <TAB><TAB>"
echo ""

# =============================================================================
echo "=========================================="
echo " 演習5: 補完の生産性比較"
echo "=========================================="
echo ""

cat > "${WORKDIR}/measure-keystrokes.sh" << 'BASHEOF'
#!/bin/bash
# 補完の効果を可視化するスクリプト

TARGET="${HOME}/shell-history-handson-08/project-alpha/src/components/header.tsx"
TARGET_LEN=${#TARGET}

echo "=== 補完の生産性比較 ==="
echo ""
echo "目標: 以下のファイルを cat で表示する"
echo "  ${TARGET}"
echo ""
echo "--- 補完なし（dash）---"
echo "入力文字数: cat + スペース + ${TARGET_LEN}文字 = $((TARGET_LEN + 4))文字"
echo "すべてのパスを正確に手入力する必要がある。"
echo ""

# bashでの補完をシミュレーション
echo "--- 基本補完（bash）---"
echo "おおよその入力:"
echo "  cat ~/sh<TAB>-08/pr<TAB>-a<TAB>/sr<TAB>/co<TAB>/he<TAB>"
echo "  → cat + TABキー6回 + 入力文字約20文字"
echo "入力削減率: 約 70%"
echo ""

echo "--- 高度な補完（zsh）---"
echo "おおよその入力:"
echo "  cat ~/s<TAB>08/p<TAB>a<TAB>/s<TAB>/c<TAB>/h<TAB>"
echo "  → cat + TABキー6回 + 入力文字約15文字"
echo "  ※ zshは部分マッチやメニュー選択でさらに効率化可能"
echo "入力削減率: 約 80%"
echo ""

echo "=== まとめ ==="
echo "補完なし: ${TARGET_LEN}文字の手入力（タイプミスのリスクあり）"
echo "基本補完: 約20文字 + TAB 6回（タイプミスをシステムが防ぐ）"
echo "高度補完: 約15文字 + TAB 6回（曖昧マッチも可能）"
BASHEOF
chmod +x "${WORKDIR}/measure-keystrokes.sh"

bash "${WORKDIR}/measure-keystrokes.sh"
echo ""

# =============================================================================
echo "=========================================="
echo " 全演習完了"
echo "=========================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "各シェルを対話的に試す場合:"
echo "  dash                  # 補完なしの世界"
echo "  tcsh                  # tcshの補完"
echo "  bash                  # bashの補完とReadline"
echo "  zsh                   # zshの高度な補完"
echo ""
echo "Readlineの設定を試す場合:"
echo "  INPUTRC=${WORKDIR}/inputrc-emacs bash"
echo "  INPUTRC=${WORKDIR}/inputrc-vi bash"
echo ""
echo "カスタム補完関数を試す場合:"
echo "  source ${WORKDIR}/custom-completion.bash"
