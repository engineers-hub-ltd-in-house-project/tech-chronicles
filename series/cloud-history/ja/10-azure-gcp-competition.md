# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第10回：Azure、GCP——寡占と競争の構造

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- AWSの独走に対して、MicrosoftとGoogleがそれぞれどのような設計思想でクラウド市場に参入したか
- Windows Azure（2008年発表、2010年GA）の誕生経緯——「Project Red Dog」からエンタープライズ統合プラットフォームへ
- Google App Engine（2008年）からCompute Engine（2013年GA）へ——PaaS先行戦略とIaaS後発参入の背景
- Satya Nadella（2014年CEO就任）の「Mobile first, Cloud first」戦略がAzureを劇的に成長させた構造
- Thomas Kurian（2019年就任）によるGoogle Cloudのエンタープライズ戦略転換
- 2025年時点の市場シェア——AWS約30%、Azure約20%、GCP約13%——寡占構造の実態と各社の差別化軸
- 技術選定が「技術」だけでなく「組織文化」と「設計思想」に規定される現実
- AWS/GCP/Azure各社CLIの設計思想の違いを体感するハンズオン

---

## 1. 「AWSだけ知っていればいい」という思い込み

2010年頃、私はAWSの世界に没入していた。

前回、前々回で書いたとおり、EC2、S3、SQS——AWSの「ビルディングブロック」を組み合わせてアーキテクチャを構築する感覚に、私はすっかり魅了されていた。APIを叩けばサーバが立ち上がり、S3にデータを格納すればイレブンナインの耐久性が保証される。この体験は革命的だった。そして、革命の渦中にいる人間は往々にして視野が狭くなる。

「クラウド＝AWS」。当時の私の認識はそこで止まっていた。

その認識が最初に揺さぶられたのは、あるデータ分析プロジェクトだった。数百GBのログデータを集計する必要があり、当時のAWSではEMR（Elastic MapReduce）でHadoopクラスタを立てるか、Redshiftにデータをロードするしかなかった。どちらも環境構築と運用に相当な手間がかかる。そのとき同僚が「BigQueryを試さないか」と言った。Google Cloud Platformのサービスだった。

BigQueryにデータをロードし、SQLを実行した。数百GBのデータに対するクエリが、数十秒で返ってきた。クラスタの構築も管理も不要。サーバーレスのデータウェアハウス。2010年に発表されたこのサービスは、Google内部で使われていたDremelという分散クエリエンジンの技術を外部に提供したものだった。

「データ分析の領域では、Googleには別の強みがある」——当然といえば当然の事実に、私はようやく気づいた。

その後、エンタープライズ案件でAzureに触れる機会が来た。クライアントの情報システム部門との打ち合わせで、インフラ基盤としてAzureが指定されていた。理由を聞くと「Active Directoryとの統合が容易だから」という回答だった。技術的な機能比較ではなく、組織の既存資産との親和性で選ばれている。Microsoft 365を全社導入している企業にとって、Azure Active Directory（現Microsoft Entra ID）との統合はシームレスだ。AWSでそれを実現するには、追加のID連携の構築が必要になる。

技術だけでクラウドは選ばれない。組織文化、既存のIT資産、ベンダーとの関係性、経営層の意思決定構造——これらがクラウド選定に深く影響する。そしてAzure、GCPがそれぞれ異なる設計思想を持つのは、まさにこの「技術以外の要素」を見据えた戦略的判断の結果なのだ。

あなたは、自分が使っているクラウドを「なぜ」選んだか、説明できるだろうか。技術的な機能比較だけでなく、その選択の背後にある構造的な力学を意識したことがあるだろうか。

---

## 2. Microsoft Azureの誕生——エンタープライズの巨人がクラウドに賭けた日

### 「Project Red Dog」——2008年の静かな始動

AWSがEC2を公開した2006年、Microsoftは何をしていたか。

正直に言えば、出遅れていた。2006年時点のMicrosoftは、Windows Server、SQL Server、.NET Frameworkといったオンプレミスソフトウェアのライセンス販売が主要な収益源だった。クラウドは、自社のビジネスモデルを破壊しかねない存在だった。ライセンス販売で年間数百億ドルを稼ぐ企業が、従量課金のクラウドサービスに全力で舵を切ることは、容易な判断ではない。

