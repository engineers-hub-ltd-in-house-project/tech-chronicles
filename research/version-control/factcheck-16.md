# ファクトチェック記録：第16回「ブランチの革命——Gitが変えた開発フロー」

調査日：2026-02-16

---

## 1. Gitブランチの内部実装——41バイトのポインタファイル

- **結論**: Gitのブランチは`.git/refs/heads/{ブランチ名}`に格納される41バイトのテキストファイル（SHA-1ハッシュ40文字 + 改行1文字）である。ブランチの作成・削除はファイルの書き込み・削除で完結し、定数時間で完了する
- **一次ソース**: Chacon, S. and Straub, B., "Git Internals - Git References." Pro Git, 2nd Edition
- **URL**: <https://git-scm.com/book/en/v2/Git-Internals-Git-References>
- **注意事項**: Git 2.45.0以降、reftable形式（バイナリ形式の参照ストレージ）がサポートされているが、デフォルトは依然として従来のファイルベース形式
- **記事での表現**: 「Gitのブランチは、特定のcommitオブジェクトを指す41バイトのテキストファイルに過ぎない。SHA-1ハッシュ40文字と改行文字1文字。それだけだ」

## 2. HEAD の実装——symbolic refとdetached HEAD

- **結論**: `.git/HEAD`ファイルは通常`ref: refs/heads/{ブランチ名}`というsymbolic referenceを格納する。特定のcommitを直接チェックアウトした場合、SHA-1ハッシュを直接格納する（detached HEAD状態）
- **一次ソース**: Chacon, S. and Straub, B., "Git Internals - Git References." Pro Git, 2nd Edition
- **URL**: <https://git-scm.com/book/en/v2/Git-Internals-Git-References>
- **注意事項**: なし
- **記事での表現**: 「HEADは『今いるブランチ』を指すポインタのポインタだ」

## 3. Git-flow——Vincent Driessen、2010年1月5日

- **結論**: Vincent Driessenが2010年1月5日にnvie.comで"A successful Git branching model"を公開。main/develop/feature/release/hotfixの5種類のブランチを定義したワークフロー。2020年3月5日に"Note of reflection"を追記し、継続的デリバリー環境ではGitHub Flowなどのよりシンプルなワークフローを推奨すると記載
- **一次ソース**: Driessen, V., "A successful Git branching model." nvie.com, 2010-01-05
- **URL**: <https://nvie.com/posts/a-successful-git-branching-model/>
- **注意事項**: 2020年の追記で「Web appのように継続的にデリバリーされるソフトウェアには向かない」と明言。「10年前に書いた当時はこのクラスのソフトウェアを想定していなかった」とのこと
- **記事での表現**: 「2010年1月5日、オランダのエンジニアVincent Driessenが、自身のブログnvie.comに"A successful Git branching model"という記事を公開した。この記事は、gitのブランチ戦略に『名前』を与えた最初のものとして広く知られることになる」

## 4. GitHub Flow——Scott Chacon、2011年8月31日

- **結論**: Scott Chaconが2011年8月31日に"GitHub Flow"と題したブログ記事を公開。mainブランチは常にデプロイ可能、featureブランチを作成してPull Requestでレビュー・マージするシンプルなモデル。Git-flowの複雑さへの対抗として提案された
- **一次ソース**: Chacon, S., "GitHub Flow." scottchacon.com, 2011-08-31
- **URL**: <https://scottchacon.com/2011/08/31/github-flow>
- **注意事項**: Git-flowの複雑さが動機。「git-flowは多くの開発チームが実際に必要とするよりも複雑」と指摘
- **記事での表現**: 「翌2011年8月、GitHubの共同創業者Scott Chaconが"GitHub Flow"を提唱した。Git-flowの複雑さに対するアンチテーゼだった」

## 5. CVSのブランチ実装——RCSベースのタグ方式

- **結論**: CVSのブランチはRCSファイルの番号体系に基づく。ブランチ作成時に`cvs tag -b`でRCS番号（例: 1.15.0.2）が付与される。ブランチ上のリビジョンは1.15.2.1, 1.15.2.2と採番される。ブランチ作成にはリポジトリ内の全ファイルにタグを付ける操作が必要で、ファイル数に比例した時間がかかる。マージ追跡機能がなく、どのリビジョンがマージ済みかを手動で管理する必要があった
- **一次ソース**: GNU CVS Manual, "CVS--Concurrent Versions System - Branching and merging"
- **URL**: <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Creating-a-branch.html>
- **注意事項**: CVSのブランチは各ファイルが独立してブランチ番号を持つため、「リポジトリ全体」のブランチという概念が弱い
- **記事での表現**: 「CVSのブランチは、RCSファイルの番号体系に埋め込まれた概念だった。ブランチの作成にはリポジトリ内の全ファイルへのタグ付けが必要で、その時間はファイル数に比例した」

