#!/bin/bash
# =============================================================================
# 第7回ハンズオン：C shellの構文と対話機能を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 前提: Docker環境（ubuntu:24.04）またはbashが使えるLinux環境
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-07"

echo "=== 第7回ハンズオン：C shellの構文と対話機能を体験する ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# cshのインストール確認
if command -v csh > /dev/null 2>&1; then
  echo "csh: インストール済み"
else
  echo "csh をインストールします..."
  if command -v apt-get > /dev/null 2>&1; then
    apt-get update -qq && apt-get install -y -qq csh tcsh
  else
    echo "警告: cshを自動インストールできません。手動でインストールしてください。"
    exit 1
  fi
fi
echo ""

# =============================================================================
echo "=========================================="
echo " 演習1: cshとshの構文比較"
echo "=========================================="
echo ""

# Bourne shell版のスクリプト
cat > "${WORKDIR}/count.sh" << 'SHEOF'
#!/bin/sh
# Bourne shell: 1から5までカウント
count=1
while [ "$count" -le 5 ]; do
  echo "sh: count = $count"
  count=$((count + 1))
done
SHEOF
chmod +x "${WORKDIR}/count.sh"

# C shell版のスクリプト
cat > "${WORKDIR}/count.csh" << 'CSHEOF'
#!/bin/csh
# C shell: 1から5までカウント
set count = 1
while ($count <= 5)
  echo "csh: count = $count"
  @ count = $count + 1
end
CSHEOF
chmod +x "${WORKDIR}/count.csh"

echo "--- Bourne shell版 ---"
sh "${WORKDIR}/count.sh"
echo ""
echo "--- C shell版 ---"
csh "${WORKDIR}/count.csh"
echo ""

echo "--- 構文の違い ---"
echo "変数代入:    sh: count=1          csh: set count = 1"
echo "比較演算:    sh: [ \"\$count\" -le 5 ]   csh: (\$count <= 5)"
echo "算術演算:    sh: count=\$((count+1))   csh: @ count = \$count + 1"
echo "ブロック終端: sh: done               csh: end"
echo ""

# =============================================================================
echo "=========================================="
echo " 演習2: cshの対話的機能"
echo "=========================================="
echo ""

cat > "${WORKDIR}/interactive-demo.csh" << 'CSHEOF'
#!/bin/csh
# cshの対話的機能のデモ
set history = 100

echo "=== cshの対話的機能 ==="
echo ""

# エイリアスの定義
alias ll 'ls -la'
alias h 'history'

echo "--- エイリアス一覧 ---"
alias
echo ""

echo "--- ヒストリの使い方（対話モードで有効） ---"
echo '!!      : 直前のコマンドを再実行'
echo '!n      : コマンド番号nを再実行'
echo '!grep   : "grep"で始まる直近のコマンドを再実行'
echo '!$      : 直前のコマンドの最後の引数'
echo '!!:s/old/new/ : 直前のコマンドの一部を置換して再実行'
echo ""

echo "--- チルダ展開のデモ ---"
echo "ホームディレクトリ: ~"
echo "展開結果: $HOME"
CSHEOF
csh "${WORKDIR}/interactive-demo.csh"
echo ""

# =============================================================================
echo "=========================================="
echo " 演習3: if文の構文比較"
echo "=========================================="
echo ""

# Bourne shell版
cat > "${WORKDIR}/iftest.sh" << 'SHEOF'
#!/bin/sh
value=42
if [ "$value" -gt 30 ]; then
  echo "sh: $value は 30 より大きい"
elif [ "$value" -gt 20 ]; then
  echo "sh: $value は 20 より大きい"
else
  echo "sh: $value は 20 以下"
fi
SHEOF

# C shell版
cat > "${WORKDIR}/iftest.csh" << 'CSHEOF'
#!/bin/csh
set value = 42
if ($value > 30) then
  echo "csh: $value は 30 より大きい"
else if ($value > 20) then
  echo "csh: $value は 20 より大きい"
else
  echo "csh: $value は 20 以下"
endif
CSHEOF

echo "--- Bourne shell版 ---"
sh "${WORKDIR}/iftest.sh"
echo ""
echo "--- C shell版 ---"
csh "${WORKDIR}/iftest.csh"
echo ""

echo "--- 構文の違い ---"
echo "条件式:  sh: [ \"\$value\" -gt 30 ]  csh: (\$value > 30)"
echo "         shは外部コマンドtestを起動   cshは内蔵式評価器で処理"
echo "終端:    sh: fi (ALGOL 68由来)       csh: endif (C風)"
echo ""

# =============================================================================
echo "=========================================="
echo " 演習4: cshスクリプティングの制限"
echo "=========================================="
echo ""

echo "--- 制限1: stdoutとstderrの分離 ---"
echo ""

