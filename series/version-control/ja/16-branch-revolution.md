# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第16回：ブランチの革命——Gitが変えた開発フロー

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- CVS/SVNにおけるブランチの実装と、それがなぜ「恐怖の対象」だったのか
- Gitのブランチが41バイトのポインタファイルに過ぎないという技術的事実
- HEADの正体——symbolic referenceとdetached HEADの仕組み
- Git-flow（2010年）、GitHub Flow（2011年）、トランクベース開発——ブランチ戦略の変遷とその背景
- 3-way mergeアルゴリズムの原理と、recursive→ortへの進化
- rebaseの誕生（2005年6月、Torvalds & Hamano）と「履歴の書き換え」の危険性
- 低レベルコマンドによるブランチ操作で「見える」内部動作

---

## 1. ブランチが怖かった頃

私がCVSを使っていた2000年代前半、「ブランチを切る」という行為には、ある種の覚悟が必要だった。

大げさに聞こえるかもしれない。だが、当時の開発現場を知る人なら頷いてくれるだろう。CVSでブランチを作成するには`cvs tag -b`コマンドを実行する。この操作は、リポジトリ内の全ファイルにブランチタグを付与する。ファイルが100個なら100回の書き込み、1,000個なら1,000回の書き込みが走る。プロジェクトの規模によっては、ブランチの作成だけで数分かかった。

作成よりも恐ろしいのは、マージだ。CVSにはマージ追跡機能がない。どのリビジョンがブランチからトランクにマージ済みかを、開発者が手動で記録する必要があった。Excelのシートに「r1.15.2.1〜r1.15.2.7はマージ済み」と書き、次のマージでは「r1.15.2.8から」と指定する。この記録が誤っていれば、マージの結果も誤る。コンフリクトが噴出し、その解消に丸一日を費やしたことがある。

だから、現場には暗黙のルールがあった。「ブランチは切らない。トランクで作業する。どうしても必要なときだけ、リリースブランチを切る」。ブランチは最後の手段であり、日常的に使うものではなかった。

2010年代に入り、gitを本格的に使い始めたとき、私は戸惑った。チームメンバーが、息をするようにブランチを作り、息をするようにマージしている。1日に何本もブランチが生まれ、消えていく。私の中にあった「ブランチは高コスト」という前提が、根底から覆された。

**なぜgitでは「ブランチを気軽に切れる」のか。その技術的根拠は何か。** そして、ブランチが「安く」なったことで、開発のワークフローはどう変わったのか。

前回（第15回）でgitのオブジェクトモデル——blob、tree、commit、tagの4つのオブジェクトとSHA-1ハッシュによる内容アドレス可能ストレージ——を解剖した。今回は、そのオブジェクトモデルの上に構築された「ブランチ」の仕組みを掘り下げる。CVS/SVNのブランチ実装との根本的な違い、3-way mergeアルゴリズム、rebaseの誕生と危険性、そしてブランチ戦略の変遷を辿る。

あなたのチームは、ブランチをどう使っているだろうか。その使い方は、gitのオブジェクトモデルの特性を活かしているだろうか。

---

## 2. ブランチ実装の系譜——CVS、SVN、そしてGit

### CVSのブランチ——RCSファイルに刻まれた分岐

CVSのブランチの実装を理解するには、その基盤であるRCSのファイル形式に遡る必要がある。

CVSはRCS（Revision Control System）のラッパーとして出発した。各ファイルのバージョン履歴は、対応するRCSファイル（`,v`ファイル）に格納される。RCSファイルの中で、各リビジョンは番号で識別される。トランクのリビジョンは`1.1`、`1.2`、`1.3`……と連番で進む。

ブランチを作成すると、この番号体系に「枝」が生える。たとえばリビジョン`1.15`からブランチを切ると、そのブランチには`1.15.0.2`という内部番号が付与される。ブランチ上でコミットを重ねると、`1.15.2.1`、`1.15.2.2`、`1.15.2.3`と進んでいく。`.0.`を含む番号はブランチ識別子であり、それ以降の番号がブランチ上のリビジョンを示す。

```
CVSのリビジョン番号体系:

  トランク:  1.1 → 1.2 → ... → 1.15 → 1.16 → 1.17
                                  │
  ブランチ:                       └─→ 1.15.2.1 → 1.15.2.2 → 1.15.2.3
                                      (ブランチ番号: 1.15.0.2)
```

ここで決定的に重要なのは、このブランチ番号が「ファイルごと」に付与される点だ。リポジトリに100個のファイルがあれば、100個のRCSファイルのそれぞれにブランチタグが書き込まれる。ブランチの作成コストはファイル数に比例する。O(n)だ。

さらに深刻なのは、CVSのブランチが「リポジトリ全体」の概念として一貫性を持たないことだ。ファイルAはリビジョン1.15からブランチし、ファイルBはリビジョン1.8からブランチする。それぞれのRCSファイルが独立してブランチ番号を管理するため、「このブランチはリポジトリ全体のどの時点から分岐したのか」を一意に特定することが難しい。

