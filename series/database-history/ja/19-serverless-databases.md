# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第19回：サーバレスDB——運用からの解放

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- マネージドDBからサーバレスDBへの進化の系譜——Amazon RDS（2009年）からAurora、PlanetScale、Neonへ
- Amazon Auroraの「ログこそがデータベース」設計——コンピュートとストレージの分離がもたらした革新
- PlanetScale（2018年設立、2021年GA）の背景——YouTube由来のVitessとオンラインスキーマ変更
- Neon（2021年設立、2022年ローンチ）のアーキテクチャ——Pageserver / Safekeeper / Computeの3層構造
- Turso（2023年）とCloudflare D1（2022年）——SQLiteベースのエッジDB革命
- サーバレスDB固有の課題——コールドスタート、コネクションプーリング、コスト予測の難しさ

---

## 1. 深夜3時のページャが鳴らなくなった日

2015年頃、私はあるプロジェクトでMySQLの運用を担当していた。

マスタ・スレーブ構成のMySQL 5.6、物理サーバ3台。第11回で語ったレプリケーションの世界そのものだ。深夜のバッチ処理でディスクI/Oが跳ね、スロークエリが増え、レプリケーションが遅延する。アラートが飛ぶ。起きて、ターミナルを開き、`SHOW PROCESSLIST`を叩き、問題のクエリを`KILL`する。バイナリログの同期状況を確認し、スレーブが追いついたことを確認して、ようやく眠りに戻る。

この生活が変わったのは、Amazon RDSに移行したときだ。

バックアップは自動化された。フェイルオーバーはMulti-AZ配置で自動化された。パッチ適用のウィンドウは設定画面でスケジュールするだけだ。深夜3時のページャは、鳴らなくなった。

だが、RDSに移行してもなお残る運用がある。インスタンスサイズの選定。リードレプリカの追加・削除。スケールアップ時のダウンタイム。パラメータグループの調整。そして何より、使っていない時間帯にも課金され続けるインスタンス。開発環境のRDSインスタンスは、エンジニアが寝ている間も、誰にも使われないまま稼働し続ける。

「運用から完全に解放される日は来るのか」——この問いは、データベースの歴史の中で繰り返し問われてきた。マネージドDBは運用の大部分を引き受けた。だが「サーバレスDB」は、さらにその先を目指している。サーバのプロビジョニング、スケーリング、さらには「使わない時間の課金」からの解放だ。

あなたが今、開発環境のデータベースに月額いくら払っているか考えてほしい。そのデータベースは、1日のうち何時間実際に使われているだろうか。8時間？ 4時間？ もしかすると1時間も使われていないかもしれない。残りの23時間分の課金は、本当に必要なのだろうか。

---

## 2. マネージドDBからサーバレスDBへ——運用抽象化の系譜

### Amazon RDS——「運用のアウトソーシング」の始まり

データベース運用の歴史を振り返ると、抽象化のレイヤーが段階的に積み上がってきたことがわかる。

2009年10月、AmazonはAmazon RDS（Relational Database Service）をリリースした。最初にサポートされたのはMySQL 5.1のみだ。RDSの価値提案は明快だった——データベースのインストール、パッチ適用、バックアップ、リカバリ、フェイルオーバーをAWSが代行する。ユーザーはインスタンスタイプを選び、データベースエンジンを指定するだけでよい。

これは革命的だった。それまでのデータベース運用は、ハードウェアの調達から始まる。RAIDの構成、OSのインストール、データベースソフトウェアのインストールとチューニング、バックアップスクリプトの実装、監視の設定、障害時の対応手順書の整備——これらすべてがDBA（データベース管理者）の責務だった。RDSはこの責務の大部分をAWS側に移した。

だがRDSには「サーバ」の概念が残っている。`db.m5.xlarge`か`db.r6g.2xlarge`か、インスタンスタイプを選ばなければならない。この選定は本質的に「未来のワークロードを予測する」行為であり、過小評価すればパフォーマンス不足に陥り、過大評価すればコストを浪費する。

### Amazon Aurora——「ログこそがデータベース」

2014年11月のAWS re:Invent 2014で、Amazonは新たなデータベースを発表した。Amazon Auroraだ。GAは2015年7月。

