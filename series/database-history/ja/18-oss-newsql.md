# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第18回：CockroachDB, TiDB——OSSで挑むNewSQL

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Spannerの設計思想を継承したOSSのNewSQLデータベースがどのように生まれたか
- CockroachDB（2014年〜）の創業経緯——元Google社員がSpannerの思想をOSSで再現した挑戦
- TiDB（2015年〜）の創業経緯——中国発のMySQL互換NewSQLとそのアーキテクチャ
- YugabyteDB（2016年〜）の位置づけ——元Facebook社員によるPostgreSQL互換の選択肢
- Raftアルゴリズム（2014年、Ongaro & Ousterhout）がNewSQLの基盤となった理由
- 原子時計なしにトランザクションの順序付けを実現するHybrid Logical Clock（HLC）
- CockroachDBの3ノードクラスタによるハンズオン——ノード障害時の自動復旧と分散トランザクション

---

## 1. 「PostgreSQL互換のSQLが、そのまま動いた」

2021年頃、私はあるプロジェクトの技術検証でCockroachDBを初めて触った。

前回取り上げたGoogle Spannerの設計思想に衝撃を受けていた私にとって、CockroachDBは「Spannerを自分の手元で動かせる」という魅力的な選択肢に見えた。だが正直に言えば、半信半疑だった。Spannerの核心であるTrueTimeは原子時計とGPSに依存している。その前提なしに、分散データベースで強一貫性を実現できるのか。

