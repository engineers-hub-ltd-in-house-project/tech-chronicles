# ファクトチェック記録：第9回「ストアドプロシージャとトリガー——ロジックはどこに置くべきか」

## 1. Sybase SQL Serverにおけるストアドプロシージャとトリガーの起源

- **結論**: Sybase SQL Serverは1987年5月にSunワークステーション向けUNIX版として最初の商用版を出荷した。Sybase SQL Serverは、ストアドプロシージャとトリガーをサポートした最初の商用RDBMSとされ、コストベースクエリオプティマイザも備えていた。クライアント/サーバアーキテクチャを採用した最初のDBMSでもあり、従来のモノリシックな設計と一線を画した
- **一次ソース**: SAP Community Blog「A Deeper Look At Sybase: History of ASE」(2011); Ispirer「Sybase ASE History」; Database of Databases (dbdb.io)
- **URL**: <https://blogs.sap.com/2011/04/15/a-deeper-look-at-sybase-history-of-ase/>, <https://doc.ispirer.com/sqlways/Output/SQLWays-1-178.html>
- **注意事項**: ブループリントでは「1980年代後半」と記載。正確には1987年5月が最初の商用リリース。プリリリース版の時点でストアドプロシージャとトリガーは評価されていた
- **記事での表現**: 1987年、Sybase SQL Serverがストアドプロシージャとトリガーを備えた最初の商用RDBMSとして登場した

## 2. Oracle PL/SQLの歴史

- **結論**: PL/SQL 1.0はSQL*Forms v3.0とともに最初に導入された。1991年にOracle 6のTransaction Processing Optionの一部としてサーバサイドでのPL/SQL実行が可能になったが、このバージョンではストアドプロシージャの保存・再利用はできなかった。PL/SQL 2.0がOracle 7.0（1992年）とともに出荷され、ストアドプロシージャ・ストアドファンクションの作成と保存が初めて可能になった。言語設計はAda言語の影響を強く受けている
- **一次ソース**: O'Reilly「Oracle PL/SQL Programming」Chapter 1.3 "The Origins of PL/SQL"; Oracle FAQ「PL/SQL」; Wikipedia「PL/SQL」
- **URL**: <https://www.orafaq.com/wiki/PL/SQL>, <https://www.oreilly.com/library/view/oracle-pl-sql-programming/9780596805401/ch01s02.html>
- **注意事項**: ブループリントでは「PL/SQL（Oracle、1991年）」と記載。サーバサイドPL/SQL実行は1991年だが、ストアドプロシージャとして保存可能になったのは1992年のPL/SQL 2.0（Oracle 7.0）から
- **記事での表現**: 1991年にOracle 6でサーバサイドPL/SQLが登場し、1992年のOracle 7.0（PL/SQL 2.0）でストアドプロシージャの保存と再利用が実現した

## 3. T-SQLの起源（Microsoft SQL ServerとSybaseの関係）

- **結論**: 1988年1月、MicrosoftはAshton-TateおよびSybaseと共同で、IBM OS/2向けのSybase SQL Serverの派生版を開発する契約を結んだ。最初のMicrosoft SQL Server v1.0は1989年にリリースされた。製品はSybase SQL Server 3.0ベースで、1994年まで3つのSybase著作権表示を含んでいた。1993年7月のWindows NT発売前後にSybaseとMicrosoftは袂を分かち、それぞれ独自の設計・マーケティング路線を進めた。SQL Server 2005でレガシーSybaseコードは完全に書き換えられた。T-SQL（Transact-SQL）はSybaseが開発した手続き型SQL拡張で、Microsoft SQL Serverにも引き継がれた
- **一次ソース**: Wikipedia「History of Microsoft SQL Server」; LearnSQL.com「A Brief History of MS SQL Server」; SQLShack「TSQL History」
- **URL**: <https://en.wikipedia.org/wiki/History_of_Microsoft_SQL_Server>, <https://www.sqlshack.com/tsql-history/>
- **注意事項**: ブループリントではT-SQL（Microsoft SQL Server）と記載。歴史的にはSybase起源
- **記事での表現**: T-SQLはSybaseが開発した手続き型SQL拡張で、1989年にMicrosoft SQL Server v1.0にも採用された。両社は1993年に袂を分かった

