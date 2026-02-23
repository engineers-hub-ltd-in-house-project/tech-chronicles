# ファクトチェック記録：第19回「macOS——UNIXが消費者の手に届いた日」

調査日：2026-02-23

---

## 1. NeXTSTEPの歴史

- **結論**: NeXT社はSteve Jobsにより1985年9月16日に法人登記された（同日がApple正式退任日）。NeXTSTEP 1.0は1989年9月18日にリリースされた。技術基盤はMachマイクロカーネル2.5と4.3BSD-Tahoeである。プレビュー版（0.8）は1988年10月12日のNeXT Computer発表時に公開された。
- **一次ソース**: Wikipedia, "NeXTSTEP", <https://en.wikipedia.org/wiki/NeXTSTEP>; TechRadar, "Steve Jobs' iconic NeXT venture officially launched 40 years ago", 2025
- **URL**: <https://en.wikipedia.org/wiki/NeXTSTEP>
- **注意事項**: NeXT社の「設立」日には複数の解釈がある。Jobsが最初に公表したのは1985年9月12日だが、法人登記は9月16日。Mach 2.5は「ライブラリとしてBSDカーネルに組み込まれた」ハイブリッド構成であり、純粋なマイクロカーネルではない点に注意。
- **記事での表現**: 「1985年にAppleを去ったSteve Jobsが設立したNeXT社は、1989年にNeXTSTEP 1.0をリリースした。その基盤はCarnegie Mellon大学のMachマイクロカーネル2.5と4.3BSDであり、UNIXの技術資産を継承したオブジェクト指向OSだった。」

## 2. Machマイクロカーネルの起源

- **結論**: MachはCarnegie Mellon大学でRichard RashidとAvie Tevanianを中心に1985年から1994年にかけて開発された。Mach 1.0は1985年に内部リリース。Mach 2.5はBSD互換レイヤーを含むモノリシック的構成。Mach 3.0は1994年にリリースされ、BSDカーネルコードを除去した純粋なマイクロカーネル設計となった。
- **一次ソース**: Wikipedia, "Mach (kernel)"; CMU Mach 3.0 Sources; GNU Hurd, "Mach History"
- **URL**: <https://en.wikipedia.org/wiki/Mach_(kernel)>
- **注意事項**: Mach 2.5の正確なリリース年は資料によって異なる（1988年〜1990年頃）。Avie Tevanianは後にNeXTのソフトウェア責任者、さらにAppleのChief Software Technology Officerとなった。
- **記事での表現**: 「1985年、Carnegie Mellon大学のRichard RashidとAvie Tevanianらは、分散コンピューティング研究のためにMachカーネルの開発を開始した。Avie Tevanianは後にNeXTのソフトウェア責任者となり、さらにAppleのChief Software Technology Officerとして、MachをmacOSの心臓部に据える橋渡しをした。」

## 3. Mac OS X 10.0のリリース

- **結論**: Mac OS X 10.0（コードネーム"Cheetah"）は2001年3月24日にリリースされた。Mac OS X Public Betaは2000年9月13日に先行公開されている。
- **一次ソース**: Wikipedia, "Mac OS X 10.0"; macOS version history
- **URL**: <https://en.wikipedia.org/wiki/Mac_OS_X_10.0>
- **注意事項**: リリース日2001年3月24日、コードネーム"Cheetah"はいずれも確認済み。
- **記事での表現**: 「2001年3月24日、Mac OS X 10.0 "Cheetah"がリリースされた。」

## 4. Darwinのオープンソース化

- **結論**: Appleは2000年4月5日にDarwin 1.0をオープンソースとしてリリースした。ライセンスはApple Public Source License（APSL）。2003年7月にAPSL 2.0へ改訂され、FSFはこれをフリーソフトウェアライセンスと認定した。
- **一次ソース**: Apple Newsroom, "Apple Releases Darwin 1.0 Open Source", April 5, 2000
- **URL**: <https://www.apple.com/newsroom/2000/04/05Apple-Releases-Darwin-1-0-Open-Source/>
- **注意事項**: APSL 1.0はFSFから「フリーソフトウェアライセンスではない」と批判されていた。APSL 2.0で初めてFSFの承認を得た。高レベルフレームワーク（Cocoa, Carbon）はクローズドソースのまま。
- **記事での表現**: 「2000年4月5日、AppleはmacOSの中核をDarwin 1.0としてオープンソース公開した。」

