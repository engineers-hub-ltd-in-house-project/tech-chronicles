# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第6回：Oracle, DB2, PostgreSQL——商用とOSSの系譜

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Oracle V2が1979年に世界初の商用SQL RDBMSとして登場した経緯
- IBMがSystem Rの成果を商用化したSQL/DSとDB2の戦略的意義
- Michael StonebrakerがIngresからPostgreSQLへ至る系譜を築いた道のり
- MySQLが「手軽さ」でWeb時代を制覇した理由
- OracleのMVCCとRAC、PostgreSQLの拡張性、MySQLのプラガブルストレージエンジンという設計判断の違い
- PostgreSQLとMySQLで同じスキーマ・同じクエリの挙動差を体験する方法

---

## 1. 「これが商用の力か」と思った日

2004年頃、私はある中規模の業務システム開発で、初めてOracle Databaseに触れた。

それまでの私はMySQLの世界で生きていた。PHPとMySQLでWebシステムを組み、phpMyAdminでテーブルを管理し、困ったらスロークエリログを眺める。それが私の「データベース」だった。

Oracleの管理画面にログインしたとき、最初に感じたのは異質な重厚さだった。Enterprise Managerの画面には、私が知らない概念が並んでいた。表領域（Tablespace）。データファイル。REDOログ。UNDOセグメント。SGAとPGA。MySQLでは意識したことのない、データベースの「内側」がすべて可視化されていた。

そしてクエリを投げたとき、衝撃を受けた。MySQLでは数秒かかっていた集計クエリが、Oracleでは一瞬で返ってきた。コストベースオプティマイザの精度、パラレルクエリの実行、マテリアライズドビューの自動リフレッシュ。「商用データベースとはこういうものか」と、素直に感嘆した。

だが同時に、ライセンスコストの桁に目を疑った。年間のライセンス費用だけで、MySQLのサーバを何台も買える。そして設定項目の多さに溺れそうになった。初期化パラメータだけで数百個ある。パフォーマンスチューニングには専門のDBAが必要で、Oracle認定資格（OCP）を持つエンジニアの時給は、PHPプログラマの倍だった。

数年後、PostgreSQLに出会ったとき、私は別の感覚を覚えた。解放感だ。Oracleの機能の多くが——MVCC、ウィンドウ関数、CTEによる再帰クエリ、JSONデータ型——PostgreSQLにもある。しかもオープンソースだ。ライセンスを気にせず、好きなだけインスタンスを立てられる。拡張機能（Extension）を追加すれば、全文検索も地理空間データも扱える。

あの日から20年以上が経った。今、私の周囲でOracleを新規に採用するプロジェクトは激減した。PostgreSQLが「デファクトスタンダード」の座に就きつつある。だがここに至るまでには、40年以上にわたる商用とOSSの競争と共進化の歴史がある。

リレーショナルデータベースの実装は、どのような競争の中で進化してきたのか。今回は、その系譜を辿る。

---

## 2. 世界初の商用SQL RDBMS——Oracle V2

### Larry Ellisonの賭け

前回（第5回）で見たように、Coddのリレーショナルモデル（1970年）とChamberlin & BoyceのSQL（1974年）は、データベースの世界に革命的な概念をもたらした。だが1970年代後半、IBMはこの革命を自社の商用製品に落とし込むことに慎重だった。System Rは研究プロジェクトであり、IBMの主力製品はあくまでIMSだった。IMSは莫大な収益を上げており、それを食い潰すリレーショナルデータベースを急いで商用化する理由は、IBM内部にはなかった。

その隙を突いたのが、外部の起業家たちだった。

1977年、Larry Ellison、Bob Miner、Ed Oatesの3人がカリフォルニア州サンタクララでSoftware Development Laboratories（SDL）を設立した。Ellisonは当時32歳。IBMのSystem Rに関する公開論文——特にSEQUELの仕様とSystem Rのアーキテクチャに関する技術報告——を読み、リレーショナルデータベースの商用化に巨大な市場機会があると確信した。

IBMが公開論文という形で研究成果を外部に出していたことは、歴史的に重要だ。System Rチームは学術的な伝統に従い、設計と実装の詳細を論文として発表していた。この「知の公開」が、結果としてIBMの競合を生み出すことになる。

SDLはRelational Software, Inc.（RSI）に改名し、リレーショナルデータベースの開発に着手した。開発言語はアセンブリ。ターゲットプラットフォームはDigital Equipment Corporation（DEC）のPDP-11ミニコンピュータだった。

### 1979年6月——Oracle V2

1979年6月、RSIはOracle V2をVAXコンピュータ向けにリリースした。

