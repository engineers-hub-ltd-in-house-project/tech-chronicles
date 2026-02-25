# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第19回：マイクロサービスとクラウド——分散システムの光と影

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- SOA（Service-Oriented Architecture）とESBの重厚長大さが「SOA疲れ」を生み、マイクロサービスの登場を準備した歴史的経緯
- Jeff Bezosが2002年頃にAmazon社内に発した「APIマンデート」と、Two-Pizza Teamsの設計原則
- Netflixの2008年データベース破損事件から始まる7年間のマイクロサービス移行の全貌
- James LewisとMartin Fowlerの「Microservices」記事（2014年3月）が確立した定義と9つの特徴
- Martin Fowlerの「MonolithFirst」（2015年）が突きつけた警告の意味
- サーキットブレーカー（Netflix Hystrix、2012年）からService Mesh（Istio、2017年）への進化
- 分散トレーシングの系譜——Google Dapper、Zipkin（2012年）、Jaeger（2017年）、OpenTelemetry（2019年）
- マイクロサービスがクラウドを前提とする技術的理由と、その複雑性のコスト

---

## 1. モノリスが壊れた日

2012年のある日、私はモノリシックアプリケーションの前で途方に暮れていた。

あるWebサービスの開発を数年間続けてきた。最初は小さなRailsアプリケーションだった。モデルが10個、コントローラが8個、開発者は3人。デプロイは`git push`してCapistranoを叩くだけ。シンプルで、速く、何の問題もなかった。

だが、サービスが成長するにつれて状況は変わった。モデルは200を超え、コントローラは150を超え、開発者は20人になった。一つの機能を変更すると、予想もしなかった場所でテストが壊れる。決済モジュールの修正が、なぜか通知システムのテストを落とす。開発者同士がコンフリクトを解消するために午前中を費やす。デプロイは金曜日を避けるようになり、やがて「デプロイウィンドウ」という概念が生まれた。週に2回、火曜と木曜の15時から17時だけデプロイが許可される。

ある日、決済処理の緊急バグ修正が必要になった。修正自体は3行の変更だ。だがデプロイするには、テストスイート全体を通す必要がある。テストの実行に45分かかる。そして、決済とは無関係なテストが3つ落ちた。他の開発者が投入した別の変更と競合していたのだ。バグ修正のマージに半日を要した。

「3行の修正に半日かかるシステムは、何かが根本的に間違っている」

私はそう思った。そして、当時テック系のブログやカンファレンスで頻繁に耳にするようになっていた言葉——「マイクロサービス」——に手を伸ばすことになる。

結論を先に言おう。マイクロサービスへの分割は、モノリスの問題の一部を確かに解決した。だが同時に、モノリスでは存在しなかった種類の問題を大量に生み出した。サービス間通信の遅延、分散トランザクションの地獄、デバッグの困難さ。あるサービスの障害が別のサービスに連鎖する。本番環境で起きた問題の原因を突き止めるために、6つのサービスのログを横断的に追跡しなければならない。

数年の格闘の末、私はこう結論づけた。「マイクロサービスは組織の問題を解決する。技術の問題は増やす」。

あなたのチームは今、モノリスとマイクロサービスのどちらで開発しているだろうか。そしてその選択の根拠を、技術的なトレードオフとして説明できるだろうか。

---

## 2. マイクロサービス前史——SOAの栄光と失敗

### Jeff Bezosの「APIマンデート」——2002年の予言

マイクロサービスの思想は、2014年にJames LewisとMartin Fowlerが記事を書く遥か前から、実践として存在していた。

2002年頃——正確な年は「前後1年の誤差がある」と当事者自身が認めている——Jeff BezosはAmazon社内に一つの指令を発した。後に「APIマンデート」として知られることになるこの指令は、2011年10月にGoogleのエンジニアSteve YeggeがGoogle+に誤って公開投稿した社内メモ（通称「Stevey's Google Platforms Rant」）によって、広く世に知られることになった。

Bezosの指令は明快だった。

1. 全チームは、自らのデータと機能をサービスインターフェースとして公開すること
2. チーム間の通信は、このサービスインターフェースを通じてのみ行うこと
3. 他のチームのデータストアを直接読むこと、共有メモリモデル、バックドア——いかなる形の直接的なプロセス間通信も禁止する
4. 使用するプロトコルは問わない（HTTP、CORBA、Pub/Sub、カスタムプロトコル、何でもよい）
5. 全てのサービスインターフェースは、例外なく、外部に公開可能な形で設計すること
6. これに従わない者は解雇する

最後の一文が、この指令の本気度を物語っている。

Bezosの指令と同時に導入されたのが「Two-Pizza Teams」——2枚のピザで養える規模（10人未満）のチーム編成原則だった。小さなチームが、小さなサービスを、独立してデプロイする。この組織設計とサービス設計の一致は、後にマイクロサービスの核心原則となる「コンウェイの法則」の実践そのものだった。

コンウェイの法則とは、1967年にMelvin Conwayが提唱した観察である。「システムを設計する組織は、その組織のコミュニケーション構造のコピーとなるシステムを設計する制約を受ける」。逆に言えば、望ましいシステム構造があるなら、それに合わせて組織を設計すべきだ。Bezosはこの法則を、意図的に、徹底的に適用した。

その結果として生まれたのがAWS（Amazon Web Services）だった。社内サービスのインターフェースを外部に公開可能な形で設計せよ、というBezosの第5条件は、まさにAWSの設計原則そのものだ。S3もEC2もSQSも、もともとはAmazon社内のサービスを外部に公開したものである。

### SOAの台頭と「ESB疲れ」

Bezosが社内にAPIマンデートを発した2002年頃、エンタープライズITの世界では「SOA（Service-Oriented Architecture）」が急速に台頭していた。

SOAの概念自体は1990年代後半に登場していたが、2000年代前半に企業に大規模に導入されたのは、ガートナーのアナリストたちの推進によるところが大きい。特にRoy W. SchulteとYefim V. Natisは、2002年に「Enterprise Service Bus（ESB）」という用語を提唱し、SOA実現のための統合基盤として位置づけた。

ESBの役割は、異なるシステム間の通信を仲介するミドルウェアだ。メッセージルーティング、プロトコル変換、データ変換、セキュリティ、モニタリング——これらの横断的関心事をESBが一手に引き受ける。理論上は美しい。だが実装は重厚長大だった。

```
SOA + ESBのアーキテクチャ:

  サービスA ──┐
              │
  サービスB ──┤     ┌──────────────────────────┐
              ├────→│   Enterprise Service Bus  │
  サービスC ──┤     │                          │
              │     │  ・メッセージルーティング │
  サービスD ──┘     │  ・プロトコル変換         │
                    │  ・データ変換             │
                    │  ・セキュリティ           │
                    │  ・トランザクション管理   │
                    │  ・モニタリング           │
                    └──────────────────────────┘
                              │
                    ┌─────────┼─────────┐
                    │         │         │
                サービスE  サービスF  サービスG

  問題: ESBが全通信の中央集権的なボトルネックになる
  ESBの設定変更 = 全サービスに影響するリスク
```

