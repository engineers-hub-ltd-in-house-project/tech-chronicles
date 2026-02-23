# UNIXという思想

## ——パイプ、プロセス、ファイル――すべてはここから始まった

### 第3回：Ken ThompsonとDennis Ritchie——二人の天才が残したもの

**連載「UNIXという思想——パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- UNIXの設計哲学を生んだ二人の人間——Ken ThompsonとDennis Ritchieの経歴と技術的功績
- C言語がなぜ、どのようにして生まれ、UNIXの移植性を決定的にしたのか
- 「OSを高級言語で書く」という判断がなぜ革命的だったのか
- UNIXのカーネル構造——プロセス、ファイルシステム、シェルの三層設計
- C言語でUNIXシステムコール（fork, exec, pipe, open, read, write）を直接呼び出す実践

---

## 1. 報じられなかった死

2011年10月5日、Steve Jobsが亡くなった。世界中のメディアが一斉に報じた。ニュースサイトのトップページがJobsの写真で埋まり、Appleストアには花束が積まれ、SNSには追悼の言葉が溢れた。56歳だった。

その7日後、2011年10月12日、Dennis Ritchieがニュージャージー州バークレーハイツの自宅で亡くなった。70歳だった。

世間は、ほぼ何も報じなかった。

私はRitchieの訃報をRob PikeのGoogle+への投稿で知った。Pikeは元Bell Labsの同僚で、Plan 9やGo言語をThompsonと共に設計した人物だ。彼は後にこう述べている。「Dennisはより大きな影響を与えた。それなのに一般の人々は彼が誰かすら知らない」。Brian Kernighanもニューヨーク・タイムズに語った。「Dennisが作ったツール——そしてその直接の子孫たち——は、今日のほとんどすべてのものを動かしている」。

私は、この報道の格差に憤りを感じた。同時に、納得もしていた。Jobsの仕事は目に見える。iPhoneを手に取れば、Jobsの遺産に触れられる。だがRitchieの仕事は、iPhoneの内側にある。macOSはUNIX認証を受けたOSであり、その基盤にはC言語で書かれたDarwinカーネルがある。iOSもまたDarwinの上に構築されている。Jobsが世界に届けた製品の、その奥底で動いている基盤を作った男。それがDennis Ritchieだった。

あなたが今使っているOS——Linux、macOS、Windows（そのカーネルの一部はCで書かれている）、Android、iOS——そのすべてが、Ritchieの仕事の上に成り立っている。あなたが書いているコード——Python、Java、JavaScript、Go、Rust——それらの言語の文法は、Ritchieが設計したC言語の影響を直接的・間接的に受けている。

UNIXの設計哲学は、どのような人間によって生み出されたのか。前回、私たちはMulticsの挫折とPDP-7という制約がUNIXを生んだ経緯を辿った。だが、制約だけでは哲学は生まれない。制約の中で「何を残し、何を捨てるか」を判断できる人間がいて、初めて哲学が結晶する。

Ken ThompsonとDennis Ritchie。この二人の天才がいなければ、UNIXは存在しなかった。そしてUNIXがなければ、あなたが今日使っているほぼすべてのソフトウェアは、別の形をしていただろう。

---

## 2. Ken Thompson——システムの原型を作る男

### 二進数に魅せられた少年

Kenneth Lane Thompson、1943年2月4日、ルイジアナ州ニューオーリンズ生まれ。父は米海軍の戦闘機パイロットで、家族は数年ごとに転居を繰り返した。

Thompsonは少年時代から論理に取り憑かれていた。後に彼自身がこう語っている。「私はいつも論理に魅了されていた。小学校でさえ、算数の問題を二進数でやったりしていた。ただ魅了されていたから」。

カリフォルニア大学バークレー校で電気工学・コンピュータサイエンスを学び、情報理論家Elwyn Berlekampのもとで学士号（1965年）と修士号（1966年）を取得した。在学中にはGeneral Dynamicsでのワークスタディプログラムにも参加している。

1966年、Bell Labsに入社。ここからThompsonの伝説が始まる。

### 正規表現の実装者

Thompsonの技術的功績は、UNIXだけにとどまらない。まず触れるべきは、正規表現の実装だ。

1968年、ThompsonはCommunications of the ACMに「Regular Expression Search Algorithm」を発表した。これは、正規表現を非決定性有限オートマトン（NFA）に変換するアルゴリズム——後にThompson構成法と呼ばれることになる——を記述した論文だ。Thompsonはこのアルゴリズムを、QEDテキストエディタに正規表現によるパターンマッチングを実装するために開発した。

注目すべきは、ThompsonがこのアルゴリズムをIBM 7094のマシンコードへのJIT（Just-In-Time）コンパイルとして実装したことだ。正規表現のパターンを解析し、それに対応するマシンコードの断片を動的に生成して実行する。1968年にJITコンパイルの原型を実践していたのだ。

今日、あなたがプログラミング言語で正規表現を使うとき——Pythonの`re`モジュール、JavaScriptの`RegExp`、Goの`regexp`パッケージ——そのほぼすべてがThompsonの表記法の変種を使用している。`grep`コマンドの名前自体が、edエディタのコマンド`g/re/p`（global / regular expression / print）に由来する。正規表現は、UNIXのテキスト処理文化の根幹であり、その最初の実用的実装を作ったのがThompsonだった。

### UNIXの原型

前回詳しく見たように、Thompsonは1969年にPDP-7の上でUNIXの原型を作った。Space Travelというゲームの移植から始まり、ファイルシステム、シェル、ユーティリティ群へと発展したこの小さなOSは、Multicsで学んだ本質をPDP-7の制約の中で蒸留したものだった。

だが、Thompsonの才能が最も鮮やかに発揮されたのは、システムの「原型」を作る速度と精度においてだった。Dennis Ritchieは後に、ThompsonのコーディングスタイルについてBrian Kernighanにこう語っている。Thompsonは最初から動くものを作る。設計を紙の上で練り込むのではなく、手を動かしてコードを書き、動かしながら形にしていく。PDP-7のUNIXはまさにその方法で生まれた。

