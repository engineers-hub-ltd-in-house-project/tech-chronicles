# ファクトチェック記録：第23回「マイクロサービスとUNIX原則——思想の転生」

## 1. Martin Fowler & James Lewis「Microservices」記事

- **結論**: 2014年3月25日に martinfowler.com で公開。「microservices」という用語自体は2011年5月のヴェネツィア近郊でのソフトウェアアーキテクト・ワークショップで議論され、2012年5月に同グループが名称として採用。James Lewisは2012年3月にKrakowの33rd Degreeカンファレンスで「Microservices - Java, the Unix Way」として発表。2013年末にFowlerがLewisと共同で定義記事を執筆
- **一次ソース**: Martin Fowler, James Lewis, "Microservices: A Definition of This New Architectural Term", 25 March 2014
- **URL**: <https://martinfowler.com/articles/microservices.html>
- **注意事項**: 「2014年3月」は正確。FowlerとLewisはThoughtWorks所属
- **記事での表現**: 2014年3月25日、Martin FowlerとJames Lewisが「Microservices」と題する記事を公開した

## 2. SOA（Service-Oriented Architecture）の歴史

- **結論**: SOAの概念は1990年代後半から存在し、CORBA、DCOM等の分散オブジェクト技術に起源を持つ。SOAPは1998年にMicrosoft、DevelopMentor、UserLand Softwareが提案、2000年5月8日にW3C Noteとしてバージョン1.1が公開。WSDLバージョン1.1は2001年3月15日にW3C Note発行。2000年代中盤にエンタープライズ分野で全盛期を迎えた
- **一次ソース**: W3C, "Simple Object Access Protocol (SOAP) 1.1", W3C Note, 8 May 2000; Wikipedia, "Service-oriented architecture"
- **URL**: <https://en.wikipedia.org/wiki/Service-oriented_architecture>
- **注意事項**: SOAの「発明者」は特定の個人に帰属しない。概念の形成は漸進的
- **記事での表現**: 2000年代、SOA（Service-Oriented Architecture）がエンタープライズ・ソフトウェアの世界を席巻した

## 3. Conway's Law（Melvin Conway、1967/1968年）

- **結論**: Melvin Conwayが1967年にHarvard Business Reviewに投稿したが却下され、1968年4月にDatamation誌（Vol.14, No.4, pp.28-31）に「How Do Committees Invent?」として掲載。「Conway's Law」の名称はFred Brooksが『The Mythical Man-Month』（1975年）で命名
- **一次ソース**: Melvin E. Conway, "How Do Committees Invent?", Datamation, 14(4), 28-31, April 1968
- **URL**: <https://www.melconway.com/Home/pdf/committees.pdf>
- **注意事項**: 論文執筆は1967年だが発表は1968年。ブループリントの「1967年」は執筆年としては正しい
- **記事での表現**: 1968年、Melvin Conwayが「How Do Committees Invent?」をDatamation誌に発表した。「組織がシステムを設計すると、その構造は組織のコミュニケーション構造のコピーになる」

## 4. 12-Factor App（Heroku、Adam Wiggins、2011年）

- **結論**: 2011年にHeroku共同創業者のAdam Wigginsが12factor.netで公開。Herokuは2007年設立。数百の顧客アプリケーションをホストする中で成功パターンを体系化したもの
- **一次ソース**: Adam Wiggins, "The Twelve-Factor App", 2011
- **URL**: <https://12factor.net/>
- **注意事項**: 正式な公開月は2011年（Wikipediaによれば「presented by developers at Heroku」）。2024年にHerokuが12-Factor App定義をオープンソース化
- **記事での表現**: 2011年、Heroku共同創業者のAdam Wigginsが「The Twelve-Factor App」を公開した

## 5. Netflixのマイクロサービス移行

- **結論**: 2008年にデータベース破損による3日間のサービス停止が発生し、モノリシック・アーキテクチャの脆弱性が露呈。2009年からAWSクラウドベースのマイクロサービスへの移行を開始。移行完了まで約7年を要し、最終的に700以上のマイクロサービスに分割
- **一次ソース**: Netflix Tech Blog; ByteByteGo, "A Brief History of Scaling Netflix"
- **URL**: <https://blog.bytebytego.com/p/a-brief-history-of-scaling-netflix>
- **注意事項**: 「microservices」という用語が普及する以前の移行開始
- **記事での表現**: 2008年、Netflixはデータベース破損による3日間のサービス停止を経験した。この事件が契機となり、2009年からAWSクラウドベースのマイクロサービスへの移行を開始した

## 6. Amazon Jeff Bezos API Mandate（2002年頃）

