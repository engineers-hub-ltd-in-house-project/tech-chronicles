# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第14回：Google App Engine——Googleスケールの約束と制約

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- PaaSにおける「制約による設計」の思想と、それがスケーラビリティにもたらす本質的な意味
- Google App Engine発表（2008年4月7日、Campfire Oneイベント）の経緯と初期仕様
- GAEのサンドボックス制約——ファイルシステム書き込み禁止、60秒リクエストタイムアウト、ライブラリ制限
- Datastore（Bigtableベース）の設計思想——なぜRDBMSを捨てたのか
- Python専用からJava（2009年）、Go（2011年）、PHP（2013年）への段階的なランタイム拡張
- オートスケーリングと「ゼロへのスケールダウン」——サーバーレスの先駆け
- 第二世代ランタイム（2018年、gVisor）による制約の緩和
- Flexible Environment（2017年GA）からCloud Run（2019年GA）への系譜
- AWS Elastic Beanstalk（2011年）との設計思想の対比
- GAEの制約を再現するハンズオン

---

## 1. 「Googleのインフラで動かせる」という誘惑

2009年の冬、私はある案件で頭を抱えていた。

Ruby on Railsで構築したWebアプリケーションが、予想を超えるトラフィックに晒されていた。EC2のインスタンスを増やし、ロードバランサの設定を調整し、データベースのレプリカを追加し——すべて手動だった。トラフィックのピークは予測不能で、深夜2時にアラートが鳴ってSSHでサーバにログインし、`top` コマンドでCPU使用率を睨みながらインスタンスを追加する。そんな夜が何度も続いた。

同僚のエンジニアが言った。「Google App Engineを試してみたらどうだ。オートスケーリングが全自動で、インスタンスの管理をGoogleがやってくれる」

Google App Engine——略してGAE。「Googleのインフラの上でアプリケーションを動かせる」という謳い文句は魅力的だった。GoogleはGmail、YouTube、Google検索という世界最大級のWebサービスを運用している。そのインフラ技術を使えるなら、スケーラビリティの問題は解決するのではないか。

だが、GAEを調べ始めて、私はすぐに壁にぶつかった。

まず、Pythonしかサポートしていなかった（Javaサポートは2009年4月に追加されたばかりだった）。私のアプリケーションはRailsだ。次に、ファイルシステムに書き込めない。ユーザがアップロードした画像をローカルディスクに保存する処理が至る所にあった。さらに、RDBMSが使えない。GAEのデータストアはBigtableベースのNoSQLで、SQLのJOIN操作ができない。リクエストには60秒のタイムアウトがある。使えるライブラリに制限がある。

「これは、アプリケーションの設計を根本から変えろということか」

その通りだった。GAEは「Googleのインフラで動かせる」という約束の裏に、「Googleの設計思想に従え」という暗黙の契約を携えていた。Herokuが「開発者体験の向上」を旗印にPaaSを普及させた一方で、Googleはまったく別のアプローチを取った。スケーラビリティのために、開発者の自由を制限する。制約を受け入れた者にだけ、Googleスケールの恩恵を与える。

結局、その案件ではGAEへの移行を断念した。だが数年後、私はGAEの設計思想が正しかったことを理解する。ファイルシステムに書き込まない、ステートレスにする、リクエストを短く保つ——これらの制約は、すべてスケーラブルなアプリケーション設計の原則そのものだった。GAEは「便利なデプロイ環境」ではなく、「分散システムの設計原則を実装に埋め込む教育装置」だったのだ。

あなたは、制約を「不便」としか見なかったことはないだろうか。その制約の裏にある設計思想を読み解こうとしたことはあるだろうか。

---

## 2. Google App Engineの誕生と進化

### 2008年4月7日——Campfire Oneの夜

2008年4月7日、Googleは「Campfire One」と名付けた開発者イベントで、Google App Engineのプレビュー版を発表した。これはGoogleにとって初のクラウドコンピューティングサービスであり、AWS EC2の正式公開（2006年8月）から約1年半後のことだった。

発表の骨子はシンプルだった。開発者がPythonでWebアプリケーションを書き、Googleのインフラにデプロイできる。スケーリングはGoogleが自動で行う。開発者はサーバの管理を一切する必要がない。

プレビュー版は最初の10,000人の開発者に限定され、無料枠として500MBのストレージ、200百万CPUサイクル/日、10GBの帯域幅が提供された。これは月間約500万ページビュー相当——小規模なWebアプリケーションなら無料で運用できる、当時としては破格の条件だった。

だが、この「破格の条件」には代償があった。

### Pythonのみ——そして厳格なサンドボックス

プレビュー版のGAEがサポートしていたのはPython 2.5のみだった。2008年当時、Webアプリケーション開発の主流言語はJava、PHP、Rubyであり、Pythonは成長中とはいえ主流ではなかった。DjangoやTurboGearsといったPythonのWebフレームワークは存在したが、Ruby on RailsやJava EEほどの採用実績はなかった。

