#!/bin/bash
# =============================================================================
# 第17回ハンズオン：Cloud Spannerエミュレータで分散トランザクションを体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: docker, python3, pip
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-17"
CONTAINER_NAME="db-history-ep17-spanner"
EMULATOR_HOST="localhost:9010"
INSTANCE_ID="test-instance"
DATABASE_ID="test-database"

echo "=== 第17回ハンズオン：Cloud Spannerエミュレータで分散トランザクションを体験する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- Spannerエミュレータの起動 ---
echo "[準備] Cloud Spannerエミュレータを起動"
echo ""

# 既存コンテナの停止
docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

docker run -d \
  --name "${CONTAINER_NAME}" \
  -p 9010:9010 \
  -p 9020:9020 \
  gcr.io/cloud-spanner-emulator/emulator:latest

echo "  エミュレータを起動中..."
sleep 5

# エミュレータの接続確認
for i in $(seq 1 10); do
  if curl -s "http://localhost:9020/" > /dev/null 2>&1; then
    echo "  エミュレータが起動した"
    break
  fi
  if [ "$i" -eq 10 ]; then
    echo "  エラー: エミュレータの起動に失敗した"
    exit 1
  fi
  sleep 2
done
echo ""

# --- Python環境のセットアップ ---
echo "[準備] Python依存ライブラリのインストール"
echo ""

pip install --quiet google-cloud-spanner 2>/dev/null || pip install --quiet --break-system-packages google-cloud-spanner

echo "  google-cloud-spanner インストール完了"
echo ""

# --- 演習1: スキーマ作成とデータ投入 ---
echo "[演習1] スキーマ作成とデータ投入"
echo ""

cat > "${WORKDIR}/setup_database.py" << 'PYEOF'
"""Spannerエミュレータにインスタンス・データベース・テーブルを作成し、初期データを投入する"""
import os

os.environ["SPANNER_EMULATOR_HOST"] = "localhost:9010"

from google.cloud import spanner
from google.cloud.spanner_admin_instance_v1.types import spanner_instance_admin

PROJECT_ID = "test-project"
INSTANCE_ID = "test-instance"
DATABASE_ID = "test-database"

client = spanner.Client(project=PROJECT_ID)

# インスタンスの作成
print("  インスタンスを作成中...")
instance = client.instance(
    INSTANCE_ID,
    configuration_name=f"projects/{PROJECT_ID}/instanceConfigs/emulator-config",
    display_name="Test Instance",
    node_count=1,
)
operation = instance.create()
operation.result(timeout=30)
print(f"  インスタンス '{INSTANCE_ID}' を作成した")

# データベースとテーブルの作成
print("  データベースとテーブルを作成中...")
database = instance.database(
    DATABASE_ID,
    ddl_statements=[
        """CREATE TABLE Accounts (
            AccountId   INT64 NOT NULL,
            Owner       STRING(100) NOT NULL,
            Balance     INT64 NOT NULL,
            UpdatedAt   TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true)
        ) PRIMARY KEY (AccountId)""",
        """CREATE TABLE TransferLog (
            TransferId  STRING(36) NOT NULL,
            FromAccount INT64 NOT NULL,
            ToAccount   INT64 NOT NULL,
            Amount      INT64 NOT NULL,
            CreatedAt   TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true)
        ) PRIMARY KEY (TransferId)""",
    ],
)
operation = database.create()
operation.result(timeout=30)
print(f"  データベース '{DATABASE_ID}' を作成した")

# 初期データの投入
print("  初期データを投入中...")
with database.batch() as batch:
    batch.insert(
        table="Accounts",
        columns=["AccountId", "Owner", "Balance", "UpdatedAt"],
        values=[
            [1, "Alice", 100000, spanner.COMMIT_TIMESTAMP],
            [2, "Bob", 50000, spanner.COMMIT_TIMESTAMP],
            [3, "Charlie", 75000, spanner.COMMIT_TIMESTAMP],
        ],
    )
print("  初期データを投入した")

# データの確認
print("")
print("  === 現在の口座残高 ===")
with database.snapshot() as snapshot:
    results = snapshot.execute_sql(
        "SELECT AccountId, Owner, Balance FROM Accounts ORDER BY AccountId"
    )
    for row in results:
        print(f"  Account {row[0]}: {row[1]}, Balance={row[2]:,}")
print("")
PYEOF

python3 "${WORKDIR}/setup_database.py"