なぜV2なのか。V1は社内のプロトタイプであり、商用出荷されなかった。V2が最初の商用版だが、バージョン1の製品がないことで顧客に不信感を与えるリスクを避けるため、敢えてV2と名付けた。マーケティング判断だ。

Oracle V2は、世界初の商用SQL RDBMSとして歴史に刻まれることになる。正確に言えば、SQLのサブセットを実装した最初の商用リレーショナルデータベースだ。この時点でのSQL実装は限定的であり、トランザクション機能（COMMITとROLLBACK）すら備えていなかった。だが「SQLでデータベースに問い合わせる」という体験を商用製品として提供した最初の企業がRSIだったことは事実だ。

### Version 3——C言語への書き直しと移植性革命

1983年、Oracle Version 3がリリースされた。これは単なるバージョンアップではなく、アーキテクチャの根本的な転換だった。

V3はC言語で全面的に書き直された。この決定を推進したのはBruce Scottだ。Bob Minerはアセンブリ言語によるパフォーマンスの優位性を主張して抵抗したが、Scottの「単一のコードベースで複数プラットフォームに対応する」というビジョンが採用された。

この判断は決定的だった。C言語で書かれたOracle V3は、メインフレーム、ミニコンピュータ、パーソナルコンピュータのすべてで動作する初のRDBMSとなった。一つのコードベースがあらゆるプラットフォームで動く。当時のデータベース市場において、これは圧倒的な競争優位だった。顧客はハードウェアを乗り換えてもデータベースを変える必要がない。Oracleは「プラットフォーム非依存」を武器に急速にシェアを伸ばし、この年に売上を倍増させて500万ドルに到達した。

1983年、RSIはOracle Systems Corporation（後にOracle Corporation）に改名した。製品名と社名の一致は、リレーショナルデータベースに会社の命運を賭けるという意思表示だった。

---

## 3. IBMの反撃——SQL/DSとDB2

### なぜIBMは遅れたのか

IBMはリレーショナルモデルの「発明者」であり、System RでSQLの実装を先駆けたにもかかわらず、商用化ではOracleに先を越された。なぜか。

理由は組織の力学だ。1970年代後半のIBMにとって、IMSは年間数十億ドルを生む主力製品だった。IMSチームは社内で強大な政治力を持ち、リレーショナルデータベースの商用化はIMSの市場を侵食するものとして抵抗した。Codd自身がIBM内部でこの抵抗に直面していたことは、第4回で触れた通りだ。

さらに、IBMの文化は「完璧な製品を出す」ことを重視した。System Rはあくまで研究プロトタイプであり、商用レベルの品質に達するには時間がかかる。一方、OracleのEllisonは「とりあえず動くものを出す」スタンスだった。機能が不完全でも、市場に最初に出た者がルールを作る。この哲学の違いが、商用化の速度を分けた。

### SQL/DS（1981年）

IBMが最初に投入した商用リレーショナルデータベースは、SQL/DS（SQL/Data System）だ。1981年、DOS/VSEおよびVM/CMS環境向けにリリースされた。

SQL/DSはSystem Rの技術を直接的に基盤としていた。だがSQL/DSのターゲットは中小規模のシステムであり、IBMの主力メインフレームMVS向けではなかった。MVS上の主力データベースはあくまでIMSであり、IBMはまだリレーショナルデータベースをIMSの代替として位置づけることに慎重だった。

### DB2（1983年）

1983年、IBMはついにMVSメインフレーム向けのリレーショナルデータベースDB2（IBM Database 2）を発表した。一般利用可能（GA）となったのは1985年だ。

DB2の投入は、IBMがリレーショナルモデルを「本気で」商用化するという宣言だった。MVSメインフレームはIBMの最重要プラットフォームであり、そこにリレーショナルデータベースを投入するということは、長期的にIMSからの移行を視野に入れたことを意味する。

結果は明確だった。1989年までにDB2の売上は約10億ドルに成長し、IMSの売上と肩を並べた。リレーショナルモデルの商用的な正当性は、もはや疑いの余地がなかった。

### 「発明者」と「商用化の先駆者」の乖離

ここで注目すべきは、IBM——リレーショナルモデルの発明者であり、SQLの開発者であり、System Rの構築者——が、商用化ではOracleに後塵を拝したという事実だ。

技術を発明した組織が、その技術の商用化で最初に成功するとは限らない。研究と事業化のあいだには深い溝がある。IBMはその溝を越えるのに、Oracleより4年以上遅れた。そして4年の遅れは、市場のルールを決める権利を失うことを意味した。

この構図は、テクノロジーの歴史で繰り返し現れる。Xerox PARCがGUIを発明し、Appleがそれを商用化した。BellLabsがUnixを生み出し、Linuxがその思想を引き継いで市場を制した。発明と普及は別の能力であり、別の組織が担うことが多い。

