# 第14回ハンズオン：GNU coreutils――自由なUNIXツール群の再実装

## 概要

GNU coreutilsの実態を理解し、GNUツールとBSDツールの差異を体験するハンズオン。
あなたが毎日使っている`ls`や`cat`がGNUプロジェクトによる再実装であることを確認し、
POSIX標準とGNU拡張の境界を実践的に学ぶ。

## 演習一覧

| 演習 | 内容                                                 |
| ---- | ---------------------------------------------------- |
| 1    | GNU coreutilsのバージョン確認と--helpの統一性        |
| 2    | GNU拡張（long options、--color、負の行数指定）の実例 |
| 3    | POSIXポータブルなスクリプトの書き方                  |

## 動作環境

- Docker（ubuntu:24.04イメージ）
- または任意のGNU/Linux環境

## セットアップ

```bash
bash setup.sh
```

## 学べること

- GNU coreutilsの出自を--versionで確認する方法
- --helpがすべてのGNUツールで統一されている事実
- long options（--human-readable等）の自己文書化効果
- POSIXLY_CORRECT環境変数によるPOSIX互換モードの検証
- GNU sedとBSD sedの-iオプション差異への対処法
- クロスプラットフォームシェルスクリプトの実践テクニック

## ライセンス

MIT
