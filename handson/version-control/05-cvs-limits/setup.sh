#!/bin/bash
# =============================================================================
# 第5回ハンズオン：CVSの弱点を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: cvs (apt install cvs / brew install cvs)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-05"

echo "=== 第5回ハンズオン：CVSの弱点を体験する ==="
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
    printf("Version: %s\n", VERSION);
    return 0;
}
SRCEOF

cat > src/config.h << 'SRCEOF'
#ifndef CONFIG_H
#define CONFIG_H
#define VERSION "1.0"
#endif
SRCEOF

cvs import -m "Initial import" myproject vendor start 2>&1
cd "${WORKDIR}"
rm -rf project-import
cvs checkout myproject 2>&1
cd myproject

echo "  -> プロジェクトをインポートしチェックアウトしました"
echo ""

# --- 演習1: アトミックコミットの不在 ---
echo "================================================================"
echo "[演習1] アトミックコミットの不在"
echo "================================================================"
echo ""
echo "  二つのファイルを論理的に関連する形で変更し、同時にコミットします。"
echo "  CVSが各ファイルを個別に処理することを確認します。"
echo ""

cat > src/config.h << 'SRCEOF'
#ifndef CONFIG_H
#define CONFIG_H
#define VERSION "2.0"
#define NEW_FEATURE 1
#endif
SRCEOF

cat > src/main.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"

int main(void) {
    printf("Version: %s\n", VERSION);
#if NEW_FEATURE
    printf("New feature enabled!\n");
#endif
    return 0;
}
SRCEOF

echo "  変更内容:"
echo "    - config.h: VERSION を 2.0 に、NEW_FEATURE を追加"
echo "    - main.c: NEW_FEATURE を参照するコードを追加"
echo ""

echo "  cvs commit の出力:"
cvs commit -m "Bump version to 2.0 and add new feature" 2>&1
echo ""

echo "  -> 各ファイルが個別に処理されています"
echo "  -> CVSには「この二つの変更は同じ論理的変更の一部」という記録がありません"
echo ""

echo "  config.h の履歴:"
cvs log src/config.h 2>&1 | grep -E "^(revision|date)" | head -4
echo ""

echo "  main.c の履歴:"
cvs log src/main.c 2>&1 | grep -E "^(revision|date)" | head -4
echo ""

echo "  -> リビジョン番号はファイルごとに独立しています"
echo "  -> gitでは一つのコミットハッシュが複数ファイルの変更をまとめますが、"
echo "     CVSにはその仕組みがありません"
echo ""

# --- 演習2: ディレクトリの削除不能 ---
echo "================================================================"
echo "[演習2] ディレクトリの削除不能"
echo "================================================================"
echo ""

mkdir -p src/experimental
cat > src/experimental/test.c << 'SRCEOF'
#include <stdio.h>
void test_func(void) {
    printf("This is experimental.\n");
}
SRCEOF

cvs add src/experimental 2>&1
cvs add src/experimental/test.c 2>&1
cvs commit -m "Add experimental module" 2>&1
echo ""

echo "  experimental ディレクトリとファイルを追加しました。"
echo "  次に、このモジュールを削除します。"
echo ""

cvs remove -f src/experimental/test.c 2>&1
cvs commit -m "Remove experimental module" 2>&1
echo ""

echo "  ファイルを削除しましたが、ディレクトリは残っています:"
echo ""
echo "  作業コピーの状態:"
ls -la src/experimental/ 2>/dev/null || echo "    (作業コピーからは削除済み)"
echo ""

echo "  リポジトリ内部の状態:"
echo "    src/experimental/ ディレクトリ:"
ls "${CVSROOT}/myproject/src/experimental/" 2>/dev/null || true
echo ""
echo "    Attic/ ディレクトリ（削除されたファイルの保管場所）:"
ls "${CVSROOT}/myproject/src/experimental/Attic/" 2>/dev/null || true
echo ""

echo "  -> ファイルは Attic/ に移動しましたが、ディレクトリは残り続けます"
echo "  -> CVSにはディレクトリを削除する仕組みが存在しません"
echo ""

echo "  -P フラグで空ディレクトリを非表示にする（運用上の回避策）:"
cd "${WORKDIR}"
rm -rf myproject
cvs checkout -P myproject 2>&1 > /dev/null
echo "    cvs checkout -P 後の src/ ディレクトリ:"
ls myproject/src/
echo ""
echo "  -> -P により空の experimental/ は表示されませんが、リポジトリにはまだ存在します"
echo ""

cd "${WORKDIR}/myproject"

# --- 演習3: リネームと履歴の断絶 ---
echo "================================================================"
echo "[演習3] リネームと履歴の断絶"
echo "================================================================"
echo ""

# 履歴を積む
cat > src/config.h << 'SRCEOF'
#ifndef CONFIG_H
#define CONFIG_H
#define VERSION "2.1"
#define NEW_FEATURE 1
#define APP_NAME "MyApp"
#endif
SRCEOF
cvs commit -m "Add APP_NAME constant" 2>&1 > /dev/null

cat > src/config.h << 'SRCEOF'
#ifndef CONFIG_H
#define CONFIG_H
#define VERSION "2.2"
#define NEW_FEATURE 1
#define APP_NAME "MyApp"
#define MAX_CONNECTIONS 100
#endif
SRCEOF
cvs commit -m "Add MAX_CONNECTIONS constant" 2>&1 > /dev/null

