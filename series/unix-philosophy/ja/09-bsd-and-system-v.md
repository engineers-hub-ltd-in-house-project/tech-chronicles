# UNIXという思想

## ——パイプ、プロセス、ファイル――すべてはここから始まった

### 第9回：「BSDとSystem V——分裂の始まり」

**連載「UNIXという思想——パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- UNIXがなぜ一つにまとまれなかったのか——AT&Tのライセンス体制とバークレーの学術文化が生んだ必然的分裂
- BSD（Berkeley Software Distribution）の誕生と進化——Bill Joyの1BSDからDARPA資金による4.2BSDまでの系譜
- AT&T System IIIとSystem Vの商用化路線——研究プロジェクトから商用製品への転換
- BSDとSystem Vの技術的差異——シグナル処理、ネットワーキングAPI、ファイルシステム、端末制御、プロセス間通信の設計思想の違い
- UNIX Wars——OSFとUnix Internationalの対立と、SVR4による統合の試み
- `ps aux` と `ps -ef` の違いに象徴される分裂の痕跡が、現代のLinuxにどう残っているか

---

## 1. `ps aux` と `ps -ef` のあいだ

2000年代前半、私は複数のUNIX系OSを横断する案件に携わっていた。Solaris、AIX、HP-UX、そしてLinux。それぞれのサーバにログインし、同じ運用作業を行う。だが「同じ」はずの作業が、OSごとに微妙に異なった。

最も象徴的だったのは `ps` コマンドだ。

あるサーバでは `ps aux` と打つ。別のサーバでは `ps -ef` と打つ。どちらも「実行中のプロセスを一覧表示する」という同じ目的のコマンドだ。だが構文が異なる。`ps aux` にはハイフンがない。`ps -ef` にはハイフンがある。出力のカラムも微妙に違う。BSDスタイルの `ps aux` は %CPU、%MEM、STAT カラムを表示する。System Vスタイルの `ps -ef` は PPID（親プロセスID）とSTIME（開始時刻）を表示する。

```bash
# BSD構文
ps aux
# USER  PID  %CPU  %MEM  VSZ  RSS  TTY  STAT  START  TIME  COMMAND

# System V構文
ps -ef
# UID  PID  PPID  C  STIME  TTY  TIME  CMD
```

最初は単なる方言の違いだと思っていた。地方ごとに呼び名が変わる食べ物のようなものだ、と。だが調べていくうちに、この違いの背後に、UNIXの歴史における最大の分裂——BSDとSystem Vの対立——が横たわっていることを知った。

ハイフンの有無は些細な表面の違いにすぎない。その下には、シグナルの処理方法、ネットワーキングAPIの設計、ファイルシステムの構造、端末制御のインタフェース——あらゆる層にわたる設計思想の対立がある。そしてその対立は、1970年代のAT&T Bell Labsと、カリフォルニア大学バークレー校という二つの文化の衝突から始まった。

あなたが日常的に使っているLinuxは、この二つの系統の技術を「両方」取り込んでいる。Berkeley socketsでネットワークプログラミングを行い、System V IPCの共有メモリやセマフォを使い、POSIXで標準化されたシグナル処理を呼ぶ。現代のLinuxは、BSDとSystem Vの分裂を「知らなくても使える」ように設計されている。だが知らないままでいると、なぜLinuxがこのように設計されているのか——なぜBerkeley socketsとSystem V IPCが共存しているのか——という問いに答えられない。

UNIXはなぜ一つにまとまれなかったのか。その分裂は悪だったのか。

---

## 2. 二つの系譜——バークレーとAT&T

### AT&Tのライセンスとバークレーのハッカー文化

UNIXの分裂を理解するには、まずAT&TとUNIXの関係を理解する必要がある。

UNIXは1969年にAT&T Bell Labsで生まれた。だがAT&Tは1956年の同意判決（Consent Decree）により、電話事業以外での商業活動を制限されていた。この制約がUNIXの運命を決定づけた。AT&TはUNIXを商用製品として販売できない。代わりに、大学や研究機関にソースコード付きのライセンスを安価に提供した。

このライセンス体制が、UNIXを学術界に広めた。大学の研究者たちはソースコードを読み、改変し、拡張した。AT&TのUNIXは、大学という温床で自由に変異し、進化した。

その最も重要な変異が、カリフォルニア大学バークレー校で起きた。

1974年、バークレーのBob FabryがAT&TからVersion 4 UNIXのライセンスを取得した。翌1975年にはKen ThompsonがバークレーでサバティカルIを過ごし、Version 6 UNIXを持ち込んだ。Thompsonの訪問は、バークレーのUNIXコミュニティに火をつけた。

その火を最も激しく燃え上がらせたのが、大学院生のBill Joyだった。

### Bill JoyとBSDの誕生

1977年、JoyはUNIXの改良ソフトウェアを集め始めた。Pascalコンパイラ、ex行エディタ——バークレーの研究者たちが書いた拡張を一つのパッケージにまとめる作業だ。翌1978年3月9日、最初のBerkeley Software Distribution（1BSD）がリリースされた。V6 UNIXへのアドオンとして、約30本のテープが無料で配布された。

1BSDは控えめな始まりだった。だがその後のBSDの進化は急速だった。

1979年5月、2BSDがリリースされた。ここにはJoyが開発した二つのプログラムが含まれていた。exのビジュアル版であるvi（現在も使われ続けているテキストエディタ）と、C shell（csh）だ。C shellはC言語風の構文を持つ対話型シェルで、ヒストリ機能とジョブ制御を導入した。