---

## 4. Berkeley学派——IngresからPostgreSQLへ

### Ingres——もう一つのリレーショナルデータベース

System Rを生んだIBM San Jose Research Laboratoryは、リレーショナルデータベースの唯一の研究拠点ではなかった。東海岸のIBMに対し、西海岸のUC BerkeleyでもCoddのリレーショナルモデルの実装が進んでいた。

1974年、UC BerkeleyのMichael StonebrakerとEugene Wongが、リレーショナルデータベースIngres（Interactive Graphics and Retrieval System）のプロトタイプを完成させた。名前はフランスの画家アングル（Ingres）にちなんでいるが、偶然にも格好よい頭字語にもなっていた。

Ingresの開発資金は、DARPA（国防高等研究計画局）、ARO（陸軍研究局）、NSF（全米科学財団）などの助成金だった。労働力の多くは大学院生と学部生だ。IBMの企業研究所が潤沢な予算と専任の研究者を抱えていたのとは対照的な、大学研究室のスタイルだった。

Ingresの問い合わせ言語はQUELだった。前回（第5回）で触れたように、QUELはCoddの関係論理に基づく言語であり、技術的にはSQLよりも洗練されていたとする評価もある。だが歴史はSQLを選んだ。1986年のANSI標準化によってSQLが業界標準となり、IngresもQUELからSQLへの移行を余儀なくされた。

Ingresが歴史的に重要なのは、製品そのものだけでなく、そこから生まれた「人」と「派生物」だ。Ingresプロジェクトで訓練を受けた学生たちは、多くのデータベース製品を生み出した。Britton-Lee、TandemのNonStop SQL、そしてSybase。データベース産業の人材を大量に輩出したIngresは、リレーショナルデータベースの「教育機関」でもあった。

1980年、Stonebraker自身がRelational Technology, Inc.を共同設立し、Ingresの商用版を開発した。だがStonebrakerの関心は、Ingresの延長線上にはなかった。

### POSTGRES——「Ingresの次」

1986年、StonebrakerはUC Berkeleyで新しいプロジェクトを開始した。POSTGRES（Post-Ingres）だ。

POSTGRESの動機は、Ingresとリレーショナルモデルの限界を超えることにあった。Stonebrakerは、当時のリレーショナルデータベースが抱えていた問題を明確に認識していた。

第一に、データ型の貧弱さ。リレーショナルモデルは整数、浮動小数点数、文字列といった基本的なデータ型しか扱えなかった。だが現実のアプリケーション——CAD/CAM、地理情報システム（GIS）、マルチメディア——は、もっと複雑なデータ構造を必要としていた。

第二に、ルールシステムの不在。データの整合性を維持するための規則を、データベースの内部に埋め込む仕組みが不十分だった。

POSTGRESの核心的な設計思想は「拡張性（extensibility）」だ。ユーザーが独自のデータ型を定義し、独自の演算子を作り、独自のインデックスメソッドを追加できる。データベースは固定された機能の箱ではなく、拡張可能な基盤（platform）であるべきだ。この思想は、後のPostgreSQLに直接受け継がれることになる。

1987年にデモシステムが動作し、1989年にVersion 1が外部にリリースされた。その後Version 4.2までBerkeleyで開発が続けられたが、Stonebrakerは1992年にBerkeleyを去り、POSTGRESの商用化のためにIllustra Information Technologies（後にInformixが買収）を設立した。

### Postgres95からPostgreSQLへ

BerkeleyのPOSTGRESプロジェクトはVersion 4.2で公式に終了した。だがコードはオープンに公開されていた。

1994年、大学院生のAndrew YuとJolly ChenがPOSTGRESにSQL言語インタプリタを追加した。POSTGRESのオリジナル問い合わせ言語POSTQUELを、業界標準のSQLに置き換えたのだ。1995年、この改良版はPostgres95としてWebに公開され、オープンソースの道を歩み始めた。

1996年、コミュニティは「Postgres95」という名前が時の試練に耐えないと判断し、PostgreSQLに改名した。オリジナルのPOSTGRESプロジェクトとSQLサポートの両方を名前に反映した命名だ。

IngresからPOSTGRES、Postgres95を経てPostgreSQLへ。この系譜の背後には、常にStonebrakerのビジョンがある。リレーショナルモデルの限界を見据え、拡張性という設計原則を埋め込み、オープンな開発モデルで世界に公開する。Stonebrakerは2014年にACMチューリング賞を受賞した。「現代のデータベースシステムの基盤となる概念と実践への根本的な貢献」がその理由だ。

---

## 5. MySQLとSQL Server——Web時代とエンタープライズ

