# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第17回：Google Spanner——分散と強一貫性の両立

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 「分散で強一貫性」という不可能に思えた課題に、Googleがどのようにアプローチしたか
- Google Spanner論文（2012年、OSDI）の核心——TrueTime APIと外部一貫性
- 原子時計とGPSによる時刻同期が、分散トランザクションの常識を変えた仕組み
- CAP定理を「超えた」のではなく「工学的に回避した」Spannerの設計判断
- Google F1——シャーディングされたMySQLからSpannerへの移行が証明したもの
- NewSQLという用語の誕生（2011年、451 Research）と、その意味するところ
- Cloud Spannerエミュレータを使った分散トランザクションのハンズオン

---

## 1. 「そんなことが可能なのか」

2020年頃、私はあるプロジェクトの技術選定でGoogle Cloud Spannerのドキュメントを初めて読んだ。

第12回で語ったCAP定理のことが頭にあった。分散システムにおいて、一貫性（Consistency）、可用性（Availability）、分断耐性（Partition Tolerance）の三つを同時に満たすことはできない。ネットワーク分断は現実に起きる以上、分断耐性は前提であり、残る選択肢は一貫性か可用性のどちらかを犠牲にすることだ。第15回で取り上げたCassandraやDynamoDBは可用性を優先し、結果整合性を受け入れた。それが分散データベースの「当然の帰結」だと私は理解していた。

ところがSpannerのドキュメントにはこう書いてある。「グローバルに分散し、強一貫性のあるトランザクションを提供する」と。

待ってほしい。それはCAP定理に反しないのか。

さらに読み進めると、99.999%——5ナインの可用性を約束するとある。年間のダウンタイムが約5分15秒という水準だ。これは「可用性を犠牲にした」システムの数字ではない。

原子時計とGPS。TrueTime API。外部一貫性。Paxosによるレプリケーション。聞いたことのない概念が次々と現れる。正直に言えば、最初は眉唾だった。Googleだから可能な「特殊解」であり、一般のエンジニアには関係のない世界だろうと。

だが論文を読み、アーキテクチャを理解するにつれて、認識が変わった。Spannerは魔法ではない。物理法則を書き換えたわけでもない。「時刻の不確実性」という、分散システムにおける最も根本的な問題に、工学的に正面から取り組んだ結果だった。

あなたは「分散データベースでは強一貫性は無理」と思い込んでいないだろうか。CAP定理を「分散は妥協の産物」と解釈していないだろうか。Spannerの物語は、その思い込みを揺さぶる。

---

## 2. Spannerが生まれた背景——Googleの「痛み」

### シャーディングの悪夢

Spannerの誕生を理解するには、Google内部で何が起きていたかを知る必要がある。

2000年代後半、Googleの広告プラットフォーム——AdWords（現Google Ads）——は、シャーディングされたMySQL上で稼働していた。Google広告はGoogleの収益の大部分を占める最重要システムだ。顧客数の増加とデータ量の拡大に伴い、MySQLのシャードを増やし続ける必要があった。

第11回で語ったように、シャーディングはスケーラビリティの代償として、アプリケーション層に多大な複雑さをもたらす。クロスシャードのJOIN、分散トランザクション、リシャーディング——これらの問題はGoogleほどの規模になると致命的だった。

そして、ついに限界が来た。

Google広告チームが最後に行ったリシャーディングは、2年以上の集中的作業を要した。数十チームの調整が必要で、収益に直結するミッションクリティカルなデータベースを停止させずにシャードを再分割するという、気の遠くなるような作業だった。

リシャーディングが完了したとき、広告チームは確信した。「二度とこれをやりたくない」と。

### Bigtableの限界

一方、GoogleにはBigtableがあった。2006年に論文が発表されたBigtableは、数千台のサーバに跨る巨大な分散ストレージであり、Google検索のインデックスやGmail、Google Earthなど多くのサービスの基盤だった。

だがBigtableにはトランザクションがない。厳密に言えば、単一行内のアトミックな操作は可能だが、複数行にまたがるトランザクションは提供されていなかった。これは第14回で触れたNoSQLの典型的な設計判断だ——スケーラビリティと引き換えにACIDトランザクションを犠牲にする。