同年末の3BSDは、BSDにとって質的転換点だった。VAXアーキテクチャ向けの仮想メモリ実装を含む完全なオペレーティングシステムとしてリリースされた。もはやV6 UNIXの「アドオン」ではない。独立したUNIX系OSとしてのBSDがここに生まれた。

3BSDの成功は、国防高等研究計画局（DARPA）の目に留まった。1979年秋、バークレーのBob FabryはDARPAに提案書を提出し、ARPAnet向けの拡張UNIXの開発を申し出た。1980年4月、DARPAとの契約が成立し、FabryはCSRG（Computer Systems Research Group）を設立した。DARPAの資金を背景に、BSDの開発は本格的な研究プロジェクトとなった。

1980年11月には4BSDがリリースされ、ジョブ制御、delivermail（sendmailの祖先）、reliable signals（信頼性のあるシグナル）、Cursesライブラリが導入された。

そして1983年8月、4.2BSDがリリースされた。このリリースがインターネットの歴史を変えることになる。

### 4.2BSD——インターネットの基盤を築いたOS

4.2BSDの最大の革新は、TCP/IPネットワーキングプロトコルスイートのカーネルへの直接実装だった。

TCP/IPの実装自体はBBN（Bolt, Beranek and Newman）が先行していたが、BSDチームはBBNのコードを大幅に改良した。Bill JoyとSam Lefflerが高速ネットワーク向けに最適化を施し、ユーザからのバグフィックスやパフォーマンス改善を取り込んだ。DARPAは数ヶ月のテストの結果、BBN版よりもBSD版のTCP/IP実装が優れていると判定した。

4.2BSDはさらに、Berkeley socketsという革新的なネットワークプログラミングAPIを導入した。`socket()`、`bind()`、`listen()`、`accept()`、`connect()`——この一連のシステムコールは、ネットワークプログラミングの事実上の標準APIとなり、現代のすべての主要OSに受け継がれている。あなたが今日書くネットワークプログラムが使うAPIは、1983年のバークレーで設計されたものだ。

もう一つの重要な技術革新が、Marshall Kirk McKusickが設計したFFS（Fast File System）だ。V7 UNIXのファイルシステムはディスク上のデータ配置が非効率で、パフォーマンスに問題があった。McKusickはシリンダグループの概念を導入してディスクを小チャンクに分割し、データの局所性を改善した。さらに二つのブロックサイズを導入して、大きなファイルへの高速アクセスと小さなファイルのスペース効率を両立させた。結果として、従来のファイルシステムの最大10倍のアクセス速度を実現した。この成果は1984年8月のACM Transactions on Computer Systems誌に掲載された。

4.2BSDは、バークレーのCSRGが生み出した最も影響力のあるリリースだった。TCP/IP、Berkeley sockets、FFS——これらの技術は、後のインターネットとサーバOSの基盤となった。2006年、InformationWeek誌は4.3BSD（4.2BSDの後継、1986年6月リリース）を「史上最高のソフトウェア」と評し、「インターネットの最大の理論的支柱」とコメントした。

1982年、JoyはバークレーからSun Microsystemsの共同創業者として転身した。BSDの成果を商用UNIXの世界に持ち込んだのだ。Joyの離脱後、Mike KarelsとMarshall Kirk McKusickがCSRGのリーダーシップを引き継ぎ、BSDの開発を続けた。

### AT&Tの商用化路線——System IIIとSystem V

バークレーがBSDを発展させている間、AT&Tは別の道を歩んでいた。

1982年のAT&T分割（Modified Final Judgment）により、AT&Tは電話事業以外の商業活動の制約から解放された。UNIXを商用製品として販売できるようになったのだ。

AT&Tは1982年にSystem IIIをBell Labs外部へリリースした。System IIIは、V7 UNIX、PWB/UNIX 2.0、CB UNIX 3.0など、Bell Labs内部で並行して発展していた複数のUNIXバリアントを統合したものだった。

翌1983年1月、System V（内部名Unix 5.0）がリリースされた。これがAT&Tの商用UNIX路線の本格的な開始だ。System Vは「AT&Tの公式UNIX」として位置づけられ、商用ライセンスのもとで販売された。

1984年にSystem V Release 2（SVR2）がリリースされ、ファイルロックやシェルのジョブ制御などが追加された。1987年にはSVR3がリリースされ、STREAMS、Remote File Sharing（RFS）、Transport Layer Interface（TLI）が導入された。

ここに、UNIXの二大系統が確立した。学術・研究コミュニティから生まれたBSDと、AT&Tの商用路線から生まれたSystem V。二つの系統は同じUNIXの根から生まれながら、異なる方向に成長していった。

---

## 3. 設計思想の分岐——五つの戦線

BSDとSystem Vの技術的差異は、単なる「実装の違い」ではない。どちらの系統も「正しいUNIX」を目指していたが、「正しさ」の定義が異なっていた。その差異を、五つの技術領域で見ていく。

### 戦線1：シグナル処理——信頼性の設計

シグナルは、UNIXにおけるプロセス間の非同期通知メカニズムだ。プロセスの終了（SIGTERM）、不正メモリアクセス（SIGSEGV）、端末からの割り込み（SIGINT）——これらのイベントをプロセスに通知する。

V7 UNIX（そしてSystem V）のシグナルは「unreliable（信頼性のない）」ものだった。シグナルハンドラが呼び出されると、そのシグナルの処理方式が自動的にデフォルト（通常はプロセス終了）にリセットされた。ハンドラの先頭で `signal()` を再設定する必要があったが、シグナル到着とハンドラ再設定の間に同じシグナルが再度到着すると、プロセスは死んだ。

