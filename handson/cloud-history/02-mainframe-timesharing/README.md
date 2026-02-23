# ハンズオン：タイムシェアリングの原理を体感する

## 概要

1960年代にメインフレームで実現されたタイムシェアリングの原理を、Linuxのプロセススケジューリングを通じて体感する。CPUタイムスライスの分配、Noisy Neighbor問題、コンテキストスイッチのオーバーヘッドを実際に観察し、クラウドの設計思想の根源を理解する。

## 演習一覧

| 演習  | 内容                                 | 学べること                             |
| ----- | ------------------------------------ | -------------------------------------- |
| 演習1 | カーネルのスケジューラ設定を確認する | CPUタイムスライスの概念                |
| 演習2 | 複数プロセスのCPU時間分配を観察する  | 公平なスケジューリング（CFS）          |
| 演習3 | Noisy Neighbor問題を再現する         | 計算資源共有のコスト                   |
| 演習4 | コンテキストスイッチを計測する       | タイムシェアリングの「見えないコスト」 |

## 動作環境

- Docker（Docker Desktop または Docker Engine）
- ベースイメージ: `ubuntu:24.04`
- 必要な権限: `--privileged`（`/proc/sys` へのアクセスに必要）

## セットアップ

```bash
# 自動セットアップスクリプトの実行
bash setup.sh
```

または手動で以下を実行:

```bash
docker run -it --rm --privileged ubuntu:24.04 bash
apt-get update && apt-get install -y procps stress-ng util-linux time sysstat
```

## 関連する連載記事

- [第2回：メインフレームとタイムシェアリング——計算資源を共有した最初の時代](../../../series/cloud-history/ja/02-mainframe-timesharing.md)

## ライセンス

MIT License
