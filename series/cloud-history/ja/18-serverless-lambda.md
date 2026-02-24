# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第18回：サーバーレス（Lambda）——サーバが「見えない」世界

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- サーバーレスの先駆者Zimki（2006年）が示した「関数単位の課金」モデルと、その早すぎた退場
- AWS Lambda（2014年11月発表）が確立した「イベント駆動・関数単位のデプロイ・自動スケーリング・ゼロへのスケールダウン」というサーバーレスの設計原則
- Firecracker microVM（2018年）——Lambdaを支えるRust製仮想化技術の仕組みと、起動時間125ミリ秒未満の実現
- コールドスタート問題の本質と、Provisioned Concurrency（2019年）による緩和策
- サーバーレスの料金構造と「サーバーレスの逆説」——十分なトラフィックではEC2の方が安くなる構造
- Google Cloud Functions（2016年〜）、Azure Functions（2016年〜）を含むサーバーレスエコシステムの全体像
- Lambdaの進化の軌跡——Node.js単独ローンチからコンテナイメージサポートまで

---

## 1. 「サーバがない」という嘘

2016年のある日、私はAWS Lambdaに初めて関数をデプロイした。

前回取り上げたKubernetesと格闘する日々の中で、同僚がこう言った。「Lambdaなら、クラスタの運用も要らないですよ」。Kubernetesのコントロールプレーンのバージョンアップに3時間を費やした翌日だった。「サーバを管理しなくていい」という言葉は、あの日の私には魅力的すぎた。

最初のLambda関数は、S3バケットに画像がアップロードされたらサムネイルを生成するという、よくある処理だった。

```javascript
// 2016年当時のLambda関数（Node.js）
exports.handler = function(event, context, callback) {
    var bucket = event.Records[0].s3.bucket.name;
    var key = event.Records[0].s3.object.key;
    console.log('Processing: ' + bucket + '/' + key);
    // サムネイル生成処理...
    callback(null, 'Success');
};
```

S3にファイルをアップロードする。数秒後、サムネイルが生成されている。サーバはどこにも見えない。EC2インスタンスを起動する必要もない。Kubernetesのマニフェストを書く必要もない。「コードを書いてデプロイする。あとはAWSがやる」——この体験は、前回述べたKubernetesの「宣言的インフラ」をさらに一歩押し進めたものだった。インフラの宣言すら不要。コードだけを書けばいい。

だが、最初の高揚感はすぐに冷めた。

あるとき、Lambda関数のレスポンスが異常に遅いことに気づいた。通常200ミリ秒で返る処理が、5秒以上かかっている。ログを見ると、`Init Duration: 4800ms` という見慣れない項目がある。コールドスタートだった。Lambda関数は、一定時間呼び出されないと実行環境が破棄される。次の呼び出し時には、実行環境をゼロから構築し直す必要がある。この初期化にかかる時間が、コールドスタートである。

「サーバがない？ いや、どこかで動いているはずだ」

私は思った。サーバーレスはサーバがないのではない。サーバを意識しないだけだ。だがサーバは確実に存在し、その起動には時間がかかる。「サーバーレス」という名称は、技術の実態を正確に表現していない。むしろ「サーバ管理レス」——サーバの管理責任をクラウド事業者に移譲する、というのが正確な表現だ。

この認識に至るまでに、私はコールドスタートと格闘し、実行時間の制限に苦しみ、デバッグの困難さに頭を抱え、予想外の課金に驚くことになる。

あなたはサーバーレスを使っているだろうか。使っているなら、その「見えないサーバ」の正体を知っているだろうか。使っていないなら、なぜ使わないのか——その判断の根拠を言語化できるだろうか。

---

## 2. サーバーレスの先史時代——Lambdaの前に何があったか

### Zimki——早すぎたサーバーレス

サーバーレスの歴史は、AWS Lambdaから始まったわけではない。

2006年——AWS S3やEC2が産声を上げたのと同じ年に、ロンドンのFotango社がZimkiというプラットフォームを公開している。Fotango社はCanon Europeの子会社であり、プロジェクトを率いたのはSimon Wardleyだった。

Zimkiは、開発者がブラウザ上のIDEでJavaScriptコードを書き、それをサーバサイドで実行できるプラットフォームだった。注目すべきは、その課金モデルである。Zimkiは関数の実行回数やリソース消費量に基づくユーティリティコンピューティング（従量課金）モデルを採用していた。サーバのプロビジョニングは不要で、コードを書けばすぐに動く。これは、8年後にAWS Lambdaが実現するモデルと驚くほど酷似している。

だが、Zimkiの運命は悲劇的だった。Canon Europeは「クラウドコンピューティング」の将来性を信じなかった。Wardleyはプラットフォームのオープンソース化を提案したが、これも拒否された。2007年7月、WardleyはOSCON（O'Reilly Open Source Convention）のステージ上で辞任を宣言するという劇的な退場を演じた。そしてZimkiは2007年12月24日——クリスマスイブに、全データが削除されてサービスを終了した。The Registerは「Fotango to smother Zimki on Christmas Eve（FotangoがクリスマスイブにZimkiを窒息死させる）」と報じた。

Zimkiの失敗は、技術的な問題ではなかった。タイミングと、親会社のビジョンの欠如が敗因だった。2006年にはまだ「クラウド」という言葉すら一般的ではなく、「サーバーレス」という概念は影も形もなかった。だが振り返れば、Zimkiが目指していたものは、Lambda、Cloud Functions、Azure Functionsが後に実現した世界そのものだった。

### BaaS——サーバーレスのもう一つの系譜

サーバーレスには、もう一つの系譜がある。BaaS（Backend as a Service）だ。

2011年、James TamplinとAndrew Leeがサンフランシスコで設立したFirebaseは、リアルタイムデータベースサービスとして成長した。開発者はバックエンドのサーバを自前で構築する必要がなく、FirebaseのSDKをフロントエンドに組み込むだけで、データの保存・同期・認証といったバックエンド機能を利用できた。Firebaseは2014年10月にGoogleに買収され、Google Cloud Platformのエコシステムに組み込まれた。

BaaSの思想は明確だ。「バックエンドのコードをできるだけ書かない」。定型的なバックエンド処理——認証、データ保存、プッシュ通知、ファイルストレージ——をマネージドサービスとして提供し、開発者はフロントエンドのロジックに集中する。

