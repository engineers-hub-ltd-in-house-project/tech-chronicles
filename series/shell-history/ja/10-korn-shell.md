# 第10回：Korn shell――"全部入り"への最初の挑戦

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- Korn shellが誕生した背景――Bourne shellとcshの二極化を統合しようとした野心
- David Kornの設計思想と、Mike Veach/Pat Sullivanによるコマンドライン編集の統合
- ksh88がPOSIXシェル標準（IEEE Std 1003.2-1992）の基礎となった歴史的事実
- ksh88からksh93への進化――連想配列、浮動小数点演算、複合変数、discipline関数
- AT&Tのプロプライエタリライセンスがkshの普及を阻んだ構造的要因
- pdksh、mksh、ksh93u+mへと続くコミュニティ主導のフォークの系譜
- kshがbashに与えた直接的影響――拡張グロビング、算術展開、FPATH/autoload

---

## 1. 導入――商用UNIXの現場で出会ったもう一つのシェル

2000年代前半、私はある企業のサーバ管理を請け負っていた。

納品されたSolarisのマシンにログインすると、プロンプトが`$`で始まる。見慣れたbashのプロンプトに似ているが、何かが違う。`echo $0`と打つと、返ってきたのは`ksh`だった。

当時の私にとって、シェルとはbashのことだった。自分のLinuxマシンではbashを使い、スクリプトも`#!/bin/bash`で書いていた。cshやtcshは大学のBSD環境で触ったことがあったが、kshは名前しか知らなかった。

しかし、商用UNIXの世界ではkshが標準だった。Solaris、HP-UX、AIX――これらのOSにログインすると、そこにいるのはbashではなくkshだ。スクリプトのshebang行は`#!/bin/ksh`で、管理用スクリプトはkshの構文で書かれている。

最初は戸惑った。`print`コマンド（bashでは`echo`を使う場面でkshは`print`を持つ）、`typeset`による変数の型宣言、`select`文によるメニュー生成。見慣れない構文がところどころに現れる。だが、Bourne shell互換の部分は問題なく動く。bashで書いたスクリプトのほとんどがksh上でもそのまま動いた。

しばらく使っているうちに気づいた。kshは「bashの古い版」ではない。むしろ、bashがkshから多くの機能を借用しているのだ。算術展開`$((...))`も、拡張グロビングも、コマンドライン編集のviモード/emacsモードも、kshが先に実装した機能だった。

そして、ksh88とksh93の微妙な差異に何度か足をすくわれた。あるシステムではksh88が動き、別のシステムではksh93が動いている。同じ`ksh`という名前でありながら、連想配列が使えたり使えなかったりする。同じ`function`キーワードでも、スコープの挙動が異なる。バージョンの違いが見えない場所で挙動を変えるのは、実務上の地雷だった。

あなたは、kshを使ったことがあるだろうか。bashしか知らない世代のエンジニアにとって、kshは「過去のシェル」に見えるかもしれない。だが、kshの歴史を知ることは、bashの設計を理解することにほかならない。bashが持つ機能の多くは、kshで先に実現されたものだからだ。

この回では、Korn shellの誕生から現在までの歴史を辿る。Bourne shellとcshの二極化を統合しようとした野心、AT&Tのライセンス政策がもたらした悲劇、そしてkshがPOSIX標準やbashに残した遺産について語りたい。

---

## 2. 歴史的背景――二極化への回答

### Bell Labsの問題意識

1980年代初頭のBell Labsでは、シェルの二極化が日常的な不便として認識されていた。

前回まで語ってきたように、対話的機能ではcsh/tcshが優れ、スクリプティングではBourne shellが堅実だった。Bell Labsの開発者たちも、対話にはcshを使い、スクリプトにはBourne shellを使うという使い分けを強いられていた。二つの異なる構文体系を頭の中で切り替える認知コスト。cshの対話的便利さを享受するために、Bourne shell互換のスクリプティング能力を犠牲にする不条理。

David Kornは1976年にBell Labsのテクニカルスタッフとなった人物だ。KornがKorn shellの開発を始めた動機は、自分自身と同僚が直面していたこの問題を解決することにあった。当時最も使われていたBourne shellとC shellの両方に対する不満――Bourne shellの対話機能の貧弱さと、cshのスクリプティング能力の欠陥――を一つのシェルで解決しようとしたのだ。

Kornの設計方針は明確だった。Bourne shellとの後方互換性を維持しつつ、cshの対話的機能を取り込み、さらに独自の言語拡張を加える。「全部入り」のシェルだ。

### 1983年7月14日――USENIXでの発表

1983年7月14日、David KornはトロントのUSENIXカンファレンスでKorn shellを発表した。"KSH - A Shell Programming Language"と題されたこの発表は、UNIXシェルの歴史における一つの分水嶺だった。