Google社内でも、Bigtableのトランザクション不在に苦しむチームが多かった。結果として、Bigtable上に独自のトランザクション層を構築するプロジェクトが社内で乱立した。Megastore（2011年に論文発表）はその一つで、Bigtable上にPaxosベースのレプリケーションとトランザクションを載せた。だがMegastoreは書き込みスループットが低く、レイテンシも大きかった。

Googleが必要としていたのは、Bigtableのスケーラビリティと、RDBのトランザクション保証と、そしてグローバルな分散を、すべて兼ね備えたシステムだった。

### Spanner論文の衝撃

2012年10月、GoogleはOSDI（10th USENIX Symposium on Operating Systems Design and Implementation）において「Spanner: Google's Globally-Distributed Database」を発表した。筆頭著者はJames C. Corbett。Jeffrey Dean、Sanjay Ghemawatら26名の共著だ。

この論文が示したのは、グローバル規模でデータを分散し、外部一貫性のある分散トランザクションをサポートする最初のシステムだった。

論文の冒頭で、著者らはSpannerの位置づけを明確にしている。Spannerは「半リレーショナル」なデータベースだと。データはスキーマ化されたテーブルに格納され、SQLライクなクエリ言語でアクセスされる。Bigtableの「Key-Valueストア」からの意図的な進化であり、Google内部のチームがBigtableの上に独自のトランザクション層を構築するという「車輪の再発明」を止めさせるためのものだった。

2013年には、Google広告バックエンドのMySQL移行を報告するF1論文が発表された。「F1: A Distributed SQL Database That Scales」。移行時のデータ規模は約100TB、数百のアプリケーションがクエリを発行し、10万QPSを超え、99.999%の可用性を達成していた。Spannerが「論文上の理論」ではなく「Googleの最重要システムを支える実用品」であることの、これ以上ない証明だった。

---

## 3. TrueTime——時刻の不確実性に正面から挑む

### 分散システムにおける時刻の問題

Spannerのアーキテクチャを理解するには、まず「なぜ時刻が問題なのか」を理解する必要がある。

分散システムにおいて、異なるマシンの時計は完全には一致しない。NTP（Network Time Protocol）で同期しても、数ミリ秒から数十ミリ秒の誤差が生じる。ネットワーク遅延、OSのスケジューリング、ハードウェアの個体差——時計のずれを完全にゼロにすることは物理的に不可能だ。

なぜこれが問題なのか。分散トランザクションでは、複数のノードにまたがる操作の「順序」を決定する必要がある。トランザクションT1がT2より先にコミットしたなら、すべてのノードがその順序を認識しなければならない。だがノード間の時計がずれていれば、あるノードではT1が先に見え、別のノードではT2が先に見える。これが分散システムにおける一貫性の根本的な困難だ。

Leslie Lamportが1978年の論文「Time, Clocks, and the Ordering of Events in a Distributed System」で示したように、分散システムにおける「時間」は自明ではない。Lamportは物理時計に頼らず、論理時計（Logical Clock）によってイベントの因果関係を追跡する手法を提案した。この手法は多くの分散システムで採用されている。第15回で触れたDynamoのVector Clocksも、この系譜に連なるものだ。

だがLamportの論理時計には限界がある。因果関係のないイベント——並行に発生したイベント——の順序を決定できない。Spannerが必要としたのは、すべてのトランザクションに対してグローバルに一意な順序を決定する仕組みだった。

### TrueTime APIの設計

Spannerの解決策は、物理時計の精度を極限まで高めることだった。

GoogleはTrueTimeと呼ばれる時刻APIを開発した。TrueTimeの革新は、時刻を「単一の値」ではなく「不確実性区間」として表現する点にある。

```
TrueTime API

TT.now() → TTinterval [earliest, latest]

 ■ 従来のシステム時計
   now() → 2024-01-15T10:30:00.000
   →「今は10:30:00.000である」（だが実際にはずれている可能性がある）
   → 誤差は不明

 ■ TrueTime
   TT.now() → [10:30:00.001, 10:30:00.005]
   →「今は10:30:00.001から10:30:00.005の間のどこかである」
   → 不確実性区間 ε = 2ms（区間幅の半分）
   → 真の時刻がこの区間内にあることが保証される

 ■ TrueTimeが提供する3つの関数
   TT.now()    → TTinterval [earliest, latest]
   TT.after(t) → true if t has definitely passed
   TT.before(t)→ true if t has definitely not arrived
```

