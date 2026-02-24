# ファクトチェック記録：第18回「サーバーレス（Lambda）——サーバが『見えない』世界」

## 1. AWS Lambda の発表

- **結論**: AWS Lambdaは2014年11月13日、AWS re:Invent 2014のWerner Vogels（AWS CTO）のDay 2キーノートで発表された。初期対応言語はNode.jsのみ。GA（一般提供）は2015年。
- **一次ソース**: Amazon Web Services, "Amazon Web Services Announces AWS Lambda", November 2014; Werner Vogels, "AWS Lambda turns 10: A rare look at the doc that started it", All Things Distributed, November 2024
- **URL**: <https://press.aboutamazon.com/2014/11/amazon-web-services-announces-aws-lambda>, <https://www.allthingsdistributed.com/2024/11/aws-lambda-turns-10-a-rare-look-at-the-doc-that-started-it.html>
- **注意事項**: AWSは「Node.jsのみでローンチするという難しい決断を下した」と後に振り返っている。re:Invent 2014時点ではプレビューとしての発表
- **記事での表現**: 2014年11月13日、AWS re:Invent 2014のWerner Vogelsキーノートにおいて、AWS Lambdaが発表された。対応言語はNode.jsのみという最小限の構成だった

## 2. Google Cloud Functions のローンチ

- **結論**: Google Cloud Functionsは2016年2月にアルファ版として発表、2017年3月にベータ版へ移行、2018年7月24日にGA（一般提供）となった
- **一次ソース**: TechCrunch, "Google's Cloud Functions serverless platform is now generally available", July 24, 2018; Google Cloud Functions Release Notes
- **URL**: <https://techcrunch.com/2018/07/24/googles-cloud-functions-serverless-platform-is-now-generally-available/>, <https://cloud.google.com/functions/docs/release-notes>
- **注意事項**: アルファからGAまで約2年半を要した。現在はCloud Run functionsに名称変更
- **記事での表現**: Google Cloud Functionsは2016年2月のアルファ版発表を経て、2017年3月にベータ版、2018年7月に正式版（GA）へ到達した

## 3. Azure Functions のローンチ

- **結論**: Azure Functionsは2016年3月にプレビュー版として公開、2016年11月にGA（一般提供）となった
- **一次ソース**: Microsoft Azure Blog, "Announcing general availability of Azure Functions", November 2016; InfoQ, "Azure Functions Reach General Availability", December 2016
- **URL**: <https://azure.microsoft.com/en-us/blog/announcing-general-availability-of-azure-functions/>, <https://www.infoq.com/news/2016/12/Azure-Functions-GA/>
- **注意事項**: プレビュー期間中に900件以上のGitHub issueが処理された
- **記事での表現**: Azure Functionsは2016年3月にプレビュー版として登場し、同年11月にGAとなった

## 4. Zimki——サーバーレスPaaSの先駆者

- **結論**: ZimkiはSimon Wardleyが率いるFotango社（Canon Europe子会社、ロンドン拠点）が開発。2006年3月にベータローンチ、EuroOSCONで公開。開発者がブラウザ上のIDEでコードを書き、関数単位で課金される「ユーティリティコンピューティング」モデル。Canon Europeがクラウドの将来性を信じず、オープンソース化も拒否。Wardleyは2007年7月のOSCONでステージ上から辞任を表明。2007年12月24日にサービス終了、全データ削除
- **一次ソース**: The Register, "Fotango to smother Zimki on Christmas Eve", September 25, 2007; Simon Wardley (blog.gardeviance.org), "VMForce, Zimki and the cloud", May 2010
- **URL**: <https://www.theregister.com/2007/09/25/zimki_fotango_shut/>, <https://blog.gardeviance.org/2010/05/vmforce-zimki-and-cloud.html>
- **注意事項**: 「サーバーレス」という用語自体は当時存在しなかったが、概念的にはサーバーレスの先駆けと位置づけられる
- **記事での表現**: 2006年、ロンドンのFotango社（Canon Europe子会社）がZimkiを公開した。関数単位で課金されるユーティリティコンピューティングモデルは、現在のLambdaに酷似していた。だがCanon Europeはクラウドの将来性を信じず、2007年12月24日にサービスは終了した

