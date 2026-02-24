#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-08"

echo "============================================================"
echo " クラウドの考古学 第8回 ハンズオン"
echo " AWS CLIでEC2のライフサイクルを体験する"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "  docker run -it --rm --name ec2-handson ubuntu:24.04 bash"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo "============================================================"
echo " 環境セットアップ"
echo "============================================================"
echo ""

apt-get update -qq && apt-get install -y -qq \
  curl unzip python3 python3-pip jq > /dev/null 2>&1
echo "必要なパッケージをインストールしました"

# ============================================================
echo ""
echo "============================================================"
echo " 演習1: EC2操作環境のセットアップ"
echo "============================================================"
echo ""

echo "--- AWS CLI v2のインストール ---"
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws
echo ""

aws --version
echo ""

echo "--- AWS CLIの設定（ローカル学習用） ---"
mkdir -p ~/.aws
cat > ~/.aws/credentials << 'EOF'
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
EOF

cat > ~/.aws/config << 'EOF'
[default]
region = ap-northeast-1
output = json
EOF

echo "AWS CLI設定完了（ローカル学習用のダミー認証情報）"
echo ""
echo "=== 演習1完了 ==="

# ============================================================
echo ""
echo "============================================================"
echo " 演習2: EC2ライフサイクルのコマンド体系"
echo "============================================================"
echo ""

echo "EC2インスタンスのライフサイクル:"
echo ""
echo "  [AMI] → run-instances → [pending] → [running]"
echo "                            stop-instances → [stopped]"
echo "                            start-instances → [running]"
echo "                            terminate-instances → [terminated]"
echo ""

echo "--- AWS CLIとvirshの対比 ---"
echo ""
echo "  virsh define       →  （AMIの登録に相当）"
echo "  virsh start        →  aws ec2 run-instances"
echo "  virsh list         →  aws ec2 describe-instances"
echo "  virsh shutdown     →  aws ec2 stop-instances"
echo "  virsh undefine     →  aws ec2 terminate-instances"
echo "  virsh snapshot     →  aws ec2 create-image"
echo ""
echo "クラウドAPIは、libvirt/virshの設計を"
echo "HTTP API化し、認証・課金・スケーリングを"
echo "組み込んだものと理解できる。"
echo ""
echo "=== 演習2完了 ==="

# ============================================================
echo ""
echo "============================================================"
echo " 演習3: UserDataの概念と使い捨てサーバの設計"
echo "============================================================"
echo ""

echo "UserDataとは:"
echo "  EC2インスタンスの初回起動時に自動実行されるスクリプト。"
echo "  手動設定なしで即座にサービスを開始できる。"
echo "  これが「使い捨て」設計の核心だ。"
echo ""

echo "--- UserDataスクリプトの例 ---"
echo ""

cat > "${WORKDIR}/userdata-webserver.sh" << 'USERDATA'
#!/bin/bash
# EC2 UserDataスクリプト: Webサーバの自動セットアップ
set -euo pipefail

exec > >(tee /var/log/userdata.log) 2>&1
echo "=== UserData実行開始: $(date) ==="

apt-get update -y
apt-get install -y nginx

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id \
  2>/dev/null || echo "local-demo")
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone \
  2>/dev/null || echo "demo-az")

cat > /var/www/html/index.html << HTML
<!DOCTYPE html>
<html>
<head><title>EC2 Instance Info</title></head>
<body>
<h1>EC2 Instance Information</h1>
<p>Instance ID: ${INSTANCE_ID}</p>
<p>Availability Zone: ${AZ}</p>
<p>Launched at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")</p>
<p>This server is disposable.</p>
</body>
</html>
HTML

systemctl enable nginx
systemctl start nginx
echo "=== UserData実行完了: $(date) ==="
USERDATA

cat "${WORKDIR}/userdata-webserver.sh"
echo ""

echo "--- AWS CLIでの使用方法（概念） ---"
echo ""
echo '  aws ec2 run-instances \'
echo '    --image-id ami-xxxxx \'
echo '    --instance-type t3.micro \'
echo '    --user-data file://userdata-webserver.sh'
echo ""
echo "同じコマンドを10回叩けば、10台の同一構成のWebサーバが立つ。"
echo "どの1台が壊れても、同じコマンドで新しい1台が立つ。"
echo "これが「使い捨て」設計の力だ。"
echo ""
echo "=== 演習3完了 ==="

# ============================================================
echo ""
echo "============================================================"
echo " 演習4: EC2の設計思想——パラダイム比較"
echo "============================================================"
echo ""

echo "--- 「ペット」モデル vs 「家畜」モデル ---"
echo ""
echo "  ペット（EC2以前）        家畜（EC2以降）"
echo "  ──────────────────────────────────────────"
echo "  名前を付ける             IDで管理"
echo "  手動セットアップ         AMI + UserDataで自動"
echo "  障害は修復する           障害は捨てて作り直す"
echo "  寿命は数ヶ月〜数年      寿命は数分〜数日"
echo "  月額固定課金             時間（秒）単位課金"
echo ""
echo "EC2は「サーバ」の概念を消したのではない。"
echo "「サーバとの付き合い方」を変えたのだ。"
echo ""
echo "=== 演習4完了 ==="

# ============================================================
echo ""
echo "============================================================"
echo " 全演習完了"
echo "============================================================"
echo ""
echo "このハンズオンで確認したこと:"
echo "  1. AWS CLIのコマンド体系はvirsh（第7回）と構造的に対応する"
echo "  2. UserDataがサーバの「使い捨て」を実現する核心技術である"
echo "  3. EC2は「ペット→家畜」パラダイムシフトを可能にした"
echo ""
