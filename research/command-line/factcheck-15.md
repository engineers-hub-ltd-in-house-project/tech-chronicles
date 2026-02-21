# ファクトチェック記録：第15回「Plan 9の夢――UNIXの先にあったもの」

## 1. Plan 9 from Bell Labsの開発経緯と主要メンバー

- **結論**: Plan 9は1980年代後半からBell LabsのComputing Science Research Centerで開発が始まった。主要メンバーはRob Pike、Ken Thompson、Dave Presotto、Phil Winterbottom。Dennis Ritchieが研究部門長として支援した。第1版は1992年に大学向けにリリースされた。
- **一次ソース**: Plan 9 from Bell Labs公式サイト, Wikipedia
- **URL**: <https://9p.io/plan9/about.html>, <https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs>
- **注意事項**: 開発開始時期は「late 1980s」と記述されるのが通常。正確な開始年は明記されていない。
- **記事での表現**: 「1980年代後半、Bell LabsのComputing Science Research Centerで開発が始まった」

## 2. Plan 9のエディションと公開日

- **結論**: 第1版（1992年、大学向け）、第2版（1995年、書籍+CD形式）、第3版（2000年6月、インターネットで無料公開）、第4版（2002年4月、Lucent Public License 1.02）。
- **一次ソース**: Wikipedia, Plan 9 Foundation, GitHub plan9foundation/plan9
- **URL**: <https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs>, <https://github.com/plan9foundation/plan9>
- **注意事項**: 第1版はアカデミア限定で煩雑な手続きが必要だった。これが普及を阻害した要因の一つ。
- **記事での表現**: 各エディションの年号と配布形態を正確に記述

## 3. UTF-8の発明（1992年、Rob Pike & Ken Thompson）

- **結論**: 1992年9月2日、New Jerseyのダイナーでの食事中にRob PikeとKen Thompsonがテーブルマット（placemat）にUTF-8の設計を書いた。背景はX/OpenからのFSS/UTF設計への意見を求められたこと。9月8日（火曜日）午前3:22、Thompson がPlan 9でのUTF-8実装を完了した旨のメールを送信。1993年1月25-29日のUSENIXカンファレンス（サンディエゴ）で正式発表。
- **一次ソース**: Rob Pike, "The history of UTF-8 as told by Rob Pike"
- **URL**: <https://doc.cat-v.org/bell_labs/utf-8_history>, <https://www.cl.cam.ac.uk/~mgk25/ucs/utf-8-history.txt>
- **注意事項**: 「ダイナーのテーブルマットに書いた」というエピソードはRob Pike自身の証言。X/OpenがFSS/UTF仕様をPikeとThompsonに相談したことが直接の契機。
- **記事での表現**: ダイナーのプレイスマットに設計を書いたエピソードを含め、日付を正確に記述

## 4. 9Pプロトコルの設計

- **結論**: 9P（後に9P2000に改訂）はPlan 9の分散OS基盤となるネットワークプロトコル。ファイルシステムインターフェースを通じてすべてのリソースへのアクセスを提供。NFSやRFSと異なり、バイトレベルでのファイルアクセスを行う。walk, clone, open, read, writeなどの操作がある。第4版で9P2000に改訂された。
- **一次ソース**: Wikipedia "9P (protocol)", Plan 9 documentation
- **URL**: <https://en.wikipedia.org/wiki/9P_(protocol)>, <https://9p.io/sys/doc/9.html>
- **注意事項**: 9PはStyx（Inferno OS向けの名称）とも呼ばれる。
- **記事での表現**: ファイルシステムインターフェースとしての9Pの設計思想と具体的な操作を説明

## 5. per-process namespaces

- **結論**: Plan 9ではプロセスごとにファイルシステムの名前空間を持つ。同じパス名が異なるプロセスで異なるリソースを指すことができる。各プロセスがmount/bindを行っても他のプロセスには影響しない。
- **一次ソース**: "The Use of Name Spaces in Plan 9" (Rob Pike他), Wikipedia
- **URL**: <https://9p.io/sys/doc/names.html>, <https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs>
- **注意事項**: Linuxのnamespacesはこの概念に影響を受けているが、Plan 9ほど徹底していない。
- **記事での表現**: 「プロセスごとに独立したファイルシステムの名前空間を持つ」

