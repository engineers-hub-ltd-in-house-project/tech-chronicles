# UNIXという思想

## ——パイプ、プロセス、ファイル――すべてはここから始まった

### 第6回：「"Everything is a file"——抽象化の極致」

**連載「UNIXという思想——パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- UNIXが「すべてはファイルである」という設計判断に至った歴史的経緯と技術的動機
- ファイルディスクリプタによる統一的抽象——open/read/write/closeの四つのシステムコールがあらゆるI/Oを支配する仕組み
- UNIXにおけるファイルの7つの種類——通常ファイル、ディレクトリ、シンボリックリンク、名前付きパイプ、ブロックデバイス、キャラクタデバイス、ソケット
- VFS（Virtual File System）層の誕生——Sun MicrosystemsがNFSのために1985年に導入した抽象レイヤー
- /procと/sys——プロセス情報とデバイスモデルをファイルとして公開するLinuxの拡張
- Plan 9が「すべてはファイル」を極限まで徹底した設計と、その現代への影響
- ioctl()に見る「すべてはファイル」の限界と、抽象化の功罪

---

## 1. 「これ全部ファイルなのか」

2003年頃のことだ。私はあるWebサービスのサーバ管理を担当していた。Red Hat Linux 9が動くラックマウントサーバの群れ。障害調査の最中に、私は立て続けに三つのコマンドを打った。

```bash
cat /proc/cpuinfo
cat /proc/meminfo
cat /dev/urandom | od -A x -t x1 -N 16
```

最初の二つは、CPUの情報とメモリの状態を表示する。三つ目は、ランダムなバイト列を16バイトだけ16進数で表示する。どれも`cat`で読んでいる。`cat`は——文字通り「concatenate（連結）」——ファイルを読んで標準出力に書くだけのプログラムだ。

だが、`/proc/cpuinfo`はディスク上に存在するファイルではない。カーネルがプロセスやハードウェアの情報をリアルタイムに生成する仮想ファイルだ。`/dev/urandom`はハードウェアの乱数生成器に接続されたデバイスファイルだ。どちらも「通常のファイル」ではない。だが`cat`はそんなことを知らない。`open()`して`read()`して`write()`する——ファイルと同じ操作で、ハードウェア情報も乱数も取得できる。

そのとき、私は初めてUNIXの「Everything is a file（すべてはファイルである）」という原則の意味を、頭ではなく手で理解した。

テキストファイルを読むのも、CPUの情報を取得するのも、乱数を生成するのも、ネットワーク通信をするのも——UNIXでは同じ操作だ。`open()`でハンドルを取得し、`read()`でデータを読み、`write()`でデータを書き、`close()`でハンドルを閉じる。この四つのシステムコールが、UNIXのあらゆるI/Oの基盤になっている。

この設計判断の意味を、あなたは理解しているだろうか。

「異なるものを同じ方法で扱う」——これが抽象化の本質だ。ディスク上のファイル、メモリ内の仮想ファイル、ハードウェアデバイス、ネットワーク接続、プロセス間通信。それぞれの実装は全く異なる。だが「バイト列を読み書きする対象」として統一することで、プログラムは対象が何であるかを知る必要がなくなった。前回のパイプの話を思い出してほしい。プログラムが「自分の出力がパイプに接続されていることを知らない」のは、この抽象化があるからだ。

「すべてはファイルである」——この原則はUNIXの設計思想の中で最も野心的であり、最も成功し、そして最も誤解されている。

---

## 2. デバイスファイルの誕生——ハードウェアをファイルに変えた日

### 1971年——特殊ファイルの出現

UNIXの「すべてはファイルである」は、最初から完成された原則ではなかった。段階的に発展した設計思想だ。

その原型は、1971年11月3日に発行されたUNIX First EditionのProgrammer's Manualに見ることができる。Ken ThompsonとDennis Ritchieが書いたこのマニュアルには、「special files（特殊ファイル）」の項が設けられていた。

Dennis Ritchieが導入したこの概念は、ハードウェアデバイスをファイルシステム内のファイルとして表現するものだった。テレタイプ端末、磁気テープ、ディスクドライブ——これらの物理的なデバイスに、`/dev/`ディレクトリ配下のファイル名が割り当てられた。プログラムはそのファイルを`open()`して`read()`や`write()`するだけでデバイスにアクセスできる。デバイスドライバの詳細は、カーネルが隠蔽する。

この設計判断が画期的だったのは、それ以前のオペレーティングシステムでは、デバイスへのアクセスに専用のシステムコールや専用のAPIが必要だったことだ。テープを読むAPI、プリンタに書くAPI、端末に表示するAPI——デバイスごとに異なるインタフェースがあり、プログラムはアクセス先のデバイスを「知っている」必要があった。

UNIXはこの常識を覆した。デバイスをファイルに変えることで、ファイルを扱えるプログラムはすべて、デバイスも扱えるようになった。`cat`でディスクの内容を読める。リダイレクション`>`でプリンタに出力できる。デバイスへのアクセスに特別なプログラムは不要だ。

### ブロックデバイスとキャラクタデバイス

UNIXは初期の段階から、デバイスファイルを二つのカテゴリに分けた。

**ブロックデバイス**は、固定サイズのブロック（典型的には512バイトや4096バイト）単位でデータを転送するデバイスだ。ハードディスク、SSD、USBメモリなど、ランダムアクセス可能なストレージデバイスがここに分類される。`ls -l`で表示すると、先頭が`b`になる。

