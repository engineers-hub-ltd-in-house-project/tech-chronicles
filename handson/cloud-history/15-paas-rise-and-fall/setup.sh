#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-15"

echo "============================================"
echo " クラウドの考古学 第15回 ハンズオン"
echo " PaaSの栄枯盛衰"
echo " 第一世代PaaSとPaaS 2.0の違いを体験する"
echo "============================================"
echo ""

# -----------------------------------------------
echo ">>> 環境セットアップ"
# -----------------------------------------------
apt-get update -qq && apt-get install -y -qq python3 python3-pip python3-venv curl git nodejs npm > /dev/null 2>&1
echo "必要なパッケージをインストールしました"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# -----------------------------------------------
echo ">>> 演習1: 第一世代PaaSの制約をシミュレートする"
# -----------------------------------------------
echo "Herokuモデルの制約を再現します..."

cat > Procfile << 'EOF'
web: python3 app.py
worker: python3 worker.py
EOF

cat > runtime.txt << 'EOF'
python-3.12.x
EOF

cat > requirements.txt << 'EOF'
flask==3.0.0
redis==5.0.0
EOF

cat > app.py << 'PYEOF'
"""第一世代PaaSモデルのアプリケーション"""
import os
import json
import sys

PORT = int(os.environ.get("PORT", 8080))
DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///local.db")

def check_paas_constraints():
    """第一世代PaaSの制約を確認する"""
    constraints = {
        "環境変数による設定": bool(os.environ.get("PORT")),
        "揮発性ファイルシステム": True,
        "プロセスの使い捨て性": True,
        "ポートバインディング": f"PORT={PORT}",
        "ログは標準出力へ": True,
    }
    return constraints

print(f"[INFO] Starting on port {PORT}", file=sys.stdout)
print(f"[INFO] Database: {DATABASE_URL}", file=sys.stdout)
print(f"[INFO] Constraints: {json.dumps(check_paas_constraints(), indent=2, ensure_ascii=False)}", file=sys.stdout)
PYEOF

python3 app.py

echo ""
echo "=== 第一世代PaaSの制約 ==="
echo "1. Procfile: プロセスタイプの宣言（web, worker）"
echo "2. runtime.txt: ランタイムバージョンの指定"
echo "3. requirements.txt: 依存関係の宣言"
echo "4. 環境変数: 設定は環境変数経由（DATABASE_URL等）"
echo "5. 揮発性FS: ファイルシステムへの永続的書き込み不可"
echo ""
echo "問題点:"
echo "  - Procfile/runtime.txtはHeroku固有の仕様"
echo "  - Buildpackがサポートしない構成は使えない"
echo "  - 別のPaaSに移行するとデプロイ設定の書き直しが必要"
echo ""

# -----------------------------------------------
echo ">>> 演習2: PaaS 2.0（コンテナベース）との対比"
# -----------------------------------------------
echo "Dockerfileベースのデプロイモデルを確認します..."

cat > Dockerfile << 'DOCKERFILE'
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
ENV PORT=8080
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:${PORT}/health || exit 1
EXPOSE ${PORT}
CMD ["python3", "app.py"]
DOCKERFILE

echo "=== PaaS 2.0（コンテナベース）の利点 ==="
echo ""
echo "1. Dockerfileは業界標準 -- OCI準拠のコンテナイメージ"
echo "2. 同じイメージが複数のプラットフォームで動作:"
echo "   - fly deploy          (Fly.io)"
echo "   - render deploy       (Render)"
echo "   - railway up          (Railway)"
echo "   - gcloud run deploy   (Cloud Run)"
echo "   - kubectl apply       (Kubernetes)"
echo ""

cat > compare.py << 'PYEOF'
"""第一世代PaaSとPaaS 2.0の比較"""

