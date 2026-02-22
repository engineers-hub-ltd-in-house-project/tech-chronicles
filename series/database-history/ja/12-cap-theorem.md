# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第12回：CAP定理——分散システムの不可能三角形

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 分散データベースにおける根本的な制約——なぜ一貫性・可用性・分断耐性の三つを同時に満たすことが不可能なのか
- Eric Brewerが2000年のPODCで提唱したCAP予想の背景と、2002年にGilbertとLynchが行った形式証明の意義
- CAPの「Consistency」が意味する線形化可能性と、ACIDの「Consistency」との根本的な違い
- BASEモデル（Basically Available, Soft state, Eventually consistent）とACIDの対比
- CAP定理に対する批判と進化——Brewerの回顧、AbadiのPACELC理論、Kleppmannの批判
- ネットワーク分断が現実に起きたとき、データベースが何を犠牲にするのかを体験するハンズオン

---

## 1. MongoDBで書き込みが消えた日

2013年頃、私はあるプロジェクトでMongoDBを採用した。

理由は単純だった。前回の連載で述べたとおり、RDBのシャーディングは地獄だ。JOINが壊れる。トランザクションが保証されない。アプリケーションコードが膨れ上がる。その苦しみを知っていたからこそ、「スキーマレスで水平スケーリングが容易」というMongoDBの謳い文句は魅力的に映った。

レプリカセットを3ノードで構成し、本番運用を開始した。最初の数か月は順調だった。書き込み性能は良好で、レプリケーションも安定していた。

異変が起きたのは、データセンターのネットワーク障害がきっかけだった。

プライマリノードが他の2台と通信できなくなった。MongoDBのレプリカセットでは、プライマリが過半数のノードと通信を維持できなくなると、そのプライマリはステップダウンし、セカンダリに降格する。残りの2台が新しいプライマリを選出する。ここまではレプリカセットの設計どおりだ。

問題は、旧プライマリがステップダウンするまでの短い時間に書き込まれたデータだった。ネットワーク分断が発生してからプライマリがステップダウンするまでの数秒間、アプリケーションは旧プライマリに書き込み続けていた。その書き込みは新プライマリには伝わっていない。ネットワークが回復し、旧プライマリが新プライマリに追いつこうとしたとき、レプリケートされていなかった書き込みは「ロールバック」された。

データが消えた。

正確には、ロールバックされたデータはファイルに書き出されるため、手動で復旧は可能だ。だが、アプリケーションからは「書き込んだはずのデータが存在しない」状態になった。ユーザーには「さっき登録したデータが消えている」と映る。

当時の私はwrite concern（書き込み確認レベル）を適切に設定していなかった。デフォルトのwrite concern `{w: 1}` では、プライマリへの書き込み完了のみを確認し、セカンダリへのレプリケーションは待たない。`{w: "majority"}` に設定すれば、過半数のノードへの書き込みを確認してからクライアントに応答するため、ロールバックのリスクは大幅に減る。だが、その分レイテンシは増加する。

ここに、分散データベースの根本的なトレードオフがある。

「すべての書き込みを確実に保持したい」と「すべてのリクエストに高速に応答したい」は、ネットワーク分断が存在する世界では両立しない。この不可能性を、2000年にEric Brewerが一つの予想として定式化した。

あなたが今使っている分散データベースは、ネットワーク分断が起きたとき何を犠牲にするか——答えられるだろうか。

---

## 2. CAP定理の誕生——Brewerの予想からGilbert-Lynchの証明へ

### Eric Brewerという人物

CAP定理を理解するには、まずそれを提唱した人物の背景を知る必要がある。

Eric Allen BrewerはUC Berkeley（カリフォルニア大学バークレー校）のコンピュータサイエンス教授であり、同時に大規模分散システムの実務経験を持つ稀有な研究者だ。1996年、大学院生とともにInktomi Corporationを共同創業した。InktomiはクラスタベースのWebサーチエンジンを構築し、当時のインターネット検索の基盤技術を開発した企業だ。Googleが登場する前の話である。

BrewerのCAP予想は、学術的な思考実験から生まれたものではない。Inktomiで大規模分散システムを運用する中で、一貫性と可用性のトレードオフを日常的に経験していた実務感覚が、その根底にある。

