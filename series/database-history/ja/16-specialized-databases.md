# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第16回：時系列DB, グラフDB——専門特化の進化

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 「汎用データベースでは足りない」と気づく瞬間——IoTプロジェクトでPostgreSQLのクエリが破綻した体験
- RRDtool（1999年）からInfluxDB（2013年）、TimescaleDB（2017年）、Prometheus（2012年）に至る時系列データベースの系譜
- 時系列データの本質的特性——追記支配、時間ベースのクエリ、ダウンサンプリング、圧縮
- Neo4j（2007年）が生み出したプロパティグラフモデルとIndex-Free Adjacencyの設計思想
- Cypher（2011年）からGQL（ISO/IEC 39075:2024）へ至るグラフクエリ言語の標準化
- PostgreSQL（再帰CTE）vs Neo4j（Cypher）で「友達の友達」検索を比較するハンズオン

---

## 1. PostgreSQLが悲鳴を上げた日

2018年頃、私はあるIoTプロジェクトに携わっていた。

工場の製造ラインに設置されたセンサーから、温度、湿度、振動、電力消費量といったデータが1秒間隔で送られてくる。センサーは200台以上。つまり1秒あたり200行以上のINSERTが発生する。1日で約1,700万行。1か月で約5億行。

最初、私たちはPostgreSQLに全データを格納していた。PostgreSQLは信頼できるデータベースだ。第8回で語ったように、私はPostgreSQLの拡張性と堅牢性を長年信頼してきた。テーブル設計は教科書通りに正規化し、タイムスタンプにインデックスを張り、パーティショニングも設定した。

最初の1か月は問題なかった。だが3か月を過ぎたあたりから、集計クエリが急激に遅くなり始めた。

「過去24時間のセンサーAの平均温度を5分間隔で集計する」——このクエリが、データ量の増加とともに数秒から数十秒に膨れ上がった。ダッシュボードはタイムアウトを起こし、ユーザーからの苦情が相次いだ。

原因はわかっていた。PostgreSQLは汎用のリレーショナルデータベースであり、時系列データのワークロードに特化した最適化を持っていない。書き込みはすべてMVCCのメカニズムに従い、不要になった古い行のバキュームが必要だ。だが時系列データは追記のみで更新はない。MVCCの恩恵を受けないまま、そのオーバーヘッドだけを負っている。インデックスはB-Treeで、時系列データの時間範囲クエリには効率的だが、大量の集計処理はフルスキャンに近い。

先輩エンジニアに相談したところ、InfluxDBを勧められた。「時系列データなら時系列データベースを使え」と。

InfluxDBに移行した結果は劇的だった。同じ集計クエリが数十秒から数百ミリ秒に改善された。書き込みスループットも桁違いに向上した。古いデータは自動的にダウンサンプリングされ、ストレージの増加も抑制された。

あのとき私は「汎用データベースでは足りない」というシンプルだが重要な教訓を得た。PostgreSQLが悪いのではない。データの性質に合わないツールを使っていたのだ。

あなたのプロジェクトのデータベースは、そのデータの性質に合っているだろうか。すべてのデータをPostgreSQLやMySQLに入れていないだろうか。データの性質を見つめ直すと、別の選択肢が見えてくるかもしれない。

---

## 2. 時系列データベースの系譜——RRDtoolからPrometheusまで

### RRDtool——固定サイズのデータ格納という発想

時系列データ専用のストレージという発想の先駆者は、1999年にTobias Oetikerが公開したRRDtool（Round Robin Database Tool）だ。

OetikerはRRDtool以前に、MRTG（Multi Router Traffic Grapher、1995年）というネットワークトラフィック監視ツールを開発していた。MRTGはSNMPでルータからトラフィックデータを収集し、グラフ化する。だがMRTGのログファイルは時間とともに肥大化し、大規模なネットワーク監視では性能問題が顕在化した。

RRDtoolはこの問題に対して、巧妙な設計を採用した。Round Robin Database——円形バッファ型のデータベースだ。

