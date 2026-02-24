# ファクトチェック記録：第13回「Heroku——『git pushでデプロイ』が変えたもの」

## 1. Heroku創業の経緯

- **結論**: Herokuは2007年6月にJames Lindenbaum、Adam Wiggins、Orion Henryの3名によって創業された。当初はブラウザ内コードエディタでRubyアプリケーションの構築・デプロイを支援するプラットフォームだった。Y Combinatorに参加（W08バッチ）
- **一次ソース**: Heroku公式サイト "About Heroku"; Y Combinator企業ページ
- **URL**: <https://www.heroku.com/about/>、<https://www.ycombinator.com/companies/heroku>
- **注意事項**: Wikipediaでは「June 2007」と記載。公式サイトでも2007年創業と明記
- **記事での表現**: 2007年6月、James Lindenbaum、Adam Wiggins、Orion Henryの3名がHerokuを創業した

## 2. SalesforceによるHeroku買収

- **結論**: 2010年12月8日にSalesforce.comがHerokuを2億1,200万ドルの現金で買収を発表。買収完了は2011年1月3日
- **一次ソース**: Salesforce公式プレスリリース; TechCrunch報道
- **URL**: <https://www.salesforce.com/news/press-releases/2011/01/03/salesforce-com-completes-acquisition-of-heroku/>、<https://techcrunch.com/2010/12/08/breaking-salesforce-buys-heroku-for-212-million-in-cash/>
- **注意事項**: 一部メディアでは「2億5,000万ドル」との報道もあるが、公式プレスリリースでは2億1,200万ドル
- **記事での表現**: 2010年12月、SalesforceはHerokuを約2億1,200万ドルで買収した

## 3. The Twelve-Factor App

- **結論**: Adam Wigginsが2011年にHerokuでの経験を基にThe Twelve-Factor App方法論を発表。12factor.netで公開。2010年から2011年にかけてのHeroku内部での実践を体系化したもの
- **一次ソース**: 12factor.net公式サイト; Wikipedia "Twelve-Factor App methodology"
- **URL**: <https://12factor.net/>、<https://en.wikipedia.org/wiki/Twelve-Factor_App_methodology>
- **注意事項**: 正式公開は2011年。Heroku内部では2010年頃から議論されていた
- **記事での表現**: 2011年、HerokuのAdam Wigginsは、The Twelve-Factor Appを12factor.netで公開した

## 4. Heroku Buildpackの概念

- **結論**: BuildpackはCedar stackの一部として2011年に導入された。言語を検出し、依存関係を解決し、ビルドを実行する。Cedar stackは言語に依存しない汎用スタックとして設計され、buildpackが言語サポートを担う
- **一次ソース**: Heroku公式ブログ "Buildpacks: Heroku-Designed Build-Time Adapter"
- **URL**: <https://blog.heroku.com/buildpacks>、<https://devcenter.heroku.com/articles/buildpacks>
- **注意事項**: Cloud Native Buildpacksプロジェクトは2018年1月にPivotalとHerokuが共同で発足
- **記事での表現**: Cedar stackとともにbuildpackの概念を導入し、言語検出・依存解決・ビルドの自動化を実現した

## 5. Heroku Cedarスタックとポリグロット化

- **結論**: Cedar stack（Celadon Cedar）は2011年5月にパブリックベータとして発表。2011年夏にRuby、Node.js、Clojure、Java、Python、Scalaの公式サポートを開始。それ以前のスタックはArgent Aspen（2009年）、Badious Bamboo（2010年）
- **一次ソース**: Heroku公式ブログ; InfoQ報道
- **URL**: <https://blog.heroku.com/celadon_cedar>、<https://www.infoq.com/news/2011/08/heroku_polyglot/>
- **注意事項**: 初期はRuby（1.8.6）のみのRails専用プラットフォームだった
- **記事での表現**: 2011年、Cedar stackの導入でHerokuはポリグロットプラットフォームとなり、Ruby以外の言語もサポートした