# --- 演習2: 分散トランザクション（送金処理） ---
echo "[演習2] 分散トランザクション（送金処理）"
echo ""

cat > "${WORKDIR}/transfer.py" << 'PYEOF'
"""Spannerの分散トランザクションで送金を実行する"""
import os
import uuid

os.environ["SPANNER_EMULATOR_HOST"] = "localhost:9010"

from google.cloud import spanner

PROJECT_ID = "test-project"
INSTANCE_ID = "test-instance"
DATABASE_ID = "test-database"

client = spanner.Client(project=PROJECT_ID)
instance = client.instance(INSTANCE_ID)
database = instance.database(DATABASE_ID)


def transfer(from_account, to_account, amount):
    """送金処理を分散トランザクションで実行する"""

    def transfer_funds(transaction):
        # 送金元の残高を確認
        row = list(
            transaction.read(
                table="Accounts",
                columns=["Balance"],
                keyset=spanner.KeySet(keys=[[from_account]]),
            )
        )
        from_balance = row[0][0]

        if from_balance < amount:
            raise ValueError(
                f"残高不足: 残高 {from_balance:,} < 送金額 {amount:,}"
            )

        # 送金先の残高を確認
        row = list(
            transaction.read(
                table="Accounts",
                columns=["Balance"],
                keyset=spanner.KeySet(keys=[[to_account]]),
            )
        )
        to_balance = row[0][0]

        # 両方の残高を更新（アトミックに実行される）
        transaction.update(
            table="Accounts",
            columns=["AccountId", "Balance", "UpdatedAt"],
            values=[
                [from_account, from_balance - amount, spanner.COMMIT_TIMESTAMP],
                [to_account, to_balance + amount, spanner.COMMIT_TIMESTAMP],
            ],
        )

        # 送金ログを記録
        transaction.insert(
            table="TransferLog",
            columns=["TransferId", "FromAccount", "ToAccount", "Amount", "CreatedAt"],
            values=[
                [
                    str(uuid.uuid4()),
                    from_account,
                    to_account,
                    amount,
                    spanner.COMMIT_TIMESTAMP,
                ]
            ],
        )

    database.run_in_transaction(transfer_funds)


# 送金の実行
print("  === 送金前の残高 ===")
with database.snapshot() as snapshot:
    results = snapshot.execute_sql(
        "SELECT AccountId, Owner, Balance FROM Accounts ORDER BY AccountId"
    )
    total_before = 0
    for row in results:
        print(f"  Account {row[0]}: {row[1]}, Balance={row[2]:,}")
        total_before += row[2]
    print(f"  合計: {total_before:,}")
print("")

print("  送金1: Alice → Bob に 30,000 を送金")
transfer(1, 2, 30000)
print("  送金1 完了")

print("  送金2: Bob → Charlie に 15,000 を送金")
transfer(2, 3, 15000)
print("  送金2 完了")

print("  送金3: Charlie → Alice に 5,000 を送金")
transfer(3, 1, 5000)
print("  送金3 完了")
print("")

print("  === 送金後の残高 ===")
with database.snapshot() as snapshot:
    results = snapshot.execute_sql(
        "SELECT AccountId, Owner, Balance FROM Accounts ORDER BY AccountId"
    )
    total_after = 0
    for row in results:
        print(f"  Account {row[0]}: {row[1]}, Balance={row[2]:,}")
        total_after += row[2]
    print(f"  合計: {total_after:,}")
print("")

print(f"  送金前合計: {total_before:,}")
print(f"  送金後合計: {total_after:,}")
if total_before == total_after:
    print("  >>> 合計額が一致: トランザクションの原子性が保証されている")
else:
    print("  >>> 合計額が不一致: データの不整合が発生している（異常）")
print("")

# 送金ログの確認
print("  === 送金ログ ===")
with database.snapshot() as snapshot:
    results = snapshot.execute_sql(
        "SELECT TransferId, FromAccount, ToAccount, Amount, CreatedAt "
        "FROM TransferLog ORDER BY CreatedAt"
    )
    for row in results:
        print(f"  {row[0][:8]}... : Account {row[1]} → Account {row[2]}, Amount={row[3]:,}")
print("")

# 残高不足の送金を試みる
print("  送金4: Alice → Bob に 999,999 を送金（残高不足）")
try:
    transfer(1, 2, 999999)
    print("  送金4 完了（想定外）")
