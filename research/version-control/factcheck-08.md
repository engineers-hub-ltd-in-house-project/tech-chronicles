# ファクトチェック記録：第8回「Subversionの誕生——"CVS done right"」

調査日：2026-02-15

---

## 1. CollabNetの設立とSubversionプロジェクトの開始

- **結論**: CollabNetは1999年にTim O'Reilly、Brian Behlendorf、Bill Portelliによって設立された。2000年2月、CollabNetはKarl Fogelに連絡を取り、CVSの後継となるオープンソースバージョン管理システムの開発を依頼した。Karl FogelとBen Collins-Sussmanが雇用され、2000年5月に詳細設計が開始された。
- **一次ソース**: SVN Book, "What Is Subversion?" (svnbook.red-bean.com); ASF Blog, "20th Anniversary of Apache Subversion" (2020)
- **URL**: <https://svnbook.red-bean.com/en/1.8/svn.intro.whatis.html>, <https://news.apache.org/foundation/entry/the-apache-software-foundation-announces58>
- **注意事項**: Brian BehlendorfはApache Software Foundationの創設メンバーでもある。CollabNetとApacheの関係が深い。
- **記事での表現**: 「2000年2月、CollabNetはCVSの専門書『Open Source Development with CVS』の著者Karl Fogelに声をかけた。Fogelは友人のJim Blandyと新しいバージョン管理システムの設計を議論していた最中だった」

## 2. Jim Blandyの役割——Subversionの名前と基本設計

- **結論**: Jim BlandyはCVSへの不満から、新しいバージョン管理の方法を考えていた。「Subversion」という名前とデータストアの基本設計は、BlandyがCollabNetのプロジェクト開始前に考案していた。Blandyの雇用主Red Hat Softwareが、彼をプロジェクトに無期限で「寄贈」した。
- **一次ソース**: SVN Book, "Subversion's History" section
- **URL**: <https://svnbook.red-bean.com/en/1.7/svn-book.html>
- **注意事項**: Karl FogelとJim Blandyは1995年にCyclic Softwareを共同創設し、CVSの商用サポートを提供していた。CVSを最も深く理解していた二人がSubversionを設計したことに意義がある。
- **記事での表現**: 「Jim Blandyは"Subversion"という名前だけでなく、データストアの基本設計まで考案していた。CVSの商用サポートを提供していた人間が、CVSの後継を設計する——これほど説得力のある開発者はいなかった」

## 3. Karl Fogelの経歴と著書

- **結論**: Karl Fogelは1992年からオープンソース開発者。1995年にJim Blandyと共にCyclic Software（CVS初の商用サポート企業）を創設。1997年にCVSに匿名リードオンリーリポジトリアクセスを追加。1999年に『Open Source Development with CVS』（Coriolis OpenPress）を出版。2000-2006年にCollabNetでSubversionの創設開発者。2005年に『Producing Open Source Software』（O'Reilly Media）を出版。
- **一次ソース**: Karl Fogel Professional Biography (producingoss.com)
- **URL**: <https://producingoss.com/cv/bio.html>
- **注意事項**: Fogelの経歴はCVSからSubversionへの連続性を示している。
- **記事での表現**: 「Karl Fogelは1999年に『Open Source Development with CVS』を出版した。CVSの内部を知り尽くした著者が、CVSの限界をも知り尽くしていたのは当然のことだった」

## 4. 「CVS done right」というモットー

- **結論**: Subversionは「CVSを正しく作り直す」ことを目標に掲げた。「CVS done right」という表現は広く使われたが、公式なスローガンというよりコミュニティで自然発生的に広まった。Hacker Newsでの議論でも「Subversion used to say, 'CVS done right.'」と言及されている。SVN Bookは「CVSの上位互換」として設計されたことを明記している。
- **一次ソース**: SVN Book; Hacker News discussion
- **URL**: <https://news.ycombinator.com/item?id=24743958>, <https://svnbook.red-bean.com/en/1.8/svn.intro.whatis.html>
- **注意事項**: Linus Torvaldsは後にこのスローガンを批判し、「CVSを正しくやるという目標設定自体が限界だった」と述べた。
- **記事での表現**: 「"CVS done right"——この言葉がSubversionのコミュニティで自然に広まった。CVSの問題を正しく解決する。それがSubversionの明確なゴールだった」

