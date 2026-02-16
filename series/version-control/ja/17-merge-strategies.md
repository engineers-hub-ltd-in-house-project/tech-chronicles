# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第17回：マージ戦略の深淵——recursive, ort, octopus

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- gitのマージが「魔法」ではなく、明確なアルゴリズムの産物であること
- 共通祖先の発見（merge-base）がマージの起点であり、DAG上のLCAアルゴリズムであること
- resolveストラテジーの限界と、recursiveストラテジーが仮想マージベースで解決したこと
- ort（Ostensibly Recursive's Twin）がrecursiveをゼロから書き直し、作業ディレクトリ不要のインメモリアーキテクチャで劇的な高速化を達成したこと
- octopusマージが3つ以上のブランチを同時統合する仕組みと、コンフリクト時に中断する設計判断
- cherry-pickとrevertが内部的に3-way mergeとして実装されている事実
- コンフリクト時にgitが作り出す内部状態——MERGE_HEAD、MERGE_MSG、インデックスのstage番号

---

## 1. マージが「壊れた」日

私がgitを本格的に使い始めた2010年代前半、あるプロジェクトでマージコンフリクトの地獄に陥ったことがある。

そのプロジェクトでは、3人のエンジニアがそれぞれ長命なfeatureブランチを持っていた。ブランチAとブランチBを先にmainにマージし、次にブランチCをマージしようとしたとき、大量のコンフリクトが噴出した。ブランチCの開発者は、途中でブランチAの変更の一部をcherry-pickして取り込んでいた。同じ変更が異なるコンテキストで二重に適用されようとしていたのだ。

コンフリクトマーカーが数十ファイルに散在し、その解消に丸一日を費やした。だが、本当の問題はコンフリクトの量ではなかった。問題は、私がマージアルゴリズムの動作を理解していなかったことだった。gitがどのコミットを「共通祖先」として選び、何と何を比較し、どのような条件でコンフリクトを判定しているのか——それがわからないまま、目の前のコンフリクトマーカーを一つずつ手動で解消していた。

その経験の後、私はgitのマージの内部動作を調べ始めた。そして気づいた。マージアルゴリズムを理解すると、コンフリクトが「なぜ」起きたのかが見えるようになる。見えるようになると、コンフリクトを事前に回避する判断ができるようになる。マージは魔法ではない。明確なアルゴリズムの産物だ。

**gitのマージは「魔法」ではない。では、内部で何が起きているのか。**

前回（第16回）では、gitのブランチが41バイトのポインタファイルに過ぎないこと、3-way mergeの原理、recursiveからortへの進化の概要を扱った。今回は、マージアルゴリズムの「内部」に踏み込む。共通祖先の発見アルゴリズム、recursiveストラテジーが仮想マージベースを構築する具体的な手順、ortがアーキテクチャレベルで何を変えたか、cherry-pickの内部動作、そしてコンフリクト時にgitが作り出す内部状態——MERGE_HEAD、MERGE_MSG、インデックスのstage番号——を解剖する。

あなたは、コンフリクトが起きたとき、gitの内部で何が起きているかを「見える」だろうか。

---

## 2. 共通祖先の発見——マージの起点

### merge-base: DAG上のLCA

全てのマージは、共通祖先（common ancestor）の発見から始まる。前回、3-way mergeが「共通祖先」「ours（HEAD側）」「theirs（マージ対象側）」の3つのバージョンを比較するアルゴリズムであることを述べた。では、gitはどのようにして共通祖先を発見するのか。

gitのコミット履歴はDAG（有向非巡回グラフ）を形成する。各コミットは`parent`フィールドで1つ以上の親コミットを参照する。通常のコミットは親が1つ、マージコミットは親が2つ以上だ。このDAG上で、2つのコミットの「共通祖先」を見つけるのが`git merge-base`コマンドの仕事である。

`git merge-base`のアルゴリズムは、グラフ理論における最小共通祖先（Lowest Common Ancestor, LCA）アルゴリズムの変種だ。gitの公式ドキュメントは「最良共通祖先（best common ancestor）」という用語を用いる。定義は明確だ。「ある共通祖先Aが他の共通祖先Bの祖先であるならば、BはAより良い。これ以上良い共通祖先を持たない共通祖先が、最良共通祖先である」。

直感的に言えば、2つのブランチの分岐点に最も近い共通コミットが、最良共通祖先だ。

```
単純なケース: 共通祖先が一意に定まる

  A ← B ← C ← D         (main)
            └── E ← F    (feature)

  merge-base(D, F) = B
  → BはDとFの最良共通祖先

  マージ時:
  - base（共通祖先）: B
  - ours（HEAD側）:   D
  - theirs:           F
```

多くのケースでは、共通祖先は一意に定まる。だが、常にそうとは限らない。

### 複数の共通祖先——criss-cross merge

マージの履歴が複雑になると、共通祖先が一意に定まらない場合がある。典型例がcriss-cross merge（交差マージ）だ。

