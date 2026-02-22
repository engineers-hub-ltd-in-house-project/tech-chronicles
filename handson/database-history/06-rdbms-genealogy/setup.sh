#!/bin/bash
# =============================================================================
# 第6回ハンズオン：PostgreSQLとMySQLの挙動の違いを体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: Docker（PostgreSQL 17 および MySQL 8.4 公式イメージを使用）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-06"
PG_CONTAINER="db-history-ep06-pg"
MY_CONTAINER="db-history-ep06-mysql"

echo "=== 第6回ハンズオン：PostgreSQLとMySQLの挙動の違いを体験する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- 既存コンテナの停止・削除 ---
for c in "${PG_CONTAINER}" "${MY_CONTAINER}"; do
    if docker ps -a --format '{{.Names}}' | grep -q "^${c}$"; then
        echo "既存コンテナ ${c} を停止・削除しています..."
        docker rm -f "${c}" > /dev/null 2>&1
    fi
done

# --- PostgreSQLコンテナの起動 ---
echo "[Step 1] PostgreSQLコンテナを起動しています..."
docker run -d \
    --name "${PG_CONTAINER}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    postgres:17 > /dev/null

# --- MySQLコンテナの起動 ---
echo "[Step 2] MySQLコンテナを起動しています..."
docker run -d \
    --name "${MY_CONTAINER}" \
    -e MYSQL_ROOT_PASSWORD=handson \
    -e MYSQL_DATABASE=handson \
    mysql:8.4 > /dev/null

# --- 起動待ち ---
echo "データベースの起動を待っています..."
for i in $(seq 1 30); do
    if docker exec "${PG_CONTAINER}" pg_isready -U postgres > /dev/null 2>&1; then
        echo "PostgreSQLが起動しました。"
        break
    fi
    sleep 1
done

for i in $(seq 1 60); do
    if docker exec "${MY_CONTAINER}" mysqladmin ping -h localhost -uroot -phandson --silent > /dev/null 2>&1; then
        echo "MySQLが起動しました。"
        break
    fi
    sleep 1
done

# --- PostgreSQLテストデータの投入 ---
echo ""
echo "[Step 3] PostgreSQLにテストデータを投入しています..."

cat > "${WORKDIR}/pg_setup.sql" << 'SQLEOF'
-- =============================================================================
-- 第6回ハンズオン: PostgreSQL テストデータのセットアップ
-- =============================================================================

CREATE TABLE departments (
    dept_code VARCHAR(10) PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dept_code VARCHAR(10) REFERENCES departments(dept_code),
    salary INTEGER NOT NULL,
    hire_date DATE NOT NULL
);

INSERT INTO departments VALUES
    ('D01', 'Engineering'),
    ('D02', 'Sales'),
    ('D03', 'Marketing'),
    ('D04', 'HR'),
    ('D05', 'Finance');

INSERT INTO employees (name, dept_code, salary, hire_date)
SELECT
    'Employee_' || i,
    'D0' || (1 + (i % 5)),
    300000 + (random() * 500000)::int,
    '2015-01-01'::date + (random() * 3500)::int
FROM generate_series(1, 50000) AS s(i);

ANALYZE departments;
ANALYZE employees;
SQLEOF

docker cp "${WORKDIR}/pg_setup.sql" "${PG_CONTAINER}:/tmp/pg_setup.sql"
docker exec "${PG_CONTAINER}" psql -U postgres -d handson -f /tmp/pg_setup.sql > /dev/null

echo "PostgreSQLのテストデータ投入が完了しました。"

# --- MySQLテストデータの投入 ---
echo ""
echo "[Step 4] MySQLにテストデータを投入しています..."

cat > "${WORKDIR}/my_setup.sql" << 'SQLEOF'
-- =============================================================================
-- 第6回ハンズオン: MySQL テストデータのセットアップ
-- =============================================================================

