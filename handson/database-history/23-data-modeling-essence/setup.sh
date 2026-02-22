#!/bin/bash
# =============================================================================
# 第23回ハンズオン：同じ要件を3つの設計で実装する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: docker
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-23"

echo "=== 第23回ハンズオン：同じ要件を3つの設計で実装する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- PostgreSQL起動 ---
echo "[準備] PostgreSQL 17をDockerで起動"
echo ""

# 既存コンテナがあれば削除
docker rm -f pg-normalized 2>/dev/null || true

docker run -d \
  --name pg-normalized \
  -e POSTGRES_PASSWORD=handson \
  -e POSTGRES_DB=normalized_db \
  -p 5432:5432 \
  postgres:17

echo "PostgreSQL起動を待機中..."
sleep 5

# =============================================================================
# アプローチ1: 正規化RDB設計
# =============================================================================
echo "============================================================"
echo "[アプローチ1] 正規化RDB設計（第3正規形）"
echo "============================================================"
echo ""

docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
-- 顧客テーブル
CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 商品テーブル
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price INTEGER NOT NULL,
  category TEXT NOT NULL
);

-- 注文テーブル
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id),
  status TEXT NOT NULL DEFAULT 'created',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 注文明細テーブル
CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL,
  unit_price INTEGER NOT NULL
);

-- テストデータ投入
INSERT INTO customers (name, email) VALUES
('田中太郎', 'tanaka@example.com'),
('鈴木花子', 'suzuki@example.com'),
('佐藤次郎', 'sato@example.com');

INSERT INTO products (name, price, category) VALUES
('PostgreSQL入門書', 3200, '書籍'),
('DuckDBハンドブック', 2800, '書籍'),
('SQLマスターコース', 15000, 'オンライン講座'),
('DB設計パターン集', 3800, '書籍');

INSERT INTO orders (customer_id, status, created_at) VALUES
(1, 'completed', '2024-11-01 10:00:00'),
(1, 'shipped',   '2024-12-15 14:30:00'),
(2, 'completed', '2024-11-20 09:00:00'),
(3, 'paid',      '2025-01-05 16:00:00');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 3200), (1, 2, 1, 2800),
(2, 3, 1, 15000),
(3, 1, 2, 3200), (3, 4, 1, 3800),
(4, 2, 1, 2800), (4, 3, 1, 15000);
SQL

echo ""
echo "正規化RDB設計のデータ投入完了"
echo ""

# 注文一覧クエリ
echo "[クエリ] 注文一覧（3テーブルJOIN）"
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
SELECT
  o.id AS order_id,
  c.name AS customer_name,
  o.status,
  p.name AS product_name,
  oi.quantity,
  oi.unit_price * oi.quantity AS subtotal,
  o.created_at
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON oi.product_id = p.id
ORDER BY o.created_at DESC;
SQL

echo ""

# 集計クエリ
echo "[クエリ] 顧客別の累計購入金額"
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
SELECT
  c.name AS customer_name,
  COUNT(DISTINCT o.id) AS order_count,
  SUM(oi.unit_price * oi.quantity) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
GROUP BY c.id, c.name
ORDER BY total_spent DESC;
SQL

echo ""

# =============================================================================
# アプローチ2: 非正規化ドキュメント設計
# =============================================================================
echo "============================================================"
echo "[アプローチ2] 非正規化ドキュメント設計（JSONB）"
echo "============================================================"
echo ""

docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
CREATE TABLE order_documents (
  id SERIAL PRIMARY KEY,
  data JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO order_documents (data, created_at) VALUES
('{"order_id": 1, "customer": {"id": 1, "name": "田中太郎", "email": "tanaka@example.com"}, "status": "completed", "items": [{"product_id": 1, "name": "PostgreSQL入門書", "category": "書籍", "quantity": 1, "unit_price": 3200}, {"product_id": 2, "name": "DuckDBハンドブック", "category": "書籍", "quantity": 1, "unit_price": 2800}], "total": 6000}'::jsonb, '2024-11-01 10:00:00'),
('{"order_id": 2, "customer": {"id": 1, "name": "田中太郎", "email": "tanaka@example.com"}, "status": "shipped", "items": [{"product_id": 3, "name": "SQLマスターコース", "category": "オンライン講座", "quantity": 1, "unit_price": 15000}], "total": 15000}'::jsonb, '2024-12-15 14:30:00'),
('{"order_id": 3, "customer": {"id": 2, "name": "鈴木花子", "email": "suzuki@example.com"}, "status": "completed", "items": [{"product_id": 1, "name": "PostgreSQL入門書", "category": "書籍", "quantity": 2, "unit_price": 3200}, {"product_id": 4, "name": "DB設計パターン集", "category": "書籍", "quantity": 1, "unit_price": 3800}], "total": 10200}'::jsonb, '2024-11-20 09:00:00'),
('{"order_id": 4, "customer": {"id": 3, "name": "佐藤次郎", "email": "sato@example.com"}, "status": "paid", "items": [{"product_id": 2, "name": "DuckDBハンドブック", "category": "書籍", "quantity": 1, "unit_price": 2800}, {"product_id": 3, "name": "SQLマスターコース", "category": "オンライン講座", "quantity": 1, "unit_price": 15000}], "total": 17800}'::jsonb, '2025-01-05 16:00:00');
SQL

echo ""
echo "非正規化ドキュメント設計のデータ投入完了"
echo ""

# 注文一覧クエリ
echo "[クエリ] 注文一覧（JOINなし）"
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
SELECT
  data->>'order_id' AS order_id,
  data->'customer'->>'name' AS customer_name,
  data->>'status' AS status,
  (data->>'total')::integer AS total,
  created_at
FROM order_documents
ORDER BY created_at DESC;
SQL

echo ""

# 集計クエリ
echo "[クエリ] 顧客別の累計購入金額（JOINなし）"
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
SELECT
  data->'customer'->>'name' AS customer_name,
  COUNT(*) AS order_count,
  SUM((data->>'total')::integer) AS total_spent
FROM order_documents
GROUP BY data->'customer'->>'id', data->'customer'->>'name'
ORDER BY total_spent DESC;
SQL

echo ""

# =============================================================================
# アプローチ3: イベントソーシング設計
# =============================================================================
echo "============================================================"
echo "[アプローチ3] イベントソーシング設計"
echo "============================================================"
echo ""

docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
CREATE TABLE event_store (
  id SERIAL PRIMARY KEY,
  stream_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  event_data JSONB NOT NULL,
  version INTEGER NOT NULL,
  occurred_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(stream_id, version)
);

-- 注文1のイベント列
INSERT INTO event_store (stream_id, event_type, event_data, version, occurred_at) VALUES
('order-1', 'OrderCreated', '{"customer_id": 1, "customer_name": "田中太郎"}'::jsonb, 1, '2024-11-01 10:00:00'),
('order-1', 'ItemAdded', '{"product_id": 1, "name": "PostgreSQL入門書", "quantity": 1, "unit_price": 3200}'::jsonb, 2, '2024-11-01 10:00:01'),
('order-1', 'ItemAdded', '{"product_id": 2, "name": "DuckDBハンドブック", "quantity": 1, "unit_price": 2800}'::jsonb, 3, '2024-11-01 10:00:02'),
('order-1', 'OrderPaid', '{"amount": 6000, "method": "credit_card"}'::jsonb, 4, '2024-11-01 10:30:00'),
('order-1', 'OrderShipped', '{"tracking_number": "JP1234567890"}'::jsonb, 5, '2024-11-03 09:00:00'),
('order-1', 'OrderCompleted', '{}'::jsonb, 6, '2024-11-05 14:00:00');

-- 注文2のイベント列
INSERT INTO event_store (stream_id, event_type, event_data, version, occurred_at) VALUES
('order-2', 'OrderCreated', '{"customer_id": 1, "customer_name": "田中太郎"}'::jsonb, 1, '2024-12-15 14:30:00'),
('order-2', 'ItemAdded', '{"product_id": 3, "name": "SQLマスターコース", "quantity": 1, "unit_price": 15000}'::jsonb, 2, '2024-12-15 14:30:01'),
('order-2', 'OrderPaid', '{"amount": 15000, "method": "bank_transfer"}'::jsonb, 3, '2024-12-16 10:00:00'),
('order-2', 'OrderShipped', '{"tracking_number": "JP9876543210"}'::jsonb, 4, '2024-12-18 09:00:00');

-- 注文3のイベント列
INSERT INTO event_store (stream_id, event_type, event_data, version, occurred_at) VALUES
('order-3', 'OrderCreated', '{"customer_id": 2, "customer_name": "鈴木花子"}'::jsonb, 1, '2024-11-20 09:00:00'),
('order-3', 'ItemAdded', '{"product_id": 1, "name": "PostgreSQL入門書", "quantity": 2, "unit_price": 3200}'::jsonb, 2, '2024-11-20 09:00:01'),
('order-3', 'ItemAdded', '{"product_id": 4, "name": "DB設計パターン集", "quantity": 1, "unit_price": 3800}'::jsonb, 3, '2024-11-20 09:00:02'),
('order-3', 'OrderPaid', '{"amount": 10200, "method": "credit_card"}'::jsonb, 4, '2024-11-20 10:00:00'),
('order-3', 'OrderShipped', '{"tracking_number": "JP1111111111"}'::jsonb, 5, '2024-11-22 09:00:00'),
('order-3', 'OrderCompleted', '{}'::jsonb, 6, '2024-11-25 12:00:00');
SQL

echo ""
echo "イベントソーシング設計のデータ投入完了"
echo ""

# イベントから状態を再構築
echo "[クエリ] イベント再生による現在の状態の導出"
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
WITH latest_status AS (
  SELECT DISTINCT ON (stream_id)
    stream_id, event_type, occurred_at
  FROM event_store
  WHERE event_type IN ('OrderCreated', 'OrderPaid', 'OrderShipped', 'OrderCompleted')
  ORDER BY stream_id, version DESC
),
order_customers AS (
  SELECT stream_id, event_data->>'customer_name' AS customer_name
  FROM event_store
  WHERE event_type = 'OrderCreated'
),
order_items AS (
  SELECT
    stream_id,
    jsonb_agg(jsonb_build_object(
      'name', event_data->>'name',
      'quantity', (event_data->>'quantity')::integer,
      'unit_price', (event_data->>'unit_price')::integer
    )) AS items,
    SUM((event_data->>'quantity')::integer * (event_data->>'unit_price')::integer) AS total
  FROM event_store
  WHERE event_type = 'ItemAdded'
  GROUP BY stream_id
)
SELECT
  ls.stream_id,
  oc.customer_name,
  CASE ls.event_type
    WHEN 'OrderCreated' THEN 'created'
    WHEN 'OrderPaid' THEN 'paid'
    WHEN 'OrderShipped' THEN 'shipped'
    WHEN 'OrderCompleted' THEN 'completed'
  END AS status,
  oi.items,
  oi.total,
  ls.occurred_at AS last_updated
FROM latest_status ls
JOIN order_customers oc ON oc.stream_id = ls.stream_id
JOIN order_items oi ON oi.stream_id = ls.stream_id
ORDER BY ls.stream_id;
SQL

echo ""

# 任意時点の状態再現
echo "[クエリ] 注文1の支払い完了時点（配送前）の状態"
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
SELECT stream_id, event_type, event_data, occurred_at
FROM event_store
WHERE stream_id = 'order-1'
  AND occurred_at <= '2024-11-01 10:30:00'
ORDER BY version;
SQL

echo ""
echo "============================================================"
echo "全演習が完了しました"
echo ""
echo "後片付け:"
echo "  docker stop pg-normalized && docker rm pg-normalized"
echo "============================================================"
