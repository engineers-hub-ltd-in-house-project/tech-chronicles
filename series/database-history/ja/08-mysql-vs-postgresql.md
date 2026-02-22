# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第8回：MySQL vs PostgreSQL——Web時代のRDB戦争

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- LAMPスタック全盛期にMySQLが「Web時代のデフォルトDB」となった背景
- MyISAMとInnoDBの設計思想の違い、そしてInnoDBがデフォルトになるまでの経緯
- PostgreSQLが「知る人ぞ知る存在」だった理由と、そこからの逆転劇
- MySQLのスレッドモデルとPostgreSQLのプロセスモデルの設計判断
- VACUUMというPostgreSQL固有の運用課題の本質
- 両者のベンチマークを通じて特性の違いを体感する方法

---

## 1. レンタルサーバにはMySQLしかなかった

2003年頃、私はPHPでWebアプリケーションを作っていた。

クライアントから「会員管理システムを作ってほしい」という依頼を受け、レンタルサーバの管理画面にログインする。コントロールパネルには「MySQL」の文字がある。phpMyAdminへのリンクがあり、クリックすればブラウザ上でテーブルを作れる。データベースの選択肢はMySQLだけだ。PostgreSQLの「ポ」の字もない。

当時の私にとって、それは自然なことだった。PHPの教本にはMySQLとの接続方法が書いてある。`mysql_connect()`で接続し、`mysql_query()`でSQLを投げる。Webの入門記事はすべてMySQL前提だ。レンタルサーバの料金プランに「PostgreSQL対応」はオプションですらない。MySQLは空気のように「そこにあるもの」だった。

あるとき、先輩エンジニアに「PostgreSQL使ったことある？」と聞かれた。ない、と答えると、「外部キー制約がちゃんと効くよ」と言われた。意味が分からなかった。外部キー制約が「ちゃんと効かない」データベースがあるのか。

あった。当時のMySQLのデフォルトストレージエンジンであるMyISAMは、外部キー制約をサポートしていなかった。`FOREIGN KEY`をCREATE TABLE文に書いても、構文エラーにはならないが、制約としては機能しない。黙って無視される。知らなかった。何年もの間、私は外部キー制約が効いていると思い込んで、効いていないデータベースを運用していた。

その後、PostgreSQLに乗り換えた最初のプロジェクトで、INSERT文がエラーで弾かれた。参照先のレコードが存在しないのに子テーブルにデータを入れようとしたのだ。これが「外部キー制約がちゃんと効く」ということか。データベースが、データの整合性を守ってくれている。当たり前のことが、当たり前でなかった世界から来た私には、新鮮な衝撃だった。

なぜMySQLはWeb開発で勝利し、PostgreSQLは長い間「知る人ぞ知る存在」だったのか。そして、なぜ今その勢力図が逆転しつつあるのか。この問いの答えは、技術の優劣ではなく、時代の要請と設計判断の違いにある。

---

## 2. LAMPの時代——MySQLが「勝者」になった理由

### LAMPスタックという革命

1998年、ドイツのコンピュータ雑誌Computertechnikに掲載されたMichael Kunzeの記事が、一つの頭字語を世に送り出した。LAMP——Linux, Apache, MySQL, PHP（あるいはPerl, Python）。高価な商用ソフトウェアスタックに対する、完全にオープンソースの代替手段だ。

この頭字語は、単なるソフトウェアの組み合わせ以上のものを象徴していた。1990年代後半、Webの爆発的な成長は、安価にWebサービスを構築・運用できるインフラへの需要を生み出していた。Windows Server + IIS + SQL Server + ASPの商用スタックは高額だ。Solaris + Oracle Databaseは論外だ。予算の限られたスタートアップやフリーランスの開発者にとって、「すべて無料」のLAMPスタックは救いだった。

O'Reilly MediaとMySQL ABはLAMPの普及に積極的に貢献した。MySQL ABの共同創設者であるDavid AxmarkとMonty Widenius（Michael Widenius）は、LAMPスタックの構成要素としてMySQLを位置づけるマーケティングを展開した。2000年にMySQLがGPLライセンスで完全にオープンソース化されると、その利用は爆発的に拡大した。

### 「簡単さ」という最強の武器

MySQLがWeb開発で「勝者」になった理由は、速度でも機能でもない。「簡単さ」だ。

`apt-get install mysql-server`で入る。インストール直後からすぐに使える。phpMyAdminをブラウザで開けば、SQLを一行も書かずにテーブルを作れる。PHPからの接続は数行のコードで済む。レンタルサーバの管理画面に最初から組み込まれている。

2000年代前半、Webホスティングの世界ではMySQLが事実上の唯一の選択肢だった。レンタルサーバ事業者がMySQLをプリインストールしたのは、軽量で運用が容易だったからだ。MySQLのスレッドベースのアーキテクチャは、プロセスベースのPostgreSQLと比較して、メモリ消費が少なく、大量の接続を軽量に処理できた。共有ホスティング環境では、この「軽さ」が決定的だった。