```
criss-cross mergeの例:

  A ← B ← M1 ← D       (branch-1)
  │    ↗    ↑
  │   /     │
  ↓  ↙      │
  A ← C ← M2 ← E       (branch-2)

  Bから分岐したCがある。
  M1はBとCのマージ（branch-1側で実行）。
  M2はCとBのマージ（branch-2側で実行）。

  DとEをマージしようとすると:
  - M1はDの祖先、かつEの祖先（M2経由ではないが、CはM2の親）
    → 正確にはM1はDの祖先だがEの祖先ではない
  - M1とM2が共にDとEの共通祖先の候補になる
  - M1はM2の祖先ではなく、M2もM1の祖先ではない
  → 最良共通祖先が2つ存在する
```

実際には、2つのブランチが互いの変更をマージし合う（交差する）と、この状態が生まれる。`git merge-base --all`を実行すると、複数の共通祖先が表示される。

共通祖先が1つの場合、3-way mergeは明快だ。だが複数の場合、どの共通祖先を使うべきか。この問いへの答えが、マージストラテジーの核心である。

---

## 3. マージストラテジーの系譜——resolve, recursive, ort

### resolve: 最初のストラテジー

gitの最初期のマージストラテジーは**resolve**だった。resolveは単純な3-way mergeを実行する。共通祖先が複数存在する場合、そのうちの1つを選択して3-way mergeの基準とする。

この「1つを選択する」という設計は、単純だが問題がある。選択された共通祖先によってマージ結果が変わる可能性がある。criss-cross mergeのケースでは、どの共通祖先を選ぶかで異なるコンフリクトパターンが生じることがある。resolveはリネーム（ファイル名変更）の検出もサポートしていなかった。

resolveストラテジーはgitの初期バージョンではデフォルトだったが、その限界は明らかだった。

### recursive: 仮想マージベースの構築

2005年9月、Fredrik KuivinenがPythonスクリプトとして新しいマージアルゴリズムを実装した（コミット`720d150`）。当初は作者の名前にちなんで"fredrik"ストラテジーと呼ばれていたが、Junio C Hamanoによって"recursive"にリネームされた（コミット`e4cf17c`、2005年9月13日）。

recursiveストラテジーの核心は、共通祖先が複数存在する場合の処理にある。resolveのように1つを「選ぶ」のではなく、複数の共通祖先を**再帰的にマージして仮想的な1つの共通祖先を構築**する。

その手順を具体的に示す。

```
recursiveストラテジーの動作:

  前提: DとEをマージしたい。共通祖先がM1とM2の2つ。

  ステップ1: M1とM2を（再帰的に）マージする
  ┌──────────────────────────────────────────┐
  │ M1とM2の共通祖先を見つける              │
  │ → 共通祖先が1つなら通常の3-way merge     │
  │ → 複数なら更に再帰（recursive）          │
  │ → 結果として「仮想マージベース V」を得る  │
  └──────────────────────────────────────────┘

  ステップ2: 仮想マージベースVを使って、DとEを3-way merge
  - base:   V（仮想マージベース）
  - ours:   D
  - theirs: E

  → 複数の共通祖先の「統合された状態」を基準にマージを実行
```

「再帰的にマージする」とは何か。M1とM2をマージする際にも共通祖先が必要だ。その共通祖先がまた複数存在する場合、さらにそれらをマージする——この処理が再帰的に繰り返される。これが"recursive"の名の由来だ。

仮想マージベースの構築中にコンフリクトが発生する場合もある。その場合、recursiveストラテジーはコンフリクトマーカーを含んだ状態のまま仮想マージベースとして使用する。これはエッジケースであり、稀にコンフリクトマーカーが意味論的に特別扱いされないために予期しない結果を生むことがある。だが、Linux 2.6カーネルの実際のマージコミットを用いたテストでは、resolveストラテジーより少ないコンフリクトで、かつ誤マージのない結果を達成したと報告されている。

recursiveストラテジーはGit v0.99.9kからv2.33.0まで、約16年間にわたってデフォルトマージストラテジーの地位にあった。gitのマージと言えばrecursiveだった。

### ort: ゼロからの書き直し

2021年8月16日、Git 2.33のリリースとともに、Elijah Newrenが開発した**merge-ort**が導入された。"ort"は"Ostensibly Recursive's Twin"（表向きはrecursiveの双子）の頭字語だ。

ortはrecursiveの「改良版」ではない。ゼロからの完全な書き直しだ。アルゴリズムの本質——共通祖先の再帰的マージと3-way merge——は同じだが、実装のアーキテクチャが根本的に異なる。

recursiveの実装（`merge-recursive.c`）には、長年の拡張と修正の蓄積による構造的な問題があった。その最大のものが、作業ディレクトリ（ワーキングツリー）とインメモリインデックスへの依存だ。recursiveはマージの途中結果を作業ディレクトリに書き出し、インデックスを更新しながら処理を進める。これは実装上は自然だが、深刻なボトルネックになる。

第一に、ディスクI/Oが頻繁に発生する。リベース操作のように多数のコミットを順次マージする場合、コミットごとに作業ディレクトリへの書き込みとインデックスの更新が走る。

第二に、インデックスのデータ構造に起因する二次的計算量の問題がある。インデックスへのエントリの挿入・削除がO(n)であるため、大量のファイル変更を伴うマージではこの操作がボトルネックになる。

第三に、変更されていないファイルも処理対象になる。recursiveはtreeオブジェクト全体を走査するため、数万ファイルのリポジトリで数ファイルしか変更されていなくても、全ファイルを確認する。

