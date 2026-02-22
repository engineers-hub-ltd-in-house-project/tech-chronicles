# 第18回ハンズオン：fishの世界を体験する

## 概要

fish（friendly interactive shell）の対話的機能とPOSIX非互換の構文を、bashとの比較を通じて体験する。構文ハイライト、オートサジェスチョン、ワード分割の違い、Universal Variablesなど、fishの設計思想を実感するための演習集。

## 演習一覧

| 演習  | テーマ               | 学べること                                 |
| ----- | -------------------- | ------------------------------------------ |
| 演習1 | fishの対話的機能     | 構文ハイライトとオートサジェスチョンの体験 |
| 演習2 | bashとfishの構文比較 | 変数代入、制御構造、コマンド置換の違い     |
| 演習3 | ワード分割の違い     | fishがワード分割を廃止した設計判断の意味   |
| 演習4 | Universal Variables  | セッション間の変数共有と永続化             |
| 演習5 | 起動速度の比較       | fish / bash / dashの起動パフォーマンス     |

## 動作環境

- Docker環境（ubuntu:24.04）を推奨
- または apt-get が使えるLinux環境

## 使い方

```bash
# Docker環境で実行する場合
docker run -it ubuntu:24.04 /bin/bash
bash setup.sh

# ローカル環境で実行する場合
bash setup.sh
```

## ライセンス

MIT
