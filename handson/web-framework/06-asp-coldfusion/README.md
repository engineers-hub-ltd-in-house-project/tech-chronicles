# 第6回ハンズオン：忘れられた技術の遺伝子を体験する

## 概要

ASP Classic、ColdFusion、ASP.NET WebFormsという「主流に選ばれなかった」技術が遺した設計判断を、現代の手段で再構成して体感する。
レガシーWindowsサーバや商用ColdFusionライセンスは不要——Node.js + EJS、Lucee CE Docker、HTMXの3点で、それぞれの思想を追体験できる。

## 学べること

- ASP Classic の `<%...%>` インライン文化（EJSで再現）
- ColdFusion CFML のタグベース構文（`<cfquery>`, `<cfloop>`, `<cfif>` など）
- HTMX で実現する「サーバが状態を持ち、クライアントはHTML差分を受け取る」パターン
- ASP.NET WebForms の ViewState/PostBack 思想が、現代のサーバサイド・ステートフル・フレームワークに受け継がれた系譜

## 動作環境

- Docker（Lucee CE 用、`lucee/lucee` イメージ）
- Node.js 20+（npm 含む）
- 接続先ポート: 3000（ASP風）、3001（HTMX）、8888（Lucee）

## 演習一覧

| 演習  | 内容                                             | 所要時間目安 |
| ----- | ------------------------------------------------ | ------------ |
| 演習1 | Node.js + EJS で `<%...%>` インライン文化を再現  | 10分         |
| 演習2 | Lucee CE Docker で CFML タグベース構文を読み解く | 10分         |
| 演習3 | HTMX で「サーバが主、クライアントが従」を体験    | 15分         |

## セットアップ

```bash
./setup.sh
```

このスクリプトは作業ディレクトリ `~/web-framework-handson-06` 配下に3つのサブディレクトリ（`asp-style/`、`cfml/`、`htmx/`）を作り、それぞれの演習用ファイルを配置する。Lucee CEコンテナを起動し、Node.jsの簡易サーバを順次起動して動作確認まで行う。

## 動作確認の見どころ

- 演習1：`curl 'http://localhost:3000/?user=Yusuke'` で、`<%=...%>` 埋め込みと `<% ... %>` ブロックがHTMLに反映される様子を確認
- 演習2：`curl http://localhost:8888/index.cfm` で、`<cfloop>` がループ展開された結果のHTMLが返る
- 演習3：ブラウザで `http://localhost:3001/` を開き、+/- ボタンを押すと、サーバ側のカウンタ変数の値だけがHTMLとして返り、`#counter` 要素の中身に差し込まれる動作を観察

## トラブルシュート

- ポート競合：3000/3001/8888が使われていれば、setup.sh内のポート番号を編集する
- Luceeコンテナの起動に時間がかかる場合：`docker logs lucee-handson` でTomcatの起動を確認（30秒〜1分程度）
- Node.jsの依存解決失敗：`npm cache clean` 後に再実行

## 後片付け

```bash
# Luceeコンテナの停止と削除
docker stop lucee-handson && docker rm lucee-handson

# Node.jsプロセスの停止
pkill -f "node server.js" || true

# 作業ディレクトリの削除
rm -rf ~/web-framework-handson-06
```

## ライセンス

MIT
