# 第9回：シェルの二つの文化――スクリプティングと対話の乖離

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- 「対話用シェル」と「スクリプト用シェル」がなぜ分離したのか――cshの功罪から始まる構造的必然
- Tom Christiansen "Csh Programming Considered Harmful" が突きつけた問題の本質
- Debian/Ubuntuが/bin/shをdashに変更した技術的・政治的判断（Ubuntu 2006年、Debian 2011年）
- POSIX shの設計思想――「対話」と「スクリプティング」に対する非対称な態度
- bash依存構文（bashisms）の実態と、checkbashismsによる検出
- 各ディストリビューションの/bin/sh実装の違いとその意味
- shebang行の歴史――#!/bin/shが「契約」になるまで

---

## 1. 導入――なぜ #!/bin/zsh と書かないのか

私は対話シェルとしてzshを使っている。

プロンプトのカスタマイズ、高度な補完、拡張グロビング――zshの対話的機能は、日常のターミナル操作において圧倒的に快適だ。前回までに辿ったように、tcshがTENEXの補完を移植し、kshがコマンドライン編集を実装し、GNU Readlineがそれをライブラリ化した。zshはそのすべてを吸収し、さらに先へ進んだシェルだ。

しかし、私がシェルスクリプトを書くとき、ファイルの先頭にはこう書く。

```bash
#!/bin/sh
```

あるいは、bash固有の機能が必要なときは、こう書く。

```bash
#!/bin/bash
```

`#!/bin/zsh`とは書かない。

これは習慣ではない。意識的な選択だ。スクリプトが動く環境を限定したくないからだ。自分のマシンにはzshが入っている。だが、CIサーバには入っていないかもしれない。Docker alpineコンテナには入っていない。同僚のマシンに入っている保証もない。

ここに「シェルの二つの文化」の核心がある。

対話的に使うシェルと、スクリプトを実行するシェルは、まったく異なる要件を持つ。対話シェルには補完、構文ハイライト、プロンプトカスタマイズ、ヒストリ検索が必要だ。スクリプト用シェルにはポータビリティ、高速起動、明確なエラーハンドリング、予測可能な挙動が必要だ。そして、この二つの要件は、しばしば矛盾する。

あなたはどうだろうか。対話用のシェルとスクリプト用のシェルを、意識的に使い分けているだろうか。あるいは、「bashが両方やってくれる」と考えているだろうか。

この回では、シェルの歴史がこの「二つの文化」をいかにして生み出したのかを辿る。cshが対話の革命を起こしながらスクリプティングで挫折した教訓から、Debianが/bin/shをdashに変えた判断まで。シェルの本質的な緊張を、正面から論じたい。

---

## 2. 歴史的背景――二つの文化はいかにして分岐したか

### cshの成功と失敗――分岐の起点

第7回と第8回で、私たちはcshとtcshの歴史を辿った。1978年にBill Joyが生み出したC shellは、対話的シェルという概念を実質的に発明した。ヒストリ機能、ジョブコントロール、エイリアス、チルダ展開――これらの革新は、シェルを「コマンド入力装置」から「対話的作業環境」へと変貌させた。

しかし、cshにはもう一つの顔があった。スクリプティング言語としての顔だ。そしてその顔は、醜いものだった。

cshのスクリプティングの問題は、個別のバグではなく、言語設計の根幹に関わるものだった。1990年代半ば、Tom Christiansenが"Csh Programming Considered Harmful"を発表した。この文書はUNIXプログラミングの世界で広く読まれ、cshのスクリプティング言語としての致命的欠陥を体系的に指摘した古典的テキストとなった。冒頭の一文は明快だ。

> "The csh is a tool utterly inadequate for programming, and its use for such purposes should be strictly banned."

Christiansenが指摘した欠陥は多岐にわたる。その中でも特に深刻なものを見てみよう。

**標準エラー出力のリダイレクトができない。** Bourne shellでは`2>/dev/null`でstderrをリダイレクトできる。cshにはファイルディスクリプタを個別にリダイレクトする構文が存在しない。できるのは`>&`でstdoutとstderrを同時にリダイレクトすることだけだ。stderrだけをファイルに送り、stdoutは端末に表示したい？ cshでは直接的にはできない。

```csh
# Bourne shell: stderrだけリダイレクトできる
command 2>/dev/null

# csh: stdout と stderr をまとめるしかない
command >& /dev/null
# stderrだけをリダイレクトする直接的な方法がない
```

