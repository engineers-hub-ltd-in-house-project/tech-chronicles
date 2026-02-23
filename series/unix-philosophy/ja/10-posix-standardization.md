# UNIXという思想

## ——パイプ、プロセス、ファイル――すべてはここから始まった

### 第10回：「POSIX標準化——"標準UNIX"は実現したか」

**連載「UNIXという思想——パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- UNIXの「標準化」がなぜ必要とされたのか——BSD vs System Vの分裂がもたらした移植性の危機
- POSIX（IEEE 1003.1）が策定されるまでの前史——/usr/group Standard（1984年）、SVID、X/Open XPGという三つの標準化の試み
- Richard Stallmanが「POSIX」という名前を命名した経緯とその動機
- POSIXが標準化した範囲——システムコール、シェル、ユーティリティ、pthreads——と、意図的に標準化しなかった範囲——GUI、パッケージ管理、サービス管理
- Single UNIX Specification（SUS）とSpec 1170の誕生——UNIX Warsの残滓を収束させた業界連携
- The Open GroupによるUNIX商標管理と認証プログラム（UNIX 95/98/03）の意味
- macOSがUNIX 03認証を取得しているという事実が実際に保証すること
- POSIX準拠（compliance）と適合（conformance）の乖離——「標準」が「互換」を意味しない現実

---

## 1. 「標準」という名の幻想

2000年代後半、私はある移植プロジェクトに参加していた。商用UNIXで動いていた基幹システムをLinuxに移行する案件だ。両方のOSが「POSIX準拠」を謳っている。標準化されたインタフェースに従っているのだから、移植は比較的容易なはずだ——そう楽観していた。

現実は甘くなかった。

まず、ファイルパスの長さ制限が異なった。POSIX は `PATH_MAX` を定義しているが、その値は実装依存だ。移行元のOSでは1023バイト、移行先のLinuxでは4096バイト。コード上は問題ないように見えるが、テストケースの期待値が合わない。次に、`signal()` 関数の振る舞いが微妙に異なった。BSDスタイルのreliable signalsを前提としたコードが、移行先の環境で不安定に動作する。glibcのバージョンとコンパイルフラグの組み合わせで `signal()` のセマンティクスが変わるのだ。結局、すべてのシグナル処理を `sigaction()` に書き換えることになった。

さらに厄介だったのは、POSIXが定義していない領域だ。パッケージの依存関係管理、サービスの起動制御、ログのローテーション——これらは標準の範囲外で、OS間で完全に異なる。移植作業の大半は、POSIXが「標準化しなかった」部分に費やされた。

「POSIX準拠」は、同じ言語を話すことを保証する。だが同じ言語を話す人間同士でも、方言が通じないことがある。標準化とは、その方言の溝をどこまで埋められたのか——そして、どこに埋められない溝を残したのか——の物語だ。

あなたが書いているシェルスクリプトは、POSIX準拠だろうか。bashの配列やプロセス置換を使っていないだろうか。使っているなら、そのスクリプトはmacOSのデフォルトシェル（zsh）やBusyBoxのashでは動かないかもしれない。「標準」という言葉の意味と限界を、一緒に考えてみたい。

---

## 2. 標準化への三つの道——POSIXの前史

### 分裂がもたらした危機

前回の記事で、BSDとSystem Vの分裂を詳しく見た。シグナル処理、ネットワーキングAPI、ファイルシステム、端末制御、プロセス間通信——あらゆる層にわたる設計思想の対立があった。そしてUNIX Warsにおいて、OSF（Open Software Foundation）とUnix Internationalが政治的に対立した。

この分裂は、ソフトウェア開発者にとって深刻な実害をもたらした。あるUNIX系OS向けに書いたプログラムが、別のUNIX系OSでそのままコンパイル・実行できない。シグナルの挙動が違う。IPCのAPIが違う。端末制御の構造体が違う。同じ「UNIX」を名乗りながら、ソースコードレベルでの互換性が保証されない。

この状況を解決するために、1980年代に三つの標準化の試みが並行して動いた。

### 第一の道：/usr/group Standard（1984年）

最も早い標準化の試みは、UNIXユーザーコミュニティから生まれた。

/usr/group（UNIXのユーザーグループ組織、後にUniForum と改称）のStandards Committeeが1981年に活動を開始した。UNIXの各実装間で共通するプログラミングインタフェースを特定し、文書化する作業だ。3年間の議論と調整を経て、1984年1月17日に/usr/group Standardが公表された。

この文書は、UNIXのシステムコールとCライブラリの共通インタフェースを定義する最初の体系的な試みだった。AT&TのUNIXでもBSDでも動くプログラムを書くために、「最低限これだけは同じであるべき」というインタフェースの集合を定めたのだ。

/usr/group Standardの意義は、その内容自体よりも、「UNIXに標準が必要だ」という認識を業界全体に広めたことにある。この文書がIEEE P1003プロジェクトの直接的な基盤となった。1985年、IEEEが/usr/group の作業を引き継ぎ、P1003（後のPOSIX）として正式な標準化プロセスに載せた。

### 第二の道：System V Interface Definition（1985年）

AT&Tは独自の標準化を進めていた。

1985年春、AT&TはSystem V Interface Definition（SVID）第1版を公表した。System V Release 2（SVR2）のプログラミングインタフェースを定義した文書で、AT&Tにとってのゲームチェンジャーだった。AT&TはSVID準拠を「System V」ブランド使用の条件とした。System Vと名乗りたければ、SVIDに適合しなければならない。

1986年にはSVR3に基づくSVID第2版が3巻構成で公表された。SVIDはAT&Tの商用戦略と不可分に結びついていた。標準を自ら定義し、その標準に従うことをブランド使用の条件とする——AT&Tは標準化を商業的武器として使ったのだ。

