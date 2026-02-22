#!/bin/bash
# =============================================================================
# 第3回ハンズオン：階層型データモデルの制約を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: python3, sqlite3 (Ubuntu 24.04に標準搭載)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-03"

echo "=== 第3回ハンズオン：階層型データモデルの制約を体験する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- 演習1: 階層型データモデルのナビゲーション ---
echo "[演習1] 階層型データモデルのナビゲーション"
echo ""

cat > "${WORKDIR}/hierarchical_navigation.py" << 'PYEOF'
# hierarchical_navigation.py -- 階層型データモデルでのナビゲーション体験
import json

# 階層型データベース（JSON構造でIMSの概念を模擬）
# ルートセグメント: 口座、子セグメント: 取引履歴、孫セグメント: 明細
hierarchical_db = [
    {
        "segment_type": "ACCOUNT",
        "account_id": "A001",
        "name": "Tanaka Taro",
        "balance": 1500000,
        "children": {
            "TRANSACTION": [
                {
                    "tx_id": "T001",
                    "date": "2024-01-15",
                    "type": "deposit",
                    "amount": 500000,
                    "children": {
                        "DETAIL": [
                            {"detail_id": "D001", "memo": "Salary January"}
                        ]
                    }
                },
                {
                    "tx_id": "T002",
                    "date": "2024-01-20",
                    "type": "withdrawal",
                    "amount": 30000,
                    "children": {
                        "DETAIL": [
                            {"detail_id": "D002", "memo": "ATM withdrawal"}
                        ]
                    }
                },
            ]
        }
    },
    {
        "segment_type": "ACCOUNT",
        "account_id": "A002",
        "name": "Suzuki Hanako",
        "balance": 2300000,
        "children": {
            "TRANSACTION": [
                {
                    "tx_id": "T003",
                    "date": "2024-01-10",
                    "type": "deposit",
                    "amount": 800000,
                    "children": {
                        "DETAIL": [
                            {"detail_id": "D003", "memo": "Salary January"}
                        ]
                    }
                },
            ]
        }
    },
]


class HierarchicalNavigator:
    """IMSのDL/Iを模擬したナビゲーター"""

    def __init__(self, db):
        self.db = db
        self.current_root_idx = -1
        self.current_root = None
        self.current_child_type = None
        self.current_child_idx = -1
        self.current_child = None
        self.steps = 0

    def gu(self, account_id):
        """GU (Get Unique) -- ルートセグメントを検索"""
        self.steps += 1
        for i, root in enumerate(self.db):
            if root["account_id"] == account_id:
                self.current_root_idx = i
                self.current_root = root
                self.current_child_type = None
                self.current_child_idx = -1
                self.current_child = None
                return root
        return None

    def gn_root(self):
        """GN (Get Next) -- 次のルートセグメントへ移動"""
        self.steps += 1
        self.current_root_idx += 1
        if self.current_root_idx < len(self.db):
            self.current_root = self.db[self.current_root_idx]
            self.current_child_type = None
            self.current_child_idx = -1
            self.current_child = None
            return self.current_root
        return None

    def gnp(self, child_type):
        """GNP (Get Next within Parent) -- 親の範囲内で次の子を取得"""
        self.steps += 1
        if self.current_root is None:
            return None
        children = self.current_root.get("children", {}).get(child_type, [])
        if self.current_child_type != child_type:
            self.current_child_type = child_type
            self.current_child_idx = 0
        else:
            self.current_child_idx += 1
        if self.current_child_idx < len(children):
            self.current_child = children[self.current_child_idx]
            return self.current_child
        self.current_child = None
        return None


# === 問い合わせ1: 口座A001の全取引を取得する ===
print("  === 問い合わせ1: 口座A001の全取引（階層型ナビゲーション） ===")
print()

nav = HierarchicalNavigator(hierarchical_db)