**関数が存在しない。** Bourne shellには関数がある。cshにはない。コードの再利用はaliasに頼るしかない。aliasは単純な文字列置換であり、引数を扱うのは困難だ。複雑なロジックを再利用可能な単位にまとめることが、言語の水準でできない。

**シグナルハンドリングが貧弱だ。** Bourne shellの`trap`コマンドは、任意のシグナルに対してクリーンアップ処理を定義できる。cshの`onintr`は機能が限定的であり、堅牢なスクリプトに必要な細やかなシグナル制御ができない。

これらは「バグ」ではない。cshの言語設計そのものの限界だ。Bill Joyがcshを設計したとき、主眼は対話的操作の改善にあった。C風の構文はプログラマにとって親しみやすく、ヒストリやジョブコントロールは日常操作を劇的に改善した。だが、スクリプティング言語としての堅牢性は、設計のスコープに十分に含まれていなかったのだ。

### Bourne shellの対極――スクリプティングの堅牢性と対話の貧弱さ

cshの対極にあったのがBourne shellだ。

Stephen Bourneが1979年に設計したBourne shellは、スクリプティング言語として堅実だった。ファイルディスクリプタの自在な操作、`trap`による細やかなシグナルハンドリング、関数、here document――これらはスクリプトの堅牢性を支える基盤だった。

だが、第4回で触れたように、Bourne shellの対話的機能は貧弱だった。コマンドライン編集がない。補完がない。ヒストリ機能がない（cshのヒストリをBourne系に持ち込んだのはkshだ）。ジョブコントロールもない（これもcshの発明であり、後にBourne系に取り込まれた）。

ここに構造的な乖離が生じた。

```
対話的機能の優劣:
csh/tcsh  ████████████████████  ← 補完、ヒストリ、ジョブコントロール
Bourne sh ███                   ← なし

スクリプティング言語としての堅牢性:
csh/tcsh  ██████                ← stderrリダイレクト不可、関数なし
Bourne sh ████████████████████  ← trap、関数、fd操作
```

1980年代のUNIXユーザは、対話にはcsh/tcshを使い、スクリプトにはBourne shellを使うという使い分けを、暗黙のうちに確立していった。login shellにはcshを設定し、スクリプトのshebang行には`#!/bin/sh`と書く。この二重構造は「仕方なく」生まれたものだったが、やがてUNIXの文化として定着した。

### shebang行の誕生――スクリプトが実行者を選ぶ

ここで、shebang行の歴史に触れなければならない。

1980年1月、Dennis Ritchieがカーネルにインタプリタディレクティブのサポートを追加した。Version 8 Unix向けの変更だ。ファイルの先頭が`#!`で始まる場合、カーネルはその後に続くプログラムをインタプリタとしてスクリプトを実行する。

Ritchie自身が書いたメール（1980年1月10日付）にはこうある。

> The system has been changed so that if a file being executed begins with the magic characters #!, the rest of the line is understood to be the name of an interpreter for the executed file.

この変更により、`#!/bin/sh`と書かれたスクリプトはBourne shellで実行され、`#!/bin/csh`と書かれたスクリプトはC shellで実行されるようになった。スクリプト自身が「自分をどのインタプリタで実行するか」を宣言できるようになったのだ。

shebang行の導入は、「二つの文化」に技術的な基盤を与えた。対話的シェルとして何を使おうと、スクリプトは自分のインタプリタを指定できる。login shellがcshでも、`#!/bin/sh`のスクリプトはBourne shellで動く。この分離が、UNIXの多様なシェル文化を可能にした。

そして`#!/bin/sh`は、単なるパス指定を超えた意味を持つようになる。「このスクリプトはPOSIX互換シェルで動作する」という契約だ。`/bin/sh`が何を指すか――bash、dash、ash、あるいはksh――はシステムによって異なる。だが、`#!/bin/sh`と書かれたスクリプトは、どの`/bin/sh`でも動くことが期待される。この期待こそが、「ポータブルシェルスクリプト」という概念の根幹にある。

### kshとbash――「全部入り」の試み

cshの対話的革新をBourne shell系列に取り込もうという試みは、1983年のKorn shell（ksh）に始まる。

