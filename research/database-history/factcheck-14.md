# ファクトチェック記録：第14回「MongoDB, CouchDB——ドキュメント指向の挑戦」

## 1. MongoDBの誕生（10gen、2007年創業、2009年公開）

- **結論**: 10genは2007年2月28日にDwight Merriman、Eliot Horowitz、Kevin P. Ryanにより設立された。当初はPaaS構築を目指していたが、既存DBが要件を満たさずMongoDBを開発。2009年2月にオープンソースとして公開。名前は "humongous" に由来
- **一次ソース**: MongoDB Inc. Wikipedia、MongoDB公式プレスリリース
- **URL**: <https://en.wikipedia.org/wiki/MongoDB_Inc.>
- **注意事項**: Merriman は DoubleClick の共同創業者・CTO、Horowitz は DoubleClick エンジニア・ShopWiki 創業者。DoubleClick でのスケーラビリティ問題がMongoDB開発の動機
- **記事での表現**: 「2007年、DoubleClickの共同創業者Dwight MerrimanとエンジニアEliot Horowitzは、10genを設立した。当初はPaaSの構築を目指していたが、要件を満たすデータベースが見つからず、MongoDBの開発に着手した。2009年2月にオープンソースとして公開された」

## 2. 10genからMongoDB Inc.への社名変更（2013年）

- **結論**: 2013年8月27日、10genはMongoDB, Inc.に社名変更を発表した
- **一次ソース**: MongoDB公式プレスリリース、TechCrunch
- **URL**: <https://www.mongodb.com/company/newsroom/press-releases/10gen-announces-solutions-name-change-mongodb-inc>, <https://techcrunch.com/2013/08/27/10gen-is-now-mongodb-to-reflect-focus-on-nosql-database/>
- **記事での表現**: 「2013年8月、10genはMongoDB, Inc.に社名を変更した」

## 3. CouchDBの誕生（2005年、Damien Katz）

- **結論**: CouchDBは2005年4月にDamien Katzが作成した。元IBM Lotus Notes開発者。当初C++で書かれたがその後Erlangに移行（2006年2月）。2008年2月にApache Incubatorに参加、Apache License 2.0を採用。初の安定版（1.0.0）は2010年7月14日
- **一次ソース**: Apache CouchDB Wikipedia、Database of Databases
- **URL**: <https://en.wikipedia.org/wiki/Apache_CouchDB>, <https://dbdb.io/db/couchdb>
- **注意事項**: CouchDB は "Cluster of Unreliable Commodity Hardware" の頭文字。ErlangによるMVCC実装、RESTful HTTP APIが特徴
- **記事での表現**: 「2005年4月、元IBM Lotus Notes開発者のDamien KatzがCouchDBを作成した。当初C++で書かれたが、2006年にErlangで書き直された」

## 4. MongoDB WiredTiger（2014年買収、3.0で導入、3.2でデフォルト化）

- **結論**: MongoDBは2014年12月16日にWiredTiger Inc.を買収。WiredTigerはMongoDB 3.0（2015年）でオプションとして導入、MongoDB 3.2でデフォルトストレージエンジンとなった
- **一次ソース**: MongoDB公式プレスリリース、WiredTiger Wikipedia
- **URL**: <https://www.mongodb.com/company/newsroom/press-releases/wired-tiger>, <https://en.wikipedia.org/wiki/WiredTiger>
- **注意事項**: WiredTigerの主要アーキテクトはDr. Michael CahillとKeith Bostic（Berkeley DB、Sleepycat Software出身）。ドキュメントレベルロックを実現
- **記事での表現**: 「2014年12月、MongoDBはWiredTiger Inc.を買収した。WiredTigerは MongoDB 3.0でオプションとして導入され、3.2でデフォルトストレージエンジンとなった」

## 5. MongoDB マルチドキュメントトランザクション（4.0、2018年）

- **結論**: MongoDB 4.0（2018年夏リリース）でマルチドキュメントACIDトランザクションがレプリカセット上でサポートされた。2018年2月15日に発表。MongoDB 4.2でシャードクラスタへの拡張。2015年から開始した数年間のエンジニアリング成果
- **一次ソース**: MongoDB公式プレスリリース、InfoQ
- **URL**: <https://www.mongodb.com/press/mongodb-announces-multi-document-acid-transactions-in-release-40>, <https://www.infoq.com/news/2018/07/MongoDB-4.0-Released/>
- **記事での表現**: 「2018年、MongoDB 4.0でマルチドキュメントACIDトランザクションが導入された」