first_gen = {
    "パッケージング": "Procfile + runtime.txt + Buildpack（プラットフォーム固有）",
    "ランタイム": "プラットフォーム管理（選択肢が限定）",
    "システム依存": "Buildpackが対応するもののみ",
    "ポータビリティ": "低い（移行にはデプロイ設定の書き直しが必要）",
    "カスタマイズ": "限定的（Buildpackの範囲内）",
    "移行コスト": "高い（3ヶ月以上のケースも）",
}

second_gen = {
    "パッケージング": "Dockerfile（OCI標準）",
    "ランタイム": "開発者が自由に選択（Dockerfile内で定義）",
    "システム依存": "任意（apt-get等でインストール可能）",
    "ポータビリティ": "高い（同一イメージが複数環境で動作）",
    "カスタマイズ": "高い（Dockerfile内で自由に構成）",
    "移行コスト": "低い（デプロイコマンドの変更程度）",
}

print("=" * 60)
print("第一世代PaaS vs PaaS 2.0 比較")
print("=" * 60)
for key in first_gen:
    print(f"\n--- {key} ---")
    print(f"  第一世代: {first_gen[key]}")
    print(f"  PaaS 2.0: {second_gen[key]}")
print()
PYEOF

python3 compare.py
echo ""

# -----------------------------------------------
echo ">>> 演習3: PaaSプラットフォームのロックイン度を測定する"
# -----------------------------------------------
echo "各PaaSのロックイン度を定量分析します..."

cat > lockIn_analysis.py << 'PYEOF'
"""PaaSプラットフォームのロックイン度分析"""

platforms = {
    "Heroku（第一世代）": {
        "パッケージング固有性": 4,
        "ランタイム固有性": 3,
        "データベース固有性": 2,
        "アドオン依存": 5,
        "デプロイ設定固有性": 4,
        "ネットワーク設定固有性": 3,
    },
    "GAE Standard（第一世代）": {
        "パッケージング固有性": 5,
        "ランタイム固有性": 5,
        "データベース固有性": 5,
        "アドオン依存": 4,
        "デプロイ設定固有性": 5,
        "ネットワーク設定固有性": 4,
    },
    "Cloud Run（PaaS 2.0）": {
        "パッケージング固有性": 1,
        "ランタイム固有性": 1,
        "データベース固有性": 2,
        "アドオン依存": 2,
        "デプロイ設定固有性": 2,
        "ネットワーク設定固有性": 2,
    },
    "Fly.io（PaaS 2.0）": {
        "パッケージング固有性": 1,
        "ランタイム固有性": 1,
        "データベース固有性": 2,
        "アドオン依存": 2,
        "デプロイ設定固有性": 2,
        "ネットワーク設定固有性": 3,
    },
}

print("=== PaaSプラットフォーム ロックイン度分析 ===")
print()
for name, scores in platforms.items():
    total = sum(scores.values())
    avg = total / len(scores)
    max_score = max(scores.values())
    max_factor = [k for k, v in scores.items() if v == max_score][0]
    print(f"  {name}")
    print(f"  総合スコア: {total}/30 (平均: {avg:.1f}/5.0)")
    print(f"  最大ロックイン要因: {max_factor} ({max_score}/5)")
    for factor, score in scores.items():
        bar = "X" * score + "." * (5 - score)
        print(f"    {factor:24s} [{bar}] {score}/5")
    print()

print("考察:")
print("  第一世代PaaS（Heroku, GAE Standard）は")
print("  ロックインスコアが高い（21-28/30）。")
print("  PaaS 2.0（Cloud Run, Fly.io）はコンテナ標準化により")
print("  スコアが大幅に低下（10-11/30）している。")
print()
print("  ただし、PaaS 2.0でもデータベースやネットワーク設定には")
print("  プラットフォーム固有の要素が残る。完全なポータビリティは")
print("  幻想であり、「ロックインの度合い」で判断すべきである。")
PYEOF

python3 lockIn_analysis.py

echo ""
echo "============================================"
echo " ハンズオン完了"
echo " 作業ディレクトリ: ${WORKDIR}"
echo "============================================"