# Bourne shell: stdoutとstderrを別ファイルに
cat > "${WORKDIR}/redir.sh" << SHEOF
#!/bin/sh
echo "これはstdout" > ${WORKDIR}/out.txt
ls /nonexistent 2> ${WORKDIR}/err.txt
echo "stdout: \$(cat ${WORKDIR}/out.txt)"
echo "stderr: \$(cat ${WORKDIR}/err.txt)"
SHEOF
echo "Bourne shellでのstdout/stderr分離:"
sh "${WORKDIR}/redir.sh" 2>/dev/null
echo ""

echo "C shellでは stdout と stderr を別々のファイルに"
echo "リダイレクトする直接的な構文がない。"
echo "'>' はstdoutのみ、'>&' はstdoutとstderrの両方。"
echo "分離するには外部コマンドやサブシェルの回避策が必要。"
echo ""

echo "--- 制限2: ループ出力のパイプ ---"
echo ""
cat > "${WORKDIR}/loop-pipe.sh" << 'SHEOF'
#!/bin/sh
# Bourne shell: ループの出力を直接パイプに流せる
for word in apple banana cherry apple banana apple; do
  echo "$word"
done | sort | uniq -c | sort -rn
SHEOF
echo "Bourne shell: ループの出力をパイプに:"
sh "${WORKDIR}/loop-pipe.sh"
echo ""
echo "C shellではこの構文が直接使えない場合がある。"
echo ""

echo "--- 制限3: シグナルハンドリング ---"
cat > "${WORKDIR}/trap.sh" << 'SHEOF'
#!/bin/sh
# Bourne shell: 複数のシグナルをトラップ可能
trap 'echo "SIGINT受信"; exit 1' INT
trap 'echo "SIGTERM受信"; exit 1' TERM
trap 'echo "終了処理"' EXIT
echo "シグナルハンドラ設定済み（INT, TERM, EXIT）"
SHEOF
echo "Bourne shell: 複数シグナルのtrap:"
sh "${WORKDIR}/trap.sh"
echo ""
echo "C shell: onintr で SIGINT のみトラップ可能。"
echo "SIGTERM や EXIT のトラップはできない。"
echo ""

# =============================================================================
echo "=========================================="
echo " 演習5: foreach vs for"
echo "=========================================="
echo ""

# テストファイルの作成
mkdir -p "${WORKDIR}/logs"
echo "ERROR: disk full" > "${WORKDIR}/logs/app1.log"
echo "INFO: started" >> "${WORKDIR}/logs/app1.log"
echo "ERROR: timeout" >> "${WORKDIR}/logs/app1.log"
echo "INFO: running" > "${WORKDIR}/logs/app2.log"
echo "ERROR: connection refused" > "${WORKDIR}/logs/app3.log"
echo "INFO: completed" >> "${WORKDIR}/logs/app3.log"

# Bourne shell版
cat > "${WORKDIR}/logscan.sh" << SHEOF
#!/bin/sh
echo "=== Bourne shell: ログスキャン ==="
for logfile in ${WORKDIR}/logs/*.log; do
  errors=\$(grep -c "ERROR" "\$logfile")
  if [ "\$errors" -gt 0 ]; then
    basename=\$(basename "\$logfile")
    echo "\$basename: \$errors 件のエラー"
  fi
done
SHEOF

# C shell版
cat > "${WORKDIR}/logscan.csh" << CSHEOF
#!/bin/csh
echo "=== C shell: ログスキャン ==="
foreach logfile (${WORKDIR}/logs/*.log)
  set errors = \`grep -c "ERROR" "\$logfile"\`
  if (\$errors > 0) then
    set bname = \`basename "\$logfile"\`
    echo "\${bname}: \$errors 件のエラー"
  endif
end
CSHEOF

echo "--- Bourne shell版 ---"
sh "${WORKDIR}/logscan.sh"
echo ""
echo "--- C shell版 ---"
csh "${WORKDIR}/logscan.csh"
echo ""

echo "=== 構文の対比 ==="
echo "ループ:      sh: for f in *.log; do...done"
echo "             csh: foreach f (*.log)...end"
echo "コマンド置換: sh: \$(command)  csh: \`command\`"
echo "条件式:      sh: [ \"\$errors\" -gt 0 ]"
echo "             csh: (\$errors > 0)"
echo ""

# =============================================================================
echo "=========================================="
echo " 全演習完了"
echo "=========================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "cshを対話的に試したい場合:"
echo "  csh"
echo "  set history = 100"
echo "  alias ll 'ls -la'"
echo "  ll"
echo "  !!"
echo ""
echo "スクリプトを個別に実行したい場合:"
echo "  sh ${WORKDIR}/count.sh"
echo "  csh ${WORKDIR}/count.csh"
