# ファクトチェック記録：第6回

**対象記事**: 第6回「ブランチとマージの悪夢——CVS時代の苦い教訓」
**調査日**: 2026-02-15
**調査手段**: WebSearch による一次ソース検証

---

## 1. CVSのブランチ番号体系（RCSリビジョン番号の分岐構造）

- **結論**: CVSのブランチはRCSのリビジョン番号体系に基づく。ブランチ番号は、分岐元リビジョンに偶数整数を追加して構成される。例えばリビジョン1.4から分岐する場合、ブランチ番号は1.4.2となり、そのブランチ上の最初のリビジョンは1.4.2.1となる。CVSは内部的に「マジックブランチ番号」（例: 1.4.0.2）を使用し、二番目に右の位置に0を挿入する効率化を行っている
- **一次ソース**: GNU CVS Manual v1.11.23, "Branches and revisions"
- **URL**: <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Branches-and-revisions.html>
- **注意事項**: ブランチ番号は常に奇数個のピリオド区切り整数で構成される。偶数分岐番号2, 4, 6...が使われる
- **記事での表現**: 「CVSのブランチは、RCSのリビジョン番号に偶数整数を追加する形で表現される。リビジョン1.4から分岐するブランチは1.4.2となり、そのブランチ上のリビジョンは1.4.2.1, 1.4.2.2と続く」

## 2. CVSのブランチ作成コマンド（cvs tag -b）

- **結論**: CVSでブランチを作成するには `cvs tag -b branchname` を使用する。このコマンドはリポジトリ内の各ファイルに対して個別にブランチタグを記録する。ブランチはリポジトリ側に作成され、作業コピーは自動的にブランチに切り替わらない。ブランチに切り替えるには別途 `cvs update -r branchname` が必要
- **一次ソース**: GNU CVS Manual v1.11.23, "Creating a branch"
- **URL**: <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Creating-a-branch.html>
- **注意事項**: タグ付けはファイル単位で行われるため、大規模プロジェクトではブランチ作成自体に時間がかかる
- **記事での表現**: 「CVSでブランチを作るには `cvs tag -b` を実行する。これはリポジトリ内の全ファイルに対してブランチタグを個別に記録する操作であり、ファイル数に比例して時間がかかった」

## 3. CVSのタグ実装——ファイル単位のリビジョンマッピング

- **結論**: CVSのタグは、各ファイルの特定リビジョンに名前を付与する仕組みであり、「リビジョン番号のマトリクス（ファイル名 x リビジョン番号）を横切る曲線」として機能する。gitのタグがリポジトリ全体のスナップショット（単一のコミットオブジェクト）を指すのに対し、CVSのタグはファイルごとに異なるリビジョンを指す。このため、CVSでは任意のファイルリビジョンの組み合わせをタグ付けすることが可能だが、リポジトリ全体の一貫したスナップショットの概念が弱い
- **一次ソース**: apenwarr blog, "A tale of five merges: cvs, svn, git, darcs, etc."; GNU CVS Manual v1.11.23, "Tags"
- **URL**: <https://apenwarr.ca/log/20080319>, <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Tags.html>
- **注意事項**: CVSからgitへの変換（cvs2git）が困難な根本原因の一つ
- **記事での表現**: 「CVSのタグはファイル単位のリビジョン番号への名前付けであり、リポジトリ全体のスナップショットという概念とは根本的に異なる」

## 4. CVSのマージ追跡の不在

- **結論**: CVSにはマージ追跡機能がない。`cvs update -j branchname` でブランチの変更をトランクにマージした後、再度同じコマンドを実行すると、既にマージ済みの変更を再度マージしようとし、意図しない結果を招く。これを回避するには、マージ後にタグを打ち（例: `merged_from_branch_to_trunk`）、次回のマージでは `cvs update -j merged_tag -j branchname` のように二つの `-j` オプションを使って差分範囲を指定する必要があった
- **一次ソース**: GNU CVS Manual v1.11.23, "Merging a branch"; Karl Fogel, "Open Source Development with CVS"
- **URL**: <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Merging-a-branch.html>, <https://durak.org/sean/pubs/software/cvsbook/Multiple-Merges.html>
- **注意事項**: マージ後のタグ付けを忘れると、二度目のマージが破滅的な結果をもたらす可能性がある。CVSマニュアル自身が「マージ後すぐにタグを打て、さもなければ歯ぎしりすることになる」と警告している
- **記事での表現**: 「CVSにはマージ追跡機能がなかった。一度マージした変更を記録する仕組みがなく、再マージ時に同じ変更を二重に適用してしまう問題があった。開発者はマージのたびにタグを打つ運用規律でこの問題を回避するしかなかった」

## 5. CVSのstickyタグ問題

- **結論**: CVSの「sticky tag」は、作業コピーのファイルが特定のリビジョンやブランチに固定（sticky）される仕組み。ブランチで作業した後にトランクに戻る場合、`cvs update -A` でstickyタグを解除する必要がある。非ブランチタグがstickyになると、そのファイルはコミットできなくなる。「cvs server: sticky tag 'tagname' is not a branch」というエラーメッセージは、CVS利用者なら誰もが一度は目にしたものだった
- **一次ソース**: GNU CVS Manual v1.11.23, "Sticky tags"; Karl Fogel, "Open Source Development with CVS"
- **URL**: <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Sticky-tags.html>, <https://durak.org/sean/pubs/software/cvsbook/I-am-having-problems-with-sticky-tags_003b-how-do-I-get-rid-of-them_003f.html>
- **注意事項**: stickyタグの存在は初心者には特に混乱を招いた
- **記事での表現**: 「CVSのstickyタグは、作業コピーが特定のブランチやリビジョンに固定される仕組みで、ブランチを切り替える際のトラップとして悪名高かった」

