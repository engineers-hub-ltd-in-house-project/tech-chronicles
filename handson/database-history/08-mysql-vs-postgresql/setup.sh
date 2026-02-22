#!/bin/bash
# =============================================================================
# 第8回ハンズオン：MySQLとPostgreSQLの特性を比較する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: Docker（MySQL 8.0 および PostgreSQL 17 公式イメージを使用）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-08"
MYSQL_CONTAINER="db-history-ep08-mysql"
PG_CONTAINER="db-history-ep08-pg"

echo "=== 第8回ハンズオン：MySQLとPostgreSQLの特性を比較する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- 既存コンテナの停止・削除 ---
for CONTAINER in "${MYSQL_CONTAINER}" "${PG_CONTAINER}"; do
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
        echo "既存コンテナ ${CONTAINER} を停止・削除しています..."
        docker rm -f "${CONTAINER}" > /dev/null 2>&1
    fi
done

# --- MySQLコンテナの起動 ---
echo "[Step 1] MySQLコンテナを起動しています..."
docker run -d \
    --name "${MYSQL_CONTAINER}" \
    -e MYSQL_ROOT_PASSWORD=handson \
    -e MYSQL_DATABASE=handson \
    mysql:8.0 \
    --default-authentication-plugin=mysql_native_password > /dev/null

# --- PostgreSQLコンテナの起動 ---
echo "[Step 2] PostgreSQLコンテナを起動しています..."
docker run -d \
    --name "${PG_CONTAINER}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    postgres:17 > /dev/null

# --- 起動待ち（MySQL） ---
echo "MySQLの起動を待っています..."
for i in $(seq 1 60); do
    if docker exec "${MYSQL_CONTAINER}" mysqladmin ping -u root -phandson --silent > /dev/null 2>&1; then
        echo "MySQLが起動しました。"
        break
    fi
    if [ "$i" -eq 60 ]; then
        echo "ERROR: MySQLの起動がタイムアウトしました。"
        exit 1
    fi
    sleep 1
done

# --- 起動待ち（PostgreSQL） ---
echo "PostgreSQLの起動を待っています..."
for i in $(seq 1 30); do
    if docker exec "${PG_CONTAINER}" pg_isready -U postgres > /dev/null 2>&1; then
        echo "PostgreSQLが起動しました。"
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "ERROR: PostgreSQLの起動がタイムアウトしました。"
        exit 1
    fi
    sleep 1
done

# --- MySQLテストデータの投入 ---
echo ""
echo "[Step 3] MySQLにテストデータを投入しています..."

cat > "${WORKDIR}/mysql_setup.sql" << 'SQLEOF'
-- =============================================================================
-- 第8回ハンズオン: MySQL テストデータのセットアップ
-- =============================================================================

-- 型テスト用テーブル
CREATE TABLE test_types (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date_col DATE,
    int_col INT,
    varchar_col VARCHAR(100)
);

-- ユーザーテーブル
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 注文テーブル（外部キー制約付き — InnoDBで有効）
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product VARCHAR(100) NOT NULL,
    amount INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- ベンチマーク用テーブル
CREATE TABLE bench_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    key_col VARCHAR(50) NOT NULL,
    value_col TEXT,
    num_col INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_key (key_col),
    INDEX idx_num (num_col)
);

-- ユーザーデータの投入（1,000件）
DELIMITER //
CREATE PROCEDURE generate_users()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 1000 DO
        INSERT INTO users (username, email)
        VALUES (
            CONCAT('user_', LPAD(i, 5, '0')),
            CONCAT('user_', LPAD(i, 5, '0'), '@example.com')
        );
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;
CALL generate_users();
DROP PROCEDURE generate_users;

-- 注文データの投入（100,000件）
DELIMITER //
CREATE PROCEDURE generate_orders()
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= 100000 DO
        INSERT INTO orders (user_id, product, amount)
        VALUES (
            FLOOR(1 + RAND() * 1000),
            CONCAT('Product_', LPAD(FLOOR(1 + RAND() * 500), 3, '0')),
            FLOOR(100 + RAND() * 99900)
        );
        SET i = i + 1;
    END WHILE;
END //
DELIMITER ;
CALL generate_orders();
DROP PROCEDURE generate_orders;