### PODC 2000 基調講演

2000年7月、オレゴン州ポートランドで開催されたACM PODC（Symposium on Principles of Distributed Computing）において、Brewerは基調講演「Towards Robust Distributed Systems」を行った。

この講演でBrewerが提唱したのは、分散システムに関する一つの予想だった。

> 分散システムにおいて、以下の三つの性質を同時にすべて満たすことはできない。
>
> - **Consistency（一貫性）**: すべてのノードが同じ時点で同じデータを返す
> - **Availability（可用性）**: 障害が発生していないノードへのすべてのリクエストが応答を返す
> - **Partition Tolerance（分断耐性）**: ネットワークの分断が発生しても、システムが動作を継続する

三つの性質のうち、同時に満たせるのは最大二つ——これがBrewerの予想、後の「CAP定理」だ。

```
CAP定理の三角形

         Consistency
        （一貫性）
           /\
          /  \
         / CP \
        /______\
       /\      /\
      /  \ CA /  \
     / AP \  /    \
    /______\/______\
Availability    Partition
（可用性）     Tolerance
              （分断耐性）

三つの頂点のうち、同時に達成できるのは最大二つ。
ネットワーク分断は現実世界で避けられないため、
実質的にはCPかAPの二択になる。
```

重要なのは、Brewerがこれを「定理」ではなく「予想（conjecture）」として提示したことだ。形式的な証明はなく、Inktomiでの実務経験と分散システム研究から導かれた直感的な命題だった。

### Gilbert-Lynchによる形式証明（2002年）

2002年、MITのSeth GilbertとNancy Lynchが論文「Brewer's Conjecture and the Feasibility of Consistent, Available, Partition-Tolerant Web Services」をACM SIGACT News（Vol. 33, No. 2）に発表し、Brewerの予想を非同期ネットワークモデルにおいて形式的に証明した。予想は「定理」に昇格した。

Gilbert-Lynchの証明で重要なのは、各要素の厳密な定義だ。

**Consistency（一貫性）** は、線形化可能性（linearizability）として定義された。すべての読み取り操作が、最も新しい書き込みの結果を返す。システム全体が一つのコピーであるかのように振る舞う。ここで注意が必要なのは、CAPにおけるConsistencyとACIDにおけるConsistencyは根本的に異なる概念だということだ。ACIDのConsistencyはデータベース制約（一意制約、外部キー制約など）の維持を意味する。CAPのConsistencyは「全ノードが同じデータを返す」ことを意味する。

**Availability（可用性）** は、障害が発生していないすべてのノードが、すべてのリクエストに対して最終的に応答を返すことと定義された。ただし、応答の速度には制限がない。理論上は無限に遅い応答も「利用可能」に含まれる。

**Partition Tolerance（分断耐性）** は、ネットワーク上の任意のメッセージが消失してもシステムが動作を継続することと定義された。

この証明の核心は直感的に理解できる。ネットワーク分断が発生し、ノードAとノードBが通信できない状態を考える。クライアントがノードAに書き込みを行い、別のクライアントがノードBから読み取りを行う場合、二つの選択肢しかない。

```
ネットワーク分断時のジレンマ

Client 1              Client 2
   │                     │
   │── WRITE x=5 ──→ Node A    ╳    Node B ←── READ x ──│
   │                     │   (分断)   │                  │
   │                     │           │                  │
選択肢1: 一貫性を優先（CP）
   Node Bは応答を拒否する（分断が解消するまで待つ）
   → 一貫性は保たれるが、可用性が失われる

選択肢2: 可用性を優先（AP）
   Node Bは古い値（x=旧値）を返す
   → 可用性は保たれるが、一貫性が失われる
```

ノードBが一貫性を保つためにはノードAからの最新データが必要だが、ネットワーク分断により通信できない。ノードBが応答を返さなければ可用性が犠牲になる。古い値を返せば一貫性が犠牲になる。両方を同時に満たすことはできない。

### なぜ「CA」は実質的に存在しないのか