ローカルマシンでDockerを使い、3ノードのCockroachDBクラスタを立ち上げた。所要時間は5分もかからなかった。そしてpsqlクライアントから接続し、PostgreSQLと同じSQLを叩いた。

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO users (name, email) VALUES ('test', 'test@example.com');
SELECT * FROM users;
```

動いた。PostgreSQL互換のSQLが、3ノードの分散クラスタ上で、そのまま動いた。

次に、1ノードを強制停止した。`docker stop`でコンテナを落とす。そして再びSQLを叩く。動く。データも失われていない。残りの2ノードが自動的にRaftの合意を維持し、サービスを継続していた。

感動と同時に、疑問が湧いた。これは本当にSpannerと同じ保証を提供しているのか。原子時計なしに、何を犠牲にしているのか。そして、この技術はどこまで「実用」に耐えるのか。

あなたが使っているRDBがPostgreSQLやMySQLなら、こう考えてほしい。もしそのSQLをそのまま使えて、かつ自動的にスケールアウトし、ノード障害にも耐えるデータベースがあるとしたら。それは「万能の銀の弾丸」なのか、それとも新たなトレードオフの始まりなのか。

---

## 2. Spannerの子供たち——NewSQL OSSの誕生

### CockroachDB——Google File Systemチームからの挑戦

CockroachDBの物語は、Google社内から始まる。

Spencer Kimball、Peter Mattis、Ben Darnell。3人は元Google社員だ。KimballとMattisはGoogle File System（GFS）チームのメンバーであり、DarnellはGoogle Readerチームに所属していた。3人ともGoogle在籍中にBigtableやSpannerを使用しており、Spannerの設計思想を深く理解していた。

2012年、Kimball、Mattis、Brian McGinnisはViewFinderという写真共有アプリのスタートアップを立ち上げた。このプロジェクトでデータベースの課題に直面したことが、後のCockroachDBの着想に繋がった。2013年にSquare（現Block）がViewFinderを買収した後、KimballとMattisは次の構想を練り始める。

2014年1月、KimballはCockroachDBの最初の設計文書を書いた。そして2月、GitHubにオープンソースプロジェクトとして公開した。設計文書は明確な目標を掲げていた。「Spannerのような分散SQLデータベースを、誰もが利用できるOSSとして実現する」と。

2015年5月、VCからの関心を受けて3人はCockroach Labs社を正式に設立した。Benchmark Capitalを中心としたシードラウンドで630万ドルを調達。そして2017年5月、CockroachDB v1.0をリリースした。初のproduction-readyバージョンだ。

名前の由来は「ゴキブリ」——あのしぶとい生物だ。ノードが死んでも、データセンターが落ちても、システムが生き続ける。そういうデータベースを作りたいという意志が込められている。マーケティング的には賛否があるが、技術者としてはその率直さに好感が持てる。

### TiDB——中国発のMySQL互換NewSQL

同じ2015年、地球の反対側でもう一つのNewSQLプロジェクトが始まっていた。

PingCAPは2015年4月、Max Liu、Edward Huang、Dylan Cuiの3名が中国で設立した。3人は中国のインターネット企業でインフラ基盤の開発に携わったエンジニアだ。Max LiuはCodisというオープンソースのRedisクラスタソリューションの共同開発者であり、Edward HuangはGoとRustに精通するアーキテクトだった。

彼らが直面していた課題は、CockroachDBの創業者たちと驚くほど似ている。MySQLのシャーディングによるスケーリングの限界、アプリケーション層の複雑化、運用負荷の増大。違いは、彼らのターゲットがPostgreSQLではなくMySQLだったことだ。

中国のインターネット企業——特にeコマースやフィンテック——ではMySQLが圧倒的に普及していた。シャーディングミドルウェア（VitessやMySQL Proxyに相当する自社ツール）で凌いでいたが、根本的な解決にはならない。TiDBは「MySQLのDROP-IN REPLACEMENT」を目指した。既存のMySQLアプリケーションを、コードを変更せずに分散データベースに移行する。

TiDB 1.0 GAは2017年10月16日にリリースされた。CockroachDB v1.0の5ヶ月後だ。Spannerの論文発表から5年——OSSのNewSQLは、2017年に相次いで実用段階に達した。

### YugabyteDB——Cassandraの経験から生まれた第三の選択肢

2016年2月、さらにもう一つのNewSQLプロジェクトが始まった。

YugabyteDBの創業者はKannan Muthukkaruppan、Karthik Ranganathan、Mikhail Bautinの3名だ。彼らは元Facebook社員で、Facebookで最初のウェブスケールデータベースの一つであるCassandraの構築と運用に携わっていた。

興味深いのは、CockroachDBの創業者がSpanner（NewSQL）から着想を得たのに対し、YugabyteDBの創業者はCassandra（NoSQL）の経験から出発している点だ。Cassandraの分散アーキテクチャの強みを活かしつつ、CassandraにはなかったSQL互換とACIDトランザクションを提供する。第15回で語ったNoSQLの世界と、第17回で語ったNewSQLの世界を架橋する試みと言える。

YugabyteDBは2017年11月に最初のパブリックベータをリリースし、2019年7月にApache 2.0ライセンスでオープンソース化された。PostgreSQL互換のYSQLとCassandra互換のYCQLという二つのAPIを提供する独自のアプローチを取っている。

### 三者の共通点と差異

この3つのNewSQL OSSには、共通の設計目標がある。

第一に、SQLインターフェース。CockroachDBとYugabyteDBはPostgreSQL互換、TiDBはMySQL互換。既存のRDBで使い慣れたSQLをそのまま使えることが、NewSQLの普及にとって決定的に重要だった。

第二に、分散スケーラビリティ。データを自動的にシャーディングし、ノードの追加・削除に応じてリバランスする。第11回で語ったシャーディングの苦しみを、データベース自身が引き受ける。

第三に、強一貫性。Raftアルゴリズムによる合意で、分散トランザクションのACID保証を提供する。第12回のCAP定理でいえば、CP（一貫性と分断耐性）を選択しつつ、可用性を可能な限り高める設計だ。

だが差異も大きい。アーキテクチャ、互換性の深さ、ライセンス、コミュニティ、ターゲット市場——それぞれが異なるトレードオフを選んでいる。

---

## 3. Raft——「理解できる」合意アルゴリズム

### なぜPaxosではなくRaftか

NewSQL OSSの技術的基盤を理解するには、Raftアルゴリズムの話を避けて通れない。

第17回で触れたように、Spannerはレプリケーションの合意にPaxosを使用している。Paxosは1998年にLeslie Lamportが発表した分散合意アルゴリズムで、理論的には完全だが、一つ大きな問題があった。理解が困難なのだ。

Lamport自身、1990年に最初の論文を投稿した際、査読者から「興味深いがあまり重要ではない」と却下された逸話がある。その後1998年に再投稿して受理されたが、実装者たちはPaxosの仕様を正確に実装することに苦しみ続けた。Googleのエンジニアですら、Chubbyロックサービスの論文（2006年）で「Paxosの実装は驚くほど難しい」と認めている。

2014年、スタンフォード大学のDiego OngaroとJohn Ousterhoutが「In Search of an Understandable Consensus Algorithm」という論文を発表した。この論文はUSENIX ATC 2014でBest Paper Awardを受賞した。

Raftの核心は、名前が示す通り「理解可能性」だ。Paxosと数学的に同等の正確性と効率を持ちながら、設計を明確な部分に分解することで、実装者が正しく理解し、正しく実装できることを目指した。

```
Raftの分解された設計

