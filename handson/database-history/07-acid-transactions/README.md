# 第7回ハンズオン：トランザクション分離レベルとデッドロックを体験する

## 概要

PostgreSQLでトランザクション分離レベルの違いを観察し、デッドロックを意図的に発生させる。ACIDの「I（Isolation）」が実際にどう機能するかを体感する演習である。

## 演習一覧

1. **READ COMMITTEDの挙動** — Non-Repeatable Readの発生を観察する
2. **REPEATABLE READによる防止** — Snapshot Isolationがスナップショットを維持する様子を確認する
3. **REPEATABLE READでの更新競合** — First-Committer-Winsの挙動を体験する
4. **デッドロックの発生と解消** — 意図的にデッドロックを起こし、PostgreSQLの検出と解消を観察する

## 動作環境

- Docker（PostgreSQL 17 公式イメージを使用）
- ターミナルを2つ以上同時に開ける環境

## セットアップ

```bash
bash setup.sh
```

## 手動で接続する場合

```bash
docker exec -it db-history-ep07-pg psql -U postgres -d handson
```

## 後片付け

```bash
docker rm -f db-history-ep07-pg
```
