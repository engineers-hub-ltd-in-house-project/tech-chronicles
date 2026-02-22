# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第13回：Memcached, Redis——キャッシュ層という発明

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- なぜデータベースの「前」にもう一つのデータストアが必要になったのか——キャッシュ層誕生の必然性
- Brad FitzpatrickがLiveJournalのために開発したmemcached（2003年）の設計思想と、その驚くべき単純さ
- Salvatore Sanfilippo（antirez）がLLOOGGのために生み出したRedis（2009年）が「キャッシュ」を超えて「データ構造サーバ」になった経緯
- Facebookが毎秒数十億リクエストを捌くキャッシュ層をどう設計したか
- Cache Aside、Write Through、Write Behindの各キャッシュ戦略とそのトレードオフ
- Thundering HerdとCache Stampedeというキャッシュ特有の障害パターンとその対策

---

## 1. MySQLの悲鳴をmemcachedで黙らせた日

2007年頃、私はあるWebサービスの運用に携わっていた。

アクセス数は順調に伸びていたが、MySQLが悲鳴を上げ始めた。スロークエリログが際限なく膨らみ、コネクションプールは枯渇寸前だ。読み取りクエリの大半はまったく同じ結果を返すものだった。ユーザーのプロフィール情報、記事のメタデータ、カテゴリ一覧——変更頻度は低いのに、リクエストのたびに律儀にSELECT文を発行していた。

先輩エンジニアに相談すると、返ってきた言葉は短かった。「memcached入れろ」。

memcachedの導入は拍子抜けするほど簡単だった。`apt-get install memcached`でインストールし、PHPのmemcacheエクステンションを有効にする。アプリケーションコードの修正もシンプルだ。データベースからの読み取り結果をmemcachedに保存し、次のリクエストではまずmemcachedを確認する。キャッシュに存在すればそれを返し、なければデータベースに問い合わせる。いわゆるCache Asideパターンだ。

効果は劇的だった。MySQLへのクエリ数が7割以上減少し、レスポンスタイムは目に見えて改善した。データベースサーバのCPU使用率が80%超から20%台に下がったときは、正直なところ「なぜもっと早く入れなかったのか」と思った。

だが、その安堵は長くは続かなかった。

キャッシュの恩恵を享受する裏で、新たな問題が静かに忍び寄っていた。ユーザーがプロフィールを更新したのに、画面に反映されない。記事を編集したのに、古い内容が表示される。キャッシュの有効期限（TTL）を5分に設定していたため、更新から最大5分間、古いデータが表示され続ける。

「キャッシュを消せばいい」と言うのは簡単だ。だが、どのキャッシュキーを消すべきか。一つのテーブルの更新が、複数のキャッシュキーに影響する場合はどうする。キャッシュの削除とデータベースの更新の順序はどうすべきか。キャッシュを先に消してからデータベースを更新する場合、その間のリクエストは古いデータをキャッシュに再投入してしまう。データベースを先に更新してからキャッシュを消す場合、その間のリクエストはまだ古いキャッシュを読む。

キャッシュは「データベースの遅さを隠す魔法」に見えた。だが、その魔法には代償がある。一貫性だ。

前回の連載でCAP定理を取り上げた。分散システムにおいて一貫性と可用性は両立しない。キャッシュ層の導入は、まさにこのトレードオフをアプリケーション層で実装することに他ならない。データベースという「真実の源泉（Source of Truth）」の前に、もう一つの「近似的な真実」を置く。その近似がどこまで許容できるかは、アプリケーションの要件が決める。

あなたが今運用しているシステムに、キャッシュ層はあるだろうか。そのキャッシュが古いデータを返す可能性を、あなたは意識しているだろうか。

---

## 2. memcachedとRedis——二つのキャッシュの系譜

### LiveJournalとmemcachedの誕生

memcachedの誕生を理解するには、2000年代初頭のWebサービスが直面していた状況を知る必要がある。

LiveJournalはBrad Fitzpatrickが1999年に立ち上げたソーシャルネットワーキング・ブログサービスだ。個人プロジェクトとして始まったサービスが急速にユーザーを獲得し、2003年頃にはサーバの処理能力が限界に達していた。新しいハードウェアの調達を待つ間、Fitzpatrickはある事実に気づいた——LiveJournalの複数のサーバには、使われていないRAMが大量にあった。

2003年5月22日、FitzpatrickはこのRAMを有効活用するための分散メモリキャッシュシステムを書いた。これがmemcachedだ。最初のプロトタイプはPerlで書かれた。その後、LiveJournalのエンジニアであったAnatoly VorobeyがCで書き直し、本格的な運用に耐えるシステムとなった。

