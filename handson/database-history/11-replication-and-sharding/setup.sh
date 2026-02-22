#!/bin/bash
# =============================================================================
# 第11回ハンズオン：レプリケーションとシャーディング——スケールの壁を越える
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: Docker（PostgreSQL 17 公式イメージを使用）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-11"
PUB_CONTAINER="db-history-ep11-pub"
SUB_CONTAINER="db-history-ep11-sub"
SHARD0_CONTAINER="db-history-ep11-shard0"
SHARD1_CONTAINER="db-history-ep11-shard1"
NETWORK="db-history-ep11-net"

echo "=== 第11回ハンズオン：レプリケーションとシャーディング ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- 既存コンテナ・ネットワークの停止・削除 ---
for c in "${PUB_CONTAINER}" "${SUB_CONTAINER}" "${SHARD0_CONTAINER}" "${SHARD1_CONTAINER}"; do
    if docker ps -a --format '{{.Names}}' | grep -q "^${c}$"; then
        echo "既存コンテナ ${c} を停止・削除しています..."
        docker rm -f "${c}" > /dev/null 2>&1
    fi
done

docker network rm "${NETWORK}" > /dev/null 2>&1 || true

# --- Dockerネットワークの作成 ---
echo "[Step 1] Dockerネットワークを作成しています..."
docker network create "${NETWORK}" > /dev/null

# =============================================================================
# パート1: 論理レプリケーション
# =============================================================================

echo ""
echo "=== パート1: 論理レプリケーション ==="
echo ""

# --- パブリッシャー（マスタ）の起動 ---
echo "[Step 2] パブリッシャーを起動しています..."
docker run -d \
    --name "${PUB_CONTAINER}" \
    --network "${NETWORK}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    -e POSTGRES_INITDB_ARGS="--data-checksums" \
    postgres:17 \
    -c wal_level=logical \
    -c max_replication_slots=4 \
    -c max_wal_senders=4 > /dev/null

# --- サブスクライバー（レプリカ）の起動 ---
echo "[Step 3] サブスクライバーを起動しています..."
docker run -d \
    --name "${SUB_CONTAINER}" \
    --network "${NETWORK}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    -e POSTGRES_INITDB_ARGS="--data-checksums" \
    postgres:17 > /dev/null

echo "PostgreSQLの起動を待機しています..."
for c in "${PUB_CONTAINER}" "${SUB_CONTAINER}"; do
    for i in $(seq 1 30); do
        if docker exec "${c}" pg_isready -U postgres > /dev/null 2>&1; then
            echo "  ${c} が起動しました。"
            break
        fi
        sleep 1
    done
done

# --- パブリッシャーにテーブルとパブリケーションを作成 ---
echo ""
echo "[Step 4] パブリッシャーにテーブルとパブリケーションを作成しています..."

docker exec -i "${PUB_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- テーブル作成
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- パブリケーション作成（usersテーブルの変更を公開する）
CREATE PUBLICATION pub_users FOR TABLE users;
SQL

echo "パブリケーションを作成しました。"

# --- サブスクライバーにテーブルとサブスクリプションを作成 ---
echo ""
echo "[Step 5] サブスクライバーにテーブルとサブスクリプションを作成しています..."

docker exec -i "${SUB_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- 同一構造のテーブルを作成（論理レプリケーションは自動でテーブルを作らない）
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- サブスクリプション作成
CREATE SUBSCRIPTION sub_users
    CONNECTION 'host=db-history-ep11-pub port=5432 dbname=handson user=postgres password=handson'
    PUBLICATION pub_users;
SQL

echo "サブスクリプションを作成しました。"

# =============================================================================
# パート2: シャーディング
# =============================================================================

echo ""
echo "=== パート2: シャーディング ==="
echo ""

# --- シャード0の起動 ---
echo "[Step 6] シャード0（偶数user_id）を起動しています..."
docker run -d \
    --name "${SHARD0_CONTAINER}" \
    --network "${NETWORK}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    postgres:17 > /dev/null

# --- シャード1の起動 ---
echo "[Step 7] シャード1（奇数user_id）を起動しています..."
docker run -d \
    --name "${SHARD1_CONTAINER}" \
    --network "${NETWORK}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    postgres:17 > /dev/null