だがSVIDの限界は明らかだった。これはAT&Tの一社標準であり、BSDの技術は含まれていない。Berkeley socketsもFFS（Fast File System）もreliable signalsも、SVIDの範囲外だった。BSDユーザーにとって、SVIDはSystem Vの押しつけに映った。

### 第三の道：X/Open Portability Guide（1985年〜）

ヨーロッパから別の動きが生まれた。

1984年、Bull、ICL、Siemens、Olivetti、Nixdorfの5社がX/Openコンソーシアムを設立した（1985年にPhilipsとEricssonが加入し、X/Openの名称を正式に採用）。ヨーロッパのコンピュータメーカーが、アメリカの二大勢力（AT&TとBSD）のどちらにも依存しない、中立的なUNIX標準を求めたのだ。

X/Openは1985年にX/Open Portability Guide Issue 1（XPG1）を公表した。基本的なOSインタフェース、C言語、COBOL、ISAMなどをカバーする実装ガイドだ。以降、XPG2（1987年、国際化やIPCを追加）、XPG3（1989年、POSIX仕様との収斂を図る）、XPG4（1992年7月）と改版を重ねた。

X/Openのアプローチは/usr/groupやIEEEとは異なっていた。IEEEが「最小限の共通インタフェース」を定義したのに対し、X/Openはより広範な「実装要件」を定めた。IEEEのPOSIXが「理論的に最低限必要なもの」なら、X/OpenのXPGは「実用的に必要なもの」を集めた文書だった。XPG3以降はPOSIX仕様をベースにしつつ、POSIXが定義しない国際化機能やCurses（端末制御ライブラリ）などを追加した。

この三つの道——/usr/group（コミュニティ）、SVID（AT&T）、XPG（ヨーロッパ連合）——は、それぞれ異なる立場からUNIXの標準化を試みた。だが最終的に歴史的に最も大きな影響力を持ったのは、/usr/groupの作業を引き継いだIEEEのPOSIXだった。

---

## 3. POSIX——「移植可能なOSインタフェース」の設計

### 名前の由来——Stallmanの提案

1988年、IEEEはUNIXインタフェースの標準仕様を完成させた。だが仕様には簡潔な名前がなかった。正式名称は「Portable Operating System Interface for Computer Environments」——長すぎて実用的ではない。

委員会は「IEEEIX」という略称を候補にした。Richard Stallmanはこの名前を良いとは思わなかった。Stallmanは「portable operating system」の頭文字を取り、UNIXを連想させる「ix」を末尾に付けて「POSIX」を提案した。IEEEはこの名称を即座に採用した。

Stallmanには戦略的な動機があった。GNUプロジェクトはUNIXの互換環境を構築していたが、「GNUはUNIXではない」（GNU's Not Unix）というのがプロジェクトの立場だった。標準インタフェースに「UNIX」とは別の名前が付けば、GNU互換システムをUNIXとは独立した存在として位置づけやすくなる。

些細なエピソードに見えるかもしれないが、命名は重要だ。「POSIX」という名前があったからこそ、この標準はUNIXの特定の実装から独立した概念として普及した。LinuxもmacOSもFreeBSDも、UNIXの派閥に関係なく「POSIX準拠」を目指すことができた。もし標準の名前が「UNIX Standard」だったなら、AT&Tの商標問題に巻き込まれ、広く受け入れられなかった可能性がある。

### POSIX.1——システムインタフェースの標準化（1988年）

IEEE Std 1003.1-1988（POSIX.1）は、UNIXシステムのCプログラミングインタフェースを標準化した。

POSIX.1-1988は、当時の主要なUNIX実装——V7 UNIX、System III、System V、4.2BSD、4.3BSD——から共通するインタフェースを抽出し、「移植可能なプログラムを書くために必要な最小限のAPI」を定義した。具体的には以下の領域をカバーしている。

```
POSIX.1-1988 が標準化した主要領域:

  プロセス管理:
    fork(), exec(), wait(), exit()
    プロセスグループ、セッション

  ファイルI/O:
    open(), read(), write(), close(), lseek()
    stat(), chmod(), chown()
    ディレクトリ操作（opendir(), readdir(), closedir()）

  シグナル:
    sigaction() -- BSDのreliable signalsを基に標準化
    sigprocmask(), sigpending(), sigsuspend()

  パイプ:
    pipe()

  環境変数:
    getenv()

  端末制御:
    termios構造体 -- BSDのtermiosを基に標準化
    tcgetattr(), tcsetattr()
```

注目すべきは、BSDとSystem Vの対立をPOSIXがどう解決したかだ。

シグナル処理では、BSDのreliable signalsの設計思想が採用された。`sigaction()` がPOSIX標準のシグナルAPIとなり、V7/System Vの `signal()` は非推奨とされた。前回の記事で見た「シグナルの取りこぼし」問題は、POSIX標準に従う限り発生しない。

端末制御では、BSDの `termios` が標準として採用された。System Vの `termio` は事実上廃止された。

一方、ネットワーキングAPIについては、POSIX.1-1988の段階では標準化されなかった。Berkeley socketsとSTREAMS/TLIの対立がまだ決着していなかったためだ（後にBerkeley socketsがPOSIX標準に取り込まれる）。

1990年にPOSIX.1-1990が改訂版として発行され、これがISOにも採用された（ISO/IEC 9945-1:1990）。この1990年版が安定した基盤となり、以降の修正・拡張はこの版に対して行われた。

### POSIX.2——シェルとユーティリティの標準化（1992年）

POSIX.1がシステムプログラマのためのAPIを標準化したのに対し、POSIX.2（IEEE 1003.2-1992）はシェルとユーティリティを標準化した。6年間の議論を経て、1992年9月に批准された。

POSIX.2は二つのパートで構成されている。

