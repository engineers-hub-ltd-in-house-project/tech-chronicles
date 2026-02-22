# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第21回：データレイクとLakehouse——分析基盤の進化

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- OLTP（トランザクション処理）とOLAP（分析処理）はなぜ分離されたのか——ワークロード特性の根本的な違い
- データウェアハウスの誕生と進化——Bill Inmon（1992年）からRalph Kimball（1996年）、そしてクラウドDWH（Redshift、BigQuery）へ
- 列指向ストレージの原理——なぜ分析クエリが行指向の100倍速くなるのか
- Hadoop/HDFSとデータレイクの栄枯盛衰——「何でも放り込める湖」が「データの沼」に変わった理由
- Apache Parquet、Delta Lake、Apache Icebergによるテーブルフォーマット革命——データレイクにACIDを持ち込む
- Lakehouseアーキテクチャの設計思想——データウェアハウスとデータレイクの統合
- HTAP（Hybrid Transactional/Analytical Processing）の現在——TiDB TiFlash、AlloyDB
- DuckDBのインプロセス分析——「SQLite for Analytics」の衝撃

---

## 1. なぜ同じデータを二重に管理しなければならないのか

2015年頃、私はある中規模のECサイトの開発チームに参加していた。

システムの構成は典型的だった。PostgreSQLがトランザクション処理を担い、商品の在庫管理、注文処理、ユーザー認証をさばいている。日々数十万件のトランザクションが流れる。このPostgreSQLが、システムの「心臓」だった。

問題は、経営層からの分析要求だった。「先月の売上を商品カテゴリ別に集計してほしい」「過去1年間の購買傾向を地域別に分析したい」「キャンペーンのコンバージョン率をリアルタイムで把握したい」。

最初は素朴に対処した。PostgreSQLのレプリカに対してSQLで集計クエリを投げる。だが月次の売上集計を走らせると、数百万行のJOINと集約がレプリカの負荷を跳ね上げ、レプリケーション遅延が増大する。本番DBへの影響こそ避けられたが、レプリカに依存していた他の読み取り処理——たとえば商品検索のキャッシュ更新——が巻き添えで遅延する。

ある日、経営企画部門から「直近3年分の全注文データを使って、ユーザーのライフタイムバリュー（LTV）を計算してほしい」と依頼が来た。3年分の注文データは数千万行。関連テーブルとJOINすれば処理対象は億行を超える。レプリカで走らせたところ、クエリは4時間以上かかり、その間レプリカは他のクエリにまともに応答しなくなった。

結局、私たちはETL（Extract, Transform, Load）パイプラインを構築し、PostgreSQLからデータを抽出し、変換し、分析用のデータウェアハウスに投入する仕組みを作ることになった。夜間バッチでデータを転送し、翌朝には分析チームが使えるようにする。

そのとき、私は根本的な疑問を抱いた。なぜ同じデータを二重に管理しなければならないのか。なぜトランザクション処理と分析処理は、同じデータベースで共存できないのか。

あなたの組織でも同じ構図がないだろうか。「本番DB」と「分析DB」が分かれていて、その間をETLパイプラインが日々データを運んでいる。その二重管理のコスト——ETLの開発、障害対応、データの鮮度問題——を疑問に思ったことはないだろうか。

---

## 2. OLTP/OLAP分離の歴史——ワークロードの根本的な衝突

### 二つのワークロードの衝突

データベースのワークロードは、大きく二つに分類される。OLTP（Online Transaction Processing）とOLAP（Online Analytical Processing）だ。

OLTPは、日々のビジネストランザクションを処理する。注文の登録、在庫の更新、ユーザーの認証。特徴は、少数の行に対する高頻度の読み書きだ。1回のクエリが触れるのは数行から数百行。だがそのクエリが毎秒数千回、数万回飛んでくる。レイテンシが生命線であり、1回の処理は数ミリ秒以内に完了しなければならない。

OLAPは、蓄積されたデータを分析する。売上集計、トレンド分析、ユーザーセグメンテーション。特徴は、大量の行に対する低頻度のスキャンだ。1回のクエリが数百万行から数億行を走査し、集約する。レイテンシへの要求はOLTPほど厳しくないが、スループット——単位時間あたりに処理できるデータ量——が重要になる。

```
OLTPとOLAPのワークロード特性

                    OLTP                      OLAP
                    (トランザクション処理)     (分析処理)
─────────────────────────────────────────────────────────
対象行数/クエリ     数行〜数百行              数百万行〜数億行
クエリ頻度          毎秒数千〜数万回          数回〜数十回/日
対象カラム          全カラム（1レコード全体）  少数カラム（売上額、日付等）
操作                INSERT/UPDATE/DELETE      SELECT + 集約(SUM, AVG, COUNT)
レイテンシ要求      ミリ秒単位               秒〜分単位
同時実行性          高い（数千接続）          低い（数十接続）
データの鮮度        リアルタイム              数時間〜1日遅れが許容
最適なストレージ    行指向                    列指向
─────────────────────────────────────────────────────────
```

この二つのワークロードを同じデータベースで走らせると何が起きるか。OLAPの集計クエリが数億行をフルスキャンしている間、そのテーブルに対するOLTPの書き込みがロック待ちになる。あるいはOLAPクエリがCPUとI/Oを占有し、OLTPのレイテンシが跳ね上がる。第7回で語ったACIDのIsolation（独立性）を厳密に守ろうとすれば、OLAPクエリは巨大なスナップショットを保持し、MVCCのバージョンチェーンが肥大化する。

これは技術的な限界というよりも、設計上のトレードオフだ。OLTPに最適化したデータベースは行指向ストレージを使う。1行のレコードを高速に読み書きするために、関連するカラムのデータを連続した物理領域に配置する。一方、OLAPに最適化したデータベースは列指向ストレージを使う。特定のカラムだけを高速にスキャンするために、同じカラムのデータを連続した物理領域に配置する。行指向と列指向は物理的なデータ配置が正反対であり、一つのストレージで両方を最適化することは原理的に困難だ。

