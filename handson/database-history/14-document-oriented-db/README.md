# 第14回ハンズオン：MongoDB, CouchDB——ドキュメント指向の挑戦

## 概要

同じECサイトのデータモデルをPostgreSQL（正規化リレーショナル）とMongoDB（非正規化ドキュメント）で実装し、
CRUD操作の違いと各モデルの得手不得手を体験する。

## 演習一覧

| 演習  | 内容                                     | 学べること                     |
| ----- | ---------------------------------------- | ------------------------------ |
| 演習1 | データモデルの比較（正規化 vs 非正規化） | 二つのモデルの構造的な違い     |
| 演習2 | 読み取り操作の比較（JOIN vs 埋め込み）   | 読み取り性能のトレードオフ     |
| 演習3 | 更新操作と一貫性の比較                   | 非正規化による更新異常のリスク |
| 演習4 | Aggregation Pipeline vs SQL集計          | 集計クエリの表現力の違い       |

## 動作環境

- Docker（PostgreSQL 17 + MongoDB 8 公式イメージを使用）
- bash

## セットアップ

```bash
bash setup.sh
```

## 後片付け

```bash
docker rm -f db-history-ep14-postgres db-history-ep14-mongo
docker network rm db-history-ep14-net 2>/dev/null || true
```

## ライセンス

MIT