そしてCMSの台頭がMySQLの地位を不動のものにした。WordPress（2003年登場）、Drupal（2001年）、Joomla（2005年）——PHP製のオープンソースCMSはすべてMySQLを前提に作られた。WordPressは2025年時点でWeb全体の40%以上を占めるとされ、その背後にはすべてMySQLがある。CMSが「MySQLを使う」ことを前提にし、ホスティング事業者が「MySQLを提供する」ことを前提にし、入門書が「MySQLを教える」ことを前提にする。この循環が、MySQL以外の選択肢を見えなくした。

### Facebook、YouTube、Twitter——巨大サービスの選択

MySQLの「勝利」を決定的にしたのは、Web 2.0時代の巨大サービスによる採用だ。

Facebook、YouTube、Twitter、Flickr——2000年代のWeb世界を変革したサービスの多くがMySQLを選んだ。これらのサービスがMySQLを選んだ理由は、技術的な最適性だけではない。LAMPスタックの一部としてすでにそこにあり、開発者のスキルセットにMySQL経験が含まれており、コミュニティとエコシステムが充実していた。

Facebookは後に独自のMySQLフォーク（現在のMyRocks）を開発するほど、MySQLの限界と格闘することになる。だが初期段階では、MySQLの「手軽さ」がスタートアップの速度を支えた。技術的に「最適」でなくても、「十分に良く、すぐに使える」ことが、スタートアップにとっては最適解だった。

---

## 3. MyISAM vs InnoDB——ストレージエンジンという設計判断

### MyISAMの時代

MySQLの設計で最も特徴的なのは、プラガブルストレージエンジンというアーキテクチャだ。SQLの解析やクエリ最適化を担う上位レイヤーと、データの物理的な格納・取得を担うストレージエンジンが分離されている。同じMySQL上で、テーブルごとに異なるストレージエンジンを選択できる。

MySQL 5.5以前のデフォルトストレージエンジンはMyISAMだった。MyISAMの設計思想は明快だ——シンプルさと読み取り性能。

MyISAMはテーブルロック方式を採用する。書き込み時にはテーブル全体がロックされ、他のすべての読み取り・書き込みがブロックされる。行レベルロックという概念がない。トランザクションもサポートしない。`BEGIN`と`COMMIT`を書いても、各SQL文は即座にディスクに反映される。原子性の保証は個々のSQL文の単位だ。外部キー制約はCREATE TABLE文で宣言できるが、実際には無視される。

この設計は、一見するとデータベースの本質を欠いているように思える。第7回で見たACID特性——原子性、一貫性、独立性、永続性——のうち、MyISAMが保証するのは永続性だけだ。しかしMyISAMには、この制約と引き換えに得たものがある。

MyISAMのデータファイル構造は単純で、フルテーブルスキャンが高速だった。テーブルロック方式はロック管理のオーバーヘッドが小さく、読み取りが圧倒的に多いワークロード（Webアプリケーションの典型）では、十分な性能を発揮した。インデックス統計の管理が軽量で、`COUNT(*)`が瞬時に返る（テーブルのメタデータに行数を保持しているため）。メモリ消費が少なく、共有ホスティング環境に適していた。

2000年代前半のWebアプリケーションの大部分は「読み取りが圧倒的に多く、書き込みは少ない」というワークロードだった。ブログの閲覧、掲示板の表示、商品カタログの検索——これらはすべて読み取り中心だ。MyISAMはこのワークロードに最適化されていた。トランザクションも外部キー制約も、当時の多くのWeb開発者にとっては「なくても困らない」ものだった。

### InnoDBの台頭

InnoDBの歴史は、MySQLとは独立している。

1995年、フィンランドのヘルシンキ大学で数理論理学の博士号を持つHeikki Tuuriが、Innobase Oyを設立してInnoDBの開発を始めた。InnoDBの最初の公開リリースは2001年で、MySQL 3.23のオプションプラグインとして提供された。

InnoDBはMyISAMとは正反対の設計思想を持つ。行レベルロック、MVCC（Multi-Version Concurrency Control、第7回参照）、ACID準拠のトランザクション、外部キー制約、WAL（Write-Ahead Logging）によるクラッシュリカバリ。第7回で語ったトランザクション理論のすべてが、InnoDBには実装されている。

2005年10月、OracleがInnobase Oyを買収した。MySQL ABにとって、これは衝撃だった。自社のデータベースの最も重要なストレージエンジンの開発元が、RDB市場の最大の競合であるOracleに買収されたのだ。この買収がMySQL ABの将来に対する不安を生み、後のSunによるMySQL AB買収（2008年）の遠因の一つになったとも言われる。

