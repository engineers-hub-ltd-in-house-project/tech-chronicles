# 第18回ハンズオン：Gitのトレードオフを体感する

## 概要

Gitの内容アドレス可能ストレージが大きなバイナリファイルに対して持つ本質的な弱点、Git LFSの動作原理、shallow clone/sparse-checkoutによるスケーラビリティ対策を、実際に手を動かして体験する。

## 演習一覧

| 演習  | 内容                                            | 学べること                                  |
| ----- | ----------------------------------------------- | ------------------------------------------- |
| 演習1 | バイナリファイルによるリポジトリ肥大化          | テキスト vs バイナリのデルタ圧縮効率の違い  |
| 演習2 | Git LFSのポインタファイルとsmudge/cleanフィルタ | Git LFSの内部動作、ポインタファイルの構造   |
| 演習3 | shallow cloneの効果測定                         | 履歴制限によるクローンサイズ削減と制約      |
| 演習4 | sparse-checkoutによるモノレポの部分展開         | cone modeの設定と作業ディレクトリの絞り込み |

## 動作環境

- Docker（推奨）: `ubuntu:24.04`
- 必要なツール: `git`, `git-lfs`, `curl`, `python3`
- 所要時間: 約20分

## 実行方法

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y git git-lfs curl python3 time

# スクリプトの実行
bash setup.sh
```

## ライセンス

MIT