## 5. Firebase の歴史

- **結論**: Firebaseは2011年にJames TamplinとAndrew Leeがサンフランシスコで設立（前身はEnvolve）。2014年10月21日にGoogleが買収を発表
- **一次ソース**: TechCrunch, "Google Acquires Firebase To Help Developers Build Better Real-Time Apps", October 21, 2014; Wikipedia, "Firebase"
- **URL**: <https://techcrunch.com/2014/10/21/google-acquires-firebase-to-help-developers-build-better-realtime-apps/>, <https://en.wikipedia.org/wiki/Firebase>
- **注意事項**: 前身Envolveは元々リアルタイムチャット機能のスタートアップ。買収額は非公開
- **記事での表現**: 2011年にJames TamplinとAndrew Leeが設立したFirebaseは、リアルタイムデータベースサービスとして成長し、2014年10月にGoogleに買収された

## 6. Firecracker microVM

- **結論**: Firecrackerは2018年11月のAWS re:Invent 2018で発表・オープンソース化。Rustで記述されたVMM（Virtual Machine Monitor）で、Linux KVM上で動作するmicroVMを提供。Chromium OSのcrosvm（Rust製VMM）をフォークして開発。起動時間125ミリ秒未満、メモリオーバーヘッド5MiB未満。Apache 2.0ライセンス
- **一次ソース**: AWS Open Source Blog, "Announcing the Firecracker Open Source Technology", 2018; Amazon Science, "How AWS's Firecracker virtual machines work"
- **URL**: <https://aws.amazon.com/blogs/opensource/firecracker-open-source-secure-fast-microvm-serverless/>, <https://www.amazon.science/blog/how-awss-firecracker-virtual-machines-work>
- **注意事項**: AWS LambdaおよびAWS Fargateの基盤技術として使用。ホストあたり毎秒最大150のmicroVMを作成可能
- **記事での表現**: 2018年11月のre:Invent 2018で、AWSはFirecrackerをオープンソースとして公開した。Rust製のVMMで、起動時間125ミリ秒未満、メモリオーバーヘッド5MiB未満という軽量さでLambdaとFargateの基盤を支えている

## 7. Serverless Framework の歴史

- **結論**: 2015年にAusten Collinsが作成。当初の名前は「JAWS」（Just AWS Without Servers）。2015年10月のAWS re:Invent 2015で紹介。2015年末に「Serverless」に改名。2016年10月にシードラウンド300万ドルを調達
- **一次ソース**: Serverless Chats Podcast, "Episode #66: The Story of the Serverless Framework with Austen Collins"; AWS, "Austen Collins | AWS Serverless Hero"
- **URL**: <https://www.serverlesschats.com/66/>, <https://aws.amazon.com/developer/community/heroes/austen-collins/>
- **注意事項**: Austen CollinsはAWS Serverless Heroに選出されている
- **記事での表現**: 2015年、Austen Collinsは「JAWS（Just AWS Without Servers）」というプロジェクトを立ち上げ、年末には「Serverless Framework」に改名した

## 8. コールドスタートと Provisioned Concurrency

- **結論**: Provisioned Concurrencyは2019年12月のAWS re:Invent 2019で発表。事前に指定した数の実行環境を初期化済みの状態で維持し、二桁ミリ秒でのレスポンスを実現
- **一次ソース**: AWS News Blog, "New - Provisioned Concurrency for Lambda Functions", December 2019
- **URL**: <https://aws.amazon.com/blogs/aws/new-provisioned-concurrency-for-lambda-functions/>
- **注意事項**: Provisioned Concurrencyは追加コストが発生する
- **記事での表現**: 2019年12月のre:Invent 2019でProvisioned Concurrencyが発表された。事前に実行環境を初期化済みの状態で維持し、コールドスタートを回避する仕組みである

## 9. Lambda の実行制限

