#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-21"

echo "=========================================="
echo "クラウドの考古学 第21回 ハンズオン"
echo "FinOps——クラウドコストという新しい工学"
echo "=========================================="

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ===========================================
# 演習1: InfracostでTerraformコードのコストを見積もる
# ===========================================

echo ""
echo "=========================================="
echo "演習1: InfracostでTerraformコードのコストを見積もる"
echo "=========================================="

# --- Infracostのインストール ---
echo ""
echo "--- Infracostのインストール ---"
if ! command -v infracost &> /dev/null; then
  curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
  echo "Infracost をインストールしました"
else
  echo "Infracost は既にインストール済みです: $(infracost --version)"
fi

# --- Terraformのインストール（未インストールの場合） ---
echo ""
echo "--- Terraformの確認 ---"
if ! command -v terraform &> /dev/null; then
  echo "Terraform が見つかりません。インストールします..."
  curl -fsSL https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip -o terraform.zip
  unzip -o terraform.zip -d /usr/local/bin/
  rm terraform.zip
  echo "Terraform をインストールしました"
else
  echo "Terraform は既にインストール済みです: $(terraform --version | head -1)"
fi

# --- Infracostの認証案内 ---
echo ""
echo "--- Infracost APIキーの設定 ---"
echo "無料のAPIキーを取得してください:"
echo "  infracost auth login"
echo ""
echo "または環境変数で設定:"
echo "  export INFRACOST_API_KEY=<your-api-key>"
echo ""

# --- シナリオA: EC2ベースの小規模Webアプリ ---
echo "--- シナリオA: EC2ベース構成の作成 ---"
mkdir -p scenario-a

cat > scenario-a/main.tf << 'TF_EOF'
# シナリオA: EC2ベースの小規模Webアプリ（On-Demand）

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.medium"

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name        = "web-server-${count.index + 1}"
    Environment = "production"
    Team        = "backend"
  }
}

