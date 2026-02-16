# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第19回：GitHubの功罪——ソーシャルコーディングが変えたもの

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- GitHubが2008年の登場からOSSホスティングのデファクトスタンダードとなるまでの経緯と、SourceForgeからの世代交代
- Pull Requestモデルの進化——2008年の原型から、diffコメント（2011年）、Mergeボタン（2011年）への変遷
- メーリングリストベースのパッチレビューとPull Requestモデルの設計思想の違い
- Fork & Pullモデルがオープンソース参加のハードルをどう変えたか
- GitHub Actionsに代表されるCI/CD統合がもたらした「プラットフォームロックイン」の構造
- 「Git = GitHub」という等号が生み出した功罪——民主化と矮小化の両面
- git format-patchとgit send-emailによるメーリングリスト方式のパッチ送付ワークフロー

---

## 1. 「Fork」ボタンを押した日

2009年の終わり頃だったと思う。私はあるOSSライブラリのバグに遭遇し、修正パッチを送りたいと考えていた。それ以前——SourceForge時代——であれば、パッチを書いて、プロジェクトのバグトラッカーにファイルを添付し、メンテナーの返答を待つという手順だった。プロジェクトによってはメーリングリストにパッチを投げることもあった。いずれにせよ、パッチを送るまでの手続きは決して軽いものではなかった。

GitHubでは違った。画面右上の「Fork」ボタンを押す。自分のアカウントにリポジトリのコピーが作られる。ローカルにクローンし、修正し、コミットし、プッシュする。そして「Pull Request」を作成する。それだけだった。

私はその体験に感動した。だが同時に、ある種の違和感も覚えた。この手軽さは素晴らしい。しかし、メーリングリストで行われていた議論の深さ、パッチに添えられた設計意図の説明、メンテナーとの技術的な対話——それらが、ボタン一つの手軽さの裏側で失われはしないか。

あれから15年以上が経った。GitHubは1億5,000万人以上の開発者と6億以上のリポジトリを抱えるプラットフォームに成長した。2024年だけでパブリックおよびプライベートプロジェクトへの貢献は50億以上に達している。OSSへの参加は劇的に容易になった。だが、私のあの違和感は消えていない。

**GitHubはgitを「民主化」したのか、「矮小化」したのか。** 今回は、その問いに向き合う。

---

## 2. GitHubの誕生——タイミングとテイスト

### SourceForge時代の限界

GitHubの歴史を語る前に、それ以前の世界を振り返る必要がある。

1999年に設立されたSourceForgeは、2000年代前半のオープンソース開発において中心的な役割を果たしていた。第5回で触れたように、CVS全盛期のOSS開発はSourceForgeを軸に回っていた。プロジェクトのホスティング、バグトラッカー、メーリングリスト、ダウンロードミラー——SourceForgeは「OSSプロジェクトに必要なものを一か所に集めた」プラットフォームだった。

しかし、SourceForgeにはいくつかの構造的な問題があった。

第一に、バージョン管理への対応が遅れていた。SourceForgeはCVSとSubversionをサポートしていたが、Gitへの対応は後手に回った。分散型VCSの時代が到来しつつある中で、SourceForgeは集中型の世界観にとどまっていた。

第二に、SourceForgeの焦点は「配布」であって「協調開発」ではなかった。プロジェクトページはダウンロード数やリリースファイルを中心に構成されており、開発者同士のインタラクションは二の次だった。GitHubの共同創業者Scott Chaconが後年指摘したように、「SourceForgeにはGitの"G"もなく、ユーザープロフィールへの注力もなく、プライベートリポジトリもなかった」。

第三に、SourceForgeは2012年にDice Holdingsに売却された後、Windowsのダウンロードにアドウェアをバンドルするという行為に手を染め、OSSコミュニティの信頼を決定的に失った。GIMPやnmap、VLCといった著名プロジェクトが次々とSourceForgeから離脱していった。

### 「タイミングとテイスト」

2007年末、Tom Preston-Werner、Chris Wanstrath、PJ Hyettの3人がGitHubの構想を練り始めた。翌2008年2月にプライベートベータを開始し、2008年4月10日に正式ローンチした。Scott Chaconが4人目の共同創業者として加わり、Gitの内部構造に精通する技術的な基盤を提供した。

GitHubが登場した2008年は、絶妙なタイミングだった。Linus TorvaldsがGitを公開したのが2005年。それから3年が経ち、Gitは技術的に成熟しつつあったが、一般の開発者にとっては依然としてハードルが高かった。コマンドラインの複雑さ、ドキュメントの難解さ、そしてホスティングサービスの不在——Gitを使い始めるには、自前でリポジトリをホスティングするか、Gitorious（2007年設立）のような黎明期のサービスを使うしかなかった。

Chaconは後年、GitHubの成功要因を「タイミングとテイスト」と総括している。「タイミング」は、Gitという新しいパラダイムが生まれた直後に参入したこと。「テイスト」は、広告主やCTOに売れるものではなく、開発者自身が使いたいと思うものを作ったこと。GitHubの創業者たちは全員が開発者であり、自分たちの問題を自分たちのために解決した。

