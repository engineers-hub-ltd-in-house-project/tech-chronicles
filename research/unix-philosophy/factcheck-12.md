# ファクトチェック記録：第12回「GNU宣言とFSF——自由ソフトウェアという思想」

## 1. GNU プロジェクト発表日とUsenet投稿

- **結論**: Richard Stallmanは1983年9月27日、Usenetのnet.unix-wizardsおよびnet.usoftグループに「New UNIX implementation」というタイトルでGNUプロジェクトを発表した。投稿時刻は午前0時30分、署名はrms@mit-oz。開発は1984年1月に開始。
- **一次ソース**: GNU Project, "Initial Announcement"
- **URL**: <https://www.gnu.org/gnu/initial-announcement.en.html>
- **注意事項**: 発表は1983年9月だが、実際の開発開始は1984年1月
- **記事での表現**: 「1983年9月27日、Usenetのnet.unix-wizardsに『New UNIX implementation』と題された投稿が現れた」

## 2. GNU宣言の発表（1985年、Dr. Dobb's Journal）

- **結論**: GNU宣言は1985年3月、Dr. Dobb's Journal of Software Toolsに掲載された（pp. 30-34）。「Realizable Fantasies」というテーマのもとで発表。1987年に若干の更新が行われた。
- **一次ソース**: Dr. Dobb's Journal, March 1985; GNU Project公式サイト
- **URL**: <https://en.wikipedia.org/wiki/GNU_Manifesto>
- **注意事項**: 宣言はプロジェクト発表（1983年9月）より後の1985年3月に文書として発表
- **記事での表現**: 「1985年3月、Dr. Dobb's Journalに掲載されたGNU宣言」

## 3. Free Software Foundation設立（1985年10月4日）

- **結論**: FSFは1985年10月4日にRichard Stallmanによって設立された。501(c)(3)非営利団体。ボストンに本拠地。
- **一次ソース**: FSF History; Wikipedia "Free Software Foundation"
- **URL**: <https://www.fsf.org/history/>
- **注意事項**: FSF設立はGNU宣言発表（1985年3月）の約7か月後
- **記事での表現**: 「1985年10月4日、StallmanはFree Software Foundation（FSF）を設立した」

## 4. Stallmanのプリンタ事件（Xerox 9700）

- **結論**: 1980年、MIT AI LabにXerox 9700レーザープリンタが設置された。Stallmanらハッカーはソースコードへのアクセスを拒否された。以前のプリンタ（XGP）ではStallmanがソフトウェアを改造し、ジャム通知機能等を追加していた。新プリンタはプリコンパイル済みバイナリのみ提供。
- **一次ソース**: Sam Williams, "Free as in Freedom", Chapter 1; Wikipedia "Richard Stallman"
- **URL**: <https://www.oreilly.com/openbook/freedom/ch01.html>
- **注意事項**: この事件がフリーソフトウェア運動の直接的な動機とされるが、複合的な要因があった
- **記事での表現**: 「1980年、MIT AI LabにXerox 9700レーザープリンタが導入された。Stallmanらはソースコードへのアクセスを拒否された」

## 5. StallmanのMIT退職（1984年1月/2月）

- **結論**: 1984年1月（一部ソースでは2月）にStallmanはMIT AI Labを退職し、GNUプロジェクトに専念。退職理由は、MITに在籍したままだとMITが成果物に権利を主張し、配布条件を制限する可能性があったため。
- **一次ソース**: GNU Project, "About the GNU Project"; Wikipedia "Richard Stallman"
- **URL**: <https://www.gnu.org/gnu/thegnuproject.html>
- **注意事項**: 退職後もMIT AI Labのオフィスは使用し続けた
- **記事での表現**: 「1984年初頭、StallmanはMITを退職した。MITが成果物に権利を主張する可能性を排除するためだった」

## 6. GNUプロジェクトの主要成果物とタイムライン

- **結論**:
  - GNU Emacs: 1984年開発開始、1985年3月20日にバージョン13（最初の公開版）リリース
  - GCC (GNU C Compiler): 1987年3月22日リリース、MITのFTPサイトから配布。同年12月にC++対応
  - GDB: GNU Debugger（開発初期からのコンポーネント）
  - GNU coreutils: ls, grep, awk, make等のUNIXユーティリティ群
  - Bash: 1989年6月8日、Brian Foxがベータ版（v.99）をリリース
- **一次ソース**: GNU Project, Wikipedia各項目
- **URL**: <https://en.wikipedia.org/wiki/GNU_Project>, <https://en.wikipedia.org/wiki/GNU_Compiler_Collection>, <https://en.wikipedia.org/wiki/Bash_(Unix_shell)>
- **注意事項**: 1990年までに、Emacs、GCC、ほとんどのコアライブラリとユーティリティが揃ったが、カーネル（Hurd）が未完成だった
- **記事での表現**: 年表形式で各コンポーネントのリリース日を正確に記述

## 7. GPL（GNU General Public License）の歴史

- **結論**:
  - Emacs General Public License: 1985年、最初のコピーレフトライセンス
  - GPL v1: 1989年2月25日リリース
  - GPL v2: 1991年6月リリース
  - GPL v3: 2007年6月29日リリース
- **一次ソース**: GNU公式サイト、Wikipedia "GNU General Public License"
- **URL**: <https://www.gnu.org/licenses/old-licenses/gpl-1.0.en.html>, <https://en.wikipedia.org/wiki/GNU_General_Public_License>
- **注意事項**: Emacs GPLからGPL v1への一般化に約4年かかった
- **記事での表現**: 「1985年のEmacs General Public Licenseが最初のコピーレフトライセンスであり、1989年にGPL v1として汎用化された」

