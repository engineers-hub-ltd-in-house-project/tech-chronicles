# ファクトチェック記録：第7回

**対象記事**: 第7回「集中型VCSの設計哲学——それは本当に『悪』だったのか？」
**調査日**: 2026-02-15
**調査手段**: WebSearch による一次ソース検証

---

## 1. CAP定理——Eric Brewer（2000年）

- **結論**: CAP定理はEric Brewerが1998年秋に着想し、1999年にCAP原理として発表、2000年のACM Symposium on Principles of Distributed Computing（PODC）で予想（conjecture）として発表した。2002年にMITのSeth GilbertとNancy Lynchが形式的な証明を行い、定理として確立された。分散データストアは一貫性（Consistency）、可用性（Availability）、分断耐性（Partition tolerance）の3つを同時に満たすことはできず、最大2つまでしか保証できないとする
- **一次ソース**: Wikipedia, "CAP theorem"; Gilbert & Lynch, "Perspectives on the CAP Theorem," MIT (2002)
- **URL**: <https://en.wikipedia.org/wiki/CAP_theorem>, <https://groups.csail.mit.edu/tds/papers/Gilbert/Brewer2.pdf>
- **注意事項**: CAP定理は厳密にはデータベース/分散システムの定理であり、VCSへの直接適用はアナロジーとして扱う必要がある。記事中でもアナロジーであることを明示する
- **記事での表現**: 「2000年、Eric BrewerがCAP定理を提唱した。分散システムは一貫性・可用性・分断耐性の三つを同時に満たせない。集中型VCSは一貫性と可用性を選び、分断耐性を犠牲にした設計と見ることができる」

## 2. Conway's Law——Melvin Conway（1967年/1968年）

- **結論**: Melvin Conwayが1967年に執筆し、Datamation誌に1968年4月に掲載された論文"How Do Committees Invent?"で提唱された。「システムを設計する組織は、その組織のコミュニケーション構造を反映した設計を生み出すことを余儀なくされる」という法則。Fred Brooksが著書『The Mythical Man-Month』でこれを「Conway's Law」と命名した
- **一次ソース**: Conway, M.E., "How Do Committees Invent?," Datamation, April 1968
- **URL**: <https://www.melconway.com/Home/pdf/committees.pdf>, <https://www.melconway.com/Home/Conways_Law.html>
- **注意事項**: VCSの設計選択と組織構造の関係を論じる文脈で使用。直接的なVCSへの言及ではないが、組織構造がツール選択に影響するという議論の補強として有効
- **記事での表現**: 「1968年にMelvin Conwayが提唱した法則は、組織がシステムを設計する際、その組織のコミュニケーション構造のコピーを生み出すと述べた。VCSの選択もまた、組織構造に深く影響される」

## 3. Lock-Modify-Unlock vs Copy-Modify-Merge モデル

- **結論**: SVN Bookは二つの並行性制御モデルを解説している。Lock-Modify-Unlock（悲観的ロック）はファイルを一人だけが編集できるよう排他ロックする方式。Copy-Modify-Merge（楽観的ロック）は各ユーザーが作業コピーを取得し、並行して作業し、最後にマージする方式。CVSはCopy-Modify-Mergeを革新的に導入した最初の主要VCSであり、SubversionもCopy-Modify-Mergeを基本としつつ、バイナリファイル等のためにLock-Modify-Unlockもサポートする
- **一次ソース**: SVN Book (svnbook.red-bean.com), "Versioning Models"; SVN Book, "Locking"
- **URL**: <https://svnbook.red-bean.com/en/1.0/ch02s02.html>, <https://svnbook.red-bean.com/en/1.8/svn.advanced.locking.html>
- **注意事項**: Copy-Modify-Mergeは「楽観的並行性制御」、Lock-Modify-Unlockは「悲観的並行性制御」とも呼ばれる。RCSは悲観的ロック方式だった
- **記事での表現**: 「RCSのLock-Modify-Unlock方式は、ファイルを一人しか編集できないという制約を設けることで一貫性を保証した。CVSが導入したCopy-Modify-Merge方式は、並行編集を許可し衝突時にマージで解決する革新だった」

