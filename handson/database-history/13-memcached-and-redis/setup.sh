#!/bin/bash
# =============================================================================
# 第13回ハンズオン：Memcached, Redis——キャッシュ層という発明
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: Docker（Redis 7 + PostgreSQL 17 公式イメージを使用）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-13"
REDIS_CONTAINER="db-history-ep13-redis"
POSTGRES_CONTAINER="db-history-ep13-postgres"
NETWORK="db-history-ep13-net"

echo "=== 第13回ハンズオン：Memcached, Redis——キャッシュ層という発明 ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}/scripts"

# --- 既存コンテナ・ネットワークの停止・削除 ---
for c in "${REDIS_CONTAINER}" "${POSTGRES_CONTAINER}"; do
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
# Redis コンテナの起動
# =============================================================================

echo "[Step 2] Redisコンテナを起動しています..."
docker run -d \
    --name "${REDIS_CONTAINER}" \
    --network "${NETWORK}" \
    -p 6379:6379 \
    redis:7 > /dev/null

# Redisの起動を待機
for i in $(seq 1 15); do
    if docker exec "${REDIS_CONTAINER}" redis-cli ping 2>/dev/null | grep -q PONG; then
        echo "  ${REDIS_CONTAINER} が起動しました。"
        break
    fi
    sleep 1
done

# =============================================================================
# PostgreSQL コンテナの起動
# =============================================================================

echo "[Step 3] PostgreSQLコンテナを起動しています..."
docker run -d \
    --name "${POSTGRES_CONTAINER}" \
    --network "${NETWORK}" \
    -e POSTGRES_PASSWORD=handson \
    -e POSTGRES_DB=handson \
    postgres:17 > /dev/null

# PostgreSQLの起動を待機
for i in $(seq 1 30); do
    if docker exec "${POSTGRES_CONTAINER}" pg_isready -U postgres > /dev/null 2>&1; then
        echo "  ${POSTGRES_CONTAINER} が起動しました。"
        break
    fi
    sleep 1
done

# =============================================================================
# PostgreSQL テストデータの投入
# =============================================================================

echo "[Step 4] PostgreSQLにテストデータを投入しています..."

docker exec -i "${POSTGRES_CONTAINER}" psql -U postgres -d handson <<'SQL'
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price INTEGER NOT NULL,
    category VARCHAR(50) NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO products (name, price, category) VALUES
    ('Mechanical Keyboard', 15000, 'peripherals'),
    ('27" 4K Monitor', 45000, 'displays'),
    ('Wireless Mouse', 8000, 'peripherals'),
    ('USB-C Hub', 6000, 'accessories'),
    ('Webcam HD', 12000, 'peripherals'),
    ('Standing Desk', 55000, 'furniture'),
    ('Monitor Arm', 9000, 'accessories'),
    ('Noise Cancelling Headphones', 35000, 'audio'),
    ('Microphone', 18000, 'audio'),
    ('Laptop Stand', 4000, 'accessories');
SQL

echo "  products テーブル（10行）を作成しました。"

# =============================================================================
# Redis に HyperLogLog テストデータを投入
# =============================================================================

echo "[Step 5] RedisにHyperLogLogテストデータを投入しています..."

# 10万件のユニークユーザーIDを投入
docker exec "${REDIS_CONTAINER}" bash -c '
for i in $(seq 1 100000); do
    redis-cli PFADD uv:large-test "user:${i}" > /dev/null
done
' 2>/dev/null

PFCOUNT=$(docker exec "${REDIS_CONTAINER}" redis-cli PFCOUNT uv:large-test)
echo "  uv:large-test に100,000件投入 → PFCOUNT: ${PFCOUNT}"

# =============================================================================
# デモスクリプトの配置
# =============================================================================

echo "[Step 6] デモスクリプトを配置しています..."

# --- Cache Aside デモスクリプト ---
cat > "${WORKDIR}/scripts/cache-aside-demo.sh" <<'SCRIPT'
#!/bin/bash
set -euo pipefail

REDIS_CLI="redis-cli -h db-history-ep13-redis"
PSQL="psql -h db-history-ep13-postgres -U postgres -d handson -t -A"

echo "=== Cache Aside パターン デモ ==="
echo ""