FaaS（Function as a Service）としてのAWS Lambdaと、BaaSとしてのFirebase。この二つの系譜が合流したものが、今日「サーバーレスアーキテクチャ」と呼ばれるものの全体像である。FaaSがカスタムロジックの実行基盤を提供し、BaaSが定型的なバックエンド機能を提供する。両者を組み合わせることで、開発者はサーバの管理から完全に解放される——少なくとも、理論的には。

---

## 3. AWS Lambda——2014年11月13日、何が起きたか

### re:Invent 2014のキーノート

2014年11月13日、ラスベガスで開催されたAWS re:Invent 2014のDay 2キーノートで、AWSのCTO Werner VogelsはAWS Lambdaを発表した。

Lambdaの構想は、社内での長い検討の末に生まれたものだった。2024年11月にVogelsが公開した回顧記事「AWS Lambda turns 10: A rare look at the doc that started it」によれば、LambdaはAWSの内部ドキュメントから始まり、「イベントに応じてコードを実行する」というシンプルな原則を追求した結果だった。

発表時のLambdaの仕様は、今から見れば極めて限定的だった。

- 対応言語はNode.jsのみ
- 最大実行時間は60秒
- メモリは最大1,536MB
- 永続的なストレージは持てない（ステートレス）
- 呼び出しごとに新しい実行環境が割り当てられる可能性がある

AWSは「Node.jsのみでローンチするという難しい決断を下した」と後に振り返っている。しかしこの最小限の仕様こそが、Lambdaの設計思想を端的に表現していた。サーバを管理しない。スケーリングを考えない。インフラを意識しない。「コードを書いて、イベントに紐づける」——それだけだ。

翌2015年のre:Invent 2015のキーノートで、VogelsはLambdaのビジョンを一言で表現した。

> **"No server is easier to manage than no server."**
> （管理が最も容易なサーバーとは、存在しないサーバーである）

この言葉は、サーバーレスの思想を象徴するフレーズとして広く引用されることになる。

### Lambdaの急速な進化

Lambdaは、ローンチ後に急速な機能拡張を遂げた。その軌跡を追うと、サーバーレスの適用範囲がどのように拡大してきたかが見える。

```
AWS Lambda 進化のタイムライン:

 2014.11  ローンチ（プレビュー）
  │       Node.jsのみ、最大実行時間60秒
  │
 2015.06  Java 8サポート追加
  │       ← エンタープライズ開発者へのリーチ拡大
 2015.10  Python 2.7サポート追加
  │       最大実行時間を5分に拡大（re:Invent 2015）
  │
 2016.02  VPCサポート追加
  │       ← RDSなどVPC内リソースへのアクセスが可能に
 2016.12  C#（.NET Core）サポート追加
  │
 2018.01  Go言語サポート追加
 2018.10  最大実行時間を15分に拡大
 2018.11  Lambda Layers / Custom Runtime API
  │       Ruby言語サポート追加
  │       Firecracker microVM公開（re:Invent 2018）
  │       ← Custom Runtimeで事実上あらゆる言語に対応
  │
 2019.12  Provisioned Concurrency（re:Invent 2019）
  │       ← コールドスタート問題への回答
  │
 2020.12  コンテナイメージサポート（最大10GB）
          メモリ上限10GB・6 vCPU
          ミリ秒単位課金（従来は100ms単位の切り上げ）
          ← サーバーレスとコンテナの境界が曖昧に
```

この進化には、いくつかの重要な転換点がある。

**2016年2月のVPCサポート**は、Lambdaの適用範囲を大幅に広げた。VPC内のリソース——RDS（リレーショナルデータベース）、ElastiCache（キャッシュ）、Elasticsearch——にLambdaからアクセスできるようになったのだ。だがこの機能は、当初深刻な副作用を伴っていた。VPC内のLambda関数は、ENI（Elastic Network Interface）の作成を伴うため、コールドスタートが10秒以上に悪化する場合があった。この問題はAWSにとっても頭痛の種であり、2019年にネットワーキングアーキテクチャの根本的な改善が行われるまで、完全には解消されなかった。

**2018年11月のCustom Runtime API**は、Lambdaの設計哲学を転換させた。それまでLambdaはAWSが公式にサポートする言語でしか使えなかったが、Custom Runtimeにより、開発者は任意の言語やフレームワークをLambda上で実行できるようになった。Rust、C++、COBOL——理論的には何でも動く。Lambda Layersと組み合わせることで、共通ライブラリの共有も可能になった。

**2020年12月のコンテナイメージサポート**は、サーバーレスとコンテナの境界を決定的に曖昧にした。最大10GBのコンテナイメージをLambdaにデプロイできる。機械学習モデルのような大容量のアーティファクトも、Lambdaで実行できるようになった。前回取り上げたKubernetesのコンテナと、Lambdaの関数——この二つの世界が、技術的には接近しつつある。

### サーバーレスの追随者たち

AWS Lambdaの発表から2年後、主要クラウドベンダーがサーバーレスに参入した。

Google Cloud Functionsは2016年2月にアルファ版として発表された。当初はNode.jsのみの対応で、GAに達したのは2018年7月だった。アルファからGAまで約2年半という長い道のりは、サーバーレスプラットフォームの構築が技術的にいかに困難であるかを物語っている。

Azure Functionsは2016年3月にプレビュー版として登場し、同年11月にGAとなった。Microsoftはプレビュー期間中に900件以上のGitHub issueを処理し、.NETエコシステムとの深い統合を武器にエンタープライズ市場を攻めた。

```
サーバーレスプラットフォームのタイムライン:

  2006  Zimki（Fotango社）← 先駆者、2007年に終了
   │
  2014  AWS Lambda 発表（11月）← FaaSの事実上の創造者
   │
  2016  Google Cloud Functions アルファ（2月）
   │    Azure Functions プレビュー（3月）
   │    Azure Functions GA（11月）
   │
  2017  Google Cloud Functions ベータ（3月）
   │
  2018  Google Cloud Functions GA（7月）
   │    Firecracker microVM 公開（11月）
   │
  2019  Provisioned Concurrency（12月）
   │
  2020  コンテナイメージサポート（12月）
```

