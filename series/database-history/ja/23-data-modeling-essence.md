# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第23回：データモデリングの本質——正規化、非正規化、そしてその先

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Coddの正規化理論（1970-1972年）から第5正規形（1979年）まで、正規化の歴史的系譜
- Peter ChenのERモデル（1976年）が概念モデリングに与えた革命的影響
- Ralph Kimballのディメンショナルモデリング（1996年）とBill Inmonの3NF設計（1992年）の対立
- Eric EvansのDDD（2003年）がデータモデリングに持ち込んだ「境界」の概念
- Greg YoungのCQRS/イベントソーシングが覆したデータモデリングの前提
- マイクロサービス時代のデータオーナーシップと「Database per Service」パターン
- 同じビジネス要件に対する3つの設計アプローチ（正規化RDB、非正規化ドキュメント、イベントソーシング）の実践的比較

---

## 1. 24年分のデータモデリングと「正解のない世界」

私がデータモデリングという行為を初めて意識したのは、2000年代初頭のことだ。PHP + MySQLでWebシステムを構築していた時期、あるECサイトのデータベース設計を任された。

当時の私は、大学の教科書で学んだ正規化理論を信奉していた。テーブルは正規化すべきだ。冗長なデータは排除すべきだ。第3正規形を満たすことがデータベース設計の「正解」だ——そう信じて疑わなかった。

設計は美しかった。商品テーブル、カテゴリテーブル、注文テーブル、注文明細テーブル、顧客テーブル、住所テーブル——すべてが正規化され、外部キーで関連付けられていた。ERダイアグラムを印刷してチームに見せたとき、誰も異論を唱えなかった。

問題は、運用開始後に顕在化した。

商品一覧ページの表示に6つのテーブルをJOINする必要があった。注文履歴の表示にはさらに多くのJOINが必要だった。ページの読み込みに3秒以上かかる。MySQLの `EXPLAIN` を睨みながらインデックスを追加するが、JOINの数が多すぎて根本的な解決にならない。

上司に相談した。「テーブルを非正規化したらどうだ」と言われた。私は抵抗した。非正規化はデータの冗長性を生む。更新時の整合性維持が困難になる。教科書に書いてあった「正規化すべき理由」を並べ立てた。

上司は穏やかに言った。「教科書は、このサイトのアクセスパターンを知らない」。

結局、商品一覧用の非正規化テーブルを追加した。カテゴリ名、ブランド名、メインの商品画像URLを商品テーブルに冗長に持たせた。ページの表示速度は0.3秒に改善した。10倍の高速化だ。

あの日以来、私はデータモデリングに「正解」があるという幻想を捨てた。正規化は正しい。非正規化も正しい。問題は「何に対して」正しいかだ。

それから20年以上が経った。その間に、NoSQLブームでドキュメント指向の設計に翻弄され、MongoDBで「スキーマレスの自由」を謳って後で苦労し、DDDの境界づけられたコンテキストにデータの「所有権」という概念を学び、イベントソーシングで「状態ではなくイベントを保存する」という発想の転換に衝撃を受けた。CQRSで読み取りモデルと書き込みモデルを分離したとき、「データモデルは一つであるべきだ」という前提そのものが揺らいだ。

データモデリングの「正解」は存在するのか。24年間の結論を先に言おう。「正解はない。だが判断基準はある」。

この回では、正規化理論の誕生からイベントソーシングまで、データモデリングの思想的系譜を辿る。そしてその先に見える「判断基準」を、歴史の中から抽出したい。あなたが明日設計するデータモデルのために。

---

## 2. 正規化の系譜——Coddが遺した理論体系

### 正規化以前の世界

正規化理論を語る前に、なぜ正規化が必要だったのかを確認しておく。

第4回で詳しく語ったように、Edgar F. Coddが1970年に「A Relational Model of Data for Large Shared Data Banks」をCommunications of the ACM（Vol.13, pp.377-387）に発表したとき、データベースの世界は階層型モデルとネットワーク型モデルが支配していた。これらのモデルでは、データの物理的配置とアプリケーションのアクセスパスが密結合していた。

Coddのリレーショナルモデルは、データを「関係（リレーション）」——数学的にはn組の集合——として抽象化し、物理的な格納方法から切り離した。だがリレーショナルモデルだけでは、関係をどう設計すべきかという指針が不足していた。

同じ情報を異なる方法でテーブルに分割できるとき、どの分割が「よい」設計なのか。この問いに体系的に回答したのが、正規化理論である。

### 第1正規形から第3正規形へ（1970-1971年）

Coddの1970年論文では、第1正規形（1NF）のみが定義されていた。1NFの要件は単純だ。すべての属性がアトミック（不可分）な値を持つこと。つまり、一つのセルに複数の値を詰め込まないこと。

翌1971年、Coddは「Further Normalization of the Data Base Relational Model」を発表し、第2正規形（2NF）と第3正規形（3NF）を定義した。この論文のIBM研究報告は1971年8月31日付で、1972年にPrentice-Hall刊行の『Data Base Systems』に収録された。

Coddがこの論文で提示した目標は明確だ。「リレーションの集合を、より理解しやすく、操作しやすく、カジュアルなユーザーにとってより有用なものにすること」。そして「アプリケーションプログラムが、データベースの再構成に対して生存可能な状態に保たれるか」という問いに対して、第3正規形が「アプリケーションプログラムの寿命を大幅に延ばす」と予測した。

