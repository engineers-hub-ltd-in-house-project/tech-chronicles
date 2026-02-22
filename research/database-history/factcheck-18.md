# ファクトチェック記録：第18回「CockroachDB, TiDB——OSSで挑むNewSQL」

調査日：2026-02-22

---

## 1. CockroachDBの創業と創業者の経歴

- **結論**: CockroachDBのオープンソースプロジェクトは2014年2月にSpencer KimballがGitHubで開始した。Cockroach Labs社は2015年5月13日に設立された。創業者はSpencer Kimball、Peter Mattis、Ben Darnellの3名で、全員元Google社員。KimballとMattisはGoogle File Systemチームのメンバー、DarnellはGoogle Readerチームのメンバーだった。3人はGoogle在籍中にBigtableやSpannerを使用しており、Spannerに着想を得てCockroachDBを開発した
- **一次ソース**: TechCrunch, "CockroachDB, the database that just won't die", 2021年; Wikipedia, "CockroachDB"; CockroachDB Wikipedia, "Spencer Kimball"
- **URL**: <https://techcrunch.com/2021/07/15/cockroachdb-ec1-origin/>, <https://en.wikipedia.org/wiki/CockroachDB>
- **注意事項**: ブループリントでは「2015年」とあるが、これはCockroach Labs社の設立年。オープンソースプロジェクト開始は2014年2月。Kimballは2014年1月に最初の設計文書を執筆。2012年にKimball、Mattis、Brian McGinnisがViewFinderを創業し、そこでDB課題に直面したことがCockroachDBの着想に繋がった
- **記事での表現**: 「Spencer Kimballは2014年1月に最初の設計文書を書き、2月にGitHubでオープンソースプロジェクトを開始した。2015年にCockroach Labs社を設立。KimballとMattisはGoogle File Systemチーム出身、DarnellはGoogle Readerチーム出身で、全員がBigtableやSpannerを使用した経験を持つ」

## 2. TiDBの創業と創業者の経歴

- **結論**: PingCAPは2015年4月に設立された。創業者はMax Liu（CEO）、Edward Huang（CTO）、Dylan Cui（Co-Founder）の3名。中国のインターネット企業でインフラエンジニアとして活動していた3名が、データベースの管理・スケーリング・保守の困難さに課題を感じて創業した。TiDBはMySQL互換の分散SQLデータベースで、Apache 2.0ライセンス
- **一次ソース**: PingCAP公式サイト "About Us"; TechCrunch, "TiDB developer PingCAP wants to expand in North America", 2018年; Wikipedia, "TiDB"
- **URL**: <https://www.pingcap.com/about-us/>, <https://techcrunch.com/2018/09/11/tidb-developer-pingcap-wants-to-expand-in-north-america-after-raising-50m-series-c/>, <https://en.wikipedia.org/wiki/TiDB>
- **注意事項**: ブループリントでは創業者名が記載されていない。Max LiuはCodis（オープンソースRedisクラスタソリューション）の共同開発者でもある。Edward HuangはGo/Rustのエキスパートで、TiDB/TiKVのアーキテクト
- **記事での表現**: 「PingCAPは2015年4月、Max Liu、Edward Huang、Dylan Cuiの3名が中国で設立した。中国のインターネット企業でインフラ基盤の開発に携わった3人は、既存のデータベースのスケーリングと運用の限界に直面し、TiDBの開発を決意した」

## 3. YugabyteDBの創業と創業者の経歴

- **結論**: Yugabyteは2016年2月にKannan Muthukkaruppan、Karthik Ranganathan、Mikhail Bautinの3名が設立した。3名は元Facebook社員で、Facebookで最初のウェブスケールデータベースの一つであるCassandraの構築・運用チームに所属していた。2017年11月に最初のパブリックベータをリリース。2019年7月にApache 2.0でオープンソース化
- **一次ソース**: Yugabyte公式サイト "About"; Wikipedia, "YugabyteDB"; Unite.ai, "Karthik Ranganathan Interview"
- **URL**: <https://www.yugabyte.com/about/>, <https://en.wikipedia.org/wiki/YugabyteDB>, <https://www.unite.ai/karthik-ranganathan-co-founder-and-co-ceo-of-yugabyte-interview-series/>
- **注意事項**: ブループリントでは「2016年」とあり一致。創業者の前職はFacebook（Meta）のCassandraチーム。Spannerではなく、FacebookでのCassandra経験がベース
- **記事での表現**: 「YugabyteDBは2016年、元Facebook社員のKannan Muthukkaruppan、Karthik Ranganathan、Mikhail Bautinが設立した。3人はFacebookでCassandraの構築・運用に携わった経験を持つ」

## 4. Raftアルゴリズムの論文と経緯

