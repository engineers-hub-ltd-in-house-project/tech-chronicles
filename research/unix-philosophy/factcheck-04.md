# ファクトチェック記録：第4回「"Do one thing and do it well"——単一責務の起源」

## 1. Doug McIlroyのUNIX哲学の原典

- **結論**: McIlroyは1978年7月、Bell System Technical Journal Vol. 57, No. 6のUNIX特集号の序文（Foreword）で、UNIX哲学を初めて文書化した。共著者はE. N. PinsonとB. A. Tague。pp. 1902-1903
- **一次ソース**: M.D. McIlroy, E.N. Pinson, B.A. Tague, "UNIX Time-Sharing System: Foreword", The Bell System Technical Journal, Vol. 57, No. 6, Part 2, July-August 1978
- **URL**: <https://archive.org/details/bstj57-6-1899>, <https://onlinelibrary.wiley.com/doi/10.1002/j.1538-7305.1978.tb02135.x>
- **注意事項**: よく引用される「Write programs that do one thing and do it well. Write programs to work together. Write programs to handle text streams, because that is a universal interface.」はPeter Salusが1994年に簡潔にまとめたバージョン。原文はより長い箇条書き形式で記載されている
- **記事での表現**: McIlroyの1978年BSTJ序文の原文を正確に引用し、Salusの簡略版と区別する

## 2. McIlroyの1978年BSTJ序文の具体的内容

- **結論**: 原文の箇条書きは以下の通り: (1) Make each program do one thing well. To do a new job, build afresh rather than complicate old programs by adding new "features". (2) Expect the output of every program to become the input to another, as yet unknown, program. Don't clutter output with extraneous information. Avoid stringently columnar or binary input formats. Don't insist on interactive input. (3) Design and build software, even operating systems, to be tried early, ideally within weeks. Don't hesitate to throw away the clumsy parts and rebuild them. (4) Use tools in preference to unskilled help to lighten a programming task, even if you have to detour to build the tools and expect to throw some of them out after you've finished using them.
- **一次ソース**: McIlroy et al., "UNIX Time-Sharing System: Foreword", BSTJ, 1978
- **URL**: <https://danluu.com/mcilroy-unix/>
- **注意事項**: Bergsonの引用文「Intelligence...is the faculty of making artificial objects, especially tools to make tools.」で序文が始まる
- **記事での表現**: 4つの原則を原文のまま引用し、各原則の意味を解説する

## 3. Peter Salusの三原則（1994年）

- **結論**: Peter H. Salusは『A Quarter Century of UNIX』（Addison-Wesley, 1994年）でUNIX哲学を3原則に簡潔化した: (1) Write programs that do one thing and do it well. (2) Write programs to work together. (3) Write programs to handle text streams, because that is a universal interface. この簡潔版がMcIlroyの言葉として広く引用される
- **一次ソース**: Peter H. Salus, "A Quarter Century of UNIX", Addison-Wesley, 1994, ISBN 0-201-54777-5
- **URL**: <https://www.amazon.com/Quarter-Century-UNIX-Peter-Salus/dp/0201547775>
- **注意事項**: Salusはこの三原則をMcIlroyに帰属させている。Salus自身がインタビューで100人以上の関係者に取材して執筆
- **記事での表現**: 「Peter Salusが1994年の著書でMcIlroyのUNIX哲学を三原則に蒸留した」

## 4. Mike Gancarzの『The UNIX Philosophy』（1995年）

- **結論**: Mike Gancarz著、Digital Press（Elsevier系列）、1995年刊。9つの基本原則と10の副次原則を提示。基本原則には「Small is beautiful」「Make each program do one thing well」「Build a prototype as soon as possible」「Choose portability over efficiency」が含まれる。世界で15,000部以上を販売
- **一次ソース**: Mike Gancarz, "The UNIX Philosophy", Digital Press, 1995, ISBN 978-1-55558-123-7
- **URL**: <https://shop.elsevier.com/books/the-unix-philosophy/gancarz/978-0-08-094819-5>
- **注意事項**: 2003年に改訂版『Linux and the Unix Philosophy』が出版されている
- **記事での表現**: 「Mike Gancarzは1995年の著書で9つの基本原則と10の副次原則としてUNIX哲学を体系化した」

## 5. Eric Raymondの17のルール（2003年）

- **結論**: Eric S. Raymond著『The Art of UNIX Programming』、Addison-Wesley、2003年刊。17のルール: (1) Modularity, (2) Clarity, (3) Composition, (4) Separation, (5) Simplicity, (6) Parsimony, (7) Transparency, (8) Robustness, (9) Representation, (10) Least Surprise, (11) Silence, (12) Repair, (13) Economy, (14) Generation, (15) Optimization, (16) Diversity, (17) Extensibility
- **一次ソース**: Eric S. Raymond, "The Art of UNIX Programming", Addison-Wesley, 2003, ISBN 0-13-142901-9
- **URL**: <http://www.catb.org/esr/writings/taoup/html/> （オンライン全文公開）
- **注意事項**: 全文がWebで公開されている。Raymondは「KISS Principle（Keep it Simple, Stupid）」をUNIX哲学の根幹と位置づけている
- **記事での表現**: 17のルールを列挙し、その中でも特に「Rule of Modularity」「Rule of Composition」「Rule of Simplicity」を重点的に解説

