#!/bin/bash
# =============================================================================
# 第3回ハンズオン：Thompson shellの世界を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 前提: Docker環境（ubuntu:24.04）またはbashが使えるLinux環境
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-03"

echo "=== 第3回ハンズオン：Thompson shellの世界を体験する ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# --- 演習1: リダイレクトだけでデータ処理を行う ---
echo "================================================================"
echo "[演習1] リダイレクトだけでデータ処理を行う（パイプなし）"
echo "================================================================"
echo ""
echo "Thompson shell V1にはパイプがなかった。"
echo "パイプなしでデータ処理を行うとどうなるか体験する。"
echo ""

# サンプルデータの作成
cat > "${WORKDIR}/access_log.txt" << 'EOF'
192.168.1.10 GET /index.html 200
192.168.1.20 GET /about.html 200
192.168.1.10 POST /api/login 401
192.168.1.30 GET /index.html 200
192.168.1.20 GET /contact.html 404
192.168.1.10 GET /dashboard 200
192.168.1.40 POST /api/login 200
192.168.1.10 GET /settings 403
192.168.1.30 POST /api/data 500
192.168.1.20 GET /index.html 200
EOF

echo "サンプルデータを作成しました: ${WORKDIR}/access_log.txt"
echo ""

echo "--- パイプなしのデータ処理（Thompson shell V1の世界） ---"
echo "エラー応答（4xx, 5xx）のIPアドレスを集計する"
echo ""

# パイプなしで処理する（中間ファイルが必要）
grep -E ' [45][0-9]{2}$' "${WORKDIR}/access_log.txt" > "${WORKDIR}/step1_errors.txt"
echo "Step 1: エラー行を抽出 → step1_errors.txt"
cat "${WORKDIR}/step1_errors.txt"
echo ""

awk '{print $1}' "${WORKDIR}/step1_errors.txt" > "${WORKDIR}/step2_ips.txt"
echo "Step 2: IPアドレスを取り出す → step2_ips.txt"
cat "${WORKDIR}/step2_ips.txt"
echo ""

sort "${WORKDIR}/step2_ips.txt" > "${WORKDIR}/step3_sorted.txt"
echo "Step 3: ソートする → step3_sorted.txt"
cat "${WORKDIR}/step3_sorted.txt"
echo ""

uniq -c "${WORKDIR}/step3_sorted.txt" > "${WORKDIR}/step4_result.txt"
echo "Step 4: 集計する → step4_result.txt"
cat "${WORKDIR}/step4_result.txt"
echo ""

echo "中間ファイル一覧:"
ls -la "${WORKDIR}"/step*.txt
echo ""

echo "--- パイプありのデータ処理（V3以降の世界） ---"
echo "同じ処理がパイプで1行に書ける:"
echo '  grep -E " [45][0-9]{2}$" access_log.txt | awk "{print $1}" | sort | uniq -c'
echo ""
echo "結果:"
grep -E ' [45][0-9]{2}$' "${WORKDIR}/access_log.txt" | awk '{print $1}' | sort | uniq -c
echo ""
echo "パイプなし: 中間ファイル4個が必要"
echo "パイプあり: 中間ファイル0個"
echo ""

# 中間ファイルを掃除
rm -f "${WORKDIR}"/step*.txt

# --- 演習2: 「変数なし」の世界を体験する ---
echo "================================================================"
echo "[演習2] 「変数なし」の世界を体験する"
echo "================================================================"
echo ""

echo "--- 変数が使える世界（現代のシェル） ---"
TARGET_DIR="/etc"
FILE_COUNT=$(ls -1 "$TARGET_DIR" | wc -l)
echo "TARGET_DIR=\"${TARGET_DIR}\""
echo "FILE_COUNT=\$(ls -1 \"\$TARGET_DIR\" | wc -l)"
echo "結果: ${TARGET_DIR} には ${FILE_COUNT} 個のエントリがある"
echo ""

echo "--- 変数なしの世界（Thompson shellの制約） ---"
echo "パスを何度も直接書くしかない:"
echo "  /etc には $(ls -1 /etc | wc -l) 個のエントリがある"
echo "  /usr には $(ls -1 /usr | wc -l) 個のエントリがある"
echo ""
echo "変数がなければ、値の再利用ができない。"
echo "同じパスを何度も手で書く必要がある。"
echo "修正時には全箇所を漏れなく変更しなければならない。"
echo ""

# --- 演習3: if/gotoが外部コマンドだった世界を再現する ---
echo "================================================================"
echo "[演習3] if/gotoが外部コマンドだった世界を再現する"
echo "================================================================"
echo ""

# /bin/ifの簡易再現
cat > "${WORKDIR}/fake_if" << 'SCRIPT'
#!/bin/sh
# Thompson shellの/bin/ifの簡易再現
# 使い方: fake_if -r filename command [args...]
# 使い方: fake_if -w filename command [args...]

if [ "$1" = "-r" ]; then
  shift
  testfile="$1"
  shift
  if [ -r "$testfile" ]; then
    exec "$@"
  fi
elif [ "$1" = "-w" ]; then
  shift
  testfile="$1"
  shift
  if [ -w "$testfile" ]; then
    exec "$@"
  fi
