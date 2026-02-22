#!/bin/bash
# =============================================================================
# 第9回ハンズオン：ストアドプロシージャとアプリケーションコードの比較
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: Docker（PostgreSQL 17 公式イメージを使用）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-09"
PG_CONTAINER="db-history-ep09-pg"

echo "=== 第9回ハンズオン：ストアドプロシージャとアプリケーションコードの比較 ==="
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
    email VARCHAR(200) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 商品テーブル
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 在庫テーブル
CREATE TABLE inventory (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id),
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT positive_stock CHECK (stock_quantity >= 0)
);

-- 注文テーブル
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'confirmed',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 注文の監査ログテーブル
CREATE TABLE orders_audit (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    changed_at TIMESTAMP DEFAULT NOW(),
    operation VARCHAR(10) NOT NULL,
    old_quantity INTEGER,
    new_quantity INTEGER,
    old_amount NUMERIC(10, 2),
    new_amount NUMERIC(10, 2),
    changed_by VARCHAR(100) DEFAULT current_user
);

-- 在庫変更ログテーブル
CREATE TABLE inventory_log (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    old_quantity INTEGER,
    new_quantity INTEGER,
    changed_at TIMESTAMP DEFAULT NOW(),
    changed_by VARCHAR(100) DEFAULT current_user
);

SQL

echo "テーブルを作成しました。"

# --- テストデータの投入 ---
echo ""
echo "[Step 3] テストデータを投入しています..."

docker exec -i "${PG_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- === テストデータ ===

-- 顧客データ
INSERT INTO customers (name, email) VALUES
    ('田中太郎', 'tanaka@example.com'),
    ('佐藤花子', 'sato@example.com'),
    ('鈴木一郎', 'suzuki@example.com');

-- 商品データ
INSERT INTO products (name, price) VALUES
    ('ノートPC', 98000.00),
    ('キーボード', 12000.00),
    ('マウス', 3500.00),
    ('モニター', 45000.00),
    ('USBハブ', 2800.00);

-- 在庫データ
INSERT INTO inventory (product_id, stock_quantity) VALUES
    (1, 50),
    (2, 200),
    (3, 500),
    (4, 30),
    (5, 1000);

SQL

echo "テストデータを投入しました。"

# --- ストアドプロシージャの作成 ---
echo ""
echo "[Step 4] ストアドプロシージャを作成しています..."

docker exec -i "${PG_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- === ストアドプロシージャ: 受注処理 ===
CREATE OR REPLACE FUNCTION process_order(
    p_customer_id INTEGER,
    p_product_id INTEGER,
    p_quantity INTEGER
) RETURNS INTEGER AS $$
DECLARE
    v_stock INTEGER;
    v_price NUMERIC(10, 2);
    v_order_id INTEGER;
BEGIN
    -- Step 1: 在庫を確認（行ロック取得）
    SELECT stock_quantity INTO v_stock
    FROM inventory
    WHERE product_id = p_product_id
    FOR UPDATE;

    IF v_stock IS NULL THEN
        RAISE EXCEPTION 'Product % not found in inventory', p_product_id;
    END IF;

    -- Step 2: 在庫チェック
    IF v_stock < p_quantity THEN
        RAISE EXCEPTION 'Insufficient stock for product %: requested %, available %',
            p_product_id, p_quantity, v_stock;
    END IF;

    -- Step 3: 商品価格の取得
    SELECT price INTO v_price
    FROM products
    WHERE id = p_product_id;

    -- Step 4: 在庫を減らす
    UPDATE inventory
    SET stock_quantity = stock_quantity - p_quantity,
        updated_at = NOW()
    WHERE product_id = p_product_id;

    -- Step 5: 受注レコードを作成
    INSERT INTO orders (customer_id, product_id, quantity, total_price)
    VALUES (p_customer_id, p_product_id, p_quantity, v_price * p_quantity)
    RETURNING id INTO v_order_id;

    RETURN v_order_id;
END;
$$ LANGUAGE plpgsql;

-- === ストアドプロシージャ: ベンチマーク（SP版） ===
CREATE OR REPLACE FUNCTION benchmark_sp_orders(p_count INTEGER)
RETURNS TEXT AS $$
DECLARE
    v_start TIMESTAMP;
    v_end TIMESTAMP;
    v_i INTEGER;
    v_customer_id INTEGER;
    v_product_id INTEGER;
BEGIN
    v_start := clock_timestamp();

    FOR v_i IN 1..p_count LOOP
        v_customer_id := (v_i % 3) + 1;
        v_product_id := 5;  -- USBハブ（在庫1000）
        PERFORM process_order(v_customer_id, v_product_id, 1);
    END LOOP;

    v_end := clock_timestamp();

    RETURN format('SP version: %s orders in %s ms',
        p_count,
        EXTRACT(MILLISECOND FROM (v_end - v_start))::INTEGER);
