# ファクトチェック記録：第8回「小さなツールの組み合わせ——合成可能性の設計」

## 1. Doug McIlroyのUNIX哲学の定式化（1978年）

- **結論**: McIlroyは1978年7-8月号のBell System Technical Journal（Vol. 57, No. 6）のUNIX特集号の序文（Foreword）で、UNIX哲学の設計指針を文書化した。共著者はE.N. Pinson、B.A. Tague。指針には「Make each program do one thing well」「Expect the output of every program to become the input to another, as yet unknown, program」「Don't clutter output with extraneous information」などが含まれる
- **一次ソース**: M.D. McIlroy, E.N. Pinson, B.A. Tague, "UNIX Time-Sharing System: Foreword", Bell System Technical Journal, Vol. 57, No. 6, pp.1899-1904, July-August 1978
- **URL**: <https://archive.org/details/bstj57-6-1899>
- **注意事項**: より簡潔な三原則の定式化（「Write programs that do one thing and do it well...」）は、1994年にPeter SalusがMcIlroyの言葉として『A Quarter Century of UNIX』で広めたもの
- **記事での表現**: McIlroyの1978年の序文を「合成可能性の設計規約」の原典として引用する

## 2. Brian Kernighan & P.J. Plauger『Software Tools』（1976年）

- **結論**: 1976年にAddison-Wesleyから出版。Ratfor（Rational Fortran）で記述。ソフトウェアを「ツール」として設計し組み合わせるアプローチを提唱。同書の続編『Software Tools in Pascal』は1981年1月にAddison-Wesleyから出版
- **一次ソース**: Brian W. Kernighan, P. J. Plauger, "Software Tools", Addison-Wesley, 1976, ISBN 978-0201036695
- **URL**: <https://openlibrary.org/books/OL4934660M/Software_tools>
- **注意事項**: 原書はRatforで記述。Pascal版は1981年出版
- **記事での表現**: Kernighanの「Toolboxアプローチ」の思想的起源として、1976年の出版年と共著者Plaugerを正確に記述する

## 3. Kernighan & Pike『The UNIX Programming Environment』（1984年）

- **結論**: 1984年にPrentice Hallから出版。Brian W. KernighanとRob Pike（いずれもBell Labs）の共著。UNIXの哲学——小さな協調するツール群を標準化された入出力で接続する——を体系的に解説。ファイルシステム、コマンド、リダイレクト、パイプ、フィルタ、シェルプログラミングを網羅
- **一次ソース**: Brian W. Kernighan, Rob Pike, "The UNIX Programming Environment", Prentice Hall, 1984, ISBN 978-0139376818
- **URL**: <https://www.cs.princeton.edu/~bwk/upe/upe.html>
- **注意事項**: 出版から40年以上経過しているが、掲載されたほとんどの例は現代のUNIX系システムでコンパイル・実行可能
- **記事での表現**: UNIXの合成可能性を体系的に解説した書籍として引用

## 4. UNIX V7（1979年）のコマンド群

- **結論**: Version 7 Unix（1979年1月）はBell Labsからリリースされ、Bourne shell、awk、tar、touchなど多数のコマンド・ユーティリティを含む。マニュアルには「数百」のユーザレベルプログラムが含まれると記述されているが、正確な数は公式に明記されていない。セクション1（コマンド）の項目数は約200前後と推定される
- **一次ソース**: UNIX Programmer's Manual, Seventh Edition, January 1979, Bell Telephone Laboratories
- **URL**: <https://s3.amazonaws.com/plan9-bell-labs/7thEdMan/v7vol1.pdf>
- **注意事項**: ブループリントの「約200のコマンド」は推定値。正確には「数百のユーザレベルプログラム」とマニュアルに記述。記事では「約200」ではなく、より正確な表現を使用する
- **記事での表現**: 「V7 UNIXのマニュアルセクション1には数百のコマンドが収録されていた。それぞれが独立したプログラムだ」

## 5. 標準入出力（stdin/stdout/stderr）の歴史

- **結論**: stdin（fd 0）とstdout（fd 1）はUNIXの初期から存在。stderr（fd 2）はVersion 6以降に追加された。stderrの誕生にはBell Labsの写植機（Graphic Systems C/A/T phototypesetter）のエピソードが関わる。エラーメッセージが標準出力に混ざり、写植出力にエラーメッセージが美しく印字されてしまう事態が発生。この無駄な写植作業への不満がstderr分離の契機となった
- **一次ソース**: Diomidis Spinellis, "The Birth of Standard Error", blog, 2013-12-11; Dennis Ritchie, "The Evolution of the Unix Time-sharing System", 1984
- **URL**: <https://www.spinellis.gr/blog/20131211/index.html>
- **注意事項**: stderrの正確な導入バージョンはVersion 6とVersion 7の間（V6まではdiagnosticsはstdoutの一部だった）
- **記事での表現**: 写植機のエピソードを導入として使い、stderrが「実用上の痛み」から生まれた設計判断であることを描写する

## 6. 終了コード（Exit Code）の規約

- **結論**: POSIX互換システムでは、成功を0、失敗を非ゼロで表す慣習が確立している。C言語ではEXIT_SUCCESS（0）とEXIT_FAILURE（1）マクロが定義されている。BSDシステムには/usr/include/sysexits.hで終了コードの体系化が試みられている。この規約はUNIXの初期からシェルの条件分岐（if, while, &&, ||）と結びついて発展した
- **一次ソース**: POSIX IEEE 1003.1; sysexits.h (BSD)
- **URL**: <https://en.wikipedia.org/wiki/Exit_status>
- **注意事項**: 0が「成功」である理由は、成功のパターンが一つしかないのに対し、失敗には複数の理由があるため（非ゼロの値で失敗の種類を区別できる）
- **記事での表現**: 終了コードの規約を合成可能性の第四条件として解説する

