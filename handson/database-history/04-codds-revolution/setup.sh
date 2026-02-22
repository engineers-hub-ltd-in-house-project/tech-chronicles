#!/bin/bash
# =============================================================================
# 第4回ハンズオン：関係代数と正規化を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: sqlite3 (apt-get install -y sqlite3)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-04"

echo "=== 第4回ハンズオン：関係代数と正規化を体験する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- 演習1: 関係代数の基本操作をSQLで再現する ---
echo "[演習1] 関係代数の基本操作をSQLで再現する"
echo ""

cat > "${WORKDIR}/relational_algebra.sql" << 'SQLEOF'
-- relational_algebra.sql -- 関係代数の基本操作をSQLで体験する

CREATE TABLE employees (
    emp_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    dept_code TEXT NOT NULL,
    salary INTEGER NOT NULL
);

CREATE TABLE departments (
    dept_code TEXT PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT NOT NULL
);

INSERT INTO employees VALUES ('E001', 'Tanaka', 'D01', 500000);
INSERT INTO employees VALUES ('E002', 'Suzuki', 'D02', 600000);
INSERT INTO employees VALUES ('E003', 'Sato', 'D01', 450000);
INSERT INTO employees VALUES ('E004', 'Yamada', 'D03', 550000);

INSERT INTO departments VALUES ('D01', 'Sales', 'Tokyo');
INSERT INTO departments VALUES ('D02', 'Engineering', 'Osaka');
INSERT INTO departments VALUES ('D03', 'Marketing', 'Tokyo');

-- === 選択 (Selection): σ(dept_code='D01')(employees) ===
.print '=== 選択 (Selection): dept_code = D01 ==='
SELECT * FROM employees WHERE dept_code = 'D01';

-- === 射影 (Projection): π(name, salary)(employees) ===
.print ''
.print '=== 射影 (Projection): name, salary ==='
SELECT DISTINCT name, salary FROM employees;

-- === 結合 (Join): employees ⋈ departments ===
.print ''
.print '=== 結合 (Join): employees JOIN departments ==='
SELECT e.emp_id, e.name, d.dept_name, d.location
FROM employees e
JOIN departments d ON e.dept_code = d.dept_code;

-- === 選択 + 射影 + 結合の組み合わせ ===
.print ''
.print '=== 組み合わせ: 東京の部署の社員名と部署名 ==='
.print '関係代数: π(name, dept_name)(σ(location=Tokyo)(employees ⋈ departments))'
SELECT e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_code = d.dept_code
WHERE d.location = 'Tokyo';

-- === 和 (Union) ===
CREATE TABLE former_employees (
    emp_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    dept_code TEXT NOT NULL,
    salary INTEGER NOT NULL
);
INSERT INTO former_employees VALUES ('E005', 'Ito', 'D01', 480000);
INSERT INTO former_employees VALUES ('E006', 'Watanabe', 'D02', 520000);

.print ''
.print '=== 和 (Union): 現社員 ∪ 元社員 ==='
SELECT emp_id, name FROM employees
UNION
SELECT emp_id, name FROM former_employees;

-- === 差 (Difference) ===
.print ''
.print '=== 差 (Difference): 社員が所属していない部署 ==='
SELECT dept_code FROM departments
EXCEPT
SELECT DISTINCT dept_code FROM employees;

.print ''
.print '注目: すべての操作が「何がほしいか」の宣言だけで完結している。'
.print '「どのインデックスを使うか」「どの順序で走査するか」は一切書いていない。'
.print 'これがCoddが実現した「データの論理的独立性」の恩恵だ。'
SQLEOF

sqlite3 :memory: < "${WORKDIR}/relational_algebra.sql"

echo ""
echo "---"
echo ""

# --- 演習2: 非正規化テーブルで更新異常を体験する ---
echo "[演習2] 非正規化テーブルで更新異常を体験する"
echo ""

cat > "${WORKDIR}/update_anomalies.sql" << 'SQLEOF'
-- update_anomalies.sql -- 更新異常を実際に発生させる

CREATE TABLE orders_denormalized (
    order_id TEXT,
    customer_name TEXT,
    customer_address TEXT,
    product_name TEXT,
    unit_price INTEGER,
    quantity INTEGER
);

INSERT INTO orders_denormalized VALUES ('001', 'Yamada Corp', 'Tokyo Minato', 'Bolt-A', 100, 50);
INSERT INTO orders_denormalized VALUES ('001', 'Yamada Corp', 'Tokyo Minato', 'Nut-B', 50, 100);
INSERT INTO orders_denormalized VALUES ('002', 'Suzuki Inc', 'Osaka Kita', 'Bolt-A', 100, 200);
INSERT INTO orders_denormalized VALUES ('003', 'Yamada Corp', 'Tokyo Minato', 'Washer-C', 30, 500);

.print '=== 非正規化テーブルの初期状態 ==='
.headers on
.mode column
SELECT * FROM orders_denormalized;