マージの困難さも、この実装に起因する。CVSにはマージ追跡機能（merge tracking）がない。`cvs update -j`でブランチからの変更をマージする際、どのリビジョンまでがマージ済みかを手動で管理する必要がある。これを誤ると、同じ変更を二重にマージしたり、必要な変更が漏れたりする。

### SVNのブランチ——ディレクトリコピーという発想

Subversion（SVN）は、CVSのブランチの欠陥を明確に意識して設計された。

SVNのブランチは`svn copy`コマンドで作成される。典型的には、`trunk/`ディレクトリを`branches/feature-x/`にコピーする。ファイルシステム上のディレクトリコピーだ。

```
SVNのブランチ構造:

  /trunk/
  /branches/
      feature-x/     ← svn copy trunk branches/feature-x
      release-2.0/   ← svn copy trunk branches/release-2.0
  /tags/
      v1.0/          ← svn copy trunk tags/v1.0
```

「ディレクトリコピー」と聞くと、巨大なプロジェクトでは莫大なコストがかかると思うかもしれない。だが、SVNは内部でCopy-on-Write方式を採用している。`svn copy`はサーバ側で「元のデータへのポインタ」を作成するだけで、実際のデータ複製は行わない。サーバ側でのブランチ作成は定数時間——O(1)——で完了する。

CVSと比較すれば、これは大きな進歩だ。だが、SVNのブランチには別の問題がある。

第一に、ブランチが「特別な構造」ではなく「単なるディレクトリ」であるため、SVNのツールやプロトコルはブランチを通常のパスと区別しない。`branches/feature-x`がブランチであることを知っているのは、人間の慣習だけだ。ツールにとっては単なるディレクトリコピーに過ぎない。

第二に、マージ追跡は当初存在しなかった。SVN 1.5（2008年6月リリース）で`svn:mergeinfo`プロパティが導入されるまで、SVNのマージ状況はCVS同様に手動管理だった。`svn:mergeinfo`の導入後も、その挙動は複雑で、特にサブツリーマージ（ディレクトリ単位の部分マージ）では予期しない結果を生むことがあった。

第三に、ブランチの削除が心理的に重い。SVNのブランチは「ディレクトリ」であり、削除は`svn delete`で行う。操作自体は容易だが、「ディレクトリを消す」という行為は、「ポインタを消す」よりも心理的な抵抗が大きい。これは技術的な問題ではなく認知的な問題だが、無視できない影響がある。

### Gitのブランチ——41バイトの革命

gitのブランチは、根本的に異なる。

前回（第15回）で述べたように、gitのオブジェクトモデルでは、commitオブジェクトがDAG（有向非巡回グラフ）を形成する。各commitは`parent`フィールドで親commitを参照し、`tree`フィールドでプロジェクト全体のスナップショット（treeオブジェクト）を参照する。この構造が確立された上で、ブランチは驚くほど単純なものとして実装される。

ブランチは、`.git/refs/heads/{ブランチ名}`に格納される**41バイトのテキストファイル**だ。SHA-1ハッシュの十六進表現40文字と、改行文字1文字。それだけである。

```
Gitのブランチの正体:

  $ cat .git/refs/heads/main
  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0

  ↑ 41バイト = SHA-1ハッシュ(40文字) + 改行(1文字)
```

ブランチの作成は、このファイルを1つ書くだけだ。ファイルシステム上のファイル作成1回。プロジェクトのサイズに関係なく定数時間で完了する。10個のブランチを作りたければ、10個の41バイトファイルを書けばよい。100個でも1,000個でも同じだ。

ブランチの削除は、このファイルを消すだけだ。commitオブジェクトは消えない。reflog（参照の履歴）にも記録が残る。「うっかり消した」場合でも、commitのSHA-1ハッシュを知っていれば復元できる。

ブランチの切り替えは、`.git/HEAD`ファイルの内容を書き換えるだけだ。

```
HEADの仕組み:

  通常の状態（attached HEAD）:
  $ cat .git/HEAD
  ref: refs/heads/main       ← symbolic reference（ポインタのポインタ）

  ブランチの切り替え:
  $ git checkout feature-x
  $ cat .git/HEAD
  ref: refs/heads/feature-x  ← 書き換わった

  detached HEAD状態:
  $ git checkout a1b2c3d
  $ cat .git/HEAD
  a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0  ← SHA-1を直接格納
```

HEADは「今いるブランチ」を示すsymbolic reference——ポインタのポインタだ。通常は`ref: refs/heads/{ブランチ名}`という文字列を格納し、間接的にcommitを指す。特定のcommitを直接チェックアウトした場合、HEADはSHA-1ハッシュを直接格納する。これがdetached HEAD状態だ。

この実装の対比を整理する。

```
ブランチ実装の比較:

  CVS:
  ├── ブランチ作成: 全ファイルにタグ付与 → O(ファイル数)
  ├── ブランチの正体: RCSファイル内の番号体系
  ├── マージ追跡: なし（手動管理）
  └── 心理的コスト: 高い

  SVN:
  ├── ブランチ作成: svn copy（Copy-on-Write）→ O(1)
  ├── ブランチの正体: ディレクトリ
  ├── マージ追跡: SVN 1.5以降（svn:mergeinfo）
  └── 心理的コスト: 中程度

  Git:
  ├── ブランチ作成: 41バイトのファイル書き込み → O(1)
  ├── ブランチの正体: commitへのポインタ
  ├── マージ追跡: DAG構造に内在（親commitの参照）
  └── 心理的コスト: 極めて低い
```