2010年12月、MySQL 5.5がリリースされ、InnoDBがデフォルトストレージエンジンに変更された。この変更は、MySQLの設計哲学の転換を象徴する。「速度優先、簡単さ優先」のMyISAMから、「正しさと信頼性」のInnoDBへ。Web開発が成熟し、ECサイトや金融系のアプリケーションがMySQLで動くようになると、トランザクションと外部キー制約は「なくても困らない」ものではなくなった。

```
ストレージエンジンの設計判断

MyISAM（MySQL 5.5以前のデフォルト）
┌───────────────────────────────────┐
│ テーブルロック                     │
│ トランザクション: なし             │
│ 外部キー制約: なし                 │
│ MVCC: なし                        │
│ クラッシュリカバリ: 限定的         │
│ COUNT(*): 瞬時（メタデータ保持）  │
│ メモリ消費: 小                     │
│ 設計思想: 速度とシンプルさ         │
└───────────────────────────────────┘

InnoDB（MySQL 5.5以降のデフォルト）
┌───────────────────────────────────┐
│ 行レベルロック                     │
│ トランザクション: ACID準拠         │
│ 外部キー制約: あり                 │
│ MVCC: あり                        │
│ クラッシュリカバリ: WALベース      │
│ COUNT(*): テーブルスキャン必要     │
│ メモリ消費: 大                     │
│ 設計思想: 正しさと信頼性           │
└───────────────────────────────────┘
```

### 買収の連鎖——MySQLの運命

2008年1月16日、Sun MicrosystemsがMySQL ABを約10億ドルで買収した。現金約8億ドルとストックオプション約2億ドルだ。Sun は150億ドル規模とされたデータベース市場への参入を狙った。

だがSun自体の経営が揺らいでいた。2010年、OracleがSun Microsystemsを買収する。MySQLは、Oracleの傘下に入った。

オープンソースコミュニティの反応は激烈だった。Oracleは世界最大の商用データベースベンダーだ。そのOracleがMySQLを所有する。自社のフラグシップ製品Oracle Databaseとの競合を避けるため、MySQLの開発を意図的に停滞させるのではないか。この懸念は、単なる杞憂ではなかった。Oracleはすでに2005年にInnobase Oyを買収しており、MySQLの心臓部であるInnoDBを支配していたのだから。

2009年2月、MySQLの共同創設者であるMonty Widenius（Michael Widenius）がMonty Program Abを設立し、MySQLをフォークしてMariaDBを立ち上げた。MariaDBは末娘Mariaにちなんで命名された（MySQLのMyも、長女のMyにちなんでいる）。MariaDBはMySQLのドロップイン・リプレースメント——つまり、MySQLと完全な互換性を保ちつつ、独自の進化を遂げることを目指した。

Linux のディストリビューションも動いた。Red Hat Enterprise Linux、Fedora、openSUSE、Arch Linuxなどが、デフォルトのMySQLパッケージをMariaDBに切り替えた。WikimediaもMySQLからMariaDBへの移行を実施した。OracleのMySQL支配に対するコミュニティの「反撃」だった。

結果として、OracleはMySQLの開発を停滞させるどころか、むしろ積極的に強化した。MySQL 5.6（2013年）でクエリオプティマイザが大幅に改善され、5.7（2015年）でJSON型が導入され、8.0（2018年）でウィンドウ関数やCTE（Common Table Expressions）が追加された。競合するMariaDBとPostgreSQLの存在が、OracleにMySQL開発の加速を促した側面は否定できない。

---

## 4. PostgreSQLの逆襲——「正しさ」が報われるまで

### 長い雌伏の時

PostgreSQLが「知る人ぞ知る存在」だった理由は、技術的な欠陥ではない。むしろ逆だ。PostgreSQLは「正しすぎた」のだ。

第6回で触れたように、PostgreSQLはMichael StonebrakerのIngresプロジェクト（1974年、UC Berkeley）の直系の子孫だ。POSTGRES（1986年〜）を経てPostgres95（1994年）となり、1996年にPostgreSQLと改名された。学術的な系譜を持つこのデータベースは、SQL標準への準拠、型システムの拡張性、データの整合性の保証を重視した。

だがこの「正しさ」が、2000年代のWeb開発現場では不利に働いた。

第一に、インストールと設定がMySQLより煩雑だった。PostgreSQLのプロセスベースアーキテクチャは、接続ごとに新しいプロセスを生成する。1プロセスあたりのメモリ消費はMySQLのスレッドモデルと比較して大きく、共有ホスティング環境では数十〜数百の接続を捌くのに相当なメモリが必要だった。レンタルサーバ事業者がPostgreSQLを敬遠したのは、この「重さ」のためだ。

第二に、PHPとの統合がMySQLほどスムーズでなかった。PHPの標準関数に`mysql_*`系の関数が含まれ、入門書はすべてMySQL前提で書かれていた。PostgreSQLを使うには`pg_*`系の関数を使う必要があり、情報が少なかった。

