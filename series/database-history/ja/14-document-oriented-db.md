# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第14回：MongoDB, CouchDB——ドキュメント指向の挑戦

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 「スキーマレス」という言葉がなぜ2010年代の開発者を魅了し、そして裏切ったのか
- DoubleClickのスケーラビリティ問題から生まれたMongoDB（2009年）と、Lotus Notes開発者が構想したCouchDB（2005年）の設計思想の違い
- 「スキーマオンリード」と「スキーマオンライト」の本質的な区別——スキーマは消えたのではなく、移動しただけだ
- ドキュメントモデルにおけるEmbedding（埋め込み）とReferencing（参照）の設計判断
- MongoDBの進化——MMAPv1からWiredTiger、トランザクション非対応からマルチドキュメントACIDトランザクションへ
- 同じデータをPostgreSQLとMongoDBの両方で実装し、各モデルの得手不得手を体験するハンズオン

---

## 1. 「スキーマレスだから設計不要」という幻想

2012年頃、私はあるプロジェクトでMongoDBを採用した。

当時のNoSQLブームの熱気は凄まじかった。「RDBはスケールしない」「SQLは時代遅れ」「MongoDBならスキーマレスで柔軟にデータを扱える」——Twitterのタイムラインにも、技術カンファレンスのスライドにも、こうした言葉が溢れていた。2010年には「MongoDB is web scale!」と絶叫するパロディ動画がプログラマの間で話題になったが、パロディの対象になるほどMongoDBへの熱狂は過熱していた。

私がMongoDBを選んだ理由は、正直なところ「スキーマ設計が不要」という甘い誘惑だった。RDBでテーブル設計をするたびに、正規化のレベルで悩み、マイグレーションスクリプトを書き、ALTER TABLE文の実行に冷や汗をかいてきた。MongoDBなら、JSONをそのまま突っ込める。カラムの追加も削除も、スキーマ変更なしで行える。開発速度が劇的に上がる——そう信じた。

最初の数か月は、その信念は正しいように見えた。プロトタイプの開発速度は確かに速かった。新しいフィールドが必要になれば、アプリケーションコードを変更するだけで、データベース側の変更は不要だ。フロントエンドから送られてくるJSONをほぼそのままMongoDBに保存し、取り出すときもそのまま返す。シンプルで美しいアーキテクチャに思えた。

だが、プロジェクトが成長するにつれて、カオスが忍び寄ってきた。

あるコレクションのドキュメントを見ると、同じ「ユーザー」を表すはずのドキュメントが、ドキュメントごとに異なるフィールドを持っている。あるドキュメントには`email`フィールドがあるが、別のドキュメントには`mail`フィールドがある。日付が文字列で入っているドキュメントと、ISO 8601形式で入っているドキュメントが混在している。住所が文字列一本で入っているドキュメントと、構造化されたサブドキュメントで入っているドキュメントが共存している。

アプリケーションコードは、これらのバリエーションをすべてハンドリングしなければならなかった。`email`フィールドが存在しなければ`mail`フィールドを確認し、日付が文字列ならパースし、住所が文字列ならそのまま表示し、オブジェクトならフィールドを結合して表示する。

「スキーマレス」は「スキーマ不要」を意味しなかった。スキーマはデータベースから消えたのではなく、アプリケーションコードの中に散らばっただけだった。しかもデータベースが強制してくれないため、不整合が気づかないうちに蓄積される。

結局、私たちはMongoDB 3.6で導入されたJSON Schemaバリデーションを後から適用することになった。「スキーマレスだから設計不要」と思い込んでMongoDBを採用し、最終的にスキーマを強制する機能を後付けで入れる——この皮肉な結末は、私だけの経験ではなかったはずだ。

あなたがMongoDBや他のドキュメント型データベースを使っているなら、問いたい。そのコレクションのドキュメントは、すべて同じ構造を持っているだろうか。持っていないなら、その違いはアプリケーションコードのどこで吸収されているだろうか。

---

## 2. ドキュメント型データベースの誕生——二つの系譜