そして、たとえPythonを使っていたとしても、GAEのサンドボックスは通常のPython実行環境とは異なる制約を課した。

**ファイルシステムへの書き込み禁止。** アプリケーションはローカルディスクにファイルを書き込めない。ユーザのアップロードファイル、一時ファイル、キャッシュファイル——すべて、ファイルシステム以外の手段で管理する必要があった。永続化が必要ならDatastore（後述）に、ファイルの保存が必要ならBlobstore（のちにGoogle Cloud Storage）に格納することが求められた。

**60秒のリクエストタイムアウト。** Webリクエストの処理時間は60秒に制限されていた。タイムアウトが近づくと例外が発生し、アプリケーションはそれをキャッチして適切に終了処理を行うことが期待された。重い計算処理や長時間の外部API呼び出しを、単一のリクエスト内で完結させることはできない。

**ライブラリの制限。** C拡張を含むPythonライブラリは使用できなかった。たとえば画像処理ライブラリのPIL（Python Imaging Library）はネイティブコードを含むため直接使えず、代わりにGAEが提供するImages APIを使う必要があった。ネットワークソケットの直接操作も禁止されており、外部HTTPリクエストにはURL Fetch APIを使うことが求められた。

これらの制約は、当時の開発者にとって「異常」とも言える厳しさだった。なぜGoogleはここまで制約を課したのか。

答えは、Googleの内部インフラの設計思想にある。Googleは2003年にGFS（Google File System）のペーパーを、2004年にMapReduceのペーパーを、2006年にBigtableのペーパーを公開している。これらの技術に共通するのは、「個々のノードは信頼できない」「障害は日常的に起きる」「水平スケーリングが前提」という分散システムの原則だ。GAEのサンドボックス制約は、この原則をアプリケーション設計に組み込むための仕組みだった。

ファイルシステムへの書き込み禁止は、アプリケーションをステートレスに保つための制約だ。ステートレスなアプリケーションは、任意のインスタンスにリクエストをルーティングでき、インスタンスの追加・削除が容易になる。60秒のタイムアウトは、長時間占有されるリソースを防ぎ、多数のリクエストを効率的に処理するための制約だ。ライブラリの制限は、サンドボックスの隔離を維持し、マルチテナント環境での安全性を担保するための制約である。

### 段階的なランタイム拡張

GAEの初期制約の中で最も大きな障壁は、Python専用という点だった。Googleはこれを段階的に解消していった。

2009年4月7日——GAE発表のちょうど1年後——GoogleはJava対応を発表した。最初の10,000人の開発者限定のアーリーアクセスとして提供され、Java 6 JVM、Java Servletsインターフェース、Google Web Toolkit（GWT）との統合が含まれていた。Java対応により、GAEのターゲットは一気に拡大した。エンタープライズ開発の主力言語であるJavaが使えるようになったことで、個人開発者だけでなく企業のプロジェクトでもGAEが選択肢に入るようになった。

2011年5月、Google I/Oで Go言語の実験的サポートが発表された。GoはGoogle自身が開発したプログラミング言語であり、GAEとの親和性は高かった。Goの高速なコンパイル、軽量な並行処理（goroutine）、静的バイナリ生成は、GAEのサンドボックス環境に適していた。

2013年5月にはPHPのLimited Previewが開始された。PHPはWebアプリケーション開発で最も広く使われている言語の一つであり、WordPress等のCMSの基盤でもある。だが、GAEのサンドボックス制約——特にファイルシステムへの書き込み禁止——は、PHPエコシステムの多くのライブラリやフレームワークと相性が悪かった。PHPアプリケーションの多くは、テンプレートキャッシュやセッションファイルをローカルディスクに書き込むことを前提としていたからだ。

```
GAEのランタイム拡張タイムライン:

  2008年4月   Python 2.5（プレビュー版、Campfire One）
  |           サンドボックス制約: ファイル書き込み禁止,
  |           60秒タイムアウト, ライブラリ制限
  |
  2009年4月   Java 6対応（10,000人限定アーリーアクセス）
  |           Java Servlets, GWT統合
  |
  2011年5月   Go実験的サポート（Google I/O発表）
  |           Googleが開発した言語との親和性
  |
  2011年9月   GA（一般提供）開始
  |           無料枠から有料プランへの移行
  |
  2013年5月   PHP対応（Limited Preview）
  |
  2017年3月   Flexible Environment GA
  |           Docker対応、制約の大幅緩和
  |
  2018年      第二世代ランタイム（gVisorベース）
  |           Python 3.7, Node.js等の未修正ランタイム
  |
  2019年11月  Cloud Run GA
              GAEの精神的後継、コンテナベース
```

### 2011年の転換点——GA化と料金改定