### データウェアハウスの誕生

この「OLTPとOLAPの分離」を体系化したのが、Bill Inmonだ。

Inmonは1970年代からデータウェアハウス（DWH）の概念を提唱し、1992年に『Building the Data Warehouse』を出版して概念を体系化した。Inmonはデータウェアハウスを「主題指向（Subject-Oriented）、統合（Integrated）、時変（Time-Variant）、非揮発性（Non-Volatile）のデータの集合体であり、経営の意思決定を支援するもの」と定義した。

この定義の各要素は重要だ。「主題指向」は、業務システムのテーブル設計（注文テーブル、在庫テーブル）ではなく、分析の視点（売上分析、顧客分析）でデータを組織化すること。「統合」は、複数の業務システムから来るデータを統一的なフォーマットに変換すること。「時変」は、過去の履歴を保持し、時系列での分析を可能にすること。「非揮発性」は、一度投入されたデータは更新されず、追記のみであること。

Inmonのモデルは、企業全体の統合データウェアハウスを構築し、そこからデータマート（部門別の分析用データベース）を派生させるトップダウンのアプローチだ。

一方、1996年にRalph Kimballが『The Data Warehouse Toolkit』を出版し、異なるアプローチを提唱した。Kimballのモデルは、ファクトテーブル（事実を記録するテーブル、例：売上金額）とディメンションテーブル（分析の軸となるテーブル、例：商品、日付、地域）によるスタースキーマ設計だ。データマートを先に構築し、必要に応じて統合するボトムアップのアプローチである。

```
スタースキーマ（Kimball方式）

        ┌──────────┐
        │ 商品     │
        │dim_product│
        └────┬─────┘
             │
┌──────────┐ │ ┌──────────────┐
│ 日付     ├─┼─┤ 売上ファクト  │──┬──┌──────────┐
│dim_date  │ │ │fact_sales    │  │  │ 地域     │
└──────────┘ │ │              │  │  │dim_region│
             │ │ ・売上金額   │  │  └──────────┘
             │ │ ・数量       │  │
             │ │ ・割引額     │  │  ┌──────────┐
             │ │              │  └──│ 顧客     │
             │ └──────────────┘     │dim_customer│
             │                      └──────────┘
             │
    中心にファクトテーブル、周囲にディメンションテーブル
    → 星形（Star Schema）の構造
```

Inmon対Kimballの論争は1990年代から2000年代にかけて業界を二分した。だが共通していたのは、「OLTPシステムとは別に、分析専用のデータストアを構築する」という前提だ。つまり、データの二重管理は「避けられないコスト」として受け入れられていた。

### 列指向ストレージの革命

データウェアハウスの性能を飛躍的に向上させたのが、列指向ストレージ（Columnar Storage）だ。

行指向ストレージでは、1行のレコード全体が連続した物理領域に格納される。`SELECT * FROM orders WHERE id = 42` のような、特定の1行を丸ごと取得するクエリには最適だ。だが`SELECT SUM(amount) FROM orders WHERE year = 2024` のような、数百万行の特定カラムだけをスキャンする集計クエリには非効率的だ。`amount`カラムだけが必要なのに、`id`、`user_id`、`product_id`、`address`など不要なカラムのデータまでディスクから読み込まなければならない。

列指向ストレージはこの問題を根本から解決する。同じカラムのデータを連続した物理領域に格納する。`SUM(amount)` を計算するには、`amount`カラムのデータだけを連続的に読み込めばよい。不要なカラムは一切読まない。

```
行指向 vs 列指向のデータ配置

行指向ストレージ:
┌────────────────────────────────────────────────────┐
│ id=1, user=Alice, amount=1000, date=2024-01-15     │ → Row 1
│ id=2, user=Bob,   amount=2500, date=2024-01-16     │ → Row 2
│ id=3, user=Alice, amount=800,  date=2024-01-17     │ → Row 3
│ id=4, user=Carol, amount=3200, date=2024-01-18     │ → Row 4
└────────────────────────────────────────────────────┘
  SUM(amount) → 全行を読む必要あり（不要なカラムも含む）

列指向ストレージ:
┌───────────────────┐
│ id:     1, 2, 3, 4│ → Column: id
├───────────────────┤
│ user:   Alice, Bob│ → Column: user
│         Alice, Ca…│
├───────────────────┤
│ amount: 1000, 2500│ → Column: amount ← これだけ読めばいい
│         800, 3200 │
├───────────────────┤
│ date:   2024-01-15│ → Column: date
│         ...       │
└───────────────────┘
  SUM(amount) → amountカラムだけを読む（I/O 1/4以下）
```

列指向ストレージにはもう一つの強力な利点がある。圧縮効率だ。同じカラムのデータは同じ型であり、値の分布に偏りがあることが多い。たとえば`country`カラムに格納される値は、数十種類の国名のいずれかだ。辞書圧縮（Dictionary Encoding）やランレングス圧縮（Run-Length Encoding）を適用すると、元データの10分の1以下に圧縮できる場合がある。圧縮されたデータはディスクI/Oを削減し、CPUキャッシュに収まりやすくなり、結果として処理速度がさらに向上する。

列指向ストレージの学術的な基盤は1970年代に遡るが、実用化が進んだのは2000年代だ。1996年にSybase IQが最初の商用列指向データベースとして登場し、2002年にCWI（Centrum Wiskunde & Informatica、オランダ）のPeter BonczとMartin KerstenがMonetDBを公開した。2005年にはMITを中心とした研究チームがC-Storeを発表し、これが後にVerticaとして商用化された（2011年にHPが買収）。

