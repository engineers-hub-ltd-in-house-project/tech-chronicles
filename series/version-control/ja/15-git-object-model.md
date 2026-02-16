# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第15回：Gitオブジェクトモデル——blob, tree, commit, tag

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- gitの4つのオブジェクトタイプ（blob, tree, commit, tag）の正確な内部バイナリ形式
- SHA-1ハッシュがどのように計算されるか——ヘッダフォーマット「{type} {size}\0{content}」の全貌
- 内容アドレス可能ストレージ（CAS）の思想的ルーツ——Plan 9のVentiからgitへの系譜
- zlib圧縮によるlooseオブジェクトの格納形式と.git/objectsディレクトリの設計
- packファイルのデルタ圧縮——OFS_DELTAとREF_DELTAの仕組み
- annotated tagとlightweight tagの内部構造の違い
- SHA-1からSHA-256への移行の現在（Git 3.0に向けた進捗）
- オブジェクトのライフサイクル——loose、pack、gcによる整理

---

## 1. .git/objectsを覗いた日

私が初めて`.git/objects`ディレクトリの中身を覗いたのは、2010年代の初め頃だ。

当時の私はSubversionからgitへの移行を進めていた。gitの基本操作——`add`、`commit`、`push`、`pull`——は覚えた。ブランチの作成もマージも、CVS時代とは比較にならない速さで完了する。便利だ。だが、何をやっているのかがわからない。Subversionなら理解できた。リビジョン番号があり、サーバにリポジトリがあり、`svn log -r 1234`で特定のリビジョンを参照できる。構造が頭の中で見える。gitは違った。40文字の十六進文字列が飛び交い、`HEAD`だの`refs/heads/main`だのという謎の参照があり、`detached HEAD`という不気味な状態に陥ることがある。何が起きているのかが、見えない。

ある日、私は`.git`ディレクトリを`ls`してみた。

```
.git/
├── HEAD
├── config
├── objects/
│   ├── 0a/
│   ├── 1f/
│   ├── 3c/
│   ├── ...
│   ├── info/
│   └── pack/
├── refs/
│   ├── heads/
│   └── tags/
└── ...
```

`objects`ディレクトリの下に、2文字のディレクトリが並んでいる。`0a`、`1f`、`3c`——。その中にファイルがある。ファイル名は38文字の十六進文字列だ。`cat`してみると、バイナリデータが表示される。読めない。

`git cat-file -p`というコマンドの存在を知ったのは、その翌日だ。SHA-1ハッシュを引数に渡すと、オブジェクトの中身が人間に読める形式で表示される。blobはファイルの内容。treeはディレクトリのエントリ一覧。commitは著者情報とメッセージ。

「こうなっていたのか」——その瞬間、gitの挙動が「予測可能」になった。`git add`が何をしているのか。`git commit`が何を作っているのか。`git checkout`が何を切り替えているのか。全てが、4種類のオブジェクトとそれらを指すポインタの操作として理解できるようになった。

**gitは内部でデータをどう保持しているのか。それを知ると何が変わるのか。** 前回（第14回）でgitの誕生とオブジェクトモデルの概要を紹介した。今回は、その内部に踏み込む。バイナリレベルでオブジェクトの構造を解剖し、ハッシュがどう計算され、圧縮がどう施され、packファイルがどう最適化されるのかを追う。

あなたのgitの理解は、「使える」レベルだろうか、それとも「見える」レベルだろうか。

---

## 2. 内容アドレス可能ストレージの系譜——VentiからMonotone、そしてgitへ

### Plan 9のVenti——「内容が住所」という発想

gitのオブジェクトモデルを理解するには、その思想的ルーツに触れる必要がある。

2002年、Bell LabsのSean QuinlanとSean Dorwardは、Plan 9オペレーティングシステムのために「Venti」というアーカイブストレージシステムを発表した。USENIXのFAST '02（Conference on File and Storage Technologies）で発表されたこの論文は、Best Paper Awardを受賞した。

Ventiの核心は、データブロックの内容のSHA-1ハッシュを、そのブロックの「住所」として使うことだ。通常のファイルシステムでは、データは「場所」で管理される——セクター番号、ブロック番号、iノード番号。データの内容が変わっても、住所は変わらない。Ventiは逆だ。データの内容そのものが住所を決定する。内容が同じなら住所も同じ。内容が1ビットでも違えば住所も変わる。

この設計には二つの重要な帰結がある。

第一に、書き込みは本質的にwrite-onceだ。同じ住所に異なる内容を書き込むことはできない（住所が内容によって決まるのだから、異なる内容は異なる住所を持つ）。したがって、一度書かれたデータは上書きされない。アーカイブストレージとして理想的な性質だ。

第二に、重複排除が自動的に行われる。同じ内容のデータは、何度書き込んでも同じ住所を持つ。すでにその住所にデータが存在するなら、追加の格納は不要だ。

この「内容アドレス可能ストレージ（Content-Addressable Storage: CAS）」という設計パターンは、Venti以前にも存在していた。暗号学やネットワーキングの分野で、データの指紋（フィンガープリント）をハッシュ関数で算出するアイデア自体は古い。だがVentiは、それをファイルシステムの基盤として実用化した先駆的な実装の一つだ。

### MonotoneがつなぐVentiとgit