第三に、Windowsへの対応が遅れた。PostgreSQLがWindows上でネイティブに動作するようになったのは、バージョン8.0（2005年1月リリース）からだ。それ以前はCygwinというUNIXエミュレーション環境が必要だった。Windowsが開発環境の主流だった2000年代前半において、これは無視できない障壁だった。

### 転換点——PostgreSQL 8.0以降の進化

2005年のPostgreSQL 8.0は、PostgreSQLの歴史における転換点だ。Windowsネイティブサポートに加え、Savepoints（トランザクション内の部分的ロールバック）、Point-in-Time Recovery、テーブルスペースが導入された。

その後の進化は加速する。

PostgreSQL 8.1（2005年）は、autovacuum（自動VACUUM）をオプション機能として導入した。VACUUMの必要性についてはこの後詳述するが、手動でのVACUUM実行が必要だったPostgreSQLの運用負荷は、長年にわたる批判の的だった。8.3（2008年）でautovacuumがデフォルト有効化され、マルチプロセスアーキテクチャに移行したことで、この問題は大幅に改善された。

PostgreSQL 9.0（2010年）は、ストリーミングレプリケーションとHot Standbyを導入した。それまでPostgreSQLには組み込みのレプリケーション機能がなく、Slony-Iなどの外部ツールに依存していた。MySQLがバージョン3.23（2000年）の時点でレプリケーションを備えていたことを考えると、10年の遅れだ。だがこの遅れは、WALベースのストリーミングレプリケーションという堅牢な設計として結実した。

9.1（2011年）では同期レプリケーションとSerializable Snapshot Isolation（SSI）が導入され、9.2（2012年）ではインデックスオンリースキャンが実装された。PostgreSQLの各リリースは、着実に機能と性能の両面で進化を重ねた。

```
PostgreSQLの進化タイムライン（主要マイルストーン）

2005  8.0  ─── Windows ネイティブ対応、PITR
2005  8.1  ─── autovacuum（オプション）、Two-Phase Commit
2008  8.3  ─── autovacuumデフォルト有効化
2010  9.0  ─── ストリーミングレプリケーション、Hot Standby
2011  9.1  ─── 同期レプリケーション、SSI
2012  9.2  ─── インデックスオンリースキャン、JSON型
2013  9.3  ─── マテリアライズドビュー、LATERAL JOIN
2014  9.4  ─── JSONB型、論理デコーディング
2016  9.6  ─── パラレルクエリ
2017  10   ─── 宣言的パーティショニング、論理レプリケーション
2020  13   ─── インクリメンタルソート、パラレルVACUUM
2024  17   ─── インクリメンタルバックアップ
```

### 勢力図の逆転

2017年、DB-EnginesがPostgreSQLを年間DBMS（DBMS of the Year）に選出した。2018年、2023年、2024年にも同賞を受賞し、直近7年間で4回の受賞という圧倒的な存在感を示している。

何が変わったのか。

第一に、Web開発のスタックが変わった。LAMPの時代は終わり、Node.js、Python（Django/Flask）、Ruby（Rails）、Go、Rustなど、言語とフレームワークが多様化した。これらのエコシステムではMySQLへの「ロックイン」がない。ORMがデータベース抽象化層を提供し、PostgreSQLへの切り替えが容易になった。

第二に、PostgreSQLの拡張性が現代の要件に合致した。JSON/JSONB型のネイティブサポート（9.2/9.4）、全文検索（GINインデックス）、地理空間データ（PostGIS）、ベクトル検索（pgvector）——PostgreSQLは単なるRDBを超えた「マルチモデルデータベース」としての地位を確立した。一つのデータベースで、リレーショナルデータもJSONドキュメントも地理空間データもベクトルも扱える。

第三に、クラウドの台頭がPostgreSQLに追い風となった。AWS RDS、Google Cloud SQL、Azure Database for PostgreSQLなど、マネージドサービスが運用負荷を吸収した。PostgreSQLの「重さ」——プロセスモデルのメモリ消費やVACUUMの運用——は、クラウドベンダーが面倒を見てくれる。レンタルサーバ時代の不利は消えた。

第四に、開発者の意識が変わった。「とりあえず動く」から「正しく動く」へ。型安全性、データ整合性、標準準拠——かつて「過剰」と見なされた PostgreSQLの特性が、プロダクション環境での信頼性として再評価されるようになった。

---

## 5. 設計思想の対比——スレッドとプロセス、VACUUMとUndo

### スレッドモデル vs プロセスモデル

MySQLとPostgreSQLの設計思想の違いは、接続処理のアーキテクチャに端的に現れる。

