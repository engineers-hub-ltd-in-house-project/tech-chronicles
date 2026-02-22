# 第20回ハンズオン：コンテナ時代のシェル――Docker, CI/CD, そして/bin/sh問題

## 概要

Docker環境で「シェルの違い」が引き起こす問題を実際に体験するハンズオン。
Alpine（ash）、Debian（bash/dash）、scratch（シェルなし）の環境差、
Dockerfileのshell form vs exec formの挙動差、PID 1問題によるシグナルハンドリングの違い、
そしてCI/CDパイプラインを意識したPOSIX準拠スクリプトへの書き換えを実践する。

## 演習一覧

| # | テーマ                          | 内容                                                                          |
| - | ------------------------------- | ----------------------------------------------------------------------------- |
| 1 | シェル環境の確認                | Alpine/Debianで`/bin/sh`の実体を確認し、bash拡張の互換性を検証                |
| 2 | shell form vs exec form         | DockerのCMD/ENTRYPOINTの2形式がPID 1とプロセスツリーに与える影響を確認        |
| 3 | PID 1とシグナルハンドリング     | shell formとexec formで`docker stop`のgraceful shutdown挙動が異なることを実証 |
| 4 | POSIX準拠スクリプトへの書き換え | bash依存スクリプトをPOSIX sh互換に書き換える実践演習                          |
| 5 | マルチステージビルドとシェル    | ビルドステージでbashを使い、実行ステージでシェルを排除するDockerfileの構築    |

## 動作環境

- Docker Engine 20.10以降
- OS: Linux, macOS, WSL2
- ディスク: 約500MB（Dockerイメージのダウンロード分）

## 使い方

```bash
# Docker環境で実行（推奨）
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock \
  docker:cli sh -c "apk add --no-cache bash && bash"

# またはホストのDocker環境で直接実行
bash setup.sh
```

## ライセンス

MIT
