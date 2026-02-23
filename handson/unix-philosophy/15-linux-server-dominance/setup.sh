#!/bin/bash
# =============================================================================
# 第15回ハンズオン：エンタープライズLinuxの運用管理を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 推奨環境: Docker が利用可能なホスト環境
# 必要なツール: docker
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-15"

echo "=== 第15回ハンズオン：エンタープライズLinuxの運用管理を体験する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- Dockerイメージの取得 ---
echo "[準備] Dockerイメージの取得"
docker pull almalinux:9
docker pull ubuntu:24.04
echo ""

# --- 演習1: エンタープライズLinuxの基本情報確認 ---
echo "============================================================"
echo "[演習1] エンタープライズLinuxの基本情報確認"
echo "============================================================"
echo ""

docker run --rm almalinux:9 sh -c '
echo "=== OS情報 ==="
cat /etc/os-release
echo ""
echo "=== カーネルバージョン ==="
uname -r
echo ""
echo "=== RPMパッケージ数 ==="
rpm -qa | wc -l
echo ""
echo "=== インストール済みの主要パッケージ（先頭20件） ==="
rpm -qa --qf "%{NAME}\n" | sort | head -20
'
echo ""

# --- 演習2: systemctlによるサービス管理 ---
echo "============================================================"
echo "[演習2] systemctlによるサービス管理"
echo "============================================================"
echo ""

docker run --rm almalinux:9 sh -c '
echo "=== httpdのインストール ==="
dnf install -y httpd 2>/dev/null | tail -3
echo ""

echo "=== httpdのユニットファイル ==="
cat /usr/lib/systemd/system/httpd.service
echo ""

echo "=== ユニットファイルの構造解説 ==="
echo "[Unit] セクション: 依存関係と説明を定義"
echo "[Service] セクション: 実行方法（Type, ExecStart等）を定義"
echo "[Install] セクション: 有効化時の動作を定義"
echo ""
echo "SysV initスクリプト（数十〜数百行のシェルスクリプト）に対し、"
echo "systemdのユニットファイルは宣言的な設定ファイルである。"
echo "手続き的 → 宣言的への転換がここに表れている。"
'
echo ""

# --- 演習3: RPMパッケージの管理とリポジトリ ---
echo "============================================================"
echo "[演習3] RPMパッケージの管理とリポジトリ"
echo "============================================================"
echo ""

docker run --rm almalinux:9 sh -c '
echo "=== DNFリポジトリの確認 ==="
dnf repolist
echo ""

echo "=== パッケージの検索: httpd ==="
dnf search httpd 2>/dev/null | head -10
echo ""

echo "=== bashパッケージの詳細情報 ==="
dnf info bash 2>/dev/null
echo ""

echo "=== RPMの検証（改ざん検出） ==="
rpm -V bash 2>/dev/null
echo "(出力がなければ改ざんなし)"
echo ""

echo "=== パッケージグループの一覧 ==="
dnf group list 2>/dev/null | head -15
'
echo ""

# --- 演習4: ログ管理 ---
echo "============================================================"
echo "[演習4] ログ管理"
echo "============================================================"
echo ""

docker run --rm almalinux:9 sh -c '
echo "=== /var/log の内容 ==="
ls -la /var/log/ 2>/dev/null
echo ""

echo "=== 従来のsyslog vs systemdジャーナル ==="
echo ""
echo "従来のログ管理:"
echo "  /var/log/messages   -- システムメッセージ"
echo "  /var/log/secure     -- 認証ログ"
echo "  /var/log/httpd/     -- Apacheのログ"
echo "  テキストファイル。grep/awk/sedで検索・解析。"
echo ""
echo "journalctlのログ管理:"
echo "  journalctl -u httpd     -- 特定サービスのログ"
echo "  journalctl --since today -- 今日のログ"
echo "  journalctl -p err        -- エラー以上のログ"
echo "  構造化されたバイナリログ。メタデータで検索可能。"
'
echo ""

# --- 演習5: RHEL系 vs Debian系の比較 ---
echo "============================================================"
echo "[演習5] RHEL系とDebian系の運用管理比較"
echo "============================================================"
echo ""

echo "--- RHEL系（AlmaLinux 9）---"
docker run --rm almalinux:9 sh -c '
echo "パッケージ管理: dnf (RPM)"
echo "  インストール:  dnf install -y nginx"
echo "  アップデート:  dnf update --security"
echo "  検索:          dnf search nginx"
echo ""
echo "ファイアウォール: firewalld"
echo "  許可:  firewall-cmd --add-service=http --permanent"
echo "  反映:  firewall-cmd --reload"
echo ""
echo "強制アクセス制御: SELinux"
echo "  状態確認: getenforce"
echo "  設定:     setsebool -P httpd_can_network_connect on"
echo ""
echo "パッケージ検証: rpm -Va"
'

echo ""

echo "--- Debian系（Ubuntu 24.04）---"
docker run --rm ubuntu:24.04 sh -c '
echo "パッケージ管理: apt (dpkg)"
echo "  インストール:  apt update && apt install -y nginx"
echo "  アップデート:  apt update && apt upgrade"
echo "  検索:          apt search nginx"
echo ""
echo "ファイアウォール: ufw"
echo "  許可:  ufw allow http"
echo "  有効化: ufw enable"
echo ""
echo "強制アクセス制御: AppArmor"
echo "  状態確認: aa-status"
echo "  強制:     aa-enforce /etc/apparmor.d/usr.sbin.nginx"
echo ""
echo "パッケージ検証: debsums --changed"
'

echo ""
echo "============================================================"
echo "ハンズオン完了"
echo "============================================================"
echo ""
echo "同じLinuxカーネルの上に構築されながら、RHEL系とDebian系では"
echo "運用管理の「手触り」が大きく異なる。この違いは、ディストリビューション"
echo "ごとの設計選択の積み重ねである。"
echo ""
echo "どちらが「正解」かではなく、用途と組織に合った選択を理解すること"
echo "——それがこのハンズオンの目的だ。"