kshは、Bourne shellのソースコードをベースに開発された。これは意図的な選択だ。ゼロからシェルを書くのではなく、Bourne shellの上に機能を積み上げる。こうすることで、既存のBourne shellスクリプトとの完全な後方互換性を保証できる。

kshが最初に注目を集めた機能の一つが、コマンドライン編集だ。ここには興味深い経緯がある。

Bell Labsの開発者Mike Veachは、Bourne shellにemacsスタイルのコマンドライン編集機能を独自に実装していた。同じくBell Labsの開発者Pat Sullivanは、viスタイルのコマンドライン編集を独自にBourne shellに組み込んでいた。両者はそれぞれ独立に作業していたのだ。

VeachのいたチームもSullivanのいたチームも、kshを使う条件として「自分たちのコマンドライン編集モードが使えること」を要求した。Kornは当初、コマンドライン編集をシェルに組み込むことに消極的だった。端末ドライバ側で実現されるべき機能だと考えていたのだ。しかし、端末ドライバへの統合が近い将来には実現しそうにないことが明らかになり、Kornは両方のモードをkshに統合する判断を下した。

こうしてkshは、emacsモードとviモード、二つのコマンドライン編集モードを備えた最初のシェルとなった。第8回で述べたように、tcshは1983年にKen Greerのコード（1975年の補完実装に由来）をベースにコマンドライン補完を実装したが、kshが提供したのは補完とは異なる、コマンドラインの「編集」だ。入力中のコマンドを自在にカーソル移動し、修正し、ヒストリから呼び出して再編集できる。viに慣れた開発者はviモードを、Emacsに慣れた開発者はemacsモードを選べる。

1984年、KornはBell Labs Fellowに選出された。kshの評価がいかに高かったかを示す事実だ。

### cshの対話的機能の取り込み

kshはcshの対話的機能を積極的に取り込んだ。

**ヒストリ機能**。cshが導入した`!`コマンドによるヒストリ展開をkshも採用した。ただし、kshのヒストリはcshよりも洗練されていた。kshでは`fc`（fix command）コマンドが導入され、過去のコマンドをエディタで開いて編集し、再実行できるようになった。`fc -l`でヒストリを一覧し、`fc -e vi`でviで編集して再実行する。コマンドライン編集と組み合わせることで、cshの`!`展開よりも柔軟なヒストリ操作が可能になった。

**エイリアス**。cshの`alias`機能をkshも実装した。よく使うコマンドに短縮名を付ける機能だ。

**ジョブコントロール**。cshが発明した`fg`, `bg`, `Ctrl-Z`によるジョブ制御もkshに統合された。

**チルダ展開**。cshが導入した`~`によるホームディレクトリ展開も取り込まれた。

これらの機能により、kshはBourne shell互換でありながらcshと同等の対話的快適さを提供できるシェルとなった。cshの構文を覚える必要なく、Bourne shell系の構文のままで対話的機能を使える。これがkshの最大の売りだった。

### ksh88――POSIX標準の基礎

kshは継続的に改良され、1988年版のksh（通称ksh88）がSystem V Release 4（SVR4）に採用された。これは決定的に重要な出来事だった。

SVR4はAT&TとSun Microsystemsの協力で開発されたUNIXの統合版だ。System VとBSD系の機能を統合したこのOSが、ksh88をシステムシェルの一つとして搭載したことで、kshは商用UNIX全体に浸透した。Solaris、HP-UX、AIX――主要な商用UNIXがkshを標準シェルとして提供するようになった。

さらに重要なことに、ksh88はIEEE Std 1003.2-1992（POSIXシェル標準）の基礎文書となった。POSIXのShell and Utilities仕様は、Bourne shellとksh88の機能を土台として策定されたのだ。算術展開`$((...))`、コマンド置換`$(...)`（バッククォート`\`に代わる形式）、拡張``test`コマンドの構文――これらはkshが導入し、POSIXが標準化した機能だ。

このことの意味を正確に理解してほしい。今日、あなたが`#!/bin/sh`と書いたスクリプトで使っている`$((...))` 構文は、kshが発明した機能をPOSIXが標準化したものだ。bashが実装している多くの「POSIX準拠」機能は、kshが先に設計した機能なのである。kshはPOSIXの「基礎」であり、bashはPOSIXの「実装者」だ。

### ksh93――言語としての飛躍

1993年、kshは大幅な改訂を受け、ksh93として生まれ変わった。ksh88が「Bourne shellに対話機能を足したシェル」だとすれば、ksh93は「シェルの枠を超えたプログラミング言語」への飛躍を目指した。

ksh93で追加された主要な機能を見てみよう。

