# ファクトチェック記録：第7回「C shell――Bill JoyのBourne shellへの反乱」

## 1. Bill Joyの経歴とC shellの開発

- **結論**: William Nelson Joy（1954年11月8日生まれ）はUCバークレーの大学院生としてC shellを開発した。ミシガン大学で1975年に電気工学の学士号を取得後、バークレーに進学。Bob FabryのComputer Systems Research Group（CSRG）でBSDの開発に携わった。1979年にMS（電気工学・計算機科学）を取得。viエディタの開発者でもあり、1982年にSun Microsystemsを共同設立した
- **一次ソース**: Bill Joy, Wikipedia; UC Berkeley Engineering
- **URL**: <https://en.wikipedia.org/wiki/Bill_Joy>, <https://engineering.berkeley.edu/bill-joy-co-founder-of-sun-microsystems/>
- **注意事項**: viの開発は1976年頃から開始（exの拡張として）
- **記事での表現**: UCバークレーの大学院生だったBill Joyが1970年代後半にC shellを開発した

## 2. C shellのリリース時期と2BSD

- **結論**: C shellは2BSD（Second Berkeley Software Distribution）の一部として1979年5月にリリースされた。2BSDにはvi（exのビジュアルモード）とC shellという2つの重要なプログラムが含まれていた。Joyが2BSDを最初に配布したのは1978年とする記述もあるが、正式リリースは1979年5月
- **一次ソース**: Berkeley Software Distribution, Wikipedia; History of BSD, Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Berkeley_Software_Distribution>, <https://en.wikipedia.org/wiki/History_of_the_Berkeley_Software_Distribution>
- **注意事項**: ブループリントには「1978年, 2BSD」とあるが、2BSDの正式リリースは1979年5月。開発は1978年から行われていたが、配布は1979年。記事では「1970年代後半に開発、1979年に2BSDとして配布」と正確に記述する
- **記事での表現**: Bill Joyが1970年代後半に開発し、1979年5月に2BSDの一部としてリリースされた

## 3. C shellの初期貢献者

- **結論**: Bill Joy以外の初期貢献者として、Michael Ubell、Eric Allman、Mike O'Brien、Jim Kulpが挙げられている
- **一次ソース**: C shell, Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/C_shell>
- **注意事項**: Eric Allmanはsendmailやsyslogでも知られる人物
- **記事での表現**: JoyのほかにMichael Ubell、Eric Allman、Mike O'Brien、Jim Kulpらが初期の貢献者として記録されている

## 4. C shellの対話的機能の革新

- **結論**: C shellが導入した主要な対話的機能は、ヒストリ機構、エイリアス、ディレクトリスタック、チルダ記法（~）、cdpath、ジョブコントロール、パスハッシュ。ヒストリ機構はINTERLISPのredoに類似した仕組みとして設計された。これらの機能は後に他のシェルにコピーされた
- **一次ソース**: C shell, Wikipedia; Bill Joy, "An Introduction to the C shell", FreeBSD Archives
- **URL**: <https://en.wikipedia.org/wiki/C_shell>, <https://docs-archive.freebsd.org/44doc/usd/04.csh/paper.html>
- **注意事項**: ヒストリ機構の「!」（bang）コマンドはcsh固有の記法
- **記事での表現**: cshはヒストリ機構、エイリアス、チルダ展開、ジョブコントロールなど、今日のシェルに引き継がれる対話的機能を初めて導入した

## 5. ジョブコントロールの実装者と経緯

- **結論**: ジョブコントロールとディレクトリスタック機能は、オーストリア・ラクセンブルクのIIASA（国際応用システム分析研究所）のJ.E. Kulp（Jim Kulp）が最初に実装した。ただし、当初の構文は現在のものとは異なっていた。4.1BSDカーネルの機能を利用して実装された。後にKorn shellが採用し、SVR4版Bourne shellにも組み込まれた
- **一次ソース**: Job control (Unix), Wikipedia; csh(1) OpenBSD manual
- **URL**: <https://en.wikipedia.org/wiki/Job_control_(Unix)>, <https://man.openbsd.org/csh.1>
- **注意事項**: fg, bg, Ctrl-Zの現在の構文はKulpのオリジナルとは異なる
- **記事での表現**: ジョブコントロールはIIASAのJim Kulpが最初に実装し、4.1BSDカーネルの機能を利用した

## 6. C言語風の構文設計

