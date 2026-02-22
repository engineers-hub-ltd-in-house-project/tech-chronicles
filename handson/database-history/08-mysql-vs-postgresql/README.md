# 第8回ハンズオン：MySQLとPostgreSQLの特性を比較する

## 概要

MySQLとPostgreSQLに同じスキーマ・同じデータを用意し、型の扱い、外部キー制約の挙動、ワークロード特性の違いを体験する。「手軽さ vs 正しさ」という設計判断の違いを実感する演習である。

## 演習一覧

1. **型の厳密性の違い** — 暗黙の型変換、不正な日付の扱いを比較する
2. **外部キー制約の挙動** — 存在しない外部キーへのINSERTの結果を比較する
3. **ワークロード特性の比較** — 読み取り・書き込みベンチマークで性能特性の違いを観察する

## 動作環境

- Docker（MySQL 8.0 および PostgreSQL 17 公式イメージを使用）
- ターミナルを2つ以上同時に開ける環境

## セットアップ

```bash
bash setup.sh
```

## 手動で接続する場合

```bash
# MySQL
docker exec -it db-history-ep08-mysql mysql -u root -phandson handson

# PostgreSQL
docker exec -it db-history-ep08-pg psql -U postgres -d handson
```

## 後片付け

```bash
docker rm -f db-history-ep08-mysql db-history-ep08-pg
```