CAP定理は「3つから2つを選ぶ」と表現されることが多い。論理的にはCA、CP、APの3つの組み合わせが考えられる。しかし、実際のシステム設計においてCA——つまり「一貫性と可用性はあるが分断耐性がない」——は実質的に成立しない。

理由は単純だ。ネットワーク分断は避けられない。物理的なケーブルの損傷、スイッチの故障、ルーティングの異常、クラウドプロバイダのAZ（Availability Zone）間の通信障害——分散システムにおいてネットワーク分断は「起きるかどうか」ではなく「いつ起きるか」の問題だ。

Google内部のネットワークですら分断は発生する。Amazonのデータセンター間でも発生する。Peter Bailisらの2014年の調査では、データセンター内のネットワーク分断が年間数十回発生することが報告されている。

つまり、Partition Tolerance（分断耐性）は「オプション」ではなく「前提」だ。ネットワーク分断が起きたとき、システムは動作を継続しなければならない。その上で、一貫性（CP）を優先するか、可用性（AP）を優先するかを選ぶ——これがCAP定理の実質的な意味である。

---

## 3. CAPの設計判断——CP vs AP、そしてBASE

### CP設計——一貫性を優先する

CP設計は、ネットワーク分断が発生した場合、一貫性を維持するために一部のノードの可用性を犠牲にする。過半数のノードと通信できないノードはリクエストを拒否する。

代表的なCP設計のシステムには以下がある。

**Apache ZooKeeper** は分散コーディネーションサービスであり、構成管理やリーダー選出に使用される。ZooKeeperはZAB（ZooKeeper Atomic Broadcast）プロトコルを用いて、全ノードが同一のデータを持つことを保証する。ネットワーク分断が発生し、ノードが過半数のクォーラムと通信できなくなった場合、そのノードはクライアントからの読み取り・書き込みリクエストを拒否する。

**Apache HBase** はGoogle Bigtable論文にインスパイアされたカラムファミリ型データストアだ。HBaseはマスタ・スレーブアーキテクチャを採用し、一貫性を優先する設計となっている。リージョンサーバが過半数と通信できなくなった場合、書き込みが拒否される可能性がある。

CP設計の利点は明確だ。クライアントは常に最新のデータを読めるか、エラーを受け取るかのどちらかだ。「古いデータを返される」というリスクがない。金融系システムのように「間違ったデータを返すくらいなら、応答しない方がまし」という要件には、CP設計が適する。

### AP設計——可用性を優先する

AP設計は、ネットワーク分断が発生しても、すべてのノードが応答を返し続ける。ただし、各ノードが返すデータは最新でない可能性がある。

**Apache Cassandra** はAmazon Dynamo論文とGoogle Bigtable論文のハイブリッドとして2008年にFacebookで開発された。Cassandraはマスタレスアーキテクチャを採用し、すべてのノードが対等だ。ネットワーク分断が発生しても、各パーティション内のノードは独立して読み書きを受け付ける。分断が解消された後、ヒントハンドオフ（hinted handoff）やリードリペア（read repair）により、データの整合性が「結果的に」回復する。

**Amazon DynamoDB** もAP寄りの設計だ。デフォルトでは結果整合性のある読み取りを提供し、強い整合性のある読み取りはオプションとして選択可能だ。

AP設計の利点は、高い可用性とレイテンシの低さだ。全ノードが常に応答を返すため、ユーザー体験が安定する。ECサイトのショッピングカートのように「データが数秒古くても、応答しないよりはるかにまし」という要件には、AP設計が適する。実際、AmazonのDynamo論文はショッピングカートのユースケースから生まれた。

### BASEモデル——ACIDの対概念

CP/APの設計判断と密接に関連する概念が、BASEモデルだ。

2008年、eBayのTechnical FellowであるDan PritchettがACM Queue誌に「BASE: An Acid Alternative」を発表した。BASEは以下の頭文字を取ったものだ。

- **Basically Available（基本的に利用可能）**: システムは障害があっても基本的に応答を返す
- **Soft state（柔軟な状態）**: システムの状態は時間とともに変化しうる。外部入力がなくても、結果整合性のプロセスにより状態が変わる
- **Eventually consistent（結果整合性）**: 新たな更新がなければ、最終的に全ノードが同じ値を返す

