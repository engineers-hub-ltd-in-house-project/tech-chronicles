# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第14回：Linus Torvaldsの決断——Gitの誕生（2005年4月）

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Linus Torvaldsが既存の分散型VCS（Monotone、Darcs、GNU arch）を選ばず、自作を決断した技術的理由
- 2005年4月3日から4月29日までのgit開発タイムラインの全貌
- gitの設計要件——速度、分散、データ完全性、非線形開発——の具体的な内容と根拠
- gitが「バージョン管理ツール」ではなく「コンテンツアドレッサブルファイルシステム」として設計された意味
- 最初のコミット（e83c5163）に含まれた10ファイル・約1,000行のCコードと7つの初期コマンド
- Junio Hamanoへのメンテナ移譲（2005年7月26日）とv1.0リリース（2005年12月21日）の経緯
- Linux kernel 2.6.12（2005年6月17日）——gitで管理された最初の公式カーネルリリース

---

## 1. 「なぜ自分で作るのか」という問い

2005年4月6日、Linus TorvaldsがLKMLに投稿した「Kernel SCM saga...」というメールを、私はリアルタイムで読んだ。

前回（第13回）で詳述したBitKeeper事件の直後だ。BitMover社が無償ライセンスを打ち切り、Linuxカーネル開発チームはバージョン管理ツールを失った。その状況でTorvaldsが選んだのは、既存のツールへの移行ではなく、新しいツールの自作だった。

私は当時、「なぜ既存のものを使わないのか」と疑問に思った。分散型VCSはすでに存在していた。前回までに触れたMonotone、Darcs、GNU arch——いずれも活発に開発されており、OSSプロジェクトでの実績もあった。カーネル規模のプロジェクトに使えるかどうかは別として、ゼロから作るよりは既存のものを改良するほうが合理的ではないか。

だが、Torvaldsのメーリングリスト投稿を追いかけるうちに、私は理解した。Torvaldsが求めていたものは、当時存在するどのツールにもなかった。正確に言えば、彼が求めていた「組み合わせ」が、どのツールにも存在しなかったのだ。

それは「速度」と「単純さ」の組み合わせだった。

Torvaldsはプログラマとして特異な立場にいる。Linuxカーネルという、人類が作り上げた最大級のソフトウェアプロジェクトのメンテナだ。数千人の開発者から毎日数百のパッチが送られてくる。マージ操作を1日に何十回も行う。そのような人間にとって、バージョン管理ツールの性能は日常の生産性に直結する。

**LinusはなぜGitを「自分で作る」ことを選んだのか。** この問いは、単に技術選定の話ではない。「既存のものを使う」か「自分で作る」か——エンジニアが日常的に直面するこの判断を、歴史上最も影響力のあるプログラマの一人がどう下したかという話だ。

あなたは、いつ「自分で作る」ことを選ぶだろうか。その判断基準は、何だろうか。

---

## 2. 消去法の果てに——既存DVCSが選ばれなかった理由

### Monotone——「正しすぎた」設計

2005年4月7日、TorvaldsはLKMLの「Re: Kernel SCM saga..」スレッドで、Monotoneに言及した。

> "If you must, start reading up on 'monotone'."

この一文は、Torvaldsが既存のDVCSの中でMonotoneを最も真剣に検討していたことを示している。MonotoneはGraydon Hoareが2003年に開始したプロジェクトで、SHA-1ハッシュによるオブジェクト識別、内容アドレス可能ストレージという、後にgitが採用する設計アイデアの多くを先行して実装していた。

だが、Torvaldsの評価は痛烈だった。

Monotoneは「real database」（SQLite）を使い、「nice C++ abstractions」と「nice object-oriented libraries」を備えていた。ソフトウェア工学の教科書に載るような「正しい」設計だ。だがTorvaldsは、その「正しさ」こそが問題だと指摘した。抽象化のレイヤーが重なることで性能が犠牲になり、結果として「horrible and unmaintainable mess」が生じると。

具体的な数字で言えば、Monotoneはカーネル規模のリポジトリ（当時で数万ファイル、数十万のコミット）を扱うには遅すぎた。Torvaldsが求めていたのは、パッチの適用が秒単位で完了するツールだ。Monotoneの抽象化レイヤーは、その要件を満たせなかった。

ここで重要なのは、Torvaldsがmonocloneの設計思想を全否定したわけではないことだ。SHA-1によるオブジェクト識別、暗号学的ハッシュによるデータ完全性保証——これらのアイデアは、gitに直接受け継がれた。TorvaldsはMonotoneの「何を」管理するかの思想には共感し、「どう」管理するかの実装を拒否したのだ。

### Darcs——パッチ理論の美しさと実用性の壁

