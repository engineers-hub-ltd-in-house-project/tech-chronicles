# UNIXという思想

## ――パイプ、プロセス、ファイル――すべてはここから始まった

### 第18回：「Plan 9――UNIXの先を夢見た実験」

**連載「UNIXという思想――パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Plan 9 from Bell Labs（1992年初公開）の設計思想と、UNIXの「Everything is a file」を徹底した9Pプロトコルの仕組み
- per-process名前空間とユニオンマウントによるリソース抽象化の革新
- UTF-8の誕生（1992年9月、Rob PikeとKen Thompson）とPlan 9での世界初の完全サポート
- rfork()システムコールの設計と、Linuxのnamespace/clone/unshare機能への直接的な影響
- Plan 9が商業的に普及しなかった理由——「十分に良い」UNIXという最大の敵
- FUSE、/proc、v9fs、Docker/コンテナのnamespace分離——Plan 9のアイデアが形を変えて現代のLinuxに流入した経路

---

## 1. 「正しすぎたOS」との出会い

2008年頃、私はある技術カンファレンスの廊下でPlan 9の話を聞いた。

正確には、Bell Labsの元研究者と雑談する機会があり、「UNIXの次」として設計されたOSの話になった。私は当時、複数の商用UNIXとLinuxを横断するインフラ案件に没頭しており、Solaris、AIX、HP-UX、Linuxの差異に日々悩まされていた。UNIXの設計思想に惹かれつつも、その不完全さ——ファイルと言いながらソケットは別のAPIが必要だったこと、名前空間がグローバルで他のユーザのマウントが見えてしまうこと、設定ファイルの場所がディストリビューションごとに異なること——に常々苛立ちを覚えていた。

「Plan 9は、UNIXの"Everything is a file"を本気で徹底したOSだ」

その一言が引っかかった。帰宅後、QEMUでPlan 9を起動してみた。起動画面にはGlendaという名の兎のマスコットが描かれている。OSの名前は、Ed Woodの1957年のSF映画「Plan 9 from Outer Space」——「史上最低の映画」として名高い作品——に由来する。Bell Labsの研究者らしいユーモアだ。

端末を開いて驚いた。ネットワーク接続の状態が`/net/tcp`というファイルとして見える。ウィンドウシステムの状態が`/dev/wsys`として見える。他のマシンのリソースが、ローカルのファイルシステムにマウントされて見える。UNIXで「Everything is a file」と言っていたものの、実際にはファイルではなかった領域——ネットワーク、GUI、リモートリソース——が、Plan 9ではすべてファイル操作でアクセスできる。

「これか」と思った。UNIXの設計者たち自身が「UNIXの理念は不完全だった」と認め、それを徹底した世界を作ろうとした。その結果がPlan 9だった。

だが同時に、別の疑問も浮かんだ。これほど理に適ったOSが、なぜ誰も使っていないのか。UNIXの限界を知り尽くした人間が作った「正しい」OSが、なぜUNIXに取って代われなかったのか。

あなたは、自分が使っているLinuxのnamespace機能——Dockerのコンテナ分離を支える基盤技術——の設計思想が、1990年代のBell Labsの実験的OSに遡ることを知っているだろうか。

---

## 2. UNIXの設計者がUNIXを超えようとした

### Bell Labsの次なる挑戦

Plan 9 from Bell Labsは、1980年代半ばからBell LabsのComputing Science Research Centerで開発が始まった。設計を率いたのはRob Pike、Ken Thompson、Dave Presotto、Phil Winterbottom——UNIXとC言語を生んだのと同じ研究グループだった。Dennis RitchieはComputing Techniques Research Departmentの長としてプロジェクトを支援した。

この事実は極めて重要だ。Plan 9は「UNIXを知らない人間が作ったUNIXの代替」ではない。**UNIXを作った人間自身が、UNIXの限界を認識し、その先を設計しようとしたOS**なのだ。

Rob Pikeは1995年のComputing Systems誌に発表された論文「Plan 9 from Bell Labs」の中で、Plan 9の設計思想を三つの原則に集約している。

第一に、リソースはファイルシステム内のファイルのように名前を付けてアクセスする。第二に、それらのリソースにアクセスするための標準プロトコル——9P——が存在する。第三に、異なるサービスが提供する互いに独立した階層構造を、一つのプライベートな階層的名前空間に結合する。

UNIXの「Everything is a file」は理念としては美しかったが、実装は不完全だった。通常のファイルは`open()`/`read()`/`write()`/`close()`で操作するが、ネットワーク接続にはBSD socketの`socket()`/`connect()`/`send()`/`recv()`という別のAPI体系が必要だった。プロセス間通信にはSystem VのIPCというさらに別の仕組みがあった。GUIウィンドウシステムのX11は、独自のクライアント-サーバプロトコルで動作し、ファイルとは無関係だった。

UNIXは「すべてはファイルである」と宣言しながら、実際にはファイルでないものが多数存在した。Plan 9は、この不完全さを解消しようとした。

### First Editionから Fourth Editionへ

Plan 9のリリースは4つの版（Edition）に分かれる。

First Edition（1992年）は大学向けの配布だった。この時点でPlan 9の主要な構成要素——カーネル、9Pプロトコル、per-process名前空間、samエディタ、完全なUTF-8サポート——はすでに完成していた。

Second Edition（1995年）で初めて一般に公開された。ソースライセンスは350ドル。AT&Tは組み込みシステム市場をターゲットとしたが、積極的なマーケティングは行わなかった。

