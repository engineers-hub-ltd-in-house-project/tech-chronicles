# ファクトチェック記録：第23回「シェルの本質に立ち返る――対話・自動化・システム接点」

## 1. Thompson shell（1971年）のリリースと特徴

- **結論**: Thompson shellはKen Thompsonによって書かれ、1971年11月3日リリースのUnix V1に搭載された最初のUnixシェルである。単純なコマンドインタプリタであり、スクリプティング用には設計されていなかったが、I/Oリダイレクション（<, >）を導入した。パイプはDouglas McIlroyの提案により後に追加された。1979年にBourne shellとC shellに置き換えられた。
- **一次ソース**: Wikipedia, "Thompson shell"
- **URL**: <https://en.wikipedia.org/wiki/Thompson_shell>
- **注意事項**: V6 Unix（1975年）の時点でThompson shellのプログラミング機能の限界が明らかになっていた。Programmer's WorkbenchのJohn Masheyが改良を試みた。
- **記事での表現**: 「Thompson shell（1971年）は対話のためのシェルだった。スクリプティング言語としては設計されていない。」

## 2. Bourne shell（1979年）のリリースと設計思想

- **結論**: Stephen BourneがBell Labsで開発し、1979年のUnix V7で初登場。開発は1976年に開始。Bourne shellはスクリプティング言語としての能力を重視した設計。Bill Joyは対話用途でのBourne shellの劣位を指摘し、Bourne自身もC shellの対話機能の優位性を認めていた。
- **一次ソース**: Wikipedia, "Bourne shell"; Wikipedia, "Stephen R. Bourne"
- **URL**: <https://en.wikipedia.org/wiki/Bourne_shell>
- **注意事項**: Bourne shellはSystem V Bourne shellがPOSIX標準のベースとなった。
- **記事での表現**: 「Bourne shell（1979年）はシェルをプログラミング言語にした。だが対話性は犠牲にされた。」

## 3. C shell（1978-1979年）のリリースと対話機能

- **結論**: Bill JoyがUC Berkeleyの大学院生時代に開発。プロトタイプは1978年、正式リリースは1979年5月の2BSDに含まれた。ヒストリ機構、エイリアス、ジョブ制御、ディレクトリスタック、チルダ記法など対話的機能を多数導入。ただしスクリプティング言語としては信頼性に問題があった。
- **一次ソース**: Wikipedia, "C shell"; FreeBSD docs archive, "An Introduction to the C shell" by William Joy
- **URL**: <https://en.wikipedia.org/wiki/C_shell>
- **注意事項**: cshの対話重視・スクリプト軽視は「シェルの二つの文化」の起源。Tom Christiansenの"Csh Programming Considered Harmful"（1996年）がスクリプト用途の問題を詳述。
- **記事での表現**: 「C shell（1979年）は対話に全振りした。ヒストリ、エイリアス、ジョブ制御——Bourne shellが捨てたものを拾い上げた。」

## 4. Korn shell（1983年）の統合アプローチ

- **結論**: David KornがBell Labsで開発、1983年7月14日にUSENIXで発表。Bourne shellのソースコードをベースに、C shellの対話機能（ヒストリ、エイリアス）とvi/Emacsスタイルの行編集を統合。Mike Veach（Emacsモード）とPat Sullivan（viモード）が行編集コードを貢献。当初はプロプライエタリ。
- **一次ソース**: Wikipedia, "KornShell"; kornshell.com
- **URL**: <https://en.wikipedia.org/wiki/KornShell>
- **注意事項**: kshは「対話とスクリプティングの統合」を最初に試みたシェル。2000年にソースコード公開、2005年からEclipse Public License。
- **記事での表現**: 「Korn shell（1983年）は『全部入り』を目指した最初のシェル——対話もスクリプティングも一つのシェルで。」

## 5. POSIX シェル標準（IEEE 1003.2, 1992年）

- **結論**: IEEE P1003.2は6年の策定期間を経て1992年9月17日にIEEE Standards Boardで承認、1993年4月5日にANSI承認。1003.2（シェルスクリプトの可搬性）と1003.2a（UPE: User Portability Extensions、対話的利用）の二部構成。System V Bourne shellをベースに、既存のsh/ksh/csh/BSDシェルのコードとの互換性を考慮。
- **一次ソース**: IEEE Standards Association; IEEE Xplore, "1003.2-1992"
- **URL**: <https://ieeexplore.ieee.org/document/6880751/>
- **注意事項**: POSIX標準は「最小公約数」としてのシェルを定義。対話機能は1003.2aに分離された。
- **記事での表現**: 「POSIX（1992年）はシェルの『最小限の契約書』を定義した。スクリプトの可搬性が主眼であり、対話機能はUPEとして分離された。」

## 6. bash（1989年）の誕生とGNUプロジェクト

- **結論**: Brian Fox（1959年生）がGNUプロジェクトのために開発。1989年6月8日にベータ版（v0.99）をリリース。Free Software Foundationに1985年から参加し、Richard Stallmanと共に働いた。Bourne shell互換を基本とし、kshとcshの機能を取り込んだ。Foxは1992-1994年の間にメンテナを退任。
- **一次ソース**: Wikipedia, "Bash (Unix shell)"; Wikipedia, "Brian Fox (programmer)"
- **URL**: <https://en.wikipedia.org/wiki/Bash_(Unix_shell)>
- **注意事項**: bashはGPLv2でライセンスされていたが、bash 4.0（2009年）からGPLv3に変更。これがAppleのmacOSでのbash 3.2固定の原因。
- **記事での表現**: 「bash（1989年）はGNU自由ソフトウェアとして誕生し、対話もスクリプティングも『全部やる』シェルとなった。」

