# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第11回：IaaSの本質——「抽象化のレイヤー」として理解する

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- IaaS（Infrastructure as a Service）が単なる「リモートのサーバ貸し」ではなく、計算・ストレージ・ネットワークの統合的な抽象化であること
- NIST SP 800-145（2011年）が定義したクラウドの5つの本質的特性——オンデマンド・セルフサービス、ブロードネットワークアクセス、リソースプーリング、ラピッドエラスティシティ、メジャードサービス
- OpenStack（2010年、NASA + Rackspace）——オープンソースでIaaSを構築しようとした壮大な試みとその教訓
- VPC（Virtual Private Cloud）の仮想ネットワーク設計——L2/L3のオーバーレイネットワークとVXLAN
- AWS Nitroシステム——ハイパーバイザをカスタムハードウェアに置き換えた抽象化の深化
- Shared Responsibility Model——クラウドにおける責任の境界線
- VPCをゼロから手動構築するハンズオン

---

## 1. IaaSを「リモートのサーバ」としか理解していなかった頃

私がIaaSを本当の意味で理解したのは、障害の現場だった。

2012年のある夜、運用中のWebサービスが応答しなくなった。EC2インスタンスは稼働している。CPU使用率も正常。だがユーザーからは「アクセスできない」という報告が続々と入る。調査を進めると、原因はネットワークだった。Availability Zone（AZ）単位での部分的なネットワーク障害が発生しており、私たちのインスタンスが配置されていたAZが影響を受けていたのだ。

問題はそこではない。問題は、私がその時点まで、IaaSのネットワーク層がどう構成されているかを深く理解していなかったことだ。EC2インスタンスに付与されたIPアドレスは物理的なネットワークインターフェースに直接紐づいているのか。AZをまたいだ通信は物理的にどう接続されているのか。セキュリティグループのルールは何層目で評価されているのか——これらの問いに、私は明確に答えられなかった。

「IaaSはリモートのサーバだ」——その認識が間違いだと気づいたのは、その障害の渦中だった。

EC2インスタンスは「サーバ」ではない。仮想化された計算リソースだ。EBSボリュームは「ディスク」ではない。ネットワーク越しにアタッチされたブロックストレージだ。VPCは「ネットワーク」ではない。ソフトウェアで定義されたオーバーレイネットワークだ。全てが抽象化されている。そしてその抽象化の仕組みを理解しないまま、私は「サーバを借りている」つもりになっていた。

あの障害以降、私はIaaSを「サーバの貸し出し」ではなく「抽象化のレイヤー」として捉え直した。計算、ストレージ、ネットワーク——この三つの物理的リソースを、APIで統合的に制御可能にした仕組み。それがIaaSの本質だ。

あなたは、自分が使っているIaaSの抽象化の下に何があるか、説明できるだろうか。仮想マシンの「裏側」で何が起きているか、想像できるだろうか。

---

## 2. NISTの定義——クラウドとは何か、を公式に定めた文書

### SP 800-145——16回のドラフトを経た定義

2011年9月、NIST（National Institute of Standards and Technology、米国国立標準技術研究所）がSP 800-145「The NIST Definition of Cloud Computing」を発行した。著者はPeter MellとTimothy Grance。16回のドラフトを経て完成したこの文書は、わずか7ページの薄さだが、クラウドコンピューティングの業界標準の定義として今なお参照され続けている。

NISTの定義は、クラウドコンピューティングを以下のように記述する。

> クラウドコンピューティングとは、設定可能な計算リソース（例：ネットワーク、サーバ、ストレージ、アプリケーション、サービス）の共有プールへの、ユビキタスで、便利な、オンデマンドのネットワークアクセスを可能にするモデルであり、最小限の管理労力またはサービスプロバイダーとのやり取りで、迅速にプロビジョニングおよびリリースできるものである。

この定義が重要なのは、クラウドを「技術」ではなく「モデル」として定義した点だ。特定の技術スタック（仮想化、コンテナ、特定のハイパーバイザ等）に依存しない、より抽象的な定義になっている。

### 5つの本質的特性

NISTはクラウドの5つの本質的特性（Five Essential Characteristics）を定義した。この5つを理解することが、IaaSの本質を理解する第一歩だ。

**第一の特性：On-demand Self-service（オンデマンド・セルフサービス）。** 利用者が人的なやり取りなしに自動的にリソースをプロビジョニングできること。コロケーションの時代、私はサーバ調達のために営業担当に電話し、見積もりを取り、搬入日を調整していた。EC2のAPIを叩けば数分で完了する——本質は「人間を介在させない」ことだ。