-- ベンチマーク用INSERT関数
DELIMITER //
CREATE PROCEDURE benchmark_insert(IN num_rows INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time DATETIME(6);
    SET start_time = NOW(6);

    START TRANSACTION;
    WHILE i <= num_rows DO
        INSERT INTO bench_data (key_col, value_col, num_col)
        VALUES (
            CONCAT('key_', LPAD(i, 8, '0')),
            CONCAT('value_', REPEAT('x', 50)),
            FLOOR(RAND() * 1000000)
        );
        SET i = i + 1;
    END WHILE;
    COMMIT;

    SELECT CONCAT(
        num_rows, ' rows inserted in ',
        TIMESTAMPDIFF(MICROSECOND, start_time, NOW(6)) / 1000000.0,
        ' seconds'
    ) AS result;
END //
DELIMITER ;

ANALYZE TABLE users;
ANALYZE TABLE orders;
SQLEOF

docker cp "${WORKDIR}/mysql_setup.sql" "${MYSQL_CONTAINER}:/tmp/mysql_setup.sql"
docker exec "${MYSQL_CONTAINER}" mysql -u root -phandson handson -e "SOURCE /tmp/mysql_setup.sql" 2>/dev/null

echo "MySQLのテストデータ投入が完了しました。"

# --- PostgreSQLテストデータの投入 ---
echo ""
echo "[Step 4] PostgreSQLにテストデータを投入しています..."

cat > "${WORKDIR}/pg_setup.sql" << 'SQLEOF'
-- =============================================================================
-- 第8回ハンズオン: PostgreSQL テストデータのセットアップ
-- =============================================================================

-- 型テスト用テーブル
CREATE TABLE test_types (
    id SERIAL PRIMARY KEY,
    date_col DATE,
    int_col INT,
    varchar_col VARCHAR(100)
);

-- ユーザーテーブル
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 注文テーブル（外部キー制約付き）
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    product VARCHAR(100) NOT NULL,
    amount INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ベンチマーク用テーブル
CREATE TABLE bench_data (
    id SERIAL PRIMARY KEY,
    key_col VARCHAR(50) NOT NULL,
    value_col TEXT,
    num_col INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_key ON bench_data(key_col);
CREATE INDEX idx_num ON bench_data(num_col);

-- ユーザーデータの投入（1,000件）
INSERT INTO users (username, email)
SELECT
    'user_' || LPAD(g::text, 5, '0'),
    'user_' || LPAD(g::text, 5, '0') || '@example.com'
FROM generate_series(1, 1000) AS g;

-- 注文データの投入（100,000件）
INSERT INTO orders (user_id, product, amount)
SELECT
    1 + (random() * 999)::int,
    'Product_' || LPAD((1 + (random() * 499)::int)::text, 3, '0'),
    100 + (random() * 99900)::int
FROM generate_series(1, 100000);

-- ベンチマーク用INSERT関数
CREATE OR REPLACE FUNCTION benchmark_insert(num_rows INT)
RETURNS TEXT AS $$
DECLARE
    i INT := 1;
    start_time TIMESTAMP;
    elapsed NUMERIC;
BEGIN
    start_time := clock_timestamp();

    WHILE i <= num_rows LOOP
        INSERT INTO bench_data (key_col, value_col, num_col)
        VALUES (
            'key_' || LPAD(i::text, 8, '0'),
            'value_' || repeat('x', 50),
            (random() * 1000000)::int
        );
        i := i + 1;
    END LOOP;

    elapsed := EXTRACT(EPOCH FROM (clock_timestamp() - start_time));
    RETURN num_rows || ' rows inserted in ' || elapsed || ' seconds';
END;
$$ LANGUAGE plpgsql;

ANALYZE users;
ANALYZE orders;
SQLEOF

docker cp "${WORKDIR}/pg_setup.sql" "${PG_CONTAINER}:/tmp/pg_setup.sql"
docker exec "${PG_CONTAINER}" psql -U postgres -d handson -f /tmp/pg_setup.sql > /dev/null

echo "PostgreSQLのテストデータ投入が完了しました。"

# --- 完了メッセージ ---
echo ""
echo "============================================================"
echo "セットアップが完了しました。"
echo "============================================================"
echo ""
echo "MySQL に接続:"
echo "  docker exec -it ${MYSQL_CONTAINER} mysql -u root -phandson handson"
echo ""
echo "PostgreSQL に接続:"
echo "  docker exec -it ${PG_CONTAINER} psql -U postgres -d handson"
echo ""
echo "--- 演習1: 型の厳密性の違い ---"
echo "MySQL:      SELECT 'abc' + 1;        -- → 1（エラーにならない）"
echo "PostgreSQL: SELECT 'abc' + 1;        -- → ERROR"
echo ""
echo "--- 演習2: 外部キー制約 ---"
echo "MySQL/PG:   INSERT INTO orders (user_id, product, amount)"
echo "            VALUES (9999, 'Widget', 1000);"
echo "            -- 両方ともエラー（InnoDBの場合）"
echo ""
echo "--- 演習3: ワークロード比較 ---"
echo "MySQL:      CALL benchmark_insert(10000);"
echo "PostgreSQL: SELECT benchmark_insert(10000);"
echo ""
echo "コンテナの停止・削除:"
echo "  docker rm -f ${MYSQL_CONTAINER} ${PG_CONTAINER}"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
