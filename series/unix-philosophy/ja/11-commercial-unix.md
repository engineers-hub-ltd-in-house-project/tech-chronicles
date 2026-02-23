# UNIXという思想

## ——パイプ、プロセス、ファイル――すべてはここから始まった

### 第11回：「商用UNIXの栄華と黄昏——Solaris, AIX, HP-UX」

**連載「UNIXという思想——パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 商用UNIXが企業の基幹システムを支配した1990年代——Sun Microsystems、IBM、Hewlett-Packardが自社プロセッサとOSを垂直統合したビジネスモデルの構造
- SunOS/Solaris、AIX、HP-UXの誕生と技術的系譜——BSDベースからSystem Vへの収斂、そして各社独自の技術革新
- IRIX（SGI）とTru64 UNIX（DEC）を含む商用UNIX群の全体像——SPARC、POWER、PA-RISC、MIPS、Alpha各アーキテクチャとOSの密結合
- Solarisが生み出した三つの技術的遺産——ZFS（2005年）、DTrace（2005年）、Zones（2005年）の設計思想と革新性
- AIXのWPAR（Workload Partitions）とHP-UXのServiceguardが示すエンタープライズ技術の進化
- 商用UNIXの凋落——Linux/x86の台頭、コストと人材の構造的要因、OracleによるSun買収（2010年）が意味するもの
- 商用UNIXの技術がLinuxに受け継がれた経路——ZFS→OpenZFS、DTrace→eBPF/bpftrace、Zones→cgroups/namespaces

---

## 1. 「技術的に正しい」ものが勝つとは限らない

2000年代後半、私はあるSolarisからLinuxへの移行プロジェクトに参加していた。

金融系の基幹システムだ。SPARC Enterprise上のSolaris 10で稼働していた。ZFSでストレージを管理し、DTraceでパフォーマンス問題を診断し、Zonesでアプリケーション環境を分離していた。技術的には堅牢そのものだった。ZFSのエンドツーエンドのデータ整合性検証は、サイレントデータ破損という潜在的脅威を根本から排除していた。DTraceの動的トレーシングは、本番環境でオーバーヘッドなしにカーネルからアプリケーションまでを透視できた。Zones はOSレベルの仮想化を、仮想マシンの重さなしに実現していた。

だが、移行は決まっていた。

理由は技術ではなかった。SPARC Enterpriseのハードウェア保守契約が高騰していた。Solarisを扱えるエンジニアの採用が年々困難になっていた。新卒エンジニアはLinuxしか知らない。中途採用の候補者もLinux経験者ばかりだ。Solaris固有のスキル——SMF（Service Management Facility）の設定、ZFSのプール管理、DTraceのスクリプト記述——を持つエンジニアは、市場で希少な存在になりつつあった。

私はDTraceのスクリプトをLinux上の同等ツール（当時はSystemTapが主流だった）に書き換える作業を担当した。DTraceで10行で書けたトレーシングスクリプトが、SystemTapでは50行以上に膨らんだ。DTraceの安全性保証——カーネルをクラッシュさせないことがフレームワークレベルで担保されていた——はSystemTapにはなかった。本番環境で気軽にトレースを仕掛けられるという安心感は、Solarisならではのものだった。

ZFSのスナップショット機能も移行対象だった。Linux上ではLVMのスナップショットで代替したが、ZFSの「常にオン」のチェックサム検証に相当する機能はなかった。データ整合性に対するZFSの設計思想——「ファイルシステムは自分自身のデータが正しいことを証明できるべきだ」——は、当時のLinuxファイルシステム（ext3/ext4）には存在しない発想だった。

技術的にはSolarisが優れていた部分が確かにあった。だが、コストと人材調達の現実がLinux移行を不可避にした。私はこのとき、技術の優劣が市場の勝敗を決めるわけではないという、痛みを伴う教訓を得た。

この経験は、商用UNIXの歴史そのものを象徴している。Sun Microsystems、IBM、Hewlett-Packard、Silicon Graphics、Digital Equipment Corporation——これらの企業は、UNIXの設計思想を独自に発展させ、革新的な技術を生み出した。その技術の多くは、今日のLinuxに形を変えて受け継がれている。だが、それを生み出した企業と製品は、市場から姿を消した。

あなたが今、`docker run` で起動しているコンテナの概念は、Solaris Zonesに遡る。`bpftrace` で書いているトレーシングスクリプトの設計思想は、DTraceに由来する。OpenZFSのストレージ管理は、Sun Microsystemsのエンジニアが設計した原型をそのまま受け継いでいる。商用UNIXは「滅びた」のではない。その技術的遺産は、形を変えて生き続けている。

---

## 2. 商用UNIXの群像——五つの帝国

### Sun Microsystems と Solaris——BSDからSystem Vへの大転換

Sun Microsystemsは1982年2月24日、Scott McNealy、Andy Bechtolsheim、Vinod Khoslaによってスタンフォード大学から生まれた。Bill Joy——BSDの主要開発者——がまもなく参加し、共同創業者に数えられる。社名「SUN」はStanford University Networkの頭文字だ。Sunは最初の四半期（1982年7月）から黒字を達成した。

SunのOSはBSDの血統を引いていた。1982年後半から提供されたSunOSは4.2BSDをカスタマイズしたもので、SunのSPARCワークステーションの基盤となった。SPARCプロセッサは1984年にSunの小チームが開発を開始し、1987年に製品出荷された。Berkeley RISC-IIに直接基づく設計で、1990年代にピークを迎える。1990年末時点で、Sunはワークステーション出荷の3分の1以上のシェアを占め、Hewlett-Packardが約20%で2位だった。

