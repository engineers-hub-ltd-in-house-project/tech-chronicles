# ファクトチェック記録：第19回「GitHubの功罪——ソーシャルコーディングが変えたもの」

## 1. GitHubの設立と創業者

- **結論**: GitHub, Inc.は2007年に設立。サービスは2008年2月からプライベートベータとして公開され、2008年4月10日に正式ローンチ。創業者はTom Preston-Werner、Chris Wanstrath、PJ Hyett、Scott Chacon。Ruby on Railsで開発された
- **一次ソース**: GitHub Wikipedia; Tom Preston-Werner Wikipedia; GitHub History (pslmodels.github.io)
- **URL**: <https://en.wikipedia.org/wiki/GitHub>, <https://en.wikipedia.org/wiki/Tom_Preston-Werner>
- **注意事項**: Scott Chaconを4人目の共同創業者として数えるかどうかは文献によるが、GitHub自身の公式記録では4人を共同創業者として扱っている
- **記事での表現**: 「2008年4月、Tom Preston-Werner、Chris Wanstrath、PJ Hyett、Scott Chaconの4人がGitHubを正式に公開した」

## 2. Pull Request機能の歴史

- **結論**: Pull Request機能はGitHub公開ローンチ以前の2008年2月にベータ版で導入。当初はgit request-pullのGUIラッパーに近く、通知を送るだけの機能だった。2011年2月にdiffビュー上で直接コメントする機能が追加。2011年4月にMergeボタンが初めて実装された
- **一次ソース**: rdnlsmith.com, "A Brief History of the Pull Request"; GitHub community discussion #132528
- **URL**: <https://rdnlsmith.com/posts/2023/004/pull-request-origins/>, <https://github.com/orgs/community/discussions/132528>
- **注意事項**: Git自体にはgit request-pullコマンドが最初期から存在しており、「プルリクエスト」の概念はGitHub独自の発明ではなく、GitHubが概念をWebインターフェースとして具現化した
- **記事での表現**: 「GitHubのPull Request機能は2008年のベータ期に原型が導入され、2011年にdiffコメントとMergeボタンの追加により、現在知られる形に完成した」

## 3. git request-pullの歴史的起源

- **結論**: Linus Torvaldsはgit-pull-scriptを初期のGitに実装し、その後git-request-pull-scriptが作成された。git request-pullはLinuxカーネルの「リューテナント」モデルで使われ、変更のサマリーをメーリングリストに送信するために設計された。GitHubの「Pull Request」はこの概念のWeb化である
- **一次ソース**: Git SCM, git-request-pull documentation; Linux Kernel documentation, "Creating Pull Requests"
- **URL**: <https://git-scm.com/docs/git-request-pull>, <https://docs.kernel.org/maintainer/pull-requests.html>
- **注意事項**: git request-pullの出力はLinus Torvaldsの要求仕様に合わせて設計されている
- **記事での表現**: 「Git自体に最初期からgit request-pullコマンドが存在していた。GitHubはこの概念をWebインターフェースとして再発明した」

## 4. GitLabの設立と歴史

- **結論**: GitLabは2011年10月にウクライナのプログラマーDmytro Zaporozhets（Dmitriy Zaporozhets）がサイドプロジェクトとしてRuby on Railsで開発を開始。2013年1月からフルタイム開発に移行。2014年にGitLab Inc.が設立され、共同創業者のSytse Sijbrandij（Sid Sijbrandij）がビジネスとして展開
- **一次ソース**: GitLab Wikipedia; GitLab Inc. Wikipedia; GitLab Blog farewell from Dmitriy Zaporozhets
- **URL**: <https://en.wikipedia.org/wiki/GitLab>, <https://about.gitlab.com/blog/a-special-farewell-from-gitlab-dmitriy-zaporozhets/>
- **注意事項**: Zaporozhetsはウクライナのハルキウ在住で、社内のコード共有プラットフォームとして開発を始めた
- **記事での表現**: 「2011年、ウクライナのDmytro ZaporozhetsがGitLabの開発を開始した。GitHubの対抗馬として、オープンソースで自社ホスティング可能なプラットフォームを提供した」