## 4. PL/pgSQLの歴史

- **結論**: PL/pgSQL（Procedural Language/PostgreSQL）はJan Wieckによって実装され、PostgreSQL 6.4（1998年10月30日リリース）で初登場した。Oracle PL/SQLの影響を強く受けており、構文が類似している。PL/pgSQL、PL/SQL、SQL/PSMのいずれもAda言語の影響下にある。なおPostgreSQLでCREATE PROCEDUREコマンドが使えるようになったのはPostgreSQL 11（2018年）からで、それ以前はCREATE FUNCTIONでvoid型を返す形で代替していた
- **一次ソース**: Wikipedia「PL/pgSQL」; PostgreSQL Documentation
- **URL**: <https://en.wikipedia.org/wiki/PL/pgSQL>, <https://www.postgresql.org/docs/current/plpgsql.html>
- **注意事項**: PostgreSQL 11以前は「ストアドプロシージャ」という概念がなく、すべて「関数」として扱われていた。CREATE PROCEDUREの導入によりトランザクション制御が可能になった
- **記事での表現**: PL/pgSQLは1998年のPostgreSQL 6.4で登場し、Oracle PL/SQLに似た構文を採用した。正式なCREATE PROCEDUREは2018年のPostgreSQL 11で導入された

## 5. SQL/PSM標準の歴史

- **結論**: SQL/PSM（SQL/Persistent Stored Modules）は、ストアドプロシージャのためのISO標準言語拡張である。1990年頃からJim Meltonを中心とするANSI SQL委員会のグループが開発を開始。1996年にSQL-92の拡張として初版が公開された（ISO/IEC 9075-4:1996、PSM-96とも呼ばれる）。その後SQL:1999標準に統合され、以降Part 4として継続。商用DBの独自言語（PL/SQL 1992年、T-SQL 1995年、SPL 1996年）が先行し、標準化が後追いとなった
- **一次ソース**: Wikipedia「SQL/PSM」; CodeDocs「SQL/PSM」
- **URL**: <https://en.wikipedia.org/wiki/SQL/PSM>
- **注意事項**: SQL/PSMはOracle PL/SQLから派生したとされる。標準は存在するが、各ベンダーは独自の実装を維持しており、互換性は低い
- **記事での表現**: 1996年、SQL/PSM（Persistent Stored Modules）が国際標準化されたが、各ベンダーの独自実装が先行していたため、互換性の問題は解消されなかった

## 6. MySQLにおけるストアドプロシージャのサポート

- **結論**: MySQLは5.0（2005年10月正式リリース、ベータ版は2005年3月）でストアドプロシージャ、トリガー、ビュー、カーソル、XAトランザクションを導入した。それ以前のMySQLにはストアドプロシージャ機能がなかった
- **一次ソース**: MySQL公式ドキュメント「MySQL 5.0 Stored Procedures」; Wikipedia「MySQL」
- **URL**: <https://dev.mysql.com/doc/refman/5.7/en/faqs-stored-procs.html>, <https://en.wikipedia.org/wiki/MySQL>
- **注意事項**: MySQLが商用DB・PostgreSQLと比較して相当遅くストアドプロシージャをサポートした点は記事で言及する価値がある
- **記事での表現**: MySQLがストアドプロシージャをサポートしたのは2005年の5.0からで、Oracle（1992年）やPostgreSQL（1998年）と比較して大幅に遅い参入だった

## 7. Martin Fowlerのドメインロジックに関する議論

- **結論**: Martin Fowlerは2003年の著書『Patterns of Enterprise Application Architecture』で、ドメインロジックの組織化パターンとしてTransaction Script、Domain Model、Table Moduleの3つを定義した。また「Domain Logic and SQL」という記事で、ビジネスロジックをSQLやストアドプロシージャに置くことの是非を論じている。ビューやストアドプロシージャによるカプセル化には限界があり、複数データソースの場合はアプリケーション層での完全なカプセル化が必要と指摘
- **一次ソース**: Martin Fowler「Domain Logic and SQL」(martinfowler.com); Martin Fowler『Patterns of Enterprise Application Architecture』(2002年)
- **URL**: <https://martinfowler.com/articles/dblogic.html>, <https://martinfowler.com/eaaCatalog/>
- **注意事項**: Fowlerの立場はアプリケーション層へのロジック集約寄りだが、SQLの表現力自体は認めている
- **記事での表現**: Martin Fowlerは2003年の著書でドメインロジックのパターンを整理し、ストアドプロシージャによるカプセル化の限界を指摘した

