# UNIXという思想

## ——パイプ、プロセス、ファイル――すべてはここから始まった

### 第13回：「Linux誕生——Linus Torvaldsの"just a hobby"」

**連載「UNIXという思想——パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Linus Torvaldsがcomp.os.minixに投稿した1991年8月25日の原文と、その背景にあったMINIXとの関係
- Andrew TanenbaumのMINIX（1987年）——教育用OSがLinux誕生の直接的な触媒となった経緯
- Linux 0.01（1991年9月17日、10,239行）から1.0（1994年3月14日、176,250行）への成長過程
- Tanenbaum-Torvalds論争（1992年1月29日）——モノリシックカーネル vs マイクロカーネルの設計論争
- Linuxカーネルのアーキテクチャ——モノリシック設計の選択理由と、ローダブルカーネルモジュール（LKM）による拡張性の獲得
- GPLv2採用（1992年2月、Linux 0.12）の決定的意味——GNUツール群との結合を可能にした法的基盤
- VFS（Virtual File System）層の設計——UNIXの「すべてはファイルである」原則の継承
- Linuxカーネルのタスクスケジューラの進化——O(n)からO(1)、CFS、EEVDFへ

---

## 1. あの投稿を読んだ日

1999年の秋、私はSlackware 3.5のインストールに四苦八苦していた。カーネル2.0.34。CDROMから起動し、パーティションを手動で切り、パッケージを一つずつ選んでいく。インストールが終わっても、X Window Systemの設定が待っている。XF86Configを手で書き、モニタの水平・垂直同期周波数を調べ、`startx` と打って祈る。画面が映れば歓喜、映らなければviで設定ファイルを修正してやり直す。

そんな日々の中で、私はLinuxの「歴史」に興味を持ち始めた。ある日、Webブラウザで——おそらくNetscape Navigatorだったと思う——Linus Torvaldsの1991年の投稿を読んだ。comp.os.minixに投稿された、あの文章だ。

> I'm doing a (free) operating system (just a hobby, won't be big and professional like gnu) for 386(486) AT clones.

「趣味でOSを作っている。大きくもないし、gnuのようにプロフェッショナルでもない。」

この一文を読んだとき、私は自分が今使っているSlackwareの画面を見つめた。このOS——カーネルのコンパイルに何時間もかかり、設定ファイルの一行を間違えればブートしなくなる、このOSが、一人の大学生の「趣味」から始まったのだ。

しかも、Torvaldsは当時21歳だった。1969年12月28日にフィンランド・ヘルシンキで生まれ、ヘルシンキ大学でコンピュータサイエンスを学んでいた学生だ。当時の私は26歳で、まだLinuxのインストールすらまともにできていなかった。自分より年下の人間が、世界を変えるOSカーネルを「趣味で」書き始めていた——その事実に、複雑な感情を覚えた。

だがこの投稿には、もう一つ重要な情報が含まれていた。

> I've currently ported bash(1.08) and gcc(1.40), and things seem to work.

Bash 1.08とGCC 1.40。つまり、GNUのツールだ。前回（第12回）で見たように、GNUプロジェクトが10年近くかけて構築してきたユーザランドのツール群が、ここで合流している。Torvaldsはカーネルを書いた。だがそのカーネルの上で動く最初のプログラムは、GNUの成果物だった。

なぜフィンランドの大学生が作ったOSカーネルが、世界を制覇したのか。それは偶然ではない。それ以前のすべての歴史——UNIXの設計哲学、GNUプロジェクトのツール群、GPLのライセンス設計、そしてインターネットというコラボレーション基盤——が一点に収束した結果だ。

あなたが今日使っているLinux——Docker内で動いているカーネル、AWSのEC2インスタンスを支えるカーネル、Androidスマートフォンの中枢——それはすべて、1991年8月25日の「趣味」から始まっている。

---

## 2. MINIXという揺りかご

### Andrew Tanenbaumの教室

Linuxの誕生を理解するためには、まずMINIXを理解しなければならない。

1987年、アムステルダム自由大学（Vrije Universiteit）のコンピュータサイエンス教授Andrew S. Tanenbaumは、教科書『Operating Systems: Design and Implementation』をPrentice Hallから出版した。この教科書には、MINIXと名付けられたUNIX互換の小型OSのソースコードが付属していた。

Tanenbaumの動機は明確だった。1980年代、AT&TがUNIXのライセンス条件を厳格化したことで（第11回参照）、大学でUNIXのソースコードを教材として使うことが困難になっていた。John Lionsの伝説的な著書『Lions' Commentary on UNIX 6th Edition, with Source Code』（1977年）のように、UNIXのソースコードを解説する書籍はあったが、ライセンス上の理由から自由に配布できない状況になっていた。Tanenbaumはこの問題を、自分でUNIX互換OSを書くことで解決した。

MINIXは教育用に設計された。小さく、読みやすく、理解しやすいことが最優先だった。だがその技術的な設計選択は、後にLinuxとの対比で歴史的な意味を持つことになる。