```
System V (unreliable signals) の問題:

  1. SIGINTが到着
  2. ハンドラが呼ばれる（この時点で処理がデフォルトにリセット）
  3. ハンドラ内で signal(SIGINT, handler) を再設定
     ↑
     この2と3の間にSIGINTが再度到着すると...
     → デフォルト動作（プロセス終了）が実行される
     → シグナルを「取りこぼす」

BSD (reliable signals) の解決:

  1. SIGINTが到着
  2. ハンドラが呼ばれる（処理はリセットされない）
  3. ハンドラ実行中、同じシグナルはブロックされる
  4. ハンドラが中断したシステムコールは自動的に再開される
  → シグナルの取りこぼしが発生しない
```

4.0BSD（1980年）はreliable signals（信頼性のあるシグナル）を導入した。BSDのシグナルでは、ハンドラが呼ばれてもデフォルトにリセットされない。ハンドラ実行中は同じシグナルの配送がブロックされる。さらに、シグナルにより中断されたシステムコールが自動的に再開される。

プロセッサの高速化とジョブ制御の普及が、この問題を顕在化させた。高速なプロセッサでは二つのシグナルが極めて短い間隔で到着し得る。ジョブ制御（`Ctrl-Z` でプロセスを一時停止し、`fg` で再開する操作）はシグナルを頻繁に使用する。unreliable signalsの環境では、ジョブ制御中のプロセスが予期せず死ぬ可能性があった。

この差異は、最終的にPOSIXの `sigaction()` として標準化された。`sigaction()` はBSDのreliable signalsの設計思想を取り込み、シグナルの処理方式、ブロックマスク、フラグを明示的に指定できるようにした。

### 戦線2：ネットワーキングAPI——socketsとSTREAMS/TLI

ネットワーキングAPIの設計は、BSDとSystem Vの対立が最も激しかった領域だ。

BSDはBerkeley socketsを導入した。ソケットはファイルディスクリプタの拡張として設計され、`socket()`、`bind()`、`listen()`、`accept()`、`connect()`、`send()`、`recv()` という一連のシステムコールで操作する。UNIXの「すべてはファイルである」という原則との親和性が高く、`read()` / `write()` でもデータの送受信が可能だ。

```
BSD Berkeley sockets:

  socket()  ─→  bind()  ─→  listen()  ─→  accept()  ─→  read()/write()
                                              │
                                       新しいfd を返す
                                       （ファイルディスクリプタ）

  特徴:
  - TCP/IPに最適化された設計
  - ファイルディスクリプタとして扱える
  - シンプルなAPI
  - 1983年の4.2BSDで導入
```

System VはSTREAMSフレームワークとTLI（Transport Layer Interface）を導入した。STREAMSはDennis Ritchieが設計した汎用的なI/Oフレームワークで、プロトコルスタックをモジュールとして積み重ねる構造を持つ。TLIはSTREAMS上に構築されたネットワークAPIだ。

```
System V STREAMS + TLI:

  アプリケーション
       │
       ▼
  ┌──────────┐
  │   TLI    │  ← Transport Layer Interface
  ├──────────┤
  │ Module C │  ← プロトコルモジュール（積み重ね可能）
  ├──────────┤
  │ Module B │
  ├──────────┤
  │ Module A │
  ├──────────┤
  │  Driver  │  ← デバイスドライバ
  └──────────┘

  特徴:
  - プロトコル非依存の設計（OSI前提）
  - モジュールの動的な積み重ね
  - 深いプロトコルスタックに対応
  - 1987年のSVR3で導入
```

TLIはOSIモデルに基づいて設計されており、特定のプロトコルに依存しない汎用性を持っていた。1980年代後半、TCP/IPが勝利するかOSIプロトコルが勝利するかはまだ不透明だった。TLIの設計はOSIプロトコルの台頭を見越したものだった。

だが歴史はTCP/IPを選んだ。そしてTCP/IPとの親和性は、明らかにBerkeley socketsのほうが高かった。socketsはシンプルで、TCP/IPに最適化されており、パフォーマンスも優れていた。STREAMSは汎用性と引き換えに複雑さとオーバーヘッドを抱えていた。

1990年代初頭には、Berkeley socketsが事実上の標準となることは明白だった。UNIX 03 Single UNIX Specificationは、STREAMSをオプションとし、POSIX socketsを推奨APIとして定めた。

この対立は、ソフトウェア設計における普遍的な問いを含んでいる。「汎用的に設計すべきか、特定の用途に最適化すべきか」。STREAMSは汎用性を追求した。socketsは実用性を追求した。結果として、実用性が勝った。だが「汎用性を追求した設計が常に負ける」わけではない。この問いは、形を変えて何度も繰り返される。

### 戦線3：ファイルシステム——FFSとs5fs

ファイルシステムの設計も、両系統の思想の違いを反映していた。

System Vのファイルシステム（s5fs、System V File System）は、V7 UNIXのファイルシステムをほぼそのまま引き継いだシンプルな設計だった。ブロックサイズは512バイトまたは1024バイト固定。inodeとデータブロックの配置に局所性の考慮がなく、大きなファイルシステムではヘッドの移動が頻発してパフォーマンスが劣化した。

BSDのFFS（Fast File System）は、McKusickが1983年に設計した根本的な改良だった。