memcachedの設計思想は徹底的に「単純であること」だった。

```
memcachedの設計思想

┌─────────────────────────────────────────────┐
│ memcached = 巨大なハッシュテーブル            │
│                                             │
│  Key → Value のペアをメモリ上に保持する       │
│  以上。                                      │
│                                             │
│ できること:                                  │
│   GET key         — 値の取得                │
│   SET key value   — 値の設定                │
│   DELETE key      — 値の削除                │
│   INCR/DECR key   — 数値のインクリメント     │
│                                             │
│ できないこと:                                │
│   - 永続化（メモリ上のみ）                    │
│   - 値の検索・フィルタリング                  │
│   - サーバ間のデータレプリケーション          │
│   - 複雑なデータ構造の操作                   │
│   - Pub/Subメッセージング                    │
└─────────────────────────────────────────────┘
```

memcachedのサーバ自体は分散のロジックを持たない。各memcachedインスタンスは独立に動作し、互いの存在すら知らない。キーをどのサーバに割り当てるかは、クライアントライブラリがConsistent Hashing（一貫性ハッシュ法）によって決定する。ハッシュ空間をリング状に構成し、キーとサーバの両方をリング上にマッピングする。キーから時計回りに最初に出会うサーバが、そのキーの担当サーバだ。

この設計には深い意味がある。サーバを追加・削除しても、再配置が必要なキーは全体のごく一部で済む。Consistent Hashingがなければ、サーバの増減のたびに大半のキーの所在が変わり、キャッシュが一斉に無効化されてデータベースに負荷が殺到する——いわゆるCache Stampedeが起きる。

メモリが尽きた場合は、LRU（Least Recently Used）アルゴリズムにより、最も長い間アクセスされていないエントリから順に追い出される。永続化の仕組みはない。memcachedを再起動すれば、キャッシュは消える。この「消えても問題ない」という前提が、memcachedを根本的に単純にしている。

### RedisとLLOOGG——もう一つの系譜

memcachedがLiveJournalの「読み取り負荷の軽減」という明確な課題から生まれたのに対し、Redisは少し異なる文脈から登場した。

2007年頃、イタリアのプログラマSalvatore Sanfilippo（ハンドル名: antirez）は、LLOOGG というリアルタイムWebログ分析サービスを運営していた。LLOOGGは、Webサイトの訪問者の行動をリアルタイムに追跡するツールだ。Google Analyticsがリアルタイム機能を提供するのは2011年だから、LLOOGGは時代を先取りしていた。

LLOOGGのデータ処理にantirezは最初MySQLを使っていたが、リアルタイム処理の要求にMySQLのディスクI/Oが追いつかなかった。データの読み書きのたびにディスクにアクセスし、データ量の増加に伴ってボトルネックが顕在化した。

antirezはメモリ上でデータを処理すればこの問題を解決できると考え、最初にTcl言語でLMDB（LLOOGG Memory Database）というプロトタイプを作った。このプロトタイプの経験を踏まえ、Cで本格的に実装したのがRedis（Remote Dictionary Server）だ。2009年4月に初版がリリースされた。

Redisがmemcachedと根本的に異なるのは、antirezが「単なるKey-Valueキャッシュ」ではなく「データ構造サーバ」として設計した点だ。memcachedが保持できるのは文字列（バイト列）のみだが、Redisは最初から複数のデータ構造をネイティブにサポートした。

```
Redisのデータ構造（初期〜現在）

■ String（文字列）  ← memcachedと同等の基本機能
  SET key "value"
  GET key
  INCR counter

■ List（リスト）    ← 双方向連結リスト
  LPUSH mylist "a"
  RPOP mylist
  LRANGE mylist 0 -1

■ Set（集合）       ← 重複なしの要素集合
  SADD myset "a" "b" "c"
  SISMEMBER myset "a"
  SINTER set1 set2    ← 積集合の演算

■ Sorted Set（ソート済み集合）  ← スコア付き集合
  ZADD leaderboard 100 "player1"
  ZADD leaderboard 200 "player2"
  ZRANGE leaderboard 0 -1 WITHSCORES  ← ランキング

■ Hash（ハッシュ）  ← フィールド-値のマップ
  HSET user:1 name "Alice" age "30"
  HGET user:1 name
  HGETALL user:1

（以下は後に追加されたデータ構造）
■ HyperLogLog（2014年、Redis 2.8.9）   ← 確率的カーディナリティ推定
■ Stream（2018年、Redis 5.0）           ← 追記型ログデータ構造
■ Bitmaps / Bitfields                   ← ビット単位の操作
```