ortはこれらの問題を、アーキテクチャレベルで解決した。

**作業ディレクトリを使わない。** ortはマージ結果を直接treeオブジェクトとして構築する。作業ディレクトリにもインデックスにも途中結果を書き出さない。全ての処理がメモリ上で完結する。マージが完了した後、最終結果を一度だけ作業ディレクトリに展開する。リベース操作では、最後のコミットの結果だけを展開すればよく、途中のコミットでは作業ディレクトリへの書き込みが不要になる。

**変更されたパスだけを処理する。** ortはtreeオブジェクトの比較時に、変更のないサブツリーをスキップする。数万ファイルのリポジトリで3ファイルだけが変更された場合、ortは3ファイルだけを処理する。

**インデックス操作のボトルネックを回避する。** ortはインメモリインデックスを使わず、独自のデータ構造でマージ結果を管理する。エントリの挿入・削除の二次的計算量の問題が発生しない。

Newrenが公開したベンチマークは、この設計の効果を劇的に示している。約26,000のリネームを含むブランチで35コミットをリベースするケース（mega-renames）では、recursiveが5,964秒かかった処理をortは661.8ミリ秒で完了した。9,012倍の高速化だ。リネームのないケース（no-renames）でも95倍、単一の大量リネームケース（just-one-mega）で565倍の高速化を達成した。

ortがデフォルトに昇格したのはGit 2.34（2021年11月）だ。Git 2.50では、`-s recursive`を指定しても内部的にortにリダイレクトされるようになった。recursiveストラテジーは、事実上ortに吸収された。

GitHubもortの恩恵を受けている。github/githubモノリスリポジトリでは、リベース操作の平均速度が10倍改善し、P99メトリクスでは5倍の改善が報告されている。ortの「作業ディレクトリ不要」というアーキテクチャは、サーバサイドでのマージ処理に特に適している。

```
マージストラテジーの設計比較:

  resolve:
  ├── 共通祖先が複数 → 1つを選択
  ├── リネーム検出 → なし
  └── デフォルト期間 → 初期バージョン

  recursive:
  ├── 共通祖先が複数 → 再帰的にマージして仮想ベースを構築
  ├── リネーム検出 → あり
  ├── 実装 → 作業ディレクトリ + インデックスに依存
  └── デフォルト期間 → v0.99.9k 〜 v2.33（約16年間）

  ort:
  ├── 共通祖先が複数 → 再帰的にマージ（recursiveと同じ原理）
  ├── リネーム検出 → あり（改善済み）
  ├── 実装 → インメモリ、作業ディレクトリ不要
  └── デフォルト期間 → v2.34 〜 現在
```

---

## 4. octopusとcherry-pick——マージの変奏

### octopus: 多腕のマージ

前回（第16回）でoctopus mergeの概要に触れた。ここでは、その内部動作をもう少し掘り下げる。

octopusマージストラテジーは、2005年8月24日にJunio C Hamanoがシェルスクリプトとして実装した（コミット`d9f3be7`、コミットメッセージは"Infamous 'octopus merge'"）。3つ以上のブランチを1つのマージコミットに統合する戦略だ。

octopusの動作原理は、反復的な3-way mergeだ。

```
octopus mergeの内部動作:

  git merge feature-a feature-b feature-c を実行した場合:

  ステップ1: 現在のHEAD（main）とfeature-aを3-way merge
  → 中間結果1を得る

  ステップ2: 中間結果1とfeature-bを3-way merge
  → 中間結果2を得る

  ステップ3: 中間結果2とfeature-cを3-way merge
  → 最終結果を得る

  → 全ステップが成功した場合、4つの親を持つマージコミットを作成
```

決定的に重要なのは、octopusの安全性ポリシーだ。いずれかのステップでコンフリクトが検出されると、octopusは全体を中断し、作業ディレクトリを元の状態に巻き戻す。Hamano自身が「octopus mergeはコンフリクトを記録するためのものではない」と明言している。

この設計判断は意図的だ。octopusは「複数のブランチが独立した変更を含み、互いに衝突しない」場合にのみ使用されることを前提としている。Linuxカーネルの開発では、Linus Torvaldsがサブシステムメンテナからの複数のプルリクエストを一度に統合する際にoctopusを用いる。各サブシステムは独立したディレクトリで開発されているため、コンフリクトは通常発生しない。

octopusがデフォルトで使用されるのは、`git merge`に3つ以上のブランチを指定した場合だ。2つのブランチのマージではort（またはrecursive）が使用される。

### cherry-pick: 3-way mergeとしてのパッチ適用

cherry-pickの内部動作は、多くのエンジニアの直感に反する。

直感的には、cherry-pickは「あるコミットの差分（パッチ）を取り出し、現在のブランチに適用する」操作に思える。実際、概念的にはその通りだ。だが、内部実装は単純なパッチ適用ではない。cherry-pickは3-way mergeとして実装されている。

Julia Evansが2023年のブログ記事で明快に解説した仕組みを、ここで整理する。

```
cherry-pickの内部動作:

  前提: コミットXをcherry-pickする
  - X の親コミット = P
  - X の変更内容 = P → X の差分
  - 現在のHEAD = H

  実行される3-way merge:
  - base（共通祖先）: P（Xの親コミット）
  - ours（HEAD側）:   H（現在のHEAD）
  - theirs:           X（cherry-pickするコミット）

  つまり:
  「Pから見てHが加えた変更」と「Pから見てXが加えた変更」を
  3-way mergeで統合する
```