CREATE TABLE departments (
    dept_code VARCHAR(10) PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    dept_code VARCHAR(10),
    salary INT NOT NULL,
    hire_date DATE NOT NULL,
    FOREIGN KEY (dept_code) REFERENCES departments(dept_code)
) ENGINE=InnoDB;

INSERT INTO departments VALUES
    ('D01', 'Engineering'),
    ('D02', 'Sales'),
    ('D03', 'Marketing'),
    ('D04', 'HR'),
    ('D05', 'Finance');

-- MySQLではgenerate_seriesがないため、再帰CTEで代用
INSERT INTO employees (name, dept_code, salary, hire_date)
WITH RECURSIVE seq AS (
    SELECT 1 AS i
    UNION ALL
    SELECT i + 1 FROM seq WHERE i < 50000
)
SELECT
    CONCAT('Employee_', i),
    CONCAT('D0', 1 + (i % 5)),
    300000 + FLOOR(RAND() * 500000),
    DATE_ADD('2015-01-01', INTERVAL FLOOR(RAND() * 3500) DAY)
FROM seq;

ANALYZE TABLE departments;
ANALYZE TABLE employees;
SQLEOF

docker cp "${WORKDIR}/my_setup.sql" "${MY_CONTAINER}:/tmp/my_setup.sql"
docker exec "${MY_CONTAINER}" mysql -uroot -phandson handson < "${WORKDIR}/my_setup.sql" 2>/dev/null

echo "MySQLのテストデータ投入が完了しました。"

# --- 演習SQLファイルの作成 ---
echo ""
echo "[Step 5] 演習SQLファイルを作成しています..."

# 演習1: 型の厳密さの違い (PostgreSQL)
cat > "${WORKDIR}/exercise1_pg.sql" << 'SQLEOF'
-- =============================================================================
-- 演習1: 型の厳密さの違い (PostgreSQL)
-- =============================================================================

\echo '=== PostgreSQLでの型チェック ==='

CREATE TABLE type_test (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    age INTEGER NOT NULL
);

\echo '正常な挿入:'
INSERT INTO type_test (name, age) VALUES ('Alice', 30);
INSERT INTO type_test (name, age) VALUES ('Bob', '25');
SELECT * FROM type_test;

\echo ''
\echo '不正な型の挿入（エラーになる）:'
\echo 'INSERT INTO type_test (name, age) VALUES (''Charlie'', ''abc'');'
INSERT INTO type_test (name, age) VALUES ('Charlie', 'abc');

DROP TABLE type_test;
SQLEOF

# 演習1: 型の厳密さの違い (MySQL)
cat > "${WORKDIR}/exercise1_my.sql" << 'SQLEOF'
-- =============================================================================
-- 演習1: 型の厳密さの違い (MySQL)
-- =============================================================================

-- STRICT_TRANS_TABLESを無効にして歴史的な振る舞いを再現
SET sql_mode = '';

SELECT '=== MySQLでの型チェック (sql_mode=空) ===' AS message;

CREATE TABLE type_test (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    age INT NOT NULL
);

INSERT INTO type_test (name, age) VALUES ('Alice', 30);
INSERT INTO type_test (name, age) VALUES ('Bob', '25');
INSERT INTO type_test (name, age) VALUES ('Charlie', 'abc');

SELECT '正常な挿入 + 不正な型も受け入れられた:' AS message;
SELECT * FROM type_test;
SELECT '>>> Charlie の age が 0 になっている!' AS message;
SELECT '>>> MySQL のデフォルト(STRICT_TRANS_TABLES有効)ではエラーになる' AS message;

-- 厳格モードに戻す
SET sql_mode = 'STRICT_TRANS_TABLES';
SELECT '=== STRICT_TRANS_TABLES 有効時 ===' AS message;
DELETE FROM type_test WHERE name = 'Charlie';
INSERT INTO type_test (name, age) VALUES ('Dave', 'xyz');

