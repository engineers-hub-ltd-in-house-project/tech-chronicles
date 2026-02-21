# ファクトチェック記録：第21回「CLIデザインの原則――man, --help, 12 Factor CLI」

## 1. manページの起源（1971年11月3日）

- **結論**: UNIX Programmer's Manualは1971年11月3日に初版が発行された。最初のmanページはDennis RitchieとKen Thompsonがマネージャーのdoug McIlroyの要請により執筆した。初版は61個のコマンドを文書化した
- **一次ソース**: Wikipedia "Man page"; Two-Bit History "The Lineage of Man" (2017); Alex's Blog "Man Pages (Part 1)" (2024)
- **URL**: <https://en.wikipedia.org/wiki/Man_page>, <https://twobithistory.org/2017/09/28/the-lineage-of-man.html>, <https://abochannek.github.io/utilities/2024/12/08/man-pages.html>
- **注意事項**: McIlroyの役割は、マニュアルの品質基準を高く保つことに貢献した。Sandy Fraserの証言によれば、McIlroyがマニュアルに高い基準を要求したことが、プログラム自体の品質向上にもつながった
- **記事での表現**: 「1971年11月3日、UNIX Programmer's Manualの初版が発行された。Dennis RitchieとKen Thompsonが、マネージャーのDoug McIlroyの要請によって執筆したものだ」

## 2. manページの構造（NAME, SYNOPSIS, DESCRIPTION）

- **結論**: 初版のmanページからNAME, SYNOPSIS, DESCRIPTIONなどのヘッダー構造が確立された。オプションフラグは角括弧で囲まれ、メタ引数（例: file）は下線付きで記述された。roff（後にnroff/troff）でフォーマットされた
- **一次ソース**: Wikipedia "Man page"; manpages.bsd.lv "History of UNIX Manpages"
- **URL**: <https://en.wikipedia.org/wiki/Man_page>, <https://manpages.bsd.lv/history.html>
- **注意事項**: セクション分け（Section 1: General Commands, Section 2: System Calls等）は当初は長い印刷物のセクションに過ぎなかった。man(1)コマンド自体の登場はUNIX V2以降
- **記事での表現**: 「NAME、SYNOPSIS、DESCRIPTION、SEE ALSOという見出し構造は、1971年の初版から存在していた」

## 3. roff/nroff/troffの歴史

- **結論**: 初版manページはJoe F. Ossannaが書いたroffでフォーマットされた。nroff（newer roff）はより柔軟な言語として開発された。Graphic Systems CAT植字機を得てtroff（typesetter roff）が誕生した。man macroの小さなセットはUNIX V4で初めて使用された
- **一次ソース**: Wikipedia "troff", Wikipedia "nroff"
- **URL**: <https://en.wikipedia.org/wiki/Troff>, <https://en.wikipedia.org/wiki/Nroff>
- **注意事項**: 最初の正式なマクロパッケージはMichael LeskのmsマクロでUNIX V6で導入
- **記事での表現**: 「manページのフォーマットにはroff（後のnroff/troff）が使用された」

## 4. getopt関数の歴史

- **結論**: getoptは1980年頃に遡る。1985年のUNIFORUM会議（ダラス）でAT&Tがパブリックドメインとして公開する意図で発表した。Henry Spencerが1984年4月28日に独自の互換実装を書いた。getoptはPOSIX.1-1988で標準化された
- **一次ソース**: ESR "Set the WABAC to 1984: Henry Spencer getopt, and the roots of open source"; Wikipedia "Getopt"
- **URL**: <http://esr.ibiblio.org/?p=7552>, <https://en.wikipedia.org/wiki/Getopt>
- **注意事項**: AT&TのライセンスがSpencerの独自実装のきっかけとなった。BSDは今でもSpencerのバージョンを使用している
- **記事での表現**: 「getoptの起源は1980年頃に遡る。1985年のUNIFORUM会議でAT&Tがgetoptを公開したが、Henry Spencerは1984年に独自の互換実装を書いていた」

## 5. GNU long optionとgetopt_long

- **結論**: GNUプロジェクト（1983年発表）はコマンドライン構文に変更を加えた。当初は+記号でlong optionを示したが、すぐに--（ダブルダッシュ）に変更された。getopt_longはGNU拡張として開発され、マルチ文字オプションの統一的なパースを提供する。GNU Coding Standardsの著作権は1992年から
- **一次ソース**: GNU Coding Standards; Wikipedia "GNU coding standards"; Blog "Unix command line conventions over time"
- **URL**: <https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html>, <https://en.wikipedia.org/wiki/GNU_coding_standards>, <https://blog.liw.fi/posts/2022/05/07/unix-cli/>
- **注意事項**: GNU Coding Standardsは--helpと--versionを全プログラムでサポートすることを推奨
- **記事での表現**: 「GNUは当初+記号でlong optionを示していたが、すぐに--（ダブルダッシュ）に変更した。getopt_long関数により、--verboseのような読みやすいオプションの統一的パースが可能になった」

## 6. POSIX Utility Syntax Guidelines

