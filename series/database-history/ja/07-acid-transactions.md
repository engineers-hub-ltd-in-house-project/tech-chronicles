# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第7回：ACIDとトランザクション——データの「約束」をどう守るか

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- トランザクションという概念がなぜ生まれ、何を解決しているのか
- Jim Grayのトランザクション研究とその歴史的意義
- ACID特性（原子性・一貫性・独立性・永続性）の各要素の本質
- トランザクション分離レベルの設計思想とトレードオフ
- MVCCがどのように「読み取りと書き込みの共存」を実現するか
- PostgreSQLで分離レベルの違いとデッドロックを体験する方法

---

## 1. 口座残高が消えた夜

2008年頃、私は金融系のシステム開発に関わっていた。

正確には、金融系と呼ぶには規模が小さい——中小企業向けの請求管理・入金消込システムだ。だがお金を扱うシステムであることに変わりはない。顧客の口座残高を管理し、入金があれば残高を更新し、請求書と突き合わせて消し込む。至極まっとうな業務アプリケーションだった。

ある深夜、監視アラートが鳴った。「残高不整合検出」。

調べてみると、一つの口座で残高がマイナスになっていた。入金処理と消込処理が同時に走り、片方の更新が他方の更新を上書きしていた。いわゆる「ロストアップデート」だ。2つのプロセスがほぼ同時に同じ口座の残高を読み取り、それぞれが独立に計算した結果を書き戻した。結果として、片方の入金がなかったことになっていた。

原因はすぐに分かった。問題のコードは、残高の読み取りと更新を別々のSQL文で実行しており、その間にトランザクションの保護がなかった。`SELECT`で残高を取得し、アプリケーション側で計算し、`UPDATE`で書き戻す。この一連の操作が一つのトランザクションとして保護されていなかった。

修正は単純だった。`BEGIN`と`COMMIT`で処理を囲み、`SELECT ... FOR UPDATE`で行ロックを取得する。たったそれだけの変更で、問題は解消した。

だが私は考え込んだ。なぜこのバグが本番環境に到達するまで発見されなかったのか。開発環境では同時アクセスがない。テスト環境でも、テスターは一人で順番に操作する。並行処理の問題は、並行処理が実際に起きなければ顕在化しない。そしてデータベースが提供する「トランザクション」という仕組みの意味を、開発チームの誰もが正確には理解していなかった。

トランザクションとは何か。なぜデータベースは「約束を守る」必要があるのか。この問いは、見かけ以上に深い。トランザクションの概念を形式的に定義し、その理論的基盤を築いた人物の名は、Jim Grayという。

---

## 2. Jim Gray——トランザクションに生涯を捧げた人

### 数学者からデータベース研究者へ

Jim Gray（1944年1月12日、サンフランシスコ生まれ）は、トランザクション処理研究の歴史において最も重要な人物の一人だ。

GrayはUC Berkeleyで数学と工学の学士号（1966年）を取得し、同大学でコンピュータサイエンスの博士号を1969年に取得した。これはBerkeleyにおけるCS分野最初の博士号だった。博士論文の後、IBMのポスドクフェロー（1969-1971年）を経て、IBMの研究施設で1971年から1980年まで勤務した。

IBMでのGrayの仕事は、System Rプロジェクトと深く結びついていた。第5回で触れたように、System R（1974-1979年）はIBM San Jose Research LaboratoryでSQLの実装を実証した画期的なプロジェクトだった。Grayはこのプロジェクトにおいて、同時実行制御と障害回復という、相互に関連する2つの問題に対する統一的なアプローチを構築した。

ここで「トランザクション」の概念が、直感的なものから形式的なものへと昇華される。

### 「The Transaction Concept」（1981年）

1981年、GrayはVLDB会議（第7回国際超大規模データベース会議）で論文「The Transaction Concept: Virtues and Limitations」を発表した。この時点でGrayはTandem Computersに移籍しており、フォールトトレラントなコンピュータシステム上でのデータベース運用という、当時の最先端の課題に取り組んでいた。

この論文でGrayは、トランザクションを「状態の変換（transformation of state）」として形式的に定義した。銀行口座間の送金を例にとろう。口座Aから口座Bに10万円を送金する処理は、口座Aの残高を10万円減らし、口座Bの残高を10万円増やす。この2つの操作は不可分でなければならない。片方だけが実行された状態は、データベースとして許容できない。

Grayはトランザクションが持つべき特性を3つ挙げた。原子性（atomicity）——すべてが実行されるか、何も実行されないか。一貫性（consistency）——正しい状態変換であること。永続性（durability）——完了した結果は障害後も生き残ること。