2010年代に入ると、クラウドデータウェアハウスが列指向ストレージを標準採用する。2012年にAmazonがRedshiftを発表し、クラウド上のフルマネージド列指向データウェアハウスを実現した。Redshiftは列指向ストレージとMPP（Massively Parallel Processing）アーキテクチャを組み合わせ、ペタバイト規模のデータを分析できるサービスだ。同じ2012年にGoogleはBigQueryをGAとした。BigQueryは2010年に論文が発表されたGoogleのDremelシステムを商用化したものであり、ストレージとコンピュートを完全に分離したサーバレスアーキテクチャが特徴だった。

だが、データウェアハウスにはある種の窮屈さがあった。データは事前に定義されたスキーマに適合しなければ投入できない。非構造化データ——ログファイル、JSONドキュメント、画像、動的に変わるイベントデータ——を扱うことは困難だった。そして2000年代後半、データ量の爆発的増大が、データウェアハウスの限界を顕在化させた。

---

## 3. データレイクからLakehouseへ——20年間の試行錯誤

### Hadoopとデータレイクの勃興

2003年にGoogleがGFS（Google File System）論文を、2004年にMapReduce論文を発表した。この二つの論文に触発されて、Doug CuttingとMike Cafarellaは2006年にApache Hadoopをリリースした。HDFS（Hadoop Distributed File System）は、コモディティサーバのローカルディスクにデータを分散配置し、MapReduceフレームワークはそのデータを並列処理する。Googleのインフラを安価なハードウェアで再現する試みだった。

Hadoopの衝撃は、「スキーマを決めなくてもデータを格納できる」ことにあった。データウェアハウスが「スキーマオンライト（書き込み時にスキーマを定義する）」であるのに対し、Hadoopは「スキーマオンリード（読み込み時にスキーマを解釈する）」だ。JSONでもCSVでもログファイルでもバイナリでも、とにかくHDFSに放り込んでおけば、後からMapReduceで処理できる。

この「何でも放り込める」ストレージの概念を、2010年にPentahoの共同創業者兼CTOのJames Dixonが「データレイク」と名付けた。Dixonはブログ記事「Pentaho, Hadoop, and Data Lakes」で、「データマートがボトル入り飲料水の店だとしたら、データレイクはより自然な状態の大きな水域である」と表現した。

データレイクの思想は魅力的だった。あらゆるデータを生のまま格納し、必要なときに必要な形で処理する。ETLの「Transform（変換）」を書き込み時ではなく読み込み時に行うことで、柔軟性が飛躍的に高まる。データウェアハウスでは「どんな分析をしたいか」を事前に決めなければスキーマを設計できないが、データレイクでは「とりあえず全部保存しておき、分析の仕方は後で考える」ことができる。

2010年代前半、Hadoopエコシステムは爆発的に成長した。Apache Hive（SQLライクなクエリ）、Apache Pig（データフロー言語）、Apache HBase（列指向NoSQLストア）——Hadoop上に多くのツールが構築され、データレイクは企業のデータ基盤として急速に普及した。

### 「データの沼」——データレイクの失敗

だがデータレイクは、多くの組織で期待通りには機能しなかった。

「何でも放り込める」は、裏を返せば「何が入っているかわからない」になる。メタデータの管理が不十分なまま大量のデータを投入すると、誰がいつ何の目的で投入したかわからないファイルが堆積する。スキーマが定義されていないため、あるファイルが有効なデータなのか、中間処理の一時ファイルなのか、すでに古くなったスナップショットなのかを判別できない。

この状態は「データスワンプ（データの沼）」と呼ばれるようになった。データレイクが「大きな水域」であるなら、管理されないデータレイクは淀んだ沼——入ったものが腐り、何も見通せない——だ。

私自身、2016年にHadoopベースのデータレイクの構築に関わった経験がある。最初の半年は順調だった。各部門のデータを次々とHDFSに投入し、Hiveでアドホック分析を行い、経営層に報告する。だが1年も経つと、HDFSの容量は数十テラバイトに膨れ上がり、データの系譜（どのデータがどこから来て、どう変換されたか）を誰も追えなくなった。分析チームが「先月の売上データはどのディレクトリにある？」と聞くと、答えが返ってこない。複数のETLパイプラインが同じデータを異なるフォーマットで生成し、どちらが「正しい」かわからない。

データレイクにはもう一つ、技術的な根本問題があった。ACIDトランザクションの不在だ。

HDFSは分散ファイルシステムであり、データベースではない。ファイルの上書き中にプロセスが失敗すれば、中途半端な状態のファイルが残る。複数のプロセスが同じデータを同時に読み書きすれば、不整合が生じる。第7回で語ったACID——原子性、一貫性、独立性、永続性——は、データレイクには存在しなかった。

この問題は、データレイクを「バッチ処理の入力ソース」としてのみ使う限りは顕在化しにくい。だがデータレイクを「企業のデータ基盤」として使おうとすると——ストリーミングデータのリアルタイム投入、既存データの更新・削除、複数パイプラインの並行実行——ACIDの不在が致命的になる。

### Apache Sparkの台頭とMapReduceの退場

Hadoopの計算エンジンであるMapReduceにも問題があった。MapReduceは各ステップの中間結果をHDFSに書き出す。複数のステップを含むジョブでは、ディスクI/Oがボトルネックになり、処理速度が著しく低下する。インタラクティブなクエリ——SQLを投げて数秒で結果を得る——には不向きだった。

2009年、UC BerkeleyのAMPLabでMatei Zahariaが開発を開始したApache Sparkは、この問題をインメモリ処理で解決した。中間結果をディスクに書き出すのではなく、メモリ上に保持する。RDD（Resilient Distributed Dataset）という抽象により、分散データに対する変換処理をメモリ上で連鎖させ、最終結果だけをディスクに書き出す。MapReduceに比べて、最大100倍の速度向上を達成した。

