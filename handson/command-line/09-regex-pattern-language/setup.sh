#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/command-line-handson-09"

echo "=============================================="
echo " 第9回ハンズオン: 正規表現――CLIを支えるパターン言語"
echo "=============================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ==============================================
# 演習1: 正規表現の基礎
# ==============================================

echo ""
echo "=============================================="
echo "[演習1] 正規表現の基礎――リテラルから文字クラスへ"
echo "=============================================="
echo ""

# テスト用データを作成
cat > "${WORKDIR}/sample.txt" << 'TEXTEOF'
2025-01-15 INFO  Server started on port 8080
2025-01-15 ERROR Connection refused: 192.168.1.100
2025-01-15 WARN  Memory usage at 85%
2025-01-16 ERROR Timeout after 30000ms
2025-01-16 INFO  Request from 10.0.0.1 completed in 42ms
2025-01-16 DEBUG Query returned 0 rows
2025-01-17 ERROR Disk space critical: 95% used
2025-01-17 INFO  Backup completed: 1024MB transferred
TEXTEOF

echo "サンプルデータ:"
cat -n "${WORKDIR}/sample.txt"
echo ""

echo "--- Step 1: リテラルマッチ ---"
echo ""
echo '  grep "ERROR" sample.txt'
grep "ERROR" "${WORKDIR}/sample.txt" | sed 's/^/  /'
echo ""
echo "  → 固定文字列 ERROR を含む行を表示"
echo ""

echo "--- Step 2: 文字クラス [abc] ---"
echo ""
echo '  grep "[EW]" sample.txt'
echo "  → E または W を含む行"
grep "[EW]" "${WORKDIR}/sample.txt" | sed 's/^/  /'
echo ""

echo "--- Step 3: 範囲指定 [a-z] ---"
echo ""
echo '  grep -E "[0-9]{1,3}%" sample.txt'
echo "  → 1〜3桁の数字 + % を含む行"
grep -E '[0-9]{1,3}%' "${WORKDIR}/sample.txt" | sed 's/^/  /'
echo ""

echo "--- Step 4: 量指定子 *, +, ? ---"
echo ""
echo '  grep -E "[0-9]+ms" sample.txt'
echo "  → 1桁以上の数字 + ms を含む行"
grep -E '[0-9]+ms' "${WORKDIR}/sample.txt" | sed 's/^/  /'
echo ""

echo "--- Step 5: アンカー ^, \$ ---"
echo ""
echo '  grep "^2025-01-16" sample.txt'
echo "  → 行頭が 2025-01-16 の行"
grep '^2025-01-16' "${WORKDIR}/sample.txt" | sed 's/^/  /'
echo ""

echo "--- Step 6: 組み合わせ ---"
echo ""
echo '  grep -E "^2025-01-1[67].*ERROR" sample.txt'
echo "  → 16日または17日のERROR行"
grep -E '^2025-01-1[67].*ERROR' "${WORKDIR}/sample.txt" | sed 's/^/  /'
echo ""

# ==============================================
# 演習2: BRE vs ERE の構文差異
# ==============================================

echo "=============================================="
echo "[演習2] BRE vs ERE の構文差異"
echo "=============================================="
echo ""

cat > "${WORKDIR}/versions.txt" << 'TEXTEOF'
Python 3.12.0 released 2023-10-02
Go 1.21.0 released 2023-08-08
Rust 1.73.0 released 2023-10-05
Java 21 released 2023-09-19
Node 20.9.0 released 2023-10-24
TEXTEOF

echo "テストデータ:"
cat -n "${WORKDIR}/versions.txt"
echo ""

echo "--- 課題: メジャーバージョンが2桁以上の行を抽出 ---"
echo ""

echo '  BRE (grep): grep "[0-9]\{2,\}\.[0-9]" versions.txt'
grep '[0-9]\{2,\}\.[0-9]' "${WORKDIR}/versions.txt" | sed 's/^/  /'
echo ""

