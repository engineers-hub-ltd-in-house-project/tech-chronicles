# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第13回：Heroku——「git pushでデプロイ」が変えたもの

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- PaaS（Platform as a Service）がIaaSの上に構築した「開発者体験」という抽象化の本質
- Heroku創業（2007年）からSalesforce買収（2010年）、無料プラン廃止（2022年）までの軌跡
- `git push heroku main` が実現した「デプロイの民主化」の技術的仕組み
- Dyno、Buildpack、Procfile——Herokuが確立したPaaSの基本概念
- The Twelve-Factor App（2011年、Adam Wiggins）の12原則とその現代的意義
- PaaSの制約がもたらす「自由の喪失」と「障害時の無力感」
- Cedar stackによるポリグロット化とbuildpackアーキテクチャ
- Dokku（2013年）——セルフホスト版Herokuが示したPaaS思想の普遍性
- Cloud Foundry（2011年）、OpenShift——企業向けPaaSの系譜
- PaaSの光と影を体験するハンズオン（Dokku環境構築とデプロイ）

---

## 1. デプロイスクリプトの地獄

私が初めて `git push heroku main` を実行したのは、2010年の秋だった。

当時の私のデプロイ手順は、控えめに言っても地獄だった。手元のRailsアプリケーションを本番サーバに届けるために、私は以下のような手順を毎回踏んでいた。SSHで本番サーバにログインする。`git pull` でソースコードを取得する。`bundle install` で依存ライブラリをインストールする。`rake db:migrate` でデータベースのマイグレーションを実行する。`rake assets:precompile` でアセットをコンパイルする。Unicornを再起動する。Nginxの設定を確認する。ログを `tail -f` で監視して、エラーが出ていないことを祈る。

この手順をシェルスクリプトにまとめていたが、スクリプトの中間で失敗したときのロールバック処理は不完全で、本番環境と開発環境の微妙な差異に何度も悩まされた。Rubyのバージョンが違う、OpenSSLのバージョンが違う、ImageMagickがインストールされていない——「手元では動くのに」という言い訳を何度も繰り返した。

Capistrano（2005年にJamis Buckが開発したRuby向けデプロイ自動化ツール）を導入して多少は改善された。だがそれでも、デプロイ先のサーバの構成管理は私の責任だった。Nginxの設定、PostgreSQLのチューニング、ログローテーション、SSL証明書の更新——アプリケーションのコードを書く時間と、インフラを維持する時間の比率が、次第に後者に傾いていった。

そんなとき、同僚のRubyエンジニアがHerokuを教えてくれた。「`git push` するだけでデプロイできる」と言うのだ。信じられなかった。

```bash
git push heroku main
```

この一行を実行したとき、ターミナルにビルドログが流れ始めた。Rubyのバージョンが自動検出される。`bundle install` が走る。アセットがコンパイルされる。スラグ（slug）が生成される。新しいダイノ（dyno）にスラグが配信される。URLが表示される。アクセスすると、私のアプリケーションがインターネット上で動いている。

サーバにSSHでログインしていない。Nginxの設定を書いていない。OSのパッケージを手動でインストールしていない。デプロイスクリプトのメンテナンスをしていない。ただ、Gitでプッシュしただけだ。

衝撃だった。と同時に、一つの疑問が頭をよぎった。「この裏側で何が起きているのか、私にはまったく見えない。何かが壊れたとき、私は何ができるのだろう」

この問いが、PaaS（Platform as a Service）の本質を射抜いている。インフラを意識しない開発体験は、開発者を何から解放し、何から切り離したのか。この回では、Herokuが切り拓いたPaaSの世界を、その光と影の両面から掘り下げる。

あなたは、自分のアプリケーションがデプロイされるまでに何が起きているか——すべて説明できるだろうか。

---

## 2. Herokuの軌跡——Ruby専用プラットフォームからPaaSの代名詞へ

### 創業——ブラウザの中のRuby

2007年6月、James Lindenbaum、Adam Wiggins、Orion Henryの3人は、サンフランシスコでHerokuを創業した。当初のビジョンは「ブラウザ内でRubyアプリケーションを構築・デプロイできるプラットフォーム」だった。Ruby on Railsの学習障壁を下げ、プログラミング教育を支援するという目的があった。

このアイデアは、Y Combinatorの2008年冬バッチ（W08）に採択された。だが創業者たちは、すぐにあることに気づく。ユーザの多くは、教育目的でプラットフォームを使っていなかった。自分のRubyアプリケーションを手軽にデプロイする手段として使っていたのだ。

