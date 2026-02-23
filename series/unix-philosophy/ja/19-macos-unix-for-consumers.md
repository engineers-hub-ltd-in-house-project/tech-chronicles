# UNIXという思想

## ――パイプ、プロセス、ファイル――すべてはここから始まった

### 第19回：「macOS――UNIXが消費者の手に届いた日」

**連載「UNIXという思想――パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- NeXTSTEP（1989年）の技術基盤とSteve JobsのApple復帰によるmacOSの誕生経緯
- XNUカーネルの三層構造――Machマイクロカーネル、FreeBSD由来のBSD層、IOKitドライバフレームワーク
- Mac OS X 10.5 Leopard（2007年）のUNIX 03認証取得の意味と、macOSが「正式なUNIX」である技術的根拠
- launchd（2005年）の設計とsystemdへの影響――macOSがLinuxに先駆けたinitシステム改革
- APFS（2017年）の導入とZFS採用断念の経緯――ファイルシステムに見るAppleの設計判断
- 開発者がmacOSを選ぶ理由――UNIXの力とGUIの洗練の共存、HomebrewによるUNIXエコシステム

---

## 1. Terminal.appを開いた日

2010年頃、私はそれまで10年以上使い続けてきたLinuxデスクトップからmacOSに移行した。

きっかけは単純だった。クライアント先でのプレゼンテーション中に、Linuxデスクトップの外部ディスプレイ出力が機能せず、xrandrコマンドを叩いている姿を見せてしまったのだ。内容は技術者向けだったから致命的ではなかったが、「道具に振り回されている」感覚が不快だった。同僚がMacBook Proを開き、ディスプレイケーブルを繋ぎ、何事もなくプレゼンを始める。その当たり前の動作が、私にはできなかった。

MacBook Proを購入して最初にやったことは、Terminal.appを開くことだった。

`ls`が動く。`grep`が動く。`find`が動く。`ssh`でリモートサーバに繋がる。`vim`でファイルを編集できる。当然だ。macOSはUNIXなのだから。だが、当然であることに感動した。私が10年以上かけて身につけたUNIXの操作体系が、そのまま使える。しかもその上に、フォントレンダリングが美しいGUIが載っている。外部ディスプレイは繋ぐだけで動く。スリープから復帰してWi-Fiが切れることもない。

あの日、私は理解した。macOSとは「UNIXの上にAppleのUIを載せたOS」なのだと。そして、この二層構造こそが、macOSが開発者に支持される理由の核心なのだと。

だが「macOSはUNIXである」と言ったとき、その意味を正確に理解している人はどれほどいるだろうか。macOSの下で動いているカーネル――XNU――は、1980年代のCarnegie Mellon大学の研究と、1989年のSteve Jobsの追放劇と、FreeBSDのコードが合流した、複雑な技術史の産物だ。あなたがMacのターミナルで`uname -a`を打ったとき返ってくる「Darwin」という文字列の背後には、UNIXの設計思想が消費者の手に届くまでの30年以上にわたる物語がある。

---

## 2. NeXTSTEP――追放されたJobsがUNIXに出会うまで

### 4億2900万ドルの「帰還」

macOSの起源を辿るには、Steve Jobsの追放劇から始めなければならない。

1985年、Steve JobsはAppleの経営権争いに敗れ、自ら設立した会社を去った。9月16日にNeXT社を法人登記する。Jobsが次に作ろうとしたのは、大学や研究機関向けの高性能ワークステーションだった。NeXTが選んだOSの技術基盤は、Carnegie Mellon大学で開発されていたMachマイクロカーネルだった。

Machは1985年にRichard RashidとAvie Tevanianを中心に開発が始まった。分散コンピューティング研究のために設計されたこのカーネルは、タスク、スレッド、ポート（プロセス間通信）、仮想メモリという四つの抽象化を核とし、OSの基本サービスをユーザ空間に追い出す「マイクロカーネル」アーキテクチャを目指していた。NeXTが採用したMach 2.5は、4.3BSD-Tahoeのカーネルコードを内包するハイブリッド構成だった。純粋なマイクロカーネルではないが、Machの抽象化レイヤとBSDのUNIX互換性を一つのカーネルに統合する設計だった。

1989年9月18日、NeXTSTEP 1.0がリリースされた。Machマイクロカーネルの上にBSD由来のUNIX互換レイヤを載せ、その上にObjective-Cベースのオブジェクト指向フレームワークとDisplay PostScript（PDFベースの描画エンジン）を載せた構造だ。NeXTSTEPは、当時としては異例なほどの開発者体験を提供した。Interface Builderによるビジュアルなアプリケーション開発、オブジェクト指向のAPI設計、そしてその基盤としてのUNIXのコマンドラインとシステムコール群。

NeXTSTEPは技術的には先進的だったが、商業的には苦戦した。NeXTのハードウェアは高価であり（NeXT Computer: 6,500ドル）、市場は限定的だった。しかしNeXTSTEPの上で開発された最も有名なアプリケーションがある。1990年、CERNのTim Berners-LeeがNeXTSTEP上で世界最初のWebブラウザとWebサーバを開発した。World Wide Webの発明は、NeXTSTEPのUNIXネットワーク機能とオブジェクト指向開発環境の上で成し遂げられたのだ。

