# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第17回：コンテナオーケストレーション——KubernetesがIaaSを再定義する

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Docker（2013年）がコンテナ技術を民主化し、アプリケーションのパッケージングをどう変革したか
- Google社内のクラスタ管理システムBorg（2004年頃〜）とOmega（2013年論文発表）がKubernetesの設計にどう影響したか
- Kubernetes（2014年発表、2015年v1.0リリース）の宣言的設定とReconciliation Loopの設計思想
- Docker Swarm（2015年）、Apache Mesos/Marathon（2009年〜）との「オーケストレーション戦争」の顛末
- CNCF（Cloud Native Computing Foundation、2015年設立）がクラウドネイティブエコシステムを形成した経緯
- GKE（2015年）、AKS（2017年プレビュー）、EKS（2018年GA）——マネージドKubernetesの普及
- Kubernetesの複雑性の本質——「あなたの組織にKubernetesは本当に必要か」という問い

---

## 1. YAMLの海に溺れた日

2015年の秋、私はDocker Composeで快適に動いていた開発環境を、本番に持っていくという課題に直面していた。

Docker Composeは開発環境では申し分なかった。`docker-compose up` の一言で、Webアプリケーション、データベース、キャッシュサーバが立ち上がる。第13回で取り上げたHerokuの `git push heroku main` に匹敵する、快適な開発者体験だった。だが問題は、「本番でも同じように動かしたい」という、一見すると当然の要求にあった。

Docker Composeは単一ホスト上でコンテナを管理するツールだ。本番環境では、複数のホストにまたがってコンテナを配置し、障害が起きたら自動で復旧し、トラフィックに応じてスケールさせなければならない。Docker Composeにはその能力がなかった。

「Kubernetesを使えばいいのでは」

同僚のインフラエンジニアがそう言った。当時、Kubernetesは2015年7月にバージョン1.0がリリースされたばかりだった。私は公式ドキュメントを読み始め、最初のYAMLファイルを書いた。

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: myapp:latest
        ports:
        - containerPort: 8080
```

「これだけか」と思った。たった20行のYAMLでアプリケーションの3レプリカがデプロイできる。だが、この「これだけか」という印象は数日で崩壊した。Serviceが必要だ。Ingressが必要だ。ConfigMapとSecretでアプリケーションの設定を管理する必要がある。PersistentVolumeClaimでストレージを確保する必要がある。NetworkPolicyでPod間の通信を制御する必要がある。RBAC（Role-Based Access Control）でアクセス権限を設定する必要がある。

一つのアプリケーションをKubernetesで本番運用するために、私は最終的に15を超えるYAMLファイルを書いた。合計するとおそらく500行を超えていた。Docker Composeでは30行で済んでいたものが、である。

「これは本当にインフラを簡単にしているのか」

私は真剣に自問した。YAMLの海に溺れている感覚だった。インデントを一つ間違えれば動かない。リソース名のタイポに気づくまで30分を費やす。`kubectl apply -f` を叩くたびに、何が起きているのか正確には把握できていない不安がつきまとう。

だが、理解が進むにつれて、風景が変わった。

ある日、本番環境でPodが死んだ。手動では何もしていない。だが数秒後、新しいPodが自動で起動し、トラフィックが復旧した。Kubernetesが「3つのレプリカが存在すべき」という宣言を読み取り、実際の状態が2つに減ったことを検知し、あるべき状態に自律的に修復したのだ。

「これだ」と思った。YAMLは冗長だ。学習曲線は急峻だ。だが、Kubernetesが提供しているものは単なるコンテナの管理ツールではない。「インフラのあるべき姿を宣言し、システムがその状態を自律的に維持する」——宣言的インフラという、根本的に新しいパラダイムだった。

あなたはKubernetesを使っているだろうか。使っているなら、それが「なぜ」そう設計されたか、考えたことはあるだろうか。使っていないなら、「なぜ使わない」という判断の根拠を言語化できるだろうか。

---

## 2. Dockerがもたらした「箱」の標準化

### 5分間のライトニングトークが世界を変えた

Kubernetesを理解するには、まずDockerが何を変えたかを理解する必要がある。

2013年3月15日、PyCon US 2013のメインステージで、Solomon Hykesは5分間のライトニングトーク「The Future of Linux Containers」を行った。Hykesはフランスで設立されたPaaS企業dotCloudの共同創業者で、dotCloudの内部ツールとして開発していたコンテナ技術を初めて公開デモした。

Hykes自身は30人程度の小部屋でのデモを想定していたという。だがPyConのライトニングトークはメインステージで行われ、数百人の聴衆が見守る中でのデモとなった。反響は予想を遥かに超えた。誰かがまだ未完成だったDockerのサイトをHacker Newsに投稿し、「vaporware」と呼んだ。HykesとチームはDockerを2週間でオープンソースとして公開することを決断した。

Dockerは2013年3月にオープンソースとしてリリースされた。当初はLXC（Linux Containers）をデフォルトの実行環境として使用していた。dotCloud Inc.は2013年にDocker Inc.に社名を変更する。PaaS企業として始まった会社が、自社の内部ツールに社名を変えたのだ。それほど、Dockerのインパクトは大きかった。

### Dockerが解決した問題

Docker以前、Linuxコンテナ技術は既に存在していた。LXC（2008年）、cgroups（2007年にLinuxカーネルに統合）、namespaces——これらのカーネル機能を組み合わせれば、プロセスの隔離環境を作ることはできた。第5回で取り上げたVPS（Virtual Private Server）も、この系統の技術の応用だった。

では、Dockerは何が新しかったのか。

Dockerが解決したのは、「アプリケーションのパッケージングと配布」の問題だった。それまで、アプリケーションを別の環境にデプロイするには、OSの設定、ライブラリのバージョン、環境変数、ファイルパス——これらすべてを揃える必要があった。「開発環境では動くのに本番で動かない」という問題は、あらゆる開発チームが日常的に直面する悪夢だった。

```
Docker以前のデプロイ:

  開発者のPC          本番サーバ
  ┌──────────┐        ┌──────────┐
  │ App      │        │ App      │
  │ Python 3.9│  ───→  │ Python 3.8│  ← バージョン不一致!
  │ libssl 1.1│        │ libssl 1.0│  ← ライブラリ不一致!
  │ Ubuntu 22 │        │ CentOS 7  │  ← OS不一致!
  └──────────┘        └──────────┘
  "動いた!"            "動かない..."

