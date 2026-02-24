# ファクトチェック記録：第8回「AWS EC2（2006年）——『サーバを借りる』概念が変わった日」

## 1. AWS EC2パブリックベータの開始日

- **結論**: AWSは2006年8月24日にAmazon EC2のベータを発表した（プレスリリースの日付は8月24日、サービス開始は8月25日とする記述もある）。限定パブリックベータとして先着順でアクセスを提供。正式版（GAリリース、ベータラベル廃止）は2008年10月23日
- **一次ソース**: AWS公式What's New発表
- **URL**: <https://aws.amazon.com/about-aws/whats-new/2006/08/24/announcing-amazon-elastic-compute-cloud-amazon-ec2---beta/>
- **注意事項**: ブループリントでは「2006年8月」とあり正確。発表日と実際のサービス開始日に1日のずれがある可能性があるが、2006年8月で問題なし
- **記事での表現**: 「2006年8月、AWSはEC2の限定パブリックベータを開始した」

## 2. Chris PinkhamとBenjamin Blackのペーパー（2003年）

- **結論**: 2003年、当時Amazonで働いていたChris Pinkham（マネージャー）とBenjamin Black（ネットワークエンジニア、後にマネージャーに昇進）が、Amazonのインフラを完全に標準化・自動化し、ウェブサービスに全面依存する構想を短いペーパーにまとめた。このペーパーには仮想サーバをサービスとして販売する可能性も記述されていた。Pinkhamはその後南アフリカに戻り、現地のオフィスでEC2チームを立ち上げ、EC2を構築した
- **一次ソース**: Benjamin Black, "EC2 Origins", 2009年1月25日
- **URL**: <https://blog.b3k.us/2009/01/25/ec2-origins.html>
- **注意事項**: ブループリントでは「2003年のChris PinhamとBenjamin Blackのペーパー」とあるが、姓のスペルは「Pinkham」（kあり）が正確
- **記事での表現**: 「2003年、AmazonのChris PinkhamとBenjamin Blackが、標準化・自動化されたインフラと仮想サーバのサービス提供を構想するペーパーを書いた」

## 3. Andy Jassyの役割

- **結論**: Andy Jassyは1997年にAmazonにマーケティングマネージャーとして入社。Jeff Bezosのテクニカルアドバイザー（chief of staff的役割、いわゆる「shadow」）を務めた後、2003年にBezosとともにAWSの構想を練り始めた。2003年のBezos邸でのエグゼクティブリトリートで、Amazonのコアコンピテンシーとして「インフラサービスの運用能力」が特定された。Jassyは57人のチームを率いてAWSを立ち上げ、2016年にAWSのCEOに昇進
- **一次ソース**: TechCrunch "How AWS came to be", 2016年7月2日、Wikipedia "Andy Jassy"
- **URL**: <https://techcrunch.com/2016/07/02/andy-jassys-brief-history-of-the-genesis-of-aws/>
- **注意事項**: AWSの起源については「余剰キャパシティの販売」という神話が広く流布しているが、Werner Vogelsは「excess capacity story is a myth」と明確に否定している
- **記事での表現**: 「Andy Jassyは57人のチームを率いてAWSを構築した。2003年のエグゼクティブリトリートで、Amazonが『インフラサービスの運用』にコアコンピテンシーを持つと認識したことが転換点だった」

## 4. S3の公開日とSQSの公開日

- **結論**: SQS（Simple Queue Service）は2004年11月にAWS最初の公開インフラサービスとしてベータリリース。S3（Simple Storage Service）は2006年3月14日に公開。EC2は2006年8月にベータ開始。つまりサービス提供順はSQS→S3→EC2
- **一次ソース**: AWS公式ブログ "Amazon SQS – 15 Years and Still Queueing!", Wikipedia "Timeline of Amazon Web Services"
- **URL**: <https://aws.amazon.com/blogs/aws/amazon-sqs-15-years-and-still-queueing/>
- **注意事項**: ブループリントでは「SQS（2004年11月、AWS最初のサービス）」「S3（2006年3月）」とあり正確
- **記事での表現**: 「AWSの最初の公開インフラサービスはSQS（2004年11月）であり、S3が2006年3月、EC2が2006年8月と続いた」