前回（第14回）で述べたように、gitの設計にMonotoneのアイデアが影響したことは明確だ。Graydon Hoareが2003年に開始したMonotoneは、SHA-1ハッシュによるオブジェクト識別と内容アドレス可能ストレージを分散型VCSに適用した。Linus TorvaldsはLKMLでMonotoneに言及し、その設計思想に一定の評価を示しつつも、実装（SQLiteデータベース + C++抽象化レイヤー）が性能を犠牲にしていると批判した。

gitがVentiから「直接」影響を受けたかどうかは、文献上明確ではない。TorvaldsがVentiの論文を読んでいたかどうかは、私の知る限り確認できない。だが、Bell Labs → Plan 9 → Ventiという系譜と、OSSコミュニティ → Monotone → gitという系譜は、CASという共通のアイデアで結ばれている。

重要なのは、gitがMonotoneのCAS思想を採用しつつ、実装において根本的に異なるアプローチを取ったことだ。Monotoneはデータベース（SQLite）にオブジェクトを格納した。gitはファイルシステムに直接格納した。SHA-1ハッシュの先頭2文字をディレクトリ名、残り38文字をファイル名とする。この「愚直な」設計が、データベースのオーバーヘッドを排除し、gitに圧倒的な性能を与えた。

TorvaldsがMonotoneについて「SQLiteはreal databaseだ」と述べたとき、それは褒め言葉ではなかった。gitにとって、オブジェクトの格納はファイルの読み書きと同義でなければならなかった。抽象化レイヤーを一つ挟むことのコストを、Torvaldsは許容しなかった。

### CASがバージョン管理にもたらすもの

CASがバージョン管理に適している理由を、改めて整理する。

バージョン管理の本質は「変更の記録」だ。変更を記録するには、「ある時点の状態」を確実に保存し、「別の時点の状態」と比較できなければならない。CASは、この要件に対する優れた解を提供する。

CASでは、データの完全性がハッシュによって保証される。保存したデータを後から取り出したとき、ハッシュを再計算して元のハッシュと比較すれば、データが完全に保存されていることを確認できる。1ビットの改竄、1バイトの破損も見逃さない。

さらに、CASでは同一内容のデータが自動的に共有される。バージョン管理では、多くのファイルがバージョン間で変更されない。100個のファイルのうち1個だけ変更された場合、CASでは変更されなかった99個のファイルは前のバージョンと同じオブジェクトを参照する。ストレージの効率化が、設計レベルで組み込まれている。

gitは、このCASの原理を4種類のオブジェクト——blob、tree、commit、tag——で実装した。次の章で、その内部構造を解剖する。

---

## 3. 4つのオブジェクト——バイナリレベルの解剖

### 全オブジェクトに共通するルール

gitの全てのオブジェクトは、同じルールに従って作られる。

```
オブジェクトの格納プロセス:

  1. ヘッダの構築
     "{type} {size}\0"
     type  = blob | tree | commit | tag
     size  = contentのバイト数（10進数文字列）
     \0    = NULLバイト（0x00）

  2. SHA-1ハッシュの計算
     SHA-1(header + content) → 40文字の十六進文字列

  3. zlib圧縮
     zlib_deflate(header + content) → 圧縮データ

  4. ファイルシステムに格納
     .git/objects/{SHA-1先頭2文字}/{SHA-1残り38文字}
```

具体例で示す。ファイルの内容が "hello world\n"（12バイト）の場合:

```
ヘッダ:       "blob 12\0"        （9バイト）
結合:         "blob 12\0hello world\n"  （21バイト）
SHA-1:        95d09f2b10159347eece71399a7e2e907ea3df4f
zlib圧縮後:   バイナリデータ
格納先:       .git/objects/95/d09f2b10159347eece71399a7e2e907ea3df4f
```

このプロセスは全オブジェクトタイプで同一だ。異なるのは`type`文字列と`content`の形式だけである。SHA-1ハッシュが「内容の指紋」として機能するため、同じ内容は常に同じハッシュ値を持ち、同じ格納先に収まる。これがCASの原理だ。

先頭2文字をディレクトリ名にしている理由は、ファイルシステムの性能対策だ。多くのファイルシステムは、1つのディレクトリに大量のファイルが集中すると性能が劣化する。256個のサブディレクトリに分散させることで、この問題を回避している。

### blob——内容だけの純粋なオブジェクト

blobオブジェクトは、gitの中で最も単純なオブジェクトだ。ファイルの内容そのものを格納する。ファイル名を持たない。パーミッションを持たない。タイムスタンプを持たない。純粋に内容だけだ。

```
blobオブジェクトの構造:

  ヘッダ: "blob {size}\0"
  内容:   ファイルの生バイト列

  例: "Hello, World!" という13バイトのファイル
  ヘッダ + 内容 = "blob 13\0Hello, World!"
```

「ファイル名を持たない」という設計判断は、深い意味を持つ。

Linus Torvaldsは「gitはコンテンツを追跡するのであって、ファイルを追跡するのではない」と明言した。blobが名前を持たないことは、この哲学の直接的な表現だ。同じ内容のファイルがプロジェクト内に複数存在しても——`src/config.json`と`test/fixtures/config.json`が同一の場合——gitのオブジェクトデータベースにはblobが1つしか存在しない。名前やパスが違っても、内容が同じならオブジェクトも同じ。

