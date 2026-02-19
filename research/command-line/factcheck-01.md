# ファクトチェック記録: 第1回「なぜ今、コマンドラインを語るのか -- GUI時代の盲点」

調査日: 2026-02-19

---

## 1. Stack Overflow Developer Survey -- 開発者のターミナル/CLI使用実態

- **結論**: Stack Overflow Developer Survey 2024では65,437人の開発者が回答。VS Codeが73.6%のシェアで最も使われるIDEであり、統合ターミナルが主要機能の一つ。Docker（CLIツール）は2024→2025で+17ポイントの使用増。2025年調査では49,000+人が回答
- **一次ソース**: Stack Overflow, "2024 Developer Survey" / "2025 Developer Survey"
- **URL**: <https://survey.stackoverflow.co/2024/> / <https://survey.stackoverflow.co/2025/>
- **注意事項**: ターミナル使用率の直接的な統計項目はない。IDE使用率とDockerなどCLIツールの普及率から間接的に推測する形
- **記事での表現**: VS Codeが開発者の73.6%に使われ、その統合ターミナルが日常的な開発の起点となっている事実を述べる

## 2. Macintosh発売（1984年1月24日）とGUI革命

- **結論**: Apple Macintoshは1984年1月24日に$2,495で発売。初の商業的に成功したGUI搭載パーソナルコンピュータ。マウスとデスクトップメタファーを採用し、コマンドライン入力を不要にした。発売4ヶ月で70,000台を販売（5月3日時点）。1984年1月22日のスーパーボウルXVIIIで「1984」CMを放映（監督: リドリー・スコット）
- **一次ソース**: Smithsonian Magazine, "Forty Years Ago, the Mac Triggered a Revolution in User Experience" / Wikipedia "Macintosh 128K"
- **URL**: <https://www.smithsonianmag.com/innovation/forty-years-ago-the-mac-triggered-a-revolution-in-user-experience-180983623/> / <https://en.wikipedia.org/wiki/Macintosh_128K>
- **注意事項**: 「CLIは死んだ」という直接的な引用は見つからないが、Macintoshが「コマンドライン入力を不要にした」という文脈で語られている
- **記事での表現**: 1984年のMacintosh発売が「CLIは不要になる」という予感を世界に与えた、という文脈で使用

## 3. Windows 95発売（1995年8月24日）とDOS窓の衰退

- **結論**: Windows 95は1995年8月24日に発売。$3億のプロモーションキャンペーン。最初の4日間で100万本を出荷。1998年末にはデスクトップOSシェア57.4%を獲得。DOS上に構築されていたが、GUIがDOSを事実上隠蔽した。「PCを買った人の多くはDOSの存在をほぼ意識しなくなった」
- **一次ソース**: How-To Geek, "Windows 95 Turns 25: When Windows Went Mainstream" / Wikipedia "Windows 95"
- **URL**: <https://www.howtogeek.com/685668/windows-95-turns-25-heres-how-it-transformed-pcs/> / <https://en.wikipedia.org/wiki/Windows_95>
- **注意事項**: Windows 95はDOS上に構築されており、完全にDOSと決別したわけではない
- **記事での表現**: Windows 95が「一般ユーザーをコマンドラインから引き離した」決定的転機として記述

## 4. iPhone発売（2007年）とNUI（Natural User Interface）の台頭

- **結論**: Steve JobsがiPhoneを2007年1月9日のMacWorldで発表。6月29日に一般販売開始。マルチタッチによるピンチ・スワイプ操作を標準化。ボタンは1つだけ、スタイラス不要、キーボード不要。CLI→GUI→NUI（Natural User Interface）という3段階のインターフェース進化の文脈で位置づけられる
- **一次ソース**: Wikipedia "Natural user interface" / Tandem "It's Been 15 Years: Here's How the iPhone Has Influenced UI Design"
- **URL**: <https://en.wikipedia.org/wiki/Natural_user_interface> / <https://madeintandem.com/blog/14-years-heres-iphone-influenced-ui-design/>
- **注意事項**: NUIの定義は学術的に厳密ではなく、マーケティング用語的な側面もある
- **記事での表現**: iPhoneが「キーボードすら不要にした」という文脈で、CLI不要論のさらなる加速として記述

## 5. Ben Shneidermanの「直接操作」概念（1983年）

- **結論**: Ben Shneidermanが1983年にComputer誌で"Direct Manipulation: A Step Beyond Programming Languages"を発表（Vol.16, pp.57-69）。直接操作の3原則:（1）オブジェクトとアクションの連続的表現、（2）迅速・漸進的・可逆的アクション、（3）物理的アクションとジェスチャーによる入力コマンドの置換。認知負荷の観点で、CLIは「想起（recall）」を要求し、GUIは「再認（recognition）」を提供する
- **一次ソース**: Ben Shneiderman, "Direct Manipulation: A Step Beyond Programming Languages", Computer, 1983
- **URL**: <https://www.cs.umd.edu/~ben/papers/Shneiderman1983Direct.pdf>
- **注意事項**: 1982年に認知分析自体は開始されている。1983年は論文発表年
- **記事での表現**: CLI/GUIの本質的違いを「想起 vs 再認」という認知科学的フレームワークで説明する際に引用

## 6. Docker CLI / kubectl の普及とCLIの復権