2008年12月時点で、GitHubは約27,000のパブリックリポジトリを保有していた。同時期のBitbucket（同じく2008年設立、当初はMercurial専用）は1,000をわずかに超える程度だった。ローンチから1年後の2009年2月には46,000以上のパブリックリポジトリを集め、6,200以上がフォークされ、4,600がマージされた。開発者は明確にGitHubを選んでいた。

### GitHubが変えた「OSS参加の入口」

GitHubの最大の貢献は、OSSへの参加のハードルを劇的に下げたことだ。

SourceForge時代、OSSプロジェクトに貢献するためには以下のステップが必要だった。

まず、プロジェクトのメーリングリストに参加する。次にバグトラッカーで既知の問題を確認する。ソースコードをチェックアウトし、修正を行い、diff形式のパッチファイルを作成する。そのパッチをバグトラッカーに添付するか、メーリングリストに投稿する。メンテナーがパッチを確認し、適用するかどうかを判断する。このプロセスには、メーリングリストの作法を理解し、パッチの形式を正しく整え、メンテナーとのコミュニケーションを成立させるだけの知識と忍耐が必要だった。

GitHubのFork & Pullモデルは、このプロセスを根本的に変えた。Forkボタンを押せば、リポジトリのコピーが自分のアカウントに作られる。そこで自由に変更を加え、Pull Requestを送信する。メンテナーはWebインターフェース上でdiffを確認し、コメントを付け、承認すればMergeボタンを押すだけでマージが完了する。

この変化は数字に表れている。2025年時点でGitHubは1億5,000万人以上の開発者を擁している。2024年だけで1億2,100万以上の新規リポジトリが作成され、月間プルリクエストマージ数は平均4,320万に達している。OSSへの参加が「特別なこと」から「日常的なこと」に変わった。

だが、ここで立ち止まって考えたい。参加のハードルが下がったことは、参加の質が上がったことを意味するだろうか。

---

## 3. Pull Requestモデルの功罪

### Pull Requestの進化

GitHubのPull Request機能は、一夜にして完成したものではない。その進化の過程を追うと、この仕組みの設計思想がより鮮明に見えてくる。

2008年2月、GitHubのベータ版でPull Requestの原型が導入された。当初の機能は極めて限定的で、git request-pullコマンドのGUIラッパーに近いものだった。特定のユーザーに通知を送り、プルすべきリポジトリとHEADコミットをリストし、関連するコミットへのリンクと短いメッセージを添えるだけの機能だった。

ここで注目すべきは、Git自体に最初期からgit request-pullというコマンドが存在していたことだ。Linus TorvaldsはGitの開発初期にgit-pull-scriptを実装し、続いてgit-request-pull-scriptを作成した。このコマンドは変更のサマリーを生成し、メーリングリストに投稿するために設計されていた。GitHubの「Pull Request」は、このGitネイティブの概念をWebインターフェースとして再発明したものだ。

しかし、2008年のPull Requestは現在の姿とは大きく異なっていた。

2011年2月、GitHubはPull RequestのdiffビューにコメントするCVS能を追加した。これにより、コードの特定の行に対してインラインでレビューコメントを付けることが可能になった。メーリングリストでは20年前から行われていた行単位のコードレビューが、ようやくGitHubでも実現した。

2011年4月、Mergeボタンが初めて実装された。それ以前は、Pull Requestを受け取ったメンテナーがローカルで手動マージを実行する必要があった。Mergeボタンの登場により、Webインターフェース上でワンクリックでマージが完了するようになった。

この進化の過程を振り返ると、GitHubのPull Requestモデルは段階的に「完成」していったことがわかる。2008年の原型は通知機能にすぎず、2011年のdiffコメントとMergeボタンの追加によって、現在知られる「コードレビューとマージの統合プラットフォーム」としての形が整った。

### メーリングリスト方式との本質的な違い

Pull Requestモデルの意義を理解するには、それが置き換えた（あるいは置き換えなかった）ワークフロー——メーリングリストベースのパッチレビュー——との違いを把握する必要がある。

Linuxカーネルは、2026年の今日に至るまで、メーリングリストベースのパッチレビューを維持している。GitHubにはtorvalds/linuxリポジトリが存在するが、これは読み取り専用のミラーであり、Pull Requestは受け付けていない。カーネルの開発者はgit format-patchでパッチをメール形式のファイルに変換し、git send-emailでメーリングリストに送信する。

なぜカーネルコミュニティはGitHubのPull Requestモデルを採用しないのか。技術的・組織的な理由が複数ある。