**キャラクタデバイス**は、バイト単位のストリームとしてデータを転送するデバイスだ。端末、シリアルポート、マウス、キーボード、`/dev/null`、`/dev/urandom`など。ランダムアクセスではなく、逐次的にデータが流れる。`ls -l`で先頭が`c`になる。

```
$ ls -l /dev/sda /dev/null /dev/tty
brw-rw---- 1 root disk    8, 0 ... /dev/sda    # ブロックデバイス (b)
crw-rw-rw- 1 root root    1, 3 ... /dev/null   # キャラクタデバイス (c)
crw-rw-rw- 1 root tty     5, 0 ... /dev/tty    # キャラクタデバイス (c)
```

`8, 0`や`1, 3`という数字は、メジャー番号とマイナー番号だ。メジャー番号はデバイスドライバを識別し、マイナー番号は同一ドライバが管理する個々のデバイスを識別する。カーネルはこの番号を使って、ファイル操作を適切なデバイスドライバに振り分ける。

この二分法は、1970年代初頭のハードウェアの特性を反映している。だがその設計は50年後の今も生きている。SSDは物理的にはフラッシュメモリだが、UNIXからはブロックデバイスとして見える。GPUも、`/dev/nvidia0`というキャラクタデバイスを通じてアクセスされる。

### UNIXにおけるファイルの7種類

POSIXが定義するUNIXのファイルタイプは7種類ある。

```
UNIXのファイル7種類:

  種類               ls -l の先頭文字    説明
  ─────────────────  ──────────────────  ──────────────────────────
  通常ファイル        -                   テキスト、バイナリデータ
  ディレクトリ        d                   他のファイルを含む
  シンボリックリンク  l                   別のファイルへの参照
  名前付きパイプ      p                   FIFO、プロセス間通信
  ブロックデバイス    b                   ブロック単位のI/O
  キャラクタデバイス  c                   バイト単位のストリームI/O
  ソケット            s                   ネットワーク/ローカル通信
```

7種類のファイル。7つの異なる実体。だがプログラムの視点からは、これらはすべて「ファイルディスクリプタを通じて読み書きできる対象」だ。通常のテキストファイルも、ネットワークソケットも、デバイスも、パイプも——`open()`（あるいは`socket()`）でファイルディスクリプタを取得し、`read()`で読み、`write()`で書き、`close()`で閉じる。

この統一性がなければ、パイプも、リダイレクションも、前回の`strace`でのパイプ観察も成立しない。`echo hello | cat`が動くのは、echoの標準出力とcatの標準入力が、どちらもファイルディスクリプタだからだ。パイプだろうがファイルだろうがソケットだろうが、ファイルディスクリプタという統一的なハンドルで操作できる。

---

## 3. ファイルディスクリプタとVFS——抽象化を支える仕組み

### ファイルディスクリプタ——万能のハンドル

UNIXの「すべてはファイル」を技術的に支えているのは、ファイルディスクリプタ（file descriptor、以下fd）だ。

fdは非負の整数値であり、プロセスがオープンしているI/Oチャネルを識別する。プロセスが起動すると、3つのfdがデフォルトで割り当てられる。

```
ファイルディスクリプタのデフォルト割り当て:

  fd 0 : 標準入力  (stdin)   ← キーボード or パイプの読み出し側
  fd 1 : 標準出力  (stdout)  ← 端末 or パイプの書き込み側
  fd 2 : 標準エラー (stderr)  ← 端末（通常、stdoutと同じ先）
```

`open()`を呼ぶと、カーネルは使われていない最小のfd番号を割り当てる。`open("/etc/passwd", O_RDONLY)`が`3`を返したなら、以降`read(3, buf, size)`でそのファイルからデータを読める。

ここで重要なのは、`read(3, buf, size)`というシステムコールは、fd 3が何を指しているかを知らない、ということだ。通常のファイルかもしれない。パイプかもしれない。ソケットかもしれない。デバイスファイルかもしれない。`read()`はfd番号を受け取り、カーネルに「このfdから読んでくれ」と頼むだけだ。fdが何に接続されているかは、カーネルが管理するファイルテーブルに記録されている。

```
プロセスのファイルディスクリプタテーブル:

  Process A
  ┌─────────┐
  │ fd table │
  │  0 ──────┼──→ パイプ (読み出し側)
  │  1 ──────┼──→ /var/log/output.txt
  │  2 ──────┼──→ /dev/tty (端末)
  │  3 ──────┼──→ TCP socket (192.168.1.10:8080)
  │  4 ──────┼──→ /dev/sda (ディスクデバイス)
  └─────────┘

  read(0, ...) → パイプからデータを読む
  read(3, ...) → TCPソケットからデータを読む
  read(4, ...) → ディスクデバイスからデータを読む
  → すべて同じ read() システムコールで操作
```

このテーブルが、「すべてはファイル」を実現する間接参照のレイヤーだ。プログラムはfd番号だけを知っている。fdの先に何があるかは知らなくてよい。この無関心さ——前回のパイプの議論で「UNIXパイプの設計上の核心」と呼んだ性質——は、ファイルディスクリプタの抽象化から生まれている。

### VFS——仮想ファイルシステム層

ファイルディスクリプタがプロセス側の抽象なら、カーネル側の抽象はVFS（Virtual File System）層だ。

1985年、Sun MicrosystemsはSunOS 2.0でVFSを導入した。動機は明確だった。NFS（Network File System）をサポートするために、ローカルのUFS（Unix File System）とネットワーク越しのNFSを、カーネル内で統一的に扱う仕組みが必要になったのだ。

Sunが考案したVFSは二層構造だった。

