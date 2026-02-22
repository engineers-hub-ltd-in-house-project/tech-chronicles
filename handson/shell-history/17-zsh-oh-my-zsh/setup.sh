#!/bin/bash
# =============================================================================
# 第17回ハンズオン：Oh My Zshなしでzshを理解する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 前提: Docker環境（ubuntu:24.04）またはapt-getが使えるLinux環境
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-17"

echo "=== 第17回ハンズオン：Oh My Zshなしでzshを理解する ==="
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
  apt-get update -qq && apt-get install -y -qq zsh git curl time >/dev/null 2>&1
  echo "  zsh, git, curl をインストールしました"
else
  echo "  apt-get が見つかりません。手動でzsh, git, curlをインストールしてください"
fi

echo ""

# --- 演習1: 素のzshとOh My Zshの起動速度比較 ---
echo "================================================================"
echo "[演習1] 素のzshとOh My Zshの起動速度比較"
echo "================================================================"
echo ""

echo "--- 素のzsh（設定ファイルなし）---"
for i in 1 2 3 4 5; do
  start_time=$(date +%s%N)
  zsh -f -c "exit"
  end_time=$(date +%s%N)
  elapsed=$(( (end_time - start_time) / 1000000 ))
  echo "  実行${i}: ${elapsed}ms"
done

echo ""
echo "--- Oh My Zshをインストール ---"
export RUNZSH=no
export CHSH=no
HOME_BACKUP="${HOME}"
export HOME="${WORKDIR}/omz-home"
mkdir -p "${HOME}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null || true

echo ""
echo "--- Oh My Zsh付きzsh ---"
for i in 1 2 3 4 5; do
  start_time=$(date +%s%N)
  ZDOTDIR="${HOME}" zsh -c "exit" 2>/dev/null
  end_time=$(date +%s%N)
  elapsed=$(( (end_time - start_time) / 1000000 ))
  echo "  実行${i}: ${elapsed}ms"
done
export HOME="${HOME_BACKUP}"

echo ""
echo "=> 素のzshは数十ms、Oh My Zshは数百ms。差は明確。"
echo ""

# --- 演習2: zstyleによる補完設定 ---
echo "================================================================"
echo "[演習2] zstyleによる補完設定"
echo "================================================================"
echo ""

cat << 'ZSHRC' > "${WORKDIR}/minimal.zshrc"
# 補完システムの初期化
autoload -Uz compinit
compinit -d /tmp/zcompdump

# 大文字小文字を区別しない補完
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# メニュー選択式の補完
zstyle ':completion:*' menu select

# グループ表示
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '-- %d --'
zstyle ':completion:*:warnings' format '-- マッチなし --'
ZSHRC

echo "最小限の補完設定を作成しました: ${WORKDIR}/minimal.zshrc"
echo ""
echo "内容:"
cat "${WORKDIR}/minimal.zshrc"
echo ""
echo "=> zstyleの ':completion:*' はコンテキストパターン"
echo "   コマンドごとに異なる補完挙動を設定可能"
echo ""

# --- 演習3: グロブ修飾子の体験 ---
echo "================================================================"
echo "[演習3] グロブ修飾子（glob qualifiers）"
echo "================================================================"
echo ""

# テスト用ディレクトリ構造を作成
mkdir -p "${WORKDIR}/glob-lab/src/lib" "${WORKDIR}/glob-lab/docs" "${WORKDIR}/glob-lab/logs"
echo '#!/usr/bin/env python3' > "${WORKDIR}/glob-lab/src/main.py"
echo 'print("hello")' >> "${WORKDIR}/glob-lab/src/main.py"
chmod +x "${WORKDIR}/glob-lab/src/main.py"
echo "# utils" > "${WORKDIR}/glob-lab/src/utils.py"
echo "# test" > "${WORKDIR}/glob-lab/src/test_main.py"
echo "# helper" > "${WORKDIR}/glob-lab/src/lib/helper.py"
echo "# readme" > "${WORKDIR}/glob-lab/docs/readme.md"
echo "# api" > "${WORKDIR}/glob-lab/docs/api.md"
echo "error log" > "${WORKDIR}/glob-lab/logs/error.log"
echo "app log" > "${WORKDIR}/glob-lab/logs/app.log"
ln -s "${WORKDIR}/glob-lab/src/main.py" "${WORKDIR}/glob-lab/run"

echo "テスト用ファイル構造:"
find "${WORKDIR}/glob-lab" -not -path '*/\.*' | sort | sed "s|${WORKDIR}/glob-lab/||" | tail -n +2
echo ""

zsh << ZSH_GLOB
setopt EXTENDED_GLOB

echo "--- (.) 通常ファイルのみ ---"
print -l ${WORKDIR}/glob-lab/**/*(.) | sed "s|${WORKDIR}/glob-lab/||"

echo ""
echo "--- (/) ディレクトリのみ ---"
print -l ${WORKDIR}/glob-lab/**/*(/) | sed "s|${WORKDIR}/glob-lab/||"

echo ""
echo "--- (@) シンボリックリンクのみ ---"
print -l ${WORKDIR}/glob-lab/**/*(@) | sed "s|${WORKDIR}/glob-lab/||"