```
正規化の段階的な進化

第1正規形 (1NF) ── 1970年、Codd
│  要件: すべての属性がアトミック値
│  排除: 繰り返しグループ、ネストした構造
│
第2正規形 (2NF) ── 1971年、Codd
│  要件: 1NF + 非キー属性が候補キー全体に完全関数従属
│  排除: 部分関数従属（複合キーの一部への依存）
│
第3正規形 (3NF) ── 1971年、Codd
│  要件: 2NF + 非キー属性間の推移的関数従属がない
│  排除: 推移的従属（A→B→Cのような間接的依存）
│
Boyce-Codd正規形 (BCNF) ── 1974年、Boyce & Codd
│  要件: すべての非自明な関数従属X→Yにおいて、Xがスーパーキー
│  排除: 3NFでは許容される特定の異常パターン
│
第4正規形 (4NF) ── 1977年、Fagin
│  要件: BCNF + 非自明な多値従属X→→Yにおいて、Xがスーパーキー
│  排除: 多値従属による冗長性
│
第5正規形 (5NF/PJ/NF) ── 1979年、Fagin
   要件: すべての非自明な結合従属において、各射影がキーを含む
   排除: 結合従属による冗長性
```

この年表で注目すべきは、正規化理論の核心が約10年間（1970-1979年）で急速に整備されたことだ。Coddが1NFを定義してからRonald Faginが5NFを定義するまで、わずか9年。この9年間に、データモデリングの理論的基盤が確立された。

### BCNFと「Codd以降」の正規化

1974年、Raymond F. BoyceとEdgar F. CoddがBoyce-Codd正規形（BCNF）を発表した（「Recent Investigations in Relational Database Systems」、IFIP Congress, pp.1017-1021）。興味深いことに、Chris Dateは、BCNFと実質的に同等の定義がIan Heathにより1971年に既に提示されていたと指摘している。

BCNFは3NFの強化版だ。3NFでは許容される特定の異常パターン——候補キーが複数存在し、それらが重複する属性を含む場合に発生する——を排除する。実務上、3NFとBCNFの違いが問題になるケースは限定的だが、理論的な体系としての完備性を追求するCoddの姿勢がここに見える。

1977年、IBMのRonald Faginが「Multivalued Dependencies and a New Normal Form for Relational Databases」をACM Transactions on Database Systemsに発表し、第4正規形（4NF）を定義した。多値従属性（Multivalued Dependency）という新しい概念を導入し、関数従属性がその特殊ケースであることを示した。

1979年、同じくFaginがACM SIGMODで「Normal Forms and Relational Database Operators」を発表し、第5正規形（5NF）——射影-結合正規形（PJ/NF）——を定義した。Faginはこの論文で、5NFが「関数従属性、多値従属性、結合従属性に起因するすべての挿入・削除・更新異常を排除するために必要な正規化の最高レベル」であることを証明した。

### 正規化理論の功績と限界

正規化理論はデータベース設計に決定的な貢献をした。データの冗長性を体系的に排除する手法を提供し、更新時の整合性維持を容易にした。教科書的には、正規化はデータベース設計の「ベストプラクティス」として教えられ続けている。

だが正規化理論には、根本的な前提がある。「データの更新（書き込み）における整合性を最優先する」という前提だ。

正規化がデータの冗長性を排除するのは、同じデータが複数の場所に存在すると、一方を更新して他方を更新し忘れるリスクがあるからだ。つまり正規化は、書き込み操作の安全性を最適化する設計手法なのだ。

では読み取り操作はどうか。正規化されたデータベースでは、情報を取得するために複数のテーブルをJOINする必要がある。JOINの数が増えるほど、クエリの複雑さと実行コストは増大する。私がECサイトで体験したように、読み取り性能の劣化は正規化の構造的な代償だ。

この「書き込み最適化 vs 読み取り最適化」のトレードオフこそが、データモデリングの根本的な緊張関係である。正規化理論は、このトレードオフの「書き込み側」に立つ理論だ。では「読み取り側」に立つ設計思想はどのように発展してきたのか。

---

## 3. 正規化の「外」へ——データモデリング思想の多様化

### Peter ChenのERモデル（1976年）——概念の地図

正規化理論は「テーブルの構造をどう分割すべきか」に回答する理論だが、そもそも「何をテーブルにすべきか」という問いには答えない。この問いに取り組んだのが、Peter Pin-Shan Chenだ。

1976年、MITスローン経営大学院の助教授だったChen（台湾生まれ、1973年にハーバード大学でPh.D.取得）は、ACM Transactions on Database Systems（Vol.1, No.1, pp.9-36）に「The Entity-Relationship Model—Toward a Unified View of Data」を発表した。初期版は1975年9月のVLDB国際会議で発表されていた。

ChenのERモデルは、データベースに格納すべき「実世界の情報構造」を、エンティティ（実体）、リレーションシップ（関係）、属性（属性）という三つの概念で記述する。そしてER図（Entity-Relationship Diagram）という視覚的な表記法を提供した。

```
ERモデルの三要素

┌───────────────────────────────────────────────────┐
│                  ERモデル (1976)                    │
├───────────────────────────────────────────────────┤
│                                                    │
│  エンティティ (Entity)                              │
│    現実世界の「もの」や「概念」                      │
│    例: 顧客、商品、注文                             │
│                                                    │
│  リレーションシップ (Relationship)                   │
│    エンティティ間の「関連」                          │
│    例: 顧客が注文する、注文に商品が含まれる          │
│    カーディナリティ: 1:1, 1:N, M:N                  │
│                                                    │
│  属性 (Attribute)                                   │
│    エンティティやリレーションシップの「性質」         │
│    例: 顧客名、注文日、商品価格                      │
│                                                    │
├───────────────────────────────────────────────────┤
│  正規化理論: テーブル構造の「分割方法」を決める       │
│  ERモデル:   テーブルにすべき「概念」を決める         │
│  → 両者は補完関係にある                             │
└───────────────────────────────────────────────────┘
```