```
RRDtoolの Round Robin Archive（RRA）の概念

┌─────────────────────────────────────────────────┐
│  高解像度（5分間隔、288スロット = 24時間分）      │
│  ┌───┬───┬───┬───┬───┬ ─ ─ ┬───┐               │
│  │ 1 │ 2 │ 3 │ 4 │ 5 │     │288│               │
│  └───┴───┴───┴───┴───┴ ─ ─ ┴───┘               │
│  → 最新24時間は5分単位で保持                     │
│  → 288スロットを超えると最古のデータに上書き      │
│                                                 │
│  中解像度（30分間隔、672スロット = 14日分）        │
│  ┌───┬───┬───┬───┬ ─ ─ ┬───┐                    │
│  │ 1 │ 2 │ 3 │ 4 │     │672│                    │
│  └───┴───┴───┴───┴ ─ ─ ┴───┘                    │
│  → 過去14日は30分平均で保持                      │
│                                                 │
│  低解像度（2時間間隔、732スロット = 約2か月分）    │
│  ┌───┬───┬───┬ ─ ─ ┬───┐                        │
│  │ 1 │ 2 │ 3 │     │732│                        │
│  └───┴───┴───┴ ─ ─ ┴───┘                        │
│  → 過去2か月は2時間平均で保持                    │
└─────────────────────────────────────────────────┘

ファイルサイズは常に一定（事前に計算可能）
→ ディスク容量の計画が立てやすい
→ ファイルの断片化が起きない
```

RRDtoolの設計が示した重要な洞察が二つある。

第一に、時系列データにおける「データの鮮度」と「解像度」のトレードオフだ。直近のデータは高解像度で必要だが、古いデータは集約された低解像度で十分だ。これは後のすべての時系列データベースが継承する設計思想となった。

第二に、固定サイズのストレージだ。ファイルが際限なく膨張しないことで、運用上の予測可能性が得られる。ただし、これは柔軟性の犠牲でもある。RRDtoolでは事前にデータの解像度とRetention期間を定義しなければならず、後から変更することは困難だった。

RRDtoolはNagios、Cacti、Ganglia、Graphiteといった監視ツールのデータストレージとして広く使われた。2010年代に入るまで、ネットワーク監視とサーバ監視における事実上の標準だった。

### Prometheus——Googleの監視思想をオープンソースに

2012年、SoundCloudで二人の元Google SRE——Matt ProudとJulius Volz——がPrometheusの開発を開始した。

GoogleにはBorgmon（Borg Monitoring）という社内監視システムがあった。BorgmonはGoogleのクラスタ管理システムBorgと密に統合され、プルベースのメトリクス収集、多次元データモデル、独自のクエリ言語を備えていた。ProudとVolzは、このGoogleの監視思想をオープンソースの世界に持ち込もうとした。

Prometheusの設計における革新的な選択が「プルモデル」だ。従来の監視システム（Nagios、Zabbixなど）は、監視対象がメトリクスを監視サーバにプッシュする「プッシュモデル」を採用していた。Prometheusは逆に、監視サーバが定期的に監視対象のHTTPエンドポイントにアクセスしてメトリクスを「プル」する。

```
プッシュモデル vs プルモデル

■ プッシュモデル（Nagios, StatsD, InfluxDB等）
  ┌───────┐         ┌──────────┐
  │App 1  │──push──→│          │
  │App 2  │──push──→│ 監視     │
  │App 3  │──push──→│ サーバ   │
  └───────┘         └──────────┘
  → アプリケーション側にクライアント設定が必要
  → 監視サーバの所在をアプリケーションが知る必要がある
  → アプリケーションが落ちると、メトリクスが消失する

■ プルモデル（Prometheus）
  ┌──────────┐         ┌───────┐
  │          │──pull──→│App 1  │  /metrics エンドポイント
  │Prometheus│──pull──→│App 2  │  /metrics エンドポイント
  │          │──pull──→│App 3  │  /metrics エンドポイント
  └──────────┘         └───────┘
  → 監視サーバが能動的にメトリクスを収集する
  → アプリケーションはメトリクスを公開するだけ
  → 監視対象の死活もプル失敗で検出できる
```

2015年1月にパブリックアナウンスされ、Hacker News で1位を獲得した。2016年、PrometheusはKubernetesに次ぐCNCF（Cloud Native Computing Foundation）の第2のプロジェクトとして採用された。Kubernetesとの親和性が高く、クラウドネイティブ時代の監視の事実上の標準となっている。

