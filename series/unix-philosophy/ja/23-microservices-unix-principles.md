# UNIXという思想

## ――パイプ、プロセス、ファイル――すべてはここから始まった

### 第23回：「マイクロサービスとUNIX原則――思想の転生」

**連載「UNIXという思想――パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- マイクロサービスアーキテクチャの歴史的起源と、SOA（Service-Oriented Architecture）からの進化
- UNIX哲学とマイクロサービス原則の構造的なアナロジー――「一つのことをうまくやれ」からSingle Responsibilityへ
- Conway's Law（1968年）が現代のチーム構造とサービス分割に与えた影響
- Jeff Bezos API Mandate（2002年頃）とNetflixの移行（2009年〜）が示した実践知
- UNIXのローカルパイプラインと分散マイクロサービスの決定的な違い――ネットワークは信頼できない
- 12-Factor App（2011年）がUNIX哲学の精神をクラウドネイティブに翻訳した方法

---

## 1. 30年越しの既視感

2018年のある日、私はあるプロジェクトの設計レビューに参加していた。大規模なモノリシック・アプリケーションをマイクロサービスに分割するという、当時流行りの——そして今振り返れば安易でもあった——方針が決まった後の、サービス境界の議論だ。

ホワイトボードには十数個の箱が描かれていた。「認証サービス」「ユーザプロファイルサービス」「通知サービス」「決済サービス」。それぞれの箱の間をAPI呼び出しの矢印が結んでいる。若いアーキテクトが説明する。「各サービスは一つの責務だけを持ちます。サービス間はREST APIで疎結合に接続します。データベースはサービスごとに分離します。」

私は既視感に襲われた。

この設計原則を、私は30年近く前に別の文脈で学んでいた。1990年代後半、Slackwareの黒い画面の前で。

「一つのプログラムは一つのことをうまくやれ」「プログラムは協調して動くように作れ」「テキストストリームを共通のインタフェースにせよ」——Doug McIlroyが1978年に定式化したUNIX哲学の三原則だ。

ホワイトボードの箱を眺めながら、私の頭の中ではUNIXコマンドのパイプラインが重なっていた。`grep`は検索だけをやる。`sort`はソートだけをやる。`wc`はカウントだけをやる。それぞれが一つのことをうまくやり、パイプで組み合わせることで複雑な処理を実現する。この設計原則が、半世紀の時を超えて、分散システムの設計原則として「再発明」されている。

だが同時に、決定的な違いも感じていた。UNIXのパイプは同一マシン上で動く。カーネルが保証するプロセス間通信だ。パイプの中のデータが消失することはない。プロセスの起動は数ミリ秒で終わる。ところがマイクロサービスはネットワーク越しに通信する。パケットは消える。レイテンシは予測できない。サービスは突然死ぬ。

マイクロサービスアーキテクチャはUNIX哲学の「転生」なのか。それとも、表面的な類似に過ぎない別の思想なのか。

---

## 2. モノリスからサービスへ――分割の歴史

### SOAの野心と挫折

マイクロサービスの前史を語るには、SOA（Service-Oriented Architecture）に触れなければならない。

2000年代、SOAがエンタープライズ・ソフトウェアの世界を席巻した。SOAP（Simple Object Access Protocol）は1998年にMicrosoft、DevelopMentor、UserLand Softwareによって提案され、2000年5月8日にW3C Noteとしてバージョン1.1が公開された。WSDL（Web Services Description Language）バージョン1.1は2001年3月15日にW3C Noteとして発行された。ESB（Enterprise Service Bus）がサービス間の通信を仲介し、BPEL（Business Process Execution Language）がサービスのオーケストレーションを記述する。

SOAの思想自体は健全だった。「ビジネス機能をサービスとして公開し、再利用可能にする」。これはUNIX哲学の「小さなプログラムを組み合わせて大きな仕事をする」と通底する発想だ。

だが現実のSOAは、思想とは裏腹に肥大化した。WSDLの定義ファイルは数千行に膨れ上がり、SOAPメッセージのXMLエンベロープはペイロードの何倍もの大きさになった。ESBは「インテリジェントなパイプ」として中央集権的なルーティング、変換、オーケストレーションを担い、やがてESB自体がシステムのボトルネックかつ単一障害点になった。

```
SOAの典型的な構成:

[サービスA] ─→ ┌──────────────────────────────────┐ ─→ [サービスB]
[サービスC] ─→ │   ESB（Enterprise Service Bus）  │ ─→ [サービスD]
[サービスE] ─→ │  ルーティング/変換/オーケストレーション  │ ─→ [サービスF]
               └──────────────────────────────────┘

問題:
- ESBが単一障害点
- ESBに業務ロジックが集中（「賢いパイプ」問題）
- WSDLによる強い結合
- XMLの冗長さ
```