パート1（IEEE 1003.2）は、シェルスクリプトの移植性と標準ユーティリティを定義した。標準シェルの仕様は主にSystem VのBourneシェルに基づいているが、一部BSDの機能も取り込んでいる。`cd`、`echo`、`test`、`[` といった組み込みコマンドの振る舞いから、`awk`、`sed`、`grep`、`sort`、`find` といった外部コマンドのオプションと出力形式まで、「POSIXシェルスクリプト」が何を前提にできるかを厳密に定義した。

パート2（IEEE 1003.2a）は、User Portability Extensions（UPE）として、viエディタやその他の対話的ユーティリティを定義した。

```
POSIX.2 が標準化したシェル機能の例:

  変数展開:    ${var:-default}, ${var:=default}, ${var:+alt}
  コマンド置換: $(command)  ← POSIX標準
                `command`   ← 旧来の構文（互換性のため残存）
  算術展開:    $((expression))
  テスト構文:   [ expression ]  ← test コマンド
  制御構造:    if/then/elif/else/fi, for/do/done,
               while/do/done, case/esac

  POSIXシェルに「含まれない」bash拡張の例:
  ×  配列:      array=(a b c)
  ×  [[ ]]:     [[ $var == pattern ]]
  ×  プロセス置換: <(command)
  ×  ブレース展開: {1..10}
  ×  let構文:    let "x = x + 1"
```

この区分は実用的に重要だ。あなたがbash拡張（配列、`[[ ]]`、プロセス置換など）を使ったスクリプトを書いた場合、そのスクリプトはmacOSのデフォルトシェル（zsh）やAlpine LinuxのBusyBox ash、FreeBSDのsh では正しく動作しない可能性がある。POSIX準拠のシェルスクリプトを書くということは、これらの拡張を使わないということだ。

### POSIX Threads——pthreads（1995年）

1995年、IEEE Std 1003.1c-1995（POSIX.1c）がスレッドプログラミングインタフェースを標準化した。いわゆるpthreads（POSIX Threads）だ。

マルチプロセッサシステムの普及に伴い、並行処理のプログラミングモデルの標準化が急務だった。各UNIXベンダーが独自のスレッドライブラリを提供していたが（SolarisのUI threads、Digital UNIXのDEC threads、AIXのpthreadなど）、インタフェースが異なるためマルチスレッドプログラムの移植は困難だった。

POSIX.1cは `pthread_create()`、`pthread_join()`、`pthread_mutex_lock()`、`pthread_cond_wait()` といった関数群を定義し、スレッドの生成・管理・同期のための統一的なAPIを提供した。現在、FreeBSD、Linux、macOS、Solaris、QNXなど主要なUNIX系OSはすべてpthreadsを実装している。

pthreadsの標準化は、POSIXの範囲がシステムコールやシェルにとどまらず、並行プログラミングモデルにまで及んだことを示している。POSIXは「UNIXとは何か」を定義するだけでなく、「UNIXの上でどうプログラムを書くか」のモデルまで標準化しようとした。

### POSIXが標準化しなかったもの

POSIXが何を標準化したかと同じくらい重要なのは、何を標準化しなかったかだ。

**GUI（グラフィカルユーザインタフェース）**。POSIXはGUIを標準化しなかった。1980年代後半から1990年代にかけて、UNIXのGUI環境はX Window System上のMotif、Open Look、CDEなどが乱立していた。だがベンダー間でGUIの共通基盤について合意が得られなかった。X Window Systemすら全ベンダーの合意事項ではなかった。GUIは巨大で複雑なソフトウェアであり、開発コストが高い。ある特定のベンダーのGUIを「標準」に選べば、他のベンダーが不利になる。全く新しいGUIを標準として設計すれば、既存のどのベンダーの実装とも互換がない。POSIXの「シェル」の定義は「コマンド言語インタプリタ」に限定されており、GUIシェルは概念的に除外されていた。

**パッケージ管理**。ソフトウェアの配布・インストール・依存関係管理の仕組みはOS間で全く異なる。RPM、DEB、pkg、ports——これらはそれぞれ独自の設計哲学を持ち、共通化の試みはほぼ存在しなかった。

**サービス管理**。デーモンの起動・停止・監視の仕組みも標準化されなかった。SysV init、BSD init、launchd、systemd——各OSが独自の方法でサービスを管理している。

**ネットワーク管理**。IPアドレスの設定、ルーティングテーブルの操作、ファイアウォールの管理は、POSIX の範囲外だ。

```
POSIXが標準化した / しなかった領域:

  標準化した（移植可能なコードが書ける）:
  ┌─────────────────────────────────────────┐
  │  システムコール（プロセス, ファイルI/O）  │
  │  シグナル処理（sigaction）               │
  │  端末制御（termios）                     │
  │  シェルとユーティリティ（sh, awk, sed等） │
  │  スレッド（pthreads）                    │
  │  正規表現（BRE/ERE）                     │
  │  ソケット（後に追加）                    │
  └─────────────────────────────────────────┘

  標準化しなかった（OS間で互換性なし）:
  ┌─────────────────────────────────────────┐
  │  GUI / ウィンドウシステム                │
  │  パッケージ管理                          │
  │  サービス管理（init, systemd）           │
  │  ネットワーク管理コマンド                │
  │  デバイス命名規則                        │
  │  システム管理・設定                      │
  │  ファイルシステム固有機能                │
  └─────────────────────────────────────────┘
```

POSIXの設計者たちは、標準化の範囲を意図的に限定した。「最小公約数」を標準にすることで、各OSの独自性を殺さずに移植性の基盤を提供する——それがPOSIXの戦略だった。この戦略には功罪がある。功としては、多様なOSがPOSIXに準拠できた。罪としては、実際のシステム管理や運用において、POSIXだけでは到底足りない領域が残った。

---

## 4. Spec 1170とSingle UNIX Specification——「本物のUNIX」の定義

### UNIX Warsの後始末