### CouchDB——Lotus Notesの精神を受け継ぐ

ドキュメント型データベースの歴史は、MongoDBではなくCouchDBから始まる。

2005年4月、元IBM Lotus Notes開発者のDamien Katzは、CouchDBを作成した。Katzはロータスノーツの設計思想——半構造化データの格納、レプリケーション、オフライン対応——に強い影響を受けていた。CouchDBの名前は「Cluster of Unreliable Commodity Hardware」の頭文字であり、信頼性の低い汎用ハードウェアの上で動く分散データベースを志向していた。

CouchDBは当初C++で書かれたが、2006年2月にErlangで書き直された。Erlangの選択は意図的だった。Erlangは並行処理と耐障害性に優れた言語であり、電話交換機の制御用にエリクソンが開発したものだ。分散データベースに求められる特性——並行アクセスの処理、ノード障害からの回復——とErlangの設計思想は合致していた。

CouchDBの設計には際立った特徴が二つある。

第一に、RESTful HTTP APIだ。CouchDBへのすべての操作は、標準的なHTTPメソッド（GET、PUT、POST、DELETE）で行う。専用のクライアントライブラリやプロトコルは不要で、curlコマンドだけでデータベースを操作できる。これは2005年当時としては革新的な設計だった。

第二に、MVCC（Multi-Version Concurrency Control）による楽観的並行制御だ。CouchDBはドキュメントを更新するたびに新しいリビジョンを作成する。読み取りは常に特定のリビジョンに対して行われるため、書き込みによってブロックされない。この方式は、RDBが採用するロックベースの並行制御とは根本的に異なるアプローチだ。

2008年2月、CouchDBはApache Software Foundationのインキュベーションプロジェクトとなり、Apache License 2.0を採用した。2010年7月14日に最初の安定版であるバージョン1.0.0がリリースされた。

### MongoDB——DoubleClickの痛みから

MongoDBの物語は、オンライン広告の世界から始まる。

2007年2月28日、Dwight Merriman、Eliot Horowitz、Kevin P. Ryanの3人がニューヨークで10genを設立した。MerrimanはDoubleClick（後にGoogleが買収するオンライン広告企業）の共同創業者でCTO、HorowitzはDoubleClickのエンジニアでShopWikiの創業者だった。

10genの当初の目標は、オープンソースコンポーネントのみで構築されたPaaS（Platform as a Service）の開発だった。だが、クラウドアーキテクチャの要件を満たすデータベースが見つからなかった。DoubleClickで大規模なRDBの運用を経験していた彼らは、リレーショナルモデルのスケーラビリティの限界を痛感していた。

こうして10genは、自社でデータベースを開発する決断を下す。MongoDBだ。名前は"humongous"（巨大な）に由来し、大量のデータを扱うことを意図している。2009年2月、MongoDBはオープンソースとして公開された。

MongoDBの初期の設計思想は明確だった。

```
MongoDBの設計思想（初期）

┌──────────────────────────────────────────────────┐
│ 1. ドキュメント指向                                │
│    → JSONライクな構造（BSON）でデータを保存         │
│    → 一つのドキュメントに関連データを埋め込める      │
│                                                    │
│ 2. スキーマの柔軟性                                │
│    → コレクション内のドキュメントは異なる構造を持てる │
│    → ALTER TABLE不要、マイグレーション不要           │
│                                                    │
│ 3. 水平スケーラビリティ                            │
│    → 組み込みのシャーディング                       │
│    → レプリカセットによる自動フェイルオーバー        │
│                                                    │
│ 4. 開発者の生産性                                  │
│    → アプリケーションのオブジェクトとデータの形が一致 │
│    → インピーダンスミスマッチの解消                  │
└──────────────────────────────────────────────────┘
```

特に「インピーダンスミスマッチの解消」は重要な概念だ。オブジェクト指向プログラミング言語のオブジェクト構造と、RDBのテーブル構造は根本的に異なる。オブジェクトはネストされた階層構造を持つが、RDBのテーブルはフラットな行と列だ。この構造の不一致——インピーダンスミスマッチ——を埋めるためにORM（Object-Relational Mapping）が生まれた。だが、MongoDBではアプリケーションのオブジェクトをほぼそのままドキュメントとして保存できる。ORMは不要になる——少なくとも理論上は。