オープンソースの世界でも、サーバーレスのエコシステムが急速に形成された。2015年、Austen Collinsは「JAWS（Just AWS Without Servers）」というプロジェクトを立ち上げた。同年のre:Invent 2015で紹介された後、年末には「Serverless Framework」に改名された。Lambda上でのアプリケーション開発を飛躍的に容易にするこのフレームワークは、サーバーレスの普及に大きく貢献した。CollinsはAWS Serverless Heroに選出されている。

---

## 4. サーバーレスの設計原則と技術的な深層

### 四つの設計原則

サーバーレスの設計原則を整理すると、四つに集約できる。

**第一に、イベント駆動（Event-driven）。** Lambda関数は、常時起動しているサーバではない。イベントが発生したときにだけ起動する。S3バケットへのファイルアップロード、API GatewayへのHTTPリクエスト、DynamoDBテーブルの変更、SQSキューへのメッセージ到着、CloudWatchのスケジュール——これらのイベントがトリガーとなり、関数が呼び出される。

```
イベント駆動のアーキテクチャ:

  イベントソース                    Lambda関数        後続処理
  ┌──────────┐                   ┌──────────┐      ┌──────────┐
  │ S3       │── ファイル作成 ──→│ 画像変換 │─────→│ S3       │
  │ バケット │                   │ 関数     │      │（変換後）│
  └──────────┘                   └──────────┘      └──────────┘

  ┌──────────┐                   ┌──────────┐      ┌──────────┐
  │ API      │── HTTPリクエスト →│ API処理  │─────→│ DynamoDB │
  │ Gateway  │                   │ 関数     │      │          │
  └──────────┘                   └──────────┘      └──────────┘

  ┌──────────┐                   ┌──────────┐      ┌──────────┐
  │ SQS      │── メッセージ ───→│ バッチ   │─────→│ RDS      │
  │ キュー   │                   │ 処理関数 │      │          │
  └──────────┘                   └──────────┘      └──────────┘

  ┌──────────┐                   ┌──────────┐
  │CloudWatch│── スケジュール ──→│ 定期処理 │
  │ Events   │   (cron式)       │ 関数     │
  └──────────┘                   └──────────┘
```

この設計は、第2回で取り上げたメインフレームのバッチ処理と構造的に類似している。バッチ処理は「ジョブが投入されたら実行し、終わったらリソースを解放する」。Lambdaは「イベントが発生したら関数を実行し、終わったらリソースを解放する」。60年の時を経て、「必要なときだけ計算資源を使い、終わったら返す」という原則が、テクノロジーを変えて回帰しているのだ。

**第二に、関数単位のデプロイ（Function as a unit of deployment）。** EC2ではサーバ（仮想マシン）がデプロイの単位であり、Kubernetesではコンテナ（Pod）がデプロイの単位である。Lambdaでは、関数がデプロイの単位だ。一つの関数は一つの責務を持ち、一つのイベントに応答する。

**第三に、自動スケーリング。** Lambda関数は、リクエスト数に応じて自動的にスケールする。1リクエスト/秒でも10,000リクエスト/秒でも、開発者はスケーリングの設定を書く必要がない。EC2ではAuto Scaling Groupの設定が必要だ。KubernetesではHorizontal Pod Autoscalerの設定が必要だ。Lambdaではそれすら不要。

**第四に、ゼロへのスケールダウン（Scale to zero）。** これがサーバーレスの最も特徴的な性質だ。リクエストがなければ、実行環境は存在しない。課金もない。EC2インスタンスは停止しても存在し続ける。Kubernetesでは最低1つのPodが稼働し続ける。Lambdaでは、ゼロにスケールダウンする。「使っていないのに課金される」状態が存在しない。

```
スケーリングモデルの比較:

  EC2:
    リクエスト数  ■■■■■
    インスタンス  ■■□□□  ← 手動/Auto Scalingで増減
    課金         ■■□□□  ← 稼働時間課金（停止中も一部課金）

  Kubernetes:
    リクエスト数  ■■■■■
    Pod数        ■■■□□  ← HPA/VPAで増減（最低1 Pod）
    課金         ■■■□□  ← ノードの稼働時間課金

  Lambda:
    リクエスト数  ■■■■■
    実行環境数    ■■■■■  ← 自動（リクエスト数に比例）
    課金         ■■■■■  ← リクエスト数+実行時間課金
                          リクエスト0 → 課金0（Scale to zero）
```

### コールドスタート——サーバーレスの宿痾

サーバーレスの設計原則には、本質的なトレードオフが内在している。その最たるものがコールドスタート問題だ。

Lambda関数が呼び出されると、AWSは以下のプロセスを実行する。

1. **実行環境の確保**: 利用可能な実行環境があるか確認する。なければ新しく作成する
2. **ランタイムの初期化**: Node.js、Python、Javaなどのランタイムを起動する
3. **コードのロード**: デプロイパッケージをダウンロードし、展開する
4. **初期化コードの実行**: ハンドラ関数の外にある初期化コード（データベース接続の確立など）を実行する
5. **ハンドラの実行**: 実際のリクエスト処理を行う

ステップ1〜4がコールドスタートのオーバーヘッドだ。ステップ5だけがリクエスト処理本体である。

```
コールドスタート vs ウォームスタート:

  コールドスタート（実行環境が存在しない場合）:
  ├── 実行環境の作成    ─── 数百ms〜数秒
  ├── ランタイムの初期化 ── 数十ms〜数百ms
  ├── コードのロード    ─── 数十ms〜数百ms
  ├── 初期化コードの実行 ── 数十ms〜数秒（DB接続等）
  └── ハンドラの実行    ─── 実際の処理時間
  合計: 数百ms〜10秒以上（言語・パッケージサイズに依存）

  ウォームスタート（実行環境が再利用される場合）:
  └── ハンドラの実行    ─── 実際の処理時間のみ
  合計: 数ms〜数十ms
```

コールドスタートの影響は、言語とパッケージサイズによって大きく異なる。Node.jsやPythonのような軽量なランタイムでは数百ミリ秒程度で済むが、Javaのような重量級のランタイムでは数秒から10秒以上に達することがあった。VPC内のLambda関数では、ENIの作成にさらに時間がかかり、コールドスタートが10秒を超えることも珍しくなかった（この問題は2019年のネットワーキング改善で大幅に緩和された）。

