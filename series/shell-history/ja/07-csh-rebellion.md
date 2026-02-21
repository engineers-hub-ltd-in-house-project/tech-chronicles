# 第7回：C shell――Bill JoyのBourne shellへの反乱

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- Bill JoyがUCバークレーでC shellを開発した背景と動機
- cshが導入した革新的な対話機能――ヒストリ、エイリアス、ジョブコントロール、チルダ展開
- C言語風の構文設計とBourne shellとの根本的な違い
- Tom Christiansenの "Csh Programming Considered Harmful" が指摘したスクリプティングの致命的欠陥
- BSD vs System Vの分裂がシェル文化に与えた影響

---

## 1. 導入――「これはshとは別の言語だ」

2000年代初頭、私は大学の計算機室で初めてBSD系のUNIXに触れた。

それまでの私はLinux――Slackware、そしてRed Hat――の世界にいた。ターミナルを開けばbashが立ち上がる。それが当たり前だった。ところが、その大学の計算機室にはFreeBSDのワークステーションが並んでいた。ログインすると、プロンプトの雰囲気が違う。何気なく`for`ループを書こうとして、構文エラーが出た。

```
% for f in *.txt
for: Command not found.
```

何が起きたのか分からなかった。`for`がない？ そんなシェルがあるのか？

隣の席にいた先輩が教えてくれた。「それcshだよ。`foreach`を使え」。

```csh
% foreach f (*.txt)
? echo $f
? end
```

`foreach`？ `end`？ 丸括弧？ 私が知っているシェルの構文とはまったく違う。`if`文も`then`で始まり`endif`で終わる。Bourne shellの`fi`ではない。変数の設定も`set`コマンドを使う。代入演算子`=`の前に空白を置ける。

「これはshとは別の言語だ」――その直感は正しかった。

cshとBourne shellは、同じ「シェル」というカテゴリに属しながら、構文レベルでは互換性がない。まったく異なる設計思想に基づく、まったく異なる言語だ。bashやzshに慣れた現代のエンジニアの多くは、cshの構文を知らないだろう。だが、cshは「対話的シェル」という概念を実質的に発明したシェルであり、あなたが今使っているシェルの対話的機能――ヒストリ、エイリアス、ジョブコントロール――のほぼすべてが、cshに起源を持つ。

なぜBourne shellとまったく異なる構文のシェルが生まれたのか。2つのシェル文化はどのように分岐し、そしてその分岐は今日のシェルにどんな遺産を残したのか。

前回、私たちはパイプとUNIX哲学――「すべてはテキスト」という暗黙の契約とその限界――を議論した。今回はBourne shellの系譜を離れ、シェルの歴史におけるもう一つの大きな流れ、BSD側の「反乱」を辿る。

---

## 2. 歴史的背景――バークレーの大学院生が起こした革命

### Bill Joyという人物

C shellの物語は、一人の大学院生から始まる。

William Nelson Joy、1954年11月8日生まれ。1975年にミシガン大学で電気工学の学士号を取得した後、カリフォルニア大学バークレー校の大学院に進学した。バークレーでBob FabryのComputer Systems Research Group（CSRG）に加わり、BSD（Berkeley Software Distribution）の開発に携わることになる。

Joyの能力は突出していた。バークレー在学中に、彼はviエディタ（1976年頃からexの拡張として開発）、C shell、そしてBSDのTCP/IPネットワークスタックの初期実装に関わった。これらはいずれも、その後のUNIX――そしてインターネット――の歴史を決定づける仕事だ。1979年にMS（電気工学・計算機科学）を取得し、1982年にはSun Microsystemsを共同設立する。

Joyがcshを開発した1970年代後半、彼は20代前半の大学院生だった。この事実は重要だ。cshは、大企業の研究所が組織的に開発したプロダクトではない。一人の若く才気溢れるプログラマが、既存のシェルに対する不満から生み出したものだ。

### Bourne shellへの不満

Joyがcshを開発した動機を理解するには、当時のBourne shellの状況を知る必要がある。

1979年、Stephen BourneのBourne shellはUNIX V7とともにリリースされ、「標準シェル」の座を確立しつつあった。第4回で見たとおり、Bourne shellはシェルを「プログラミング言語」に昇格させた画期的な存在だ。しかし、対話的なシェルとしては、少なからぬ不満があった。

第一に、コマンド履歴がなかった。一度打ったコマンドを再利用するには、もう一度タイプするしかない。長いパイプラインを少し修正して再実行する――今日では当たり前のこの操作が、Bourne shellでは不可能だった。

第二に、エイリアスがなかった。頻繁に使うコマンドに短い別名を付ける機能がない。`ls -la`を毎回タイプし続けるしかなかった。

