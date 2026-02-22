# 第22回ハンズオン：PowerShellという異なるパラダイム――オブジェクトパイプラインの世界

## 概要

PowerShellをLinux上にインストールし、オブジェクトパイプラインの動作を体験する。bashのテキストパイプラインとの比較を通じて、「パイプラインを流れるものがオブジェクトである」ことの意味を理解する。

## 学べること

- PowerShellのオブジェクトパイプラインの基本操作
- `Get-Member`によるオブジェクトの型・プロパティの調査
- bash + jq と PowerShellの同一タスク比較（JSON処理）
- `Format-Table`/`Format-List`によるデータと表示の分離
- `Get-Command`によるVerb-Noun命名規則の発見可能性

## 演習一覧

| 演習  | 内容                               | 比較対象              |
| ----- | ---------------------------------- | --------------------- |
| 演習1 | オブジェクトの型とプロパティの確認 | bash には相当機能なし |
| 演習2 | JSON処理（サーバ一覧の集計）       | bash + jq             |
| 演習3 | フォーマッティングレイヤーの体験   | bash のテキスト出力   |
| 演習4 | Verb-Nounの発見可能性              | man -k / apropos      |

## 動作環境

- Docker: ubuntu:24.04 ベースイメージ
- PowerShell: 7.x（Microsoft公式リポジトリからインストール）
- 必要ツール: wget, apt-transport-https, jq（比較用）

## セットアップ

```bash
# Dockerコンテナの起動
docker run -it --rm ubuntu:24.04 bash

# セットアップスクリプトの実行（コンテナ内で）
bash setup.sh
```

## ライセンス

MIT
