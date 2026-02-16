# ファクトチェック記録：第22回「gitの限界——次世代VCSへの要求仕様」

調査日：2026-02-16

---

## 1. Pijul——パッチ理論ベースのVCS

- **結論**: Pijulは2015年にPierre-Etienne MeunierとFlorent Beckerが開始した分散型VCS。Rustで実装。GPL2ライセンス。Samuel MimramとCinzia di Giustoのパッチ理論（圏論のpushoutに基づく）を基盤とする。Beckerは当時Darcsのコア貢献者であり、自己集合に関する論文執筆中にDarcsの欠点を解決するアイデアを着想。2017年1月に最初の動作版を公開、2020年11月にアルファ版をリリース
- **一次ソース**: Pijul公式サイト; initialcommit.com, "Pijul - The Mathematically Sound Version Control System Written in Rust"; initialcommit.com, "Q&A with the Creator of the Pijul Version Control System"
- **URL**: <https://pijul.org/>; <https://initialcommit.com/blog/pijul-version-control-system>; <https://initialcommit.com/blog/pijul-creator>
- **注意事項**: Darcsの指数的マージ問題を解決。Pijulのパッチ適用は`O(p * c * log(h))`、Darcsは最悪ケースで`O(2^h)`
- **記事での表現**: 「2015年、Pierre-Etienne MeunierとFlorent Beckerは、Darcsの欠点を解決する新しいVCSとしてPijulの開発を開始した。Beckerは当時Darcsのコア貢献者であり、圏論のpushoutに基づくパッチ理論を基盤に据えた」

## 2. Darcs——パッチ理論の起源

- **結論**: Darcs（Darcs Advanced Revision Control System）はDavid Roundyが開発。2002年6月、GNU archの新しいパッチフォーマットに関するTom Lordとのメール議論から「パッチの理論」を着想。最初はC++で実装し、2002年秋にHaskellで書き直し、2003年4月に公開。パッチの交換（commutation）を自動計算する仕組みが核心。量子力学の演算子との類推がパッチ理論の起源。Darcs 2.0は2008年4月リリースで、指数的マージコンフリクト問題を軽減する「darcs-2」セマンティクスを導入
- **一次ソース**: Wikipedia, "Darcs"; Darcs公式サイト
- **URL**: <https://en.wikipedia.org/wiki/Darcs>; <https://darcs.net/Theory>
- **注意事項**: パッチ理論はDarcsが開拓し、Pijulが数学的に厳密化した関係
- **記事での表現**: 「2002年、David RoundyはGNU archの議論からパッチ理論を着想し、Darcsを開発した。パッチの交換可能性を自動計算するこの理論は、量子力学の演算子との類推から生まれた」

## 3. Jujutsu (jj)——GoogleのGit互換VCS

- **結論**: Martin von Zweigbergkが2019年後半に趣味プロジェクトとして開始。Googleでのフルタイムプロジェクトに発展。Apache 2.0ライセンス。Rustで実装。Gitリポジトリをストレージバックエンドとして使用し、Git互換性を実現。特徴: (1) 作業コピーの自動スナップショット化（コミットとして扱う）、(2) オペレーションログによる全操作の記録とundo、(3) コンフリクトをコミットに記録し後から解決可能、(4) ステージングエリア不要。2025年時点でGoogle内部で約900ユーザー、Linux限定GAを2026年前半に予定、その後Mercurial統合ユーザーを移行予定
- **一次ソース**: GitHub jj-vcs/jj; Scribd, "Jujutsu at Google - Martin von Zweigbergk"
- **URL**: <https://github.com/jj-vcs/jj>; <https://www.scribd.com/document/939387502/Jujutsu-at-Google-Martin-von-Zweigbergk>
- **注意事項**: Googleの公式サポート製品ではなく、コミュニティサポート。GoogleのPiper/CitCバックエンドにも対応可能な設計
- **記事での表現**: 「2019年後半、GoogleのMartin von Zweigbergkは趣味プロジェクトとしてJujutsuの開発を開始した。Gitリポジトリをストレージバックエンドとして使用するGit互換VCSであり、作業コピーの自動スナップショット化やオペレーションログなど、Gitの設計上の制約を解消する機能を備える」

## 4. Sapling——MetaのスケーラブルVCS

