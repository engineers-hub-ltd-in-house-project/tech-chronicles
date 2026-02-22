#!/bin/bash
# =============================================================================
# 第7回ハンズオン：トランザクション分離レベルとデッドロックを体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: Docker（PostgreSQL 17 公式イメージを使用）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-07"
PG_CONTAINER="db-history-ep07-pg"

echo "=== 第7回ハンズオン：トランザクション分離レベルとデッドロックを体験する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- 既存コンテナの停止・削除 ---
if docker ps -a --format '{{.Names}}' | grep -q "^${PG_CONTAINER}$"; then
    echo "既存コンテナ ${PG_CONTAINER} を停止・削除しています..."
    docker rm -f "${PG_CONTAINER}" > /dev/null 2>&1
fi

# --- PostgreSQLコンテナの起動 ---
echo "[Step 1] PostgreSQLコンテナを起動しています..."
docker run -d \
    --name "${PG_CONTAINER}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    postgres:17 > /dev/null

# --- 起動待ち ---
echo "データベースの起動を待っています..."
for i in $(seq 1 30); do
    if docker exec "${PG_CONTAINER}" pg_isready -U postgres > /dev/null 2>&1; then
        echo "PostgreSQLが起動しました。"
        break
    fi
    sleep 1
done

# --- テストデータの投入 ---
echo ""
echo "[Step 2] テストデータを投入しています..."

cat > "${WORKDIR}/setup.sql" << 'SQLEOF'
-- =============================================================================
-- 第7回ハンズオン: テストデータのセットアップ
-- =============================================================================

-- 口座テーブル
CREATE TABLE accounts (
    account_id VARCHAR(10) PRIMARY KEY,
    owner_name VARCHAR(100) NOT NULL,
    balance INTEGER NOT NULL CHECK (balance >= 0)
);

-- テストデータ
INSERT INTO accounts VALUES
    ('A001', 'Alice', 1000000),
    ('A002', 'Bob', 500000),
    ('A003', 'Charlie', 750000),
    ('A004', 'Diana', 300000),
    ('A005', 'Eve', 1200000);

