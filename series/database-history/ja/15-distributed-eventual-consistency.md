# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第15回：Cassandra, DynamoDB——分散と結果整合性の世界

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 2007年のAmazon Dynamo論文が提示した「可用性を最優先する」分散アーキテクチャの設計思想
- FacebookがDynamoとBigtableのハイブリッドとして開発したCassandraの起源と進化
- Consistent Hashing、Vector Clocks、Quorumという三つの基盤技術の仕組みと意義
- DynamoDBの「プロビジョニングされたキャパシティ」モデルとスロットリングの現実
- CassandraとDynamoDBにおける「クエリファースト」のデータモデリング手法
- 3ノードCassandraクラスタで一貫性レベルを変えた読み書きの挙動を体験するハンズオン

---

## 1. 「絶対に落ちない」の代償

2016年頃、私はあるプロジェクトでAmazon DynamoDBを初めて使った。

それまでの私のデータベース経験は、MySQL、PostgreSQLというRDBの世界が中心だった。第13回で触れたRedisはキャッシュ層として使っていたし、第14回のMongoDBにも手を出して痛い目に遭っていた。だがDynamoDBは、それらとはまったく異なる思考を要求してきた。

最初の壁は「プロビジョニングされたキャパシティ」という概念だった。

RDBでは、テーブルを作ればクエリを投げられる。1秒に100回投げようが1000回投げようが、サーバの性能が許す限りクエリは処理される。遅くなることはあっても、「拒否」されることはない。だがDynamoDBは違った。テーブル作成時に「読み取りキャパシティユニット」と「書き込みキャパシティユニット」を指定しなければならない。そしてそのキャパシティを超えたリクエストは、スロットリング——つまりリクエスト拒否——される。

これは当時の私にとって衝撃だった。データベースがリクエストを「拒否」する？ リトライすれば通るかもしれないが、通らないかもしれない。キャパシティの見積もりを間違えれば、ピーク時にアプリケーションがエラーを返す。RDBの世界では「遅い」がスロットリングの代わりだった。DynamoDBの世界では「遅い」の代わりに「拒否」がある。

さらに困惑したのが、Global Secondary Index（GSI）のスロットリングだ。ベーステーブルのキャパシティには余裕があるのに、GSIのキャパシティが不足すると、ベーステーブルへの書き込みまでスロットリングされる。バックプレッシャーと呼ばれるこの現象に初めて遭遇したとき、原因の特定に丸一日かかった。CloudWatchのメトリクスを睨みながら、「なぜベーステーブルの書き込みが拒否されるのか」を追い続けた。

だが、DynamoDBの思想を理解するにつれて、スロットリングは「欠陥」ではなく「設計判断」だと気づいた。DynamoDBは「絶対に落ちない」ことを最優先に設計されている。個々のリクエストが拒否されても、システム全体は動き続ける。RDBが「すべてのリクエストを受け入れるが、負荷で全体が遅くなる（あるいは落ちる）」という設計であるのに対し、DynamoDBは「システム全体の安定性を守るために、個々のリクエストを犠牲にする」という設計だ。

この設計思想の根源は、2007年に発表された一本の論文にある。

あなたが今使っているデータベース——PostgreSQLでもMySQLでもMongoDBでもいい——が「落ちた」経験はあるだろうか。その障害の原因は何だっただろうか。「絶対に落ちない」を実現するために、何を犠牲にすべきだと考えるだろうか。

---

## 2. Amazon Dynamo論文——可用性至上主義の設計書

### 「常に書き込める」という至上命題

2007年10月、AmazonはSOSP（21st ACM Symposium on Operating Systems Principles）において、一本の論文を発表した。「Dynamo: Amazon's Highly Available Key-value Store」——Giuseppe DeCandia、Werner Vogelsら9名の共著である。

この論文は、Amazonが社内で運用していた分散Key-Valueストア「Dynamo」の設計と実装を詳細に記述したものだ。論文の冒頭で、著者らはAmazonのビジネス要件を明確にしている。Amazonのeコマースプラットフォームでは、「カートに入れる」操作が常に成功しなければならない。サーバ障害やネットワーク分断が発生しても、顧客がカートに商品を追加できなくなることは許されない。わずかな障害が直接的な売上損失に繋がるからだ。

この要件は、従来のRDBの設計思想とは根本的に異なる優先順位を要求した。RDBは一貫性（Consistency）を最優先とする。トランザクションのACID特性が示すように、データの正しさを保証することが最も重要だ。だがAmazonが求めたのは、一貫性よりも可用性（Availability）だった。データが一時的に不整合であっても、システムが常にリクエストを受け付け、応答を返すことが最優先だ。

第12回で取り上げたCAP定理の文脈で言えば、Dynamoは明確にAP（Availability + Partition Tolerance）側に立つ設計だ。ネットワーク分断が発生した場合、一貫性を犠牲にしてでも可用性を維持する。