- **結論**: 2024年時点でKubernetes本番導入率80%（前年66%から20.7%増）。Docker市場シェア87.67%、世界108,000社以上が利用。Stack Overflow Developer Survey 2023でDocker使用率53%超。コンテナ使用率はIT専門職で92%（2024年調査、前年80%から増加）。CLIがインフラ管理の中心に回帰
- **一次ソース**: Docker Blog "2025 Docker State of App Dev" / Octopus "40 Kubernetes Statistics In 2025"
- **URL**: <https://www.docker.com/blog/2025-docker-state-of-app-dev/> / <https://octopus.com/devops/ci-cd-kubernetes/kubernetes-statistics/>
- **注意事項**: 数値はソースにより差がある。IT専門職 vs 全開発者で数値が異なる
- **記事での表現**: Docker/kubectlの普及により「CLIがインフラの中心に回帰した」事実を具体的数値とともに記述

## 7. Doug McIlroyとUNIXパイプ -- テキストストリームの普遍性

- **結論**: Doug McIlroyが1964年にパイプの概念を提案（「プログラムをガーデンホースのように接続すべきだ」）。Ken Thompsonが1973年1月15日にUnix V3でパイプを実装。McIlroyのUNIX哲学:「一つのことをうまくやるプログラムを書け。協調するプログラムを書け。テキストストリームを扱うプログラムを書け。それがユニバーサルインターフェースだからだ」。Thompsonは「もう聞き飽きた」と言い、一晩でgrepやcatなどの主要プログラムをパイプ対応に改修した
- **一次ソース**: Unix Heritage Wiki / The New Stack "Pipe: How the System Call That Ties Unix Together Came About"
- **URL**: <https://wiki.tuhs.org/doku.php?id=features:pipes> / <https://thenewstack.io/pipe-how-the-system-call-that-ties-unix-together-came-about/>
- **注意事項**: 1964年はメモの日付。実装は1973年1月
- **記事での表現**: テキストストリームが「ユニバーサルインターフェース」である理由を、McIlroyの原典を引用して説明

## 8. Xerox Alto（1973年3月1日）-- GUI の原点

- **結論**: Xerox Altoは1973年3月1日にXerox PARCで開発。世界初のGUI搭載コンピュータの一つ。Alan Kay率いるLearning Research Groupが研究。ビットマップディスプレイ、マウス、WYSIWYGエディタ、Ethernetネットワーキングを搭載。1979年にSteve JobsがPARCを訪問し、AltoのGUIに影響を受けてLisaとMacintoshを開発
- **一次ソース**: Computer History Museum / Wikipedia "Xerox Alto"
- **URL**: <https://www.computerhistory.org/revolution/input-output/14/347> / <https://en.wikipedia.org/wiki/Xerox_Alto>
- **注意事項**: Altoは製品として販売されたわけではなく、研究用コンピュータ。約2,000台が製造
- **記事での表現**: 「GUIの概念はCLIよりわずか4年遅れで生まれている（Unix 1969年、Alto 1973年）」という文脈で使用

## 9. Neal Stephenson "In the Beginning was the Command Line"（1999年）

- **結論**: Neal Stephensonが1999年に発表した38,000語のエッセイ。テレタイプからモダンOSまでのインターフェース史を論じる。出版社のWebサイトに掲載され、Slashdot効果でサーバがダウンするほどのアクセスを集めた。Microsoft、Apple、Linux、BeOSのOS戦争を自動車の比喩で論じた
- **一次ソース**: Neal Stephenson, nealstephenson.com / Internet Archive
- **URL**: <https://www.nealstephenson.com/in-the-beginning-was-the-command-line.html> / <https://archive.org/details/stephenson-neal-1999.-in-the-beginning-was-the-command-line>
- **注意事項**: 1999年時点の議論であり、Linux/BeOSの評価は当時の文脈で読む必要がある
- **記事での表現**: CLIの本質を語った先行文献として紹介。「25年以上前にStephensonが問いかけた疑問は、今なお有効である」

## 10. Steve Jobs "bicycle for the mind"（1990年）

- **結論**: Steve Jobsが1990年のインタビュー映像（Library of Congress向けドキュメンタリー"Memory & Imagination"）で「コンピュータは心の自転車だ」と発言。元ネタは1973年のScientific American誌（S.S. Wilson著）の移動効率比較で、自転車に乗った人間がコンドルを凌駕したという研究。「What a computer is to me is the most remarkable tool that we have ever come up with. It's the equivalent of a bicycle for our minds.」
- **一次ソース**: The Marginalian, "Steve Jobs on Why Computers Are Like a Bicycle for the Mind (1990)"
- **URL**: <https://www.themarginalian.org/2011/12/21/steve-jobs-bicycle-for-the-mind-1990/>
- **注意事項**: 1981年のプレゼンでも類似の発言があるとする説もある
- **記事での表現**: GUIの設計哲学を象徴する言葉として引用。ただし、CLIもまた「心の自転車」たり得ることを対比的に論じる

## 11. モダンCLIツールの台頭（ripgrep, fzf等）

- **結論**: ripgrep（2016年, Andrew Gallant/BurntSushi）を皮切りに、Rust/Go製の新世代CLIツール群が登場。fd, bat, eza, zoxide, atuin, starship, lazygit, lazydocker, k9s等。単なる高速化ではなく、UXの根本的再設計（色付き出力、.gitignore自動認識、デフォルト値の最適化）。2024-2025年にはAI CLIツール（Claude Code等）も台頭
- **一次ソース**: KDAB "CLI++: Upgrade Your Command Line" / The Rise of Terminal Tools
- **URL**: <https://www.kdab.com/cli-upgrade-your-command-line-with-a-new-generation-of-everyday-tools/> / <https://tduyng.com/blog/rise-of-terminal/>
- **注意事項**: 普及率の正確な統計データは限定的。GitHub Stars数やパッケージマネージャのダウンロード数で間接的に推測可能
- **記事での表現**: 「CLIは死ぬどころか、2020年代に入ってルネサンスを迎えている」という論旨の具体的根拠として使用