MySQLはスレッドベースのアーキテクチャを採用している。新しいクライアント接続が確立されると、MySQL内部で一つのスレッドが生成される。スレッドはプロセス内のメモリ空間を共有するため、生成コストが低く、メモリ消費も小さい。1スレッドあたりのメモリオーバーヘッドは比較的小さく、数千の同時接続を処理できる。

PostgreSQLはプロセスベースのアーキテクチャを採用している。新しいクライアント接続ごとに、OSレベルの新しいプロセス（バックエンドプロセス）が`fork()`される。各プロセスは独立したメモリ空間を持つ。

```
接続モデルの違い

MySQL（スレッドモデル）
┌─────────────────────────────────┐
│ mysqld プロセス                  │
│ ┌──────┐┌──────┐┌──────┐       │
│ │Thread││Thread││Thread│ ...    │
│ │ #1   ││ #2   ││ #3   │       │
│ └──────┘└──────┘└──────┘       │
│     共有メモリ空間              │
│   ┌────────────────────┐       │
│   │ Buffer Pool        │       │
│   │ Query Cache        │       │
│   │ InnoDB Buffer      │       │
│   └────────────────────┘       │
└─────────────────────────────────┘
1スレッドあたりのオーバーヘッド: 小

PostgreSQL（プロセスモデル）
┌────────┐ ┌────────┐ ┌────────┐
│Process │ │Process │ │Process │ ...
│ #1     │ │ #2     │ │ #3     │
│独自メモリ│ │独自メモリ│ │独自メモリ│
└────┬───┘ └────┬───┘ └────┬───┘
     │          │          │
     └──────────┼──────────┘
          共有メモリ
     ┌──────────────────┐
     │ Shared Buffers   │
     │ WAL Buffers      │
     └──────────────────┘
1プロセスあたりのオーバーヘッド: 大
```

この設計判断にはトレードオフがある。

MySQLのスレッドモデルは軽量で、多数の接続を効率的に処理できる。だがスレッドはメモリ空間を共有するため、一つのスレッドのクラッシュがプロセス全体に波及するリスクがある。また、スレッド間の排他制御（ミューテックス）がボトルネックになりうる。

PostgreSQLのプロセスモデルは重量級だが、障害隔離性に優れる。一つのバックエンドプロセスがクラッシュしても、他の接続には影響しない。独立したメモリ空間は、あるクエリの暴走が他の接続を直接巻き込まないことを意味する。だがプロセス生成のコストは高く、数百を超える同時接続ではメモリ消費が課題になる。

PostgreSQLの世界では、この課題に対する解がコネクションプーリングだ。PgBouncer やPgpool-IIといったミドルウェアが、クライアント接続とバックエンドプロセスの間に立ち、プロセスの再利用を行う。アプリケーションから見れば数千の接続でも、PostgreSQL側では数十〜百程度のバックエンドプロセスで処理する。コネクションプーリングはPostgreSQLの運用における実質的な必須コンポーネントだ。

### MVCC実装の違い——VACUUMの宿命

第7回でMVCCの概念を解説した。データを更新するとき、古いバージョンを消すのではなく新しいバージョンを追加する。読み取りトランザクションは古いバージョンを読み、書き込みトランザクションは新しいバージョンを作る。ブロックなしの並行処理だ。

同じMVCCでも、MySQLとPostgreSQLではその実装が根本的に異なる。

MySQL（InnoDB）はUndoログ方式を採用する。データの最新バージョンはテーブルのデータページに直接書き込まれ、変更前の値はUndoログという別領域に退避される。古いバージョンが必要なトランザクションは、Undoログを辿って過去のバージョンを再構成する。不要になったUndoログは、バックグラウンドで自動的にパージされる。

PostgreSQLはテーブル内バージョン保持方式を採用する。データの新旧バージョンがすべてテーブルのデータページ内に共存する。更新されると、古い行は「死んだタプル（dead tuple）」としてそのまま残り、新しい行が別の場所に書き込まれる。各行にはトランザクションIDベースの可視性情報（`xmin`、`xmax`）が付与され、トランザクションはこの情報を参照して自分に「見える」バージョンを判定する。

```
MVCC実装の違い

MySQL (InnoDB) — Undoログ方式
┌───────────────────┐    ┌─────────────────┐
│ テーブル           │    │ Undoログ         │
│ ┌───────────────┐ │    │ ┌─────────────┐ │
│ │ row: value=200│ │←──→│ │ 旧: val=100 │ │
│ │ (最新版のみ)  │ │    │ │ (変更前の値)│ │
│ └───────────────┘ │    │ └─────────────┘ │
│                   │    │ 自動パージ       │
└───────────────────┘    └─────────────────┘

PostgreSQL — テーブル内バージョン保持方式
┌────────────────────────────────────────┐
│ テーブル                                │
│ ┌──────────────────────────────────┐   │
│ │ row v1: value=100 (dead tuple)   │   │
│ │   xmin=100, xmax=105             │   │
│ ├──────────────────────────────────┤   │
│ │ row v2: value=200 (live tuple)   │   │
│ │   xmin=105, xmax=∞              │   │
│ └──────────────────────────────────┘   │
│ → VACUUM で dead tuple を回収する必要   │
└────────────────────────────────────────┘
```

