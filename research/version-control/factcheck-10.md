# ファクトチェック記録：第10回

## テーマ：Subversionの黄金時代と陰り

---

## 1. Subversionのバージョン別リリース日と主要機能

- **結論**: 1.0（2004年2月23日）、1.1（2004年9月29日）、1.2（2005年5月21日）、1.3（2005年12月30日）、1.4（2006年9月10日）、1.5（2008年6月19日）、1.6（2009年3月20日）、1.7（2011年10月11日）。1.5でマージ追跡（svn:mergeinfo）と疎チェックアウト。1.6でツリーコンフリクト検出。1.7でHTTPv2プロトコルと集中型メタデータ（.svn）
- **一次ソース**: Apache Subversion, "Release History"
- **URL**: <https://subversion.apache.org/docs/release-notes/release-history.html>
- **注意事項**: 1.5のリリースは当初の予定から大幅に遅延した。Hyrum K. Wrightによる論文がこの経緯を記録している
- **記事での表現**: Subversion 1.0は2004年2月23日にリリースされた。以降、ほぼ年1回のペースでメジャーバージョンが更新され、1.5（2008年6月）で待望のマージ追跡機能が実装された

## 2. Subversionの市場シェア推移（2005-2010年）

- **結論**: 2009年時点でSubversionの市場シェアは約57.5%。Gitはわずか2.4%だった。Eclipse Community Survey 2009年ではSVNが58%、Gitが2%
- **一次ソース**: Eclipse Community Survey 2009; RhodeCode "Version Control Systems Popularity in 2025" (歴史データ引用)
- **URL**: <https://rhodecode.com/blog/156/version-control-systems-popularity-in-2025>
- **注意事項**: 調査対象コミュニティにより数値は変動する。Eclipse調査はJava開発者が中心。2025年時点ではSVNのシェアは約13%まで低下
- **記事での表現**: 2009年のEclipseコミュニティ調査ではSVNが58%のシェアを握り、Gitは2%に過ぎなかった。Subversionは明確に市場の覇者だった

## 3. TortoiseSVNの歴史

- **結論**: 2002年にTim KempがTortoiseCVSに触発されて開発を開始。最初の公開リリースはバージョン0.4（2003年1月24日）。Stefan Kungがプロジェクトに参加し大部分を書き直した。バージョン1.0は2004年2月23日リリース。Windowsエクスプローラのシェル拡張として実装され、右クリックメニューとオーバーレイアイコンを提供
- **一次ソース**: TortoiseSVN公式サイト "About"; Wikipedia "TortoiseSVN"
- **URL**: <https://tortoisesvn.net/about.html>, <https://en.wikipedia.org/wiki/TortoiseSVN>
- **注意事項**: TortoiseSVNはSubversionの普及にWindowsプラットフォームで決定的な役割を果たした
- **記事での表現**: TortoiseSVNは2003年に初の公開リリースを迎え、Windowsエクスプローラに統合されたGUIクライアントとして、Subversionの普及を牽引した

## 4. Eclipse Subversionプラグイン（Subclipse, Subversive）

- **結論**: SubclipseはSubversionコアコミッターが開発・保守。Subversive は Eclipse Foundation公式のSVN統合プラグイン。両者ともEclipse IDEからSVN操作（checkout, commit, update, merge, revert）を実行可能にした
- **一次ソース**: Eclipse Marketplace; Oracle "Using and hacking Subclipse"
- **URL**: <https://marketplace.eclipse.org/content/subclipse>, <https://marketplace.eclipse.org/content/subversive-svn-team-provider>
- **注意事項**: EGitとJGitは2009年5月にEclipseに移行し、2010年6月のHeliosリリースに同梱された。これがGitへの移行の転換点
- **記事での表現**: SubclipseとSubversiveという二つのプラグインにより、Eclipse IDEはSubversionの強力なフロントエンドとなった

## 5. Visual StudioのSubversion統合（AnkhSVN, VisualSVN）