- **結論**: タイムアウト: 当初60秒→2015年に5分→2018年10月に15分。メモリ: 当初最大1,536MB→2017年11月に3,008MB→2020年12月に10,240MB（10GB・6 vCPU）
- **一次ソース**: JAXenter, "Day 2 at the AWS re:Invent - what we learned", 2015; AWS, "Amazon Lambda enables functions that can run up to 15 minutes", October 2018; AWS, "AWS Lambda now supports up to 10 GB of memory and 6 vCPU cores", December 2020
- **URL**: <https://jaxenter.com/day-2-at-the-aws-reinvent-what-we-learned-121375.html>, <https://www.amazonaws.cn/en/new/2018/aws-lambda-enables-functions-that-can-run-up-to-15-minutes/>, <https://aws.amazon.com/about-aws/whats-new/2020/12/aws-lambda-supports-10gb-memory-6-vcpu-cores-lambda-functions/>
- **注意事項**: 当初の60秒制限はJAXenterの「from 1 minute to 5 minutes」記述から裏付け
- **記事での表現**: Lambdaのローンチ時、最大実行時間はわずか60秒。2015年に5分、2018年10月に15分へ段階的に拡大。メモリも当初の最大1,536MBから、2020年12月に10,240MB（10GB・6 vCPU）へと拡張された

## 10. Lambda の料金モデル

- **結論**: リクエスト課金（100万リクエストあたり$0.20）+コンピュート課金（GB秒あたり$0.0000166667）。月100万リクエスト+320万秒のコンピュート時間が無料枠。2020年12月からミリ秒単位課金を導入
- **一次ソース**: AWS Lambda Pricing page
- **URL**: <https://aws.amazon.com/lambda/pricing/>
- **注意事項**: 散発的・スパイク型ワークロードではLambdaが有利。24時間365日の安定高負荷ではEC2（Reserved Instance）の方がコスト効率が高い
- **記事での表現**: Lambdaは「リクエスト単価」と「コンピュート時間（GB秒）」の二本立て課金で、月100万リクエストまでは無料枠に収まる。だが24時間稼働の高負荷処理ではEC2のReserved Instanceの方がコスト効率が高くなる

## 11. Lambda の初期機能と進化

- **結論**: 2014年11月Node.jsのみ→2015年Java 8/Python 2.7→2016年VPCサポート/C#→2018年Go/Ruby/Lambda Layers/Custom Runtime/Firecracker→2019年Provisioned Concurrency→2020年コンテナイメージサポート（最大10GB）/メモリ10GB/ミリ秒課金
- **一次ソース**: AWS Compute Blog, The Register, InfoWorld, AWS announcements（各項目のURL参照）
- **URL**: 各年の発表記事（項目1, 6, 8, 9のURLを参照）
- **注意事項**: VPCサポートは当初コールドスタートが深刻に悪化する問題があり、2019年にネットワーキングが改善された
- **記事での表現**: Node.js単独でローンチしたLambdaは、Java、Python、C#、Go、Rubyと対応言語を拡大し、2018年のCustom Runtime APIで事実上あらゆる言語に対応した。2020年のコンテナイメージサポートで、サーバーレスとコンテナの境界はさらに曖昧になった

## 12. Werner Vogels とサーバーレスビジョン

- **結論**: Werner VogelsはAmazon.comのVP兼CTO。2014年re:Invent Day 2キーノートでLambdaを発表。2015年re:Inventキーノートで「No server is easier to manage than no server」の名言を残した
- **一次ソース**: JAXenter, "Day 2 at the AWS re:Invent - what we learned", 2015; Ubertas Consulting, "Cloud Simplified: What is Serverless Architecture?", 2017
- **URL**: <https://jaxenter.com/day-2-at-the-aws-reinvent-what-we-learned-121375.html>, <https://ubertasconsulting.com/2017/05/18/blog-6-serverless-architecture/>
- **注意事項**: 「No server is easier to manage than no server」はre:Invent 2015での発言
- **記事での表現**: Werner Vogelsは2015年のre:Inventキーノートで「No server is easier to manage than no server（管理が最も容易なサーバーとは、存在しないサーバーである）」と述べ、サーバーレスの思想を端的に表現した