一般的なシステム時計は`now()`を呼ぶと単一のタイムスタンプを返す。だがその値がどれだけ正確かは保証されない。NTPで同期していても、「真の時刻」との誤差は不明だ。

TrueTimeは違う。`TT.now()`は区間を返す。「真の時刻は、この区間の中にある」と保証する。誤差を隠蔽するのではなく、明示的に表現する。この発想の転換がSpannerの根幹を支えている。

### 原子時計とGPSのハイブリッド

TrueTimeの不確実性区間を小さく保つために、Googleは各データセンターに二種類の専用タイムマスターを配置している。GPSレシーバーを搭載したタイムマスターと、原子時計（セシウムまたはルビジウム）を搭載したタイムマスターだ。

```
TrueTimeのインフラストラクチャ

 ┌─────────────── データセンター ──────────────────┐
 │                                                │
 │  ┌──────────────┐    ┌──────────────┐          │
 │  │ GPS          │    │ Atomic Clock │          │
 │  │ Time Master  │    │ Time Master  │          │
 │  └──────┬───────┘    └──────┬───────┘          │
 │         │                   │                  │
 │         └─────────┬─────────┘                  │
 │                   │                            │
 │         ┌─────────┴─────────┐                  │
 │         │  Time Slave Daemon │                  │
 │         │  (各サーバで稼働)   │                  │
 │         └─────────┬─────────┘                  │
 │                   │                            │
 │         TT.now() → [earliest, latest]          │
 │         不確実性区間 ε: 通常 1〜7 ms            │
 └────────────────────────────────────────────────┘

 GPSと原子時計を併用する理由:
 ・GPSは高精度だが、アンテナ障害やジャミングに弱い
 ・原子時計はGPS非依存だが、長期的にドリフトする
 ・異なる障害モードを持つ二つのソースを組み合わせることで
   信頼性を高める
```

GPSと原子時計は異なる障害モードを持つ。GPSはアンテナの障害やジャミング、信号妨害に弱い。原子時計はGPSに依存しないが、長期間にわたるとドリフト（時刻のずれ）が蓄積する。この二つを組み合わせることで、どちらか一方が障害を起こしても時刻の精度を維持できる。

各サーバ上ではタイムスレーブデーモンが稼働し、定期的にタイムマスターから時刻を取得して自身の時計を校正する。この仕組みにより、Googleは不確実性区間（ε）を通常1〜7ミリ秒、多くの場合6ミリ秒未満に維持している。

### Commit Wait——不確実性区間を「待つ」

TrueTimeの真価は、Spannerのコミットプロトコルで発揮される。

トランザクションがコミットするとき、Spannerはコミットタイムスタンプを`TT.now().latest`（不確実性区間の最新端）に設定する。そして、`TT.after(commit_timestamp)`がtrueになるまで待つ。つまり、コミットタイムスタンプが「確実に過去」になるまで、コミットの完了をクライアントに通知しない。

```
Commit Wait プロトコル

 時刻 ──────────────────────────────────────→

 トランザクション T1:
 ┌──────────┐
 │ 処理実行  │
 └────┬─────┘
      │
      ▼
 コミットタイムスタンプ = TT.now().latest
      │
      │← Commit Wait →│
      │  (εの経過を待つ) │
      │                │
      ▼                ▼
 コミット要求         コミット完了
                     (クライアントに通知)

 トランザクション T2（T1の完了後に開始）:
                        ┌──────────┐
                        │ 処理実行  │
                        └────┬─────┘
                             │
                             ▼
                     T2のタイムスタンプ > T1のタイムスタンプ
                     （TrueTimeの保証により確実）

 → T1のコミットが完了してからT2が開始した場合、
   T2のタイムスタンプは必ずT1より大きい
 → これが「外部一貫性」の保証
```

このCommit Waitが保証するのは「外部一貫性（External Consistency）」だ。トランザクションT1がコミットを完了した後にトランザクションT2がコミットを開始した場合、T2のコミットタイムスタンプは必ずT1より大きくなる。つまり、トランザクションのコミット順序が実時間の順序と一致する。

外部一貫性は、厳密な直列化可能性（Strict Serializability）と等価だ。線形化可能性（Linearizability）を複数の読み書き操作からなるトランザクションに拡張したものであり、分散データベースにおける最強の一貫性保証と言ってよい。