POSIXが「移植可能なインタフェース」を定義した一方で、「UNIXとは何か」というより根本的な問いは未解決のまま残っていた。

1988年のUNIX Wars（OSF vs Unix International）は、1989年のSVR4のリリースで技術的にはある程度収束した。だが業界の分断は続いていた。そして1990年代初頭、新たな脅威が現れた。Microsoftだ。

Windows NTがサーバ市場に参入し、Windows 95がデスクトップ市場を席巻しようとしていた。UNIX陣営が内部で争っている間に、Microsoftが市場を奪いつつあった。Novellは自社のNetWareの市場がMicrosoftに侵食されるのを見ていた。UNIX業界は、内部対立を収束させ、共通の標準を確立する必要に迫られた。

### Spec 1170——実際に使われているインタフェースの棚卸し

1993年3月、HP、IBM、SunSoft、SCO、Novell、USL（Unix System Laboratories）がCOSE（Common Open Software Environment）を結成した。UNIX Warsの残滓を清算し、共通のオープン標準を策定するための業界連携だ。

COSEの最初の作業は、「実際に使われているUNIXインタフェース」の棚卸しだった。大量の既存UNIXアプリケーションを調査し、実際に呼び出されているシステムコールやライブラリ関数を特定した。その結果、1,170個のインタフェースが特定された。この数字がそのまま仕様の名前になった——Spec 1170だ。

理論的に「あるべき」インタフェースではなく、実際に「使われている」インタフェースを標準化する。このプラグマティックなアプローチがSpec 1170の特徴だった。1993年、Spec 1170はCOSEからX/Openにfasttrack手続きで引き渡され、標準化作業が進められた。

### UNIX商標の分離——NovellからX/Openへ

同じ1993年、もう一つの歴史的転換が起きた。

1993年6月14日、NovellはAT&TからUnix System Laboratories（USL）を買収した。AT&Tが保有していたUNIXのソースコード所有権とUNIX商標が、Novellの手に渡った。

そしてNovellは、UNIX商標の権利をX/Openに移転した。これは画期的な決定だった。UNIXの商標が特定のベンダーの手を離れ、中立的なコンソーシアムに委ねられたのだ。「UNIX」と名乗れるかどうかは、もはやAT&Tのライセンスを持っているかどうかではなく、標準への適合を第三者機関が認証するかどうかで決まる。

ソースコード所有権は別の道を歩んだ。Novellは1995年にUNIXのソースコードをSCO（Santa Cruz Operation）に売却した。商標と実装の分離——これがUNIXの標準化における最も重要な構造変革だった。

### Single UNIX Specification（1995年〜）

1995年、X/OpenはSpec 1170を基にSingle UNIX Specification（SUS）Version 1を公表した。SUSはPOSIXの範囲を超え、実際のUNIXシステムに必要なインタフェースの全体像を定義する仕様だ。そして、SUSに適合したシステムだけが「UNIX」の商標を使用できるという認証プログラム——UNIX 95ブランド——を開始した。

1996年にX/OpenとOSF（Open Software Foundation）が合併し、The Open Groupが設立された。かつてUNIX Warsで対立した二つの組織が、一つに統合されたのだ。The Open Groupは現在もUNIX商標を管理している。

1997年にはSUS Version 2（UNIX 98ブランド）が公表され、64ビットサポートやリアルタイム拡張が追加された。

2001年、さらに大きな統合が行われた。POSIX.1、POSIX.2、SUSの各標準が、Austin Groupの主導により単一文書に統合された。POSIX.1-2001（IEEE Std 1003.1-2001）＝SUS Version 3（SUSv3）＝UNIX 03ブランドの基盤だ。これにより、POSIXとSUSは実質的に同一の文書となった。

```
標準化の統合の流れ:

  1984  /usr/group Standard
    │
    ▼
  1988  POSIX.1 (IEEE 1003.1-1988)    ─────────────────┐
    │                                                   │
  1990  POSIX.1-1990                                    │
    │                                                   │
  1992  POSIX.2 (IEEE 1003.2-1992)    ──────┐          │
    │                                       │          │
  1993  Spec 1170 (COSE → X/Open)           │          │
    │                                       │          │
  1995  SUS Version 1 / UNIX 95             │          │
    │   POSIX.1c (pthreads)                 │          │
    │                                       │          │
  1996  X/Open + OSF → The Open Group       │          │
    │                                       │          │
  1997  SUS Version 2 / UNIX 98             │          │
    │                                       │          │
  2001  POSIX.1-2001 = SUSv3 / UNIX 03 ◀───┴──────────┘
    │   （三つの標準を単一文書に統合）
    │
  2008  POSIX.1-2008 = SUSv4
    │
  2017  POSIX.1-2017 (= 2008 + TC1 + TC2)
    │
  2024  POSIX.1-2024（最新版、C17対応）
```

この統合の歴史を見ると、UNIX標準化の20年間は「分裂→競争→疲弊→統合」のサイクルだったことがわかる。POSIX、SUS、XPGという三つの異なる標準化の試みが、最終的に一つに収束した。その収束の原動力は、技術的な合理性よりも、Microsoftという共通の脅威に対抗する商業的動機だった。

### macOSのUNIX認証——「本物のUNIX」とは何か

SUSとUNIX認証プログラムが現代においてどう機能しているかを示す、もっとも意外な事例がmacOSだ。

2007年10月26日、Mac OS X 10.5 Leopard（Intel版）がUNIX 03認証を取得した。BSD系OSとして初のUNIX 03認証だった。以降、OS X Lionを唯一の例外として、すべてのmacOSバージョンがUNIX 03認証を継続している。最新のmacOS 15.0 Sequoiaも認証済みだ。

この事実は、多くのエンジニアを驚かせる。macOSは「UNIXライク」なOSではない。The Open Groupの認証を受けた、正式な「UNIX」だ。LinuxやFreeBSDは事実上POSIX準拠だが、公式のUNIX認証は受けていない。商標法上、「UNIX」と名乗れるのはThe Open Groupの認証を受けたシステムだけだ。