UNIXの思想に立ち返って考えれば、SOAの失敗の本質は明確だ。UNIXのパイプは「愚かな」パイプだ。データをバイトストリームとして左から右に流すだけで、データの解釈や変換は行わない。知性はパイプの両端にある——つまり個々のコマンドにある。SOAのESBは、この原則を逆転させた。パイプ自体を「賢く」し、サービス間の結合をパイプの中に押し込んだ。その結果、パイプが複雑化し、サービスの独立性が損なわれた。

### Jeff Bezos API Mandate――あるいは「独裁者の慧眼」

SOAが肥大化の道を辿っていた2002年頃、AmazonのJeff Bezosは社内に一つの指令を発した。

この指令の存在が広く知られるようになったのは、2011年10月にGoogleのエンジニアSteve Yeggeが誤って公開した社内メモ——通称「Stevey's Google Platforms Rant」——によってだ。YeggeはかつてのAmazonでの経験を回想し、Bezosの指令を次のように要約した。

1. すべてのチームは、データと機能をサービスインタフェースを通じて公開すること
2. チーム間の通信は、これらのインタフェースを通じて行うこと
3. 直接リンク、他チームのデータストアの直接読み取り、共有メモリモデル、バックドアなど、いかなるプロセス間通信も禁止
4. すべてのサービスインタフェースは、例外なく、外部公開可能に設計すること
5. これに従わない者は解雇する

Yeggeは「Bezosは正気ではないほど間違ったことをたくさんやるが、この点に関しては決定的に正しかった」と述べている。

Bezosの指令は、UNIX哲学を組織設計のレベルに引き上げたものと読める。UNIXでは、プロセスは他のプロセスのメモリ空間に直接アクセスできない。プロセス間の通信はファイルディスクリプタ——パイプ、ソケット、ファイル——を通じて行われる。Bezosは、組織における「チーム」をUNIXにおける「プロセス」に見立て、チーム間の通信をサービスインタフェースに限定した。

この指令の結果、Amazonは社内のあらゆるシステムをサービスとして再構築した。そしてその副産物として、社内で使っていたインフラ——コンピュート、ストレージ、データベース——を外部に提供するサービスが生まれた。Amazon Web Services（AWS）だ。2006年に正式サービスを開始したAWSは、「すべてをサービスインタフェースで公開せよ」という指令の最も壮大な帰結である。

### Netflixの「大移動」

Amazonが社内のサービス化を進めていた頃、もう一つの企業がモノリスからマイクロサービスへの移行を象徴する事例を作りつつあった。

2008年、Netflixはデータベース破損による3日間のサービス停止を経験した。単一のJavaモノリスがOracle Database上で動き、DVDレンタルとストリーミングの両方を処理していた。この事件が、Netflixのアーキテクチャを根本から変える契機となった。

2009年、NetflixはAWSクラウドベースのマイクロサービスアーキテクチャへの移行を開始した。「microservices」という用語がまだ存在しない時期だ。この移行は約7年を要し、最終的に700以上のマイクロサービスに分割された。

Netflixの移行が注目に値するのは、単にモノリスを分割しただけでなく、分散システムの困難に正面から向き合ったことだ。2011年、Netflixは「Chaos Monkey」を開発した。本番環境でランダムにサービスインスタンスを停止させるツールだ。「障害は起きないもの」ではなく「障害は必然」という前提で設計する。この発想は、UNIXの堅牢性の哲学——「プログラムは不意の入力を優雅に処理すべきだ」——の分散システム版と言える。

2012年、Chaos MonkeyはApache 2.0ライセンスでオープンソース化された。Netflixはその後もSimian Armyと呼ばれるツール群を展開し、様々な障害シナリオをテストする「Chaos Engineering」という分野を事実上創出した。

### 「Microservices」の定義

2014年3月25日、Martin FowlerとJames Lewisが「Microservices: A Definition of This New Architectural Term」と題する記事を martinfowler.com に公開した。

この記事は、既にNetflixやAmazonが実践していた——そして名前がなかった——アーキテクチャスタイルに、明確な定義を与えた。FowlerとLewisは、マイクロサービスアーキテクチャの特徴を以下のように整理した。

- **サービスによるコンポーネント化（Componentization via Services）**
- **ビジネス機能に基づく組織化（Organized around Business Capabilities）**
- **プロジェクトではなくプロダクト（Products not Projects）**
- **賢いエンドポイントと愚かなパイプ（Smart endpoints and dumb pipes）**
- **分散ガバナンス（Decentralized Governance）**
- **分散データ管理（Decentralized Data Management）**
- **インフラ自動化（Infrastructure Automation）**
- **障害を前提とした設計（Design for failure）**
- **進化的設計（Evolutionary Design）**

この中で「Smart endpoints and dumb pipes（賢いエンドポイントと愚かなパイプ）」は、SOAのESBモデルに対する明示的なアンチテーゼであり、同時にUNIX哲学のパイプモデルへの回帰でもある。