kshはBourne shell互換の構文を持ちながら、cshの対話的機能（ヒストリ、エイリアス、ジョブコントロール）とコマンドライン編集（emacsモード、viモード）を統合した。連想配列や算術展開などの言語拡張も加え、「スクリプティングにも対話にも強いシェル」を目指した。だが、AT&Tのプロプライエタリライセンスがkshの普及を阻んだことは第10回で詳しく語る。

1989年に登場したbashは、kshの路線を引き継いだ。GNU Readlineによるコマンドライン編集、csh由来のヒストリ展開、プログラマブル補完、配列、プロセス置換――bashはスクリプティングと対話の両方で使える「全部入り」のシェルとして、Linuxの普及とともに覇権を握った。

bashの成功は、一見すると「二つの文化」の統合に見える。対話にもスクリプティングにもbashを使えばいい。実際、多くのエンジニアがそうしている。

しかし、bashの「全部入り」は、別の問題を生んだ。

### Debianの決断――/bin/shをdashに変える

2006年10月、Ubuntu 6.10（Edgy Eft）がリリースされた。このリリースには、一見地味だが影響の大きい変更が含まれていた。`/bin/sh`がbashからdashに変更されたのだ。

dash（Debian Almquist shell）は、Kenneth Almquistが1989年に開発したash（Almquist shell）のDebian向けフォークだ。POSIX準拠の最小限のシェルであり、bashに比べてバイナリサイズが小さく、起動が速い。

なぜUbuntuはこの変更を行ったのか。理由は明確だ。

Ubuntuのブートプロセスでは、大量のシェルスクリプトが実行される。initスクリプト、設定スクリプト、各種サービスの起動スクリプト――これらはすべて`/bin/sh`を通じて実行される。bashは機能豊富だが、その分バイナリが大きく、起動が遅い。すべてのスクリプト呼び出しでbashが起動されると、その累積的なオーバーヘッドは無視できない。

dashに切り替えたことで、Ubuntuのブートプロセスの速度が向上した。Ubuntu Wikiの記録によれば、/bin/shの変更だけでブート時間が約1秒短縮された。数値としては小さく見えるかもしれないが、「/bin/shを差し替えるだけ」でこの効果が得られたことの意味は大きい。

しかし、この変更には大きな痛みが伴った。`#!/bin/sh`で始まるスクリプトの中に、bash固有の構文（bashisms）を使っているものが多数存在したのだ。`#!/bin/sh`と書いておきながら、実際にはbashの機能に依存している。`/bin/sh`がbashだった間は問題にならなかった。だが、`/bin/sh`がdashに変わった瞬間、これらのスクリプトは壊れた。

Debian本体はUbuntuに追従し、/bin/shのdashへの変更をrelease goalとして掲げた。Debian 5.0 Lenny（2009年）では完了せず、最終的にDebian 6.0 Squeeze（2011年2月）で正式に`/bin/sh`のデフォルトがdashとなった。その過程で、Debianのバグトラッカーには「goal-dash」タグの付いたバグが大量に登録された。何百ものパッケージから、bashismsが一つずつ取り除かれていった。

この出来事は、「二つの文化」の実態を白日の下に晒した。多くのスクリプトが`#!/bin/sh`と宣言しながら、実際にはbashに依存していた。`/bin/sh`がbashであった時代には、この不整合は見えなかった。dashへの変更は、「`#!/bin/sh`はPOSIX互換シェルで動くという契約である」という事実を、エコシステム全体に突きつけたのだ。

---

## 3. 技術論――対話とスクリプティングの要件比較

### 対話的シェルの要件

対話的シェルに求められる機能は、人間の操作効率と快適性に直結する。

**コマンドライン補完**は、前回詳しく論じた。TABキーによるファイル名補完、コマンド名補完、オプション補完。zshやfishでは、サブコマンドの認識や候補の説明表示まで行われる。対話的操作の生産性を左右する最重要機能の一つだ。

**構文ハイライト**は、fishが先駆けた機能だ。入力中のコマンドが存在すれば色が付き、存在しなければ赤く表示される。Enterを押す前にエラーに気づける。zshではzsh-syntax-highlightingプラグインで同等の機能を実現できる。bashにはネイティブの構文ハイライトがない。

**ヒストリ検索**は、過去に入力したコマンドを素早く呼び出す機能だ。Ctrl-Rによるインクリメンタル検索（GNU Readline由来）は広く使われているが、zshのヒストリサブストリング検索やfishのオートサジェスチョンは、さらに進んだ形の実装だ。