1993年、NeXTはハードウェア事業から撤退し、ソフトウェア企業へ転身する。NeXTSTEPは他社のハードウェア上で動くOPENSTEPへと進化した。そして1996年12月20日、AppleはNeXTを4億2900万ドルとApple株150万株で買収した。表向きはAppleがNeXTを買収したが、実態はNeXTの技術とSteve JobsがAppleに「帰還」したのだ。1997年9月、Jobsは暫定CEO（本人は"iCEO"と称した）に就任する。

NeXTSTEPの技術資産は、macOSの基盤となった。Machカーネル、BSD層、Objective-Cのフレームワーク、Interface Builder――これらすべてがAppleに移植され、Mac OS Xとして結実する。ここに一つの逆説がある。AppleをUNIXの世界に導いたのは、Appleを追放されたSteve Jobsだった。

### Avie Tevanian――Machからmacへの橋

NeXTからAppleへの技術移転において、Avie Tevanianの存在は決定的だった。

TevanianはCarnegie Mellon大学でMachカーネルの開発に携わった研究者であり、博士論文のテーマもMachに関するものだった。NeXTに移籍してソフトウェア部門の責任者となり、NeXTSTEPの開発を率いた。Apple買収後はAppleのChief Software Technology Officerに就任し、Mac OS Xのアーキテクチャ設計を統括した。

つまり、Tevanianは一人の人間として「Machカーネルの開発者 → NeXTSTEPのソフトウェア責任者 → Mac OS Xのアーキテクト」というキャリアを辿った。macOSの中で今も動いているMachカーネルのコードは、Tevanianが大学院生だった時代に書いた設計の延長線上にある。技術は人を通じて伝播する。macOSのUNIXの血脈は、Carnegie Mellon大学の研究室からNeXTのオフィスを経て、Cupertino（Apple本社所在地）に至ったのだ。

---

## 3. XNU――「UNIXではない」と名乗るUNIXカーネル

### 三層構造のハイブリッドカーネル

macOSのカーネルはXNUと呼ばれる。"X is Not Unix"の再帰的頭字語だ。GNUが"GNU's Not Unix"であるのと同じ命名形式である。「UNIXではない」と名乗りながら、実質的にUNIXのインタフェースを提供する。この名前自体が、macOSの技術的アイデンティティの複雑さを象徴している。

XNUは三つの要素から構成されるハイブリッドカーネルである。

```
XNUカーネルの三層構造:

┌─────────────────────────────────────────────────┐
│                  ユーザ空間                      │
│  アプリケーション / シェル / デーモン            │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │         BSD層 (FreeBSD由来)             │    │
│  │  POSIX API / プロセスモデル             │    │
│  │  ネットワークスタック / VFS              │    │
│  │  ユーザ/グループ / パーミッション       │    │
│  ├─────────────────────────────────────────┤    │
│  │       Mach層 (OSFMK 7.3ベース)         │    │
│  │  タスク / スレッド / 仮想メモリ         │    │
│  │  プロセス間通信（Machポート）           │    │
│  │  スケジューリング                       │    │
│  ├─────────────────────────────────────────┤    │
│  │        IOKit (C++サブセット)            │    │
│  │  デバイスドライバフレームワーク          │    │
│  │  電力管理 / ホットプラグ               │    │
│  └─────────────────────────────────────────┘    │
│                  XNUカーネル                     │
├─────────────────────────────────────────────────┤
│              ハードウェア                        │
└─────────────────────────────────────────────────┘
```

**第一層：Machマイクロカーネル。** OSFMK（Open Software Foundation Mach Kernel）7.3をベースとし、CMU Mach 3.0およびユタ大学のMach 4の成果を取り込んでいる。Machはタスク（プロセスの実行コンテキスト）、スレッド、仮想メモリ管理、Machポートによるプロセス間通信（IPC）を提供する。XNUの最下層であり、ハードウェアとの直接的なやりとり――割り込み処理、メモリマッピング、コンテキストスイッチ――を担う。

**第二層：BSD層。** FreeBSD由来のコードを基盤とし、POSIX API、UNIXプロセスモデル、ネットワークプロトコルスタック（TCP/IP）、仮想ファイルシステム（VFS）、ユーザ/グループ/パーミッションといったUNIXの「顔」を提供する。Machのタスクをラップして「UNIXプロセス」として外部に見せるのがBSD層の役割だ。ユーザ空間のアプリケーションが`fork()`、`exec()`、`open()`、`read()`、`write()`を呼ぶとき、それを受け取るのはBSD層である。

**第三層：IOKit。** Embedded C++（C++のサブセット）で記述されたオブジェクト指向デバイスドライバフレームワーク。デバイスの検出、ドライバのマッチング、電力管理、ホットプラグ対応を提供する。Linuxのデバイスドライバモデルとは異なり、オブジェクト指向の継承関係で整理されている。

この三層構造のポイントは、Machとbsd層の役割分担にある。Machが提供する抽象化——タスク、スレッド、仮想メモリ、IPC——は、UNIXの概念とは異なる。UNIXの「プロセス」はMachでは「タスク」であり、UNIXの「シグナル」はMachでは「メッセージ」だ。BSD層がその間を取り持ち、Machの抽象化をUNIXのインタフェースに翻訳する。

