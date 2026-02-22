#!/bin/bash
# =============================================================================
# 第19回ハンズオン：シェル初期化ファイルの実験とdotfiles管理
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 前提: Docker環境（ubuntu:24.04）またはapt-getが使えるLinux環境
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-19"

echo "=== 第19回ハンズオン：シェル初期化ファイルの実験とdotfiles管理 ==="
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
  apt-get install -y -qq zsh stow curl git >/dev/null 2>&1
  echo "  zsh, stow, curl, git をインストールしました"
else
  echo "  apt-getが利用できません。手動でzsh, stow, curl, gitをインストールしてください。"
fi

echo ""

# =============================================================================
# 演習1: bashの初期化ファイル読み込み順序を実験する
# =============================================================================
echo "=============================================="
echo " 演習1: bash初期化ファイルの読み込み順序"
echo "=============================================="
echo ""

BASH_TEST_HOME="${WORKDIR}/bash-init-test"
mkdir -p "${BASH_TEST_HOME}"

cat > "${BASH_TEST_HOME}/.bash_profile" << 'EOF'
echo "[LOADED] .bash_profile"
EOF

cat > "${BASH_TEST_HOME}/.bashrc" << 'EOF'
echo "[LOADED] .bashrc"
EOF

cat > "${BASH_TEST_HOME}/.profile" << 'EOF'
echo "[LOADED] .profile"
EOF

echo "--- ケース1: 対話的ログインシェル ---"
echo "  (bash --login を実行)"
HOME="${BASH_TEST_HOME}" bash --login -c "echo '  done'"
echo ""

echo "--- ケース2: 対話的非ログインシェル ---"
echo "  (bash を実行)"
HOME="${BASH_TEST_HOME}" bash -c "echo '  done'"
echo ""

echo "--- ケース3: .bash_profileがない場合 ---"
rm "${BASH_TEST_HOME}/.bash_profile"
HOME="${BASH_TEST_HOME}" bash --login -c "echo '  done'"
echo "  => .bash_profileがなければ.profileにフォールバック"
echo ""

echo "--- ケース4: .bash_profileから.bashrcをsource ---"
cat > "${BASH_TEST_HOME}/.bash_profile" << 'EOF'
echo "[LOADED] .bash_profile"
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
EOF
echo "  (.bash_profileに.bashrcのsourceを追加)"
HOME="${BASH_TEST_HOME}" bash --login -c "echo '  done'"
echo "  => これがbashの初期化ファイルの定番パターン"
echo ""

# =============================================================================
# 演習2: zshの5段階初期化ファイルを実験する
# =============================================================================
echo "=============================================="
echo " 演習2: zshの5段階初期化ファイル"
echo "=============================================="
echo ""

ZSH_TEST_DIR="${WORKDIR}/zsh-init-test"
mkdir -p "${ZSH_TEST_DIR}"

cat > "${ZSH_TEST_DIR}/.zshenv" << 'EOF'
echo "[1] .zshenv (すべてのzshで読み込み)"
EOF

cat > "${ZSH_TEST_DIR}/.zprofile" << 'EOF'
echo "[2] .zprofile (ログインシェルで読み込み)"
EOF

cat > "${ZSH_TEST_DIR}/.zshrc" << 'EOF'
echo "[3] .zshrc (対話的シェルで読み込み)"
EOF

cat > "${ZSH_TEST_DIR}/.zlogin" << 'EOF'
echo "[4] .zlogin (ログインシェルで、.zshrcの後に読み込み)"
EOF

echo "--- ケース1: 対話的ログインシェル ---"
ZDOTDIR="${ZSH_TEST_DIR}" zsh --login -c "echo '  ---'"
echo ""

echo "--- ケース2: 対話的非ログインシェル ---"
ZDOTDIR="${ZSH_TEST_DIR}" zsh -c "echo '  ---'"
echo ""

echo "--- ケース3: 非対話的（スクリプト実行）---"
echo 'echo "  script running"' > "${WORKDIR}/zsh-test-script.zsh"
ZDOTDIR="${ZSH_TEST_DIR}" zsh "${WORKDIR}/zsh-test-script.zsh"
echo "  => .zshenvはスクリプト実行でも読み込まれる（注意）"
echo ""

# =============================================================================
# 演習3: login shellとnon-login shellの違い
# =============================================================================
echo "=============================================="
echo " 演習3: login shell判定の確認"
echo "=============================================="
echo ""

echo "--- bashでの確認方法 ---"
echo "  ログインシェルの場合:"
bash --login -c 'shopt -q login_shell && echo "    login shell: yes" || echo "    login shell: no"'
echo "  非ログインシェルの場合:"
bash -c 'shopt -q login_shell && echo "    login shell: yes" || echo "    login shell: no"'
echo ""

echo "--- zshでの確認方法 ---"
echo "  ログインシェルの場合:"
ZDOTDIR=/tmp zsh --login -c '[[ -o login ]] && echo "    login shell: yes" || echo "    login shell: no"'
echo "  非ログインシェルの場合:"
ZDOTDIR=/tmp zsh -c '[[ -o login ]] && echo "    login shell: yes" || echo "    login shell: no"'
echo ""