┌─────────────────────────────────────────────┐
│  Raft合意アルゴリズム                          │
│                                             │
│  1. リーダー選出 (Leader Election)            │
│     ・一つのRaftグループに一つのLeader          │
│     ・Leaderがダウンしたら、残りが投票で新Leader │
│     ・選出にはグループの過半数の合意が必要       │
│                                             │
│  2. ログ複製 (Log Replication)               │
│     ・全ての書き込みはLeaderを経由する          │
│     ・LeaderがFollowerにログエントリを送信      │
│     ・過半数がログを保存したら「コミット」       │
│                                             │
│  3. 安全性 (Safety)                          │
│     ・コミットされたエントリは永続的             │
│     ・Leaderのログは常に最も「新しい」          │
│     ・旧Leaderの未コミットエントリは上書きされる │
│                                             │
│  Paxosとの違い:                              │
│  ・Paxosは単一の合意を定式化 → 実装が曖昧      │
│  ・Raftはリーダーベース → 状態遷移が明確        │
│  ・Raftは「理解しやすさ」を設計目標に含む       │
└─────────────────────────────────────────────┘
```

OngaroとOusterhoutは論文の中で、スタンフォードの学生を対象としたユーザースタディの結果を報告している。PaxosとRaftの両方を学んだ学生に理解度テストを行ったところ、Raftの方が有意に高い点数を記録した。

この「理解しやすさ」は、学術的な美点にとどまらない。実用上の巨大な利点だ。分散合意アルゴリズムの実装にバグがあれば、データの不整合——最悪の場合、データの喪失——に直結する。アルゴリズムを正しく理解できなければ、正しく実装できない。正しく実装できなければ、正しくデバッグもできない。

CockroachDB、TiDB、YugabyteDBの三者がいずれもRaftを採用したのは偶然ではない。OSSプロジェクトとして世界中の開発者がコードをレビューし、バグを発見し、改善に貢献するためには、合意アルゴリズムが理解可能であることが前提条件だった。

### マルチRaftアーキテクチャ

NewSQL OSSの各システムは、単一のRaftグループではなく「マルチRaft」アーキテクチャを採用している。データをRange（CockroachDB）やRegion（TiKV）と呼ばれる単位に分割し、各分割が独立したRaftグループを形成する。

```
マルチRaftアーキテクチャ（CockroachDBの例）

 ┌──────── Node 1 ────────┐  ┌──────── Node 2 ────────┐  ┌──────── Node 3 ────────┐
 │                        │  │                        │  │                        │
 │  Range 1 [A-F]         │  │  Range 1 [A-F]         │  │  Range 1 [A-F]         │
 │  ★ Leader              │  │    Follower             │  │    Follower             │
 │  ─────────────────     │  │  ─────────────────     │  │  ─────────────────     │
 │  Range 2 [G-M]         │  │  Range 2 [G-M]         │  │  Range 2 [G-M]         │
 │    Follower             │  │  ★ Leader              │  │    Follower             │
 │  ─────────────────     │  │  ─────────────────     │  │  ─────────────────     │
 │  Range 3 [N-S]         │  │  Range 3 [N-S]         │  │  Range 3 [N-S]         │
 │    Follower             │  │    Follower             │  │  ★ Leader              │
 │  ─────────────────     │  │  ─────────────────     │  │  ─────────────────     │
 │  Range 4 [T-Z]         │  │  Range 4 [T-Z]         │  │  Range 4 [T-Z]         │
 │  ★ Leader              │  │    Follower             │  │    Follower             │
 └────────────────────────┘  └────────────────────────┘  └────────────────────────┘

 各RangeはそれぞれRaftグループを形成する
 ・Leaderはノード間で分散 → 負荷分散
 ・各Rangeは独立に合意を取る → 並列処理が可能
 ・Rangeが大きくなると自動分割（split）
 ・ノード追加時は自動リバランス