だがSunは、1980年代後半に大きな方向転換を行う。AT&TがSystem V Release 4（SVR4）の開発パートナーとしてSunを選んだのだ。AT&TとSunの共同開発によるSVR4は、System VとBSDの機能を統合する試みだった。前々回（第9回）で見たUNIX Warsにおいて、この提携はOSF（Open Software Foundation）結成の直接的な引き金となった。

SunはSVR4をベースにSolaris 2.xを開発し、1991年にリリースした。BSDベースのSunOS 4.1.xは後に遡及的に「Solaris 1.x」と呼ばれるようになったが、実態は全く異なるOSへの移行だった。BSDからSystem Vへ——これはSunにとって技術的にも文化的にも大きな転換だった。Bill Joyが築いたBSDの伝統を持つ企業が、AT&Tの商用UNIX路線に舵を切ったのだ。

この転換に対するSun社内の反発は小さくなかった。BSDのネットワーキングスタック、シグナル処理、ファイルシステムに慣れたエンジニアたちが、System Vの設計思想に適応する必要があった。だがSunの経営陣は、業界標準への収斂が長期的な競争優位につながると判断した。SVR4によってBSDとSystem Vの機能が統合されたことで、Solarisは両方の長所を持つプラットフォームとなった。

### IBM AIX——POWERの上に築かれた帝国

IBMは1986年にAIX（Advanced Interactive eXecutive）をRT PC向けにリリースした。System V Releases 1/2をベースに、4.2BSDおよび4.3BSDのソースコードを組み込んだハイブリッドなUNIXだった。

だがAIXが真の力を発揮するのは、1990年のRS/6000（RISC System/6000）とともに登場したAIX Version 3からだ。IBMは1985年にWatson研究所で「AMERICA architecture」の研究を開始し、1986年にAustinの開発拠点でRS/6000の開発に着手した。1990年2月、POWER（Performance Optimization With Enhanced RISC）命令セットを搭載した最初のシステムがRS/6000として出荷され、AIX Version 3がその上で動作した。

IBMの強みは、ハードウェアからOS、ミドルウェア、アプリケーションまでを一貫して提供できる垂直統合にあった。DB2（データベース）、WebSphere（アプリケーションサーバ）、Tivoli（システム管理）——IBMのソフトウェアスタック全体がAIX上で最適化されていた。金融機関、通信事業者、政府機関——ミッションクリティカルなワークロードを持つ組織がAIXを選んだ。

POWERアーキテクチャの進化はAIXの進化と表裏一体だった。POWER1（1990年）からPOWER10（2021年）まで、IBMはプロセッサとOSを同時に進化させ続けた。この垂直統合モデルは、パフォーマンスと信頼性の面で大きな優位性をもたらした。だが同時に、x86/Linuxの水平分業モデルに対するコスト上の劣位を構造的に抱えることにもなった。

AIXは商用UNIXの中では唯一、2026年現在もIBMによってアクティブに開発・サポートされている。Power Systemsは依然としてエンタープライズ市場の一角を占め、AIX 7.3（2021年リリース）が最新版として稼働している。だがその市場規模は、1990年代のピークとは比較にならないほど縮小している。

### HP-UX——Precision Architectureの夢

Hewlett-Packardは1984年にHP-UXをリリースした。System III（後にSystem V）ベースのUNIXで、HP 9000シリーズのワークステーションおよびサーバ上で動作した。

HPは独自のPA-RISC（Precision Architecture RISC）プロセッサを開発していた。1982年にHP Laboratoriesで設計が開始され、1986年に初の製品——HP 9000 Series 840——が出荷された。PA-RISCとHP-UXの組み合わせは、特に通信事業者やメーカーの基幹システムで強固な地位を築いた。

HPの特徴は、エンタープライズ向けの信頼性技術に対する執着だった。HP Serviceguard——1990年に登場した高可用性クラスタリングソフトウェア——は、UNIX向けの初期のHAソリューションの一つだった。フェイルオーバー、パッケージ（アプリケーション群）のノード間移行、自動復旧——これらの機能は、24時間365日の稼働を要求する基幹システムにとって不可欠だった。

だがHP-UXの運命は、PA-RISCの運命と結びついていた。HPはIntelとの提携でItanium（IA-64）アーキテクチャの共同開発に踏み切り、PA-RISCからItaniumへの移行を推進した。PA-RISCは2008年末に廃止された。Itanium上のHP-UXは継続されたが、Itanium自体がx86-64に対してパフォーマンスと価格競争力で劣り、市場は縮小の一途をたどった。

2026年1月、HP-UXの最後のサポートバージョンが終了した。40年以上の歴史を持つOSの、静かな幕引きだった。

### SGIのIRIXとDECのTru64——忘れられた革新者たち

商用UNIXの群像には、SolarisやAIXほど知られていないが技術的に重要な存在がある。

Silicon Graphics（SGI）が開発したIRIXは、MIPSプロセッサ上で動作するSystem Vベース（+BSD拡張）のUNIXだった。1988年のリリース3.0でIRIXの名称が採用された。IRIXの技術的遺産は二つある。一つはXFS——高性能な64bitジャーナリングファイルシステムで、現在もLinuxの主要ファイルシステムの一つとして広く使われている。もう一つはOpenGL——SGIが開発した3DグラフィックスAPIで、現在のGPUプログラミングの基盤となっている。1990年代初頭、IRIXはSMP（対称型マルチプロセッシング）で先駆的な存在であり、1つから1,024プロセッサ以上のシングルシステムイメージを実現していた。映画業界のVFXはIRIXワークステーション上で制作された。2006年9月、SGIはMIPS/IRIXの開発終了を発表した。

