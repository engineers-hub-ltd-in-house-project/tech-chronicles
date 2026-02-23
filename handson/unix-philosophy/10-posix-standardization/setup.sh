#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-10"

echo "=========================================="
echo " Episode 10: POSIX Shell Script Compatibility"
echo "=========================================="
echo ""
echo "Working directory: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo ">>> Installing required shells..."
# ============================================================
apt-get update -qq && apt-get install -y -qq dash busybox zsh ksh mksh > /dev/null 2>&1
echo "Installed: dash, busybox (ash), zsh, ksh, mksh"

# ============================================================
echo ""
echo ">>> Exercise 1: bash-only script vs POSIX shell"
# ============================================================

cat > bash_only.sh << 'SCRIPT'
#!/bin/sh
# bash拡張を使ったスクリプト（POSIXシェルでは動かない）

# bash拡張: 配列
fruits=(apple banana cherry)
echo "First fruit: ${fruits[0]}"

# bash拡張: [[ ]] 構文
if [[ "hello" == h* ]]; then
    echo "Pattern match with [["
fi

# bash拡張: プロセス置換
diff <(echo "line1") <(echo "line2")

# bash拡張: ブレース展開
echo {1..5}
SCRIPT
chmod +x bash_only.sh

echo "--- Running bash_only.sh with bash ---"
bash bash_only.sh 2>&1 || true

echo ""
echo "--- Running bash_only.sh with dash (POSIX shell) ---"
dash bash_only.sh 2>&1 || true

echo ""
echo "--- Running bash_only.sh with busybox ash ---"
busybox ash bash_only.sh 2>&1 || true

# ============================================================
echo ""
echo ">>> Exercise 2: POSIX-compatible rewrite"
# ============================================================

cat > posix_compatible.sh << 'SCRIPT'
#!/bin/sh
# POSIX準拠のスクリプト -- bash拡張を一切使わない

# 配列の代替: スペース区切りの文字列 + set
fruits="apple banana cherry"
set -- $fruits
echo "First fruit: $1"

# [[ ]] の代替: case
case "hello" in
    h*) echo "Pattern match with case" ;;
    *)  echo "No match" ;;
esac

# プロセス置換の代替: 一時ファイル
tmpfile1=$(mktemp)
tmpfile2=$(mktemp)
echo "line1" > "$tmpfile1"
echo "line2" > "$tmpfile2"
diff "$tmpfile1" "$tmpfile2" || true
rm -f "$tmpfile1" "$tmpfile2"

# ブレース展開の代替: 算術ループ
i=1
while [ "$i" -le 5 ]; do
    printf "%d " "$i"
    i=$((i + 1))
done
echo ""
SCRIPT
chmod +x posix_compatible.sh

for shell in bash dash "busybox ash" "zsh --emulate sh" mksh; do
    shell_name=$(echo "$shell" | awk '{print $1}')
    echo "--- Running posix_compatible.sh with ${shell_name} ---"
    $shell posix_compatible.sh
    echo ""
done

# ============================================================
echo ""
echo ">>> Exercise 3: POSIX utility compatibility"
# ============================================================

mkdir -p posix_test
cat > posix_test/data.txt << 'DATA'
Alice 30 Engineering
Bob 25 Marketing
Charlie 35 Engineering
Diana 28 Marketing
Eve 32 Engineering
DATA

cat > posix_utils.sh << 'SCRIPT'
#!/bin/sh
echo "=== grep (POSIX BRE) ==="
grep "Engineering" posix_test/data.txt

echo ""
echo "=== awk (POSIX) ==="
awk '{ sum += $2; count++ } END { printf "Average age: %.1f\n", sum/count }' \
    posix_test/data.txt

echo ""
echo "=== sed (POSIX) ==="
sed 's/Engineering/Eng/g; s/Marketing/Mkt/g' posix_test/data.txt

echo ""
echo "=== sort + uniq (POSIX) ==="
awk '{ print $3 }' posix_test/data.txt | sort | uniq -c | sort -rn

echo ""
echo "=== test / [ ] (POSIX) ==="
x=42
if [ "$x" -gt 40 ] && [ "$x" -lt 50 ]; then
    echo "$x is between 40 and 50"
fi

echo ""
echo "=== printf (POSIX) ==="
printf "Name: %-10s Age: %3d\n" "Alice" 30
printf "Name: %-10s Age: %3d\n" "Bob" 25
SCRIPT
chmod +x posix_utils.sh