## 8. ストアドプロシージャの利点と欠点

- **結論**: 利点としてはネットワークラウンドトリップ削減、セキュリティ境界の確保（定義者権限での実行）、コード再利用性、データ近接処理による高性能が挙げられる。欠点としてはテスト困難（単体テスト不可、モック/スタブ不可）、デバッグ困難（DB製品により対応差あり）、バージョン管理の困難さ（ゼロダウンタイムデプロイが困難）、ベンダーロックイン、ドメインロジックの分断（アプリケーション層とDB層にロジックが分散）が挙げられる
- **一次ソース**: GeeksforGeeks「Advantages and Disadvantages of Using Stored Procedures」; dusted.codes「Drawbacks of Stored Procedures」; Jeff Atwood「Who Needs Stored Procedures, Anyways?」(Coding Horror)
- **URL**: <https://www.geeksforgeeks.org/sql/advantages-and-disadvantages-of-using-stored-procedures-sql/>, <https://dusted.codes/drawbacks-of-stored-procedures>, <https://blog.codinghorror.com/who-needs-stored-procedures-anyways/>
- **注意事項**: モダンなアプリケーション開発ではストアドプロシージャの使用は減少傾向。マイクロサービス、CI/CD、頻繁なデプロイとの相性が悪い
- **記事での表現**: ストアドプロシージャはネットワーク効率とセキュリティに優れるが、テスト・デバッグ・バージョン管理の困難さがモダン開発の要件と衝突する

## 9. データベースマイグレーションツール（Flyway, Liquibase）

- **結論**: Flyway（Redgate）とLiquibase はデータベーススキーマの変更管理ツール。FlywayはSQLベースのマイグレーション、Liquibaseは XML/YAML/JSON/SQL の複数形式に対応。いずれもストアドプロシージャやトリガーを含む複雑なマイグレーションを管理できる。ORMのマイグレーション機能では扱いにくいストアドプロシージャの管理を補完する役割を果たしている
- **一次ソース**: Bytebase「Flyway vs Liquibase in 2026」; Baeldung「Liquibase vs Flyway」
- **URL**: <https://www.bytebase.com/blog/flyway-vs-liquibase/>, <https://www.baeldung.com/liquibase-vs-flyway>
- **注意事項**: これらのツールの存在はストアドプロシージャのバージョン管理問題を部分的に解消するが、テスト困難やデバッグ困難の根本的解決にはならない
- **記事での表現**: Flyway やLiquibase はスキーマ変更の管理を体系化したが、ストアドプロシージャの本質的な保守性の問題は残っている

## 10. Thick Database vs Thin Database パラダイム

- **結論**: 「Thick Database」パラダイム（Fat DB）はRDBMSにビジネスロジックを集中させる設計思想で、参照整合性の厳格な適用、第三正規形のデータモデル、ストアドプロシージャによるトランザクショナルAPIを特徴とする。特にOracle Databaseの文化圏で強く推奨された。対して「Thin Database」アプローチはDBを純粋なストレージとして扱い、ロジックをアプリケーション層に置く。2010年代以降、マイクロサービスやCI/CDの普及に伴い、Thin Databaseアプローチが主流に
- **一次ソース**: Mike Smithers「What's Special About Oracle? Relational Databases and the Thick Database Paradigm」(2016); Martin Fowler「Domain Logic and SQL」
- **URL**: <https://mikesmithers.wordpress.com/2016/06/03/whats-special-about-oracle-relational-databases-and-the-thick-database-paradigm/>, <https://martinfowler.com/articles/dblogic.html>
- **注意事項**: Thick Databaseは完全に否定されたわけではなく、データ整合性が最重要な金融系などでは依然として有効。ただし主流はThin Database方向へ移行
- **記事での表現**: 2000年代の「ファットDB」アーキテクチャは、Oracle文化圏で特に強く推奨された。2010年代以降、アプリケーション層へのロジック移行（「シンDB」）が主流になった