- **結論**: Raftは2014年にDiego OngaroとJohn Ousterhout（スタンフォード大学）が発表した分散合意アルゴリズム。論文「In Search of an Understandable Consensus Algorithm」はUSENIX ATC 2014でBest Paper Awardを受賞。Raftはマルチ-Paxosと同等の結果を生成し、Paxosと同等の効率を持つが、「理解しやすさ」を設計目標とした。リーダー選出、ログ複製、安全性を明確に分離している
- **一次ソース**: Ongaro, D. and Ousterhout, J., "In Search of an Understandable Consensus Algorithm", USENIX ATC 2014, pp.305-319
- **URL**: <https://www.usenix.org/conference/atc14/technical-sessions/presentation/ongaro>, <https://raft.github.io/raft.pdf>
- **注意事項**: OngaroはOusterhout教授の指導のもと2014年にスタンフォードで博士号を取得。Raft論文は博士論文の一部
- **記事での表現**: 「2014年、スタンフォード大学のDiego OngaroとJohn Ousterhoutが、Raftアルゴリズムを発表した。論文『In Search of an Understandable Consensus Algorithm』はUSENIX ATC 2014でBest Paper Awardを受賞。Paxosと同等の正確性と効率を持ちながら、『理解しやすさ』を最優先に設計された合意アルゴリズムだ」

## 5. CockroachDBのアーキテクチャ（Range、Raft、PostgreSQL互換）

- **結論**: CockroachDBはデータをキースペースの連続する範囲（Range）に分割する。各Rangeは独立したRaftグループとして複数のノードにレプリカを持つ。Rangeがデフォルトサイズに達すると自動的に分割（split）される。ノード追加・削除時には自動リバランスが行われる。SQLインターフェースはPostgreSQLワイヤープロトコル互換で、PostgreSQLネイティブクライアントドライバをそのまま利用可能。トランザクションの一貫性にはHybrid Logical Clock（HLC）を使用
- **一次ソース**: CockroachDB公式ドキュメント "Architecture Overview", "Replication Layer", "Distribution Layer"; CockroachDB設計文書 (design.md)
- **URL**: <https://www.cockroachlabs.com/docs/stable/architecture/overview>, <https://www.cockroachlabs.com/docs/stable/architecture/replication-layer>, <https://www.cockroachlabs.com/docs/stable/architecture/distribution-layer>
- **注意事項**: CockroachDBの「Range」はSpannerの「split」に相当する概念
- **記事での表現**: 「CockroachDBはデータをRange（範囲）と呼ばれる連続するキー範囲に分割する。各Rangeは独立したRaftグループを形成し、複数のノードに跨るレプリカを持つ。Rangeが規定サイズに達すると自動的にsplitされ、ノードの追加・削除時には自動リバランスが行われる」

## 6. CockroachDBのHybrid Logical Clock（HLC）

- **結論**: CockroachDBは原子時計の代わりにHybrid Logical Clock（HLC）を使用する。HLCは物理コンポーネント（ローカルの壁時計に近い値）と論理コンポーネント（物理コンポーネントが同じイベントを区別する）で構成される。SpannerがTrueTimeでLinearizabilityを提供するのに対し、CockroachDBはSerializabilityまでを保証する。因果関係のあるトランザクション間でタイムスタンプの逆転が理論上は起こりうるが、causality tokenにより回避可能
- **一次ソース**: Cockroach Labs Blog, "Living without atomic clocks: Where CockroachDB and Spanner diverge"; CockroachDB公式ドキュメント "Transaction Layer"
- **URL**: <https://www.cockroachlabs.com/blog/living-without-atomic-clocks/>, <https://www.cockroachlabs.com/docs/stable/architecture/transaction-layer>
- **注意事項**: Spannerの外部一貫性（External Consistency = Strict Serializability）とCockroachDBのSerializabilityは異なる保証レベル。この差異はNewSQLを語る上で重要な論点
- **記事での表現**: 「CockroachDBは原子時計やGPSを前提としない。代わりにHybrid Logical Clock（HLC）を採用し、物理時計と論理時計を組み合わせてトランザクションの順序付けを行う。Spannerが外部一貫性を保証するのに対し、CockroachDBはSerializabilityを保証する。両者の差は微妙だが、存在する」

## 7. TiDBのアーキテクチャ（TiKV、TiDB Server、PD、TiFlash）

- **結論**: TiDBはコンピュートとストレージを分離したアーキテクチャ。主要コンポーネントは3つ: (1) TiDB Server——ステートレスなSQL層、MySQL互換プロトコルを外部に公開、SQLの解析・最適化・分散実行計画の生成を担当。(2) TiKV——分散トランザクショナルKey-Valueストレージエンジン、データはRaftにより複数レプリカ（デフォルト3）で管理。Rust実装。(3) PD（Placement Driver）——クラスタのメタデータ管理とデータスケジューリングを担当。TiFlashはカラムナーストアで、Raft Learnerによりrow store（TiKV）からカラムナーレプリカを非同期で複製し、HTAPを実現
- **一次ソース**: PingCAP公式ドキュメント "TiDB Architecture"; VLDB 2020論文 "TiDB: A Raft-based HTAP Database"; TiKV GitHub
- **URL**: <https://docs.pingcap.com/tidb/stable/tidb-architecture/>, <https://www.vldb.org/pvldb/vol13/p3072-huang.pdf>, <https://github.com/tikv/tikv>
- **注意事項**: TiKVは2020年9月にCNCF Graduatedプロジェクトとなった。TiDB自体ではなくTiKVが卒業した点に注意
- **記事での表現**: 「TiDBのアーキテクチャはコンピュートとストレージを明確に分離する。SQL層のTiDB Server、分散KVストアのTiKV、メタデータとスケジューリングを担うPD、カラムナーストアのTiFlash。TiKVはRust実装で、Raftによる合意を行う。TiKVは2020年9月にCNCF Graduatedプロジェクトとなった」