Auroraの設計思想は、2017年のSIGMOD論文「Amazon Aurora: Design Considerations for High Throughput Cloud-Native Relational Databases」（Verbitski et al.）に詳述されている。その核心は一つの洞察にある——「高スループットなデータ処理のボトルネックは、コンピュートやストレージではなくネットワークに移った」。

従来のRDBMSは、データページ全体をストレージに書き込む。Auroraはこの設計を根本から覆した。コンピュートノードからストレージ層に送信するのは、Redo Log（変更の差分記録）のみだ。データページ全体に比べてRedo Logは遥かに小さく、ネットワークI/Oを劇的に削減できる。

```
従来のRDBMS vs Aurora のI/O設計

 従来のRDBMS
 ┌──────────────────┐
 │  Compute Node    │
 │  (MySQL/PG)      │
 └───────┬──────────┘
         │  データページ全体を書き込み
         │  (16KB x N ページ)
         ▼
 ┌──────────────────┐
 │  ストレージ       │
 │  (EBS等)         │
 └──────────────────┘

 Amazon Aurora
 ┌──────────────────┐
 │  Compute Node    │
 │  (MySQL/PG互換)   │
 └───────┬──────────┘
         │  Redo Logのみ送信
         │  (数十〜数百バイト)
         ▼
 ┌───────────────────────────────────┐
 │  Aurora Storage (分散ストレージ)    │
 │                                   │
 │  AZ-1      AZ-2      AZ-3        │
 │ ┌─────┐  ┌─────┐  ┌─────┐       │
 │ │Node1│  │Node3│  │Node5│       │
 │ │Node2│  │Node4│  │Node6│       │
 │ └─────┘  └─────┘  └─────┘       │
 │                                   │
 │  6ノードに書き込み                  │
 │  4/6のクォーラムでコミット確認       │
 │  ストレージ層がページをマテリアライズ  │
 └───────────────────────────────────┘
```

「ログこそがデータベース（The log is the database）」——Auroraのストレージ層はRedo Logからデータページを再構築できる。チェックポイントもリカバリもストレージフリートにオフロードされる。コンピュートノードがクラッシュしても、従来のWALリプレイが不要なため、リカバリはほぼ瞬時に完了する。

この設計は、コンピュートとストレージの分離という概念を実用レベルで証明した。コンピュートとストレージが独立しているなら、コンピュートだけを止めて、ストレージだけを生かしておくこともできるはずだ。この発想が、サーバレスDBへの道を開いた。

### Aurora Serverless——最初の「サーバレスDB」

2018年8月、AWSはAurora Serverless（v1）をGAとしてリリースした。従来のAuroraがインスタンスサイズの固定を要求したのに対し、Aurora Serverlessはワークロードに応じて自動的にスケールする。

だがv1には大きな制約があった。スケーリングの際に接続が切断されることがあった。スケーリングの粒度も粗く、レスポンスにも遅延が生じた。

2022年4月、Aurora Serverless v2がGAとなった。v2は根本的に改善されている。スケーリングはミリ秒単位で行われ、接続を切断しない。Aurora Capacity Unit（ACU）という単位で、0.5 ACU（約1GiBメモリ）から128 ACU（約256GiBメモリ）まで、0.5 ACU刻みの細粒度でスケールする。

だがAurora Serverlessには一つ、重大な制約が残っていた。v1にはあった「ゼロスケール」——完全にコンピュートを停止して課金をゼロにする機能——がv2では提供されなかった（v1は2024年に廃止された）。つまり、Aurora Serverless v2は「使っていない時間のコスト」問題を完全には解決しない。最低0.5 ACUの課金は常に発生する。

この「ゼロスケール」の不在こそが、次世代のサーバレスDBが解決しようとした課題の一つだ。

---

## 3. サーバレスDBの新世代——PlanetScale, Neon, Turso

### PlanetScale——YouTubeのスケーリング技術を万人に

PlanetScaleの物語は、YouTubeの裏側から始まる。

Jiten VaidyaとSugu Sougoumarane。二人はインド工科大学ボンベイ校で出会い、後にYouTubeでVitessを開発した。Vitessは2010年にYouTubeの動画メタデータを管理するために作られた水平スケーリングシステムだ。MySQLの上に分散レイヤーを構築し、シャーディング、コネクション管理、クエリルーティングを透過的に処理する。第11回で語ったシャーディングの苦しみを、ミドルウェアで自動化したのがVitessだ。