第三に、ジョブコントロールがなかった。フォアグラウンドで実行中のプロセスを一時停止し、バックグラウンドに回す。別のプロセスをフォアグラウンドに持ってくる。この操作ができなかった。

第四に、条件式の評価が遅かった。Bourne shellの`if`文は、条件部分を外部コマンド`test`（`[`）として実行する。子プロセスを起動して条件を評価するため、オーバーヘッドがあった。

そして第五に、構文がCプログラマにとって馴染みにくかった。Bourne shellの制御構造はALGOL 68の影響を受けており、`if`を`fi`で閉じ、`case`を`esac`で閉じる。Cを日常的に書くプログラマにとって、この逆転キーワードは違和感の源だった。

Joyは、これらの不満を解消するシェルを作ろうとした。

### 2BSDとしてのリリース――1979年5月

C shellは、2BSD（Second Berkeley Software Distribution）の一部として1979年5月にリリースされた。2BSDにはviエディタとC shellという2つの重要なプログラムが含まれており、どちらもJoyの手によるものだった。

Joy以外にも、Michael Ubell、Eric Allman、Mike O'Brien、Jim Kulpが初期の貢献者として記録されている。Eric Allmanは後にsendmailやsyslogの開発者として知られることになる人物だ。Jim Kulpについては後述するが、ジョブコントロールとディレクトリスタック機能の最初の実装者である。

Joyは "An Introduction to the C shell" という文書をBSDのドキュメントとして書いた（後にMark Seidenが4.3BSD向けに改訂）。この文書の冒頭で、Joyはcshを「UNIXの新しいコマンド言語インタプリタ」と紹介し、「他のシェルの良い機能と、INTERLISPのredoに類似したヒストリ機構を組み込んだ」と説明している。

「他のシェルの良い機能」――この表現は重要だ。cshはBourne shellを否定したのではなく、Bourne shellに欠けていた対話的機能を補完することを目指した。だが、その過程で構文レベルでの互換性を捨てた。この決断が、その後数十年にわたるシェル文化の分裂の起点となる。

### BSD vs System V――OSの分裂がシェルの分裂を生んだ

cshの登場は、UNIXの世界における大きな分裂と連動している。

1980年代、UNIXは大きく2つの系統に分かれた。AT&T（Bell Labs）が開発するSystem V系と、UCバークレーが開発するBSD系だ。この分裂は「Unix Wars」と呼ばれ、技術的にも文化的にも深い溝を生んだ。

技術的な違いは多岐にわたる。ネットワーキングではBSDのソケット（BSD 4.2で導入されたTCP/IPスタック）とSystem Vのストリーム。端末制御ではBSDのttyとSystem Vのtermio。そしてシェルでは、BSDのcshとSystem Vの/bin/sh（Bourne shell）だ。

文化的な分裂も顕著だった。プログラマや技術者はBSD側に、ビジネス指向の人々はSystem V側に集まる傾向があった。エンジニアリングワークステーションのベンダーはほぼすべてがBSDを採用した。BSDのTCP/IPネットワーキングが不可欠だったからだ。

この分裂の中で、「どのシェルを使うか」は単なる個人の好みではなく、所属する「陣営」の表明でもあった。BSD環境ではcshがデフォルトの対話シェルとして普及し、System V環境ではBourne shellが標準だった。同じ「UNIXのシェル」でありながら、構文が互換しない2つのシェルが並立する状況が、1980年代を通じて定着した。

1987年にAT&TとSun Microsystems（Joyが共同設立した会社だ）が統合に着手し、1988年にSystem V Release 4（SVR4）がリリースされた。SVR4はBSDの主要機能（ソケット、TCP/IP、csh、ジョブコントロール）をSystem Vに取り込み、分裂の解消を図った。だが、シェル文化の分裂はそう簡単には解消されなかった。

---

## 3. 技術論――cshの設計思想と構文の全体像

### C言語風の式文法

cshの最大の設計上の特徴は、C言語からの構文借用だ。

Bourne shellでは、条件式の評価に外部コマンド`test`（または`[`）を使う。

```sh
# Bourne shell: 外部コマンドtestを使った条件評価
if [ "$count" -gt 10 ]; then
  echo "count is greater than 10"
fi
```

この`[`は`/bin/[`（または`/usr/bin/[`）として存在する実際のプログラムだ。シェルは条件部分を評価するたびに子プロセスを起動し、`test`コマンドを実行する。

cshはこれとは根本的に異なるアプローチを取った。シェル自体に式評価器（expression evaluator）を内蔵し、C言語の演算子をほぼそのまま使えるようにした。

```csh
# C shell: 内蔵の式評価器を使った条件評価
if ($count > 10) then
  echo "count is greater than 10"
endif
```