Docker以後のデプロイ:

  開発者のPC          本番サーバ
  ┌──────────┐        ┌──────────┐
  │┌────────┐│        │┌────────┐│
  ││ App    ││        ││ App    ││
  ││ Python ││  ───→  ││ Python ││  ← 同一イメージ
  ││ libssl ││        ││ libssl ││  ← 同一イメージ
  ││ Ubuntu ││        ││ Ubuntu ││  ← 同一イメージ
  │└────────┘│        │└────────┘│
  │  Docker  │        │  Docker  │
  └──────────┘        └──────────┘
  "動いた!"            "動いた!"
```

Dockerイメージは、アプリケーションとその依存関係をすべて一つの「箱」に詰め込む。この箱は、Dockerが動く環境であればどこでも同じように動作する。「私のマシンでは動く（It works on my machine）」問題を、根本的に解決したのだ。

さらにDocker Hubという公開レジストリにより、イメージの配布が標準化された。`docker pull nginx` と打てば、世界中の誰もが同じNginxイメージを取得できる。これは、ソフトウェアの配布における革命だった。

### コンテナの爆発的普及——そして管理の問題

Dockerは爆発的に普及した。だが、普及するほどに新たな問題が浮上した。

本番環境では、コンテナは一つでは済まない。Webアプリケーション、APIサーバ、バックグラウンドワーカー、データベース、キャッシュ——マイクロサービスアーキテクチャの台頭もあり、一つのシステムが数十、数百のコンテナで構成されることが珍しくなくなった。

これらのコンテナを、複数のホストマシンにどう配置するか。あるホストが障害で落ちたとき、そこで動いていたコンテナをどう別のホストに移すか。トラフィックが増えたとき、コンテナの数をどう増やすか。コンテナ同士はどうやって通信するか。

「コンテナのオーケストレーション（編成・管理）」——この問題を解くことが、2014年から2017年にかけてのクラウドネイティブ領域の最大のテーマとなった。

---

## 3. Borg、Omega、そしてKubernetes——Googleの系譜

### Borg——Googleの「見えないOS」

Kubernetesの設計を理解するには、その先祖であるGoogle社内のシステムを知る必要がある。

Googleは2000年代初頭から、社内で大規模なクラスタ管理システムを運用していた。それがBorgである。2015年にEuroSysで発表された論文「Large-scale cluster management at Google with Borg」（Abhishek Verma, Luis Pedrosa, Madhukar R. Korupolu, David Oppenheimer, Eric Tune, John Wilkes著）によれば、Borgは数万台のマシンからなるクラスタで、数千の異なるアプリケーションから数十万のジョブを管理していた。

Borgの設計思想を一言で表すなら、「計算機クラスタを一台の巨大なコンピュータのように扱う」ことである。Borgのユーザーは、個々のマシンを意識する必要がなかった。「このジョブを実行するにはCPU 2コアとメモリ4GBが必要」と宣言すれば、Borgが適切なマシンを選んでジョブを配置する。マシンが障害で落ちれば、自動的にジョブを別のマシンに再配置する。

```
Google Borgのアーキテクチャ概念図:

  ┌─────────────────────────────────────────┐
  │              BorgMaster                  │
  │  ┌──────────┐  ┌──────────┐             │
  │  │Scheduler │  │ Paxos    │（高可用性） │
  │  │          │  │ レプリカ │             │
  │  └──────────┘  └──────────┘             │
  └───────────────┬─────────────────────────┘
                  │ ジョブの配置指示
    ┌─────────────┼─────────────┐
    ▼             ▼             ▼
  ┌──────┐     ┌──────┐     ┌──────┐
  │Borglet│     │Borglet│     │Borglet│ ← 各マシンのエージェント
  │ ┌──┐ │     │ ┌──┐ │     │ ┌──┐ │
  │ │J1│ │     │ │J3│ │     │ │J5│ │
  │ │J2│ │     │ │J4│ │     │ │J6│ │
  │ └──┘ │     │ └──┘ │     │ └──┘ │
  └──────┘     └──────┘     └──────┘
  Machine 1     Machine 2     Machine 3
