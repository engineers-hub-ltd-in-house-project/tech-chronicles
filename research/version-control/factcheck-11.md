# ファクトチェック記録：第11回「Subversionは死んだのか？——今なお現役の理由」

調査日: 2026-02-15

---

## 1. Apache Subversion 最新バージョンとリリース状況

- **結論**: Subversion 1.14.0-LTSが2020年5月27日にリリースされ、2024年12月8日に1.14.5（バグ修正/セキュリティリリース、CVE-2024-46901対応）が最新。1.14.x系は継続的にメンテナンスされている
- **一次ソース**: Apache Subversion, "Release History"
- **URL**: <https://subversion.apache.org/docs/release-notes/release-history.html>
- **注意事項**: 1.14はLTS（Long Term Support）リリース。1.14.0以降のリリース歴: 1.14.1（2021-02-10）、1.14.2（2022-04-12）、1.14.3（2023-12-28）、1.14.4（2024-10-08）、1.14.5（2024-12-08）
- **記事での表現**: 「Subversion 1.14.0-LTSは2020年5月にリリースされ、2024年12月の1.14.5に至るまで、セキュリティ修正とバグ修正のリリースが継続されている」

## 2. Subversion 1.14の主要新機能（shelving/checkpointing）

- **結論**: Subversion 1.14ではPython 3サポート、実験的なshelving/checkpointing機能、svnadmin build-repcacheコマンド、改善されたコンフリクト解決（リネームされたファイルの編集を含むシナリオ対応）が導入された
- **一次ソース**: Apache Subversion, "1.14 LTS Release Notes"
- **URL**: <https://subversion.apache.org/docs/release-notes/1.14>
- **注意事項**: shelving/checkpointingは実験的機能（experimental）。shelving-v2とshelving-v3は1.10のシェルフと互換性なし。Unixシステムでは平文パスワード保存がデフォルトで無効化
- **記事での表現**: 「1.14ではshelving/checkpointing（実験的機能）が導入され、ネットワーク接続なしでも作業のスナップショットを保存・復元できるようになった。集中型VCSのオフライン制約を緩和する試みである」

## 3. Stack Overflow Developer Survey でのバージョン管理ツール利用率

- **結論**: Stack Overflow Developer Surveyによれば、開発者の93%がGitを使用。SVNは残りの少数派に含まれる。2025年時点ではGitの利用率は93.87%に上昇
- **一次ソース**: Stack Overflow Blog, "Beyond Git: The other version control systems developers use" (2023年1月)
- **URL**: <https://stackoverflow.blog/2023/01/09/beyond-git-the-other-version-control-systems-developers-use/>
- **注意事項**: SVN単体の具体的なパーセンテージは公開記事から明確に抽出できないが、Git以外の全VCSで約7%
- **記事での表現**: 「Stack Overflow Developer Surveyによれば、開発者の93%以上がGitを使用しており、SVNを含むその他のVCSは合計でも7%程度に過ぎない」

## 4. ゲーム業界でのSubversion/Perforce利用

- **結論**: ゲーム業界ではPerforceが主流（Epic Games自身がUE開発にPerforceを使用・推奨）。SVNはBlizzard等のレガシープロジェクト、中小規模スタジオ（5-50名）で利用継続。Unreal Engine 4/5はSVNをネイティブサポート。SVNはPerforceに対する無料の代替として位置づけられる
- **一次ソース**: Epic Games, "Collaboration and Version Control in Unreal Engine" / Execution Unit, "How I setup Subversion to work with Unreal" (2024年8月)
- **URL**: <https://dev.epicgames.com/documentation/en-us/unreal-engine/collaboration-and-version-control-in-unreal-engine> / <https://www.executionunit.com/blog/2024/08/21/how-i-setup-subversion-to-work-with-unreal/>
- **注意事項**: 2024 State of Game Technologyレポートでは回答者の69%がバージョン管理を使用
- **記事での表現**: 「ゲーム業界ではPerforceが業界標準だが、Subversionは中小規模スタジオにとってコスト面で魅力的な選択肢であり、Unreal Engineが公式にサポートしている」