echo "  config.h に3回の変更履歴を作成しました。"
echo ""
echo "  リネーム前の config.h の履歴:"
cvs log src/config.h 2>&1 | grep -E "^(revision|date|---)" | head -12
echo ""

# リネームを実行
cvs remove -f src/config.h 2>&1 > /dev/null

cat > src/settings.h << 'SRCEOF'
#ifndef SETTINGS_H
#define SETTINGS_H
#define VERSION "2.2"
#define NEW_FEATURE 1
#define APP_NAME "MyApp"
#define MAX_CONNECTIONS 100
#endif
SRCEOF

cvs add src/settings.h 2>&1 > /dev/null
cvs commit -m "Rename config.h to settings.h" 2>&1
echo ""

echo "  リネーム後の settings.h の履歴:"
cvs log src/settings.h 2>&1 | grep -E "^(revision|date|---)" | head -8
echo ""

echo "  -> settings.h はリビジョン 1.1 から始まっています"
echo "  -> config.h 時代の履歴（1.1〜1.4）は完全に切断されました"
echo "  -> gitでは git log --follow でリネーム前の履歴を追跡できますが、"
echo "     CVSにはその機能がありません"
echo ""

# --- 演習4: バイナリファイルの破損 ---
echo "================================================================"
echo "[演習4] バイナリファイルの破損（キーワード展開）"
echo "================================================================"
echo ""

# $Id$ を含むバイナリデータを作成
printf 'BINARY\x00DATA\x00$Id$\x00END' > src/data.bin
ORIGINAL_MD5=$(md5sum src/data.bin 2>/dev/null | cut -d' ' -f1 || md5 -q src/data.bin 2>/dev/null || echo "N/A")
echo "  元のバイナリファイル（\$Id\$ を含む）:"
echo "    MD5: ${ORIGINAL_MD5}"
xxd src/data.bin 2>/dev/null | head -3 || od -A x -t x1z src/data.bin | head -3
echo ""

# テキストモード（デフォルト）で追加
cvs add src/data.bin 2>&1
cvs commit -m "Add binary file without -kb" 2>&1
echo ""

# チェックアウトし直して確認
cd "${WORKDIR}"
rm -rf myproject
cvs checkout -P myproject 2>&1 > /dev/null
cd myproject

EXPANDED_MD5=$(md5sum src/data.bin 2>/dev/null | cut -d' ' -f1 || md5 -q src/data.bin 2>/dev/null || echo "N/A")
echo "  キーワード展開後のバイナリファイル:"
echo "    MD5: ${EXPANDED_MD5}"
xxd src/data.bin 2>/dev/null | head -3 || od -A x -t x1z src/data.bin | head -3
echo ""

if [ "${ORIGINAL_MD5}" != "${EXPANDED_MD5}" ]; then
    echo "  -> ファイルが破損しました。\$Id\$ が展開されてデータが変わっています"
else
    echo "  -> (環境によっては展開が確認しづらい場合があります)"
fi
echo ""

# 正しい方法で管理し直す
cvs remove -f src/data.bin 2>&1 > /dev/null
cvs commit -m "Remove incorrectly added binary" 2>&1 > /dev/null

printf 'BINARY\x00DATA\x00$Id$\x00END' > src/data.bin
cvs add -kb src/data.bin 2>&1
cvs commit -m "Add binary file with -kb" 2>&1
echo ""

cd "${WORKDIR}"
rm -rf myproject
cvs checkout -P myproject 2>&1 > /dev/null
cd myproject

CORRECT_MD5=$(md5sum src/data.bin 2>/dev/null | cut -d' ' -f1 || md5 -q src/data.bin 2>/dev/null || echo "N/A")
echo "  -kb オプション使用後のバイナリファイル:"
echo "    MD5: ${CORRECT_MD5}"
xxd src/data.bin 2>/dev/null | head -3 || od -A x -t x1z src/data.bin | head -3
echo ""
echo "  -> -kb を指定することでキーワード展開と行末変換が抑制されます"
echo "  -> ただし、この指定はファイルごとに明示的に行う必要があります"
echo ""

# --- まとめ ---
echo "================================================================"
echo "=== CVSの四大構造的弱点 まとめ ==="
echo "================================================================"
echo ""
echo "  1. アトミックコミットの不在"
echo "     -> 複数ファイルの変更が一つの不可分な単位として記録されない"
echo "     -> コミット途中の中断でリポジトリが不整合になる危険がある"
echo ""
echo "  2. ディレクトリのバージョン管理不可"
echo "     -> ディレクトリの追加・削除・リネームをバージョン管理できない"
echo "     -> 削除したディレクトリもリポジトリに残り続ける"
echo ""
echo "  3. リネーム（ファイル移動）の非対応"
echo "     -> ファイルをリネームすると変更履歴の連続性が断たれる"
echo "     -> リファクタリングでファイル名を変えるたびに履歴が失われる"
echo ""
echo "  4. バイナリファイルの扱い"
echo "     -> デフォルトでテキスト前提の処理が行われ、バイナリが破損する"
echo "     -> -kb オプションの指定漏れが深刻なデータ損失を引き起こす"
echo ""
echo "  これらはすべて、CVSがRCSのラッパーとして生まれた設計に起因します。"
echo ""

echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