resource "aws_db_instance" "main" {
  allocated_storage   = 100
  storage_type        = "gp3"
  engine              = "postgres"
  engine_version      = "16.1"
  instance_class      = "db.t3.large"
  identifier          = "main-db"
  username            = "admin"
  password            = "change-me-in-production"
  skip_final_snapshot = true
  multi_az            = true

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

resource "aws_lb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

resource "aws_s3_bucket" "assets" {
  bucket = "myapp-static-assets"

  tags = {
    Environment = "production"
    Team        = "frontend"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "myapp-application-logs"

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/app/web-server"
  retention_in_days = 90

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = "subnet-0abcdef1234567890"

  tags = {
    Name        = "main-nat-gw"
    Environment = "production"
  }
}
TF_EOF

echo "  scenario-a/main.tf を作成しました"

# --- シナリオB: サーバーレス構成 ---
echo "--- シナリオB: サーバーレス構成の作成 ---"
mkdir -p scenario-b

cat > scenario-b/main.tf << 'TF_EOF'
# シナリオB: サーバーレス構成（Lambda + API Gateway + DynamoDB）

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_lambda_function" "api" {
  function_name = "myapp-api"
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  memory_size   = 512
  timeout       = 30
  filename      = "dummy.zip"

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

resource "aws_apigatewayv2_api" "main" {
  name          = "myapp-api"
  protocol_type = "HTTP"

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

resource "aws_dynamodb_table" "main" {
  name         = "myapp-data"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

resource "aws_s3_bucket" "assets" {
  bucket = "myapp-static-assets-v2"

  tags = {
    Environment = "production"
    Team        = "frontend"
  }
}

resource "aws_cloudfront_distribution" "main" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_id   = "s3-assets"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-assets"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = "production"
    Team        = "frontend"
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/myapp-api"
  retention_in_days = 30

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
TF_EOF

echo "  scenario-b/main.tf を作成しました"

echo ""
echo "=== 演習1 実行手順 ==="
echo ""
echo "1. シナリオA（EC2ベース）の見積もり:"
echo "   cd ${WORKDIR}/scenario-a"
echo "   infracost breakdown --path ."
echo ""
echo "2. シナリオB（サーバーレス）の見積もり:"
echo "   cd ${WORKDIR}/scenario-b"
echo "   infracost breakdown --path ."
echo ""
echo "3. 比較:"
echo "   cd ${WORKDIR}/scenario-a"
echo "   infracost breakdown --path . --format json --out-file infracost-base.json"
echo "   cd ${WORKDIR}/scenario-b"
echo "   infracost diff --path . --compare-to ${WORKDIR}/scenario-a/infracost-base.json"

# ===========================================
# 演習2: 設計変更のコスト影響シミュレーション
# ===========================================

echo ""
echo "=========================================="
echo "演習2: 設計変更のコスト影響シミュレーション"
echo "=========================================="

mkdir -p scenario-a-optimized

cat > scenario-a-optimized/main.tf << 'TF_EOF'
# シナリオA 最適化版
# 変更点:
# 1. EC2: t3.medium -> t3.small（ライトサイジング）
# 2. RDS: multi_az = false, db.t3.large -> db.t3.medium
# 3. NAT Gateway -> VPCエンドポイント
# 4. S3ログにライフサイクルポリシー追加
# 5. CloudWatchログ保持: 90日 -> 30日

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.small"

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name        = "web-server-${count.index + 1}"
    Environment = "production"
    Team        = "backend"
  }
}

resource "aws_db_instance" "main" {
  allocated_storage   = 50
  storage_type        = "gp3"
  engine              = "postgres"
  engine_version      = "16.1"
  instance_class      = "db.t3.medium"
  identifier          = "main-db"
  username            = "admin"
  password            = "change-me-in-production"
  skip_final_snapshot = true
  multi_az            = false

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

resource "aws_lb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

resource "aws_s3_bucket" "assets" {
  bucket = "myapp-static-assets"

  tags = {
    Environment = "production"
    Team        = "frontend"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "myapp-application-logs"

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "log-retention"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "vpc-0abcdef1234567890"
  service_name = "com.amazonaws.ap-northeast-1.s3"

  tags = {
    Name        = "s3-endpoint"
    Environment = "production"
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/app/web-server"
  retention_in_days = 30

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
TF_EOF

echo "  scenario-a-optimized/main.tf を作成しました"

echo ""
echo "=== 演習2 実行手順 ==="
echo ""
echo "1. 最適化前のベースラインを生成:"
echo "   cd ${WORKDIR}/scenario-a"
echo "   infracost breakdown --path . --format json --out-file infracost-base.json"
echo ""
echo "2. 最適化後との差分を確認:"
echo "   cd ${WORKDIR}/scenario-a-optimized"
echo "   infracost diff --path . --compare-to ${WORKDIR}/scenario-a/infracost-base.json"
echo ""
echo "確認ポイント:"
echo "  - EC2 ライトサイジング（t3.medium -> t3.small）の削減額"
echo "  - RDS multi_az 無効化の削減額（約2倍 -> 1倍）"
echo "  - NAT Gateway 削除の削減額（月額約45ドル + データ処理料金）"

# ===========================================
# 演習3: タグ戦略とコスト配賦の設計
# ===========================================

echo ""
echo "=========================================="
echo "演習3: タグ戦略とコスト配賦の設計"
echo "=========================================="

cat > "${WORKDIR}/tagging-strategy.md" << 'MD_EOF'
# タグ戦略テンプレート

## 必須タグ（全リソースに付与）

| タグキー    | 説明               | 値の例                      |
|-------------|--------------------|-----------------------------|
| Environment | 環境区分           | production, staging, dev    |
| Team        | 所有チーム         | backend, frontend, platform |
| Project     | プロジェクト名     | search-api, user-service    |
| CostCenter  | コストセンター番号 | CC-1001, CC-2003            |
| ManagedBy   | 管理方法           | terraform, manual, cdk      |

## 推奨タグ（付与を推奨）

| タグキー   | 説明                 | 値の例             |
|------------|----------------------|--------------------|
| Owner      | 担当者メールアドレス | sato@example.com   |
| Purpose    | リソースの目的       | web-server, batch  |
| ExpiresAt  | 削除予定日           | 2026-04-30         |
| Compliance | 準拠規制             | pci-dss, hipaa     |

## タグ命名規則

- キー: PascalCase（例: CostCenter, ManagedBy）
- 値: lowercase-kebab（例: production, search-api）

## ガバナンスルール

1. タグなしリソースの検知: AWS Config ルールで毎日チェック
2. 新規リソース: SCP でタグ必須を強制
3. ExpiresAt 超過リソース: 自動通知 -> 7日後に自動停止
MD_EOF

cat > "${WORKDIR}/check-untagged.sh" << 'SH_EOF'
#!/bin/bash
set -euo pipefail

echo "=========================================="
echo "タグなしリソースの検出"
echo "=========================================="
echo ""
echo "--- タグなしEC2インスタンスの検出 ---"
echo ""
echo "以下のコマンドでEnvironmentタグが欠けたインスタンスを検出:"
echo ""
echo 'aws ec2 describe-instances \'
echo '  --filters "Name=instance-state-name,Values=running" \'
echo '  --query "Reservations[].Instances[?!Tags || !Tags[?Key==\`Environment\`]].[InstanceId,InstanceType,LaunchTime]" \'
echo '  --output table'
echo ""
echo "--- タグなしRDSインスタンスの検出 ---"
echo ""
echo 'aws rds describe-db-instances \'
echo '  --query "DBInstances[?!TagList || !TagList[?Key==\`Environment\`]].[DBInstanceIdentifier,DBInstanceClass]" \'
echo '  --output table'
echo ""
echo "--- チーム別コストの集計（Cost Explorer API） ---"
echo ""
echo 'aws ce get-cost-and-usage \'
echo '  --time-period Start=$(date -d "30 days ago" +%Y-%m-%d),End=$(date +%Y-%m-%d) \'
echo '  --granularity MONTHLY \'
echo '  --metrics "UnblendedCost" \'
echo '  --group-by Type=TAG,Key=Team \'
echo '  --output json'
SH_EOF
chmod +x "${WORKDIR}/check-untagged.sh"

echo "  tagging-strategy.md を作成しました"
echo "  check-untagged.sh を作成しました"

# ===========================================
# 完了
# ===========================================

echo ""
echo "=========================================="
echo "セットアップ完了"
echo "=========================================="
echo ""
echo "作成されたディレクトリ: ${WORKDIR}"
echo ""
echo "ファイル一覧:"
echo "  scenario-a/main.tf           -- EC2ベース構成"
echo "  scenario-b/main.tf           -- サーバーレス構成"
echo "  scenario-a-optimized/main.tf -- 最適化後の構成"
echo "  tagging-strategy.md          -- タグ戦略テンプレート"
echo "  check-untagged.sh            -- タグなしリソース検出スクリプト"
echo ""
echo "各演習の実行手順は上記の出力を参照してください。"
