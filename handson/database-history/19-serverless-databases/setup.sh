#!/bin/bash
# =============================================================================
# 第19回ハンズオン：NeonのサーバレスPostgreSQLを体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: node (18+), npm, psql
# 必要なアカウント: Neon (無料Freeプラン)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-19"
PROJECT_NAME="serverless-handson"
BRANCH_NAME="feature-discount"

echo "=== 第19回ハンズオン：NeonのサーバレスPostgreSQLを体験する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- 前提条件チェック ---
echo "[準備] 前提条件を確認"

if ! command -v node &>/dev/null; then
  echo "  エラー: Node.js がインストールされていない"
  echo "  https://nodejs.org/ からインストールすること"
  exit 1
fi
echo "  Node.js: $(node --version)"

if ! command -v psql &>/dev/null; then
  echo "  警告: psql がインストールされていない"
  echo "  psqlなしでも演習は可能だが、直接接続にはpsqlが必要"
fi

echo ""

# --- neonctl CLIのインストール ---
echo "[準備] neonctl CLI を確認"
if ! command -v neonctl &>/dev/null; then
  echo "  neonctl をインストール中..."
  npm install -g neonctl
  echo "  neonctl のインストールが完了した"
else
  echo "  neonctl: $(neonctl --version)"
fi
echo ""

# --- 認証確認 ---
echo "[準備] Neon 認証を確認"
echo "  neonctl auth を実行して認証を行う"
echo "  （ブラウザが開くので、Neonアカウントでログインすること）"
echo ""
neonctl auth || {
  echo "  エラー: Neon認証に失敗した"
  echo "  https://neon.tech でアカウントを作成し、再度実行すること"
  exit 1
}
echo ""

# --- プロジェクト作成 ---
echo "[演習1] Neonプロジェクトを作成"

# 既存プロジェクトの確認と削除
EXISTING_PROJECT=$(neonctl projects list --output json 2>/dev/null | grep -o "\"${PROJECT_NAME}\"" || true)
if [ -n "${EXISTING_PROJECT}" ]; then
  echo "  既存プロジェクト '${PROJECT_NAME}' を削除"
  neonctl projects delete "${PROJECT_NAME}" 2>/dev/null || true
  sleep 3
fi

echo "  プロジェクト '${PROJECT_NAME}' を作成中..."
neonctl projects create --name "${PROJECT_NAME}"
echo "  プロジェクトの作成が完了した"
echo ""

# 接続文字列の取得
echo "  === 接続情報 ==="
CONNECTION_STRING=$(neonctl connection-string 2>/dev/null)
echo "  接続文字列: ${CONNECTION_STRING}"
echo ""

# 接続文字列をファイルに保存
echo "${CONNECTION_STRING}" >"${WORKDIR}/connection-string.txt"
echo "  接続文字列を ${WORKDIR}/connection-string.txt に保存した"
echo ""

# --- テーブル作成とデータ投入 ---
echo "[演習1] テーブル作成とデータ投入"
echo ""

psql "${CONNECTION_STRING}" <<'SQL'
-- テーブル作成
CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(10, 2) NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- データ投入
INSERT INTO products (name, price, category) VALUES
  ('PostgreSQL入門', 3200, 'book'),
  ('データベース設計の教科書', 3800, 'book'),
  ('SQLパズル', 2800, 'book'),
  ('機械学習キット', 15000, 'hardware'),
  ('Raspberry Pi 5', 12000, 'hardware');
SQL

echo "  === 初期データ ==="
psql "${CONNECTION_STRING}" -c "SELECT id, name, price, category FROM products ORDER BY id;"
echo ""
echo "  >>> サーバレスPostgreSQL上でテーブル作成とデータ投入が完了した"
echo ""

# --- 演習2: ブランチ作成 ---
echo "[演習2] ブランチによるスキーマ変更テスト"
echo ""

echo "  mainブランチから '${BRANCH_NAME}' ブランチを作成中..."
neonctl branches create --name "${BRANCH_NAME}"
echo "  ブランチの作成が完了した（Copy-on-Write: データの物理コピーは行われない）"
echo ""

# ブランチの接続文字列を取得
BRANCH_CONNECTION=$(neonctl connection-string --branch "${BRANCH_NAME}" 2>/dev/null)
echo "  ブランチ接続文字列: ${BRANCH_CONNECTION}"
echo "${BRANCH_CONNECTION}" >"${WORKDIR}/branch-connection-string.txt"
echo ""

# ブランチ上でスキーマ変更
echo "  ブランチ上でスキーマを変更..."
psql "${BRANCH_CONNECTION}" <<'SQL'
-- ブランチ上でスキーマを変更
ALTER TABLE products ADD COLUMN discount_rate NUMERIC(3, 2) DEFAULT 0.00;

-- ブランチ上でデータを変更
UPDATE products SET discount_rate = 0.20 WHERE category = 'book';
SQL

echo "  === ブランチ上のデータ（discount_rateカラム追加済み） ==="
psql "${BRANCH_CONNECTION}" -c "
SELECT name, price, discount_rate,
       price * (1 - discount_rate) AS discounted_price
FROM products ORDER BY id;
"
echo ""

# mainブランチで確認
echo "  === mainブランチのデータ（変更の影響を受けていない） ==="
psql "${CONNECTION_STRING}" -c "SELECT * FROM products ORDER BY id;"
echo ""
echo "  >>> ブランチ上の変更はmainに影響しない。独立した環境でスキーマ変更を安全にテストできる"
echo ""

# --- 演習3: Scale to Zero ---
echo "[演習3] Scale to Zeroの観察"
echo ""
echo "  NeonのCompute Nodeはデフォルトで5分間のインアクティビティ後に自動停止する"
echo "  ブランチの状態を確認:"
neonctl branches list
echo ""
echo "  Scale to Zeroを体験するには:"
echo "    1. 5分以上何も操作せずに待つ"
echo "    2. neonctl branches list でCompute Nodeの状態を確認"
echo "    3. psqlで再接続 -> Compute Nodeが自動起動"
echo "    4. 最初のクエリに数百ミリ秒の追加レイテンシ（コールドスタート）を観測"
echo ""

# --- 演習4: コネクションプーリング ---
echo "[演習4] コネクションプーリング"
echo ""
echo "  Neonはプーリング付き接続を提供している"
echo "  直接接続:    ${CONNECTION_STRING}"
echo "  プーリング接続: ${CONNECTION_STRING}?pgbouncer=true"
echo ""
echo "  プーリング接続のテスト:"
psql "${CONNECTION_STRING}?pgbouncer=true" -c "SELECT pg_backend_pid(), now();"
echo ""
echo "  >>> サーバレスアプリ（Lambda等）からの大量接続には、プーリング接続を使用すること"
echo ""

echo "=== セットアップ完了 ==="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "接続情報:"
echo "  main ブランチ:   ${CONNECTION_STRING}"
echo "  feature ブランチ: ${BRANCH_CONNECTION}"
echo ""
echo "手動で試すには:"
echo "  psql \"\$(cat ${WORKDIR}/connection-string.txt)\""
echo ""
echo "後片付け:"
echo "  neonctl branches delete ${BRANCH_NAME}"
echo "  neonctl projects delete ${PROJECT_NAME}"
