#!/bin/bash
# =============================================================================
# 第15回ハンズオン：Cassandra, DynamoDB——分散と結果整合性の世界
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: Docker（Cassandra 5.0 + DynamoDB Local 公式イメージを使用）
# メモリ: 4GB以上推奨（Cassandra 3ノード構成）
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-15"
CASS1="db-history-ep15-cass1"
CASS2="db-history-ep15-cass2"
CASS3="db-history-ep15-cass3"
DYNAMODB="db-history-ep15-dynamodb"
NETWORK="db-history-ep15-net"

echo "=== 第15回ハンズオン：Cassandra, DynamoDB——分散と結果整合性の世界 ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- 既存コンテナ・ネットワークの停止・削除 ---
for c in "${CASS1}" "${CASS2}" "${CASS3}" "${DYNAMODB}"; do
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
# Cassandra 3ノードクラスタの起動
# =============================================================================

echo "[Step 2] Cassandraノード1を起動しています..."
docker run -d \
    --name "${CASS1}" \
    --network "${NETWORK}" \
    -e CASSANDRA_CLUSTER_NAME="HandsonCluster" \
    -e CASSANDRA_DC="dc1" \
    -e CASSANDRA_RACK="rack1" \
    -e CASSANDRA_ENDPOINT_SNITCH="GossipingPropertyFileSnitch" \
    -e HEAP_NEWSIZE=128M \
    -e MAX_HEAP_SIZE=512M \
    cassandra:5.0 > /dev/null

echo "  ノード1の起動を待機中..."
for i in $(seq 1 120); do
    if docker exec "${CASS1}" cqlsh -e "SELECT now() FROM system.local" > /dev/null 2>&1; then
        echo "  ${CASS1} が起動しました。"
        break
    fi
    if [ "$i" -eq 120 ]; then
        echo "  エラー: ${CASS1} の起動がタイムアウトしました。"
        exit 1
    fi
    sleep 2
done

echo "[Step 3] Cassandraノード2を起動しています..."
docker run -d \
    --name "${CASS2}" \
    --network "${NETWORK}" \
    -e CASSANDRA_CLUSTER_NAME="HandsonCluster" \
    -e CASSANDRA_SEEDS="${CASS1}" \
    -e CASSANDRA_DC="dc1" \
    -e CASSANDRA_RACK="rack2" \
    -e CASSANDRA_ENDPOINT_SNITCH="GossipingPropertyFileSnitch" \
    -e HEAP_NEWSIZE=128M \
    -e MAX_HEAP_SIZE=512M \
    cassandra:5.0 > /dev/null

echo "  ノード2の起動を待機中..."
for i in $(seq 1 120); do
    if docker exec "${CASS2}" cqlsh -e "SELECT now() FROM system.local" > /dev/null 2>&1; then
        echo "  ${CASS2} が起動しました。"
        break
    fi
    if [ "$i" -eq 120 ]; then
        echo "  エラー: ${CASS2} の起動がタイムアウトしました。"
        exit 1
    fi
    sleep 2
done

echo "[Step 4] Cassandraノード3を起動しています..."
docker run -d \
    --name "${CASS3}" \
    --network "${NETWORK}" \
    -e CASSANDRA_CLUSTER_NAME="HandsonCluster" \
    -e CASSANDRA_SEEDS="${CASS1}" \
    -e CASSANDRA_DC="dc1" \
    -e CASSANDRA_RACK="rack3" \
    -e CASSANDRA_ENDPOINT_SNITCH="GossipingPropertyFileSnitch" \
    -e HEAP_NEWSIZE=128M \
    -e MAX_HEAP_SIZE=512M \
    cassandra:5.0 > /dev/null

echo "  ノード3の起動を待機中..."
for i in $(seq 1 120); do
    if docker exec "${CASS3}" cqlsh -e "SELECT now() FROM system.local" > /dev/null 2>&1; then
        echo "  ${CASS3} が起動しました。"
        break
    fi
    if [ "$i" -eq 120 ]; then
        echo "  エラー: ${CASS3} の起動がタイムアウトしました。"
        exit 1
    fi
    sleep 2
done

# クラスタ全体の安定化を待つ
echo "  クラスタの安定化を待機中..."
sleep 10

echo "[Step 5] Cassandraクラスタの状態を確認しています..."
docker exec "${CASS1}" nodetool status

# =============================================================================
# Cassandra キースペースとテーブルの作成
# =============================================================================

echo ""
echo "[Step 6] Cassandraにキースペースとデータを投入しています..."

