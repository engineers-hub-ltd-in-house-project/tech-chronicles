# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第14回：GNU coreutils――自由なUNIXツール群の再実装

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Richard Stallmanが1983年にGNUプロジェクトを発表した経緯と、「自由なソフトウェア」という思想の核心
- GNUプロジェクトが「まずツール群を再実装し、最後にカーネルを作る」という戦略を採った理由
- GNU coreutilsの成立過程――fileutils、textutils、shellutilsの三つのパッケージが2003年に統合されるまで
- GNU拡張（long options、--helpフラグの統一）がUNIXのコマンドライン体験をどう変えたか
- POSIX標準とGNU拡張の関係、そしてGNUツールとBSDツールの微妙な非互換性
- BusyBox（1995年）がGNU coreutilsの「もう一つの再実装」として組み込みLinuxを支えている事実
- GNU/BSDの両環境でコマンドの差異を確認し、POSIXポータブルなスクリプトを書く技法

---

## 1. あなたが使っているlsは、誰が書いたlsなのか

1998年の夏、私はSlackware 3.5をインストールしたばかりのPC/AT互換機の前にいた。

この連載の第1回で書いた通り、私のLinux入門はSlackwareだった。当時、GUIはまだ安定しない。XFree86の設定を何度やり直しても解像度がうまく合わず、結局、黒い画面のbashプロンプトの前で一日を過ごすことになった。

`ls`と打つ。ファイル一覧が表示される。`ls -l`と打つ。詳細が出る。`ls -la`で隠しファイルも見える。このとき私は、自分が打っている`ls`がどこから来たのかなど考えもしなかった。UNIXの`ls`。それだけの認識だった。

数年後、macOSで作業する機会が増えた。いつもの調子で`ls --color=auto`と打つ。エラーが返る。「`illegal option -- -`」。何が起きたのかすぐにはわからなかった。Linuxでは当たり前に使えていたオプションが、なぜmacOSで動かないのか。

調べてわかった。LinuxのlsはGNU lsだ。macOSのlsはBSD lsだ。同じ`ls`という名前でありながら、異なる人間が、異なる思想で、異なる時期に書いたものだった。GNU lsの`--color=auto`はGNUプロジェクト独自の拡張であり、BSD lsにはそのオプションが存在しない。macOSで色付き出力を得るには`-G`フラグを使う。環境変数もLS_COLORS（GNU）とLSCOLORS（BSD）で書式が異なる。

さらに調べると、AT&TのオリジナルUNIXに含まれていた`ls`とも、GNU lsは別のプログラムだ。GNUプロジェクトが1980年代に「自由なソフトウェア」の名の下に、UNIXのツール群をゼロから書き直したものだ。私が毎日使っていた`ls`は、Ken ThompsonやDennis Ritchieが書いたオリジナルの`ls`ではなかった。GNUの誰かが、GPLライセンスの下で書き直した`ls`だった。

あなたが毎日使っている`ls`、`cat`、`grep`、`sort`、`wc`、`head`、`tail`――これらはすべて、GNUプロジェクトによる再実装だ。オリジナルのUNIXコマンドそのものではない。なぜ再実装する必要があったのか。そこには、ソフトウェアの「自由」をめぐる、1980年代の闘争がある。

---

## 2. 「自由なUNIX」を求めて――GNUプロジェクトの誕生

### プリンタ事件と怒りの原点

GNUプロジェクトの物語は、一台のプリンタから始まる。

1980年代初頭、MIT人工知能研究所（AI Lab）に新しいXeroxのレーザープリンタが導入された。以前のプリンタでは、ソースコードが公開されており、紙詰まりが起きると関係者に自動通知するようにStallmanがコードを改修していた。だが新しいプリンタのソフトウェアはプロプライエタリ（独占的）であり、ソースコードは非公開だった。Stallmanはソースコードの提供をXeroxに求めたが、断られた。

この体験がStallmanの思想を決定的に方向づけた。ソフトウェアを「所有」し、ユーザーから自由を奪うことへの根本的な怒り。この怒りが、GNUプロジェクトの原動力となった。

### 1983年9月27日：Usenetへの宣言

1983年9月27日、Richard StallmanはUsenetのnet.unix-wizardsニュースグループに一通の投稿を行った。タイトルは「Free Unix!」。投稿の冒頭にはこう書かれている。