AWSはこの問題に対して、2019年12月のre:Invent 2019でProvisioned Concurrencyを発表した。事前に指定した数の実行環境を初期化済みの状態で維持する仕組みである。コールドスタートは排除されるが、それは「常時待機する実行環境に対して課金が発生する」ことを意味する。つまり、サーバーレスの最大の利点である「Scale to zero」を放棄することになる。

ここに、サーバーレスの根本的なジレンマがある。ゼロにスケールダウンすればコスト効率は最高だが、コールドスタートが発生する。コールドスタートを排除するには、実行環境を常時維持する——つまり、サーバーレスの最大の利点を手放す必要がある。

### Firecracker——Lambdaを支えるマイクロVM

サーバーレスの「見えないサーバ」は、実際にはどのような技術で動いているのか。

AWS Lambdaは当初、EC2インスタンス上のコンテナで関数を実行していた。だがこのアーキテクチャには、セキュリティと効率性のジレンマがあった。コンテナはカーネルを共有するため、完全な隔離を保証することが難しい。かといって、関数ごとに仮想マシンを起動するのでは、オーバーヘッドが大きすぎる。

AWSがこの問題を解決するために開発したのが、Firecrackerだ。2018年11月のre:Invent 2018で、AWSはFirecrackerをApache 2.0ライセンスでオープンソース化した。

Firecrackerは、Chromium OS（Chrome OS）のcrosvmをフォークして開発されたRust製のVMM（Virtual Machine Monitor）だ。Linux KVM上で動作し、microVM——軽量な仮想マシンを高速に起動する。

Firecrackerの性能は驚異的だ。

- **起動時間**: 125ミリ秒未満
- **メモリオーバーヘッド**: 5MiB未満
- **作成速度**: ホストあたり毎秒150以上のmicroVMを作成可能

```
Firecrackerのアーキテクチャ:

  ┌─────────────────────────────────────────────┐
  │  物理ホスト                                 │
  │                                             │
  │  ┌──────────┐ ┌──────────┐ ┌──────────┐    │
  │  │microVM 1 │ │microVM 2 │ │microVM 3 │    │
  │  │┌────────┐│ │┌────────┐│ │┌────────┐│    │
  │  ││Lambda  ││ ││Lambda  ││ ││Lambda  ││    │
  │  ││関数 A  ││ ││関数 B  ││ ││関数 C  ││    │
  │  │└────────┘│ │└────────┘│ │└────────┘│    │
  │  │ゲストOS  │ │ゲストOS  │ │ゲストOS  │    │
  │  │(最小Linux│ │(最小Linux│ │(最小Linux│    │
  │  │ カーネル)│ │ カーネル)│ │ カーネル)│    │
  │  └────┬─────┘ └────┬─────┘ └────┬─────┘    │
  │       │            │            │           │
  │  ┌────┴────────────┴────────────┴────┐      │
  │  │        Firecracker VMM            │      │
  │  │        (Rust製、最小限のデバイス)  │      │
  │  └───────────────┬───────────────────┘      │
  │                  │                          │
  │  ┌───────────────┴───────────────────┐      │
  │  │            Linux KVM              │      │
  │  └───────────────────────────────────┘      │
  │                                             │
  │  ホストOS（Linux）                          │
  └─────────────────────────────────────────────┘
```

Firecrackerの設計思想は「最小限」だ。従来のVMM（QEMUなど）は、BIOS、PCI、USB、GPUなど膨大なデバイスをエミュレートする。Firecrackerは、ネットワーク、ブロックストレージ、シリアルコンソール、タイマーなど、サーバーレスの実行に最低限必要なデバイスだけを実装する。この「削ぎ落とし」が、125ミリ秒未満の起動時間と5MiB未満のメモリオーバーヘッドを実現している。

なぜRustで書かれたのか。AWSは2017年秋にRustでの開発を決定した。メモリ安全性が保証されるRustは、セキュリティが最優先であるVMMの実装言語として理想的だった。CやC++で発生しがちなメモリ関連の脆弱性を、言語レベルで排除できる。

Firecrackerの登場は、第6回・第7回で取り上げた仮想化技術の系譜における一つの到達点でもある。IBM CP-40（1967年）から始まった仮想化は、VMware ESX（2001年）で商用化され、Xen/KVM（2003年/2007年）でオープンソース化された。Firecrackerは、仮想化技術を「サーバーレスのための軽量な隔離」という新たな用途に最適化したものだ。仮想マシンの起動に数分かかっていた時代から、125ミリ秒未満——これは、50年以上にわたる仮想化技術の進化の一つの到達点である。

### サーバーレスの料金構造——そして逆説

Lambdaの料金モデルは、従来のクラウドサービスとは根本的に異なる。

EC2は「インスタンスの稼働時間」に対して課金される。t3.microであれば1時間あたり約$0.0104（東京リージョン）。使っていなくても、インスタンスが起動していれば課金される。

Lambdaは「リクエスト数」と「コンピュート時間（GB秒）」の二本立てだ。

- **リクエスト課金**: 100万リクエストあたり$0.20
- **コンピュート課金**: GB秒あたり$0.0000166667（x86の場合）
- **無料利用枠**: 月100万リクエスト + 40万GB秒のコンピュート時間

月100万リクエストまでは無料枠に収まる。これは、小規模なAPIやバッチ処理であれば実質無料で運用できることを意味する。2020年12月からはミリ秒単位の課金が導入され、100ミリ秒単位の切り上げによる無駄が解消された。

だが、ここに「サーバーレスの逆説」がある。

散発的なワークロード——1日に数百回程度のAPI呼び出し、あるいはイベント駆動のバッチ処理——には、Lambdaは圧倒的にコスト効率が高い。使っていないときの課金がゼロだからだ。

しかし、トラフィックが安定的に高くなると、状況が逆転する。24時間365日、一定のリクエストを処理し続けるワークロードでは、EC2のReserved Instance（1年または3年の予約で最大72%割引）の方がはるかに安い。リクエストあたりのコンピュート時間を固定して比較すると、ある閾値を超えるとLambdaの総コストがEC2を上回る。

