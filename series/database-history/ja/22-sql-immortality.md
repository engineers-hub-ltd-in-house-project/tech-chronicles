# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第22回：SQLの不死——なぜ50年経っても消えないのか

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- SQL標準化の50年史——SQL-86からSQL:2023まで、10回の改訂が何を追加してきたか
- NoSQLブームの「Not Only SQL」への転換——SQLを葬ろうとした運動がSQLを再評価した皮肉
- GoogleのMapReduceからDremel/BigQueryへの回帰——SQLを捨てたGoogle自身がSQLに戻った理由
- SQLが生き残る4つの構造的要因——宣言的クエリ、関係代数、人的資本、ツールエコシステム
- QUEL、Datalog、GraphQL——SQLの「代替」はなぜ主流にならなかったか
- モダンSQL機能——ウィンドウ関数、再帰CTE、JSONB操作、SQL/PGQによるグラフクエリ
- SQLの限界と未来——50年生き残った言語が次の50年も生き残る保証はない

---

## 1. 「SQLはレガシー」と聞いた2010年代

2012年頃、私はある勉強会に参加していた。テーマは「NoSQLとビッグデータの未来」。登壇者は自信に満ちた口調で言った。「SQLは過去の遺物です。これからはMapReduceとドキュメント指向データベースの時代です」。

会場は熱気に包まれていた。MongoDBのロゴが入ったステッカーが配られ、参加者の多くがMacBookの背面に貼っていた。SQLは古い、リレーショナルデータベースはスケールしない、スキーマレスこそが自由だ——そういう空気が支配していた。

私は複雑な気持ちでその光景を見ていた。当時すでにエンジニア歴15年以上。MySQLのスロークエリと格闘し、PostgreSQLの拡張性に助けられ、SQLの表現力に何度も感嘆してきた。SQLが完璧だとは思わない。NULLの三値論理は直感に反するし、集合演算の挙動に何度もつまずいた。だが、SQLが「過去の遺物」だとは到底思えなかった。

それから10年以上が経った。2026年現在、私の目の前にある光景はこうだ。

CockroachDBはPostgreSQL互換のSQLインターフェースを提供している。TiDBはMySQL互換のSQLインターフェースを提供している。Apache Spark SQLはHadoopの世界にSQLを持ち込んだ。DuckDBは分析の世界にSQLを持ち込んだ。Google BigQueryはSQLでペタバイト級のデータを分析する。Amazon AthenaはS3上のデータをSQLで問い合わせる。

2012年の勉強会で「SQLは過去の遺物」と宣言した人々が支持したMongoDBでさえ、2019年のバージョン4.0でマルチドキュメントACIDトランザクションを実装し、2021年にはSQL互換のクエリインターフェースを拡充した。

あらゆるシステムが、SQLに「戻って」きている。あるいは、SQLから「離れられなかった」と言うべきか。

なぜだろうか。なぜ50年前に生まれた言語が、NoSQLブームにも、MapReduce革命にも、AI時代にも耐えて、いまだに「データベースの共通語」であり続けるのか。

あなたが日常的に書いているSQL——SELECT、JOIN、WHERE、GROUP BY——がなぜ50年間死ななかったのか。その理由を、歴史の中に探ってみたい。

---

## 2. SQL標準化の50年史——死なない言語の進化戦略

### SEQUELからSQLへ

第5回で語ったように、SQLの起源は1974年にまで遡る。IBMのSan Jose Research LaboratoryでDonald ChamberlinとRaymond Boyceが開発したSEQUEL（Structured English Query Language）は、Edgar F. Coddのリレーショナルモデルを実装するための問い合わせ言語として設計された。System R（1974-1979年）で実装が進められ、英国Hawker Siddeley Dynamics Engineering Limited社の商標問題から「SQL」に改名された。

だがSQLの真の力は、言語そのものの設計よりも、その後の「標準化」戦略にある。

### 標準化という防壁

1986年、SQLはANSI（American National Standards Institute）により標準化された（SQL-86）。翌1987年にはISO標準にもなった。この標準化の意味は深い。

SQLが標準化される以前、各RDBMSベンダーは独自のクエリ言語を提供していた。UC BerkeleyのIngresプロジェクトはQUELを持ち、IBMのSystem RはSQLを持ち、他のベンダーはそれぞれ独自の方言を持っていた。開発者は特定のデータベースに縛られ、移行コストは甚大だった。

SQL-86の標準化は、この状況に終止符を打った。データベースベンダーが準拠すべき共通のインターフェース仕様が定まったことで、「SQLを覚えれば、どのRDBMSでも使える」という状況が生まれた。完全な互換性ではないにせよ、SQLの基本構文——SELECT、INSERT、UPDATE、DELETE——は、どのRDBMSでも同じように動く。

この「標準化」という防壁が、SQLをベンダー間の競争から守り、言語としての寿命を飛躍的に延ばした。

### SQL標準の進化

標準化されたSQLは、しかし決して「固定された」言語ではない。50年間で10回の改訂を重ね、時代の要求に応え続けてきた。