**プロンプトカスタマイズ**は、作業コンテキスト（現在のディレクトリ、gitブランチ、直前のコマンドの成否、実行時間等）を視覚的に提示する機能だ。zshのPROMPT変数の柔軟性、Starship（クロスシェルプロンプト）の登場は、プロンプトが単なる装飾ではなく情報表示装置であることを示している。

**ジョブコントロール**（`Ctrl-Z`, `fg`, `bg`, `jobs`）は、cshが1970年代後半に導入し、POSIXが標準化した。対話的操作では、一つのコマンドの実行中に別の作業を行いたい場面が頻繁にある。

これらの機能に共通するのは、「人間の入力を支援する」という方向性だ。補完は入力量を減らし、ハイライトは視覚的フィードバックを提供し、ヒストリは記憶の補助をする。すべては「人間がリアルタイムで対話する」場面に最適化されている。

### スクリプティングシェルの要件

スクリプティングシェルに求められる要件は、対話的シェルとは根本的に異なる。

**ポータビリティ**が第一の要件だ。スクリプトは、書かれた環境以外でも動かなければならない。開発者のmacOSで書かれたスクリプトが、CI環境のUbuntuで動き、Docker alpineコンテナでも動く。そのためには、特定のシェルの拡張機能に依存しないことが重要だ。

**高速起動**が第二の要件だ。対話的シェルは一度起動すれば長時間動き続ける。起動に0.5秒かかっても問題にならない。しかし、ブートプロセスやCI/CDパイプラインでは、シェルスクリプトが何百回と実行される。1回の起動に10ミリ秒余計にかかれば、累積で数秒、場合によっては数十秒のオーバーヘッドになる。Debianがdashに切り替えた理由がここにある。

**予測可能な挙動**が第三の要件だ。対話的シェルでは「賢い」推測が歓迎される（例：fishのオートサジェスチョン）。スクリプティングでは「賢さ」は危険だ。スクリプトは書かれたとおりに、明確に、予測可能に動作しなければならない。「たいていの場合はうまく動く」では不十分だ。

**エラーハンドリング**が第四の要件だ。対話的操作では、コマンドが失敗したら人間が判断して次の操作を行う。スクリプティングでは、エラー時にスクリプトが自律的に適切な処理を行わなければならない。`set -euo pipefail`はbashのベストプラクティスとして定着したが、これ自体がPOSIX準拠ではない（`set -o pipefail`はPOSIX未規定）。

**POSIX準拠**が第五の要件だ。POSIX sh標準（IEEE 1003.2, 1992年制定）は、シェルの「最小公約数」を定義する。POSIX準拠のスクリプトは、POSIX準拠の任意のシェルで動作することが保証される。

```
対話的シェルの要件:         スクリプティングシェルの要件:
┌────────────────────┐     ┌────────────────────┐
│ 補完               │     │ ポータビリティ     │
│ 構文ハイライト     │     │ 高速起動           │
│ ヒストリ検索       │     │ 予測可能な挙動     │
│ プロンプトカスタマイズ │  │ エラーハンドリング │
│ ジョブコントロール │     │ POSIX準拠          │
│ オートサジェスチョン│     │ テスト可能性       │
│ テーマ/プラグイン  │     │ 最小限の依存       │
└────────────────────┘     └────────────────────┘
   ↑人間の操作効率を最大化     ↑自動実行の信頼性を最大化
```

### bashismsの実態

`#!/bin/sh`と書きながらbash固有の機能を使う――いわゆる「bashisms」は、どのようなものか。代表的なものを挙げる。

**`[[ ]]` 条件式**。POSIX shでは`[ ]`（`test`コマンド相当）のみが使える。bashの`[[ ]]`はパターンマッチングや正規表現マッチングが可能で、ワード分割が行われないため安全だ。だが、dashやash、BusyBox shでは動作しない。

```bash
# bashism: [[ ]] は POSIX shにない
if [[ "$name" == *.txt ]]; then
  echo "テキストファイル"
fi

# POSIX準拠の書き方
case "$name" in
  *.txt) echo "テキストファイル" ;;
esac
```

**配列**。bash 2.0で導入された配列（`array=(a b c)`）はPOSIX shに存在しない。連想配列（bash 4.0）も同様だ。

```bash
# bashism: 配列は POSIX shにない
files=( *.log )
echo "${files[0]}"

# POSIX準拠の代替（ポジショナルパラメータを使う）
set -- *.log
echo "$1"
```