## 8. コピーレフトの概念と用語の起源

- **結論**: コピーレフトの概念はStallmanが1985年のGNU宣言で記述。「copyleft」という用語はDon Hopkinsが1984年か1985年にStallmanに送った手紙に由来（Stallman本人の証言）。
- **一次ソース**: Wikipedia "Copyleft"; Stallman biographies
- **URL**: <https://en.wikipedia.org/wiki/Copyleft>
- **注意事項**: 概念自体はStallman、用語はDon Hopkins由来
- **記事での表現**: 「『copyleft』という言葉はDon HopkinsがStallmanに送った手紙に由来する。copyrightの意図的な逆転だ」

## 9. GPLv2とGPLv3の主要な差異

- **結論**: GPLv3（2007年6月29日）の主要な追加点：(1) Tivoization禁止——TiVoがGPLソフトウェアを使用しつつハードウェアで改変版の実行をブロックした慣行への対抗、(2) ソフトウェア特許への明示的対応、(3) DRM制限の禁止。LinuxカーネルはGPLv2のみ（"or later" 条項なし）でライセンスされており、GPLv3には移行していない。
- **一次ソース**: GNU Project, "Why Upgrade to GPLv3"; Wikipedia
- **URL**: <https://www.gnu.org/licenses/rms-why-gplv3.en.html>
- **注意事項**: Linus TorvaldsはGPLv3に反対の立場
- **記事での表現**: 「GPLv3はTivoization——ハードウェアによるソフトウェア改変の制限——を明示的に禁止した」

## 10. Eric Raymond「The Cathedral and the Bazaar」とOSI設立

- **結論**:
  - 1997年5月27日、ドイツ・ヴュルツブルクのLinux Kongressで初発表
  - 1999年に書籍として出版
  - 1998年1月、Netscapeがソースコード公開を発表
  - 1998年2月3日、パロアルトの戦略会議で「open source」の用語が生まれた
  - OSI（Open Source Initiative）: 1998年2月下旬、Eric RaymondとBruce Perensが共同設立。Raymond初代会長、Perens副会長
  - Open Source Definitionは Debian Free Software Guidelines（DFSG）から派生
- **一次ソース**: OSI History; Wikipedia
- **URL**: <https://opensource.org/about/history-of-the-open-source-initiative>, <https://en.wikipedia.org/wiki/The_Cathedral_and_the_Bazaar>
- **注意事項**: 「open source」はNetscapeのソースコード公開がきっかけ
- **記事での表現**: 正確な日付と経緯を時系列で記述

## 11. GNU Hurdの歴史と現状

- **結論**: 1990年に開発開始（1986年に別のカーネル試作が頓挫した後）。CMUのMachマイクロカーネル上に構築。1987年にStallmanがMachの使用を提案、CMUのライセンス条件の不確実性で3年遅延。Linuxカーネルの登場（1991年）後、開発は減速。2026年現在も「プロダクション品質ではない」状態。
- **一次ソース**: GNU Hurd公式サイト; Wikipedia "GNU Hurd"
- **URL**: <https://www.gnu.org/software/hurd/hurd.html>, <https://en.wikipedia.org/wiki/GNU_Hurd>
- **注意事項**: Hurdの遅延がLinuxカーネル採用の最大の要因
- **記事での表現**: 「GNUはカーネル以外のすべてを揃えた。だがHurdは完成しなかった」

## 12. 「Free Software」の四つの自由と「GNU/Linux」論争

- **結論**:
  - 四つの自由: Freedom 0（実行の自由）、Freedom 1（研究と改変の自由）、Freedom 2（再配布の自由）、Freedom 3（改良版の配布の自由）。番号が0から始まるのはプログラミング慣習のパロディかつ、Freedom 0が後から追加されたため
  - GNU/Linux論争: Stallmanは1994年頃からGNU/Linux表記を求め始め、1996年にEmacs 19.31で「lignux」を使用、後に「GNU/Linux」に変更。Debian等がGNU/Linuxを使用するが、多数派は「Linux」のみ
- **一次ソース**: FSF "What is Free Software?"; Wikipedia "GNU/Linux naming controversy"
- **URL**: <https://www.gnu.org/philosophy/free-sw.en.html>, <https://en.wikipedia.org/wiki/GNU/Linux_naming_controversy>
- **注意事項**: 「free」は「無料」ではなく「自由」の意。"Free as in freedom, not as in free beer"
- **記事での表現**: 四つの自由を正確に列挙し、「free」の二義性を解説

## 13. BusyBoxとGNU coreutilsの比較

- **結論**: BusyBoxは1995年にBruce Perensが作成、1996年に初期目的を達成。1999年にErik Andersenがメンテナに就任（2006年まで）。300以上のコマンドを単一バイナリに統合。「The Swiss Army Knife of Embedded Linux」。GNU coreutilsのミニマリスト代替実装。
- **一次ソース**: Wikipedia "BusyBox"; BusyBox公式サイト
- **URL**: <https://en.wikipedia.org/wiki/BusyBox>
- **注意事項**: BusyBoxはGPLv2でライセンスされている
- **記事での表現**: 「BusyBoxはGNU coreutilsの軽量代替として、組込みLinux市場で標準的な存在となった」