```
コスト構造の比較（概念図）:

  月額コスト
    ↑
    │            Lambda ／
    │              ／  EC2 (Reserved)
    │           ／ ─────────────────
    │        ／
    │     ／    EC2 (On-Demand)
    │  ／  ──────────────────────
    │／
    │
    └───────────────────────────→ リクエスト数/月

    少ないリクエスト → Lambda が圧倒的に安い
    多いリクエスト  → EC2 Reserved が安くなる
    「交差点」がどこにあるかは、関数の実行時間と
    メモリ使用量によって異なる
```

この逆説は、サーバーレスの本質的な設計トレードオフを反映している。サーバーレスは「粒度の細かい課金」を実現した。使った分だけ払う。だが、粒度が細かいということは、一つ一つのリクエストに対するオーバーヘッド（実行環境の管理、イベントのルーティング、課金の計算）が存在するということでもある。このオーバーヘッドは、大量のリクエストを処理する場合には無視できないコストになる。

第21回で詳しく取り上げるFinOpsの文脈では、「このワークロードはサーバーレスに適しているか、それともコンテナやEC2の方が適切か」という判断が、コスト最適化の重要な要素になる。

---

## 5. サーバーレスの光と影——何が解決され、何が残ったか

### 解決されたもの

サーバーレスが解決した問題は明確だ。

**第一に、サーバの運用管理。** OSのパッチ適用、ランタイムのバージョンアップ、セキュリティアップデート——これらの責任がクラウド事業者に移譲される。前回取り上げたKubernetesでは、コンテナの中のアプリケーションは開発者の責任だが、ノードのOSやKubernetesのバージョンは運用チームが管理する必要がある。サーバーレスでは、この責任境界がさらにアプリケーションコード側に寄る。

```
責任分界モデルの比較:

              ユーザーの責任          クラウド事業者の責任
  ─────────────────────────────────────────────────
  IaaS       アプリケーション        物理インフラ
  (EC2)      ミドルウェア            仮想化レイヤー
             OS                     ネットワーク
             セキュリティパッチ      データセンター

  CaaS       アプリケーション        コンテナランタイム
  (EKS)      コンテナイメージ        クラスタ管理
             オーケストレーション    ノードOS
             設定                   物理インフラ

  FaaS       アプリケーション        ランタイム
  (Lambda)   コード                 スケーリング
             関数の設定              セキュリティパッチ
                                    実行環境管理
                                    物理インフラ
```

**第二に、スケーリングの複雑性。** Auto Scaling Groupの設定、最小/最大インスタンス数の決定、スケーリングポリシーの調整——これらが一切不要になる。トラフィックが急増すれば自動的にスケールアウトし、落ち着けば自動的にスケールインする。開発者がスケーリングについて考える必要がない。

**第三に、アイドル時のコスト。** 使っていないときの課金がゼロ。これは、トラフィックが不定期なワークロード——Webhookの受信、定期的なバッチ処理、開発/ステージング環境のAPI——にとって、劇的なコスト削減を意味する。

### 残された課題

だが、サーバーレスは万能薬ではない。解決された問題と引き換えに、新たな課題が生まれている。

**第一に、コールドスタート。** 既に詳述したとおり、ゼロからの起動には時間がかかる。リアルタイム性が求められるAPIや、レイテンシーに敏感なユーザー向けサービスでは、コールドスタートは致命的になりうる。Provisioned Concurrencyで緩和できるが、それはコスト増を伴う。

**第二に、実行時間の制限。** Lambdaの最大実行時間は15分。これは、長時間のデータ処理やバッチジョブには不十分だ。当初は60秒だった制限が5分、15分と拡大されてきたが、依然として制約は存在する。Step Functionsを使って処理を分割する手法はあるが、アーキテクチャの複雑性が増す。

**第三に、デバッグと可観測性の困難さ。** EC2やKubernetesであれば、サーバにSSHでログインし、プロセスの状態を直接確認できる。Lambdaでは、それができない。実行環境は一時的であり、関数の実行が終わればログとメトリクスだけが残る。CloudWatch LogsとX-Rayで追跡は可能だが、従来のデバッグ手法とは根本的に異なるアプローチが求められる。

**第四に、ベンダーロックイン。** Lambda関数はAWSのイベントソース（S3、DynamoDB、SQS、API Gateway）と密結合する設計になっている。同じ関数をGoogle Cloud FunctionsやAzure Functionsに移植するには、イベントソースの抽象化、デプロイメントの書き換え、設定の変更が必要だ。コードそのものは移植可能でも、アーキテクチャ全体はAWSのエコシステムに深く依存する。

**第五に、テストの困難さ。** ローカル環境でLambda関数を完全に再現することは難しい。SAM（Serverless Application Model）LocalやLocalStackなどのツールはあるが、本番環境との差異は避けられない。特にイベントソースとの統合テストは、実際のAWS環境でしか検証できない部分が大きい。

### 「サーバーレスファースト」は正解か

2020年前後、「サーバーレスファースト」——新しいプロジェクトはまずサーバーレスで検討し、サーバーレスで対応できない場合にのみコンテナやEC2を使う——というアプローチが提唱された。

この考え方には一理ある。小規模なプロジェクトの立ち上げ期には、運用コストゼロ・スケーリング自動・課金最小というサーバーレスの利点は圧倒的だ。だが、プロジェクトが成長し、トラフィックが安定的に増加すると、サーバーレスの制約が足かせになることがある。

私は「サーバーレスファースト」を全面的には支持しない。正確に言えば、「ワークロードの特性を見極めてから、最適な実行モデルを選ぶ」ことを推奨する。

- **イベント駆動のバッチ処理**: サーバーレスが最適
- **不定期なAPIエンドポイント**: サーバーレスが最適
- **安定した高トラフィックのAPI**: コンテナ（ECS/EKS）やEC2が最適
- **長時間のデータ処理**: EC2やECS/EKS上のバッチジョブが最適
- **レイテンシーに極めて敏感な処理**: コールドスタートのリスクを考慮し、Provisioned Concurrencyつきのサーバーレスか、コンテナを検討

技術選定は二者択一ではない。一つのシステムの中で、サーバーレスとコンテナとEC2を組み合わせることは珍しくない。重要なのは、各実行モデルのトレードオフを理解した上で、ワークロードの特性に応じた選択をすることだ。