**第二の特性：Broad Network Access（ブロードネットワークアクセス）。** ネットワーク経由で標準的なメカニズムを通じてアクセスできること。APIという統一インターフェースが、アクセス手段を問わない操作を可能にしている。

**第三の特性：Resource Pooling（リソースプーリング）。** プロバイダーのリソースがプールされ、マルチテナントモデルで複数の利用者に提供されること。利用者は提供されるリソースの物理的位置を制御できない（リージョンレベルでは指定可能）。これは第2回で触れたメインフレームのタイムシェアリングの現代版だ。「他人の計算機を共有する」原理は60年以上変わっていない。

**第四の特性：Rapid Elasticity（ラピッドエラスティシティ）。** リソースを迅速かつ弾力的にプロビジョニング・リリースでき、自動的にスケールアウト・スケールインできること。ホスティング時代、スペック変更に数日を要した。IaaSではAuto Scalingが負荷に応じてインスタンス数を自動増減する。

**第五の特性：Measured Service（メジャードサービス）。** リソース使用量が自動的に計測され、利用実績に基づいて課金されること。コロケーションの月額固定からIaaSの従量課金への転換は、この特性の具現だ。

### 3つのサービスモデル——抽象化のレイヤー

NISTは3つのサービスモデルを定義した。IaaS、PaaS、SaaS——この分類は「抽象化のレベルの違い」を示す座標軸だ。

```
抽象化レベルの階層図:

  ┌─────────────────────────────────────────────────┐
  │                    SaaS                          │
  │   アプリケーションをそのまま利用する              │
  │   例: Gmail, Salesforce, Microsoft 365           │
  │   利用者の責任: データ、アクセス制御のみ          │
  ├─────────────────────────────────────────────────┤
  │                    PaaS                          │
  │   アプリケーションコードをデプロイする            │
  │   例: Heroku, Google App Engine, Cloud Run       │
  │   利用者の責任: コード、データ、設定              │
  ├─────────────────────────────────────────────────┤
  │                    IaaS                          │
  │   計算・ストレージ・ネットワークを制御する        │
  │   例: AWS EC2, Azure VM, Google Compute Engine   │
  │   利用者の責任: OS、ミドルウェア、コード、データ  │
  ├─────────────────────────────────────────────────┤
  │              物理インフラ（オンプレミス）          │
  │   全てを自分で管理する                           │
  │   利用者の責任: 全て（ハードウェア含む）          │
  └─────────────────────────────────────────────────┘

  ↑ 抽象化レベルが高い = 制御が少ない = 運用負荷が軽い
  ↓ 抽象化レベルが低い = 制御が多い = 運用負荷が重い
```

IaaSは3つのサービスモデルの中で最も抽象化レベルが低い——つまり、利用者に最も多くの制御を与える。だがそれは「物理的なサーバを貸す」こととは本質的に異なる。IaaSが抽象化しているのは「物理ハードウェア」であり、提供しているのは「プログラマブルなインフラ」だ。

この区別が重要なのは、IaaSの制約と責任を正しく理解するためだ。IaaSを「サーバの貸し出し」と認識していると、物理サーバと同じ前提でシステムを設計してしまう。だがIaaSのインスタンスは、いつでも消えうる。EBSボリュームはネットワーク越しにアタッチされているため、物理ディスクとは異なるレイテンシ特性を持つ。VPCのネットワークはソフトウェアで構成されており、物理ネットワークとは異なるスループット特性を示す。抽象化のレイヤーを意識しなければ、適切な設計はできない。

---

## 3. IaaSの三本柱——計算・ストレージ・ネットワークの抽象化

### 計算の抽象化——仮想マシンからマイクロVMへ

IaaSにおける「計算」の抽象化は、第6回・第7回で扱った仮想化技術の上に成り立っている。物理的なCPUとメモリを、ハイパーバイザが仮想マシンとして切り出す。利用者はvCPU数とメモリサイズを指定し、APIで仮想マシンを起動する。

だが「仮想マシンの起動」は、見た目ほど単純な処理ではない。APIリクエストが到達してから仮想マシンが利用可能になるまでの過程を追ってみよう。

