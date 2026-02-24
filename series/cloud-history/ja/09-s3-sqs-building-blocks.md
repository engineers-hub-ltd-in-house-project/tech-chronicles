# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第9回：S3、SQS——クラウドの基本構成要素

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- EC2だけでは「クラウド」にならない理由——計算・ストレージ・メッセージングの三位一体
- SQS（2004年）がAWS最初のインフラサービスとして発表された経緯と、メッセージングの本質
- S3（2006年）のオブジェクトストレージ設計——HTTP動詞だけでデータを操作する革新
- 「イレブンナイン」（99.999999999%）の耐久性が意味するものと、その達成メカニズム
- 結果整合性（Eventual Consistency）の概念と、S3が14年間抱え続けた設計上のトレードオフ
- AWSの「ビルディングブロック」思想——小さなプリミティブを組み合わせる設計哲学の起源
- S3互換APIによるオブジェクト操作とSQSのプロデューサ/コンシューマパターンの実践

---

## 1. 「データはどこに置くのか」

EC2のインスタンスストレージがエフェメラル——揮発性だと知ったとき、私は目の前が暗くなった。

前回、第8回で書いたとおり、私は2008年にEC2を初めて触った。APIを叩くと数分でサーバが立ち上がり、不要になれば捨てる。「サーバは消耗品になった」という衝撃を受けた。だが、衝撃はもう一つ待っていた。

あるプロジェクトでEC2インスタンスにアプリケーションをデプロイし、データをローカルディスクに保存していた。テスト運用は順調だった。ところが、インスタンスを停止して再起動しようとした際、ローカルディスクのデータが消えていた。正確には、インスタンスストア（エフェメラルストレージ）は停止操作でデータを失う仕様だった。ドキュメントに書いてあった。だが、ホスティング時代の感覚が抜けない私は、「サーバのディスク=永続」という前提を無意識に持ち込んでいた。

EC2にはまだEBSが存在しなかった。EBS（Elastic Block Store）が登場したのは2008年8月20日——EC2のベータ開始から約2年後のことだ。では、2006年から2008年までの2年間、EC2のユーザーはデータをどこに保存していたのか。

答えはS3だった。

S3（Simple Storage Service）に初めてオブジェクトを格納したとき、私はファイルシステムとは根本的に異なる何かに触れている感覚を持った。ディレクトリもない。パーミッションの概念も違う。`PUT`でオブジェクトを格納し、`GET`で取得し、`DELETE`で消す。HTTPの動詞がそのままストレージのAPIになっている。ファイルシステムの上に構築されたものではなく、最初からHTTP APIとして設計されたストレージ。それがS3だった。

同じ頃、もう一つの発見があった。EC2のインスタンスが複数台に増えたとき、インスタンス間の通信をどう設計するかという問題に直面した。あるインスタンスで発生したイベントを別のインスタンスに伝えたい。直接通信すると、送信先が停止していた場合にメッセージが失われる。そこでSQS（Simple Queue Service）を間に挟んだ。メッセージをキューに入れ、受信側が準備できたときに取り出す。非同期処理の基本パターンだが、このキューイングサービスがクラウド上にマネージドサービスとして存在しているという事実が、私のアーキテクチャの発想を変えた。

計算だけではクラウドにならない。ストレージとメッセージングが加わって初めて、クラウドは「アーキテクチャの構築基盤」になる。

あなたは今、S3にオブジェクトを格納するとき、そのデータがどのように複数のデータセンターに分散され、なぜ「99.999999999%の耐久性」を達成できるのか、考えたことがあるだろうか。あるいはSQSにメッセージを送信するとき、そのメッセージが「少なくとも1回」配信されるという保証の背後に、どのような分散システムの設計判断があるか、意識したことはあるだろうか。

---

## 2. AWSの「ビルディングブロック」思想——小さなプリミティブの集合体

### BezosのAPIマンデート

AWSのサービス設計を理解するには、その原点まで遡る必要がある。

2002年頃、Jeff BezosはAmazon社内の全チームに対して一つの命令を下した。後に「APIマンデート」と呼ばれることになるこの指令の内容は、おおよそ次のようなものだった。

1. 全てのチームは、データと機能をサービスインターフェース経由で公開すること
2. チーム間の通信は、このサービスインターフェースを通じてのみ行うこと
3. 直接リンク、他チームのデータストアへの直接アクセス、共有メモリモデル、バックドア——一切の例外なく禁止
4. 使用する技術は問わない。HTTP、CORBA、Pub/Sub、独自プロトコル——何でもよい
5. 全てのサービスインターフェースは、例外なく、外部の開発者に公開できる設計であること