ERモデルの革命的な点は、データベース設計のプロセスを二段階に分離したことだ。まず「概念設計」——現実世界の情報構造をER図で表現する。次に「論理設計」——ER図を正規化されたテーブル構造に変換する。

この分離により、データベース設計者は技術的な制約から離れて「何を表現すべきか」に集中できるようになった。ERモデルはデータモデリングの「概念的地図」を描く道具であり、正規化理論は地図を「実装」に落とし込む道具だ。ChenのERモデルは5,000以上の被引用数を誇り、概念モデリングという研究・実務分野を切り開いた。

### Kimball vs Inmon——分析の世界での戦い

1990年代に入ると、データモデリングの戦場はトランザクション処理（OLTP）から分析処理（OLAP）へと拡大した。ここで二つの対立する設計思想が激突する。Bill InmonとRalph Kimballの論争だ。

1992年、Bill Inmonは『Building the Data Warehouse』（QED Technical Publishing Group）を出版し、データウェアハウスの概念を確立した。Inmonはデータウェアハウスを「統合的、主題指向、時系列、非揮発性」のリポジトリと定義し、そのデータモデルとして第3正規形（3NF）を推奨した。

Inmonの主張はこうだ。データウェアハウスの中核は企業全体の統合データモデルであるべきだ。正規化によってデータの一貫性と柔軟性を保証し、各部門のデータマート（分析用のサブセット）はこの中核モデルから派生させる。トップダウンアプローチである。

4年後の1996年、Ralph Kimballは『The Data Warehouse Toolkit』（Wiley）を出版し、まったく異なるアプローチを提唱した。ディメンショナルモデリングだ。

Kimballのアプローチは、データを「ファクト（事実）」と「ディメンション（次元）」に分離する。ファクトテーブルには計測可能な数値データ（売上金額、数量など）を格納し、ディメンションテーブルには分析の切り口（時間、地域、商品カテゴリなど）を格納する。この構造はスタースキーマと呼ばれ、ファクトテーブルを中心にディメンションテーブルが放射状に配置される。

```
Inmon vs Kimball: 二つのデータウェアハウス設計思想

Inmon方式 (1992年)
─────────────────
  ソース → ETL → 企業データウェアハウス (3NF) → データマート
                        │                         │
                  正規化された統合モデル      部門別スタースキーマ
                        │
                 トップダウンアプローチ
                        │
  利点: データの一貫性、柔軟性、単一ソースオブトゥルース
  欠点: 構築に時間がかかる、コストが高い

Kimball方式 (1996年)
─────────────────
  ソース → ETL → データマート (スタースキーマ) → 統合バス
                        │
                 非正規化ディメンショナルモデル
                        │
                 ボトムアップアプローチ
                        │
  利点: 迅速な構築、直感的なクエリ、高い検索性能
  欠点: データの冗長性、部門間の不整合リスク
```

この論争は、データモデリングの本質を浮き彫りにする。Inmonは「データの整合性」を最優先し、Kimballは「データの利用しやすさ」を最優先する。どちらが「正しい」のか。答えは、問いの立て方に依存する。

私の経験から言えば、この論争に「勝者」はいない。大規模な企業でInmon方式の3NF統合モデルを構築する余裕がある組織は限られている。一方でKimball方式のスタースキーマだけでは、組織全体のデータ一貫性を担保できない。実務では両者のハイブリッド——統合層を3NFで構築し、消費層をスタースキーマで構築する——が現実的な解であることが多い。

### Eric EvansのDDD（2003年）——データに「境界」を引く

2003年、Eric Evansは『Domain-Driven Design: Tackling Complexity in the Heart of Software』（Addison-Wesley）を出版した。「Domain-Driven Design」という用語自体がEvansの造語であり、この書籍はソフトウェア設計に決定的な影響を与えた。

DDDがデータモデリングに持ち込んだ最大の概念は「境界づけられたコンテキスト（Bounded Context）」だ。

従来のデータモデリングでは、企業全体の情報を一つの統合データモデルで表現することが理想とされていた。Inmonのデータウェアハウスも、ERモデルによる概念設計も、究極的には「単一の整合的なモデル」を目指していた。

Evansはこの前提を否定した。大規模なシステムにおいて、単一の整合的なモデルは幻想だと。

「顧客」という概念一つとっても、営業部門にとっての顧客、配送部門にとっての顧客、経理部門にとっての顧客は、含む属性も制約も異なる。これらを一つの「顧客テーブル」に押し込めようとすると、妥協と複雑さが増大する。

DDDの回答は、ビジネスドメインを複数の「境界づけられたコンテキスト」に分割し、各コンテキスト内で独自のモデルを構築することだ。コンテキスト間のデータ交換はコンテキストマッピングで明示的に管理する。

```
DDDの境界づけられたコンテキスト

従来のアプローチ:
┌──────────────────────────────────────────────┐
│           企業統合データモデル                  │
│                                               │
│  顧客テーブル（全部門の要件を網羅）            │
│  ├ 顧客ID, 名前, 住所                         │
│  ├ 与信限度額（経理用）                        │
│  ├ 配送先住所リスト（配送用）                  │
│  ├ 営業担当者（営業用）                        │
│  └ ... 属性が肥大化する                       │
└──────────────────────────────────────────────┘

DDDのアプローチ:
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ 営業コンテキスト│  │ 配送コンテキスト│  │ 経理コンテキスト│
│              │  │              │  │              │
│ 顧客:        │  │ 配送先:       │  │ 取引先:       │
│ ├ 顧客ID     │  │ ├ 配送先ID    │  │ ├ 取引先ID    │
│ ├ 名前       │  │ ├ 宛名       │  │ ├ 法人名      │
│ ├ 営業担当   │  │ ├ 住所       │  │ ├ 与信限度額   │
│ └ 商談履歴   │  │ └ 配送指示   │  │ └ 請求先情報   │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                │                │
       └────── コンテキストマッピング ──────┘
       （各コンテキスト間でIDによる参照）
```