この発見がHerokuの方向転換を決定づけた。ブラウザ内エディタから、コマンドラインベースのデプロイプラットフォームへ。開発者が手元の環境でコードを書き、`git push` するだけで本番環境にデプロイできる——この体験を研ぎ澄ませることに集中した。

初期のHerokuが稼働していたスタックは「Argent Aspen」（2009年）と呼ばれ、Ruby 1.8.6のみをサポートし、Ruby on Railsアプリケーション専用だった。制約は厳しかったが、ターゲットは明確だった。2000年代後半のRuby on Railsコミュニティは急速に成長しており、37signals（現Basecamp）のDHH（David Heinemeier Hansson）が2005年にRailsを公開して以来、Web開発の世界でRubyは最もホットな言語の一つだった。Herokuはこの波に乗った。

### `git push` というインターフェースの革新

Herokuが実現した最も重要なイノベーションは、技術的に高度なものではない。`git push` をデプロイのインターフェースとしたことだ。

2000年代後半、Webアプリケーションのデプロイは、開発者にとって依然として苦痛な作業だった。FTPでファイルをアップロードする（さらに原始的な方法）、SSHでサーバにログインして手動で操作する、Capistranoのようなデプロイ自動化ツールを設定する——いずれも、開発者がインフラの知識を持ち、サーバの状態を管理することを前提としていた。

Herokuは、この前提を覆した。Gitは開発者が日常的に使うツールだ。ソースコードのバージョン管理のために既に `git commit` を実行している。そのワークフローに `git push heroku main` を一行追加するだけで、アプリケーションが本番環境にデプロイされる。新しいツールを学ぶ必要がない。新しい概念を理解する必要がない。既存のワークフローの延長線上にデプロイがある。

Herokuは「新しいデプロイツール」を作ったのではない。「既存のGitワークフローにデプロイ機能を接木した」のだ。

### Salesforceによる買収と黄金期

Herokuの急成長は業界の注目を集めた。2010年12月8日、SalesforceはHerokuを約2億1,200万ドルの現金で買収することを発表した。買収完了は2011年1月3日。Herokuの累計調達額がわずか1,300万ドルだったことを考えると、驚異的なリターンだった。

Salesforceの資金力を得たHerokuは、2011年に二つの決定的な進化を遂げる。

**第一の進化：Cedar stack（Celadon Cedar）によるポリグロット化。** 2011年5月にパブリックベータとして発表されたCedar stackは、Herokuの設計思想を根本から変えた。Aspen/Bambooの時代、HerokuはRuby専用プラットフォームだった。Cedarは「言語に依存しない汎用スタック」として設計され、buildpackという抽象化レイヤーを通じて任意の言語をサポートする。2011年夏までに、Ruby、Node.js、Clojure、Java、Python、Scalaが公式サポートされた。

**第二の進化：The Twelve-Factor App方法論の公開。** Heroku共同創業者のAdam Wigginsは、2011年に12factor.netでThe Twelve-Factor Appを公開した。Herokuで数百のSaaSアプリケーションを運用する中で蓄積された知見を、12の原則として体系化したものだ。この方法論は、Heroku上のアプリケーション設計指針であると同時に、クラウドネイティブアプリケーション設計の普遍的原則として、PaaSの枠を超えて広く受容された。

この時期のHerokuは文字通り輝いていた。無料プランが存在し、`heroku create` と `git push` の二行でアプリケーションをインターネットに公開できた。プログラミングブートキャンプの教材、ハッカソンのデプロイ先、個人プロジェクトのホスティング——「最初のデプロイ」の場所として、Herokuは世界中の開発者に選ばれていた。

### 衰退と無料プラン廃止

だが、黄金期は永遠には続かなかった。Salesforce傘下でのHerokuは次第に投資の優先順位が下がり、DockerとKubernetesの台頭（2013年〜2015年）がIaaSの柔軟性を劇的に向上させると、「PaaSの制約」が相対的に目立つようになった。

決定的な転機は2022年8月25日に訪れた。Herokuは無料プランの廃止を発表し、11月28日に無料ダイノ、無料Heroku Postgresの提供を終了した。ゼネラルマネージャのBob Wiseは「不正利用と悪用への対応に膨大なリソースを費やしていた」ことを理由に挙げた。無料プランに依存していた教育現場、個人開発者、オープンソースプロジェクトが一斉に代替先を探し始め、Railway、Render、Fly.ioがこの移行需要を吸収した。

