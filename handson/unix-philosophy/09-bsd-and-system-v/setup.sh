#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-09"

echo "============================================"
echo " 第9回ハンズオン: BSDとSystem Vの差異を体験する"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================
# 環境構築
# ============================================
echo ""
echo ">>> 環境構築: 必要なパッケージをインストール"
apt-get update -qq && apt-get install -y -qq procps iproute2 net-tools sysvinit-utils 2>/dev/null

# ============================================
# 演習1: psコマンドのBSD構文とSystem V構文
# ============================================
echo ""
echo "============================================"
echo " 演習1: psコマンドのBSD構文とSystem V構文"
echo "============================================"

echo ""
echo ">>> BSD構文: ps aux"
ps aux | head -5

echo ""
echo ">>> System V構文: ps -ef"
ps -ef | head -5

echo ""
echo ">>> ヘッダの比較"
echo "BSD style:     $(ps aux | head -1)"
echo "System V style: $(ps -ef | head -1)"

echo ""
echo "BSD構文は %CPU, %MEM, STAT カラムを表示"
echo "System V構文は PPID, C, STIME カラムを表示"
echo "この違いはUNIXの分裂の歴史に由来する"

# ============================================
# 演習2: System V IPCを体験する
# ============================================
echo ""
echo "============================================"
echo " 演習2: System V IPCを体験する"
echo "============================================"

echo ""
echo ">>> 現在のSystem V IPCリソースを確認"
ipcs

echo ""
echo ">>> System V IPC リソースを作成"
ipcmk -M 1024
echo "共有メモリセグメント（1024バイト）を作成"

ipcmk -Q
echo "メッセージキューを作成"

ipcmk -S 1
echo "セマフォ（1要素）を作成"

echo ""
echo ">>> 作成後のSystem V IPCリソース"
ipcs

echo ""
echo ">>> クリーンアップ"
ipcs -q | awk 'NR>3 && $2 ~ /^[0-9]+$/ {print $2}' | while read id; do
    ipcrm -q "$id" 2>/dev/null || true
done
ipcs -m | awk 'NR>3 && $2 ~ /^[0-9]+$/ {print $2}' | while read id; do
    ipcrm -m "$id" 2>/dev/null || true
done
ipcs -s | awk 'NR>3 && $2 ~ /^[0-9]+$/ {print $2}' | while read id; do
    ipcrm -s "$id" 2>/dev/null || true
done
echo "System V IPCリソースを削除完了"

# ============================================
# 演習3: シグナル処理の違いを体験する
# ============================================
echo ""
echo "============================================"
echo " 演習3: シグナル処理の違い"
echo "============================================"

echo ""
echo ">>> BSDスタイルのreliable signals（bashのデフォルト動作）"

trap 'echo "  SIGUSR1 received (handler still active)"' USR1
MY_PID=$$
echo "PID: $MY_PID"
echo "SIGUSRを3回送信..."
kill -USR1 $MY_PID
kill -USR1 $MY_PID
kill -USR1 $MY_PID
echo ""
echo "ハンドラは3回すべてで動作した（BSDスタイル: reliable signals）"
echo "旧System Vスタイルでは、1回目のシグナル後にハンドラがリセットされ、"
echo "2回目のシグナルでプロセスが死ぬ可能性があった"
trap - USR1

# ============================================
# 演習4: ネットワーキングコマンドの系譜
# ============================================
echo ""
echo "============================================"
echo " 演習4: ネットワーキングコマンドの系譜"
echo "============================================"

echo ""
echo ">>> BSD由来のコマンド（net-tools パッケージ）"
echo "ifconfig (BSD origin):"
ifconfig lo 2>/dev/null | head -3 || echo "  利用不可"

echo ""
echo "netstat (BSD origin):"
netstat -an 2>/dev/null | head -5 || echo "  利用不可"

echo ""
echo ">>> 現代のLinuxコマンド（iproute2 パッケージ）"
echo "ip addr (ifconfigの後継):"
ip addr show lo 2>/dev/null | head -5 || echo "  利用不可"

echo ""
echo "ss (netstatの後継):"
ss -an 2>/dev/null | head -5 || echo "  利用不可"

echo ""
echo "net-tools（ifconfig, netstat, route）はBSD由来のコマンド"
echo "iproute2（ip, ss）は現代のLinux置き換えコマンド"

# ============================================
# 演習5: initシステムの痕跡
# ============================================
echo ""
echo "============================================"
echo " 演習5: initシステムの痕跡"
echo "============================================"

echo ""
echo ">>> SysV initのディレクトリ構造"
ls -d /etc/init.d/ 2>/dev/null && echo "  /etc/init.d/ が存在（SysV init遺産）" || echo "  /etc/init.d/ は存在しない"
ls -d /etc/rc*.d/ 2>/dev/null | head -5 || echo "  /etc/rc*.d/ は存在しない"

echo ""
echo ">>> /etc/inittab（System V initの設定ファイル）"
if [ -f /etc/inittab ]; then
    head -5 /etc/inittab
else
    echo "  /etc/inittab は存在しない（systemd環境では期待される動作）"
fi

# ============================================
# 演習6: BSD由来とSystem V由来の機能の識別
# ============================================
echo ""
echo "============================================"
echo " 演習6: LinuxにおけるBSD/System V由来の機能"
echo "============================================"

echo ""
echo "--- BSD由来 ---"
echo "1. Berkeley sockets: socket(), bind(), listen(), accept()"
echo "2. FFSの影響: ext4のブロックグループはFFSのシリンダグループに由来"
echo "3. BSD構文のps: 'ps aux'"
echo "4. TCP/IPネットワーキングスタック"

echo ""
echo "--- System V由来 ---"
echo "1. System V IPC: shmget(), msgget(), semget()"
echo "2. System V構文のps: 'ps -ef'"
echo "3. SysV init: /etc/init.d/ ディレクトリ構造"
echo "4. STREAMS: Linuxには含まれない（socketsを選択）"

echo ""
echo "--- POSIX標準化（両系統の統合） ---"
echo "1. sigaction(): BSD由来のreliable signalsをPOSIX標準化"
echo "2. termios: BSD由来の端末インタフェースをPOSIX標準化"
echo "3. POSIX IPC: System V IPCの改良版"

echo ""
echo "============================================"
echo " 全演習完了"
echo "============================================"
echo ""
echo "Linuxは、BSDとSystem Vの両方の遺産を実用的に統合した"
echo "オペレーティングシステムである。"