注目すべきは、この1981年の時点ではまだ「ACID」という頭字語は登場していないことだ。Grayは概念を定義したが、名付けは別の研究者の仕事となる。

### ACIDの命名——Haerder & Reuter（1983年）

1983年12月、Theo HaerderとAndreas ReuterがACM Computing Surveysに「Principles of Transaction-Oriented Database Recovery」を発表した。この論文は、トランザクション指向のデータベース回復に関する概念的な枠組みを提供するものだった。

この論文の中で、HaerderとReuterはトランザクションが満たすべき4つの特性を頭字語で整理した。Atomicity（原子性）、Consistency（一貫性）、Isolation（独立性）、Durability（永続性）。ACIDだ。

Grayの1981年論文が提示した3つの特性にIsolation（独立性）を明示的に加え、4要素として体系化したのがHaerderとReuterの貢献だ。Grayの論文でも独立性の概念は暗黙的に含まれていたが、ACIDという明快な頭字語がなければ、この概念はここまで広く浸透しなかったかもしれない。名前の力は大きい。

GrayとReuterは後に共著で『Transaction Processing: Concepts and Techniques』（1993年、Morgan Kaufmann）を執筆している。1986年に1週間のセミナーの準備として書き始めた教材が、最終的に1,000ページを超える教科書に膨れ上がったという。この書籍は今日でもトランザクション処理の決定版として参照される。

### チューリング賞と失踪

1998年、Jim Grayは「データベースおよびトランザクション処理研究への先駆的貢献と、システム実装における技術的リーダーシップ」に対してACMチューリング賞を受賞した。

2007年1月28日、Grayはサンフランシスコ沖のファラロン諸島に向けて、母親の遺灰を撒くための単独航海に出発した。そして帰ってこなかった。米沿岸警備隊による4日間の捜索、その後のテクノロジー業界による前例のない大規模な衛星画像解析キャンペーンにもかかわらず、Grayの40フィートヨット「テナシャス」の痕跡は一切見つからなかった。2012年1月28日、裁判所により法的に死亡が宣告された。

トランザクションに生涯を捧げた研究者が、答えのない消失という形で去ったことには、何か象徴的なものを感じずにはいられない。だがGrayが残したものは確かだ。トランザクションの形式的定義、ロック理論、WAL（Write-Ahead Logging）、二相コミットプロトコル。データベースが「約束を守る」ための理論的基盤は、Grayの仕事の上に成り立っている。

---

## 3. ACID——4つの「約束」を解剖する

ACIDの4つの特性を、一つずつ掘り下げていこう。

### Atomicity（原子性）——全か無か

原子性は、トランザクションの最も直感的な特性だ。トランザクション内の操作は、すべてが成功するか、すべてが失敗するか、どちらかでなければならない。中間状態は外部から見えてはならない。

冒頭の送金の例に戻ろう。口座Aの残高を10万円減らし、口座Bの残高を10万円増やす。もしこの処理の途中でサーバがクラッシュしたら——口座Aの残高は減ったのに口座Bの残高は増えていない——お金が消えたことになる。原子性はこの事態を防ぐ。

```
原子性の保証

トランザクション: 口座Aから口座Bへ10万円送金

  BEGIN TRANSACTION
  ├── UPDATE accounts SET balance = balance - 100000 WHERE id = 'A';
  └── UPDATE accounts SET balance = balance + 100000 WHERE id = 'B';
  COMMIT

正常完了:
  [A: -100,000]  [B: +100,000]  →  両方とも反映

途中でクラッシュ:
  [A: -100,000]  [B: 未実行]    →  ロールバック → 両方とも元に戻る

  中間状態（Aだけ減ってBが増えていない）は決して起きない
```

原子性を実現する技術の核心が、WAL（Write-Ahead Logging）だ。データベースは、データを実際に変更する前に、変更内容をログに書き出す。「先にログを書く」からWrite-Ahead Loggingだ。クラッシュ後の復旧時には、ログを参照して、未完了のトランザクションの変更をすべて取り消す（UNDO）。完了済みだがデータファイルに反映されていないトランザクションの変更は再適用する（REDO）。

WALの概念はIBM System Rプロジェクト（1974-1979年）の中で確立された。Grayらの研究がこの技術の基盤を築き、1983年のHaerder & Reuter論文がWALの役割を体系的に分類した。現在でもほぼすべてのRDBMSがWALに基づく回復メカニズムを採用している。PostgreSQLがWALを本格導入したのはバージョン7.1（2001年）であり、これによりポイントインタイムリカバリやレプリケーションが可能になった。

### Consistency（一貫性）——正しい状態遷移

一貫性は、4つの特性の中で最も誤解されやすい。

