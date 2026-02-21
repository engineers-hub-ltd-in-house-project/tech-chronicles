# ファクトチェック記録：第8回「テキスト処理の系譜――ed, grep, sed, awk」

## 1. edエディタの開発（Ken Thompson, 1969年）

- **結論**: edはKen Thompsonにより1969年8月、PDP-7上でUNIXの最初期の要素（アセンブラ、エディタ、シェル）の一つとして開発された。QED（1965-66年、Butler LampsonとL. Peter DeutschがBerkeley Timesharing System向けに開発）の系譜を引く。ThompsonはQEDをCTSSおよびMulticsに移植した経験があり、そのQED版で初めて正規表現を実装した。edはQEDから正規表現を簡略化して採用した（`*`演算子のみ、alternationやparenthesesなし）。
- **一次ソース**: Dennis Ritchie, "An incomplete history of the QED Text Editor", Nokia Bell Labs; Wikipedia "Ed (text editor)"
- **URL**: <https://www.bell-labs.com/usr/dmr/www/qed.html>, <https://en.wikipedia.org/wiki/Ed_(text_editor)>
- **注意事項**: QEDの原版（Berkeley版）は正規表現を持たなかった。正規表現はThompsonがCTSS版で導入した点を明確にすること。
- **記事での表現**: 「1969年8月、Ken ThompsonはPDP-7上でedを書いた。それはBerkeley Timesharing System上のQED（1965-66年、Butler LampsonとL. Peter Deutsch）の系譜を引くラインエディタだった。」

## 2. QEDとThompsonの正規表現実装（1966-1968年）

- **結論**: QEDは1965-66年にButler LampsonとL. Peter Deutsch（実装はDeutschとDana Angluin）がBerkeley Timesharing System（SDS 940）向けに開発した。Ken ThompsonがCTSS（IBM 7094）に移植した版（1966年頃）で初めてコンパイル型NFA（非決定性有限オートマトン）を用いた正規表現を実装した。Thompsonは1968年にCACM論文 "Regular expression search algorithm" を発表した（Communications of the ACM 11(6), pp.419-422, June 1968）。
- **一次ソース**: Ken Thompson, "Regular expression search algorithm", CACM 11(6), 1968; Wikipedia "QED (text editor)"; Russ Cox, "Implementing Regular Expressions", swtch.com
- **URL**: <https://en.wikipedia.org/wiki/QED_(text_editor)>, <https://swtch.com/~rsc/regexp/regexp1.html>
- **注意事項**: McNaughton-Yamadaの構成法（1960年）が先行するが、NFA概念を明示的に用いたのはThompsonの論文が最初期とされる。
- **記事での表現**: 「ThompsonはQEDのCTSS版で正規表現をNFAとしてコンパイルする手法を編み出し、1968年のCACM論文でこれを公表した。この論文が、正規表現を理論から実用へ架け橋した。」

## 3. grepの誕生（Ken Thompson, 1973年）

- **結論**: grepはKen Thompsonが作成した。Lee McMahonがThe Federalist Papersの著者帰属分析のために大量テキスト検索を必要とし、Thompsonに依頼。edは全ファイルをメモリにロードする設計のため巨大ファイルには不向きだったため、Thompsonはedの正規表現コードを抽出し、行単位で逐次処理するスタンドアロンツールとして書き出した。名前はedのコマンド `g/re/p`（global regular expression print）に由来する。grepはVersion 4 UNIX（1973年11月）のマニュアルに初掲載。マニュアルの日付は1973年3月3日だが、Thompson本人はそれ以前から個人的に使用していたと証言（"grep was a private command of mine for quite a while before I made it public"）。
- **一次ソース**: Wikipedia "Grep"; Brian Kernighan, "Brian Kernighan Remembers the Origins of 'grep'", The New Stack; Ken Thompson quote
- **URL**: <https://en.wikipedia.org/wiki/Grep>, <https://thenewstack.io/brian-kernighan-remembers-the-origins-of-grep/>
- **注意事項**: grepの正確な「作成日」は不明。マニュアルの日付（1973年3月3日）はマニュアルの最終更新日である可能性が高い。
- **記事での表現**: 「grepの名前はedの `g/re/p` コマンドに由来する。Lee McMahonがThe Federalist Papersの著者分析のために大量テキスト検索を必要とし、Thompsonがedの正規表現エンジンを切り出してスタンドアロンツールにした。」