PrometheusはTSDB（時系列データベース）を内蔵しているが、長期保存には別途ストレージが必要だ。この限界に対応するために、Thanos、Cortex、Mimir（Grafana Labs）といったプロジェクトが生まれた。Prometheus単体は「監視のための時系列DB」であり、汎用の時系列データストアではない。

### InfluxDB——汎用時系列データベースの台頭

2013年、Paul DixはInfluxDBをオープンソースとして公開した。

DixはもともとErrplaneという会社を設立し、アプリケーションのパフォーマンス監視サービスを開発していた。その過程で、既存のデータベース（PostgreSQL、MongoDB、Cassandraなど）が時系列データのワークロードに適していないことを痛感した。汎用データベースは「行の更新」を前提に設計されているが、時系列データは「追記のみ」だ。この根本的なワークロードの違いに最適化されたデータベースが必要だ——そう考えてInfluxDBを開発した。

InfluxDBの設計上の特徴は以下の通りだ。

独自のストレージエンジン（TSM: Time-Structured Merge Tree）を採用し、時系列データの書き込みと圧縮に最適化した。InfluxQL（SQL風のクエリ言語）を提供し、RDB経験者にとっての学習コストを下げた。Retention Policy（保持ポリシー）を組み込み、古いデータの自動削除やダウンサンプリングをデータベースレベルでサポートした。

InfluxDB 2.0ではFluxという関数型のクエリ言語に移行したが、3.x系では再びSQLベースのクエリに回帰している。この揺れ動きは、第22回で取り上げる「SQLの不死性」の一つの傍証でもある。

### TimescaleDB——PostgreSQLの上に建てる

2017年、Ajay KulkarniとMichael Freedman（プリンストン大学教授）がTimescaleDBを公開した。

TimescaleDBのアプローチはInfluxDBとは対照的だ。ゼロから時系列専用のデータベースを構築するのではなく、PostgreSQLの拡張（Extension）として時系列機能を追加する。

```
InfluxDB vs TimescaleDB のアプローチの違い

■ InfluxDB: 専用データベース
  ┌─────────────────────────┐
  │     InfluxDB             │
  │  ┌───────────────────┐  │
  │  │ 独自ストレージエンジン│  │
  │  │ (TSM Tree)         │  │
  │  │ 独自クエリ言語      │  │
  │  │ 独自プロトコル      │  │
  │  └───────────────────┘  │
  └─────────────────────────┘
  → 時系列に完全最適化
  → 既存のSQLツールは使えない（一部互換性あり）
  → PostgreSQLのエコシステムとは分離

■ TimescaleDB: PostgreSQL拡張
  ┌─────────────────────────────┐
  │     PostgreSQL               │
  │  ┌───────────────────────┐  │
  │  │  TimescaleDB Extension │  │
  │  │  ・ハイパーテーブル      │  │
  │  │  ・時間ベースの           │  │
  │  │    自動パーティショニング  │  │
  │  │  ・チャンク圧縮           │  │
  │  │  ・連続集約               │  │
  │  └───────────────────────┘  │
  │  PostgreSQLの全機能が使える   │
  │  ・SQL（JOIN, CTE, Window）  │
  │  ・拡張（PostGIS, pgvector） │
  │  ・ツール（pg_dump, psql）   │
  └─────────────────────────────┘
  → 完全なSQL互換
  → 既存のPostgreSQLツールがそのまま使える
  → 時系列以外のデータも同じDBで管理できる
```

TimescaleDBの核心は「ハイパーテーブル」だ。テーブルを作成すると、TimescaleDBはそのテーブルを内部的に時間ベースの「チャンク」に自動分割する。古いチャンクは高効率に圧縮され、最新のチャンクは書き込みに最適化される。この自動パーティショニングにより、ユーザーは通常のPostgreSQLテーブルとして時系列データを扱いながら、時系列に最適化されたストレージの恩恵を受けられる。