gitのマージ追跡について補足する。gitでは、マージコミットが2つ以上のparentフィールドを持つことで、「どのcommitとどのcommitが統合されたか」がDAGの構造自体に記録される。CVSやSVNのように外部的なマージ追跡メカニズムは不要だ。マージの履歴は、オブジェクトモデルの中に内在している。

### ブランチ戦略の変遷——技術が文化を変えた

ブランチの「コスト」が劇的に下がったことで、開発のワークフローが変わった。その変遷を辿る。

**Git-flow（2010年1月5日）。** オランダのエンジニアVincent Driessenが、自身のブログnvie.comに"A successful Git branching model"という記事を公開した。この記事は、gitのブランチ戦略に「名前」と「構造」を与えた最初の体系的な提案として、爆発的に普及した。

Git-flowは5種類のブランチを定義する。

```
Git-flowのブランチモデル:

  永続ブランチ:
  ├── main (master)    ← リリース済みコードのみ
  └── develop          ← 次のリリースの統合先

  一時ブランチ:
  ├── feature/*        ← 機能開発（developから分岐、developにマージ）
  ├── release/*        ← リリース準備（developから分岐、main/developにマージ）
  └── hotfix/*         ← 緊急修正（mainから分岐、main/developにマージ）
```

Git-flowは、ブランチが「安い」というgitの特性を最大限に活用した。CVS時代には考えられなかった——5種類のブランチを日常的に作成し、破棄するワークフローだ。

だが、Git-flowには批判もあった。ブランチの種類が多すぎる。featureブランチが長期間存在するとコンフリクトが蓄積する。developブランチの存在意義が曖昧だ。Driessen自身が2020年3月5日に"Note of reflection"を追記し、こう述べた。「Webアプリのように継続的にデリバリーされるソフトウェアには、GitHub Flowのようなよりシンプルなワークフローを推奨する」。Git-flowが想定していたのは、複数バージョンを同時にサポートする必要があるパッケージソフトウェアだった。

**GitHub Flow（2011年8月31日）。** GitHubの共同創業者Scott Chaconが"GitHub Flow"を提唱した。Git-flowの複雑さに対するアンチテーゼだった。

GitHub Flowのルールは極めて単純だ。mainブランチは常にデプロイ可能な状態を保つ。新しい作業はmainから説明的な名前のブランチを切って開始する。作業が完了したらPull Requestを作成し、レビューを経てmainにマージする。マージしたらすぐにデプロイする。

ブランチの種類は2つだけ——mainと、作業ブランチ。Chaconは「Git-flowは多くの開発チームが実際に必要とするよりも複雑だ」と指摘した。

**トランクベース開発。** ブランチ戦略のもう一つの極がトランクベース開発だ。全ての開発者がtrunk（main）に直接コミットするか、極めて短命な（1日以内の）ブランチを使う。

興味深いことに、この「全員がトランクで作業する」というモデルは、CVS/SVN時代のデフォルトの開発スタイルそのものだ。当時は「ブランチのコストが高いからトランクで作業する」という消極的な選択だった。だが、GoogleはPerforceを使って35,000人以上の開発者が単一の巨大モノレポでトランクベース開発を実践しており、2018年のDORA（DevOps Research and Assessment）レポートはトランクベース開発をハイパフォーマンスチームの特徴として挙げた。

ブランチが「安い」時代にあえてブランチを最小限にする。これは消極的選択ではなく、継続的インテグレーションの文脈における積極的な設計判断だ。Martin Fowlerは2000年に"Continuous Integration"の記事で、全員がトランクに頻繁にコミットする重要性を論じていた。トランクベース開発は、ブランチの「コスト」が技術的に解消された後に、ワークフローの「複雑さ」というコストを改めて問い直したものだと言える。

---

## 3. マージとリベース——ブランチを統合する技術

### 3-way mergeの原理

ブランチが安くなっても、最終的にはブランチを統合しなければならない。統合の技術——マージアルゴリズム——は、ブランチの「使いやすさ」を左右する。

gitのマージの基盤は3-way mergeだ。2つの変更されたバージョンと、それらの共通祖先（common ancestor）を比較する。

```
3-way mergeの原理:

  共通祖先 (Base):     行1: A    行2: B    行3: C
  ブランチ1 (Ours):    行1: A    行2: X    行3: C     ← 行2をBからXに変更
  ブランチ2 (Theirs):  行1: A    行2: B    行3: Y     ← 行3をCからYに変更

  マージ結果:          行1: A    行2: X    行3: Y     ← 両方の変更を取り込み

  判定ルール:
  - Baseと同じ → 変更なし
  - 片方だけ変更 → その変更を採用
  - 両方が同じ変更 → その変更を採用
  - 両方が異なる変更 → コンフリクト（人間に委ねる）
```

