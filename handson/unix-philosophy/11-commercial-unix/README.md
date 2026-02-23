# 第11回ハンズオン：商用UNIXの遺産をLinux上で体験する

## 概要

商用UNIXが生み出した革新的技術——DTraceの動的トレーシング、ZFSのデータ整合性検証——がLinuxにどう受け継がれたかを、eBPF/bpftraceとOpenZFS関連ツールを通じて体験する。

## 学べること

- bpftraceによるシステムコールの動的トレーシング（DTraceの設計思想の継承）
- bpftraceのアグリゲーション機能によるI/O分析
- DTrace構文とbpftrace構文の対応関係
- プロセスライフサイクルの観測
- 商用UNIXの技術的遺産がLinuxに「移植」された経路の理解

## 演習一覧

| 演習 | 内容                                        |
| ---- | ------------------------------------------- |
| 1    | bpftraceでシステムコールを動的トレーシング  |
| 2    | bpftraceのアグリゲーションでI/Oサイズを分析 |
| 3    | プロセスの生成・実行を追跡する              |
| 4    | DTrace構文とbpftrace構文の比較表を確認する  |

## 動作環境

- Docker（ubuntu:24.04イメージ）
- `--privileged` フラグが必要（eBPFプログラムの実行にカーネル権限が必要）
- 追加パッケージ: bpfcc-tools, bpftrace, stress-ng, sysstat, strace

## セットアップ

```bash
docker run -it --rm --privileged ubuntu:24.04 bash
# コンテナ内で:
bash setup.sh
```

## 注意事項

- bpftraceの実行にはroot権限が必要
- `--privileged` なしではeBPFプログラムが実行できない
- ホストカーネルのバージョンによっては一部のトレースポイントが利用できない場合がある

## ライセンス

MIT