## 5. Bitbucketの設立とAtlassian買収

- **結論**: Bitbucketは2008年7月にJesper Nohrが設立。当初はMercurial（Hg）専用のホスティングサービスだった。2010年9月29日にAtlassianが買収。買収額は非公開。2011年にGitサポートを追加。2015年にAtlassianのStash製品をBitbucket Serverに改名
- **一次ソース**: Bitbucket Wikipedia; TechCrunch, "Atlassian Buys Mercurial Project Hosting Site BitBucket", 2010-09-29
- **URL**: <https://en.wikipedia.org/wiki/Bitbucket>, <https://techcrunch.com/2010/09/29/atlassian-buys-mercurial-project-hosting-site-bitbucket/>
- **注意事項**: BitbucketはもともとMercurial用であり、GitHub（Git用）とは異なるVCSをターゲットとしていた
- **記事での表現**: 「Bitbucketは2008年にMercurial向けホスティングとして設立され、2010年にAtlassianに買収された後、Gitサポートも追加された」

## 6. MicrosoftによるGitHub買収

- **結論**: 2018年6月4日にMicrosoftがGitHubの買収を発表。買収額は75億ドル（Microsoft株式で支払い）。2018年10月26日に買収完了。買収時点でGitHubは2,800万人以上の開発者と8,500万以上のリポジトリを抱えていた。Microsoft VPのNat Friedmanが新CEOに就任、Chris WanstrahはMicrosoftテクニカルフェローとなった
- **一次ソース**: Microsoft News, "Microsoft to acquire GitHub for $7.5 billion", 2018-06-04; Microsoft Blog, "Microsoft completes GitHub acquisition", 2018-10-26
- **URL**: <https://news.microsoft.com/source/2018/06/04/microsoft-to-acquire-github-for-7-5-billion/>, <https://blogs.microsoft.com/blog/2018/10/26/microsoft-completes-github-acquisition/>
- **注意事項**: GitHubは買収後も独立した組織として運営を継続
- **記事での表現**: 「2018年、MicrosoftがGitHubを75億ドルで買収した。買収時点で2,800万人以上の開発者が利用していた」

## 7. GitHub利用統計（2024-2025年）

- **結論**: 2025年時点でGitHubの開発者数は1億5,000万人以上（一部報道では1億8,000万人以上）。2024年にはパブリックおよびプライベートプロジェクトへの貢献が50億以上。リポジトリ数は6億3,000万以上。月間プルリクエストマージ数は平均4,320万。Pythonが2024年にJavaScriptを抜いて最も使用される言語に。インドは2028年までに米国を抜いて最大の開発者人口になると予測
- **一次ソース**: GitHub Octoverse 2024/2025 Report; Kinsta GitHub Statistics; ElectroIQ GitHub Statistics
- **URL**: <https://octoverse.github.com/>, <https://kinsta.com/blog/github-statistics/>, <https://electroiq.com/stats/github-statistics/>
- **注意事項**: 開発者数はアカウント数であり、アクティブユーザー数とは異なる
- **記事での表現**: 「2025年時点でGitHubは1億5,000万人以上の開発者と6億以上のリポジトリを抱える」

## 8. GitHub Actionsの歴史

- **結論**: GitHub Actionsは2018年10月のGitHub Universeカンファレンスで初めて発表された。正式GA（General Availability）は2019年11月13日。Linux、Windows、macOSのホステッドランナーを提供し、マーケットプレイスでプリビルトアクションの共有が可能
- **一次ソース**: TechCrunch, "GitHub launches Actions, its workflow automation tool", 2018-10-16; GitHub Wikipedia (Timeline)
- **URL**: <https://techcrunch.com/2018/10/16/github-launches-actions-its-workflow-automation-tool/>, <https://en.wikipedia.org/wiki/Timeline_of_GitHub>
- **注意事項**: GitHub Actions以前はTravis CI、CircleCI、Jenkinsなどの外部CI/CDサービスが主流だった
- **記事での表現**: 「2018年に発表されたGitHub Actionsは、2019年11月に正式リリースされ、CI/CDをGitHubプラットフォームに統合した」

