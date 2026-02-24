# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第15回：PaaSの栄枯盛衰——なぜ「便利すぎる抽象化」は苦戦したか

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- PaaSが「インフラを忘れる」という夢を提示し、なぜその夢が一度は潰えたように見えたのか
- PaaSの栄光期（2008〜2013年）における主要プレイヤー——Heroku、GAE、Cloud Foundry、OpenShiftの全体像
- PaaS企業dotCloudがDockerを生み出し、自らPaaSを捨てた皮肉な転換（2013年）
- Docker/Kubernetes（2013〜2014年）の台頭がPaaS市場に与えた構造的インパクト
- PaaSが苦戦した3つの構造的理由——ベンダーロックイン、カスタマイズ性の不足、コストの不透明性
- Cloud Foundry（2011年、VMware）とOpenShift（2011年、Red Hat）の企業向けPaaS戦略
- 「PaaS 2.0」の台頭——Cloud Run、Fly.io、Render、Railway、Vercelが受け入れられている理由
- コンテナの標準化がPaaSのロックイン問題をどう緩和したか
- The Twelve-Factor Appの思想がPaaSを超えてクラウドネイティブの標準となった経緯

---

## 1. PaaSの夢が醒めた朝

2015年の秋、私はあるスタートアップのインフラ移行プロジェクトに関わっていた。

そのチームは2012年にHerokuでプロダクトを立ち上げた。`git push heroku main` で始まる開発体験は快適で、初期の成長期にはインフラのことなど一切考えずにプロダクト開発に集中できた。Herokuの約束——「インフラを忘れて開発に集中しろ」——は、確かに実現されていた。

だが、プロダクトが成長するにつれて、壁にぶつかった。

データベースのレイテンシが問題になり始めたが、Heroku Postgresの設定を細かくチューニングする方法がない。バックグラウンドジョブのメモリ使用量が増えたが、Dynoのサイズは限られた選択肢しかなく、必要なスペックと提供されるスペックの間に常にギャップがある。月額費用は、同等スペックのAWS EC2インスタンスの3〜5倍に膨らんでいた。そして何より、Heroku固有のBuildpackに依存したビルドパイプラインが、チームの技術的な選択肢を狭めていた。

「AWSに移行しよう」

その判断自体は合理的だった。だが移行は容易ではなかった。Herokuのアドオンエコシステムに依存していた部分を自前で構築し直す必要があった。ログ集約、メトリクス監視、SSL証明書管理——Herokuが「隠蔽」していたものを、一つ一つ自分たちの手で構築し直す作業だ。移行には3ヶ月を要した。

この経験は、私にPaaSという概念の構造的なジレンマを突きつけた。PaaSは開発の初期段階では圧倒的に便利だ。だがプロダクトが成長し、要求が複雑化すると、その「便利な抽象化」が「変更不能な制約」に変わる。そしてPaaSからの脱出——いわゆる「出口」——のコストは、PaaSに依存した期間が長いほど高くなる。

2015年というタイミングには意味がある。Dockerが2013年にオープンソース化され、Kubernetesが2014年に発表され、コンテナオーケストレーションが現実の選択肢になりつつあった時期だ。「PaaSに頼らなくても、コンテナとオーケストレーションで同等以上のことができる」——そう考えるエンジニアが増えていた。

PaaSは「インフラを忘れる」という夢を見せた。その夢はなぜ潰えたのか。いや、本当に潰えたのか。あなたは今、デプロイ先としてHerokuやGAEを第一候補に挙げるだろうか。それとも、VercelやCloud Runを選ぶだろうか。その選択の背後にある歴史を、今回は読み解いていく。

---

## 2. PaaSの栄光期——2008年から2013年の風景

### 先駆者たちの登場

PaaSの歴史を俯瞰するために、まず2008年から2013年までの「栄光期」を振り返る。

この時期に登場した主要なPaaSプラットフォームを時系列で整理すると、以下のようになる。

```
PaaSプラットフォームの登場タイムライン:

  2007年  Heroku創業（James Lindenbaum, Adam Wiggins, Orion Henry）
  |       Ruby on Railsアプリケーションのデプロイに特化
  |
  2008年  Google App Engine発表（4月7日、Campfire One）
  |       Python専用、厳格なサンドボックス制約
  |       dotCloud設立（Solomon Hykes, Kamel Founadi,
  |       Sebastien Pahl）— PaaS企業として出発
  |
  2010年  SalesforceがHerokuを買収（12月、2億1200万ドル）
  |       Red HatがMakaraを買収（11月、PaaS技術の獲得）
  |
  2011年  Cloud Foundry発表（4月、VMware、オープンソースPaaS）
  |       OpenShift発表（5月、Red Hat）
  |       AWS Elastic Beanstalk発表
  |       The Twelve-Factor App公開（11月、Adam Wiggins）
  |       GAE GA化・料金改定（9月）
  |
  2012年  OpenShiftオープンソース化（5月）
  |       OpenShift Enterprise 1.0 GA（11月）
  |
  2013年  Docker オープンソース化（3月）
  |       dotCloudがDocker Inc.に社名変更（10月）
  |       Pivotal Software設立（Cloud Foundry移管）
```

この5年間は、PaaSにとっての黄金期だった。クラウドの民主化が進み、EC2でサーバを立てることは容易になったが、デプロイパイプラインの構築、ミドルウェアの設定、ログの集約、SSL証明書の管理——いわゆる「アプリケーション運用のオーバーヘッド」は依然として大きかった。PaaSはこのオーバーヘッドを解消する存在として期待された。