```
Machの抽象化とBSD層のUNIXインタフェース:

Machの概念           BSD層の翻訳          ユーザ空間のAPI
─────────────────────────────────────────────────────
Machタスク      →   UNIXプロセス     →   fork(), exec()
Machスレッド    →   POSIXスレッド    →   pthread_create()
仮想メモリ領域  →   mmap/ファイル    →   mmap(), munmap()
Machポート      →   (直接公開)       →   mach_msg()
               →   ソケット等       →   socket(), pipe()
```

この設計がもたらす利点は、移植性とアーキテクチャ中立性だ。Mach層がハードウェアの違いを吸収するため、その上のBSD層とアプリケーションは、プロセッサアーキテクチャの変更に対して比較的耐性がある。この設計が、後述するApple Silicon（ARM）への移行を支えることになる。

### Darwin――macOSのオープンソース核

2000年4月5日、AppleはmacOSの中核をDarwinとしてオープンソース公開した。Apple Public Source License（APSL）の下、XNUカーネルのソースコードが世界に開かれた。当初のAPSL 1.0はFree Software Foundationから「真にフリーではない」と批判されたが、2003年7月のAPSL 2.0でFSFの承認を得た。

Darwinの公開は技術的に重要な意味を持つ。macOSのカーネルとコアユーティリティはオープンソースだが、GUIフレームワーク（Cocoa）、デスクトップ環境（Aqua）、各種の高レベルフレームワークはクローズドソースのままだ。つまりmacOSは「中核がオープンソース、UIがプロプライエタリ」という二重構造を持つ。Linuxがカーネルからデスクトップ環境まで完全にオープンソースであるのとは対照的だ。

2001年3月24日、Mac OS X 10.0 "Cheetah"がリリースされた。UNIXの技術基盤の上に、Aquaと呼ばれるGUIデスクトップ環境を載せた新世代のmacOSの幕開けである。初期のMac OS Xは動作が緩慢で、Classic環境（旧Mac OSアプリの互換実行レイヤ）との行き来にも時間がかかった。だがAppleは矢継ぎ早にアップデートを重ね、10.1 Puma（2001年9月）で体感速度を大幅に改善し、10.2 Jaguar（2002年8月）でQuartzExtremeによるGPU描画を導入し、10.3 Panther（2003年10月）で実用的なOSとしての完成度に達した。

### UNIX 03認証――macOSは「正式なUNIX」である

2007年、Mac OS X 10.5 Leopardは、The Open GroupからUNIX 03認証を取得した。

この事実の意味は大きい。UNIX 03認証とは、The Open Groupが管理するSingle UNIX Specification Version 3（SUSv3、2004年策定）への適合を認証するものだ。つまりmacOSは、POSIX API、シェル、ユーティリティの振る舞いがSUSv3の仕様に準拠していることを、第三者機関によって認定されている。BSD系OSとしては初のUNIX 03認証だった。

以後、macOSは各バージョンで認証を維持しており、2024年のmacOS 15 Sequoiaに至るまで、Apple SiliconとIntelの両プラットフォームでUNIX 03認定製品であり続けている。

ここで一つ整理しておく。「LinuxはUNIXか」という問いに対する技術的に正確な答えは「No」である。LinuxはUNIXの設計思想を継承し、POSIX互換のAPIを提供しているが、The Open GroupからのUNIX認証は取得していない。一方、macOSはUNIX 03認証を持つ正式な「UNIX」だ。世界で最も広く使われているUNIX認定OSは、企業のサーバルームで動くSolaris（すでに実質的に終了）でも、FreeBSDでもなく、カフェでデザイナーが使っているMacBook上のmacOSなのだ。

```
「UNIX」認証の有無:

┌─────────────────────┬──────────────────┬────────────┐
│ OS                  │ UNIX認証         │ 備考       │
├─────────────────────┼──────────────────┼────────────┤
│ macOS               │ UNIX 03認証済み  │ 2007年〜   │
│ AIX (IBM)           │ UNIX認証済み     │            │
│ HP-UX (HPE)         │ UNIX認証済み     │            │
│ Solaris (Oracle)    │ UNIX認証済み     │ 実質終了   │
├─────────────────────┼──────────────────┼────────────┤
│ Linux               │ 未認証           │ POSIX互換  │
│ FreeBSD             │ 未認証           │ BSD系      │
│ OpenBSD             │ 未認証           │ BSD系      │
└─────────────────────┴──────────────────┴────────────┘

macOSは消費者向けOSでありながら、正式なUNIX認定製品だ。
```

ただし、この認証が保証するのはSUSv3（2004年策定）への準拠であり、より新しいSingle UNIX Specification Version 4（2016年策定）への認証ではない。標準規格としてはやや古い世代の仕様に基づく認証であることは知っておくべきだ。とはいえ、macOSがUNIXの系譜に正式に連なるOSであるという事実は変わらない。

---

## 4. macOSの技術的独自性――UNIXを超えた部分

### launchd――systemdに先駆けたinitシステム改革

第17回でsystemd論争を取り上げた際、「UNIX哲学の"小さなツール"原則に反する」という批判を紹介した。だが実は、systemdの設計に影響を与えたinitシステムが、macOSにすでに存在していた。

2005年、Mac OS X 10.4 TigerでAppleのDave Zarzyckiが設計したlaunchdが導入された。launchdは、従来のBSD init、inetd（ネットワークサービス管理）、cron（定時実行）、SystemStarter（Appleの独自起動スクリプト）の機能を一つのデーモンに統合した。