丸括弧の中の式は、外部コマンドを起動することなくシェル内部で評価される。算術演算子（`+`, `-`, `*`, `/`, `%`）、比較演算子（`>`, `<`, `>=`, `<=`, `==`, `!=`）、論理演算子（`&&`, `||`, `!`）、ビット演算子（`&`, `|`, `^`, `~`）――Cプログラマが日常的に使う演算子がそのまま使えた。

この設計には明確な利点があった。第一に、外部プロセスを起動しないため高速だ。ループ内で多数の条件評価を行うスクリプトでは、この差が顕著に現れる。第二に、Cプログラマにとって読みやすい。`-gt`（greater than）の代わりに`>`と書ける。

ただし、完全にCと同じではなかった。演算子の結合規則（associativity）がCとは異なり、cshでは右から左に結合する（Cでは多くの演算子が左から右）。この差異は、複雑な式を書く際に思わぬ挙動を生むことがあった。

### 制御構造の比較

cshとBourne shellの制御構造を並べてみよう。

```
Bourne shell             C shell
─────────────────────── ─────────────────────────
if [ 条件 ]; then        if (条件) then
  コマンド                  コマンド
elif [ 条件 ]; then      else if (条件) then
  コマンド                  コマンド
else                     else
  コマンド                  コマンド
fi                       endif

for var in リスト; do    foreach var (リスト)
  コマンド                  コマンド
done                     end

while [ 条件 ]; do       while (条件)
  コマンド                  コマンド
done                     end

case $var in             switch ($var)
  パターン)              case パターン:
    コマンド                コマンド
    ;;                      breaksw
esac                     endsw
```

Bourne shellのキーワードはALGOL 68から借りた逆転キーワード（`fi`, `esac`, `done`）で終端される。cshのキーワードは`endif`, `end`, `endsw`と、より直感的な終端語を使う。Bourne shellの設計者Stephen BourneがALGOL 68の愛好者だったことはよく知られているが、Cプログラマの多数派にとっては、cshの構文のほうが馴染みやすかった。

### ヒストリ機構――INTERLISPからの着想

cshが導入した対話的機能の中で、最も日常的に使われたのがヒストリ機構だ。

Joyはこの機能をINTERLISP（BBN、後にXerox PARCで発展したLISP処理系）のredo機能に着想を得て設計した。INTERLISPは、ユーザが過去に入力したS式を修正して再評価する仕組みを持っていた。Joyはこの考え方をシェルに移植した。

ヒストリ機構の核は`!`（エクスクラメーションマーク、通称「bang」）文字だ。

```csh
# 直前のコマンドを再実行
!!

# 直前のコマンドの引数を再利用
echo !*

# コマンド番号42を再実行
!42

# "grep"で始まる直近のコマンドを再実行
!grep

# 直前のコマンドの最後の引数
echo !$

# 直前のコマンドの特定の引数を置換して再実行
!!:s/old/new/
```

この「bang記法」は、タイプ量を劇的に削減した。長いパイプラインを一文字変えて再実行する、前のコマンドの引数を使い回す――これらの操作が、コマンドを丸ごと再タイプすることなく可能になった。

Bourne shellにはこの機能がなかった。Bourne shellでコマンドを再実行するには、もう一度タイプするか、fc（fix command）コマンドを使う必要があった（fcはKorn shellで導入され、後にPOSIXに取り込まれた）。

cshのヒストリ記法は、そのまま後続のシェル――tcsh、bash、zsh――に引き継がれている。bashで`!!`を打てば直前のコマンドが再実行される。これはcshの遺産だ。

### エイリアス――コマンドの別名

エイリアスもcshが導入した機能だ。

```csh
# C shellでのエイリアス定義
alias ll 'ls -la'
alias h 'history 20'
alias rm 'rm -i'
```

エイリアスは、ユーザが定義した短い名前を、シェルが内部的に展開する仕組みだ。`ll`と打てばシェルが`ls -la`に展開して実行する。スクリプトを書くほどではないが、毎回タイプするには長すぎるコマンドに対して、エイリアスは完璧な解決策だった。

Bourne shellにはエイリアスがなかった。同等の機能を実現するには、シェル関数を定義するか、PATHの通ったディレクトリにラッパースクリプトを作る必要があった。いずれもエイリアスほど手軽ではない。

### チルダ展開――ホームディレクトリの短縮記法

`~`（チルダ）をホームディレクトリのパスに展開する機能も、cshが導入したものだ。

```csh
# チルダ展開
cd ~           # 自分のホームディレクトリ
cd ~/documents # ホームディレクトリ配下のdocuments
cd ~username   # 他のユーザのホームディレクトリ
```