```
「UNIX」を名乗れるOS（UNIX認証取得済み）:
  - macOS（10.5 Leopard以降）
  - AIX（IBM）
  - HP-UX（Hewlett Packard Enterprise）
  - Solaris（Oracle）
  - z/OS（IBM、UNIX System Servicesコンポーネント）

「UNIX」を名乗れないOS（認証未取得）:
  - Linux（各ディストリビューション）
  - FreeBSD / NetBSD / OpenBSD
  - Android（Linuxカーネルベースだが）
```

ただし、UNIX認証が保証する範囲は限定的だ。認証は、SUSが定義するAPIとユーティリティが正しく動作することを適合テストスイートで確認するものだ。OSの品質、パフォーマンス、セキュリティを保証するものではない。認証テストスイートがカバーしていないエッジケースでの互換性も保証されない。

macOSのUNIX認証は、「UNIXとは何か」という問いの答えが、技術的な血統ではなく、標準への適合になったことを象徴している。macOSのカーネル（XNU）はMachマイクロカーネルとFreeBSDのハイブリッドだ。AT&TのUNIXソースコードとの血縁関係は薄い。だがSUSの適合テストに合格する限り、それは「UNIX」だ。

---

## 5. 標準の功罪——POSIXは何を成し遂げ、何を成し遂げられなかったか

### 功：移植性の基盤

POSIXの最大の功績は、ソースコードレベルの移植性の基盤を提供したことだ。

POSIX以前、あるUNIX系OS向けに書いたCプログラムを別のUNIXに移植するには、システムコールの互換性を一つ一つ確認し、条件付きコンパイル（`#ifdef`）で差異を吸収する必要があった。シグナル処理、端末制御、ファイル操作——あらゆる場面で「このOSではこう書く、あのOSではああ書く」という分岐が発生した。

POSIX準拠のインタフェースだけを使ってプログラムを書けば、その分岐は大幅に減る。`sigaction()` を使えばシグナル処理はどのPOSIX環境でも同じだ。`termios` を使えば端末制御も統一される。POSIXシェルの構文だけでスクリプトを書けば、bash、zsh、dash、ashのどれでも動く（はずだ）。

この「はずだ」がPOSIXの限界でもあるのだが、少なくとも共通の土台が存在するということの価値は計り知れない。POSIXがなければ、LinuxもmacOSも今の形では存在しなかった。Linuxカーネルの初期開発においてLinus TorvaldsがPOSIX準拠を強く意識していたことは、Linuxがサーバ市場で広く受け入れられた一因だ。

### 功：「最小公約数」による多様性の維持

POSIXが標準化の範囲を限定したことは、短所であると同時に長所でもある。

もしPOSIXがGUI、パッケージ管理、サービス管理まで標準化していたら、各OSの独自性は大きく制約されただろう。macOSのlaunchd、Linuxのsystemd、FreeBSDのrc.d——これらはPOSIXの範囲外だからこそ、各OSが自由に設計できた。

POSIXは「必要最小限の共通言語」を提供し、その上で各OSが独自の進化を遂げる余地を残した。この設計判断は、生態系の多様性を維持しながら相互運用性を確保するという、難しいバランスを実現している。

### 罪：「準拠」と「互換」の乖離

POSIXの最大の問題は、「POSIX準拠」が「互換」を意味しないことだ。

POSIX準拠（compliance）とPOSIX適合（conformance）は異なる概念だ。「準拠」は非公式な業界用語で、標準の一部を実装していれば名乗れる。「適合」は公式の認証テストスイートに合格した状態を指す。Linuxは広くPOSIX準拠と見なされているが、公式のPOSIX適合認証は（多くのディストリビューションでは）受けていない。認証には費用と時間がかかり、カーネルやglibcのバージョンアップのたびに再認証が必要だからだ。

さらに根本的な問題がある。POSIXはソースコードレベルの移植性を目指しているが、同じソースコードが異なるPOSIX準拠OS上で同じ振る舞いをする保証はない。`PATH_MAX` の値、`errno` の具体的な値、ファイルシステムの大文字小文字の扱い——POSIXが「実装定義」（implementation-defined）や「未規定」（unspecified）としている領域で、OSごとの差異が生じる。

私が経験した移植プロジェクトの苦労の多くは、この「実装定義」の領域に起因していた。POSIXが定めた共通言語は確かに役立つ。だがその共通言語の「方言」が残る部分で、実際の移植作業の大半が費やされる。

### 罪：事実上の陳腐化

POSIXの標準化プロセスは遅い。新しい標準版の策定には何年もかかる。その間に技術は進歩する。

例えば、POSIXは `epoll`（Linux固有の高性能イベント通知メカニズム）を標準化していない。`kqueue`（BSD系の同等機能）も標準化していない。高性能なネットワークサーバを書くには、これらのOS固有APIを使わざるを得ない。POSIXが定義する `select()` や `poll()` では、大量のファイルディスクリプタを扱う場合にパフォーマンスが不足する。

同様に、POSIXは `inotify`（Linuxのファイル変更監視）や `FSEvents`（macOSのファイル変更監視）を標準化していない。非同期I/O（`io_uring` など）の最新の進展もPOSIXの範囲外だ。

結果として、高性能なシステムソフトウェアはPOSIX準拠のAPIだけでは書けない。OS固有のAPIを使い、条件付きコンパイルで差異を吸収するという、POSIX以前と同じ構造が再現されている。POSIXは「基礎的な移植性」を提供するが、「最先端の機能の移植性」は提供できていない。

---

## 6. ハンズオン：POSIXシェルスクリプトの互換性を検証する

ここからは手を動かす。POSIXシェルスクリプト（bash拡張を使わない）を書き、複数のシェル環境で動作することを確認する。

