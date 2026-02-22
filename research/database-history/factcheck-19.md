# ファクトチェック記録：第19回「サーバレスDB——運用からの解放」

## 1. Amazon RDS のリリース日

- **結論**: Amazon RDS は2009年10月26日にリリースされた。初期はMySQL 5.1のみサポート
- **一次ソース**: AWS Blog, "Introducing Amazon RDS – The Amazon Relational Database Service", 2009
- **URL**: <https://aws.amazon.com/blogs/aws/introducing-rds-the-amazon-relational-database-service/>
- **注意事項**: ベータサービスとしてのローンチ。PostgreSQLサポートは2013年11月に追加
- **記事での表現**: 「Amazon RDS（2009年10月）」

## 2. Amazon Aurora のリリース日とアーキテクチャ

- **結論**: Amazon Aurora は2014年11月12日の re:Invent 2014でプレビュー発表、2015年7月にGA。コンピュートとストレージを分離し、redo logのみをストレージに送信する「log is the database」設計
- **一次ソース**: Amazon Science, "A decade of database innovation: The Amazon Aurora story"; Verbitski et al., "Amazon Aurora: Design Considerations for High Throughput Cloud-Native Relational Databases", SIGMOD 2017
- **URL**: <https://www.amazon.science/blog/a-decade-of-database-innovation-the-amazon-aurora-story>, <https://www.amazon.science/publications/amazon-aurora-design-considerations-for-high-throughput-cloud-native-relational-databases>
- **注意事項**: ブループリントでは「2014年」としているが、プレビュー発表は2014年11月、GAは2015年7月。ストレージは6ノードに書き込み、4ノードのクォーラムでコミット確認
- **記事での表現**: 「Amazon Aurora（2014年11月のre:Invent 2014で発表、2015年7月GA）」

## 3. Aurora Serverless のリリース日

- **結論**: Aurora Serverless v1は2018年8月にGA。Aurora Serverless v2は2022年4月1日にGA
- **一次ソース**: AWS Blog, "Amazon Aurora Serverless v2 is Generally Available: Instant Scaling for Demanding Workloads", 2022; BusinessWire, "AWS Announces General Availability of Amazon Aurora Serverless v2"
- **URL**: <https://aws.amazon.com/blogs/aws/amazon-aurora-serverless-v2-is-generally-available-instant-scaling-for-demanding-workloads/>
- **注意事項**: v1は2024年にAWSが廃止を発表。v2はACU（Aurora Capacity Unit）単位でスケール、最小0.5 ACU、最大128 ACU。v2ではスケーリングが接続を切断せずにミリ秒単位で実行される
- **記事での表現**: 「Aurora Serverless（v1: 2018年GA、v2: 2022年4月GA）」

## 4. PlanetScale のリリースと背景

- **結論**: PlanetScale社は2018年にJiten VaidyaとSugu Sougoumaraneが設立。両名はYouTubeでVitessを開発した元エンジニア。サーバレスDBプラットフォームは2021年5月にベータ、2021年11月にGA
- **一次ソース**: TechCrunch, "They scaled YouTube -- now they'll shard everyone with PlanetScale", 2018; BusinessWire, "PlanetScale Announces General Availability", 2021
- **URL**: <https://techcrunch.com/2018/12/13/planetscale/>, <https://www.businesswire.com/news/home/20211116005663/en/>
- **注意事項**: ブループリントでは「2021年」としているが、会社設立は2018年、サーバレスプラットフォームのGAが2021年11月。Series C $50M調達（2021年11月）。Sam Lambert（元GitHub）が後にCEO就任。2024年3月にHobby（無料）プラン廃止、全プラン有料化
- **記事での表現**: 「PlanetScale（2018年設立、Vitess開発者が創業。サーバレスプラットフォームは2021年11月GA）」

## 5. Neon のリリースと創業者

- **結論**: Neon は2021年にNikita Shamgunov、Heikki Linnakangas、Stas Kelvichが設立。2022年にパブリックローンチ。Shamgunovは元SingleStore共同創業者/CEO、LinnakanasはPostgreSQLコミッター歴20年超、KelvichはPostgresハッカー
- **一次ソース**: Neon About Us; Caproasia, "$62 Billion Data & AI Company Databricks to Buy Serverless PostgreSQL Platform Neon for $1 Billion"
- **URL**: <https://neon.com/about-us>, <https://www.caproasia.com/2025/05/15/62-billion-data-ai-company-databricks-to-buy-serverless-postgresql-platform-neon-for-1-billion-neon-founded-in-2021-by-nikita-shamgunov-heikki-linnakangas-stas-kelvich/>
- **注意事項**: 2025年5月にDatabricksが約10億ドルでNeonを買収。アーキテクチャはCompute Node / Safekeeper / Pageserverの3層構造。WALをSafekeeperがPaxosで冗長化。Scale to Zero機能（デフォルト5分非アクティブで停止）
- **記事での表現**: 「Neon（2021年設立、2022年パブリックローンチ。PostgreSQL互換サーバレス）」

## 6. Turso のリリースと libSQL

- **結論**: ChiselStrike社が2022年にSQLiteをフォークしてlibSQLを作成。2023年初頭にChiselStrike Tursoとしてサーバレスエッジデータベースを発表。Glauber Costaが創業者/CEO
- **一次ソース**: Turso Blog, "Announcing ChiselStrike Turso"; Medium/ChiselStrike Blog, "We're bringing libSQL into the Turso family"
- **URL**: <https://turso.tech/blog/announcing-chiselstrike-turso-164472456b29>, <https://medium.com/chiselstrike/were-bringing-libsql-into-the-turso-family-8cc1a653448e>
- **注意事項**: libSQLはSQLiteの「Open Source but not Open Contribution」問題を解決するためのフォーク。Embedded Replicas機能でVPS上のアプリ内にレプリカを配置可能。2024年12月にRustでSQLiteを再実装したバージョンを発表
- **記事での表現**: 「Turso（2023年発表、libSQL/SQLiteベースのエッジDB）」