ACIDにおけるConsistencyは、トランザクションがデータベースをある正しい状態から別の正しい状態に遷移させることを意味する。ここで「正しい状態」とは、データベースに定義されたすべての制約——主キー制約、外部キー制約、CHECK制約、NOT NULL制約、ユニーク制約——が満たされている状態だ。

先の送金の例で、口座残高にCHECK制約（`balance >= 0`）がかかっていたとしよう。口座Aの残高が5万円しかないのに10万円を送金しようとすると、更新後のAの残高はマイナスになり、CHECK制約に違反する。この場合、トランザクション全体がロールバックされる。

注意すべきは、この「一貫性」はCAP定理における「Consistency」（全ノードが同じデータを返す）とは別の概念だということだ。ACIDのCは「ルール違反を許さない」であり、CAPのCは「全員が同じデータを見る」だ。同じ英単語が異なる文脈で異なる意味を持つことは、この分野で混乱を招く常習犯だ。

もう一点、一貫性の保証にはデータベースだけでなくアプリケーションの責任も含まれる。「送金元と送金先の残高の合計は変わらない」というビジネスルールは、SQL制約だけでは表現しにくい。この種の一貫性は、アプリケーション側で保証する必要がある。ACIDの「C」は、データベースとアプリケーションの共同責任なのだ。

### Isolation（独立性）——見えてはいけないもの

独立性は、4つの特性の中で最も複雑であり、最もパフォーマンスへの影響が大きい。

理想的には、トランザクションは他のトランザクションからの干渉を一切受けないべきだ。複数のトランザクションが同時に実行されても、それぞれが「自分だけがデータベースを使っている」かのように振る舞えること。これが完全な独立性だ。

だが完全な独立性を実現しようとすると、同時に一つのトランザクションしか実行できなくなる。逐次実行だ。それではデータベースの存在意義が失われる。並行処理ができなければ、数千人のユーザーが同時にアクセスするWebアプリケーションは成り立たない。

ここにトレードオフが生まれる。独立性をどこまで緩和するか。この「どこまで」を段階的に定義したのが、トランザクション分離レベルだ。後ほど詳しく掘り下げる。

### Durability（永続性）——約束は守られなければならない

永続性は最もシンプルな概念だ。トランザクションがコミットされたら、その結果は永続的に保持される。サーバがクラッシュしても、電源が落ちても、ディスクが壊れない限り、コミット済みのデータは失われない。

永続性の実現もWALに依存する。トランザクションのコミット時に、変更内容がWALログとしてディスクに書き込まれる（`fsync`によるフラッシュ）。データベースのデータファイル自体はメモリ上のバッファに溜まった状態かもしれないが、WALログがディスク上に確実に書かれていれば、クラッシュ後にログからデータを復元できる。

ここにもトレードオフがある。コミットごとにディスクへのフラッシュ（`fsync`）を行うと、I/O性能がボトルネックになる。PostgreSQLの`synchronous_commit`パラメータを`off`にすると、コミット時のWALフラッシュを遅延させて書き込み性能を向上できるが、クラッシュ時に直近の数百ミリ秒分のコミット済みトランザクションが失われるリスクが生じる。永続性と性能のトレードオフだ。

```
ACIDの4つの特性と実現技術

  ┌─────────────────────────────────────────────────────┐
  │ A: Atomicity（原子性）                              │
  │    「全か無か」                                      │
  │    実現技術: WAL + UNDO/REDO                         │
  ├─────────────────────────────────────────────────────┤
  │ C: Consistency（一貫性）                             │
  │    「正しい状態遷移」                                 │
  │    実現技術: 制約（PK, FK, CHECK, UNIQUE）+          │
  │             アプリケーションロジック                   │
  ├─────────────────────────────────────────────────────┤
  │ I: Isolation（独立性）                               │
  │    「見えてはいけないものを見せない」                   │
  │    実現技術: ロック / MVCC / SSI                      │
  ├─────────────────────────────────────────────────────┤
  │ D: Durability（永続性）                              │
  │    「約束は必ず守る」                                 │
  │    実現技術: WAL + fsync                             │
  └─────────────────────────────────────────────────────┘
```

---

## 4. 分離レベル——「どこまで見せるか」の設計

### 三つの異常現象

トランザクション分離レベルを理解するには、まず「独立性が不十分だと何が起きるか」を知る必要がある。SQL:1992標準は、以下の3つの異常現象（アノマリー）を定義した。

**Dirty Read（ダーティリード）**——未コミットのデータを読む。トランザクションAが行を更新したが、まだコミットしていない。トランザクションBがその未コミットの値を読み取ってしまう。Aがロールバックすると、Bは「存在しないデータ」に基づいて処理を行ったことになる。

