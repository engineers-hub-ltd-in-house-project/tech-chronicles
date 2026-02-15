# Handson -- ハンズオン演習環境

各連載記事のハンズオンセクションで使用するスクリプト・設定ファイルを格納する。

## ディレクトリ構成

```
handson/
├── README.md
└── version-control/
    ├── 01-manual-vcs/        # 第1回：gitなしでバージョン管理
    ├── 02-diff-patch/        # 第2回：diff/patchの深掘り（予定）
    ├── 03-rcs/               # 第3回：RCSを体験する（予定）
    └── ...
```

## 実行環境

すべてのハンズオンは以下の環境で動作確認済み。

- **推奨**: Docker（Ubuntu 24.04ベース）
- **代替**: Linux（Ubuntu/Debian）、macOS、WSL2

```bash
# Docker環境の起動
docker run -it --rm ubuntu:24.04 bash
```

## ライセンス

handson/ 配下のコードは MIT License で公開する。
