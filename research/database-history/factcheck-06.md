# ファクトチェック記録：第6回「Oracle, DB2, PostgreSQL——商用とOSSの系譜」

## 1. Oracle V2（1979年）——世界初の商用SQL RDBMS

- **結論**: 1977年にLarry Ellison, Bob Miner, Ed OatesがSoftware Development Laboratories（SDL）を設立。1979年6月、Relational Software, Inc.（RSI、SDLから改名）がOracle V2をVAXコンピュータ向けにリリース。世界初の商用SQL RDBMSとされる。V1は社内プロトタイプで出荷されなかったためV2が最初の商用版。
- **一次ソース**: Oracle Corporation, "50 Years of the Relational Database"; Oracle Profit Magazine Timeline
- **URL**: <https://www.oracle.com/database/50-years-relational-database/>, <https://www.oracle.com/us/corporate/profit/p27anniv-timeline-151918.pdf>
- **注意事項**: 会社名の変遷: SDL (1977) → RSI → Oracle Systems Corporation (1982-1983年頃) → Oracle Corporation。改名時期は1982年説と1983年説がある。
- **記事での表現**: 1979年6月、Relational Software, Inc.がOracle V2を発表した。世界初の商用SQL RDBMSである。

## 2. Oracle Version 3（1983年）——C言語による移植性革命

- **結論**: 1983年3月、Oracle Version 3をリリース。C言語で書き直され、メインフレーム・ミニコンピュータ・パーソナルコンピュータで動作する初のRDBMSとなった。C言語への移行はBruce Scottが推進し、アセンブリ言語を支持するBob Minerの抵抗を押し切った。
- **一次ソース**: Oracle公式歴史ページ; 複数のOracle歴史資料
- **URL**: <https://content.dsp.co.uk/the-history-of-oracle-1977-2000>
- **注意事項**: Version 3のリリースにより売上が倍増し500万ドルに到達したとされる。
- **記事での表現**: 1983年、Oracle Version 3がリリースされた。C言語で全面書き直しされたことにより、単一のコードベースで複数プラットフォームに対応する初のRDBMSとなった。

## 3. IBM SQL/DS（1981年）とDB2（1983年）

- **結論**: IBM SQL/DS（SQL/Data System）は1981年にDOS/VSEおよびVM/CMS向けにリリース。IBMとして初の商用リレーショナルデータベース製品。DB2は1983年にMVSメインフレーム向けに発表され、1985年に一般利用可能（GA）となった。1989年までにDB2の売上は約10億ドルに達し、IMSと同等になった。
- **一次ソース**: IEEE Annals of the History of Computing, "SQL/DS: IBM's First RDBMS"; IBM公式歴史ページ
- **URL**: <https://dl.acm.org/doi/10.1109/MAHC.2013.28>, <https://www.ibm.com/history/relational-database>
- **注意事項**: SQL/DSの一般利用可能は1982年とする資料もある（発表と出荷の時期の差）。
- **記事での表現**: IBMは1981年にSQL/DSを、1983年にDB2を市場に投入した。特にDB2はMVSメインフレーム向けの戦略製品として位置づけられた。

## 4. Ingres（1974年、UC Berkeley、Michael Stonebraker）

- **結論**: Michael StonebrakerとEugene Wongが1974年にUC BerkeleyでIngres（Interactive Graphics and Retrieval System）のプロトタイプを完成。DARPA、ARO、NSFなどの助成金と学生の労力で開発。問い合わせ言語QUELを使用。1980年にStonebraker自身がRelational Technology, Inc.を共同設立し商用化。Ingres出身の学生がBritton-Lee、Tandem NonStop SQL、Sybaseなど多くのデータベース製品を生み出した。Stonebrakerは2014年チューリング賞受賞。
- **一次ソース**: ACM Turing Award公式; UC Berkeley EECS Technical Report
- **URL**: <https://amturing.acm.org/award_winners/stonebraker_1172121.cfm>, <https://www2.eecs.berkeley.edu/Pubs/TechRpts/1974/28785.html>
- **注意事項**: Ingresの名前はフランスの画家アングルにちなむ。
- **記事での表現**: 1974年、UC BerkeleyのMichael StonebrakerとEugene Wongが、リレーショナルデータベースIngresのプロトタイプを完成させた。

## 5. PostgreSQLの系譜（Postgres → Postgres95 → PostgreSQL）

- **結論**: 1986年、StonebrakerがUC BerkeleyでPOSTGRESプロジェクトを開始（DARPA等の助成）。1987年にデモシステムが動作。1989年にVersion 1を外部リリース。1994年、Andrew YuとJolly ChenがSQL言語インタプリタを追加。Berkeley POSTGRESプロジェクトはVersion 4.2で公式終了。1995年、Postgres95としてオープンソースでWebに公開。1996年、PostgreSQLに改名（SQLサポートを反映）。
- **一次ソース**: PostgreSQL公式ドキュメント "A Brief History of PostgreSQL"
- **URL**: <https://www.postgresql.org/docs/current/history.html>
- **注意事項**: POSTGRESの名前は「Post-Ingres」の意。Stonebrakerは1985年までBerkeleyでIngresを率い、その後POSTGRESに移行。
- **記事での表現**: 1986年、StonebrakerはIngresの後継としてPOSTGRESプロジェクトを開始した。1996年、SQLサポートを反映してPostgreSQLに改名された。

## 6. MySQL（1995年、Michael Widenius, David Axmark）