## 7. zsh（1990年）の最大主義

- **結論**: Paul FalstadがPrinceton大学の学生時代に1990年に初版を執筆。名前はPrinceton大学のTA、Zhong Shaoのログイン名"zsh"に由来。当初はAmiga用cshサブセットとして構想されたが、kshとtcshの交差点を目指すシェルに発展。バージョン4.0（2001年）、5.0（2012年）。
- **一次ソース**: Wikipedia, "Z shell"
- **URL**: <https://en.wikipedia.org/wiki/Z_shell>
- **注意事項**: zshは対話機能もスクリプティング機能も最大限に追求する「最大主義」のシェル。2019年macOS Catalinaでデフォルトに。
- **記事での表現**: 「zsh（1990年）は『全部入り、かつ対話も最高に』という最大主義のシェルである。」

## 8. fish（2005年）のPOSIX離脱

- **結論**: Axel Liljencrantzが開発、2005年2月13日に初リリース。意図的にPOSIXを捨て、ユーザーフレンドリーさ・発見可能性を重視。構文ハイライト、高度なタブ補完。v1.0〜1.23.1はLiljencrantzがメンテナ（最終1.x版は2009年3月）。GPLv2ライセンス。
- **一次ソース**: LWN.net, "Fish - The friendly interactive shell"; fishshell.com
- **URL**: <https://lwn.net/Articles/136518/>
- **注意事項**: fishは「対話専用」に近い設計思想。スクリプティング用途では依然bashやshが使われることが多い。
- **記事での表現**: 「fish（2005年）は対話の軸に全力を注ぎ、POSIXというスクリプティングの契約を意図的に破棄した。」

## 9. Nushell（2019年）の構造化データアプローチ

- **結論**: 2019年8月23日、Sophia Turner（旧Jonathan Turner）、Yehuda Katz、Andres Robalinoにより発表。Rust製。PowerShellの構造化データアプローチに触発され、Unixパイプラインの哲学と融合。JSON、TOML、YAML等の構造化テキストをネイティブに理解。
- **一次ソース**: Nushell公式ブログ, "Introducing nushell"; The Changelog Podcast #363
- **URL**: <https://www.nushell.sh/blog/2019-08-23-introducing-nushell.html>
- **注意事項**: NushellはPowerShellのオブジェクトパイプラインと、Unixのパイプライン哲学の合流点に位置する。
- **記事での表現**: 「Nushell（2019年）はテキストでもオブジェクトでもない『テーブル』をパイプラインに流す第三の道を選んだ。」

## 10. macOS Catalina（2019年）のデフォルトシェル変更

- **結論**: 2019年、macOS Catalinaからデフォルトシェルがbashからzshに変更。主な理由はライセンス——bash 4.0以降がGPLv3に変更されたため、AppleはGPLv3コードをOSに含めない方針からbash 3.2（2007年）で固定していた。Catalina搭載のzshはバージョン5.7.1（MITライセンス）。
- **一次ソース**: Apple Support; The Next Web
- **URL**: <https://thenextweb.com/news/why-does-macos-catalina-use-zsh-instead-of-bash-licensing>
- **注意事項**: この変更は多くのmacOSユーザーにzshを「初期設定」として体験させた。
- **記事での表現**: 「2019年、Appleはライセンス問題からbashを見限りzshをデフォルトにした——これは『シェルは選ぶもの』ではなく『与えられるもの』の典型例である。」

## 11. Debian/Ubuntuの/bin/sh変更（dash, 2006-2007年）

- **結論**: Ubuntu 6.10（2006年10月）で/bin/shをbashからdash（Debian Almquist Shell）に変更。主な理由はパフォーマンス——dashはbashより起動・実行が大幅に高速（OpenOffice.orgのconfigureスクリプトが2分半短縮）。ブート速度の改善にも貢献。対話用のデフォルトログインシェルはbashのまま。
- **一次ソース**: Ubuntu Wiki, "DashAsBinSh"; LWN.net, "A tale of two shells: bash or dash"
- **URL**: <https://wiki.ubuntu.com/DashAsBinSh>
- **注意事項**: 「対話用シェル」と「システムスクリプト用シェル」を分離する実例。bashismの問題が浮き彫りに。
- **記事での表現**: 「Debian/Ubuntuは/bin/shをdashに変更した——対話用シェルとシステム用シェルは別でよい、という宣言である。」

## 12. Elvish（2016年頃）とOils/YSH

- **結論**: Elvishの作者はQi Xiao（GitHub: xiaq）。Go言語で実装。構造化データ（リスト、マップ、関数）をパイプラインで流せる。Oils（旧Oil Shell）はAndy Chuが開発。OSH（既存bashスクリプト実行）とYSH（新言語）の二層構成。2023年3月にOilからYSHに改名。
- **一次ソース**: GitHub xiaq/elvish; github.com/oils-for-unix/oils; oilshell.org
- **URL**: <https://github.com/xiaq>, <https://www.oilshell.org/>
- **注意事項**: Elvishは対話とスクリプティングの両方を新しいアプローチで解決しようとする。OilsはPOSIX互換（OSH）から段階的に新言語（YSH）に移行する戦略。
- **記事での表現**: 「ElvishもOils/YSHも、対話とスクリプティングの二項対立を超えようとする試みである。」