```
Herokuの軌跡:

  2007年  創業（James Lindenbaum, Adam Wiggins, Orion Henry）
  │       ブラウザ内Rubyエディタ → CLIデプロイへ転換
  │
  2009年  Argent Aspen stack（Ruby専用）
  │
  2010年  Badious Bamboo stack
  │       12月: Salesforceが$212Mで買収
  │
  2011年  Cedar stack → ポリグロット化（Ruby, Node.js, Java, Python...）
  │       Adam Wiggins: The Twelve-Factor App公開
  │       Buildpack / Procfile / Dyno の概念確立
  │
  2011-   黄金期: 無料プラン、開発者コミュニティの中心
  2018年
  │
  2022年  無料プラン廃止（11月28日）
  │       Railway, Render, Fly.ioへの移行加速
  │
  現在    Fir世代（ARM, コンテナベース）への移行中
```

---

## 3. PaaSの技術設計——Herokuが確立した概念群

### Dyno——コンテナの先駆け

Herokuの実行単位は「Dyno」と呼ばれる。Dynoは、Herokuが管理するLinuxコンテナだ。OSコンテナ化技術を基盤とし、追加のカスタム強化でプロセス間の隔離を実現している。

前回のマルチテナント設計で解説したcgroupsとnamespacesの技術が、ここでも使われている。各Dynoは独立したプロセス空間を持ち、メモリとCPUの使用量が制限される。あるDynoのクラッシュが他のDynoに影響することはない。

Dynoには種類がある。「Web Dyno」はHTTPリクエストを受け付ける唯一のプロセスタイプであり、Herokuのルータから外部トラフィックが転送される。「Worker Dyno」はバックグラウンドジョブを処理する。この分離は、Unixの「一つのことをうまくやる」哲学に通じる。Webリクエストの処理と、バックグラウンドの重い処理を、同一プロセスで行わない。それぞれに適した実行環境を割り当てる。

ここで見逃してはならないのは、Dynoという概念が生まれた時期だ。Docker（2013年）よりも前に、Herokuは「アプリケーションをコンテナ化された環境で実行する」というモデルを確立していた。もちろん、Herokuが使っていたのはDockerコンテナではなくLXCベースの独自コンテナ技術だが、「アプリケーションの実行環境をパッケージ化し、隔離された環境で動かす」という思想は共通している。PaaSは、コンテナの実用化においてIaaS+Dockerに先んじていたとも言える。

### Buildpack——言語検出からビルドまでの自動化

Cedar stack以降のHerokuで、`git push` がデプロイとして機能する仕組みの中核がbuildpackだ。

`git push heroku main` を実行すると、以下の処理が順番に行われる。

```
git push heroku main 実行後の処理フロー:

  ① Gitリポジトリの受信
     Herokuのgitリモートがpushを受け取る
     ↓
  ② 言語検出（Detect）
     buildpackがリポジトリを走査し、言語を判定
     - Gemfile → Ruby
     - package.json → Node.js
     - requirements.txt → Python
     - pom.xml → Java
     ↓
  ③ コンパイル（Compile）
     依存ライブラリのインストール
     アセットのコンパイル
     ランタイムの準備
     ↓
  ④ スラグ生成（Release）
     実行可能なアーティファクト（slug）を生成
     圧縮されたファイルシステムスナップショット
     ↓
  ⑤ Dynoへの配信
     新しいDynoにslugを展開
     Procfileに基づいてプロセスを起動
     ↓
  ⑥ ルーティング
     Herokuルータが新しいDynoにトラフィックを転送
```

buildpackの設計は巧みだ。「Detect」「Compile」「Release」の3フェーズで構成され、各フェーズはシェルスクリプトとして実装されている。言語ごとに異なるbuildpackを用意することで、Herokuのプラットフォーム本体は言語に依存しない。新しい言語のサポートを追加するには、新しいbuildpackを書けばいい。プラットフォームのコア部分を変更する必要がない。

この分離の思想は、Unixの哲学——「メカニズムとポリシーを分離する」——そのものだ。buildpackはポリシー（どの言語をどうビルドするか）を定義し、Herokuのプラットフォームはメカニズム（ビルドの実行、スラグの配信、Dynoの管理）を提供する。