## 6. MEAN スタックの命名（2013年、Valeri Karpov）

- **結論**: MEANという頭文字はValeri Karpovが2013年のブログ記事で提唱した。MongoDB、Express.js、Angular、Node.jsの頭文字。後にReactを使うMERN、Vue.jsを使うMEVNも登場
- **一次ソース**: MEAN (solution stack) Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/MEAN_(solution_stack)>
- **記事での表現**: 「2013年、Valeri KarpovがMEANスタック（MongoDB, Express.js, Angular, Node.js）という用語を提唱した」

## 7. 「MongoDB is web scale」ミーム

- **結論**: 2010年頃、Xtranormalアニメーションで「MongoDB is web scale!」とMongoDB信者が叫ぶパロディ動画が話題になった。NoSQLブームの過熱とマーケティング批判の象徴
- **一次ソース**: Hacker News、Know Your Meme
- **URL**: <https://news.ycombinator.com/item?id=1636198>, <https://knowyourmeme.com/videos/29985-xtranormal>
- **記事での表現**: 「2010年、『MongoDB is web scale!』と絶叫するパロディ動画が象徴するNoSQLブームの過熱」

## 8. MongoDB スキーマバリデーション（3.2でvalidator導入、3.6でJSON Schema対応）

- **結論**: MongoDB 3.2でバリデーションルール（validator）が導入された。MongoDB 3.6（2017年）でJSON Schemaバリデーション（$jsonSchemaオペレータ）が追加された
- **一次ソース**: MongoDB公式ドキュメント
- **URL**: <https://docs.mongodb.com/v3.6/core/schema-validation/>
- **記事での表現**: 「MongoDB 3.6（2017年）でJSON Schemaバリデーションが導入された。『スキーマレス』を謳ったMongoDBが、スキーマ強制機能を追加した皮肉」

## 9. MongoDB Aggregation Framework（2.2、2012年）

- **結論**: Aggregation Frameworkは MongoDB 2.2（2012年8月29日リリース）で導入された。リアルタイム集計が可能になった。MongoDB 5.0でmap-reduceは非推奨となりAggregation Pipelineへ移行
- **一次ソース**: MongoDB公式プレスリリース、LWN.net
- **URL**: <https://www.mongodb.com/company/newsroom/press-releases/mongodb-22-delivers-improved-analytics-and-faster-performance>, <https://lwn.net/Articles/514162/>
- **記事での表現**: 「2012年8月のMongoDB 2.2で、Aggregation Frameworkが導入された」

## 10. BSON（Binary JSON）

- **結論**: BSONは2009年にMongoDBで発案されたバイナリ形式。JSONの拡張で、datetime、byte array、IEEE 754浮動小数点数などJSONにない型をサポート。bsonspec.orgで仕様が公開
- **一次ソース**: BSON Wikipedia、bsonspec.org
- **URL**: <https://en.wikipedia.org/wiki/BSON>, <https://bsonspec.org/>
- **記事での表現**: 「MongoDBはデータをBSON（Binary JSON）形式で保存する。JSONの拡張で、日付型やバイナリデータなどの型を追加している」

## 11. MMAPv1ストレージエンジンの制限

- **結論**: MMAPv1はMongoDBの初代ストレージエンジン。コレクションレベルロック（3.0以降、それ以前はデータベースレベルロック）、ドキュメントレベルロック非対応。MongoDB 4.2で削除。パディングによるストレージ非効率、並行書き込みのスケーラビリティ問題
- **一次ソース**: MongoDB公式ドキュメント、Percona Blog
- **URL**: <https://www.percona.com/blog/mongodb-engines-mmapv1-vs-wiredtiger/>
- **記事での表現**: 「初期のMongoDBはMMAPv1ストレージエンジンを使用していた。データベースレベル（後にコレクションレベル）のロックしか持たず、並行書き込みがボトルネックとなった」

## 12. スキーマオンリード vs スキーマオンライト

- **結論**: Schema-on-Write（スキーマオンライト）はデータ書き込み前にスキーマを定義する従来のRDBのアプローチ。Schema-on-Read（スキーマオンリード）はデータ読み取り時にスキーマを適用するアプローチで、ドキュメント型DBやデータレイクで使われる
- **一次ソース**: 複数の技術文献、Dremio、MongoDB公式
- **URL**: <https://www.dremio.com/wiki/schema-on-read-vs-schema-on-write/>
- **記事での表現**: 「『スキーマレス』の正確な表現は『スキーマオンリード』だ。スキーマが不要なのではなく、スキーマの適用をデータ書き込み時ではなく読み取り時に行う」
