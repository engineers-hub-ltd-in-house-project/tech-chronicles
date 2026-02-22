# 第16回ハンズオン：時系列DB, グラフDB——専門特化の進化

## 概要

PostgreSQL（再帰CTE）とNeo4j（Cypher）で「友達の友達」検索を比較し、グラフデータベースの表現力を体験する。さらにTimescaleDBで時系列データの集約クエリを実行し、専門特化型データベースの威力を確認する。

## 学べること

- RDBでのグラフ探索（JOINと再帰CTE）の限界
- Neo4jのCypherクエリによるパターンマッチングの直感性
- TimescaleDBのハイパーテーブルと時間バケット集約
- 連続集約（Continuous Aggregate）による高速な時系列集計

## 演習一覧

| 演習  | 内容                                             |
| ----- | ------------------------------------------------ |
| 演習1 | PostgreSQLで「友達の友達」検索（JOIN + 再帰CTE） |
| 演習2 | Neo4jで「友達の友達」検索（Cypher）              |
| 演習3 | TimescaleDBで時系列データの集約クエリ            |

## 動作環境

- Docker（PostgreSQL 17 + TimescaleDB拡張 + Neo4j 5 公式イメージを使用）
- メモリ: 2GB以上推奨

## 使い方

```bash
bash setup.sh
```

## 後片付け

```bash
docker rm -f db-history-ep16-postgres db-history-ep16-neo4j
docker network rm db-history-ep16-net 2>/dev/null || true
```