BASEはACIDの対概念として提案された。ACIDが「トランザクションの完全な一貫性」を保証するのに対し、BASEは「一貫性を緩め、可用性とスケーラビリティを得る」モデルだ。

```
ACID vs BASE

         ACID                            BASE
┌─────────────────────┐      ┌─────────────────────┐
│ Atomicity           │      │ Basically Available  │
│  - 全か無か          │      │  - 基本的に利用可能   │
│ Consistency         │      │ Soft state           │
│  - 制約の維持        │      │  - 柔軟な状態         │
│ Isolation           │      │ Eventually           │
│  - トランザクション分離│      │   consistent         │
│ Durability          │      │  - 結果整合性         │
│  - 永続性            │      │                     │
└─────────────────────┘      └─────────────────────┘
   強い一貫性                    弱い一貫性
   低いスケーラビリティ           高いスケーラビリティ
   （単一ノードが前提）          （分散が前提）
```

ここで重要なのは、ACIDとBASEは二者択一ではないということだ。多くの実システムでは、データの種類や操作の性質に応じて、ACIDとBASEを使い分けている。ユーザーの残高更新はACID的に処理し、アクセスログの書き込みはBASE的に処理する——こうした混合モデルが現実のアーキテクチャだ。

### 結果整合性とその変種

AP設計を選んだ場合、一貫性のモデルは「結果整合性（eventual consistency）」になる。2008年、AmazonのCTO Werner VogelsはACM Queue誌に「Eventually Consistent」を発表し、結果整合性の概念とその変種を体系的に整理した。

結果整合性とは、「新たな更新がなければ、最終的にすべてのアクセスが最後に更新された値を返す」ことを保証するモデルだ。「最終的に」がいつなのかは保証されない。数ミリ秒かもしれないし、数分かもしれない。

Vogelsが整理した結果整合性の主な変種は以下のとおりだ。

**因果整合性（Causal Consistency）**: プロセスAがプロセスBに「データを更新した」と通知した場合、その後のBからのアクセスは更新後の値を返す。因果関係のない更新間の順序は保証しない。

**Read-Your-Writes整合性**: あるプロセスが書き込みを行った後、そのプロセス自身からの読み取りは常に書き込んだ値を返す。私がMongoDBで経験した問題——書き込み直後に読み取ると古い値が返る——はまさにRead-Your-Writes整合性の欠如だった。

**セッション整合性**: セッションのコンテキスト内でRead-Your-Writes整合性を保証する。多くのWebアプリケーションでは、この粒度の整合性で十分な場合が多い。

**モノトニック読み取り整合性（Monotonic Read Consistency）**: 一度新しい値を読み取ったプロセスは、その後に古い値を読み取ることはない。時間が「巻き戻る」ことがない。

これらの変種が重要なのは、「結果整合性」と一口に言っても、アプリケーションが必要とする整合性のレベルは様々だからだ。「結果的に一貫すればよい」のか、「自分の書き込みは即座に読めなければならない」のか——要件によって必要な整合性モデルは異なる。

---

## 4. CAP定理への批判と進化——12年後の再評価

### Brewerの回顧（2012年）

CAP定理はその明快さゆえに広く普及したが、同時に多くの誤解も生んだ。

2012年2月、Brewer自身がIEEE Computer誌に「CAP Twelve Years Later: How the 'Rules' Have Changed」を発表し、12年間の誤解を正した。

Brewerが指摘した最も重要な点は、「3つから2つを選ぶ」という図式が過度に単純化されたものだったということだ。

第一に、分断は常に発生しているわけではない。分散システムの大部分の時間は、ネットワークが正常に動作している。分断が発生していない間は、一貫性と可用性の両方を提供できる。CAPのトレードオフが強制されるのは、分断が実際に発生した瞬間だけだ。

第二に、一貫性と可用性は0か1かの二択ではない。データの種類やオペレーションの種類によって、一貫性のレベルを段階的に調整できる。同じシステム内でも、ある操作はCP的に、別の操作はAP的に処理するという設計が可能だ。

第三に、分断の検出と回復のメカニズムを設計に組み込むことで、分断発生時の影響を最小化できる。分断を「防ぐ」ことはできないが、分断を「管理する」ことはできる。

