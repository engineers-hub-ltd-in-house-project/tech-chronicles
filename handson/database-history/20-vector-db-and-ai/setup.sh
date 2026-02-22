#!/bin/bash
# =============================================================================
# 第20回ハンズオン：pgvectorでセマンティック検索を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: docker, psql
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-20"
CONTAINER_NAME="pgvector-handson"
PG_PASSWORD="handson"
PG_DB="vectordb"
PG_PORT="5432"

echo "=== 第20回ハンズオン：pgvectorでセマンティック検索を体験する ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- 前提条件チェック ---
echo "[準備] 前提条件を確認"

if ! command -v docker &>/dev/null; then
  echo "  エラー: Docker がインストールされていない"
  echo "  https://docs.docker.com/get-docker/ からインストールすること"
  exit 1
fi
echo "  Docker: $(docker --version)"

if ! command -v psql &>/dev/null; then
  echo "  警告: psql がインストールされていない"
  echo "  PostgreSQLクライアントをインストールすること"
  echo "  Ubuntu: sudo apt install postgresql-client"
  echo "  macOS:  brew install libpq"
  exit 1
fi
echo "  psql: $(psql --version)"
echo ""

# --- 既存コンテナの削除 ---
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "[準備] 既存コンテナ '${CONTAINER_NAME}' を削除"
  docker stop "${CONTAINER_NAME}" 2>/dev/null || true
  docker rm "${CONTAINER_NAME}" 2>/dev/null || true
  echo ""
fi

# --- PostgreSQL + pgvector の起動 ---
echo "[演習1] PostgreSQL + pgvector を起動"
docker run -d \
  --name "${CONTAINER_NAME}" \
  -e POSTGRES_PASSWORD="${PG_PASSWORD}" \
  -e POSTGRES_DB="${PG_DB}" \
  -p "${PG_PORT}:5432" \
  pgvector/pgvector:pg17

echo "  コンテナの起動を待機中..."
sleep 5

# 接続確認
PGPASSWORD="${PG_PASSWORD}" psql -h localhost -p "${PG_PORT}" -U postgres -d "${PG_DB}" -c "SELECT version();" >/dev/null 2>&1
echo "  PostgreSQL + pgvector が起動した"
echo ""

# --- pgvector拡張の有効化とテーブル作成 ---
echo "[演習1] pgvector拡張の有効化とテーブル作成"

PGPASSWORD="${PG_PASSWORD}" psql -h localhost -p "${PG_PORT}" -U postgres -d "${PG_DB}" <<'SQL'
-- pgvector拡張の有効化
CREATE EXTENSION IF NOT EXISTS vector;

-- ベクトルカラムを持つテーブルの作成（3次元の簡易ベクトル）
CREATE TABLE tech_articles (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT NOT NULL,
  published_at DATE NOT NULL,
  embedding vector(3)
);
SQL

echo "  pgvector拡張の有効化とテーブル作成が完了した"
echo ""

# --- データ投入 ---
echo "[演習2] データ投入"

PGPASSWORD="${PG_PASSWORD}" psql -h localhost -p "${PG_PORT}" -U postgres -d "${PG_DB}" <<'SQL'
INSERT INTO tech_articles (title, content, category, published_at, embedding) VALUES
  ('JWT認証の実装ガイド',
   'JWTを使ったステートレス認証の設計パターンとリフレッシュトークンの実装方法',
   'security', '2024-06-15',
   '[0.85, 0.12, 0.72]'),

  ('OAuth 2.0 PKCEフロー解説',
   'パブリッククライアントにおけるOAuth 2.0 PKCEフローの実装とセキュリティ考慮事項',
   'security', '2024-07-20',
   '[0.82, 0.15, 0.68]'),

  ('PostgreSQLインデックス設計',
   'B-Treeインデックスの構造と複合インデックスの最左一致の法則',
   'database', '2024-05-10',
   '[0.10, 0.88, 0.35]'),

  ('Docker Compose入門',
   '開発環境をDockerComposeで構築するベストプラクティス',
   'infrastructure', '2024-04-01',
   '[0.15, 0.30, 0.90]'),

  ('セッション管理のベストプラクティス',
   'Webアプリケーションにおけるセッション管理のセキュリティ対策',
   'security', '2024-08-05',
   '[0.80, 0.18, 0.65]'),

  ('Kubernetesネットワーキング入門',
   'Pod間通信とServiceの仕組みを理解する',
   'infrastructure', '2024-03-15',
   '[0.18, 0.25, 0.88]'),

  ('SSL/TLS証明書の仕組み',
   'SSL/TLS証明書の認証局と証明書チェーンの解説',
   'security', '2024-09-10',
   '[0.55, 0.20, 0.45]');