この設計思想の違いは、両者の用途を決定的に分けた。memcachedはその名のとおり「メモリキャッシュ」に特化し、読み取り負荷の軽減という一点に卓越した。Redisは「キャッシュ」にも使えるが、それだけではない。セッションストア、リアルタイムランキング、メッセージキュー、レートリミッタ——データ構造の豊富さが、多様なユースケースへの適用を可能にした。

### Redisの進化の軌跡

antirezはRedisのBDFL（Benevolent Dictator for Life、優しい終身独裁者）として、11年間にわたってプロジェクトを率いた。その間のRedisの進化は目覚ましい。

2010年、Redis 2.0でPub/Sub（Publish/Subscribe）メッセージング機能が導入された。これにより、Redisはキャッシュやデータストアにとどまらず、メッセージブローカーとしての役割も担うようになった。

2012年10月、Redis 2.6でLuaスクリプティングが導入された。EVALコマンドにより、サーバサイドでLuaスクリプトを実行できるようになった。複数のRedisコマンドをアトミックに実行できるため、Check-and-Setのような操作が安全に行える。

2014年、Redis 2.8.9でHyperLogLogデータ構造が追加された。最大12KBのメモリで、数億の一意な要素のカーディナリティを標準誤差0.81%で推定できる。コマンド名のPFプレフィックス（PFADD、PFCOUNT、PFMERGE）は、HyperLogLogアルゴリズムの発明者Philippe Flajoletへの敬意を表している。

2015年4月、Redis 3.0のリリースとともに、Redis Clusterが安定版として提供された。16384のハッシュスロットによるデータの自動分散と、マスタ・レプリカ間のフェイルオーバーが可能になった。memcachedのクライアントサイドのConsistent Hashingとは異なり、Redis Clusterはサーバサイドでシャーディングとフェイルオーバーを管理する。

2018年10月、Redis 5.0でStreamデータ型が導入された。追記型のログデータ構造で、コンシューマグループによる分散処理をサポートする。Apache Kafkaに触発された設計だが、Redisのメモリ上で動作するため、低レイテンシでのメッセージ処理が可能だ。

2020年6月30日、antirezはメンテナの座を退いた。Yossi GottliebとOran Agraに引き継がれた。

そして2024年3月、Redisの歴史に大きな転換点が訪れた。Redis Labs（現Redis Inc.）は、Redis 7.4以降のライセンスをBSD 3-clauseからRSALv2（Redis Source Available License v2）とSSPLv1（Server Side Public License v1）のデュアルライセンスに変更すると発表した。クラウドプロバイダがRedisをマネージドサービスとして提供しながら十分な価値をコミュニティに還元していない、というのがその理由だった。

この決定に対し、Linux Foundationは2024年3月28日にValkey——Redis 7.2.4のBSDライセンスフォーク——を発表した。AWS、Google Cloud、Oracle、Ericsson、Snapが支援に名を連ねた。オープンソースのライセンス問題は本連載の主題ではないが、この出来事はRedisが「単なるキャッシュツール」ではなく、現代のインフラストラクチャにとって不可欠な存在になったことの証左だ。

---

## 3. キャッシュの設計思想——戦略とそのトレードオフ

### なぜキャッシュが必要なのか

キャッシュ層が必要になる根本的な理由は、「メモリとディスクの速度差」にある。

```
アクセス速度のオーダー比較（概算）

L1キャッシュ参照:              ~1 ns
L2キャッシュ参照:              ~4 ns
メインメモリ参照:              ~100 ns
SSD ランダムリード:            ~16 μs   = 16,000 ns
HDD ランダムリード:            ~2 ms    = 2,000,000 ns
ネットワーク（同一DC内）:       ~500 μs  = 500,000 ns
ネットワーク（東京-大阪間）:    ~10 ms   = 10,000,000 ns

メインメモリはSSDの約160倍、HDDの約20,000倍速い。
```

データベースは本質的にディスクベースのシステムだ。B+Treeインデックスの走査、WALへの書き込み、データページのフェッチ——これらはすべてディスクI/Oを伴う。バッファプールによってホットデータはメモリ上にキャッシュされるが、データ量がメモリに収まらなくなれば、ディスクアクセスは避けられない。

memcachedやRedisがデータベースの「前」に置かれる理由はここにある。頻繁にアクセスされるデータをメモリ上に保持することで、ディスクI/Oという最大のボトルネックを回避する。

### Cache Aside（Lazy Loading）

最も広く使われるキャッシュ戦略がCache Aside（レイジーローディング）だ。私が最初にmemcachedを導入したときも、このパターンだった。