```
メーリングリスト方式とPull Request方式の比較:

  メーリングリスト方式（Linuxカーネル）:
  ┌─────────────────────────────────────────────────┐
  │  開発者                                          │
  │  1. git format-patch でパッチを生成               │
  │  2. git send-email でメーリングリストに送信       │
  │  3. 複数のメーリングリスト・メンテナーにCC可能    │
  │  4. スレッド内でインラインコメント               │
  │  5. メンテナーがローカルでgit amを実行して適用   │
  └─────────────────────────────────────────────────┘
  特徴:
  - 分散的: 単一のプラットフォームに依存しない
  - クロスサブシステム: 複数のメーリングリストに同時送信可能
  - オフライン対応: メールクライアントで完結
  - 透明性: すべてのレビューが公開アーカイブに残る

  Pull Request方式（GitHub）:
  ┌─────────────────────────────────────────────────┐
  │  開発者                                          │
  │  1. リポジトリをFork                              │
  │  2. ブランチで変更してPush                       │
  │  3. Pull Requestを作成（Webインターフェース）     │
  │  4. レビュアーがdiffにコメント                    │
  │  5. Mergeボタンでマージ                          │
  └─────────────────────────────────────────────────┘
  特徴:
  - 集中的: GitHubプラットフォームに依存
  - 視覚的: diffビュー、会話スレッド、ステータスチェック
  - 統合的: CI/CD、コードオーナー、ブランチ保護と連携
  - 手軽: ブラウザで完結する操作
```

第一の違いは、スケーラビリティの方向性だ。メーリングリスト方式は、複数のサブシステムにまたがる変更を自然に扱える。一つのパッチセットを、関連する複数のメーリングリストとメンテナーに同時にCCできる。一方、GitHubのPull Requestは単一のリポジトリに対して作成される。クロスリポジトリの変更を一つの議論としてまとめることは困難だ。

第二の違いは、プラットフォーム依存性だ。メーリングリスト方式は、特定のプラットフォームに依存しない。メールクライアントがあればどこでも動作し、アーカイブは複数のサイト（lore.kernel.org等）に分散保存される。Pull Request方式はGitHubのサービスに依存する。GitHubがダウンすれば、レビューは停止する。

第三の違いは、レビューの文化だ。メーリングリストでは、パッチに添えるカバーレターで設計意図を詳述する文化がある。なぜこの変更が必要なのか、どのような代替案を検討したのか、どのようなテストを行ったのか。この文脈情報が、パッチそのものと一体として議論される。Pull Requestでもdescriptionを書くことはできるが、実際にはPull Requestのタイトルと数行の説明だけで送られることが少なくない。

しかし、公平に言えば、Pull Requestモデルがメーリングリスト方式に劣るわけではない。優れている点も明確にある。

Pull Requestの視覚的なdiffビューは、変更の全体像を把握しやすい。ステータスチェック（CI/CD）との統合により、コードが自動テストを通過したかどうかが一目でわかる。コードオーナーの自動割り当てにより、適切なレビュアーが自動的に通知される。ブランチ保護ルールにより、必要なレビュー数やCIの通過を強制できる。これらの機能は、メーリングリスト方式では外部ツールとの組み合わせでしか実現できない。

重要なのは、Pull RequestモデルとメーリングリストGitst方式は、異なる問題を解いているということだ。Linuxカーネルのような巨大で階層的なプロジェクトには、メーリングリスト方式の分散性と柔軟性が適している。中小規模のプロジェクトには、Pull Requestモデルの手軽さと視覚性が適している。「どちらが優れているか」ではなく、「どの文脈で何が適切か」を問うべきだ。

### Fork & Pullモデルの設計思想

Fork & Pullモデルについて、もう少し踏み込んで考える。

Gitは分散型バージョン管理システムだ。全てのクローンがリポジトリの完全なコピーであり、原理的には対等だ。「中央リポジトリ」は慣習として存在するが、Gitの設計上は特権的な地位を持たない。第12回で論じた分散型VCSの思想そのものだ。

GitHubのFork & Pullモデルは、この分散型の原理を巧みにWebインターフェースに落とし込んだ。Forkは「分散型VCSにおけるリポジトリの複製」というGitの根本機能を、ワンクリックで実現する。Pull Requestは「複製されたリポジトリからの変更の取り込み要求」というGitの概念を、可視化された形で提供する。

だが、Fork & Pullモデルには微妙な逆説がある。分散型VCSの原理をWebインターフェースに載せた結果、運用は事実上「集中型」になった。全てのForkはGitHub上に存在し、全てのPull RequestはGitHub上で処理される。Gitが「中央のない世界」を志向したのに対し、GitHubはGitの上に「新たな中央」を構築した。

この逆説は、必ずしも悪いことではない。分散型VCSの「対等なリポジトリ」という概念は、理念としては美しいが、実際のOSS開発では「どのリポジトリが正統か」という合意が必要だ。GitHubは、originリポジトリ（上流）とFork（下流）の関係を視覚的に明確にし、「正統」の所在を一目で理解できるようにした。

しかし、この「中央化」がGitHubへのプラットフォーム依存を生んだことも事実だ。多くの開発者にとって、Gitのリモート操作は「GitHubの操作」と同義になった。git pushはGitHubにプッシュすることであり、git cloneはGitHubからクローンすることだ。Gitが提供する分散型の可能性——複数のリモートを持つ、自前のサーバにホスティングする、メーリングリストでパッチを交換する——は、多くの開発者の視野から消えた。

---

## 4. 「Git = GitHub」という等号の危うさ

### プラットフォームロックイン

