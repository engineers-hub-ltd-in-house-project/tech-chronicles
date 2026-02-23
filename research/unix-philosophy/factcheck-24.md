# ファクトチェック記録：第24回「UNIX――技術ではなく設計哲学として」

## 1. UNIXの誕生年と2026年時点での経過年数

- **結論**: UNIXの開発は1969年夏にBell LabsでKen Thompsonにより開始された。2026年現在で57年が経過している
- **一次ソース**: Wikipedia, "History of Unix"; IEEE Spectrum, "The Strange Birth and Long Life of Unix"
- **URL**: <https://en.wikipedia.org/wiki/History_of_Unix>
- **注意事項**: 「誕生」を1969年の開発開始とするか、1970年の公式命名とするかで1年のずれがある。本連載では開発開始の1969年を起点とする
- **記事での表現**: 「1969年、Ken ThompsonがPDP-7の前でUNIXの最初のコードを書いてから57年」

## 2. Doug McIlroyによるUNIX哲学の定式化（1978年）

- **結論**: Doug McIlroyは1978年のBell System Technical Journal（Vol. 57, No. 6, July-August 1978）の序文で、UNIX哲学の特徴的なスタイルを文書化した。共著者はE. N. PinsonとB. A. Tague
- **一次ソース**: M. D. McIlroy, E. N. Pinson, B. A. Tague, "UNIX Time-Sharing System: Foreword", Bell System Technical Journal, 57(6), 1978
- **URL**: <https://archive.org/details/bstj57-6-1899>
- **注意事項**: McIlroyの原文は4つの原則を含む。Peter Salusが1994年に3原則に要約したものとは異なる
- **記事での表現**: McIlroyが1978年に定式化した原則として原文に準拠して記述する

## 3. Peter Salusの3原則（1994年）

- **結論**: Peter H. Salusは1994年の著書『A Quarter Century of UNIX』で、McIlroyの哲学を3原則に要約した。(1) 一つのことをうまくやるプログラムを書け、(2) 協調して動くプログラムを書け、(3) テキストストリームを扱うプログラムを書け
- **一次ソース**: Peter H. Salus, "A Quarter Century of UNIX", Addison-Wesley, 1994
- **URL**: <https://www.amazon.com/Quarter-Century-UNIX-Peter-Salus/dp/0201547775>
- **注意事項**: SalusはMcIlroyの原文を要約したものであり、McIlroy自身の定式化とは微妙に異なる
- **記事での表現**: 「Peter Salusが1994年に3原則として蒸留した」

## 4. Mike Gancarzの9つの原則（1995年）

- **結論**: Mike Gancarzは1995年の著書『The UNIX Philosophy』で9つの原則を定式化した。(1) Small is beautiful、(2) Make each program do one thing well、(3) Build a prototype as soon as possible、(4) Choose portability over efficiency、(5) Store data in flat text files、(6) Use software leverage to your advantage、(7) Use shell scripts to increase leverage and portability、(8) Avoid captive user interfaces、(9) Make every program a filter
- **一次ソース**: Mike Gancarz, "The UNIX Philosophy", Digital Press, 1995
- **URL**: <https://www.amazon.com/UNIX-Philosophy-Mike-Gancarz/dp/1555581234>
- **注意事項**: 2003年に『Linux and the Unix Philosophy』として改訂版が出版されている
- **記事での表現**: 「Gancarzは1995年にUNIX哲学を9つの原則として体系化した」

## 5. Eric Raymondの17のルール（2003年）

- **結論**: Eric S. Raymondは2003年の著書『The Art of UNIX Programming』で17のルールを定式化した。Modularity, Clarity, Composition, Separation, Simplicity, Parsimony, Transparency, Robustness, Representation, Least Surprise, Silence, Repair, Economy, Generation, Optimization, Diversity, Extensibility
- **一次ソース**: Eric S. Raymond, "The Art of UNIX Programming", Addison-Wesley, 2003
- **URL**: <http://www.catb.org/esr/writings/taoup/html/>
- **注意事項**: 全文がオンラインで無料公開されている
- **記事での表現**: 「Raymondは2003年に17のルールとして展開した」

## 6. Ken Thompson、Rob PikeとGo言語

- **結論**: Go言語はKen Thompson、Rob Pike、Robert Griesemerによって2007年にGoogleで開発が開始され、2009年11月10日にオープンソースとして公開された。3人はすべての機能について全員の合意を必要とし、不要な複雑さを排除する設計方針を採った
- **一次ソース**: Wikipedia, "Go (programming language)"; go.dev公式サイト
- **URL**: <https://en.wikipedia.org/wiki/Ken_Thompson>
- **注意事項**: Thompson、PikeともにBell Labs出身でUNIX/Plan 9の開発者。Go言語にはUNIX哲学のシンプルさの思想が色濃く反映されている
- **記事での表現**: 「UNIXの創造者Ken Thompsonと、Plan 9の設計者Rob Pikeが、2007年にGoogleでGo言語の開発を始めた」

## 7. Rob Pikeの「Simplicity is Complicated」講演（2015年）

- **結論**: Rob Pikeは2015年11月9日のdotGo 2015カンファレンスで「Simplicity is Complicated」と題した講演を行い、Go言語の成功の鍵はシンプルさにあると述べた。「機能は複雑さを増し、可読性を損なう」「シンプルさとは複雑さを隠す技術である」
- **一次ソース**: Rob Pike, "Simplicity is Complicated", dotGo 2015
- **URL**: <https://go.dev/talks/2015/simplicity-is-complicated.slide>
- **注意事項**: 講演スライドはGo公式サイトで公開されている
- **記事での表現**: 「Pikeは2015年のdotGoで『Simplicity is Complicated』と題して講演し」