TimescaleDBのアプローチは「既存のエコシステムを活かす」という戦略的判断だ。PostgreSQLを使っている組織は、追加のインフラなしに時系列機能を導入できる。既存のSQLクエリ、バックアップ手順、監視ツールがそのまま使える。この「移行コストの低さ」が、InfluxDBとは異なる顧客層を獲得した。

---

## 3. グラフデータベース——「関係」が主役になるとき

### 関係の時代の到来

ここまでこの連載で取り上げてきたデータベースは、すべて「エンティティ」が主役だった。ユーザー、注文、商品、メトリクス——データの基本単位は「もの」であり、「もの同士の関係」は外部キーやJOINで二次的に表現されていた。

だが、ある種のデータにおいては、関係こそがデータの本質である場面がある。

ソーシャルネットワーク。「AさんがBさんをフォローしている」「BさんとCさんは友達」「CさんはDさんの投稿にいいねした」——このデータにおいて最も重要な情報は、ユーザー個々の属性ではなく、ユーザー間の「関係」だ。

知識グラフ。「東京はJapanの首都である」「Japanはアジアに位置する」「アジアは大陸である」——エンティティの属性よりも、エンティティ間の関係のネットワークが知識を構成する。

不正検知。「口座Aから口座Bへの送金」「口座Bから口座Cへの送金」「口座Cから口座Aへの送金」——循環する送金パターンを検出するには、取引の「グラフ構造」を辿る必要がある。

こうしたユースケースにおいて、RDBのJOINは根本的な限界にぶつかる。「友達の友達の友達」を検索するクエリを考えてみよう。

```sql
-- PostgreSQLで「友達の友達の友達」を検索する
-- 3段階のJOINが必要
SELECT DISTINCT f3.friend_id
FROM friendships f1
JOIN friendships f2 ON f1.friend_id = f2.user_id
JOIN friendships f3 ON f2.friend_id = f3.user_id
WHERE f1.user_id = 1
  AND f3.friend_id != 1;
```

3段階のJOINだ。深さが増えるたびにJOINが追加され、計算量は指数関数的に増大する。100万人のユーザーがそれぞれ100人の友達を持つ場合、3段階のJOINは最大で100 x 100 x 100 = 100万行の中間結果を生成しうる。これがRDBでグラフ構造のクエリが遅い根本的理由だ。

### Neo4j——プロパティグラフの誕生

2007年1月23日、Emil Eifrem、Johan Svensson、Peter Neubauerはスウェーデンのマルメでグラフデータベース企業Neo Technology（後のNeo4j Inc.）を設立し、Neo4jをGPLでオープンソース化した。

Eifremがグラフデータベースの着想を得たのは2000年のことだ。ムンバイ行きのフライト中、Enterprise Content Management（ECM）システムの開発でRDBの限界に直面していたEifremは、機内のナプキンにプロパティグラフモデルの原型をスケッチした——と本人が後に語っている。

Neo4jが確立したプロパティグラフモデルは以下の構造を持つ。

```
プロパティグラフモデル

  ┌──────────────┐     FOLLOWS      ┌──────────────┐
  │  Node        │─────────────────→│  Node        │
  │  (:Person)   │                  │  (:Person)   │
  │  name: Alice │                  │  name: Bob   │
  │  age: 30     │                  │  age: 28     │
  └──────────────┘                  └──────┬───────┘
         │                                 │
         │  LIKES                          │  WROTE
         ▼                                 ▼
  ┌──────────────┐                  ┌──────────────┐
  │  Node        │                  │  Node        │
  │  (:Post)     │                  │  (:Post)     │
  │  title: ...  │                  │  title: ...  │
  │  date: ...   │                  │  date: ...   │
  └──────────────┘                  └──────────────┘

  構成要素:
  ・ノード（Node）: エンティティ。ラベル（:Person, :Post）で分類
  ・リレーションシップ（Relationship）: 方向付きの関係（FOLLOWS, LIKES）
  ・プロパティ（Property）: ノードとリレーションシップに付与される属性
  ・ラベル（Label）: ノードの分類（RDBのテーブルに相当）
```

### Index-Free Adjacency——グラフデータベースの核心技術

Neo4jの性能の秘密は、Index-Free Adjacency（インデックスフリー隣接）というストレージ設計にある。