この指令の存在は、2011年にGoogleのエンジニアSteve Yeggeが社内メモで言及し、そのメモが誤って外部に公開されたことで広く知られるようになった。

注目すべきは5番目の条件だ。「外部に公開できる設計であること」。これは単なるSOA（サービス指向アーキテクチャ）への移行ではない。内部ツールと外部サービスの区別を最初からなくすという設計原則だ。Amazon社内で使われている計算、ストレージ、メッセージングの仕組みを、そのまま外部開発者にも提供できるよう設計せよ——この原則が、AWSの「ビルディングブロック」思想の原点となった。

### 「インターネットOS」の構想

Andy Jassyは、AWSを「インターネットOS」として構想した。その骨格は、ソフトウェア開発に必要な基盤機能を、小さく、独立した、APIで操作可能なサービス群として提供することにあった。

計算が必要ならEC2を使う。ストレージが必要ならS3を使う。非同期メッセージングが必要ならSQSを使う。これらは互いに独立しているが、組み合わせることであらゆるアーキテクチャを構築できる。一つの巨大な統合プラットフォームではなく、小さなプリミティブの集合体。この設計思想は、UNIXの「小さなプログラムを組み合わせる」哲学と通底している。

そしてこの思想は、AWSのサービス公開順序にも表れている。

```
AWSインフラサービスの公開順序:

  2004年11月  SQS（Simple Queue Service）     ── メッセージング
  2006年 3月  S3（Simple Storage Service）     ── ストレージ
  2006年 7月  SQS 本番公開（GA）              ── メッセージング（GA）
  2006年 8月  EC2（Elastic Compute Cloud）     ── 計算
  2008年 8月  EBS（Elastic Block Store）       ── ブロックストレージ

  メッセージング → ストレージ → 計算 → ブロックストレージ
```

EC2が最初ではなかった。SQSが2004年に、S3が2006年3月に公開され、EC2は2006年8月に公開されている。計算リソースの貸し出しだけが目的であれば、EC2を最初に出すのが自然だろう。だがAWSは、メッセージングとストレージを先に公開した。これは偶然ではない。AWSは最初から、独立した「ビルディングブロック」の集合体として設計されていた。

### なぜ「ビルディングブロック」なのか

この設計思想がなぜ重要なのか。一つの具体例で考えてみよう。

画像のリサイズ処理を構築する場合を想像してほしい。ユーザーがアップロードした画像を複数のサイズにリサイズし、配信する。従来のアーキテクチャでは、これを一台のサーバ上で同期的に処理していた。アップロード、リサイズ、保存、配信——全てが一つのサーバの中で完結する。

ビルディングブロック思想では、これが次のように分解される。

```
画像リサイズ処理——ビルディングブロックによる設計:

  ユーザー
    │
    │ 画像アップロード
    ▼
  ┌─────┐    PUT     ┌─────┐
  │ EC2 │ ─────────→ │ S3  │  ← 元画像を保存
  └─────┘            └──┬──┘
                        │
                        │ S3イベント通知
                        ▼
                     ┌─────┐
                     │ SQS │  ← リサイズ要求をキューに格納
                     └──┬──┘
                        │
                        │ ポーリング
                        ▼
                     ┌─────┐    PUT     ┌─────┐
                     │ EC2 │ ─────────→ │ S3  │  ← リサイズ済み画像を保存
                     │(別) │            └─────┘
                     └─────┘

  各コンポーネントは独立している:
  ── S3は画像の保存だけを担当する
  ── SQSはリサイズ要求の受け渡しだけを担当する
  ── EC2（リサイズワーカー）はリサイズ処理だけを担当する
  ── どのコンポーネントが故障しても、他は影響を受けない
  ── リサイズワーカーのEC2は負荷に応じて台数を増減できる
```

計算（EC2）、ストレージ（S3）、メッセージング（SQS）——この三つのプリミティブを組み合わせるだけで、スケーラブルで耐障害性の高いアーキテクチャが構築できる。一つのサーバに全てを詰め込む必要がない。各コンポーネントは独立してスケールし、独立して障害から回復する。

これがAWSの「ビルディングブロック」思想の核心だ。

---

## 3. S3——「ストレージをHTTP APIにする」という発明

### オブジェクトストレージという設計