Third Edition（2000年）は、Bell Labsの新しい親会社Lucent Technologiesが商用サポートを打ち切った後に、Plan 9 Licenseという独自のオープンソースライセンスでリリースされた。このライセンスはFree Software Foundationから「真にフリーではない」と批判された。

Fourth Edition（2002年4月）でようやくLucent Public License 1.02——OSIが認めるオープンソースライセンス——でリリースされた。2014年にはUCバークレー経由でGPL-2.0にもライセンスされ、2021年3月23日にはBell LabsからPlan 9 Foundationに知的財産が移転し、全版がMITライセンスで再公開された。

この遅すぎたオープンソース化は、Plan 9の運命を決定づけた要因の一つだ。Linuxが1991年にGPLv2で公開され、世界中の開発者のコントリビューションを集めていた時期に、Plan 9は大学向け配布か350ドルのライセンスしかなかった。1992年から2002年まで——Linuxが爆発的に成長した10年間——Plan 9のソースコードは事実上、閉じたままだった。

### 9Pプロトコル——統一インタフェースの実現

Plan 9の技術的核心は9Pプロトコル（別名Styx）にある。

UNIXではファイル操作はカーネル内のVFS（Virtual File System）層を通じて行われ、ネットワーク操作はソケットAPIを通じて行われる。二つの異なるインタフェースが並存している。Plan 9は、この二重性を9Pという単一のプロトコルで解消した。

9Pはメッセージ指向のファイルシステムプロトコルだ。すべてのリソース——ファイル、ディレクトリ、ネットワーク接続、プロセス情報、ウィンドウシステム、さらにはリモートマシンのリソース——は、9Pサーバとして実装される。クライアントは9Pメッセージ（attach、walk、open、read、write、clunk等）を送信してリソースにアクセスする。ローカルもリモートも関係ない。

```
UNIXとPlan 9のリソースアクセスモデル比較:

UNIX:
  ファイル         → open() / read() / write() / close()   [VFS]
  ネットワーク     → socket() / connect() / send() / recv() [BSD socket]
  プロセス間通信   → shmget() / msgget() / semget()         [System V IPC]
  ウィンドウシステム → X11プロトコル                         [独自プロトコル]

  → 4つの異なるAPI体系が並存

Plan 9:
  ファイル         → 9P (open / read / write / clunk)
  ネットワーク     → 9P (/net/tcp を read / write)
  プロセス情報     → 9P (/proc/PID/status を read)
  ウィンドウシステム → 9P (/dev/wsys を read / write)
  リモートリソース → 9P (マウントして read / write)

  → すべてが9Pという単一のプロトコルに統一
```

この統一がもたらす威力は大きい。たとえば、リモートマシンのファイルシステムにアクセスしたい場合、UNIXではNFS（Network File System）を使う。リモートマシンのプロセス一覧を見たい場合は、SSHでログインして`ps`を叩く。Plan 9では、リモートマシンの`/proc`を自分の名前空間にマウントすれば、ローカルの`/proc`と同じようにファイル操作でプロセス情報を読める。ネットワーク越しという事実は、ユーザからは見えない。

Rob Pikeらの1995年の論文は、Plan 9のネットワーク設計を以下のように述べている。「システムはファイルシステム内のファイルのように名前が付けられアクセスされるリソースの上に構築されている。標準プロトコル9Pがこれらのリソースへのアクセスを提供し、異なるサービスが提供する互いに独立した階層構造が一つのプライベートな名前空間に結合される。」

この設計は、UNIXの「Everything is a file」を理念から実装に変えるものだった。UNIXが言葉だけで実現できなかったことを、Plan 9は本気で実現しようとした。

---

## 3. Plan 9の三つの革新

### per-process名前空間——グローバルからローカルへ

UNIXのファイルシステム名前空間はグローバルだ。あるユーザが`/mnt/nfs`にネットワークドライブをマウントすれば、同じマシン上のすべてのユーザからそのマウントが見える。`/etc/resolv.conf`を変更すれば、全プロセスのDNS設定が変わる。rootユーザが`mount`すれば、システム全体のファイルシステムツリーが変わる。

この設計はシンプルだが、深刻な問題をはらんでいる。あるプロセスの環境変更が、無関係な他のプロセスに波及する。マルチユーザ環境で、各ユーザが異なるネットワーク構成を必要とする場合に対処が難しい。セキュリティの面でも、すべてのプロセスが同じ名前空間を共有することは望ましくない。

Plan 9はこの問題を、per-process名前空間で解決した。

Plan 9では、各プロセスが独自のファイルシステム名前空間を持つ。`bind`と`mount`コマンドでファイルシステムの構成を変更しても、その変更は当該プロセスとその子プロセスにしか影響しない。他のプロセスの名前空間はまったく変わらない。しかもマウント操作に特権（root権限）は不要だ。グローバルな状態を変更するわけではないのだから、権限を制限する必要がないのだ。

```
UNIXとPlan 9の名前空間モデル比較:

UNIX（グローバル名前空間）:
  全プロセスが同一の名前空間を共有
  ┌──────────────────────────────┐
  │  /                           │
  │  ├── /home                   │
  │  ├── /etc                    │
  │  ├── /mnt/nfs  ← mount      │  ← 全プロセスから見える
  │  └── /proc                   │
  │                              │
  │  プロセスA  プロセスB  (同じ/mnt/nfsが見える)
  └──────────────────────────────┘

Plan 9（per-process名前空間）:
  各プロセスが独自の名前空間を構築
  ┌────────────────┐  ┌────────────────┐
  │ プロセスA       │  │ プロセスB       │
  │ /              │  │ /              │
  │ ├── /home      │  │ ├── /home      │
  │ ├── /net  ←独自│  │ ├── /net  ←独自│
  │ ├── /mnt/work  │  │ ├── /mnt/data  │
  │ └── /dev/draw  │  │ └── /dev/audio │
  └────────────────┘  └────────────────┘
  AとBの名前空間は互いに独立。
  Aのmount操作はBに影響しない。
```

