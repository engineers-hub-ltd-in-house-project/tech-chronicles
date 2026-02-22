# 第13回ハンズオン：Memcached, Redis——キャッシュ層という発明

## 概要

Redisのデータ構造（Sorted Set、HyperLogLog）を活用した実用パターンを実装し、
キャッシュの不整合を意図的に発生させて解消する。

## 演習一覧

| 演習  | 内容                                        | 学べること                       |
| ----- | ------------------------------------------- | -------------------------------- |
| 演習1 | Sorted Setによるリアルタイムランキング      | Redisのデータ構造の威力          |
| 演習2 | HyperLogLogによるユニークビジター推定       | 確率的データ構造のメモリ効率     |
| 演習3 | Cache Asideパターンとキャッシュ不整合の体験 | キャッシュ戦略のトレードオフ     |
| 演習4 | Thundering Herdのシミュレーションと対策     | Request Coalescingによる障害対策 |

## 動作環境

- Docker（Redis 7 公式イメージ + PostgreSQL 17 公式イメージを使用）
- bash

## セットアップ

```bash
bash setup.sh
```

## 後片付け

```bash
docker rm -f db-history-ep13-redis db-history-ep13-postgres
docker network rm db-history-ep13-net 2>/dev/null || true
```

## ライセンス

MIT