**Non-Repeatable Read（非反復読み取り）**——同じクエリが異なる結果を返す。トランザクションAが行を読み取る。その後、トランザクションBがその行を更新してコミットする。トランザクションAが同じ行を再度読み取ると、値が変わっている。

**Phantom Read（ファントムリード）**——存在しなかった行が現れる。トランザクションAが条件付きクエリ（`WHERE salary > 500000`）を実行する。トランザクションBが条件に合致する新しい行を挿入してコミットする。トランザクションAが同じクエリを再実行すると、前にはなかった行が結果に含まれている。

```
3つの異常現象

Dirty Read:
  Tx A:  UPDATE ... (未COMMIT)
  Tx B:  SELECT ...  →  Aの未コミット値を読む（危険!）
  Tx A:  ROLLBACK    →  Bが読んだデータは幻だった

Non-Repeatable Read:
  Tx A:  SELECT salary FROM ... WHERE id=1  →  500,000
  Tx B:  UPDATE salary=600,000 WHERE id=1; COMMIT;
  Tx A:  SELECT salary FROM ... WHERE id=1  →  600,000（変わった!）

Phantom Read:
  Tx A:  SELECT * WHERE salary > 500000  →  3行
  Tx B:  INSERT INTO ... (salary=700000); COMMIT;
  Tx A:  SELECT * WHERE salary > 500000  →  4行（増えた!）
```

### 4つの分離レベル

SQL:1992標準は、これらの異常現象をどこまで許容するかによって、4段階の分離レベルを定義した。

| 分離レベル       | Dirty Read | Non-Repeatable Read | Phantom Read |
| ---------------- | ---------- | ------------------- | ------------ |
| READ UNCOMMITTED | 発生する   | 発生する            | 発生する     |
| READ COMMITTED   | 防止       | 発生する            | 発生する     |
| REPEATABLE READ  | 防止       | 防止                | 発生する     |
| SERIALIZABLE     | 防止       | 防止                | 防止         |

**READ UNCOMMITTED** は最も緩い分離レベルだ。他のトランザクションの未コミットの変更まで見える。実用的にこのレベルを使う場面はほとんどない。PostgreSQLはREAD UNCOMMITTEDを指定しても、内部的にはREAD COMMITTEDとして扱う。

**READ COMMITTED** はPostgreSQLのデフォルト分離レベルだ。コミットされたデータのみが見える。だがトランザクション内で同じクエリを2回実行すると、間に他のトランザクションのコミットが挟まれば、異なる結果が返ることがある。

**REPEATABLE READ** は、トランザクション開始時点のスナップショットを見続ける。トランザクション中にどれだけ他の変更がコミットされても、見える世界は変わらない。PostgreSQLのREPEATABLE READはSnapshot Isolationに基づいており、SQL-92が定義するPhantom Readも防止する。

**SERIALIZABLE** は最も厳格な分離レベルだ。複数のトランザクションが並行実行されても、結果はそれらをある順序で逐次実行した場合と同じになることが保証される。

### Berenson et al.の批判（1995年）

SQL-92の分離レベル定義は、後に不十分であることが指摘された。

1995年、Hal Berenson、Phil Bernstein、Jim Gray、Jim Melton、Elizabeth O'Neil、Patrick O'Neilの6名がACM SIGMOD会議で「A Critique of ANSI SQL Isolation Levels」を発表した。Jim Gray自身がこの論文の共著者であることは示唆的だ。

この論文は、SQL-92の異常現象に基づく分離レベル定義が曖昧であり、いくつかの重要な実装（特にロックベースの実装）を正しく特徴づけられないことを指摘した。そして新しい分離レベルとして**Snapshot Isolation**を定義した。

Snapshot Isolationでは、トランザクションはトランザクション開始時点のデータベースの「スナップショット」を読み取る。書き込みは、コミット時に他のトランザクションとの書き込み競合がないかチェックされ、競合があればアボートされる（First-Committer-Wins）。

Snapshot IsolationはSQL-92の表で定義された3つの異常現象（Dirty Read、Non-Repeatable Read、Phantom Read）をすべて防止する。だがSerializableとは異なる。Write Skew（書き込みスキュー）と呼ばれる異常が発生しうるのだ。

Write Skewの例を挙げよう。医療システムで、「常に1人以上の当直医がいなければならない」という制約があるとする。2人の当直医AとBがそれぞれ同時に「もう1人いるから、自分はシフトを外れよう」と判断する。Snapshot Isolationでは、それぞれのトランザクションが開始時点で「もう1人いる」ことを確認し、自分のシフトを外す。両方のトランザクションがコミットに成功すると、当直医がゼロになる。これがWrite Skewだ。