Digital Equipment Corporation（DEC）が開発したTru64 UNIXは、別の意味で技術的に興味深い存在だった。OSF/1（Open Software Foundation/1）をベースとし、カーネギーメロン大学で開発されたMachマイクロカーネルの上に構築されていた。Alphaプロセッサ——DECが設計した64bit RISCアーキテクチャ——上で動作し、当時最も先進的な64bit UNIXの一つだった。1995年にOSF/1 AXPからDigital UNIXに改名、1998年のCompaqによるDEC買収後にTru64 UNIXに改名された。2002年にHPがCompaqを買収し、Tru64の先進的機能（AdvFS、TruCluster、LSM）をHP-UXに移植する計画を発表した。最終保守リリースは2010年10月だった。

これらの「忘れられた」商用UNIXは、技術的革新の宝庫だった。XFSは今もLinuxで標準的に使われているし、OpenGLはGPUプログラミングの基礎だ。Machカーネルの設計はmacOS（XNU）に受け継がれている。商用UNIXの歴史は、SolarisやAIXだけでは語れない。

### 垂直統合——商用UNIXのビジネスモデル

五つの商用UNIXに共通するのは、ハードウェアとソフトウェアの垂直統合モデルだ。

```
商用UNIXの垂直統合モデル（1990年代）

  Sun           IBM           HP            SGI           DEC
  ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐
  │Solaris │   │  AIX   │   │ HP-UX  │   │ IRIX   │   │ Tru64  │
  ├────────┤   ├────────┤   ├────────┤   ├────────┤   ├────────┤
  │ SPARC  │   │ POWER  │   │PA-RISC │   │  MIPS  │   │ Alpha  │
  └────────┘   └────────┘   └────────┘   └────────┘   └────────┘
     │             │             │             │             │
  自社プロセッサ + 自社OS + 自社ミドルウェア = 最適化されたスタック

        ┌──────────────────────────────────────────────────────┐
        │              Linux / x86 の水平分業モデル             │
        │                                                      │
        │  OS層:   Linux（Red Hat, SUSE, Debian, ...）          │
        │  HW層:   x86（Intel, AMD） ← 誰でも製造可能          │
        │  MW層:   OSS（Apache, MySQL, PostgreSQL, ...）        │
        │                                                      │
        │  → 各層が独立して調達可能 → コスト最適化              │
        └──────────────────────────────────────────────────────┘
```

垂直統合には明確な利点があった。自社プロセッサの特性を知り尽くしたOS開発チームが、ハードウェアの性能を最大限に引き出す最適化を施せる。SolarisのSPARC向けスレッドスケジューリング、AIXのPOWER向けメモリ管理、HP-UXのPA-RISC向けI/O最適化——これらはハードウェアとソフトウェアが同じ屋根の下にあるからこそ可能な最適化だった。

だがこのモデルには構造的な弱点があった。コストだ。自社プロセッサの設計・製造コスト、OS開発コスト、サポートコスト——すべてが一社に集中する。一方、x86/Linuxの水平分業モデルでは、プロセッサのコストはIntelとAMDの競争が引き下げ、OSのコストはオープンソースコミュニティが分散し、ミドルウェアのコストもOSSが吸収する。個々の組み合わせの最適化では垂直統合に劣るかもしれないが、トータルコストでは水平分業が圧倒的に有利だった。

1990年代、この構造的な差はまだ表面化していなかった。RISC/UNIX サーバの性能はx86サーバを大きく上回っており、基幹システムにはRISC/UNIXが必須とされていた。だが2000年代に入り、x86プロセッサの性能が急速に向上し、Linux の信頼性とスケーラビリティが証明されるにつれて、コスト差が決定的な意味を持つようになった。

---

## 3. 三つの技術的遺産——ZFS、DTrace、Zones

商用UNIXの技術的遺産の中でも、Solaris 10（2005年1月リリース）が生み出した三つの技術は特筆に値する。ZFS、DTrace、Zonesだ。これらはいずれも、それまでの常識を覆す設計思想を持っていた。

### ZFS——ファイルシステムの再発明

ZFSの開発は2001年にSun MicrosystemsでJeff Bonwick、Bill Moore、Matthew Ahrensのチームによって始まった。2004年9月14日に発表され、2005年10月31日にSolaris開発トランクに統合、2006年6月のSolaris 10 6/06アップデートで一般公開された。

ZFSの設計思想は「エンドツーエンドのデータ整合性」だ。従来のファイルシステムは、ディスクがデータを正しく書き込んだと信頼していた。だが現実には、ディスクのファームウェアバグ、コントローラの故障、ケーブルの接触不良などにより、データが知らないうちに破損する——いわゆるサイレントデータコラプション——が発生する。ZFSはすべてのデータブロックにチェックサムを格納し、読み出し時に検証する。データの破損を検知したら、冗長コピーから自動修復する。

```
従来のファイルシステムの信頼モデル:

  アプリケーション → ファイルシステム → ボリューム管理 → ディスク
                                                           ↑
                                             ここを「信頼」している
                                             （実際にはサイレント破損の可能性）

ZFSの信頼モデル:

  アプリケーション → ZFS ─────────────────────────→ ディスク
                      │                                 │
                      └─ チェックサム検証 ←─────────────┘
                      └─ コピーオンライト
                      └─ ボリューム管理統合
                      └─ 自動修復（ミラー/RAID-Z）

  → ディスクを「信頼しない」設計
```

ZFSのもう一つの革新は、ファイルシステムとボリュームマネージャの統合だ。従来は、ディスク → パーティション → ボリュームマネージャ（LVM等）→ ファイルシステム（ext3等）という層構造だった。ZFSはこの全体を一つのソフトウェアスタックに統合し、ストレージプールという概念を導入した。ディスクをプールに追加し、プールからファイルシステムを切り出す。スナップショット、クローン、圧縮、重複排除——これらがファイルシステムレベルで透過的に提供される。