この設計の帰結として、gitはファイルのリネームを明示的に追跡しない。BitKeeperはリネームを第一級の操作として追跡した。gitはしない。代わりに、`git diff`や`git log`がファイル内容の類似度をヒューリスティックに検出する。デフォルトの閾値は50%——内容の50%以上が一致していれば「リネーム」と判定する。

### tree——ディレクトリ構造のスナップショット

treeオブジェクトは、ある時点のディレクトリ構造を記録する。各エントリは、モード（パーミッション）、オブジェクトタイプ、SHA-1ハッシュ、ファイル名（またはサブディレクトリ名）の組だ。

`git cat-file -p`で表示される人間可読な形式はこうなる:

```
treeオブジェクトの表示例:

  100644 blob af5626b...  README.md
  100644 blob 3b18e51...  main.py
  100755 blob 8f94139...  setup.sh
  040000 tree 99f1a6d...  src/
  120000 blob a1b2c3d...  config.link
```

モード値は限定的だ。UNIXの柔軟なパーミッション体系のサブセットしかgitは追跡しない。

```
gitが追跡するモード:

  モード    意味                      対象
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  100644    通常ファイル（非実行）    blob
  100755    実行可能ファイル          blob
  120000    シンボリックリンク        blob（リンク先パスを格納）
  040000    サブディレクトリ          tree
  160000    gitlink（サブモジュール） commit（外部リポジトリの参照）
```

この5種類だけだ。UNIXの`chmod 644`、`chmod 755`以外の細かなパーミッション（例えば`chmod 600`や`chmod 664`）は区別されない。gitにとって重要なのは「実行可能かどうか」という1ビットの情報だけなのだ。

treeオブジェクトの実際のバイナリ形式は、`cat-file -p`の表示とは異なる。

```
treeエントリのバイナリ形式:

  {mode} {name}\0{20バイトのSHA-1バイナリ}

  例:
  "100644 README.md\0" + [SHA-1の20バイトバイナリ]
  "040000 src\0" + [SHA-1の20バイトバイナリ]
```

注意すべきは、バイナリ形式ではSHA-1が十六進文字列（40文字）ではなく、生のバイナリ（20バイト）で格納されることだ。これはストレージ効率のための最適化である。20バイト × エントリ数 vs 40バイト × エントリ数——大規模リポジトリでは無視できない差になる。

treeオブジェクトが再帰的にtreeを参照できることで、gitは任意の深さのディレクトリ構造を表現する。プロジェクトのルートディレクトリに対応するtreeが、各コミットの「スナップショット」の実体だ。

### commit——時間と因果を記録する

commitオブジェクトは、gitの履歴を構成する核心的なオブジェクトだ。

```
commitオブジェクトの構造:

  tree {treeのSHA-1}
  parent {親commitのSHA-1}        ← 0個以上（初回コミットは0個、マージは2個以上）
  author {名前} <{メール}> {UNIXタイムスタンプ} {タイムゾーン}
  committer {名前} <{メール}> {UNIXタイムスタンプ} {タイムゾーン}

  {コミットメッセージ}
```

実際の例を見る:

```
tree 4b825dc642cb6eb9a060e54bf899d15f5ca25c45
parent a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0
author Yusuke Sato <yusuke@example.com> 1707000000 +0900
committer Yusuke Sato <yusuke@example.com> 1707000000 +0900

Fix memory leak in connection pool
```

ここで重要なのは、authorとcommitterが分離されていることだ。多くの開発者はこの区別を意識したことがないだろう。一人で開発している場合、両者は常に同じだ。

この分離は、Linuxカーネルの開発ワークフローを反映している。カーネル開発では、パッチの著者（author）とそれをリポジトリに適用するメンテナ（committer）が異なることが日常だ。あるカーネル開発者がパッチを書き、サブシステムメンテナがそれをレビューして自分のブランチに取り込み、最終的にLinus Torvaldsがmainlineにマージする。このとき、authorは元のパッチ作者であり、committerはマージを行った人物だ。

`git am`（メールからのパッチ適用）や`git cherry-pick`を使うと、この区別が実際に発生する。

```
authorとcommitterが異なる例:

  author   Alice <alice@example.com>   1707000000 +0000
  committer Bob <bob@example.com>      1707100000 +0000

  → Aliceがパッチを書き、Bobがそれを適用した
```

commitオブジェクトのもう一つの重要な性質は、parentフィールドによってDAG（有向非巡回グラフ）を形成することだ。各commitは0個以上の親commitを参照する。初回コミットは親を持たない（ルートコミット）。通常のコミットは親を1つ持つ。マージコミットは親を2つ以上持つ。

```
DAGとしてのgit履歴:

  A ← B ← C ← D          （直線的な履歴）

  A ← B ← D               （マージ）
       ↑   ↑
       C ──┘

  A                        （ルートコミット、parent = 0個）
```

このDAG構造が、gitのブランチ・マージ・リベースの全ての基盤となる。ブランチは、DAGの中の特定のcommitを指すポインタだ。マージは、2つのcommitを親に持つ新しいcommitの作成だ。詳細は次回（第16回）で掘り下げる。

### tag——リリースに名前を刻む

gitの4つ目のオブジェクトタイプがtagだ。ただし、注意が必要である。gitには「タグ」が2種類存在し、そのうち一方だけがオブジェクトを作成する。