なぜ3-way mergeなのか。単純なパッチ適用（diff + patch）では、適用先のコンテキストが変わっている場合に失敗しやすい。3-way mergeを使うことで、パッチの「意図」をより正確に理解し、コンテキストの変更に適応できる。

具体例で説明する。

```
例: cherry-pickが3-way mergeである利点

  コミットXの親P:
    行1: AAA
    行2: BBB
    行3: CCC

  コミットX（Pからの変更: 行2をXXXに）:
    行1: AAA
    行2: XXX
    行3: CCC

  現在のHEAD H（行1がAAAからYYYに変更されている）:
    行1: YYY
    行2: BBB
    行3: CCC

  単純なパッチ適用の場合:
  - パッチ: 「行2をBBBからXXXに変更」
  - 適用先のHで行2はBBB → 適用成功
  - 結果: 行1=YYY, 行2=XXX, 行3=CCC

  3-way mergeの場合:
  - base=P, ours=H, theirs=X
  - 行1: Pは"AAA", Hは"YYY"（oursが変更）, Xは"AAA" → "YYY"を採用
  - 行2: Pは"BBB", Hは"BBB"（変更なし）, Xは"XXX"（theirsが変更）→ "XXX"を採用
  - 行3: 全て"CCC" → "CCC"を採用
  - 結果: 行1=YYY, 行2=XXX, 行3=CCC（同じ結果）
```

この単純な例では結果は同じだ。だが、コンテキストの行番号がずれている場合や、周辺の行が変更されている場合に、3-way mergeはパッチ適用より正確にcherry-pickの「意図」を適用できる。

revert操作は、cherry-pickの逆だ。revertは対象コミットXを「取り消す」操作であり、内部的には以下の3-way mergeとして実装される。

```
revertの内部動作:

  前提: コミットXをrevertする
  - X の親コミット = P

  実行される3-way merge:
  - base（共通祖先）: X（revertするコミット自体）
  - ours（HEAD側）:   H（現在のHEAD）
  - theirs:           P（Xの親コミット）

  → cherry-pickのbase/theirsが入れ替わった形
  → 「Xの変更を取り消す」差分を3-way mergeで適用
```

gitのソースコード上でも、cherry-pickとrevertは密接に関連している。両方とも`sequencer.c`に実装されており、内部的に同じマージ関数（`do_recursive_merge()`、現在はortベース）を呼び出す。cherry-pickかrevertかの違いは、base/theirsに渡すコミットの組み合わせだけだ。

rebaseもまた、cherry-pickの連続実行として実装されている。`git rebase main`は、現在のブランチのコミットを1つずつcherry-pickしてmainの先頭に「置き直す」操作だ。ortの「作業ディレクトリ不要」というアーキテクチャが、リベースで劇的な効果を発揮する理由がここにある。recursiveは各cherry-pickで作業ディレクトリに書き込んでいたが、ortは最後のcherry-pickの結果だけを書き出せばよい。

---

## 5. コンフリクトの解剖——gitが作り出す内部状態

### マージが失敗するとき

3-way mergeの判定ルールを前回（第16回）で示した。「両方が同じ箇所を異なる内容に変更した場合」、gitはコンフリクトを宣言する。このとき、gitは内部にどのような状態を作り出すのか。

コンフリクトが発生すると、gitは以下の4つの状態を作り出す。

**第一に、`.git/MERGE_HEAD`ファイル。** マージ対象のコミットのSHA-1ハッシュが記録される。octopusマージの場合は複数行になる。このファイルの存在自体が「マージが進行中である」ことを示すマーカーだ。`git commit`はこのファイルが存在する場合、マージコミット（複数の親を持つコミット）を作成する。

**第二に、`.git/MERGE_MSG`ファイル。** 自動生成されたマージコミットメッセージが格納される。`Merge branch 'feature' into main`といったメッセージだ。コンフリクトを解消して`git commit`すると、このメッセージがデフォルトのコミットメッセージとして使用される。

**第三に、作業ディレクトリのコンフリクトマーカー。** コンフリクトが発生したファイルには、以下の形式のマーカーが挿入される。

```
<<<<<<< HEAD
（HEAD側の変更内容）
=======
（マージ対象側の変更内容）
>>>>>>> feature
```

`git merge`に`--diff3`スタイルを設定している場合（`git config merge.conflictStyle diff3`）、共通祖先の内容も表示される。

```
<<<<<<< HEAD
（HEAD側の変更内容）
||||||| merged common ancestors
（共通祖先の内容）
=======
（マージ対象側の変更内容）
>>>>>>> feature
```

diff3スタイルは、コンフリクト解消を大幅に容易にする。共通祖先の内容が見えることで、「元々どうだったのか」「両者がそれぞれ何を意図して変更したのか」が明確になる。私は全てのgit環境でdiff3スタイルを設定することを強く推奨する。

**第四に、インデックスのstage番号。** これがマージの内部状態の核心だ。

通常のインデックス（ステージングエリア）では、各ファイルはstage 0として記録されている。コンフリクトが発生すると、該当ファイルのstage 0エントリが消え、代わりに3つのエントリが作られる。