```
Index-Free Adjacency vs RDBのJOIN

■ RDB（PostgreSQL）でのリレーションシップ探索
  users テーブル → friendships テーブル → users テーブル
       │               │                    │
       └── B-Tree ──→ JOIN ←── B-Tree ──────┘
            Index       (O(log n))        Index

  深さ D のグラフ探索 = D 回のJOIN
  各JOINはインデックスルックアップ O(log n) を要する
  全体: O(D × log n)
  → データ量 n が増えると遅くなる

■ Neo4j でのリレーションシップ探索
  Node A ──→ Relationship ──→ Node B
       直接参照           直接参照
       (ポインタ)         (ポインタ)

  隣接ノードへのアクセス = O(1)
  深さ D のグラフ探索 = D 回のポインタ辿り
  全体: O(D × k)  (k = 各ノードの平均接続数)
  → データ量 n が増えても速度は変わらない
```

RDBではJOINのたびにインデックスを参照する。データ量が増えればインデックスのツリーが深くなり、ルックアップに時間がかかる。O(log n)は効率的だが、グラフの深さに比例してJOINが増え、全体のコストは急増する。

Neo4jでは、各ノードが隣接するノードへの直接参照（物理的なポインタ）を保持している。隣接ノードへのアクセスは常にO(1)だ。データベース全体のノード数が100万でも1億でも、隣接ノードの探索速度は変わらない。

この設計の代償は、書き込み時のオーバーヘッドだ。ノードやリレーションシップを追加するたびに、関連するノードのポインタを更新する必要がある。また、グラフ全体のスキャン（「すべてのPersonノードを取得する」など）はRDBのフルテーブルスキャンに劣る場合がある。グラフデータベースは「グラフの局所的な探索」に最適化されており、「全データの集計」には向いていない。

### Cypherクエリ言語——グラフのためのSQL

2011年、Neo4jのAndrés TaylorがCypherクエリ言語を設計した。

CypherはSQLの宣言的な性質をグラフの世界に持ち込む試みだ。SQLが「テーブルとカラム」を抽象化するように、Cypherは「ノードとリレーションシップ」を抽象化する。

```cypher
// Cypher: 「友達の友達の友達」を検索する
MATCH (alice:Person {name: 'Alice'})-[:FRIEND]->()-[:FRIEND]->()-[:FRIEND]->(fof3:Person)
WHERE fof3 <> alice
RETURN DISTINCT fof3.name

// 読み方:
// alice という :Person ノード（name が 'Alice'）から
// :FRIEND リレーションシップを3回辿って到達する :Person ノード
// ただし alice 自身は除外する
```

SQLの3段階JOINと比較してほしい。Cypherでは、パターンマッチングの構文でグラフの構造をそのまま記述できる。`()-[:FRIEND]->()` がノード間のリレーションシップを表す。深さが増えてもパターンを追加するだけだ。

2015年10月、Neo4jはopenCypherプロジェクトを立ち上げ、CypherをNeo4j固有の言語からオープン標準への道に乗せた。Oracle、Databricks、Tableauらが参加し、Cypherの仕様をオープン化した。

そして2024年4月12日、ISOはGQL（Graph Query Language）をISO/IEC 39075として正式に公開した。1987年にSQLが標準化されて以来、ISOが公開した初の新しいデータベースクエリ言語標準だ。GQLはCypherの影響を強く受けており、プロパティグラフのパターンマッチング構文を標準化した。SQLの誕生から約50年、グラフの世界にも「共通言語」が生まれたのだ。

### Amazon NeptuneとグラフDBの広がり

2017年11月、AWSはre:InventでグラフデータベースサービスAmazon Neptuneを発表した（一般提供は2018年5月）。Neptuneはプロパティグラフ（Gremlin、openCypher）とRDF（SPARQL）の両方をサポートし、フルマネージドで提供される。

NeptuneのようなマネージドサービスがグラフDBの採用障壁を下げた一方で、グラフデータベースの採用は時系列DBほど爆発的ではない。その理由は、グラフ構造のデータが必要なユースケースが、時系列データに比べて限定的だからだ。ほとんどのWebアプリケーションでは、RDBのJOINで十分な深さのリレーションシップしか扱わない。グラフDBが真に輝くのは、ソーシャルネットワーク分析、知識グラフ、不正検知、レコメンデーションエンジンといった「関係の深い探索」が必要な場面だ。