```

この設計の利点は二つある。第一に、各Rangeが独立に合意を取るため、異なるRangeへの書き込みは並列に実行できる。第二に、Leaderがノード間で分散されるため、特定のノードに負荷が集中しない。Spannerのsplitベースの設計を踏襲しつつ、Raftの明快さを活かしたアーキテクチャだ。

---

## 4. CockroachDBとTiDB——二つのアーキテクチャ

### CockroachDB——モノリシックなノードとHLC

CockroachDBのアーキテクチャは、各ノードが対等（symmetric）であることを特徴とする。すべてのノードがSQL層、分散KVストア、Raftの合意を一体として持つ。クライアントはどのノードに接続してもよい。

```
CockroachDBのノード構成

 ┌──────────────────── CockroachDB Node ────────────────────┐
 │                                                         │
 │  ┌──────────────────────────────────┐                   │
 │  │  SQL Layer                       │                   │
 │  │  ・PostgreSQLワイヤープロトコル互換  │                   │
 │  │  ・SQL解析・最適化・実行           │                   │
 │  │  ・分散クエリの計画と実行          │                   │
 │  └──────────┬───────────────────────┘                   │
 │             │                                           │
 │  ┌──────────▼───────────────────────┐                   │
 │  │  Transaction Layer               │                   │
 │  │  ・MVCC (Multi-Version Concurrency│                   │
 │  │    Control)                      │                   │
 │  │  ・分散トランザクション            │                   │
 │  │  ・Hybrid Logical Clock (HLC)    │                   │
 │  └──────────┬───────────────────────┘                   │
 │             │                                           │
 │  ┌──────────▼───────────────────────┐                   │
 │  │  Distribution Layer              │                   │
 │  │  ・Rangeの管理・ルーティング       │                   │
 │  │  ・自動split / merge             │                   │
 │  │  ・自動リバランス                 │                   │
 │  └──────────┬───────────────────────┘                   │
 │             │                                           │
 │  ┌──────────▼───────────────────────┐                   │
 │  │  Replication Layer               │                   │
 │  │  ・Raft合意                      │                   │
 │  │  ・スナップショットの送受信         │                   │
 │  └──────────┬───────────────────────┘                   │
 │             │                                           │
 │  ┌──────────▼───────────────────────┐                   │
 │  │  Storage Layer                   │                   │
 │  │  ・Pebble (LSMベースのKVストア)   │                   │
 │  └──────────────────────────────────┘                   │
 └─────────────────────────────────────────────────────────┘

 全ノードが同一構成 → どのノードにも接続可能
```

このモノリシックな設計は運用をシンプルにする。すべてのノードが同じバイナリを実行し、同じ役割を担う。コンポーネントごとに異なるスケーリングが必要なTiDBとは対照的だ。

CockroachDBの最も独自性の高い技術的判断は、原子時計の代わりにHybrid Logical Clock（HLC）を採用した点にある。

SpannerはTrueTime APIにより、原子時計とGPSで物理時刻の不確実性区間を1〜7ミリ秒に抑え、Commit Waitで外部一貫性を保証する。だがCockroachDBはOSSであり、ユーザーのインフラに原子時計を要求できない。

HLCは物理コンポーネント（ローカルの壁時計に近い値）と論理コンポーネント（同じ物理時刻のイベントを区別する数値）で構成される。ノード間で通信が行われるたびに、物理コンポーネントが同期され、論理コンポーネントが更新される。これにより、Lamportの論理時計と物理時計の良い部分を組み合わせた時刻管理が実現される。

```
Hybrid Logical Clock (HLC) の構成

 Spanner TrueTime          CockroachDB HLC
 ────────────             ──────────────
 TT.now() → [earliest,    HLC.now() → {physical, logical}
              latest]
                           physical: NTPで同期された壁時計
 原子時計 + GPS で           logical: 同一physical値のイベントを
 不確実性区間を保証            区別するカウンタ

 保証: 外部一貫性            保証: Serializability
      (Strict Serializability)
                           Linearizabilityは保証しない
 コスト: 原子時計が必要       コスト: NTP精度に依存
         Commit Wait                max_offset（デフォルト500ms）
                                    の範囲内で時計がずれる可能性

 ──────────────────────────────────────────────
 実用上の差:
 ・ほとんどのアプリケーションでは差は観測されない
 ・因果関係のある別クライアントのトランザクションで
   理論上はタイムスタンプの逆転が起こりうる
 ・CockroachDBのcausality tokenで回避可能
