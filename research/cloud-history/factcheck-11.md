# ファクトチェック記録：第11回「IaaSの本質——『抽象化のレイヤー』として理解する」

## 1. NIST SP 800-145 クラウドコンピューティングの定義

- **結論**: NIST SP 800-145は2011年9月に発行。著者はPeter MellとTimothy Grance。クラウドの5つの本質的特性を定義：(1) On-demand self-service、(2) Broad network access、(3) Resource pooling、(4) Rapid elasticity、(5) Measured service。3つのサービスモデル（IaaS/PaaS/SaaS）と4つのデプロイメントモデル（Private/Public/Community/Hybrid）を定義
- **一次ソース**: Peter Mell, Timothy Grance, "The NIST Definition of Cloud Computing", NIST Special Publication 800-145, September 2011
- **URL**: <https://csrc.nist.gov/pubs/sp/800/145/final>
- **注意事項**: 16回目のドラフトが最終版として発行された。発行日は2011年9月28日
- **記事での表現**: 「2011年9月、NISTはSP 800-145としてクラウドコンピューティングの定義を発行した。Peter MellとTimothy Granceが執筆したこの文書は、16回のドラフトを経て完成し、クラウドの5つの本質的特性を定義した」

## 2. OpenStackの発足（2010年、NASA + Rackspace）

- **結論**: 2010年初頭、NASAのソフトウェア開発者とRackspaceの代表者がタイ料理店で会合。NASAのNebula（Nova）とRackspaceのCloud Files（Swift）を基盤として統合。2010年7月21日、OSCONで正式発表。最初のDesign Summitは2010年7月13-14日（テキサス州オースティン）。初回リリース「Austin」は2010年10月21日、NovaとSwiftの2コンポーネント
- **一次ソース**: OpenStack Project Team Guide, "Introduction: A Bit of OpenStack History"
- **URL**: <https://docs.openstack.org/project-team-guide/introduction.html>
- **注意事項**: 25以上のパートナーが初期参加。NASAのNebulaプラットフォームとRackspaceのCloud Filesプラットフォームが起源
- **記事での表現**: 「2010年7月、NASAとRackspaceが共同でOpenStackを発表した。NASAのNovaコンピュートエンジンとRackspaceのSwiftオブジェクトストレージを核とするオープンソースIaaSプラットフォームだ」

## 3. Amazon VPCの導入時期

- **結論**: Amazon VPCは2009年8月26日にリリース。当初は限定ベータで、US-Eastリージョンの単一Availability Zoneで提供。EC2-Classicネットワーク（共有モデル）からの移行先として位置づけ。初期にはElastic IP、Auto Scaling、Elastic Load Balancingは利用不可
- **一次ソース**: AWS, "Introducing Amazon Virtual Private Cloud", AWS News Blog, 2009年8月
- **URL**: <https://aws.amazon.com/about-aws/whats-new/2009/08/26/introducing-amazon-virtual-private-cloud/>
- **注意事項**: Werner Vogelsも同日にブログ記事を公開。VPCの導入はエンタープライズ顧客のセキュリティ要件への対応が背景
- **記事での表現**: 「2009年8月、AWSはVPC（Virtual Private Cloud）を発表した。クラウド上に論理的に隔離されたネットワークを構築できるこのサービスは、IaaSのネットワーク抽象化における画期的な一歩だった」

## 4. AWS Shared Responsibility Model

- **結論**: AWSの責任共有モデルは「Security of the Cloud」（AWS側）と「Security in the Cloud」（顧客側）を区別。AWSは物理インフラ、ハイパーバイザ、ネットワーク等の基盤を管理。顧客はゲストOS、アプリケーション、データ、セキュリティグループの設定を管理。サービスタイプ（IaaS/マネージドサービス）により責任範囲が異なる
- **一次ソース**: AWS, "Shared Responsibility Model"
- **URL**: <https://aws.amazon.com/compliance/shared-responsibility-model/>
- **注意事項**: 概念自体は2011年頃から存在。IaaS（EC2）ではゲストOS管理が顧客責任、マネージドサービス（S3/DynamoDB）ではAWS側がOS・プラットフォームを管理
- **記事での表現**: 「AWSのShared Responsibility Modelは、『クラウドのセキュリティ』はAWSが、『クラウド内のセキュリティ』は顧客が責任を持つという境界線を明確に引いた」

## 5. VXLAN（RFC 7348）

- **結論**: VXLAN（Virtual eXtensible Local Area Network）はRFC 7348として2014年8月に発行。L3ネットワーク上にL2オーバーレイネットワークを構築するフレームワーク。24ビットVNI（VXLAN Network Identifier）により約1600万の論理ネットワークを実現（IEEE 802.1Q VLANの12ビット=4094に対し大幅に拡張）。UDPポート4789を使用。著者にはVMware、Cisco、Intel、Red Hat等の技術者が名を連ねる
- **一次ソース**: M. Mahalingam et al., "Virtual eXtensible Local Area Network (VXLAN)", RFC 7348, August 2014
- **URL**: <https://datatracker.ietf.org/doc/html/rfc7348>
- **注意事項**: Informational RFC（標準トラック文書ではない）。データセンター仮想化の要求から生まれた技術。VXLANの草案は2011年頃からVMwareやCiscoにより提案されていた
- **記事での表現**: 「2014年にRFC 7348として標準化されたVXLANは、L3ネットワーク上にL2のオーバーレイネットワークを構築する。24ビットのVNIにより約1600万の論理ネットワークをサポートし、従来のVLAN（4094個）の限界を突破した」