launchdの核心的な設計は**ソケットアクティベーション**にある。従来のinetdと同様に、サービスが使用するソケットをlaunchdが先に確保し、実際の接続要求が来てから対応するデーモンを起動する。これにより、ブート時にすべてのサービスを起動する必要がなくなり、起動時間が短縮される。さらにlaunchdは、サービスの依存関係を宣言的に記述するplist（Property List）ファイルによって管理され、起動順序の自動解決も行う。

5年後の2010年、Lennart Poetteringは"Rethinking PID 1"というブログ記事でsystemdの設計思想を公開した。その中でPoetering自身がlaunchdに言及し、ソケットアクティベーションの着想元の一つとして明確に参照している。systemdはlaunchdの「コピー」ではなく、Upstart、Solaris SMFなど複数の先行システムからも着想を得ている。だがlaunchdが示した「initの機能統合」という方向性が、systemdの設計に影響を与えたことは事実だ。

```
initシステムの進化:

BSD init (1983〜)        SysV init (1983〜)
  │                        │
  │  シェルスクリプト       │  ランレベル + rcスクリプト
  │  による逐次起動        │  による逐次起動
  │                        │
  └──────┬─────────────────┘
         │
    ┌────┴────┐
    │  macOS  │
    │ launchd │  (2005年, Dave Zarzycki)
    │         │  init + inetd + cron統合
    │         │  ソケットアクティベーション
    │         │  plistによる宣言的設定
    └────┬────┘
         │ 影響
    ┌────┴─────────┐
    │    Linux     │
    │   systemd    │  (2010年, Lennart Poettering)
    │              │  ユニットファイルによる宣言的設定
    │              │  ソケットアクティベーション
    │              │  cgroups統合
    └──────────────┘
```

macOSのlaunchdは、Linux世界のsystemd論争に先行する形で「initシステムの統合」を実現していた。macOSのユーザの多くは気づいていないだろうが、Macの裏側では2005年から、UNIXの伝統的なinitを超えた統合サービス管理が動いていた。

### APFS――ファイルシステムの世代交代

macOSのファイルシステムの歴史は、Appleの設計判断を理解する好例だ。

macOSは長年、HFS+（Hierarchical File System Plus、1998年導入）をデフォルトファイルシステムとして使用していた。HFS+はクラシックMac OS時代のHFS（1985年）を拡張したもので、フラッシュストレージを前提としない時代の設計を引きずっていた。大文字小文字を区別しない（case-insensitive）のがデフォルトであり、これはUNIXの伝統――ファイルシステムはcase-sensitiveであるべき――とは相容れない特性だった。

Appleは一時、SunのZFSの採用を検討した。Mac OS X Leopard～Snow Leopard期にZFSの実装を進め、開発者向けプレビューまで公開していた。ZFSは第11回で取り上げた通り、コピーオンライト、スナップショット、データ整合性検証、128ビットアドレッシングなど、圧倒的に先進的な設計を持つファイルシステムだ。だが2009年10月、AppleはZFSプロジェクトを中止した。公式な理由は明かされていないが、ZFSのCDDL（Common Development and Distribution License）がAppleのライセンス戦略と相容れなかったこと、さらにNetAppとの特許問題リスクが要因とされている。

結果として、Appleは独自のファイルシステムを一から構築する道を選んだ。2017年、macOS 10.13 High SierraでAPFS（Apple File System）が導入された。フラッシュストレージに最適化され、コピーオンライト、スナップショット、ネイティブ暗号化、スペースシェアリング（複数ボリュームがストレージプールを共有）といった現代的な機能を備える。ZFSの影響を直接受けているかどうかはAppleが公言していないが、コピーオンライトやスナップショットといった類似する設計要素は見受けられる。

このエピソードが示すのは、Appleの設計判断の一貫した特徴だ。外部の優れた技術（Mach、FreeBSD、ZFS）を検討し、自社の要件に合う部分を取り込み、合わない部分は独自に再実装する。macOSのUNIXの血脈は「純粋な継承」ではなく「選択的な吸収と独自の発展」である。

### BSDコマンドとGNUコマンドの差異

macOSのUNIX環境を日常的に使う開発者が必ず直面する問題がある。macOSのコマンドラインツールはFreeBSD由来のBSD版であり、Linux環境で慣れ親しんだGNU版とはオプション体系が異なるのだ。

最も頻繁に遭遇する差異は`sed`だ。LinuxのGNU sedでは`sed -i 's/old/new/g' file`がファイルを直接編集する。macOSのBSD sedでは`sed -i '' 's/old/new/g' file`と、`-i`の後に空文字列のバックアップ拡張子を明示する必要がある。`grep`のオプション、`date`コマンドのフォーマット指定、`xargs`の挙動もBSD版とGNU版で異なる。

```
BSD版とGNU版の代表的な差異:

コマンド    BSD (macOS)                   GNU (Linux)
──────────────────────────────────────────────────────
sed -i      sed -i '' 's/a/b/g' file     sed -i 's/a/b/g' file
date        date -v+1d                   date -d '+1 day'
xargs       xargs（空入力でも実行）      xargs（空入力で実行しない）
grep -P     非対応                        Perl互換正規表現
readlink    readlink file                readlink -f file
stat        stat -f '%m' file            stat -c '%Y' file
```

