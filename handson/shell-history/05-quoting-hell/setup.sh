#!/bin/bash
# =============================================================================
# 第5回ハンズオン：クォーティング地獄を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 前提: Docker環境（ubuntu:24.04）またはbashが使えるLinux環境
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-05"

echo "=== 第5回ハンズオン：クォーティング地獄を体験する ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# ShellCheckのインストール確認
if command -v shellcheck > /dev/null 2>&1; then
  echo "ShellCheck: インストール済み ($(shellcheck --version | head -2 | tail -1))"
else
  echo "ShellCheck をインストールします..."
  if command -v apt-get > /dev/null 2>&1; then
    apt-get update -qq && apt-get install -y -qq shellcheck
  else
    echo "警告: ShellCheckを自動インストールできません。"
    echo "演習5はスキップされます。"
  fi
fi
echo ""

# --- 演習1: ワード分割の基本メカニズム ---
echo "================================================================"
echo "[演習1] ワード分割の基本メカニズム"
echo "================================================================"
echo ""
echo "未クォートの変数展開がワード分割を引き起こす様子を確認する。"
echo ""

# スペースを含むファイル名を作成
mkdir -p "${WORKDIR}/logs"
echo "ERROR: disk full" > "${WORKDIR}/logs/error report.log"
echo "INFO: started" > "${WORKDIR}/logs/access_log.txt"
echo "ERROR: timeout" > "${WORKDIR}/logs/system status.log"

echo "--- 作成したファイル ---"
ls -la "${WORKDIR}/logs/"
echo ""

# 罠: 未クォートの変数展開
echo "--- 未クォートの変数展開 ---"
TARGET="${WORKDIR}/logs/error report.log"
echo "変数の値: ${TARGET}"
echo ""

echo "cat \$TARGET (クォートなし):"
cat $TARGET 2>&1 || true
echo ""

echo "cat \"\$TARGET\" (クォートあり):"
cat "$TARGET"
echo ""

echo "ダブルクォートがないと、スペースの位置でワード分割が発生し、"
echo "2つの別々の引数になる。これは「バグ」ではなく「設計」だ。"
echo ""

# --- 演習2: グロビングとワード分割の複合 ---
echo "================================================================"
echo "[演習2] グロビングとワード分割の複合"
echo "================================================================"
echo ""
echo "ワード分割に加えて、グロビング（パス名展開）も作用する。"
echo ""

cd "${WORKDIR}/logs"

echo "--- グロビングの罠 ---"
pattern="*.log"

echo "未クォート: echo \$pattern"
echo $pattern
echo ""

echo "クォートあり: echo \"\$pattern\""
echo "$pattern"
echo ""

echo "--- 変数内のアスタリスク ---"
message="Warning: found * files in logs"

echo "未クォート: echo \$message"
echo $message
echo ""

echo "クォートあり: echo \"\$message\""
echo "$message"
echo ""

echo "未クォートの展開では、* がカレントディレクトリの"
echo "ファイル名に展開されてしまう。"
echo ""

cd "${WORKDIR}"

# --- 演習3: "$@" vs "$*" ---
echo "================================================================"
echo "[演習3] \"\$@\" vs \"\$*\" の決定的な差"
echo "================================================================"
echo ""
echo "Bourne shellには配列変数がなかった。"
echo "\"\$@\" が唯一の安全なリスト処理手段だった。"
echo ""

# サブシェルで位置パラメータを操作
(
  set -- "error report.log" "access log.txt" "debug.log"
  echo "位置パラメータ: 3つの引数（うち2つはスペースを含む）"
  echo ""

  echo '--- for arg in "$@" ---'
  for arg in "$@"; do
    echo "  arg: '${arg}'"
  done
  echo "→ 3つの引数がそれぞれ保持される"
  echo ""

  echo '--- for arg in "$*" ---'
  for arg in "$*"; do
    echo "  arg: '${arg}'"
  done
  echo "→ すべてが1つの文字列に結合される"
  echo ""

  echo '--- for arg in $@ (クォートなし) ---'
  for arg in $@; do
    echo "  arg: '${arg}'"
  done
  echo "→ ワード分割によって5つの引数に分裂する"
  echo ""

  echo '"$@" だけが、スペースを含む引数を正しく保持する。'
)
echo ""

# --- 演習4: IFSの操作 ---
echo "================================================================"
echo "[演習4] IFSの操作"
echo "================================================================"
echo ""
echo "IFS（Internal Field Separator）がワード分割を制御する。"
echo ""

echo "--- デフォルトIFSでのワード分割 ---"
data="apple:banana:cherry"
for item in $data; do
  echo "  item: '${item}'"
done
echo "→ デフォルトIFS（スペース/タブ/改行）ではコロンで分割されない"
echo ""