今日では`~`がホームディレクトリを意味することはすべてのシェルユーザにとって常識だが、この記法はBourne shellには存在しなかった。Bourne shellでは`$HOME`環境変数を明示的に使う必要があった。cshが`~`をホームディレクトリの短縮記法として導入し、この記法が後にKorn shell、bash、zshに引き継がれた。

### ジョブコントロール――プロセスを支配する

cshのもう一つの重要な革新が、ジョブコントロールだ。

ジョブコントロールの最初の実装は、オーストリア・ラクセンブルクにあるIIASA（International Institute for Applied Systems Analysis、国際応用システム分析研究所）のJim Kulp（J.E. Kulp）によるものだった。Kulpは4.1BSDカーネルの機能を利用して、ジョブコントロールとディレクトリスタック機能をcshに実装した。ただし、Kulpが最初に実装した構文は、現在のものとは異なっていた。

ジョブコントロールにより、ユーザは実行中のプロセスに対してより細やかな制御を行えるようになった。

```csh
# フォアグラウンドのプロセスを一時停止
# Ctrl-Z を押す

# 停止したプロセスをバックグラウンドで再開
bg

# バックグラウンドのプロセスをフォアグラウンドに戻す
fg

# 実行中のジョブ一覧
jobs

# 特定のジョブをフォアグラウンドに持ってくる
fg %2
```

ジョブコントロール以前は、プロセスをバックグラウンドで実行するには、コマンドの末尾に`&`を付けて起動するしかなかった。一度フォアグラウンドで起動したプロセスを途中でバックグラウンドに回すことはできなかった。ジョブコントロールは、`Ctrl-Z`でプロセスを一時停止し、`bg`でバックグラウンドに回し、`fg`でフォアグラウンドに戻すという操作を可能にした。

この機能は後にKorn shellが採用し、SVR4版のBourne shellにも組み込まれた。今日のbashやzshのジョブコントロールは、cshとKulpの仕事に直接の源流を持つ。

### cshの対話的革新のまとめ

cshが導入した対話的機能を俯瞰すると、その革新性の大きさが分かる。

```
cshが導入した主要な対話的機能:

┌────────────────────────────────────────────────────┐
│ 機能             │ csh (1979)  │ Bourne sh (1979)  │
├────────────────────────────────────────────────────┤
│ ヒストリ機構     │ あり（!記法）│ なし              │
│ エイリアス       │ あり         │ なし              │
│ ジョブコントロール│ あり (4.1BSD)│ なし（SVR4で追加）│
│ チルダ展開 (~)   │ あり         │ なし              │
│ ディレクトリスタック│ あり (pushd/popd)│ なし         │
│ 内蔵式評価器     │ あり（C風）  │ なし（外部test）  │
│ パスハッシュ     │ あり         │ なし              │
│ cdpath           │ あり         │ なし              │
└────────────────────────────────────────────────────┘

これらの機能は、すべて後続のシェルに引き継がれた。
bash、zsh、fish――現代のあらゆるシェルは、
cshが切り拓いた「対話的シェル」の地平の上に立っている。
```

cshは「対話的シェル」という概念を実質的に発明した。Bourne shellが「プログラミング言語としてのシェル」を確立したとすれば、cshは「人間が対話的に使うためのシェル」を確立した。この2つの方向性――スクリプティングと対話――の分岐が、シェルの歴史における最も根源的なテンションとなっていく。

---

## 4. "Csh Programming Considered Harmful"――スクリプティングの致命的欠陥

### 対話の革命とスクリプティングの失敗

cshの対話的機能は革命的だった。だが、cshにはもう一つの顔がある。スクリプティング言語としての顔だ。そして、この顔は「失敗」と評されることになる。

1996年10月、Tom Christiansenが "Csh Programming Considered Harmful" と題した文書を公開した。この文書は、cshをスクリプティング言語として使うことの問題を体系的かつ痛烈に指摘したもので、シェルの世界における最も有名な「考慮有害」文書の一つとなった。

Christiansenの主張の核心はこうだ。「cshはプログラミングにまったく不適切なツールであり、そのような目的での使用は厳しく禁じられるべきである」。

この断言は過激に聞こえるかもしれない。だが、Christiansenが列挙した技術的問題は、いずれも実際にスクリプトの信頼性を損なう深刻なものだった。

### アドホックなパーサー

cshの最も根本的な問題は、パーサーの設計にある。

Bourne shellはスクリプトを実行前にパース（構文解析）し、構文エラーがあれば実行前に検出する。cshはこれとは異なり、実行しながらパースする。スクリプトの途中に構文エラーがあっても、その行に到達するまでエラーは検出されない。

