# ファクトチェック記録：第7回「ACIDとトランザクション——データの『約束』をどう守るか」

## 1. Jim Gray の生没年とキャリア

- **結論**: James Nicholas Gray、1944年1月12日サンフランシスコ生まれ。2007年1月28日にファラロン諸島沖へ単独航海に出発し行方不明。2012年1月28日に法的に死亡宣告。UC Berkeleyで数学・工学の学士号（1966年）、コンピュータサイエンスの博士号（1969年、Berkeley初のCS博士号）。IBM（1971-1980年）、Tandem Computers（1980-1990年）、DEC（1990-1994年）、Microsoft Research（1995-2007年）に在籍
- **一次ソース**: ACM Turing Award page; Britannica; Wikipedia
- **URL**: <https://amturing.acm.org/award_winners/gray_3649936.cfm>
- **注意事項**: 生年は1944年で確定。ブループリントの「1944-2003年」は誤り（2003年はCoddの没年と混同か）。2007年失踪、2012年法的死亡宣告が正確
- **記事での表現**: Jim Gray（1944年生まれ、2007年行方不明）

## 2. Jim Gray のチューリング賞（1998年）

- **結論**: 1998年ACMチューリング賞受賞。受賞理由は "for seminal contributions to database and transaction processing research and technical leadership in system implementation"
- **一次ソース**: ACM A.M. Turing Award page
- **URL**: <https://amturing.acm.org/award_winners/gray_3649936.cfm>
- **注意事項**: なし
- **記事での表現**: 1998年、Jim Grayはデータベースおよびトランザクション処理研究への先駆的貢献でACMチューリング賞を受賞した

## 3. Jim Gray「The Transaction Concept: Virtues and Limitations」（1981年）

- **結論**: 1981年9月、VLDB '81（第7回国際超大規模データベース会議）で発表。Tandem Computers所属。pp.144-154。トランザクションの概念を原子性・永続性・一貫性の特性として定式化
- **一次ソース**: ACM Digital Library; Jim Gray Azurewebsites
- **URL**: <https://dl.acm.org/doi/10.5555/1286831.1286846>, <https://jimgray.azurewebsites.net/papers/thetransactionconcept.pdf>
- **注意事項**: この1981年論文ではまだACID頭字語は使われていない。ACIDの頭字語は1983年Haerder & Reuter論文で登場
- **記事での表現**: 1981年、Jim GrayはVLDB会議で「The Transaction Concept: Virtues and Limitations」を発表し、トランザクションを状態変換の単位として形式的に定義した

## 4. ACID特性の定式化: Haerder & Reuter（1983年）

- **結論**: Theo HaerderとAndreas Reuterが1983年12月にACM Computing Surveys, Vol.15, pp.287-317に発表した「Principles of Transaction-Oriented Database Recovery」でACID（Atomicity, Consistency, Isolation, Durability）の頭字語を導入
- **一次ソース**: ACM Computing Surveys
- **URL**: <https://dl.acm.org/doi/10.1145/289.291>
- **注意事項**: ACID概念自体はGrayの1981年論文等で既に議論されていたが、ACIDという頭字語の初出はこの1983年論文
- **記事での表現**: 1983年、Theo HaerderとAndreas Reuterの論文「Principles of Transaction-Oriented Database Recovery」でACIDの頭字語が定式化された

## 5. Write-Ahead Logging（WAL）の歴史

- **結論**: WALの概念はIBM System Rプロジェクト（1974-1979年）に遡る。Jim Grayらの研究によりトランザクション回復のためのログ概念が確立された。1980年代にHaerder & Reuter（1983年）がWALの役割を分類体系の中で整理。PostgreSQLはバージョン7.1（2001年）でWALを導入
- **一次ソース**: Wikipedia "Write-ahead logging"; PostgreSQL Documentation
- **URL**: <https://en.wikipedia.org/wiki/Write-ahead_logging>, <https://www.postgresql.org/docs/current/wal-intro.html>
- **注意事項**: WALの「発明者」は特定の一人に帰属しにくい。System Rの回復サブシステムの中で発展した概念
- **記事での表現**: WALの原理はIBM System Rプロジェクト（1974-1979年）の中で確立された

