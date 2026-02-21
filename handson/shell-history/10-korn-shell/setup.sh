#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-10"

echo "============================================"
echo " 第10回ハンズオン: Korn shell"
echo " \"全部入り\"への最初の挑戦"
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

# -------------------------------------------
# セクション2: 必要パッケージの確認
# -------------------------------------------
echo "--- セクション2: 必要パッケージの確認 ---"
if command -v mksh > /dev/null 2>&1; then
    echo "  mksh: インストール済み"
else
    echo "  mksh: 未インストール（apt-get install -y mksh でインストールしてください）"
fi

if command -v bc > /dev/null 2>&1; then
    echo "  bc: インストール済み"
else
    echo "  bc: 未インストール（apt-get install -y bc でインストールしてください）"
fi

if command -v bash > /dev/null 2>&1; then
    echo "  bash: インストール済み"
else
    echo "  bash: 未インストール"
fi
echo ""

# -------------------------------------------
# セクション3: 算術展開比較スクリプトの作成
# -------------------------------------------
echo "--- セクション3: 算術展開比較スクリプトの作成 ---"

cat > "${WORKDIR}/arithmetic-compare.sh" << 'SCRIPT'
#!/bin/bash
echo "=== 算術展開: bash vs mksh 比較 ==="
echo ""

echo "--- bash での算術展開 ---"
bash -c '
echo "3 + 5 = $(( 3 + 5 ))"
echo "10 * 3 = $(( 10 * 3 ))"
a=10
echo "a=10, a++ = $(( a++ )), a is now $a"
echo "0xFF & 0x0F = $(( 0xFF & 0x0F ))"
echo "1 << 4 = $(( 1 << 4 ))"
x=42
echo "x=42, (x > 30) = $(( x > 30 ? 1 : 0 )) (1=true)"
'

echo ""
echo "--- mksh での算術展開 ---"
mksh -c '
echo "3 + 5 = $(( 3 + 5 ))"
echo "10 * 3 = $(( 10 * 3 ))"
a=10
echo "a=10, a++ = $(( a++ )), a is now $a"
echo "0xFF & 0x0F = $(( 0xFF & 0x0F ))"
echo "1 << 4 = $(( 1 << 4 ))"
x=42
echo "x=42, (x > 30) = $(( x > 30 ? 1 : 0 )) (1=true)"
'

echo ""
echo "結論: 算術展開の構文はkshが発明し、POSIXが標準化した。"
echo "bashとkshで同じ構文が使えるのは偶然ではない。"
SCRIPT
chmod +x "${WORKDIR}/arithmetic-compare.sh"
echo "  作成: arithmetic-compare.sh"

# -------------------------------------------
# セクション4: 拡張グロビング比較スクリプトの作成
# -------------------------------------------
echo "--- セクション4: 拡張グロビング比較スクリプトの作成 ---"

cat > "${WORKDIR}/extglob-compare.sh" << 'SCRIPT'
#!/bin/bash
echo "=== 拡張グロビング: bash vs mksh 比較 ==="
echo ""

TESTDIR=$(mktemp -d)
touch "${TESTDIR}/report.txt" "${TESTDIR}/notes.md" "${TESTDIR}/backup.bak"
touch "${TESTDIR}/data.csv" "${TESTDIR}/temp.tmp" "${TESTDIR}/log.txt"

echo "テストファイル:"
ls "${TESTDIR}"
echo ""

echo "--- mksh: 拡張グロビング（デフォルトで有効）---"
mksh -c "
cd ${TESTDIR}
echo '@(*.txt|*.md) → .txt または .md:'
echo @(*.txt|*.md)
echo ''
echo '!(*.bak|*.tmp) → .bak と .tmp 以外:'
echo !(*.bak|*.tmp)
"

echo ""
echo "--- bash: 拡張グロビング（shopt -s extglob が必要）---"
bash -c "
cd ${TESTDIR}
shopt -s extglob
echo '@(*.txt|*.md) → .txt または .md:'
echo @(*.txt|*.md)
echo ''
echo '!(*.bak|*.tmp) → .bak と .tmp 以外:'
echo !(*.bak|*.tmp)
"

rm -rf "${TESTDIR}"

echo ""
echo "結論: 拡張グロビングはkshが導入し、bashが shopt -s extglob で借用した。"
echo "kshではデフォルト有効、bashでは明示的な有効化が必要。"
SCRIPT
chmod +x "${WORKDIR}/extglob-compare.sh"
echo "  作成: extglob-compare.sh"

# -------------------------------------------
# セクション5: コプロセス演習スクリプトの作成
# -------------------------------------------
echo "--- セクション5: コプロセス演習スクリプトの作成 ---"

cat > "${WORKDIR}/coproc-demo.sh" << 'SCRIPT'
#!/bin/bash
echo "=== コプロセスの実演 ==="
echo ""