```
EC2インスタンスの起動プロセス（簡略化）:

  1. APIリクエスト受信
     ── RunInstances APIがリージョンのエンドポイントに到達
     ── IAMポリシーに基づく認証・認可

  2. 配置先の決定
     ── 指定されたAZ内で、利用可能な物理ホストを選択
     ── インスタンスタイプに応じたCPU/メモリの空きを確認
     ── Nitroカードのリソース割り当て

  3. ストレージの準備
     ── AMI（Amazon Machine Image）からEBSボリュームを作成
     ── EBSボリュームは物理ホストとは別の場所に存在
     ── ネットワーク経由でアタッチ

  4. ネットワークの構成
     ── VPC内にENI（Elastic Network Interface）を作成
     ── プライベートIPアドレスを割り当て
     ── セキュリティグループのルールを適用
     ── （指定があれば）パブリックIPを割り当て

  5. 仮想マシンの起動
     ── Nitroハイパーバイザがゲストを起動
     ── UserDataスクリプトの実行
     ── インスタンスが「running」状態に遷移
```

注目すべきは、計算（CPU/メモリ）、ストレージ（EBSボリューム）、ネットワーク（ENI/VPC）の三つが、物理的に別々の場所で独立して管理されていることだ。物理サーバではCPU、ディスク、NICが一つの筐体に収まっている。IaaSでは、これらが分離されている。この分離こそがIaaSの設計の核心であり、弾力性（ストレージだけ増やす、ネットワーク帯域だけ変更する等）を実現する根源だ。

AWSは2012年からNitroシステムの設計を開始し、2017年のC5インスタンスで完全なNitro化を実現した。Nitroシステムは、ネットワーク（VPC）、ストレージ（EBS）、管理機能を専用のカスタムハードウェア（Nitroカード）にオフロードする。従来のXenハイパーバイザではDom0（管理用仮想マシン）がこれらの機能を処理していたが、Nitroシステムでは専用ハードウェアが担うため、ホストCPUのほぼ100%をインスタンスに割り当てることが可能になった。2015年にAWSが買収したAnnapurna Labsのカスタムシリコン技術がこれを支えている。

```
Xen時代 vs Nitro時代:

  Xen（〜2017年）:
  [Guest VM1] [Guest VM2] [Dom0: VPC/EBS/管理]
  ─────── Xen Hypervisor ───────
  ─────── 物理ハードウェア ───────
  ※ Dom0がホストCPUの一部を消費

  Nitro（2017年〜）:
  [Guest VM1] [Guest VM2] [Guest VM3]
  ─── Nitro Hypervisor（軽量） ───
  ─────── 物理ハードウェア ───────
  [Nitro Card: VPC] [Nitro Card: EBS] [Nitro Sec.Chip]
  ※ 管理処理がハードウェアに移り、CPUはほぼ全てVMに割り当て
```

Nitroシステムの登場は、「抽象化のコスト」を最小化する試みだ。仮想化には必ずオーバーヘッドが伴う。Nitroはそのオーバーヘッドの大部分を専用ハードウェアに移すことで、仮想マシンのパフォーマンスをベアメタルに限りなく近づけた。抽象化を維持しながら、抽象化のペナルティを消す——これは工学的に見事な解決だ。

### ストレージの抽象化——ブロック・オブジェクト・ファイル

IaaSのストレージは3つの抽象化モデルを提供する。**ブロックストレージ**（EBS等）は物理ディスクに最も近い。EC2にアタッチされたEBSボリュームはローカルディスクのように見えるが、実際にはネットワーク越しにアクセスしている。**オブジェクトストレージ**（S3等）はキーでオブジェクトを格納・取得する（第9回で詳述）。**ファイルストレージ**（EFS等）はNFS/SMBの伝統的な共有ファイルシステムをクラウド上で提供する。

物理サーバでは「ディスク」は一つの概念だった。IaaSでは用途に応じて最適な抽象化モデルを「選択」する。選択肢があるということは設計判断が必要だということだ。そしてその判断の質は、各モデルの仕組みへの理解に依存する。

### ネットワークの抽象化——VPCとオーバーレイネットワーク

IaaSのネットワーク抽象化は、三本柱の中で最も複雑であり、最も見えにくい。

2009年8月、AWSはVPC（Virtual Private Cloud）を発表した。クラウド上に論理的に隔離されたネットワークを構築できるこのサービスは、IaaSのネットワーク抽象化における画期的な一歩だった。それ以前のEC2（EC2-Classic）では、全てのインスタンスが共有のフラットなネットワーク上に配置されていた。VPCの導入により、利用者は自分専用のIPアドレス空間を定義し、サブネットを作成し、ルーティングを制御できるようになった。