## 6. 二相コミットプロトコルの起源

- **結論**: Jim Grayが1978年の論文「Notes on Data Base Operating Systems」で二相コミットプロトコルを導入。ただし類似の概念はLampsonとSturgis（1976年）でも独立に記述されていた。Lindsay et al.（1979年）も独立の記述がある
- **一次ソース**: Wikipedia "Two-phase commit protocol"; Gray, "Notes on Data Base Operating Systems", 1978
- **URL**: <https://en.wikipedia.org/wiki/Two-phase_commit_protocol>
- **注意事項**: 複数の研究者が独立に同様のプロトコルを記述しており、Grayのみの発明とは言い切れない
- **記事での表現**: 二相コミットプロトコルはJim Gray（1978年）らにより定式化された

## 7. MVCC（Multi-Version Concurrency Control）の起源

- **結論**: David P. Reedが1978年のMIT博士論文「Naming and Synchronization in a Decentralized Computer System」でMVCCを記述し、オリジナルの成果と主張。最初の商用実装はDEC VAX Rdb/ELN（1984年、Jim Starkey）。InterBase（1981年に実装開始）。OracleはVersion 3（1983年）以降にMVCC的なUndoセグメントを実装。PostgresはStonebrakerのPOSTGRES（1985年）以降
- **一次ソース**: Wikipedia "Multiversion concurrency control"; CMU 15-721 lecture notes
- **URL**: <https://en.wikipedia.org/wiki/Multiversion_concurrency_control>
- **注意事項**: MVCCの「最初の実装」は複数の候補がある。第6回で既にOracleのMVCC実装について言及済み
- **記事での表現**: MVCC概念は1978年のDavid P. ReedのMIT博士論文に遡る

## 8. SQL-92のトランザクション分離レベル標準

- **結論**: SQL:1992標準で4つの分離レベルが定義された: READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE。異常現象（Dirty Read, Non-Repeatable Read, Phantom Read）に基づく定義
- **一次ソース**: PostgreSQL Documentation; Wikipedia "Isolation (database systems)"
- **URL**: <https://en.wikipedia.org/wiki/Isolation_(database_systems)>
- **注意事項**: 1995年のBerenson et al.「A Critique of ANSI SQL Isolation Levels」（SIGMOD 95）でSQL-92の分離レベル定義の不備が指摘され、Snapshot Isolationが定義された
- **記事での表現**: SQL:1992標準は4つのトランザクション分離レベルを定義した

## 9. Snapshot Isolation の批判論文

- **結論**: Hal Berenson, Phil Bernstein, Jim Gray, Jim Melton, Elizabeth O'Neil, Patrick O'Neilが1995年のACM SIGMOD会議で「A Critique of ANSI SQL Isolation Levels」を発表。SQL-92の分離レベル定義の曖昧さを指摘し、Snapshot Isolationを定義した
- **一次ソース**: ACM Digital Library
- **URL**: <https://dl.acm.org/doi/10.1145/223784.223785>
- **注意事項**: Jim Gray自身がこの論文の共著者
- **記事での表現**: 1995年、Berenson, Bernstein, Grayらの論文がSQL-92分離レベル定義の不備を指摘し、Snapshot Isolationを正式に定義した

## 10. PostgreSQLのSerializable Snapshot Isolation（SSI）

- **結論**: PostgreSQL 9.1（2011年9月リリース）でSerializable Snapshot Isolation（SSI）が導入された。Dan R. K. Portsらによる実装。Snapshot Isolationの異常（Write Skew）を検出し、危険なトランザクションをアボートすることで真のSerializableを実現
- **一次ソース**: VLDB Endowment; PostgreSQL Wiki
- **URL**: <https://dl.acm.org/doi/10.14778/2367502.2367523>, <https://wiki.postgresql.org/wiki/Serializable>
- **注意事項**: SSIはSnapshot Isolationとほぼ同等のパフォーマンスで真のSerializableを実現するが、一部のトランザクションがアボートされるリスクがある
- **記事での表現**: PostgreSQL 9.1（2011年）でSerializable Snapshot Isolation（SSI）が導入され、読み取りがブロックされることなく真のSerializableが実現された