echo "--- IFSをコロンに変更 ---"
OLD_IFS="${IFS}"
IFS=":"
for item in $data; do
  echo "  item: '${item}'"
done
IFS="${OLD_IFS}"
echo "→ IFS=':' にすると、コロンでワード分割される"
echo ""

echo "--- PATH変数の分割 ---"
PATH_DEMO="/usr/bin:/usr/local/bin:/home/user/bin"
OLD_IFS="${IFS}"
IFS=":"
echo "PATH の各コンポーネント:"
for dir in $PATH_DEMO; do
  echo "  ${dir}"
done
IFS="${OLD_IFS}"
echo ""
echo "IFSの変更はグローバルに作用する。"
echo "変更前の値を保存し、使用後に復元すること。"
echo ""

# --- 演習5: ShellCheckによる静的解析 ---
echo "================================================================"
echo "[演習5] ShellCheckによる静的解析"
echo "================================================================"
echo ""

if ! command -v shellcheck > /dev/null 2>&1; then
  echo "ShellCheck が見つかりません。この演習はスキップします。"
  echo ""
else
  echo "ShellCheck でクォーティング問題を自動検出する。"
  echo ""

  # 意図的に問題のあるスクリプトを作成
  cat > "${WORKDIR}/buggy.sh" << 'SCRIPT'
#!/bin/sh
# 意図的にクォーティングの問題を含むスクリプト

# SC2086: 未クォートの変数展開
filename="error report.log"
cat $filename

# SC2046: 未クォートのコマンド置換
current_dir=$(pwd)
cd $current_dir

# SC2048: "$@" の代わりに $@ を使用
for arg in $@; do
  echo "$arg"
done

# SC2086: 条件式での未クォート変数
name="hello world"
if [ $name = "hello world" ]; then
  echo "match"
fi
SCRIPT

  echo "--- 問題のあるスクリプト ---"
  cat "${WORKDIR}/buggy.sh"
  echo ""

  echo "--- ShellCheck の結果 ---"
  shellcheck "${WORKDIR}/buggy.sh" 2>&1 || true
  echo ""

  # 修正版を作成
  cat > "${WORKDIR}/fixed.sh" << 'SCRIPT'
#!/bin/sh
# クォーティングを修正したスクリプト

# 修正: ダブルクォートで変数を囲む
filename="error report.log"
cat "$filename"

# 修正: コマンド置換もダブルクォートで囲む
current_dir=$(pwd)
cd "$current_dir"

# 修正: "$@" を使う
for arg in "$@"; do
  echo "$arg"
done

# 修正: 条件式でもダブルクォートを使う
name="hello world"
if [ "$name" = "hello world" ]; then
  echo "match"
fi
SCRIPT

  echo "--- 修正後のスクリプト ---"
  cat "${WORKDIR}/fixed.sh"
  echo ""

  echo "--- ShellCheck の結果（修正後） ---"
  shellcheck "${WORKDIR}/fixed.sh" 2>&1 || true
  echo ""
fi

# --- 演習6: 安全なパターン集 ---
echo "================================================================"
echo "[演習6] 安全なパターン集"
echo "================================================================"
echo ""
echo "クォーティング地獄を回避する実践的なテクニック。"
echo ""

echo "--- パターン1: 変数展開は常にダブルクォート ---"
file="${WORKDIR}/logs/error report.log"
echo "安全: cat \"\$file\""
cat "$file"
echo ""

echo "--- パターン2: コマンド置換もダブルクォート ---"
dir="$(pwd)"
echo "安全: dir=\"\$(pwd)\" → ${dir}"
echo ""

echo "--- パターン3: findの結果を安全に処理 ---"
echo "危険: for f in \$(find ...)"
echo "安全: find ... -exec / find ... -print0 | xargs -0"
echo ""
echo "find -exec の例:"
find "${WORKDIR}/logs" -name "*.log" -exec echo "  found: {}" \;
echo ""

echo "--- パターン4: 引数の受け渡しは \"\$@\" ---"
echo "危険: func \$@"
echo "安全: func \"\$@\""
echo ""

echo "--- パターン5: 条件式でもダブルクォート ---"
value=""
if [ "$value" = "" ]; then
  echo "  空文字列を安全に判定: [ \"\$value\" = \"\" ]"
fi
echo ""

echo "=== 原則: 迷ったらダブルクォート ==="
echo ""

# --- 完了 ---
echo "================================================================"
echo " 演習完了"
echo "================================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "クォーティング地獄は「バグ」ではなく「設計」だ。"
echo "この設計を理解せずにシェルスクリプトを書くことは、"
echo "地雷原を地図なしで歩くに等しい。"
echo "ダブルクォートがその地図である。"

# 掃除
rm -rf "${WORKDIR}"