この差異は、macOSがFreeBSDのユーザランドを基盤としていることの直接的な帰結だ。macOSのBSDコマンドはアップストリームのFreeBSDから独自に分岐しており、GNU拡張は含まれていない。Linux環境用に書いたシェルスクリプトがmacOSで動かない原因の多くは、この差異に起因する。Homebrewでcoreutilsパッケージをインストールすれば、`g`プレフィックス付き（`ggrep`、`gsed`等）でGNU版を使えるが、それは対症療法にすぎない。

POSIX準拠のシェルスクリプトを書く——GNU拡張に依存しない——ことが、macOSとLinuxの両方で動くスクリプトを書くための正道だ。この話題は第10回のPOSIX標準化の回で触れた内容と直接つながる。

---

## 5. ハンズオン：macOSのUNIX層を探索する

このハンズオンでは、macOSの「下」で動いているUNIXの実体を確認する。macOS環境を持っていない読者も、記載されたコマンドの出力例から構造を理解できるように構成した。Docker環境での代替演習も提供する。

### 環境構築

```bash
# macOS環境を持つ場合はTerminal.appで直接実行できる。
# macOSを持っていない場合、Docker上のFreeBSD環境で
# BSD系コマンドの挙動を確認する代替演習を用意した。
# 基本演習はUbuntu 24.04のDocker環境で実行する。
docker pull ubuntu:24.04
```

### 演習1：macOSのDarwin層を確認する（macOS環境向け）

macOSのTerminal.appで以下を実行し、macOSがUNIXであることを確認する。

```bash
# macOSのシステム情報を確認する
echo "=== macOSのUNIX層を確認する ==="
echo ""

echo "--- sw_vers: macOSバージョン情報 ---"
sw_vers
echo ""

echo "--- uname -a: カーネル情報 ---"
uname -a
# 出力例:
# Darwin MacBook-Pro.local 24.x.x Darwin Kernel Version 24.x.x:
# ... root:xnu-xxxxx.x.x~x/RELEASE_ARM64_T6000 arm64
#
# 「Darwin」がOSの名前、「xnu-」がXNUカーネルのバージョン、
# 「ARM64」がApple Siliconのアーキテクチャを示す。
echo ""

echo "--- XNUカーネルのバージョン ---"
sysctl kern.version
# XNUのバージョン番号が確認できる。
# 「xnu-」に続く番号はAppleのビルド番号体系に対応する。
echo ""

echo "--- POSIX準拠の確認 ---"
getconf _POSIX_VERSION
# 出力例: 200112 (POSIX.1-2001) または 200809 (POSIX.1-2008)
echo ""

echo "--- BSD由来のコマンド群 ---"
echo "ls のバージョン:"
ls --version 2>&1 || echo "(BSD版lsは--versionを持たない。これがGNU版との違いだ)"
echo ""
echo "sed のバージョン:"
sed --version 2>&1 || echo "(BSD版sedは--versionを持たない)"
echo ""

echo "--- macOSのカーネル拡張（kext）一覧の抜粋 ---"
kextstat 2>/dev/null | head -5 || kmutil showloaded 2>/dev/null | head -5
echo "(IOKitベースのドライバがロードされている)"
```

### 演習2：BSDコマンドとGNUコマンドの差異を体験する

macOSのBSD版コマンドとLinuxのGNU版コマンドの差異を実際に確認する。

```bash
docker run --rm ubuntu:24.04 bash -c '
echo "=== BSDコマンドとGNUコマンドの差異 ==="
echo ""
echo "macOSはFreeBSD由来のBSD版コマンドを使用する。"
echo "LinuxはGNU版コマンドを使用する。"
echo "同じコマンド名でもオプション体系が異なることがある。"
echo ""

# GNU版sedのバージョン確認
echo "--- GNU sed（Linux） ---"
sed --version 2>&1 | head -1
echo ""

# ファイルの直接編集: -i オプションの違い
echo "--- sed -i の違い ---"
echo "Hello World" > /tmp/test.txt

echo "GNU sed (Linux):    sed -i \"s/Hello/Goodbye/\" /tmp/test.txt"
sed -i "s/Hello/Goodbye/" /tmp/test.txt
cat /tmp/test.txt

echo ""
echo "BSD sed (macOS):    sed -i \"\" \"s/Hello/Goodbye/\" file"
echo "  → -iの後に空文字列のバックアップ拡張子が必要"
echo "  → GNU sedでは -i のみで直接編集可能"
echo ""

# date コマンドの違い
echo "--- date コマンドの違い ---"
echo "GNU date (Linux):   date -d \"+1 day\"  → 明日の日付"
date -d "+1 day" "+%Y-%m-%d" 2>/dev/null || echo "(実行エラー)"
echo ""
echo "BSD date (macOS):   date -v+1d        → 明日の日付"
echo "  → GNU版の -d オプションはBSD版には存在しない"
echo "  → BSD版の -v オプションはGNU版には存在しない"
echo ""

# readlink の違い
echo "--- readlink の違い ---"
ln -sf /tmp/test.txt /tmp/link.txt
echo "GNU readlink (Linux): readlink -f /tmp/link.txt"
readlink -f /tmp/link.txt
echo ""
echo "BSD readlink (macOS):  readlink -f は非対応の場合がある"
echo "  → macOSでは realpath コマンドが代替"
echo ""

# POSIX準拠のポータブルな書き方
echo "=== POSIX準拠のポータブルな代替 ==="
echo ""
echo "macOSとLinuxの両方で動くスクリプトを書くには、"
echo "GNU拡張やBSD拡張に依存しない書き方が重要だ。"
echo ""
echo "日付操作（移植可能な方法）:"
echo "  GNU/BSD拡張を使わず、POSIX準拠の方法で日付計算を行う:"
echo "  tomorrow=\$(date -d \"+1 day\" +%Y-%m-%d 2>/dev/null ||"
echo "            date -v+1d +%Y-%m-%d 2>/dev/null)"
echo ""
echo "sed -i の移植可能なパターン:"
echo "  sed -i.bak \"s/old/new/g\" file && rm file.bak"
echo "  → .bak拡張子を指定すればBSD/GNU両方で動く"
echo ""

# 実際にポータブルなsed -iを実行
echo "Hello World" > /tmp/portable.txt
sed -i.bak "s/Hello/Portable/" /tmp/portable.txt && rm /tmp/portable.txt.bak
echo "ポータブルsed -iの結果: $(cat /tmp/portable.txt)"
'
```