S3（Simple Storage Service）は2006年3月14日に公開された。Pi Day——円周率の日——に公開されたこのサービスは、ストレージの概念を根本から再定義した。

S3を理解するには、まず「オブジェクトストレージ」という設計思想を、従来のストレージモデルと比較する必要がある。

```
3つのストレージモデル:

  ブロックストレージ（EBS, SAN）
  ── データを固定サイズのブロックに分割。低レイテンシー、高IOPS
  ── OSがファイルシステムを構築する基盤

  ファイルストレージ（EFS, NFS）
  ── 階層的なディレクトリ構造。複数クライアントから同時アクセス可能
  ── パーミッション、ロック機構あり

  オブジェクトストレージ（S3, GCS）
  ── フラットな名前空間。HTTP API（PUT/GET/DELETE）で操作
  ── ディレクトリ階層なし。カスタムメタデータ付与可能
  ── 大規模な非構造化データに最適
```

オブジェクトストレージにおいて、`images/photo-001.jpg` の `images/` はディレクトリではない。それはオブジェクトキー（名前）の一部にすぎない。S3には本質的にディレクトリという概念が存在しない。全てのオブジェクトはバケットというコンテナの中にフラットに配置される。S3のコンソールやCLIがディレクトリのように見せているのは、キー名のプレフィックスによる「模倣」に過ぎない。

この設計は意図的なものだ。ディレクトリ構造を持たないことで、S3はディレクトリのリネーム、移動、ロック管理といったファイルシステム特有の複雑さから解放される。その代わりに得たものは、事実上無制限のスケーラビリティだ。

### HTTP動詞がストレージAPIになる

S3のAPI設計は、RESTの原則を忠実に体現している。2006年の公開時、S3はREST、SOAP、BitTorrentの3つのプロトコルをサポートしていたが、中核となったのはREST APIだった。

S3のREST APIは、HTTPの標準動詞がそのままストレージ操作に対応する。`PUT /bucket/key` で格納、`GET /bucket/key` で取得、`DELETE /bucket/key` で削除。独自プロトコルは不要で、`curl`コマンドでもウェブブラウザでもアクセスできる。この「HTTPさえ話せれば使える」特性が、S3をあらゆる言語・プラットフォームから利用可能にした。

そしてS3のREST APIは事実上の標準となった。MinIO、Ceph、Cloudflare R2——S3互換APIを実装するストレージサービスは数多い。PUT/GET/DELETEという直感的な操作体系の学習コストの低さと実装の容易さが、この普及を支えている。

### イレブンナインの耐久性

S3の最も驚異的な設計目標は、99.999999999%——通称「イレブンナイン」の耐久性だ。

この数字が意味するところを具体的に示そう。1,000万個のオブジェクトをS3に保存した場合、1個のオブジェクトを失う確率は、計算上1万年に1回である。人類の文明が始まって約5,000年。その倍の期間をかけて、ようやく1個のオブジェクトが失われるかもしれないという設計目標だ。

ここで「耐久性（Durability）」と「可用性（Availability）」の違いを明確にしておく。耐久性はデータが失われない確率であり、可用性はデータにアクセスできる確率だ。S3 Standardの可用性は99.99%（フォーナイン）であり、年間約52分のダウンタイムを許容する。つまり、「データは消えないが、一時的にアクセスできないことはある」という設計だ。

S3がイレブンナインの耐久性をどのように達成しているか、その仕組みを見てみよう。

S3がこの耐久性を達成する仕組みは四つの柱からなる。(1) **複数AZへの分散保存**——オブジェクトは最低3つのAvailability Zoneに自動複製される。(2) **イレーシャーコーディング**——単純なコピーではなく、ストレージ効率を保ちながら冗長化する前方誤り訂正技術。(3) **バックグラウンド監査**——ストレージノードを定期スキャンし、破損を検出すれば自動修復。故障ディスクのデータは別ノードに再複製される。(4) **チェックサム検証**——格納時と取得時にチェックサムを照合し、サイレントなデータ破損を検出・修復する。

もちろん「99.999999999%」は設計目標であり、絶対的な保証ではない。だが、この設計目標を掲げ、それに見合うメカニズムを実装したこと自体が、ストレージの世界におけるパラダイムシフトだった。

S3の規模も桁違いだ。2025年時点で、S3には500兆を超えるオブジェクトが保存されており、毎秒2億リクエストを処理している。2006年の公開から約19年で、人類が生成するデータの相当な部分がこの一つのサービスの上に載っている。

### 結果整合性から強い整合性へ——14年間のトレードオフ