`rfork()`システムコールがこの仕組みの核だ。Plan 9のrfork()はプロセスを生成する際に、ビットフラグで名前空間、メモリ空間、ファイルディスクリプタテーブル等の属性を「共有」するか「コピー」するかを細かく制御できる。名前空間を共有すれば、親と子で同じ名前空間の変更が互いに見える。コピーすれば、独立した名前空間で動作する。

この設計は、1992年にRob Pike、Dave Presotto、Ken Thompson、Howard Trickey、Phil Winterbottomが発表した論文「The Use of Name Spaces in Plan 9」に詳述されている。論文は「いくつかの注意深く実装された抽象化があれば、さまざまなアーキテクチャとネットワーク上で最大規模のシステムをサポートする小さなオペレーティングシステムを作ることが可能である」と述べ、その基盤をper-process名前空間と9Pプロトコルの二つに置いた。

### ユニオンマウント——柔軟なファイルシステム合成

Plan 9のもう一つの革新がユニオンマウントだ。

UNIXでは、あるディレクトリにファイルシステムをマウントすると、元のディレクトリの内容は隠される。`/mnt`にUSBドライブをマウントすれば、`/mnt`に元々あったファイルは見えなくなる。一つのマウントポイントには一つのファイルシステムしか存在できない。

Plan 9のbindとmountはユニオンディレクトリをサポートする。複数のディレクトリ——あるいは複数のファイルシステム——を一つのマウントポイントに「重ね合わせる」ことができる。フラグで、新しいディレクトリをユニオンの先頭に追加するか、末尾に追加するか、あるいは既存の内容を完全に置換するかを指定する。ファイルの検索時はユニオンの先頭から順に走査され、最初に見つかったファイルが使われる。

```
Plan 9のユニオンマウント:

  bind -b /usr/local/bin /bin    (-b: before, 先頭に追加)

  結果:
  /bin の内容:
    ┌─ /usr/local/bin/myapp     ← 先頭（新しく追加）
    ├─ /usr/local/bin/mytool    ← 先頭
    ├─ /bin/ls                  ← 元の/bin
    ├─ /bin/cat                 ← 元の/bin
    └─ /bin/grep                ← 元の/bin

  → /usr/local/bin と元の /bin の両方が /bin として見える。
  → 同名ファイルがあれば、先頭のものが優先される。
```

この概念は後にLinuxのoverlayfs（2014年にLinuxカーネルに統合）やDockerのイメージレイヤ構造に影響を与えた。Dockerイメージが複数のレイヤを重ね合わせて一つのファイルシステムとして提示する仕組みは、Plan 9のユニオンマウントの思想と通底している。

### UTF-8の誕生——ダイナーのプレースマットの上で

Plan 9の「副産物」の中で、最も広範な影響を世界に与えたのはUTF-8だ。

1992年9月、Rob PikeとKen Thompsonはニュージャージーのダイナーにいた。X/Open（後のThe Open Group）のメンバーから、ISO 10646の文字エンコーディングに関する提案の相談を受けていた。Plan 9は当時、ISO 10646のオリジナルのUTF（FSS-UTF）を使って16ビット文字をサポートしていたが、PikeとThompsonはそのエンコーディングに不満を持っていた。

その夜、二人はダイナーのプレースマット（ランチョンマット）の上で新しいエンコーディングを設計した。ASCII互換であること。バイト列のどこからでも文字の境界を検出できる自己同期性を持つこと。ソート順がUnicodeのコードポイント順と一致すること。NULバイト（0x00）を文字の途中に含まないこと——C言語の文字列処理と互換であるために。

Rob Pikeは2003年のメールでこう回想している。「UTF-8は1992年9月頃のある夜、ニュージャージーのダイナーでプレースマットの上に設計された」。

1992年9月8日火曜日午前3時22分——Ken Thompsonは、Plan 9のUTF-8への移行が完了したことをメールで報告した。わずか数日で、OS全体の文字エンコーディングを新しい方式に移行したのだ。Plan 9はUTF-8を完全にサポートした世界最初のOSとなった。

```
UTF-8のエンコーディング構造:

  コードポイント範囲       バイト数  ビットパターン
  ───────────────────────────────────────────────
  U+0000 .. U+007F        1バイト   0xxxxxxx          ← ASCII互換
  U+0080 .. U+07FF        2バイト   110xxxxx 10xxxxxx
  U+0800 .. U+FFFF        3バイト   1110xxxx 10xxxxxx 10xxxxxx
  U+10000 .. U+10FFFF     4バイト   11110xxx 10xxxxxx 10xxxxxx 10xxxxxx

  設計の要点:
  - ASCIIの範囲（U+0000〜U+007F）は1バイトで表現 → 既存のCコードが壊れない
  - 各バイトの先頭ビットで「先頭バイトか継続バイトか」を判別 → 自己同期性
  - NULバイト（0x00）はU+0000のみ → C文字列のNUL終端と互換
  - バイト列の辞書順ソートがコードポイント順と一致
```

