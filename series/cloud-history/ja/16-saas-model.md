# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第16回：SaaSモデル——ソフトウェアを「所有しない」時代

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- ソフトウェアを「買う」時代から「借りる」時代への転換が何を意味したのか
- ASP（Application Service Provider、1990年代後半）がSaaSの前身として何を試み、なぜ失敗したのか
- Salesforce（1999年創業）の「No Software」キャンペーンがSaaS市場をどう切り拓いたか
- Google Apps（2006年）、Slack（2013年）に至るSaaSの爆発的普及の構造
- Adobe Creative Cloud（2013年）とOffice 365（2011年）が示した永久ライセンスからサブスクリプションへの不可逆的転換
- SaaSの設計原則——マルチテナント、API駆動、サブスクリプション課金の技術的背景
- SaaSバックエンドのテナント分離戦略——サイロモデル、ブリッジモデル、プールモデルの設計判断
- SaaS疲れの実態——企業あたり平均106のSaaSアプリ、シャドーITを含めると275に達する現実
- GDPR（2018年施行）とSOC 2がSaaSプロバイダーに課したコンプライアンス要件

---

## 1. 「自分で運用する」という呪縛からの解放

2014年の冬、私はあるスタートアップのインフラ刷新を任されていた。

そのチームは自社サーバでSubversionを運用していた。Subversionは2004年にバージョン1.0がリリースされたオープンソースのバージョン管理システムで、当時はまだ多くの開発チームが使っていた。だが問題は、そのSubversionサーバの運用そのものにあった。物理サーバのOS更新、セキュリティパッチの適用、バックアップの確認、ディスク容量の監視——バージョン管理という「本来の目的」とは無関係な運用作業が、インフラエンジニアの時間を蝕んでいた。

「GitHub Enterpriseに移行しませんか」

私がそう提案したとき、チームリーダーの反応は予想通りだった。「データを外部に預けるのか」「サービスが止まったらどうする」「毎月の費用がかかり続ける」——いずれも正当な懸念だった。だが私は、自社運用のSubversionサーバが過去1年間に3回ダウンし、そのたびに復旧に半日を費やした事実を指摘した。GitHub Enterpriseの稼働率は99.95%を超える。自社運用でこの数字を維持するコストと、サービス利用料を比較すれば、答えは明白だった。

移行を決断した後、CIサーバも見直した。Jenkins——2005年にKohsuke KawaguchiがHudsonとして開発を始め、OracleのSun買収後の商標紛争を経て2011年にJenkinsへ改名されたCIツール——を自社サーバで運用していたが、プラグインの依存関係の問題、Javaのバージョンアップへの追従、ビルドキューの管理に常に手を焼いていた。2019年にGitHub ActionsがGA（一般提供）となったとき、私たちは迷わず移行した。

この2つの移行で解放されたもの——それはサーバの運用負荷だけではない。「このソフトウェアを自分たちで運用し続けなければならない」という思い込みからの解放だった。Subversionも Jenkinsも、私たちが解決したかった問題は「コードの管理」と「ビルドの自動化」であって、「サーバの運用」ではなかった。

だが同時に、失ったものもある。Subversionサーバのディスク上にあったリポジトリは、自分たちの手の届く範囲にあった。バックアップテープを金庫に入れておけば、たとえ会社が倒産しても——極端な話だが——データは手元に残る。GitHubに預けたデータは、GitHubというサービスの存続に依存している。料金体系の変更も、APIの仕様変更も、自分たちではコントロールできない。

ソフトウェアを「所有する」ことから「借りる」ことへの転換。これは単にデプロイ先が変わったという話ではない。ソフトウェアそのものの消費モデル——誰が所有し、誰が運用し、誰がリスクを負うか——の根本的な変革である。そしてこの変革には名前がある。SaaS——Software as a Serviceだ。

あなたは今、いくつのSaaSを使っているだろうか。GitHub、Slack、Google Workspace、Figma、Notion、Jira、Datadog——数え始めると、指が足りなくなるのではないか。では、それらのサービスの裏側で何が動いているか、考えたことはあるだろうか。

---

## 2. ASPの夢と挫折——SaaS以前の「ソフトウェアをサービスとして」

### 忘れられた先駆者たち

SaaSという概念が2000年代に爆発的に普及する以前、「ソフトウェアをサービスとして提供する」という発想は既に存在していた。1990年代後半に登場したASP（Application Service Provider）モデルがそれである。

ASPの基本的な考え方はシンプルだ。企業が自社にソフトウェアをインストールして運用する代わりに、ASP事業者がデータセンターでソフトウェアをホストし、企業はインターネット経由でそれにアクセスする。月額または年額のサブスクリプション料金を支払い、ソフトウェアの購入・インストール・運用から解放される。

この説明だけを聞けば、SaaSと何が違うのかと思うかもしれない。だが決定的な違いがあった。

ASPが提供していたのは、サードパーティ製のクライアント/サーバアプリケーションの「ホスティング」だった。つまり、もともとオンプレミスで動作するように設計されたソフトウェアを、そのままデータセンターのサーバに乗せて、リモートからアクセスできるようにしただけなのだ。アプリケーション自体はマルチテナントを前提に設計されておらず、テナントごとに個別のインスタンスを立てる必要があった。