### AbadiのPACELC理論（2012年）

同じ2012年、Daniel AbadiがIEEE Computer誌に「Consistency Tradeoffs in Modern Distributed Database System Design: CAP is Only Part of the Story」を発表し、PACELC理論を提唱した。

PACELCは以下の構造を持つ。

> ネットワーク分断（**P**artition）が発生した場合、**A**vailability と **C**onsistency のどちらかを選択する。
> それ以外（**E**lse）の通常時は、**L**atency と **C**onsistency のどちらかを選択する。

CAP定理は「分断時のトレードオフ」のみを論じたが、Abadiは「分断が発生していない通常時にもトレードオフが存在する」と指摘した。ネットワークが正常に動作していても、複数ノード間でデータの一貫性を保とうとすれば、合意プロトコルの実行にレイテンシが発生する。レイテンシを最小化したければ、一貫性を緩める必要がある。

```
PACELC による分散データベースの分類

             分断時       通常時
           (P) A or C?   (E) L or C?
Cassandra:     PA           EL      ← 常に可用性/低レイテンシ優先
DynamoDB:      PA           EL      ← 常に可用性/低レイテンシ優先
HBase:         PC           EC      ← 常に一貫性優先
ZooKeeper:     PC           EC      ← 常に一貫性優先
MongoDB:       PA           EC      ← 分断時は可用性、通常時は一貫性
Spanner:       PC           EC      ← 一貫性優先（レイテンシはTrueTimeで対処）
```

PACELCのPA/EL組み合わせ（分断時も通常時も可用性/低レイテンシ優先）のCassandraと、PC/EC組み合わせ（分断時も通常時も一貫性優先）のHBaseは、一貫した設計思想を持つシステムだ。一方、PA/EC（分断時は可用性、通常時は一貫性）のMongoDBのような混合パターンも存在する。

### Kleppmannの批判（2015年）

2015年5月、Martin Kleppmann（後に『Designing Data-Intensive Applications』を著す）がブログ記事「Please stop calling databases CP or AP」を公開し、CAP定理の過度な単純化を鋭く批判した。同年9月には学術論文「A Critique of the CAP Theorem」も発表している。

Kleppmannの批判は多岐にわたるが、核心は以下の四点だ。

**定義が狭すぎる。** CAPにおけるConsistencyは線形化可能性（linearizability）のみを指すが、実際のシステムでは因果整合性、セッション整合性、スナップショット分離など、様々なレベルの一貫性がある。線形化可能性か結果整合性かの二択は、実務的には粗すぎる。

**モデルが限定的すぎる。** CAPの形式モデルは単一のread-writeレジスタ（単一のデータ項目に対する読み書き）を対象としており、複数のオブジェクトにまたがるトランザクションは考慮していない。現実のデータベースが提供する機能の大部分がモデルの外にある。

**障害モードが不十分。** CAPが考慮する障害はネットワーク分断のみだ。ノードのクラッシュ、ディスク障害、ソフトウェアバグ、リソース枯渇——現実の分散システムで発生する様々な障害がCAP定理の射程外にある。

**レイテンシを無視している。** CAPの可用性の定義では、応答時間の制約がない。理論上は10分後に応答しても「利用可能」だ。しかし実務的には、レイテンシは可用性と同じかそれ以上に重要だ。この欠陥はAbadiのPACELCが部分的に補ったが、CAPそのものの限界として認識すべきだ。

Kleppmannの結論は「データベースをCPやAPとラベル付けするのをやめよう」というものだった。代わりに、各システムが具体的にどのような一貫性保証を提供し、どのような障害シナリオに対してどう振る舞うかを、より精密に記述すべきだと主張した。

### Jepsenプロジェクト——理論を実証で検証する

CAP定理の議論が理論的な枠組みにとどまる中、2013年頃からKyle Kingsbury（ハンドル名: Aphyr）が「Call me maybe」シリーズとして、分散データベースの一貫性を実証的に検証し始めた。

Kingsburyが開発したJepsenフレームワークは、分散データベースのクラスタを構築し、ネットワーク分断やノードクラッシュなどのフォールトを注入しながら、データの一貫性が宣言どおりに保たれているかを自動的に検証する。