## 7. Eric Raymond『The Art of UNIX Programming』（2003年）の17ルール

- **結論**: 2003年にAddison-Wesleyから出版。UNIX哲学をKISS原則として要約し、17のルールに体系化。合成可能性に直接関連するルールとして「Rule of Modularity」（単純な部品を清潔なインタフェースで接続）、「Rule of Composition」（他のプログラムと接続されるよう設計）、「Rule of Silence」（驚くべきことがなければ何も言うな）、「Rule of Repair」（失敗は大声で通知）がある
- **一次ソース**: Eric S. Raymond, "The Art of UNIX Programming", Addison-Wesley, 2003
- **URL**: <http://www.catb.org/esr/writings/taoup/html/>
- **注意事項**: オンラインで全文公開されている
- **記事での表現**: Raymondの17ルールから合成可能性に関連するルールを抽出して引用する

## 8. Mike Gancarz『The UNIX Philosophy』（1995年）

- **結論**: 1995年にDigital Pressから出版。9つの主要原則と10の副次的原則を定義。主要原則に「Small is beautiful」「Make each program do one thing well」「Build a prototype as soon as possible」「Choose portability over efficiency」「Store data in flat text files」「Use software leverage to your advantage」「Use shell scripts to increase leverage and portability」「Avoid captive user interfaces」「Make every program a filter」が含まれる
- **一次ソース**: Mike Gancarz, "The UNIX Philosophy", Digital Press, 1995, ISBN 978-1555581237
- **URL**: <https://www.amazon.com/UNIX-Philosophy-Mike-Gancarz/dp/1555581234>
- **注意事項**: Gancarzの第9原則「Make every program a filter」が合成可能性に直結する
- **記事での表現**: Gancarzの「Make every program a filter」を合成可能性の設計原則として引用

## 9. Rule of Silence（沈黙の規則）

- **結論**: UNIXの「沈黙は金」の規則は、驚くべきこと・興味深いこと・有用なことを言う必要がなければ何も出力すべきではないというもの。起源は1969年のテレタイプ端末時代——低速の印字端末では不要な出力行がユーザの時間を深刻に浪費した。この規則が合成可能性に寄与する理由は、おしゃべりなプログラムはパイプラインの後段のプログラムと相性が悪く、出力のパースを妨げるため
- **一次ソース**: Eric S. Raymond, "The Art of UNIX Programming", Chapter 11: "Silence is Golden", 2003
- **URL**: <http://www.catb.org/esr/writings/taoup/html/ch11s09.html>
- **注意事項**: この規則は「no news is good news」としても知られる
- **記事での表現**: 沈黙の規則を「合成可能性のための暗黙のプロトコル」として解説する

## 10. シェルの「接着剤」としての役割

- **結論**: Bourne shellは1976年にStephen BourneがBell Labsで開発を開始し、1979年のVersion 7 Unixでリリースされた。Thompson shellの後継として設計され、対話的コマンドインタプリタであると同時にスクリプト言語として機能。ヒアドキュメント、コマンド置換、変数、制御構造を導入し、プログラムの組み合わせを自動化する「接着剤」の役割を果たした
- **一次ソース**: Bourne shell - Wikipedia; Stephen Bourne, "The UNIX Shell", Bell System Technical Journal, 1978
- **URL**: <https://en.wikipedia.org/wiki/Bourne_shell>
- **注意事項**: シェルの「glue language」としての性格はUNIXの合成可能性の実現手段として重要
- **記事での表現**: シェルを「小さなツール群を束ねる接着剤」として位置づけ、合成可能性の実現におけるシェルの役割を解説

## 11. 関数型プログラミングのパイプ演算子とUNIXパイプの類似性

- **結論**: 複数の関数型言語がUNIXパイプに触発されたパイプ演算子`|>`を持つ。F#、OCaml、Elm、Elixir、Gleamなどが採用。Haskellでは`&`演算子（reverse function application）が2014年頃に追加。UNIXパイプとモナドの関係については、「パイプはモナドの`>>=`演算子と意味的に類似している」とする分析がある（Oleg Kiselyovの研究）
- **一次ソース**: Oleg Kiselyov, "UNIX pipes as IO monads"; 各言語の公式ドキュメント
- **URL**: <https://okmij.org/ftp/Computation/monadic-shell.html>
- **注意事項**: UNIXパイプとモナドの接点は技術論として重要だが、過度な同一視は避ける。UNIXパイプは型なしテキストストリームであり、モナドは型安全な計算の合成フレームワーク
- **記事での表現**: 関数型言語の`|>`演算子をUNIXパイプの思想的後継として位置づけ、モナドとの接点を技術論で扱う

## 12. マイクロサービスとUNIX哲学の思想的接続

- **結論**: マイクロサービスの設計原則はUNIX哲学と構造的に類似する。「一つのサービスは一つのことをうまくやる」はUNIXの単一責務原則に対応し、APIを介したサービス間の疎結合な連携はパイプラインのフィルタモデルに対応する。Donnie Berkholz（RedMonk、2014年5月）が「Microservices and the migrating Unix philosophy」で両者の関係を論じている
- **一次ソース**: Donnie Berkholz, "Microservices and the migrating Unix philosophy", RedMonk, May 20, 2014
- **URL**: <https://redmonk.com/dberkholz/2014/05/20/microservices-and-the-migrating-unix-philosophy/>
- **注意事項**: 構造的類似は認めつつも、決定的な違い（ネットワーク越しの非同期通信、分散システムの困難）を明示すること
- **記事での表現**: マイクロサービスを「UNIX哲学の現代的変奏」として位置づけ、合成可能性の条件が変わらず適用されることを示す
