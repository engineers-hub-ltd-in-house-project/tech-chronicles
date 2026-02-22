# ファクトチェック記録：第11回「レプリケーションとシャーディング——スケールの壁を越える」

## 1. MySQLレプリケーションの導入時期

- **結論**: MySQLはバージョン3.23.15（2000年5月）でStatement-Based Replication（SBR）を導入した。バイナリログにSQL文を記録し、スレーブで再実行する方式。Row-Based Replication（RBR）はMySQL 5.1で導入された。MySQL 5.7.7以降、デフォルトのbinlog_formatがSTATEMENTからROWに変更された
- **一次ソース**: MySQL 5.7 Reference Manual, "Replication Formats"; Marcelo Altmann, "A Brief History of MySQL Replication"
- **URL**: <https://dev.mysql.com/doc/refman/5.7/en/replication-formats.html>, <https://altmannmarcelo.medium.com/a-brief-history-of-mysql-replication-85f057922800>
- **注意事項**: MySQL 8.0.26で用語変更（master→source, slave→replica）
- **記事での表現**: MySQLは2000年、バージョン3.23.15でレプリケーション機能を導入した。当初はStatement-Based Replication（SBR）のみで、マスタで実行されたSQL文をそのままスレーブで再実行する方式だった

## 2. PostgreSQLストリーミングレプリケーション

- **結論**: PostgreSQL 9.0（2010年9月20日リリース）でストリーミングレプリケーションとHot Standbyが導入された。NTT OSSセンターのFujii Masaoが主要開発者。Heikki Linnakangas が2010年1月15日にコミットした
- **一次ソース**: PostgreSQL 9.0 Press Release; PostgreSQL Wiki "Streaming Replication"
- **URL**: <https://www.postgresql.org/about/news/postgresql-90-final-release-available-now-1235/>, <https://wiki.postgresql.org/wiki/Streaming_Replication>
- **注意事項**: 9.0以前はWALファイル単位の転送（WAL Shipping）のみだった
- **記事での表現**: PostgreSQLは長らくレプリケーションを外部ツール（Slony-I等）に頼っていたが、2010年のバージョン9.0でストリーミングレプリケーションを組み込んだ

## 3. PostgreSQL論理レプリケーション

- **結論**: PostgreSQL 10（2017年10月5日リリース）でネイティブの論理レプリケーションが導入された。論理レプリケーションの基盤（logical decoding）はPostgreSQL 9.4で導入されていた
- **一次ソース**: PostgreSQL 10 Release Announcement
- **URL**: <https://www.postgresql.org/about/news/postgresql-10-released-1786/>
- **注意事項**: 9.4以前はサードパーティの拡張（pglogical等）が必要だった
- **記事での表現**: PostgreSQL 10（2017年）でネイティブの論理レプリケーションが導入され、テーブル単位でのレプリケーションが可能になった

## 4. MySQL半同期レプリケーション

- **結論**: MySQL 5.5でプラグインとして半同期レプリケーションが導入された。少なくとも1台のスレーブがバイナリログイベントを受信・記録したことを確認してからコミットを完了する方式
- **一次ソース**: MySQL 5.7 Reference Manual, "Semisynchronous Replication"
- **URL**: <https://dev.mysql.com/doc/refman/5.7/en/replication-semisync.html>
- **注意事項**: 完全な同期ではなく「半同期」——スレーブでの実行完了は待たない
- **記事での表現**: MySQL 5.5で半同期レプリケーションがプラグインとして導入され、少なくとも1台のスレーブがイベントを受領したことを確認してからコミットを完了する方式が可能になった

## 5. Google Bigtable論文

- **結論**: "Bigtable: A Distributed Storage System for Structured Data" は2006年11月、OSDI '06（第7回USENIX Symposium on Operating Systems Design and Implementation、シアトル）で発表。著者はFay Chang, Jeffrey Dean, Sanjay Ghemawat, Wilson C. Hsieh, Deborah A. Wallach, Mike Burrows, Tushar Chandra, Andrew Fikes, Robert E. Gruber
- **一次ソース**: USENIX OSDI '06 Proceedings
- **URL**: <https://www.usenix.org/conference/osdi-06/bigtable-distributed-storage-system-structured-data>
- **注意事項**: Bigtable自体は2004年頃からGoogle社内で運用開始。論文発表は2006年
- **記事での表現**: 2006年、GoogleはBigtable論文を発表し、数千台のコモディティサーバにペタバイト規模のデータを分散格納するアーキテクチャを公開した

