# ファクトチェック記録：第21回「データレイクとLakehouse——分析基盤の進化」

## 1. Bill Inmonとデータウェアハウス概念

- **結論**: Bill Inmonは1970年代からデータウェアハウスの原則を議論し、用語を生み出した。1992年に『Building the Data Warehouse』を出版し、概念を体系化・普及させた。データウェアハウスを「主題指向、統合、時変、非揮発性のデータ集合体」と定義した
- **一次ソース**: Bill Inmon, 『Building the Data Warehouse』, 1992年初版
- **URL**: <https://en.wikipedia.org/wiki/Bill_Inmon>
- **注意事項**: ブループリントでは「1990年代」とあるが、Inmonの活動は1970年代から。1992年の書籍出版が体系化の起点
- **記事での表現**: 1992年にBill Inmonが『Building the Data Warehouse』を出版し、データウェアハウスの概念を体系化した

## 2. Ralph KimballとThe Data Warehouse Toolkit

- **結論**: Ralph Kimballは1996年に『The Data Warehouse Toolkit』初版を出版し、ディメンショナルモデリング（スタースキーマ）を業界に導入した。累計45万部以上を販売
- **一次ソース**: Ralph Kimball, 『The Data Warehouse Toolkit』, Wiley, 1996年初版
- **URL**: <https://www.wiley.com/en-us/The+Data+Warehouse+Toolkit:+The+Definitive+Guide+to+Dimensional+Modeling,+3rd+Edition-p-9781118530801>
- **注意事項**: Inmonのトップダウン（企業全体のDWH）対Kimballのボトムアップ（データマート起点）のアプローチの対比が重要
- **記事での表現**: 1996年にRalph Kimballが『The Data Warehouse Toolkit』を出版し、ファクトテーブルとディメンションテーブルによるスタースキーマを提唱した

## 3. Apache Hadoop/HDFSの起源

- **結論**: Doug CuttingとMike Cafarellaが、Apache Nutchプロジェクトの中でHadoopを開発。2003年のGoogle GFS論文と2004年のMapReduce論文に着想を得た。2006年1月にNutchから独立したサブプロジェクトとなり、2006年4月にHadoop 0.1.0をリリース。Doug Cuttingの子供の黄色い象のぬいぐるみから命名
- **一次ソース**: Apache Hadoop Wikipedia, Doug Cutting Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Apache_Hadoop>
- **注意事項**: ブループリントでは「2006年」と記載。Hadoop自体の独立は2006年だが、開発は2004年頃から開始
- **記事での表現**: 2006年にDoug CuttingとMike CafarellaがApache Hadoopをリリースした

## 4. Apache Sparkの起源

- **結論**: 2009年にUC BerkeleyのAMPLabでMatei Zahariaが開発を開始。2010年にBSDライセンスでオープンソース化。2013年にApache Software Foundationに寄贈しApache 2.0ライセンスに変更。2014年にApacheトップレベルプロジェクトに昇格
- **一次ソース**: Apache Spark Wikipedia, Matei Zaharia Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Apache_Spark>
- **注意事項**: ブループリントでは「2014年」とあるが、開発開始は2009年。2014年はTLPになった年
- **記事での表現**: 2009年にMatei ZahariaがUC BerkeleyのAMPLabでApache Sparkの開発を開始し、2014年にApacheトップレベルプロジェクトに昇格した

## 5. James Dixonとデータレイク概念

- **結論**: 2010年10月にPentahoの共同創業者兼CTOのJames Dixonがブログ記事「Pentaho, Hadoop, and Data Lakes」でデータレイクの概念を提唱した。「データマートがボトル入り飲料水の店だとしたら、データレイクはより自然な状態の大きな水域」と表現した
- **一次ソース**: James Dixon, "Pentaho, Hadoop, and Data Lakes", 2010年10月14日
- **URL**: <https://jamesdixon.wordpress.com/2010/10/14/pentaho-hadoop-and-data-lakes/>
- **注意事項**: Hadoop World in New Yorkの時期と一致
- **記事での表現**: 2010年にPentahoのJames Dixonがブログ記事で「データレイク」という概念を提唱した

