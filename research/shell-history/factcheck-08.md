# ファクトチェック記録：第8回「tcshとコマンドライン編集――シェルがUIになった瞬間」

## 1. tcshの起源とKen Greer

- **結論**: Ken Greerはカーネギーメロン大学で1975年9月にTENEXスタイルのファイル名補完コードの開発を開始し、1981年12月にC shellにマージした。Mike Ellisが1983年9月にFairchild A.I. Labsでコマンド補完を追加。1983年10月3日、Greerがnet.sourcesニュースグループにソースを投稿した。
- **一次ソース**: tcsh Wikipedia, tcsh公式ドキュメント
- **URL**: <https://en.wikipedia.org/wiki/Tcsh>
- **注意事項**: ブループリントでは「1983年, Ken Greer, カーネギーメロン大学」とあるが、開発開始は1975年9月、C shellへのマージは1981年12月、net.sourcesへの投稿は1983年10月。コマンド補完の追加はMike Ellis（1983年9月）による。
- **記事での表現**: Ken Greerが1975年からTENEXスタイル補完の開発を開始し、1981年にcshにマージ、1983年に公開された経緯を正確に記述する。

## 2. TENEXオペレーティングシステムとコマンド補完の起源

- **結論**: TENEXは1969年にBBN（Bolt, Beranek and Newman）でDaniel MurphyとDaniel Bobrowらにより開発されたPDP-10用タイムシェアリングOS。「エスケープ認識（escape recognition）」という仕組みでコマンド補完を実現した。ユーザが部分的なコマンドを入力してEscapeキーを押すと、システムが残りを補完した。「?」を入力するとマッチするコマンドのリストを表示した。
- **一次ソース**: TENEX Wikipedia, Command-line completion Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/TENEX_(operating_system)>, <https://en.wikipedia.org/wiki/Command-line_completion>
- **注意事項**: コマンド補完の最初の例はBerkeley Timesharing System for SDS 940とされる。TENEXはEscapeキーをトリガーとする「明示的補完」を導入した点が革新的。
- **記事での表現**: TENEXがEscapeキーによるコマンド補完を実現し、tcshの「t」の由来となったことを記述。

## 3. Paul Placewayの貢献

- **結論**: Paul Placewayはオハイオ州立大学（Ohio State University）でtcshの開発を引き継ぎ、長年のメンテナを務めた。Readlineの再表示コードでBrian Foxを支援した記録もある。
- **一次ソース**: tcsh Linux Wiki, Chet Ramey: Geek of the Week
- **URL**: <https://linux.fandom.com/wiki/Tcsh>, <https://www.red-gate.com/simple-talk/opinion/geek-of-the-week/chet-ramey-geek-of-the-week/>
- **注意事項**: ブループリントでは「Paul Placewayによる拡張」とある。彼はtcshの主要な開発者・メンテナとして位置づけられる。
- **記事での表現**: Paul Placewayがオハイオ州立大学でtcshの開発を引き継ぎ、長期メンテナンスを担ったことを記述。

## 4. GNU Readlineの誕生

- **結論**: GNU Readlineは1988年にFSF（Free Software Foundation）の従業員Brian Foxにより、POSIXが要求するシェルの行編集機能を実装するために作成された。最初の公開リリースは1989年、Bash 1.14に非分離モジュールとして同梱。バージョン1.05以降、Chet Ramey（Case Western Reserve University）がメンテナンスを引き継ぎ、1998年以降は唯一のメンテナ。
- **一次ソース**: GNU Readline Wikipedia, Brian Fox Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/GNU_Readline>, <https://en.wikipedia.org/wiki/Brian_Fox_(computer_programmer)>
- **注意事項**: ブループリントでは「GNU Readline（1985年, Brian Fox）」とあるが、実際の作成は1988年。Brian Foxが1985年にFSFに参加したのは事実だが、Readline自体は1988年作成。
- **記事での表現**: 1988年にBrian Foxが作成、1989年にBash 1.14とともに公開されたと正確に記述する。

## 5. kshのコマンドライン編集（emacsモード/viモード）

- **結論**: KornShell（ksh）は1983年にDavid Korn（Bell Labs）により発表され、最初にコマンドライン編集機能（emacsモードとviモード）を実装したシェルとされる。emacsモードはMike Veach、viモードはPat Sullivanが実装した。
- **一次ソース**: KornShell Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/KornShell>
- **注意事項**: kshがシェルとして最初にコマンドライン編集を実装した点は複数ソースで確認。ただしtcshのファイル名補完（1981年マージ）とは異なる機能カテゴリ。
- **記事での表現**: kshが1983年にemacs/viモードのコマンドライン編集を導入し、tcshとは異なるアプローチで対話的操作を改善した経緯を記述。

## 6. termcapとterminfo

