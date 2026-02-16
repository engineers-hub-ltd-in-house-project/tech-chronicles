# ファクトチェック記録：第14回「Linus Torvaldsの決断——Gitの誕生（2005年4月）」

調査日: 2026-02-16

---

## 1. git開発開始日とLKML投稿

- **結論**: Linus Torvaldsは2005年4月3日にgitの開発を開始した。4月6日にLKMLに「Kernel SCM saga...」の件名でメールを投稿し、BitKeeperからの離脱と代替SCMの検討を公表した。4月7日にgitの最初のコミット（self-hosting達成）を行った。
- **一次ソース**: Torvalds, L., "Kernel SCM saga..." LKML, 2005-04-06; git/git リポジトリの最初のコミット e83c5163316f89bfbde7d9ab23ca2e25604af290
- **URL**: <https://lkml.org/lkml/2005/4/6/121>, <https://github.com/git/git/commit/e83c5163316f89bfbde7d9ab23ca2e25604af290>
- **注意事項**: 「開発開始」は4月3日（2.6.12-rc2リリース日と同日）、「最初のコミット」は4月7日、「LKML投稿」は4月6日。これらの日付を混同しないこと
- **記事での表現**: 「2005年4月3日、Torvaldsはgitの開発を開始した。4月6日にLKMLへ『Kernel SCM saga...』を投稿。4月7日に最初のコミットを行い、self-hostingを達成した」

## 2. 「10日間で原型完成」の真偽

- **結論**: 4月3日の開発開始から約10日間で、gitはLinuxカーネルのソースツリーを管理できる状態に達した。ただし、4月7日にself-hosting（git自身のソースコードをgitで管理）を達成しており、最小限の原型は4-5日で完成。Torvalds自身は「4ヶ月間の精神的な準備期間があった」と述べている
- **一次ソース**: Wikipedia "Git"; GitLab "Journey through Git's 20-year history"; git-tower.com "Celebrating 20 Years of Git"
- **URL**: <https://en.wikipedia.org/wiki/Git>, <https://about.gitlab.com/blog/journey-through-gits-20-year-history/>, <https://www.git-tower.com/blog/git-turns-20>
- **注意事項**: 「10日間」はよく引用されるが、正確にはself-hostingまでが4日、カーネル管理開始（4月16日）までが13日。「10日間」は概数として定着している
- **記事での表現**: 正確なマイルストーンを示しつつ、「10日間」が概数であることを明記する

## 3. Linusの設計要件

- **結論**: Torvaldsの設計要件は主に3つ: (1) 分散型（BitKeeperライクなワークフロー）、(2) 高速性（日常操作は1秒以内）、(3) データ完全性（SHA-1によるチェックサム）。さらに非線形開発（大規模ブランチ/マージ）のサポートが要件に含まれる
- **一次ソース**: git-scm.com "A Short History of Git"; Torvalds, L., Google Tech Talk on Git (2007-05-03); Wikipedia "Git"
- **URL**: <https://git-scm.com/book/en/v2/Getting-Started-A-Short-History-of-Git>, <https://en.wikipedia.org/wiki/Git>
- **注意事項**: Torvaldsは2005年のInfoWorldインタビューで「日常操作は1秒以内」と述べた。2007年のGoogle Tech Talkでは設計思想をより詳細に語っている
- **記事での表現**: 3つの要件を明確に区分して記述し、各要件の根拠（BitKeeperでの経験、カーネル開発の規模）を説明する

## 4. 既存DVCS（Monotone, Darcs等）を選ばなかった理由