これが意味することは重大だ。cshスクリプトは、特定の条件分岐に入ったときにだけ構文エラーで停止する可能性がある。テスト時には問題なく動作し、本番環境で異なる条件に遭遇したときに初めて壊れる。

```csh
#!/bin/csh
# このスクリプトは $flag が1のときだけ構文エラーで停止する
if ($flag == 1) then
  # 以下の行に構文エラーがあるが、
  # $flagが0のときはこのブロックに入らないため検出されない
  echo "処理開始
endif
```

Bourne shell系のシェルであれば、スクリプトの読み込み時にクォートの不一致が検出される。cshでは、そのコードパスが実行されるまで問題は発覚しない。

### ファイルディスクリプタ操作の制限

Bourne shellでは、任意のファイルディスクリプタを自由に操作できる。

```sh
# Bourne shell: 柔軟なファイルディスクリプタ操作
exec 3>logfile.txt         # fd 3をlogfileに向ける
echo "メッセージ" >&3      # fd 3に出力
exec 3>&-                  # fd 3を閉じる

# stderrだけをファイルに保存し、stdoutは端末に出す
command 2>error.log

# stderrをstdoutにマージ
command 2>&1

# stdoutをファイルに、stderrを別のファイルに
command >output.log 2>error.log
```

cshでは、こうした柔軟な操作ができない。cshのリダイレクション機能は以下に限定される。

```csh
# C shell: 限定的なリダイレクション
command > file      # stdoutをファイルにリダイレクト
command >& file     # stdoutとstderrをファイルにリダイレクト
command | command2  # パイプ（stdoutのみ）
command |& command2 # パイプ（stdoutとstderrをマージ）
```

stdoutとstderrを別々のファイルにリダイレクトする――Bourne shellでは`command >out.log 2>err.log`と一行で書ける処理が、cshでは直接的には不可能だ。回避策として、サブシェルやラッパースクリプトを使う必要がある。

この制限は、ロギングやエラーハンドリングを真剣に行うスクリプトにとって致命的だ。

### シグナルハンドリングの制限

Bourne shellでは`trap`コマンドで任意のシグナルを捕捉できる。

```sh
# Bourne shell: 柔軟なシグナルハンドリング
trap 'echo "終了処理"; rm -f /tmp/lockfile; exit' INT TERM EXIT
trap '' HUP  # SIGHUPを無視
```

cshでは、トラップできるシグナルはSIGINTのみだ。

```csh
# C shell: SIGINTのみトラップ可能
onintr cleanup
# ...処理...
cleanup:
  echo "中断されました"
  exit 1
```

SIGTERMやSIGHUPを捕捉できない。一時ファイルのクリーンアップやロックファイルの解放を確実に行う必要があるスクリプトでは、この制限は致命的な信頼性の問題を生む。

### パイプと制御構造の非互換

Bourne shellでは、パイプの中に制御構造を自由に組み込める。

```sh
# Bourne shell: パイプの中で制御構造が使える
if grep -q "ERROR" logfile; then
  cat logfile | grep "ERROR"
fi | wc -l

# ループの出力をパイプに流す
for f in *.log; do
  grep "ERROR" "$f"
done | sort | uniq -c
```

cshでは、パイプと制御構造の組み合わせに制限がある。制御構造の出力を直接パイプに流すには、別のスクリプトに切り出すか、サブシェルを使う回避策が必要になる。

### これらの問題が意味すること

cshのスクリプティングにおける問題は、個々の制限としてはそれぞれ回避策が存在する。だが、問題の本質はその集積にある。アドホックなパーサー、限定的なファイルディスクリプタ操作、貧弱なシグナルハンドリング、パイプと制御構造の非互換――これらの制限が重なると、ある程度の複雑さを超えたスクリプトは、cshでは信頼性を担保できなくなる。

Christiansenの結論は明確だった。cshのスクリプティングの問題は「設計上の欠陥」であり、cshをスクリプティング言語として使用すべきではない。

この結論は、cshの価値を全否定するものではない。Christiansenが批判したのはcshの「スクリプティング」機能であって、「対話的シェル」としてのcshではない。実際、cshは対話的シェルとしては大きな成功を収めた。問題は、対話的シェルとして優れた機能と、スクリプティング言語としての堅牢性が、同じ設計の中で両立しなかったことだ。

---

## 5. ハンズオン――cshの構文と対話機能を体験する

理論だけでは実感が湧かない。実際にcshを起動し、Bourne shell系との構文の違いと、cshが導入した対話的機能の革新性を体験しよう。

### 環境構築

Docker環境を前提とする。

```bash
docker run -it ubuntu:24.04 bash
# コンテナ内で:
apt-get update && apt-get install -y csh tcsh
```