### PostgreSQLのSerializable Snapshot Isolation（SSI）

PostgreSQL 9.1（2011年）で導入されたSerializable Snapshot Isolation（SSI）は、このWrite Skew問題を解決する。

SSIの基本的なアイデアは、Snapshot Isolationを実行しながら、トランザクション間の読み取り-書き込みの依存関係を監視することだ。「危険な構造」——直列化異常を引き起こしうるトランザクションの組み合わせ——を検出すると、関係するトランザクションの一部をアボートする。

従来の二相ロック（2PL）によるSerializableは、読み取りと書き込みが互いにブロックし合うため、並行性が著しく低下する。SSIでは読み取りが書き込みをブロックせず、書き込みが読み取りをブロックしない。パフォーマンスはSnapshot Isolationとほぼ同等だが、一部のトランザクションがアボートされるリスクがある。

これは「ロックで防ぐ」のではなく「異常を検出して修正する」という楽観的なアプローチだ。多くのワークロードでは衝突はまれであり、楽観的アプローチの方が効率的だ。

---

## 5. MVCC——読み取りと書き込みの共存

### ロックの限界

トランザクションの独立性を実現する最も素朴な方法はロックだ。データを読み取るときは共有ロック（S lock）を取得し、書き込むときは排他ロック（X lock）を取得する。共有ロック同士は共存できるが、排他ロックは他のすべてのロックと競合する。

この方式は正しく動作するが、問題がある。書き込み中のデータを読み取ろうとすると、書き込みが完了するまでブロックされる。逆に読み取り中のデータに書き込もうとしても、読み取りが完了するまでブロックされる。読み取りと書き込みが互いに足を引っ張り合うのだ。

金融系システムで月次レポートを生成する場面を想像してほしい。数百万件のレコードを集計する長いクエリが走っている間、日常の入出金処理が全てブロックされる。これは実用上、許容できない。

### David P. ReedとMVCCの概念

この問題に対する解決策が、MVCC（Multi-Version Concurrency Control、多版型同時実行制御）だ。

MVCCの概念は、David P. Reedの1978年のMIT博士論文「Naming and Synchronization in a Decentralized Computer System」に遡る。Reedは、データの各バージョンを保持することで、読み取りトランザクションと書き込みトランザクションが互いにブロックされない仕組みを提案した。

アイデアは明快だ。データを更新するとき、古いバージョンを消すのではなく、新しいバージョンを追加する。読み取りトランザクションは、自分の開始時点で最新だったバージョンを読む。書き込みトランザクションが新しいバージョンを作成中でも、読み取りトランザクションは古いバージョンを読めば済む。ブロックは発生しない。

```
MVCCの仕組み（概念図）

時刻 T1: Tx A が row X を読み取り開始

  row X: [version 1: value=100, 有効期間 T0〜∞]

時刻 T2: Tx B が row X を更新（value=200）

  row X: [version 1: value=100, 有効期間 T0〜T2]
         [version 2: value=200, 有効期間 T2〜∞]

時刻 T3: Tx A が row X を再度読み取り

  Tx A は T1 時点のスナップショットを使用
  → version 1（value=100）を読む（version 2 は見えない）

結果: Tx A はブロックされず、一貫したデータを読み取れる
      Tx B もブロックされず、更新を完了できる
```

### 商用実装の系譜

MVCCの最初の商用実装は、Jim Starkeyが手がけたDEC VAX Rdb/ELN（1984年）とされる。StarkeyはさらにInterBase（1981年に実装開始）でもMVCCを実装した。InterBaseは後にオープンソース化され、Firebirdとして今日も存続している。

Oracleは独自のMVCC実装を持つ。第6回で触れたように、OracleはUndoセグメントを用いて変更前の値を保持し、読み取りトランザクションに一貫したビューを提供する。StonebrakerのPOSTGRES（1985年〜）もマルチバージョンの概念を取り入れていた。

現代のRDBMSにおいて、MVCCは事実上の標準だ。PostgreSQL、MySQL（InnoDB）、Oracle、SQL Serverのすべてが何らかのMVCC実装を持っている。「読み取りが書き込みをブロックしない」というMVCCの基本原則は、Webアプリケーションのように読み取りが圧倒的に多いワークロードにおいて、不可欠な性質となった。

### PostgreSQLのMVCC実装

PostgreSQLのMVCC実装は他のRDBMSとは異なるアプローチを取る。

OracleやMySQLがUndoログ（変更前の値を別領域に保存）を使うのに対し、PostgreSQLはテーブル自体に複数バージョンの行を保持する。各行にはトランザクションIDベースの可視性情報（`xmin`、`xmax`）が付与され、トランザクションはこの情報を参照して、自分にとって「見える」バージョンを判定する。