```
s5fs (System V) の問題:

  ┌──────────────────────────────────────────┐
  │ ブート │ スーパー │  inode   │  データブロック  │
  │ ブロック│ ブロック │  領域    │  （連続配置）   │
  └──────────────────────────────────────────┘

  問題: inodeとデータブロックが物理的に離れている
  → ファイルのメタデータ読み取りとデータ読み取りで
    ディスクヘッドが大きく移動する

FFS (BSD) の解決:

  ┌─────────────────┐┌─────────────────┐┌───────────...
  │ シリンダグループ0 ││ シリンダグループ1 ││ シリンダグループ2
  │                 ││                 ││
  │ スーパーブロック  ││ スーパーブロック  ││
  │ inode           ││ inode           ││
  │ データブロック    ││ データブロック    ││
  └─────────────────┘└─────────────────┘└───────────...

  解決: 同じシリンダグループ内にinodeとデータを配置
  → ディスクヘッドの移動を最小化
  → 最大10倍の性能改善
```

FFSはさらに、4KBと1KB（後に8KBと1KB）の二つのブロックサイズを導入し、大きなファイルの連続読み出しと小さなファイルのスペース効率を両立させた。この「大ブロック + フラグメント」の設計は、現代のファイルシステムにも影響を与えている。

### 戦線4：端末制御——termioとtermios

端末（ターミナル）の制御インタフェースも、両系統で異なっていた。

System V（System IIIから）は `termio` インタフェースを導入した。`termio` 構造体と `ioctl()` システムコールで端末パラメータを取得・設定する。

BSDは `termios` インタフェースを発展させた。ジョブ制御のサポート、中断文字（suspend character）や遅延中断文字の追加など、対話的な端末操作に不可欠な機能を備えていた。

1980年代半ばまで、ほとんどのユーザはシンプルなキャラクタ端末しか持っていなかった。ウィンドウシステムはまだ一般的ではなく、一度に一つのタスクしか実行できない。BSDのジョブ制御——`Ctrl-Z` でプロセスを一時停止し、`fg` で前景に戻し、`bg` でバックグラウンド実行に移す——は、この制約の中で複数タスクの切り替えを可能にした。System Vがジョブ制御をサポートしたのはSVR4（1989年）になってからだった。

最終的に、POSIX.1-1990がBSDの `termios` を基にした標準端末インタフェースを定義した。System Vの `termio` は事実上廃止され、`termios` が標準となった。

### 戦線5：プロセス間通信——socketsとIPC

プロセス間通信（IPC）の設計も、両系統の思想の違いを鮮明に示している。

BSDはネットワーク通信とローカルIPC を統一的に扱うために、socketsを採用した。UNIXドメインソケットを使えば、同一マシン上のプロセス間通信もsocketsの同じAPIで行える。「すべてはファイルである」の延長線上で、通信もファイルディスクリプタとして抽象化された。

System Vは、ネットワーク通信とローカルIPCを別の仕組みとして設計した。ネットワーク通信にはSTREAMS/TLI、ローカルIPCにはSystem V IPCと呼ばれる三つのメカニズム——メッセージキュー（`msgget()`、`msgsnd()`、`msgrcv()`）、共有メモリ（`shmget()`、`shmat()`、`shmdt()`）、セマフォ（`semget()`、`semop()`）——を提供した。

```
BSD のIPC設計:

  ネットワーク通信:  socket(AF_INET, ...)    ─┐
  ローカルIPC:      socket(AF_UNIX, ...)    ─┤── 同じAPI
  ファイルI/O:      open() / read() / write() ─┘   （ファイルディスクリプタ）

  → 統一的なインタフェース

System V のIPC設計:

  ネットワーク通信:  STREAMS / TLI          ← 独自のAPI
  メッセージキュー:  msgget() / msgsnd()    ← 独自のAPI
  共有メモリ:       shmget() / shmat()     ← 独自のAPI
  セマフォ:         semget() / semop()     ← 独自のAPI
  ファイルI/O:      open() / read() / write() ← ファイルディスクリプタ

  → 用途ごとに異なるAPI
```

System V IPCは、各メカニズムが特定の用途に最適化されていた。共有メモリは高速なデータ共有に適し、セマフォは同期処理に特化し、メッセージキューは型付きメッセージの交換を可能にした。だがそれぞれが独自のAPIを持ち、ファイルディスクリプタとして扱えないため、`select()` や `poll()` によるイベント多重化ができないという制約があった。

現代のLinuxは、両方のIPCメカニズムをサポートしている。Berkeley socketsもSystem V IPCも使える。さらにPOSIXが定義したPOSIX IPC（`mq_open()`、`sem_open()`、`shm_open()`）も使える。これらが共存しているのは、どちらか一方を捨てることができなかったからだ。それぞれに適した用途がある。

### 文化の違い——longhairs vs shorthairs

五つの技術的差異の根底には、文化の違いがあった。

当時の関係者が述べたところによれば、BSDとSystem Vの対立は「longhairs（長髪族）対 shorthairs（短髪族）」と形容された。プログラマや技術者はバークレーとBSDに傾倒し、ビジネス指向の人々はAT&TとSystem Vを支持した。

この構図は単純化しすぎだが、ある種の真実を含んでいる。BSDは学術・研究コミュニティで発展した。新しい技術を実験し、最先端のアイデアを実装することに価値を置いた。TCP/IP、仮想メモリ、FFS、Berkeley sockets——これらはすべて、研究者たちが「より良いUNIX」を追求した結果だ。