echo ""
echo "--- (*) 実行可能ファイルのみ ---"
print -l ${WORKDIR}/glob-lab/**/*(*) | sed "s|${WORKDIR}/glob-lab/||"

echo ""
echo "--- *.py を名前の逆順で ---"
print -l ${WORKDIR}/glob-lab/**/*.py(On) | sed "s|${WORKDIR}/glob-lab/||"

echo ""
echo "--- 先頭2件だけ（更新日時順）---"
print -l ${WORKDIR}/glob-lab/**/*(om[1,2]) | sed "s|${WORKDIR}/glob-lab/||"
ZSH_GLOB

echo ""
echo "=> findコマンドなしで、グロブ修飾子だけでフィルタリング"
echo "   (.)=通常ファイル, (/)=ディレクトリ, (@)=シンボリックリンク"
echo "   (*)=実行可能, (om)=更新日時順, ([1,2])=先頭2件"
echo ""

# --- 演習4: zleカスタムウィジェット ---
echo "================================================================"
echo "[演習4] zleカスタムウィジェット"
echo "================================================================"
echo ""

cat << 'ZLE_RC' > "${WORKDIR}/zle-demo.zshrc"
# --- zleカスタムウィジェット ---

# ウィジェット1: コマンドラインの先頭にsudoを追加/除去
function toggle-sudo {
    if [[ "$BUFFER" == sudo\ * ]]; then
        BUFFER="${BUFFER#sudo }"
        CURSOR=$(( CURSOR - 5 ))
    else
        BUFFER="sudo $BUFFER"
        CURSOR=$(( CURSOR + 5 ))
    fi
}
zle -N toggle-sudo
bindkey '^[s' toggle-sudo   # Alt-s

# ウィジェット2: 現在のディレクトリのファイル一覧を表示
function list-files {
    echo ""
    ls -la --color=auto
    zle reset-prompt
}
zle -N list-files
bindkey '^[l' list-files     # Alt-l

# ウィジェット3: 直前のコマンドの終了コードを表示
function show-exit-code {
    zle -M "直前の終了コード: $?"
}
zle -N show-exit-code
bindkey '^[e' show-exit-code  # Alt-e
ZLE_RC

echo "zleウィジェット設定を作成しました: ${WORKDIR}/zle-demo.zshrc"
echo ""
echo "内容:"
cat "${WORKDIR}/zle-demo.zshrc"
echo ""
echo "使い方:"
echo "  zsh を起動し、source ${WORKDIR}/zle-demo.zshrc を実行"
echo "  Alt-s: sudoのトグル"
echo "  Alt-l: ファイル一覧"
echo "  Alt-e: 終了コード表示"
echo ""
echo "=> zleウィジェットはシェル関数として実装される"
echo "   \$BUFFERでコマンドライン全体、\$CURSORでカーソル位置にアクセス"
echo ""

# --- 演習5: Oh My Zshなしの完全な.zshrc ---
echo "================================================================"
echo "[演習5] Oh My Zshなしの完全な.zshrc"
echo "================================================================"
echo ""

cat << 'FULL_ZSHRC' > "${WORKDIR}/full.zshrc"
# =================================================
# Oh My Zshなしの完全なzsh設定
# 起動時間: 100-200ms
# =================================================

# --- ヒストリ設定 ---
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# --- 基本オプション ---
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt CORRECT
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP

# --- 補完設定 ---
autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- マッチなし --%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# --- キーバインド ---
bindkey -e
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '^[[Z' reverse-menu-complete

# --- プロンプト（Gitブランチ表示付き）---
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%F{cyan}(%b)%f '
setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f ${vcs_info_msg_0_}%# '

# --- エイリアス ---
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
FULL_ZSHRC

echo "完全なzsh設定を作成しました: ${WORKDIR}/full.zshrc"
echo ""
echo "この設定を使ってzshを起動:"
echo "  ZDOTDIR=${WORKDIR} zsh"
echo ""

# 起動速度の計測
echo "--- この設定での起動速度 ---"
for i in 1 2 3; do
  start_time=$(date +%s%N)
  ZDOTDIR="${WORKDIR}" zsh -c "exit" 2>/dev/null
  end_time=$(date +%s%N)
  elapsed=$(( (end_time - start_time) / 1000000 ))
  echo "  実行${i}: ${elapsed}ms"
done
# .zshrcとしてコピー（ZDOTDIRから読み込まれるように）
cp "${WORKDIR}/full.zshrc" "${WORKDIR}/.zshrc"

echo ""

# --- まとめ ---
echo "================================================================"
echo "=== ハンズオン完了 ==="
echo "================================================================"
echo ""
echo "ポイント:"
echo "  1. 素のzshはOh My Zshの数分の1の起動時間で動作する"
echo "  2. zstyleでコマンドごとに補完挙動を細かく制御できる"
echo "  3. グロブ修飾子でfindコマンドなしのファイルフィルタリングが可能"
echo "  4. zleウィジェットでコマンドライン操作を自由にカスタマイズできる"
echo "  5. Oh My Zshなしでも必要十分な設定は数十行で書ける"
echo ""
echo "次のステップ:"
echo "  zsh を対話モードで起動し、グロブ修飾子や補完を体験してみよう"
echo "  ZDOTDIR=${WORKDIR} zsh"