3-way mergeが2-way merge（単に2つのファイルを比較する方式）より優れている理由は、「誰が何を変更したか」を判定できる点にある。2-way mergeでは、2つのファイルに差異がある場合、「どちらが正しいか」を判断できない。3-way mergeでは、共通祖先を基準に「どちらが変更を加えたか」が明確になる。

diffユーティリティの歴史は古い。James W. HuntとM. Douglas McIlroyが1976年にBell Labsで開発したdiffが、行単位の差分検出の基礎を築いた。Larry Wallが1985年に作成したpatchプログラムが差分の適用を自動化した。diff3（GNU実装）が3-way textマージの標準実装となり、CVSはこのdiff3のスクリプトとして出発した。

gitのマージは、このdiff3の延長線上にありつつ、DAGベースの共通祖先発見という独自の要素を加えている。

### recursiveからortへ——マージストラテジーの進化

gitのデフォルトマージストラテジーは、その歴史の中で進化してきた。

**recursiveストラテジー。** 2005年9月、Fredrik Kuivinenがgitに新しいマージアルゴリズムを実装した。当初は作者の名前にちなんで"fredrik"ストラテジーと呼ばれていたが、Junio C Hamanoによって"recursive"にリネームされた（コミット`e4cf17c`、2005年9月13日）。

recursiveの名は、共通祖先が複数存在する場合の振る舞いに由来する。通常、2つのcommitの共通祖先は1つだが、複雑な履歴——たとえばcriss-cross merge（交差マージ）の後——では、共通祖先が複数見つかることがある。

```
共通祖先が複数存在するケース（criss-cross merge）:

  A ← B ← D ← F      （ブランチ1）
  ↑       ↗ ↑
  └─ C ← E ← G       （ブランチ2）
       ↗
  B → D（BはDの祖先、DはFの祖先）
  C → E（CはEの祖先、EはGの祖先）
  B ← E のマージあり、C ← D のマージあり
  → FとGの共通祖先としてDとEの両方が候補になる
```

このとき、recursiveストラテジーは複数の共通祖先を再帰的にマージして仮想的な1つの共通祖先を構築し、それを基準に3-way mergeを実行する。この再帰的な処理が"recursive"の名の由来だ。

recursiveストラテジーはGit v0.99.9kからv2.33.0まで、約16年間にわたってgitのデフォルトマージストラテジーだった。

**ortストラテジー。** 2021年8月、Git 2.33でElijah Newrenが開発したmerge-ortが導入された。"ort"は"Ostensibly Recursive's Twin"（表向きはrecursiveの双子）の頭字語だ。

ortはrecursiveのスクラッチ書き直しだ。アルゴリズムの本質——共通祖先の再帰的マージと3-way merge——は同じだが、実装が根本的に異なる。ortの最大の特徴は、変更されていないディレクトリのtreeを走査しないことだ。巨大なリポジトリで一部のファイルだけが変更された場合、recursiveはtree全体を走査するが、ortは変更されたパスだけを処理する。

その効果は劇的だった。Newrenの報告によれば、特定のリベース操作で500〜9,000倍の高速化を達成した。Git 2.34（2021年11月）でortがデフォルトストラテジーに昇格し、Git 2.50ではrecursiveストラテジーは内部的にortにリダイレクトされた。

```
マージストラテジーの系譜:

  時期                ストラテジー   状態
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  2005年9月           fredrik        初期実装（Python）
  2005年9月           recursive      リネーム、Cに書き直し
  v0.99.9k〜v2.33    recursive      デフォルト（約16年間）
  2021年8月 (v2.33)  ort            導入（オプション）
  2021年11月 (v2.34) ort            デフォルトに昇格
  2025年 (v2.50)     recursive      内部的にortにリダイレクト
```

### octopus merge——多腕のマージ

gitには、3つ以上のブランチを同時にマージする「octopus merge」という戦略もある。タコの腕のように複数のブランチを一度にまとめるこの戦略は、コンフリクトがない場合にのみ成功する。コンフリクトが1つでも検出されると、octopus mergeは中断される。

```
octopus merge:

  git merge feature-a feature-b feature-c

       A ← B ←──── M       （マージコミットMは3つの親を持つ）
       ↑           ↑ ↑ ↑
       ├── C ──────┘ │ │   (feature-a)
       ├── D ────────┘ │   (feature-b)
       └── E ──────────┘   (feature-c)
```

Linuxカーネルのgit履歴は、octopus mergeの実用例を示している。2017年時点の統計で、カーネルの649,306コミット中46,930（7.2%）がマージであり、そのうち1,549（マージの3.3%）がoctopus mergeだ。66個の親を持つマージコミットすら存在する。カーネル開発者はgitの機能を使い倒しており、octopus mergeは複数のサブシステムからの独立した変更を一括で統合する際に用いられる。

### rebaseの誕生——履歴を「置き直す」

gitのブランチ統合には、mergeの他にもう一つの手法がある。rebaseだ。

rebaseの概念は、2005年6月のLinus TorvaldsとJunio Hamanoのメーリングリスト上の会話から生まれた。Torvaldsは「開発者が本当にやりたいのは、ローカルのコミットを共通の親からリモートの新しいHEADの上に『re-base（基盤を置き直す）』することだ」とコメントした。Hamanoが`git cherry`コマンドを使った"re-base"スクリプトを実装し、これがバージョン管理における"rebase"という用語の初出となった。