- **結論**: termcapはBill Joyが1978年にBerkeley Unix用に最初のライブラリを作成した。端末の能力（カーソル移動、画面消去、色変更等）をデータベースに記録し、プログラムが端末非依存で動作できるようにした。terminfoはtermcapの後継で、コンパイル済みデータベースを使用しncurses等が利用する。
- **一次ソース**: Termcap Wikipedia, Terminfo Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Termcap>, <https://en.wikipedia.org/wiki/Terminfo>
- **注意事項**: termcapの設計はMITのIncompatible Timesharing System（ITS）のターミナルデータストアに影響を受けた。
- **記事での表現**: コマンドライン編集を実現するための基盤技術として、termcap（1978年、Bill Joy）とterminfoを解説。

## 7. viモード vs emacsモードの歴史

- **結論**: kshが1983年にemacs/viモードを最初に実装。GNU Readlineはデフォルトでemacsキーバインドを採用し、`set -o vi`でviモードに切り替え可能。inputrcファイルで`set editing-mode vi`を指定することでも切り替え可能。
- **一次ソース**: GNU Bash Reference Manual, Readline ArchWiki
- **URL**: <https://www.gnu.org/software/bash/manual/html_node/Readline-vi-Mode.html>, <https://wiki.archlinux.org/title/Readline>
- **注意事項**: emacsモードがデフォルトである理由はRichard Stallman（Emacsの作者）がGNUプロジェクトの創始者であることと関連。
- **記事での表現**: emacsモードとviモードの対立の歴史的背景と、Readlineがデフォルトでemacsを選んだ設計判断を記述。

## 8. bash-completionプロジェクト

- **結論**: bash-completionプロジェクトはIan Macdonaldにより作成された。プログラマブル補完関数のコレクションで、現在はGitHub（scop/bash-completion）でメンテナンスされている。
- **一次ソース**: GitHub bash-completion, GNU Bash Manual
- **URL**: <https://github.com/scop/bash-completion/>, <https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html>
- **注意事項**: bashのプログラマブル補完機能（complete, compgen等）自体はbash 2.04（2000年頃）で導入された。
- **記事での表現**: tcshの補完機能がbashのプログラマブル補完に影響を与えた系譜として言及。

## 9. inputrcとReadlineの設定アーキテクチャ

- **結論**: Readlineの設定ファイルは`~/.inputrc`（環境変数INPUTRCで変更可能）。emacs/viモードの切り替え、キーバインドのカスタマイズ、条件構文（$if）によるアプリケーション別設定が可能。キーマップ名としてemacs, emacs-standard, emacs-meta, emacs-ctlx, vi, vi-move, vi-command, vi-insertが定義されている。
- **一次ソース**: GNU Readline Library, Readline ArchWiki
- **URL**: <https://tiswww.case.edu/php/chet/readline/readline.html>, <https://wiki.archlinux.org/title/Readline>
- **注意事項**: Readlineを使用するプログラムは多数あり（bash, gdb, python REPL等）、inputrcの設定がこれらすべてに影響する。
- **記事での表現**: Readlineが入力編集をライブラリとして分離したアーキテクチャの重要性と、inputrcによる統一設定の利点を記述。

## 10. Christos Zoulasとtcshの現在

- **結論**: 1990年代にChristos Zoulasがtcshのリードメンテナとなり、現在（2025年時点）もメンテナンスを継続している。最新安定版は6.24.16（2025年7月9日リリース）。
- **一次ソース**: tcsh Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Tcsh>
- **注意事項**: tcshは非常に安定しているが、年に1回程度のバグ修正リリースが続いている。
- **記事での表現**: tcshが40年以上にわたりメンテナンスされ続けている事実に言及。

## 11. TOPS-20とコマンド補完のシステムコール化

- **結論**: TENEXの後継であるTOPS-20は、コマンド補完機能をコマンドインタプリタからOS自体に移した（COMND JSYSシステムコール）。これにより任意のプログラムが補完機能を利用可能になった。
- **一次ソース**: Command-line completion Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Command-line_completion>
- **注意事項**: この「補完のシステムレベル化」は、後のGNU Readlineの「補完のライブラリ化」と思想的に通じる。
- **記事での表現**: TENEXからTOPS-20への進化における補完のシステムレベル化が、Readlineのライブラリ化に通じる設計思想であることを指摘。

## 12. tcshのプログラマブル補完（complete builtin）

- **結論**: tcshはcompleteビルトインコマンドにより、プログラマブル補完を提供する。ファイル名・コマンド名・変数名のデフォルト補完に加え、任意のコマンドに対するカスタム補完ルールを定義できる。
- **一次ソース**: tcsh man page (Ubuntu), O'Reilly "Using csh & tcsh"
- **URL**: <https://manpages.ubuntu.com/manpages/trusty/man1/tcsh.1.html>, <https://www.oreilly.com/library/view/using-csh/9781449377526/ch10.html>
- **注意事項**: tcshのcomplete構文はbashのcomplete構文とは異なるが、概念的には同等。
- **記事での表現**: tcshが単なるファイル名補完を超えてプログラマブル補完を実現した事実を記述。