DDDの「集約（Aggregate）」という概念も、データモデリングに深い影響を与えた。集約は、一つのルートエンティティを起点としてまとめられるオブジェクト群であり、集約の外部からは集約ルートのみが参照される。これはデータベース設計においては、「どのテーブルをまとめてトランザクションの単位とするか」という問いへの回答となる。

DDDの視点は、正規化理論とは根本的に異なる。正規化理論は「データの構造的冗長性の排除」を目的とするが、DDDは「ビジネスドメインの概念的境界の反映」を目的とする。DDDの視点に立てば、コンテキスト間でデータが重複すること自体は問題ではない。各コンテキストが自身の責務に対して整合的であれば、それで十分だ。

### CQRS/イベントソーシング——データモデルの「分裂」

DDDが「空間的な境界」をデータモデルに導入したとすれば、CQRS（Command Query Responsibility Segregation）とイベントソーシングは「操作の方向による分離」を導入した。

CQRSのルーツは、Bertrand Meyerが1988年の著書『Object-Oriented Software Construction』（Prentice Hall）で提唱した「Command Query Separation（CQS）」原則にある。CQSの原則は単純だ。メソッドは「コマンド（状態を変更するが値を返さない）」か「クエリ（値を返すが状態を変更しない）」のどちらかであるべきだ。

Greg Youngはこの原則をアーキテクチャレベルに拡張し、2007年頃に「CQRS」という用語を造語した。CQRSの核心は、「書き込みモデル」と「読み取りモデル」を完全に分離することだ。

従来のデータモデリングでは、一つのテーブル設計が書き込みと読み取りの両方を担う。正規化はこの一つのモデルの中で書き込みの整合性を最適化し、非正規化はこの一つのモデルの中で読み取りの性能を最適化する。正規化と非正規化のトレードオフは、一つのモデルの中での緊張関係だ。

CQRSはこの前提を覆す。書き込み側（Command）には正規化された、整合性を重視したモデルを使い、読み取り側（Query）には非正規化された、パフォーマンスを重視したモデルを使う。二つのモデルはイベントやメッセージを介して同期される。

```
CQRSのモデル分離

従来のアプローチ:
┌─────────────────────────┐
│   単一のデータモデル       │
│                          │
│  書き込み ──→ テーブル群 ←── 読み取り
│            （妥協の産物）
│                          │
│  正規化すれば書き込みに有利 │
│  非正規化すれば読み取りに有利│
│  → 常にトレードオフ        │
└─────────────────────────┘

CQRSのアプローチ:
┌──────────────────┐     ┌──────────────────┐
│  書き込みモデル     │     │  読み取りモデル     │
│  (Command側)      │     │  (Query側)        │
│                   │     │                   │
│  正規化された      │     │  非正規化された     │
│  ドメインモデル    │────→│  ビューモデル       │
│                   │ 同期 │                   │
│  整合性最優先      │     │  パフォーマンス最優先│
└──────────────────┘     └──────────────────┘
                  │
           トレードオフの解消
           （各モデルが各目的に最適化）
```

イベントソーシングは、CQRSと頻繁に組み合わせて使用されるパターンだ。Martin Fowlerが2005年にEvent Sourcingパターンを記事として公開し、Greg Youngが2007年にその定義を定式化した。

イベントソーシングの核心は、「現在の状態」ではなく「状態を変化させたイベント」をデータの一次ソースとして保存することだ。注文の「現在の状態」を保存するのではなく、「注文が作成された」「商品が追加された」「支払いが完了した」「配送が開始された」という一連のイベントを時系列で保存する。現在の状態は、これらのイベントを先頭から再生することで導出される。

2016年の講演「A Decade of DDD, CQRS, Event Sourcing」でGreg Youngは「CQRSはイベントソーシングへのステッピングストーンだった」と述べている。読み取りと書き込みを分離するCQRSの思想が、「書き込み側をイベントストアにする」というイベントソーシングの発想を自然に導いた。

ただし、Martin Fowlerは2011年のCQRS記事で「ほとんどのシステムにとってCQRSはリスクのある複雑性を加える」と警告している。CQRS/イベントソーシングは強力なパターンだが、その複雑性に見合うだけのユースケースでのみ採用すべきだ。

### マイクロサービス——データの「所有権」

DDDの境界づけられたコンテキストとCQRSの思想は、マイクロサービスアーキテクチャのデータ管理原則に直結する。

Chris Richardson（microservices.ioの創設者、『Microservices Patterns』Manning, 2018年）やSam Newman（『Building Microservices』O'Reilly, 2015年）が体系化した「Database per Service」パターンは、各マイクロサービスが自身のデータベースを所有し、他のサービスのデータベースに直接アクセスしないという原則だ。

これはDDDの境界づけられたコンテキストをデータベースレベルで実現するものだ。各サービスのデータモデルは独立して進化でき、スキーマの変更が他のサービスに波及しない。

だがこの原則は、正規化理論の対極に位置する。正規化が「データの冗長性を排除する」ことを目指すのに対し、Database per Serviceは「サービス間でデータが重複することを許容する」。顧客の名前が注文サービスと配送サービスの両方に保存されていても構わない。それぞれのサービスが自身の責務に対して整合的であれば、グローバルな整合性は結果整合性（Eventual Consistency）で十分だ。

