# ファクトチェック記録：第9回「S3、SQS——クラウドの基本構成要素」

## 1. S3の公開日

- **結論**: Amazon S3（Simple Storage Service）は2006年3月14日（Pi Day）に米国で一般公開された。欧州リージョンは2007年11月に追加。AWSインフラサービスとして最初にGAとなったサービス
- **一次ソース**: AWS公式プレスリリース "Amazon Web Services Launches", 2006年3月14日; Werner Vogels, "Happy 15th Birthday Amazon S3", All Things Distributed, 2021年3月
- **URL**: <https://press.aboutamazon.com/2006/3/amazon-web-services-launches>, <https://www.allthingsdistributed.com/2021/03/happy-15th-birthday-amazon-s3.html>
- **注意事項**: S3はEC2（2006年8月）より先に公開された
- **記事での表現**: 「2006年3月14日——偶然にもPi Day（円周率の日）——S3はAWSのインフラサービスとして最初に一般公開された」

## 2. SQSの公開日とAWS最初のサービス

- **結論**: SQS（Simple Queue Service）は2004年11月にベータとして公開され、AWSインフラサービスとして最初に発表されたサービス。本番公開（GA）は2006年7月13日。初期仕様はメッセージサイズ上限8KB
- **一次ソース**: AWS News Blog, "Amazon Simple Queue Service Released"; AWS News Blog, "Amazon SQS – 15 Years and Still Queueing!", 2019年
- **URL**: <https://aws.amazon.com/blogs/aws/amazon_simple_q/>, <https://aws.amazon.com/blogs/aws/amazon-sqs-15-years-and-still-queueing/>
- **注意事項**: SQSの「最初」はベータ発表（2004年）として。S3はGA公開として最初
- **記事での表現**: 「2004年11月、SQSがAWSインフラサービスとして最初に発表された。本番公開は2006年7月」

## 3. EBSの公開日

- **結論**: Amazon EBS（Elastic Block Store）は2008年8月20日に公開された。EC2のベータ開始（2006年8月）から約2年後
- **一次ソース**: Werner Vogels, "Amazon EBS - Elastic Block Store has launched", All Things Distributed, 2008年8月; AWS Blog, "Amazon Elastic Block Store at 15 Years", 2023年
- **URL**: <https://www.allthingsdistributed.com/2008/08/amazon_ebs_elastic_block_store.html>, <https://aws.amazon.com/blogs/storage/amazon-elastic-block-store-at-15-years/>
- **注意事項**: EBSの登場によりEC2のインスタンスストア（揮発性）に頼らない永続ストレージが利用可能になった
- **記事での表現**: 「2008年8月20日、EBSが公開され、EC2にようやく永続的なブロックストレージが加わった」

## 4. Werner Vogelsの「Eventually Consistent」論文

- **結論**: Werner VogelsがACM Queueに「Eventually Consistent」を発表（2008年、Volume 6, Issue 6, pp.14-19）。Communications of the ACM（Vol.52, No.1, pp.40-44）にも2009年1月に掲載。初版はVogels自身のブログに2007年12月に投稿
- **一次ソース**: ACM Queue, "Eventually Consistent", 2008; Werner Vogels, "Eventually Consistent - Revisited", All Things Distributed, 2008年12月
- **URL**: <https://queue.acm.org/detail.cfm?id=1466448>, <https://www.allthingsdistributed.com/2008/12/eventually_consistent.html>
- **注意事項**: S3やSimpleDB等のAWSサービスの設計背景として結果整合性を説明
- **記事での表現**: 「2008年、Werner VogelsはACM Queueに"Eventually Consistent"を発表し、分散システムにおける整合性と可用性のトレードオフを体系化した」

## 5. Dynamoペーパー（2007年、SOSP）