## 6. SVNのブランチ実装——ディレクトリコピー方式

- **結論**: SVNのブランチは`svn copy`コマンドによるディレクトリコピーとして実装される。内部ではCopy-on-Write方式の「cheap copy」で、実際のデータ複製は行わず定数時間で完了する。ブランチは通常の`branches/`ディレクトリ下のサブディレクトリとして見える。ただしマージ追跡は当初存在せず、SVN 1.5（2008年6月）で`svn:mergeinfo`プロパティとして導入された
- **一次ソース**: Collins-Sussman, B. et al., "Version Control with Subversion - Using Branches"
- **URL**: <https://svnbook.red-bean.com/en/1.7/svn.branchmerge.using.html>
- **注意事項**: svn copyはサーバ側で定数時間だが、クライアント側での操作（作業コピー全体のコピー）は線形時間
- **記事での表現**: 「SVNはブランチを『ディレクトリコピー』として実装した。svn copyはサーバ内部でCopy-on-Writeを用い、定数時間で完了する。CVSに比べれば格段に高速だ。だが、それでもgitの41バイトファイル書き込みには及ばない」

## 7. 3-way mergeアルゴリズムの歴史

- **結論**: 3-way mergeは、2つのファイルと共通祖先（common ancestor）を比較するマージ手法。diffユーティリティはJames W. HuntとM. Douglas McIlroyがBell Labsで1976年に開発。patchプログラムはLarry Wallが1985年に作成。diff3（GNU実装）が3-way textマージの標準実装。CVSはdiff3のスクリプトとして始まった
- **一次ソース**: Wikipedia, "Merge (version control)"
- **URL**: <https://en.wikipedia.org/wiki/Merge_(version_control)>
- **注意事項**: diff3はライン単位のマージであり、同じ行を両方が変更した場合はコンフリクトとなる
- **記事での表現**: 「3-way mergeの原理は、2つの変更されたバージョンとそれらの共通祖先を比較する。共通祖先からの差分が競合しなければ自動マージ、競合すればコンフリクトとして人間に委ねる」

## 8. Git recursive mergeストラテジー——Fredrik Kuivinen、2005年9月

- **結論**: recursive mergeストラテジーはFredrik Kuivinenが2005年にPythonスクリプトとして実装。当初は"fredrik"ストラテジーと呼ばれていたが、2005年9月13日にJunio C Hamanoのコミット（e4cf17c）で"recursive"にリネームされた。Git v0.99.9kからv2.33.0までデフォルトのマージストラテジーだった
- **一次ソース**: Git commit e4cf17ce0d by Junio C Hamano, "Rename the 'fredrik' merge strategy to 'recursive'", 2005-09-13
- **URL**: <https://github.com/git/git/commit/e4cf17ce0db2dab7c9525a732f86c5e3df3b4ed0>
- **注意事項**: 共通祖先が複数存在する場合、共通祖先同士を再帰的にマージして仮想的な共通祖先を構築する点がrecursiveの名の由来
- **記事での表現**: 「recursive mergeの名は、共通祖先が複数存在する場合の振る舞いに由来する。共通祖先が2つ以上あるとき、recursiveストラテジーはそれらを再帰的にマージして仮想的な共通祖先を作り出す」

## 9. Git merge-ort——Elijah Newren、Git 2.33（2021年8月）

- **結論**: merge-ortストラテジーはElijah Newrenがrecursiveストラテジーのスクラッチ書き直しとして開発。"ort"は"Ostensibly Recursive's Twin"の頭字語。Git 2.33（2021年8月）で導入。特定のケースでrecursiveの500〜9,000倍高速。Git 2.34（2021年11月）でデフォルトストラテジーに昇格。Git 2.50でrecursiveストラテジーは内部的にortにリダイレクトされた
- **一次ソース**: The Register, "Git 2.33 released with new optional merge process", 2021-08-17
- **URL**: <https://www.theregister.com/2021/08/17/git_233/>
- **注意事項**: 500〜9,000倍はrebase操作における特定の「非常にトリッキーな」ケースでの測定値。一般的なマージでの改善幅はケースバイケース
- **記事での表現**: 「2021年、Elijah Newrenによるmerge-ort——"Ostensibly Recursive's Twin"——がrecursiveストラテジーを置き換えた。特定のケースで500〜9,000倍の高速化を達成したこの新ストラテジーは、Git 2.34でデフォルトとなった」