さらに重要なのは、buildpackがオープンソースであり、誰でもカスタムbuildpackを作成できることだ。公式にサポートされていない言語やフレームワークであっても、buildpackを書けばHeroku上で動かせる。この拡張性が、Herokuのエコシステムを大きく広げた。2018年1月には、PivotalとHerokuが共同でCloud Native Buildpacksプロジェクトを発足させ、buildpackの概念をHeroku以外のプラットフォーム（Google Cloud、Gitlab、Knative等）でも使えるように標準化した。Herokuが生み出した概念が、プラットフォームの壁を超えて普及した好例だ。

### Procfile——宣言的プロセス定義

Herokuが導入したもう一つの重要な概念がProcfileだ。アプリケーションのルートディレクトリに置かれる、シンプルなテキストファイルである。

```
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq
clock: bundle exec clockwork clock.rb
```

Procfileの各行は「プロセスタイプ名: コマンド」の形式で、アプリケーションがどのようなプロセスで構成されるかを宣言する。`web` はHTTPリクエストを受け付けるプロセス、`worker` はバックグラウンドジョブを処理するプロセス、`clock` は定期実行タスクを処理するプロセスだ。

Procfileの革新は「アプリケーションの実行方法を、アプリケーション自身が宣言する」という発想にある。従来、アプリケーションの起動方法はインフラ側の設定ファイル（Nginx設定、Supervisord設定、init.dスクリプト等）に記述されていた。アプリケーションのコードとインフラの設定が別々の場所にあり、両者の整合性を保つのは人間の責任だった。Procfileは、この責任をアプリケーションのリポジトリに統合した。

この「宣言的プロセス定義」の思想は、後のKubernetesのDeployment YAMLや、docker-compose.ymlのservices定義に受け継がれている。アプリケーションが「何を実行するか」を自分自身で宣言し、プラットフォームがその宣言に従って実行する——この分離は、クラウドネイティブ設計の基本パターンとなった。

### アドオン——サービスの組み合わせ

Herokuのアドオンエコシステムも特筆に値する。データベース、キャッシュ、モニタリング等の周辺サービスを `heroku addons:create` コマンド一つで追加できる。追加されたアドオンの接続情報は環境変数として自動的にDynoに注入される。Heroku Postgresを追加すれば `DATABASE_URL` が設定され、アプリケーションはこの環境変数を読むだけでデータベースに接続できる。The Twelve-Factor Appの第3原則「Config」を、プラットフォームの機能として強制した設計だ。

### The Twelve-Factor App——PaaSから生まれたクラウドネイティブの原則

2011年にAdam Wigginsが12factor.netで公開したThe Twelve-Factor Appは、Herokuの運用経験を12の原則に蒸留したものだ。依存関係の明示的宣言（II）、環境変数による設定管理（III）、ビルド・リリース・実行の厳密な分離（V）、ステートレスプロセス（VI）、プロセスモデルによるスケールアウト（VIII）、高速起動とグレースフルシャットダウン（IX）——これら12の原則はそれぞれ、Herokuの設計に直結している。

原則IとVは `git push` によるデプロイフローそのものだ。原則IIはbuildpackによる依存解決、原則IIIはアドオンの環境変数注入、原則VIとVIIIはDynoとProcfileの設計に対応する。つまり、The Twelve-Factor Appは「Heroku上でうまく動くアプリケーションの設計原則」として始まったが、その原則は「クラウド環境でうまく動くアプリケーションの設計原則」と本質的に同一だった。Herokuの制約がそのまま、クラウドネイティブ設計のベストプラクティスになったのだ。

この事実は示唆に富む。制約は必ずしも悪ではない。適切に設計された制約は、良い設計を強制する。Herokuの「ファイルシステムに永続データを書けない」という制約は、開発者にステートレスなアプリケーション設計を強いた。「環境変数でしか設定を渡せない」という制約は、設定のハードコードを防いだ。これらの制約が生んだ設計パターンは、Heroku以外の環境でも有効だった。だからこそ、The Twelve-Factor Appはプラットフォーム固有の文書ではなく、クラウドネイティブの普遍的原則として受容された。

### PaaSの抽象化レイヤー——IaaSとの比較

ここで、IaaSとPaaSの抽象化レイヤーを明確に比較しておこう。第11回でIaaSが「計算・ストレージ・ネットワークの三本柱をAPIで統合的に抽象化したプログラマブルインフラ」であることを解説した。PaaSは、このIaaSの上にさらに一段の抽象化を積む。