企業はSOAの導入に何百万ドルもの投資を行った。WebサービスのWSDL定義、SOAPメッセージ、XMLスキーマの管理、ESBの設定——これらの「儀式的な」作業が、開発者の時間を蝕んだ。サービスを一つ追加するために、ESBの設定変更、スキーマの更新、テスト環境の再構築が必要になる。「サービスの独立性」を謳いながら、ESBという中央集権的なボトルネックがすべてのサービスを密結合させていた。

2000年代後半、IT業界には「SOA疲れ」が広がった。Anne Thomas Manes（当時Burton Group、後にGartner）は2009年1月のブログ記事で「SOA is Dead; Long Live Services」と宣言し、大きな反響を呼んだ。SOAの概念は死んだのではない。だがSOAという「ブランド」に付着した重厚長大なベンダー製品群とESBの複雑性への嫌悪感が、次の波を呼び込む土壌を作った。

### Netflixの転機——2008年のデータベース破損

SOA疲れが広がる一方で、実践的にサービス分割を推し進めていた企業がある。Netflixだ。

2008年8月、Netflixに危機が訪れた。ディスクアレイのファームウェア更新が原因でデータベースが破損し、3日間にわたってDVDの配送が停止した。当時のNetflixは、モノリシックなJavaアプリケーションとOracle Databaseの上に構築されていた。単一障害点（Single Point of Failure）の恐ろしさを、文字通り身をもって経験したのだ。

この事件がNetflixの技術戦略を根本から変えた。2009年、Netflixはクラウドファースト戦略を宣言し、AWSへの移行を開始した。同時に、モノリシックアプリケーションを独立したサービスに分割する作業が始まった。

Netflixの移行は7年に及ぶ壮大なプロジェクトだった。

```
Netflixのマイクロサービス移行タイムライン:

  2008  データベース破損事件（3日間の障害）
   │    ← 単一障害点の危険性を痛感
   │
  2009  クラウドファースト戦略を宣言
   │    AWSへの移行開始
   │
  2010  ステートレスサービスのクラウド移行
  〜    マイクロサービスへの分割が本格化
  2012  Hystrixをオープンソース化
   │    ← サーキットブレーカーパターンの普及
   │
  2012  Chaos Monkeyの公開
  〜    データレイク（S3）、Cassandraのグローバルスケール
  2014  分散トレーシング、サービスメッシュの実験
   │
  2015  マルチリージョン Active-Active構成
   │    カオスエンジニアリングの体系化
   │
  2016  最後のデータセンターを閉鎖
        ← 7年間の移行が完了
        700以上のマイクロサービス
```

2016年1月に最後のデータセンターを閉鎖した時点で、Netflixのストリーミング会員数は2008年の8倍に達していた。700以上のマイクロサービスが動き、エンジニアは1日に何度もコードをデプロイしていた。

だが、Netflixの成功は技術だけの話ではない。組織文化、開発プラクティス、運用アプローチの根本的な変革を伴っていた。そしてNetflixは、その過程で得た知見をオープンソースとして惜しみなく公開した。Hystrix（サーキットブレーカー）、Eureka（サービスディスカバリ）、Zuul（APIゲートウェイ）、Ribbon（クライアントサイドロードバランサ）——これらのNetflix OSSは、マイクロサービスを実践する世界中のチームの共通基盤となった。

---

## 3. 2014年3月25日——マイクロサービスの定義が生まれた日

### James LewisとMartin Fowlerの記事

2014年3月25日、James LewisとMartin Fowlerはmartinfowler.comに「Microservices」と題する記事を公開した。

2013年末、Fowlerはマイクロサービスという用語が業界で頻繁に使われるようになっているにもかかわらず、明確な定義が存在しないことを懸念していた。そこで、Thoughtworksの同僚であり、マイクロサービスの経験豊富な実践者であるJames Lewisと共同で、この記事を執筆した。

LewisとFowlerは、マイクロサービスアーキテクチャを9つの特徴で定義した。

**1. サービスによるコンポーネント化（Componentization via Services）。** ライブラリではなく、独立してデプロイ可能なサービスとしてコンポーネントを構築する。

**2. ビジネスケイパビリティに基づく組織化（Organized around Business Capabilities）。** 技術レイヤー（UI、ロジック、データ）ではなく、ビジネス機能（決済、通知、ユーザ管理）でチームとサービスを分割する。これはコンウェイの法則の意図的な適用だ。

**3. プロダクト、プロジェクトではなく（Products not Projects）。** サービスを「作って引き渡す」のではなく、チームがサービスのライフサイクル全体に責任を持つ。Amazonの「You build it, you run it」の精神。

**4. スマートエンドポイントとダムパイプ（Smart endpoints and dumb pipes）。** ESBのような「賢い」パイプの代わりに、RESTful HTTPやメッセージングキューのような「単純な」通信手段を使い、ロジックはエンドポイント（サービス自身）に置く。これは、SOA/ESBの反省から生まれた原則だ。

**5. 分散ガバナンス（Decentralized Governance）。** 全サービスに同じ技術スタックを強制しない。各チームが最適な言語やフレームワークを選択できる。

**6. 分散データ管理（Decentralized Data Management）。** サービスごとにデータベースを持つ。共有データベースは使わない。これは、データの整合性に関する根本的な設計判断を伴う。

**7. インフラ自動化（Infrastructure Automation）。** CI/CD（継続的インテグレーション/継続的デリバリー）、自動テスト、自動デプロイが前提。マイクロサービスなしのモノリスでも有用だが、マイクロサービスでは必須。

**8. 障害を前提とした設計（Design for failure）。** サービスは障害を起こす。ネットワークは信頼できない。だからサーキットブレーカー、タイムアウト、ヘルスチェック、フェイルオーバーを設計に組み込む。

**9. 進化的設計（Evolutionary Design）。** サービスの境界は変わりうる。分割や統合を容易にする設計を心がける。

```
マイクロサービスの9つの特徴（Lewis & Fowler, 2014）:

  ┌─────────────────────────────────────────────────────────┐
  │  組織的側面                                             │
  │  ┌───────────────┐ ┌──────────────┐ ┌───────────────┐  │
  │  │ビジネスケイパ │ │プロダクト    │ │分散           │  │
  │  │ビリティで組織│ │志向（作って │ │ガバナンス    │  │
  │  │化            │ │運用する）   │ │（技術選択の  │  │
  │  │              │ │             │ │ 自由）       │  │
  │  └───────────────┘ └──────────────┘ └───────────────┘  │
  ├─────────────────────────────────────────────────────────┤
  │  技術的側面                                             │
  │  ┌───────────────┐ ┌──────────────┐ ┌───────────────┐  │
  │  │サービスによる│ │スマート      │ │分散データ    │  │
  │  │コンポーネント│ │エンドポイント│ │管理          │  │
  │  │化            │ │＋ダムパイプ  │ │（DB per      │  │
  │  │              │ │（ESBの否定）│ │ Service）    │  │
  │  └───────────────┘ └──────────────┘ └───────────────┘  │
  ├─────────────────────────────────────────────────────────┤
  │  運用的側面                                             │
  │  ┌───────────────┐ ┌──────────────┐ ┌───────────────┐  │
  │  │インフラ自動化│ │障害を前提   │ │進化的設計    │  │
  │  │（CI/CD必須） │ │とした設計   │ │（境界は     │  │
  │  │              │ │             │ │ 変わりうる） │  │
  │  └───────────────┘ └──────────────┘ └───────────────┘  │
  └─────────────────────────────────────────────────────────┘
```