```
インデックスのstage番号:

  通常時:
  stage 0: app.py (HEAD の内容)

  コンフリクト時:
  stage 1: app.py (共通祖先 / base の内容)
  stage 2: app.py (HEAD側 / ours の内容)
  stage 3: app.py (MERGE_HEAD側 / theirs の内容)
```

stage 1が共通祖先（base）、stage 2がHEAD側（ours）、stage 3がMERGE_HEAD側（theirs）。これは3-way mergeの3つの入力そのものだ。

`git ls-files -u`（-uは"unmerged"）コマンドで、コンフリクト状態のインデックスエントリを確認できる。各エントリのstage番号、ファイルモード、blobのSHA-1ハッシュが表示される。

```bash
$ git ls-files -u
100644 a1b2c3d... 1 app.py    # stage 1: 共通祖先
100644 d4e5f6a... 2 app.py    # stage 2: ours (HEAD)
100644 b7c8d9e... 3 app.py    # stage 3: theirs (MERGE_HEAD)
```

各ステージの内容は`git show`で直接取得できる。

```bash
$ git show :1:app.py    # stage 1（共通祖先）の内容
$ git show :2:app.py    # stage 2（ours）の内容
$ git show :3:app.py    # stage 3（theirs）の内容
```

コンフリクトの解消とは、これら3つのステージを「解決」し、stage 0に統合する操作だ。`git add app.py`を実行すると、stage 1, 2, 3が削除され、作業ディレクトリの現在の`app.py`がstage 0として記録される。全てのファイルがstage 0に戻ったとき、マージは完了可能な状態になる。

### なぜstage番号を知る必要があるのか

stage番号の知識は、実用的な場面で役に立つ。

たとえば、大量のコンフリクトを一括で処理する場合。「全てのコンフリクトでtheirs（マージ対象側）を採用する」という判断ができるなら、以下のように操作できる。

```bash
# 全てのコンフリクトファイルでtheirs（stage 3）を採用
git ls-files -u | awk '{print $4}' | sort -u | while read file; do
  git checkout --theirs -- "$file"
  git add "$file"
done
```

あるいは、特定のファイルだけ共通祖先の内容に戻して、そこから手動で編集をやり直したい場合。

```bash
# stage 1（共通祖先）の内容を取得して編集の起点にする
git show :1:app.py > app.py
# 手動で編集した後
git add app.py
```

stage番号を知らなければ、コンフリクトマーカーを1つずつ手動で編集するしかない。stage番号を知っていれば、マージの内部状態に直接アクセスし、より効率的で正確なコンフリクト解消が可能になる。

---

## 6. ハンズオン：マージの内部を追跡する

マージアルゴリズムの理解を「体感」に変えるために、意図的にコンフリクトを起こし、gitの内部状態を追跡する。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y git
```

### 演習1：コンフリクト時の内部状態を観察する

```bash
WORKDIR="${HOME}/vcs-handson-17"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=== 演習1: コンフリクト時の内部状態を観察する ==="
echo ""

# gitの設定（Docker環境用）
git config --global user.email "handson@example.com"
git config --global user.name "Handson User"
git config --global init.defaultBranch main

# リポジトリの初期化
git init --quiet conflict-demo
cd conflict-demo

# 共通祖先（base）を作成
cat > app.py << 'PYEOF'
# app.py - バージョン管理デモ
def greet(name):
    return f"Hello, {name}!"

def calculate(x, y):
    return x + y

if __name__ == "__main__":
    print(greet("World"))
    print(calculate(1, 2))
PYEOF
git add app.py
git commit --quiet -m "Base version"

# mainブランチで変更
cat > app.py << 'PYEOF'
# app.py - バージョン管理デモ
def greet(name):
    return f"Hi, {name}! Welcome!"

def calculate(x, y):
    return x + y

if __name__ == "__main__":
    print(greet("World"))
    print(calculate(1, 2))
PYEOF
git add app.py
git commit --quiet -m "Change greeting message (main)"

# featureブランチで同じ箇所を異なる内容に変更
git checkout --quiet -b feature HEAD~1
cat > app.py << 'PYEOF'
# app.py - バージョン管理デモ
def greet(name):
    return f"Good morning, {name}!"

def calculate(x, y):
    return x + y

if __name__ == "__main__":
    print(greet("World"))
    print(calculate(1, 2))
PYEOF
git add app.py
git commit --quiet -m "Change greeting message (feature)"

# mainに戻ってマージ（コンフリクトが発生する）
git checkout --quiet main
echo "--- マージを実行（コンフリクトが発生する）---"
git merge feature || true
echo ""

echo "--- .git/MERGE_HEAD の内容 ---"
cat .git/MERGE_HEAD
echo "-> マージ対象のコミットSHA-1"
echo ""

echo "--- .git/MERGE_MSG の内容 ---"
cat .git/MERGE_MSG
echo ""

echo "--- インデックスのstage番号（git ls-files -u）---"
git ls-files -u
echo ""
echo "-> stage 1=共通祖先, stage 2=ours(HEAD), stage 3=theirs(MERGE_HEAD)"
echo ""