**プロセス置換**。`<(command)`と`>(command)`はbash/zshの拡張であり、POSIX shに存在しない。

```bash
# bashism: プロセス置換は POSIX shにない
diff <(sort file1) <(sort file2)

# POSIX準拠の代替（一時ファイルを使う）
sort file1 > /tmp/sorted1
sort file2 > /tmp/sorted2
diff /tmp/sorted1 /tmp/sorted2
rm /tmp/sorted1 /tmp/sorted2
```

**`local`キーワード**。関数内ローカル変数を宣言する`local`はPOSIX shで規定されていない。ただし、dashを含む多くのシェルが`local`をサポートしており、Debian Policyでは`local`の使用を許容している。厳密なPOSIX準拠を求めるなら使えないが、実用上は広く通用する。

**`source`コマンド**。POSIX shでは`.`（ドットコマンド）を使う。`source`はbash拡張だ。

**`$'...'`（ANSI-C quoting）**。`$'\n'`のようなエスケープシーケンスを含むクォーティングはPOSIX shに存在しない。

**`{1..10}`（ブレース展開）**。数値や文字列の連番を生成するブレース展開は、bash/zshの拡張だ。

**`<<<`（ヒアストリング）**。`command <<< "string"`はbash拡張であり、POSIX shでは使えない。

これらのbashismsは、一つ一つは小さな違いに見える。だが、`/bin/sh`がdashであるシステムでこれらの構文を含むスクリプトを実行すると、即座にエラーになる。「自分の環境では動いた」が、「本番環境では壊れた」に変わる。

### /bin/sh の正体――ディストリビューションごとの違い

`/bin/sh`は、すべてのUNIX系OSに存在するパスだ。だが、その正体はシステムによって異なる。

```
ディストリビューション       /bin/sh の実体
──────────────────────       ──────────────
Debian / Ubuntu              dash (Debian Almquist Shell)
Red Hat / CentOS / Fedora    bash
FreeBSD                      ash (Almquist Shell派生)
Alpine Linux                 BusyBox ash
macOS (Catalina以降)         bash 3.2 (sh互換モード) ※
OpenBSD                      pdksh派生 (ksh)
NetBSD                       ash派生

※ macOSでは対話シェルのデフォルトがzshに変わったが、
   /bin/sh は bash 3.2（GPLv2最終版）のままである
```

この表が示すのは、`#!/bin/sh`と書いたスクリプトが「何によって実行されるか」が環境依存だということだ。bashの環境で書かれたスクリプトがbashismsを含んでいても、bash上では動く。だが、そのスクリプトをAlpine Linuxのコンテナで実行すれば、BusyBox ashが`[[ ]]`を理解できずにエラーを出す。

macOSの二重構造は特に興味深い。2019年のCatalina以降、macOSのデフォルト対話シェルはzshに変わった。だが、`/bin/sh`はbash 3.2のままだ。GPLv3を避けるためにbashのバージョンが3.2で凍結されている一方で、`/bin/sh`をzshやdashに変更するほどの理由はないと判断されているのだろう。対話シェルとシステムシェルの分離が、OS レベルで体現されている例だ。

### POSIX shの対話的機能に対する非対称な態度

POSIX sh標準（IEEE Std 1003.1）を読むと、興味深い非対称性に気づく。

POSIXはスクリプティング言語としてのシェルの構文と意味論を詳細に規定している。変数展開、パラメータ展開、コマンド置換、パイプライン、リダイレクト、制御構造――これらは厳密に定義されている。

一方、対話的機能に対するPOSIXの態度は控えめだ。ジョブコントロール（`bg`, `fg`, `jobs`）は規定されている。コマンドライン編集については、viモードのみが標準化された。emacsモードは標準化されていない。POSIXの策定過程で、Emacs陣営がフルエディタの標準化に反対し、Richard Stallman自身も標準化を見送るよう意向を示したためだ。

コマンドライン補完については、POSIXは何も規定していない。構文ハイライトも、オートサジェスチョンも、プロンプトのカスタマイズ機構も、POSIXのスコープ外だ。

この非対称性は意図的なものだ。POSIXの目的は「ポータブルなシェルスクリプトの基盤」を定義することにあり、「快適な対話的操作の基盤」を定義することにはない。スクリプティング要件は標準化できるが、対話的要件はユーザの好みに強く依存するため、標準化になじまない。

