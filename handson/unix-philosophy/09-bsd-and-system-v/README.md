# 第9回ハンズオン：BSDとSystem Vの差異を体験する

## 概要

BSDとSystem Vの分裂がUNIXの設計にどのような痕跡を残しているかを、Linux環境で実際に確認する。psコマンドの二重構文、System V IPC、シグナル処理の違い、ネットワークコマンドの系譜、initシステムの遺産を体験する。

## 演習一覧

| 演習  | 内容                              | 学べること                                          |
| ----- | --------------------------------- | --------------------------------------------------- |
| 演習1 | psコマンドのBSD構文とSystem V構文 | `ps aux` と `ps -ef` の出力カラムの違いと歴史的背景 |
| 演習2 | System V IPCの作成と確認          | 共有メモリ、メッセージキュー、セマフォの操作        |
| 演習3 | シグナル処理の違い                | reliable signalsとunreliable signalsの挙動の差      |
| 演習4 | ネットワーキングコマンドの系譜    | BSD由来コマンドと現代のiproute2コマンドの比較       |
| 演習5 | initシステムの痕跡                | SysV initからsystemdへの移行の痕跡                  |
| 演習6 | BSD由来とSystem V由来の機能の識別 | Linuxにおける両系統の技術の共存を確認               |

## 動作環境

- Docker + ubuntu:24.04 イメージ
- 追加パッケージ: procps, iproute2, net-tools, sysvinit-utils

## セットアップ

```bash
bash setup.sh
```

## ライセンス

MIT