この設計にはトレードオフがある。利点は、Undoログの管理が不要であり、ロールバックが高速なことだ。欠点は、古いバージョンの行がテーブル内に蓄積され、定期的な清掃（VACUUM）が必要になることだ。VACUUMはPostgreSQLの運用における最大の関心事の一つであり、autovacuumの適切な設定はPostgreSQL管理者の必須スキルだ。

### 楽観的ロック vs 悲観的ロック

MVCCと関連して、アプリケーション設計レベルでのロック戦略にも触れておきたい。

**悲観的ロック（Pessimistic Locking）** は、「衝突が起きるだろう」と仮定し、データにアクセスする前にロックを取得する。`SELECT ... FOR UPDATE`がその典型だ。確実に衝突を防げるが、並行性が低下する。

**楽観的ロック（Optimistic Locking）** は、「衝突はめったに起きないだろう」と仮定し、ロックなしで読み取り・更新を行う。更新時にバージョン番号やタイムスタンプを確認し、他のトランザクションが先に更新していたら、自分の更新を中止して再試行する。

```sql
-- 楽観的ロックの例（バージョン番号方式）
-- 読み取り時
SELECT id, name, balance, version FROM accounts WHERE id = 1;
-- → id=1, name='Alice', balance=500000, version=3

-- 更新時（versionが変わっていないことを確認）
UPDATE accounts SET balance = 400000, version = 4
WHERE id = 1 AND version = 3;
-- → 1 row updated（成功）
-- → 0 rows updated（他のトランザクションが先に更新 → 再試行が必要）
```

楽観的ロックは衝突がまれなワークロード（一般的なWebアプリケーションの大部分）で効率的だ。一方、衝突が頻発する状況では再試行コストが積み重なり、悲観的ロックの方が適する。選択は「衝突の頻度」に依存する。

### デッドロック——ロックの罠

ロックを使う以上、デッドロックは避けられない。

デッドロックとは、2つ以上のトランザクションが互いに相手のロック解放を待ち合い、いずれも進行できなくなる状態だ。

```
デッドロックの発生

  Tx A: 行1をロック → 行2のロックを待つ
  Tx B: 行2をロック → 行1のロックを待つ

  → 互いに相手を待ち、永遠に進行しない
```

データベースはデッドロックを検出するために、待ちグラフ（wait-for graph）を構築する。トランザクション間の「待っている」関係を有向グラフで表現し、グラフ内に閉路（サイクル）が存在すればデッドロックと判定する。検出されると、データベースは関係するトランザクションの一つを選んでアボート（ロールバック）し、デッドロックを解消する。

PostgreSQLはデッドロック検出を即座には行わない。まず`deadlock_timeout`パラメータ（デフォルト1秒）で指定された時間だけ待ち、その時点でまだロックが取得できなければ、初めて待ちグラフを構築してデッドロックを検出する。この遅延は、短時間で自然に解消されるロック待ちに対して、不要な検出処理のオーバーヘッドを避けるための設計だ。

デッドロックは「バグ」ではない。ロックに基づく同時実行制御の構造的な帰結だ。アプリケーション側でできることは、デッドロック発生時のリトライロジックを実装すること、そしてロック取得の順序を統一してデッドロックの発生確率を下げることだ。

---

## 6. ハンズオン: トランザクション分離レベルとデッドロックを体験する

今回のハンズオンでは、PostgreSQLでトランザクション分離レベルの違いを観察し、デッドロックを意図的に発生させる。

### 演習概要

1. READ COMMITTEDとREPEATABLE READの挙動差を確認する
2. Dirty Read（のブロック）を観察する
3. Non-Repeatable Readの発生と防止を体験する
4. デッドロックを意図的に発生させて解消する

### 環境構築

Docker環境でPostgreSQLを起動する。

```bash
# handson/database-history/07-acid-transactions/setup.sh を実行
bash setup.sh
```

### 演習1: READ COMMITTEDの挙動

2つのターミナルを開き、同じPostgreSQLに接続する。

```bash
# ターミナル1, ターミナル2 共通
docker exec -it db-history-ep07-pg psql -U postgres -d handson
```

```sql
-- === ターミナル1 ===
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- 口座Aの残高を確認
SELECT * FROM accounts WHERE account_id = 'A001';
-- → balance = 1000000（100万円）
```

```sql
-- === ターミナル2 ===
-- 口座Aに入金（ターミナル1のトランザクション実行中に）
BEGIN;
UPDATE accounts SET balance = balance + 500000 WHERE account_id = 'A001';
COMMIT;
```