### Dynamo論文が統合した技術群

Dynamo論文の革新性は、個々の技術の発明にあるのではない。既存の分散システム技術を統合し、実際の本番環境で動く一つのシステムとして構築したことにある。論文が採用した主要技術を整理しよう。

```
Dynamo論文が統合した技術群

┌──────────────────────────────────────────────────────┐
│  課題                    採用した技術                   │
│                                                      │
│  データの分散配置        Consistent Hashing            │
│   → どのノードにデータを配置するか                     │
│                                                      │
│  高可用性の書き込み      Sloppy Quorum +               │
│                         Hinted Handoff                │
│   → 一部のノードが落ちても書き込みを継続               │
│                                                      │
│  競合の検出              Vector Clocks                 │
│   → 同じデータへの並行更新を検出する                   │
│                                                      │
│  競合の解決              アプリケーション側の            │
│                         セマンティック解決              │
│   → 「最後の書き込みが勝つ」ではなく                   │
│     アプリケーションが判断する                         │
│                                                      │
│  レプリカ間の同期        Anti-Entropy Protocol         │
│                         (Merkle Trees)                │
│   → バックグラウンドでレプリカの差分を検出・修復        │
│                                                      │
│  障害検出               Gossip Protocol                │
│   → ノード間で互いの死活情報を交換する                 │
└──────────────────────────────────────────────────────┘
```

これらの技術の中から、特に重要な三つ——Consistent Hashing、Vector Clocks、Quorum——について深掘りする。

### Consistent Hashing——ノード追加・削除に耐える分散

Consistent Hashingは、1997年にMITのDavid Kargerらが発表した手法だ。論文タイトルは「Consistent Hashing and Random Trees: Distributed Caching Protocols for Relieving Hot Spots on the World Wide Web」（STOC 1997）。

通常のハッシュによる分散を考えてみよう。N台のノードがあるとき、データのキーをハッシュし、`hash(key) % N` でノードを決定する。この方式は単純だが、致命的な弱点がある。ノードが1台追加または削除されると、Nの値が変わり、ほぼすべてのデータの配置先が変わる。大量のデータ移動（リバランシング）が発生し、その間システムは不安定になる。

Consistent Hashingはこの問題を解決する。

```
Consistent Hashing の概念図

                    0
                ┌───────┐
            ┌───┤       ├───┐
           ╱    └───────┘    ╲
         ╱                     ╲
    ┌───────┐               ┌───────┐
    │Node A │               │Node C │
    └───────┘               └───────┘
         ╲                     ╱
           ╲    ┌───────┐    ╱
            └───┤Node B ├───┘
                └───────┘

  ハッシュリング上にノードを配置する。
  データのキーもハッシュして同じリング上にマッピングする。
  データは、リング上で時計回りに最初に見つかるノードに格納される。

  ノード追加時:
    → 新ノードの担当範囲のデータのみ移動する
    → 他のノードのデータは影響を受けない

  ノード削除時:
    → 削除されたノードのデータは次のノードに引き継がれる
    → 他のノードのデータは影響を受けない
```

ノードの追加・削除時に移動するデータは全体の `1/N` だけだ。これは `hash(key) % N` 方式で「ほぼすべて」のデータが移動するのとは対照的である。

Dynamo論文では、さらに「仮想ノード（Virtual Nodes）」の概念を導入した。物理ノード1台に対して複数の仮想ノードをリング上に配置することで、データの分布を均等化し、ノードの性能差にも対応できる。

### Vector Clocks——分散環境での因果関係の追跡

分散システムにおいて、「どちらの書き込みが新しいか」を判断するのは簡単ではない。各ノードの物理時計はずれている。NTP（Network Time Protocol）で同期しても、ミリ秒単位のずれは避けられない。

この問題に対する古典的な解法がVector Clocks（ベクトル時計）だ。1978年にLeslie Lamportが論理時計（Lamport Clock）の概念を提案し、1988年にColin FidgeとFriedemann Matternが独立にベクトル時計へ一般化した。

Vector Clocksは、各ノードの書き込み回数をベクトルとして保持する。

```
Vector Clocks による因果関係の追跡

初期状態: データ D のVector Clock = {}

1. Node A が D を書き込む
   D = "value1", VC = {A:1}

2. Node B が D を読み取り（VC = {A:1}）、更新する
   D = "value2", VC = {A:1, B:1}

3. Node C が D を読み取り（VC = {A:1}）、別の値に更新する
   D = "value3", VC = {A:1, C:1}

  ここで競合が検出される:
    VC {A:1, B:1} と VC {A:1, C:1} は
    どちらも相手の「後」ではない（並行している）
    → アプリケーションに競合解決を委ねる

比較ルール:
  VC1 ≤ VC2 ⟺ VC1の全要素がVC2以下
    {A:1, B:1} ≤ {A:1, B:2}  → VC2はVC1の後（上書き可能）
    {A:1, B:1} と {A:1, C:1} → 比較不能（並行＝競合）
```