2026年現在、Webページの約99%がUTF-8でエンコードされている。UTF-8は事実上、インターネットのテキストエンコーディングの世界標準だ。この標準が、1992年のダイナーのプレースマットの上で生まれ、Plan 9で初めて実装されたという事実は、Plan 9の影響力の証明として最も説得力がある。Plan 9というOSを使ったことがある人間はごくわずかだ。だがPlan 9が生んだUTF-8は、文字通り世界中のすべてのWebページに浸透している。

---

## 4. Plan 9はなぜ「失敗」したのか、そしてどう生き残ったか

### 「十分に良い」UNIXという最大の敵

Plan 9が商業的に普及しなかった理由は、技術的な劣位ではない。むしろ逆だ。Plan 9は技術的に「正しすぎた」。

Eric S. Raymondは『The Art of UNIX Programming』（2003年）の中で、Plan 9の失敗を端的に分析している。「Plan 9はUNIXをその先祖から引き離すほど魅力的な改善には至らなかった。……最も危険な敵は、十分に良い既存のコードベースである」。

UNIXには明らかな限界がある。「Everything is a file」は不完全だ。名前空間はグローバルだ。ネットワーク透過性は後付けだ。だがUNIXは「十分に良い」のだ。数十年にわたって蓄積されたソフトウェア資産、トレーニングされた人材、確立されたワークフロー——これらすべてを放棄してPlan 9に移行するだけの動機を、Plan 9は提供できなかった。

Plan 9が普及しなかった要因を整理する。

**互換性の断絶。** Plan 9はPOSIX互換ではない。UNIXのアプリケーションはPlan 9上でそのまま動かない。APE（ANSI/POSIX Environment）という互換レイヤは存在したが、完全な互換性は提供しなかった。テキストエディタ、スプレッドシート、CADプログラム、サーバアプリケーション——UNIXの世界で蓄積された膨大なアプリケーション資産が使えない。Raymondが「素晴らしい空箱」と表現したように、Plan 9は美しい設計を持つが、中に入れるソフトウェアがなかった。

**商用サポートの不在。** AT&Tは研究プロジェクトとしてPlan 9を運営したが、商用ソフトウェアとして市場に投入する意志も能力も十分ではなかった。組み込みシステム市場をターゲットとしたが、積極的なマーケティング、十分なドキュメント、明確なライセンス体系は長年にわたって欠如していた。

**ライセンスの問題。** Linuxが1991年からGPLv2で完全にオープンだったのに対し、Plan 9のソースコードが真の意味でオープンになったのは2002年のFourth Editionからだ。この10年のギャップは致命的だった。1990年代こそが、UNIXの代替がエコシステムを構築できるタイミングだった。Linuxはそのタイミングを掴んだ。Plan 9は逃した。

**デバイスドライバとハードウェアサポートの不足。** Linuxは世界中のボランティアがドライバを書いた。Plan 9のドライバサポートは限定的で、一般的なハードウェアで動作させることすら困難な場合があった。

### Plan 9のDNAがLinuxに流入した

Plan 9はOSとしては普及しなかった。だが、そのアイデアは形を変えて現代のLinuxに深く浸透している。

**Linux namespaces。** Dockerのコンテナ分離を支えるLinuxのnamespace機能は、Plan 9のper-process名前空間に直接着想を得たものだ。Wikipediaの"Linux namespaces"記事にも「Linux namespacesはPlan 9 from Bell Labsで広く使われている名前空間機能に着想を得た」と明記されている。mount namespace（2002年、Linux 2.4.19）を皮切りに、UTS、IPC、PID、network、user、cgroup、time namespaceが段階的に導入された。Linuxの`clone()`システムコールはPlan 9の`rfork()`に直接対応し、`unshare()`は既存プロセスの名前空間を分離する——rfork()のフラグ制御と同じ概念だ。

**FUSE（Filesystem in Userspace）。** Plan 9では、ユーザ空間のプログラムが9Pサーバとして振る舞うことで、任意のリソースをファイルシステムとして公開できた。この「ユーザ空間でファイルシステムを実装する」という発想は、LinuxのFUSE（2001年〜）に影響を与えた。FUSEの直接の祖先はAVFS（A Virtual Filesystem）であり、GNU Hurdのtranslatorコンセプトの影響も受けているが、Plan 9の思想的影響は広く認められている。

**/procファイルシステム。** Linuxの`/proc`ファイルシステムはPlan 9の`/proc`に明示的に着想を得ている。Plan 9は/procを「ファイルシステムの一級市民」として設計し、プロセスの状態をファイル操作で読み書きできるようにした。4.4BSDのprocfs実装もPlan 9からクローンされたものだ。

**v9fs（Linux上の9P実装）。** LinuxカーネルにはCONFIG_9P_FSというオプションで9Pプロトコルのネイティブサポートが含まれている。v9fs（Plan 9 Resource Sharing for Linux）として実装され、KVM/QEMUの仮想マシンとホスト間のファイル共有（VirtFS）に実用されている。Plan 9のプロトコルが、Linuxのカーネルソースに組み込まれて生きているのだ。

**plan9port（Plan 9 from User Space）。** Russ Cox（Go言語の共同開発者でもある）が作成したplan9portは、Plan 9のユーザ空間ツール群をLinux、macOS、FreeBSD等に移植したプロジェクトだ。Rob Pike自身が、plan9portのacmeエディタを日常的に使い続けている。Plan 9のUIが現代のUNIX系OSで動いているのだ。