FowlerとLewisは記事の中でこう書いている——マイクロサービスのコミュニティは、軽量なメッセージングインフラを好む。この「軽量」と「賢いエンドポイント、愚かなパイプ」の組み合わせは、UNIXのパイプライン設計と驚くほど一致する。

「microservices」という用語自体の起源は、2011年5月のヴェネツィア近郊で開催されたソフトウェアアーキテクト・ワークショップに遡る。参加者たちが共通して実践していたアーキテクチャスタイルを表す言葉として議論され、2012年5月に同グループが「microservices」を名称として正式に採用した。James Lewisは2012年3月、Krakowの33rd Degreeカンファレンスで「Microservices - Java, the Unix Way」と題して発表している。タイトルに「the Unix Way」が入っていることに注目してほしい。マイクロサービスの初期の実践者たちは、自らの設計原則がUNIX哲学と重なることを明確に意識していた。

---

## 3. 構造的アナロジー――UNIXパイプラインとマイクロサービス

### 四つの対応関係

UNIX哲学とマイクロサービスの間には、表面的な類似を超えた構造的な対応関係がある。

```
UNIX哲学                          マイクロサービス原則
─────────────────────────────    ─────────────────────────────────
(1) "Do one thing well"         → Single Responsibility Principle
    一つのことをうまくやれ           一つのサービスは一つの責務

(2) パイプ（pipe）               → API / メッセージキュー
    プロセス間のデータ転送           サービス間のデータ転送

(3) テキストストリーム            → JSON / gRPC / Protocol Buffers
    万能インタフェース               標準化されたデータフォーマット

(4) stdin/stdout/stderr         → HTTP/REST / イベント / ログ
    標準化された入出力               標準化されたプロトコル
```

一つずつ掘り下げる。

**（1）「一つのことをうまくやれ」→ Single Responsibility**

Doug McIlroyの「Make each program do one thing well」は、マイクロサービスの「各サービスは一つのビジネス機能に対応する」と直接的に対応する。

UNIXの`grep`は検索だけをやる。ソートはしない。カウントもしない。出力のフォーマットも最小限だ。マイクロサービスの「認証サービス」は認証だけをやる。ユーザプロファイルの管理はしない。通知の送信もしない。

この原則の本質は「境界の設定」にある。何をやるかを定義することは、同時に何をやらないかを定義することだ。UNIXコマンドの設計者は「このコマンドの責務はここまで」という線を引く判断を繰り返し行った。マイクロサービスのアーキテクトは「このサービスの境界はここまで」という同じ判断を、ビジネスドメインのレベルで行う。

**（2）パイプ → API / メッセージキュー**

UNIXのパイプは、1973年にKen ThompsonがDoug McIlroyのアイデアを一晩で実装した。プロセスAの標準出力をプロセスBの標準入力に接続する。データはバイトストリームとして流れ、パイプ自体はデータの内容に関知しない——「愚かなパイプ」だ。

マイクロサービスのAPI呼び出しやメッセージキューは、このパイプの役割を担う。REST APIはHTTPプロトコルの上でJSONを運ぶ。gRPCはHTTP/2の上でProtocol Buffersを運ぶ。Apache Kafka（2011年、LinkedInのJay Krepsらが開発し、オープンソース化）のようなメッセージキューは、サービス間の非同期通信を仲介する。

FowlerとLewisが強調した「Smart endpoints and dumb pipes」は、まさにこの対応を指している。SOAのESBが「賢いパイプ」として失敗した教訓から、マイクロサービスはUNIXのパイプモデル——パイプは愚かに、知性はエンドポイントに——に回帰した。

**（3）テキストストリーム → JSON / gRPC**

UNIXのテキストストリームは、プロセス間の「万能インタフェース」だった。どのコマンドもテキストを入力として受け取り、テキストを出力する。この共通のデータフォーマットが、コマンドの自由な組み合わせを可能にした。

前回の第22回で論じたとおり、テキストストリームには「型がない」という根本的な限界がある。マイクロサービスの世界では、JSON、gRPC（Protocol Buffers）、GraphQLといった構造化されたデータフォーマットがこの役割を担う。

```
UNIXのテキストストリーム:
  user:x:1000:1000:John Doe:/home/john:/bin/bash

→ フィールドの意味は暗黙知。パーサは自前で書く。

マイクロサービスのJSON:
  {"id": 1000, "name": "John Doe", "home": "/home/john", "shell": "/bin/bash"}

→ フィールド名で意味が明示。型情報は部分的。

マイクロサービスのProtocol Buffers:
  message User {
    int32 id = 1;
    string name = 2;
    string home = 3;
    string shell = 4;
  }

→ フィールド名、型、シリアライゼーション順序が明示的に定義。
```

