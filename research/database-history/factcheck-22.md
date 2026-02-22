# ファクトチェック記録：第22回「SQLの不死——なぜ50年経っても消えないのか」

## 1. SQL標準化の歴史（SQL-86からSQL:2023まで）

- **結論**: SQLは1986年にANSI標準として採択され（SQL-86）、1987年にISO標準となった。以降、SQL-89、SQL-92、SQL:1999、SQL:2003、SQL:2006、SQL:2008、SQL:2011、SQL:2016、SQL:2023と改訂を重ねている。SQL:2023（ISO/IEC 9075:2023）は2023年6月に正式採択された第9版
- **一次ソース**: ISO/IEC JTC 1, SC 32; The ANSI Blog
- **URL**: <https://blog.ansi.org/ansi/sql-standard-iso-iec-9075-2023-ansi-x3-135/>
- **注意事項**: SQL-92は標準文書が120ページから579ページに拡大した大改訂。SQL:1999でオブジェクトリレーショナル機能追加、SQL:2003でXML統合、SQL:2016でJSON対応、SQL:2023でProperty Graph Queries（SQL/PGQ）追加
- **記事での表現**: SQL標準化の50年史として、各版の主要追加機能を時系列で記述する

## 2. SEQUEL/SQLの誕生とSystem R

- **結論**: 1974年、IBM San Jose Research LaboratoryのDonald ChamberlinとRaymond BoyceがSEQUEL（Structured English Query Language）を開発。System Rプロジェクト（1974-1979年）で実装。SEQUELは英国Hawker Siddeley Dynamics Engineering Limited社の商標であったため、SQLに改名された
- **一次ソース**: Chamberlin, D. and Boyce, R., "SEQUEL: A Structured English Query Language", 1974; Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Donald_D._Chamberlin>
- **注意事項**: SEQUELという名前はIngresのQUELへの語呂合わせとも広く認識されている
- **記事での表現**: 第5回で既述のため、要約的に触れる

## 3. NoSQLの「Not Only SQL」への転換

- **結論**: NoSQLという用語は1998年にCarlo Strozziが自身の軽量RDBに命名したのが最初。2009年にJohan Oskarsson（Last.fm開発者）が「オープンソース分散非リレーショナルデータベース」を議論するイベントを組織し、用語を再導入。その後「Not Only SQL」と解釈されるようになった
- **一次ソース**: Wikipedia "NoSQL"; Martin Fowler "Nosql Definition"
- **URL**: <https://en.wikipedia.org/wiki/NoSQL>, <https://martinfowler.com/bliki/NosqlDefinition.html>
- **注意事項**: 2009年のOskarssonのイベントが現代的なNoSQLムーブメントの起点。Carlo Strozziの1998年のNoSQLは現代的意味とは異なる
- **記事での表現**: NoSQLブームの中でもSQLへの回帰が起きた文脈で使用

## 4. GoogleのMapReduceからSQL回帰（Dremel/BigQuery）

- **結論**: Google内部で2006年にAndrey Gubarevが「20%プロジェクト」としてDremelを考案。MapReduceのジョブ作成が煩雑で分析に時間がかかる問題をSQLインターフェースで解決。2010年にDremel論文発表（VLDB 2010）。2012年にBigQueryとして商用リリース
- **一次ソース**: Melnik, S. et al., "Dremel: Interactive Analysis of Web-Scale Datasets", VLDB 2010; Melnik, S. et al., "Dremel: A Decade of Interactive SQL Analysis at Web Scale", VLDB 2020
- **URL**: <https://www.vldb.org/pvldb/vol13/p3461-melnik.pdf>
- **注意事項**: Google自身がMapReduceの煩雑さからSQLに回帰した事実は、SQL不死の象徴的エピソード
- **記事での表現**: Google自身がSQLに「戻った」事実として記述

## 5. Apache Hive——HadoopにSQLを持ち込む

- **結論**: Apache HiveはFacebookのJoydeep Sen SarmaとAshish Thusooが開発。2010年にHadoopエコシステムのコンポーネントとして登場。HiveQL（SQLライクなクエリ言語）を提供し、内部でMapReduce/Tez/Sparkジョブに変換する
- **一次ソース**: Apache Hive公式サイト; Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Apache_Hive>
- **注意事項**: HiveはMapReduceの上にSQLインターフェースを載せた最初の主要プロジェクトの一つ
- **記事での表現**: MapReduceの世界にもSQLが「復帰」した例として記述

## 6. Presto/Trino——FacebookのSQLクエリエンジン

- **結論**: 2012年8月8日、FacebookのMartin Traverso、Dain Sundstrom、David Phillips、Eric Hwangが開発開始。約300PBのデータに対するHiveの性能限界を解決する目的。2013年11月にオープンソース化。2020年12月にPrestoSQLがTrinoにリブランド
- **一次ソース**: Wikipedia "Presto (SQL query engine)"; Starburst blog
- **URL**: <https://en.wikipedia.org/wiki/Presto_(SQL_query_engine)>
- **注意事項**: PrestoDB（Facebook/Meta維持）とTrino（元PrestoSQL、創設メンバー維持）の分岐に注意
- **記事での表現**: 分散データに対するSQLクエリエンジンとしてHive→Prestoの進化を記述

