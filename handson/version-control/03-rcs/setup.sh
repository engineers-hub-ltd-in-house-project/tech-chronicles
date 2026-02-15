#!/bin/bash
# =============================================================================
# 第3回ハンズオン：RCSで「履歴の自動記録」を体感する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: rcs (apt install rcs / brew install rcs)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-03"

echo "=== 第3回ハンズオン：RCSで「履歴の自動記録」を体感する ==="
echo ""

# RCSがインストールされているか確認
if ! command -v ci &> /dev/null; then
    echo "エラー: RCSがインストールされていません"
    echo "  Ubuntu/Debian: sudo apt install rcs"
    echo "  macOS: brew install rcs"
    echo "  Docker: docker run -it --rm ubuntu:24.04 bash"
    echo "          apt update && apt install -y rcs"
    exit 1
fi

# 作業ディレクトリの作成
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# RCS管理ファイル用ディレクトリ
mkdir -p RCS

# --- 演習1: 最初のチェックイン ---
echo "[演習1] 最初のチェックイン"
echo ""

cat > hello.c << 'EOF'
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
EOF

echo "  作成したファイル:"
cat hello.c
echo ""

# 初期チェックイン
ci -i -t-"A simple greeting program" -m"Initial version" hello.c
echo ""
echo "  -> ci（check in）により hello.c が RCS/hello.c,v に登録されました"
echo "  -> 注目: 作業ファイル hello.c は削除されます（RCSの流儀）"
echo ""

ls -la hello.c 2>/dev/null && echo "  hello.c が存在します" || echo "  hello.c は削除されました（想定通り）"
echo ""
echo "  RCS管理ファイル:"
ls -la RCS/
echo ""

# --- 演習2: 編集サイクル（co -l / 編集 / ci -u） ---
echo "[演習2] 編集サイクル: チェックアウト -> 編集 -> チェックイン"
echo ""

# ロック付きチェックアウト
echo "  co -l hello.c（ロック付きチェックアウト）:"
co -l hello.c
echo ""

# ファイルを編集
cat > hello.c << 'EOF'
#include <stdio.h>

int main(int argc, char *argv[]) {
    const char *name = (argc > 1) ? argv[1] : "World";
    printf("Hello, %s!\n", name);
    return 0;
}
EOF

echo "  編集後のファイル:"
cat hello.c
echo ""

# 差分を確認
echo "  rcsdiff hello.c（作業ファイルと最新リビジョンの差分）:"
rcsdiff hello.c 2>&1 || true
echo ""

# チェックイン（-u: ロックなしチェックアウトを自動実行、作業ファイルが残る）
ci -u -m"Add command-line argument support" hello.c
echo ""
echo "  -> ci -u により変更がリビジョン1.2として記録されました"
echo "  -> -u オプションにより作業ファイルが読み取り専用で残ります"
echo ""

# --- もう一度編集サイクルを回す ---
co -l hello.c 2>&1
cat > hello.c << 'EOF'
#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[]) {
    const char *name = (argc > 1) ? argv[1] : "World";
    printf("Hello, %s!\n", name);
    if (strcmp(name, "World") != 0) {
        printf("Nice to meet you!\n");
    }
    return 0;
}
EOF
ci -u -m"Add personalized greeting" hello.c 2>&1
echo "  -> リビジョン1.3として記録"
echo ""

# --- 演習3: 履歴の確認（rlog） ---
echo "[演習3] 履歴の確認: rlog"
echo ""
echo "  rlog hello.c:"
echo ""
rlog hello.c
echo ""
echo "  -> 各リビジョンの日時、著者、ログメッセージ、変更行数が記録されています"
echo "  -> これが httpd.conf.bak にはなかった「メタデータの自動記録」です"
echo ""

# --- 演習4: リビジョン間の差分（rcsdiff） ---
echo "[演習4] リビジョン間の差分: rcsdiff"
echo ""

echo "=== リビジョン1.1と1.2の差分 ==="
rcsdiff -r1.1 -r1.2 hello.c 2>&1 || true
echo ""

echo "=== リビジョン1.1と最新（1.3）の差分 ==="
rcsdiff -r1.1 hello.c 2>&1 || true
echo ""

echo "  -> rcsdiff は git diff に直接対応するコマンドです"
echo ""

# --- 演習5: 過去のリビジョンを取り出す ---
echo "[演習5] 過去のリビジョンの参照"
echo ""

echo "=== リビジョン1.1の内容 ==="
co -p -r1.1 hello.c 2>&1
echo ""

echo "  -> co -p -r1.1 で初期バージョンの内容を表示"
echo "  -> -p オプションにより作業ファイルを上書きせず標準出力に表示"
echo ""

# --- 演習6: ,v ファイルの内部構造 ---
echo "[演習6] ,v ファイルの内部構造"
echo ""

echo "=== RCS/hello.c,v の内容 ==="
echo ""
cat RCS/hello.c,v
echo ""
echo ""
echo "  -> 構造の読み方:"
echo "     1. 冒頭: メタデータ（リビジョン番号、日時、著者、ログメッセージ）"
echo "     2. 最新リビジョン（1.3）のテキスト全文が @ で囲まれて格納"
echo "     3. 古いリビジョンへのリバースデルタ（d=削除, a=追加の指示）"
echo "     -> 最新版はそのままコピーで取り出せる（高速）"
echo "     -> 古い版はデルタを逆順に適用して復元する"
echo ""

# --- git との対応表 ---
echo "=== RCS と git の対応表 ==="
echo ""
echo "  RCS            git                   意味"
echo "  -----------    -------------------   ----------------"
echo "  ci             git commit            変更を記録する"
echo "  co             git checkout          ファイルを取り出す"
echo "  co -l          (git checkout -b)     編集用に取り出す"
echo "  rcsdiff        git diff              差分を表示する"
echo "  rlog           git log               履歴を表示する"
echo "  co -p -rN      git show REV:file     特定版を表示する"
echo ""

echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ディレクトリ構成:"
ls -la "${WORKDIR}/"
echo ""
echo "RCS管理ファイル:"
ls -la "${WORKDIR}/RCS/"
