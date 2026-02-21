# ファクトチェック記録: 第10回「Korn shell――"全部入り"への最初の挑戦」

## 1. David Kornとkshの開発・発表

- **結論**: David KornがBell Labsで開発し、1983年7月14日にUSENIXカンファレンス（トロント）で発表。1983年の発表タイトルは"KSH - A Shell Programming Language"。1994年のUSENIXシンポジウムで"ksh - An Extensible High Level Language"を発表（別の論文）。KornはBourne shellのソースコードをベースに開発を開始
- **一次ソース**: David G. Korn, "KSH - A Shell Programming Language", USENIX Conference Proceedings, Summer 1983, Toronto; KornShell Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/KornShell>, <https://www.oilshell.org/archive/ksh-usenix.pdf>, <http://www.kornshell.com/~dgk/>
- **注意事項**: ブループリントでは論文タイトルを"ksh - An Extensible High Level Language"としているが、これは1994年の論文。1983年の発表タイトルは"KSH - A Shell Programming Language"。記事ではUSENIX 1983での発表日（7月14日）を使用する
- **記事での表現**: 「1983年7月14日、David KornはトロントのUSENIXカンファレンスでKorn shellを発表した」

## 2. コマンドライン編集（emacs/viモード）の開発者

- **結論**: kshのviモードのコマンドライン編集はPat Sullivanが、emacsモードはMike Veachが、それぞれ独立にBourne shellを改造して実装していた。両者のコードがkshに統合された。kshはコマンドライン編集を組み込んだ最初のシェルである
- **一次ソース**: KornShell Wikipedia, HandWiki, AcademiaLab
- **URL**: <https://en.wikipedia.org/wiki/KornShell>, <https://handwiki.org/wiki/Software:KornShell>
- **注意事項**: 当初Kornはコマンドライン編集をシェルに組み込むことに否定的で、端末ドライバに移行されることを期待していた。しかしそれが実現しそうにないことが明らかになり、両モードを統合した
- **記事での表現**: 「kshはコマンドライン編集を組み込んだ最初のシェルだった。Pat Sullivanがviモードを、Mike Veachがemacsモードを実装した」

## 3. ksh88とksh93の分裂

- **結論**: ksh88は1988年版で、System V Release 4に採用された。POSIXシェル標準（IEEE Std 1003.2-1992）の基礎文書となった。ksh93は1993年に大幅改訂され、連想配列、浮動小数点演算、複合変数、discipline関数、名前参照変数、名前空間などの機能が追加された
- **一次ソース**: KornShell FAQ (kornshell.com), KornShell Wikipedia
- **URL**: <http://www.kornshell.com/doc/faq.html>, <http://www.kornshell.com/doc/ksh93.html>, <https://en.wikipedia.org/wiki/KornShell>
- **注意事項**: ksh88とksh93の間には互換性の問題がある（関数スコープの違い、ビルトインコマンドの検索順序の変更など）
- **記事での表現**: 「ksh88はSystem V Release 4に採用され、POSIXシェル標準の基礎となった。1993年の大幅改訂でksh93となり、連想配列、浮動小数点演算、複合変数など先進的な機能が追加された」

## 4. AT&Tライセンスとオープンソース化

- **結論**: 2000年まではAT&Tのプロプライエタリソフトウェア。2000年3月1日、ksh93iリリースで初めてソースコードが公開されたが、AT&T独自のライセンス（変更はパッチとしてのみ配布可能）。2005年初頭、ksh93qリリースでEclipse Public License (EPL) に変更
- **一次ソース**: KornShell Wikipedia, Slashdot "AT&T's Korn Shell Source Code Released" (2000-03-04)
- **URL**: <https://en.wikipedia.org/wiki/KornShell>, <https://tech.slashdot.org/story/00/03/04/1437214/atts-korn-shell-source-code-released>
- **注意事項**: 2000年のAT&Tライセンスは制約付きで真の「オープンソース」ではなかった。EPLへの移行（2005年）で初めて広義のOSSライセンスとなった
- **記事での表現**: 「2000年、AT&Tはksh93のソースコードを初めて公開した。ただし独自ライセンスで制約があり、本格的にオープンソース化されたのは2005年のEclipse Public License採用以降だ」

## 5. pdkshとmkshの系譜

- **結論**: AT&TのkshがプロプライエタリだったためPublic Domain Korn Shell（pdksh）が開発された。pdkshの開発は1999年に停止。2002年頃、MirBSDプロジェクトの一部としてmkshの開発が開始。OpenBSDのpdkshクリーンアップ作業（2003年頃）のコードを取り込み、他OSへの対応を追加。mkshは現在唯一アクティブに開発されているpdksh派生シェルであり、Androidのデフォルトシェルとしても採用
- **一次ソース**: MirBSD mksh page, mksh FAQ
- **URL**: <http://www.mirbsd.org/mksh.htm>, <http://www.mirbsd.org/mksh-faq.htm>, <https://en.wikipedia.org/wiki/KornShell>
- **注意事項**: pdkshは「Public Domain」を名乗るが、一部ファイルにはライセンス制約があった（mksh R21以降はこれらを除去）。mkshはAndroid採用により「最大のユーザベースを持つKorn shell派生」とも言われる
- **記事での表現**: 「AT&Tのkshが入手できなかった多くのユーザにとって、pdksh（Public Domain Korn Shell）が唯一の選択肢だった。pdkshの開発は1999年に終了し、その後継としてmkshが現在もアクティブに開発されている」

## 6. kshの機能: コプロセス