**連想配列**。キーと値のペアを格納するデータ構造だ。bashが連想配列をサポートしたのはbash 4.0（2009年）だが、ksh93は1993年の時点で実装していた。16年先行していたことになる。

**浮動小数点演算**。ksh93は倍精度浮動小数点演算をネイティブにサポートした。C言語の数学ライブラリ関数（sin, cos, exp, log等）にシェルから直接アクセスできる。bashには今なお浮動小数点演算がない（整数演算のみ）。

**複合変数**（compound variables）。C言語の構造体に相当するデータ構造だ。ドット（`.`）をセパレータとした階層的な変数名前空間を実現する。

```ksh
# ksh93の複合変数
typeset -C server
server.name="web01"
server.port=8080
server.status="running"
echo "${server.name}:${server.port} is ${server.status}"
```

**discipline関数**。変数の参照や代入にフック関数を結びつける仕組みだ。変数が参照されたとき（`get`）、代入されたとき（`set`）、追加されたとき（`append`）に自動的にカスタム関数が呼び出される。オブジェクト指向言語のgetter/setterに近い概念をシェルに持ち込んだ。

```ksh
# ksh93のdiscipline関数
function count.set {
    echo "countが ${.sh.value} に変更されました"
}
count=0    # → "countが 0 に変更されました"
count=42   # → "countが 42 に変更されました"
```

**名前空間**（namespace）。変数や関数の名前衝突を防ぐスコーピング機構だ。大規模なスクリプトで異なるモジュールが同じ変数名を使っても干渉しない。

**名前参照変数**（nameref）。他の変数への参照を保持する変数だ。C言語のポインタに近い概念だ。bashが`nameref`を導入したのはbash 4.3（2014年）で、やはりksh93が先行していた。

```ksh
# ksh93の名前参照
typeset -n ref=original_var
original_var="hello"
echo "$ref"    # → hello
ref="world"
echo "$original_var"    # → world
```

これらの機能を見ると、ksh93が単なる「シェル」の改良にとどまらず、本格的なプログラミング言語への進化を志向していたことがわかる。複合変数とdiscipline関数は、事実上オブジェクト指向的なプログラミングをシェルスクリプトで可能にする。名前空間は大規模スクリプトのモジュール化を支援する。これらは2020年代の今でも、bashには実装されていない機能だ。

だが、ksh93の野心は、その普及を阻んだ構造的な問題と無縁ではなかった。

### AT&Tのライセンス政策――技術的優位の無力

ここからが、kshの歴史で最も教訓的な部分だ。

kshはAT&Tのプロプライエタリソフトウェアだった。AT&TのSystem Vライセンスを持つ組織だけが、kshのバイナリを合法的に利用できた。ソースコードは非公開。自由に配布することはできない。

1980年代から1990年代、GNUプロジェクトは「自由なUNIX」の実現を目指してシステムのあらゆるコンポーネントをフリーソフトウェアとして再実装していた。シェルも例外ではない。1988年、Brian FoxがFSF（Free Software Foundation）のためにbashの開発を開始した。bashはGPLのもとで自由に配布できる。誰でもソースコードを読み、修正し、再配布できる。

1991年、Linus TorvaldsがLinuxカーネルを公開した。Linuxディストリビューションが次々と登場し、フリーソフトウェアのシェルが必要とされた。kshはプロプライエタリだから使えない。bashはGPLで自由だから使える。結果は明白だった。

Linuxディストリビューションはbashをデフォルトシェルとして採用した。Linuxが普及するにつれて、bashが「世界で最も使われるシェル」の座を獲得していった。技術的にはkshが先行していた機能の多くが、bashに「再実装」される形で広まった。

kshの側にも動きはあった。2000年3月1日、AT&TはついにkshのソースコードをAT&T独自ライセンスのもとで公開した。だが、このライセンスには制約があった。変更はパッチの形でのみ配布可能で、ソースコードの自由な改変・再配布はできなかった。真の「オープンソース」とは言い難い条件だ。

2005年初頭、ksh93qリリースでEclipse Public License（EPL）に切り替えられ、ようやく広義のOSSライセンスとなった。だが、時すでに遅し。bashはLinuxとともに世界を席巻しており、kshが覇権を取り戻す余地はなかった。

ここに、ソフトウェア史の重要な教訓がある。技術的優位は、ライセンス政策の前に無力になり得る。kshは1983年から一貫してbashに先行する機能を実装し続けた。連想配列も、浮動小数点演算も、複合変数も、discipline関数も、名前空間も。だが、それらの機能にアクセスできるのはAT&Tのライセンスを持つ組織だけだった。bashは技術的にkshの後追いだったが、GPLの自由さがLinuxの普及と結びつき、kshが手にできなかった覇権を勝ち取った。