---

## 4. 「正しいデータモデルを正しいDBで」

### 汎用 vs 専門特化のトレードオフ

ここまでの議論をまとめよう。

```
データベースの選択: 汎用 vs 専門特化

                汎用DB               時系列DB            グラフDB
                (PostgreSQL等)       (InfluxDB等)        (Neo4j等)
───────────────────────────────────────────────────────────────────
データ構造      テーブル + 行         時刻 + メトリクス    ノード + 関係
主な操作        CRUD + JOIN          追記 + 範囲集計     パターン探索
書き込み        行単位更新・挿入     追記のみ（高速）    ノード/辺の追加
クエリ          SQL（万能）          時間範囲 + 集約     グラフパターン
スケール        垂直 + 水平（制限）  時間軸に沿って線形  データ量に非依存
ストレージ      行指向 or 列指向     時間順 + 圧縮       ノード + ポインタ
強み            柔軟性・整合性       時系列の書込み/集計  関係の深い探索
弱み            特化ワークロードで   時系列以外は苦手    全体集計に不向き
                効率が落ちる
───────────────────────────────────────────────────────────────────
```

専門特化型データベースを選ぶ判断基準は、「汎用DBで問題が顕在化しているかどうか」だ。

PostgreSQLで時系列データの集計クエリが遅くなっているなら、TimescaleDB（PostgreSQL拡張で移行コスト最小）またはInfluxDB（専用DBで性能最大化）を検討すべきだ。RDBのJOINが5段階以上にネストし、クエリが複雑化しているなら、Neo4jを検討すべきだ。

逆に、PostgreSQLで問題なく動いているワークロードを「流行りだから」という理由で専門特化DBに移行する必要はない。専門特化DBの導入は、運用するデータベースの種類が増えることを意味する。バックアップ、監視、障害対応、セキュリティパッチ——すべてのデータベースに対して個別の知識と手順が必要になる。この運用コストを正当化できるだけの性能上のメリットがなければ、移行は割に合わない。

### ポリグロットパーシステンスという考え方

2011年頃、Martin Fowlerらが「ポリグロットパーシステンス（Polyglot Persistence）」という概念を提唱した。一つのアプリケーション内で、データの性質に応じて複数のデータベースを使い分けるという考え方だ。

```
ポリグロットパーシステンスの例

┌─────────────────────────────────────────┐
│           Webアプリケーション              │
│                                         │
│  ユーザー・注文  → PostgreSQL（RDB）      │
│  セッション      → Redis（KVS）          │
│  アクセスログ    → InfluxDB（時系列DB）   │
│  レコメンデーション→ Neo4j（グラフDB）      │
│  全文検索        → Elasticsearch         │
│  ファイル        → S3（オブジェクトストア） │
└─────────────────────────────────────────┘
```

この設計は理想的に見える。だが現実には、複数のデータベース間のデータ整合性、トランザクション管理、運用負荷という重大な課題がある。すべてのデータベースに対して専門知識を持つエンジニアが必要になり、障害時のデバッグ難易度も上がる。

私の経験から言えば、ポリグロットパーシステンスは「必要に迫られて」採用するものであり、「設計の美しさ」のために採用するものではない。最初はPostgreSQLで始め、特定のワークロードでPostgreSQLが限界を見せたときに、そのワークロードだけを専門特化DBに移行する。この段階的なアプローチが、多くの場合において最も現実的だ。

---

## 5. ハンズオン: PostgreSQL vs Neo4j、そしてTimescaleDB

今回のハンズオンでは、同じソーシャルネットワークデータをPostgreSQL（再帰CTE）とNeo4j（Cypher）で「友達の友達」検索し、性能と表現力の違いを体験する。さらにTimescaleDBで時系列データの集約クエリを実行する。

### 演習概要

1. PostgreSQLとNeo4jに同じソーシャルネットワークデータを投入する
2. 「友達の友達」検索をSQL（再帰CTE）とCypherで比較する
3. TimescaleDBでセンサーデータの時系列集約クエリを体験する