Commit Waitの所要時間は不確実性区間εに依存する。εが7ミリ秒なら、最大7ミリ秒の待ちが発生する。だがTrueTimeの精度が高いため、大半のケースで待ち時間は非常に短い。さらに、Commit WaitはPaxosプロポーザルの送信と並行して実行されるため、実質的なレイテンシへの影響は限定的だ。

---

## 4. Spannerのアーキテクチャ——Paxosとsplitの設計

### データの分割とレプリケーション

Spannerはデータベーステーブルをsplit（スプリット）と呼ばれる連続するキー範囲に分割する。各splitは独立したPaxosグループとして、複数のゾーン（データセンター）にまたがるレプリカに複製される。

```
Spannerのデータ分割とレプリケーション

 テーブル: Users
 ┌─────────────────────────────────────────┐
 │ key: A-F  │ key: G-M  │ key: N-S  │ key: T-Z  │
 │ (split 1)  │ (split 2)  │ (split 3)  │ (split 4)  │
 └─────────────────────────────────────────┘

 各splitは独立したPaxosグループ

 Split 1 のPaxosグループ:
 ┌───────────────────────────────────────────────┐
 │                                               │
 │  Zone A          Zone B          Zone C       │
 │  ┌─────────┐   ┌─────────┐   ┌─────────┐    │
 │  │ Replica  │   │ Replica  │   │ Replica  │    │
 │  │ (Leader) │   │(Follower)│   │(Follower)│    │
 │  └─────────┘   └─────────┘   └─────────┘    │
 │       │              │              │         │
 │       └──── Paxos合意（過半数で決定）────┘     │
 │                                               │
 │  ・書き込み: Leaderが提案 → 過半数の同意で確定  │
 │  ・読み取り: Leaderまたは十分新しいFollowerから  │
 │  ・Leader障害: 残りのレプリカが新Leaderを選出    │
 └───────────────────────────────────────────────┘
```

Paxosは1998年にLeslie Lamportが発表した分散合意アルゴリズムだ。ギリシャのパクソス島の架空の議会をメタファーに、分散環境での合意形成の手順を定式化した。Spannerでは各splitのレプリカ群がPaxosグループを形成し、書き込みはPaxosの合意プロトコルに従う。投票レプリカの過半数が同意すれば、書き込みは確定する。

この設計により、一つのゾーン（データセンター）が完全に失われても、残りのゾーンのレプリカがサービスを継続できる。Leaderが失われた場合は、残りのレプリカから新たなLeaderが選出される。

### 分散トランザクション——二相コミットとPaxos

Spannerが真に革新的なのは、複数のPaxosグループにまたがるトランザクション——つまりクロスシャードのトランザクション——を強一貫性で実行できる点だ。

```
分散トランザクションの流れ

 トランザクション: 「AさんからBさんへ送金」
 Aさんのデータ → Split 1 (Paxos Group 1)
 Bさんのデータ → Split 3 (Paxos Group 3)

 ┌─────────────────────────────────────────────┐
 │  Phase 1: Prepare（準備）                    │
 │                                             │
 │  Coordinator                                │
 │  (Split 1 Leader)                           │
 │       │                                     │
 │       ├──→ Split 1: 「Aの残高を減らす準備OK？」│
 │       │    → Paxos合意 → Prepared            │
 │       │                                     │
 │       └──→ Split 3: 「Bの残高を増やす準備OK？」│
 │            → Paxos合意 → Prepared            │
 │                                             │
 │  Phase 2: Commit（確定）                     │
 │                                             │
 │  Coordinator                                │
 │       │                                     │
 │       │  コミットタイムスタンプ = TT.now().latest│
 │       │  ← Commit Wait (εの経過を待つ) →     │
 │       │                                     │
 │       ├──→ Split 1: Commit!                  │
 │       │    → Paxos合意 → Committed           │
 │       │                                     │
 │       └──→ Split 3: Commit!                  │
 │            → Paxos合意 → Committed           │
 │                                             │
 │  → クライアントに成功を通知                    │
 └─────────────────────────────────────────────┘
```