### MongoDBの爆発的普及とMEANスタック

MongoDBの普及速度は驚異的だった。

2013年、Valeri KarpovがMEANスタック（MongoDB、Express.js、Angular、Node.js）という用語を提唱した。JavaScriptだけでフロントエンドからバックエンドからデータベースまでを構築する——この「フルスタックJavaScript」の思想は、当時急増していたNode.js開発者を強く惹きつけた。

同年8月、10genはMongoDB, Inc.に社名を変更した。製品名と社名を一致させるこの決断は、MongoDBがもはや10genの「プロジェクトの一つ」ではなく、企業のアイデンティティそのものになったことを示している。

だが、普及の裏で批判も高まっていた。「MongoDB is web scale」のパロディ動画が象徴するように、MongoDBの採用理由が技術的な判断ではなく、ブームへの追従であるケースが少なくなかった。「スキーマレスだから設計不要」「JOINが不要だから速い」「SQLは古い」——こうした単純化された主張が、後に多くのプロジェクトで痛みを生むことになる。

### MongoDBの進化——批判に応えて

MongoDBの功績の一つは、批判に対して真摯に技術的改善を重ねたことだ。

初期のMongoDBはMMAPv1ストレージエンジンを使用していた。MMAPv1はオペレーティングシステムのメモリマップドファイルを利用するシンプルな設計だったが、致命的な制限があった。ロックの粒度がデータベースレベル（後にコレクションレベルに改善）であり、並行書き込みのスケーラビリティに深刻なボトルネックがあった。RDBが数十年前に解決したドキュメントレベルのロックが、MongoDBにはなかったのだ。

2014年12月、MongoDBはWiredTiger Inc.を買収した。WiredTigerの主要アーキテクトであるDr. Michael CahillとKeith Bosticは、Berkeley DBの開発者だった。WiredTigerストレージエンジンはMongoDB 3.0（2015年）でオプションとして導入され、MongoDB 3.2でデフォルトストレージエンジンとなった。WiredTigerはドキュメントレベルのロック、データ圧縮、暗号化をもたらし、MongoDBの性能特性を根本的に変えた。

2012年8月、MongoDB 2.2でAggregation Frameworkが導入された。それまでMongoDBで集計処理を行うにはMapReduceを使う必要があったが、Aggregation Frameworkはパイプライン方式で直感的な集計を可能にした。SQLのGROUP BYやWINDOW関数に相当する操作が、MongoDBネイティブの形で行えるようになった。

2017年、MongoDB 3.6でJSON Schemaバリデーションが導入された。`$jsonSchema`オペレータを使い、コレクションにスキーマ制約を定義できるようになった。「スキーマレス」を最大の売りにしていたMongoDBが、スキーマ強制機能を追加したのだ。これは矛盾ではない。「スキーマの柔軟性」と「スキーマの不在」は別物だということに、コミュニティが気づいた結果だ。

そして2018年、MongoDB 4.0でマルチドキュメントACIDトランザクションがレプリカセット上でサポートされた。2015年から始まった数年間のエンジニアリング成果であり、MongoDB 4.2ではシャードクラスタにも拡張された。「NoSQLだからトランザクションは不要」という初期の思想から、「必要な場面ではトランザクションを使える」という現実的な設計への転換だ。

この進化を見ると、MongoDBは初期の「RDBのアンチテーゼ」から、RDBの優れた機能を選択的に取り込む「ハイブリッド」へと変貌していることがわかる。

---

## 3. ドキュメントモデルの技術的本質

### スキーマオンリードとスキーマオンライト

「スキーマレス」という用語は、技術的に不正確だ。より正確な表現は「スキーマオンリード」と「スキーマオンライト」の対比である。