### Cloud Foundry——「企業のためのオープンソースPaaS」

第13回でHeroku、第14回でGoogle App Engineを詳しく見てきた。ここでは、企業向けPaaSとして重要な位置を占めたCloud FoundryとOpenShiftに焦点を当てる。

2011年4月、VMwareはCloud Foundryを「業界初のオープンソースPaaS」として発表した。Cloud Foundryの設計思想は、HerokuやGAEとは異なるベクトルを持っていた。

HerokuとGAEはパブリックPaaS——クラウド事業者が管理するマルチテナント環境で、開発者がアプリケーションをデプロイする。一方、Cloud Foundryは「プライベートPaaS」——企業が自社のインフラ上にPaaS環境を構築し、自社の開発者に提供するという構想だった。

Cloud Foundryの背後にあったのは、エンタープライズの現実だ。大企業は規制要件、セキュリティポリシー、既存のオンプレミスインフラとの統合という制約を抱えている。パブリックPaaSに全面移行することは、技術的にも組織的にも困難な場合が多い。Cloud Foundryは、この現実に対して「自分たちのインフラ上にPaaSを立てる」という回答を提示した。

Cloud Foundryのアーキテクチャは、後のクラウドネイティブ技術に影響を与えた概念を多く含んでいる。Buildpackの仕組み（ソースコードから実行可能なイメージを自動生成する）、`cf push` コマンドによるワンコマンドデプロイ、ヘルスモニタリングと自動復旧——これらはHerokuの設計思想を企業向けに拡張したものだった。

だが、Cloud Foundryの運命は複雑な道を辿ることになる。VMwareからPivotal Software（EMC/VMware/GEの合弁会社、2013年設立）に移管され、さらにLinux Foundation傘下のCloud Foundry Foundationに移管された（2015年）。この間に、Docker/Kubernetesの台頭という地殻変動が起きた。Cloud Foundryは独自のコンテナ実行環境（Garden/Diego）を持っていたが、Kubernetesがコンテナオーケストレーションの事実上の標準となると、この独自性はアドバンテージではなく障壁になった。

### OpenShift——Red Hatの賭け

Red Hatは2010年11月にPaaS企業Makaraを買収し、2011年5月にOpenShiftを発表した。OpenShift Enterprise 1.0は2012年11月にGAとなり、エンタープライズ向けPaaSとしてCloud Foundryと競合する立場に立った。

興味深いのは、OpenShiftのその後の転身だ。初期のOpenShift（バージョン1〜2）はRHELベースの独自コンテナ技術を使用していた。これはDocker以前のLinuxコンテナ技術であり、Red Hat独自の実装だった。だが2015年6月にリリースされたOpenShift 3で、Red Hatは大胆な決断を下す。独自技術を捨て、DockerとKubernetesを全面採用したのだ。

この転身は戦略的に正しかった。OpenShiftは「PaaSプラットフォーム」から「エンタープライズKubernetesディストリビューション」に生まれ変わり、Kubernetesの普及とともに成長を続けることになる。「PaaS」というラベルに固執せず、基盤技術の変化に合わせて自らを再定義する柔軟さが、OpenShiftの生存を可能にした。

Cloud FoundryとOpenShiftの対比は、PaaSの栄枯盛衰を理解する上で重要だ。Cloud Foundryは独自のコンテナ実行環境を維持し続け、Kubernetesへの統合（KubeCF、Korifi）は後手に回った。OpenShiftは早期にKubernetesを受け入れ、自らを「PaaS」から「Kubernetesプラットフォーム」に再定義した。同じ企業向けPaaSでありながら、技術的転換への対応の違いが、その後の軌跡を分けた。

### dotCloudの皮肉——PaaS企業がPaaSを殺した

PaaSの栄光期を語る上で避けて通れないのが、dotCloudの物語だ。

dotCloudは2008年にSolomon Hykes、Kamel Founadi、Sebastien Pahlによりパリで設立されたPaaS企業だ。2010年に米国法人化し、2011年にはシリコンバレーに移転、シリーズAで1100万ドルを調達した。HerokuやGAEと同様に、開発者がアプリケーションをクラウドに簡単にデプロイできるプラットフォームを提供していた。

dotCloudの技術的な特徴は、コンテナ技術を基盤としていたことだ。他の初期PaaSが各言語向けに別個のツールやパッケージングを必要としたのに対し、dotCloudは統一されたコンテナフォーマットを使用していた。このコンテナ技術が、社内ツールとして開発されたDockerの原型となる。

2013年3月、dotCloudは社内ツールだったDockerをオープンソースとして公開した。反響は予想を遥かに超えた。Docker 1.0が2014年にリリースされた時点で、ダウンロード数は275万回を超えていた。

そして2013年10月29日、dotCloudはPaaS事業の縮小と、社名のDocker Inc.への変更を発表する。PaaS企業が自社の中核技術をオープンソース化し、その技術の成功によってPaaS事業そのものを捨てた——この皮肉は、PaaSというカテゴリの構造的な脆弱さを象徴している。

dotCloudの転身が示したのは、PaaSの価値は「プラットフォーム」そのものではなく、その基盤にある「コンテナ」という技術にあったということだ。コンテナが標準化されれば、その上に構築するプラットフォームは交換可能になる。PaaSの「便利さ」は、基盤技術の「囲い込み」の上に成り立っていた。基盤が開放された瞬間、PaaSの参入障壁は崩れた。