これは本質的にシングルテナントモデルだった。顧客が100社あれば、100個のアプリケーションインスタンスを運用しなければならない。スケールすればするほどコストは線形に増加する。オンプレミスのソフトウェアがバージョン3.0に達している時期に、ASP版はまだバージョン1.0相当の品質——そんな状況も珍しくなかった。

2000年までに世界で500社以上のASPが設立された。代表的な企業にUSinternetworkingがある。1998年1月に設立され、1999年4月にIPOを果たしたが、わずか3年後の2002年1月に倒産した。USinternetworkingの軌跡は、ASPモデルの構造的な脆弱性を象徴している。

### ASPが失敗した4つの理由

ASPモデルの崩壊には、4つの構造的な原因があった。

第一に、シングルテナントアーキテクチャによる高コスト。顧客ごとに独立したインスタンスを運用するため、顧客数に比例してインフラコストが増大した。スケールメリットが効かないビジネスモデルだったのだ。

第二に、アプリケーション品質の低さ。ASPが提供するのは、もともとLAN環境で動作するように設計されたソフトウェアである。インターネット経由のアクセスでは、レイテンシの増大、帯域幅の制約、接続の不安定さが直撃した。ユーザー体験は、オンプレミスで直接動かした場合に遠く及ばなかった。

第三に、インターネットインフラの未成熟。1990年代後半のインターネット接続は、多くの企業にとってまだ細く不安定だった。ビジネスクリティカルなアプリケーションをインターネット越しに利用するには、インフラが追いついていなかった。

第四に、2001年のドットコムバブル崩壊。IT投資全体が急速に冷え込む中、ASP事業者の多くが資金を調達できなくなり、倒産した。

ASPの失敗は、「ソフトウェアをサービスとして提供する」という発想そのものの失敗ではなかった。それは、実装方法——シングルテナント、既存ソフトの流用、未成熟なインフラ——の失敗だった。この失敗の教訓を学び、設計を根本から変えた存在が、1999年に生まれる。

### Salesforceの誕生——「No Software」の衝撃

1999年3月8日、サンフランシスコのテレグラフヒルにある賃貸アパートの一室で、一つの会社が産声を上げた。

Marc Benioff——当時36歳、Oracle副社長の職にあった——は、Parker Harris、Dave Moellenhoff、Frank Dominguezとともに、Salesforceを創業した。住所は1449 Montgomery Street。Oracleの豪華なオフィスとは対照的な、ありふれたアパートだった。

Benioffが目指したのは、CRM（Customer Relationship Management）ソフトウェアをインターネット経由で提供することだった。だが、単に既存のCRMをホスティングするASPとは根本的に異なるアプローチを取った。Salesforceは最初から、マルチテナントを前提にゼロから設計されたWebアプリケーションだった。

ASPが「既存ソフトの引っ越し」だったのに対し、Salesforceは「インターネットネイティブのソフトウェア」だった。この設計思想の違いが、すべてを変えた。

Benioffのマーケティング戦略は過激だった。広告の専門家Bruce Campbell——レーガン大統領の「Morning in America」テレビキャンペーンを手がけた人物——と組み、ゴーストバスターズ風に赤い斜線で「SOFTWARE」の文字を打ち消す「No Software」ロゴを生み出した。ソフトウェアのパッケージ版を購入し、インストールし、運用するという行為そのものを否定するメッセージだ。

2000年2月7日、サンフランシスコのRegency Theaterで1,500人を集めたローンチイベントが開催された。テーマは「The End of Software」。Benioffは当時のCRM市場の巨人、Siebel Systemsのカンファレンス会場の前で、俳優を雇って偽の抗議デモを仕掛けるというゲリラマーケティングまで展開した。

大胆なマーケティングの裏側で、Salesforceの技術チームは地道な仕事をしていた。マルチテナントアーキテクチャの構築である。一つのアプリケーションインスタンスで複数の企業（テナント）にサービスを提供する。テナント間のデータは厳密に分離する。一つのテナントの負荷が他のテナントに影響しないようにする。これはASPのシングルテナントモデルとは根本的に異なる設計であり、スケールメリットが効く構造だった。

2004年6月23日、SalesforceはNYSE（ニューヨーク証券取引所）に上場した。ティッカーシンボルは「CRM」。初値11ドルに対し、初日の終値は17.20ドル——56.4%の上昇だった。ソフトウェアを「売る」のではなく「貸す」ビジネスモデルが、資本市場に認められた瞬間だった。

---

## 3. SaaSの爆発的普及——所有から利用へ

### Google Apps——オフィスソフトの地殻変動

Salesforceが切り拓いたSaaSの道を、Googleが一気に拡張した。

2006年8月28日、Googleは「Google Apps for Your Domain」を発表した。Gmail、Google Talk、Google Calendar、Page Creator（後にGoogle Sitesに置換）を統合した、企業向けクラウドオフィススイートである。

この発表のインパクトを理解するには、当時のオフィスソフト市場を思い出す必要がある。2006年当時、Microsoft Officeは企業向けオフィスソフト市場でほぼ独占的な地位を占めていた。企業はOfficeのライセンスをボリュームライセンス契約で購入し、社内のPCにインストールする。数年ごとにバージョンアップが発表され、そのたびに互換性の問題が発生し、IT部門は展開計画の策定に追われる。