```
Plan 9のアイデアがLinuxに流入した経路:

  Plan 9 (1992)
    │
    ├── per-process名前空間
    │     └──→ Linux namespaces (2002〜)
    │            └──→ Docker/コンテナ分離 (2013〜)
    │
    ├── ユーザ空間ファイルシステム
    │     └──→ FUSE (2001〜)
    │            └──→ sshfs, s3fs, etc.
    │
    ├── /proc ファイルシステム
    │     └──→ Linux /proc (1992〜)
    │            └──→ /sys (sysfs, 2004〜)
    │
    ├── 9P プロトコル
    │     └──→ v9fs (Linux kernel)
    │            └──→ VirtFS (KVM/QEMUファイル共有)
    │
    ├── ユニオンマウント
    │     └──→ overlayfs (Linux 3.18, 2014)
    │            └──→ Dockerイメージレイヤ
    │
    └── UTF-8
          └──→ 全世界のWebページの99%
```

Plan 9のアイデアは、OSとしてではなく、個別の機能としてLinuxに吸収された。一つの統一された設計哲学として受け入れられるのではなく、便利な部品として切り出され、既存のLinuxカーネルに組み込まれた。それはPlan 9の設計者が意図した形ではないかもしれない。だが技術の影響力は、必ずしもそのオリジナルの形で伝播するわけではない。

### Infernoと9front——Plan 9の系譜

Plan 9の系譜は本体だけでは終わらない。

Infernoは1995年にBell Labsで開発されたOSで、Plan 9のアイデアをより広いデバイスとネットワークに展開しようとした。9Pの変種であるStyxプロトコル、Limboプログラミング言語、Disバーチャルマシン（アーキテクチャ非依存のバイトコード実行環境）を特徴とする。Plan 9が「研究用OS」にとどまったのに対し、InfernoはPlan 9の商業化の試みとも言えるが、やはり広く普及することはなかった。

9frontは、Plan 9の最もアクティブなフォーク（派生プロジェクト）だ。ドライバの追加、x86-64ネイティブ対応、Wi-Fi/USB/オーディオサポート等を改善し、2026年現在もアクティブに開発が続いている。独特のコミュニティ文化——ジョークやミームに満ちたドキュメント——を持ち、技術的真面目さとサブカルチャー的なユーモアが共存している。

---

## 5. ハンズオン：Plan 9の世界を体験する

このハンズオンでは、Plan 9のアイデアがLinuxにどのように流入しているかを実際に体験する。9frontをQEMUで起動するオプションと、LinuxのnamespacesやFUSE等でPlan 9の概念を体感するオプションの両方を提供する。

### 環境構築

```bash
# Ubuntu 24.04のDocker環境を使用
docker pull ubuntu:24.04
```

### 演習1：Linux namespacesでPlan 9のper-process名前空間を体験する

Plan 9のper-process名前空間の概念が、Linuxのnamespace機能としてどう実現されているかを確認する。

```bash
docker run --rm --privileged ubuntu:24.04 bash -c '
echo "=== Plan 9のper-process名前空間 → Linux namespaces ==="
echo ""
echo "Plan 9では各プロセスが独自のファイルシステム名前空間を持つ。"
echo "Linuxのunshare(2)は、この概念を実装したシステムコールだ。"
echo ""

echo "--- 現在のnamespace情報 ---"
ls -la /proc/self/ns/ 2>/dev/null || echo "(情報取得不可)"
echo ""

echo "--- Linux namespaceの種類とPlan 9との対応 ---"
echo ""
echo "Linux namespace   導入時期        Plan 9との対応"
echo "─────────────────────────────────────────────────────────"
echo "mount (mnt)       2002 (2.4.19)   per-process名前空間の直接的実装"
echo "UTS               2006 (2.6.19)   (UNIXの機能、Plan 9には直接対応なし)"
echo "IPC               2006 (2.6.19)   Plan 9では9Pで代替"
echo "PID               2008 (2.6.24)   Plan 9のrfork(RFPROC)に対応"
echo "network (net)     2009 (2.6.29)   Plan 9の/netに対応"
echo "user              2013 (3.8)      (Plan 9には直接対応なし)"
echo "cgroup            2016 (4.6)      (Plan 9には直接対応なし)"
echo "time              2020 (5.6)      (Plan 9には直接対応なし)"
echo ""

echo "--- rfork() vs clone() vs unshare() ---"
echo ""
echo "Plan 9: rfork(flags)"
echo "  RFNAMEG  名前空間を共有     RFCNAMEG  名前空間をコピー"
echo "  RFFDG    FDテーブルをコピー  RFMEM     メモリを共有"
echo "  RFPROC   新プロセスを作成    RFNOWAIT  親がwaitしない"
echo ""
echo "Linux: clone(flags, ...)"
echo "  CLONE_NEWNS    新しいmount namespace"
echo "  CLONE_NEWPID   新しいPID namespace"
echo "  CLONE_NEWNET   新しいnetwork namespace"
echo "  CLONE_NEWUSER  新しいuser namespace"
echo ""
echo "Linux: unshare(flags)"
echo "  → 既存プロセスの名前空間を分離（rforkのコピー操作に相当）"
'
```

### 演習2：mount namespaceの分離を体験する

unshareコマンドでmount namespaceを分離し、Plan 9のper-process名前空間がLinuxでどう動作するかを確認する。