```
VFS（Virtual File System）のアーキテクチャ:

  ユーザ空間
  ──────────────────────────────────
    アプリケーション
      │  open(), read(), write(), close()
      ▼
  ──────────────────────────────────
  カーネル空間
      │
      ▼
  ┌──────────────────────┐
  │  VFS 層               │  ← ファイルシステムの共通インタフェース
  │  (vnode/vfs interface) │
  └──────┬───────┬───────┬┘
         │       │       │
         ▼       ▼       ▼
  ┌─────┐ ┌─────┐ ┌──────┐
  │ ext4 │ │ NFS │ │procfs│  ← 具体的なファイルシステム実装
  └─────┘ └─────┘ └──────┘
         │       │
         ▼       ▼
       ディスク  ネットワーク
```

VFS層は、アプリケーションからの`open()`、`read()`、`write()`、`close()`を受け取り、それをパス名に基づいて適切なファイルシステム実装に振り分ける。`/home/user/data.txt`へのアクセスはext4に、`/mnt/share/report.pdf`へのアクセスはNFSに、`/proc/cpuinfo`へのアクセスはprocfsに——アプリケーション側のコードは一切変わらない。

VFSの設計は、オブジェクト指向プログラミングにおけるインタフェースやポリモーフィズムと本質的に同じだ。共通のインタフェース（read、write、open、close）を定義し、具体的な実装（ext4、NFS、procfs）がそれを満たす。アプリケーションは抽象に依存し、具象を知らない。

SunがVFSを発明した動機はNFSという実用的な課題だった。だがその帰結は、UNIXの「すべてはファイル」の原則を、単一のファイルシステムから無限のファイルシステムへと拡張したことだった。VFSがあるからこそ、`/proc`も`/sys`も`/dev`もFUSEも、すべてが同一の`read()`/`write()`で操作できる。

### /proc——プロセスをファイルに変える

`/proc`ファイルシステムの歴史はLinuxより古い。

1984年、Tom J. KillianがUNIX V8（8th Edition）に/procを実装し、同年6月のUSENIXで「Processes as Files」と題して発表した。元々の動機は、デバッガがプロセスの状態を調査するために使っていた`ptrace()`システムコールの代替だった。プロセスの情報を「ファイルとして読む」ことで、既存のファイル操作ツールをデバッグに流用できるようにしたのだ。

このアイデアはPlan 9に受け継がれ、さらにLinuxへと伝播した。Linuxでは1992年9月のv0.97.3で/procが初めて導入された。

Linuxの/procは、当初の「プロセス情報」という範囲を大きく超えて拡張された。1992年12月のv0.98.6では、プロセス以外のシステム情報——CPU、メモリ、ネットワーク、カーネルパラメータ——も/proc配下に配置されるようになった。

```
/procの構造（Linuxの場合）:

  /proc/
  ├── 1/                    # PID 1のプロセス情報
  │   ├── status            # プロセスの状態
  │   ├── cmdline           # コマンドライン引数
  │   ├── fd/               # オープンしているfd一覧
  │   └── maps              # メモリマップ
  ├── cpuinfo               # CPU情報
  ├── meminfo               # メモリ情報
  ├── loadavg               # 負荷平均
  ├── net/                  # ネットワーク統計
  │   ├── tcp               # TCP接続一覧
  │   └── dev               # ネットワークデバイス統計
  └── sys/                  # カーネルパラメータ（読み書き可能）
      └── net/
          └── ipv4/
              └── ip_forward  # echo 1 > でIP転送を有効化
```

`cat /proc/1/status`で、PID 1のプロセスの状態がテキストとして表示される。`cat /proc/cpuinfo`でCPUのモデル名やクロック数が読める。`echo 1 > /proc/sys/net/ipv4/ip_forward`とすれば、ファイルへの書き込みでカーネルの動作が変わる。

ここに、「すべてはファイル」の原則の威力が凝縮されている。プロセスの状態もCPUの情報もカーネルのパラメータも、すべてファイルとして公開される。だから`cat`で読め、`grep`で検索でき、`echo`と`>`で書ける。新しいAPIを覚える必要はない。ファイル操作を知っていれば、カーネルの奥深くにある情報にアクセスできる。

### /sys——デバイスモデルのファイル化

Linuxの/procは成功と同時に、その成功ゆえの問題を抱えた。プロセス情報からカーネルパラメータまで、あらゆる情報が/procに詰め込まれ、構造が乱雑になった。

2003年、Patrick MochelはLinuxカーネル2.6にsysfs（/sysファイルシステム）を導入した。カーネル2.4の問題点——統一的なドライバ-デバイス関係の表現方法の欠如、汎用的なホットプラグ機構の不在、/procの肥大化——を解決するためだ。

/sysはデバイスモデルの情報を構造化された形でユーザ空間に公開する。

```
/sysの構造:

  /sys/
  ├── block/                # ブロックデバイス
  │   └── sda/
  │       ├── size          # デバイスサイズ
  │       └── queue/        # I/Oスケジューラ設定
  ├── class/                # デバイスクラス別
  │   ├── net/
  │   │   └── eth0/
  │   │       ├── address   # MACアドレス
  │   │       └── speed     # リンク速度
  │   └── backlight/
  │       └── intel_backlight/
  │           └── brightness  # 画面の明るさ（書き込み可能）
  ├── devices/              # デバイスツリー
  └── fs/                   # ファイルシステム情報
```

`cat /sys/class/net/eth0/address`でNICのMACアドレスが読める。`echo 50 > /sys/class/backlight/intel_backlight/brightness`でノートPCの画面の明るさを変えられる。