```
IaaS vs PaaS の抽象化レイヤー:

  ┌──────────────────────────────────────────┐
  │  あなたが管理するもの                      │
  ├────────────────────┬─────────────────────┤
  │       IaaS         │       PaaS          │
  │  (AWS EC2等)       │  (Heroku等)         │
  ├────────────────────┼─────────────────────┤
  │ アプリケーション    │ アプリケーション     │
  │ ランタイム          │                     │
  │ ミドルウェア        │                     │
  │ OS                 │                     │
  ├────────────────────┼─────────────────────┤
  │  クラウドが管理     │  クラウドが管理      │
  ├────────────────────┼─────────────────────┤
  │ 仮想化             │ ランタイム           │
  │ ストレージ          │ ミドルウェア         │
  │ ネットワーク        │ OS                  │
  │ 物理サーバ          │ 仮想化              │
  │                    │ ストレージ           │
  │                    │ ネットワーク         │
  │                    │ 物理サーバ           │
  └────────────────────┴─────────────────────┘

  IaaS: OSより下をクラウドが管理
  PaaS: アプリケーションより下を全てクラウドが管理
```

PaaSでは開発者が管理する範囲は「アプリケーションのコード」だけだ。運用負荷からの解放は強力だが、制約も等しく強力である。ランタイムのバージョンはプラットフォーム提供のものに限られ、OSレベルのカスタマイズはできず、障害時にプラットフォーム内部に踏み込めない。

私がHerokuで最も痛感したのは、障害時の無力感だった。IaaSならSSHでサーバにログインし、プロセスの状態を確認できる。PaaSでは `heroku logs --tail` でログを眺めるしかない。第12回で解説したマルチテナンシーの隔離と同じ構造だ——隔離はセキュリティのために必要だが、可視性と制御性を犠牲にする。

---

## 4. Herokuの影響圏——PaaSエコシステムの広がり

### Cloud FoundryとOpenShift——企業のためのPaaS

Herokuが「開発者個人のためのPaaS」なら、企業はどうか。2011年4月、VMwareはCloud Foundryをオープンソースのエンタープライズ向けPaaSとして発表した。Derek Collisonのチームが2009年から開発を進めていたもので、Apache 2.0ライセンスで公開された。企業が自社のデータセンターやプライベートクラウド上にPaaS環境を構築できることが最大の特徴だった。2013年にPivotalに移管され、2015年にLinux Foundation傘下のCloud Foundry Foundationが設立された。

Red HatのOpenShift（2011年〜）も企業向けPaaSとして登場し、2015年のOpenShift 3でKubernetesを基盤とするアーキテクチャに転換した。Kubernetesがデファクトスタンダードとなったことで、OpenShiftは「Kubernetesの上に構築されたエンタープライズPaaS」として生き残ることができた。

HerokuがマネージドPaaS（プラットフォームの運用をHerokuが行う）であるのに対し、Cloud FoundryやOpenShiftは「自社運用可能なPaaS」だ。PaaSの利便性を得つつ、データの所在とプラットフォームの管理権限を自社に保持したい企業にとって、この選択肢は重要だった。

### Dokku——100行のBashが証明したPaaS思想の普遍性

2013年6月、Jeff Lindsay（progrium）は、Dokkuを公開した。「The smallest PaaS implementation you've ever seen」——当初は100行未満のBashスクリプトで書かれた、セルフホスト版Herokuだった。

DokkuはDocker、Herokuのbuildpack、gitreceive（Git pushを受信するツール）の3つを組み合わせて構築されている。自分のサーバにDokkuをインストールし、`git push dokku main` すると、Herokuと同じようにbuildpackがアプリケーションを検出・ビルドし、Dockerコンテナとして起動する。

Dokkuの意義は技術的な完成度にあるのではない。「Herokuの開発者体験は、100行のBashで再現できる」という事実を示したことにある。PaaSの核心は、何百万ドルもの投資や何千台ものサーバではなく、「Gitリポジトリの受信→言語検出→ビルド→コンテナ起動→ルーティング」という一連のワークフローを自動化するパイプラインだ。この本質が、100行のスクリプトで表現できるほどシンプルだったという事実は、Herokuの設計思想の普遍性を証明している。

Dokkuは現在も活発に開発が続いており、プラグインシステムで機能を拡張できる本格的なセルフホストPaaSに成長している。個人開発者やスタートアップが、VPS一台の上にHeroku的な体験を構築するための現実的な選択肢だ。

