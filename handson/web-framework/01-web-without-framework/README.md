# ハンズオン: フレームワークなしでWebを作れるか

**連載「フレームワークという幻想」第1回 対応**

## 概要

Node.jsの標準`http`モジュールだけを使い、外部ライブラリなしでTodo REST APIを構築する。フレームワークが隠蔽している4つの構成要素（HTTPリクエストの受信、ルーティング、ボディパース、レスポンス生成）を自分の手で実装することで、Webアプリケーションの本質を体感する。

## 学べること

- `http.createServer`によるHTTPサーバの起動
- URLパターンマッチングによるルーティングの自作
- ストリームからのリクエストボディ読み取りとJSONパース
- ステータスコード・ヘッダ・ボディを含むHTTPレスポンスの手動構築
- フレームワーク（Express/Next.js）が内部で行っている処理の実体

## 演習一覧

| # | 演習内容                             | ファイル       |
| - | ------------------------------------ | -------------- |
| 1 | HTTPサーバの起動（Hello World）      | server.js      |
| 2 | ルーターの実装（パスパラメータ対応） | router.js      |
| 3 | リクエストボディパーサーの実装       | body-parser.js |
| 4 | Todo REST APIの構築（全機能統合）    | app.js         |
| 5 | curlによる動作確認                   | --             |

## 動作環境

- Docker（推奨）
- Node.js 22 LTS

```bash
# Docker環境で実行する場合
docker run -it --rm -p 3000:3000 node:22-slim bash
```

## セットアップ

```bash
# 自動セットアップスクリプトを実行
bash setup.sh

# 手動で実行する場合
cd ~/web-framework-handson-01
node app.js
```

## 動作確認

```bash
# Todoを作成
curl -s -X POST http://localhost:3000/todos \
  -H 'Content-Type: application/json' \
  -d '{"title": "フレームワークの歴史を学ぶ"}' | jq .

# 一覧取得
curl -s http://localhost:3000/todos | jq .

# 個別取得
curl -s http://localhost:3000/todos/1 | jq .

# 更新
curl -s -X PUT http://localhost:3000/todos/1 \
  -H 'Content-Type: application/json' \
  -d '{"completed": true}' | jq .

# 削除
curl -s -X DELETE http://localhost:3000/todos/1
```

## ライセンス

MIT