この設計判断が、「二つの文化」の制度的な裏付けとなっている。POSIX shは「スクリプティングの契約」であり、「対話の契約」ではない。対話的機能は各シェルが自由に競争する領域として残されたのだ。

---

## 4. ハンズオン――bashismsの検出とPOSIX準拠の実践

理論を理解したところで、実際に「二つの文化」の境界を体験しよう。bash依存のスクリプトをdashで実行して壊れる様子を見、checkbashismsで問題を検出し、POSIX準拠に書き換える演習を行う。

### 環境構築

Docker環境を前提とする。

```bash
docker run -it ubuntu:24.04 bash
# コンテナ内で:
apt-get update && apt-get install -y dash devscripts
```

あるいは、本記事に付属する`setup.sh`スクリプトを使えば、演習環境の構築を一括で行える。

```bash
bash setup.sh
```

### 演習1: bash依存スクリプトがdashで壊れる様子を観察する

まず、bashismsを含むスクリプトを作成し、bashとdashの両方で実行してみる。

```bash
# bash依存スクリプトを作成
cat > /tmp/bashism-demo.sh << 'SCRIPT'
#!/bin/sh
# このスクリプトは #!/bin/sh と宣言しているが、
# 実際にはbash固有の機能に依存している

echo "=== bashism デモスクリプト ==="

# bashism 1: [[ ]] 条件式
name="report.txt"
if [[ "$name" == *.txt ]]; then
    echo "1. テキストファイルを検出: $name"
fi

# bashism 2: 配列
fruits=(apple banana cherry)
echo "2. 果物の数: ${#fruits[@]}"
echo "   最初の果物: ${fruits[0]}"

# bashism 3: ブレース展開
echo "3. 連番: $(echo {1..5})"

# bashism 4: ヒアストリング
read -r line <<< "hello world"
echo "4. ヒアストリング: $line"

# bashism 5: source コマンド
echo 'MY_VAR="sourced"' > /tmp/bashism-vars.sh
source /tmp/bashism-vars.sh
echo "5. source結果: $MY_VAR"

echo "=== 完了 ==="
SCRIPT
chmod +x /tmp/bashism-demo.sh
```

bashで実行すると、すべて正常に動く。

```bash
bash /tmp/bashism-demo.sh
# → すべての出力が表示される
```

dashで実行すると、壊れる。

```bash
dash /tmp/bashism-demo.sh
# → 最初の [[ で構文エラー
# /tmp/bashism-demo.sh: 10: [[: not found
```

`#!/bin/sh`と宣言しているにもかかわらず、bashの環境でしか動かない。これが「bashisms」問題の本質だ。

### 演習2: checkbashismsで問題を検出する

Debianのdevscriptsに含まれるcheckbashismsを使えば、スクリプトからbashismsを自動検出できる。

```bash
# checkbashisms で検査
checkbashisms /tmp/bashism-demo.sh
```

出力例:

```
possible bashism in /tmp/bashism-demo.sh line 10 ([[ used):
if [[ "$name" == *.txt ]]; then
possible bashism in /tmp/bashism-demo.sh line 15 (arrays):
fruits=(apple banana cherry)
possible bashism in /tmp/bashism-demo.sh line 20 (brace expansion):
echo "3. 連番: $(echo {1..5})"
possible bashism in /tmp/bashism-demo.sh line 23 (here-string):
read -r line <<< "hello world"
possible bashism in /tmp/bashism-demo.sh line 27 (source):
source /tmp/bashism-vars.sh
```

checkbashismsは、bashismsの種類ごとに問題箇所を特定してくれる。このツールの定義する「bashism」は「POSIXが要求していないシェル機能」だ。

### 演習3: POSIX準拠に書き換える

検出されたbashismsをPOSIX準拠の構文に書き換えてみよう。

```bash
cat > /tmp/posix-demo.sh << 'SCRIPT'
#!/bin/sh
# POSIX準拠版: dashでもashでも動く

echo "=== POSIX準拠 デモスクリプト ==="

# 修正1: [[ ]] → case文
name="report.txt"
case "$name" in
    *.txt)
        echo "1. テキストファイルを検出: $name"
        ;;
esac

# 修正2: 配列 → ポジショナルパラメータ
set -- apple banana cherry
echo "2. 果物の数: $#"
echo "   最初の果物: $1"

# 修正3: ブレース展開 → seqコマンド
echo "3. 連番: $(seq 1 5 | tr '\n' ' ')"

# 修正4: ヒアストリング → パイプ
line=$(echo "hello world")
echo "4. パイプ代替: $line"

# 修正5: source → . (ドットコマンド)
echo 'MY_VAR="sourced"' > /tmp/posix-vars.sh
. /tmp/posix-vars.sh
echo "5. ドットコマンド結果: $MY_VAR"

echo "=== 完了 ==="
SCRIPT
chmod +x /tmp/posix-demo.sh
```