```bash
docker run --rm --privileged ubuntu:24.04 bash -c '
echo "=== mount namespaceの分離体験 ==="
echo ""

# tmpfsを作成して確認
mkdir -p /tmp/plan9-demo

echo "--- 通常のマウント（グローバルに見える）---"
mount -t tmpfs none /tmp/plan9-demo
echo "Plan 9 was here" > /tmp/plan9-demo/hello.txt
echo "マウント内容: $(cat /tmp/plan9-demo/hello.txt)"
umount /tmp/plan9-demo

echo ""
echo "--- unshareによるmount namespace分離 ---"
echo ""
echo "unshare --mount は、新しいmount namespaceでプロセスを起動する。"
echo "これはPlan 9のrfork(RFCNAMEG)に概念的に対応する。"
echo ""

# 新しいmount namespaceで操作
unshare --mount bash -c "
    # この中のマウント操作は外部に影響しない
    mount -t tmpfs none /tmp/plan9-demo
    echo \"Private namespace content\" > /tmp/plan9-demo/secret.txt
    echo \"namespace内: \$(cat /tmp/plan9-demo/secret.txt)\"
    echo \"この/tmp/plan9-demoは、このプロセスにしか見えない\"
"

# unshareの外からは見えない
echo ""
echo "namespace外: /tmp/plan9-demo の内容 = $(ls /tmp/plan9-demo 2>/dev/null || echo "(空)")"
echo "→ unshare内のマウントは外部に影響しない。これがper-process名前空間だ。"
echo ""

echo "=== この仕組みがDockerの基盤 ==="
echo "docker runは内部で以下のnamespacesを作成する:"
echo "  mount namespace  → コンテナ独自のファイルシステム"
echo "  PID namespace    → コンテナ内のPID 1"
echo "  network namespace → コンテナ独自のネットワーク"
echo "  UTS namespace    → コンテナ独自のホスト名"
echo ""
echo "Plan 9が1992年に実現したper-process名前空間が、"
echo "2013年のDockerを経て、現代のインフラの基盤になっている。"
'
```

### 演習3：9Pプロトコルの概念をLinux上で確認する

Linux上の9Pサポート（v9fs）と、/procファイルシステムを通じてPlan 9の「Everything is a file」の思想を体験する。

```bash
docker run --rm --privileged ubuntu:24.04 bash -c '
echo "=== Linux上のPlan 9の痕跡 ==="
echo ""

echo "--- /proc: Plan 9由来のプロセスファイルシステム ---"
echo ""
echo "Plan 9の/procは、プロセスの全状態をファイルとして公開する。"
echo "Linuxの/procはこの設計を受け継いでいる。"
echo ""

# 自分自身のプロセス情報をファイル操作で読む
PID=$$
echo "PID $PID のプロセス情報（/proc/$PID/配下のファイル）:"
echo ""
echo "  /proc/$PID/comm    = $(cat /proc/$PID/comm 2>/dev/null)"
echo "  /proc/$PID/cmdline = $(tr \"\\0\" \" \" < /proc/$PID/cmdline 2>/dev/null)"
echo "  /proc/$PID/status（抜粋）:"
head -5 /proc/$PID/status 2>/dev/null | sed "s/^/    /"
echo ""

echo "Plan 9では、プロセスの制御もファイル書き込みで行う:"
echo "  echo kill > /proc/PID/ctl   (プロセスを終了)"
echo "  echo stop > /proc/PID/ctl   (プロセスを停止)"
echo ""
echo "Linuxの /proc/PID/ はPlan 9ほど徹底していないが、"
echo "「プロセス情報をファイルとして公開する」という設計は同じだ。"
echo ""

echo "--- Linux カーネルの9Pサポート ---"
echo ""
echo "Linuxカーネルには9Pプロトコルのネイティブサポートが含まれる。"
echo "CONFIG_9P_FS=y/m でビルドすれば、Plan 9の9Pサーバを"
echo "Linuxから直接マウントできる。"
echo ""
echo "主な用途:"
echo "  - KVM/QEMUのVirtFS（ホスト-ゲスト間ファイル共有）"
echo "  - WSL2のWindows-Linux間ファイルアクセス（9P使用）"
echo "  - Plan 9 / 9frontとの直接通信"
echo ""

modinfo 9p 2>/dev/null && echo "→ 9Pモジュールがカーネルに存在" || \
  echo "→ 9Pモジュール情報取得不可（コンテナ内のため）"
echo ""

echo "--- WSL2と9P ---"
echo ""
echo "Windows上のWSL2がWindowsのファイルシステム（/mnt/c等）に"
echo "アクセスする際、内部的に9Pプロトコルが使われている。"
echo "Plan 9のプロトコルが、2020年代のWindows-Linux間通信を"
echo "支えているのだ。"
'
```

### 演習4：ユニオンマウントの概念をoverlayfsで体験する

Plan 9のユニオンマウントがLinuxのoverlayfsとしてどう実現されているかを体験する。