その結果は衝撃的だった。8年間で26のシステムから一貫性違反が発見された。失われたデータ、ダーティリード、ファントムリード——理論的には起きないとドキュメントに書かれている問題が、現実に発生していた。

MongoDBもJepsenの検証対象となった。Kingsburyの2015年の分析では、MongoDBのデフォルト設定でレプリカセットのフェイルオーバー時にデータが失われるケースが確認されている。私が体験した問題そのものだ。

Jepsenプロジェクトの意義は、CAP定理の理論的な「CP or AP」という分類を超えて、「実際のシステムが障害時にどう振る舞うか」を検証したことにある。マーケティング資料やドキュメントの主張と、実際の挙動が一致するとは限らない。

### 理論の限界を知った上で使う

CAP定理に対する批判を紹介したが、これはCAP定理が無価値だという意味ではない。

CAP定理の価値は、分散システムにおける根本的なトレードオフの存在を明示したことにある。ネットワーク分断が発生したとき、一貫性と可用性は両立しない——このシンプルな命題は、2000年以前の分散システム設計では必ずしも明確に認識されていなかった。「うまくやればすべてを手に入れられる」という楽観を打ち砕いたことに、CAP定理の歴史的意義がある。

同時に、CAP定理は「入り口」であって「出口」ではない。分散システムの設計判断を、「CP or AP」の二文字に還元することはできない。Kleppmannが指摘するように、各システムの具体的な一貫性保証、障害時の挙動、レイテンシ特性を精密に理解することが、実務では不可欠だ。

---

## 5. ハンズオン: 分断耐性と一貫性・可用性のトレードオフを体験する

今回のハンズオンでは、Dockerで3ノードのデータベースクラスタを構築し、意図的にネットワーク分断を発生させる。分断時にCP的な挙動とAP的な挙動がどう現れるかを体験する。

### 演習概要

1. PostgreSQLの同期レプリケーションでCP的な挙動を確認する——分断時に書き込みがブロックされることを体験する
2. PostgreSQLの非同期レプリケーションでAP的な挙動を確認する——分断時に書き込みは成功するが、レプリカのデータが古くなることを体験する
3. 分断解消後のデータ収束を観察する

### 環境構築

```bash
# handson/database-history/12-cap-theorem/setup.sh を実行
bash setup.sh
```

### 演習1: CP的挙動——同期レプリケーションとネットワーク分断

setup.shがプライマリ（primary）とスタンバイ（standby-sync）の2台のPostgreSQLコンテナを同期レプリケーション構成で起動している。

プライマリに接続してデータを書き込む。

```bash
docker exec -it db-history-ep12-primary psql -U postgres -d handson
```

```sql
-- 正常時の書き込み（同期レプリケーション: スタンバイへの書き込み完了を待つ）
INSERT INTO sensor_data (sensor_id, value, recorded_at)
VALUES ('sensor-001', 23.5, NOW());
-- → 正常に完了する（スタンバイへのレプリケーション完了を確認してから応答）

-- レプリケーション状態を確認
SELECT client_addr, sync_state, sent_lsn, flush_lsn
FROM pg_stat_replication;
```

スタンバイに接続してデータが同期されていることを確認する。

```bash
docker exec -it db-history-ep12-standby-sync psql -U postgres -d handson
```

```sql
SELECT * FROM sensor_data;
-- → プライマリと同じデータが表示される
```

ネットワーク分断を発生させる。

```bash
# スタンバイをネットワークから切断する
docker network disconnect db-history-ep12-net db-history-ep12-standby-sync
```

プライマリで書き込みを試みる。

```sql
-- ネットワーク分断中の書き込み（同期レプリケーション）
-- タイムアウトを5秒に設定してブロックを観察する
SET synchronous_commit = on;
SET statement_timeout = '5s';
INSERT INTO sensor_data (sensor_id, value, recorded_at)
VALUES ('sensor-002', 18.7, NOW());
-- → タイムアウトする！ スタンバイからのACKを待ち続けるため書き込みが完了しない
-- これがCP的挙動: 一貫性を保つために可用性（書き込み応答）を犠牲にする
```

