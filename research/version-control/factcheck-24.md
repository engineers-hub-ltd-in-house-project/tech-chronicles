# ファクトチェック記録：第24回「git ありきの世界に改めて問う——あなたは何を選ぶか」

## 1. Stack Overflow Developer Survey 2025——Git使用率

- **結論**: 2025年のStack Overflow Developer Surveyで、93%以上の開発者がGitを使用していると回答。177カ国から49,000件以上の回答を収集。2016年の87.1%から着実に上昇。GitHubが最も人気のあるコード管理・コラボレーションツール（81%）。
- **一次ソース**: Stack Overflow Developer Survey 2025
- **URL**: <https://survey.stackoverflow.co/2025/>, <https://rhodecode.com/blog/156/version-control-systems-popularity-in-2025>
- **注意事項**: 調査はオンライン回答者のバイアスがあり、企業内のSVN利用者などは過小評価されている可能性がある。
- **記事での表現**: 「2025年のStack Overflow Developer Surveyによれば、開発者の93%以上がGitを使用している」

## 2. GitHub開発者数——1億人突破

- **結論**: 2025年初頭にGitHubの開発者数が1億人を突破。過去1年で3,600万人以上の新規開発者が参加（平均で毎秒1人以上）。インドが最大の新規登録国（全新規アカウントの14%、520万人以上）。2025年6月にリポジトリ数が10億を突破。
- **一次ソース**: GitHub Octoverse 2025, GitHub Innovation Graph
- **URL**: <https://octoverse.github.com/>, <https://github.com/about>
- **注意事項**: アカウント数≠アクティブ開発者数。ボットや重複アカウントを含む可能性。
- **記事での表現**: 「2025年、GitHubの登録開発者数は1億人を超えた。リポジトリ数は10億に達している」

## 3. Everett Rogers「イノベーションの普及」（1962年）

- **結論**: Everett Rogersが1962年に著書『Diffusion of Innovations』で体系化。イノベーションの普及を5つの採用者カテゴリ（イノベーター、アーリーアダプター、アーリーマジョリティ、レイトマジョリティ、ラガード）で説明。普及速度に影響する5つの特性：相対的優位性、互換性、複雑性、試行可能性、観察可能性。6,000以上の研究で検証済み。
- **一次ソース**: Rogers, Everett M. "Diffusion of Innovations." Free Press, 1962.
- **URL**: <https://en.wikipedia.org/wiki/Diffusion_of_innovations>
- **注意事項**: 第5版（2003年）が最終版。Rogersは2004年に逝去。
- **記事での表現**: 「Everett Rogersが1962年に体系化した『イノベーションの普及』理論は、技術がどのように社会に浸透するかを5段階の採用者カテゴリで説明する」

## 4. Richard Gabriel「Worse is Better」（1989年）

- **結論**: Richard P. Gabrielが1989年のエッセイ「Lisp: Good News, Bad News, How to Win Big」の中で提唱。「New Jersey style」とも呼ばれる。実装のシンプルさがインターフェースの正しさよりも重要であるという設計哲学。1991年にJamie ZawinskiがLucid Inc.のファイルから発見し広めた。後にGabriel自身が「このアドバイスは腐食性だ。若者の精神を歪める」と述懐。
- **一次ソース**: Gabriel, Richard P. "Lisp: Good News, Bad News, How to Win Big." 1989.
- **URL**: <https://www.dreamsongs.com/WorseIsBetter.html>, <https://www.jwz.org/doc/worse-is-better.html>
- **注意事項**: UNIXとCの成功をLisp/MITアプローチとの対比で論じたもの。Gitの設計思想とも関連する。
- **記事での表現**: 「Richard Gabrielが1989年に提唱した『Worse is Better』——実装のシンプルさがインターフェースの正しさに優先するという原則——は、UNIXの成功を説明すると同時に、Gitの設計思想にも通じる」

## 5. Chesterton's Fence（1929年）

