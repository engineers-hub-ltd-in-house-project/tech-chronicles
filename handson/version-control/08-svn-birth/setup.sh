#!/bin/bash
# =============================================================================
# 第8回ハンズオン：Subversionサーバの構築と基本操作
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: subversion (svn, svnadmin)
# 推奨環境: docker run -it --rm ubuntu:24.04 bash
#            apt update && apt install -y subversion
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-08"

echo "=== 第8回ハンズオン：Subversionサーバの構築と基本操作 ==="
echo ""

# 作業ディレクトリの初期化
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- 演習1: リポジトリの作成とアトミックコミット ---
echo "[演習1] リポジトリの作成とアトミックコミット"

# SVNリポジトリの作成（FSFSバックエンド）
svnadmin create "${WORKDIR}/myrepo"

echo "  リポジトリ作成完了"
echo "  バックエンド: $(cat "${WORKDIR}/myrepo/db/fs-type")"
echo ""

# 作業コピーのチェックアウト
svn checkout "file://${WORKDIR}/myrepo" "${WORKDIR}/wc" --quiet
cd "${WORKDIR}/wc"

# 標準ディレクトリ構造の作成
svn mkdir trunk branches tags --quiet
svn commit -m "Create standard directory layout" --quiet

echo "  リビジョン1: 標準ディレクトリ構造（trunk/branches/tags）を作成"
echo "  -> CVSではディレクトリの作成は履歴に記録されなかった"
echo ""

# 複数ファイルのアトミックコミット
cat > trunk/main.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"

int main(void) {
    printf("%s version %s\n", APP_NAME, APP_VERSION);
    return 0;
}
SRCEOF

cat > trunk/config.h << 'SRCEOF'
#ifndef CONFIG_H
#define CONFIG_H
#define APP_NAME "SVN Demo"
#define APP_VERSION "1.0"
#endif
SRCEOF

cat > trunk/Makefile << 'SRCEOF'
CC = gcc
CFLAGS = -Wall -I.

app: main.c config.h
	$(CC) $(CFLAGS) -o app main.c

clean:
	rm -f app
SRCEOF

svn add trunk/main.c trunk/config.h trunk/Makefile --quiet
svn commit -m "Add initial source code: main.c, config.h, Makefile" --quiet

echo "  リビジョン2: 3つのファイルが1つのアトミックコミット"
echo "  -> CVSでは各ファイルが独立したリビジョン番号を持った"
echo "  -> Subversionではリポジトリ全体で1つのリビジョン番号"
echo ""

svn log -r 2 -v "file://${WORKDIR}/myrepo"
echo ""

# --- 演習2: リネームの追跡 ---
echo "[演習2] リネームの追跡"

cd "${WORKDIR}/wc"
svn move trunk/main.c trunk/app.c --quiet
svn commit -m "Rename main.c to app.c" --quiet

echo "  リビジョン3: main.c を app.c にリネーム"
echo ""

echo "  --- リネーム後の変更ログ ---"
svn log -v -r 3 "file://${WORKDIR}/myrepo"
echo ""

echo "  --- app.c の履歴（リネーム前を含む）---"
svn log "file://${WORKDIR}/myrepo/trunk/app.c"
echo ""

echo "  -> app.c の履歴を遡ると、main.c だった頃のコミットも表示される"
echo "  -> CVSではリネームすると履歴が断絶した"
echo ""

# --- 演習3: cheap copy によるブランチとタグ ---
echo "[演習3] cheap copy によるブランチとタグ"

cd "${WORKDIR}/wc"

# タグの作成（サーバ側操作）
svn copy "file://${WORKDIR}/myrepo/trunk" \
         "file://${WORKDIR}/myrepo/tags/release-1.0" \
         -m "Tag release 1.0" --quiet

echo "  リビジョン4: release-1.0 タグを作成（cheap copy）"

# ブランチの作成（サーバ側操作）
svn copy "file://${WORKDIR}/myrepo/trunk" \
         "file://${WORKDIR}/myrepo/branches/feature-new-output" \
         -m "Create feature branch" --quiet