```
gitの2種類のタグ:

  lightweight tag（軽量タグ）:
  ├── .git/refs/tags/{タグ名} にcommitのSHA-1を書いた41バイトのファイル
  ├── gitオブジェクトは作成されない
  ├── 単なる「名前付きポインタ」
  └── git tag v1.0 で作成

  annotated tag（注釈付きタグ）:
  ├── .git/objects/ に独立したtagオブジェクトを作成
  ├── タグの作成者、日時、メッセージ、オプションのGPG署名を格納
  ├── 「署名付きのマイルストーン」
  └── git tag -a v1.0 -m "Release v1.0" で作成
```

annotated tagオブジェクトの内部構造はこうなる:

```
annotated tagオブジェクトの構造:

  object {参照先オブジェクトのSHA-1}
  type {参照先オブジェクトのタイプ（通常はcommit）}
  tag {タグ名}
  tagger {名前} <{メール}> {UNIXタイムスタンプ} {タイムゾーン}

  {タグメッセージ}
  {オプション: GPG署名}
```

lightweight tagは、ブランチと内部構造がほぼ同じだ。どちらもSHA-1を書いた小さなファイルに過ぎない。違いは格納場所（`refs/heads/`か`refs/tags/`か）と、意味論だけだ。

annotated tagはgitオブジェクトとして永続的に保存される。タグの作成者、作成日時、メッセージが記録される。GPG署名を付加すれば、そのタグが特定の人物によって作成されたことを暗号学的に証明できる。ソフトウェアリリースのマーキングには、annotated tagが推奨される。`git describe`コマンドがデフォルトでannotated tagのみを対象とすることも、その裏付けだ。

### 4つのオブジェクトの関係図

```
gitオブジェクトモデルの全体像:

  tag (annotated)
    │
    ▼
  commit ─────────────────→ tree (root)
    │ parent                   │
    ▼                         ├── blob (README.md)
  commit (parent)             ├── blob (main.py)
    │ parent                  ├── tree (src/)
    ▼                         │     ├── blob (app.py)
  commit (root)               │     └── blob (utils.py)
                              └── tree (tests/)
                                    └── blob (test_app.py)

  [ルール]
  - 全オブジェクトはSHA-1ハッシュで識別される
  - 同一内容 = 同一ハッシュ = 同一オブジェクト
  - オブジェクト間の参照はSHA-1ハッシュによるポインタ
  - オブジェクトは不変（immutable）——一度作られたら変更されない
```

---

## 4. 圧縮と最適化——looseオブジェクトからpackファイルへ

### looseオブジェクト——個別ファイルとしての格納

ここまで述べた格納方式——各オブジェクトをzlib圧縮して個別のファイルとして保存する——は、「looseオブジェクト」と呼ばれる。`git add`や`git commit`を実行すると、新しいオブジェクトはまずlooseオブジェクトとして作成される。

looseオブジェクトの格納は単純で高速だ。ファイルを1つ書くだけの操作で完了する。読み取りもファイルを1つ読むだけだ。データベースのトランザクションもロックも不要。Torvaldsが「ファイルシステムの人間」として設計した痕跡が、ここにある。

だが、looseオブジェクトには非効率な面がある。

第一に、各オブジェクトが独立にzlib圧縮されるため、類似した内容のオブジェクト間で重複するバイト列が個別に格納される。ファイルの1行だけ変更しても、変更後の全内容が新しいblobとして保存される。zlib圧縮は個々のオブジェクト内の冗長性は排除するが、オブジェクト間の類似性は利用できない。

第二に、大量のlooseオブジェクトは多数の小さなファイルを生成する。ファイルシステムによっては、大量の小ファイルがiノードを消費し、ディレクトリ操作の性能を劣化させる。

### packファイル——デルタ圧縮による最適化

この非効率を解消するのがpackファイルだ。

gitは一定の条件——looseオブジェクトが約6,700個を超えたとき、または`git gc`が手動で実行されたとき——で、複数のlooseオブジェクトを1つのpackファイルに統合する。packファイルは`.git/objects/pack/`ディレクトリに格納される。

```
packファイルの構造:

  .git/objects/pack/
  ├── pack-{SHA-1}.pack    ← オブジェクトデータ本体
  └── pack-{SHA-1}.idx     ← インデックス（高速検索用）

  packファイルのヘッダ:
  ┌──────────────┬──────────────┬──────────────┐
  │ 'PACK'       │ バージョン   │ オブジェクト数│
  │ (4バイト)    │ (4バイト)    │ (4バイト)    │
  └──────────────┴──────────────┴──────────────┘
  現在のバージョンは2
```

packファイルの核心は「デルタ圧縮」だ。類似したオブジェクトを見つけ、一方を「ベースオブジェクト」、他方を「ベースからの差分（デルタ）」として格納する。これは概念的にはdiffに似ているが、gitのデルタ圧縮はテキストベースではなくバイナリレベルで行われる。