## 6. AWS Nitroシステム

- **結論**: AWSは2012年からNitroシステムの設計を開始。2015年にAnnapurna Labsを約3.5億ドルで買収。段階的に進化：C3（2013年、ネットワークオフロード）→C4（2014年、ストレージオフロード）→C5（2017年11月、re:Inventで発表、完全Nitro化）。Nitroカード（VPC/EBS/Instance Storage/Controller用）、Nitroセキュリティチップ、Nitroハイパーバイザの3要素。従来のXenハイパーバイザのDom0をカスタムハードウェアに置き換え、ほぼ100%のホストリソースをインスタンスに割り当て
- **一次ソース**: AWS, "The Security Design of the AWS Nitro System" (whitepaper); Werner Vogels, "Reinventing virtualization with the AWS Nitro System", All Things Distributed, 2020
- **URL**: <https://docs.aws.amazon.com/whitepapers/latest/security-design-of-aws-nitro-system/the-nitro-system-journey.html>
- **注意事項**: 2018年以降に起動された全EC2インスタンスがNitroシステム上で動作。ベアメタルインスタンスもNitroにより実現
- **記事での表現**: 「AWSは2012年からNitroシステムの設計を開始し、2017年のC5インスタンスで完全なNitro化を実現した。ネットワーク、ストレージ、管理機能を専用ハードウェアにオフロードすることで、ほぼ100%のホストリソースをインスタンスに割り当てる」

## 7. IaaS/PaaS/SaaSの分類

- **結論**: NIST SP 800-145が3つのサービスモデルを公式に定義。IaaS＝計算・ストレージ・ネットワークのプロビジョニング。PaaS＝プログラミング言語・ライブラリ・ツール等のアプリケーション開発プラットフォーム提供。SaaS＝クラウド上で動作するアプリケーションの提供。この分類はNIST以前から業界で使われており、NISTが公式化
- **一次ソース**: NIST SP 800-145（前掲）
- **URL**: <https://nvlpubs.nist.gov/nistpubs/legacy/sp/nistspecialpublication800-145.pdf>
- **注意事項**: この分類は完全に排他的ではなく、FaaS（Function as a Service）等の新しいモデルが後に登場
- **記事での表現**: 「NISTはクラウドの3つのサービスモデルを定義した。IaaS、PaaS、SaaS——この分類は、抽象化のレベルの違いを示す座標軸だ」

## 8. OpenStackの栄枯盛衰

- **結論**: 2010年発足後、急速に成長。しかし複雑性が障壁に。HPが2015年にHelion Public Cloudを終了。CiscoのIntercloudは2017年に3年で終了。2020年時点でGartnerは約2,000の本格的本番環境を確認（当初の期待を大幅に下回る）。テレコムと中国以外での採用は限定的。Kubernetesの台頭により、プライベートクラウドの焦点がCaaS（Container as a Service）に移行
- **一次ソース**: The Register, "OpenStack at 10 years old: A failure on its own terms, a success in its own niche", 2020
- **URL**: <https://www.theregister.com/2020/10/22/openstack_at_10/>
- **注意事項**: OpenStack自体は死んでおらず、テレコム業界やプライベートクラウド領域で引き続き利用されている。2020年にOpenStack FoundationはOpen Infrastructure Foundationに改名
- **記事での表現**: 「OpenStackは壮大な実験だった。HPが2015年にHelion Public Cloudを終了し、Ciscoが2017年にIntercloudを畳んだとき、パブリッククラウドに対抗するオープンソースIaaSという夢の限界が見えた」

## 9. 仮想ネットワーク（SDN/オーバーレイネットワーク）の概念

- **結論**: クラウドの仮想ネットワークは各プロバイダーで異なる実装：AWS VPC（2009年〜、リージョン内、サブネットはAZ単位）、Azure VNet（リージョン内、NSGによるトラフィック制御）、Google Cloud VPC（グローバルVPC、リージョンをまたぐ単一VPC）。Google VPCはAndromedaネットワーク仮想化スタックで実装
- **一次ソース**: 各社公式ドキュメント
- **URL**: <https://cloud.google.com/vpc/docs/vpc>
- **注意事項**: Google VPCのグローバル設計は、AWSやAzureのリージョン内VPCとは根本的に異なるアプローチ
- **記事での表現**: 「VPCの設計にも各社の思想が表れる。AWSとAzureはリージョン内のVPC/VNetだが、GCPはグローバルVPC——リージョンをまたぐ単一のネットワークを構築できる」

## 10. Availability Zone（AZ）の設計思想

- **結論**: AWSが先駆けたAZの概念は、物理的に離れた独立した障害ドメインをリージョン内に複数配置する設計。各AZは1つ以上のデータセンターで構成され、独立した電力・冷却・ネットワークを持つ。AZ間は低遅延の専用ネットワークで接続。この設計により、単一データセンターの障害がリージョン全体に波及することを防ぐ
- **一次ソース**: AWS, "Regions and Availability Zones"
- **URL**: <https://aws.amazon.com/about-aws/global-infrastructure/regions_az/>
- **注意事項**: AzureのAvailability Zones（2017年GA）、GCPのZone概念も同様だが実装の詳細は異なる
- **記事での表現**: 「AZは物理的に離れた独立した障害ドメインであり、IaaSのネットワーク抽象化における重要な設計概念だ」