```
Cache Aside パターン

【読み取り】
Client → Cache に問い合わせ
  ├── Cache Hit  → キャッシュから値を返す
  └── Cache Miss → DB に問い合わせ → 結果をCache に書き込み → 値を返す

【書き込み】
Client → DB に書き込み → Cache のキーを削除（invalidation）

┌────────┐      ┌────────┐      ┌────────┐
│ Client │─(1)→│ Cache  │      │   DB   │
│        │←(2)─│ (miss) │      │        │
│        │────────(3)─────────→│        │
│        │←───────(4)──────────│        │
│        │─(5)→│ (set)  │      │        │
└────────┘      └────────┘      └────────┘
```

Cache Asideの利点は明確だ。キャッシュに障害が発生しても、アプリケーションはデータベースにフォールバックできる。キャッシュはあくまで「高速なショートカット」であり、データの正本はデータベースにある。

欠点もある。キャッシュミス時のレイテンシは、キャッシュなしの場合よりも悪化する。キャッシュへの問い合わせ、データベースへの問い合わせ、キャッシュへの書き込みと、3つの操作が発生するからだ。また、キャッシュの無効化タイミングによっては、古いデータが一定期間残る。

### Write Through

Write Throughは、書き込み時にキャッシュとデータベースの両方に同時に書き込む戦略だ。

```
Write Through パターン

【書き込み】
Client → Cache に書き込み → DB に書き込み → 完了を返す

【読み取り】
Client → Cache から読み取り（常にキャッシュにデータが存在する）

┌────────┐      ┌────────┐      ┌────────┐
│ Client │─(1)→│ Cache  │─(2)→│   DB   │
│        │←──────(3)────────────│        │
└────────┘      └────────┘      └────────┘
```

Write Throughの利点は、キャッシュとデータベースの一貫性が高いことだ。書き込みのたびにキャッシュが更新されるため、読み取り時に古いデータが返されるリスクが低い。

欠点は、書き込みレイテンシの増大だ。すべての書き込みがキャッシュとデータベースの両方を経由するため、書き込みが遅くなる。また、一度も読まれないデータもキャッシュに書き込まれるため、メモリの利用効率が下がる。

### Write Behind（Write Back）

Write Behind は、書き込みをキャッシュにのみ行い、データベースへの書き込みを非同期で遅延させる戦略だ。

```
Write Behind パターン

【書き込み】
Client → Cache に書き込み → 完了を返す（即座に応答）
（バックグラウンドで）Cache → DB にバッチ書き込み

┌────────┐      ┌────────┐    非同期    ┌────────┐
│ Client │─(1)→│ Cache  │───(後で)───→│   DB   │
│        │←(2)─│        │             │        │
└────────┘      └────────┘             └────────┘
```

Write Behindの利点は、書き込みレイテンシの劇的な低減だ。クライアントはキャッシュへの書き込み完了をもって応答を受け取る。データベースへの書き込みはバッチで行われるため、書き込み回数も削減できる。

欠点は深刻だ。キャッシュ障害時にデータが失われる。キャッシュに書き込んでからデータベースに同期されるまでの間にキャッシュが落ちれば、そのデータは消える。前回の連載で述べたCAP定理のトレードオフが、ここでも顔を出す——可用性と低レイテンシを得る代わりに、耐久性（Durability）を犠牲にしている。

### Facebookのキャッシュアーキテクチャ

キャッシュ戦略の話を実際のスケールで理解するために、Facebookの事例を見よう。

2013年、FacebookのRajesh Nishtalaらは、USENIXのNSDI（Networked Systems Design and Implementation）で「Scaling Memcache at Facebook」を発表した。この論文は、数十億リクエスト/秒を処理し、数兆アイテムを保持するキャッシュ層の設計を公開した、キャッシュアーキテクチャの金字塔だ。

Facebookのアーキテクチャはmemcachedをベースとしているが、単純にmemcachedを並べただけではない。以下のような多層構造を持つ。