2018年、VaidyaとSougoumaraneはPlanetScale社を設立した。Vitessの技術を、誰もが使えるサーバレスDBプラットフォームとして提供するためだ。後にSam Lambert（元GitHubのインフラチームリーダー）がCEOに就任し、開発者体験（DX）の設計を主導した。

PlanetScaleのサーバレスDBプラットフォームは2021年5月にベータ、2021年11月にGAとなった。Vitessベース、MySQL互換。だがPlanetScaleが開発者の心を掴んだのは、MySQL互換であること以上に、二つの革新的な機能によるところが大きい。

**第一に、データベースブランチング。** gitのブランチモデルをデータベースに適用した。本番のスキーマをブランチし、そこでスキーマ変更をテストし、問題なければ本番にマージする。Deploy Request（Pull Requestに相当）でスキーマ変更のレビューとデプロイを管理できる。

**第二に、ノンブロッキングスキーマ変更。** Vitessのオンラインスキーマ変更機能を活用し、本番テーブルをロックせずにスキーマを変更する。内部的にはゴーストテーブル（元テーブルのコピー）を作成し、ALTER TABLEをゴーストテーブルに適用し、データを同期した上でカットオーバー（テーブルの交換）を行う。本番トラフィックへの影響は最小限だ。トラフィックスパイク時にはマイグレーション処理を自動的にスケールダウンし、必要に応じてロールバックも可能だ。

ただしPlanetScaleの道は平坦ではない。2024年3月、PlanetScaleはHobbyプラン（無料ティア）の廃止を発表した。2024年4月8日以降、すべてのデータベースに有料のScaler Proプランが必要となった。「無料で広く普及させ、有料プランで収益化する」モデルの転換だ。前回触れたCockroachDBのライセンス変遷と同様、サーバレスDBビジネスの収益化の難しさを物語っている。

### Neon——PostgreSQLの「サーバレスネイティブ」再設計

2021年、Nikita Shamgunov、Heikki Linnakangas、Stas Kelvichの3名がNeonを設立した。

3人のバックグラウンドは注目に値する。ShamgunovはMicrosoft SQL Serverチームの出身で、その後SingleStoreの共同創業者・CEOを務めた。LinnakanasはPostgreSQLコミッターとして20年以上の経験を持つ——育休中にPostgreSQLの内部実装を「暇つぶし」で読み始めたのが最初だという。KelvichはR-tree実装のためにPostgreSQLのハッキングに入った元物理学者だ。データベースのビジネスを知る者、PostgreSQLの内部を知り尽くした者、そして異なる分野からの視点を持つ者——この組み合わせは意図的だ。

Neonは2022年にパブリックローンチした。PostgreSQL互換のサーバレスDB。だがNeonは単にPostgreSQLをクラウドでホスティングしているのではない。PostgreSQLのストレージ層を完全に置き換えている。

```
Neonのアーキテクチャ

 ┌────────────────────────────────┐
 │  Compute Node                  │
 │  (ステートレスなPostgreSQLインスタンス)│
 │  ・標準PostgreSQL互換           │
 │  ・ローカルディスク書き込みなし    │
 │  ・メモリ → NVMeキャッシュ       │
 │    → Pageserver の順で読み取り   │
 └────────┬───────────────────────┘
          │ WAL (Write-Ahead Log)
          ▼
 ┌──────────────────────────────────┐
 │  Safekeeper (WAL冗長化サービス)    │
 │  ・Paxos合意でWALを冗長保存       │
 │  ・クォーラムの確認でコミット完了    │
 │  ・Pageserverに処理済みWALを転送   │
 └────────┬───────────────────────────┘
          │ 処理済みWAL
          ▼
 ┌──────────────────────────────────┐
 │  Pageserver (ストレージバックエンド) │
 │  ・WALからページバージョンを         │
 │    マテリアライズ                   │
 │  ・Layer Fileに変換して保存         │
 │  ・Copy-on-Writeでブランチ実現      │
 │  ・クラウドストレージ(S3)に永続化    │
 └──────────────────────────────────┘
```

**Compute Node**はステートレスなPostgreSQLインスタンスだ。ローカルディスクへの書き込みは行わず、すべてのWALをSafekeeperに送信する。ステートレスであるため、起動・停止が高速であり、これがScale to Zero（後述）を可能にしている。

