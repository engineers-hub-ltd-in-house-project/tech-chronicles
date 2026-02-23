# ファクトチェック記録：第10回「POSIX標準化——"標準UNIX"は実現したか」

## 1. IEEE POSIX（IEEE 1003.1）の成立年と経緯

- **結論**: 最初のPOSIX標準（IEEE Std 1003.1-1988）は1988年に発行された。その基盤は1984年の/usr/groupの標準化活動にあり、1985年にIEEEがP1003プロジェクトとして正式に作業を開始した。POSIX.1-1988はV7 UNIX、System III、System V、4.2BSD、4.3BSDのインタフェースを統合したものである
- **一次ソース**: IEEE Standards Association, "IEEE 1003.1-1988"
- **URL**: <https://standards.ieee.org/ieee/1003.1/1388/>
- **注意事項**: 1990年版（POSIX.1-1990）が1988年版の改訂として安定基盤となり、以降の修正はこの1990年版に対して行われた
- **記事での表現**: 1984年の/usr/group標準→1985年のIEEE P1003作業開始→1988年のIEEE Std 1003.1-1988発行という時系列で記述

## 2. Richard Stallmanによる「POSIX」命名

- **結論**: Richard Stallmanが「POSIX」という名前を提案した。IEEEが仕様を完成させたが簡潔な名称がなく、委員会が「IEEEIX」を候補としていたところ、Stallmanが「portable operating system」の頭文字に「ix」を付けて「POSIX」を提案した。発音は「pahz-icks」（positiveのように）
- **一次ソース**: Richard Stallman, "The origin of the name POSIX"
- **URL**: <https://stallman.org/articles/posix.html>
- **注意事項**: Stallmanの動機は、GNUをUNIXシステムと呼ばれることを避けるため（GNU's Not Unix）。IEEEはこの名称を即座に採用した
- **記事での表現**: Stallman本人の記述に基づき、命名の経緯と動機を正確に記述

## 3. /usr/groupと標準化の前史

- **結論**: /usr/group（後のUniForum）のStandards Committeeが1981年に活動を開始し、1984年1月17日に/usr/group Standardを公表した。この文書がPOSIX.1-1988の直接的な基盤となった。1985年にAT&TがSystem V Interface Definition（SVID）第1版をSVR2に基づいて公表
- **一次ソース**: Open Group, "POSIX.1 Backgrounder"; Eric S. Raymond, "Unix Standards" (The Art of UNIX Programming)
- **URL**: <https://www.opengroup.org/austin/papers/backgrounder.html>, <http://www.catb.org/~esr/writings/taoup/html/ch17s02.html>
- **注意事項**: SVID第2版は1986年にSVR3に基づいて公表。AT&TはSVID準拠を「System V」ブランド使用の条件とした
- **記事での表現**: POSIX以前の標準化活動として/usr/group StandardとSVIDを位置づける

## 4. X/Open Portability Guide（XPG）の系譜

- **結論**: X/Openは1984年にヨーロッパのUNIXベンダー数社により設立されたコンソーシアム。1985年にXPG1（Issue 1）を公表。以降XPG2（1987年）、XPG3（1989年、POSIX仕様との収斂を図る）、XPG4（1992年7月）と発展した
- **一次ソース**: Wikipedia, "X/Open"
- **URL**: <https://en.wikipedia.org/wiki/X/Open>
- **注意事項**: XPG3からPOSIX仕様との整合が意識され始めた。XPG4はSingle UNIX Specificationの前身
- **記事での表現**: X/OpenがPOSIX標準を補完する実装基準として機能した経緯を記述

## 5. Single UNIX Specification（SUS）とSpec 1170