```
Facebookのキャッシュアーキテクチャ概要
（2013年NSDI論文に基づく）

Region A（プライマリ）           Region B（レプリカ）
┌────────────────────────────┐  ┌────────────────────────────┐
│ ┌──────────────────────┐   │  │ ┌──────────────────────┐   │
│ │ Frontend Cluster 1   │   │  │ │ Frontend Cluster     │   │
│ │ ┌─────┐ ┌─────────┐ │   │  │ │ ┌─────┐ ┌─────────┐ │   │
│ │ │ Web │→│memcached│ │   │  │ │ │ Web │→│memcached│ │   │
│ │ └─────┘ └─────────┘ │   │  │ │ └─────┘ └─────────┘ │   │
│ └──────────────────────┘   │  │ └──────────────────────┘   │
│ ┌──────────────────────┐   │  │                            │
│ │ Frontend Cluster 2   │   │  │ ┌──────────────────────┐   │
│ │ ┌─────┐ ┌─────────┐ │   │  │ │   Regional Pool      │   │
│ │ │ Web │→│memcached│ │   │  │ │   (低頻度データ)      │   │
│ │ └─────┘ └─────────┘ │   │  │ └──────────────────────┘   │
│ └──────────────────────┘   │  └────────────────────────────┘
│ ┌──────────────────────┐   │         ↑
│ │   Regional Pool      │   │         │ レプリケーション
│ │   (低頻度データ)      │   │         │ （MySQL → リモートマーカ
│ └──────────────────────┘   │         │   → キャッシュ無効化）
│ ┌──────────────────────┐   │
│ │   Storage (MySQL)    │   │
│ └──────────────────────┘   │
└────────────────────────────┘
```

この論文で特に重要なのは、キャッシュの無効化（invalidation）の設計だ。Facebookはデータベース（MySQL）の更新時にmemcachedのキーを削除する「look-aside cache invalidation」を採用した。書き込み時にキャッシュを更新（Write Through）するのではなく、削除する。次の読み取りでキャッシュミスが発生し、データベースから最新の値がロードされる。

一見すると非効率に見えるが、この設計には理由がある。Facebookのワークロードでは読み取りが書き込みの数百倍多い。書き込み時にキャッシュを更新しても、そのキャッシュエントリが次に読まれる前に再度更新される可能性がある。キーの削除だけなら、書き込み処理のオーバーヘッドは最小限に抑えられる。

---

## 4. キャッシュの闇——一貫性問題とその対策

### キャッシュ不整合の根本原因

キャッシュの一貫性問題は、単純なように見えて根が深い。

Cache Asideパターンにおける最も基本的な不整合シナリオを考える。

```
Race Condition: キャッシュ削除と読み取りの競合

時刻    Thread A（書き込み）      Thread B（読み取り）     Cache      DB
 t1     DB更新: x = 新値                                            x=新値
 t2                              Cache GET x → Miss      (空)
 t3                              DB読み取り: x = 新値
 t4     Cache DELETE x           ← 既に空なので何も起きない (空)
 t5                              Cache SET x = 新値       x=新値

→ この場合は問題ない。だが順序が変わると…

時刻    Thread A（書き込み）      Thread B（読み取り）     Cache      DB
 t1                              Cache GET x → Miss      (空)       x=旧値
 t2     DB更新: x = 新値                                            x=新値
 t3     Cache DELETE x                                   (空)
 t4                              DB読み取り: x = ??? ← t1時点のクエリ結果（旧値）
 t5                              Cache SET x = 旧値      x=旧値    x=新値

→ キャッシュに旧値がTTL分残り続ける！
```

この問題は「stale set」と呼ばれ、Facebookの論文でも詳しく議論されている。Facebookはこの問題に対して「lease」メカニズムを導入した。キャッシュミス時にクライアントにleaseトークンを発行し、キャッシュの設定時にそのトークンの有効性を検証する。キーが削除されるとleaseトークンが無効化されるため、古い値の書き込みを防げる。

### Thundering Herd（殺到問題）

キャッシュの一貫性問題の中でも特に破壊的なのが、Thundering Herd（雷の群れ）だ。

人気のあるキャッシュキーが失効した瞬間、そのキーにアクセスしようとする大量のリクエストがすべてキャッシュミスとなる。これらのリクエストは同時にデータベースに殺到し、同じクエリを繰り返し実行する。データベースは過負荷に陥り、応答時間が急上昇し、最悪の場合はサービスダウンに至る。

```
Thundering Herd のメカニズム

   キャッシュ有効期限切れ
          ↓
 ┌───────────────────────────────────┐
 │  リクエスト 1 → Cache Miss → DB  │
 │  リクエスト 2 → Cache Miss → DB  │
 │  リクエスト 3 → Cache Miss → DB  │  ← 全員が同じクエリを
 │  リクエスト 4 → Cache Miss → DB  │     データベースに発行
 │  ...                             │
 │  リクエスト N → Cache Miss → DB  │
 └───────────────────────────────────┘
                    ↓
              DB 過負荷
                    ↓
            レスポンス遅延
                    ↓
         さらにリクエスト滞留
                    ↓
          サービスダウン（最悪の場合）
```

### Cache Stampede

