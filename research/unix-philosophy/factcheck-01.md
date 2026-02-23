# ファクトチェック記録：第1回「2026年にUNIXを語る理由」

調査日：2026-02-23

---

## 1. Top500スーパーコンピュータにおけるLinuxのシェア

- **結論**: 2017年11月以降、Top500の100%がLinuxで稼働。2025年時点でも100%を維持
- **一次ソース**: TOP500 Project, Operating system Family statistics
- **URL**: <https://www.top500.org/statistics/details/osfam/1/>
- **注意事項**: 2017年11月のリスト以降、非Linux OSは消滅。El Capitan（1.742 EFLOPS）、Frontier（1.353 EFLOPS）、Aurora（1.012 EFLOPS）がトップ3
- **記事での表現**: 「Top500スーパーコンピュータの100%がLinuxで稼働している」

## 2. UNIXの誕生（1969年、Bell Labs、PDP-7）

- **結論**: 1969年夏、Bell LabsのKen ThompsonとDennis Ritchieが、DEC PDP-7上でUNIXの開発を開始。Multics撤退後の個人的プロジェクトとして始まった
- **一次ソース**: Dennis Ritchie, Ken Thompson, "The UNIX Time-Sharing System", Communications of the ACM, 1974; Computer History Museum, "The Earliest Unix Code: An Anniversary Source Code Release"
- **URL**: <https://computerhistory.org/blog/the-earliest-unix-code-an-anniversary-source-code-release/>
- **注意事項**: Thompson、Ritchie、McIlroy、OssannaらがMulticsプロジェクトから撤退した後のプロジェクト。Thompsonは1ヶ月でPDP-7用の最初のバージョンを作成
- **記事での表現**: 「1969年夏、Bell LabsのKen ThompsonとDennis Ritchieは、DEC PDP-7の前でUNIXの開発を始めた」

## 3. PDP-7のスペック

- **結論**: 18ビットワードのミニコンピュータ。標準メモリ4Kワード（9KB）、最大64Kワード（144KB）。メモリサイクルタイム1.75μs。1964年発表、1965年出荷。価格$72,000
- **一次ソース**: DEC PDP-7 documentation; Wikipedia PDP-7
- **URL**: <https://en.wikipedia.org/wiki/PDP-7>
- **注意事項**: ブループリントでは「18ビットワード、メモリ9Kワード」とあるが、標準構成は4Kワード（9KB ≒ 9Kバイト）。9Kワードではなく9KBが正確。ただしBell Labsの個体がどの構成だったかの一次ソースは未確認
- **記事での表現**: 「PDP-7——18ビットワード、標準メモリ4Kワード（約9KB）のミニコンピュータ」

## 4. macOSのUNIX 03認証

- **結論**: Mac OS X 10.5 Leopard（2007年10月26日）で初めてUNIX 03認証を取得。以降、macOS 15.0（Sequoia）までほぼ全バージョンで認証継続。The Open Groupが「UNIX」商標を管理
- **一次ソース**: The Open Group, Register of UNIX Certified Products
- **URL**: <https://www.opengroup.org/openbrand/register/>
- **注意事項**: OS X Lionは認証未取得。macOS 11 Big Sur以降はIntel（x86-64）とApple Silicon（ARM64）の両方で認証。認証の実質的な意味については議論がある
- **記事での表現**: 「macOSは2007年のLeopard以降、The Open GroupによるUNIX 03認証を取得し続けている」

## 5. AndroidとLinuxカーネル

- **結論**: AndroidはLinuxカーネルベースのOS。2025年時点でモバイルOS市場シェア約72%。世界で最も使われているOSはAndroid（全デバイス合計で約39%）
- **一次ソース**: StatCounter Global Stats; Wikipedia, Usage share of operating systems
- **URL**: <https://gs.statcounter.com/os-market-share/mobile/worldwide>
- **注意事項**: 2025年にHuaweiがHarmonyOS NEXTを導入し、Linuxカーネルから離脱した点も留意。ただしシェアは小さい
- **記事での表現**: 「モバイルOSのAndroidはLinuxカーネルで動作し、世界のスマートフォンの約72%を占める」