## 6. Delta Lake（Databricks、2019年）

- **結論**: 2019年4月24日にDatabricksがSpark+AI Summitキーノートで発表。Apache 2.0ライセンスでオープンソース化。Delta Lake 0.1を初版リリース。ACIDトランザクション、スキーマ管理、統合されたストリーミング/バッチ処理を提供。Linux Foundationと共同で発表
- **一次ソース**: Databricks公式ブログ, "Databricks Open Sources Delta Lake for Data Lake Reliability"
- **URL**: <https://www.databricks.com/company/newsroom/press-releases/databricks-open-sources-delta-lake-for-data-lake-reliability>
- **注意事項**: 2022年にDelta Lake 2.0でさらに多くの機能をオープンソース化
- **記事での表現**: 2019年4月にDatabricksがDelta Lakeをオープンソースとして公開した

## 7. Apache Iceberg（Netflix、2018年）

- **結論**: NetflixのRyan BlueとDan Weeksが2017年に開発を開始。Apache Hiveの正確性保証やアトミックトランザクションの欠如に対処するために作成。2018年11月にApache Software Foundationに寄贈・オープンソース化。2020年5月にApacheトップレベルプロジェクトに昇格
- **一次ソース**: Apache Iceberg Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Apache_Iceberg>
- **注意事項**: Apple, Dremio, AWS, Tencent, LinkedIn, Stripeなど大手企業がコントリビュート
- **記事での表現**: 2018年にNetflixが開発したApache IcebergがApache Software Foundationに寄贈された

## 8. Apache Hudi（Uber、2016年開発開始）

- **結論**: 2016年にUberが開発。2017年にオープンソース化。2019年1月にApache Incubatorに提出。2020年6月にApacheトップレベルプロジェクトに昇格。Uber内で4,000以上のテーブル、数ペタバイトのデータを管理。Hadoopウェアハウスのアクセスレイテンシを数時間から30分未満に短縮
- **一次ソース**: Uber Engineering Blog, "Hudi: Uber Engineering's Incremental Processing Framework on Apache Hadoop"
- **URL**: <https://www.uber.com/blog/hoodie/>
- **注意事項**: ブループリントでは「2019年」と記載しているが、開発開始は2016年、オープンソース化は2017年
- **記事での表現**: 2016年にUberが開発したApache Hudiは、インクリメンタル処理フレームワークとしてデータレイクに更新処理を持ち込んだ

## 9. Lakehouseアーキテクチャ論文（Databricks、2021年CIDR）

- **結論**: CIDR 2021で発表（2021年1月）。論文タイトルは「Lakehouse: A New Generation of Open Platforms that Unify Data Warehousing and Advanced Analytics」。著者にMatei Zahariaらが含まれる。データレイクの低コストストレージとデータウェアハウスのACIDトランザクション・スキーマ強制・性能を統合するアーキテクチャ
- **一次ソース**: Zaharia et al., CIDR 2021
- **URL**: <https://people.eecs.berkeley.edu/~matei/papers/2021/cidr_lakehouse.pdf>
- **注意事項**: ブループリントでは「2020年」と記載しているが、論文発表は2021年1月（CIDR '21）。概念自体は2020年頃から提唱
- **記事での表現**: 2021年のCIDRカンファレンスでDatabricksがLakehouseアーキテクチャの論文を発表した

## 10. DuckDB（CWI、2019年）