**Safekeeper**はWALの冗長化サービスだ。Compute NodeからWALを受信し、Paxos合意によりクォーラムを満たしたWALレコードをコミット済みとみなす。WALの安全な保存を担保し、Pageserverとの間で処理済みWALを転送する。

**Pageserver**はNeonのストレージエンジンの核心だ。受信したWALを処理し、ページバージョンをマテリアライズ（再構築）する。WALをリレーションとページごとにスライスし、Layer Fileと呼ばれるファイル形式に変換して保存する。最終的にはクラウドストレージ（Amazon S3等）に永続化される。

この3層分離には明確な設計上の理由がある。Neonの技術ブログによれば、WALサービス（Safekeeper）とページサーバ（Pageserver）を分離することで、合意アルゴリズムの正確性を独立に検証できる。また、I/Oパターンが根本的に異なるコンポーネント（Safekeeperは追記専用、Pageserverは読み書き更新）をハードウェアレベルで最適化できる。

Neonの最も革新的な機能が**ブランチング**だ。gitのブランチと同じ感覚で、データベースの完全なコピーを瞬時に作成できる。内部的にはCopy-on-Write——ポインタの移動だけでブランチが生成され、以降の書き込みのみが差分として記録される。ストレージコストはほぼゼロだ。

```bash
# Neon CLI でブランチを作成
neon branches create --name feature-auth --parent main

# ブランチは独立したPostgreSQL接続文字列を持つ
# 本番データの完全なコピーで、安全にテスト可能
psql "postgresql://user:pass@ep-xxx.us-east-2.aws.neon.tech/dbname"
```

開発ブランチ、ステージングブランチ、フィーチャーブランチ——gitで当たり前のワークフローが、データベースでも可能になる。スキーマ変更のテスト、マイグレーションの検証、本番データを使った開発——これらをブランチ上で安全に行い、問題がなければ本番に反映する。

そしてNeonは**Scale to Zero**を実現した。デフォルトで5分間のインアクティビティの後、Compute Nodeを自動的に停止する。ストレージ（Pageserver + S3）はデータを保持し続けるが、コンピュートの課金はゼロになる。次のクエリが到着すると、数百ミリ秒でCompute Nodeが再起動する。

開発環境のデータベースが、使っていない23時間は課金されない。これはAurora Serverless v2では実現できなかった「ゼロスケール」だ。

2025年5月、Databricksが約10億ドルでNeonの買収を発表した。サーバレスPostgreSQLの技術的価値が、業界にどう評価されているかを示す一つの指標だ。

### Turso——SQLiteをエッジに持っていく

2022年、ChiselStrike社（創業者: Glauber Costa）はSQLiteをフォークし、libSQLプロジェクトを立ち上げた。

SQLiteは世界で最も広くデプロイされたデータベースだ。すべてのスマートフォン、ほとんどのWebブラウザ、無数の組込みシステムに搭載されている。だがSQLiteには一つの特殊な性質がある——オープンソースだが、外部からのコントリビューションを受け付けない。ソースコードは公開されているが、開発はSQLiteのコアチーム（D. Richard Hipp率いるHwaci社）が完全にコントロールしている。

libSQLは「Open Source かつ Open Contribution」なSQLiteフォークとして出発した。SQLiteとの後方互換性を保ちながら、サーバモード（HTTPアクセス）、ネイティブベクトル検索など、元のSQLiteでは実現できない機能を追加している。

2023年初頭、ChiselStrikeはTursoを発表した。libSQLをベースとしたエッジサーバレスDBだ。Tursoの設計思想は、NeonやPlanetScaleとは根本的に異なる。MySQLやPostgreSQLのような「重い」RDBMSをサーバレスにするのではなく、「軽い」SQLiteをグローバルに分散させる。

Tursoの特徴的な機能が**Embedded Replicas**だ。アプリケーションサーバの中にSQLiteのレプリカを組み込み、読み取りクエリをローカルで処理する。書き込みはTursoのプライマリに送信され、Raft的なレプリケーションでレプリカに伝播する。データがアプリケーションと同一プロセスにあるため、ネットワークレイテンシがゼロに近い読み取りが可能だ。

### Cloudflare D1——エッジのSQLite

