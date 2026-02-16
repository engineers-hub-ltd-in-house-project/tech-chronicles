# ファクトチェック記録：第23回「バージョン管理の本質に立ち返る——変更・協調・歴史」

## 1. SCCS（Source Code Control System）の起源

- **結論**: Marc J. Rochkindが1972年にBell LabsでSNOBOL4を用いてSCCSを開発。1973年にC言語で書き直し、PDP-11上のUNIXで動作。最初の公開版はSCCS Version 4（1977年2月18日）。論文は1975年12月にIEEE Transactions on Software Engineeringに掲載。
- **一次ソース**: Rochkind, Marc J. "The Source Code Control System." IEEE Transactions on Software Engineering, SE-1(4): 364-370, December 1975.
- **URL**: <https://en.wikipedia.org/wiki/Source_Code_Control_System>, <https://www.mrochkind.com/mrochkind/docs/SCCSretro2.pdf>
- **注意事項**: 「1972年開発開始」はRochkind自身の回顧録で確認済み。論文発表は1975年。
- **記事での表現**: 「1972年、Bell LabsのMarc J. Rochkindが開発したSCCSは、ソースコードの変更履歴を自動的に記録する最初のツールだった」

## 2. RCS（Revision Control System）の起源

- **結論**: Walter F. TichyがPurdue大学で開発し、1982年に公開。論文「Design, Implementation and Evaluation of a Revision Control System」は1982年3月25日付。正式論文は1985年にSoftware—Practice & Experience誌に掲載。
- **一次ソース**: Tichy, Walter F. "RCS—A System for Version Control." Software—Practice & Experience 15, 7 (July 1985). Purdue University Technical Report.
- **URL**: <https://docs.lib.purdue.edu/cstech/394/>, <https://www.gnu.org/software/rcs/tichy-paper.pdf>
- **注意事項**: 1982年の初版公開と1985年の論文掲載を区別する必要あり。
- **記事での表現**: 「1982年、Purdue大学のWalter F. Tichyが発表したRCSは、リバースデルタ方式による差分保存を導入した」

## 3. CVS（Concurrent Versions System）の起源

- **結論**: Dick Gruneが1984年7月から1985年8月にかけて、学生Erik BaalbergenとMaarten Waageとの協調開発のためにシェルスクリプトとして開発。1986年6月23日に公開。comp.sources.unixニュースグループのvolume 6（1986年7月）に投稿。Brian Berlinerが1989年4月にCで書き直し。
- **一次ソース**: Dick Grune's CVS page
- **URL**: <https://dickgrune.com/Programs/CVS.orig/>
- **注意事項**: 初期版はcmtという名前。RCSの上に構築されたラッパー。
- **記事での表現**: 「1986年、Dick Gruneが公開したCVSは、RCSをネットワーク対応に拡張し、複数開発者の並行作業を可能にした」

## 4. Subversionの開発開始

- **結論**: 2000年2月、CollabNetがKarl Fogelに連絡。Jim Blandyが基本設計とSubversionの名称を考案。Karl FogelとBen Collins-Sussmanを雇用し、2000年5月に詳細設計開始。2001年にはSubversion自身のソースコードをホスト。2004年2月にバージョン1.0リリース。
- **一次ソース**: "Version Control with Subversion" (svnbook), Subversion's History chapter
- **URL**: <https://svnbook.red-bean.com/en/1.6/svn.intro.whatis.html>, <https://en.wikipedia.org/wiki/Apache_Subversion>
- **注意事項**: Apache Software Foundationが2020年にSubversionの20周年を記念している。
- **記事での表現**: 「2000年、CollabNetのKarl FogelとBen Collins-Sussmanが中心となり、"CVS done right"を目指すSubversionの開発が始まった」

## 5. Git誕生の経緯

- **結論**: 2005年4月3日に開発開始。4月6日にプロジェクトをアナウンス。4月7日にセルフホスティング達成（最初のコミット: e83c5163316）。初期のGitは「the information manager from hell」と称された。7月26日にJunio Hamanoにメンテナンスを委譲。12月21日にバージョン1.0リリース。
- **一次ソース**: Git initial commit, LKML archives, git-scm.com
- **URL**: <https://git-scm.com/book/en/v2/Getting-Started-A-Short-History-of-Git>, <https://en.wikipedia.org/wiki/Git>
- **注意事項**: Linus Torvaldsは「ファイルシステム設計者の視点からバージョン管理に取り組んだ」と述べている。
- **記事での表現**: 「2005年4月、Linus TorvaldsはGitを『コンテンツアドレッサブルファイルシステム』として設計し、10日足らずでセルフホスティングを達成した」

## 6. Fred Brooks "No Silver Bullet"（1986年）

- **結論**: 1986年発表の論文。ソフトウェア工学における「本質的複雑さ（essential complexity）」と「偶有的複雑さ（accidental complexity）」の区別を提唱。本質的困難として複雑性、適合性、可変性、不可視性の4つを挙げた。
- **一次ソース**: Brooks, Frederick P. "No Silver Bullet—Essence and Accident in Software Engineering." 1986. 後にIEEE Computer誌 (1987) に掲載。
- **URL**: <https://en.wikipedia.org/wiki/No_Silver_Bullet>, <https://worrydream.com/refs/Brooks_1986_-_No_Silver_Bullet.pdf>
- **注意事項**: 『The Mythical Man-Month』20周年記念版（1995年）に収録。
- **記事での表現**: 「Fred Brooksが1986年に提唱した『本質的複雑さと偶有的複雑さ』の区別は、バージョン管理の評価にも適用できる」