- **結論**: MetaがMercurialをベースに10年以上かけて開発。2022年11月15日にオープンソースとして公開。3つのコンポーネント: (1) Saplingクライアント（slコマンド）、(2) Mononoke（スケーラブルな分散ソースコントロールサーバー）、(3) EdenFS（仮想ファイルシステム）。SmartlogのWeb UI、VS Code統合を提供。Git互換クライアントとして動作可能。Facebookは2012年頃にGitからMercurialに移行（Linuxカーネルの数倍のコードベースでGitの基本操作が遅すぎたため）、その後Mercurialを大幅カスタマイズし、最終的にSaplingとしてフォーク
- **一次ソース**: Meta Engineering Blog, "Sapling: Source control that's user-friendly and scalable," 2022-11-15; LWN.net, "Meta's Sapling source-code management system"
- **URL**: <https://engineering.fb.com/2022/11/15/open-source/sapling-source-control-scalable/>; <https://lwn.net/Articles/915104/>
- **注意事項**: Mononokeサーバーは外部利用はまだサポートされていない。Smartlogのドラッグアンドドロップrebaseやマルチウェイcommit splitが特徴
- **記事での表現**: 「Metaは2022年11月にSaplingをオープンソースとして公開した。Mercurialをベースに10年以上かけて開発されたもので、EdenFS仮想ファイルシステムとMononokeサーバーにより、数百万のファイルとコミットを持つリポジトリに対応する」

## 5. Gitのモノレポスケーリング問題——Microsoft/Google/Metaの事例

- **結論**:
  - **Microsoft**: 2017年にWindowsコードベースをGitに移行。リポジトリサイズ約300GB、350万ファイル。移行前はgit checkoutに最大3時間、git statusに約10分。GVFS（Git Virtual File System）を開発し、cloneを12時間超→数分、checkoutを2-3時間→30秒、statusを10分→4-5秒に改善。約3,500人のWindows開発者がGit/GVFSで運用。後にScalarに移行
  - **Google**: 独自のPiperリポジトリを使用。約10億ファイル、約3,500万コミット、86TB、20億行以上のコード。1日40,000以上のコミット。商用・OSSのVCSでは対応できないスケール
  - **Meta**: 2012年頃にGitからMercurialに移行。コードベースがLinuxカーネルの数倍に成長し、基本操作に最大45分かかる状態
- **一次ソース**: Brian Harry's Blog, "The largest Git repo on the planet," 2017; ACM, "Why Google Stores Billions of Lines of Code in a Single Repository," 2016; Meta Engineering Blog, 2014
- **URL**: <https://devblogs.microsoft.com/bharry/the-largest-git-repo-on-the-planet/>; <https://cacm.acm.org/research/why-google-stores-billions-of-lines-of-code-in-a-single-repository/>; <https://engineering.fb.com/2014/01/07/core-infra/scaling-mercurial-at-facebook/>
- **注意事項**: Googleはそもそもgitを使っていない。Metaもgitでは対応できなかった
- **記事での表現**: 「Microsoftは2017年、300GBのWindowsリポジトリをGitに移行した。移行前のgit checkoutには最大3時間、git statusには約10分を要した。この問題を解決するためにGVFS（後のScalar）を開発した」

## 6. VFS for Git / Scalar

- **結論**: GVFS（Git Virtual File System）はMicrosoftが2017年に発表。ファイルシステムを仮想化し、実際にアクセスされるまでファイルをダウンロードしない方式。後にScalarに移行。ScalarはVFS for Gitからの教訓とGitの新機能を組み合わせた薄いラッパー。新規デプロイにはScalarを推奨。長期目標はサーバーサイドコードをGit公式リリースに統合すること
- **一次ソース**: Azure DevOps Blog, "Announcing GVFS"; Azure DevOps Blog, "Introducing Scalar"; Microsoft/Scalar GitHub
- **URL**: <https://devblogs.microsoft.com/devops/announcing-gvfs-git-virtual-file-system/>; <https://devblogs.microsoft.com/devops/introducing-scalar/>; <https://github.com/microsoft/scalar>
- **注意事項**: GVFSはWindows 10 Anniversary Update以降が必要。Scalarはクロスプラットフォーム対応
- **記事での表現**: 「MicrosoftはGVFS（2017年）でファイルシステムを仮想化してGitの大規模リポジトリ問題に対処し、後により軽量なScalarへと移行した。長期的にはGit本体への機能統合を目指している」