それでもMicrosoftは動いた。社内では「Project Red Dog」というコードネームで、クラウドプラットフォームの開発が秘密裏に進められていた。プロジェクトを率いたのはDave CutlerとAmitabh Srivastavaだ。Dave Cutlerは、VMS（Digital Equipment Corporation）とWindows NTのアーキテクトとして知られる、OS設計の巨匠だ。Cutlerがクラウドプラットフォームの設計に関わっていたという事実は、Microsoftがこのプロジェクトにどれほどの重みを置いていたかを物語る。

2008年10月27日、MicrosoftのPDC（Professional Developers Conference）で、当時のチーフソフトウェアアーキテクトRay Ozzieが「Windows Azure」を発表した。Ozzieは壇上でこう述べた——「Azureは、Microsoftの全てのサービスの基盤となるべきものだ」。

この発表から商用サービスの開始までには、1年以上を要した。Windows Azure Platformが一般提供（GA）されたのは2010年2月1日のことだ。21カ国で商用サービスが開始され、SLA（Service Level Agreement）が適用された。AWSのEC2パブリックベータ（2006年8月）から数えて約3年半の遅れだった。

### エンタープライズ統合プラットフォームとしてのAzure

Azureの設計思想は、最初からAWSとは根本的に異なっていた。

AWSは「ビルディングブロック」——小さな独立したプリミティブをAPIで組み合わせる設計だった。EC2、S3、SQSはそれぞれ独立しており、開発者が自由に組み立てる。UNIXの哲学に近い。

Azureは「統合プラットフォーム」を志向した。Windows Server、SQL Server、Active Directory、Visual Studio、.NET——Microsoftが数十年かけて構築してきたエンタープライズソフトウェアのエコシステムを、クラウドに延伸する。オンプレミスで動いていたワークロードが、コードの書き換えなしに（あるいは最小限の修正で）クラウドで動く。それがAzureの原初的な設計意図だった。

```
AWSとAzureの設計思想の違い:

  AWS（2006年〜）
  ── 小さなビルディングブロックの集合体
  ── 開発者が自由に組み合わせる
  ── Unix哲学的: 一つのことをうまくやるサービス群
  ── 起点: Amazon.comの内部インフラの外部公開

  Azure（2010年〜）
  ── エンタープライズ統合プラットフォーム
  ── 既存のMicrosoft製品との連続性を重視
  ── Windows Server / Active Directory / .NETとの統合
  ── 起点: エンタープライズ顧客のクラウド移行支援
```

この設計思想の違いは、利用者の属性にも反映されている。AWSの初期ユーザーはスタートアップと技術志向の開発者だった。Netflix、Airbnb、Pinterest——これらの企業がAWSを選んだのは、APIの柔軟性と従量課金モデルがスタートアップの成長パターンに合致したからだ。

一方、Azureの顧客層の中核は、既にMicrosoft製品を大規模に導入しているエンタープライズだった。Windows ServerでActive Directoryを運用し、Exchange Serverでメールを管理し、SQL Serverでデータベースを動かしている企業。彼らにとって、AWSへの移行は「未知のプラットフォームへの全面的な移行」を意味した。Azureへの移行は「既に知っているMicrosoftの世界の延長」だった。

### Satya Nadellaの転換——「Mobile first, Cloud first」

Azureの初期は、決して順風満帆ではなかった。Windows Azure Platformの初期バージョンは、PaaS（Platform as a Service）に特化しており、IaaS（仮想マシンの直接提供）には対応していなかった。AWSのEC2に相当するIaaS機能——Azure Virtual Machinesが追加されたのは2012年のことだ。この判断は後から見れば明らかな戦略ミスだった。エンタープライズ顧客がクラウドに求めた最初の一歩は、既存のワークロードをそのまま仮想マシンに載せる「リフト＆シフト」であり、それにはIaaSが必要だった。

転機は2014年に訪れた。2月4日、Satya NadellaがMicrosoftの第3代CEOに就任した。Nadellaは就任直後の社内メールで「Mobile first, Cloud first」——モバイルとクラウドを最優先する戦略を宣言した。この宣言は、単なるスローガンではなかった。Microsoftの事業構造を、ライセンス販売モデルからクラウドサブスクリプションモデルへと根本的に転換する決断だった。

Nadellaの下で、Azureは三つの方向に大きく舵を切った。

第一に、Linuxとオープンソースの全面的な受容だ。かつてSteve BallmerがLinuxを「癌」と呼んだMicrosoftが、Azure上でLinuxの仮想マシンを第一級市民として扱うようになった。2016年時点で、Azure上の仮想マシンの3分の1以上がLinuxだった。現在ではその比率はさらに高い。