### PaaSの思想が浸透した現代のツール群

Herokuが確立した「git pushでデプロイ」の思想は、形を変えて現代のツール群に浸透している。

Vercel、Netlify、Railway、Fly.io——これらの現代的プラットフォームに共通するのは、Herokuが確立した二つの原則だ。「開発者が既に使っているツール（Git）をデプロイのインターフェースとする」こと、そして「インフラの詳細をプラットフォームが管理し、開発者はコードに集中する」こと。Herokuは2022年の無料プラン廃止で多くのユーザを失ったが、その設計思想はこれらの後継を通じて生き続けている。

---

## 5. ハンズオン——Dokkuで「自分だけのHeroku」を体験する

ここからは、Dokkuを使って「自分だけのPaaS」を構築し、`git push` デプロイの裏側で何が起きているかを体験する。Herokuが隠蔽していた処理の一つ一つを、自分の手で確認できるのがDokkuの利点だ。

### 環境

- Docker（Ubuntu 24.04ベースコンテナ）

### 演習1：PaaSの処理フローを手動で再現する

まずは、PaaSが裏側で行っている処理を手動で一つずつ実行し、何が起きているかを理解する。Dokkuのインストールにはsystemdが必要であり、通常のDockerコンテナでは完全なDokkuは動作しない。そこでこの演習では、buildpackを手動で実行し、PaaSのビルドパイプラインを理解する。

```bash
# Docker環境を準備
docker run -it --rm ubuntu:24.04 bash

# 必要なツールのインストール
apt-get update && apt-get install -y git curl nodejs npm python3 python3-pip python3-venv

# サンプルアプリケーションを作成（Python Flask）
mkdir -p /app/myproject && cd /app/myproject

# Flaskアプリケーション
cat > app.py << 'PYEOF'
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return f"Hello from my PaaS! Running on port {os.environ.get('PORT', '5000')}"

@app.route('/health')
def health():
    return "OK"

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
PYEOF

# 依存ファイル（Twelve-Factor原則II: Dependencies）
cat > requirements.txt << 'EOF'
flask==3.1.0
gunicorn==23.0.0
EOF

# Procfile（Twelve-Factor原則VIII: Concurrency）
cat > Procfile << 'EOF'
web: gunicorn app:app --bind 0.0.0.0:$PORT
worker: python3 -c "print('Worker process started')"
EOF

echo "=== アプリケーション構造 ==="
ls -la
echo ""
echo "=== Procfile の内容 ==="
cat Procfile
```

### 演習2：PaaSのビルドフェーズを再現する

```bash
# === PaaSビルドパイプラインの手動再現 ===

cd /app/myproject

# Phase 1: 言語検出（Detect）
# buildpackはこのロジックで言語を判定する
echo "=== Phase 1: 言語検出 ==="
if [ -f "requirements.txt" ]; then
    echo "検出: Python（requirements.txt が存在）"
    DETECTED_LANG="python"
elif [ -f "Gemfile" ]; then
    echo "検出: Ruby（Gemfile が存在）"
    DETECTED_LANG="ruby"
elif [ -f "package.json" ]; then
    echo "検出: Node.js（package.json が存在）"
    DETECTED_LANG="nodejs"
else
    echo "言語を検出できません"
    exit 1
fi
echo ""

# Phase 2: 依存解決（Compile）
echo "=== Phase 2: 依存解決 ==="
python3 -m venv /app/venv
/app/venv/bin/pip install -r requirements.txt 2>&1 | tail -5
echo ""

# Phase 3: Procfileパース
echo "=== Phase 3: Procfile パース ==="
echo "定義されたプロセスタイプ:"
while IFS=: read -r ptype cmd; do
    ptype=$(echo "$ptype" | xargs)
    cmd=$(echo "$cmd" | xargs)
    echo "  - $ptype: $cmd"
done < Procfile
echo ""

# Phase 4: 環境変数の注入（Twelve-Factor原則III: Config）
echo "=== Phase 4: 環境変数の注入 ==="
export PORT=8080
export DATABASE_URL="postgres://user:pass@db-host:5432/myapp"
export REDIS_URL="redis://redis-host:6379/0"
echo "PORT=$PORT"
echo "DATABASE_URL=$DATABASE_URL"
echo "REDIS_URL=$REDIS_URL"
echo ""
echo "PaaSではアドオン追加時にこれらが自動注入される"
echo ""

# Phase 5: プロセス起動
echo "=== Phase 5: webプロセス起動 ==="
# Procfileのwebエントリからコマンドを抽出
WEB_CMD=$(grep "^web:" Procfile | cut -d: -f2- | xargs)
echo "実行コマンド: $WEB_CMD"
echo ""
echo "（実際のPaaSではここでDyno/コンテナが起動する）"
```