- **結論**: cshの式評価はCの文法と演算子をほぼそのまま取り込んだ。Bourne shellが条件評価に外部コマンドtestを使用していたのに対し、cshはシェル内蔵の式評価器を持ち、直接式を評価できた。これにより高速だった。cshの制御構文（if/then/endif, foreach/end, switch/case/endsw）はC言語に類似しており、Bourne shellのALGOL 68由来の逆転キーワード（fi, esac, done）とは対照的。ただし演算子の結合規則がCとは異なり、cshでは右から左（Cでは多くの演算子が左から右）
- **一次ソース**: C shell, Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/C_shell>
- **注意事項**: 「C風構文」は対話的利用とスクリプティングの両面に影響を与えた
- **記事での表現**: cshの式文法はCの演算子をほぼそのまま取り込み、外部コマンドtestに頼るBourne shellより高速に条件評価を実行できた

## 7. Tom Christiansen "Csh Programming Considered Harmful"

- **結論**: Tom Christiansenがcomp.unix.shellなどに投稿した文書。日付は1996年10月6日（ブループリントでは1995年だが、正確には1996年）。バージョン履歴に「csh-faq,v 1.7 95/09/28」とあり、1995年から開発されていたが、公開は1996年。cshのスクリプティング用途を「有害」として批判した。具体的問題点：ファイルディスクリプタ操作の制限、シグナルハンドリングの制限（SIGINTのみ）、アドホックなパーサー（実行前に全体をパースしない）、パイプと制御構造の組み合わせ不可
- **一次ソース**: Tom Christiansen, "Csh Programming Considered Harmful"
- **URL**: <https://www-uxsup.csx.cam.ac.uk/misc/csh.html>, <http://harmful.cat-v.org/software/csh>
- **注意事項**: ブループリントは1995年としているが、正確には1996年10月。記事では「1990年代半ば」と表現するか、正確に1996年とするのが妥当
- **記事での表現**: Tom Christiansenの1996年の文書 "Csh Programming Considered Harmful" はcshのスクリプティングの問題を体系的に指摘した

## 8. cshスクリプティングの具体的問題点

- **結論**: (1) アドホックなパーサー（実行前に全体をパースせず、実行しながらパースする）、(2) ファイルディスクリプタ操作がstdin/stdoutのリダイレクトとstderrのstdoutへのdup程度しかできない、(3) シグナルハンドリングがSIGINTのtrapのみ（Bourne shellは任意のシグナルをtrap可能）、(4) パイプを制御構造の中に組み込めない、(5) マルチラインの複合コマンドの扱いに問題
- **一次ソース**: Tom Christiansen, "Csh Programming Considered Harmful"; "Top Ten Reasons not to use the C shell", grymoire.com
- **URL**: <https://www-uxsup.csx.cam.ac.uk/misc/csh.html>, <https://www.grymoire.com/unix/CshTop10.txt>
- **注意事項**: これらの制限はスクリプティングにのみ該当し、対話的利用では問題にならない
- **記事での表現**: cshのパーサーはアドホックで、ファイルディスクリプタ操作・シグナルハンドリング・パイプと制御構造の組み合わせに致命的な制限がある

## 9. BSD vs System V の分裂とシェル文化

- **結論**: 1980年代にUNIXはAT&TのSystem VとBSDの2大系統に分裂した。技術的にはソケット vs ストリーム、BSD tty vs System V termioなどの違いがあった。文化的にはプログラマ・技術者がBSD側、ビジネス指向がSystem V側に分かれる傾向があった。シェルにおいては、BSDではcshがデフォルト的な対話シェル、System Vでは/bin/sh（Bourne shell）が標準だった。1987年にAT&TとSunが統合に着手し、1988年にSVR4としてリリース。TCP/IPネットワーキングはBSD 4.2が先行して組み込んでおり、System Vにはなかった
- **一次ソース**: Unix wars, Wikipedia; Berkeley Software Distribution, Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Unix_wars>, <https://en.wikipedia.org/wiki/Berkeley_Software_Distribution>
- **注意事項**: 「BSDではcshがデフォルト」は正確には対話的シェルとしての普及であり、/bin/shはBSDにも存在した
- **記事での表現**: 1980年代のBSD vs System Vの分裂はOSだけでなくシェル文化の分裂も生んだ

## 10. cshのヒストリ機構とINTERLISP

- **結論**: Bill Joyの "An Introduction to the C shell" によれば、cshのヒストリ機構はINTERLISPのredo機能に類似したものとして設計された。「!」（bang）文字がヒストリ置換の開始記号。「!!」で直前のコマンドを再実行、「!n」でイベント番号n、「!string」でstringで始まる直近のコマンドを参照
- **一次ソース**: Bill Joy, "An Introduction to the C shell", FreeBSD Documentation Archives
- **URL**: <https://docs-archive.freebsd.org/44doc/usd/04.csh/paper.html>
- **注意事項**: INTERLISPはBBN（Bolt Beranek and Newman）が開発したLISP処理系
- **記事での表現**: cshのヒストリ機構はINTERLISPのredo機能から着想を得た