## 5. 初期EC2のインスタンス仕様

- **結論**: 2006年8月のEC2ベータ開始時、提供されたインスタンスは1.7GHz Xeonプロセッサ相当、1.75GB RAM、160GBのローカルディスク、250Mb/sのネットワーク帯域。当初は名前がなかったが、後に「m1.small」と命名された。価格は1時間あたり0.10ドル（10セント）。Linuxのみ対応（Windows対応は2008年10月）
- **一次ソース**: AWS公式ブログ "EC2 Instance History", TechCrunch "How Amazon EC2 grew"
- **URL**: <https://aws.amazon.com/blogs/aws/ec2-instance-history/>
- **注意事項**: インスタンスストレージ（160GB）は揮発性（ephemeral）であり、インスタンスの停止・終了でデータが消失した。EBSは2008年8月まで存在しなかった
- **記事での表現**: 「最初のEC2インスタンスは1.7GHz Xeon相当のCPU、1.75GB RAM、160GBのローカルディスクで、1時間10セントだった。このローカルディスクは揮発性であり、インスタンスを停止するとデータは消えた」

## 6. EBSの登場時期

- **結論**: Amazon Elastic Block Store（EBS）は2008年8月20日に発表・公開。EC2ベータ開始から約2年後。「EC2インスタンスにネットワーク接続型のブロックストレージを提供する」というシンプルなアイデアから生まれた
- **一次ソース**: Werner Vogels "Amazon EBS - Elastic Block Store has launched", All Things Distributed, 2008年8月20日
- **URL**: <https://www.allthingsdistributed.com/2008/08/amazon_ebs_elastic_block_store.html>
- **注意事項**: EBS登場以前のEC2は永続ストレージを持たず、データの永続化にはS3を使う必要があった。この制約がEC2の「使い捨て」設計思想を強化した
- **記事での表現**: 「EBSが登場したのは2008年8月20日——EC2のベータ開始から2年後のことだ。それまでの2年間、EC2には永続ストレージが存在しなかった」

## 7. EC2の時間課金モデル

- **結論**: EC2は時間単位（per hour）の従量課金を採用した。m1.smallで1時間あたり0.10ドル。当時のホスティング業界は月額固定課金が主流だった。2017年10月にEC2は秒単位課金に移行（Linux/Ubuntu、最低60秒）
- **一次ソース**: AWS公式発表、EC2 Instance History
- **URL**: <https://aws.amazon.com/blogs/aws/ec2-instance-history/>
- **注意事項**: 「月額ではなく時間課金」という点がEC2の革新の一つ。使った時間だけ支払う（pay-as-you-go）モデルはホスティング業界の常識を覆した
- **記事での表現**: 「月額固定課金が当たり前の時代に、EC2は時間単位の従量課金を導入した。1時間10セント——使った分だけ払う」

## 8. Availability Zone（AZ）の設計

- **結論**: AZは物理的に離れた独立したデータセンター（群）で構成される障害ドメイン。各リージョン内に最低3つのAZが存在。AZ間の距離は最大約60マイル（約100km）で、同期レプリケーションが可能な一桁ミリ秒のレイテンシーを維持。電力、冷却、物理セキュリティが独立し、異なる変電所から電力供給を受ける設計
- **一次ソース**: AWS公式ホワイトペーパー "AWS Fault Isolation Boundaries"
- **URL**: <https://docs.aws.amazon.com/whitepapers/latest/aws-fault-isolation-boundaries/availability-zones.html>
- **注意事項**: 初期のEC2（2006年）ではAZの概念がどの程度成熟していたかは不明確。AZの設計が現在の形になったのは段階的な進化の結果
- **記事での表現**: 「AZは物理的に離れた独立した障害ドメインであり、電力・冷却・ネットワークが独立している。AZ間は最大約100km離れているが、一桁ミリ秒のレイテンシーで接続される」