第二に、ハイブリッドクラウド戦略の推進だ。Azure Stackによって、Azureと同一のAPIと管理モデルをオンプレミス環境でも利用可能にした。エンタープライズ顧客にとって「全てをクラウドに移す」ことは、規制要件、データ主権、レイテンシー要件などの理由で現実的でない場合が多い。Azureは「クラウドとオンプレミスのシームレスな連続性」を売りにした。

第三に、Microsoft 365（旧Office 365）との統合だ。Azure Active Directory（現Microsoft Entra ID）を軸に、メール、ファイル共有、コミュニケーション、ID管理をクラウド上で統合する。エンタープライズのIT管理者にとって、この統合は絶大な価値を持つ。個別のサービスを組み合わせる手間なく、一つのプラットフォームで全てが管理できる。

この戦略は奏功した。Azureの収益は急成長し、2025年時点でクラウドインフラ市場シェアの約20%を占める。AWSの約30%に次ぐ第2位だ。

---

## 3. Google Cloud Platform——Googleスケールの技術を外部に開く

### PaaS先行という異色の参入

Googleのクラウド参入は、AWSともAzureとも異なる経路を辿った。

2008年4月、GoogleはApp Engineをプレビュー公開した。AWSのEC2が「仮想マシンを貸す」IaaSだったのに対し、App Engineは「アプリケーションをGoogle上で動かす」PaaSだった。仮想マシンの管理は不要。アプリケーションコードをデプロイすれば、Googleのインフラが自動的にスケーリングする。

この設計判断は、Googleの文化を色濃く反映している。Google社内では、エンジニアが物理サーバや仮想マシンを直接管理することはない。Borg（後のKubernetesの原型）がリソース管理を抽象化し、Bigtable、Spanner、GFSといった分散システムがデータを管理する。Googleのエンジニアにとって、「サーバを管理する」という発想自体が異質だった。だから最初に外部に提供したのも、「サーバを貸す」のではなく「アプリケーション実行環境を提供する」PaaSだった。

だがこの判断は、市場の現実との間にギャップを生んだ。

2008年から2012年頃、クラウドに移行しようとする企業の多くが求めていたのは「既存のワークロードをそのまま動かせる仮想マシン」——つまりIaaSだった。App Engineの抽象化レベルは高すぎた。Pythonのみ（後にJava、Go、PHPが追加）、ファイルシステムへの書き込み不可、リクエスト時間制限あり、使えるライブラリに制約あり——これらの制約は、Googleスケールのアプリケーションを作るための合理的な設計だったが、既存アプリケーションの移行先としては使いにくかった。

Googleがこのギャップを認識し、IaaSに本格参入したのは2012年のことだ。Google Compute Engineは2012年6月のGoogle I/Oで限定プレビューとして発表され、一般提供（GA）は2013年12月だった。AWSのEC2（2006年）から7年、AzureのIaaS対応（2012年）からも1年以上遅れた後発参入だった。

### 差別化の軸——データ分析とML

Googleがクラウド市場で独自の地位を築いた領域がある。データ分析と機械学習だ。

2010年にBigQueryが発表された。Google社内で使われていた分散クエリエンジンDremelの技術を、外部向けサービスとして提供したものだ。BigQueryの革新性は「サーバーレスデータウェアハウス」という概念にあった。従来のデータウェアハウス（Amazon Redshift、Teradata等）は、クラスタの構築、サイジング、チューニングが必要だった。BigQueryはそれらを全て不要にした。データをロードし、SQLを書き、実行する。それだけだ。ペタバイト規模のデータに対するクエリが数秒から数十秒で返る。

```
データ分析アプローチの違い:

  AWS Redshift（2012年GA）
  ── クラスタベースのデータウェアハウス
  ── ノード数とタイプを事前に選択
  ── 容量に応じた時間課金
  ── 従来のMPP（大規模並列処理）アーキテクチャ

  Google BigQuery（2010年発表）
  ── サーバーレスデータウェアハウス
  ── インフラ管理不要
  ── クエリ処理量に応じた課金
  ── Dremel由来の列指向分散処理エンジン
  ── ストレージとコンピュートの完全分離

  Azure Synapse Analytics（2019年GA）
  ── 統合分析サービス
  ── サーバーレスとプロビジョニングの両対応
  ── Power BI / Azure MLとの統合
  ── Microsoft BI エコシステムとの連携
```