MINIXはマイクロカーネルアーキテクチャを採用していた。ファイルシステム、メモリ管理、プロセス管理などのOS機能を、カーネル空間ではなくユーザ空間のサーバプロセスとして実装する。カーネル自体は最小限の機能——プロセス間通信（IPC）とスケジューリング——のみを担う。この設計は理論的に美しい。各コンポーネントが独立しているため、一つのサーバが落ちてもカーネル全体が落ちない。デバッグも容易だ。

だが実用上の問題があった。MINIXはIntel 8086を対象に設計されており、1991年時点で普及していた386プロセッサの機能——保護モード、仮想メモリ——を十分に活用していなかった。ライセンスも教育利用を想定しており、自由に改変・再配布できる状態ではなかった（2000年にBSD 3-Clauseに変更されるまでプロプライエタリなソースアベイラブルライセンスだった）。

### Torvaldsとの出会い

Linus Torvaldsは1990年秋、ヘルシンキ大学でTanenbaumの教科書に出会った。Torvaldsは後にこの本を「the book that launched me to new heights」と自伝『Just for Fun: The Story of an Accidental Revolutionary』（2001年、David Diamondとの共著）で振り返っている。

Torvaldsの背景を理解しておくことは重要だ。彼は11歳の1981年にCommodore VIC-20でプログラミングを始め、BASICから6502 CPUの機械語に進んだ。その後Sinclair QLを購入し、ハードウェアとOSを徹底的に改造した。フィンランドではQLのソフトウェアが入手困難だったため、アセンブラやゲームを自作した。

1988年にヘルシンキ大学に入学し、1989年にフィンランド海軍での兵役（11か月の士官訓練）を経て、大学に戻った。1990年、C言語とUNIXのプログラミングの講義を受け、TanenbaumのMINIXに出会う。そして1991年初頭、個人用のDX33（Intel 386、33MHz）マシンにMINIXをインストールした。

MINIXを使いながら、Torvaldsは不満を感じ始めた。ターミナルエミュレータの機能が不足していた。大学のUNIXサーバに接続するためのモデム制御とファイルのダウンロードに、もっと良い端末プログラムが必要だった。そこでTorvaldsはMINIX上でターミナルエミュレータを書き始めた。だがそのプログラムはMINIXの制約を超え始め、ハードウェアを直接制御するコードになっていった。ディスクドライバを書き、ファイルシステムを実装し——気がつけば、それはOSカーネルになっていた。

これは設計から始まったプロジェクトではない。実用的な必要性から、一歩ずつ積み上げていった結果だ。Torvalds自身の言葉を借りれば「just a hobby」——趣味だった。

### 1991年8月25日——comp.os.minixへの投稿

1991年8月25日20:57:08 GMT、TorvaldsはUsenetのcomp.os.minixニュースグループに投稿した。件名は「What would you like to see most in minix?」。

投稿の全文を引用する価値がある核心部分はこうだ。

> Hello everybody out there using minix -
>
> I'm doing a (free) operating system (just a hobby, won't be big and professional like gnu) for 386(486) AT clones. This has been brewing since april, and is starting to get ready. I'd like any feedback on things people like/dislike in minix, as my OS resembles it somewhat (same physical layout of the file-system (due to practical reasons) among other things).

「私は（フリーな）オペレーティングシステムを作っている（趣味でやっているだけで、gnuのように大きくもプロフェッショナルでもない）。386(486)のATクローン用だ。4月からずっと取り組んでいて、そろそろ準備ができてきた。」

そして追伸にこう書いた。

