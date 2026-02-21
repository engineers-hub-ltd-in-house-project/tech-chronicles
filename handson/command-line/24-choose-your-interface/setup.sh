#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/command-line-handson-24"

echo "============================================================"
echo " 第24回ハンズオン: インターフェース選定マトリクスを作成する"
echo "============================================================"
echo ""

# ----- セクション1: 環境準備 -----
echo ">>> セクション1: 環境準備"
mkdir -p "${WORKDIR}/logs"
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

# ----- セクション2: テスト用ログデータ生成 -----
echo ">>> セクション2: テスト用ログデータ生成"

for i in $(seq 1 5); do
  cat > "${WORKDIR}/logs/app-${i}.log" << LOGEOF
2025-02-01 10:00:01 [INFO] Service started on port 808${i}
2025-02-01 10:05:23 [ERROR] Connection refused to database server
2025-02-01 10:05:24 [WARN] Retrying connection in 5 seconds
2025-02-01 10:05:29 [INFO] Database connection restored
2025-02-01 10:15:00 [ERROR] Request timeout after 30s for /api/users
2025-02-01 10:30:00 [INFO] Health check passed
2025-02-01 11:00:00 [WARN] Memory usage at 85%
2025-02-01 11:30:45 [ERROR] Out of memory exception in worker thread
2025-02-01 12:00:00 [INFO] Service restarted by watchdog
LOGEOF
done

echo "ログファイル5本を生成しました"
echo ""

# ----- セクション3: 演習1 --- 同じタスクを異なる方法で実行する -----
echo ">>> 演習1: 同じタスクを異なる方法で実行する"
echo ""

echo "--- タスク: 全ログファイルからERRORを抽出し、メッセージ別に集計する ---"
echo ""

echo "[方法1: CLIパイプライン（精密・再現可能・組み合わせ可能）]"
grep "ERROR" "${WORKDIR}/logs/"*.log \
  | sed 's/.*\[ERROR\] //' \
  | sort \
  | uniq -c \
  | sort -rn
echo ""

echo "→ 反復性: 高い（そのままスクリプト化できる）"
echo "→ 探索性: 低い（grepの構文を知っている必要がある）"
echo "→ 構造性: テキスト向き（ログはテキストデータ）"
echo "→ 曖昧性: 低い（完全に精密な指示）"
echo ""

echo "[方法2: 自然言語での指示（想定）]"
echo '指示例: "ログファイルからエラーを探して、どんなエラーが多いか教えて"'
echo ""
echo "→ 反復性: 低い（同じ結果が保証されない）"
echo "→ 探索性: 高い（構文を知らなくても指示できる）"
echo "→ 構造性: テキスト向き"
echo "→ 曖昧性: 高い（AIが解釈を補う）"
echo ""

echo "[方法3: GUIログビューアー（想定）]"
echo "操作例: ファイルを開く → フィルタに'ERROR'と入力 → 集計ビューに切替"
echo ""
echo "→ 反復性: 低い（手動操作を毎回再現する必要がある）"
echo "→ 探索性: 高い（メニューからフィルタ機能を発見できる）"
echo "→ 構造性: 視覚的な表示（色分け、ハイライト）"
echo "→ 曖昧性: 低い（操作は明確）"
echo ""

# ----- セクション4: 演習2 --- 反復タスクのスクリプト化 -----
echo ">>> 演習2: 反復タスクのスクリプト化"
echo ""

echo "--- 手動操作を記録し、スクリプトに変換する ---"
echo ""

echo "手動実行1: ログのエラー件数確認"
grep -c "ERROR" "${WORKDIR}/logs/"*.log
echo ""

echo "手動実行2: メモリ警告の確認"
grep "Memory" "${WORKDIR}/logs/"*.log
echo ""

echo "手動実行3: 最新のエラーを確認"
grep "ERROR" "${WORKDIR}/logs/"*.log | tail -5
echo ""

cat > "${WORKDIR}/daily-check.sh" << 'SCRIPT'
#!/bin/bash
set -euo pipefail

LOG_DIR="${1:-.}"
echo "=== 日次ログチェックレポート ==="
echo "実行日時: $(date)"
echo "対象: ${LOG_DIR}"
echo ""