```
スキーマオンライト（RDB）vs スキーマオンリード（ドキュメントDB）

■ スキーマオンライト（Schema-on-Write）
  → データを書き込む「前」にスキーマを定義する
  → 定義に合わないデータは書き込みが拒否される

  CREATE TABLE users (
      id INT PRIMARY KEY,
      name VARCHAR(100) NOT NULL,
      email VARCHAR(255) NOT NULL UNIQUE,
      age INT CHECK (age >= 0)
  );

  INSERT INTO users (id, name, email, age) VALUES (1, 'Alice', 'alice@example.com', 30);
  -- → 成功

  INSERT INTO users (id, name, age) VALUES (2, 'Bob', 25);
  -- → エラー: email は NOT NULL

■ スキーマオンリード（Schema-on-Read）
  → データを読み取る「とき」にスキーマを解釈する
  → 書き込み時にはどんな構造でも受け入れる

  db.users.insertOne({ name: "Alice", email: "alice@example.com", age: 30 })
  // → 成功

  db.users.insertOne({ name: "Bob", age: 25 })
  // → 成功（emailフィールドがなくてもエラーにならない）

  db.users.insertOne({ name: "Charlie", mail: "charlie@example.com", age: "twenty" })
  // → 成功（フィールド名が違っても、型が違っても受け入れる）
```

スキーマオンライトでは、データの整合性はデータベースが保証する。不正なデータは書き込みの段階で弾かれるため、読み取り側はデータの構造を信頼できる。

スキーマオンリードでは、データの整合性はアプリケーションが保証しなければならない。データベースはどんな構造のドキュメントも受け入れるため、読み取り側がデータの構造を検証する責任を負う。

どちらが「優れている」かではない。トレードオフだ。スキーマオンライトは安全だが硬直的だ。スキーマの変更にはマイグレーションが必要で、大規模なテーブルのALTER TABLEは時間がかかる。スキーマオンリードは柔軟だが危険だ。開発者の規律なしには、データの品質が劣化する。

### Embedding vs Referencing——ドキュメント設計の核心

ドキュメントモデルにおける最も重要な設計判断が、Embedding（埋め込み）とReferencing（参照）の選択だ。

```
同じデータの二つの表現方法

■ Embedding（埋め込み）——関連データをドキュメント内に入れ子にする
{
  "_id": "order-001",
  "customer": {
    "name": "Alice",
    "email": "alice@example.com"
  },
  "items": [
    { "product": "Keyboard", "price": 15000, "qty": 1 },
    { "product": "Mouse",    "price": 8000,  "qty": 2 }
  ],
  "total": 31000
}
→ 1回のクエリで注文の全情報を取得できる
→ 顧客情報が注文ごとに重複する（非正規化）

■ Referencing（参照）——別コレクションへの参照IDを持つ
// orders コレクション
{
  "_id": "order-001",
  "customer_id": "customer-alice",
  "items": [
    { "product_id": "prod-keyboard", "qty": 1 },
    { "product_id": "prod-mouse",    "qty": 2 }
  ]
}

// customers コレクション
{
  "_id": "customer-alice",
  "name": "Alice",
  "email": "alice@example.com"
}

// products コレクション
{
  "_id": "prod-keyboard",
  "name": "Keyboard",
  "price": 15000
}
→ データの重複がない（正規化に近い）
→ 注文の全情報を取得するには複数のクエリが必要
```

Embeddingが適するのは以下の場合だ。関連データが常に一緒にアクセスされる。子データが親データのコンテキスト外で意味を持たない。一対一または一対少数の関係。更新頻度が低い。

Referencingが適するのは以下の場合だ。関連データが独立してアクセスされる。多対多の関係。頻繁に更新されるデータ。ドキュメントサイズがMongoDBの上限（16MB）に近づく場合。

この判断は「JOINが不要だからMongoDBは速い」という単純な主張が見落としている本質的な問題だ。MongoDBでJOINに相当する操作（`$lookup`）を多用するなら、そもそもリレーショナルモデルのほうが適している可能性が高い。ドキュメントモデルが輝くのは、Embeddingによって一回のクエリでデータを取得できる設計ができる場合だ。

