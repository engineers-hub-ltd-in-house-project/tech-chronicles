#!/bin/bash
# =============================================================================
# 第4回ハンズオン：Bourne shellの言語機能を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 前提: Docker環境（ubuntu:24.04）またはbashが使えるLinux環境
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-04"

echo "=== 第4回ハンズオン：Bourne shellの言語機能を体験する ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# --- 演習1: 変数と制御構造の基本 ---
echo "================================================================"
echo "[演習1] 変数と制御構造の基本"
echo "================================================================"
echo ""
echo "Bourne shellが導入した変数と制御構造を使う。"
echo "ALGOL 68由来の fi, esac, done に注目してほしい。"
echo ""

# 変数代入
LOG_DIR="/var/log"
THRESHOLD=3

echo "--- 変数代入 ---"
echo "LOG_DIR=\"${LOG_DIR}\""
echo "THRESHOLD=${THRESHOLD}"
echo ""

# for...in...do...done ループ
echo "--- for ループ (for...in...do...done) ---"
for file in /etc/hostname /etc/hosts /etc/nonexistent; do
  if [ -f "$file" ]; then
    LINE_COUNT=$(wc -l < "$file")
    echo "  ${file}: 存在する (${LINE_COUNT} 行)"
  else
    echo "  ${file}: 存在しない"
  fi
done
echo ""

# case...in...esac 分岐
echo "--- case 分岐 (case...in...esac) ---"
SHELL_NAME=$(basename "${SHELL:-/bin/sh}")
case "$SHELL_NAME" in
  bash)  echo "  Bourne-Again SHell を使用中" ;;
  zsh)   echo "  Z Shell を使用中" ;;
  dash)  echo "  Debian Almquist SHell を使用中" ;;
  sh)    echo "  Bourne Shell互換を使用中" ;;
  *)     echo "  シェル: ${SHELL_NAME}" ;;
esac
echo ""
echo "  fi は if の逆綴り、esac は case の逆綴り。"
echo "  done はALGOL 68の od の代替（od コマンドとの衝突回避）。"
echo ""

# while...do...done ループ
echo "--- while ループ (while...do...done) ---"
count=1
while [ "$count" -le 5 ]; do
  echo "  カウント: ${count}"
  count=$((count + 1))
done
echo ""

# --- 演習2: ワード分割の罠 ---
echo "================================================================"
echo "[演習2] ワード分割の罠"
echo "================================================================"
echo ""
echo "Bourne shellの処理パイプライン:"
echo "  変数展開 → ワード分割 → グロビング"
echo "未クォートの変数展開はワード分割の対象になる。"
echo ""

# スペースを含むファイル名を作成する
mkdir -p "${WORKDIR}/logs"
echo "ERROR: disk full" > "${WORKDIR}/logs/error report.log"
echo "INFO: started" > "${WORKDIR}/logs/access_log.txt"

echo "--- 作成したファイル ---"
ls -la "${WORKDIR}/logs/"
echo ""

# 罠1: クォートなしの変数展開
echo "--- 罠1: クォートなしの変数展開 ---"
TARGET="${WORKDIR}/logs/error report.log"

echo "変数の値: ${TARGET}"
echo ""

echo "クォートなし: cat \$TARGET"
echo "  (実行結果:)"
cat $TARGET 2>&1 || true
echo ""

echo "クォートあり: cat \"\$TARGET\""
echo "  (実行結果:)"
cat "$TARGET"
echo ""

echo "クォートがないと、スペースの位置でワード分割が発生し、"
echo "'error' と 'report.log' が別々の引数になる。"
echo ""

# 罠2: for ループでのワード分割
echo "--- 罠2: for ループでのワード分割 ---"
FILES="${WORKDIR}/logs/error report.log ${WORKDIR}/logs/access_log.txt"

echo "クォートなし: for f in \$FILES"
for f in $FILES; do
  echo "  引数: '$(basename "$f" 2>/dev/null || echo "$f")'"
done
echo ""

echo "正しいアプローチ: 個別にクォートで囲む"
for f in "${WORKDIR}/logs/error report.log" "${WORKDIR}/logs/access_log.txt"; do
  if [ -f "$f" ]; then
    echo "  $(basename "$f"): 存在する"
  fi
done
echo ""

# --- 演習3: ヒアドキュメントとコマンド置換 ---
echo "================================================================"
echo "[演習3] ヒアドキュメントとコマンド置換"
echo "================================================================"
echo ""
echo "Thompson shellにはなかった2つの機能を組み合わせる。"
echo ""