```
SQL標準の進化年表

SQL-86 (1986)  ─── 最初の標準。基本的なDDL/DML
    │               120ページ
    │
SQL-89 (1989)  ─── 整合性制約の追加
    │               Ada, C言語バインディング
    │
SQL-92 (1992)  ─── 大規模改訂。579ページに拡大
    │               外部結合(LEFT/RIGHT/FULL JOIN)
    │               集合演算(UNION/INTERSECT/EXCEPT)
    │               CASE式、CAST
    │
SQL:1999       ─── オブジェクトリレーショナル機能
    │               正規表現マッチング
    │               再帰クエリ(WITH RECURSIVE)
    │               トリガー
    │
SQL:2003       ─── ウィンドウ関数(OVER, PARTITION BY)
    │               XML統合
    │               MERGE文
    │               シーケンスジェネレータ
    │
SQL:2006       ─── XML拡張の強化
    │
SQL:2008       ─── TRUNCATE TABLE
    │               INSTEAD OF トリガー
    │
SQL:2011       ─── テンポラルデータベース機能
    │               期間定義、期間述語
    │
SQL:2016       ─── JSON対応
    │               行パターン認識(MATCH_RECOGNIZE)
    │               多態テーブル関数
    │
SQL:2023       ─── Property Graph Queries (SQL/PGQ)
                    JSON強化（型変換、比較・ソート）
                    ANY_VALUE集約関数
```

この年表を眺めると、一つの重要なパターンが見えてくる。SQLは「新しい技術トレンド」を標準に取り込み続けてきた。2000年代のXMLブームにはSQL:2003とSQL:2006で対応した。2010年代のJSONの普及にはSQL:2016で対応した。そして2020年代のグラフデータベースの台頭には、SQL:2023でProperty Graph Queries（SQL/PGQ）を標準に取り込んだ。

SQL/PGQの追加は特に象徴的だ。第16回で語ったNeo4jのCypherクエリ言語に代表されるグラフクエリの世界を、SQL標準が吸収したのである。GRAPH_TABLEという新しいFROM句の演算子により、リレーショナルテーブルに格納されたデータをグラフとして問い合わせることが可能になった。

つまりSQLは、競合する技術を「標準の中に取り込む」ことで生き延びてきた。XMLが来ればXML対応を加え、JSONが来ればJSON対応を加え、グラフDBが来ればグラフクエリを加える。敵を倒すのではなく、敵を吸収する。これがSQLの進化戦略だ。

---

## 3. SQLを殺そうとした者たち——そして全員が帰還した

### MapReduceの挑戦——Googleの壮大な回り道

SQLの不死を語る上で避けて通れないのが、2000年代に起きた「ビッグデータ革命」だ。

2004年、Googleが発表したMapReduce論文は、データ処理の世界に地殻変動を引き起こした。ペタバイト級のデータを、何千台ものコモディティサーバで並列処理する。SQLのような宣言的クエリ言語ではなく、MapとReduceという二つの関数をJavaで記述する手続き的なプログラミングモデルだ。

GoogleはMapReduceによって、SQLでは到達できないスケーラビリティを実現した。そしてApache Hadoopが2006年にこの思想をオープンソースで実装し、世界中の企業がMapReduceを導入した。

だが、MapReduceには致命的な弱点があった。開発生産性だ。

単純な集計クエリ——「地域別の売上合計を求めよ」——をSQLなら3行で書ける処理が、MapReduceでは数十行のJavaコードを要する。データ分析者はJavaプログラマではない。彼らはSQLを書きたいのだ。

```
同じクエリの表現コスト比較

SQL:
  SELECT region, SUM(amount)
  FROM sales
  GROUP BY region;

MapReduce (疑似コード):
  class SalesMapper extends Mapper {
    void map(key, value, context) {
      record = parse(value);
      context.write(record.region, record.amount);
    }
  }
  class SalesReducer extends Reducer {
    void reduce(key, values, context) {
      total = 0;
      for (value : values) {
        total += value;
      }
      context.write(key, total);
    }
  }
  // + ジョブの設定、入出力フォーマットの定義、実行コード...

→ SQLの3行 vs MapReduceの数十行
→ しかも結果は同じ
```

結果として何が起きたか。MapReduceの上に、SQLインターフェースが構築されたのだ。

2010年、FacebookのJoydeep Sen SarmaとAshish ThusooがApache Hiveを公開した。HiveQLというSQLライクなクエリ言語を提供し、クエリを内部でMapReduceジョブに変換する。開発者はSQLを書くだけで、Hadoopクラスタ上のデータを分析できるようになった。

2012年8月、同じくFacebookでMartin Traversoらが開発したPrestoが登場した。約300ペタバイトのデータに対するHiveの性能限界を解決するために設計された、分散SQLクエリエンジンだ。2013年11月にオープンソース化され（後にPrestoSQL→Trinoに分岐・リブランド）、LinkedIn、Netflix、Teradata等の企業が採用した。

そしてGoogle自身が、SQLに「戻った」。

2006年、Google内部でAndrey Gubarevが「20%プロジェクト」としてDremelの開発を始めた。MapReduceジョブの作成が煩雑で、分析に数時間から数日かかる問題を、SQLインターフェースで解決するシステムだ。2010年にDremel論文が発表され、2012年にBigQueryとして商用化された。MapReduceを世界に広めたGoogle自身が、社内ではSQLに回帰していたのである。

この事実は重い。SQLを「過去の遺物」として葬ろうとしたビッグデータ革命の旗手——Google自身が、SQLの不死を証明したのだ。

### NoSQLの「Not Only SQL」

第12回から第16回で語ったNoSQL革命も、結局はSQLからの完全な離脱に失敗した。

2009年、Johan Oskarsson（Last.fm開発者）がサンフランシスコで「オープンソース分散非リレーショナルデータベース」を議論するミートアップを組織した。このイベントがNoSQLムーブメントの象徴的な起点となった。当初、NoSQLは文字通り「No SQL」——SQLを使わないデータベース——を意味していた。