2011年9月、GAEは正式にGA（一般提供）を開始した。同時に行われた料金体系の改定は、コミュニティに大きな波紋を呼んだ。プレビュー期間の寛大な無料枠が大幅に縮小され、それまで無料で運用できていたアプリケーションに課金が発生するようになった。Slashdotをはじめとする技術コミュニティで批判が噴出し、一部の開発者はGAEからの移行を検討し始めた。

この経験は、クラウドサービスの料金設計に関する重要な教訓を含んでいる。寛大な無料枠はユーザ獲得に有効だが、その無料枠に依存したユーザが増えるほど、料金改定時のインパクトは大きくなる。前回取り上げたHerokuが2022年に無料プランを廃止した際にも、まったく同じ構図が再現された。

---

## 3. 「制約による設計」の技術論

### DatastoreはなぜRDBMSではないのか

GAEの制約の中で、開発者に最も大きな設計転換を求めたのがDatastoreだ。

GAEのDatastoreはGoogle Bigtable上に構築されたNoSQLデータストアである。Bigtableは2006年にGoogleが論文「Bigtable: A Distributed Storage System for Structured Data」（Fay Chang et al., OSDI 2006）で発表した分散ストレージシステムで、Google検索のインデックス、Gmail、Google Mapsなどの基盤となっている。

DatastoreがRDBMSではなくBigtableを基盤とした理由は明確だ。RDBMSはJOIN操作やトランザクションの一貫性を保証するために、データが同一ノード上に存在することを前提とする。この前提は、データが数台のサーバに収まるうちは問題ないが、数千台、数万台のサーバに分散するGoogleスケールでは維持できない。

Bigtableの設計は、この前提を放棄する代わりに、水平スケーラビリティを獲得した。データは行キーの辞書順でソートされ、タブレットと呼ばれる単位でシャーディングされる。各タブレットは独立したサーバに配置できるため、データ量の増加に対してサーバを追加するだけで対応できる。

```
RDBMSとDatastoreの設計思想の対比:

  RDBMS（MySQL, PostgreSQL等）
  ┌─────────────────────────────────────────────┐
  | 設計原則: データの正規化と整合性             |
  |                                              |
  | ・正規化（第1〜第3正規形）                   |
  | ・JOIN操作で関連テーブルを結合               |
  | ・ACID トランザクション                      |
  | ・外部キー制約によるデータ整合性保証         |
  |                                              |
  | 限界: 単一ノードの性能に律速される           |
  |       水平スケーリングが困難                  |
  └─────────────────────────────────────────────┘

  Datastore（Bigtableベース）
  ┌─────────────────────────────────────────────┐
  | 設計原則: 水平スケーラビリティ               |
  |                                              |
  | ・非正規化（関連データを同一エンティティに）  |
  | ・JOINなし — 必要なデータは事前に結合         |
  | ・Entity Groupによる限定的トランザクション    |
  | ・結果整合性（Eventually Consistent）         |
  |                                              |
  | 獲得: 数千台規模の水平スケーリング           |
  |       Googleスケールのデータ処理             |
  └─────────────────────────────────────────────┘
```

Datastoreの設計制約は具体的だった。Entity Groupの更新頻度は1秒に1回以下が推奨されていた。これは、Entity Group内のデータ一貫性を保つためにPaxosベースの合意プロトコルが使われており、高頻度の更新がボトルネックになるためだ。また、行キーが辞書順に近い値（たとえば連番のID）にアクセスが集中すると、特定のタブレットに負荷が偏るホットキー問題が発生した。

この制約に直面した開発者の多くは困惑した。RDBMSの正規化に慣れた開発者にとって、「JOINできない」「正規化するな」「データを冗長に持て」という指針は、長年の訓練と真逆だったからだ。だが、この設計思想は2010年代にNoSQLムーブメントとして広く受容されることになる。MongoDB、Cassandra、DynamoDB——これらのNoSQLデータベースはいずれも、スケーラビリティのためにRDBMSの制約を部分的に放棄するアプローチを採っている。GAEのDatastoreは、この潮流の先駆けだった。

### オートスケーリング——「ゼロへのスケールダウン」の先見性

GAEのオートスケーリングは、3つのモードを提供していた。

**自動スケーリング。** リクエストレート、レスポンスレイテンシ、その他のアプリケーションメトリクスに基づいて、インスタンス数を自動的に増減する。トラフィックがない場合、インスタンス数はゼロまで縮小する。

**基本スケーリング。** リクエストが到着したときにインスタンスを作成し、アイドル状態になるとシャットダウンする。断続的なワークロードに適している。

**手動スケーリング。** 指定された数のインスタンスを常時起動し続ける。メモリに状態を保持する必要があるアプリケーション向け。

自動スケーリングの「ゼロへのスケールダウン」は、GAEの設計思想の中でも特に先見性のある概念だった。トラフィックがないときにリソースをまったく消費しない——この動作は、2014年に登場するAWS Lambdaの核心概念そのものだ。GAEは「サーバーレス」という言葉が生まれる前に、サーバーレスの本質を実装していた。