Spannerの分散トランザクションは二相コミットプロトコルに基づいている。第7回で触れた伝統的な二相コミットと同じ構造だが、決定的な違いがある。各フェーズでの決定がPaxosの合意によって複製されるため、コーディネータの単一障害点問題が解消されている。コーディネータのリーダーが障害を起こしても、同じPaxosグループの他のレプリカがトランザクションの状態を引き継げる。

そしてCommit Waitがここで効く。コミットタイムスタンプの割り当てとCommit Waitにより、すべての分散トランザクションにグローバルに一意で因果関係を保存する順序が付与される。これが、複数のPaxosグループをまたぐトランザクションであっても外部一貫性を保証する仕組みだ。

### SpannerとCAP定理——「超えた」のか

ここで、冒頭の問いに立ち返ろう。SpannerはCAP定理を「超えた」のか。

答えは「いいえ」だ。CAP定理の提唱者であるEric Brewer自身が、Google在籍中の2017年に「Spanner, TrueTime & The CAP Theorem」という文書を著し、この点を明確にしている。

SpannerはCAP定理の分類では技術的にCPシステムだ。ネットワーク分断が発生した場合、Paxosの過半数が通信不能になれば、そのsplitへの書き込みは不可能になる。一貫性を守るために可用性を犠牲にする、というCAP定理の枠組みの中にいる。

だが、Brewerはこうも述べている。Googleの内部ネットワークの品質は極めて高く、ネットワーク分断は非常に稀だと。SpannerはCAP定理を超えたのではなく、ネットワーク分断の発生確率を極限まで下げることで、実用上CAPの制約を回避している。99.999%以上の可用性は、ネットワーク品質への投資の結果であり、アルゴリズムの魔法ではない。

Brewerの言葉を借りれば、Spannerは「effectively CA」——実効的にCAの性質を持つCPシステムだ。

この区別は重要だ。SpannerがCAP定理を「超えた」と信じてしまうと、分散システムの根本的なトレードオフを見誤る。Googleのネットワーク品質を前提としたアーキテクチャを、一般企業のインターネット接続で再現できると思ってはいけない。

---

## 5. Google Cloud Spanner——「Googleの秘密兵器」の民主化

### 社内からクラウドへ

SpannerはもともとGoogle社内でのみ使われていたシステムだ。Google広告のF1に始まり、Google Play、Google Photos、Google Financeなど、Googleの多くのサービスがSpanner上で稼働するようになった。

2017年2月、GoogleはCloud Spannerのパブリックベータを公開した。同年5月に一般提供（GA）を開始し、99.999%の可用性をSLAとして約束した。Google社内で磨かれた技術を、外部の開発者にも提供する。

当初のCloud Spannerは最小構成が1ノードで、価格は$0.90/ノード/時——月額約650ドルだった。小規模なプロジェクトにとっては手が出にくい価格であり、「Spannerは大企業向け」という印象を強くした。

2022年6月、Googleはグラニュラーインスタンスサイジングを一般提供し、最小100処理ユニット（1ノード = 1,000処理ユニット）から利用可能にした。月額約65ドルからSpannerを使える。この価格改定は、Spannerの敷居を大幅に下げた。

### NewSQLという概念

2011年、451 Research（現S&P Global Market Intelligence傘下）のアナリストMatthew Aslettは、こうしたデータベースの新しいカテゴリを「NewSQL」と名付けた。

NewSQLの定義は明確だ。SQLインターフェースを提供し、分散によるスケーラビリティを実現し、かつ強一貫性（ACIDトランザクション）を保証する。NoSQLが「SQLを捨ててスケーラビリティを得た」のに対し、NewSQLは「SQLを維持したまま分散でスケールする」ことを目指す。

Carnegie Mellon大学のAndy Pavloは2016年の「What's Really New with NewSQL?」で、NewSQLを三つのサブカテゴリに分類した。第一に、Spanner、CockroachDB、TiDBのようにゼロから構築された新アーキテクチャ。第二に、VitessやCitusのようなシャーディングミドルウェア。第三に、Amazon AuroraやGoogle Cloud SQLのようなクラウドDBaaS。

Spannerは第一のカテゴリの代表格であり、その論文はNewSQLの理論的基盤となった。第18回で取り上げるCockroachDBやTiDBは、Spannerの設計思想を継承しつつ、OSSとして実現したものだ。