System Vは商用市場で発展した。互換性、安定性、サポート体制に価値を置いた。企業の基幹システムで動くOSには、最先端の技術より、信頼性と予測可能性が求められた。

どちらが「正しい」UNIXだったのか。その問いに答えはない。だが両者の競争が、UNIXの技術を鍛えたことは間違いない。

---

## 4. UNIX Wars——標準化を巡る政治

### AT&TとSunの接近

1987年、AT&TとSun Microsystemsは、UNIXの統一に向けた共同作業を開始した。

SunのSunOSはBSD系だったが、当時のAT&Tの最新版であるSVR3にはTCP/IPネットワーキングが組み込まれておらず、System Vにはワークステーション市場で競争力がなかった。一方、BSDの「4.2 > V」（4.2BSDはSystem Vより優れている）というポスターが出回るほど、エンジニアリングワークステーション市場ではBSDが優勢だった。

AT&TとSunの連合は、SVR3と4.3BSD、Xenix、SunOSの技術を統合した新しいUNIX——System V Release 4（SVR4）——の開発を目指した。

### OSFの結成——「Gang of Seven」

AT&TとSunの接近は、他のUNIXベンダーに危機感を抱かせた。

1988年1月、DECのArmando Stettnerがパロアルトで招待制の会議を開催した。そして1988年5月、DEC、HP、IBM、Apollo Computer、Groupe Bull、Nixdorf Computer、Siemensの7社が「Gang of Seven」として、Open Software Foundation（OSF）を設立した。

OSFの目的は、AT&T/Sunの連合に対抗するオープンなUNIX標準を策定することだった。SunのScott McNealyは、OSFを「Oppose Sun Forever（永遠にSunに反対する組織）」と揶揄した。

これに対し、AT&Tは同年中にUnix International（UI）を設立して対抗した。UIのソフトウェア開発はUnix System Laboratories（USL）が担った。

```
1988年のUNIX業界の陣営図:

  ┌───────────────────────────┐    ┌───────────────────────────┐
  │  Open Software Foundation │    │    Unix International     │
  │        (OSF)              │    │         (UI)              │
  │                           │    │                           │
  │  DEC, HP, IBM             │ vs │  AT&T, Sun Microsystems   │
  │  Apollo, Bull, Nixdorf    │    │  Unix System Laboratories │
  │  Siemens                  │    │                           │
  │                           │    │                           │
  │  → OSF/1 (Mach ベース)   │    │  → SVR4 (統合UNIX)       │
  └───────────────────────────┘    └───────────────────────────┘

                    ↕ 対立

        この対立が「UNIX Wars」と呼ばれた
```

UNIX Warsは、技術的な対立というよりも商業的・政治的な対立だった。OSFは独自のOS「OSF/1」（Machマイクロカーネルベース）を開発したが、商業的に成功しなかった。一方、SVR4は1988年10月18日に発表され、1989年初頭から商用製品に採用された。

### SVR4——統合と妥協

SVR4は、BSDとSystem Vの技術的対立を「統合」で解消しようとした試みだった。

SVR4は、SVR3、4.3BSD、Xenix、SunOSの技術を統合し、以下のBSD機能を取り込んだ。

- Berkeley sockets（ネットワーキングAPI）
- TCP/IPネットワーキングスタック
- FFS互換のファイルシステム
- C shellとジョブ制御
- reliable signals（`sigaction()` ベース）
- BSDスタイルの端末制御（`termios`）

主要プラットフォームはIntel x86とSPARC。SPARCバージョンはSolaris 2（SunOS 5.x）としてSunが開発した。多くのUNIXベンダー——Hewlett-Packard（HP-UX）、SGI（IRIX）、NEC、富士通——がSVR4を自社OSのベースとして採用した。

SVR4は技術的な意味では「BSDの勝利」だった。BSDの主要技術がSystem Vに取り込まれたのだから。だが商業的な意味ではSystem Vのブランドが生き残った。「System V互換」が商用UNIXの要件として残り続けた。

UNIX Warsの本当の敗者は、UNIXそのものだったかもしれない。業界の分裂と内部抗争は、UNIXの市場浸透を遅らせた。その間隙を突いて、1991年にフィンランドの大学生がLinuxカーネルを書き始めることになるのだが、それは第13回で語る。

---

## 5. 分裂の遺産——現代のLinuxに残る痕跡

BSDとSystem Vの分裂は過去の歴史だが、その痕跡は現代のLinuxに深く刻み込まれている。

### psコマンドの二重構文

冒頭で触れた `ps` コマンドの二重構文は、最も身近な痕跡だ。Linuxのps（procps）は、BSD構文とSystem V構文の両方を受け付ける。

```bash
# BSD構文（ハイフンなし）
ps aux

# System V構文（ハイフンあり）
ps -ef

# GNU拡張構文（ダブルハイフン）
ps --forest
```

ps(1)のマニュアルには、この三つの構文が共存している理由が説明されている。歴史的互換性のためだ。BSDに慣れた管理者もSystem Vに慣れた管理者も、自分の手癖で `ps` を使える。この互換性は便利だが、同時に歴史の重荷でもある。

### ネットワークプログラミング

LinuxはBerkeley socketsを標準のネットワーキングAPIとして採用した。System VのSTREAMS/TLIはLinuxには実装されていない。この選択は、1990年代初頭にLinuxが設計された時点で、socketsの勝利が確定していたことを反映している。

### IPCメカニズムの共存

LinuxはBerkeley socketsとSystem V IPC（共有メモリ、セマフォ、メッセージキュー）の両方をサポートしている。さらにPOSIX IPCも加わり、三世代のIPCメカニズムが共存している。

