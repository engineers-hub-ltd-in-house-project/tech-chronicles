# ファクトチェック記録：第17回「マージ戦略の深淵——recursive, ort, octopus」

## 1. diff3アルゴリズムの起源

- **結論**: diff3はRandy Smithが1988年に開発した。3-way mergeアルゴリズムの標準実装として、CVS、Subversion、Gitなど広範なバージョン管理システムに採用されている
- **一次ソース**: Wikipedia, "diff3"; Khanna, Kunal, Pierce, "A Formal Investigation of Diff3", 2007
- **URL**: <https://en.wikipedia.org/wiki/Diff3>, <https://www.cis.upenn.edu/~bcpierce/papers/diff3-short.pdf>
- **注意事項**: diff3のcopyright表記は1988-1989、作者はRandy SmithとP. Heckel
- **記事での表現**: 「diff3ユーティリティは1988年にRandy Smithによって開発され、3-way mergeの標準実装となった」

## 2. resolveストラテジー（recursiveの前身）

- **結論**: resolveストラテジーはGitの初期デフォルトマージストラテジーだった。3-way mergeを用いるが、共通祖先が複数ある場合にそのうちの1つを選択する方式であり、criss-cross mergeの処理が不完全だった。recursiveストラテジーがGit v0.99.9kでデフォルトに昇格するまで使用された
- **一次ソース**: Git SCM, merge-strategies Documentation
- **URL**: <https://git-scm.com/docs/merge-strategies>
- **注意事項**: resolveは現在も`-s resolve`で利用可能だが、推奨されない
- **記事での表現**: 「recursiveの前身であるresolveストラテジーは、共通祖先が複数存在する場合にその1つを任意に選択するものだった」

## 3. recursiveマージストラテジー — Fredrik Kuivinen, 2005年9月

- **結論**: Fredrik Kuivinenが2005年9月にPythonスクリプトとして実装。コミット720d150で導入。当初は作者名にちなんで"fredrik"ストラテジーと呼ばれた。2005年9月13日のコミットe4cf17cでJunio C Hamanoにより"recursive"にリネームされた。Git v0.99.9kからv2.33.0まで約16年間デフォルト
- **一次ソース**: Git commit 720d150, Git commit e4cf17c
- **URL**: <https://github.com/git/git/commit/720d150c48fc35fca13c6dfb3c76d60e4ee83b87>, <https://github.com/git/git/commit/e4cf17ce0db2dab7c9525a732f86c5e3df3b4ed0>
- **注意事項**: 初期実装はPython、後にCに書き直された。Linux 2.6カーネルのマージコミットでテストされ、resolveより少ないコンフリクトで正確なマージを達成
- **記事での表現**: 「2005年9月、Fredrik KuivinenがPythonスクリプトとして実装し、Junio C Hamanoが"recursive"にリネームした（コミットe4cf17c、2005年9月13日）」

## 4. criss-cross mergeと仮想マージベース

- **結論**: criss-cross mergeとは、共通祖先が一意に定まらない（複数の最良共通祖先が存在する）履歴構造。recursiveストラテジーは複数の共通祖先を再帰的にマージして仮想的な1つの共通祖先を構築し、それを基準に3-way mergeを行う
- **一次ソース**: Git SCM merge-strategies Documentation; Plastic SCM Blog, "More on recursive merge strategy", 2012
- **URL**: <https://git-scm.com/docs/merge-strategies>, <https://blog.plasticscm.com/2012/01/more-on-recursive-merge-strategy.html>
- **注意事項**: この再帰的処理がrecursiveの名の由来。エッジケースとしてコンフリクトマーカーが意味論的に特別扱いされないため、稀に誤マージの可能性がある
- **記事での表現**: 「recursiveストラテジーは複数の共通祖先を再帰的にマージして仮想的な共通祖先を構築する。この再帰的処理が名前の由来である」

## 5. ortストラテジー — Elijah Newren, Git 2.33（2021年8月）

- **結論**: Git 2.33（2021年8月16日リリース）でElijah Newrenが開発したmerge-ortが導入された。"ort"は"Ostensibly Recursive's Twin"の頭字語。Git 2.34（2021年11月）でデフォルトに昇格
- **一次ソース**: The Register, "Git 2.33 released with new optional merge process", 2021-08-17; Elijah Newren, git mailing list
- **URL**: <https://www.theregister.com/2021/08/17/git_233/>, <https://lore.kernel.org/git/4a0f088f3669a95c7f75e885d06c0a3bdaf31f42.1628055482.git.gitgitgadget@gmail.com/>
- **注意事項**: Git 2.50でrecursiveストラテジーは内部的にortにリダイレクトされた
- **記事での表現**: 「2021年8月、Git 2.33でElijah Newrenが開発したmerge-ortが導入された。"ort"は"Ostensibly Recursive's Twin"の頭字語である」

## 6. ortの性能改善ベンチマーク

- **結論**: mega-renamesテストケース（約26,000リネームを含むブランチで35コミットをリベース）でrecursive比9,012倍の高速化。just-one-megaケースで565倍。no-renamesケースで95倍。mega-renamesケースでortは661.8ms、recursiveは5,964秒。ortはインメモリインデックスを回避し、インデックスエントリの挿入・削除による二次的挙動を排除
- **一次ソース**: Elijah Newren, git mailing list, "Change default merge backend from recursive to ort"
- **URL**: <https://lore.kernel.org/git/4a0f088f3669a95c7f75e885d06c0a3bdaf31f42.1628055482.git.gitgitgadget@gmail.com/>
- **注意事項**: これらは極端なケースでのベンチマーク。通常のマージでは差は小さい場合もある
- **記事での表現**: 「Newrenのベンチマークによれば、大量リネームを含むリベース操作で最大9,012倍の高速化を達成した」