1971年にUNIXがPDP-11に移行したとき、ThompsonはPDP-11のアセンブリ言語でカーネルを書き直した。この時点でUNIXには既に、fork()によるプロセス生成、exec()によるプログラム実行、階層型ファイルシステム、パイプ（1973年にDoug McIlroyの強い要望を受けてThompsonが「一晩の熱狂的な作業」で実装）、そしてシェルが備わっていた。

### チェスとBelle

Thompsonのもう一つの情熱はチェスだった。1971年には最初のバージョンのUNIXにチェスプログラムを書いている。後にJoseph Condonとともに、Belleという専用チェスハードウェアを開発した。Belleは1980年、オーストリアのリンツで開催された第3回世界コンピュータチェス選手権で優勝した。ACM北米コンピュータチェス選手権でも5回の優勝を果たしている。専用ハードウェアを使って世界コンピュータチェス選手権を制した最初のシステムだった。

さらに、Thompsonはチェスのエンドゲームテーブルベース——4、5、6ピースのすべての終盤局面を完全に列挙したデータベース——を構築した。逆行解析（retrograde analysis）によって、あらゆる終盤局面における「完璧な手」を事前計算しておく。計算量による力技で、人間の直観を超える。「疑わしければ、力技を使え（When in doubt, use brute force）」——Thompsonの有名な格言は、彼自身の実践から生まれたものだった。

### Plan 9からGo言語へ

Bell Labsでの後半のキャリアで、ThompsonはRob Pike、Dave Presotto、Phil Winterbottomらとともに、Plan 9 from Bell Labsの設計と実装に携わった。Plan 9は「UNIXの次」を目指すOSであり、「すべてはファイルである」の原則をUNIX以上に徹底したシステムだった。ネットワーク越しのリソースもファイルとしてマウントでき、プロセスごとに独立した名前空間を持つ。商業的には広く普及しなかったが、そのアイデア——UTF-8（Rob PikeとThompsonが1992年に発明）、名前空間の分離、FUSEの原型——は、後のLinuxやmacOSに形を変えて流れ込んでいる。

2006年、ThompsonはGoogleに入社した。そこでRob PikeとRobert Griesemerとともに、新しいプログラミング言語の設計に着手した。2007年9月21日、3人はGoogleのホワイトボードの前で、新言語の目標をスケッチし始めた。2009年11月に公開されたこの言語は、Go（Golang）と名付けられた。

GoにはUNIXの設計哲学が色濃く反映されている。シンプルであること。合成可能であること。読みやすいコードを書きやすい構造にすること。C言語の直系の子孫でありながら、Cの弱点——メモリ管理の危険性、並行性の欠如——を現代的に解決した。Thompsonの60年以上にわたるキャリアの集大成とも言える言語だ。

Ken Thompsonのキャリアを通覧すると、一つのパターンが見える。正規表現、UNIX、Belle、Plan 9、Go——彼は常に「システムの原型」を作っている。全体のアーキテクチャを一人で構想し、動くものを素早く形にする。理論に耽溺するのではなく、動く実装で語る。UNIXのシンプルさは、Thompson個人の美学でもあった。

---

## 3. Dennis Ritchie——言語で世界を書き換えた男

### 物理学者になれなかった青年

Dennis MacAlistair Ritchie、1941年9月8日、ニューヨーク州ブロンクスビル生まれ。ニュージャージー州サミットで育った。父Alistair RitchieはBell Labsのエンジニアで、スイッチング理論の専門家だった。息子は父の職場に導かれるようにして、計算機科学の道に進むことになる。

Ritchieはハーバード大学で物理学を学び、1963年に学士号を取得した。だが彼は後にこう振り返っている。「学部時代の経験から、物理学者になるには自分は十分に賢くないと悟った」。在学中、ハーバードのコンピュータシステム——UNIVAC I——の運用に関する講義に出席したことが、計算機科学への関心のきっかけとなった。

ハーバードで数学のPhD課程に進んだが、博士論文の審査が行われることはなかった。Bell Labsでの仕事が、学位の完成より先に彼を捉えたのだ。

### B言語からC言語へ

RitchieがBell Labsに入社した後、Multicsプロジェクトに参加し、その撤退を経てUNIXの開発に加わった経緯は、前回見たとおりだ。ここでは、Ritchie最大の技術的功績——C言語の設計——に焦点を当てる。

UNIXの初期版はPDP-7のアセンブリ言語で書かれていた。PDP-11に移行した後も、カーネルはPDP-11のアセンブリだった。アセンブリ言語は特定のハードウェアに密結合している。PDP-11のアセンブリで書かれたプログラムは、他のマシンでは一行も動かない。

Ken ThompsonはPDP-7の上でB言語を設計していた。B言語はMITのMartin Richardsが1967年に設計したBCPL（Basic Combined Programming Language）を源流とする言語だ。Thompsonはこれを簡素化し、PDP-7のメモリ制約に収まるコンパイラを実装した。

だがB言語には根本的な問題があった。型がない。B言語の世界では、すべてのデータが「マシンワード」——PDP-7なら18ビット、PDP-11なら16ビット——として扱われる。文字も整数も浮動小数点数も、すべて同じサイズのワードだ。PDP-7の18ビットワードには2つのASCII文字（各9ビット）を詰め込めたが、PDP-11の16ビットワードでは文字の格納が不自然になった。さらに、PDP-11はバイトアドレッシングをサポートしており、個々のバイトを直接操作できる。B言語のワード指向モデルは、この能力を活かせなかった。

1971年から1972年にかけて、RitchieはB言語を拡張し始めた。まず型システムを導入した。`int`と`char`の区別、配列、ポインタ。この過渡期の言語は内部で「NB」（New B）と呼ばれた。さらに構造体、共用体、より豊かな型表現が加わり、1973年初頭までにはC言語の本質的な部分が完成した。

Ritchie自身が「The Development of the C Language」（1993年）で記しているように、Cの設計は一つの明確な動機に駆動されていた。UNIXのカーネルをアセンブリ言語ではなく高級言語で書き直すこと。そのためには、言語がハードウェアに十分近い抽象度を持ちつつ、特定のハードウェアに依存しない表現力を備えている必要があった。