2010年にBSDライセンスでオープンソース化され、2013年にApache Software Foundationに寄贈、2014年にApacheトップレベルプロジェクトに昇格した。Spark SQLの導入により、SQLインターフェースでデータレイク上のデータを分析できるようになった。ここでも第22回で詳しく語る「SQLの不死」が垣間見える——新しい計算エンジンが登場しても、インターフェースとしてSQLに回帰するのだ。

### Apache Parquet——列指向フォーマットのデファクト標準

データレイクの性能問題を解決するもう一つの重要な要素が、ファイルフォーマットだ。

2013年、TwitterとClouderaのエンジニアが共同でApache Parquetをリリースした。Googleが2010年に発表したDremel論文のレコード分解・再構成アルゴリズムに基づく列指向ファイルフォーマットだ。元の名前は「Red Elm」——Dremelのアナグラムである。

Parquetの設計は、データウェアハウスの列指向ストレージの利点を、データレイク上のファイルに持ち込んだ。ファイル内部でデータを列ごとに格納し、列単位での読み込みと高効率な圧縮を実現する。Twitterでの初期テストでは、ストレージ使用量を28%削減し、単一カラムの読み取り時間を90%削減した。

```
Apache Parquetのファイル構造（簡略図）

┌──────────────────────────────────┐
│ Row Group 1                      │
│ ┌──────────┬──────────┬────────┐ │
│ │Column: id│Column:   │Column: │ │
│ │ 1,2,3... │user      │amount  │ │
│ │          │Alice,Bob │1000,   │ │
│ │          │Alice,... │2500,...│ │
│ └──────────┴──────────┴────────┘ │
├──────────────────────────────────┤
│ Row Group 2                      │
│ ┌──────────┬──────────┬────────┐ │
│ │Column: id│Column:   │Column: │ │
│ │ 1001,... │user      │amount  │ │
│ │          │Carol,... │800,... │ │
│ └──────────┴──────────┴────────┘ │
├──────────────────────────────────┤
│ Footer                           │
│ ・各Column Chunkのオフセット     │
│ ・スキーマ情報                   │
│ ・統計情報（min/max値）          │
│   → 不要なRow Groupをスキップ可  │
└──────────────────────────────────┘
```

Parquetのフッターには各カラムの統計情報（最小値、最大値、NULL数）が記録されており、クエリエンジンはこの情報を使って不要なRow Groupの読み込みをスキップできる（述語プッシュダウン）。`WHERE amount > 5000` のクエリを実行する際、あるRow Groupの`amount`カラムの最大値が3000であれば、そのRow Groupは読み飛ばせる。

Parquetはデータレイクの列指向フォーマットとしてデファクト標準の地位を確立し、Spark、Hive、Presto/Trino、Impalaなど主要な分析エンジンがネイティブにサポートしている。

### テーブルフォーマット革命——Delta Lake、Iceberg、Hudi

Parquetは優れたファイルフォーマットだが、それだけではデータレイクの根本問題を解決できない。Parquetファイルの集合体に対するACIDトランザクション、スキーマの進化、タイムトラベル（過去の時点のデータ参照）——これらの機能は、ファイルフォーマットのレイヤーでは提供できない。

この問題を解決するために登場したのが、「テーブルフォーマット」と呼ばれる新しいレイヤーだ。データレイク上のファイル群を「テーブル」として抽象化し、ACIDトランザクションやスキーマ管理を提供する。

**Apache Hudi**は、2016年にUberがインクリメンタル処理フレームワークとして開発した。名前はHadoop Upserts Deletes and Incrementalsの頭文字だ。Uberは日々膨大な配車データを生成しており、Hadoopデータウェアハウスのアクセスレイテンシを数時間から30分未満に短縮する必要があった。Hudiはデータレイクに「更新（upsert）」と「削除（delete）」の概念を持ち込み、インクリメンタルなデータ処理を可能にした。2017年にオープンソース化され、2020年にApacheトップレベルプロジェクトに昇格した。

**Apache Iceberg**は、Netflixが開発したテーブルフォーマットだ。NetflixのRyan BlueとDan Weeksが2017年に開発を開始した。動機はApache Hiveの限界だった。Hiveはテーブルのメタデータをディレクトリ構造に依存しており、正確性の保証やアトミックなトランザクションを提供できなかった。Icebergはスナップショットベースのメタデータ管理を導入し、テーブル操作のアトミック性を保証した。2018年11月にApache Software Foundationに寄贈され、2020年にトップレベルプロジェクトに昇格した。

**Delta Lake**は、2019年4月にDatabricksがSpark+AI Summitで発表し、Apache 2.0ライセンスでオープンソース化した。Apache Sparkの生みの親であるMatei Zahariaが設立したDatabricksが、データレイクの信頼性問題に正面から取り組んだプロジェクトだ。Delta Lakeはトランザクションログ（`_delta_log`ディレクトリ）にすべてのテーブル操作を記録し、ACIDトランザクション、スキーマの強制、タイムトラベルを実現する。

```
テーブルフォーマットの仕組み（Delta Lakeの例）

データレイク（S3/GCS/ADLS等のオブジェクトストレージ）
└── my_table/
    ├── _delta_log/                    ← トランザクションログ
    │   ├── 00000000000000000000.json  ← 初回コミット
    │   ├── 00000000000000000001.json  ← 2回目のコミット
    │   └── 00000000000000000002.json  ← 3回目のコミット
    ├── part-00000-xxxx.parquet        ← データファイル
    ├── part-00001-xxxx.parquet
    └── part-00002-xxxx.parquet

トランザクションログの中身（簡略化）:
{
  "add": {
    "path": "part-00002-xxxx.parquet",
    "size": 1048576,
    "modificationTime": 1709596800000
  },
  "remove": {
    "path": "part-00000-old.parquet"
  }
}

→ どのファイルが有効で、どのファイルが無効かを
  トランザクションログが管理する
→ ログを遡ればタイムトラベル（過去の状態の参照）が可能
```