# 1. キャッシュミス → DB読み取り → キャッシュ設定
echo "[1] キャッシュミス: DBから読み取りしてキャッシュに設定"
START=$(date +%s%N)
CACHED=$(${REDIS_CLI} GET product:1 2>/dev/null)
if [ -z "${CACHED}" ] || [ "${CACHED}" = "" ]; then
    echo "  Cache MISS"
    RESULT=$(PGPASSWORD=handson ${PSQL} -c "SELECT name || ':' || price FROM products WHERE id = 1;" 2>/dev/null)
    ${REDIS_CLI} SETEX product:1 30 "${RESULT}" > /dev/null
    echo "  DB結果: ${RESULT}"
    echo "  キャッシュに設定（TTL 30秒）"
else
    echo "  Cache HIT: ${CACHED}"
fi
END=$(date +%s%N)
echo "  所要時間: $(( (END - START) / 1000000 ))ms"
echo ""

# 2. キャッシュヒット
echo "[2] キャッシュヒット: キャッシュから読み取り"
START=$(date +%s%N)
CACHED=$(${REDIS_CLI} GET product:1 2>/dev/null)
echo "  Cache HIT: ${CACHED}"
END=$(date +%s%N)
echo "  所要時間: $(( (END - START) / 1000000 ))ms"
echo ""

# 3. DB更新（キャッシュ削除なし）
echo "[3] DB更新: price を 1500 → 1800 に変更（キャッシュ削除なし）"
PGPASSWORD=handson ${PSQL} -c "UPDATE products SET price = 1800, updated_at = NOW() WHERE id = 1;" > /dev/null 2>&1
echo "  DB更新完了"
echo ""

# 4. 古いキャッシュが返る
echo "[4] キャッシュから読み取り（古い値が返る）"
CACHED=$(${REDIS_CLI} GET product:1 2>/dev/null)
echo "  Cache HIT: ${CACHED} ← 古い値！"
echo ""

# 5. キャッシュ削除
echo "[5] キャッシュを削除（invalidation）"
${REDIS_CLI} DEL product:1 > /dev/null
echo "  キャッシュ削除完了"
echo ""

# 6. 最新値が返る
echo "[6] 再度読み取り（キャッシュミス → DB読み取り → 最新値）"
RESULT=$(PGPASSWORD=handson ${PSQL} -c "SELECT name || ':' || price FROM products WHERE id = 1;" 2>/dev/null)
${REDIS_CLI} SETEX product:1 30 "${RESULT}" > /dev/null
echo "  DB結果: ${RESULT} ← 最新値"
echo ""

# 価格を元に戻す
PGPASSWORD=handson ${PSQL} -c "UPDATE products SET price = 15000, updated_at = NOW() WHERE id = 1;" > /dev/null 2>&1
${REDIS_CLI} DEL product:1 > /dev/null
echo "=== デモ完了 ==="
SCRIPT

# --- Thundering Herd デモスクリプト ---
cat > "${WORKDIR}/scripts/thundering-herd-demo.sh" <<'SCRIPT'
#!/bin/bash
set -euo pipefail

REDIS_CLI="redis-cli -h db-history-ep13-redis"
PSQL="psql -h db-history-ep13-postgres -U postgres -d handson -t -A"

echo "=== Thundering Herd シミュレーション ==="
echo ""

# カウンタをリセット
${REDIS_CLI} SET db_query_count:no_protection 0 > /dev/null
${REDIS_CLI} SET db_query_count:with_coalescing 0 > /dev/null
${REDIS_CLI} DEL product:popular > /dev/null
${REDIS_CLI} DEL product:popular:lock > /dev/null

echo "=== 対策なし: 全リクエストがDBに殺到 ==="
echo ""

# 対策なし: 10リクエストを同時に発行
for i in $(seq 1 10); do
    (
        CACHED=$(${REDIS_CLI} GET product:popular 2>/dev/null)
        if [ -z "${CACHED}" ] || [ "${CACHED}" = "" ]; then
            # Cache Miss → DB問い合わせ
            ${REDIS_CLI} INCR db_query_count:no_protection > /dev/null
            RESULT=$(PGPASSWORD=handson ${PSQL} -c "SELECT name || ':' || price FROM products WHERE id = 2;" 2>/dev/null)
            sleep 0.1  # DB問い合わせの遅延をシミュレート
            ${REDIS_CLI} SETEX product:popular 30 "${RESULT}" > /dev/null
        fi
    ) &