ネットワークを復旧させる。

```bash
# スタンバイをネットワークに再接続
docker network connect db-history-ep12-net db-history-ep12-standby-sync
```

```sql
-- ネットワーク復旧後の書き込み
SET statement_timeout = '30s';
INSERT INTO sensor_data (sensor_id, value, recorded_at)
VALUES ('sensor-002', 18.7, NOW());
-- → 正常に完了する
```

### 演習2: AP的挙動——非同期レプリケーションとネットワーク分断

setup.shが非同期レプリケーション構成のプライマリ（primary-async）とスタンバイ（standby-async）も起動している。

プライマリに接続する。

```bash
docker exec -it db-history-ep12-primary-async psql -U postgres -d handson
```

```sql
-- 正常時の書き込み
INSERT INTO sensor_data (sensor_id, value, recorded_at)
VALUES ('sensor-101', 25.0, NOW());
```

非同期スタンバイを確認する。

```bash
docker exec -it db-history-ep12-standby-async psql -U postgres -d handson
```

```sql
SELECT * FROM sensor_data;
-- → データがレプリケートされている
```

ネットワーク分断を発生させる。

```bash
# 非同期スタンバイをネットワークから切断
docker network disconnect db-history-ep12-net db-history-ep12-standby-async
```

プライマリで書き込みを試みる。

```sql
-- ネットワーク分断中の書き込み（非同期レプリケーション）
INSERT INTO sensor_data (sensor_id, value, recorded_at)
VALUES ('sensor-102', 19.3, NOW());
-- → 即座に完了する！ スタンバイへのレプリケーションを待たない
-- これがAP的挙動: 可用性を維持するが、一貫性が失われる

INSERT INTO sensor_data (sensor_id, value, recorded_at)
VALUES ('sensor-103', 22.1, NOW());
-- → これも即座に完了する
```

スタンバイの状態を確認する（分断中）。

```bash
docker exec -it db-history-ep12-standby-async psql -U postgres -d handson
```

```sql
SELECT * FROM sensor_data;
-- → sensor-102, sensor-103 は表示されない！
-- プライマリとスタンバイで異なるデータが見える = 一貫性の喪失
```

### 演習3: 分断解消後のデータ収束

```bash
# ネットワークを復旧
docker network connect db-history-ep12-net db-history-ep12-standby-async
```

```bash
# 数秒待ってからスタンバイを確認
sleep 3
docker exec -it db-history-ep12-standby-async psql -U postgres -d handson \
    -c "SELECT * FROM sensor_data ORDER BY id;"
```

```sql
-- → sensor-102, sensor-103 が表示される
-- 結果整合性: 分断解消後、最終的にデータが収束する
```

### 後片付け

```bash
docker rm -f db-history-ep12-primary db-history-ep12-standby-sync \
    db-history-ep12-primary-async db-history-ep12-standby-async
docker network rm db-history-ep12-net 2>/dev/null || true
```

---

## 6. 不可能性を知ることの価値

第12回を振り返ろう。

**CAP定理は、分散システムにおける根本的な制約を明示する。** 一貫性（Consistency）、可用性（Availability）、分断耐性（Partition Tolerance）の三つを同時に満たす分散システムは存在しない。Eric Brewerが2000年にPODCで予想として提唱し、2002年にGilbertとLynchが形式的に証明した。

**ネットワーク分断は避けられないため、実質的にはCPかAPの二択になる。** CP設計（ZooKeeper、HBase）はネットワーク分断時に可用性を犠牲にし、AP設計（Cassandra、DynamoDB）は一貫性を犠牲にする。どちらが「正しい」かは、アプリケーションの要件が決める。

**BASEモデルはACIDの対概念として、結果整合性に基づく設計思想を体系化した。** Dan Pritchettが2008年に発表し、Werner Vogelsが結果整合性の変種（因果整合性、Read-Your-Writes整合性、セッション整合性等）を整理した。