- **結論**: AnkhSVNはApache License下の無料プラグイン。Visual Studio .NET 2002/2003向けの1.x系と、VS 2005以降のSCC API対応で完全書き直しされた2.0系がある。VisualSVNはTortoiseSVNを内部利用する商用プラグイン
- **一次ソース**: AnkhSVN Wikipedia; Visual Studio Marketplace
- **URL**: <https://en.wikipedia.org/wiki/AnkhSVN>, <https://marketplace.visualstudio.com/items?itemName=vs-publisher-303797.AnkhSVN-SubversionSupportforVisualStudio>
- **注意事項**: AnkhSVN 2.0はVS 2008以降対応。VisualSVNはソリューションエクスプローラにステータスアイコンを表示
- **記事での表現**: AnkhSVNとVisualSVNにより、Visual StudioからのSubversion操作が可能となり、.NET開発者にもSubversionが浸透した

## 6. Subversion 1.5のマージ追跡（svn:mergeinfo）の仕組みと限界

- **結論**: svn:mergeinfo はバージョン管理されたプロパティで、マージ済みリビジョンのリストをパスごとに記録する。形式は「マージ元パス:リビジョンリスト」の改行区切り。明示的mergeinfo（プロパティに記録）と暗黙的mergeinfo（自然な履歴から推論）の二種がある。ただしリネームを含むマージでは問題が発生しやすく、svn:mergeinfo プロパティが肥大化する問題もあった
- **一次ソース**: Apache Subversion Blog, "Subversion 1.5 Mergeinfo - Understanding the Internals" (2008年5月); SVN Book, "Basic Merging"
- **URL**: <https://subversion.apache.org/blog/2008-05-06-merge-info.html>, <https://svnbook.red-bean.com/en/1.7/svn.branchmerge.basicmerging.html>
- **注意事項**: 1.5以前はマージ追跡が一切なく、開発者が手動で記録する必要があった
- **記事での表現**: Subversion 1.5で導入されたsvn:mergeinfo プロパティは、マージ済みリビジョンをパスごとに記録する仕組みだが、リネームを含むブランチ間マージでは依然として問題が多発した

## 7. Subversionのリネーム追跡の限界とツリーコンフリクト

- **結論**: Subversionの `svn move` は内部的に `svn copy` + `svn delete` として実装される。コピーと削除が概念的に結びついているという情報はサーバに伝達されず、リポジトリにも保存されない。このためマージ・更新時に「ツリーコンフリクト」が頻発する。SVN-3630（Rename tracking）は長年の未解決課題
- **一次ソース**: SVN Book, "Dealing with Structural Conflicts"; Apache JIRA SVN-3630
- **URL**: <https://svnbook.red-bean.com/en/1.6/svn.tour.treeconflicts.html>, <https://issues.apache.org/jira/browse/SVN-3630>
- **注意事項**: Subversion 1.6でツリーコンフリクトの「検出」は改善されたが、リネーム追跡そのものは未実装のまま
- **記事での表現**: Subversionは `svn move` をcopy+deleteとして処理するため、真のリネーム追跡ができない。これがマージ時のツリーコンフリクトの主因であり、SVN-3630として長年にわたり未解決の課題であり続けた

## 8. Subversionのオフライン作業の制約

- **結論**: Subversionではオフラインでsvn status, svn diff, svn revertは実行可能（.svn内にpristineコピーを保持するため）。ただしcommit, update, merge, log（リモート）など主要操作はネットワーク接続を必要とする。オフラインでのコミットは不可
- **一次ソース**: SVN Book, "Basic Work Cycle"; Apache Subversion FAQ
- **URL**: <https://svnbook.red-bean.com/en/1.7/svn.tour.cycle.html>, <https://subversion.apache.org/faq.html>
- **注意事項**: SVK（svn上の分散レイヤー）やgit-svnが回避策として使われた
- **記事での表現**: 標準的なSubversionでは、ネットワークに接続できない環境ではコミットが一切できない。ローカルでの差分確認やリバートは可能だが、変更の記録という核心機能がオフラインでは使えなかった

## 9. 大規模リポジトリでのSubversionの性能問題

