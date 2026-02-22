# 第12回ハンズオン：CAP定理——分散システムの不可能三角形

## 概要

Dockerで構築したPostgreSQLクラスタに対し、意図的にネットワーク分断を発生させ、一貫性（Consistency）と可用性（Availability）のトレードオフを体験する。

## 演習一覧

| 演習 | 内容                                       | 学べること                                           |
| ---- | ------------------------------------------ | ---------------------------------------------------- |
| 1    | 同期レプリケーションでのネットワーク分断   | CP的挙動: 一貫性を保つために書き込みがブロックされる |
| 2    | 非同期レプリケーションでのネットワーク分断 | AP的挙動: 書き込みは成功するがデータが不一致になる   |
| 3    | 分断解消後のデータ収束                     | 結果整合性: 通信回復後にデータが最終的に一致する     |

## 動作環境

- Docker（PostgreSQL 17 公式イメージを使用）
- bash

## セットアップ

```bash
bash setup.sh
```

## 後片付け

```bash
docker rm -f db-history-ep12-primary db-history-ep12-standby-sync \
    db-history-ep12-primary-async db-history-ep12-standby-async
docker network rm db-history-ep12-net 2>/dev/null || true
```