この記事の影響は絶大だった。マイクロサービスは「Netflixがやっていること」という漠然とした印象から、明確な特徴を持つアーキテクチャスタイルへと昇華された。

### 「MonolithFirst」——Fowler自身の警告

だが、マイクロサービスの定義を広めたFowler自身が、わずか1年後に警告を発している。

2015年6月3日、Fowlerはmartinfowler.comに「MonolithFirst」という記事を公開した。その冒頭は印象的だ。

> 「成功したマイクロサービスのほぼすべてが、大きくなりすぎたモノリスから始まっている。一方、最初からマイクロサービスで構築したほぼすべてのケースが、深刻な問題に陥っている」

Fowlerが指摘した理由は二つある。

**第一に、マイクロサービスプレミアム。** マイクロサービスには固有のコスト——分散システムの複雑性、サービス間通信のオーバーヘッド、運用の難しさ——が存在する。シンプルなアプリケーションでは、このコストがメリットを上回る。

**第二に、サービス境界の発見の困難さ。** 適切なサービス境界を最初から見極めることは、経験豊富なアーキテクトにとっても難しい。モノリスで開発を始め、ドメインの理解が深まってからサービスに分割する方が、正しい境界を見つけやすい。

この「まずモノリスから始めよ」という助言は、マイクロサービスの熱狂に対する冷水として機能した。だが、その冷水を浴びなかったチームの中には、「マイクロサービスから始めたばかりに、分散モノリス——マイクロサービスの欠点だけを持ち、メリットのないシステム——を作り上げてしまった」という話が後を絶たなかった。

---

## 4. マイクロサービスの技術的課題と解法の進化

### サービスディスカバリ——「相手はどこにいるのか」

モノリスでは、関数呼び出しは同じプロセス内で完結する。メソッド名を指定すれば、ランタイムが呼び出し先を解決してくれる。だがマイクロサービスでは、呼び出し先は別のプロセス、別のマシン、場合によっては別のデータセンターにある。

「相手はどこにいるのか」——この問いに答えるのがサービスディスカバリだ。

```
サービスディスカバリの仕組み:

  クライアントサイドディスカバリ（Netflix Eureka方式）:

  サービスA ──→ サービスレジストリ ←── サービスB（登録）
     │           （Eureka）              │
     │                                   │
     │  1. レジストリに問い合わせ         │
     │  2. サービスBのアドレス一覧を取得  │
     │  3. クライアント側でロードバランス  │
     └───────────→ サービスB ←────────────┘

  サーバサイドディスカバリ（Kubernetes方式）:

  サービスA ──→ ロードバランサ ──→ サービスB
                 （Service）       Pod 1, Pod 2, Pod 3
     │
     │  1. Kubernetes Serviceの名前で宛先指定
     │  2. kube-proxyがPodへルーティング
     │  3. クライアントはPodの存在を意識しない
```

Netflixが2012年にオープンソース化したEurekaは、クライアントサイドディスカバリの代表格だ。各サービスは起動時にEurekaサーバに自身を登録し、他のサービスはEurekaに問い合わせて呼び出し先のアドレスを取得する。クラウド環境ではサービスのインスタンスが動的に増減するため、静的なIPアドレスでは通信先を指定できない。サービスディスカバリは、クラウド上のマイクロサービスにとって基盤的な仕組みだ。

第17回で取り上げたKubernetesは、サービスディスカバリをプラットフォームレベルで提供する。KubernetesのServiceリソースは、DNSベースのサービスディスカバリとロードバランシングを一体化したものだ。`http://payment-service.default.svc.cluster.local` という名前で呼び出せば、Kubernetesが適切なPodにルーティングしてくれる。

### サーキットブレーカー——「障害の連鎖を断ち切る」

マイクロサービスの世界では、一つのリクエストが複数のサービスを横断する。ユーザーが注文ボタンを押すと、注文サービスが在庫サービスに在庫確認を依頼し、決済サービスに課金を依頼し、通知サービスに確認メールの送信を依頼する。

では、決済サービスが応答しなくなったらどうなるか。

注文サービスは決済サービスの応答を待ち続ける。タイムアウトまでの間、注文サービスのスレッドは占有され、新たなリクエストを処理できない。注文サービスに依存する他のサービスも、連鎖的に応答不能になる。一つのサービスの障害が、システム全体を麻痺させる。これがカスケード障害（cascading failure）だ。

```
カスケード障害のメカニズム:

  ユーザー → 注文サービス → 在庫サービス    ✓ 応答正常
                  │
                  └──→ 決済サービス    ✗ 応答なし
                  │        ↑
                  │     タイムアウト待ち（30秒）
                  │     スレッドが枯渇
                  │
                  └──→ 通知サービス    ✓ 到達不能
                          ↑                （注文サービスが
                       注文サービスの        応答不能のため）
                       スレッド枯渇で
                       リクエスト処理不能

  結果: 決済サービス1つの障害 → システム全体が応答不能
```

この問題を解決するパターンが、サーキットブレーカーだ。Michael Nygardが2007年の著書『Release It!』で提唱した概念である。

サーキットブレーカーの動作原理は、電気回路のブレーカーと同じだ。

```
サーキットブレーカーの3つの状態:

  ┌──────────┐    障害率が閾値超過    ┌──────────┐
  │  CLOSED  │ ─────────────────→ │   OPEN   │
  │ （正常） │                       │ （遮断） │
  │          │                       │          │
  │ リクエスト│                       │ リクエスト│
  │ を転送   │                       │ を即座に │
  │          │                       │ 拒否     │
  └──────────┘                       └──────────┘
       ↑                                  │
       │         一定時間経過後            │
       │                                  ↓
       │                            ┌──────────┐
       │     成功率が回復            │HALF-OPEN │
       └──────────────────────── │ （半開） │
                                    │          │
                                    │ 一部の   │
                                    │ リクエスト│
                                    │ を試行   │
                                    └──────────┘
```

**CLOSED状態**: リクエストは通常通り転送される。障害率を監視する。

**OPEN状態**: 障害率が閾値を超えると、リクエストの転送を停止し、即座にエラーを返す。障害を起こしているサービスへのリクエストを止めることで、スレッド枯渇とカスケード障害を防ぐ。

**HALF-OPEN状態**: 一定時間後、限定的にリクエストを試行する。成功すればCLOSEDに戻り、失敗すれば再びOPENになる。