S3の設計において最も議論を呼んだのは、結果整合性（Eventual Consistency）モデルの採用だった。

2006年の公開から2020年まで、S3は結果整合性モデルを採用していた。具体的には、S3に新しいオブジェクトをPUTした直後にGETすると、最新のデータが返ってくる保証があった（新規PUT後のread-after-write consistency）。だが、既存オブジェクトを上書き（PUT）または削除（DELETE）した直後にGETすると、古いデータが返ってくる可能性があった。

具体的には、新規オブジェクトのPUT直後のGETは即座に整合した。だが既存オブジェクトの上書きPUTやDELETE直後のGETでは、古いデータが返る可能性があった。数秒〜数十秒後に結果的に整合する——これが「結果整合性」の意味だ。

なぜこのような設計を選んだのか。ここでCAP定理に触れる必要がある。

2000年、Eric BrewerがPODC（ACM Symposium on Principles of Distributed Computing）で一つの予想を提示した。2002年にSeth GilbertとNancy Lynch（MIT）がこれを正式に証明し、CAP定理として確立された。その内容は次のとおりだ。

```
CAP定理:

  分散システムは、以下の3つの性質を
  同時に完全には満たすことができない。

  C: 一貫性（Consistency）
     全てのノードが同じ時点で同じデータを返す

  A: 可用性（Availability）
     全てのリクエストに対して応答を返す

  P: 分断耐性（Partition Tolerance）
     ネットワークの分断が発生しても動作し続ける

  ── 分散システムではネットワーク分断は避けられない。
     したがってPは必須。
  ── 残りのCとAの間でトレードオフを選ぶ必要がある。

  S3（2006-2020年）は:
  ── Pを前提とし
  ── A（可用性）を優先し
  ── C（一貫性）を緩和した（結果整合性）
```

S3は地理的に離れた複数のAZにデータを分散保存する。ネットワーク分断は現実的に発生しうる。その状況で可用性を維持するために、一貫性を「結果的に整合する」レベルまで緩和した。書き込みが全てのレプリカに伝播するまでの短い時間、古いデータが返る可能性を許容することで、書き込み操作をブロックせず、高い可用性を実現した。

2008年、Werner VogelsはACM Queueに「Eventually Consistent」を発表し、この設計判断の背後にある理論を体系化した。Vogelsは、分散システムにおける整合性のレベルは一つではなく、アプリケーションの要件に応じて選択すべきものだと主張した。結果整合性、因果整合性、read-your-writes整合性、セッション整合性——整合性にはグラデーションがあり、強い整合性を要求するほどレイテンシーとスループットのコストが増大する。

同じ2007年には、AmazonのエンジニアチームがSOSP（ACM Symposium on Operating Systems Principles）で「Dynamo: Amazon's Highly Available Key-value Store」を発表していた。Giuseppe DeCandiaらによるこの論文は、一貫性ハッシュ、ベクタークロック、クォーラムプロトコル、ゴシップベースの障害検出といった分散システムの技法を組み合わせた高可用性キーバリューストアの設計を記述した。Dynamoの設計思想——可用性を一貫性より優先する——は、S3やSQSの設計判断と共通の根を持っている。

そして2020年12月2日、re:Invent 2020で、AWSはS3の全操作（GET、PUT、LIST、およびタグ・ACL・メタデータの変更操作）で強い読み取り後書き込み整合性（strong read-after-write consistency）を提供すると発表した。追加費用なし。パフォーマンスへの影響なし。14年間続いた結果整合性モデルからの転換だった。

この発表の意味は深い。2006年時点では、強い整合性を達成しながらS3のスケーラビリティと可用性を維持することは、工学的に困難だった。だが14年間の技術的蓄積——ハードウェアの進化、分散システムのアルゴリズムの改善、AWS内部のインフラ最適化——が、このトレードオフを解消した。CAP定理は依然として有効だが、「CとAのどちらかを完全に犠牲にする」のではなく、「工学的な努力によってトレードオフの影響を最小化できる」ことを、S3は実証した。

---

## 4. SQS——分散システムの「接着剤」

### AWSの最初のインフラサービス

前回の第8回で、AWSのサービス公開順序について触れた。EC2（2006年8月）が注目を集めがちだが、実はSQS（Simple Queue Service）こそがAWSインフラサービスとして最初に発表されたサービスだ。

