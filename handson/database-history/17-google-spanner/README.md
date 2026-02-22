# 第17回ハンズオン：Cloud Spannerエミュレータで分散トランザクションを体験する

## 概要

Google Cloud Spannerエミュレータを使い、分散トランザクションの動作を体験する。エミュレータはローカルで動作するインメモリのSpanner互換環境であり、Google Cloudアカウントは不要である。

## 演習一覧

| 演習  | 内容                             | 学べること                               |
| ----- | -------------------------------- | ---------------------------------------- |
| 演習1 | スキーマ作成とデータ投入         | SpannerのDDL構文、主キー設計             |
| 演習2 | 分散トランザクション（送金処理） | 強一貫性のトランザクション、自動リトライ |
| 演習3 | 読み取りモードの比較             | Strong Read、Stale Read、読み取り専用TX  |

## 動作環境

- Docker（Docker Composeは不要）
- Python 3.10以上
- pip（google-cloud-spannerライブラリのインストールに使用）

## 使い方

```bash
bash setup.sh
```

## 後片付け

```bash
docker rm -f db-history-ep17-spanner 2>/dev/null || true
```