### pdkshとmksh――コミュニティの回答

AT&Tのkshが手に入らないことへの不満から、フリーなksh互換シェルが開発された。

Public Domain Korn Shell（pdksh）は、1980年代半ばにPublic Domain Bourne Shellとして始まったプロジェクトにksh88互換の機能拡張が加えられたものだ。名前の通りパブリックドメインとして公開され、AT&Tのライセンスに縛られずに使える。pdkshはkshの全機能を実装していたわけではないが、多くの環境でkshの代替として利用された。OpenBSDは長年pdkshをデフォルトシェルとして採用していた。pdkshの開発は1999年に停止した。

pdkshの後を継いだのがmksh（MirBSD Korn Shell）だ。2002年頃、MirBSDプロジェクトの一部としてmkshの開発が始まった。OpenBSDが2003年頃に行ったpdkshのクリーンアップ作業を取り込み、他のOSへのポータビリティを追加した。mkshは現在も活発に開発されており、pdksh派生で唯一メンテナンスが続いているシェルだ。

mkshが注目される理由の一つは、Androidのデフォルトシェルとして採用されていることだ。世界中のAndroid端末にmkshが搭載されている。この事実から、「最大のユーザベースを持つKorn shell派生」とも評される。

### ksh93u+mの現在

ksh93本体にも紆余曲折があった。

2017年、AT&TのAST（Advanced Software Technology）プロジェクトはksh93にフォーカスすると宣言した。Red Hatが顧客要望に応じてkshの開発に参加し、2019年秋にksh2020がリリースされた。だが、ksh2020は既存スクリプトとの互換性問題やパフォーマンス低下を引き起こし、深刻な批判を受けた。

2020年3月、AT&Tはksh2020の変更をロールバックし、ブランチに退避させた。ksh2020は「リリースはされたが、AT&Tによって一度もメンテナンスされなかった」という異例の状況に陥った。

これを受けて、2020年5月にコミュニティ主導でksh93u+m（最後の安定版であるksh93u+ 2012-08-01をベースにしたフォーク）のリポジトリが作成された。ksh93u+mは現在もバグ修正と改善が続けられており、ksh93の事実上の正統後継だ。

kshの歴史は、一つのシェルが辿り得る最も波乱に満ちた軌跡の一つだ。Bell Labsの天才的な設計から始まり、プロプライエタリライセンスで普及を阻まれ、コミュニティフォークで命脈を保ち、企業主導の改修が失敗し、再びコミュニティに帰ってきた。

---

## 3. 技術論――kshの言語設計とbashへの影響

### kshの言語拡張の全体像

kshが導入した言語拡張を、bashとの対比で体系的に整理する。

```
機能                    ksh88   ksh93   bash    POSIX sh
──────────────────────  ─────   ─────   ─────   ────────
コマンドライン編集
  (vi/emacs)            1983    ○       1989+   vi のみ
算術展開 $((...))       ○       ○       ○       ○
コマンド置換 $(...)     ○       ○       ○       ○
チルダ展開              ○       ○       ○       ○
エイリアス              ○       ○       ○       ○
関数                    ○       ○       ○       ○
ジョブコントロール      ○       ○       ○       ○
配列                    ○       ○       2.0     ×
連想配列                ×       ○       4.0     ×
拡張グロビング          ○       ○       extglob ×
コプロセス              ○       ○       4.0     ×
select文                ○       ○       ○       ×
FPATH/autoload          ○       ○       ×       ×
浮動小数点演算          ×       ○       ×       ×
複合変数                ×       ○       ×       ×
discipline関数          ×       ○       ×       ×
名前空間                ×       ○       ×       ×
名前参照 (nameref)      ×       ○       4.3     ×
print コマンド          ○       ○       ×       ×
```

この表から読み取れることは三つある。

第一に、ksh88はPOSIXシェル標準のスーパーセットだ。POSIXが標準化した機能のほとんどすべてをksh88がカバーしており、さらにPOSIXには含まれない機能（配列、拡張グロビング、コプロセス、select文、FPATH/autoload）も持つ。ksh88がPOSIX標準の基礎文書となったのは、このカバー範囲の広さゆえだ。

第二に、bashはkshの機能を段階的に取り込んできた。配列はbash 2.0（1996年）で、連想配列はbash 4.0（2009年）で、名前参照はbash 4.3（2014年）で導入された。いずれもkshが先行して実装していた機能だ。

第三に、ksh93の独自機能（浮動小数点演算、複合変数、discipline関数、名前空間）は、bashに取り込まれていない。ksh93はシェルの言語設計において、bashが追いついていない領域を今なお持っている。

### 算術展開とkshの遺産