---

## 3. PaaSの停滞——なぜ「便利すぎる抽象化」は苦戦したか

### Docker/Kubernetesの台頭（2013〜2014年）

2013年のDockerオープンソース化、そして2014年6月10日のKubernetes発表——GoogleのVP Eric BrewerがDockerConで発表した——は、PaaS市場の転換点となった。

Docker以前、アプリケーションのパッケージングとデプロイは各PaaSプラットフォームの独自仕様に依存していた。Herokuには Buildpack、GAEにはSDKとapp.yaml、Cloud Foundryには独自のDroplet形式があった。開発者は、選択したPaaSの仕様に合わせてアプリケーションを構成する必要があった。

Dockerは、この状況を根本から変えた。`Dockerfile` という統一されたフォーマットでアプリケーションの実行環境を定義し、どの環境でも同一のコンテナイメージを実行できる。アプリケーションのポータビリティが、PaaSプラットフォームではなくコンテナ規格によって保証されるようになった。

Kubernetesはさらに一歩進んで、コンテナのスケジューリング、スケーリング、ネットワーキング、サービスディスカバリを標準化した。PaaSが提供していた「自動デプロイ」「オートスケーリング」「ヘルスチェックと自動復旧」といった機能を、IaaSレベルの柔軟性を保ったまま実現できるようになった。

```
PaaSとDocker/Kubernetesの抽象化レイヤー比較:

  従来型PaaS（Heroku, GAE, Cloud Foundry）
  ┌─────────────────────────────────────────────┐
  | アプリケーションコード                      |
  ├─────────────────────────────────────────────┤
  | PaaS固有のパッケージング                    |
  | （Buildpack, SDK, Droplet）                  |
  ├─────────────────────────────────────────────┤
  | PaaS固有のランタイム                         |
  | （Dyno, GAE Sandbox, Diego Cell）            |
  ├─────────────────────────────────────────────┤
  | PaaS固有の運用ツール                         |
  | （ログ, メトリクス, SSL, ルーティング）      |
  ├─────────────────────────────────────────────┤
  | IaaS（隠蔽されている）                      |
  └─────────────────────────────────────────────┘
  -> ポータビリティ: 低い（PaaS間の移行は困難）
  -> カスタマイズ: 限定的
  -> 運用負荷: 低い（PaaSが管理）

  Docker + Kubernetes
  ┌─────────────────────────────────────────────┐
  | アプリケーションコード                      |
  ├─────────────────────────────────────────────┤
  | Dockerfile（業界標準のパッケージング）       |
  ├─────────────────────────────────────────────┤
  | コンテナランタイム（OCI準拠）               |
  ├─────────────────────────────────────────────┤
  | Kubernetes（業界標準のオーケストレーション） |
  | （デプロイ, スケーリング, ネットワーク,      |
  |   ヘルスチェック, サービスディスカバリ）      |
  ├─────────────────────────────────────────────┤
  | IaaS（可視・制御可能）                       |
  └─────────────────────────────────────────────┘
  -> ポータビリティ: 高い（どのクラウドでも動く）
  -> カスタマイズ: 高い（IaaSレベルまで制御可能）
  -> 運用負荷: 高い（自分で管理する必要がある）
```

この図が示しているのは、PaaSとDocker/Kubernetesの本質的なトレードオフだ。PaaSは運用負荷を下げるが、ポータビリティとカスタマイズ性を犠牲にする。Docker/Kubernetesはポータビリティとカスタマイズ性を獲得するが、運用負荷を開発者に戻す。

2014年から2018年にかけて、多くのエンジニアリングチームはこのトレードオフにおいてDocker/Kubernetes側を選んだ。その判断には、技術的な合理性があった。だが同時に、Kubernetes自体の複雑性というコストを過小評価していた側面もある。

### PaaSが苦戦した3つの構造的理由

Docker/Kubernetesの台頭だけがPaaSの停滞の原因ではない。PaaSには構造的な問題が3つあった。

**第一に、ベンダーロックインへの恐怖。** PaaSプラットフォームは、独自のパッケージング、独自のランタイム、独自のアドオンエコシステムを持つ。これらに依存すればするほど、別のプラットフォームへの移行コストが増大する。冒頭で語った私の経験——Herokuからの移行に3ヶ月を要した——は、この問題の典型例だ。

ベンダーロックインの恐怖は、PaaSの採用を検討する段階で最大の障壁となった。技術選定の会議で「5年後にこのPaaSがなくなったらどうする」という問いが出されると、多くのチームは「ならば最初からIaaSで組もう」という結論に至った。実際にはその「5年後」が来る前にプロダクトが終了するケースの方が多いのだが、ロックインへの恐怖は合理的な判断を歪めるほどに強力だった。

**第二に、カスタマイズ性の不足。** PaaSの抽象化は、「80%のユースケースに対して便利」に設計されている。だが残りの20%——データベースの設定変更、ネットワークの細かな制御、特殊なミドルウェアの導入——に対しては、PaaSの壁がそのまま制約となる。

この問題は「成長の天井」と言い換えてもよい。プロダクトが小規模なうちはPaaSの抽象化がぴったりはまる。だが規模が大きくなり、要求が特殊化すると、PaaSの「壁」に突き当たる。そして多くの場合、壁を超える手段はPaaSの中には存在しない。PaaSを離れるか、PaaSの制約に合わせて設計を妥協するかの二択を迫られる。

