#!/bin/bash
# =============================================================================
# 第24回ハンズオン：データベース選定の評価マトリクスを作る
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: docker (演習5のみ)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/database-history-handson-24"

echo "=== 第24回ハンズオン：データベース選定の評価マトリクスを作る ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# =============================================================================
# 演習1: 要件定義テンプレート
# =============================================================================
echo "============================================================"
echo "[演習1] 要件定義テンプレート"
echo "============================================================"
echo ""

cat > "${WORKDIR}/requirements-template.txt" << 'TEMPLATE'
============================================================
データベース選定 要件定義シート
============================================================

プロジェクト名: ___________________
記入日:         ___________________
記入者:         ___________________

[1. データの性質]
  主要なデータ型:     ___________________
  (構造化 / 半構造化 / 非構造化 / 時系列 / グラフ)
  スキーマの変更頻度: 低 / 中 / 高
  データ間の関連性:   単純 / 中程度 / 複雑（多対多のJOINが頻繁）

[2. アクセスパターン]
  読み取り:書き込み比率: ___:___
  主要な操作:           CRUD / 集計・分析 / 全文検索 / 時系列集約
  レイテンシ要件:       <10ms / <100ms / <1s / 許容
  バッチ処理の有無:     あり / なし

[3. 一貫性要件]
  トランザクション:     必須(ACID) / 部分的 / 不要
  一貫性レベル:         強一貫性 / 結果整合性 / 混合
  データ損失の許容度:   ゼロ / 数秒分まで / 数分分まで

[4. スケール要件]
  初期データ量:         ___GB
  1年後の予測:          ___GB
  3年後の予測:          ___GB
  同時接続数:           ___
  書き込みTPS:          ___
  読み取りTPS:          ___

[5. 運用体制]
  DBAの有無:           いる / いない
  インフラチーム:       いる / いない
  クラウド:             AWS / GCP / Azure / オンプレ / ハイブリッド
  運用予算(月額):       ___円
  SLA要件:             99.9% / 99.95% / 99.99%

[6. エコシステム]
  チームのDB経験:      ___________________
  使用言語/FW:         ___________________
  既存インフラ:        ___________________
  採用市場の制約:      ___________________
============================================================
TEMPLATE

echo "要件定義テンプレートを作成しました: ${WORKDIR}/requirements-template.txt"
echo ""

# =============================================================================
# 演習2: ECサイトシナリオでのスコアリング
# =============================================================================
echo "============================================================"
echo "[演習2] ECサイトシナリオでのスコアリング"
echo "============================================================"
echo ""

cat > "${WORKDIR}/scoring-ec-site.txt" << 'SCORING'
============================================================
シナリオ: ECサイトの注文管理システム
============================================================

要件:
- 構造化データ中心（顧客、商品、注文、在庫）
- 読み取り:書き込み = 7:3
- 強一貫性必須（在庫管理、決済処理）
- 初期10GB、1年後100GB
- DBAなし、AWS利用
- チームはPostgreSQL経験あり

評価基準: 1(不適合) - 5(最適)

                  PostgreSQL  MySQL  DynamoDB  MongoDB
                  (RDS)       (RDS)
──────────────────────────────────────────────────────
データの性質       5           5      3         4
  構造化/JOIN多

アクセスパターン   5           4      3         4
  OLTP/複雑JOIN

一貫性要件        5           5      2         3
  ACID必須

スケール要件      5           5      5         4
  〜100GB

運用体制          5           5      5         5
  AWS RDS

エコシステム      5           4      3         3
  チーム経験
──────────────────────────────────────────────────────
合計              30          28     21        23
──────────────────────────────────────────────────────

結論: PostgreSQL (RDS) が最適

根拠:
- 構造化データのJOIN操作で最も表現力が高い
- ACID保証が在庫管理の一貫性要件を満たす
- 100GB規模なら単一ノードで十分
- チームの既存スキルが活かせる
============================================================
SCORING

echo "ECサイトスコアリングを作成しました: ${WORKDIR}/scoring-ec-site.txt"
echo ""

# =============================================================================
# 演習3: IoTシナリオでのスコアリング
# =============================================================================
echo "============================================================"
echo "[演習3] IoTシナリオでのスコアリング"
echo "============================================================"
echo ""