### 非正規化のトレードオフ

Embeddingは本質的に非正規化だ。同じデータが複数のドキュメントに存在する。

```
非正規化のトレードオフ

                  正規化（RDB的）        非正規化（ドキュメント的）
読み取り性能:      △ JOIN必要             ○ 1クエリで完結
書き込み性能:      ○ 1箇所を更新          △ 複数箇所を更新
一貫性:           ○ 単一ソース            △ 更新漏れのリスク
ストレージ:       ○ 重複なし              △ データ重複
スキーマ変更:      △ マイグレーション必要   ○ 柔軟
複雑なクエリ:      ○ SQL + JOIN           △ Aggregation Pipeline
```

非正規化の最大のリスクは「更新異常」だ。第4回で取り上げたCoddの正規化理論が排除しようとしたまさにその問題が、ドキュメントモデルでは設計によっては再来する。顧客のメールアドレスが変わったとき、その顧客の全注文ドキュメント内の埋め込み顧客情報を更新しなければならない。一つでも更新漏れがあれば、不整合が生じる。

MongoDBのAggregation Pipelineは、この問題への一つの回答だ。`$lookup`ステージでコレクション間の結合が可能であり、必要に応じて正規化されたデータを結合して取得できる。ただし、`$lookup`はRDBのJOINとは実装が異なり、分散環境でのパフォーマンス特性も異なる。

### CouchDB vs MongoDB——設計思想の分岐

CouchDBとMongoDBは、ともにドキュメント型データベースでありながら、設計思想は大きく異なる。

```
CouchDB vs MongoDB の設計思想の違い

                  CouchDB                    MongoDB
開発言語:         Erlang                     C++
API:             RESTful HTTP API            独自バイナリプロトコル
データ形式:       JSON                       BSON（Binary JSON）
クエリ:          MapReduce / Mango           独自クエリ言語 / Aggregation
レプリケーション: マルチマスタ                 レプリカセット（単一プライマリ）
同期:            双方向レプリケーション        単方向レプリケーション
並行制御:         MVCC（リビジョン管理）       WiredTiger MVCC
オフライン:       オフラインファースト設計      サーバ前提設計
哲学:            データの可用性・同期          開発者の生産性・性能
```

CouchDBは「分散」と「同期」を核に据えた設計だ。マルチマスタレプリケーションにより、複数のノードが独立に書き込みを受け付け、後で競合を解決する。オフライン環境で動作し、ネットワーク復旧後に同期するユースケースに適する。モバイルアプリケーションやエッジコンピューティングに向いた設計だ。

MongoDBは「開発者の生産性」と「性能」を核に据えた設計だ。豊富なクエリ言語、Aggregation Pipeline、組み込みのシャーディング——開発者が素早くアプリケーションを構築し、スケールさせることに注力した。結果としてMongoDBが市場を席巻し、CouchDBは相対的にニッチな存在となった。

---

## 4. ドキュメントモデルが真に輝く場面、そして輝かない場面

### ドキュメントモデルが適するユースケース

ドキュメントモデルが真に力を発揮するのは、以下のようなケースだ。

**コンテンツ管理システム（CMS）**。記事、ブログ投稿、製品情報など、個々のエンティティが自己完結的で、エンティティごとに異なる属性を持つケース。記事Aにはビデオ埋め込みがあり、記事Bにはギャラリーがあり、記事Cにはコード例がある——このような可変構造を自然に表現できる。

**イベントログ・監査ログ**。イベントの構造が時間とともに変化する場合、スキーマオンリードの柔軟性が活きる。古いイベントと新しいイベントが異なるフィールドを持っていても問題ない。

**プロトタイプ開発**。要件が不確定な段階で、データモデルを頻繁に変更しながら開発を進める場合。マイグレーションのオーバーヘッドなしにフィールドの追加・変更ができる。

**リアルタイムアナリティクス**。Aggregation Pipelineを使って、大量のドキュメントをリアルタイムに集計・変換する場合。

### ドキュメントモデルが適さないユースケース