```

Borgの重要な設計判断をいくつか挙げる。

**第一に、宣言的なジョブ仕様。** ユーザーは「どのマシンで動かすか」ではなく「何を動かすか」を宣言する。リソース要件、レプリカ数、制約条件を記述すれば、配置の最適化はBorgに委ねられる。

**第二に、高い利用率の追求。** Borgはadmission control（受け入れ制御）、効率的なタスクパッキング、オーバーコミットメント、マシン共有を組み合わせて、クラスタ全体の利用率を高めていた。計算資源を無駄にしないことへの執念は、Googleの規模だからこそ切実だった。

**第三に、障害を前提とした設計。** 数万台のマシンを運用していれば、毎日どこかで障害が起きる。Borgは障害を例外ではなく常態として扱い、自動的な復旧を設計の中核に据えていた。

### Omega——スケジューラの革新

2013年、GoogleはBorgの次世代スケジューラとしてOmegaの論文をEuroSysで発表した。「Omega: flexible, scalable schedulers for large compute clusters」（Malte Schwarzkopf, Andy Konwinski, Michael Abd-El-Malek, John Wilkes著）は、Best Student Paper Awardを受賞した。

Borgのスケジューラはモノリシック（一枚岩）だった。すべてのスケジューリング判断が一つの中央スケジューラを通る。規模が大きくなると、この中央集権型の設計がボトルネックになる。

Omegaは、共有状態（Shared State）とロックフリーの楽観的並行制御（Optimistic Concurrency Control）を用いた並列スケジューラアーキテクチャを提案した。複数の独立したスケジューラがクラスタ状態のローカルコピーを持ち、並行して配置決定を行う。衝突が発生した場合は最初のリクエストが優先され、衝突したスケジューラはリトライする。

この設計により、新しいスケジューリングポリシーを既存のものと並行して導入できるようになった。「柔軟性とスケーラビリティの両立」——これがOmegaのテーマだった。

### BorgからKubernetesへ——何を持ち込み、何を捨てたか

2016年、ACM Queueに発表された論文「Borg, Omega, and Kubernetes」（Brendan Burns, Brian Grant, David Oppenheimer, Eric Brewer, John Wilkes著）で、Googleの3世代にわたるコンテナ管理システムから得た教訓が体系化された。

この論文は、Kubernetesの設計がBorgとOmegaのどの教訓を取り入れ、どの部分を意図的に変えたかを明示している。

**Borgから持ち込んだもの：**

- 宣言的なジョブ/タスク仕様
- Podの概念（Borgでは「task」と呼ばれていた、密結合のコンテナグループ）
- Labelによる柔軟なグルーピング（Borgではジョブ名に固定されていた設計の反省から、より柔軟なラベルセレクタを導入）
- IPアドレスのPodへの付与（Borgではポート番号の共有が問題だった）

**Borgから意図的に変えたもの：**

- Borgの「ジョブ」は固定的なグルーピングだったが、KubernetesではLabelとSelectorによる動的で柔軟なグルーピングを導入した
- Borgは単一のクラスタ内で閉じていたが、Kubernetesはフェデレーション（複数クラスタの連携）を視野に入れた設計にした
- BorgのAPIはGoogle社内に最適化されていたが、KubernetesのAPIは汎用的で拡張可能な設計にした

**Omegaから持ち込んだもの：**

- APIサーバを中心とした共有状態モデル（etcdに格納される）
- 複数の独立したコントローラが協調動作するアーキテクチャ

Kubernetesの創設者であるJoe Beda、Brendan Burns、Craig McLuckieの3人は、Google社内でBorgに触れ、その威力と限界を身をもって知っていた。彼らは2013年秋からプロジェクトの構想を始め、2014年6月6日に最初のコミットを行い、同年6月10日のDockerCon 2014でGoogle社員Eric Brewerが基調講演でKubernetesを発表した。

注目すべきは、創設者たちが最初から「Google」のプレフィックスをつけないことを意識していた点だ。Kubernetesはギリシャ語で「操舵手」を意味する。プロジェクトの内部コードネームは「Project Seven of Nine」——Star Trek: Voyagerに登場する元Borgドローンのキャラクター名だった。Borgから生まれたが、Borgとは異なる存在であることを示す、ユーモアを込めた命名だった。

---

## 4. 宣言的設定とReconciliation Loop——Kubernetesの設計思想

### 手続き的 vs 宣言的——パラダイムの転換

Kubernetesの技術的な設計思想を理解するうえで、最も重要な概念が「宣言的設定（Declarative Configuration）」と「Reconciliation Loop（調整ループ）」だ。

従来のインフラ管理は、手続き的（Imperative）だった。「サーバAにSSHで接続せよ」「Nginxをインストールせよ」「設定ファイルを書き換えよ」「サービスを再起動せよ」——操作の手順を一つずつ指示する。シェルスクリプトもAnsibleのtask listも、本質的にはこのパラダイムだ。

Kubernetesは宣言的（Declarative）パラダイムを採用した。「Nginxが3つのレプリカで動作していること」「ポート80でトラフィックを受けること」「CPUは500ミリコア、メモリは256MBを上限とすること」——望ましい状態（Desired State）を宣言する。「どうやってその状態にたどり着くか」は、システムが自律的に判断する。

```
手続き的（Imperative）:

  管理者 → "サーバAにNginxをインストールしろ"
         → "設定ファイルを/etc/nginx/に配置しろ"
         → "systemctl start nginxを実行しろ"
         → "3台目のサーバを追加しろ"
         → "ロードバランサに登録しろ"

  管理者は「手順」を記述する
  途中で失敗すると、どこまで進んだか把握が困難
  べき等性（idempotency）の保証は管理者の責任