```sql
-- === ターミナル1（続き） ===
-- 同じクエリを再度実行
SELECT * FROM accounts WHERE account_id = 'A001';
-- → balance = 1500000（150万円に変わっている!）
-- READ COMMITTEDでは、他のトランザクションのCOMMIT後のデータが見える
COMMIT;
```

READ COMMITTEDでは、トランザクション内で同じクエリを2回実行しても、その間に他のトランザクションがコミットすれば結果が変わる。これがNon-Repeatable Readだ。

### 演習2: REPEATABLE READによる防止

```sql
-- === ターミナル1 ===
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT * FROM accounts WHERE account_id = 'A001';
-- → balance = 1500000
```

```sql
-- === ターミナル2 ===
BEGIN;
UPDATE accounts SET balance = balance - 200000 WHERE account_id = 'A001';
COMMIT;
```

```sql
-- === ターミナル1（続き） ===
SELECT * FROM accounts WHERE account_id = 'A001';
-- → balance = 1500000（変わっていない!）
-- REPEATABLE READでは、トランザクション開始時のスナップショットが維持される
COMMIT;
```

REPEATABLE READでは、トランザクション開始時点のスナップショットが一貫して読み取られる。他のトランザクションがコミットした変更は見えない。これがSnapshot Isolationの効果だ。

### 演習3: REPEATABLE READでの更新競合

```sql
-- === ターミナル1 ===
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM accounts WHERE account_id = 'A001';
-- → balance = 1300000
```

```sql
-- === ターミナル2 ===
BEGIN;
UPDATE accounts SET balance = balance + 100000 WHERE account_id = 'A001';
COMMIT;
```

```sql
-- === ターミナル1（続き） ===
-- 同じ行を更新しようとすると...
UPDATE accounts SET balance = balance - 50000 WHERE account_id = 'A001';
-- ERROR: could not serialize access due to concurrent update
-- PostgreSQLのREPEATABLE READでは、他のトランザクションが
-- 先にコミットした行を更新しようとするとエラーになる
ROLLBACK;
```

この挙動は、PostgreSQLのREPEATABLE READが内部的にSnapshot Isolationとして実装されていることの直接的な現れだ。First-Committer-Wins——先にコミットしたトランザクションが勝ち、後から更新しようとしたトランザクションはアボートされる。

### 演習4: デッドロックの発生と解消

```sql
-- === ターミナル1 ===
BEGIN;
-- 口座A001のロックを取得
UPDATE accounts SET balance = balance - 100000 WHERE account_id = 'A001';
-- 次に口座A002を更新したいが、まだ実行しない
```

```sql
-- === ターミナル2 ===
BEGIN;
-- 口座A002のロックを取得
UPDATE accounts SET balance = balance - 100000 WHERE account_id = 'A002';
-- 口座A001を更新しようとする → ターミナル1がロック中なので待ち状態
UPDATE accounts SET balance = balance + 100000 WHERE account_id = 'A001';
-- （ブロックされる）
```

```sql
-- === ターミナル1（続き） ===
-- 口座A002を更新しようとする → ターミナル2がロック中
UPDATE accounts SET balance = balance + 100000 WHERE account_id = 'A002';
-- → しばらく待つと...
-- ERROR: deadlock detected
-- DETAIL: Process ... waits for ShareLock on transaction ...;
--         blocked by process ...
-- HINT: See server log for query details.
```

PostgreSQLがデッドロックを検出し、片方のトランザクション（通常は最近のもの）をアボートした。もう片方のトランザクションはブロックから解放され、処理を続行できる。

```sql
-- === ターミナル1 ===
ROLLBACK;  -- デッドロックでアボートされたのでROLLBACK

-- === ターミナル2 ===
COMMIT;  -- こちらは正常に完了
```

### 後片付け

```bash
docker rm -f db-history-ep07-pg
```

---

## 7. ACIDの「約束」の重さ

第7回を振り返ろう。

**トランザクションの概念は、Jim Grayの研究によって形式的に定義された。** 1981年のVLDB論文で、Grayはトランザクションを状態変換の単位として定義し、原子性・一貫性・永続性の特性を示した。1983年、HaerderとReuterがIsolation（独立性）を加えて4要素とし、ACID頭字語を生み出した。

**ACIDの4つの特性は、それぞれが異なる技術で実現される。** 原子性と永続性はWAL（Write-Ahead Logging）に基づく。一貫性はデータベース制約とアプリケーションの共同責任だ。独立性は最も複雑で、ロック、MVCC、SSIといった技術が重層的に組み合わされる。

