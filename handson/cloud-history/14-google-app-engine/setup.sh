#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-14"

echo "============================================"
echo " クラウドの考古学 第14回 ハンズオン"
echo " Google App Engine——Googleスケールの約束と制約"
echo " GAEの「制約による設計」を体験する"
echo "============================================"
echo ""

# -----------------------------------------------
echo ">>> 環境セットアップ"
# -----------------------------------------------
apt-get update -qq && apt-get install -y -qq python3 python3-pip python3-venv curl > /dev/null 2>&1
echo "必要なパッケージをインストールしました"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# -----------------------------------------------
echo ">>> 演習1: GAEのサンドボックス制約を再現する"
# -----------------------------------------------
echo "制約なしアプリケーションの問題点を確認します..."

cat > app_unconstrained.py << 'PYEOF'
"""制約なしのWebアプリケーション（従来型の設計）"""
import os
import json
import time

def save_user_data(user_id, data):
    os.makedirs("/tmp/userdata", exist_ok=True)
    filepath = f"/tmp/userdata/{user_id}.json"
    with open(filepath, "w") as f:
        json.dump(data, f)
    return filepath

def load_user_data(user_id):
    filepath = f"/tmp/userdata/{user_id}.json"
    if os.path.exists(filepath):
        with open(filepath) as f:
            return json.load(f)
    return None

print("=== 制約なしアプリケーション ===")
path = save_user_data("user123", {"name": "Alice", "score": 100})
print(f"データ保存: {path}")
data = load_user_data("user123")
print(f"データ読込: {data}")
print(f"ファイルが存在: {os.path.exists(path)}")
print()
print("問題点:")
print("  1. データがローカルファイルシステムに依存")
print("     -> インスタンスが再作成されるとデータ消失")
print("  2. 別のインスタンスからは同じデータにアクセスできない")
print("     -> スケールアウト時にデータの不整合が発生")
print("  3. 120秒の処理はリクエストタイムアウトに引っかかる")
PYEOF

python3 app_unconstrained.py
echo ""

# -----------------------------------------------
echo ">>> 演習2: Datastoreの制約（JOINなし、非正規化）を体験する"
# -----------------------------------------------
echo "Datastore Simulatorで非正規化設計を体験します..."

cat > app_constrained.py << 'PYEOF'
"""GAEの制約に従ったアプリケーション設計"""
import json
import time

class DatastoreSimulator:
    """GAE Datastoreの簡易シミュレータ"""
    def __init__(self):
        self._entities = {}
        self._group_timestamps = {}

    def put(self, kind, key, entity, entity_group=None):
        group = entity_group or key
        now = time.time()
        if group in self._group_timestamps:
            elapsed = now - self._group_timestamps[group]
            if elapsed < 1.0:
                print(f"  警告: Entity Group '{group}' の更新間隔が"
                      f"短すぎます ({elapsed:.3f}秒)")
        if kind not in self._entities:
            self._entities[kind] = {}
        self._entities[kind][key] = {**entity, '_key': key}
        self._group_timestamps[group] = now

    def get(self, kind, key):
        return self._entities.get(kind, {}).get(key)

ds = DatastoreSimulator()

print("=== Datastore: JOINなしの世界 ===")
print()
ds.put("UserProfile", "user123", {
    "name": "Alice", "score": 100,
    "bio": "Engineer", "posts_count": 42
})
print("RDBMSの場合:")
print("  SELECT u.name, p.bio FROM users u")
print("  JOIN profiles p ON u.id = p.user_id")
print()
print("Datastoreの場合:")
print("  -> JOINできない。関連データを同一エンティティに格納")
profile = ds.get("UserProfile", "user123")
print(f"  非正規化されたデータ: {profile}")
print()

print("=== Entity Group更新頻度の制約 ===")
for i in range(3):
    ds.put("Counter", "global", {"count": i}, entity_group="counters")
    time.sleep(0.2)
print("-> 高頻度更新はシャーディングで対処する")
PYEOF

python3 app_constrained.py
echo ""

# -----------------------------------------------
echo ">>> 演習3: ファイルシステム制約とタイムアウトの影響"
# -----------------------------------------------
echo "マルチインスタンス環境とTask Queueパターンを体験します..."

cat > constraints_demo.py << 'PYEOF'
"""GAEの制約がスケーラビリティに与える影響"""
import os, json, tempfile, shutil, uuid
from collections import deque

print("=== ファイルシステム制約とスケーラビリティ ===")
print()
inst_a = tempfile.mkdtemp(prefix="instance_a_")
inst_b = tempfile.mkdtemp(prefix="instance_b_")

with open(os.path.join(inst_a, "session.json"), "w") as f:
    json.dump({"user": "Alice", "cart": ["item1"]}, f)
print("インスタンスA: セッション保存（ローカルFS）")
print(f"インスタンスB: 同じセッション -> "
      f"存在しない ({os.path.exists(os.path.join(inst_b, 'session.json'))})")
print("-> ファイルシステム書き込み禁止は、マルチインスタンス環境での")
print("   データ整合性を保証するための制約")
shutil.rmtree(inst_a); shutil.rmtree(inst_b)
print()

print("=== 60秒タイムアウトと非同期処理 ===")
print()
TIMEOUT = 60
items = list(range(50))
total = len(items) * 2
print(f"同期処理: {len(items)}件 x 2秒 = {total}秒 > {TIMEOUT}秒制限")
print("-> DeadlineExceededError!")
print()

queue = deque()
batches = [items[i:i+10] for i in range(0, len(items), 10)]
print(f"非同期処理: {len(batches)}バッチに分割してTask Queueに委譲")
for i, batch in enumerate(batches):
    tid = str(uuid.uuid4())[:8]
    queue.append({"id": tid, "batch": i})
    print(f"  キューに追加: batch_{i} (ID: {tid})")
print("-> リクエストは即座にタスクIDリストを返却")
print("-> バックグラウンドで各バッチが順次処理される")
print()
print("設計原則:")
print("  1. リクエストハンドラは60秒以内に完了する")
print("  2. 長時間処理はTask Queue（現Cloud Tasks）に委譲")
print("  3. この設計はマイクロサービスの非同期パターンと同一")
PYEOF

python3 constraints_demo.py
echo ""

# -----------------------------------------------
echo "============================================"
echo " ハンズオン完了"
echo ""
echo " 学んだこと:"
echo "  1. ファイルシステム書き込み禁止 = ステートレス設計の要求"
echo "  2. Datastoreの非正規化 = スケーラビリティのためのトレードオフ"
echo "  3. 60秒タイムアウト = 非同期処理パターンの必然性"
echo "  4. GAEの制約はすべて分散システムの設計原則に根ざしている"
echo "============================================"
