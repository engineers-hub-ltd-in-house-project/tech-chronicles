#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-22"

echo "============================================"
echo " 第22回ハンズオン"
echo " UNIX哲学の限界――何がうまくいかなかったか"
echo "============================================"
echo ""
echo "作業ディレクトリ: $WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習1: 型なしテキストストリームの脆弱性"
echo "============================================"
echo ""

echo "--- テスト用ファイルの作成 ---"
mkdir -p "$WORKDIR/demo-files"
cd "$WORKDIR/demo-files"

# 「普通の」ファイル名
touch "report.txt" "data.csv" "README.md"

# 「特殊な」ファイル名（スペース、ダブルスペース、ハイフン含む）
touch "my report.txt"
touch "file with  double  spaces.txt"
touch -- "-dangerous-name.txt"

echo "作成したファイル:"
find . -maxdepth 1 -type f | sort
echo ""

echo "--- テキストファイルの数（naiveな方法） ---"
NAIVE_COUNT=$(ls | grep "\.txt$" | wc -l)
echo "ls | grep '.txt$' | wc -l → $NAIVE_COUNT"
echo ""

echo "--- 各ファイルの情報取得（naiveな方法） ---"
echo "ls -l | awk '{print \$5, \$9}' の結果:"
ls -l | awk '{print $5, $9}' | tail -n +2
echo ""
echo "→ 'my report.txt' のファイル名が分割されている"
echo "  スペースを含むファイル名はテキストパースで壊れる"
echo ""

echo "--- 安全な方法（NUL区切り） ---"
echo "find . -name '*.txt' -print0 | xargs -0 ls -la の結果:"
find . -name "*.txt" -print0 | xargs -0 ls -la
echo ""
echo "→ NUL区切りで正しく処理されるが、"
echo "  これはテキストストリームモデルの限界を認めたパッチだ"
echo ""

# クリーンアップ
cd "$WORKDIR"

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習2: 状態を持つ処理の困難さ"
echo "============================================"
echo ""

echo "--- テスト用JSONデータの作成 ---"
cat > "$WORKDIR/users.json" << 'JSONEOF'
[
  {"id": 1, "name": "Alice", "department_id": 10},
  {"id": 2, "name": "Bob", "department_id": 20},
  {"id": 3, "name": "Charlie", "department_id": 10},
  {"id": 4, "name": "Diana", "department_id": 30}
]
JSONEOF

cat > "$WORKDIR/departments.json" << 'JSONEOF'
[
  {"id": 10, "name": "Engineering", "budget": 500000},
  {"id": 20, "name": "Marketing", "budget": 300000}
]
JSONEOF

echo "users.json:"
cat "$WORKDIR/users.json"
echo ""
echo "departments.json:"
cat "$WORKDIR/departments.json"
echo ""

echo "--- シェルパイプラインでのJOIN試行 ---"
echo "タスク: 各ユーザに所属部署名を付加して表示する"
echo ""

# pipefailを一時無効化（jqのselect失敗を許容）
set +o pipefail
jq -r '.[] | "\(.id)\t\(.name)\t\(.department_id)"' "$WORKDIR/users.json" | \
while IFS=$'\t' read -r uid uname dept_id; do
    dept_name=$(jq -r ".[] | select(.id == $dept_id) | .name" "$WORKDIR/departments.json")
    if [ -z "$dept_name" ]; then
        dept_name="(不明)"
    fi
    echo "$uid  $uname  $dept_name"
done
set -o pipefail

echo ""
echo "問題点:"
echo "  1. whileループ内でjqを毎回起動（プロセス生成コスト）"
echo "  2. department_id=30のDianaは部署が見つからない"
echo "     → エラーハンドリングを手動で追加する必要がある"
echo "  3. パイプの中のwhileループはサブシェルで動作する"
echo "     → ループ内で設定した変数がループ外に反映されない"
echo ""

echo "--- jq単体でのJOIN（読めるか？） ---"
jq -n --slurpfile users "$WORKDIR/users.json" --slurpfile depts "$WORKDIR/departments.json" '
  [$users[0][] | . as $u |
   {id: $u.id, name: $u.name,
    department: ([$depts[0][] | select(.id == $u.department_id) | .name] | if length > 0 then .[0] else "N/A" end)}]
'
echo ""
echo "→ 動作はするが、SQLの SELECT u.name, d.name FROM users u JOIN departments d"
echo "  に比べて可読性が著しく低い"

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習3: エラーハンドリングの限界"
echo "============================================"
echo ""