David Roundyが2002年に開始したDarcsは、「パッチ理論」という数学的に美しい基盤を持っていた。パッチ（変更）を第一級のオブジェクトとして扱い、パッチの順序交換や合成を代数的に定義する。

パッチ理論の美しさは認めるが、Torvaldsにとって問題だったのは計算量だ。パッチ間の依存関係を追跡するアルゴリズムは、最悪の場合に指数的な計算時間を要する可能性があった（後に「darcs merge conflict exponential blowup」として知られる問題）。カーネル規模の非線形開発——数百のブランチが並行して存在し、頻繁にマージされる——において、この計算量は致命的だった。

また、DarcsはHaskellで書かれていた。当時、Haskellの実行時性能はC言語に比べて大幅に劣っていた。Torvaldsがカーネル開発で求めるレベルの性能を、Darcsが達成することは現実的でなかった。

### GNU arch——先駆者の限界

Tom Lordが2001年に開始したGNU arch（tla）は、分散型VCSの先駆者の一つだった。だが、GNU archは使い勝手に深刻な問題を抱えていた。コマンド体系が独特で学習曲線が急であり、命名規則が冗長だった。

Torvaldsは、GNU archの設計アプローチに対して明確な不満を示していた。Linuxカーネル開発者のような、日々大量のパッチを処理する必要がある人々にとって、ツールの使い勝手は性能と同じくらい重要だ。

### 消去法の結論

```
既存DVCSの評価（2005年4月、Linusの視点）:

  ツール          長所                    致命的欠点
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Monotone        SHA-1ベースの設計思想   性能不足（SQLite + C++抽象化）
  Darcs           数学的に美しいパッチ理論 計算量の問題、Haskellの実行性能
  GNU arch        分散型の先駆者           使い勝手の悪さ、命名規則の冗長さ
  Subversion      CVSの正統進化           集中型（根本的に不適合）
  CVS             実績豊富               あらゆる面で不十分
```

どのツールも、Torvaldsが求める「速度」「分散」「単純さ」の三つを同時に満たしていなかった。そしてTorvaldsは、BitKeeperを3年間使った経験から、「分散型VCSとはこうあるべきだ」という明確なビジョンを持っていた。

「自分で作る」という判断は、傲慢さからではなく、要件と既存ツールの間に埋めがたいギャップがあったことの帰結だった。

---

## 3. 「ファイルシステムの人間」が作ったバージョン管理

### Torvaldsの設計要件

gitの設計は、Torvaldsが3年間のBitKeeper使用で蓄積した知見と、Linuxカーネルという巨大プロジェクトの運用経験から導き出された。2007年5月3日のGoogle Tech Talkで、Torvaldsは自身の設計思想を詳細に語った。以下は、その講演と2005年のLKML投稿、2005年のInfoWorldインタビューから抽出した設計要件である。

**要件1：速度——日常操作は1秒以内**

Torvaldsは2005年のInfoWorldインタビューでこう述べた。「Gitはある程度、日常的に行うすべての操作が1秒以内に完了すべきだという原則に基づいて設計された」。

この要件は、カーネル開発の現実から来ている。Torvaldsは1日に数百のパッチを処理する。マージ操作、差分表示、ログ参照——これらの操作が数秒かかるだけで、1日の累積遅延は無視できないものになる。BitKeeperはこの性能要件を満たしていた。後継ツールも、同等以上の性能を提供しなければならなかった。

**要件2：分散——BitKeeperライクなワークフロー**

各開発者がリポジトリの完全なコピーを保持し、オフラインでコミット、ブランチ作成、履歴参照が可能であること。サーバが落ちても開発が止まらないこと。Linuxカーネルの「信頼の階層」モデル——サブシステムメンテナが独立に開発を進め、準備ができた段階でLinusのツリーにマージする——を自然に表現できること。

**要件3：データ完全性——暗号学的保証**

すべてのオブジェクトの完全性がハッシュによって保証されること。Torvaldsの言葉を借りれば、「SCMに入れたものが、まったく同じ状態で出てくることを保証できないなら、使う価値がない」。これは、カーネルのような安全保障上重要なソフトウェアにとって、譲れない要件だった。

**要件4：非線形開発のサポート**

数百のブランチが並行して存在し、頻繁にマージされる開発モデルを効率的に処理できること。ブランチの作成とマージが、コストのかからない日常的な操作であること。

### 「バージョン管理ツール」ではなく「ファイルシステム」

ここからが、gitの設計で最も重要な——そして最も誤解されている——部分だ。

Torvaldsは2007年のGoogle Tech Talkで、こう述べた。「私はファイルシステムの人間だ。ファイルシステムは私が理解しているものであり、gitはファイルシステムの人間の視点から設計した」。

gitは「バージョン管理ツール」として設計されたのではない。**「コンテンツアドレッサブルファイルシステム」**として設計された。バージョン管理機能は、そのファイルシステムの上に構築される「応用層」に過ぎない。

