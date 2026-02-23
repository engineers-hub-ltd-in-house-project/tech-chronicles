#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-17"

echo "============================================"
echo " 第17回ハンズオン: SysV initとsystemdの設計比較"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================
# 演習1: SysV initスクリプトの構造を理解する
# ============================================
echo ""
echo "=== 演習1: SysV initスクリプトの構造を理解する ==="
echo ""

cat > sysv-myapp-init.sh << 'SYSV_SCRIPT'
#!/bin/bash
# /etc/init.d/myapp -- SysV initスクリプトの典型例
# このスクリプトは教育目的のサンプルです

DAEMON=/usr/local/bin/myapp
PIDFILE=/var/run/myapp.pid
NAME=myapp

start() {
    echo -n "Starting $NAME: "
    if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        echo "already running"
        return 0
    fi
    $DAEMON --daemon --pidfile=$PIDFILE
    echo "done"
}

stop() {
    echo -n "Stopping $NAME: "
    if [ -f "$PIDFILE" ]; then
        kill $(cat "$PIDFILE")
        rm -f "$PIDFILE"
        echo "done"
    else
        echo "not running"
    fi
}

status() {
    if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        echo "$NAME is running (PID $(cat $PIDFILE))"
    else
        echo "$NAME is not running"
    fi
}

case "$1" in
    start)   start ;;
    stop)    stop ;;
    restart) stop; sleep 1; start ;;
    status)  status ;;
    *)       echo "Usage: $0 {start|stop|restart|status}" ;;
esac
SYSV_SCRIPT

chmod +x sysv-myapp-init.sh
echo "SysV initスクリプトのサンプルを作成しました: sysv-myapp-init.sh"
echo ""
echo "確認: cat sysv-myapp-init.sh"

# ============================================
# 演習2: systemdユニットファイルの設計を理解する
# ============================================
echo ""
echo "=== 演習2: systemdユニットファイルの設計を理解する ==="
echo ""

cat > systemd-myapp.service << 'UNIT_FILE'
[Unit]
Description=My Application Service
After=network.target
Wants=network-online.target
Documentation=https://example.com/myapp/docs

[Service]
Type=simple
ExecStart=/usr/local/bin/myapp --foreground
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

# セキュリティ強化
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
NoNewPrivileges=true

# リソース制限
MemoryMax=512M
CPUQuota=50%

[Install]
WantedBy=multi-user.target
UNIT_FILE

echo "systemdユニットファイルのサンプルを作成しました: systemd-myapp.service"
echo ""
echo "確認: cat systemd-myapp.service"

# ============================================
# 演習3: systemdの実際の動作確認コマンド集
# ============================================
echo ""
echo "=== 演習3: systemdの実際の動作確認 ==="
echo ""

cat > systemd-commands.sh << 'COMMANDS'
#!/bin/bash
# systemdの主要コマンド集（ホストシステムで実行すること）

echo "=== サービス管理 ==="
echo "systemctl status httpd         # サービスの状態確認"
echo "systemctl start httpd          # サービス起動"
echo "systemctl stop httpd           # サービス停止"
echo "systemctl restart httpd        # サービス再起動"
echo "systemctl enable httpd         # 自動起動有効化"
echo "systemctl disable httpd        # 自動起動無効化"
echo "systemctl is-active httpd      # 動作中か確認"
echo "systemctl is-enabled httpd     # 自動起動設定か確認"
echo ""

echo "=== 起動分析 ==="
echo "systemd-analyze                # 起動時間の概要"
echo "systemd-analyze blame          # サービスごとの起動時間"
echo "systemd-analyze critical-chain # クリティカルパスの表示"
echo ""

echo "=== cgroups確認 ==="
echo "systemd-cgls                   # cgroupツリー表示"
echo "systemd-cgtop                  # cgroupリソース使用率（top風）"
echo ""

echo "=== ジャーナルログ ==="
echo "journalctl                     # 全ログ表示"
echo "journalctl -u httpd            # 特定サービスのログ"
echo "journalctl -f                  # リアルタイム監視"
echo "journalctl -p err              # エラー以上のログ"
echo "journalctl --since '1 hour ago' # 直近1時間"
echo "journalctl -o json-pretty      # JSON出力"
COMMANDS

chmod +x systemd-commands.sh
echo "systemdコマンド集を作成しました: systemd-commands.sh"

# ============================================
# 演習4: journalctlとsyslogの比較
# ============================================
echo ""
echo "=== 演習4: journalctlとsyslogの比較 ==="
echo ""

cat > journal-vs-syslog.sh << 'COMPARE'
#!/bin/bash
# journaldとsyslogの比較（ホストシステムで実行すること）

echo "=== syslog方式（テキストログ）の操作 ==="
echo ""
echo "# ログファイルを直接読む"
echo "cat /var/log/syslog"
echo ""
echo "# grepでフィルタ"
echo "grep 'error' /var/log/syslog"
echo ""
echo "# awkで集計"
echo "awk '{print $5}' /var/log/syslog | sort | uniq -c | sort -rn"
echo ""
echo "# リアルタイム監視"
echo "tail -f /var/log/syslog"
echo ""

echo "=== journald方式（バイナリログ）の操作 ==="
echo ""
echo "# 全ログ表示"
echo "journalctl --no-pager"
echo ""
echo "# grepと組み合わせる（変換が必要）"
echo "journalctl --no-pager | grep 'error'"
echo ""
echo "# 構造化クエリ（journald固有の機能）"
echo "journalctl -u httpd -p err --since '1 hour ago'"
echo ""
echo "# JSON出力をjqで処理"
echo "journalctl -o json --no-pager | jq '.MESSAGE'"
echo ""
echo "# リアルタイム監視"
echo "journalctl -f"
COMPARE

chmod +x journal-vs-syslog.sh
echo "ログ比較スクリプトを作成しました: journal-vs-syslog.sh"

# ============================================
# 演習5: systemd timerとcronの比較
# ============================================
echo ""
echo "=== 演習5: systemd timerとcronの比較 ==="
echo ""

cat > backup.service << 'SERVICE'
[Unit]
Description=Daily Backup

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
Nice=19
IOSchedulingClass=idle
SERVICE

cat > backup.timer << 'TIMER'
[Unit]
Description=Daily Backup Timer

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
TIMER

echo "systemd timerのサンプルを作成しました: backup.service, backup.timer"
echo ""
echo "crontabとの比較:"
echo "  cron:  0 3 * * * /usr/local/bin/backup.sh"
echo "  timer: OnCalendar=*-*-* 03:00:00 + Persistent=true"

# ============================================
# 完了
# ============================================
echo ""
echo "============================================"
echo " セットアップ完了"
echo "============================================"
echo ""
echo "作成したファイル:"
echo "  ${WORKDIR}/sysv-myapp-init.sh      -- SysV initスクリプトのサンプル"
echo "  ${WORKDIR}/systemd-myapp.service   -- systemdユニットファイルのサンプル"
echo "  ${WORKDIR}/systemd-commands.sh     -- systemdコマンド集"
echo "  ${WORKDIR}/journal-vs-syslog.sh    -- journaldとsyslogの比較"
echo "  ${WORKDIR}/backup.service          -- systemd timerのサービスユニット"
echo "  ${WORKDIR}/backup.timer            -- systemd timerのタイマーユニット"
echo ""
echo "各ファイルを読み、ホストシステムのsystemd環境で"
echo "コマンドを実行して動作を確認してください。"