echo "シャードの起動を待機しています..."
for c in "${SHARD0_CONTAINER}" "${SHARD1_CONTAINER}"; do
    for i in $(seq 1 30); do
        if docker exec "${c}" pg_isready -U postgres > /dev/null 2>&1; then
            echo "  ${c} が起動しました。"
            break
        fi
        sleep 1
    done
done

# --- シャード0にテーブル作成とデータ投入 ---
echo ""
echo "[Step 8] シャード0にデータを投入しています..."

docker exec -i "${SHARD0_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- 注文テーブル（シャード0: 偶数user_idのデータ）
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    order_date DATE NOT NULL
);

-- 偶数user_idの注文データ（5万件）
INSERT INTO orders (user_id, product_name, amount, order_date)
SELECT
    (floor(random() * 500) * 2 + 2)::INTEGER,
    'Product_' || (floor(random() * 100) + 1)::INTEGER,
    (random() * 10000 + 100)::NUMERIC(10, 2),
    DATE '2024-01-01' + (random() * 365)::INTEGER
FROM generate_series(1, 50000);

ANALYZE orders;
SQL

echo "シャード0にデータを投入しました。"

# --- シャード1にテーブル作成とデータ投入 ---
echo ""
echo "[Step 9] シャード1にデータを投入しています..."

docker exec -i "${SHARD1_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- 注文テーブル（シャード1: 奇数user_idのデータ）
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    order_date DATE NOT NULL
);

-- 奇数user_idの注文データ（5万件）
INSERT INTO orders (user_id, product_name, amount, order_date)
SELECT
    (floor(random() * 500) * 2 + 1)::INTEGER,
    'Product_' || (floor(random() * 100) + 1)::INTEGER,
    (random() * 10000 + 100)::NUMERIC(10, 2),
    DATE '2024-01-01' + (random() * 365)::INTEGER
FROM generate_series(1, 50000);

ANALYZE orders;
SQL

echo "シャード1にデータを投入しました。"

# =============================================================================
# 完了メッセージ
# =============================================================================

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "--- パート1: 論理レプリケーション ---"
echo ""
echo "パブリッシャーに接続:"
echo "  docker exec -it ${PUB_CONTAINER} psql -U postgres -d handson"
echo ""
echo "サブスクライバーに接続:"
echo "  docker exec -it ${SUB_CONTAINER} psql -U postgres -d handson"
echo ""
echo "演習1: パブリッシャーでINSERTし、サブスクライバーで確認"
echo "  [pub] INSERT INTO users (name, email) VALUES ('Tanaka', 'tanaka@example.com');"
echo "  [sub] SELECT * FROM users;"
echo ""
echo "演習2: 大量データ投入でレプリケーションラグを観測"
echo "  [pub] INSERT INTO users (name, email)"
echo "        SELECT 'User_' || i, 'user' || i || '@example.com'"
echo "        FROM generate_series(1, 100000) AS i;"
echo "  [sub] SELECT COUNT(*) FROM users;  -- 繰り返し実行してラグを観測"
echo ""
echo "--- パート2: シャーディング ---"
echo ""
echo "シャード0（偶数user_id）に接続:"
echo "  docker exec -it ${SHARD0_CONTAINER} psql -U postgres -d handson"
echo ""
echo "シャード1（奇数user_id）に接続:"
echo "  docker exec -it ${SHARD1_CONTAINER} psql -U postgres -d handson"
echo ""
echo "演習3: シャード内クエリ"
echo "  [shard0] SELECT user_id, SUM(amount) FROM orders WHERE user_id = 2 GROUP BY user_id;"
echo ""
echo "演習4: クロスシャードクエリの困難さ"
echo "  [shard0] SELECT user_id, SUM(amount) AS total FROM orders GROUP BY user_id ORDER BY total DESC LIMIT 5;"
echo "  → シャード0の偶数user_idの結果のみ。全体の上位5を得るには両シャードの結果をマージする必要がある。"
echo ""
echo "--- 後片付け ---"
echo "  docker rm -f ${PUB_CONTAINER} ${SUB_CONTAINER} ${SHARD0_CONTAINER} ${SHARD1_CONTAINER}"
echo "  docker network rm ${NETWORK}"