fi
SCRIPT
chmod +x "${WORKDIR}/fake_if"

echo "テスト用ファイルを作成"
echo "hello from Thompson shell era" > "${WORKDIR}/testfile.txt"
echo ""

echo "--- /bin/if の動作再現 ---"
echo "コマンド: fake_if -r testfile.txt cat testfile.txt"
echo "（testfile.txtが読み取り可能ならcatを実行）"
echo ""
echo "結果:"
"${WORKDIR}/fake_if" -r "${WORKDIR}/testfile.txt" cat "${WORKDIR}/testfile.txt"
echo ""

echo "コマンド: fake_if -r nonexistent cat nonexistent"
echo "（存在しないファイルに対して実行）"
echo ""
echo "結果:"
"${WORKDIR}/fake_if" -r "${WORKDIR}/nonexistent" cat "${WORKDIR}/nonexistent" || true
echo "(何も表示されない = 条件が偽なのでコマンドは実行されない)"
echo ""

echo "--- /bin/goto の概念 ---"
echo "Thompson shellの/bin/gotoは、スクリプトファイル内の"
echo "': label' という行にlseek()でジャンプする仕組みだった。"
echo ""
echo "Thompson shell風スクリプトの概念的表現:"
echo "  : start"
echo "  echo \"処理A\""
echo "  goto end"
echo "  : middle"
echo "  echo \"ここはスキップされる\""
echo "  : end"
echo "  echo \"処理完了\""
echo ""
echo "現代のシェルにgotoは存在しない。"
echo "while/for/caseなどの構造化された制御構造に置き換えられた。"
echo ""

# --- 演習4: fork/execモデルを観察する ---
echo "================================================================"
echo "[演習4] fork/execモデルを観察する"
echo "================================================================"
echo ""

echo "現在のシェルのPID: $$"
echo ""

echo "--- 外部コマンド実行時のfork ---"
echo "親シェル(PID $$)がforkして子プロセスを生成し、"
echo "子プロセスがexecでコマンドに置き換わる。"
echo ""

echo "子プロセスのPIDを確認:"
sh -c 'echo "  子プロセスのPID: $$"'
echo ""

echo "--- バックグラウンド実行（&） ---"
echo "Thompson shellのV1からバックグラウンド実行は存在した。"
sleep 1 &
BG_PID=$!
echo "バックグラウンドプロセスのPID: ${BG_PID}"
echo "シェルは即座に次のコマンドを受け付ける。"
wait ${BG_PID}
echo "バックグラウンドプロセス完了。"
echo ""

echo "--- リダイレクトとfork/execの関係 ---"
echo "リダイレクトは、fork後・exec前に子プロセスが行う。"
echo "コマンド自身はリダイレクトを知らない。"
echo ""
echo "この文はファイルに書き込まれる" > "${WORKDIR}/redirect_demo.txt"
echo "リダイレクト先の内容:"
cat "${WORKDIR}/redirect_demo.txt"
echo ""

# --- 演習5: Thompson shellの機能一覧を確認する ---
echo "================================================================"
echo "[演習5] Thompson shellの機能一覧を確認する"
echo "================================================================"
echo ""

echo "--- Thompson shellにあった機能 ---"
echo ""

echo "[1] コマンド実行 (V1, 1971年から)"
ls /tmp > /dev/null 2>&1 && echo "  → OK"

echo "[2] 入出力リダイレクト > < (V1, 1971年から)"
echo "test" > "${WORKDIR}/redir_test.txt"
cat "${WORKDIR}/redir_test.txt" > /dev/null && echo "  → OK"

echo "[3] 逐次実行 ; (V1, 1971年から)"
echo "A" > /dev/null ; echo "B" > /dev/null && echo "  → OK"

echo "[4] バックグラウンド実行 & (V1, 1971年から)"
sleep 0.1 &
wait && echo "  → OK"

echo "[5] パイプ | (V3, 1973年から)"
echo "hello" | tr a-z A-Z > /dev/null && echo "  → OK"

echo ""
echo "--- Thompson shellになかった機能 ---"
echo ""

echo "[6] 名前付き変数"
DEMO_VAR="world"
echo "  現代: DEMO_VAR=\"world\" → ${DEMO_VAR}"
echo "  → Thompson shellでは不可能"

echo "[7] 制御構造 (for/while/case)"
RESULT=""
for i in 1 2 3; do RESULT="${RESULT}${i}"; done
echo "  現代: for i in 1 2 3; do ... done → ${RESULT}"
echo "  → Thompson shellでは不可能"

echo "[8] 関数定義"
demo_func() { echo "Hello, $1"; }
echo "  現代: demo_func() { ... }; demo_func World → $(demo_func World)"
echo "  → Thompson shellでは不可能"

echo ""
echo "================================================================"
echo " 演習完了"
echo "================================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "Thompson shellは「対話の最小限」を実装したシェルだった。"
echo "変数も制御構造もパイプ（V1）もない世界で、"
echo "シェルの本質が何であるかを考える手がかりになったはずだ。"

# 掃除
rm -f "${WORKDIR}/redir_test.txt" "${WORKDIR}/redirect_demo.txt"
rm -f "${WORKDIR}/testfile.txt" "${WORKDIR}/fake_if"