- **結論**: G.K. Chestertonが1929年の著書『The Thing: Why I Am a Catholic』で提唱した原則。「なぜそこにフェンスがあるか分からないなら、撤去してはならない」。改革者に対する警告として、既存のものの理由を理解してから変更すべきだと主張。
- **一次ソース**: Chesterton, G.K. "The Thing: Why I Am a Catholic." 1929.
- **URL**: <https://fs.blog/chestertons-fence/>
- **注意事項**: ソフトウェアエンジニアリングでは「レガシーコードの変更前に既存の設計意図を理解せよ」という文脈で引用される。
- **記事での表現**: 「G.K. Chestertonが1929年に述べた原則——なぜそのフェンスがあるか理解するまで撤去するな——は、技術選定においても有効だ。既存のツールがなぜ選ばれたかを理解せずに置き換えてはならない」

## 6. Lindy Effect（リンディ効果）

- **結論**: Nassim Nicholas Talebが2012年の著書『Antifragile: Things That Gain from Disorder』で明示的に「Lindy Effect」と命名。非消耗品の将来の寿命期待値はその現在の年齢に比例するという法則。NYのLindy's Deliでコメディアンたちが非公式に理論化したのが起源。
- **一次ソース**: Taleb, Nassim Nicholas. "Antifragile: Things That Gain from Disorder." Random House, 2012.
- **URL**: <https://en.wikipedia.org/wiki/Lindy_effect>
- **注意事項**: Gitは2005年誕生で2026年現在21年。リンディ効果に従えば、さらに21年以上の寿命が期待される。ただしこれはヒューリスティックであり保証ではない。
- **記事での表現**: 「Nassim Talebが2012年に命名した『リンディ効果』——非消耗品の将来の寿命期待値はその現在の年齢に比例する——に従えば、21年間生き延びたGitはさらに長期間使われ続ける可能性が高い」

## 7. Joel Spolsky「Things You Should Never Do, Part I」（2000年）

- **結論**: Joel Spolskyが2000年4月6日に「Joel on Software」で公開。Netscapeがブラウザのコード全体を一から書き直す決定をしたことを「ソフトウェア企業が犯しうる最悪の戦略的ミス」と批判。全面書き直しによってNetscape 5.0が欠番となり、約3年のリリース遅延が発生し、Internet Explorerに対する競争優位を失った。
- **一次ソース**: Spolsky, Joel. "Things You Should Never Do, Part I." Joel on Software, April 6, 2000.
- **URL**: <https://www.joelonsoftware.com/2000/04/06/things-you-should-never-do-part-i/>
- **注意事項**: 「全面書き直しは常に悪い」という主張には反例もある（LinusのGit開発自体が成功した書き直しの一例）。
- **記事での表現**: 「Joel Spolskyが2000年に警告した通り、ゼロからの書き直しは多くの場合、致命的な結果を招く。だが、この原則にも例外はある」

## 8. Architecture Decision Records（ADR）——Michael Nygard（2011年）

- **結論**: Michael Nygardが2011年11月15日のブログ記事「Documenting Architecture Decisions」で提唱。アーキテクチャ上の決定を、タイトル・ステータス・コンテキスト・決定・結果の5項目で記録する短いテキストファイル。Nygard形式が事実上の標準となり、多くの組織で採用。
- **一次ソース**: Nygard, Michael. "Documenting Architecture Decisions." Cognitect Blog, November 15, 2011.
- **URL**: <https://www.cognitect.com/blog/2011/11/15/documenting-architecture-decisions>, <https://adr.github.io/>
- **注意事項**: ADRは「なぜそのツール・技術を選んだか」を記録する仕組みであり、第23回で論じた「歴史の保存（Why?）」と直接関連する。
- **記事での表現**: 「Michael Nygardが2011年に提唱したArchitecture Decision Records（ADR）は、技術的決定の理由を構造化して記録する手法だ」