Googleは2001年頃から社内で「Stubby」というRPCフレームワークを使い、Protocol Buffersでサービス間の通信を定義していた。2015年2月、Googleはこの仕組みをgRPCとしてオープンソース化した。テキストストリームの「万能性」をスキーマ定義による「型安全性」に置き換えたのだ。

**（4）stdin/stdout/stderr → HTTP/REST / イベント / ログ**

UNIXのプロセスは三つの標準ストリームを持つ。標準入力（stdin、ファイルディスクリプタ0）、標準出力（stdout、同1）、標準エラー出力（stderr、同2）。この三つのチャネルが標準化されていることで、プロセスは他のプロセスの実装詳細を知らなくても連携できる。

マイクロサービスの世界では、HTTP/RESTが同期的な通信の標準プロトコルとなり、イベントバス（Kafka、RabbitMQ等）が非同期通信の標準チャネルとなった。ログは構造化ログ（JSON形式）として標準化され、分散トレーシング（OpenTelemetry等）がサービスをまたいだ処理の追跡を可能にしている。

### Conway's Law――組織が設計を決める

UNIX哲学とマイクロサービスの対応関係を考えるとき、もう一つ無視できない原則がある。Conway's Lawだ。

1968年、Melvin Conwayが「How Do Committees Invent?」をDatamation誌に発表した。Conwayの主張は、後にFred Brooksが『The Mythical Man-Month』（1975年）で「Conway's Law」と命名し、広く知られるようになった。

> 「システムを設計する組織は、その組織のコミュニケーション構造のコピーである設計を生み出す」

UNIXは少人数のチーム——Ken Thompson、Dennis Ritchie、Doug McIlroy、そしてBell Labsの研究者たち——によって設計された。各人が独立してツールを開発し、パイプで組み合わせた。小さな独立したプログラムの集合体というUNIXの設計は、Bell Labsの小さく独立した研究チームの構造を反映している。

マイクロサービスでも同じ原則が働く。Amazonの「Two-Pizza Team」——二枚のピザで全員が食べられる規模のチーム——は、各チームが独立したサービスを所有・運用する。チームの境界がサービスの境界になる。Conway's Lawをマイクロサービスに意図的に適用したのだ。

FowlerとLewisはこの点を明確に認識していた。マイクロサービスの「Organized around Business Capabilities」という原則は、Conway's Lawを逆手に取る戦略だ。技術レイヤーではなくビジネス機能でチームを組織すれば、サービスの境界はビジネス機能の境界と一致する。これを「Inverse Conway Maneuver（逆コンウェイ作戦）」と呼ぶ者もいる。

### 12-Factor App――UNIX哲学のクラウドネイティブ翻訳

2011年、Heroku共同創業者のAdam Wigginsが「The Twelve-Factor App」を12factor.netで公開した。Herokuは2007年の設立以来、数百の顧客アプリケーションをPaaS（Platform as a Service）上でホストしてきた。成功するアプリケーションに共通するパターンと、問題を起こすアプリケーションに共通するアンチパターンを体系化したのが12-Factor Appだ。

12の原則のうち、UNIX哲学との対応が特に明確なものがいくつかある。

```
12-Factor App                    UNIX哲学との対応
──────────────────────────────  ──────────────────────────────
III.  設定は環境変数に格納        環境変数はUNIXの基本的な構成手段
VI.   プロセスはステートレス       フィルタモデルのステートレス性
VII.  ポートバインディング         ソケットはUNIXのIPC機構
VIII. 並行性はプロセスモデルで     UNIXのfork/execモデル
XI.   ログはイベントストリーム     stdout/stderrへのストリーム出力
```

特に「XI. ログはイベントストリームとして扱え」は、UNIX哲学の直接的な翻訳だ。12-Factor Appは「アプリケーションはログファイルへの書き込みや管理を行わない。各プロセスは標準出力（stdout）にイベントストリームをバッファなしで書き出す」と規定している。ログの収集・ルーティング・保存は、アプリケーションの外部——実行環境——が担う。これはUNIXの「コマンドはstdoutに出力し、出力先の管理はシェルやパイプに委ねる」というモデルそのものだ。

---

## 4. 決定的な違い――ネットワークは信頼できない

### パイプとAPIの間に横たわる深淵

ここまでUNIX哲学とマイクロサービスの構造的アナロジーを語ってきた。だが、両者の間には決定的な違いがある。その違いを理解しなければ、アナロジーは危険な誤解に変わる。

UNIXのパイプは同一マシン上で動く。カーネルがプロセス間のデータ転送を保証する。パイプに書き込まれたバイトは、必ず相手に届く。順序は保たれる。遅延はナノ秒からマイクロ秒のオーダーだ。プロセスが死ねば、パイプはSIGPIPEシグナルで即座に通知される。

マイクロサービスのAPIは、ネットワーク越しに通信する。そしてネットワークは信頼できない。

1994年頃、Sun MicrosystemsのL. Peter Deutschらは「分散コンピューティングの8つの誤謬（Fallacies of Distributed Computing）」をまとめた。

