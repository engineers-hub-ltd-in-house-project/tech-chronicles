#!/bin/bash
# =============================================================================
# 第2回ハンズオン：diffの内部を体験し、限界を知る
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: diff, patch (通常プリインストール済み)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-02"

echo "=== 第2回ハンズオン：diffの内部を体験し、限界を知る ==="
echo ""

# 作業ディレクトリの作成
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- 演習1: LCSの手作業トレース ---
echo "[演習1] LCSの手作業トレース"
echo ""

# テスト用ファイルを作成
printf 'A\nB\nC\nD\nE\nF\n' > text_a.txt
printf 'A\nC\nB\nD\nE\nG\n' > text_b.txt

echo "テキストA: A B C D E F"
echo "テキストB: A C B D E G"
echo ""
echo "LCSのDP表:"
echo ""
echo '        ""  A  C  B  D  E  G'
echo '  ""     0  0  0  0  0  0  0'
echo '  A      0  1  1  1  1  1  1'
echo '  B      0  1  1  2  2  2  2'
echo '  C      0  1  2  2  2  2  2'
echo '  D      0  1  2  2  3  3  3'
echo '  E      0  1  2  2  3  4  4'
echo '  F      0  1  2  2  3  4  4'
echo ""
echo "LCS長: 4 (A, B, D, E)"
echo ""
echo "diffの出力:"
diff text_a.txt text_b.txt || true
echo ""
echo "  -> diffはLCSに含まれない行を「変更」として報告します"
echo ""

# --- 演習2: diff出力フォーマット比較 ---
echo "[演習2] diff出力フォーマットの比較"
echo ""

cat > original.c << 'EOF'
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
EOF

cat > modified.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <name>\n", argv[0]);
        return 1;
    }
    printf("Hello, %s!\n", argv[1]);
    return 0;
}
EOF

echo "=== Normal Diff ==="
diff original.c modified.c || true
echo ""

echo "=== Context Diff (-c) ==="
diff -c original.c modified.c || true
echo ""

echo "=== Unified Diff (-u) ==="
diff -u original.c modified.c || true
echo ""
echo "  -> 同じ差分を3つの形式で比較。gitはunified形式を採用しています"
echo ""

# --- 演習3: tarball + diff/patch の破綻体験 ---
echo "[演習3] tarball + diff/patch の破綻体験"
echo ""

# v1: プロジェクトの初期バージョン
mkdir -p project/src project/docs
cat > project/src/main.c << 'EOF'
#include <stdio.h>
#include "utils.h"

int main() {
    greet("World");
    return 0;
}
EOF

cat > project/src/utils.h << 'EOF'
#ifndef UTILS_H
#define UTILS_H
void greet(const char *name);
#endif
EOF

cat > project/src/utils.c << 'EOF'
#include <stdio.h>
#include "utils.h"

void greet(const char *name) {
    printf("Hello, %s!\n", name);
}
EOF

cat > project/docs/README.txt << 'EOF'
My Project v1
A simple greeting program.
EOF

tar czf project_v1.tar.gz project/
echo "  v1 tarball作成完了"

# v2: ファイルのリネーム + 変更 + 新規追加
mv project/src/utils.c project/src/helpers.c
mv project/src/utils.h project/src/helpers.h

cat > project/src/main.c << 'EOF'
#include <stdio.h>
#include "helpers.h"

int main(int argc, char *argv[]) {
    const char *name = (argc > 1) ? argv[1] : "World";
    greet(name);
    return 0;
}
EOF

cat > project/src/helpers.h << 'EOF'
#ifndef HELPERS_H
#define HELPERS_H
void greet(const char *name);
void farewell(const char *name);
#endif
EOF

cat > project/src/helpers.c << 'EOF'
#include <stdio.h>
#include "helpers.h"

void greet(const char *name) {
    printf("Hello, %s!\n", name);
}

void farewell(const char *name) {
    printf("Goodbye, %s!\n", name);
}
EOF

cat > project/src/config.h << 'EOF'
#ifndef CONFIG_H
#define CONFIG_H
#define VERSION "2.0"
#endif
EOF

cat > project/docs/README.txt << 'EOF'
My Project v2
A greeting program with farewell support.
Now accepts command-line arguments.
EOF

tar czf project_v2.tar.gz project/
echo "  v2 tarball作成完了"

# tarball を展開して差分を取得
mkdir -p v1_extracted v2_extracted
cd v1_extracted && tar xzf ../project_v1.tar.gz && cd ..
cd v2_extracted && tar xzf ../project_v2.tar.gz && cd ..

echo ""
echo "=== v1 -> v2 の差分 ==="
diff -ruN v1_extracted/project/ v2_extracted/project/ || true
echo ""
echo "  -> 注目: utils.c/utils.h が「削除」、helpers.c/helpers.h が「新規追加」として"
echo "     報告されます。diffは「リネーム」を検出できません。"
echo ""

# --- 演習4: fuzz factorとrejectの体験 ---
echo "[演習4] patchのfuzz factorとreject"
echo ""

cd "${WORKDIR}"

# ベースファイル
cat > base.txt << 'EOF'
line 1: header
line 2: introduction
line 3: first paragraph
line 4: second paragraph
line 5: conclusion
line 6: footer
EOF

# 変更版
cat > changed.txt << 'EOF'
line 1: header
line 2: introduction
line 3: first paragraph (revised)
line 4: second paragraph
line 5: conclusion
line 6: footer
EOF

diff -u base.txt changed.txt > revision.patch || true

# ベースファイルが少し変わっている場合
cat > base_modified.txt << 'EOF'
line 0: new preface
line 1: header
line 2: introduction
line 3: first paragraph
line 4: second paragraph
line 5: conclusion
line 6: footer
EOF

echo "=== パッチの内容 ==="
cat revision.patch
echo ""

echo "=== 修正済みベースにパッチ適用（fuzz動作） ==="
cp base_modified.txt target.txt
patch target.txt < revision.patch || true
echo ""
echo "=== 適用結果 ==="
cat target.txt
echo ""
echo "  -> 行番号がずれていても、patchはfuzz factorにより"
echo "     文脈を手がかりに正しい適用箇所を特定します"
echo ""

echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ディレクトリ構成:"
ls -1 "${WORKDIR}/"