echo "--- mksh のコプロセス (|& 構文) ---"
mksh -c '
bc |&
print -p "scale=10; 4*a(1)"
read -p pi
echo "pi = $pi"

print -p "2^10"
read -p result
echo "2^10 = $result"

print -p "scale=5; s(3.14159/6)"
read -p sin30
echo "sin(30 deg) = $sin30"

print -p "quit"
'

echo ""
echo "kshは1988年からコプロセスをサポート。"
echo "bashは4.0（2009年）で coproc キーワードとして導入。"
SCRIPT
chmod +x "${WORKDIR}/coproc-demo.sh"
echo "  作成: coproc-demo.sh"

# -------------------------------------------
# セクション6: select文デモスクリプトの作成
# -------------------------------------------
echo "--- セクション6: select文デモスクリプトの作成 ---"

cat > "${WORKDIR}/select-demo.sh" << 'SCRIPT'
#!/bin/mksh
# kshのselect文によるメニュー
echo "=== select文デモ ==="
echo "kshが導入したメニュー選択構文"
echo ""

PS3="シェルを選択 (番号を入力): "
select shell in bash zsh ksh fish dash 終了; do
    case "$shell" in
        bash)  echo "  → GNUの標準シェル。Brian Fox, 1989年〜" ;;
        zsh)   echo "  → 最大主義。Paul Falstad, 1990年〜" ;;
        ksh)   echo "  → 本日の主役。David Korn, 1983年〜" ;;
        fish)  echo "  → POSIX非互換の挑戦者。2005年〜" ;;
        dash)  echo "  → POSIX原理主義。起動速度重視" ;;
        終了)  echo "  終了します"; break ;;
        *)     echo "  → 無効な選択: $REPLY" ;;
    esac
done
SCRIPT
chmod +x "${WORKDIR}/select-demo.sh"
echo "  作成: select-demo.sh"

# -------------------------------------------
# セクション7: bash vs mksh 構文差異スクリプトの作成
# -------------------------------------------
echo "--- セクション7: bash vs mksh 構文差異スクリプトの作成 ---"

cat > "${WORKDIR}/syntax-compare.sh" << 'SCRIPT'
#!/bin/bash
echo "=== bash vs mksh 構文差異 ==="
echo ""

echo "--- 1. print コマンド（ksh固有）vs echo ---"
echo "[bash] echo:"
bash -c 'echo "hello\tworld"'
echo "[mksh] print:"
mksh -c 'print "hello\tworld"'
echo "[mksh] print -r (raw):"
mksh -c 'print -r "hello\tworld"'
echo ""

echo "--- 2. typeset -i による整数型宣言 ---"
echo "[mksh]:"
mksh -c 'typeset -i num; num="3+5"; echo "  typeset -i num; num=\"3+5\" -> $num"'
echo "[bash]:"
bash -c 'declare -i num; num="3+5"; echo "  declare -i num; num=\"3+5\" -> $num"'
echo ""

echo "--- 3. whence（ksh）vs type（bash）---"
echo "[mksh] whence -v ls:"
mksh -c 'whence -v ls' 2>/dev/null || echo "  (whence not available)"
echo "[bash] type ls:"
bash -c 'type ls'
echo ""

echo "--- 4. print -s によるヒストリ追加（ksh固有）---"
echo "[mksh]:"
mksh -c 'print -s "manually added command"; echo "  print -s でヒストリに直接追加可能"'
echo "[bash]:"
echo "  history -s で同等の操作が可能"
echo ""

echo "結論: kshとbashは多くの共通機能を持つが、"
echo "ksh固有のコマンド（print, whence）とbash固有のコマンド（type, help）がある。"
SCRIPT
chmod +x "${WORKDIR}/syntax-compare.sh"
echo "  作成: syntax-compare.sh"

# -------------------------------------------
# セクション8: 演習手順の表示
# -------------------------------------------
echo ""
echo "============================================"
echo " セットアップ完了"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "演習手順:"
echo ""
echo "  演習1: コマンドライン編集の体験"
echo "    mksh"
echo "    # emacs モード: Ctrl-P/N (ヒストリ), Ctrl-A/E (行頭/末)"
echo "    # vi モード: set -o vi"
echo ""
echo "  演習2: 算術展開の比較"
echo "    bash ${WORKDIR}/arithmetic-compare.sh"
echo ""
echo "  演習3: 拡張グロビングの比較"
echo "    bash ${WORKDIR}/extglob-compare.sh"
echo ""
echo "  演習4: select文デモ"
echo "    mksh ${WORKDIR}/select-demo.sh"
echo ""
echo "  演習5: コプロセスの動作確認"
echo "    bash ${WORKDIR}/coproc-demo.sh"
echo ""
echo "  演習6: bash vs mksh 構文差異"
echo "    bash ${WORKDIR}/syntax-compare.sh"
echo ""