## 10. git rebase の誕生——2005年6月、Linus TorvaldsとJunio Hamanoの会話

- **結論**: rebaseの概念は2005年6月、LKMLでのLinus TorvaldsとJunio Hamanoの会話から生まれた。Torvaldsが「開発者が本当にやりたいマージは、ローカルのコミットを共通の親からリモートの新しいHEADの上に『re-base』することだ」とコメントし、Hamanoが`git cherry`を使った"re-base"スクリプトを実装した。これがバージョン管理における"rebase"という用語の初出とされる
- **一次ソース**: GitButler Blog, "20 years of Git. Still weird, still wonderful.", 2025
- **URL**: <https://blog.gitbutler.com/20-years-of-git>
- **注意事項**: Junio Hamanoは2005年7月26日にLinusからGitメンテナの役割を引き継いだ
- **記事での表現**: 「2005年6月、LinusとJunio Hamanoのメーリングリスト上の会話から、rebaseという概念が生まれた。開発者が本当にやりたいのは、ローカルの変更をリモートの最新状態の上に『re-base（基盤を置き直す）』することだ——というLinusの洞察が起点だった」

## 11. トランクベース開発の歴史

- **結論**: トランクベース開発の思想はCVS/SVN時代からの「全員が単一トランクで作業する」モデルに遡る。Googleは初期からPerforceを使い、35,000人以上の開発者が単一の巨大モノレポでトランクベース開発を実践。Martin Fowlerが2000年に"Continuous Integration"記事を公開し、CI/CDとの連携が理論化された。2018年のDORA（DevOps Research and Assessment）レポートでトランクベース開発がハイパフォーマンスチームの特徴として言及
- **一次ソース**: Hammant, P., "Google's Scaled Trunk-Based Development", 2013; trunkbaseddevelopment.com
- **URL**: <https://paulhammant.com/2013/05/06/googles-scaled-trunk-based-development/>, <https://trunkbaseddevelopment.com/>
- **注意事項**: Googleの35,000人はPaul Hammantの2013年記事時点の数字。現在はさらに多い可能性がある
- **記事での表現**: 「トランクベース開発は、実はCVS/SVN時代から存在した『全員がトランクで作業する』という素朴なモデルの再発見でもある。Googleは35,000人以上の開発者が単一のモノレポでトランクベース開発を実践している」

## 12. Octopus mergeとLinuxカーネル

- **結論**: octopus mergeは3つ以上のブランチを同時にマージする戦略。コンフリクトがない場合にのみ成功する。Linuxカーネルのgit履歴では649,306コミット中46,930（7.2%）がマージ、うち1,549（マージの3.3%）がoctopusマージ。66個の親を持つコミットが最大記録
- **一次ソース**: Destroy All Software Blog, "The Biggest and Weirdest Commits in Linux Kernel Git History", 2017
- **URL**: <https://www.destroyallsoftware.com/blog/2017/the-biggest-and-weirdest-commits-in-linux-kernel-git-history>
- **注意事項**: 上記の統計は2017年時点のもの
- **記事での表現**: 「Linuxカーネルの履歴では、マージコミットの約3.3%がoctopusマージだ。66個の親を持つコミットすら存在する」

## 13. reftable形式——Git 2.45.0

- **結論**: reftable形式はShawn Pearce（JGit開発者、元Google）が設計したバイナリ形式の参照ストレージ。Git 2.45.0（2024年4月）で導入。従来のloose refs（ファイルベース）やpacked-refsファイルに代わる効率的な形式。大量のref操作で大幅な性能向上（100万refからの削除: files形式229.8ms → reftable 2.0ms）
- **一次ソース**: Git SCM, "reftable Documentation"
- **URL**: <https://git-scm.com/docs/reftable>
- **注意事項**: Git 2.45.0時点ではオプション機能。デフォルトは従来のfiles形式
- **記事での表現**: 「Git 2.45.0で導入されたreftable形式は、Shawn Pearceが設計したバイナリ形式の参照ストレージだ。大量のブランチを扱うリポジトリで劇的な性能向上をもたらす」
