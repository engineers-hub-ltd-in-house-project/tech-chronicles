# UNIXという思想

## ――パイプ、プロセス、ファイル――すべてはここから始まった

### 第20回：「DockerとKubernetes――UNIX原則の現代的帰結」

**連載「UNIXという思想――パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- chroot（1979年）からFreeBSD Jails（2000年）、Solaris Zones（2005年）に至るプロセス分離技術の系譜
- Linux namespaces（2002年〜）とcgroups（2006年〜）がコンテナの技術的基盤を形成した経緯
- Docker（2013年）が「コンテナの民主化」を実現した技術的・社会的メカニズム
- Kubernetes（2014年）のpodとsidecarパターンに見るUNIX哲学の現代的表現
- 「一つのコンテナには一つのプロセス」というベストプラクティスとUNIXの「一つのことをうまくやれ」の構造的接続
- namespaces/cgroupsを使ってDockerなしでコンテナを手動構築する方法

---

## 1. 「これはchrootの進化形だ」

2014年の秋、私はあるWebサービスのインフラ移行プロジェクトに関わっていた。物理サーバ上で動いていたアプリケーション群を、Dockerコンテナに載せ替えるという仕事だ。

`docker run`を初めて叩いたとき、私は不思議な既視感を覚えた。コマンドを実行すると、プロセスが起動する。そのプロセスは隔離された環境で動いている。ホスト側のファイルシステムは見えない。ネットワークも別の空間にある。だがホストOSのカーネルは共有している。

「これはchrootの進化形だ」——私の頭にそう浮かんだ。

1999年、Slackwareを触り始めた頃、私はchrootを知った。`chroot /path/to/newroot /bin/sh`で、プロセスのルートディレクトリを変更する。chrootされたプロセスは、指定されたディレクトリをルートとして認識し、その外のファイルシステムにはアクセスできない。単純だが、強力な隔離だった。当時はサーバのビルド環境やテスト環境の分離に使っていた。

Dockerコンテナの中で`ps aux`を打ったとき、プロセスが隔離されている様を見て、あの頃のchrootの感覚が蘇った。だがDockerはchrootとは比較にならない精度で隔離を実現していた。ファイルシステムだけでなく、PID空間、ネットワーク、ホスト名、ユーザID——あらゆるカーネルリソースが分離されている。

後にKubernetesを触り始めたとき、別の発見があった。Kubernetesのpodは複数のコンテナをまとめ、それぞれのコンテナが一つの責務を担う。メインのアプリケーションコンテナの横に、ログ収集用のsidecarコンテナが走る。それぞれが自分の仕事だけをこなし、ネットワークとストレージを共有しながら協調する。

私は既視感を覚えた。これはUNIXのパイプラインではないか。`cat`がファイルを読み、`grep`がパターンを探し、`wc`が行を数える。それぞれが単機能で、それぞれが独立したプロセスとして動き、標準入出力を介してデータを受け渡す。Kubernetesのpodは、パイプラインの各コマンドが個別のプロセスであるように、各コンテナが個別の責務を持つ。

コンテナ技術は、本当にUNIX哲学の延長線上にあるのか。それとも、見た目の類似に惑わされているだけなのか。この回では、chrootからDockerとKubernetesに至るまでの50年の系譜を辿り、その問いに向き合う。

---

## 2. プロセス分離の系譜――chrootからコンテナへ

### 1979年：chrootの誕生

プロセス分離の歴史は、UNIXそのものの歴史と並走している。

1979年、Version 7 Unixの開発過程でchrootシステムコールが導入された。当初の目的は、V7ディストリビューションのビルドとテストを隔離された環境で行うことだった。chrootは指定したディレクトリをプロセスのルートディレクトリとして設定し、そのプロセスからは指定ディレクトリの外にあるファイルシステムが見えなくなる。

Bill Joyは1982年3月18日、4.2BSDリリースの17か月前に、BSD向けにchrootを導入した。インストールシステムとビルドシステムのテストに活用するためだった。chrootの設計は単純そのものだ。ファイルシステムの「見える範囲」を制限するだけで、プロセスのネットワークアクセスやプロセス間通信は制限しない。セキュリティ機構としては不完全であり、root権限を持つプロセスはchrootから脱出できる。だがこの「ファイルシステムの視界を狭める」という発想は、後のコンテナ技術のすべての出発点となった。

```
chrootの動作原理:

通常のプロセス:
/                          ← プロセスが見えるルート
├── bin/
├── etc/
├── home/
├── var/
└── usr/

chrootされたプロセス:
/srv/chroot/               ← このディレクトリが新しいルートになる
├── bin/    → プロセスからは / に見える
├── etc/    → プロセスからは /etc に見える
├── lib/
└── usr/

chrootの外（/home, /var 等）はプロセスから見えない。
ただしネットワーク、プロセステーブル、IPCは隔離されない。
```

### 2000年：FreeBSD Jails――chrootを超えた隔離

chrootの限界は明白だった。ファイルシステムしか隔離できない。同一ホスト上の他のプロセスはpsで見えるし、ネットワークも共有されている。この限界を超えたのが、FreeBSD Jailsだ。