一方で、以下のケースではRDBのほうが適している。

**複雑な関係を持つデータ**。多対多の関係が頻繁に生じるデータ。例えば、学生と講座の関係、著者と書籍の関係など。Embeddingではデータの重複が膨大になり、Referencingでは`$lookup`の多用がパフォーマンスを劣化させる。

**厳密なトランザクション要件**。複数のコレクションにまたがるアトミックな操作が頻繁に必要な場合。MongoDB 4.0以降でマルチドキュメントトランザクションがサポートされたが、パフォーマンスオーバーヘッドはRDBのそれより大きい。MongoDBの公式ドキュメント自体が「多くのシナリオでは、非正規化されたデータモデルがマルチドキュメントトランザクションの必要性を最小化する」と述べている。

**複雑なレポーティング・集計**。多数のテーブルを横断するJOINと集計が必要な業務レポート。SQLのウィンドウ関数やサブクエリが本領を発揮する場面で、Aggregation Pipelineは表現力で劣る。

**データの一貫性が最優先**。金融取引、在庫管理など、データの不整合が直接的な損失に繋がるケース。スキーマオンライトによる厳密な制約と、成熟したトランザクション機構を持つRDBが安全だ。

---

## 5. ハンズオン: PostgreSQL vs MongoDB——同じデータ、二つのモデル

今回のハンズオンでは、同じデータモデルをPostgreSQL（正規化リレーショナル）とMongoDB（非正規化ドキュメント）で実装し、CRUD操作の違いと各モデルの得手不得手を体験する。

### 演習概要

1. 同じECサイトのデータ（ユーザー、商品、注文）を両方のデータベースに投入する
2. 基本的なCRUD操作の違いを比較する
3. JOINを多用するクエリと、埋め込みドキュメントのクエリを比較する
4. データの更新時の一貫性の違いを体験する

### 環境構築

```bash
# handson/database-history/14-document-oriented-db/setup.sh を実行
bash setup.sh
```

### 演習1: データモデルの比較——正規化 vs 非正規化

setup.shがPostgreSQLとMongoDBのコンテナを起動し、サンプルデータを投入済みだ。

PostgreSQLの正規化されたスキーマを確認する。

```bash
docker exec -it db-history-ep14-postgres psql -U postgres -d handson
```

```sql
-- PostgreSQL: 正規化されたテーブル構造
\dt

-- users, products, orders, order_items の4テーブル
SELECT * FROM users LIMIT 3;
SELECT * FROM products LIMIT 3;
SELECT * FROM orders LIMIT 3;
SELECT * FROM order_items WHERE order_id = 1;
```

MongoDBの非正規化されたドキュメントを確認する。

```bash
docker exec -it db-history-ep14-mongo mongosh handson
```

```javascript
// MongoDB: 埋め込みドキュメント構造
// 注文ドキュメントに顧客情報と商品情報が埋め込まれている
db.orders.findOne()

// 出力例:
// {
//   _id: "order-001",
//   customer: { name: "Alice", email: "alice@example.com" },
//   items: [
//     { product: "Mechanical Keyboard", price: 15000, qty: 1 },
//     { product: "Wireless Mouse", price: 8000, qty: 2 }
//   ],
//   total: 31000,
//   ordered_at: ISODate("2026-02-20T10:00:00Z")
// }
```

### 演習2: 読み取り操作の比較

```sql
-- PostgreSQL: 注文の詳細を取得するにはJOINが必要
SELECT o.id AS order_id,
       u.name AS customer_name,
       u.email AS customer_email,
       p.name AS product_name,
       p.price,
       oi.quantity,
       o.total,
       o.ordered_at
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE o.id = 1;
-- → 4テーブルのJOINが必要
```

```javascript
// MongoDB: 1クエリで全情報を取得
db.orders.findOne({ _id: "order-001" })
// → JOINなし、1ドキュメントに全情報が含まれる
```