さらにGoogleは、TensorFlow（2015年オープンソース化）、TPU（Tensor Processing Unit、2016年発表）、Cloud ML Engine（現Vertex AI）といったML/AIインフラの提供で、データサイエンスと機械学習のワークロードに強い訴求力を持った。「データを分析し、モデルを訓練し、推論を実行する」——この一連のワークフローにおいて、GCPは他の二社にはない統合的な強みを持っていた。

### エンタープライズへの遅れと戦略転換

しかし、データ分析とMLの強みだけでは、クラウド市場全体のシェアを獲得するには不十分だった。

Googleのクラウド事業が長らく抱えていた課題は、エンタープライズ営業力の不足だった。Googleは広告事業を基盤とする企業であり、その顧客は主にインターネット上のエンドユーザーだ。大企業のIT部門に対して、数年にわたる関係構築、セキュリティ監査への対応、カスタム契約の交渉、24時間365日の有人サポート——これらのエンタープライズ営業に必要な能力は、Googleの組織文化の中で十分に培われてこなかった。

2015年11月、GoogleはVMware共同創業者のDiane Greeneを Google Cloud部門のCEOに迎えた。Greeneの下で、エンタープライズ向けの営業チームが拡充され、SAP、Salesforceなどのエンタープライズパートナーシップが構築された。しかし、AWSやAzureとのシェア差は縮まらなかった。

2019年1月、Diane Greeneの後任としてThomas KurianがGoogle Cloud CEOに就任した。Kurianは元Oracle幹部であり、エンタープライズソフトウェアの世界で30年以上のキャリアを持つ人物だ。KurianはCNBCのインタビューで「Googleはより積極的に競争する」と明言し、エンタープライズ営業の大幅な強化を推進した。

Kurian体制下で、Googleは営業・販売機能をほぼ4倍に拡大した。Anthosを発表し、顧客がオンプレミス、Google Cloud、さらにはAWSやAzure上でもアプリケーションを統一的に管理できるマルチクラウドプラットフォームを提供した。「Googleのインフラ技術をどこでも使える」——この訴求は、クラウドのロックイン問題を懸念する企業に響いた。

2025年現在、GCPの市場シェアは約13%。AWSの約30%、Azureの約20%に次ぐ第3位だが、前年同期比で30%以上の成長率を維持しており、三社の中で最も高い成長率を記録している。

---

## 4. 三社の設計思想の比較——なぜ「同じクラウド」が三つ必要なのか

### ビルディングブロック vs 統合プラットフォーム vs Googleスケールの外部提供

三社のクラウドサービスは、表面的には同じことを提供しているように見える。仮想マシン、ストレージ、データベース、ネットワーク、コンテナ、サーバーレス——カタログ上の機能リストは似通っている。だが、その背後にある設計思想は根本的に異なる。

**AWSの設計思想：ビルディングブロック**

AWSは「小さなプリミティブの集合体」を基本原則とする。EC2、S3、SQS、Lambda、DynamoDB——各サービスは独立しており、開発者が自由に組み合わせる。この思想は前回解説したBezosのAPIマンデートに端を発し、UNIXの「一つのことをうまくやる」哲学と通底している。

AWSの強みは選択肢の豊富さだ。2025年現在、AWSは200以上のサービスを提供している。データベースだけでも、RDS（リレーショナル）、DynamoDB（キーバリュー）、ElastiCache（インメモリ）、Neptune（グラフ）、Timestream（時系列）、Keyspaces（Cassandra互換）、DocumentDB（MongoDB互換）——目的に応じて最適なサービスを選べる。

だがこの豊富さは裏返せば複雑さだ。「どのサービスを使えばいいのか」という判断が常に求められる。AWSの学習曲線が急峻なのは、サービス数の多さだけでなく、「組み合わせ方」を自分で判断しなければならないことに起因する。

**Azureの設計思想：エンタープライズ統合プラットフォーム**

Azureは「Microsoftエコシステムとの統合」を基本原則とする。Azure Active Directory（現Microsoft Entra ID）、Azure DevOps、Azure SQL Database、Power BI、Microsoft 365——これらは個別のサービスではなく、統合されたプラットフォームの一部として設計されている。