### C言語の設計思想

C言語の設計には、いくつかの一貫した原則がある。

**プログラマを信頼する**。Cは、プログラマが何をしているか理解していることを前提とする。配列の境界チェックはしない。型の暗黙変換は最小限の警告で行う。ポインタ演算は自由だ。この設計判断は、安全性と効率性のトレードオフにおいて、一貫して効率性の側に立つ。後世の言語——Java、Rust、Go——がCの「危険な自由」を制限する方向に進化したことを考えると、Cの設計は意図的な選択であったことがわかる。

**ハードウェアに近い抽象**。Cのポインタは、メモリアドレスの薄いラッパーだ。構造体のメモリレイアウトはプログラマが制御できる。ビット演算、シフト演算は言語の第一級の機能として提供される。Cは「高級アセンブリ言語」と揶揄されることがあるが、それはCの設計の意図を正確に捉えている。OSのカーネルを書くために設計された言語として、ハードウェアの直接操作が不可欠だった。

**小さな言語仕様**。C言語のキーワードは、K&R Cの時代で32個に過ぎなかった。言語のコア機能は最小限に抑え、ライブラリで拡張する。「言語は小さく、ライブラリは大きく」——この設計はUNIXの哲学「小さなツールの組み合わせ」と同じ思想だ。

この三つの原則は、UNIXの設計哲学と驚くほど相似形を成している。

| UNIXの原則               | C言語の原則                        |
| ------------------------ | ---------------------------------- |
| 一つのことをうまくやれ   | 言語は小さく、ライブラリで拡張する |
| プログラムを組み合わせよ | 関数を組み合わせてプログラムを構成 |
| テキストを共通語にせよ   | ソースコードが人間可読のテキスト   |
| 制約の中で簡素に作れ     | ハードウェアに近く、余計なものなし |

UNIXとCは、別々に設計されたのではない。同じ人々が、同じ場所で、同じ思想のもとに作った。UNIXはCのために設計されたOSであり、CはUNIXのために設計された言語だ。この共進化こそが、両者の一貫性の源泉である。

### 1973年——OSを高級言語で書き直す革命

1973年の夏、RitchieとThompsonは、UNIXのカーネルをC言語で書き直した。Version 4 UNIXとして知られるこのバージョンは、世界で初めてカーネルの大部分が高級言語で記述されたOSだった。

当時の常識を理解する必要がある。OSのカーネルはアセンブリ言語で書くものだった。ハードウェアを直接操作するコード——割り込みハンドラ、コンテキストスイッチ、メモリ管理——は、マシンの命令セットを直接使わなければ効率的に書けないとされていた。高級言語で書かれたOSなど、使い物にならないほど遅い——そう信じられていた。

RitchieとThompsonは、この常識に挑んだ。C言語は、高級言語としての抽象化とアセンブリ言語に近い低水準操作の両方を提供する。ポインタ操作、ビット演算、直接的なメモリアクセス——これらの機能があるからこそ、カーネルのような低水準のコードをCで書けた。

もちろん、すべてをCで書けたわけではない。割り込みの入り口や、コンテキストスイッチの最も低水準な部分、ブートストラップコードは依然としてアセンブリだった。だが、カーネルの論理——プロセス管理、ファイルシステム、デバイスドライバの上位層——はCで記述された。1983年時点で、UNIXカーネルは2万行未満のコードで構成され、その75%以上がマシン非依存だった。

この書き直しがもたらした最大の成果は、移植性だ。アセンブリ言語で書かれたOSは、特定のCPUアーキテクチャに束縛される。PDP-11のアセンブリで書かれたUNIXは、VAXには移植できない。だがCで書かれたUNIXは、そのCPU向けのCコンパイラがあれば、原理的には移植できる。

ただし、移植性の獲得は即座ではなかった。Version 4にはまだPDP-11依存のコードが多く、最初の他プラットフォームへの移植は1978年のInterdata 8/32だった。Steve JohnsonのPortable C Compiler（PCC）の開発も、この移植性の実現に不可欠だった。だが、「原理的に移植可能である」という事実が道を開いた。この道の先に、VAX、Sun SPARC、IBM POWER、Intel x86、ARM——あらゆるアーキテクチャ上で動くUNIX系OSの歴史がある。

あなたが今日使っているLinuxカーネルは、Cで書かれている。macOSのXNUカーネルもCで書かれている。WindowsのNTカーネルもCで書かれている。iOSも、Androidも。RitchieがCで書き直したUNIXカーネルは、その直系の子孫——あるいは思想的な子孫——が、文字通り世界中のコンピュータで動いている。

---

## 4. 共進化するOSと言語——UNIXカーネルの三層設計

### プロセス、ファイルシステム、シェル

ThompsonとRitchieが設計したUNIXカーネルは、三つの根本的な抽象の上に構築されている。プロセス、ファイルシステム、そしてシェルだ。

