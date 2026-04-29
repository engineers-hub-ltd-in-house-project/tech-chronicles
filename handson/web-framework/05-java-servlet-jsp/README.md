# 第5回ハンズオン：素のServletでWebアプリケーションを作る

## 概要

Java Servlet API（Jakarta EE 10、`jakarta.servlet` 名前空間）を使い、フレームワークなしでWebアプリケーションを構築する。
最小のServlet、web.xmlによるURLマッピング、フィルタチェーン、Dockerでの実行までを通じて、
CGI/PHPとの構造的な違い——HTTPリクエストのオブジェクト指向抽象化と宣言的設定の意味——を体感する。

## 学べること

- `HttpServletRequest` / `HttpServletResponse` によるHTTPの抽象化
- `web.xml` による宣言的なServlet/フィルタ定義（URLとクラスの分離）
- フィルタチェーン（`chain.doFilter()`）が後のミドルウェアパターンの原型である事実
- WARディレクトリ構成と Tomcat デプロイメントモデル
- CGI/PHP との構造的差異（プロセス起動コスト・状態保持・URL→コードの対応関係）

## 動作環境

- Docker（`eclipse-temurin:21-jdk` および `eclipse-temurin:21-jre`）
- Apache Tomcat 10.1.x（Jakarta EE 10、Servlet 6.0）
- JDK 21（Eclipse Temurin）

> **注意**: 本ハンズオンは Tomcat 10 系（`jakarta.servlet`）を使う。Tomcat 9 系（`javax.servlet`）とは名前空間が異なるので、サーブレットコードの`import`文をコピー流用する場合は注意すること。

## 演習一覧

| 演習  | 内容                                         | 所要時間目安 |
| ----- | -------------------------------------------- | ------------ |
| 演習1 | 最小の`HttpServlet`を書く                    | 10分         |
| 演習2 | `web.xml`でURLマッピングを宣言する           | 10分         |
| 演習3 | フィルタチェーンを実装し、ミドルウェアを体験 | 15分         |
| 演習4 | Dockerで Tomcat にデプロイし、動作確認       | 15分         |

## セットアップ

```bash
./setup.sh
```

このスクリプトは作業ディレクトリ `~/web-framework-handson-05` を作成し、各演習用のソースコードと`web.xml`、Dockerfileを配置する。
最後にDockerでTomcatコンテナをビルド・起動し、`curl` で動作確認まで行う。

## 動作確認の見どころ

- `curl http://localhost:8080/handson/hello` のレスポンスがServletから返る
- `docker logs` に `[LOG] >>> GET /handson/hello` / `[LOG] <<< Xms` が記録される（フィルタチェーンが動いている証拠）

## トラブルシュート

- ポート 8080 が使用中の場合：`docker run -p 18080:8080 ...` のように別ポートにマッピングする
- `javac` のクラスが見つからない場合：Tomcat 10 の Servlet API JAR (`/opt/tomcat/lib/servlet-api.jar`) を classpath に含めているか確認する
- コンテナが起動しない場合：`docker logs servlet-handson` でTomcatの起動ログを確認

## 後片付け

```bash
docker stop servlet-handson && docker rm servlet-handson
docker rmi servlet-handson
rm -rf ~/web-framework-handson-05
```

## ライセンス

MIT