## 4. Subversionのパスベースアクセス制御

- **結論**: Subversionは、リポジトリ内の特定のディレクトリやファイルに対して、ユーザーごとにread-only（r）またはread/write（rw）の権限を設定できるパスベースアクセス制御（Path-Based Authorization）を提供する。authzファイルで設定し、Apache（mod_authz_svn）またはsvnserveの両方で利用可能。Gitにはこのようなパスベースのネイティブなアクセス制御は存在しない
- **一次ソース**: SVN Book, "Path-Based Authorization"
- **URL**: <https://svnbook.red-bean.com/en/1.7/svn.serverconfig.pathbasedauthz.html>, <https://cwiki.apache.org/confluence/display/SVN/Path-Based+Access+Control>
- **注意事項**: Gitでは外部ツール（Gitolite, GitLabのProtected Branches等）で類似機能を実現するが、ネイティブ機能ではない。Perforceも強力なアクセス制御を持つ
- **記事での表現**: 「Subversionはリポジトリ内の特定パスに対して、ユーザーごとにread/writeの権限を細かく設定できた。この機能はコンプライアンス要件の厳しい企業環境で重要な差別化要因だった」

## 5. ネットワーク帯域の歴史的制約（1990年代〜2000年代）

- **結論**: 1990年代のインターネット接続は56kbpsのダイアルアップが標準。2000年代初頭のブロードバンドは256kbps〜1Mbps程度。企業向け専用回線は高額だった。この時代、リポジトリ全体のクローン（分散型VCSの基本操作）は現実的でないケースが多かった
- **一次ソース**: galbithink.org, "U.S. Bandwidth Price Trends in the 1990s"; Dresner Group, "The Evolution of Internet Speeds Since the 1990s"
- **URL**: <https://www.galbithink.org/prices.htm>, <https://www.dresnergroup.com/blog/the-evolution-of-internet-speeds-since-the-1990s>
- **注意事項**: 企業内LANは当時でも10Mbps〜100Mbps（Ethernet）だったため、同じオフィス内でのCVS/SVN使用には問題なかった。WANを越えた分散開発の制約が大きかった
- **記事での表現**: 「1990年代の標準的なインターネット接続は56kbpsのダイアルアップだった。リポジトリの全履歴をローカルに複製するという分散型VCSの前提は、この時代には非現実的だった」

## 6. ストレージコストの歴史的推移

- **結論**: 1990年頃のハードディスク容量あたりコストは約$250/GB。2000年頃には大幅に低下し、ストレージコストは主要な制約ではなくなりつつあった。2009年時点で約$0.11/GB、2017年で約$0.03/GBまで下落。指数関数的な価格低下が続いた
- **一次ソース**: mkomo.com, "A History of Storage Cost (update)"; Backblaze Blog, "The Cost Per Gigabyte of Hard Drives Over Time"
- **URL**: <https://mkomo.com/cost-per-gigabyte>, <https://www.backblaze.com/blog/hard-drive-cost-per-gigabyte/>
- **注意事項**: 1990年代にリポジトリの全履歴を各開発者のローカルマシンに保持するコストは無視できなかった
- **記事での表現**: 「1990年頃、ハードディスクは1GBあたり約250ドルだった。リポジトリの全履歴を各開発者のローカルマシンに保持するという分散型のアプローチは、ストレージコストの面からも合理的ではなかった」

## 7. Perforceとゲーム業界における集中型VCSの採用