今日、ほとんどのシェルスクリプトで使われている算術展開`$((...))`の歴史を正確に知っている人は少ない。

Bourne shellには算術演算の組み込み機能がなかった。整数演算を行うには外部コマンドの`expr`を使う必要があった。

```sh
# Bourne shell時代: exprによる算術演算
result=$(expr 3 + 5)
echo "$result"    # → 8
```

`expr`は外部プロセスを起動するため遅い。また、演算子をシェルのメタキャラクタから保護するためにエスケープが必要な場合がある（`expr 3 \* 5`のように`*`をエスケープする）。

kshはこの問題を、算術展開`$((...))`の導入で解決した。シェルのビルトインとして算術演算を行うため、外部プロセスのオーバーヘッドがない。C言語に近い演算子構文を使えるため、直感的だ。

```ksh
# kshの算術展開
result=$((3 + 5))
echo "$result"    # → 8

# C言語風の演算子がすべて使える
a=10
echo $(( a * 3 ))        # → 30
echo $(( a > 5 ? 1 : 0 ))  # → 1（三項演算子）
echo $(( a <<= 2 ))      # → 40（ビットシフト代入）
```

この`$((...))`構文はkshからPOSIXシェル標準に取り込まれ、bash、dash、zsh、ash――POSIX準拠のすべてのシェルが実装するに至った。日常的に使っているこの構文が、kshに端を発するものだと知る人は多くない。

ksh93はさらに踏み込んで、浮動小数点演算をネイティブにサポートした。

```ksh
# ksh93の浮動小数点演算
typeset -F pi=3.14159265358979
echo $(( pi * 2 ))       # → 6.28318530717959

# C数学ライブラリ関数
echo $(( sin(pi / 6) ))  # → 0.5
echo $(( sqrt(2) ))      # → 1.41421356237310
echo $(( exp(1) ))       # → 2.71828182845905
```

bashでは浮動小数点演算ができない。`bc`や`awk`などの外部ツールに頼るしかない。ksh93は1993年の時点で、シェル内で完結する浮動小数点演算を提供していた。

### 拡張グロビング

ファイル名のパターンマッチング（グロビング）において、kshは標準のワイルドカード（`*`, `?`, `[...]`）に加えて、拡張グロビングパターンを導入した。

```
パターン          意味                            例
──────────        ────                            ──
?(pattern)        0回または1回の一致              ?(*.txt|*.md)
*(pattern)        0回以上の一致                   *(.[ch])
+(pattern)        1回以上の一致                   +(*.log)
@(pattern)        ちょうど1回の一致               @(yes|no)
!(pattern)        パターンに一致しないもの        !(*.bak)
```

bashはこの拡張グロビングをksh93から借用し、`shopt -s extglob`で有効化できるオプションとして実装した。デフォルトでは無効であるため、bashで拡張グロビングを使うには明示的に有効化する必要がある。kshではデフォルトで使える。

```bash
# bashで拡張グロビングを有効化
shopt -s extglob

# ksh由来の拡張グロビング
ls !(*.bak|*.tmp)     # .bak と .tmp 以外のファイルを表示
ls @(*.txt|*.md)      # .txt または .md のファイルを表示
```

### コプロセス

コプロセスは、バックグラウンドプロセスとの双方向通信を可能にする機能だ。パイプは一方向だが、コプロセスは読み書きの両方ができる。

ksh88は`|&`演算子でコプロセスを起動し、`read -p`で読み込み、`print -p`で書き込む。

```ksh
# ksh のコプロセス
bc |&                          # bcをコプロセスとして起動
print -p "scale=10; 4*a(1)"   # コプロセスに式を送信
read -p pi                     # コプロセスから結果を読み取る
echo "pi = $pi"               # → pi = 3.1415926535
```

bashが同等の機能を導入したのはbash 4.0（2009年）で、`coproc`キーワードという異なる構文を採用した。kshのコプロセスとbashのcoprocは、同じ概念を異なるインタフェースで提供している。

### FPATH/autoload――関数の遅延読み込み

kshのFPATH/autoload機構は、あまり知られていないが洗練された機能だ。

PATHが実行可能ファイルの検索パスを定義するように、FPATHは関数定義ファイルの検索パスを定義する。`autoload`（`typeset -fu`のエイリアス）で関数名を宣言すると、その関数が実際に呼び出されたときにFPATHのディレクトリから関数定義を読み込む。

```ksh
# kshのFPATH/autoload
export FPATH=~/ksh-functions:/usr/local/lib/ksh

# 関数を「遅延読み込み」として宣言
autoload json_parse
autoload log_rotate
autoload backup_db

# json_parseが実際に呼ばれたとき、FPATHから定義が読み込まれる
json_parse < data.json
```

