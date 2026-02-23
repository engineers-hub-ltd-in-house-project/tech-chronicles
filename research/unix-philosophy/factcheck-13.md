# ファクトチェック記録：第13回「Linux誕生——Linus Torvaldsの"just a hobby"」

## 1. Linus Torvaldsのcomp.os.minix投稿（1991年8月25日）

- **結論**: 1991年8月25日20:57:08 GMT、Linus Torvaldsはcomp.os.minixニュースグループに「What would you like to see most in minix?」という件名で投稿した。「I'm doing a (free) operating system (just a hobby, won't be big and professional like gnu) for 386(486) AT clones」が冒頭の文言
- **一次ソース**: Usenet投稿（comp.os.minix、1991年8月25日）、Google Groups等にアーカイブが残存
- **URL**: <https://en.wikipedia.org/wiki/History_of_Linux>
- **注意事項**: 投稿日は8月25日だが、Linux 0.01のコードがFTPサーバにアップロードされたのは9月17日。公式の「誕生日」は8月25日の投稿日とされることが多い
- **記事での表現**: 1991年8月25日、ヘルシンキ大学の21歳の学生がUsenetに投稿した事実として記述

## 2. Linus Torvaldsの経歴・生年

- **結論**: Linus Benedict Torvaldsは1969年12月28日、フィンランド・ヘルシンキ生まれ。スウェーデン語系フィンランド人。ヘルシンキ大学に1988年から1996年まで在籍し、コンピュータサイエンスの修士号を取得。11歳（1981年）でVIC-20でプログラミングを開始
- **一次ソース**: Wikipedia "Linus Torvalds"、Britannica
- **URL**: <https://en.wikipedia.org/wiki/Linus_Torvalds>
- **注意事項**: 1991年の投稿時は21歳。1989年にフィンランド海軍で兵役
- **記事での表現**: 「1969年生まれ、ヘルシンキ大学の学生」として記述。投稿時21歳

## 3. MINIX（Andrew Tanenbaum、1987年）

- **結論**: MINIXは1987年にAndrew S. Tanenbaumがアムステルダム自由大学（Vrije Universiteit）で作成した教育用UNIX互換OS。教科書『Operating Systems: Design and Implementation』（Prentice Hall、1987年）に付属。マイクロカーネルアーキテクチャ。3か月以内にcomp.os.minixニュースグループが立ち上がり、40,000人以上の購読者を集めた
- **一次ソース**: Wikipedia "Minix"、Tanenbaum "Operating Systems: Design and Implementation"
- **URL**: <https://en.wikipedia.org/wiki/Minix>
- **注意事項**: 初期のMINIXはプロプライエタリなソースアベイラブルライセンスで、2000年にBSD 3-Clauseに変更。Torvaldsの自伝『Just for Fun』で「the book that launched me to new heights」と記述
- **記事での表現**: Tanenbaumの教育用OS、マイクロカーネル設計、Torvaldsに直接影響を与えた

## 4. Linux 0.01のリリース（1991年9月17日）

- **結論**: 1991年9月17日、TorvaldsはLinux 0.01をFUNET（Finnish University and Research Network）のFTPサーバ ftp.funet.fi にアップロードした。10,239行のコード。この時点ではMINIXが必要（コンパイルと動作にMINIX環境を要した）。公式発表はされず
- **一次ソース**: Linux kernel version history (Wikipedia)、FUNETアーカイブ
- **URL**: <https://en.wikipedia.org/wiki/Linux_kernel_version_history>
- **注意事項**: 0.01は自己ホスティング不可。コンパイルにMINIXが必要だった
- **記事での表現**: FTPサーバへの静かなアップロードとして記述、10,239行

## 5. Linux 0.02の公式発表（1991年10月5日）

- **結論**: 1991年10月5日、Torvaldsはcomp.os.minixに最初の「公式」リリースとしてLinux 0.02を発表。bash/gcc/gnu-make/gnu-sed/compress等が動作すると報告
- **一次ソース**: Usenet投稿、Linux.com "Linus Torvalds' Linux 0.02 Release Post from 1991"
- **URL**: <https://www.linux.com/news/linus-torvalds-linux-002-release-post-1991/>
- **注意事項**: 0.02が実質的な最初の公開リリース
- **記事での表現**: 10月5日を「最初の公式リリース」として言及

## 6. Tanenbaum-Torvalds論争（1992年1月29日）

