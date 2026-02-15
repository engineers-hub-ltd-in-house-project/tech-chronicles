# 第2回ハンズオン：diffの内部を体験し、限界を知る

## 概要

第2回「すべてはcp -rから始まった——バージョン管理以前の世界」に対応するハンズオン演習。

第1回ではcp、diff、patchの基本操作を体験した。本演習では、diffの「仕組み」の理解と、diff/patchだけでは管理が破綻するシナリオの体験に焦点を当てる。

## 学べること

- LCS（最長共通部分列）アルゴリズムの基本原理
- diff出力フォーマット（normal / context / unified）の違い
- 複数ファイルプロジェクトでのtarball + diff/patch管理の限界
- patchのfuzz factorとrejectの仕組み

## 動作環境

- Linux（Ubuntu 24.04 推奨）
- macOS（diff, patch は標準搭載）
- Windows（WSL2 推奨）

Docker を使う場合:

```bash
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y diffutils patch
```

## 実行方法

```bash
bash setup.sh
```

## 演習内容

| 演習 | テーマ                      | 概要                                                           |
| ---- | --------------------------- | -------------------------------------------------------------- |
| 1    | LCSの手作業トレース         | DP表を使ってdiffの内部計算を追体験する                         |
| 2    | diff出力フォーマット比較    | normal / context / unified の三形式を比較する                  |
| 3    | tarball + diff/patch の破綻 | ファイルの追加・リネームを含む変更でdiff/patchの限界を体験する |
| 4    | fuzz factorとreject         | patchの堅牢性と限界を体験する                                  |

## 前提知識

第1回のハンズオン（cp、diff、patch の基本操作）を完了していること。
