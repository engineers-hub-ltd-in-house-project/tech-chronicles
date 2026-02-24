#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-10"

echo "============================================================"
echo " クラウドの考古学 第10回 ハンズオン"
echo " Azure、GCP——三社のCLIで設計思想の違いを体感する"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "推奨実行環境:"
echo "  docker run -it --rm --name cloud-cli-handson ubuntu:24.04 bash"
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
  curl unzip less groff apt-transport-https ca-certificates gnupg \
  > /dev/null 2>&1
echo "基本パッケージをインストールしました"

# ============================================================
echo ""
echo "============================================================"
echo " 演習1: 三社のCLIをインストール"
echo "============================================================"
echo ""

echo "--- AWS CLI v2 ---"
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install --update 2>/dev/null || ./aws/install
rm -rf awscliv2.zip aws
echo "AWS CLI v2 インストール完了"
aws --version
echo ""

echo "--- Google Cloud SDK ---"
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
https://packages.cloud.google.com/apt cloud-sdk main" \
  > /etc/apt/sources.list.d/google-cloud-sdk.list
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg 2>/dev/null
apt-get update -qq && apt-get install -y -qq google-cloud-cli > /dev/null 2>&1
echo "Google Cloud SDK インストール完了"
gcloud --version 2>/dev/null | head -1
echo ""

echo "--- Azure CLI ---"
curl -sL https://aka.ms/InstallAzureCLIDeb | bash > /dev/null 2>&1
echo "Azure CLI インストール完了"
az --version 2>/dev/null | head -1
echo ""

# ============================================================
echo ""
echo "============================================================"
echo " 演習2: コマンド構造の比較——仮想マシン操作"
echo "============================================================"
echo ""

echo "三社のCLIで「仮想マシン一覧」を取得するコマンドの構造比較:"
echo ""
echo "  AWS:    aws ec2 describe-instances"
echo "          aws <service> <api-action>"
echo "          → APIアクション名がそのままサブコマンド"
echo "          → 「APIの薄いラッパー」設計"
echo ""
echo "  GCP:    gcloud compute instances list"
echo "          gcloud <product> <resource> <verb>"
echo "          → リソース中心の階層構造"
echo "          → 自然言語的に読める"
echo ""
echo "  Azure:  az vm list"
echo "          az <resource> <verb>"
echo "          → 最もフラットな構造"
echo "          → リソースグループ前提の管理"
echo ""

echo "--- 各CLIのヘルプ構造を確認 ---"
echo ""
echo "AWS CLI:"
aws ec2 describe-instances help 2>/dev/null | head -5 || \
  echo "  aws ec2 describe-instances --help で詳細を確認"
echo ""
echo "gcloud:"
gcloud compute instances list --help 2>/dev/null | head -5 || \
  echo "  gcloud compute instances list --help で詳細を確認"
echo ""
echo "Azure CLI:"
az vm list --help 2>/dev/null | head -5 || \
  echo "  az vm list --help で詳細を確認"
echo ""

# ============================================================
echo ""
echo "============================================================"
echo " 演習3: 出力フォーマットの比較"
echo "============================================================"
echo ""

echo "三社の出力制御方法の違い:"
echo ""
echo "  AWS:    --output json|text|table|yaml"
echo "          --query (JMESPath式)"
echo "          例: aws ec2 describe-instances \\"
echo "                --query 'Reservations[].Instances[].InstanceId'"
echo ""
echo "  GCP:    --format json|yaml|table|csv|value"
echo "          独自のフォーマット指定子"
echo "          例: gcloud compute instances list \\"
echo "                --format='table(name,zone,status)'"
echo ""
echo "  Azure:  --output json|jsonc|table|tsv|yaml"
echo "          --query (JMESPath式)"
echo "          例: az vm list \\"
echo "                --query '[].{Name:name, RG:resourceGroup}' \\"
echo "                --output table"
echo ""
echo "設計思想の反映:"
echo "  AWS  → 開発者がAPIレスポンスを自由にプログラマティック加工"
echo "  GCP  → 直感的なフォーマット指定による柔軟なカスタマイズ"
echo "  Azure → IT管理者に読みやすいテーブル出力がデフォルト"
echo ""

# ============================================================
echo ""
echo "============================================================"
echo " 演習4: リソース管理モデルの違い"
echo "============================================================"
echo ""

echo "三社のリソース管理の基本単位:"
echo ""
echo "  AWS:    タグベース"
echo "          ── 任意のキーバリューペアでリソースをグルーピング"
echo "          ── 柔軟だが強制力がない。運用規律が必要"
echo "          ── 例: aws ec2 describe-instances \\"
echo "                   --filters 'Name=tag:Env,Values=production'"
echo ""
echo "  GCP:    プロジェクトベース"
echo "          ── 課金・IAM・APIの有効化が全てプロジェクト単位"
echo "          ── 明確な境界でチーム/アプリを分離しやすい"
echo "          ── 例: gcloud projects list"
echo ""
echo "  Azure:  リソースグループベース"
echo "          ── 「一緒にデプロイ・一緒に削除」の論理グループ"
echo "          ── ライフサイクル管理が直感的"
echo "          ── 例: az group list"
echo ""

# ============================================================
echo ""
echo "============================================================"
echo " 全演習完了"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "この演習で学んだこと:"
echo "  1. CLIの構造が設計思想を直接反映している"
echo "  2. AWS=APIラッパー、GCP=リソース階層、Azure=フラット構造"
echo "  3. 出力制御に各社の想定ユーザー層の違いが表れる"
echo "  4. リソース管理（タグ/プロジェクト/リソースグループ）は"
echo "     プラットフォーム全体の設計哲学と一貫している"
echo ""
echo "注意: 実際のクラウド操作にはアカウントと認証が必要です。"
echo "各社の無料枠を利用してさらに深く探索してみてください:"
echo "  AWS:   https://aws.amazon.com/free/"
echo "  GCP:   https://cloud.google.com/free"
echo "  Azure: https://azure.microsoft.com/free/"