宣言的（Declarative）:

  管理者 → "Nginxが3レプリカで動作している状態"
           (YAMLマニフェストとして記述)

                    ↓

  Kubernetes → 現在の状態を観測
             → 望ましい状態と比較
             → 差分があれば修正
             → 差分がなければ何もしない
             → この検査を永続的に繰り返す

  管理者は「あるべき状態」を記述する
  途中で失敗しても、再試行が自動的に行われる
  べき等性はシステムが保証する
```

この宣言的パラダイムの技術的な実装が、Reconciliation Loopである。

### Reconciliation Loop——Kubernetesの心臓

Kubernetesのコントローラは、終了しないループ（Non-terminating Loop）として動作する。その動作は極めてシンプルな3ステップで表現できる。

1. **Observe（観測）**: APIサーバを監視し、リソースの現在の状態を取得する
2. **Diff（差分検出）**: 望ましい状態（`.spec`に記述されたもの）と現在の状態（`.status`に反映されたもの）を比較する
3. **Act（修正）**: 差分があれば、現在の状態を望ましい状態に近づけるアクションを実行する

このループが永続的に回り続けるのがReconciliation Loopである。

```
Reconciliation Loop:

  ┌──────────────┐
  │  APIサーバ   │←── 望ましい状態（.spec）
  │   (etcd)     │    が格納されている
  └──────┬───────┘
         │ Watch（監視）
         ▼
  ┌──────────────┐    ┌──────────────┐
  │  コントローラ │───→│  ワーク      │
  │              │    │  キュー      │
  │  Observe     │    └──────┬───────┘
  │  Diff        │           │
  │  Act         │←──────────┘
  │              │    Reconcile関数を呼び出し
  └──────┬───────┘
         │ 修正アクション
         ▼
  ┌──────────────┐
  │  実際のリソース│  Pod, Service,
  │  (クラスタ)   │  Volume, etc.
  └──────────────┘

  ※失敗時は指数バックオフで再キュー
  ※このループは永遠に回り続ける
```

具体的な例で説明しよう。DeploymentコントローラはDeploymentリソースを監視している。ユーザーが `replicas: 3` と宣言すると、コントローラは現在のPod数を確認し、足りなければPodを作成し、多ければ削除する。ノードが障害で落ちてPodが消えれば、コントローラはその消失を検知し、別のノードにPodを再作成する。

この設計の優れた点は、「何が起きても、望ましい状態への収束が試みられる」ことだ。ネットワーク障害、ノード障害、APIサーバの一時的な停止——あらゆる外乱に対して、Reconciliation Loopは自律的に修復を試みる。コントローラは「この問題をどう修復するか」を個別にプログラムされているのではなく、「望ましい状態と現在の状態の差分を解消する」という汎用的なロジックで動作する。

### コントローラパターン——Kubernetesの拡張性の源泉

Kubernetesの標準コントローラだけでも、その数は多い。

- **Deployment Controller**: Podの望ましいレプリカ数を維持する
- **ReplicaSet Controller**: Podのレプリカセットを管理する（DeploymentControllerから呼ばれる）
- **Service Controller**: クラウドプロバイダのロードバランサを管理する
- **Node Controller**: ノードの状態を監視し、障害ノードを検知する
- **Job Controller**: バッチジョブの完了を管理する

これらはすべて、同じReconciliation Loopパターンで実装されている。そしてKubernetesの真の威力は、このパターンをユーザーが拡張できる点にある。Custom Resource Definition（CRD）とカスタムコントローラ——いわゆる「Operator Pattern」——により、Kubernetesの宣言的設計をあらゆるドメインに適用できる。

たとえば、PostgreSQLのOperatorを導入すれば、以下のようなYAMLでデータベースクラスタを宣言的に管理できる。

```yaml
apiVersion: acid.zalan.do/v1
kind: postgresql
metadata:
  name: my-postgres-cluster
spec:
  teamId: "myteam"
  numberOfInstances: 3
  postgresql:
    version: "16"
  volume:
    size: 10Gi