- **結論**: TorvaldsはMonotoneに言及し「If you must, start reading up on 'monotone'」と推奨しつつも、性能が不十分と判断した。MonotoneはSQLiteベースの「real database」を使い「nice C++ abstractions」を持つが、Torvaldsはそれが「horrible and unmaintainable mess」を生むと批判した。Darcsはパフォーマンス問題（パッチ理論に基づくマージの計算量）があった。GNU archは使い勝手に問題があった
- **一次ソース**: Torvalds, L., "Re: Kernel SCM saga.." LKML, 2005-04-07; Wikipedia "Monotone (software)"; Linux Journal "A Git Origin Story"
- **URL**: <https://lkml.org/lkml/2005/4/7/150>, <https://en.wikipedia.org/wiki/Monotone_(software)>, <https://www.linuxjournal.com/content/git-origin-story>
- **注意事項**: TorvaldsはMonotoneの設計思想には一定の評価を示しており、gitの設計にMonotoneのアイデアを一部取り入れている（SHA-1ハッシュ、コンテンツアドレッシング等）。全否定ではない
- **記事での表現**: Monotoneへの評価と批判の両面を記述し、性能要件がカーネル規模では致命的だった点を強調する

## 5. SHA-1による内容アドレス可能ストレージの設計思想

- **結論**: gitのオブジェクトデータベースは内容アドレス可能（content-addressable）ストレージ。すべてのオブジェクトはSHA-1ハッシュで識別される。Torvaldsは「ファイルシステムの人間」としての視点からgitを設計した。SHA-1は主にデータ破損検出のためであり、暗号学的セキュリティは「偶然の副産物」とTorvaldsは述べた
- **一次ソース**: Torvalds, L., Google Tech Talk (2007); git初期README; Wikipedia "Git"
- **URL**: <https://git.wiki.kernel.org/index.php/LinusTalk200705Transcript>, <https://en.wikipedia.org/wiki/Git>
- **注意事項**: SHA-1からSHA-256への移行は現在進行中（Git 2.29以降でオプション対応）。記事執筆時点（2026年）の状況も併記する
- **記事での表現**: 「gitはバージョン管理ツールではなく、コンテンツアドレッサブルファイルシステムとして設計された」という点を強調

## 6. git初期コマンド体系

- **結論**: gitの最初のコミット（e83c5163）は10個のファイル、約1,000行のCコード。初期コマンドは7つ: init-db（リポジトリ初期化）、update-cache（インデックス更新）、write-tree（ツリーオブジェクト書き出し）、commit-tree（コミットオブジェクト作成）、cat-file（オブジェクト内容表示）、read-tree（ツリー読み込み）、show-diff（差分表示）
- **一次ソース**: Atlassian Blog "What Can We Learn from the Code in Git's Initial Commit?"; GitLab "Journey through Git's 20-year history"
- **URL**: <https://www.atlassian.com/blog/bitbucket/what-can-we-learn-from-the-code-in-gits-initial-commit>, <https://about.gitlab.com/blog/journey-through-gits-20-year-history/>
- **注意事項**: 初期のcat-fileは内容を直接表示せず、一時ファイルに書き出していた
- **記事での表現**: 7つのコマンドとその役割を表形式で整理し、現在のgitコマンドとの対応を示す

## 7. Junio Hamanoのメンテナ就任

- **結論**: 2005年7月26日、Linus TorvaldsはJunio Hamanoをgitプロジェクトの新しいメンテナに任命した。TorvaldsはHamanoを「obvious choice」と評した。Hamanoはgitの最初のコミットから約1週間後にプロジェクトに参加し、git 0.99リリース時点で数百のコミットを行っていた
- **一次ソース**: Wikipedia "Git"; GitLab "Journey through Git's 20-year history"; Simple Wikipedia "Junio Hamano"
- **URL**: <https://en.wikipedia.org/wiki/Git>, <https://about.gitlab.com/blog/journey-through-gits-20-year-history/>, <https://simple.wikipedia.org/wiki/Junio_Hamano>
- **注意事項**: HamanoはCalifornia在住、Google勤務。2026年現在もgitのメンテナを務めている
- **記事での表現**: Torvaldsからのメンテナ移譲を、gitがLinusの個人プロジェクトからコミュニティプロジェクトへ移行した転換点として描く

## 8. git v1.0リリース