### 演習3：Twelve-Factor Appの原則を体験する

```bash
# === Twelve-Factor Appの主要原則を体験 ===

cd /app/myproject

# 原則III: Config — 設定を環境変数に格納する
echo "=== 原則III: Config ==="
echo "悪い例: db_host = 'production-db.example.com'  # ハードコード"
echo "良い例: db_url = os.environ['DATABASE_URL']    # 環境変数から取得"
echo "→ 開発/ステージング/本番で同じコード、異なる設定"
echo ""

# 原則VI: Processes — ステートレスなプロセス
echo "=== 原則VI: Processes（ステートレス） ==="
TMPDIR=$(mktemp -d)
echo "session_data_12345" > "$TMPDIR/session.txt"
echo "Dyno Aでセッションを保存: $(cat "$TMPDIR/session.txt")"
rm -rf "$TMPDIR"
echo "Dyno Aが再起動 → セッションデータ消失"
echo "→ セッションはRedis等の外部ストアに保存すべき"
echo ""

# 原則IX: Disposability — 高速な起動とグレースフルシャットダウン
echo "=== 原則IX: Disposability ==="
echo "Dynoはデプロイ時、日次再起動、スケール変更で再作成される"
echo "→ 高速起動、SIGTERMでグレースフルシャットダウン、が必須"
echo ""

# 原則X: Dev/prod parity — 開発と本番の一致
echo "=== 原則X: Dev/prod parity ==="
echo "最小化すべき3つのギャップ:"
echo "  時間: 数週間 → 数分（git push）"
echo "  人:   開発者と運用者の分離 → 開発者がデプロイ"
echo "  ツール: macOS+SQLite/Linux+PostgreSQL → 統一"
```

### 演習4：PaaSの制約を体験する

