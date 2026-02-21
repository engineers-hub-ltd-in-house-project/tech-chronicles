# ファクトチェック記録：第5回「クォーティング地獄――シェル言語設計の原罪」

## 1. Bourne shellの処理パイプライン（変数展開→ワード分割→グロビング→クォート除去）

- **結論**: Bourne shellでは、コマンドライン処理においてトークン化→変数展開/コマンド置換→ワード分割（field splitting）→パス名展開（globbing）→クォート除去の順で処理が行われる。ワード分割はIFSに基づいて行われ、未クォートの展開結果のみが対象となる。POSIXでもこの処理順序が標準化されている。
- **一次ソース**: POSIX.1-2024 Shell Command Language; Greg's Wiki "WordSplitting"
- **URL**: <https://pubs.opengroup.org/onlinepubs/9699919799/xrat/V4_xcu_chap02.html>, <https://mywiki.wooledge.org/WordSplitting>
- **注意事項**: POSIXでは "field splitting" と呼称。bashマニュアルでは "word splitting" と呼ぶ
- **記事での表現**: シェルの処理パイプラインを5段階で図示し、ワード分割がステップ3に位置することを明示

## 2. IFS（Internal Field Separator）の設計と歴史

- **結論**: IFSはBourne shellから存在する特殊変数で、デフォルト値はスペース・タブ・改行の3文字。ワード分割の区切り文字を定義する。POSIXではSystem V shell互換のIFS挙動（デフォルトIFS時）とKorn shell互換のIFS挙動（非デフォルトIFS時）の両方を許容する形で標準化された
- **一次ソース**: Greg's Wiki "IFS"; POSIX Shell Command Language rationale; Wikipedia "Internal field separator"
- **URL**: <https://mywiki.wooledge.org/IFS>, <https://en.wikipedia.org/wiki/Internal_field_separator>
- **注意事項**: IFSの正式名称は "Internal Field Separator" だが "Input Field Separators" と呼ばれることもある
- **記事での表現**: IFSのデフォルト値と、変更時のワード分割挙動の変化をコード例で示す

## 3. UNIX V7時代のファイル名慣習（スペースを使わない前提）

- **結論**: UNIX V7時代のファイル名は最大14バイトの制約があり、慣習としてスペースを含めないのが一般的だった。UNIXファイルシステム自体はスペースを許容するが、シェルのワード分割がスペースを区切り文字として扱うため、スペース入りファイル名は問題を引き起こす。David A. Wheelerが "Fixing Unix/Linux/POSIX Filenames" で詳細に論じている
- **一次ソース**: David A. Wheeler, "Fixing Unix/Linux/POSIX Filenames"; Chris Siebenmann, "The length of file names in early Unix"
- **URL**: <https://dwheeler.com/essays/fixing-unix-linux-filenames.html>, <https://utcc.utoronto.ca/~cks/space/blog/unix/UnixEarlyFilenameLengths>
- **注意事項**: Wheelerは「よく設計されたシステムでは、簡単なことは簡単であるべき」と述べ、UNIXのファイル名設計に「鋭い縁（sharp edges）」があると指摘
- **記事での表現**: 1979年当時のファイル名慣習がワード分割設計の前提にあったことを歴史的文脈として記述

## 4. "$@" vs "$\*" の違いとその歴史

- **結論**: `$*`はすべての位置パラメータを1つの文字列として扱い（IFSの最初の文字で結合）、`$@`はダブルクォート内で各位置パラメータを個別の文字列として保持する。`"$@"`はダブルクォート規則の唯一の例外であり、`"$1" "$2" ...`と等価になる。これはBourne shellで導入された設計
- **一次ソース**: Greg's Wiki "Quotes"; Grymoire Bourne Shell Tutorial; Baeldung "What's the Difference Between $* and $@"
- **URL**: <https://mywiki.wooledge.org/Quotes>, <https://www.grymoire.com/Unix/Bourne.html>, <https://www.baeldung.com/linux/dollar-star-at>
- **注意事項**: Bourne shellには配列変数が存在しなかったため、`"$@"`が事実上唯一の「リスト」を安全に扱う手段だった
- **記事での表現**: `"$@"`と`$*`の挙動差をコード例で示し、配列不在の代償としての`"$@"`の重要性を論じる

## 5. Bourne shellに配列変数が存在しなかった事実

- **結論**: Bourne shellおよびPOSIX shには配列変数が存在しない。唯一の「配列」は位置パラメータ（$1, $2, ..., $@）のみ。配列変数はksh88で導入され、bash 2.0（1996年）でbashにも追加された。連想配列はbash 4.0（2009年）から
- **一次ソース**: POSIX Shell Array/List Data Structure (Baeldung); codestudy.net "Array Syntax in POSIX Shells"
- **URL**: <https://www.baeldung.com/linux/posix-shell-array>, <https://www.codestudy.net/blog/arrays-in-a-posix-compliant-shell/>
- **注意事項**: POSIX shで配列的処理を行うには `set --` と `"$@"` の組み合わせが標準的手法
- **記事での表現**: 配列不在が「スペースを含む複数ファイル名のリスト」処理を困難にした設計上の帰結として記述

## 6. シェルのクォーティング機構（シングル/ダブル/バックスラッシュ）

