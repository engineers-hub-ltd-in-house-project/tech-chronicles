# ファクトチェック記録：第18回「Plan 9――UNIXの先を夢見た実験」

## 1. Plan 9の開発開始と初公開

- **結論**: Plan 9はBell LabsのComputing Science Research Centerで1980年代半ばに開発が開始され、1992年に大学向けに初版（First Edition）がリリースされた。
- **一次ソース**: Plan 9 from Bell Labs公式サイト, "About"ページ; Wikipedia "Plan 9 from Bell Labs"
- **URL**: <https://9p.io/plan9/about.html>, <https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs>
- **注意事項**: 「1992年」は大学向け配布の年。一般公開（Second Edition）は1995年。
- **記事での表現**: 「Plan 9は1980年代半ばからBell Labsで開発が始まり、1992年に大学向けにFirst Editionがリリースされた」

## 2. Plan 9の設計者

- **結論**: 主要設計者はKen Thompson、Rob Pike、Dave Presotto、Phil Winterbottom。Dennis Ritchieは当時Computing Techniques Research Departmentの長としてサポート。その他Brian Kernighan、Tom Duff、Doug McIlroy、Bjarne Stroustrup、Bruce Ellisらも貢献。
- **一次ソース**: Rob Pike et al., "Plan 9 from Bell Labs", Computing Systems, 1995; Plan 9 Foundation公式サイト
- **URL**: <https://www.usenix.org/legacy/publications/compsystems/1995/sum_pike.pdf>, <https://www.plan9foundation.org/about.html>
- **注意事項**: UNIXを作ったグループと同じメンバーが中心。
- **記事での表現**: 「Plan 9の設計を率いたのはRob Pike、Ken Thompson、Dave Presotto、Phil Winterbottom——UNIXとC言語を生んだのと同じBell Labsの研究グループだった」

## 3. Plan 9の名前の由来

- **結論**: Ed Wood監督の1957年のSF映画「Plan 9 from Outer Space」（公開1957-1959年）に由来。「史上最低の映画」として知られる作品。
- **一次ソース**: Wikipedia "Plan 9 from Outer Space"; Plan 9 from Bell Labs Wikipedia記事
- **URL**: <https://en.wikipedia.org/wiki/Plan_9_from_Outer_Space>, <https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs>
- **注意事項**: 映画の制作年は1957年、劇場公開は1958-1959年。
- **記事での表現**: 「Plan 9という名前は、Ed Woodの1957年のSF映画『Plan 9 from Outer Space』——『史上最低の映画』として知られる作品——に由来する」

## 4. Plan 9のエディション（版）のリリース時系列

- **結論**: First Edition（1992年、大学向け）、Second Edition（1995年、一般公開、$350）、Third Edition（2000年、Plan 9 License）、Fourth Edition（2002年4月、Lucent Public License 1.02）。
- **一次ソース**: Wikipedia "Plan 9 from Bell Labs"; Plan 9 Foundation公式サイト
- **URL**: <https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs>, <https://p9f.org/about.html>
- **注意事項**: 2014年にUCバークレー経由でGPL-2.0へ。2021年3月23日にPlan 9 FoundationへIP移転しMITライセンスへ。
- **記事での表現**: 「First Edition（1992年、大学向け配布）からFourth Edition（2002年4月、Lucent Public License 1.02でオープンソース化）まで、4つの版が公開された」

## 5. 9Pプロトコルの設計

- **結論**: 9P（Plan 9 Filesystem Protocol、別名Styx）はPlan 9の全リソースアクセスを統一するネットワークプロトコル。すべてのリソースをファイルサーバとして公開し、ファイル操作（open, read, write, close等）のメッセージで操作する。
- **一次ソース**: Wikipedia "9P (protocol)"; Rob Pike et al., "Plan 9 from Bell Labs", 1995
- **URL**: <https://en.wikipedia.org/wiki/9P_(protocol)>, <https://css.csail.mit.edu/6.824/2014/papers/plan9.pdf>
- **注意事項**: 9P2000は2002年のプロトコル改訂版。Linux上では9p2000.Lとして実装。
- **記事での表現**: 「9P（別名Styx）は、Plan 9のすべてのリソースをファイル操作のメッセージで扱うネットワークプロトコルである」