```
データモデリング思想の歴史的系譜

1970  Codd: 正規化理論 ─── 冗長性の排除（書き込み最適化）
  │
1976  Chen: ERモデル ────── 概念構造の可視化
  │
1992  Inmon: 3NF DWH ───── 分析でも正規化を堅持
  │
1996  Kimball: スタースキーマ── 分析用途の非正規化を肯定
  │
2003  Evans: DDD ─────── 境界づけられたコンテキスト（空間的分割）
  │
2005  Fowler: Event Sourcing── 状態ではなくイベントを保存
  │
2007  Young: CQRS ────── 読み書きモデルの分離（操作的分割）
  │
2015  Newman/Richardson ── Database per Service（所有権の分割）
  │
  ▼
データモデリングは「唯一の正解」から「判断基準に基づく選択」へ
```

この系譜を俯瞰すると、データモデリングの思想は「単一の最適解」から「文脈に応じた選択」へと進化してきたことがわかる。正規化理論は万能ではない。だがERモデルもディメンショナルモデリングもDDDもCQRSもイベントソーシングも、単独では万能ではない。

それぞれが異なる「文脈」——アクセスパターン、一貫性要件、スケール要件、チーム構造——に対して最適化された設計手法であり、データモデリングの本質は「どの手法をどの文脈で適用するか」という判断にある。

---

## 4. ハンズオン: 同じ要件を3つの設計で実装する

理論だけでは、各アプローチの「手触り」は伝わらない。同じビジネス要件に対して、3つの異なるデータモデル——正規化RDB設計、非正規化ドキュメント設計、イベントソーシング設計——を実装し、それぞれの得手不得手を体験する。

### ビジネス要件: 簡易ECサイトの注文管理

以下の要件を満たす注文管理システムを設計する。

- 顧客が商品を注文する
- 注文には複数の商品が含まれる
- 注文にはステータス（作成済み、支払済み、配送中、完了）がある
- 顧客情報、商品情報、注文情報をそれぞれ管理する
- 注文履歴の参照、特定顧客の注文集計、商品別の売上集計が必要

### 環境構築

```bash
# handson/database-history/23-data-modeling-essence/setup.sh を実行
bash setup.sh
```

### アプローチ1: 正規化RDB設計（PostgreSQL）

第3正規形に従った正統派の設計だ。データの冗長性を排除し、外部キーで関連を管理する。

```bash
# PostgreSQL 17をDockerで起動
docker run -d \
  --name pg-normalized \
  -e POSTGRES_PASSWORD=handson \
  -e POSTGRES_DB=normalized_db \
  -p 5432:5432 \
  postgres:17

sleep 3
```

```bash
# 正規化されたスキーマとテストデータを投入
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
-- 顧客テーブル
CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 商品テーブル
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price INTEGER NOT NULL,
  category TEXT NOT NULL
);

-- 注文テーブル
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id),
  status TEXT NOT NULL DEFAULT 'created',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 注文明細テーブル（多対多の解決）
CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL,
  unit_price INTEGER NOT NULL  -- 注文時点の価格を記録
);

-- テストデータ投入
INSERT INTO customers (name, email) VALUES
('田中太郎', 'tanaka@example.com'),
('鈴木花子', 'suzuki@example.com'),
('佐藤次郎', 'sato@example.com');

INSERT INTO products (name, price, category) VALUES
('PostgreSQL入門書', 3200, '書籍'),
('DuckDBハンドブック', 2800, '書籍'),
('SQLマスターコース', 15000, 'オンライン講座'),
('DB設計パターン集', 3800, '書籍');

INSERT INTO orders (customer_id, status, created_at) VALUES
(1, 'completed', '2024-11-01 10:00:00'),
(1, 'shipped',   '2024-12-15 14:30:00'),
(2, 'completed', '2024-11-20 09:00:00'),
(3, 'paid',      '2025-01-05 16:00:00');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 3200), (1, 2, 1, 2800),
(2, 3, 1, 15000),
(3, 1, 2, 3200), (3, 4, 1, 3800),
(4, 2, 1, 2800), (4, 3, 1, 15000);
SQL

echo "正規化RDB設計のデータ投入完了"
```

```bash
# 典型的なクエリ: 注文一覧（JOINが多い）
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
-- 注文一覧: 顧客名、注文ステータス、商品名、数量、金額を取得
-- 3つのJOINが必要
SELECT
  o.id AS order_id,
  c.name AS customer_name,
  o.status,
  p.name AS product_name,
  oi.quantity,
  oi.unit_price * oi.quantity AS subtotal,
  o.created_at
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
JOIN products p ON oi.product_id = p.id
ORDER BY o.created_at DESC;
SQL
```

```bash
# 集計クエリ: 顧客別の累計購入金額
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
SELECT
  c.name AS customer_name,
  COUNT(DISTINCT o.id) AS order_count,
  SUM(oi.unit_price * oi.quantity) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.id
JOIN order_items oi ON oi.order_id = o.id
GROUP BY c.id, c.name
ORDER BY total_spent DESC;
SQL
```

正規化設計の特徴を体感できただろうか。データの冗長性はゼロだ。商品の価格を変更しても、過去の注文の`unit_price`は注文時の価格を保持する（これはorder_itemsに冗長に価格を持たせている。ある意味、ここにすでに「非正規化」が潜んでいる）。だが、単純な注文一覧の表示に3つのJOINが必要だ。テーブル数が増えれば、クエリの複雑さは加速度的に増す。

### アプローチ2: 非正規化ドキュメント設計（PostgreSQL JSONB）

MongoDBのようなドキュメント指向データベースの設計をPostgreSQLのJSONBで模倣する。一つの注文ドキュメントに、関連する顧客情報と商品情報を埋め込む。