DROP TABLE type_test;
SQLEOF

# 演習2: 文字列比較とNULL (PostgreSQL)
cat > "${WORKDIR}/exercise2_pg.sql" << 'SQLEOF'
-- =============================================================================
-- 演習2: 文字列比較とNULLの挙動 (PostgreSQL)
-- =============================================================================

\echo '=== PostgreSQL: 文字列比較 ==='
SELECT 'abc' = 'ABC' AS case_sensitive_result;
\echo '>>> PostgreSQLはデフォルトでcase-sensitive (false)'

\echo ''
\echo '=== PostgreSQL: 空文字列とNULL ==='
SELECT '' IS NULL AS empty_is_null;
\echo '>>> PostgreSQLでは空文字列とNULLは別物 (false)'

\echo ''
\echo '=== PostgreSQL: 文字列の末尾空白 ==='
SELECT 'abc' = 'abc   ' AS trailing_space;
\echo '>>> PostgreSQLではTEXT型の比較で末尾空白を区別する (false)'
SQLEOF

# 演習2: 文字列比較とNULL (MySQL)
cat > "${WORKDIR}/exercise2_my.sql" << 'SQLEOF'
-- =============================================================================
-- 演習2: 文字列比較とNULLの挙動 (MySQL)
-- =============================================================================

SELECT '=== MySQL: 文字列比較 ===' AS message;
SELECT 'abc' = 'ABC' AS case_sensitive_result;
SELECT '>>> MySQLはデフォルトでcase-insensitive (1=true)' AS message;

SELECT '=== MySQL: 空文字列とNULL ===' AS message;
SELECT '' IS NULL AS empty_is_null;
SELECT '>>> MySQLでも空文字列とNULLは別物 (0=false)' AS message;

SELECT '=== MySQL: 文字列の末尾空白 ===' AS message;
SELECT 'abc' = 'abc   ' AS trailing_space;
SELECT '>>> MySQLのVARCHAR比較では末尾空白を無視する (1=true)' AS message;
SQLEOF

# 演習3: 外部キー制約 (PostgreSQL)
cat > "${WORKDIR}/exercise3_pg.sql" << 'SQLEOF'
-- =============================================================================
-- 演習3: 外部キー制約の振る舞い (PostgreSQL)
-- =============================================================================

\echo '=== PostgreSQL: 外部キー制約違反 ==='
\echo '存在しない部署コード D99 で挿入を試みる:'
INSERT INTO employees (name, dept_code, salary, hire_date)
VALUES ('TestUser', 'D99', 400000, '2024-01-01');

\echo ''
\echo '>>> PostgreSQLは外部キー制約違反をエラーにする'
SQLEOF

# 演習3: 外部キー制約 (MySQL)
cat > "${WORKDIR}/exercise3_my.sql" << 'SQLEOF'
-- =============================================================================
-- 演習3: 外部キー制約の振る舞い (MySQL InnoDB)
-- =============================================================================

SELECT '=== MySQL (InnoDB): 外部キー制約違反 ===' AS message;
SELECT '存在しない部署コード D99 で挿入を試みる:' AS message;
INSERT INTO employees (name, dept_code, salary, hire_date)
VALUES ('TestUser', 'D99', 400000, '2024-01-01');
SQLEOF

# 演習4: EXPLAIN出力の読み比べ (PostgreSQL)
cat > "${WORKDIR}/exercise4_pg.sql" << 'SQLEOF'
-- =============================================================================
-- 演習4: EXPLAIN出力の読み比べ (PostgreSQL)
-- =============================================================================

\echo '=== PostgreSQL: EXPLAIN ANALYZE ==='
EXPLAIN ANALYZE
SELECT e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_code = d.dept_code
WHERE d.dept_name = 'Engineering';

\echo ''
\echo '>>> PostgreSQLはツリー構造で各ノードのコストと実行時間を表示する'
\echo '>>> Hash Join / Nested Loop / Merge Join など結合方式も確認できる'
SQLEOF