```
分散コンピューティングの8つの誤謬:

1. ネットワークは信頼できる           → パケットは消失する
2. レイテンシはゼロである             → 通信には時間がかかる
3. 帯域幅は無限である               → データ量には上限がある
4. ネットワークは安全である           → 盗聴・改竄のリスクがある
5. トポロジは変化しない              → ノードは追加・削除される
6. 管理者は一人である               → 複数の管理ドメインが存在する
7. トランスポートコストはゼロである     → 通信にはコストがかかる
8. ネットワークは均質である           → 異なるプロトコル・実装が混在する
```

UNIXのパイプラインでは、これらの「誤謬」のほとんどが実際に成り立つ。カーネル内のパイプは信頼でき、レイテンシはほぼゼロで、帯域幅は実質的に無限（メモリ帯域に律速される）で、セキュリティはプロセスの権限分離で保証される。

マイクロサービスでは、8つすべてが誤謬として機能する。

```
UNIXパイプ vs マイクロサービス通信:

                     UNIXパイプ          マイクロサービス
─────────────────  ──────────────────  ─────────────────────
通信路             カーネル内パイプ      ネットワーク（TCP/IP）
レイテンシ          μs〜ms              ms〜s（ネットワーク依存）
信頼性             カーネル保証          パケット損失あり
順序保証            あり（FIFO）         プロトコル依存
障害検知            SIGPIPE即時通知       タイムアウト依存
障害の粒度          プロセス単位          サービス+ネットワーク
データフォーマット    バイトストリーム       JSON/gRPC/etc.
状態共有            なし（独立プロセス）   なし（独立サービス）
```

この差異は、アナロジーの限界を示している。

### CAP定理――分散システムの不可能性定理

2000年、カリフォルニア大学バークレー校のEric BrewerがACM Symposium on Principles of Distributed Computing（PODC）の基調講演で一つの推測を提示した。分散データストアは、一貫性（Consistency）、可用性（Availability）、分断耐性（Partition Tolerance）の三つの性質のうち、同時に二つまでしか保証できない。

2002年、MITのSeth GilbertとNancy Lynchがこの推測を形式的に証明し、CAP定理となった。

UNIXのパイプラインは単一マシン上で動く。ネットワーク分断（Partition）は発生しない。だからCAP定理の制約を受けない。一貫性と可用性の両方を享受できる。

マイクロサービスはネットワーク越しに動く。ネットワーク分断は「起きるかどうか」ではなく「いつ起きるか」の問題だ。したがって分断耐性は必須であり、設計者は一貫性と可用性のどちらを優先するかを選択しなければならない。

この制約は、UNIXのパイプラインには存在しなかった根本的な困難だ。UNIXの`cat file | grep pattern | wc -l`では、grepがデータの一部しか受け取っていないかもしれない、という心配をする必要はない。マイクロサービスでは、認証サービスへのリクエストがタイムアウトしたとき——リクエストが到達しなかったのか、処理中なのか、レスポンスが返る途中で消えたのか——を判別することはできない。

### 「分散モノリス」という罠

マイクロサービスへの移行で最も陥りやすい罠が「分散モノリス（Distributed Monolith）」だ。

サービスを物理的に分割しても、論理的に密結合していれば、モノリスの欠点——変更の連鎖的影響、独立デプロイの不可能——はそのまま残り、さらに分散システムの複雑さ——ネットワーク遅延、部分障害、分散トランザクション——が加わる。モノリスの欠点とマイクロサービスの欠点を同時に抱え込み、どちらの利点も得られない。

```
分散モノリスの症状:

1. 同期的な連鎖呼び出し
   サービスA → サービスB → サービスC → サービスD
   → Dが遅延するとA〜C全体が遅延する
   → Dが障害を起こすとA〜C全体が障害になる

2. 共有データベース
   サービスA ─┐
   サービスB ─┼── [共有DB]
   サービスC ─┘
   → スキーマ変更が全サービスに影響する
   → 独立デプロイが不可能

3. 同時デプロイの必要性
   サービスAの変更 → サービスBも同時にデプロイ必須
   → 結局モノリスと同じリリースサイクル
```

UNIXの世界では、この種の問題は起きにくい。`grep`のインタフェース（テキストの行を受け取り、マッチした行を出力する）は、40年以上変わっていない。`sort`の実装が変わっても、`grep`は影響を受けない。テキストストリームという「愚かな」インタフェースが、コマンド間の独立性を保っている。

マイクロサービスで同じ独立性を実現するには、意識的な設計が必要だ。サービスのAPIのバージョニング、後方互換性の維持、非同期通信の採用、サーキットブレーカーパターン、イベント駆動アーキテクチャ——UNIXのパイプでは「ただそうなっていた」ことを、マイクロサービスでは意図的に設計しなければならない。

---