**第三に、コストの不透明性。** PaaSは一般に、同等のIaaSリソースよりも高額だ。PaaSの料金には、IaaSのインフラコストに加えて、プラットフォームの管理・運用コスト、アドオンサービスのマージンが上乗せされている。

問題は、このコスト構造が不透明であることだ。Herokuの1x Dyno（512MB RAM、1x CPU share）がAWSのどのインスタンスに相当し、実際のコスト差がどれほどかを把握するのは容易ではない。規模が小さいうちは許容できる差額も、プロダクトの成長とともに看過できない金額に膨らむ。

この3つの問題は、PaaSというモデルの構造に起因する。PaaSは抽象化を提供するために独自性を持つ必要があり、その独自性がロックインを生む。抽象化は便利な範囲が限られており、範囲外のユースケースには対応できない。そして抽象化のコストは必然的にIaaSの上に乗るため、コストは常にIaaSより高くなる。

### PaaSの停滞期（2014〜2018年）

2014年から2018年にかけて、PaaSの主要プレイヤーは苦境に立たされた。

Herokuは2010年のSalesforce買収後、投資が鈍化した。競合がコンテナオーケストレーション、エッジコンピューティング、サーバーレスで革新を進める中、Herokuの中核プロダクトはほとんど変わらなかった。2022年4月にはOAuthトークンの流出というセキュリティインシデントが発覚し、同年8月には無料プランの廃止が発表された。Herokuの衰退は、PaaS先駆者の栄枯盛衰を象徴する出来事だ。

GAEは第14回で詳述したように、Flexible Environment（2017年GA）と第二世代ランタイム（2018年、gVisor）で制約を大幅に緩和し、最終的にCloud Run（2019年GA）という新しい形態に進化した。GAEは「PaaSを捨てた」のではなく、「PaaSの思想をコンテナの標準の上に再構築した」と言える。

Cloud Foundryは大企業での採用を維持したものの、Kubernetesとの統合では後手に回った。KubeCF（Cloud FoundryのKubernetes上での実行）やKorifi（Kubernetes上でのCloud Foundry API）といったプロジェクトが進められたが、新規採用は鈍化した。

そして、dotCloudがDockerに転身した2013年の出来事は、PaaS市場全体に対する象徴的なメッセージとなった。PaaS企業自身が、PaaSよりもコンテナ技術に未来を見出した——この事実は、PaaSの停滞を加速させた。

---

## 4. PaaSの復権——「PaaS 2.0」の台頭

### なぜ今、PaaSの思想が戻ってきたのか

2019年以降、PaaSの思想は形を変えて復活しつつある。Cloud Run、Fly.io、Render、Railway、Vercel——これらのプラットフォームは、かつてのPaaSが果たした役割——「インフラを意識せず開発に集中する」——を、コンテナの標準化の上に再構築している。

この「PaaS 2.0」とでも呼ぶべき新世代が受け入れられている理由は、第一世代PaaSが苦戦した3つの問題に対して、技術的な進化が回答を用意したからだ。

**ベンダーロックインの緩和——コンテナ標準化。** Docker/OCI（Open Container Initiative）によるコンテナイメージの標準化は、PaaSのロックイン問題を構造的に変えた。第一世代PaaSでは、プラットフォーム固有のBuildpackやSDKがロックインの源泉だった。PaaS 2.0では、標準的なDockerfileでアプリケーションをパッケージングする。Fly.ioでデプロイしたコンテナイメージは、原理的にはCloud RunでもRailwayでも、あるいは自前のKubernetesクラスタでも動かせる。

もちろん、完全なポータビリティは幻想だ。各プラットフォームの環境変数の扱い、ネットワーク設定、永続ストレージの接続方法には差異がある。だが第一世代PaaSの「アプリケーション全体をプラットフォーム仕様で書き直す」レベルのロックインとは、質的に異なる。

**カスタマイズ性の向上——コンテナという「逃げ道」。** PaaS 2.0は、Dockerコンテナを受け入れるという一点において、根本的にカスタマイズの余地を広げた。Herokuでは「Buildpackがサポートするスタック」にアプリケーションを合わせる必要があったが、PaaS 2.0では「HTTPリクエストに応答するコンテナ」であれば何でもデプロイできる。ランタイムの選択、ライブラリのバージョン、システム依存のツール——すべてDockerfile内で自由に構成できる。

PaaSの抽象化の「壁」に突き当たったとき、Dockerfileの中に退避できる。これは第一世代PaaSにはなかった「逃げ道」であり、PaaS 2.0の採用障壁を大きく下げている。

**コスト構造の改善——従量課金の精緻化。** Fly.ioやCloud Runは、ミリ秒単位やリクエスト単位の従量課金を提供している。Herokuの月額固定のDyno課金と比較すると、使用量に応じたコスト最適化の余地が大きい。特にCloud Runの「ゼロへのスケールダウン」——リクエストがなければ課金されない——は、低トラフィックのアプリケーションにとって劇的なコスト削減を意味する。

### PaaS 2.0の主要プレイヤー

PaaS 2.0のプレイヤーは、それぞれ異なるポジションを取っている。