- **結論**: POSIX.1-1988（IEEE Std 1003.1-1988）が最初のPOSIX標準。Utility Syntax Guidelines（12.2節）は、コマンドラインオプションの統一的な規約を定めた13のガイドラインで構成される。最新版はPOSIX.1-2024（Issue 8）
- **一次ソース**: The Open Group, "Utility Conventions", POSIX.1-2024
- **URL**: <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html>
- **注意事項**: 歴史的ユーティリティの中には既にこのガイドラインに違反しているものがあるが、将来のユーティリティにはガイドライン準拠が推奨されている
- **記事での表現**: 「POSIX Utility Syntax Guidelines（12.2節）は13のガイドラインで構成され、オプションは単一の英数字文字であること、-区切り文字で始まること、--がオプションの終わりを示すことなどを規定した」

## 7. 12 Factor CLI Apps

- **結論**: Jeff DickeyがHerokuのCLI開発者として2018年10月10日にMediumで発表した。Herokuの12 Factor App方法論をCLIアプリケーション向けに適応させたもの。Herokuはoclif（Open CLI Framework）というNode.js/TypeScript製フレームワークも公開した
- **一次ソース**: Jeff Dickey, "12 Factor CLI Apps", Medium, 2018年10月10日
- **URL**: <https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46>
- **注意事項**: oclif はHeroku CLIとSalesforce CLIの共通基盤。Jeff Dickeyはoclif のリードアーキテクトでもあった
- **記事での表現**: 「2018年10月、HerokuのCLI開発者Jeff Dickeyは『12 Factor CLI Apps』を発表した」

## 8. clig.dev（Command Line Interface Guidelines）

- **結論**: 2020年12月に公開された。著者はAanand Prasad（Squarespace）、Ben Firshman（Docker Compose共同作成者、Replicate）、Carl Tashian（Smallstep）、Eva Parish（Squarespace）。Hacker Newsのフロントページに3日間掲載された
- **一次ソース**: clig.dev; InfoQ "CLI Guidelines Aim to Help You Write Better CLI Programs" (2020年12月17日); GitHub cli-guidelines/cli-guidelines
- **URL**: <https://clig.dev/>, <https://www.infoq.com/news/2020/12/cli-guidelines-qa/>, <https://github.com/cli-guidelines/cli-guidelines>
- **注意事項**: Ben FirshmanがDocker Compose開発の経験からCLI設計のベストプラクティスが必要だと感じたことがきっかけ
- **記事での表現**: 「2020年12月、Aanand Prasad、Ben Firshman、Carl Tashian、Eva Parishの四人がCommand Line Interface Guidelines（clig.dev）を公開した」

## 9. sysexits.hと終了コードの規約

- **結論**: sysexits.hは4.0BSD（1980年）でdelivermailユーティリティ（後のsendmail）のためにEric Allmanが作成した。終了コードは64（EX_USAGE）から78（EX_CONFIG）の範囲。POSIX/Cの規約では0が成功、非0が失敗。終了コードは0-255の範囲
- **一次ソース**: FreeBSD man page "sysexits(3)"; Wikipedia "Exit status"
- **URL**: <https://man.freebsd.org/cgi/man.cgi?query=sysexits>, <https://en.wikipedia.org/wiki/Exit_status>
- **注意事項**: sysexits.hのコードは広く参照されるが、POSIX標準には含まれていない。GNU Cライブラリも採用している
- **記事での表現**: 「1980年、Eric Allmanはdelivermail（後のsendmail）のためにsysexits.hを作成した。終了コード64から78までの範囲で、使用法エラー、データエラー、入力不在などの失敗分類を定義した」

## 10. stderrの歴史

- **結論**: 標準エラー出力はUNIX V6まで標準出力の一部だった。Dennis Ritchieが標準エラーの概念を作成した。きっかけは、植字実行時にエラーメッセージが植字されてしまい、無駄になったことが複数回あったため
- **一次ソース**: Wikipedia "Standard streams"
- **URL**: <https://en.wikipedia.org/wiki/Standard_streams>
- **注意事項**: V7（1979年）で正式にstdin/stdout/stderrの3ストリームが確立された
- **記事での表現**: 「標準エラー出力の概念は、Dennis Ritchieが作成した。V6まではエラーメッセージも標準出力に混在しており、植字実行でエラーが植字されてしまうという問題が動機だった」

## 11. サブコマンドパターンの歴史

- **結論**: サブコマンドベースのインターフェースは `tool [general options] command [command options] [command arguments]` の構文を持つ。CVS、Subversion、gitなどのバージョン管理ツールで広く使われた。gitはPATH上のgit-<subcmd>実行ファイルを自動解決する仕組みを持つ
- **一次ソース**: Julio Merino, "CLI design: Subcommand-based interfaces" (2013); git公式ドキュメント
- **URL**: <https://jmmv.dev/2013/09/cli-design-subcommand-based-interfaces.html>, <https://git.github.io/htmldocs/gitcli.html>
- **注意事項**: サブコマンドパターンの起源は特定しにくいが、CVS（1990年）やRCS以前から存在する可能性がある。SCCSも類似パターン
- **記事での表現**: 「サブコマンドパターンは、CVS、Subversion、gitなどを通じて広く普及した」