SQL

echo "  === 投入データ ==="
PGPASSWORD="${PG_PASSWORD}" psql -h localhost -p "${PG_PORT}" -U postgres -d "${PG_DB}" \
  -c "SELECT id, title, category FROM tech_articles ORDER BY id;"
echo ""

# --- キーワード検索 vs セマンティック検索 ---
echo "[演習2] キーワード検索 vs セマンティック検索"
echo ""

echo "  --- キーワード検索: '認証' を含む記事 ---"
PGPASSWORD="${PG_PASSWORD}" psql -h localhost -p "${PG_PORT}" -U postgres -d "${PG_DB}" \
  -c "SELECT title, content FROM tech_articles WHERE content LIKE '%認証%' ORDER BY published_at DESC;"
echo ""
echo "  >>> LIKE検索ではJWT認証とSSL/TLS証明書がヒット"
echo "  >>> OAuthやセッション管理は '認証' を含まないためヒットしない"
echo ""

echo "  --- セマンティック検索: 'ログインのセキュリティ強化' に意味的に近い記事 ---"
echo "  （クエリベクトル: [0.83, 0.14, 0.70]）"
PGPASSWORD="${PG_PASSWORD}" psql -h localhost -p "${PG_PORT}" -U postgres -d "${PG_DB}" <<'SQL'
SELECT title,
       ROUND((1 - (embedding <=> '[0.83, 0.14, 0.70]'))::numeric, 4) AS similarity
FROM tech_articles
ORDER BY embedding <=> '[0.83, 0.14, 0.70]'
LIMIT 5;
SQL
echo ""
echo "  >>> ベクトル検索ではJWT認証、OAuth PKCE、セッション管理が上位に"
echo "  >>> キーワードに依存せず、意味的な近さで検索できている"
echo ""

# --- HNSWインデックス ---
echo "[演習3] HNSWインデックスの作成"

PGPASSWORD="${PG_PASSWORD}" psql -h localhost -p "${PG_PORT}" -U postgres -d "${PG_DB}" <<'SQL'
-- HNSWインデックスの作成
CREATE INDEX idx_tech_articles_embedding
  ON tech_articles USING hnsw (embedding vector_cosine_ops);

-- インデックスを使った検索のEXPLAIN
EXPLAIN ANALYZE
SELECT title,
       1 - (embedding <=> '[0.83, 0.14, 0.70]') AS similarity
FROM tech_articles
ORDER BY embedding <=> '[0.83, 0.14, 0.70]'
LIMIT 3;
SQL
echo ""
echo "  >>> 少量データではSeq Scanが選択される場合がある"
echo "  >>> 数万件以上でHNSWインデックスの効果が顕著になる"
echo ""

# --- フィルタリング付きベクトル検索 ---
echo "[演習4] フィルタリング付きベクトル検索"
echo ""
echo "  --- securityカテゴリ + 2024年6月以降 + セマンティック検索 ---"

PGPASSWORD="${PG_PASSWORD}" psql -h localhost -p "${PG_PORT}" -U postgres -d "${PG_DB}" <<'SQL'
SELECT title, category, published_at,
       ROUND((1 - (embedding <=> '[0.83, 0.14, 0.70]'))::numeric, 4) AS similarity
FROM tech_articles
WHERE category = 'security'
  AND published_at >= '2024-06-01'
ORDER BY embedding <=> '[0.83, 0.14, 0.70]'
LIMIT 3;
SQL
echo ""
echo "  >>> pgvectorの強み: SQLのWHERE句とベクトル検索を一つのクエリで実行できる"
echo "  >>> リレーショナルなフィルタリングとセマンティック検索の融合"
echo ""

echo "=== セットアップ完了 ==="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "コンテナ名: ${CONTAINER_NAME}"
echo ""
echo "手動で試すには:"
echo "  PGPASSWORD=${PG_PASSWORD} psql -h localhost -p ${PG_PORT} -U postgres -d ${PG_DB}"
echo ""
echo "後片付け:"
echo "  docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME}"
