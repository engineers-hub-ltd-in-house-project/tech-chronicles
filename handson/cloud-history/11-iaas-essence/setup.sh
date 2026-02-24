#!/bin/bash
set -euo pipefail

###############################################################################
# Cloud History Episode 11 - VPCをゼロから手動で構築する
# IaaSのネットワーク抽象化を体感するハンズオン
###############################################################################

WORKDIR="${HOME}/cloud-history-handson-11"

echo "=============================================="
echo " Episode 11: VPCをゼロから手動で構築する"
echo "=============================================="
echo ""
echo "このスクリプトはDocker環境でAWS CLIをセットアップします。"
echo "VPCの構築は手動で行い、IaaSのネットワーク抽象化を体感します。"
echo ""

###############################################################################
# 演習0: 環境セットアップ
###############################################################################
echo "=== 演習0: 環境セットアップ ==="

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# AWS CLIの確認
if ! command -v aws &> /dev/null; then
    echo "AWS CLI v2 をインストールしています..."
    apt-get update -qq && apt-get install -y -qq curl unzip less jq > /dev/null 2>&1
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip && ./aws/install > /dev/null 2>&1
    rm -rf awscliv2.zip aws/
    echo "AWS CLI v2 インストール完了"
else
    echo "AWS CLI は既にインストール済みです: $(aws --version)"
fi

echo ""
echo "AWS CLIの認証情報を設定してください:"
echo "  aws configure"
echo ""
echo "設定後、以下の手順でVPCを構築してください。"
echo ""

###############################################################################
# 演習1: VPCの骨格を構築する
###############################################################################
cat << 'INSTRUCTIONS'
=== 演習1: VPCの骨格を構築する ===

# VPCを作成（10.0.0.0/16 = 65,536個のIPアドレス空間）
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --query 'Vpc.VpcId' \
  --output text)
echo "VPC ID: ${VPC_ID}"

# DNSホスト名を有効化
aws ec2 modify-vpc-attribute \
  --vpc-id "${VPC_ID}" \
  --enable-dns-hostnames '{"Value": true}'

# 名前タグを付与
aws ec2 create-tags \
  --resources "${VPC_ID}" \
  --tags Key=Name,Value=handson-vpc

=== 演習2: サブネットを作成する ===

# パブリックサブネット
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id "${VPC_ID}" \
  --cidr-block 10.0.1.0/24 \
  --availability-zone ap-northeast-1a \
  --query 'Subnet.SubnetId' \
  --output text)
aws ec2 create-tags \
  --resources "${PUBLIC_SUBNET_ID}" \
  --tags Key=Name,Value=handson-public-subnet

# プライベートサブネット
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id "${VPC_ID}" \
  --cidr-block 10.0.2.0/24 \
  --availability-zone ap-northeast-1a \
  --query 'Subnet.SubnetId' \
  --output text)
aws ec2 create-tags \
  --resources "${PRIVATE_SUBNET_ID}" \
  --tags Key=Name,Value=handson-private-subnet

=== 演習3: インターネットゲートウェイとルーティング ===

# インターネットゲートウェイを作成してVPCにアタッチ
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)
aws ec2 attach-internet-gateway \
  --internet-gateway-id "${IGW_ID}" \
  --vpc-id "${VPC_ID}"

# パブリックサブネット用のルートテーブル
PUBLIC_RT_ID=$(aws ec2 create-route-table \
  --vpc-id "${VPC_ID}" \
  --query 'RouteTable.RouteTableId' \
  --output text)
aws ec2 create-route \
  --route-table-id "${PUBLIC_RT_ID}" \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id "${IGW_ID}"
aws ec2 associate-route-table \
  --route-table-id "${PUBLIC_RT_ID}" \
  --subnet-id "${PUBLIC_SUBNET_ID}"

=== 演習4: セキュリティグループ ===

SG_ID=$(aws ec2 create-security-group \
  --group-name handson-sg \
  --description "Handson security group" \
  --vpc-id "${VPC_ID}" \
  --query 'GroupId' \
  --output text)
aws ec2 authorize-security-group-ingress \
  --group-id "${SG_ID}" --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress \
  --group-id "${SG_ID}" --protocol tcp --port 80 --cidr 0.0.0.0/0

=== 演習5: 確認とクリーンアップ ===

# 確認
aws ec2 describe-vpcs --vpc-ids "${VPC_ID}" --output table
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=${VPC_ID}" --output table

# クリーンアップ（依存関係の逆順で削除）
aws ec2 delete-security-group --group-id "${SG_ID}"
aws ec2 disassociate-route-table \
  --association-id $(aws ec2 describe-route-tables \
    --route-table-ids "${PUBLIC_RT_ID}" \
    --query 'RouteTables[0].Associations[?!Main].RouteTableAssociationId' \
    --output text)
aws ec2 delete-route-table --route-table-id "${PUBLIC_RT_ID}"
aws ec2 detach-internet-gateway \
  --internet-gateway-id "${IGW_ID}" --vpc-id "${VPC_ID}"
aws ec2 delete-internet-gateway --internet-gateway-id "${IGW_ID}"
aws ec2 delete-subnet --subnet-id "${PUBLIC_SUBNET_ID}"
aws ec2 delete-subnet --subnet-id "${PRIVATE_SUBNET_ID}"
aws ec2 delete-vpc --vpc-id "${VPC_ID}"
echo "クリーンアップ完了"
INSTRUCTIONS

echo ""
echo "上記の手順をコピーして実行してください。"
echo "作業ディレクトリ: ${WORKDIR}"
