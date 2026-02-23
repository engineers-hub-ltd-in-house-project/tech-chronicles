# ファクトチェック記録：第7回「テキストストリーム——万能インタフェースとしてのテキスト」

## 1. ed テキストエディタ（1969年、Ken Thompson）

- **結論**: edは1969年8月にKen ThompsonがPDP-7上でUNIXの一部として開発した。アセンブラ、エディタ、シェルがUNIXの最初の三要素。edの多くの機能はThompsonがUCバークレーで使っていたQEDエディタに由来する。Dennis Ritchieが後に「決定版」のedを作成した
- **一次ソース**: ed (text editor) - Wikipedia; Dennis Ritchie's QED history (Bell Labs)
- **URL**: <https://en.wikipedia.org/wiki/Ed_(text_editor)>, <https://www.bell-labs.com/usr/dmr/www/qed.html>
- **注意事項**: edの正確なリリース日は不明だが、1969年のUNIX初版に含まれていた。V7 Unix（1979年）で広く配布された
- **記事での表現**: 「1969年、Ken ThompsonがUNIXの一部としてedを実装した。UCバークレーで使っていたQEDエディタの機能を取り込んだものだ」

## 2. sed ストリームエディタ（1973-1974年、Lee E. McMahon）

- **結論**: sedは1973年から1974年にかけてBell LabsのLee E. McMahonが開発した。edの拡張として設計された。連邦主義者論文（Federalist Papers）の著者判定のための統計分析作業（Bob Morrisとの共同）が、高度なテキスト処理ツールの必要性を浮き彫りにし、sed開発の動機となった。Version 7 Unix（1979年）で初めてリリースされた
- **一次ソース**: Lee E. McMahon, "SED — A Non-interactive Text Editor", Bell Laboratories; sed - Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Sed>, <https://wolfram.schneider.org/bsd/7thEdManVol2/sed/sed.pdf>
- **注意事項**: ブループリントでは「sed（1974年）」と記載。開発は1973-1974年、リリースはV7（1979年）
- **記事での表現**: 「1973年から1974年にかけて、Lee E. McMahonがBell Labsでsedを開発した。連邦主義者論文の著者判定という統計的テキスト分析が、対話的でないストリーム処理の必要性を示した」

## 3. awk プログラミング言語（1977年、Aho, Weinberger, Kernighan）

- **結論**: awkの初版は1977年にAT&T Bell Laboratoriesで作成された。名前は設計者Alfred V. Aho、Peter J. Weinberger、Brian W. Kernighanの頭文字に由来する。Version 7 Unixに含まれた最初期のツールの一つ。1985年にユーザ定義関数などの拡張が始まり、1988年に『The AWK Programming Language』が出版された
- **一次ソース**: AWK - Wikipedia; GNU Awk User's Guide - History
- **URL**: <https://en.wikipedia.org/wiki/AWK>, <https://www.gnu.org/software/gawk/manual/html_node/History.html>
- **注意事項**: 1988年の書籍はAddison-Wesley刊。2023年に第2版が出版された
- **記事での表現**: 「1977年、Alfred V. Aho、Peter J. Weinberger、Brian W. KernighanがBell Labsでawkを設計した。パイプラインに計算能力を加える初期のツールだった」

## 4. Ken Thompsonの正規表現エンジン（1968年）

- **結論**: Ken Thompsonの論文「Regular Expression Search Algorithm」は1968年6月にCommunications of the ACM（Vol. 11, No. 6）に掲載された。正規表現をNFA（非決定性有限オートマトン）に変換するアルゴリズム（Thompson's construction）を記述。IBM 7094コードへのJITコンパイルとして実装した。これはQEDエディタへの正規表現実装に基づき、後にedとgrepに正規表現が組み込まれた
- **一次ソース**: Ken Thompson, "Programming Techniques: Regular expression search algorithm", Communications of the ACM, Vol. 11, No. 6, June 1968
- **URL**: <https://dl.acm.org/doi/10.1145/363347.363387>, <https://www.oilshell.org/archive/Thompson-1968.pdf>
- **注意事項**: JITコンパイルの初期の重要な例としても知られる
- **記事での表現**: 「1968年、Ken Thompsonは正規表現をNFAに変換するアルゴリズムをCACMに発表した。このアルゴリズムはQEDエディタの実装に基づき、後にed、そしてgrepに受け継がれた」

## 5. POSIX正規表現（BRE/ERE、IEEE 1003.2-1992）

- **結論**: POSIX.2（IEEE Std 1003.2-1992）でBRE（Basic Regular Expressions）とERE（Extended Regular Expressions）が標準化された。BREは歴史的なedやgrepの正規表現に対応し、EREは歴史的なegrepの正規表現に対応する。BREでは`()`と`{}`をエスケープする必要があるが、EREでは不要
- **一次ソース**: IEEE Std 1003.2-1992; The Open Group Base Specifications
- **URL**: <https://pubs.opengroup.org/onlinepubs/9699919799/xrat/V4_xbd_chap09.html>
- **注意事項**: POSIX.2は1992年に国際的に承認された
- **記事での表現**: 「1992年のPOSIX.2（IEEE 1003.2）で、BRE（ed/grep系）とERE（egrep系）として正規表現構文が標準化された」

## 6. Doug McIlroyの「テキストストリームは万能インタフェース」の出典