### MySQL——速度と手軽さの追求

1990年代半ば、もう一つのリレーショナルデータベースが静かに登場した。

スウェーデン人のDavid AxmarkとAllan Larsson、フィンランド人のMichael "Monty" Wideniusが開発したMySQLだ。開発は1994年に始まり、最初のバージョンは1995年5月23日に登場した。

MySQLの出自は、OracleやDB2、あるいはIngres/PostgreSQLとは根本的に異なる。Oracleは商用市場を狙った起業家の野心から生まれ、DB2はIBMの企業戦略から、Ingres/PostgreSQLは学術研究から生まれた。MySQLは、Wideniusが個人的に使っていたmSQL（miniSQL）が遅すぎるため、より高速な代替を作ったことに始まる。学術的な理論よりも実用的な速度を、機能の網羅性よりも手軽さを優先した設計だった。

MySQLの最初のストレージ層はISAM（Indexed Sequential Access Method）に基づいていた。後にMyISAMに進化するこのストレージエンジンは、トランザクション（ACID）をサポートしない代わりに、読み取り性能が高かった。テーブルレベルロックという粗い並行制御は、書き込みの多いワークロードには不向きだったが、読み取りが圧倒的に多いWebアプリケーションには十分だった。

外部キー制約もなかった。`JOIN`の最適化も洗練されていなかった。SQL標準への準拠も低かった。PostgreSQLと比べれば「機能が足りない」データベースだった。

だがMySQLは爆発的に普及した。

理由は単純だ。インストールが簡単で、設定がほぼ不要で、速くて、無料だった。LAMPスタック——Linux、Apache、MySQL、PHP——の「M」として、世界中のWebホスティング環境にプリインストールされた。レンタルサーバを借りれば、MySQLはすでにそこにあった。`apt-get install mysql-server`で入る。phpMyAdminでブラウザから操作できる。2000年代前半のWebエンジニアにとって、MySQLは「データベース」の同義語だった。

### SQL Server——エンタープライズのもう一つの系譜

1988年1月、Microsoft、Sybase、Ashton-Tateの3社が共同開発契約を発表した。SybaseがUNIX向けに開発していたリレーショナルデータベースサーバ技術をMicrosoftにライセンスし、OS/2向けに適応するというものだ。

1989年、SQL Server v1.0がリリースされた。16ビットのOS/2向けリレーショナルデータベースだ。基盤はSybase SQL Server 3.0 for UNIX/VMSだった。

その後、MicrosoftはSQL ServerをWindows NT向けに独自に発展させ、Sybaseとの提携は1993年に終了した。SQL ServerはWindows環境における支配的なRDBMSとなり、.NETフレームワークやVisual Studioとの緊密な統合を強みに、企業のWindows環境に深く浸透していった。

Oracle、DB2、PostgreSQL、MySQL、SQL Server。1990年代末までに、リレーショナルデータベースの主要な系譜が出揃った。だがこれらは単なる「同じ概念の異なる実装」ではない。それぞれが異なる設計哲学を持ち、異なるトレードオフを選び、異なる市場で戦った。

---

## 6. 三つの設計哲学——Oracle、PostgreSQL、MySQL

### Oracle——商用の力と垂直統合

Oracleの設計哲学は「あらゆるものを自前で提供する」垂直統合だ。

OracleのMVCC（Multi-Version Concurrency Control）実装は、Undoセグメント（旧称ロールバックセグメント）を用いた独自の方式だ。トランザクションがデータを変更すると、変更前の値がUndoセグメントに記録される。他のトランザクションがそのデータを読み取るとき、コミットされていない変更は見えない。代わりにUndoセグメントから変更前の値が読み取られる。

この仕組みにより、Oracleは「読み取りが書き込みをブロックしない」読み取り一貫性を実現した。MVCC概念自体は1978年のDavid P. Reedの博士論文に遡り、最初の商用実装はDEC VAX Rdb/ELN（1984年、Jim Starkey）とされるが、Oracleは商用RDBMSにおける早期かつ大規模な実装者の一つだ。

2001年、Oracle 9iでReal Application Clusters（RAC）が導入された。RACの前身はOracle Parallel Server（OPS、Oracle 7で1992年に導入）だ。OPSはディスクベースのロックを使用し、ノード間のデータ転送が遅かった。RACはCache Fusion技術によりノード間のメモリ-メモリ直接転送を実現し、共有ディスクアーキテクチャ上でのスケーラビリティを大幅に改善した。

Oracleの強みは「何でもできる」ことだ。パーティショニング、マテリアライズドビュー、Advanced Queuing、Flashback Technology、Data Guard。あらゆるエンタープライズ要件に対応する機能が、一つの製品に統合されている。だがその代償はコストだ。ライセンス費用、専任DBAの人件費、トレーニングコスト。Oracleを選ぶということは、その経済的負担を受け入れるということだ。