echo "  => ターミナルエミュレータによってデフォルトが異なる"
echo "     macOS Terminal.app -> ログインシェル"
echo "     多くのLinuxターミナル -> 非ログインシェル"
echo "     tmux/screen -> 非ログインシェル（設定次第）"
echo ""

# =============================================================================
# 演習4: GNU Stowによるdotfiles管理
# =============================================================================
echo "=============================================="
echo " 演習4: GNU Stowによるdotfiles管理"
echo "=============================================="
echo ""

STOW_HOME="${WORKDIR}/stow-test-home"
DOTFILES="${STOW_HOME}/dotfiles"

mkdir -p "${STOW_HOME}"
mkdir -p "${DOTFILES}/bash"
mkdir -p "${DOTFILES}/git"
mkdir -p "${DOTFILES}/vim"

cat > "${DOTFILES}/bash/.bashrc" << 'EOF'
# My .bashrc managed by GNU Stow
alias ll='ls -la'
alias gs='git status'
export EDITOR=vim
EOF

cat > "${DOTFILES}/git/.gitconfig" << 'EOF'
[user]
    name = Test User
    email = test@example.com
[core]
    editor = vim
EOF

cat > "${DOTFILES}/vim/.vimrc" << 'EOF'
set number
set expandtab
set shiftwidth=4
EOF

echo "--- dotfilesリポジトリの構造 ---"
find "${DOTFILES}" -type f | sort | sed "s|${STOW_HOME}/||"
echo ""

echo "--- stowでシンボリックリンクを作成 ---"
cd "${DOTFILES}"
HOME="${STOW_HOME}" stow -t "${STOW_HOME}" bash git vim
echo "  stow -t ~ bash git vim を実行"
echo ""

echo "--- リンクの確認 ---"
for f in .bashrc .gitconfig .vimrc; do
  if [ -L "${STOW_HOME}/${f}" ]; then
    target=$(readlink "${STOW_HOME}/${f}")
    echo "  ${f} -> ${target}"
  fi
done
echo ""

echo "--- unstow（リンク解除）---"
HOME="${STOW_HOME}" stow -t "${STOW_HOME}" -D bash
if [ ! -e "${STOW_HOME}/.bashrc" ]; then
  echo "  .bashrc のリンクが解除された"
fi
echo ""

echo "  => GNU Stowはシンボリックリンクの作成/解除を自動化する"
echo "     ディレクトリ構造 = リンク先の構造"
echo ""

# =============================================================================
# 演習5: Starshipプロンプトの体験
# =============================================================================
echo "=============================================="
echo " 演習5: Starshipプロンプトの体験"
echo "=============================================="
echo ""

if ! command -v starship > /dev/null 2>&1; then
  echo "[準備] Starshipをインストール中..."
  curl -sS https://starship.rs/install.sh | sh -s -- --yes 2>/dev/null
  echo ""
fi

echo "--- Starshipのバージョン ---"
starship --version 2>/dev/null || echo "  (Starshipのインストールに失敗しました)"
echo ""

STARSHIP_TEST="${WORKDIR}/starship-test"
mkdir -p "${STARSHIP_TEST}"

echo "--- 設定1: ミニマル ---"
cat > "${STARSHIP_TEST}/starship.toml" << 'TOML'
format = "$directory$character"

[character]
success_symbol = "[>](bold green)"
error_symbol = "[>](bold red)"

[directory]
style = "bold cyan"
truncation_length = 2
TOML

echo "  設定内容:"
cat "${STARSHIP_TEST}/starship.toml" | sed 's/^/    /'
echo ""

if command -v starship > /dev/null 2>&1; then
  echo "  プロンプト表示:"
  STARSHIP_CONFIG="${STARSHIP_TEST}/starship.toml" starship prompt 2>/dev/null | sed 's/^/    /'
  echo ""
fi

echo "--- 設定2: 情報量多め ---"
cat > "${STARSHIP_TEST}/starship.toml" << 'TOML'
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$line_break\
$character"""

[character]
success_symbol = "[->](bold green)"
error_symbol = "[->](bold red)"

[directory]
style = "bold cyan"

[git_branch]
symbol = "git:"
TOML

echo "  設定内容:"
cat "${STARSHIP_TEST}/starship.toml" | sed 's/^/    /'
echo ""

if command -v starship > /dev/null 2>&1; then
  echo "  プロンプト表示:"
  STARSHIP_CONFIG="${STARSHIP_TEST}/starship.toml" starship prompt 2>/dev/null | sed 's/^/    /'
  echo ""
fi

echo "  => Starshipの特徴:"
echo "     1. クロスシェル: bash/zsh/fish/PowerShell等に対応"
echo "     2. Rust製: 高速な起動"
echo "     3. TOML設定: シェルに依存しない統一的な設定"
echo "     4. XDG準拠: ~/.config/starship.toml"
echo ""

# =============================================================================
# 完了
# =============================================================================
echo "=============================================="
echo " 全演習完了"
echo "=============================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "クリーンアップ: rm -rf ${WORKDIR}"