## 6. Linuxのサーバ市場シェア

- **結論**: サーバOS市場でLinuxのシェアは約44%（2025年）。Webサーバでは約59%。クラウドワークロードでは約49%
- **一次ソース**: Various industry reports (Statista, W3Techs)
- **URL**: <https://commandlinux.com/statistics/linux-server-market-share/>
- **注意事項**: 統計によってシェアの数値は異なる。「過半数」とは断言できないが、最大シェアであることは間違いない。ただしサーバOS全体ではWindowsも相当のシェアを持つ
- **記事での表現**: 「サーバOSにおいてLinuxは最大のシェアを持ち、Webサーバの約6割、クラウドワークロードの約半数で使われている」

## 7. Doug McIlroyのUNIX哲学

- **結論**: Doug McIlroyが1978年にBell System Technical Journalで文書化。3原則: (1) Write programs that do one thing and do it well, (2) Write programs to work together, (3) Write programs to handle text streams, because that is a universal interface。Peter H. Salusが1994年の『A Quarter Century of UNIX』でこれを引用・整理
- **一次ソース**: Doug McIlroy, Bell System Technical Journal, 1978; Peter H. Salus, A Quarter Century of UNIX, 1994
- **URL**: <https://en.wikipedia.org/wiki/Unix_philosophy>
- **注意事項**: McIlroyはパイプの発明者であり、Bell Labsの Computing Techniques Research Department を1965年から1986年まで率いた
- **記事での表現**: 「McIlroyは1978年、UNIX哲学を三つの原則として明文化した」

## 8. Ken Thompson・Dennis Ritchieのチューリング賞（1983年）

- **結論**: 1983年にACMチューリング賞を共同受賞。受賞理由: "for their development of generic operating systems theory and specifically for the implementation of the UNIX operating system"
- **一次ソース**: ACM A.M. Turing Award
- **URL**: <https://amturing.acm.org/award_winners/thompson_4588371.cfm>
- **注意事項**: Thompsonの受賞講演 "Reflections on Trusting Trust" はコンピュータセキュリティの古典となった
- **記事での表現**: 「1983年、ThompsonとRitchieはUNIXの開発でACMチューリング賞を共同受賞した」

## 9. C言語によるUNIX書き直し（1973年）

- **結論**: 1973年、Version 4 UNIXがC言語で書き直された。OSを高級言語で記述するという当時の常識を覆す決断だった。同年、Symposium on Operating Systems Principlesで初の公式発表
- **一次ソース**: Dennis Ritchie, Wikipedia; "The UNIX Time-Sharing System" paper, 1974
- **URL**: <https://en.wikipedia.org/wiki/Dennis_Ritchie>
- **注意事項**: B言語（Thompson, 1970年）→ C言語（Ritchie, 1972年頃完成）→ Version 4 UNIXのC書き直し（1973年）という流れ。ただしV4にはまだPDP-11固有コードが多く残っていた
- **記事での表現**: 「1973年、RitchieはUNIXをC言語で書き直した。OSを高級言語で記述するという前例のない試みだった」

## 10. Eric Raymondの『The Art of UNIX Programming』（2003年）の17ルール

- **結論**: Eric S. Raymondが2003年に出版。UNIX設計の17のルールを体系化（Rule of Modularity, Clarity, Composition, Separation, Simplicity, Parsimony, Transparency, Robustness, Representation, Least Surprise, Silence, Repair, Economy, Generation, Optimization, Diversity, Extensibility）
- **一次ソース**: Eric S. Raymond, The Art of UNIX Programming, Addison-Wesley, 2003
- **URL**: <http://www.catb.org/esr/writings/taoup/html/>
- **注意事項**: オンラインで全文公開されている
- **記事での表現**: 「Raymondは2003年、UNIX設計の原則を17のルールとして体系化した」