- **結論**: 1993年3月にCOSE（Common Open Software Environment）がHP、IBM、SunSoft、SCO、Novell、USLにより結成された。実際に使用されているUNIXインタフェースを調査した結果1,170個が特定され、「Spec 1170」と命名された。1993年にCOSEからX/Openへfasttrack手続きで引き渡され、最終的にSingle UNIX Specification（SUS）となった。SUS Version 1は1995年にリリース
- **一次ソース**: Wikipedia, "Common Open Software Environment"; Wikipedia, "Single UNIX Specification"
- **URL**: <https://en.wikipedia.org/wiki/Common_Open_Software_Environment>, <https://en.wikipedia.org/wiki/Single_UNIX_Specification>
- **注意事項**: COSEはUNIX Warsの収束を背景に、Microsoftの台頭（デスクトップ市場のWindows支配とサーバ市場への進出）に対抗するための業界連携だった
- **記事での表現**: UNIX Wars後の和解と標準化統合の文脈でSpec 1170→SUSの流れを記述

## 6. The Open Groupの設立とUNIX商標管理

- **結論**: 1993年10月、NovellがUNIXの商標権をX/Openに移転した（ソースコードの所有権とは別）。1996年にX/OpenとOSF（Open Software Foundation）が合併してThe Open Groupが設立された。The Open Groupが現在もUNIX商標を管理している
- **一次ソース**: The Open Group, "UNIX Certification"; unix.org, "History of UNIX"
- **URL**: <https://unix.org/what_is_unix/the_brand.html>, <https://www.unix.org/unix_history.html>
- **注意事項**: Novellは1993年6月14日にAT&TからUSL（Unix System Laboratories）を買収完了。UNIX商標のX/Openへの移転は同年10月。ソースコード所有権は1995年にSCO（Santa Cruz Operation）に売却
- **記事での表現**: 商標と実装の分離という歴史的転換点として記述

## 7. UNIX 95/98/03認証プログラム

- **結論**: UNIX 95はSUS Version 1に対応（1995年）、UNIX 98はSUS Version 2に対応（1997年）、UNIX 03はSUS Version 3に対応（2001年）。認証はThe Open Groupが管理する公式ブランドプログラムで、適合テストスイートへの合格が必要
- **一次ソース**: The Open Group, "The Register of UNIX Certified Products"
- **URL**: <https://www.opengroup.org/openbrand/register/>
- **注意事項**: UNIX 03が現在も使われている主要な認証レベル。認証には費用と継続的なテストが必要
- **記事での表現**: 「UNIXと名乗るためには認証が必要」という事実を明確にする

## 8. macOSのUNIX 03認証

- **結論**: Mac OS X 10.5 Leopard（2007年10月26日リリース、x86版）が最初のUNIX 03認証を取得したBSD系OSである。以降のmacOS全バージョン（OS X Lionを除く）がUNIX 03認証を継続している。最新ではmacOS 15.0 SequoiaおよびmacOS 26.0 TahoeもUNIX 03認証済み
- **一次ソース**: The Open Group, "Apple Inc. - Register of UNIX Certified Products"
- **URL**: <https://www.opengroup.org/openbrand/register/apple.htm>
- **注意事項**: OS X Lion（10.7）だけが認証を取得していない例外がある。認証の実態については批判的見解もある（OSnews, 2024年記事）
- **記事での表現**: macOSが「正式なUNIX」であるという事実と、その認証が意味するものを記述

## 9. POSIX.2（IEEE 1003.2-1992）——シェルとユーティリティの標準化

- **結論**: IEEE 1003.2-1992は6年間の作業を経て1992年9月に批准された。パート1（1003.2）がシェルスクリプトの移植性とユーティリティを定義、パート2（1003.2a）がUser Portability Extensions（UPE）としてviエディタ等の対話的ユーティリティを定義。標準シェルは主にSystem VのBourneシェルに基づく
- **一次ソース**: IEEE Standards Association, "IEEE 1003.2-1992"
- **URL**: <https://standards.ieee.org/standard/1003_2-1992.html>
- **注意事項**: bash拡張は標準には含まれない。POSIX準拠シェルスクリプトはbash固有機能を避ける必要がある
- **記事での表現**: POSIX.1（システムコール）とPOSIX.2（シェル・ユーティリティ）が標準の二本柱であることを記述

