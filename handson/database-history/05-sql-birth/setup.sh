#!/bin/bash
# =============================================================================
# 第5回ハンズオン：SQLの宣言的性質を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: Docker（PostgreSQL 17公式イメージを使用）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-05"
CONTAINER_NAME="db-history-ep05"

echo "=== 第5回ハンズオン：SQLの宣言的性質を体験する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- 既存コンテナの停止・削除 ---
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "既存コンテナを停止・削除しています..."
    docker rm -f "${CONTAINER_NAME}" > /dev/null 2>&1
fi

# --- PostgreSQLコンテナの起動 ---
echo "[Step 1] PostgreSQLコンテナを起動しています..."
docker run -d \
    --name "${CONTAINER_NAME}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    postgres:17 > /dev/null

echo "PostgreSQLの起動を待っています..."
for i in $(seq 1 30); do
    if docker exec "${CONTAINER_NAME}" pg_isready -U postgres > /dev/null 2>&1; then
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
-- 第5回ハンズオン: テストデータのセットアップ
-- =============================================================================

-- テーブル作成
CREATE TABLE departments (
    dept_code TEXT PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT NOT NULL
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    dept_code TEXT NOT NULL REFERENCES departments(dept_code),
    salary INTEGER NOT NULL,
    hire_date DATE NOT NULL
);

-- 部署データ
INSERT INTO departments VALUES
    ('D01', 'Sales', 'Tokyo'),
    ('D02', 'Engineering', 'Osaka'),
    ('D03', 'Marketing', 'Tokyo'),
    ('D04', 'HR', 'Nagoya'),
    ('D05', 'Finance', 'Tokyo');

-- 10万件の従業員データ（オプティマイザの判断を観察するため）
INSERT INTO employees (name, dept_code, salary, hire_date)
SELECT
    'Employee_' || i,
    'D0' || (1 + (i % 5)),
    300000 + (random() * 500000)::int,
    '2010-01-01'::date + (random() * 5000)::int
FROM generate_series(1, 100000) AS s(i);

-- 統計情報の更新
ANALYZE departments;
ANALYZE employees;

-- NULL演習用テーブル
CREATE TABLE test_null (
    id SERIAL PRIMARY KEY,
    value INTEGER
);
INSERT INTO test_null (value) VALUES (10), (20), (NULL), (30), (NULL);
SQLEOF

docker cp "${WORKDIR}/setup.sql" "${CONTAINER_NAME}:/tmp/setup.sql"
docker exec "${CONTAINER_NAME}" psql -U postgres -d handson -f /tmp/setup.sql > /dev/null

echo "テストデータの投入が完了しました。"

# --- 演習SQLファイルの作成 ---
echo ""
echo "[Step 3] 演習SQLファイルを作成しています..."

# 演習1: 同じ結果を返す複数のSQL
cat > "${WORKDIR}/exercise1_optimizer.sql" << 'SQLEOF'
-- =============================================================================
-- 演習1: 同じ結果を返す複数のSQL -- オプティマイザの判断を比較する
-- =============================================================================

\echo '=== クエリA: JOINで書く ==='
EXPLAIN ANALYZE
SELECT e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_code = d.dept_code
WHERE d.location = 'Tokyo';

\echo ''
\echo '=== クエリB: サブクエリで書く ==='
EXPLAIN ANALYZE
SELECT e.name,
       (SELECT d.dept_name FROM departments d WHERE d.dept_code = e.dept_code)
FROM employees e
WHERE e.dept_code IN (SELECT dept_code FROM departments WHERE location = 'Tokyo');

\echo ''
\echo '=== クエリC: EXISTSで書く ==='
EXPLAIN ANALYZE
SELECT e.name,
       (SELECT d.dept_name FROM departments d WHERE d.dept_code = e.dept_code)
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM departments d
    WHERE d.dept_code = e.dept_code AND d.location = 'Tokyo'
);

\echo ''
\echo '>>> 3つのクエリは同じ結果を返すが、実行計画が異なる可能性がある。'
\echo '>>> SQL文には「Hash Joinを使え」とも「Nested Loopを使え」とも書いていない。'
\echo '>>> オプティマイザが自動的に判断した。これがSQLの宣言的性質だ。'
SQLEOF

# 演習2: インデックスとオプティマイザ
cat > "${WORKDIR}/exercise2_index.sql" << 'SQLEOF'
-- =============================================================================
-- 演習2: インデックスでオプティマイザの判断が変わる
-- =============================================================================

\echo '=== インデックスなしでの実行計画 (salary > 700000) ==='
EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 700000;

\echo ''
\echo '=== インデックスを追加 ==='
CREATE INDEX idx_employees_salary ON employees(salary);
ANALYZE employees;

\echo ''
\echo '=== インデックスありでの実行計画 (salary > 700000, 該当行が少ない) ==='
EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 700000;

\echo ''
\echo '=== インデックスありでの実行計画 (salary > 200000, 大多数が該当) ==='
EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 200000;

\echo ''
\echo '>>> salary > 700000 ではインデックスが使われるが、'
\echo '>>> salary > 200000 ではフルスキャンが選ばれる可能性がある。'
\echo '>>> オプティマイザが「テーブル全体を読んだ方が速い」と判断したからだ。'

-- 後片付け
DROP INDEX idx_employees_salary;
SQLEOF