Azureの強みは、エンタープライズの既存環境との連続性だ。Active Directoryで管理されるID、Exchangeのメール、SharePointのファイル共有——オンプレミスで運用されているこれらの資産を、最小限の摩擦でクラウドに拡張できる。ハイブリッドクラウドにおいて、Azureは三社の中で最もシームレスな体験を提供する。

Azureの課題は、Microsoft以外の技術スタックとの親和性だ。LinuxやOSS対応は大幅に改善されたが、「Microsoftの世界」の外から来た開発者にとっては、ドキュメントの構造やサービス名称の命名規則に馴染みにくさを感じることがある。

**GCPの設計思想：Googleスケールの技術を外部提供**

GCPは「Googleが内部で使っている技術を外部にも提供する」を基本原則とする。BigQuery（Dremel由来）、Cloud Spanner（Spanner由来）、GKE（Borg/Kubernetes由来）、Cloud Bigtable（Bigtable由来）——GCPの主要サービスの多くは、Googleが自社のサービス（検索、Gmail、YouTube等）を運用するために開発した技術の外部提供だ。

GCPの強みは、大規模分散システムの技術力だ。Spannerのようなグローバル分散データベース、BigQueryのようなサーバーレスデータウェアハウス、TPUのようなML専用ハードウェア——これらは、Google自身が世界規模のサービスを運用する中で鍛えられた技術であり、他社が容易に追随できないものだ。

GCPの課題は、サービスの「完成度」と「企業向け成熟度」のギャップだ。Googleは技術的に先進的なサービスを素早く公開するが、エンタープライズが求めるサポート体制、SLA、コンプライアンス認証の整備には時間がかかる傾向がある。また、Googleのサービス終了の歴史（Google Reader、Hangouts等）が、エンタープライズ顧客に「このサービスは将来も継続されるのか」という不安を与える側面もある。

```
三社の設計思想を一枚の図にまとめる:

  ┌──────────────────────────────────────────────────────────┐
  │               クラウドの三つの設計思想                   │
  ├──────────┬──────────────┬──────────────┬────────────────┤
  │          │    AWS       │   Azure      │    GCP         │
  ├──────────┼──────────────┼──────────────┼────────────────┤
  │ 設計原則 │ ビルディング │ エンタープ   │ Googleスケール │
  │          │ ブロック     │ ライズ統合   │ 技術の外部提供 │
  ├──────────┼──────────────┼──────────────┼────────────────┤
  │ 起点     │ Amazon.com   │ Windows      │ Google内部     │
  │          │ 内部インフラ │ Server /     │ インフラ技術   │
  │          │ の外部公開   │ Active       │ （Borg,        │
  │          │              │ Directory    │   Dremel等）   │
  ├──────────┼──────────────┼──────────────┼────────────────┤
  │ 強み     │ 選択肢の     │ エンタープ   │ データ分析、   │
  │          │ 豊富さ、     │ ライズ統合、 │ ML/AI基盤、    │
  │          │ エコシステム │ ハイブリッド │ 大規模分散     │
  ├──────────┼──────────────┼──────────────┼────────────────┤
  │ 課題     │ 複雑性、     │ Microsoft外  │ エンタープ     │
  │          │ 学習曲線     │ との親和性   │ ライズ営業力、 │
  │          │              │              │ サービス継続性 │
  ├──────────┼──────────────┼──────────────┼────────────────┤
  │ 顧客層   │ スタートアップ│ エンタープ   │ データ/AI      │
  │ の傾向   │ 技術志向企業 │ ライズ、     │ 志向企業、     │
  │          │              │ MS製品       │ テック企業     │
  │          │              │ 利用企業     │                │
  ├──────────┼──────────────┼──────────────┼────────────────┤
  │ シェア   │ 約30%        │ 約20%        │ 約13%          │
  │ (2025)   │              │              │                │
  └──────────┴──────────────┴──────────────┴────────────────┘
```

### リージョン戦略の違い

リージョン戦略にも設計思想が表れる。AWSは34以上、GCPは40以上、Azureは60以上のリージョンを運用している（2025年時点、定義が異なるため単純比較は難しい）。Azureのリージョン数が突出しているのはエンタープライズ戦略の反映だ。各国の政府機関や金融機関が求めるデータ主権——データが自国内に留まること——に対応するため、小規模な国にもリージョンを展開している。

### ロックインの構造