2022年5月、CloudflareはD1を発表した。Cloudflare Workersのためのサーバレスデータベースだ。

D1もSQLiteベースだが、Tursoとは異なるアプローチを取る。Cloudflareのエッジインフラ（世界300以上のデータセンター）にSQLiteデータベースを配置し、読み取りレプリカをユーザーに近いエッジロケーションに自動配置する。1データベースあたり10GBの上限があり、大規模データには向かない。代わりに、テナントごとやユーザーごとに個別のデータベースを作る「マルチデータベース」設計を前提としている。

PlanetScale、Neon、Turso、D1——これらのサーバレスDBに共通するのは、従来のRDBMSとは異なる「レイヤー」での革新だ。データベースエンジン自体の改良（MySQLやPostgreSQLの新機能）ではなく、その周囲——コンピュートとストレージの分離、自動スケーリング、ゼロスケール、ブランチング、エッジ配置——に新たな価値を生み出している。

---

## 4. サーバレスDBの設計原則とトレードオフ

### コンピュートとストレージの分離

サーバレスDBに共通する設計原則の第一は、コンピュートとストレージの完全な分離だ。

従来のデータベースでは、SQLの処理（コンピュート）とデータの保存（ストレージ）が同一サーバ上で密結合していた。この密結合は、スケーリングを困難にする。SQLの処理能力を上げたいだけなのにストレージも一緒にスケールしなければならない、あるいはその逆。

Auroraが先鞭をつけたコンピュートとストレージの分離は、サーバレスDBの基盤技術となった。

```
コンピュートとストレージの分離がもたらすもの

 密結合（従来のRDBMS）
 ┌──────────────────────────┐
 │  サーバ                   │
 │  ┌──────┐ ┌──────────┐  │
 │  │Compute│ │ Storage  │  │
 │  │(CPU,  │ │ (Disk,   │  │
 │  │ Mem)  │ │  RAID)   │  │
 │  └──────┘ └──────────┘  │
 │  一緒にスケール           │
 │  一緒に起動/停止          │
 │  一緒に課金               │
 └──────────────────────────┘

 分離（サーバレスDB）
 ┌────────────┐      ┌──────────────┐
 │  Compute   │      │  Storage     │
 │  ・独立に    │      │  ・独立に      │
 │   スケール  │ ←──→ │   スケール    │
 │  ・停止可能  │      │  ・常時稼働    │
 │  ・使った分  │      │  ・使った分    │
 │   だけ課金  │      │   だけ課金    │
 └────────────┘      └──────────────┘

 分離のメリット:
 ・コンピュートを停止してもデータは失われない
  → Scale to Zero が可能に
 ・SQL処理能力とストレージ容量を独立に調整可能
 ・コンピュートの起動/停止が高速（ステートレス）
```

この分離が、Scale to Zeroを可能にする核心だ。コンピュートを停止してもストレージにデータが残るから、コンピュートを安全に止められる。そしてクエリが来たら、新しいコンピュートを起動してストレージに接続すればよい。

### コールドスタート問題

サーバレスDBの最大の技術的課題は、コールドスタートだ。

Scale to Zeroしたデータベースに最初のクエリが到着した時、コンピュートノードを起動し、メモリにバッファプールを構築し、クエリを処理する。この起動時間がコールドスタートのレイテンシだ。

NeonはCompute Nodeの起動を数百ミリ秒で実現している。PostgreSQLのプロセスを起動し、Pageserverとの接続を確立する。だがバッファプール（メモリ上のキャッシュ）は空の状態だ。最初の数クエリは、すべてのページをPageserverからフェッチする必要があるため、通常より遅い。

コールドスタートの影響を軽減する方法はいくつかある。Scale to Zeroの待機時間を長めに設定する（Neonは最大7日まで設定可能）。頻繁にアクセスされる本番データベースではScale to Zeroを無効にする。そしてアプリケーション側でコネクションプーリングを適切に設定する。

### コネクションプーリングの新たな重要性

サーバレス環境におけるデータベース接続は、従来のサーバ環境とは根本的に異なる問題を引き起こす。

従来のWebアプリケーションでは、数台のアプリケーションサーバがデータベースにコネクションプールを維持する。サーバ数×プールサイズが同時接続数になり、これは予測可能だ。