```
デルタ圧縮の概念:

  looseオブジェクト（圧縮前）:
  ┌────────────────────────────────┐
  │ blob v1: "Hello World\n"      │  ← 完全なオブジェクト
  └────────────────────────────────┘
  ┌────────────────────────────────┐
  │ blob v2: "Hello Git World\n"  │  ← 完全なオブジェクト
  └────────────────────────────────┘

  packファイル（デルタ圧縮後）:
  ┌────────────────────────────────┐
  │ blob v2: "Hello Git World\n"  │  ← ベースオブジェクト（完全）
  └────────────────────────────────┘
  ┌────────────────────────────────┐
  │ blob v1: delta(v2 → v1)       │  ← デルタ（v2からの差分）
  └────────────────────────────────┘
```

注目すべきは、gitが「新しい方をベースにして古い方をデルタとして格納する」ことが多い点だ。直感に反するが、合理的な理由がある。最もよくアクセスされるのは最新バージョンだ。最新バージョンをベースオブジェクトとして完全に格納しておけば、最新バージョンへのアクセスはデルタの展開なしに完了する。古いバージョンへのアクセスは頻度が低いため、デルタ展開のコストは許容できる。

デルタデータの形式は2種類ある。

```
デルタの参照方式:

  OBJ_OFS_DELTA:
  ├── packファイル内の相対オフセットでベースオブジェクトを指定
  ├── よりコンパクト（3-5%の縮小）
  └── 同一packファイル内のオブジェクトのみ参照可能

  OBJ_REF_DELTA:
  ├── 20バイトのSHA-1でベースオブジェクトを指定
  ├── packファイルをまたいだ参照が可能
  └── ネットワーク転送時のthin packで使用
```

デルタデータ自体は、2種類の命令の列で構成される。

```
デルタ命令:

  copy命令（MSB = 1）:
  → ベースオブジェクトの指定範囲をコピー
  → 「オフセットXからYバイトをコピーせよ」

  insert命令（MSB = 0）:
  → 新しいバイト列を挿入
  → 「次のNバイトをそのまま出力せよ」
```

ファイルの一部だけが変更された場合、デルタは「変更されていない部分はベースからコピー、変更された部分だけ新規挿入」という効率的な表現になる。これにより、大きなファイルの小さな変更は、極めてコンパクトに格納される。

デルタチェーンの深さは`pack.depth`設定値（デフォルト50）で制限される。あるデルタのベースが別のデルタであり、そのベースがさらに別のデルタ……という連鎖が深すぎると、オブジェクトの展開に時間がかかる。深さの制限は、格納効率と読み取り性能のトレードオフだ。

### 二層構造の美しさ

ここまでの説明で見えてくるのは、gitの「概念モデル」と「ストレージモデル」が分離された二層構造だ。

```
gitの二層構造:

  概念モデル（ユーザーから見える世界）:
  ┌─────────────────────────────────────────┐
  │ スナップショット型                       │
  │ 各commitはプロジェクト全体の状態を記録   │
  │ 任意のcommitの状態を即座に復元可能       │
  └─────────────────────────────────────────┘

  ストレージモデル（.git/objects の中の世界）:
  ┌─────────────────────────────────────────┐
  │ looseオブジェクト: 個別zlib圧縮          │
  │ packファイル: デルタ圧縮 + zlib圧縮      │
  │ オブジェクト間の類似性を利用した最適化    │
  └─────────────────────────────────────────┘
```

概念的にはスナップショット型でありながら、ストレージ層ではデルタ圧縮を使う。この分離が、概念の単純さと実装の効率性を両立させている。ユーザーは「各コミットがプロジェクト全体のスナップショットである」という単純なモデルで考えればよい。gitが裏側でデルタ圧縮を行っていることを意識する必要はない。

CVSやSubversionが「差分型」を概念モデルとストレージモデルの両方に採用したのとは対照的だ。差分型では、特定のバージョンを復元するために差分の連鎖を追う必要があり、概念的にも実装的にも複雑になる。gitは「概念は単純、実装は賢く」というアプローチを取った。

### SHA-1からSHA-256へ——進行中の移行

gitの内部を語る上で、SHA-1からSHA-256への移行にも触れなければならない。

SHA-1は2017年、Googleとオランダ・CWIの研究チームによる「SHAttered」攻撃で、理論上だけでなく実用上も衝突生成が可能であることが実証された。同じSHA-1ハッシュを持つ2つの異なるPDFファイルが作成されたのだ。

gitのセキュリティモデルにおいて、SHA-1の主たる役割はデータの完全性検証——偶発的な破損の検出——だ。Torvalds自身が「暗号学的セキュリティは偶然の副産物」と述べている。だが、悪意ある攻撃者が意図的に衝突を起こすリスクは無視できない。

SHA-256への移行は段階的に進んでいる。

```
SHA-256移行のタイムライン:

  2020年10月  Git 2.29   SHA-256リポジトリの実験的サポート
  2023年 8月  Git 2.42   SHA-256は「実験的な好奇心」から脱却
  2025年 8月  Git 2.51   内部plumbingのSHA-256対応を拡充
  2025年末    Git 2.52   SHA-1とSHA-256の相互運用性作業開始
  2026年末    Git 3.0    SHA-256をデフォルトにする目標

  課題:
  - brian m. carlsonの見積もり: 移行に200-400パッチ必要、約100が完了
  - GitHub/GitLab/BitbucketのSHA-256完全対応が未達
  - 既存の数十億のSHA-1リポジトリとの互換性維持
```