なお、近年はNewSQLという用語より「Distributed SQL」が主流になりつつある。Matt Aslett自身もこの傾向を認識している。名称は変わっても、「SQLインターフェース + 分散スケーラビリティ + 強一貫性」という目標は変わらない。

### Spannerの「コスト」

Spannerの技術的な優位性は明らかだが、コストの現実も直視する必要がある。

Spannerの分散トランザクションは、単一ノードのRDBに比べてレイテンシが大きい。Paxosの合意には複数ゾーン間の通信が必要であり、さらにCommit Waitの時間が加わる。単一リージョン構成でも、書き込みレイテンシは数ミリ秒〜十数ミリ秒だ。マルチリージョン構成ではさらに大きくなる。

この数ミリ秒が問題にならないアプリケーションもあれば、致命的なアプリケーションもある。レイテンシに極めて敏感な高頻度取引システムには向かない。一方、グローバルに展開するeコマースやSaaSプラットフォームには適している。

また、Cloud Spannerの運用コストは、同等のワークロードをPostgreSQLやMySQLで処理する場合と比較して高い。グローバルな分散と強一貫性が本当に必要かどうかを、コストとのトレードオフとして検討すべきだ。多くのアプリケーションにとって、単一リージョンのPostgreSQLで十分かもしれない。

2025年、SpannerはACM SIGMOD Systems Awardを受賞した。論文発表から13年。Spannerの設計思想は、CockroachDB、TiDB、YugabyteDBといったOSSのNewSQLデータベースに継承され、分散データベースの世界に不可逆的な変化をもたらした。

---

## 6. ハンズオン: Cloud Spannerエミュレータで分散トランザクションを体験する

今回のハンズオンでは、Cloud Spannerエミュレータを使って分散トランザクションの動作を体験する。エミュレータはローカルで動作するインメモリのSpanner互換環境であり、Googleのクラウドアカウントは不要だ。

### 演習概要

1. Cloud SpannerエミュレータをDockerで起動する
2. スキーマを作成し、データを投入する
3. 強一貫性の分散トランザクション（送金処理）を実行する
4. 読み取り専用トランザクションとスナップショット読み取りの違いを体験する

### 環境構築

```bash
# handson/database-history/17-google-spanner/setup.sh を実行
bash setup.sh
```

### 演習1: スキーマ作成とデータ投入

エミュレータが起動したら、gcloud CLIまたはPythonクライアントを使ってデータベースを操作する。setup.shが自動的にインスタンス、データベース、テーブルを作成し、初期データを投入する。

```sql
-- Spannerのテーブル定義（DDL）
-- 注: SpannerはPostgreSQLやMySQLとは異なるDDL構文を持つ

CREATE TABLE Accounts (
  AccountId   INT64 NOT NULL,
  Owner       STRING(100) NOT NULL,
  Balance     INT64 NOT NULL,
  UpdatedAt   TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true),
) PRIMARY KEY (AccountId);

CREATE TABLE TransferLog (
  TransferId  STRING(36) NOT NULL,
  FromAccount INT64 NOT NULL,
  ToAccount   INT64 NOT NULL,
  Amount      INT64 NOT NULL,
  CreatedAt   TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true),
) PRIMARY KEY (TransferId);
```

Spannerの主キーがテーブル定義の最後に`PRIMARY KEY (AccountId)`として指定される点に注目してほしい。RDBの`PRIMARY KEY`制約と同じ概念だが、構文が異なる。`OPTIONS (allow_commit_timestamp=true)`はSpanner固有の機能で、コミットタイムスタンプを自動的にカラムに格納できる。

### 演習2: 分散トランザクション——送金処理