**トランザクション分離レベルは、独立性とパフォーマンスのトレードオフを段階的に設計したものだ。** SQL:1992標準は4段階の分離レベルを定義したが、1995年のBerenson et al.の論文がその不備を指摘し、Snapshot Isolationを定式化した。PostgreSQL 9.1（2011年）のSSIは、Snapshot Isolationの性能を維持しつつ真のSerializableを実現する画期的な実装だ。

**MVCCは「読み取りが書き込みをブロックしない」という原則を実現し、現代のRDBMSの基盤となっている。** David P. Reedの1978年の博士論文に概念が遡り、1980年代に商用実装が始まった。PostgreSQLはテーブル内にバージョンを保持するユニークな実装を採用し、VACUUMによる清掃が運用上の重要課題となっている。

冒頭の問いに戻ろう。「トランザクションとは何か？ なぜデータベースは『約束を守る』必要があるのか？」

トランザクションとは、データベースの状態を安全に変更するための「契約」だ。原子性は「中途半端にしない」という約束。一貫性は「ルールを破らない」という約束。独立性は「他人の途中を見せない」という約束。永続性は「忘れない」という約束。

この4つの約束は当たり前に聞こえる。だが当たり前を保証するための技術——WAL、MVCC、SSI、デッドロック検出——は、50年にわたる研究の積み重ねの上に成り立っている。`BEGIN`と`COMMIT`の間で起きていることの背後には、Jim Grayが生涯をかけて築いた理論体系がある。

だが、この「約束」は無料ではない。ACIDを完璧に守ろうとすると、パフォーマンスが犠牲になる。特に分散システムにおいては、強い一貫性と高い可用性を同時に実現することが原理的に不可能であることが証明されている。ACIDの「約束」を部分的に緩和し、代わりにスケーラビリティを手に入れようとする動き——それがNoSQL革命であり、CAP定理が描く世界だ。

次回は、RDBの黄金期を象徴する戦い——MySQL vs PostgreSQLを取り上げる。Web時代にMySQLが勝利した理由、PostgreSQLが「知る人ぞ知る存在」だった時代、そして現在の勢力図が逆転しつつある背景を掘り下げる。

あなたのプロジェクトでは、トランザクション分離レベルを意識して設定しているだろうか。デフォルトのREAD COMMITTEDで本当に十分だろうか。その判断ができるかどうかは、ACIDの「約束」の重さを理解しているかどうかにかかっている。

---

### 参考文献

- Jim Gray, "The Transaction Concept: Virtues and Limitations", VLDB 1981. <https://jimgray.azurewebsites.net/papers/thetransactionconcept.pdf>
- Theo Haerder, Andreas Reuter, "Principles of Transaction-Oriented Database Recovery", ACM Computing Surveys, Vol.15, No.4, 1983. <https://dl.acm.org/doi/10.1145/289.291>
- Jim Gray, Andreas Reuter, "Transaction Processing: Concepts and Techniques", Morgan Kaufmann, 1993.
- Hal Berenson, Phil Bernstein, Jim Gray, Jim Melton, Elizabeth O'Neil, Patrick O'Neil, "A Critique of ANSI SQL Isolation Levels", ACM SIGMOD 1995. <https://dl.acm.org/doi/10.1145/223784.223785>
- David P. Reed, "Naming and Synchronization in a Decentralized Computer System", MIT PhD Dissertation, 1978.
- Dan R. K. Ports, Kevin Grittner, "Serializable Snapshot Isolation in PostgreSQL", VLDB Endowment, 2012. <https://dl.acm.org/doi/10.14778/2367502.2367523>
- ACM, "Jim Gray - A.M. Turing Award Laureate". <https://amturing.acm.org/award_winners/gray_3649936.cfm>
- Wikipedia, "Jim Gray (computer scientist)". <https://en.wikipedia.org/wiki/Jim_Gray_(computer_scientist)>
- Wikipedia, "Multiversion concurrency control". <https://en.wikipedia.org/wiki/Multiversion_concurrency_control>
- Wikipedia, "Write-ahead logging". <https://en.wikipedia.org/wiki/Write-ahead_logging>
- PostgreSQL Documentation, "Transaction Isolation". <https://www.postgresql.org/docs/current/transaction-iso.html>
- PostgreSQL Documentation, "Write-Ahead Logging (WAL)". <https://www.postgresql.org/docs/current/wal-intro.html>

---

**次回予告：** 第8回「MySQL vs PostgreSQL——Web時代のRDB戦争」では、LAMPスタック全盛期にMySQLが「勝者」となった背景、PostgreSQLの長い雌伏の時、そして2010年代以降の勢力逆転を検証する。MyISAM vs InnoDB、レプリケーション、VACUUMの功罪まで、2つのOSS RDBMSの設計思想の違いに迫る。