だがサーバレスアプリケーション（AWS Lambda、Cloudflare Workers等）では、リクエストごとに新しい実行環境が起動する可能性がある。各実行環境がデータベース接続を確立すると、スパイク時に数百〜数千の接続が同時に発生する。PostgreSQLのデフォルトの最大接続数は100だ。すぐに枯渇する。

この問題に対する解決策が、プロキシベースのコネクションプーリングだ。

**PgBouncer**はPostgreSQLの定番コネクションプーラーだ。Transaction Poolingモードでは、トランザクション単位でサーバ接続を使い回す。クライアント接続が1000あっても、実際にPostgreSQLに接続されるのは数十本で済む。NeonはビルトインでPgBouncerベースの接続プーリングを提供している。

**Prisma Accelerate**は、ORMフレームワークPrismaが提供するマネージドコネクションプーリング+グローバルキャッシュサービスだ。Cloudflareの300以上のロケーションにキャッシュノードを配置し、接続プーリングとクエリキャッシュを統合的に提供する。Prisma Data Proxy（前身サービス）の後継として2023年にリリースされた。

サーバレスDBの世界では、データベース自体のパフォーマンスだけでなく、「接続の管理」が新たなボトルネックになりうる。コネクションプーリングは、もはや最適化のテクニックではなく、サーバレスアーキテクチャの必須コンポーネントだ。

### コスト予測の難しさ

サーバレスDBの「使った分だけ課金」モデルは、理論上は合理的だ。だが実務上は、コストの予測が困難になるという新たな問題を生む。

固定インスタンスのRDS（例えば`db.r6g.xlarge`）なら、月額コストは予測可能だ。だがサーバレスDBでは、コストはワークロードに比例する。予期しないトラフィックスパイク、非効率なクエリ、バッチ処理の暴走——これらが直接的にコスト増加につながる。

私が見た実例として印象深いのは、開発環境のサーバレスDBで、ORMが生成する非効率なクエリが大量のコンピュート時間を消費し、固定インスタンスよりも高額になったケースだ。サーバレスDBのコスト最適化には、クエリの効率性がこれまで以上に直結する。

```
コストモデルの比較

 固定インスタンス (RDS)          サーバレスDB (Neon, PlanetScale)
 ─────────────────────        ─────────────────────────────
 月額固定 (例: $500/月)         従量課金 (Compute時間 + Storage)

 利点:                         利点:
 ・コスト予測が容易              ・使わない時間はゼロ課金
 ・使い放題                     ・小規模なら極めて安価
                               ・開発環境のコスト大幅削減

 欠点:                         欠点:
 ・使ってない時間も課金           ・スパイク時のコスト急増リスク
 ・過剰プロビジョニングの無駄     ・非効率クエリがコスト直結
                               ・月末まで総額が読めない
```

---

## 5. ハンズオン: Neonのサーバレス PostgreSQLを体験する

今回のハンズオンでは、NeonのサーバレスPostgreSQLを使い、ブランチ機能とScale to Zeroの動作を確認する。Neonは無料のFreeプランでブランチングとScale to Zeroを体験できる。

### 演習概要

1. Neonプロジェクトを作成し、サーバレスPostgreSQLに接続する
2. テーブルを作成し、データを投入する
3. ブランチを作成し、本番に影響を与えずにスキーマ変更をテストする
4. Scale to Zeroの動作を観察する
5. コネクションプーリングの効果を確認する

### 環境構築

```bash
# handson/database-history/19-serverless-databases/setup.sh を実行
bash setup.sh
```

### 演習1: Neonプロジェクトの作成と接続

Neonのアカウント作成後、CLIまたはWebコンソールからプロジェクトを作成する。

```bash
# Neon CLI のインストール（npm経由）
npm install -g neonctl

# 認証
neonctl auth

# プロジェクト作成
neonctl projects create --name serverless-handson

# 接続情報の確認
neonctl connection-string
```

表示された接続文字列でpsqlから接続する。

```bash
# psqlで接続（接続文字列はneonctl connection-stringの出力を使用）
psql "postgresql://user:pass@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require"
```

接続すると、通常のPostgreSQLと同じ操作が可能だ。