```

「PostgreSQLクラスタが3ノードで動作し、各ノードに10GBのストレージがある状態」を宣言すれば、Operatorがその状態を実現し、維持し続ける。レプリケーションの設定、フェイルオーバーの処理、バックアップのスケジュール——これらすべてがReconciliation Loopの中で自律的に管理される。

2016年のACM Queue論文で、著者たちはこの設計思想を「Record of Intent（意図の記録）」と表現した。YAMLマニフェストは単なる設定ファイルではない。「こうあるべきだ」というインフラへの意図の宣言である。

### Pod——最小のデプロイ単位

Kubernetesの設計でもう一つ重要な概念がPodだ。

コンテナランタイム（Dockerなど）の最小単位は「コンテナ」だが、Kubernetesの最小デプロイ単位は「Pod」である。Podは一つ以上のコンテナを含み、同じネットワーク名前空間とストレージボリュームを共有する。

なぜコンテナではなくPodなのか。これはBorgからの教訓だ。Borgの論文では、密結合のプロセス群（たとえば、アプリケーションとそのログ収集エージェント）を一つのユニットとして管理する「alloc」という概念が記述されている。KubernetesのPodはこのallocの直系の子孫である。

```
Pod の構造:

  ┌──────────────────────────────────┐
  │  Pod                             │
  │  ┌──────────┐  ┌──────────┐     │
  │  │ App      │  │ Log      │     │
  │  │ Container│  │ Sidecar  │     │
  │  │ :8080    │  │ (Fluentd)│     │
  │  └──────────┘  └──────────┘     │
  │       │              │          │
  │  ┌────┴──────────────┴────┐     │
  │  │  共有ネットワーク       │     │
  │  │  (localhost で通信可能) │     │
  │  └────────────────────────┘     │
  │  ┌────────────────────────┐     │
  │  │  共有ボリューム         │     │
  │  │  (ファイルシステム共有) │     │
  │  └────────────────────────┘     │
  └──────────────────────────────────┘
```

Pod内のコンテナは `localhost` で互いに通信できる。共有ボリュームを通じてファイルのやり取りもできる。これにより、「メインのアプリケーションコンテナ」と「補助的なサイドカーコンテナ」（ログ収集、プロキシ、設定の動的更新など）を一つのユニットとして管理できる。

このサイドカーパターンは、マイクロサービスアーキテクチャにおけるService Mesh（第19回で詳述）の基盤技術でもある。IstioやLinkerdのようなService Meshは、各PodにEnvoyプロキシをサイドカーとして注入することで、サービス間通信の制御を実現している。

### Serviceによるサービスディスカバリ

Podは一時的な存在だ。障害が起きれば消え、再作成されれば新しいIPアドレスを持つ。クライアントがPodのIPアドレスを直接参照していたら、Podが再作成されるたびに接続が切れる。

この問題を解決するのがServiceリソースだ。Serviceは安定したIPアドレス（ClusterIP）とDNS名を提供し、背後にある複数のPodにトラフィックを振り分ける。PodのIPアドレスが変わっても、ServiceのIPアドレスは変わらない。

```
Service によるサービスディスカバリ:

  クライアント
       │
       │ web-service.default.svc.cluster.local
       ▼
  ┌─────────────┐
  │  Service     │  ClusterIP: 10.96.0.100
  │  (web-svc)   │  安定したIPとDNS名
  └──────┬──────┘
         │ Label Selector: app=web
    ┌────┼────┐
    ▼    ▼    ▼
  ┌───┐┌───┐┌───┐
  │Pod││Pod││Pod│  IPは動的に変わる
  │ A ││ B ││ C │  (10.244.x.x)
  └───┘└───┘└───┘