### 演習3：XNUカーネルの構造をソースコードから確認する

AppleはXNUカーネルのソースコードを公開している。その構造を確認する。

```bash
docker run --rm ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq git > /dev/null 2>&1

echo "=== XNUカーネルのソースコード構造 ==="
echo ""
echo "AppleはXNUカーネルのソースコードをGitHubで公開している。"
echo "https://github.com/apple-oss-distributions/xnu"
echo ""

echo "--- XNUのディレクトリ構造（概要）---"
echo ""
echo "xnu/"
echo "├── bsd/           ← FreeBSD由来のBSD層"
echo "│   ├── kern/      ← UNIXプロセスモデル、シグナル処理"
echo "│   ├── vfs/       ← 仮想ファイルシステム"
echo "│   ├── net/       ← ネットワークスタック"
echo "│   ├── nfs/       ← NFSクライアント"
echo "│   └── sys/       ← システムコール定義"
echo "│"
echo "├── osfmk/         ← Machマイクロカーネル層"
echo "│   ├── kern/      ← タスク、スレッド、スケジューラ"
echo "│   ├── vm/        ← 仮想メモリ管理"
echo "│   ├── ipc/       ← Machポート、メッセージ"
echo "│   ├── arm64/     ← ARM64アーキテクチャ固有コード"
echo "│   └── x86_64/    ← x86_64アーキテクチャ固有コード"
echo "│"
echo "├── iokit/          ← IOKitドライバフレームワーク"
echo "│   ├── IOKit/     ← ドライバ基底クラス"
echo "│   └── Kernel/    ← カーネル空間IOKit"
echo "│"
echo "├── libkern/        ← カーネル空間ライブラリ"
echo "├── security/       ← セキュリティフレームワーク"
echo "└── EXTERNAL_HEADERS/ ← 外部公開ヘッダ"
echo ""

echo "=== Machの抽象化とBSD層の対応 ==="
echo ""
echo "XNUでは、一つの実行コンテキストに対して"
echo "Machの表現とBSDの表現が並存する:"
echo ""
echo "  Machタスク (task_t)  ←→  BSDプロセス (proc_t)"
echo "  ┌─────────────────────────────────────────┐"
echo "  │ Machタスク                               │"
echo "  │  - 仮想アドレス空間                      │"
echo "  │  - Machポート名前空間                    │"
echo "  │  - タスクのスレッド群                    │"
echo "  │                                         │"
echo "  │  ┌──────────────────────────────┐       │"
echo "  │  │ BSDプロセス                   │       │"
echo "  │  │  - PID                       │       │"
echo "  │  │  - UID/GID                   │       │"
echo "  │  │  - ファイルディスクリプタ表   │       │"
echo "  │  │  - シグナルハンドラ          │       │"
echo "  │  └──────────────────────────────┘       │"
echo "  └─────────────────────────────────────────┘"
echo ""
echo "fork()が呼ばれると、BSD層はまずMachのtask_create()で"
echo "新しいタスクを作成し、その上にBSDプロセス構造体を初期化する。"
echo "ユーザ空間からは「UNIXプロセス」に見えるが、"
echo "カーネル内部では「Machタスク + BSDプロセス」の二重表現だ。"
'
```

### 演習4：launchdとsystemdの設定比較

macOSのlaunchdとLinuxのsystemdを比較し、initシステム統合の設計思想の共通点を確認する。