2011年、Netflixの APIチームはこのパターンを体系的に実装するレジリエンスエンジニアリングに着手した。2012年、その成果がHystrixとしてオープンソース化された。Hystrixは、スレッド隔離とサーキットブレーカーを組み合わせた耐障害性ライブラリであり、Java/JVMベースのマイクロサービスにおけるデファクトスタンダードとなった。

だが、Hystrixの物語には続きがある。2018年11月19日、NetflixはHystrixをメンテナンスモードに移行すると発表した。新機能の追加は行わず、既存のバグ修正のみを継続する。Netflixは、社内の既存アプリケーションではHystrixを引き続き使用するが、新プロジェクトにはResilient4jなどの代替を推奨した。

Resilience4jは、Java 8と関数型プログラミングを前提に設計された軽量な耐障害性ライブラリだ。Hystrixがオブジェクト指向の`HystrixCommand`でラップする設計だったのに対し、Resilience4jは関数合成（function composition）でデコレートする設計を採用した。CircuitBreaker、RateLimiter、Retry、Bulkhead、TimeLimiterといったモジュールを、必要に応じて組み合わせる。Spring Frameworkも、新プロジェクトでの推奨サーキットブレーカーとしてResilience4jを位置づけている。

### 分散トレーシング——「リクエストの旅路を追う」

モノリスでは、リクエストの処理フローをスタックトレースで追跡できる。だがマイクロサービスでは、一つのリクエストが複数のサービスを横断する。従来のログ分析では、サービスAのログ、サービスBのログ、サービスCのログを突き合わせ、タイムスタンプで相関を推測するしかない。

この問題に体系的に取り組んだのが、Googleだった。2010年、GoogleはDapperと題する論文を公開した。Googleの本番環境で使われている分散トレーシングシステムの設計を記述したこの論文は、後の分散トレーシングの基礎理論となった。

Dapperの核心は、リクエストの「旅路」全体をTrace（トレース）として表現し、各サービスでの処理をSpan（スパン）として記録し、Span同士を親子関係で繋げるという構造だ。

```
分散トレーシングの構造（Dapper方式）:

  Trace ID: abc-123（リクエスト全体を一意に識別）

  ┌──────────────────────────────────────────────────┐
  │ Span A: APIゲートウェイ（200ms）                 │
  │  ┌────────────────────────────────────┐          │
  │  │ Span B: 注文サービス（150ms）      │          │
  │  │  ┌──────────────────┐              │          │
  │  │  │ Span C: 在庫確認 │              │          │
  │  │  │ （50ms）         │              │          │
  │  │  └──────────────────┘              │          │
  │  │  ┌──────────────────────────┐      │          │
  │  │  │ Span D: 決済処理（80ms） │      │          │
  │  │  │  ┌────────────────┐      │      │          │
  │  │  │  │ Span E: 外部API│      │      │          │
  │  │  │  │ 呼出（60ms）  │      │      │          │
  │  │  │  └────────────────┘      │      │          │
  │  │  └──────────────────────────┘      │          │
  │  └────────────────────────────────────┘          │
  └──────────────────────────────────────────────────┘

  → Trace全体で200ms。決済処理が80msで最も時間を占め、
    うち60msは外部API呼び出し。ボトルネックは外部APIにある。
```

Dapper論文に触発されて、オープンソースの分散トレーシングシステムが次々と生まれた。

**Zipkin（2012年）**: TwitterがHack Weekで開発し、オープンソース化した最初のOSS分散トレーシングシステム。Johan OskarssonとFranklin Huが主要著者。計測機能とUIを完備していた点で画期的だった。

**Jaeger（2017年）**: Uber社内で2015年に開発が始まり、2017年にオープンソース化。2017年9月にCNCF（Cloud Native Computing Foundation）の第12番目のホステッドプロジェクトとして採用され、2019年10月にGraduatedステータスに到達した。Go言語で実装されている。

**OpenTelemetry（2019年）**: 分散トレーシングの標準化をめぐっては、CNCF傘下のOpenTracing（2016年〜）とGoogleが主導するOpenCensusが並立し、コミュニティが分断されていた。2019年5月、両プロジェクトが統合してOpenTelemetryが誕生した。トレース、メトリクス、ログを統一的に扱う観測フレームワークとして、2021年8月にCNCFインキュベーティングプロジェクトに昇格した。

```
分散トレーシングの系譜:

  2010  Google Dapper 論文
   │    ← 理論的基盤
   │
  2012  Zipkin（Twitter）
   │    ← 最初のOSS分散トレーシング
   │
  2015  Jaeger 開発開始（Uber社内）
   │
  2016  OpenTracing（CNCF）
   │    ← トレーシングAPIの標準化を目指す
   │
  2017  Jaeger オープンソース化・CNCF採用
   │    OpenCensus（Google）
   │    ← メトリクスとトレーシングの統合を目指す
   │
  2019  OpenTelemetry 誕生
   │    ← OpenTracing + OpenCensus の統合
   │
  2021  OpenTelemetry CNCFインキュベーティング昇格
```

分散トレーシングの進化は、マイクロサービスの複雑性に対する解答の一つだ。だが解答であると同時に、この複雑な観測基盤が必要である事実自体が、マイクロサービスが導入する複雑性の証左でもある。

### Service Mesh——「サービス間通信をインフラに落とす」

マイクロサービスが増えると、サービス間通信に関する横断的関心事——サーキットブレーカー、リトライ、タイムアウト、暗号化、認証、負荷分散、分散トレーシング——を各サービスが個別に実装する必要が出てくる。

当初、これらの機能はNetflix OSSのようなライブラリとして提供された。Hystrix（サーキットブレーカー）、Ribbon（ロードバランサ）、Eureka（ディスカバリ）——これらをアプリケーションコードに組み込む。だがこのアプローチには問題がある。ライブラリのバージョンアップは全サービスのデプロイを伴う。言語が異なるサービス（JavaとGoとPython）では、それぞれの言語用のライブラリが必要になる。

Service Meshは、これらの横断的関心事をアプリケーションコードから引き剥がし、インフラレイヤーに落とすアーキテクチャパターンだ。

```
Service Meshのアーキテクチャ（サイドカーパターン）:

  ┌─────────────────────┐    ┌─────────────────────┐
  │ Pod A               │    │ Pod B               │
  │ ┌─────────┐         │    │         ┌─────────┐ │
  │ │サービスA │         │    │         │サービスB │ │
  │ │（注文）  │         │    │         │（決済） │ │
  │ └────┬────┘         │    │         └────┬────┘ │
  │      │ localhost     │    │  localhost   │      │
  │ ┌────┴────┐         │    │         ┌────┴────┐ │
  │ │ Envoy   │←───mTLS────→│ Envoy   │ │
  │ │ Proxy   │         │    │         │ Proxy   │ │
  │ │(Sidecar)│         │    │         │(Sidecar)│ │
  │ └─────────┘         │    │         └─────────┘ │
  └─────────────────────┘    └─────────────────────┘
           ↑                            ↑
           └────── コントロールプレーン ─┘
                   （Istio / Linkerd）
                   ・トラフィック制御ルール
                   ・セキュリティポリシー
                   ・テレメトリ収集設定
```