だがムーブメントが成熟するにつれて、NoSQLの意味は「Not Only SQL」へと変容した。SQLを否定するのではなく、SQLだけではないという立場への転換だ。この意味の変容自体が、SQLの不死を象徴している。「SQLをやめよう」と言ったはずの運動が、「SQLも必要だよね」と認めざるを得なくなったのだ。

実際、主要なNoSQLデータベースの多くがSQLライクなクエリインターフェースを追加してきた。

CassandraはCQL（Cassandra Query Language）を提供している。構文はSQLに酷似しており、SELECT、INSERT、UPDATE、DELETEが使える。CQLのドキュメントには明確に「SQL inspired」と記されている。

MongoDBは集約パイプライン（Aggregation Pipeline）に加えて、MongoDB 4.0（2018年）でACIDトランザクションを実装し、SQLに近い機能セットを獲得していった。MongoDB Atlas SQL InterfaceはSQLでMongoDBのデータを直接クエリできるインターフェースだ。

Amazon DynamoDBに対しては、PartiQL（Particle QL）というSQL互換のクエリ言語がAWSから提供されている。DynamoDBの独自のクエリ構文ではなく、SQLの構文でDynamoDBのデータを操作できる。

InfluxDBは時系列データベースであるにもかかわらず、InfluxQL——SQLに似た独自のクエリ言語——を長年提供し、さらにFluxという新しい関数型言語に移行した後も、最終的にSQL互換のインターフェースを再導入した。

この帰還のパターンは明確だ。NoSQLデータベースは、データモデルやストレージエンジンのレベルではリレーショナルモデルから離脱できた。だがクエリインターフェースのレベルでは、SQLから離脱できなかった。

### Spark SQLの象徴性

2014年にApache SparkにSQL機能が追加されたことの象徴性は、改めて強調に値する。

SparkはMapReduceを置き換える新世代の分散計算エンジンとして設計された。RDD（Resilient Distributed Dataset）という独自の抽象の上に、Scala/Java/PythonのAPIでデータ変換を記述する。MapReduceよりはるかに表現力が高く、速度も速い。

だがSparkの開発チームは、SQLインターフェースを追加した。Spark SQLだ。なぜか。理由は単純だ。データ分析者はSQLを知っている。SQLを知らないデータ分析者はほとんどいない。新しいAPIを覚えさせるよりも、既にある知識——SQL——を活用する方が採用のハードルが低い。

この判断は正しかった。Spark SQLは、Sparkの中で最も広く使われているコンポーネントとなった。前回の記事でも触れたが、新しい計算エンジンが登場してもインターフェースとしてSQLに回帰する。このパターンは繰り返し現れる。

---

## 4. SQLが不死である4つの構造的要因

ここまで歴史を辿ってきた。MapReduceも、NoSQLも、SQLを殺すことはできなかった。ではなぜか。私は、SQLの不死には4つの構造的要因があると考えている。

### 要因1: 宣言的クエリの普遍性

SQLの最も根本的な設計判断は、「宣言的」であることだ。

第5回で語ったように、SQLは「何が欲しいか（What）」を記述する言語であり、「どう取得するか（How）」は記述しない。`SELECT name FROM users WHERE age > 30` は、「30歳以上のユーザーの名前が欲しい」と宣言しているだけだ。インデックスを使うのか、シーケンシャルスキャンするのか、パーティションをプルーニングするのか——実行計画はデータベースエンジンが決定する。

この「What vs How」の分離は、SQLに驚異的な耐久性をもたらした。

ストレージ技術が磁気ディスクからSSDに変わっても、SQLの構文は変わらない。データが単一サーバから分散クラスタに移行しても、SQLの構文は変わらない。クエリオプティマイザが統計ベースからAIベースに進化しても、SQLの構文は変わらない。「How」の部分がどれだけ革新されても、「What」の表現は不変だからだ。

手続き的なクエリ言語——MapReduceやMongoDBの初期のクエリ構文——は、「How」を記述する。データの取得方法に言及するため、基盤技術の変化に対して脆弱だ。ストレージ構造が変われば、クエリの書き方も変わる。

宣言的な言語は、基盤技術の変化を吸収するバッファとして機能する。これが50年の技術変化に耐えた第一の理由だ。

```
宣言的 vs 手続き的

宣言的（SQL）:
┌───────────────────────────┐
│ SELECT ... FROM ... WHERE │  ← 「何が欲しいか」を宣言
└───────────┬───────────────┘
            │
    ┌───────▼───────┐
    │ クエリ        │  ← オプティマイザが「どう取るか」を決定
    │ オプティマイザ │
    └───────┬───────┘
            │
    ┌───────▼───────┐  ← 実行エンジンは世代交代しても
    │ 実行エンジン  │     SQLの構文は変わらない
    │ (行指向/列指向│
    │  /分散/GPU...)│
    └───────────────┘

手続き的（MapReduce等）:
┌────────────────────────────┐
│ map() → shuffle → reduce() │  ← 「どう処理するか」を記述
└────────────────────────────┘
   ↑ 実行方法の変化がAPIの変化に直結する
```

### 要因2: 関係代数という数学的基盤

SQLは、Coddの関係代数に基づいている。選択（Selection）、射影（Projection）、結合（Join）、和（Union）、差（Difference）——これらの基本操作は、集合論と一階述語論理に根ざした数学的構造だ。

数学的基盤を持つことの利点は何か。それはクエリの最適化が「証明可能」になることだ。

