# ファクトチェック記録：第16回「時系列DB, グラフDB——専門特化の進化」

## 1. RRDtool

- **結論**: 1999年にTobias Oetikerが初版をリリース。MRTG（Multi Router Traffic Grapher、1995年）の後継として設計。Round Robin Database形式で固定サイズのファイルにデータを格納し、古いデータを自動的にダウンサンプリングする。設計は1997年末から開始された
- **一次ソース**: Tobias Oetiker, RRDtool公式サイト
- **URL**: <https://oss.oetiker.ch/rrdtool/>
- **注意事項**: RRDtoolは「データベース」というよりは「データロギング・グラフ描画システム」に近い。時系列DBの直接の先祖ではないが、時系列データ専用のストレージ設計という意味で先駆的
- **記事での表現**: 「1999年、Tobias OetikerはMRTGの限界を超えるためにRRDtoolを公開した」

## 2. InfluxDB

- **結論**: Paul DixとTodd Persenが2012年にErrplaneを設立。2013年にY Combinator参加後、時系列データベースに方向転換しInfluxDBを開発。2013年後半にオープンソースとして公開。2014年11月にMayfield Fund, Trinity Venturesから8.1M Series A調達。InfluxQL（SQL風）、Flux（関数型）、InfluxDB 3.xでSQLに回帰
- **一次ソース**: InfluxData公式ブログ、Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/InfluxDB>
- **注意事項**: ブループリントには「2013年」とあり正確。正確には2013年後半にオープンソース公開
- **記事での表現**: 「2013年、Paul DixはInfluxDBをオープンソースとして公開した」

## 3. TimescaleDB

- **結論**: 2017年4月にAjay Kulkarni（CEO）とMichael J. Freedman（CTO、プリンストン大学教授）が設立。PostgreSQL拡張として開発。2018年11月に安定版1.0リリース。2025年6月にTigerDataに社名変更
- **一次ソース**: TimescaleDB Wikipedia, Timescale公式サイト
- **URL**: <https://en.wikipedia.org/wiki/TimescaleDB>
- **注意事項**: ブループリントの「2017年、PostgreSQL拡張」は正確。IoTワークロードへの対応がきっかけ
- **記事での表現**: 「2017年、Ajay KulkarniとMichael FreedmanはTimescaleDBを公開した」

## 4. Prometheus

- **結論**: 2012年にSoundCloudでMatt ProudとJulius Volzが開発開始。両名ともに元Google SRE。2012年2月にリサーチ開始、2012年8月にGoサーバ開発開始、2012年11月に公開リポジトリ。2015年1月にパブリックアナウンス（Hacker News #1）。2016年にKubernetesに次ぐCNCF第2のプロジェクトとして採用。2016年7月にPrometheus 1.0リリース
- **一次ソース**: SoundCloud Backstage Blog, PromLabs Blog
- **URL**: <https://developers.soundcloud.com/blog/prometheus-has-come-of-age-a-reflection-on-the-development-of-an-open-source-project/>
- **注意事項**: PrometheusはTSDB単体というよりは監視システム全体。Pull型のメトリクス収集モデルが特徴的
- **記事での表現**: 「2012年、SoundCloudの元Google SREであるMatt ProudとJulius VolzがPrometheusの開発を開始した」

## 5. Neo4j

- **結論**: 2007年1月23日設立。創業者はEmil Eifrem, Johan Svensson, Peter Neubauer。スウェーデンのマルメで設立、Neo Technology社の一部として。Emil Eifremは2000年にグラフデータベースの着想を得た（ムンバイ行きのフライト中、ナプキンにプロパティグラフモデルをスケッチ）。ECM（Enterprise Content Management）システム構築時にRDBの限界を認識。GPLライセンスでオープンソース化。2009年にSunstoneとConorからシード資金2.5M調達
- **一次ソース**: Neo4j公式、CanvasBusinessModel
- **URL**: <https://canvasbusinessmodel.com/blogs/brief-history/neo4j-brief-history>
- **注意事項**: ブループリントには「2007年、Neo4j Inc.」とあるが正確には「Neo Technology」として設立、後にNeo4j Inc.に改称
- **記事での表現**: 「2007年、Emil Eifrem、Johan Svensson、Peter NeubauerはスウェーデンでNeo4j（当時Neo Technology）を設立した」