echo "--- 各stageの内容 ---"
echo "[stage 1: 共通祖先（base）]"
git show :1:app.py | head -4
echo "..."
echo ""
echo "[stage 2: ours（HEAD / main）]"
git show :2:app.py | head -4
echo "..."
echo ""
echo "[stage 3: theirs（MERGE_HEAD / feature）]"
git show :3:app.py | head -4
echo "..."
echo ""

echo "--- 作業ディレクトリのコンフリクトマーカー ---"
cat app.py
echo ""
echo "-> <<<<<<< HEAD と >>>>>>> feature の間がコンフリクト箇所"

# コンフリクトを解消
echo ""
echo "--- コンフリクトを解消する ---"
cat > app.py << 'PYEOF'
# app.py - バージョン管理デモ
def greet(name):
    return f"Hi, {name}! Good morning!"

def calculate(x, y):
    return x + y

if __name__ == "__main__":
    print(greet("World"))
    print(calculate(1, 2))
PYEOF
git add app.py

echo "--- 解消後のインデックス（git ls-files -s app.py）---"
git ls-files -s app.py
echo ""
echo "-> stage 0に統合された（コンフリクト解消完了）"

git commit --quiet --no-edit
echo ""
echo "--- マージコミットの親 ---"
git cat-file -p HEAD | grep parent
echo "-> 2つのparentを持つマージコミットが作成された"
```

### 演習2：cherry-pickが3-way mergeであることを確認する

```bash
echo ""
echo "=== 演習2: cherry-pickが3-way mergeであることを確認する ==="
echo ""

cd "${WORKDIR}"
git init --quiet cherry-demo
cd cherry-demo
git config user.email "handson@example.com"
git config user.name "Handson User"

# ベースとなるコードを作成
cat > util.py << 'PYEOF'
# util.py
def add(a, b):
    return a + b

def multiply(a, b):
    return a * b
PYEOF
git add util.py
git commit --quiet -m "Initial util.py"

# featureブランチでmultiplyを変更
git checkout --quiet -b feature
cat > util.py << 'PYEOF'
# util.py
def add(a, b):
    return a + b

def multiply(a, b):
    """Multiply two numbers."""
    return a * b
PYEOF
git add util.py
git commit --quiet -m "Add docstring to multiply"
FEATURE_COMMIT=$(git rev-parse HEAD)

# さらにfeatureでaddも変更
cat > util.py << 'PYEOF'
# util.py
def add(a, b):
    """Add two numbers."""
    return a + b

def multiply(a, b):
    """Multiply two numbers."""
    return a * b
PYEOF
git add util.py
git commit --quiet -m "Add docstring to add"

# mainに戻り、独自の変更を加える
git checkout --quiet main
cat > util.py << 'PYEOF'
# util.py
def add(a, b):
    return a + b

def multiply(a, b):
    return a * b

def subtract(a, b):
    return a - b
PYEOF
git add util.py
git commit --quiet -m "Add subtract function"

echo "--- cherry-pick前のmainのutil.py ---"
cat util.py
echo ""

echo "--- cherry-pickするコミット（multiplyにdocstring追加）---"
echo "コミット: ${FEATURE_COMMIT:0:12}"
git log --oneline -1 "${FEATURE_COMMIT}"
echo ""

# cherry-pickを実行
echo "--- cherry-pickを実行 ---"
git cherry-pick "${FEATURE_COMMIT}"
echo ""

echo "--- cherry-pick後のutil.py ---"
cat util.py
echo ""
echo "-> multiplyへのdocstring追加がcherry-pickされた"
echo "   mainで追加したsubtract関数はそのまま残っている"
echo "   これは単純なパッチ適用ではなく、3-way mergeの結果"
echo ""
echo "   内部動作:"
echo "   - base: cherry-pickコミットの親（Initial util.py）"
echo "   - ours: 現在のHEAD（subtract追加済み）"
echo "   - theirs: cherry-pickコミット（docstring追加済み）"
echo "   → baseからoursへの変更（subtract追加）と"
echo "     baseからtheirsへの変更（docstring追加）を3-way mergeで統合"
```

### 演習3：merge-baseの動作を確認する

```bash
echo ""
echo "=== 演習3: merge-baseの動作を確認する ==="
echo ""

cd "${WORKDIR}"
git init --quiet mergebase-demo
cd mergebase-demo
git config user.email "handson@example.com"
git config user.name "Handson User"

# 共通の履歴を構築
echo "v1" > file.txt
git add file.txt
git commit --quiet -m "Commit A"
A=$(git rev-parse HEAD)

echo "v2" > file.txt
git add file.txt
git commit --quiet -m "Commit B"
B=$(git rev-parse HEAD)

# 2つのブランチに分岐
git checkout --quiet -b branch-1
echo "v3-branch1" > file.txt
git add file.txt
git commit --quiet -m "Commit C (branch-1)"
C=$(git rev-parse HEAD)

git checkout --quiet main
echo "v3-main" > file.txt
git add file.txt
git commit --quiet -m "Commit D (main)"
D=$(git rev-parse HEAD)

echo "--- コミットグラフ ---"
echo "  A($( echo ${A} | cut -c1-7)) ← B($(echo ${B} | cut -c1-7)) ← D($(echo ${D} | cut -c1-7))  [main]"
echo "                                    └── C($(echo ${C} | cut -c1-7))  [branch-1]"
echo ""

