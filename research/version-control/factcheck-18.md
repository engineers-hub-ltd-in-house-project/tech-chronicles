# ファクトチェック記録：第18回「分散の代償——Gitのトレードオフ」

## 1. Git LFSの発表と開発

- **結論**: Git LFS（Large File Storage）は2015年4月、Git Merge 2015カンファレンスでGitHub開発者のRick Olsonにより発表された。GitHubがクライアントとサーバのリファレンス実装をオープンソースとして公開。Git LFSはAtlassian、GitHub、その他のオープンソースコントリビュータによって共同開発された
- **一次ソース**: Git Rev News Edition 2, April 15th, 2015; GitHub git-lfs repository
- **URL**: <https://git.github.io/rev_news/2015/04/05/edition-2/>, <https://github.com/git-lfs/git-lfs>
- **注意事項**: Git LFS以前にもgit-annexなどの代替ソリューションが存在した
- **記事での表現**: 「2015年4月、GitHub開発者のRick OlsonがGit Merge 2015でGit LFSを発表した」

## 2. Git LFSのアーキテクチャ — ポインタファイルとsmudge/cleanフィルタ

- **結論**: Git LFSはGitのsmudge/cleanフィルタ機構を利用する。cleanフィルタはファイル追加時にバイナリをローカルLFSストアに保存し、ポインタファイル（バージョン、OID sha256ハッシュ、サイズを含むテキストファイル）をステージングする。smudgeフィルタはチェックアウト時にポインタファイルを検出し、ローカルLFSストアまたはリモートサーバから実体を取得して展開する
- **一次ソース**: git-lfs.com; Ken Muse, "The Secret Life of Git Large File Storage"
- **URL**: <https://git-lfs.com/>, <https://www.kenmuse.com/blog/secret-life-of-git-lfs/>
- **注意事項**: ポインタファイルは約130バイト程度の小さなテキストファイル
- **記事での表現**: 「Git LFSはGitのsmudge/cleanフィルタを利用し、大きなバイナリをポインタファイルに置き換える」

## 3. Gitの内容アドレス可能ストレージと大きなファイルの問題

- **結論**: GitはSHA-1（将来的にSHA-256）ハッシュによる内容アドレス可能ストレージを採用。ファイルの内容が変更されるたびに新しいblobオブジェクトが完全に生成される。packファイルでのデルタ圧縮は事後的な最適化であり、バイナリファイルのデルタ圧縮は効率が悪い。巨大バイナリはオブジェクトストア全体を肥大化させ、クローンとフェッチの負担を増大させる
- **一次ソース**: Git SCM, "Git Internals - Packfiles"; Git SCM, pack-heuristics Documentation
- **URL**: <https://git-scm.com/book/en/v2/Git-Internals-Packfiles>, <https://git-scm.com/docs/pack-heuristics>
- **注意事項**: テキストファイルはデルタ圧縮で効率よく格納できるが、バイナリは差分が大きく圧縮率が低い
- **記事での表現**: 「内容アドレス可能ストレージは全てのオブジェクトをハッシュで一意に識別する。バイナリファイルの1バイトの変更でも、新しいblobオブジェクト全体が生成される」

## 4. Microsoft WindowsリポジトリのGit移行（2017年）

- **結論**: 2017年5月、MicrosoftはWindowsの開発をGitに移行したと発表。Windowsリポジトリは約350万ファイル、約300GBの規模。約4,000人のエンジニアのうち約3,500人がGitに移行。GVFSなしでは、クローンに12時間以上、チェックアウトに2-3時間、statusに10分かかっていた。GVFSにより、クローンは数分、チェックアウトは30秒、statusは4-5秒に短縮
- **一次ソース**: TechCrunch, "Microsoft now uses Git and GVFS to develop Windows", 2017-05-24; Brian Harry's Blog, "The largest Git repo on the planet"
- **URL**: <https://techcrunch.com/2017/05/24/microsoft-now-uses-git-and-gvfs-to-develop-windows/>, <https://devblogs.microsoft.com/bharry/the-largest-git-repo-on-the-planet/>
- **注意事項**: GVFSはGit Virtual File Systemの略だったが、GNOMEのGVFSとの名称衝突により2018年にVFS for Gitに改名
- **記事での表現**: 「Microsoftは2017年にWindowsの開発をGitに移行した。約350万ファイル、約300GBのリポジトリである」