- **結論**: Bourne shellのクォーティング機構は3種類。（1）シングルクォート: すべての特殊文字の意味を無効化（リテラル）、（2）ダブルクォート: $, `, \ の特殊意味を保持しつつワード分割とグロビングを抑制、（3）バックスラッシュ: 直後の1文字のみをクォート。バッククォートはクォーティング文字ではなくコマンド置換の構文
- **一次ソース**: Unix Power Tools 3rd Ed. "Bourne Shell Quoting"; Grymoire "Unix Shell Quotes"; Montana State University "quoting in the bourne shell"
- **URL**: <https://docstore.mik.ua/orelly/unix3/upt/ch27_12.htm>, <https://www.grymoire.com/Unix/Quote.html>, <https://www.cs.montana.edu/courses/309/topics/shell/shell-quoting.html>
- **注意事項**: ダブルクォート内でのバックスラッシュは $, `, ", \, 改行 の前でのみ特殊意味を持つ
- **記事での表現**: 3種類のクォーティングの意味を表形式で整理し、それぞれの使い分けをコード例で示す

## 7. ShellCheck（Vidar Holen, 2012年〜）の歴史と功績

- **結論**: ShellCheckはVidar 'koala_man' Holenが2012年に開発を開始した静的解析ツール。Haskellで実装されている。2012年にIRCチャンネル #bash@Freenode のボットとして誕生した。初期バージョンにはエラーコードすらなく、平文の英語メッセージのみだった。その後GitHubで最もスターの多いHaskellプロジェクトとなった。MIT SIPB（Student Information Processing Board）の "Writing Safe Shell Scripts" ガイドで言及されたことが知名度拡大のきっかけ
- **一次ソース**: Vidar Holen, "Lessons learned from writing ShellCheck"; ShellCheck GitHub repository; Hackage package
- **URL**: <https://www.vidarholen.net/contents/blog/?p=859>, <https://github.com/koalaman/shellcheck>, <https://hackage.haskell.org/package/ShellCheck>
- **注意事項**: Holenは「最も楽しく興味深い言語」としてHaskellを選択。ShellCheckのコンパイルには2GBのRAMが必要
- **記事での表現**: ShellCheckの誕生経緯をIRCボットから始まった物語として紹介し、SC2086等の具体的な警告コードを解説

## 8. ShellCheck SC2086（ダブルクォート忘れ警告）

- **結論**: SC2086は "Double quote to prevent globbing and word splitting" という警告メッセージ。ShellCheckで最も頻出する警告の一つ。未クォートの変数展開を検出し、ワード分割とグロビングのリスクを警告する
- **一次ソース**: ShellCheck Wiki SC2086
- **URL**: <https://www.shellcheck.net/wiki/SC2086>, <https://github.com/koalaman/shellcheck/wiki/SC2086>
- **注意事項**: SC2086はinfoレベルの警告。意図的にワード分割を使うケースでは `# shellcheck disable=SC2086` で抑制可能
- **記事での表現**: SC2086を「最も遭遇する警告」として紹介し、ハンズオンで実際にShellCheckを実行して確認

## 9. ShellCheck SC2046（コマンド置換のクォーティング）

- **結論**: SC2046は "Quote this to prevent word splitting" という警告。未クォートのコマンド置換 `$(...)` を検出する。コマンド置換の結果もワード分割の対象となるため、ダブルクォートで囲む必要がある
- **一次ソース**: ShellCheck Wiki SC2046
- **URL**: <https://www.shellcheck.net/wiki/SC2046>
- **注意事項**: 配列への代入時など、意図的にワード分割が必要なケースもある
- **記事での表現**: SC2046をSC2086と並ぶ代表的な警告として紹介

## 10. POSIXによるワード分割の標準化（IEEE 1003.2, 1992年）

- **結論**: IEEE 1003.2-1992（POSIX Shell and Utilities）でシェルのワード分割挙動が標準化された。IFSのデフォルト値（スペース・タブ・改行）時はSystem V shell互換の挙動、非デフォルトIFS時はKorn shell互換の挙動が定められた。標準化にあたりBourne shellとksh88のサブセットが基盤となった。策定に6年を要した
- **一次ソース**: IEEE Standard 1003.2-1992; POSIX Shell Command Language Rationale
- **URL**: <https://standards.ieee.org/standard/1003_2-1992.html>, <https://pubs.opengroup.org/onlinepubs/9699919799/xrat/V4_xcu_chap02.html>
- **注意事項**: POSIX標準化により、1979年の設計判断が「標準」として固定化された
- **記事での表現**: POSIXが「1979年の設計判断を追認し、標準化した」事実として記述

## 11. glob（パス名展開）の歴史――外部コマンドからシェル内蔵へ

- **結論**: UNIX初期（V1-V6, 1969-1975年）ではglobbingは外部コマンド `/etc/glob` として実装されていた。Dennis Ritchieが実装。"glob" は "global" の略で、$PATH全体を検索する意図があった。Bourne shell（V7, 1979年）でシェル内蔵化された。現在はPOSIX.2で標準化
- **一次ソース**: Wikipedia "Glob (programming)"; Greg's Wiki "glob"
- **URL**: <https://en.wikipedia.org/wiki/Glob_(programming)>, <https://mywiki.wooledge.org/glob>
- **注意事項**: 呼び出されたプログラム側はglob自体を見ることはなく、展開済みのファイル名のみを引数として受け取る
- **記事での表現**: グロビングがワード分割の直後に処理される段階として位置づけ、未クォートの変数展開がグロビングの対象にもなるリスクを解説