gitの最初のコミットに含まれるREADME（2005年4月7日）は、こう始まる。

> GIT - the stupid content tracker

「stupid（愚直な）」という形容は自嘲ではない。設計哲学の宣言だ。gitは「賢い」ことをしない。gitはコンテンツを追跡する。それだけだ。ファイルの内容をハッシュで識別し、ツリー構造で整理し、コミットで時系列に並べる。バージョン管理に必要な「知性」——ブランチ戦略、マージポリシー、ワークフロー設計——は、人間の側に委ねられる。

同じREADMEには、gitの名前の由来について自虐的な注釈がある。

> "git" can mean anything, depending on your mood.
>
> - "global information tracker": you're in a good mood, and it actually works for you. Angels sing, and a light suddenly fills the room.
> - "goddamn idiotic truckload of sh*t": when it breaks

そしてコミットメッセージは「Initial revision of 'git', the information manager from hell」だった。

このユーモアの背後に、Torvaldsの設計思想がある。gitは「情報管理ツール」であって「バージョン管理ツール」ではない。この区別は、gitの内部構造を理解する上で決定的に重要だ。

### 内容アドレス可能ストレージ——全てはSHA-1から始まる

gitの核心は、内容アドレス可能（content-addressable）ストレージにある。

従来のファイルシステムは「場所」でファイルを管理する。`/home/user/project/src/main.c`——パスがファイルの識別子だ。ファイルの内容が変わっても、パスは変わらない。

gitは「内容」でオブジェクトを管理する。ファイルの内容をSHA-1でハッシュし、そのハッシュ値がオブジェクトの識別子になる。同じ内容のファイルは、どこに置かれていても、いつ作成されても、同じハッシュ値を持つ。

```
従来のファイルシステム:

  パス（場所）  →  内容
  /src/main.c   →  #include <stdio.h>...

git（内容アドレス可能ストレージ）:

  SHA-1ハッシュ（内容の指紋）  →  内容
  af5626b4a114abcb82d63db7c8082c3c4756e51f  →  #include <stdio.h>...
```

この設計には、いくつかの重要な帰結がある。

第一に、同一内容のファイルは自動的に重複排除される。プロジェクト内に同じ内容のファイルが100個あっても、gitのオブジェクトデータベースには1つのblobしか格納されない。

第二に、データの完全性が暗号学的に保証される。オブジェクトの内容が1ビットでも変われば、ハッシュ値が変わる。したがって、オブジェクトの改竄や破損は、ハッシュ値の不一致によって即座に検出される。

第三に、この設計はMonotoneから着想を得ている。だが、Monotoneがオブジェクトの管理にSQLiteデータベースを使ったのに対し、gitは単純なファイルシステム操作——ハッシュ値の先頭2文字をディレクトリ名とし、残りをファイル名とする——でオブジェクトを管理した。この「愚直さ」が、圧倒的な性能の源泉となった。

Torvaldsは後にSHA-1の役割についてこう述べた。ハッシュの主な目的は偶発的なデータ破損の検出であり、暗号学的なセキュリティは「偶然の副産物」だと。これは正直な告白だ。gitのセキュリティモデルにおいて、データの完全性を真に保証するのはGPG署名であり、SHA-1ではない。

### 4つのオブジェクト——gitの世界を構成する最小単位

gitの内部は、わずか4種類のオブジェクトで構成される。

```
gitオブジェクトモデル:

  blob（Binary Large Object）
  ├── ファイルの内容そのもの
  ├── ファイル名を持たない（内容のみ）
  └── SHA-1ハッシュで識別

  tree
  ├── ディレクトリに相当
  ├── blobやtreeへの参照（ファイル名 + ハッシュ）のリスト
  └── ある時点のプロジェクト構造のスナップショット

  commit
  ├── 特定のtreeを指すポインタ
  ├── 親commit（0個以上）への参照
  ├── 著者（author）とコミッタ（committer）の情報
  └── コミットメッセージ

  tag
  ├── 特定のオブジェクト（通常はcommit）への参照
  ├── タグ名
  ├── タグ作成者の情報
  └── オプションのGPG署名
```

このモデルの優美さは、その単純さにある。ファイルの内容はblob、ディレクトリ構造はtree、時点の記録はcommit。たったこれだけで、バージョン管理に必要な全ての情報を表現できる。

CVSがファイル単位で差分を保存し、Subversionがリポジトリ全体のリビジョンを連番で管理したのに対し、gitはオブジェクトのDAG（有向非巡回グラフ）として履歴を表現する。各commitは親commitを指し、その連鎖がプロジェクトの歴史を形成する。ブランチはこのDAGの中の特定のcommitを指すポインタに過ぎない——41バイトのテキストファイルだ。

