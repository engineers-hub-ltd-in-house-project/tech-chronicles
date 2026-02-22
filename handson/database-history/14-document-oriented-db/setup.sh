#!/bin/bash
# =============================================================================
# 第14回ハンズオン：MongoDB, CouchDB——ドキュメント指向の挑戦
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: Docker（PostgreSQL 17 + MongoDB 8 公式イメージを使用）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-14"
POSTGRES_CONTAINER="db-history-ep14-postgres"
MONGO_CONTAINER="db-history-ep14-mongo"
NETWORK="db-history-ep14-net"

echo "=== 第14回ハンズオン：MongoDB, CouchDB——ドキュメント指向の挑戦 ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- 既存コンテナ・ネットワークの停止・削除 ---
for c in "${POSTGRES_CONTAINER}" "${MONGO_CONTAINER}"; do
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
# PostgreSQL コンテナの起動とデータ投入
# =============================================================================

echo "[Step 2] PostgreSQLコンテナを起動しています..."
docker run -d \
    --name "${POSTGRES_CONTAINER}" \
    --network "${NETWORK}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    postgres:17 > /dev/null

# PostgreSQLの起動を待機
for i in $(seq 1 30); do
    if docker exec "${POSTGRES_CONTAINER}" pg_isready -U postgres > /dev/null 2>&1; then
        echo "  ${POSTGRES_CONTAINER} が起動しました。"
        break
    fi
    sleep 1
done

echo "[Step 3] PostgreSQLにスキーマとデータを投入しています..."

docker exec -i "${POSTGRES_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- ユーザーテーブル
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 商品テーブル
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price INTEGER NOT NULL,
    category VARCHAR(50) NOT NULL
);

-- 注文テーブル
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    total INTEGER NOT NULL,
    ordered_at TIMESTAMP DEFAULT NOW()
);

-- 注文明細テーブル
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL,
    price_at_order INTEGER NOT NULL
);

-- ユーザーデータ
INSERT INTO users (name, email) VALUES
    ('Alice', 'alice@example.com'),
    ('Bob', 'bob@example.com'),
    ('Charlie', 'charlie@example.com');

-- 商品データ
INSERT INTO products (name, price, category) VALUES
    ('Mechanical Keyboard', 15000, 'peripherals'),
    ('Wireless Mouse', 8000, 'peripherals'),
    ('27" 4K Monitor', 45000, 'displays'),
    ('USB-C Hub', 6000, 'accessories'),
    ('Noise Cancelling Headphones', 35000, 'audio');

-- 注文データ
INSERT INTO orders (user_id, total, ordered_at) VALUES
    (1, 31000, '2026-02-20 10:00:00'),
    (2, 45000, '2026-02-20 14:30:00'),
    (1, 41000, '2026-02-21 09:00:00'),
    (3, 6000, '2026-02-21 16:00:00');

-- 注文明細データ
INSERT INTO order_items (order_id, product_id, quantity, price_at_order) VALUES
    (1, 1, 1, 15000),
    (1, 2, 2, 8000),
    (2, 3, 1, 45000),
    (3, 4, 1, 6000),
    (3, 5, 1, 35000),
    (4, 4, 1, 6000);
SQL

echo "  PostgreSQL: users(3行), products(5行), orders(4行), order_items(6行)"

# =============================================================================
# MongoDB コンテナの起動とデータ投入
# =============================================================================

echo "[Step 4] MongoDBコンテナを起動しています..."
docker run -d \
    --name "${MONGO_CONTAINER}" \
    --network "${NETWORK}" \
    mongo:8 > /dev/null

# MongoDBの起動を待機
for i in $(seq 1 30); do
    if docker exec "${MONGO_CONTAINER}" mongosh --eval "db.runCommand({ping:1})" > /dev/null 2>&1; then
        echo "  ${MONGO_CONTAINER} が起動しました。"
        break
    fi
    sleep 1
done

echo "[Step 5] MongoDBにドキュメントデータを投入しています..."