## 5. Subversionのパスベースアクセス制御（authz）

- **結論**: mod_authz_svnモジュールによりApache HTTP Server上でパスベースの認可が可能。authzファイルでユーザー/グループごとにr（読取）/rw（読書）を設定。パスの階層構造に沿って権限が継承され、具体的なパスの指定が親ディレクトリの権限を上書きする
- **一次ソース**: SVN Book, "Path-Based Authorization"
- **URL**: <https://svnbook.red-bean.com/en/1.8/svn.serverconfig.pathbasedauthz.html>
- **注意事項**: パスベース認可は性能に影響する場合がある（サーバが各パスの権限を確認するコスト）。分散型VCSではリポジトリ全体が複製されるため、このレベルのパスベースアクセス制御は原理的に困難
- **記事での表現**: 「Subversionのauthzファイルによるパスベースアクセス制御は、ディレクトリ単位でユーザーごとのread/read-write権限を設定できる。分散型VCSでは原理的に実現が困難な機能であり、企業のガバナンス要件に直接応える」

## 6. svn:externalsの機能

- **結論**: svn:externalsはバージョン管理されたプロパティで、作業コピー内のサブディレクトリに外部リポジトリのURLをマッピングする。svn checkout/update時に自動的に外部リポジトリもチェックアウト/更新される。特定リビジョンへの固定も可能
- **一次ソース**: SVN Book, "Externals Definitions"
- **URL**: <https://svnbook.red-bean.com/en/1.7/svn.advanced.externals.html>
- **注意事項**: 外部作業コピーへのコミットは個別に実行する必要がある。SVN 1.5以降はファイル単位のexternalsも可能。サブディレクトリの一部だけを参照できる（Gitのsubmoduleではリポジトリ全体が対象）
- **記事での表現**: 「svn:externalsは外部リポジトリの特定パスを作業コピー内に自動的にチェックアウトする機能であり、リポジトリの一部分だけを参照できる点でgit submoduleよりも柔軟である」

## 7. git submoduleとsvn:externalsの比較

- **結論**: 主な違い: (1) git submoduleは特定コミットに固定（明示的にupdateが必要）、svn:externalsはupdate時に自動更新される、(2) git submoduleはリポジトリ全体を参照、svn:externalsはサブディレクトリを指定可能、(3) git submoduleはコミットハッシュで固定、svn:externalsはリビジョン指定も指定なし（最新追従）も可能
- **一次ソース**: Alex King, "Git Submodules are not SVN Externals" (2012年)
- **URL**: <https://alexking.org/blog/2012/03/05/git-submodules-vs-svn-externals>
- **注意事項**: git submoduleの制限を補うためにgit-externalやgit subtreeなどの代替ツールが存在
- **記事での表現**: 「svn:externalsはサブディレクトリ単位での参照が可能で、update時に自動更新される。git submoduleはリポジトリ全体を特定コミットに固定し、明示的な更新操作が必要。この設計の違いは、依存関係管理のワークフローに影響する」

## 8. Subversionのsparse checkout（部分チェックアウト）

- **結論**: Subversion 1.5で導入。--depthオプションでdepth-empty、depth-files、depth-immediates、depth-infinityの4段階を指定可能。depth設定は「sticky」で、一度設定すると作業コピーに記憶される。後から--set-depthで変更可能
- **一次ソース**: SVN Book, "Sparse Directories"
- **URL**: <https://svnbook.red-bean.com/en/1.8/svn.advanced.sparsedirs.html>
- **注意事項**: Gitのsparse-checkoutと類似する機能だが、SVNの方が先に実装（SVN 1.5は2008年、Gitのsparse-checkoutは2010年のGit 1.7.0で導入）
- **記事での表現**: 「Subversionのsparse checkoutは、リポジトリの一部のみをチェックアウトする機能で、大規模リポジトリの部分的な利用を可能にする」

## 9. Blender StudioのSVNからGit LFS移行とベンチマーク

