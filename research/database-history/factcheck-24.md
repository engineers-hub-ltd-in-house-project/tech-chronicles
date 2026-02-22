# ファクトチェック記録：第24回「データベースの地層を読む——あなたは何を選ぶか」

## 1. DB-Engines Ranking 2026年2月時点のトップ5

- **結論**: 2026年2月時点でOracle（スコア1204）、MySQL（868）、Microsoft SQL Server（708）、PostgreSQL（672）、MongoDB（379）の順。PostgreSQLは2025年を通じて最も成長したOSSリレーショナルDB
- **一次ソース**: DB-Engines, "DB-Engines Ranking", 2026年2月更新
- **URL**: <https://db-engines.com/en/ranking>
- **注意事項**: DB-Engines RankingはWebサイトのメンション、検索トレンド、求人情報等の複合指標。実利用シェアとは異なる
- **記事での表現**: DB-Engines Ranking（2026年2月）では、Oracle、MySQL、SQL Server、PostgreSQLが上位を占める

## 2. Stack Overflow Developer Survey 2024-2025のデータベース人気

- **結論**: 2024年調査でPostgreSQLが49%で2年連続最人気。2025年調査ではPostgreSQLが55.6%に達し、年間約7ポイントの増加は過去最大の伸び。「最も賞賛される」「最も望まれる」の両部門でも3年連続1位
- **一次ソース**: Stack Overflow, "2024 Developer Survey" / "2025 Developer Survey"
- **URL**: <https://survey.stackoverflow.co/2024/technology> / <https://survey.stackoverflow.co/2025/technology>
- **注意事項**: 回答者はStack Overflowユーザー層に偏りがある
- **記事での表現**: Stack Overflow Developer Survey 2025では、PostgreSQLがプロフェッショナル開発者の55.6%に利用され、3年連続で「最も賞賛されるデータベース」の座を維持している

## 3. Coddの1970年論文

- **結論**: Edgar F. Codd, "A Relational Model of Data for Large Shared Data Banks", Communications of the ACM, Vol.13, No.6, pp.377-387, 1970年6月
- **一次ソース**: ACM Digital Library
- **URL**: <https://dl.acm.org/doi/10.1145/362384.362685>
- **注意事項**: 初稿はIBM Research Report RJ599として1969年8月に発表されている
- **記事での表現**: 1970年、Edgar F. CoddがCommunications of the ACM（Vol.13, No.6, pp.377-387）に発表した論文

## 4. CAP定理（Eric Brewer、2000年）

- **結論**: Eric Brewerが2000年7月19日、PODC 2000（Portland, Oregon）の基調講演「Towards Robust Distributed Systems」でCAP予想を提唱。2002年にSeth GilbertとNancy Lynchが証明
- **一次ソース**: Brewer, E., "Towards Robust Distributed Systems", PODC 2000 Keynote
- **URL**: <https://people.eecs.berkeley.edu/~brewer/cs262b-2004/PODC-keynote.pdf>
- **注意事項**: 当初は「予想（conjecture）」であり、定理として証明されたのは2002年
- **記事での表現**: 2000年、Eric BrewerがPODC基調講演でCAP予想を提唱し、2002年にGilbertとLynchが証明した

## 5. Google Spanner論文（2012年）

- **結論**: "Spanner: Google's Globally-Distributed Database", OSDI 2012で発表。TrueTime APIが核心技術。時刻不確実性を10ms未満に抑えるためにGPSと原子時計を使用
- **一次ソース**: Google Research
- **URL**: <https://research.google/pubs/spanner-googles-globally-distributed-database-2/>
- **注意事項**: 2017年にGoogle Cloud Spannerとして商用化
- **記事での表現**: 2012年、Google Spanner論文（OSDI 2012）がTrueTime APIによるグローバル分散と強一貫性の両立を示した

## 6. Amazon Dynamo論文（2007年）

- **結論**: "Dynamo: Amazon's Highly Available Key-value Store", SOSP 2007（Stevenson, WA、10月14-17日）で発表。Giuseppe DeCandia他9名の著者。結果整合性モデルの実用化を示した
- **一次ソース**: ACM SIGOPS Operating Systems Review, Vol.41, No.6, pp.205-220, 2007
- **URL**: <https://dl.acm.org/doi/10.1145/1323293.1294281>
- **記事での表現**: 2007年、Amazon Dynamo論文（SOSP 2007）が結果整合性と高可用性のトレードオフを実用化した