あるいは、本記事に付属する`setup.sh`スクリプトを使えば、演習環境の構築を一括で行える。

```bash
bash setup.sh
```

### 演習1：cshとshの構文比較――同じ処理を両方で書く

まず、同じ処理をBourne shell構文とcsh構文の両方で書き、構文の違いを体感する。

```sh
# --- 演習1: 構文比較 ---

WORK="/tmp/csh-demo"
mkdir -p "$WORK"

# Bourne shell版のスクリプト
cat > "$WORK/count.sh" << 'SHEOF'
#!/bin/sh
# Bourne shell: 1から5までカウント
count=1
while [ "$count" -le 5 ]; do
  echo "sh: count = $count"
  count=$((count + 1))
done
SHEOF
chmod +x "$WORK/count.sh"

# C shell版のスクリプト
cat > "$WORK/count.csh" << 'CSHEOF'
#!/bin/csh
# C shell: 1から5までカウント
set count = 1
while ($count <= 5)
  echo "csh: count = $count"
  @ count = $count + 1
end
CSHEOF
chmod +x "$WORK/count.csh"

echo "=== Bourne shell版 ==="
sh "$WORK/count.sh"
echo ""
echo "=== C shell版 ==="
csh "$WORK/count.csh"
echo ""

echo "--- 構文の違い ---"
echo "変数代入:    sh: count=1       csh: set count = 1"
echo "比較演算:    sh: [ \"\$count\" -le 5 ]  csh: (\$count <= 5)"
echo "算術演算:    sh: count=\$((count+1))  csh: @ count = \$count + 1"
echo "ブロック終端: sh: done            csh: end"
```

### 演習2：cshの対話的機能を体験する

cshのヒストリ機構とエイリアスを実際に使ってみる。

```sh
# --- 演習2: cshの対話的機能 ---

# cshのヒストリ機構をスクリプトでシミュレーション
cat > "$WORK/history-demo.csh" << 'CSHEOF'
#!/bin/csh
# ヒストリ機構のデモ
set history = 100

echo "=== cshヒストリ機構のデモ ==="
echo ""

# エイリアスの定義
alias ll 'ls -la'
alias h 'history'

echo "--- エイリアス一覧 ---"
alias
echo ""

echo "--- ヒストリの使い方（対話モードで有効） ---"
echo '!!      : 直前のコマンドを再実行'
echo '!n      : コマンド番号nを再実行'
echo '!grep   : "grep"で始まる直近のコマンドを再実行'
echo '!$      : 直前のコマンドの最後の引数'
echo '!!:s/old/new/ : 直前のコマンドの一部を置換して再実行'
echo ""

echo "--- チルダ展開のデモ ---"
echo "ホームディレクトリ: ~"
echo "展開結果: $HOME"
CSHEOF
csh "$WORK/history-demo.csh"
```

### 演習3：if文の構文比較

条件分岐の構文をsh、csh、bashで比較する。

```sh
# --- 演習3: if文の構文比較 ---

# Bourne shell版
cat > "$WORK/iftest.sh" << 'SHEOF'
#!/bin/sh
value=42
if [ "$value" -gt 30 ]; then
  echo "sh: $value は 30 より大きい"
elif [ "$value" -gt 20 ]; then
  echo "sh: $value は 20 より大きい"
else
  echo "sh: $value は 20 以下"
fi
SHEOF

# C shell版
cat > "$WORK/iftest.csh" << 'CSHEOF'
#!/bin/csh
set value = 42
if ($value > 30) then
  echo "csh: $value は 30 より大きい"
else if ($value > 20) then
  echo "csh: $value は 20 より大きい"
else
  echo "csh: $value は 20 以下"
endif
CSHEOF

echo "=== if文の構文比較 ==="
echo ""
echo "--- Bourne shell版 ---"
sh "$WORK/iftest.sh"
echo ""
echo "--- C shell版 ---"
csh "$WORK/iftest.csh"
echo ""

echo "--- 構文の違い ---"
echo "条件式:  sh: [ \"\$value\" -gt 30 ]  csh: (\$value > 30)"
echo "         shは外部コマンドtestを起動   cshは内蔵式評価器で処理"
echo "終端:    sh: fi (ALGOL 68由来)       csh: endif (C風)"
```

### 演習4：cshスクリプティングの制限を体験する

cshの「スクリプティング言語としての弱さ」を実際に確認する。