Google Appsは、この構造そのものを否定した。ブラウザがあればよい。インストールは不要。バージョンアップは自動で行われ、全ユーザーが常に最新版を使う。複数人が同じドキュメントをリアルタイムで同時編集できる。これは、デスクトップアプリケーションの延長線上にはない、まったく新しい体験だった。

Google Appsの当初の提供形態は無料だった。有料版（Premier Edition）が追加されたのは2007年のことである。「無料のオフィスソフト」というインパクトは、特にスタートアップや中小企業にとって絶大だった。Office Suiteに年間数万円のライセンス費用を払う必要がなくなったのだ。

2016年9月29日にGoogle Appsは「G Suite」にリブランドされ、2020年10月6日にはさらに「Google Workspace」へと名を変えた。だがその本質——ソフトウェアをインストールせず、ブラウザ越しに利用する——は変わっていない。

### 永久ライセンスの終焉——AdobeとMicrosoftの決断

Google Appsが「最初からSaaSとして生まれた」ソフトウェアだとすれば、既存のデスクトップソフトウェアをSaaSに転換した事例として最もドラマチックなのは、AdobeとMicrosoftの決断である。

2011年6月28日、MicrosoftはOffice 365の一般提供を開始した。Google Docsとの競争が主な動機であった。従来のOfficeスイートの永久ライセンスに加えて、月額課金のサブスクリプションモデルを選択肢として提示した。

だが、真に衝撃的だったのはAdobeの決断である。

2013年5月6日、Adobeは今後Creative Suiteの新バージョンをリリースしないと宣言した。PhotoshopもIllustratorもPremiere Proも、今後はサブスクリプション専用のAdobe Creative Cloudでのみ提供される。永久ライセンスという選択肢を、Adobeは完全に廃止したのだ。

反発は激しかった。株価は約7%下落した。Change.orgでは5,000人を超えるユーザーが永久ライセンスの継続を求める署名を行った。「毎月払い続けなければ、自分のツールが使えなくなる」——クリエイターたちの怒りは理解できるものだった。

だが長期的に見れば、この決断はAdobeの収益構造を根本的に変革した。Creative Cloudのサブスクリプション加入者は、2013年のゼロから2024年には3,000万人を超えるまでに成長した。Adobeの年間収益は44億ドル（2013年）から150億ドル超（2024年）に跳ね上がった。

AdobeとMicrosoftの事例は、永久ライセンスからサブスクリプションへの転換が不可逆的な産業構造の変化であることを示している。買い切りのソフトウェアが「普通」だった時代は、確実に終わりつつある。

### SaaSの爆発——Slack、そしてすべてがサービスに

SaaSの波は、CRM（Salesforce）やオフィスソフト（Google Apps、Office 365）にとどまらなかった。あらゆるカテゴリのソフトウェアが「サービスとして」提供されるようになった。

その象徴的な存在がSlackである。Stewart Butterfield——Flickrの共同創業者——が2009年にバンクーバーで設立したTiny Speckは、当初マルチプレイヤーゲームGlitchを開発していた。2011年9月にGlitchはローンチされたが、十分なユーザーを獲得できず失敗に終わった。

だが、Glitchの開発過程で生まれた内部コミュニケーションツールが、思わぬ価値を持っていた。チーム内のやり取りを集約し、検索可能にし、外部サービスと連携する——このツールをプロダクトとして切り出したものがSlackである。

2013年8月にプレビュー公開、2014年2月に一般公開されたSlackは、爆発的な成長を遂げた。電子メールに代わるビジネスコミュニケーションの形を提示し、「チャットベースのコラボレーション」というカテゴリを確立した。2020年12月1日、Salesforceは277億ドルでSlackの買収を発表した。CRMのSaaS王者が、コミュニケーションのSaaS王者を飲み込んだのだ。

Slackの成功は、SaaSの普及パターンを象徴している。かつて企業は、社内コミュニケーションのために自前のIRCサーバやJabber（XMPP）サーバを運用していた。メールサーバもExchange Serverを自社で構築し運用していた。それが、Slack、Microsoft Teams、Google Chatに置き換わった。自前運用からサービス利用へ。この移行は、ほぼすべてのソフトウェアカテゴリで進行した。

Gartnerの予測によると、2024年の世界SaaS支出は2,472億ドル（前年比20%増）に達し、2025年には約3,000億ドルに到達する見通しである。SaaSは既にクラウド市場全体の中で最大のセグメントであり、成長率も鈍化の兆しを見せていない。AIの導入がさらなる成長を牽引している。

だが、この急成長の裏側には「SaaS疲れ」と呼ばれる現象も生まれている。BetterCloudの2024年レポートによると、企業あたりの平均SaaSアプリ数は106。Zyloの2025年調査ではシャドーIT（IT部門が把握していないアプリ）を含めると275に達する。毎月平均7.6の新しいSaaSアプリが企業の技術環境に流入し、42%の組織がIT予算の圧力からSaaS最適化に迫られている。しかもSaaS価格は前年比約11.4%上昇しており、G7諸国の平均インフレ率2.7%を大幅に上回る。

ソフトウェアを「所有しない」自由は、いつの間にか「サブスクリプションから逃れられない」束縛に変わりつつある。この構造の裏側を、次章で技術的に読み解いていく。

---