2026年2月現在、SHA-256リポジトリは`git init --object-format=sha256`で作成できるが、デフォルトは依然としてSHA-1だ。Git 3.0で目標とされるSHA-256デフォルト化が実現すれば、gitのオブジェクトモデルにおけるハッシュは20バイト（SHA-1）から32バイト（SHA-256）に拡大する。packファイルのフォーマット、プロトコルの互換性、エコシステム全体への影響を考えると、この移行は容易ではない。

だが、移行の方向性は不可逆だ。SHA-1は遠くない将来、gitの内部から退場する。

---

## 5. ハンズオン：gitオブジェクトを手で解剖する

前回のハンズオン（第14回）では、低レベルコマンドでオブジェクトを作成した。今回は、作成されたオブジェクトの内部をバイナリレベルで検証する。SHA-1ハッシュを手動で再計算し、zlib圧縮を自分で解凍し、packファイルの中身を覗く。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y git python3 xxd
```

### 演習1：SHA-1ハッシュを手動で検証する

```bash
WORKDIR="${HOME}/vcs-handson-15"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=== 演習1: SHA-1ハッシュの手動検証 ==="
echo ""

# テスト用のファイル内容を用意
echo -n "Hello, Git Object Model!" > test_content.txt

# gitが計算するハッシュを確認
GIT_HASH=$(git hash-object test_content.txt)
echo "git hash-object の結果: ${GIT_HASH}"

# 手動でSHA-1を計算する
# gitのヘッダフォーマット: "{type} {size}\0{content}"
CONTENT=$(cat test_content.txt)
SIZE=$(wc -c < test_content.txt | tr -d ' ')
echo "ファイルサイズ: ${SIZE} バイト"
echo "ヘッダ: \"blob ${SIZE}\\0\""

