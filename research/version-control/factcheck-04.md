# ファクトチェック記録：第4回

**対象記事**: 第4回「CVSの誕生——RCSの限界を超えて」
**調査日**: 2026-02-15
**調査手段**: WebSearch による一次ソース検証

---

## 1. Dick GruneによるCVSの開発経緯

- **結論**: Dick Gruneは1986年7月にCVSの原型を開発した。動機は、Vrije Universiteit Amsterdamにおいて学生のErik BaalbergenとMaarten Waageとの間でACK（Amsterdam Compiler Kit）Cコンパイラの共同開発を円滑にすることだった。3人の作業スケジュールが大きく異なっていた（一人は定時勤務、一人は不規則、Gruneは夜間のみ作業可能）。プロジェクト期間は1984年7月から1985年8月。初期の名前は「cmt」（commitの意）。1986年6月23日にcomp.sources.unixへ公開投稿された
- **一次ソース**: Dick Grune, CVS.orig page; Wikipedia, "Concurrent Versions System"
- **URL**: <https://dickgrune.com/Programs/CVS.orig/>
- **注意事項**: ACKプロジェクト自体は1984-1985年だが、CVSスクリプトの公開は1986年。初期実装はBourneシェルスクリプトで、RCSパッケージに依存
- **記事での表現**: 「1986年、オランダのVrije Universiteit AmsterdamのDick Gruneは、学生との共同開発を円滑にするため、RCSのラッパースクリプトとしてCVSの原型を開発した」

## 2. 初期CVSの技術的実装

- **結論**: 初期CVSは3つの主要コマンドで構成されていた。CreateVersion（リポジトリからプライベートコピーを生成）、UpdateVersion（最新の変更をrcsmergeで統合）、Commit（ファイルをリポジトリに登録）。内部的にはRCSの,vファイルをそのまま利用。Gruneは可能なファイル状態の全組み合わせを網羅する「決定テーブル」を作成して設計した。「very-long-term transactions」を可能にし、リポジトリ側では未回収のコピーを追跡しない設計
- **一次ソース**: Dick Grune, CVS.orig page
- **URL**: <https://dickgrune.com/Programs/CVS.orig/>
- **注意事項**: CreateVersion/UpdateVersion/Commitという命名は後のcheckout/update/commitに対応する
- **記事での表現**: 「Gruneの初期CVSは3つの操作——CreateVersion、UpdateVersion、Commit——で構成されるシェルスクリプト群だった。内部ではRCSの,vファイルをそのまま利用し、ファイル状態の全組み合わせを網羅する決定テーブルに基づいて設計された」

## 3. Brian BerlinerによるCの書き直し

- **結論**: 1989年4月、Brian Berliner（Prisma, Inc.所属）がCVSをC言語で書き直した。Jeff Polkがモジュールおよびベンダーブランチのサポートを設計・実装した。Prisma社は1988年12月からCVSを利用しており、SunOSカーネルのサードパーティ開発に使用。SunOS 4.0.3カーネルソースのアップグレード配布では346ファイル中233ファイルが修正、うち139ファイルがクリーンにマージ、94ファイルが手動マージを要した。1990年にUSENIX Conference Proceedingsで "CVS II: Parallelizing Software Development" を発表
- **一次ソース**: Berliner, B., "CVS II: Parallelizing Software Development," USENIX Conference Proceedings, pp. 341-352, 1990
- **URL**: <https://docs-archive.freebsd.org/44doc/psd/28.cvs/paper.pdf>
- **注意事項**: 「CVS II」というタイトルはGruneの初期CVSに対する第二世代の意味。Prismaでの実績がCVSの信頼性を証明した
- **記事での表現**: 「1989年4月、Prisma社のBrian BerlinerがCVSをC言語で全面的に書き直した。SunOSカーネル開発での実戦投入を経て、1990年のUSENIX Conferenceで論文として発表された」

## 4. CVS version 1.0とFSFへの提出

- **結論**: 1990年11月19日、CVS version 1.0がFree Software Foundationに提出され、開発・配布が引き継がれた。GPLの下でリリースされた
- **一次ソース**: Wikipedia, "Concurrent Versions System"
- **URL**: <https://en.wikipedia.org/wiki/Concurrent_Versions_System>
- **注意事項**: FSFへの提出がCVSのオープンソースとしての地位を確立した
- **記事での表現**: 「1990年11月19日、CVS version 1.0がFree Software Foundationに提出され、GPLの下で配布されることになった」

## 5. Copy-Modify-Mergeモデル

- **結論**: CVSはRCSの悲観的ロック（Lock-Modify-Unlock）モデルを捨て、Copy-Modify-Mergeモデル（楽観的並行制御）を採用した。開発者はリポジトリから作業コピーを取得し、自由に変更し、変更を後からマージする。実際には同じファイルの同じ箇所を変更するケースは少なく、衝突は稀だった。衝突が発生した場合はCVSクライアントが自動的にハンドリングし、自動解決不可能な場合のみ手動介入が必要
- **一次ソース**: GNU CVS Manual v1.11.23; SVN Book "Versioning Models"
- **URL**: <https://www.gnu.org/software/trans-coord/manual/cvs/cvs.html>
- **注意事項**: 「Concurrent」（並行）というCVSの名前自体がこのモデルの本質を表す
- **記事での表現**: 「CVSは『Concurrent（並行）』の名が示す通り、RCSのファイルロックを捨て、Copy-Modify-Mergeモデルを採用した。複数の開発者が同じファイルを同時に編集でき、衝突は後からマージで解決する」