### 環境構築

```bash
# handson/database-history/16-specialized-databases/setup.sh を実行
bash setup.sh
```

### 演習1: PostgreSQLでの「友達の友達」検索

```bash
docker exec -it db-history-ep16-postgres psql -U postgres -d handson
```

```sql
-- 友達の一覧（深さ1）
SELECT u2.name AS friend
FROM friendships f
JOIN users u2 ON f.friend_id = u2.id
WHERE f.user_id = 1;

-- 友達の友達（深さ2）: JOINの連鎖
SELECT DISTINCT u3.name AS friend_of_friend
FROM friendships f1
JOIN friendships f2 ON f1.friend_id = f2.user_id
JOIN users u3 ON f2.friend_id = u3.id
WHERE f1.user_id = 1
  AND f2.friend_id != 1;

-- 再帰CTEで可変深さの探索
WITH RECURSIVE friend_graph AS (
    -- 起点: user_id = 1 (Alice)
    SELECT f.friend_id, 1 AS depth
    FROM friendships f
    WHERE f.user_id = 1

    UNION

    -- 再帰: 深さ3まで辿る
    SELECT f.friend_id, fg.depth + 1
    FROM friend_graph fg
    JOIN friendships f ON fg.friend_id = f.user_id
    WHERE fg.depth < 3
)
SELECT DISTINCT u.name, fg.depth
FROM friend_graph fg
JOIN users u ON fg.friend_id = u.id
WHERE fg.friend_id != 1
ORDER BY fg.depth, u.name;
```

### 演習2: Neo4jでの「友達の友達」検索

```bash
docker exec -it db-history-ep16-neo4j cypher-shell -u neo4j -p handsonpass
```

```cypher
// 友達の一覧（深さ1）
MATCH (alice:Person {name: 'Alice'})-[:FRIEND]->(friend:Person)
RETURN friend.name AS friend;

// 友達の友達（深さ2）
MATCH (alice:Person {name: 'Alice'})-[:FRIEND]->()-[:FRIEND]->(fof:Person)
WHERE fof <> alice
RETURN DISTINCT fof.name AS friend_of_friend;

// 可変深さの探索（深さ1〜3）
MATCH (alice:Person {name: 'Alice'})-[:FRIEND*1..3]->(reachable:Person)
WHERE reachable <> alice
RETURN DISTINCT reachable.name AS reachable_person,
       min(length(shortestPath((alice)-[:FRIEND*]->(reachable)))) AS min_depth
ORDER BY min_depth, reachable_person;
```

Cypherの `[:FRIEND*1..3]` という構文に注目してほしい。「FRIENDリレーションシップを1回から3回辿る」という意味だ。SQLの再帰CTEと比較して、はるかに直感的に可変深さの探索を記述できる。

### 演習3: TimescaleDBで時系列集約

```bash
docker exec -it db-history-ep16-postgres psql -U postgres -d handson
```

```sql
-- TimescaleDBのハイパーテーブルを確認
SELECT hypertable_name, num_chunks
FROM timescaledb_information.hypertables;

-- 直近24時間のセンサーデータを5分間隔で集約
SELECT time_bucket('5 minutes', time) AS bucket,
       sensor_id,
       AVG(temperature) AS avg_temp,
       MIN(temperature) AS min_temp,
       MAX(temperature) AS max_temp,
       COUNT(*) AS readings
FROM sensor_data
WHERE time > NOW() - INTERVAL '24 hours'
GROUP BY bucket, sensor_id
ORDER BY bucket DESC, sensor_id
LIMIT 20;

-- 連続集約（Continuous Aggregate）を使った高速集約
-- setup.shが作成済みの連続集約ビューを参照
SELECT * FROM sensor_data_hourly
ORDER BY bucket DESC
LIMIT 10;
```

`time_bucket`はTimescaleDBが提供する関数で、時間を指定した間隔に丸める。通常のPostgreSQLの`date_trunc`より柔軟で、任意の間隔（5分、15分、1時間など）を指定できる。連続集約（Continuous Aggregate）は、集計結果をマテリアライズして自動的に更新するTimescaleDB固有の機能だ。

### 後片付け