PostgreSQLの方式には明確な利点がある。Undoログの管理が不要で、ロールバックが高速だ（古いバージョンがテーブルに残っているため、新しいバージョンを無効化するだけで済む）。長時間のトランザクションがUndoログを肥大化させる（InnoDBの「Undo log bloat」問題）こともない。

だが代償がある。VACUUM（バキューム）だ。

dead tupleはテーブル内に溜まり続ける。放置すれば、テーブルが際限なく肥大化する（テーブルブロート）。クエリは dead tupleを含むデータページを読み込むため、実質的なデータ量以上のI/Oが発生する。これを防ぐのがVACUUMだ。VACUUMはdead tupleを回収し、その領域を再利用可能にする。

PostgreSQL 8.1（2005年）でautovacuumがオプション機能として導入され、8.3（2008年）でデフォルト有効化された。これにより手動でのVACUUM実行は基本的に不要になったが、autovacuumの設定チューニングはPostgreSQL管理者の必須スキルであり続けている。大規模なテーブルでautovacuumの実行が追いつかなければ、テーブルブロートとトランザクションIDの周回（wraparound）という致命的な問題に直面する。

VACUUMはPostgreSQLの「税金」だ。MVCCのメリットを享受する代わりに、この運用コストを受け入れなければならない。MySQLのUndoログ方式には別の「税金」——Undoログの肥大化と長時間トランザクションでの性能劣化——があるが、運用者の意識に上りにくい。VACUUMの可視性の高さが、PostgreSQLの運用は大変だという印象を生んできた面はある。

### レプリケーションの系譜

MySQLのレプリケーションは、MySQL 3.23.15（2000年5月）で導入されたStatement-Based Replication（SBR）に始まる。マスターサーバ上で実行されたSQL文をそのままバイナリログに記録し、スレーブサーバがそのSQL文を再実行する方式だ。

SBRはシンプルだが問題がある。`NOW()`や`RAND()`のような非決定的関数を含むSQL文は、マスターとスレーブで異なる結果を返す可能性がある。この問題に対処するため、MySQL 5.1（2008年）でRow-Based Replication（RBR）とMixed-Modeが追加された。RBRは、SQL文ではなく変更された行のデータそのものをバイナリログに記録する。MySQL 5.7.7（2015年）でRBRがデフォルトに変更された。

一方、PostgreSQLの組み込みレプリケーション機能はMySQL に比べて10年遅い。PostgreSQL 9.0（2010年）でストリーミングレプリケーションが導入されるまで、PostgreSQLのレプリケーションはSlony-IやPgpool-IIなどのサードパーティツールに依存していた。

だがこの「遅れ」は、WALベースのストリーミングレプリケーションという堅牢な設計として結実した。WALレコードを物理的に転送する方式は、SQL文の再実行（SBR）のような非決定性の問題を原理的に回避する。9.1（2011年）で同期レプリケーションが追加され、10（2017年）で論理レプリケーションが導入されて、柔軟性も確保された。

先行者のMySQLが試行錯誤の中で段階的に改善した問題を、後発のPostgreSQLは最初から堅牢な設計で解決した。後発の利点（second-mover advantage）の典型的な例だ。

---

## 6. ハンズオン: MySQLとPostgreSQLの特性を比較する

今回のハンズオンでは、MySQLとPostgreSQLで同じワークロードを実行し、両者の挙動の違いを体験する。

### 演習概要

1. MySQLとPostgreSQLに同じスキーマ・同じデータを用意する
2. 型の扱いの違いを確認する（暗黙の型変換、厳密性）
3. 読み取り中心・書き込み中心のワークロードで性能特性を比較する
4. 外部キー制約の挙動差を観察する

### 環境構築

```bash
# handson/database-history/08-mysql-vs-postgresql/setup.sh を実行
bash setup.sh
```

### 演習1: 型の厳密性の違い

MySQLとPostgreSQLに接続する。

```bash
# MySQL に接続
docker exec -it db-history-ep08-mysql mysql -u root -phandson handson

# PostgreSQL に接続
docker exec -it db-history-ep08-pg psql -U postgres -d handson
```

MySQLでの挙動を確認する。

```sql
-- === MySQL ===
-- 文字列と数値の暗黙変換
SELECT 1 + '2';
-- → 3（文字列'2'が数値2に暗黙変換される）

SELECT 'abc' + 1;
-- → 1（文字列'abc'は数値0に変換される。エラーにならない）

-- 日付の扱い
INSERT INTO test_types (date_col) VALUES ('2024-02-30');
-- → MySQL（厳密モードOFFの場合）: 0000-00-00 が挿入されるか、警告のみ
-- → MySQL 5.7+ (厳密モードON): エラー
```