- **結論**: コプロセス機能はksh88（1988年）から存在。`|&`演算子でバックグラウンドプロセスとの双方向通信を実現。`read -p`で読み込み、`print -p`で書き込み。bashは4.0（2009年）で`coproc`キーワードとして導入。zshも独自の構文でサポート
- **一次ソース**: IBM AIX documentation, Linux Journal
- **URL**: <https://www.ibm.com/docs/ssw_aix_71/osmanagement/HT_korn_shell_coprocess_facil.html>, <https://www.linuxjournal.com/content/bash-co-processes>
- **注意事項**: kshのコプロセスとbashのcoprocは構文が異なる
- **記事での表現**: 「コプロセスはksh88から存在する機能で、バックグラウンドプロセスとの双方向通信を可能にする。bashが同等の機能を導入したのは4.0（2009年）になってからだ」

## 7. kshの機能: FPATH/autoload

- **結論**: FPATHはksh独自の環境変数で、コロン区切りのディレクトリリスト。`autoload`（`typeset -fu`のエイリアス）で関数名を登録し、実際に呼び出されたときにFPATHのディレクトリからスクリプトを探して読み込む。PATHの関数版。zshにも同様の機能がある
- **一次ソース**: O'Reilly "Korn Shell Programming by Example", Dr Dobb's
- **URL**: <https://www.oreilly.com/library/view/korn-shell-programming/0789724650/0789724650_app01lev1sec2.html>, <https://www.drdobbs.com/creating-global-functions-with-the-korn/199101137>
- **注意事項**: bashにはFPATH/autoloadに相当する機能がない（エミュレーションは可能だが標準では提供されていない）
- **記事での表現**: 「FPATHとautoload機構は、関数の遅延読み込みを実現するkshの先進的な機能だ。bashには相当する機構がない」

## 8. ksh88がPOSIXシェル標準の基礎

- **結論**: ksh88はIEEE Std 1003.2-1992（POSIX Shell and Utilities）の主要な基礎文書となった。POSIXシェル標準はBourne shellとksh88の機能をベースに策定された。算術展開`$((...))`はkshが導入しPOSIXが標準化した
- **一次ソース**: O'Reilly "Learning the Korn Shell" Appendix, kornshell.com
- **URL**: <https://docstore.mik.ua/orelly/unix3/korn/appa_03.htm>, <http://www.kornshell.com/doc/ksh93.html>
- **注意事項**: POSIXシェル標準はksh88の「サブセット」であり、ksh88の全機能がPOSIXに含まれるわけではない
- **記事での表現**: 「ksh88はPOSIXシェル標準（IEEE Std 1003.2-1992）の基礎文書となった。POSIXのシェル仕様は、Bourne shellとksh88の機能を土台として策定された」

## 9. kshからbashへの影響

- **結論**: bashはkshから多くの機能を取り込んだ。拡張グロビング（`extglob`: `@()`, `+()`, `*()`等）はksh93由来。算術展開`$((...))`はksh由来（POSIX経由で標準化）。連想配列はksh93が先行（bash 4.0が2009年に導入、ksh93は1993年時点で実装済み）
- **一次ソース**: Greg's Wiki, Linux Journal
- **URL**: <https://mywiki.wooledge.org/ArithmeticExpression>, <https://www.linuxjournal.com/content/bash-extended-globbing>
- **注意事項**: bashの`extglob`オプションはデフォルトでは無効。`shopt -s extglob`で有効化が必要
- **記事での表現**: 「bashの拡張グロビング（extglob）はksh93から直接借用した機能だ。`@()`、`+()`、`*()`、`!()`パターンはkshが先に実装した」

## 10. ksh93のコミュニティフォーク（ksh2020とksh93u+m）

- **結論**: AT&Tは2017年にAST（Advanced Software Technology）プロジェクトをksh93にフォーカス。Red Hatが顧客要望で開発に参加し、2019年秋にksh2020をリリース。しかし互換性問題やパフォーマンス低下が報告され、2020年3月にAT&Tはksh2020の変更をロールバック。これを受けてコミュニティが2020年5月にksh93u+m（最後の安定版ksh93u+ 2012-08-01ベース）のリポジトリを作成し、バグ修正開発を継続中
- **一次ソース**: GitHub ksh93/ksh, GitHub att/ast issues
- **URL**: <https://github.com/ksh93/ksh>, <https://github.com/att/ast/issues/1466>, <https://github.com/ksh2020/ksh>
- **注意事項**: ksh93u+mが現在のksh93の事実上の後継。AT&T自身はもはやアクティブに開発していない
- **記事での表現**: 「2020年、AT&Tのkshリポジトリはksh2020の互換性問題を受けてロールバックされた。現在はコミュニティ主導のksh93u+mが開発を継続している」

## 11. ksh93の先進的機能: 複合変数・discipline関数・名前空間

- **結論**: ksh93は複合変数（compound variables: C言語の構造体に相当）、discipline関数（変数の参照・代入時にフック関数を実行できる「アクティブ変数」機構）、名前空間（namespace）をサポート。これらの機能は他のシェルにはない独自のもの
- **一次ソース**: kornshell.com FAQ, IBM AIX documentation
- **URL**: <http://www.kornshell.com/doc/faq.html>, <https://www.ibm.com/docs/en/aix/7.2.0?topic=shell-enhanced-korn-ksh93>, <https://blog.fpmurphy.com/2009/01/ksh93-compound-variables_05.html>
- **注意事項**: これらの機能はksh93を「シェル」を超えた「プログラミング言語」へと押し上げたが、同時に複雑さも増した
- **記事での表現**: 「ksh93の複合変数はC言語の構造体に相当し、discipline関数はオブジェクト指向言語のgetter/setterに近い概念をシェルに持ち込んだ」