- **結論**: MySQL ABはスウェーデン人のDavid AxmarkとAllan Larsson、フィンランド人のMichael "Monty" Wideniusによって設立。開発は1994年に開始、最初のバージョンは1995年5月23日に登場。mSQLを基にISAMベースのストレージを使用。最初の外部リリースは1996年8月。TCX DataKonsult AB（1985年設立）が商業的代理を担当。
- **一次ソース**: Wikipedia "MySQL"; Oracle MySQL Blog "MySQL Retrospective – The Early Years"
- **URL**: <https://en.wikipedia.org/wiki/MySQL>, <https://blogs.oracle.com/mysql/mysql-retrospective-the-early-years>
- **注意事項**: 共同設立者は3人（Axmark, Larsson, Widenius）。ブループリントではAxmarkとWideniusの2人のみ記載。Larssonも含めるべき。
- **記事での表現**: 1995年、Michael "Monty" Widenius、David Axmark、Allan Larssonが開発したMySQLの最初のバージョンが公開された。

## 7. SQL Server（1989年、Microsoft/Sybase/Ashton-Tate共同開発）

- **結論**: 1988年1月、Microsoft、Sybase、Ashton-Tateが共同開発契約を発表。SybaseがUNIX向けに開発していたリレーショナルデータベースサーバ技術をMicrosoftにライセンスし、OS/2向けに適応。1989年にSQL Server v1.0（16ビット、OS/2向け）をリリース。Sybase SQL Server 3.0 for UNIX/VMSがベース。
- **一次ソース**: Wikipedia "History of Microsoft SQL Server"; LearnSQL.com "A Brief History of MS SQL Server"
- **URL**: <https://en.wikipedia.org/wiki/History_of_Microsoft_SQL_Server>, <https://learnsql.com/blog/history-ms-sql-server/>
- **注意事項**: ブループリントでは「Microsoft, Sybase共同開発」とあるが、実際にはAshton-Tateも参加していた（3社共同）。
- **記事での表現**: 1989年、Microsoft、Sybase、Ashton-Tateの3社共同でOS/2向けSQL Server v1.0がリリースされた。

## 8. OracleのMVCCとRAC

- **結論**: OracleはUndo（Rollback）セグメントを使用したMVCC実装を持つ。読み取り一貫性を提供し、読み取りが書き込みをブロックしない設計。MVCC概念自体は1978年のDavid P. Reedの博士論文、1981年のBernstein & Goodmanの論文で体系化。最初の商用MVCC実装はDEC VAX Rdb/ELN（1984年、Jim Starkey）。Oracle RAC（Real Application Clusters）は2001年のOracle 9iで導入。前身はOracle Parallel Server（OPS、Oracle 7で1992年に導入）。RACはCache Fusionによるメモリ間直接ブロック転送が革新。
- **一次ソース**: Oracle公式ドキュメント; Wikipedia "Multiversion concurrency control"; Wikipedia "Oracle RAC"
- **URL**: <https://docs.oracle.com/en/database/oracle/oracle-database/19/cncpt/data-concurrency-and-consistency.html>, <https://en.wikipedia.org/wiki/Oracle_RAC>
- **注意事項**: Oracle自体がMVCCの「発明者」ではないが、商用RDBMSへの早期実装者の一つ。
- **記事での表現**: OracleはUndoセグメントを用いたMVCCを実装し、「読み取りが書き込みをブロックしない」読み取り一貫性を実現した。RACは2001年のOracle 9iで導入された。

## 9. MySQLのプラガブルストレージエンジンとInnoDB

- **結論**: MySQLはプラガブルストレージエンジンアーキテクチャを採用。MySQL 5.5（2010年12月リリース）以前はMyISAMがデフォルト。MyISAMはISAMストレージエンジンの後継で、テーブルレベルロック、トランザクション非対応。InnoDB は1995年にHeikki TuuriがInnobase Oyを設立して開発開始。ACID準拠、行レベルロック、MVCC対応。2005年10月にOracleがInnobase Oyを買収。MySQL 5.5以降はInnoDBがデフォルト。
- **一次ソース**: MySQL公式ドキュメント "Alternative Storage Engines"; Wikipedia "Innobase"
- **URL**: <https://dev.mysql.com/doc/refman/8.4/en/storage-engines.html>, <https://en.wikipedia.org/wiki/Innobase>
- **注意事項**: OracleによるInnobase買収（2005年）はSunによるMySQL買収（2008年）より前であり、MySQL コミュニティに動揺を与えた。
- **記事での表現**: MySQLの特徴的なアーキテクチャ決定がプラガブルストレージエンジンだ。MySQL 5.5以前のデフォルトはMyISAMだったが、2010年のMySQL 5.5でInnoDBがデフォルトに変更された。

## 10. SunによるMySQL買収とOracle買収、MariaDBフォーク

- **結論**: 2008年2月26日、Sun MicrosystemsがMySQL ABを10億ドルで買収完了。2009年4月20日、OracleがSun Microsystemsを74億ドルで買収すると発表。2010年1月27日に買収完了。欧州委員会がMySQL関連の懸念から調査を行い、承認が遅れた。Michael Wideniusは2009年にMariaDBの開発を開始し、MySQLからフォーク。
- **一次ソース**: Wikipedia "Acquisition of Sun Microsystems by Oracle Corporation"; Wikipedia "MySQL AB"
- **URL**: <https://en.wikipedia.org/wiki/Acquisition_of_Sun_Microsystems_by_Oracle_Corporation>, <https://en.wikipedia.org/wiki/MySQL_AB>
- **注意事項**: MariaDBの開発開始は2009年だが、公式ローンチは2010年頃。ブループリントの「MariaDBのフォーク（2009年、Michael Widenius）」は開発開始時期として正確。
- **記事での表現**: 2008年、Sun MicrosystemsがMySQL ABを10億ドルで買収した。2010年、OracleがSunを買収すると、WideniusはMySQLをフォークしてMariaDBを立ち上げた。