```

ServiceはLabel Selectorを使って対象のPodを特定する。`app: web` というラベルを持つすべてのPodが、自動的にServiceのエンドポイントに登録される。Podが増えれば自動的に追加され、減れば自動的に除外される。

これは、従来の「ロードバランサに手動でサーバを登録する」作業を完全に自動化したものだ。そしてこの自動化もまた、Reconciliation Loopの一部として実現されている。

---

## 5. オーケストレーション戦争——Kubernetes以外の選択肢

### Docker Swarm——シンプルさの追求

Kubernetesだけがコンテナオーケストレーションの回答ではなかった。2014年から2017年にかけて、複数のソリューションが覇権を争った。

Docker Inc.自身が提供したのがDocker Swarmだ。2015年にSwarm「Classic」がGAとなり、2016年のDocker 1.12ではSwarm Modeとしてエンジンに組み込まれた。GA時点で1,000ノード、30,000以上のコンテナのスケールをサポートしていた。

Swarmの設計思想は「Dockerユーザーにとっての自然な延長」だった。Docker CLIに慣れた開発者が、ほぼ同じコマンド体系でクラスタ管理を行える。`docker service create` でサービスをデプロイし、`docker service scale` でスケーリングする。学習曲線はKubernetesに比べて圧倒的に緩やかだった。

だが、その「シンプルさ」は諸刃の剣だった。Kubernetesが提供するような細かな制御——Pod Affinity/Anti-Affinity、Custom Resource Definition、RBAC、Network Policy——Swarmにはこれらの多くが欠けていた。小規模なデプロイには十分だが、大規模で複雑なワークロードには力不足だった。

### Apache Mesos/Marathon——大規模への解答

もう一つの有力な選択肢がApache Mesos/Marathonだった。

Apache Mesosは2009年にUC BerkeleyのRAD Lab（Reliable Adaptive Distributed Systems Laboratory）で生まれた。Benjamin Hindman、Andy Konwinski、Matei Zaharia（後のApache Spark創設者）、教授Ion Stoicaによる研究プロジェクトで、当初はNexusという名前だったが、名前の衝突によりMesosに改名された。

Mesosの設計思想はKubernetesとは根本的に異なる。Kubernetesが「コンテナオーケストレーション」に特化しているのに対し、Mesosは「データセンター全体のリソースを抽象化するOS」を目指した。Mesosの上にはMarathon（コンテナオーケストレーション）、Chronos（ジョブスケジューリング）、Spark（分散データ処理）など、複数のフレームワークを載せることができた。

TwitterやAirbnbがMesosを大規模に採用していたことで、「大規模環境ではMesos」という認識が2015年頃には広まっていた。だが、Mesosのアプローチは2層スケジューリング（Mesosがリソースを提供し、フレームワークがそれを受け取る）であり、フレームワーク間の協調が難しいという構造的な課題を抱えていた。

### Kubernetesの勝利——なぜKubernetesが標準になったか

2017年頃、「オーケストレーション戦争」は事実上の決着がついた。2017年10月のDockerCon EUで、Docker Inc.自身がKubernetesをDocker Enterprise Editionに統合すると発表したのだ。これは、Docker SwarmがKubernetesとの競争に敗れたことを事実上認めた瞬間だった。

Mesosphere（後にD2iQに改名）も、MesosベースのプラットフォームからKubernetesベースへとピボットした。

Kubernetesが勝利した要因は複数ある。

**第一に、Googleの後ろ盾とCNCFの中立性。** 2015年7月、Kubernetes 1.0のリリースと同時に、Linux Foundation傘下にCloud Native Computing Foundation（CNCF）が設立された。創設メンバーにはGoogle、Docker、Red Hat、IBM、VMwareなどが名を連ねた。KubernetesはGoogleが生み出したが、CNCFという中立的な組織に寄贈されたことで、「特定のベンダーのプロダクト」ではなく「業界標準のオープンソースプロジェクト」という位置づけを獲得した。

**第二に、拡張性の設計。** CRDとカスタムコントローラにより、Kubernetesの機能を誰でも拡張できる。この拡張性が、巨大なエコシステムの形成を促した。ストレージ、ネットワーク、モニタリング、セキュリティ——あらゆるドメインのベンダーがKubernetes上のソリューションを提供し始めた。

**第三に、マネージドKubernetesの普及。** GKE（Google Kubernetes Engine、2015年）が先陣を切り、AKS（Azure Kubernetes Service、2017年10月プレビュー、2018年6月GA）、EKS（Amazon Elastic Kubernetes Service、2018年6月GA）が続いた。主要3クラウドベンダーすべてがマネージドKubernetesを提供したことで、「Kubernetesを使うこと」のハードルが劇的に下がった。コントロールプレーンの運用という、最も困難な部分をクラウドベンダーに委ねることができるようになったのだ。

**第四に、APIの設計品質。** KubernetesのAPIはリソース指向で、一貫した操作（GET、LIST、WATCH、CREATE、UPDATE、DELETE）を全リソースタイプに対して提供する。この統一性が、ツールやオートメーションとの統合を容易にした。

```
オーケストレーション戦争のタイムライン:

 2013   Docker公開（3月、PyCon）
  │
 2014   Kubernetes発表（6月、DockerCon）
  │     Marathon Docker対応
  │
 2015   Kubernetes 1.0（7月、OSCON）
  │     CNCF設立（7月発表、12月正式）
  │     Docker Swarm Classic GA
  │     GKE ローンチ
  │
 2016   Docker 1.12 Swarm Mode組み込み
  │
 2017   Docker社がK8s統合を発表（10月）
  │     AKS プレビュー（10月）
  │     ← この頃に「K8sの勝利」が確定的に
  │
 2018   EKS GA（6月）
  │     AKS GA（6月）
```

---

## 6. ハンズオン——Kubernetesの宣言的インフラを体験する

ここまでの技術論を体で理解するために、kindまたはminikubeを使ってローカルにKubernetesクラスタを構築し、宣言的設定の威力を体感しよう。

### 演習1：ローカルKubernetesクラスタの構築とDeployment

```bash
# === kindによるローカルKubernetesクラスタの構築 ===

# kind（Kubernetes IN Docker）をインストール
# kindはDockerコンテナの中にKubernetesノードを作る
# Docker環境が必須

# kindのインストール（Linux/amd64）
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# kubectlのインストール
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

# クラスタの作成（コントロールプレーン1 + ワーカー2）
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

echo ""
echo "=== クラスタの状態を確認 ==="
kubectl cluster-info
kubectl get nodes

echo ""
echo "=== Deploymentの作成 ==="
# Nginxを3レプリカでデプロイする
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-demo
  labels:
    app: web-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-demo
  template:
    metadata:
      labels:
        app: web-demo
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 128Mi
EOF

# Podが起動するのを待つ
kubectl rollout status deployment/web-demo --timeout=120s

echo ""
echo "=== Podの状態を確認 ==="
kubectl get pods -o wide
echo ""
echo "注目: 3つのPodがワーカーノードに分散配置されている"
echo "KubernetesのSchedulerが自動的に最適な配置を決定した"
```

### 演習2：Reconciliation Loopの動作を観察する

```bash
# === Reconciliation Loopの観察 ===