### PostgreSQL——拡張性と標準準拠

PostgreSQLの設計哲学は、Stonebrakerが1986年のPOSTGRESプロジェクトで掲げた「拡張性」を直接受け継いでいる。

PostgreSQLでは、ユーザーが独自のデータ型を定義し、その型に対する演算子を作り、その型を効率的に検索するためのインデックスメソッドを追加できる。これは単なる「プラグイン機構」ではない。PostgreSQLのカタログテーブル（システムテーブル）にはハードコードされた型や演算子のリストがない。すべてがカタログに登録されたオブジェクトであり、ユーザー定義のものも組み込みのものも同じ仕組みで管理される。

この設計が生み出した成果は多岐にわたる。PostGIS（地理空間データ拡張）、pg_trgm（トライグラム検索）、pgvector（ベクトル検索）。これらはすべて、PostgreSQLの拡張性アーキテクチャの上に構築されている。データベースの「外側」でなく「内側」に新しい機能を追加できるため、クエリオプティマイザのコスト推定やインデックスの利用といったデータベースエンジンの恩恵を、拡張機能もフルに受けられる。

もう一つの特徴がSQL標準への高い準拠度だ。PostgreSQLは公式ドキュメントでSQL標準との差異を明記しており、可能な限り標準に従う方針を持っている。ウィンドウ関数、CTE（共通テーブル式）、LATERAL JOIN、JSONBデータ型。SQL標準の新機能は、比較的早くPostgreSQLに取り込まれる。

### MySQL——プラガブルストレージエンジンと手軽さ

MySQLの最も特徴的なアーキテクチャ決定は、プラガブルストレージエンジンだ。

SQL層（パーサー、オプティマイザ、実行エンジン）とストレージ層を分離し、ストレージエンジンを差し替えられる設計だ。MyISAM、InnoDB、MEMORY、CSV、Archive——それぞれ異なる特性を持つストレージエンジンを、テーブルごとに選択できる。

この設計は柔軟性をもたらした。読み取り中心のテーブルにはMyISAMを、トランザクションが必要なテーブルにはInnoDBを。一つのデータベース内で用途に応じたストレージを使い分けられる。

だが同時に、この設計は問題も引き起こした。ストレージエンジンごとに機能が異なるため、「MySQLでできること」が一意に定まらない。MyISAMにはトランザクションがないが、InnoDBにはある。MyISAMには全文検索があるが（初期の頃）、InnoDBにはなかった（後に追加された）。SQL層とストレージ層のインターフェースの制約により、一部の最適化がストレージエンジン横断で実現しにくかった。

InnoDBの歴史は特筆に値する。1995年、フィンランドのHeikki TuuriがInnobase Oyを設立し、InnoDB ストレージエンジンの開発を開始した。InnoDBはACID準拠、行レベルロック、MVCCを備え、MySQLに「本物のトランザクション」をもたらした。MySQL ABとInnobase Oyは緊密に協力し、InnoDBはMySQL利用者の40%以上に使われるようになった。

2005年10月、OracleがInnobase Oyを買収した。MySQL ABにとっては衝撃だった。最も重要なストレージエンジンの開発元が、最大の競合であるOracleの傘下に入ったのだ。この買収は、後のSunによるMySQL買収、そしてOracleによるSun買収への伏線となる。

2010年12月、MySQL 5.5がリリースされ、ついにInnoDBがデフォルトストレージエンジンに変更された。MyISAMの時代は終わり、MySQLもトランザクション対応のデータベースとしての道を本格的に歩み始めた。

```
RDBMS設計哲学の比較

  Oracle                PostgreSQL             MySQL
  ┌──────────────┐     ┌──────────────┐      ┌──────────────┐
  │ 垂直統合     │     │ 拡張性       │      │ 手軽さ       │
  │              │     │              │      │              │
  │ ・あらゆる   │     │ ・ユーザー   │      │ ・インストール│
  │   機能を内蔵 │     │   定義型     │      │   が簡単     │
  │ ・RAC        │     │ ・カスタム   │      │ ・プラガブル  │
  │ ・Flashback  │     │   演算子     │      │   ストレージ │
  │ ・Data Guard │     │ ・拡張Index  │      │ ・LAMP Stack │
  │ ・高コスト   │     │ ・標準準拠   │      │ ・低い参入障壁│
  │              │     │ ・無料       │      │ ・無料       │
  └──────────────┘     └──────────────┘      └──────────────┘
       │                     │                     │
  Enterprise           Developer             Web Application
  Mission Critical     Freedom               Speed & Simplicity
```