docker exec -i "${CASS1}" cqlsh <<'CQL'
-- キースペースの作成（レプリケーションファクター3 = 全ノードにコピー）
CREATE KEYSPACE IF NOT EXISTS handson
WITH REPLICATION = {
    'class': 'SimpleStrategy',
    'replication_factor': 3
};

USE handson;

-- ユーザー投稿テーブル（クエリファースト設計）
-- アクセスパターン: 特定ユーザーの最新投稿をN件取得する
CREATE TABLE IF NOT EXISTS user_posts (
    user_id UUID,
    posted_at TIMESTAMP,
    post_id UUID,
    content TEXT,
    PRIMARY KEY ((user_id), posted_at, post_id)
) WITH CLUSTERING ORDER BY (posted_at DESC, post_id ASC);

-- サンプルデータの投入
INSERT INTO user_posts (user_id, posted_at, post_id, content)
VALUES (11111111-1111-1111-1111-111111111111, '2026-02-20 10:00:00', uuid(), 'First post by Alice');

INSERT INTO user_posts (user_id, posted_at, post_id, content)
VALUES (11111111-1111-1111-1111-111111111111, '2026-02-20 14:00:00', uuid(), 'Second post by Alice');

INSERT INTO user_posts (user_id, posted_at, post_id, content)
VALUES (11111111-1111-1111-1111-111111111111, '2026-02-21 09:00:00', uuid(), 'Third post by Alice');

INSERT INTO user_posts (user_id, posted_at, post_id, content)
VALUES (22222222-2222-2222-2222-222222222222, '2026-02-20 11:00:00', uuid(), 'First post by Bob');

INSERT INTO user_posts (user_id, posted_at, post_id, content)
VALUES (22222222-2222-2222-2222-222222222222, '2026-02-21 15:00:00', uuid(), 'Second post by Bob');

-- 確認
SELECT * FROM user_posts WHERE user_id = 11111111-1111-1111-1111-111111111111;
CQL

echo "  Cassandra: handson.user_posts にサンプルデータを投入しました。"

# =============================================================================
# DynamoDB Local の起動
# =============================================================================

echo ""
echo "[Step 7] DynamoDB Localを起動しています..."
docker run -d \
    --name "${DYNAMODB}" \
    --network "${NETWORK}" \
    amazon/dynamodb-local:latest > /dev/null

# DynamoDB Localの起動を待機
sleep 3
echo "  ${DYNAMODB} が起動しました。"

echo "[Step 8] DynamoDB Localにテーブルとデータを投入しています..."

# AWS CLIがDynamoDBコンテナ内にないため、別コンテナからアクセス
# DynamoDB Local用のコンテナ内でaws cliを使う

docker exec -i "${DYNAMODB}" sh -c 'cat > /tmp/create-table.json << "JSON"
{
    "TableName": "SingleTable",
    "KeySchema": [
        {"AttributeName": "PK", "KeyType": "HASH"},
        {"AttributeName": "SK", "KeyType": "RANGE"}
    ],
    "AttributeDefinitions": [
        {"AttributeName": "PK", "AttributeType": "S"},
        {"AttributeName": "SK", "AttributeType": "S"},
        {"AttributeName": "GSI1PK", "AttributeType": "S"},
        {"AttributeName": "GSI1SK", "AttributeType": "S"}
    ],
    "GlobalSecondaryIndexes": [
        {
            "IndexName": "GSI1",
            "KeySchema": [
                {"AttributeName": "GSI1PK", "KeyType": "HASH"},
                {"AttributeName": "GSI1SK", "KeyType": "RANGE"}
            ],
            "Projection": {"ProjectionType": "ALL"},
            "ProvisionedThroughput": {"ReadCapacityUnits": 5, "WriteCapacityUnits": 5}
        }
    ],
    "ProvisionedThroughput": {"ReadCapacityUnits": 5, "WriteCapacityUnits": 5}
}
JSON
'

docker exec "${DYNAMODB}" aws dynamodb create-table \
    --cli-input-json file:///tmp/create-table.json \
    --endpoint-url http://localhost:8000 --region local > /dev/null 2>&1