## 5. VFS for Git（旧GVFS）とScalar

- **結論**: Microsoftは2017年2月にGVFS（後のVFS for Git）を発表。ファイルシステムを仮想化し、必要なファイルだけをダウンロードする。2018年6月にGNOME GVFSとの名称衝突からVFS for Gitに改名。VFS for Git 2.32でメンテナンスモードに入り、後継としてScalarが推奨される。ScalarはGit 2.38（2022年10月）で本体に統合された
- **一次ソース**: Azure DevOps Blog, "Announcing GVFS"; Azure DevOps Blog, "Introducing Scalar"; Phoronix, "Git 2.38 Adds Microsoft's Scalar"
- **URL**: <https://devblogs.microsoft.com/devops/announcing-gvfs-git-virtual-file-system/>, <https://devblogs.microsoft.com/devops/introducing-scalar/>, <https://www.phoronix.com/news/Git-2.38-Released>
- **注意事項**: Scalarは仮想ファイルシステムを使わず、partial clone、sparse-checkout、FSMonitor等の既存Git機能を組み合わせる
- **記事での表現**: 「VFS for Git（旧GVFS）は仮想ファイルシステムによる解決策だったが、現在はScalar（Git 2.38で本体統合）に移行している」

## 6. Googleのモノレポ Piper

- **結論**: 2015年時点でGoogleのリポジトリは10億ファイル、3,500万コミット、86TBのデータ、20億行のコードを含む。GoogleはPerforceの再実装であるPiperを開発し、10のデータセンターにPaxosアルゴリズムで分散配置。Gitは使用していない
- **一次ソース**: Potvin, R. and Levenberg, J., "Why Google Stores Billions of Lines of Code in a Single Repository", Communications of the ACM, 2016
- **URL**: <https://cacm.acm.org/research/why-google-stores-billions-of-lines-of-code-in-a-single-repository/>
- **注意事項**: Googleのモノレポは「Gitでは不可能な規模」の代表例
- **記事での表現**: 「Googleは2015年時点で86TB・20億行のコードを単一リポジトリで管理しているが、Gitではなく独自のPiperを使用している」

## 7. MetaのSapling

- **結論**: Metaは2022年11月15日にSaplingをオープンソースとして公開。10年前にMercurialの拡張として開始され、独自のストレージフォーマット、ワイヤプロトコル、アルゴリズムを持つシステムに成長。数千万のファイル、数千万のコミット、数千万のブランチを持つMetaのモノレポをサポート。Gitリポジトリのクローンと操作にも対応
- **一次ソース**: Meta Engineering Blog, "Sapling: Source control that's user-friendly and scalable", 2022-11-15
- **URL**: <https://engineering.fb.com/2022/11/15/open-source/sapling-source-control-scalable/>
- **注意事項**: Mercurial由来のため、gitとは異なるコマンド体系だが、Git互換モードを持つ
- **記事での表現**: 「Metaは2022年にSaplingを公開した。Mercurial拡張として始まり、独自システムに発展した」

## 8. Git sparse-checkout cone mode（Git 2.25）

- **結論**: Git 2.25.0（2020年1月13日リリース）でsparse-checkoutコマンドが大幅改善され、cone modeが導入された。cone modeはディレクトリ単位で指定を行い、ハッシュベースのアルゴリズムでパターンマッチングを高速化する。非cone modeの複雑なパターン指定に比べ高速
- **一次ソース**: InfoQ, "Git 2.25 Improves Support for Sparse Checkout", 2020-01
- **URL**: <https://www.infoq.com/news/2020/01/git-2-25-sparse-checkout/>
- **注意事項**: Git 2.37.0（2022年6月）でcone modeがデフォルトに変更
- **記事での表現**: 「Git 2.25（2020年1月）でsparse-checkoutのcone modeが導入され、ディレクトリ単位の高速なパターンマッチングが可能になった」