2000年3月14日リリースのFreeBSD 4.0で、Poul-Henning Kampが開発したJailsが搭載された。R&D Associates社（Webホスティングプロバイダ）からの委託プロジェクトとして1999年に開発が始まったJailsは、chrootのファイルシステム隔離に加えて、プロセス空間の隔離、ネットワークの隔離（Jailごとに固有のIPアドレスを割り当て）、そしてroot権限の制限を実現した。

Jailsの設計思想は明確だった。一つのFreeBSDホスト上で、互いに干渉できない複数の仮想的なFreeBSD環境を動かす。Webホスティングのように、複数の顧客のサービスを一台のサーバで安全に共存させるための技術だ。chrootが「ファイルシステムの壁」だったとすれば、Jailsは「プロセス、ネットワーク、権限を含む包括的な壁」だった。

### 2005年：Solaris Zones――エンタープライズコンテナの先駆

第11回で取り上げた商用UNIXの技術的遺産の一つが、Solaris Zonesである。2004年2月にSolaris 10のベータ版で公開され、2005年1月31日のSolaris 10正式リリースで一般提供された。

Solaris Zonesは、FreeBSD Jailsの概念をさらに発展させ、エンタープライズグレードの機能を備えていた。各Zoneには独自のファイルシステム、ネットワーク、プロセス空間が割り当てられ、ホスト側の「グローバルゾーン」とは完全に分離される。さらにSolaris Resource Manager（後のResource Controls）との統合により、CPU、メモリ、ネットワーク帯域のリソース制限が可能だった。

```
プロセス分離技術の進化:

1979  chroot (V7 Unix)
      │  ファイルシステムの隔離のみ
      │
2000  FreeBSD Jails (FreeBSD 4.0)
      │  ファイルシステム + プロセス + ネットワーク + 権限
      │
2005  Solaris Zones (Solaris 10)
      │  Jails相当 + リソース制限 + エンタープライズ管理
      │
2002-2008  Linux namespaces + cgroups
      │  カーネルレベルの汎用的な隔離とリソース制限の基盤
      │
2008  LXC (Linux Containers)
      │  namespaces + cgroupsの統合フロントエンド
      │
2013  Docker
      │  イメージ形式 + レジストリ + 開発者体験の革新
      │
2014  Kubernetes
      │  コンテナオーケストレーション + podモデル
      ↓
```

ここで注目すべきは、chrootからSolaris Zonesまでの系譜が、いずれもUNIX系OSの中で生まれたことだ。プロセスを隔離するという発想は、UNIXの「プロセス」という抽象化が最初から持っていた可能性の一つだった。UNIXがプロセスをアドレス空間の境界で分離するOSとして設計された瞬間から、「その分離をもっと強固にできないか」という問いは必然的に生まれた。chrootからDockerまでの50年は、その問いに対する段階的な回答の歴史である。

### Linuxカーネルの基盤技術：namespacesとcgroups

Dockerの話をする前に、その基盤技術であるLinux namespacesとcgroupsを理解しなければならない。この二つの技術がなければ、Dockerは存在しない。

**namespaces**は、カーネルリソースの「可視範囲」を限定する機構だ。2002年8月3日、Linux 2.4.19でAl Viroにより最初のnamespace——mount namespace——が導入された。CLONE_NEWNSフラグをclone(2)システムコールに渡すことで、プロセスごとに異なるマウントポイントの集合を持たせることが可能になった。

この設計はPlan 9 from Bell Labsに触発されている。第18回で取り上げたPlan 9のper-process名前空間——プロセスごとに異なるファイルシステムの「景色」を持てる設計——が、Linux namespacesの直接的な先祖だ。CLONE_NEWNSの「NS」が単に"new namespace"の略で、mount namespaceという具体的な名前を持たなかったのは、当時の開発者が将来さらに多種のnamespaceが必要になるとは考えていなかった証拠だ。

だが歴史はそうはならなかった。以降15年以上にわたり、namespaceの種類は段階的に追加された。

```
Linux namespacesの導入時系列:

namespace        カーネル    年     隔離対象
───────────────────────────────────────────────────────
Mount (mnt)      2.4.19    2002   マウントポイント
UTS              2.6.19    2006   ホスト名、ドメイン名
IPC              2.6.19    2006   System V IPC、POSIXメッセージキュー
PID              2.6.24    2008   プロセスID空間
Network (net)    2.6.29    2009   ネットワークデバイス、IPアドレス、ルーティング
User             3.8       2013   UID/GIDマッピング
Cgroup           4.6       2016   cgroupルートディレクトリ
Time             5.6       2020   システムクロック
```

**cgroups**（control groups）は、プロセスグループへのリソース制限を提供する。2006年、GoogleのエンジニアPaul MenageとRohit Sethが「process containers」として開発を開始した。2007年後半、Linuxカーネル内で「container」という用語が別の意味で使われていたため混乱を避けるべく「control groups」に改名され、2008年1月リリースのLinux 2.6.24でメインラインにマージされた。

cgroupsが制御するリソースは多岐にわたる。CPU使用率、メモリ使用量、ブロックI/O帯域、ネットワーク帯域——プロセスグループが消費できるリソースの上限を設定できる。namespacesが「何が見えるか」を制御するのに対し、cgroupsは「どれだけ使えるか」を制御する。この二つの組み合わせが、Linuxにおけるコンテナ技術の基盤となった。