## 6. CAP定理

- **結論**: Eric Brewerが2000年7月19日、PODC（Principles of Distributed Computing）の基調講演 "Towards Robust Distributed Systems" で提唱。2002年にSeth GilbertとNancy Lynch（MIT）が "Brewer's Conjecture and the Feasibility of Consistent, Available, Partition-Tolerant Web Services" で形式的に証明
- **一次ソース**: Brewer's PODC 2000 keynote slides; Gilbert & Lynch, ACM SIGACT News, 2002
- **URL**: <https://people.eecs.berkeley.edu/~brewer/cs262b-2004/PODC-keynote.pdf>, <https://dl.acm.org/doi/10.1145/564585.564601>
- **注意事項**: Brewerは2000年時点で「予想（conjecture）」として提示。定理として確立されたのは2002年のGilbert & Lynchの証明以降
- **記事での表現**: 2000年、Eric BrewerはPODCの基調講演でCAP予想を提唱した。2002年にMITのSeth GilbertとNancy Lynchがこれを形式的に証明し、「CAP定理」として確立された

## 7. Vitessの歴史

- **結論**: VitessはYouTubeで2010年に開発開始。MySQLのシャーディングミドルウェアとして、アプリケーション層からシャーディングロジックを分離するプロキシとして設計された。2011年にオープンソース化。CNCF（Cloud Native Computing Foundation）のプロジェクトとなり、Slack, Pinterest, GitHubなどが採用
- **一次ソース**: Vitess公式ドキュメント "History"
- **URL**: <https://vitess.io/docs/20.0/overview/history/>
- **注意事項**: PlanetScaleはVitessをベースとしたサービス
- **記事での表現**: YouTubeは2010年、MySQLのシャーディングを透過的に行うミドルウェアVitessを開発し、2011年にオープンソース化した

## 8. Consistent Hashing

- **結論**: 1997年、David Karger, Eric Lehman, Frank Thomson Leighton, Rina Panigrahy, Matthew S. Levine, Daniel Lewinが "Consistent Hashing and Random Trees: Distributed Caching Protocols for Relieving Hot Spots on the World Wide Web" をSTOC '97で発表
- **一次ソース**: Proceedings of STOC '97, pp. 654-663
- **URL**: <https://dl.acm.org/doi/10.1145/258533.258660>
- **注意事項**: Amazon Dynamo論文（2007年）でConsistent Hashingが分散データベースの文脈で広く知られるようになった
- **記事での表現**: Consistent Hashingは1997年にKargerらがSTOCで発表したアルゴリズムで、ノードの追加・削除時に再配置されるデータを最小化する

## 9. Shardingの語源

- **結論**: "shard"という用語の起源は、1986年のComputer Corporation of Americaの論文 "A System for Highly Available Replicated Data" か、1997年のMMORPG「Ultima Online」のいずれかに由来するとされる。データベース文脈での水平分割（horizontal partitioning）を複数サーバに分散配置する手法
- **一次ソース**: Wikipedia "Shard (database architecture)"
- **URL**: <https://en.wikipedia.org/wiki/Shard_(database_architecture)>
- **注意事項**: 用語の正確な起源は確定していない
- **記事での表現**: シャーディングの「シャード（shard）」は「破片」を意味し、一つのテーブルを複数のサーバに分散配置する手法を指す

## 10. Spider Storage Engine

- **結論**: SpiderはKentoku SHIBAが開発したMySQL/MariaDB用のシャーディングストレージエンジン。MariaDB 10.0.4からバンドルされた。テーブルパーティショニング機能を使ってデータベースシャーディングを実現する
- **一次ソース**: MariaDB Spider Storage Engine documentation; Kentoku Shiba presentations
- **URL**: <https://mariadb.org/wp-content/uploads/2014/05/Spider_in_MariaDB_20140403.pdf>
- **注意事項**: MySQL本体にはビルトインのシャーディング機能は存在せず、外部ミドルウェアに依存
- **記事での表現**: MariaDBはSpider Storage Engineをバンドルし、ストレージエンジンレベルでのシャーディングを提供したが、MySQL本体にはシャーディング機能が組み込まれることはなかった