三社のクラウドを使い始めると、ベンダーロックインが発生する。ロックインには三つのレイヤーがある。(1) **サービスのロックイン**——DynamoDB（AWS）、Cosmos DB（Azure）、Cloud Spanner（GCP）はそれぞれ独自APIを持ち、移行には大幅な書き換えが要る。(2) **データのロックイン**——イングレスは無料だがエグレスは有料。データが蓄積するほど移行障壁が高まる。(3) **スキルのロックイン**——各社のIAM・管理モデルは異なり、チームの習熟が特定クラウドに固定される。

ロックインは必ずしも悪ではない。クラウド固有サービスの活用が開発効率を大幅に向上させるからだ。問題は、ロックインを認識せずにアーキテクチャを設計し、後から移行の困難さに直面することだ。「意図的に受け入れる」のと「知らずに陥る」のでは意味が全く異なる。

### 市場の構造——なぜ寡占が崩れないのか

2025年Q2〜Q3時点で、AWSが約30%、Azureが約20%、GCPが約13%——三社合計で市場の約63%を占める。残りの37%を、Alibaba Cloud、Oracle Cloud、IBM Cloud、その他のプロバイダーが分け合っている。Synergy Research Groupの調査によれば、三社以外で4%以上のシェアを持つ事業者は存在しない。

この寡占構造を支えるのは三つの構造的要因だ。(1) **規模の経済**——データセンター建設、ネットワーク敷設、カスタムハードウェア開発に数十億ドル規模の初期投資が必要であり、追随できる企業が限られる。(2) **エコシステムの自己強化**——サービス数が増えるほど開発者が集まり、開発者が集まるほどツールとドキュメントが充実し、新規顧客がさらに集まる正のフィードバックループ。(3) **スイッチングコスト**——前述のロックイン構造が既存顧客の移行を阻む。

だが寡占は「固定」ではない。AWSのシェアは2021年の約33%から2025年の約30%に漸減した。これは収益の減少ではなく——収益額は増加し続けている——市場全体の急拡大と、とりわけAzureの成長による相対的な変化だ。市場規模は2025年に年間4,000億ドルを超える見込みであり、拡大する市場のシェア争いだ。

---

## 5. ハンズオン——三社のCLIで設計思想の違いを体感する

ここからは、AWS、GCP、AzureのCLI（コマンドラインインターフェース）を実際に触り、各社の設計思想の違いを体感する。CLIの設計は、プラットフォーム全体の設計思想を最も直接的に反映する。今回はアカウント作成やクラウドへの接続は不要——各CLIのヘルプシステムとコマンド構造を確認するだけで、設計思想の違いが見えてくる。

### 環境

- Docker（Ubuntu 24.04ベースコンテナ）
- AWS CLI v2
- Google Cloud SDK（gcloud）
- Azure CLI（az）

### 演習1：三社のCLIをインストールし、コマンド構造を比較する

```bash
# Docker環境で三社のCLIをインストール
docker run -it --rm ubuntu:24.04 bash

# AWS CLI v2
apt-get update && apt-get install -y curl unzip less groff
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o "awscliv2.zip"
unzip -q awscliv2.zip && ./aws/install

# Google Cloud SDK
apt-get install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
  https://packages.cloud.google.com/apt cloud-sdk main" \
  > /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
apt-get update && apt-get install -y google-cloud-cli

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash
```

### 演習2：コマンド構造の比較——仮想マシン操作

三社のCLIで「仮想マシン一覧を取得する」コマンドを比較する。

```bash
# AWS: サービス名 + 操作 の構造
aws ec2 describe-instances --help | head -20
# aws <service> <operation> [options]
# 例: aws ec2 describe-instances
#     aws s3 ls
#     aws lambda list-functions

# GCP: リソース名 + 操作 の構造
gcloud compute instances list --help | head -20
# gcloud <product> <resource> <operation> [options]
# 例: gcloud compute instances list
#     gcloud storage ls
#     gcloud functions list

# Azure: リソース名 + 操作 の構造
az vm list --help | head -20
# az <resource> <operation> [options]
# 例: az vm list
#     az storage blob list
#     az functionapp list
```

この3つのコマンドから、設計思想の違いが見える。