ZFSの遺産は複数の経路でLinuxに受け継がれた。OpenZFSプロジェクトは、2013年9月に「ZFSプロジェクトの真のオープンソース後継」として発足した。CDDLライセンスとGPLの非互換性により、ZFSはLinuxカーネルに直接統合されることはなかったが、カーネルモジュールとして広く利用されている。Ubuntu 19.10（2019年）はZFSをルートファイルシステムのオプションとして公式に提供した。

一方、btrfs（B-tree file system）はZFSの設計思想——コピーオンライト、チェックサム、スナップショット——をLinuxネイティブなGPLライセンスで実現することを目指して開発された。Oracleの Chris Masonが2007年に開発を開始し、ZFSと同様の機能群をLinuxカーネルに直接統合するアプローチを取った。ただし、btrfsはZFSの「クローン」ではなく、独自の設計判断を持つ別のファイルシステムだ。

### DTrace——本番環境の透視装置

DTraceの開発は2001年にSun MicrosystemsのBryan Cantrillによって始まった。Adam LeventhalとMike Shapiroがまもなく参加し、コアチームを形成した。2003年11月に初めて利用可能となり、2005年1月のSolaris 10で正式リリースされた。DTraceはOpenSolarisプロジェクトで最初にCDDLでオープンソース化されたコンポーネントでもある（2005年1月25日）。

DTraceが解決した問題は、本番環境のパフォーマンス診断だ。従来のトレーシングツールは二つの大きな制約があった。一つは、トレースポイントを事前にコードに埋め込む必要があること（静的トレーシング）。もう一つは、トレーシングのオーバーヘッドが大きく、本番環境で使うことが現実的でないこと。

DTraceは「動的トレーシング」を実現した。プローブ——約4万のトレースポイント——がSolaris 10のカーネル全体に組み込まれており、DTraceが無効な状態ではゼロオーバーヘッドで動作する。必要な時にプローブを有効化し、リアルタイムでシステムの振る舞いを観測できる。カーネルからユーザランドのアプリケーションまで、スタック全体を一つのフレームワークで透視できる。

```
DTraceのアーキテクチャ:

  ┌─────────────────────────────────────────────────┐
  │  D言語スクリプト（AWK風の記述言語）              │
  │  例: syscall::write:entry { @[execname] = count(); } │
  └──────────────┬──────────────────────────────────┘
                 │ コンパイル
                 ▼
  ┌─────────────────────────────────────────────────┐
  │  DTrace仮想マシン（カーネル内で安全に実行）      │
  │  ・無効時ゼロオーバーヘッド                      │
  │  ・安全性保証：カーネルクラッシュを起こさない    │
  │  ・ループ禁止、メモリ制限 → 暴走しない          │
  └──────────────┬──────────────────────────────────┘
                 │ プローブ
                 ▼
  ┌─────────────────────────────────────────────────┐
  │  プロバイダ                                      │
  │  ・syscall: システムコール出入口                  │
  │  ・fbt:     カーネル関数境界                      │
  │  ・pid:     ユーザプロセス関数                    │
  │  ・io:      I/Oイベント                           │
  │  ・proc:    プロセスライフサイクル                │
  └─────────────────────────────────────────────────┘
```

DTraceの設計で最も重要なのは「安全性保証」だ。DTraceの仮想マシンはカーネル内で実行されるが、無限ループを禁止し、メモリアクセスを制限し、カーネルをクラッシュさせるような操作を構造的に不可能にしている。これにより、本番環境の稼働中のシステムに対して、安心してトレーシングを仕掛けることができる。

私がSolarisからLinuxへの移行プロジェクトでDTraceの不在を最も痛感したのは、パフォーマンス問題の診断時だった。Solarisでは `dtrace -n 'syscall::write:entry { @[execname] = count(); }'` と一行打てば、どのプロセスがどれだけwriteシステムコールを発行しているかが即座にわかった。この気軽さは、DTraceの安全性保証があって初めて成り立つ。

DTraceの設計思想は、LinuxのeBPF（extended Berkeley Packet Filter）エコシステムに受け継がれた。eBPFの前身であるBPFは1992年にSteven McCanneとVan Jacobsonによって開発されたパケットフィルタリング専用の仮想マシンだったが、2012年から2014年にかけてLinuxカーネルで汎用仮想マシンに拡張された。Linux 3.18（2014年）でeBPF仮想マシンが正式統合され、カーネル内の安全なプログラム実行基盤としての地位を確立した。

bpftrace——Alastair Robertsonが開発した高レベルトレーシング言語——は、DTraceの設計哲学を直接的に継承している。Brendan Gregg（元Sun Microsystems、DTraceの主要な伝道者）はbpftraceを「DTrace 2.0」と位置づけている。DTraceのD言語とbpftraceの構文は類似しており、DTraceユーザがbpftraceに移行しやすい設計になっている。

### Zones——コンテナの先駆

Solaris Zonesは2004年2月にSolaris 10のベータ版（build 51）で初公開され、2005年のSolaris 10正式リリースで一般公開された。Dan PriceとAndy Tuckerらが、BSD Jailsの概念から着想を得て開発した。

Zonesの設計思想は「一つのカーネルで複数の隔離された実行環境を提供する」ことだ。仮想マシン（Xen、VMware等）がハードウェア全体をエミュレートするのに対し、Zonesはカーネルを共有しつつ、プロセス空間、ファイルシステム、ネットワークスタック、ユーザ管理を隔離する。仮想マシンに比べてオーバーヘッドが極めて小さく、起動も高速だ。