echo "--- merge-base main branch-1 ---"
MERGE_BASE=$(git merge-base main branch-1)
echo "${MERGE_BASE}"
echo ""
if [ "${MERGE_BASE}" = "${B}" ]; then
  echo "-> merge-baseはB（分岐点）= $(echo ${B} | cut -c1-7)"
  echo "   これが3-way mergeの共通祖先として使用される"
else
  echo "-> 予期しない結果"
fi
echo ""

# マージしてからさらにmerge-baseを確認
echo "--- マージ後のmerge-base ---"
git merge --quiet --no-edit branch-1 2>/dev/null || git merge --quiet --no-edit -X ours branch-1
M=$(git rev-parse HEAD)

echo "マージ後:"
echo "  A ← B ← D ← M($(echo ${M} | cut -c1-7))  [main]"
echo "            └── C ──┘            [branch-1]"
echo ""

# branch-1をさらに進める
git checkout --quiet branch-1
echo "v4-branch1" > file.txt
git add file.txt
git commit --quiet -m "Commit E (branch-1)"
E=$(git rev-parse HEAD)

git checkout --quiet main
echo "v4-main" > file.txt
git add file.txt
git commit --quiet -m "Commit F (main)"
F=$(git rev-parse HEAD)

echo "さらに進めた後:"
echo "  A ← B ← D ← M ← F($(echo ${F} | cut -c1-7))  [main]"
echo "            └── C ── ↗ ── E($(echo ${E} | cut -c1-7))  [branch-1]"
echo ""

NEW_BASE=$(git merge-base main branch-1)
echo "新しいmerge-base: $(echo ${NEW_BASE} | cut -c1-7)"
echo ""
if [ "${NEW_BASE}" = "${M}" ] || [ "${NEW_BASE}" = "${C}" ]; then
  echo "-> マージコミットMまたはCが新しい共通祖先"
  echo "   一度マージした後は、共通祖先がマージポイントに進む"
  echo "   これがgitのDAG構造によるマージ追跡の仕組み"
fi
```

### 演習4：diff3スタイルのコンフリクト表示を体験する

```bash
echo ""
echo "=== 演習4: diff3スタイルのコンフリクト表示 ==="
echo ""

cd "${WORKDIR}"
git init --quiet diff3-demo
cd diff3-demo
git config user.email "handson@example.com"
git config user.name "Handson User"

# diff3スタイルを設定
git config merge.conflictStyle diff3

# コンフリクトを生成
echo "original content" > readme.txt
git add readme.txt
git commit --quiet -m "Base"

git checkout --quiet -b feature
echo "feature content" > readme.txt
git add readme.txt
git commit --quiet -m "Feature change"

git checkout --quiet main
echo "main content" > readme.txt
git add readme.txt
git commit --quiet -m "Main change"

echo "--- diff3スタイルでマージ（コンフリクト発生）---"
git merge feature || true
echo ""