# 演習4: EXPLAIN出力の読み比べ (MySQL)
cat > "${WORKDIR}/exercise4_my.sql" << 'SQLEOF'
-- =============================================================================
-- 演習4: EXPLAIN出力の読み比べ (MySQL)
-- =============================================================================

SELECT '=== MySQL: EXPLAIN ===' AS message;
EXPLAIN
SELECT e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_code = d.dept_code
WHERE d.dept_name = 'Engineering';

SELECT '>>> MySQLは表形式でテーブルごとのアクセス方式を表示する' AS message;
SELECT '>>> type列: ALL(フルスキャン), ref(インデックス参照), eq_ref(一意参照)' AS message;
SQLEOF

# ファイルをコンテナにコピー
for f in exercise1_pg.sql exercise2_pg.sql exercise3_pg.sql exercise4_pg.sql; do
    docker cp "${WORKDIR}/${f}" "${PG_CONTAINER}:/tmp/${f}"
done
for f in exercise1_my.sql exercise2_my.sql exercise3_my.sql exercise4_my.sql; do
    docker cp "${WORKDIR}/${f}" "${MY_CONTAINER}:/tmp/${f}"
done

echo "演習SQLファイルの作成が完了しました。"

# --- 演習の自動実行 ---

echo ""
echo "============================================================"
echo "[演習1] 型の厳密さの違い"
echo "============================================================"
echo ""
echo "--- PostgreSQL ---"
docker exec "${PG_CONTAINER}" psql -U postgres -d handson -f /tmp/exercise1_pg.sql 2>&1 || true
echo ""
echo "--- MySQL ---"
docker exec "${MY_CONTAINER}" mysql -uroot -phandson handson < "${WORKDIR}/exercise1_my.sql" 2>&1 || true

echo ""
echo "============================================================"
echo "[演習2] 文字列比較とNULLの挙動"
echo "============================================================"
echo ""
echo "--- PostgreSQL ---"
docker exec "${PG_CONTAINER}" psql -U postgres -d handson -f /tmp/exercise2_pg.sql
echo ""
echo "--- MySQL ---"
docker exec "${MY_CONTAINER}" mysql -uroot -phandson handson < "${WORKDIR}/exercise2_my.sql" 2>/dev/null

echo ""
echo "============================================================"
echo "[演習3] 外部キー制約の振る舞い"
echo "============================================================"
echo ""
echo "--- PostgreSQL ---"
docker exec "${PG_CONTAINER}" psql -U postgres -d handson -f /tmp/exercise3_pg.sql 2>&1 || true
echo ""
echo "--- MySQL (InnoDB) ---"
docker exec "${MY_CONTAINER}" mysql -uroot -phandson handson < "${WORKDIR}/exercise3_my.sql" 2>&1 || true

echo ""
echo "============================================================"
echo "[演習4] EXPLAIN出力の読み比べ"
echo "============================================================"
echo ""
echo "--- PostgreSQL ---"
docker exec "${PG_CONTAINER}" psql -U postgres -d handson -f /tmp/exercise4_pg.sql
echo ""
echo "--- MySQL ---"
docker exec "${MY_CONTAINER}" mysql -uroot -phandson handson < "${WORKDIR}/exercise4_my.sql" 2>/dev/null

# --- 完了メッセージ ---
echo ""
echo "============================================================"
echo "全演習が完了しました。"
echo "============================================================"
echo ""
echo "手動でSQLを試すには:"
echo "  PostgreSQL: docker exec -it ${PG_CONTAINER} psql -U postgres -d handson"
echo "  MySQL:      docker exec -it ${MY_CONTAINER} mysql -uroot -phandson handson"
echo ""
echo "コンテナの停止・削除:"
echo "  docker rm -f ${PG_CONTAINER} ${MY_CONTAINER}"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