```
仮想マシン vs Zones（OSレベル仮想化）:

  仮想マシン:                    Zones:
  ┌───────┐ ┌───────┐           ┌───────┐ ┌───────┐
  │ App A │ │ App B │           │ App A │ │ App B │
  ├───────┤ ├───────┤           ├───────┤ ├───────┤
  │Guest  │ │Guest  │           │Zone 1 │ │Zone 2 │
  │ OS    │ │ OS    │           │(隔離) │ │(隔離) │
  ├───────┤ ├───────┤           └───┬───┘ └───┬───┘
  │  VM   │ │  VM   │               │         │
  ├───────┴─┴───────┤           ┌───┴─────────┴───┐
  │  ハイパーバイザ  │           │ 単一カーネル     │
  ├─────────────────┤           │ （Solaris）      │
  │   ハードウェア   │           ├─────────────────┤
  └─────────────────┘           │   ハードウェア   │
                                └─────────────────┘
  → 各VMにOSが必要              → カーネル共有でオーバーヘッド最小
  → オーバーヘッド大            → 起動が高速
  → 完全な隔離                  → 軽量な隔離
```

2005年当時、OSレベルの仮想化は事実上未知の領域だった。Solaris ZonesはFreeBSD Jails（2000年）の概念を発展させ、リソース管理（CPU、メモリ、ネットワーク帯域の制限）と組み合わせた初の本格的なプロダクション対応実装となった。Joyent（後にSamsungが買収）は2006年にSolaris Zonesベースのクラウドホスティング事業を構築し、OSレベル仮想化の商用利用を先駆けた。

Zonesの概念はLinuxのコンテナ技術に直接的な影響を与えた。Googleのエンジニアは2006年に「process containers」（後のcgroups）の開発を開始した。「container」という用語自体が、Solaris Zones + Resource Management を指す「Solaris Containers」から広まったものだ。2007年後半にLinuxカーネル内での用語の混乱を避けるため「control groups」に改名され、2008年1月のLinux 2.6.24でカーネルメインラインにマージされた。

一方、Linux namespacesは2002年のLinux 2.4.19でmount namespaceが初めて利用可能になって以来、段階的に実装が進んだ。PID namespace、network namespace、user namespace等が追加され、2013年2月のLinux 3.8でuser namespacesが完成し、コンテナに必要なnamespace群が出揃った。

2008年夏にリリースされたLXC（Linux Containers）がcgroupsとnamespacesを組み合わせた最初のコンテナツールとなり、2013年にDockerがLXCの上に構築されて登場した（後にDocker独自のlibcontainerに移行）。Dockerのコンテナは、Solaris Zonesが行っていたこと——単一カーネルでのOSレベル分離——と概念的に同じだが、Linuxのcgroups/namespaces上に構築された独自の実装だ。

### AIXのWPARとHP-UXのServiceguard

Solaris Zones の成功を受けて、IBMも2007年にAIX 6.1でWPAR（Workload Partitions）を導入した。WPARはAIXのOS仮想化技術で、一つのAIXインスタンスを複数の隔離された環境に分割する。2年間のベータテストを経てリリースされ、RBAC（Role-based Access Control）とともにAIX 6の二大機能だった。カーネルレベルの根本的変更が伴ったため、バージョン番号がAIX 5.3から6に上がった。WPARはLPAR（Logical Partition、ハードウェアレベルの仮想化）の補完的位置づけで、より軽量な仮想化を提供した。

HP-UXはコンテナ化技術では後発だったが、高可用性の分野で先行していた。HP Serviceguard（1990年〜）は、クラスタ内のノード間でアプリケーションパッケージを自動的にフェイルオーバーする仕組みを提供し、世界で8万以上のライセンスが導入された。サービスIPアドレスがクラスタノード間で移動し、クライアントから見るとダウンタイムが最小化される——現代のKubernetesのPodフェイルオーバーと概念的に同じ仕組みだ。

---

## 4. 黄昏——なぜ商用UNIXは退場したのか

### コストの構造的劣位

商用UNIXの凋落を一言で説明するなら「コスト」だ。

1990年代、SPARC、POWER、PA-RISCプロセッサの性能はx86を大きく上回っていた。基幹システムにRISC/UNIXを選ぶことは、パフォーマンス面で合理的だった。だが2000年代に入り、IntelのXeon、AMDのOpteronがエンタープライズ市場に本格参入すると、状況が変わった。x86プロセッサは半導体の微細化トレンドの恩恵を最も受けやすい量産アーキテクチャであり、コストパフォーマンスで急速にRISCプロセッサに追いついた。

x86サーバの単価は、同等性能のRISC/UNIXサーバの数分の一だった。しかもx86サーバは複数ベンダー（Dell、HP、IBM自身）から調達可能で、価格競争が働く。一方、SPARCサーバはSunからしか買えない。POWERサーバはIBMからしか買えない。PA-RISCサーバはHPからしか買えない。ベンダーロックインは、調達コストの下方硬直性を意味した。

### 人材の構造的シフト

コスト以上に決定的だったのは、人材の構造的シフトだ。

2000年代以降、大学や専門学校でLinuxを学んだ世代が労働市場に流入した。Red Hat認定やLPIC（Linux Professional Institute Certification）は広く普及したが、SolarisやAIXの認定資格を持つ若手エンジニアは年々減少した。企業がSolaris/AIXの運用を維持しようとしても、エンジニアの採用が困難になった。

これは自己強化的なフィードバックループを形成した。Linuxの普及 → Linuxエンジニアの増加 → 企業のLinux採用加速 → さらなるLinuxの普及。逆にSolaris/AIXは、普及の縮小 → エンジニアの減少 → 企業の移行加速 → さらなる縮小、という負のスパイラルに陥った。

### IDCのデータが示す衰退