# シングルテーブル設計のサンプルデータ投入
docker exec "${DYNAMODB}" aws dynamodb batch-write-item \
    --endpoint-url http://localhost:8000 --region local \
    --request-items '{
        "SingleTable": [
            {
                "PutRequest": {
                    "Item": {
                        "PK": {"S": "USER#user-001"},
                        "SK": {"S": "PROFILE"},
                        "name": {"S": "Alice"},
                        "email": {"S": "alice@example.com"},
                        "created_at": {"S": "2026-01-01T00:00:00Z"},
                        "GSI1PK": {"S": "USER"},
                        "GSI1SK": {"S": "Alice"}
                    }
                }
            },
            {
                "PutRequest": {
                    "Item": {
                        "PK": {"S": "USER#user-001"},
                        "SK": {"S": "ORDER#2026-02-20T10:00:00Z#order-001"},
                        "total": {"N": "31000"},
                        "status": {"S": "shipped"},
                        "GSI1PK": {"S": "ORDER#shipped"},
                        "GSI1SK": {"S": "2026-02-20T10:00:00Z"}
                    }
                }
            },
            {
                "PutRequest": {
                    "Item": {
                        "PK": {"S": "USER#user-001"},
                        "SK": {"S": "ORDER#2026-02-21T09:00:00Z#order-003"},
                        "total": {"N": "41000"},
                        "status": {"S": "delivered"},
                        "GSI1PK": {"S": "ORDER#delivered"},
                        "GSI1SK": {"S": "2026-02-21T09:00:00Z"}
                    }
                }
            },
            {
                "PutRequest": {
                    "Item": {
                        "PK": {"S": "USER#user-002"},
                        "SK": {"S": "PROFILE"},
                        "name": {"S": "Bob"},
                        "email": {"S": "bob@example.com"},
                        "created_at": {"S": "2026-01-15T00:00:00Z"},
                        "GSI1PK": {"S": "USER"},
                        "GSI1SK": {"S": "Bob"}
                    }
                }
            },
            {
                "PutRequest": {
                    "Item": {
                        "PK": {"S": "USER#user-002"},
                        "SK": {"S": "ORDER#2026-02-20T14:30:00Z#order-002"},
                        "total": {"N": "45000"},
                        "status": {"S": "shipped"},
                        "GSI1PK": {"S": "ORDER#shipped"},
                        "GSI1SK": {"S": "2026-02-20T14:30:00Z"}
                    }
                }
            }
        ]
    }' > /dev/null 2>&1

echo "  DynamoDB Local: SingleTable にシングルテーブル設計のサンプルデータを投入しました。"

# =============================================================================
# 完了メッセージ
# =============================================================================

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "--- 演習1: Cassandraクラスタの確認 ---"
echo ""
echo "クラスタ状態の確認:"
echo "  docker exec -it ${CASS1} nodetool status"
echo ""
echo "cqlshでCassandraに接続:"
echo "  docker exec -it ${CASS1} cqlsh"
echo ""
echo "--- 演習2: 一貫性レベルの比較 ---"
echo ""
echo "cqlsh内で一貫性レベルを変更:"
echo "  CONSISTENCY ONE;"
echo "  CONSISTENCY QUORUM;"
echo "  CONSISTENCY ALL;"
echo "  SELECT * FROM handson.user_posts WHERE user_id = 11111111-1111-1111-1111-111111111111;"
echo ""
echo "--- 演習3: ノード障害時の挙動 ---"
echo ""
echo "ノード3を停止:"
echo "  docker stop ${CASS3}"
echo ""
echo "一貫性レベルごとの書き込みテスト:"
echo "  CONSISTENCY ONE;    -- 成功する"
echo "  CONSISTENCY QUORUM; -- 成功する（2/3 >= QUORUM）"
echo "  CONSISTENCY ALL;    -- 失敗する（3ノード必要だが2ノードしか生存していない）"
echo ""
echo "ノード3を復旧:"
echo "  docker start ${CASS3}"
echo ""
echo "--- 演習4: DynamoDB Localでシングルテーブル設計 ---"
echo ""
echo "テーブル一覧:"
echo "  docker exec -it ${DYNAMODB} aws dynamodb list-tables --endpoint-url http://localhost:8000 --region local"
echo ""
echo "ユーザープロフィール取得:"
echo "  docker exec -it ${DYNAMODB} aws dynamodb get-item --table-name SingleTable \\"
echo "    --key '{\"PK\": {\"S\": \"USER#user-001\"}, \"SK\": {\"S\": \"PROFILE\"}}' \\"
echo "    --endpoint-url http://localhost:8000 --region local"
echo ""
echo "ユーザーの注文一覧:"
echo "  docker exec -it ${DYNAMODB} aws dynamodb query --table-name SingleTable \\"
echo "    --key-condition-expression 'PK = :pk AND begins_with(SK, :sk)' \\"
echo "    --expression-attribute-values '{\":pk\": {\"S\": \"USER#user-001\"}, \":sk\": {\"S\": \"ORDER#\"}}' \\"
echo "    --endpoint-url http://localhost:8000 --region local --output table"
echo ""
echo "--- 後片付け ---"
echo "  docker rm -f ${CASS1} ${CASS2} ${CASS3} ${DYNAMODB}"
echo "  docker network rm ${NETWORK}"