```bash
docker rm -f db-history-ep16-postgres db-history-ep16-neo4j
docker network rm db-history-ep16-net 2>/dev/null || true
```

---

## 6. データの性質を見つめよ

第16回を振り返ろう。

**時系列データベースは、追記支配・時間範囲クエリ・ダウンサンプリングという時系列データ固有の特性に最適化されている。** RRDtool（1999年）が示した「データの鮮度と解像度のトレードオフ」という設計思想は、InfluxDB（2013年）、Prometheus（2012年）、TimescaleDB（2017年）へと受け継がれた。

**グラフデータベースは、エンティティ間の「関係」が主役のデータに最適化されている。** Neo4j（2007年）が確立したプロパティグラフモデルとIndex-Free Adjacencyの設計は、RDBのJOINが指数関数的にコストが増大するグラフ探索を、O(1)の隣接ノードアクセスで解決する。

**Cypher（2011年）はグラフのためのSQLを目指し、2024年にGQL（ISO/IEC 39075）として国際標準化された。** 1987年のSQL以来、ISOが公開した初の新しいデータベースクエリ言語標準だ。

**専門特化型データベースは「銀の弾丸」ではなく「正しい道具」だ。** 導入の判断基準は「汎用DBで問題が顕在化しているかどうか」であり、「流行り」ではない。ポリグロットパーシステンスは理想的に見えるが、運用コストの現実を見据えた段階的アプローチが多くの場合において最善だ。

冒頭の問いに戻ろう。「『汎用データベースでは足りない』用途は、何をきっかけに専用DBを生み出したのか？」

きっかけは常に「痛み」だ。時系列データの書き込みと集計でRDBが悲鳴を上げた。グラフ構造のクエリでJOINが爆発した。その痛みを解決するために、データの性質に特化したデータベースが生まれた。だが「痛みのない場面で使う」のは過剰だ。

データの性質に合ったデータベースを選ぶ力こそが、現代のエンジニアに求められている。そしてその力は、データベースの歴史——汎用から専門特化への進化の必然性——を知ることで養われる。

次回からは第5章「NewSQL以降」に入る。第17回「Google Spanner——分散と強一貫性の両立」では、CAP定理を「超えた」と言われるデータベースの真実に迫る。原子時計とGPSを使ったTrueTime API。分散と強一貫性の「両立」は、本当に可能なのだろうか。

---

### 参考文献

- Oetiker, T., "RRDtool - The Time Series Database". <https://oss.oetiker.ch/rrdtool/>
- InfluxDB, Wikipedia. <https://en.wikipedia.org/wiki/InfluxDB>
- TimescaleDB, Wikipedia. <https://en.wikipedia.org/wiki/TimescaleDB>
- SoundCloud, "Prometheus has come of age - a reflection on the development of an open-source project". <https://developers.soundcloud.com/blog/prometheus-has-come-of-age-a-reflection-on-the-development-of-an-open-source-project/>
- PromLabs, "Prometheus Turns 10", 2022. <https://promlabs.com/blog/2022/11/24/prometheus-turns-10/>
- Neo4j, "Emil Eifrem, Neo4j Founder — Interview". <https://hackernoon.com/something-much-broader-than-compensation-drives-us-emil-eifrem-neo4j-founder-interview-168278957077>
- Cypher (query language), Wikipedia. <https://en.wikipedia.org/wiki/Cypher_(query_language)>
- ISO/IEC 39075:2024, "Information technology — Database languages — GQL". <https://www.iso.org/standard/76120.html>
- Amazon Neptune, Wikipedia. <https://en.wikipedia.org/wiki/Amazon_Neptune>
- Timescale, "What is a Time-Series Database?". <https://www.timescale.com/blog/what-is-a-time-series-database>

---

**次回予告：** 第17回「Google Spanner——分散と強一貫性の両立」では、CAP定理を「超えた」とされるデータベースの真実に迫る。2012年のSpanner論文が提示したTrueTime API——原子時計とGPSによる時刻同期。Google Cloud Spannerのドキュメントを初めて読んだときの衝撃。「グローバルに分散して強一貫性」は本当に可能なのか。Spannerのアーキテクチャと、その「魔法ではなく工学」という本質を解き明かす。