同じ操作をPostgreSQLで試す。

```sql
-- === PostgreSQL ===
-- 文字列と数値の暗黙変換
SELECT 1 + '2';
-- → 3（'2'が整数に変換される。ただしこれはリテラルの場合のみ）

SELECT 'abc' + 1;
-- → ERROR: invalid input syntax for type integer: "abc"
-- PostgreSQLは不正な変換を許さない

-- 日付の扱い
INSERT INTO test_types (date_col) VALUES ('2024-02-30');
-- → ERROR: date/time field value out of range: "2024-02-30"
-- 存在しない日付は即座にエラー
```

この違いは「厳密さ」の設計判断だ。MySQLは「できるだけエラーにしない」方向、PostgreSQLは「不正なデータを受け入れない」方向に設計されている。どちらが「正しい」かは一概に言えないが、データの信頼性を重視するなら、PostgreSQLの厳密さは安心材料になる。

### 演習2: 外部キー制約の挙動

```sql
-- === MySQL ===
-- テーブルの確認
SHOW CREATE TABLE orders\G
-- Storage Engineを確認: InnoDB なら外部キー制約が有効

-- 存在しないユーザーIDで注文を挿入
INSERT INTO orders (user_id, product, amount) VALUES (9999, 'Widget', 1000);
-- → InnoDB: ERROR 1452 - Cannot add or update a child row:
--           a foreign key constraint fails
-- → MyISAM: 成功してしまう（制約が無視される）
```

```sql
-- === PostgreSQL ===
INSERT INTO orders (user_id, product, amount) VALUES (9999, 'Widget', 1000);
-- → ERROR: insert or update on table "orders" violates
--          foreign key constraint "orders_user_id_fkey"
-- PostgreSQLは常に外部キー制約を強制する
```

### 演習3: ワークロード特性の比較

setup.shが生成した10万件のデータに対して、読み取り・書き込みの性能を比較する。

```sql
-- === MySQL ===
-- 読み取りベンチマーク: 集約クエリ
SELECT
  u.username,
  COUNT(o.id) AS order_count,
  SUM(o.amount) AS total_amount
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.username
ORDER BY total_amount DESC
LIMIT 10;

-- 実行時間を確認
-- MySQL では SET profiling = 1; を使用するか、
-- クエリの前に EXPLAIN ANALYZE を付ける（MySQL 8.0以降）
```

```sql
-- === PostgreSQL ===
-- 同じクエリを実行
EXPLAIN ANALYZE
SELECT
  u.username,
  COUNT(o.id) AS order_count,
  SUM(o.amount) AS total_amount
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.username
ORDER BY total_amount DESC
LIMIT 10;

-- Planning Time と Execution Time を確認する
```

```sql
-- === MySQL ===
-- 書き込みベンチマーク: バルクINSERT
-- setup.sh内で生成されるストアドプロシージャを使用
CALL benchmark_insert(10000);
-- 所要時間を確認
```

```sql
-- === PostgreSQL ===
-- 同様のバルクINSERT
SELECT benchmark_insert(10000);
-- 所要時間を確認
```

この演習のポイントは、絶対的な速度の比較ではなく、ワークロード特性による違いを理解することだ。読み取り中心のシンプルなクエリではMySQLが速い傾向にあり、複雑なJOINや集約クエリ、書き込み中心のワークロードではPostgreSQLが安定した性能を発揮する傾向がある。だがこれは一般論であり、インデックス設計やクエリの書き方、設定パラメータによって結果は大きく変わる。

### 後片付け

```bash
docker rm -f db-history-ep08-mysql db-history-ep08-pg
```

---

## 7. 「手軽さ」と「正しさ」の先にあるもの

第8回を振り返ろう。

**MySQLがWeb時代のデフォルトDBとなった理由は、「手軽さ」だった。** LAMPスタックの一部としてレンタルサーバにプリインストールされ、phpMyAdminで操作でき、PHPの入門書で教えられた。WordPress をはじめとするCMSがMySQLを前提とし、Facebook、YouTube、TwitterがMySQLを採用した。この「どこにでもある」ことが、MySQLの最大の武器だった。

**MyISAMからInnoDBへのデフォルト変更（MySQL 5.5、2010年）は、MySQLの設計哲学の転換を象徴する。** トランザクション非対応・外部キー制約非対応のMyISAMから、ACID準拠のInnoDBへ。Web開発の成熟が、「速さとシンプルさ」から「正しさと信頼性」への移行を促した。

**MySQLの買収劇——Sun（2008年、10億ドル）からOracle（2010年）——は、オープンソースの所有権という問題を突きつけた。** MontyWideniusによるMariaDBのフォーク（2009年）は、コミュニティの「反撃」だった。皮肉にも、この競争圧力がOracleによるMySQL開発の加速を促した。