Delta Lake、Iceberg、Hudiの三つは「テーブルフォーマット御三家」と呼ばれ、それぞれがデータレイクにACIDトランザクション、スキーマの進化、タイムトラベル機能を提供する。アプローチの細部は異なるが、根本的な思想は共通している——データレイクをデータベースの信頼性に近づけること。

### Lakehouseアーキテクチャ——二つの世界の統合

2021年1月、CIDRカンファレンスでDatabricksのMatei Zahariaらが論文「Lakehouse: A New Generation of Open Platforms that Unify Data Warehousing and Advanced Analytics」を発表した。

Lakehouseアーキテクチャの核心は、データレイクの柔軟性とデータウェアハウスの信頼性を一つのシステムに統合することだ。

```
アーキテクチャの進化

【第1世代：データウェアハウス】
業務DB → ETL → データウェアハウス → BIツール
  ・構造化データのみ
  ・スキーマオンライト
  ・高コスト（専用ハードウェア/ライセンス）
  ・高信頼（ACID、スキーマ強制）

【第2世代：データレイク + データウェアハウス】
業務DB → ETL → データレイク → ETL → データウェアハウス → BIツール
                    ↓
                 ML/AI処理
  ・構造化 + 非構造化データ
  ・スキーマオンリード
  ・低コスト（コモディティストレージ）
  ・低信頼（ACIDなし）
  ・データの二重管理問題

【第3世代：Lakehouse】
業務DB → データレイク（テーブルフォーマット層）→ BIツール
              │                                → ML/AI処理
              │  Delta Lake / Iceberg / Hudi
              │  ・ACIDトランザクション
              │  ・スキーマの進化
              │  ・タイムトラベル
              └──→ 統一されたデータ基盤
  ・構造化 + 非構造化データ
  ・低コスト（オブジェクトストレージ）
  ・高信頼（テーブルフォーマットによるACID）
  ・データの一元管理
```

Lakehouseの論文が指摘するデータウェアハウスの課題は明快だ。第一に、データの鮮度問題。業務DBからデータウェアハウスへのETLパイプラインには遅延がある。日次バッチなら1日遅れ、リアルタイムETLでも数分から数十分の遅延が生じる。第二に、データの二重管理コスト。同じデータをデータレイクとデータウェアハウスの両方に保持するため、ストレージコストが二倍になり、ETLパイプラインの開発・運用コストが加わる。第三に、ベンダーロックイン。データウェアハウスは独自のストレージフォーマットを使うため、他のシステムへの移行が困難だ。

Lakehouseはこれらの問題に対して、オープンなファイルフォーマット（Parquet）をデータレイク上に配置し、テーブルフォーマット（Delta Lake、Iceberg等）でACIDトランザクションとメタデータ管理を提供し、高性能なクエリエンジンで分析処理を行う。ETLの「データレイク→データウェアハウス」の部分を不要にするのが目標だ。

---

## 4. HTAPとDuckDB——新しい分析の形

### HTAP——OLTPとOLAPの壁を壊す試み

テーブルフォーマットとLakehouseがデータレイクの信頼性を向上させる一方で、別のアプローチも進んでいる。HTAP（Hybrid Transactional/Analytical Processing）——トランザクション処理と分析処理を一つのデータベースで共存させる試みだ。

第18回で語ったTiDBは、HTAP機能としてTiFlashを提供している。TiKV（行指向ストレージ）がOLTPワークロードを処理し、TiFlash（列指向ストレージ）がOLAPワークロードを処理する。TiFlashはRaftの学習者（Learner）プロトコルを使ってTiKVからリアルタイムでデータを複製し、行フォーマットのデータを列フォーマットに変換する。アプリケーションからは単一のSQLインターフェースとしてアクセスでき、TiDBのオプティマイザがクエリの種類に応じてTiKVとTiFlashのどちらからデータを読むかを自動判断する。

```
TiDBのHTAPアーキテクチャ

┌─────────────────────────────────────────┐
│  TiDB Server（SQLレイヤー）             │
│  ・SQL解析・最適化                      │
│  ・クエリの種類に応じてルーティング     │
└──────────┬─────────────┬────────────────┘
           │             │
    ┌──────▼──────┐  ┌──▼──────────────┐
    │ TiKV        │  │ TiFlash         │
    │ (行指向)    │  │ (列指向)        │
    │ OLTP向き    │  │ OLAP向き        │
    │ INSERT/     │──│ Raft Learnerで  │
    │ UPDATE/     │  │ リアルタイム複製│
    │ DELETE      │  │                 │
    │             │  │ 集計・分析クエリ│
    └─────────────┘  └─────────────────┘

OLTPクエリ → TiKVから読む
OLAPクエリ → TiFlashから読む
（アプリケーションは意識しなくてよい）
```

2022年にGoogleが発表したAlloyDBも、同様のアプローチを採る。AlloyDBはPostgreSQL互換のフルマネージドデータベースでありながら、列指向エンジンを内蔵している。分析クエリで標準PostgreSQLの最大100倍の高速化を実現し、行指向と列指向の使い分けをワークロードの学習に基づいて自動で行う。

HTAPの思想は、冒頭で語った「なぜ同じデータを二重に管理しなければならないのか」という問いに対する、最も直接的な答えだ。だが課題もある。行指向から列指向への複製にはリソースが必要であり、OLTPとOLAPの完全なリソース分離が難しい場合がある。また、数十テラバイト規模の分析ワークロードに対しては、専用のデータウェアハウスやLakehouseの方が適している場合が多い。HTAPは「すべてを一つに」という理想に近づいているが、銀の弾丸ではない。