## 5. Subversionの開発マイルストーン

- **結論**:
  - Milestone 1（2000年10月20日）: 基本的な作業コピー操作。XMLファイルを使ったcheckout/update/commit
  - Milestone 2（2001年5月15日）: WebDAVレイヤーを介したcheckout/update/commit
  - Milestone 3（2001年8月30日）: セルフホスティング達成。14ヶ月のコーディング後、8月31日にSubversion開発者はCVSの使用を停止し、Subversion自身でソースコードを管理し始めた
  - Version 1.0（2004年2月23日）: 正式リリース
- **一次ソース**: Subversion Release History (subversion.apache.org); SVN Book History section
- **URL**: <https://subversion.apache.org/docs/release-notes/release-history.html>, <https://docs.huihoo.com/subversion/1.2/svn.intro.history.html>
- **注意事項**: セルフホスティングの日付は8月30日（Milestone 3の公式日付）と8月31日（SVN Bookの記述）で微妙に異なる。Milestone 3の日付を採用する。
- **記事での表現**: 「2001年8月、開発開始から14ヶ月でSubversionはセルフホスティングを達成した。Subversion開発チームはCVSの使用を停止し、自分たちのツールで自分たちのソースコードを管理し始めた」

## 6. Subversionのアトミックコミット

- **結論**: SubversionはCVSにはなかったアトミックコミットを実現した。「アトミックトランザクション」とは、リポジトリへのすべての変更が適用されるか、まったく適用されないかのどちらかであることを意味する。CVSではコミット中にネットワーク障害が発生すると、一部のファイルだけがコミットされた状態になる可能性があった。
- **一次ソース**: SVN Book, "Version Control the Subversion Way"
- **URL**: <https://svnbook.red-bean.com/en/1.6/svn.basic.in-action.html>
- **注意事項**: アトミックコミットはSubversionの最も重要な改善点の一つ。
- **記事での表現**: 「CVSでは、10個のファイルをコミット中にネットワークが切れると、5個だけがコミットされた壊れた状態になりうる。Subversionでは、全てが成功するか、全てが失敗するか——中間状態は存在しない」

## 7. Subversionのリビジョン番号設計

- **結論**: Subversionはリポジトリ全体に対して単一の連番リビジョン番号を割り当てる。各リビジョンはリポジトリのツリー全体のスナップショットを表す。初期リビジョンはゼロで、空のルートディレクトリのみ。CVSがファイルごとに独立したリビジョン番号を持っていたのとは根本的に異なる。
- **一次ソース**: SVN Book, "Revisions"; SVN Book, "Version Control the Subversion Way"
- **URL**: <https://svnbook.red-bean.com/en/1.6/svn.basic.in-action.html>
- **注意事項**: 連番リビジョンは集中型だからこそ可能な設計。分散型では原理的に不可能。
- **記事での表現**: 「Subversionのリビジョン番号はリポジトリ全体に対して一意に割り当てられる。リビジョン234は、その時点のリポジトリの完全な状態を表す」

## 8. Apache/WebDAV（mod_dav_svn）とsvnserveの二つのプロトコル

- **結論**: Subversionは二つのネットワークプロトコルをサポートした。(1) Apache httpdのmod_dav_svnモジュールによるWebDAV/DeltaVプロトコル（HTTP/HTTPS上）。(2) svnserveプロセスによるカスタムプロトコル（svn://、またはSSHトンネルのsvn+ssh://）。DeltaVはRFC 3253で定義されたWebDAVの拡張。しかしSubversionは最終的にDeltaVの完全サポートを断念し、独自のHTTPベースプロトコルに移行した。
- **一次ソース**: SVN Book, "httpd, the Apache HTTP Server"; SVN Book, "WebDAV and Autoversioning"; RFC 3253
- **URL**: <https://svnbook.red-bean.com/en/1.7/svn.serverconfig.httpd.html>, <https://datatracker.ietf.org/doc/html/rfc3253>
- **注意事項**: Apache httpd + mod_dav_svn構成は、既存のApacheインフラに乗れるという利点があった。
- **記事での表現**: 「Subversionの設計者はApacheをネットワークサーバとして採用した。WebDAVモジュールがすでに存在していたからだ。HTTPという既知のプロトコルを使うことで、ファイアウォールの問題を回避できた」

