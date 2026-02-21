# 第9回ハンズオン：シェルの二つの文化――スクリプティングと対話の乖離

## 概要

bash依存スクリプト（bashisms）の問題を実際に体験し、POSIX準拠スクリプトへの書き換え手法を習得するハンズオンである。`/bin/sh`がdashである環境でbashismsがどう壊れるかを観察し、checkbashismsとShellCheckによる静的解析を実践する。

## 演習一覧

| # | 演習              | 内容                                             |
| - | ----------------- | ------------------------------------------------ |
| 1 | bashismsの観察    | bash依存スクリプトをdashで実行し壊れる様子を確認 |
| 2 | checkbashisms     | Debianのcheckbashismsツールでbashismsを自動検出  |
| 3 | POSIX準拠書き換え | bashismsをPOSIX準拠構文に書き換え                |
| 4 | /bin/shの正体確認 | 現在の環境で/bin/shが何を指すか確認              |
| 5 | 起動速度比較      | dashとbashの起動速度を1000回実行で計測           |
| 6 | ShellCheck活用    | ShellCheckでbashisms検出と--shell=shオプション   |

## 動作環境

- Docker (ubuntu:24.04)
- 必要パッケージ: dash, devscripts, shellcheck

## セットアップ

```bash
bash setup.sh
```

## 学べること

- bashismsの具体例と検出方法
- POSIX準拠スクリプトの書き方
- checkbashismsとShellCheckの使い分け
- dashとbashの起動速度の差異
- /bin/shの実体がディストリビューションごとに異なる事実

## ライセンス

MIT