---

## 7. 所有と自由——商用DBからOSSへの転換

### Sun/Oracle買収劇

MySQLの歴史は、データベース業界の所有権をめぐるドラマでもある。

2008年2月、Sun MicrosystemsがMySQL ABを10億ドルで買収した。SunはJava、Solaris、SPARCプロセッサの企業であり、MySQL ABの買収はオープンソースソフトウェアへの投資拡大の一環だった。

だがSun自体が経営難に陥った。2009年4月20日、OracleがSun Microsystemsを74億ドルで買収すると発表した。この買収により、OracleはJava、MySQL、Solaris、そしてSPARCという巨大な技術ポートフォリオを手に入れることになった。

欧州委員会は、OracleによるMySQL支配がオープンソースデータベース市場の競争を損なう可能性があるとして調査を開始した。2010年1月27日、条件付きで買収が承認され、完了した。

MySQLの生みの親であるMichael "Monty" Wideniusは、OracleによるMySQL支配を懸念し、2009年にMySQLをフォークしてMariaDBの開発を開始した。MySQLの開発者の一部もWideniusのもとに移った。MariaDBはMySQLとのバイナリ互換を維持しつつ、独自の機能拡張（Ariaストレージエンジン、ColumnStoreなど）を進めていった。

### 「所有者」が変わっても生き残るコード

この一連の買収劇は、オープンソースソフトウェアの本質的な特性を浮き彫りにした。コードは所有者が変わっても、フォークという手段で生き残る。MySQLのコードベースはOracle傘下のMySQL Community Editionとして存続し、同時にMariaDB、Percona Server for MySQLといったフォークとして分岐した。

一方、プロプライエタリなデータベースにはこの「安全弁」がない。Oracleのコードをフォークすることは不可能だ。ライセンスを打ち切られれば、移行先を探すしかない。この「ベンダーロックイン」のリスクは、2010年代以降、企業がPostgreSQLやMySQLを選ぶ大きな動機の一つとなった。

Stonebrakerのチューリング賞受賞（2014年）は、データベース研究のOSSへの貢献が学術的にも認められた証だ。Ingres、POSTGRES、PostgreSQL。学術研究がオープンソースを通じて産業に浸透する経路を切り拓いたのは、Stonebrakerの系譜だった。

---

## 8. ハンズオン: PostgreSQLとMySQLの挙動の違いを体験する

今回のハンズオンでは、PostgreSQLとMySQLをDockerで立ち上げ、同じスキーマ・同じクエリの挙動の違いを観察する。

### 演習概要

1. PostgreSQLとMySQLで同じテーブルを作成し、型の扱いの違いを観察する
2. NULL処理と文字列比較の挙動差を確認する
3. 外部キー制約の振る舞いの違いを体験する
4. EXPLAIN出力の読み比べを行う

### 環境構築

Docker環境でPostgreSQLとMySQLを同時に起動する。

```bash
# handson/database-history/06-rdbms-genealogy/setup.sh を実行
bash setup.sh
```

### 演習1: 型の厳密さの違い

```sql
-- === PostgreSQL ===
CREATE TABLE type_test (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    age INTEGER NOT NULL
);

-- PostgreSQLでは型が厳密
INSERT INTO type_test (name, age) VALUES ('Alice', 30);     -- OK
INSERT INTO type_test (name, age) VALUES ('Bob', '25');      -- OK（暗黙の型変換）
INSERT INTO type_test (name, age) VALUES ('Charlie', 'abc'); -- ERROR!
-- ERROR:  invalid input syntax for type integer: "abc"
```

```sql
-- === MySQL (sql_mode='') ===
CREATE TABLE type_test (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    age INT NOT NULL
);

-- MySQLのデフォルト（STRICT_TRANS_TABLESなし）では寛容
INSERT INTO type_test (name, age) VALUES ('Alice', 30);      -- OK
INSERT INTO type_test (name, age) VALUES ('Bob', '25');       -- OK
INSERT INTO type_test (name, age) VALUES ('Charlie', 'abc');  -- Warning! age=0で挿入される
```

MySQL 8.0以降のデフォルトでは`STRICT_TRANS_TABLES`が有効であり、`'abc'`のようなINT不正入力はエラーになる。だが歴史的に、MySQLは「なるべくエラーにしない」方針で設計されていた。この寛容さはWebアプリケーションの素早いプロトタイピングには便利だったが、データの整合性という観点では危険だった。

### 演習2: 文字列比較とNULLの挙動

