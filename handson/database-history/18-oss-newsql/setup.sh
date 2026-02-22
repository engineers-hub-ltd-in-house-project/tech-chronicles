#!/bin/bash
# =============================================================================
# 第18回ハンズオン：CockroachDB 3ノードクラスタでNewSQLを体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: docker
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-18"
NETWORK_NAME="roachnet"
NODE1="roach1"
NODE2="roach2"
NODE3="roach3"
COCKROACH_IMAGE="cockroachdb/cockroach:latest"
DATABASE="bankdb"

echo "=== 第18回ハンズオン：CockroachDB 3ノードクラスタでNewSQLを体験する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- クリーンアップ ---
echo "[準備] 既存のコンテナとネットワークをクリーンアップ"
docker rm -f "${NODE1}" "${NODE2}" "${NODE3}" 2>/dev/null || true
docker network rm "${NETWORK_NAME}" 2>/dev/null || true
echo ""

# --- Dockerネットワークの作成 ---
echo "[準備] Dockerネットワークを作成"
docker network create "${NETWORK_NAME}"
echo "  ネットワーク '${NETWORK_NAME}' を作成した"
echo ""

# --- 3ノードクラスタの起動 ---
echo "[準備] CockroachDB 3ノードクラスタを起動"
echo ""

echo "  Node 1 を起動中..."
docker run -d \
  --name "${NODE1}" \
  --hostname "${NODE1}" \
  --network "${NETWORK_NAME}" \
  -p 26257:26257 \
  -p 8080:8080 \
  "${COCKROACH_IMAGE}" start \
  --insecure \
  --join="${NODE1},${NODE2},${NODE3}" \
  --advertise-addr="${NODE1}"

echo "  Node 2 を起動中..."
docker run -d \
  --name "${NODE2}" \
  --hostname "${NODE2}" \
  --network "${NETWORK_NAME}" \
  "${COCKROACH_IMAGE}" start \
  --insecure \
  --join="${NODE1},${NODE2},${NODE3}" \
  --advertise-addr="${NODE2}"

echo "  Node 3 を起動中..."
docker run -d \
  --name "${NODE3}" \
  --hostname "${NODE3}" \
  --network "${NETWORK_NAME}" \
  "${COCKROACH_IMAGE}" start \
  --insecure \
  --join="${NODE1},${NODE2},${NODE3}" \
  --advertise-addr="${NODE3}"

echo ""
echo "  ノードの起動を待機中..."
sleep 10

# --- クラスタの初期化 ---
echo "[準備] クラスタを初期化"
docker exec "${NODE1}" cockroach init --insecure
echo "  クラスタの初期化が完了した"
echo ""

# ノードの状態確認
echo "  === クラスタのノード状態 ==="
docker exec "${NODE1}" cockroach sql --insecure \
  -e "SELECT node_id, address, is_live FROM crdb_internal.gossip_nodes ORDER BY node_id;" 2>/dev/null || true
echo ""

# --- 演習1: PostgreSQL互換SQLの実行 ---
echo "[演習1] PostgreSQL互換SQLの実行"
echo ""

docker exec "${NODE1}" cockroach sql --insecure -e "
CREATE DATABASE IF NOT EXISTS ${DATABASE};
" 2>/dev/null

docker exec "${NODE1}" cockroach sql --insecure --database="${DATABASE}" -e "
CREATE TABLE IF NOT EXISTS accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner STRING NOT NULL,
  balance INT NOT NULL CHECK (balance >= 0),
  created_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO accounts (owner, balance) VALUES
  ('Alice', 100000),
  ('Bob', 50000),
  ('Charlie', 75000);
" 2>/dev/null

echo "  === 初期データ ==="
docker exec "${NODE1}" cockroach sql --insecure --database="${DATABASE}" \
  -e "SELECT owner, balance FROM accounts ORDER BY owner;" 2>/dev/null
echo ""

echo "  >>> PostgreSQL互換のSQLが分散クラスタ上で動作した"
echo ""

# --- 演習2: 分散トランザクション（送金処理） ---
echo "[演習2] 分散トランザクション（送金処理）"
echo ""

echo "  === 送金前の残高 ==="
docker exec "${NODE1}" cockroach sql --insecure --database="${DATABASE}" \
  -e "SELECT owner, balance FROM accounts ORDER BY owner;" 2>/dev/null

echo "  送金1: Alice -> Bob に 30,000 を送金"
docker exec "${NODE1}" cockroach sql --insecure --database="${DATABASE}" -e "
BEGIN;
  UPDATE accounts SET balance = balance - 30000 WHERE owner = 'Alice';
  UPDATE accounts SET balance = balance + 30000 WHERE owner = 'Bob';
COMMIT;
" 2>/dev/null
echo "  送金1 完了"