クエリオプティマイザは、SQLクエリを関係代数の式に変換し、数学的に等価な変換を適用して最適な実行計画を探索する。たとえば、結合の順序を入れ替えても結果が変わらないことは、関係代数の結合の交換律によって保証される。選択条件を結合の前に適用する「述語プッシュダウン」の正当性も、関係代数の性質から導かれる。

```
関係代数に基づくクエリ最適化の例

元のクエリ:
  SELECT u.name, o.total
  FROM users u JOIN orders o ON u.id = o.user_id
  WHERE u.country = 'Japan' AND o.total > 10000;

関係代数的に等価な変換:
  Step 1: 選択を結合の前に押し下げる（述語プッシュダウン）
    σ(country='Japan')(users) ⋈ σ(total>10000)(orders)
    → JOINする前にフィルタリングすることで、処理行数を削減

  Step 2: 結合順序の最適化
    小さいテーブルを内側に置く
    → ハッシュ結合のメモリ消費を削減

  これらの変換の正当性は関係代数の性質から数学的に保証される
```

MapReduceやMongoDBの集約パイプラインには、こうした数学的基盤がない。オプティマイザが自動的にクエリを最適化する余地が、SQLに比べて構造的に小さい。

この数学的基盤は、SQLの拡張性にも寄与している。ウィンドウ関数（SQL:2003）は関係代数にウィンドウ演算を追加し、再帰CTE（SQL:1999）は関係代数に不動点意味論を追加した。数学的な基盤があるからこそ、拡張が体系的に行える。

### 要因3: 膨大な人的資本

2024年のStack Overflow Developer Surveyによれば、SQLはプロフェッショナル開発者の54.1%が使用しており、プログラミング言語として第2位にランクインしている（第1位はJavaScript）。

この数字の意味を考えてほしい。世界中の開発者の半数以上がSQLを書ける。これは途方もない「人的資本」だ。

新しいクエリ言語を普及させるということは、この数百万人規模の人的資本を無視するということだ。全員にMongoDBの集約パイプライン構文を覚えさせるのか？ Cypherを覚えさせるのか？ MapReduceのJava APIを覚えさせるのか？

CockroachDBがPostgreSQL互換のSQLインターフェースを選んだ理由、TiDBがMySQL互換のSQLインターフェースを選んだ理由は、技術的な優劣の問題ではない。PostgreSQLやMySQLのSQLを書ける開発者が世界に何百万人もいるという、人的資本の問題だ。既存の知識をそのまま活用できるデータベースは、採用のハードルが圧倒的に低い。

これは「ネットワーク効果」に似た構造だ。SQLを知っている人が多いから、新しいデータベースもSQLに対応する。新しいデータベースがSQLに対応するから、SQLを学ぶ人がさらに増える。この正のフィードバックループが、SQLの地位を自己強化し続けている。

### 要因4: ツールエコシステム

SQLの周囲には、50年かけて構築された巨大なツールエコシステムが存在する。

BIツール（Tableau、Looker、Metabase）はSQLでデータソースに接続する。ETLツール（dbt、Airbyte、Fivetran）はSQLで変換処理を定義する。ORM（ActiveRecord、SQLAlchemy、Prisma）はSQLを生成する。マイグレーションツール（Flyway、Liquibase）はSQLでスキーマ変更を管理する。モニタリングツール（pganalyze、Datadog Database Monitoring）はSQLクエリのパフォーマンスを解析する。

これらのツールはすべて、SQLという共通のインターフェースを前提として構築されている。新しいデータベースがSQLに対応するだけで、これらのツールとの互換性が自動的に得られる。逆に、SQLに対応しないデータベースは、これらのツールを一から構築し直さなければならない。

dbt（data build tool）は特に象徴的だ。2016年に登場したdbtは、SQLだけでデータ変換のパイプラインを構築するツールだ。ELT（Extract, Load, Transform）のTransformをSQLで記述する。dbtの成功は、「SQLこそがデータ変換の最適な言語である」という宣言に他ならない。

```
SQLエコシステムの広がり

                    ┌─────────────┐
                    │ BIツール     │
                    │ Tableau,     │
                    │ Looker,      │
                    │ Metabase     │
                    └──────┬──────┘
                           │ SQL
┌──────────┐   SQL   ┌────▼────┐   SQL   ┌──────────┐
│ ORM      ├────────►│         │◄────────┤ ETL/ELT  │
│ Active   │         │  SQL    │         │ dbt,     │
│ Record,  │         │  対応DB │         │ Airbyte  │
│ Prisma   │         │         │         │          │
└──────────┘         └────┬────┘         └──────────┘
                          │ SQL
                    ┌─────▼──────┐
                    │ マイグレー │
                    │ ション     │
                    │ Flyway,    │
                    │ Liquibase  │
                    └────────────┘

→ 新しいDBがSQLに対応するだけで
  このエコシステム全体と接続できる
```

---

## 5. SQLの代替が失敗した理由

SQLが不死である要因を4つ挙げた。だが反対側——SQLを代替しようとした言語——の視点からも考える必要がある。

### QUEL——技術的に優れていた敗者

SQLの最大のライバルは、1976年にUC BerkeleyのMichael StonebrakerとEugene WongがIngresプロジェクトで開発したQUELだ。

QUELはタプル関係論理（Tuple Relational Calculus）に基づいており、多くのデータベース研究者がSQLよりも理論的に洗練された言語だと評価していた。QUELは範囲変数を使ってテーブルを参照し、retrieve、append、replace、deleteという一貫した構文でデータを操作する。

