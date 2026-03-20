#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-22"

echo "=========================================="
echo "クラウドの考古学 第22回 ハンズオン"
echo "マルチクラウドの現実を体験する"
echo "=========================================="
echo ""

# --- ディレクトリ作成 ---
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "作業ディレクトリ: ${WORKDIR}"
echo ""

# ==========================================
# 演習1: マルチクラウド Terraform 構成の比較
# ==========================================
echo "=========================================="
echo "演習1: マルチクラウド Terraform 構成の比較"
echo "=========================================="
echo ""

# --- AWS 構成 ---
mkdir -p aws-web

cat > aws-web/main.tf << 'TF_EOF'
# AWS: Web サーバー + RDS PostgreSQL
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

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "multicloud-demo"
  }
}

# AWS では サブネットは AZ に紐づく
resource "aws_subnet" "web_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "web-subnet-a"
  }
}

resource "aws_subnet" "web_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "web-subnet-c"
  }
}

# --- EC2 インスタンス ---
resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.web_a.id

  tags = {
    Name = "web-server"
  }
}

# --- RDS PostgreSQL ---
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet"
  subnet_ids = [aws_subnet.web_a.id, aws_subnet.web_c.id]
}

resource "aws_db_instance" "main" {
  identifier          = "demo-db"
  engine              = "postgres"
  engine_version      = "16.1"
  instance_class      = "db.t3.medium"
  allocated_storage   = 20
  db_name             = "appdb"
  username            = "admin"
  password            = "change-me-in-production"
  skip_final_snapshot = true

  db_subnet_group_name = aws_db_subnet_group.main.name

  # AWS 固有: IAM 認証の有効化
  iam_database_authentication_enabled = true

  tags = {
    Name = "demo-database"
  }
}

# --- セキュリティグループ ---
resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
TF_EOF

echo "AWS 構成を作成しました: aws-web/main.tf"

# --- GCP 構成 ---
mkdir -p gcp-web

cat > gcp-web/main.tf << 'TF_EOF'
# GCP: Web サーバー + Cloud SQL PostgreSQL
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "my-project-id"
  region  = "asia-northeast1"
}

# --- VPC ---
# GCP の VPC はグローバル（リージョンをまたぐ）
resource "google_compute_network" "main" {
  name                    = "multicloud-demo"
  auto_create_subnetworks = false
}

# GCP では サブネットはリージョンに紐づく（全AZにまたがる）
resource "google_compute_subnetwork" "web" {
  name          = "web-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "asia-northeast1"
  network       = google_compute_network.main.id

  # GCP 固有: Private Google Access
  private_ip_google_access = true
}

# --- Compute Engine インスタンス ---
resource "google_compute_instance" "web" {
  name         = "web-server"
  machine_type = "e2-medium"
  zone         = "asia-northeast1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.web.id

    access_config {
      # Ephemeral public IP
    }
  }

  # GCP 固有: メタデータでSSH鍵を管理
  metadata = {
    enable-oslogin = "true"
  }
}