## 6. CVSのリポジトリ構造とRCS ,vファイルの利用

- **結論**: CVSのリポジトリは作業ディレクトリと対応するディレクトリツリー構造を持つ。各ファイルはRCS形式の,vファイルとして格納される。CVSROOT管理ディレクトリには設定ファイル（loginfo, modules, commitinfo等）が,vファイル形式で格納される。Atticサブディレクトリにはtrunkに存在しないファイルが格納される
- **一次ソース**: GNU CVS Manual, "Repository files"
- **URL**: <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Repository-files.html>
- **注意事項**: CVSはRCSの,vファイル形式を拡張して使用するが、magic branchesなどCVS独自の拡張がある。CVSのロック機構はRCSのそれとは異なる実装
- **記事での表現**: 「CVSのリポジトリ内部では、各ファイルがRCS形式の,vファイルとして格納される。CVSはRCSを土台として、その上にディレクトリレベルの管理機能を構築した」

## 7. CVSのクライアント・サーバモデル

- **結論**: 初期のCVSはローカル専用だった。1993年、Cygnus SolutionsのJim Kingdonがクライアント・サーバモードを実装した。Kingdonはバージニア州のコミューンに住んでおり、シリコンバレーに移住せずにリモートで作業するためにこの機能を必要とした。Jim BlandyとKarl Fogel（後のSubversionプロジェクトの中心人物）がこのパッチの公式採用を推進した。pserver認証方式はポート2401（IANA公式登録）を使用し、平文パスワードの簡易エンコーディングによる認証を行う
- **一次ソース**: Increment Magazine, "Committing to Collaboration"; GNU CVS Manual, "Connection"
- **URL**: <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Connection.html>
- **注意事項**: pserverのセキュリティは脆弱で、パスワードは「不用意な漏洩を防ぐ」程度の難読化のみ。ext（SSH経由）の方が安全だが設定が複雑だった
- **記事での表現**: 「1993年、Cygnus SolutionsのJim Kingdonがクライアント・サーバモードを実装し、CVSはネットワーク越しに利用可能になった。後にKarl FogelとJim Blandyがこのパッチの公式採用を推進した」

## 8. SourceForgeの設立とCVS

- **結論**: SourceForgeは1999年11月17日にVA Softwareによって開設された。フリー・オープンソースソフトウェア開発者に無料で一元的な開発プラットフォームを提供した最初のサービス。CVSリポジトリ、バグトラッカー、メーリングリストなどのツールを無料提供。2000年末には数千プロジェクト、2001年末には約30,000プロジェクトが登録
- **一次ソース**: SourceForge Community Blog; Wikipedia, "SourceForge"
- **URL**: <https://sourceforge.net/blog/brief-history-sourceforge-look-to-future/>
- **注意事項**: SourceForgeのサイト運営ソフトウェア自体も2000年1月にフリーソフトウェアとして公開された（SourceForge Alexandria）
- **記事での表現**: 「1999年11月、VA SoftwareがSourceForgeを開設した。CVSリポジトリを核とする無料の開発プラットフォームは、OSSエコシステムの爆発的成長の触媒となった。2001年末には約30,000プロジェクトが登録されていた」

## 9. CVSのファイル単位バージョニング

- **結論**: CVSは各ファイルを独立にバージョニングする。ファイルごとに1.1, 1.2, 1.3...とリビジョン番号が振られ、ブランチでは1.1.1.1のように追加の数字コンポーネントが付く。プロジェクト全体としてのアトミックコミットは存在しない（これがCVSの最大の弱点の一つ）
- **一次ソース**: Two Bit History, "Version Control Before Git with CVS"
- **URL**: <https://twobithistory.org/2018/07/07/cvs.html>
- **注意事項**: ファイル単位のバージョニングはRCSからの直接的な継承。プロジェクト全体のスナップショットという概念はSubversion以降で導入
- **記事での表現**: 「CVSは各ファイルを独立にバージョニングする。リビジョン1.1, 1.2, 1.3とファイルごとに番号が振られる。プロジェクト全体を一つの単位として記録するアトミックコミットは、CVSの設計には存在しなかった」

## 10. CVSのブランチ実装の影響

- **結論**: CVSはバージョン管理システムにおけるブランチ機能の実装を導入した。他のシステムにおけるブランチ技術はすべて、1990年に文書化されたCVSの実装に由来するとされる
- **一次ソース**: Wikipedia, "Concurrent Versions System"
- **URL**: <https://en.wikipedia.org/wiki/Concurrent_Versions_System>
- **注意事項**: RCSにもブランチは存在したが、CVSがプロジェクト全体を対象としたブランチ操作を実現し、実用的なワークフローとして確立した
- **記事での表現**: 「CVSはバージョン管理におけるブランチ機能を実用的な形で確立した。後続のシステムにおけるブランチ技術は、CVSの実装に多くを負っている」