```bash
# System V IPC の確認
ipcs          # System V IPCリソースの一覧表示

# POSIX IPC の確認
ls /dev/shm/  # POSIX共有メモリオブジェクト

# Berkeley sockets
ls /var/run/*.sock  # UNIXドメインソケット
```

### シグナル処理

Linuxの `signal()` 関数の挙動は、glibcのバージョンと設定により、BSDスタイルかSystem Vスタイルか変わり得る。このため、移植可能なコードではPOSIXの `sigaction()` を使うことが強く推奨される。`sigaction()` は、BSDのreliable signalsの設計思想を標準化したものだ。

### initシステム

System VのinitシステムはSysV init（ランレベルベースの逐次起動）として広く知られ、長年にわたりLinuxディストリビューションで使われた。`/etc/init.d/` にシェルスクリプトを配置し、`/etc/rc.d/` のシンボリックリンクで起動順序を制御する。この仕組みはSystem Vの設計を直接受け継いでいる。

BSDのinitシステムは異なるアプローチを取り、`/etc/rc` スクリプトを中心とした単純な構造を維持した。FreeBSDのrc.d/は、この伝統を現代化したものだ。

2010年代のsystemdの台頭は、SysV init（System Vの遺産）からの脱却だった。この話題は第17回で詳しく扱う。

---

## 6. ハンズオン：BSDとSystem Vの差異を体験する

ここからは手を動かす。FreeBSD（BSD系）とLinux（System V系の影響を強く受けた）の差異を実際に確認し、UNIXの分裂がどのように各OSの設計に影響しているかを体験する。

### 環境構築

Docker上でLinux（Ubuntu）とFreeBSDの違いを確認する。FreeBSDのDockerイメージは公式には提供されていないため、Linux環境内でBSD系コマンドとSystem V系コマンドの違いに焦点を当てる。

```bash
docker run -it --rm ubuntu:24.04 bash
```

コンテナ内で必要なツールを用意する。

```bash
apt-get update && apt-get install -y procps iproute2 net-tools sysvinit-utils
```

### 演習1：psコマンドのBSD構文とSystem V構文

```bash
# BSD構文: ハイフンなし
echo "=== BSD style: ps aux ==="
ps aux | head -5

# System V構文: ハイフンあり
echo ""
echo "=== System V style: ps -ef ==="
ps -ef | head -5

# 出力カラムの違いを比較
echo ""
echo "=== BSD style header ==="
ps aux | head -1

echo ""
echo "=== System V style header ==="
ps -ef | head -1

# BSD構文の特徴: %CPU, %MEM, STAT カラム
# System V構文の特徴: PPID, C, STIME カラム
```

### 演習2：System V IPCを体験する

System V IPCのメッセージキュー、共有メモリ、セマフォを実際に作成・確認する。

```bash
# System V IPCの現在の状態を確認
echo "=== Current System V IPC resources ==="
ipcs

# ipcsコマンドの出力形式:
# ------ Message Queues --------
# key        msqid      owner      perms      used-bytes   messages
#
# ------ Shared Memory Segments --------
# key        shmid      owner      perms      bytes      nattch
#
# ------ Semaphore Arrays --------
# key        semid      owner      perms      nsems

# System V IPC は ipcmk コマンドで作成できる
echo ""
echo "=== Creating System V IPC resources ==="

# 共有メモリセグメントを作成（1024バイト）
ipcmk -M 1024
echo "Shared memory created"

# メッセージキューを作成
ipcmk -Q
echo "Message queue created"

# セマフォを作成（1要素）
ipcmk -S 1
echo "Semaphore created"

# 作成されたリソースを確認
echo ""
echo "=== System V IPC resources after creation ==="
ipcs

# クリーンアップ: 作成したリソースを削除
echo ""
echo "=== Cleaning up ==="
ipcs -q | awk 'NR>3 && $2 ~ /^[0-9]+$/ {print $2}' | while read id; do
    ipcrm -q "$id" 2>/dev/null
done
ipcs -m | awk 'NR>3 && $2 ~ /^[0-9]+$/ {print $2}' | while read id; do
    ipcrm -m "$id" 2>/dev/null
done
ipcs -s | awk 'NR>3 && $2 ~ /^[0-9]+$/ {print $2}' | while read id; do
    ipcrm -s "$id" 2>/dev/null
done
echo "Cleanup complete"
ipcs
```

### 演習3：シグナル処理の違いを体験する

BSDスタイルとSystem Vスタイルのシグナル処理の違いを、シェルスクリプトで疑似的に体験する。

```bash
# trapコマンドはシェルレベルのシグナルハンドラ
# BSDスタイル: ハンドラはリセットされない（現代のbashのデフォルト動作）

echo "=== Signal handling demo ==="

# シグナルハンドラを設定
trap 'echo "SIGUSR1 received (handler still active)"' USR1

# 自分自身のPIDを取得
MY_PID=$$

echo "PID: $MY_PID"
echo "Sending SIGUSR1 three times..."

# シグナルを3回送信——ハンドラが毎回呼ばれることを確認
kill -USR1 $MY_PID
kill -USR1 $MY_PID
kill -USR1 $MY_PID

echo ""
echo "Handler remained active for all three signals."
echo "This is BSD-style 'reliable' signal behavior."
echo ""
echo "In old System V style, the handler would have been"
echo "reset to default after the first invocation,"
echo "and the second signal could have killed the process."

# ハンドラをリセット
trap - USR1
```