## 9. Git partial clone（Git 2.19）

- **結論**: partial cloneはGit 2.19（2018年9月）前後で段階的に導入された。`--filter=blob:none`オプションでblobをダウンロードせずにクローンし、必要時に遅延取得する。平均88.6%のクローン時間削減、最大のリポジトリでは99%以上の削減を達成
- **一次ソース**: Git SCM, partial-clone Documentation (2.19.0); GitLab Blog, "How Git Partial Clone lets you fetch only the large file you need"
- **URL**: <https://git-scm.com/docs/partial-clone/2.19.0>, <https://about.gitlab.com/blog/partial-clone-for-massive-repositories/>
- **注意事項**: partial cloneはサーバ側のサポートも必要。GitHub、GitLab、Azure DevOpsが対応
- **記事での表現**: 「Git 2.19前後でpartial clone機能が導入され、blobの遅延取得が可能になった」

## 10. Git shallow clone

- **結論**: shallow clone（`git clone --depth N`）はGitの初期から存在する機能。指定した深さの履歴のみをダウンロードする。CI/CDパイプラインで広く使用。大規模リポジトリで最大10倍のクローン高速化。ただし、git bisect等の全履歴を必要とする操作に制限がある
- **一次ソース**: Git SCM, shallow Documentation; Perforce, "How to Use Git Shallow Clone"
- **URL**: <https://git-scm.com/docs/shallow>, <https://www.perforce.com/blog/vcs/git-beyond-basics-using-shallow-clones>
- **注意事項**: `--unshallow`で後から完全な履歴を取得可能
- **記事での表現**: 「shallow cloneは履歴の深さを制限してクローン時間を大幅に短縮する」

## 11. Gitのパスベースアクセス制御の制限

- **結論**: Gitは分散型であるため、リポジトリにアクセスできるユーザーは全ての内容を読める。パスベースの読み取り制限は原理的に不可能。Subversionはsvnserve/Apache + authzで細粒度のパスベースアクセス制御を実現しており、ディレクトリ・ファイル単位で読み書き権限を設定できる。Gitでの代替策はリポジトリの分割（git submodule等）
- **一次ソース**: SVN Book, "Path-Based Authorization" (1.7); GitHub Community Discussion
- **URL**: <https://svnbook.red-bean.com/en/1.7/svn.serverconfig.pathbasedauthz.html>
- **注意事項**: GitHub、GitLabはブランチ保護ルールで書き込みを制限できるが、読み取り制限はリポジトリ単位
- **記事での表現**: 「Gitは分散型の設計上、パスベースの読み取りアクセス制御を提供できない。Subversionはauthzで細粒度のパスベース権限を実現していた」

## 12. モノレポ vs マルチレポのトレードオフ

- **結論**: モノレポの利点は統一的な依存関理、リポジトリ横断的なリファクタリング、コード共有と可視性。欠点はCIパイプラインの複雑化、パフォーマンス問題、アクセス制御の困難。マルチレポの利点はプロジェクト分離、独立バージョニング、細粒度のセキュリティ。欠点は横断的リファクタリングの困難、依存関係管理の複雑化
- **一次ソース**: Thoughtworks, "Monorepo vs. multi-repo"; CircleCI Blog, "Benefits and challenges of monorepo development practices"
- **URL**: <https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/monorepo-vs-multirepo>, <https://circleci.com/blog/monorepo-dev-practices/>
- **注意事項**: Google、Meta、Microsoftはモノレポだが、いずれもGit標準機能では対応できず独自ツールを開発している
- **記事での表現**: 「モノレポの利点は一元管理と横断的変更の容易さだが、Gitの標準機能だけでは大規模モノレポを扱いきれない」
