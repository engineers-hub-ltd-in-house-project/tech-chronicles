# ファクトチェック記録：第8回「MySQL vs PostgreSQL——Web時代のRDB戦争」

## 1. LAMPスタックの起源と普及

- **結論**: LAMPという頭字語は1998年12月、ドイツのコンピュータ雑誌Computertechnikに掲載されたMichael Kunzeの記事で造語された。Linux, Apache, MySQL, PHP/Perl/Pythonの組み合わせが、高価な商用パッケージに対するオープンソースの代替手段として提示された。1990年代後半のドットコムバブル期にコスト面から急速に普及した
- **一次ソース**: Wikipedia「LAMP (software bundle)」; Tedium「LAMP Stack History」(2021)
- **URL**: <https://en.wikipedia.org/wiki/LAMP_(software_bundle)>
- **注意事項**: O'Reilly MediaとMySQL ABが共同でLAMPの普及に貢献した
- **記事での表現**: 1998年にドイツのコンピュータ雑誌でLAMPという頭字語が生まれ、オープンソースによるWeb開発スタックの代名詞となった

## 2. Sun MicrosystemsによるMySQL AB買収（2008年）

- **結論**: 2008年1月16日、Sun MicrosystemsはMySQL ABを約10億ドル（現金約8億ドル+ストックオプション約2億ドル）で買収する合意を発表した
- **一次ソース**: Sun Microsystems公式プレスリリース; TechCrunch報道（2008年1月16日）
- **URL**: <https://techcrunch.com/2008/01/16/sun-picks-up-mysql-for-1-billion-open-source-is-a-legitimate-business-model/>
- **注意事項**: 当時150億ドル規模とされたデータベース市場への参入が目的
- **記事での表現**: 2008年1月、Sun MicrosystemsがMySQL ABを約10億ドルで買収した

## 3. OracleによるSun買収とMySQLコミュニティの動揺

- **結論**: OracleがSun Microsystemsを買収し、2010年にMySQLがOracle傘下に入った。オープンソースコミュニティはOracleがMySQL開発を縮小するのではないかと懸念した
- **一次ソース**: Wikipedia「Acquisition of Sun Microsystems by Oracle Corporation」; tecmint.com記事
- **URL**: <https://en.wikipedia.org/wiki/Acquisition_of_Sun_Microsystems_by_Oracle_Corporation>
- **注意事項**: Oracleは自社のフラグシップ製品Oracle Databaseとの内部競合を懸念されていた
- **記事での表現**: 2010年、OracleがSunを買収しMySQLはOracle傘下に。コミュニティはMySQLの将来を危惧した

## 4. MariaDBのフォーク（2009年）

- **結論**: Michael "Monty" Widenius（MySQLの共同創設者）がOracleによるSun買収発表の日にMySQLをフォークし、MariaDBを立ち上げた。Monty Program Abは2009年2月に設立。MariaDBは末娘Mariaにちなんで命名。MariaDB Corporation ABは2010年に設立、MariaDB Foundationは2012年に設立
- **一次ソース**: Wikipedia「Michael Widenius」; Wikipedia「MariaDB」
- **URL**: <https://en.wikipedia.org/wiki/Michael_Widenius>
- **注意事項**: MariaDBはMySQLのドロップイン・リプレースメントとして設計された
- **記事での表現**: 2009年、MySQLの生みの親であるMonty WideniusがMariaDBをフォーク。末娘Mariaの名を冠した

## 5. MyISAM vs InnoDB——デフォルトストレージエンジンの変遷

- **結論**: MyISAMはMySQL 5.5以前のデフォルトストレージエンジン。InnoDB は1995年にHeikki Tuuriが設立したInnobase Oyで開発。2001年にMySQL 3.23のオプションプラグインとして初の公開リリース。2005年10月、OracleがInnobase Oyを買収。MySQL 5.5.5（2010年12月リリース）でInnoDBがデフォルトストレージエンジンに変更された
- **一次ソース**: Wikipedia「MyISAM」; Wikipedia「InnoDB」; Wikipedia「Innobase」
- **URL**: <https://en.wikipedia.org/wiki/InnoDB>
- **注意事項**: MyISAMはトランザクション非対応、外部キー制約非対応。InnoDBはACID準拠、外部キー制約対応
- **記事での表現**: MySQL 5.5（2010年）でInnoDBがデフォルトに。それまでのMyISAMはトランザクションも外部キー制約もサポートしていなかった

## 6. PostgreSQLの主要マイルストーン（8.0以降）

- **結論**:
  - 8.0（2005年1月19日）: Windows ネイティブサポート、Savepoints、Point-in-Time Recovery、Tablespaces
  - 8.1（2005年）: autovacuum（オプション機能として導入）、Two-Phase Commit、性能改善
  - 8.3（2008年）: autovacuumがデフォルトで有効化、マルチプロセスautovacuum
  - 9.0（2010年）: ストリーミングレプリケーション、Hot Standby
  - 9.1（2011年）: 同期レプリケーション、Serializable Snapshot Isolation（SSI）
- **一次ソース**: PostgreSQL公式ドキュメント Release Notes; EDB「History of improvements in VACUUM in PostgreSQL」
- **URL**: <https://www.postgresql.org/docs/8.4/release-8-0.html>
- **注意事項**: 8.0のWindows対応はPostgreSQLの普及拡大の重要な転換点
- **記事での表現**: PostgreSQL 8.0（2005年）でWindows対応を果たし、9.0（2010年）でストリーミングレプリケーションを獲得した

