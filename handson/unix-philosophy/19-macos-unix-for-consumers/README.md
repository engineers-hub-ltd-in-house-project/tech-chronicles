# 第19回ハンズオン：macOSのUNIX層を探索する

## 概要

macOSの下で動いているUNIXの実体を確認するハンズオン。XNUカーネルの構造、BSDコマンドとGNUコマンドの差異、launchdとsystemdの設計比較、アーキテクチャ移行の仕組みを体験する。

## 演習一覧

| 演習  | 内容                                        | 環境                  |
| ----- | ------------------------------------------- | --------------------- |
| 演習1 | macOSのDarwin層を確認する                   | macOS（Terminal.app） |
| 演習2 | BSDコマンドとGNUコマンドの差異を体験する    | Docker (ubuntu:24.04) |
| 演習3 | XNUカーネルの構造をソースコードから確認する | Docker (ubuntu:24.04) |
| 演習4 | launchdとsystemdの設定比較                  | Docker (ubuntu:24.04) |
| 演習5 | macOSのアーキテクチャ移行とカーネルの中立性 | Docker (ubuntu:24.04) |

## 学べること

- macOSがUNIX 03認証を持つ正式なUNIXであることの確認方法
- XNUカーネルの三層構造（Mach + BSD + IOKit）の役割分担
- BSD版コマンドとGNU版コマンドのオプション差異と移植可能なスクリプトの書き方
- launchdの設計思想とsystemdとの比較
- Apple Siliconへの移行を支えたアーキテクチャ中立性の設計

## 動作環境

- macOS環境（演習1はmacOS専用）
- Docker Desktop（演習2〜5はubuntu:24.04コンテナで実行）
- 特権モード不要（演習2〜5）

## セットアップ

```bash
# 自動セットアップ
bash setup.sh

# または手動でDockerイメージを取得
docker pull ubuntu:24.04
```

## ライセンス

MIT