/procと/sysの分離は、「すべてはファイル」の原則を維持したまま、情報の構造化を進めた例だ。アクセス方法は変わらない——`read()`と`write()`だ。だが情報の整理方法が改善された。

---

## 4. Plan 9——「すべてはファイル」を極限まで徹底した世界

### UNIXの設計者たちの不満

UNIXの「すべてはファイル」は、実際には「ほとんどはファイルである」だった。

ネットワーク通信にはソケットAPIが必要だ。ウィンドウシステムにはX11プロトコルが必要だ。プロセス間通信にはSystem Vのメッセージキューや共有メモリが必要だ。これらはファイルディスクリプタで操作できるとはいえ、`open("/dev/tcp/192.168.1.10/80")`のような形でファイルパスから直接アクセスすることはできない。

UNIXの設計者たち自身が、この不徹底さに不満を抱いていた。Ken Thompson、Rob Pike、Dave Presotto、Phil Winterbottomらは1980年代後半からBell LabsでPlan 9を設計し始めた。UNIXの「すべてはファイル」を、今度は妥協なく徹底する——それがPlan 9の設計思想だった。

### 9Pプロトコル——14のメッセージで世界を表現する

Plan 9の中核は9P（後にStyxとも呼ばれ、最新版は9P2000）というファイルプロトコルだ。

9Pはわずか14種類のメッセージで構成されるプロトコルで、あらゆるリソースへのアクセスをファイル操作に還元する。ネットワーク越しのファイル操作はもちろん、Plan 9ではネットワークそのもの、ウィンドウシステム、さらにはプロセスの制御までが9Pを通じて行われる。

UNIXでは、ネットワーク通信に`socket()`、`connect()`、`bind()`、`listen()`、`accept()`といった専用のシステムコールが必要だ。Plan 9では、ネットワーク接続はファイルシステムとして表現される。TCPで接続したければ、`/net/tcp`ディレクトリ配下のファイルを読み書きする。

```
UNIXでのTCP接続:
  int sock = socket(AF_INET, SOCK_STREAM, 0);
  connect(sock, &addr, sizeof(addr));
  write(sock, data, len);
  read(sock, buf, sizeof(buf));
  close(sock);

Plan 9でのTCP接続:
  int fd = open("/net/tcp/clone", OWRITE);  // 新しい接続を作成
  read(fd, id, ...);                        // 接続IDを取得
  write(ctlfd, "connect 192.168.1.10!80");  // 接続先を指定
  // → /net/tcp/{id}/data を read/write する
```

Plan 9では、ネットワーク接続を開始する操作すら`open()`と`write()`で行う。専用のシステムコールは存在しない。ネットワークは「ファイルシステムの一部」として自然に扱われる。

### per-process名前空間——プロセスごとの世界観

Plan 9のもう一つの革新は、per-process名前空間だ。

UNIXでは、すべてのプロセスが基本的に同じファイルシステムビューを共有する。`/etc/passwd`はどのプロセスから見ても同じ`/etc/passwd`だ。

Plan 9では、プロセスごとに名前空間をカスタマイズできる。あるプロセスにとっての`/dev`が、別のプロセスにとっての`/dev`と異なる内容を持つことがある。`rfork()`システムコールはビットベクタの引数を取り、親プロセスと子プロセスの間で名前空間を共有するか、コピーするかを細粒度で制御する。

この設計は、UNIXの名前空間——後にLinux 2.4.19（2002年）で導入されたmount名前空間の機構に直接影響を与えた。Dockerコンテナの隔離がlinux名前空間に基づいていることを考えれば、Plan 9の設計思想は間接的に現代のコンテナ技術を支えている。

### ユニオンマウント——ディレクトリの重ね合わせ

Plan 9のユニオンマウントは、複数のディレクトリを一つのパスに「重ねる」仕組みだ。`/bin`に複数のディレクトリをユニオンマウントすれば、それぞれのディレクトリにある実行ファイルがすべて`/bin`配下に見える。検索は指定された順序で行われる。

この発想は、LinuxのUnionFS、AUFS、overlayfsへと受け継がれた。Dockerのイメージレイヤーは、まさにユニオンマウントの現代的実装だ。

### Plan 9の「失敗」と遺産

Plan 9は商業的に普及しなかった。1992年の初公開以降、研究用途以外での採用はきわめて限られた。既存のUNIXソフトウェアとの互換性がなく、エコシステムが育たなかったことが主因だ。

だがPlan 9の影響は、形を変えて現代のOSに流れ込んでいる。

1992年9月、Rob PikeとKen ThompsonはNew Jerseyのダイナーのプレースマットの上でUTF-8を設計した。Thompsonがビットパッキングを考案し、その夜のうちにPlan 9全体をUTF-8に変換した。UTF-8は今やWebの標準文字エンコーディングだ。

Plan 9のper-process名前空間は、Linuxの名前空間（namespaces）に受け継がれ、コンテナ技術の基盤となった。Plan 9のユニオンマウントは、Dockerのレイヤーファイルシステムに受け継がれた。Plan 9の/procは、Linuxの/procに受け継がれた。9Pプロトコルは、LinuxカーネルのVirtio-9pとしてゲストOSとホスト間のファイル共有に使われ、FUSEの設計にも影響を与えた。

技術の影響力は、採用数だけでは測れない。

---

## 5. 「すべてはファイル」の限界——ioctl()という妥協

### ioctl()——抽象化の裏口

「すべてはファイルである」は、美しい原則だ。だが現実は美しさだけでは回らない。

`open()`、`read()`、`write()`、`close()`——この四つのシステムコールであらゆるI/Oを表現できるか。答えは否だ。