## 5. macOSのUNIX 03認証

- **結論**: Mac OS X 10.5 Leopard（Intelプラットフォーム）が2007年にThe Open GroupからUNIX 03認証を取得した。BSD系OSとして初のUNIX 03認証。以後macOSの各バージョンで認証が維持されており、macOS 15.0 Sequoia（2024年）もApple SiliconおよびIntelの両プラットフォームでUNIX 03認証を取得している。
- **一次ソース**: The Open Group, "Open Brand Register"; Engadget, "Leopard qualifies for official UNIX 03 certification", 2007
- **URL**: <https://www.opengroup.org/openbrand/register/>
- **注意事項**: Leopardの認証はIntel Macのみで、PowerPC Macは対象外だった。認証対象はSingle UNIX Specification Version 3（2004年策定）であり、Version 4（2016年策定）ではない。
- **記事での表現**: 「2007年、Mac OS X 10.5 LeopardはThe Open GroupからUNIX 03認証を取得した。BSD系OSとしては初の快挙であり、macOSは正式に『UNIX』を名乗れるOSとなった。」

## 6. XNUカーネルのアーキテクチャ

- **結論**: XNUは"X is Not Unix"の再帰的頭字語。ハイブリッドカーネルであり、(1) OSFMK 7.3ベースのMachマイクロカーネル（CMU Mach 3.0およびUtah大学Mach 4由来）、(2) FreeBSD由来のBSD層（POSIX API、プロセスモデル、ネットワークスタック、VFS）、(3) IOKit（Embedded C++サブセットで記述されたオブジェクト指向デバイスドライバフレームワーク）から構成される。
- **一次ソース**: Wikipedia, "XNU"; GitHub, apple-oss-distributions/xnu; Apple Developer, "BSD Overview"
- **URL**: <https://en.wikipedia.org/wiki/XNU>
- **注意事項**: 「FreeBSD 5ベース」は歴史的出発点であり、Appleは継続的に新しいコードを選択的に取り込んでいる。「macOS = FreeBSD」ではなく、大幅にカスタマイズされた独自実装。
- **記事での表現**: 「XNU——"X is Not Unix"という再帰的頭字語を持つこのカーネルは、Machマイクロカーネル、FreeBSD由来のBSD層、IOKitドライバフレームワークという三つの要素を融合したハイブリッドカーネルである。」

## 7. Apple Silicon M1への移行

- **結論**: Apple M1チップは2020年11月10日のAppleイベントで発表された。M1搭載Macは2020年11月17日に発売。macOS 11 Big SurがApple Silicon対応の最初のmacOSリリース。Darwin/XNUはarm64eアーキテクチャに対応し、Pointer Authentication（PAC）をサポート。
- **一次ソース**: Apple Newsroom, "Apple unleashes M1", November 10, 2020
- **URL**: <https://www.apple.com/newsroom/2020/11/apple-unleashes-m1/>
- **注意事項**: Apple Siliconへの移行発表自体はWWDC 2020（2020年6月22日）で行われ、M1チップの具体的発表は11月10日。arm64eはPointer Authenticationを加えたApple独自拡張。
- **記事での表現**: 「2020年11月、AppleはM1チップを発表しMacのアーキテクチャをx86からARMに移行した。Darwin/XNUカーネルのアーキテクチャ中立性——Machから受け継いだ設計思想——がこの大規模な移行を可能にした。」

## 8. launchd

- **結論**: launchdはAppleのDave Zarzyckiが設計し、2005年4月のMac OS X 10.4 Tigerで導入された。init、inetd、cronなどの機能を一元化した統合サービス管理フレームワーク。systemd（2010年、Lennart Poettering）はlaunchdのソケットアクティベーション機構に影響を受けている。
- **一次ソース**: Wikipedia, "launchd"; Lennart Poettering, "Rethinking PID 1", 2010
- **URL**: <https://en.wikipedia.org/wiki/Launchd>
- **注意事項**: systemdがlaunchdに「影響を受けた」は正確だが、「模倣」ではない。Poettering自身が"Rethinking PID 1"でlaunchdに言及している。
- **記事での表現**: 「2005年、Mac OS X 10.4 TigerでAppleのDave Zarzyckiが設計したlaunchdが導入された。init、inetd、cronの機能を一つのデーモンに統合するこの設計は、5年後のsystemdの着想源の一つとなった。」