## 4. SaaSの技術的構造——マルチテナントの設計思想

### SaaSを成り立たせる3つの設計原則

SaaSを技術的に定義すると、以下の3つの設計原則が浮かび上がる。

```
SaaSの3つの設計原則:

  ┌──────────────────────────────────────────────┐
  │  1. マルチテナントアーキテクチャ             │
  │     - 1つのアプリケーションインスタンスで     │
  │       複数のテナント（顧客企業）に提供        │
  │     - テナント間のデータ隔離を保証            │
  │     - スケールメリットによるコスト効率         │
  ├──────────────────────────────────────────────┤
  │  2. API駆動                                  │
  │     - すべての機能がAPIで公開される            │
  │     - 外部サービスとの連携（インテグレーション）│
  │     - プログラマブルな拡張性                   │
  ├──────────────────────────────────────────────┤
  │  3. サブスクリプション課金                    │
  │     - 永久ライセンスではなく月額/年額課金     │
  │     - 利用量に応じた従量制の併用              │
  │     - 継続的な収益（Recurring Revenue）        │
  └──────────────────────────────────────────────┘
```

この3つは相互に依存している。マルチテナントアーキテクチャがなければ、多数のテナントを低コストで運用できない。APIがなければ、テナントごとの拡張性やサービス間連携を提供できない。サブスクリプション課金がなければ、継続的なサービス提供のための収益基盤が成り立たない。

ASPモデルが失敗したのは、この3つのうちマルチテナントアーキテクチャが欠けていたからだ。シングルテナントのASPでは、顧客数の増加に比例してコストが増え、スケールメリットが効かなかった。Salesforceが最初からマルチテナントを選択したのは、ASPの失敗を明確に認識していたからである。

### Force.comに見るマルチテナントの原型

マルチテナントSaaSアーキテクチャの設計原則を最も体系的にまとめた文献は、SalesforceのCraig WeissmanとSteve Bobrowskiが2008年に発表した「The Force.com Multitenant Architecture」ホワイトペーパーである。この論文は翌2009年にACM SIGMOD国際会議でも発表された。

Force.comのアーキテクチャは「メタデータ駆動型」と呼ばれる。その核心を理解するために、従来型のアプリケーションとの違いを見てみよう。

```
従来型アプリケーション:

  テナントA              テナントB              テナントC
  ┌─────────┐           ┌─────────┐           ┌─────────┐
  │ アプリ  │           │ アプリ  │           │ アプリ  │
  │ ケーション│           │ ケーション│           │ ケーション│
  ├─────────┤           ├─────────┤           ├─────────┤
  │ DB_A    │           │ DB_B    │           │ DB_C    │
  └─────────┘           └─────────┘           └─────────┘
  ※テナントごとにアプリ+DBを個別に運用（ASPモデル）


Force.com マルチテナントアーキテクチャ:

  テナントA    テナントB    テナントC
       \           |           /
        \          |          /
  ┌──────────────────────────────────┐
  │  マルチテナントカーネル          │
  │  （アプリケーションランタイム）  │
  │  ・メタデータを読み取り          │
  │  ・テナント固有のアプリを        │
  │    動的に生成                    │
  ├──────────────────────────────────┤
  │  共有データベース（単一スキーマ）│
  │  ┌──────────────────────────┐    │
  │  │ OrgID │ メタデータ │ データ│    │
  │  ├───────┼──────────┼───────┤    │
  │  │ A     │ 顧客管理   │ ...   │    │
  │  │ B     │ 案件管理   │ ...   │    │
  │  │ C     │ 顧客+案件  │ ...   │    │
  │  └──────────────────────────┘    │
  │  ※OrgIDでネイティブパーティショニング │
  └──────────────────────────────────┘
```

Force.comの設計の要点は4つある。

**第一に、単一の共有データベース・単一スキーマ。** すべてのテナントのデータが同じデータベース、同じスキーマに格納される。テナントの識別はOrgID（組織ID）で行い、データベースのネイティブパーティショニングで物理的に分離する。

**第二に、メタデータ駆動のアプリケーション生成。** テナントごとのカスタマイズ（画面レイアウト、ビジネスロジック、API）はメタデータとして格納される。マルチテナントカーネル（アプリケーションランタイム）がこのメタデータを実行時に読み取り、テナント固有のアプリケーションを動的に生成する。アプリケーションのコードそのものは全テナントで共通だ。

**第三に、マルチテナント専用のクエリオプティマイザ。** 従来のデータベースのコストベースオプティマイザは、マルチテナント環境のデータアクセス特性——OrgIDによるフィルタリングが全クエリに付加される——に最適化されていない。Force.comは独自のクエリオプティマイザを実装し、この問題に対処した。

**第四に、テナント間の公平なリソース配分。** あるテナントの重いクエリが他のテナントの性能に影響しないよう、ガバナー制限（Governor Limits）を設けている。クエリの行数制限、API呼び出し回数の制限、CPU時間の制限——これらは「制約」であると同時に、マルチテナント環境の公平性を保つための設計判断だ。

このForce.comのアーキテクチャは、SaaS設計の教科書的存在となった。第12回で扱ったマルチテナント設計の原則が、SaaSの文脈でどう具現化されるかを示す、最も重要なリファレンスである。

### テナント分離の3つの戦略

