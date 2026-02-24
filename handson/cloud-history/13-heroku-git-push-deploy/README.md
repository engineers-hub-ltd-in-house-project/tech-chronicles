# ハンズオン：PaaSの処理フローを手動で再現する

**クラウドの考古学 第13回「Heroku——『git pushでデプロイ』が変えたもの」対応**

## 概要

PaaSが `git push` の裏側で行っている処理を手動で一つずつ再現し、Buildpack・Procfile・Twelve-Factor Appの概念を体験する。

## 演習一覧

| # | 演習内容                      | 学べること                                     |
| - | ----------------------------- | ---------------------------------------------- |
| 1 | PaaSの処理フローを手動で再現  | 言語検出・依存解決・スラグ生成の仕組み         |
| 2 | PaaSのビルドフェーズを再現    | Buildpackの3フェーズ（Detect/Compile/Release） |
| 3 | Twelve-Factor Appの原則を体験 | Config、Processes、Disposabilityの実践         |
| 4 | PaaSの制約を体験              | 揮発性FS、リソース制限、可視性の喪失           |

## 動作環境

- Docker（Ubuntu 24.04ベースコンテナ）

## セットアップ

```bash
bash setup.sh
```

## 注意事項

- この演習はDokkuの完全なインストールは行わない（systemdが必要なため）
- PaaSの処理フローを手動で再現することで、抽象化の裏側を理解することが目的
- Python 3とFlaskを使用するが、他の言語でも同様の概念が適用される

## ライセンス

MIT