VPCの裏側では、オーバーレイネットワーク技術が動いている。物理的なネットワーク（アンダーレイ）の上に、ソフトウェアで構成された仮想的なネットワーク（オーバーレイ）を重ねる。利用者のトラフィックは、オーバーレイ上のアドレスで送受信され、物理ネットワーク上ではカプセル化されて転送される。

この技術の標準の一つがVXLAN（Virtual eXtensible Local Area Network）だ。2014年にRFC 7348として標準化されたVXLANは、L3ネットワーク上にL2のオーバーレイネットワークを構築する。24ビットのVNI（VXLAN Network Identifier）により約1600万の論理ネットワークをサポートし、従来のVLAN（IEEE 802.1Qの12ビット=4094個）の限界を突破した。クラウドのマルチテナント環境では、数千、数万のテナントが独立したネットワークを必要とするため、VLANの4094個では到底足りない。

```
VPCの構造（オーバーレイとアンダーレイ）:

  利用者が見える世界（オーバーレイ）:
  VPC 10.0.0.0/16
  ├── Public Subnet 10.0.1.0/24 ── [VM] [VM] ── Internet GW
  └── Private Subnet 10.0.2.0/24 ── [VM] [DB] ── NAT GW

  実際の物理ネットワーク（アンダーレイ）:
  [Host A] ── [Host B] ── [Host C] ── [Host D]
  （各ホストに複数テナントのVMが混在）

  利用者の10.0.1.10 → 10.0.2.20 は
  実際にはHost A → Host Cへの通信（VXLANでカプセル化）
```

VPCの設計にも各社の思想が表れる。AWSのVPCはリージョン内に閉じ、サブネットはAZ単位だ。AzureのVNetも基本的にリージョン内。一方GCPのVPCはグローバル——リージョンをまたぐ単一のVPCを構築でき、サブネットがリージョン単位になる。Google社内のAndromedaネットワーク仮想化スタックに由来するこの設計は、マルチリージョン構成をシンプルにする一方、リージョン間レイテンシが「同一VPC内」という抽象化の裏に隠れるリスクもある。

ネットワークの抽象化は、IaaSの中で最も「見えない」部分だ。計算はvCPU数とメモリサイズで直感的に理解できる。ストレージもGB単位で把握しやすい。だがネットワークは、サブネット設計、ルーティング、セキュリティグループ、NATゲートウェイ、ピアリング——複数の概念が絡み合い、全体像を掴みにくい。そして障害が起きたとき、最も問題を切り分けにくいのもネットワークだ。だからこそ、IaaSのネットワーク抽象化を深く理解することは、クラウドアーキテクトにとって不可欠な能力なのだ。

---

## 4. OpenStack——オープンソースIaaSの壮大な実験

### 「AWSをオープンソースで再現する」という野心

IaaSの本質を理解するうえで、OpenStackの歴史を避けて通ることはできない。OpenStackは「IaaSを自分たちの手で構築する」という試みであり、IaaSの構成要素を分解して見せてくれたプロジェクトだからだ。

2010年初頭、NASAのソフトウェア開発者とRackspaceの代表者が会合を持った。NASAは内部クラウド「Nebula」のためにNova（計算）を、Rackspaceはオブジェクトストレージのswiftを開発していた。両者は「IaaSをオープンソースで構築する」ビジョンで一致し、2010年7月21日にOSCONで正式発表。10月21日に最初のリリース「Austin」が公開された。NovaとSwiftの2コンポーネントが、IaaSの核心——計算とストレージ——をオープンソースで提供する第一歩だった。

OpenStackのアーキテクチャは、IaaSの構成要素を明確に分離している。

```
OpenStackの主要コンポーネント（IaaSとの対応）:

  ┌─────────────────────────────────────────────┐
  │              OpenStack Dashboard (Horizon)    │
  │                  （Webインターフェース）        │
  ├─────────────────────────────────────────────┤
  │                  API Layer                    │
  ├──────────┬──────────┬──────────┬─────────────┤
  │  Nova    │  Cinder  │ Neutron  │  Swift      │
  │ (計算)   │(ブロック │(ネット   │(オブジェクト│
  │          │ストレージ│ ワーク)  │ ストレージ) │
  │ EC2相当  │ EBS相当  │ VPC相当  │  S3相当     │
  ├──────────┴──────────┴──────────┴─────────────┤
  │  Keystone（認証/認可）── IAM相当              │
  │  Glance（マシンイメージ管理）── AMI相当       │
  │  Heat（オーケストレーション）── CloudFormation │
  └─────────────────────────────────────────────┘
```

