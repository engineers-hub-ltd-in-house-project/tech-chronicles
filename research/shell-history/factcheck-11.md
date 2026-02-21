# ファクトチェック記録: 第11回「POSIXシェル標準――誰も読まない契約書」

## 1. IEEE 1003.2-1992の制定経緯

- **結論**: IEEE P1003.2（Shell and Utilities）は6年間の策定作業を経て、1992年9月17日にIEEE Standards Boardにより承認された。正式名称は"IEEE Standard for Information Technology--Portable Operating System Interfaces (POSIX)--Part 2: Shell and Utilities"。策定に6年を要した理由は、Version 7 shell、System V shell、BSD shell、Korn shellの各実装間の差異を調整する必要があったこと、および委員メンバー間のシェルに対するバイアスの存在
- **一次ソース**: IEEE Standards Association; O'Reilly "Learning the Korn Shell" Appendix A.2
- **URL**: <https://standards.ieee.org/ieee/1003.2/1408/>, <http://www.cs.ait.ac.th/~on/O/oreilly/unix/ksh/appa_02.htm>
- **注意事項**: 1003.2は「Part 2: Shell and Utilities」であり、1003.1（Part 1: System Interfaces）とは別のドキュメント。後に統合される
- **記事での表現**: 「IEEE P1003.2は6年の策定作業を経て、1992年9月17日に承認された」

## 2. POSIX shの設計基盤（Bourne shell + ksh88）

- **結論**: POSIXシェル標準はSystem V Bourne shellを基盤とし、ksh88の機能も取り込んだ。具体的にはkshからの取り込みとして$()構文によるコマンド置換、チルダ展開などがある。ただしksh88の配列（set -A）はPOSIX標準に含まれなかった。委員会はVersion 7 shell、System V shell、BSD shell、Korn shellの各実装間の既存コードを可能な限り収容する必要があった
- **一次ソース**: O'Reilly "Learning the Korn Shell" Appendix A.2; O'Reilly "Learning the bash Shell" Appendix A.2
- **URL**: <http://www.cs.ait.ac.th/~on/O/oreilly/unix/ksh/appa_02.htm>, <https://www.oreilly.com/library/view/learning-the-bash/1565923472/apas02.html>
- **注意事項**: POSIXシェルはksh88の「サブセット」として設計されたのではなく、Bourne shellベースにkshの一部機能を取り込んだ形。第10回の表現を踏襲しつつ正確に
- **記事での表現**: 「POSIX shはSystem V Bourne shellを基盤とし、Korn shellが導入した機能（$()構文、算術展開、チルダ展開等）を取り込んで標準化された」

## 3. Austin Groupの設立と役割

- **結論**: Austin Group（Austin Common Standards Revision Group）は1998年にThe Open Group、IEEE、ISO/IEC JTC1/SC22/WG15の3者により結成された共同技術ワーキンググループ。名前はテキサス州オースティンで開催された最初の会議に由来。POSIXとSingle UNIX Specificationの共同改訂を行う。SUSv3（2001年）はAustin Groupの最初の主要成果
- **一次ソース**: Austin Group Wikipedia; POSIX Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Austin_Group>, <https://en.wikipedia.org/wiki/POSIX>
- **注意事項**: Austin Groupは1998年結成。それ以前はIEEEとX/Open（後のThe Open Group）がそれぞれ独立に標準策定を行っていた
- **記事での表現**: 「1998年、The Open Group、IEEE、ISO/IECの3者がAustin Groupを結成し、POSIXとSingle UNIX Specificationの統合改訂を開始した」

## 4. Single UNIX Specification（SUS）とPOSIXの関係