## 9. APFS（Apple File System）

- **結論**: APFSは2016年6月13日のWWDC 2016で発表され、2017年9月25日にmacOS 10.13 High Sierraで正式導入。HFS+（1998年導入）の後継。AppleはZFSの採用を検討したが、CDDLライセンスの問題により2009年10月に断念した。
- **一次ソース**: Wikipedia, "Apple File System"; Gizmodo, "Why Did Apple Drop ZFS From Snow Leopard?", 2009
- **URL**: <https://en.wikipedia.org/wiki/Apple_File_System>
- **注意事項**: ZFS中止の正確な理由はAppleから公式説明がなく、ライセンス問題説が最有力だが確定ではない。
- **記事での表現**: 「2017年、AppleはHFS+に代わるAPFSをmacOS High Sierraで導入した。AppleはかつてZFSの採用を模索したが、CDDLライセンスとの相容れなさから2009年に断念し、独自のファイルシステムを構築する道を選んだ。」

## 10. Homebrewパッケージマネージャ

- **結論**: HomebrewはMax Howellにより2009年に作成された（最初のコミット2009年5月20日）。先行するMacPorts（旧名DarwinPorts）は2002年にApple社員（Landon Fuller、Kevin Van Vechten、Jordan Hubbard）によりOpenDarwinプロジェクトの一部として開始。
- **一次ソース**: Wikipedia, "Homebrew (package manager)"; MacPorts Wiki, "MacPortsHistory"
- **URL**: <https://en.wikipedia.org/wiki/Homebrew_(package_manager)>
- **注意事項**: Jordan HubbardはFreeBSDの共同創設者であり、Apple在籍時にDarwinPorts/MacPortsに関与した点は重要。
- **記事での表現**: 「2002年にApple社員らが立ち上げたDarwinPorts（後のMacPorts）、2009年にMax Howellが公開したHomebrewが、macOSのUNIXパッケージエコシステムを形成した。」

## 11. Steve JobsのApple復帰

- **結論**: AppleはNeXTを1996年12月20日に4億2900万ドルとApple株式150万株で買収した。Jobsは"特別顧問"として復帰。1997年9月16日に暫定CEO（iCEO）就任。2000年1月5日に正式にCEOとなった。
- **一次ソース**: Cult of Mac; MacRumors, "25 Years Ago, Apple Acquired NeXT", 2021; Wikipedia, "Steve Jobs"
- **URL**: <https://en.wikipedia.org/wiki/Steve_Jobs>
- **注意事項**: 買収額は「4億2900万ドル」が広く引用される。暫定CEO（1997年9月）と正式CEO（2000年1月）を区別して記述すべき。
- **記事での表現**: 「1996年12月20日、AppleはNeXTを4億2900万ドルで買収した。Steve Jobsは1997年9月に暫定CEOに就任し、NeXTSTEPの技術資産がmacOSの基盤となった。」

## 12. macOSにおけるFreeBSDユーザランド

- **結論**: macOS（Darwin）のBSD層は主にFreeBSD 5のコードを基盤としている。BSD層はXNUカーネル内でMach層の上に実装され、POSIX API、UNIXプロセスモデル、ネットワークスタック、VFSを提供する。ユーザランドのコマンド群（ls、cp、grep等）もFreeBSD由来だが独自に分岐している。macOSのBSDコマンドはGNUコアユーティリティとはオプション体系が異なる。
- **一次ソース**: Apple Developer Documentation, "BSD Overview"; Wikipedia, "XNU"; FreeBSD Foundation記事
- **URL**: <https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/KernelProgramming/BSD/BSD.html>
- **注意事項**: 「FreeBSD 5ベース」は歴史的出発点であり、Appleは継続的に新しいコードを選択的に取り込んでいる。macOSのBSD sedにはGNU拡張がないなど、実用上の違いがある。
- **記事での表現**: 「macOSのXNUにおいて、FreeBSD由来のBSD層はMachの上に載るかたちでUNIXの顔——POSIX API、プロセスモデル、ネットワークスタック——を提供している。」