### DuckDB——「SQLite for Analytics」

2019年、オランダのCWI（Centrum Wiskunde & Informatica）のMark RaaseveldtとHannes MuhleisenがDuckDBをリリースした。SIGMOD 2019でデモ論文「DuckDB: an Embeddable Analytical Database」を発表し、世界初の目的特化型インプロセスOLAPデータベースと位置づけた。

DuckDBのコンセプトは明快だ——「SQLite for Analytics」。SQLiteがOLTPのインプロセスデータベースとして世界中で使われているように、DuckDBはOLAPのインプロセスデータベースとして機能する。

```
SQLite vs DuckDB の位置づけ

SQLite:
・インプロセス（サーバ不要）
・行指向ストレージ
・OLTP向き（小さなトランザクション処理に最適）
・組み込み用途（モバイルアプリ、ブラウザ、IoT）

DuckDB:
・インプロセス（サーバ不要）
・列指向ストレージ
・OLAP向き（大量データの分析処理に最適）
・分析用途（データサイエンス、アドホック分析、ETL）
```

DuckDBの革新性は、サーバを一切立てずに、ローカルのCSVファイルやParquetファイルに対して高速な分析クエリを実行できることにある。Pythonから数行で使える。

```python
import duckdb

# CSVファイルに対してSQLを実行（インポート不要）
result = duckdb.sql("""
    SELECT region, SUM(amount) as total_sales
    FROM 'sales_data.csv'
    GROUP BY region
    ORDER BY total_sales DESC
""")
print(result)

# Parquetファイルもクエリ可能
result = duckdb.sql("""
    SELECT year, month, AVG(price) as avg_price
    FROM 'transactions/*.parquet'
    WHERE year >= 2023
    GROUP BY year, month
    ORDER BY year, month
""")
```

`'sales_data.csv'`や`'transactions/*.parquet'`という表記に注目してほしい。テーブルにデータをロードする必要がない。ファイルをそのままクエリできる。ワイルドカードでディレクトリ内の全Parquetファイルをまとめてクエリすることも可能だ。

DuckDBが高速な理由は、CWIのデータベース研究グループが2005年に開発したベクトル化実行（Vectorized Execution）にある。従来のデータベースが1行ずつ処理するのに対し、DuckDBはカラムのデータをバッチ（ベクトル）単位で処理する。現代のCPUはSIMD命令やキャッシュラインの効率的な利用により、連続したデータのバッチ処理に最適化されている。列指向ストレージ + ベクトル化実行の組み合わせが、インプロセスでありながら驚異的な分析性能を生む。

DuckDBがデータ分析の現場にもたらした変化は大きい。従来、数ギガバイトのCSVを分析するには、PostgreSQLにインポートするか、pandasで読み込むか、クラウドのデータウェアハウスにロードする必要があった。DuckDBを使えば、ローカル環境で、サーバなしで、SQLだけで分析が完了する。データサイエンティストにとって、「とりあえずデータを見たい」という欲求に最速で応えるツールだ。

---

## 5. ハンズオン: DuckDBでParquetファイルを分析する

今回のハンズオンでは、DuckDBを使って大規模データの分析クエリを実行し、行指向DB（PostgreSQL）との速度差を体験する。Docker環境で完結するため、外部サービスへの登録は不要だ。

### 演習概要

1. DuckDBとPostgreSQLをDockerで起動する
2. 100万行の売上データを生成する
3. 行指向（PostgreSQL）と列指向（DuckDB）で同じ集計クエリを実行し、速度を比較する
4. Parquetファイルの効率性を確認する
5. DuckDBの高度なSQL機能（ウィンドウ関数、PIVOT）を体験する

### 環境構築

```bash
# handson/database-history/21-datalake-and-lakehouse/setup.sh を実行
bash setup.sh
```

### 演習1: データ生成とPostgreSQLへの投入

```bash
# PostgreSQLをDockerで起動
docker run -d \
  --name pg-handson \
  -e POSTGRES_PASSWORD=handson \
  -e POSTGRES_DB=salesdb \
  -p 5432:5432 \
  postgres:17

# 起動を待機
sleep 3
```

```bash
# DuckDBで100万行のテストデータをCSVとParquetで生成
docker run --rm -v "$(pwd)":/data \
  python:3.12-slim bash -c '
pip install -q duckdb > /dev/null 2>&1
python3 << "PYEOF"
import duckdb

con = duckdb.connect()

# 100万行の売上データを生成
con.execute("""
    COPY (
        SELECT
            i AS id,
            2020 + (i % 5) AS year,
            1 + (i % 12) AS month,
            CASE (i % 5)
                WHEN 0 THEN '"'"'Tokyo'"'"'
                WHEN 1 THEN '"'"'Osaka'"'"'
                WHEN 2 THEN '"'"'Nagoya'"'"'
                WHEN 3 THEN '"'"'Fukuoka'"'"'
                WHEN 4 THEN '"'"'Sapporo'"'"'
            END AS region,
            CASE (i % 4)
                WHEN 0 THEN '"'"'Electronics'"'"'
                WHEN 1 THEN '"'"'Clothing'"'"'
                WHEN 2 THEN '"'"'Food'"'"'
                WHEN 3 THEN '"'"'Books'"'"'
            END AS category,
            ROUND(100 + (RANDOM() * 9900), 2) AS amount,
            1 + (RANDOM() * 10)::INT AS quantity
        FROM generate_series(1, 1000000) AS t(i)
    ) TO '"'"'/data/sales.csv'"'"' (HEADER, DELIMITER '"'"','"'"')
""")

# 同じデータをParquet形式でも出力
con.execute("""
    COPY (SELECT * FROM read_csv_auto('"'"'/data/sales.csv'"'"'))
    TO '"'"'/data/sales.parquet'"'"' (FORMAT PARQUET)
""")

import os
csv_size = os.path.getsize("/data/sales.csv")
parquet_size = os.path.getsize("/data/sales.parquet")
print(f"CSV size:     {csv_size / 1024 / 1024:.1f} MB")
print(f"Parquet size: {parquet_size / 1024 / 1024:.1f} MB")
print(f"Compression:  {parquet_size / csv_size * 100:.1f}%")
PYEOF
'
```

