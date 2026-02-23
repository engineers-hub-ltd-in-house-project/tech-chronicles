# 第8回ハンズオン：小さなツールの組み合わせ——合成可能性の設計

## 概要

合成可能性（composability）の四条件——stdin/stdout/stderr、テキスト行指向、終了コード、副作用の最小化——を実際に確認し、合成可能なCLIツールを設計・実装してパイプラインに組み込む。

## 演習一覧

| 演習  | 内容                                             | 使用ツール              |
| ----- | ------------------------------------------------ | ----------------------- |
| 演習1 | 合成可能性の四条件を確認する                     | cat, grep, awk, sort    |
| 演習2 | 合成可能なフィルタをシェル関数で作る             | シェル関数, awk, sed    |
| 演習3 | 終了コードの活用                                 | set -e, pipefail        |
| 演習4 | stderrの正しい使い方                             | リダイレクト            |
| 演習5 | シェルの接続パターン（プロセス置換、xargs、tee） | diff, xargs, tee        |
| 演習6 | 合成可能なツールの実践的な組み立て               | awk, sort, uniq, パイプ |

## 動作環境

- Docker（ubuntu:24.04イメージ）
- 追加パッケージ: coreutils, gawk

## セットアップ

```bash
bash setup.sh
```

または手動で:

```bash
docker run -it --rm ubuntu:24.04 bash
apt-get update && apt-get install -y coreutils gawk
```

## ライセンス

MIT
