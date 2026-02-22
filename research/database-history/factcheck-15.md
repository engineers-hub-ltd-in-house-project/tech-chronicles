# ファクトチェック記録：第15回「Cassandra, DynamoDB——分散と結果整合性の世界」

## 1. Amazon Dynamo論文

- **結論**: 2007年10月、SOSP（21st ACM Symposium on Operating Systems Principles）にて発表。正式タイトルは「Dynamo: Amazon's Highly Available Key-value Store」。著者はGiuseppe DeCandia, Deniz Hastorun, Madan Jampani, Gunavardhan Kakulapati, Avinash Lakshman, Alex Pilchin, Swaminathan Sivasubramanian, Peter Vosshall, Werner Vogels。Consistent Hashing、Vector Clocks、Sloppy Quorum、Anti-Entropyベースのリカバリを統合した最初の本番システム
- **一次ソース**: DeCandia et al., "Dynamo: Amazon's Highly Available Key-value Store", SOSP 2007
- **URL**: <https://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf>
- **注意事項**: Amazon DynamoとAmazon DynamoDBは別物。Dynamoは社内システム、DynamoDBは2012年のマネージドサービス。DynamoDBはDynamo論文の思想を受け継いでいるが、アーキテクチャは大きく異なる
- **記事での表現**: 「2007年、AmazonはSOSPにおいて『Dynamo: Amazon's Highly Available Key-value Store』を発表した」

## 2. Apache Cassandraの起源

- **結論**: FacebookのAvinash LakshmanとPrashant Malikが開発。Lakshmanは前述のDynamo論文の共著者でもある。Facebookの受信箱検索（Inbox Search）機能のために設計された。DynamoのP2P分散技術とBigtableのデータモデル（カラムファミリ）を組み合わせたハイブリッド設計
- **一次ソース**: Lakshman, Malik, "Cassandra - A Decentralized Structured Storage System", LADIS 2009
- **URL**: <https://www.cs.cornell.edu/projects/ladis2009/papers/lakshman-ladis2009.pdf>
- **注意事項**: ブループリントには「2008年、Facebook開発」とあるが、正確にはFacebook社内での開発は2007年頃から、OSSとしての公開が2008年7月
- **記事での表現**: 「Cassandraは2007年にFacebook社内で開発が始まり、2008年7月にオープンソースとして公開された」

## 3. Cassandraのオープンソース化とApacheプロジェクト化

- **結論**: 2008年7月にGoogle Codeでオープンソースとして公開。2009年1月（一部ソースでは3月）にApache Incubatorプロジェクトに。2010年2月17日にApacheトップレベルプロジェクトに昇格
- **一次ソース**: Apache Cassandra Wikipedia, Apache Incubator Wiki
- **URL**: <https://en.wikipedia.org/wiki/Apache_Cassandra>
- **注意事項**: Incubator入りの正確な月は「2009年1月」と「2009年3月」で情報源により差異あり。Wikipediaでは「March 2009」
- **記事での表現**: 「2009年3月にApache Incubatorプロジェクトとなり、2010年2月にトップレベルプロジェクトに昇格した」

## 4. Amazon DynamoDBのリリース

- **結論**: 2012年1月18日に一般提供開始。AWSのフルマネージドNoSQLデータベースサービス。Werner Vogels（Amazon CTO）が発表
- **一次ソース**: AWS Press Release, "Amazon Web Services Launches Amazon DynamoDB"
- **URL**: <https://press.aboutamazon.com/2012/1/amazon-web-services-launches-amazon-dynamodb-a-new-nosql-database-service-designed-for-the-scale-of-the-internet>
- **注意事項**: ブループリントの「2012年」は正確。DynamoDBはDynamo論文の名前を冠しているが、内部アーキテクチャはDynamoとは大きく異なる
- **記事での表現**: 「2012年1月、AmazonはDynamoDBを一般提供開始した」

## 5. Google Cloud Bigtable

- **結論**: 2015年5月6日にベータ版として公開。2016年8月にGA（一般提供）。Bigtable論文自体は2006年のOSDI
- **一次ソース**: Google Cloud Announcement, TechCrunch
- **URL**: <https://techcrunch.com/2015/05/06/google-launches-cloud-bigtable-a-highly-scalable-and-performant-nosql-database/>
- **注意事項**: ブループリントには「2015年、Bigtable論文の商用化」とある。ベータ版が2015年、GAが2016年
- **記事での表現**: 「2015年5月、GoogleはBigtable論文のマネージドサービス版としてCloud Bigtableを公開した」

## 6. Consistent Hashing