```
namespacesとcgroupsの役割分担:

┌──────────────────────────────────────────────────┐
│                 コンテナ                          │
│                                                  │
│  namespaces: 「何が見えるか」を制御              │
│  ┌─────────┬─────────┬─────────┬────────┐       │
│  │ Mount   │  PID    │ Network │  UTS   │       │
│  │ 独自の  │ 独自の  │ 独自の  │ 独自の │       │
│  │ ファイル│ プロセス│ IPアドレ│ ホスト │       │
│  │ システム│ ツリー  │ ス/経路 │ 名     │       │
│  └─────────┴─────────┴─────────┴────────┘       │
│                                                  │
│  cgroups: 「どれだけ使えるか」を制御             │
│  ┌─────────┬─────────┬─────────┬────────┐       │
│  │ CPU     │ Memory  │ Block   │ Network│       │
│  │ 最大    │ 上限    │ I/O     │ 帯域   │       │
│  │ 50%     │ 512MB   │ 制限    │ 制限   │       │
│  └─────────┴─────────┴─────────┴────────┘       │
│                                                  │
│  ホストOSのLinuxカーネルを共有                    │
└──────────────────────────────────────────────────┘
```

2008年、これらの基盤技術を統合するフロントエンドとしてLXC（Linux Containers）がリリースされた。IBMのエンジニアによる開発で、namespacesとcgroupsを組み合わせてLinuxカーネルの機能だけでコンテナ環境を提供する最初の本格的な実装だった。LXCは技術的には完成度が高かったが、一般の開発者にとっては敷居が高かった。コンテナの作成にはカーネル機能の理解が必要で、イメージの配布や共有の仕組みもなかった。

ここまでの技術——chroot、Jails、Zones、namespaces、cgroups、LXC——はすべて、インフラストラクチャの専門家のためのツールだった。一般の開発者がコンテナを意識することは、まだなかった。

---

## 3. Docker――コンテナの民主化とUNIX哲学

### Solomon Hykesの5分間

2013年3月15日、PyCon 2013のライトニングトークセッション。Solomon Hykesという名前のエンジニアが、"The Future of Linux Containers"と題した5分間のプレゼンテーションを行った。

Hykesは、PaaS企業dotCloudの共同創業者だった。dotCloudは内部でLinuxコンテナ技術を活用しており、その内部ツールをオープンソースとして公開することを決断した。それがDockerである。

Hykesは小さなサイドルームを想像していたが、PyCon 2013のライトニングトークはメインステージで行われた。数百人の聴衆の前で、Dockerの最初のデモが実行された。反応は想像を超えるものだった。デモの動画はバイラルに拡散し、dotCloudのチームは「これが本物の可能性だ」と気づいた。結果として、dotCloudはPaaS事業から撤退し、Docker社に転身する。

Dockerの技術的な基盤は、LXCと同じくnamespacesとcgroupsだった。初期のDockerはLXCをデフォルトの実行環境として使用していた。だがDockerが革命的だったのは、技術そのものではなく、その上に構築された三つの仕組みだ。

**第一に、Dockerイメージ。** Dockerはコンテナの実行環境をレイヤー化されたイメージとしてパッケージングした。Dockerfileという宣言的な定義ファイルから、再現可能なイメージをビルドできる。イメージのレイヤー構造はUnion File Systemに基づく。当初はAUFS（Advanced Union File System）を使用していたが、AUFSはLinuxカーネルのメインラインにマージされなかったため、現在はLinux 3.18（2014年）でカーネルにマージされたOverlayFS（overlay2ドライバ）がデフォルトとなっている。各レイヤーはCopy-on-Write（CoW）で管理され、変更があったファイルだけが新しいレイヤーにコピーされる。

**第二に、Docker Hub（レジストリ）。** イメージを共有するための中央リポジトリだ。`docker pull nginx`と打てば、nginxの公式イメージがダウンロードされ、即座に実行できる。パッケージマネージャのリポジトリに相当する概念をコンテナに持ち込んだことで、「誰でも同じ環境を数秒で手に入れられる」世界が実現した。

**第三に、開発者体験。** `docker build`、`docker run`、`docker push`——わずか数個のコマンドで、ビルド、実行、配布が完結する。LXCでは設定ファイルを手書きし、カーネル機能の細部を理解する必要があった。Dockerはその複雑さを抽象化し、アプリケーション開発者の言葉で語れるインタフェースを提供した。

### 「コンテナ = プロセス」という理解

Dockerの技術的本質を一言でいえば、「コンテナとは、namespacesとcgroupsで隔離・制限されたLinuxプロセスである」ということだ。仮想マシン（VM）のように独自のカーネルを持つわけではない。ホストOSのLinuxカーネルを共有しながら、namespacesでリソースの「可視範囲」を限定し、cgroupsでリソースの「使用量」を制限する。

```
仮想マシン vs コンテナ:

仮想マシン:                     コンテナ:
┌─────────────┐                ┌──────────────┐
│  App A      │                │  App A       │
│  Bins/Libs  │                │  Bins/Libs   │
│  Guest OS   │ ← 独自カーネル │              │ ← カーネル共有
├─────────────┤                ├──────────────┤
│  App B      │                │  App B       │
│  Bins/Libs  │                │  Bins/Libs   │
│  Guest OS   │ ← 独自カーネル │              │ ← カーネル共有
├─────────────┤                ├──────────────┤
│ Hypervisor  │                │ Container    │
│ (VMM)       │                │ Runtime      │
├─────────────┤                ├──────────────┤
│ Host OS     │                │ Host Linux   │
│ + Kernel    │                │ Kernel       │
├─────────────┤                ├──────────────┤
│ Hardware    │                │ Hardware     │
└─────────────┘                └──────────────┘

VMはハードウェアを仮想化する。
コンテナはカーネルの隔離機能を使う。
コンテナの正体は「隔離されたプロセス」だ。
```

