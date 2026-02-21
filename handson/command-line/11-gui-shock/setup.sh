#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/command-line-handson-11"

echo "=============================================="
echo " 第11回ハンズオン: GUIの衝撃"
echo " GUIとCLIの認知モデルを体験する"
echo "=============================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ==============================================
# 演習1: GUIが得意なこと、CLIが得意なこと
# ==============================================

echo ""
echo "=============================================="
echo "[演習1] GUIが得意なこと、CLIが得意なこと"
echo "=============================================="
echo ""

# 100個のテストファイルを生成
mkdir -p "${WORKDIR}/project"
cd "${WORKDIR}/project"
rm -f *.txt 2>/dev/null || true

for i in $(seq -w 1 100); do
    echo "Content of file ${i} - Report for Q4 2024 analysis" > "report_2024_draft_${i}.txt"
done

echo "--- 100個のテストファイルを作成 ---"
ls | head -5
echo "...（合計 $(ls | wc -l) 個）"
echo ""

echo "--- タスク: ファイル名を一括変更 ---"
echo "  'report_2024_draft_' → 'report_2025_final_'"
echo ""

echo "CLIでの操作（1コマンド）:"
echo '  for f in report_2024_draft_*.txt; do mv "$f" "${f/report_2024_draft_/report_2025_final_}"; done'
echo ""

# 実行時間を計測
SECONDS=0
for f in report_2024_draft_*.txt; do
    mv "$f" "${f/report_2024_draft_/report_2025_final_}"
done
elapsed=$SECONDS

echo "結果:"
ls | head -5
echo "...（合計 $(ls | wc -l) 個）"
echo ""
echo "所要時間: ${elapsed}秒（100個のファイルを一括リネーム）"
echo ""
echo "GUI（ファイルマネージャ）での同等操作:"
echo "  1ファイルあたり約10秒 × 100ファイル = 約16分40秒"
echo ""
echo "→ CLIの構造的優位性: テキストのパターンマッチと反復処理"
echo "  ただし、この比較はCLIに有利なタスクを選んでいる"
echo "  画像のサムネイル表示による分類など、GUIが優位なタスクもある"

# ==============================================
# 演習2: 「再現可能性」の差を体験する
# ==============================================

echo ""
echo "=============================================="
echo "[演習2] 「再現可能性」の差を体験する"
echo "=============================================="
echo ""

# テストデータの生成（ログファイル）
cd "${WORKDIR}"
rm -f server.log 2>/dev/null || true

for i in $(seq 1 100); do
    day=$(printf '%02d' $(( (i % 20) + 1 )))
    hour=$(printf '%02d' $((RANDOM % 24)))
    min=$(printf '%02d' $((RANDOM % 60)))
    sec=$(printf '%02d' $((RANDOM % 60)))
    duration=$((RANDOM % 2000))
    case $((i % 7)) in
        0) level="ERROR" ;;
        1) level="WARN" ;;
        *) level="INFO" ;;
    esac
    echo "2026-02-${day} ${hour}:${min}:${sec} [${level}] Request processed in ${duration}ms" >> server.log
done

echo "--- 生成されたログ（先頭5行）---"
head -5 server.log
echo "...（合計 $(wc -l < server.log) 行）"
echo ""

echo "--- CLIでのログ分析 ---"
echo ""
echo "コマンド: grep ERROR server.log | awk '{print \$1}' | sort | uniq -c | sort -rn"
echo ""
echo "日付別ERROR件数:"
grep "ERROR" server.log | awk '{print $1}' | sort | uniq -c | sort -rn
echo ""

total=$(wc -l < server.log)
errors=$(grep -c "ERROR" server.log || true)
echo "統計:"
echo "  総行数: ${total}"
echo "  ERROR行数: ${errors}"
echo ""

echo "→ このコマンドの特性:"
echo "  1. テキストとして記録できる"
echo "  2. 別のログファイルにそのまま適用できる"
echo "  3. スクリプトに保存してCIパイプラインに組み込める"
echo "  4. git commitでバージョン管理できる"
echo "  GUIでの手動操作にはこれらの特性がない"
echo ""

# 分析スクリプトの作成
cat > "${WORKDIR}/analyze-errors.sh" << 'SCRIPTEOF'
#!/bin/bash
set -euo pipefail

LOGFILE="${1:?使い方: $0 <logfile>}"

echo "=== エラーログ分析: ${LOGFILE} ==="
echo ""

total=$(wc -l < "$LOGFILE")
errors=$(grep -c "ERROR" "$LOGFILE" || true)
warns=$(grep -c "WARN" "$LOGFILE" || true)

echo "総行数: ${total}"
echo "ERROR: ${errors}"
echo "WARN:  ${warns}"
echo ""

echo "--- 日付別ERROR件数 ---"
grep "ERROR" "$LOGFILE" | awk '{print $1}' | sort | uniq -c | sort -rn
echo ""

echo "--- 応答時間上位5件 ---"
grep -oP '\d+(?=ms)' "$LOGFILE" | sort -rn | head -5 | while read ms; do
    echo "  ${ms}ms"
done
SCRIPTEOF
chmod +x "${WORKDIR}/analyze-errors.sh"

echo "--- 再利用可能なスクリプトとして保存 ---"
echo "ファイル: ${WORKDIR}/analyze-errors.sh"
echo ""
echo "実行結果:"
bash "${WORKDIR}/analyze-errors.sh" "${WORKDIR}/server.log"

