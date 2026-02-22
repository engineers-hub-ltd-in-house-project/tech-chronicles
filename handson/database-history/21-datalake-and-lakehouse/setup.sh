#!/bin/bash
# =============================================================================
# 第21回ハンズオン：DuckDBでParquetファイルを分析する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: docker
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-21"

echo "=== 第21回ハンズオン：DuckDBでParquetファイルを分析する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- 演習1: テストデータの生成 ---
echo "[演習1] 100万行の売上データをCSV/Parquetで生成"
echo ""

docker run --rm -v "${WORKDIR}":/data \
  python:3.12-slim bash -c '
pip install -q duckdb > /dev/null 2>&1
python3 << "PYEOF"
import duckdb
import os

con = duckdb.connect()

print("  Generating 1,000,000 rows of sales data...")

con.execute("""
    COPY (
        SELECT
            i AS id,
            2020 + (i % 5) AS year,
            1 + (i % 12) AS month,
            CASE (i % 5)
                WHEN 0 THEN '"'"'Tokyo'"'"'
                WHEN 1 THEN '"'"'Osaka'"'"'
                WHEN 2 THEN '"'"'Nagoya'"'"'
                WHEN 3 THEN '"'"'Fukuoka'"'"'
                WHEN 4 THEN '"'"'Sapporo'"'"'
            END AS region,
            CASE (i % 4)
                WHEN 0 THEN '"'"'Electronics'"'"'
                WHEN 1 THEN '"'"'Clothing'"'"'
                WHEN 2 THEN '"'"'Food'"'"'
                WHEN 3 THEN '"'"'Books'"'"'
            END AS category,
            ROUND(100 + (RANDOM() * 9900), 2) AS amount,
            1 + (RANDOM() * 10)::INT AS quantity
        FROM generate_series(1, 1000000) AS t(i)
    ) TO '"'"'/data/sales.csv'"'"' (HEADER, DELIMITER '"'"','"'"')
""")

con.execute("""
    COPY (SELECT * FROM read_csv_auto('"'"'/data/sales.csv'"'"'))
    TO '"'"'/data/sales.parquet'"'"' (FORMAT PARQUET)
""")

csv_size = os.path.getsize("/data/sales.csv")
parquet_size = os.path.getsize("/data/sales.parquet")
print(f"  CSV size:     {csv_size / 1024 / 1024:.1f} MB")
print(f"  Parquet size: {parquet_size / 1024 / 1024:.1f} MB")
print(f"  Compression:  {parquet_size / csv_size * 100:.1f}%")
print(f"  → Parquetは列指向圧縮により、CSVより大幅に小さい")
PYEOF
'
echo ""

# --- 演習2: PostgreSQLでの集計 ---
echo "[演習2] PostgreSQL（行指向）での集計クエリ"
echo ""

echo "  Starting PostgreSQL..."
docker run -d \
  --name pg-handson \
  -e POSTGRES_PASSWORD=handson \
  -e POSTGRES_DB=salesdb \
  -v "${WORKDIR}":/data \
  -p 5432:5432 \
  postgres:17 > /dev/null 2>&1

echo "  Waiting for PostgreSQL to be ready..."
sleep 5

echo "  Creating table and loading data..."
docker exec -i pg-handson psql -U postgres -d salesdb << 'SQL'
CREATE TABLE sales (
  id INTEGER PRIMARY KEY,
  year INTEGER,
  month INTEGER,
  region TEXT,
  category TEXT,
  amount NUMERIC(10,2),
  quantity INTEGER
);
SQL

docker exec -i pg-handson bash -c "cat /data/sales.csv | psql -U postgres -d salesdb -c \"\copy sales FROM STDIN WITH (FORMAT csv, HEADER true)\""

echo "  Loaded rows:"
docker exec -i pg-handson psql -U postgres -d salesdb -t -c "SELECT COUNT(*) FROM sales;"

echo ""
echo "  Running aggregation query on PostgreSQL..."
docker exec -i pg-handson psql -U postgres -d salesdb << 'SQL'
\timing on