Force.comのように単一データベース・単一スキーマで全テナントを格納するアプローチは、スケーラビリティとコスト効率に優れるが、唯一の正解ではない。SaaSバックエンドのテナント分離には、主に3つの戦略が存在する。

```
テナント分離の3つの戦略:

 (1) サイロモデル（Database-per-Tenant）
 ┌──────┐  ┌──────┐  ┌──────┐
 │ DB_A │  │ DB_B │  │ DB_C │   テナントごとに専用DB
 └──────┘  └──────┘  └──────┘
 ✔ 最大のデータ隔離        ✘ 運用コスト大（DB×テナント数）
 ✔ テナント別バックアップ  ✘ スケーラビリティに限界
 ✔ 規制要件への対応        ✘ テナント追加のリードタイム

 (2) ブリッジモデル（Schema-per-Tenant）
 ┌─────────────────────────┐
 │ 共有DB                  │
 │ ┌─────┐┌─────┐┌─────┐  │   共有DBの中にテナント別スキーマ
 │ │ S_A ││ S_B ││ S_C │  │
 │ └─────┘└─────┘└─────┘  │
 └─────────────────────────┘
 ✔ セキュリティと効率のバランス  ✘ リソース競合の可能性
 ✔ テナント追加が容易            ✘ スキーマ変更に慎重な計画が必要
 ✔ バックアップの簡素化          ✘ テナント数の上限（DBの制約）

 (3) プールモデル（Row-Level Security）
 ┌─────────────────────────┐
 │ 共有DB・共有テーブル     │
 │ ┌─────────────────────┐ │   同一テーブルに全テナントの
 │ │ tenant_id │ data    │ │   データを格納、行レベルで制御
 │ │ A         │ ...     │ │
 │ │ B         │ ...     │ │
 │ │ C         │ ...     │ │
 │ └─────────────────────┘ │
 └─────────────────────────┘
 ✔ コスト効率が最大         ✘ ノイジーネイバーのリスク
 ✔ スケーラビリティが高い   ✘ アクセス制御のミスが致命的
 ✔ 運用が簡素               ✘ テナント別操作が複雑
```

実務上、この3つの戦略のどれを選ぶかは、テナントの特性によって異なる。AWSの公式ガイダンス「Guidance for Multi-Tenant Architectures on AWS」やAWS Well-Architected Framework SaaS Lens、Microsoftの「Multitenant SaaS Patterns」が包括的なリファレンスとして公開されている。

多くの成熟したSaaSでは、ハイブリッドモデルが採用されている。大規模なエンタープライズ顧客にはサイロモデル（専用データベース）を提供し、中規模の顧客にはブリッジモデル（スキーマ分離）を、小規模や無料プランの顧客にはプールモデル（Row-Level Security）を適用する。顧客のグレードに応じてテナント分離の強度を変える戦略だ。

### SaaSのセキュリティとコンプライアンス

SaaSが企業のコアデータを預かる存在になるにつれて、セキュリティとコンプライアンスの要件は厳格化の一途を辿った。

2018年5月25日、GDPR（General Data Protection Regulation）が適用開始された。GDPRはEU居住者の個人データを扱うすべての事業者に、所在地を問わず厳格なデータ保護義務を課す。違反した場合の罰則は、世界売上の4%または2,000万ユーロのいずれか高い方だ。

GDPRがSaaSプロバイダーに突きつけた問いは本質的だった。「あなたのサービスは、顧客のデータをどこに保存し、どのように保護し、要求があれば削除できるのか」。マルチテナント環境での「忘れられる権利」（Right to Erasure）の実装は、単純な `DELETE` 文では済まない。バックアップ、ログ、キャッシュ、レプリカ——データの断片はシステムの至る所に散在する。

同時期に、AICPA（米国公認会計士協会）が定めたSOC 2（Service Organization Control 2）監査フレームワークが、エンタープライズ契約の事実上の入場券となった。SOC 2は5つのTrust Services Criteria——セキュリティ、可用性、処理の完全性、機密性、プライバシー——に基づく監査で、法的義務ではないが、大企業がSaaSベンダーを選定する際に「SOC 2 Type II レポートを提出できるか」は必須の確認項目になっている。

GDPRとSOC 2の双方への対応は、現代のSaaSベンダーにとってベースライン要件である。これらを満たさなければ、エンタープライズ市場には参入すらできない。SaaSが「ソフトウェアを借りる」モデルである以上、「預けたデータが安全か」という問いに答え続けることは、SaaSプロバイダーの存在意義そのものに関わる。

---

## 5. ハンズオン——マルチテナントSaaSの基本アーキテクチャを構築する

ここまでの技術論を体で理解するために、Dockerを使ってマルチテナントSaaSの基本アーキテクチャを構築してみよう。3つのテナント分離戦略——サイロモデル、ブリッジモデル（スキーマ分離）、プールモデル（Row-Level Security）——を実際に実装し、それぞれの特性を観察する。

### 演習1：プールモデル——Row-Level Securityによるテナント分離

最もコスト効率の高いプールモデルから始める。PostgreSQLのRow-Level Security（RLS）機能を使い、同一テーブル上でテナント間のデータを分離する。