## 10. POSIX Threads（pthreads、IEEE 1003.1c-1995）

- **結論**: pthreadsはIEEE Std 1003.1c-1995として1995年に標準化された（ANSI承認は1996年6月7日）。POSIX標準への修正（amendment）としてスレッドプログラミングインタフェースを定義。libpthreadとして多くのUNIX系OSに実装されている
- **一次ソース**: IEEE Standards Association, "IEEE 1003.1c-1995"
- **URL**: <https://standards.ieee.org/ieee/1003.1c/1393/>
- **注意事項**: POSIX.1cはISO/IEC 9945-1:1996としても発行された
- **記事での表現**: POSIXがシステムコールだけでなくスレッドモデルまで標準化した範囲の広さを示す例として使用

## 11. POSIX.1-2001/SUSv3とAustin Groupによる統合

- **結論**: 2001年にPOSIX.1、POSIX.2、SUSの各標準がAustin Groupの主導により単一文書に統合された。これがPOSIX.1-2001（IEEE Std 1003.1-2001）＝SUS Version 3（SUSv3）である。その後POSIX.1-2008（SUSv4、2008年12月）、POSIX.1-2017（SUSv4 + TC1 + TC2と実質同一）、POSIX.1-2024（2024年6月14日発行、最新版）と改訂が続く
- **一次ソース**: The Open Group, "The Single UNIX Specification, Version 4 - Introduction"
- **URL**: <https://unix.org/version4/overview.html>
- **注意事項**: POSIX.1-2017はPOSIX.1-2008にTechnical Corrigenda 1（2013年）と2（2016年）を適用したもので、技術的には同一。POSIX.1-2024はC17言語標準に対応
- **記事での表現**: 標準の統合と改訂の流れを時系列で記述

## 12. POSIXが標準化しなかった範囲

- **結論**: POSIXが意図的に標準化しなかった領域: (1) GUI（ベンダー間で共通基盤がなく、X Window Systemすら合意されなかった）、(2) パッケージ管理、(3) サービス管理（init/systemd）、(4) デバイス命名規則、(5) システム管理・設定。POSIXの「シェル」定義はコマンド言語インタプリタに限定され、GUIシェルは除外
- **一次ソース**: Chris Siebenmann, "Why there is no POSIX standard for a Unix GUI"; Tech Monitor, "THE LIMITATIONS OF POSIX COMPLIANCE"
- **URL**: <https://utcc.utoronto.ca/~cks/space/blog/unix/WhyNoStandardUnixGUIs>, <https://www.techmonitor.ai/technology/the_limitations_of_posix_compliance_and_why_it_does_not_mean_unix_compatibility>
- **注意事項**: GUI標準化の失敗はMotif/CDE vs GNOME/KDEの歴史にも関連。パッケージ管理の非標準化がLinuxディストリビューションの分裂を招いた一因
- **記事での表現**: POSIXの限界を「標準化した範囲」と「しなかった範囲」の対比で記述

## 13. POSIX準拠と互換性の乖離

- **結論**: POSIX準拠（compliance）は非公式な業界用語で、標準の一部を実装していれば名乗れる。POSIX適合（conformance）は公式認証テストスイートに合格した状態。Linuxは事実上POSIX準拠だが公式の適合認証は受けていない。認証は高額で時間がかかるため、多くのOSは認証なしに「POSIX互換」として運用されている。ソースコードレベルの移植性を保証するが、バイナリレベルの互換性は保証しない
- **一次ソース**: Tech Monitor, "THE LIMITATIONS OF POSIX COMPLIANCE AND WHY IT DOES NOT MEAN UNIX COMPATIBILITY"
- **URL**: <https://www.techmonitor.ai/technology/the_limitations_of_posix_compliance_and_why_it_does_not_mean_unix_compatibility>
- **注意事項**: 「POSIX準拠」を名乗るシステム間でも実際の移植には相当の作業が必要な場合がある
- **記事での表現**: 著者体験（POSIX準拠同士で移植に苦労した話）と結びつけて記述