# Python3でヘッダ + 内容のSHA-1を計算
MANUAL_HASH=$(python3 -c "
import hashlib
content = open('test_content.txt', 'rb').read()
header = f'blob {len(content)}\0'.encode()
sha1 = hashlib.sha1(header + content).hexdigest()
print(sha1)
")
echo "手動計算の結果:         ${MANUAL_HASH}"
echo ""

if [ "${GIT_HASH}" = "${MANUAL_HASH}" ]; then
  echo "-> 一致。gitのSHA-1計算は \"blob {size}\\0{content}\" のSHA-1"
else
  echo "-> 不一致（予期しない結果）"
fi
echo ""
echo "-> ヘッダがなければハッシュは変わる"
RAW_SHA1=$(python3 -c "
import hashlib
content = open('test_content.txt', 'rb').read()
print(hashlib.sha1(content).hexdigest())
")
echo "   内容だけのSHA-1:   ${RAW_SHA1}"
echo "   git hash-objectの値: ${GIT_HASH}"
echo "-> 両者は異なる。ヘッダの存在がgitのハッシュを特徴づける"
```

### 演習2：looseオブジェクトのzlib圧縮を解凍する

```bash
echo ""
echo "=== 演習2: looseオブジェクトのzlib圧縮を解凍する ==="
echo ""

# リポジトリを初期化してオブジェクトを作成
mkdir -p "${WORKDIR}/decompress-test"
cd "${WORKDIR}/decompress-test"
git init --quiet

# ファイルを追加してblobオブジェクトを作成
echo "This is a test file for zlib decompression." > sample.txt
BLOB_HASH=$(git hash-object -w sample.txt)
echo "blobオブジェクトのハッシュ: ${BLOB_HASH}"

# looseオブジェクトのファイルパスを構築
DIR="${BLOB_HASH:0:2}"
FILE="${BLOB_HASH:2}"
OBJ_PATH=".git/objects/${DIR}/${FILE}"
echo "格納先: ${OBJ_PATH}"
echo ""

# ファイルのバイナリ内容を表示（最初の16バイト）
echo "--- 圧縮状態のバイナリ（先頭16バイト）---"
xxd -l 16 "${OBJ_PATH}"
echo ""
echo "-> 先頭バイト 78 01 または 78 9C はzlibのマジックナンバー"
echo "   78 = CMF（Compression Method and Flags）"
echo "   01 = FLG（Flags）- 低圧縮レベル"
echo "   9C = FLG（Flags）- デフォルト圧縮レベル"
echo ""

# Pythonでzlib解凍して内容を確認
echo "--- zlib解凍後の内容 ---"
python3 -c "
import zlib
with open('${OBJ_PATH}', 'rb') as f:
    compressed = f.read()
decompressed = zlib.decompress(compressed)
# NULLバイトで分割してヘッダと内容を分離
null_pos = decompressed.index(b'\x00')
header = decompressed[:null_pos].decode()
content = decompressed[null_pos+1:]
print(f'ヘッダ: \"{header}\"')
print(f'内容:   \"{content.decode()}\"')
print(f'圧縮前: {len(decompressed)} バイト')
print(f'圧縮後: {len(compressed)} バイト')
"
echo ""
echo "-> gitオブジェクト = zlib_deflate(ヘッダ + NULLバイト + 内容)"
```

### 演習3：annotated tagオブジェクトの解剖

```bash
echo ""
echo "=== 演習3: annotated tagオブジェクトの解剖 ==="
echo ""

cd "${WORKDIR}/decompress-test"

# コミットを作成
git add sample.txt
git commit --quiet -m "Initial commit for tag demo"

# lightweight tagを作成
git tag v0.1-light

# annotated tagを作成
git tag -a v0.1 -m "First annotated tag for demonstration"

echo "--- lightweight tag の内部 ---"
LIGHT_REF=$(cat .git/refs/tags/v0.1-light)
echo "refs/tags/v0.1-light の内容: ${LIGHT_REF}"
echo "オブジェクトタイプ: $(git cat-file -t "${LIGHT_REF}")"
echo "-> lightweight tag = commitへのポインタ（gitオブジェクトなし）"
echo ""

echo "--- annotated tag の内部 ---"
ANNOT_REF=$(cat .git/refs/tags/v0.1)
echo "refs/tags/v0.1 の内容: ${ANNOT_REF}"
echo "オブジェクトタイプ: $(git cat-file -t "${ANNOT_REF}")"
echo ""
echo "--- tagオブジェクトの中身 ---"
git cat-file -p "${ANNOT_REF}"
echo ""
echo "-> annotated tag = 独立したtagオブジェクト"
echo "   object: 参照先のcommit"
echo "   type: 参照先のオブジェクトタイプ"
echo "   tag: タグ名"
echo "   tagger: 作成者・日時"
echo "   メッセージ: タグの説明"
```

### 演習4：packファイルの確認

```bash
echo ""
echo "=== 演習4: packファイルの確認 ==="
echo ""

cd "${WORKDIR}/decompress-test"

# 複数のコミットを作成してオブジェクトを増やす
for i in $(seq 1 10); do
  echo "Version ${i} of the file with some content." > sample.txt
  git add sample.txt
  git commit --quiet -m "Update ${i}"
done

echo "--- gc実行前のlooseオブジェクト数 ---"
LOOSE_COUNT=$(find .git/objects -type f ! -path "*/pack/*" ! -path "*/info/*" | wc -l)
echo "looseオブジェクト: ${LOOSE_COUNT} 個"
echo ""

# git gcでpackファイルを生成
echo "--- git gc を実行 ---"
git gc --quiet
echo ""

echo "--- gc実行後 ---"
LOOSE_AFTER=$(find .git/objects -type f ! -path "*/pack/*" ! -path "*/info/*" | wc -l)
PACK_COUNT=$(find .git/objects/pack -name "*.pack" | wc -l)
echo "looseオブジェクト: ${LOOSE_AFTER} 個"
echo "packファイル: ${PACK_COUNT} 個"
echo ""

# packファイルの中身を確認
PACK_FILE=$(find .git/objects/pack -name "*.pack" | head -1)
if [ -n "${PACK_FILE}" ]; then
  IDX_FILE="${PACK_FILE%.pack}.idx"
  echo "--- packファイルの統計 ---"
  git verify-pack -v "${IDX_FILE}" | tail -5
  echo ""
  echo "--- デルタチェーンの確認 ---"
  echo "（depth > 0 のエントリがデルタ圧縮されたオブジェクト）"
  git verify-pack -v "${IDX_FILE}" | grep -c "delta" || echo "0"
  echo " 個のオブジェクトがデルタ圧縮されている"
fi
echo ""
echo "-> looseオブジェクトがpackファイルに統合された"
echo "-> 類似オブジェクト間のデルタ圧縮でストレージ効率が向上"
echo "-> git verify-pack で内部を確認できる"
```

### 演習で見えたこと

四つの演習を通じて、gitオブジェクトの内部構造をバイナリレベルで確認した。

演習1では、SHA-1ハッシュの計算方法を手動で検証した。gitのハッシュは「ヘッダ + 内容」のSHA-1であり、内容だけのSHA-1とは異なる。`sha1sum`コマンドの出力と`git hash-object`の出力が一致しないのは、このヘッダの存在によるものだ。gitを使い始めて「なぜハッシュが合わないのか」と悩んだ経験がある人は多いだろう。答えは、この9バイト程度のヘッダにある。

演習2では、looseオブジェクトをzlib解凍して中身を確認した。`.git/objects`に格納されたバイナリファイルは、zlibで圧縮されたヘッダ + 内容だ。先頭バイトの`0x78`がzlibのマジックナンバーであることを知っていれば、gitオブジェクトを識別できる。

演習3では、annotated tagとlightweight tagの内部構造の違いを確認した。lightweight tagは単なるポインタだが、annotated tagは独立したgitオブジェクトとして作成者情報とメッセージを保持する。リリースのマーキングにannotated tagが推奨される理由が、この内部構造の違いから理解できる。

演習4では、git gcによるlooseオブジェクトからpackファイルへの統合を体験した。`git verify-pack`でpackファイルの内部を覗くと、デルタ圧縮されたオブジェクトの存在を確認できる。gitが裏側で行っている最適化の実態が、ここにある。

---

## 6. まとめと次回予告

### この回の要点

第一に、gitの内部は4種類のオブジェクト——blob、tree、commit、tag——で構成される。全てのオブジェクトは「{type} {size}\0{content}」というヘッダ形式に従い、SHA-1ハッシュで識別され、zlib圧縮されて`.git/objects`に格納される。

第二に、内容アドレス可能ストレージ（CAS）の思想は、Plan 9のVenti（2002年、Quinlan & Dorward）やMonotone（2003年、Graydon Hoare）を経て、gitに受け継がれた。gitの独自性は、CASの実装にデータベースではなくファイルシステムを使った点にある。この「愚直さ」がgitの性能の源泉だ。

第三に、blobはファイル名を持たない。この設計により、同一内容のファイルは自動的に重複排除され、リネーム検出はヒューリスティックに行われる。treeオブジェクトがファイル名とblobの対応付けを行い、commitオブジェクトがtreeのスナップショットに時間と因果（parent）を結びつける。annotated tagは独立したオブジェクトとして作成者情報を保持するが、lightweight tagは単なるポインタだ。

第四に、gitは「概念モデルはスナップショット型、ストレージモデルはデルタ圧縮型」という二層構造を持つ。looseオブジェクトは個別にzlib圧縮され、packファイルではオブジェクト間のデルタ圧縮が行われる。デルタデータはcopy命令とinsert命令のバイナリ列で構成される。

第五に、SHA-1からSHA-256への移行が進行中であり、Git 3.0（2026年末目標）でSHA-256がデフォルトになる予定だ。SHA-1の衝突攻撃（SHAttered、2017年）を受けた不可避の移行だが、エコシステム全体の対応にはまだ時間を要する。

### 冒頭の問いへの暫定回答

gitは内部でデータをどう保持しているのか。それを知ると何が変わるのか。

gitは、4種類のオブジェクトとSHA-1ハッシュによるCASという、驚くほど単純なモデルでデータを保持している。その単純さは、Torvaldsが「ファイルシステムの人間」として、データベースの抽象化を拒否し、ファイルの読み書きだけで実装した結果だ。

それを知ると何が変わるか。gitの操作が「予測可能」になる。`git add`はblobを作成しインデックスを更新する操作だ。`git commit`はtreeとcommitオブジェクトを作成する操作だ。`git branch`は41バイトのファイルを書く操作だ。`git merge`は新しいcommitオブジェクト（parentを2つ持つ）を作成する操作だ。

全てが、オブジェクトとポインタの操作として理解できる。「何か壊れた」ときにパニックにならない。`.git/objects`の中身を覗き、`git cat-file`でオブジェクトを読み、`git fsck`で整合性をチェックすれば、何が起きているかが見える。「見える」ことは「直せる」ことにつながる。

gitの内部を知ることは、gitの挙動を「予測できる」エンジニアになるための第一歩だ。

### 次回予告

4つのオブジェクトとSHA-1ハッシュ——gitの「基盤」は理解した。だが、私たちが日常的に使う「ブランチ」は、このオブジェクトモデルの中でどう表現されているのか。

**第16回「ブランチの革命——Gitが変えた開発フロー」**

CVS時代、ブランチは「恐怖」の対象だった。作成にも時間がかかり、マージはさらに悪夢だった。gitはブランチを「41バイトのファイル」——特定のcommitを指すポインタ——として実装することで、この恐怖を過去のものにした。ブランチの作成は一瞬。削除も一瞬。この「ブランチが安い」という特性が、Git-flow、GitHub Flow、トランクベース開発といったワークフローの革新を可能にした。

次回は、gitのブランチモデルの技術的な仕組みと、それが開発文化をどう変えたかを掘り下げる。CVS/SVNのブランチ実装との根本的な違い、3-way mergeアルゴリズム、rebaseの仕組みと危険性——ブランチの全てを解剖する。

あなたのチームのブランチ戦略は、gitのオブジェクトモデルの特性を活かしているだろうか。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Quinlan, S. and Dorward, S., "Venti: A New Approach to Archival Data Storage." USENIX FAST '02 (2002). <https://www.usenix.org/conference/fast-02/venti-new-approach-archival-data-storage>
- Chacon, S. and Straub, B., "Git Internals - Git Objects." Pro Git, 2nd Edition. <https://git-scm.com/book/en/v2/Git-Internals-Git-Objects>
- Chacon, S. and Straub, B., "Git Internals - Packfiles." Pro Git, 2nd Edition. <https://git-scm.com/book/en/v2/Git-Internals-Packfiles>
- Git SCM, "pack-format Documentation." <https://git-scm.com/docs/pack-format>
- Git SCM, "hash-function-transition Documentation." <https://git-scm.com/docs/hash-function-transition>
- Git SCM, "git-gc Documentation." <https://git-scm.com/docs/git-gc>
- Git SCM, "git-tag Documentation." <https://git-scm.com/docs/git-tag>
- Hajnoczi, S., "Git: Internals of how objects are stored." (2016). <http://blog.vmsplice.net/2016/05/git-internals-of-how-objects-are-stored.html>
- Wikipedia, "Content-addressable storage." <https://en.wikipedia.org/wiki/Content-addressable_storage>
- Help Net Security, "Git 2.51: Preparing for the future with SHA-256." (2025-08-19). <https://www.helpnetsecurity.com/2025/08/19/git-2-51-sha-256/>
- Phoronix, "Git 2.52-rc0 Starts Working On SHA1-SHA256 Interop." <https://www.phoronix.com/news/Git-2.52-rc0-Released>
- LWN.net, "Git considers SHA-256, Rust, LLMs, and more." <https://lwn.net/Articles/1042172/>
- Hamano, J.C., "GIT—A Stupid Content Tracker." Ottawa Linux Symposium (2006). <https://landley.net/kdocs/ols/2006/ols2006v1-pages-385-394.pdf>
