# ファクトチェック記録：第24回「ターミナルは遺物か、改めて問う――あなたのインターフェースを選べ」

## 1. Ben Shneidermanの「直接操作（Direct Manipulation）」

- **結論**: Ben Shneidermanが1983年にIEEE Computer誌で「Direct Manipulation: A Step Beyond Programming Languages」を発表し、「直接操作」という概念を提唱した。対象物の視覚的表現、迅速で可逆的な操作、複雑な構文の代わりに物理的操作を用いるという三つの原則を定義した
- **一次ソース**: Ben Shneiderman, "Direct Manipulation: A Step Beyond Programming Languages", Computer, vol. 16, pp. 57-69, 1983
- **URL**: <https://www.cs.umd.edu/~ben/papers/Shneiderman1983Direct.pdf>
- **注意事項**: 1984年のMacintosh発売の前年に発表された理論であり、GUIの認知的基盤を提供した
- **記事での表現**: 「1983年、Ben Shneidermanは直接操作（Direct Manipulation）という概念を提唱した」

## 2. Jakob Nielsenの「再認 vs 想起（Recognition vs Recall）」

- **結論**: Jakob NielsenとRolf Molichが1990年にユーザビリティヒューリスティクスを開発。1994年にNielsenが249のユーザビリティ問題の因子分析に基づいて改良。第6のヒューリスティクスが「Recognition rather than recall（想起よりも再認）」である
- **一次ソース**: Jakob Nielsen, "10 Usability Heuristics for User Interface Design", 1994（2024年更新）
- **URL**: <https://www.nngroup.com/articles/ten-usability-heuristics/>
- **注意事項**: 原則の要点は「オブジェクト、アクション、オプションを可視化することでユーザーの記憶負荷を最小化せよ」
- **記事での表現**: 「GUIは再認（recognition）を活用し、CLIは想起（recall）を要求する。Jakob Nielsenが1994年に体系化したこの区別は、インターフェース選定の基本軸となる」

## 3. Don Normanの「アフォーダンス」と「シグニファイア」

- **結論**: Don Normanが1988年に『The Design of Everyday Things』（初版タイトルは『The Psychology of Everyday Things』）でアフォーダンスの概念をデザインに導入。2013年の改訂版でシグニファイア（signifier）の概念を追加した。アフォーダンスはJames J. Gibsonの生態心理学から借用
- **一次ソース**: Don Norman, "The Design of Everyday Things", 1988（初版）/2013（改訂版）
- **URL**: <https://en.wikipedia.org/wiki/The_Design_of_Everyday_Things>
- **注意事項**: CLIにはアフォーダンスが乏しい（コマンドの存在が視覚的に示されない）。GUIはシグニファイアが豊富（ボタン、メニュー）。この違いがインターフェース選定に直結する
- **記事での表現**: 「Don Normanが1988年に論じたアフォーダンスの観点から見ると、CLIは発見可能性（discoverability）に欠ける」

## 4. Xerox Alto（1973年）

- **結論**: Xerox AltoはXerox PARCで開発され、1973年3月1日に最初のマシンが動作した。Alan Kay、Butler Lampson、Chuck Thackerらが開発に携わった。ビットマップディスプレイ、マウス、WYSIWYG編集、イーサネットなどを備えた世界初のGUI搭載ワークステーション
- **一次ソース**: Computer History Museum, "Xerox Alto"
- **URL**: <https://www.computerhistory.org/revolution/input-output/14/347>
- **注意事項**: 商用製品ではなく研究用マシン。1979年12月にSteve Jobsが訪問しMacintoshに影響
- **記事での表現**: 「1973年、Xerox PARCでAltoが稼働した。GUIの原型を示した最初のマシンだった」

## 5. Apple Macintosh（1984年1月24日）

- **結論**: Steve Jobsが1984年1月24日、クパチーノのフリントセンターでApple株主総会にてMacintoshを発表。価格$2,495。9インチ白黒ディスプレイ、Motorola 68000（8MHz）、128KB RAM。「1984」CMはRidley Scott監督
- **一次ソース**: Time Magazine, "Exclusive: Watch Steve Jobs' First Demonstration of the Mac"
- **URL**: <https://time.com/1847/steve-jobs-mac/>
- **注意事項**: GUIをパーソナルコンピュータに普及させた歴史的転換点
- **記事での表現**: 「1984年1月24日、Steve JobsはMacintoshを発表した」

## 6. Windows 95（1995年8月24日）