```sh
# --- 演習4: cshスクリプティングの制限 ---

echo "=== cshスクリプティングの制限を確認 ==="
echo ""

# 制限1: ファイルディスクリプタ操作
echo "--- 制限1: stdoutとstderrの分離 ---"
echo ""

# Bourne shell: stdoutとstderrを別ファイルに
cat > "$WORK/redir.sh" << 'SHEOF'
#!/bin/sh
echo "これはstdout" > /tmp/csh-demo/out.txt 2> /tmp/csh-demo/err.txt
ls /nonexistent 2>> /tmp/csh-demo/err.txt
echo "stdout: $(cat /tmp/csh-demo/out.txt)"
echo "stderr: $(cat /tmp/csh-demo/err.txt)"
SHEOF
echo "Bourne shellでのstdout/stderr分離:"
sh "$WORK/redir.sh"
echo ""

echo "C shellでは stdout と stderr を別々のファイルに"
echo "リダイレクトする直接的な構文がない。"
echo "'>' はstdoutのみ、'>&' はstdoutとstderrの両方。"
echo "分離するには外部コマンドやサブシェルの回避策が必要。"
echo ""

# 制限2: ループ出力のパイプ（Bourne shell）
echo "--- 制限2: ループ出力のパイプ ---"
echo ""
cat > "$WORK/loop-pipe.sh" << 'SHEOF'
#!/bin/sh
# Bourne shell: ループの出力を直接パイプに流せる
for word in apple banana cherry apple banana apple; do
  echo "$word"
done | sort | uniq -c | sort -rn
SHEOF
echo "Bourne shell: ループの出力をパイプに:"
sh "$WORK/loop-pipe.sh"
echo ""
echo "C shellではこの構文が直接使えない場合がある。"
echo ""

# 制限3: シグナルハンドリング
echo "--- 制限3: シグナルハンドリング ---"
cat > "$WORK/trap.sh" << 'SHEOF'
#!/bin/sh
# Bourne shell: 複数のシグナルをトラップ可能
trap 'echo "SIGINT受信"; exit 1' INT
trap 'echo "SIGTERM受信"; exit 1' TERM
trap 'echo "終了処理"' EXIT
echo "シグナルハンドラ設定済み（INT, TERM, EXIT）"
SHEOF
echo "Bourne shell: 複数シグナルのtrap:"
sh "$WORK/trap.sh"
echo ""
echo "C shell: onintr で SIGINT のみトラップ可能。"
echo "SIGTERM や EXIT のトラップはできない。"
```

### 演習5：foreachとfor――ファイル処理の構文比較

実用的なファイル処理タスクで両方の構文を比較する。

```sh
# --- 演習5: 実用的な構文比較 ---

# テストファイルの作成
mkdir -p "$WORK/logs"
echo "ERROR: disk full" > "$WORK/logs/app1.log"
echo "INFO: started" >> "$WORK/logs/app1.log"
echo "ERROR: timeout" >> "$WORK/logs/app1.log"
echo "INFO: running" > "$WORK/logs/app2.log"
echo "ERROR: connection refused" > "$WORK/logs/app3.log"
echo "INFO: completed" >> "$WORK/logs/app3.log"

# Bourne shell版
cat > "$WORK/logscan.sh" << 'SHEOF'
#!/bin/sh
echo "=== Bourne shell: ログスキャン ==="
for logfile in /tmp/csh-demo/logs/*.log; do
  errors=$(grep -c "ERROR" "$logfile")
  if [ "$errors" -gt 0 ]; then
    basename=$(basename "$logfile")
    echo "$basename: $errors 件のエラー"
  fi
done
SHEOF

# C shell版
cat > "$WORK/logscan.csh" << 'CSHEOF'
#!/bin/csh
echo "=== C shell: ログスキャン ==="
foreach logfile (/tmp/csh-demo/logs/*.log)
  set errors = `grep -c "ERROR" "$logfile"`
  if ($errors > 0) then
    set basename = `basename "$logfile"`
    echo "${basename}: $errors 件のエラー"
  endif
end
CSHEOF

echo "--- Bourne shell版 ---"
sh "$WORK/logscan.sh"
echo ""
echo "--- C shell版 ---"
csh "$WORK/logscan.csh"
echo ""

echo "=== 構文の対比 ==="
echo "ループ:     sh: for f in *.log; do...done"
echo "            csh: foreach f (*.log)...end"
echo "コマンド置換: sh: \$(command)  csh: \`command\`"
echo "条件式:     sh: [ \"\$errors\" -gt 0 ]"
echo "            csh: (\$errors > 0)"
```

---

## 6. まとめと次回予告

### この回の要点

第一に、C shellはUCバークレーの大学院生Bill Joyが1970年代後半に開発し、1979年5月に2BSD（Second Berkeley Software Distribution）の一部としてリリースされた。Bourne shellへの不満――コマンド履歴の欠如、エイリアスの不在、ジョブコントロールの不備、対話的機能の貧弱さ――が開発の動機だった。