この「コンテナ = プロセス」という理解は、UNIX哲学との接続点を明確にする。UNIXにおいて、プロセスは独立した実行単位であり、自身のアドレス空間を持ち、他のプロセスとはシステムコールを介して通信する。コンテナは、このプロセスの独立性をnamespacesとcgroupsで強化したものだ。

### 「一つのコンテナには一つのプロセス」

Dockerの公式ドキュメントには、長らく「一つのコンテナには一つのプロセス（正確には、一つのコンテナには一つの関心事・サービス）」というベストプラクティスが記載されてきた。Webサーバとデータベースを同一コンテナに入れるのではなく、それぞれを別のコンテナにする。ログ収集もメトリクス取得も、別のコンテナだ。

このベストプラクティスは、UNIX哲学の第一原則「一つのことをうまくやれ（Do one thing and do it well）」と構造的に同じだ。

第4回で取り上げたDoug McIlroyの言葉を思い出してほしい。「プログラムは一つのことをうまくやるように書け。」UNIXのコマンド群——`grep`、`sort`、`uniq`、`wc`——はそれぞれ単一の責務を持ち、パイプラインで組み合わせることで複雑な処理を実現する。

コンテナの世界でも同じ原則が適用される。各コンテナが一つのサービスを担い、ネットワークを介して協調する。コンテナが一つの責務に限定されていれば、スケーリングが容易になる（特定のサービスだけをスケールアウトできる）。障害の影響範囲が局所化される（一つのコンテナが落ちても他には影響しない）。デプロイも独立して行える。

ただし、この「一つのコンテナには一つのプロセス」は教条ではない。Dockerの公式ドキュメント自身が「一つのコンテナは一つの関心事（concern）に集中すべき」と述べており、「一つのプロセス」とは限定していない。Apache HTTPサーバのようにワーカープロセスをforkするサービスは、一つのコンテナの中で複数のプロセスを持つ。重要なのはプロセス数ではなく、責務の範囲だ。この点もまた、UNIXコマンドの設計原則と同じだ。`awk`は内部で複雑な処理を行うが、その責務は「テキスト処理」という一つの領域に限定されている。

### 2015年：OCI――コンテナの「POSIX」

2015年6月22日、DockerとCoreOSを中心にOpen Container Initiative（OCI）が設立された。コンテナのランタイム仕様（Runtime Specification）とイメージフォーマット仕様（Image Specification）を標準化する取り組みだ。Dockerは自社のコンテナランタイムruncをOCIに寄贈し、仕様のリファレンス実装とした。

この動きは、第10回で取り上げたPOSIX標準化と構造的に同じだ。UNIXが分裂の危機にあったとき、POSIXが「最小公約数」としての標準を定めたように、OCIはコンテナ技術が乱立する前に標準を定めた。Docker以外のランタイム——Podman、containerd、CRI-O——がOCI仕様に準拠することで、コンテナイメージの互換性が保証される。標準化は退屈だが、生態系を支える基盤だ。

---

## 4. Kubernetes――パイプラインとしてのコンテナオーケストレーション

### Google Borgの公開版

2014年6月6日、GoogleはKubernetesをオープンソースプロジェクトとして発表した。

Kubernetesの起源は、Google社内で10年以上にわたり運用されてきたコンテナオーケストレーションシステムBorgにある。GoogleのインフラストラクチャはLinux上で数十億のコンテナを動かしていた。Borgはそのコンテナ群のスケジューリング、ヘルスチェック、リソース管理を担う巨大なシステムだった。KubernetesはBorgの設計知見を「公開版」として再構築したものだ。中心開発者はJoe Beda、Brendan Burns、Craig McLuckieだった。

2015年7月21日、Kubernetes v1.0がリリースされた。同時にGoogleはKubernetesをCloud Native Computing Foundation（CNCF）に寄贈した。CNCFはLinux Foundation傘下の組織として、コンテナとクラウドネイティブ技術のオープンソースエコシステムを統括する役割を担う。

### podとsidecar――UNIX的な設計パターン

Kubernetesの最小デプロイ単位はpodである。podは一つ以上のコンテナのグループであり、同一のネットワーク名前空間とストレージを共有する。通常は一つのpodに一つのメインコンテナを配置するが、複数のコンテナを配置することもできる。この複数コンテナの配置パターンとして代表的なのが、sidecarパターンだ。

sidecarパターンでは、メインアプリケーションコンテナの横に、補助機能を担うsidecarコンテナを配置する。たとえば、メインコンテナがWebアプリケーションを実行し、sidecarコンテナがログ収集を担当する。あるいは、sidecarコンテナがTLSの終端処理を行い、メインコンテナはHTTPだけを処理する。各コンテナは自分の責務にのみ集中し、pod内のネットワーク共有を介して協調する。

