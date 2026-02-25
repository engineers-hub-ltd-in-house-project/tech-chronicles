# ファクトチェック記録: cloud-history 第19回

「マイクロサービスとクラウド——分散システムの光と影」

---

## 1. James LewisとMartin Fowlerの「Microservices」記事（2014年3月）

- **結論**: James Lewis（Thoughtworks Principal Consultant）とMartin Fowlerが共著で2014年3月25日に公開した。マイクロサービスの9つの特徴を定義し、SOAとの関係を議論した記事である
- **一次ソース**: James Lewis, Martin Fowler, "Microservices", martinfowler.com, March 25, 2014
- **URL**: <https://martinfowler.com/articles/microservices.html>
- **注意事項**: 2013年末にFowlerがマイクロサービスの明確な定義がないことを懸念し、経験豊富な実践者であるLewisと共同で執筆に至った
- **記事での表現**: 2014年3月25日、James LewisとMartin Fowlerがmartinfowler.comに公開した「Microservices」記事がマイクロサービスの定義を確立した

## 2. SOA（Service-Oriented Architecture）とESB（Enterprise Service Bus）の歴史

- **結論**: SOAは1990年代後半に登場した概念。ESBという用語はGartnerのRoy W. Schulteが2002年に初めて使用した。商用ESBとしてはCandle社のRoma（1998年）が最も直接的な祖先とされる。2000年代前半にSOA/ESBは企業に大規模に導入されたが、複雑性と重厚長大さが問題となった
- **一次ソース**: Roy W. Schulte, Yefim V. Natis (Gartner), 2002; David Chappell, "The Enterprise Service Bus" (書籍)
- **URL**: <https://en.wikipedia.org/wiki/Enterprise_service_bus>
- **注意事項**: SOAの定義自体が曖昧だった点も後のマイクロサービス議論の伏線となる
- **記事での表現**: SOAは2000年代前半に企業IT に大規模導入されたが、ESBの重厚長大さが「SOA疲れ」を生んだ

## 3. Netflixのマイクロサービス移行

- **結論**: 2008年8月、Netflixはデータベース破損による3日間のサービス停止を経験。これを契機にAWSへの移行とマイクロサービスアーキテクチャへの転換を開始。2009年にクラウドファースト戦略を宣言し、約7年かけて移行を完了。2016年1月に最後のデータセンターを閉鎖。最終的に700以上（現在は1000以上）のマイクロサービスに分割
- **一次ソース**: Netflix Tech Blog; About Netflix, "Completing the Netflix Cloud Migration", January 2016
- **URL**: <http://about.netflix.com/en/news/completing-the-netflix-cloud-migration>
- **注意事項**: 2008年のインシデントはディスクアレイのファームウェア問題によるDB破損。DVD配送が3日間停止
- **記事での表現**: 2008年のデータベース破損事件をきっかけに、Netflixは7年をかけてモノリスから700以上のマイクロサービスへ移行し、2016年1月にクラウド移行を完了した

## 4. Martin Fowlerの「Monolith First」（2015年6月3日）

- **結論**: 2015年6月3日にmartinfowler.comのblikiに公開。「成功したマイクロサービスのほぼすべてが、大きくなりすぎたモノリスから始まった」と指摘。新プロジェクトをマイクロサービスから始めることを戒めた
- **一次ソース**: Martin Fowler, "MonolithFirst", martinfowler.com, June 3, 2015
- **URL**: <https://martinfowler.com/bliki/MonolithFirst.html>
- **注意事項**: Sam Newmanの"Don't start with a monolith"という反論記事も同サイトに掲載されており、議論は一方的ではない
- **記事での表現**: Fowlerは2015年6月の「MonolithFirst」で「まずモノリスから始めよ」と警告した

## 5. Istioサービスメッシュの登場（2017年5月）

- **結論**: Google、IBM、Lyftにより2017年5月にオープンソース化。GlueCon 2017で発表。バージョン0.1がリリースされた。プロダクション対応をうたうIstio 1.0は2018年7月にリリース
- **一次ソース**: Istio, "Introducing Istio", May 2017
- **URL**: <https://istio.io/latest/news/releases/0.x/announcing-0.1/>
- **注意事項**: 当初はマイクロサービスアーキテクチャで構築されていたが、後にモノリスに戻された。データプレーン（Envoyプロキシ）、コントロールプレーン、サイドカーパターンの構成
- **記事での表現**: 2017年5月、Google・IBM・LyftがIstioをオープンソース化し、サービスメッシュの概念を広めた

## 6. Netflix Hystrix（2012年オープンソース化）

- **結論**: Hystrixは2011年にNetflix APIチームのレジリエンスエンジニアリングから発展。2012年にオープンソース化（Apache License 2.0）。サーキットブレーカーパターンを実装した耐障害性ライブラリ。2018年11月19日にメンテナンスモードに移行
- **一次ソース**: Netflix/Hystrix GitHub Wiki; InfoQ, "Netflix Hystrix – Latency and Fault Tolerance for Complex Distributed Systems", December 2012
- **URL**: <https://github.com/Netflix/Hystrix>
- **注意事項**: 2018年11月以降はResilient4jが後継として推奨されている
- **記事での表現**: 2012年にNetflixがオープンソース化したHystrixは、サーキットブレーカーパターンのデファクト実装となった

