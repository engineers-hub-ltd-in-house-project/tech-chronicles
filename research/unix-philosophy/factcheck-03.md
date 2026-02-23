# ファクトチェック記録：第3回「Ken ThompsonとDennis Ritchie——二人の天才が残したもの」

## 1. Dennis Ritchieの訃報とSteve Jobsとの報道格差

- **結論**: Dennis Ritchieは2011年10月12日に自宅（ニュージャージー州バークレーハイツ）で死去。享年70歳。Steve Jobsは2011年10月5日に死去。Ritchieの死は世間でほとんど報じられなかった
- **一次ソース**: Washington Post obituary, CNN "Dennis Ritchie: The shoulders Steve Jobs stood on"
- **URL**: <https://www.washingtonpost.com/local/obituaries/dennis-ritchie-founder-of-unix-and-c-dies-at-70/2011/10/13/gIQAXsVXiL_story.html>, <https://www.cnn.com/2011/10/14/tech/innovation/dennis-ritchie-obit-bell-labs/index.html>
- **注意事項**: Rob Pikeの言葉「Dennis had a bigger effect, and the public doesn't even know who he is」。Brian Kernighanの言葉「The tools that Dennis built—and their direct descendants—run pretty much everything today」
- **記事での表現**: 2011年10月12日の訃報、Steve Jobsの死（10月5日）の1週間後、世間の報道の格差について言及

## 2. Ken Thompsonの経歴

- **結論**: Kenneth Lane Thompson、1943年2月4日ニューオーリンズ生まれ。UCバークレーで電気工学・コンピュータサイエンスの学士（1965年）・修士（1966年）取得。1966年Bell Labs入社。チェスプログラム、正規表現、B言語、Plan 9、Go言語に至るキャリア
- **一次ソース**: Wikipedia, ACM Turing Award page, Computer History Museum
- **URL**: <https://en.wikipedia.org/wiki/Ken_Thompson>, <https://amturing.acm.org/award_winners/thompson_4588371.cfm>
- **注意事項**: 父は米海軍の戦闘機パイロット。家族は数年ごとに引っ越し
- **記事での表現**: 1943年生まれ、UCバークレーで学位取得、1966年Bell Labs入社として記述

## 3. Dennis Ritchieの経歴

- **結論**: Dennis MacAlistair Ritchie、1941年9月8日ニューヨーク州ブロンクスビル生まれ。ニュージャージー州サミットで育つ。父Alistair RitchieはBell Labsのエンジニア（スイッチング理論の専門家）。ハーバード大学で物理学の学士号（1963年）取得。数学のPhD課程に進むも完了せず。Bell Labsに入社
- **一次ソース**: Wikipedia, Britannica, EBSCO Research Starters
- **URL**: <https://en.wikipedia.org/wiki/Dennis_Ritchie>, <https://www.britannica.com/biography/Dennis-M-Ritchie>
- **注意事項**: Ritchie自身「物理学者になるには十分に賢くないと思った」と述べている。UNIVAC Iに関する講義がコンピュータへの興味のきっかけ。PhD取得について、一部の資料では「1968年にPhD取得」とし、他の資料では「完了せず」としている。Ritchie自身が述べたところでは博士論文の審査が行われることはなかった
- **記事での表現**: 1941年生まれ、ハーバード大学で物理学を学び、Bell Labsに入社として記述

## 4. C言語の開発経緯

- **結論**: B言語（Ken Thompson、1969年頃開発）→ NB（New B）→ C言語（Dennis Ritchie、1971〜1973年に開発）。B言語は型なし言語であり、その制約がCの開発動機となった。1973年初頭にはCの本質的部分が完成し、同年夏にPDP-11向けUNIXカーネルがCで書き直された
- **一次ソース**: Dennis Ritchie, "The Development of the C Language", 1993
- **URL**: <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/chist.html>
- **注意事項**: B言語はBCPL（Martin Richards、1967年）に由来する。ThompsonがB言語を設計し、RitchieがCに発展させた
- **記事での表現**: B言語からNB、Cへの発展過程を正確に記述。1971〜1973年の開発期間

## 5. UNIXカーネルのC言語による書き直し

- **結論**: 1973年、Version 4 UNIXでカーネルがC言語で書き直された。これはOSを高級言語で書き直した画期的な出来事。ただしVersion 4にはまだPDP-11依存のコードが多く、最初の他プラットフォームへの移植は1978年のInterdata 8/32。1983年時点でUNIXカーネルは2万行未満のコードで構成され、75%以上がマシン非依存
- **一次ソース**: History of Unix (Wikipedia), Tom's Hardware (Unix v4 recovery article)
- **URL**: <https://en.wikipedia.org/wiki/History_of_Unix>, <https://www.tomshardware.com/software/linux/unix-v4-recovered-from-randomly-found-tape-at-university-of-utah-only-known-copy-of-first-os-version-with-kernel-and-core-utilities-written-in-c>
- **注意事項**: 移植性の獲得は即座ではなく段階的だった。Version 6（1975年）が外部配布の最初の版
- **記事での表現**: 1973年のVersion 4でCによる書き直し、移植性の獲得は段階的であったことを明記

## 6. チューリング賞受賞（1983年）

