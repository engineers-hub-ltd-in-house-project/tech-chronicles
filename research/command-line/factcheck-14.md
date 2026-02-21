# ファクトチェック記録：第14回「GNU coreutils――自由なUNIXツール群の再実装」

## 1. GNUプロジェクトの発表と GNU Manifesto

- **結論**: Richard Stallmanは1983年9月27日にUsenetのnet.unix-wizardsニュースグループにGNUプロジェクトの初期発表を投稿した。これは「GNU Manifesto」そのものではなく、プロジェクトの告知である。GNU ManifestoはDr. Dobb's Journalの1985年3月号に掲載された
- **一次ソース**: GNU Project, "Initial Announcement", gnu.org; Wikipedia, "GNU Manifesto"
- **URL**: <https://www.gnu.org/gnu/initial-announcement.en.html>, <https://en.wikipedia.org/wiki/GNU_Manifesto>
- **注意事項**: ブループリントでは「GNU Manifesto（1983年9月27日）」とあるが、1983年9月27日は初期発表（Usenet投稿）の日付であり、GNU Manifestoの出版は1985年3月。記事では両者を区別する
- **記事での表現**: 「1983年9月27日、Richard StallmanはUsenetのnet.unix-wizardsニュースグループに"Free Unix!"と題する投稿を行った」「1985年3月、Dr. Dobb's JournalにGNU Manifestoが掲載された」

## 2. GNUプロジェクトの戦略と開発順序

- **結論**: GNUプロジェクトはまずツール群を再実装し、最後にカーネル（Hurd）を作る戦略を採った。最初の主要ツールはGNU Emacs（開発1984年、公開1985年3月20日）。GCC（GNU C Compiler）は1987年3月22日にベータリリース
- **一次ソース**: Wikipedia, "GNU Emacs"; Wikipedia, "GNU Compiler Collection"; Wikipedia, "GNU Project"
- **URL**: <https://en.wikipedia.org/wiki/GNU_Emacs>, <https://en.wikipedia.org/wiki/GNU_Compiler_Collection>, <https://en.wikipedia.org/wiki/GNU_Project>
- **注意事項**: GNU Emacsの最初の公開リリースは1985年3月20日。GCCの最初のリリースは1987年3月22日（FTP経由、MIT）
- **記事での表現**: 「GNUプロジェクトの戦略は明確だった。まず、既存のUNIXで動作するツール群を自由なライセンスで再実装する。コンパイラ、エディタ、シェル、ユーティリティ。最後にカーネルを開発してシステムを完成させる」

## 3. GNU coreutilsの統合（2003年）

- **結論**: GNU coreutilsは、fileutils、textutils、shellutils（sh-utils）の3パッケージを統合して2003年に誕生。最初のメジャーリリースはcoreutils 5.0（2003年4月4日発表）。統合前の最後の個別バージョンはfileutils-4.1.11、textutils-2.1、sh-utils-2.0.15
- **一次ソース**: Wikipedia, "GNU Core Utilities"; GNU, "Coreutils FAQ"
- **URL**: <https://en.wikipedia.org/wiki/GNU_Core_Utilities>, <https://www.gnu.org/software/coreutils/faq/coreutils-faq.html>
- **注意事項**: 統合作業自体は2002年後半に開始され、2003年4月に最初の統合リリース
- **記事での表現**: 「2003年、GNU coreutilsが誕生した。それまで別々に開発・リリースされていたfileutils、textutils、sh-utils（shellutils）の三つのパッケージが一つに統合された」

## 4. GNU coreutilsに含まれるコマンド数

- **結論**: GNU coreutilsには約108個のコマンドが含まれる
- **一次ソース**: Wikipedia, "List of GNU Core Utilities commands"; Robert Elder's Guide To GNU Coreutils
- **URL**: <https://en.wikipedia.org/wiki/List_of_GNU_Core_Utilities_commands>, <https://blog.robertelder.org/gnu-coreutils-package-guide/>
- **注意事項**: バージョンによりコマンド数は若干変動する
- **記事での表現**: 「GNU coreutilsは100以上のコマンドを収録している」

## 5. GNU long options（ダブルダッシュ規約）の歴史

- **結論**: GNUプロジェクトは当初、long optionsにプラス記号（+）を使用していたが、後にダブルダッシュ（--）に変更した。Richard Stallmanは、TOPS-20などのOSが長いオプション名をサポートしていたことに影響を受け、UNIXのシングルレターオプションの限界を超えたいと考えた。getopt_long()関数がGNU C Libraryで実装された
- **一次ソース**: Wikipedia, "Getopt"; blog.djmnet.org, "Why Do Long Options Start with Two Dashes?"
- **URL**: <https://en.wikipedia.org/wiki/Getopt>, <https://blog.djmnet.org/2019/08/02/why-do-long-options-start-with/>
- **注意事項**: 当初は+prefix → 後に--prefixに変更。ダブルダッシュにより、-abcのような短いオプションの結合と--longoptionを明確に区別可能
- **記事での表現**: 「GNU long optionsは当初プラス記号（+option）で始まっていたが、やがてダブルダッシュ（--option）に統一された。この設計により、`-abc`（短いオプション3つの結合）と`--abc`（長いオプション1つ）を曖昧さなく区別できるようになった」

## 6. GPLライセンスと「ソフトウェアの自由」の4つの自由

