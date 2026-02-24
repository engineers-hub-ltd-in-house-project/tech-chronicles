# ファクトチェック記録：第14回「Google App Engine——Googleスケールの約束と制約」

## 1. Google App Engine発表日・イベント

- **結論**: Google App Engineは2008年4月7日、Campfire Oneイベントでプレビュー版として発表された。初期は最初の10,000名の開発者に限定され、Pythonのみサポート。無料枠として500MBストレージ、月間約500万ページビュー相当のCPU・帯域幅が提供された
- **一次ソース**: Google Developers Blog, "Google App Engine at Campfire One", April 2008; Google Press Release, "Previewing Google App Engine: Run Your Apps on Google's Infrastructure", April 7, 2008
- **URL**: <https://developers.googleblog.com/en/google-app-engine-at-campfire-one/>; <https://cloudplatform.googleblog.com/2008/04/introducing-google-app-engine-our-new.html>
- **注意事項**: プレビュー版発表が2008年4月、正式GA（General Availability）は2011年9月
- **記事での表現**: 「2008年4月7日、GoogleはCampfire Oneイベントで、Google App Engineのプレビュー版を発表した」

## 2. Python専用からのランタイム拡張タイムライン

- **結論**: 初期はPython（2.5）のみ。Java対応は2009年4月7日（最初の10,000開発者限定でアーリーアクセス）。Go対応はGoogle I/O 2011で実験的サポートとして発表（2011年5月）。PHP対応は2013年5月にLimited Preview
- **一次ソース**: Google Press Release, "Google App Engine Announces New Features, Early Look at Java Language Support", April 7, 2009; The Go Blog, "Go and Google App Engine", May 2011; The Register, "Google launches Go runtime for App Engine", July 25, 2011
- **URL**: <https://go.dev/blog/appengine>; <https://www.theregister.com/2011/07/25/google_app_engine_go_runtime_released/>
- **注意事項**: Go対応発表はGoogle I/O 2011（2011年5月）、実験的ランタイムとしてリリースはその後
- **記事での表現**: 「2009年4月にJava対応、2011年にGoの実験的サポート、2013年にPHP対応と、段階的にランタイムが拡張された」

## 3. GAEのサンドボックス制約

- **結論**: App Engine Standard Environmentには厳格なサンドボックス制約があった。(1) ファイルシステムへの書き込み不可、(2) Webリクエストのタイムアウト60秒、(3) 使用可能なライブラリの制限（サンドボックス環境でブロックされるAPIあり）、(4) リクエストサイズ上限32MB
- **一次ソース**: Google Cloud Documentation, "How Requests are Handled"; O'Reilly, "Programming Google App Engine with Python"
- **URL**: <https://docs.cloud.google.com/appengine/docs/legacy/standard/php/how-requests-are-handled>; <https://docs.cloud.google.com/appengine/docs/standard/quotas>
- **注意事項**: 第二世代ランタイム（2018年〜）ではgVisorベースのサンドボックスに移行し、多くの制約が緩和された
- **記事での表現**: 「ファイルシステムへの書き込みは禁止され、Webリクエストには60秒のタイムアウトが課された」

## 4. Datastore（Bigtableベース）の設計

- **結論**: App EngineのDatastoreはGoogle Bigtable上に構築されたNoSQLデータストア。SQLクエリ、JOIN操作、マルチロウトランザクションは非サポート。Entity Groupの更新は1秒に1回以下が推奨。ホットキー問題あり
- **一次ソース**: Google Cloud Documentation, "Datastore Overview"; Google Cloud Documentation, "Cloud Datastore best practices"
- **URL**: <https://docs.cloud.google.com/appengine/docs/legacy/standard/go111/datastore>; <https://docs.cloud.google.com/datastore/docs/cloud-datastore-best-practices>
- **注意事項**: DatastoreはのちにCloud Datastoreとして独立サービス化、さらにFirestore（Datastoreモード）に進化
- **記事での表現**: 「DatastoreはBigtable上に構築されたNoSQLデータストアであり、RDBMSの正規化やJOIN操作を捨て、水平スケーラビリティを選んだ設計だった」

## 5. App Engine Flexible Environment

- **結論**: App Engine Flexible Environment（旧称Managed VMs）はDockerコンテナベースでアプリケーションを実行する。2016年頃からDockerビルドがクラウド側で自動実行されるように改善。GA（一般提供）はCloud Next 2017（2017年3月）で発表
- **一次ソース**: Google Cloud Documentation, "App Engine flexible environment"; Google Cloud Blog
- **URL**: <https://cloud.google.com/appengine/docs/flexible>; <https://cloud.google.com/appengine/docs/flexible-environment>
- **注意事項**: Flexible Envは「Standard Envの制約を緩和」するために設計されたが、起動時間はStandardより遅い
- **記事での表現**: 「2017年にGA化したFlexible Environmentは、Dockerコンテナベースの実行環境で、Standard Environmentの厳格な制約を大幅に緩和した」

## 6. Cloud Run（2019年）——GAEの精神的後継

