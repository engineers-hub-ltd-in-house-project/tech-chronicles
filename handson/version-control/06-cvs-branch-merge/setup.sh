#!/bin/bash
# =============================================================================
# 第6回ハンズオン：CVSのブランチとマージの痛みを体感する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: cvs (apt install cvs / brew install cvs)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-06"

echo "=== 第6回ハンズオン：CVSのブランチとマージの痛みを体感する ==="
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

# リポジトリの初期化
export CVSROOT="${WORKDIR}/cvsrepo"
cvs init

echo "  -> リポジトリを初期化しました: ${CVSROOT}"
echo ""

# プロジェクトの作成とインポート
mkdir -p "${WORKDIR}/project-import/src"
cd "${WORKDIR}/project-import"

cat > src/main.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"

int main(void) {
    printf("App v%s\n", VERSION);
    return 0;
}
SRCEOF

cat > src/config.h << 'SRCEOF'
#ifndef CONFIG_H
#define CONFIG_H
#define VERSION "1.0"
#endif
SRCEOF

cat > src/utils.c << 'SRCEOF'
#include <string.h>

int string_length(const char *s) {
    return strlen(s);
}
SRCEOF

cvs import -m "Initial import" myproject vendor start 2>&1
cd "${WORKDIR}"
rm -rf project-import
cvs checkout myproject 2>&1
cd myproject

echo "  -> プロジェクトをインポートしチェックアウトしました"
echo ""

# トランクに変更を積む
sed -i 's/1.0/1.1/' src/config.h
cvs commit -m "Bump to v1.1" 2>&1 > /dev/null

sed -i 's/1.1/1.2/' src/config.h
cvs commit -m "Bump to v1.2" 2>&1 > /dev/null

echo "  -> トランクに2件の変更をコミットしました"
echo ""

# --- 演習1: ブランチの作成と番号体系の確認 ---
echo "================================================================"
echo "[演習1] ブランチの作成と番号体系の確認"
echo "================================================================"
echo ""
echo "  cvs tag -b でブランチを作成し、内部的なリビジョン番号を確認します。"
echo ""

cvs tag -b release-1 2>&1
echo ""

echo "  ブランチに切り替え:"
cvs update -r release-1 2>&1
echo ""

echo "  各ファイルのステータス（ブランチのリビジョン番号に注目）:"
echo ""

echo "  --- main.c ---"
cvs status src/main.c 2>&1 | grep -E "(Repository revision|Sticky Tag)"
echo ""

echo "  --- config.h ---"
cvs status src/config.h 2>&1 | grep -E "(Repository revision|Sticky Tag)"
echo ""

echo "  --- utils.c ---"
cvs status src/utils.c 2>&1 | grep -E "(Repository revision|Sticky Tag)"
echo ""

echo "  -> main.c と utils.c はリビジョン 1.1.1.1 からの分岐"
echo "  -> config.h はリビジョン 1.3 からの分岐"
echo "  -> 同じブランチ名でも、ファイルごとに分岐点が異なります"
echo "  -> Gitではブランチは41バイトのポインタ1つ。CVSではファイル数分の記録が必要です"
echo ""

# --- 演習2: ブランチとトランクの並行開発 ---
echo "================================================================"
echo "[演習2] ブランチとトランクの並行開発"
echo "================================================================"
echo ""

echo "  ブランチでバグ修正を行います..."
echo ""

# ブランチでバグ修正
cat > src/main.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"

int main(void) {
    printf("App v%s\n", VERSION);
    printf("(stable release)\n");
    return 0;
}
SRCEOF
cvs commit -m "[release-1] Add stable release indicator" 2>&1

cat > src/utils.c << 'SRCEOF'
#include <string.h>

int string_length(const char *s) {
    if (s == NULL) return 0;  /* Bug fix: NULL check */
    return strlen(s);
}
SRCEOF
cvs commit -m "[release-1] Fix NULL pointer bug in string_length" 2>&1
echo ""

echo "  -> ブランチに2件のバグ修正をコミットしました"
echo ""

# トランクに戻る
echo "  トランクに戻って新機能開発を行います..."
cvs update -A 2>&1
echo ""

cat > src/main.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"
#include "utils.h"

int main(void) {
    printf("App v%s\n", VERSION);
    printf("String length: %d\n", string_length("hello"));
    return 0;
}
SRCEOF

cat > src/utils.h << 'SRCEOF'
#ifndef UTILS_H
#define UTILS_H
int string_length(const char *s);
#endif
SRCEOF
cvs add src/utils.h 2>&1

sed -i 's/1.2/2.0/' src/config.h
cvs commit -m "Start v2.0 development" 2>&1
echo ""

echo "  -> トランクに新機能をコミットしました"
echo "  -> トランク: v2.0開発中（main.c に新機能追加、utils.h 追加）"
echo "  -> ブランチ: v1.2のバグ修正（NULLチェック追加 等）"
echo ""

# --- 演習3: 最初のマージ ---
echo "================================================================"
echo "[演習3] 最初のマージ——コンフリクトとの遭遇"
echo "================================================================"
echo ""

echo "  ブランチの変更をトランクにマージします:"
echo "  cvs update -j release-1"
echo ""

echo "  --- マージ実行 ---"
cvs update -j release-1 2>&1 || true
echo ""

echo "  --- コンフリクトの確認 ---"
if grep -rl "<<<<<<" src/ 2>/dev/null; then
    echo ""
    echo "  コンフリクトが発生しました。main.c の内容を確認します:"
    echo ""
    cat src/main.c
    echo ""
    echo "  -> トランクとブランチの両方で main.c を変更したため衝突しています"
    echo "  -> コンフリクトマーカー（<<<<<<< / ======= / >>>>>>>）が挿入されています"