ただし、「ゼロへのスケールダウン」にはコールドスタートという代償がある。ゼロ状態からリクエストを受けると、インスタンスの起動に時間がかかる。Python 2.7のランタイムでは数百ミリ秒程度だったが、Javaランタイムでは数秒に及ぶこともあった。この遅延は、低頻度アクセスのアプリケーションにとって深刻な問題となった。GAEはのちに「ウォームアップリクエスト」（`/_ah/warmup`）の仕組みを導入し、最低1インスタンスを常時起動する設定も可能にしたが、いずれもコールドスタートの根本解決ではなく緩和策だった。

### サンドボックスの設計——なぜGoogleはここまで制約したのか

GAEのStandard Environmentでは、アプリケーションはGoogleが管理するサンドボックス内で実行される。第12回で解説したcgroupsやnamespacesによるコンテナ隔離とは異なり、GAEの初期サンドボックスはより厳格なアプローチを取っていた。Pythonランタイム自体が修正されており、`os.system()` や `subprocess` モジュールによる外部プロセスの起動が禁止されていた。ネットワーク通信もURL Fetch API経由に制限され、任意のTCPソケットを開くことはできなかった。

```
GAEのサンドボックスモデル（初期Standard Environment）:

  ┌─────────────────────────────────────────────┐
  |  アプリケーション                             |
  |  ┌──────────────────────────────────────┐    |
  |  | 許可された操作:                       |    |
  |  |  ・Datastore API（データ永続化）      |    |
  |  |  ・URL Fetch API（HTTP通信）          |    |
  |  |  ・Memcache API（キャッシュ）         |    |
  |  |  ・Task Queue API（非同期処理）       |    |
  |  |  ・Images API（画像処理）             |    |
  |  |  ・Users API（認証）                  |    |
  |  |  ・Mail API（メール送信）             |    |
  |  └──────────────────────────────────────┘    |
  |                                              |
  |  ┌──────────────────────────────────────┐    |
  |  | 禁止された操作:                       |    |
  |  |  x ファイルシステムへの書き込み       |    |
  |  |  x 外部プロセスの起動                 |    |
  |  |  x 任意のTCPソケット                  |    |
  |  |  x C拡張ライブラリの使用              |    |
  |  |  x 60秒を超えるリクエスト処理        |    |
  |  └──────────────────────────────────────┘    |
  └─────────────────────────────────────────────┘
```

なぜここまで厳格な制約を課したのか。理由は二つある。

第一に、マルチテナント環境のセキュリティと安定性の確保だ。GAEでは同一の物理マシン上で数千のアプリケーションが同時に実行される。一つのアプリケーションがファイルシステムを汚染したり暴走するプロセスを生成したりすると、同居する他のアプリケーションに影響が及ぶ。厳格なサンドボックスは、第12回で詳述した「Noisy Neighbor」問題を根本から防ぐための措置だった。

第二に、自動スケーリングの実現だ。アプリケーションがステートレスであり外部依存が限定されていれば、任意のインスタンスにリクエストをルーティングでき、インスタンスの追加・削除も瞬時に行える。ファイルシステムにデータを持つアプリケーションや長時間実行プロセスを持つアプリケーションは、この瞬時のスケーリングを困難にする。

つまり、GAEの制約は「意地悪」ではなく「設計原則の埋め込み」だった。ステートレス、短命リクエスト、外部ストレージの利用——これらは分散システムの教科書が推奨する原則そのものであり、GAEはそれを「推奨」ではなく「仕組みとして要求」したのだ。

### HerokuとGAE——同じPaaSの異なる哲学

前回取り上げたHerokuとGAEを比較すると、PaaSという同じカテゴリに属しながら、根本的に異なる設計哲学が見えてくる。

Herokuの設計哲学は「開発者体験の最大化」だ。`git push heroku main` というインターフェースに象徴されるように、開発者が既に知っているツールとワークフローを活かし、デプロイの障壁を可能な限り下げる。制約は存在するが（揮発性ファイルシステム、Dynoの再起動等）、それは結果として良い設計を促す程度のものであり、GAEほど厳格ではない。

GAEの設計哲学は「スケーラビリティのための制約の要求」だ。Googleの内部インフラで培われた分散システムの原則を、外部の開発者にも適用する。制約は「推奨」ではなく「要求」であり、従わないアプリケーションはそもそも動作しない。その代わり、制約に従ったアプリケーションは、Googleのインフラが保証するスケーラビリティを享受できる。

もう一つの重要な違いは、データベースの扱いだ。HerokuはPostgreSQLをアドオンとして提供し、開発者はSQLという馴染みの言語でデータを操作できる。GAEはDatastore（Bigtableベース）を「標準の」データストアとして位置づけ、RDBMSとは根本的に異なるデータモデルを要求した。この選択は、スケーラビリティの観点からは正しいが、開発者の学習コストの観点からは大きな障壁となった。