CSVとParquetのファイルサイズの違いに注目してほしい。Parquetは列指向で圧縮されているため、CSVの半分以下になることが多い。

### 演習2: PostgreSQLへのデータロードと集計

```bash
# PostgreSQLにテーブル作成とデータ投入
docker exec -i pg-handson psql -U postgres -d salesdb << 'SQL'
-- テーブル作成
CREATE TABLE sales (
  id INTEGER PRIMARY KEY,
  year INTEGER,
  month INTEGER,
  region TEXT,
  category TEXT,
  amount NUMERIC(10,2),
  quantity INTEGER
);

-- CSVからデータをロード
\copy sales FROM '/dev/stdin' WITH (FORMAT csv, HEADER true)
SQL

# CSVをPostgreSQLに流し込む
cat sales.csv | docker exec -i pg-handson psql -U postgres -d salesdb \
  -c "\copy sales FROM STDIN WITH (FORMAT csv, HEADER true)"

-- 行数確認
docker exec -i pg-handson psql -U postgres -d salesdb \
  -c "SELECT COUNT(*) FROM sales;"
```

```bash
# PostgreSQLでの集計クエリ（行指向）
docker exec -i pg-handson psql -U postgres -d salesdb << 'SQL'
\timing on

-- クエリ1: 年別・地域別の売上合計
SELECT year, region,
       SUM(amount) AS total_sales,
       COUNT(*) AS order_count,
       ROUND(AVG(amount), 2) AS avg_amount
FROM sales
GROUP BY year, region
ORDER BY year, region;

-- クエリ2: カテゴリ別の月次売上推移
SELECT year, month, category,
       SUM(amount) AS total_sales
FROM sales
WHERE year = 2024
GROUP BY year, month, category
ORDER BY month, category;
SQL
```

### 演習3: DuckDBでの同じ集計クエリ（列指向）

```bash
# DuckDBでCSVをクエリ（データロード不要）
docker run --rm -v "$(pwd)":/data \
  python:3.12-slim bash -c '
pip install -q duckdb > /dev/null 2>&1
python3 << "PYEOF"
import duckdb
import time

con = duckdb.connect()

# --- CSVに対するクエリ ---
print("=== DuckDB: CSVクエリ ===")
start = time.perf_counter()
result = con.execute("""
    SELECT year, region,
           SUM(amount) AS total_sales,
           COUNT(*) AS order_count,
           ROUND(AVG(amount), 2) AS avg_amount
    FROM read_csv_auto('"'"'/data/sales.csv'"'"')
    GROUP BY year, region
    ORDER BY year, region
""").fetchdf()
elapsed_csv = time.perf_counter() - start
print(result.to_string())
print(f"\nCSV query time: {elapsed_csv:.3f} sec")

# --- Parquetに対するクエリ ---
print("\n=== DuckDB: Parquetクエリ ===")
start = time.perf_counter()
result = con.execute("""
    SELECT year, region,
           SUM(amount) AS total_sales,
           COUNT(*) AS order_count,
           ROUND(AVG(amount), 2) AS avg_amount
    FROM read_parquet('"'"'/data/sales.parquet'"'"')
    GROUP BY year, region
    ORDER BY year, region
""").fetchdf()
elapsed_parquet = time.perf_counter() - start
print(result.to_string())
print(f"\nParquet query time: {elapsed_parquet:.3f} sec")
print(f"Parquet vs CSV speedup: {elapsed_csv / elapsed_parquet:.1f}x")
PYEOF
'
```

DuckDBがParquetファイルをクエリする速度と、CSVファイルをクエリする速度の差に注目してほしい。Parquetは列指向フォーマットであるため、DuckDBの列指向エンジンと相性が良く、CSVより高速に処理できる。

### 演習4: DuckDBの高度なSQL

```bash
docker run --rm -v "$(pwd)":/data \
  python:3.12-slim bash -c '
pip install -q duckdb > /dev/null 2>&1
python3 << "PYEOF"
import duckdb

con = duckdb.connect()

# ウィンドウ関数: 各地域の月次売上と累積売上
print("=== ウィンドウ関数: 月次売上と累積売上 ===")
result = con.execute("""
    SELECT region, month,
           SUM(amount) AS monthly_sales,
           SUM(SUM(amount)) OVER (
               PARTITION BY region
               ORDER BY month
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS cumulative_sales
    FROM read_parquet('"'"'/data/sales.parquet'"'"')
    WHERE year = 2024
    GROUP BY region, month
    ORDER BY region, month
""").fetchdf()
print(result.head(15).to_string())

# PIVOT: 地域×カテゴリの売上クロス集計
print("\n=== PIVOT: 地域×カテゴリのクロス集計 ===")
result = con.execute("""
    PIVOT (
        SELECT region, category, SUM(amount) AS total
        FROM read_parquet('"'"'/data/sales.parquet'"'"')
        WHERE year = 2024
        GROUP BY region, category
    )
    ON category
    USING SUM(total)
    ORDER BY region
""").fetchdf()
print(result.to_string())
PYEOF
'
```

### 後片付け

```bash
docker stop pg-handson && docker rm pg-handson
rm -f sales.csv sales.parquet
```

---

## 6. 分析基盤の地層——統合への長い道のり

