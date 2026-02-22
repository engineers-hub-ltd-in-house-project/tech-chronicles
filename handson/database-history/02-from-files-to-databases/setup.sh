#!/bin/bash
# =============================================================================
# 第2回ハンズオン：CSVファイルベースのデータ管理と同時書き込みの破壊
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: python3 (Ubuntu 24.04に標準搭載)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-02"

echo "=== 第2回ハンズオン：CSVファイルベースのデータ管理と同時書き込みの破壊 ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- 演習1: データの冗長性と不整合を再現する ---
echo "[演習1] データの冗長性と不整合"
echo ""

cat > "${WORKDIR}/redundancy_demo.py" << 'PYEOF'
# redundancy_demo.py -- データの冗長性と不整合を体験する
import csv
import os

# 「人事部」と「経理部」がそれぞれ独自のファイルを持つ
HR_FILE = "hr_employees.csv"
ACCOUNTING_FILE = "accounting_payroll.csv"

HR_FIELDS = ["emp_id", "name", "address", "department"]
ACC_FIELDS = ["emp_id", "name", "address", "salary"]

def init_files():
    """両部門のファイルを初期化する（同じ従業員データを重複して保持）"""
    employees = [
        {"emp_id": "001", "name": "Tanaka", "address": "Tokyo", "department": "Sales"},
        {"emp_id": "002", "name": "Suzuki", "address": "Osaka", "department": "Engineering"},
        {"emp_id": "003", "name": "Yamada", "address": "Nagoya", "department": "Marketing"},
    ]

    # 人事部ファイル
    with open(HR_FILE, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=HR_FIELDS)
        writer.writeheader()
        for emp in employees:
            writer.writerow({k: emp[k] for k in HR_FIELDS})

    # 経理部ファイル（同じデータ + 給与情報）
    with open(ACCOUNTING_FILE, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=ACC_FIELDS)
        writer.writeheader()
        salaries = {"001": 5000000, "002": 6000000, "003": 4500000}
        for emp in employees:
            writer.writerow({
                "emp_id": emp["emp_id"],
                "name": emp["name"],
                "address": emp["address"],
                "salary": salaries[emp["emp_id"]],
            })