- **結論**: Ken ThompsonとDennis Ritchieは1983年にACMチューリング賞を共同受賞。受賞理由は「for their development of generic operating systems theory and specifically for the implementation of the UNIX operating system」
- **一次ソース**: ACM Turing Award公式ページ
- **URL**: <https://amturing.acm.org/award_winners/thompson_4588371.cfm>, <https://amturing.acm.org/award_winners/ritchie_1506389.cfm>
- **注意事項**: Thompsonの受賞講演は「Reflections on Trusting Trust」——コンパイラバックドアに関する先駆的論文
- **記事での表現**: 1983年チューリング賞共同受賞、受賞理由の原文引用

## 7. K&R本『The C Programming Language』

- **結論**: 初版は1978年2月22日にPrentice Hallから出版。Brian KernighanとDennis Ritchieの共著。KernighanがC言語の最初の広く入手可能な書籍の本文を執筆し、Ritchieのリファレンスマニュアルが付録となった。第2版は1988年4月にANSI C対応として出版
- **一次ソース**: Wikipedia "The C Programming Language"
- **URL**: <https://en.wikipedia.org/wiki/The_C_Programming_Language>
- **注意事項**: 初版で記述されたCのバージョンは「K&R C」と呼ばれる
- **記事での表現**: 1978年出版、K&R Cの標準としての役割

## 8. Doug McIlroyによるパイプの発明

- **結論**: McIlroyは1964年のメモでパイプのアイデアを提案。「We should have some ways of connecting programs like garden hose」。実装は1973年1月15日、Ken Thompsonが「one feverish night」でpipe()システムコールを実装。Version 3 UNIXに導入
- **一次ソース**: McIlroy自身の記述, Unix Heritage Wiki
- **URL**: <https://en.wikipedia.org/wiki/Douglas_McIlroy>, <https://wiki.tuhs.org/doku.php?id=features:pipes>
- **注意事項**: McIlroyの有名な言葉「The next day saw an unforgettable orgy of one-liners as everybody joined in the excitement of plumbing」
- **記事での表現**: 第2回で既に言及済み。本回では簡潔に触れる

## 9. Ken ThompsonのBelleチェスコンピュータ

- **結論**: ThompsonとJoseph Condonが開発。1980年にリンツ（オーストリア）で開催された第3回世界コンピュータチェス選手権で優勝。ACM北米コンピュータチェス選手権で5回優勝。専用チェスハードウェアを使用して優勝した最初のシステム
- **一次ソース**: Wikipedia "Belle (chess machine)", Chessprogramming wiki
- **URL**: <https://en.wikipedia.org/wiki/Belle_(chess_machine)>, <https://www.chessprogramming.org/Belle>
- **注意事項**: エンドゲームテーブルベース（4、5、6ピースのすべての終盤局面の完全列挙）も開発
- **記事での表現**: Belleの世界チャンピオン獲得とエンドゲームテーブルベースに言及

## 10. Ken ThompsonとGo言語

- **結論**: Go言語は2007年9月21日にRobert Griesemer、Rob Pike、Ken Thompsonの3人がGoogleのホワイトボードで目標のスケッチを始めた。2009年11月に公開発表。2012年3月にバージョン1.0リリース。Thompsonは2006年からGoogleに勤務
- **一次ソース**: Go公式ブログ, Wikipedia
- **URL**: <https://go.dev/blog/first-go-program>, <https://en.wikipedia.org/wiki/Go_(programming_language)>
- **注意事項**: CとUNIXの設計哲学がGoにも反映されている（シンプルさ、合成可能性）
- **記事での表現**: 2006年Google入社後、Rob PikeとRobert Griesemerと共にGo言語を設計

## 11. Ken Thompsonの正規表現への貢献

- **結論**: 1968年、Communications of the ACMに「Regular Expression Search Algorithm」を発表。QEDテキストエディタに正規表現を実装。Thompson構成法（正規表現からNFAへの変換アルゴリズム）を発明。JITコンパイル的手法でIBM 7094のマシンコードに変換して高速マッチングを実現
- **一次ソース**: Thompson, "Regular Expression Search Algorithm", CACM 1968
- **URL**: <https://dl.acm.org/doi/10.1145/363347.363387>
- **注意事項**: 今日のほぼすべての正規表現実装はThompsonの表記法の変種を使用
- **記事での表現**: 1968年のCACM論文、QEDエディタでの実装、Thompson構成法

## 12. Brian Kernighanの文書化の功績

- **結論**: 『The UNIX Programming Environment』（Rob Pikeとの共著、1984年）、『The C Programming Language』（Ritchieとの共著、1978年）、ditroffの開発。UNIXの設計哲学を文書化し広く伝えた功績
- **一次ソース**: Wikipedia "Brian Kernighan"
- **URL**: <https://en.wikipedia.org/wiki/Brian_Kernighan>
- **注意事項**: KernighanはUNIXのコードを書いたわけではないが、その哲学を言語化し広めた
- **記事での表現**: UNIXの思想の「語り部」としてのKernighanの役割

## 13. Joe Ossannaの貢献

- **結論**: Joseph Frank Ossanna, Jr.（1928年12月10日〜1977年11月28日）。Bell Labsのエンジニア・プログラマ。Multicsの開発に参加した後、UNIXの初期開発メンバーとなる。roffをnroffとして書き直し、さらにtroff（1973年、当初PDP-11アセンブリ、後にCで書き直し）を開発
- **一次ソース**: Wikipedia "Joe Ossanna", Wikipedia "Troff"
- **URL**: <https://en.wikipedia.org/wiki/Joe_Ossanna>, <https://en.wikipedia.org/wiki/Troff>
- **注意事項**: 1977年に死去、troffの他デバイス対応はKernighanが引き継いだ
- **記事での表現**: UNIX初期メンバーの一人としてroff/troffの開発に言及
