#!/bin/bash
# =============================================================================
# 第4回ハンズオン：CVSサーバを立てて「リポジトリ」と「並行開発」を体感する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: cvs (apt install cvs / brew install cvs)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-04"

echo "=== 第4回ハンズオン：CVSで「リポジトリ」と「並行開発」を体感する ==="
echo ""

# CVSがインストールされているか確認
if ! command -v cvs &> /dev/null; then
    echo "エラー: CVSがインストールされていません"
    echo "  Ubuntu/Debian: sudo apt install cvs"
    echo "  macOS: brew install cvs"
    echo "  Docker: docker run -it --rm ubuntu:24.04 bash"
    echo "          apt update && apt install -y cvs"
    exit 1
fi

# 作業ディレクトリの作成
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- 演習1: リポジトリの初期化 ---
echo "[演習1] リポジトリの初期化"
echo ""

export CVSROOT="${WORKDIR}/cvsrepo"
cvs init

echo "  -> cvs init によりリポジトリが作成されました"
echo "  -> CVSROOT: ${CVSROOT}"
echo ""
echo "  リポジトリ構造:"
ls -la "${CVSROOT}/"
echo ""
echo "  CVSROOT管理ディレクトリ:"
ls "${CVSROOT}/CVSROOT/" | head -20
echo ""
echo "  -> modules,v, loginfo,v 等の管理ファイルがRCS形式で格納されています"
echo "  -> リポジトリの設定自体がバージョン管理されています"
echo ""

# --- 演習2: プロジェクトのインポート ---
echo "[演習2] プロジェクトのインポート"
echo ""

# プロジェクトディレクトリを作成
mkdir -p "${WORKDIR}/myproject-import/src"
cd "${WORKDIR}/myproject-import"

cat > src/main.c << 'SRCEOF'
#include <stdio.h>
#include "utils.h"

int main(int argc, char *argv[]) {
    const char *name = (argc > 1) ? argv[1] : "World";
    greet(name);
    return 0;
}
SRCEOF

cat > src/utils.h << 'SRCEOF'
#ifndef UTILS_H
#define UTILS_H

void greet(const char *name);

#endif
SRCEOF

cat > src/utils.c << 'SRCEOF'
#include <stdio.h>
#include "utils.h"

void greet(const char *name) {
    printf("Hello, %s!\n", name);
}
SRCEOF

cat > Makefile << 'SRCEOF'
CC = gcc
CFLAGS = -Wall -Wextra
SRC = src/main.c src/utils.c
TARGET = hello

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -Isrc -o $@ $(SRC)

clean:
	rm -f $(TARGET)
SRCEOF

echo "  作成したプロジェクト構造:"
find . -type f | sort
echo ""

# インポート
cvs import -m "Initial import of hello project" myproject vendor start 2>&1
echo ""
echo "  -> cvs import によりプロジェクト全体がリポジトリに登録されました"
echo "  -> RCSでは各ファイルを個別にci する必要がありましたが、CVSでは一括登録"
echo ""

# リポジトリ内部を確認
echo "  リポジトリ内部（RCS ,vファイル）:"
find "${CVSROOT}/myproject" -type f | sort
echo ""
echo "  -> 各ファイルがRCS形式の ,v ファイルとして格納されています"
echo "  -> CVSはRCSを内部ストレージエンジンとして利用しています"
echo ""

# --- 演習3: チェックアウト ---
echo "[演習3] チェックアウト（プロジェクト全体の取得）"
echo ""

cd "${WORKDIR}"
rm -rf myproject-import  # インポート元は不要

# チェックアウト
cvs checkout myproject 2>&1
cd myproject

echo ""
echo "  -> cvs checkout によりプロジェクト全体が取得されました"
echo ""

echo "  CVSメタデータディレクトリ:"
find . -name "CVS" -type d
echo ""

echo "  CVS/Root（リポジトリの場所）:"
cat CVS/Root
echo ""

echo "  CVS/Repository（リポジトリ内のパス）:"
cat CVS/Repository
echo ""

echo "  CVS/Entries（各ファイルのリビジョン情報）:"
cat CVS/Entries
echo ""
echo "  -> RCSではファイル単位のco、CVSではプロジェクト単位のcheckout"
echo ""

# --- 演習4: 編集とコミット（ロックなし） ---
echo "[演習4] 編集とコミット（ロックなし）"
echo ""