echo "--- コンフリクトマーカー（diff3スタイル）---"
cat readme.txt
echo ""
echo '-> ||||||| で区切られた箇所が「共通祖先の内容」'
echo "   共通祖先が見えることで、両者が何を変更したかが明確になる"
echo "   git config merge.conflictStyle diff3 を強く推奨する"
```

### 演習で見えたこと

四つの演習を通じて、gitのマージの内部動作を直接確認した。

演習1では、コンフリクト時にgitが作り出す4つの内部状態——MERGE_HEAD、MERGE_MSG、コンフリクトマーカー、インデックスのstage番号——を確認した。`git ls-files -u`でstage 1/2/3のエントリが見え、`git show :N:file`で各ステージの内容を直接取得できる。コンフリクトの解消は、これら3つのステージをstage 0に統合する操作だ。

演習2では、cherry-pickが単純なパッチ適用ではなく3-way mergeとして実装されていることを確認した。cherry-pickするコミットの親をbase、コミット自体をtheirs、現在のHEADをoursとして3-way mergeを実行する。これにより、パッチの「意図」がコンテキストの変更に適応できる。

演習3では、`git merge-base`が分岐点の共通祖先を発見するアルゴリズムであることを確認した。マージ後は共通祖先がマージポイントに進み、次のマージでは新しい共通祖先が使われる。これがDAG構造によるマージ追跡の仕組みだ。

演習4では、diff3スタイルのコンフリクト表示を体験した。共通祖先の内容が表示されることで、コンフリクトの原因分析と解消が容易になる。

---

## 7. まとめと次回予告

### この回の要点

第一に、マージは共通祖先の発見（merge-base）から始まる。`git merge-base`はDAG上の最良共通祖先（LCA）を発見するアルゴリズムであり、criss-cross mergeのように複数の最良共通祖先が存在する場合がある。この「複数の共通祖先」への対処が、マージストラテジーの核心的な違いだ。

第二に、resolveストラテジーは複数の共通祖先から1つを選択するだけだったが、recursiveストラテジー（Fredrik Kuivinen、2005年9月）は複数の共通祖先を再帰的にマージして仮想マージベースを構築する。この再帰的処理が"recursive"の名の由来であり、Linux 2.6カーネルのテストでresolveより優れた結果を示した。

第三に、ort（Elijah Newren、2021年8月、Git 2.33）はrecursiveのゼロからの書き直しであり、作業ディレクトリを使わないインメモリアーキテクチャが最大の革新だ。マージ結果を直接treeオブジェクトとして構築し、変更されたパスだけを処理することで、極端なケースで最大9,012倍の高速化を達成した。

第四に、cherry-pickとrevertは内部的に3-way mergeとして実装されている。cherry-pickは対象コミットの親をbase、コミットをtheirs、HEADをoursとしてマージを実行する。revertはその逆だ。rebaseはcherry-pickの連続実行であり、ortのインメモリアーキテクチャがリベースで劇的な効果を発揮する理由はここにある。

第五に、コンフリクト時にgitはMERGE_HEAD、MERGE_MSG、コンフリクトマーカー、インデックスのstage番号（1=base, 2=ours, 3=theirs）という4つの内部状態を作り出す。これらの状態に直接アクセスすることで、より効率的なコンフリクト解消が可能になる。

### 冒頭の問いへの暫定回答

gitのマージは「魔法」ではない。では何が起きているのか。

答えは、3-way mergeという明確なアルゴリズムと、その入力となる共通祖先の発見アルゴリズムの組み合わせだ。マージストラテジーの違いは、共通祖先が複数存在する場合の対処方法の違いに帰着する。そして、その上に構築されたcherry-pick、revert、rebaseは、いずれも3-way mergeの変奏だ。

マージアルゴリズムの理解は、コンフリクト解消能力に直結する。コンフリクトが発生したとき、stage番号を通じて3つの入力——共通祖先、ours、theirs——に直接アクセスできる。diff3スタイルを使えば、共通祖先の内容がコンフリクトマーカーに表示される。「何が起きているか」が見えれば、「どう解消すべきか」の判断は格段に容易になる。

マージの内部を知らなくても、gitは使える。だが、知っているエンジニアと知らないエンジニアでは、コンフリクトに直面したときの対応力が根本的に異なる。これは、道具を「使える」ことと「理解している」ことの違いだ。

### 次回予告

gitの内部構造を3回にわたって解剖してきた——オブジェクトモデル（第15回）、ブランチ（第16回）、マージ（今回）。これらの理解を踏まえた上で、gitの「弱点」に目を向ける。

**第18回「分散の代償——Gitのトレードオフ」**

次回は、gitが何を犠牲にして何を得たのかを問う。巨大バイナリファイルの扱い、巨大リポジトリでの性能問題、Git LFSの設計と妥協、shallow cloneとsparse checkoutの仕組み。内容アドレス可能ストレージという設計の本質的な制約と、モノレポ vs マルチレポの判断を考える。

完璧なツールは存在しない。gitの弱点を知ることは、gitを「盲信」から解放し、適切な運用判断につなげる第一歩だ。あなたのプロジェクトで、gitの弱点に遭遇したことはあるだろうか。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Git SCM, "merge-strategies Documentation." <https://git-scm.com/docs/merge-strategies>
- Git SCM, "git-merge-base Documentation." <https://git-scm.com/docs/git-merge-base>
- Git SCM, "Git Tools - Advanced Merging." Pro Git, 2nd Edition. <https://git-scm.com/book/en/v2/Git-Tools-Advanced-Merging>
- Git commit 720d150, "Add a new merge strategy by Fredrik Kuivinen." 2005-09. <https://github.com/git/git/commit/720d150c48fc35fca13c6dfb3c76d60e4ee83b87>
- Git commit e4cf17c, "Rename the 'fredrik' merge strategy to 'recursive'." 2005-09-13. <https://github.com/git/git/commit/e4cf17ce0db2dab7c9525a732f86c5e3df3b4ed0>
- Git commit d9f3be7, "Infamous 'octopus merge'." 2005-08-24. <https://github.com/git/git/commit/d9f3be7e2e4c9b402bbe6ee6e2b39b2ee89132cf>
- Newren, E., "Change default merge backend from recursive to ort." git mailing list, 2021-08. <https://lore.kernel.org/git/4a0f088f3669a95c7f75e885d06c0a3bdaf31f42.1628055482.git.gitgitgadget@gmail.com/>
- The Register, "Git 2.33 released with new optional merge process likely to become the default." 2021-08-17. <https://www.theregister.com/2021/08/17/git_233/>
- talent500.com, "Scaling Merge-Ort at GitHub: Enhancing Performance and Accuracy." <https://talent500.com/blog/scaling-merge-ort-github/>
- Evans, J., "How git cherry-pick and revert use 3-way merge." 2023-11-10. <https://jvns.ca/blog/2023/11/10/how-cherry-pick-and-revert-work/>
- Khanna, S., Kunal, K. and Pierce, B. C., "A Formal Investigation of Diff3." FSTTCS, 2007. <https://www.cis.upenn.edu/~bcpierce/papers/diff3-short.pdf>
- Coglan, J., "Merging with diff3." 2017-05-08. <https://blog.jcoglan.com/2017/05/08/merging-with-diff3/>
- Plastic SCM Blog, "More on recursive merge strategy." 2012. <https://blog.plasticscm.com/2012/01/more-on-recursive-merge-strategy.html>
- Git SCM, "git-cherry-pick Documentation." <https://git-scm.com/docs/git-cherry-pick>
- Wikipedia, "diff3." <https://en.wikipedia.org/wiki/Diff3>