GitHubの急成長に伴い、GitHubは事実上のインフラとなった。この「インフラ化」は、開発エコシステム全体に深い影響を与えている。

2010年9月にAtlassianに買収されたBitbucket（2008年設立、当初Mercurial専用）は、Gitサポートを追加して対抗したが、GitHubの優位を覆すには至らなかった。2011年にウクライナのDmytro ZaporozhetsがGitLabの開発を開始し、自社ホスティング可能なオープンソースの代替プラットフォームを提供した。GitLab Inc.は2014年に設立され、CI/CD機能の統合でGitHubとは異なる価値を打ち出した。

しかし、OSSコミュニティにおけるGitHubの支配的地位は揺るがなかった。2018年6月4日、MicrosoftがGitHubを75億ドルで買収すると発表した（2018年10月26日に完了）。買収時点でGitHubは2,800万人以上の開発者と8,500万以上のリポジトリを抱えていた。一部の開発者はMicrosoftのOSSに対する歴史的な姿勢を懸念し、GitLabへの移行を検討した。だが、大規模な流出は起きなかった。GitHubは「代替困難なインフラ」になっていたのだ。

GitHubがインフラとなった結果、何が起きたか。

第一に、プロジェクトのアイデンティティがGitHub上のURLと結びついた。`github.com/organization/project`というURLが、プロジェクトの「住所」になった。READMEのバッジ、Issueのリンク、Pull Requestの参照——あらゆるものがGitHubのURLに紐づいている。プロジェクトを別のプラットフォームに移行することは、住所変更の通知と同じ困難さを伴う。

第二に、GitHub固有の機能への依存が深まった。GitHub Issues、GitHub Projects、GitHub Wiki、GitHub Pages、GitHub Packages——これらはGitのプロトコルとは無関係の、GitHub独自のサービスだ。プロジェクトがこれらの機能を使い込むほど、プラットフォーム移行のコストは増大する。

第三に、CI/CDパイプラインがGitHubに統合された。

### GitHub ActionsとCI/CDの統合

2018年10月のGitHub Universeカンファレンスで発表されたGitHub Actionsは、2019年11月13日に正式リリースされた。ワークフローの自動化ツールとして登場し、CI/CDをGitHubプラットフォームに統合した。

GitHub Actions以前、CI/CDの世界はGitHubとは独立していた。Travis CI、CircleCI、Jenkinsといった外部サービスやツールが、GitHubのWebhookを利用してGitのイベント（プッシュ、Pull Request）に反応し、ビルドとテストを実行していた。CI/CDはGitHubの「外」にあった。

GitHub Actionsは、この関係を逆転させた。CI/CDがGitHubの「中」に入った。ワークフロー定義ファイル（`.github/workflows/`）がリポジトリの一部となり、GitHubのイベントに直接反応し、GitHubが提供するランナー（Linux、Windows、macOS）上で実行される。マーケットプレイスでプリビルトアクションを共有でき、複雑なパイプラインを数十行のYAMLで構成できる。

この統合は便利だ。だが、その便利さの裏側にあるものを認識しておくべきだ。

`.github/workflows/`に書かれたCI/CDパイプラインは、GitHubでしか動作しない。GitLab CI/CD（`.gitlab-ci.yml`）やCircleCI（`.circleci/config.yml`）には、それぞれ異なる構文と異なる実行環境がある。プラットフォームを移行する際、CI/CDパイプラインの書き直しは大きなコストとなる。

```
CI/CDプラットフォーム依存の構造:

  GitHub Actions (.github/workflows/ci.yml):
  ┌────────────────────────────────────────┐
  │ on: [push, pull_request]               │
  │ jobs:                                   │
  │   test:                                 │
  │     runs-on: ubuntu-latest             │
  │     steps:                              │
  │       - uses: actions/checkout@v4      │
  │       - uses: actions/setup-node@v4    │  ← GitHubマーケットプレイス
  │       - run: npm test                  │
  └────────────────────────────────────────┘
  → GitHubでのみ動作

  GitLab CI (.gitlab-ci.yml):
  ┌────────────────────────────────────────┐
  │ stages:                                 │
  │   - test                                │
  │ test:                                   │
  │   image: node:20                       │
  │   script:                               │
  │     - npm test                         │
  └────────────────────────────────────────┘
  → GitLabでのみ動作

  → 「Gitの操作」はポータブルだが
    「CI/CDの操作」はプラットフォーム固有
```

これが意味するのは、「Git = GitHub」という等号が、Gitの層だけでなく、CI/CDの層でも固定化されているということだ。プロジェクトのバージョン管理（Git）はポータブルだが、プロジェクトの自動化（CI/CD）はGitHubにロックインされる。そしてCI/CDは、現代のソフトウェア開発において省略不可能な要素だ。

### 民主化と矮小化

ここで、冒頭の問いに立ち返る。GitHubはgitを「民主化」したのか、「矮小化」したのか。