```

重要な違いを正直に述べる。SpannerのTrueTimeは外部一貫性（Strict Serializability）を保証する。CockroachDBのHLCはSerializabilityを保証する。両者の差は微妙だが、確かに存在する。

外部一貫性は、トランザクションのコミット順序が実時間の順序と一致することを保証する。つまり「T1がコミットした後にT2がコミットした」場合、すべてのノードがその順序を認識する。HLCベースのSerializabilityでは、因果関係のない別のクライアントからのトランザクション間で、タイムスタンプの逆転が理論上は起こりうる。

ただし、この差が実際のアプリケーションで問題になるケースは極めて稀だ。CockroachDBはcausality token（因果関係トークン）を提供しており、あるトランザクションのコミットトークンを次のトランザクションに渡すことで、因果関係のあるトランザクション間のタイムスタンプの順序を保証できる。

原子時計なしにSpannerに近い保証を実現する。この工学的判断が、CockroachDBをOSSとして成立させた核心だ。

### TiDB——ストレージとコンピュートの分離

TiDBのアーキテクチャは、CockroachDBとは根本的に異なる設計判断を取っている。ストレージとコンピュートを明確に分離したのだ。

```
TiDBのアーキテクチャ

 ┌─────── TiDB Server ──────┐   ┌─────── TiDB Server ──────┐
 │ (Stateless SQL Layer)     │   │ (Stateless SQL Layer)     │
 │ ・MySQL互換プロトコル      │   │ ・MySQL互換プロトコル      │
 │ ・SQL解析・最適化          │   │ ・SQL解析・最適化          │
 │ ・分散実行計画の生成       │   │ ・分散実行計画の生成       │
 └────────────┬──────────────┘   └────────────┬──────────────┘
              │                               │
              └──────────┬────────────────────┘
                         │
         ┌───────────────▼───────────────────┐
         │       PD (Placement Driver)       │
         │ ・クラスタメタデータの管理           │
         │ ・タイムスタンプ発行（TSO）          │
         │ ・データスケジューリング             │
         │ ・Raftグループのリーダーバランス      │
         └───────────────┬───────────────────┘
                         │
    ┌────────────────────┼─────────────────────┐
    │                    │                     │
 ┌──▼──────────┐  ┌──────▼──────┐  ┌──────────▼──┐
 │  TiKV Node  │  │  TiKV Node  │  │  TiKV Node  │
 │ (Row Store) │  │ (Row Store) │  │ (Row Store) │
 │ ・Raft合意    │  │ ・Raft合意    │  │ ・Raft合意    │
 │ ・RocksDB    │  │ ・RocksDB    │  │ ・RocksDB    │
 │ ・Rust実装    │  │ ・Rust実装    │  │ ・Rust実装    │
 └──────────────┘  └─────────────┘  └─────────────┘
        │                │                │
        └────────────────┼────────────────┘
                         │ (Raft Learner)
    ┌────────────────────┼─────────────────────┐
    │                    │                     │
 ┌──▼──────────┐  ┌──────▼──────┐  ┌──────────▼──┐
 │TiFlash Node │  │TiFlash Node │  │TiFlash Node │
 │(Column Store)│  │(Column Store)│  │(Column Store)│
 │ ・分析クエリ   │  │ ・分析クエリ   │  │ ・分析クエリ   │
 │ ・C++実装     │  │ ・C++実装     │  │ ・C++実装     │
 └──────────────┘  └─────────────┘  └─────────────┘
