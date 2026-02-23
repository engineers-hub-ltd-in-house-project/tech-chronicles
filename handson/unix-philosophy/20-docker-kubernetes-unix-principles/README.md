# 第20回ハンズオン：Dockerなしでコンテナを手動構築する

## 概要

Linux カーネルの namespaces と cgroups を直接操作し、Docker を使わずに「コンテナ」を手動構築する。コンテナの本質が「隔離されたプロセス」であることを自分の手で確認する演習。

## 演習一覧

| 演習 | 内容                           | 学べること                               |
| ---- | ------------------------------ | ---------------------------------------- |
| 1    | namespaces によるプロセス隔離  | UTS/PID/Mount namespace の動作原理       |
| 2    | cgroups によるリソース制限     | メモリ制限の仕組みと /sys/fs/cgroup 操作 |
| 3    | ファイルシステム隔離の手動構築 | chroot + namespace の組み合わせ          |
| 4    | コンテナの「層」を可視化       | /proc/self/ns と cgroup 情報の読み取り   |

## 動作環境

- Docker がインストールされた Linux/macOS/Windows（WSL2）環境
- ベースイメージ: `ubuntu:24.04`
- 特権モード（`--privileged`）でコンテナを起動する必要がある

## セットアップ

```bash
bash setup.sh
```

## 注意事項

- 演習は Docker コンテナ内で実行するため、ホスト環境に影響はない
- `--privileged` フラグは namespace/cgroup 操作に必要な権限を付与する
- 本番環境では `--privileged` の使用は推奨されない（演習目的に限定）

## ライセンス

MIT