## 6. Amazon Neptune

- **結論**: 2017年11月29日にAWS re:Invent 2017で発表。2018年5月30日に一般提供（GA）開始。Property GraphとW3C RDFの両モデルをサポート。クエリ言語としてApache TinkerPop Gremlin、openCypher、SPARQLをサポート。Blazegraphをベースに構築
- **一次ソース**: AWS Blog, TechCrunch, Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Amazon_Neptune>
- **注意事項**: ブループリントには「2017年」とあるが、発表が2017年、GAは2018年。記事では発表年と提供開始年を区別して記述する
- **記事での表現**: 「2017年11月、AWSはre:InventでグラフデータベースサービスAmazon Neptuneを発表し、2018年5月に一般提供を開始した」

## 7. GQL（Graph Query Language）ISO標準化

- **結論**: ISO/IEC 39075:2024として2024年4月12日に正式公開。1987年にSQLがISO標準化されて以来、ISOが公開した初の新データベースクエリ言語標準。2019年9月に国際標準化プロジェクトが承認。14の国家標準化機関が賛成、0が反対、6が棄権で承認
- **一次ソース**: ISO/IEC 39075:2024, GQL Standards
- **URL**: <https://www.iso.org/standard/76120.html>
- **注意事項**: ブループリントには「2024年ISO標準化」とあり正確。GQLはプロパティグラフ向けの宣言的クエリ言語
- **記事での表現**: 「2024年4月、ISOはGQL（Graph Query Language）をISO/IEC 39075として公開した」

## 8. インデックスフリー隣接（Index-Free Adjacency）

- **結論**: Neo4jのネイティブグラフストレージの核心概念。各ノードが隣接ノードへの直接参照（ポインタ）を持ち、インデックスルックアップなしに関係を辿れる。隣接ノードへのアクセスは常にO(1)。RDBのJOIN（O(log n)のインデックスルックアップ）との根本的な違い
- **一次ソース**: Neo4j Blog, Wikipedia (Graph database)
- **URL**: <https://en.wikipedia.org/wiki/Graph_database>
- **注意事項**: Index-Free Adjacencyはすべてのグラフデータベースが採用しているわけではない（例：Amazon NeptuneはBlazeGraphベースで異なるアーキテクチャ）
- **記事での表現**: 「Neo4jの核心的な設計がIndex-Free Adjacency（インデックスフリー隣接）だ」

## 9. Cypherクエリ言語

- **結論**: 2011年にNeo4j（当時Neo Technology）のAndrés Taylorが設計。SQLを意識した宣言的クエリ言語だが、グラフパターンマッチングに特化。2015年10月にopenCypherプロジェクトとしてオープン化（Oracle, Databricks, Tableauらが参加）。GQL（ISO/IEC 39075:2024）の設計に大きな影響を与えた
- **一次ソース**: Wikipedia (Cypher query language), openCypher.org
- **URL**: <https://en.wikipedia.org/wiki/Cypher_(query_language)>
- **注意事項**: CypherはNeo4j固有の言語だったが、openCypherプロジェクトで標準化への道が開かれ、GQLの基盤となった
- **記事での表現**: 「2011年、Neo4jのAndrés TaylorはCypherクエリ言語を設計した」

## 10. 時系列データの特性

- **結論**: 時系列データの主要特性: (1) 追記支配的（Append-only）——新しい観測を追加するだけで過去のデータは変更しない、(2) 時間ベースのクエリ——時間範囲での検索が中心、(3) ダウンサンプリング——古いデータの解像度を下げて保存、(4) リテンションポリシー——一定期間後に自動削除、(5) 圧縮——デルタエンコーディング、ラン レングスエンコーディングなどで高圧縮率
- **一次ソース**: Timescale Blog, TDengine Guide
- **URL**: <https://www.timescale.com/blog/what-is-a-time-series-database>
- **注意事項**: 技術的特性の説明であり、特定の年号・人名の検証は不要
- **記事での表現**: 技術論セクションで時系列データの特性として説明
