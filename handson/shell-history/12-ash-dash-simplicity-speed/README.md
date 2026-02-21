# 第12回ハンズオン: ash/dash――POSIX原理主義と単純さの速度

## 概要

dashとbashの速度差を実際に計測し、機能を削ぎ落とすことの技術的価値を体験するハンズオン。バイナリサイズ比較、起動速度ベンチマーク、スクリプト実行速度の計測を行い、Alpine Linux（BusyBox ash）でPOSIX準拠スクリプトの動作を確認する。Dockerイメージサイズの比較も実施する。

## 演習一覧

| 演習  | 内容                                                 |
| ----- | ---------------------------------------------------- |
| 演習1 | バイナリサイズと依存ライブラリの比較                 |
| 演習2 | 起動速度のベンチマーク（1,000回起動）                |
| 演習3 | スクリプト実行速度の比較                             |
| 演習4 | Alpine Linux（BusyBox ash）でPOSIX準拠スクリプト実行 |
| 演習5 | Dockerイメージサイズの実測比較                       |

## 動作環境

- Docker（推奨）
- ベースイメージ: `ubuntu:24.04`（bash + dash）および `alpine:3.21`（BusyBox ash）
- Dockerイメージ比較用: `busybox:latest`, `debian:bookworm-slim`

## セットアップ

```bash
bash setup.sh
```

## ライセンス

MIT