```bash
# === PaaSの制約（光の裏にある影） ===

# 制約1: ファイルシステムは揮発性
echo "=== 制約1: 揮発性ファイルシステム ==="
DEPLOY_DIR=$(mktemp -d)
echo "upload.jpg" > "$DEPLOY_DIR/upload.jpg"
echo "デプロイv1: $(ls "$DEPLOY_DIR")"
rm -rf "$DEPLOY_DIR" && DEPLOY_DIR=$(mktemp -d)
echo "デプロイv2: $(ls "$DEPLOY_DIR" 2>/dev/null || echo '空 — 消えた')"
echo "→ ファイルはS3等の外部ストレージに保存すべき"
rm -rf "$DEPLOY_DIR"
echo ""

# 制約2: リソースと時間の制限
echo "=== 制約2: リソース制限 ==="
echo "Webリクエスト: 30秒タイムアウト / Dyno起動: 60秒以内"
echo "メモリ上限: 512MB(Standard-1X), 1GB(Standard-2X)"
echo "→ 長時間処理はWorker Dynoに委譲する設計が必須"
echo ""

# 制約3: 障害時の可視性喪失
echo "=== 制約3: 障害時の可視性 ==="
echo "IaaSでできること → PaaSではできないこと:"
echo "  SSH接続 → 不可  /  strace,tcpdump → 不可"
echo "  カーネルパラメータ変更 → 不可"
echo "  ログ: heroku logs --tail のみ"
echo "→ PaaS最大のトレードオフ: 障害がプラットフォーム内部にあると無力"
```

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/13-heroku-git-push-deploy/` に用意してある。

---

## 6. まとめと次回予告

### この回のまとめ

第13回では、Herokuが切り拓いたPaaS（Platform as a Service）の世界を、その技術設計、歴史的軌跡、そして光と影の両面から読み解いた。

**Herokuは「開発者体験」をクラウドに持ち込んだ先駆者だった。** 2007年の創業から、`git push heroku main` というデプロイ体験を確立し、開発者がインフラを意識せずにアプリケーションを公開できる世界を実現した。この「デプロイの民主化」は、それ自体がクラウドの民主化の一形態だった。

**Dyno、Buildpack、Procfileは、PaaSの基本概念を定義した。** Dyno（隔離されたコンテナ実行環境）、Buildpack（言語検出・依存解決・ビルドの自動化パイプライン）、Procfile（宣言的プロセス定義）——これらの概念は、Herokuを超えてCloud Native Buildpacks、Kubernetes、docker-composeに受け継がれている。

**The Twelve-Factor App（2011年）は、PaaSの設計原則をクラウドネイティブの普遍的原則に昇華した。** HerokuのAdam Wigginsが体系化した12の原則は、Heroku上のアプリケーション設計指針として始まったが、クラウドネイティブアプリケーション設計の基盤として広く受容された。「制約が良い設計を強制する」——Herokuの制約は、結果としてクラウドネイティブのベストプラクティスとなった。

**PaaSの抽象化は、解放と制約の両面を持つ。** IaaSがOS以下を抽象化するのに対し、PaaSはアプリケーション以下のすべてを抽象化する。開発者はコードに集中できるが、ランタイムの選択肢、スケーリングの粒度、障害時の可視性は制約される。特に障害時、プラットフォーム内部に踏み込めない無力感は、PaaS最大のトレードオフだ。

冒頭の問いに答えよう。「インフラを意識しない開発体験は、何を解放し、何を隠蔽したのか？」——PaaSは開発者をインフラ運用の負荷から解放し、アプリケーション開発に集中できる環境を提供した。だがその代償として、インフラの可視性と制御性を隠蔽した。隠蔽の中身を知らない者にとって、PaaSはブラックボックスであり、障害時に打つ手がない。隠蔽の中身を知る者にとって、PaaSは意図的に選択した抽象化であり、その制約の範囲内で合理的に運用できる。

### 次回予告

第14回では、「Google App Engine——Googleスケールの約束と制約」を取り上げる。

Herokuが「開発者体験」を軸にPaaSを普及させた一方で、Googleは別のアプローチでPaaSに取り組んだ。2008年4月に発表されたGoogle App Engine（GAE）は、「Googleのインフラの上でアプリケーションを動かせる」という魅力的な約束と引き換えに、厳格な制約を課した。ファイルシステムに書き込めない。リクエストに時間制限がある。使えるライブラリが限られる。RDBMSの代わりにDatastore（Bigtableベース）を使え——Googleスケールのスケーラビリティを手に入れる代わりに、Googleの設計思想に従うことが求められた。

「制約による設計」は、開発者の自由を奪うのか、それとも良い設計を強制するのか。次回は、GAEが体現した「もう一つのPaaS哲学」に踏み込む。

---

## 参考文献

- Heroku, "About Heroku: Our Platform, Philosophy, Team and History". <https://www.heroku.com/about/>
- Salesforce, "Salesforce.com Completes Acquisition of Heroku", January 2011. <https://www.salesforce.com/news/press-releases/2011/01/03/salesforce-com-completes-acquisition-of-heroku/>
- TechCrunch, "Salesforce.com Buys Heroku For $212 Million In Cash", December 2010. <https://techcrunch.com/2010/12/08/breaking-salesforce-buys-heroku-for-212-million-in-cash/>
- Adam Wiggins, "The Twelve-Factor App", 2011. <https://12factor.net/>
- Heroku Dev Center, "Buildpacks". <https://devcenter.heroku.com/articles/buildpacks>
- Heroku Dev Center, "The Procfile". <https://devcenter.heroku.com/articles/procfile>
- Heroku Dev Center, "Dynos (App Containers)". <https://devcenter.heroku.com/articles/dynos>
- Heroku Blog, "Celadon Cedar — A Major New Version of the Heroku Platform". <https://blog.heroku.com/celadon_cedar>
- Heroku Blog, "Heroku's Next Chapter", August 2022. <https://blog.heroku.com/next-chapter>
- Jeff Lindsay, "Dokku — The smallest PaaS implementation you've ever seen", June 2013. <https://progrium.github.io/blog/2013/06/19/dokku-the-smallest-paas-implementation-youve-ever-seen/>
- VMware Open Source Blog, "The Past, Present and Future of Cloud Foundry – Part 1", June 2020. <https://blogs.vmware.com/opensource/2020/06/25/the-past-present-and-future-of-cloud-foundry-part-1/>
- Cloud Foundry Foundation. <https://www.cloudfoundry.org/>
- InfoQ, "Ephemeralization or Heroku's Evolution to a Polyglot Cloud OS", August 2011. <https://www.infoq.com/news/2011/08/heroku_polyglot/>
- Lee Robinson, "The Story of Heroku". <https://leerob.com/heroku>