# ==============================================
# 演習3: 「発見しやすさ」の差を体験する
# ==============================================

echo ""
echo "=============================================="
echo "[演習3] 「発見しやすさ」の差を体験する"
echo "  ――CLIの「想起」問題"
echo "=============================================="
echo ""

echo "--- CLIの「想起」（recall）問題 ---"
echo ""
echo "Q: テキストファイルの行数を数えたい"
echo ""
echo "  知っている人: wc -l filename"
echo "  知らない人:   ... （何を調べればいいかもわからない）"
echo ""
echo "GUIなら:"
echo "  テキストエディタで開く → ステータスバーに行数が表示される"
echo "  → コマンド名を知らなくても目的を達成できる"
echo ""

echo "--- --help による自己文書化 ---"
echo ""
echo "CLIツールは --help で機能を「発見」できる:"
wc --help 2>&1 | head -10
echo "..."
echo ""
echo "→ --help は「wc というコマンドの存在を知っている」前提"
echo "  GUIメニューとは異なり、存在を知らないコマンドは発見できない"
echo ""

echo "--- type / which によるコマンド確認 ---"
echo ""
echo "Q: 'sort' コマンドはどこにある？"
type sort 2>/dev/null || which sort 2>/dev/null
echo ""
echo "Q: 'find' コマンドはどこにある？"
type find 2>/dev/null || which find 2>/dev/null
echo ""
echo "→ コマンドの存在確認はできるが、これも「コマンド名を知っている」前提"

echo ""
echo "--- man -k (apropos) によるキーワード検索 ---"
echo ""
echo "CLIにも「再認」に歩み寄る仕組みがある:"
echo ""

# manデータベースの構築
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq man-db coreutils > /dev/null 2>&1
mandb -q 2>/dev/null || true

echo "コマンド: man -k 'sort'"
man -k "sort" 2>/dev/null | head -5 || echo "  （manデータベースが構築されていない場合はスキップ）"
echo ""

echo "コマンド: man -k 'search'"
man -k "search" 2>/dev/null | head -5 || echo "  （manデータベースが構築されていない場合はスキップ）"
echo ""

echo "→ man -k はキーワードでmanページを検索できる"
echo "  だが、適切なキーワードを「想起」する必要がある"
echo "  GUIの「メニューを開けば全機能が見える」とは根本的に異なる"

# ==============================================
# 演習4: 認知モデルの違いを可視化する
# ==============================================

echo ""
echo "=============================================="
echo "[演習4] 認知モデルの違いを可視化する"
echo "  ――同一タスクでのGUI/CLI操作手順"
echo "=============================================="
echo ""

echo "タスク: カレントディレクトリのうち、サイズが1KB以上のファイルを"
echo "        更新日時の新しい順に5件表示する"
echo ""

# テストファイルの準備
cd "${WORKDIR}"
mkdir -p "${WORKDIR}/testdata"
cd "${WORKDIR}/testdata"
rm -f *.bin *.txt 2>/dev/null || true

for i in $(seq 1 20); do
    size=$((RANDOM % 3000 + 100))
    dd if=/dev/urandom bs="${size}" count=1 of="data_$(printf '%02d' $i).bin" 2>/dev/null
    # 少し待って更新日時をずらす
    sleep 0.05
done

echo "--- テストファイル一覧 ---"
ls -lS *.bin | head -5
echo "...（合計 $(ls *.bin | wc -l) 個）"
echo ""

echo "--- CLIでの操作 ---"
echo ""
echo "コマンド: ls -lt *.bin | awk '\$5 >= 1024 {print \$5, \$9}' | head -5"
echo ""
echo "結果:"
ls -lt *.bin | awk 'NR>0 && $5 >= 1024 {print $5, $9}' | head -5
echo ""

echo "--- 操作の認知プロセス比較 ---"
echo ""
echo "CLI（想起ベース）:"
echo "  1. ls コマンドの存在を知っている     [想起]"
echo "  2. -lt オプションの意味を知っている   [想起]"
echo "  3. awk でフィルタリングを設計する     [想起 + 構築]"
echo "  4. head -5 でトップ5に絞る            [想起]"
echo "  → 全段階で「記憶からの検索」が必要"
echo "  → 一度書けば記録・再利用・自動化が可能"
echo ""
echo "GUI（再認ベース）:"
echo "  1. ファイルマネージャを開く          [再認: アイコンを見て選ぶ]"
echo "  2. 「詳細表示」に切り替える          [再認: メニューから選ぶ]"
echo "  3. 「更新日時」列でソートする         [再認: ヘッダをクリック]"
echo "  4. サイズを目視で確認する             [再認: 数値を見て判断]"
echo "  5. 上位5件を覚えておく               [記憶]"
echo "  → ほぼ全段階で「見て選ぶ」だけで操作可能"
echo "  → 操作手順の記録・自動化は困難"

echo ""
echo "=============================================="
echo " 全演習完了"
echo "=============================================="
echo ""
echo "この演習で確認したこと:"
echo "  1. CLIは一括処理・パターンマッチ・反復タスクに構造的に強い"
echo "  2. CLIの操作はテキストとして記録・再利用・自動化できる（再現可能性）"
echo "  3. CLIは機能の「発見」が困難（想起ベースの認知モデル）"
echo "  4. GUIは直感的な操作と機能の発見に優れる（再認ベースの認知モデル）"
echo "  5. 優劣ではなく認知モデルの違い。タスクの性質で使い分ける"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