# 演習3: NULLの三値論理
cat > "${WORKDIR}/exercise3_null.sql" << 'SQLEOF'
-- =============================================================================
-- 演習3: NULLの三値論理を体験する
-- =============================================================================

\echo '=== NULLとの比較がUNKNOWNを返す挙動 ==='
SELECT id, value, (value = NULL) AS eq_null FROM test_null;

\echo ''
\echo '=== WHERE句でのNULLの扱い ==='
\echo 'WHERE value = NULL の結果:'
SELECT * FROM test_null WHERE value = NULL;

\echo ''
\echo 'WHERE value <> NULL の結果:'
SELECT * FROM test_null WHERE value <> NULL;

\echo ''
\echo 'WHERE value IS NULL の結果:'
SELECT * FROM test_null WHERE value IS NULL;

\echo ''
\echo 'WHERE value IS NOT NULL の結果:'
SELECT * FROM test_null WHERE value IS NOT NULL;

\echo ''
\echo '=== NOT IN にNULLが含まれる場合の罠 ==='
\echo 'NOT IN (10, 20, NULL) の結果:'
SELECT * FROM test_null WHERE value NOT IN (10, 20, NULL);
\echo '>>> 0行！ value=30 も返らない。'
\echo '>>> 理由: 30 <> NULL → UNKNOWN, NOT UNKNOWN → UNKNOWN'
\echo '>>> WHERE句はUNKNOWNの行を除外する。'

\echo ''
\echo 'NOT IN (10, 20) の結果（NULLなし）:'
SELECT * FROM test_null WHERE value NOT IN (10, 20);
\echo '>>> value=30 が正しく返る。NULLがなければ期待通り動く。'
SQLEOF

# 演習4: ウィンドウ関数
cat > "${WORKDIR}/exercise4_window.sql" << 'SQLEOF'
-- =============================================================================
-- 演習4: ウィンドウ関数 -- SQLの宣言的な表現力の進化
-- =============================================================================

\echo '=== 部署ごとの給与ランキングと統計 ==='
SELECT
    name,
    dept_code,
    salary,
    RANK() OVER (PARTITION BY dept_code ORDER BY salary DESC) AS salary_rank,
    AVG(salary) OVER (PARTITION BY dept_code)::int AS dept_avg_salary,
    salary - AVG(salary) OVER (PARTITION BY dept_code)::int AS diff_from_avg
FROM employees
WHERE dept_code IN ('D01', 'D02')
ORDER BY dept_code, salary DESC
LIMIT 20;

\echo ''
\echo '>>> 1つのSQL文で「部署内ランキング」「部署平均」「平均との差」を同時に計算。'
\echo '>>> 手続き型言語なら複数のループとソートが必要な処理を、'
\echo '>>> 宣言的に「何がほしいか」を書くだけで実現している。'
\echo '>>> ウィンドウ関数はSQL:2003で標準化されたが、その設計思想は'
\echo '>>> 1974年のSEQUELと同じ——「何がほしいか」の宣言だ。'
SQLEOF

docker cp "${WORKDIR}/exercise1_optimizer.sql" "${CONTAINER_NAME}:/tmp/"
docker cp "${WORKDIR}/exercise2_index.sql" "${CONTAINER_NAME}:/tmp/"
docker cp "${WORKDIR}/exercise3_null.sql" "${CONTAINER_NAME}:/tmp/"
docker cp "${WORKDIR}/exercise4_window.sql" "${CONTAINER_NAME}:/tmp/"

echo "演習SQLファイルの作成が完了しました。"

# --- 演習の自動実行 ---
echo ""
echo "============================================================"
echo "[演習1] 同じ結果を返す複数のSQL -- オプティマイザの判断"
echo "============================================================"
echo ""
docker exec "${CONTAINER_NAME}" psql -U postgres -d handson -f /tmp/exercise1_optimizer.sql

echo ""
echo "============================================================"
echo "[演習2] インデックスでオプティマイザの判断が変わる"
echo "============================================================"
echo ""
docker exec "${CONTAINER_NAME}" psql -U postgres -d handson -f /tmp/exercise2_index.sql

echo ""
echo "============================================================"
echo "[演習3] NULLの三値論理を体験する"
echo "============================================================"
echo ""
docker exec "${CONTAINER_NAME}" psql -U postgres -d handson -f /tmp/exercise3_null.sql

echo ""
echo "============================================================"
echo "[演習4] ウィンドウ関数 -- SQLの宣言的な表現力の進化"
echo "============================================================"
echo ""
docker exec "${CONTAINER_NAME}" psql -U postgres -d handson -f /tmp/exercise4_window.sql

# --- 完了メッセージ ---
echo ""
echo "============================================================"
echo "全演習が完了しました。"
echo "============================================================"
echo ""
echo "手動でSQLを試すには:"
echo "  docker exec -it ${CONTAINER_NAME} psql -U postgres -d handson"
echo ""
echo "コンテナの停止・削除:"
echo "  docker rm -f ${CONTAINER_NAME}"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "  exercise1_optimizer.sql -- オプティマイザの判断比較"
echo "  exercise2_index.sql     -- インデックスと実行計画"
echo "  exercise3_null.sql      -- NULLの三値論理"
echo "  exercise4_window.sql    -- ウィンドウ関数"
