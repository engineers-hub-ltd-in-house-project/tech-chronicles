# ファクトチェック記録：第15回「GPLv3とbashデフォルト時代の終焉――AppleがmacOSのデフォルトをzshに変えた日」

## 1. bash 3.2のリリース日とGPLv2最終版

- **結論**: bash 3.2は2006年10月12日にChet Rameyがリリースを発表した。bash 3.x系がGPLv2でリリースされた最後のメジャーバージョンである。Apple向けの最終パッチは3.2.57（2014年）
- **一次ソース**: Chet Ramey, "Bash-3.2 available for FTP", 2006-10-12
- **URL**: <https://sourceware.org/legacy-ml/cygwin/2006-10/msg00464.html>
- **注意事項**: bash 3.2.57はAppleが出荷した最終バージョン。2026年現在のmacOS（Ventura, Sonoma, Sequoia）でも/bin/bashは3.2.57のまま
- **記事での表現**: bash 3.2（2006年10月）はGPLv2でリリースされた最後のbashメジャーバージョンである

## 2. bash 4.0のリリース日とGPLv3への移行

- **結論**: bash 4.0は2009年2月20日にChet Rameyがリリースを発表した。GPLv3ライセンスで公開された最初のbashメジャーバージョンである。主要な新機能は連想配列、コプロセス（coproc）、globstar（`**`パターン）、case文の`;&`と`;;&`ターミネータ
- **一次ソース**: Chet Ramey, "Bash-4.0 available for FTP", 2009-02-20; TLDP, "Bash, version 4"; LWN.net, "Bash 4.0 released"
- **URL**: <https://lwn.net/Articles/320366/>, <https://tldp.org/LDP/abs/html/bashver4.html>
- **注意事項**: bash 4.0への移行はGPLv3への移行を意味する。GPLv3は2007年6月29日に公表されており、bash 4.0のリリースはその約1年8ヶ月後
- **記事での表現**: 2009年2月20日、bash 4.0がリリースされた。ライセンスはGPLv3。連想配列、コプロセス、globstarなどの重要な新機能が追加された

## 3. GPLv3のリリース日と主要な変更点

- **結論**: GPLv3は2007年6月29日にFree Software Foundationが公表した。1年半の公開協議、数千のコメント、4つのドラフトを経ての公表。GPLv2からの主要な変更点は (1) Anti-Tivoization条項、(2) 明示的な特許保護条項、(3) DRM/技術的保護手段に関する条項
- **一次ソース**: Free Software Foundation, "FSF releases the GNU General Public License, version 3", 2007-06-29
- **URL**: <https://www.fsf.org/news/gplv3_launched>, <https://www.gnu.org/licenses/rms-why-gplv3.en.html>
- **注意事項**: GPLv2は1991年公表。GPLv3は16年ぶりのメジャー改訂
- **記事での表現**: 2007年6月29日、FSFはGPLv3を公表した。GPLv2から16年ぶりの改訂であり、Anti-Tivoization条項、明示的特許保護、DRM対策が追加された

## 4. Tivoization/Anti-Tivoization条項の内容

- **結論**: Tivoizationとは、GPLソフトウェアをハードウェアに組み込みつつ、ハードウェア制限によりユーザーが改変版を実行できないようにする行為。Richard StallmanがTiVo社のデジタルビデオレコーダーにおけるGNU GPLソフトウェア使用を指して命名。GPLv3はこれを明示的に禁止し、消費者向け製品にGPLv3ソフトウェアを配布する場合、改変ソフトウェアのインストールに必要な情報（暗号鍵等）の提供を義務付けた
- **一次ソース**: Wikipedia, "Tivoization"; FSF, "A Quick Guide to GPLv3"
- **URL**: <https://en.wikipedia.org/wiki/Tivoization>, <https://www.gnu.org/licenses/quick-guide-gplv3.html>
- **注意事項**: Anti-Tivoization条項は消費者向け製品にのみ適用。ビジネス/組織向け製品にはTivoizationが許容される
- **記事での表現**: GPLv3のAnti-Tivoization条項は、ハードウェアにGPLソフトウェアを組み込む企業に対し、ユーザーが改変版を実行するために必要な情報の提供を義務付けた

## 5. AppleのGPLソフトウェア排除の歴史

- **結論**: Appleは2011年前後から体系的にGPLライセンスのソフトウェアをmacOSから排除し始めた。OS X 10.5には47のGPLパッケージがあったが、10.6で44、10.7で29に減少。主要な排除例: (1) Samba→自社製SMBX (OS X 10.7 Lion, 2011年)、(2) GCC→Clang/LLVM (Xcode 4.x以降)、(3) GNU coreutils→BSD版ツール。bashも3.2（GPLv2最終版）で凍結された
- **一次ソース**: "Apple's great GPL purge" (2012年分析記事); Slashdot, "Apple Remove Samba From OS X 10.7 Because of GPLv3"
- **URL**: <https://news.ycombinator.com/item?id=3559990>, <https://apple.slashdot.org/story/11/03/24/1546205/apple-remove-samba-from-os-x-107-because-of-gplv3>
- **注意事項**: Apple自身は公式にGPL排除の方針を表明したことはない。排除のパターンから推測されている
- **記事での表現**: Appleは2011年前後からGPLv3ソフトウェアの体系的な排除を進めた。OS X 10.5の47パッケージから10.7では29パッケージへと、GPLソフトウェアは着実に減少した