> PS. Yes - it's free of any minix code, and it has a multi-threaded fs. It is NOT portable (uses 386 task switching etc), and it probably never will support anything other than AT-harddisks, as that's all I have :-(

「MINIXのコードは一切含んでいない。マルチスレッドのファイルシステムを持つ。ポータブルではない（386のタスクスイッチング等を使っている）し、おそらくATハードディスク以外はサポートしないだろう。それしか持っていないから :-(」

この投稿には、後から振り返ると歴史的な皮肉がいくつも含まれている。

第一に、「won't be big and professional like gnu」。2026年現在、LinuxカーネルはTop500スーパーコンピュータの100%で動作し、Androidを通じて世界のモバイル端末の大多数を支え、クラウドインフラストラクチャの事実上の標準となっている。「大きくならない」どころか、ソフトウェア史上最も広く展開されたOSカーネルになった。

第二に、「it probably never will support anything other than AT-harddisks」。Linuxカーネルは現在、x86、ARM、RISC-V、PowerPC、s390xなど数十のアーキテクチャをサポートし、スマートフォンから宇宙ステーションまで、あらゆるハードウェアで動作している。

第三に、「it's free of any minix code」。これは後のTanenbaum-Torvalds論争の伏線でもある。Torvaldsのカーネルは、MINIXのコードを一行も含んでいない。だが設計の影響——特にファイルシステムの物理レイアウト——は明確に受けている。

---

## 3. モノリシックカーネルという「退行」

### 1991年9月17日——Linux 0.01

投稿から約3週間後の1991年9月17日、TorvaldsはLinux 0.01のソースコードをFUNET（Finnish University and Research Network）のFTPサーバ ftp.funet.fi にアップロードした。

Linux 0.01は10,239行のコードで構成されていた。比較のために言えば、当時のMINIXのカーネルは約12,000行だった。0.01はまだ自己ホスティング不可能で、コンパイルするためにMINIX環境が必要だった。動作するプログラムはGNU Bashのバイナリが含まれていた——カーネルの最初のユーザ空間プログラムが、GNUプロジェクトの成果物だったことは象徴的だ。

1991年10月5日、TorvaldsはLinux 0.02をcomp.os.minixで公式に発表した。これが事実上の最初の公開リリースだ。「bash/gcc/gnu-make/gnu-sed/compress等が動作する」と報告された。ここでもGNUのツール群が登場する。LinuxカーネルはGNUのエコシステムの上で産声を上げた。

### Torvaldsの設計選択——モノリシック

Torvaldsが選んだのはモノリシックカーネルだった。ファイルシステム、デバイスドライバ、プロセス管理、メモリ管理——すべてをカーネル空間で一つのアドレス空間内に実装する。MINIXのマイクロカーネルアーキテクチャとは対照的な選択だ。

なぜモノリシックを選んだのか。Torvaldsの答えは実用的だった。モノリシックカーネルはシンプルで、高速で、実装しやすい。マイクロカーネルの利点——コンポーネント間の分離、障害の局所化——は理論的には魅力的だが、その代償としてプロセス間通信（IPC）のオーバーヘッドが発生する。ユーザ空間のサーバプロセスとカーネル間のコンテキストスイッチは、パフォーマンスに直接響く。

```
モノリシックカーネル vs マイクロカーネル:

  モノリシックカーネル（Linux）:
  ┌─────────────────────────────────────────────┐
  │            ユーザ空間                        │
  │  ┌─────────┐ ┌─────────┐ ┌───────────────┐ │
  │  │ シェル   │ │ アプリ  │ │ ユーティリティ│ │
  │  └────┬────┘ └────┬────┘ └──────┬────────┘ │
  ├───────┼───────────┼─────────────┼───────────┤
  │       │    システムコール         │           │
  │  ┌────┴───────────┴─────────────┴────────┐  │
  │  │         カーネル空間                   │  │
  │  │  ┌─────────┐ ┌──────────┐ ┌────────┐ │  │
  │  │  │ プロセス │ │ ファイル │ │デバイス│ │  │
  │  │  │ 管理     │ │ システム │ │ドライバ│ │  │
  │  │  ├─────────┤ ├──────────┤ ├────────┤ │  │
  │  │  │ メモリ   │ │ネットワーク│ │ IPC  │ │  │
  │  │  │ 管理     │ │ スタック  │ │      │ │  │
  │  │  └─────────┘ └──────────┘ └────────┘ │  │
  │  └───────────────────────────────────────┘  │
  │  → 全機能が同一アドレス空間で動作            │
  │  → 関数呼び出しで通信（高速）               │
  │  → 一つのバグがカーネル全体をクラッシュ可能 │
  └─────────────────────────────────────────────┘

  マイクロカーネル（MINIX, GNU Hurd）:
  ┌─────────────────────────────────────────────┐
  │            ユーザ空間                        │
  │  ┌─────────┐ ┌──────────┐ ┌──────────────┐ │
  │  │ シェル   │ │ ファイル │ │ デバイス     │ │
  │  │         │ │ サーバ   │ │ ドライバ     │ │
  │  └────┬────┘ └────┬────┘ └──────┬────────┘ │
  │       │    IPC    │      IPC    │           │
  ├───────┼───────────┼─────────────┼───────────┤
  │  ┌────┴───────────┴─────────────┴────────┐  │
  │  │     マイクロカーネル（最小限）          │  │
  │  │  ┌─────────┐ ┌──────────┐             │  │
  │  │  │ IPC     │ │ スケジュ │             │  │
  │  │  │         │ │ ーリング │             │  │
  │  │  └─────────┘ └──────────┘             │  │
  │  └───────────────────────────────────────┘  │
  │  → OS機能の大半がユーザ空間で動作           │
  │  → IPC経由で通信（オーバーヘッドあり）      │
  │  → サーバ障害がカーネルをクラッシュしない   │
  └─────────────────────────────────────────────┘
```

この設計選択は、UNIXの歴史における一つの岐路だった。UNIXの初期の設計者たちが選んだモノリシックカーネルという路線を、Torvaldsは継承した。一方、MINIXのTanenbaumやGNU HurdのStallmanは、マイクロカーネルという「次の世代」のアーキテクチャを志向していた。

### 1992年1月29日——「LINUX is obsolete」

1992年1月29日、Andrew TanenbaumはUsenet comp.os.minixに「LINUX is obsolete」（LINUXは時代遅れだ）という件名で投稿した。この投稿は、OS設計の歴史における最も有名な論争の一つとなった。

Tanenbaumの主張は明快だった。モノリシックカーネルを1991年に設計することは「1970年代への巨大な後退」であり、OSの設計は必然的にマイクロカーネルに向かう。Linuxはx86アーキテクチャに密結合しており、移植性がない。教育的にも、モノリシックカーネルは「間違った」設計だ。

Torvaldsは翌日応答した。マイクロカーネルの「理論的・美学的」優位性は認めつつも、実用性——実際に動き、実際のハードウェアで使えるカーネル——を優先した立場を表明した。MINIXのマルチスレッドの不在を具体的な設計上の欠陥として指摘した。

この論争にはPeter MacDonald、David S. Miller、Theodore Ts'oら複数の開発者が参加し、カーネル設計だけでなくプロセッサアーキテクチャの将来についても議論が展開された。

歴史はTorvaldsの側に立った——少なくとも実用的な意味においては。30年以上経った現在もLinuxはモノリシックカーネルであり、世界の大半のサーバとモバイルデバイスで動作している。GNU Hurdは2026年現在も正式リリースに至っていない。MINIXは2005年にMINIX 3として信頼性重視のマイクロカーネルに再設計されたが、汎用OSとしての採用は限定的だ。

だが、Tanenbaumの主張が「間違っていた」と断じるのは単純すぎる。マイクロカーネルの思想は、macOSのXNUカーネル（Machマイクロカーネル + FreeBSD）、QNX、seL4といったシステムに生き続けている。Linuxカーネル自体も、ローダブルカーネルモジュール（LKM）という妥協を通じて、モノリシックカーネルの硬直性を緩和してきた。設計思想の「正しさ」は、一つの指標だけでは測れない。

### GPLv2の採用——1992年の転換点

Torvaldsが初期のLinuxカーネルに付していたライセンスは、独自のものだった。「ソースコードの完全な公開」を義務付けつつ、「金銭の授受を禁止」していた。この制約は問題を生んだ。ユーザグループでのミーティングでLinuxのコピーを配布する際、ディスクの実費すら回収できなかったのだ。

1992年1月、Linux 0.12のリリースに際して、TorvaldsはGPLv2（GNU General Public License Version 2）を採用した。GPLは1992年2月1日から発効した。Torvaldsは後にこう述べている。「making Linux GPLed was definitely the best thing I ever did.」（LinuxをGPLにしたのは、間違いなく私がやった中で最良のことだった。）

GPLv2の採用は三つの決定的な意味を持った。

第一に、商用配布の道を開いた。GPLv2はソースコードの公開を義務付けるが、商用利用を禁止しない。これにより、後にRed Hat、SUSE、DebianプロジェクトなどがLinuxディストリビューションを配布・販売することが可能になった。

第二に、貢献者の安心を確保した。GPLv2のコピーレフト条項により、自分が書いたコードが第三者にクローズドにされることがないという保証が生まれた。企業も個人も、安心してLinuxカーネルにコードを貢献できるようになった。前回（第12回）で見たGPLの設計思想が、ここで具体的な効果を発揮した。

第三に、GNUのエコシステムとの法的な整合性が確立された。GCC、Bash、coreutils——これらGPLで配布されているGNUツール群と、同じGPLv2のLinuxカーネルが組み合わさることで、法的に一貫した自由なOSが成立した。

ただし、TorvaldsはGPLv2の「only」条項を選択した。「GPLv2、またはそれ以降のバージョン」（or any later version）ではなく、「GPLv2のみ」（GPLv2 only）だ。この選択は2007年のGPLv3リリース時に重要な意味を持つことになる（第12回参照）。

---

## 4. Linuxカーネルのアーキテクチャ——UNIXの遺産と独自の進化

### UNIXからの継承

Linuxカーネルは、UNIXの設計原則を多くの点で継承している。だがそれは機械的なコピーではなく、UNIXの思想を1990年代のハードウェアと要求に合わせて再解釈したものだ。

**プロセスモデル。** Linuxのプロセスモデルは、UNIXの`fork()`/`exec()`パラダイムを直接受け継いでいる。`fork()`で親プロセスを複製し、`exec()`で新しいプログラムに置き換える。このモデルはUNIX V1（1971年）から存在するもので、Linuxはこれを忠実に実装した。さらにLinuxは`clone()`システムコールを導入し、スレッドとプロセスを統一的に扱えるようにした。Linuxにおけるスレッドは「アドレス空間を共有する軽量プロセス」であり、カーネル内部では通常のプロセスと同じ`task_struct`構造体で管理される。

**VFS（Virtual File System）層。** 第6回で見た「すべてはファイルである」の原則を、LinuxはVFS層として実装している。VFSは具体的なファイルシステム（ext4、XFS、btrfs、NFS等）の上に抽象化レイヤーを提供し、ユーザ空間のプログラムが`open()`、`read()`、`write()`、`close()`という統一的なインタフェースで、異なるファイルシステムに透過的にアクセスできるようにする。

VFSの内部構造は四つの主要なオブジェクトで構成される。

```
Linux VFSの主要オブジェクト:

  superblock（スーパーブロック）
    └── マウントされたファイルシステムの情報を保持
    └── struct super_block / struct super_operations

  inode（アイノード）
    └── ファイルの実体（メタデータ）を表現
    └── パーミッション、サイズ、タイムスタンプ等
    └── struct inode / struct inode_operations

  dentry（ディレクトリエントリ）
    └── パスの各要素をinodeに関連付ける
    └── /bin/vi → "/" + "bin" + "vi" の3つのdentry
    └── struct dentry / struct dentry_operations
    └── dcache（dentryキャッシュ）で高速化

  file（ファイル）
    └── プロセスがopenしたファイルを表現
    └── ファイルディスクリプタに対応
    └── struct file / struct file_operations
```

このオブジェクト指向的な設計により、新しいファイルシステムの追加は、VFSのインタフェースに合わせた関数群を実装するだけで済む。カーネルの他の部分は変更不要だ。これはまさにUNIXの「統一的なインタフェース」の原則を、コードレベルで実現している。

**`/proc` ファイルシステム。** LinuxはUNIXの「すべてはファイルである」をさらに拡張し、カーネルの内部状態をファイルとして公開する`/proc`ファイルシステムを実装した（1992年、Linux 0.98以降）。プロセスの状態（`/proc/[pid]/status`）、メモリマップ（`/proc/[pid]/maps`）、CPU情報（`/proc/cpuinfo`）——これらをファイル操作で読み取れる。後に`/sys`ファイルシステム（sysfs、2004年のLinux 2.6系列で導入）が加わり、デバイスとドライバのツリー構造がファイルシステムとして表現されるようになった。

### 独自の進化——ローダブルカーネルモジュール

モノリシックカーネルの最大の弱点は、新しいハードウェアのサポートやファイルシステムの追加のためにカーネルを再コンパイルしなければならないことだ。Linuxはこの問題を、ローダブルカーネルモジュール（LKM: Loadable Kernel Module）で解決した。

LKMは、実行中のカーネルに動的にロード・アンロードできるオブジェクトファイルだ。デバイスドライバ、ファイルシステム、ネットワークプロトコル——カーネルの機能の大部分は、現代のLinuxディストリビューションではLKMとして実装されている。`/lib/modules/` 以下に配置され、`modprobe` コマンドでロードされる。Linux 2.6以降、モジュールファイルの拡張子は`.o`から`.ko`（kernel object）に変更された。

これはモノリシックカーネルとマイクロカーネルの中間的な解と見ることができる。カーネルの基本部分はモノリシックだが、機能の追加・削除はカーネルの再コンパイルなしに動的に行える。マイクロカーネルのような障害の局所化は得られないが、実用的な拡張性をモノリシックカーネルのパフォーマンスと両立させている。

### タスクスケジューラの進化

Linuxカーネルの内部で最も劇的な進化を遂げたコンポーネントの一つが、タスクスケジューラだ。

Linux 0.01のスケジューラは素朴だった。実行可能なプロセスのリストを線形に走査し、最も優先度の高いプロセスを選ぶ。計算量はO(n)——プロセス数に比例する。プロセスが少ない環境では問題なかったが、サーバワークロードでプロセス数が増えるとスケーリングしない。

2003年、Linux 2.6.0でIngo MolnárのO(1)スケジューラが採用された。名前の通り、プロセス数に関係なく一定時間でスケジューリング判断を行う。active/expiredの二つのランキューと、ビットマップによる優先度管理で実現された。サーバワークロードのスケーラビリティは劇的に向上したが、デスクトップ環境でのインタラクティブ応答性に課題が残った。

2007年、Linux 2.6.23でCFS（Completely Fair Scheduler）が導入された。Con Kolivasのインタラクティブスケジューリングの研究に触発されて、Ingo Molnárが設計した。CFSは赤黒木（red-black tree）を使い、各プロセスに「仮想ランタイム」を割り当てる。仮想ランタイムが最も少ないプロセスが次に実行される。計算量はO(log n)。理論的な「公平さ」と実用的なパフォーマンスの両立を目指した設計だ。

そして2023年、Linux 6.6でEEVDF（Earliest Eligible Virtual Deadline First）がCFSを置き換えた。スケジューリングの「レイテンシの公平性」をさらに改善する設計だ。

```
Linuxスケジューラの進化:

  v0.01〜v2.4.x   O(n)スケジューラ
                    └── 線形走査、シンプルだがスケールしない
                         │
  v2.6.0〜v2.6.22  O(1)スケジューラ（Ingo Molnár、2003年）
                    └── 一定時間スケジューリング
                    └── サーバ性能は向上、デスクトップに課題
                         │
  v2.6.23〜v6.5    CFS（Ingo Molnár、2007年）
                    └── 赤黒木ベース、O(log n)
                    └── 「完全に公平な」スケジューリング
                         │
  v6.6〜           EEVDF（2023年）
                    └── CFSの後継
                    └── レイテンシの公平性を改善
```

このスケジューラの進化は、Linuxカーネルの設計哲学の一端を示している。Torvaldsの実用主義——理論的な最適解よりも、実際のワークロードで「十分に良い」解を選び、問題が明らかになったら改善する。UNIXの「シンプルに始めて、必要に応じて複雑さを追加する」原則の実践だ。

### 0.01から40,000,000行へ

Linuxカーネルの成長は驚異的だ。

1991年9月のLinux 0.01は10,239行だった。1994年3月のLinux 1.0.0は176,250行。1996年6月のLinux 2.0（初のSMP対応）はさらに大きくなった。そして2025年1月、Linux 6.14 rc1は4,000万行を超えた。

10,239行から4,000万行へ。約3,900倍の成長。この数字は、一人の大学生の「趣味」が、いかにして世界最大のソフトウェアプロジェクトの一つになったかを物語っている。

2024年時点で、Linuxカーネルには約4,800人の開発者が年間で貢献している。企業による貢献が84.3%を占め、Intel（13.1%）、Red Hat（7.2%）、Linaro（5.6%）、IBM（4.1%）などが主要な貢献企業だ。Greg Kroah-Hartmanは2025年時点で最もアクティブな個人メンテナであり、6,800件以上のコミットを記録している。

Linuxカーネルは、もはや一人の人間のプロジェクトではない。だがその設計の核——モノリシックカーネル、UNIX互換のシステムコール、VFS層——は、1991年のTorvaldsの選択から一貫している。

---

## 5. ハンズオン：Linuxカーネルに触れる

このハンズオンでは、Linuxカーネルのソースコードを取得し、最小構成でのコンパイルを体験した後、カーネルモジュールを自作してロードする。UNIXの「小さなプログラムを組み合わせる」思想が、カーネルレベルでどう表現されているかを、手を動かして理解する。

### 環境構築

Docker上にUbuntu 24.04環境を準備する。カーネルのコンパイルには開発ツール一式が必要だ。

```bash
docker run -it --rm --privileged ubuntu:24.04 bash
```

`--privileged` フラグは、カーネルモジュールのロードに必要だ。

```bash
# 必要なパッケージをインストール
apt-get update && apt-get install -y \
  build-essential \
  linux-headers-$(uname -r) \
  git \
  bc \
  flex \
  bison \
  libelf-dev \
  libssl-dev \
  kmod
```

### 演習1：カーネルバージョンの確認とカーネルの内部構造の探索

まず、現在動作しているカーネルの情報を確認する。

```bash
# カーネルバージョンの確認
uname -r
uname -a

# カーネルのブートパラメータ
cat /proc/cmdline

# CPUの情報（UNIXの「すべてはファイルである」原則）
cat /proc/cpuinfo | head -20

# メモリの情報
cat /proc/meminfo | head -10

# ロードされているカーネルモジュールの一覧
lsmod | head -20

# カーネルモジュールの数
lsmod | wc -l
```

`/proc` ファイルシステムを通じて、カーネルの内部状態がファイルとして読み取れる。これがUNIXの「すべてはファイルである」原則のLinuxにおける実践だ。

### 演習2：Linuxカーネルのソースコードを探索する

カーネルのソースコードの構造を確認することで、モノリシックカーネルの設計を理解する。

```bash
# カーネルのソースツリーを取得（浅いクローン、最新のみ）
cd /tmp
git clone --depth 1 https://github.com/torvalds/linux.git
cd linux

# ソースツリーのトップレベル構造
ls -d */
```

出力されるディレクトリの意味を理解する。

```bash
# 各ディレクトリの役割:
# arch/     - アーキテクチャ固有のコード（x86, arm, riscv等）
# drivers/  - デバイスドライバ（コード量の最大部分）
# fs/       - ファイルシステム（ext4, xfs, btrfs, proc等）
# kernel/   - カーネルのコア（スケジューラ、シグナル、fork等）
# mm/       - メモリ管理
# net/      - ネットワークスタック
# include/  - ヘッダファイル
# init/     - カーネルの初期化コード

# 全体のコード行数を概算する
find . -name '*.c' -o -name '*.h' | xargs wc -l 2>/dev/null | tail -1

# ドライバがコードの大部分を占めていることを確認
echo "=== drivers/ ==="
find drivers/ -name '*.c' | xargs wc -l 2>/dev/null | tail -1
echo "=== kernel/ ==="
find kernel/ -name '*.c' | xargs wc -l 2>/dev/null | tail -1
echo "=== fs/ ==="
find fs/ -name '*.c' | xargs wc -l 2>/dev/null | tail -1

# VFS層のコードを確認する
ls fs/*.c | head -10

# スケジューラのコードを確認する
ls kernel/sched/
wc -l kernel/sched/*.c
```

`drivers/` ディレクトリが圧倒的に大きいことがわかるだろう。モノリシックカーネルの「膨張」の主因はドライバだ。LKMの仕組みにより、すべてのドライバがカーネルにリンクされるわけではないが、ソースツリーには含まれている。

### 演習3：カーネルの最小構成コンパイル

カーネルを実際にコンパイルする。`tinyconfig` は利用可能な最小構成で、カーネルの本質的な部分だけをビルドする。

```bash
cd /tmp/linux

# 最小構成を生成
make tinyconfig

# コンパイル（並列ビルド）
# ※ Docker環境ではCPUコア数に応じて調整
make -j$(nproc) 2>&1 | tail -20

# 生成されたカーネルイメージのサイズを確認
ls -lh arch/x86/boot/bzImage 2>/dev/null || \
ls -lh vmlinux
```

`tinyconfig` でビルドされたカーネルは非常に小さい。これはLinuxカーネルの本質——必要な機能だけを選択してビルドできる——を示している。0.01の10,239行は、この原則の極端な表現だった。

### 演習4：カーネルモジュールの自作

LKMの仕組みを体験する。最もシンプルなカーネルモジュールを書き、ロードし、アンロードする。

```bash
# 作業ディレクトリを作成
mkdir -p /tmp/hello_module && cd /tmp/hello_module

# カーネルモジュールのソースコードを作成
cat > hello.c << 'EOF'
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("handson");
MODULE_DESCRIPTION("A simple hello world kernel module");
MODULE_VERSION("0.1");

static int __init hello_init(void)
{
    printk(KERN_INFO "Hello from kernel module! This is LKM in action.\n");
    return 0;
}

static void __exit hello_exit(void)
{
    printk(KERN_INFO "Goodbye from kernel module! LKM unloaded.\n");
}

module_init(hello_init);
module_exit(hello_exit);
EOF

# Makefileを作成（Makefileのレシピ行にはタブ文字が必要）
cat > Makefile << 'EOF'
obj-m += hello.o

KDIR ?= /lib/modules/$(shell uname -r)/build

all:
    make -C $(KDIR) M=$(PWD) modules

clean:
    make -C $(KDIR) M=$(PWD) clean
EOF
# Makefileのインデントをタブに変換（Makeの構文要件）
sed -i 's/^    /\t/' Makefile

# コンパイル
make

# モジュールのロード
insmod hello.ko

# カーネルログで出力を確認
dmesg | tail -5

# モジュールがロードされていることを確認
lsmod | grep hello

# モジュールの情報を表示
modinfo hello.ko

# モジュールのアンロード
rmmod hello

# アンロード時のメッセージを確認
dmesg | tail -5
```

`insmod` でモジュールをロードし、`rmmod` でアンロードする。`printk()` はカーネル空間のログ出力関数で、ユーザ空間の `printf()` に相当する。このモジュールのロード・アンロードの仕組みが、Linuxのモノリシックカーネルに拡張性を与えているLKMの実体だ。

### 演習5：/procファイルシステムとの対話

`/proc` ファイルシステムを通じて、カーネルの内部状態をファイル操作で読み取る体験をする。UNIXの「すべてはファイルである」原則が、Linuxでどう実現されているかの具体例だ。

```bash
# 現在のプロセスの情報を/procから読み取る
# 自分のシェルのPIDを取得
echo $$

# そのプロセスのステータス
cat /proc/$$/status | head -15

# プロセスのメモリマップ
cat /proc/$$/maps | head -10

# プロセスのファイルディスクリプタ一覧
ls -la /proc/$$/fd/

# カーネルのバージョン情報
cat /proc/version

# システム全体の統計
cat /proc/stat | head -5

# マウントされたファイルシステム
cat /proc/mounts | head -10

# /proc配下のファイルは「ファイル」として見えるが、
# ディスク上に実体はない。カーネルが動的に生成している
stat /proc/cpuinfo
```

`/proc` のファイルはディスク上に存在しない。カーネルが `read()` システムコールのタイミングで動的に内容を生成する。これはUNIXの「すべてはファイルである」原則を、Linux独自の方法で拡張した設計だ。第6回で見たPlan 9の9Pプロトコルの影響が、ここに見える。

---

## 6. まとめと次回予告

### この回の要点

Linuxの誕生は偶然ではない。それ以前のすべての歴史が収束した必然だった。

1991年8月25日、ヘルシンキ大学の21歳の学生Linus Torvaldsが、comp.os.minixに「趣味でOSを作っている」と投稿した。その「趣味のプロジェクト」は、GNUプロジェクトが10年かけて構築したユーザランドのツール群（GCC、Bash、coreutils）と結合し、GPLv2のライセンスによって法的に一貫した自由なOSとなり、インターネットを通じた分散型のコラボレーションで急速に成長した。

Torvaldsがモノリシックカーネルを選んだことは、Tanenbaumから「1970年代への後退」と批判された。だが実用性を優先するこの選択は、結果として正しかった——少なくとも、広範な採用と継続的な進化という指標においては。ローダブルカーネルモジュール（LKM）の仕組みにより、モノリシックカーネルの硬直性は緩和され、実用的な拡張性が確保された。

LinuxカーネルはUNIXの設計原則——`fork()`/`exec()`によるプロセスモデル、VFSによるファイルシステム抽象化、`/proc`による「すべてはファイルである」の拡張——を継承しつつ、独自の進化を遂げてきた。タスクスケジューラはO(n)からO(1)、CFS、EEVDFへと進化し、10,239行から4,000万行を超えるソースコードへと成長した。

GPLv2の採用（1992年、Linux 0.12）は、Torvalds自身が「やった中で最良のこと」と認める決断だった。GNUプロジェクトのツール群とLinuxカーネルを法的に結合し、商用利用の道を開き、貢献者の権利を保護した。技術だけでなく、ライセンスの選択がソフトウェアの運命を左右する——前回のGPLの歴史が、ここで具体的な結果を生んだ。

### 冒頭の問いへの暫定回答

「なぜフィンランドの大学生が作ったOSカーネルが、世界を制覇したのか？」

技術的な優位性だけでは説明できない。Torvaldsのカーネルが世界を制覇した要因は、いくつかの歴史的条件の収束にある。第一に、GNUプロジェクトが「カーネル以外のすべて」を用意していた。第二に、GPLv2が商用利用を許容しつつソースコードの公開を保証する、絶妙な均衡点を提供した。第三に、インターネット——特にUsenetとFTP——というグローバルなコラボレーション基盤が存在した。第四に、386プロセッサの普及により、手頃な価格のPCでUNIX互換環境が動作するようになっていた。第五に、商用UNIXの高価格とライセンス制約に対する不満が広がっていた。

Torvaldsは天才だ。だが天才は歴史の文脈の中で天才になる。UNIXの設計哲学、GNUの自由なツール群、GPLの法的フレームワーク、インターネットの通信基盤、そしてx86ハードウェアの普及——これらすべてが揃った1991年という時代が、Torvaldsの「趣味」を世界標準に押し上げた。

あなたが今日 `docker run` と打つとき、その裏で動いているLinuxカーネルは、一人の大学生が32年前に「just a hobby」として始めたプロジェクトの直系の子孫だ。その事実を知っているかどうかで、あなたがトラブルに直面したときの対処能力は変わる。

### 次回予告

次回は「ディストリビューション戦争——多様性というUNIXの遺伝子」。Linuxカーネルが存在しても、それだけではユーザが使えるOSにはならない。カーネルの上に何を載せるか——パッケージ管理、初期化システム、デフォルトの構成、ユーザインタフェース——これらの選択が、Slackware、Debian、Red Hat、Gentoo、Ubuntuという多様なディストリビューションを生んだ。なぜLinuxにはこれほど多くの「亜種」があるのか。その多様性はUNIXの「自由に改変できる」という思想の直接的な帰結なのか、それとも断片化という弱点なのか。

---

## 参考文献

- Linus Torvalds, comp.os.minix posting, August 25, 1991: <https://groups.google.com/g/comp.os.minix/c/dlNtH7RRrGA/m/SwRavCzVE7gJ>
- Linus Torvalds, Linux 0.02 release announcement, October 5, 1991: <https://www.linux.com/news/linus-torvalds-linux-002-release-post-1991/>
- Linus Torvalds, David Diamond, "Just for Fun: The Story of an Accidental Revolutionary", HarperBusiness, 2001
- Andrew S. Tanenbaum, "Operating Systems: Design and Implementation", Prentice Hall, 1987
- Tanenbaum–Torvalds debate, comp.os.minix, January 29, 1992: <https://en.wikipedia.org/wiki/Tanenbaum%E2%80%93Torvalds_debate>
- Wikipedia, "Linux kernel": <https://en.wikipedia.org/wiki/Linux_kernel>
- Wikipedia, "History of Linux": <https://en.wikipedia.org/wiki/History_of_Linux>
- Wikipedia, "Linux kernel version history": <https://en.wikipedia.org/wiki/Linux_kernel_version_history>
- Wikipedia, "Minix": <https://en.wikipedia.org/wiki/Minix>
- Wikipedia, "Linus Torvalds": <https://en.wikipedia.org/wiki/Linus_Torvalds>
- Wikipedia, "Completely Fair Scheduler": <https://en.wikipedia.org/wiki/Completely_Fair_Scheduler>
- Wikipedia, "Loadable kernel module": <https://en.wikipedia.org/wiki/Loadable_kernel_module>
- Red Hat Blog, "Celebrating 30 years of the Linux kernel and the GPLv2": <https://www.redhat.com/en/blog/celebrating-30-years-linux-kernel-and-gplv2>
- Stackscale, "The Linux Kernel surpasses 40 Million lines of code": <https://www.stackscale.com/blog/linux-kernel-surpasses-40-million-lines-code/>
- The Linux Kernel documentation, "Overview of the Linux Virtual File System": <https://docs.kernel.org/filesystems/vfs.html>
- The Linux Kernel documentation, "CFS Scheduler": <https://docs.kernel.org/scheduler/sched-design-CFS.html>