else
    echo "  コンフリクトなし（変更箇所が重なっていない場合）"
fi
echo ""

echo "  コンフリクトを手動で解消します..."
cat > src/main.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"
#include "utils.h"

int main(void) {
    printf("App v%s\n", VERSION);
    printf("(stable release)\n");
    printf("String length: %d\n", string_length("hello"));
    return 0;
}
SRCEOF

cvs commit -m "Merge release-1 to trunk (first merge)" 2>&1
echo ""
echo "  -> 最初のマージが完了しました"
echo ""

# --- 演習4: 二度目のマージ ---
echo "================================================================"
echo "[演習4] 二度目のマージ——マージ追跡不在の恐怖"
echo "================================================================"
echo ""
echo "  最初のマージ後、ブランチでさらに修正を加えます..."
echo ""

# ブランチに切り替えて追加修正
cvs update -r release-1 2>&1

cat > src/utils.c << 'SRCEOF'
#include <string.h>

int string_length(const char *s) {
    if (s == NULL) return 0;
    return (int)strlen(s);  /* Add explicit cast */
}
SRCEOF
cvs commit -m "[release-1] Add explicit cast in string_length" 2>&1
echo ""

echo "  -> ブランチに追加修正をコミットしました"
echo ""

# トランクに戻る
cvs update -A 2>&1

echo "  二度目のマージを実行します（タグなし——これが問題の核心）:"
echo "  cvs update -j release-1"
echo ""

echo "  --- 二度目のマージ実行 ---"
cvs update -j release-1 2>&1 || true
echo ""

echo "  --- マージ結果の確認 ---"
if grep -rl "<<<<<<" src/ 2>/dev/null; then
    echo ""
    echo "  コンフリクトが発生しました！"
    echo "  -> 既にマージ済みの変更が再度適用されたためです"
    echo "  -> CVSはマージ履歴を記録しないので、ブランチの分岐点から"
    echo "     全変更を再度適用しようとします"
else
    echo "  （環境によってはコンフリクトにならず、二重適用が静かに行われる場合もあります）"
fi
echo ""

echo "  utils.c の内容を確認:"
cat src/utils.c
echo ""
echo "  main.c の内容を確認:"
cat src/main.c
echo ""

echo "  -> 最初のマージで既に取り込んだ変更が再度マージ対象になっています"
echo "  -> CVSはブランチの分岐点から全変更を再適用するためです"
echo ""

# 正しい方法の説明
echo "  === 正しい方法: マージ後にタグを打つ ==="
echo ""
echo "  CVSでの正しいマージ運用:"
echo "    1. マージ実行: cvs update -j release-1"
echo "    2. マージ後にタグ: cvs tag -r release-1 merged-round1"
echo "    3. 二度目のマージ: cvs update -j merged-round1 -j release-1"
echo "       (前回のマージポイントから現在までの差分だけを適用)"
echo ""
echo "  この運用規律を全員が毎回守る必要がありました。"
echo "  一人でもタグ付けを忘れると、次回のマージが破綻します。"
echo ""

# 一旦リセット
cvs update -A -C 2>&1 > /dev/null

# --- 演習5: stickyタグの混乱 ---
echo "================================================================"
echo "[演習5] stickyタグの混乱"
echo "================================================================"
echo ""

# リリースタグを打つ（ブランチではなく固定タグ）
cvs tag release-1.2.1 2>&1
echo ""

echo "  リリースタグ release-1.2.1 を作成しました（固定タグ、ブランチではない）"
echo ""

echo "  そのタグに update します:"
cvs update -r release-1.2.1 2>&1
echo ""

echo "  stickyタグの状態を確認:"
cvs status src/utils.c 2>&1 | grep -E "(Status|Sticky Tag)"
echo ""

echo "  ファイルを変更してコミットを試みます..."
echo "// test" >> src/utils.c
echo ""
echo "  --- コミット試行 ---"
cvs commit -m "Test commit on sticky tag" 2>&1 || true
echo ""

echo "  -> 非ブランチタグにstickyが設定されているため、コミットが拒否されました"
echo "  -> 'sticky tag ... is not a branch' はCVS利用者なら誰もが見たエラーです"
echo ""

echo "  stickyタグを解除してトランクに戻ります:"
cvs update -A 2>&1
echo ""
cvs status src/utils.c 2>&1 | grep -E "(Status|Sticky Tag)"
echo ""

echo "  -> cvs update -A でstickyタグが解除され、トランクのHEADに戻りました"
echo ""

# --- まとめ ---
echo "================================================================"
echo "=== CVSのブランチとマージの問題 まとめ ==="
echo "================================================================"
echo ""
echo "  1. ブランチ番号体系"
echo "     -> ファイルごとに異なるリビジョン番号でブランチが管理される"
echo "     -> Gitの41バイトポインタと比べ、作成コストがファイル数に比例する"
echo ""
echo "  2. マージ追跡の不在"
echo "     -> マージ履歴を記録しないため、二度目のマージで二重適用が発生する"
echo "     -> マージのたびにタグを打つ運用規律が必須だった"
echo ""
echo "  3. stickyタグの混乱"
echo "     -> 非ブランチタグでコミット不能、ブランチの暗黙的固定"
echo "     -> 意図しないブランチへのコミットのリスク"
echo ""
echo "  これらの問題が「ブランチは怖い」という文化を生みました。"
echo "  Gitのブランチが「安い」ことの本当の意味は、"
echo "  CVSのブランチが「高い」ことを知って初めて理解できます。"
echo ""

echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