echo "--- エラー件数（ファイル別） ---"
grep -c "ERROR" "${LOG_DIR}"/*.log 2>/dev/null || echo "  エラーなし"
echo ""

echo "--- メモリ警告 ---"
grep "Memory" "${LOG_DIR}"/*.log 2>/dev/null || echo "  警告なし"
echo ""

echo "--- 直近のエラー（最新5件） ---"
grep "ERROR" "${LOG_DIR}"/*.log 2>/dev/null | tail -5 || echo "  エラーなし"
echo ""

echo "=== レポート終了 ==="
SCRIPT

chmod +x "${WORKDIR}/daily-check.sh"

echo "--- スクリプトを実行 ---"
echo ""
bash "${WORKDIR}/daily-check.sh" "${WORKDIR}/logs"

echo ""
echo "→ 手動で3回実行したコマンドが、スクリプト1本になった。"
echo "  明日も明後日も同じチェックを実行できる。"
echo "  これがCLIの『反復性に対する適合』の実体だ。"
echo ""

# ----- セクション5: 演習3 --- 探索性の軸を体験する -----
echo ">>> 演習3: 探索性の軸を体験する"
echo ""

echo "[CLIの場合: 想起(recall)が必要]"
echo "知っていなければならないこと:"
echo "  - ls でファイル一覧を見る"
echo "  - cat でファイルの内容を見る"
echo "  - grep でパターンを検索する"
echo ""

echo "Step 1: ファイル一覧を見る"
ls -la "${WORKDIR}/logs/"
echo ""

echo "Step 2: 1つ目のファイルの内容を確認"
head -5 "${WORKDIR}/logs/app-1.log"
echo ""

echo "Step 3: ログレベルの種類を把握する"
grep -oE '\[[A-Z]+\]' "${WORKDIR}/logs/"*.log | sed 's/.*://' | sort -u
echo ""

echo "→ この探索には、ls, head, grep の知識が必要だった。"
echo "  GUIのファイラーなら、フォルダをクリックして開き、"
echo "  ファイルをダブルクリックすれば内容が見える。"
echo "  『何があるか分からない』状態では、GUIの発見可能性が活きる。"
echo ""

echo "[CLIの探索性を補う方法]"
echo "  方法1: --help フラグ"
echo "  方法2: Tab補完（対話的シェルで利用可能）"
echo "  方法3: 自然言語で質問（AI活用）"
echo ""

# ----- セクション6: 演習4 --- インターフェース選定マトリクス -----
echo ">>> 演習4: インターフェース選定マトリクスを作成する"
echo ""

cat << 'MATRIX'
以下のマトリクスを、自分の日常タスクで埋めてみよう。
各タスクの四軸スコアを評価し、最適なインターフェースを判定する。

┌────────────────────┬──────┬──────┬──────┬──────┬──────────┐
│ タスク              │反復性│探索性│構造性│曖昧性│最適な IF  │
├────────────────────┼──────┼──────┼──────┼──────┼──────────┤
│ 例: ログ分析        │ 高   │ 低   │ 低   │ 低   │ CLI      │
│ 例: UIデザイン      │ 低   │ 高   │ 高   │ 中   │ GUI      │
│ 例: コードレビュー  │ 中   │ 高   │ 中   │ 中   │ GUI+CLI  │
│ 例: 障害調査        │ 低   │ 高   │ 低   │ 高   │ AI+CLI   │
│ 例: デプロイ        │ 高   │ 低   │ 低   │ 低   │ CLI/CI   │
│ 例: サーバ監視      │ 高   │ 中   │ 中   │ 低   │ TUI      │
├────────────────────┼──────┼──────┼──────┼──────┼──────────┤
│ あなたのタスク1:     │      │      │      │      │          │
│ あなたのタスク2:     │      │      │      │      │          │
│ あなたのタスク3:     │      │      │      │      │          │
│ あなたのタスク4:     │      │      │      │      │          │
│ あなたのタスク5:     │      │      │      │      │          │
└────────────────────┴──────┴──────┴──────┴──────┴──────────┘

評価基準:
  反復性: 低=1回限り / 中=週数回 / 高=毎日
  探索性: 低=何をすべきか明確 / 中=ある程度探索が必要 / 高=手探り
  構造性: 低=テキスト中心 / 中=表形式 / 高=視覚的・空間的
  曖昧性: 低=指示が精密 / 中=ある程度曖昧 / 高=何を探すか不明

判定基準:
  反復性が高い → CLI/スクリプト向き
  探索性が高い → GUI向き
  構造性が高い → GUI向き
  曖昧性が高い → AI(自然言語)向き
  複数の軸が中程度 → TUIやハイブリッド(コマンドパレット等)

MATRIX

echo ""
echo "→ このマトリクスの目的は、意識的にインターフェースを選ぶことだ。"
echo "  『いつも使っているから』ではなく、"
echo "  『このタスクにはこのインターフェースが最適だから』と"
echo "  言語化できるようになることが、この演習のゴールだ。"
echo ""

# ----- クリーンアップ案内 -----
echo "============================================================"
echo " 全演習完了"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "クリーンアップ: rm -rf ${WORKDIR}"