## 9. Jujutsu（jj）の現状（2025-2026年）

- **結論**: Google社員が開発したGit互換の次世代VCS。2024年12月にjj-vcs GitHubオーガニゼーションに移行。活発な開発が継続中（最新はv0.24+）。git blameに相当するjj file annotateを実装。Git互換でありながら、ステージングエリア廃止、コンフリクトのファーストクラス化、オペレーションログなどの革新を導入。
- **一次ソース**: jj-vcs/jj GitHub repository, Jujutsu documentation
- **URL**: <https://github.com/jj-vcs/jj>, <https://docs.jj-vcs.dev/latest/>
- **注意事項**: まだ1.0未達。プロダクション利用には注意が必要。Google内部での利用状況は非公開。
- **記事での表現**: 「Jujutsuは、Git互換性を維持しながら、ステージングエリアの廃止やコンフリクトのファーストクラス化といった革新を導入している。2026年現在も活発な開発が続いている」

## 10. Sapling（Meta）の現状（2025-2026年）

- **結論**: Meta（旧Facebook）が開発・使用するスケーラブルなVCS。2022年11月にオープンソース化。Git互換のクライアントとして動作可能。Stacked Commitsワークフローが特徴。ただし、サーバーサイドコンポーネント（Mononoke, EdenFS）は外部利用未サポート。Meta外での大規模採用は限定的。
- **一次ソース**: Meta Engineering Blog, Sapling SCM
- **URL**: <https://sapling-scm.com/>, <https://engineering.fb.com/2022/11/15/open-source/sapling-source-control-scalable/>
- **注意事項**: Meta内部では数千万ファイル規模のモノレポで使用されているが、その環境はMononoke+EdenFSに依存している。
- **記事での表現**: 「Saplingは、Meta内部で巨大モノレポのスケーリングを実現しているが、そのフル機能を外部で再現するにはサーバーサイドコンポーネントが必要だ」

## 11. Git 3.0とSHA-256移行

- **結論**: Git 3.0は2026年末までのリリースを目指して開発中。最大の変更はSHA-1からSHA-256へのデフォルトハッシュアルゴリズム変更。Brian M. Carlsonが中心的に作業し、移行に必要な200-400パッチのうち約100が完了。Git自体・Dulwich・Forgejoは完全サポート。GitLab・go-git・libgit2は実験的サポート。GitHubはSHA-256サポートなし。
- **一次ソース**: Git project development discussions, DeployHQ Blog
- **URL**: <https://www.deployhq.com/blog/git-3-0-on-the-horizon-what-git-users-need-to-know-about-the-next-major-release>, <https://www.helpnetsecurity.com/2025/08/19/git-2-51-sha-256/>
- **注意事項**: SHA-1からSHA-256への移行は相互運用性を維持する計画。既存リポジトリが即座に壊れることはない。
- **記事での表現**: 「2026年末を目標にGit 3.0のリリースが計画されている。SHA-1からSHA-256への移行が最大の変更点だが、GitHubを含む主要なプラットフォームのSHA-256対応はまだ完了していない」

## 12. GitButlerの登場

- **結論**: Git上に構築されたモダンなバージョン管理クライアント。Tauri（Rust）+ Svelte（TypeScript）で実装。並行ブランチの同時利用、AI支援コミットメッセージ生成、無制限のundo機能を提供。2025年11月時点でGitHub Star 17,000以上。Fair Sourceライセンス（2年後にMIT）。
- **一次ソース**: GitButler GitHub repository, Butler's Log
- **URL**: <https://github.com/gitbutlerapp/gitbutler>, <https://blog.gitbutler.com/>
- **注意事項**: Gitの上位レイヤーとして動作するため、Gitを置き換えるものではなく、Gitの使用体験を改善するもの。
- **記事での表現**: 「GitButlerのようなツールは、Gitそのものを置き換えるのではなく、Gitの上に新しいワークフローを構築するアプローチを取っている」
