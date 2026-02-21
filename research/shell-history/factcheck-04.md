# ファクトチェック記録：第4回「Bourne shell――シェルがプログラミング言語になった日」

## 1. Stephen Bourneの経歴とBourne shellの開発時期

- **結論**: Stephen Richard "Steve" Bourne（1944年1月7日生まれ）はイギリスの計算機科学者。King's College Londonで数学の学士号、Trinity College, Cambridgeでコンピュータサイエンスのディプロマと数学の博士号を取得。Cambridge大学計算機研究所でALGOL 68Cコンパイラの開発に従事した後、Bell LabsでUNIX V7チームに9年間在籍。Bourne shellの開発は1976年に開始され、1979年のUNIX V7で公式リリースされた。
- **一次ソース**: Wikipedia, "Stephen R. Bourne"; BSDCan2015 Speaker Profile
- **URL**: <https://en.wikipedia.org/wiki/Stephen_R._Bourne>
- **注意事項**: 開発開始は1976年、PWB/UNIXでのテストを経てV7（1979年）でリリース
- **記事での表現**: 「Stephen Bourne（Bell Labs）によるBourne shellの開発は1976年に始まり、1979年のUNIX V7で公式にリリースされた」

## 2. ALGOL 68の影響とシェル構文

- **結論**: BourneはCambridge大学でALGOL 68Cコンパイラ（Michael Guyと共同開発、CAMAL代数処理システム用）の開発に従事しており、ALGOL 68の改訂委員会にも参加していた。この背景がシェル構文に直接影響した。`if ~ then ~ elif ~ else ~ fi`、`case ~ in ~ esac`、`for/while ~ do ~ done`（ALGOL 68の`od`の代わりに`done`を使用。`od`はバイナリ表示コマンドとして既に存在していたため）。
- **一次ソース**: Wikipedia, "ALGOL 68C"; research!rsc, "Bourne Shell Macros"
- **URL**: <https://en.wikipedia.org/wiki/ALGOL_68C>, <https://research.swtch.com/shmacro>
- **注意事項**: `done`が`od`の代わりに使われた理由は、`od`が既存のUNIXコマンド（octal dump）だったため
- **記事での表現**: 「BourneはCambridge大学でALGOL 68Cコンパイラを開発した経歴を持つ。`fi`は`if`の逆、`esac`は`case`の逆。ALGOL 68の`od`は既存コマンドと衝突するため`done`に置き換えられた」

## 3. Bourne shellのソースコードにおけるALGOL風Cマクロ

- **結論**: Bourne shellのCソースコードでは、`/usr/src/cmd/sh/mac.h`にALGOL 68風のCプリプロセッサマクロが定義されていた。`IF`→`if(`、`THEN`→`){`、`ELSE`→`} else {`、`ELIF`→`} else if (`、`FI`→`;}`、`BEGIN`→`{`、`END`→`}`、`FOR`→`for`、`WHILE`→`while`、`DO`→`{`、`OD`→`;}`等。これによりCで書かれたソースコードがALGOL 68プログラマに馴染みやすいスタイルになっていた。このマクロ群は後にIOCCC（International Obfuscated C Code Contest）誕生のインスピレーションの一つとなった。
- **一次ソース**: Russ Cox, "Bourne Shell Macros", research!rsc
- **URL**: <https://research.swtch.com/shmacro>
- **注意事項**: マクロはコンパイル結果に影響しない純粋なスタイル変換
- **記事での表現**: 「Bourne shellのCソースコード自体がALGOL 68風のマクロで書かれていた。IF/THEN/ELSE/FIマクロがCプリプロセッサで定義され、ソースコードはALGOLプログラムのように読めた」

## 4. Bourne shellの主要機能（V7, 1979年）

- **結論**: V7 Bourne shellの機能: (1) スクリプトをファイル名でコマンドとして呼び出し可能、(2) フロー制御構造（if/then/elif/else/fi、case/in/esac、for/do/done、while/do/done）、(3) クォーティング機構、(4) バッククォートによるコマンド置換、(5) ヒアドキュメント（`<<`）、(6) 環境変数（export）、(7) 入出力リダイレクト（ファイルディスクリプタ2>によるエラーメッセージの分離を最初に実現）、(8) パターンマッチング。
- **一次ソース**: S.R. Bourne, "The UNIX Shell", Bell System Technical Journal, Vol. 57, No. 6, Part 2, pp.1971-1990 (July-August 1978)
- **URL**: <https://onlinelibrary.wiley.com/doi/abs/10.1002/j.1538-7305.1978.tb02139.x>
- **注意事項**: 論文は1978年発表だがV7のリリースは1979年
- **記事での表現**: 正確な機能リストとして本文中で列挙

## 5. 関数の追加時期

- **結論**: Bourneは1983年まで継続的にシェルの開発を行い、関数が最後に追加した機能だった。Bourne自身は「もっと早く追加すべきだった」と述べている。関数は公式にはSVR2（System V Release 2, 1984年）で組み込まれた。SVR2では`unset`、`echo`ビルトイン、ビルトインのリダイレクトサポートも追加された。
- **一次ソース**: Wikipedia, "Bourne shell"; TechTarget definition
- **URL**: <https://en.wikipedia.org/wiki/Bourne_shell>, <https://threatpicture.com/people/steve-bourne/>
- **注意事項**: V7（1979年）の初期リリースには関数は含まれていない
- **記事での表現**: 「Bourneの最後の追加機能は関数だった（1983年頃）。彼自身、もっと早く追加すべきだったと振り返っている」

## 6. ヒアドキュメントの起源