## 7. Git SHA-1からSHA-256への移行

- **結論**: SHA-1からSHA-256への移行は2018年後半に後継ハッシュとして特定。Git 2.42（2023年8月）でSHA-256リポジトリが「実験的好奇心」でなくなった。Git 2.45（2024年）でSHA-1/SHA-256相互運用パッチ着手。Git 2.51.0でSHA-256をGit 3.0のデフォルトハッシュに指定。Brian m. carlsonがほぼ全てのSHA-256作業を担当、推定200-400パッチが必要で約100完了。Git 3.0は2026年後半リリース目標。SHA-256のほか、Rustを必須ビルド要件にする計画（影響評価次第で延期の可能性）
- **一次ソース**: DeployHQ, "Git 3.0 on the Horizon"; Help Net Security, "Git 2.51: Preparing for the future with SHA-256"; LWN.net, "Git considers SHA-256, Rust, LLMs, and more"; Phoronix, "Git Developers Talk About Potentially Releasing Git 3.0 By The End Of Next Year"
- **URL**: <https://www.deployhq.com/blog/git-3-0-on-the-horizon-what-git-users-need-to-know-about-the-next-major-release>; <https://www.helpnetsecurity.com/2025/08/19/git-2-51-sha-256/>; <https://lwn.net/Articles/1042172/>
- **注意事項**: SHA-1/SHA-256の相互運用があるため既存リポジトリが即座に壊れることはない。ただし全依存プロジェクトのSHA-256対応が最大の障壁
- **記事での表現**: 「Git 3.0では、SHA-1からSHA-256へのデフォルトハッシュ切り替えが予定されている。2026年後半のリリースが目標だが、SHA-256対応パッチは推定200-400中約100が完了した段階であり、依存プロジェクトの対応状況が最大の障壁となっている」

## 8. Gitの設計的制約とUX問題

- **結論**: Santiago Perez De RossoとDaniel JacksonがMITで2013年に発表した論文 "What's Wrong with Git? A Conceptual Design Analysis"（Onward! 2013）がGitの概念設計を体系的に分析。問題点: (1) コマンド構文の恣意性と非一貫性（git pullがfetch+merge、git checkout -bがbranch+checkout）、(2) コマンドのオーバーロード（checkoutがブランチ切り替えとファイル復元の両方）、(3) ステージングエリアの用語不統一（staging area/index/cache）、(4) plumbingとporcelainの断絶。この研究はGitless（Gitの概念的再設計）の基盤に。Steve Bennettの「10 things I hate about Git」（2012年）も広く参照される批判
- **一次ソース**: Perez De Rosso, S., Jackson, D. "What's Wrong with Git? A Conceptual Design Analysis." Onward! 2013, ACM SIGPLAN; Bennett, S. "10 things I hate about Git," 2012
- **URL**: <https://spderosso.github.io/onward13.pdf>; <https://stevebennett.me/2012/02/24/10-things-i-hate-about-git/>
- **注意事項**: Git 2.23（2019年8月）でgit switchとgit restoreが導入され、checkoutのオーバーロード問題は部分的に改善された
- **記事での表現**: 「2013年、MITのSantiago Perez De RossoとDaniel Jacksonは論文 "What's Wrong with Git?" でGitの概念設計を体系的に分析した。コマンド構文の非一貫性、コマンドのオーバーロード、ステージングエリアの用語不統一などの問題を指摘し、Gitless（Gitの概念的再設計）を提案した」

## 9. パッチ理論の数学的基盤

- **結論**: パッチ理論の数学的定式化は圏論に基づく。ファイル（作業ディレクトリの状態）をオブジェクト、パッチを射（arrow）とする圏を定義。マージ操作はpushoutとして定義される。全てのパッチが交換可能な圏では、pushoutはパッチを任意の順序で適用することで得られる。Samuel MimramとCinzia di Giustoの論文 "A Categorical Theory of Patches"（2013年）が形式的基盤。Darcsのパッチ理論はcommutation（交換）を中心概念とし、Pijulはpushout（合併）を中心概念とする
- **一次ソース**: Mimram, S., di Giusto, C. "A Categorical Theory of Patches." Electronic Notes in Theoretical Computer Science, 2013; arXiv:1311.3903
- **URL**: <https://www.sciencedirect.com/science/article/pii/S1571066113000649>; <https://ar5iv.labs.arxiv.org/html/1311.3903>; <https://pijul.org/model/>
- **注意事項**: 二つのパッチが非互換の場合、pushoutは圏内に必ずしも存在しない。有限余極限での自由完備化がPijulの解法
- **記事での表現**: 「パッチ理論の数学的基盤は圏論にある。ファイルをオブジェクト、パッチを射とする圏を定義し、マージ操作をpushoutとして定式化する。Darcsがパッチの交換（commutation）を中心に据えたのに対し、Pijulはpushout（合併）を中心に据えることで指数的マージ問題を解決した」

