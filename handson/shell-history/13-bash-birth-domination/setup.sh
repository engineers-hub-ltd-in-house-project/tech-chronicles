#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-13"

echo "============================================"
echo " 第13回ハンズオン: Bashの誕生と席巻"
echo " 世界を飲み込んだGNUシェル"
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
# セクション2: bashバージョンと環境確認
# -------------------------------------------
echo "--- セクション2: bashバージョンと環境確認 ---"
echo ""
echo "bash version: ${BASH_VERSION}"
echo "bash versinfo: ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}"
echo ""

echo "=== shopt オプション一覧 ==="
shopt | head -20
echo "  ... (全 $(shopt | wc -l) オプション)"
echo ""

# -------------------------------------------
# セクション3: 配列と連想配列
# -------------------------------------------
echo "--- セクション3: 配列と連想配列 ---"

echo ""
echo "=== インデックス配列（bash 2.0+） ==="
shells=("bash" "zsh" "fish" "dash" "ksh")

echo "全要素: ${shells[*]}"
echo "要素数: ${#shells[@]}"
echo "3番目:  ${shells[2]}"

for shell in "${shells[@]}"; do
    echo "  - ${shell}"
done

echo ""
echo "=== 連想配列（bash 4.0+） ==="
declare -A shell_year
shell_year["Thompson shell"]=1971
shell_year["Bourne shell"]=1979
shell_year["csh"]=1978
shell_year["ksh"]=1983
shell_year["bash"]=1989
shell_year["zsh"]=1990
shell_year["fish"]=2005

for name in "${!shell_year[@]}"; do
    printf "  %-16s : %d年\n" "${name}" "${shell_year[$name]}"
done

# -------------------------------------------
# セクション4: 拡張条件式と正規表現マッチ
# -------------------------------------------
echo ""
echo "--- セクション4: 拡張条件式と正規表現マッチ ---"

echo ""
echo "=== [[ ... ]] と [ ... ] の違い ==="
filename="my file.txt"

if [ -n "$filename" ]; then
    echo "[ ... ]: 変数にはクォーティングが必要"
fi

if [[ -n $filename ]]; then
    echo "[[ ... ]]: ワード分割が起きないため安全"
fi

echo ""
echo "=== 正規表現マッチ =~ ==="
version="bash-5.2.15"