- **結論**: 1992年1月29日、TanenbaumがUsenet comp.os.minixに「LINUX is obsolete」という件名で投稿。モノリシックカーネルは「1970年代への巨大な後退」と批判。Torvaldsは翌日応答。Peter MacDonald、David S. Miller、Theodore Ts'oらも参加
- **一次ソース**: Wikipedia "Tanenbaum–Torvalds debate"、O'Reilly "Open Sources" Appendix A
- **URL**: <https://en.wikipedia.org/wiki/Tanenbaum%E2%80%93Torvalds_debate>
- **注意事項**: Torvaldsはマイクロカーネルの「理論的・美学的」優位性を認めつつ、実用性でモノリシックを擁護。Tanenbaumはポータビリティの問題も指摘（x86依存）
- **記事での表現**: 両者の主張を公平に紹介。モノリシック vs マイクロカーネルの設計論争として

## 7. Linux 0.12のGPLv2採用（1992年1月/2月）

- **結論**: Linux 0.12（1992年1月リリース）でGPLv2を採用。GPLの適用は1992年2月1日から発効。それ以前はTorvalds独自のライセンス（商用配布を禁止）を使用していた。ライセンス変更の理由は、ユーザグループでの配布時にコスト回収すらできない制約への不満
- **一次ソース**: Red Hat Blog "Celebrating 30 years of the Linux kernel and the GPLv2"
- **URL**: <https://www.redhat.com/en/blog/celebrating-30-years-linux-kernel-and-gplv2>
- **注意事項**: Torvalds自身が「making Linux GPLed was definitely the best thing I ever did」と述べている
- **記事での表現**: GPLv2採用の経緯と動機を記述。第12回のGPLの話と接続

## 8. Linux 1.0（1994年3月14日）

- **結論**: Linux 1.0.0は1994年3月14日にリリース。176,250行のコード。最初の「本番環境に適した」バージョンとされる
- **一次ソース**: Wikipedia "Linux kernel version history"
- **URL**: <https://en.wikipedia.org/wiki/Linux_kernel_version_history>
- **注意事項**: 0.01の10,239行から約17倍に成長
- **記事での表現**: 約2年半で10,000行から176,000行への成長として記述

## 9. Linux 2.0のSMP対応（1996年6月9日）

- **結論**: Linux 2.0.0は1996年6月9日にリリース。初のSMP（対称型マルチプロセッシング）の公式サポートを含む。ただし2.0系のSMPはBKL（Big Kernel Lock）による制約があり、カーネル内に一度に一つのCPUしか入れなかった。真のSMP改善はLinux 2.2（1999年1月）以降
- **一次ソース**: Wikipedia "Linux kernel"
- **URL**: <https://en.wikipedia.org/wiki/Linux_kernel>
- **注意事項**: SMP対応の初歩的段階であり、効率的なSMPは後のバージョンで実現
- **記事での表現**: SMP対応の開始として言及、完全なSMPは段階的に改善されたことを注記

## 10. Linuxカーネルのスケジューラ進化

- **結論**: O(n)スケジューラ（v0.01〜v2.4.x）→ O(1)スケジューラ（v2.6.0〜v2.6.22）→ CFS: Completely Fair Scheduler（v2.6.23、2007年10月〜）→ EEVDF（v6.6、2023年〜）。Con KolivasのワークがIngo MolnárのCFS開発を促した
- **一次ソース**: Wikipedia "Completely Fair Scheduler"、Linux Kernel Documentation
- **URL**: <https://en.wikipedia.org/wiki/Completely_Fair_Scheduler>
- **注意事項**: EEVDF（Earliest Eligible Virtual Deadline First）がv6.6でCFSを置き換えた
- **記事での表現**: スケジューラの進化を設計哲学の文脈で紹介

## 11. Linuxカーネルのコード規模の成長

- **結論**: 0.01は10,239行。1.0.0は176,250行。2025年1月時点でLinux 6.14 rc1で4,000万行を突破。20,000人以上の開発者が貢献。企業貢献が84.3%を占める（Intel 13.1%、Red Hat 7.2%等）
- **一次ソース**: Stackscale "The Linux Kernel surpasses 40 Million lines of code"
- **URL**: <https://www.stackscale.com/blog/linux-kernel-surpasses-40-million-lines-code/>
- **注意事項**: 2024年の年間新規コミット数は10年間で最低を記録
- **記事での表現**: 指数関数的成長の具体的数値として使用

## 12. Linus Torvaldsの自伝『Just for Fun』

- **結論**: 『Just for Fun: The Story of an Accidental Revolutionary』はLinus TorvaldsとDavid Diamondの共著。2001年5月にHarperBusinessから出版
- **一次ソース**: Amazon.com、Goodreads
- **URL**: <https://www.goodreads.com/book/show/160171.Just_for_Fun>
- **注意事項**: Torvaldsの生い立ち、動機、Linux開発の初期が語られる一次資料
- **記事での表現**: 参考文献として引用