```

TiDBの主要コンポーネントは4つだ。

**TiDB Server**はステートレスなSQL層だ。MySQL互換のプロトコルを外部に公開し、SQLの解析・最適化・分散実行計画の生成を担う。ステートレスであるため、負荷に応じてTiDB Serverの台数だけを増減できる。SQLの処理能力とストレージ容量を独立にスケールできるのは、CockroachDBのモノリシック設計にはない利点だ。

**TiKV**は分散トランザクショナルKey-Valueストレージエンジンだ。Rust実装であり、内部ストレージにRocksDBを使用する。データはRaftにより複数のレプリカ（デフォルト3）で管理される。TiKVは単独でも利用可能で、2020年9月にCNCF（Cloud Native Computing Foundation）のGraduatedプロジェクトとなった。KubernetesやPrometheusと同列の成熟度認定だ。

**PD（Placement Driver）**はクラスタの「頭脳」だ。メタデータの管理、タイムスタンプの発行（TSO: Timestamp Oracle）、データのスケジューリングを担う。TiKVノードからリアルタイムに報告されるデータ分布に基づいて、Regionの移動やLeaderのバランスを指示する。

**TiFlash**はカラムナーストアだ。TiKVの行指向データから、Raft Learnerプロトコルによりカラムナーレプリカを非同期で複製する。これによりTiDBはHTAP（Hybrid Transactional/Analytical Processing）——トランザクション処理と分析処理を同一システムで実行する——を実現する。第21回で取り上げるHTAPの先駆的な実装の一つだ。

### 二つのアーキテクチャの比較

CockroachDBのモノリシック設計とTiDBの分離設計は、どちらが「正しい」ということではない。異なるトレードオフを選んだ結果だ。

CockroachDBの利点は運用のシンプルさだ。単一バイナリをデプロイするだけでよい。すべてのノードが同じ役割を担うため、コンポーネント間の依存関係やバージョン不整合を心配する必要がない。だがSQL処理能力とストレージ容量を独立にスケールすることが難しい。

TiDBの利点はスケーリングの柔軟性だ。クエリが重いがデータ量は少ないワークロードならTiDB Serverを増やし、データ量が増えたならTiKVノードを追加する。分析クエリが必要ならTiFlashを追加する。各コンポーネントを独立にスケールできる。だがコンポーネントが多い分、運用の複雑さは増す。PD、TiDB Server、TiKV、TiFlash——それぞれの監視と管理が必要だ。

そして互換性のターゲットが異なる。CockroachDBはPostgreSQLの型システムやSQL構文を再現し、TiDBはMySQLのプロトコルと構文を再現する。この選択は技術的な優劣ではなく、ターゲット市場の反映だ。欧米ではPostgreSQLが主流になりつつあり、中国・アジアではMySQLが依然として強い。

---

## 5. NewSQLの「現実」——万能ではないという事実

### レイテンシの代償

NewSQL OSSを技術検証する際、最初に直面するのがレイテンシだ。

単一ノードのPostgreSQLで1ミリ秒未満で完了するINSERT文が、CockroachDBの3ノードクラスタでは数ミリ秒〜十数ミリ秒かかる。これはRaftの合意プロトコルの本質的なコストだ。書き込みがコミットされるには、Leaderが提案を発行し、過半数のFollowerがログを永続化し、その応答をLeaderが受け取る必要がある。最低でもネットワークラウンドトリップ1回分のレイテンシが加わる。

マルチリージョン構成ではさらに大きくなる。東京とバージニアの間のネットワークレイテンシは約150ミリ秒だ。3ノードを異なるリージョンに配置すれば、書き込みのたびにこのレイテンシがかかる。

この数ミリ秒が問題にならないアプリケーションは多い。eコマースの注文処理やSaaSのデータ管理では、数ミリ秒の追加レイテンシは許容範囲内だろう。だが高頻度取引システムやリアルタイムゲームのバックエンドでは致命的だ。

私が技術検証で学んだのは、「NewSQLの導入を検討する前に、まずワークロードのレイテンシ要件を明確にせよ」ということだ。分散の恩恵が、レイテンシの代償に見合うかどうか。この判断を怠ると、導入後に「遅い」という不満が噴出する。

### ライセンスの変遷

OSSのNewSQLを語る上で、ライセンスの問題を避けて通れない。

CockroachDBは当初Apache 2.0ライセンスで公開された。だが2019年、Business Source License（BSL）に変更した。BSLはソースコードは公開されるが、競合サービスでの利用を制限するライセンスだ。そして2024年8月、CockroachDBはさらにライセンスを変更し、CockroachDB Coreエディションを廃止して単一のEnterprise版に統合した。年間売上1,000万ドル以上の企業にはCPU数ベースの有料ライセンスが必要となり、それ以下のスタートアップは無料で利用できる。

この変更はオープンソースコミュニティで大きな論争を引き起こした。Apache 2.0 → BSL → Enterprise Only という段階的な移行は、VCの出資を受けたOSSデータベース企業のビジネスモデルの構造的な困難を浮き彫りにしている。OSSとして広く普及させ、エンタープライズ機能で収益を上げるモデルは、クラウドベンダーがOSSをマネージドサービスとして提供する時代には持続が難しい。

一方、TiDBはApache 2.0ライセンスを維持している。YugabyteDBもApache 2.0だ。ただし、これが永続的に続く保証はない。ライセンスの変更は、OSSデータベースを選定する際のリスク要因として認識しておくべきだ。

### 運用の複雑さ

「分散データベースは管理が自動化されている」——この期待は半分正しく、半分間違っている。

確かに、シャーディングの管理、レプリカの配置、ノード障害時のフェイルオーバーは自動化されている。第11回で語った手動シャーディングの苦しみからは解放される。だが新たな運用上の課題が生まれる。

分散クエリのパフォーマンスチューニングは、単一ノードのRDBとは異なるスキルが必要だ。EXPLAIN ANALYZEの出力が示す実行計画は、どのノードでどのデータが処理されたかを含む複雑なものになる。ホットスポット（特定のRangeへのアクセス集中）の検出と対処、Raftのレイテンシ監視、ノード間のネットワーク品質の維持——これらは単一ノードのPostgreSQLでは不要だった運用タスクだ。

私の経験から言えば、NewSQLの導入が正当化されるのは、単一ノードのRDBでは「どうしても」解決できないスケーラビリティや可用性の要件がある場合だ。「なんとなく将来的にスケールが必要になるかもしれない」という理由でNewSQLを選ぶのは、過剰設計の典型だ。多くのアプリケーションにとって、単一ノードのPostgreSQLは驚くほど遠くまで行ける。

---

## 6. ハンズオン: CockroachDB 3ノードクラスタでNewSQLを体験する

今回のハンズオンでは、CockroachDBの3ノードクラスタをDockerで構築し、ノード障害時の自動復旧、分散トランザクション、PostgreSQL互換の動作を確認する。

### 演習概要

1. CockroachDB 3ノードクラスタをDockerで構築する
2. PostgreSQL互換のSQLでテーブル作成とデータ投入を行う
3. 分散トランザクション（送金処理）を実行する
4. ノード障害時の自動復旧を体験する
5. Rangeの分散状況を確認する

### 環境構築

```bash
# handson/database-history/18-oss-newsql/setup.sh を実行
bash setup.sh
```

### 演習1: クラスタの起動とPostgreSQL互換SQLの実行

setup.shが3ノードのCockroachDBクラスタをDockerで起動し、クラスタを初期化する。

```bash
# 3ノードクラスタの起動（setup.shが自動実行）
docker network create roachnet