-- 年別・地域別の売上合計
SELECT year, region,
       SUM(amount) AS total_sales,
       COUNT(*) AS order_count,
       ROUND(AVG(amount), 2) AS avg_amount
FROM sales
GROUP BY year, region
ORDER BY year, region;
SQL

echo ""

# --- 演習3: DuckDBでの集計 ---
echo "[演習3] DuckDB（列指向）での集計クエリ"
echo ""

docker run --rm -v "${WORKDIR}":/data \
  python:3.12-slim bash -c '
pip install -q duckdb > /dev/null 2>&1
python3 << "PYEOF"
import duckdb
import time

con = duckdb.connect()

# CSV
print("  --- DuckDB: CSV query ---")
start = time.perf_counter()
result = con.execute("""
    SELECT year, region,
           SUM(amount) AS total_sales,
           COUNT(*) AS order_count,
           ROUND(AVG(amount), 2) AS avg_amount
    FROM read_csv_auto('"'"'/data/sales.csv'"'"')
    GROUP BY year, region
    ORDER BY year, region
""").fetchdf()
elapsed_csv = time.perf_counter() - start
print(result.to_string())
print(f"  CSV query time: {elapsed_csv:.3f} sec")

# Parquet
print("")
print("  --- DuckDB: Parquet query ---")
start = time.perf_counter()
result = con.execute("""
    SELECT year, region,
           SUM(amount) AS total_sales,
           COUNT(*) AS order_count,
           ROUND(AVG(amount), 2) AS avg_amount
    FROM read_parquet('"'"'/data/sales.parquet'"'"')
    GROUP BY year, region
    ORDER BY year, region
""").fetchdf()
elapsed_parquet = time.perf_counter() - start
print(result.to_string())
print(f"  Parquet query time: {elapsed_parquet:.3f} sec")
print(f"  Parquet vs CSV speedup: {elapsed_csv / elapsed_parquet:.1f}x")
print("")
print("  → Parquetは列指向フォーマットのため、")
print("    集計クエリではCSVより高速に処理できる")
PYEOF
'
echo ""

# --- 演習4: DuckDBの高度なSQL ---
echo "[演習4] DuckDBの高度なSQL（ウィンドウ関数、PIVOT）"
echo ""

docker run --rm -v "${WORKDIR}":/data \
  python:3.12-slim bash -c '
pip install -q duckdb > /dev/null 2>&1
python3 << "PYEOF"
import duckdb

con = duckdb.connect()

# ウィンドウ関数
print("  --- ウィンドウ関数: 月次売上と累積売上 ---")
result = con.execute("""
    SELECT region, month,
           SUM(amount) AS monthly_sales,
           SUM(SUM(amount)) OVER (
               PARTITION BY region
               ORDER BY month
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS cumulative_sales
    FROM read_parquet('"'"'/data/sales.parquet'"'"')
    WHERE year = 2024
    GROUP BY region, month
    ORDER BY region, month
""").fetchdf()
print(result.head(15).to_string())

# PIVOT
print("")
print("  --- PIVOT: 地域 x カテゴリのクロス集計 ---")
result = con.execute("""
    PIVOT (
        SELECT region, category, SUM(amount) AS total
        FROM read_parquet('"'"'/data/sales.parquet'"'"')
        WHERE year = 2024
        GROUP BY region, category
    )
    ON category
    USING SUM(total)
    ORDER BY region
""").fetchdf()
print(result.to_string())
PYEOF
'
echo ""

# --- 後片付け ---
echo "[後片付け]"
docker stop pg-handson > /dev/null 2>&1 && docker rm pg-handson > /dev/null 2>&1
echo "  PostgreSQLコンテナを停止・削除しました"
echo ""

echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "生成されたファイル:"
ls -lh "${WORKDIR}/sales.csv" "${WORKDIR}/sales.parquet" 2>/dev/null || true
echo ""
echo "後片付け: rm -rf ${WORKDIR}"