ディスクのフォーマット、端末のボーレート設定、ネットワークインタフェースのMTU変更、GPUへのコマンド送信——これらの「デバイス固有の操作」は、`read()`や`write()`のバイトストリームモデルには収まらない。「読む」でも「書く」でもない操作が、デバイスには無数に存在する。

この問題に対するUNIXの解決策が`ioctl()`（I/O control）システムコールだ。

```c
#include <sys/ioctl.h>

int ioctl(int fd, unsigned long request, ...);
```

`ioctl()`はファイルディスクリプタと「リクエストコード」を受け取り、デバイス固有の操作を行う。端末のウィンドウサイズを取得する`TIOCGWINSZ`、ネットワークインタフェースのフラグを設定する`SIOCSIFFLAGS`——リクエストコードはデバイスドライバごとに異なり、事実上何でもできる「裏口」だ。

`ioctl()`は「すべてはファイル」の原則に対する最も顕著な例外であり、最も実用的な妥協だ。LWN.netの2022年の記事が指摘するように、ioctl()はドキュメント化が不十分で、イントロスペクション（自己記述）が不可能で、32ビットと64ビットの間で互換性問題を起こす。だがそれでも、50年以上にわたって使い続けられている。代替手段がないからだ。

### FUSEによるユーザ空間への拡張

「すべてはファイル」の原則を拡張する別のアプローチとして、FUSE（Filesystem in Userspace）がある。

2001年、Miklos SzerediがFUSEの開発を開始した。2005年にLinuxカーネル2.6.14に正式にマージされたFUSEは、ユーザ空間のプログラムがファイルシステムを実装できる仕組みだ。カーネルモジュール（fuse.ko）がカーネルとユーザ空間の仲介役を果たし、ユーザ空間のプログラムが`open()`、`read()`、`write()`などのファイル操作に対する応答を自由に実装できる。

FUSEの登場により、「すべてはファイル」の適用範囲が大幅に広がった。sshfs（SSH越しのリモートファイルシステム）、s3fs（Amazon S3をファイルシステムとしてマウント）、ntfs-3g（NTFSの読み書き）——これらはすべてFUSE上に構築されている。Amazon S3のオブジェクトストレージを`ls`で一覧し、`cat`で読み、`cp`でコピーできる。クラウドのストレージが、ローカルのファイルと同じ操作で扱える。

FUSEは「すべてはファイル」の原則を、カーネル開発者だけの特権からユーザ空間の開発者にまで開放した。

### 抽象化の功罪

「すべてはファイル」の功績は明白だ。統一的なインタフェースにより、プログラムの再利用性が飛躍的に高まった。パイプ、リダイレクション、シェルスクリプト——これらはすべて、「ファイルディスクリプタを読み書きする」という統一モデルの上に成り立っている。

だが抽象化には代価がある。

第一に、情報の損失。ファイルは「バイト列の読み書き」に抽象化される。だが、データベースの行やJSONのフィールドやTCPの接続状態は、単なるバイト列ではない。構造を持ったデータを非構造のバイト列に還元することで、型情報やスキーマ情報が失われる。

第二に、操作の限定。`read()`と`write()`だけでは表現できない操作が存在する。それが`ioctl()`を生んだ。「すべてはファイル」と言いながら、実際にはファイル操作だけでは不足する——この矛盾は、UNIXの設計の正直な限界だ。

第三に、性能のオーバーヘッド。VFS層を経由するすべてのI/Oには、抽象化の間接参照コストがかかる。データベースがバッファプール管理に`O_DIRECT`を使ってVFSのページキャッシュを迂回するのは、この抽象化が性能の足かせになるケースがあるからだ。

「すべてはファイル」は万能の原則ではない。だがこの原則があったからこそ、UNIXのツール群は50年以上にわたって組み合わせ可能であり続けた。抽象化の不完全さを認めつつ、その不完全な抽象化が生み出す統一性の価値を評価する——これが「原則を知る」ということだ。

---

## 6. ハンズオン：「すべてはファイル」を手で確かめる

ここからは手を動かす。/procの探索、デバイスファイルの実験、FUSEによる自作ファイルシステムを通じて、「すべてはファイル」の原則を体験する。

### 環境構築

```bash
docker run -it --rm --privileged ubuntu:24.04 bash
```

`--privileged`はデバイスファイルやカーネルパラメータへのアクセスに必要だ。

コンテナ内で必要なツールを用意する。

```bash
apt-get update && apt-get install -y gcc python3 fuse3 libfuse3-dev pkg-config strace
```

### 演習1：/procからプロセスの内部を覗く

/procを通じて、実行中のプロセスの内部状態をファイル操作だけで読み取る。

```bash
# 現在のシェルのPIDを確認
echo $$

# そのプロセスの情報をファイルとして読む
cat /proc/$$/status | head -10
```

出力にはプロセス名、状態、PID、メモリ使用量などが含まれる。これはカーネルがリアルタイムに生成するテキストだ。ディスク上にファイルは存在しない。

```bash
# プロセスが開いているファイルディスクリプタを確認
ls -l /proc/$$/fd
```

`0`、`1`、`2`がそれぞれstdin、stdout、stderrに対応するシンボリックリンクとして見える。fdの先が何に接続されているかが、ファイルシステムの操作で確認できる。

```bash
# プロセスのメモリマップを確認
cat /proc/$$/maps | head -10

# カーネルパラメータを読む
cat /proc/sys/kernel/hostname

# カーネルパラメータを書き換える（root権限が必要）
echo "test-container" > /proc/sys/kernel/hostname
cat /proc/sys/kernel/hostname
```