```python
# transfer.py -- Spannerの分散トランザクションで送金を実行する

from google.cloud import spanner

def transfer(instance_id, database_id, from_account, to_account, amount):
    """送金処理を分散トランザクションで実行する"""
    client = spanner.Client()
    instance = client.instance(instance_id)
    database = instance.database(database_id)

    def transfer_funds(transaction):
        # 送金元の残高を確認
        results = transaction.read(
            table="Accounts",
            columns=["Balance"],
            keyset=spanner.KeySet(keys=[[from_account]]),
        )
        from_balance = list(results)[0][0]

        if from_balance < amount:
            raise ValueError(
                f"Insufficient funds: {from_balance} < {amount}"
            )

        # 送金先の残高を確認
        results = transaction.read(
            table="Accounts",
            columns=["Balance"],
            keyset=spanner.KeySet(keys=[[to_account]]),
        )
        to_balance = list(results)[0][0]

        # 両方の残高を更新（アトミックに実行される）
        transaction.update(
            table="Accounts",
            columns=["AccountId", "Balance", "UpdatedAt"],
            values=[
                [from_account, from_balance - amount,
                 spanner.COMMIT_TIMESTAMP],
                [to_account, to_balance + amount,
                 spanner.COMMIT_TIMESTAMP],
            ],
        )

        # 送金ログを記録
        import uuid
        transaction.insert(
            table="TransferLog",
            columns=[
                "TransferId", "FromAccount", "ToAccount",
                "Amount", "CreatedAt",
            ],
            values=[[
                str(uuid.uuid4()), from_account, to_account,
                amount, spanner.COMMIT_TIMESTAMP,
            ]],
        )

    database.run_in_transaction(transfer_funds)
```

`database.run_in_transaction()`がSpannerの分散トランザクションを実行する。この関数は以下を自動的に処理する。

- トランザクションの開始と二相コミット
- 競合が発生した場合の自動リトライ
- TrueTimeに基づくコミットタイムスタンプの割り当て
- 外部一貫性の保証

`from_account`と`to_account`が異なるsplitに属する場合でも、トランザクションの原子性と一貫性は保証される。送金元の残高減少と送金先の残高増加は、すべてのノードから見て不可分の操作として実行される。

### 演習3: 読み取り専用トランザクションとスナップショット読み取り

```python
# read_modes.py -- Spannerの読み取りモードの違いを体験する

from google.cloud import spanner
import datetime

def demonstrate_read_modes(instance_id, database_id):
    """Spannerの3つの読み取りモードを比較する"""
    client = spanner.Client()
    instance = client.instance(instance_id)
    database = instance.database(database_id)

    # 1. 強い読み取り（Strong Read）
    # 最新のデータを読む。Paxosリーダーに問い合わせる
    with database.snapshot(multi_use=True) as snapshot:
        results = snapshot.execute_sql(
            "SELECT AccountId, Owner, Balance FROM Accounts"
        )
        print("=== Strong Read (latest data) ===")
        for row in results:
            print(f"  Account {row[0]}: {row[1]}, Balance={row[2]}")

    # 2. ステイル読み取り（Stale Read）
    # 指定した時刻以前のスナップショットを読む
    # リーダーに問い合わせる必要がなく、最寄りのレプリカから読める
    staleness = datetime.timedelta(seconds=15)
    with database.snapshot(exact_staleness=staleness) as snapshot:
        results = snapshot.execute_sql(
            "SELECT AccountId, Owner, Balance FROM Accounts"
        )
        print("=== Stale Read (15 seconds ago) ===")
        for row in results:
            print(f"  Account {row[0]}: {row[1]}, Balance={row[2]}")

    # 3. 読み取り専用トランザクション
    # 複数のクエリを同一スナップショットで実行する
    with database.snapshot(multi_use=True) as snapshot:
        results1 = snapshot.execute_sql(
            "SELECT SUM(Balance) FROM Accounts"
        )
        total = list(results1)[0][0]

        results2 = snapshot.execute_sql(
            "SELECT AccountId, Balance FROM Accounts"
        )
        individual_total = sum(row[1] for row in results2)

        print("=== Read-Only Transaction ===")
        print(f"  SUM(Balance): {total}")
        print(f"  Individual total: {individual_total}")
        print(f"  Consistent: {total == individual_total}")
```

ステイル読み取りはSpannerの重要な機能だ。15秒前のスナップショットで十分なクエリ（ダッシュボード表示など）であれば、Paxosリーダーに問い合わせることなく最寄りのレプリカから読み取れる。これにより読み取りレイテンシを大幅に削減できる。一方、強い読み取り（Strong Read）は最新データを保証するが、リーダーとの通信が必要なため、レイテンシが大きくなる。

### 後片付け

```bash
docker rm -f db-history-ep17-spanner 2>/dev/null || true
```

---

## 7. 魔法ではなく、工学である

第17回を振り返ろう。

**Google Spannerは、シャーディングされたMySQLの限界から生まれた。** Google広告チームが2年以上を費やしたリシャーディングの苦痛が、「二度とリシャーディングしたくない」という動機でSpanner開発を推進した。