```
PaaS 2.0 プレイヤーマップ:

  対象領域
  ─────────────────────────────────────────────────────
  フルスタック                    フロントエンド特化
  (バックエンド+DB+ワーカー)     (静的サイト+SSR+Edge)

  ┌─────────────┐               ┌──────────────┐
  | Fly.io      |               | Vercel       |
  | (2017年〜)  |               | (2015年〜,   |
  | Firecracker |               |  旧ZEIT)     |
  | マイクロVM  |               | Next.js統合  |
  | グローバル  |               | Edge         |
  | エッジ展開  |               | Functions    |
  └─────────────┘               └──────────────┘

  ┌─────────────┐               ┌──────────────┐
  | Render      |               | Netlify      |
  | (2019年〜)  |               | (2014年〜)   |
  | Heroku      |               | JAMstack     |
  | 精神的後継  |               | 提唱者       |
  | 統合サービス|               | CDN+         |
  └─────────────┘               | Functions    |
                                └──────────────┘
  ┌─────────────┐
  | Railway     |               ┌──────────────┐
  | (2020年〜)  |               | Cloud Run    |
  | GitHub連携  |               | (2019年〜)   |
  | 即時デプロイ|               | Google Cloud |
  └─────────────┘               | コンテナ     |
                                | サーバーレス |
                                └──────────────┘
```

**Fly.io**（2017年設立、Jerome Gravel-Niquet、Kurt Mackey、Michael Dwan）は、FirecrackerマイクロVMを基盤に、アプリケーションを世界中のエッジロケーションで実行する。創業者のKurt Mackeyは以前MongoHQ（のちにCompose、2015年にIBMに売却）を創業しており、データベースホスティングの経験をPaaSに持ち込んだ。Fly.ioの設計思想は「Herokuの開発者体験を、グローバルなエッジインフラの上に再構築する」ことにある。`fly deploy` というシンプルなコマンドの裏で、コンテナが世界中のデータセンターに分散配置される。

**Render**（2019年設立、Anurag Goel、元Stripeエンジニア）は、Herokuの精神的後継を明確に標榜している。cronジョブ、バックグラウンドワーカー、静的サイトホスティング、継続的デプロイメントを統合的に提供し、Herokuからの移行パスを用意している。2022年のHeroku無料プラン廃止後、Renderへの移行が加速した。

**Railway**（2020年設立）は、GitHubリポジトリとの連携による即時デプロイを核とし、「サーバを意識せずにコードをデプロイする」というPaaSの原初の約束を、コンテナ技術の上に再構築した。2022年にRedpoint VenturesリードのSeries Aで2000万ドルを調達している。

**Vercel**（2015年にZEITとして設立、Guillermo Rauch、2020年にVercelへ改名）とNetlify（2014年設立、Mathias Biilmann）は、フロントエンド特化のPaaSという独自のポジションを確立した。Vercelは自社が開発するNext.jsフレームワークとの深い統合、VercelのEdge Functionsによるエッジ実行を武器とし、フロントエンド開発者にとっての「デファクトPaaS」となっている。Netlifyは2015〜2016年にJAMstack（JavaScript, APIs, Markup）という概念を提唱し、静的サイトジェネレータとCDNの組み合わせによる新しいWebアーキテクチャを普及させた。

**Cloud Run**（2019年4月発表、同年11月GA）は、GAEの精神的後継として第14回で詳述した。標準的なDockerコンテナをサーバーレスに実行し、ゼロへのスケールダウンが可能。Knative Serving APIを実装しており、ポータビリティも確保されている。Cloud RunはGoogle Cloudのマネージドサービスとしてのエンタープライズ信頼性と、PaaS的な開発者体験を両立させている。

### The Twelve-Factor Appの遺産

PaaSの栄枯盛衰を語る上で、The Twelve-Factor Appの存在は特筆に値する。

2011年11月、Heroku共同創業者のAdam Wigginsが12factor.netで公開したこの方法論は、HerokuのPaaS運用で蓄積された知見を12の原則として体系化したものだ。コードベースの一元管理、環境変数による設定、ステートレスなプロセス、ポートバインディング、並行性、使い捨て性——これらの原則は、Heroku上でスケーラブルなアプリケーションを構築するためのベストプラクティスだった。

皮肉なのは、The Twelve-Factor Appの影響力が、Heroku自体の影響力を遥かに超えて広がったことだ。Kubernetesのベストプラクティス、マイクロサービスの設計原則、CI/CDパイプラインの設計——現代のクラウドネイティブ開発の多くの側面が、The Twelve-Factor Appの原則を内包している。Spring Boot、Django、Express.js——主要なWebフレームワークはいずれも、これらの原則を暗黙的に組み込んでいる。

PaaSという形態は停滞したが、PaaSが生み出した設計思想はクラウドネイティブの標準となった。HerokuのBuildpack的な仕組みはCloud Native Buildpacks（CNB）として標準化された。GAEの「制約による設計」は、サーバーレスの設計原則に受け継がれた。Cloud Foundryの `cf push` 体験は、Cloud RunやFly.ioの開発者体験に影響を与えた。

PaaSは死んだのではない。PaaSは溶けたのだ。プラットフォームとしての形を失い、思想としてクラウドネイティブの基盤に溶け込んだ。

```
PaaSの思想の継承:

  第一世代PaaS（2007-2013）          現代の継承先
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Heroku: git pushデプロイ      ->  GitOps, CI/CD自動化
  Heroku: Buildpack             ->  Cloud Native Buildpacks
  Heroku: Twelve-Factor App     ->  クラウドネイティブ設計原則
  Heroku: アドオンエコシステム  ->  マネージドサービス連携
  ──────────────────────────────────────────────────────
  GAE: サンドボックス制約       ->  サーバーレスの設計制約
  GAE: ゼロスケールダウン       ->  Lambda/Cloud Run
  GAE: Datastore（NoSQL強制）   ->  スケーラビリティ優先設計
  ──────────────────────────────────────────────────────
  Cloud Foundry: cf push        ->  PaaS 2.0のUX
  Cloud Foundry: 企業向けPaaS   ->  OpenShift/Tanzu
  ──────────────────────────────────────────────────────
  OpenShift: Kubernetes転換     ->  エンタープライズK8s
```