echo "--- Running with dash ---"
dash posix_utils.sh

# ============================================================
echo ""
echo ">>> Exercise 4: echo vs printf"
# ============================================================

cat > echo_vs_printf.sh << 'SCRIPT'
#!/bin/sh
echo "=== echo with escape sequences ==="
echo "Tab:\there"
echo "Newline:\nhere"

echo ""
echo "=== printf is consistent ==="
printf "Tab:\there\n"
printf "Newline:\nhere\n"
SCRIPT
chmod +x echo_vs_printf.sh

echo "--- bash ---"
bash echo_vs_printf.sh
echo ""
echo "--- dash ---"
dash echo_vs_printf.sh

# ============================================================
echo ""
echo ">>> Exercise 5: Practical POSIX log analysis"
# ============================================================

cat > access.log << 'LOG'
192.168.1.10 - - [23/Feb/2026:10:15:30] "GET /index.html HTTP/1.1" 200 1234
192.168.1.20 - - [23/Feb/2026:10:15:31] "GET /api/users HTTP/1.1" 200 5678
192.168.1.10 - - [23/Feb/2026:10:15:32] "POST /api/login HTTP/1.1" 401 89
192.168.1.30 - - [23/Feb/2026:10:15:33] "GET /index.html HTTP/1.1" 200 1234
192.168.1.20 - - [23/Feb/2026:10:15:34] "GET /api/users HTTP/1.1" 500 234
192.168.1.10 - - [23/Feb/2026:10:15:35] "GET /static/style.css HTTP/1.1" 200 4567
192.168.1.40 - - [23/Feb/2026:10:15:36] "GET /index.html HTTP/1.1" 200 1234
192.168.1.20 - - [23/Feb/2026:10:15:37] "DELETE /api/users/5 HTTP/1.1" 403 123
192.168.1.30 - - [23/Feb/2026:10:15:38] "GET /api/health HTTP/1.1" 200 45
192.168.1.10 - - [23/Feb/2026:10:15:39] "GET /index.html HTTP/1.1" 304 0
LOG

cat > analyze_log.sh << 'SCRIPT'
#!/bin/sh
# POSIXシェル準拠のログ解析スクリプト
LOGFILE="${1:?Usage: $0 <logfile>}"

if [ ! -f "$LOGFILE" ]; then
    printf "Error: File not found: %s\n" "$LOGFILE" >&2
    exit 1
fi

total=$(wc -l < "$LOGFILE")
printf "=== Log Analysis Report ===\n"
printf "File: %s\n" "$LOGFILE"
printf "Total requests: %d\n\n" "$total"

printf "--- Status Code Distribution ---\n"
awk '{ for(i=1;i<=NF;i++) if($i ~ /^[0-9][0-9][0-9]$/ && $(i-1) ~ /HTTP/) print $i }' \
    "$LOGFILE" | sort | uniq -c | sort -rn | \
while read count code; do
    pct=$((count * 100 / total))
    printf "  %s: %3d requests (%2d%%)\n" "$code" "$count" "$pct"
done

printf "\n--- Top IP Addresses ---\n"
awk '{ print $1 }' "$LOGFILE" | sort | uniq -c | sort -rn | head -5 | \
while read count ip; do
    printf "  %-15s %3d requests\n" "$ip" "$count"
done

printf "\n--- HTTP Methods ---\n"
awk -F'"' '{ split($2, a, " "); print a[1] }' "$LOGFILE" | \
    sort | uniq -c | sort -rn | \
while read count method; do
    printf "  %-6s %3d requests\n" "$method" "$count"
done
SCRIPT
chmod +x analyze_log.sh

echo "--- Running with dash ---"
dash analyze_log.sh access.log

echo ""
echo "--- Running with busybox ash ---"
busybox ash analyze_log.sh access.log

# ============================================================
echo ""
echo "=========================================="
echo " All exercises completed!"
echo "=========================================="
echo ""
echo "Key takeaways:"
echo "  1. bash extensions break on POSIX shells (dash, ash)"
echo "  2. POSIX-compliant scripts work across all shells"
echo "  3. Use printf instead of echo for portability"
echo "  4. Use case instead of [[ ]] for pattern matching"
echo "  5. Use set -- for positional parameter lists (no arrays)"