この設計が、後にgitの「ブランチが安い」という特性を生み出す。ブランチの作成は、41バイトのファイルを1つ書くだけの操作だ。CVSやSubversionのブランチが「コピー」操作であったのに対し、gitのブランチは「ポインタの追加」操作だ。桁違いに軽い。

### スナップショット型 vs 差分型

gitのもう一つの重要な設計判断は、「スナップショット型」の採用だ。

CVSやSubversionは「差分型」だ。各リビジョンは前のリビジョンからの「差分」として保存される。ファイルの現在の内容を得るには、初期バージョンから全ての差分を順に適用する必要がある（実際には最適化が施されているが、概念的にはそうだ）。

gitは「スナップショット型」だ。各コミットは、その時点でのプロジェクト全体の状態——全ファイルの内容——を記録する。変更されていないファイルは、前のコミットと同じblobを指すだけなので、実際のストレージ消費は差分型とほぼ同等だ。だが、概念的にはスナップショットだ。

```
差分型（CVS/SVN）:

  v1 ─────┐
           │ diff(v1→v2)
  v2 ─────┤
           │ diff(v2→v3)
  v3 ─────┘
  → v3の内容を得るには: v1 + diff(v1→v2) + diff(v2→v3) を計算

スナップショット型（git）:

  commit A ──→ tree A ──→ blob1, blob2, blob3
  commit B ──→ tree B ──→ blob1, blob2, blob4  （blob3が変更→blob4）
  commit C ──→ tree C ──→ blob1, blob5, blob4  （blob2が変更→blob5）
  → commit Cの内容を得るには: tree Cを読むだけ
```

スナップショット型の利点は、任意のコミットの状態を即座に復元できることだ。差分の連鎖を追う必要がない。これが、gitの操作——checkout、diff、log——が高速である理由の一つだ。

ただし、ストレージの効率化のために、gitは「packファイル」という仕組みを持つ。一定数のオブジェクトが蓄積されると、gitはそれらを差分圧縮してpackファイルにまとめる。つまり、gitは概念的にはスナップショット型だが、ストレージレベルでは差分圧縮を使う。この二層構造が、概念の単純さと実装の効率性を両立させている。

---

## 4. 10ファイル、1,000行——gitの最初のコミットを読む

### e83c5163——歴史を変えた1,000行

2005年4月7日、Linus Torvaldsはgitの最初のコミットを行った。コミットハッシュは`e83c5163316f89bfbde7d9ab23ca2e25604af290`。コミットメッセージは「Initial revision of 'git', the information manager from hell」。

このコミットに含まれるのは、わずか10個のファイル、約1,000行のCコードだ。

```
gitの最初のコミットに含まれるファイル:

  ファイル名           サイズ    役割
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Makefile             ~30行    ビルド設定
  README               ~30行    プロジェクト説明
  cache.h              ~160行   データ構造の定義
  init-db.c            ~50行    リポジトリ初期化
  update-cache.c       ~250行   インデックスの更新
  write-tree.c         ~100行   ツリーオブジェクトの書き出し
  commit-tree.c        ~120行   コミットオブジェクトの作成
  cat-file.c           ~30行    オブジェクト内容の表示
  read-tree.c          ~50行    ツリーオブジェクトの読み込み
  show-diff.c          ~70行    作業ディレクトリとインデックスの差分
  read-cache.c         ~250行   インデックス（キャッシュ）の読み書き
```

この10ファイルが提供する7つのコマンドは、gitの本質を凝縮している。

```
初期gitコマンドと現在のgitコマンドの対応:

  初期コマンド       機能                      現在の対応
  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  init-db          リポジトリ初期化          git init
  update-cache     ファイルをインデックスに追加 git add
  write-tree       インデックスからツリー作成  git write-tree（低レベル）
  commit-tree      コミットオブジェクト作成    git commit-tree（低レベル）
  cat-file         オブジェクト内容を表示      git cat-file
  read-tree        ツリーをインデックスに読込  git read-tree（低レベル）
  show-diff        差分を表示                git diff
```

注目すべきは、現在の`git commit`や`git log`に相当する「高レベル」コマンドが存在しないことだ。初期のgitは、低レベルの「配管（plumbing）」コマンドしか持っていなかった。ユーザーフレンドリーな「陶器（porcelain）」コマンドは、後から追加された。

これは意図的な設計だ。Torvaldsはgitを「ユーザー向けのバージョン管理ツール」として作ったのではない。「コンテンツを管理するファイルシステムの基盤」として作ったのだ。その基盤の上に、各自が好きなインターフェースを構築すればよい——それがTorvaldsの考えだった。

### 2005年4月の開発タイムライン

gitの最初の1ヶ月は、驚異的な速度で進んだ。