---

## 5. ハンズオン——PaaSの「世代」を体験する

ここからは、PaaSの2つの世代——第一世代（Herokuモデル）と第二世代（コンテナベース）——の違いを手元の環境で体験する。Herokuの思想を再現するDokku（セルフホスト版Heroku）と、PaaS 2.0の思想を体現するDockerコンテナ直接デプロイを比較し、PaaSの進化が何を変えたのかを実感する。

### 環境

- Docker（Ubuntu 24.04ベースコンテナ）

### 演習1：第一世代PaaSの制約を体験する

```bash
# Docker環境を準備
docker run -it --rm ubuntu:24.04 bash

# 必要なツールのインストール
apt-get update && apt-get install -y python3 python3-pip python3-venv \
  curl git nodejs npm

# 作業ディレクトリ
mkdir -p /app/paas-evolution && cd /app/paas-evolution

# === 第一世代PaaSの制約をシミュレートする ===

# Herokuモデル: Buildpackによるデプロイ
# Procfileとruntime.txtでアプリケーションの構成を宣言する

cat > Procfile << 'EOF'
web: python3 app.py
worker: python3 worker.py
EOF

cat > runtime.txt << 'EOF'
python-3.12.x
EOF

cat > requirements.txt << 'EOF'
flask==3.0.0
redis==5.0.0
EOF

cat > app.py << 'PYEOF'
"""第一世代PaaSモデルのアプリケーション"""
import os
import json

# PaaS制約1: 環境変数で設定を受け取る（Twelve-Factor #3）
PORT = int(os.environ.get("PORT", 8080))
DATABASE_URL = os.environ.get("DATABASE_URL", "sqlite:///local.db")

# PaaS制約2: ファイルシステムは揮発性
# -> 再起動でデータが消える。永続化は外部サービスに委譲
EPHEMERAL_STORAGE = "/tmp/uploads"

def check_paas_constraints():
    """第一世代PaaSの制約を確認する"""
    constraints = {
        "環境変数による設定": bool(os.environ.get("PORT")),
        "揮発性ファイルシステム": True,
        "プロセスの使い捨て性": True,
        "ポートバインディング": f"PORT={PORT}",
        "ログは標準出力へ": True,
    }
    return constraints

# PaaS制約3: ログはファイルではなく標準出力に出す
# （Twelve-Factor #11）
import sys
print(f"[INFO] Starting on port {PORT}", file=sys.stdout)
print(f"[INFO] Database: {DATABASE_URL}", file=sys.stdout)
print(f"[INFO] Constraints: {json.dumps(check_paas_constraints(), indent=2,
      ensure_ascii=False)}", file=sys.stdout)
PYEOF

python3 app.py

echo ""
echo "=== 第一世代PaaSの制約 ==="
echo "1. Procfile: プロセスタイプの宣言（web, worker）"
echo "2. runtime.txt: ランタイムバージョンの指定"
echo "3. requirements.txt: 依存関係の宣言"
echo "4. 環境変数: 設定は環境変数経由（DATABASE_URL等）"
echo "5. 揮発性FS: ファイルシステムへの永続的書き込み不可"
echo ""
echo "問題点:"
echo "  - Procfile/runtime.txtはHeroku固有の仕様"
echo "  - Buildpackがサポートしない構成は使えない"
echo "  - 別のPaaSに移行するとデプロイ設定の書き直しが必要"
```

### 演習2：PaaS 2.0（コンテナベース）との対比

```bash
cd /app/paas-evolution

# === PaaS 2.0: Dockerfileによる標準化 ===

cat > Dockerfile << 'DOCKERFILE'
# PaaS 2.0: 標準的なDockerfileでアプリケーションを定義
# -> Fly.io, Render, Railway, Cloud Run で共通に使える

FROM python:3.12-slim

WORKDIR /app

# 依存関係のインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# アプリケーションコードのコピー
COPY app.py .

# 環境変数のデフォルト値（実行時にオーバーライド可能）
ENV PORT=8080

# ヘルスチェック（PaaS 2.0の多くが対応）
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:${PORT}/health || exit 1

# ポートの公開
EXPOSE ${PORT}

# アプリケーションの起動
CMD ["python3", "app.py"]
DOCKERFILE

echo "=== PaaS 2.0（コンテナベース）の利点 ==="
echo ""
echo "1. Dockerfileは業界標準 -- OCI準拠のコンテナイメージ"
echo "2. 同じイメージが複数のプラットフォームで動作:"
echo "   - fly deploy          (Fly.io)"
echo "   - render deploy       (Render)"
echo "   - railway up          (Railway)"
echo "   - gcloud run deploy   (Cloud Run)"
echo "   - kubectl apply       (Kubernetes)"
echo ""

# 両者の比較を可視化
cat > compare.py << 'PYEOF'
"""第一世代PaaSとPaaS 2.0の比較"""

first_gen = {
    "パッケージング": "Procfile + runtime.txt + Buildpack（プラットフォーム固有）",
    "ランタイム": "プラットフォーム管理（選択肢が限定）",
    "システム依存": "Buildpackが対応するもののみ",
    "ポータビリティ": "低い（移行にはデプロイ設定の書き直しが必要）",
    "カスタマイズ": "限定的（Buildpackの範囲内）",
    "移行コスト": "高い（3ヶ月以上のケースも）",
}

second_gen = {
    "パッケージング": "Dockerfile（OCI標準）",
    "ランタイム": "開発者が自由に選択（Dockerfile内で定義）",
    "システム依存": "任意（apt-get等でインストール可能）",
    "ポータビリティ": "高い（同一イメージが複数環境で動作）",
    "カスタマイズ": "高い（Dockerfile内で自由に構成）",
    "移行コスト": "低い（デプロイコマンドの変更程度）",
}

print("=" * 60)
print("第一世代PaaS vs PaaS 2.0 比較")
print("=" * 60)
for key in first_gen:
    print(f"\n--- {key} ---")
    print(f"  第一世代: {first_gen[key]}")
    print(f"  PaaS 2.0: {second_gen[key]}")
print()
PYEOF

python3 compare.py
```

