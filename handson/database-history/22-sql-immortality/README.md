# 第22回ハンズオン: モダンSQLの力を体験する

## 概要

SQLが50年間生き残った理由の一つは、言語としての表現力が進化し続けていることにある。このハンズオンでは、SQL:1999以降に追加されたモダンSQL機能を実際に手を動かして体験する。

## 学べること

- **ウィンドウ関数**（SQL:2003）: GROUP BYでは不可能な「集計結果と個別行の共存」
- **再帰CTE**（SQL:1999）: 階層構造データの走査をSQLだけで実現
- **JSONB操作**: 半構造化データのクエリをリレーショナルDBで完結させる
- **複合クエリ**: 複数のモダンSQL機能を組み合わせた実践的なレポート生成

## 演習一覧

| # | 演習内容                       | 使用するSQL機能                            |
| - | ------------------------------ | ------------------------------------------ |
| 1 | テストデータの準備             | CREATE TABLE, INSERT                       |
| 2 | 部署別給与ランキングと移動平均 | RANK(), OVER(), PARTITION BY, ROWS BETWEEN |
| 3 | 組織の階層構造の走査           | WITH RECURSIVE, CTE                        |
| 4 | JSONBデータの検索と集約        | ->>, ->, @>, jsonb_array_elements_text()   |
| 5 | 複合クエリによる分析レポート   | CTE + ウィンドウ関数 + CASE式              |

## 動作環境

- Docker（Docker Engine 20.10以上）
- bash（macOS/Linux/WSL2）

外部サービスへの登録は不要。すべてローカルのDockerコンテナで完結する。

## セットアップ

```bash
bash setup.sh
```

## 後片付け

```bash
docker stop pg-modern-sql && docker rm pg-modern-sql
```

## ライセンス

MIT
