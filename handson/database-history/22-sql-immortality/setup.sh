#!/bin/bash
# =============================================================================
# 第22回ハンズオン：モダンSQLの力を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: docker
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-22"

echo "=== 第22回ハンズオン：モダンSQLの力を体験する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- PostgreSQL起動 ---
echo "[準備] PostgreSQL 17をDockerで起動"
echo ""

# 既存コンテナがあれば削除
docker rm -f pg-modern-sql 2>/dev/null || true

docker run -d \
  --name pg-modern-sql \
  -e POSTGRES_PASSWORD=handson \
  -e POSTGRES_DB=moderndb \
  -p 5432:5432 \
  postgres:17

echo "PostgreSQL起動を待機中..."
sleep 5

# --- テストデータ投入 ---
echo "[準備] テストデータを投入"
echo ""

docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- 従業員テーブル（階層構造付き）
CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  department TEXT NOT NULL,
  salary INTEGER NOT NULL,
  manager_id INTEGER REFERENCES employees(id),
  hired_date DATE NOT NULL
);

INSERT INTO employees (name, department, salary, manager_id, hired_date) VALUES
('田中太郎', 'Engineering', 1200000, NULL,  '2010-04-01'),
('鈴木花子', 'Engineering', 950000,  1,     '2015-06-15'),
('佐藤次郎', 'Engineering', 880000,  1,     '2016-09-01'),
('高橋美咲', 'Engineering', 820000,  2,     '2019-04-01'),
('伊藤健太', 'Engineering', 780000,  2,     '2020-07-01'),
('渡辺由美', 'Sales',       900000,  NULL,  '2012-04-01'),
('山本誠一', 'Sales',       750000,  6,     '2017-10-01'),
('中村あい', 'Sales',       720000,  6,     '2018-04-01'),
('小林拓也', 'Sales',       680000,  7,     '2021-04-01'),
('加藤恵理', 'Marketing',   850000,  NULL,  '2013-04-01'),
('吉田翔太', 'Marketing',   700000,  10,    '2018-09-01'),
('山田奈々', 'Marketing',   650000,  10,    '2022-04-01');

-- 月次売上テーブル
CREATE TABLE monthly_sales (
  id SERIAL PRIMARY KEY,
  employee_id INTEGER REFERENCES employees(id),
  year_month DATE NOT NULL,
  amount INTEGER NOT NULL
);

INSERT INTO monthly_sales (employee_id, year_month, amount)
SELECT
  e.id,
  date_trunc('month', generate_series('2024-01-01'::date, '2024-12-01'::date, '1 month'))::date,
  (random() * 500000 + 100000)::integer
FROM employees e
WHERE e.department = 'Sales';

-- プロダクト情報テーブル（JSONB）
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  metadata JSONB NOT NULL
);

INSERT INTO products (name, metadata) VALUES
('PostgreSQL入門書',
 '{"category": "book", "price": 3200, "tags": ["database", "SQL", "PostgreSQL"],
   "specs": {"pages": 450, "publisher": "Tech Press", "edition": 3}}'),
('DuckDBハンドブック',
 '{"category": "book", "price": 2800, "tags": ["database", "analytics", "DuckDB"],
   "specs": {"pages": 320, "publisher": "Data Books", "edition": 1}}'),
('SQLマスターコース',
 '{"category": "course", "price": 15000, "tags": ["SQL", "database", "online"],
   "specs": {"hours": 40, "level": "intermediate", "platform": "online"}}'),
('DB設計パターン集',
 '{"category": "book", "price": 3800, "tags": ["database", "design", "patterns"],
   "specs": {"pages": 380, "publisher": "Tech Press", "edition": 2}}'),
('Redis実践ガイド',
 '{"category": "book", "price": 2900, "tags": ["NoSQL", "Redis", "cache"],
   "specs": {"pages": 280, "publisher": "Cloud Books", "edition": 1}}');
SQL

echo ""
echo "テストデータの投入が完了しました"
echo ""

# --- 演習2: ウィンドウ関数 ---
echo "============================================================"
echo "[演習2] ウィンドウ関数: 部署別給与ランキングと移動平均"
echo "============================================================"
echo ""

docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- 部署内の給与ランキング
SELECT
  name,
  department,
  salary,
  RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank,
  DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dense_rank,
  salary - AVG(salary) OVER (PARTITION BY department) AS diff_from_avg
FROM employees
ORDER BY department, salary DESC;
SQL

echo ""

docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- 売上の移動平均（3カ月移動平均）
SELECT
  e.name,
  ms.year_month,
  ms.amount,
  ROUND(AVG(ms.amount) OVER (
    PARTITION BY ms.employee_id
    ORDER BY ms.year_month
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  )) AS moving_avg_3m,
  SUM(ms.amount) OVER (
    PARTITION BY ms.employee_id
    ORDER BY ms.year_month
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_total
FROM monthly_sales ms
JOIN employees e ON e.id = ms.employee_id
WHERE e.name = '山本誠一'
ORDER BY ms.year_month;
SQL

echo ""

# --- 演習3: 再帰CTE ---
echo "============================================================"
echo "[演習3] 再帰CTE: 組織の階層構造の走査"
echo "============================================================"
echo ""

docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- 組織階層の展開
WITH RECURSIVE org_tree AS (
  SELECT
    id, name, department, manager_id,
    name AS management_chain,
    0 AS depth
  FROM employees
  WHERE manager_id IS NULL

  UNION ALL

  SELECT
    e.id, e.name, e.department, e.manager_id,
    ot.management_chain || ' > ' || e.name,
    ot.depth + 1
  FROM employees e
  INNER JOIN org_tree ot ON e.manager_id = ot.id
)
SELECT
  repeat('  ', depth) || name AS org_chart,
  department,
  management_chain,
  depth
FROM org_tree
ORDER BY department, management_chain;
SQL

echo ""

# --- 演習4: JSONB操作 ---
echo "============================================================"
echo "[演習4] JSONB操作: 半構造化データのクエリ"
echo "============================================================"
echo ""

docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- JSONB内のネストしたフィールドを抽出
SELECT
  name,
  metadata->>'category' AS category,
  (metadata->>'price')::integer AS price,
  metadata->'specs'->>'publisher' AS publisher,
  metadata->'specs'->>'pages' AS pages
FROM products
WHERE metadata->>'category' = 'book'
ORDER BY (metadata->>'price')::integer DESC;
SQL

echo ""

docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- tags配列を展開して、タグごとの商品数を集計
SELECT
  tag,
  COUNT(*) AS product_count,
  ROUND(AVG((metadata->>'price')::integer)) AS avg_price
FROM products, jsonb_array_elements_text(metadata->'tags') AS tag
GROUP BY tag
ORDER BY product_count DESC, avg_price DESC;
SQL

echo ""

# --- 演習5: 複合クエリ ---
echo "============================================================"
echo "[演習5] 複合クエリ: モダンSQL機能の組み合わせ"
echo "============================================================"
echo ""

docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- 部署ごとの給与分析レポート
WITH dept_stats AS (
  SELECT
    department,
    name,
    salary,
    hired_date,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank,
    PERCENT_RANK() OVER (PARTITION BY department ORDER BY salary) AS percentile,
    salary - LAG(salary) OVER (PARTITION BY department ORDER BY hired_date) AS salary_gap_from_prev_hire,
    FIRST_VALUE(name) OVER (
      PARTITION BY department ORDER BY salary DESC
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS highest_earner
  FROM employees
)
SELECT
  department,
  name,
  salary,
  salary_rank,
  ROUND(percentile::numeric, 2) AS percentile,
  salary_gap_from_prev_hire,
  highest_earner,
  CASE
    WHEN salary_rank = 1 THEN 'Top Earner'
    WHEN percentile >= 0.75 THEN 'Above Average'
    WHEN percentile >= 0.25 THEN 'Average'
    ELSE 'Below Average'
  END AS salary_tier
FROM dept_stats
ORDER BY department, salary_rank;
SQL

echo ""
echo "============================================================"
echo "全演習が完了しました"
echo ""
echo "後片付け:"
echo "  docker stop pg-modern-sql && docker rm pg-modern-sql"
echo "============================================================"