def update_hr_address(emp_id, new_address):
    """人事部がアドレスを更新する（経理部のファイルは更新されない）"""
    rows = []
    with open(HR_FILE, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row["emp_id"] == emp_id:
                row["address"] = new_address
            rows.append(row)
    with open(HR_FILE, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=HR_FIELDS)
        writer.writeheader()
        writer.writerows(rows)

def check_consistency():
    """両ファイルの整合性を確認する"""
    hr_data = {}
    with open(HR_FILE, "r") as f:
        for row in csv.DictReader(f):
            hr_data[row["emp_id"]] = row

    acc_data = {}
    with open(ACCOUNTING_FILE, "r") as f:
        for row in csv.DictReader(f):
            acc_data[row["emp_id"]] = row

    print("  === 整合性チェック ===")
    inconsistencies = 0
    for emp_id in hr_data:
        if emp_id in acc_data:
            hr_addr = hr_data[emp_id]["address"]
            acc_addr = acc_data[emp_id]["address"]
            if hr_addr != acc_addr:
                inconsistencies += 1
                print(f"    不整合発見! ID={emp_id}:")
                print(f"      人事部:  address={hr_addr}")
                print(f"      経理部:  address={acc_addr}")
    if inconsistencies == 0:
        print("    不整合なし")
    else:
        print(f"")
        print(f"    {inconsistencies}件の不整合が発生している。")
        print(f"    同一データが複数ファイルに分散している限り、")
        print(f"    この問題は構造的に解決できない。")

if __name__ == "__main__":
    print("  === データの冗長性と不整合のデモ ===")
    print("")

    init_files()
    print("  [初期状態]")
    check_consistency()

    print("")
    print("  [人事部がTanakaの住所を Tokyo -> Yokohama に更新]")
    update_hr_address("001", "Yokohama")

    check_consistency()
PYEOF

python3 "${WORKDIR}/redundancy_demo.py"
echo ""

# --- 演習2: ファイルロック(flock)の限界を体験する ---
echo "[演習2] ファイルロック(flock)の限界"
echo ""

cat > "${WORKDIR}/flock_limitation.py" << 'PYEOF'
# flock_limitation.py -- ファイルロックの限界を体験する
import csv
import fcntl
import multiprocessing
import time
import os

DATA_FILE = "shared_inventory.csv"

def init_inventory():
    """在庫ファイルを初期化する"""
    with open(DATA_FILE, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["item_id", "name", "stock"])
        writer.writerow(["001", "Widget-A", 100])

def read_stock_with_lock():
    """ロック付きで在庫を読む"""
    with open(DATA_FILE, "r") as f:
        fcntl.flock(f.fileno(), fcntl.LOCK_SH)  # 共有ロック
        reader = csv.DictReader(f)
        rows = list(reader)
        fcntl.flock(f.fileno(), fcntl.LOCK_UN)
    return int(rows[0]["stock"]) if rows else 0

def update_stock_with_lock(new_stock):
    """ロック付きで在庫を書く"""
    with open(DATA_FILE, "w", newline="") as f:
        fcntl.flock(f.fileno(), fcntl.LOCK_EX)  # 排他ロック
        writer = csv.writer(f)
        writer.writerow(["item_id", "name", "stock"])
        writer.writerow(["001", "Widget-A", new_stock])
        fcntl.flock(f.fileno(), fcntl.LOCK_UN)

def purchase_item(worker_id, n_purchases):
    """在庫を1つずつ減らす（ロック付き、だが Read-Then-Write の隙間あり）"""
    for i in range(n_purchases):
        stock = read_stock_with_lock()
        if stock > 0:
            time.sleep(0.001)  # 処理時間のシミュレーション
            update_stock_with_lock(stock - 1)

if __name__ == "__main__":
    WORKERS = 4
    PURCHASES_PER_WORKER = 10

    print(f"  ワーカー数: {WORKERS}")
    print(f"  各ワーカーの購入回数: {PURCHASES_PER_WORKER}")
    print(f"  初期在庫: 100")
    print(f"  期待される最終在庫: {100 - WORKERS * PURCHASES_PER_WORKER}")
    print(f"")

    init_inventory()

    processes = []
    for i in range(WORKERS):
        p = multiprocessing.Process(
            target=purchase_item,
            args=(i, PURCHASES_PER_WORKER),
        )
        processes.append(p)

    for p in processes:
        p.start()
    for p in processes:
        p.join()

    final_stock = read_stock_with_lock()
    expected = 100 - WORKERS * PURCHASES_PER_WORKER

    print(f"  最終在庫: {final_stock}")
    print(f"  期待値:   {expected}")
    print(f"  差異:     {final_stock - expected}")

    if final_stock != expected:
        print(f"")
        print(f"  >>> ロックを使っているのにデータが不正確!")
        print(f"  >>> 原因: Read(共有ロック) と Write(排他ロック) が")
        print(f"  >>>       別々のロック取得であるため、")
        print(f"  >>>       Read後〜Write前の隙間に他プロセスが介入する。")
        print(f"  >>> これが TOCTOU (Time of Check to Time of Use) 問題である。")
        print(f"  >>>")
        print(f"  >>> データベースはこれを、トランザクションの")
        print(f"  >>> 分離性(Isolation) で解決する。")
    else:
        print(f"")
        print(f"  (今回はたまたま正確だった。再実行すると不正確になる可能性がある)")
PYEOF

python3 "${WORKDIR}/flock_limitation.py"
echo ""

echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ディレクトリ構成:"
ls -1 "${WORKDIR}/"