done
wait

COUNT=$(${REDIS_CLI} GET db_query_count:no_protection 2>/dev/null)
echo "DB問い合わせ回数: ${COUNT}（全リクエストがDBに殺到）"
echo ""

# リセット
${REDIS_CLI} DEL product:popular > /dev/null

echo "=== Request Coalescing（対策あり）: ロックで排他制御 ==="
echo ""

for i in $(seq 1 10); do
    (
        CACHED=$(${REDIS_CLI} GET product:popular 2>/dev/null)
        if [ -z "${CACHED}" ] || [ "${CACHED}" = "" ]; then
            # ロック取得を試みる（SETNX + EX でタイムアウト付き）
            LOCK=$(${REDIS_CLI} SET product:popular:lock 1 NX EX 5 2>/dev/null)
            if echo "${LOCK}" | grep -q "OK"; then
                # ロック取得成功 → DB問い合わせ
                ${REDIS_CLI} INCR db_query_count:with_coalescing > /dev/null
                RESULT=$(PGPASSWORD=handson ${PSQL} -c "SELECT name || ':' || price FROM products WHERE id = 2;" 2>/dev/null)
                sleep 0.1  # DB問い合わせの遅延をシミュレート
                ${REDIS_CLI} SETEX product:popular 30 "${RESULT}" > /dev/null
                ${REDIS_CLI} DEL product:popular:lock > /dev/null
            else
                # ロック取得失敗 → 他のリクエストがキャッシュを再投入するまで待機
                for j in $(seq 1 20); do
                    sleep 0.1
                    CACHED=$(${REDIS_CLI} GET product:popular 2>/dev/null)
                    if [ -n "${CACHED}" ] && [ "${CACHED}" != "" ]; then
                        break
                    fi
                done
            fi
        fi
    ) &
done
wait

COUNT=$(${REDIS_CLI} GET db_query_count:with_coalescing 2>/dev/null)
echo "DB問い合わせ回数: ${COUNT}（最初のリクエストのみDBに問い合わせ）"
echo ""

# クリーンアップ
${REDIS_CLI} DEL product:popular product:popular:lock \
    db_query_count:no_protection db_query_count:with_coalescing > /dev/null

echo "=== デモ完了 ==="
SCRIPT

chmod +x "${WORKDIR}/scripts/cache-aside-demo.sh"
chmod +x "${WORKDIR}/scripts/thundering-herd-demo.sh"

# スクリプトをRedisコンテナにコピー
docker cp "${WORKDIR}/scripts" "${REDIS_CONTAINER}:/scripts"

# Redisコンテナに psql クライアントをインストール
docker exec "${REDIS_CONTAINER}" bash -c \
    "apt-get update -qq && apt-get install -y -qq postgresql-client > /dev/null 2>&1" || true

echo "  デモスクリプトを配置しました。"

# =============================================================================
# 完了メッセージ
# =============================================================================

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "--- 演習1: Sorted Setによるリアルタイムランキング ---"
echo ""
echo "Redisに接続:"
echo "  docker exec -it ${REDIS_CONTAINER} redis-cli"
echo ""
echo "コマンド例:"
echo "  ZADD leaderboard 1500 \"player:alice\""
echo "  ZREVRANGE leaderboard 0 2 WITHSCORES"
echo ""
echo "--- 演習2: HyperLogLogによるユニークビジター推定 ---"
echo ""
echo "  docker exec -it ${REDIS_CONTAINER} redis-cli PFCOUNT uv:large-test"
echo ""
echo "--- 演習3: Cache Asideパターンとキャッシュ不整合 ---"
echo ""
echo "  docker exec -it ${REDIS_CONTAINER} bash /scripts/cache-aside-demo.sh"
echo ""
echo "--- 演習4: Thundering Herdのシミュレーション ---"
echo ""
echo "  docker exec -it ${REDIS_CONTAINER} bash /scripts/thundering-herd-demo.sh"
echo ""
echo "--- PostgreSQLに接続 ---"
echo ""
echo "  docker exec -it ${POSTGRES_CONTAINER} psql -U postgres -d handson"
echo ""
echo "--- 後片付け ---"
echo "  docker rm -f ${REDIS_CONTAINER} ${POSTGRES_CONTAINER}"
echo "  docker network rm ${NETWORK}"