```
Kubernetesのpodとsidecarパターン:

Pod
┌──────────────────────────────────────────────┐
│                                              │
│  ┌──────────────┐    ┌──────────────────┐   │
│  │   Main       │    │   Sidecar        │   │
│  │   Container  │    │   Container      │   │
│  │              │    │                  │   │
│  │  Webアプリ   │    │  ログ収集        │   │
│  │  (nginx)     │    │  (fluentd)       │   │
│  │              │    │                  │   │
│  └──────┬───────┘    └────────┬─────────┘   │
│         │                     │              │
│    ┌────┴─────────────────────┴────┐         │
│    │     共有ネットワーク          │         │
│    │     (localhost通信可能)       │         │
│    ├──────────────────────────────┤         │
│    │     共有ボリューム            │         │
│    │     (ログファイル等)          │         │
│    └──────────────────────────────┘         │
│                                              │
└──────────────────────────────────────────────┘

UNIXパイプラインとの対比:

  cat access.log | grep "ERROR" | wc -l

  各コマンド = 独立したプロセス
  パイプ     = 標準入出力による通信
  全体       = 一つの処理パイプライン

  pod内の各コンテナ = 独立したプロセス
  共有ネットワーク  = localhost/ボリュームによる通信
  pod全体           = 一つの論理的な単位
```

この構造は、UNIXのパイプラインと完全に同じだとは言えない。UNIXパイプラインでは各コマンドが標準入出力という統一インタフェースでデータを受け渡す。Kubernetesのpodではコンテナ間の通信にlocalhostネットワークや共有ボリュームを使い、プロトコルはHTTP、gRPC、ファイルI/Oなど多様だ。テキストストリームという「万能インタフェース」の統一性は失われている。

だが設計思想のレベルでは、深い共鳴がある。「個々の要素は一つの責務に集中し、明確なインタフェースを介して組み合わせる」——この原則は、UNIXコマンドのパイプラインでもKubernetesのpodでも変わらない。

### Kubernetesとプロセス管理の類比

Kubernetesの機能全体を俯瞰すると、UNIXのプロセス管理との類比がさらに見えてくる。

```
UNIX/Linuxのプロセス管理とKubernetesの対応:

UNIX/Linux              Kubernetes
──────────────────────────────────────────
プロセス         →      コンテナ
プロセスグループ →      Pod
init/systemd     →      kubelet
fork/exec        →      コンテナ起動
kill/signal      →      Pod終了/再起動
nice/renice      →      リソースリクエスト/リミット
cron             →      CronJob
デーモン         →      Deployment (replicas)
```

UNIXにおいてinitプロセス（PID 1）がすべてのプロセスの親であり、孤児プロセスの回収とシグナルの伝播を担うように、Kubernetesのkubeletは各ノード上でコンテナのライフサイクルを管理する。systemdがサービスの起動、ヘルスチェック、自動再起動を担うように、KubernetesのDeploymentコントローラーはコンテナの望ましい状態（レプリカ数、リソース制限、ヘルスチェック）を宣言的に管理し、実態が宣言と乖離すれば自動的に修正する。

この類比は偶然ではない。コンテナの本質が「隔離されたプロセス」である以上、コンテナの管理はプロセスの管理の延長線上にある。UNIXが50年以上かけて洗練してきたプロセス管理の概念——起動、監視、シグナル、リソース制限、依存関係管理——が、スケールを変えてKubernetesで再現されているのだ。

---

## 5. ハンズオン：Dockerなしでコンテナを手動構築する

このハンズオンでは、Dockerを使わずにLinuxカーネルのnamespaces/cgroupsを直接操作して「コンテナ」を手動構築する。コンテナの本質が「隔離されたプロセス」であることを、自分の手で確認する。

### 環境構築

```bash
# Docker上のUbuntu 24.04で実行する。
# ホスト側でコンテナを起動する際、特権モード(--privileged)が必要。
# namespacesの操作にはCAP_SYS_ADMIN権限が必要なためだ。
docker run -it --privileged ubuntu:24.04 bash
```

### 演習1：namespacesによるプロセス隔離を体験する

```bash
echo "=== 演習1: namespacesでプロセスを隔離する ==="
echo ""
echo "unshare コマンドで新しいnamespaceを作成し、"
echo "プロセスを隔離された環境に配置する。"
echo ""

# 現在のホスト名を確認
echo "--- 現在の環境 ---"
echo "ホスト名: $(hostname)"
echo "PID: $$"
echo ""

# UTS namespace + PID namespace + Mount namespace を分離して
# 新しいシェルを起動する
echo "--- unshareで新しいnamespaceを作成 ---"
echo "実行コマンド:"
echo '  unshare --uts --pid --mount --fork /bin/bash'
echo ""
echo "unshare のオプション:"
echo "  --uts    : UTS namespace（ホスト名）を分離"
echo "  --pid    : PID namespace（プロセスID空間）を分離"
echo "  --mount  : Mount namespace（マウントポイント）を分離"
echo "  --fork   : 新しいPID namespaceでforkしてから実行"
echo ""

# 実際に実行（非対話的にデモ）
unshare --uts --pid --mount --fork /bin/bash -c '
  # 新しいnamespace内
  echo "=== 隔離された環境 ==="

  # ホスト名を変更（UTS namespaceが分離されているので
  # ホスト側には影響しない）
  hostname container-demo
  echo "ホスト名: $(hostname)"

  # procfsをマウントして、PID namespaceを正しく反映させる
  mount -t proc proc /proc

  # PID namespace内のプロセス一覧
  echo ""
  echo "--- PID namespace内のプロセス ---"
  ps aux
  echo ""
  echo "注目: PID 1が/bin/bashになっている。"
  echo "通常のLinuxではPID 1はinit/systemdだ。"
  echo "PID namespaceを分離したことで、"
  echo "このシェルが「この世界のinit」になった。"
  echo ""
  echo "これがコンテナの本質だ。"
  echo "Dockerは裏でこれと同じことをしている。"
'

echo ""
echo "--- ホスト側に戻った ---"
echo "ホスト名: $(hostname)"
echo "(UTS namespaceが分離されていたので、"
echo " ホスト側のホスト名は変わっていない)"
```