## 6. /procファイルシステム（Plan 9版）

- **結論**: Plan 9の/procはプロセス管理のための専用システムコールを持たず、ファイルシステムを通じてプロセスを制御する。各プロセスは/proc/{pid}/配下にmem, ctl, status, noteなどのファイルを持つ。ctlファイルに"stop"や"kill"というテキストを書き込んでプロセスを制御する。LinuxとBSDの/procはPlan 9から影響を受けた。
- **一次ソース**: Plan 9 documentation, Wikipedia "procfs"
- **URL**: <https://en.wikipedia.org/wiki/Procfs>, <https://9p.io/sys/doc/9.html>
- **注意事項**: Linux/procはPlan 9的だがPlan 9のように一貫していない。テキスト制御インターフェースはPlan 9の特徴。
- **記事での表現**: ctlファイルへのテキスト書き込みによるプロセス制御の仕組みを説明

## 7. /netファイルシステム（ネットワーク）

- **結論**: Plan 9にはネットワーク用の専用システムコールやioctlが存在しない。代わりに/netファイルシステムを使う。/net/tcp/clone を読み書きして接続を確立し、/net/tcp/{n}/dataで通信する。/net/csがコネクションサーバ。
- **一次ソース**: Plan 9 documentation, MIT lecture notes
- **URL**: <https://pdos.csail.mit.edu/6.828/2006/lec/l-plan9.html>
- **注意事項**: UNIXのBerkeley socket APIとは根本的に異なるアプローチ。
- **記事での表現**: ネットワーク接続の具体的なファイル操作手順を示す

## 8. rcシェル（Tom Duff）

- **結論**: rcはTom DuffがBell LabsでPlan 9用に1980年代後半に設計・実装した。Bourne shellの欠点を修正し、構文を簡素化した。主要な設計特徴：（1）マクロプロセッサではない（入力を複数回走査しない）、（2）変数は文字列ではなくリスト（配列）、（3）IFSによる予期しない分割がない。
- **一次ソース**: Tom Duff, "Rc — The Plan 9 Shell"
- **URL**: <https://doc.cat-v.org/plan_9/4th_edition/papers/rc>, <https://www.scs.stanford.edu/nyu/04fa/sched/readings/rc.pdf>
- **注意事項**: Unix向けの独立した再実装（Byron Rakitzis版）もある。
- **記事での表現**: Bourne shellの問題点（IFS、再走査）とrcの解決策を対比

## 9. Acmeエディタ

- **結論**: Rob Pikeが設計・実装。1993年に最初のリリース。テキストをユーザーインターフェースの核とする設計。マウスコーディングを多用する独特のUI。Oberon（Niklaus Wirth）の影響を受けている。論文"Acme: A User Interface for Programmers"は1994年に発表。plan9portの一部としてUnixにも移植されている。
- **一次ソース**: Wikipedia "Acme (text editor)", Russ Cox "A Tour of Acme"
- **URL**: <https://en.wikipedia.org/wiki/Acme_(text_editor)>, <https://research.swtch.com/acme>
- **注意事項**: AcmeはIDEでもテキストエディタでもなく「プログラマー向けのユーザーインターフェース」と位置づけられている。
- **記事での表現**: テキストベースの統合環境としてのAcmeの独自性を説明

## 10. Rio（ウィンドウシステム）

- **結論**: Plan 9のウィンドウシステム。Rob Pikeが設計。各ウィンドウがrcシェルのインスタンスを持つ。ウィンドウ自体も/dev/drawと/dev/consを通じてファイルとして操作される。「Everything is a file」の原則がウィンドウシステムにも適用されている。
- **一次ソース**: Wikipedia "Rio (windowing system)"
- **URL**: <https://en.wikipedia.org/wiki/Rio_(windowing_system)>
- **注意事項**: 初期のPlan 9ウィンドウシステムは8 1/2と呼ばれ、後にrioに置き換えられた。
- **記事での表現**: ウィンドウがファイルとして抽象化されている点を強調