if [[ $version =~ ^bash-([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "マッチした: ${version}"
    echo "  メジャー: ${BASH_REMATCH[1]}"
    echo "  マイナー: ${BASH_REMATCH[2]}"
    echo "  パッチ:   ${BASH_REMATCH[3]}"
else
    echo "マッチしなかった"
fi

# -------------------------------------------
# セクション5: プロセス置換
# -------------------------------------------
echo ""
echo "--- セクション5: プロセス置換 <(...) ---"

echo ""
echo "=== /etc/shells の内容を確認 ==="
if [ -f /etc/shells ]; then
    cat /etc/shells
else
    echo "(/etc/shells が存在しません)"
fi

echo ""
echo "=== 二つのディレクトリのファイル一覧を比較 ==="
echo "diff <(ls /bin | head -5) <(ls /usr/bin | head -5)"
diff <(ls /bin 2>/dev/null | head -5) <(ls /usr/bin 2>/dev/null | head -5) || true

# -------------------------------------------
# セクション6: EPOCHSECONDS と EPOCHREALTIME
# -------------------------------------------
echo ""
echo "--- セクション6: EPOCHSECONDS / EPOCHREALTIME（bash 5.0+） ---"

if [[ -n "${EPOCHSECONDS:-}" ]]; then
    echo "EPOCHSECONDS:  ${EPOCHSECONDS}"
    echo "EPOCHREALTIME: ${EPOCHREALTIME}"
    echo ""
    echo "date コマンドとの比較:"
    echo "  date +%s:      $(date +%s)"
    echo "  EPOCHSECONDS:  ${EPOCHSECONDS}"
    echo ""
    echo "EPOCHSECONDS は外部コマンドを呼ばずに UNIX 時刻を取得できる。"
else
    echo "EPOCHSECONDS は bash 5.0 以降で利用可能"
    echo "現在の bash バージョン: ${BASH_VERSION}"
fi

# -------------------------------------------
# セクション7: コプロセス
# -------------------------------------------
echo ""
echo "--- セクション7: コプロセス (coproc, bash 4.0+) ---"

coproc MYPROC { cat; }

echo "Hello from main process" >&"${MYPROC[1]}"

read -r line <&"${MYPROC[0]}"
echo "コプロセスから受信: ${line}"

exec {MYPROC[1]}>&-
wait "${MYPROC_PID}" 2>/dev/null || true
echo "コプロセス終了"

# -------------------------------------------
# セクション8: プログラマブル補完のデモ
# -------------------------------------------
echo ""
echo "--- セクション8: プログラマブル補完のカスタム定義 ---"

cat << 'SCRIPT' > "${WORKDIR}/custom_completion.sh"
#!/bin/bash
# カスタム補完関数のデモ
# このスクリプトを source して使う: source custom_completion.sh

# 仮想コマンド "shellctl" の補完定義
_shellctl_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # サブコマンド一覧
    local commands="list info switch default history"

    # サブコマンドの補完
    if [ "${COMP_CWORD}" -eq 1 ]; then
        COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        return
    fi

    # サブコマンドごとの引数補完
    case "$prev" in
        switch|info)
            local shells="bash zsh fish dash ksh tcsh"
            COMPREPLY=( $(compgen -W "$shells" -- "$cur") )
            ;;
        list)
            local options="--all --installed --available"
            COMPREPLY=( $(compgen -W "$options" -- "$cur") )
            ;;
    esac
}

complete -F _shellctl_complete shellctl
echo "shellctl の補完が有効になりました。"
echo "使い方: shellctl [TAB] で補完を試してください。"
SCRIPT
echo "  作成: ${WORKDIR}/custom_completion.sh"
echo ""
echo "  補完を試すには:"
echo "    source ${WORKDIR}/custom_completion.sh"
echo "    shellctl [TABキーを押す]"

# -------------------------------------------
# セクション9: bash固有機能 vs POSIX sh の境界確認
# -------------------------------------------
echo ""
echo "--- セクション9: bash固有機能 vs POSIX sh の境界 ---"

cat << 'SCRIPT' > "${WORKDIR}/bash_vs_posix.sh"
#!/bin/bash
# bash 固有機能を使ったスクリプト（dash/ash では動かない）
echo "=== bash 固有機能のデモ ==="

# 1. 配列
arr=("one" "two" "three")
echo "配列: ${arr[*]}"

# 2. [[ ... ]]
if [[ "hello" == h* ]]; then
    echo "[[ ... ]]: パターンマッチ成功"
fi

# 3. プロセス置換
wc -l <(echo -e "line1\nline2\nline3")

# 4. ブレース展開
echo "ブレース展開: "{A,B,C}_{1,2}

# 5. $'...' ANSI-C クォーティング
echo $'タブ区切り:\tここ'

echo ""
echo "上記はすべて bash 固有（または bash + zsh）の機能。"
echo "POSIX sh / dash / BusyBox ash では動作しない。"
SCRIPT

cat << 'POSIXSCRIPT' > "${WORKDIR}/posix_equivalent.sh"
#!/bin/sh
# 上と同等の処理を POSIX sh で書いた場合
echo "=== POSIX sh 互換のデモ ==="

# 1. 配列の代替（スペース区切り文字列）
items="one two three"
echo "要素: ${items}"

# 2. [ ... ] 標準条件式
case "hello" in
    h*) echo "[ ... ]: パターンマッチ成功" ;;
esac

# 3. プロセス置換の代替（一時ファイル）
tmpfile=$(mktemp)
printf "line1\nline2\nline3\n" > "$tmpfile"
wc -l "$tmpfile"
rm -f "$tmpfile"

# 4. ブレース展開の代替
for letter in A B C; do
    for num in 1 2; do
        printf "%s_%s " "${letter}" "${num}"
    done
done
echo ""

# 5. タブの出力
printf "タブ区切り:\tここ\n"

echo ""
echo "上記はすべて POSIX sh 準拠。dash/ash/bash で動作する。"
POSIXSCRIPT

chmod +x "${WORKDIR}/bash_vs_posix.sh"
chmod +x "${WORKDIR}/posix_equivalent.sh"
echo "  作成: ${WORKDIR}/bash_vs_posix.sh  (bash 固有機能)"
echo "  作成: ${WORKDIR}/posix_equivalent.sh  (POSIX 準拠版)"
echo ""

echo "=== bash 版を実行 ==="
bash "${WORKDIR}/bash_vs_posix.sh"
echo ""
echo "=== POSIX 版を実行 ==="
/bin/sh "${WORKDIR}/posix_equivalent.sh" 2>&1 || bash "${WORKDIR}/posix_equivalent.sh"

# -------------------------------------------
# セクション10: まとめ
# -------------------------------------------
echo ""
echo "============================================"
echo " ハンズオン完了"
echo "============================================"
echo ""
echo "作成されたファイル:"
echo "  ${WORKDIR}/custom_completion.sh   -- プログラマブル補完デモ"
echo "  ${WORKDIR}/bash_vs_posix.sh       -- bash固有機能デモ"
echo "  ${WORKDIR}/posix_equivalent.sh    -- POSIX準拠版"
echo ""
echo "追加演習:"
echo "  1. custom_completion.sh を source して TAB 補完を体験する"
echo "  2. bash_vs_posix.sh を dash で実行してエラーを確認する:"
echo "     dash ${WORKDIR}/bash_vs_posix.sh"
echo "  3. Alpine コンテナで posix_equivalent.sh の動作を確認する:"
echo "     docker run --rm -v ${WORKDIR}:/work alpine:3.21 /bin/sh /work/posix_equivalent.sh"
