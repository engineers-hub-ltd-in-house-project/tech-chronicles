#!/bin/bash
set -euo pipefail

# ============================================================
# 第16回ハンズオン：マルチテナントSaaSの基本アーキテクチャ
# ============================================================
# SaaSバックエンドの核心であるテナント分離戦略を実装・比較する
# 3つのモデル: プール（RLS）、ブリッジ（スキーマ分離）、比較分析
# ============================================================

WORKDIR="${HOME}/cloud-history-handson-16"

echo "============================================================"
echo " 第16回ハンズオン: マルチテナントSaaSの基本アーキテクチャ"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --------------------------------------------------
# 演習1: プールモデル -- Row-Level Securityによるテナント分離
# --------------------------------------------------
echo ""
echo "============================================================"
echo " 演習1: プールモデル（Row-Level Security）"
echo "============================================================"
echo ""

# 既存コンテナがあれば停止・削除
docker rm -f saas-rls 2>/dev/null || true

echo "--- PostgreSQL 16 コンテナを起動 ---"
docker run -d --name saas-rls \
  -e POSTGRES_DB=saas_app \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:16

echo "PostgreSQL起動を待機中..."
sleep 5

echo ""
echo "--- テナントテーブルとデータの作成 ---"
docker exec -i saas-rls psql -U admin -d saas_app << 'SQL'
-- テナント管理テーブル
CREATE TABLE tenants (
    tenant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    plan TEXT NOT NULL DEFAULT 'free',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- テナントデータ（共有テーブル）
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- テナントを3つ作成
INSERT INTO tenants (tenant_id, name, plan) VALUES
    ('aaaaaaaa-0000-0000-0000-000000000001', 'Acme Corp', 'enterprise'),
    ('bbbbbbbb-0000-0000-0000-000000000002', 'Beta Inc', 'pro'),
    ('cccccccc-0000-0000-0000-000000000003', 'Charlie LLC', 'free');

-- 各テナントのプロジェクトを追加
INSERT INTO projects (tenant_id, name, description) VALUES
    ('aaaaaaaa-0000-0000-0000-000000000001', 'Project Alpha', 'Acmeの社内プロジェクト'),
    ('aaaaaaaa-0000-0000-0000-000000000001', 'Project Omega', 'Acmeの顧客向けプロジェクト'),
    ('bbbbbbbb-0000-0000-0000-000000000002', 'Beta Launch', 'Betaの新製品開発'),
    ('cccccccc-0000-0000-0000-000000000003', 'Charlie MVP', 'Charlieの初期プロダクト');
SQL

echo ""
echo "--- Row-Level Security を設定 ---"
docker exec -i saas-rls psql -U admin -d saas_app << 'SQL'
-- RLSを有効化
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- テナント別のロールを作成
CREATE ROLE tenant_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON projects TO tenant_user;
GRANT USAGE, SELECT ON SEQUENCE projects_id_seq TO tenant_user;

-- RLSポリシーを定義
CREATE POLICY tenant_isolation ON projects
    USING (tenant_id = current_setting('app.current_tenant')::UUID)
    WITH CHECK (tenant_id = current_setting('app.current_tenant')::UUID);

-- 管理者は全データが見える（RLSバイパス）
SELECT '=== 管理者: 全テナントのデータ ===' AS info;
SELECT t.name AS tenant, p.name AS project
FROM projects p JOIN tenants t ON p.tenant_id = t.tenant_id
ORDER BY t.name, p.name;
SQL

echo ""
echo "--- テナントAとしてアクセス ---"
docker exec -i saas-rls psql -U admin -d saas_app << 'SQL'
SET app.current_tenant = 'aaaaaaaa-0000-0000-0000-000000000001';
SET ROLE tenant_user;

SELECT '=== テナントA（Acme Corp）: 自分のデータのみ ===' AS info;
SELECT id, name, description FROM projects;
SELECT '行数:' AS label, count(*) AS count FROM projects;

RESET ROLE;
SQL

echo ""
echo "--- テナントBとしてアクセス ---"
docker exec -i saas-rls psql -U admin -d saas_app << 'SQL'
SET app.current_tenant = 'bbbbbbbb-0000-0000-0000-000000000002';
SET ROLE tenant_user;

SELECT '=== テナントB（Beta Inc）: 自分のデータのみ ===' AS info;
SELECT id, name, description FROM projects;
SELECT '行数:' AS label, count(*) AS count FROM projects;

RESET ROLE;
SQL

echo ""
echo "--- テナントCとしてアクセス ---"
docker exec -i saas-rls psql -U admin -d saas_app << 'SQL'
SET app.current_tenant = 'cccccccc-0000-0000-0000-000000000003';
SET ROLE tenant_user;

SELECT '=== テナントC（Charlie LLC）: 自分のデータのみ ===' AS info;
SELECT id, name, description FROM projects;
SELECT '行数:' AS label, count(*) AS count FROM projects;

RESET ROLE;
SQL

echo ""
echo "考察:"
echo "  1. RLSにより、SQLクエリにWHERE句を明示的に追加しなくても"
echo "     テナント分離が実現される"
echo "  2. セッション変数（app.current_tenant）の設定がセキュリティの生命線"
echo "  3. テナントIDの設定ミス/漏れが致命的"
echo "     -> アプリケーション層でのミドルウェアによる自動設定が必須"

echo ""
echo "--- 演習1 クリーンアップ ---"
docker stop saas-rls && docker rm saas-rls
echo "演習1 完了"

# --------------------------------------------------
# 演習2: ブリッジモデル -- スキーマ分離
# --------------------------------------------------
echo ""
echo "============================================================"
echo " 演習2: ブリッジモデル（Schema-per-Tenant）"
echo "============================================================"
echo ""

docker run -d --name saas-schema \
  -e POSTGRES_DB=saas_app \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:16

echo "PostgreSQL起動を待機中..."
sleep 5

echo ""
echo "--- テナントごとのスキーマを作成 ---"
docker exec -i saas-schema psql -U admin -d saas_app << 'SQL'
-- テナントごとにスキーマを作成
CREATE SCHEMA tenant_acme;
CREATE SCHEMA tenant_beta;
CREATE SCHEMA tenant_charlie;

-- 各スキーマに同じテーブル構造を作成
DO $$
DECLARE
    schema_name TEXT;
BEGIN
    FOR schema_name IN SELECT unnest(ARRAY['tenant_acme', 'tenant_beta', 'tenant_charlie'])
    LOOP
        EXECUTE format('
            CREATE TABLE %I.projects (
                id SERIAL PRIMARY KEY,
                name TEXT NOT NULL,
                description TEXT,
                created_at TIMESTAMPTZ DEFAULT now()
            )', schema_name);
    END LOOP;
END $$;

-- 各テナントのスキーマにデータを投入
INSERT INTO tenant_acme.projects (name, description)
VALUES ('Project Alpha', 'Acmeの社内プロジェクト'),
       ('Project Omega', 'Acmeの顧客向けプロジェクト');

INSERT INTO tenant_beta.projects (name, description)
VALUES ('Beta Launch', 'Betaの新製品開発');

INSERT INTO tenant_charlie.projects (name, description)
VALUES ('Charlie MVP', 'Charlieの初期プロダクト');

-- テナントごとのデータ確認
SELECT '=== テナントA（tenant_acme） ===' AS info;
SELECT * FROM tenant_acme.projects;

SELECT '=== テナントB（tenant_beta） ===' AS info;
SELECT * FROM tenant_beta.projects;

SELECT '=== テナントC（tenant_charlie） ===' AS info;
SELECT * FROM tenant_charlie.projects;
SQL

echo ""
echo "--- search_pathによるテナント切り替え ---"
docker exec -i saas-schema psql -U admin -d saas_app << 'SQL'
-- search_pathでテナントAを設定
SET search_path TO tenant_acme, public;
SELECT '=== search_path: tenant_acme ===' AS info;
SELECT * FROM projects;

-- search_pathでテナントBに切り替え
SET search_path TO tenant_beta, public;
SELECT '=== search_path: tenant_beta ===' AS info;
SELECT * FROM projects;

-- スキーマ一覧
SELECT '=== テナントスキーマ一覧 ===' AS info;
SELECT schema_name,
       (SELECT count(*) FROM information_schema.tables
        WHERE table_schema = schema_name) AS table_count
FROM information_schema.schemata
WHERE schema_name LIKE 'tenant_%'
ORDER BY schema_name;
SQL

echo ""
echo "考察:"
echo "  1. テナントごとにスキーマが独立 -- 物理的なデータ分離に近い"
echo "  2. search_pathの設定でテナント切り替えが可能"
echo "  3. スキーマ単位のバックアップ・リストアが可能"
echo "  4. テナント数が数千を超えるとDB側の制約に注意"

echo ""
echo "--- 演習2 クリーンアップ ---"
docker stop saas-schema && docker rm saas-schema
echo "演習2 完了"

# --------------------------------------------------
# 演習3: 3つのモデルの比較分析
# --------------------------------------------------
echo ""
echo "============================================================"
echo " 演習3: テナント分離戦略の比較分析"
echo "============================================================"
echo ""

cat << 'ANALYSIS'
==============================================
  マルチテナント テナント分離戦略の比較
==============================================

                    サイロ         ブリッジ        プール
                 (DB-per-      (Schema-per-    (Row-Level
                  Tenant)        Tenant)       Security)
------------------------------------------------------
データ隔離      ★★★★★         ★★★★☆         ★★★☆☆
コスト効率      ★☆☆☆☆         ★★★☆☆         ★★★★★
運用の容易さ    ★★☆☆☆         ★★★☆☆         ★★★★★
スケーラビリティ ★★☆☆☆         ★★★☆☆         ★★★★★
カスタマイズ性  ★★★★★         ★★★★☆         ★★☆☆☆
テナント追加    ★★☆☆☆         ★★★★☆         ★★★★★
バックアップ粒度 ★★★★★         ★★★★☆         ★★☆☆☆
ノイジーネイバー ★★★★★         ★★★☆☆         ★★☆☆☆
------------------------------------------------------

推奨ユースケース:

  サイロモデル:
    → 金融・医療など規制の厳しい業界
    → データの物理的分離が要件
    → 大企業向けのエンタープライズプラン

  ブリッジモデル:
    → セキュリティと効率のバランスが必要
    → 中規模のテナント数（数百〜数千）
    → プロプランの顧客向け

  プールモデル:
    → 大量のテナントを低コストで運用
    → テナント数が数千〜数万以上
    → フリープラン・スタータープランの顧客向け

実務上のベストプラクティス:
  多くの成熟したSaaSは、顧客のプランに応じて
  テナント分離の強度を変えるハイブリッドモデルを採用する。

  Enterprise  → サイロ（専用DB）
  Pro         → ブリッジ（スキーマ分離）
  Free/Start  → プール（RLS）
ANALYSIS

echo ""
echo "============================================================"
echo " ハンズオン完了"
echo "============================================================"
echo ""
echo "学んだこと:"
echo "  1. Row-Level Security（RLS）はアプリケーションコードを"
echo "     変更せずテナント分離を実現できる強力な仕組みである"
echo "  2. スキーマ分離はデータの物理的な分離に近く、"
echo "     バックアップ粒度と分離性のバランスが良い"
echo "  3. テナント分離戦略の選択は、規制要件、コスト、"
echo "     スケーラビリティのトレードオフで決まる"
echo "  4. 実務上はハイブリッドモデルが現実解"
