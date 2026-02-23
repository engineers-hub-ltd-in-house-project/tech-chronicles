# 第18回ハンズオン：Plan 9の世界を体験する

## 概要

Plan 9 from Bell Labsのアイデアが現代のLinuxにどのように流入しているかを実際に体験する。Linux namespaces（per-process名前空間）、overlayfs（ユニオンマウント）、/procファイルシステム、UTF-8の内部構造を通じて、Plan 9の設計思想の現代的な帰結を理解する。

## 演習一覧

| 演習  | 内容                                                    | 所要時間 |
| ----- | ------------------------------------------------------- | -------- |
| 演習1 | Linux namespacesでPlan 9のper-process名前空間を体験する | 10分     |
| 演習2 | mount namespaceの分離を体験する                         | 10分     |
| 演習3 | 9Pプロトコルの概念をLinux上で確認する                   | 10分     |
| 演習4 | ユニオンマウントの概念をoverlayfsで体験する             | 10分     |
| 演習5 | UTF-8の自己同期性を確認する                             | 10分     |

## 動作環境

- Docker（Ubuntu 24.04イメージ）
- 一部の演習では`--privileged`フラグが必要（namespaceとoverlayfsの操作のため）

## セットアップ

```bash
# 自動セットアップスクリプトを実行
./setup.sh
```

## ライセンス

MIT