2017年5月、Google、IBM、Lyftの三社はIstioをオープンソース化した。Istioはデータプレーン（Envoyプロキシ）とコントロールプレーンから構成されるService Meshだ。各サービスのPodにEnvoyプロキシがサイドカーとして注入され、サービス間の全トラフィックがこのプロキシを経由する。アプリケーションコードはHTTPリクエストを送るだけ。暗号化、リトライ、サーキットブレーカー、トレーシング——これらはすべてEnvoyプロキシが透過的に処理する。

Istioの初期バージョン0.1は実験的なものだったが、2018年7月にリリースされた1.0で「プロダクションレディ」が宣言された。

Service Meshの思想は、SOA時代のESBと構造的に似ている。通信の横断的関心事を、アプリケーションの外に切り出す。だが決定的な違いがある。ESBは中央集権的な単一のバスだった。Service Meshは分散的だ。各サービスのサイドカーがメッシュ状に接続する。単一障害点は存在しない。

---

## 5. マイクロサービスはクラウドを前提とする——その技術的理由

### なぜマイクロサービスはクラウドなしでは成立しにくいのか

マイクロサービスの9つの特徴を振り返ると、その多くがクラウドの能力を暗黙の前提としていることに気づく。

**動的なサービスディスカバリ。** マイクロサービスのインスタンスは動的に増減する。IPアドレスは固定されない。この環境でサービスを発見するためには、サービスレジストリか、Kubernetesのような動的なプラットフォームが必要だ。オンプレミスの固定的なインフラでは、この動的性が制約される。

**独立したデプロイ。** 各サービスが独立してデプロイされるということは、デプロイの頻度がサービス数に比例して増加するということだ。20のマイクロサービスがそれぞれ週に2回デプロイすれば、週40回のデプロイが発生する。これを手動で管理することは不可能だ。CI/CDパイプライン、コンテナレジストリ、オーケストレーション——クラウドネイティブなツールチェーンが必須になる。

**弾力的なスケーリング。** 各サービスの負荷は異なる。注文サービスは1日中忙しいが、レポート生成サービスは深夜に集中する。サービスごとに異なるスケーリングポリシーを適用するには、クラウドの弾力性が不可欠だ。

**障害ドメインの分離。** マイクロサービスの価値の一つは、障害の影響範囲を限定することだ。だがそのためには、サービスごとに独立した実行環境（コンテナ、VM、Availability Zone）が必要であり、これはクラウドの抽象化なしには実現が困難だ。

```
マイクロサービスとクラウドの相互依存:

  マイクロサービスの要件      →   クラウドが提供する機能
  ────────────────────────────────────────────────────
  動的なサービスディスカバリ  →   Kubernetes Service
                                  AWS Cloud Map
                                  Consul

  独立したデプロイ            →   コンテナオーケストレーション
                                  CI/CDパイプライン
                                  ECS/EKS/GKE/AKS

  弾力的なスケーリング        →   Auto Scaling
                                  HPA (Kubernetes)
                                  Lambda (サーバーレス)

  障害ドメインの分離          →   Availability Zone
                                  リージョン分離
                                  VPC分離

  分散データ管理              →   マネージドDB
                                  (RDS, DynamoDB, Cloud SQL)

  観測可能性                  →   CloudWatch, Datadog
                                  X-Ray, Jaeger
                                  OpenTelemetry
```

### 分散システムの「8つの誤謬」

マイクロサービスは分散システムである。そして分散システムには、1994年にSun MicrosystemsのPeter Deutschが提唱した「分散コンピューティングの8つの誤謬（The Eight Fallacies of Distributed Computing）」が容赦なく襲いかかる。

1. ネットワークは信頼できる
2. レイテンシーはゼロである
3. 帯域幅は無限である
4. ネットワークはセキュアである
5. トポロジーは変化しない
6. 管理者は一人である
7. 転送コストはゼロである
8. ネットワークは均質である

モノリスでは、これらの誤謬は問題にならない。プロセス内の関数呼び出しは、ネットワークを経由しない。だがマイクロサービスでは、すべてのサービス間通信がネットワークを経由する。ネットワークは遅延し、切断され、混雑する。

私がモノリスからマイクロサービスに移行した際に最も苦しんだのが、この「ネットワーク越しの呼び出しは関数呼び出しとは根本的に異なる」という事実だった。モノリス内の関数呼び出しは、数ナノ秒で完了し、失敗しない（メモリ不足を除けば）。マイクロサービス間のHTTPリクエストは、数ミリ秒から数百ミリ秒かかり、タイムアウトし、接続が拒否され、レスポンスが途中で途切れる。

```
モノリスの関数呼び出し vs マイクロサービスのHTTP呼び出し:

  モノリス:
  ┌───────────────────────────────────────┐
  │ order.process()                       │
  │   → inventory.check()     ~10ns      │
  │   → payment.charge()      ~10ns      │
  │   → notification.send()   ~10ns      │
  │ 合計: ~30ns, 失敗確率: ≈0           │
  └───────────────────────────────────────┘

  マイクロサービス:
  ┌───────────────────────────────────────────┐
  │ POST /orders                              │
  │   → GET inventory-svc/check  ~5ms        │
  │     (DNS解決, TCP接続, TLSハンドシェイク)  │
  │     失敗の可能性: タイムアウト, 503, 接続拒否│
  │   → POST payment-svc/charge  ~50ms       │
  │     (外部決済APIへの中継を含む)            │
  │     失敗の可能性: タイムアウト, 500, 429   │
  │   → POST notification-svc/send ~10ms     │
  │     失敗の可能性: キュー満杯, 503         │
  │ 合計: ~65ms, 各呼び出しに失敗の可能性あり │
  └───────────────────────────────────────────┘

  呼び出し時間: ナノ秒 → ミリ秒（10万倍）
  失敗モード: なし → 多数
```

この差が、「マイクロサービスは技術の問題を増やす」という私の実感の根源だ。

### 分散トランザクションのジレンマ

モノリスでは、データベーストランザクションは単純だ。注文を作成し、在庫を減らし、支払いを記録する。すべてが一つのデータベーストランザクション内で完結し、失敗すればロールバックされる。ACID（原子性、一貫性、分離性、耐久性）が保証される。

マイクロサービスでは、各サービスが独自のデータベースを持つ。注文サービスのDBで注文を作成し、在庫サービスのDBで在庫を減らし、決済サービスのDBで支払いを記録する。3つの異なるデータベースにまたがるトランザクションをどう管理するか。

伝統的な解法は2フェーズコミット（2PC）だ。だが2PCは、参加者の一つが応答しなくなるとトランザクション全体がブロックされる。分散環境では、この「応答しない」状態が日常的に起きる。

マイクロサービスの世界で主流となったのは、Sagaパターンだ。Sagaは、一連のローカルトランザクションと、それぞれに対応する補償トランザクション（失敗時に前の操作を取り消すための処理）で構成される。