account = nav.gu("A001")
if account:
    print(f"    GU -> 口座: {account['account_id']} {account['name']}")
    while True:
        tx = nav.gnp("TRANSACTION")
        if tx is None:
            break
        print(f"    GNP -> 取引: {tx['tx_id']} {tx['date']} {tx['type']} {tx['amount']}")

print(f"\n    ナビゲーション操作回数: {nav.steps}")

# === 問い合わせ2: 全口座の2024年1月の入金合計 ===
print()
print("  === 問い合わせ2: 全口座の2024年1月入金合計（階層型ナビゲーション） ===")
print()

nav2 = HierarchicalNavigator(hierarchical_db)
total_deposits = 0

nav2.current_root_idx = -1
while True:
    account = nav2.gn_root()
    if account is None:
        break
    print(f"    GN -> 口座: {account['account_id']} {account['name']}")
    while True:
        tx = nav2.gnp("TRANSACTION")
        if tx is None:
            break
        if tx["date"].startswith("2024-01") and tx["type"] == "deposit":
            total_deposits += tx["amount"]
            print(f"      GNP -> 入金発見: {tx['amount']}")

print(f"\n    2024年1月の入金合計: {total_deposits}")
print(f"    ナビゲーション操作回数: {nav2.steps}")
print()
print("    注目: プログラマは全ルートを辿り、各ルートの子を辿り、")
print("    条件に合うものを自分で判別している。")
print("    SQLなら: SELECT SUM(amount) FROM transactions")
print("             WHERE date LIKE '2024-01%' AND type = 'deposit'")
PYEOF

python3 "${WORKDIR}/hierarchical_navigation.py"
echo ""

# --- 演習2: 多対多の関係における階層型モデルの限界 ---
echo "[演習2] 多対多の関係における階層型モデルの限界"
echo ""

cat > "${WORKDIR}/many_to_many_problem.py" << 'PYEOF'
# many_to_many_problem.py -- 階層型モデルで多対多を表現する問題
import json

student_root_db = [
    {
        "student_id": "S001",
        "name": "Yamada",
        "courses": [
            {"course_id": "C101", "course_name": "Database", "room": "A301"},
            {"course_id": "C102", "course_name": "Networks", "room": "B205"},
        ]
    },
    {
        "student_id": "S002",
        "name": "Sato",
        "courses": [
            {"course_id": "C101", "course_name": "Database", "room": "A301"},
            {"course_id": "C103", "course_name": "OS", "room": "C110"},
        ]
    },
]

print("  === 階層型モデルでの多対多の問題 ===")
print()

# 問題1: データの冗長性
print("  [問題1] データの冗長性")
course_copies = {}
for student in student_root_db:
    for course in student["courses"]:
        cid = course["course_id"]
        if cid not in course_copies:
            course_copies[cid] = []
        course_copies[cid].append(student["student_id"])

for cid, students in course_copies.items():
    if len(students) > 1:
        print(f"    講義 {cid} のデータが {len(students)} 回重複: "
              f"学生 {', '.join(students)} の下にそれぞれ存在")

# 問題2: 更新不整合
print()
print("  [問題2] 更新不整合のシミュレーション")
print("    講義C101の教室を A301 -> D401 に変更する")
print()

student_root_db[0]["courses"][0]["room"] = "D401"

for student in student_root_db:
    for course in student["courses"]:
        if course["course_id"] == "C101":
            print(f"    学生{student['student_id']}から見た C101 の教室: "
                  f"{course['room']}")

print()
print("    >>> 同じ講義C101の教室情報が学生によって異なる!")
print("    >>> 階層型モデルでは、多対多の関係を表現するために")
print("    >>> データを重複させるしかなく、更新不整合が構造的に避けられない。")
PYEOF

python3 "${WORKDIR}/many_to_many_problem.py"
echo ""

# --- 演習3: リレーショナルモデルとの比較 ---
echo "[演習3] リレーショナルモデルとの比較"
echo ""