2004年11月、SQSは静かにベータとして公開された。メッセージキューイングサービス——コンポーネント間で非同期にメッセージを受け渡すためのマネージドサービスだ。本番公開（GA）は2006年7月13日。EC2のベータ公開（2006年8月）よりわずかに先行している。

なぜメッセージキューが、AWSの最初のサービスだったのか。

この問いに答えるには、メッセージキューが分散システムにおいて果たす役割を理解する必要がある。

### なぜメッセージキューが必要なのか

分散システムにおいて、コンポーネント間の通信は根本的な課題だ。AがBにメッセージを送りたいとき、最も単純な方法は直接通信（同期通信）だ。AがBにHTTPリクエストを送り、Bがレスポンスを返す。

同期通信では、Bが停止していればAのリクエストは失敗し、Bが遅ければAも遅くなり、トラフィックが急増すればBの過負荷がAに連鎖する。送信側と受信側が密に結合しているのだ。

メッセージキューは、この結合を「間接的な非同期通信」によって解く。

```
非同期通信（メッセージキュー経由）:

  サービスA ──PUT──→ [SQS キュー] ←──POLL── サービスB

  ── Bが停止中 → メッセージはキューに蓄積。B復旧後に順次処理
  ── Bが遅い   → Aはキューに入れた時点で完了。Bは自分のペースで消費
  ── 急増時    → キューがバッファ。ワーカー数を増やしてスケール
```

メッセージキューの本質は「時間的なデカップリング」だ。送信者と受信者が同じ時刻に稼働している必要がない。送信者は受信者の処理速度を気にする必要がない。このデカップリングが、分散システムの耐障害性とスケーラビリティを根本的に改善する。

### SQSの設計思想

SQSの設計には、分散システムの現実に根ざしたいくつかの重要な判断がある。

**「少なくとも1回」の配信保証（At-Least-Once Delivery）**

SQS Standardキューは「少なくとも1回」のメッセージ配信を保証する。つまり、メッセージが失われることはないが、同じメッセージが2回以上配信される可能性がある。

```
At-Least-Once Deliveryの仕組み:

  プロデューサ → [キュー] → コンシューマ

  1. プロデューサがメッセージを送信
     → SQSは複数のサーバに冗長に保存

  2. コンシューマがメッセージを受信
     → SQSはメッセージを「非表示」にする
     （Visibility Timeout）

  3. コンシューマが処理完了後、メッセージを削除
     → SQSからメッセージが除去される

  もし3が実行されなかった場合（コンシューマの障害等）:
     → Visibility Timeout後にメッセージが再表示される
     → 別のコンシューマ（または同じコンシューマ）が再受信
     → 結果として、メッセージは「少なくとも1回」配信される
```

なぜ「正確に1回（Exactly Once）」ではなく「少なくとも1回」なのか。分散システムにおいて、ネットワーク障害やノード障害が発生しうる環境で「正確に1回」の配信を保証することは、極めて困難だ。メッセージの送信確認がネットワーク障害で失われた場合、送信者はメッセージが届いたか確認できない。再送すれば重複し、再送しなければ消失する。この二択のうち、SQSは「重複する可能性があるが、絶対に失わない」方を選んだ。

2016年11月、AWSはSQS FIFOキューを発表した。メッセージの順序保証と、5分間の重複排除インターバルを使った「正確に1回の処理（Exactly-Once Processing）」を提供する。ただし、FIFOキューはStandardキューに比べてスループットが制限される（1秒あたり300メッセージ、バッチ処理で3,000メッセージ）。ここにもトレードオフがある——順序保証と重複排除を得る代わりに、スループットを犠牲にする。

**分散メッセージキューとしての設計**

SQS自体が分散システムとして設計されている。メッセージは複数のサーバに冗長に保存され、単一障害点が存在しない。キューのサイズに上限はなく（事実上無制限）、リクエスト数に応じて自動的にスケールする。

これは自前でメッセージキューを運用する場合とは対照的だ。RabbitMQやActiveMQを自前で運用した経験がある人なら、ブローカーの高可用性構成、ディスク溢れ、ネットワーク分断時の振る舞い——これらの問題に頭を悩ませたことがあるだろう。SQSはこれらの運用課題をマネージドサービスとして吸収する。

### メッセージキューの設計パターン

SQSの上に構築される代表的な設計パターンは三つある。

第一に、**ワークキュー（Producer-Consumer）パターン**。複数のプロデューサがメッセージを送信し、複数のコンシューマ（ワーカー）が処理する。ワーカー数を増減するだけでスケーリングが可能だ。本稿のハンズオンで扱う画像リサイズの例がこれに当たる。