この機構の利点は二つある。第一に、シェルの起動時にすべての関数定義を読み込む必要がないため、起動が速い。第二に、関数をファイル単位で管理できるため、大規模なスクリプト群の整理が容易になる。

bashにはFPATH/autoloadに相当する標準機能がない。zshはkshから借用してFPATH/autoload機構を実装しており、zshのプラグインシステムの基盤となっている。

### ksh88とksh93の互換性の罠

kshを実務で使った人間が必ず直面するのが、ksh88とksh93の互換性問題だ。同じ「ksh」という名前でありながら、挙動が異なる箇所がある。

最も注意が必要なのは関数のスコープだ。

```ksh
# ksh88: function キーワードでも () 形式でも動的スコープ
function greet {
    name="hello"
}

# ksh93: function キーワード → 静的スコープ（ローカル変数が使える）
#        () 形式           → POSIXと互換（動的スコープ）
function greet {
    typeset name="hello"   # name は greet のローカル変数
}
greet() {
    typeset name="hello"   # name はグローバルに影響する
}
```

ksh93では`function`キーワードで定義した関数と`name()`形式で定義した関数で、変数のスコーピングルールが異なる。ksh88ではこの区別がなかった。「同じスクリプトがksh88では動くがksh93で変数の値がおかしくなる」という現象が起きうる。

ビルトインコマンドの検索順序も変わった。ksh88ではビルトインコマンドが常にPATHに優先していたが、ksh93ではPATH上に同名のコマンドがあれば、PATHの方が優先される場合がある。これは意図的な設計変更だが、ksh88前提のスクリプトが予期せぬ挙動を示す原因になった。

商用UNIXの世界では、同じ組織内でもシステムによってksh88が動いていたりksh93が動いていたりする。スクリプトのポータビリティを考えるなら、ksh88/ksh93の差異を把握しておく必要がある。

---

## 4. ハンズオン――ksh（mksh）で体感するkshの世界

理論を理解したところで、実際にksh（mksh）を触ってみよう。kshの機能をbashとの比較で体験し、「bashの多くの機能がどこから来たのか」を体感する。

### 環境構築

Docker環境を前提とする。

```bash
docker run -it ubuntu:24.04 bash
# コンテナ内で:
apt-get update && apt-get install -y mksh bc
```

あるいは、本記事に付属する`setup.sh`スクリプトを使えば、演習環境の構築を一括で行える。

```bash
bash setup.sh
```

### 演習1: kshのコマンドライン編集を体験する

mkshはkshのコマンドライン編集機能を実装している。デフォルトでemacsモードが有効だ。

```bash
# mkshを起動
mksh

# emacsモードを確認
set -o | grep emacs
# → emacs           on

# viモードに切り替え
set -o vi

# viモードでの操作:
# ESC で命令モードへ
# i で挿入モードへ
# k で前のヒストリ
# j で次のヒストリ
# / で後方検索

# emacsモードに戻す
set -o emacs

# emacsモードでの操作:
# Ctrl-P で前のヒストリ
# Ctrl-N で次のヒストリ
# Ctrl-R でインクリメンタル検索
# Ctrl-A で行頭へ
# Ctrl-E で行末へ
```

kshが1983年に導入したこの二つのモードは、bashにも受け継がれている。bashの`set -o vi`と`set -o emacs`は、kshから借用した機能だ。

### 演習2: kshの算術展開とbashの比較

```bash
# mksh内で算術展開を試す
mksh -c '
echo "=== 算術展開 ==="

# 基本演算
echo "3 + 5 = $(( 3 + 5 ))"
echo "10 * 3 = $(( 10 * 3 ))"

# C言語風の演算子
a=10
echo "a++ = $(( a++ )), a = $a"   # 後置インクリメント
echo "++a = $(( ++a )), a = $a"   # 前置インクリメント

# ビット演算
echo "0xFF & 0x0F = $(( 0xFF & 0x0F ))"  # → 15
echo "1 << 4 = $(( 1 << 4 ))"            # → 16

# 三項演算子
x=42
echo "x > 30 ? \"big\" : \"small\" → $(( x > 30 ? 1 : 0 )) (1=big)"

echo ""
echo "これらの演算子はkshが最初に導入し、POSIXとbashに継承された"
'
```

### 演習3: 拡張グロビングの比較

