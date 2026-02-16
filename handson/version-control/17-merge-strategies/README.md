# 第17回ハンズオン：マージの内部を追跡する

## 概要

gitのマージアルゴリズムの内部動作を、意図的にコンフリクトを起こしながら追跡する。
MERGE_HEAD、インデックスのstage番号、cherry-pickの3-way merge動作、merge-baseの共通祖先発見を実際に確認する。

## 演習一覧

| 演習  | 内容                                     | 学べること                                          |
| ----- | ---------------------------------------- | --------------------------------------------------- |
| 演習1 | コンフリクト時の内部状態を観察           | MERGE_HEAD、MERGE_MSG、stage番号、`git ls-files -u` |
| 演習2 | cherry-pickが3-way mergeであることを確認 | cherry-pickの内部動作、base/ours/theirsの対応       |
| 演習3 | merge-baseの動作を確認                   | 共通祖先の発見、マージ後の共通祖先の変化            |
| 演習4 | diff3スタイルのコンフリクト表示          | `merge.conflictStyle diff3`の効果                   |

## 動作環境

- **推奨**: Docker（ubuntu:24.04）
- **必須ツール**: git

```bash
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y git
```

## 実行方法

```bash
bash setup.sh
```

## 関連記事

- [第17回：マージ戦略の深淵——recursive, ort, octopus](../../../series/version-control/ja/17-merge-strategies.md)