## 5. ハンズオン：UNIXパイプラインとマイクロサービスのアナロジーを体感する

UNIXパイプラインとマイクロサービスの構造的アナロジーを、同じデータ処理タスクを二つの方法で実装することで体感する。

### 環境構築

```bash
docker run -it --rm ubuntu:24.04 bash
apt-get update && apt-get install -y curl jq coreutils netcat-openbsd procps
```

### 演習1：UNIXパイプラインによるデータ処理

まず、UNIXの伝統的なパイプラインでデータ処理を行う。

```bash
# テストデータ: Webアクセスログ（簡易版）
mkdir -p /tmp/handson && cd /tmp/handson

cat > access.log << 'EOF'
2026-02-23T10:00:01 GET /api/users 200 45ms
2026-02-23T10:00:02 GET /api/products 200 120ms
2026-02-23T10:00:03 POST /api/orders 201 340ms
2026-02-23T10:00:04 GET /api/users 200 42ms
2026-02-23T10:00:05 GET /api/products 500 5ms
2026-02-23T10:00:06 GET /api/users 200 50ms
2026-02-23T10:00:07 POST /api/orders 201 280ms
2026-02-23T10:00:08 GET /api/products 200 115ms
2026-02-23T10:00:09 GET /api/users 404 3ms
2026-02-23T10:00:10 DELETE /api/orders/42 204 90ms
2026-02-23T10:00:11 GET /api/products 200 130ms
2026-02-23T10:00:12 POST /api/orders 500 2ms
EOF

echo "=== UNIXパイプライン: エンドポイント別リクエスト数 ==="
cat access.log | awk '{print $3}' | sort | uniq -c | sort -rn

echo ""
echo "=== UNIXパイプライン: ステータスコード500のリクエスト ==="
cat access.log | grep " 500 " | awk '{print $1, $2, $3}'

echo ""
echo "=== UNIXパイプライン: 平均レスポンスタイム（エンドポイント別） ==="
cat access.log | awk '{
  endpoint=$3;
  gsub(/ms/, "", $5);
  time=$5;
  sum[endpoint]+=time;
  count[endpoint]++;
}
END {
  for (e in sum) {
    printf "%s: %.1fms (%d requests)\n", e, sum[e]/count[e], count[e]
  }
}' | sort
```

各コマンドの責務は明確に分離されている。`cat`はファイルを読む。`awk`はフィールドを抽出・集計する。`sort`はソートする。`uniq -c`はカウントする。「一つのことをうまくやれ」の原則がパイプラインの中で機能している。

### 演習2：マイクロサービス的なアプローチ（シェルで模擬）

同じ処理を、マイクロサービスのアナロジーとして「独立したプロセス」に分割する。各プロセスはファイルベースのAPIで通信する。

```bash
cd /tmp/handson

# === サービス1: ログ収集サービス ===
# 生のログを読み取り、JSONに変換して出力する
cat > log_collector.sh << 'SCRIPT'
#!/bin/bash
# Log Collector Service: 生ログをJSONに変換
INPUT="$1"
while IFS=' ' read -r timestamp method endpoint status latency; do
    latency_num="${latency%ms}"
    printf '{"timestamp":"%s","method":"%s","endpoint":"%s","status":%s,"latency_ms":%s}\n' \
        "$timestamp" "$method" "$endpoint" "$status" "$latency_num"
done < "$INPUT"
SCRIPT
chmod +x log_collector.sh

# === サービス2: フィルタサービス ===
# 条件に基づいてリクエストをフィルタリング
cat > filter_service.sh << 'SCRIPT'
#!/bin/bash
# Filter Service: 条件に基づくフィルタリング
FIELD="$1"
VALUE="$2"
jq -c "select(.${FIELD} == ${VALUE})"
SCRIPT
chmod +x filter_service.sh

# === サービス3: 集計サービス ===
# エンドポイント別の統計を計算
cat > aggregator_service.sh << 'SCRIPT'
#!/bin/bash
# Aggregator Service: エンドポイント別集計
jq -s '
  group_by(.endpoint)
  | map({
      endpoint: .[0].endpoint,
      count: length,
      avg_latency_ms: (map(.latency_ms) | add / length),
      error_count: map(select(.status >= 500)) | length
    })
  | sort_by(-.count)
'
SCRIPT
chmod +x aggregator_service.sh

echo "=== マイクロサービス的パイプライン ==="
echo ""
echo "--- Step 1: ログ収集サービス（生ログ → JSON） ---"
bash log_collector.sh access.log | head -3
echo "..."

echo ""
echo "--- Step 2: フィルタ → 集計パイプライン ---"
bash log_collector.sh access.log | bash aggregator_service.sh

echo ""
echo "--- Step 3: エラーのみフィルタ ---"
bash log_collector.sh access.log | bash filter_service.sh "status" "500"
```

### 演習3：マイクロサービスの「困難」を体験する