Dynamo論文では、競合が検出された場合、アプリケーション側でセマンティック解決を行う設計を採用した。Amazonのショッピングカートの場合、二つのカートが競合したら、両方のアイテムを統合（ユニオン）する。商品が余分にカートに入る可能性はあるが、商品が消える可能性はない。可用性を最優先するAmazonの思想が、競合解決のポリシーにまで反映されている。

### Quorum——一貫性のダイヤルを回す

Quorum（定足数）は、分散システムにおける一貫性と可用性のバランスを調整する仕組みだ。

3つのパラメータで制御する。N（レプリカ数）、R（読み取り時に応答を待つノード数）、W（書き込み時に応答を待つノード数）。

```
Quorum の仕組み（N = 3 の場合）

■ 強一貫性の条件: R + W > N

  例: R=2, W=2, N=3 → 2 + 2 = 4 > 3 ✓
  読み取りQuorumと書き込みQuorumが必ず1つ以上のノードで重なる
  → 最新のデータが必ず読み取られる

  書き込み時:                    読み取り時:
  ┌──────┐  W=2               ┌──────┐  R=2
  │Node 1│  ← 書き込みOK      │Node 1│  ← 読み取り（古い値）
  │Node 2│  ← 書き込みOK      │Node 2│  ← 読み取り（最新値）★
  │Node 3│  ← 未到達          │Node 3│  ← 読み取り不要
  └──────┘                    └──────┘
  2ノードからOKを受け取った     2ノードから応答を受け取った
  時点で書き込み成功            → 最新値を含む応答がある

■ 結果整合性: R + W ≤ N

  例: R=1, W=1, N=3 → 1 + 1 = 2 ≤ 3
  読み取り時に古いデータが返る可能性がある
  → 高速だがデータの「新しさ」は保証されない
```

Dynamo論文では、これをさらに発展させた「Sloppy Quorum」を採用した。通常のQuorumでは、あらかじめ決められたN個のレプリカノードからR個（またはW個）の応答を待つ。だがSloppy Quorumでは、本来のレプリカノードが利用不可の場合、一時的に別のノードが代理で書き込みを受け付ける（Hinted Handoff）。障害が復旧したら、代理ノードからオリジナルのノードにデータを転送する。

これにより、ノード障害時でも書き込みが成功する確率が飛躍的に高まる。代償として、一貫性の保証は通常のQuorumより弱くなる。

---

## 3. Cassandra——DynamoとBigtableのハイブリッド

### Facebookの受信箱検索問題

2007年、Facebookは急激なユーザー増加のなかで、受信箱検索機能のスケーラビリティに苦しんでいた。数億人のユーザーが送受信するメッセージを検索可能にするには、大量の書き込みを処理し、複数のデータセンターに分散し、単一障害点がなく、低レイテンシで応答するデータストアが必要だった。

この課題に取り組んだのが、Avinash LakshmanとPrashant Malikだ。LakshmanはAmazon Dynamo論文の共著者でもある。彼はDynamoの分散技術——Consistent Hashing、レプリケーション、Gossipプロトコル——を熟知していた。同時に、GoogleのBigtable論文（2006年、OSDI）が提示したカラムファミリというデータモデルの表現力にも注目していた。

CassandraはこのDynamoとBigtableのハイブリッドとして設計された。Dynamoからは分散アーキテクチャ——マスタレスのP2P構成、Consistent Hashing、Gossipプロトコル——を、Bigtableからはデータモデル——カラムファミリ、ソート済みのカラム、SuperColumn——を受け継いだ。

Cassandraという名前は、ギリシャ神話のトロイの予言者カサンドラに由来する。カサンドラは真実を語るが誰にも信じてもらえないという呪いをかけられた人物だ。Facebookの開発者がなぜこの名前を選んだかについて公式な説明はないが、分散システムにおいて「データの真実」を伝えることの困難さを暗示しているとも解釈できる。

### オープンソース化とApacheプロジェクト

2008年7月、FacebookはCassandraをGoogle Codeでオープンソースとして公開した。2009年3月にApache Incubatorプロジェクトとなり、2010年2月にApacheトップレベルプロジェクトに昇格した。

Facebookからの独立後、Cassandraは急速にコミュニティを拡大した。DataStax社（2010年設立）がCassandraの商用サポートとツーリングを提供し、エンタープライズ採用を後押しした。Netflix、Apple、Spotify、Instagramなど、大規模なデータ処理を必要とする企業がCassandraを採用した。特にNetflixは、AWS上でのCassandra大規模運用のノウハウをオープンソースとして公開し、コミュニティに大きな貢献をした。

