# 第11回ハンズオン：レプリケーションとシャーディング——スケールの壁を越える

## 概要

PostgreSQLの論理レプリケーションを構築してレプリケーションラグを観測し、アプリケーション層での簡易シャーディングを体験する。レプリケーションでは書き込みがスレーブに反映されるまでのラグを計測し、シャーディングではクロスシャードクエリの困難さを実感する。

## 演習一覧

1. **論理レプリケーションの構築** — パブリッシャーとサブスクライバーの構成を確認し、データの同期を観察する
2. **レプリケーションラグの観測** — 大量データ投入時にサブスクライバーでの反映タイミングを計測する
3. **簡易シャーディングの体験** — ハッシュベースで2台のシャードにデータを分割し、シャード内クエリの動作を確認する
4. **クロスシャードクエリの困難さ** — 複数シャードにまたがる集約クエリが単一シャードでは完結しないことを体験する

## 動作環境

- Docker（PostgreSQL 17 公式イメージを使用）
- ターミナル

## セットアップ

```bash
bash setup.sh
```

## 手動で接続する場合

```bash
# パブリッシャー（レプリケーション元）
docker exec -it db-history-ep11-pub psql -U postgres -d handson

# サブスクライバー（レプリケーション先）
docker exec -it db-history-ep11-sub psql -U postgres -d handson

# シャード0（偶数user_id）
docker exec -it db-history-ep11-shard0 psql -U postgres -d handson

# シャード1（奇数user_id）
docker exec -it db-history-ep11-shard1 psql -U postgres -d handson
```

## 後片付け

```bash
docker rm -f db-history-ep11-pub db-history-ep11-sub \
    db-history-ep11-shard0 db-history-ep11-shard1
docker network rm db-history-ep11-net 2>/dev/null || true
```