- **結論**: Cloud Runは2019年4月にGoogle Cloud Next 2019でベータ版として発表、2019年11月14日にGA。Knative Serving APIを実装したサーバーレスコンテナプラットフォーム。ステートレスHTTPコンテナをゼロからスケール可能
- **一次ソース**: Google Cloud Blog, "Cloud Run: Bringing serverless to containers", April 2019; Google Cloud Blog, "Cloud Run is GA", November 2019
- **URL**: <https://cloud.google.com/blog/products/serverless/cloud-run-bringing-serverless-to-containers>; <https://cloud.google.com/blog/products/serverless/knative-based-cloud-run-services-are-ga>
- **注意事項**: Cloud RunはApp Engineとは独立したサービスだが、「サンドボックス内でコンテナを実行する」という設計思想にGAEからの系譜がある
- **記事での表現**: 「2019年にGA化したCloud Runは、GAEの『制約による設計』の精神を引き継ぎつつ、コンテナの標準化によってポータビリティを実現した」

## 7. AWS Elastic Beanstalk（2011年）

- **結論**: AWSは2011年にElastic Beanstalkを発表。既にIaaSで確立されたAWSが後追いでPaaSを提供した形。GAEより制約が少なく、開発者がインフラのカスタマイズをしやすい設計
- **一次ソース**: TechTarget, "PaaS showdown: AWS Elastic Beanstalk vs. Google App Engine"
- **URL**: <https://www.techtarget.com/searchcloudcomputing/tip/PaaS-showdown-AWS-Elastic-Beanstalk-vs-Google-App-Engine>
- **注意事項**: Elastic BeanstalkはEC2上に構築されたPaaSレイヤーであり、GAEのように独自ランタイムを持つわけではない
- **記事での表現**: 「AWSのElastic Beanstalk（2011年）はEC2上にPaaSレイヤーを構築した。GAEとは対照的に、開発者にインフラのカスタマイズ余地を残す設計だった」

## 8. GAEのオートスケーリング

- **結論**: App Engineは3種類のスケーリングをサポート: (1) 自動スケーリング（リクエストレート、レイテンシ等に基づく）、(2) 基本スケーリング（リクエスト到着時にインスタンス作成、アイドル時にシャットダウン）、(3) 手動スケーリング。自動スケーリングではゼロインスタンスまでスケールダウン可能
- **一次ソース**: Google Cloud Documentation, "How instances are managed"
- **URL**: <https://cloud.google.com/appengine/docs/standard/how-instances-are-managed>
- **注意事項**: ゼロへのスケールダウンはコスト効率を高めるが、コールドスタートレイテンシの原因となる
- **記事での表現**: 「GAEの自動スケーリングはトラフィックがゼロならインスタンスもゼロになる。この『ゼロへのスケールダウン』は、後のサーバーレスの核心概念を先取りしていた」

## 9. 第二世代ランタイムとgVisor（2018年）

- **結論**: 2018年、GoogleはApp Engine Standard Environmentの第二世代ランタイムを導入。gVisor（Goで書かれたユーザースペースカーネル）によるコンテナサンドボックスを採用。これにより従来のサンドボックス制約の多くが撤廃され、未修正のPython 3.7やNode.jsランタイムが利用可能に
- **一次ソース**: Google Cloud Blog, "Introducing App Engine Second Generation runtimes and Python 3.7", 2018; InfoQ, "Google App Engine to Support Node.js 8.x Using the Recently Open Source gVisor Sandbox"
- **URL**: <https://cloud.google.com/blog/products/gcp/introducing-app-engine-second-generation-runtimes-and-python-3-7>; <https://www.infoq.com/news/2018/05/gae-node/>
- **注意事項**: gVisorは2018年にオープンソース化。App Engine以外にもCloud RunやGKE Sandboxで使用される
- **記事での表現**: 「2018年の第二世代ランタイムは、gVisorというGoで書かれたユーザースペースカーネルをサンドボックスに採用した。これにより、従来の厳格な制約の多くが解消された」

## 10. GAEの無料枠とプレビュー時の初期仕様

- **結論**: プレビュー版（2008年）では500MBストレージ、200百万CPUサイクル/日、10GB帯域幅の無料枠。2009年から有料プランが利用可能に。2011年9月に新料金体系へ移行（大幅値上げとの批判あり）
- **一次ソース**: Google Press Release; Slashdot, "New Prices For Google Apps Engine", September 2011
- **URL**: <https://tech.slashdot.org/story/11/09/01/2120247/new-prices-for-google-apps-engine>; <https://blogoscoped.com/archive/2008-05-28-n22.html>
- **注意事項**: 初期の無料枠は非常に寛大で、多くの小規模アプリが無料で運用できた。これがGAE普及の大きな要因
- **記事での表現**: 「プレビュー版の無料枠は月間約500万ページビュー相当——小規模なWebアプリケーションを無料で運用できる、当時としては破格の条件だった」

---

**品質ゲート**: 10項目中10項目が「検証済み」。基準（最低6項目）を満たしている。