## 9. SourceForgeの衰退とGitHubの台頭

- **結論**: SourceForge（1999年設立）は2000年代前半にOSSホスティングの中心だった。2008年12月時点でGitHubは約27,000のパブリックリポジトリを保有。SourceForgeは2012年にDice Holdingsに売却され、Windowsダウンロードにアドウェアをバンドルする行為で信頼を失った。2013-2014年頃にGitHubがデファクトスタンダードとなった
- **一次ソース**: blog.gitbutler.com, "Why GitHub Actually Won" (Scott Chacon); Graphite Blog, "How GitHub monopolized code hosting"
- **URL**: <https://blog.gitbutler.com/why-github-actually-won>, <https://graphite.com/blog/github-monopoly-on-code-hosting>
- **注意事項**: Scott Chaconは「タイミングとテイスト」がGitHubの勝因と分析している
- **記事での表現**: 「SourceForgeがアドウェア問題で信頼を失う中、GitHubは開発者体験を重視したアプローチでOSSホスティングのデファクトスタンダードとなった」

## 10. Linuxカーネルのメーリングリストベース開発ワークフロー

- **結論**: Linuxカーネル開発はメーリングリストベースのパッチレビューを維持している。git format-patchでパッチをメール形式のファイルに変換し、git send-emailで送信する。GitHubリポジトリ（torvalds/linux）は読み取り専用のミラーであり、Pull Requestは受け付けていない。理由として、スケーラビリティ（大量のレビュアーへの対応）、オフラインアクセス、クロスサブシステム変更への対応、信頼の段階的構築がある
- **一次ソース**: Linux Kernel Documentation, "Submitting patches"; LWN.net, "Why kernel development still uses email"; LWN.net, "Pulling GitHub into the kernel process"
- **URL**: <https://docs.kernel.org/process/submitting-patches.html>, <https://lwn.net/Articles/702177/>, <https://lwn.net/Articles/860607/>
- **注意事項**: KubernetesプロジェクトがGitHubのPRモデルの限界を示す例として引用される（4,000以上のオープンイシュー、511以上のオープンPR）
- **記事での表現**: 「Linuxカーネルは今なおメーリングリストベースのパッチレビューを採用しており、GitHubのPull Requestモデルとは根本的に異なるワークフローを維持している」

## 11. GitHubの「Social Coding」コンセプト

- **結論**: GitHubは初期のタグラインとして「Social Code Hosting」を使用し、ロゴに「social coding」を表記していた。後に「Build software better, together」「Where software is built」に変更。Scott Chaconによれば、GitHubが勝利した理由は「タイミングとテイスト」——新しいパラダイム（Git/DVCS）の誕生時に、開発者体験を中心に据えたアプローチで臨んだこと
- **一次ソース**: blog.gitbutler.com, "Why GitHub Actually Won" (Scott Chacon); Hacker News discussion
- **URL**: <https://blog.gitbutler.com/why-github-actually-won>, <https://news.ycombinator.com/item?id=33310451>
- **注意事項**: 「open source」という用語自体が1998年に作られたもので、GitHubローンチの2008年時点ではOSSプロジェクトは約18,000件だった（Chaconの言及）
- **記事での表現**: 「GitHubは"Social Coding"をスローガンに掲げ、コードホスティングを社会的活動として再定義した」

## 12. GitHub初期の成長（2009年時点）

- **結論**: 2009年2月24日、GitHubは公開1年目の成果を発表。46,000以上のパブリックリポジトリを保有し、6,200以上のリポジトリが少なくとも1回フォークされ、4,600がマージされた
- **一次ソース**: GitHub Blog (2009年2月の投稿、各種引用で確認)
- **URL**: 直接のURLは確認できなかったが、Wikipedia Timeline of GitHubおよびGitHub history記事で引用
- **注意事項**: 1年で46,000リポジトリという成長は当時としては急速だった
- **記事での表現**: 「ローンチから1年で46,000以上のパブリックリポジトリを集め、6,200以上がフォークされた」