```bash
docker run --rm ubuntu:24.04 bash -c '
echo "=== launchd vs systemd: initシステムの設計比較 ==="
echo ""

echo "--- launchd (macOS, 2005年〜) ---"
echo ""
echo "launchdのサービス定義はplist（Property List）形式:"
echo ""
cat << "PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.myservice</string>

    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/myservice</string>
        <string>--port</string>
        <string>8080</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>Sockets</key>           <!-- ソケットアクティベーション -->
    <dict>
        <key>Listeners</key>
        <dict>
            <key>SockServiceName</key>
            <string>8080</string>
        </dict>
    </dict>
</dict>
</plist>
PLIST
echo ""

echo "--- systemd (Linux, 2010年〜) ---"
echo ""
echo "systemdのサービス定義はINI形式のユニットファイル:"
echo ""
cat << "UNIT"
[Unit]
Description=My Service
After=network.target

[Service]
ExecStart=/usr/local/bin/myservice --port 8080
Restart=always

[Install]
WantedBy=multi-user.target
UNIT
echo ""

echo "--- 対応するソケットアクティベーション定義 ---"
cat << "SOCKET"
[Unit]
Description=My Service Socket

[Socket]
ListenStream=8080

[Install]
WantedBy=sockets.target
SOCKET
echo ""

echo "=== 設計思想の比較 ==="
echo ""
echo "共通点:"
echo "  - 宣言的な設定ファイル（命令型シェルスクリプトではない）"
echo "  - ソケットアクティベーション（接続時にサービス起動）"
echo "  - プロセスの自動再起動（KeepAlive / Restart=always）"
echo "  - 依存関係の自動解決"
echo ""
echo "相違点:"
echo "  - 設定形式: plist（XML） vs ユニットファイル（INI）"
echo "  - スコープ: launchdはmacOS専用 vs systemdは多くのLinuxディストロで採用"
echo "  - cgroups統合: systemdはcgroupsでリソース制限 vs launchdはなし"
echo "  - 範囲拡大: systemdはログ、ネットワーク、DNS等まで統合"
echo "             launchdは比較的initの領域に留まる"
echo ""
echo "launchd (2005) → systemd (2010)"
echo "macOSが先行した「initシステムの統合」を、"
echo "systemdがLinuxの文脈で拡張・発展させた。"
'
```

### 演習5：macOSのアーキテクチャ移行とカーネルの中立性

macOS/Darwinが複数のCPUアーキテクチャ移行を成功させてきた歴史を、カーネル設計の観点から確認する。

```bash
docker run --rm ubuntu:24.04 bash -c '
echo "=== macOSのアーキテクチャ移行の歴史 ==="
echo ""
echo "macOS（とその前身）は、4回のCPUアーキテクチャ移行を経験した。"
echo "これはOS史上、最も多くのアーキテクチャ移行を成功させた例の一つだ。"
echo ""
echo "  1984年   Motorola 68000系     (Macintosh)"
echo "    ↓"
echo "  1994年   PowerPC              (Power Macintosh)"
echo "    ↓"
echo "  2006年   Intel x86/x86_64     (Intel Mac)"
echo "    ↓"
echo "  2020年   Apple Silicon (ARM64) (M1 Mac〜)"
echo ""
echo "Mac OS X以降の2回の移行（PowerPC→Intel、Intel→ARM）は"
echo "XNUカーネルの設計が成功の鍵だった。"
echo ""

echo "--- Machのアーキテクチャ抽象化 ---"
echo ""
echo "Machマイクロカーネルは設計時から移植性を重視していた。"
echo "Carnegie Mellon大学でのMach開発当初から、"
echo "VAX、IBM RT、Sun 3、Intel i386など複数のアーキテクチャに"
echo "移植されていた。XNUはこの設計を継承している。"
echo ""
echo "XNUのアーキテクチャ固有コードは osfmk/ 配下に分離:"
echo ""
echo "  osfmk/"
echo "  ├── arm/         ← ARM32（iOS用）"
echo "  ├── arm64/       ← ARM64（Apple Silicon Mac + iOS）"
echo "  ├── x86_64/      ← Intel Mac用"
echo "  └── kern/        ← アーキテクチャ非依存のカーネルコード"
echo ""
echo "アーキテクチャ固有部分（コンテキストスイッチ、"
echo "割り込み処理、仮想メモリのページテーブル操作）を"
echo "明確に分離することで、カーネルの大部分は"
echo "アーキテクチャ変更の影響を受けない。"
echo ""

echo "--- Universal Binary / Rosetta ---"
echo ""
echo "PowerPC→Intel移行（2006年）:"
echo "  - Universal Binary: 一つの実行ファイルに"
echo "    PowerPCとIntel両方のコードを含む"
echo "  - Rosetta: PowerPCバイナリをIntel上で"
echo "    動的変換して実行するエミュレーション層"
echo ""
echo "Intel→Apple Silicon移行（2020年）:"
echo "  - Universal Binary 2: IntelとARM64の両コードを含む"
echo "  - Rosetta 2: Intelバイナリ(x86_64)をARM64上で実行"
echo "    AOT（Ahead-of-Time）変換で高いパフォーマンスを実現"
echo ""
echo "Linuxカーネルもマルチアーキテクチャに対応しているが、"
echo "「一つのバイナリで複数アーキテクチャを実行する」Universal Binaryは"
echo "macOS独自のアプローチだ。"
echo ""

echo "=== arm64eアーキテクチャ ==="
echo ""
echo "Apple SiliconのmacOSはarm64eアーキテクチャを使用する。"
echo "これは標準的なARM64にPointer Authentication（PAC）を"
echo "追加したApple独自拡張だ。"
echo ""
echo "Pointer Authentication:"
echo "  - ポインタに暗号学的署名を付与"
echo "  - ROP（Return-Oriented Programming）攻撃を困難にする"
echo "  - カーネル空間とユーザ空間の両方で有効"
echo ""
echo "XNUカーネル自体がPACで保護されており、"
echo "カーネルレベルのエクスプロイトに対する耐性が向上している。"
echo "UNIXの伝統的なuid/gidセキュリティモデルを超えた、"
echo "ハードウェアレベルのセキュリティ機構だ。"
'
```

---

## 6. まとめと次回予告

### この回の要点

