# 第13回ハンズオン：キーボード駆動のGUIパターンを体験する

## 概要

CLIとGUIの融合を体験するハンズオン。fzf（コマンドラインfuzzy finder）を使い、GUIのCommand Paletteと同じ「テキスト入力 + fuzzy matching + リアルタイム絞り込み」パターンをCLIで実現する。dmenu的な「リスト生成 | 絞り込み | 実行」パターンをシェルスクリプトで構築し、CLIの組み合わせ可能性とGUIの発見しやすさの融合を体感する。

## 演習一覧

| 演習  | 内容                          | 学べること                                   |
| ----- | ----------------------------- | -------------------------------------------- |
| 演習1 | fzfによるfuzzy matching       | fuzzy matchingの基本動作と従来の検索との違い |
| 演習2 | fzfとパイプラインの組み合わせ | fzfをUNIXパイプラインの部品として使う手法    |
| 演習3 | dmenuパターンのCLI再現        | シェルスクリプトでCommand Paletteを実装する  |

## 動作環境

- Docker（ubuntu:24.04ベース）推奨
- 必要なツール: fzf, git, curl, bash
- セットアップスクリプトが自動でインストールを行う

## 実行方法

```bash
# Docker環境で実行
docker run -it --rm ubuntu:24.04 bash

# セットアップスクリプトの実行
bash setup.sh
```

## ライセンス

MIT