- **結論**: Perforce（Helix Core）はAAA級ゲーム開発における業界標準。数百GBのバイナリアセットの管理、排他的チェックアウト（マージ不可能なバイナリファイルの衝突防止）、50人以上の開発者による同時作業、パスベースの厳密なアクセス制御を提供。2020年代においても、ゲーム業界や大企業では集中型VCSが現役で使われている
- **一次ソース**: Perforce Software, "Version Control for Binary Files"; Perforce, "Git vs. Perforce P4"
- **URL**: <https://www.perforce.com/blog/vcs/version-control-for-binary-files>, <https://www.perforce.com/blog/vcs/git-vs-perforce-how-choose-and-when-use-both>
- **注意事項**: Perforceはプロプライエタリソフトウェアであり、OSSのCVS/SVNとは異なるが、集中型VCSの設計思想を共有する
- **記事での表現**: 「2020年代においても、ゲーム業界ではPerforceが標準的に使われている。数百GBのバイナリアセットを管理し、マージ不可能なファイルには排他ロックを適用するという運用は、集中型VCSの設計思想が今なお合理的な領域が存在することを示している」

## 8. Linus Torvaldsの設計原則——WWCVSND

- **結論**: Linus TorvaldsはGitの設計において"WWCVSND"（What Would CVS Not Do）——「CVSがやらなかったことを選ぶ」という原則を掲げた。判断に迷ったときは、CVSが選ばなかった設計を採用した。集中型VCS（特にCVS）のすべてのアンチパターンを意識的に避けるという設計思想だった
- **一次ソース**: Kyle Cordes blog, "Linus Torvalds explains distributed source control"
- **URL**: <https://kylecordes.com/2007/linux-git-distributed>
- **注意事項**: この発言はGitの設計動機を理解する上で重要だが、同時に集中型VCSの問題点を裏返しに照射している
- **記事での表現**: 「LinusはGitの設計原則として"WWCVSND"を掲げた。CVSがやらないことをやる。この逆説的な設計指針は、集中型VCSの何が問題だったかを鮮明に浮かび上がらせる」

## 9. 集中型VCSの「単一信頼点」としてのメリット

- **結論**: 集中型リポジトリはプロジェクトの「単一の信頼できる情報源（Single Source of Truth）」として機能する。全員が同じ中央サーバの同じリビジョンを参照するため、「正しいバージョンはどれか」という曖昧さが排除される。バックアップ、監査、コンプライアンスの観点からも、変更履歴が一箇所に集約されていることは管理上の利点がある
- **一次ソース**: RhodeCode Blog, "Why enterprises still use Subversion source control in 2026?"; Perforce, "Helix Core"
- **URL**: <https://rhodecode.com/blog/162/why-enterprises-still-use-subversion-source-control-in-2026>, <https://www.perforce.com/blog/vcs/git-vs-perforce-how-choose-and-when-use-both>
- **注意事項**: 分散型VCSでも「blessed repository」パターンで擬似的に単一信頼点を構築できるが、技術的に強制されるものではない
- **記事での表現**: 「集中型リポジトリは唯一の信頼できる情報源として機能した。正しいバージョンがどれかという問いに対して、集中型VCSは構造的に明確な答えを持っていた」

## 10. CVS/Subversionの企業採用と集中型ワークフロー（2000年代）

- **結論**: CVSは2000年頃にOSSコミュニティで最大の普及を達成し、SourceForgeやSavannahの大多数のプロジェクトで使用された。CollabNetは2000年にSubversionの開発を開始し、「より良いCVS」を目標に掲げた。Subversion 1.0は2004年にリリースされ、2000年代半ばにCVSからSVNへの大規模な移行が起きた。企業ではClearCase、Perforce、IBM/Rationalのツールも使われていた
- **一次ソース**: Wikipedia, "Concurrent Versions System"; twobithistory.org, "Version Control Before Git with CVS"
- **URL**: <https://en.wikipedia.org/wiki/Concurrent_Versions_System>, <https://twobithistory.org/2018/07/07/cvs.html>
- **注意事項**: 企業環境ではOSS以外の商用VCS（ClearCase, Perforce, StarTeam等）も広く使われていた
- **記事での表現**: 「2000年代、CVSとSubversionは企業のソフトウェア開発における標準的なバージョン管理ツールだった。集中型のワークフローは、組織の管理構造と自然に整合した」
