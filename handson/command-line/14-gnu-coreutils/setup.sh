#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/command-line-handson-14"

echo "========================================"
echo " 第14回ハンズオン: GNU coreutils"
echo " 自由なUNIXツール群の再実装"
echo "========================================"
echo ""

# ----------------------------------------
# 作業ディレクトリの準備
# ----------------------------------------
echo "--- 作業ディレクトリを作成: ${WORKDIR} ---"
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ----------------------------------------
# 演習1: GNU coreutilsのバージョン確認と--helpの統一性
# ----------------------------------------
echo ""
echo "========================================"
echo " 演習1: GNU coreutilsの統一的インターフェース"
echo "========================================"
echo ""

echo "--- --version で出自を確認 ---"
echo ""
for cmd in ls cat sort head wc cut; do
    echo "$ ${cmd} --version | head -1"
    ${cmd} --version 2>&1 | head -1
done
echo ""
echo "=> すべて 'GNU coreutils' と表示される"
echo "   これらはAT&TのオリジナルUNIXコマンドではなく"
echo "   GNUプロジェクトによる再実装である"
echo ""

echo "--- --help の統一性 ---"
echo ""
echo "すべてのGNUコマンドで --help が使える:"
echo ""
for cmd in ls sort wc; do
    echo "$ ${cmd} --help | head -2"
    ${cmd} --help 2>&1 | head -2
    echo ""
done
echo "=> 使い方に迷ったらまず --help を試す"
echo "   これはGNUの規約であり、すべてのGNUツールで動作する"

# ----------------------------------------
# 演習2: GNU拡張の実例
# ----------------------------------------
echo ""
echo "========================================"
echo " 演習2: GNU拡張の実例"
echo "========================================"
echo ""

# テスト用データの生成
mkdir -p "${WORKDIR}/demo"
cd "${WORKDIR}/demo"
for i in $(seq 1 5); do
    dd if=/dev/urandom of="file_${i}.dat" bs=1024 count=$((i * 100)) 2>/dev/null
done
mkdir subdir
echo "hello world" > subdir/test.txt

echo "--- GNU拡張: ls --color=auto ---"
echo '$ ls --color=auto'
ls --color=auto
echo ""
echo "=> --color はGNU拡張。BSDでは -G を使う"
echo ""

echo "--- GNU拡張: long options による自己文書化 ---"
echo '$ ls -l --human-readable --sort=size *.dat'
ls -l --human-readable --sort=size *.dat
echo ""
echo "=> long options は自己文書化される"
echo "   -lhS と同じだが、意味が読み取りやすい"
echo ""

echo "--- GNU拡張: ls --group-directories-first ---"
echo '$ ls --group-directories-first'
ls --group-directories-first
echo ""
echo "=> ディレクトリを先頭に表示するGNU独自機能"
echo ""

echo "--- GNU拡張: head の負の行数指定 ---"
seq 1 10 > "${WORKDIR}/demo/numbers.txt"
echo '$ cat numbers.txt'
cat "${WORKDIR}/demo/numbers.txt"
echo ""
echo '$ head -n -3 numbers.txt'
head -n -3 "${WORKDIR}/demo/numbers.txt"
echo ""
echo "=> 最後の3行を除いた全行を出力"
echo "   POSIXのheadにはこの機能がない"
echo ""

echo "--- GNU拡張: sort --human-numeric-sort ---"
echo -e "1.5K\n2M\n500\n10G\n100K" > "${WORKDIR}/demo/sizes.txt"
echo '$ cat sizes.txt'
cat "${WORKDIR}/demo/sizes.txt"
echo ""
echo '$ sort --human-numeric-sort sizes.txt'
sort --human-numeric-sort "${WORKDIR}/demo/sizes.txt"
echo ""
echo "=> K, M, G などの単位を理解してソートするGNU拡張"

# ----------------------------------------
# 演習3: POSIXポータブルなスクリプトの書き方
# ----------------------------------------
echo ""
echo "========================================"
echo " 演習3: POSIXポータブル vs GNU依存"
echo "========================================"
echo ""

echo "--- POSIXLY_CORRECT で GNU 拡張を無効化 ---"
echo ""
echo "通常モード（GNU拡張有効）:"
echo '$ head -n -3 numbers.txt'
head -n -3 "${WORKDIR}/demo/numbers.txt"
echo ""

echo "POSIX互換モード（GNU拡張無効）:"
echo '$ POSIXLY_CORRECT=1 head -n -3 numbers.txt'
POSIXLY_CORRECT=1 head -n -3 "${WORKDIR}/demo/numbers.txt" 2>&1 || \
    echo "(エラー: POSIXのheadは負の行数を受け付けない)"
echo ""

echo "--- ポータブルなスクリプトの例 ---"
echo ""
echo "# 非ポータブル（GNU依存）:"
echo '  sed -i "s/old/new/g" file          # BSD sed では動かない'
echo '  date -d "2024-01-15" +%s           # BSD date では動かない'
echo '  ls --color=auto                    # BSD ls では動かない'
echo ""
echo "# ポータブル（POSIX準拠）:"
echo '  sed "s/old/new/g" file > file.tmp && mv file.tmp file'
echo '  ls -l                              # POSIXオプションのみ'
echo ""

echo "--- sed の GNU/BSD 互換テクニック ---"
echo ""

# 実際にsed -iを試す
echo "original text" > "${WORKDIR}/demo/sed_test.txt"
echo '$ cat sed_test.txt'
cat "${WORKDIR}/demo/sed_test.txt"

echo ""
echo "# GNU sed でのインプレース編集:"
echo '$ sed -i "s/original/modified/g" sed_test.txt'
sed -i "s/original/modified/g" "${WORKDIR}/demo/sed_test.txt"
echo '$ cat sed_test.txt'
cat "${WORKDIR}/demo/sed_test.txt"

echo ""
echo "# ポータブルなインプレース編集:"
echo "original text" > "${WORKDIR}/demo/sed_test2.txt"
echo '$ sed "s/original/modified/g" sed_test2.txt > sed_test2.tmp'
echo '$ mv sed_test2.tmp sed_test2.txt'
sed "s/original/modified/g" "${WORKDIR}/demo/sed_test2.txt" > "${WORKDIR}/demo/sed_test2.tmp"
mv "${WORKDIR}/demo/sed_test2.tmp" "${WORKDIR}/demo/sed_test2.txt"
echo '$ cat sed_test2.txt'
cat "${WORKDIR}/demo/sed_test2.txt"
echo ""
echo "=> 一時ファイル経由の方法はどのOS・環境でも動作する"

# ----------------------------------------
# まとめ
# ----------------------------------------
echo ""
echo "========================================"
echo " まとめ"
echo "========================================"
echo ""
echo "1. あなたが使っている ls, cat, sort は GNU coreutils の再実装"
echo "2. --version で出自を確認できる"
echo "3. --help はすべての GNU ツールで統一されている"
echo "4. GNU 拡張は便利だが、ポータビリティを損なう場合がある"
echo "5. POSIXLY_CORRECT=1 でポータブルかどうかを検証できる"
echo "6. クロスプラットフォームスクリプトでは POSIX 準拠を意識する"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