UNIXパイプラインでは起きない問題——ネットワーク遅延、部分障害——を模擬する。

```bash
cd /tmp/handson

echo "=== 分散システムの困難を模擬する ==="
echo ""

# --- 模擬1: レイテンシの影響 ---
echo "--- 模擬1: レイテンシの影響 ---"

# UNIXパイプライン（即座に完了）
echo "UNIXパイプライン:"
time (cat access.log | grep "500" | wc -l) 2>&1

echo ""

# マイクロサービス模擬（各サービスにネットワーク遅延）
echo "マイクロサービス模擬（各サービスに100ms遅延）:"
time (
    # サービス1: ログ読み取り（100ms遅延）
    sleep 0.1
    cat access.log > /tmp/handson/step1_out.txt

    # サービス2: フィルタリング（100ms遅延）
    sleep 0.1
    grep "500" /tmp/handson/step1_out.txt > /tmp/handson/step2_out.txt

    # サービス3: カウント（100ms遅延）
    sleep 0.1
    wc -l < /tmp/handson/step2_out.txt
) 2>&1

echo ""
echo "→ 同じ処理でも、ネットワーク遅延が加算される"
echo "  3サービス x 100ms = 300msのオーバーヘッド"
echo "  UNIXパイプには、この遅延は存在しない"

# --- 模擬2: 部分障害 ---
echo ""
echo "--- 模擬2: 部分障害 ---"

# サービスが途中で死ぬ場合
cat > unreliable_service.sh << 'SCRIPT'
#!/bin/bash
# 50%の確率で障害を起こすサービス
if (( RANDOM % 2 == 0 )); then
    echo "ERROR: Service unavailable" >&2
    exit 1
fi
# 正常時は入力をそのまま通過
cat
SCRIPT
chmod +x unreliable_service.sh

echo "信頼性の低いサービスを5回呼び出す:"
for i in $(seq 1 5); do
    result=$(echo "test data" | bash unreliable_service.sh 2>/dev/null)
    status=$?
    if [ $status -eq 0 ]; then
        echo "  試行$i: 成功 → '$result'"
    else
        echo "  試行$i: 失敗（サービス障害）"
    fi
done

echo ""
echo "→ UNIXのパイプでは、コマンドが50%の確率で失敗することはない"
echo "  マイクロサービスでは、ネットワーク障害・サービスダウンが日常"
echo "  リトライ、サーキットブレーカー、フォールバックが必要になる"

# --- 模擬3: 同じタスクの比較 ---
echo ""
echo "--- まとめ: UNIXパイプ vs マイクロサービス ---"
echo ""
echo "UNIXパイプラインの利点:"
echo "  - レイテンシが極めて低い（カーネル内通信）"
echo "  - 信頼性が高い（パイプは壊れない）"
echo "  - シンプル（テキストが流れるだけ）"
echo ""
echo "マイクロサービスの利点:"
echo "  - 独立したスケーリング（サービス単位で増減可能）"
echo "  - 独立したデプロイ（他サービスに影響なし）"
echo "  - 技術的多様性（サービスごとに異なる言語・DBを選択可能）"
echo ""
echo "マイクロサービスの代償:"
echo "  - ネットワーク遅延"
echo "  - 部分障害への対処"
echo "  - 分散トレーシングの必要性"
echo "  - データ一貫性の困難（CAP定理）"

# クリーンアップ
rm -rf /tmp/handson
```

この演習で体感すべき核心は、UNIXパイプラインとマイクロサービスは同じ設計原則を共有しているが、動作する「環境」が根本的に異なるということだ。同一マシンのカーネル内という信頼できる環境と、ネットワーク越しの信頼できない環境。原則は転生できるが、環境の差異が新たな困難を生む。

---

## 6. まとめと次回予告

### この回の要点

マイクロサービスアーキテクチャはUNIX哲学の「転生」である。だがその転生は、単純な再発明ではなく、半世紀の技術的進化を経た変容だ。

第一に、構造的アナロジーは実在する。「一つのことをうまくやれ」はSingle Responsibility Principleに、パイプはAPI/メッセージキューに、テキストストリームはJSON/gRPCに、標準入出力はHTTP/RESTに対応する。James Lewisが2012年に「Microservices - Java, the Unix Way」と題して発表したのは、この対応関係を意識的に認識していたからだ。

第二に、「Smart endpoints and dumb pipes」という原則は、SOAの「賢いパイプ（ESB）」の失敗を経て、UNIX哲学のパイプモデルへの回帰として明確に位置づけられる。FowlerとLewisが2014年の記事でこの原則を強調したのは、SOAの教訓を踏まえてのことだ。

第三に、Conway's Law（1968年）と12-Factor App（2011年）は、UNIX哲学の原則を組織設計とクラウドネイティブ設計にそれぞれ翻訳した。AmazonのBezos API Mandate（2002年頃）は、UNIX的なプロセス分離の原則を組織レベルで強制した。