```bash
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
-- 非正規化ドキュメント設計用のテーブル
CREATE TABLE order_documents (
  id SERIAL PRIMARY KEY,
  data JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- テストデータ: 関連情報を埋め込んだドキュメント
INSERT INTO order_documents (data, created_at) VALUES
('{
  "order_id": 1,
  "customer": {"id": 1, "name": "田中太郎", "email": "tanaka@example.com"},
  "status": "completed",
  "items": [
    {"product_id": 1, "name": "PostgreSQL入門書", "category": "書籍",
     "quantity": 1, "unit_price": 3200},
    {"product_id": 2, "name": "DuckDBハンドブック", "category": "書籍",
     "quantity": 1, "unit_price": 2800}
  ],
  "total": 6000
}'::jsonb, '2024-11-01 10:00:00'),
('{
  "order_id": 2,
  "customer": {"id": 1, "name": "田中太郎", "email": "tanaka@example.com"},
  "status": "shipped",
  "items": [
    {"product_id": 3, "name": "SQLマスターコース", "category": "オンライン講座",
     "quantity": 1, "unit_price": 15000}
  ],
  "total": 15000
}'::jsonb, '2024-12-15 14:30:00'),
('{
  "order_id": 3,
  "customer": {"id": 2, "name": "鈴木花子", "email": "suzuki@example.com"},
  "status": "completed",
  "items": [
    {"product_id": 1, "name": "PostgreSQL入門書", "category": "書籍",
     "quantity": 2, "unit_price": 3200},
    {"product_id": 4, "name": "DB設計パターン集", "category": "書籍",
     "quantity": 1, "unit_price": 3800}
  ],
  "total": 10200
}'::jsonb, '2024-11-20 09:00:00'),
('{
  "order_id": 4,
  "customer": {"id": 3, "name": "佐藤次郎", "email": "sato@example.com"},
  "status": "paid",
  "items": [
    {"product_id": 2, "name": "DuckDBハンドブック", "category": "書籍",
     "quantity": 1, "unit_price": 2800},
    {"product_id": 3, "name": "SQLマスターコース", "category": "オンライン講座",
     "quantity": 1, "unit_price": 15000}
  ],
  "total": 17800
}'::jsonb, '2025-01-05 16:00:00');

-- 注文一覧: JOINなしで取得できる
SELECT
  data->>'order_id' AS order_id,
  data->'customer'->>'name' AS customer_name,
  data->>'status' AS status,
  (data->>'total')::integer AS total,
  created_at
FROM order_documents
ORDER BY created_at DESC;
SQL
```

```bash
# ドキュメント設計での集計クエリ
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
-- 顧客別の累計購入金額: JOINなし
SELECT
  data->'customer'->>'name' AS customer_name,
  COUNT(*) AS order_count,
  SUM((data->>'total')::integer) AS total_spent
FROM order_documents
GROUP BY data->'customer'->>'id', data->'customer'->>'name'
ORDER BY total_spent DESC;

-- 商品別の売上: JSONB配列を展開
SELECT
  item->>'name' AS product_name,
  SUM((item->>'quantity')::integer) AS total_quantity,
  SUM((item->>'quantity')::integer * (item->>'unit_price')::integer) AS total_revenue
FROM order_documents,
     jsonb_array_elements(data->'items') AS item
GROUP BY item->>'product_id', item->>'name'
ORDER BY total_revenue DESC;
SQL
```

ドキュメント設計では、注文一覧の取得にJOINが不要だ。一つのドキュメントに必要な情報がすべて埋め込まれている。読み取り性能は圧倒的に高い。

だが代償がある。顧客の名前が変更された場合、すべての注文ドキュメントの `customer.name` を更新しなければならない。商品の価格が変更された場合も同様だ。データの冗長性が更新の複雑さを生む。これが非正規化の構造的コストだ。

### アプローチ3: イベントソーシング設計

状態ではなくイベントを保存する。現在の状態はイベントの再生で導出する。

```bash
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
-- イベントストア
CREATE TABLE event_store (
  id SERIAL PRIMARY KEY,
  stream_id TEXT NOT NULL,      -- 集約のID（例: order-1）
  event_type TEXT NOT NULL,     -- イベントの種類
  event_data JSONB NOT NULL,    -- イベントのペイロード
  version INTEGER NOT NULL,     -- 楽観的同時実行制御用
  occurred_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(stream_id, version)    -- 同一ストリームでバージョン重複を防止
);

-- イベントデータの投入
-- 注文1のイベント列
INSERT INTO event_store (stream_id, event_type, event_data, version, occurred_at) VALUES
('order-1', 'OrderCreated', '{
  "customer_id": 1, "customer_name": "田中太郎"
}'::jsonb, 1, '2024-11-01 10:00:00'),
('order-1', 'ItemAdded', '{
  "product_id": 1, "name": "PostgreSQL入門書", "quantity": 1, "unit_price": 3200
}'::jsonb, 2, '2024-11-01 10:00:01'),
('order-1', 'ItemAdded', '{
  "product_id": 2, "name": "DuckDBハンドブック", "quantity": 1, "unit_price": 2800
}'::jsonb, 3, '2024-11-01 10:00:02'),
('order-1', 'OrderPaid', '{
  "amount": 6000, "method": "credit_card"
}'::jsonb, 4, '2024-11-01 10:30:00'),
('order-1', 'OrderShipped', '{
  "tracking_number": "JP1234567890"
}'::jsonb, 5, '2024-11-03 09:00:00'),
('order-1', 'OrderCompleted', '{}'::jsonb, 6, '2024-11-05 14:00:00');

-- 注文2のイベント列
INSERT INTO event_store (stream_id, event_type, event_data, version, occurred_at) VALUES
('order-2', 'OrderCreated', '{
  "customer_id": 1, "customer_name": "田中太郎"
}'::jsonb, 1, '2024-12-15 14:30:00'),
('order-2', 'ItemAdded', '{
  "product_id": 3, "name": "SQLマスターコース", "quantity": 1, "unit_price": 15000
}'::jsonb, 2, '2024-12-15 14:30:01'),
('order-2', 'OrderPaid', '{
  "amount": 15000, "method": "bank_transfer"
}'::jsonb, 3, '2024-12-16 10:00:00'),
('order-2', 'OrderShipped', '{
  "tracking_number": "JP9876543210"
}'::jsonb, 4, '2024-12-18 09:00:00');

-- 注文3のイベント列
INSERT INTO event_store (stream_id, event_type, event_data, version, occurred_at) VALUES
('order-3', 'OrderCreated', '{
  "customer_id": 2, "customer_name": "鈴木花子"
}'::jsonb, 1, '2024-11-20 09:00:00'),
('order-3', 'ItemAdded', '{
  "product_id": 1, "name": "PostgreSQL入門書", "quantity": 2, "unit_price": 3200
}'::jsonb, 2, '2024-11-20 09:00:01'),
('order-3', 'ItemAdded', '{
  "product_id": 4, "name": "DB設計パターン集", "quantity": 1, "unit_price": 3800
}'::jsonb, 3, '2024-11-20 09:00:02'),
('order-3', 'OrderPaid', '{
  "amount": 10200, "method": "credit_card"
}'::jsonb, 4, '2024-11-20 10:00:00'),
('order-3', 'OrderShipped', '{
  "tracking_number": "JP1111111111"
}'::jsonb, 5, '2024-11-22 09:00:00'),
('order-3', 'OrderCompleted', '{}'::jsonb, 6, '2024-11-25 12:00:00');
SQL

echo "イベントソーシング設計のデータ投入完了"
```