docker exec -i "${MONGO_CONTAINER}" mongosh handson <<'JS'
// 顧客コレクション（参照用）
db.customers.insertMany([
    { _id: "customer-alice", name: "Alice", email: "alice@example.com", created_at: new Date("2026-01-01") },
    { _id: "customer-bob", name: "Bob", email: "bob@example.com", created_at: new Date("2026-01-15") },
    { _id: "customer-charlie", name: "Charlie", email: "charlie@example.com", created_at: new Date("2026-02-01") }
]);

// 注文コレクション（埋め込みモデル: 顧客情報と商品情報を埋め込む）
db.orders.insertMany([
    {
        _id: "order-001",
        customer: { name: "Alice", email: "alice@example.com" },
        items: [
            { product: "Mechanical Keyboard", price: 15000, qty: 1, category: "peripherals" },
            { product: "Wireless Mouse", price: 8000, qty: 2, category: "peripherals" }
        ],
        total: 31000,
        ordered_at: new Date("2026-02-20T10:00:00Z")
    },
    {
        _id: "order-002",
        customer: { name: "Bob", email: "bob@example.com" },
        items: [
            { product: "27\" 4K Monitor", price: 45000, qty: 1, category: "displays" }
        ],
        total: 45000,
        ordered_at: new Date("2026-02-20T14:30:00Z")
    },
    {
        _id: "order-003",
        customer: { name: "Alice", email: "alice@example.com" },
        items: [
            { product: "USB-C Hub", price: 6000, qty: 1, category: "accessories" },
            { product: "Noise Cancelling Headphones", price: 35000, qty: 1, category: "audio" }
        ],
        total: 41000,
        ordered_at: new Date("2026-02-21T09:00:00Z")
    },
    {
        _id: "order-004",
        customer: { name: "Charlie", email: "charlie@example.com" },
        items: [
            { product: "USB-C Hub", price: 6000, qty: 1, category: "accessories" }
        ],
        total: 6000,
        ordered_at: new Date("2026-02-21T16:00:00Z")
    }
]);

print("MongoDB: customers(3件), orders(4件) を投入しました。");
JS

# =============================================================================
# 完了メッセージ
# =============================================================================

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "--- 演習1: データモデルの比較 ---"
echo ""
echo "PostgreSQLに接続:"
echo "  docker exec -it ${POSTGRES_CONTAINER} psql -U postgres -d handson"
echo ""
echo "MongoDBに接続:"
echo "  docker exec -it ${MONGO_CONTAINER} mongosh handson"
echo ""
echo "--- 演習2: 読み取り操作の比較 ---"
echo ""
echo "PostgreSQL (JOIN):"
echo "  SELECT o.id, u.name, p.name, oi.quantity"
echo "  FROM orders o JOIN users u ON o.user_id = u.id"
echo "  JOIN order_items oi ON o.id = oi.order_id"
echo "  JOIN products p ON oi.product_id = p.id WHERE o.id = 1;"
echo ""
echo "MongoDB (埋め込み):"
echo "  db.orders.findOne({ _id: 'order-001' })"
echo ""
echo "--- 演習3: 更新操作と一貫性 ---"
echo ""
echo "PostgreSQL: UPDATE users SET email = 'alice.new@example.com' WHERE id = 1;"
echo "MongoDB:    db.orders.updateMany({ 'customer.email': 'alice@example.com' },"
echo "              { \$set: { 'customer.email': 'alice.new@example.com' } })"
echo ""
echo "--- 演習4: 集計クエリの比較 ---"
echo ""
echo "PostgreSQL: GROUP BY + JOIN で商品カテゴリ別集計"
echo "MongoDB:    db.orders.aggregate([...]) で同等の集計"
echo ""
echo "--- 後片付け ---"
echo "  docker rm -f ${POSTGRES_CONTAINER} ${MONGO_CONTAINER}"
echo "  docker network rm ${NETWORK}"