この対応関係を見れば、IaaSが「サーバの貸し出し」ではないことが一目瞭然だ。IaaSとは、計算（Nova/EC2）、ブロックストレージ（Cinder/EBS）、オブジェクトストレージ（Swift/S3）、ネットワーク（Neutron/VPC）、認証認可（Keystone/IAM）、マシンイメージ管理（Glance/AMI）——これらの独立したコンポーネントが、APIで連携する統合システムだ。

### OpenStackの教訓——IaaSを「構築する」ことの困難さ

OpenStackは多くの期待を集めた。「AWSに匹敵するIaaSを、オープンソースで、自社のデータセンターに構築できる」——この約束は、特にベンダーロックインを懸念するエンタープライズに響いた。

だが現実は厳しかった。

モジュールが追加されるにつれて、シンプルさは失われ、複雑性が急速に増大した。OpenStackのデプロイと運用には深い専門知識が必要であり、それ自体が一つの専門分野になった。2015年にHPがHelion Public Cloudを終了し、2017年にCiscoがIntercloudを3年で畳んだとき、パブリッククラウドに対抗するオープンソースIaaSという夢の限界が見えた。2020年時点で、調査会社Gartnerが確認したOpenStackの本格的な本番環境は約2,000件——当初の期待を大幅に下回る数字だった。

OpenStackが教えてくれたのは、「IaaSを構築することの困難さ」だ。AWSが提供するIaaSの裏側には、カスタムハードウェア（Nitroシステム）、世界規模のネットワーク、数十万台の物理サーバを運用する組織力、そして10年以上にわたる運用経験の蓄積がある。これをオープンソースソフトウェアだけで再現しようとする試みは、ソフトウェアの問題ではなく、運用の問題にぶつかったのだ。

だがOpenStackは失敗ではない。テレコム業界やプライベートクラウド領域では今なお重要な役割を果たしている。そして何より、IaaSの構成要素を可視化し、「クラウドの裏側で何が動いているか」をオープンソースコードとして世界に公開した。IaaSを理解したい者にとって、OpenStackは最良の教科書だ。

---

## 5. Shared Responsibility Model——抽象化が生む責任の境界線

### 「クラウドのセキュリティ」と「クラウド内のセキュリティ」

IaaSの抽象化は便利だが、一つの重大な問いを生む。「誰が何に責任を持つのか」だ。

物理サーバを自分で管理していた時代、責任の所在は明確だった。ハードウェアの故障も、OSのセキュリティパッチも、ネットワークの設定ミスも、全て自分の責任だ。つらいが、わかりやすい。

IaaSでは、責任が分割される。AWSが「Shared Responsibility Model（責任共有モデル）」と呼ぶこの概念は、クラウドアーキテクチャにおける最も重要なメンタルモデルの一つだ。

原則は明快だ。**AWSは「クラウドのセキュリティ」（Security of the Cloud）に責任を持つ。顧客は「クラウド内のセキュリティ」（Security in the Cloud）に責任を持つ。**

```
Shared Responsibility Model（IaaSの場合）:

  顧客の責任（Security IN the Cloud）:
  データ / アプリケーション / アクセス制御（IAM）
  OS（パッチ適用） / ネットワーク設定（SG） / 暗号化
  ─────────── 責任の境界線 ───────────
  AWSの責任（Security OF the Cloud）:
  ハイパーバイザ / 物理ネットワーク / 物理ストレージ
  物理サーバ / データセンター（電力/冷却/物理セキュリティ）
```

この境界線はサービスモデルによって移動する。IaaS（EC2）では、ゲストOSの管理は顧客の責任だ。セキュリティパッチの適用、ファイアウォールの設定、ミドルウェアのバージョン管理——全て顧客が行う。一方、マネージドサービス（S3、DynamoDB等）では、AWSがOS、プラットフォーム、ネットワーク設定を管理し、顧客はデータとアクセス制御に集中できる。

私が骨身に沁みて学んだのは、この境界線を曖昧にしたまま運用すると必ず事故が起きるということだ。セキュリティグループで全ポートを開放する、S3バケットをパブリックに設定する、IAMユーザーにAdministratorAccessを付与する——これらは全て「クラウド内のセキュリティ」の問題であり、顧客の責任範囲だ。AWSはこれらの設定ミスを防ぐことはできない。

### 抽象化レベルと責任範囲の反比例