```
2005年4月のgit開発タイムライン:

  4月 3日  開発開始（2.6.12-rc2リリースと同日）
  4月 6日  LKML投稿「Kernel SCM saga...」
  4月 7日  最初のコミット e83c5163（self-hosting達成）
           10ファイル、約1,000行のCコード
           7つの低レベルコマンド
  4月16日  gitでの最初のLinuxカーネルコミット
  4月18日  最初のマルチブランチマージ
  4月29日  6.7パッチ/秒のベンチマーク達成
```

4月3日から4月7日までの4日間で、self-hosting（git自身のソースコードをgitで管理できる状態）を達成した。4月16日には、Linuxカーネルのソースツリーがgitの管理下に移された。4月29日には、カーネルツリーへのパッチ適用速度が毎秒6.7パッチに達した。

「10日間でgitの原型を完成させた」という伝説は、おおむね事実だ。ただし、Torvalds自身が述べたように、コードを書き始める前に「4ヶ月間の精神的な準備期間」があった。BitKeeperを使いながら、「もし自分でVCSを作るなら」という思考実験を続けていたのだ。

この「4ヶ月の思考 + 10日の実装」という構造は、ソフトウェア設計の教訓を含んでいる。優れたソフトウェアは、コードを書く前にすでに設計されている。Torvaldsが10日間で原型を作れたのは、10日間が天才的だったからではなく（もちろんそれもあるが）、設計が事前に固まっていたからだ。

### 2005年6月〜12月——プロジェクトの成熟

開発の速度は4月以降も衰えなかった。

2005年6月17日、gitで管理された最初の公式Linuxカーネルリリースである2.6.12がリリースされた。開発開始からわずか2ヶ月半だ。gitはすでに、人類最大級のソフトウェアプロジェクトを管理できる能力を証明した。

2005年7月26日、Torvaldsはgitのメンテナをジュニオ・ハマノ（Junio C. Hamano）に移譲した。Torvaldsはハマノを「obvious choice（明白な選択）」と評した。ハマノはgitの最初のコミットから約1週間後にプロジェクトに参加し、git 0.99リリース時点で数百のコミットを行っていた。

このメンテナ移譲は、gitがTorvaldsの個人プロジェクトからコミュニティプロジェクトへ移行した転換点だ。Torvaldsはgitの開発を「やめた」のではなく、「コントリビューターとして参加する」形に変えた。これは、OSSプロジェクトの健全な成長パターンの一つだ。

2005年12月21日、ハマノの下でgit v1.0がリリースされた。4月の開発開始からわずか8ヶ月半。v0.99からv1.0までに34回のリリースが行われた（0.99.1から0.99.9nまで）。この密度の高いリリースサイクルは、プロジェクトが急速に成熟していたことを示している。

---

## 5. ハンズオン：gitの最初のコミットに触れる——1,000行のコードが変えた世界

gitの設計思想を理解する最善の方法は、gitの最初期のバージョンに実際に触れることだ。このハンズオンでは、gitのリポジトリから最初のコミットを取り出し、初期コマンドの構造を確認する。さらに、gitの低レベルコマンドを使って、gitの内部構造を自分の手で操作する。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y git curl
```

### 演習1：gitの最初のコミットを読む

```bash
WORKDIR="${HOME}/vcs-handson-14"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=== 演習1: gitの最初のコミットを読む ==="

# git自身のリポジトリをクローン
git clone --bare https://github.com/git/git.git git-source.git 2>&1 | tail -3
echo ""

# 最初のコミットのハッシュを取得
FIRST_COMMIT=$(git --git-dir=git-source.git rev-list --max-parents=0 HEAD | tail -1)
echo "gitの最初のコミット:"
git --git-dir=git-source.git log --format="  ハッシュ: %H%n  著者: %an <%ae>%n  日付: %ai%n  メッセージ: %s" "${FIRST_COMMIT}"
echo ""

# 最初のコミットに含まれるファイル一覧
echo "--- 最初のコミットに含まれるファイル ---"
git --git-dir=git-source.git ls-tree --name-only "${FIRST_COMMIT}"
echo ""

# READMEの内容を表示
echo "--- 最初のREADMEの内容 ---"
git --git-dir=git-source.git show "${FIRST_COMMIT}:README" | head -30
echo ""
echo "-> 'GIT - the stupid content tracker' という冒頭に注目"
echo "-> gitの名前の由来を自嘲的に説明している"
echo "-> この「愚直さ」がgitの設計哲学"
```

### 演習2：低レベルコマンドでgitオブジェクトを手動作成する

```bash
echo ""
echo "=== 演習2: 低レベルコマンドでgitオブジェクトを手動作成する ==="

# 新しいリポジトリを初期化
mkdir -p "${WORKDIR}/manual-git"
cd "${WORKDIR}/manual-git"
git init --quiet