```
┌─────────────────────────────────────────────────────┐
│                      ユーザ空間                      │
│                                                     │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐            │
│  │  shell   │  │  grep   │  │  cat    │  ...       │
│  │ (sh/bash)│  │         │  │         │            │
│  └────┬─────┘  └────┬────┘  └────┬────┘            │
│       │             │            │                  │
│  ─────┼─────────────┼────────────┼──── システムコール境界
│       │             │            │                  │
│  ┌────▼─────────────▼────────────▼────────────────┐ │
│  │              カーネル空間                       │ │
│  │                                                │ │
│  │  ┌──────────────────────────────────────────┐  │ │
│  │  │         プロセス管理                      │  │ │
│  │  │  fork() / exec() / wait() / exit()       │  │ │
│  │  │  スケジューリング / シグナル              │  │ │
│  │  └──────────────────────────────────────────┘  │ │
│  │                                                │ │
│  │  ┌──────────────────────────────────────────┐  │ │
│  │  │         ファイルシステム                  │  │ │
│  │  │  open() / read() / write() / close()     │  │ │
│  │  │  inode / ディレクトリ / パーミッション    │  │ │
│  │  └──────────────────────────────────────────┘  │ │
│  │                                                │ │
│  │  ┌──────────────────────────────────────────┐  │ │
│  │  │         デバイスドライバ                  │  │ │
│  │  │  キャラクタデバイス / ブロックデバイス    │  │ │
│  │  └──────────────────────────────────────────┘  │ │
│  └────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

この構造で最も重要なのは、ユーザ空間とカーネル空間の明確な分離だ。Multicsが8段階のリング保護で精緻なアクセス制御を実装しようとしたのに対し、UNIXは2段階——カーネルモード（特権あり）とユーザモード（特権なし）——に簡素化した。ユーザ空間のプログラムがカーネルの機能を利用するには、システムコールという明確に定義されたインタフェースを通る。

### fork()とexec()——プロセス生成の設計

UNIXのプロセス生成モデルは、シンプルさにおいて際立っている。

`fork()`は、現在のプロセスの完全なコピーを作る。親プロセスのメモリ空間、開いているファイルディスクリプタ、環境変数——すべてが複製される。fork()の戻り値だけが異なる。親プロセスには子プロセスのPID（プロセスID）が返り、子プロセスには0が返る。

`exec()`は、現在のプロセスのメモリ空間を新しいプログラムで置き換える。fork()で作った子プロセスの中でexec()を呼ぶと、子プロセスが別のプログラムに「変身」する。

```
親プロセス (PID=100)
    │
    ├── fork() ──→ 子プロセス (PID=101)
    │                  │
    │                  ├── exec("/bin/ls")
    │                  │       ↓
    │                  │   [lsプログラムに変身]
    │                  │   ディレクトリ一覧を出力
    │                  │   exit(0)
    │                  │
    ├── wait() ◀──────┘
    │   (子の終了を待つ)
    ▼
```

なぜ、プロセス生成を「コピー」と「置換」の二段階に分けたのか。一つのシステムコールで「新しいプログラムを新しいプロセスとして起動する」方が直観的ではないか。

この二段階分離には、深い設計上の理由がある。fork()とexec()の間——子プロセスが作られた後、新しいプログラムに置き換わる前——に、子プロセスの環境を自由に操作できるのだ。ファイルディスクリプタをリダイレクトしたり、環境変数を変更したり、シグナルマスクを設定したり。この「fork()とexec()の間の隙間」が、UNIXのパイプやリダイレクションの実装を驚くほどシンプルにしている。

シェルが`ls | grep txt`を実行するとき、内部では次のことが起きている。

1. シェルがpipe()を呼び、パイプを作る
2. シェルがfork()で子プロセスを作る（ls用）
3. ls用の子プロセスが、標準出力をパイプの書き込み端に接続し、exec("ls")を呼ぶ
4. シェルがfork()でもう一つの子プロセスを作る（grep用）
5. grep用の子プロセスが、標準入力をパイプの読み取り端に接続し、exec("grep", "txt")を呼ぶ
6. シェルがwait()で両方の子プロセスの終了を待つ

fork()とexec()が分離されているからこそ、ステップ3と5で「exec()の前にファイルディスクリプタを操作する」ことができる。もしプロセス生成が一つの関数で完結していたら、このような柔軟な操作は不可能か、はるかに複雑なAPIが必要になっていただろう。

### ファイルディスクリプタの統一インタフェース

UNIXのファイルシステムは、第6回で詳しく扱う「Everything is a file」の原則に基づいている。ここでは、C言語から見たシステムコールの統一性に焦点を当てる。

```c
int fd;

/* 通常のファイルを開く */
fd = open("/etc/passwd", O_RDONLY);

/* パイプを作る */
int pipefd[2];
pipe(pipefd);  /* pipefd[0]:読み取り端, pipefd[1]:書き込み端 */