```
CLI構造の比較:

  AWS CLI:
  ── aws <service> <api-action>
  ── aws ec2 describe-instances
  ── aws s3api list-objects-v2 --bucket my-bucket
  ── API名がそのままサブコマンドになっている
  ── 「APIの薄いラッパー」という設計思想
  ── 学習にはAPI仕様の理解が必要

  gcloud:
  ── gcloud <product> <resource> <verb>
  ── gcloud compute instances list
  ── gcloud storage buckets list
  ── リソース中心の階層構造
  ── 「リソースに対する操作」という自然言語的な構造
  ── --format オプションで出力形式を統一的に制御

  az:
  ── az <resource-type> <verb>
  ── az vm list
  ── az storage blob list --container-name mycontainer
  ── 最もフラットな構造
  ── リソースグループによる論理的な管理が前提
  ── --output オプションでtable/json/tsvを切り替え
```

AWS CLIは「APIの薄いラッパー」だ。`describe-instances` というサブコマンド名は、EC2 APIのアクション名そのものだ。APIを直接操作している感覚が強い。開発者が「低レベルの制御」を好む文化と合致している。

gcloudは「リソース中心の階層構造」を持つ。`gcloud compute instances list` は「computeサービスの、instancesリソースを、listする」と自然言語的に読める。Googleの「ユーザーが直感的に操作できるインターフェース」へのこだわりが反映されている。

azは「最もフラットな構造」だ。`az vm list` は端的で覚えやすい。Azure CLI全体が「リソースグループ」という概念を前提としており、全てのリソースがリソースグループに属する。これはAzureの「統合管理」思想の表れだ。

### 演習3：出力フォーマットの比較

```bash
# AWS: --output json|text|table|yaml + JMESPathフィルタリング
# aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId'

# GCP: --format json|yaml|table|csv|value（独自フォーマット指定子）
# gcloud compute instances list --format="json(name,zone,status)"

# Azure: --output json|jsonc|table|tsv|yaml + JMESPathクエリ
# az vm list --query "[].{Name:name, RG:resourceGroup}" --output table
```

AWS CLIはJMESPath（JSONクエリ言語）で出力を加工する。「開発者がAPIレスポンスを自由に加工する」思想だ。gcloudは独自の `--format` 指定子で最も柔軟なカスタマイズが可能。Azure CLIもJMESPathをサポートしつつ、`--output table` のデフォルトがIT管理者に読みやすい設計だ。

### 演習4：設計思想を体感する——リソース管理の違い

```bash
# 三社のリソース管理モデルの違いを確認する

# AWS: リソースはリージョン/サービスに紐づく
# タグによる論理的なグルーピング
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=production" \
  --help 2>/dev/null | head -5
# → タグベースの柔軟な管理。だが強制力はない

# GCP: リソースはプロジェクトに紐づく
# プロジェクト = 課金・権限・リソースの基本単位
gcloud projects list --help 2>/dev/null | head -5
# → プロジェクト単位の明確な境界

# Azure: リソースはリソースグループに紐づく
# リソースグループ = ライフサイクルの単位
az group list --help 2>/dev/null | head -5
# → リソースグループ単位のデプロイと削除
# → 「一緒にデプロイされ、一緒に削除される」という考え方
```

AWSはタグベースの管理が中心だ。任意のキーバリューペアをリソースに付与し、フィルタリングやコスト配賦に使う。柔軟だが、タグの付与は強制されない。運用規律が必要だ。

GCPはプロジェクトが基本単位だ。課金、IAM（権限管理）、APIの有効化——全てがプロジェクト単位で管理される。境界が明確で、チームやアプリケーションごとにプロジェクトを分離しやすい。

