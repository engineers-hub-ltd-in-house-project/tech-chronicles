# 第21回ハンズオン：次世代シェルの挑戦――Nushell、Oil/YSH、Elvish、その先へ

## 概要

このハンズオンでは、次世代シェル（Nushell、Oil/YSH）をDocker環境にインストールし、同じタスクをbashと次世代シェルの両方で実装して比較する。テキストストリームと構造化データパイプラインの違いを体感することが目的である。

## 学べること

- Nushellのインストールと基本操作――構造化データパイプラインの体験
- bash + jq vs Nushell――JSON処理の実装比較
- bash + awk vs Nushell――ログ解析の実装比較
- Oil/YSH（Oils）のOSHモードとYSHモード――bash互換性と新言語の共存
- bashからYSHへの段階的書き換え手法

## 演習一覧

| 演習  | 内容                             | 比較対象               |
| ----- | -------------------------------- | ---------------------- |
| 演習1 | JSON処理（サーバ情報の集計）     | bash + jq vs Nushell   |
| 演習2 | ログ解析（エンドポイント別統計） | bash + awk vs Nushell  |
| 演習3 | bash → YSH段階的移行             | OSHモード vs YSHモード |

## 動作環境

- Docker（ubuntu:24.04ベースイメージ）
- インターネット接続（Nushell、Oilsのダウンロードに必要）

## セットアップ

```bash
chmod +x setup.sh
./setup.sh
```

または Docker で直接実行:

```bash
docker run -it --rm -v "$(pwd):/handson" ubuntu:24.04 bash /handson/setup.sh
```

## ライセンス

MIT