```
QUEL vs SQL: 同じクエリの比較

QUEL:
  range of e is employees
  retrieve (e.name, e.salary)
  where e.department = "Engineering"
  sort by e.salary desc

SQL:
  SELECT name, salary
  FROM employees
  WHERE department = 'Engineering'
  ORDER BY salary DESC;
```

QUELは構文が一貫しており、NULL処理もSQLより直感的だった。Berkeley大学のチームにはSQLより長い時間をかけてQUELを洗練する余裕があり、多くの専門家がQUELをSQLに対する技術的に優れた代替と見なしていた。

だがQUELは敗北した。決定的だったのは、1986年のANSI SQL標準化だ。SQLが業界標準になった瞬間、QUELは「非標準の方言」になった。データベースベンダーはSQL対応を優先し、QUELをサポートする動機を失った。Ingres自体も1990年代にSQL対応に移行した。

技術的優位性だけでは、標準化の力に勝てない。この教訓は、今日に至るまで繰り返し証明されている。

### Datalog——学術的理想の限界

1977年、フランスのトゥールーズでHerve GallaireとJack Minkerがロジックとデータベースに関するワークショップを開催した。このイベントから生まれた研究潮流が、Datalogだ。

Datalogは論理プログラミングとデータベースの統合を目指し、Prologに似た宣言的な構文でクエリを記述する。再帰クエリの表現はSQLよりも自然であり、プログラム分析やセキュリティポリシーの記述に適している。

だがDatalogは、汎用的なデータベースクエリ言語としては普及しなかった。理由は明確だ。学習曲線が急であること。論理プログラミングのパラダイムに馴染みのない開発者が大多数であること。そしてSQLが既に膨大な人的資本を持っていたこと。Datalogは現在も特定のドメイン——プログラム分析ツールのDatomicやLogicblox——で使われているが、SQLの代替にはなり得なかった。

### GraphQL——レイヤーの違い

2012年にFacebook内部でLee Byron、Dan Schafer、Nick Schrockらが開発し、2015年にオープンソース化されたGraphQLは、「SQLの代替」として語られることがある。だがこの比較は不正確だ。

GraphQLはAPI層のクエリ言語であり、データベース層のクエリ言語ではない。GraphQLはクライアントとサーバの間のデータ受け渡しを最適化するために設計された。サーバの内部では、GraphQLリゾルバがSQLクエリを生成してデータベースにアクセスするのが一般的だ。

つまりGraphQLとSQLは競合しない。レイヤーが異なる。GraphQLは「フロントエンドからバックエンドへの問い合わせ」を担い、SQLは「バックエンドからデータベースへの問い合わせ」を担う。FacebookがGraphQLを開発した動機も、SQLの代替ではなく、既存のREST APIとFQL（Facebook Query Language）の限界を解決するためだった。

### 代替が失敗する構造的理由

QUEL、Datalog、GraphQL——三者三様の言語が、それぞれの理由でSQLの代替に失敗した（あるいは代替を意図していなかった）。これらの事例から浮かび上がるパターンは何か。

第一に、**標準化の壁**。QUELは技術的に優れていたが、SQLの標準化によって駆逐された。新しい言語がSQLを代替するには、ANSI/ISO標準に匹敵する業界横断的な合意形成が必要だ。

第二に、**人的資本の慣性**。数百万人のSQL開発者を、新しい言語に移行させるコストは莫大だ。Datalogが普及しなかった主因はここにある。

第三に、**エコシステムの引力**。50年かけて構築されたSQLツールエコシステムは、新しい言語にとっての参入障壁だ。新しいクエリ言語を採用するということは、BIツール、ETLツール、ORM、モニタリングツール——これらすべてを新しい言語に対応させるということを意味する。

SQLを殺すには、SQLより技術的に優れているだけでは足りない。標準化し、数百万人に学ばせ、エコシステムを再構築しなければならない。その壁は、おそらくどんな言語にとっても高すぎる。

---

## 6. ハンズオン: モダンSQLの力を体験する

SQLが50年間生き残った理由の一つは、言語としての表現力が進化し続けていることだ。今回のハンズオンでは、モダンSQL機能——ウィンドウ関数、再帰CTE、JSONB操作——を使って「SQLだけでここまでできる」ことを体験する。Docker環境で完結するため、外部サービスへの登録は不要だ。

### 演習概要

1. PostgreSQL 17をDockerで起動し、テストデータを投入する
2. ウィンドウ関数で「部署別のランキング」「移動平均」を計算する
3. 再帰CTEで「組織の階層構造」を走査する
4. JSONB操作で「半構造化データ」をSQLで問い合わせる
5. 複数のモダンSQL機能を組み合わせた実践的なクエリを書く

### 環境構築

```bash
# handson/database-history/22-sql-immortality/setup.sh を実行
bash setup.sh
```

### 演習1: テストデータの準備

```bash
# PostgreSQL 17をDockerで起動
docker run -d \
  --name pg-modern-sql \
  -e POSTGRES_PASSWORD=handson \
  -e POSTGRES_DB=moderndb \
  -p 5432:5432 \
  postgres:17

# 起動を待機
sleep 3
```