**抽象化レベルが上がるほど、利用者の責任範囲は小さくなる。** だが責任が小さいということは、制御できる範囲も小さいということだ。IaaSを選択する最大の理由は制御の幅にある。OSレベルの設定、ミドルウェアの選択、ネットワーク構成の細かな制御——だがその自由には責任が伴う。このトレードオフを意識的に選択できるかどうかが、IaaSを「使う」のと「使いこなす」の違いだ。

---

## 6. ハンズオン——VPCをゼロから手動で構築する

ここからは、VPC（Virtual Private Cloud）をゼロから手動で構築し、IaaSのネットワーク抽象化を体感する。マネジメントコンソールのウィザードやIaCツールを使わず、AWS CLIで一つずつリソースを作成することで、VPCの構造を「部品」のレベルで理解する。

### 環境

- Docker（Ubuntu 24.04ベースコンテナ）
- AWS CLI v2
- AWSアカウント（無料枠の範囲で実行可能）

### 演習1：VPCの骨格を構築する

```bash
# Docker環境で作業する
docker run -it --rm ubuntu:24.04 bash

# AWS CLI v2 のインストール
apt-get update && apt-get install -y curl unzip less jq
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o "awscliv2.zip"
unzip -q awscliv2.zip && ./aws/install

# 認証情報の設定（自分のアクセスキーを使用）
aws configure
# AWS Access Key ID: （入力）
# AWS Secret Access Key: （入力）
# Default region name: ap-northeast-1
# Default output format: json
```

まず、VPCを作成する。CIDRブロック（IPアドレス範囲）を指定する。

```bash
# VPCを作成（10.0.0.0/16 = 65,536個のIPアドレス空間）
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --query 'Vpc.VpcId' \
  --output text)

echo "VPC ID: ${VPC_ID}"

# VPCにDNSホスト名を有効化
aws ec2 modify-vpc-attribute \
  --vpc-id "${VPC_ID}" \
  --enable-dns-hostnames '{"Value": true}'

# 名前タグを付与
aws ec2 create-tags \
  --resources "${VPC_ID}" \
  --tags Key=Name,Value=handson-vpc
```

この時点で、論理的に隔離されたネットワーク空間が作成された。だが、この中にはまだ何もない。サブネットも、インターネットへの出口もない。VPCは「空の箱」だ。

### 演習2：サブネットを作成する——パブリックとプライベート

VPCの中にサブネットを作成する。パブリックサブネット（インターネットからアクセス可能）とプライベートサブネット（インターネットから直接アクセス不可）の2つを作る。

```bash
# パブリックサブネットを作成（10.0.1.0/24 = 256個のIPアドレス）
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id "${VPC_ID}" \
  --cidr-block 10.0.1.0/24 \
  --availability-zone ap-northeast-1a \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags \
  --resources "${PUBLIC_SUBNET_ID}" \
  --tags Key=Name,Value=handson-public-subnet

# プライベートサブネットを作成（10.0.2.0/24）
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id "${VPC_ID}" \
  --cidr-block 10.0.2.0/24 \
  --availability-zone ap-northeast-1a \
  --query 'Subnet.SubnetId' \
  --output text)

aws ec2 create-tags \
  --resources "${PRIVATE_SUBNET_ID}" \
  --tags Key=Name,Value=handson-private-subnet

echo "Public Subnet: ${PUBLIC_SUBNET_ID}"
echo "Private Subnet: ${PRIVATE_SUBNET_ID}"
```

サブネットを作成しても、まだ「パブリック」と「プライベート」の区別は存在しない。名前タグをつけただけだ。サブネットがパブリックかプライベートかを決めるのは、ルーティングだ。

### 演習3：インターネットゲートウェイとルーティング

```bash
# インターネットゲートウェイを作成
IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

# VPCにアタッチ
aws ec2 attach-internet-gateway \
  --internet-gateway-id "${IGW_ID}" \
  --vpc-id "${VPC_ID}"

# パブリックサブネット用のルートテーブルを作成
PUBLIC_RT_ID=$(aws ec2 create-route-table \
  --vpc-id "${VPC_ID}" \
  --query 'RouteTable.RouteTableId' \
  --output text)

aws ec2 create-tags \
  --resources "${PUBLIC_RT_ID}" \
  --tags Key=Name,Value=handson-public-rt

# デフォルトルート（0.0.0.0/0）をインターネットゲートウェイに向ける
aws ec2 create-route \
  --route-table-id "${PUBLIC_RT_ID}" \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id "${IGW_ID}"

# パブリックサブネットにルートテーブルを関連付け
aws ec2 associate-route-table \
  --route-table-id "${PUBLIC_RT_ID}" \
  --subnet-id "${PUBLIC_SUBNET_ID}"
```