echo '  ERE (grep -E): grep -E "[0-9]{2,}\.[0-9]" versions.txt'
grep -E '[0-9]{2,}\.[0-9]' "${WORKDIR}/versions.txt" | sed 's/^/  /'
echo ""

echo "  → 同じ結果だが、EREの方が簡潔"
echo ""

echo "--- 課題: グルーピングと選択 ---"
echo ""
echo '  BRE: grep "\(Python\|Rust\)" versions.txt'
grep '\(Python\|Rust\)' "${WORKDIR}/versions.txt" | sed 's/^/  /'
echo ""

echo '  ERE: grep -E "(Python|Rust)" versions.txt'
grep -E '(Python|Rust)' "${WORKDIR}/versions.txt" | sed 's/^/  /'
echo ""

echo '  → BREでは \( \) \| が必要、EREでは不要'
echo ""

echo "--- 課題: sedでの日付変換 ---"
echo ""
echo "  YYYY-MM-DD → MM/DD/YYYY に変換"
echo ""

echo "  sed (BRE):"
sed 's/\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)/\2\/\3\/\1/' "${WORKDIR}/versions.txt" | sed 's/^/  /'
echo ""

echo "  sed -E (ERE):"
sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})/\2\/\3\/\1/' "${WORKDIR}/versions.txt" | sed 's/^/  /'
echo ""
echo "  → EREの方がはるかに読みやすい"
echo ""

# ==============================================
# 演習3: バックトラッキングの指数爆発
# ==============================================

echo "=============================================="
echo "[演習3] バックトラッキングの指数爆発"
echo "=============================================="
echo ""

echo "Pythonのreモジュール（バックトラッキング方式）で"
echo "指数爆発を安全に体験する。"
echo ""

# Python3がなければインストール
if ! command -v python3 &> /dev/null; then
    echo "python3をインストール中..."
    apt-get update -qq && apt-get install -y -qq python3 > /dev/null 2>&1
fi

python3 << 'PYEOF'
import re
import time

# 安全なパターン: a+b にマッチ
safe_pattern = re.compile(r"a+b")

# 危険なパターン: (a+)+b にマッチ（入れ子の量指定子）
evil_pattern = re.compile(r"(a+)+b")

print("パターン        入力長  時間(秒)  結果")
print("─" * 55)

for n in [10, 15, 18, 20, 22]:
    test_input = "a" * n  # bがないので必ず不一致

    # 安全なパターン
    start = time.perf_counter()
    result = safe_pattern.match(test_input)
    safe_time = time.perf_counter() - start

    # 危険なパターン（タイムアウト付き）
    start = time.perf_counter()
    if n <= 20:
        result = evil_pattern.match(test_input)
        evil_time = time.perf_counter() - start
    else:
        evil_time = -1  # スキップ

    if evil_time >= 0:
        print(f"a+b             {n:>5}  {safe_time:>8.6f}  不一致")
        print(f"(a+)+b          {n:>5}  {evil_time:>8.6f}  不一致")
    else:
        print(f"a+b             {n:>5}  {safe_time:>8.6f}  不一致")
        print(f"(a+)+b          {n:>5}  (スキップ: 指数時間のため)")
    print()
PYEOF

echo ""
echo "→ (a+)+b は入力長が増えると処理時間が指数的に増大する"
echo "  これがReDoS（正規表現によるサービス妨害）の原理"
echo ""
echo "--- 対策 ---"
echo ""
echo "  1. 入れ子の量指定子を避ける: (a+)+ → a+"
echo "  2. 原子的グループを使う（PCRE）: (?>a+)b"
echo "  3. バックトラッキングしないエンジンを使う:"
echo "     RE2, Go regexp, Rust regex, ripgrep"
echo ""

# ==============================================
# クリーンアップ
# ==============================================

echo "=============================================="
echo " 全演習完了"
echo "=============================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "クリーンアップ: rm -rf ${WORKDIR}"