except Exception as e:
    print(f"  >>> 送金4 失敗: {e}")
    print("  >>> トランザクションがロールバックされ、残高は変更されていない")
print("")
PYEOF

python3 "${WORKDIR}/transfer.py"

# --- 演習3: 読み取りモードの比較 ---
echo "[演習3] 読み取りモードの比較"
echo ""

cat > "${WORKDIR}/read_modes.py" << 'PYEOF'
"""Spannerの読み取りモードの違いを体験する"""
import os
import datetime

os.environ["SPANNER_EMULATOR_HOST"] = "localhost:9010"

from google.cloud import spanner

PROJECT_ID = "test-project"
INSTANCE_ID = "test-instance"
DATABASE_ID = "test-database"

client = spanner.Client(project=PROJECT_ID)
instance = client.instance(INSTANCE_ID)
database = instance.database(DATABASE_ID)

# 1. 強い読み取り（Strong Read）
print("  === 1. Strong Read（最新データ） ===")
print("  Paxosリーダーに問い合わせて最新データを返す")
with database.snapshot() as snapshot:
    results = snapshot.execute_sql(
        "SELECT AccountId, Owner, Balance FROM Accounts ORDER BY AccountId"
    )
    for row in results:
        print(f"    Account {row[0]}: {row[1]}, Balance={row[2]:,}")
print("")

# 2. ステイル読み取り（Stale Read）
print("  === 2. Stale Read（15秒前のスナップショット） ===")
print("  リーダーに問い合わせず、最寄りのレプリカから読む")
print("  （エミュレータではStrong Readと同じ結果になる）")
staleness = datetime.timedelta(seconds=15)
with database.snapshot(exact_staleness=staleness) as snapshot:
    results = snapshot.execute_sql(
        "SELECT AccountId, Owner, Balance FROM Accounts ORDER BY AccountId"
    )
    for row in results:
        print(f"    Account {row[0]}: {row[1]}, Balance={row[2]:,}")
print("")

# 3. 読み取り専用トランザクション
print("  === 3. Read-Only Transaction ===")
print("  複数クエリが同一スナップショットで一貫した結果を返す")
with database.snapshot(multi_use=True) as snapshot:
    # クエリ1: 合計
    results1 = snapshot.execute_sql("SELECT SUM(Balance) AS total FROM Accounts")
    total = list(results1)[0][0]

    # クエリ2: 個別残高の合計
    results2 = snapshot.execute_sql(
        "SELECT AccountId, Balance FROM Accounts ORDER BY AccountId"
    )
    individual_total = 0
    for row in results2:
        individual_total += row[1]

    print(f"    SUM(Balance):         {total:,}")
    print(f"    個別残高の手動合計:   {individual_total:,}")
    if total == individual_total:
        print("    >>> 一致: 同一スナップショットで読み取った結果は常に一貫している")
    else:
        print("    >>> 不一致: スナップショットの一貫性が破れている（異常）")
print("")

# 4. SQLクエリの実行
print("  === 4. SQLクエリの実行例 ===")
print("  SpannerはGoogleSQL（SQL互換）をサポートする")
with database.snapshot() as snapshot:
    # 残高が50,000以上の口座
    results = snapshot.execute_sql(
        "SELECT Owner, Balance FROM Accounts WHERE Balance >= 50000 ORDER BY Balance DESC"
    )
    print("  残高 50,000 以上の口座:")
    for row in results:
        print(f"    {row[0]}: {row[1]:,}")
    print("")

    # 口座数と平均残高
    results = snapshot.execute_sql(
        "SELECT COUNT(*) AS cnt, AVG(Balance) AS avg_balance FROM Accounts"
    )
    row = list(results)[0]
    print(f"  口座数: {row[0]}")
    print(f"  平均残高: {row[1]:,.0f}")
print("")
PYEOF

python3 "${WORKDIR}/read_modes.py"

echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "Spannerエミュレータ: ${CONTAINER_NAME}"
echo "  gRPC: localhost:9010"
echo "  REST: localhost:9020"
echo ""
echo "Pythonスクリプトを個別に実行する場合:"
echo "  export SPANNER_EMULATOR_HOST=localhost:9010"
echo "  python3 ${WORKDIR}/transfer.py"
echo "  python3 ${WORKDIR}/read_modes.py"
echo ""
echo "後片付け:"
echo "  docker rm -f ${CONTAINER_NAME}"