echo "=== 現在のPod一覧 ==="
kubectl get pods

echo ""
echo "=== Podを1つ手動で削除する ==="
# 最初のPodを取得して削除
POD_NAME=$(kubectl get pods -l app=web-demo -o jsonpath='{.items[0].metadata.name}')
echo "削除するPod: $POD_NAME"
kubectl delete pod "$POD_NAME"

echo ""
echo "=== 5秒待って再確認 ==="
sleep 5
kubectl get pods

echo ""
echo "考察:"
echo "- 削除したPodのStatusは 'Terminating' になる"
echo "- 即座に新しいPodが作成される（名前が異なる）"
echo "- Deployment Controllerが 'replicas: 3' の"
echo "  Desired Stateを検知し、Actual Stateとの差分を"
echo "  修正した（Reconciliation Loop）"
echo ""
echo "これが宣言的インフラの本質:"
echo "  管理者は「あるべき状態」を宣言するだけ"
echo "  Kubernetesが自律的にその状態を維持する"
```

### 演習3：スケーリングとローリングアップデート

```bash
# === スケーリングの体験 ===

echo "=== 現在のレプリカ数: 3 ==="
kubectl get deployment web-demo

echo ""
echo "=== レプリカ数を5に増やす ==="
kubectl scale deployment web-demo --replicas=5
sleep 5
kubectl get pods -l app=web-demo

echo ""
echo "=== レプリカ数を2に減らす ==="
kubectl scale deployment web-demo --replicas=2
sleep 5
kubectl get pods -l app=web-demo

echo ""
echo "=== ローリングアップデート ==="
echo "Nginx 1.27 → 1.27-alpine にイメージを更新"
kubectl set image deployment/web-demo nginx=nginx:1.27-alpine
kubectl rollout status deployment/web-demo --timeout=120s

echo ""
echo "=== 更新後のPodを確認 ==="
kubectl get pods -l app=web-demo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

echo ""
echo "考察:"
echo "- ローリングアップデートでは古いPodを1つずつ"
echo "  新しいPodに置き換える（ゼロダウンタイム）"
echo "- rollout history でデプロイ履歴を確認できる:"
kubectl rollout history deployment/web-demo

echo ""
echo "=== ロールバック ==="
echo "問題があった場合、前のバージョンに戻せる"
kubectl rollout undo deployment/web-demo
kubectl rollout status deployment/web-demo --timeout=120s
kubectl get pods -l app=web-demo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
```

### 演習4：ServiceとDNSによるサービスディスカバリ

```bash
# === Serviceの作成とサービスディスカバリ ===

echo "=== Serviceを作成 ==="
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web-demo-svc
spec:
  selector:
    app: web-demo
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

echo ""
echo "=== Serviceの状態を確認 ==="
kubectl get service web-demo-svc
kubectl describe service web-demo-svc

echo ""
echo "=== Service経由でアクセス ==="
# 一時的なPodからService名でアクセスする
kubectl run test-client --rm -i --restart=Never \
  --image=curlimages/curl:latest -- \
  curl -s http://web-demo-svc.default.svc.cluster.local

echo ""
echo "考察:"
echo "- 'web-demo-svc.default.svc.cluster.local' という"
echo "  DNS名でServiceにアクセスできる"
echo "- 背後のPodのIPアドレスが変わっても、DNS名は安定"
echo "- EndpointsにPodのIPが自動登録される:"
kubectl get endpoints web-demo-svc

echo ""
echo "=== クリーンアップ ==="
kubectl delete deployment web-demo
kubectl delete service web-demo-svc
kind delete cluster
```

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/17-kubernetes-orchestration/` に用意してある。

---

## 7. まとめと次回予告

### この回のまとめ

第17回では、コンテナオーケストレーションの歴史と、Kubernetesが確立した宣言的インフラ管理の設計思想を読み解いた。

**Docker（2013年）は「アプリケーションのパッケージングと配布」の問題を解決した。** Solomon Hykesが PyCon 2013で披露した5分間のデモは、コンテナ技術を一部の専門家から全世界の開発者へと民主化した。だがDockerが普及するほどに、「大量のコンテナをどう管理するか」というオーケストレーションの問題が浮上した。

**Kubernetesは、Googleが10年以上運用してきたBorg/Omegaの教訓から生まれた。** 2014年6月に発表され、2015年7月にv1.0がリリースされた。創設者のJoe Beda、Brendan Burns、Craig McLuckieは、Borgの威力を外の世界に持ち出すことを目指した。だし同時に、Borgの制約——固定的なジョブ管理、内部向けに最適化されたAPI——を意図的に改善した。

**Kubernetesの設計の核心は、宣言的設定とReconciliation Loopにある。** ユーザーは「あるべき状態」をYAMLマニフェストとして宣言し、コントローラが自律的にその状態を維持し続ける。手続き的な「手順の記述」から、宣言的な「意図の記録」へ——このパラダイム転換が、Kubernetesが単なるコンテナ管理ツールではなく「IaaSの上のOS」と呼ばれる所以である。