ここがポイントだ。パブリックサブネットとプライベートサブネットの違いは、**ルートテーブルにインターネットゲートウェイへのルートがあるかどうか**だけだ。パブリックサブネットのルートテーブルには `0.0.0.0/0 → IGW` というルートがあり、プライベートサブネットのルートテーブルにはそれがない。この一行のルーティング設定が、ネットワークの性格を決定する。

```
VPCの構造（ここまでの状態）:

  VPC: 10.0.0.0/16
  ├── Public Subnet 10.0.1.0/24 (AZ:1a)
  │   Route: 10.0.0.0/16→local, 0.0.0.0/0→IGW
  ├── Private Subnet 10.0.2.0/24 (AZ:1a)
  │   Route: 10.0.0.0/16→local （IGWルートなし）
  └── Internet Gateway → Internet
```

### 演習4：セキュリティグループの設定

```bash
# セキュリティグループを作成
SG_ID=$(aws ec2 create-security-group \
  --group-name handson-sg \
  --description "Handson security group" \
  --vpc-id "${VPC_ID}" \
  --query 'GroupId' \
  --output text)

# SSH（22番ポート）を許可
# ※ 実運用では 0.0.0.0/0 ではなく自分のIPに限定すること
aws ec2 authorize-security-group-ingress \
  --group-id "${SG_ID}" \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# HTTP（80番ポート）を許可
aws ec2 authorize-security-group-ingress \
  --group-id "${SG_ID}" \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

echo "Security Group: ${SG_ID}"
```

セキュリティグループは「ステートフルファイアウォール」だ。インバウンドルールで許可した通信のレスポンスは、アウトバウンドルールを設定しなくても自動的に許可される。これは従来のネットワークACL（アクセス制御リスト）とは異なる抽象化だ。物理ファイアウォールの設定に慣れた人間が、この「ステートフル」の概念を把握するまでに時間がかかることがある。

### 演習5：構築したVPCの確認と解体

```bash
# 作成したリソースの確認
aws ec2 describe-vpcs --vpc-ids "${VPC_ID}" --output table
aws ec2 describe-subnets --filters "Name=vpc-id,Values=${VPC_ID}" --output table

# クリーンアップ（課金を避けるため必ず実行）
# 依存関係の逆順で削除する
aws ec2 delete-security-group --group-id "${SG_ID}"
aws ec2 disassociate-route-table \
  --association-id $(aws ec2 describe-route-tables \
    --route-table-ids "${PUBLIC_RT_ID}" \
    --query 'RouteTables[0].Associations[?!Main].RouteTableAssociationId' \
    --output text)
aws ec2 delete-route-table --route-table-id "${PUBLIC_RT_ID}"
aws ec2 detach-internet-gateway \
  --internet-gateway-id "${IGW_ID}" --vpc-id "${VPC_ID}"
aws ec2 delete-internet-gateway --internet-gateway-id "${IGW_ID}"
aws ec2 delete-subnet --subnet-id "${PUBLIC_SUBNET_ID}"
aws ec2 delete-subnet --subnet-id "${PRIVATE_SUBNET_ID}"
aws ec2 delete-vpc --vpc-id "${VPC_ID}"
```

VPCの構築に必要なリソースは、VPC本体、サブネット、インターネットゲートウェイ、ルートテーブル、セキュリティグループ——最低でも5種類だ。そしてこれらは独立したリソースであり、APIで個別に作成し、関連付けて初めて機能する。削除時に依存関係の逆順を辿る必要があることも、リソース間の関係性を体感させてくれる。