```bash
docker run --rm --privileged ubuntu:24.04 bash -c '
echo "=== Plan 9のユニオンマウント → Linux overlayfs ==="
echo ""
echo "Plan 9: bind -b /new /existing  (ユニオンマウント)"
echo "Linux:  mount -t overlay ...    (overlayfs)"
echo ""

# overlayfsの準備
mkdir -p /tmp/overlay-demo/{lower,upper,work,merged}

# 下位レイヤ（元のファイル）
echo "original content" > /tmp/overlay-demo/lower/base.txt
echo "will be hidden" > /tmp/overlay-demo/lower/override.txt

# 上位レイヤ（変更・追加）
echo "overridden content" > /tmp/overlay-demo/upper/override.txt
echo "new file" > /tmp/overlay-demo/upper/added.txt

echo "--- 下位レイヤ（lower）---"
ls -la /tmp/overlay-demo/lower/
echo ""

echo "--- 上位レイヤ（upper）---"
ls -la /tmp/overlay-demo/upper/
echo ""

# overlayfsでマウント
mount -t overlay overlay \
  -o lowerdir=/tmp/overlay-demo/lower,upperdir=/tmp/overlay-demo/upper,workdir=/tmp/overlay-demo/work \
  /tmp/overlay-demo/merged

echo "--- 統合結果（merged）---"
echo "Plan 9のユニオンマウントと同様に、複数のレイヤが一つに見える:"
echo ""
for f in /tmp/overlay-demo/merged/*; do
    echo "  $(basename $f): $(cat $f)"
done
echo ""

echo "=== Dockerイメージレイヤとの関係 ==="
echo ""
echo "Dockerイメージは複数のレイヤで構成される:"
echo ""
echo "  ┌─────────────────────┐"
echo "  │  コンテナ書き込み層  │ ← upper (読み書き可)"
echo "  ├─────────────────────┤"
echo "  │  アプリレイヤ        │ ← lower3 (読み取り専用)"
echo "  ├─────────────────────┤"
echo "  │  依存パッケージ      │ ← lower2"
echo "  ├─────────────────────┤"
echo "  │  ベースイメージ      │ ← lower1"
echo "  └─────────────────────┘"
echo ""
echo "overlayfsでこれらを一つのファイルシステムとして提示する。"
echo "Plan 9が1992年に実現したユニオンマウントの現代版だ。"

umount /tmp/overlay-demo/merged 2>/dev/null
'
```

### 演習5：UTF-8の自己同期性を確認する

Plan 9が生んだUTF-8の設計の巧妙さを、バイトレベルで確認する。

```bash
docker run --rm ubuntu:24.04 bash -c '
echo "=== UTF-8: Plan 9が世界に贈った文字エンコーディング ==="
echo ""
echo "UTF-8は1992年9月、Rob PikeとKen Thompsonが設計した。"
echo "Plan 9は完全なUTF-8サポートを持つ最初のOSだった。"
echo ""

# UTF-8のバイト列を確認
echo "--- 文字とUTF-8バイト列 ---"
echo ""
printf "A (U+0041): "; echo -n "A" | xxd -p
printf "あ (U+3042): "; echo -n "あ" | xxd -p
printf "漢 (U+6F22): "; echo -n "漢" | xxd -p
printf "🐰 (U+1F430): "; echo -n "🐰" | xxd -p
echo ""

echo "--- UTF-8の自己同期性 ---"
echo ""
echo "UTF-8の設計が巧妙な点は、バイト列のどこから読み始めても"
echo "文字の境界を検出できることだ:"
echo ""
echo "  先頭バイト:  0xxxxxxx (ASCII)     → 1バイト文字"
echo "               110xxxxx             → 2バイト文字の開始"
echo "               1110xxxx             → 3バイト文字の開始"
echo "               11110xxx             → 4バイト文字の開始"
echo "  継続バイト:  10xxxxxx             → 文字の途中"
echo ""
echo "どのバイトを見ても、それが文字の先頭か途中かを即座に判別できる。"
echo "これが自己同期性（self-synchronizing）だ。"
echo ""

echo "--- ASCII互換性の重要さ ---"
echo ""
echo "// C言語の文字列処理がそのまま動く"
echo "char *s = \"Hello, 世界\";"
echo "strlen(s);    // バイト数を返す（文字数ではない）"
echo "strchr(s, H); // ASCII文字の検索は正しく動く"
echo "strcmp(a, b);  // バイト列比較がUnicodeのコードポイント順と一致"
echo ""
echo "NULバイト（0x00）がU+0000以外に出現しないため、"
echo "C言語のNUL終端文字列とUTF-8は完全に互換だ。"
echo "これはPlan 9がC言語の世界で生まれたことの必然的帰結である。"

# 現在のロケール
echo ""
echo "--- このシステムのロケール ---"
locale 2>/dev/null | head -3 || echo "(locale情報取得不可)"
echo ""
echo "2026年現在、Webページの約99%がUTF-8でエンコードされている。"
echo "Plan 9が生んだ文字エンコーディングが、世界を支配した。"
'
```

---

## 6. まとめと次回予告

### この回の要点

Plan 9 from Bell Labs（1992年初公開）は、UNIXの設計者自身が「UNIXの次」として設計したOSだ。Rob Pike、Ken Thompson、Dave Presotto、Phil Winterbottom——UNIXとC言語を生んだBell Labsの研究グループが、UNIXの「Everything is a file」の不完全さを認識し、その理念を徹底しようとした。

Plan 9の三つの革新——9Pプロトコルによるすべてのリソースの統一的なファイルアクセス、per-process名前空間によるグローバル状態の排除、ユニオンマウントによる柔軟なファイルシステム合成——は、UNIXの設計を根本から再考した結果だ。そしてその「副産物」として生まれたUTF-8（1992年9月、Rob PikeとKen Thompsonがニュージャージーのダイナーで設計）は、2026年現在のWebページの約99%に使われる世界標準となった。

Plan 9はOSとしては「失敗」した。最大の敵は「十分に良い」UNIXだった。互換性の断絶、商用サポートの不在、遅すぎたオープンソース化、アプリケーションとドライバの不足が重なり、Plan 9はLinuxに取って代わることはできなかった。