---

## 6. ハンズオン——サーバーレスの動作を体験する

ここでは、LocalStackを使ってローカル環境でAWS Lambdaの動作を再現し、サーバーレスの設計原則を体験する。AWS アカウントがなくても実行可能だ。

### 演習1：Lambda関数の作成と呼び出し

```bash
# === LocalStackによるサーバーレス環境の構築 ===

# Docker環境が必須
# LocalStackはAWSサービスをローカルでエミュレートする

# 作業ディレクトリの作成
WORKDIR="${HOME}/cloud-history-handson-18"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=========================================="
echo "演習1: Lambda関数の作成と呼び出し"
echo "=========================================="

# docker-compose.ymlの作成
cat > docker-compose.yml << 'COMPOSE_EOF'
version: '3.8'
services:
  localstack:
    image: localstack/localstack:3.8
    ports:
      - "4566:4566"
    environment:
      - SERVICES=lambda,s3,sqs,logs,iam
      - LAMBDA_EXECUTOR=docker
      - DOCKER_HOST=unix:///var/run/docker.sock
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - "./volume:/var/lib/localstack"
COMPOSE_EOF

# LocalStackの起動
docker compose up -d
echo "LocalStackの起動を待機中..."
sleep 15

# AWS CLIのエンドポイント設定（LocalStack用）
export AWS_DEFAULT_REGION=ap-northeast-1
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_ENDPOINT_URL=http://localhost:4566

# Lambda関数のコード作成
mkdir -p functions

cat > functions/hello.py << 'PYTHON_EOF'
import json
import datetime

def handler(event, context):
    """
    最もシンプルなLambda関数。
    eventにはトリガーからのデータが渡される。
    contextにはLambdaの実行環境情報が含まれる。
    """
    print(f"Event received: {json.dumps(event)}")
    print(f"Function name: {context.function_name}")
    print(f"Remaining time (ms): {context.get_remaining_time_in_millis()}")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from Lambda!',
            'timestamp': datetime.datetime.now().isoformat(),
            'event': event
        })
    }
PYTHON_EOF

# ZIPパッケージの作成
cd functions
zip hello.zip hello.py
cd ..

# IAMロールの作成（LocalStackでは簡略化）
aws iam create-role \
  --role-name lambda-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }' 2>/dev/null

# Lambda関数の作成
aws lambda create-function \
  --function-name hello-function \
  --runtime python3.12 \
  --handler hello.handler \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --zip-file fileb://functions/hello.zip \
  --timeout 30 \
  --memory-size 128

echo ""
echo "=== Lambda関数の呼び出し ==="
aws lambda invoke \
  --function-name hello-function \
  --payload '{"name": "serverless", "action": "test"}' \
  --cli-binary-format raw-in-base64-out \
  output.json

echo "レスポンス:"
cat output.json | python3 -m json.tool

echo ""
echo "考察:"
echo "- Lambda関数はイベント（payload）を受け取り、処理結果を返す"
echo "- サーバの起動・停止は意識しない"
echo "- 関数の実行時間とメモリ使用量が課金対象となる"
```

### 演習2：イベント駆動アーキテクチャの体験

```bash
echo "=========================================="
echo "演習2: S3イベント → Lambda（イベント駆動）"
echo "=========================================="

# S3トリガーで起動するLambda関数
cat > functions/s3_handler.py << 'PYTHON_EOF'
import json

def handler(event, context):
    """
    S3にファイルがアップロードされたときに呼び出される関数。
    eventにはS3イベントの詳細が含まれる。
    """
    for record in event.get('Records', []):
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        size = record['s3']['object'].get('size', 0)

        print(f"New file detected!")
        print(f"  Bucket: {bucket}")
        print(f"  Key:    {key}")
        print(f"  Size:   {size} bytes")

        # 実際のアプリケーションでは、ここで:
        # - 画像のリサイズ
        # - メタデータの抽出
        # - データベースへの登録
        # - 別のS3バケットへのコピー
        # などを行う

    return {
        'statusCode': 200,
        'body': json.dumps({
            'processed': len(event.get('Records', []))
        })
    }
PYTHON_EOF

cd functions
zip s3_handler.zip s3_handler.py
cd ..

# S3トリガー用Lambda関数の作成
aws lambda create-function \
  --function-name s3-handler \
  --runtime python3.12 \
  --handler s3_handler.handler \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --zip-file fileb://functions/s3_handler.zip \
  --timeout 60 \
  --memory-size 256

# S3バケットの作成
aws s3 mb s3://my-upload-bucket

# S3イベント通知の設定
aws s3api put-bucket-notification-configuration \
  --bucket my-upload-bucket \
  --notification-configuration '{
    "LambdaFunctionConfigurations": [{
      "LambdaFunctionArn": "arn:aws:lambda:ap-northeast-1:000000000000:function:s3-handler",
      "Events": ["s3:ObjectCreated:*"]
    }]
  }'

echo ""
echo "=== S3にファイルをアップロード ==="
echo "Hello, Serverless!" > /tmp/test-upload.txt
aws s3 cp /tmp/test-upload.txt s3://my-upload-bucket/test.txt
sleep 3

echo ""
echo "=== Lambda関数のログを確認 ==="
aws logs describe-log-groups 2>/dev/null | python3 -m json.tool

echo ""
echo "考察:"
echo "- S3へのファイルアップロードが「イベント」となり"
echo "  Lambda関数が自動的に呼び出される"
echo "- 開発者はイベントの処理ロジックだけを書けばよい"
echo "- サーバの待ち受け、ポーリング、キューイングは不要"
echo "- これがイベント駆動アーキテクチャの本質"
```

### 演習3：SQSキュー + Lambda（非同期処理パターン）

