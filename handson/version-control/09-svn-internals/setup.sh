#!/bin/bash
# =============================================================================
# 第9回ハンズオン：Subversionリポジトリの内部構造を覗く
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: subversion (svn, svnadmin, svnlook)
# 推奨環境: docker run -it --rm ubuntu:24.04 bash
#            apt update && apt install -y subversion
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-09"

echo "=== 第9回ハンズオン：Subversionリポジトリの内部構造を覗く ==="
echo ""

# 既存ディレクトリのクリーンアップ
if [ -d "${WORKDIR}" ]; then
  rm -rf "${WORKDIR}"
fi
mkdir -p "${WORKDIR}"

# --- 演習1: リポジトリの物理構造を確認する ---
echo "[演習1] リポジトリの物理構造を確認する"

svnadmin create "${WORKDIR}/myrepo"

echo "  FSFSバックエンド: $(cat "${WORKDIR}/myrepo/db/fs-type")"
echo "  FSFSフォーマット: $(head -1 "${WORKDIR}/myrepo/db/format")"
echo "  現在のリビジョン: $(cat "${WORKDIR}/myrepo/db/current")"
echo ""
echo "  リビジョンファイルの配置:"
ls -la "${WORKDIR}/myrepo/db/revs/0/"
echo ""
echo "  -> 1リビジョン＝1ファイル。これがFSFSの基本構造"
echo ""

# --- 演習2: コミットとリビジョンファイルの解剖 ---
echo "[演習2] コミットとリビジョンファイルの解剖"

svn checkout "file://${WORKDIR}/myrepo" "${WORKDIR}/wc" --quiet
cd "${WORKDIR}/wc"

svn mkdir trunk --quiet

cat > trunk/hello.c << 'SRCEOF'
#include <stdio.h>
int main(void) {
    printf("Hello, Subversion internals!\n");
    return 0;
}
SRCEOF
svn add trunk/hello.c --quiet
svn commit -m "Add trunk and hello.c" --quiet

echo "  現在のリビジョン: $(cat "${WORKDIR}/myrepo/db/current")"
echo ""
echo "  --- リビジョン1のファイル内容（生データ）---"
cat "${WORKDIR}/myrepo/db/revs/0/1"
echo ""
echo ""
echo "  -> node-revision、representation、changed-pathsが"
echo "     テキストとして読める。これがFSFSの透過性"
echo ""

# --- 演習3: svnlookによるリポジトリ検査 ---
echo "[演習3] svnlookによるリポジトリ検査"

echo "  --- svnlook info ---"
svnlook info "${WORKDIR}/myrepo"
echo ""

echo "  --- svnlook tree ---"
svnlook tree "${WORKDIR}/myrepo"
echo ""

echo "  --- svnlook changed ---"
svnlook changed "${WORKDIR}/myrepo"
echo ""

echo "  --- svnlook cat trunk/hello.c ---"
svnlook cat "${WORKDIR}/myrepo" trunk/hello.c
echo ""
echo "  -> svnlookはリポジトリを読み取り専用で検査する"
echo "     作業コピーを介さず直接アクセスする"
echo ""

# --- 演習4: 複数コミットとskip-deltaの効果を観察する ---
echo "[演習4] 複数コミットとリビジョンファイルのサイズ変化"

cd "${WORKDIR}/wc"

for i in $(seq 2 8); do
  cat > trunk/hello.c << SRCEOF
#include <stdio.h>
int main(void) {
    printf("Hello, Subversion internals! (version ${i})\n");
    return 0;
}
SRCEOF
  svn commit -m "Update hello.c to version ${i}" --quiet
done

echo "  --- リビジョンファイルのサイズ比較 ---"
for rev in $(seq 0 8); do
  size=$(wc -c < "${WORKDIR}/myrepo/db/revs/0/${rev}")
  printf "  リビジョン %d: %5d bytes\n" "${rev}" "${size}"
done
echo ""
echo "  -> デルタ格納により、変更が小さいリビジョンは"
echo "     ファイルサイズも小さくなる"
echo ""

# --- 演習5: svnadmin dumpフォーマット ---
echo "[演習5] svnadmin dumpフォーマット"

echo "  --- ダンプフォーマット（リビジョン0-1のみ）---"
svnadmin dump "${WORKDIR}/myrepo" -r 0:1 2>/dev/null
echo ""

echo "  --- 完全ダンプとデルタダンプのサイズ比較 ---"
full_size=$(svnadmin dump "${WORKDIR}/myrepo" 2>/dev/null | wc -c)
delta_size=$(svnadmin dump "${WORKDIR}/myrepo" --deltas 2>/dev/null | wc -c)
printf "  完全ダンプ:   %d bytes\n" "${full_size}"
printf "  デルタダンプ: %d bytes\n" "${delta_size}"
echo ""
echo "  -> デルタダンプはファイル内容を差分形式で出力する"
echo ""

# --- 演習6: ダンプ/ロードによるリポジトリの複製 ---
echo "[演習6] ダンプ/ロードによるリポジトリの複製"

svnadmin dump "${WORKDIR}/myrepo" > "${WORKDIR}/repo.dump" 2>/dev/null
svnadmin create "${WORKDIR}/newrepo"
svnadmin load "${WORKDIR}/newrepo" < "${WORKDIR}/repo.dump" > /dev/null 2>&1

echo "  元リポジトリの最新リビジョン:   $(svnlook youngest "${WORKDIR}/myrepo")"
echo "  複製先リポジトリの最新リビジョン: $(svnlook youngest "${WORKDIR}/newrepo")"
echo ""
echo "  --- 複製先でリビジョン1のツリーを確認 ---"
svnlook tree -r 1 "${WORKDIR}/newrepo"
echo ""
echo "  -> ダンプ/ロードでリポジトリの完全な複製が可能"
echo "  -> リビジョン番号、メッセージ、タイムスタンプ全てが保持される"

echo ""
echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ディレクトリ構成:"
ls -1 "${WORKDIR}/"