mergeとrebaseの違いを図示する。

```
merge vs rebase:

  初期状態:
  A ← B ← C          (main)
       └── D ← E     (feature)

  merge の場合:
  A ← B ← C ←───── M  (main、マージコミットMが作成される)
       └── D ← E ──┘   (feature)

  rebase の場合:
  A ← B ← C ← D' ← E'  (main/feature、DとEが「置き直される」)

  D' と E' は D と E の「コピー」
  内容は同じだが、SHA-1ハッシュは異なる（parentが変わるため）
```

rebaseは、ブランチの分岐点を移動させる操作だ。feature上のコミットD、Eを、mainの最新コミットCの上に「置き直す」。結果として、直線的な履歴が得られる。マージコミットが生成されないため、`git log`が読みやすくなる。

だが、rebaseには本質的な危険がある。rebaseは既存のコミットを「書き換える」操作だ。正確には、元のコミットを削除して新しいコミット（内容は同じだがparentが異なるため、SHA-1ハッシュも異なる）を作成する。元のコミットD、Eは、rebase後のD'、E'とは異なるオブジェクトだ。

これが問題になるのは、リモートリポジトリに既にpushされたコミットをrebaseする場合だ。他の開発者がコミットD、Eを基に作業していた場合、rebase後に強制pushすると、D、Eは消滅し、D'、E'に置き換わる。他の開発者のローカルリポジトリはD、Eを参照しているため、整合性が崩れる。

これがrebaseの「黄金律」の背景だ。**公開済みのブランチをrebaseしてはならない。** rebaseはローカルのコミットを整理するための道具であり、共有されたコミットを書き換えるための道具ではない。

Linus Torvalds自身が2009年にこの点を強調している。Torvaldsはrebaseを「自分のローカルな変更をきれいに保つ」ために推奨しつつ、共有ブランチのrebaseを厳しく戒めた。

---

## 4. ブランチの内部を覗く——reftableと未来

### 従来のファイルベース参照格納

ここまで述べてきたように、gitのブランチは`.git/refs/heads/`ディレクトリ下のテキストファイルとして格納される。この方式は単純で理解しやすいが、スケーラビリティの問題を抱えている。

リポジトリに数千のブランチやタグが存在する場合、`.git/refs/`以下に数千のファイルが作成される。ファイルシステムによっては、1つのディレクトリに大量のファイルが存在すると性能が劣化する。

gitはこの問題に対処するため、`packed-refs`ファイルを導入した。`git pack-refs`（または`git gc`の一部として）を実行すると、looseな参照ファイルが`.git/packed-refs`という単一のテキストファイルに統合される。ルックアップ時は、まずloose refsを確認し、なければpacked-refsを検索する。

```
packed-refsの形式:

  $ cat .git/packed-refs
  # pack-refs with: peeled fully-peeled sorted
  a1b2c3d4e5f6... refs/heads/feature-a
  b2c3d4e5f6a7... refs/heads/feature-b
  c3d4e5f6a7b8... refs/heads/main
  d4e5f6a7b8c9... refs/tags/v1.0
  ^e5f6a7b8c9d0... （annotated tagの場合、peelされたcommitのSHA-1）
```

### reftable——次世代の参照ストレージ

2024年4月、Git 2.45.0で**reftable形式**が導入された。Shawn Pearce（JGit開発者、元Google）が設計したこのバイナリ形式は、従来のloose refs + packed-refsの二層構造を、効率的な単一の形式で置き換える。

reftableの設計目標は明確だ。単一参照のルックアップと範囲スキャンを高速にすること。複数参照の同時更新をアトミックに行えること。大量の参照を持つリポジトリでスケールすること。

性能差は顕著だ。100万の参照を持つリポジトリで参照を1つ削除する操作は、従来のfiles形式で229.8ミリ秒、reftable形式で2.0ミリ秒。100倍以上の差がある。

Git 2.45.0時点ではオプション機能だが、reftableは将来的にデフォルトの参照格納形式になる可能性がある。ブランチが「41バイトのテキストファイル」であるという本稿の説明は、概念モデルとしては今後も正確だが、ストレージモデルは変わりつつある。前回（第15回）で述べたlooseオブジェクトとpackファイルの関係——「概念モデルはスナップショット型、ストレージモデルはデルタ圧縮型」——と同じ構造の分離が、参照格納にも起きている。

---

## 5. ハンズオン：低レベルコマンドでブランチを操作する

gitのブランチの内部を「見る」ために、低レベルコマンドを使ってブランチ操作を再現する。`git branch`や`git merge`といったポーセリンコマンドの裏側で何が起きているかを確認する。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y git
```

### 演習1：ブランチの正体を確認する

```bash
WORKDIR="${HOME}/vcs-handson-16"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=== 演習1: ブランチの正体を確認する ==="
echo ""

# gitの設定（Docker環境用）
git config --global user.email "handson@example.com"
git config --global user.name "Handson User"
git config --global init.defaultBranch main

# リポジトリの初期化
git init --quiet branch-demo
cd branch-demo