- **結論**: 「Dynamo: Amazon's Highly Available Key-value Store」はGiuseppe DeCandia, Deniz Hastorun, Madan Jampani, Gunavardhan Kakulapati, Avinash Lakshman, Alex Pilchin, Swaminathan Sivasubramanian, Peter Vosshall, Werner Vogelsの共著。2007年のSOSP（21st ACM Symposium on Operating Systems Principles）で発表
- **一次ソース**: Amazon Science; ACM Digital Library
- **URL**: <https://www.amazon.science/publications/dynamo-amazons-highly-available-key-value-store>, <https://dl.acm.org/doi/10.1145/1294261.1294281>
- **注意事項**: Dynamoの技術はConsistent Hashing、Object Versioning、Quorum、Gossipプロトコルを使用。後のDynamoDBの直接の前身ではなく、設計思想の影響
- **記事での表現**: 「2007年、AmazonのエンジニアチームがSOSPでDynamoペーパーを発表した。一貫性ハッシュ、ベクタークロック、クォーラムといった分散システムの技法を組み合わせた高可用性キーバリューストアの設計だった」

## 6. S3の耐久性設計（イレブンナイン）

- **結論**: S3 Standardは99.999999999%（11ナイン）の耐久性を設計目標とする。データは最低3つのアベイラビリティゾーンに分散保存。イレーシャーコーディング（前方誤り訂正）、バックグラウンド監査プロセスによるデータ整合性検証と自動修復を実施。1,000万オブジェクトを保存した場合、1個のオブジェクトを失う確率は10,000年に1回
- **一次ソース**: AWS公式ドキュメント "Data protection in Amazon S3"; AWS S3 Storage Classes
- **URL**: <https://docs.aws.amazon.com/AmazonS3/latest/userguide/DataDurability.html>, <https://aws.amazon.com/s3/storage-classes/>
- **注意事項**: 耐久性（Durability）と可用性（Availability）は異なる概念。S3 Standardの可用性は99.99%
- **記事での表現**: 「S3は99.999999999%——いわゆるイレブンナインの耐久性を設計目標に掲げた。1,000万個のオブジェクトを保存した場合、1個を失う確率は1万年に1回である」

## 7. CAP定理

- **結論**: Eric BrewerがPODC 2000（ACM Symposium on Principles of Distributed Computing）で予想として発表。2002年にSeth GilbertとNancy Lynch（MIT）がACM SIGACT Newsで正式に証明し、定理として確立
- **一次ソース**: Brewer, E., PODC 2000 keynote; Gilbert, S. & Lynch, N., "Brewer's Conjecture and the Feasibility of Consistent, Available, Partition-Tolerant Web Services", ACM SIGACT News, 2002
- **URL**: <https://en.wikipedia.org/wiki/CAP_theorem>, <https://users.ece.cmu.edu/~adrian/731-sp04/readings/GL-cap.pdf>
- **注意事項**: CAPは「3つのうち2つしか同時に満たせない」という単純化が広まったが、実際にはより微妙。Brewer自身が2012年に「12 Years Later」で修正を加えている
- **記事での表現**: 「2000年、Eric BrewerがPODCで提示し、2002年にGilbertとLynchが証明したCAP定理——分散システムは一貫性、可用性、分断耐性の3つを同時に完全には満たせない」

## 8. S3の初期価格体系

- **結論**: 2006年のS3公開時の価格はストレージが$0.15/GB/月（15セント）。データ転送費用は別途。フラットレート（容量による段階的割引なし）。その後10年で80%以上の価格低下。2026年現在のS3 Standardは$0.023/GB/月〜
- **一次ソース**: AWS S3 pricing history; hidekazu-konishi.com S3 history timeline
- **URL**: <https://hidekazu-konishi.com/entry/aws_history_and_timeline_amazon_s3.html>
- **注意事項**: 初期はストレージ料金のみシンプルだったが、後にストレージクラス、リクエスト数、データ転送量の複合課金に進化
- **記事での表現**: 「S3の初期価格は1GBあたり月額15セント。シンプルな従量課金だった」