```bash
# === PostgreSQL Row-Level Securityによるマルチテナント ===

# PostgreSQLコンテナを起動
docker run -d --name saas-rls \
  -e POSTGRES_DB=saas_app \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:16

sleep 3

# テナントテーブルとデータの作成
docker exec -i saas-rls psql -U admin -d saas_app << 'SQL'
-- テナント管理テーブル
CREATE TABLE tenants (
    tenant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    plan TEXT NOT NULL DEFAULT 'free',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- テナントデータ（共有テーブル）
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- テナントを3つ作成
INSERT INTO tenants (tenant_id, name, plan) VALUES
    ('aaaaaaaa-0000-0000-0000-000000000001', 'Acme Corp', 'enterprise'),
    ('bbbbbbbb-0000-0000-0000-000000000002', 'Beta Inc', 'pro'),
    ('cccccccc-0000-0000-0000-000000000003', 'Charlie LLC', 'free');

-- 各テナントのプロジェクトを追加
INSERT INTO projects (tenant_id, name, description) VALUES
    ('aaaaaaaa-0000-0000-0000-000000000001', 'Project Alpha', 'Acmeの社内プロジェクト'),
    ('aaaaaaaa-0000-0000-0000-000000000001', 'Project Omega', 'Acmeの顧客向けプロジェクト'),
    ('bbbbbbbb-0000-0000-0000-000000000002', 'Beta Launch', 'Betaの新製品開発'),
    ('cccccccc-0000-0000-0000-000000000003', 'Charlie MVP', 'Charlieの初期プロダクト');

-- === Row-Level Security の設定 ===

-- RLSを有効化
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- テナント別のロールを作成
CREATE ROLE tenant_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON projects TO tenant_user;
GRANT USAGE, SELECT ON SEQUENCE projects_id_seq TO tenant_user;

-- RLSポリシーを定義
-- current_settingでセッション変数からtenant_idを読み取る
CREATE POLICY tenant_isolation ON projects
    USING (tenant_id = current_setting('app.current_tenant')::UUID)
    WITH CHECK (tenant_id = current_setting('app.current_tenant')::UUID);

-- 確認: RLS無効の管理者（admin）は全データが見える
SELECT '=== 管理者（RLSバイパス）: 全テナントのデータが見える ===' AS info;
SELECT t.name AS tenant, p.name AS project
FROM projects p JOIN tenants t ON p.tenant_id = t.tenant_id
ORDER BY t.name, p.name;

SQL

echo ""
echo "=== Row-Level Security の動作確認 ==="
echo ""

# テナントAとしてアクセス
docker exec -i saas-rls psql -U admin -d saas_app << 'SQL'
-- テナントAとしてセッションを設定
SET app.current_tenant = 'aaaaaaaa-0000-0000-0000-000000000001';
SET ROLE tenant_user;

SELECT '=== テナントA（Acme Corp）としてアクセス ===' AS info;
SELECT id, name, description FROM projects;

-- テナントAからテナントBのデータを見ようとしても見えない
SELECT '=== テナントBのデータは見えない（RLSが自動フィルタリング） ===' AS info;
SELECT count(*) AS visible_rows FROM projects;

RESET ROLE;
SQL

# テナントBとしてアクセス
docker exec -i saas-rls psql -U admin -d saas_app << 'SQL'
SET app.current_tenant = 'bbbbbbbb-0000-0000-0000-000000000002';
SET ROLE tenant_user;

SELECT '=== テナントB（Beta Inc）としてアクセス ===' AS info;
SELECT id, name, description FROM projects;

RESET ROLE;
SQL

echo ""
echo "=== 考察 ==="
echo "1. RLSにより、アプリケーションコードを変更せず"
echo "   テナント分離が実現できる"
echo "2. セッション変数（app.current_tenant）を正しく設定することが"
echo "   セキュリティの生命線"
echo "3. テナントIDの設定ミス/漏れが致命的 -- アプリケーション層での"
echo "   ミドルウェアによる自動設定が必須"

docker stop saas-rls && docker rm saas-rls
```

### 演習2：スキーマ分離モデル——テナントごとのスキーマ

