# ファクトチェック記録：第13回「CLIとGUIの融合――IDEのターミナル、GUIのコマンドパレット」

## 1. Emacs M-xコマンド体系の起源（1976年）

- **結論**: TECO EMacsは1976年夏にMIT AI Labで開発された。Guy Steeleが多数のTECOマクロパッケージを統一する設計を行い、Richard Stallmanとともに実装した。M-x（execute-extended-command）は「説明的な英語名を持つコマンド」を実行する仕組みであり、David A. MoonがMM（Meta-Meta）マクロとして設計した「1-2キーストロークではなく説明的な英語名を持つコマンド」に由来する
- **一次ソース**: Wikipedia "Emacs"; EmacsWiki "EmacsHistory"; onlisp.co.uk "On the Origin of Emacs in 1976"
- **URL**: <https://en.wikipedia.org/wiki/Emacs>, <https://www.emacswiki.org/emacs/EmacsHistory>, <https://onlisp.co.uk/On-the-Origin-of-Emacs-in-1976.html>
- **注意事項**: 1976年のTECO EmacsとGNU Emacs（1984年）は別物。M-xの概念はTECO Emacsの時代からある
- **記事での表現**: 1976年、MIT AI LabでRichard Stallmanらが開発したEmacsは、M-x（Meta-x）キーで「名前を指定してコマンドを実行する」仕組みを備えていた。キーバインドに割り当てられていないコマンドでも、名前さえ知っていれば実行できる

## 2. Vim（1991年）のexコマンドモード

- **結論**: Bram Moolenaarが1988年に開発を開始し、1991年11月2日にVersion 1.14を"Vi Imitation"としてFred Fish disk #591で公開した。コロン（:）で入るコマンドモードはvi/exの系譜を引き継いでおり、exコマンド体系はed→ex→viの流れで1976年のBill Joyのexに遡る
- **一次ソース**: Wikipedia "Vim (text editor)"; twobithistory.org "Where Vim Came From"
- **URL**: <https://en.wikipedia.org/wiki/Vim_(text_editor)>, <https://twobithistory.org/2018/08/05/where-vim-came-from.html>
- **注意事項**: Vimの:コマンドはコマンドパレットの直接の祖先ではないが、「テキスト入力でコマンドを実行する」パラダイムの一例
- **記事での表現**: 1991年にBram Moolenaarが公開したVimは、exコマンドモード（コロンキーで起動）を通じて「名前ベースのコマンド実行」を維持した

## 3. Sublime TextのCommand Palette（2011-2012年）

- **結論**: Jon Skinnerが開発。Command PaletteはSublime Text 2のベータ期間中（2011年）に導入され、Sublime Text 2.0は2012年6月26日に正式リリースされた。Ctrl+Shift+P / Cmd+Shift+Pでアクセスし、fuzzy matchingによるコマンドのインクリメンタル検索が可能。Jon Skinner自身はmacOSの「メニュー項目の検索」機能から着想を得たと述べている
- **一次ソース**: Wikipedia "Sublime Text"; Sublime Text Blog "Sublime Text 2.0 Released"; digitalseams.com
- **URL**: <https://en.wikipedia.org/wiki/Sublime_Text>, <https://www.sublimetext.com/blog/articles/sublime-text-2-0-released>, <https://digitalseams.com/blog/why-do-sublime-text-and-vs-code-use-ctrl-shift-p-for-the-command-bar>
- **注意事項**: Command Paletteの「発明」としてSublime Textが最も有名だが、macOSのHelp > Search機能（メニュー項目検索）が先行していた
- **記事での表現**: 2011年、Jon SkinnerのSublime Text 2がCommand Paletteを導入した。Ctrl+Shift+Pでコマンド名の一部をタイプすれば、fuzzy matchingで候補が絞り込まれ、メニューを辿ることなくコマンドを実行できる

## 4. VS Code（2015年発表、統合ターミナル2016年）

- **結論**: VS Codeは2015年4月29日のBuild 2015で発表され、2015年11月18日にオープンソース化された。統合ターミナルは2016年5月のVersion 1.2で初めて導入された。当初は単一ターミナルのみで、キーボードによるコピー&ペーストも未対応だった。2016年6月のVersion 1.3でxterm.jsを採用し大幅改善された
- **一次ソース**: Wikipedia "Visual Studio Code"; VS Code Release Notes May 2016 (v1.2)
- **URL**: <https://en.wikipedia.org/wiki/Visual_Studio_Code>, <https://code.visualstudio.com/updates/May_2016>
- **注意事項**: VS CodeのCommand PaletteはSublime Text由来であり、Ctrl+Shift+Pのキーバインドもそのまま継承
- **記事での表現**: 2016年5月、VS Code 1.2で統合ターミナルが導入された。IDEのウィンドウ内にCLIが埋め込まれ、コードの編集とコマンドの実行がAlt+Tabなしで切り替えられる

## 5. macOS Spotlight（2005年）とランチャーの系譜

- **結論**: macOS Tiger（10.4, 2005年4月29日）でSpotlightが導入された。先行してQuicksilverが2003年にNicholas Jitkoff（Blacktree）によって開発されていた。Alfred（2010年、Andrew & Vero Peppeller、英国）がSpotlightの制約を補い約10年間支配的だった。Raycast（2020年）がモダンなランチャーとして登場
- **一次ソース**: Wikipedia "Quicksilver (software)"; 各種比較記事
- **URL**: <https://en.wikipedia.org/wiki/Quicksilver_(software)>
- **注意事項**: Quicksilver（2003年）はSpotlight（2005年）より先に存在していた。Quicksilver v1.0は2013年3月25日にリリース（10年のベータ後）
- **記事での表現**: 2003年にNicholas JitkoffのQuicksilverが登場し、macOS上でキーボード駆動のランチャーという概念を確立した。2005年、Apple自身がSpotlightをOS標準に組み込んだ