AWSのElastic Beanstalk（2011年）は、第三のアプローチを取った。Elastic Beanstalkは既存のAWSサービス（EC2、RDS、ELB等）の上にPaaSレイヤーを構築するもので、開発者はインフラのカスタマイズ余地を保ったまま、デプロイの自動化を享受できる。GAEの「厳格な制約」でもHerokuの「独自のビルド・ランタイム」でもなく、「既存のIaaSの上に便利なレイヤーを被せる」というアプローチだ。

```
3つのPaaSの設計哲学:

  Heroku（2007年〜）
  ┌────────────────────────────────────────┐
  | 哲学: 開発者体験の最大化                |
  | インターフェース: git push              |
  | データベース: PostgreSQL（SQL）         |
  | 制約の度合い: 中程度（結果的に良い設計） |
  | 差別化: DX（Developer Experience）     |
  └────────────────────────────────────────┘

  Google App Engine（2008年〜）
  ┌────────────────────────────────────────┐
  | 哲学: スケーラビリティのための制約      |
  | インターフェース: SDK + コマンドライン   |
  | データベース: Datastore（NoSQL）        |
  | 制約の度合い: 厳格（設計原則を仕組みに） |
  | 差別化: Googleスケールの自動スケーリング |
  └────────────────────────────────────────┘

  AWS Elastic Beanstalk（2011年〜）
  ┌────────────────────────────────────────┐
  | 哲学: IaaSの上の便利レイヤー           |
  | インターフェース: CLI / Console         |
  | データベース: RDS（任意のRDBMS）        |
  | 制約の度合い: 低（IaaSの柔軟性を維持）  |
  | 差別化: AWSエコシステムとの統合         |
  └────────────────────────────────────────┘
```

---

## 4. GAEの進化——制約の緩和と新たな系譜

### 第二世代ランタイムとgVisor（2018年）

GAEの厳格なサンドボックスは、初期の設計としては理にかなっていたが、年月を経るにつれて大きな障壁となった。多くのライブラリやフレームワークがGAEのサンドボックス内で動作せず、開発者は「GAE用の特別な書き方」を強いられた。

2018年、Googleはこの問題に対して根本的な解決策を投入した。第二世代ランタイムだ。

第二世代ランタイムは、gVisorというGo言語で書かれたユーザースペースカーネルをサンドボックスの基盤に採用した。gVisorは、アプリケーションとホストカーネルの間に位置し、Linuxのシステムコールインターフェースを実装する。アプリケーションから見るとLinuxカーネルが動いているように見えるが、実際のシステムコールはgVisorによってインターセプトされ、安全に処理される。

この技術革新により、従来のサンドボックス制約の多くが撤廃された。未修正のPython 3.7ランタイムがそのまま動作し、Node.jsも標準的な実行環境として利用可能になった。C拡張を含むライブラリも（gVisorが対応するシステムコールの範囲内で）使えるようになった。

```
第一世代と第二世代ランタイムの比較:

  第一世代（〜2017年）
  ┌──────────────────────────────────────┐
  | ・修正されたPythonランタイム          |
  | ・独自サンドボックスによる厳格な制約   |
  | ・C拡張ライブラリ使用不可             |
  | ・GAE固有のAPI（Datastore, URL Fetch）|
  | ・ポータビリティが低い                |
  └──────────────────────────────────────┘

  第二世代（2018年〜）
  ┌──────────────────────────────────────┐
  | ・未修正の標準ランタイム               |
  | ・gVisorベースのサンドボックス         |
  | ・多くのC拡張ライブラリが利用可能      |
  | ・標準ライブラリ/クライアントが利用可能|
  | ・ポータビリティが向上                |
  └──────────────────────────────────────┘
```

第二世代ランタイムへの移行は、GAEの設計哲学の転換点でもあった。「Googleの設計思想に従え」という厳格なアプローチから、「標準的な開発体験を提供しつつ、裏側でGoogleのインフラを活用する」というアプローチへの移行だ。gVisorの技術により、セキュリティと隔離は維持したまま、開発者に見える制約を大幅に減らすことができた。

### Flexible Environment——Dockerの波を受けて

第二世代ランタイムに先立つ2017年3月のGoogle Cloud Nextで、GAE Flexible Environment（旧称Managed VMs）がGAとなった。

Flexible Environmentは、Standard Environmentとは根本的に異なるアプローチを取っている。Standard Environmentがサンドボックス内で軽量なインスタンスを高速に起動・停止するのに対し、Flexible EnvironmentはDockerコンテナをCompute Engine VM上で実行する。

これにより、Standard Environmentの多くの制約が解消された。任意のDockerイメージを使える。ファイルシステムへの書き込みが可能。SSHでインスタンスにアクセスできる。カスタムランタイムを定義できる。だが代償として、インスタンスの起動に数分かかり、ゼロへのスケールダウンはできない。料金もStandard Environmentより高い。