# 最初のコミット
echo "Hello, World!" > hello.txt
git add hello.txt
git commit --quiet -m "Initial commit"

# ブランチの正体を確認
echo "--- .git/HEAD の内容 ---"
cat .git/HEAD
echo ""
echo "-> HEADはsymbolic reference: refs/heads/mainを指している"
echo ""

echo "--- .git/refs/heads/main の内容 ---"
cat .git/refs/heads/main
echo ""
MAIN_HASH=$(cat .git/refs/heads/main)
echo "-> mainブランチはcommit ${MAIN_HASH} を指す41バイトのファイル"
echo ""

# ファイルサイズの確認
echo "--- mainブランチのファイルサイズ ---"
wc -c .git/refs/heads/main
echo "-> 41バイト = SHA-1(40文字) + 改行(1文字)"
echo ""

# 新しいブランチを低レベルコマンドで作成
echo "--- 低レベルコマンドでブランチを作成 ---"
# git branchを使わず、直接ファイルを書き込む
cp .git/refs/heads/main .git/refs/heads/feature-manual
echo "refs/heads/feature-manual を直接作成"
echo ""

# gitがブランチとして認識するか確認
echo "--- git branch の出力 ---"
git branch
echo ""
echo "-> ファイルを書くだけでブランチが作れる"
echo "   git branchはrefs/heads/以下のファイルを列挙しているに過ぎない"
```

### 演習2：HEADの動きを追跡する

```bash
echo ""
echo "=== 演習2: HEADの動きを追跡する ==="
echo ""

cd "${WORKDIR}/branch-demo"

echo "--- ブランチ切り替え前のHEAD ---"
cat .git/HEAD
echo ""

# ブランチを切り替え
git checkout --quiet feature-manual

echo "--- ブランチ切り替え後のHEAD ---"
cat .git/HEAD
echo ""
echo "-> HEADの参照先がmainからfeature-manualに変わった"
echo ""

# feature-manualでコミット
echo "Feature work" >> hello.txt
git add hello.txt
git commit --quiet -m "Add feature work"

echo "--- feature-manualの指す先 ---"
cat .git/refs/heads/feature-manual
echo ""
echo "--- mainの指す先（変わっていない）---"
cat .git/refs/heads/main
echo ""
echo "-> コミットによりfeature-manualのポインタだけが進んだ"
echo "   mainは元のコミットを指したまま"
echo ""

# detached HEADを体験
MAIN_HASH=$(cat .git/refs/heads/main)
git checkout --quiet "${MAIN_HASH}"

echo "--- detached HEAD状態 ---"
cat .git/HEAD
echo ""
echo "-> HEADがsymbolic referenceではなく、SHA-1を直接格納している"
echo "   これがdetached HEAD状態"

# 元に戻す
git checkout --quiet main
```

### 演習3：3-way mergeを手動で確認する

```bash
echo ""
echo "=== 演習3: 3-way mergeを手動で確認する ==="
echo ""

cd "${WORKDIR}"
git init --quiet merge-demo
cd merge-demo
git config user.email "handson@example.com"
git config user.name "Handson User"

# 共通祖先を作成
cat > app.py << 'EOF'
# app.py - サンプルアプリケーション
def main():
    print("Hello, World!")
    print("Version 1.0")

def helper():
    return 42

if __name__ == "__main__":
    main()
EOF
git add app.py
git commit --quiet -m "Base version"
BASE_HASH=$(git rev-parse HEAD)

# ブランチ1: main で変更
cat > app.py << 'EOF'
# app.py - サンプルアプリケーション
def main():
    print("Hello, World!")
    print("Version 2.0")

def helper():
    return 42

if __name__ == "__main__":
    main()
EOF
git add app.py
git commit --quiet -m "Update version to 2.0"

# ブランチ2: feature で別の変更
git checkout --quiet -b feature "${BASE_HASH}"
cat > app.py << 'EOF'
# app.py - サンプルアプリケーション
def main():
    print("Hello, World!")
    print("Version 1.0")

def helper():
    return 100

if __name__ == "__main__":
    main()
EOF
git add app.py
git commit --quiet -m "Update helper return value"

echo "--- マージ前の状態 ---"
echo "main: Version 2.0に変更（行4）"
echo "feature: helperの戻り値を100に変更（行7）"
echo "共通祖先: ${BASE_HASH:0:7}"
echo ""

# 共通祖先を確認
echo "--- 共通祖先の確認 ---"
MERGE_BASE=$(git merge-base main feature)
echo "git merge-base main feature = ${MERGE_BASE:0:7}"
echo "これがBase commit (共通祖先) = ${BASE_HASH:0:7}"
echo ""

# マージを実行
git checkout --quiet main
echo "--- マージ実行 ---"
git merge --no-edit feature
echo ""

echo "--- マージ結果 ---"
cat app.py
echo ""
echo "-> 行4: Version 2.0（mainの変更が採用）"
echo "   行7: return 100（featureの変更が採用）"
echo "   3-way mergeにより、競合しない変更が自動統合された"
echo ""