END;
$$ LANGUAGE plpgsql;

-- === ストアドプロシージャ: ベンチマーク（個別SQL版） ===
CREATE OR REPLACE FUNCTION benchmark_individual_orders(p_count INTEGER)
RETURNS TEXT AS $$
DECLARE
    v_start TIMESTAMP;
    v_end TIMESTAMP;
    v_i INTEGER;
    v_customer_id INTEGER;
    v_product_id INTEGER;
    v_stock INTEGER;
    v_price NUMERIC(10, 2);
BEGIN
    v_start := clock_timestamp();

    FOR v_i IN 1..p_count LOOP
        v_customer_id := (v_i % 3) + 1;
        v_product_id := 5;

        -- 個別のSQLステートメントとして実行
        SELECT stock_quantity INTO v_stock
        FROM inventory
        WHERE product_id = v_product_id
        FOR UPDATE;

        SELECT price INTO v_price
        FROM products
        WHERE id = v_product_id;

        UPDATE inventory
        SET stock_quantity = stock_quantity - 1,
            updated_at = NOW()
        WHERE product_id = v_product_id;

        INSERT INTO orders (customer_id, product_id, quantity, total_price)
        VALUES (v_customer_id, v_product_id, 1, v_price);
    END LOOP;

    v_end := clock_timestamp();

    RETURN format('Individual SQL version: %s orders in %s ms',
        p_count,
        EXTRACT(MILLISECOND FROM (v_end - v_start))::INTEGER);
END;
$$ LANGUAGE plpgsql;

SQL

echo "ストアドプロシージャを作成しました。"

# --- トリガーの作成 ---
echo ""
echo "[Step 5] トリガーを作成しています..."

docker exec -i "${PG_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- === トリガー: 注文の監査ログ ===
CREATE OR REPLACE FUNCTION audit_orders_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO orders_audit (
            order_id, operation,
            old_quantity, new_quantity,
            old_amount, new_amount
        ) VALUES (
            NEW.id, 'INSERT',
            NULL, NEW.quantity,
            NULL, NEW.total_price
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO orders_audit (
            order_id, operation,
            old_quantity, new_quantity,
            old_amount, new_amount
        ) VALUES (
            OLD.id, 'UPDATE',
            OLD.quantity, NEW.quantity,
            OLD.total_price, NEW.total_price
        );
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO orders_audit (
            order_id, operation,
            old_quantity, new_quantity,
            old_amount, new_amount
        ) VALUES (
            OLD.id, 'DELETE',
            OLD.quantity, NULL,
            OLD.total_price, NULL
        );
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER orders_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION audit_orders_changes();

-- === トリガー: 在庫変更ログ ===
CREATE OR REPLACE FUNCTION log_inventory_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO inventory_log (
        product_id, old_quantity, new_quantity
    ) VALUES (
        NEW.product_id, OLD.stock_quantity, NEW.stock_quantity
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER inventory_log_trigger
    AFTER UPDATE ON inventory
    FOR EACH ROW
    EXECUTE FUNCTION log_inventory_changes();

-- === トリガー: 更新日時の自動更新 ===
CREATE OR REPLACE FUNCTION update_modified_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_timestamp();

SQL

echo "トリガーを作成しました。"

# --- 完了メッセージ ---
echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "PostgreSQLに接続するには:"
echo "  docker exec -it ${PG_CONTAINER} psql -U postgres -d handson"
echo ""
echo "演習1: ストアドプロシージャによる受注処理"
echo "  SELECT process_order(1, 1, 5);"
echo ""
echo "演習2: アプリケーション側SQLによる受注処理"
echo "  BEGIN; SELECT ... UPDATE ... INSERT ... COMMIT;"
echo ""
echo "演習3: パフォーマンス比較"
echo "  SELECT benchmark_sp_orders(1000);"
echo "  SELECT benchmark_individual_orders(1000);"
echo ""
echo "演習4: トリガーによる監査ログ"
echo "  UPDATE orders SET quantity = 10 WHERE id = 1;"
echo "  SELECT * FROM orders_audit;"
echo ""
echo "演習5: トリガーの連鎖"
echo "  SELECT process_order(2, 3, 1);"
echo "  SELECT * FROM orders_audit;"
echo "  SELECT * FROM inventory_log;"
echo ""
echo "後片付け:"
echo "  docker rm -f ${PG_CONTAINER}"