民主化の側面は明白だ。GitHubは、OSSへの参加のハードルを劇的に下げた。Fork & Pullモデルにより、初めてのコントリビューターでもボタン数回でパッチを送れるようになった。プロジェクトの発見可能性が向上し、トレンドやスターシステムを通じて優れたプロジェクトが可視化された。「Social Coding」というGitHubのスローガンは、コーディングを社会的な活動として再定義した。開発者のプロフィールページは、コントリビューション履歴を可視化し、一種の技術的履歴書として機能するようになった。

矮小化の側面もまた、認識すべきだ。

Gitは分散型バージョン管理システムとして設計された。全てのクローンが対等であり、中央サーバなしで動作する。メーリングリストでパッチを交換し、複数のリモートリポジトリを自在に扱い、ネットワークなしでもコミットやブランチ操作ができる。これがGitの本来の姿だ。

しかし、GitHubが「Git = GitHub」という等式を定着させた結果、多くの開発者にとってGitの能力はGitHubが提供する機能の範囲に矮小化された。git format-patchやgit send-emailを使ったことのある開発者はどれだけいるだろうか。git remoteで複数のリモートを管理した経験のある開発者は。自前のGitサーバをホスティングした経験は。

GitHubがgitのUI層を担うこと自体は悪いことではない。問題は、UI層がGitの可能性を覆い隠し、GitHubが提供しない機能は「存在しない」かのように振る舞うことだ。

私は2010年代後半に、若手エンジニアから「git pushしたのにGitHubに反映されない」という相談を受けたことがある。原因は、pushの宛先がGitHubではなく、別のリモートリポジトリに設定されていたことだった。その若手は、git pushの宛先がGitHub以外でありうることを、そもそも想像していなかった。

これは個人の問題ではなく、構造の問題だ。GitHubが提供するUIと体験が、Gitの全体像を覆い隠している。Gitは本来、プラットフォームに依存しないツールだ。しかし、多くの開発者にとって、Gitはもはや「GitHubを使うためのコマンドラインツール」に成り下がっている。

---

## 5. GitHubの競争と多元化

### GitLabとBitbucket——対抗馬たちの存在意義

GitHubの一強体制に対して、代替プラットフォームは異なる価値を提供してきた。

GitLabは、2011年にDmytro Zaporozhetsがウクライナで開発を開始した。Zaporozhetsは当時勤務していた企業で、チームのためのコード共有プラットフォームを必要としていたが、既存の選択肢は高価すぎると判断し、自前で構築した。GitLabの最大の差別化要因は二つある。一つはオープンソースであり、自社サーバにインストールして運用できること。もう一つは、CI/CDをプラットフォームに早い段階で統合したことだ。GitLab CI/CDは`.gitlab-ci.yml`で定義され、GitLabのインフラストラクチャの中核を成している。

Bitbucketは2008年7月にJesper Nohrが設立した。当初はMercurial専用のホスティングサービスだった。2010年9月29日にAtlassianに買収され、その後Gitサポートが追加された。BitbucketはJira、Confluence、Trelloといった Atlassianの開発ツールスイートとの統合が強みであり、企業向けの開発ワークフローでは一定のシェアを維持している。

これらの代替プラットフォームの存在は、「Git = GitHub」という等号に疑問を投げかける。Gitはプロトコルであり、データモデルであり、コマンドラインツールだ。GitHubはGitのホスティングサービスの一つにすぎない。GitLabでもBitbucketでも、あるいは自前のGitサーバでも、Gitの全機能は同じように動作する。

### Gitが本来持つポータビリティ

ここで強調すべきことがある。Gitのリポジトリは、原理的にはどのホスティングサービスにも移行可能だ。

```bash
# GitHubからGitLabへのリポジトリ移行（基本的な操作）
git clone --mirror https://github.com/org/project.git
cd project.git
git remote set-url origin https://gitlab.com/org/project.git
git push --mirror
```

リポジトリの全履歴、全ブランチ、全タグが、数コマンドで別のプラットフォームに移行できる。これはGitの分散型アーキテクチャがもたらす本質的な利点だ。SubversionやCVSでは、リポジトリの移行はサーバ管理者の仕事であり、開発者が自律的に行えるものではなかった。

だが、前述のとおり、Gitのリポジトリだけを移行しても、Issue、Pull Request、Wiki、CI/CDパイプライン、GitHub Pagesのデプロイ設定は移行されない。プラットフォームの「付加価値」がロックインの源泉になっている。

Gitのポータビリティと、GitHubのロックインは、異なる層の話だ。Gitの層では自由だが、GitHub固有サービスの層では拘束される。この二層構造を理解することが、「Git = GitHub」の等号を解体する第一歩だ。

---

## 6. ハンズオン：メーリングリスト方式のパッチ送付を体験する

GitHubのPull Requestモデルに慣れた開発者にとって、メーリングリスト方式のパッチ送付は「別世界」に感じるかもしれない。だが、Gitにはこのワークフローのための専用コマンドが最初期から組み込まれている。このハンズオンでは、git format-patchとgit amを使って、メーリングリスト方式のパッチ交換を体験する。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y git
```

### 演習1：git format-patchでパッチファイルを生成する

```bash
WORKDIR="${HOME}/vcs-handson-19"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=== 演習1: git format-patchでパッチファイルを生成する ==="
echo ""