## 7. MySQLのレプリケーション方式の歴史

- **結論**: MySQL 3.23.15（2000年5月）でStatement-Based Replication（SBR）が導入。MySQL 5.1でRow-Based Replication（RBR）とMixed-Modeが追加。MySQL 5.7.7（2015年以降）でRow-Basedがデフォルトに変更
- **一次ソース**: MySQL公式ドキュメント「Replication Formats」; Marcelo Altmann「A Brief History of MySQL Replication」
- **URL**: <https://dev.mysql.com/doc/mysql-replication-excerpt/5.7/en/replication-formats.html>
- **注意事項**: SBRは非決定的な関数（NOW(), RAND()等）でレプリカとの不整合を起こしうる
- **記事での表現**: MySQL 3.23（2000年）でSBR、5.1でRBR追加、5.7.7でRBRがデフォルトに

## 8. PostgreSQLのVACUUM/autovacuumの歴史

- **結論**: autovacuumはPostgreSQL 8.1でオプション機能として導入。PostgreSQL 8.3（2008年）で初めてデフォルト有効化され、マルチプロセスアーキテクチャに移行した
- **一次ソース**: PostgreSQL公式ドキュメント「Routine Vacuuming」; EDB「History of improvements in VACUUM in PostgreSQL」
- **URL**: <https://www.enterprisedb.com/postgres-tutorials/history-improvements-vacuum-postgresql>
- **注意事項**: VACUUMはPostgreSQLのMVCC実装（テーブル内にバージョンを保持）に起因する固有の運用課題
- **記事での表現**: PostgreSQL 8.1でautovacuumが登場し、8.3（2008年）でデフォルト有効化

## 9. MySQLとPostgreSQLのアーキテクチャ比較（スレッド vs プロセス）

- **結論**: MySQLはスレッドベース（thread-per-connection）モデルで、1スレッドあたり約256KBのメモリ消費。PostgreSQLはプロセスベース（process-per-connection）モデルで、1接続あたり約9MBのメモリ消費。PostgreSQLのプロセスモデルは障害隔離性に優れるが、接続数のスケーリングにはコネクションプーリング（PgBouncer等）が必要
- **一次ソース**: Bytebase「Postgres vs. MySQL: a Complete Comparison in 2026」; 各種技術比較記事
- **URL**: <https://www.bytebase.com/blog/postgres-vs-mysql/>
- **注意事項**: メモリ消費量は設定やワークロードにより大きく変動する。具体的な数値は参考値
- **記事での表現**: MySQLのスレッドモデルは軽量で多数の同時接続に有利。PostgreSQLのプロセスモデルは障害隔離に優れるが接続プーリングが実質必須

## 10. DB-Engines RankingにおけるMySQL vs PostgreSQLの推移

- **結論**: DB-EnginesランキングではMySQLが2位、PostgreSQLが4位（2025年9月時点）。ただしPostgreSQLは継続的にスコアを伸ばし、DB-Engines DBMS of the Year を2017年、2018年、2023年、2024年に受賞。MySQLは2024年に125ポイントのスコア低下。2024年にPostgreSQLが年間DBMS賞を受賞（通算5回目）
- **一次ソース**: DB-Engines Ranking; DB-Engines「PostgreSQL is the DBMS of the Year 2023」
- **URL**: <https://db-engines.com/en/ranking_trend/system/MySQL;PostgreSQL>
- **注意事項**: DB-Enginesランキングは検索エンジンの言及、求人、SNS、技術サイトなどを基にしたメタスコアであり、実際の導入数とは異なる
- **記事での表現**: DB-EnginesランキングでPostgreSQLは2017年から年間DBMS賞を4回受賞し、MySQLとの差を着実に縮めている

## 11. MySQL版リリースと主要機能

- **結論**:
  - MySQL 5.0（2003年アルファ、2005年GA）: ストアドプロシージャ、ビュー、トリガー、カーソル
  - MySQL 5.1（2008年GA）: イベントスケジューラ、パーティショニング、Row-Based Replication
  - MySQL 5.5（2010年12月GA）: InnoDBデフォルト化、半同期レプリケーション
  - MySQL 5.6（2013年2月GA）: クエリオプティマイザ改善、Memcached API
  - MySQL 5.7（2015年10月GA）: JSON型、マルチソースレプリケーション
  - MySQL 8.0（2018年4月GA）: CTEウィンドウ関数、JSONの大幅強化
- **一次ソース**: Wikipedia「MySQL」; endoflife.date「MySQL」
- **URL**: <https://en.wikipedia.org/wiki/MySQL>
- **注意事項**: MySQL 6.0は開発中止、バージョンは5.7から8.0に飛んだ
- **記事での表現**: MySQLの主要バージョン変遷を年表で記述

## 12. WordPress/Drupal等CMSとMySQLの関係

- **結論**: WordPress（2003年）、Drupal（2001年）、Joomla（2005年）がLAMPスタック上で動作し、MySQLの普及を加速した。phpMyAdmin はMySQL管理の事実上の標準ツールとなり、ほぼすべてのレンタルサーバにプリインストールされた
- **一次ソース**: Wikipedia「phpMyAdmin」; 各種LAMP解説記事
- **URL**: <https://en.wikipedia.org/wiki/PhpMyAdmin>
- **注意事項**: WordPressは2025年時点でもWeb全体の40%以上のシェアを持ち、MySQLの最大の利用基盤
- **記事での表現**: WordPress（2003年）をはじめとするPHP製CMSがLAMPスタック上でMySQLを「デフォルトDB」にした