## 6. トランクベース開発がCVS時代に主流だった理由

- **結論**: CVS時代にトランクベース開発が主流だった理由は、マージの困難さに起因する。Paul Hammantは「マージがバグだらけだった初期には、事実上トランクモデルを強いられた」と述べている。全員が毎日何度もHEADリビジョンと同期し、小さな変更をコミットすることで、コンフリクトの痛みを最小化した。CVSが"trunk"というブランチ名を普及させたのもこの時代である
- **一次ソース**: Paul Hammant, "The origins of Trunk-Based Development" (2015); trunkbaseddevelopment.com
- **URL**: <https://paulhammant.com/2015/04/23/the-origins-of-trunk-based-development/>, <https://trunkbaseddevelopment.com/game-changers/>
- **注意事項**: トランクベース開発は1990年代半ばから知られていたが、明確に命名・体系化されたのは後年
- **記事での表現**: 「CVS時代、マージの困難さゆえにトランクベース開発が事実上の標準だった。ブランチを切ることのコストが高すぎたため、全員がtrunkに対して小さな変更を頻繁にコミットする開発スタイルが合理的だった」

## 7. CVSのマージ機構——diff3/rcsmergeの使用

- **結論**: CVSのマージはinternal的にrcsmerge（RCSのマージツール）を呼び出し、さらにその内部でdiff3（3-way diff）を使用する。CVS自体が「diff3上のスクリプト群」として始まったという経緯がある。3-way mergeは、共通祖先（BASE）、現在のファイル（THIS）、マージ対象（OTHER）の三つの入力を比較し、非衝突の変更は自動的に統合し、衝突する変更にはコンフリクトマーカーを挿入する
- **一次ソース**: tonyg.github.io, "Three-Way Merge - Revision Control"; Karl Fogel, "Open Source Development with CVS"
- **URL**: <https://tonyg.github.io/revctrl.org/ThreeWayMerge.html>, <https://durak.org/sean/pubs/software/cvsbook/Detecting-And-Resolving-Conflicts.html>
- **注意事項**: CVSのマージはファイル単位で行われ、ファイル間の依存関係は考慮されない
- **記事での表現**: 「CVSのマージは内部的にrcsmergeとdiff3を使った3-way mergeだった。ファイル単位で処理され、ファイル間の論理的依存関係は考慮されなかった」

## 8. Gitのブランチ実装——41バイトのポインタ

- **結論**: Gitのブランチは、.git/refs/heads/ディレクトリ内の41バイトのファイル（40文字のSHA-1ハッシュ＋改行文字）として実装されている。ブランチの作成は、新しいファイルにコミットハッシュを書き込むだけの操作であり、リポジトリのデータをコピーする必要がない。このため、ブランチの作成はほぼ瞬時に完了する
- **一次ソース**: Pro Git (git-scm.com), "Git Branching - Branches in a Nutshell"; Pro Git, "Git References"
- **URL**: <https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell>, <https://git-scm.com/book/en/v2/Git-Internals-Git-References>
- **注意事項**: Git 2.45以降ではreftable形式も導入されているが、概念的にはブランチ＝ポインタという設計は変わらない
- **記事での表現**: 「Gitのブランチは41バイトのファイルに過ぎない。コミットのSHA-1ハッシュ（40文字）と改行文字1つ。ブランチの作成とは、このファイルを一つ書き込むことだ」

## 9. Vincent Driessenのgit-flow（2010年）

- **結論**: Vincent Driessenは2010年1月5日に"A successful Git branching model"を公開した。このモデルはmaster/develop/feature/release/hotfixの5種類のブランチを使い分けるワークフローで、公開後の10年間で事実上の標準として広く普及した。Driessen自身は2020年3月の追記（Note of reflection）で、Webアプリの継続的デリバリー環境ではgit-flowが最適でない場合があることを認めている
- **一次ソース**: Vincent Driessen, "A successful Git branching model," nvie.com, January 5, 2010
- **URL**: <https://nvie.com/posts/a-successful-git-branching-model/>
- **注意事項**: git-flowの普及は、Gitのブランチが「安い」からこそ可能だった
- **記事での表現**: 「2010年、Vincent Driessenが"A successful Git branching model"を公開した。5種類のブランチを自在に使い分けるこのモデルが広く受け入れられたこと自体が、CVS時代からのブランチ観の劇的な変化を示している」

## 10. Martin Fowlerのfeature branchに関する言及

- **結論**: Martin Fowlerは2009年9月3日に"Feature Branch"のblikiエントリを公開した。feature branchパターンと継続的インテグレーションの関係を論じ、長寿命のfeature branchが統合の遅延を引き起こすリスクを指摘した。後に"Patterns for Managing Source Code Branches"としてより包括的な記事も公開している
- **一次ソース**: Martin Fowler, "Feature Branch," martinfowler.com, September 3, 2009
- **URL**: <https://martinfowler.com/bliki/FeatureBranch.html>, <https://martinfowler.com/articles/branching-patterns.html>
- **注意事項**: Fowlerの議論はCVS時代の「ブランチ恐怖症」とGit時代の「ブランチ乱造」の両極を見据えたもの
- **記事での表現**: 「Martin Fowlerが2009年にfeature branchパターンについて論じた際、ブランチの長寿命化と統合遅延のリスクを指摘した。ブランチが安くなったことで、今度は別の問題が浮上したのだ」