## 10. Mercurialの衰退とMetaの移行

- **結論**: Facebookは初期にGitを使用していたが、2012年頃にコードベースがLinuxカーネルの数倍に成長し、Gitの基本操作が最大45分かかる状態になったためMercurialに移行。その後Mercurialを大幅にカスタマイズ（バックエンドをFacebook独自の分散オブジェクトストア "Eden" に書き換え）。最終的にMercurialコミュニティとの方向性の相違からSaplingとしてフォーク。SaplingのCLI（sl）は元々Mercurialベースで、UIや機能の多くを継承
- **一次ソース**: Meta Engineering Blog, "Scaling Mercurial at Facebook," 2014; LWN.net, "Meta's Sapling source-code management system," 2022
- **URL**: <https://engineering.fb.com/2014/01/07/core-infra/scaling-mercurial-at-facebook/>; <https://lwn.net/Articles/915187/>
- **注意事項**: Metaの移行は「Git→Mercurial→Mercurialカスタム版→Sapling」という段階的な経緯
- **記事での表現**: 「Facebookは2012年頃、Git操作に最大45分を要する状態に達し、Mercurialに移行した。その後Mercurialを大幅にカスタマイズしたが、コミュニティとの方向性が合わず、最終的にSaplingとしてフォークした」

## 11. Git互換性と革新のジレンマ

- **結論**: JujutsuはGitリポジトリをストレージバックエンドとして使用し、ブックマーク（ブランチ）などの高レベルメタデータはGitの外で管理。SaplingはGit互換クライアントとして動作可能。両者とも既存のGitエコシステム（GitHub、GitLab、CI/CD）との互換性を維持しつつ、独自の改善を導入するアプローチ。PijulはGit互換性を持たず、独自のデータモデルを採用
- **一次ソース**: Jujutsu Docs, "Git compatibility"; Sapling公式サイト
- **URL**: <https://jj-vcs.github.io/jj/latest/git-compatibility/>; <https://sapling-scm.com/>
- **注意事項**: Git互換性は普及の鍵だが、Gitの設計制約も引き継ぐジレンマがある
- **記事での表現**: 「JujutsuとSaplingはGit互換性を維持しながら独自の改善を導入するアプローチを採る。PijulはGit互換性を持たず、独自のデータモデルで勝負する。Git互換性は普及の鍵だが、同時にGitの設計制約を引き継ぐジレンマを抱える」

## 12. Git 3.0の計画——mainデフォルト化、Rust導入

- **結論**: Git 3.0では(1) SHA-256デフォルト化、(2) Rustを必須ビルド要件に（Patrick Steinhardtがパッチ提出）、(3) defaultBranchをmainに変更、などが計画。2026年後半リリース目標。Rust導入はプラットフォーム互換性の議論を引き起こしている（Rustコンパイラがサポートしないプラットフォームでのビルド不可）。影響が大きい場合はマイナーリリースに延期の可能性
- **一次ソース**: DeployHQ Blog; Phoronix; LWN.net; It's FOSS News
- **URL**: <https://www.deployhq.com/blog/git-3-0-on-the-horizon-what-git-users-need-to-know-about-the-next-major-release>; <https://www.phoronix.com/news/Git-3.0-Release-Talk-2026>; <https://news.itsfoss.com/git-3-rust/>
- **注意事項**: Git 3.0は破壊的変更を含むメジャーバージョンだが、SHA-1/SHA-256相互運用により段階的移行が可能
- **記事での表現**: 「Git 3.0は2026年後半のリリースを目指し、SHA-256のデフォルト化、Rustの必須ビルド要件化、デフォルトブランチのmainへの変更を計画している。20年以上Cで書かれてきたGitにとって、Rust導入は大きなアーキテクチャ変更となる」