# gitの設定
git config --global user.email "maintainer@example.com"
git config --global user.name "Maintainer"
git config --global init.defaultBranch main

# 「上流」リポジトリを作成（メンテナーのリポジトリ）
git init --quiet upstream-project
cd upstream-project

# 初期コミット
cat > calculator.py << 'PYEOF'
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

if __name__ == "__main__":
    print(f"1 + 2 = {add(1, 2)}")
    print(f"5 - 3 = {subtract(5, 3)}")
PYEOF
git add calculator.py
git commit --quiet -m "Initial commit: basic calculator with add and subtract"

echo "--- 上流リポジトリを作成 ---"
git log --oneline
echo ""

# 「貢献者」のクローンを作成
cd "${WORKDIR}"
git clone --quiet upstream-project contributor-fork
cd contributor-fork
git config user.email "contributor@example.com"
git config user.name "Contributor"

# 貢献者が機能を追加（2つのコミット）
cat > calculator.py << 'PYEOF'
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

def multiply(a, b):
    return a * b

if __name__ == "__main__":
    print(f"1 + 2 = {add(1, 2)}")
    print(f"5 - 3 = {subtract(5, 3)}")
    print(f"4 * 3 = {multiply(4, 3)}")
PYEOF
git add calculator.py
git commit --quiet -m "Add multiply function

Implement multiplication as a new arithmetic operation.
This completes the basic four arithmetic operations (part 1 of 2)."

cat > calculator.py << 'PYEOF'
def add(a, b):
    return a + b

def subtract(a, b):
    return a - b

def multiply(a, b):
    return a * b

def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

if __name__ == "__main__":
    print(f"1 + 2 = {add(1, 2)}")
    print(f"5 - 3 = {subtract(5, 3)}")
    print(f"4 * 3 = {multiply(4, 3)}")
    print(f"10 / 3 = {divide(10, 3)}")
PYEOF
git add calculator.py
git commit --quiet -m "Add divide function with zero-division guard

Implement division with explicit zero-division error handling.
This completes the basic four arithmetic operations (part 2 of 2)."

echo "--- 貢献者のコミット履歴 ---"
git log --oneline
echo ""

# git format-patch でパッチファイルを生成
echo "--- git format-patch でパッチファイルを生成 ---"
git format-patch origin/main --output-directory "${WORKDIR}/patches"
echo ""

echo "生成されたパッチファイル:"
ls -la "${WORKDIR}/patches/"
echo ""

echo "--- パッチファイルの内容（1つ目）---"
cat "${WORKDIR}/patches/0001-Add-multiply-function.patch"
echo ""
echo "-> パッチファイルはメールのRFC 2822形式で生成される"
echo "   From, Date, Subject, メッセージ本文、そしてdiffが含まれる"
echo "   これをそのままメーリングリストに送信できる"
```

### 演習2：git amでパッチを適用する

```bash
echo ""
echo "=== 演習2: git amでパッチを適用する ==="
echo ""

# メンテナー側でパッチを適用
cd "${WORKDIR}/upstream-project"

echo "--- 適用前のコミット履歴 ---"
git log --oneline
echo ""

echo "--- パッチを適用（git am）---"
git am "${WORKDIR}/patches/"*.patch
echo ""

echo "--- 適用後のコミット履歴 ---"
git log --oneline
echo ""

echo "--- 適用後のファイル内容 ---"
cat calculator.py
echo ""

echo "-> git am はパッチのメタデータ（著者、日時、コミットメッセージ）を"
echo "   そのまま保持してコミットを作成する"
echo "   Author は貢献者のまま維持される:"
git log --format="%h %an <%ae> %s" -2
```

### 演習3：カバーレターを付けたパッチセット

```bash
echo ""
echo "=== 演習3: カバーレターを付けたパッチセットを生成する ==="
echo ""

cd "${WORKDIR}/contributor-fork"

# カバーレター付きでパッチを再生成
git format-patch origin/main \
  --cover-letter \
  --output-directory "${WORKDIR}/patches-with-cover"

echo "--- カバーレター付きのパッチファイル ---"
ls -la "${WORKDIR}/patches-with-cover/"
echo ""

echo "--- カバーレターの内容 ---"
cat "${WORKDIR}/patches-with-cover/0000-cover-letter.patch"
echo ""
echo "-> カバーレター（0000-cover-letter.patch）はパッチセット全体の"
echo "   概要を説明するためのものである"
echo "   *** SUBJECT HERE *** と *** BLURB HERE *** を"
echo "   実際の説明に置き換えてからメーリングリストに送信する"
echo ""
echo "   Linuxカーネル開発では、カバーレターに以下を記載する:"
echo "   - パッチセットの目的と設計意図"
echo "   - 代替案の検討内容"
echo "   - テスト方法と結果"
echo "   - 前回のバージョンからの変更点（v2, v3...）"
```

### 演習4：Pull Requestモデルとの比較

```bash
echo ""
echo "=== 演習4: Pull Request方式との操作フロー比較 ==="
echo ""

cd "${WORKDIR}"