```bash
# テストデータを投入
docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- 従業員テーブル（階層構造付き）
CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  department TEXT NOT NULL,
  salary INTEGER NOT NULL,
  manager_id INTEGER REFERENCES employees(id),
  hired_date DATE NOT NULL
);

INSERT INTO employees (name, department, salary, manager_id, hired_date) VALUES
('田中太郎', 'Engineering', 1200000, NULL,  '2010-04-01'),
('鈴木花子', 'Engineering', 950000,  1,     '2015-06-15'),
('佐藤次郎', 'Engineering', 880000,  1,     '2016-09-01'),
('高橋美咲', 'Engineering', 820000,  2,     '2019-04-01'),
('伊藤健太', 'Engineering', 780000,  2,     '2020-07-01'),
('渡辺由美', 'Sales',       900000,  NULL,  '2012-04-01'),
('山本誠一', 'Sales',       750000,  6,     '2017-10-01'),
('中村あい', 'Sales',       720000,  6,     '2018-04-01'),
('小林拓也', 'Sales',       680000,  7,     '2021-04-01'),
('加藤恵理', 'Marketing',   850000,  NULL,  '2013-04-01'),
('吉田翔太', 'Marketing',   700000,  10,    '2018-09-01'),
('山田奈々', 'Marketing',   650000,  10,    '2022-04-01');

-- 月次売上テーブル
CREATE TABLE monthly_sales (
  id SERIAL PRIMARY KEY,
  employee_id INTEGER REFERENCES employees(id),
  year_month DATE NOT NULL,
  amount INTEGER NOT NULL
);

INSERT INTO monthly_sales (employee_id, year_month, amount)
SELECT
  e.id,
  date_trunc('month', generate_series('2024-01-01'::date, '2024-12-01'::date, '1 month'))::date,
  (random() * 500000 + 100000)::integer
FROM employees e
WHERE e.department = 'Sales';

-- プロダクト情報テーブル（JSONB）
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  metadata JSONB NOT NULL
);

INSERT INTO products (name, metadata) VALUES
('PostgreSQL入門書',
 '{"category": "book", "price": 3200, "tags": ["database", "SQL", "PostgreSQL"],
   "specs": {"pages": 450, "publisher": "Tech Press", "edition": 3}}'),
('DuckDBハンドブック',
 '{"category": "book", "price": 2800, "tags": ["database", "analytics", "DuckDB"],
   "specs": {"pages": 320, "publisher": "Data Books", "edition": 1}}'),
('SQLマスターコース',
 '{"category": "course", "price": 15000, "tags": ["SQL", "database", "online"],
   "specs": {"hours": 40, "level": "intermediate", "platform": "online"}}'),
('DB設計パターン集',
 '{"category": "book", "price": 3800, "tags": ["database", "design", "patterns"],
   "specs": {"pages": 380, "publisher": "Tech Press", "edition": 2}}'),
('Redis実践ガイド',
 '{"category": "book", "price": 2900, "tags": ["NoSQL", "Redis", "cache"],
   "specs": {"pages": 280, "publisher": "Cloud Books", "edition": 1}}');
SQL

echo "テストデータの投入が完了しました"
```

### 演習2: ウィンドウ関数——集計と個別データの共存

ウィンドウ関数はSQL:2003で導入された機能で、GROUP BYでは不可能な「集計結果と個別行の共存」を実現する。

```bash
docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- 部署内の給与ランキング
-- RANK(): 同率の場合は同じ順位、次の順位をスキップ
-- DENSE_RANK(): 同率の場合は同じ順位、次の順位はスキップしない
SELECT
  name,
  department,
  salary,
  RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank,
  DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dense_rank,
  salary - AVG(salary) OVER (PARTITION BY department) AS diff_from_avg
FROM employees
ORDER BY department, salary DESC;
SQL
```

`PARTITION BY department` が「部署ごとに」を意味し、`ORDER BY salary DESC` が「給与の高い順に」を意味する。GROUP BYと異なり、元の行はそのまま保持される。各行に対して「部署内での順位」と「部署平均との差額」が付加される。

```bash
docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- 売上の移動平均（3カ月移動平均）
SELECT
  e.name,
  ms.year_month,
  ms.amount,
  ROUND(AVG(ms.amount) OVER (
    PARTITION BY ms.employee_id
    ORDER BY ms.year_month
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  )) AS moving_avg_3m,
  SUM(ms.amount) OVER (
    PARTITION BY ms.employee_id
    ORDER BY ms.year_month
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_total
FROM monthly_sales ms
JOIN employees e ON e.id = ms.employee_id
WHERE e.name = '山本誠一'
ORDER BY ms.year_month;
SQL
```

`ROWS BETWEEN 2 PRECEDING AND CURRENT ROW` は「現在行を含む直近3行」のウィンドウフレームを定義する。これにより、ExcelやPythonのpandasで行うような移動平均の計算が、SQLだけで完結する。

### 演習3: 再帰CTE——階層構造の走査

再帰CTE（Common Table Expression）はSQL:1999で導入された。組織図やディレクトリ構造のような再帰的なデータ構造を、SQLだけで走査できる。

```bash
docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- 組織階層の展開: 各従業員のマネジメントチェーンを辿る
WITH RECURSIVE org_tree AS (
  -- ベースケース: トップレベル（manager_idがNULL）の従業員
  SELECT
    id,
    name,
    department,
    manager_id,
    name AS management_chain,
    0 AS depth
  FROM employees
  WHERE manager_id IS NULL

  UNION ALL

  -- 再帰ステップ: 各マネージャーの部下を辿る
  SELECT
    e.id,
    e.name,
    e.department,
    e.manager_id,
    ot.management_chain || ' > ' || e.name,
    ot.depth + 1
  FROM employees e
  INNER JOIN org_tree ot ON e.manager_id = ot.id
)
SELECT
  repeat('  ', depth) || name AS org_chart,
  department,
  management_chain,
  depth
FROM org_tree
ORDER BY department, management_chain;
SQL
```

