#!/bin/bash
# =============================================================================
# 第16回ハンズオン：時系列DB, グラフDB——専門特化の進化
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: Docker（TimescaleDB + Neo4j 5 公式イメージを使用）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-16"
POSTGRES_CONTAINER="db-history-ep16-postgres"
NEO4J_CONTAINER="db-history-ep16-neo4j"
NETWORK="db-history-ep16-net"

echo "=== 第16回ハンズオン：時系列DB, グラフDB——専門特化の進化 ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- 既存コンテナ・ネットワークの停止・削除 ---
for c in "${POSTGRES_CONTAINER}" "${NEO4J_CONTAINER}"; do
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
# PostgreSQL + TimescaleDB コンテナの起動とデータ投入
# =============================================================================

echo "[Step 2] PostgreSQL + TimescaleDB コンテナを起動しています..."
docker run -d \
    --name "${POSTGRES_CONTAINER}" \
    --network "${NETWORK}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    timescale/timescaledb:latest-pg17 > /dev/null

# PostgreSQLの起動を待機
for i in $(seq 1 30); do
    if docker exec "${POSTGRES_CONTAINER}" pg_isready -U postgres > /dev/null 2>&1; then
        echo "  ${POSTGRES_CONTAINER} が起動しました。"
        break
    fi
    sleep 1
done

echo "[Step 3] PostgreSQLにソーシャルネットワークデータを投入しています..."

docker exec -i "${POSTGRES_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- ===========================================
-- ソーシャルネットワークデータ（グラフ探索用）
-- ===========================================

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE friendships (
    user_id INTEGER NOT NULL REFERENCES users(id),
    friend_id INTEGER NOT NULL REFERENCES users(id),
    PRIMARY KEY (user_id, friend_id)
);

-- ユーザーデータ（8名のソーシャルネットワーク）
INSERT INTO users (name) VALUES
    ('Alice'),   -- 1
    ('Bob'),     -- 2
    ('Charlie'), -- 3
    ('Diana'),   -- 4
    ('Eve'),     -- 5
    ('Frank'),   -- 6
    ('Grace'),   -- 7
    ('Hank');    -- 8

-- 友達関係（双方向）
INSERT INTO friendships (user_id, friend_id) VALUES
    (1, 2), (2, 1),  -- Alice <-> Bob
    (1, 3), (3, 1),  -- Alice <-> Charlie
    (2, 4), (4, 2),  -- Bob <-> Diana
    (2, 5), (5, 2),  -- Bob <-> Eve
    (3, 5), (5, 3),  -- Charlie <-> Eve
    (3, 6), (6, 3),  -- Charlie <-> Frank
    (4, 7), (7, 4),  -- Diana <-> Grace
    (5, 7), (7, 5),  -- Eve <-> Grace
    (6, 8), (8, 6),  -- Frank <-> Hank
    (7, 8), (8, 7);  -- Grace <-> Hank

CREATE INDEX idx_friendships_user ON friendships(user_id);
CREATE INDEX idx_friendships_friend ON friendships(friend_id);

-- ===========================================
-- 時系列データ（TimescaleDB用）
-- ===========================================

CREATE EXTENSION IF NOT EXISTS timescaledb;

CREATE TABLE sensor_data (
    time TIMESTAMPTZ NOT NULL,
    sensor_id INTEGER NOT NULL,
    temperature DOUBLE PRECISION,
    humidity DOUBLE PRECISION
);

-- ハイパーテーブルに変換
SELECT create_hypertable('sensor_data', 'time');

-- 過去48時間分のセンサーデータを生成（10秒間隔、5センサー）
INSERT INTO sensor_data (time, sensor_id, temperature, humidity)
SELECT
    ts,
    s.id AS sensor_id,
    20.0 + 5.0 * sin(extract(epoch from ts) / 3600.0 + s.id) + random() * 2.0 AS temperature,
    50.0 + 15.0 * cos(extract(epoch from ts) / 7200.0 + s.id) + random() * 3.0 AS humidity
FROM generate_series(
    NOW() - INTERVAL '48 hours',
    NOW(),
    INTERVAL '10 seconds'
) AS ts
CROSS JOIN generate_series(1, 5) AS s(id);

-- 連続集約（Continuous Aggregate）の作成
CREATE MATERIALIZED VIEW sensor_data_hourly
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 hour', time) AS bucket,
    sensor_id,
    AVG(temperature) AS avg_temp,
    MIN(temperature) AS min_temp,
    MAX(temperature) AS max_temp,
    AVG(humidity) AS avg_humidity,
    COUNT(*) AS readings
FROM sensor_data
GROUP BY bucket, sensor_id
WITH NO DATA;

-- 連続集約にデータを投入
CALL refresh_continuous_aggregate('sensor_data_hourly', NULL, NULL);

SQL

echo "  PostgreSQL: users(8行), friendships(20行), sensor_data(約86,400行)"

# =============================================================================
# Neo4j コンテナの起動とデータ投入
# =============================================================================

echo "[Step 4] Neo4jコンテナを起動しています..."
docker run -d \
    --name "${NEO4J_CONTAINER}" \
    --network "${NETWORK}" \
    -e NEO4J_AUTH=neo4j/handsonpass \
    -e NEO4J_PLUGINS='[]' \
    neo4j:5 > /dev/null