2006年第2四半期、UNIXサーバは世界サーバ市場の約35%（43億ドル）を占めていたが、前年比で売上1.6%減、出荷数1.8%減だった（IDC調べ）。この縮小トレンドは少なくとも10年間続いていたとされる。1990年代後半にUNIXサーバ市場を支配していたSun Microsystemsは、2005年にIBMに追い抜かれた。

### OracleによるSun買収——一つの時代の終わり

2009年4月20日、OracleはSun Microsystemsの買収を発表した。買収額は約74億ドル（1株9.50ドル）。2010年1月21日にEU競争委員会が無条件承認し、2010年1月27日に買収が完了した。

Oracleの狙いはJava、MySQL、そしてSunのハードウェア事業だった。Solarisは副次的な資産だった。買収後、OracleはOpenSolarisプロジェクトを廃止した。2005年6月14日にSunがCDDLライセンスで公開したSolarisのソースコードは、再びクローズドソースに戻された。Oracleは Solaris 11を継続開発したが、オープンソースコミュニティとの関係は断絶した。

OpenSolarisの遺産はillumosプロジェクトに引き継がれた。illumosはOpenSolarisの最後のオープンソースリリースをフォークし、SmartOS（Joyent）、OmniOS、OpenIndiana等のディストリビューションの基盤となっている。ZFS、DTrace、Zonesの技術はillumosを通じて今も進化を続けている。

Sun Microsystemsの買収は、商用UNIX時代の象徴的な終焉だった。ワークステーション市場を創造し、BSDの伝統を商用化し、Java を生み出し、ZFS/DTrace/Zonesで技術革新を続けた企業が、データベースベンダーに吸収されたのだ。

---

## 5. ハンズオン：商用UNIXの遺産をLinux上で体験する

商用UNIXの技術的遺産がLinuxにどう受け継がれたかを、手を動かして確認する。OpenZFSによるストレージ管理と、eBPF/bpftraceによるシステム観測を体験する。

### 環境構築

Docker上にUbuntu 24.04環境を準備する。

```bash
docker run -it --rm --privileged ubuntu:24.04 bash
```

`--privileged` フラグは、eBPFプログラムの実行やカーネルモジュールの操作に必要だ。

コンテナ内で必要なツールをインストールする。

```bash
apt-get update && apt-get install -y \
    bpfcc-tools \
    bpftrace \
    linux-tools-common \
    linux-headers-$(uname -r) \
    procps \
    stress-ng \
    sysstat \
    trace-cmd \
    strace
```

### 演習1：bpftraceでDTraceの設計思想を体験する

DTraceが切り拓いた「動的トレーシング」の概念を、bpftrace（「DTrace 2.0」）で体験する。

```bash
# プロセスごとのシステムコール数を集計する
# DTraceなら: dtrace -n 'syscall:::entry { @[execname] = count(); }'
# bpftraceでは:
bpftrace -e 'tracepoint:raw_syscalls:sys_enter { @[comm] = count(); }' &
BPFTRACE_PID=$!

# 負荷をかける
dd if=/dev/zero of=/dev/null bs=1M count=100 2>/dev/null
sleep 3

# 結果を確認
kill $BPFTRACE_PID 2>/dev/null
wait $BPFTRACE_PID 2>/dev/null
```

DTraceのD言語とbpftraceの構文の類似性に注目してほしい。`プローブ { アクション }` という基本構造は同じだ。DTraceの設計思想——「宣言的にトレース対象を指定し、集計する」——がそのまま受け継がれている。

```bash
# ファイルのopen()を追跡する
# DTraceなら: dtrace -n 'syscall::open:entry { printf("%s %s", execname, copyinstr(arg0)); }'
# bpftraceでは:
bpftrace -e '
tracepoint:syscalls:sys_enter_openat {
    printf("%s opened: %s\n", comm, str(args.filename));
}' &
BPFTRACE_PID=$!

# ファイルアクセスを発生させる
cat /etc/hostname 2>/dev/null
ls /tmp 2>/dev/null
sleep 2

kill $BPFTRACE_PID 2>/dev/null
wait $BPFTRACE_PID 2>/dev/null
```

### 演習2：bpftraceの集計機能——DTraceのアグリゲーション

DTraceの強力な機能の一つは、カーネル内でのデータ集計（アグリゲーション）だ。大量のイベントをカーネル内で集計し、ユーザ空間には要約されたデータだけを渡す。bpftraceもこの設計を継承している。

```bash
# I/Oサイズのヒストグラムを生成する
# DTraceなら: dtrace -n 'io:::start { @size = quantize(args[0]->b_bcount); }'
# bpftraceでは:
bpftrace -e '
tracepoint:block:block_rq_issue {
    @io_size = hist(args.bytes);
}' &
BPFTRACE_PID=$!

# I/Oを発生させる
dd if=/dev/zero of=/tmp/testfile bs=4K count=1000 2>/dev/null
sync
dd if=/tmp/testfile of=/dev/null bs=4K 2>/dev/null
sleep 3

kill $BPFTRACE_PID 2>/dev/null
wait $BPFTRACE_PID 2>/dev/null
rm -f /tmp/testfile
```

ヒストグラムとして出力される結果は、DTraceの `quantize()` と同じ2のべき乗バケットを使っている。この設計は、I/Oパターンの分析に最適だ。

### 演習3：プロセス監視——Solaris prstatの系譜

商用UNIXには、それぞれ独自の高機能なプロセス監視ツールがあった。Solarisの `prstat`、AIXの `topas`、HP-UXの `glance` だ。Linux の `top` や `htop` はこれらの影響を受けている。