- **結論**: Blender Studioは2023年5月にSVNのsunset（段階的廃止）を発表。理由: Git LFSの成熟、Giteaへの移行によりGitでバイナリ管理が実用的に。SVNはマニュアル、翻訳、ライブラリ、テストファイル等のバイナリリポジトリに使用されていた。ベンチマーク結果: Git LFS（.blend圧縮あり）が転送速度でSVNとvanilla Gitの双方を上回り、サーバサイズも同等
- **一次ソース**: Blender Developers Blog, "Sunsetting Subversion" (2023年5月15日) / Blender Studio Blog, "Benchmarking Version Control Solutions for Creative Collaboration"
- **URL**: <https://code.blender.org/2023/05/sunsetting-subversion/> / <https://studio.blender.org/blog/benchmarking-version-control-git-lfs-svn-mercurial/>
- **注意事項**: ベンチマークでvanilla Gitは大きなバイナリでgit addに1分以上、repackingで32GB RAM消費という問題あり。Mercurialは2GiB制限で大規模プロジェクトに不適合。SVNサーバサイズはSpringプロジェクトで247.9GB
- **記事での表現**: 「Blender Studioは2023年にSVNからGit LFSへの移行を開始した。ベンチマークではGit LFSが転送速度で優位だったが、vanilla GitはバイナリのRAM消費が問題となった」

## 10. Git LFSの制限とSVNのバイナリ処理との比較

- **結論**: Git LFSの主な制限: (1) ファイルの差分圧縮を行わず、バージョンごとにファイル全体を保存するためストレージコストが大きい、(2) 多くのGitホストがLFSストレージに追加料金を課す、(3) LFS使用時にはリポジトリの完全なコピーが全ユーザーに行き渡らない、(4) セットアップが各リポジトリ・ユーザーごとに必要。SVNは中央サーバで一元管理でき、差分保存も行う
- **一次ソース**: Assembla, "Git LFS: The Pocketbook Explanation" / Blender Studio benchmark
- **URL**: <https://get.assembla.com/blog/git-lfs/> / <https://studio.blender.org/blog/benchmarking-version-control-git-lfs-svn-mercurial/>
- **注意事項**: Git LFSは改善が進んでおり、2024年時点では多くのGitフロントエンドがLFSを標準サポート。ただしワークフローの複雑さは残る
- **記事での表現**: 「Git LFSはバイナリの差分圧縮を行わず、バージョンごとにファイル全体を保存する。ストレージコストとセットアップの複雑さは、SVNの中央集権的なバイナリ管理と比較した際の弱点である」

## 11. Subversionのファイルロック機能

- **結論**: svn lockコマンドでファイルの排他的編集権を取得可能。svn:needs-lockプロパティを設定すると、ロック未取得時にファイルが読み取り専用になる。バイナリファイルのように差分マージが不可能なファイルに特に有用。ロックの強制解除（breaking）も可能
- **一次ソース**: SVN Book, "Locking"
- **URL**: <https://svnbook.red-bean.com/en/1.7/svn.advanced.locking.html>
- **注意事項**: Git LFS Locksも同様の機能を提供するが、後発の実装であり、SVNのロック機能の方が成熟している
- **記事での表現**: 「Subversionのファイルロック機能は、バイナリファイルの同時編集を防止するlock-modify-unlockモデルを実現する。svn:needs-lockプロパティにより、ロックなしでの編集を自動的に防止できる」

## 12. Apache Software FoundationのSVNからGitへの移行

- **結論**: ASF自身がSubversionの開発母体でありながら、多くのASFプロジェクトがGitに移行。Apache Tomcatは2019年頃にGit移行を実施。ASFはinfra.apache.orgでSVN→Git移行ガイドを提供。svn2gitを使用した変換、gitbox.apache.orgへのプッシュ、旧SVNリポジトリの読み取り専用化という手順
- **一次ソース**: Apache Infrastructure, "SVN to Git migration"
- **URL**: <https://infra.apache.org/svn-to-git-migration.html>
- **注意事項**: ASFの全プロジェクトがGitに移行したわけではない。Subversion自体のソースコードリポジトリは依然としてSVNで管理されている
- **記事での表現**: 「Apache Software Foundation自身のプロジェクトも順次Gitに移行しているが、Subversion自体のソースコードは今もSVNで管理されている。これは象徴的な事実である」