## 7. Conway's Law（1968年）

- **結論**: Melvin Conwayが1967年にHarvard Business Reviewに投稿したが却下され、1968年4月にDatamation誌に「How Do Committees Invent?」として掲載。Fred Brooksが『The Mythical Man-Month』で引用し「Conway's Law」と命名。
- **一次ソース**: Conway, Melvin E. "How Do Committees Invent?" Datamation, April 1968.
- **URL**: <https://www.melconway.com/Home/Conways_Law.html>, <https://en.wikipedia.org/wiki/Conway%27s_law>
- **注意事項**: 原文: "organizations which design systems are constrained to produce designs which are copies of the communication structures of these organizations."
- **記事での表現**: 「Melvin Conwayが1968年に指摘した通り、組織のコミュニケーション構造はシステムの設計に反映される。バージョン管理システムの設計もまた、その時代の開発組織の構造を反映している」

## 8. Leslie Lamport「Time, Clocks, and the Ordering of Events」（1978年）

- **結論**: 1978年7月、Communications of the ACM 21(7): 558-565に掲載。分散システムにおけるイベントの順序付け（半順序）と論理クロック（Lamportタイムスタンプ）を提案。2000年にPODC Influential Paper Award、2007年にACM SIGOPS Hall of Fame Awardを受賞。
- **一次ソース**: Lamport, Leslie. "Time, Clocks, and the Ordering of Events in a Distributed System." Communications of the ACM, 21(7): 558-565, July 1978.
- **URL**: <https://dl.acm.org/doi/10.1145/359545.359563>, <https://amturing.acm.org/p558-lamport.pdf>
- **注意事項**: 分散型VCSにおける「コミットの順序付け」問題と直接関連する。
- **記事での表現**: 「Leslie Lamportが1978年に示したように、分散システムにおけるイベントの順序付けは本質的に困難である。分散型VCSにおけるコミット履歴の順序付けもまた、この問題の一変形だ」

## 9. IEEE 828 Software Configuration Management標準

- **結論**: 初版は1983年に制定。構成識別、構成制御、構成状態記録、構成監査の4活動を定義。1990年、1998年、2005年、2012年に改訂。構成管理（CM）の概念は1950年代のハードウェア管理に遡る。
- **一次ソース**: IEEE Std 828-1983, "IEEE Standard for Software Configuration Management Plans"
- **URL**: <https://ieeexplore.ieee.org/document/7439689>, <https://standards.ieee.org/ieee/828/10549/>
- **注意事項**: SCMの4活動（識別・制御・状態記録・監査）はバージョン管理の「本質」の整理に使える。
- **記事での表現**: 「IEEE 828は1983年の初版以来、ソフトウェア構成管理の4活動——識別、制御、状態記録、監査——を定義し続けてきた」

## 10. diff/patchの起源

- **結論**: James W. HuntとM. Douglas McIlroyが1976年にBell Labsで開発。最長共通部分列（LCS）アルゴリズムに基づく。Bell Labs Computing Science Technical Report #41, July 1976。Larry Wallが1985年にpatchプログラムを開発。
- **一次ソース**: Hunt, J. W., McIlroy, M. D. "An Algorithm for Differential File Comparison." Bell Laboratories Computing Science Technical Report #41, July 1976.
- **URL**: <https://www.cs.dartmouth.edu/~doug/diff.pdf>
- **注意事項**: diff3（three-way diff）はCVSの「Copy-Modify-Merge」モデルの基盤技術。
- **記事での表現**: 「1976年、HuntとMcIlroyが開発したdiffアルゴリズムは、二つのファイルの差分を最長共通部分列の計算に帰着させた」

## 11. Brooks' Law とチームコミュニケーション

- **結論**: Fred Brooksが1975年の著書『The Mythical Man-Month』で提唱。「遅れているソフトウェアプロジェクトへの要員追加は、プロジェクトをさらに遅らせる」。n人のチームの通信経路数はn(n-1)/2。
- **一次ソース**: Brooks, Frederick P. "The Mythical Man-Month: Essays on Software Engineering." Addison-Wesley, 1975.
- **URL**: <https://en.wikipedia.org/wiki/The_Mythical_Man-Month>, <https://en.wikipedia.org/wiki/Brooks's_law>
- **注意事項**: コミュニケーションコストとバージョン管理の「協調」機能は密接に関連する。
- **記事での表現**: 「Brooksが1975年に指摘した通り、n人のチームではn(n-1)/2の通信経路が生じる。バージョン管理の『協調』機能は、この通信コストを構造化する仕組みだ」

## 12. Mercurialの誕生

- **結論**: Matt Mackallが2005年4月19日にLinux Kernel Mailing Listで「Mercurial v0.1 - a minimal scalable distributed SCM」としてアナウンス。BitKeeperの無償ライセンス撤回を受けて開発開始。Gitと同時期（Gitのアナウンスは4月6日）。
- **一次ソース**: LKML: Matt Mackall, "Mercurial v0.1 - a minimal scalable distributed SCM", 2005-04-20
- **URL**: <https://lkml.org/lkml/2005/4/20/45>, <https://en.wikipedia.org/wiki/Mercurial>
- **注意事項**: GitとMercurialが同一の問題（BitKeeper問題）に対する並行解として誕生したことは、第23回の「本質」の議論で重要。
- **記事での表現**: 「2005年4月、同じ問題に対して二つの異なる解が同時に生まれた。Linus TorvaldsのGitとMatt MackallのMercurialだ」