echo "--- テストデータ作成 ---"
echo -e "apple\nbanana\ncherry\ndate\nelderberry" > "$WORKDIR/fruits.txt"
cat "$WORKDIR/fruits.txt"
echo ""

echo "--- パイプラインの終了コード ---"
echo ""

echo "存在するパターンの検索:"
set +o pipefail
cat "$WORKDIR/fruits.txt" | grep "banana" | sort | wc -l
echo "パイプライン終了コード: $?"
echo ""

echo "存在しないパターンの検索:"
cat "$WORKDIR/fruits.txt" | grep "fig" | sort | wc -l
echo "パイプライン終了コード: $?"
echo "→ 0（wc自体は成功しているため、grepの失敗が握りつぶされる）"
echo ""

echo "pipefail有効時:"
set -o pipefail
cat "$WORKDIR/fruits.txt" | grep "fig" | sort | wc -l || true
echo "→ grepの失敗がパイプライン全体の終了コードに反映される"
set +o pipefail
echo ""

echo "--- PIPESTATUS配列（bash拡張） ---"
cat "$WORKDIR/fruits.txt" | grep "fig" | sort | wc -l
echo "各コマンドの終了コード: ${PIPESTATUS[*]}"
echo "→ 2番目のgrepだけが失敗（コード1）"
echo "  ただしPIPESTATUSはbash固有の拡張であり、POSIX標準ではない"
echo ""

echo "--- 終了コードの曖昧さ ---"
grep "nonexistent_pattern" /etc/passwd || true
echo "終了コード: ${PIPESTATUS[0]} （パターンにマッチなし）"

grep "nonexistent_pattern" /nonexistent/file 2>/dev/null || true
echo "終了コード: ${PIPESTATUS[0]} （ファイルが存在しない）"
echo ""
echo "→ 終了コード1=マッチなし、2=ファイルエラー"
echo "  grepは区別するが、多くのコマンドは「0か非0か」しか返さない"
echo "  構造化されたエラー情報は一切伝達されない"

set -o pipefail

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習4: セキュリティモデルの粗さ"
echo "============================================"
echo ""

echo "--- 現在のセキュリティコンテキスト ---"
echo "UID: $(id -u)"
echo "GID: $(id -g)"
echo "Groups: $(id -Gn 2>/dev/null || echo '(取得不可)')"
echo ""

echo "--- ファイルパーミッションの粒度 ---"
echo "secret data" > "$WORKDIR/secret.txt"
chmod 640 "$WORKDIR/secret.txt"
ls -la "$WORKDIR/secret.txt"
echo ""

echo "制御できること:"
echo "  - 所有者(owner)の読み/書き/実行"
echo "  - グループ(group)の読み/書き/実行"
echo "  - その他(other)の読み/書き/実行"
echo ""
echo "制御できないこと:"
echo "  - 特定のユーザAには読み取り許可、ユーザBには拒否"
echo "  - プロセスに「ネットワークアクセスのみ許可」"
echo "  - プロセスに「特定のディレクトリのみアクセス許可」"
echo "  - 時間帯による条件付きアクセス制御"
echo ""

echo "--- setuidバイナリの確認 ---"
echo "システム上のsetuidバイナリ（先頭5件）:"
find /usr/bin /usr/sbin -perm -4000 -type f 2>/dev/null | head -5 || echo "(該当なし)"
echo "..."
echo "これらのプログラムに脆弱性があれば、"
echo "攻撃者はroot権限で任意のコードを実行できる"
echo ""

# -------------------------------------------------
echo ""
echo "============================================"
echo " まとめ"
echo "============================================"
echo ""
echo "UNIX哲学の限界を体験した:"
echo ""
echo "1. テキストストリームは型情報を持たず、"
echo "   スペースを含むファイル名すら安全に扱えない"
echo ""
echo "2. 構造化データのJOINのような処理は、"
echo "   パイプラインでは不自然かつ非効率になる"
echo ""
echo "3. パイプラインの終了コードは「握りつぶされ」、"
echo "   構造化されたエラー情報を伝達する手段がない"
echo ""
echo "4. uid/gidモデルの粒度は粗く、"
echo "   最小権限の原則を実現しにくい"
echo ""
echo "これらの限界は、UNIX哲学の「失敗」ではなく"
echo "「適用範囲の明確化」だ。"
echo "原則を理解した上で、限界を見極めよ。"
echo ""

# クリーンアップ
echo "--- クリーンアップ ---"
rm -rf "$WORKDIR"
echo "作業ディレクトリを削除しました: $WORKDIR"
echo ""
echo "ハンズオン完了"