## 8. CockroachDBのライセンス変遷

- **結論**: CockroachDBは当初Apache 2.0ライセンスで公開。2019年にBusiness Source License（BSL）に変更。2024年8月にさらにライセンスを変更し、CockroachDB Coreを廃止して単一のEnterprise版に統合。年間売上1,000万ドル以上の企業にはCPU数ベースの有料ライセンスが必要、それ以下のスタートアップは無料で利用可能。2024年11月のv24.3から新ライセンス体系が適用
- **一次ソース**: The Register, "CockroachDB scuttles away from open source Core offering", 2024年8月; InfoQ, "Concerns Rise in Open-Source Community as CockroachDB Ends Core Free Edition", 2024年9月
- **URL**: <https://www.theregister.com/2024/08/19/cockroachdb_abandons_open_core/>, <https://www.infoq.com/news/2024/09/cockroachdb-license-concerns/>
- **注意事項**: ライセンス変更はオープンソースコミュニティで論争を引き起こした。TiDBとYugabyteDBがApache 2.0を維持している点との対比は記事の論点になりうる
- **記事での表現**: 「CockroachDBは当初Apache 2.0で公開されたが、2019年にBSLへ変更、2024年にはCoreエディションを廃止してEnterprise版に一本化した。OSSから商用ライセンスへの段階的な移行は、オープンソースデータベースのビジネスモデルの難しさを示している」

## 9. CockroachDB v1.0リリースとTiDB v1.0 GAリリース

- **結論**: CockroachDB v1.0は2017年5月にリリースされ、最初のproduction-readyバージョンとなった。TiDB 1.0 GAは2017年10月16日にリリースされた。両者とも2014-2015年に開発を開始し、2017年にそれぞれ初の安定版をリリースした
- **一次ソース**: Cockroach Labs Blog, "CockroachDB 1.0 is production-ready"; PingCAP TiDB Release Timeline
- **URL**: <https://www.cockroachlabs.com/blog/cockroachdb-1-0-release/>, <https://docs.pingcap.com/tidb/stable/release-timeline/>
- **注意事項**: 2017年は両プロジェクトにとって重要な節目の年
- **記事での表現**: 「2017年、CockroachDBとTiDBはそれぞれv1.0をリリースした。CockroachDB v1.0は5月、TiDB 1.0 GAは10月。Spannerの論文発表から5年、OSSのNewSQLが実用段階に達した」

## 10. TiKVのCNCF Graduated

- **結論**: TiKVは2020年9月にCNCF（Cloud Native Computing Foundation）のGraduatedプロジェクトとなった。TiKVはRust実装の分散トランザクショナルKey-Valueデータベースで、元々TiDBを補完するために作成された
- **一次ソース**: TiKV GitHub; CNCF
- **URL**: <https://github.com/tikv/tikv>
- **注意事項**: CNCF GraduatedはKubernetesやPrometheusと同列の成熟度認定。TiDB自体ではなくストレージ層のTiKVがGraduated
- **記事での表現**: 「TiKVは2020年9月にCNCF Graduatedプロジェクトとなった。Kubernetesと同列の成熟度認定を受けたことは、分散ストレージエンジンとしてのTiKVの信頼性を裏付けている」

## 11. NewSQLの共通設計目標とトレードオフ

- **結論**: CockroachDB（PostgreSQL互換）、TiDB（MySQL互換）、YugabyteDB（PostgreSQL互換 + Cassandra互換）はいずれも「SQLインターフェース + 分散スケーラビリティ + 強一貫性」を目指す。共通のトレードオフとして、単一ノードRDBに比べて書き込みレイテンシが大きい（Raft合意に複数ノード間通信が必要）、運用の複雑さ、コストがある。YugabyteDBのPostgreSQL互換スコアは85.08%、CockroachDBは53.66%（PostgreSQL Compatibility Index）
- **一次ソース**: sanj.dev "Distributed SQL 2025: CockroachDB vs TiDB vs YugabyteDB"; YugabyteDB公式サイト
- **URL**: <https://sanj.dev/post/distributed-sql-databases-comparison>, <https://www.yugabyte.com/yugabytedb-vs-cockroachdb/>
- **注意事項**: 互換性スコアは測定方法やバージョンにより変動する。CockroachDBの互換性は年々向上している
- **記事での表現**: 「NewSQLの各実装は異なるRDB互換性戦略を取る。CockroachDBとYugabyteDBはPostgreSQL互換、TiDBはMySQL互換。互換性の度合いは異なるが、既存のORMやツールチェーンをそのまま使える利便性を追求している点は共通する」