```bash
echo "=========================================="
echo "演習3: SQS → Lambda（非同期処理パターン）"
echo "=========================================="

# SQSから受信するLambda関数
cat > functions/sqs_handler.py << 'PYTHON_EOF'
import json
import time

def handler(event, context):
    """
    SQSキューのメッセージを処理するLambda関数。
    バッチでメッセージを受け取り、1件ずつ処理する。
    """
    processed = 0
    for record in event.get('Records', []):
        body = json.loads(record['body'])
        message_id = record['messageId']

        print(f"Processing message {message_id}")
        print(f"  Body: {json.dumps(body)}")

        # 重い処理のシミュレーション（実際のアプリでは
        # データ変換、外部API呼び出し、DB書き込み等）
        time.sleep(0.1)

        processed += 1

    print(f"Total processed: {processed} messages")
    return {'statusCode': 200, 'processed': processed}
PYTHON_EOF

cd functions
zip sqs_handler.zip sqs_handler.py
cd ..

# SQSキューの作成
aws sqs create-queue --queue-name task-queue

# SQS処理用Lambda関数の作成
aws lambda create-function \
  --function-name sqs-handler \
  --runtime python3.12 \
  --handler sqs_handler.handler \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --zip-file fileb://functions/sqs_handler.zip \
  --timeout 60 \
  --memory-size 128

# イベントソースマッピング（SQS → Lambda）
QUEUE_ARN=$(aws sqs get-queue-attributes \
  --queue-url http://sqs.ap-northeast-1.localhost.localstack.cloud:4566/000000000000/task-queue \
  --attribute-names QueueArn \
  --query 'Attributes.QueueArn' --output text 2>/dev/null || echo "arn:aws:sqs:ap-northeast-1:000000000000:task-queue")

aws lambda create-event-source-mapping \
  --function-name sqs-handler \
  --event-source-arn "${QUEUE_ARN}" \
  --batch-size 5

echo ""
echo "=== SQSにメッセージを送信 ==="
QUEUE_URL=$(aws sqs get-queue-url --queue-name task-queue --query 'QueueUrl' --output text)

for i in $(seq 1 10); do
  aws sqs send-message \
    --queue-url "${QUEUE_URL}" \
    --message-body "{\"task_id\": ${i}, \"type\": \"process_data\"}"
done
echo "10件のメッセージを送信しました"

sleep 5
echo ""
echo "考察:"
echo "- SQSキューにメッセージが到着すると、自動的にLambda関数が起動"
echo "- batch-size=5 の設定により、最大5件のメッセージをまとめて処理"
echo "- メッセージが増えれば、Lambda関数の並行実行数が自動的に増加"
echo "- メッセージがなくなれば、Lambda関数は実行されない（Scale to zero）"
echo "- これがサーバーレスの自動スケーリングの本質"
```

### 演習4：コールドスタートの観察