# --- Cloud SQL PostgreSQL ---
resource "google_sql_database_instance" "main" {
  name             = "demo-db"
  database_version = "POSTGRES_16"
  region           = "asia-northeast1"

  settings {
    tier = "db-custom-2-7680"  # GCP 固有: カスタムマシンタイプ

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id

      # GCP 固有: Private Service Access が必要
    }

    backup_configuration {
      enabled    = true
      start_time = "02:00"
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "appdb" {
  name     = "appdb"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "admin" {
  name     = "admin"
  instance = google_sql_database_instance.main.name
  password = "change-me-in-production"
}

# --- ファイアウォールルール ---
# GCP 固有: ファイアウォールはVPCレベル（AWSはSGがインスタンスレベル）
resource "google_compute_firewall" "web" {
  name    = "allow-http"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}
TF_EOF

echo "GCP 構成を作成しました: gcp-web/main.tf"
echo ""

# ==========================================
# 演習2: AWS vs GCP 差異分析
# ==========================================
echo "=========================================="
echo "演習2: AWS vs GCP 差異分析"
echo "=========================================="
echo ""

cat > analysis.md << 'MD_EOF'
# マルチクラウド差異分析: AWS vs GCP

## 1. ネットワーク設計の差異

| 項目           | AWS                          | GCP                           |
|----------------|------------------------------|-------------------------------|
| VPC スコープ   | リージョン単位               | グローバル                    |
| サブネット     | AZ に紐づく                  | リージョンに紐づく（全AZ）   |
| ファイアウォール| Security Group (インスタンス) | Firewall Rule (VPC)          |
| 公開IP         | Elastic IP (明示的)          | Ephemeral/Static (access_config) |
| DNS            | Route 53 (別サービス)        | Cloud DNS (別サービス)        |

## 2. データベースサービスの差異

| 項目           | AWS RDS                      | GCP Cloud SQL                 |
|----------------|------------------------------|-------------------------------|
| インスタンス   | db.t3.medium (定義済みサイズ) | db-custom-2-7680 (カスタム)  |
| 認証           | IAM DB Authentication        | Cloud SQL Proxy + IAM        |
| プライベート接続| VPC内サブネットグループ      | Private Service Access       |
| フェイルオーバー| Multi-AZ (自動)              | HA構成 (リージョナル)        |
| バックアップ   | 自動 (保持期間指定)          | 手動 + 自動 (時刻指定)       |

## 3. 学びのポイント

- Terraform は「言語」を統一するが「概念」は統一しない
- 同じ「PostgreSQL 16」でも接続方式・認証・HA構成はクラウド固有
- 真のポータビリティには Terraform コードの書き換えが必要
MD_EOF

echo "差異分析ドキュメントを作成しました: analysis.md"
echo ""

# ==========================================
# 演習3: マルチクラウド判断マトリクス
# ==========================================
echo "=========================================="
echo "演習3: マルチクラウド判断マトリクス"
echo "=========================================="
echo ""

cat > decision-matrix.md << 'MD_EOF'
# マルチクラウド判断マトリクス

## あなたの組織はマルチクラウドが本当に必要か？

各項目を 1（低い）〜 5（高い）で評価する。

| #  | 判断基準                                 | スコア (1-5) | 備考 |
|----|------------------------------------------|:------------:|------|
| 1  | 規制要件でマルチクラウドが必要           |              |      |
| 2  | 単一クラウドの障害が致命的な影響を与える |              |      |
| 3  | 特定クラウドの固有サービスへの依存が少ない|              |      |
| 4  | 複数クラウドの専門家を確保できる         |              |      |
| 5  | クラウド間のデータ転送量が少ない         |              |      |
| 6  | マルチクラウドの運用コスト増を許容できる |              |      |
| 7  | 現在のクラウドベンダーとの交渉力が不十分 |              |      |
| 8  | 特定のワークロードに最適なクラウドが異なる|              |      |

### スコアの解釈

- **合計 32-40**: マルチクラウドの強い正当性がある
- **合計 24-31**: 部分的なマルチクラウドが適切
- **合計 16-23**: 単一クラウドの深い活用を優先すべき
- **合計 8-15**: マルチクラウドのコストが便益を大きく上回る

### よくある「間違った理由」でのマルチクラウド

1. 「ベンダーロックインが怖い」→ ロックインの実際のコストを試算したか？
2. 「競合させて値引きを引き出す」→ 運用コスト増 > 値引き額 ではないか？
3. 「みんなやっているから」→ 自組織の具体的ニーズから判断しているか？
4. 「将来の選択肢を残したい」→ 今日の生産性を犠牲にしていないか？
MD_EOF

echo "判断マトリクスを作成しました: decision-matrix.md"
echo ""

# ==========================================
# 完了
# ==========================================
echo "=========================================="
echo "セットアップ完了"
echo "=========================================="
echo ""
echo "作成されたファイル:"
echo "  ${WORKDIR}/aws-web/main.tf       -- AWS Terraform 構成"
echo "  ${WORKDIR}/gcp-web/main.tf       -- GCP Terraform 構成"
echo "  ${WORKDIR}/analysis.md           -- 差異分析ドキュメント"
echo "  ${WORKDIR}/decision-matrix.md    -- マルチクラウド判断マトリクス"
echo ""
echo "演習の進め方:"
echo "  1. aws-web/main.tf と gcp-web/main.tf を比較し、差異を確認"
echo "  2. analysis.md を参照しながら、抽象化の限界を理解"
echo "  3. decision-matrix.md で自組織のマルチクラウド適性を評価"
echo ""
echo "Terraform を使った実際のデプロイ（任意）:"
echo "  cd ${WORKDIR}/aws-web && terraform init && terraform plan"
echo "  cd ${WORKDIR}/gcp-web && terraform init && terraform plan"