- **結論**: 自由ソフトウェアの定義は4つの自由を保証する。Freedom 0: プログラムを任意の目的で実行する自由。Freedom 1: プログラムの動作を研究し変更する自由。Freedom 2: コピーを再配布する自由。Freedom 3: 改変版を配布する自由。GPL v1は1989年2月25日リリース。GPL v2は1991年6月。GPL v3は2007年
- **一次ソース**: GNU Project, "What is Free Software?"; Wikipedia, "GNU General Public License"
- **URL**: <https://www.gnu.org/philosophy/free-sw.en.html>, <https://en.wikipedia.org/wiki/GNU_General_Public_License>
- **注意事項**: 自由ソフトウェアの定義の最初の出版物は1986年2月のGNU's Bulletin。当初は2つの自由として定義され、後に4つに拡張
- **記事での表現**: 「GPLは『コピーレフト』の原則を法的に実装したライセンスだ。GPLの下で配布されたソフトウェアの派生物は、同じライセンス条件で配布しなければならない」

## 7. BSDツールとGNUツールの差異

- **結論**: macOSはFreeBSD由来のBSD系コマンドラインツールを搭載。GNU lsの`--color=auto`に対し、BSD lsでは`-G`フラグが対応。色定義の環境変数もLS_COLORS（GNU）対LSCOLORS（BSD）と異なる。GNU版はlong options（--で始まるオプション）を広く採用しているが、BSD版はPOSIXに近い短いオプション中心
- **一次ソース**: Using GNU command line tools in macOS instead of FreeBSD tools (GitHub gist)
- **URL**: <https://gist.github.com/aculich/2283cc616b61ea908c978cffe6e92b12>
- **注意事項**: Homebrewでは`g`プレフィックス（gls, gsed等）でGNU版をインストール可能
- **記事での表現**: 「macOSのlsはBSD由来であり、GNU lsの`--color=auto`は使えない。代わりに`-G`フラグを使う」

## 8. BusyBox

- **結論**: BusyBoxはBruce Perensが1995年に開発を開始し、1996年に完成と宣言。当初はDebianのインストーラ/レスキューディスク用に1枚のフロッピーにシステムを収めることが目的。300以上のコマンドを単一のバイナリに統合。「The Swiss Army knife of Embedded Linux」の異名を持つ
- **一次ソース**: Wikipedia, "BusyBox"; BusyBox公式サイト
- **URL**: <https://en.wikipedia.org/wiki/BusyBox>, <https://busybox.net/downloads/BusyBox.html>
- **注意事項**: 1998年にDave Cinege（Linux Router Project）が引き継ぎ、組み込みシステム向けに方向転換。1999年-2006年はErik Andersenがメンテナ
- **記事での表現**: 「BusyBoxは1995年にBruce Perensが開発を始めた。当初の目的は、Debianのインストーラとレスキューディスクを1枚のフロッピーディスクに収めることだった」

## 9. Slackware 3.5

- **結論**: Slackware 3.5は1998年6月9日リリース。カーネル2.0.34を搭載。GNU gcc、g++、Objective-Cのバージョン2.4.5を含む
- **一次ソース**: Wikipedia, "Slackware"; Internet Archive, "Slackware 3.5"
- **URL**: <https://en.wikipedia.org/wiki/Slackware>, <https://archive.org/details/Slackware35>
- **注意事項**: Slackware 3.5の正確なリリース日は1998年6月9日
- **記事での表現**: 「1998年、Slackware 3.5をインストールした私のマシンには、GNUツールが入っていた。私がlsと打つとき、それはAT&TのオリジナルUNIX lsではなく、GNU fileutilsのlsだった」

## 10. POSIX標準の歴史

- **結論**: POSIX（Portable Operating System Interface）の最初の標準はIEEE Std 1003.1-1988。シェルとユーティリティに関するPOSIX.2（IEEE Std 1003.2）は1992年に公布。1999年にPOSIX.1とPOSIX.2の統合が決定
- **一次ソース**: Wikipedia, "POSIX"; The Open Group, "POSIX.1 Backgrounder"
- **URL**: <https://en.wikipedia.org/wiki/POSIX>, <https://www.opengroup.org/austin/papers/backgrounder.html>
- **注意事項**: POSIXLY_CORRECT環境変数を設定すると、GNU拡張が抑制されPOSIX互換動作になる
- **記事での表現**: 「1988年、IEEEはPOSIX（IEEE Std 1003.1-1988）を制定した。1992年にはPOSIX.2（IEEE Std 1003.2）でシェルとユーティリティの標準が定められた」

## 11. uutils/coreutils（Rust製の再実装）

- **結論**: uutils/coreutilsはGNU coreutilsのRust言語による再実装プロジェクト。クロスプラットフォーム（Linux, macOS, Windows）対応を目指す。メモリ安全性を提供。BusyBox的な単一バイナリ構造も採用可能
- **一次ソース**: GitHub, uutils/coreutils
- **URL**: <https://github.com/uutils/coreutils>
- **注意事項**: GNU coreutilsのドロップイン代替を目指している。2025年時点でフィーチャーパリティに近づいている
- **記事での表現**: 「2020年代には、Rust言語で書かれたuutils/coreutilsが登場し、GNU coreutilsのクロスプラットフォーム再実装を進めている」

## 12. GNU gawk（GNU AWK）の開発

- **結論**: GNU AWK（gawk）は1988年にリリース。Paul Rubin、Jay Fenlason、Richard Stallmanが開発。1994年以降はArnold Robbinsが単独でメンテナンス
- **一次ソース**: Wikipedia, "AWK"
- **URL**: <https://en.wikipedia.org/wiki/AWK>
- **注意事項**: オリジナルのawkはAho、Weinberger、Kernighanが1977年に開発
- **記事での表現**: 「GNU AWK（gawk）は1988年にリリースされ、オリジナルのawkを自由ソフトウェアとして再実装した」
