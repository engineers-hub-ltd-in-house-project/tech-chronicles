# 第10回ハンズオン: Korn shell――"全部入り"への最初の挑戦

## 概要

Korn shell（ksh）の機能をmksh（MirBSD Korn Shell）で体験し、bashとの比較を通じてkshがシェルの歴史に残した遺産を理解する。

## 学べること

- kshのコマンドライン編集（emacsモード/viモード）の操作
- kshの算術展開とbashとの共通点
- 拡張グロビングの構文とbashのextglobとの対応
- kshのselect文によるメニューUI
- コプロセスによるプロセス間双方向通信
- print/whenceなどksh固有コマンドとbash対応物の比較

## 動作環境

- Docker（ubuntu:24.04推奨）
- mksh（MirBSD Korn Shell）
- bash（比較用）
- bc（コプロセス演習用）

## セットアップ

```bash
# Docker環境で実行
docker run -it ubuntu:24.04 bash

# コンテナ内で:
apt-get update && apt-get install -y mksh bc

# または setup.sh を使用
bash setup.sh
```

## 演習一覧

| 演習  | 内容                        | 所要時間 |
| ----- | --------------------------- | -------- |
| 演習1 | コマンドライン編集の体験    | 5分      |
| 演習2 | 算術展開の比較              | 5分      |
| 演習3 | 拡張グロビングの比較        | 5分      |
| 演習4 | select文によるメニュー      | 5分      |
| 演習5 | コプロセスの動作確認        | 5分      |
| 演習6 | bash vs mksh 構文差異の確認 | 10分     |

## ライセンス

MIT