第四に、UNIXパイプラインとマイクロサービスの決定的な違いは「環境」にある。UNIXのパイプは同一マシン上のカーネル内通信であり、信頼性・低レイテンシ・順序保証が暗黙に提供される。マイクロサービスはネットワーク越しの通信であり、「分散コンピューティングの8つの誤謬」がすべて適用される。CAP定理の制約、部分障害、レイテンシの不確実性——これらはUNIXのパイプラインには存在しなかった困難だ。

第五に、マイクロサービスへの移行を安易に行えば「分散モノリス」に陥る。モノリスの欠点と分散システムの欠点を同時に抱え込み、どちらの利点も得られない。UNIXのパイプラインでは「ただそうなっていた」独立性と疎結合を、マイクロサービスでは意識的に設計しなければならない。

### 冒頭の問いへの暫定回答

「マイクロサービスアーキテクチャはUNIX哲学の再発明なのか？ それとも独自の思想なのか？」

両方だ。設計原則のレベルでは、マイクロサービスはUNIX哲学の「転生」と呼ぶに値する。「一つのことをうまくやれ」「愚かなパイプで繋げ」「インタフェースを統一せよ」——これらの原則は、半世紀の時を超えて分散システムの設計原則として受け継がれている。

だが実装の文脈はまったく異なる。UNIXのパイプは信頼できる同一マシン上で動くが、マイクロサービスは信頼できないネットワーク越しに動く。この環境の差異が、UNIXには存在しなかった新たな問題群——ネットワーク分断、レイテンシ、部分障害、データ一貫性——を生んでいる。原則は転生できるが、文脈は常に変わる。変わった文脈に適応するための新たな知恵——サーキットブレーカー、サガパターン、イベントソーシング、分散トレーシング——は、UNIX哲学の範囲を超えた、分散システム固有の発明だ。

### 次回予告

次回は最終回、「UNIX――技術ではなく設計哲学として」。

23回にわたってUNIXの思想を辿ってきた。PDP-7の前でKen ThompsonとDennis Ritchieが練り上げた設計哲学は、半世紀以上を経て、コンテナ、マイクロサービス、クラウドネイティブの世界に転生している。

最終回では、この連載全体を振り返り、UNIX哲学から私たちが受け継いだもの——そして次の世代に伝えるべきもの——を問う。1999年のSlackwareの黒い画面から、2026年のClaude Codeのターミナルまで。24年間UNIXと歩んだエンジニアの、ひとまずの棚卸しだ。

UNIXを使えとは言わない。UNIXの設計哲学を「知って」使え。知った上で、その原則が有効な場面と限界がある場面を見分けよ。

---

## 参考文献

- Martin Fowler, James Lewis, "Microservices: A Definition of This New Architectural Term", 25 March 2014: <https://martinfowler.com/articles/microservices.html>
- Martin Fowler, "Microservices Guide": <https://martinfowler.com/microservices/>
- Melvin E. Conway, "How Do Committees Invent?", Datamation, 14(4), 28-31, April 1968: <https://www.melconway.com/Home/pdf/committees.pdf>
- Melvin Conway, "Conway's Law": <https://www.melconway.com/Home/Conways_Law.html>
- Adam Wiggins, "The Twelve-Factor App", 2011: <https://12factor.net/>
- Steve Yegge, "Stevey's Google Platforms Rant", October 2011: <https://gist.github.com/chitchcock/1281611>
- Google Open Source Blog, "Introducing gRPC, a new open source HTTP/2 RPC Framework", February 2015: <https://opensource.googleblog.com/2015/02/introducing-grpc-new-open-source-http2.html>
- LinkedIn Engineering Blog, "Open-sourcing Kafka, LinkedIn's distributed message queue", January 11, 2011: <https://blog.linkedin.com/2011/01/11/open-source-linkedin-kafka>
- L. Peter Deutsch et al., "Fallacies of Distributed Computing", Wikipedia: <https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing>
- Seth Gilbert, Nancy Lynch, "Brewer's conjecture and the feasibility of consistent, available, partition-tolerant web services", ACM SIGACT News, 2002: <https://users.ece.cmu.edu/~adrian/731-sp04/readings/GL-cap.pdf>
- Netflix, "Chaos Monkey", GitHub: <https://github.com/Netflix/chaosmonkey>
- Jeffrey P. Snover, "Monad Manifesto", Microsoft, August 8, 2002: <https://www.jsnover.com/Docs/MonadManifesto.pdf>
- Wikipedia, "Service-oriented architecture": <https://en.wikipedia.org/wiki/Service-oriented_architecture>
- Wikipedia, "CAP theorem": <https://en.wikipedia.org/wiki/CAP_theorem>
- Wikipedia, "Twelve-Factor App methodology": <https://en.wikipedia.org/wiki/Twelve-Factor_App_methodology>