Flexible Environmentの登場は、GAEが当初の厳格な「制約による設計」から、より柔軟なアプローチへ舵を切ったことを示している。Docker/Kubernetesの台頭により、「コンテナ」が実行環境の標準単位になった2010年代後半において、GAEの独自サンドボックスはもはやアドバンテージではなく障壁になっていた。

### Cloud Run——GAEの精神的後継

2019年4月、Google Cloud Next 2019で発表され、同年11月14日にGAとなったCloud Runは、GAEの設計思想の精神的後継と言える。

Cloud Runは、ステートレスなHTTPコンテナをサーバーレスに実行するプラットフォームだ。開発者がDockerコンテナをデプロイすると、Cloud Runがそのコンテナのスケーリング（ゼロへのスケールダウンを含む）、ルーティング、TLS終端を自動的に処理する。課金は100ミリ秒単位のリソース使用量ベースだ。

GAEとCloud Runには共通する設計思想がある。ステートレスなアプリケーション前提、リクエスト駆動のスケーリング、ゼロへのスケールダウン。だが決定的な違いがある。GAEが独自のランタイムとAPIを要求したのに対し、Cloud Runは標準的なDockerコンテナを受け入れる。「HTTPリクエストに応答するステートレスなコンテナ」——この一点だけが制約だ。Cloud RunはKnative Serving APIを実装しており、Knative対応のKubernetesクラスタでも同じコンテナを実行できる。GAEの最大の批判点であったベンダーロックインに対して、ポータビリティという回答を用意した形だ。

この系譜が示すのは、制約の性質の変化だ。「ベンダー固有の制約」から「業界標準に基づく制約」へ。制約そのもの——ステートレス、HTTPリクエスト駆動——は残っている。だがその制約は、コンテナという業界標準の上に構築されている。

---

## 5. ハンズオン——GAEの「制約による設計」を体験する

ここからは、GAEが課した制約を手元の環境で再現し、「制約がなぜスケーラビリティをもたらすのか」を体験する。GAEそのものを使うのではなく、GAEの制約を意図的に模倣した環境を構築し、制約がアプリケーション設計にどのような影響を与えるかを実感することが目的だ。

### 環境

- Docker（Ubuntu 24.04ベースコンテナ）

### 演習1：GAEのサンドボックス制約を再現する

GAEが課した制約の本質を理解するために、その制約を手動で再現する。

```bash
# Docker環境を準備
docker run -it --rm ubuntu:24.04 bash

# 必要なツールのインストール
apt-get update && apt-get install -y python3 python3-pip python3-venv curl

# 作業ディレクトリ
mkdir -p /app/gae-simulator && cd /app/gae-simulator

# === GAEの「制約付きアプリケーション」を構築する ===

# まず「制約なし」のアプリケーションを書く
cat > app_unconstrained.py << 'PYEOF'
"""制約なしのWebアプリケーション（従来型の設計）"""
import os
import json
import time

# 問題1: ファイルシステムにデータを書き込む
def save_user_data(user_id, data):
    os.makedirs("/tmp/userdata", exist_ok=True)
    filepath = f"/tmp/userdata/{user_id}.json"
    with open(filepath, "w") as f:
        json.dump(data, f)
    return filepath

# 問題2: ファイルシステムからデータを読む（インスタンス固有）
def load_user_data(user_id):
    filepath = f"/tmp/userdata/{user_id}.json"
    if os.path.exists(filepath):
        with open(filepath) as f:
            return json.load(f)
    return None

# 問題3: 長時間処理をリクエスト内で行う
def heavy_computation():
    """120秒かかる重い処理"""
    time.sleep(120)
    return "done"

# テスト
print("=== 制約なしアプリケーション ===")
path = save_user_data("user123", {"name": "Alice", "score": 100})
print(f"データ保存: {path}")
data = load_user_data("user123")
print(f"データ読込: {data}")
print(f"ファイルが存在: {os.path.exists(path)}")
print()
print("問題点:")
print("  1. データがローカルファイルシステムに依存")
print("     -> インスタンスが再作成されるとデータ消失")
print("  2. 別のインスタンスからは同じデータにアクセスできない")
print("     -> スケールアウト時にデータの不整合が発生")
print("  3. 120秒の処理はリクエストタイムアウトに引っかかる")
PYEOF

python3 app_unconstrained.py
```

### 演習2：Datastoreの制約（JOINなし、非正規化）を体験する