```bash
# イベントから現在の状態を再構築する
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
-- 各注文の現在のステータスを導出
-- 最新のステータス変更イベントから判定する
WITH latest_status AS (
  SELECT DISTINCT ON (stream_id)
    stream_id,
    event_type,
    occurred_at
  FROM event_store
  WHERE event_type IN ('OrderCreated', 'OrderPaid', 'OrderShipped', 'OrderCompleted')
  ORDER BY stream_id, version DESC
),
order_customers AS (
  SELECT
    stream_id,
    event_data->>'customer_name' AS customer_name
  FROM event_store
  WHERE event_type = 'OrderCreated'
),
order_items AS (
  SELECT
    stream_id,
    jsonb_agg(jsonb_build_object(
      'name', event_data->>'name',
      'quantity', (event_data->>'quantity')::integer,
      'unit_price', (event_data->>'unit_price')::integer
    )) AS items,
    SUM((event_data->>'quantity')::integer *
        (event_data->>'unit_price')::integer) AS total
  FROM event_store
  WHERE event_type = 'ItemAdded'
  GROUP BY stream_id
)
SELECT
  ls.stream_id,
  oc.customer_name,
  CASE ls.event_type
    WHEN 'OrderCreated' THEN 'created'
    WHEN 'OrderPaid' THEN 'paid'
    WHEN 'OrderShipped' THEN 'shipped'
    WHEN 'OrderCompleted' THEN 'completed'
  END AS status,
  oi.items,
  oi.total,
  ls.occurred_at AS last_updated
FROM latest_status ls
JOIN order_customers oc ON oc.stream_id = ls.stream_id
JOIN order_items oi ON oi.stream_id = ls.stream_id
ORDER BY ls.stream_id;
SQL
```

```bash
# イベントソーシングの真価: 任意の時点の状態を再現できる
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
-- 注文1の「2024-11-01 10:30:00まで」の状態を再現
-- （支払い完了後、配送前の状態）
SELECT
  stream_id,
  event_type,
  event_data,
  occurred_at
FROM event_store
WHERE stream_id = 'order-1'
  AND occurred_at <= '2024-11-01 10:30:00'
ORDER BY version;

-- 全注文のイベント数を確認
SELECT
  stream_id,
  COUNT(*) AS event_count,
  MIN(occurred_at) AS first_event,
  MAX(occurred_at) AS last_event
FROM event_store
GROUP BY stream_id
ORDER BY stream_id;
SQL
```

イベントソーシング設計では、「何が起きたか」の完全な履歴が保存される。任意の時点の状態を再現できる。監査証跡が自動的に提供される。

だが代償は明白だ。現在の状態を取得するクエリが複雑になる。イベントの数が増えるほど、状態の再構築コストが上昇する（実運用ではスナップショットで軽減する）。そして、イベントスキーマのバージョン管理という新たな課題が発生する。

### 3つのアプローチの比較

```bash
docker exec -i pg-normalized psql -U postgres -d normalized_db << 'SQL'
-- 比較のまとめ
SELECT '正規化RDB' AS approach,
       'JOINで取得（3テーブル結合）' AS read_pattern,
       '各テーブルを個別にUPDATE' AS write_pattern,
       'テーブル間の整合性（外部キー）' AS consistency,
       'JOIN増加で性能劣化' AS weakness
UNION ALL
SELECT '非正規化ドキュメント',
       '単一ドキュメントで取得（JOINなし）',
       '埋め込みデータの一括更新が必要',
       'ドキュメント内は整合的、間は結果整合',
       'データ冗長性、更新の複雑さ'
UNION ALL
SELECT 'イベントソーシング',
       'イベント再生で状態を導出（複雑）',
       'イベントのappendのみ（単純）',
       'イベントストリームの順序で保証',
       '読み取りの複雑さ、スキーマ進化';
SQL
```

### 後片付け

```bash
docker stop pg-normalized && docker rm pg-normalized
```

---

## 5. データモデリングの「判断基準」——正解はないが、地図はある

第23回を振り返ろう。

**正規化理論は、Coddの1970年論文に始まり、1979年のFaginの第5正規形まで約10年間で体系が確立された。** その核心は、データの冗長性を体系的に排除し、更新時の整合性を保証することにある。正規化は「書き込み最適化」の設計手法だ。