-- 送金履歴テーブル
CREATE TABLE transfers (
    transfer_id SERIAL PRIMARY KEY,
    from_account VARCHAR(10) REFERENCES accounts(account_id),
    to_account VARCHAR(10) REFERENCES accounts(account_id),
    amount INTEGER NOT NULL CHECK (amount > 0),
    transferred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ANALYZE accounts;
SQLEOF

docker cp "${WORKDIR}/setup.sql" "${PG_CONTAINER}:/tmp/setup.sql"
docker exec "${PG_CONTAINER}" psql -U postgres -d handson -f /tmp/setup.sql > /dev/null

echo "テストデータの投入が完了しました。"

# --- 演習SQLファイルの作成 ---
echo ""
echo "[Step 3] 演習SQLファイルを作成しています..."

# 演習1: READ COMMITTEDの挙動（自動デモ）
cat > "${WORKDIR}/exercise1_demo.sql" << 'SQLEOF'
-- =============================================================================
-- 演習1: READ COMMITTEDの挙動（自動デモ）
-- =============================================================================

\echo '=== READ COMMITTEDのデモ ==='
\echo ''
\echo 'READ COMMITTEDでは、他のトランザクションがCOMMITした変更が'
\echo 'トランザクション内でも見えてしまう（Non-Repeatable Read）。'
\echo ''
\echo '実際に体験するには2つのターミナルを開いて操作してください。'
\echo ''
\echo '--- 手順 ---'
\echo 'ターミナル1: BEGIN; SET TRANSACTION ISOLATION LEVEL READ COMMITTED;'
\echo 'ターミナル1: SELECT * FROM accounts WHERE account_id = ''A001'';'
\echo 'ターミナル2: UPDATE accounts SET balance = balance + 500000 WHERE account_id = ''A001''; -- autocommit'
\echo 'ターミナル1: SELECT * FROM accounts WHERE account_id = ''A001''; -- 値が変わっている!'
\echo 'ターミナル1: COMMIT;'

-- 現在の口座状態を表示
\echo ''
\echo '=== 現在の口座状態 ==='
SELECT * FROM accounts ORDER BY account_id;
SQLEOF

# 演習2: REPEATABLE READの挙動（自動デモ）
cat > "${WORKDIR}/exercise2_demo.sql" << 'SQLEOF'
-- =============================================================================
-- 演習2: REPEATABLE READの挙動（自動デモ）
-- =============================================================================

\echo '=== REPEATABLE READのデモ ==='
\echo ''
\echo 'REPEATABLE READでは、トランザクション開始時のスナップショットが維持される。'
\echo '他のトランザクションがCOMMITしても見えない。'
\echo ''
\echo '--- 手順 ---'
\echo 'ターミナル1: BEGIN; SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;'
\echo 'ターミナル1: SELECT * FROM accounts WHERE account_id = ''A001'';'
\echo 'ターミナル2: UPDATE accounts SET balance = balance - 200000 WHERE account_id = ''A001''; -- autocommit'
\echo 'ターミナル1: SELECT * FROM accounts WHERE account_id = ''A001''; -- 値が変わっていない!'
\echo 'ターミナル1: COMMIT;'
SQLEOF

# 演習3: 更新競合（自動デモ）
cat > "${WORKDIR}/exercise3_demo.sql" << 'SQLEOF'
-- =============================================================================
-- 演習3: REPEATABLE READでの更新競合（自動デモ）
-- =============================================================================

\echo '=== REPEATABLE READでの更新競合デモ ==='
\echo ''
\echo '--- 手順 ---'
\echo 'ターミナル1: BEGIN; SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;'
\echo 'ターミナル1: SELECT * FROM accounts WHERE account_id = ''A001'';'
\echo 'ターミナル2: UPDATE accounts SET balance = balance + 100000 WHERE account_id = ''A001''; -- autocommit'
\echo 'ターミナル1: UPDATE accounts SET balance = balance - 50000 WHERE account_id = ''A001'';'
\echo '>>> ERROR: could not serialize access due to concurrent update'
\echo 'ターミナル1: ROLLBACK;'
\echo ''
\echo 'First-Committer-Wins: 先にコミットしたトランザクションが勝つ。'
SQLEOF

# 演習4: デッドロック（自動デモ）
cat > "${WORKDIR}/exercise4_demo.sql" << 'SQLEOF'
-- =============================================================================
-- 演習4: デッドロックの発生と解消（自動デモ）
-- =============================================================================

\echo '=== デッドロックのデモ ==='
\echo ''
\echo '--- 手順 ---'
\echo 'ターミナル1: BEGIN;'
\echo 'ターミナル1: UPDATE accounts SET balance = balance - 100000 WHERE account_id = ''A001'';'
\echo 'ターミナル2: BEGIN;'
\echo 'ターミナル2: UPDATE accounts SET balance = balance - 100000 WHERE account_id = ''A002'';'
\echo 'ターミナル2: UPDATE accounts SET balance = balance + 100000 WHERE account_id = ''A001''; -- ブロックされる'
\echo 'ターミナル1: UPDATE accounts SET balance = balance + 100000 WHERE account_id = ''A002''; -- デッドロック!'
\echo ''
\echo '>>> ERROR: deadlock detected'
\echo '>>> PostgreSQLが片方のトランザクションをアボートしてデッドロックを解消する'
SQLEOF

# ファイルをコンテナにコピー
for f in exercise1_demo.sql exercise2_demo.sql exercise3_demo.sql exercise4_demo.sql; do
    docker cp "${WORKDIR}/${f}" "${PG_CONTAINER}:/tmp/${f}"
done

echo "演習SQLファイルの作成が完了しました。"

# --- 演習ガイドの表示 ---
echo ""
echo "============================================================"
echo "[演習ガイド] 各演習の手順説明"
echo "============================================================"

for f in exercise1_demo.sql exercise2_demo.sql exercise3_demo.sql exercise4_demo.sql; do
    echo ""
    docker exec "${PG_CONTAINER}" psql -U postgres -d handson -f "/tmp/${f}"
done

# --- 完了メッセージ ---
echo ""
echo "============================================================"
echo "セットアップが完了しました。"
echo "============================================================"
echo ""
echo "2つのターミナルを開いて、以下のコマンドでPostgreSQLに接続してください:"
echo "  docker exec -it ${PG_CONTAINER} psql -U postgres -d handson"
echo ""
echo "各演習の手順は上記のガイドに従ってください。"
echo ""
echo "コンテナの停止・削除:"
echo "  docker rm -f ${PG_CONTAINER}"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
