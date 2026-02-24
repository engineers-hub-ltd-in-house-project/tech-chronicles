# ファクトチェック記録：第15回「PaaSの栄枯盛衰——なぜ『便利すぎる抽象化』は苦戦したか」

## 1. Cloud Foundryの設立と歴史

- **結論**: Cloud Foundryは2009年にVMwareのDerek Collison、Mark Lucovsky、Vadim Spivakらのチームにより設計・開発が開始され、2011年4月に業界初のオープンソースPaaSとして発表された。VMwareからEMC/VMware/GEの合弁会社Pivotal Software（2013年）に移管され、2015年にCloud Foundry Foundation（Linux Foundation傘下）に移管された
- **一次ソース**: VMware Press Release, "VMware Introduces Cloud Foundry, The Industry's First Open PaaS", April 2011; Wikipedia, "Cloud Foundry"
- **URL**: <https://news.broadcom.com/releases/cloud-foundry-apr2011>, <https://en.wikipedia.org/wiki/Cloud_Foundry>
- **注意事項**: 「Project B29」が内部コードネーム。Pivotalへの移管は2012年発表、2013年正式設立
- **記事での表現**: 2011年4月、VMwareがCloud Foundryを「業界初のオープンソースPaaS」として発表した。のちにPivotal Softwareに移管（2013年）、さらにLinux Foundation傘下のCloud Foundry Foundationに移管（2015年）された

## 2. OpenShiftの歴史とKubernetesへの転換

- **結論**: Red Hatは2010年11月にPaaS企業Makaraを買収し、2011年5月にOpenShiftを発表。2012年5月にオープンソース化、2012年11月にOpenShift Enterprise 1.0がGA。バージョン3（2015年6月）でDockerとKubernetesを採用し、独自技術からKubernetesベースへ大転換した
- **一次ソース**: Red Hat Blog, "PaaS to Kubernetes to cloud services: Looking back at 10 years of Red Hat OpenShift"; Wikipedia, "OpenShift"
- **URL**: <https://www.redhat.com/en/blog/paas-kubernetes-cloud-services-looking-back-10-years-red-hat-openshift>, <https://en.wikipedia.org/wiki/OpenShift>
- **注意事項**: バージョン3以前は独自のコンテナ技術（RHEL-based Linux containers）を使用。Docker以前のコンテナ技術
- **記事での表現**: OpenShift 3（2015年6月）でDockerとKubernetesを採用し、独自PaaSからエンタープライズKubernetesディストリビューションへ転身した

## 3. dotCloudからDockerへの転換

- **結論**: dotCloudは2008年にKamel Founadi、Solomon Hykes、Sebastien Pahlによりパリで設立され、PaaS企業として運営。2013年3月にDockerをオープンソースとして公開。2013年10月29日にPaaS事業を縮小し社名をDocker Inc.に変更。Docker 1.0は2014年にリリースされ、その時点で275万ダウンロードを達成
- **一次ソース**: Wikipedia, "Docker, Inc."; InfoWorld, "The sun sets on original Docker PaaS"
- **URL**: <https://en.wikipedia.org/wiki/Docker,_Inc.>, <https://www.infoworld.com/article/2244891/the-sun-sets-on-original-docker-paas.html>
- **注意事項**: dotCloudは2010年に米国法人化、2011年にシリコンバレーに移転。PaaS企業がコンテナ技術に転身した象徴的事例
- **記事での表現**: PaaS企業dotCloudが自社の内部技術であるDockerをオープンソース化（2013年3月）し、PaaS事業を捨ててDocker Inc.に転身（2013年10月）した。PaaS企業自身がPaaSを見捨てたという皮肉な事実

## 4. Herokuの衰退と2022年無料プラン廃止

- **結論**: SalesforceがHerokuを2010年12月に2億1200万ドルで買収。買収後は投資が鈍化。2022年4月にOAuthトークンの流出というセキュリティインシデントが発覚。2022年8月に無料プランの廃止を発表、11月28日に実施。理由として「不正利用やアビュースへの対処に莫大なリソースが必要」と説明
- **一次ソース**: Heroku FAQ, "Removal of Heroku Free Product Plans FAQ"; RedMonk, "The End of Heroku's Free Tier"; Medium, "The Rise, Decline and Free Fall of Heroku"
- **URL**: <https://help.heroku.com/RSBRUH58/removal-of-heroku-free-product-plans-faq>, <https://redmonk.com/kholterhoff/2022/12/01/the-end-of-herokus-free-tier/>, <https://medium.com/@gauravkheterpal/the-rise-decline-and-fall-of-heroku-what-could-have-been-a35f122f4183>
- **注意事項**: 第13回で詳述済み。第15回ではPaaS全体の文脈で言及
- **記事での表現**: Herokuの衰退はPaaS第一世代の限界を象徴する。買収後の投資停滞、コンテナ/サーバーレスへの対応遅れ、2022年の無料プラン廃止が重なった