この比較が、MongoDBが「JOINが不要だから速い」と言われる所以だ。ただし、これはデータモデルの設計（非正規化）によるものであり、MongoDBの技術的優位ではない。PostgreSQLでもJSONBカラムに非正規化したデータを格納すれば、同様の読み取り性能を実現できる。

### 演習3: 更新操作と一貫性の比較

```sql
-- PostgreSQL: 顧客のメールアドレスを更新
-- 1箇所の更新で全ての関連データに反映される
UPDATE users SET email = 'alice.new@example.com' WHERE id = 1;

-- 注文データからJOINで取得すると、自動的に最新のメールアドレスが返る
SELECT u.email FROM orders o
JOIN users u ON o.user_id = u.id
WHERE o.id = 1;
-- → alice.new@example.com（即座に最新値）
```

```javascript
// MongoDB: 顧客のメールアドレスを更新
// 埋め込みの場合、全注文ドキュメント内の顧客情報を更新する必要がある

// まず顧客コレクションを更新（参照用に別コレクションがある場合）
db.customers.updateOne(
    { _id: "customer-alice" },
    { $set: { email: "alice.new@example.com" } }
)

// 次に、全注文ドキュメント内の埋め込み顧客情報も更新
db.orders.updateMany(
    { "customer.email": "alice@example.com" },
    { $set: { "customer.email": "alice.new@example.com" } }
)

// 更新漏れがないか確認
db.orders.find({ "customer.email": "alice@example.com" }).count()
// → 0 であることを確認（漏れがあれば > 0）
```

これが非正規化の代償だ。正規化されたRDBでは1行の更新で済む操作が、非正規化されたドキュメントモデルでは複数のドキュメントを更新する必要がある。更新漏れはデータの不整合に直結する。

### 演習4: Aggregation Pipeline vs SQL集計

```sql
-- PostgreSQL: 商品カテゴリ別の売上集計
SELECT p.category,
       COUNT(DISTINCT o.id) AS order_count,
       SUM(oi.quantity) AS total_quantity,
       SUM(oi.quantity * p.price) AS total_revenue
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
GROUP BY p.category
ORDER BY total_revenue DESC;
```

```javascript
// MongoDB: Aggregation Pipeline で同等の集計
db.orders.aggregate([
    { $unwind: "$items" },
    { $group: {
        _id: "$items.category",
        order_count: { $addToSet: "$_id" },
        total_quantity: { $sum: "$items.qty" },
        total_revenue: { $sum: { $multiply: ["$items.price", "$items.qty"] } }
    }},
    { $project: {
        category: "$_id",
        order_count: { $size: "$order_count" },
        total_quantity: 1,
        total_revenue: 1
    }},
    { $sort: { total_revenue: -1 } }
])
```

両方とも同じ結果を返すが、表現方法はまったく異なる。SQLの宣言的な簡潔さと、Aggregation Pipelineのパイプライン的な明示性。どちらが「読みやすい」かは、慣れの問題もあるが、複雑な集計においてはSQLに一日の長がある。

### 後片付け

```bash
docker rm -f db-history-ep14-postgres db-history-ep14-mongo
docker network rm db-history-ep14-net 2>/dev/null || true
```

---

## 6. スキーマは消えない——形を変えるだけだ

第14回を振り返ろう。

**「スキーマレス」は「スキーマ不要」を意味しない。** データの構造（スキーマ）は常に存在する。問題は、それをどこで定義し、どこで強制するかだ。スキーマオンライト（RDB）はデータベースがスキーマを強制する。スキーマオンリード（ドキュメントDB）はアプリケーションがスキーマを解釈する。スキーマの責任が「移動」しただけだ。

**MongoDBは2009年にDoubleClickのスケーラビリティ問題を背景に誕生した。** 10gen（後のMongoDB, Inc.）がPaaS開発の過程で構築したドキュメント型データベースだ。MEANスタックの普及とNoSQLブームに乗って爆発的に成長したが、「スキーマレスだから設計不要」という誤解も広まった。

**CouchDBは2005年にDamien Katzが開発した、もう一つのドキュメント型データベースだ。** Erlangで書かれ、RESTful HTTP API、MVCC、マルチマスタレプリケーションを特徴とする。MongoDBが「開発者の生産性」を優先したのに対し、CouchDBは「分散と同期」を優先した。

