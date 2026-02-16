# 第15回ハンズオン：Gitオブジェクトモデル——blob, tree, commit, tagの内部を解剖する

## 概要

gitオブジェクトの内部構造をバイナリレベルで検証する。SHA-1ハッシュの手動計算、looseオブジェクトのzlib解凍、annotated tagとlightweight tagの比較、packファイルのデルタ圧縮の確認を通じて、gitの「見えない」部分を「見える」ようにする。

## 演習一覧

| 演習  | 内容                                  | 学べること                                           |
| ----- | ------------------------------------- | ---------------------------------------------------- |
| 演習1 | SHA-1ハッシュを手動で検証する         | ヘッダフォーマット「{type} {size}\0{content}」の理解 |
| 演習2 | looseオブジェクトのzlib圧縮を解凍する | .git/objectsの格納形式、zlibマジックナンバー         |
| 演習3 | annotated tagオブジェクトの解剖       | annotated tag vs lightweight tagの内部構造の違い     |
| 演習4 | packファイルの確認                    | git gc、デルタ圧縮、git verify-packの使い方          |

## 動作環境

- Docker（推奨）: `docker run -it --rm ubuntu:24.04 bash`
- 必要パッケージ: `git`, `python3`, `xxd`
- 手動セットアップ: `bash setup.sh`

## ライセンス

MIT