マネジメントコンソールのウィザードやTerraformはこの複雑さを隠蔽する。だが、これらのツールが隠しているものの実体を知らなければ、障害時に対処できない。抽象化の裏側を知ることは、抽象化を正しく使うための前提条件なのだ。

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/11-iaas-essence/` に用意してある。

---

## 7. まとめと次回予告

### この回のまとめ

第11回では、IaaS（Infrastructure as a Service）の本質を「抽象化のレイヤー」として読み解いた。

**IaaSは「サーバの貸し出し」ではない。** 計算（CPU/メモリ）、ストレージ（ブロック/オブジェクト/ファイル）、ネットワーク（VPC/サブネット/ルーティング/セキュリティグループ）——これら三つの物理リソースを、独立したコンポーネントとして抽象化し、APIで統合的に制御可能にした「プログラマブルインフラ」がIaaSだ。

**NISTのSP 800-145（2011年）は、クラウドの5つの本質的特性を定義した。** オンデマンド・セルフサービス、ブロードネットワークアクセス、リソースプーリング、ラピッドエラスティシティ、メジャードサービス——この5つの特性を満たして初めて「クラウド」と呼べる。単にサーバをリモートで貸しているだけでは、NISTの定義するクラウドには該当しない。

**OpenStack（2010年）は、IaaSの構成要素を可視化した。** NASAとRackspaceが共同で始めたこのプロジェクトは、パブリッククラウドに対抗する夢こそ実現しなかったが、Nova（計算）、Swift（オブジェクトストレージ）、Cinder（ブロックストレージ）、Neutron（ネットワーク）という分解がIaaSの内部構造を明らかにした。IaaSの構築がいかに困難かを、身をもって示した。

**AWS Nitroシステムは、抽象化のコストを最小化する試みだ。** ネットワーク、ストレージ、管理機能を専用ハードウェアにオフロードすることで、仮想化のオーバーヘッドを極限まで削減し、ベアメタルに近いパフォーマンスを仮想マシンで実現した。

**Shared Responsibility Modelは、抽象化が生む責任の境界線を定義する。** 「クラウドのセキュリティ」はプロバイダーが、「クラウド内のセキュリティ」は利用者が責任を持つ。抽象化レベルが上がるほど利用者の責任は小さくなるが、制御できる範囲も小さくなる。このトレードオフを意識的に選択できることが、IaaSを使いこなすための条件だ。

冒頭の問いに答えよう。「IaaSは結局のところ何を抽象化しているのか？」——物理ハードウェアの個別性、物理的な場所の制約、そしてリソース調達のリードタイムだ。一台一台のサーバの個性（スペック差、故障確率、配置場所）を隠蔽し、「計算能力」「ストレージ容量」「ネットワーク帯域」という均質な単位で提供する。それがIaaSの抽象化だ。

### 次回予告

第12回では、「マルチテナント設計——クラウドの核心イノベーション」を掘り下げる。

IaaSの抽象化を支える最も重要な技術的原理——それがマルチテナンシーだ。一台の物理ホストの上に、異なる顧客の仮想マシンが同居する。この「同居」がクラウドのコスト効率を生み出す根源であり、同時に最大のリスクでもある。

「Noisy Neighbor」——隣人のワークロードが自分のインスタンスの性能を食い尽くす問題。Spectre/Meltdown——ハードウェアレベルの隔離の限界を露呈したCPU脆弱性。Firecracker——AWSがLambdaのために開発したマイクロVM。マルチテナンシーの光と影を、次回は徹底的に見ていく。

あなたの仮想マシンの「隣人」が誰なのか——考えたことはあるだろうか。

---

## 参考文献

- Peter Mell, Timothy Grance, "The NIST Definition of Cloud Computing", NIST Special Publication 800-145, September 2011. <https://csrc.nist.gov/pubs/sp/800/145/final>
- OpenStack Project Team Guide, "Introduction: A Bit of OpenStack History". <https://docs.openstack.org/project-team-guide/introduction.html>
- AWS, "Introducing Amazon Virtual Private Cloud", August 2009. <https://aws.amazon.com/about-aws/whats-new/2009/08/26/introducing-amazon-virtual-private-cloud/>
- AWS, "Shared Responsibility Model". <https://aws.amazon.com/compliance/shared-responsibility-model/>
- M. Mahalingam et al., "Virtual eXtensible Local Area Network (VXLAN)", RFC 7348, August 2014. <https://datatracker.ietf.org/doc/html/rfc7348>
- Werner Vogels, "Reinventing virtualization with the AWS Nitro System", All Things Distributed, September 2020. <https://www.allthingsdistributed.com/2020/09/reinventing-virtualization-with-nitro.html>
- AWS, "The Security Design of the AWS Nitro System" (whitepaper). <https://docs.aws.amazon.com/whitepapers/latest/security-design-of-aws-nitro-system/the-nitro-system-journey.html>
- The Register, "OpenStack at 10 years old: A failure on its own terms, a success in its own niche", October 2020. <https://www.theregister.com/2020/10/22/openstack_at_10/>
- Google Cloud, "VPC networks". <https://cloud.google.com/vpc/docs/vpc>