echo ""
echo "--- Step 1: blobオブジェクトの作成 ---"
echo "gitの初期コマンド 'update-cache' に相当する操作を、低レベルで行う"
echo ""

# ファイルの内容からblobオブジェクトを作成
echo "Hello, this is the content of my file." | git hash-object -w --stdin
BLOB_HASH=$(echo "Hello, this is the content of my file." | git hash-object -w --stdin)
echo ""
echo "作成されたblobオブジェクト: ${BLOB_HASH}"
echo ""

# blobの内容を確認（初期の cat-file に相当）
echo "--- blobの内容（git cat-file -p で表示）---"
git cat-file -p "${BLOB_HASH}"
echo ""

echo "--- blobの種類（git cat-file -t で確認）---"
git cat-file -t "${BLOB_HASH}"
echo ""
echo "-> 内容のSHA-1ハッシュがオブジェクトの識別子になる"
echo "-> 同じ内容なら、いつ・どこで作成しても同じハッシュ値"
echo ""

echo "--- Step 2: treeオブジェクトの作成 ---"
echo "gitの初期コマンド 'write-tree' に相当する操作を行う"
echo ""

# blobをインデックスに追加
git update-index --add --cacheinfo 100644 "${BLOB_HASH}" hello.txt

# インデックスからtreeオブジェクトを作成
TREE_HASH=$(git write-tree)
echo "作成されたtreeオブジェクト: ${TREE_HASH}"
echo ""

# treeの内容を確認
echo "--- treeの内容 ---"
git cat-file -p "${TREE_HASH}"
echo ""
echo "-> treeはディレクトリ構造を表現する"
echo "-> 各エントリは（パーミッション、種類、ハッシュ、ファイル名）の組"
echo ""

echo "--- Step 3: commitオブジェクトの作成 ---"
echo "gitの初期コマンド 'commit-tree' に相当する操作を行う"
echo ""

# commitオブジェクトを作成
COMMIT_HASH=$(echo "My first manual commit" | git commit-tree "${TREE_HASH}")
echo "作成されたcommitオブジェクト: ${COMMIT_HASH}"
echo ""

# commitの内容を確認
echo "--- commitの内容 ---"
git cat-file -p "${COMMIT_HASH}"
echo ""
echo "-> commitはtreeへのポインタ、著者情報、メッセージを持つ"
echo "-> これがgitの履歴の最小単位"
echo ""

echo "--- Step 4: ブランチポインタの更新 ---"
echo ""

# mainブランチをこのcommitに向ける
git update-ref refs/heads/main "${COMMIT_HASH}"

# 結果を確認
echo "--- git log で確認 ---"
git log --oneline
echo ""
echo "-> 低レベルコマンドだけで、完全なgitコミットを作成した"
echo "-> git add + git commit は、上記の操作を自動化したもの"
echo "-> gitの「陶器（porcelain）」コマンドの裏では、"
echo "   「配管（plumbing）」コマンドが動いている"
```

### 演習3：内容アドレッシングの体験——同じ内容は同じハッシュ

```bash
echo ""
echo "=== 演習3: 内容アドレッシングの体験 ==="

cd "${WORKDIR}/manual-git"

echo "--- 同じ内容のファイルが同じハッシュを持つことを確認 ---"
echo ""

# 同じ内容で異なるファイル名のblobを作成
HASH_A=$(echo "Identical content" | git hash-object -w --stdin)
HASH_B=$(echo "Identical content" | git hash-object -w --stdin)
HASH_C=$(echo "Different content" | git hash-object -w --stdin)

echo "ファイルA（'Identical content'）のハッシュ: ${HASH_A}"
echo "ファイルB（'Identical content'）のハッシュ: ${HASH_B}"
echo "ファイルC（'Different content'）のハッシュ: ${HASH_C}"
echo ""

if [ "${HASH_A}" = "${HASH_B}" ]; then
  echo "-> A と B は同じハッシュ（同一内容 = 同一オブジェクト）"
else
  echo "-> A と B は異なるハッシュ（予期しない結果）"
fi

if [ "${HASH_A}" != "${HASH_C}" ]; then
  echo "-> A と C は異なるハッシュ（異なる内容 = 異なるオブジェクト）"
fi

echo ""
echo "--- .git/objects の中身を覗く ---"
echo ""
echo ".git/objects ディレクトリの構造:"
find .git/objects -type f | head -10 | while read -r path; do
  echo "  ${path}"