## 6. macOSにおけるbashのデフォルト化と終焉

- **結論**: Mac OS X 10.3 Panther（2003年）でtcshからbashにデフォルトシェルが変更された。それ以前のOS X 10.2 Jagarではtcshがデフォルトだった。2019年10月7日リリースのmacOS Catalina（10.15）でデフォルトがzshに変更。WWDC 2019（2019年6月3日）で発表。新規ユーザーアカウントのみzshがデフォルト、既存ユーザーはbashのまま
- **一次ソース**: Apple Support Document; Wikipedia, "macOS Catalina"; OSnews, "Apple switching from tcsh to bash" (2003年)
- **URL**: <https://en.wikipedia.org/wiki/MacOS_Catalina>, <https://www.osnews.com/story/4340/apple-switching-from-tcsh-to-bash/>
- **注意事項**: bashは16年間（2003-2019年）macOSのデフォルトシェルだった
- **記事での表現**: 2003年、Mac OS X PantherでAppleはtcshからbashにデフォルトシェルを変更した。16年後の2019年、macOS CatalinaでAppleはbashからzshへとデフォルトを再び変更した

## 7. zshのライセンスと選定理由

- **結論**: zshはMITライセンス（MIT-like license）で公開されている。GPLv3のような制約がなく、Appleの配布方針と矛盾しない。Paul Falstadが1990年にPrinceton大学で最初のバージョンを作成。名前はYale大学教授Zhong Shaoのログイン名「zsh」に由来。Bourne shell互換でbashとの互換性も高い
- **一次ソース**: Wikipedia, "Z shell"
- **URL**: <https://en.wikipedia.org/wiki/Z_shell>
- **注意事項**: Appleはzshへのデフォルト変更の理由を公式には技術的互換性として説明したが、GPLv3回避が主要因であることは広く認識されている
- **記事での表現**: zshはMITライセンスで公開されており、GPLv3の制約を回避したいAppleにとって理想的な選択肢だった

## 8. bash 3.2で使えない主要なbash 4.x/5.x機能

- **結論**: bash 3.2（macOS同梱版）で使えない主要機能: (1) 連想配列 declare -A（bash 4.0）、(2) コプロセス coproc（bash 4.0）、(3) globstar `**`パターン（bash 4.0）、(4) case文の`;&`と`;;&`（bash 4.0）、(5) nameref変数 declare -n（bash 4.3）、(6) mapfileの`-d`オプション（bash 4.4）、(7) `${parameter@operator}`変換（bash 4.4）、(8) `$EPOCHSECONDS`と`$EPOCHREALTIME`（bash 5.0）
- **一次ソース**: TLDP, "Bash, version 4"; GNU Bash Reference Manual; LWN.net, "Bash 4.0 brings new capabilities"
- **URL**: <https://tldp.org/LDP/abs/html/bashver4.html>, <https://lwn.net/Articles/320546/>
- **注意事項**: process substitution (`<()`, `>()`)はbash 3.2でも使用可能。`&>>`（stdoutとstderrの追記リダイレクト）はbash 4.0で追加
- **記事での表現**: macOSに同梱されたbash 3.2は、2009年以降にリリースされた13年分の新機能が一切使えない。連想配列もglobstarもnameref変数も存在しない世界だ

## 9. GCC→Clang/LLVMへの移行

- **結論**: AppleはGCCがGPLv3に移行したことを受け、独自にClang/LLVMの開発を推進した。Clangは2007年7月にオープンソース化が承認された。Apache 2.0ライセンス。Xcode 4.x（2013年頃まで）ではLLVM-GCCが暫定的に使用され、その後完全にClangに移行。GCC 4.2がAppleがmacOSに同梱した最後のGCCバージョン
- **一次ソース**: Wikipedia, "Clang"; Wikipedia, "LLVM"
- **URL**: <https://en.wikipedia.org/wiki/Clang>, <https://en.wikipedia.org/wiki/LLVM>
- **注意事項**: AppleのClang移行にはライセンス以外にも技術的理由がある（Objective-Cサポート、IDEとの統合、モジュラー設計）
- **記事での表現**: GCCのGPLv3移行は、AppleにClang/LLVMという代替コンパイラを生み出させた。ライセンス問題が技術革新を触発した一例である

## 10. macOS上のbash 3.2.57の現状（2026年時点）

- **結論**: 2026年現在、macOS Ventura、Sonoma、Sequoiaのいずれでも/bin/bashは3.2.57のままである。Appleはbashを更新する予定はない。ユーザーはHomebrew等で最新のbash 5.xをインストールする必要がある。/bin/bashは3.2.57で凍結されている
- **一次ソース**: 複数のmacOS技術ブログ・コミュニティ
- **URL**: <https://itnext.io/upgrading-bash-on-macos-7138bd1066ba>, <https://edu.chainguard.dev/open-source/update-bash-macos/>
- **注意事項**: macOS Sequoia（2024年）以降、/bin/bashの存在自体が将来的に削除される可能性も議論されているが、確定情報はない
- **記事での表現**: 2026年現在、macOSの/bin/bashは依然として3.2.57である。18年前のソフトウェアが、世界で最も普及したデスクトップOSの一つに同梱され続けている