### Cassandraのアーキテクチャ——マスタレス分散

CassandraとRDBの最も大きな違いは、マスタレス（Masterless）アーキテクチャだ。

```
RDB（MySQL）のマスタ・スレーブ構成 vs Cassandraのマスタレス構成

■ MySQL: マスタ・スレーブ構成
  ┌──────────┐
  │  Master  │  ← 書き込みはここだけ
  └────┬─────┘
       │ レプリケーション
  ┌────┴─────┐
  │          │
┌─┴──────┐ ┌─┴──────┐
│ Slave 1│ │ Slave 2│  ← 読み取り専用
└────────┘ └────────┘
  問題: Masterが落ちると書き込み不能
  → フェイルオーバーに時間がかかる

■ Cassandra: マスタレス（ピアツーピア）構成
  ┌────────┐    ┌────────┐
  │ Node 1 │────│ Node 2 │
  └───┬────┘    └────┬───┘
      │    Gossip    │
  ┌───┴────┐    ┌────┴───┐
  │ Node 3 │────│ Node 4 │
  └────────┘    └────────┘
  すべてのノードが同等（ピア）
  どのノードにも読み書き可能
  → 単一障害点がない
```

RDBのマスタ・スレーブ構成では、マスタが単一障害点になる。マスタが落ちれば書き込みは停止し、フェイルオーバー（スレーブの一台をマスタに昇格させる処理）が完了するまで数秒から数分のダウンタイムが発生する。

Cassandraでは、すべてのノードが同等のピアだ。クライアントはどのノードにも接続でき、接続先のノード（コーディネータ）がリクエストを適切なレプリカノードに振り分ける。あるノードが落ちても、他のノードがリクエストを処理する。

### Cassandraのデータモデル——パーティションキーとクラスタリングキー

Cassandraのデータモデルは、RDBのそれとは根本的に異なる思想に基づいている。

RDBでは、正規化されたスキーマを設計し、そのスキーマに対してさまざまなクエリを投げる。スキーマが先、クエリが後だ。

Cassandraでは逆だ。まずアクセスパターン（どのようなクエリが必要か）を定義し、そのクエリに最適化されたテーブル設計を行う。これが「クエリファースト」のデータモデリングだ。

Cassandraの主キーは二つの要素から構成される。パーティションキー（Partition Key）とクラスタリングキー（Clustering Key）だ。

```
Cassandraの主キーの構造

PRIMARY KEY ((partition_key), clustering_key1, clustering_key2, ...)
             ^^^^^^^^^^^^^^^^  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
             データの分散を決定   パーティション内のソート順を決定

例: ユーザーのタイムライン投稿

CREATE TABLE user_posts (
    user_id UUID,
    posted_at TIMESTAMP,
    post_id UUID,
    content TEXT,
    PRIMARY KEY ((user_id), posted_at, post_id)
) WITH CLUSTERING ORDER BY (posted_at DESC);

パーティションキー: user_id
  → 同じユーザーの投稿は同じノードに格納される

クラスタリングキー: posted_at, post_id
  → パーティション内で投稿日時の降順にソートされる

クエリ:
  SELECT * FROM user_posts
    WHERE user_id = ?
    ORDER BY posted_at DESC
    LIMIT 20;
  → 特定ユーザーの最新20投稿を1回のクエリで取得
  → パーティションキーで対象ノードを特定し、
    クラスタリングキーのソート順でデータを返す
```

パーティションキーは、データがどのノードに格納されるかを決定する。同じパーティションキーを持つすべての行は、同じノードに格納される。Consistent Hashingによってパーティションキーのハッシュ値からノードが決まる。

クラスタリングキーは、パーティション内でのデータの物理的なソート順を決定する。ディスク上でデータがソートされた状態で格納されるため、範囲クエリが高速に処理される。

この設計は、RDBのインデックスとは異なるアプローチだ。RDBではデータをまず格納し、必要に応じてインデックスを作成する。Cassandraではテーブル設計の時点で、データの物理的配置がクエリパターンに最適化されている。

### Cassandraの一貫性レベル

Cassandraは、Quorumの考え方を「一貫性レベル（Consistency Level）」として抽象化し、クエリごとに指定できるようにした。