`WITH RECURSIVE` は再帰的なクエリを定義する。ベースケース（`WHERE manager_id IS NULL`）から始まり、再帰ステップで部下を辿る。ループの終了条件は「結合する行がなくなったとき」だ。

```bash
docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- 各マネージャーの直属の部下数と、配下全体の人数
WITH RECURSIVE subordinates AS (
  SELECT
    id,
    name,
    manager_id,
    id AS root_manager_id
  FROM employees
  WHERE manager_id IS NOT NULL

  UNION ALL

  SELECT
    e.id,
    e.name,
    e.manager_id,
    s.root_manager_id
  FROM employees e
  INNER JOIN subordinates s ON e.manager_id = s.id
)
SELECT
  m.name AS manager,
  m.department,
  COUNT(DISTINCT CASE WHEN e.manager_id = m.id THEN e.id END) AS direct_reports,
  COUNT(DISTINCT s.id) AS total_subordinates
FROM employees m
LEFT JOIN employees e ON e.manager_id = m.id
LEFT JOIN subordinates s ON s.root_manager_id = m.id
WHERE EXISTS (SELECT 1 FROM employees sub WHERE sub.manager_id = m.id)
GROUP BY m.id, m.name, m.department
ORDER BY total_subordinates DESC;
SQL
```

### 演習4: JSONB操作——半構造化データのクエリ

PostgreSQLのJSONB型は、SQLの中でJSONデータを直接操作できる。NoSQLデータベースに頼らずとも、半構造化データをリレーショナルデータベースで扱える。

```bash
docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- JSONB内のネストしたフィールドを抽出
SELECT
  name,
  metadata->>'category' AS category,
  (metadata->>'price')::integer AS price,
  metadata->'specs'->>'publisher' AS publisher,
  metadata->'specs'->>'pages' AS pages
FROM products
WHERE metadata->>'category' = 'book'
ORDER BY (metadata->>'price')::integer DESC;
SQL
```

`->>` はJSONフィールドをテキストとして抽出し、`->` はJSONオブジェクトとして抽出する。ネストしたフィールドには `->` を連鎖させてアクセスする。

```bash
docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- JSONB配列の展開と検索
-- tags配列に 'database' を含む商品を検索
SELECT name, metadata->>'price' AS price, metadata->'tags' AS tags
FROM products
WHERE metadata->'tags' @> '"database"'::jsonb;

-- tags配列を展開して、タグごとの商品数を集計
SELECT
  tag,
  COUNT(*) AS product_count,
  ROUND(AVG((metadata->>'price')::integer)) AS avg_price
FROM products, jsonb_array_elements_text(metadata->'tags') AS tag
GROUP BY tag
ORDER BY product_count DESC, avg_price DESC;
SQL
```

`@>` は「含む」演算子で、JSONB配列に特定の値が含まれるかを検査する。`jsonb_array_elements_text()` はJSONB配列の各要素を行に展開する関数だ。これらの機能により、MongoDBで行うようなドキュメント検索が、PostgreSQLのSQL内で完結する。

### 演習5: 複合クエリ——モダンSQL機能の組み合わせ

最後に、ウィンドウ関数、CTE、JSONB操作を組み合わせた実践的なクエリを書く。

```bash
docker exec -i pg-modern-sql psql -U postgres -d moderndb << 'SQL'
-- 部署ごとの給与分析レポート
-- CTE + ウィンドウ関数 + 集約を組み合わせる
WITH dept_stats AS (
  SELECT
    department,
    name,
    salary,
    hired_date,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank,
    PERCENT_RANK() OVER (PARTITION BY department ORDER BY salary) AS percentile,
    salary - LAG(salary) OVER (PARTITION BY department ORDER BY hired_date) AS salary_gap_from_prev_hire,
    FIRST_VALUE(name) OVER (
      PARTITION BY department ORDER BY salary DESC
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS highest_earner
  FROM employees
)
SELECT
  department,
  name,
  salary,
  salary_rank,
  ROUND(percentile::numeric, 2) AS percentile,
  salary_gap_from_prev_hire,
  highest_earner,
  CASE
    WHEN salary_rank = 1 THEN 'Top Earner'
    WHEN percentile >= 0.75 THEN 'Above Average'
    WHEN percentile >= 0.25 THEN 'Average'
    ELSE 'Below Average'
  END AS salary_tier
FROM dept_stats
ORDER BY department, salary_rank;
SQL
```

このクエリは一つのSQL文で以下を行っている。部署内の給与ランキング。パーセンタイル計算。前の入社者との給与差。部署の最高給与者の特定。給与ティアの分類。これらすべてが、SQLの表現力だけで完結する。

### 後片付け

```bash
docker stop pg-modern-sql && docker rm pg-modern-sql
```

---

## 7. SQLの不死は永遠か

第22回を振り返ろう。

**SQLは50年間で10回の標準改訂を重ね、時代の技術トレンドを取り込み続けてきた。** SQL-86の標準化に始まり、SQL:2003のウィンドウ関数、SQL:2016のJSON対応、SQL:2023のProperty Graph Queries（SQL/PGQ）——SQLは競合技術を「標準の中に吸収する」という進化戦略で生き延びてきた。