- **結論**: SUSはX/Open（後のThe Open Group）が策定したUNIX標準。1994年にX/Open Company（1984年設立のコンソーシアム）が最初のSUSを公開。POSIX（IEEE 1003）とSUSは当初別々に策定されていたが、SUSv3（2001年、POSIX.1-2001と同時リリース）でAustin Groupにより統合。SUSv4は2008年（POSIX.1-2008）。最新版はPOSIX.1-2024（SUS Issue 8、2024年6月14日公開）
- **一次ソース**: Single UNIX Specification Wikipedia; POSIX Wikipedia; IEEE Xplore
- **URL**: <https://en.wikipedia.org/wiki/Single_UNIX_Specification>, <https://en.wikipedia.org/wiki/POSIX>, <https://ieeexplore.ieee.org/document/10555529/>
- **注意事項**: SUSはUNIX商標の認証基準でもある。POSIX準拠とUNIX認証は異なる概念
- **記事での表現**: 「SUSv3（2001年）においてPOSIXとSingle UNIX Specificationは統合され、以後Austin Groupが両者の共同改訂を担っている」

## 5. POSIX shで使えないもの（bashisms）

- **結論**: POSIX sh標準に含まれない主要な機能: (1) `[[` 条件式（bash/ksh拡張。POSIXは`[ ]`と`test`のみ）、(2) 配列（bash/ksh拡張。POSIX shには配列がない）、(3) `local`キーワード（POSIX未定義。ただし実質的にほぼ全てのPOSIX準拠シェルが実装している）、(4) `function`キーワード（ksh由来。POSIXは`name() { ... }`構文のみ）、(5) `$'...'`（ANSI-C quoting。ksh93由来。POSIX.1-2024のIssue 8で標準化が進んだ）、(6) `source`コマンド（bash拡張。POSIXは`.`のみ）、(7) プロセス置換`<(...)`（bash/ksh拡張）
- **一次ソース**: ShellCheck wiki (SC3043, SC2039, SC2113); Greg's Wiki "Bashism"; Bash Reference Manual
- **URL**: <https://www.shellcheck.net/wiki/SC3043>, <https://www.shellcheck.net/wiki/SC2039>, <https://www.shellcheck.net/wiki/SC2113>, <https://mywiki.wooledge.org/Bashism>
- **注意事項**: `local`は事実上ほぼ全てのPOSIX準拠シェルが実装しているが、POSIX標準では未定義。$'...'はPOSIX.1-2024（Issue 8）で追加された
- **記事での表現**: 各bashismの具体例をコードとともに示す

## 6. Debian/Ubuntu dash移行（2006年）

- **結論**: Ubuntu 6.10（2006年）がデフォルトの/bin/shをbashからdashに変更。Debian 6（Squeeze, 2011年）が公式にdashをデフォルト/bin/shに採用。Ubuntu 6.10での起動速度改善は、当初Upstartに帰因されていたが、実際にはdash移行による貢献が大きかった。dashはbashより小さく起動が高速
- **一次ソース**: Ubuntu Wiki "DashAsBinSh"; Debian Wiki "BootProcessSpeedup"; LWN.net "A tale of two shells"
- **URL**: <https://wiki.ubuntu.com/DashAsBinSh>, <https://wiki.debian.org/BootProcessSpeedup>, <https://lwn.net/Articles/343924/>
- **注意事項**: Debianは2006年頃から移行を進めたが、正式にデフォルト変更されたのはDebian 6（2011年）。UbuntuはDebian派生だがdash採用はUbuntuの方が先行
- **記事での表現**: 「Ubuntu 6.10（2006年）がデフォルトの/bin/shをbashからdashに変更し、起動速度の大幅な改善を実現した」

## 7. Alpine Linux / BusyBox ash

- **結論**: Alpine Linuxの/bin/shはBusyBox ashにシンボリックリンクされている。BusyBox ashはAlmquist shell（ash）の派生で、POSIX準拠の最小限シェル。Alpine Linuxのイメージサイズは5MB未満と極めて小さく、Docker/コンテナ環境で広く使われている
- **一次ソース**: Alpine Linux Wiki "Shell management"; Alpine Linux Wiki "BusyBox"; BusyBox Wikipedia
- **URL**: <https://wiki.alpinelinux.org/wiki/Shell_management>, <https://wiki.alpinelinux.org/wiki/BusyBox>, <https://en.wikipedia.org/wiki/BusyBox>
- **注意事項**: BusyBox ashは「ほぼPOSIX準拠」だが完全ではない部分もある。bashとの非互換がCI/CDパイプラインの問題になることが多い
- **記事での表現**: 「Alpine Linuxの/bin/shはBusyBox ash——POSIX準拠の最小限シェルだ」