```
Cassandraの主な一貫性レベル（レプリカ数 N = 3 の場合）

レベル       書き込み時の挙動            読み取り時の挙動
─────────────────────────────────────────────────────────
ONE          1ノードに書けたら成功       1ノードから読めたら成功
             → 最速、だが不整合の可能性  → 古いデータが返る可能性

QUORUM       (3/2+1)=2ノードに           2ノードから読めたら成功
             書けたら成功                → R+W > N を満たし
             → バランス型                  強一貫性に近い

ALL          3ノード全部に書けたら成功   3ノード全部から読めたら成功
             → 最も安全、だが最遅         → 1ノードでも落ちると失敗
             → 可用性が犠牲になる

LOCAL_QUORUM 同一データセンター内で      同一データセンター内で
             Quorumを達成すれば成功      Quorumを達成すれば成功
             → マルチDC環境でのバランス

EACH_QUORUM  全データセンターで           全データセンターで
             Quorumを達成すれば成功       Quorumを達成すれば成功
             → 最も厳格なマルチDC設定
```

この設計の巧妙さは、一貫性と可用性のトレードオフをアプリケーション開発者が「クエリ単位で」制御できることだ。同じアプリケーション内で、ユーザープロフィールの読み取りには`ONE`（速度重視）を使い、決済関連のデータには`QUORUM`（整合性重視）を使う、という使い分けが可能になる。

---

## 4. DynamoDB——マネージドサービスとしての分散データベース

### Dynamo論文からDynamoDBへ

ここで混同しやすい重要な点を整理しておく。Amazon Dynamo（2007年の論文）とAmazon DynamoDB（2012年のサービス）は別物だ。

Dynamoは、Amazon社内で運用されていた分散Key-Valueストアだ。Consistent Hashing、Vector Clocks、Sloppy Quorumなどの技術を統合した研究的プロジェクトであり、社外には提供されなかった。

DynamoDBは、2012年1月18日にAWSが一般提供を開始したフルマネージドNoSQLデータベースサービスだ。Dynamo論文の思想——可用性の優先、水平スケーラビリティ——を受け継いでいるが、アーキテクチャは大きく異なる。DynamoDBはVector Clocksの代わりにLast Writer Wins（最後の書き込みが勝つ）を採用し、アプリケーション側での競合解決を不要にした。Sloppy Quorumの代わりに、AWSのインフラストラクチャ上で自動的にデータを3箇所にレプリケートする。

Werner Vogels（Amazon CTO）は、DynamoDBの発表において「Amazonは15年以上にわたってデータベースのスケーラビリティ、パフォーマンス、コスト効率の課題に取り組んできた。DynamoDBはその集大成だ」と述べた。

### DynamoDBのデータモデル——パーティションキーとソートキー

DynamoDBのデータモデルは、Cassandraと概念的に似ている。テーブルの主キーは、パーティションキー（Partition Key）のみ、またはパーティションキーとソートキー（Sort Key）の複合キーで構成される。

```
DynamoDBのキー設計

■ パーティションキーのみ
  テーブル: Users
  ┌──────────────┬───────┬─────────────────┐
  │ user_id (PK) │ name  │ email           │
  ├──────────────┼───────┼─────────────────┤
  │ user-001     │ Alice │ alice@email.com │
  │ user-002     │ Bob   │ bob@email.com   │
  └──────────────┴───────┴─────────────────┘
  → user_idのハッシュでパーティションが決まる

■ パーティションキー + ソートキー
  テーブル: UserPosts
  ┌──────────────┬────────────────────┬─────────┬──────────┐
  │ user_id (PK) │ posted_at (SK)     │ post_id │ content  │
  ├──────────────┼────────────────────┼─────────┼──────────┤
  │ user-001     │ 2026-02-22T10:00:00│ p-001   │ Hello    │
  │ user-001     │ 2026-02-22T11:00:00│ p-002   │ World    │
  │ user-002     │ 2026-02-22T09:00:00│ p-003   │ Hi       │
  └──────────────┴────────────────────┴─────────┴──────────┘
  → 同じuser_idのデータは同じパーティションに格納
  → パーティション内はposted_atでソート済み
```

CassandraのパーティションキーとクラスタリングキーがDynamoDBではパーティションキーとソートキーに対応する。概念は同じだが、用語が異なる。

DynamoDBにはさらにGSI（Global Secondary Index）とLSI（Local Secondary Index）がある。GSIはテーブルとは異なるパーティションキーとソートキーを持つインデックスで、テーブルのデータを別の軸で検索可能にする。LSIは同じパーティションキーで異なるソートキーを持つインデックスだ。

### 「クエリファースト」のデータモデリング

CassandraとDynamoDBに共通する、RDBとの最大の思想的違いは「クエリファースト」だ。

RDBのデータモデリングでは、まずエンティティ間の関係を分析し、正規化されたスキーマを設計する。クエリは後から考える。「どんなクエリにも対応できる」柔軟性が正規化の利点だ。

CassandraとDynamoDBのデータモデリングでは、まずアプリケーションが必要とするクエリ（アクセスパターン）を列挙する。そして各クエリに最適化されたテーブルを設計する。同じデータが複数のテーブルに重複して格納されることも許容する。