```bash
# === スキーマ分離（Schema-per-Tenant）モデル ===

docker run -d --name saas-schema \
  -e POSTGRES_DB=saas_app \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:16

sleep 3

docker exec -i saas-schema psql -U admin -d saas_app << 'SQL'
-- テナントごとにスキーマを作成
CREATE SCHEMA tenant_acme;
CREATE SCHEMA tenant_beta;
CREATE SCHEMA tenant_charlie;

-- 各スキーマに同じテーブル構造を作成（テンプレート的に）
DO $$
DECLARE
    schema_name TEXT;
BEGIN
    FOR schema_name IN SELECT unnest(ARRAY['tenant_acme', 'tenant_beta', 'tenant_charlie'])
    LOOP
        EXECUTE format('
            CREATE TABLE %I.projects (
                id SERIAL PRIMARY KEY,
                name TEXT NOT NULL,
                description TEXT,
                created_at TIMESTAMPTZ DEFAULT now()
            )', schema_name);
    END LOOP;
END $$;

-- 各テナントのスキーマにデータを投入
INSERT INTO tenant_acme.projects (name, description)
VALUES ('Project Alpha', 'Acmeの社内プロジェクト'),
       ('Project Omega', 'Acmeの顧客向けプロジェクト');

INSERT INTO tenant_beta.projects (name, description)
VALUES ('Beta Launch', 'Betaの新製品開発');

INSERT INTO tenant_charlie.projects (name, description)
VALUES ('Charlie MVP', 'Charlieの初期プロダクト');

-- テナントAのデータを確認
SELECT '=== テナントA（tenant_acme）のデータ ===' AS info;
SELECT * FROM tenant_acme.projects;

-- テナントBのデータを確認
SELECT '=== テナントB（tenant_beta）のデータ ===' AS info;
SELECT * FROM tenant_beta.projects;

-- search_pathを設定することで、テナント切り替えを実現
SET search_path TO tenant_acme, public;
SELECT '=== search_pathでテナントAを設定後、単純なSELECT ===' AS info;
SELECT * FROM projects;  -- tenant_acme.projectsが参照される

SET search_path TO tenant_beta, public;
SELECT '=== search_pathでテナントBに切り替え ===' AS info;
SELECT * FROM projects;  -- tenant_beta.projectsが参照される

-- スキーマ一覧の確認
SELECT '=== テナントスキーマ一覧 ===' AS info;
SELECT schema_name,
       (SELECT count(*) FROM information_schema.tables
        WHERE table_schema = schema_name) AS table_count
FROM information_schema.schemata
WHERE schema_name LIKE 'tenant_%'
ORDER BY schema_name;

SQL

echo ""
echo "=== スキーマ分離モデルの考察 ==="
echo "1. テナントごとにスキーマが独立 -- 物理的なデータ分離に近い"
echo "2. search_pathの設定でテナント切り替えが可能"
echo "3. スキーマ単位のバックアップ・リストアが可能"
echo "4. テナント数が数千を超えるとDB側の制約に注意"

docker stop saas-schema && docker rm saas-schema
```

### 演習3：3つのモデルの比較分析