### 演習3：PaaSのロックイン度を測定する

```bash
cd /app/paas-evolution

cat > lockIn_analysis.py << 'PYEOF'
"""PaaSプラットフォームのロックイン度分析"""
import json

# 各PaaSのロックイン要因を評価する
# スコア: 1（低い）〜 5（高い）

platforms = {
    "Heroku（第一世代）": {
        "パッケージング固有性": 4,  # Buildpack依存
        "ランタイム固有性": 3,      # 限定的なスタック
        "データベース固有性": 2,    # PostgreSQL（標準的）
        "アドオン依存": 5,          # Herokuアドオンエコシステム
        "デプロイ設定固有性": 4,    # Procfile, app.json
        "ネットワーク設定固有性": 3, # Heroku固有のルーティング
    },
    "GAE Standard（第一世代）": {
        "パッケージング固有性": 5,  # app.yaml + SDK
        "ランタイム固有性": 5,      # 修正されたランタイム
        "データベース固有性": 5,    # Datastore（独自NoSQL）
        "アドオン依存": 4,          # Google固有API
        "デプロイ設定固有性": 5,    # app.yaml必須
        "ネットワーク設定固有性": 4, # GAE固有のルーティング
    },
    "Cloud Run（PaaS 2.0）": {
        "パッケージング固有性": 1,  # 標準Dockerコンテナ
        "ランタイム固有性": 1,      # 任意のランタイム
        "データベース固有性": 2,    # Cloud SQL（標準的）
        "アドオン依存": 2,          # GCPサービス連携
        "デプロイ設定固有性": 2,    # service.yaml（Knative互換）
        "ネットワーク設定固有性": 2, # 標準的なHTTP
    },
    "Fly.io（PaaS 2.0）": {
        "パッケージング固有性": 1,  # 標準Dockerコンテナ
        "ランタイム固有性": 1,      # 任意のランタイム
        "データベース固有性": 2,    # PostgreSQL（標準的）
        "アドオン依存": 2,          # Fly固有機能あり
        "デプロイ設定固有性": 2,    # fly.toml
        "ネットワーク設定固有性": 3, # Fly固有のネットワーク
    },
}

print("=== PaaSプラットフォーム ロックイン度分析 ===")
print()
for name, scores in platforms.items():
    total = sum(scores.values())
    avg = total / len(scores)
    max_score = max(scores.values())
    max_factor = [k for k, v in scores.items() if v == max_score][0]
    print(f"■ {name}")
    print(f"  総合スコア: {total}/30 (平均: {avg:.1f}/5.0)")
    print(f"  最大ロックイン要因: {max_factor} ({max_score}/5)")
    for factor, score in scores.items():
        bar = "█" * score + "░" * (5 - score)
        print(f"    {factor:24s} [{bar}] {score}/5")
    print()

print("考察:")
print("  第一世代PaaS（Heroku, GAE Standard）は")
print("  ロックインスコアが高い（21-28/30）。")
print("  PaaS 2.0（Cloud Run, Fly.io）はコンテナ標準化により")
print("  スコアが大幅に低下（10-11/30）している。")
print()
print("  ただし、PaaS 2.0でもデータベースやネットワーク設定には")
print("  プラットフォーム固有の要素が残る。完全なポータビリティは")
print("  幻想であり、「ロックインの度合い」で判断すべきである。")
PYEOF

python3 lockIn_analysis.py
```

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/15-paas-rise-and-fall/` に用意してある。

---

## 6. まとめと次回予告

### この回のまとめ

第15回では、PaaSの栄枯盛衰を俯瞰し、「便利すぎる抽象化」がなぜ苦戦し、そしてどのように形を変えて復活しつつあるかを読み解いた。

**PaaSの栄光期（2008〜2013年）には、複数のアプローチが競い合った。** Heroku（2007年）は開発者体験を、GAE（2008年）は制約によるスケーラビリティを、Cloud Foundry（2011年、VMware）はエンタープライズ向けオープンソースPaaSを、OpenShift（2011年、Red Hat）はRHELベースの企業向けPaaSを提示した。各プラットフォームは「インフラを意識しない開発」という共通のビジョンを、異なる設計哲学で追求した。

**PaaS企業dotCloudがDockerを生み出し、自らPaaSを捨てた（2013年）ことは象徴的だった。** PaaS企業が自社の内部技術をオープンソース化し、その技術がPaaSそのものを脅かす存在に成長した。Docker（2013年）とKubernetes（2014年）の台頭は、PaaSの構造的な問題——ベンダーロックイン、カスタマイズ性の不足、コストの不透明性——を顕在化させた。

**PaaSが苦戦した理由は3つの構造的問題に集約される。** (1) プラットフォーム固有の仕様によるベンダーロックイン。(2) 抽象化の「壁」を超えられないカスタマイズ性の限界。(3) IaaSに対するコストプレミアムの不透明性。Docker/Kubernetesはこれらの問題に対して、ポータビリティと柔軟性で回答した——ただし運用負荷の増大という代償付きで。

**PaaS 2.0は、コンテナの標準化の上にPaaSの思想を再構築した。** Cloud Run（2019年、Google）、Fly.io（2017年）、Render（2019年）、Railway（2020年）、Vercel（2015年、旧ZEIT）は、標準的なDockerコンテナを受け入れることでロックインを緩和し、コンテナ内のカスタマイズ自由度を確保し、従量課金の精緻化でコスト構造を改善した。

**PaaSは死んでいない。PaaSの思想はクラウドネイティブの基盤に溶け込んだ。** The Twelve-Factor App（2011年、Adam Wiggins）はクラウドネイティブ設計の標準となり、BuildpackはCloud Native Buildpacksに進化し、「ゼロへのスケールダウン」はサーバーレスの核心概念となった。PaaSという「プラットフォーム」は停滞したが、PaaSが生み出した「思想」は生き続けている。

冒頭の問いに答えよう。PaaSの夢——「インフラを忘れて開発に集中する」——は潰えていない。ただし、その実現手段は変わった。プラットフォーム固有の抽象化ではなく、コンテナという業界標準の上に構築された抽象化として。制約の性質が「ベンダー固有」から「業界標準」に変わったことで、PaaSの夢はより持続可能な形で実現されつつある。

### 次回予告

第16回では、「SaaSモデル——ソフトウェアを『所有しない』時代」を取り上げる。

PaaSが「インフラの抽象化」であるなら、SaaSは「ソフトウェアそのものの抽象化」だ。オンプレミスのバージョン管理サーバをGitHubに、自前のCIサーバをGitHub Actionsに、自社運用のチャットサーバをSlackに——「自分で運用する」から「サービスとして利用する」への移行は、何を解放し、何を失わせたのか。

Salesforceの「No Software」キャンペーン（1999年）からSaaS疲れの現在まで、ソフトウェアの「所有」と「利用」の境界線を問い直す。

---

## 参考文献

- VMware Press Release, "VMware Introduces Cloud Foundry, The Industry's First Open PaaS", April 2011. <https://news.broadcom.com/releases/cloud-foundry-apr2011>
- Red Hat Blog, "PaaS to Kubernetes to cloud services: Looking back at 10 years of Red Hat OpenShift", 2021. <https://www.redhat.com/en/blog/paas-kubernetes-cloud-services-looking-back-10-years-red-hat-openshift>
- Wikipedia, "Docker, Inc." <https://en.wikipedia.org/wiki/Docker,_Inc.>
- InfoWorld, "The sun sets on original Docker PaaS". <https://www.infoworld.com/article/2244891/the-sun-sets-on-original-docker-paas.html>
- Heroku FAQ, "Removal of Heroku Free Product Plans FAQ". <https://help.heroku.com/RSBRUH58/removal-of-heroku-free-product-plans-faq>
- RedMonk, "The End of Heroku's Free Tier", December 2022. <https://redmonk.com/kholterhoff/2022/12/01/the-end-of-herokus-free-tier/>
- Docker Blog, "10 Years Since Kubernetes Launched at DockerCon", 2024. <https://www.docker.com/blog/10-years-since-kubernetes-launched-at-dockercon/>
- Adam Wiggins, "The Twelve-Factor App", 2011. <https://12factor.net/>
- Heroku Blog, "Heroku Open Sources the Twelve-Factor App Definition". <https://www.heroku.com/blog/heroku-open-sources-twelve-factor-app-definition/>
- Wikipedia, "Cloud Foundry". <https://en.wikipedia.org/wiki/Cloud_Foundry>
- Wikipedia, "OpenShift". <https://en.wikipedia.org/wiki/OpenShift>
- Google Cloud Blog, "Cloud Run: Bringing serverless to containers", April 2019. <https://cloud.google.com/blog/products/serverless/cloud-run-bringing-serverless-to-containers>
- Vercel Blog, "ZEIT is now Vercel", April 2020. <https://vercel.com/blog/zeit-is-now-vercel>
- Biilmann Blog, "10 Years of Netlify, from Jamstack to Agent Driven Development". <https://biilmann.blog/articles/10-years-of-netlify/>
- TechCrunch, "Fly.io wants to change the way companies deploy apps at the edge", July 2022. <https://techcrunch.com/2022/07/28/fly-io-wants-to-change-the-way-companies-deploy-apps-at-the-edge/>
- TechCrunch, "Railway snags $20M to streamline deployment of apps/services", May 2022. <https://techcrunch.com/2022/05/31/railway-snags-20m-to-streamline-the-process-of-deploying-apps-and-services/>
- Gartner, "Gartner Forecasts Worldwide Public Cloud End-User Spending to Total $723 Billion in 2025", November 2024. <https://www.gartner.com/en/newsroom/press-releases/2024-11-19-gartner-forecasts-worldwide-public-cloud-end-user-spending-to-total-723-billion-dollars-in-2025>