echo "--- マージコミットの親 ---"
git cat-file -p HEAD | grep parent
echo ""
echo "-> マージコミットは2つのparentを持つ"
echo "   これがgitのDAG構造にマージ追跡が内在する仕組み"
```

### 演習4：rebaseの内部動作を確認する

```bash
echo ""
echo "=== 演習4: rebaseの内部動作を確認する ==="
echo ""

cd "${WORKDIR}"
git init --quiet rebase-demo
cd rebase-demo
git config user.email "handson@example.com"
git config user.name "Handson User"

# 共通の履歴を作成
echo "Line 1" > file.txt
git add file.txt
git commit --quiet -m "Commit A"

echo "Line 2" >> file.txt
git add file.txt
git commit --quiet -m "Commit B"

# featureブランチを作成
git checkout --quiet -b feature

echo "Feature line 1" >> file.txt
git add file.txt
git commit --quiet -m "Commit D (feature)"
D_HASH=$(git rev-parse HEAD)

echo "Feature line 2" >> file.txt
git add file.txt
git commit --quiet -m "Commit E (feature)"
E_HASH=$(git rev-parse HEAD)

# mainを進める
git checkout --quiet main
echo "Main line 1" > main.txt
git add main.txt
git commit --quiet -m "Commit C (main)"

echo "--- rebase前の状態 ---"
echo "main:    A - B - C"
echo "feature: A - B - D - E"
echo ""
echo "D のSHA-1: ${D_HASH:0:12}"
echo "E のSHA-1: ${E_HASH:0:12}"
echo ""

# rebaseを実行
git checkout --quiet feature
git rebase --quiet main

D_NEW=$(git rev-parse HEAD~1)
E_NEW=$(git rev-parse HEAD)

echo "--- rebase後の状態 ---"
echo "feature: A - B - C - D' - E'"
echo ""
echo "D' のSHA-1: ${D_NEW:0:12}"
echo "E' のSHA-1: ${E_NEW:0:12}"
echo ""
echo "--- SHA-1の比較 ---"
echo "D  (rebase前): ${D_HASH:0:12}"
echo "D' (rebase後): ${D_NEW:0:12}"
echo ""
if [ "${D_HASH}" != "${D_NEW}" ]; then
  echo "-> SHA-1が異なる。rebaseは元のコミットの「コピー」を作成する"
  echo "   内容は同じだが、parentが異なるため、別のオブジェクトになる"
  echo "   これが「履歴の書き換え」の正体"
else
  echo "-> （一致した場合：予期しない結果）"
fi
echo ""