`echo`と`>`でカーネルのパラメータを変更している。専用の管理コマンドは不要だ。ファイルへの書き込みだけで、カーネルの動作が変わる。

### 演習2：デバイスファイルの動作を確かめる

UNIXの疑似デバイスファイルは、「すべてはファイル」の最も直感的な例だ。

```bash
# /dev/null — すべてを飲み込む
echo "このテキストは消える" > /dev/null
cat /dev/null    # 何も出力されない（読むと即座にEOF）

# /dev/zero — 無限のゼロバイト
dd if=/dev/zero bs=16 count=1 2>/dev/null | od -A x -t x1
# 00 00 00 00 ... が16バイト表示される

# /dev/urandom — 擬似乱数のストリーム
dd if=/dev/urandom bs=16 count=1 2>/dev/null | od -A x -t x1
# ランダムなバイト列が表示される

# デバイスの種類を確認
ls -l /dev/null /dev/zero /dev/urandom
# すべて先頭が 'c' — キャラクタデバイス
```

`/dev/null`、`/dev/zero`、`/dev/urandom`——これらは物理ハードウェアに対応しない疑似デバイスだ。だが`cat`で読め、`echo`で書ける。ファイルと同じ操作だ。

```bash
# /dev/nullとリダイレクションの組み合わせ
# stderrだけを表示し、stdoutは破棄する
ls /nonexistent 2>&1 1>/dev/null

# /dev/urandomを使ったランダムパスワード生成
cat /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 16
echo
```

デバイスファイルがパイプラインの一部として自然に使える。`cat /dev/urandom`でランダムバイトを読み、`tr`でフィルタし、`head`で切り取る。デバイスもパイプもフィルタも、すべてファイルディスクリプタの上で協調している。

### 演習3：ファイルディスクリプタの挙動をCで観察する

ファイルディスクリプタの統一性をCプログラムで確認する。

```bash
cat << 'EOF' > /tmp/fd_demo.c
/* fd_demo: 異なるファイルタイプに同じread()を適用する */
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

void read_and_show(const char *label, int fd) {
    char buf[64];
    ssize_t n = read(fd, buf, sizeof(buf) - 1);
    if (n > 0) {
        buf[n] = '\0';
        /* 改行を除去して先頭40文字を表示 */
        char *nl = strchr(buf, '\n');
        if (nl) *nl = '\0';
        if (strlen(buf) > 40) buf[40] = '\0';
        printf("  %-20s fd=%d  data: %s\n", label, fd, buf);
    } else {
        printf("  %-20s fd=%d  (no data or error)\n", label, fd);
    }
}

int main(void) {
    printf("同じ read() で異なるファイルタイプを読む:\n\n");

    /* 通常ファイル */
    int fd1 = open("/etc/hostname", O_RDONLY);
    if (fd1 >= 0) {
        read_and_show("/etc/hostname", fd1);
        close(fd1);
    }

    /* procfs (仮想ファイル) */
    int fd2 = open("/proc/loadavg", O_RDONLY);
    if (fd2 >= 0) {
        read_and_show("/proc/loadavg", fd2);
        close(fd2);
    }

    /* デバイスファイル */
    int fd3 = open("/dev/urandom", O_RDONLY);
    if (fd3 >= 0) {
        unsigned char rbuf[4];
        read(fd3, rbuf, 4);
        printf("  %-20s fd=%d  data: %02x%02x%02x%02x\n",
               "/dev/urandom", fd3, rbuf[0], rbuf[1], rbuf[2], rbuf[3]);
        close(fd3);
    }

    /* パイプ */
    int pipefd[2];
    if (pipe(pipefd) == 0) {
        write(pipefd[1], "hello from pipe\n", 16);
        close(pipefd[1]);
        read_and_show("pipe", pipefd[0]);
        close(pipefd[0]);
    }

    printf("\n全て同じ read() システムコールで読み取った。\n");
    printf("fd番号は異なるが、操作は同一だ。\n");
    return 0;
}
EOF
gcc -o /tmp/fd_demo /tmp/fd_demo.c
/tmp/fd_demo
```

通常ファイル、procfs、デバイスファイル、パイプ——4つの異なるファイルタイプを、同じ`read()`で読んでいる。プログラムのコードには、対象がファイルなのかデバイスなのかパイプなのかを区別するロジックは一切ない。`open()`でfdを取得し、`read()`で読む。それだけだ。

### 演習4：straceでVFS層を観察する

同じ`read()`システムコールが、異なるファイルタイプに対してどう振る舞うかをstraceで確認する。

```bash
# 通常ファイルの読み取り
strace -e trace=openat,read,close cat /etc/hostname 2>&1 | tail -8

# procfsの読み取り
strace -e trace=openat,read,close cat /proc/loadavg 2>&1 | tail -8

# デバイスファイルの読み取り
strace -e trace=openat,read,close dd if=/dev/urandom bs=4 count=1 2>&1 | tail -8
```

どの場合も、システムコールは`openat()`→`read()`→`close()`の同じシーケンスだ。VFS層がファイルタイプの違いを吸収し、適切なファイルシステム実装にディスパッチしている。

### 演習5：PythonでFUSEファイルシステムを実装する

FUSEを使って、独自のファイルシステムを実装する。以下は、現在時刻を返す仮想ファイルを持つ最小限のファイルシステムだ。

```bash
# Python用FUSEバインディングをインストール
apt-get install -y python3-pip
pip3 install pyfuse3 --break-system-packages
apt-get install -y python3-pyfuse3 2>/dev/null || true

# マウントポイントを作成
mkdir -p /tmp/timefs
```