done
echo ""
echo "-> ハッシュの先頭2文字がディレクトリ名、残りがファイル名"
echo "-> これがgitの「内容アドレス可能ストレージ」の実体"
echo "-> ファイルシステムのディレクトリ操作だけで実装されている"
echo "-> データベースは使わない（Monotoneとの決定的な違い）"
```

### 演習で見えたこと

三つの演習を通じて、gitの内部構造を自分の手で操作した。

演習1で確認したgitの最初のコミットは、わずか10ファイル・約1,000行のCコードだ。この最小限のコードが、blob、tree、commitという3つのオブジェクトタイプと、それらを操作する7つのコマンドを実装している。2026年現在、数億のリポジトリを管理するgitの原型が、ここにある。

演習2では、gitの低レベルコマンドを使って、手動でコミットを作成した。`hash-object`でblobを作り、`write-tree`でtreeを作り、`commit-tree`でcommitを作る。日常的に使う`git add`と`git commit`は、これらの低レベル操作を自動化したものに過ぎない。gitの「陶器」の下には、単純で透明な「配管」がある。

演習3では、内容アドレッシングを体験した。同じ内容は同じハッシュ値を持つ。この原理がgitの重複排除と完全性保証を支えている。そして、そのストレージは単純なファイルシステム操作で実装されている。データベースは使わない。Torvaldsが「ファイルシステムの人間」として設計した痕跡が、`.git/objects`ディレクトリの構造に刻まれている。

---

## 6. gitの誕生が意味するもの

### 制約が生んだイノベーション

gitの誕生は、計画されたものではなかった。BitKeeper事件という危機的状況が、Torvaldsに「自分で作る」ことを強いた。そして、Torvaldsが3年間BitKeeperで蓄積した「分散型VCSとはこうあるべきだ」という知見が、その危機をイノベーションに変換した。

この構造は、ソフトウェアの歴史において繰り返し現れるパターンだ。制約が創造性を引き出す。Torvaldsは「既存のDVCSが遅い」という制約を、根本的に異なるアプローチ——コンテンツアドレッサブルファイルシステム——で解決した。もし既存のDVCSが「十分に速かった」なら、gitは生まれなかっただろう。

### 設計の継承と断絶

gitはBitKeeperの「フリーな代替品」として生まれたが、BitKeeperのクローンではない。gitの設計は、BitKeeperから「分散型VCSのワークフロー」を、Monotoneから「SHA-1による内容アドレッシング」を受け継ぎつつ、実装においては根本的に異なるアプローチを取った。

BitKeeperはリネームを明示的に追跡した。gitはリネームを追跡しない。代わりに、内容の類似度から推測する（ヒューリスティック検出）。BitKeeperとMonotoneはデータベースを使った。gitはファイルシステムを使った。BitKeeperは「完成品」としてのVCSだった。gitは「部品」としてのファイルシステムだった。

この「継承と断絶」の組み合わせが、gitを単なる後継ツールではなく、パラダイムシフトにした。gitは「より良いBitKeeper」ではなく、「バージョン管理の基盤技術」だった。

### 「stupidであること」の力

gitのREADMEが宣言した「stupid content tracker」——この「愚直さ」は、20年の歳月を経て、その真価を証明した。

gitは「賢い」ことをしない。ブランチ戦略を強制しない。ワークフローを規定しない。コミットメッセージのフォーマットを指定しない。gitが提供するのは、コンテンツを追跡するための「配管」だけだ。

この「愚直さ」が、gitの普遍性を生んだ。Git-flow、GitHub Flow、トランクベース開発——あらゆるワークフローが、gitの上に構築できる。一人の開発者の個人プロジェクトから、Linuxカーネルのような数千人規模の開発まで、同じツールが使える。gitが「賢い」ツールだったなら、特定のワークフローに最適化され、他のワークフローには不適合だっただろう。

Torvaldsが2005年4月に下した「ファイルシステムとして設計する」という判断は、gitの20年以上にわたる成功の土台となった。

---

## 7. まとめと次回予告

### この回の要点

第一に、Linus Torvaldsが既存のDVCS（Monotone、Darcs、GNU arch）を選ばず自作を決断した理由は、「速度」「分散」「単純さ」の三要件を同時に満たすツールが存在しなかったためだ。Monotoneは設計思想で先行していたが性能が不足し、Darcsはパッチ理論の計算量に問題があり、GNU archは使い勝手に難があった。

第二に、gitは「バージョン管理ツール」ではなく「コンテンツアドレッサブルファイルシステム」として設計された。SHA-1ハッシュによる内容アドレッシング、blob/tree/commitの3オブジェクトモデル、スナップショット型の履歴管理——これらの設計は、Torvaldsの「ファイルシステムの人間」としての視点から生まれた。

第三に、gitの最初のコミット（2005年4月7日）はわずか10ファイル・約1,000行のCコード。7つの低レベルコマンドが、gitの全てを凝縮していた。開発開始からself-hostingまで4日、Linuxカーネル管理開始まで13日、6.7パッチ/秒のベンチマーク達成まで26日という驚異的な速度で進んだ。

第四に、2005年6月17日にgitで管理された最初の公式カーネルリリース（2.6.12）が行われ、7月26日にJunio Hamanoへメンテナが移譲され、12月21日にv1.0がリリースされた。8ヶ月半で、gitは個人プロジェクトからコミュニティの共有資産へと成長した。

第五に、gitの「stupidであること」——愚直にコンテンツを追跡するだけのツールであること——が、あらゆるワークフローに適応できる普遍性を生み出した。

### 冒頭の問いへの暫定回答

LinusはなぜGitを「自分で作る」ことを選んだのか。

既存のツールが「十分でなかった」からだ。

だが、「十分でなかった」のは機能の問題ではなく、設計の問題だった。Monotoneは機能的にはgitの先駆者だった。Darcsは理論的にはgitより洗練されていた。だが、TorvaldsはLinuxカーネルという巨大プロジェクトの運用を通じて、「性能と単純さは機能より重要だ」という信念を持っていた。

この信念が、gitの設計を決定した。データベースの代わりにファイルシステムを使う。賢い抽象化の代わりに愚直な操作を提供する。バージョン管理ツールの代わりにコンテンツアドレッサブルファイルシステムを作る。

結果として生まれたのは、「最も優れたバージョン管理ツール」ではなく、「最も優れたバージョン管理の基盤」だった。その基盤の上に、20年にわたるエコシステムが構築された。

「自分で作る」ことを選ぶべきなのは、既存のツールの「機能」ではなく「設計」が合わないときだ。Torvaldsの判断は、この教訓を歴史に刻んだ。

### 次回予告

gitの「基盤」としての設計は理解した。だが、私たちが日常的に触れるgitは、この基盤の上に構築された「応用層」だ。

**第15回「Gitオブジェクトモデル——blob, tree, commit, tag」**

今回のハンズオンで触れたblob、tree、commitの3オブジェクト。これに加えてtagを含む4つのオブジェクトが、gitの全てを構成する。`.git/objects`ディレクトリの中身を徹底的に解剖し、SHA-1ハッシュがどう計算され、zlib圧縮がどう施され、packファイルがどう最適化されるのかを次回は追う。

gitの内部を知ることは、gitの挙動を「予測できる」エンジニアになるための第一歩だ。`git add`が何をし、`git commit`が何を作り、`git push`が何を送るのか——次回、その全てを明らかにする。

あなたの`.git`ディレクトリの中身を、覗いたことはあるだろうか。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Torvalds, L., "Kernel SCM saga..." Linux Kernel Mailing List (2005-04-06). <https://lkml.org/lkml/2005/4/6/121>
- Torvalds, L., "Re: Kernel SCM saga.." Linux Kernel Mailing List (2005-04-07). <https://lkml.org/lkml/2005/4/7/150>
- Torvalds, L., "Initial revision of 'git', the information manager from hell." git/git (2005-04-07). <https://github.com/git/git/commit/e83c5163316f89bfbde7d9ab23ca2e25604af290>
- Torvalds, L., "Tech Talk: Linus Torvalds on git." Google (2007-05-03). Transcript: <https://git.wiki.kernel.org/index.php/LinusTalk200705Transcript>
- Git SCM, "A Short History of Git." <https://git-scm.com/book/en/v2/Getting-Started-A-Short-History-of-Git>
- Wikipedia, "Git." <https://en.wikipedia.org/wiki/Git>
- Wikipedia, "Monotone (software)." <https://en.wikipedia.org/wiki/Monotone_(software)>
- Wikipedia, "Linux kernel version history." <https://en.wikipedia.org/wiki/Linux_kernel_version_history>
- GitLab, "Journey through Git's 20-year history." <https://about.gitlab.com/blog/journey-through-gits-20-year-history/>
- Atlassian, "What Can We Learn from the Code in Git's Initial Commit?" <https://www.atlassian.com/blog/bitbucket/what-can-we-learn-from-the-code-in-gits-initial-commit>
- Initial Commit, "A 16 Year History of the Git Init Command." <https://initialcommit.com/blog/history-git-init-command>
- Linux Journal, "A Git Origin Story." <https://www.linuxjournal.com/content/git-origin-story>
- Linux Foundation, "10 Years of Git: An Interview with Git Creator Linus Torvalds." <https://www.linuxfoundation.org/blog/blog/10-years-of-git-an-interview-with-git-creator-linus-torvalds>
- Hamano, J.C., "GIT—A Stupid Content Tracker." Ottawa Linux Symposium (2006). <https://landley.net/kdocs/ols/2006/ols2006v1-pages-385-394.pdf>
- Git Tower, "Celebrating 20 Years of Git: 20 Interesting Facts From its Creator." <https://www.git-tower.com/blog/git-turns-20>