## 6. per-process名前空間

- **結論**: Plan 9では各プロセスが独自のファイルシステム名前空間を持つ。マウント操作は呼び出したプロセスツリー内にのみ影響し、グローバルな状態を変更しない。特権も不要。
- **一次ソース**: Rob Pike et al., "The Use of Name Spaces in Plan 9", ACM SIGOPS European Workshop, 1992
- **URL**: <https://9p.io/sys/doc/names.html>, <https://dl.acm.org/doi/10.1145/506378.506413>
- **注意事項**: この概念がLinuxのnamespaces（mount namespace等）の着想源となった。
- **記事での表現**: 「Plan 9では各プロセスが独自のファイルシステム名前空間を構築でき、マウント操作はそのプロセスツリー内にのみ影響する」

## 7. ユニオンマウント

- **結論**: Plan 9のbindとmountはユニオンディレクトリをサポート。複数のディレクトリを一つのマウントポイントに重ね合わせ、先頭または末尾に追加、あるいは置換が可能。ルックアップ時は先頭から順に検索。
- **一次ソース**: Plan 9公式ドキュメント "The Use of Name Spaces in Plan 9"
- **URL**: <https://9p.io/sys/doc/names.html>
- **注意事項**: Linuxのoverlayfsやunionfsの概念的先祖。
- **記事での表現**: 「Plan 9のユニオンマウントは、複数のディレクトリを一つのマウントポイントに重ね合わせる機能である」

## 8. UTF-8の発明

- **結論**: UTF-8は1992年9月にRob PikeとKen Thompsonが設計。ニュージャージーのダイナーのプレースマット（紙ナプキン/ランチョンマット）上で設計された。1992年9月8日火曜日午前3:22にKen ThompsonがPlan 9のUTF-8移行完了のメールを送信。Plan 9は完全なUTF-8サポートを持つ最初のOSだった。
- **一次ソース**: Rob Pike, "UTF-8 history" (email, 2003); Ken Thompson & Rob Pike, "Hello World or Kαληµε´ρα κο´σµε", 1992
- **URL**: <https://doc.cat-v.org/bell_labs/utf-8_history>, <https://www.cl.cam.ac.uk/~mgk25/ucs/UTF-8-Plan9-paper.pdf>
- **注意事項**: X/Open委員のリクエストがきっかけ。ISO 10646の元のUTFに不満があった。2026年現在、Webページの約99%がUTF-8で送信されている。
- **記事での表現**: 「UTF-8は1992年9月、Rob PikeとKen Thompsonがニュージャージーのダイナーで設計した。Plan 9はUTF-8を完全にサポートした最初のOSとなった」

## 9. rforkとLinuxのclone/unshare/namespaceの関係

- **結論**: Plan 9のrfork()はプロセス作成時に名前空間、メモリ、ファイルディスクリプタ等の共有/コピーをビットベクタで制御する。Linuxのnamespaces機能はPlan 9の名前空間設計に直接着想を得た（Linux namespaces Wikipediaで明記）。Linuxのclone()はrforkに類似するシステムコール。unshare()は既存プロセスの名前空間を分離する。
- **一次ソース**: Wikipedia "Linux namespaces"; Linux man pages "namespaces(7)"
- **URL**: <https://en.wikipedia.org/wiki/Linux_namespaces>, <https://man7.org/linux/man-pages/man7/namespaces.7.html>
- **注意事項**: mount namespace（2002年、Linux 2.4.19）が最初のLinux namespace実装。
- **記事での表現**: 「Linuxのnamespace機能はPlan 9のper-process名前空間に直接着想を得たものである」

## 10. Plan 9のLinuxへの影響：FUSE、/proc、v9fs