## 9. Jeff Bezosの「APIマンデート」（約2002年）

- **結論**: 2002年頃、Jeff Bezosが全チームにサービスインターフェース経由でのみ通信するよう命令。直接リンク、他チームのデータストア直接読み取り、共有メモリモデル、バックドアを禁止。全インターフェースは外部公開可能な設計であること。2011年にGoogleのSteve Yeggeが内部メモで言及し公に知られた
- **一次ソース**: Steve Yegge, Google internal memo (accidentally public), 2011; Kong Inc. "API Mandate" article
- **URL**: <https://gist.github.com/kislayverma/d48b84db1ac5d737715e8319bd4dd368>, <https://konghq.com/blog/enterprise/api-mandate>
- **注意事項**: 正確な日付は不明（「約2002年」）。Yeggeのメモは内部用だったが誤って公開された
- **記事での表現**: 「2002年頃、BezosはAmazon全チームに対し、データと機能をサービスインターフェース経由でのみ公開するよう命じた。この"APIマンデート"が、AWSのビルディングブロック思想の原点である」

## 10. S3の強い整合性への移行（2020年12月）

- **結論**: 2020年12月2日（re:Invent 2020）、AWSはS3が全てのGET/PUT/LIST操作で強い読み取り後書き込み整合性（strong read-after-write consistency）を提供すると発表。追加費用なし、パフォーマンス影響なし。14年間の結果整合性から強い整合性への移行
- **一次ソース**: AWS News Blog, "Amazon S3 Update – Strong Read-After-Write Consistency", 2020年12月2日
- **URL**: <https://aws.amazon.com/blogs/aws/amazon-s3-update-strong-read-after-write-consistency/>
- **注意事項**: この変更により、EMRFS Consistent ViewやS3Guardが不要になった
- **記事での表現**: 「2020年12月、AWSはS3の全操作で強い整合性を提供すると発表した。14年間の結果整合性モデルからの転換であり、追加費用もパフォーマンス低下もなかった」

## 11. S3のオブジェクト数の成長

- **結論**: S3に保存されたオブジェクト数は2021年に2兆を超え、2024年には400兆、2025年（re:Invent 2025発表）には500兆オブジェクト・数百エクサバイト・毎秒2億リクエストに到達
- **一次ソース**: AWS News Blog, "Amazon S3 – The First Trillion Objects"; ByteByteGo, "How Amazon S3 Stores 350 Trillion Objects"
- **URL**: <https://aws.amazon.com/blogs/aws/amazon-s3-the-first-trillion-objects/>, <https://blog.bytebytego.com/p/how-amazon-s3-stores-350-trillion>
- **注意事項**: 成長速度が加速しており、AI/ML関連のデータ増加が大きな要因
- **記事での表現**: 「2025年時点でS3には500兆を超えるオブジェクトが保存され、毎秒2億リクエストを処理している」

## 12. SQS FIFOキューの導入（2016年）

- **結論**: 2016年11月、AWSはSQS FIFOキューを発表。メッセージの順序保証と正確に1回の処理（exactly-once processing）を提供。5分間の重複排除インターバルを使用。Standard Queueの価格も同時に引き下げ
- **一次ソース**: AWS, "Amazon SQS Introduces FIFO Queues with Exactly-Once Processing", 2016年11月; InfoQ, "Amazon Simple Queue Service Gains FIFO Queues", 2016年12月
- **URL**: <https://aws.amazon.com/about-aws/whats-new/2016/11/amazon-sqs-introduces-fifo-queues-with-exactly-once-processing-and-lower-prices-for-standard-queues/>
- **注意事項**: 「exactly-once processing」の定義には議論がある。SQSレベルでは重複排除するが、分散システム全体としてのexactly-onceは保証しない
- **記事での表現**: 「2016年、SQSにFIFOキューが追加され、メッセージの順序保証と重複排除が実現された。ただし、分散システム全体でのexactly-onceは依然として難題である」
