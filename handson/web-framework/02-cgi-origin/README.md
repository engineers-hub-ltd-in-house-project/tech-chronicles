# ハンズオン：CGIという原点——HTTPリクエストを手で受けた時代

## 概要

Apache HTTP Server + Perl CGIの環境をDockerで構築し、1990年代後半のCGI開発を体験する。CGIの仕組み——プロセスフォーク、環境変数、標準入出力——を実際に手を動かして理解する。

## 学べること

- Apache HTTP ServerのCGI設定（ScriptAlias、cgi-bin）
- CGIスクリプトの基本構造（Content-typeヘッダ、空行、ボディ）
- 環境変数によるリクエスト情報の受け渡し
- GETとPOSTの違い（QUERY_STRING vs STDIN）
- CGIのプロセスモデルとステートレス性
- ファイルベースの状態管理とファイルロック

## 演習一覧

| 演習  | 内容                                       |
| ----- | ------------------------------------------ |
| 演習1 | Hello, World! CGIスクリプト                |
| 演習2 | CGI環境変数の可視化                        |
| 演習3 | HTMLフォーム処理（GET/POST）               |
| 演習4 | アクセスカウンター（ステートレス性の体験） |

## 動作環境

- Docker（Docker Desktop または Docker Engine）
- ホストOS: Linux / macOS / Windows（WSL2）
- 使用イメージ: `debian:bookworm-slim`
- 必要パッケージ: `apache2`, `perl`, `curl`

## セットアップ

```bash
# 自動セットアップ
bash setup.sh

# または手動で実行
docker run -it --rm -p 8080:80 --name cgi-lab debian:bookworm-slim bash
```

## クリーンアップ

```bash
docker stop cgi-lab 2>/dev/null
docker rm cgi-lab 2>/dev/null
```