macOSのUNIXとしての系譜は、1985年のSteve Jobsの追放に始まる。JobsがNeXTで選択したMachマイクロカーネルとBSD層の組み合わせは、1996年のAppleによるNeXT買収を経て、Mac OS Xの技術基盤となった。Carnegie Mellon大学でMachを開発したAvie Tevanianは、NeXTを経てAppleのChief Software Technology Officerとなり、Machの血脈をmacOSに直接つないだ。

XNUカーネルは三つの要素――Machマイクロカーネル（OSFMK 7.3）、FreeBSD由来のBSD層、IOKitドライバフレームワーク――から構成されるハイブリッドカーネルだ。「X is Not Unix」という再帰的頭字語を持ちながら、BSD層がMachの抽象化をUNIXインタフェースに翻訳することで、POSIX互換のUNIX環境を提供している。2007年のUNIX 03認証取得により、macOSは正式な「UNIX」を名乗れるOSとなった。

macOSはUNIXを単に継承しただけではない。launchd（2005年）はLinuxのsystemdに先駆けてinitシステムの統合を実現し、APFS（2017年）はフラッシュストレージ時代のファイルシステムを独自に構築した。4回のCPUアーキテクチャ移行を支えたのは、Machから受け継いだアーキテクチャ中立性の設計思想だ。

macOSが示した最大の功績は、UNIXを「消費者の手に届けた」ことだ。世界中のカフェやオフィスで使われているMacBookの下で、UNIXのカーネルが動いている。ほとんどのユーザはそれを知らないが、開発者にとってmacOSの魅力の核心は、Terminal.appを開けばUNIXの全力が使えるという事実にある。

### 冒頭の問いへの暫定回答

「世界で最も"身近な"UNIXはmacOSである。この事実は何を意味するのか。」

UNIXの設計思想が「専門家だけのもの」から「すべてのコンピュータユーザのもの」になったということだ。macOSは、UNIXの力を意識させずに消費者に届けた。だが開発者にとっての意味は異なる。macOSは「GUIが使えるUNIXワークステーション」であり、その二層構造――UNIXの基盤とAppleのUIの共存――が、開発環境としての独自の価値を生み出している。NeXTSTEPに始まるこのアーキテクチャは、Steve Jobsの追放という偶然がなければ存在しなかった。技術の歴史は、時に個人の運命と交差する。

### 次回予告

次回は「DockerとKubernetes――UNIX原則の現代的帰結」。コンテナ技術の話だ。

2013年、Solomon HykesがDockerを公開したとき、多くの人はそれを「軽量な仮想マシン」だと思った。だがDockerの本質は仮想マシンではない。UNIXのプロセス分離――namespaces――とリソース制限――cgroups――の組み合わせだ。1979年のBill Joyによるchroot、2000年のFreeBSD Jails、2004年のSolaris Zones、そして第18回で取り上げたPlan 9のper-process名前空間。コンテナ技術は、UNIXの設計原則の50年にわたる蓄積の上に立っている。

「一つのコンテナには一つのプロセス」というベストプラクティスは、UNIX哲学の「一つのことをうまくやれ」と何が違うのだろうか。

---

## 参考文献

- Apple Newsroom, "Apple Releases Darwin 1.0 Open Source", April 5, 2000: <https://www.apple.com/newsroom/2000/04/05Apple-Releases-Darwin-1-0-Open-Source/>
- Apple Newsroom, "Apple unleashes M1", November 10, 2020: <https://www.apple.com/newsroom/2020/11/apple-unleashes-m1/>
- Apple Developer Documentation, "BSD Overview": <https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/KernelProgramming/BSD/BSD.html>
- Apple Developer Documentation, "Kernel Programming Guide": <https://developer.apple.com/library/archive/documentation/Darwin/Conceptual/KernelProgramming/Architecture/Architecture.html>
- The Open Group, "Register of UNIX Certified Products": <https://www.opengroup.org/openbrand/register/>
- Wikipedia, "NeXTSTEP": <https://en.wikipedia.org/wiki/NeXTSTEP>
- Wikipedia, "XNU": <https://en.wikipedia.org/wiki/XNU>
- Wikipedia, "Mach (kernel)": <https://en.wikipedia.org/wiki/Mach_(kernel)>
- Wikipedia, "Darwin (operating system)": <https://en.wikipedia.org/wiki/Darwin_(operating_system)>
- Wikipedia, "macOS version history": <https://en.wikipedia.org/wiki/MacOS_version_history>
- Wikipedia, "Apple File System": <https://en.wikipedia.org/wiki/Apple_File_System>
- Wikipedia, "Launchd": <https://en.wikipedia.org/wiki/Launchd>
- Wikipedia, "Homebrew (package manager)": <https://en.wikipedia.org/wiki/Homebrew_(package_manager)>
- Wikipedia, "Apple M1": <https://en.wikipedia.org/wiki/Apple_M1>
- GitHub, apple-oss-distributions/xnu: <https://github.com/apple-oss-distributions/xnu>
- Lennart Poettering, "Rethinking PID 1", 2010: <http://0pointer.de/blog/projects/systemd.html>
- OSnews, "macOS 15.0 now UNIX 03-certified", 2024: <https://www.osnews.com/story/140868/macos-15-0-now-unix-03-certified/>
- FreeBSD Foundation, "Apple's Open Source Roots: The BSD Heritage Behind macOS and iOS": <https://freebsdfoundation.org/news-and-events/latest-news/apples-open-source-roots-the-bsd-heritage-behind-macos-and-ios/>