```
クエリファースト vs スキーマファーストの設計プロセス

■ スキーマファースト（RDB）
  1. エンティティを洗い出す（ユーザー、注文、商品...）
  2. エンティティ間の関係を定義する（1対多、多対多...）
  3. 正規化する（1NF → 2NF → 3NF → BCNF）
  4. クエリを書く（JOINで自在にデータを取得）

■ クエリファースト（Cassandra / DynamoDB）
  1. アクセスパターンを列挙する
     - 「ユーザーIDから最新の投稿20件を取得」
     - 「日付範囲で投稿を検索」
     - 「タグから関連投稿を取得」
  2. 各アクセスパターンに最適なテーブルを設計する
     - user_posts: PK=user_id, CK=posted_at DESC
     - posts_by_date: PK=date, CK=posted_at
     - posts_by_tag: PK=tag, CK=posted_at DESC
  3. データの非正規化を受け入れる
     - 同じ投稿データが複数テーブルに存在する
     - 更新時は複数テーブルを更新する
```

この設計思想は、RDBに慣れたエンジニアにとっては直感に反する。「同じデータを複数箇所に持つ」ことは、正規化理論が排除しようとしたまさにその問題だ。だがCassandraとDynamoDBは、非正規化のコスト（更新の複雑さ、データの重複）よりも、読み取りの効率性（JOINなしの単一テーブルアクセス）を優先する設計判断をしている。

この判断が妥当かどうかは、アプリケーションの特性による。読み取りが書き込みの何倍も多いワークロード（Webアプリケーションの大半がそうだ）では、読み取りの効率化は全体のパフォーマンスに大きく寄与する。一方、書き込みが頻繁でデータの一貫性が最優先のワークロード（金融取引など）では、RDBの正規化された設計が安全だ。

### DynamoDBの進化

DynamoDBは2012年のローンチ以降、継続的に機能を拡張してきた。

2014年11月、DynamoDB Streamsが導入された。テーブルへの書き込み操作をストリームとしてキャプチャし、Lambda関数やKinesis Data Streamsに連携できる。これにより、データ変更をトリガーにしたリアルタイム処理が可能になった。

2017年11月には、Global Tablesが提供開始された。複数のAWSリージョンにわたるマルチアクティブレプリケーションにより、グローバルなアプリケーションでの低レイテンシアクセスを実現した。

そして2018年11月、On-Demand Capacityモードが追加された。プロビジョニングされたキャパシティを事前に指定する必要がなく、実際の使用量に応じて自動的にスケールする。私がDynamoDBで最初に苦しんだスロットリング問題は、このOn-Demandモードの登場でかなり緩和された。ただし、On-Demandモードでも急激なトラフィック増加（前回ピークの2倍以上）にはスロットリングが発生しうる。完全な「心配不要」ではない。

---

## 5. ハンズオン: Cassandraクラスタで一貫性レベルを体験する

今回のハンズオンでは、Cassandraの3ノードクラスタをDockerで構築し、一貫性レベルを変えた読み書きの挙動を観察する。さらに、DynamoDB Localでシングルテーブル設計を体験する。

### 演習概要

1. Cassandraの3ノードクラスタを構築し、レプリケーションの挙動を確認する
2. 一貫性レベル（ONE、QUORUM、ALL）を変えて書き込み・読み取りを行い、挙動の違いを観察する
3. ノード障害をシミュレートし、一貫性レベルによる影響の違いを体験する
4. DynamoDB Localでパーティションキー/ソートキーの設計を実践する

### 環境構築

```bash
# handson/database-history/15-distributed-eventual-consistency/setup.sh を実行
bash setup.sh
```

### 演習1: Cassandraクラスタの構築と確認

setup.shが3ノードのCassandraクラスタを起動し、テーブルとサンプルデータを投入済みだ。

```bash
# クラスタの状態を確認
docker exec -it db-history-ep15-cass1 nodetool status
```

3ノードすべてが`UN`（Up, Normal）状態であることを確認する。

```bash
# cqlshでCassandraに接続
docker exec -it db-history-ep15-cass1 cqlsh
```

```sql
-- キースペースの確認
DESCRIBE KEYSPACE handson;

-- テーブルの確認
USE handson;
SELECT * FROM user_posts WHERE user_id = 11111111-1111-1111-1111-111111111111;
```

### 演習2: 一貫性レベルの比較

```sql
-- cqlsh内で一貫性レベルを変更して実行

-- 一貫性レベル ONE: 1ノードから応答があれば成功
CONSISTENCY ONE;
SELECT * FROM user_posts WHERE user_id = 11111111-1111-1111-1111-111111111111;
-- → 最速で結果が返る

-- 一貫性レベル QUORUM: 過半数のノードから応答が必要
CONSISTENCY QUORUM;
SELECT * FROM user_posts WHERE user_id = 11111111-1111-1111-1111-111111111111;
-- → ONEより遅いが、より新しいデータが保証される

-- 一貫性レベル ALL: 全ノードからの応答が必要
CONSISTENCY ALL;
SELECT * FROM user_posts WHERE user_id = 11111111-1111-1111-1111-111111111111;
-- → 最も遅いが、完全な一貫性が保証される
```

