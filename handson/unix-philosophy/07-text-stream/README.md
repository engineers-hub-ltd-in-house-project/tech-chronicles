# 第7回ハンズオン：テキストストリーム——万能インタフェースとしてのテキスト

## 概要

UNIXのテキスト処理ツール群——sed、awk、grep——を使ったパイプラインと、jqによるJSON処理を実践する。テキストストリームが「万能インタフェース」として機能する仕組みと、その限界を手で確かめる。

## 演習一覧

| 演習  | 内容                                    | 使用ツール    |
| ----- | --------------------------------------- | ------------- |
| 演習1 | sedによるテキストストリームの変換       | sed           |
| 演習2 | awkによるテキストデータの集計           | awk           |
| 演習3 | 正規表現によるパターンマッチ（BRE/ERE） | grep, sed     |
| 演習4 | jqによるJSON処理                        | jq            |
| 演習5 | テキストストリームとJSONの橋渡し        | jq, awk, sort |

## 動作環境

- Docker（ubuntu:24.04イメージ）
- 追加パッケージ: jq, curl, gawk

## セットアップ

```bash
bash setup.sh
```

または手動で:

```bash
docker run -it --rm ubuntu:24.04 bash
apt-get update && apt-get install -y jq curl gawk
```

## ライセンス

MIT