echo "--- D'の内容を確認 ---"
echo "tree:"
git cat-file -p "${D_NEW}" | head -1
echo "parent:"
git cat-file -p "${D_NEW}" | grep parent
echo ""
echo "-> parentがmainのCommit C を指している"
echo "   元のDはCommit Bをparentとしていた"
echo "   parentが変わったので、SHA-1も変わった"
```

### 演習で見えたこと

四つの演習を通じて、gitのブランチの内部動作を確認した。

演習1では、ブランチが`.git/refs/heads/`以下の41バイトのテキストファイルであることを確認した。`git branch`コマンドを使わず、ファイルを直接コピーするだけでブランチが作成できる。gitにとってブランチの作成は、ファイルシステムへの書き込み1回で完了する操作だ。

演習2では、HEADがsymbolic reference——ブランチへのポインタ——であることを確認した。`git checkout`はHEADの参照先を書き換えるだけの操作だ。detached HEAD状態では、HEADがブランチを介さずcommitのSHA-1を直接格納する。

演習3では、3-way mergeの動作を確認した。`git merge-base`で共通祖先を特定し、共通祖先からの差分が競合しない場合は自動統合される。マージコミットは2つのparentを持ち、DAGの構造自体がマージ追跡の機能を果たす。

演習4では、rebaseが既存のコミットの「コピー」を作成する操作であることを確認した。rebase前後でコミットの内容（変更差分）は同じだが、parentが異なるためSHA-1ハッシュも異なる。これが「履歴の書き換え」の正体であり、公開済みブランチでのrebaseが危険である理由だ。

---

## 6. まとめと次回予告

### この回の要点

第一に、CVS/SVN/Gitのブランチ実装は根本的に異なる。CVSはRCSファイルの番号体系にブランチを埋め込み、作成コストはファイル数に比例する。SVNは`svn copy`によるCopy-on-Writeで定数時間の作成を実現したが、ブランチは「ディレクトリ」であり、マージ追跡は後付けだった。Gitはブランチを41バイトのポインタファイルとして実装し、作成・削除・切り替えの全てを定数時間で完了する。

第二に、ブランチの「コスト」の劇的な低下が、開発ワークフローを変革した。Git-flow（Vincent Driessen、2010年1月）は5種類のブランチを定義し、gitのブランチ特性を活用した最初の体系的なモデルとなった。GitHub Flow（Scott Chacon、2011年8月）はその複雑さに対するアンチテーゼとして、mainと作業ブランチの2種類だけの単純なモデルを提唱した。トランクベース開発は、ブランチのコストが解消された後に、ワークフローの複雑さを改めて問い直す立場だ。

第三に、gitのマージアルゴリズムは3-way mergeを基盤とし、recursiveストラテジー（Fredrik Kuivinen、2005年）からortストラテジー（Elijah Newren、2021年）へと進化した。ortは特定のケースでrecursiveの500〜9,000倍の高速化を達成し、Git 2.34でデフォルトに昇格した。

第四に、rebaseは2005年6月のTorvaldsとHamanoの会話から生まれた「コミットの基盤を置き直す」操作であり、直線的な履歴を得るために有用だが、公開済みブランチでの使用は禁忌だ。rebaseが新しいSHA-1ハッシュを持つコミットのコピーを作成するという内部動作を理解することが、この禁忌の理由の理解につながる。

第五に、reftable形式（Git 2.45.0、Shawn Pearce設計）が参照格納の次世代フォーマットとして導入された。ブランチが「41バイトのテキストファイル」であるという概念モデルは変わらないが、ストレージモデルは進化しつつある。

### 冒頭の問いへの暫定回答

なぜgitでは「ブランチを気軽に切れる」のか。その技術的根拠は何か。

答えは、オブジェクトモデルの設計にある。gitはcommitオブジェクトのDAGとして履歴を記録し、ブランチをそのDAGの特定のノードを指すポインタとして実装した。ブランチの作成はポインタの追加であり、マージ追跡はDAGの構造に内在する。ブランチのコストがゼロに近づいたことで、「ブランチは恐怖の対象」から「開発の基本単位」へと変わった。

だが、道具が変わっても、問いは残る。「ブランチが安い」ことは、「ブランチを多用すべき」ことを意味するのか。Git-flowは5種類のブランチを提案し、GitHub Flowは2種類に減らし、トランクベース開発はブランチの最小化を志向する。最適なブランチ戦略は、チームの規模、デプロイの頻度、ソフトウェアの性質によって異なる。

技術的に「安い」からといって、無条件に多用するのは知恵ではない。安さの恩恵を受けつつ、ワークフロー全体の複雑さを制御する。それが、ブランチの革命から学ぶべき教訓だろう。

### 次回予告

ブランチの統合手段としてmergeとrebaseを見てきた。だが、gitのマージは「魔法」ではない。マージが成功するとき、内部では何が起きているのか。マージが失敗するとき——コンフリクトが発生するとき——何が起きているのか。

**第17回「マージ戦略の深淵——recursive, ort, octopus」**

次回は、マージアルゴリズムの詳細に踏み込む。共通祖先の発見アルゴリズム、再帰的マージの具体的な動作、octopus mergeの仕組み、cherry-pickの内部動作。そして、コンフリクトが発生したときにgitが内部でどのような状態を作り出すのか——`MERGE_HEAD`、`MERGE_MSG`、ステージングエリアのstage番号——を解剖する。

マージアルゴリズムの理解は、コンフリクト解消能力に直結する。あなたは、コンフリクトが起きたとき、何が起きているかを「見える」だろうか。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Driessen, V., "A successful Git branching model." nvie.com, 2010-01-05. <https://nvie.com/posts/a-successful-git-branching-model/>
- Chacon, S., "GitHub Flow." scottchacon.com, 2011-08-31. <https://scottchacon.com/2011/08/31/github-flow>
- Chacon, S. and Straub, B., "Git Internals - Git References." Pro Git, 2nd Edition. <https://git-scm.com/book/en/v2/Git-Internals-Git-References>
- Git SCM, "merge-strategies Documentation." <https://git-scm.com/docs/merge-strategies>
- Git commit e4cf17c, "Rename the 'fredrik' merge strategy to 'recursive'." 2005-09-13. <https://github.com/git/git/commit/e4cf17ce0db2dab7c9525a732f86c5e3df3b4ed0>
- The Register, "Git 2.33 released with new optional merge process likely to become the default." 2021-08-17. <https://www.theregister.com/2021/08/17/git_233/>
- DEVCLASS, "Git 2.34 sets new merge default." 2021-11-17. <https://devclass.com/2021/11/17/version-control-git-2_34/>
- GitButler Blog, "20 years of Git. Still weird, still wonderful." 2025. <https://blog.gitbutler.com/20-years-of-git>
- Hammant, P., "Google's Scaled Trunk-Based Development." 2013. <https://paulhammant.com/2013/05/06/googles-scaled-trunk-based-development/>
- Collins-Sussman, B. et al., "Version Control with Subversion - Using Branches." <https://svnbook.red-bean.com/en/1.7/svn.branchmerge.using.html>
- GNU CVS Manual, "Creating a branch." <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Creating-a-branch.html>
- Git SCM, "reftable Documentation." <https://git-scm.com/docs/reftable>
- GitLab Blog, "A beginner's guide to the Git reftable format." <https://about.gitlab.com/blog/a-beginners-guide-to-the-git-reftable-format/>
- Destroy All Software Blog, "The Biggest and Weirdest Commits in Linux Kernel Git History." 2017. <https://www.destroyallsoftware.com/blog/2017/the-biggest-and-weirdest-commits-in-linux-kernel-git-history>
- Wikipedia, "Merge (version control)." <https://en.wikipedia.org/wiki/Merge_(version_control)>
- Atlassian, "Git rebase." <https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase>