Cache Stampedeは Thundering Herdと密接に関連するが、やや異なる側面を持つ。Thundering Herdが「人気キーの失効」に起因するのに対し、Cache Stampedeはより広範な状況——サーバの再起動、大規模なキャッシュフラッシュ、ネットワーク障害からの復旧時など——で発生しうる。大量のキャッシュキーが同時に無効化されることで、データベースへのリクエストが急増する現象だ。

### 対策パターン

これらの問題に対する代表的な対策は以下のとおりだ。

**Request Coalescing（リクエスト合体）**: 同じキーに対する複数のキャッシュミスリクエストを一つにまとめる。最初のリクエストがデータベースに問い合わせ、後続のリクエストは最初のリクエストの結果を待つ。Facebookの論文で紹介されたleaseメカニズムがこの方式に相当する。

**Probabilistic Early Expiration（確率的な早期更新）**: キャッシュの有効期限が切れる「前」に、確率的にキャッシュを更新する。有効期限に近づくほど更新の確率が上がる。この方式は2015年のVattani, Chierichetti, Lowensteinの論文「Optimal Probabilistic Cache Stampede Prevention」で形式化されている。

**Stale While Revalidate**: 有効期限が切れたキャッシュの値を即座に返しつつ、バックグラウンドでキャッシュを更新する。ユーザーには古い値が返されるが、レスポンスタイムは安定する。厳密な一貫性を求めない場合に有効だ。

**キャッシュウォームアップ**: アプリケーションの起動時やデプロイ時に、よくアクセスされるキーを事前にキャッシュにロードする。コールドスタート問題の緩和に役立つ。

これらの対策に共通するのは、「完璧な一貫性」と「パフォーマンス」のトレードオフを、アプリケーションの要件に応じて調整するという思想だ。前回のCAP定理で見たトレードオフが、キャッシュ層という身近な場所に現れている。

---

## 5. ハンズオン: Redisのデータ構造を活用した実用パターン

今回のハンズオンでは、Redisのデータ構造（Sorted Set、HyperLogLog）を活用した実用的なパターンを実装し、キャッシュの不整合を意図的に発生させて解消する。

### 演習概要

1. Redisの基本データ構造を使ったリアルタイムランキングの実装
2. HyperLogLogによるユニークビジター数の推定
3. Cache Asideパターンの実装とキャッシュ不整合の体験
4. Request Coalescingによる Thundering Herd対策

### 環境構築

```bash
# handson/database-history/13-memcached-and-redis/setup.sh を実行
bash setup.sh
```

### 演習1: Sorted Setによるリアルタイムランキング

setup.shがRedisコンテナとPostgreSQLコンテナを起動している。

Redisに接続する。

```bash
docker exec -it db-history-ep13-redis redis-cli
```

```redis
-- Sorted Set でリアルタイムランキングを構築する
-- ZADD key score member でスコア付きのメンバーを追加

ZADD leaderboard 1500 "player:alice"
ZADD leaderboard 2300 "player:bob"
ZADD leaderboard 1800 "player:charlie"
ZADD leaderboard 3100 "player:diana"
ZADD leaderboard 900 "player:eve"

-- 上位3名を取得（スコア降順）
ZREVRANGE leaderboard 0 2 WITHSCORES
-- 1) "player:diana"   2) "3100"
-- 3) "player:bob"     4) "2300"
-- 5) "player:charlie" 6) "1800"

-- 特定プレイヤーのランキングを取得（0-indexed、降順）
ZREVRANK leaderboard "player:bob"
-- (integer) 1  ← 2位（0始まり）

-- スコアの加算（アトミック操作）
ZINCRBY leaderboard 500 "player:alice"
-- "2000"

-- 上位3名を再確認
ZREVRANGE leaderboard 0 2 WITHSCORES
-- alice が 2000 になり、charlie を抜いた

-- スコア範囲でメンバーを取得
ZRANGEBYSCORE leaderboard 1500 2500 WITHSCORES
-- スコアが1500〜2500のプレイヤーを取得
```

RDBでこれと同等のことを行うには、`ORDER BY score DESC LIMIT 3`のSELECT文を毎回発行する必要がある。アクセスが集中するランキングページで、毎回ソートとLIMITを実行するのはデータベースにとって負担だ。Redisの Sorted Setは、挿入・削除・ランク取得がO(log N)で完了する。メンバー数が100万であっても、ランキング取得は瞬時だ。

### 演習2: HyperLogLogによるユニークビジター推定