### 演習4：ネットワーキングコマンドの系譜

ネットワーク管理コマンドにも、BSDとSystem Vの系譜が残っている。

```bash
echo "=== Network commands: BSD heritage vs modern ==="

# BSDスタイルのネットワークコマンド（net-tools パッケージ）
echo "--- BSD-heritage commands (net-tools) ---"
echo "ifconfig (BSD origin):"
ifconfig lo 2>/dev/null | head -3 || echo "  ifconfig not available or no permission"

echo ""
echo "netstat (BSD origin):"
netstat -an 2>/dev/null | head -5 || echo "  netstat not available"

echo ""
echo "route (BSD origin):"
route -n 2>/dev/null | head -5 || echo "  route not available"

# 現代のLinuxコマンド（iproute2 パッケージ）
echo ""
echo "--- Modern Linux commands (iproute2) ---"
echo "ip addr (replaces ifconfig):"
ip addr show lo | head -5

echo ""
echo "ss (replaces netstat):"
ss -an | head -5

echo ""
echo "ip route (replaces route):"
ip route show | head -5

echo ""
echo "Note: net-tools (ifconfig, netstat, route) are BSD-heritage commands."
echo "iproute2 (ip, ss) is the modern Linux replacement."
echo "Both coexist on most Linux distributions for compatibility."
```

### 演習5：initシステムの痕跡を探す

SysV initの痕跡が現代のLinuxにどう残っているかを確認する。

```bash
echo "=== SysV init heritage in modern Linux ==="

# ランレベルの概念（System Vの遺産）
echo "--- Runlevel concept (System V heritage) ---"
echo "Current runlevel:"
runlevel 2>/dev/null || echo "  runlevel command not available (systemd environment)"

# SysV init スクリプトのディレクトリ
echo ""
echo "--- SysV init directories ---"
ls -d /etc/init.d/ 2>/dev/null && echo "  /etc/init.d/ exists (SysV init heritage)" || echo "  /etc/init.d/ not found"
ls -d /etc/rc*.d/ 2>/dev/null | head -5 || echo "  /etc/rc*.d/ not found"

# systemdのユニットファイル（SysV initの後継）
echo ""
echo "--- systemd units (modern replacement) ---"
ls /etc/systemd/system/ 2>/dev/null | head -5 || echo "  systemd not available in this container"

# /etc/inittab（System V initの設定ファイル）
echo ""
echo "--- /etc/inittab (System V init config) ---"
if [ -f /etc/inittab ]; then
    head -5 /etc/inittab
else
    echo "  /etc/inittab not found (expected in systemd era)"
fi

echo ""
echo "The transition from SysV init to systemd is one of the most"
echo "visible consequences of moving beyond System V heritage."
```

### 演習6：BSD由来とSystem V由来の機能を識別する

Linuxがどの機能をBSDから、どの機能をSystem Vから取り入れているかを確認する。

```bash
echo "=== Identifying BSD and System V heritage in Linux ==="

echo ""
echo "--- From BSD ---"
echo "1. Berkeley sockets (networking API):"
echo "   socket(), bind(), listen(), accept(), connect()"
echo "   Used by virtually all network programs"

echo ""
echo "2. FFS-influenced filesystem layout:"
echo "   Modern ext4 inherits block group concept from FFS cylinder groups"

echo ""
echo "3. BSD-style ps syntax:"
ps aux > /dev/null 2>&1 && echo "   'ps aux' works (BSD syntax supported)"

echo ""
echo "4. TCP/IP networking stack:"
echo "   Descended from BSD's implementation"

echo ""
echo "--- From System V ---"
echo "1. System V IPC:"
ipcs > /dev/null 2>&1 && echo "   'ipcs' works (System V IPC supported)"

echo ""
echo "2. System V-style ps syntax:"
ps -ef > /dev/null 2>&1 && echo "   'ps -ef' works (System V syntax supported)"

echo ""
echo "3. SysV init heritage:"
echo "   /etc/init.d/ directory structure"

echo ""
echo "4. STREAMS (NOT included in Linux):"
echo "   Linux chose Berkeley sockets over STREAMS/TLI"

echo ""
echo "--- From POSIX (standardized merger) ---"
echo "1. sigaction() - reliable signal handling (BSD-originated, POSIX-standardized)"
echo "2. termios - terminal interface (BSD-originated, POSIX-standardized)"
echo "3. pthreads - POSIX threads"

echo ""
echo "Linux is a pragmatic synthesis of both traditions,"
echo "taking the best of BSD and System V while adding its own innovations."
```

---

## 7. まとめと次回予告

### この回の要点

- UNIXの分裂は偶然ではなく、必然だった。AT&Tの1956年同意判決がUNIXのソースコードを学術界に広め、バークレーのCSRGがDARPAの資金を得て独自の発展を遂げた。1978年のBill Joyによる1BSDの配布から、1983年の4.2BSDのTCP/IP実装まで、BSDは学術・研究コミュニティの中で急速に進化した

- BSDとSystem Vの技術的差異は五つの戦線に集約される。シグナル処理（reliable vs unreliable）、ネットワーキングAPI（Berkeley sockets vs STREAMS/TLI）、ファイルシステム（FFS vs s5fs）、端末制御（termios vs termio）、プロセス間通信（sockets vs System V IPC）。これらの差異は単なる実装の違いではなく、設計思想の対立を反映していた

- UNIX Warsは技術的対立であると同時に、商業的・政治的対立だった。1988年のOSF結成とUnix International設立は、UNIXの「標準」を巡る覇権争いだった。1989年のSVR4はBSDの主要技術を取り込み、技術的な統合を試みたが、業界の分裂が修復されることはなかった