cat > "${WORKDIR}/relational_comparison.py" << 'PYEOF'
# relational_comparison.py -- リレーショナルモデルで同じデータを表現する
import sqlite3
import os

DB_FILE = "university.db"
if os.path.exists(DB_FILE):
    os.remove(DB_FILE)

conn = sqlite3.connect(DB_FILE)
cur = conn.cursor()

cur.executescript("""
    CREATE TABLE students (
        student_id TEXT PRIMARY KEY,
        name TEXT NOT NULL
    );

    CREATE TABLE courses (
        course_id TEXT PRIMARY KEY,
        course_name TEXT NOT NULL,
        room TEXT NOT NULL
    );

    CREATE TABLE enrollments (
        student_id TEXT REFERENCES students(student_id),
        course_id TEXT REFERENCES courses(course_id),
        PRIMARY KEY (student_id, course_id)
    );

    INSERT INTO students VALUES ('S001', 'Yamada');
    INSERT INTO students VALUES ('S002', 'Sato');

    INSERT INTO courses VALUES ('C101', 'Database', 'A301');
    INSERT INTO courses VALUES ('C102', 'Networks', 'B205');
    INSERT INTO courses VALUES ('C103', 'OS', 'C110');

    INSERT INTO enrollments VALUES ('S001', 'C101');
    INSERT INTO enrollments VALUES ('S001', 'C102');
    INSERT INTO enrollments VALUES ('S002', 'C101');
    INSERT INTO enrollments VALUES ('S002', 'C103');
""")

print("  === リレーショナルモデルでの多対多 ===")
print()

print("  [問い合わせ1] 学生S001の全講義 (SQL: JOIN)")
rows = cur.execute("""
    SELECT s.name, c.course_name, c.room
    FROM students s
    JOIN enrollments e ON s.student_id = e.student_id
    JOIN courses c ON e.course_id = c.course_id
    WHERE s.student_id = 'S001'
""").fetchall()
for row in rows:
    print(f"    {row[0]}: {row[1]} (教室: {row[2]})")

print()
print("  [問い合わせ2] 講義C101の全受講者 (SQL: JOIN)")
rows = cur.execute("""
    SELECT c.course_name, s.name
    FROM courses c
    JOIN enrollments e ON c.course_id = e.course_id
    JOIN students s ON e.student_id = s.student_id
    WHERE c.course_id = 'C101'
""").fetchall()
for row in rows:
    print(f"    {row[0]}: {row[1]}")

print()
print("  [更新] 講義C101の教室を A301 -> D401 に変更")
cur.execute("UPDATE courses SET room = 'D401' WHERE course_id = 'C101'")

rows = cur.execute("""
    SELECT s.name, c.course_name, c.room
    FROM students s
    JOIN enrollments e ON s.student_id = e.student_id
    JOIN courses c ON e.course_id = c.course_id
    WHERE c.course_id = 'C101'
""").fetchall()
for row in rows:
    print(f"    {row[0]}: {row[1]} (教室: {row[2]})")

print()
print("    >>> 1箇所の更新が全員に即座に反映される。")
print("    >>> データの重複がないため、不整合が発生しない。")

print()
print("  [柔軟性] 階層型では困難な問い合わせ")
print("    「2科目以上履修している学生」")
rows = cur.execute("""
    SELECT s.name, COUNT(e.course_id) AS course_count
    FROM students s
    JOIN enrollments e ON s.student_id = e.student_id
    GROUP BY s.student_id
    HAVING COUNT(e.course_id) >= 2
""").fetchall()
for row in rows:
    print(f"    {row[0]}: {row[1]}科目")

print()
print("    >>> SQLは「何がほしいか」を宣言するだけで、")
print("    >>> データベースエンジンが最適な実行計画を立てる。")

conn.close()
if os.path.exists(DB_FILE):
    os.remove(DB_FILE)
PYEOF

python3 "${WORKDIR}/relational_comparison.py"
echo ""

echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ディレクトリ構成:"
ls -1 "${WORKDIR}/"