```redis
-- HyperLogLog でユニークビジター数を推定する
-- 最大12KBのメモリで、標準誤差0.81%のカーディナリティ推定

-- 今日のユニークビジター
PFADD uv:2026-02-22 "user:101" "user:102" "user:103"
PFADD uv:2026-02-22 "user:101" "user:104"
-- user:101 は重複 → カウントされない

PFCOUNT uv:2026-02-22
-- (integer) 4

-- 昨日のユニークビジター
PFADD uv:2026-02-21 "user:101" "user:105" "user:106"

-- 2日間のユニークビジター数（和集合）
PFMERGE uv:2days uv:2026-02-21 uv:2026-02-22
PFCOUNT uv:2days
-- (integer) 6  ← user:101は両日に出現するが1回だけカウント

-- 大量データでの精度検証
-- 10万件のユニーク値を投入する
-- （setup.sh が事前に投入済み）
PFCOUNT uv:large-test
-- → 約100,000 の値が返される（標準誤差0.81%以内の精度）
```

正確なカーディナリティをSetで計算するなら、全要素をメモリ上に保持する必要がある。10万件のユニーク値なら数MBのメモリを消費する。HyperLogLogは最大12KBで同等の推定が可能だ。メモリ効率は数百倍に達する。厳密な正確性が不要な場面——ユニークビジター数、ユニークIP数、一意なイベント数の概算——で威力を発揮する。

### 演習3: Cache Asideパターンとキャッシュ不整合の体験

setup.shがPostgreSQLにサンプルデータを投入し、キャッシュテスト用のスクリプトを配置している。

```bash
# PostgreSQL にテスト用データが投入済み
docker exec -it db-history-ep13-postgres psql -U postgres -d handson \
    -c "SELECT * FROM products ORDER BY id LIMIT 5;"
```

```bash
# Cache Aside パターンのデモスクリプトを実行
docker exec -it db-history-ep13-redis bash /scripts/cache-aside-demo.sh
```

このスクリプトは以下の操作を行う。

1. 商品データをDBから読み取り、Redisにキャッシュする（TTL 30秒）
2. キャッシュヒット時のレイテンシとキャッシュミス時のレイテンシを比較する
3. DBの値を更新し、キャッシュ削除前に読み取りを試みて古い値が返ることを確認する
4. キャッシュを削除し、次の読み取りで最新値が返ることを確認する

```bash
# 出力例:
# [1] DB読み取り + キャッシュ設定: 3.2ms
# [2] キャッシュヒット: 0.4ms（8倍高速）
# [3] DB更新: price = 1500 → 1800
# [4] キャッシュから読み取り: price = 1500（古い値！）
# [5] キャッシュ削除
# [6] DB読み取り + キャッシュ再設定: price = 1800（最新値）
```

### 演習4: Thundering Herd のシミュレーション

```bash
# Thundering Herd シミュレーション
docker exec -it db-history-ep13-redis bash /scripts/thundering-herd-demo.sh
```

このスクリプトは以下を行う。

1. キャッシュに値を設定（TTL 2秒）
2. 2秒待ってキャッシュを期限切れにする
3. 同時に10個のリクエストを発行し、すべてがキャッシュミスとなってDBに殺到することを確認する
4. ロック（SETNX）を使ったRequest Coalescingを適用し、DB問い合わせが1回で済むことを確認する

```bash
# 出力例:
# === Thundering Herd（対策なし）===
# DB問い合わせ回数: 10（全リクエストがDBに殺到）
#
# === Request Coalescing（対策あり）===
# DB問い合わせ回数: 1（最初のリクエストのみDBに問い合わせ）
# 残り9リクエストはキャッシュ再投入を待機して取得
```

### 後片付け

```bash
docker rm -f db-history-ep13-redis db-history-ep13-postgres
docker network rm db-history-ep13-net 2>/dev/null || true
```

---

## 6. キャッシュという「必要悪」を飼い慣らす

第13回を振り返ろう。

**キャッシュ層は、メモリとディスクの速度差を埋めるために生まれた。** データベースはディスクベースのシステムであり、メモリのアクセス速度はSSDの約160倍、HDDの約20,000倍に達する。この速度差を埋めるために、データベースの「前」にメモリベースのデータストアを置く——これがキャッシュ層の本質だ。

**memcachedは2003年にBrad FitzpatrickがLiveJournalのために開発した。** 設計思想は徹底的な単純さだ。巨大なハッシュテーブルとして機能し、GET/SET/DELETEの基本操作のみを提供する。分散ロジックはクライアントサイドのConsistent Hashingで実現する。永続化は行わない。この割り切りが、memcachedを高速で安定した「キャッシュ専用」システムにした。