cat > src/utils.c << 'SRCEOF'
#include <stdio.h>
#include <string.h>
#include "utils.h"

void greet(const char *name) {
    printf("Hello, %s!\n", name);
    if (strcmp(name, "World") != 0) {
        printf("Nice to meet you!\n");
    }
}
SRCEOF

echo "  ファイルを編集しました（ロック操作は不要）"
echo ""

echo "  cvs diff src/utils.c:"
cvs diff src/utils.c 2>&1 || true
echo ""

cvs commit -m "Add personalized greeting message" src/utils.c 2>&1
echo ""
echo "  -> ロックなしで編集 -> diff -> commit のサイクルが完了"
echo "  -> RCSでは co -l（ロック取得）が必須でしたが、CVSでは不要"
echo ""

# --- 演習5: 並行編集とマージ ---
echo "[演習5] 並行編集とマージ（CVSの真骨頂）"
echo ""

# 二つ目の作業コピーを作成
cd "${WORKDIR}"
cvs checkout -d myproject-dev2 myproject 2>&1
cd myproject-dev2

echo "  二つ目の作業コピー（別の開発者を想定）を作成しました"
echo ""

# 開発者2の変更
cat > src/utils.h << 'SRCEOF'
#ifndef UTILS_H
#define UTILS_H

void greet(const char *name);
void farewell(const char *name);

#endif
SRCEOF

cat > src/utils.c << 'SRCEOF'
#include <stdio.h>
#include <string.h>
#include "utils.h"

void greet(const char *name) {
    printf("Hello, %s!\n", name);
    if (strcmp(name, "World") != 0) {
        printf("Nice to meet you!\n");
    }
}

void farewell(const char *name) {
    printf("Goodbye, %s!\n", name);
}
SRCEOF

echo "  開発者2: farewell関数を追加してコミット"
cvs commit -m "Add farewell function" 2>&1
echo ""

# 開発者1の作業コピーでupdate
cd "${WORKDIR}/myproject"
echo "  開発者1の作業コピーで cvs update を実行:"
cvs update 2>&1
echo ""
echo "  -> 開発者2の変更が自動的にマージされました"
echo "  -> RCSのファイルロック方式では、この並行編集は不可能でした"
echo ""

echo "  更新後のutils.c:"
cat src/utils.c
echo ""

# --- 演習6: 履歴の確認とタグ ---
echo "[演習6] 履歴の確認（cvs log）とタグ（cvs tag）"
echo ""

echo "=== cvs log src/utils.c ==="
cvs log src/utils.c 2>&1
echo ""

echo "  -> ファイル単位のリビジョン番号（1.1, 1.2, ...）に注目"
echo "  -> utils.c と utils.h のリビジョン番号は独立に振られます"
echo ""

# タグ付け
cvs tag milestone-1 2>&1
echo ""
echo "  -> cvs tag milestone-1 でプロジェクト全体のスナップショットを記録"
echo "  -> gitではコミットハッシュが自動的にスナップショットを識別しますが、"
echo "     CVSではファイルごとにリビジョンが異なるため、タグで束ねる必要があります"
echo ""

# --- 対応表 ---
echo "=== RCS / CVS / git の対応表 ==="
echo ""
echo "  RCS            CVS                  git                    意味"
echo "  -----------    ------------------   -------------------    ----------------"
echo "  (なし)         cvs init             git init               リポジトリ作成"
echo "  ci -i          cvs import           git add + git commit   初期登録"
echo "  co             cvs checkout         git clone              プロジェクト取得"
echo "  co -l          (不要)               (不要)                 編集用取得"
echo "  ci             cvs commit           git commit             変更を記録"
echo "  rcsdiff        cvs diff             git diff               差分を表示"
echo "  rlog           cvs log              git log                履歴を表示"
echo "  (なし)         cvs update           git pull               最新取得+マージ"
echo "  (なし)         cvs tag              git tag                タグ付け"
echo ""

echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ディレクトリ構成:"
ls -la "${WORKDIR}/"
echo ""
echo "開発者1の作業コピー: ${WORKDIR}/myproject/"
echo "開発者2の作業コピー: ${WORKDIR}/myproject-dev2/"
echo "CVSリポジトリ:       ${CVSROOT}/"