## 4. Lee McMahonの経歴

- **結論**: Lee Edward McMahon（1931年10月24日 - 1989年2月15日）、アメリカの計算機科学者。St. Louis Universityで学士号（summa cum laude, 1955年）、Harvard Universityで心理学博士号を取得。1963年からBell Labsに勤務し、1989年の死去まで在籍。1975年にBell Labs Computing Research Centerに正式参加。sed、comm、qsort等を開発。囲碁のペアリングシステムの開発にも携わった。
- **一次ソース**: Wikipedia "Lee E. McMahon"; prabook.com
- **URL**: <https://en.wikipedia.org/wiki/Lee_E._McMahon>, <https://prabook.com/web/lee.mcmahon/2151944>
- **注意事項**: McMahonの心理学博士号という背景は、テキスト分析（Federalist Papers）への関心と整合する。
- **記事での表現**: 「McMahonはHarvard大学で心理学の博士号を取得した異色の経歴の持ち主だった。テキスト分析への関心は学術的背景から来ていた。」

## 5. sedの開発（Lee McMahon, 1973-1974年）

- **結論**: sedはLee McMahonが1973-74年にBell Labsで開発した。edの対話的コマンド（特にグローバル置換 `g/re/s/...`）をスクリプト的に非対話で実行するニーズから生まれた。McMahonは `g/re/p` に続いて `g/re/d` 等の特殊目的ツールが次々と必要になることを予見し、汎用的なストリームエディタとしてsedを設計した。sedはVersion 7 UNIX（1979年1月）で初めて公式配布された。
- **一次ソース**: Wikipedia "Sed"
- **URL**: <https://en.wikipedia.org/wiki/Sed>
- **注意事項**: 開発は1973-74年だが、公式配布はV7（1979年）。edの `s` コマンド（置換）がsedの中核機能であることを明示する。
- **記事での表現**: 「McMahonは、grepのような特殊目的ツール（g/re/p）が次々と必要になることを予見し、edのコマンド体系を非対話的に適用できる汎用ストリームエディタ――sedを1973-74年に開発した。」

## 6. awkの開発（Aho, Weinberger, Kernighan, 1977年）

- **結論**: awkはAlfred Aho、Peter Weinberger、Brian KernighanがBell Labsで1977年に開発。名前は3人の頭文字。Version 7 UNIX（1979年1月）で初配布。パターン-アクションモデルを採用し、行指向のテキスト処理にプログラミング言語の機能を加えた。1985年に大幅拡張（ユーザー定義関数、複数入力ストリーム、計算正規表現）。拡張版はnawk（new awk）と呼ばれ、System V Release 3.1（1987年）で広く配布。1988年に著者3名による書籍 "The AWK Programming Language"（Addison-Wesley）が出版された。
- **一次ソース**: Wikipedia "AWK"; GNU Awk User's Guide "History"
- **URL**: <https://en.wikipedia.org/wiki/AWK>, <https://www.gnu.org/software/gawk/manual/html_node/History.html>
- **注意事項**: 1977年が初版、1985年が拡張版（nawk）、1988年が書籍。3つの年号を区別すること。
- **記事での表現**: 「1977年、Alfred Aho、Peter Weinberger、Brian KernighanはBell Labsでawkを開発した。名前は3人の姓の頭文字だ。」

## 7. ed → ex → vi → vimの系譜