## 8. Dennis Ritchieの死去（2011年）とSteve Jobsとの比較

- **結論**: Dennis Ritchieは2011年10月12日に70歳で自宅（ニュージャージー州バークレーハイツ）で死去。Steve Jobsの死去（2011年10月5日）の1週間後であり、Jobsの報道に大きく覆い隠された。MITの教授は「Jobsは見えるものの王であり、Ritchieはほぼ見えないものの王だ」と評した
- **一次ソース**: Wikipedia, "Dennis Ritchie"; CNN, "Dennis Ritchie: The shoulders Steve Jobs stood on"
- **URL**: <https://en.wikipedia.org/wiki/Dennis_Ritchie>
- **注意事項**: Ritchieの正確な死亡日については、発見日が10月12日であり、実際の死亡日は不明とする説もある
- **記事での表現**: 「2011年10月12日、Dennis Ritchieが亡くなった。Steve Jobsの死の1週間後だった」

## 9. Top500スーパーコンピュータのLinux占有率

- **結論**: 2024年11月時点で、Top500スーパーコンピュータの100%がLinuxで稼働。2017年11月以降7年連続で100%を維持。上位3機はすべてエクサスケール：El Capitan（1.742 EFLOPS）、Frontier（1.353 EFLOPS）、Aurora（1.012 EFLOPS）
- **一次ソース**: TOP500.org, Operating system Family / Linux
- **URL**: <https://www.top500.org/statistics/details/osfam/1/>
- **注意事項**: 2017年11月のリストで初めて100%に到達
- **記事での表現**: 「Top500スーパーコンピュータの100%がLinuxで稼働している（2024年11月時点、7年連続）」

## 10. macOS Sequoia UNIX認証

- **結論**: macOS 15 Sequoia（Apple SiliconおよびIntel版）はThe Open GroupによるUNIX 03認証を取得。Appleの最初のUNIX認証はMac OS X 10.5 Leopard（2007年10月26日認証）
- **一次ソース**: The Open Group, "The Register of UNIX Certified Products"; The Register, "Apple macOS 15 Sequoia is officially UNIX"
- **URL**: <https://www.opengroup.org/openbrand/register/apple.htm>
- **注意事項**: UNIX 03仕様は2002年に策定されたもの。Linux自体はUNIX認証を取得していない（「UNIX-like」）
- **記事での表現**: 「macOS SequoiaはThe Open GroupによるUNIX 03認証を受けている」

## 11. AndroidとLinuxカーネル

- **結論**: 2025年時点でAndroidはグローバルモバイルOS市場の約72.77%を占め、約39億台のアクティブデバイスで稼働。AndroidはLinuxカーネル上に構築されている。全OS市場ではAndroid（38.94%）が世界最大のシェア
- **一次ソース**: StatCounter, "Mobile Operating System Market Share Worldwide"; Wikipedia, "Android (operating system)"
- **URL**: <https://gs.statcounter.com/os-market-share/mobile/worldwide>
- **注意事項**: AndroidはLinuxカーネルを使用しているが、GNU/Linuxとは異なるユーザランドを持つ
- **記事での表現**: 「Androidは39億台のデバイスで稼働し、そのすべてがLinuxカーネルの上に構築されている」

## 12. UNIX V4テープの発見（2025-2026年）

- **結論**: 2025年、ユタ大学メリル工学ビルの収納室から、1973年に作成されたUNIX Version 4の9トラック磁気テープが発見された。当時20本しか製造されず、完全なOSとして現存する唯一のコピーとされる。Computer History MuseumのAl Kossowがreadtapeプログラムを使用してデータを復元。Internet Archiveで公開され、SimHエミュレータで実行可能
- **一次ソース**: The Register, "UNIX V4 tape successfully recovered"; Salt Lake Tribune, 2026/01/07
- **URL**: <https://www.theregister.com/2025/12/23/unix_v4_tape_successfully_recovered/>
- **注意事項**: UNIX V4はカーネルとコアユーティリティがCで書き直された最初のバージョン
- **記事での表現**: 「2025年末、ユタ大学の収納室から1973年のUNIX V4テープが発見された」

## 13. C言語のTIOBEインデックスでの順位（2026年）

- **結論**: 2026年1月のTIOBEインデックスでCは第2位に上昇。Pythonが1位を維持。C#が2025年のLanguage of the Yearに選出。Rustは過去最高の13位
- **一次ソース**: TechRepublic, "TIOBE January 2026: C Rises, C# Wins 2025 Honor"
- **URL**: <https://www.techrepublic.com/article/news-tiobe-commentary-jan-2026/>
- **注意事項**: TIOBEインデックスは検索エンジンの結果に基づく指標であり、実際の使用率とは異なる場合がある
- **記事での表現**: 「2026年1月のTIOBEインデックスでCは第2位——1973年に誕生した言語が、半世紀を経てなお現役である」

## 14. eBPFとLinuxカーネルの進化

- **結論**: eBPF（extended Berkeley Packet Filter）はLinuxカーネル内でサンドボックス化されたプログラムを実行する技術。2024-2025年にかけて、オブザーバビリティ、セキュリティ、ネットワーキングの各分野で大幅に進展。カーネルソースコードの変更やカーネルモジュールのロードなしにカーネル機能を拡張可能
- **一次ソース**: ebpf.io, "What is eBPF?"; Linux Foundation, "The State of eBPF"
- **URL**: <https://ebpf.io/what-is-ebpf/>
- **注意事項**: eBPFのBPFは元々Berkeley Packet Filterに由来するが、現在の用途はパケットフィルタリングを大きく超えている。BSDの知的遺産がLinux上で発展している例
- **記事での表現**: 「eBPFは、Berkeleyの名を冠した技術がLinuxカーネルの中で新たな命を得た例だ」