- 現代のLinuxは、BSDとSystem Vの両方の遺産を受け継いでいる。Berkeley sockets、System V IPC、POSIXシグナル処理——異なる系統の技術が一つのOSに共存している。`ps aux` と `ps -ef` の二重構文は、この統合の最も日常的な痕跡だ

- 分裂は悪だったのか。一面では、業界の分裂がUNIXの市場浸透を遅らせ、Linuxの台頭を許した。だが別の面では、BSDとSystem Vの競争がUNIXの技術を鍛えた。TCP/IP、Berkeley sockets、FFS、reliable signals——これらはすべて、競争の産物だ。BSDの挑戦がなければ、System Vはこれらの技術を取り込む動機を持たなかっただろう

### 冒頭の問いへの暫定回答

「なぜUNIXは一つにまとまれなかったのか？ その分裂は悪だったのか？」

UNIXが一つにまとまれなかった理由は、明確だ。AT&Tのライセンス体制が学術界にソースコードを広め、バークレーのCSRGがDARPA資金を得て独自に発展したことで、二つの「正統なUNIX」が並立した。技術的な設計思想の違い——研究指向のBSDと商用指向のSystem V——が、統合を困難にした。さらに1988年のOSF/UI対立は、技術的対立を商業的覇権争いに転化させた。

分裂は悪だったのか。単純な答えは出せない。分裂がUNIXの市場支配を遅らせたのは事実だ。統一されたUNIXがあれば、ISVはより容易にアプリケーションを開発でき、企業はより低コストでUNIXを導入できただろう。だが分裂がなければ、BSDのTCP/IP実装もBerkeley socketsも、そもそも生まれなかったかもしれない。AT&Tの商用路線だけがUNIXの唯一の道だったなら、UNIXのネットワーキングはOSIプロトコルに向かっていた可能性がある。インターネットの歴史は、大きく変わっていただろう。

競争は無駄を生む。だが競争なしに技術は磨かれない。この矛盾は、ソフトウェアの歴史において何度も繰り返されるテーマだ。

あなたの現場では、「統一」と「多様性」のどちらが技術を前進させているだろうか。

### 次回予告

次回は「POSIX標準化——"標準UNIX"は実現したか」。BSDとSystem Vの分裂を解消するために、IEEE POSIX（1988年）とSingle UNIX Specification（1994年）が策定された。Richard Stallmanが「POSIX」という名前を命名したこと、macOSがUNIX認証を取得していること、そしてPOSIXが標準化した範囲と「しなかった」範囲——標準化は何を成し遂げ、何を成し遂げられなかったのか。

UNIX Wars の教訓の一つは、技術的な統一は標準化によってしか実現できないということだ。だが標準化には固有の限界がある。次回はその限界を正面から問う。

---

## 参考文献

- "Berkeley Software Distribution", Wikipedia: <https://en.wikipedia.org/wiki/Berkeley_Software_Distribution>
- "History of the Berkeley Software Distribution", Wikipedia: <https://en.wikipedia.org/wiki/History_of_the_Berkeley_Software_Distribution>
- "UNIX System III", Wikipedia: <https://en.wikipedia.org/wiki/UNIX_System_III>
- "UNIX System V", Wikipedia: <https://en.wikipedia.org/wiki/UNIX_System_V>
- "Unix wars", Wikipedia: <https://en.wikipedia.org/wiki/Unix_wars>
- "Open Software Foundation", Wikipedia: <https://en.wikipedia.org/wiki/Open_Software_Foundation>
- "UNIX International", Wikipedia: <https://en.wikipedia.org/wiki/UNIX_International>
- "Berkeley sockets", Wikipedia: <https://en.wikipedia.org/wiki/Berkeley_sockets>
- "Transport Layer Interface", Wikipedia: <https://en.wikipedia.org/wiki/Transport_Layer_Interface>
- "ps (Unix)", Wikipedia: <https://en.wikipedia.org/wiki/Ps_(Unix)>
- Marshall Kirk McKusick, William N. Joy, Samuel J. Leffler, Robert S. Fabry, "A Fast File System for UNIX", ACM Transactions on Computer Systems, Vol. 2, No. 3, August 1984: <https://dsf.berkeley.edu/cs262/FFS.pdf>
- Marshall Kirk McKusick, "Twenty Years of Berkeley Unix: From AT&T-Owned to Freely Redistributable", Open Sources: Voices from the Open Source Revolution, O'Reilly, 1999: <https://www.oreilly.com/openbook/opensources/book/kirkmck.html>
- "History of FreeBSD - Part 4: BSD and TCP/IP", Klara Systems: <https://klarasystems.com/articles/history-of-freebsd-part-4-bsd-and-tcp-ip/>
- "UNIX Wars - The Battle for Standards", Klara Systems: <https://klarasystems.com/articles/unix-wars-the-battle-for-standards/>
- W. Richard Stevens, "Advanced Programming in the UNIX Environment", Addison-Wesley, 1992
- Peter H. Salus, "A Quarter Century of UNIX", Addison-Wesley, 1994
- "Computer Systems Research Group", Wikipedia: <https://en.m.wikipedia.org/wiki/Computer_Systems_Research_Group>
- "XTI/TLI Versus Socket Interfaces", Oracle Solaris Programming Interfaces Guide: <https://docs.oracle.com/cd/E23824_01/html/821-1602/tli-65541.html>