### 環境構築

Docker上で、複数のシェルを使える環境を準備する。

```bash
docker run -it --rm ubuntu:24.04 bash
```

コンテナ内で必要なシェルをインストールする。

```bash
apt-get update && apt-get install -y dash busybox zsh ksh mksh
```

### 演習1：POSIX準拠スクリプト vs bash依存スクリプト

まず、bash依存のスクリプトがPOSIXシェルで動かないことを確認する。

```bash
# bash依存のスクリプト（POSIXシェルでは動かない）
cat > /tmp/bash_only.sh << 'SCRIPT'
#!/bin/sh
# bash拡張を使ったスクリプト

# bash拡張: 配列
fruits=(apple banana cherry)
echo "First fruit: ${fruits[0]}"

# bash拡張: [[ ]] 構文
if [[ "hello" == h* ]]; then
    echo "Pattern match with [["
fi

# bash拡張: プロセス置換
diff <(echo "line1") <(echo "line2")

# bash拡張: ブレース展開
echo {1..5}
SCRIPT
chmod +x /tmp/bash_only.sh

echo "=== Running with bash ==="
bash /tmp/bash_only.sh 2>&1 || true

echo ""
echo "=== Running with dash (POSIX shell) ==="
dash /tmp/bash_only.sh 2>&1 || true

echo ""
echo "=== Running with busybox ash ==="
busybox ash /tmp/bash_only.sh 2>&1 || true
```

### 演習2：POSIX準拠スクリプトの書き方

同じ処理をPOSIX準拠で書き直す。

```bash
cat > /tmp/posix_compatible.sh << 'SCRIPT'
#!/bin/sh
# POSIX準拠のスクリプト -- bash拡張を一切使わない

# 配列の代替: スペース区切りの文字列 + set
fruits="apple banana cherry"
set -- $fruits
echo "First fruit: $1"

# [[ ]] の代替: [ ] と case
# パターンマッチには case を使う
case "hello" in
    h*) echo "Pattern match with case" ;;
    *)  echo "No match" ;;
esac

# プロセス置換の代替: 一時ファイル
tmpfile1=$(mktemp)
tmpfile2=$(mktemp)
echo "line1" > "$tmpfile1"
echo "line2" > "$tmpfile2"
diff "$tmpfile1" "$tmpfile2" || true
rm -f "$tmpfile1" "$tmpfile2"

# ブレース展開の代替: seq コマンドまたは算術ループ
i=1
while [ "$i" -le 5 ]; do
    printf "%d " "$i"
    i=$((i + 1))
done
echo ""
SCRIPT
chmod +x /tmp/posix_compatible.sh

echo "=== Running with bash ==="
bash /tmp/posix_compatible.sh

echo ""
echo "=== Running with dash ==="
dash /tmp/posix_compatible.sh

echo ""
echo "=== Running with busybox ash ==="
busybox ash /tmp/posix_compatible.sh

echo ""
echo "=== Running with zsh (emulating sh) ==="
zsh --emulate sh /tmp/posix_compatible.sh

echo ""
echo "=== Running with mksh ==="
mksh /tmp/posix_compatible.sh
```

### 演習3：POSIXユーティリティの互換性を確認する

POSIXが標準化したユーティリティの振る舞いを確認する。

```bash
cat > /tmp/posix_utils.sh << 'SCRIPT'
#!/bin/sh
# POSIXユーティリティの互換性テスト

# テストデータの作成
mkdir -p /tmp/posix_test
cat > /tmp/posix_test/data.txt << 'DATA'
Alice 30 Engineering
Bob 25 Marketing
Charlie 35 Engineering
Diana 28 Marketing
Eve 32 Engineering
DATA

echo "=== 1. grep (POSIX BRE) ==="
# POSIX基本正規表現（BRE）でフィルタ
grep "Engineering" /tmp/posix_test/data.txt

echo ""
echo "=== 2. awk (POSIX) ==="
# awkで特定カラムの抽出と集計
awk '{ sum += $2; count++ } END { printf "Average age: %.1f\n", sum/count }' \
    /tmp/posix_test/data.txt

echo ""
echo "=== 3. sed (POSIX) ==="
# sedで置換
sed 's/Engineering/Eng/g; s/Marketing/Mkt/g' /tmp/posix_test/data.txt

echo ""
echo "=== 4. sort + uniq (POSIX) ==="
# 部署ごとの人数をカウント
awk '{ print $3 }' /tmp/posix_test/data.txt | sort | uniq -c | sort -rn

echo ""
echo "=== 5. cut + paste (POSIX) ==="
# 名前と部署だけを抽出
cut -d' ' -f1,3 /tmp/posix_test/data.txt

echo ""
echo "=== 6. test / [ ] (POSIX) ==="
# POSIXのテスト構文
x=42
if [ "$x" -gt 40 ] && [ "$x" -lt 50 ]; then
    echo "$x is between 40 and 50"
fi

echo ""
echo "=== 7. printf (POSIX) ==="
# echoではなくprintfを使う（echoの振る舞いはOS間で異なる）
printf "Name: %-10s Age: %3d\n" "Alice" 30
printf "Name: %-10s Age: %3d\n" "Bob" 25

# クリーンアップ
rm -rf /tmp/posix_test
SCRIPT
chmod +x /tmp/posix_utils.sh

echo "=== Running with dash (POSIX shell) ==="
dash /tmp/posix_utils.sh
```

### 演習4：echo vs printf——POSIXの落とし穴

POSIXの世界で最もよく知られた非互換性の一つが `echo` コマンドだ。