```sql
-- === PostgreSQL ===
-- 文字列比較はバイナリ比較（照合順序依存）
SELECT 'abc' = 'ABC';  -- false（デフォルトではcase-sensitive）
SELECT '' IS NULL;       -- false（空文字列とNULLは別物）

-- === MySQL ===
-- デフォルトの照合順序（utf8mb4_0900_ai_ci）ではcase-insensitive
SELECT 'abc' = 'ABC';  -- 1（true）
SELECT '' IS NULL;       -- 0（false, MySQLでも空文字列とNULLは区別する）
```

PostgreSQLはデフォルトでcase-sensitiveな比較を行うが、MySQLのデフォルト照合順序（`utf8mb4_0900_ai_ci`、MySQL 8.0以降）はcase-insensitiveかつアクセント非感知（accent-insensitive）だ。この違いを知らずにデータベースを移行すると、`WHERE name = 'Smith'`と`WHERE name = 'smith'`の結果が変わる。

### 演習3: 外部キー制約の振る舞い

```sql
-- === 両方で同じスキーマを作成 ===
CREATE TABLE departments (
    dept_code VARCHAR(10) PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,  -- PostgreSQL
    -- emp_id INT AUTO_INCREMENT PRIMARY KEY,  -- MySQL
    name VARCHAR(100) NOT NULL,
    dept_code VARCHAR(10) REFERENCES departments(dept_code)
);

INSERT INTO departments VALUES ('D01', 'Engineering');

-- 存在しない部署コードで挿入を試みる
INSERT INTO employees (name, dept_code) VALUES ('Alice', 'D99');
-- PostgreSQL: ERROR（外部キー制約違反）
-- MySQL (InnoDB): ERROR（外部キー制約違反）
-- MySQL (MyISAM): 成功！（MyISAMは外部キー制約を無視する）
```

MyISAMストレージエンジンは外部キー制約の構文を受け付けるが、実際には何も検証しない。`CREATE TABLE`文にFOREIGN KEY句を書いても、制約は効かない。これは「SQLの構文は受け入れるが意味論は無視する」というMyISAMの設計方針であり、長年にわたって多くのバグの温床となった。InnoDBでは外部キー制約が正しく機能する。

### 演習4: EXPLAIN出力の読み比べ

```sql
-- テストデータを投入した後、同じクエリのEXPLAIN出力を比較する

-- === PostgreSQL ===
EXPLAIN ANALYZE
SELECT e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_code = d.dept_code
WHERE d.dept_name = 'Engineering';

-- PostgreSQLのEXPLAIN出力:
-- Hash Join  (cost=1.02..24.15 rows=6 width=26) (actual time=...)
--   Hash Cond: (e.dept_code = d.dept_code)
--   ->  Seq Scan on employees e  (cost=...)
--   ->  Hash  (cost=1.01..1.01 rows=1 width=16)
--         ->  Seq Scan on departments d  (cost=...)
--               Filter: (dept_name = 'Engineering')

-- === MySQL ===
EXPLAIN
SELECT e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_code = d.dept_code
WHERE d.dept_name = 'Engineering';

-- MySQLのEXPLAIN出力:
-- +----+-------+------+--------+------+----------+-----------+
-- | id | table | type | key    | rows | filtered | Extra     |
-- +----+-------+------+--------+------+----------+-----------+
-- |  1 | d     | ALL  | NULL   |    5 |    20.00 | Using ... |
-- |  1 | e     | ref  | idx_dc |    6 |   100.00 | NULL      |
-- +----+-------+------+--------+------+----------+-----------+
```

PostgreSQLのEXPLAIN出力はツリー構造で、各ノードの推定コストと実際の実行時間（`EXPLAIN ANALYZE`の場合）を表示する。MySQLのEXPLAIN出力は表形式で、テーブルごとのアクセス方式とフィルタ条件を表示する。同じクエリ、同じデータでも、オプティマイザの判断は異なる。これは各RDBMSが異なる最適化戦略を持っていることの直接的な現れだ。

### 後片付け

```bash
docker rm -f db-history-ep06-pg db-history-ep06-mysql
```

---

## 9. 「正しさ」と「手軽さ」の綱引き

第6回を振り返ろう。

**リレーショナルデータベースの商用化は、IBMの外部から始まった。** 1979年、Larry EllisonらのRelational Software, Inc.がOracle V2を世界初の商用SQL RDBMSとしてリリースした。IBMがSystem Rの成果を商用化したSQL/DS（1981年）とDB2（1983年）は、それぞれ2年と4年遅れた。技術の発明者が商用化の先駆者になるとは限らない。

**UC Berkeleyからは、Ingres→POSTGRES→PostgreSQLという系譜が生まれた。** Michael StonebrakerはIngres（1974年）でリレーショナルデータベースの実装を先導し、POSTGRES（1986年）で拡張性という設計原則を確立した。1996年にPostgreSQLに改名されたこのデータベースは、オープンソースの力で今日のデファクトスタンダードに成長した。

