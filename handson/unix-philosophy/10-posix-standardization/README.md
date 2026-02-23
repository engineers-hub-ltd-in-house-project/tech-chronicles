# 第10回ハンズオン：POSIXシェルスクリプトの互換性を検証する

## 概要

POSIXシェルスクリプト（bash拡張を使わない）を書き、複数のシェル環境（bash、dash、BusyBox ash、zsh、mksh）で動作することを確認する。「POSIX準拠」の意味と限界を体験的に理解する。

## 学べること

- bash依存スクリプトがPOSIXシェルで動かない具体例
- bash拡張をPOSIX準拠の構文に書き換える方法
- POSIXユーティリティ（grep、awk、sed、sort、uniq）の互換性
- `echo` vs `printf` の非互換性問題
- 実用的なPOSIX準拠ログ解析スクリプトの実装

## 演習一覧

| 演習 | 内容                                      |
| ---- | ----------------------------------------- |
| 1    | bash依存スクリプト vs POSIX準拠スクリプト |
| 2    | POSIX準拠スクリプトの書き方               |
| 3    | POSIXユーティリティの互換性               |
| 4    | echo vs printf の落とし穴                 |
| 5    | POSIXシェルでの実用的なログ解析           |

## 動作環境

- Docker（ubuntu:24.04イメージ）
- 追加パッケージ: dash, busybox, zsh, ksh, mksh

## セットアップ

```bash
bash setup.sh
```

## ライセンス

MIT
