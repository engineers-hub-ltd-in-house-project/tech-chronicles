#!/bin/bash
# =============================================================================
# 第1回ハンズオン：テキストファイルでデータベースを「再発明」する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: python3 (Ubuntu 24.04に標準搭載)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-01"

echo "=== 第1回ハンズオン：テキストファイルでデータベースを「再発明」する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- 演習1: CSVベースのCRUDを実装する ---
echo "[演習1] CSVベースのCRUD操作"
echo ""

cat > "${WORKDIR}/filedb.py" << 'PYEOF'
# filedb.py -- テキストファイルによる簡易データ管理
import csv
import os

DATA_FILE = "users.csv"
FIELDNAMES = ["id", "name", "email", "age"]

def init_db():
    """データファイルを初期化する"""
    if not os.path.exists(DATA_FILE):
        with open(DATA_FILE, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
            writer.writeheader()

def create_user(name, email, age):
    """ユーザーを追加する"""
    next_id = 1
    with open(DATA_FILE, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            next_id = int(row["id"]) + 1

    with open(DATA_FILE, "a", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
        writer.writerow({
            "id": next_id,
            "name": name,
            "email": email,
            "age": age,
        })
    return next_id

def read_user(user_id):
    """IDでユーザーを検索する"""
    with open(DATA_FILE, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if int(row["id"]) == user_id:
                return row
    return None

def read_all_users():
    """全ユーザーを取得する"""
    with open(DATA_FILE, "r") as f:
        reader = csv.DictReader(f)
        return list(reader)

def update_user(user_id, **kwargs):
    """ユーザー情報を更新する"""
    rows = read_all_users()
    updated = False
    for row in rows:
        if int(row["id"]) == user_id:
            row.update(kwargs)
            updated = True
    if updated:
        with open(DATA_FILE, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
            writer.writeheader()
            writer.writerows(rows)
    return updated

def delete_user(user_id):
    """ユーザーを削除する"""
    rows = read_all_users()
    new_rows = [r for r in rows if int(r["id"]) != user_id]
    if len(new_rows) < len(rows):
        with open(DATA_FILE, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
            writer.writeheader()
            writer.writerows(new_rows)
        return True
    return False

if __name__ == "__main__":
    init_db()
    uid = create_user("Alice", "alice@example.com", 30)
    print(f"Created user with id={uid}")
    create_user("Bob", "bob@example.com", 25)
    create_user("Charlie", "charlie@example.com", 35)

    print(f"Read user 1: {read_user(1)}")
    print(f"All users: {read_all_users()}")

    update_user(2, name="Robert", age=26)
    print(f"Updated user 2: {read_user(2)}")

    delete_user(3)
    print(f"After delete: {read_all_users()}")
PYEOF

python3 "${WORKDIR}/filedb.py"
echo ""
echo "  CSVファイルの内容:"
cat "${WORKDIR}/users.csv"
echo ""

# --- 演習2: 検索性能のベンチマーク ---
echo "[演習2] 検索性能のベンチマーク"
echo ""

cat > "${WORKDIR}/bench_search.py" << 'PYEOF'
# bench_search.py -- 検索性能のベンチマーク
import csv
import time
import random
import string

DATA_FILE = "users_large.csv"
FIELDNAMES = ["id", "name", "email", "age"]

def generate_large_dataset(n):
    """N件のランダムデータを生成する"""
    print(f"  Generating {n} records...")
    with open(DATA_FILE, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
        writer.writeheader()
        for i in range(1, n + 1):
            name = "".join(random.choices(string.ascii_lowercase, k=8))
            writer.writerow({
                "id": i,
                "name": name,
                "email": f"{name}@example.com",
                "age": random.randint(18, 65),
            })
    print(f"  Generated {n} records.")

def search_by_id(target_id):
    """IDで検索する（シーケンシャルスキャン）"""
    with open(DATA_FILE, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if int(row["id"]) == target_id:
                return row
    return None

if __name__ == "__main__":
    N = 100000
    generate_large_dataset(N)

    target_id = N
    start = time.perf_counter()
    for _ in range(10):
        search_by_id(target_id)
    elapsed = (time.perf_counter() - start) / 10
    print(f"  Search by ID (seq scan, {N} rows): {elapsed:.4f} sec")
    print(f"")
    print(f"  --- 参考 ---")
    print(f"  データベース(B+Treeインデックス)なら、")
    print(f"  10万行でも数十マイクロ秒で検索が完了する。")
    print(f"  差は数十倍から数百倍になる。")
PYEOF

python3 "${WORKDIR}/bench_search.py"
echo ""

# --- 演習3: 並行アクセスによるデータ破壊 ---
echo "[演習3] 並行アクセスによるデータ破壊"
echo ""

cat > "${WORKDIR}/race_condition.py" << 'PYEOF'
# race_condition.py -- 並行アクセスによるデータ破壊を体験する
import csv
import os
import multiprocessing
import time

DATA_FILE = "counter.csv"

def init_counter():
    """カウンタを初期化する"""
    with open(DATA_FILE, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["counter"])
        writer.writerow([0])

def read_counter():
    """カウンタの現在値を読む"""
    with open(DATA_FILE, "r") as f:
        reader = csv.reader(f)
        next(reader)
        return int(next(reader)[0])

def write_counter(value):
    """カウンタの値を書き込む"""
    with open(DATA_FILE, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["counter"])
        writer.writerow([value])

def increment_counter(n_times):
    """カウンタをN回インクリメントする（ロックなし）"""
    for _ in range(n_times):
        current = read_counter()
        time.sleep(0.0001)
        write_counter(current + 1)

if __name__ == "__main__":
    WORKERS = 4
    INCREMENTS_PER_WORKER = 50

    print(f"  ワーカー数: {WORKERS}")
    print(f"  各ワーカーのインクリメント回数: {INCREMENTS_PER_WORKER}")
    print(f"  期待される最終値: {WORKERS * INCREMENTS_PER_WORKER}")
    print(f"")

    init_counter()
    print(f"  初期値: {read_counter()}")

    processes = []
    for i in range(WORKERS):
        p = multiprocessing.Process(
            target=increment_counter,
            args=(INCREMENTS_PER_WORKER,),
        )
        processes.append(p)

    start = time.perf_counter()
    for p in processes:
        p.start()
    for p in processes:
        p.join()
    elapsed = time.perf_counter() - start

    final = read_counter()
    expected = WORKERS * INCREMENTS_PER_WORKER

    print(f"")
    print(f"  最終値: {final}")
    print(f"  期待値: {expected}")
    print(f"  消失した更新: {expected - final}")
    print(f"  データ損失率: {(expected - final) / expected * 100:.1f}%")
    print(f"  実行時間: {elapsed:.2f} sec")

    if final != expected:
        print(f"")
        print(f"  >>> データが壊れた！")
        print(f"  >>> {expected - final}回分の更新が闇に消えた。")
        print(f"  >>> これが競合状態（Race Condition）である。")
        print(f"  >>> データベースはこの問題を、ロックとMVCCで解決する。")
    else:
        print(f"")
        print(f"  (今回はたまたま壊れなかった。再実行すると壊れる可能性がある)")
PYEOF

python3 "${WORKDIR}/race_condition.py"
echo ""

echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ディレクトリ構成:"
ls -1 "${WORKDIR}/"