- **結論**: リポジトリサイズが100GBに近づくとチェックアウト・コミット操作の性能が著しく劣化。200msのレイテンシでリモートユーザーのコミット時間が25%増加。50名超のチームでは同時利用のボトルネックが発生。チェックアウトサイズが大きいほどTCPの帯域-遅延制約の影響を受ける
- **一次ソース**: SVN Book, "Server Optimization"; Assembla, "SVN Repository Optimization Best Practices"
- **URL**: <https://svnbook.red-bean.com/en/1.7/svn.serverconfig.optimization.html>, <https://get.assembla.com/blog/svn-repository-optimization-tips/>
- **注意事項**: Subversion 1.7でインメモリキャッシュが導入され改善が図られた。部分チェックアウト（sparse checkout）も1.5で導入されたが、Gitのsparse-checkoutほど柔軟ではない
- **記事での表現**: 大規模リポジトリではネットワーク遅延とサーバ負荷が直接的にチーム全体の開発速度を制約した。これは集中型アーキテクチャの構造的な帰結であった

## 10. Subversion 1.5リリースの遅延（Hyrum Wright論文）

- **結論**: Subversion 1.5は当初の予定から大幅に遅れ、2008年6月にリリースされた。Hyrum K. WrightとDewayne E. Perryが2009年にICSE Workshop（FLOSS 2009）で"Subversion 1.5: A Case Study in Open Source Release Mismanagement"を発表。マージ追跡機能の開発が長期化し、ユーザーと開発者の両方に混乱をもたらした経緯を分析
- **一次ソース**: Wright, H.K. & Perry, D.E., "Subversion 1.5: A Case Study in Open Source Release Mismanagement", FLOSS 2009
- **URL**: <https://www.hyrumwright.org/papers/floss2009.pdf>
- **注意事項**: この論文はOSSプロジェクトのリリース管理の失敗事例として引用されることが多い
- **記事での表現**: マージ追跡機能の実装は予想以上に困難を極め、1.5のリリースは大幅に遅延した。この経緯はHyrum Wrightらの論文で詳細に分析されている

## 11. GitとGitHubによるSubversionの衰退

- **結論**: GitHubは2008年に公開。Eclipse Community Surveyでは2009年にSVN 58%/Git 2%だったが、2011年末にはEclipse.orgのプロジェクトでGitがSVNを超えた。2014年のEclipse調査でGitがJava開発者のVCS選択でSVNを逆転。「GitがSVNに勝ったのではなく、GitHubがSVNに勝った」という見方がある
- **一次ソース**: InfoQ, "Git surpasses CVS, SVN at Eclipse.org" (2011年12月); Stack Overflow Blog, "Beyond Git" (2023年1月)
- **URL**: <https://www.infoq.com/news/2011/12/eclipse-git/>, <https://stackoverflow.blog/2023/01/09/beyond-git-the-other-version-control-systems-developers-use/>
- **注意事項**: 衰退の時期はコミュニティにより異なる。OSSコミュニティではより早く、企業では遅れて移行が進んだ
- **記事での表現**: GitHubの登場（2008年）が転換点となり、2011年にはEclipse.orgでGitがSVNを超えた。「GitがSVNに勝ったのではなく、GitHubが勝った」とも言われる

## 12. Apache Software FoundationのGit移行

- **結論**: ASFは2019年にGitHub統合を拡大し、多くのプロジェクトがGitに移行した。ただし全面的なSVN→Git移行ではなく、個別プロジェクトの判断による。Subversion自体のソースコードはASFのSVNリポジトリで管理され続けている（GitHubにはミラーが存在）
- **一次ソース**: Apache Software Foundation, "Expands Infrastructure with GitHub Integration" (2019年4月)
- **URL**: <https://www.globenewswire.com/news-release/2019/04/29/1811088/17401/en/The-Apache-Software-Foundation-Expands-Infrastructure-with-GitHub-Integration.html>
- **注意事項**: Subversionの開発元であるASF自体がGitHub統合を進めたことは象徴的
- **記事での表現**: Subversionの本拠地であるASF自体が2019年にGitHub統合を拡大した事実は、時代の変化を象徴的に物語る
