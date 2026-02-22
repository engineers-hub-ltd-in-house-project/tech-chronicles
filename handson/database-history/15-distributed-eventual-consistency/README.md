# 第15回ハンズオン：Cassandra, DynamoDB——分散と結果整合性の世界

## 概要

Cassandraの3ノードクラスタとDynamoDB Localを使い、分散データベースにおける一貫性レベルの違いとクエリファーストのデータモデリングを体験する。

## 学べること

- Cassandraのマスタレスクラスタの構築と運用
- 一貫性レベル（ONE, QUORUM, ALL）の挙動の違い
- ノード障害時の一貫性レベルによる影響
- DynamoDBのパーティションキー/ソートキー設計
- シングルテーブル設計パターン

## 演習一覧

| 演習  | 内容                                   |
| ----- | -------------------------------------- |
| 演習1 | Cassandraクラスタの構築と状態確認      |
| 演習2 | 一貫性レベルの比較（ONE, QUORUM, ALL） |
| 演習3 | ノード障害時の挙動の違い               |
| 演習4 | DynamoDB Localでシングルテーブル設計   |

## 動作環境

- Docker（Cassandra 5.0 + DynamoDB Local 公式イメージを使用）
- メモリ: 4GB以上推奨（Cassandra 3ノード構成のため）
- ディスク: 5GB以上の空き容量

## 使い方

```bash
bash setup.sh
```

## 後片付け

```bash
docker rm -f db-history-ep15-cass1 db-history-ep15-cass2 db-history-ep15-cass3 db-history-ep15-dynamodb
docker network rm db-history-ep15-net 2>/dev/null || true
```