**Redisは2009年にSalvatore Sanfilippo（antirez）がLLOOGGのために開発した。** memcachedとは異なり、「データ構造サーバ」として設計された。String、List、Set、Sorted Set、Hash、そして後に追加されたHyperLogLog、Streamなど、豊富なデータ構造をネイティブにサポートする。これにより、キャッシュにとどまらず、セッションストア、メッセージブローカー、リアルタイムランキング、レートリミッタなど、多様なユースケースに対応する。

**Facebookは2013年のNSDI論文で、毎秒数十億リクエストを処理するmemcachedベースのキャッシュアーキテクチャを公開した。** 多層構造のキャッシュ、look-aside invalidation、leaseメカニズムによるstale set対策など、大規模運用から得られた知見は、キャッシュ設計の教科書となった。

**キャッシュ戦略にはCache Aside、Write Through、Write Behindがあり、それぞれ一貫性とパフォーマンスのトレードオフが異なる。** Cache Asideは最も一般的で耐障害性が高いが、キャッシュミス時のレイテンシ増大と一貫性の問題がある。Write Throughは一貫性が高いが書き込みが遅い。Write Behindは書き込みが速いがデータ損失リスクがある。

**Thundering HerdとCache Stampedeは、キャッシュ特有の障害パターンだ。** 人気キーの失効や大規模なキャッシュフラッシュにより、データベースにリクエストが殺到する。Request Coalescing、Probabilistic Early Expiration、Stale While Revalidateなどの対策パターンが存在する。

冒頭の問いに戻ろう。「なぜデータベースの前にもう一つの『データストア』が必要になったのか？」

それは、データベースが「正しさ」と「永続性」を保証するために支払っているコスト——ディスクI/O、ロック、WAL書き込み、インデックス更新——が、Webスケールの読み取り負荷に対して根本的に重すぎたからだ。キャッシュ層は、この「正しさのコスト」の一部を、一貫性の緩和という代償で回避する仕組みだ。

キャッシュは「必要悪」と表現されることがある。だが私はむしろ「飼い慣らすべき獣」だと思っている。キャッシュの恩恵を最大化し、リスクを最小化するには、キャッシュが何を犠牲にしているか——一貫性という根本的な代償——を正確に理解する必要がある。その理解なしにmemcachedやRedisを「とりあえず入れる」のは、CAP定理を知らずに分散データベースを選ぶのと同じだ。

次回は「MongoDB, CouchDB——ドキュメント指向の挑戦」を取り上げる。「スキーマレス」という言葉に魅了され、MongoDBに飛びついた2010年代のNoSQLブーム。スキーマレスは本当に「設計不要」を意味するのか。ドキュメントモデルがリレーショナルモデルに対して持つ真の利点と、その代償を検証する。

---

### 参考文献

- Brad Fitzpatrick, memcached初期プロトタイプに関するツイート, March 2018. <https://x.com/bradfitz/status/969331235183972352>
- memcached公式サイト. <https://memcached.org/about>
- Salvatore Sanfilippo (antirez), "Redis new data structure: the HyperLogLog", 2014. <https://antirez.com/news/75>
- Redis公式ドキュメント: Persistence. <https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/>
- Redis公式ドキュメント: Pub/Sub. <https://redis.io/docs/latest/develop/pubsub/>
- Redis公式ドキュメント: Streams. <https://redis.io/docs/latest/develop/data-types/streams/>
- Redis公式ドキュメント: Programmability (Lua scripting). <https://redis.io/docs/latest/develop/programmability/>
- Rajesh Nishtala et al., "Scaling Memcache at Facebook", NSDI 2013. <https://www.usenix.org/conference/nsdi13/technical-sessions/presentation/nishtala>
- Redis Inc., "Redis Adopts Dual Source-Available Licensing", March 2024. <https://redis.io/blog/redis-adopts-dual-source-available-licensing/>
- Linux Foundation, "Linux Foundation Launches Open Source Valkey Community", March 2024. <https://www.linuxfoundation.org/press/linux-foundation-launches-open-source-valkey-community>
- Redis Wikipedia. <https://en.wikipedia.org/wiki/Redis>
- Memcached Wikipedia. <https://en.wikipedia.org/wiki/Memcached>

---

**次回予告：** 第14回「MongoDB, CouchDB——ドキュメント指向の挑戦」では、「スキーマレス」という言葉が2010年代のWeb開発をどう変えたかを辿る。MongoDBで「スキーマレスだから設計不要」と思い込み、カオス状態に陥った話。スキーマオンリードとスキーマオンライトの本質的な違い。ドキュメントモデルとリレーショナルモデル、それぞれの得手不得手を、同じデータを両方で実装して比較する。