だがPlan 9のアイデアは、形を変えてLinuxに深く浸透している。Linux namespaces（2002年〜、Dockerのコンテナ分離の基盤）はPlan 9のper-process名前空間に直接着想を得た。FUSE（ユーザ空間ファイルシステム）はPlan 9の「すべてをファイルシステムとして公開する」思想を受け継いだ。/procファイルシステムはPlan 9の設計を参照した。v9fs（Linux上の9P実装）はKVM/QEMUのファイル共有やWSL2のWindows-Linux間通信に使われている。overlayfs（Dockerのイメージレイヤの基盤）はPlan 9のユニオンマウントの現代版だ。

Plan 9が世界に与えた教訓は二つある。第一に、「正しい」設計が普及するとは限らない。既存のエコシステムの慣性と「十分に良い」既存の解は、技術的な優位性に勝ることがある。第二に、普及しなかった技術のアイデアは死なない。Plan 9はOSとしては普及しなかったが、そのDNAはLinux、Docker、UTF-8を通じて、現代のソフトウェアインフラストラクチャの隅々にまで浸透している。

### 冒頭の問いへの暫定回答

「UNIXの設計者自身が"UNIXの次"として作ったOSは、なぜ普及しなかったのか。」

技術の普及は、技術的優位性だけでは決まらない。エコシステム、タイミング、互換性、ライセンス、マーケティング——Plan 9が欠いていたのは技術ではなく、これらの「技術以外」の要素だった。UNIXは不完全だったが「十分に良い」OSとして巨大なエコシステムを構築し、Plan 9はそのエコシステムの慣性を突破できなかった。

だが「普及しなかった」ことと「影響を与えなかった」ことは別だ。Plan 9のアイデアは、個別の機能としてLinuxに吸収され、Docker、FUSE、UTF-8を通じて世界中のインフラストラクチャに浸透した。技術の影響力は採用数だけでは測れない。

### 次回予告

次回は「macOS――UNIXが消費者の手に届いた日」。世界で最も「身近な」UNIXの話だ。

1989年、Steve JobsがAppleを追放された後に設立したNeXTは、Machマイクロカーネルの上にBSD互換のユーザランドを載せたNeXTSTEPを開発した。Jobsが1997年にAppleに復帰し、NeXTSTEPの技術基盤がMac OS Xとなった。2001年3月にリリースされたMac OS X 10.0 "Cheetah"は、UNIXをGUIの下に隠し、消費者の手に届けた。2007年にはMac OS X 10.5 "Leopard"がUNIX 03認証を取得し、macOSは公式に「UNIX」を名乗れるOSとなった。

あなたが使っているMacのTerminal.appを開いて`uname`を打てば、「Darwin」と返ってくる。その下にはXNUカーネル——Machマイクロカーネルとフリーなカーネルの混成体——が動いている。macOSがなぜ開発者に好まれるのか。その答えの核心は、UNIXの力とGUIの洗練の共存にある。

---

## 参考文献

- Rob Pike, Dave Presotto, Sean Dorward, Bob Flandrena, Ken Thompson, Howard Trickey, Phil Winterbottom, "Plan 9 from Bell Labs", Computing Systems, 1995: <https://www.usenix.org/legacy/publications/compsystems/1995/sum_pike.pdf>
- Rob Pike, Dave Presotto, Ken Thompson, Howard Trickey, Phil Winterbottom, "The Use of Name Spaces in Plan 9", ACM SIGOPS European Workshop, 1992: <https://9p.io/sys/doc/names.html>
- Rob Pike, Ken Thompson, "Hello World or Kαληµε´ρα κο´σµε" (UTF-8 paper), 1993: <https://www.cl.cam.ac.uk/~mgk25/ucs/UTF-8-Plan9-paper.pdf>
- Rob Pike, "UTF-8 history" (email, 2003): <https://doc.cat-v.org/bell_labs/utf-8_history>
- Eric S. Raymond, "Plan 9: The Way the Future Was", The Art of UNIX Programming, 2003: <https://www.catb.org/esr/writings/taoup/html/plan9.html>
- Wikipedia, "Plan 9 from Bell Labs": <https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs>
- Wikipedia, "9P (protocol)": <https://en.wikipedia.org/wiki/9P_(protocol)>
- Wikipedia, "Linux namespaces": <https://en.wikipedia.org/wiki/Linux_namespaces>
- Wikipedia, "Filesystem in Userspace": <https://en.wikipedia.org/wiki/Filesystem_in_Userspace>
- Wikipedia, "UTF-8": <https://en.wikipedia.org/wiki/UTF-8>
- Plan 9 from Bell Labs公式サイト: <https://9p.io/plan9/about.html>
- Plan 9 Foundation: <https://www.plan9foundation.org/about.html>
- Linux Kernel Documentation, "v9fs: Plan 9 Resource Sharing for Linux": <https://www.kernel.org/doc/html/latest/filesystems/9p.html>
- Linux man pages, "namespaces(7)": <https://man7.org/linux/man-pages/man7/namespaces.7.html>
- Phoronix, "Plan 9 Copyright Transferred To Foundation, MIT Licensed Code Released", 2021: <https://www.phoronix.com/news/Plan-9-2021>
- The Register, "New version of Plan 9 fork 9front released", 2022: <https://www.theregister.com/2022/11/02/plan_9_fork_9front/>
- Drew DeVault, "In praise of Plan 9", 2022: <https://drewdevault.com/2022/11/12/In-praise-of-Plan-9.html>
