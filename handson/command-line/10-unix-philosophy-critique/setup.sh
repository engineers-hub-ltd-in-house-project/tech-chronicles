#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/command-line-handson-10"

echo "=============================================="
echo " 第10回ハンズオン: UNIX哲学の功罪"
echo " 「一つのことをうまくやれ」は本当に正しいか"
echo "=============================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ==============================================
# 演習1: テキストパイプラインの限界を体験する
# ==============================================

echo ""
echo "=============================================="
echo "[演習1] テキストパイプラインの限界を体験する"
echo "=============================================="
echo ""

# テスト用ファイルの作成（スペースを含むファイル名）
mkdir -p "${WORKDIR}/test-files"
echo "Hello World" > "${WORKDIR}/test-files/my document.txt"
echo "Test" > "${WORKDIR}/test-files/normal.txt"
echo "Long content here for testing purposes" > "${WORKDIR}/test-files/another file with spaces.txt"
echo "Short" > "${WORKDIR}/test-files/brief.txt"
dd if=/dev/zero of="${WORKDIR}/test-files/binary data file.bin" bs=1024 count=10 2>/dev/null

echo "--- テスト用ファイルを作成 ---"
ls -la "${WORKDIR}/test-files/"
echo ""

echo "--- ls -l | awk でファイルサイズとファイル名を取得 ---"
echo ""
ls -l "${WORKDIR}/test-files/" | awk 'NR>1 {print $5, $9}'
echo ""
echo "→ 注目: スペースを含むファイル名が分割されている"
echo "  'my document.txt' が 'my' になり、'document.txt' が消失"
echo "  'another file with spaces.txt' が 'another' だけになる"
echo "  これがテキストパイプラインの構造的脆弱性"
echo ""

echo "--- 対策: stat コマンドで構造化出力 ---"
echo ""
for f in "${WORKDIR}/test-files/"*; do
    stat --format='%s %n' "$f"
done
echo ""
echo "→ statは引用符付きファイル名を正しく扱える"
echo "  だが、for文とクオートが必要になり、パイプラインの簡潔さが失われる"

# ==============================================
# 演習2: JSONログをsed/awk vs jqで処理する
# ==============================================

echo ""
echo "=============================================="
echo "[演習2] JSONログの処理: sed/awk vs jq"
echo "=============================================="
echo ""

# JSONログデータの生成
cat > "${WORKDIR}/access.json" << 'JSONEOF'
{"timestamp":"2026-02-20T10:00:00Z","method":"GET","path":"/api/users","status":200,"duration_ms":45}
{"timestamp":"2026-02-20T10:00:01Z","method":"POST","path":"/api/users","status":201,"duration_ms":120}
{"timestamp":"2026-02-20T10:00:02Z","method":"GET","path":"/api/users/1","status":200,"duration_ms":30}
{"timestamp":"2026-02-20T10:00:03Z","method":"GET","path":"/api/products","status":500,"duration_ms":5000}
{"timestamp":"2026-02-20T10:00:04Z","method":"DELETE","path":"/api/users/2","status":404,"duration_ms":15}
{"timestamp":"2026-02-20T10:00:05Z","method":"GET","path":"/api/users","status":200,"duration_ms":55}
{"timestamp":"2026-02-20T10:00:06Z","method":"PUT","path":"/api/users/1","status":200,"duration_ms":80}
{"timestamp":"2026-02-20T10:00:07Z","method":"GET","path":"/api/products","status":500,"duration_ms":4500}
{"timestamp":"2026-02-20T10:00:08Z","method":"GET","path":"/api/health","status":200,"duration_ms":5}
{"timestamp":"2026-02-20T10:00:09Z","method":"POST","path":"/api/orders","status":201,"duration_ms":250}
JSONEOF

echo "サンプルJSONログ（先頭3行）:"
head -3 "${WORKDIR}/access.json"
echo "..."
echo ""

echo "--- (A) grep/sed によるテキスト処理 ---"
echo "タスク: ステータス500のリクエストのパスを抽出し集計する"
echo ""
echo "コマンド: grep '\"status\":500' | sed 's/.*\"path\":\"\\([^\"]*\\)\".*/\\1/' | sort | uniq -c"
grep '"status":500' "${WORKDIR}/access.json" | \
    sed 's/.*"path":"\([^"]*\)".*/\1/' | \
    sort | uniq -c | sort -rn
echo ""
echo "→ 正規表現でJSONのフィールドを抽出している"
echo "  JSONフィールドの順序が変わると壊れる可能性がある"
echo "  \"status\":500 はテキストマッチであり、型を考慮していない"
echo ""

# jqのインストール
echo "--- jq をインストール ---"
apt-get update -qq > /dev/null 2>&1 && apt-get install -y -qq jq > /dev/null 2>&1
echo "jq version: $(jq --version)"
echo ""

echo "--- (B) jq による構造化処理 ---"
echo "コマンド: jq -r 'select(.status == 500) | .path' | sort | uniq -c"
jq -r 'select(.status == 500) | .path' "${WORKDIR}/access.json" | \
    sort | uniq -c | sort -rn
echo ""
echo "→ .status == 500 は数値比較（型安全）"
echo "  .path はキー名による直接アクセス"
echo "  フィールドの出現順序に依存しない"
echo ""