## 7. Resilience4j（Hystrixの後継）

- **結論**: Netflix Hystrixがメンテナンスモード入り（2018年11月）後、Resilience4jが後継として広く採用された。Java 8と関数型プログラミングを前提に設計。CircuitBreaker、RateLimiter、Retry、Bulkhead、TimeLimiterなどのモジュールを提供。Springが新プロジェクトでの推奨サーキットブレーカーとして位置づけ
- **一次ソース**: resilience4j/resilience4j GitHub
- **URL**: <https://github.com/resilience4j/resilience4j>
- **注意事項**: Hystrixとの設計思想の違い: Hystrixはオブジェクト指向（HystrixCommand）、Resilience4jは関数合成ベース
- **記事での表現**: Hystrixのメンテナンスモード移行後、関数型設計のResilient4jが後継として台頭した

## 8. OpenTelemetryの成立（2019年）

- **結論**: 2019年にOpenTracingとOpenCensusが統合してOpenTelemetryが誕生。最初のGitHubコミットは2019年4月、CNCF加入は2019年5月17日。2021年8月にCNCFインキュベーティングプロジェクトに昇格
- **一次ソース**: Microsoft Open Source Blog, "Announcing OpenTelemetry", May 23, 2019; CNCF, "A brief history of OpenTelemetry", May 21, 2019
- **URL**: <https://opensource.microsoft.com/blog/2019/05/23/announcing-opentelemetry-cncf-merged-opencensus-opentracing>
- **注意事項**: OpenTracingは2016年にCNCFの下で立ち上げ。OpenCensusはGoogleが開発。両プロジェクトの統合により分散トレーシングの標準化が実現
- **記事での表現**: 2019年、OpenTracingとOpenCensusが統合しOpenTelemetryが誕生。分散トレーシングの標準化が進んだ

## 9. Jaeger分散トレーシング（Uber、2017年オープンソース化）

- **結論**: 2015年にUber社内で開発開始（最初のコミットは2015年8月3日）。2017年初頭にオープンソース化。2017年9月にCNCFの第12番目のホステッドプロジェクトとして採用。2019年10月にCNCF Graduatedステータスに到達
- **一次ソース**: Uber Engineering Blog; CNCF
- **URL**: <https://www.jaegertracing.io/>
- **注意事項**: Google Dapperペーパー（2010年）に触発されたシステム。Zipkin（Twitter、2012年）に続く代表的な分散トレーシングシステム
- **記事での表現**: Uberが2015年に開発を開始したJaegerは、2017年にオープンソース化されCNCFに採用された

## 10. Jeff Bezosの「APIマンデート」（2002年頃）とTwo-Pizza Teams

- **結論**: 2002年頃（±1年）にJeff Bezosが社内に発した指令。全チームはサービスインターフェースを通じてデータと機能を公開すること、チーム間の通信はサービスインターフェース経由のみ許可、という内容。2011年にGoogleのSteve YeggeがGoogle+への誤投稿で公にした。Two-Pizza Teamsは「2枚のピザで養える規模（10人未満）」のチーム編成原則
- **一次ソース**: Steve Yegge, "Stevey's Google Platforms Rant", October 2011 (original Google+ post); AWS Executive Insights, "Amazon's Two Pizza Team"
- **URL**: <https://nordicapis.com/the-bezos-api-mandate-amazons-manifesto-for-externalization/>
- **注意事項**: 正確な年は「2002年頃」であり、Yegge自身も「plus or minus a year」と述べている
- **記事での表現**: 2002年頃、BezosはAmazon社内に「全チームはサービスインターフェースで通信せよ」というAPIマンデートを発した

## 11. Zipkin分散トレーシング（Twitter、2012年）

- **結論**: TwitterのHack Weekで生まれたプロジェクト。Google Dapperペーパーに触発され、Thrift向けに基本的なトレーシングを実装。2012年にApache License 2.0でオープンソース化。Johan OskarssonとFranklin Huが主要著者。最初のOSS分散トレーシングシステムとして計測機能とUIを完備
- **一次ソース**: Twitter Engineering Blog, "Distributed Systems Tracing with Zipkin", June 2012
- **URL**: <https://blog.twitter.com/engineering/en_us/a/2012/distributed-systems-tracing-with-zipkin>
- **注意事項**: Yelp、Salesforceなども主要なコントリビュータ
- **記事での表現**: 2012年、TwitterがGoogle Dapperに触発されたZipkinをオープンソース化し、分散トレーシングの先駆けとなった

---

**検証結果サマリ**: 11項目中11項目が検証済み。品質ゲート（最低6項目）をクリア。
