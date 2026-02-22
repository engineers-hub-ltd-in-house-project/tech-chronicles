# 第1回ハンズオン：テキストファイルでデータベースを「再発明」する

**対応記事**: [第1回「なぜデータベースの歴史を学ぶのか」](../../../series/database-history/ja/01-why-database-history.md)

## 概要

テキストファイル（CSV）とPythonスクリプトだけで簡易CRUDシステムを構築し、データベースが解決する根本問題を体験する。並行アクセスでデータが壊れる瞬間を観察し、データベースの存在意義を身体で理解する。

## 実行方法

```bash
# セットアップスクリプトの実行
bash setup.sh
```

または記事のハンズオンセクションに記載されたコマンドを順番に実行する。

## 学べること

1. CSVファイルによる基本的なCRUD操作の実装
2. シーケンシャルスキャンによる検索性能の限界
3. 並行アクセスによるデータ破壊（競合状態 / Race Condition）
4. Lost Update問題の観察
5. ファイルベースのデータ管理の根本的限界

## 動作環境

- Docker（`ubuntu:24.04` 推奨）
- Python 3（Ubuntu 24.04に標準搭載）

```bash
docker run -it --rm ubuntu:24.04 bash
apt-get update && apt-get install -y python3
```