## 5. Vercel（旧ZEIT）の設立と歴史

- **結論**: Guillermo Rauchが2015年にZEITを設立。共同創業者はTony KovanenとNaoyuki Kanezawa。最初のプロダクトは「now」（CLIデプロイツール）。2016年10月にNext.jsをリリース。2020年4月にVercelにリブランド、同時に2100万ドルの資金調達を発表
- **一次ソース**: Wikipedia, "Vercel"; Vercel Blog, "ZEIT is now Vercel"; Medium, "History of Vercel"
- **URL**: <https://en.wikipedia.org/wiki/Vercel>, <https://vercel.com/blog/zeit-is-now-vercel>, <https://medium.com/history-of-vercel/history-of-vercel-2015-2020-6-7-zeit-and-next-js-dc480a88e0b8>
- **注意事項**: VercelはフロントエンドPaaS的な位置づけ。JAMstackとの関連はNetlifyの方が先駆け
- **記事での表現**: ZEIT（2015年設立、2020年にVercelへ改名）はNext.jsフレームワーク（2016年）と統合したフロントエンドデプロイメントプラットフォームとして「PaaS 2.0」の一角を占める

## 6. Fly.ioの設立と歴史

- **結論**: Fly.ioは2017年にJerome Gravel-Niquet、Kurt Mackey、Michael Dwanにより設立。シカゴ本社。創業者らはHerokuを参考に開発。Kurt Mackeyは以前MongoHQ（のちにComposeに改名、2015年にIBMに売却）を創業。Y Combinator 2020冬バッチ
- **一次ソース**: TechCrunch, "Fly.io wants to change the way companies deploy apps at the edge"; Fly.io About page
- **URL**: <https://techcrunch.com/2022/07/28/fly-io-wants-to-change-the-way-companies-deploy-apps-at-the-edge/>, <https://fly.io/about/>
- **注意事項**: 当初はエッジコンピューティング寄りだったが、現在は汎用パブリッククラウドへ進化
- **記事での表現**: Fly.io（2017年設立）はHerokuの開発者体験を参照しつつ、Firecrackerマイクロ VMとグローバルエッジ展開を組み合わせた新世代PaaSとして台頭した

## 7. Renderの設立

- **結論**: Renderは2019年に元Stripeエンジニアのアヌラグ・ゴエル（Anurag Goel）により設立。Herokuの後継を標榜し、コンテナベースのインフラ、統合的なサービス（cronジョブ、バックグラウンドワーカー、静的サイトホスティング、CD）を提供
- **一次ソース**: Changelog/Ship It! Podcast, "The infrastructure behind a PaaS with Anurag Goel"; Render公式サイト
- **URL**: <https://changelog.com/shipit/108>, <https://render.com/>
- **注意事項**: Heroku無料プラン廃止後の移行先として急成長
- **記事での表現**: Render（2019年設立）は元Stripeエンジニアが創業し、Herokuの精神的後継を掲げるPaaS 2.0プラットフォームである

## 8. Railwayの設立

- **結論**: Railwayは2020年に共同創業者Cooperら（元Wolfram Alpha、Bloomberg、Uber）により設立。2021年にプラットフォーム正式リリース。2022年にRedpoint VenturesリードのSeries Aで2000万ドル調達
- **一次ソース**: TechCrunch, "Railway snags $20M"; Contrary Research, "Railway Business Breakdown & Founding Story"
- **URL**: <https://techcrunch.com/2022/05/31/railway-snags-20m-to-streamline-the-process-of-deploying-apps-and-services/>, <https://research.contrary.com/company/railway>
- **注意事項**: GitHub接続による簡易デプロイが特徴
- **記事での表現**: Railway（2020年設立）は「サーバーを意識せずにコードをデプロイする」というPaaSの原初の約束を、コンテナ技術の標準化の上に再構築した

## 9. The Twelve-Factor App