**SQLを殺そうとしたすべての試みは、最終的にSQLへの回帰で終わった。** GoogleのMapReduceはDremel/BigQueryでSQLに回帰した。NoSQLの「No SQL」は「Not Only SQL」に転換した。Apache SparkはSpark SQLを追加した。Presto/Trinoは分散データに対するSQLクエリエンジンとして登場した。あらゆるシステムが、SQLインターフェースを採用するか、SQLに回帰した。

**SQLが不死である構造的要因は4つある。** (1) 宣言的クエリの普遍性——「What」と「How」の分離が技術変化を吸収する。(2) 関係代数という数学的基盤——クエリ最適化の正当性が数学的に保証される。(3) 膨大な人的資本——開発者の54%がSQLを使える（Stack Overflow 2024年調査）。(4) ツールエコシステム——BIツール、ETLツール、ORMの50年分の蓄積がある。

**SQLの代替はすべて失敗した。** QUELは技術的に優れていたが標準化の力に敗れた。Datalogは学術的に洗練されていたが人的資本の壁を越えられなかった。GraphQLはそもそもレイヤーが異なる言語だった。

冒頭の問いに戻ろう。「NoSQLブームでも、NewSQLでも、AI時代でも、なぜSQLは生き残り続けるのか？」

私の答えはこうだ。SQLが不死である理由は、その本質が「データへの問いかけの言語」だからだ。データの保管場所がファイルシステムであれ、リレーショナルデータベースであれ、分散クラスタであれ、データレイクであれ——「何が知りたいかを宣言する」という行為そのものは変わらない。SQLは、この不変の行為を表現する言語として、50年間機能し続けてきた。

だが、一つだけ付け加えておきたい。「50年生き残った」ことは、「次の50年も生き残る」ことの保証にはならない。

SQLの限界は確かに存在する。グラフの走査はCypherの方が自然に書ける。時系列データの集約はPromQLのような専用言語の方が簡潔に書ける。機械学習パイプラインの定義はSQLの守備範囲ではない。SQL:2023でProperty Graph Queriesが標準化されたとはいえ、グラフデータベースの表現力をSQLが完全に包含できるかは未知数だ。

また、LLM（大規模言語モデル）の進化が、SQLの人的資本の優位性を揺るがす可能性もある。自然言語で「先月の売上上位10の商品を教えて」と聞けば、LLMがSQLを自動生成する世界が既に到来している。SQLを「書ける」ことの価値が相対的に下がったとき、SQLの最大の強みの一つが弱体化する。

SQLの不死は、構造的に強固だが、永遠を保証するものではない。技術の歴史は、「永遠に続く」と思われた支配がある日覆る事例に満ちている。COBOLがそうであったように。

次回「データモデリングの本質——正規化、非正規化、そしてその先」では、この連載の集大成として、24年分のデータモデリング経験を体系化する。正規化も非正規化も万能ではない。イベントソーシングもCQRSも銀の弾丸ではない。データモデリングの「正解」は存在するのか。あなたのプロジェクトに最適なデータモデルを選ぶための「判断基準」を、歴史の中に探る。

---

### 参考文献

- Chamberlin, D. and Boyce, R., "SEQUEL: A Structured English Query Language", IBM, 1974. <https://en.wikipedia.org/wiki/Donald_D._Chamberlin>
- ISO/IEC 9075, "Information technology — Database languages — SQL", SQL-86 (1986) ~ SQL:2023 (2023). <https://blog.ansi.org/ansi/sql-standard-iso-iec-9075-2023-ansi-x3-135/>
- Melnik, S. et al., "Dremel: Interactive Analysis of Web-Scale Datasets", VLDB 2010. <https://research.google/pubs/dremel-interactive-analysis-of-web-scale-datasets/>
- Melnik, S. et al., "Dremel: A Decade of Interactive SQL Analysis at Web Scale", VLDB 2020. <https://www.vldb.org/pvldb/vol13/p3461-melnik.pdf>
- Eisentraut, P., "SQL:2023 is finished: Here is what's new", 2023. <http://peter.eisentraut.org/blog/2023/04/04/sql-2023-is-finished-here-is-whats-new>
- Stack Overflow Developer Survey 2024. <https://survey.stackoverflow.co/2024/technology>
- Stonebraker, M. and Wong, E., "The Design and Implementation of INGRES", UC Berkeley, 1976. <https://www.cs.cmu.edu/~natassa/courses/15-721/papers/p189-stonebraker.pdf>
- Facebook Engineering, "GraphQL: A data query language", 2015. <https://engineering.fb.com/2015/09/14/core-infra/graphql-a-data-query-language/>
- Holistics, "A Short Story About SQL's Biggest Rival". <https://www.holistics.io/blog/quel-vs-sql/>
- Wikipedia, "Presto (SQL query engine)". <https://en.wikipedia.org/wiki/Presto_(SQL_query_engine)>
- Wikipedia, "Apache Spark". <https://en.wikipedia.org/wiki/Apache_Spark>
- Wikipedia, "NoSQL". <https://en.wikipedia.org/wiki/NoSQL>

---

**次回予告：** 第23回「データモデリングの本質——正規化、非正規化、そしてその先」では、24年分のデータモデリング経験を集大成する。Coddの正規化理論（1970年）、Peter ChenのERモデル（1976年）、Ralph Kimballのディメンショナルモデリング（1996年）、Eric Evansのドメイン駆動設計（2003年）、そしてイベントソーシングとCQRS——データモデリングの歴史的系譜を辿りながら、「正解はない、だが判断基準はある」という結論に至る道筋を語る。