/* どちらも同じインタフェースで読み書きできる */
char buf[1024];
read(fd, buf, sizeof(buf));       /* ファイルから読む */
read(pipefd[0], buf, sizeof(buf)); /* パイプから読む */
```

`open()`, `read()`, `write()`, `close()`——この四つのシステムコールで、ディスク上のファイルも、パイプも、デバイスも、ネットワークソケットも、同じように操作できる。ファイルディスクリプタという整数値——0, 1, 2, 3, ...——が、あらゆるI/Oリソースへの統一的なハンドルとなる。

この設計をC言語で表現したとき、コードは驚くほどシンプルになる。ファイルから読んでいるのかパイプから読んでいるのか、read()を呼ぶ側は気にしなくてよい。ファイルディスクリプタの番号さえあれば、同じコードで動く。

標準入力（fd=0）、標準出力（fd=1）、標準エラー出力（fd=2）という規約は、この統一インタフェースの上に成り立っている。プログラムは標準入力から読み、標準出力に書き、エラーメッセージは標準エラー出力に書く。パイプでプログラムを繋ぐとき、あるプログラムの標準出力（fd=1）を次のプログラムの標準入力（fd=0）に接続する。ファイルディスクリプタが統一インタフェースだからこそ、この接続が可能になる。

CとUNIXの共進化は、こうしたシステムコールのAPI設計にも現れている。C言語のシンプルな関数呼び出し規約が、UNIXのシンプルなシステムコールインタフェースと相性がよい。UNIXのシステムコールは、Cの関数として自然に表現できるように設計されている。両者は、互いを前提として設計されたのだ。

---

## 5. 二人の天才と、その周囲の人々

ThompsonとRitchieの仕事は、二人だけで成し遂げられたものではない。Bell Labsという環境と、そこに集まった人々の貢献を無視してはならない。

### Doug McIlroy——パイプの発明者にしてUNIX哲学の言語化者

Douglas McIlroyは、Bell Labsの計算機科学研究部門（Computing Techniques Research Department）の責任者だった。彼はThompsonとRitchieの上司であり、UNIXプロジェクトの庇護者でもあった。

McIlroyの最大の技術的貢献はパイプの概念だ。前回触れたように、McIlroyは1964年にパイプのアイデアを提案し、1973年にThompsonがそれを実装した。だがMcIlroyの貢献はパイプだけにとどまらない。彼はUNIXの設計哲学を最初に明文化した人物でもある。

> This is the Unix philosophy: Write programs that do one thing and do it well. Write programs to work together. Write programs to handle text streams, because that is a universal interface.

「一つのことをうまくやるプログラムを書け。協調して動くプログラムを書け。テキストストリームを扱うプログラムを書け。なぜならそれが万能のインタフェースだから」——この言葉はMcIlroyのものだ。UNIXの設計哲学は、ThompsonとRitchieのコードの中に暗黙に存在していた。それを言葉にし、原則として定式化したのがMcIlroyだった。

### Brian Kernighan——語り部としての功績

Brian Kernighanは、UNIXのカーネルコードを書いたわけではない。だが、UNIXの思想を世界に伝える上で、おそらく誰よりも大きな役割を果たした。

Ritchieとの共著『The C Programming Language』（1978年、通称K&R本）は、C言語の最初の広く入手可能な教科書となった。Kernighanが本文の大部分を執筆し、Ritchieのリファレンスマニュアルが付録として添えられた。この本は長年にわたってC言語の事実上の標準として機能し、初版で記述された言語仕様は「K&R C」として知られることになる。

Rob Pikeとの共著『The UNIX Programming Environment』（1984年）は、UNIXの設計哲学を実践的に解説した書籍だ。小さなツールの組み合わせ、フィルタパターン、シェルスクリプト——UNIXの思想を「どう使うか」の文脈で体系的に記述した。

Kernighanはまた、UNICSという名前——Multiplexed Information and Computing Serviceに対するUniplexed Information and Computing Service——を考案した人物でもある（前回参照）。多重化されたMulticsに対する単一のUNICS。この命名のセンスは、UNIXのシンプルさの美学を見事に捉えている。

UNIXの歴史において、Kernighanは「コードを書いた人」ではなく「思想を言語化し、伝えた人」として位置づけられる。ThompsonとRitchieが作ったシステムの哲学を、明瞭な散文とよく設計された書籍で世界に届けた。技術の普及において、実装者と同じくらい「語り部」が重要であることを、Kernighanの存在が証明している。

### Joe Ossanna——忘れられた四人目

UNIXの誕生に関わった四人——Thompson、Ritchie、McIlroy、Ossanna——のうち、Joe Ossannaの名前は最も知られていない。

Joseph Frank Ossanna, Jr.（1928年12月10日〜1977年11月28日）は、Bell Labsのエンジニアであり、Multicsの開発に参加した後、UNIXの初期開発に加わった人物だ。彼の最大の貢献は、テキスト整形プログラムroffの書き直し（nroff）と、写植対応版のtroff（1973年）の開発だった。

UNIXが Bell Labs内で生き延びた理由の一つが、特許部門へのテキスト処理サービスの提供だったことを思い出してほしい。Ossannaのtroffは、その「生存戦略」を技術的に支えた中核のツールだった。manページのフォーマットも、troffの書式に基づいている。

Ossannaは1977年に49歳で亡くなった。troffの他デバイス対応という未完の仕事は、Brian Kernighanが引き継いだ。

---

## 6. チューリング賞と「信頼の問題」

1983年、ThompsonとRitchieはACMチューリング賞を共同受賞した。受賞理由は「for their development of generic operating systems theory and specifically for the implementation of the UNIX operating system」——「汎用オペレーティングシステム理論の発展、特にUNIXオペレーティングシステムの実装に対して」。

チューリング賞の受賞講演は、通常、受賞対象の技術について語られる。Ritchieの講演も、Thompsonの講演も、そうであるべきだった。Ritchieは実際にUNIXの歴史と設計について語った。だがThompsonの講演は、まったく予想外の方向に進んだ。

「Reflections on Trusting Trust」——「信頼への信頼についての考察」と題されたThompsonの講演は、コンパイラにバックドアを仕込む手法を記述したものだった。Cコンパイラが自分自身をコンパイルする際に、ログインプログラムのバックドアを生成するコードを挿入する。そしてそのバックドア挿入コード自体も、コンパイラの次世代に受け継がれるようにする。ソースコードを見ても痕跡はない。コンパイラのバイナリだけがバックドアを「知って」いる。

この講演はコンピュータセキュリティの金字塔となった。「あなたは自分が使っているツールをどこまで信頼できるか？」という問いは、サプライチェーンセキュリティが叫ばれる現代において、ますます切実さを増している。

ThompsonとRitchieは、UNIXというOSを作ったことで受賞した。だがThompsonが講演で語ったのは、そのOSの上に成り立つ「信頼」の脆弱性だった。自分が作ったシステムの根本的な弱点を、受賞講演で率直に語る。この知的誠実さが、Thompson という人間の本質を示している。

---

## 7. ハンズオン：C言語でUNIXシステムコールを呼ぶ

ここまで、ThompsonとRitchieの仕事を歴史的に辿ってきた。ここからは手を動かす。C言語でUNIXのシステムコール——fork()、exec()、pipe()、open()、read()、write()——を直接呼び出し、UNIXの基本操作を体で理解する。

### 環境構築

```bash
docker run -it --rm ubuntu:24.04 bash
```

コンテナ内でCコンパイラを用意する。

```bash
apt-get update && apt-get install -y gcc
```

### 演習1：fork()とexec()——プロセス生成の基本

```c
/* fork_exec.c — fork()とexec()の基本 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    printf("親プロセス PID=%d\n", getpid());

    pid_t pid = fork();

    if (pid < 0) {
        perror("fork");
        return 1;
    }

    if (pid == 0) {
        /* 子プロセス */
        printf("子プロセス PID=%d (親PID=%d)\n", getpid(), getppid());
        printf("子プロセスが /bin/ls に変身する...\n");

        /* exec()で子プロセスを別のプログラムに置き換える */
        execlp("ls", "ls", "-la", "/tmp", (char *)NULL);

        /* exec()が成功すれば、ここには到達しない */
        perror("exec");
        return 1;
    }

    /* 親プロセス */
    int status;
    waitpid(pid, &status, 0);
    printf("親プロセス: 子プロセス(PID=%d)が終了コード%dで終了\n",
           pid, WEXITSTATUS(status));

    return 0;
}
```

コンパイルと実行:

```bash
cat << 'EOF' > /tmp/fork_exec.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    printf("親プロセス PID=%d\n", getpid());
    pid_t pid = fork();
    if (pid < 0) { perror("fork"); return 1; }
    if (pid == 0) {
        printf("子プロセス PID=%d (親PID=%d)\n", getpid(), getppid());
        printf("子プロセスが /bin/ls に変身する...\n");
        execlp("ls", "ls", "-la", "/tmp", (char *)NULL);
        perror("exec");
        return 1;
    }
    int status;
    waitpid(pid, &status, 0);
    printf("親プロセス: 子プロセス(PID=%d)が終了コード%dで終了\n",
           pid, WEXITSTATUS(status));
    return 0;
}
EOF
gcc -o /tmp/fork_exec /tmp/fork_exec.c && /tmp/fork_exec
```

fork()が呼ばれた瞬間、プロセスが二つに分裂する。親プロセスと子プロセスは、fork()の戻り値以外は完全に同一のコピーだ。子プロセスの中でexeclp()を呼ぶと、子プロセスのメモリ空間がlsプログラムで上書きされる。exec()は「戻らない関数」だ。成功すれば、呼び出し元のプログラムはもう存在しない。

### 演習2：pipe()——プロセス間通信

```c
/* pipe_demo.c — パイプによるプロセス間通信 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    int pipefd[2];

    if (pipe(pipefd) < 0) {
        perror("pipe");
        return 1;
    }

    printf("パイプ作成: 読み取り端fd=%d, 書き込み端fd=%d\n",
           pipefd[0], pipefd[1]);

    pid_t pid = fork();

    if (pid < 0) {
        perror("fork");
        return 1;
    }

    if (pid == 0) {
        /* 子プロセス: パイプから読む */
        close(pipefd[1]);  /* 書き込み端を閉じる */

        char buf[256];
        ssize_t n;
        printf("[子] パイプからの読み取りを待機...\n");

        while ((n = read(pipefd[0], buf, sizeof(buf) - 1)) > 0) {
            buf[n] = '\0';
            printf("[子] 受信: %s", buf);
        }

        close(pipefd[0]);
        printf("[子] パイプが閉じられた。終了。\n");
        return 0;
    }

    /* 親プロセス: パイプに書く */
    close(pipefd[0]);  /* 読み取り端を閉じる */

    const char *messages[] = {
        "Hello from parent process\n",
        "This is pipe communication\n",
        "Just like | in shell\n",
        NULL
    };

    for (int i = 0; messages[i] != NULL; i++) {
        write(pipefd[1], messages[i], strlen(messages[i]));
        printf("[親] 送信: %s", messages[i]);
        usleep(100000);  /* 100ms待つ（可視化のため） */
    }

    close(pipefd[1]);  /* 書き込み端を閉じる → 子プロセスのread()が0を返す */

    int status;
    waitpid(pid, &status, 0);
    printf("[親] 子プロセスが終了。\n");

    return 0;
}
```

コンパイルと実行:

```bash
cat << 'EOF' > /tmp/pipe_demo.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    int pipefd[2];
    if (pipe(pipefd) < 0) { perror("pipe"); return 1; }
    printf("パイプ作成: 読み取り端fd=%d, 書き込み端fd=%d\n",
           pipefd[0], pipefd[1]);
    pid_t pid = fork();
    if (pid < 0) { perror("fork"); return 1; }
    if (pid == 0) {
        close(pipefd[1]);
        char buf[256];
        ssize_t n;
        printf("[子] パイプからの読み取りを待機...\n");
        while ((n = read(pipefd[0], buf, sizeof(buf) - 1)) > 0) {
            buf[n] = '\0';
            printf("[子] 受信: %s", buf);
        }
        close(pipefd[0]);
        printf("[子] パイプが閉じられた。終了。\n");
        return 0;
    }
    close(pipefd[0]);
    const char *messages[] = {
        "Hello from parent process\n",
        "This is pipe communication\n",
        "Just like | in shell\n",
        NULL
    };
    for (int i = 0; messages[i] != NULL; i++) {
        write(pipefd[1], messages[i], strlen(messages[i]));
        printf("[親] 送信: %s", messages[i]);
        usleep(100000);
    }
    close(pipefd[1]);
    int status;
    waitpid(pid, &status, 0);
    printf("[親] 子プロセスが終了。\n");
    return 0;
}
EOF
gcc -o /tmp/pipe_demo /tmp/pipe_demo.c && /tmp/pipe_demo
```

pipe()がカーネル内にバッファを作る。pipefd[1]に書いたデータが、pipefd[0]から読める。シェルが`ls | grep txt`を実行するとき、まさにこのpipe()→fork()→exec()の組み合わせが使われている。シェルの`|`という記号の裏側で、カーネルのパイプとプロセス生成が静かに動いている。

### 演習3：シェルのパイプラインを自作する

シェルの`ls /etc | grep conf | wc -l`を、Cのシステムコールだけで再現する。

```c
/* mini_pipeline.c — ls /etc | grep conf | wc -l を手動で実装 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    int pipe1[2], pipe2[2];

    /* パイプを2本作る */
    if (pipe(pipe1) < 0 || pipe(pipe2) < 0) {
        perror("pipe");
        return 1;
    }

    /* --- ls /etc --- */
    pid_t pid1 = fork();
    if (pid1 == 0) {
        /* 標準出力をpipe1の書き込み端に接続 */
        dup2(pipe1[1], STDOUT_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        execlp("ls", "ls", "/etc", (char *)NULL);
        perror("exec ls");
        _exit(1);
    }

    /* --- grep conf --- */
    pid_t pid2 = fork();
    if (pid2 == 0) {
        /* 標準入力をpipe1の読み取り端に接続 */
        dup2(pipe1[0], STDIN_FILENO);
        /* 標準出力をpipe2の書き込み端に接続 */
        dup2(pipe2[1], STDOUT_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        execlp("grep", "grep", "conf", (char *)NULL);
        perror("exec grep");
        _exit(1);
    }

    /* --- wc -l --- */
    pid_t pid3 = fork();
    if (pid3 == 0) {
        /* 標準入力をpipe2の読み取り端に接続 */
        dup2(pipe2[0], STDIN_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        execlp("wc", "wc", "-l", (char *)NULL);
        perror("exec wc");
        _exit(1);
    }

    /* 親プロセス: すべてのパイプ端を閉じて子プロセスを待つ */
    close(pipe1[0]); close(pipe1[1]);
    close(pipe2[0]); close(pipe2[1]);

    waitpid(pid1, NULL, 0);
    waitpid(pid2, NULL, 0);
    waitpid(pid3, NULL, 0);

    printf("\n上記は ls /etc | grep conf | wc -l と同じ結果\n");
    printf("シェルの | は、pipe() + fork() + dup2() + exec() の組み合わせ\n");

    return 0;
}
```

コンパイルと実行:

```bash
cat << 'EOF' > /tmp/mini_pipeline.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    int pipe1[2], pipe2[2];
    if (pipe(pipe1) < 0 || pipe(pipe2) < 0) {
        perror("pipe"); return 1;
    }
    pid_t pid1 = fork();
    if (pid1 == 0) {
        dup2(pipe1[1], STDOUT_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        execlp("ls", "ls", "/etc", (char *)NULL);
        perror("exec ls"); _exit(1);
    }
    pid_t pid2 = fork();
    if (pid2 == 0) {
        dup2(pipe1[0], STDIN_FILENO);
        dup2(pipe2[1], STDOUT_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        execlp("grep", "grep", "conf", (char *)NULL);
        perror("exec grep"); _exit(1);
    }
    pid_t pid3 = fork();
    if (pid3 == 0) {
        dup2(pipe2[0], STDIN_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        execlp("wc", "wc", "-l", (char *)NULL);
        perror("exec wc"); _exit(1);
    }
    close(pipe1[0]); close(pipe1[1]);
    close(pipe2[0]); close(pipe2[1]);
    waitpid(pid1, NULL, 0);
    waitpid(pid2, NULL, 0);
    waitpid(pid3, NULL, 0);
    printf("\n上記は ls /etc | grep conf | wc -l と同じ結果\n");
    printf("シェルの | は、pipe() + fork() + dup2() + exec() の組み合わせ\n");
    return 0;
}
EOF
gcc -o /tmp/mini_pipeline /tmp/mini_pipeline.c && /tmp/mini_pipeline
```

シェルで`ls /etc | grep conf | wc -l`と打てば一瞬で終わる処理が、Cのシステムコールで書くと60行以上になる。この差が、シェルという「接着剤」の価値を如実に示している。だが同時に、シェルの`|`の裏側でカーネルが何をしているかを理解することの重要性も見えてくる。パイプの中でデータが詰まったとき、プロセスがゾンビ化したとき、ファイルディスクリプタがリークしたとき——シェルの表面だけを知っている人間は、対処できない。

### 演習4：open(), read(), write()——ファイル操作の基本

```c
/* file_ops.c — UNIXのファイル操作の基本 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

int main(void) {
    const char *path = "/tmp/unix_test.txt";
    const char *data = "UNIXはCで書かれ、CはUNIXのために作られた。\n"
                       "この共進化が、両者の一貫性の源泉である。\n";

    /* ファイルに書き込む */
    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) { perror("open for write"); return 1; }

    printf("ファイル '%s' をfd=%dで開いた（書き込み用）\n", path, fd);
    write(fd, data, strlen(data));
    close(fd);

    /* ファイルから読み込む */
    fd = open(path, O_RDONLY);
    if (fd < 0) { perror("open for read"); return 1; }

    printf("ファイル '%s' をfd=%dで開いた（読み取り用）\n\n", path, fd);

    char buf[256];
    ssize_t n;
    while ((n = read(fd, buf, sizeof(buf) - 1)) > 0) {
        buf[n] = '\0';
        printf("read()が%zd バイト返した:\n%s", n, buf);
    }
    close(fd);

    /* 同じread()でパイプからも読める */
    printf("\n--- 同じread()でパイプからも読める ---\n");
    int pipefd[2];
    pipe(pipefd);

    const char *msg = "パイプもファイルも、read()は同じ\n";
    write(pipefd[1], msg, strlen(msg));
    close(pipefd[1]);

    n = read(pipefd[0], buf, sizeof(buf) - 1);
    buf[n] = '\0';
    printf("パイプからread(): %s", buf);
    close(pipefd[0]);

    printf("\n→ open/read/write/close の4つで、ファイルもパイプも扱える\n");
    printf("→ これがUNIXの「統一インタフェース」の設計原則\n");

    unlink(path);
    return 0;
}
```

コンパイルと実行:

```bash
cat << 'EOF' > /tmp/file_ops.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

int main(void) {
    const char *path = "/tmp/unix_test.txt";
    const char *data = "UNIXはCで書かれ、CはUNIXのために作られた。\n"
                       "この共進化が、両者の一貫性の源泉である。\n";
    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) { perror("open for write"); return 1; }
    printf("ファイル '%s' をfd=%dで開いた（書き込み用）\n", path, fd);
    write(fd, data, strlen(data));
    close(fd);
    fd = open(path, O_RDONLY);
    if (fd < 0) { perror("open for read"); return 1; }
    printf("ファイル '%s' をfd=%dで開いた（読み取り用）\n\n", path, fd);
    char buf[256];
    ssize_t n;
    while ((n = read(fd, buf, sizeof(buf) - 1)) > 0) {
        buf[n] = '\0';
        printf("read()が%zd バイト返した:\n%s", n, buf);
    }
    close(fd);
    printf("\n--- 同じread()でパイプからも読める ---\n");
    int pipefd[2];
    pipe(pipefd);
    const char *msg = "パイプもファイルも、read()は同じ\n";
    write(pipefd[1], msg, strlen(msg));
    close(pipefd[1]);
    n = read(pipefd[0], buf, sizeof(buf) - 1);
    buf[n] = '\0';
    printf("パイプからread(): %s", buf);
    close(pipefd[0]);
    printf("\n→ open/read/write/close の4つで、ファイルもパイプも扱える\n");
    printf("→ これがUNIXの「統一インタフェース」の設計原則\n");
    unlink(path);
    return 0;
}
EOF
gcc -o /tmp/file_ops /tmp/file_ops.c && /tmp/file_ops
```

このハンズオンの要点は明確だ。UNIXのシステムコールは、C言語の関数として自然に呼び出せる。そしてファイルもパイプも、同じread()/write()で操作できる。この「統一インタフェース」の設計は、CとUNIXが共進化した結果であり、ThompsonとRitchieの設計思想の具現化だ。

---

## 8. まとめと次回予告

### この回の要点

- Dennis Ritchieは2011年10月12日に亡くなった。Steve Jobsの死の1週間後だった。世間はJobsを悼んだが、Ritchieの死はほとんど報じられなかった。だがRitchieがいなければ、Jobsの製品の基盤は存在しなかった。この格差は、インフラストラクチャを作る人間の仕事の「見えなさ」を象徴している

- Ken Thompson（1943年生まれ）は、正規表現の最初の実用的実装（1968年）、UNIXの原型（1969年）、Belleチェスコンピュータ（1980年世界チャンピオン）、Plan 9、Go言語（2009年公開）を生み出した。彼は常に「システムの原型」を作る人間であり、動く実装で語るエンジニアだった

- Dennis Ritchie（1941年〜2011年）は、B言語をC言語に発展させ（1971年〜1973年）、1973年にUNIXカーネルをCで書き直した。「OSを高級言語で書く」という判断は革命的だった。これによりUNIXは移植性を獲得し、あらゆるCPUアーキテクチャへの展開が可能になった

- UNIXとCは共進化した。UNIXのシステムコール——fork()、exec()、pipe()、open()、read()、write()——はCの関数として自然に表現され、Cの設計思想——プログラマへの信頼、ハードウェアに近い抽象、小さな言語仕様——はUNIXの哲学と相似形を成す

- ThompsonとRitchieの周囲にも重要な人物がいた。Doug McIlroyはパイプを発明しUNIX哲学を言語化した。Brian Kernighanは書籍を通じてその思想を世界に伝えた。Joe Ossannaはtroffの開発でUNIXの組織内生存を支えた

### 冒頭の問いへの暫定回答

「UNIXの設計哲学は、どのような人間によって生み出されたのか？」

暫定的な答えはこうだ。UNIXは、二つの異なる才能の組み合わせから生まれた。Ken Thompsonは「システムの原型を素早く形にする」天才であり、Dennis Ritchieは「原型を汎用的な道具に昇華させる」天才だった。Thompsonがアセンブリで書いたUNIXを、RitchieがC言語で書き直すことで移植可能にした。ThompsonのB言語を、RitchieがC言語に発展させることで汎用プログラミング言語にした。「動くものを作る人」と「動くものを広げる人」——この組み合わせが、UNIXとCを半世紀以上生き延びる技術に鍛え上げた。

そして、コードを書いた二人の周囲に、パイプを発明した上司（McIlroy）と、思想を書籍にした語り部（Kernighan）がいた。偉大な技術は、天才の孤独な仕事ではなく、才能の組み合わせから生まれる。Bell Labsという環境が、この組み合わせを可能にした。

### 次回予告

次回は「"Do one thing and do it well"——単一責務の起源」。UNIXの設計哲学の中で最も有名な原則——「一つのことをうまくやれ」——を深く掘り下げる。Doug McIlroyの言葉、Peter Salusの三原則、Eric Raymondの17のルール。そしてUNIXのコマンド群——cat、grep、sort、uniq、wc、cut——の設計分析。なぜ各コマンドの責務の境界は、そこに引かれているのか。「単一責務原則」は本当にソフトウェア設計の普遍的原則なのか。

あなたが書いている関数は、「一つのこと」をうまくやっているだろうか。その「一つのこと」の境界を、あなたはどうやって決めているだろうか。

---

## 参考文献

- Dennis Ritchie, "The Development of the C Language", Proceedings of the ACM History of Programming Languages conference (HOPL-II), 1993: <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/chist.html>
- Dennis Ritchie, Ken Thompson, "The UNIX Time-Sharing System", Communications of the ACM, Vol. 17, No. 7, July 1974
- Ken Thompson, "Regular Expression Search Algorithm", Communications of the ACM, Vol. 11, No. 6, June 1968: <https://dl.acm.org/doi/10.1145/363347.363387>
- Ken Thompson, "Reflections on Trusting Trust", Communications of the ACM, Vol. 27, No. 8, August 1984: <https://www.cs.cmu.edu/~rdriley/487/papers/Thompson_1984_ReflectionsonTrustingTrust.pdf>
- Brian W. Kernighan, Dennis M. Ritchie, "The C Programming Language", Prentice Hall, 1978
- Brian W. Kernighan, Rob Pike, "The UNIX Programming Environment", Prentice Hall, 1984
- Brian W. Kernighan, "UNIX: A History and a Memoir", Kindle Direct Publishing, 2019
- ACM Turing Award — Ken Thompson: <https://amturing.acm.org/award_winners/thompson_4588371.cfm>
- ACM Turing Award — Dennis Ritchie: <https://amturing.acm.org/award_winners/ritchie_1506389.cfm>
- Ken Thompson — Wikipedia: <https://en.wikipedia.org/wiki/Ken_Thompson>
- Dennis Ritchie — Wikipedia: <https://en.wikipedia.org/wiki/Dennis_Ritchie>
- Douglas McIlroy — Wikipedia: <https://en.wikipedia.org/wiki/Douglas_McIlroy>
- Belle (chess machine) — Wikipedia: <https://en.wikipedia.org/wiki/Belle_(chess_machine)>
- Go (programming language) — Wikipedia: <https://en.wikipedia.org/wiki/Go_(programming_language)>
- Joe Ossanna — Wikipedia: <https://en.wikipedia.org/wiki/Joe_Ossanna>
- CNN, "Dennis Ritchie: The shoulders Steve Jobs stood on", October 2011: <https://www.cnn.com/2011/10/14/tech/innovation/dennis-ritchie-obit-bell-labs/index.html>