### 演習2：cgroupsによるリソース制限を体験する

```bash
echo "=== 演習2: cgroupsでリソースを制限する ==="
echo ""
echo "cgroupsを使ってプロセスのメモリ使用量を制限する。"
echo "Dockerの --memory オプションの裏で動いている仕組みだ。"
echo ""

# cgroup v2がマウントされているか確認
echo "--- cgroup v2の確認 ---"
if mount | grep -q "cgroup2"; then
    echo "cgroup v2が有効"
    CGROUP_BASE="/sys/fs/cgroup"
else
    echo "cgroup v1を使用"
    CGROUP_BASE="/sys/fs/cgroup/memory"
    mkdir -p "$CGROUP_BASE" 2>/dev/null
    mount -t cgroup -o memory cgroup "$CGROUP_BASE" 2>/dev/null
fi
echo ""

# テスト用のcgroupを作成
CGROUP_PATH="$CGROUP_BASE/demo-container"
echo "--- cgroupの作成 ---"
echo "パス: $CGROUP_PATH"

if [ -d "$CGROUP_BASE/demo-container" ]; then
    rmdir "$CGROUP_BASE/demo-container" 2>/dev/null
fi

mkdir -p "$CGROUP_PATH"

# cgroup v2の場合
if mount | grep -q "cgroup2"; then
    # サブツリー制御を有効化
    echo "+memory" > "$CGROUP_BASE/cgroup.subtree_control" 2>/dev/null

    # メモリ制限を50MBに設定
    echo "52428800" > "$CGROUP_PATH/memory.max" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "メモリ制限: $(cat "$CGROUP_PATH/memory.max") bytes (50MB)"
    else
        echo "メモリ制限の設定に失敗（権限不足の可能性）"
    fi
    echo ""

    echo "--- cgroupの中身 ---"
    ls "$CGROUP_PATH/" 2>/dev/null | head -10
    echo ""

    echo "=== cgroupの仕組み ==="
    echo ""
    echo "Dockerの --memory=50m オプションは、内部で以下を実行する:"
    echo "  1. 新しいcgroupディレクトリを作成"
    echo "  2. memory.max に制限値を書き込む"
    echo "  3. コンテナのPIDを cgroup.procs に書き込む"
    echo ""
    echo "つまり、Dockerのリソース制限は"
    echo "cgroupsのファイル操作に過ぎない。"
    echo "\"Everything is a file\" の原則が"
    echo "ここでも生きている。"

    # クリーンアップ
    rmdir "$CGROUP_PATH" 2>/dev/null
else
    echo "（cgroup v1環境ではメモリサブシステムの操作が異なる）"
fi
```

### 演習3：ファイルシステム隔離を手動で構築する