**Peter Chenの1976年のERモデルは、「何をテーブルにすべきか」という概念設計の領域を切り開いた。** 正規化理論が「テーブルの分割方法」に回答するのに対し、ERモデルは「テーブルにすべき概念」に回答する。両者は補完関係にある。

**1990年代のKimball vs Inmon論争は、「分析用途でも正規化すべきか」という問いを突きつけた。** Inmonの3NF統合モデルは整合性を、Kimballのスタースキーマは利用しやすさを優先した。どちらが正しいかではなく、何を優先するかの問題だ。

**2003年のEvansのDDDは、データモデルに「境界」の概念を持ち込んだ。** 境界づけられたコンテキストは、「単一の整合的なモデル」という幻想を打破し、コンテキストごとに最適なモデルを構築する道を開いた。

**Greg YoungのCQRS/イベントソーシング（2007年頃）は、読み取りと書き込みのモデルを分離し、正規化vs非正規化のトレードオフそのものを解消する可能性を示した。** ただし、その複雑性は相応の覚悟を要する。

**マイクロサービスのDatabase per Serviceパターンは、DDDの境界をデータベースレベルで実現し、サービスごとのデータオーナーシップを確立した。**

冒頭の問い——データモデリングの「正解」は存在するのか——に戻ろう。

私の24年間の結論はこうだ。データモデリングに「銀の弾丸」はない。だが「判断基準」はある。

第一に、**アクセスパターン**。読み取りが支配的なシステムでは非正規化が有利であり、書き込みの整合性が重要なシステムでは正規化が有利だ。CQRSは両者を分離することで、この判断自体を不要にする可能性がある。

第二に、**一貫性要件**。強い一貫性が必要なドメイン（金融、在庫管理）ではACIDトランザクションと正規化が重要だ。結果整合性が許容されるドメイン（レコメンデーション、閲覧履歴）では、非正規化やイベントソーシングの柔軟性が活きる。

第三に、**スケール要件**。単一データベースに収まるシステムなら正規化で十分だ。水平スケールが必要なシステムでは、Database per Serviceやドキュメント設計の方が適合する。

第四に、**チーム構造**。Conwayの法則が教えるように、システムの構造はそれを構築する組織の構造を反映する。DDDの境界づけられたコンテキストは、チームの境界と一致させることで最も効果を発揮する。

これらの判断基準を理解した上で「選ぶ」力こそが、データモデリングの本質だ。教科書が教える「正規化せよ」は、判断基準の一つに過ぎない。

最終回「データベースの地層を読む——あなたは何を選ぶか」では、この連載全体を振り返り、50年のデータベース史が教えてくれる「技術選定の判断基準」を体系化する。24回の連載で辿ってきた地層の知識を、あなたのプロジェクトに活かすための地図を描く。

---

### 参考文献

- Codd, E.F., "A Relational Model of Data for Large Shared Data Banks", Communications of the ACM, Vol.13, No.6, pp.377-387, 1970. <https://dl.acm.org/doi/10.1145/362384.362685>
- Codd, E.F., "Further Normalization of the Data Base Relational Model", 1971. <https://www.semanticscholar.org/paper/Further-Normalization-of-the-Data-Base-Relational-Codd/7be40103ca2c4114e07bb327bf5f902d5b081808>
- Codd, E.F. and Boyce, R.F., "Recent Investigations in Relational Database Systems", IFIP Congress, pp.1017-1021, 1974. <https://en.wikipedia.org/wiki/Boyce%E2%80%93Codd_normal_form>
- Fagin, R., "Multivalued Dependencies and a New Normal Form for Relational Databases", ACM TODS, 1977. <https://dl.acm.org/doi/10.1145/320557.320571>
- Fagin, R., "Normal Forms and Relational Database Operators", ACM SIGMOD, 1979. <https://en.wikipedia.org/wiki/Fifth_normal_form>
- Chen, P.P., "The Entity-Relationship Model—Toward a Unified View of Data", ACM TODS, Vol.1, No.1, pp.9-36, 1976. <https://dl.acm.org/doi/10.1145/320434.320440>
- Inmon, W.H., "Building the Data Warehouse", QED Technical Publishing Group, 1992. <https://en.wikipedia.org/wiki/Bill_Inmon>
- Kimball, R., "The Data Warehouse Toolkit", Wiley, 1996. <https://en.wikipedia.org/wiki/Ralph_Kimball>
- Evans, E., "Domain-Driven Design: Tackling Complexity in the Heart of Software", Addison-Wesley, 2003. <https://en.wikipedia.org/wiki/Domain-driven_design>
- Fowler, M., "Event Sourcing", martinfowler.com, 2005. <https://martinfowler.com/eaaDev/EventSourcing.html>
- Fowler, M., "CQRS", martinfowler.com, 2011. <https://www.martinfowler.com/bliki/CQRS.html>
- Young, G., "CQRS Documents", 2010. <https://cqrs.files.wordpress.com/2010/11/cqrs_documents.pdf>
- Meyer, B., "Object-Oriented Software Construction", Prentice Hall, 1988. <https://en.wikipedia.org/wiki/Command%E2%80%93query_separation>
- Richardson, C., "Microservices Patterns", Manning, 2018. <https://microservices.io/patterns/data/database-per-service.html>
- Newman, S., "Building Microservices", O'Reilly, 2015.

---

**次回予告：** 最終回・第24回「データベースの地層を読む——あなたは何を選ぶか」では、この連載全24回を振り返り、データベース技術50年の歴史が教えてくれる「技術選定の判断基準」を体系化する。ファイルベースのデータ管理からNewSQL、ベクトルDB、そしてデータモデリングの本質まで——50年の地層を読む力が、次の10年のデータ管理を切り拓く。あなたは何を選ぶか。
