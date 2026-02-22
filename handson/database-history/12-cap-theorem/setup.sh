#!/bin/bash
# =============================================================================
# 第12回ハンズオン：CAP定理——分散システムの不可能三角形
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: Docker（PostgreSQL 17 公式イメージを使用）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-12"
PRIMARY_CONTAINER="db-history-ep12-primary"
STANDBY_SYNC_CONTAINER="db-history-ep12-standby-sync"
PRIMARY_ASYNC_CONTAINER="db-history-ep12-primary-async"
STANDBY_ASYNC_CONTAINER="db-history-ep12-standby-async"
NETWORK="db-history-ep12-net"

echo "=== 第12回ハンズオン：CAP定理——分散システムの不可能三角形 ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- 既存コンテナ・ネットワークの停止・削除 ---
for c in "${PRIMARY_CONTAINER}" "${STANDBY_SYNC_CONTAINER}" \
         "${PRIMARY_ASYNC_CONTAINER}" "${STANDBY_ASYNC_CONTAINER}"; do
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
# パート1: 同期レプリケーション（CP的挙動の体験）
# =============================================================================

echo ""
echo "=== パート1: 同期レプリケーション（CP的挙動） ==="
echo ""

# --- プライマリの起動 ---
echo "[Step 2] プライマリ（同期）を起動しています..."
docker run -d \
    --name "${PRIMARY_CONTAINER}" \
    --network "${NETWORK}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    -e POSTGRES_INITDB_ARGS="--data-checksums" \
    postgres:17 \
    -c wal_level=replica \
    -c max_wal_senders=4 \
    -c synchronous_standby_names='standby_sync' \
    -c synchronous_commit=on > /dev/null

# --- 同期スタンバイの起動（pg_basebackupでプライマリから初期化） ---
echo "[Step 3] 同期スタンバイを起動しています..."

# プライマリの起動を待機
for i in $(seq 1 30); do
    if docker exec "${PRIMARY_CONTAINER}" pg_isready -U postgres > /dev/null 2>&1; then
        echo "  ${PRIMARY_CONTAINER} が起動しました。"
        break
    fi
    sleep 1
done

# レプリケーション用ユーザー作成とテーブル作成
docker exec -i "${PRIMARY_CONTAINER}" psql -U postgres -d handson <<'SQL'
-- レプリケーション用設定
ALTER SYSTEM SET listen_addresses = '*';
SELECT pg_reload_conf();

-- テスト用テーブル作成
CREATE TABLE sensor_data (
    id SERIAL PRIMARY KEY,
    sensor_id VARCHAR(50) NOT NULL,
    value NUMERIC(10, 2) NOT NULL,
    recorded_at TIMESTAMP NOT NULL
);
SQL

# pg_hba.conf にレプリケーション許可を追加
docker exec "${PRIMARY_CONTAINER}" bash -c \
    "echo 'host replication postgres all md5' >> /var/lib/postgresql/data/pg_hba.conf"
docker exec "${PRIMARY_CONTAINER}" psql -U postgres -c "SELECT pg_reload_conf();" > /dev/null

# スタンバイコンテナを起動（一時的にPostgreSQLを起動してからpg_basebackupで初期化）
docker run -d \
    --name "${STANDBY_SYNC_CONTAINER}" \
    --network "${NETWORK}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    postgres:17 > /dev/null

# スタンバイの起動を待機
for i in $(seq 1 30); do
    if docker exec "${STANDBY_SYNC_CONTAINER}" pg_isready -U postgres > /dev/null 2>&1; then
        echo "  ${STANDBY_SYNC_CONTAINER} が起動しました。"
        break
    fi
    sleep 1
done

# スタンバイを停止し、pg_basebackupでプライマリからデータを取得
docker exec "${STANDBY_SYNC_CONTAINER}" bash -c "pg_ctl stop -D /var/lib/postgresql/data -m fast" 2>/dev/null || true
sleep 2
docker exec "${STANDBY_SYNC_CONTAINER}" bash -c \
    "rm -rf /var/lib/postgresql/data/* && \
     PGPASSWORD=handson pg_basebackup -h ${PRIMARY_CONTAINER} -U postgres \
     -D /var/lib/postgresql/data -Fp -Xs -P -R" 2>/dev/null

# standby.signal と application_name の設定
docker exec "${STANDBY_SYNC_CONTAINER}" bash -c \
    "echo \"primary_conninfo = 'host=${PRIMARY_CONTAINER} port=5432 user=postgres password=handson application_name=standby_sync'\" >> /var/lib/postgresql/data/postgresql.auto.conf"

# スタンバイを再起動
docker restart "${STANDBY_SYNC_CONTAINER}" > /dev/null
sleep 3

echo "同期レプリケーションの構成が完了しました。"

# =============================================================================
# パート2: 非同期レプリケーション（AP的挙動の体験）
# =============================================================================

echo ""
echo "=== パート2: 非同期レプリケーション（AP的挙動） ==="
echo ""

# --- 非同期プライマリの起動 ---
echo "[Step 4] プライマリ（非同期）を起動しています..."
docker run -d \
    --name "${PRIMARY_ASYNC_CONTAINER}" \
    --network "${NETWORK}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    -e POSTGRES_INITDB_ARGS="--data-checksums" \
    postgres:17 \
    -c wal_level=replica \
    -c max_wal_senders=4 \
    -c synchronous_commit=off > /dev/null