- **結論**: CWI（Centrum Wiskunde & Informatica）のMark RaaseveldtとHannes Muhleisen（muが開発。2019年にオープンソースとして初版リリース。SIGMOD 2019でデモ論文を発表。世界初の目的特化型インプロセスOLAPデータベース。「SQLite for analytics」を標榜。CWIのDatabase Architecturesグループの研究成果（2005年のベクトル化実行など）を基盤に構築
- **一次ソース**: Raasveldt, M. and Muhleisen, H., "DuckDB: an Embeddable Analytical Database", SIGMOD 2019
- **URL**: <https://dl.acm.org/doi/10.1145/3299869.3320212>
- **注意事項**: 2021年にCWIスピンオフ企業DuckDB Labsを設立。MotherDuckが商用クラウド版を提供
- **記事での表現**: 2019年にCWIのMark RaaseveldtとHannes MuhleisenがDuckDBをリリースした

## 11. Apache Parquet（Twitter + Cloudera、2013年）

- **結論**: TwitterとClouderaのエンジニアが共同開発。Googleの2010年Dremel論文のレコード分解・再構成アルゴリズムに基づく。最初のバージョン（Apache Parquet 1.0）は2013年7月にリリース。元の名前は「Red Elm」（Dremelのアナグラム）。2015年4月にApacheトップレベルプロジェクトに昇格
- **一次ソース**: Apache Parquet Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Apache_Parquet>
- **注意事項**: Doug Cuttingが作成したTrevniフォーマットの改良として設計された。Twitterでは初期テストでストレージ28%削減、単一カラム読み取り時間90%削減を達成
- **記事での表現**: 2013年にTwitterとClouderaのエンジニアがApache Parquetをリリースした

## 12. 列指向ストレージの歴史（MonetDB、C-Store/Vertica）

- **結論**: 列指向ストレージの概念は1970年代（転置ファイル、垂直分割）に遡る。1996年にSybase IQが最初の商用列指向DB。2002年にMonetDB（CWI、Peter BonczとMartin Kersten）。2005年にC-Store（MIT等の研究プロジェクト）、同年Vertica Systems設立（2011年にHPが買収）。2010年にGoogleがDremel論文を発表
- **一次ソース**: MonetDB History, Vertica Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Vertica>, <https://www.monetdb.org/about-us/monetdb-history/>
- **注意事項**: MonetDBはフランスの印象派画家クロード・モネにちなんで命名
- **記事での表現**: 列指向ストレージは1996年のSybase IQに始まり、2000年代のMonetDB、C-Store/Verticaで花開いた

## 13. Google AlloyDBとHTAP

- **結論**: Google I/O 2022で発表。PostgreSQL互換のフルマネージドDB。列指向エンジンを内蔵し、分析クエリで標準PostgreSQLの最大100倍高速。トランザクションワークロードでも4倍以上高速。行指向と列指向を自動で使い分ける
- **一次ソース**: Google Cloud Blog, "New AlloyDB for PostgreSQL frees you from legacy databases"
- **URL**: <https://cloud.google.com/blog/products/databases/introducing-alloydb-for-postgresql>
- **注意事項**: TiDB TiFlashと並ぶHTAPの代表例
- **記事での表現**: 2022年にGoogleがAlloyDBを発表し、PostgreSQL互換でありながらHTAPを実現した

## 14. Amazon Redshift（2012年）

- **結論**: 2012年11月のAWS re:Inventで Andy Jassyがプレビューを発表。2013年2月15日にGA。ペタバイト規模のフルマネージドクラウドデータウェアハウス。列指向ストレージとMPP（超並列処理）アーキテクチャ。AWSで最も急成長したサービスの一つ
- **一次ソース**: Amazon Science, "Amazon Redshift: Ten years of continuous reinvention"
- **URL**: <https://www.amazon.science/latest-news/amazon-redshift-ten-years-of-continuous-reinvention>
- **注意事項**: GA日は2013年2月だが、発表は2012年11月
- **記事での表現**: 2012年にAmazonがRedshiftを発表し、クラウド上のフルマネージド列指向データウェアハウスを実現した