## 6. Robert C. Martinの単一責務原則（SRP）

- **結論**: Robert C. Martin（Uncle Bob）が2002年の著書『Agile Software Development, Principles, Patterns, and Practices』で定式化。定義は「A class should have only one reason to change」（クラスは変更する理由をただ一つだけ持つべき）。2014年にブログ記事で再定義: 「Gather together the things that change for the same reasons. Separate those things that change for different reasons.」
- **一次ソース**: Robert C. Martin, "Agile Software Development, Principles, Patterns, and Practices", Prentice Hall, 2002, Chapter 8
- **URL**: <https://en.wikipedia.org/wiki/Single-responsibility_principle>
- **注意事項**: 出版年は2002年（2003年ではない）。SRPはSOLID原則のS。McIlroyの「Make each program do one thing well」（1978年）とは直接的な引用関係はないが、思想的に共鳴する
- **記事での表現**: 「Robert C. Martinは2002年にSRPを定式化した。UNIXの"Do one thing well"とは24年の時間差があるが、設計思想として深く響き合う」

## 7. UNIXコマンドの起源と作者

- **結論**:
  - cat: Ken Thompsonが1969年にPDP-7アセンブリで最初の実装。Version 1 Unix（1971年）に収録
  - grep: Ken Thompsonが1973年3月に作成。edエディタの正規表現コードを独立プログラムとして抽出。名前はedのコマンド g/re/p（global / regular expression / print）に由来。Version 4 Unixに初収録
  - sed: Lee E. McMahonが1973年-1974年に開発。edの非対話版。Version 7 Unix（1979年）に初収録
  - awk: Alfred Aho, Peter Weinberger, Brian Kernighanが1977年に作成。Version 7 Unixに収録。名前は3人の姓のイニシャル
- **一次ソース**: 各コマンドのWikipedia記事、Two-Bit History "The Source History of Cat"、GNU awk manual History section
- **URL**: <https://twobithistory.org/2018/11/12/cat.html>, <https://en.wikipedia.org/wiki/Grep>, <https://en.wikipedia.org/wiki/Sed>, <https://en.wikipedia.org/wiki/AWK>
- **注意事項**: sedの初リリースについて、一部のソースではVersion 7（1979年）初収録とするが、開発自体は1973-1974年。grepは「私的なコマンドとしてしばらく使っていた」とThompson自身が述べている
- **記事での表現**: 各コマンドの作者と年代を正確に記述する

## 8. Kernighan & Plauger『Software Tools』（1976年）

- **結論**: Brian W. KernighanとP. J. Plauger共著、Addison-Wesley、1976年刊、ISBN 978-0-201-03669-5。Ratfor（Rational Fortran）で記述。1981年にPascal版『Software Tools in Pascal』を出版。「ツールボックス」アプローチの思想的基盤。再利用可能な小さなプログラムを標準ツールとして提供する哲学を説いた
- **一次ソース**: Brian W. Kernighan, P. J. Plauger, "Software Tools", Addison-Wesley, 1976
- **URL**: <https://www.amazon.com/Software-Tools-Brian-W-Kernighan/dp/020103669X>
- **注意事項**: Pascal版は1981年刊（ブループリントでは1981年と記載されている、正確）。原著はRatforで書かれており、Pascalではない
- **記事での表現**: 「Kernighanは1976年の『Software Tools』で、ツールボックスアプローチ——再利用可能な小さなプログラムを組み合わせる設計哲学——を実践的に示した」

## 9. UNIX V7（1979年）のコマンド数

- **結論**: ブループリントでは「約200のコマンド」と記載。正確な数を一次ソースで確認できなかった。V7マニュアルのSection 1（ユーザコマンド）のページ数は相当量あるが、正確なコマンド数の公式記録は見つからず。未検証のため「約」を付けて使用する
- **一次ソース**: Unix Seventh Edition Manual, Volume 1, January 1979
- **URL**: <https://s3.amazonaws.com/plan9-bell-labs/7thEdMan/index.html>
- **注意事項**: V7は10MB未満の容量で9トラック磁気テープ1本に収まった。新コマンドとしてBourneシェル、awk、lex、lint、make、tar等が含まれる
- **記事での表現**: 「V7 Unixには多数のコマンドが含まれていた」程度にとどめ、正確な数には「約」を付ける

## 10. Kernighan & Pike『The UNIX Programming Environment』（1984年）

- **結論**: Brian W. KernighanとRob Pike共著、Prentice Hall、1984年刊。UNIXの設計哲学を実践的に解説した書籍。小さなツールの組み合わせ、フィルタパターン、シェルスクリプトの哲学を体系的に記述
- **一次ソース**: Brian W. Kernighan, Rob Pike, "The UNIX Programming Environment", Prentice Hall, 1984
- **URL**: 第3回の参考文献に記載済み
- **注意事項**: 第3回で既に言及済み。本回ではToolboxアプローチの文脈で再度参照
- **記事での表現**: 「Kernighan & Pikeは1984年の著書でUNIXの実践的哲学を世界に伝えた」