## 11. Plan 9の商業的失敗の理由

- **結論**: 主な理由は（1）ライセンスの複雑さ（第1版は大学限定で手続きが煩雑）、（2）UNIXとの非互換性（既存プログラムが動かない）、（3）技術的に優れているが移行コストに見合うほどの差ではなかった、（4）ソフトウェアエコシステムの欠如、（5）AT&T/Lucentの商業的サポートの欠如。Eric S. Raymondは「Plan 9が失敗したのは、UNIXに対する十分な改善ではなかったから」と評した。
- **一次ソース**: Wikipedia, Eric S. Raymond "The Art of UNIX Programming", HN discussions
- **URL**: <https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs>, <https://www.catb.org/esr/writings/taoup/html/plan9.html>
- **注意事項**: 「失敗」は商業的な意味であり、思想的・技術的な影響は大きい。
- **記事での表現**: 技術的成功と商業的失敗の両面を公平に記述

## 12. Plan 9のライセンス変遷

- **結論**: 第1版（1992年、大学向け限定）→第3版（2000年、オープンソース公開）→第4版（2002年、Lucent Public License 1.02）→2014年GPL-2.0（UCバークレー経由で再ライセンス）→2021年3月23日、Plan 9 FoundationにコピーライトがBell Labsから移管され、MITライセンスで再リリース。
- **一次ソース**: Phoronix, Wikipedia, Plan 9 Foundation
- **URL**: <https://www.phoronix.com/news/Plan-9-2021>, <https://www.plan9foundation.org/about.html>
- **注意事項**: MITライセンスへの移行は2021年のことであり比較的最近。
- **記事での表現**: ライセンス変遷を時系列で記述

## 13. Plan 9の現代技術への影響

- **結論**: （1）UTF-8：現在のWeb・OSの標準エンコーディング、（2）/proc：LinuxとBSDが採用、（3）Linux namespaces：Plan 9のper-process namespacesに影響を受けた（2002年Linux 2.4.19から）、コンテナ技術（Docker）の基盤、（4）FUSE：Plan 9のユーザ空間ファイルシステム概念、（5）9P：WSL、QEMU VirtFSで使用、（6）Goルーチン：Plan 9の並行処理モデルの影響。
- **一次ソース**: Wikipedia, Linux Kernel documentation, Drew DeVault "In praise of Plan 9"
- **URL**: <https://en.wikipedia.org/wiki/Linux_namespaces>, <https://docs.kernel.org/filesystems/9p.html>, <https://drewdevault.com/2022/11/12/In-praise-of-Plan-9.html>
- **注意事項**: 直接的な移植ではなく、思想的影響と独立再実装の混在。
- **記事での表現**: 各影響を具体的な技術名と時期とともに記述

## 14. 9front（現代のフォーク）

- **結論**: 9frontはPlan 9の最もアクティブなフォーク。Bell Labsでの開発停滞を受けて開始された。より多くのハードウェアドライバ、x86-64ネイティブサポート、WiFi/USBサポート、Webブラウザ等を追加。月次更新で活発に開発されている。コミュニティはエキセントリックな文化で知られる。
- **一次ソース**: 9front公式サイト, The Register, XDA Developers
- **URL**: <https://9front.org/>, <https://www.theregister.com/2022/11/02/plan_9_fork_9front/>
- **注意事項**: 9frontコミュニティの文化は独特で、敷居が高い面もある。
- **記事での表現**: 現代でPlan 9を体験する主要な手段として紹介

## 15. Rob Pikeの「Systems Software Research is Irrelevant」

- **結論**: 2000年2月21日、Rob PikeがUtah 2000で発表した講演。システムソフトウェア研究が孤立し、硬直化し、無関係になりつつあるという悲観的な見解を述べた。
- **一次ソース**: Rob Pike, "Systems Software Research is Irrelevant" (utah2000)
- **URL**: <http://herpolhode.com/rob/utah2000.pdf>, <https://doc.cat-v.org/bell_labs/utah2000/>
- **注意事項**: この講演はPlan 9の普及の困難さを反映している。
- **記事での表現**: Plan 9の創造者自身による振り返りとして引用