```bash
echo "=========================================="
echo "演習4: コールドスタートの観察"
echo "=========================================="

# コールドスタートを計測するLambda関数
cat > functions/coldstart.py << 'PYTHON_EOF'
import json
import time
import os

# --- 初期化コード（コールドスタート時のみ実行） ---
INIT_TIME = time.time()
print(f"[INIT] Function initialized at {INIT_TIME}")
print(f"[INIT] Python version: {os.sys.version}")
print(f"[INIT] Memory limit: {os.environ.get('AWS_LAMBDA_FUNCTION_MEMORY_SIZE', 'unknown')} MB")

# 重い初期化のシミュレーション（例: DB接続プールの作成）
time.sleep(0.5)
INIT_COMPLETE = time.time()
print(f"[INIT] Initialization took {(INIT_COMPLETE - INIT_TIME)*1000:.1f} ms")
# --- 初期化コードここまで ---

invocation_count = 0

def handler(event, context):
    """
    コールドスタートとウォームスタートの違いを観察する関数。
    invocation_countが1ならコールドスタート後の最初の呼び出し。
    2以上ならウォームスタート（実行環境の再利用）。
    """
    global invocation_count
    invocation_count += 1

    start = time.time()
    result = {
        'invocation_count': invocation_count,
        'is_cold_start': invocation_count == 1,
        'init_time_ms': (INIT_COMPLETE - INIT_TIME) * 1000,
        'handler_start_epoch': start,
        'remaining_time_ms': context.get_remaining_time_in_millis(),
    }

    print(f"[HANDLER] Invocation #{invocation_count}")
    print(f"[HANDLER] Cold start: {result['is_cold_start']}")

    return {
        'statusCode': 200,
        'body': json.dumps(result, indent=2)
    }
PYTHON_EOF

cd functions
zip coldstart.zip coldstart.py
cd ..

aws lambda create-function \
  --function-name coldstart-demo \
  --runtime python3.12 \
  --handler coldstart.handler \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --zip-file fileb://functions/coldstart.zip \
  --timeout 30 \
  --memory-size 128

echo ""
echo "=== 1回目の呼び出し（コールドスタート） ==="
aws lambda invoke \
  --function-name coldstart-demo \
  --payload '{}' \
  --cli-binary-format raw-in-base64-out \
  /tmp/cold1.json
cat /tmp/cold1.json | python3 -m json.tool

echo ""
echo "=== 2回目の呼び出し（ウォームスタート） ==="
aws lambda invoke \
  --function-name coldstart-demo \
  --payload '{}' \
  --cli-binary-format raw-in-base64-out \
  /tmp/cold2.json
cat /tmp/cold2.json | python3 -m json.tool

echo ""
echo "=== 3回目の呼び出し（ウォームスタート） ==="
aws lambda invoke \
  --function-name coldstart-demo \
  --payload '{}' \
  --cli-binary-format raw-in-base64-out \
  /tmp/cold3.json
cat /tmp/cold3.json | python3 -m json.tool

echo ""
echo "考察:"
echo "- 1回目: invocation_count=1, is_cold_start=true"
echo "  → 初期化コード（DB接続シミュレーション）が実行される"
echo "- 2回目以降: invocation_count>1, is_cold_start=false"
echo "  → 実行環境が再利用され、初期化コードはスキップされる"
echo "  → invocation_countが増え続けることが再利用の証拠"
echo ""
echo "=== クリーンアップ ==="
echo "docker compose down で LocalStack を停止できます"
echo "rm -rf ${WORKDIR} で作業ディレクトリを削除できます"
```

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/18-serverless-lambda/` に用意してある。

---

## 7. まとめと次回予告

### この回のまとめ

第18回では、サーバーレスの歴史と設計思想を読み解き、AWS Lambdaが確立した「サーバを管理しない」世界のトレードオフを検証した。

**サーバーレスの先史は、AWS Lambdaより8年も前に始まっていた。** 2006年にFotango社のZimkiが実現した「ブラウザ上でコードを書き、関数単位で課金される」モデルは、Lambdaの思想そのものだった。だがCanon Europeはクラウドの将来性を信じず、Zimkiは2007年のクリスマスイブに全データ削除のうえ終了した。技術的な失敗ではなく、ビジョンの欠如が敗因だった。

**2014年11月13日、Werner Vogelsはre:Invent 2014のキーノートでAWS Lambdaを発表した。** 対応言語はNode.jsのみ、最大実行時間60秒という最小限の仕様だった。だがこの発表は、「イベント駆動・関数単位のデプロイ・自動スケーリング・ゼロへのスケールダウン」というサーバーレスの四つの設計原則を確立した。翌年のre:Inventで、Vogelsは「No server is easier to manage than no server（管理が最も容易なサーバーとは、存在しないサーバーである）」と述べ、サーバーレスの思想を端的に表現した。

**Firecrackerは、サーバーレスを支える仮想化技術の到達点である。** 2018年にAWSがオープンソース化したこのRust製VMMは、125ミリ秒未満の起動時間と5MiB未満のメモリオーバーヘッドを実現した。第6回・第7回で追った仮想化技術の系譜——IBM CP-40（1967年）からVMware ESX（2001年）、Xen/KVM（2003年/2007年）を経て——は、「サーバーレスのための軽量な隔離」という新たな地平に到達した。

**コールドスタートは、サーバーレスの設計上の宿痾である。** ゼロにスケールダウンすればコスト効率は最高だが、再起動時にはコールドスタートが発生する。2019年のProvisioned Concurrencyはこの問題を緩和するが、「常時待機の実行環境に課金が発生する」——つまりサーバーレス最大の利点を一部放棄するというトレードオフを伴う。この二律背反は、サーバーレスの本質的な設計判断そのものだ。

**サーバーレスの料金構造には「逆説」がある。** 散発的なワークロードには圧倒的にコスト効率が高い。だが安定的な高トラフィックでは、EC2のReserved Instanceの方が安くなる。サーバーレスは「すべてのワークロードに最適」なのではない。ワークロードの特性——トラフィックのパターン、レイテンシー要件、実行時間——に応じた技術選定が求められる。

冒頭の問いに答えよう。「サーバを管理しない」とは何を意味するのか。サーバは消えたのか。答えは否だ。サーバは消えていない。OSのパッチ適用、セキュリティアップデート、スケーリング、可用性の確保——これらの責任がクラウド事業者に移譲されただけだ。そしてこの移譲には代償がある。コールドスタート、実行時間の制限、デバッグの困難さ、ベンダーロックイン、コスト構造の逆転。サーバーレスを選ぶのであれば、これらのトレードオフを理解した上で選ぶべきだ。「サーバがない」という幻想に惑わされてはならない。

### 次回予告

第19回では、「マイクロサービスとクラウド——分散システムの光と影」を取り上げる。

Kubernetesがコンテナのオーケストレーションを自動化し、Lambdaがサーバの管理を不要にした。だが、アプリケーションの設計そのものが変わらなければ、クラウドの恩恵を十分に引き出すことはできない。モノリスからマイクロサービスへ——この転換は何を解決し、何を複雑にしたのか。「マイクロサービスは組織の問題を解決する。技術の問題は増やす」——この苦い教訓を、分散システムの光と影として語る。

---

## 参考文献

- Amazon Web Services, "Amazon Web Services Announces AWS Lambda", November 2014. <https://press.aboutamazon.com/2014/11/amazon-web-services-announces-aws-lambda>
- Werner Vogels, "AWS Lambda turns 10: A rare look at the doc that started it", All Things Distributed, November 2024. <https://www.allthingsdistributed.com/2024/11/aws-lambda-turns-10-a-rare-look-at-the-doc-that-started-it.html>
- JAXenter, "Day 2 at the AWS re:Invent - what we learned", 2015. <https://jaxenter.com/day-2-at-the-aws-reinvent-what-we-learned-121375.html>
- The Register, "Fotango to smother Zimki on Christmas Eve", September 25, 2007. <https://www.theregister.com/2007/09/25/zimki_fotango_shut/>
- Simon Wardley, "VMForce, Zimki and the cloud", May 2010. <https://blog.gardeviance.org/2010/05/vmforce-zimki-and-cloud.html>
- TechCrunch, "Google Acquires Firebase To Help Developers Build Better Real-Time Apps", October 21, 2014. <https://techcrunch.com/2014/10/21/google-acquires-firebase-to-help-developers-build-better-realtime-apps/>
- TechCrunch, "Google's Cloud Functions serverless platform is now generally available", July 24, 2018. <https://techcrunch.com/2018/07/24/googles-cloud-functions-serverless-platform-is-now-generally-available/>
- Microsoft Azure Blog, "Announcing general availability of Azure Functions", November 2016. <https://azure.microsoft.com/en-us/blog/announcing-general-availability-of-azure-functions/>
- AWS Open Source Blog, "Announcing the Firecracker Open Source Technology: Secure and Fast microVM for Serverless Computing", 2018. <https://aws.amazon.com/blogs/opensource/firecracker-open-source-secure-fast-microvm-serverless/>
- Amazon Science, "How AWS's Firecracker virtual machines work". <https://www.amazon.science/blog/how-awss-firecracker-virtual-machines-work>
- AWS News Blog, "New - Provisioned Concurrency for Lambda Functions", December 2019. <https://aws.amazon.com/blogs/aws/new-provisioned-concurrency-for-lambda-functions/>
- AWS, "AWS Lambda Pricing". <https://aws.amazon.com/lambda/pricing/>
- AWS, "Amazon Lambda enables functions that can run up to 15 minutes", October 2018. <https://www.amazonaws.cn/en/new/2018/aws-lambda-enables-functions-that-can-run-up-to-15-minutes/>
- AWS, "AWS Lambda now supports up to 10 GB of memory and 6 vCPU cores for Lambda Functions", December 2020. <https://aws.amazon.com/about-aws/whats-new/2020/12/aws-lambda-supports-10gb-memory-6-vcpu-cores-lambda-functions/>
- Serverless Chats Podcast, "Episode #66: The Story of the Serverless Framework with Austen Collins". <https://www.serverlesschats.com/66/>