```
Sagaパターン（オーケストレーション方式）:

  成功フロー:
  注文サービス → 在庫サービス → 決済サービス → 通知サービス
  [注文作成]   [在庫確保]    [支払い処理]    [通知送信]

  決済失敗時の補償フロー:
  注文サービス ← 在庫サービス ← 決済サービス
  [注文取消]   [在庫戻し]    [支払い失敗]

  特徴:
  ・各ステップはローカルトランザクション（ACID保証あり）
  ・ステップ間は結果整合性（Eventually Consistent）
  ・失敗時は補償トランザクションで「やり直し」
  ・一時的に不整合な状態が存在しうる
```

Sagaパターンは問題を解決するが、その代償として「結果整合性（Eventual Consistency）」を受け入れなければならない。第9回で取り上げたWerner Vogelsの「Eventually Consistent」の概念が、ここで再び登場する。一時的にデータが不整合な状態——在庫は確保されたが決済がまだ完了していない——が存在しうる。この一時的な不整合を許容できるかどうかは、ビジネス要件によって異なる。

---

## 6. ハンズオン——マイクロサービスの動作と障害を体験する

ここでは、Docker Composeで簡易的なマイクロサービスアーキテクチャを構築し、サービス間通信の遅延とサーキットブレーカーパターンの動作を体験する。

### 演習1：マイクロサービスの構築と通信

```bash
# === マイクロサービスアーキテクチャの構築 ===

# Docker環境が必須
# 3つのサービス（注文、在庫、決済）を構築する

WORKDIR="${HOME}/cloud-history-handson-19"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=========================================="
echo "演習1: マイクロサービスの構築と通信"
echo "=========================================="

# ディレクトリ構成
mkdir -p order-service inventory-service payment-service

# --- 在庫サービス ---
cat > inventory-service/app.py << 'PYTHON_EOF'
from flask import Flask, jsonify, request
import time
import random
import os

app = Flask(__name__)

# 在庫データ（簡易的なインメモリストア）
inventory = {
    "item-001": {"name": "Laptop", "stock": 10},
    "item-002": {"name": "Mouse", "stock": 50},
    "item-003": {"name": "Keyboard", "stock": 30},
}

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy", "service": "inventory"})

@app.route("/check/<item_id>", methods=["GET"])
def check_stock(item_id):
    """在庫を確認する。"""
    # 意図的な遅延（ネットワークレイテンシーのシミュレーション）
    delay = random.uniform(0.01, 0.05)
    time.sleep(delay)

    if item_id not in inventory:
        return jsonify({"error": "Item not found"}), 404

    item = inventory[item_id]
    return jsonify({
        "item_id": item_id,
        "name": item["name"],
        "stock": item["stock"],
        "available": item["stock"] > 0,
        "response_time_ms": round(delay * 1000, 1)
    })

@app.route("/reserve/<item_id>", methods=["POST"])
def reserve_stock(item_id):
    """在庫を確保する。"""
    if item_id not in inventory:
        return jsonify({"error": "Item not found"}), 404

    item = inventory[item_id]
    if item["stock"] <= 0:
        return jsonify({"error": "Out of stock"}), 409

    quantity = request.json.get("quantity", 1)
    if item["stock"] < quantity:
        return jsonify({"error": "Insufficient stock"}), 409

    item["stock"] -= quantity
    return jsonify({
        "item_id": item_id,
        "reserved": quantity,
        "remaining_stock": item["stock"]
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
PYTHON_EOF

# --- 決済サービス ---
cat > payment-service/app.py << 'PYTHON_EOF'
from flask import Flask, jsonify, request
import time
import random
import os

app = Flask(__name__)

# 障害シミュレーションフラグ
FAILURE_MODE = os.environ.get("FAILURE_MODE", "none")

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy", "service": "payment"})

@app.route("/charge", methods=["POST"])
def charge():
    """決済を処理する。障害モードの設定で遅延や失敗をシミュレート。"""
    data = request.json

    # 障害シミュレーション
    if FAILURE_MODE == "slow":
        # 遅延モード: 3-8秒の遅延（タイムアウトを引き起こす）
        delay = random.uniform(3.0, 8.0)
        time.sleep(delay)
    elif FAILURE_MODE == "error":
        # エラーモード: 70%の確率で500エラー
        if random.random() < 0.7:
            return jsonify({"error": "Payment gateway timeout"}), 500
    elif FAILURE_MODE == "intermittent":
        # 間欠障害: 30%の確率で遅延、20%の確率でエラー
        r = random.random()
        if r < 0.3:
            time.sleep(random.uniform(2.0, 5.0))
        elif r < 0.5:
            return jsonify({"error": "Connection refused"}), 503
    else:
        # 正常モード
        time.sleep(random.uniform(0.05, 0.15))

    return jsonify({
        "transaction_id": f"txn-{random.randint(10000, 99999)}",
        "amount": data.get("amount", 0),
        "status": "charged",
        "failure_mode": FAILURE_MODE
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002)
PYTHON_EOF

# --- 注文サービス（サーキットブレーカー付き） ---
cat > order-service/app.py << 'PYTHON_EOF'
from flask import Flask, jsonify, request
import requests
import time
import threading

app = Flask(__name__)

INVENTORY_URL = "http://inventory-service:5001"
PAYMENT_URL = "http://payment-service:5002"

# === 簡易サーキットブレーカーの実装 ===
class CircuitBreaker:
    """
    サーキットブレーカーパターンの簡易実装。
    3つの状態: CLOSED（正常）→ OPEN（遮断）→ HALF_OPEN（半開）
    """
    CLOSED = "CLOSED"
    OPEN = "OPEN"
    HALF_OPEN = "HALF_OPEN"

    def __init__(self, name, failure_threshold=3, recovery_timeout=10):
        self.name = name
        self.state = self.CLOSED
        self.failure_count = 0
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.last_failure_time = 0
        self.success_count = 0
        self.lock = threading.Lock()

    def call(self, func, *args, **kwargs):
        with self.lock:
            if self.state == self.OPEN:
                if time.time() - self.last_failure_time > self.recovery_timeout:
                    self.state = self.HALF_OPEN
                    self.success_count = 0
                    print(f"[CB:{self.name}] OPEN -> HALF_OPEN")
                else:
                    raise CircuitOpenError(
                        f"Circuit {self.name} is OPEN. "
                        f"Retry after {self.recovery_timeout}s"
                    )

        try:
            result = func(*args, **kwargs)
            with self.lock:
                if self.state == self.HALF_OPEN:
                    self.success_count += 1
                    if self.success_count >= 2:
                        self.state = self.CLOSED
                        self.failure_count = 0
                        print(f"[CB:{self.name}] HALF_OPEN -> CLOSED")
                else:
                    self.failure_count = 0
            return result
        except Exception as e:
            with self.lock:
                self.failure_count += 1
                self.last_failure_time = time.time()
                if self.failure_count >= self.failure_threshold:
                    self.state = self.OPEN
                    print(f"[CB:{self.name}] -> OPEN "
                          f"(failures: {self.failure_count})")
            raise

    def get_status(self):
        return {
            "name": self.name,
            "state": self.state,
            "failure_count": self.failure_count,
            "failure_threshold": self.failure_threshold,
        }

class CircuitOpenError(Exception):
    pass

# サーキットブレーカーのインスタンス
payment_cb = CircuitBreaker("payment", failure_threshold=3, recovery_timeout=15)
inventory_cb = CircuitBreaker("inventory", failure_threshold=3, recovery_timeout=15)

def call_inventory(item_id):
    """在庫サービスを呼び出す。"""
    resp = requests.get(f"{INVENTORY_URL}/check/{item_id}", timeout=2)
    resp.raise_for_status()
    return resp.json()

def call_payment(amount):
    """決済サービスを呼び出す。"""
    resp = requests.post(
        f"{PAYMENT_URL}/charge",
        json={"amount": amount},
        timeout=2
    )
    resp.raise_for_status()
    return resp.json()

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy", "service": "order"})

@app.route("/circuit-status", methods=["GET"])
def circuit_status():
    """サーキットブレーカーの状態を確認する。"""
    return jsonify({
        "payment": payment_cb.get_status(),
        "inventory": inventory_cb.get_status(),
    })

@app.route("/order", methods=["POST"])
def create_order():
    """
    注文を作成する。在庫確認→決済の順に呼び出す。
    各呼び出しにサーキットブレーカーを適用。
    """
    data = request.json or {}
    item_id = data.get("item_id", "item-001")
    amount = data.get("amount", 1000)
    start = time.time()

    result = {"item_id": item_id, "steps": []}

    # Step 1: 在庫確認（サーキットブレーカー経由）
    try:
        inv = inventory_cb.call(call_inventory, item_id)
        result["steps"].append({
            "step": "inventory_check",
            "status": "success",
            "data": inv
        })
    except CircuitOpenError as e:
        result["steps"].append({
            "step": "inventory_check",
            "status": "circuit_open",
            "error": str(e)
        })
        result["status"] = "failed"
        result["error"] = "Inventory service circuit is open"
        result["elapsed_ms"] = round((time.time() - start) * 1000, 1)
        return jsonify(result), 503
    except Exception as e:
        result["steps"].append({
            "step": "inventory_check",
            "status": "error",
            "error": str(e)
        })
        result["status"] = "failed"
        result["elapsed_ms"] = round((time.time() - start) * 1000, 1)
        return jsonify(result), 500

    # Step 2: 決済処理（サーキットブレーカー経由）
    try:
        pay = payment_cb.call(call_payment, amount)
        result["steps"].append({
            "step": "payment",
            "status": "success",
            "data": pay
        })
    except CircuitOpenError as e:
        result["steps"].append({
            "step": "payment",
            "status": "circuit_open",
            "error": str(e)
        })
        result["status"] = "failed"
        result["error"] = "Payment service circuit is open"
        result["elapsed_ms"] = round((time.time() - start) * 1000, 1)
        return jsonify(result), 503
    except Exception as e:
        result["steps"].append({
            "step": "payment",
            "status": "error",
            "error": str(e)
        })
        # 補償トランザクション: 在庫の戻しが必要
        result["steps"].append({
            "step": "compensation",
            "action": "inventory_release_needed",
            "note": "在庫の確保を取り消す必要がある"
        })
        result["status"] = "failed"
        result["elapsed_ms"] = round((time.time() - start) * 1000, 1)
        return jsonify(result), 500

    result["status"] = "success"
    result["elapsed_ms"] = round((time.time() - start) * 1000, 1)
    return jsonify(result), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PYTHON_EOF

# --- 共通のrequirements.txt ---
cat > requirements.txt << 'EOF'
flask==3.1.0
requests==2.32.3
EOF

# --- Dockerfile（全サービス共通） ---
cat > Dockerfile << 'DOCKERFILE_EOF'
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
DOCKERFILE_EOF

# --- docker-compose.yml ---
cat > docker-compose.yml << 'COMPOSE_EOF'
services:
  inventory-service:
    build:
      context: .
      dockerfile: Dockerfile
    command: python inventory-service/app.py
    ports:
      - "5001:5001"

  payment-service:
    build:
      context: .
      dockerfile: Dockerfile
    command: python payment-service/app.py
    ports:
      - "5002:5002"
    environment:
      - FAILURE_MODE=none

  order-service:
    build:
      context: .
      dockerfile: Dockerfile
    command: python order-service/app.py
    ports:
      - "5000:5000"
    depends_on:
      - inventory-service
      - payment-service
COMPOSE_EOF

echo "=== サービスの起動 ==="
docker compose build
docker compose up -d
echo "サービスの起動を待機中..."
sleep 10

echo ""
echo "=== 正常系: 注文リクエスト ==="
curl -s -X POST http://localhost:5000/order \
  -H "Content-Type: application/json" \
  -d '{"item_id": "item-001", "amount": 1500}' | python3 -m json.tool

echo ""
echo "考察:"
echo "- 注文サービスが在庫サービスと決済サービスを順に呼び出す"
echo "- 各サービスはHTTPで通信（ネットワーク越しの呼び出し）"
echo "- elapsed_msを確認: モノリスなら<1msの処理が数十ms〜数百msかかる"
echo "- これがマイクロサービスの「ネットワーク越しの呼び出しコスト」"
```