**2014年から2017年にかけての「オーケストレーション戦争」は、Kubernetesの勝利に終わった。** Docker Swarmのシンプルさも、Mesos/Marathonの大規模対応能力も、Kubernetesの拡張性、CNCFの中立的ガバナンス、マネージドKubernetes（GKE、AKS、EKS）の普及には及ばなかった。2017年10月にDocker Inc.自身がKubernetes統合を発表したことが、この戦争の象徴的な終結だった。

**だが、Kubernetesは万能薬ではない。** YAMLの冗長さ、学習曲線の急峻さ、運用の複雑性——これらは現実の問題だ。「あなたの組織にKubernetesは本当に必要か」という問いは、今も有効である。小規模なチームが小規模なアプリケーションを運用するなら、Docker ComposeやPaaS（Cloud Run、Fly.io）の方が適切かもしれない。Kubernetesを選ぶのであれば、それは「宣言的インフラ管理の恩恵が、複雑性のコストを上回る」と判断したときであるべきだ。

冒頭の問いに答えよう。Kubernetesは何を解決し、何を複雑にしたのか。Kubernetesは、コンテナのライフサイクル管理、スケーリング、サービスディスカバリ、ローリングアップデートを宣言的に管理する方法を確立した。その代償として、概念の多さ（Pod、Service、Deployment、Ingress、ConfigMap、Secret、PersistentVolumeClaim...）、YAMLの冗長さ、運用の複雑性という新たなコストを生み出した。この功罪を理解した上で選択する——それが、クラウドネイティブ時代のインフラエンジニアに求められる判断力である。

### 次回予告

第18回では、「サーバーレス（Lambda）——サーバが『見えない』世界」を取り上げる。

Kubernetesはコンテナの管理を自動化したが、クラスタ自体の運用は残る。ノードのスケーリング、セキュリティパッチの適用、Kubernetesバージョンのアップグレード——「インフラを意識したくない」という開発者の願望は、まだ完全には叶えられていない。

2014年11月、AWSはre:InventでLambdaを発表した。「サーバを管理しない」——この約束は、何を意味し、何を隠蔽しているのか。コールドスタート問題と格闘しながら、サーバーレスの本質を問い直す。

---

## 参考文献

- Wikipedia, "Docker (software)". <https://en.wikipedia.org/wiki/Docker_(software)>
- PyVideo.org, "Lightning Talk - The future of Linux Containers", PyCon US 2013. <https://pyvideo.org/pycon-us-2013/the-future-of-linux-containers.html>
- Docker Blog, "Docker: Nine Years YOUNG", March 2022. <https://www.docker.com/blog/docker-nine-years-young/>
- Docker Blog, "11 Years of Docker: Shaping the Next Decade of Development", 2024. <https://www.docker.com/blog/docker-11-year-anniversary/>
- Abhishek Verma et al., "Large-scale cluster management at Google with Borg", EuroSys 2015. <https://research.google/pubs/large-scale-cluster-management-at-google-with-borg/>
- Malte Schwarzkopf et al., "Omega: flexible, scalable schedulers for large compute clusters", EuroSys 2013. <https://research.google/pubs/omega-flexible-scalable-schedulers-for-large-compute-clusters/>
- Brendan Burns et al., "Borg, Omega, and Kubernetes", ACM Queue, Volume 14, 2016. <https://queue.acm.org/detail.cfm?id=2898444>
- Kubernetes Blog, "10 Years of Kubernetes", June 2024. <https://kubernetes.io/blog/2024/06/06/10-years-of-kubernetes/>
- Google Cloud Blog, "How Kubernetes came to be: A co-founder shares the story". <https://cloud.google.com/blog/products/containers-kubernetes/from-google-to-the-world-the-kubernetes-origin-story>
- Google Cloud Platform Blog, "Kubernetes V1 Released", July 2015. <https://cloudplatform.googleblog.com/2015/07/Kubernetes-V1-Released.html>
- Kubernetes Official Documentation, "Controllers". <https://kubernetes.io/docs/concepts/architecture/controller/>
- Wikipedia, "Cloud Native Computing Foundation". <https://en.wikipedia.org/wiki/Cloud_Native_Computing_Foundation>
- Wikipedia, "Apache Mesos". <https://en.wikipedia.org/wiki/Apache_Mesos>
- Docker Docs, "Swarm mode". <https://docs.docker.com/engine/swarm/>
- GeekWire, "Kubernetes at 5: Joe Beda, Brendan Burns, and Craig McLuckie on its past, future", 2019. <https://www.geekwire.com/2019/kubernetes-5-joe-beda-brendan-burns-craig-mcluckie-past-future-true-value-open-source/>
- The New Stack, "Beda, Burns and McLuckie: the Creators of Kubernetes Look Back". <https://thenewstack.io/beda-burns-and-mcluckie-the-creators-of-kubernetes-look-back/>
- InfoQ, "Microsoft Releases Preview of Azure Container Service (AKS)", October 2017. <https://www.infoq.com/news/2017/10/azure-kubernetes-aks/>
- InfoQ, "AKS Is Now Generally Available", June 2018. <https://www.infoq.com/news/2018/06/kubernetes-microsoft-aks/>