> Starting this Thanksgiving I am going to write a complete Unix-compatible software system called GNU (Gnu's Not Unix), and give it away free to everyone who can use it.

「この感謝祭から、GNUと呼ばれる完全なUnix互換ソフトウェアシステムを書き始め、それを使えるすべての人に無料で提供する」。GNUは再帰的頭字語だ。"Gnu's Not Unix"――GNUはUNIXではない。UNIXと互換性を持つが、UNIXのコードを一切含まない、完全に自由なシステム。それがStallmanの宣言だった。

1985年3月、Stallmanはこの構想をさらに詳細に展開した文書をDr. Dobb's Journalに発表した。これが「GNU Manifesto」だ。GNU Manifestoは、ソフトウェアが自由であるべき理由を哲学的・実践的に論じた文書であり、フリーソフトウェア運動の基盤となった。

### 「自由」の定義――四つの自由

Stallmanが定義した「自由なソフトウェア」とは何か。それは価格の話ではない。「free as in freedom, not as in free beer（自由の自由であって、無料ビールの無料ではない）」。自由ソフトウェアは四つの自由を保障する。

- **自由0**：プログラムを任意の目的で実行する自由
- **自由1**：プログラムの動作を研究し、自分の必要に合わせて変更する自由（ソースコードへのアクセスが前提条件）
- **自由2**：コピーを再配布して他者を助ける自由
- **自由3**：改変版を他者に配布する自由（コミュニティ全体が変更の恩恵を受けられる）

この四つの自由は、1986年2月のGNU's Bulletinで最初に明文化された。当初は二つの自由として定義されていたが、後に四つに拡張された。自由0（実行する自由）は最も基本的であるがゆえに、後から追加され番号0が振られた。

この思想を法的に実装したのがGPL（GNU General Public License）だ。GPL v1は1989年2月25日にリリースされた。GPLは「コピーレフト」の原則を導入した。GPLの下で配布されたソフトウェアの派生物は、同じライセンス条件で配布しなければならない。つまり、自由なソフトウェアを改変して配布する者は、その改変版も自由にしなければならない。自由は連鎖する。

### 戦略：まずツールを、最後にカーネルを

GNUプロジェクトの戦略は明快だった。

UNIXシステムを構成する要素を分解すると、カーネル、シェル、コンパイラ、エディタ、そして膨大なユーティリティ群がある。Stallmanは、まず周辺のツール群を自由なライセンスで再実装し、最後にカーネルを開発してシステムを完成させるという戦略を採った。

この戦略には合理性がある。ツール群は既存のUNIX上で開発・テストできる。AT&Tのプロプライエタリなlsを使いながら、自由なlsを書く。それが動くようになったら、プロプライエタリなlsを置き換える。一つずつ、確実に。

最初の主要成果はGNU Emacsだった。Stallmanは1984年に開発を開始し、1985年3月20日に最初の公開リリースを行った。エディタは開発作業の基盤であり、これが自由であることは他のすべてのツール開発の前提条件だった。

1987年3月22日にはGCC（GNU C Compiler）がリリースされた。自由なコンパイラの存在は、自由なソフトウェアの自給自足を可能にする。プロプライエタリなコンパイラに依存せずに、自由なソフトウェアをコンパイルできる。

そして、ls、cat、cp、mv、rm、sort、grep、sed、awk――日常的に使うコマンドラインツール群の再実装が、GNU fileutils、GNU textutils、GNU shellutils（sh-utils）として進められた。

```
GNUプロジェクトの開発タイムライン:

  1983年  GNUプロジェクト発表（Usenet投稿、9月27日）
  1984年  GNU Emacs開発開始
  1985年  GNU Emacs 最初の公開リリース（3月20日）
          GNU Manifesto、Dr. Dobb's Journal掲載（3月）
  1987年  GCC 最初のリリース（3月22日）
  1988年  GNU AWK（gawk）リリース
  1989年  GPL v1 リリース（2月25日）
          GNU Bash 0.99（Brian Fox）
  1991年  GPL v2 リリース（6月）
          Linux 0.01（Linus Torvalds、8月）
          → GNUツール群 + Linuxカーネル = GNU/Linuxシステム
  1992年  GNU/Linuxディストリビューションの登場
  2003年  GNU coreutils 5.0（fileutils + textutils + sh-utils統合）
```

1991年、Linus TorvaldsがLinuxカーネルをリリースした。皮肉なことに、GNUプロジェクト自身のカーネルであるGNU Hurdは完成しなかった。だが、GNUのツール群は完成していた。Linuxカーネルの上にGNUのユーザランドを載せることで、完全に自由なUNIX互換システムが実現した。これがGNU/Linuxだ。Stallmanがこのシステムを「GNU/Linux」と呼ぶことにこだわるのは、カーネルだけではシステムは成立しないからだ。あなたが毎日使っているコマンド群は、GNUが作ったものだ。

---

## 3. GNU coreutilsの技術的設計――拡張と標準化

### fileutils、textutils、shellutilsの三系統

GNUのコマンドラインツール群は、当初三つの独立したパッケージとして開発されていた。

**GNU fileutils**は、ファイル操作に関するコマンドを収録していた。ls、cp、mv、rm、mkdir、chmod、chown、df、du、ln、touch、install。ファイルシステムを操作するための基本ツールだ。

**GNU textutils**は、テキスト処理に関するコマンドを収録していた。cat、head、tail、sort、uniq、wc、cut、paste、join、tr、expand、unexpand、fmt、fold、nl。テキストストリームを加工するためのツールだ。

**GNU shellutils（sh-utils）**は、シェル環境で使われるユーティリティを収録していた。echo、printf、date、whoami、hostname、uname、sleep、test、expr、seq、yes、true、false。シェルスクリプトの部品として機能するツールだ。

```
GNU coreutilsの三系統:

  fileutils（ファイル操作）:
    ls, cp, mv, rm, mkdir, rmdir, chmod, chown, chgrp,
    df, du, ln, touch, install, stat, ...

  textutils（テキスト処理）:
    cat, head, tail, sort, uniq, wc, cut, paste, join,
    tr, expand, unexpand, fmt, fold, nl, od, ...

  shellutils / sh-utils（シェルユーティリティ）:
    echo, printf, date, whoami, hostname, uname,
    sleep, test, expr, seq, yes, true, false, env, ...

  → 2003年、coreutils 5.0として統合
    合計100以上のコマンドを収録
```

2003年、これら三つのパッケージはGNU coreutils 5.0として統合された。統合前の最後の個別バージョンはfileutils 4.1.11、textutils 2.1、sh-utils 2.0.15だ。統合の理由は保守性の向上である。三つのパッケージには共通のコード（オプション解析、エラー処理、国際化対応など）が含まれており、それぞれで同じ修正を三回行う非効率を解消するためだった。

現在のGNU coreutilsは100以上のコマンドを収録している。あなたがLinuxマシンで日常的に使うコマンドの大半が、この一つのパッケージに含まれている。

### GNU拡張：long optionsの導入

GNUツールが既存のUNIXコマンドの「単なるクローン」ではないことを象徴するのが、long options（長いオプション）の導入だ。

オリジナルのUNIXコマンドは、短いオプション（single-letter options）を使う。`ls -l`、`grep -r`、`sort -n`。1文字のアルファベットに機能を割り当てる設計だ。この設計は簡潔だが、ツールが複雑化するにつれて問題が生じた。アルファベットは26文字しかない。大文字を加えても52文字。記号を含めてもすぐに枯渇する。しかも、`-r`がgrepでは「再帰」を意味し、sortでは「逆順」を意味するように、ツールごとに同じ文字が異なる機能に割り当てられている。

Richard Stallmanは、この限界を意識していた。Stallmanが学生時代に使っていたMITのITS（Incompatible Timesharing System）やDECのTOPS-20は、長い名前のオプションをサポートしていた。UNIXの1文字オプションは、テレタイプ時代の帯域制約の産物であり、それに固執する理由はなかった。

GNUプロジェクトは、既存の短いオプションとの互換性を保ちつつ、長いオプションを追加する方針を採った。当初、長いオプションにはプラス記号（+）がプレフィックスとして使われていた。だがこれは後にダブルダッシュ（--）に変更された。ダブルダッシュにより、`-abc`（短いオプション`-a`、`-b`、`-c`の結合）と`--abc`（長いオプション`abc`）を曖昧さなく区別できる。

```
短いオプション vs 長いオプション:

  短いオプション（オリジナルUNIX流）:
    $ ls -l -a -h
    $ ls -lah          ← 結合可能
    $ grep -r -n -i "pattern" .

  長いオプション（GNU拡張）:
    $ ls --long --all --human-readable
    $ grep --recursive --line-number --ignore-case "pattern" .

  自己文書化:
    $ ls -lah         ← l, a, hが何を意味するか、知らなければわからない
    $ ls --long --all --human-readable  ← 読めばわかる

  GNU getopt_long() の設計:
    -a          → 短いオプション（1文字）
    -abc        → 短いオプション3つの結合（-a -b -c）
    --abc       → 長いオプション "abc"
    --          → オプションの終了（以降はすべて引数として扱う）
```

この長いオプションの設計は、GNU C Libraryの`getopt_long()`関数として実装された。GNUツールの開発者はこの関数を使うことで、短いオプションと長いオプションの両方をサポートするコマンドを容易に作成できた。

長いオプションは「自己文書化」という大きな利点を持つ。`ls -lah`と書かれたスクリプトを読むとき、`l`、`a`、`h`が何を意味するかはmanページを参照しなければわからない。だが`ls --long --all --human-readable`と書かれていれば、英語として読める。シェルスクリプトの可読性は劇的に向上する。

### --helpと--versionの統一

GNUツールのもう一つの重要な設計決定は、`--help`と`--version`の統一だ。

オリジナルのUNIXコマンドには、ヘルプを表示する統一的な方法がなかった。`man ls`でmanページを読む方法はあったが、コマンド自身に「使い方を表示する」機能は標準化されていなかった。一部のコマンドは引数なしで使い方を表示し、別のコマンドは`-h`でヘルプを出し、また別のコマンドは`-h`がまったく別の意味を持っていた。

GNUプロジェクトは、すべてのGNUツールに`--help`オプションと`--version`オプションを実装することを規約とした。`--help`はコマンドの簡潔な使い方をstderrに出力し、`--version`はプログラム名とバージョン番号を出力する。この規約はGNU Coding Standardsに明記されている。

```bash
# どんなGNUコマンドでも --help が使える
$ ls --help
$ sort --help
$ cut --help

# どんなGNUコマンドでも --version が使える
$ ls --version
ls (GNU coreutils) 9.5
Copyright (C) 2024 Free Software Foundation, Inc.
...
```

この統一性は些細なことに見えるかもしれないが、100以上のコマンドすべてで同じ方法でヘルプとバージョン情報が取得できることの価値は大きい。ユーザーは新しいコマンドに出会ったとき、まず`--help`を打てばよい。この「予測可能性」は、UNIX哲学の「驚き最小の原則（Principle of Least Astonishment）」の実践だ。

### POSIXとGNU拡張の関係

ここで、POSIXとGNU拡張の関係を整理しておく必要がある。

POSIX（Portable Operating System Interface）は、IEEEが策定したUNIX互換OSの標準規格だ。1988年にIEEE Std 1003.1-1988として最初の標準が制定され、1992年にはPOSIX.2（IEEE Std 1003.2）でシェルとユーティリティの標準が定められた。

POSIXは「最小公約数」を定義する。lsがどのオプションをサポートすべきか、sortの動作はどうあるべきか。POSIXに準拠したコマンドは、どのUNIX互換OS上でも同じように動作することが期待される。

GNU coreutilsは、POSIXで定義された機能を完全に実装した上で、独自の拡張を追加している。`ls --color`はGNU拡張だ。`sort --human-numeric-sort`もGNU拡張だ。`head -n -5`（最後の5行を除いたすべて）も、POSIXのheadにはない負の行数指定というGNU拡張だ。

```
POSIXとGNU拡張の関係:

  POSIX標準（最小公約数）:
    $ ls -l          ← POSIX準拠
    $ sort -n        ← POSIX準拠
    $ head -n 10     ← POSIX準拠

  GNU拡張（追加機能）:
    $ ls --color=auto          ← GNU拡張
    $ ls --group-directories-first ← GNU拡張
    $ sort --human-numeric-sort    ← GNU拡張（-h）
    $ head -n -5               ← GNU拡張（負の行数指定）

  POSIXLY_CORRECT環境変数:
    $ export POSIXLY_CORRECT=1
    → GNUツールがPOSIX互換モードで動作する
    → GNU拡張は無効になり、POSIX準拠の動作のみ
```

GNUツールは`POSIXLY_CORRECT`環境変数が設定されていると、GNU拡張を抑制してPOSIX互換モードで動作する。これは、POSIXポータブルなスクリプトの検証に使える。

問題は、多くの開発者がGNU拡張を「UNIXの標準機能」だと誤解していることだ。Linux上で動くスクリプトを書いていると、GNU拡張に無意識に依存する。そのスクリプトをmacOS（BSDツール）やAlpine Linux（BusyBox）で実行したとき、初めて自分が何に依存していたかに気づく。

---

## 4. GNUツール vs BSDツール――二つの系譜

### なぜ二つの系譜があるのか

あなたが使っている`ls`がGNU lsなのかBSD lsなのかは、使っているOSによって決まる。大多数のLinuxディストリビューション（Ubuntu、Debian、Fedora、Arch Linux等）はGNU coreutilsを標準搭載している。一方、macOS、FreeBSD、OpenBSD、NetBSDはBSD由来のツール群を使っている。

この二つの系譜が生まれた背景には、UNIXの歴史がある。

1970年代から1980年代にかけて、UNIXはAT&Tのベル研究所で開発されたが、同時にカリフォルニア大学バークレー校（UCB）でもBSD（Berkeley Software Distribution）として独自の発展を遂げた。AT&T UNIXとBSDは、同じ根を持ちながら異なる実装を積み重ねた。1990年代にAT&TがUNIXのライセンスを厳格化すると、BSDは法的な問題を回避するためにAT&Tのコードを含まない「4.4BSD-Lite」を作成した。ここからFreeBSD、OpenBSD、NetBSDが派生した。

GNUプロジェクトもまた、AT&Tのコードを一切含まないクリーンルーム実装を目指した。結果として、UNIXの基本コマンドには三つの系譜が存在することになった。

```
UNIXコマンドの三つの系譜:

  AT&T UNIX（オリジナル）:
    Bell Labs で開発。プロプライエタリライセンス。
    現在は商用UNIX（Solaris/AIX/HP-UX）に残存。

  BSD（バークレー派生）:
    UCBで独自に発展。BSDライセンス。
    FreeBSD, OpenBSD, NetBSD, macOS が使用。

  GNU（自由ソフトウェア再実装）:
    Richard Stallman のGNUプロジェクト。GPLライセンス。
    Linux ディストリビューションが使用。

  → 同じ「ls」でも、出自が三つある
```

### 実際の差異：同じコマンド、異なる動作

GNUツールとBSDツールの差異は、日常的なコマンドに潜んでいる。以下に代表的な例を挙げる。

**ls：色付き出力**。GNU lsは`--color=auto`で出力に色をつける。BSD lsは`-G`フラグを使う。色の定義は、GNUではLS_COLORS環境変数（dircolorsコマンドで生成）、BSDではLSCOLORS環境変数（独自の書式）を使う。

**sed：インプレース編集**。GNU sedは`sed -i 's/old/new/' file`でファイルを直接編集できる。BSD sedは`sed -i '' 's/old/new/' file`と、`-i`の後に空文字列のバックアップ拡張子を明示しなければならない。この差異は、クロスプラットフォームのシェルスクリプトにおいて頻繁に問題となる。

**date：日付のフォーマット**。GNU dateは`date -d "2024-01-15"`で任意の日付を解析できる。BSD dateは`date -j -f "%Y-%m-%d" "2024-01-15"`と、異なるオプション体系を使う。

**xargs：引数の区切り**。GNU xargsは`-d`オプションで区切り文字を指定できる。BSD xargsにはこのオプションがない。

```
GNU vs BSD：代表的な差異

  色付き出力:
    GNU:  ls --color=auto     (LS_COLORS環境変数)
    BSD:  ls -G               (LSCOLORS環境変数)

  sedのインプレース編集:
    GNU:  sed -i 's/old/new/g' file
    BSD:  sed -i '' 's/old/new/g' file
              ↑ 空文字列のバックアップ拡張子が必須

  dateの日付解析:
    GNU:  date -d "2024-01-15" +%s
    BSD:  date -j -f "%Y-%m-%d" "2024-01-15" +%s

  long options:
    GNU:  ls --sort=size --reverse --human-readable
    BSD:  ls -Srh
          ↑ BSDはlong optionsを一部しかサポートしない
```

これらの差異はすべて、同じPOSIX標準の上に異なる拡張を積み重ねた結果だ。POSIXの範囲内でスクリプトを書けば両方で動くが、現実にはGNU拡張の便利さに依存してしまうことが多い。

### macOSという落とし穴

macOSを使う開発者は、特にこの問題に直面する。

macOSはDarwin（FreeBSD由来のカーネル）を基盤としており、コマンドラインツールはBSD系だ。だが、多くの開発者は日常的にLinux上で動くサーバを管理しており、手元のmacOSとリモートのLinuxで同じスクリプトが動くことを期待する。

Homebrewでは`brew install coreutils`でGNU coreutilsをインストールできる。デフォルトでは`g`プレフィックス（`gls`、`gsed`、`gawk`等）でインストールされ、PATH設定を変更すれば`ls`でGNU版を呼び出すこともできる。

だが、この「差異の上塗り」は本質的な解決ではない。チームの全員が同じHomebrewパッケージをインストールしている保証はない。CI/CD環境ではmacOSランナーとLinuxランナーで動作が異なる。Dockerを使って環境を統一する方が、根本的な解決策だ。

---

## 5. BusyBox――もう一つの再実装

### 1枚のフロッピーに全ツールを

GNUの再実装だけが、UNIXツールの再実装ではない。もう一つの重要な再実装がBusyBoxだ。

1995年、Bruce PerensはBusyBoxの開発を始めた。目的は明確だった。Debianのインストーラとレスキューディスクを1枚のフロッピーディスク（1.44MB）に収めること。GNU coreutilsは高機能だが、そのサイズは組み込み環境には大きすぎた。各コマンドが独立した実行ファイルであり、それぞれにELFヘッダやCライブラリのリンクが含まれる。100のコマンドがあれば、100のバイナリそれぞれにオーバーヘッドが乗る。

BusyBoxの解決策は単純かつ巧妙だった。すべてのコマンドを単一のバイナリに統合する。`ls`、`cat`、`grep`、`sh`――300以上のコマンドが一つの実行ファイルに含まれる。各コマンド名はBusyBoxバイナリへのシンボリックリンクだ。BusyBoxは`argv[0]`（自分がどの名前で呼ばれたか）を見て、対応するコマンドの機能を実行する。

```
BusyBoxのアーキテクチャ:

  GNU coreutils:
    /usr/bin/ls     → 独立したバイナリ (100KB)
    /usr/bin/cat    → 独立したバイナリ (60KB)
    /usr/bin/grep   → 独立したバイナリ (200KB)
    /usr/bin/sort   → 独立したバイナリ (120KB)
    ...
    → 100+のバイナリ、合計数十MB

  BusyBox:
    /bin/busybox    → 単一バイナリ (約1MB)
    /bin/ls         → busyboxへのシンボリックリンク
    /bin/cat        → busyboxへのシンボリックリンク
    /bin/grep       → busyboxへのシンボリックリンク
    /bin/sort       → busyboxへのシンボリックリンク
    ...
    → 1つのバイナリ + シンボリックリンク

  BusyBoxの動作:
    $ ls -la
    1. シェルが /bin/ls を実行
    2. /bin/ls は busybox へのシンボリックリンク
    3. busybox が argv[0] = "ls" を確認
    4. ls の機能を実行
```

BusyBoxは「The Swiss Army knife of Embedded Linux（組み込みLinuxのスイスアーミーナイフ）」と呼ばれる。1998年にDave Cinege（Linux Router Project）が開発を引き継ぎ、組み込みシステム向けに方向転換した。1999年からはErik Andersenがメンテナとなり、LinuxベースのルータやNAS、セットトップボックス、そしてAndroid端末に搭載されるようになった。

### Alpine LinuxとBusyBox

現代の開発者がBusyBoxに最も頻繁に出会うのは、Alpine Linuxだ。Alpine LinuxはBusyBoxとmusl libc（GNU glibcの軽量代替）を基盤とした軽量Linuxディストリビューションで、Dockerの公式イメージのベースとして広く使われている。

Alpine Linuxのベースイメージは5MB程度だ。対してUbuntuのベースイメージは約30MB。この差は、GNU coreutilsとBusyBoxのサイズ差に直接起因する。

だが、Alpine Linux上でGNU拡張に依存したスクリプトを動かすと失敗する。`ls --color=auto`は動く（BusyBoxが互換オプションをサポートしている場合がある）が、`sed -i`のGNU構文やdateの`-d`オプションは動作が異なる。Dockerfileの中で`apk add coreutils`を実行してGNU coreutilsをインストールすることもできるが、それではAlpineを使う意味（軽量さ）が半減する。

この問題は、BusyBoxが「GNU coreutilsの忠実なクローン」ではないことに起因する。BusyBoxは各コマンドの最小限の機能を実装しており、GNU拡張のすべてをサポートしているわけではない。これは設計上の選択だ。組み込み環境ではメモリとストレージが限られており、滅多に使われないオプションを省略することは合理的だ。

---

## 6. 自由なソフトウェアがCLIの普遍性を保証した

### もしGNUがなかったら

ここで思考実験をしてみたい。もしGNUプロジェクトが存在しなかったら、CLIの風景はどうなっていたか。

1990年代初頭、Linus TorvaldsがLinuxカーネルをリリースしたとき、その上で動作するユーザランドのコマンド群が必要だった。AT&Tのオリジナルコマンドは使えない（ライセンスの問題）。BSDのコマンドはBSDIとAT&Tの法廷闘争の最中にあり、法的に安全な状態ではなかった（1992年から1994年のUSL対BSDi訴訟）。

GNUのツール群は、この空白を埋めた。GPLライセンスの下で自由に使え、AT&Tのコードを一切含まない、クリーンルーム実装。LinuxカーネルとGNUユーザランドの組み合わせが「GNU/Linux」として急速に普及できた背景には、GNUツール群の法的・技術的な完成度があった。

もしGNUが存在しなければ、LinuxはBSDのユーティリティを使っていたかもしれない。あるいは、各ディストリビューションが独自にツール群を実装し、コマンドの互換性がなくなっていたかもしれない。GNUが事実上の標準となったことで、Linux世界全体でコマンドラインの一貫性が保たれた。

### 自由が互換性を担保する

GNUツールの「自由」は、技術的な意味でもCLIの普遍性を支えている。

GPLは、改変版の配布に際して同一のライセンス条件を要求する。つまり、あるディストリビューションがGNU lsを改変してもGPLの下で配布しなければならず、その改変はコミュニティに還元される。これにより、GNU coreutilsの動作はディストリビューション間で高い一貫性を保っている。UbuntuのlsもFedoraのlsもArch Linuxのlsも、同じGNU coreutilsのバージョンであれば同一の動作をする。

この一貫性は当たり前のようでいて、当たり前ではない。プロプライエタリな世界では、ベンダーごとにコマンドの拡張が異なり、互換性が失われる傾向がある。商用UNIX時代、Solaris、AIX、HP-UXのそれぞれで微妙に異なるlsの動作に悩まされた経験を持つ者なら、GNUによる統一の価値を理解できるだろう。

### uutils/coreutils：次世代の再実装

GNUの再実装が1980年代のCで書かれたのに対し、2020年代にはRust言語による再実装が進んでいる。uutils/coreutilsは、GNU coreutilsのクロスプラットフォーム再実装を目指すプロジェクトだ。

uutils/coreutilsの特徴は三つある。第一に、Rustのメモリ安全性。CやC++で書かれたGNU coreutilsに存在し得るバッファオーバーフローやメモリリークのリスクを、Rustの型システムと所有権モデルが構造的に排除する。第二に、クロスプラットフォーム対応。Linux、macOS、Windowsで同一のバイナリが動作することを目指している。第三に、BusyBox的な単一バイナリ構造も選択可能な設計。

uutils/coreutilsはGNU coreutilsのドロップイン代替を目指しており、GNU拡張の互換性も追求している。2025年時点でフィーチャーパリティに近づきつつあり、一部のLinuxディストリビューションでの採用が検討されている。

UNIXコマンドの再実装は、一度では終わらない。時代が変われば、技術が変わり、新しい再実装が生まれる。GNU coreutilsがAT&T UNIXを再実装したように、uutils/coreutilsがGNU coreutilsを再実装する。自由なソフトウェアは、この連鎖を可能にする。

---

## 7. ハンズオン：GNU vs BSDの差異を体験する

### 環境構築

```bash
# Docker環境で実行（ubuntu:24.04ベース）
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：GNU coreutilsのバージョン確認と--helpの統一性

```bash
apt-get update && apt-get install -y coreutils

echo "=== 演習1: GNU coreutilsの統一的インターフェース ==="
echo ""

echo "--- --version で出自を確認 ---"
ls --version 2>&1 | head -1
cat --version 2>&1 | head -1
sort --version 2>&1 | head -1
head --version 2>&1 | head -1
echo ""
echo "→ すべて 'GNU coreutils' と表示される"
echo "→ これらはAT&TのオリジナルUNIXコマンドではなく"
echo "   GNUプロジェクトによる再実装である"
echo ""

echo "--- --help の統一性 ---"
echo "すべてのGNUコマンドで --help が使える:"
echo ""
echo '$ ls --help | head -3'
ls --help 2>&1 | head -3
echo ""
echo '$ sort --help | head -3'
sort --help 2>&1 | head -3
echo ""
echo '$ wc --help | head -3'
wc --help 2>&1 | head -3
echo ""
echo "→ 使い方に迷ったらまず --help を試す"
echo "   これはGNUの規約であり、すべてのGNUツールで動作する"
```

### 演習2：GNU拡張の確認

```bash
echo ""
echo "=== 演習2: GNU拡張の実例 ==="
echo ""

# テスト用データの生成
mkdir -p /tmp/gnu-demo
cd /tmp/gnu-demo
for i in $(seq 1 5); do
    dd if=/dev/urandom of="file_${i}.dat" bs=1024 count=$((i * 100)) 2>/dev/null
done
mkdir subdir
echo "hello world" > subdir/test.txt

echo "--- GNU拡張: ls --color=auto ---"
echo '$ ls --color=auto'
ls --color=auto
echo ""
echo "→ --color はGNU拡張。BSDでは -G を使う"
echo ""

echo "--- GNU拡張: ls --human-readable --sort=size ---"
echo '$ ls -l --human-readable --sort=size'
ls -l --human-readable --sort=size *.dat
echo ""
echo "→ long options は自己文書化される"
echo "   -lhS と同じだが、意味が読み取りやすい"
echo ""

echo "--- GNU拡張: ls --group-directories-first ---"
echo '$ ls --group-directories-first'
ls --group-directories-first
echo ""
echo "→ ディレクトリを先頭に表示する GNU 独自機能"
echo ""

echo "--- GNU拡張: head の負の行数指定 ---"
seq 1 10 > /tmp/gnu-demo/numbers.txt
echo '$ head -n -3 numbers.txt'
head -n -3 /tmp/gnu-demo/numbers.txt
echo ""
echo "→ 最後の3行を除いた全行を出力"
echo "→ POSIX の head にはこの機能がない"
echo ""

echo "--- GNU拡張: sort --human-numeric-sort ---"
echo -e "1.5K\n2M\n500\n10G\n100K" > /tmp/gnu-demo/sizes.txt
echo '$ sort --human-numeric-sort sizes.txt'
sort --human-numeric-sort /tmp/gnu-demo/sizes.txt
echo ""
echo "→ K, M, G などの単位を理解してソートする GNU 拡張"
```

### 演習3：POSIXポータブルなスクリプトの書き方

```bash
echo ""
echo "=== 演習3: POSIXポータブル vs GNU依存 ==="
echo ""

echo "--- POSIXLY_CORRECT で GNU 拡張を無効化 ---"
echo ""
echo "通常モード（GNU拡張有効）:"
echo '$ head -n -3 numbers.txt'
head -n -3 /tmp/gnu-demo/numbers.txt 2>&1
echo ""

echo "POSIX互換モード（GNU拡張無効）:"
echo '$ POSIXLY_CORRECT=1 head -n -3 numbers.txt'
POSIXLY_CORRECT=1 head -n -3 /tmp/gnu-demo/numbers.txt 2>&1 || \
    echo "(エラー: POSIX の head は負の行数を受け付けない)"
echo ""

echo "--- ポータブルなスクリプトの書き方 ---"
echo ""

cat << 'EXAMPLE'
# 非ポータブル（GNU依存）:
sed -i 's/old/new/g' file          # BSD sed では動かない
date -d "2024-01-15" +%s           # BSD date では動かない
ls --color=auto                    # BSD ls では動かない

# ポータブル（POSIX準拠）:
sed 's/old/new/g' file > file.tmp && mv file.tmp file  # どこでも動く
# date の日付解析はPOSIXで標準化されていない → 代替手段を使う
ls -l                              # POSIX準拠のオプションのみ
EXAMPLE
echo ""

echo "--- sed の GNU/BSD 互換テクニック ---"
echo ""
echo "# macOS と Linux の両方で動く sed -i:"
cat << 'SEDTIP'
# 方法1: 一時ファイルを使う（最もポータブル）
sed 's/old/new/g' input.txt > output.txt && mv output.txt input.txt

# 方法2: OS判定で分岐
if sed --version 2>/dev/null | grep -q "GNU"; then
    sed -i 's/old/new/g' file
else
    sed -i '' 's/old/new/g' file
fi
SEDTIP
echo ""

echo "=== まとめ ==="
echo ""
echo "1. あなたが使っている ls, cat, sort は GNU coreutils の再実装"
echo "2. --version で出自を確認できる"
echo "3. --help はすべての GNU ツールで統一されている"
echo "4. GNU 拡張は便利だが、ポータビリティを損なう場合がある"
echo "5. POSIXLY_CORRECT=1 でポータブルかどうかを検証できる"
echo "6. クロスプラットフォームスクリプトでは POSIX 準拠を意識する"
```

ハンズオンの自動セットアップスクリプトは `handson/command-line/14-gnu-coreutils/setup.sh` を参照してほしい。

---

## 8. まとめと次回予告

### この回の要点

第一に、あなたが毎日使っている`ls`、`cat`、`grep`、`sort`は、AT&Tのオリジナルではなく、GNUプロジェクトによる再実装である。1983年9月27日のRichard StallmanによるUsenetへの投稿から始まったGNUプロジェクトは、「自由なソフトウェア」という思想の下、UNIXのツール群をゼロから書き直した。

第二に、GNUプロジェクトは「まずツール、最後にカーネル」という戦略を採った。GNU Emacs（1985年）、GCC（1987年）、そして膨大なユーティリティ群。1991年にLinuxカーネルが登場したとき、GNUのツール群は準備完了の状態にあった。この組み合わせがGNU/Linuxシステムとなった。

第三に、GNU coreutilsはfileutils、textutils、shellutilsの三つのパッケージが2003年に統合されて誕生した。100以上のコマンドを収録し、POSIX準拠の上にGNU独自の拡張（long options、--help/--versionの統一、--color等）を積み重ねている。

第四に、GNUツールとBSDツールには微妙だが重要な差異がある。`ls --color=auto`対`ls -G`、`sed -i`の構文差異、dateの日付解析の非互換性。macOS（BSD系）とLinux（GNU系）を行き来する開発者は、この差異を意識する必要がある。

第五に、BusyBox（1995年、Bruce Perens）はGNUとは異なるアプローチでUNIXツールを再実装した。300以上のコマンドを単一バイナリに統合し、組み込みLinuxとDocker（Alpine Linux）の世界で不可欠な存在となっている。

### 冒頭の問いへの暫定回答

あなたが毎日使っている`ls`や`cat`は、オリジナルのUNIXコマンドそのものなのか。

答えは否だ。それはGNUプロジェクトが「自由」の名の下に書き直したものだ。だが、この「書き直し」は単なるクローンではなかった。long optionsによる自己文書化、--helpと--versionの統一、色付き出力、人間可読なサイズ表示――GNUはオリジナルを超える使い勝手を実現した。そして、GPLライセンスによる「自由の連鎖」が、Linux世界全体でのコマンドラインの一貫性を保証した。

「自由なソフトウェア」という思想が、CLIツールの普遍性を支えている。GNUがなければ、あなたが今使っているLinuxのコマンドライン環境は存在しなかった。

### 次回予告

次回、第15回「Plan 9の夢――UNIXの先にあったもの」では、UNIXの創造者たち自身が「UNIXの何が不満だったのか」を語る。

Ken ThompsonとRob Pikeが1992年にベル研究所で開発したPlan 9は、UNIX哲学を極限まで推し進めたオペレーティングシステムだった。「Everything is a file」を文字通り実践し、ネットワークリソースもプロセス情報もウィンドウシステムもすべてファイルとして扱う。9Pプロトコル、per-process namespaces、UTF-8の発明――Plan 9のアイデアは商業的には失敗したが、形を変えて現代の技術に生き続けている。

あなたが日常的に使っているUTF-8が、Plan 9から生まれたことを知っているだろうか。

---

## 参考文献

- GNU Project, "Initial Announcement", <https://www.gnu.org/gnu/initial-announcement.en.html>
- GNU Project, "The GNU Manifesto", <https://www.gnu.org/gnu/manifesto.en.html>
- GNU Project, "What is Free Software?", <https://www.gnu.org/philosophy/free-sw.en.html>
- Wikipedia, "GNU Manifesto", <https://en.wikipedia.org/wiki/GNU_Manifesto>
- Wikipedia, "GNU Project", <https://en.wikipedia.org/wiki/GNU_Project>
- Wikipedia, "Richard Stallman", <https://en.wikipedia.org/wiki/Richard_Stallman>
- Wikipedia, "GNU Core Utilities", <https://en.wikipedia.org/wiki/GNU_Core_Utilities>
- Wikipedia, "List of GNU Core Utilities commands", <https://en.wikipedia.org/wiki/List_of_GNU_Core_Utilities_commands>
- Wikipedia, "GNU General Public License", <https://en.wikipedia.org/wiki/GNU_General_Public_License>
- Wikipedia, "GNU Emacs", <https://en.wikipedia.org/wiki/GNU_Emacs>
- Wikipedia, "GNU Compiler Collection", <https://en.wikipedia.org/wiki/GNU_Compiler_Collection>
- Wikipedia, "BusyBox", <https://en.wikipedia.org/wiki/BusyBox>
- Wikipedia, "POSIX", <https://en.wikipedia.org/wiki/POSIX>
- Wikipedia, "Getopt", <https://en.wikipedia.org/wiki/Getopt>
- GNU, "Coreutils FAQ", <https://www.gnu.org/software/coreutils/faq/coreutils-faq.html>
- GNU, "GNU Coding Standards - Compatibility", <https://www.gnu.org/prep/standards/html_node/Compatibility.html>
- FSF, "FSF History", <https://www.fsf.org/history/>
- The Open Group, "POSIX.1 Backgrounder", <https://www.opengroup.org/austin/papers/backgrounder.html>
- D-Mac's Blog, "Why Do Long Options Start with Two Dashes?", 2019, <https://blog.djmnet.org/2019/08/02/why-do-long-options-start-with/>
- Lars Wirzenius, "Unix command line conventions over time", 2022, <https://blog.liw.fi/posts/2022/05/07/unix-cli/>
- GitHub, uutils/coreutils, <https://github.com/uutils/coreutils>
- GitHub, "Using GNU command line tools in macOS instead of FreeBSD tools", <https://gist.github.com/aculich/2283cc616b61ea908c978cffe6e92b12>
- Robert Elder, "Robert Elder's Guide To GNU Coreutils", <https://blog.robertelder.org/gnu-coreutils-package-guide/>