# Neo4jの起動を待機
echo "  Neo4jの起動を待機中..."
for i in $(seq 1 60); do
    if docker exec "${NEO4J_CONTAINER}" cypher-shell -u neo4j -p handsonpass "RETURN 1" > /dev/null 2>&1; then
        echo "  ${NEO4J_CONTAINER} が起動しました。"
        break
    fi
    if [ "$i" -eq 60 ]; then
        echo "  エラー: ${NEO4J_CONTAINER} の起動がタイムアウトしました。"
        exit 1
    fi
    sleep 2
done

echo "[Step 5] Neo4jにソーシャルネットワークデータを投入しています..."

docker exec -i "${NEO4J_CONTAINER}" cypher-shell -u neo4j -p handsonpass <<'CYPHER'
// ノードの作成
CREATE (alice:Person {name: 'Alice', id: 1})
CREATE (bob:Person {name: 'Bob', id: 2})
CREATE (charlie:Person {name: 'Charlie', id: 3})
CREATE (diana:Person {name: 'Diana', id: 4})
CREATE (eve:Person {name: 'Eve', id: 5})
CREATE (frank:Person {name: 'Frank', id: 6})
CREATE (grace:Person {name: 'Grace', id: 7})
CREATE (hank:Person {name: 'Hank', id: 8})

// リレーションシップの作成（双方向）
CREATE (alice)-[:FRIEND]->(bob)
CREATE (bob)-[:FRIEND]->(alice)
CREATE (alice)-[:FRIEND]->(charlie)
CREATE (charlie)-[:FRIEND]->(alice)
CREATE (bob)-[:FRIEND]->(diana)
CREATE (diana)-[:FRIEND]->(bob)
CREATE (bob)-[:FRIEND]->(eve)
CREATE (eve)-[:FRIEND]->(bob)
CREATE (charlie)-[:FRIEND]->(eve)
CREATE (eve)-[:FRIEND]->(charlie)
CREATE (charlie)-[:FRIEND]->(frank)
CREATE (frank)-[:FRIEND]->(charlie)
CREATE (diana)-[:FRIEND]->(grace)
CREATE (grace)-[:FRIEND]->(diana)
CREATE (eve)-[:FRIEND]->(grace)
CREATE (grace)-[:FRIEND]->(eve)
CREATE (frank)-[:FRIEND]->(hank)
CREATE (hank)-[:FRIEND]->(frank)
CREATE (grace)-[:FRIEND]->(hank)
CREATE (hank)-[:FRIEND]->(grace);
CYPHER

echo "  Neo4j: Person(8ノード), FRIEND(20リレーションシップ)"

# =============================================================================
# 完了メッセージ
# =============================================================================

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "--- 演習1: PostgreSQLで「友達の友達」検索 ---"
echo ""
echo "PostgreSQLに接続:"
echo "  docker exec -it ${POSTGRES_CONTAINER} psql -U postgres -d handson"
echo ""
echo "友達の一覧:"
echo "  SELECT u2.name FROM friendships f JOIN users u2 ON f.friend_id = u2.id WHERE f.user_id = 1;"
echo ""
echo "友達の友達（再帰CTE）:"
echo "  WITH RECURSIVE friend_graph AS ("
echo "    SELECT f.friend_id, 1 AS depth FROM friendships f WHERE f.user_id = 1"
echo "    UNION"
echo "    SELECT f.friend_id, fg.depth + 1 FROM friend_graph fg"
echo "    JOIN friendships f ON fg.friend_id = f.user_id WHERE fg.depth < 3"
echo "  ) SELECT DISTINCT u.name, fg.depth FROM friend_graph fg"
echo "  JOIN users u ON fg.friend_id = u.id WHERE fg.friend_id != 1 ORDER BY fg.depth;"
echo ""
echo "--- 演習2: Neo4jで「友達の友達」検索 ---"
echo ""
echo "Neo4jに接続:"
echo "  docker exec -it ${NEO4J_CONTAINER} cypher-shell -u neo4j -p handsonpass"
echo ""
echo "友達の一覧:"
echo "  MATCH (a:Person {name: 'Alice'})-[:FRIEND]->(f:Person) RETURN f.name;"
echo ""
echo "可変深さの探索:"
echo "  MATCH (a:Person {name: 'Alice'})-[:FRIEND*1..3]->(r:Person)"
echo "  WHERE r <> a RETURN DISTINCT r.name;"
echo ""
echo "--- 演習3: TimescaleDBで時系列集約 ---"
echo ""
echo "5分間隔の集約:"
echo "  SELECT time_bucket('5 minutes', time) AS bucket, sensor_id,"
echo "    AVG(temperature) AS avg_temp FROM sensor_data"
echo "    WHERE time > NOW() - INTERVAL '1 hour'"
echo "    GROUP BY bucket, sensor_id ORDER BY bucket DESC LIMIT 20;"
echo ""
echo "連続集約ビュー:"
echo "  SELECT * FROM sensor_data_hourly ORDER BY bucket DESC LIMIT 10;"
echo ""
echo "--- 後片付け ---"
echo "  docker rm -f ${POSTGRES_CONTAINER} ${NEO4J_CONTAINER}"
echo "  docker network rm ${NETWORK}"
