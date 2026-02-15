# 第4回ハンズオン：CVSサーバを立てて「リポジトリ」と「並行開発」を体感する

## 概要

第4回「CVSの誕生——RCSの限界を超えて」に対応するハンズオン演習。

CVS（Concurrent Versions System）のリポジトリを初期化し、プロジェクトのインポート、チェックアウト、コミット、update、マージといった一連の操作を体験する。RCSのファイル単位・ロック方式との違いを実感し、Copy-Modify-Mergeモデルによる並行開発の仕組みを理解する。

## 学べること

- CVSリポジトリの初期化（cvs init）とCVSROOTの構造
- プロジェクト全体のインポート（cvs import）とチェックアウト（cvs checkout）
- ロックなしの編集・コミットサイクル（cvs diff / cvs commit）
- 並行編集のシミュレーションとcvs updateによるマージ
- cvs logによる履歴表示とcvs tagによるスナップショット記録
- リポジトリ内部のRCS ,vファイルの確認

## 動作環境

- Linux（Ubuntu 24.04 推奨）
- macOS（Homebrew で `brew install cvs`）
- Windows（WSL2 推奨）

Docker を使う場合:

```bash
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y cvs
```

## 実行方法

```bash
bash setup.sh
```

## 演習内容

| 演習 | テーマ             | 概要                                                      |
| ---- | ------------------ | --------------------------------------------------------- |
| 1    | リポジトリの初期化 | cvs init でリポジトリを作成し、CVSROOT構造を確認          |
| 2    | プロジェクト登録   | cvs import でディレクトリツリーを一括登録                 |
| 3    | チェックアウト     | cvs checkout でプロジェクト全体を取得しCVS/メタデータ確認 |
| 4    | 編集とコミット     | ロックなしで編集し、cvs diff / cvs commit で変更を記録    |
| 5    | 並行編集とマージ   | 二つの作業コピーで並行編集し、cvs update でマージ体験     |
| 6    | 履歴とタグ         | cvs log で履歴確認、cvs tag でスナップショット記録        |

## 前提知識

第1回〜第3回のハンズオン（cp、diff、patch、RCSの基本操作）を完了していること。