```bash
# テスト用ファイルを作成
mksh -c '
mkdir -p /tmp/ksh-glob-test && cd /tmp/ksh-glob-test
touch report.txt notes.md backup.bak data.csv temp.tmp log.txt

echo "=== ksh（mksh）の拡張グロビング ==="
echo "全ファイル:"
echo *

# @(pattern): ちょうど1つに一致
echo ""
echo ".txt または .md ファイル: @(*.txt|*.md)"
echo @(*.txt|*.md)

# !(pattern): 一致しないもの
echo ""
echo ".bak と .tmp 以外: !(*.bak|*.tmp)"
echo !(*.bak|*.tmp)

# +(pattern): 1回以上の一致
echo ""
echo "少なくとも1つの拡張子に一致: +(*.txt|*.csv)"
echo +(*.txt|*.csv)

echo ""
echo "bashでは shopt -s extglob が必要。kshではデフォルトで有効"
rm -rf /tmp/ksh-glob-test
'
```

### 演習4: kshのselect文

`select`文は、対話的なメニュー選択を簡潔に記述するためのksh独自の構文だ。bashもこの機能をkshから借用している。

```bash
mksh -c '
echo "=== select文によるメニュー ==="
PS3="シェルを選んでください: "
select shell in bash zsh ksh fish dash 終了; do
    case "$shell" in
        bash)  echo "→ GNUの標準シェル。1989年〜" ;;
        zsh)   echo "→ 最大主義のシェル。1990年〜" ;;
        ksh)   echo "→ 本日の主役。1983年〜" ;;
        fish)  echo "→ POSIX非互換の挑戦者。2005年〜" ;;
        dash)  echo "→ POSIX原理主義。高速起動" ;;
        終了)  echo "終了"; break ;;
        *)     echo "→ 無効な選択: $REPLY" ;;
    esac
done
' < /dev/tty
```

`select`はPOSIX shには含まれていないが、kshが導入しbashが取り込んだことで、広く使われるようになった。

### 演習5: コプロセスの動作確認

kshのコプロセスを実際に動かしてみよう。

```bash
mksh -c '
echo "=== コプロセスの実演 ==="

# bcをコプロセスとして起動
bc |&

# コプロセスに計算式を送信し、結果を読み取る
print -p "scale=10; 4*a(1)"
read -p pi
echo "pi = $pi"

print -p "scale=5; s(3.14159/6)"
read -p sin30
echo "sin(30°) = $sin30"

print -p "2^10"
read -p result
echo "2^10 = $result"

# コプロセスを終了
print -p "quit"

echo ""
echo "bashでは coproc キーワード（bash 4.0+）で同等の機能を使えるが、"
echo "kshは1988年からこの機能を持っていた"
'
```

### 演習6: bashとkshの機能差異を確認する

同じタスクをbashとmkshの両方で実行し、構文と挙動の差異を確認する。

```bash
echo "=== bash vs mksh 比較 ==="

echo ""
echo "--- print コマンド ---"
echo "[bash] echoを使う: "
bash -c 'echo "hello\tworld"'       # \t は展開されない（bash のecho）
echo "[mksh] printを使う: "
mksh -c 'print "hello\tworld"'      # \t がタブとして展開される
echo "[mksh] print -r（rawモード）: "
mksh -c 'print -r "hello\tworld"'   # \t は展開されない

echo ""
echo "--- typeset による整数型宣言 ---"
echo "[mksh]:"
mksh -c '
typeset -i num
num="3+5"
echo "typeset -i num; num=\"3+5\" → $num"   # → 8（文字列が算術式として評価される）
'
echo "[bash]:"
bash -c '
declare -i num
num="3+5"
echo "declare -i num; num=\"3+5\" → $num"   # → 8（bashもtypeset/declareで同様）
'

echo ""
echo "--- whence vs type ---"
echo "[mksh] whence -v ls:"
mksh -c 'whence -v ls'
echo "[bash] type ls:"
bash -c 'type ls'
```

`print`コマンドはksh固有の機能で、bashには存在しない。bashの`echo`はオプションや環境によって挙動が変わるが、kshの`print`はより予測可能な挙動を提供する。`whence`コマンドもksh固有で、bashでは`type`が対応する。

---

## 5. まとめと次回予告

### この回の要点

第一に、Korn shell（ksh）は1983年にDavid KornがBell Labsで開発した「全部入り」のシェルだ。Bourne shellとの後方互換性を維持しつつ、cshの対話的機能（ヒストリ、エイリアス、ジョブコントロール）を取り込み、さらにコマンドライン編集（emacsモード/viモード）を最初に実装した。Pat Sullivanがviモードを、Mike Veachがemacsモードを開発し、Kornがkshに統合した。

第二に、ksh88はPOSIXシェル標準（IEEE Std 1003.2-1992）の基礎となった。今日のPOSIX準拠シェルが実装する算術展開`$((...))`やコマンド置換`$(...)`は、kshが先に設計した機能をPOSIXが標準化したものだ。kshはPOSIXの「基礎」であり、bashはPOSIXの「実装者」にすぎない。