## 9. EC2 ClassicからVPCへの移行

- **結論**: 2006年のEC2開始時はフラットなネットワーク（後にEC2-Classicと呼ばれる）。Amazon VPCは2009年に公開。2013年12月4日以降に作成されたAWSアカウントはVPC-onlyがデフォルト。EC2-Classicは2022年8月15日に完全廃止
- **一次ソース**: AWS公式ブログ "EC2-Classic is Retiring – Here's How to Prepare"
- **URL**: <https://aws.amazon.com/blogs/aws/ec2-classic-is-retiring-heres-how-to-prepare/>
- **注意事項**: EC2-Classicの時代、全てのEC2インスタンスはAWSの共有フラットネットワーク上に存在していた。顧客間のネットワーク分離はセキュリティグループに依存
- **記事での表現**: 「EC2の初期はフラットな共有ネットワーク上にインスタンスが配置されていた。VPCによる仮想ネットワーク分離が導入されたのは2009年のことだ」

## 10. Amazonの内部インフラ課題（AWS前史）

- **結論**: 2000年代初頭のAmazonは典型的なモノリスアーキテクチャで、大規模なリレーショナルデータベースをバックエンドに持っていた。チームはサービス信頼性維持のためにリソースの約70%を運用業務に費やし、共通のインフラリソースがなかったためエンジニアは同じ問題を繰り返し解決していた。Werner Vogelsは「余剰キャパシティの販売」説を「myth（神話）」と明確に否定。Andy Jassyによれば、2006年末には内部システムの余剰キャパシティを使い切っていた
- **一次ソース**: Werner Vogels（HN引用）、Andy Jassy（2008年Wiredインタビュー）
- **URL**: <https://news.ycombinator.com/item?id=8658383>
- **注意事項**: 「AWSはAmazonの余剰サーバを売り始めたもの」という広く流布した説は不正確。AWSは余剰キャパシティの販売ではなく、内部インフラ課題の解決から生まれた
- **記事での表現**: 「AWSがAmazonの余剰サーバを売り始めたものだという説は広く流布しているが、Werner Vogelsは『余剰キャパシティの神話』と否定している」

## 11. AMI（Amazon Machine Image）の概念

- **結論**: AMIはEC2インスタンスを起動するための仮想アプライアンス（テンプレート）。OS、アプリケーションサーバ、アプリケーションを含むルートボリュームのテンプレート、起動権限、ブロックデバイスマッピングで構成される。2006年のEC2ローンチ時のコアコンポーネントとして導入。当初はLinuxとSun Microsystems OpenSolaris/Solaris Express Community Editionに対応
- **一次ソース**: AWS公式ドキュメント、Wikipedia "Amazon Machine Image"
- **URL**: <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AMIs.html>
- **注意事項**: AMIの概念は「マシンイメージをテンプレートとしてインスタンスを量産する」という設計思想を体現しており、VMwareのVM Templateやlibvirtの仮想マシン定義XMLの発展形
- **記事での表現**: 「AMIはEC2のコア概念の一つであり、OS・ミドルウェア・アプリケーションを含むマシンイメージをテンプレートとして、同一構成のインスタンスを必要な数だけ起動できる」

## 12. EC2開発拠点（南アフリカ、ケープタウン）

- **結論**: Chris Pinkhamは2003年のペーパー後、家族の事情で南アフリカのケープタウンに戻り、現地でEC2開発チームを立ち上げた。優秀なリードデベロッパーを連れて行き、ケープタウンのオフィスでEC2を構築した。ベータ公開までに約21ヶ月を要した
- **一次ソース**: Benjamin Black, "EC2 Origins", TechCrunch
- **URL**: <https://blog.b3k.us/2009/01/25/ec2-origins.html>
- **注意事項**: EC2が南アフリカで開発されたというのはAWS史の中でも興味深いエピソード
- **記事での表現**: 「Pinkhamは南アフリカのケープタウンに戻り、現地のオフィスでEC2開発チームを立ち上げた。オフィス開設からベータ公開まで約21ヶ月を要した」