- **結論**: 1997年、David Karger、Eric Lehman、Tom Leighton、Matthew R. Levine、Daniel Lewin、Rina PanigrahyがMITで発表。論文タイトル「Consistent Hashing and Random Trees: Distributed Caching Protocols for Relieving Hot Spots on the World Wide Web」、STOC 1997
- **一次ソース**: Karger et al., STOC 1997
- **URL**: <https://en.wikipedia.org/wiki/Consistent_hashing>
- **注意事項**: Daniel LewinはAkamai Technologiesの共同創業者でもある（2001年9月11日に死去）。Consistent Hashingの概念はAkamaiのCDNの基盤技術となった
- **記事での表現**: 「Consistent Hashingは1997年にMITのDavid Kargerらによって提案された手法である」

## 7. Vector Clocks

- **結論**: Leslie Lamportが1978年に論理時計（Lamport Clock）を提案。Vector Clocksへの一般化は1988年にColin FidgeとFriedemann Matternが独立に発表。Amazon Dynamo論文ではVector Clocksを競合検出に使用
- **一次ソース**: Lamport, "Time, Clocks, and the Ordering of Events in a Distributed System", 1978; Fidge, 1988; Mattern, 1988
- **URL**: <https://en.wikipedia.org/wiki/Vector_clock>
- **注意事項**: Dynamo論文ではVector Clocksを使用しているが、DynamoDBではLast Writer Wins（LWW）を採用しており、Vector Clocksは使用していない
- **記事での表現**: 「Vector Clocksは1988年にColin FidgeとFriedemann Matternが独立に提案した」

## 8. Quorum（定足数）

- **結論**: R + W > Nの条件を満たすとき強一貫性が保証される。N=レプリカ数、R=読み取りに必要な応答数、W=書き込みに必要な応答数。読み取りQuorumと書き込みQuorumが必ず交差するため、最新のデータが読み取られることが保証される
- **一次ソース**: Gifford, "Weighted Voting for Replicated Data", SOSP 1979
- **URL**: <https://en.wikipedia.org/wiki/Quorum_(distributed_computing)>
- **注意事項**: CassandraではConsistency Levelとして ONE, QUORUM, ALL などを選択可能。Dynamo論文ではSloppy Quorum（厳密なQuorumではなく、一時的なノードへの書き込みを許容）を採用
- **記事での表現**: 「Quorum方式では、R + W > N（R: 読み取りノード数、W: 書き込みノード数、N: レプリカ数）を満たすことで強一貫性を保証する」

## 9. DynamoDBのキャパシティモデル

- **結論**: 当初はProvisioned Capacity（プロビジョニングされたキャパシティ）モードのみ。2018年11月にOn-Demand Capacityモードが追加。GSI（Global Secondary Index）のスロットリングがベーステーブルの書き込みをブロックするバックプレッシャー現象がある
- **一次ソース**: AWS Documentation, DynamoDB Document History
- **URL**: <https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DocumentHistory.html>
- **注意事項**: Provisioned Capacityモードでのスロットリングは、DynamoDBの初期ユーザーにとって大きな学習コストだった
- **記事での表現**: 「DynamoDBは当初、プロビジョニングされたキャパシティモードのみを提供していた。予想を超えるトラフィックはスロットリング（リクエスト拒否）される」

## 10. DynamoDBのシングルテーブル設計

- **結論**: Rick Houlihan（AWS Principal Technologist）が提唱・普及。re:Inventの講演が毎年最も視聴されるセッションの一つ。「アクセスパターンからデータモデルを設計する」クエリファーストアプローチ。Alex DeBreieの「The DynamoDB Book」も普及に貢献
- **一次ソース**: AWS re:Invent talks by Rick Houlihan, Alex DeBrie
- **URL**: <https://www.alexdebrie.com/posts/dynamodb-single-table/>
- **注意事項**: シングルテーブル設計は万能ではなく、近年は批判的な意見も増えている。Rick Houlihan自身がX（旧Twitter）で批判に応答している
- **記事での表現**: 「DynamoDBのデータモデリングはRDBとは根本的に異なる。アクセスパターンを先に定義し、それに最適なキー設計を行う『クエリファースト』のアプローチだ」

## 11. DynamoDB Global TablesとStreams

- **結論**: DynamoDB Streamsは2014年11月に導入（re:Invent 2014で発表）。Global Tablesの初版は2017年11月に提供開始。2019年にVersion 2019.11.21がリリースされ、大幅に改善
- **一次ソース**: AWS Blog, InfoQ
- **URL**: <https://aws.amazon.com/blogs/aws/happy-birthday-dynamodb/>
- **注意事項**: Global Tablesは結果整合性のマルチリージョンレプリケーション。2024年のre:Inventでマルチリージョン強一貫性が発表された
- **記事での表現**: 本文では直接的に深く扱わないが、DynamoDBの進化として言及可能