# コマンド置換で情報を収集する
CURRENT_HOST=$(hostname)
CURRENT_KERNEL=$(uname -r)
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
CURRENT_UPTIME=$(uptime -p 2>/dev/null || uptime)

# ヒアドキュメントでレポートを生成する
echo "--- ヒアドキュメント + コマンド置換 ---"
cat << REPORT
  ========================================
   システムレポート
  ========================================
  ホスト名:     ${CURRENT_HOST}
  カーネル:     ${CURRENT_KERNEL}
  日時:         ${CURRENT_DATE}
  稼働時間:     ${CURRENT_UPTIME}
  ========================================
REPORT
echo ""

# ヒアドキュメントの変数展開を抑制する
echo "--- クォート付きデリミタ（変数展開の抑制） ---"
cat << 'NO_EXPAND'
  デリミタをクォートで囲むと、変数展開が抑制される:
    $HOME は展開されない
    $(date) も実行されない
  これはテンプレートの記述に有用だ。
NO_EXPAND
echo ""

# --- 演習4: trapによるシグナルハンドリング ---
echo "================================================================"
echo "[演習4] trapによるシグナルハンドリング"
echo "================================================================"
echo ""
echo "Bourne shellのtrapは、シグナル受信時の動作を定義する。"
echo ""

TMPFILE="${WORKDIR}/trap-demo.$$"

echo "--- trap の設定 ---"
echo "  trap 'rm -f \"\$TMPFILE\"; echo \"後始末完了\"' EXIT"
echo ""

# サブシェルでtrapのデモを行う（親シェルのEXITに影響させないため）
(
  trap "rm -f \"${TMPFILE}\"; echo '  後始末: ${TMPFILE} を削除'" EXIT

  echo "一時ファイルを作成: ${TMPFILE}"
  echo "一時データ: PID=$$" > "${TMPFILE}"
  cat "${TMPFILE}"
  echo ""

  echo "サブシェル終了（trapが発火する）..."
)
echo ""
echo "一時ファイルが削除されたか確認:"
if [ -f "${TMPFILE}" ]; then
  echo "  ${TMPFILE}: まだ存在する（想定外）"
else
  echo "  ${TMPFILE}: 削除済み（trapが正しく動作した）"
fi
echo ""

echo "trapにより、スクリプトの正常終了でも異常終了でも"
echo "後始末が確実に実行される。"
echo ""

# --- 演習5: Thompson shell時代との対比 ---
echo "================================================================"
echo "[演習5] Thompson shell時代との対比"
echo "================================================================"
echo ""
echo "同じタスクをThompson shell的手法とBourne shell手法で比較する。"
echo ""

DEMO_DIR="${WORKDIR}/compare"
mkdir -p "${DEMO_DIR}"

# テストファイルの準備
echo "ERROR: disk full" > "${DEMO_DIR}/app1.log"
echo "INFO: started" > "${DEMO_DIR}/app2.log"
echo "ERROR: timeout" > "${DEMO_DIR}/app3.log"
echo "INFO: healthy" > "${DEMO_DIR}/app4.log"
echo "ERROR: connection refused" > "${DEMO_DIR}/app5.log"

echo "タスク: ERRORを含むログファイルの一覧を出力"
echo ""

echo "--- [Thompson shell的手法] ---"
echo "変数なし、制御構造なし。ファイルごとに手動で確認する:"
echo "  grep ERROR app1.log > /dev/null && echo app1.log"
echo "  grep ERROR app2.log > /dev/null && echo app2.log"
echo "  grep ERROR app3.log > /dev/null && echo app3.log"
echo "  ... (ファイル数だけ繰り返す)"
echo ""

echo "--- [Bourne shell] ---"
echo "変数 + for + if で自動化:"
ERROR_COUNT=0
for logfile in "${DEMO_DIR}"/*.log; do
  if grep -q ERROR "$logfile"; then
    echo "  ERROR検出: $(basename "$logfile")"
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi
done
echo ""
echo "  合計: ${ERROR_COUNT} ファイルにERRORが含まれる"
echo ""

echo "Bourne shellの変数と制御構造により、"
echo "ファイル数が増えてもスクリプトを変更する必要がない。"
echo "これが『プログラミング言語』としてのシェルの力だ。"
echo ""

# --- 完了 ---
echo "================================================================"
echo " 演習完了"
echo "================================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "Bourne shellは「コマンドインタプリタ」を"
echo "「コマンドプログラミング言語」に変えた。"
echo "だがその言語設計には、ワード分割という罠が潜んでいる。"
echo "次回はその罠を正面から扱う。"

# 掃除
rm -rf "${WORKDIR}"