### 演習3: ノード障害時の挙動の違い

```bash
# Node 3を停止（障害シミュレーション）
docker stop db-history-ep15-cass3
```

```sql
-- cqlshに再接続
-- docker exec -it db-history-ep15-cass1 cqlsh

USE handson;

-- 一貫性レベル ONE: 1ノードが落ちても影響なし
CONSISTENCY ONE;
INSERT INTO user_posts (user_id, posted_at, post_id, content)
VALUES (11111111-1111-1111-1111-111111111111, toTimestamp(now()), uuid(), 'Written with ONE during node failure');
-- → 成功

-- 一貫性レベル QUORUM: 3ノード中2ノードが生きているので成功
CONSISTENCY QUORUM;
INSERT INTO user_posts (user_id, posted_at, post_id, content)
VALUES (11111111-1111-1111-1111-111111111111, toTimestamp(now()), uuid(), 'Written with QUORUM during node failure');
-- → 成功（2/3 >= 2 = QUORUM）

-- 一貫性レベル ALL: 全ノードの応答が必要なので失敗
CONSISTENCY ALL;
INSERT INTO user_posts (user_id, posted_at, post_id, content)
VALUES (11111111-1111-1111-1111-111111111111, toTimestamp(now()), uuid(), 'This will fail');
-- → エラー: Unavailable（3ノード必要だが2ノードしか生存していない）
```

ここが分散データベースの設計判断の核心だ。`ALL`は最も安全だが、1ノードでも落ちればシステム全体が書き込み不能になる。`ONE`は最も可用性が高いが、データの一貫性は保証されない。`QUORUM`はそのバランスを取る。

```bash
# Node 3を復旧
docker start db-history-ep15-cass3

# 復旧後、リペア処理を実行（バックグラウンドでデータの整合性を回復）
# 本番環境では nodetool repair を定期実行する
docker exec -it db-history-ep15-cass1 nodetool repair handson
```

### 演習4: DynamoDB Localでシングルテーブル設計

```bash
# DynamoDB Localに接続してテーブルを確認
docker exec -it db-history-ep15-dynamodb aws dynamodb list-tables \
    --endpoint-url http://localhost:8000 --region local

# テーブルの中身を確認
docker exec -it db-history-ep15-dynamodb aws dynamodb scan \
    --table-name SingleTable \
    --endpoint-url http://localhost:8000 --region local \
    --output table
```

setup.shが作成したシングルテーブルの設計を観察する。

```bash
# アクセスパターン1: ユーザーのプロフィール取得
docker exec -it db-history-ep15-dynamodb aws dynamodb get-item \
    --table-name SingleTable \
    --key '{"PK": {"S": "USER#user-001"}, "SK": {"S": "PROFILE"}}' \
    --endpoint-url http://localhost:8000 --region local

# アクセスパターン2: ユーザーの注文一覧取得
docker exec -it db-history-ep15-dynamodb aws dynamodb query \
    --table-name SingleTable \
    --key-condition-expression "PK = :pk AND begins_with(SK, :sk)" \
    --expression-attribute-values '{":pk": {"S": "USER#user-001"}, ":sk": {"S": "ORDER#"}}' \
    --endpoint-url http://localhost:8000 --region local \
    --output table
```

一つのテーブルで、異なる種類のデータ（ユーザープロフィール、注文データ）を格納し、パーティションキーとソートキーの設計だけで効率的なアクセスパターンを実現している。これがDynamoDBの「シングルテーブル設計」だ。

### 後片付け

```bash
docker rm -f db-history-ep15-cass1 db-history-ep15-cass2 db-history-ep15-cass3 db-history-ep15-dynamodb
docker network rm db-history-ep15-net 2>/dev/null || true
```

---

## 6. 分散の代償を知った上で選べ

第15回を振り返ろう。

**2007年のAmazon Dynamo論文は、分散データベースの設計原則を体系化した。** Consistent Hashingによるデータの分散配置、Sloppy QuorumとHinted Handoffによる高可用性の書き込み、Vector Clocksによる競合検出、Gossipプロトコルによる障害検出——これらの技術を統合し、「可用性を最優先にする」という設計判断を論文として明文化した。

**Cassandraは、DynamoとBigtableのハイブリッドとして2007年にFacebookで開発された。** Dynamo論文の共著者であるAvinash Lakshmanが設計に関わり、マスタレスのP2P分散アーキテクチャとカラムファミリのデータモデルを組み合わせた。2008年にオープンソース化され、2010年にApacheトップレベルプロジェクトとなった。