**PostgreSQLは「正しさ」を貫いた結果、2010年代以降に報われた。** SQL標準準拠、型システムの拡張性、JSONB、PostGIS、pgvector——「マルチモデルデータベース」としての進化が、多様化する現代の要件に合致した。DB-Engines年間DBMS賞を直近7年で4回受賞し、MySQLとの差を着実に縮めている。

**両者の設計思想の違いは、スレッドvsプロセス、Undoログvsテーブル内バージョン保持（VACUUM）、レプリケーション方式など、あらゆるレイヤーに及ぶ。** だがこれは「劣った vs 優れた」ではない。異なる時代の異なる要請に対する、異なる設計判断だ。

冒頭の問いに戻ろう。「なぜMySQLはWeb開発で勝利し、PostgreSQLは『知る人ぞ知る存在』だったのか？」

答えは単純だ。MySQLは「手軽さ」を、PostgreSQLは「正しさ」を優先した。そして2000年代のWebは、正しさよりも手軽さを求めていた。レンタルサーバにインストールされていること、phpMyAdminで操作できること、PHPから数行で接続できること——それが「勝利条件」だった。

だが時代は変わった。ORMの普及がデータベースの選択をフレームワーク依存から解放し、クラウドのマネージドサービスが運用負荷の差を吸収し、アプリケーションの複雑化がデータ整合性の重要性を再認識させた。「手軽さ」の価値が相対的に下がり、「正しさ」の価値が上がった。PostgreSQLの逆転は、技術の進歩だけでなく、時代の変化の結果でもある。

次回は、RDBの黄金期を別の角度から掘り下げる。ストアドプロシージャとトリガー——ビジネスロジックをデータベースに置くべきか、アプリケーションに置くべきか。この問いは、RDBの能力が増すにつれて、避けて通れなくなった。

あなたのプロジェクトでは、MySQLとPostgreSQLのどちらを使っているだろうか。その選択は「選んだ」結果だろうか、それとも「そこにあったから」だろうか。

---

### 参考文献

- Wikipedia, "LAMP (software bundle)". <https://en.wikipedia.org/wiki/LAMP_(software_bundle)>
- TechCrunch, "Sun Picks Up MySQL For $1 Billion", 2008. <https://techcrunch.com/2008/01/16/sun-picks-up-mysql-for-1-billion-open-source-is-a-legitimate-business-model/>
- Wikipedia, "Acquisition of Sun Microsystems by Oracle Corporation". <https://en.wikipedia.org/wiki/Acquisition_of_Sun_Microsystems_by_Oracle_Corporation>
- Wikipedia, "Michael Widenius". <https://en.wikipedia.org/wiki/Michael_Widenius>
- Wikipedia, "MariaDB". <https://en.wikipedia.org/wiki/MariaDB>
- Wikipedia, "InnoDB". <https://en.wikipedia.org/wiki/InnoDB>
- Wikipedia, "MyISAM". <https://en.wikipedia.org/wiki/MyISAM>
- Wikipedia, "Innobase". <https://en.wikipedia.org/wiki/Innobase>
- PostgreSQL Documentation, "Release 8.0". <https://www.postgresql.org/docs/8.4/release-8-0.html>
- PostgreSQL Wiki, "What's new in PostgreSQL 9.0". <https://wiki.postgresql.org/wiki/What's_new_in_PostgreSQL_9.0>
- EnterpriseDB, "History of improvements in VACUUM in PostgreSQL". <https://www.enterprisedb.com/postgres-tutorials/history-improvements-vacuum-postgresql>
- MySQL Documentation, "Replication Formats". <https://dev.mysql.com/doc/mysql-replication-excerpt/5.7/en/replication-formats.html>
- Marcelo Altmann, "A Brief History of MySQL Replication", Medium. <https://altmannmarcelo.medium.com/a-brief-history-of-mysql-replication-85f057922800>
- DB-Engines, "PostgreSQL is the DBMS of the Year 2023". <https://db-engines.com/en/blog_post/106>
- DB-Engines, "MySQL vs. PostgreSQL historical trend". <https://db-engines.com/en/ranking_trend/system/MySQL;PostgreSQL>
- Bytebase, "Postgres vs. MySQL: a Complete Comparison in 2026". <https://www.bytebase.com/blog/postgres-vs-mysql/>

---

**次回予告：** 第9回「ストアドプロシージャとトリガー——ロジックはどこに置くべきか」では、数千行のPL/pgSQLと格闘した保守案件の記憶から始め、データベースにビジネスロジックを押し込む「ファットDB」アーキテクチャの功罪を検証する。テスト困難、バージョン管理不能、ベンダーロックイン——ストアドプロシージャが抱える問題の本質に迫る。