```bash
cat << 'PYEOF' > /tmp/timefs.py
#!/usr/bin/env python3
"""timefs: 現在時刻を返す仮想ファイルシステム（FUSE）"""
import errno
import os
import stat
import time

import pyfuse3
import trio

class TimeFS(pyfuse3.Operations):
    """現在時刻を返すファイル 'now' を持つファイルシステム"""

    def __init__(self):
        super().__init__()
        self._inode_map = {
            pyfuse3.ROOT_INODE: {'name': b'.', 'type': 'dir'},
            2: {'name': b'now', 'type': 'file'},
        }

    async def getattr(self, inode, ctx=None):
        entry = pyfuse3.EntryAttributes()
        entry.st_ino = inode
        entry.st_mode = 0
        entry.st_nlink = 1
        entry.st_uid = os.getuid()
        entry.st_gid = os.getgid()
        stamp = int(time.time() * 1e9)
        entry.st_atime_ns = stamp
        entry.st_mtime_ns = stamp
        entry.st_ctime_ns = stamp

        if inode == pyfuse3.ROOT_INODE:
            entry.st_mode = stat.S_IFDIR | 0o755
            entry.st_nlink = 2
            entry.st_size = 0
        elif inode == 2:
            content = time.strftime('%Y-%m-%d %H:%M:%S\n').encode()
            entry.st_mode = stat.S_IFREG | 0o444
            entry.st_size = len(content)
        else:
            raise pyfuse3.FUSEError(errno.ENOENT)
        return entry

    async def lookup(self, parent_inode, name, ctx=None):
        if parent_inode == pyfuse3.ROOT_INODE and name == b'now':
            return await self.getattr(2)
        raise pyfuse3.FUSEError(errno.ENOENT)

    async def opendir(self, inode, ctx):
        if inode != pyfuse3.ROOT_INODE:
            raise pyfuse3.FUSEError(errno.ENOENT)
        return inode

    async def readdir(self, fh, start_id, token):
        entries = [(2, b'now')]
        for idx, (ino, name) in enumerate(entries):
            if idx < start_id:
                continue
            attr = await self.getattr(ino)
            if not pyfuse3.readdir_reply(token, name, attr, idx + 1):
                break

    async def open(self, inode, flags, ctx):
        if inode != 2:
            raise pyfuse3.FUSEError(errno.ENOENT)
        return pyfuse3.FileInfo(fh=inode)

    async def read(self, fh, offset, size):
        content = time.strftime('%Y-%m-%d %H:%M:%S\n').encode()
        return content[offset:offset + size]

def main():
    fs = TimeFS()
    fuse_options = set(pyfuse3.default_options)
    fuse_options.add('fsname=timefs')
    pyfuse3.init(fs, '/tmp/timefs', fuse_options)
    try:
        trio.run(pyfuse3.main)
    except KeyboardInterrupt:
        pass
    finally:
        pyfuse3.close()

if __name__ == '__main__':
    main()
PYEOF
```

```bash
# バックグラウンドでFUSEファイルシステムを起動
python3 /tmp/timefs.py &
FUSE_PID=$!
sleep 1

# ファイルシステムを操作する
ls -la /tmp/timefs/
cat /tmp/timefs/now        # 現在時刻が表示される
sleep 2
cat /tmp/timefs/now        # 時刻が更新されている

# パイプラインの一部として使う
cat /tmp/timefs/now | tr -d '\n' | xargs -I{} echo "Server time: {}"

# アンマウントして停止
kill $FUSE_PID 2>/dev/null
fusermount3 -u /tmp/timefs 2>/dev/null
```

ユーザ空間のPythonプログラムが「ファイルシステム」として機能している。`cat`で読め、`ls`で一覧できる。現在時刻というデータが、ファイルとして公開されている。FUSEは「すべてはファイル」の原則を、カーネル開発者でなくても実践できるようにした仕組みだ。

---

## 7. まとめと次回予告

### この回の要点

- UNIXの「すべてはファイルである」は、1971年のFirst EditionにおけるDennis Ritchieのデバイスファイルの導入に始まる。ハードウェアデバイスをファイルシステム内のファイルとして表現し、`open()`/`read()`/`write()`/`close()`という統一的なインタフェースで操作できるようにした。この設計により、ファイルを扱えるプログラムはすべてデバイスも扱えるようになった

- ファイルディスクリプタは「すべてはファイル」を支えるプロセス側の抽象であり、VFS（Virtual File System）はカーネル側の抽象だ。1985年にSun MicrosystemsがNFSのために導入したVFSは、ファイルシステムの種類の違いをアプリケーションから隠蔽し、ext4、NFS、procfs、sysfsなどを同一のシステムコールで操作可能にした

- /procは1984年にUNIX V8でTom J. Killianが実装した概念であり、Plan 9を経由してLinuxに伝播した。プロセスの内部状態をファイルとして読み取れるようにし、カーネルパラメータの変更すら`echo`と`>`で行える。/sysは2003年にPatrick Mochelがカーネル2.6に導入し、デバイスモデルの情報を構造化された形で公開した

- Plan 9は「すべてはファイル」を妥協なく徹底した。9P（14メッセージ）ですべてのリソースアクセスをファイル操作に還元し、per-process名前空間、ユニオンマウント、UTF-8（1992年、Pike & Thompson）を生み出した。商業的には普及しなかったが、Linux名前空間、overlayfs、/proc、UTF-8など、そのアイデアは現代のOSに広く受け継がれている