cat > "${WORKDIR}/scoring-iot.txt" << 'SCORING'
============================================================
シナリオ: IoTセンサーデータの収集・分析基盤
============================================================

要件:
- 数千台のセンサーから毎秒データ受信
- 時系列データが中心、スキーマは固定
- リアルタイムダッシュボードと過去データの分析
- 結果整合性で十分
- 初期1TB、1年後10TB
- 小規模チーム、GCP利用

                  TimescaleDB  InfluxDB  PostgreSQL  ClickHouse
                  (on GCE)     (Cloud)   (Cloud SQL) (on GCE)
──────────────────────────────────────────────────────────────
データの性質       5            5         3           4
  時系列データ

アクセスパターン   5            5         2           5
  追記+集約

一貫性要件        4            3         5           3
  結果整合性可

スケール要件      4            4         2           5
  〜10TB

運用体制          3            5         5           2
  マネージド優先

エコシステム      4            4         5           3
  PG経験あり
──────────────────────────────────────────────────────────────
合計              25           26        22          22
──────────────────────────────────────────────────────────────

結論: InfluxDB Cloud または TimescaleDB

判断の分岐:
- 運用負荷最小化 → InfluxDB Cloud
- PostgreSQLスキル活用 → TimescaleDB
============================================================
SCORING

echo "IoTスコアリングを作成しました: ${WORKDIR}/scoring-iot.txt"
echo ""

# =============================================================================
# 演習4: アンチパターン集
# =============================================================================
echo "============================================================"
echo "[演習4] データベース選定のアンチパターン"
echo "============================================================"
echo ""

cat > "${WORKDIR}/anti-patterns.txt" << 'ANTIPATTERN'
============================================================
データベース選定のアンチパターン
============================================================

[1] 流行追従型
  「みんながMongoDBを使っているから」
  「NewSQLが話題だから」
  → 要件を先に定義し、要件に合うものを選べ

[2] 過剰設計型
  「将来スケールが必要になるかもしれない」
  → YAGNIの原則。PostgreSQLの単一ノードは想像以上に強い
  → 数百GBまでなら垂直スケールで十分なことが多い

[3] フレームワーク依存型
  「RailsのデフォルトがSQLiteだから」
  「Next.jsのチュートリアルがPrisma+PostgreSQLだから」
  → フレームワークのデフォルトは開発の手軽さのため
  → 本番要件とは別に判断せよ

[4] SQL忌避型
  「SQLを書きたくないからNoSQL」
  → NoSQLはSQLの代替ではない
  → データの性質とアクセスパターンから判断せよ
  → SQLはあらゆる場所に回帰している

[5] 銀の弾丸型
  「PostgreSQLなら何でもできる」
  → 拡張性は高いが、専用DBが明確に適する用途もある
  → 大規模時系列、大規模グラフ、大規模全文検索は専用DBを検討
============================================================
ANTIPATTERN

echo "アンチパターン集を作成しました: ${WORKDIR}/anti-patterns.txt"
echo ""

# =============================================================================
# 演習5: PostgreSQLの拡張エコシステム体験
# =============================================================================
echo "============================================================"
echo "[演習5] PostgreSQLの拡張エコシステム体験"
echo "============================================================"
echo ""

# 既存コンテナがあれば削除
docker rm -f pg-strata 2>/dev/null || true

docker run -d \
  --name pg-strata \
  -e POSTGRES_PASSWORD=handson \
  -e POSTGRES_DB=strata_db \
  -p 5432:5432 \
  pgvector/pgvector:pg17

echo "PostgreSQL + pgvector 起動を待機中..."
sleep 5

# --- JSONB: ドキュメント指向の機能 ---
echo ""
echo "[5-1] JSONB: PostgreSQLでドキュメント指向"
docker exec -i pg-strata psql -U postgres -d strata_db << 'SQL'
-- PostgreSQLのJSONBでドキュメント指向の機能を体験
-- MongoDBのようなスキーマレスなデータ管理

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  data JSONB NOT NULL
);

-- 異なる構造のドキュメントを同じテーブルに格納
INSERT INTO products (data) VALUES
('{"name": "PostgreSQL入門", "type": "book", "price": 3200, "author": "田中太郎", "pages": 400}'::jsonb),
('{"name": "SQLマスター講座", "type": "course", "price": 15000, "duration_hours": 20, "platform": "Udemy"}'::jsonb),
('{"name": "DB設計テンプレート", "type": "template", "price": 0, "format": "SQL", "tables": 15}'::jsonb);