echo "--- フィールド順序が変わった場合のテスト ---"
# フィールド順序を変えたJSONを生成
cat > "${WORKDIR}/access-reordered.json" << 'JSONEOF'
{"status":500,"path":"/api/products","method":"GET","timestamp":"2026-02-20T10:00:03Z","duration_ms":5000}
{"path":"/api/products","duration_ms":4500,"status":500,"timestamp":"2026-02-20T10:00:07Z","method":"GET"}
JSONEOF

echo "フィールド順序を変えたJSON:"
cat "${WORKDIR}/access-reordered.json"
echo ""

echo "(A) grep/sed での抽出（フィールド順序変更後）:"
grep '"status":500' "${WORKDIR}/access-reordered.json" | \
    sed 's/.*"path":"\([^"]*\)".*/\1/' || echo "  抽出失敗またはフィールド順序に依存した不正確な結果"
echo ""

echo "(B) jq での抽出（フィールド順序変更後）:"
jq -r 'select(.status == 500) | .path' "${WORKDIR}/access-reordered.json"
echo ""
echo "→ jq はフィールド順序に関係なく正しく抽出できる"

# ==============================================
# 演習3: パイプラインのエラー処理を検証する
# ==============================================

echo ""
echo "=============================================="
echo "[演習3] パイプラインのエラー処理を検証する"
echo "=============================================="
echo ""

# pipefailを一時的に無効化して演習を実行
set +o pipefail

echo "(1) デフォルト動作（pipefail なし）:"
echo "コマンド: cat /nonexistent 2>/dev/null | grep pattern | wc -l"
cat /nonexistent/file 2>/dev/null | grep "pattern" | wc -l || true
echo "終了コード: ${PIPESTATUS[*]}"
echo "→ 最後のコマンド (wc -l) が成功するため、パイプライン全体は成功扱い"
echo "  catの失敗は完全に無視される"
echo ""

echo "(2) set -o pipefail 有効時:"
set -o pipefail
cat /nonexistent/file 2>/dev/null | grep "pattern" | wc -l || true
echo "PIPESTATUS: ${PIPESTATUS[*]}"
set +o pipefail
echo "→ パイプライン中の失敗が検出され、ゼロ以外の終了コードが返る"
echo "  ただし、どのコマンドが失敗したかはPIPESTATUS配列でしか確認できない"
echo ""

echo "(3) パイプライン途中のデータ欠損:"
echo "コマンド: echo -e 'apple\\nbanana\\ncherry' | grep 'NOMATCH' | wc -l"
echo -e 'apple\nbanana\ncherry' | grep 'NOMATCH' | wc -l || true
echo "PIPESTATUS: ${PIPESTATUS[*]}"
echo "→ grep がマッチしない場合、終了コード 1 を返す"
echo "  これは「エラー」なのか「結果が0件」なのか、終了コードだけでは区別できない"
echo ""

echo "--- まとめ ---"
echo "  パイプラインのエラー処理はUNIXの構造的弱点"
echo "  テキストストリームにエラー情報を含める仕組みがない"
echo "  stderr と終了コードという「帯域外通信」に頼るしかない"

# pipefailを再度有効化
set -o pipefail

# ==============================================
# 演習4: jqの高度なパイプライン
# ==============================================

echo ""
echo "=============================================="
echo "[演習4] jqの高度なパイプライン"
echo "  ――構造化データの組み合わせ"
echo "=============================================="
echo ""

echo "--- エンドポイント別のリクエスト統計 ---"
echo ""
echo "コマンド:"
echo '  jq -s '\''group_by(.path) | map({path: .[0].path, count: length, ...})'\'''
echo ""
jq -s '
  group_by(.path) |
  map({
    path: .[0].path,
    count: length,
    avg_duration_ms: (map(.duration_ms) | add / length | . * 100 | round / 100),
    error_count: (map(select(.status >= 400)) | length)
  }) |
  sort_by(.avg_duration_ms) |
  reverse
' "${WORKDIR}/access.json"

echo ""
echo "→ group_by でエンドポイント別にグループ化"
echo "  map でリクエスト数、平均応答時間、エラー数を集計"
echo "  sort_by で応答時間の遅い順にソート"
echo "  結果はJSON形式――さらにパイプラインで加工可能"
echo ""

echo "--- HTTPメソッド別の集計 ---"
echo ""
jq -s '
  group_by(.method) |
  map({
    method: .[0].method,
    count: length,
    status_codes: (map(.status) | group_by(.) | map({code: .[0], count: length}))
  })
' "${WORKDIR}/access.json"

echo ""
echo "→ ネストされた構造（status_codesの配列）も自然に扱える"
echo "  テキストパイプライン（sed/awk）では極めて困難な処理"

echo ""
echo "=============================================="
echo " 全演習完了"
echo "=============================================="
echo ""
echo "この演習で確認したこと:"
echo "  1. テキストパイプラインはスペースを含むファイル名で破綻する"
echo "  2. sed/awkによるJSON処理は正規表現に依存し、フォーマット変更に脆弱"
echo "  3. パイプラインのエラー処理はデフォルトで途中のエラーを無視する"
echo "  4. jqは構造化データを型安全に処理し、複雑な集計も可読性が高い"
echo ""
echo "UNIX哲学は偉大だが万能ではない。テキストストリームの限界を知ることが、"
echo "次の進化を理解する鍵である。"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