## 7. Spark SQL

- **結論**: Apache SparkにSQLコンポーネントが追加されたのは2014年。DataFrames抽象を導入し、構造化・半構造化データのサポートを提供。Spark自体は2009年にUC Berkeley AMPLabでMatei Zahariaが開発開始、2010年にオープンソース化
- **一次ソース**: Wikipedia "Apache Spark"
- **URL**: <https://en.wikipedia.org/wiki/Apache_Spark>
- **注意事項**: 前回記事でSparkの歴史は詳述済み。今回はSQLインターフェースの追加に焦点
- **記事での表現**: 新しい計算エンジンが登場してもSQLに回帰するパターンの例として記述

## 8. QUEL——SQLの最大のライバル

- **結論**: 1976年、UC BerkeleyのMichael StonebrakerとEugene WongがIngresプロジェクトの一部としてQUELを開発。タプル関係論理に基づく。多くの専門家がSQLより優れた言語と評価していた。1986年のANSI SQL標準化がQUELの衰退を決定づけた
- **一次ソース**: Stonebraker, M. and Wong, E., "The Design and Implementation of INGRES"; Holistics blog
- **URL**: <https://www.holistics.io/blog/quel-vs-sql/>
- **注意事項**: QUELは技術的に優れていたが、標準化の力でSQLが勝った——これはSQL不死の重要な論点
- **記事での表現**: 技術的優位性だけではSQL代替に成功しなかった例として記述

## 9. GraphQLの歴史

- **結論**: 2012年にFacebook内部で開発開始（モバイルアプリ再構築のため）。Lee Byron、Dan Schafer、Nick Schrock等が開発。2015年にオープンソース公開。RESTful APIやFQL（Facebook Query Language）の限界を解決する目的。データベースクエリ言語ではなくAPIクエリ言語
- **一次ソース**: Facebook Engineering blog, 2015年9月14日; Lee Byron Medium
- **URL**: <https://engineering.fb.com/2015/09/14/core-infra/graphql-a-data-query-language/>
- **注意事項**: GraphQLはSQLの代替ではなくREST APIの代替。データベース層ではなくAPI層の言語
- **記事での表現**: SQLの「代替」として挙げられることもあるが、レイヤーが異なる点を明確にする

## 10. SQL:2023の主要新機能（SQL/PGQ、JSON強化）

- **結論**: SQL:2023で新たにPart 16「Property Graph Queries（SQL/PGQ）」が追加。GRAPH_TABLE演算子でFROM句からグラフクエリを実行可能に。JSON関連では新しいアイテムメソッド（型変換中心）が追加され、JSON型の比較・ソート・グルーピング操作が定義された
- **一次ソース**: Peter Eisentraut blog "SQL:2023 is finished: Here is what's new", 2023年4月
- **URL**: <http://peter.eisentraut.org/blog/2023/04/04/sql-2023-is-finished-here-is-whats-new>
- **注意事項**: SQL/PGQはグラフDBの領域をSQL標準に取り込む動きであり、SQL標準の拡張性を示す重要な事例
- **記事での表現**: SQL標準が新しいデータモデル（グラフ）を取り込み続けている証拠として記述

## 11. Stack Overflow Developer Survey——SQL利用率

- **結論**: 2024年調査でSQLはプロフェッショナル開発者の54.1%が使用（第2位の言語）。PostgreSQLは最も人気のあるDB（49%→2025年は55.6%）。MySQL 40.3%、SQLite 33.1%（2024年）
- **一次ソース**: Stack Overflow Developer Survey 2024, 2025
- **URL**: <https://survey.stackoverflow.co/2024/technology>
- **注意事項**: SQLは言語としても上位にランクインしており、人的資本の膨大さを示すデータ
- **記事での表現**: SQLを書ける人間の数という「人的資本」がSQL不死の要因の一つとして引用

## 12. Datalogの歴史

- **結論**: 1977年にHerve GallaireとJack Minkerがフランス・トゥールーズでロジックとデータベースに関するワークショップを開催し、演繹データベースの分野を確立。Datalogという名称はDavid Maierが命名。論理プログラミングとデータベースの統合を目指した
- **一次ソース**: Wikipedia "Datalog"; Gallaire, H. and Minker, J. eds., "Logic and Data Bases", 1978
- **URL**: <https://en.wikipedia.org/wiki/Datalog>
- **注意事項**: DatalogはSQLの代替候補として学術的に研究されたが、実用では普及しなかった
- **記事での表現**: SQL以外のクエリ言語の試みとして簡潔に触れる