docker run -d --name roach1 --hostname roach1 --network roachnet \
  cockroachdb/cockroach:latest start \
  --insecure --join=roach1,roach2,roach3

docker run -d --name roach2 --hostname roach2 --network roachnet \
  cockroachdb/cockroach:latest start \
  --insecure --join=roach1,roach2,roach3

docker run -d --name roach3 --hostname roach3 --network roachnet \
  cockroachdb/cockroach:latest start \
  --insecure --join=roach1,roach2,roach3

# クラスタの初期化
docker exec roach1 cockroach init --insecure
```

クラスタが起動したら、PostgreSQL互換のSQLでデータベースを操作する。

```sql
-- CockroachDB SQL（PostgreSQL互換）
CREATE DATABASE bankdb;
USE bankdb;

CREATE TABLE accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner STRING NOT NULL,
  balance INT NOT NULL CHECK (balance >= 0),
  created_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO accounts (owner, balance) VALUES
  ('Alice', 100000),
  ('Bob', 50000),
  ('Charlie', 75000);

SELECT * FROM accounts;
```

PostgreSQLユーザーにとって馴染みのあるSQLが、分散クラスタ上でそのまま動く。`gen_random_uuid()`や`TIMESTAMPTZ`型など、PostgreSQLの関数や型がそのまま使える。

### 演習2: 分散トランザクション——送金処理

```sql
-- 分散トランザクション: AliceからBobに30,000を送金
BEGIN;
  UPDATE accounts SET balance = balance - 30000
    WHERE owner = 'Alice';
  UPDATE accounts SET balance = balance + 30000
    WHERE owner = 'Bob';
COMMIT;

-- 送金後の残高確認
SELECT owner, balance FROM accounts ORDER BY owner;
-- 合計額が変わっていないことを確認
SELECT SUM(balance) FROM accounts;
```

このトランザクションは、AliceとBobのデータが異なるRangeに属する場合でも、原子的に実行される。CockroachDBは内部的にRaftの合意と二相コミットを使用し、分散トランザクションの整合性を保証する。

### 演習3: ノード障害と自動復旧

```bash
# Node 3を強制停止
docker stop roach3

# 残り2ノードでクエリが継続できることを確認
docker exec roach1 cockroach sql --insecure --database=bankdb \
  -e "SELECT owner, balance FROM accounts ORDER BY owner;"

# 送金トランザクションも実行可能
docker exec roach1 cockroach sql --insecure --database=bankdb \
  -e "BEGIN; UPDATE accounts SET balance = balance - 5000 WHERE owner = 'Bob'; UPDATE accounts SET balance = balance + 5000 WHERE owner = 'Charlie'; COMMIT;"

# Node 3を復帰
docker start roach3

# データが自動的に同期されることを確認
sleep 10
docker exec roach3 cockroach sql --insecure --database=bankdb \
  -e "SELECT owner, balance FROM accounts ORDER BY owner;"
```

3ノードのRaftグループでは、1ノードがダウンしても残りの2ノードで過半数（2/3）を維持できるため、読み書きが継続される。ダウンしたノードが復帰すると、Raftのログ複製により自動的にデータが同期される。

### 演習4: Rangeの分散状況を確認する

```sql
-- Rangeの分散状況を確認
SHOW RANGES FROM TABLE accounts;

