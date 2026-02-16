# 第20回ハンズオン：簡易GitOpsパイプラインを構築する

## 概要

GitOpsの中核概念であるReconciliation Loop（リコンシリエーションループ）を、シェルスクリプトで再現する。Gitリポジトリに定義された「望ましい状態」と「実際の状態」を比較し、差異があれば自動的に修正する仕組みを構築することで、Flux CDやArgoCDが内部で行っていることの本質を体験する。

## 演習一覧

| 演習  | 内容                            | 学べること                                 |
| ----- | ------------------------------- | ------------------------------------------ |
| 演習1 | 宣言的な状態定義とGitリポジトリ | GitOpsにおけるSingle Source of Truthの概念 |
| 演習2 | Reconciliation Loopの実装       | Observe/Diff/Actの3ステップ                |
| 演習3 | git commitによるデプロイ        | gitの操作がインフラ操作と等価になる仕組み  |
| 演習4 | git revertによるロールバック    | gitの標準操作によるロールバックと監査証跡  |
| 演習5 | ドリフト検知と自動修復          | GitOpsの自己修復（Self-Healing）特性       |

## 動作環境

- Docker（推奨）: `ubuntu:24.04`
- 必要なツール: `git`, `jq`

```bash
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y git jq
```

## 実行方法

```bash
bash setup.sh
```

## ライセンス

MIT