## 8. autoconf/automakeとPOSIX sh

- **結論**: GNU Autoconfは1991年夏にDavid MacKenzieがFSFでの作業を支援するために開発を開始。configureスクリプトはPOSIX準拠のポータブルなシェルコードを生成する。Autoconfの"Portable Shell"ドキュメントは、様々なシェル実装間の非互換性に関する膨大な知見を集積している
- **一次ソース**: Autoconf Wikipedia; GNU Autoconf Manual "Portable Shell"
- **URL**: <https://en.wikipedia.org/wiki/Autoconf>, <https://www.gnu.org/software/autoconf/manual/autoconf-2.64/html_node/Portable-Shell.html>
- **注意事項**: autoconfが生成するconfigureスクリプトは/bin/shで実行されることを前提としており、POSIX sh準拠の重要な実例
- **記事での表現**: 「GNU Autoconf（1991年〜）が生成するconfigureスクリプトは、POSIX shの上で動くポータブルなシェルコードの最も体系的な実例だ」

## 9. checkbashismsツール

- **結論**: checkbashismsはDebianのdevscriptsパッケージに含まれるPerlスクリプト。lintianシステムのチェックの一つに基づいており、/bin/shスクリプトからbashisms（bash固有の構文）を検出する。Debian/Ubuntuがdash移行を進める際の重要なツール
- **一次ソース**: Debian Manpages; Debian GitLab devscripts
- **URL**: <https://manpages.debian.org/testing/devscripts/checkbashisms.1.en.html>, <https://salsa.debian.org/debian/devscripts/-/blob/master/scripts/checkbashisms.pl>
- **注意事項**: checkbashismsはヒューリスティックベースの検出であり、全てのbashismを検出できるわけではない
- **記事での表現**: 「checkbashisms（Debianのdevscriptsパッケージ）は、/bin/shスクリプトからbash固有の構文を検出するツールだ」

## 10. POSIX.1-2024（最新版）

- **結論**: POSIX.1-2024（IEEE Std 1003.1-2024）は2024年6月14日に公開。The Open Group Base Specifications Issue 8に対応。C17言語標準に整合。Shell and Utilitiesボリュームを含む。HTML版はThe Open Groupのサイトで無料閲覧・ダウンロード可能
- **一次ソース**: IEEE Xplore; The Open Group Publications
- **URL**: <https://ieeexplore.ieee.org/document/10555529/>, <https://pubs.opengroup.org/onlinepubs/9799919799.2024edition/mindex.html>
- **注意事項**: POSIX.1-2024はIssue 8。前版のIssue 7（POSIX.1-2017/2018）からの改訂
- **記事での表現**: 「2024年6月、最新のPOSIX.1-2024（Issue 8）が公開された」

## 11. ShellCheck（shellcheck --shell=sh）

- **結論**: ShellCheck（Vidar Holen作、2012年-）はシェルスクリプトの静的解析ツール。`--shell=sh`オプションでPOSIX sh準拠のチェックが可能。SC2039（POSIX shでは未定義の機能）、SC3043（POSIX shではlocalが未定義）、SC2113（functionキーワードは非標準）等のコードでbashismを検出
- **一次ソース**: ShellCheck Wiki
- **URL**: <https://www.shellcheck.net/wiki/SC2039>, <https://www.shellcheck.net/wiki/SC3043>, <https://www.shellcheck.net/wiki/SC2113>
- **注意事項**: ShellCheckは第5回でも紹介済み。本回ではPOSIX準拠チェックの側面に焦点を当てる
- **記事での表現**: 「ShellCheckの--shell=shオプションは、スクリプトのPOSIX準拠度を検証する実用的な手段だ」