-- 更新異常: 1箇所だけ更新
.print ''
.print '=== 更新異常: Yamada Corpの住所を1箇所だけ更新 ==='
UPDATE orders_denormalized
SET customer_address = 'Tokyo Chiyoda'
WHERE order_id = '001' AND product_name = 'Bolt-A';

SELECT order_id, customer_name, customer_address, product_name
FROM orders_denormalized
WHERE customer_name = 'Yamada Corp';

.print ''
.print '>>> 同じ顧客の住所が行によって異なる！これが更新異常だ。'

-- 挿入異常
.print ''
.print '=== 挿入異常: 受注なしの新商品を登録できない ==='
.print '商品 Pin-D (単価 20) を登録したいが、'
.print 'order_id も customer_name も存在しない商品は挿入できない。'
.print '受注と無関係に商品マスタを管理する手段がない。'

-- 削除異常
.print ''
.print '=== 削除異常: 受注002を削除 ==='
DELETE FROM orders_denormalized WHERE order_id = '002';

.print 'Suzuki Incの情報を検索:'
SELECT * FROM orders_denormalized WHERE customer_name = 'Suzuki Inc';
.print '>>> Suzuki Incの顧客情報が完全に消失した。これが削除異常だ。'
SQLEOF

sqlite3 :memory: < "${WORKDIR}/update_anomalies.sql"

echo ""
echo "---"
echo ""

# --- 演習3: 正規化による異常の解消 ---
echo "[演習3] 正規化（3NF）による異常の解消"
echo ""

cat > "${WORKDIR}/normalization.sql" << 'SQLEOF'
-- normalization.sql -- 正規化の各段階で異常を解消する

CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    customer_address TEXT NOT NULL
);

CREATE TABLE products (
    product_id TEXT PRIMARY KEY,
    product_name TEXT NOT NULL,
    unit_price INTEGER NOT NULL
);

CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES customers(customer_id),
    order_date TEXT NOT NULL
);

CREATE TABLE order_items (
    order_id TEXT REFERENCES orders(order_id),
    product_id TEXT REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO customers VALUES ('C001', 'Yamada Corp', 'Tokyo Minato');
INSERT INTO customers VALUES ('C002', 'Suzuki Inc', 'Osaka Kita');

INSERT INTO products VALUES ('P001', 'Bolt-A', 100);
INSERT INTO products VALUES ('P002', 'Nut-B', 50);
INSERT INTO products VALUES ('P003', 'Washer-C', 30);

INSERT INTO orders VALUES ('001', 'C001', '2024-01-15');
INSERT INTO orders VALUES ('002', 'C002', '2024-01-20');
INSERT INTO orders VALUES ('003', 'C001', '2024-01-25');

INSERT INTO order_items VALUES ('001', 'P001', 50);
INSERT INTO order_items VALUES ('001', 'P002', 100);
INSERT INTO order_items VALUES ('002', 'P001', 200);
INSERT INTO order_items VALUES ('003', 'P003', 500);

.headers on
.mode column

-- 更新異常の解消
.print '=== 更新異常の解消: 顧客住所を1箇所だけ更新 ==='
UPDATE customers SET customer_address = 'Tokyo Chiyoda' WHERE customer_id = 'C001';

SELECT o.order_id, c.customer_name, c.customer_address
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_name = 'Yamada Corp';

.print ''
.print '>>> すべての受注で住所が一貫して更新された。データの重複がないからだ。'

-- 挿入異常の解消
.print ''
.print '=== 挿入異常の解消: 受注なしで新商品を登録 ==='
INSERT INTO products VALUES ('P004', 'Pin-D', 20);
SELECT * FROM products WHERE product_id = 'P004';
.print '>>> 受注と無関係に商品マスタを管理できる。'

-- 削除異常の解消
.print ''
.print '=== 削除異常の解消: 受注002を削除 ==='
DELETE FROM order_items WHERE order_id = '002';
DELETE FROM orders WHERE order_id = '002';

.print 'Suzuki Incの情報を検索:'
SELECT * FROM customers WHERE customer_name = 'Suzuki Inc';
.print '>>> 受注を削除しても顧客情報は独立して保持される。'

-- JOINによる元のビューの再構成
.print ''
.print '=== JOINで元の一覧を再構成 ==='
SELECT o.order_id, c.customer_name, c.customer_address,
       p.product_name, p.unit_price, oi.quantity
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id;

.print ''
.print '>>> 正規化によってテーブルは分割されたが、JOINによって'
.print '>>> いつでも元の一覧を再構成できる。これが関係代数の閉包性の恩恵だ。'
SQLEOF

sqlite3 :memory: < "${WORKDIR}/normalization.sql"

echo ""
echo "=== 全演習完了 ==="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "  relational_algebra.sql -- 関係代数の基本操作"
echo "  update_anomalies.sql   -- 更新異常の体験"
echo "  normalization.sql      -- 正規化による異常の解消"
echo ""
echo "各SQLファイルを個別に実行するには:"
echo "  sqlite3 :memory: < ${WORKDIR}/relational_algebra.sql"