第二に、**ファンアウトパターン**。SNS（Simple Notification Service）と組み合わせ、1つのイベントを複数のSQSキューに分岐させる。たとえば注文イベントを、メール通知キュー、在庫更新キュー、分析キューに同時配信する。

第三に、**デッドレターキュー（DLQ）パターン**。処理に一定回数失敗したメッセージを別のキューに隔離し、後から原因調査と再処理を行う。障害が連鎖的にシステムを停止させるのを防ぐ安全弁だ。

これらはSQS固有のパターンではない。メッセージキューイングの世界で長年蓄積されてきた設計知識だ。だが、SQSがこれらをマネージドサービスとして提供したことで、開発者はメッセージングの「使い方」に集中でき、メッセージングの「運用」から解放された。

---

## 5. ハンズオン——S3とSQSの操作を体験する

ここからは、S3互換のオブジェクトストレージとSQSの概念を実際に手を動かして体験する。MinIO（S3互換オブジェクトストレージ）を使い、AWSアカウントなしでビルディングブロックの設計思想を体感する。

### 環境

- Docker（Ubuntu 24.04ベースコンテナ）
- MinIO（S3互換オブジェクトストレージ）
- AWS CLI v2
- Python 3

### 演習1：MinIOでS3互換APIを体験する

MinIOはS3互換APIを実装したオープンソースのオブジェクトストレージだ。AWS CLIがそのまま使える。これ自体が、S3 APIが事実上の標準となった証拠だ。

```bash
# MinIOをDockerで起動
docker run -d --name minio \
  -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  minio/minio server /data --console-address ':9001'

# AWS CLIの設定（MinIO用）
export AWS_ACCESS_KEY_ID=minioadmin
export AWS_SECRET_ACCESS_KEY=minioadmin
export AWS_DEFAULT_REGION=us-east-1
ENDPOINT=http://localhost:9000

# バケットの作成
aws s3 mb s3://my-first-bucket --endpoint-url $ENDPOINT

# オブジェクトの基本操作（PUT / GET / DELETE）
echo "Hello, S3!" > /tmp/hello.txt
aws s3 cp /tmp/hello.txt s3://my-first-bucket/hello.txt \
  --endpoint-url $ENDPOINT                              # PUT
aws s3 cp s3://my-first-bucket/hello.txt /tmp/dl.txt \
  --endpoint-url $ENDPOINT                              # GET
aws s3 ls s3://my-first-bucket/ --endpoint-url $ENDPOINT # LIST
aws s3 rm s3://my-first-bucket/hello.txt \
  --endpoint-url $ENDPOINT                              # DELETE
```

PUT/GET/DELETE——HTTPの3つの動詞だけで全ての基本操作が完結する。

### 演習2：フラット名前空間を確認する

```bash
# 「ディレクトリ」に見えるオブジェクトを作成
echo "photo" | aws s3 cp - s3://my-first-bucket/images/photo-001.jpg \
  --endpoint-url $ENDPOINT
echo "photo" | aws s3 cp - s3://my-first-bucket/images/photo-002.jpg \
  --endpoint-url $ENDPOINT
echo "log"   | aws s3 cp - s3://my-first-bucket/logs/2024-01-01.json \
  --endpoint-url $ENDPOINT

# 全オブジェクト一覧
aws s3 ls s3://my-first-bucket/ --recursive --endpoint-url $ENDPOINT
# images/photo-001.jpg, images/photo-002.jpg, logs/2024-01-01.json
# 「images/」はディレクトリではない。キー名の一部にすぎない。

# メタデータの確認
aws s3api head-object \
  --bucket my-first-bucket \
  --key images/photo-001.jpg \
  --endpoint-url $ENDPOINT
# ContentLength, ContentType, ETag——
# オブジェクトごとにメタデータがAPIで取得可能だ。
```

### 演習3：SQSの核心——Visibility Timeoutを体験する

SQSの本質を理解するために、Pythonでメッセージキューの核心部分を実装する。