**MySQLは「手軽さ」でWeb時代を制覇した。** 1995年に登場したMySQLは、機能よりも速度と簡単さを優先し、LAMPスタックの「M」として爆発的に普及した。だがSunによる買収（2008年）、Oracleによる買収（2010年）を経て、所有権の問題がオープンソースコミュニティに波紋を広げた。

**三つの設計哲学が市場を形作った。** Oracleは垂直統合によるエンタープライズ機能の網羅、PostgreSQLは拡張性とSQL標準準拠、MySQLはプラガブルストレージエンジンと手軽さ。それぞれが異なるトレードオフを選び、異なる市場で勝利した。

冒頭の問いに戻ろう。「リレーショナルデータベースの実装は、どのような競争の中で進化してきたのか」。答えは、「正しさ」と「手軽さ」の綱引きだ。

Oracleは企業に信頼を提供した。「この金を払えば、あらゆる問題に対応できる」。PostgreSQLは開発者に自由を提供した。「コードは公開されている。好きなように拡張しろ」。MySQLはWebに手軽さを提供した。「難しいことは考えるな。まずインストールしろ。動かせ」。

どれが「正解」だったかと問うのは意味がない。それぞれが、それぞれの時代と市場のニーズに応えた。そして今、PostgreSQLがかつてのMySQLのポジション——「とりあえず選ばれるデータベース」——に就きつつある。だがそれは、PostgreSQLがMySQLよりも「優れている」からではなく、時代が「手軽さ」と「正しさ」の両方を求めるようになったからだ。

あなたが次にデータベースを選ぶとき、その選択に意識的であってほしい。「なぜそれを選ぶのか」を言語化できること。それが、この連載を通じて私が伝えたいことだ。

次回は、データベースの最も根源的な約束——トランザクションとACID特性——を掘り下げる。データの「約束」をどう守るのか。Jim Grayの業績からMVCCの仕組み、分離レベルのトレードオフまで、データベースの信頼性の核心に迫る。

---

### 参考文献

- Oracle Corporation, "50 Years of the Relational Database". <https://www.oracle.com/database/50-years-relational-database/>
- Oracle Corporation, "Profit Magazine Anniversary Timeline". <https://www.oracle.com/us/corporate/profit/p27anniv-timeline-151918.pdf>
- IBM, "The Relational Database". <https://www.ibm.com/history/relational-database>
- IEEE Annals of the History of Computing, "SQL/DS: IBM's First RDBMS", Vol.35, No.2. <https://dl.acm.org/doi/10.1109/MAHC.2013.28>
- UC Berkeley EECS, "INGRES - A Relational Data Base System", Technical Report, 1974. <https://www2.eecs.berkeley.edu/Pubs/TechRpts/1974/28785.html>
- ACM, "Michael Stonebraker - A.M. Turing Award Laureate". <https://amturing.acm.org/award_winners/stonebraker_1172121.cfm>
- PostgreSQL Documentation, "A Brief History of PostgreSQL". <https://www.postgresql.org/docs/current/history.html>
- Michael Stonebraker, Lawrence A. Rowe, "The Design of POSTGRES", UC Berkeley, 1986. <https://dsf.berkeley.edu/papers/ERL-M85-95.pdf>
- Wikipedia, "MySQL". <https://en.wikipedia.org/wiki/MySQL>
- Oracle MySQL Blog, "MySQL Retrospective – The Early Years". <https://blogs.oracle.com/mysql/mysql-retrospective-the-early-years>
- Wikipedia, "History of Microsoft SQL Server". <https://en.wikipedia.org/wiki/History_of_Microsoft_SQL_Server>
- Wikipedia, "Multiversion concurrency control". <https://en.wikipedia.org/wiki/Multiversion_concurrency_control>
- Wikipedia, "Oracle RAC". <https://en.wikipedia.org/wiki/Oracle_RAC>
- Wikipedia, "Innobase". <https://en.wikipedia.org/wiki/Innobase>
- MySQL Reference Manual, "Alternative Storage Engines". <https://dev.mysql.com/doc/refman/8.4/en/storage-engines.html>
- Wikipedia, "Acquisition of Sun Microsystems by Oracle Corporation". <https://en.wikipedia.org/wiki/Acquisition_of_Sun_Microsystems_by_Oracle_Corporation>

---

**次回予告：** 第7回「ACIDとトランザクション——データの『約束』をどう守るか」では、データベースの最も根源的な機能であるトランザクションを掘り下げる。Jim Grayの研究、ACID特性の定式化、分離レベルのトレードオフ、MVCCの仕組みまで、「データの約束」を守る技術の核心に迫る。