- **結論**: Doug McIlroyの有名な定式化「Write programs to handle text streams, because that is a universal interface」は、1994年にPeter H. Salusが『A Quarter Century of UNIX』でMcIlroyに帰属して要約した。McIlroy自身は1978年にBell Labs CSTR #97で「Expect the output of every program to become the input to another, as yet unknown, program」とUNIXの「特徴的スタイル」を文書化していた
- **一次ソース**: Peter H. Salus, "A Quarter Century of UNIX", 1994; Doug McIlroy, foreword to "The Bell System Technical Journal", 1978
- **URL**: <https://en.wikipedia.org/wiki/Unix_philosophy>, <https://en.wikiquote.org/wiki/Doug_McIlroy>
- **注意事項**: 正確な「三原則」の形での初出は1994年のSalusの書籍
- **記事での表現**: 「McIlroyは『テキストストリームを扱うプログラムを書け、それが万能インタフェースだからだ』と述べた。この定式化は1994年にPeter Salusが『A Quarter Century of UNIX』で広めた」

## 7. PowerShellのオブジェクトパイプライン（2006年、Jeffrey Snover）

- **結論**: Jeffrey SnoverがMonad Manifesto（2002年8月8日）でオブジェクトパイプラインの構想を記述。UNIXのBourne shellのパイプラインに着想を得つつ、テキストではなく.NETオブジェクトをパイプラインで渡す方式を提案。開発は2003年初頭に開始。Windows PowerShell 1.0は2006年11月にリリースされた
- **一次ソース**: Jeffrey Snover, "Monad Manifesto", August 8, 2002; PowerShell - Wikipedia
- **URL**: <https://www.jsnover.com/Docs/MonadManifesto.pdf>, <https://en.wikipedia.org/wiki/PowerShell>
- **注意事項**: リリース後半年で約100万ダウンロード
- **記事での表現**: 「2002年、Jeffrey SnoverはMonad Manifestoでオブジェクトパイプラインを構想した。UNIXのテキストパイプラインへの明確な批判であり、テキスト解析の必要性を排除する設計だった。2006年11月にPowerShell 1.0としてリリースされた」

## 8. JSON（Douglas Crockford、2001年）

- **結論**: JSONの名前は2001年3月に共同設立したState Software社で生まれた。Douglas CrockfordとChip Morningstarが2001年4月に最初のJSONメッセージを送信。2002年にCrockfordがJSON.orgドメインを取得し、文法と実装例を公開。2006年7月にRFC 4627として仕様化。2013年にECMA-404として初の公式標準化
- **一次ソース**: JSON - Wikipedia; Douglas Crockford - Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/JSON>, <https://en.wikipedia.org/wiki/Douglas_Crockford>
- **注意事項**: JSONはJavaScriptのオブジェクトリテラル構文のサブセット
- **記事での表現**: 「2001年にDouglas CrockfordらがJSONを考案し、2002年にJSON.orgで公開した。テキストベースでありながら構造化されたデータ表現という、UNIXのプレーンテキストと構造化データの中間地点だ」

## 9. YAML（2001年、Clark Evans）

- **結論**: YAMLは2001年にClark Evansが提案し、Ingy dot NetおよびOren Ben-Kikiと共同で設計した。2001年5月12日に最初の記事が公開された。名前は2001年12月から2002年4月にかけて「YAML Ain't Markup Language」（再帰的頭字語）に変更。YAML 1.0仕様は2004年初頭に公開された
- **一次ソース**: YAML - Wikipedia; yaml.org
- **URL**: <https://en.wikipedia.org/wiki/YAML>, <https://yaml.org/about/>
- **注意事項**: 元々はXMLの簡略化の議論（XML-DEVメーリングリスト、1997年〜）から発展
- **記事での表現**: 「2001年にClark Evansが提案したYAMLは、人間可読性を重視した構造化データフォーマットだ」

## 10. TOML（2013年、Tom Preston-Werner）

- **結論**: TOMLはGitHub共同創業者のTom Preston-Wernerが作成し、2013年5月に初リリース。「Tom's Obvious, Minimal Language」の略。INIファイル形式の進化形として設計され、YAMLやJSONの複雑さやパース曖昧性を解消する目的
- **一次ソース**: TOML - Wikipedia; toml.io
- **URL**: <https://en.wikipedia.org/wiki/TOML>, <https://toml.io/en/>
- **注意事項**: GitHubリポジトリ toml-lang/toml でオープンソースとして管理
- **記事での表現**: 「2013年にTom Preston-WernerがTOMLを公開した。設定ファイルに特化した、曖昧性のないテキストフォーマットだ」

## 11. jq（2012年、Stephen Dolan）

- **結論**: jqはStephen Dolanが開発し、2012年10月にリリースした。「JSONのためのsed」と形容される。ポータブルCで実装され、ランタイム依存なし。フィルタのパイプライン合成というUNIX的な設計思想を持つ
- **一次ソース**: jq (programming language) - Wikipedia; GitHub jqlang/jq
- **URL**: <https://en.wikipedia.org/wiki/Jq_(programming_language)>, <https://github.com/jqlang/jq>
- **注意事項**: 最新安定版は1.7.1（2023年）
- **記事での表現**: 「2012年にStephen Dolanがリリースしたjqは、JSONのためのsedとも呼ばれる。UNIXのフィルタ設計思想を構造化データの世界に持ち込んだ」