```sql
-- テーブル作成
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC(10, 2) NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- データ投入
INSERT INTO products (name, price, category) VALUES
  ('PostgreSQL入門', 3200, 'book'),
  ('データベース設計の教科書', 3800, 'book'),
  ('SQLパズル', 2800, 'book'),
  ('機械学習キット', 15000, 'hardware'),
  ('Raspberry Pi 5', 12000, 'hardware');

-- 確認
SELECT * FROM products ORDER BY id;
```

ここまでは通常のPostgreSQLと同じだ。違いは、このデータベースの裏側でCompute Node、Safekeeper、Pageserverが動いていること。そしてしばらく放置すれば、Compute Nodeが自動的に停止すること。

### 演習2: ブランチを使ったスキーマ変更のテスト

Neonのブランチ機能を使い、本番に影響を与えずにスキーマ変更をテストする。

```bash
# mainブランチからfeature-discountブランチを作成
neonctl branches create --name feature-discount

# feature-discountブランチの接続文字列を取得
neonctl connection-string --branch feature-discount
```

ブランチの作成は数秒で完了する。Copy-on-Writeなので、データの物理コピーは行われない。

```bash
# feature-discountブランチに接続
psql "postgresql://user:pass@ep-yyy.us-east-2.aws.neon.tech/neondb?sslmode=require"
```

```sql
-- ブランチ上でスキーマを変更
ALTER TABLE products ADD COLUMN discount_rate NUMERIC(3, 2) DEFAULT 0.00;

-- ブランチ上でデータを変更
UPDATE products SET discount_rate = 0.20 WHERE category = 'book';

-- 確認
SELECT name, price, discount_rate,
       price * (1 - discount_rate) AS discounted_price
FROM products ORDER BY id;
```

ブランチ上での変更は、mainブランチに一切影響しない。

```bash
# mainブランチに接続して確認
psql "postgresql://user:pass@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require"
```

```sql
-- mainブランチにはdiscount_rateカラムが存在しない
SELECT * FROM products ORDER BY id;
-- discount_rateカラムはない -> ブランチは独立している
```

この確認ができたら、スキーマ変更が安全であることを検証したことになる。本番への適用は、mainブランチに対して直接ALTER TABLEを実行するか、マイグレーションツールを使用する。

### 演習3: Scale to Zeroの観察

NeonのScale to Zero動作を確認する。

```bash
# Compute Nodeの状態を確認
neonctl branches list

# しばらく（デフォルト5分）何も操作せずに待つ
# ...5分後...

# 再度状態を確認 -> Compute Nodeが停止（Idle状態）
neonctl branches list

# 再びクエリを実行 -> Compute Nodeが自動起動
psql "postgresql://user:pass@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require" \
  -c "SELECT count(*) FROM products;"
```

最初のクエリには数百ミリ秒〜1秒程度の追加レイテンシがかかる。これがコールドスタートのコストだ。2回目以降のクエリは通常のレイテンシで実行される。

### 演習4: コネクションプーリングの比較

Neonはプーリング付きの接続文字列を提供している。

```bash
# 直接接続（プーリングなし）
# postgresql://user:pass@ep-xxx.us-east-2.aws.neon.tech/neondb

# プーリング接続（PgBouncer経由）
# postgresql://user:pass@ep-xxx.us-east-2.aws.neon.tech/neondb?pgbouncer=true

# 接続テスト: 10本の同時接続を試行
for i in $(seq 1 10); do
  psql "postgresql://user:pass@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require&pgbouncer=true" \
    -c "SELECT pg_backend_pid(), now();" &
done
wait
```

プーリング接続では、複数のクライアント接続が少数のPostgreSQL接続に多重化される。サーバレスアプリケーション（Lambda等）からの大量の短命接続に対して、プーリングは事実上必須のコンポーネントだ。

### 後片付け

```bash
# ブランチの削除
neonctl branches delete feature-discount

# プロジェクトの削除（必要に応じて）
neonctl projects delete serverless-handson
```

---

## 6. 運用の「形」が変わる

第19回を振り返ろう。

**データベース運用の抽象化は段階的に進化してきた。** Amazon RDS（2009年）がインストール・パッチ・バックアップを引き受け、Amazon Aurora（2014年発表、2015年GA）がコンピュートとストレージの分離で「ログこそがデータベース」を実現し、Aurora Serverless（v1: 2018年、v2: 2022年）が自動スケーリングを提供した。