## 9. FSFS vs Berkeley DB（BDB）

- **結論**: 当初SubversionはBerkeley DB（BDB）を唯一のストレージバックエンドとして採用。BDBは、オープンソースライセンス、トランザクションサポート、信頼性、パフォーマンス、APIのシンプルさを理由に選ばれた。FSFS（Filesystem on top of Filesystem）はSubversion 1.1（2004年9月29日）で導入され、Subversion 1.2でデフォルトになった。Subversion 1.8でBDBは公式に非推奨となった。
- **一次ソース**: SVN Book, "The Subversion Repository, Defined"; Subversion 1.1 Release Notes; Subversion 1.2 Release Notes
- **URL**: <https://svnbook.red-bean.com/en/1.8/svn.reposadmin.basics.html>, <https://subversion.apache.org/docs/release-notes/1.1.html>, <https://subversion.apache.org/docs/release-notes/1.2.html>
- **注意事項**: BDBはプロセスクラッシュ時にリポジトリが壊れるリスクがあった。FSFSは透過的なファイルとしてOSのファイルシステム上に保存されるため、デバッグや復旧が容易だった。
- **記事での表現**: 「FSFSは"Filesystem on top of Filesystem"——OSのファイルシステム上に、バージョン管理されたファイルシステムを構築する。BDBの不透明なデータベースコンテナとは対照的に、FSFSのリポジトリは通常のファイルとして目に見える」

## 10. Subversionのディレクトリバージョニングとリネーム対応

- **結論**: SubversionはCVSとは異なり、ファイルだけでなくディレクトリ、コピー、リネーム、削除/復活もバージョン管理する。CVSはファイルの内容のみを追跡し、ディレクトリの変更は記録しなかった。CVSでのリネームは手動操作が必要で、履歴が分断された。
- **一次ソース**: SVN Book; Apache Subversion Wikipedia article
- **URL**: <https://en.wikipedia.org/wiki/Apache_Subversion>, <https://svnbook.red-bean.com/en/1.8/svn.intro.whatis.html>
- **注意事項**: Subversionのリネーム対応は内部的には「コピー+削除」であり、完全な移動追跡ではない。この制限は後のバージョンでも残っている。
- **記事での表現**: 「Subversionはディレクトリツリーの変更を記録する。ファイルの追加、削除、リネーム、ディレクトリの構造変更——CVSでは追跡できなかったこれらの操作が、すべて履歴に残る」

## 11. Subversionのブランチとタグ——cheap copy設計

- **結論**: Subversionにはブランチやタグのための専用コマンドがない。代わりに「cheap copy」（安価なコピー）メカニズムを使う。`svn copy`コマンドでディレクトリをコピーすると、内部的にはUNIXのハードリンクに似たリンクが作成され、実データは複製されない。慣習として/trunk, /branches, /tagsディレクトリ構造が推奨される。
- **一次ソース**: SVN Book, "Using Branches"; TortoiseSVN documentation
- **URL**: <https://svnbook.red-bean.com/en/1.7/svn.branchmerge.using.html>, <https://tortoisesvn.net/docs/release/TortoiseSVN_en/tsvn-dug-branchtag.html>
- **注意事項**: ブランチ＝ディレクトリコピーという設計は、技術的にはエレガントだが、ブランチの「意味」をツールが理解しないという問題を生んだ（マージ追跡の困難さ）。
- **記事での表現**: 「Subversionのブランチはディレクトリのコピーに過ぎない。`svn copy trunk branches/feature-x`と打てば、それがブランチだ。データは複製されない——内部リンクが張られるだけだ」

## 12. Subversion 1.0リリースとApache移管

- **結論**: Subversion 1.0は2004年2月23日にリリース。2009年11月にApache Incubatorに提出。2010年2月17日にApache Top-Level Projectに昇格。「Apache Subversion」と改称された。
- **一次ソース**: Subversion Release History; ASF Blog
- **URL**: <https://subversion.apache.org/docs/release-notes/release-history.html>, <https://news.apache.org/foundation/entry/the-apache-software-foundation-announces58>
- **注意事項**: CollabNetからASFへの移管は、Subversionのガバナンスの成熟を示す重要な出来事。
- **記事での表現**: 「2004年2月23日、Subversion 1.0がリリースされた。開発開始から約4年。CVSの後継としての約束を果たす準備が整った」
