# 第19回ハンズオン：シェル初期化ファイルの実験とdotfiles管理

## 概要

シェルの初期化ファイルの読み込み順序を実験で確認し、dotfiles管理ツール（GNU Stow）とクロスシェルプロンプト（Starship）を実際に体験する。

## 演習一覧

| 演習  | 内容                             | 学べること                                                         |
| ----- | -------------------------------- | ------------------------------------------------------------------ |
| 演習1 | bash初期化ファイルの読み込み順序 | login shell / non-login shellでの`.bash_profile`/`.bashrc`の挙動差 |
| 演習2 | zshの5段階初期化ファイル         | `.zshenv`→`.zprofile`→`.zshrc`→`.zlogin`の読み込み順序             |
| 演習3 | login shell判定の確認            | bashとzshでのlogin shell判定方法                                   |
| 演習4 | GNU Stowによるdotfiles管理       | シンボリックリンクファームマネージャの基本操作                     |
| 演習5 | Starshipプロンプトの体験         | クロスシェルプロンプトの設定と動作                                 |

## 動作環境

- Docker環境（ubuntu:24.04）またはapt-getが使えるLinux環境
- 必要なパッケージ: bash, zsh, stow, curl（setup.shで自動インストール）

## 使い方

```bash
# Docker環境の場合
docker run -it ubuntu:24.04 /bin/bash
# コンテナ内で
bash setup.sh

# ローカル環境の場合
bash setup.sh
```

## ライセンス

MIT