- **結論**: (1) LinuxのFUSE（Filesystem in Userspace）はPlan 9のユーザ空間ファイルシステムの概念に影響を受けた。(2) Linuxの/procファイルシステムはPlan 9の/procに明示的に着想を得ている（4.4BSDもPlan 9から/procをクローン）。(3) Linux v9fsはPlan 9の9Pプロトコル実装であり、LinuxカーネルにCONFIG_9P_FSとして含まれる。KVM/virtioでのファイル共有等に使用。
- **一次ソース**: Linux Kernel Documentation "v9fs"; Wikipedia "Filesystem in Userspace"; Wikipedia "procfs"
- **URL**: <https://www.kernel.org/doc/html/latest/filesystems/9p.html>, <https://en.wikipedia.org/wiki/Filesystem_in_Userspace>, <https://en.wikipedia.org/wiki/Procfs>
- **注意事項**: FUSEの直接の祖先はAVFS（GNU Hurdのtranslatorコンセプトの影響も）だが、Plan 9の「ユーザ空間でファイルシステムを実装する」思想の影響は広く認められている。
- **記事での表現**: 「LinuxのFUSE、/proc、v9fsはいずれもPlan 9のアイデアの直接的または間接的な影響を受けている」

## 11. Plan 9が普及しなかった理由

- **結論**: (1) UNIXが「十分に良い」存在として定着しており、乗り換えの動機が弱かった（Eric Raymond "The Art of UNIX Programming"で指摘）。(2) 商用サポートの不在（AT&T/Lucentは積極的にマーケティングせず）。(3) アプリケーションとデバイスドライバの不足。(4) 既存UNIXとの互換性の断絶。(5) ライセンスの混乱（初期は制限的）。
- **一次ソース**: Eric S. Raymond, "The Art of UNIX Programming" (Chapter "Plan 9: The Way the Future Was"), 2003; Hacker News/Quora上の議論
- **URL**: <https://www.catb.org/esr/writings/taoup/html/plan9.html>
- **注意事項**: Raymondは「最も危険な敵は、十分に良い既存のコードベースである」と表現。
- **記事での表現**: 「Plan 9の最大の敵は、'十分に良い'UNIXだった」

## 12. 9frontとPlan 9の現在

- **結論**: 9frontはPlan 9の最もアクティブなフォーク。ドライバの追加、x86-64ネイティブ対応、Wi-Fi/USB/オーディオサポート等を改善。独特のコミュニティ文化（ジョークやミームに満ちたドキュメント）を持つ。2021年3月23日にPlan 9のIPがPlan 9 Foundationに移転しMITライセンス化。
- **一次ソース**: The Register, "New version of Plan 9 fork 9front released", 2022; Phoronix, "Plan 9 Copyright Transferred To Foundation", 2021
- **URL**: <https://www.theregister.com/2022/11/02/plan_9_fork_9front/>, <https://www.phoronix.com/news/Plan-9-2021>
- **注意事項**: Plan 9 from User Space（plan9port/p9p）はRuss Coxが作成したUnix/Linux/macOS向けのPlan 9ツールのポート。Rob Pike自身がacmeエディタを日常使用。
- **記事での表現**: 「2021年にPlan 9の知的財産はPlan 9 Foundationに移転し、MITライセンスで再公開された。9frontフォークが最もアクティブな開発を続けている」

## 13. Infernoオペレーティングシステム

- **結論**: InfernoはPlan 9のアイデアをより広いデバイスとネットワークに展開するため1995年にBell Labsで開発された。Styx（9Pの変種）プロトコル、Limboプログラミング言語、Disバーチャルマシンを特徴とする。Vita Nuova Holdingsに移管され、最終的に2021年にMITライセンスで公開。
- **一次ソース**: Wikipedia "Inferno (operating system)"; Vita Nuova公式サイト
- **URL**: <https://en.wikipedia.org/wiki/Inferno_(operating_system)>, <https://www.vitanuova.com/inferno/>
- **注意事項**: InfernoはPlan 9の商業化の試みとも言える。Disバーチャルマシンはアーキテクチャ非依存のバイトコードを実行。
- **記事での表現**: 「Plan 9のアイデアはInferno OS（1995年、Bell Labs）にも引き継がれた」