dashで実行して確認する。

```bash
dash /tmp/posix-demo.sh
# → すべての出力が表示される（エラーなし）
```

checkbashismsでも検査する。

```bash
checkbashisms /tmp/posix-demo.sh
# → 何も出力されない（bashismsなし）
```

同じロジックが、bashでもdashでもashでも動く。これがPOSIX準拠スクリプトの価値だ。

### 演習4: /bin/shの正体を確認する

自分の環境で`/bin/sh`が何を指しているかを確認する方法を知っておくことは重要だ。

```bash
# /bin/sh のリンク先を確認
ls -la /bin/sh
# Debian/Ubuntu: /bin/sh -> dash
# Red Hat系:     /bin/sh -> bash
# Alpine:        /bin/sh -> /bin/busybox

# 実際のシェルのバージョンを確認
/bin/sh --version 2>/dev/null || echo "バージョン情報なし（dashまたはash）"
# bash なら "GNU bash, version X.X.X..." と表示される
# dash や ash はバージョン情報を表示しない

# POSIX準拠の確認: 特殊変数 $- を使う
/bin/sh -c 'echo "シェルオプション: $-"'
```

### 演習5: dashとbashの起動速度を比較する

「二つの文化」の分離を正当化する実務上の理由の一つが起動速度だ。実際に計測してみよう。

```bash
# bash の起動速度を計測（1000回実行）
echo "=== bash 起動速度 ==="
time for i in $(seq 1 1000); do
    bash -c 'exit 0'
done

# dash の起動速度を計測（1000回実行）
echo "=== dash 起動速度 ==="
time for i in $(seq 1 1000); do
    dash -c 'exit 0'
done
```

環境によるが、dashはbashの2〜4倍速いことが多い。1000回の起動で数秒の差が出る。ブートプロセスやCI/CDパイプラインのように大量のスクリプトが呼び出される場面では、この差は無視できない。

### 演習6: ShellCheckでbashismsを検出する

checkbashismsはDebian固有のツールだが、ShellCheck（Vidar Holen, 2012年-）はより汎用的なシェルスクリプト静的解析ツールだ。ShellCheckはシェルの指定に応じて警告を変える。

```bash
# ShellCheckがインストールされている場合
apt-get install -y shellcheck

# sh として検査（POSIX準拠チェック）
shellcheck --shell=sh /tmp/bashism-demo.sh

# bash として検査（bash固有の問題を検出）
shellcheck --shell=bash /tmp/bashism-demo.sh
```

`--shell=sh`で検査すると、bash依存の構文がすべて警告される。`--shell=bash`で検査すると、bash内での問題（クォーティング漏れ等）のみが警告される。用途に応じて使い分けるとよい。

---

## 5. まとめと次回予告

### この回の要点

第一に、シェルの「二つの文化」――対話的操作に最適化されたシェルと、スクリプティングに最適化されたシェル――は、cshの成功と失敗に端を発する構造的な乖離である。cshは対話的シェルを発明したが、スクリプティング言語としては致命的な欠陥を持っていた。Tom Christiansenの"Csh Programming Considered Harmful"は、この乖離を明確に言語化した。

第二に、1980年1月にDennis Ritchieが実装したshebang（`#!`）は、スクリプトが自分のインタプリタを宣言する仕組みを提供し、対話シェルとスクリプト用シェルの技術的な分離を可能にした。`#!/bin/sh`は「このスクリプトはPOSIX互換シェルで動作する」という契約になった。

第三に、kshとbashは「対話にもスクリプティングにも使える」全部入りシェルを目指したが、bashの普及は別の問題を生んだ。多くの開発者が`#!/bin/sh`と書きながらbash固有の構文に依存する「bashisms」問題だ。