```bash
echo "=== 演習3: ファイルシステムの隔離を手動構築する ==="
echo ""
echo "chrootとmount namespaceを組み合わせて、"
echo "独自のルートファイルシステムを持つ隔離環境を作る。"
echo ""

# 必要なパッケージをインストール
apt-get update -qq && apt-get install -y -qq debootstrap > /dev/null 2>&1

ROOTFS="/tmp/mini-container"
echo "--- 最小限のルートファイルシステムを作成 ---"
echo "パス: $ROOTFS"
echo ""

# debootstrapで最小限のDebianルートFSを作成
# （ネットワーク環境がある場合）
if command -v debootstrap > /dev/null 2>&1; then
    echo "debootstrapで最小ルートFSを構築中..."
    echo "(これには数分かかる場合がある)"
    debootstrap --variant=minbase noble "$ROOTFS" \
        http://archive.ubuntu.com/ubuntu/ 2>/dev/null

    if [ $? -eq 0 ]; then
        echo ""
        echo "--- ルートFSの構造 ---"
        ls "$ROOTFS"
        echo ""

        echo "--- 隔離環境に入る ---"
        echo "chrootで$ROOTFSをルートに設定し、"
        echo "さらにnamespacesで追加の隔離を行う。"
        echo ""

        unshare --uts --pid --mount --fork \
            /usr/sbin/chroot "$ROOTFS" /bin/bash -c '
            mount -t proc proc /proc
            hostname isolated-env
            echo "=== 隔離された環境 ==="
            echo "ホスト名: $(hostname)"
            echo "ルートFS: $(ls /)"
            echo "PID一覧:"
            ps aux 2>/dev/null || echo "(psがない場合はprocfsから確認)"
            ls /proc/ 2>/dev/null | grep "^[0-9]" | head -5
            echo ""
            echo "この環境は:"
            echo "  - 独自のルートファイルシステムを持つ (chroot)"
            echo "  - 独自のPID空間を持つ (PID namespace)"
            echo "  - 独自のホスト名を持つ (UTS namespace)"
            echo "  - 独自のマウントポイントを持つ (mount namespace)"
            echo ""
            echo "これが「コンテナ」の本質だ。"
            echo "Dockerはこれに、イメージ管理と"
            echo "開発者向けインタフェースを加えたものにすぎない。"
            umount /proc 2>/dev/null
        '
    else
        echo "debootstrapに失敗。ネットワーク接続を確認。"
        echo ""
        echo "代替: 手動でミニマルなルートFSを構築する"
        mkdir -p "$ROOTFS"/{bin,lib,lib64,proc,sys,dev,etc,tmp}

        # 必要なバイナリとライブラリをコピー
        cp /bin/bash "$ROOTFS/bin/"
        cp /bin/ls "$ROOTFS/bin/"
        cp /bin/ps "$ROOTFS/bin/" 2>/dev/null
        cp /bin/hostname "$ROOTFS/bin/" 2>/dev/null

        # 動的ライブラリをコピー
        for bin in bash ls; do
            ldd "/bin/$bin" 2>/dev/null | grep -o '/[^ ]*' | while read lib; do
                dir=$(dirname "$ROOTFS$lib")
                mkdir -p "$dir"
                cp "$lib" "$ROOTFS$lib" 2>/dev/null
            done
        done

        # ld-linux-x86-64をコピー
        cp /lib64/ld-linux-x86-64.so.2 "$ROOTFS/lib64/" 2>/dev/null

        echo "手動ルートFSの構造:"
        ls "$ROOTFS"

        unshare --uts --pid --mount --fork \
            /usr/sbin/chroot "$ROOTFS" /bin/bash -c '
            echo "=== 手動構築した隔離環境 ==="
            echo "ルートFS: $(ls /)"
            echo ""
            echo "最小限のバイナリだけを含む"
            echo "隔離されたファイルシステム。"
            echo "chrootの原理は1979年から変わらない。"
        ' 2>/dev/null || echo "(手動ルートFSの実行に失敗した場合は環境依存の問題)"
    fi
else
    echo "debootstrapが利用できない環境"
    echo "apt-get install debootstrap を実行してから再試行"
fi

# クリーンアップ
rm -rf "$ROOTFS" 2>/dev/null
```

### 演習4：コンテナの「層」を可視化する

```bash
echo "=== 演習4: Dockerコンテナの内部を覗く ==="
echo ""
echo "Dockerコンテナの中でプロセスがどのように"
echo "隔離されているかを確認する。"
echo "この演習はDocker環境（ホスト側）で実行する。"
echo ""

echo "--- /proc/self/ns: 自プロセスのnamespace情報 ---"
ls -la /proc/self/ns/
echo ""
echo "各ファイルがnamespaceのIDを示す。"
echo "同じnamespace IDを持つプロセスは"
echo "同じ「世界」にいる。"
echo ""

echo "--- /proc/self/cgroup: 自プロセスのcgroup情報 ---"
cat /proc/self/cgroup
echo ""
echo "このプロセスがどのcgroupに所属しているかがわかる。"
echo "Dockerコンテナ内で実行すると、"
echo "Docker固有のcgroupパスが表示される。"
echo ""

echo "=== まとめ ==="
echo ""
echo "コンテナの本質:"
echo "  1. namespaces: リソースの「可視範囲」を制限"
echo "  2. cgroups: リソースの「使用量」を制限"
echo "  3. chroot/pivot_root: ルートFSを差し替え"
echo ""
echo "これらはすべてLinuxカーネルの機能であり、"
echo "Dockerはその上に「使いやすさ」を加えたツールだ。"
echo "UNIXの「すべてはファイルである」原則の通り、"
echo "namespacesもcgroupsも /proc や /sys 配下の"
echo "ファイル操作で制御される。"
echo ""
echo "1979年のchrootから2013年のDockerまで、"
echo "プロセス分離の技術はUNIXの設計哲学の上に"
echo "段階的に積み重ねられてきた。"
```

---

## 6. まとめと次回予告

### この回の要点

コンテナ技術の歴史は、UNIXのプロセス分離技術の系譜そのものだ。1979年のchroot（Version 7 Unix）に始まり、2000年のFreeBSD Jails、2005年のSolaris Zones、2002年から段階的に導入されたLinux namespaces、2006年に開発が始まったcgroups、2008年のLXC——これらすべてがUNIX系OSのカーネル機能として生まれ、プロセスの隔離をより精緻なものにしてきた。

2013年にSolomon HykesがDockerを公開したとき、技術的な基盤は既に整っていた。Dockerの革新は、namespacesとcgroupsという基盤技術の上に「イメージ」「レジストリ」「開発者体験」という三つの層を加え、コンテナを一般の開発者が使える技術に変えたことにある。コンテナの本質は「隔離されたプロセス」であり、仮想マシンとは根本的に異なる。

2014年に発表されたKubernetesは、Google社内のBorgの設計知見を公開版として再構築したコンテナオーケストレーションシステムだ。Kubernetesのpodとsidecarパターンは、UNIX哲学の「一つのことをうまくやれ」と「小さなツールの組み合わせ」の現代的表現として読める。各コンテナが一つの責務に集中し、pod内で協調する構造は、パイプラインの各コマンドが単機能で連携する構造と共鳴する。