```python
#!/usr/bin/env python3
"""簡易メッセージキュー -- SQS概念デモ"""
import time, uuid, threading
from collections import deque
from dataclasses import dataclass

@dataclass
class Message:
    message_id: str
    body: str
    receipt_handle: str = ""
    visible_after: float = 0
    receive_count: int = 0

class SimpleQueue:
    def __init__(self, visibility_timeout=30):
        self._msgs = deque()
        self._lock = threading.Lock()
        self._vt = visibility_timeout

    def send(self, body):
        m = Message(message_id=uuid.uuid4().hex[:8], body=body)
        with self._lock: self._msgs.append(m)
        return m.message_id

    def receive(self):
        now = time.time()
        with self._lock:
            for m in self._msgs:
                if m.visible_after <= now:
                    m.receipt_handle = uuid.uuid4().hex[:8]
                    m.visible_after = now + self._vt
                    m.receive_count += 1
                    return m
        return None

    def delete(self, handle):
        with self._lock:
            for i, m in enumerate(self._msgs):
                if m.receipt_handle == handle:
                    del self._msgs[i]; return True
        return False

# --- Producer-Consumer デモ ---
q = SimpleQueue(visibility_timeout=3)

# Producer
for task in ["img-001をリサイズ", "img-002をリサイズ", "img-003をリサイズ"]:
    mid = q.send(task)
    print(f"送信: {task} (ID: {mid})")

# Consumer: 正常系（受信 → 処理 → 削除）
while (m := q.receive()):
    print(f"受信: {m.body} (count={m.receive_count})")
    q.delete(m.receipt_handle)  # 削除しないと再配信される

# At-Least-Once Delivery デモ
q2 = SimpleQueue(visibility_timeout=2)
q2.send("重要なタスク")

m = q2.receive()
print(f"\n1回目受信: {m.body} (count={m.receive_count})")
print("→ 削除しない（処理失敗を想定）")

time.sleep(3)  # Visibility Timeout超過

m = q2.receive()
print(f"2回目受信: {m.body} (count={m.receive_count})")
print("→ 同じメッセージが再配信された（At-Least-Once）")
q2.delete(m.receipt_handle)
```

このデモで確認できるのは、SQSの3つの核心概念だ。(1) メッセージは明示的に削除するまでキューに残る。(2) 受信されたメッセージはVisibility Timeoutの間「非表示」になり、他のコンシューマには見えない。(3) Timeout内に削除されなければメッセージは再表示され、再配信される。これが「少なくとも1回」の配信保証を実現するメカニズムだ。

### 演習4：ビルディングブロックの組み合わせ——画像処理パイプライン

S3（ストレージ）+ SQS（メッセージング）+ EC2（計算）を組み合わせた画像処理パイプラインの設計を、CLIコマンドで表現する。

```bash
# バケットとキューの作成
aws s3 mb s3://original-images
aws s3 mb s3://resized-images
aws sqs create-queue --queue-name image-resize-queue

# 1. 元画像をアップロード（パイプラインの起点）
aws s3 cp photo.jpg s3://original-images/photo.jpg
# → S3イベント通知がSQSにメッセージを送信

# 2. ワーカーがメッセージを受信
aws sqs receive-message --queue-url <queue-url>

# 3. ワーカーが画像を取得・リサイズ・保存
aws s3 cp s3://original-images/photo.jpg /tmp/photo.jpg
# （リサイズ処理）
aws s3 cp /tmp/photo-resized.jpg s3://resized-images/photo.jpg

# 4. 処理完了、メッセージを削除
aws sqs delete-message --queue-url <queue-url> \
  --receipt-handle <handle>
```