```bash
cat > /tmp/echo_vs_printf.sh << 'SCRIPT'
#!/bin/sh
# echo の振る舞いはOS/シェルによって異なる
# POSIXでは echo のエスケープシーケンスの解釈は「実装定義」

echo "=== echo with escape sequences ==="
echo "Tab:\there"
echo "Newline:\nhere"
echo "Backslash-n literally: \\n"

# 上記の出力は、シェルによって異なる:
# - bash (デフォルト): \t と \n をリテラルとして出力
# - dash: \t と \n をエスケープとして解釈
# - zsh: \t と \n をエスケープとして解釈

echo ""
echo "=== printf is consistent across shells ==="
# printfはPOSIX標準で振る舞いが明確に定義されている
printf "Tab:\there\n"
printf "Newline:\nhere\n"
printf "Backslash-n literally: \\\\n\n"
SCRIPT
chmod +x /tmp/echo_vs_printf.sh

echo "=== bash ==="
bash /tmp/echo_vs_printf.sh

echo ""
echo "=== dash ==="
dash /tmp/echo_vs_printf.sh
```

### 演習5：POSIXシェルでの実用的なスクリプト

最後に、実用的なPOSIX準拠スクリプトを書く。ログファイルの解析スクリプトだ。

```bash
# テスト用のログデータを生成
cat > /tmp/access.log << 'LOG'
192.168.1.10 - - [23/Feb/2026:10:15:30] "GET /index.html HTTP/1.1" 200 1234
192.168.1.20 - - [23/Feb/2026:10:15:31] "GET /api/users HTTP/1.1" 200 5678
192.168.1.10 - - [23/Feb/2026:10:15:32] "POST /api/login HTTP/1.1" 401 89
192.168.1.30 - - [23/Feb/2026:10:15:33] "GET /index.html HTTP/1.1" 200 1234
192.168.1.20 - - [23/Feb/2026:10:15:34] "GET /api/users HTTP/1.1" 500 234
192.168.1.10 - - [23/Feb/2026:10:15:35] "GET /static/style.css HTTP/1.1" 200 4567
192.168.1.40 - - [23/Feb/2026:10:15:36] "GET /index.html HTTP/1.1" 200 1234
192.168.1.20 - - [23/Feb/2026:10:15:37] "DELETE /api/users/5 HTTP/1.1" 403 123
192.168.1.30 - - [23/Feb/2026:10:15:38] "GET /api/health HTTP/1.1" 200 45
192.168.1.10 - - [23/Feb/2026:10:15:39] "GET /index.html HTTP/1.1" 304 0
LOG

cat > /tmp/analyze_log.sh << 'SCRIPT'
#!/bin/sh
# POSIXシェル準拠のログ解析スクリプト
# bash拡張を使わず、あらゆるPOSIXシェルで動作する

LOGFILE="${1:?Usage: $0 <logfile>}"

if [ ! -f "$LOGFILE" ]; then
    printf "Error: File not found: %s\n" "$LOGFILE" >&2
    exit 1
fi

total=$(wc -l < "$LOGFILE")
printf "=== Log Analysis Report ===\n"
printf "File: %s\n" "$LOGFILE"
printf "Total requests: %d\n\n" "$total"

# ステータスコード別集計
printf "--- Status Code Distribution ---\n"
awk '{ for(i=1;i<=NF;i++) if($i ~ /^[0-9][0-9][0-9]$/ && $(i-1) ~ /HTTP/) print $i }' \
    "$LOGFILE" | sort | uniq -c | sort -rn | \
while read count code; do
    pct=$((count * 100 / total))
    printf "  %s: %3d requests (%2d%%)\n" "$code" "$count" "$pct"
done

printf "\n--- Top IP Addresses ---\n"
awk '{ print $1 }' "$LOGFILE" | sort | uniq -c | sort -rn | head -5 | \
while read count ip; do
    printf "  %-15s %3d requests\n" "$ip" "$count"
done

printf "\n--- Error Requests (4xx/5xx) ---\n"
awk '{ for(i=1;i<=NF;i++) if($i ~ /^[45][0-9][0-9]$/ && $(i-1) ~ /HTTP/) {
    printf "  %s %s %s\n", $1, $7, $i
}}' "$LOGFILE"

printf "\n--- HTTP Methods ---\n"
awk -F'"' '{ split($2, a, " "); print a[1] }' "$LOGFILE" | \
    sort | uniq -c | sort -rn | \
while read count method; do
    printf "  %-6s %3d requests\n" "$method" "$count"
done
SCRIPT
chmod +x /tmp/analyze_log.sh

echo "=== Running with dash ==="
dash /tmp/analyze_log.sh /tmp/access.log

echo ""
echo "=== Running with busybox ash ==="
busybox ash /tmp/analyze_log.sh /tmp/access.log
```

この演習を通じて体感してほしいのは、POSIX準拠のスクリプトを書くことは制約でありながら、その制約が「どこでも動く」という強力な保証を生むということだ。bash の便利な拡張を手放す代わりに、dash でも ash でも zsh でも mksh でも動くスクリプトが手に入る。この設計判断は、UNIXの「合成可能性」の原則と同根だ。個別の便利さを捨てて、組み合わせ可能性を取る。

---

## 7. まとめと次回予告

### この回の要点

- UNIXの標準化は三つの流れから始まった。/usr/group Standard（1984年、コミュニティ主導）、SVID（1985年、AT&T主導）、X/Open XPG（1985年〜、ヨーロッパ主導）。これらの試みが最終的にPOSIX（IEEE 1003.1-1988）として結実した。Richard Stallmanが「POSIX」の名前を提案し、標準をUNIXの特定実装から独立した概念として位置づけた

- POSIXはシステムコール（POSIX.1、1988年）、シェルとユーティリティ（POSIX.2、1992年）、スレッド（POSIX.1c、1995年）を標準化した。BSDとSystem Vの対立において、シグナル処理と端末制御ではBSDの設計が採用された。一方、POSIXは意図的にGUI、パッケージ管理、サービス管理を標準化の範囲外とし、各OSの独自性を残した

