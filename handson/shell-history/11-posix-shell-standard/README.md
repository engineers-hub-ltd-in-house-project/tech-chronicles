# 第11回ハンズオン: POSIXシェル標準――誰も読まない契約書

## 概要

POSIX sh標準の「境界線」を体験するハンズオン。bashismsが実際に壊れる様子を確認し、POSIX準拠のスクリプトへの書き換えを実践する。`checkbashisms`とShellCheckによるPOSIX準拠度の自動検証も体験する。

## 演習一覧

| 演習  | 内容                                 |
| ----- | ------------------------------------ |
| 演習1 | bashismsが壊れる瞬間を体験する       |
| 演習2 | bashismsをPOSIX準拠に書き換える      |
| 演習3 | checkbashismsで自動検出する          |
| 演習4 | ShellCheckでPOSIX準拠度を検証する    |
| 演習5 | 実践的なデプロイスクリプトの書き換え |

## 動作環境

- Docker（推奨）
- ベースイメージ: `alpine:3.21`（BusyBox ash）および `ubuntu:24.04`（bash + dash）
- 追加パッケージ: `bash`, `shellcheck`, `devscripts`（Ubuntu環境のみ）

## セットアップ

```bash
bash setup.sh
```

## ライセンス

MIT