```bash
# bpftraceでプロセス生成を追跡する
# 新しいプロセスが生成されるたびに、親プロセスと子プロセスの情報を表示
bpftrace -e '
tracepoint:sched:sched_process_exec {
    printf("exec: pid=%d comm=%s\n", pid, comm);
}

tracepoint:sched:sched_process_fork {
    printf("fork: parent=%d child=%d\n", args.parent_pid, args.child_pid);
}' &
BPFTRACE_PID=$!

# プロセス生成を発生させる
for i in $(seq 1 5); do
    echo "iteration $i" > /dev/null
done
sleep 2

kill $BPFTRACE_PID 2>/dev/null
wait $BPFTRACE_PID 2>/dev/null
```

### 演習4：DTrace構文とbpftrace構文の比較表

最後に、DTraceとbpftraceの構文を並べて比較する。

```bash
cat << 'TABLE'
┌─────────────────────────────────────────────────────────────────────┐
│ DTrace (Solaris) vs bpftrace (Linux) 構文比較                       │
├───────────────────────────┬─────────────────────────────────────────┤
│ DTrace                    │ bpftrace                                │
├───────────────────────────┼─────────────────────────────────────────┤
│ syscall:::entry           │ tracepoint:raw_syscalls:sys_enter       │
│ { @[execname] = count(); }│ { @[comm] = count(); }                  │
├───────────────────────────┼─────────────────────────────────────────┤
│ syscall::read:entry       │ tracepoint:syscalls:sys_enter_read      │
│ { @bytes = quantize(arg2);}│ { @bytes = hist(args.count); }         │
├───────────────────────────┼─────────────────────────────────────────┤
│ pid$target:::entry        │ uprobe:/path/to/binary:function         │
│ { @[probefunc] = count();}│ { @[func] = count(); }                  │
├───────────────────────────┼─────────────────────────────────────────┤
│ profile:::tick-1sec       │ interval:s:1                            │
│ { ... }                   │ { ... }                                 │
├───────────────────────────┼─────────────────────────────────────────┤
│ fbt::vm_fault:entry       │ kprobe:handle_mm_fault                  │
│ { ... }                   │ { ... }                                 │
├───────────────────────────┼─────────────────────────────────────────┤
│ D言語（C風）               │ AWK/C風（DTraceに触発された構文）       │
│ 安全性: カーネル保証       │ 安全性: eBPF verifier                   │
│ プローブ: 約4万            │ プローブ: 数十万（トレースポイント+     │
│                           │           kprobe/uprobe）               │
└───────────────────────────┴─────────────────────────────────────────┘
TABLE
```

この比較表が示すのは、DTraceの設計思想がbpftraceにほぼそのまま受け継がれているという事実だ。プローブの指定方法、集計関数の名前、出力形式は異なるが、「宣言的にトレース対象を指定し、カーネル内で安全に集計し、結果を人間が読める形式で出力する」という設計思想は同一だ。

Bryan Cantrillが2001年に着手したDTraceの設計思想は、20年以上を経てLinuxのeBPFエコシステムという形で結実した。商用UNIXの技術は「滅びた」のではなく、「移植」されたのだ。

---

## 6. まとめと次回予告

### この回の要点

- 商用UNIXは1990年代に企業の基幹システムを支配した。Sun Microsystems（Solaris/SPARC）、IBM（AIX/POWER）、Hewlett-Packard（HP-UX/PA-RISC）、SGI（IRIX/MIPS）、DEC（Tru64/Alpha）——各社は自社プロセッサとOSを垂直統合し、ハードウェアの性能を最大限に引き出す最適化を施した。この垂直統合モデルは性能と信頼性で優れていたが、x86/Linuxの水平分業モデルに対するコスト上の構造的劣位を内包していた

- Solaris 10（2005年）は三つの革新的技術を世に送り出した。ZFS（2001年開発開始、2006年一般公開）はエンドツーエンドのデータ整合性検証とボリューム管理統合で、ファイルシステムの常識を覆した。DTrace（2001年開発開始、2005年リリース）は本番環境でゼロオーバーヘッドの動的トレーシングを実現し、システム観測の方法論を変えた。Zones（2005年リリース）はOSレベルの仮想化を本格的なプロダクション環境で初めて実現し、コンテナ技術の先駆となった

- 商用UNIXの凋落は技術的劣位ではなく、構造的な経済要因によるものだった。x86プロセッサの急速な性能向上とコスト低下、Linux の信頼性とスケーラビリティの証明、そしてLinuxエンジニア人材の増加が、商用UNIXからの移行を不可避にした。OracleによるSun Microsystems買収（2009年発表、2010年完了、約74億ドル）と、その後のOpenSolarisプロジェクト廃止は、商用UNIX時代の象徴的な終焉だった

- 商用UNIXの技術は「滅びた」のではなく、形を変えてLinuxに受け継がれた。ZFSはOpenZFSとしてオープンソースコミュニティで発展し、btrfsはZFSの設計思想をGPLライセンスで実現した。DTraceの動的トレーシングの概念はeBPF/bpftraceとしてLinuxに「移植」された。Solaris ZonesのOSレベル仮想化は、cgroupsとnamespacesを経てDockerコンテナに結実した。SGIのXFSは今もLinuxの主要ファイルシステムであり、OpenGLはGPUプログラミングの基礎だ

- AIXは2026年現在もIBMによってアクティブに開発されている唯一の商用UNIXであり、Power Systems上でエンタープライズ市場の一角を占めている。HP-UXは2026年1月に最後のサポートバージョンが終了した。商用UNIXの完全な退場にはまだ時間がかかるが、その主戦場はとうに失われている

### 冒頭の問いへの暫定回答

「かつて企業の基幹システムを支えた商用UNIXは、なぜLinuxに取って代わられたのか？」

答えは「技術の敗北」ではない。「ビジネスモデルの敗北」だ。