# プライマリの起動を待機
for i in $(seq 1 30); do
    if docker exec "${PRIMARY_ASYNC_CONTAINER}" pg_isready -U postgres > /dev/null 2>&1; then
        echo "  ${PRIMARY_ASYNC_CONTAINER} が起動しました。"
        break
    fi
    sleep 1
done

# テーブル作成とレプリケーション許可
docker exec -i "${PRIMARY_ASYNC_CONTAINER}" psql -U postgres -d handson <<'SQL'
CREATE TABLE sensor_data (
    id SERIAL PRIMARY KEY,
    sensor_id VARCHAR(50) NOT NULL,
    value NUMERIC(10, 2) NOT NULL,
    recorded_at TIMESTAMP NOT NULL
);
SQL

docker exec "${PRIMARY_ASYNC_CONTAINER}" bash -c \
    "echo 'host replication postgres all md5' >> /var/lib/postgresql/data/pg_hba.conf"
docker exec "${PRIMARY_ASYNC_CONTAINER}" psql -U postgres -c "SELECT pg_reload_conf();" > /dev/null

# --- 非同期スタンバイの起動 ---
echo "[Step 5] 非同期スタンバイを起動しています..."
docker run -d \
    --name "${STANDBY_ASYNC_CONTAINER}" \
    --network "${NETWORK}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    postgres:17 > /dev/null

for i in $(seq 1 30); do
    if docker exec "${STANDBY_ASYNC_CONTAINER}" pg_isready -U postgres > /dev/null 2>&1; then
        echo "  ${STANDBY_ASYNC_CONTAINER} が起動しました。"
        break
    fi
    sleep 1
done

# pg_basebackupで初期化
docker exec "${STANDBY_ASYNC_CONTAINER}" bash -c "pg_ctl stop -D /var/lib/postgresql/data -m fast" 2>/dev/null || true
sleep 2
docker exec "${STANDBY_ASYNC_CONTAINER}" bash -c \
    "rm -rf /var/lib/postgresql/data/* && \
     PGPASSWORD=handson pg_basebackup -h ${PRIMARY_ASYNC_CONTAINER} -U postgres \
     -D /var/lib/postgresql/data -Fp -Xs -P -R" 2>/dev/null

docker exec "${STANDBY_ASYNC_CONTAINER}" bash -c \
    "echo \"primary_conninfo = 'host=${PRIMARY_ASYNC_CONTAINER} port=5432 user=postgres password=handson application_name=standby_async'\" >> /var/lib/postgresql/data/postgresql.auto.conf"

docker restart "${STANDBY_ASYNC_CONTAINER}" > /dev/null
sleep 3

echo "非同期レプリケーションの構成が完了しました。"

# =============================================================================
# 完了メッセージ
# =============================================================================

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "--- パート1: 同期レプリケーション（CP的挙動） ---"
echo ""
echo "プライマリに接続:"
echo "  docker exec -it ${PRIMARY_CONTAINER} psql -U postgres -d handson"
echo ""
echo "同期スタンバイに接続:"
echo "  docker exec -it ${STANDBY_SYNC_CONTAINER} psql -U postgres -d handson"
echo ""
echo "演習1: ネットワーク分断でCP的挙動を確認"
echo "  1. プライマリで書き込み → 正常に完了"
echo "  2. スタンバイを切断:"
echo "     docker network disconnect ${NETWORK} ${STANDBY_SYNC_CONTAINER}"
echo "  3. プライマリで書き込み → ブロックされる（タイムアウト）"
echo "     SET statement_timeout = '5s';"
echo "     INSERT INTO sensor_data (sensor_id, value, recorded_at) VALUES ('s1', 23.5, NOW());"
echo "  4. 復旧:"
echo "     docker network connect ${NETWORK} ${STANDBY_SYNC_CONTAINER}"
echo ""
echo "--- パート2: 非同期レプリケーション（AP的挙動） ---"
echo ""
echo "非同期プライマリに接続:"
echo "  docker exec -it ${PRIMARY_ASYNC_CONTAINER} psql -U postgres -d handson"
echo ""
echo "非同期スタンバイに接続:"
echo "  docker exec -it ${STANDBY_ASYNC_CONTAINER} psql -U postgres -d handson"
echo ""
echo "演習2: ネットワーク分断でAP的挙動を確認"
echo "  1. プライマリで書き込み → 正常に完了"
echo "  2. スタンバイを切断:"
echo "     docker network disconnect ${NETWORK} ${STANDBY_ASYNC_CONTAINER}"
echo "  3. プライマリで書き込み → 即座に完了（スタンバイには反映されない）"
echo "  4. スタンバイでSELECT → 古いデータが返る（一貫性の喪失）"
echo "  5. 復旧:"
echo "     docker network connect ${NETWORK} ${STANDBY_ASYNC_CONTAINER}"
echo "  6. スタンバイでSELECT → データが収束する（結果整合性）"
echo ""
echo "--- 後片付け ---"
echo "  docker rm -f ${PRIMARY_CONTAINER} ${STANDBY_SYNC_CONTAINER} \\"
echo "      ${PRIMARY_ASYNC_CONTAINER} ${STANDBY_ASYNC_CONTAINER}"
echo "  docker network rm ${NETWORK}"
