#!/bin/bash
# =============================================================================
# 第1回ハンズオン：4つのシェルを並べて比較する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 前提: Docker環境（ubuntu:24.04）またはapt-getが使えるLinux環境
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-01"

echo "=== 第1回ハンズオン：4つのシェルを並べて比較する ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# --- シェルのインストール ---
echo "[準備] 必要なシェルをインストール中..."

if command -v apt-get > /dev/null 2>&1; then
  apt-get update -qq && apt-get install -y -qq zsh fish dash > /dev/null 2>&1
  echo "  zsh, fish, dash をインストールしました"
else
  echo "  apt-get が見つかりません。手動でzsh, fish, dashをインストールしてください"
fi

echo ""

# --- 演習1: 変数代入の構文比較 ---
echo "================================================================"
echo "[演習1] 変数代入の構文比較"
echo "================================================================"
echo ""

echo "--- bash ---"
echo '$ bash -c '\''NAME="world"; echo "Hello, $NAME"'\'''
bash -c 'NAME="world"; echo "Hello, $NAME"'
echo ""

echo "--- zsh ---"
echo '$ zsh -c '\''NAME="world"; echo "Hello, $NAME"'\'''
zsh -c 'NAME="world"; echo "Hello, $NAME"'
echo ""

echo "--- fish ---"
echo '$ fish -c '\''set NAME "world"; echo "Hello, $NAME"'\'''
fish -c 'set NAME "world"; echo "Hello, $NAME"'
echo ""

echo "--- dash ---"
echo '$ dash -c '\''NAME="world"; echo "Hello, $NAME"'\'''
dash -c 'NAME="world"; echo "Hello, $NAME"'
echo ""

echo "=> bash, zsh, dashは同じ構文。fishだけsetコマンドを使う。"
echo ""

# --- 演習2: ループ構文の比較 ---
echo "================================================================"
echo "[演習2] ループ構文の比較（1から5を出力）"
echo "================================================================"
echo ""

echo "--- bash ---"
echo '$ bash -c '\''for i in 1 2 3 4 5; do echo "Number: $i"; done'\'''
bash -c 'for i in 1 2 3 4 5; do echo "Number: $i"; done'
echo ""

echo "--- zsh ---"
echo '$ zsh -c '\''for i in 1 2 3 4 5; do echo "Number: $i"; done'\'''
zsh -c 'for i in 1 2 3 4 5; do echo "Number: $i"; done'
echo ""

echo "--- fish ---"
echo '$ fish -c '\''for i in 1 2 3 4 5; echo "Number: $i"; end'\'''
fish -c 'for i in 1 2 3 4 5; echo "Number: $i"; end'
echo ""

echo "--- dash ---"
echo '$ dash -c '\''for i in 1 2 3 4 5; do echo "Number: $i"; done'\'''
dash -c 'for i in 1 2 3 4 5; do echo "Number: $i"; done'
echo ""

echo "=> Bourne系（bash, zsh, dash）はdo...done構文。fishはend構文。"
echo ""

# --- 演習3: パイプラインの比較 ---
echo "================================================================"
echo "[演習3] パイプラインの比較（/etc/passwdからシェル名を抽出）"
echo "================================================================"
echo ""

echo "--- bash ---"
echo '$ bash -c '\''cat /etc/passwd | awk -F: "{print \$7}" | sort | uniq'\'''
bash -c 'cat /etc/passwd | awk -F: "{print \$7}" | sort | uniq'
echo ""

echo "--- zsh ---"
echo '$ zsh -c '\''cat /etc/passwd | awk -F: "{print \$7}" | sort | uniq'\'''
zsh -c 'cat /etc/passwd | awk -F: "{print \$7}" | sort | uniq'
echo ""

echo "--- fish ---"
echo '$ fish -c '\''cat /etc/passwd | awk -F: "{print \$7}" | sort | uniq'\'''
fish -c 'cat /etc/passwd | awk -F: "{print \$7}" | sort | uniq'
echo ""

echo "--- dash ---"
echo '$ dash -c '\''cat /etc/passwd | awk -F: "{print \$7}" | sort | uniq'\'''
dash -c 'cat /etc/passwd | awk -F: "{print \$7}" | sort | uniq'
echo ""

echo "=> パイプ（|）は4つのシェルで共通。1973年以来の普遍的な構文。"
echo ""

# --- 演習4: シェル情報の表示 ---
echo "================================================================"
echo "[演習4] 各シェルのバージョンと特徴"
echo "================================================================"
echo ""

echo "--- bash ---"
bash --version | head -1
echo ""

echo "--- zsh ---"
zsh --version
echo ""

echo "--- fish ---"
fish --version
echo ""

echo "--- dash ---"
# dashにはバージョン表示オプションがない場合がある
dpkg -l dash 2>/dev/null | grep "^ii" | awk '{print "dash " $3}' || echo "dash (version unknown)"
echo ""

# --- まとめ ---
echo "================================================================"
echo "=== ハンズオン完了 ==="
echo "================================================================"
echo ""
echo "ポイント:"
echo "  1. bash, zsh, dashはBourne shell系統であり、基本構文が共通している"
echo "  2. fishは意図的にPOSIX互換を捨て、独自の一貫した構文を持つ"
echo "  3. パイプ（|）はThompson shell（1973年）以来、シェルの種類を超えた普遍的構文"
echo "  4. 対話的機能（TAB補完、構文ハイライト等）はシェルごとに大きく異なる"
echo ""
echo "次のステップ:"
echo "  各シェルを対話モードで起動し（例: fish と入力）、TAB補完やヒストリ検索を試してみよう"