「一つのコンテナには一つのプロセス（一つの関心事）」というDockerのベストプラクティスは、UNIXの「一つのことをうまくやれ」そのものだ。namespacesもcgroupsも`/proc`や`/sys`配下のファイル操作で制御され、「すべてはファイルである」というUNIXの原則がここでも生きている。コンテナ技術は、UNIX哲学の50年にわたる蓄積の上に立っている。

### 冒頭の問いへの暫定回答

「コンテナ技術は、UNIX哲学の延長線上にあるのか。それとも別の何かか。」

延長線上にある。ただし、単純な継承ではない。chrootからDockerまでの50年は、「プロセスの隔離をより強固にする」というUNIXの設計思想の一つの軸を、段階的に発展させてきた歴史だ。namespacesがPlan 9のper-process名前空間に触発されているように、cgroupsがGoogleの内部インフラの要請から生まれたように、各技術はUNIXの設計原則を土台としつつ、新たな要件に応えて進化してきた。

ただし、UNIXパイプラインとコンテナオーケストレーションの間には本質的な差異もある。パイプラインの各コマンドは同一マシン上で同期的にテキストストリームを受け渡す。コンテナは分散環境でネットワーク越しに非同期で通信する。この差異——ネットワーク分断、遅延、部分障害——は、UNIXの設計が前提としなかった複雑さを持ち込む。設計哲学は継承できる。だが文脈は常に変わる。その変化に対応するために何が必要かは、第23回で改めて掘り下げる。

### 次回予告

次回は「WSL――WindowsがUNIXに屈服した日」。

2001年、MicrosoftのCEOスティーブ・バルマーは「LinuxはIT業界の知的財産権を攻撃する癌だ」と発言した。2014年、サティア・ナデラがCEOに就任し「Microsoft loves Linux」と宣言した。2016年、Windows Subsystem for Linux（WSL）が登場し、WindowsカーネルにLinux互換レイヤーが搭載された。2019年のWSL 2では、実際のLinuxカーネルがHyper-V上で動くようになった。

Microsoftという、UNIX/Linuxと最も長く対立してきた企業が、自らのOS上にLinux環境を提供し始めた。この事実は何を意味するのか。UNIXの設計思想が「選択肢の一つ」ではなく「開発者にとっての必需品」になったことの証なのか。

---

## 参考文献

- Wikipedia, "chroot": <https://en.wikipedia.org/wiki/Chroot>
- Chris's Wiki, "ChrootHistory": <https://utcc.utoronto.ca/~cks/space/blog/unix/ChrootHistory>
- Wikipedia, "FreeBSD jail": <https://en.wikipedia.org/wiki/FreeBSD_jail>
- Klara Systems, "FreeBSD Jails - The Beginning of FreeBSD Containers": <https://klarasystems.com/articles/freebsd-jails-the-beginning-of-freebsd-containers/>
- Wikipedia, "Solaris Containers": <https://en.wikipedia.org/wiki/Solaris_Containers>
- Wikipedia, "cgroups": <https://en.wikipedia.org/wiki/Cgroups>
- Wikipedia, "Linux namespaces": <https://en.wikipedia.org/wiki/Linux_namespaces>
- LWN.net, "Namespaces in operation, part 1: namespaces overview": <https://lwn.net/Articles/531114/>
- Wikipedia, "LXC": <https://en.wikipedia.org/wiki/LXC>
- Wikipedia, "Docker (software)": <https://en.wikipedia.org/wiki/Docker_(software)>
- Docker Blog, "Docker: Nine Years YOUNG": <https://www.docker.com/blog/docker-nine-years-young/>
- PyCon 2013, "The Future of Linux Containers" (Solomon Hykes): <https://pyvideo.org/pycon-us-2013/the-future-of-linux-containers.html>
- Docker Docs, "Run multiple processes in a container": <https://docs.docker.com/engine/containers/multi-service_container/>
- Docker Docs, "OverlayFS storage driver": <https://docs.docker.com/engine/storage/drivers/overlayfs-driver/>
- Wikipedia, "Kubernetes": <https://en.wikipedia.org/wiki/Kubernetes>
- Google Cloud Blog, "From Google to the world: The Kubernetes origin story": <https://cloud.google.com/blog/products/containers-kubernetes/from-google-to-the-world-the-kubernetes-origin-story>
- TechCrunch, "As Kubernetes Hits 1.0, Google Donates Technology To CNCF", July 21, 2015: <https://techcrunch.com/2015/07/21/as-kubernetes-hits-1-0-google-donates-technology-to-newly-formed-cloud-native-computing-foundation-with-ibm-intel-twitter-and-others/>
- Open Container Initiative: <https://opencontainers.org/about/overview/>
- Wikipedia, "Open Container Initiative": <https://en.wikipedia.org/wiki/Open_Container_Initiative>
- Kubernetes Blog, "Kubernetes Multicontainer Pods: An Overview": <https://kubernetes.io/blog/2025/04/22/multi-container-pods-overview/>
- Linux Foundation Blog, "A Brief Look at the Roots of Linux Containers": <https://www.linuxfoundation.org/blog/blog/a-brief-look-at-the-roots-of-linux-containers>