**TrueTime APIは、時刻の不確実性を隠蔽するのではなく明示的に表現する、という発想の転換だった。** 原子時計とGPSのハイブリッドにより不確実性区間を1〜7ミリ秒に抑え、Commit Waitによって外部一貫性——すべてのトランザクションのコミット順序が実時間の順序と一致すること——を保証した。

**SpannerはCAP定理を「超えた」のではなく、工学的に回避した。** 技術的にはCPシステムであり、ネットワーク分断時には可用性を犠牲にする。だがGoogleのネットワーク品質がネットワーク分断を極めて稀にすることで、99.999%の可用性を実現している。

**NewSQLという概念は2011年にMatthew Aslettが命名し、Spannerはその代表格となった。** SQLインターフェース + 分散スケーラビリティ + 強一貫性。NoSQLが捨てたものを取り戻しつつ、RDBの限界を超える。

**2025年のACM SIGMOD Systems Award受賞は、Spannerが分散データベースの世界に与えた不可逆的な影響の証だ。**

冒頭の問いに戻ろう。「CAP定理を『超えた』と言われるデータベースは、本当にCAPを超えたのか？」

超えてはいない。だが「超える必要はない」ことを示した。CAP定理は物理法則のようなものだ。物理法則を超えることはできないが、その制約の中で工学的な解を見出すことはできる。Spannerが示したのは、「分散システムのトレードオフは不変だが、トレードオフの影響を最小化する工学は存在する」ということだ。

だがSpannerの工学には、Googleのインフラストラクチャという前提がある。原子時計を各データセンターに配置し、専用ネットワークでゾーン間を接続する。それは一般の企業が再現できる環境ではない。

では、Googleのインフラなしに、Spannerの思想を実現できるのだろうか。次回「CockroachDB, TiDB——OSSで挑むNewSQL」では、原子時計なしにSpannerの設計思想を継承したOSSの挑戦を取り上げる。Raftアルゴリズム、PostgreSQL/MySQL互換、そして「誰でも使えるNewSQL」の現実と理想を語る。

---

### 参考文献

- Corbett, J.C. et al., "Spanner: Google's Globally-Distributed Database", OSDI 2012. <https://www.usenix.org/conference/osdi12/technical-sessions/presentation/corbett>
- Shute, J. et al., "F1: A Distributed SQL Database That Scales", VLDB 2013. <https://dl.acm.org/doi/10.14778/2536222.2536232>
- Brewer, E., "Spanner, TrueTime & The CAP Theorem", 2017. <https://research.google.com/pubs/archive/45855.pdf>
- Google Cloud, "Spanner: TrueTime and external consistency". <https://docs.cloud.google.com/spanner/docs/true-time-external-consistency>
- Google Cloud, "Strict Serializability and External Consistency in Spanner". <https://cloud.google.com/blog/products/databases/strict-serializability-and-external-consistency-in-spanner>
- Google Cloud, "Reflecting on Spanner paper's SIGOPS Hall of Fame Award". <https://cloud.google.com/blog/products/databases/reflecting-on-spanner-papers-sigops-hall-of-fame-award>
- Lamport, L., "The Part-Time Parliament", ACM Transactions on Computer Systems, 1998. <https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf>
- Pavlo, A. et al., "What's Really New with NewSQL?", SIGMOD Record, 2016. <https://db.cs.cmu.edu/papers/2016/pavlo-newsql-sigmodrec2016.pdf>
- Google Cloud, "Spanner wins the 2025 ACM SIGMOD Systems Award". <https://cloud.google.com/blog/products/databases/spanner-wins-the-2025-acm-sigmod-systems-award>
- Google Cloud, "Replication". <https://docs.cloud.google.com/spanner/docs/replication>

---

**次回予告：** 第18回「CockroachDB, TiDB——OSSで挑むNewSQL」では、Spannerの思想をOSSとして実現する挑戦を追う。元Google Spannerチームが開発したCockroachDB、中国発のTiDB、そしてYugabyteDB。原子時計なしにどう外部一貫性に近づくのか。PostgreSQL互換・MySQL互換の意義とは。Raftアルゴリズムによる合意、レイテンシの現実、そして「誰でも使えるNewSQL」の光と影を語る。