**CAP定理は出発点であり、最終到達点ではない。** Brewer自身が2012年に「3つから2つを選ぶ」という図式の単純化を認めた。AbadiのPACELC理論（2012年）は通常時のレイテンシ/一貫性トレードオフを補った。Kleppmannは2015年に「データベースをCPやAPとラベル付けするのをやめよう」と呼びかけ、より精密な一貫性保証の記述を求めた。

**Jepsenプロジェクトは、理論と実装のギャップを実証的に検証した。** Kyle Kingsburyの検証により、8年間で26のシステムで一貫性違反が発見された。ドキュメントの主張と実際の挙動は一致するとは限らない。

冒頭の問いに戻ろう。「なぜ『完璧な分散データベース』は存在しないのか？」

それは、ネットワークが物理的な存在である以上、完全に信頼することができないからだ。光速には限界があり、ケーブルは切れ、スイッチは故障する。その現実を受け入れた上で、「何を犠牲にするか」を明示的に選ぶことが、分散データベース設計の核心だ。

CAP定理の最大の教訓は、「不可能性を知ること」の価値にある。何が達成可能で何が不可能かを知らずに設計を始めれば、「完璧なシステム」を追い求めて終わりのない試行錯誤に陥る。不可能性を理解した上で、アプリケーションの要件に基づいてトレードオフを意識的に選択する——それが、障害時の対応力を根本的に変える。

次回は「Memcached, Redis——キャッシュ層という発明」を取り上げる。RDBのスケーリング問題に対して、多くのエンジニアが「データベースの前にもう一つのデータストアを置く」という解法を選んだ。MySQLの読み取り負荷をmemcachedで逃がした日。キャッシュの恩恵を実感すると同時に、キャッシュ不整合地獄が始まった話。Redisが「キャッシュ」を超えて「データ構造サーバ」としての地位を確立した背景を辿る。

---

### 参考文献

- Eric A. Brewer, "Towards Robust Distributed Systems", PODC 2000 Keynote. <https://people.eecs.berkeley.edu/~brewer/cs262b-2004/PODC-keynote.pdf>
- Seth Gilbert, Nancy Lynch, "Brewer's Conjecture and the Feasibility of Consistent, Available, Partition-Tolerant Web Services", ACM SIGACT News, Vol. 33, No. 2, June 2002. <https://dl.acm.org/doi/10.1145/564585.564601>
- Eric A. Brewer, "CAP Twelve Years Later: How the 'Rules' Have Changed", IEEE Computer, Vol. 45, February 2012. <https://ieeexplore.ieee.org/document/6133253/>
- Daniel J. Abadi, "Consistency Tradeoffs in Modern Distributed Database System Design: CAP is Only Part of the Story", IEEE Computer, Vol. 45, No. 2, February 2012. <https://cs.umd.edu/~abadi/papers/abadi-pacelc.pdf>
- Martin Kleppmann, "Please stop calling databases CP or AP", May 11, 2015. <https://martin.kleppmann.com/2015/05/11/please-stop-calling-databases-cp-or-ap.html>
- Martin Kleppmann, "A Critique of the CAP Theorem", September 2015. <https://www.cl.cam.ac.uk/research/dtg/archived/files/publications/public/mk428/cap-critique.pdf>
- Dan Pritchett, "BASE: An Acid Alternative", ACM Queue, Vol. 6, No. 3, 2008. <https://queue.acm.org/detail.cfm?id=1394128>
- Werner Vogels, "Eventually Consistent", ACM Queue, Vol. 6, No. 6, October 2008. <https://queue.acm.org/detail.cfm?id=1466448>
- Kyle Kingsbury, "Jepsen: MongoDB", 2015. <https://aphyr.com/posts/284-jepsen-mongodb>
- Jepsen: Distributed Systems Safety Research. <https://jepsen.io/>

---

**次回予告：** 第13回「Memcached, Redis——キャッシュ層という発明」では、「データベースの前にもう一つのデータストアを置く」という発想がどこから生まれたかを辿る。Brad FitzpatrickがLiveJournalのために作ったmemcached（2003年）から、Salvatore Sanfilippoが「データ構造サーバ」として設計したRedis（2009年）まで。キャッシュ戦略のパターン（Cache Aside、Write Through、Write Behind）と、Thundering Herd、Cache Stampedeといったキャッシュの一貫性問題を解き明かす。