第三に、ksh93は連想配列、浮動小数点演算、複合変数、discipline関数、名前空間といった先進的な機能を持ち、シェルの枠を超えたプログラミング言語を志向した。これらの機能の多くは、今日のbashにも実装されていない。

第四に、AT&Tのプロプライエタリライセンスがkshの普及を決定的に阻んだ。技術的にはbashに先行していたkshだが、Linuxの普及期にフリーソフトウェアとして利用できなかったことで、覇権をbashに奪われた。ソースコード公開は2000年、本格的なOSSライセンス採用は2005年。いずれも、bashがLinuxとともに世界を席巻した後だった。

第五に、kshの遺産はpdksh、mksh、ksh93u+mというコミュニティフォークによって受け継がれている。mkshはAndroidのデフォルトシェルとして世界中の端末に搭載されている。ksh93u+mは現在もバグ修正が続けられているksh93の正統後継だ。

### 冒頭の問いへの暫定回答

「Bourne shellの互換性を保ちつつ、cshの対話機能を取り込む。この野心は実現したのか」――この問いに対する暫定的な答えはこうだ。

技術的には、kshは「全部入り」の野心を高い水準で実現した。Bourne shell互換を維持し、cshの対話的機能を取り込み、コマンドライン編集を初めて実装し、POSIXシェル標準の基礎となった。ksh93ではさらに先進的な言語機能を実装し、2020年代のbashすらも到達していない領域を切り拓いた。

しかし、「実現した」と言い切るのは正確ではない。kshが実現したのは「技術」であり、「普及」ではなかった。技術がいかに優れていても、ユーザの手に届かなければ「実現した」とは言えない。AT&Tのライセンス政策は、kshの技術的成果をAT&Tのライセンスを持つ組織だけに閉じ込めた。

この歴史は、技術者にとって重要な教訓を含んでいる。「良い技術が勝つ」とは限らない。技術の普及は、ライセンス、タイミング、エコシステム、コミュニティといった技術以外の要因に大きく左右される。kshの物語は、その最も明瞭な事例の一つだ。

### 次回予告

kshがPOSIXシェル標準の基礎となった事実は、次回のテーマへの直接的な橋渡しとなる。第11回のテーマは「POSIXシェル標準――誰も読まない契約書」だ。

POSIX sh標準とは何か。1992年に制定されたIEEE Std 1003.2は、シェルの「最小公約数」として何を定義し、何を定義しなかったのか。そしてなぜ、ほとんどの開発者がその内容を知らないのか。

第9回で触れたように、bashismsの問題はPOSIX sh標準への無知に根ざしている。`[[ ]]`がPOSIX非準拠であること、`local`がPOSIX未定義であること、配列がPOSIX shに存在しないこと――これらを知らないまま`#!/bin/sh`と書くスクリプトは、潜在的な時限爆弾だ。

次回は、その「誰も読まない契約書」の中身を読み解く。Alpine Linuxのash、DebianのdashがPOSIX準拠の最小限シェルとして機能している理由が、そこに書かれている。

あなたは、POSIXシェル標準を読んだことがあるだろうか。読んだことがないなら、次回はその入口に立つ機会になるはずだ。

---

## 参考文献

- David G. Korn, "KSH - A Shell Programming Language", USENIX Conference Proceedings, Summer 1983, Toronto
- David G. Korn, "ksh - An Extensible High Level Language", Proceedings of the USENIX 1994 Very High Level Languages Symposium <https://www.oilshell.org/archive/ksh-usenix.pdf>
- KornShell, Wikipedia <https://en.wikipedia.org/wiki/KornShell>
- David Korn's personal page <http://www.kornshell.com/~dgk/>
- KSH-93 FAQ <http://www.kornshell.com/doc/faq.html>
- KSH-93 - The KornShell Command and Programming Language <http://www.kornshell.com/doc/ksh93.html>
- AT&T's Korn Shell Source Code Released, Slashdot (2000-03-04) <https://tech.slashdot.org/story/00/03/04/1437214/atts-korn-shell-source-code-released>
- MirBSD Korn Shell (mksh) <http://www.mirbsd.org/mksh.htm>
- mksh FAQ <http://www.mirbsd.org/mksh-faq.htm>
- ksh93u+m: KornShell lives! <https://github.com/ksh93/ksh>
- Greg's Wiki, "KornShell" <https://mywiki.wooledge.org/KornShell>
- "Learning the Korn Shell", O'Reilly, Appendix: The IEEE 1003.2 POSIX Shell Standard <https://docstore.mik.ua/orelly/unix3/korn/appa_03.htm>
- IBM AIX Documentation, "Enhanced Korn shell (ksh93)" <https://www.ibm.com/docs/en/aix/7.2.0?topic=shell-enhanced-korn-ksh93>