- ioctl()は「すべてはファイル」の原則に対する最も顕著な例外であり、最も実用的な妥協だ。read/writeだけではデバイスの全機能を表現できないという限界を認め、デバイス固有の操作に対する「裏口」を提供する。抽象化は万能ではないが、その不完全さゆえに柔軟であり、50年以上にわたって機能し続けている

### 冒頭の問いへの暫定回答

「"すべてはファイルである"——この抽象化は、なぜこれほど強力だったのか？」

暫定的な答えはこうだ。この抽象化が強力なのは、「異なるものを同じ方法で扱える」からだ。通常ファイルもデバイスもパイプもソケットも、`open()`/`read()`/`write()`/`close()`で操作できる。この統一性があるから、プログラムは対象が何であるかを知る必要がない。`cat`はファイルを読むプログラムだが、パイプからも読めるし、デバイスからも読めるし、/procからも読める。`cat`自身は何も変わっていない。接続先が変わっただけだ。

そしてこの統一性は、組み合わせ可能性（composability）の前提条件だ。パイプが機能するのは、すべてのI/Oがファイルディスクリプタを通じて行われるからだ。リダイレクションが機能するのも同じ理由だ。シェルスクリプトが強力なのは、あらゆるI/O操作がファイルという一つの抽象に還元されているからだ。

だが「すべてはファイル」は完璧ではない。ioctl()の存在が、バイトストリームだけでは世界を表現しきれないことを証明している。Plan 9は原則を徹底したが、実用の世界では妥協が必要だった。抽象化の価値は、完璧さではなく「十分に有用であること」にある。

あなたのシステムのAPIは、「統一的なインタフェース」で設計されているだろうか。異なるリソースに対して、異なるアクセス方法を要求していないだろうか。UNIXが`open()`/`read()`/`write()`/`close()`で世界を統一したように、あなたのシステムにも「一つの操作体系」が存在するだろうか。

### 次回予告

次回は「テキストストリーム——万能インタフェースとしてのテキスト」。UNIXのツール群は、ファイルの中を流れるデータの形式として「テキスト」を選んだ。バイナリではなく、テキスト。構造化データではなく、行指向のプレーンテキスト。

ed（1969年）、sed（1974年）、awk（1977年）——UNIXのテキスト処理ツールの系譜を辿りながら、「なぜテキストなのか」を考える。そしてこの選択の限界——型情報の欠如、パース曖昧性、性能の問題——にも正面から向き合う。PowerShellが「オブジェクトパイプライン」を選んだのは、UNIXのテキストストリームへの批判だった。テキストは「万能」なのか。それとも「不完全だが十分に有用」な妥協なのか。

`cat /etc/passwd | cut -d: -f1`と打ってみてほしい。コロン区切りのテキストから最初のフィールドを切り出す。このコマンドが動くのは、passwdファイルがテキストであり、フィールドが`:`で区切られているという「暗黙の合意」があるからだ。この「暗黙の合意」が何を可能にし、何を制限しているのかを、次回は掘り下げる。

---

## 参考文献

- K. Thompson, D.M. Ritchie, "UNIX Programmer's Manual, First Edition", November 3, 1971: <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/1stEdman.html>
- D.M. Ritchie, K. Thompson, "The UNIX Time-Sharing System", Communications of the ACM, Vol. 17, No. 7, July 1974
- Everything is a file — Wikipedia: <https://en.wikipedia.org/wiki/Everything_is_a_file>
- Unix file types — Wikipedia: <https://en.wikipedia.org/wiki/Unix_file_types>
- Virtual file system — Wikipedia: <https://en.wikipedia.org/wiki/Virtual_file_system>
- R. Sandberg et al., "Design and Implementation of the Sun Network Filesystem", USENIX Summer Conference, 1985: <https://cs.ucf.edu/~eurip/papers/sandbergnfs.pdf>
- Tom J. Killian, "Processes as Files", USENIX, June 1984
- procfs — Wikipedia: <https://en.wikipedia.org/wiki/Procfs>
- The /proc Filesystem — The Linux Kernel documentation: <https://docs.kernel.org/filesystems/proc.html>
- Patrick Mochel, "The sysfs Filesystem", Ottawa Linux Symposium, 2005: <https://www.kernel.org/doc/ols/2005/ols2005v1-pages-321-334.pdf>
- sysfs — Wikipedia: <https://en.wikipedia.org/wiki/Sysfs>
- Plan 9 from Bell Labs — Overview: <https://9p.io/plan9/about.html>
- Rob Pike et al., "Plan 9 from Bell Labs", Computing Systems, Vol. 8, No. 3, Summer 1995: <https://css.csail.mit.edu/6.824/2014/papers/plan9.pdf>
- 9P (protocol) — Wikipedia: <https://en.wikipedia.org/wiki/9P_(protocol)>
- Rob Pike, "UTF-8 history", 2003: <https://doc.cat-v.org/bell_labs/utf-8_history>
- Filesystem in Userspace — Wikipedia: <https://en.wikipedia.org/wiki/Filesystem_in_Userspace>
- Miklos Szeredi, "Introducing FUSE: Filesystem in USErspace", LWN.net, 2001: <https://lwn.net/2001/1115/a/fuse.php3>
- Jonathan Corbet, "ioctl() forever?", LWN.net, 2022: <https://lwn.net/Articles/897202/>
- Roy T. Fielding, "Architectural Styles and the Design of Network-based Software Architectures", University of California, Irvine, 2000: <https://ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm>
- Brian W. Kernighan, Rob Pike, "The UNIX Programming Environment", Prentice Hall, 1984
- Eric S. Raymond, "The Art of UNIX Programming", Addison-Wesley, 2003