第四に、Ubuntu 6.10（2006年）とDebian 6.0 Squeeze（2011年）が`/bin/sh`をdashに変更した出来事は、bashisms問題を顕在化させた。この変更の動機は起動速度の改善であり、dashはbashの2〜4倍速い。スクリプティングシェルには高速起動とPOSIX準拠が、対話的シェルには補完やハイライトが求められる。同時最適化は困難だ。

第五に、`/bin/sh`の実体はディストリビューションによって異なる。Debian/Ubuntuではdash、Red Hat系ではbash、FreeBSDではash、Alpine LinuxではBusyBox ash、macOSではbash 3.2だ。ポータブルなスクリプトを書くには、この多様性を前提としなければならない。

### 冒頭の問いへの暫定回答

「対話に最適なシェルとスクリプティングに最適なシェルは同じものでよいのか」――この問いに対する暫定的な答えはこうだ。

同じものでよい場面もあるし、そうでない場面もある。自分のマシンで自分だけが使うスクリプトなら、`#!/bin/bash`と書いてbashの便利な機能を使えばいい。だが、他者と共有するスクリプト、CI/CDで実行されるスクリプト、コンテナ内で動くスクリプトには、ポータビリティが求められる。その場合は`#!/bin/sh`と書き、POSIX準拠を守る方が安全だ。

重要なのは、この使い分けを「意識的に」行うことだ。対話用にzshを使い、スクリプトの先頭に`#!/bin/sh`と書く。その判断の根拠を理解している人間と、何も考えずにbashを使っている人間では、問題が起きたときの対処力が決定的に異なる。

「二つの文化」を知ることは、シェルを「道具として使いこなす」ための第一歩だ。万能のシェルは存在しない。存在しないからこそ、用途に応じた選択が必要になる。

### 次回予告

ここまで第3章「BSD反乱――C shellとその遺産」を3回にわたって語ってきた。cshが対話的シェルを発明し、tcshがそれをUIにまで引き上げ、そして「二つの文化」という構造的乖離を生んだ。

次回からは第4章「標準化と統合」に入る。第10回のテーマは「Korn shell――"全部入り"への最初の挑戦」だ。

1983年、David KornがBell Labsで発表したKorn shell（ksh）は、Bourne shell互換を維持しながらcshの対話的機能を取り込み、さらに独自の言語拡張（連想配列、浮動小数点演算、コプロセス）を加えた。bashが1989年に登場する6年前に、「全部入りシェル」の理念を体現した先駆者だ。

だが、kshにはAT&Tのプロプライエタリライセンスという足枷があった。技術的には優れていたkshが、なぜbashに覇権を奪われたのか。ライセンスが技術の普及を左右するという、ソフトウェア史の教訓がそこにある。

あなたは、kshを使ったことがあるだろうか。kshのことを知っているだろうか。もし知らないなら、次回は新しい発見があるかもしれない。

---

## 参考文献

- Tom Christiansen, "Csh Programming Considered Harmful" <https://www-uxsup.csx.cam.ac.uk/misc/csh.html>
- Ubuntu Wiki, "DashAsBinSh" <https://wiki.ubuntu.com/DashAsBinSh>
- LWN.net, "A tale of two shells: bash or dash" <https://lwn.net/Articles/343924/>
- Dennis Ritchie, shebang kernel support announcement (1980) <https://www.talisman.org/~erlkonig/documents/dennis-ritchie-and-hash-bang.shtml>
- Sven Mascheck, "The #! magic, details about the shebang/hash-bang mechanism" <https://www.in-ulm.de/~mascheck/various/shebang/>
- Shebang (Unix), Wikipedia <https://en.wikipedia.org/wiki/Shebang_(Unix)>
- Debian Almquist shell, Wikipedia <https://en.wikipedia.org/wiki/Debian_Almquist_shell>
- Greg's Wiki, "Bashism" <https://mywiki.wooledge.org/Bashism>
- checkbashisms(1), Debian manpage <https://manpages.debian.org/unstable/devscripts/checkbashisms.1.en.html>
- POSIX.1-2024, Shell Command Language, The Open Group <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sh.html>
- fish design documentation <https://fishshell.com/docs/current/design.html>
- zsh FAQ: How does zsh differ from...? <https://zsh.sourceforge.io/FAQ/zshfaq02.html>
- Scripting OS X, "About bash, zsh, sh, and dash in macOS Catalina and beyond" <https://scriptingosx.com/2020/06/about-bash-zsh-sh-and-dash-in-macos-catalina-and-beyond/>