## 7. ortのアーキテクチャ的改善 — 作業ディレクトリ不要

- **結論**: merge-ortはmerge-recursiveと異なり、作業ディレクトリやインメモリインデックスを必要としない。マージ結果を直接treeオブジェクトとして生成する。これによりサーバサイド操作やリベース時の性能が劇的に改善。GitHubのgithub/githubモノリスでは平均10倍、P99でも5倍の改善
- **一次ソース**: talent500.com, "Scaling Merge-Ort at GitHub"
- **URL**: <https://talent500.com/blog/scaling-merge-ort-github/>
- **注意事項**: 作業ディレクトリに書き込まないことで、セキュリティ面でも利点がある
- **記事での表現**: 「ortの最大のアーキテクチャ的改善は、作業ディレクトリを必要としない点にある。マージ結果を直接treeオブジェクトとして構築する」

## 8. octopus merge — Junio C Hamano, 2005年8月

- **結論**: octopusマージストラテジーはJunio C Hamanoが2005年8月24日にコミットd9f3be7で実装。シェルスクリプトとして実装された。コンフリクトがない場合にのみ成功し、1つでも検出されると中断される。3つ以上のブランチの同時マージを実現
- **一次ソース**: Git commit d9f3be7, "[PATCH] Infamous 'octopus merge'"
- **URL**: <https://github.com/git/git/commit/d9f3be7e2e4c9b402bbe6ee6e2b39b2ee89132cf>
- **注意事項**: Hamano自身が「octopus mergeはコンフリクトを記録するためのものではない」と明言。後にCに書き直された（Alban Gruin, 2020年）
- **記事での表現**: 「2005年8月24日、Junio C Hamanoがシェルスクリプトとしてoctopusマージを実装した（コミットd9f3be7）」

## 9. cherry-pickの内部メカニズム — 3-way mergeとして実装

- **結論**: git cherry-pickは単純なパッチ適用ではなく、3-way mergeとして実装されている。cherry-pickするコミットの親をbase、そのコミットをtheirs、現在のHEADをoursとして3-way mergeを実行する。revertはcherry-pickの逆で、コミットをbase、その親をtheirsとして3-way mergeを行う。両方ともsequencer.cで実装されている
- **一次ソース**: Julia Evans, "How git cherry-pick and revert use 3-way merge", 2023; Git source code sequencer.c
- **URL**: <https://jvns.ca/blog/2023/11/10/how-cherry-pick-and-revert-work/>, <https://github.com/git/git/blob/master/sequencer.c>
- **注意事項**: cherry-pickとrevertは元々revert.cに共に実装されていたが、現在はsequencer.cに移動
- **記事での表現**: 「cherry-pickは内部的に3-way mergeとして実装されている。cherry-pickするコミットの親をbase、コミット自体をtheirs、現在のHEADをoursとしてマージを実行する」

## 10. マージコンフリクト時の内部状態 — MERGE_HEAD、ステージ番号

- **結論**: マージコンフリクト時、gitは以下の状態を作り出す。(1) .git/MERGE_HEAD: マージ対象のコミットSHA-1を記録。(2) .git/MERGE_MSG: 自動生成されたマージコミットメッセージ。(3) インデックスのステージ番号: stage 0=通常（コンフリクトなし）、stage 1=共通祖先（base）、stage 2=HEAD側（ours）、stage 3=MERGE_HEAD側（theirs）。`git ls-files -u`で未マージエントリを確認可能。`git show :1:file`等で各ステージのファイル内容を取得可能
- **一次ソース**: Git SCM, "Git Tools - Advanced Merging"; Git SCM, git-merge Documentation
- **URL**: <https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging>, <https://git-scm.com/docs/git-merge>
- **注意事項**: stage 0は通常のインデックスエントリ。コンフリクト解消後に`git add`するとstage 1-3が削除されstage 0に統合される
- **記事での表現**: 「コンフリクト時、インデックスにはstage 1（共通祖先）、stage 2（ours/HEAD側）、stage 3（theirs/MERGE_HEAD側）の3つのエントリが記録される」

## 11. git merge-baseアルゴリズム

- **結論**: git merge-baseはDAG上の最良共通祖先（best common ancestor）を発見するアルゴリズム。グラフ理論の最小共通祖先（Lowest Common Ancestor, LCA）アルゴリズムの変種。「ある共通祖先が他の共通祖先の祖先であるならば、前者は後者より『良い』」という定義に基づく。最良共通祖先が複数存在する場合がある（criss-cross mergeのケース）
- **一次ソース**: Git SCM, git-merge-base Documentation
- **URL**: <https://git-scm.com/docs/git-merge-base>
- **注意事項**: `git merge-base --all`で全ての最良共通祖先を表示可能
- **記事での表現**: 「git merge-baseはDAG上の最良共通祖先を発見するアルゴリズムであり、グラフ理論のLCA（最小共通祖先）の変種である」

## 12. Linuxカーネルのoctopus mergeの統計

- **結論**: 2017年時点の統計で、Linuxカーネルの649,306コミット中46,930（7.2%）がマージコミット、うち1,549（マージの3.3%）がoctopus merge。最大66個の親を持つマージコミットが存在する
- **一次ソース**: Destroy All Software Blog, "The Biggest and Weirdest Commits in Linux Kernel Git History", 2017
- **URL**: <https://www.destroyallsoftware.com/blog/2017/the-biggest-and-weirdest-commits-in-linux-kernel-git-history>
- **注意事項**: 第16回で既出の統計。第17回では詳細に触れず、参照にとどめる
- **記事での表現**: 第16回からの参照として簡潔に言及