## 6. fzf（2013年、Junegunn Choi）

- **結論**: fzfは2013年にJunegunn Choiによって開発された汎用のコマンドラインfuzzy finder。stdin経由で任意のリストを受け取り、インタラクティブにfuzzy matchingで絞り込める。GitHubで77,000以上のスターを獲得。元はRubyで書かれ、後にGoに移植された
- **一次ソース**: GitHub junegunn/fzf; junegunn.github.io/fzf
- **URL**: <https://github.com/junegunn/fzf>, <https://junegunn.github.io/fzf/>
- **注意事項**: fzfはCLI上でfuzzy matchingを実現したツールであり、GUIのCommand Paletteと同じ問題（膨大な候補からの絞り込み）をCLI的に解決している
- **記事での表現**: 2013年、Junegunn Choiがfzfをリリースした。コマンド履歴、ファイル一覧、gitブランチ、任意のテキストリストに対してfuzzy matchingで絞り込む汎用ツールだ

## 7. dmenu（2006年、suckless.org）

- **結論**: dmenuはsuckless.orgプロジェクトの一部として2006年に開発された。Version 0.1は2006年8月4日に準備された。X11上の動的メニューであり、stdinからメニュー項目を読み取りユーザーが選択する。元はdwm用に設計された。後継としてrofi（Sean Prindle原作のsimpleswitcherが起源）がdmenuのドロップイン代替として機能する
- **一次ソース**: suckless.org dmenu; git.suckless.org/dmenu
- **URL**: <https://tools.suckless.org/dmenu/>, <https://git.suckless.org/dmenu/>
- **注意事項**: dmenuはX11のアプリケーションランチャーだが、パイプで任意のリストを渡せる「UNIX的コマンドパレット」でもある
- **記事での表現**: 2006年にsuckless.orgがリリースしたdmenuは、stdinから読み取ったテキストリストを表示し、ユーザーがインクリメンタルにフィルタリングして選択するX11プログラムだ

## 8. Atom（2014年公開ベータ、2015年正式版）とElectronの起源

- **結論**: AtomはGitHubのChris Wanstrath（共同創業者）が2008年に開発を始め、2014年2月26日にパブリックベータとして公開、2015年6月25日にv1.0正式リリースされた。Atom用に開発されたフレームワーク「Atom Shell」が後にElectron（2015年4月にリネーム）となった。AtomもCommand Palette（Ctrl+Shift+P / Cmd+Shift+P）を備えていた
- **一次ソース**: Wikipedia "Atom (text editor)"; Wikipedia "Electron (software framework)"
- **URL**: <https://en.wikipedia.org/wiki/Atom_(text_editor)>, <https://en.wikipedia.org/wiki/Electron_(software_framework)>
- **注意事項**: ElectronはAtom由来であり、VS CodeもElectron上に構築されている
- **記事での表現**: 2014年、GitHubがAtomエディタをパブリックベータとして公開した。Atom用に作られたフレームワーク「Atom Shell」は2015年にElectronと改名され、VS Codeを含む多数のデスクトップアプリの基盤となった

## 9. JetBrains IntelliJの「Search Everywhere」

- **結論**: IntelliJ IDEAのSearch Everywhere機能はダブルShiftで起動する。クラス検索（Ctrl+N）、ファイル検索（Ctrl+Shift+N）、シンボル検索（Ctrl+Alt+Shift+N）、アクション検索（Ctrl+Shift+A）を統合した機能。IntelliJ IDEA 13（2013年12月リリース）の頃にはDouble Shift to Search Everywhereが存在していた
- **一次ソース**: JetBrains Blog "Double Shift to Search Everywhere"; JetBrains IntelliJ IDEA Documentation
- **URL**: <https://blog.jetbrains.com/idea/2020/05/when-the-shift-hits-the-fan-search-everywhere/>, <https://www.jetbrains.com/help/idea/searching-everywhere.html>
- **注意事項**: IntelliJは「コマンドパレット」とは呼ばないが、実質的に同じUI/UXパターン
- **記事での表現**: JetBrainsのIntelliJ IDEAはダブルShiftで「Search Everywhere」を起動する。ファイル、シンボル、設定、アクションをすべて一つのテキスト入力で横断検索する

## 10. Jakob Nielsenの「Recognition over Recall」ヒューリスティック

- **結論**: Jakob Nielsenの「ユーザーインターフェースデザインのための10のユーザビリティヒューリスティック」の第6項「Recognition rather than recall（想起よりも再認）」は、ユーザーのメモリ負荷を最小限にし、オブジェクト、アクション、オプションを可視化すべきとする原則。GUIはこの原則に基づき、CLIは「想起」を要求する
- **一次ソース**: Nielsen Norman Group
- **URL**: <https://www.nngroup.com/articles/ten-usability-heuristics/>, <https://www.nngroup.com/videos/recognition-vs-recall/>
- **注意事項**: コマンドパレットは「CLIの想起」と「GUIの再認」を融合した設計であり、Nielsenのヒューリスティックの観点から見ると両者の長所を組み合わせた解決策
- **記事での表現**: コマンドパレットは、Nielsenが指摘した「想起（recall）」と「再認（recognition）」のギャップを橋渡しする。ユーザーはコマンド名の断片を「想起」し、システムが候補を「再認」可能な形で提示する