**新世代のサーバレスDBは、異なるアプローチで運用の課題に挑んでいる。** PlanetScale（Vitessベース、MySQL互換、2021年GA）はブランチングとノンブロッキングスキーマ変更で開発ワークフローを革新した。Neon（2021年設立、2022年ローンチ、PostgreSQL互換）はストレージ層の完全な再設計によりScale to Zeroとブランチングを実現した。Turso（2023年、libSQL/SQLiteベース）とCloudflare D1（2022年、SQLiteベース）は、「軽い」データベースをエッジに分散させる新たな方向性を示した。

**サーバレスDBには新たなトレードオフがある。** コールドスタートのレイテンシ、コネクションプーリングの必要性、コスト予測の困難さ——これらは「運用からの解放」の代償だ。運用から「解放」されるのではなく、運用の「形」が変わるのだ。

**サーバレスDBビジネスの持続性も問われている。** PlanetScaleの無料ティア廃止（2024年）、CockroachDBのライセンス変遷——OSSやフリーミアムモデルでユーザーを獲得し、エンタープライズ機能で収益化するモデルは、依然として模索が続いている。

冒頭の問いに戻ろう。「データベースの運用から本当に解放される日は来るのか？」

私の答えは、「完全な解放はない。だが運用の質は根本的に変わる」だ。

深夜3時にディスク容量のアラートで叩き起こされる時代は終わった。だが代わりに、クエリの効率性がコストに直結する世界が来た。インスタンスサイズの選定からは解放されたが、コネクションプーリングの設計が新たな必須知識になった。スケーリングは自動化されたが、コールドスタートのレイテンシをどう許容するかの判断が必要になった。

運用の形が変わっても、データベースの本質——データの整合性、永続性、効率的なアクセス——は変わらない。第7回で語ったACIDの原則も、第10回で語ったインデックス設計の原則も、サーバレスDBの上でそのまま生きている。変わったのはインフラストラクチャのレイヤーであり、データベース設計の本質ではない。

次回「ベクトルDBとAI時代のデータ管理」では、データベースの「検索」の概念そのものが変わりつつある現在を語る。SQLのLIKEでは到達できないセマンティック検索、高次元ベクトル空間でのデータ表現、pgvectorとRDB拡張の可能性——AI時代のデータ管理が何を求めているのかを、実装の手触りとともに考える。

---

### 参考文献

- Verbitski, A. et al., "Amazon Aurora: Design Considerations for High Throughput Cloud-Native Relational Databases", SIGMOD 2017. <https://www.amazon.science/publications/amazon-aurora-design-considerations-for-high-throughput-cloud-native-relational-databases>
- Amazon Science, "A decade of database innovation: The Amazon Aurora story". <https://www.amazon.science/blog/a-decade-of-database-innovation-the-amazon-aurora-story>
- AWS Blog, "Amazon Aurora Serverless v2 is Generally Available". <https://aws.amazon.com/blogs/aws/amazon-aurora-serverless-v2-is-generally-available-instant-scaling-for-demanding-workloads/>
- PlanetScale, "Non-blocking schema changes". <https://planetscale.com/docs/vitess/schema-changes>
- PlanetScale, "Deprecating the Hobby plan". <https://planetscale.com/changelog/deprecating-hobby>
- Neon, "Architecture Overview". <https://neon.com/docs/introduction/architecture-overview>
- Neon, "Architecture decisions in Neon". <https://neon.com/blog/architecture-decisions-in-neon>
- Neon, "Scale to Zero". <https://neon.com/docs/introduction/scale-to-zero>
- Turso, "Announcing ChiselStrike Turso". <https://turso.tech/blog/announcing-chiselstrike-turso-164472456b29>
- Cloudflare, "Announcing D1: our first SQL database". <https://blog.cloudflare.com/introducing-d1/>
- TechCrunch, "They scaled YouTube — now they'll shard everyone with PlanetScale". <https://techcrunch.com/2018/12/13/planetscale/>

---

**次回予告：** 第20回「ベクトルDBとAI時代のデータ管理」では、「データの検索」の根本的な変容を語る。SQLのLIKEでは届かないセマンティック検索、Embeddingによる高次元ベクトル空間でのデータ表現、HNSW・IVFといったベクトルインデックスのアルゴリズム、そしてpgvectorによるRDB拡張とPinecone・Qdrantなどの専用ベクトルDBの設計判断を考える。