- **結論**: ヒアドキュメントはUNIXシェルに起源を持ち、1979年のBourne shellから存在する。`<<`に続く区切り識別子（delimiter）でブロックテキストを埋め込む構文。Bourne shellがUNIX V7で導入した機能の一つ。
- **一次ソース**: Wikipedia, "Here document"
- **URL**: <https://en.wikipedia.org/wiki/Here_document>
- **注意事項**: Thompson shellにはヒアドキュメントは存在しなかった
- **記事での表現**: 「Bourne shellはヒアドキュメント（`<<`）を導入し、スクリプト内にテキストブロックを埋め込むことを可能にした」

## 7. IFS（Internal Field Separator）

- **結論**: IFSはBourne shellで導入された特殊変数。デフォルト値はスペース、タブ、改行。変数展開後のワード分割で使用される区切り文字を定義する。POSIXで標準化されている。
- **一次ソース**: Greg's Wiki (wooledge.org), "IFS"
- **URL**: <https://mywiki.wooledge.org/IFS>
- **注意事項**: IFSの操作は上級者向けのテクニックであり、誤用するとスクリプトが予期しない動作をする
- **記事での表現**: 「IFS（Internal Field Separator）はワード分割の挙動を制御する変数で、デフォルトはスペース・タブ・改行の3文字」

## 8. Bourne shellの論文（Bell System Technical Journal）

- **結論**: S.R. Bourne, "The UNIX Shell", Bell System Technical Journal, Vol. 57, No. 6, Part 2, pp.1971-1990, July-August 1978。Wiley Online LibraryおよびInternet Archiveでアクセス可能。DOI: 10.1002/j.1538-7305.1978.tb02139.x
- **一次ソース**: Bell System Technical Journal, Wiley Online Library
- **URL**: <https://onlinelibrary.wiley.com/doi/abs/10.1002/j.1538-7305.1978.tb02139.x>, <https://archive.org/details/bstj57-6-1971>
- **注意事項**: 論文発表は1978年、V7リリースは1979年
- **記事での表現**: 「Bourneは1978年のBell System Technical Journalに論文"The UNIX Shell"を発表した」

## 9. Thompson shell/Mashey shellからの移行

- **結論**: Bourne shellはThompson shellの後継としてV7で導入された。実行ファイル名は同じ`sh`。PWB/Mashey shellの機能不足がBourne shellを一から書き直す動機となった。Bourne shellはThompson/PWB shellとは非互換だが、PWB shellの機能の同等物を含んでいた。Bell Labs内部では「Mashey shellプログラマのためのBourne shellプログラミング」という講座が一時期存在した。
- **一次ソース**: Wikipedia, "PWB shell"; Wikipedia, "Thompson shell"
- **URL**: <https://en.wikipedia.org/wiki/PWB_shell>, <https://en.wikipedia.org/wiki/Thompson_shell>
- **注意事項**: Bourne shellは段階的改良ではなく一からの書き直し
- **記事での表現**: 「Bourne shellはThompson shellの漸進的改良ではなく、一から書き直された新しいシェルだった」

## 10. ワード分割とグロビングの処理パイプライン

- **結論**: Bourne shell（およびその後継）の処理順序: ブレース展開→チルダ展開→パラメータ/変数/算術展開とコマンド置換（左から右）→ワード分割→パス名展開（グロビング）。ワード分割はIFSに基づいて行われ、未クォートの展開結果に対してのみ適用される。パス名展開はワード分割の後に行われる。ブレース展開、ワード分割、パス名展開のみが単語数を変更できる（`$@`を除く）。
- **一次ソース**: InformIT, "Processing the Command Line"; Greg's Wiki, "WordSplitting"
- **URL**: <https://www.informit.com/articles/article.aspx?p=441605&seqNum=9>, <https://mywiki.wooledge.org/WordSplitting>
- **注意事項**: ブレース展開はBourne shell V7には存在しない（bash/zsh拡張）。V7時点の処理順序はより単純
- **記事での表現**: 「変数展開→ワード分割→グロビングという処理パイプラインが、シェルスクリプトの『罠』の根源となった」

## 11. 環境変数とexportメカニズム

- **結論**: Bourne shellはキーワードパラメータとエクスポート可能な変数による環境変数をサポートした。`export`コマンドでシェルパラメータを環境に結びつける。子プロセスが継承する環境は、元々継承された未変更のペアと、exportで指定された変更・追加から構成される。
- **一次ソース**: Bourne Shell Manual, Version 7 (Sven Mascheck)
- **URL**: <https://www.in-ulm.de/~mascheck/bourne/v7/>
- **注意事項**: 環境変数の仕組みはBourne、Mashey、Dennis Ritchieの三者が協力して設計した（第3回記事でも言及済み）
- **記事での表現**: 「`export`コマンドにより、シェル変数を子プロセスに継承させる環境変数として公開できるようになった」

## 12. trapコマンドによるシグナルハンドリング

- **結論**: Bourne shellは`trap`ビルトインコマンドによるシグナルハンドリングを提供した。`trap 'commands' signals`の形式でシグナル受信時の動作を定義できる。空文字列でシグナルを無視、引数なしでデフォルト動作に戻す。スクリプトのクリーンアップ処理に使用される。
- **一次ソース**: Shell Scripting Tutorial; Wikibooks, "Bourne Shell Scripting"
- **URL**: <https://www.shellscript.sh/trap.html>
- **注意事項**: trapはV7 Bourne shellから存在する機能
- **記事での表現**: 「`trap`コマンドにより、シグナル受信時のハンドリングが可能になった。これはスクリプトの堅牢性を飛躍的に向上させた」
