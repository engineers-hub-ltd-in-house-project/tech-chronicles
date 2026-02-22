#!/bin/bash
# =============================================================================
# 第10回ハンズオン：インデックス設計——データベースの「速さ」の正体
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: Docker（PostgreSQL 17 公式イメージを使用）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-10"
PG_CONTAINER="db-history-ep10-pg"

echo "=== 第10回ハンズオン：インデックス設計——データベースの「速さ」の正体 ==="
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
    -e POSTGRES_INITDB_ARGS="--data-checksums" \
    postgres:17 > /dev/null

echo "PostgreSQLの起動を待機しています..."
for i in $(seq 1 30); do
    if docker exec "${PG_CONTAINER}" pg_isready -U postgres > /dev/null 2>&1; then
        echo "PostgreSQLが起動しました。"
        break
    fi
    sleep 1
done

# --- テーブルの作成 ---
echo ""
echo "[Step 2] テーブルを作成しています..."

docker exec -i "${PG_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- === テーブル定義 ===

-- 顧客テーブル
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(200) NOT NULL
);

-- 商品テーブル
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- 注文テーブル（インデックスなしで作成 — 演習で段階的に追加する）
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

SQL

echo "テーブルを作成しました。"

# --- マスタデータの投入 ---
echo ""
echo "[Step 3] マスタデータを投入しています..."

docker exec -i "${PG_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- === マスタデータ ===

-- 顧客データ（100件）
INSERT INTO customers (name, email)
SELECT
    'Customer_' || i,
    'customer' || i || '@example.com'
FROM generate_series(1, 100) AS i;

-- 商品データ（50件）
INSERT INTO products (product_name, category, price)
SELECT
    'Product_' || i,
    CASE (i % 5)
        WHEN 0 THEN 'electronics'
        WHEN 1 THEN 'books'
        WHEN 2 THEN 'clothing'
        WHEN 3 THEN 'food'
        WHEN 4 THEN 'toys'
    END,
    (random() * 10000 + 100)::NUMERIC(10, 2)
FROM generate_series(1, 50) AS i;

SQL

echo "マスタデータを投入しました。"

# --- 大量テストデータの投入 ---
echo ""
echo "[Step 4] 注文データ100万行を投入しています（少々お待ちください）..."

docker exec -i "${PG_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- === 100万行の注文データ ===
-- statusの分布: shipped 33%, processing 33%, delivered 33%, cancelled 1%
INSERT INTO orders (customer_id, product_id, quantity, total_price, status, order_date)
SELECT
    (random() * 99 + 1)::INTEGER,
    (random() * 49 + 1)::INTEGER,
    (random() * 9 + 1)::INTEGER,
    (random() * 50000 + 100)::NUMERIC(10, 2),
    CASE
        WHEN random() < 0.01 THEN 'cancelled'
        WHEN random() < 0.34 THEN 'shipped'
        WHEN random() < 0.67 THEN 'processing'
        ELSE 'delivered'
    END,
    DATE '2023-01-01' + (random() * 730)::INTEGER
FROM generate_series(1, 1000000);

-- 統計情報の収集
ANALYZE orders;
ANALYZE customers;
ANALYZE products;

SQL

echo "100万行の注文データを投入しました。"

# --- テーブルサイズの確認 ---
echo ""
echo "[Step 5] テーブルのサイズを確認しています..."

docker exec -i "${PG_CONTAINER}" psql -U postgres -d handson <<'SQL'
SELECT
    relname AS table_name,
    pg_size_pretty(pg_total_relation_size(oid)) AS total_size,
    pg_size_pretty(pg_relation_size(oid)) AS table_size,
    pg_size_pretty(pg_indexes_size(oid)) AS index_size
FROM pg_class
WHERE relname IN ('orders', 'customers', 'products')
ORDER BY pg_total_relation_size(oid) DESC;
SQL

# --- 完了メッセージ ---
echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "PostgreSQLに接続するには:"
echo "  docker exec -it ${PG_CONTAINER} psql -U postgres -d handson"
echo ""
echo "演習1: インデックスなしの世界"
echo "  EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 42;"
echo ""
echo "演習2: 単一カラムインデックスの効果"
echo "  CREATE INDEX idx_orders_customer ON orders (customer_id);"
echo "  EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 42;"
echo ""
echo "演習3: 複合インデックスと最左一致の法則"
echo "  CREATE INDEX idx_orders_customer_status ON orders (customer_id, status);"
echo "  EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 42 AND status = 'shipped';"
echo "  EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'shipped';"
echo ""
echo "演習4: EXPLAIN ANALYZEを読み解く"
echo "  EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)"
echo "  SELECT o.id, o.order_date, c.name, p.product_name"
echo "  FROM orders o JOIN customers c ON o.customer_id = c.id"
echo "  JOIN products p ON o.product_id = p.id"
echo "  WHERE o.customer_id = 42 AND o.order_date >= '2024-01-01';"
echo ""
echo "演習5: カバリングインデックスとIndex-Only Scan"
echo "  CREATE INDEX idx_orders_covering ON orders (customer_id) INCLUDE (status, order_date);"
echo "  VACUUM orders;"
echo "  EXPLAIN ANALYZE SELECT customer_id, status FROM orders WHERE customer_id = 42;"
echo ""
echo "演習6: 選択性とオプティマイザの判断"
echo "  CREATE INDEX idx_orders_status ON orders (status);"
echo "  EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'shipped';"
echo "  EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'cancelled';"
echo ""
echo "後片付け:"
echo "  docker rm -f ${PG_CONTAINER}"
