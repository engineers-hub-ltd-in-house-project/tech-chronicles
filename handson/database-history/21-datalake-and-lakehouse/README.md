# 第21回ハンズオン：DuckDBでParquetファイルを分析する

## 概要

DuckDBを使って列指向ストレージ（Parquet）の分析性能を体験する。行指向DB（PostgreSQL）との速度差を実測し、列指向フォーマットの利点を理解する。

## 学べること

- CSV vs Parquet のファイルサイズと圧縮効率の違い
- 行指向DB（PostgreSQL）と列指向エンジン（DuckDB）の集計性能差
- DuckDBによるファイルへの即時クエリ（テーブルへのロード不要）
- Parquetファイルの列指向構造がもたらす性能向上
- DuckDBの高度なSQL機能（ウィンドウ関数、PIVOT）

## 演習一覧

| 演習   | 内容                                        |
| ------ | ------------------------------------------- |
| 演習 1 | 100万行のテストデータをCSVとParquetで生成   |
| 演習 2 | PostgreSQLでの集計クエリ（行指向）          |
| 演習 3 | DuckDBでの集計クエリ（列指向、CSV/Parquet） |
| 演習 4 | DuckDBの高度なSQL（ウィンドウ関数、PIVOT）  |

## 動作環境

- Docker（PostgreSQL 17、Python 3.12）
- DuckDB（Pythonパッケージとして自動インストール）
- メモリ: 2GB以上推奨
- ディスク: 500MB以上の空き容量

## セットアップ

```bash
bash setup.sh
```

## 後片付け

```bash
docker stop pg-handson 2>/dev/null && docker rm pg-handson 2>/dev/null
rm -f sales.csv sales.parquet
```