**DynamoDBは、2012年にAWSが提供開始したフルマネージド分散データベースだ。** Dynamo論文の思想を受け継ぎながらも、Vector Clocksの代わりにLast Writer Wins、Sloppy Quorumの代わりにAWSインフラ上の自動レプリケーションを採用し、運用の複雑さを隠蔽した。一方でプロビジョニングされたキャパシティとスロットリングという、RDBにはない概念を導入した。

**CassandraとDynamoDBに共通する思想は「クエリファースト」のデータモデリングだ。** RDBの正規化に代わり、アクセスパターンからテーブル設計を決定する。データの非正規化を受け入れ、読み取りの効率性を最優先する。同じデータが複数のテーブルに重複して存在することも許容する。

**Quorumは、一貫性と可用性のトレードオフを制御する「ダイヤル」だ。** R + W > Nで強一貫性、R + W <= Nで結果整合性。Cassandraはこのダイヤルをクエリ単位で回すことを可能にした。

冒頭の問いに戻ろう。「『絶対に落ちない』データベースは、何を犠牲にして実現されるのか？」

犠牲になるのは、一貫性の「即時性」だ。RDBでは、書き込んだデータは即座にすべての読み取りに反映される。分散データベースでは、書き込んだデータが全レプリカに伝播するまでの間、古いデータが読み取られる可能性がある。この「一時的な不整合」を許容することで、ノード障害やネットワーク分断が発生してもシステムが動き続ける。

もう一つの犠牲は、データモデリングの柔軟性だ。RDBでは正規化されたスキーマに対してどんなクエリも投げられる。CassandraやDynamoDBでは、事前に定義したアクセスパターン以外のクエリは効率的に実行できない。アドホックな分析クエリやJOINを含む複雑なクエリは、そもそも設計の対象外だ。

分散データベースは「完璧な一貫性」を諦めることで、RDBが到達できなかったスケーラビリティと可用性を実現した。だがその代償を理解せずに使えば、データの不整合という地雷を踏む。

次回は「時系列DB, グラフDB——専門特化の進化」を取り上げる。「汎用データベースでは足りない」用途は、何をきっかけに専用DBを生み出したのか。IoTプロジェクトで大量の時系列データをPostgreSQLに投入し、クエリが破綻した話。InfluxDB、TimescaleDB、Neo4j——データの性質に合ったデータベースを選ぶ力を考える。

---

### 参考文献

- DeCandia, G. et al., "Dynamo: Amazon's Highly Available Key-value Store", SOSP 2007. <https://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf>
- Lakshman, A., Malik, P., "Cassandra - A Decentralized Structured Storage System", LADIS 2009. <https://www.cs.cornell.edu/projects/ladis2009/papers/lakshman-ladis2009.pdf>
- Karger, D. et al., "Consistent Hashing and Random Trees: Distributed Caching Protocols for Relieving Hot Spots on the World Wide Web", STOC 1997. <https://en.wikipedia.org/wiki/Consistent_hashing>
- Lamport, L., "Time, Clocks, and the Ordering of Events in a Distributed System", Communications of the ACM, 1978. <https://lamport.azurewebsites.net/pubs/time-clocks.pdf>
- Fidge, C., "Timestamps in Message-Passing Systems That Preserve the Partial Ordering", 1988. <https://en.wikipedia.org/wiki/Vector_clock>
- Amazon Web Services, "Amazon Web Services Launches Amazon DynamoDB", January 2012. <https://press.aboutamazon.com/2012/1/amazon-web-services-launches-amazon-dynamodb-a-new-nosql-database-service-designed-for-the-scale-of-the-internet>
- Apache Cassandra, Wikipedia. <https://en.wikipedia.org/wiki/Apache_Cassandra>
- Amazon DynamoDB, Wikipedia. <https://en.wikipedia.org/wiki/Amazon_DynamoDB>
- DeBrie, A., "The What, Why, and When of Single-Table Design with DynamoDB". <https://www.alexdebrie.com/posts/dynamodb-single-table/>
- Amazon Science, "Amazon's DynamoDB — 10 years later". <https://www.amazon.science/latest-news/amazons-dynamodb-10-years-later>

---

**次回予告：** 第16回「時系列DB, グラフDB——専門特化の進化」では、「汎用データベースでは足りない」用途が何をきっかけに専用DBを生み出したのかを辿る。IoTプロジェクトで大量の時系列データをPostgreSQLに投入し、クエリが破綻した話。RRDtool（1999年）からInfluxDB、TimescaleDBへと至る時系列データベースの系譜。Neo4j（2007年）のグラフデータベースが「友達の友達」検索で見せる圧倒的な表現力。データの性質に合ったデータベースを選ぶ力を考える。