- UNIX Warsの収束とMicrosoftの台頭を背景に、1993年のCOSEがSpec 1170を策定し、これがSingle UNIX Specification（1995年）に発展した。NovellがUNIX商標をX/Openに移転し、1996年にX/OpenとOSFが合併してThe Open Groupが設立された。2001年にPOSIX.1、POSIX.2、SUSが単一文書に統合された

- macOS（10.5 Leopard、2007年〜）はUNIX 03認証を取得した正式な「UNIX」である。一方、LinuxやFreeBSDは事実上POSIX準拠だが公式認証は受けていない。「UNIX」の定義が、ソースコードの血統から標準への適合に変わったことは、標準化の最大の成果だ

- POSIXの限界は、「準拠」が「互換」を意味しないことにある。実装定義の領域で生じるOS間の差異、高性能APIの非標準化、標準化プロセスの遅さが、実際の移植作業を困難にしている。POSIXは「完全な互換性」ではなく「移植可能性の基盤」を提供した。完璧ではないが、この基盤がなければLinuxもmacOSも今の形では存在しなかった

### 冒頭の問いへの暫定回答

「UNIXの『標準化』は何を成し遂げ、何を成し遂げられなかったのか？」

POSIXとSUSが成し遂げたのは、「UNIXとは何か」という問いに対する、実用的な回答の提供だ。1980年代のUNIXは、同じ名前を冠しながら互換性のない複数の実装が乱立していた。POSIXは「移植可能なプログラムを書くための最小限の共通インタフェース」を定義し、SUSは「UNIXと名乗るための適合基準」を確立した。

成し遂げられなかったのは、「完全な互換性」だ。POSIXが定義しない領域——GUI、パッケージ管理、サービス管理、高性能I/O——において、各OSは独自の道を歩み続けている。この非互換性は、POSIXの限界であると同時に、多様性を維持する仕組みでもある。

標準化が教えてくれるのは、技術的な問題に完璧な解は存在しないということだ。POSIXは「完璧な互換性」ではなく「十分な移植性」を選んだ。その「十分さ」の範囲を知ることが、実務において最も重要だ。

あなたのプロジェクトで、「標準」に頼れる部分と「標準」が通用しない部分の境界を、意識しているだろうか。

### 次回予告

次回は「商用UNIXの栄華と黄昏——Solaris, AIX, HP-UX」。POSIXとSUSによって「UNIX」が標準化された時代、商用UNIX——Sun MicrosystemsのSolaris、IBMのAIX、Hewlett-PackardのHP-UX——は企業の基幹システムを支えていた。ZFS、DTrace、Zones、WPAR——商用UNIXは独自の技術革新を続けた。だがLinuxの台頭により、その栄華は終わりを告げる。技術的にはSolarisが優れていた部分もあった。だがコストと人材調達の現実がLinux移行を不可避にした。商用UNIXの技術的遺産は、どのようにLinuxに受け継がれたのか。

---

## 参考文献

- IEEE Standards Association, "IEEE 1003.1-1988 - IEEE Standard Portable Operating System Interface for Computer Environments": <https://standards.ieee.org/ieee/1003.1/1388/>
- Richard Stallman, "The origin of the name POSIX": <https://stallman.org/articles/posix.html>
- The Open Group, "POSIX.1 FAQ": <https://www.opengroup.org/austin/papers/posix_faq.html>
- The Open Group, "POSIX.1 Backgrounder": <https://www.opengroup.org/austin/papers/backgrounder.html>
- IEEE Standards Association, "IEEE 1003.2-1992 - Shell and Utilities": <https://standards.ieee.org/standard/1003_2-1992.html>
- IEEE Standards Association, "IEEE 1003.1c-1995 - Threads Extension": <https://standards.ieee.org/ieee/1003.1c/1393/>
- The Open Group, "The Single UNIX Specification": <https://unix.org/what_is_unix/single_unix_specification.html>
- The Open Group, "The Register of UNIX Certified Products": <https://www.opengroup.org/openbrand/register/>
- The Open Group, "Apple Inc. - Register of UNIX Certified Products": <https://www.opengroup.org/openbrand/register/apple.htm>
- Wikipedia, "Single UNIX Specification": <https://en.wikipedia.org/wiki/Single_UNIX_Specification>
- Wikipedia, "POSIX": <https://en.wikipedia.org/wiki/POSIX>
- Wikipedia, "X/Open": <https://en.wikipedia.org/wiki/X/Open>
- Wikipedia, "Common Open Software Environment": <https://en.wikipedia.org/wiki/Common_Open_Software_Environment>
- Wikipedia, "System V Interface Definition": <https://en.wikipedia.org/wiki/System_V_Interface_Definition>
- Wikipedia, "Unix System Laboratories": <https://en.wikipedia.org/wiki/Unix_System_Laboratories>
- Chris Siebenmann, "Why there is no POSIX standard for a Unix GUI": <https://utcc.utoronto.ca/~cks/space/blog/unix/WhyNoStandardUnixGUIs>
- Tech Monitor, "THE LIMITATIONS OF POSIX COMPLIANCE AND WHY IT DOES NOT MEAN UNIX COMPATIBILITY": <https://www.techmonitor.ai/technology/the_limitations_of_posix_compliance_and_why_it_does_not_mean_unix_compatibility>
- Eric S. Raymond, "Unix Standards", The Art of UNIX Programming, 2003: <http://www.catb.org/~esr/writings/taoup/html/ch17s02.html>
- The Open Group, "The Single UNIX Specification, Version 4 - Introduction": <https://unix.org/version4/overview.html>
- The Open Group, "UNIX Certification -- The Brand": <https://unix.org/what_is_unix/the_brand.html>
- Peter H. Salus, "A Quarter Century of UNIX", Addison-Wesley, 1994
- W. Richard Stevens, "Advanced Programming in the UNIX Environment", Addison-Wesley, 1992