## 7. NewSQL用語の起源（2011年）

- **結論**: 2011年、451 ResearchのアナリストMatthew Aslettが「NewSQL」という用語を造語した。新しいスケーラブル/高性能SQLデータベースベンダーの総称
- **一次ソース**: Aslett, M., "What we talk about when we talk about NewSQL", 451 Group Blog, 2011年4月6日
- **URL**: <https://blogs.the451group.com/information_management/2011/04/06/what-we-talk-about-when-we-talk-about-newsql/>
- **記事での表現**: 2011年、451 ResearchのMatthew Aslettが「NewSQL」という用語を造語した

## 8. CockroachDBのライセンス変更（2024年）

- **結論**: CockroachDBは2024年にEnterprise Licenseに変更し、OSSのCore Free Editionを終了。コミュニティで批判を受けた。対照的にTiDBはApache License 2.0を維持
- **一次ソース**: InfoQ, "Concerns Rise in Open-Source Community as CockroachDB Ends Core Free Edition", 2024年9月
- **URL**: <https://www.infoq.com/news/2024/09/cockroachdb-license-concerns/>
- **記事での表現**: 2024年、CockroachDBがEnterprise Licenseに移行し、OSS版を終了した

## 9. Redisのライセンス変更とValkey fork（2024-2025年）

- **結論**: 2024年3月、Redisが3条項BSDからSSPLv1/RSALv2のデュアルライセンスに変更。Linux FoundationがValkey forkを発表（AWS、Google Cloud等が支援）。2025年、Redis 8.0でAGPLv3を追加し「オープンソース復帰」を宣言
- **一次ソース**: The Register, "Redis 'returns' to open source with AGPL license", 2025年5月
- **URL**: <https://www.theregister.com/2025/05/01/redis_returns_to_open_source/>
- **記事での表現**: 2024年のRedisライセンス変更はValkey forkを生み、OSSデータベースのライセンス問題を浮き彫りにした

## 10. pgvector（PostgreSQL拡張）の成長

- **結論**: pgvectorはPostgreSQL向けのベクトル類似検索拡張。HNSWとIVFFlatインデックスをサポート。2025年、Aurora PostgreSQLでpgvector 0.8.0がサポートされ、クエリ性能が最大9倍向上
- **一次ソース**: GitHub pgvector/pgvector
- **URL**: <https://github.com/pgvector/pgvector>
- **記事での表現**: pgvectorはPostgreSQLをベクトルデータベースとしても使えるようにし、専用ベクトルDBへの依存を回避する選択肢を提供している

## 11. DuckDBの成長

- **結論**: DuckDBは2018年にMark RaasveldtとHannes Mühleisen（CWI、オランダ）が開発開始。2019年に初リリース。2024年6月にv1.0.0リリース。インプロセスOLAP DB。MITライセンス。DuckDB Foundationが長期維持を保証
- **一次ソース**: DuckDB公式サイト / Wikipedia
- **URL**: <https://duckdb.org/> / <https://en.wikipedia.org/wiki/DuckDB>
- **記事での表現**: 2019年に登場したDuckDBは「分析のためのSQLite」と呼ばれ、インプロセスで動作する列指向OLAPデータベースとして急速に普及している

## 12. Martin Kleppmann『Designing Data-Intensive Applications』

- **結論**: Martin Kleppmann著、O'Reilly Media、2017年3月出版。分散データシステムの設計原則を体系化した書籍
- **一次ソース**: O'Reilly Media
- **URL**: <https://www.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/>
- **記事での表現**: Martin Kleppmannの『Designing Data-Intensive Applications』（O'Reilly, 2017年）

## 13. Neonの買収（Databricks、2025年）

- **結論**: 2025年5月14日、DatabricksがNeon（サーバレスPostgreSQL）の買収を発表。買収後、使用量ベースの新料金体系を導入
- **一次ソース**: 各種報道
- **URL**: 検索結果より確認
- **記事での表現**: 2025年、DatabricksがサーバレスPostgreSQLプラットフォームNeonを買収した