第二に、cshはC言語から構文を借用し、シェル内蔵の式評価器を持つことで、Bourne shellの外部コマンド`test`依存を回避した。制御構造の終端にはC風の`endif`, `end`, `endsw`を使い、ALGOL 68由来の逆転キーワード`fi`, `done`, `esac`とは異なる設計を選んだ。

第三に、cshはヒストリ機構（INTERLISPのredoに着想）、エイリアス、チルダ展開、ジョブコントロール（Jim KulpがIIASAで最初に実装）、ディレクトリスタックなど、今日の対話的シェルの基盤となる機能を導入した。これらの機能はすべて後続のシェルに引き継がれている。

第四に、cshはスクリプティング言語としては深刻な欠陥を持っていた。Tom Christiansenの1996年の文書 "Csh Programming Considered Harmful" は、アドホックなパーサー、ファイルディスクリプタ操作の制限、シグナルハンドリングの貧弱さ、パイプと制御構造の非互換を体系的に指摘した。

第五に、cshの登場はBSD vs System Vという1980年代のUNIX分裂と連動しており、「どのシェルを使うか」がOS陣営の選択と結びついていた。この分裂は、シェルの歴史における「対話」と「スクリプティング」という2つの方向性の乖離を可視化した。

### 冒頭の問いへの暫定回答

「なぜBourne shellとまったく異なる構文のシェルが生まれたのか」――この問いに対する暫定的な答えはこうだ。

Bourne shellは「シェルをプログラミング言語にする」ことに注力し、対話的な使い勝手を二の次にした。Bill Joyはその不満を構文レベルで解消しようとし、Cプログラマにとって自然な構文と、INTERLISPから着想を得た対話的機能を持つ新しいシェルを設計した。構文の互換性を維持する選択肢もあったはずだが、Joyはそれを選ばなかった。結果として生まれたのは、対話的には革命的だがスクリプティングには不向きな、Bourne shellとは別系統のシェルだった。

「2つのシェル文化はどう分岐したのか」――BSD vs System Vの分裂が、シェルの分岐を加速した。BSDの世界ではcshが、System Vの世界ではBourne shellが標準となり、2つの互換しない構文体系が並立した。この分岐は最終的には「対話にはcsh系、スクリプティングにはsh系」という使い分けの定着を促し、「シェルの二つの文化」――対話とスクリプティングの乖離――を構造化した。

cshの物語が教えてくれるのは、一つのツールが対話とスクリプティングの両方で最適であることの困難さだ。cshは対話のために最適化された結果、スクリプティングで致命的な弱点を持つことになった。Bourne shellはスクリプティングのために設計された結果、対話的機能が貧弱だった。この二律背反は、後のシェルの歴史において繰り返し現れるテーマとなる。

### 次回予告

次回は、cshの系譜を引き継ぎ、対話的シェルの可能性をさらに押し広げたtcshを語る。

1983年、カーネギーメロン大学のKen Greerがcshにコマンドライン補完機能を追加したtcsh（TENEX C shell）を生み出した。「TABキーを押せばファイル名が補完される」――今日では当たり前のこの機能は、tcshが世界に示したものだ。同じ頃、Brian FoxがGNUプロジェクトの一環としてGNU Readlineを開発し、コマンドライン編集をライブラリとして分離するという設計判断を下した。

コマンドライン補完とコマンドライン編集は、シェルを「命令入力装置」から「対話的インタフェース」に変えた。あなたが毎日何十回も押しているTABキーの歴史を、次回は辿る。

---

## 参考文献

- Bill Joy, "An Introduction to the C shell" (revised for 4.3BSD by Mark Seiden), UC Berkeley <https://docs-archive.freebsd.org/44doc/usd/04.csh/paper.html>
- C shell, Wikipedia <https://en.wikipedia.org/wiki/C_shell>
- Bill Joy, Wikipedia <https://en.wikipedia.org/wiki/Bill_Joy>
- Tom Christiansen, "Csh Programming Considered Harmful", 1996 <https://www-uxsup.csx.cam.ac.uk/misc/csh.html>
- Bruce Barnett, "Top Ten Reasons not to use the C shell" <https://www.grymoire.com/unix/CshTop10.txt>
- Job control (Unix), Wikipedia <https://en.wikipedia.org/wiki/Job_control_(Unix)>
- Berkeley Software Distribution, Wikipedia <https://en.wikipedia.org/wiki/Berkeley_Software_Distribution>
- Unix wars, Wikipedia <https://en.wikipedia.org/wiki/Unix_wars>
- History of the Berkeley Software Distribution, Wikipedia <https://en.wikipedia.org/wiki/History_of_the_Berkeley_Software_Distribution>
- csh(1), OpenBSD manual pages <https://man.openbsd.org/csh.1>