```bash
cd /app/gae-simulator

cat > app_constrained.py << 'PYEOF'
"""GAEの制約に従ったアプリケーション設計"""
import json
import time

# === インメモリのDatastoreシミュレータ ===
class DatastoreSimulator:
    """GAE Datastoreの簡易シミュレータ"""
    def __init__(self):
        self._entities = {}
        self._group_timestamps = {}

    def put(self, kind, key, entity, entity_group=None):
        group = entity_group or key
        now = time.time()
        if group in self._group_timestamps:
            elapsed = now - self._group_timestamps[group]
            if elapsed < 1.0:
                print(f"  警告: Entity Group '{group}' の更新間隔が"
                      f"短すぎます ({elapsed:.3f}秒)")
        if kind not in self._entities:
            self._entities[kind] = {}
        self._entities[kind][key] = {**entity, '_key': key}
        self._group_timestamps[group] = now

    def get(self, kind, key):
        return self._entities.get(kind, {}).get(key)

ds = DatastoreSimulator()

print("=== Datastore: JOINなしの世界 ===")
print()

# RDBMSなら別テーブルにしてJOINするが、Datastoreではできない
# -> 関連データを同一エンティティに非正規化して保存
ds.put("UserProfile", "user123", {
    "name": "Alice", "score": 100,
    "bio": "Engineer", "posts_count": 42
})
print("RDBMSの場合:")
print("  SELECT u.name, p.bio FROM users u")
print("  JOIN profiles p ON u.id = p.user_id")
print()
print("Datastoreの場合:")
print("  -> JOINできない。関連データを同一エンティティに格納")
profile = ds.get("UserProfile", "user123")
print(f"  非正規化されたデータ: {profile}")
print()

# Entity Group更新頻度の制約を体験
print("=== Entity Group更新頻度の制約 ===")
for i in range(3):
    ds.put("Counter", "global", {"count": i}, entity_group="counters")
    time.sleep(0.2)
print("-> 高頻度更新はシャーディングで対処する")
PYEOF

python3 app_constrained.py
```

### 演習3：ファイルシステム制約とタイムアウトの影響