## 6. Heroku Dynoの仕組み

- **結論**: DynoはHerokuが管理するLinuxコンテナ。OSコンテナ化技術を使用し、追加のカスタム強化を施している。Webダイノ（HTTP受信可能）とWorkerダイノ（バックグラウンドジョブ）に分かれる
- **一次ソース**: Heroku Dev Center "Dynos (App Containers)"
- **URL**: <https://devcenter.heroku.com/articles/dynos>
- **注意事項**: Cedar世代ではx86ベース。Fir世代（2025年〜）ではARMベース
- **記事での表現**: Dynoと呼ばれるLinuxコンテナ上でアプリケーションを実行する

## 7. Herokuの無料プラン廃止

- **結論**: 2022年8月25日に無料プランの廃止を発表。2022年11月28日に無料ダイノ、無料Heroku Postgres、無料Heroku Data for Redisの提供を終了。理由は「不正利用と悪用への対応に膨大なリソースを費やしていた」ため
- **一次ソース**: Heroku公式ブログ "Heroku's Next Chapter"; TechCrunch報道
- **URL**: <https://blog.heroku.com/next-chapter>、<https://techcrunch.com/2022/08/25/heroku-announces-plans-to-eliminate-free-plans-blaming-fraud-and-abuse/>
- **注意事項**: Heroku GM Bob Wiseが「6〜8年の投資不足」を背景として言及
- **記事での表現**: 2022年11月、Herokuは無料プランを廃止した

## 8. Procfileとプロセスモデル

- **結論**: ProcfileはHerokuが導入した、言語に依存しないプロセス定義フォーマット。Unixプロセスモデルを基盤に、アプリケーションの実行方法を宣言的に定義する。web、worker等のプロセスタイプを定義可能
- **一次ソース**: Heroku Dev Center "The Procfile"; Heroku Blog "The New Heroku (Part 1 of 4)"
- **URL**: <https://devcenter.heroku.com/articles/procfile>、<https://blog.heroku.com/the_new_heroku_1_process_model_procfile>
- **注意事項**: Procfileの概念はCedar stackとともに導入された
- **記事での表現**: Procfileにより、アプリケーションのプロセス定義を宣言的に記述する仕組みを確立した

## 9. Dokku（セルフホスト版Heroku）

- **結論**: 2013年6月にJeff Lindsay（progrium）が発表。「The smallest PaaS implementation you've ever seen」と称し、当初は100行未満のBashスクリプトだった。DockerとHerokuのbuildpackを組み合わせたシングルホスト向けPaaS
- **一次ソース**: Jeff Lindsay公式ブログ; GitHub dokku/dokku
- **URL**: <https://progrium.github.io/blog/2013/06/19/dokku-the-smallest-paas-implementation-youve-ever-seen/>、<https://github.com/dokku/dokku>
- **注意事項**: 現在も活発に開発が続いている
- **記事での表現**: 2013年、Jeff LindsayはDokku——100行未満のBashで書かれたセルフホスト版Herokuを公開した

## 10. Cloud Foundry

- **結論**: VMwareが2011年4月にオープンソースPaaSとして発表。Derek Collisonが率いるチームが2009年から開発。Apache 2.0ライセンス。2013年にPivotalに移管、2015年にCloud Foundry Foundation（Linux Foundation傘下）を設立
- **一次ソース**: VMware Open Source Blog; Cloud Foundry Foundation; Wikipedia
- **URL**: <https://blogs.vmware.com/opensource/2020/06/25/the-past-present-and-future-of-cloud-foundry-part-1/>、<https://en.wikipedia.org/wiki/Cloud_Foundry>
- **注意事項**: 「業界初のオープンソースPaaS」を標榜していた
- **記事での表現**: 2011年4月、VMwareはCloud Foundryをオープンソースの企業向けPaaSとして発表した