- **結論**: 2011年11月にHeroku共同創業者のAdam Wigginsにより12factor.netで公開。2010〜2011年の内部プロジェクトでHerokuプラットフォーム上の実運用SaaSアプリケーションの知見を体系化。PaaSの設計原則がクラウドネイティブ設計の標準となった
- **一次ソース**: 12factor.net; Heroku Blog, "Heroku Open Sources the Twelve-Factor App Definition"; Wikipedia, "Twelve-Factor App methodology"
- **URL**: <https://12factor.net/>, <https://www.heroku.com/blog/heroku-open-sources-twelve-factor-app-definition/>, <https://en.wikipedia.org/wiki/Twelve-Factor_App_methodology>
- **注意事項**: 第13回で詳述済み。第15回ではPaaSの遺産として言及
- **記事での表現**: The Twelve-Factor App（2011年、Adam Wiggins）はHerokuのPaaS運用から生まれた設計原則であり、PaaSそのものが衰退してもこの思想はクラウドネイティブの標準として生き続けている

## 10. PaaS市場規模（Gartner予測）

- **結論**: Gartner予測によると、世界のPaaS市場は2023年に約1430億ドル、2024年に約1724億ドル（前年比約21%成長）。2025年の世界パブリッククラウド全体の支出は7234億ドル（前年の5957億ドルから成長）。PaaSはIaaS、DaaSと並んで最も成長率が高いセグメント
- **一次ソース**: Gartner Press Release, May 2024; Gartner Press Release, November 2024
- **URL**: <https://www.gartner.com/en/newsroom/press-releases/2024-05-20-gartner-forecasts-worldwide-public-cloud-end-user-spending-to-surpass-675-billion-in-2024>, <https://www.gartner.com/en/newsroom/press-releases/2024-11-19-gartner-forecasts-worldwide-public-cloud-end-user-spending-to-total-723-billion-dollars-in-2025>
- **注意事項**: Gartnerの「PaaS」定義は広義（データベース、ミドルウェア、AI/MLプラットフォーム等を含む）。狭義のアプリケーションPaaSとは異なる
- **記事での表現**: Gartnerの予測ではPaaS市場は2024年に約1720億ドル規模と推定されるが、これは広義のプラットフォームサービスを含む数字であり、狭義のアプリケーションPaaSとは区別が必要

## 11. Netlifyの設立とJAMstack

- **結論**: Netlifyは2014年7月10日にMathias Biilmannにより設立。当初はBitBalloonの名称。2015年にChristian Bachが合流し正式ローンチ。JAMstack（JavaScript, APIs, Markup）という用語は2015-2016年にBiilmannとBachが提唱。静的サイトデプロイメントの先駆者
- **一次ソース**: Wikipedia, "Netlify"; Biilmann Blog, "10 Years of Netlify"
- **URL**: <https://en.wikipedia.org/wiki/Netlify>, <https://biilmann.blog/articles/10-years-of-netlify/>
- **注意事項**: フロントエンド特化のPaaSとして位置づけ。Vercelとの競合関係
- **記事での表現**: Netlify（2014年設立）はJAMstackという概念を提唱し、フロントエンド特化のデプロイメントプラットフォームとしてPaaS 2.0の一角を形成した

## 12. Kubernetesの発表とPaaSへの影響

- **結論**: 2014年6月10日、Googleの副社長Eric BrewerがDockerConでKubernetesを発表。Google内部のBorg/Omegaの経験を基に開発。Kubernetesは急速に普及し、コンテナオーケストレーションの標準となった。これにより開発者はIaaSレベルの柔軟性を保ちつつ、PaaS的な自動化を実現できるようになり、従来型PaaSの存在意義が問われた
- **一次ソース**: Docker Blog, "10 Years Since Kubernetes Launched at DockerCon"
- **URL**: <https://www.docker.com/blog/10-years-since-kubernetes-launched-at-dockercon/>
- **注意事項**: KubernetesはPaaSの「代替」というよりも、PaaSの基盤技術となった面もある（OpenShift 3以降）
- **記事での表現**: 2014年6月のKubernetes発表は、PaaS市場の転換点となった。Kubernetesはコンテナオーケストレーションを標準化し、IaaSの柔軟性とPaaSの自動化を両立させる選択肢を開発者に与えた

---

**品質ゲート確認: 12項目すべて検証済み。基準（6項目以上）を満たす。**