商用UNIXの垂直統合モデル——自社プロセッサ、自社OS、自社ミドルウェアの一体提供——は、性能と信頼性を最大化する優れたモデルだった。だが、このモデルは研究開発コストの一社集中を意味し、コストの下方硬直性を生んだ。x86/Linuxの水平分業モデルは、プロセッサのコストをIntelとAMDの競争が引き下げ、OSのコストをオープンソースコミュニティが分散し、各層を独立に最適化できた。

そして皮肉なことに、商用UNIXが生み出した最も革新的な技術——ZFS、DTrace、Zones——は、それを生み出した企業の延命には貢献せず、競合であるLinuxを強化する方向に作用した。技術は企業の壁を超えて受け継がれる。それがオープンソースの時代の必然だ。

あなたの組織で「技術的に正しい」選択と「ビジネスとして合理的な」選択が対立したとき、あなたはどちらを選ぶだろうか。

### 次回予告

次回は「GNU宣言とFSF——自由ソフトウェアという思想」。商用UNIXがハードウェアと結びついた「所有するソフトウェア」の時代を謳歌していた1985年、Richard Stallmanは「GNU宣言」を発表し、ソフトウェアは「自由であるべきだ」と宣言した。GCC、Emacs、GDB、coreutils、bash——GNUプロジェクトが生み出したツール群なしには、Linuxカーネルは実用的なOSになり得なかった。GPL（GNU General Public License）のコピーレフト条項は、ソフトウェアの「自由」を法的に保証する仕組みだ。Free SoftwareとOpen Sourceの違いは何か。ソフトウェアの「自由」とは何を意味するのか。

---

## 参考文献

- Wikipedia, "Sun Microsystems": <https://en.wikipedia.org/wiki/Sun_Microsystems>
- Wikipedia, "SunOS": <https://en.wikipedia.org/wiki/SunOS>
- Wikipedia, "Oracle Solaris": <https://en.wikipedia.org/wiki/Oracle_Solaris>
- Wikipedia, "IBM AIX": <https://en.wikipedia.org/wiki/IBM_AIX>
- Wikipedia, "IBM RS/6000": <https://en.wikipedia.org/wiki/IBM_RS/6000>
- Wikipedia, "HP-UX": <https://en.wikipedia.org/wiki/HP-UX>
- Wikipedia, "PA-RISC": <https://en.wikipedia.org/wiki/PA-RISC>
- Wikipedia, "IRIX": <https://en.wikipedia.org/wiki/IRIX>
- Wikipedia, "Tru64 UNIX": <https://en.wikipedia.org/wiki/Tru64_UNIX>
- Wikipedia, "SPARC": <https://en.wikipedia.org/wiki/SPARC>
- Wikipedia, "ZFS": <https://en.wikipedia.org/wiki/ZFS>
- Wikipedia, "DTrace": <https://en.wikipedia.org/wiki/DTrace>
- Wikipedia, "Solaris Containers": <https://en.wikipedia.org/wiki/Solaris_Containers>
- Wikipedia, "Workload Partitions": <https://en.wikipedia.org/wiki/Workload_Partitions>
- Wikipedia, "HP Serviceguard": <https://en.wikipedia.org/wiki/HP_Serviceguard>
- Wikipedia, "cgroups": <https://en.wikipedia.org/wiki/Cgroups>
- Wikipedia, "Berkeley Packet Filter": <https://en.wikipedia.org/wiki/Berkeley_Packet_Filter>
- Wikipedia, "eBPF": <https://en.wikipedia.org/wiki/EBPF>
- Wikipedia, "OpenSolaris": <https://en.wikipedia.org/wiki/OpenSolaris>
- Wikipedia, "Acquisition of Sun Microsystems by Oracle Corporation": <https://en.wikipedia.org/wiki/Acquisition_of_Sun_Microsystems_by_Oracle_Corporation>
- Klara Systems, "History of ZFS - Part 1: The Birth of ZFS": <https://klarasystems.com/articles/history-of-zfs-part-1-the-birth-of-zfs/>
- OpenZFS, "History": <https://openzfs.org/wiki/History>
- Brendan Gregg, "bpftrace (DTrace 2.0) for Linux 2018": <https://www.brendangregg.com/blog/2018-10-08/dtrace-for-linux-2018.html>
- Brendan Gregg, "DTrace Tools": <https://www.brendangregg.com/dtrace.html>
- Brendan Gregg, "Linux eBPF Tracing Tools": <https://www.brendangregg.com/ebpf.html>
- Oracle, "DTrace Tutorial": <https://www.oracle.com/solaris/technologies/dtrace-tutorial.html>
- Oracle, "Oracle Buys Sun": <https://www.oracle.com/corporate/pressrelease/oracle-buys-sun-042009.html>
- IBM Redbooks, "Workload Partition Management in IBM AIX Version 6.1": <https://www.redbooks.ibm.com/abstracts/sg247656.html>
- IEEE Spectrum, "Chip Hall of Fame: Sun Microsystems SPARC Processor": <https://spectrum.ieee.org/chip-hall-of-fame-sun-microsystems-sparc-processor>
- Network World, "The long, slow death of commercial Unix": <https://www.networkworld.com/article/966988/the-long-slow-death-unix.html>
- The Register, "The last supported version of HP-UX is no more": <https://www.theregister.com/2026/01/05/hpux_end_of_life/>
- VMware Open Source Blog, "The Story of Containers": <https://blogs.vmware.com/opensource/2018/02/27/the-story-of-containers/>
- Roman Brick, "Solaris Zones – The Original Container Revolution Missed": <https://romanbrick.substack.com/p/solaris-zones-the-original-container>
- ETHW, "Sun Microsystems": <https://ethw.org/Sun_Microsystems>
- ETHW, "Milestones: SPARC RISC Architecture, 1987": <https://ethw.org/Milestones:SPARC_RISC_Architecture,_1987>