各コンポーネントは独立している。S3は保存だけ、SQSは受け渡しだけ、EC2はリサイズ処理だけを担当する。ワーカー数を増やせば処理速度が上がり、一つのコンポーネントの障害が全体を停止させない。これがビルディングブロック思想の実践だ。

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/09-s3-sqs-building-blocks/` に用意してある。

---

## 6. まとめと次回予告

### この回のまとめ

第9回では、EC2に続くAWSの基本構成要素——S3（ストレージ）とSQS（メッセージング）——の設計思想と、それらを貫く「ビルディングブロック」思想を追った。

**クラウドの本質は「サーバの仮想化」ではない。** 計算（EC2）、ストレージ（S3）、メッセージング（SQS）という独立したプリミティブをAPIで組み合わせる基盤——それがクラウドだ。2002年頃のBezosのAPIマンデートに端を発するこの「ビルディングブロック」思想が、AWSの設計原則を貫いている。

**S3はストレージをHTTP APIに変えた。** フラットな名前空間とPUT/GET/DELETEのシンプルさが事実上の標準を生み、イレブンナインの耐久性設計が2025年時点で500兆オブジェクトを支えている。

**結果整合性は「設計判断」だった。** CAP定理に基づき可用性を優先した14年間の選択を、2020年に技術的蓄積が克服した。Werner Vogelsの「Eventually Consistent」やDynamoペーパーが理論的背景を提供し、S3は追加費用なしで強い整合性を実現した。

**SQSは分散システムの「接着剤」だ。** 「少なくとも1回」の配信保証とVisibility Timeoutによる再配信メカニズムが、送信者と受信者を時間的にデカップリングし、耐障害性とスケーラビリティを根本的に改善する。

冒頭の問いに答えよう。「計算（EC2）だけでクラウドは成り立つのか？」——否だ。計算とストレージを分離し、各コンポーネントを独立したビルディングブロックとして組み合わせる設計思想が、クラウドを「レンタルサーバの進化版」から「アーキテクチャの構築基盤」に転換させた。

### 次回予告

第10回では、「Azure、GCP——寡占と競争の構造」を探る。

AWSが確立した「ビルディングブロック」思想は、クラウドコンピューティングのパラダイムを定義した。だがAWSの独走は、当然ながら競合の参入を招いた。2008年にGoogle App Engine、2010年にMicrosoft Azure——後発組はAWSの模倣ではなく、それぞれ独自の設計思想でクラウド市場に挑んだ。

Azureは「エンタープライズ統合プラットフォーム」として。GCPは「Googleスケールの技術の外部提供」として。同じ「クラウド」という名のもとに、異なる設計哲学が並立している。そしてこの差異こそが、クラウド選定において理解すべき本質だ。

あなたがAWS、Azure、GCPのいずれかを選ぶとき——その判断は技術的な機能比較だけで下されているだろうか。それとも、各社の設計思想と、自組織の文化との相性も考慮しているだろうか。

---

## 参考文献

- Vogels, W., "Happy 15th Birthday Amazon S3 -- the service that started it all", All Things Distributed, 2021. <https://www.allthingsdistributed.com/2021/03/happy-15th-birthday-amazon-s3.html>
- Amazon, "Amazon Web Services Launches", Press Release, 2006. <https://press.aboutamazon.com/2006/3/amazon-web-services-launches>
- AWS, "Amazon SQS – 15 Years and Still Queueing!", AWS News Blog, 2019. <https://aws.amazon.com/blogs/aws/amazon-sqs-15-years-and-still-queueing/>
- Vogels, W., "Amazon EBS - Elastic Block Store has launched", All Things Distributed, 2008. <https://www.allthingsdistributed.com/2008/08/amazon_ebs_elastic_block_store.html>
- Vogels, W., "Eventually Consistent - Revisited", All Things Distributed, 2008. <https://www.allthingsdistributed.com/2008/12/eventually_consistent.html>
- Vogels, W., "Eventually Consistent", ACM Queue, Volume 6, Issue 6, 2008. <https://queue.acm.org/detail.cfm?id=1466448>
- DeCandia, G. et al., "Dynamo: Amazon's Highly Available Key-value Store", SOSP 2007. <https://www.amazon.science/publications/dynamo-amazons-highly-available-key-value-store>
- AWS, "Amazon S3 Update – Strong Read-After-Write Consistency", AWS News Blog, 2020. <https://aws.amazon.com/blogs/aws/amazon-s3-update-strong-read-after-write-consistency/>
- AWS, "Data protection in Amazon S3", AWS Documentation. <https://docs.aws.amazon.com/AmazonS3/latest/userguide/DataDurability.html>
- AWS, "Amazon SQS Introduces FIFO Queues with Exactly-Once Processing", 2016. <https://aws.amazon.com/about-aws/whats-new/2016/11/amazon-sqs-introduces-fifo-queues-with-exactly-once-processing-and-lower-prices-for-standard-queues/>
- Yegge, S., "Stevey's Google Platforms Rant", 2011. <https://gist.github.com/kislayverma/d48b84db1ac5d737715e8319bd4dd368>
- Kong Inc., "API Mandate: How Jeff Bezos' memo changed software forever". <https://konghq.com/blog/enterprise/api-mandate>
- Gilbert, S. & Lynch, N., "Brewer's Conjecture and the Feasibility of Consistent, Available, Partition-Tolerant Web Services", ACM SIGACT News, 2002. <https://users.ece.cmu.edu/~adrian/731-sp04/readings/GL-cap.pdf>
- Wikipedia, "CAP theorem". <https://en.wikipedia.org/wiki/CAP_theorem>
- AWS, "Block vs File vs Object Storage", AWS Documentation. <https://aws.amazon.com/compare/the-difference-between-block-file-object-storage/>
