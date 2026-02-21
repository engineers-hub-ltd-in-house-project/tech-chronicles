# 第15回ハンズオン：Plan 9の夢――UNIXの先にあったもの

## 概要

Plan 9 from Bell Labsの設計思想が現代のLinuxにどのような影響を与えているかを、実際のコマンド操作を通じて体験する。Plan 9のOSそのものをインストールするのではなく、Linux上でPlan 9由来の技術（/proc、UTF-8、namespaces、9P）を確認・検証する。

## 演習一覧

| 演習  | 内容                                     | 所要時間 |
| ----- | ---------------------------------------- | -------- |
| 演習1 | LinuxにおけるPlan 9の痕跡を確認する      | 5分      |
| 演習2 | UTF-8の設計原則を体感する                | 10分     |
| 演習3 | 9Pプロトコルの概念をLinuxで確認する      | 10分     |
| 演習4 | Linux namespacesとPlan 9の関係を理解する | 10分     |

## 動作環境

- Docker（ubuntu:24.04イメージ）
- または Ubuntu 24.04 以降のLinux環境

## セットアップ

```bash
# 自動セットアップ
bash setup.sh

# または手動でDocker環境を起動
docker run -it --rm ubuntu:24.04 bash
```

## 関連する連載記事

- [第15回：Plan 9の夢――UNIXの先にあったもの](../../../series/command-line/ja/15-plan9-dream.md)

## ライセンス

MIT