- **結論**: ed（1969年、Thompson）→ em（1976年2月、George Coulouris、Queen Mary College、"editor for mortals"）→ en → ex（1976年、Bill JoyとChuck Haley、UC Berkeley）→ vi（ex 2.0のビジュアルモード、Second BSD, 1979年5月）→ vim（1988年開発開始、Bram Moolenaar）。Bill Joyは300baudモデムでの作業を想定して効率的なキーバインドを設計した。
- **一次ソース**: Various Wikipedia articles; "Where Vim Came From" (Two-Bit History); Pikuma blog
- **URL**: <https://twobithistory.org/2018/08/05/where-vim-came-from.html>, <https://en.wikipedia.org/wiki/Vi_(text_editor)>
- **注意事項**: viの名前でインストールされたのはex 2.0（Second BSD, 1979年）からであり、1976年時点ではviはexのビジュアルモードだった。
- **記事での表現**: 「edの系譜はem→ex→viと進化し、ラインエディタからフルスクリーンエディタへの転換を遂げた。この系譜はエディタ側の進化であり、フィルタ側の進化（grep→sed→awk）とは異なる道を辿る。」

## 8. Thompson の正規表現CACM論文（1968年）

- **結論**: Ken Thompson, "Regular expression search algorithm", Communications of the ACM, Vol.11, No.6, pp.419-422, June 1968. 正規表現をNFAにコンパイルし、IBM 7094の機械語コードとして出力するアルゴリズムを記述。Janusz Brzozowskiの1964年CACM論文 "Derivatives of regular expressions" が理論的基礎。
- **一次ソース**: Ken Thompson, CACM 1968; Russ Cox, swtch.com "Implementing Regular Expressions"
- **URL**: <https://swtch.com/~rsc/regexp/regexp1.html>, <https://en.wikipedia.org/wiki/Thompson's_construction>
- **注意事項**: 論文はNFA概念を明示していないが、後の解釈ではNFA構成法として理解されている。
- **記事での表現**: 「1968年、ThompsonはCACMに正規表現の検索アルゴリズムを発表した。正規表現をNFAに変換し機械語にコンパイルするこの手法は、後のすべての正規表現エンジンの原型となった。」

## 9. Version 7 UNIXの重要性（1979年）

- **結論**: Version 7 UNIX（Seventh Edition）は1979年1月にBell Labsからリリースされた。sed、awk、make、lex、lint、tar、uucp等の重要ツールが同梱された。V7はAT&Tによる商業化以前の最後の広く配布されたBell Labs版UNIXであり、その後のBSD系・System V系の分岐の基点となった。
- **一次ソース**: Wikipedia "Version 7 Unix"
- **URL**: <https://en.wikipedia.org/wiki/Version_7_Unix>
- **注意事項**: V7がsedとawkの初配布バージョンである点を明確にする。
- **記事での表現**: 「1979年1月のVersion 7 UNIX――sedもawkもこのバージョンで初めて公式配布された。V7はUNIXの歴史における分水嶺であり、後のBSD系・System V系の基点となった。」

## 10. gawk（GNU awk）の開発

- **結論**: gawk（GNU awk）は1986年にPaul Rubinが執筆を開始し、Jay Fenlasonが完成させた。Richard Stallmanの助言を受けている。POSIX仕様に準拠しつつGNU拡張を追加。
- **一次ソース**: GNU Awk User's Guide "History"
- **URL**: <https://www.gnu.org/software/gawk/manual/html_node/History.html>
- **注意事項**: gawkは本記事の主題ではないが、awkの影響の広がりを示す例として言及可能。
- **記事での表現**: 必要に応じて簡潔に言及。

## 11. テキストストリームという共通インターフェース

- **結論**: ed、grep、sed、awkはすべて「行指向」のテキスト処理を基本とする。入力をテキストストリームとして受け取り、行単位で処理し、テキストストリームとして出力する。この共通インターフェースにより、パイプで自在に組み合わせることができる。McIlroyのUNIX哲学第三条「テキストストリームを扱うプログラムを書け」の体現。
- **一次ソース**: Peter H. Salus, "A Quarter Century of Unix", 1994; 前回（第7回）記事
- **URL**: 該当なし（原則論）
- **注意事項**: 第7回との重複を避け、ここではツール群の「生態系」としての側面を強調する。
- **記事での表現**: 「これらのツールはすべて同じ規約に従う。テキストを行単位で読み、処理し、テキストとして出力する。この規約こそが、50年にわたる互換性の源泉だ。」