- **結論**: 2002年頃、Jeff Bezosが社内に発した指令。全チームはデータと機能をサービスインタフェースを通じて公開すること、直接リンク・直接データベース読み取り・共有メモリ等のプロセス間通信は禁止、全インタフェースは外部公開可能に設計すること。この指令は2011年にSteve Yeggeが誤って公開したGoogle内部メモ「Stevey's Google Platforms Rant」で広く知られた
- **一次ソース**: Steve Yegge, "Stevey's Google Platforms Rant", October 2011（元はGoogle+への誤投稿）
- **URL**: <https://gist.github.com/chitchcock/1281611>
- **注意事項**: Bezos本人の文書は公開されていない。Yeggeの証言が唯一の公開ソース。時期は「2002年頃」とされるが正確な日付は不明
- **記事での表現**: 2002年頃、AmazonのJeff Bezosは全チームにサービスインタフェースを通じたデータ・機能の公開を義務付ける社内指令を発した

## 7. gRPCの歴史（Google Stubby → gRPC）

- **結論**: Googleは2001年頃から内部RPC基盤「Stubby」を使用。2015年2月にgRPCとしてオープンソース化（Apache 2.0ライセンス）。2016年8月にバージョン1.0安定版リリース。HTTP/2ベース、Protocol Buffersによるシリアライゼーション
- **一次ソース**: Google Open Source Blog, "Introducing gRPC, a new open source HTTP/2 RPC Framework", February 2015
- **URL**: <https://opensource.googleblog.com/2015/02/introducing-grpc-new-open-source-http2.html>
- **注意事項**: 「g」は「gRPC」の再帰的略語とされるが、公式には特定の意味を持たない
- **記事での表現**: 2015年2月、GoogleはStubbyの後継となるgRPCをオープンソースとして公開した

## 8. 分散コンピューティングの誤謬（Fallacies of Distributed Computing）

- **結論**: 1991年以降、Sun MicrosystemsのBill JoyとDave Lyonが最初の4つの誤謬を提示。L. Peter Deutschが1994年頃に5〜7番目を追加。James Goslingが1997年頃に8番目「ネットワークは均質である」を追加
- **一次ソース**: L. Peter Deutsch et al., "Fallacies of Distributed Computing"; Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Fallacies_of_distributed_computing>
- **注意事項**: 正確な年は諸説あり。Deutschが「1994年」にまとめたとする記述が多い
- **記事での表現**: 1994年頃、Sun MicrosystemsのL. Peter Deutschらは「分散コンピューティングの誤謬」をまとめた

## 9. CAP定理（Eric Brewer、2000年）

- **結論**: 1999年にEric Brewerが原則として発表、2000年のACM Symposium on Principles of Distributed Computing (PODC) で推測（conjecture）として提示。2002年にMITのSeth GilbertとNancy Lynchが形式的に証明し定理となった
- **一次ソース**: Eric Brewer, "Towards Robust Distributed Systems", PODC Keynote, 2000; Seth Gilbert, Nancy Lynch, "Brewer's conjecture and the feasibility of consistent, available, partition-tolerant web services", ACM SIGACT News, 2002
- **URL**: <https://users.ece.cmu.edu/~adrian/731-sp04/readings/GL-cap.pdf>
- **注意事項**: 分散システムは一貫性(Consistency)・可用性(Availability)・分断耐性(Partition tolerance)の3つのうち2つしか同時に保証できない
- **記事での表現**: 2000年、Eric BrewerがPODCの基調講演でCAP推測を提示した

## 10. Apache Kafka（LinkedIn、2011年）

- **結論**: LinkedInで2010年頃に開発開始。Jay Kreps、Neha Narkhede、Jun Raoが共同開発。2011年初頭にオープンソース化。2012年10月23日にApache Incubatorを卒業。2014年11月にKreps、Narkhede、RaoがConfluent社を設立
- **一次ソース**: LinkedIn Engineering Blog, "Open-sourcing Kafka, LinkedIn's distributed message queue", January 11, 2011
- **URL**: <https://blog.linkedin.com/2011/01/11/open-source-linkedin-kafka>
- **注意事項**: Kafkaは「メッセージキュー」より「分散ログベースのメッセージングシステム」が正確
- **記事での表現**: 2011年、LinkedInのJay Krepsらが開発した分散メッセージングシステムKafkaがオープンソース化された

## 11. Netflix Chaos Monkey（2011年）

- **結論**: 2011年にNetflixがChaos Monkeyを開発。本番環境でランダムにインスタンスを停止させ、システムの回復力をテストするツール。2012年にApache 2.0ライセンスでオープンソース化。Simian Armyの一部として発展
- **一次ソース**: Netflix Tech Blog; GitHub Netflix/chaosmonkey
- **URL**: <https://github.com/Netflix/chaosmonkey>
- **注意事項**: Chaos Engineeringという分野の先駆け
- **記事での表現**: 2011年、NetflixはChaos Monkeyを開発した。本番環境でランダムにインスタンスを停止させ、マイクロサービスの回復力をテストするツールだ