**ドキュメントモデルの核心的な設計判断はEmbedding vs Referencingだ。** Embeddingは読み取りが速いが、データの重複と更新異常のリスクを伴う。Referencingは一貫性を保ちやすいが、複数クエリが必要になる。「JOINが不要」という利点は、データモデルが適切にEmbeddingで設計されている場合にのみ成立する。

**MongoDBは批判に応えて劇的に進化した。** MMAPv1からWiredTigerへのストレージエンジン移行（2014-2015年）、JSON Schemaバリデーション（2017年）、マルチドキュメントACIDトランザクション（2018年）——初期の「RDBのアンチテーゼ」から、RDBの優れた機能を選択的に取り込むハイブリッドへと変貌した。

冒頭の問いに戻ろう。「『スキーマレス』は本当に自由をもたらしたのか？」

自由をもたらした面はある。開発初期のスピード、スキーマ進化の柔軟性、アプリケーションオブジェクトとデータ構造の自然な対応——これらは実際のメリットだ。だが、その自由には代償がある。スキーマの管理責任がデータベースからアプリケーションに移転し、開発者の規律なしにはデータの品質が劣化する。

結局のところ、データには構造がある。その構造をどこで定義し、どこで強制するかは、技術的な選択だ。「スキーマレスだから自由」と「スキーマがあるから安全」は、同じトレードオフの両面にすぎない。

次回は「Cassandra, DynamoDB——分散と結果整合性の世界」を取り上げる。「絶対に落ちない」データベースは、何を犠牲にして実現されるのか。Amazon Dynamo論文が切り拓いた分散データベースの世界と、Consistent Hashing、Vector Clocks、Quorumといった技術を辿る。

---

### 参考文献

- MongoDB Inc., Wikipedia. <https://en.wikipedia.org/wiki/MongoDB_Inc.>
- MongoDB, Wikipedia. <https://en.wikipedia.org/wiki/MongoDB>
- Apache CouchDB, Wikipedia. <https://en.wikipedia.org/wiki/Apache_CouchDB>
- 10gen, "10gen Announces Company Name Change to MongoDB, Inc.", August 27, 2013. <https://www.mongodb.com/company/newsroom/press-releases/10gen-announces-solutions-name-change-mongodb-inc>
- MongoDB Inc., "MongoDB Acquires WiredTiger Inc.", December 16, 2014. <https://www.mongodb.com/company/newsroom/press-releases/wired-tiger>
- MongoDB Inc., "MongoDB Announces Multi-Document ACID Transactions in Release 4.0", February 15, 2018. <https://www.mongodb.com/press/mongodb-announces-multi-document-acid-transactions-in-release-40>
- MongoDB Inc., "MongoDB 2.2 Delivers Improved Analytics and Faster Performance", August 29, 2012. <https://www.mongodb.com/company/newsroom/press-releases/mongodb-22-delivers-improved-analytics-and-faster-performance>
- MongoDB Docs, "Schema Validation". <https://www.mongodb.com/docs/manual/core/schema-validation/>
- MongoDB Docs, "Embedded Data Versus References". <https://www.mongodb.com/docs/manual/data-modeling/concepts/embedding-vs-references/>
- BSON Specification. <https://bsonspec.org/>
- MEAN (solution stack), Wikipedia. <https://en.wikipedia.org/wiki/MEAN_(solution_stack)>

---

**次回予告：** 第15回「Cassandra, DynamoDB——分散と結果整合性の世界」では、「絶対に落ちない」データベースがどのような設計思想で実現されているかを辿る。2007年のAmazon Dynamo論文が提示した分散アーキテクチャ。FacebookがDynamoとBigtableのハイブリッドとして開発したCassandra。DynamoDBの「プロビジョニングされたキャパシティ」に戸惑い、スロットリングに苦しんだ話。Consistent Hashing、Quorum、そして「クエリファースト」のデータモデリングを体験する。