## 7. Cloudflare D1 のリリース

- **結論**: Cloudflare D1 は2022年5月11日に発表。SQLiteベースのエッジサーバレスDB。Workers向け
- **一次ソース**: Cloudflare Blog, "Announcing D1: our first SQL database", 2022
- **URL**: <https://blog.cloudflare.com/introducing-d1/>
- **注意事項**: ベータアクセスは2022年6月から。水平スケールは10GBデータベースを複数に分割する設計。Cloudflareのエッジインフラでグローバルレプリケーション
- **記事での表現**: 「Cloudflare D1（2022年5月発表、SQLiteベースのエッジDB）」

## 8. Neon のアーキテクチャ（Pageserver / Safekeeper / Compute）

- **結論**: Neonは3層アーキテクチャ。Compute Node（ステートレスなPostgreSQLインスタンス、ローカルディスクに書き込まない）、Safekeeper（WALの冗長保存、Paxos合意）、Pageserver（WALからページバージョンをマテリアライズ、layer fileに変換）
- **一次ソース**: Neon Docs, "Architecture Overview"; Neon Blog, "Architecture decisions in Neon"
- **URL**: <https://neon.com/docs/introduction/architecture-overview>, <https://neon.com/blog/architecture-decisions-in-neon>
- **注意事項**: Computeはローカルメモリ → ローカルNVMeキャッシュ → Pageserverの順でページを読む。SafekeeperのクォーラムでWALをコミット
- **記事での表現**: アーキテクチャ図とともに解説

## 9. PlanetScale のオンラインスキーマ変更

- **結論**: PlanetScaleはVitessのオンラインスキーマ変更機能を利用。ゴーストテーブルを作成し、元テーブルのスキーマをコピー後にALTER TABLEを適用、データを同期し、カットオーバーでテーブルを交換。本番トラフィックに影響を与えない
- **一次ソース**: PlanetScale Docs, "Non-blocking schema changes"; PlanetScale Blog, "How PlanetScale makes schema changes"
- **URL**: <https://planetscale.com/docs/vitess/schema-changes>, <https://planetscale.com/blog/how-planetscale-makes-schema-changes>
- **注意事項**: Safe migrationsを有効にする必要がある。トラフィックスパイク時はマイグレーション処理を自動スケールダウン。Revert機能でロールバック可能
- **記事での表現**: PlanetScaleのオンラインスキーマ変更として解説

## 10. Aurora のログベースストレージ

- **結論**: AuroraはRedo Logのみをストレージ層に送信（「log is the database」設計）。従来のデータベースのようにデータページ全体を書かない。6ストレージノードに書き込み、4/6のクォーラムでコミット確認。チェックポイントとリカバリはストレージフリートにオフロード
- **一次ソース**: Verbitski et al., "Amazon Aurora: Design Considerations for High Throughput Cloud-Native Relational Databases", SIGMOD 2017; AWS re:Invent 2019 "Amazon Aurora storage demystified"
- **URL**: <https://pages.cs.wisc.edu/~yxy/cs764-f20/papers/aurora-sigmod-17.pdf>, <https://d1.awsstatic.com/events/reinvent/2019/REPEAT_Amazon_Aurora_storage_demystified_How_it_all_works_DAT309-R.pdf>
- **注意事項**: ネットワークI/Oが大幅に削減されることがAuroraの性能上の核心。クラッシュリカバリはほぼ瞬時（従来のWALリプレイ不要）
- **記事での表現**: Auroraのアーキテクチャ図とともに「ログこそがデータベース」として解説

## 11. コネクションプーリング（PgBouncer / Prisma Accelerate）

- **結論**: PgBouncerはPostgreSQLのコネクションプーラーで、transaction poolingモードでサーバレス環境のコネクション問題を解決。Prisma AccelerateはPrismaのマネージドコネクションプーリング+グローバルキャッシュサービス（Prisma Data Proxyの後継、Data Proxyは2023年末に廃止）
- **一次ソース**: Neon Docs, "Connection pooling"; Prisma Blog, "Accelerate in Preview"
- **URL**: <https://neon.com/docs/connect/connection-pooling>, <https://www.prisma.io/blog/accelerate-preview-release-ab229e69ed2>
- **注意事項**: NeonはビルトインでPgBouncerを提供。サーバレス環境ではLambda等のコールドスタート時にコネクション枯渇が問題になる
- **記事での表現**: サーバレスDB特有の課題としてコネクションプーリングを解説

## 12. Neon のブランチング機能

- **結論**: NeonはCopy-on-Writeでデータベースブランチを作成。gitのブランチと同様に、ポインタの移動でデータの完全コピーを提供。7日間のWAL履歴を保持し、ポイントインタイムリストアが可能
- **一次ソース**: The New Stack, "Neon: Branching in Serverless PostgreSQL"; Neon Docs
- **URL**: <https://thenewstack.io/neon-branching-in-serverless-postgresql/>, <https://neon.com/docs/introduction>
- **注意事項**: ブランチはストレージコストがほぼゼロ（差分のみ保存）。開発/テスト/本番のワークフローに活用可能
- **記事での表現**: Neonのブランチ機能をgitアナロジーで解説