echo "--- メーリングリスト方式のワークフロー ---"
echo "  1. git clone <upstream>           # リポジトリをクローン"
echo "  2. git checkout -b feature        # ブランチを作成"
echo "  3. （コードを変更してコミット）"
echo "  4. git format-patch main          # パッチファイルを生成"
echo "  5. git send-email *.patch         # メーリングリストに送信"
echo "  6. （レビュー: メール上でインラインコメント）"
echo "  7. メンテナー: git am *.patch     # パッチを適用"
echo ""
echo "--- Pull Request方式のワークフロー ---"
echo "  1. Fork（Webブラウザ）             # リポジトリをフォーク"
echo "  2. git clone <fork>               # フォークをクローン"
echo "  3. git checkout -b feature        # ブランチを作成"
echo "  4. （コードを変更してコミット）"
echo "  5. git push origin feature        # フォークにプッシュ"
echo "  6. Pull Request作成（Webブラウザ） # PRを作成"
echo "  7. （レビュー: Web上でdiffコメント）"
echo "  8. Mergeボタン（Webブラウザ）      # マージ"
echo ""

# パッチのサイズを確認
echo "--- パッチファイルのサイズ（メーリングリスト方式）---"
du -sh "${WORKDIR}/patches/"
echo "-> パッチはテキストファイルとしてメールに添付される"
echo "   ネットワーク接続が不安定な環境でも扱える"
echo ""
echo "--- 比較のまとめ ---"
echo "メーリングリスト方式:"
echo "  + プラットフォーム非依存（メールがあれば動作する）"
echo "  + オフラインでパッチの作成・レビューが可能"
echo "  + パッチセットとカバーレターで設計意図を構造的に伝達"
echo "  - 学習コストが高い（メールの作法、パッチ形式の理解）"
echo "  - 視覚的なdiffビューがない（テキストベース）"
echo ""
echo "Pull Request方式:"
echo "  + 視覚的で直感的なインターフェース"
echo "  + CI/CD統合、コードオーナー自動割り当て"
echo "  + 初心者でも参加しやすい"
echo "  - プラットフォーム依存（GitHubがダウンすると停止）"
echo "  - Gitの分散型の利点を一部犠牲にしている"
```

### 演習で見えたこと

四つの演習を通じて、GitHubのPull Requestモデルが置き換えた（あるいは補完した）ワークフローを体験した。

演習1では、git format-patchがコミットをRFC 2822形式のメールファイルに変換する仕組みを確認した。パッチファイルには著者情報、日時、コミットメッセージ、そしてdiffの全てが含まれており、メーリングリストに直接送信可能な形式だ。

演習2では、git amがパッチファイルからコミットを再構築し、著者情報を保持したままリポジトリに適用する動作を確認した。メンテナーは受け取ったパッチを検証し、適用するかどうかを判断できる。

演習3では、カバーレター（0000-cover-letter.patch）の存在を確認した。カバーレターはパッチセット全体の設計意図を説明する文書であり、Linuxカーネル開発では不可欠な要素だ。Pull Requestのdescriptionに相当するが、より構造的で詳細な記述が文化として根づいている。

演習4では、メーリングリスト方式とPull Request方式のワークフローを並べて比較した。どちらにも明確な利点と欠点があり、「どちらが優れているか」ではなく「どの文脈で何が適切か」が重要であることを確認した。

---

## 7. まとめと次回予告

### この回の要点

第一に、GitHubは2008年4月の正式ローンチ以来、OSSホスティングのデファクトスタンダードとなった。SourceForgeからの世代交代は、Gitという新しいパラダイムの誕生と、開発者体験を中心に据えた設計（共同創業者Scott Chaconの言う「タイミングとテイスト」）によって実現された。2025年時点で1億5,000万人以上の開発者と6億以上のリポジトリを擁し、その規模は他のプラットフォームを圧倒している。

第二に、Pull Requestモデルは一夜にして完成したものではない。2008年の通知機能から始まり、2011年のdiffコメントとMergeボタンの追加を経て、現在の「コードレビューとマージの統合プラットフォーム」に進化した。Git自体に最初期から存在したgit request-pullの概念をWebインターフェースとして再発明したものだ。

第三に、GitHubのFork & Pullモデルは、OSSへの参加のハードルを劇的に下げた。しかし同時に、Gitの分散型設計の上に「新たな中央」を構築し、「Git = GitHub」という等号を定着させた。多くの開発者にとって、Gitの能力はGitHubが提供する機能の範囲に矮小化されている。

第四に、GitHub Actions（2018年発表、2019年11月正式リリース）に代表されるCI/CD統合は、開発ワークフローのGitHub依存を深化させた。Gitのリポジトリは原理的にポータブルだが、CI/CDパイプラインはプラットフォーム固有であり、移行コストが高い。Gitの層とGitHub固有サービスの層は区別して理解する必要がある。

第五に、メーリングリストベースのパッチレビューは、GitHubのPull Requestモデルとは異なる設計思想を持つ。Linuxカーネルが今なおメーリングリスト方式を維持している理由は、スケーラビリティ、プラットフォーム非依存性、クロスサブシステム対応などの技術的要件に基づいている。両方式は「異なる問題を解いている」のであり、一方が他方に優越するものではない。

### 冒頭の問いへの暫定回答

GitHubはgitを「民主化」したのか、「矮小化」したのか。

答えは「両方」だ。そして、この二つは矛盾しない。

GitHubはOSSへの参加を民主化した。Fork & Pullモデルにより、誰でもOSSプロジェクトに貢献できるようになった。プロジェクトの発見可能性が飛躍的に向上し、OSSコミュニティの規模は爆発的に拡大した。これは紛れもない功績だ。

同時に、GitHubは「Git = GitHub」という等号を通じて、Gitの可能性を矮小化した。Gitが本来持つ分散型の柔軟性——複数のリモート、メーリングリストでのパッチ交換、プラットフォーム非依存の運用——は、多くの開発者の視野から消えた。GitHubが提供しない機能は、事実上「存在しない」ものとして扱われるようになった。

重要なのは、この構造を自覚することだ。GitHubを使うこと自体は何も悪くない。GitHubは優れたプラットフォームであり、OSSエコシステムに計り知れない貢献をしてきた。だが、GitHubが「全て」ではないことを知っておくべきだ。GitHubがなくなったとしても、Gitは動く。リポジトリは移行できる。パッチはメールで送れる。Gitは、GitHubより前に存在し、GitHubがなくなった後も存在し続けるだろう。

ツールを使いこなすためには、ツールの外側を知る必要がある。GitHubを真に活用するためには、GitHubの外側——Gitそのものの設計思想と、GitHubが登場する以前のワークフロー——を理解しておくことが、エンジニアとしての視野を広げる。

### 次回予告

**第20回「CI/CDとgitの密結合——インフラがVCSを前提とする時代」**

次回は、GitHubのエコシステムからさらに視野を広げ、gitがインフラの「前提条件」になった時代を考える。GitOps（Weaveworks、2017年）の思想は、Gitリポジトリを「Single Source of Truth」とし、インフラの宣言的な状態管理をgit commitとgit revertで実現する。Jenkins、Travis CI、GitHub Actions、ArgoCD——CI/CDツールの変遷は、gitとインフラの関係がどう深化してきたかを物語る。IaC（Infrastructure as Code）の現場で私が見てきたのは、CDK、Terraform、CloudFormation——あらゆるものがGitリポジトリに収束していく現実だ。

gitが「開発ツール」を超えて「インフラの基盤」になったとき、何が起きるのか。そして、その密結合には、どのようなリスクが潜んでいるのか。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- GitHub, "About pull requests." GitHub Docs. <https://docs.github.com/articles/about-pull-requests>
- GitHub, "Octoverse 2024/2025 Report." <https://octoverse.github.com/>
- Chacon, S., "Why GitHub Actually Won." Butler's Log, 2024. <https://blog.gitbutler.com/why-github-actually-won>
- rdnlsmith, "A Brief History of the Pull Request." 2023. <https://rdnlsmith.com/posts/2023/004/pull-request-origins/>
- Microsoft, "Microsoft to acquire GitHub for $7.5 billion." Microsoft News, 2018-06-04. <https://news.microsoft.com/source/2018/06/04/microsoft-to-acquire-github-for-7-5-billion/>
- Microsoft, "Microsoft completes GitHub acquisition." The Official Microsoft Blog, 2018-10-26. <https://blogs.microsoft.com/blog/2018/10/26/microsoft-completes-github-acquisition/>
- TechCrunch, "GitHub launches Actions, its workflow automation tool." 2018-10-16. <https://techcrunch.com/2018/10/16/github-launches-actions-its-workflow-automation-tool/>
- TechCrunch, "Atlassian Buys Mercurial Project Hosting Site BitBucket." 2010-09-29. <https://techcrunch.com/2010/09/29/atlassian-buys-mercurial-project-hosting-site-bitbucket/>
- GitLab, "A special farewell from GitLab's Dmitriy Zaporozhets." <https://about.gitlab.com/blog/a-special-farewell-from-gitlab-dmitriy-zaporozhets/>
- The Linux Kernel documentation, "Submitting patches: the essential guide to getting your code into the kernel." <https://docs.kernel.org/process/submitting-patches.html>
- LWN.net, "Why kernel development still uses email." 2016. <https://lwn.net/Articles/702177/>
- LWN.net, "Pulling GitHub into the kernel process." 2021. <https://lwn.net/Articles/860607/>
- Graphite, "How GitHub monopolized code hosting." <https://graphite.com/blog/github-monopoly-on-code-hosting>
- Git SCM, "git-request-pull Documentation." <https://git-scm.com/docs/git-request-pull>
- Git SCM, "git-format-patch Documentation." <https://git-scm.com/docs/git-format-patch>
- Git SCM, "git-send-email Documentation." <https://git-scm.com/docs/git-send-email>
- Wikipedia, "GitHub." <https://en.wikipedia.org/wiki/GitHub>
- Wikipedia, "GitLab." <https://en.wikipedia.org/wiki/GitLab>
- Wikipedia, "Bitbucket." <https://en.wikipedia.org/wiki/Bitbucket>