echo "  リビジョン5: feature-new-output ブランチを作成（cheap copy）"
echo ""

# 作業コピーを更新
svn update --quiet

# ブランチ上でファイルを変更
cat > branches/feature-new-output/app.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"

int main(void) {
    printf("=== %s ===\n", APP_NAME);
    printf("Version: %s\n", APP_VERSION);
    printf("Build date: %s\n", __DATE__);
    return 0;
}
SRCEOF

svn commit -m "Enhanced output format in feature branch" --quiet

echo "  リビジョン6: ブランチ上で出力形式を変更"
echo ""

echo "  --- リポジトリの構造 ---"
svn list -R "file://${WORKDIR}/myrepo" | head -20
echo ""

echo "  --- trunkのapp.c（変更されていない）---"
cat trunk/app.c
echo ""

echo "  --- ブランチのapp.c（変更済み）---"
cat branches/feature-new-output/app.c
echo ""

echo "  -> ブランチでの変更はtrunkに影響しない"
echo "  -> cheap copy のためストレージ消費はほぼゼロ"
echo ""

# --- 演習4: リビジョン番号の力 ---
echo "[演習4] リビジョン番号の力"

echo "  --- 全リビジョンの一覧 ---"
svn log -q "file://${WORKDIR}/myrepo"
echo ""

echo "  --- リビジョン2時点のファイル内容（main.cとして存在していた）---"
svn cat -r 2 "file://${WORKDIR}/myrepo/trunk/main.c"
echo ""
echo ""

echo "  --- リビジョン2から最新までのtrunk/app.cの差分 ---"
svn diff -r 2:HEAD "file://${WORKDIR}/myrepo/trunk/app.c" 2>/dev/null || \
  echo "  (リネームのため直接の差分は取得できないが、各リビジョンを個別に参照可能)"
echo ""

echo "  -> 「リビジョン2を見てくれ」と言えば全員が同じ状態を参照できる"
echo "  -> git の a3f2e1b のようなハッシュ値と比べて人間にとって扱いやすい"
echo ""

# --- 演習5: リポジトリの内部構造を覗く ---
echo "[演習5] FSFSリポジトリの内部構造"

echo "  --- リポジトリのdb/ディレクトリ ---"
ls "${WORKDIR}/myrepo/db/"
echo ""

echo "  --- ストレージバックエンド ---"
echo "  fs-type: $(cat "${WORKDIR}/myrepo/db/fs-type")"
echo ""

echo "  --- 現在のリビジョン番号 ---"
echo "  current: $(cat "${WORKDIR}/myrepo/db/current")"
echo ""

echo "  --- リビジョンファイルの一覧 ---"
ls -la "${WORKDIR}/myrepo/db/revs/0/"
echo ""

echo "  --- リビジョン0（初期状態）の内容の先頭 ---"
head -5 "${WORKDIR}/myrepo/db/revs/0/0"
echo "  ..."
echo ""

echo "  --- リビジョン1のプロパティ（コミットメッセージ等）---"
cat "${WORKDIR}/myrepo/db/revprops/0/1"
echo ""

echo "  -> FSFSのリポジトリは通常のファイルとして保存されている"
echo "  -> Berkeley DBのような不透明なデータベースではない"
echo "  -> バックアップは単純なファイルコピーで可能"
echo ""

# --- まとめ ---
echo "=== セットアップ完了 ==="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "リポジトリ:       ${WORKDIR}/myrepo"
echo "作業コピー:       ${WORKDIR}/wc"
echo ""
echo "Subversionが「CVSを正しくやり直した」ことの要点:"
echo "  1. アトミックコミット -- 複数ファイルの変更が1つのリビジョン"
echo "  2. ディレクトリバージョニング -- 構造変更も履歴に記録"
echo "  3. リネーム追跡 -- ファイル名の変更で履歴が断絶しない"
echo "  4. cheap copy -- ブランチ/タグの作成がストレージ効率的"
echo "  5. 連番リビジョン -- 人間にとって扱いやすい識別子"
echo "  6. FSFS -- 透過的なファイル構造で管理が容易"