echo "  送金2: Bob -> Charlie に 15,000 を送金"
docker exec "${NODE1}" cockroach sql --insecure --database="${DATABASE}" -e "
BEGIN;
  UPDATE accounts SET balance = balance - 15000 WHERE owner = 'Bob';
  UPDATE accounts SET balance = balance + 15000 WHERE owner = 'Charlie';
COMMIT;
" 2>/dev/null
echo "  送金2 完了"

echo "  送金3: Charlie -> Alice に 5,000 を送金"
docker exec "${NODE1}" cockroach sql --insecure --database="${DATABASE}" -e "
BEGIN;
  UPDATE accounts SET balance = balance - 5000 WHERE owner = 'Charlie';
  UPDATE accounts SET balance = balance + 5000 WHERE owner = 'Alice';
COMMIT;
" 2>/dev/null
echo "  送金3 完了"
echo ""

echo "  === 送金後の残高 ==="
docker exec "${NODE1}" cockroach sql --insecure --database="${DATABASE}" \
  -e "SELECT owner, balance FROM accounts ORDER BY owner;" 2>/dev/null

echo "  === 合計額の確認 ==="
docker exec "${NODE1}" cockroach sql --insecure --database="${DATABASE}" \
  -e "SELECT SUM(balance) AS total FROM accounts;" 2>/dev/null
echo "  >>> 合計額が 225,000 のまま: トランザクションの原子性が保証されている"
echo ""

# 残高不足の送金
echo "  送金4: Alice -> Bob に 999,999 を送金（残高不足）"
docker exec "${NODE1}" cockroach sql --insecure --database="${DATABASE}" -e "
BEGIN;
  UPDATE accounts SET balance = balance - 999999 WHERE owner = 'Alice';
  UPDATE accounts SET balance = balance + 999999 WHERE owner = 'Bob';
COMMIT;
" 2>/dev/null || echo "  >>> 送金4 失敗: CHECK制約により残高不足が検出され、トランザクションがロールバックされた"
echo ""

# --- 演習3: ノード障害と自動復旧 ---
echo "[演習3] ノード障害と自動復旧"
echo ""

echo "  Node 3 を強制停止..."
docker stop "${NODE3}"
echo "  Node 3 が停止した"
echo ""

sleep 5

echo "  === 残り2ノードでのクエリ実行 ==="
docker exec "${NODE1}" cockroach sql --insecure --database="${DATABASE}" \
  -e "SELECT owner, balance FROM accounts ORDER BY owner;" 2>/dev/null
echo "  >>> Node 3 がダウンしても、残り2ノード（過半数）でクエリが継続した"
echo ""

echo "  残り2ノードで送金トランザクションを実行"
docker exec "${NODE1}" cockroach sql --insecure --database="${DATABASE}" -e "
BEGIN;
  UPDATE accounts SET balance = balance - 1000 WHERE owner = 'Alice';
  UPDATE accounts SET balance = balance + 1000 WHERE owner = 'Bob';
COMMIT;
" 2>/dev/null
echo "  >>> 書き込みトランザクションもNode障害中に実行できた"
echo ""

echo "  Node 3 を復帰..."
docker start "${NODE3}"
echo "  Node 3 が復帰した。データの自動同期を待機中..."
sleep 10

echo "  === Node 3 からのクエリ実行 ==="
docker exec "${NODE3}" cockroach sql --insecure --database="${DATABASE}" \
  -e "SELECT owner, balance FROM accounts ORDER BY owner;" 2>/dev/null
echo "  >>> Node 3 が復帰後、障害中の変更も含めてデータが自動同期された"
echo ""

# --- 演習4: Rangeの分散状況確認 ---
echo "[演習4] Rangeの分散状況確認"
echo ""

echo "  === accounts テーブルのRange分散 ==="
docker exec "${NODE1}" cockroach sql --insecure --database="${DATABASE}" \
  -e "SHOW RANGES FROM TABLE accounts;" 2>/dev/null
echo ""

echo "  === クラスタのノード状態（最終確認） ==="
docker exec "${NODE1}" cockroach sql --insecure \
  -e "SELECT node_id, address, is_live FROM crdb_internal.gossip_nodes ORDER BY node_id;" 2>/dev/null
echo ""

echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "CockroachDB クラスタ:"
echo "  Node 1: ${NODE1} (SQL: localhost:26257, Web UI: http://localhost:8080)"
echo "  Node 2: ${NODE2}"
echo "  Node 3: ${NODE3}"
echo ""
echo "SQLクライアントの接続:"
echo "  docker exec -it ${NODE1} cockroach sql --insecure --database=${DATABASE}"
echo ""
echo "Web UIの確認:"
echo "  http://localhost:8080"
echo ""
echo "後片付け:"
echo "  docker rm -f ${NODE1} ${NODE2} ${NODE3}"
echo "  docker network rm ${NETWORK_NAME}"