- **結論**: git v1.0は2005年12月21日にJunio Hamanoのもとでリリースされた。v0.99からv1.0までに34回のリリース（0.99.1〜0.99.7, 0.99.7a〜0.99.7d, 0.99.8〜0.99.8g, 0.99.9〜0.99.9n）が行われた
- **一次ソース**: Wikipedia "Git"; GitLab "Journey through Git's 20-year history"
- **URL**: <https://en.wikipedia.org/wiki/Git>, <https://about.gitlab.com/blog/journey-through-gits-20-year-history/>
- **注意事項**: 開発開始（4月3日）からv1.0（12月21日）まで約8ヶ月半
- **記事での表現**: 「2005年4月に始まったプロジェクトは、同年12月21日にv1.0に到達した」

## 9. Linux kernel 2.6.12のgit管理下での最初のリリース

- **結論**: Linux kernel 2.6.12は2005年6月17日にリリースされた（6月16日にgitで管理された最初のカーネルリリース、とする文献もある）。BitKeeperからgitへの移行後、最初の公式カーネルリリースだった
- **一次ソース**: Wikipedia "Linux kernel version history"; Wikipedia "Git"
- **URL**: <https://en.wikipedia.org/wiki/Linux_kernel_version_history>, <https://en.wikipedia.org/wiki/Git>
- **注意事項**: 4月のgit開発開始から約2ヶ月半で、公式カーネルリリースを管理できる状態に到達した
- **記事での表現**: 「2005年6月17日、gitで管理された最初の公式カーネルリリースであるLinux 2.6.12がリリースされた」

## 10. gitの自己定義——「the stupid content tracker」と「the information manager from hell」

- **結論**: gitの最初のコミットメッセージは「Initial revision of 'git', the information manager from hell」。READMEの冒頭は「GIT - the stupid content tracker」。READMEではgitの名前の由来を自嘲的に説明: 「a random three-letter combination」「global information tracker（機嫌がいいとき）」「goddamn idiotic truckload of sh*t（壊れたとき）」
- **一次ソース**: git/git リポジトリ初期コミット e83c5163; initialcommit.com "How did Git get its name?"
- **URL**: <https://github.com/git/git/commit/e83c5163316f89bfbde7d9ab23ca2e25604af290>, <https://initialcommit.com/blog/How-Did-Git-Get-Its-Name>
- **注意事項**: 「stupid」は自嘲であると同時に設計思想の表明——gitは「賢い」機能を持たず、愚直にコンテンツを追跡する
- **記事での表現**: READMEの原文を引用し、「stupidであること」がgitの設計哲学であることを解説

## 11. 2005年4月のgit開発タイムライン（詳細）

- **結論**: 4月3日: 開発開始 → 4月6日: LKML投稿 → 4月7日: 最初のコミット（self-hosting） → 4月16日: gitでの最初のLinuxカーネルコミット → 4月18日: 最初のマルチブランチマージ → 4月29日: 6.7パッチ/秒のベンチマーク達成
- **一次ソース**: Wikipedia "Git"; GitLab "Journey through Git's 20-year history"
- **URL**: <https://en.wikipedia.org/wiki/Git>, <https://about.gitlab.com/blog/journey-through-gits-20-year-history/>
- **注意事項**: 各マイルストーンの日付は複数のソースで確認済み
- **記事での表現**: タイムライン形式で提示し、各マイルストーンの技術的意味を解説する

## 12. Google Tech Talk（2007年5月3日）

- **結論**: 2007年5月3日、Linus TorvaldsはGoogleでgitについてのTech Talkを行った。この講演で「gitはファイルシステムの人間の視点から設計した」「CVSは最悪のバージョン管理」「Subversionは最も無意味なプロジェクト」等の発言を行った。git設計思想の最も詳細な一次ソースの一つ
- **一次ソース**: Torvalds, L., "Tech Talk: Linus Torvalds on git" Google (2007-05-03)
- **URL**: <https://git.wiki.kernel.org/index.php/LinusTalk200705Transcript>
- **注意事項**: 講演は2007年であり、2005年のgit誕生時の文脈とは2年のずれがある。記事では時系列を明確にすること
- **記事での表現**: 設計思想の解説部分で引用する。2007年の講演であることを明記する
