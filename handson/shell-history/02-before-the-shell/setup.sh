#!/bin/bash
# =============================================================================
# 第2回ハンズオン：バッチ処理と対話的処理を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 前提: Docker環境（ubuntu:24.04）またはbashが使えるLinux環境
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-02"

echo "=== 第2回ハンズオン：バッチ処理と対話的処理を体験する ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# --- 演習1: バッチ処理的ワークフローの再現 ---
echo "================================================================"
echo "[演習1] バッチ処理的ワークフロー"
echo "================================================================"
echo ""
echo "「パンチカード」にあたるスクリプトファイルを作成します..."

cat > "${WORKDIR}/batch_job.sh" << 'BATCH'
#!/bin/sh
echo "=== バッチジョブ開始 ==="
echo "日時: $(date)"
echo "ユーザー: $(whoami)"
echo "ホスト: $(hostname)"
echo ""
echo "--- /etc/passwd の行数を集計 ---"
wc -l /etc/passwd
echo ""
echo "--- ファイルシステムの使用量 ---"
df -h /
echo ""
echo "=== バッチジョブ完了 ==="
BATCH

chmod +x "${WORKDIR}/batch_job.sh"

echo "スクリプトを実行し、結果をファイルに保存します（途中経過は見えません）..."
"${WORKDIR}/batch_job.sh" > "${WORKDIR}/batch_output.txt" 2>&1

echo ""
echo "--- 「翌日、結果を受け取る」 ---"
cat "${WORKDIR}/batch_output.txt"
echo ""
echo "=> バッチ処理では実行中の途中経過が見えない。結果は事後に確認するのみ。"
echo ""

# --- 演習2: 対話的ワークフロー ---
echo "================================================================"
echo "[演習2] 対話的ワークフロー"
echo "================================================================"
echo ""
echo "同じ情報を、1コマンドずつ即座に確認しながら取得します..."
echo ""

echo '$ date'
date
echo ""

echo '$ whoami'
whoami
echo ""

echo '$ hostname'
hostname
echo ""

echo '$ wc -l /etc/passwd'
wc -l /etc/passwd
echo ""

echo '$ df -h /'
df -h /
echo ""

echo "=> 対話的処理では各コマンドの結果を即座に確認し、次の操作を判断できる。"
echo ""

# --- 演習3: heredocによる「パンチカード的」入力 ---
echo "================================================================"
echo "[演習3] heredocで「パンチカード的」入力を再現"
echo "================================================================"
echo ""

echo "heredocでsortコマンドに一括入力:"
echo '$ sort << EOF'
echo 'banana'
echo 'apple'
echo 'cherry'
echo 'date'
echo 'elderberry'
echo 'EOF'
echo ""
echo "結果:"
sort << 'EOF'
banana
apple
cherry
date
elderberry
EOF
echo ""
echo "=> heredocの内容は実行前に確定している。途中変更は不可。これがバッチ的処理の制約。"
echo ""

# --- 演習4: RUNCOMの精神を体験する ---
echo "================================================================"
echo "[演習4] RUNCOMの精神――コマンドをビルディングブロックとして使う"
echo "================================================================"
echo ""

echo "Step 1: データを生成する"
echo '$ seq 1 100 > numbers.txt'
seq 1 100 > "${WORKDIR}/numbers.txt"
echo "  -> 1から100の数列を生成"
echo ""

echo "Step 2: フィルタリングする（偶数のみ）"
echo '$ awk "\$1 % 2 == 0" numbers.txt > even.txt'
awk '$1 % 2 == 0' "${WORKDIR}/numbers.txt" > "${WORKDIR}/even.txt"
echo "  -> 偶数のみを抽出"
echo ""

echo "Step 3: 集計する"
EVEN_COUNT=$(wc -l < "${WORKDIR}/even.txt")
EVEN_SUM=$(awk '{sum+=$1} END {print sum}' "${WORKDIR}/even.txt")
echo "  偶数の個数: ${EVEN_COUNT}"
echo "  偶数の合計: ${EVEN_SUM}"
echo ""
echo "=> PouzinのRUNCOM（1963年頃）は、コマンドをサブルーチンのように組み合わせる仕組みだった。"
echo ""

# --- 演習5: .rcファイルの起源を確認する ---
echo "================================================================"
echo "[演習5] .rcファイルの起源を確認する"
echo "================================================================"
echo ""

echo "--- ホームディレクトリの.rcファイル ---"
ls -la ~/.*rc 2>/dev/null || echo "(なし)"
echo ""

echo "--- /etc配下のrcファイル ---"
ls /etc/*rc 2>/dev/null || echo "(なし)"
echo ""

echo "--- .rcの由来 ---"
echo "  rc = run commands"
echo "  起源: Louis Pouzin, CTSS RUNCOM (1963年頃)"
echo "  系譜: RUNCOM -> Multics shell -> UNIX -> .bashrc, .vimrc, .zshrc..."
echo ""

# --- まとめ ---
echo "================================================================"
echo "=== ハンズオン完了 ==="
echo "================================================================"
echo ""
echo "ポイント:"
echo "  1. バッチ処理は途中経過が見えず、フィードバックループが長い"
echo "  2. 対話的処理は即座に結果を確認し、次の操作を判断できる"
echo "  3. heredocはパンチカード的な「事前確定入力」を再現する"
echo "  4. RUNCOMの精神は現代のシェルスクリプトに直接つながっている"
echo "  5. .rcファイルの命名規則は1963年のCTSS RUNCOMに由来する"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