第21回を振り返ろう。

**OLTPとOLAPの分離は、ワークロード特性の根本的な衝突に起因する。** 行指向ストレージは少数行の高速な読み書きに最適化され、列指向ストレージは大量行の特定カラムの高速スキャンに最適化されている。この物理的なデータ配置の違いが、トランザクション処理と分析処理を同一データベースで効率的に処理することを困難にしてきた。1992年のBill Inmonと1996年のRalph Kimballは、この分離を前提としたデータウェアハウスのアーキテクチャを確立した。

**データレイクは柔軟性を得た代わりに信頼性を失った。** 2006年のHadoop、2010年のデータレイク概念は、スキーマオンリードの自由と低コストのストレージをもたらした。だがACIDトランザクションの不在とメタデータ管理の欠如が、多くのデータレイクを「データの沼」に変えた。

**テーブルフォーマットがデータレイクにACIDを持ち込んだ。** Apache Hudi（2016年、Uber）、Apache Iceberg（2017年、Netflix）、Delta Lake（2019年、Databricks）——三つのテーブルフォーマットが、データレイク上のファイル群にトランザクションログ、スキーマの進化、タイムトラベルを提供し、信頼性の問題を解決した。

**Lakehouseアーキテクチャは、データウェアハウスとデータレイクの統合を目指す。** 2021年のDatabricksの論文は、データレイクの低コスト・柔軟性とデータウェアハウスの信頼性・性能を一つのシステムに統合する第3世代のアーキテクチャを提唱した。ETLパイプラインによるデータの二重管理を解消するのが目標だ。

**HTAPとDuckDBは、別の角度から分析の壁を壊す。** TiDB TiFlashやAlloyDBは行指向と列指向のストレージを一つのデータベースに共存させ、OLTPとOLAPを統合する。DuckDBはインプロセスの列指向エンジンにより、サーバなしで大規模データの分析を可能にした。

冒頭の問いに戻ろう。「トランザクション処理と分析処理を、一つのシステムで賄えるのか？」

私の答えは、「近づいているが、まだ完全ではない」だ。

Lakehouseアーキテクチャはデータの二重管理を大幅に削減したが、リアルタイム性の要求が高い場合にはストリーミング処理との統合が必要になる。HTAPは小〜中規模のワークロードで有効だが、数十テラバイト級の分析には専用の列指向エンジンが依然として優位だ。DuckDBはローカル分析の革命だが、マルチテナントの大規模分析基盤を代替するものではない。

50年前にCoddがリレーショナルモデルを提唱したとき、OLTPとOLAPの区別は存在しなかった。データベースはただ「データを格納し、問い合わせに答える」ものだった。データ量の爆発的増大が、この単純な世界を二分した。そして今、テクノロジーの進化が、分かれた世界を再び統合しようとしている。だが統合の道は一本ではない。Lakehouse、HTAP、インプロセス分析——それぞれが異なるトレードオフを持つ異なる解だ。

次回「SQLの不死——なぜ50年経っても消えないのか」では、この連載で繰り返し現れてきたパターンに正面から向き合う。NoSQLブーム、MapReduce、GraphQL——SQLを「過去のもの」にしようとした試みはすべて失敗し、あらゆるシステムがSQLインターフェースに回帰している。SQLが50年間死ななかった本当の理由を、歴史の中に探る。

---

### 参考文献

- Inmon, W. H., 『Building the Data Warehouse』, Wiley, 1992年初版. <https://en.wikipedia.org/wiki/Bill_Inmon>
- Kimball, R., 『The Data Warehouse Toolkit』, Wiley, 1996年初版. <https://www.wiley.com/en-us/The+Data+Warehouse+Toolkit:+The+Definitive+Guide+to+Dimensional+Modeling,+3rd+Edition-p-9781118530801>
- Dean, J. and Ghemawat, S., "MapReduce: Simplified Data Processing on Large Clusters", OSDI 2004. <https://research.google/pubs/mapreduce-simplified-data-processing-on-large-clusters/>
- Dixon, J., "Pentaho, Hadoop, and Data Lakes", 2010. <https://jamesdixon.wordpress.com/2010/10/14/pentaho-hadoop-and-data-lakes/>
- Melnik, S. et al., "Dremel: Interactive Analysis of Web-Scale Datasets", VLDB 2010. <https://research.google/pubs/dremel-interactive-analysis-of-web-scale-datasets/>
- Zaharia, M. et al., "Resilient Distributed Datasets: A Fault-Tolerant Abstraction for In-Memory Cluster Computing", NSDI 2012. <https://www.usenix.org/conference/nsdi12/technical-sessions/presentation/zaharia>
- Apache Parquet. <https://parquet.apache.org/>
- Zaharia, M. et al., "Lakehouse: A New Generation of Open Platforms that Unify Data Warehousing and Advanced Analytics", CIDR 2021. <https://people.eecs.berkeley.edu/~matei/papers/2021/cidr_lakehouse.pdf>
- Raasveldt, M. and Muhleisen, H., "DuckDB: an Embeddable Analytical Database", SIGMOD 2019. <https://dl.acm.org/doi/10.1145/3299869.3320212>
- Delta Lake. <https://delta.io/>
- Apache Iceberg. <https://iceberg.apache.org/>
- Apache Hudi. <https://hudi.apache.org/>

---

**次回予告：** 第22回「SQLの不死——なぜ50年経っても消えないのか」では、SQL標準化の50年史を辿り、NoSQLブームでも、MapReduceでも、AI時代でも、なぜSQLは生き残り続けるのかを探る。Google自身がDremelやBigQueryでSQLに回帰した事実、Spark SQL、DuckDB、CockroachDB——あらゆるシステムがSQLインターフェースを採用する理由を、宣言的クエリの普遍性と関係代数の数学的基盤から考える。