```bash
cd /app/gae-simulator

cat > constraints_demo.py << 'PYEOF'
"""GAEの制約がスケーラビリティに与える影響"""
import os, json, tempfile, shutil, uuid
from collections import deque

# === 制約1: ファイルシステムとマルチインスタンス ===
print("=== ファイルシステム制約とスケーラビリティ ===")
print()
inst_a = tempfile.mkdtemp(prefix="instance_a_")
inst_b = tempfile.mkdtemp(prefix="instance_b_")

with open(os.path.join(inst_a, "session.json"), "w") as f:
    json.dump({"user": "Alice", "cart": ["item1"]}, f)
print("インスタンスA: セッション保存（ローカルFS）")
print(f"インスタンスB: 同じセッション -> "
      f"存在しない ({os.path.exists(os.path.join(inst_b, 'session.json'))})")
print("-> ファイルシステム書き込み禁止は、マルチインスタンス環境での")
print("   データ整合性を保証するための制約")
shutil.rmtree(inst_a); shutil.rmtree(inst_b)
print()

# === 制約2: 60秒タイムアウトとTask Queue ===
print("=== 60秒タイムアウトと非同期処理 ===")
print()
TIMEOUT = 60
items = list(range(50))
total = len(items) * 2  # 1件2秒 = 100秒
print(f"同期処理: {len(items)}件 x 2秒 = {total}秒 > {TIMEOUT}秒制限")
print("-> DeadlineExceededError!")
print()

# Task Queueパターン
queue = deque()
batches = [items[i:i+10] for i in range(0, len(items), 10)]
print(f"非同期処理: {len(batches)}バッチに分割してTask Queueに委譲")
for i, batch in enumerate(batches):
    tid = str(uuid.uuid4())[:8]
    queue.append({"id": tid, "batch": i})
    print(f"  キューに追加: batch_{i} (ID: {tid})")
print("-> リクエストは即座にタスクIDリストを返却")
print("-> バックグラウンドで各バッチが順次処理される")
print()
print("設計原則:")
print("  1. リクエストハンドラは60秒以内に完了する")
print("  2. 長時間処理はTask Queue（現Cloud Tasks）に委譲")
print("  3. この設計はマイクロサービスの非同期パターンと同一")
PYEOF

python3 constraints_demo.py
```

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/14-google-app-engine/` に用意してある。

---

## 6. まとめと次回予告

### この回のまとめ

第14回では、Google App Engineが体現した「制約による設計」の思想を、その技術的詳細、歴史的経緯、そしてクラウドアーキテクチャへの影響とともに読み解いた。

**GAEは「Googleスケールの約束」と「厳格な制約」をセットで提示した。** 2008年4月7日のCampfire Oneイベントで発表されたGAEは、Googleのインフラ上でアプリケーションを動かせるという魅力的な約束を携えていた。だがその約束の裏には、ファイルシステムへの書き込み禁止、60秒のリクエストタイムアウト、Bigtableベースの非SQLデータストア——開発者の自由を大きく制限するサンドボックスが存在した。

**GAEの制約は分散システムの設計原則の「仕組み化」だった。** ファイルシステムに書き込まない（ステートレス）、リクエストを短く保つ（タイムアウト）、データを非正規化する（スケーラブルなストレージ）——これらは分散システムの教科書が推奨する原則そのものだ。GAEはこれらを「推奨」ではなく「仕組み」として組み込んだ。制約に従ったアプリケーションは、結果として自動スケーリングに適した設計となった。

**オートスケーリングの「ゼロへのスケールダウン」は、サーバーレスの先駆けだった。** トラフィックがゼロならインスタンスもゼロにする——GAEのこの動作は、2014年のAWS Lambda登場よりも前に、サーバーレスの核心概念を実装していた。ただし、コールドスタートという代償があり、この課題は現在のサーバーレスプラットフォームにも引き継がれている。

**GAEの系譜は、Flexible Environment（2017年）、第二世代ランタイム（2018年、gVisor）、Cloud Run（2019年）へと続いている。** 厳格な独自サンドボックスから、Dockerコンテナベースの標準的な実行環境へ。制約の性質が「ベンダー固有」から「業界標準」に変わった。この進化は、PaaS全体の潮流——コンテナ標準化によるポータビリティの獲得——を体現している。

冒頭の問いに答えよう。GAEの制約は、Googleが数十万台のサーバ運用で学んだ分散システムの原則を、外部の開発者にも要求するものだった。当時は「不便」に映ったが、振り返ればクラウドネイティブ設計の先取りだった。制約が「なぜそうなっているか」を理解することは、受け入れるにせよ拒むにせよ、正しい判断の前提となる。

### 次回予告

第15回では、「PaaSの栄枯盛衰——なぜ『便利すぎる抽象化』は苦戦したか」を取り上げる。

Heroku（第13回）とGAE（第14回）という二つのPaaSの先駆者を見てきた。どちらも革新的であり、どちらもクラウドの歴史に消えない足跡を残した。だが、PaaSというカテゴリ自体は、2014年以降のDocker/Kubernetesの台頭によって苦戦を迫られた。

「インフラを忘れて開発に集中する」というPaaSの夢は、なぜ実現しなかったのか——いや、本当に実現しなかったのか。Cloud Foundry、OpenShiftの企業向けPaaS、そしてCloud Run、Vercel、Fly.ioという「PaaS 2.0」の台頭。PaaSの思想は死んだのか、それとも形を変えて生き続けているのか。次回はPaaSの全体像を俯瞰し、その栄枯盛衰の構造を読み解く。

---

## 参考文献

- Google Developers Blog, "Google App Engine at Campfire One", April 2008. <https://developers.googleblog.com/en/google-app-engine-at-campfire-one/>
- Google Cloud Platform Blog, "Introducing Google App Engine + our new blog", April 2008. <https://cloudplatform.googleblog.com/2008/04/introducing-google-app-engine-our-new.html>
- Google Press Release, "Google App Engine Announces New Features, Early Look at Java Language Support", April 7, 2009. <http://googlepress.blogspot.com/2009/04/google-app-engine-announces-new_07.html>
- The Go Blog, "Go and Google App Engine", May 2011. <https://go.dev/blog/appengine>
- Google Cloud Documentation, "How instances are managed". <https://cloud.google.com/appengine/docs/standard/how-instances-are-managed>
- Google Cloud Documentation, "Quotas and limits | App Engine standard environment". <https://docs.cloud.google.com/appengine/docs/standard/quotas>
- Google Cloud Documentation, "Cloud Datastore best practices". <https://docs.cloud.google.com/datastore/docs/cloud-datastore-best-practices>
- Google Cloud Blog, "Introducing App Engine Second Generation runtimes and Python 3.7", 2018. <https://cloud.google.com/blog/products/gcp/introducing-app-engine-second-generation-runtimes-and-python-3-7>
- Google Cloud Blog, "Cloud Run: Bringing serverless to containers", April 2019. <https://cloud.google.com/blog/products/serverless/cloud-run-bringing-serverless-to-containers>
- Google Cloud Blog, "Cloud Run is GA", November 2019. <https://cloud.google.com/blog/products/serverless/knative-based-cloud-run-services-are-ga>
- Fay Chang et al., "Bigtable: A Distributed Storage System for Structured Data", OSDI 2006. <https://research.google/pubs/pub27898/>
- TechCrunch, "Google Jumps Head First Into Web Services With Google App Engine", April 7, 2008. <https://techcrunch.com/2008/04/07/google-jumps-head-first-into-web-services-with-google-app-engine/>
- InfoQ, "Google App Engine to Support Node.js 8.x Using the Recently Open Source gVisor Sandbox", May 2018. <https://www.infoq.com/news/2018/05/gae-node/>
- Reto Meier, "An Annotated History of Google's Cloud Platform". <https://medium.com/@retomeier/an-annotated-history-of-googles-cloud-platform-90b90f948920>