Azureはリソースグループが基本単位だ。「一緒にデプロイされ、一緒に削除されるリソースの論理的なグループ」というコンセプトで、ライフサイクル管理が直感的だ。環境（開発/ステージング/本番）やアプリケーションごとにリソースグループを分ける使い方が一般的だ。

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/10-azure-gcp-competition/` に用意してある。

---

## 6. まとめと次回予告

### この回のまとめ

第10回では、AWSの独走に対してMicrosoftとGoogleがそれぞれ異なる設計思想で参入した経緯と、2025年時点の寡占構造を追った。

**AWSの独走は崩れなかった。だが理由は「技術的優位」だけではない。** 2006年の先行者優位、規模の経済、エコシステムの自己強化、スイッチングコスト——これらの構造的要因が、AWSの市場リーダーの地位を固定化している。2025年Q2〜Q3時点で約30%のシェアは、2021年の約33%から漸減しているが、収益額自体は増加を続けている。

**Azureは「エンタープライズ統合プラットフォーム」として独自の地位を確立した。** Windows Azureとして2010年に商用開始、2014年のSatya NadellaのCEO就任を転機に急成長した。Active Directory統合、ハイブリッドクラウド、Microsoft 365との連携——既にMicrosoft製品を導入している企業にとって、Azureは最も摩擦の少ないクラウド移行先だ。

**GCPは「Googleスケールの技術の外部提供」で差別化した。** App Engine（2008年）でPaaS先行参入し、Compute Engine（2013年GA）でIaaSに後発参入。BigQuery、TensorFlow、GKE——Googleが内部で鍛えた技術を武器に、データ分析とML/AIの領域で強い訴求力を持つ。Thomas Kurian（2019年就任）の下でエンタープライズ営業を強化し、市場シェア約13%は三社中最も高い成長率を維持している。

**クラウド市場は寡占だが、画一ではない。** 三社の設計思想——「ビルディングブロック」「エンタープライズ統合」「Googleスケール技術の外部提供」——は本質的に異なる。CLIのコマンド構造から、リージョン戦略、リソース管理モデルまで、設計思想の違いは全てのレイヤーに浸透している。

冒頭の問いに答えよう。「AWSの独走はなぜ崩れなかったのか？」——先行者優位と構造的なロックインが基盤だ。「後発組はどう戦ったのか？」——AWSの模倣ではなく、自社の強み（Microsoft：エンタープライズ、Google：データ/AI）を軸にした差別化戦略で戦った。そして最も重要なのは、クラウドの選定は「技術的な機能比較」だけでは完結しないということだ。組織文化、既存のIT資産、チームのスキルセット——これらが技術以上にクラウド選定を規定する。

### 次回予告

第11回では、「IaaSの本質——『抽象化のレイヤー』として理解する」を探る。

ここまでの10回で、メインフレームから始まり、コロケーション、ホスティング、仮想化、そしてAWS/Azure/GCPの三大クラウドまでを辿ってきた。だが、「IaaS（Infrastructure as a Service）」という言葉を、私たちは本当に理解しているだろうか。IaaSは「リモートのサーバ」ではない。計算、ストレージ、ネットワークを統合的に抽象化し、APIで制御可能にした「プログラマブルインフラ」だ。

NIST（米国国立標準技術研究所）が2011年に定義したクラウドの5つの特性。OpenStack——オープンソースでIaaSを構築しようとした壮大な試み。VPC（Virtual Private Cloud）の仮想ネットワーク設計。そして「Shared Responsibility Model」——クラウドにおける責任の境界線。

あなたが日常的に使っているIaaSの「抽象化」の下に何があるのか——次回はその層を剥がしていく。

---

## 参考文献

- Microsoft, "Microsoft Unveils Windows Azure at Professional Developers Conference", 2008. <https://news.microsoft.com/source/2008/10/27/microsoft-unveils-windows-azure-at-professional-developers-conference/>
- Microsoft, "Windows Azure General Availability", The Official Microsoft Blog, 2010. <https://blogs.microsoft.com/blog/2010/02/01/windows-azure-general-availability/>
- Microsoft Azure Blog, "Upcoming Name Change for Windows Azure", 2014. <https://azure.microsoft.com/en-us/blog/upcoming-name-change-for-windows-azure/>
- Google Cloud Platform Blog, "Introducing Google App Engine + our new blog", 2008. <https://cloudplatform.googleblog.com/2008/04/introducing-google-app-engine-our-new.html>
- Google Cloud Platform Blog, "Google Compute Engine is now Generally Available", 2013. <https://cloudplatform.googleblog.com/2013/12/google-compute-engine-is-now-generally-available.html>
- CNBC, "Google cloud CEO Thomas Kurian: Google will compete more aggressively", 2019. <https://www.cnbc.com/2019/02/12/google-cloud-ceo-thomas-kurian-google-will-compete-more-aggressively.html>
- IBM/PR Newswire, "IBM Closes Acquisition of SoftLayer Technologies", 2013. <https://www.prnewswire.com/news-releases/ibm-closes-acquisition-of-softlayer-technologies-214589711.html>
- Synergy Research Group, "Worldwide Cloud Infrastructure Market Share", 2025. <https://www.statista.com/chart/18819/worldwide-market-share-of-leading-cloud-infrastructure-service-providers/>
- Kinsta, "AWS Market Share: Revenue, Growth & Competition", 2025. <https://kinsta.com/aws-market-share/>
