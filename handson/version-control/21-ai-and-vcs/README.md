# 第21回ハンズオン：AI支援開発のワークフローをgitで追跡可能にする

## 概要

AI支援開発におけるコードの帰属情報をgitで追跡可能にする仕組みを構築する。Co-authored-byトレーラーの基本から、カスタムトレーラーによるメタデータの記録、git logを使った解析、commit-msg hookによるトレーラーの自動検証までを体験する。

## 演習一覧

| 演習  | 内容                                       | 学べること                                             |
| ----- | ------------------------------------------ | ------------------------------------------------------ |
| 演習1 | gitトレーラーの基本                        | Co-authored-byの仕組みとgit interpret-trailersの使い方 |
| 演習2 | カスタムトレーラーによるAIメタデータの記録 | AI-Tool、AI-Model等のカスタムトレーラーの設計          |
| 演習3 | git logによるAI関与の分析                  | grep機能でAI関与のあるコミットを抽出・集計する方法     |
| 演習4 | git blameとAI帰属の可視化                  | git blameの限界とAI帰属の推定方法                      |
| 演習5 | commit-msg hookによるトレーラーの自動検証  | hook機構でトレーサビリティのルールを強制する方法       |

## 動作環境

- Docker（推奨）: `ubuntu:24.04`
- 必要なツール: `git`

```bash
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y git
```

## 実行方法

```bash
bash setup.sh
```

## ライセンス

MIT