-- JSONB演算子で柔軟な検索
SELECT data->>'name' AS name, data->>'type' AS type, (data->>'price')::int AS price
FROM products
WHERE (data->>'price')::int > 0
ORDER BY (data->>'price')::int DESC;

-- GINインデックスで高速検索
CREATE INDEX idx_products_data ON products USING GIN (data);

-- 特定のキーを含むドキュメントだけを検索
SELECT data->>'name' AS name
FROM products
WHERE data ? 'author';
SQL

echo ""

# --- pgvector: ベクトル検索 ---
echo "[5-2] pgvector: PostgreSQLでベクトル検索"
docker exec -i pg-strata psql -U postgres -d strata_db << 'SQL'
-- pgvectorでベクトル類似検索を体験
-- 専用ベクトルDBなしでセマンティック検索が可能

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE documents (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  embedding vector(3)  -- 簡略化のため3次元ベクトル
);

-- サンプルデータ（実際にはEmbedding APIで生成する）
INSERT INTO documents (title, content, embedding) VALUES
('リレーショナルモデル', 'Coddが1970年に提唱したデータモデル', '[0.9, 0.1, 0.2]'),
('NoSQLデータベース',   'スケーラビリティを重視した非RDB',     '[0.2, 0.8, 0.3]'),
('NewSQL',              'RDBとNoSQLの長所を統合する試み',       '[0.6, 0.5, 0.7]'),
('CAP定理',             '分散システムの制約を定式化した定理',   '[0.3, 0.7, 0.5]'),
('ACID特性',            'トランザクションの4つの保証',          '[0.8, 0.2, 0.3]');

-- HNSWインデックスの作成
CREATE INDEX idx_documents_embedding ON documents USING hnsw (embedding vector_cosine_ops);

-- ベクトル類似検索: 「リレーショナルモデル」に近いドキュメント
SELECT title, content,
       1 - (embedding <=> '[0.9, 0.1, 0.2]') AS similarity
FROM documents
ORDER BY embedding <=> '[0.9, 0.1, 0.2]'
LIMIT 3;

-- ベクトル類似検索: 「分散システム」に近いドキュメント
SELECT title, content,
       1 - (embedding <=> '[0.3, 0.7, 0.5]') AS similarity
FROM documents
ORDER BY embedding <=> '[0.3, 0.7, 0.5]'
LIMIT 3;
SQL

echo ""

# --- 全体のまとめ ---
echo "[まとめ] PostgreSQLの拡張エコシステム"
docker exec -i pg-strata psql -U postgres -d strata_db << 'SQL'
-- PostgreSQLが拡張で対応できる領域
SELECT 'JSONB' AS feature,
       'ドキュメント指向（MongoDB的）' AS description,
       'PostgreSQL標準機能' AS source
UNION ALL
SELECT 'pgvector',
       'ベクトル類似検索（Pinecone的）',
       'pgvector拡張'
UNION ALL
SELECT 'TimescaleDB',
       '時系列データ（InfluxDB的）',
       'TimescaleDB拡張'
UNION ALL
SELECT 'PostGIS',
       '地理空間データ（専用GIS DB的）',
       'PostGIS拡張'
UNION ALL
SELECT 'Apache AGE',
       'グラフデータ（Neo4j的）',
       'Apache AGE拡張'
UNION ALL
SELECT 'tsvector',
       '全文検索（Elasticsearch的）',
       'PostgreSQL標準機能';
SQL

echo ""
echo "============================================================"
echo "全演習が完了しました"
echo ""
echo "作成したファイル:"
echo "  ${WORKDIR}/requirements-template.txt  -- 要件定義テンプレート"
echo "  ${WORKDIR}/scoring-ec-site.txt        -- ECサイトスコアリング"
echo "  ${WORKDIR}/scoring-iot.txt            -- IoTスコアリング"
echo "  ${WORKDIR}/anti-patterns.txt          -- アンチパターン集"
echo ""
echo "後片付け:"
echo "  docker stop pg-strata && docker rm pg-strata"
echo "============================================================"