-- クラスタのノード状態を確認
SELECT node_id, address, is_live FROM crdb_internal.gossip_nodes;
```

`SHOW RANGES`はCockroachDB固有のコマンドで、テーブルのデータがどのRangeに分割され、各Rangeのレプリカがどのノードに配置されているかを確認できる。データ量が少ない段階では1つのRangeに収まるが、データが増えると自動的にsplitされる。

### 後片付け

```bash
docker rm -f roach1 roach2 roach3 2>/dev/null || true
docker network rm roachnet 2>/dev/null || true
```

---

## 7. OSSで挑むということ

第18回を振り返ろう。

**NewSQL OSSは、Spannerの設計思想を「誰もが使える形」に翻訳する試みだ。** CockroachDBはGoogle File Systemチーム出身のKimball、Mattis、Darnellが2014年に開始し、TiDBはLiu、Huang、Cuiが2015年に中国で立ち上げ、YugabyteDBはFacebookのCassandraチーム出身のMuthukkaruppan、Ranganathan、Bautinが2016年に創業した。

**Raftアルゴリズム（2014年、Ongaro & Ousterhout）は、NewSQL OSSの基盤技術となった。** Paxosと数学的に同等でありながら「理解しやすい」合意アルゴリズムは、OSSとして世界中の開発者が参加するプロジェクトにとって不可欠の条件だった。

**CockroachDBとTiDBは、異なるアーキテクチャを選択した。** CockroachDBは全ノード対等のモノリシック設計でPostgreSQL互換、TiDBはストレージとコンピュートの分離設計でMySQL互換。どちらが「正しい」ではなく、異なるトレードオフの選択だ。

**原子時計なしの一貫性保証は、CockroachDBのHLCが解決策を示した。** Serializabilityを保証しつつ、外部一貫性との微細な差は実用上ほぼ無視できる。原子時計を前提としないことで、OSSとしての成立を可能にした。

**NewSQLは万能ではない。** レイテンシの代償、運用の複雑さ、ライセンスの変遷——これらのトレードオフを理解した上で選択すべきだ。多くのアプリケーションにとって、単一ノードのPostgreSQLで十分だという事実も忘れてはならない。

冒頭の問いに戻ろう。「Spannerの思想を、誰もが使えるOSSとして実現できるのか？」

答えは「条件付きでイエス」だ。原子時計なしにSpannerに近い保証を実現する工学的な解は存在する。だがSpannerと同一の保証ではない。そしてSpannerの運用はGoogleのインフラチームが担っているが、OSSのNewSQLの運用はあなた自身が担う。その違いは小さくない。

NewSQLは「RDBの安心感」と「分散の拡張性」を両立させる意欲的な試みだ。だがトレードオフは消えていない。消えることは、おそらくない。重要なのは、トレードオフを理解した上で「選ぶ」力を持つことだ。

次回「サーバレスDB——運用からの解放」では、データベースの「運用」そのものを問い直す。Amazon Aurora、PlanetScale、Neon——サーバレスDBは運用負荷をゼロに近づけようとしている。だが本当に「運用からの解放」は可能なのか。新たなトレードオフとともに語る。

---

### 参考文献

- Ongaro, D. and Ousterhout, J., "In Search of an Understandable Consensus Algorithm", USENIX ATC 2014. <https://www.usenix.org/conference/atc14/technical-sessions/presentation/ongaro>
- CockroachDB Architecture Overview. <https://www.cockroachlabs.com/docs/stable/architecture/overview>
- Cockroach Labs Blog, "Living without atomic clocks: Where CockroachDB and Spanner diverge". <https://www.cockroachlabs.com/blog/living-without-atomic-clocks/>
- Cockroach Labs Blog, "CockroachDB 1.0 is production-ready". <https://www.cockroachlabs.com/blog/cockroachdb-1-0-release/>
- PingCAP, "TiDB Architecture". <https://docs.pingcap.com/tidb/stable/tidb-architecture/>
- Huang, D. et al., "TiDB: A Raft-based HTAP Database", VLDB 2020. <https://www.vldb.org/pvldb/vol13/p3072-huang.pdf>
- TiKV GitHub (CNCF Graduated). <https://github.com/tikv/tikv>
- PingCAP, "TiDB Release Timeline". <https://docs.pingcap.com/tidb/stable/release-timeline/>
- YugabyteDB, "About Yugabyte". <https://www.yugabyte.com/about/>
- TechCrunch, "CockroachDB, the database that just won't die", 2021. <https://techcrunch.com/2021/07/15/cockroachdb-ec1-origin/>

---

**次回予告：** 第19回「サーバレスDB——運用からの解放」では、データベースの運用そのものを問い直す。Amazon RDSからAurora、そしてPlanetScale、Neon、Tursoへ。「サーバレス」の概念がデータベース層に到達したとき、何が変わり、何が変わらないのか。コンピュートとストレージの分離、ゼロスケール、ブランチング——新しいパラダイムの可能性と限界を語る。