### 演習2：カスケード障害とサーキットブレーカーの体験

```bash
echo "=========================================="
echo "演習2: カスケード障害とサーキットブレーカー"
echo "=========================================="

cd "${HOME}/cloud-history-handson-19"

echo "=== 決済サービスを障害モードに切り替え ==="
# 決済サービスをエラーモード（70%の確率で500エラー）で再起動
docker compose stop payment-service
FAILURE_MODE=error docker compose up -d payment-service
sleep 5

echo ""
echo "=== サーキットブレーカーの状態（初期） ==="
curl -s http://localhost:5000/circuit-status | python3 -m json.tool

echo ""
echo "=== 障害中のリクエスト（5回連続） ==="
for i in $(seq 1 5); do
  echo "--- リクエスト #${i} ---"
  curl -s -X POST http://localhost:5000/order \
    -H "Content-Type: application/json" \
    -d '{"item_id": "item-001", "amount": 1500}' | python3 -m json.tool
  sleep 1
done

echo ""
echo "=== サーキットブレーカーの状態（障害後） ==="
curl -s http://localhost:5000/circuit-status | python3 -m json.tool

echo ""
echo "考察:"
echo "- 決済サービスが70%の確率でエラーを返す"
echo "- 失敗が3回（failure_threshold）に達すると"
echo "  サーキットブレーカーがOPEN状態になる"
echo "- OPEN状態では決済サービスを呼び出さず、即座にエラーを返す"
echo "  → タイムアウト待ちによるスレッド枯渇を防止"
echo "  → カスケード障害を食い止める"

echo ""
echo "=== 15秒後にHALF-OPEN状態への遷移を確認 ==="
echo "(recovery_timeout=15秒)"
sleep 16

echo ""
echo "=== HALF-OPEN状態のリクエスト ==="
curl -s -X POST http://localhost:5000/order \
  -H "Content-Type: application/json" \
  -d '{"item_id": "item-001", "amount": 1500}' | python3 -m json.tool

echo ""
echo "=== 決済サービスを正常モードに戻す ==="
docker compose stop payment-service
FAILURE_MODE=none docker compose up -d payment-service
sleep 5

echo ""
echo "=== 回復後のリクエスト ==="
for i in $(seq 1 3); do
  echo "--- リクエスト #${i} ---"
  curl -s -X POST http://localhost:5000/order \
    -H "Content-Type: application/json" \
    -d '{"item_id": "item-002", "amount": 800}' | python3 -m json.tool
  sleep 1
done

echo ""
echo "=== 最終的なサーキットブレーカーの状態 ==="
curl -s http://localhost:5000/circuit-status | python3 -m json.tool

echo ""
echo "考察:"
echo "- HALF-OPEN状態で2回成功すると、CLOSEDに戻る"
echo "- サーキットブレーカーが自動的に障害を検出し、回復を確認する"
echo "- 人間の介入なしに、システムが自律的に回復する設計"
echo ""
echo "=== クリーンアップ ==="
echo "docker compose down で全サービスを停止できます"
echo "rm -rf ${HOME}/cloud-history-handson-19 で作業ディレクトリを削除できます"
```

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/19-microservices-cloud/` に用意してある。

---

## 7. まとめと次回予告

### この回のまとめ

第19回では、マイクロサービスとクラウドの相互依存関係を歴史的・技術的に読み解いた。

**マイクロサービスの思想は、2014年の定義以前から実践として存在していた。** 2002年頃、Jeff BezosはAmazon社内に「全チームはサービスインターフェースで通信せよ」というAPIマンデートを発した。この指令とTwo-Pizza Teamsの組織設計が、後のAWSの設計原則の基盤となった。SOAとESBの重厚長大さへの「SOA疲れ」が、軽量なサービス分割への欲求を生み出した。

**Netflixの2008年データベース破損事件は、マイクロサービスの最も有名な成功事例の出発点だった。** 7年をかけて700以上のマイクロサービスに分割し、2016年に最後のデータセンターを閉鎖した。その過程でオープンソース化されたHystrix、Eureka、Zuulは、世界中のマイクロサービス実践者の共通基盤となった。

**2014年3月25日、James LewisとMartin Fowlerが「Microservices」記事を公開し、9つの特徴で定義を確立した。** だがFowler自身が翌年「MonolithFirst」で警告を発した。「成功したマイクロサービスのほぼすべてが、大きくなりすぎたモノリスから始まった」。適切なサービス境界を最初から見極めることは、経験豊富なアーキテクトにとっても困難だ。

**マイクロサービスの技術的課題に対して、エコシステムは急速に進化した。** サーキットブレーカー（Hystrix 2012年→Resilience4j）、分散トレーシング（Zipkin 2012年→Jaeger 2017年→OpenTelemetry 2019年）、Service Mesh（Istio 2017年）。だがこれらの解法自体が、マイクロサービスが導入する複雑性の証左でもある。

**マイクロサービスはクラウドを前提とする。** 動的なサービスディスカバリ、独立したデプロイ、弾力的なスケーリング、障害ドメインの分離——これらの要件はクラウドの能力なしには実現が困難だ。そして分散システムの「8つの誤謬」が容赦なく襲いかかる。ネットワーク越しの呼び出しは、関数呼び出しとは根本的に異なる。

冒頭の問いに答えよう。マイクロサービスはクラウドの約束を実現するアーキテクチャなのか、それとも分散システムの複雑性という代償を払わせるものなのか。答えは「両方」だ。マイクロサービスは、独立したデプロイ、チームの自律性、スケーリングの柔軟性というクラウドの利点を最大限に引き出す。同時に、サービス間通信のレイテンシ、分散トランザクションの複雑性、可観測性の困難さという代償を課す。

「マイクロサービスは組織の問題を解決する。技術の問題は増やす」——私のこの結論は、数年間の実践を経て、今も変わっていない。だからこそ重要なのは、モノリスが悪いわけでもマイクロサービスが正義なわけでもなく、自分の組織とシステムの状況に応じた適切な判断を下す能力だ。

### 次回予告

第20回では、「CDN、エッジコンピューティング——計算を『ユーザーの近く』に持っていく」を取り上げる。

メインフレームの集中処理から、クライアント/サーバの分散、クラウドの再集中を経て、今度は計算が再びユーザーの近くに移動し始めている。Akamai（1998年）に始まるCDNの歴史から、Cloudflare Workers（2017年）やLambda@Edge（2017年）に至るエッジコンピューティングの系譜を辿る。「計算する場所」の最適解は、時代の技術的制約によって変わり続ける。その揺り戻しの構造を、次回で語る。

---

## 参考文献

- James Lewis, Martin Fowler, "Microservices", martinfowler.com, March 25, 2014. <https://martinfowler.com/articles/microservices.html>
- Martin Fowler, "MonolithFirst", martinfowler.com, June 3, 2015. <https://martinfowler.com/bliki/MonolithFirst.html>
- Steve Yegge, "Stevey's Google Platforms Rant", October 2011. (Original Google+ post, widely archived)
- Netflix, "Completing the Netflix Cloud Migration", About Netflix, January 2016. <http://about.netflix.com/en/news/completing-the-netflix-cloud-migration>
- Netflix/Hystrix, GitHub Repository. <https://github.com/Netflix/Hystrix>
- InfoQ, "Netflix Hystrix – Latency and Fault Tolerance for Complex Distributed Systems", December 2012. <https://www.infoq.com/news/2012/12/netflix-hystrix-fault-tolerance/>
- Resilience4j, GitHub Repository. <https://github.com/resilience4j/resilience4j>
- Twitter Engineering, "Distributed Systems Tracing with Zipkin", June 2012. <https://blog.twitter.com/engineering/en_us/a/2012/distributed-systems-tracing-with-zipkin>
- Jaeger, Official Website. <https://www.jaegertracing.io/>
- Microsoft Open Source Blog, "Announcing OpenTelemetry: the merger of OpenCensus and OpenTracing", May 23, 2019. <https://opensource.microsoft.com/blog/2019/05/23/announcing-opentelemetry-cncf-merged-opencensus-opentracing>
- CNCF, "A brief history of OpenTelemetry (So Far)", May 21, 2019. <https://www.cncf.io/blog/2019/05/21/a-brief-history-of-opentelemetry-so-far/>
- Istio, "Introducing Istio", May 2017. <https://istio.io/latest/news/releases/0.x/announcing-0.1/>
- AWS Executive Insights, "Amazon's Two Pizza Team". <https://aws.amazon.com/executive-insights/content/amazon-two-pizza-team/>
- Michael Nygard, "Release It!", Pragmatic Bookshelf, 2007.
- Peter Deutsch, "The Eight Fallacies of Distributed Computing", Sun Microsystems, 1994.
- Melvin Conway, "How Do Committees Invent?", Datamation, April 1968.