- **結論**: Windows 95は1995年8月24日に小売発売。スタートメニュー、タスクバー、Windows Explorerを導入。Rolling Stonesの「Start Me Up」を使った3億ドルの宣伝キャンペーン。発売後4日間で100万本を出荷
- **一次ソース**: Wikipedia, "Windows 95"
- **URL**: <https://en.wikipedia.org/wiki/Windows_95>
- **注意事項**: スタートボタンのUI要素は後のWindowsでも基本的に継承された
- **記事での表現**: 「1995年8月24日のWindows 95は、スタートメニューとタスクバーでGUIデスクトップの標準を確立した」

## 7. iPhone（2007年1月9日）

- **結論**: Steve Jobsが2007年1月9日のMacworld Conferenceで初代iPhoneを発表。マルチタッチインターフェースを導入。「revolutionary user interface」と称した。実際の発売は2007年6月29日
- **一次ソース**: AppleInsider, "Behind-the-scenes details revealed about Steve Jobs' first iPhone announcement"
- **URL**: <https://appleinsider.com/articles/13/10/04/behind-the-scenes-details-reveal-steve-jobs-first-iphone-announcement>
- **注意事項**: NUI（Natural User Interface）の大衆化の転換点。デモ機はプロトタイプでクラッシュの危険があった
- **記事での表現**: 「2007年1月9日、Steve Jobsがマルチタッチインターフェースを搭載したiPhoneを発表した」

## 8. ChatGPT（2022年11月30日）

- **結論**: OpenAIが2022年11月30日にChatGPTを公開。5日間で100万ユーザー、2ヶ月で1億ユーザーに到達し、「史上最速で普及した消費者向けソフトウェア」と報じられた。自然言語インターフェースの大衆化の転換点
- **一次ソース**: OpenAI, "Introducing ChatGPT"
- **URL**: <https://openai.com/index/chatgpt/>
- **注意事項**: 技術的ブレークスルーよりもUIのアクセシビリティ（シンプルなチャットウィンドウ）が爆発的普及の主因
- **記事での表現**: 「2022年11月30日にOpenAIがChatGPTを公開した。自然言語インターフェースが大衆のものになった瞬間だった」

## 9. Neal Stephenson『In the Beginning was the Command Line』（1999年）

- **結論**: Neal Stephensonが1999年に発表した約38,000語のエッセイ。OS、GUI、CLIの関係を論じた。出版社のWebサイトに掲載されバイラルに広がった
- **一次ソース**: Neal Stephenson, "In the Beginning was the Command Line", 1999
- **URL**: <https://www.nealstephenson.com/in-the-beginning-was-the-command-line.html>
- **注意事項**: 1999年時点の考察であり、当時のLinux/Windows対立が背景にある
- **記事での表現**: 「1999年、Neal Stephensonは『In the Beginning was the Command Line』で、GUIとCLIの関係を鮮やかに描いた」

## 10. Claude Code（2025年2月）

- **結論**: AnthropicがClaude Codeを2025年2月にリリース。ターミナル上で動作するエージェント型コーディングツール。自然言語でタスクを指示し、コードベースの理解、コード生成、gitワークフロー管理を実行。2025年5月にClaude 4と共に一般提供開始。2025年10月にWeb版も公開
- **一次ソース**: Anthropic, Claude Code GitHub
- **URL**: <https://github.com/anthropics/claude-code>
- **注意事項**: 2025年7月時点でClaude Code収益が5.5倍に成長
- **記事での表現**: 「2025年2月、AnthropicはClaude Codeをリリースした。自然言語でCLI操作を指示するエージェント型ツールだ」

## 11. Fittsの法則

- **結論**: Paul Fittsが1954年に提唱。ターゲットへの移動時間はターゲットまでの距離とターゲットの幅の比の関数。Shannon定式化（Scott MacKenzieが提案）が最も広く使われている。情報理論との類似性から、ポインティングを情報処理タスクとして定量化する
- **一次ソース**: Wikipedia, "Fitts's law"
- **URL**: <https://en.wikipedia.org/wiki/Fitts's_law>
- **注意事項**: GUIの設計原則に直結する（ボタンは大きく、距離は近く）。CLIにはFittsの法則が適用されない（キーボード入力はポインティングではない）
- **記事での表現**: 「Fittsの法則（1954年）によればポインティングの時間は距離と幅に依存する。CLIはこの制約から自由だ」

## 12. clig.dev（Command Line Interface Guidelines）

- **結論**: Aanand Prasad（Squarespace）、Ben Firshman（Docker Compose共同作成者、Replicate共同創業者）、Carl Tashian（Smallstep）、Eva Parish（Squarespace）が2020年に公開。初週にGitHub Stars 600、Hacker News フロントページに3日間掲載
- **一次ソース**: clig.dev
- **URL**: <https://clig.dev/>
- **注意事項**: UNIXの原則を現代に更新したCLIデザインガイドライン
- **記事での表現**: 「2020年に公開されたCommand Line Interface Guidelines（clig.dev）は、CLIデザインの現代的な指針を体系化した」