```bash
# === テナント分離戦略の比較分析 ===

cat << 'ANALYSIS'
==============================================
  マルチテナント テナント分離戦略の比較
==============================================

                    サイロ         ブリッジ        プール
                 (DB-per-      (Schema-per-    (Row-Level
                  Tenant)        Tenant)       Security)
------------------------------------------------------
データ隔離      ★★★★★         ★★★★☆         ★★★☆☆
コスト効率      ★☆☆☆☆         ★★★☆☆         ★★★★★
運用の容易さ    ★★☆☆☆         ★★★☆☆         ★★★★★
スケーラビリティ ★★☆☆☆         ★★★☆☆         ★★★★★
カスタマイズ性  ★★★★★         ★★★★☆         ★★☆☆☆
テナント追加    ★★☆☆☆         ★★★★☆         ★★★★★
バックアップ粒度 ★★★★★         ★★★★☆         ★★☆☆☆
ノイジーネイバー ★★★★★         ★★★☆☆         ★★☆☆☆
------------------------------------------------------

推奨ユースケース:

  サイロモデル:
    - 金融・医療など規制の厳しい業界
    - データの物理的分離が要件
    - テナント数が少ない（数十〜数百）
    - 大企業向けのエンタープライズプラン

  ブリッジモデル:
    - セキュリティと効率のバランスが必要
    - テナント別のスキーマ管理が許容できる
    - 中規模のテナント数（数百〜数千）
    - プロプランの顧客向け

  プールモデル:
    - 大量のテナントを低コストで運用
    - データの論理的分離で十分
    - テナント数が数千〜数万以上
    - フリープラン・スタータープランの顧客向け

実務上のベストプラクティス:
  多くの成熟したSaaSは、顧客のプランに応じて
  テナント分離の強度を変えるハイブリッドモデルを採用する。

  Enterprise  → サイロ（専用DB）
  Pro         → ブリッジ（スキーマ分離）
  Free/Start  → プール（RLS）

ANALYSIS
```

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/16-saas-model/` に用意してある。

---

## 6. まとめと次回予告

### この回のまとめ

第16回では、ソフトウェアを「所有する」時代から「借りる」時代への転換——SaaSモデルの歴史と技術的構造を読み解いた。

**SaaSの前身であるASP（1990年代後半）は、「ソフトウェアをサービスとして」という発想自体は正しかったが、実装が誤っていた。** シングルテナントアーキテクチャ、既存ソフトの流用、未成熟なインフラ——これらの構造的問題に加え、2001年のドットコムバブル崩壊で大半のASP事業者が消滅した。ASPの失敗は「何を作るか」ではなく「どう作るか」の問題だった。

**Salesforce（1999年創業）はASPの教訓を学び、最初からマルチテナントを前提に設計された。** Marc Benioffの「No Software」キャンペーンは過激なマーケティングだったが、その裏側にあったのは、マルチテナントアーキテクチャという堅実な技術的基盤だった。2008年に発表されたForce.comのマルチテナントアーキテクチャ論文は、メタデータ駆動型設計の原則を体系化し、SaaS設計の教科書となった。

**Google Apps（2006年）はオフィスソフトの消費モデルを変え、Adobe Creative Cloud（2013年）とOffice 365（2011年）は永久ライセンスからサブスクリプションへの不可逆的転換を象徴した。** Adobeの決断は短期的には株価下落と顧客の反発を招いたが、長期的には収益を3倍以上に成長させた。買い切りのソフトウェアが「普通」だった時代は終わった。

**SaaSの技術的構造は、マルチテナントアーキテクチャ、API駆動、サブスクリプション課金の3つの原則に支えられている。** テナント分離には、サイロモデル（Database-per-Tenant）、ブリッジモデル（Schema-per-Tenant）、プールモデル（Row-Level Security）の3つの戦略があり、成熟したSaaSは顧客のプランに応じてハイブリッドに使い分ける。

**SaaSの急成長の裏側には「SaaS疲れ」がある。** 企業あたり平均106のSaaSアプリ（BetterCloud、2024年）、シャドーITを含めると275（Zylo、2025年）。SaaS価格は前年比11.4%上昇。GDPRやSOC 2への対応も、SaaSベンダーにとって避けられないベースライン要件となった。

冒頭の問いに答えよう。ソフトウェアを「買う」時代から「借りる」時代への転換は、開発者を運用の呪縛から解放した。自前のSubversionサーバやJenkinsサーバを運用する必要はなくなった。だが、その代償として、私たちはソフトウェアに対するコントロールの一部を手放した。サービスの料金改定、API仕様の変更、サービスの終了——これらは、ソフトウェアを「所有」していた時代には存在しなかったリスクだ。SaaSの恩恵を享受しつつ、依存のリスクを認識する。この緊張感の中に、SaaS時代のエンジニアの正しい姿勢がある。

### 次回予告

第17回では、「コンテナオーケストレーション——KubernetesがIaaSを再定義する」を取り上げる。

IaaSは仮想マシン単位でインフラを抽象化した。PaaSはデプロイを抽象化した。SaaSはソフトウェアそのものを抽象化した。では、その間を埋める存在は何か。Docker（2013年）が生み出した「コンテナ」は、アプリケーションのパッケージングを革命的に変えた。そしてKubernetes（2014年、Google）は、そのコンテナの管理——オーケストレーション——を通じて、IaaSの上に新たな抽象化レイヤーを築いた。

YAMLの海に溺れながら、それでもKubernetesが「宣言的インフラ」の標準となった理由を問い直す。

---

## 参考文献

- SmartBear, "The Pre-History of Software as a Service". <https://smartbear.com/blog/the-pre-history-of-software-as-a-service/>
- TechTarget, "What is application service provider (ASP)?". <https://www.techtarget.com/searchapparchitecture/definition/application-service-provider-ASP>
- Salesforce, "The History of Salesforce". <https://www.salesforce.com/news/stories/the-history-of-salesforce/>
- Marc Benioff, "Behind the Cloud", Jossey-Bass, 2009. <https://www.oreilly.com/library/view/behind-the-cloud/9780470521168/>
- Craig D. Weissman & Steve Bobrowski, "The Design of the Force.com Multitenant Internet Application Development Platform", ACM SIGMOD, 2009. <https://architect.salesforce.com/fundamentals/platform-multitenant-architecture>
- Wikipedia, "Google Workspace". <https://en.wikipedia.org/wiki/Google_Workspace>
- Wikipedia, "Adobe Creative Cloud". <https://en.wikipedia.org/wiki/Adobe_Creative_Cloud>
- Tapflare, "Case Study: Adobe's Transition to a Subscription Model". <https://tapflare.com/articles/adobe-subscription-model-case-study>
- Microsoft, "Microsoft Launches Office 365 Globally", June 2011. <https://news.microsoft.com/source/2011/06/28/microsoft-launches-office-365-globally/>
- Wikipedia, "Slack Technologies". <https://en.wikipedia.org/wiki/Slack_Technologies>
- TechCrunch, "The Slack origin story", May 2019. <https://techcrunch.com/2019/05/30/the-slack-origin-story/>
- BetterCloud, "The big list of 2025 SaaS statistics". <https://www.bettercloud.com/monitor/saas-statistics/>
- Zylo, "2025 SaaS Management Index". <https://zylo.com/reports/2025-saas-management-index/>
- SaaStr, "Gartner: SaaS Spend is Actually Accelerating, Will Hit $300 Billion in 2025". <https://www.saastr.com/gartner-saas-spend-is-actually-accelerating-will-hit-300-billion-in-2025/>
- Wikipedia, "General Data Protection Regulation". <https://en.wikipedia.org/wiki/General_Data_Protection_Regulation>
- Secureframe, "The History of SOC 2". <https://secureframe.com/hub/soc-2/history>
- AWS, "Guidance for Multi-Tenant Architectures on AWS". <https://aws.amazon.com/solutions/guidance/multi-tenant-architectures-on-aws/>
- Microsoft Learn, "Multitenant SaaS Patterns - Azure SQL Database". <https://learn.microsoft.com/en-us/azure/azure-sql/database/saas-tenancy-app-design-patterns>
- AWS Blog, "Multi-tenant data isolation with PostgreSQL Row Level Security". <https://aws.amazon.com/blogs/database/multi-tenant-data-isolation-with-postgresql-row-level-security/>
- Wikipedia, "Jenkins (software)". <https://en.wikipedia.org/wiki/Jenkins_(software)>
- Apache Subversion Release History. <https://subversion.apache.org/docs/release-notes/release-history.html>
- GitHub Blog, "GitHub Actions now supports CI/CD", August 2019. <https://github.blog/2019-08-08-github-actions-now-supports-ci-cd/>
