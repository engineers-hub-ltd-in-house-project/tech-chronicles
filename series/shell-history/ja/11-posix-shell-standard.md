# 第11回：POSIXシェル標準――誰も読まない契約書

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- POSIX sh標準（IEEE 1003.2-1992）の制定経緯――6年の策定作業と委員会での衝突
- POSIXシェルがBourne shellとksh88を基盤として設計された歴史的事実
- Austin GroupによるPOSIXとSingle UNIX Specificationの統合（1998年〜）
- POSIX shで使えるもの/使えないものの具体的境界――配列、`[[`、`local`、`function`、`$'...'`
- POSIX準拠が重要になる場面――Alpine Linux、Docker、CI/CD環境
- `checkbashisms`とShellCheckによるPOSIX準拠度の検証手法
- autoconfが体現する「ポータブルシェル」の知恵

---

## 1. 導入――CI環境で壊れたスクリプト

ある日、CI環境でデプロイスクリプトが壊れた。

手元のmacOSでは動いていた。開発チームのUbuntuマシンでも問題なかった。だがCI環境のAlpine Linuxコンテナでは、スクリプトが1行目から失敗する。エラーメッセージはこうだった。

```
/bin/sh: [[: not found
```

原因はすぐにわかった。スクリプトのshebang行は`#!/bin/sh`だったが、中身はbashの構文で書かれていた。`[[ -f "$file" ]]`という条件式。macOSとUbuntuでは`/bin/sh`がbash（あるいはbashと互換性のあるシェル）にリンクされていたから、bash拡張の`[[`が動いた。だがAlpine Linuxの`/bin/sh`はBusyBox ash――POSIX準拠の最小限シェルだ。`[[`はPOSIXシェル標準に含まれていない。

私は`[[`を`[`に書き換え、`==`を`=`に直し、配列を位置パラメータに置き換え、`source`を`.`に変えた。スクリプトはようやく動いた。だが、根本的な疑問が残った。

なぜ私は`#!/bin/sh`と書いておきながら、bashの構文を使っていたのか。`/bin/sh`が何を意味するのかを、正確に理解していなかったからだ。`/bin/sh`と書いた瞬間、そのスクリプトはPOSIXシェル標準という「契約」に拘束される。だが、その契約の中身を読んだことがなかった。

あなたは、POSIXシェル標準を読んだことがあるだろうか。「POSIX準拠」という言葉は聞いたことがあっても、具体的に何が準拠で何が非準拠なのかを答えられる開発者は少ない。POSIX shとは何なのか。どこまでが「標準」で、どこからが「拡張」なのか。

この回では、その「誰も読まない契約書」の中身を読み解く。

---

## 2. 歴史的背景――標準化という困難な営み

### UNIX戦争とポータビリティの危機

1980年代、UNIXの世界は分裂していた。

AT&TのSystem V、UCBのBSD、そしてそれぞれから派生した商用UNIX――Solaris、HP-UX、AIX、IRIX、Ultrix。各OSは独自のシェル実装を持ち、独自の拡張を施していた。System VにはBourne shellがあり、BSDにはcshがあり、AT&TにはKorn shellがあった。

企業がUNIXベースのソフトウェアを開発するとき、最大の問題は「どのUNIXで動くか」だった。System V向けに書いたシェルスクリプトがBSD環境で動かない。kshの機能を使ったスクリプトがkshのない環境で壊れる。ポータビリティの欠如は、開発コストを直接的に押し上げていた。

この状況を解決するために、標準化の動きが始まった。

### IEEE 1003：POSIXの誕生

POSIXという名前は、Richard Stallmanが提案したものだ。"Portable Operating System Interface"の略にUNIXを連想させる"X"を付けた造語である。

POSIXの標準化はIEEE（Institute of Electrical and Electronics Engineers）のもとで進められた。IEEE 1003という規格番号が割り当てられ、複数のパートに分かれて策定された。

**Part 1（IEEE 1003.1）** はシステムインタフェース――C言語のAPIレベルでのOS機能の標準化だ。ファイル操作、プロセス管理、シグナル処理など。POSIX.1-1988として最初に承認された。

**Part 2（IEEE 1003.2）** はシェルとユーティリティ――シェル言語の仕様と、`grep`、`sed`、`awk`、`sort`といったコマンドラインユーティリティの仕様だ。この第11回で扱うのは、このPart 2にあたる。

### 6年の難産――IEEE P1003.2

IEEE P1003.2の策定は、1986年頃に開始された。そして承認に至るまでに6年を要し、1992年9月17日にIEEE Standards Boardにより正式に承認された。

6年。オペレーティングシステムのインタフェースを定めるPart 1（1003.1）が1988年に承認されてから、さらに4年も後だ。なぜこれほど時間がかかったのか。

O'Reillyの"Learning the Korn Shell"はこの経緯を端的に描写している。策定委員会は、既存のシェルコード――Version 7 shell、System V shell、BSD shell、Korn shellのもとで書かれたスクリプト――を可能な限り収容する設計にしなければならなかった。これらのシェル間の差異を洗い出し、妥協点を見つける作業は、気が遠くなるほど退屈で困難だったはずだ。加えて、委員メンバーには特定のシェルへのバイアスがあった。Bourne shell派、ksh派、csh派がそれぞれの立場から主張をぶつけ合う。技術的な合理性だけでは決着がつかない問題が山積していた。

結果として生まれた標準は、妥協の産物だった。だがそれは悪い意味ではない。複数の実装の「最小公約数」として、どのPOSIX準拠シェルでも動くことが保証されるスクリプトの仕様が定義されたのだ。

### POSIX shの基盤：Bourne shellとksh88

IEEE 1003.2-1992で定義されたシェル言語は、System V Bourne shellを基盤としている。これは自然な選択だった。Bourne shellは1979年のUNIX V7以来、商用UNIXの標準シェルとして広く使われてきた。既存のシェルスクリプトの多くがBourne shell互換の構文で書かれていた。

だが、POSIXシェルは純粋なBourne shellの再定義ではない。前回述べたように、ksh88がPOSIX標準の重要な基礎となった。kshが導入した機能のうち、いくつかがPOSIX標準に取り込まれている。

**`$(...)`によるコマンド置換**。Bourne shellのバッククォート`` `...` ``に代わる、ネスト可能な構文だ。Bourne shellではコマンド置換をネストするとバッククォートのエスケープが複雑になったが、`$(...)`ならば自然にネストできる。

```sh
# Bourne shell: ネストが困難
outer=`echo \`echo inner\``

# POSIX sh（ksh由来）: ネストが自然
outer=$(echo $(echo inner))
```

**算術展開`$((...))`**。kshが導入した、外部コマンド`expr`を使わずにシェル内で算術演算を行う構文だ。

**チルダ展開**。cshが発明し、kshが取り込んだ`~`によるホームディレクトリ展開も、POSIX標準に含まれている。

一方で、ksh88が持っていた多くの機能はPOSIXに取り込まれなかった。配列（ksh88の`set -A`構文）、拡張グロビング（`@()`, `+()`等）、コプロセス、`select`文、FPATH/autoload機構――これらはいずれもPOSIX標準の外にある。POSIXは「最小公約数」を目指したのであり、特定のシェルの「全機能」を標準化したのではない。

### Austin Groupと標準の統合

POSIXの歴史には、もう一つの重要な標準が絡んでくる。Single UNIX Specification（SUS）だ。

SUSはX/Open Company（1984年設立のコンソーシアム、後にThe Open Groupに統合）が策定したUNIX標準で、1994年に最初のバージョンが公開された。POSIXがIEEEの標準、SUSがThe Open Groupの標準――同じUNIXの世界に二つの標準が並立する状況は、それ自体がポータビリティの障害だった。

1998年、この問題を解決するためにAustin Group（Austin Common Standards Revision Group）が結成された。テキサス州オースティンで開催された最初の会議にちなむ命名だ。Austin GroupはThe Open Group、IEEE、ISO/IEC JTC1/SC22/WG15の3者が参加する共同技術ワーキンググループで、POSIXとSUSの統合改訂を担う。

2001年、Austin Groupの最初の主要成果としてSUSv3（Single UNIX Specification Version 3）がリリースされた。これはIEEE Std 1003.1-2001（POSIX.1-2001）と同一の文書だ。以後、POSIXとSUSは事実上同じ標準となった。シェルとユーティリティの仕様は、もはや独立したPart 2ではなく、統合された標準の一部として維持されている。

その後もAustin Groupは改訂を続け、2008年にSUSv4（POSIX.1-2008）、そして2024年6月14日にはPOSIX.1-2024（Issue 8）が公開された。POSIX.1-2024はC17言語標準との整合が図られた最新版であり、The Open GroupのサイトでHTML版が無料で閲覧・ダウンロードできる。

「誰も読まない契約書」と題したが、実は読もうと思えば誰でも読める。読まないのは、読む必要性を感じていないからだ。

---

## 3. 技術論――契約書の中身を読む

### POSIX shの境界線

POSIXシェル標準が定義する範囲を、具体的に見ていこう。ここで重要なのは、「何が含まれているか」よりも「何が含まれていないか」だ。なぜなら、含まれていない機能を`#!/bin/sh`スクリプトで使うことが、ポータビリティの問題を引き起こすからだ。

以下の表は、よく使われるシェルの機能がPOSIX標準に含まれるかどうかを整理したものだ。

```
機能                          POSIX sh   bash     ksh      zsh      dash
────────────────────────────  ────────   ────     ───      ───      ────
変数代入  VAR=value           ○          ○        ○        ○        ○
コマンド置換  $(...)          ○          ○        ○        ○        ○
算術展開  $((...))            ○          ○        ○        ○        ○
チルダ展開  ~                 ○          ○        ○        ○        ○
パラメータ展開  ${var:-def}   ○          ○        ○        ○        ○
条件式  [ ... ] / test        ○          ○        ○        ○        ○
for / while / until / if      ○          ○        ○        ○        ○
case文                        ○          ○        ○        ○        ○
関数  name() { ... }          ○          ○        ○        ○        ○
リダイレクト  > < >> 2>&1     ○          ○        ○        ○        ○
パイプ  |                     ○          ○        ○        ○        ○
ヒアドキュメント  <<EOF       ○          ○        ○        ○        ○
trap                          ○          ○        ○        ○        ○
. (source)                    ○          ○        ○        ○        ○
──── 以下はPOSIX非準拠 ────
[[ ... ]]                     ×          ○        ○        ○        ×
配列                          ×          ○        ○        ○        ×
local キーワード              ×(*)       ○        ○        ○        ○
function キーワード           ×          ○        ○        ○        ×
$'...' (ANSI-C quoting)       △(**)      ○        ○        ○        ×
source コマンド               ×          ○        ○        ○        ×
プロセス置換 <(...)           ×          ○        ○        ○        ×
=~ 正規表現マッチ             ×          ○        ×        ○        ×
|& (パイプとstderr)           ×          ○        ○        ○        ×
select文                      ×          ○        ○        ○        ×
連想配列                      ×          ○(4.0+)  ○        ○        ×
```

(\*) `local`はPOSIX標準では未定義だが、事実上ほぼ全てのPOSIX準拠シェル（dash、BusyBox ash含む）が実装している。
(\*\*) `$'...'`はPOSIX.1-2024（Issue 8）で標準に追加された。それ以前のバージョンでは非標準。

この表の「以下はPOSIX非準拠」の境界線が、実務上最も重要なラインだ。`#!/bin/sh`と書いたスクリプトでこれらの機能を使うと、dashやBusyBox ashの環境で壊れる。

### 最も危険なbashisms

実務上、POSIX非準拠で最も問題になりやすい構文を詳しく見ていく。

#### `[[ ... ]]` vs `[ ... ]`

`[[`はkshが導入し、bashとzshが採用した拡張条件式だ。POSIX標準には含まれていない。POSIXが定義するのは`[ ... ]`（`test`コマンドと等価）のみだ。

```sh
# bash拡張（POSIX非準拠）
if [[ "$str" == "hello" ]]; then
    echo "match"
fi

# POSIX準拠
if [ "$str" = "hello" ]; then
    echo "match"
fi
```

`[[`と`[`の違いは単なる構文の差ではない。`[[`はシェルのキーワードであり、内部でワード分割やグロビングが抑制される。そのため変数のクォートを省略しても安全に動作する。一方、`[`は通常のコマンド（あるいはビルトイン）であり、引数はシェルの通常の展開規則に従う。変数を適切にクォートしなければ、スペースを含むファイル名などで壊れる。

```sh
# [[ ではクォートを省略しても安全
[[ $filename == *.txt ]]

# [ ではクォートが必須
[ "$filename" = "*.txt" ]    # リテラル比較
```

この違いは、第5回で論じたクォーティングの問題に直結する。`[[`の方が安全に書けるのは事実だが、POSIX準拠を求めるなら`[`を使い、変数を適切にクォートする規律が要る。

#### 配列

POSIXシェルには配列がない。bash、ksh、zshではインデックス配列と連想配列が使えるが、POSIX shでは位置パラメータ（`$1`, `$2`, ...）が唯一の「配列的」なデータ構造だ。

```sh
# bash拡張（POSIX非準拠）
files=(report.txt notes.md data.csv)
for f in "${files[@]}"; do
    echo "$f"
done

# POSIX準拠: 位置パラメータを使う
set -- report.txt notes.md data.csv
for f in "$@"; do
    echo "$f"
done
```

位置パラメータによる代替は、一つの大きな制約を持つ。位置パラメータは一つしかない。`set --`で新しい値をセットすると、以前の値は失われる。複数の「配列」を同時に扱いたい場合、POSIXシェルだけでは極めて不便だ。

もう一つの回避策は、空白区切りの文字列とIFS（Internal Field Separator）を使う方法だ。

```sh
# POSIX準拠: IFSによる疑似配列
files="report.txt notes.md data.csv"
IFS=' '
for f in $files; do
    echo "$f"
done
```

ただし、この方法はファイル名にスペースが含まれていると壊れる。Rich's sh tricksのような知恵を駆使すれば回避は可能だが、bashの配列に比べて格段に複雑になる。

#### `local`キーワード

`local`はPOSIX標準では未定義だ。ShellCheckはSC3043というコードでこれを警告する。

```sh
# POSIX非準拠（厳密には）
myfunc() {
    local result="hello"
    echo "$result"
}

# POSIX準拠の代替（変数名にプレフィックスを付ける）
myfunc() {
    _myfunc_result="hello"
    echo "$_myfunc_result"
}
```

ただし、この問題には興味深い事情がある。`local`はPOSIX標準には含まれていないが、事実上ほぼ全てのPOSIX準拠シェルが実装している。dash、BusyBox ash、FreeBSDのsh――いずれも`local`をサポートする。現実のポータビリティ問題としては、`local`が原因で壊れるケースはほぼない。

これは「標準に書かれていないが、実質的に標準となっている」機能の例だ。標準と実装の間には、このような隙間がしばしば存在する。

#### `function`キーワード

POSIX標準が定義する関数定義の構文は`name() { ... }`だ。`function`キーワードはkshが導入した構文であり、POSIX非準拠だ。

```sh
# ksh/bash拡張（POSIX非準拠）
function greet {
    echo "hello"
}

# POSIX準拠
greet() {
    echo "hello"
}
```

dashでは`function greet { ... }`は構文エラーになる。ShellCheckはSC2113としてこれを検出する。

#### `source`コマンド

外部スクリプトを読み込む`source`コマンドは、bash/ksh/zshの拡張だ。POSIX標準で定義されているのは`.`（ドットコマンド）のみだ。

```sh
# bash拡張（POSIX非準拠）
source ./config.sh

# POSIX準拠
. ./config.sh
```

些細な違いに見えるが、Alpine LinuxのBusyBox ashでは`source`がビルトインとして存在しない場合がある。CI/CDパイプラインでAlpineベースのコンテナを使っている場合、この差異が問題になる。

### POSIXが「書かなかったもの」の意味

POSIX標準が特定の機能を含まなかった理由は、大きく三つに分類できる。

**第一に、合意に至らなかった機能**。配列は典型的だ。ksh88は`set -A`で配列をサポートしていたが、この構文はBourne shellにも他のシェルにも存在しない。配列の必要性は認識されていたが、「どの構文を標準とするか」で合意形成ができなかった。結果、POSIX shには配列が含まれていない。

**第二に、実装間の差異が大きすぎた機能**。`[[`条件式はkshとbashが異なる挙動を持つ部分があり、標準化が困難だった。`[`（testコマンド）は十分に枯れた仕様で合意しやすかった。

**第三に、特定のシェルに固有すぎた機能**。プロセス置換`<(...)`やコプロセスは、実装がkshとbashに限られており、「最小公約数」としての標準に含める根拠が薄かった。

この「書かなかったもの」のリストは、シェルスクリプトを書く者にとっての「地図」だ。POSIX shの範囲内にとどまれば、スクリプトはdashでもashでもbashでもzshでも動く。POSIX shの範囲を超えた瞬間、スクリプトは特定のシェルに依存する。

### autoconf：ポータブルシェルの知恵の集大成

POSIXシェル標準の「実用的な体現者」として、GNU Autoconfに言及しなければならない。

1991年夏、David MacKenzieはFSF（Free Software Foundation）での作業を支援するためにAutoconfの開発を開始した。Autoconfが生成する`configure`スクリプトは、POSIXシェルの上で動くポータブルなシェルコードの最も体系的な実例だ。

Autoconfの"Portable Shell"ドキュメントは、数十年にわたって蓄積されたシェル実装間の非互換性に関する知見の集大成だ。SunOS 4のシェルのバグ、HP-UXのコンパイラの挙動、IRIXの特異な仕様、AIXのリンカの癖、初期Linuxのlibc5の問題、Darwin/macOSの差異――あらゆる環境でのシェルスクリプトの落とし穴が記録されている。

`configure`スクリプトが`#!/bin/sh`で始まる理由は、最大限のポータビリティを確保するためだ。bashが存在しない環境、kshが存在しない環境、あるいは`/bin/sh`が古いBourne shellを指す環境――そのいずれでも動かなければならない。Autoconfはそのために、POSIX shの範囲内にとどまるだけでなく、POSIX以前のシェルとの互換性すら考慮したコードを生成する。

この営みは、POSIX shの重要性を雄弁に物語っている。ポータブルなシェルスクリプトを書きたければ、POSIX shの範囲を知る必要がある。Autoconfの開発者たちは、その範囲を30年以上にわたって精密に探索し続けてきた。

### /bin/shの正体

`/bin/sh`が何を指すかは、OSとディストリビューションによって異なる。この事実は、POSIX準拠の問題を理解する上で極めて重要だ。

```
OS / ディストリビューション        /bin/sh の実体
──────────────────────────────    ────────────────
Debian 6+ / Ubuntu 6.10+         dash
Alpine Linux                      BusyBox ash
FreeBSD                           FreeBSD sh（ash派生）
OpenBSD                           pdksh派生
macOS (現行)                      zsh
macOS (〜Mojave)                  bash 3.2
Solaris (旧)                      Bourne shell / ksh
多くのLinuxディストリビューション  bash
```

この表が示すのは、`#!/bin/sh`と書いたスクリプトが実行されるシェルは、環境によってまったく異なるということだ。手元のマシンでは`/bin/sh`がbashかもしれないが、CIサーバではdashかもしれない。Dockerコンテナの中ではBusyBox ashかもしれない。

第9回で触れたDebianの決断は、この文脈で改めて重要性を持つ。Ubuntu 6.10（2006年）がデフォルトの`/bin/sh`をbashからdashに変更した。その主な動機は起動速度の改善だった。当時、起動プロセスの高速化はUpstart（新しいinitシステム）の功績とされがちだったが、実際にはdash移行の貢献が大きかったことが後に明らかになった。dashはbashより小さく、起動が高速だ。`/bin/sh`経由で大量のスクリプトが実行されるブートプロセスにおいて、シェルの起動速度の差は顕著な効果をもたらした。

Debianの公式な`/bin/sh`変更は2011年のDebian 6（Squeeze）だが、Ubuntuが先行して2006年に移行を実施したことで、bash依存スクリプトの問題が広く認識されるようになった。

このdash移行は、POSIX準拠の実践的な意味を突きつけた事件だった。`/bin/sh`がbashを指す世界では、bashismsはバグではなく「たまたま動くコード」だった。`/bin/sh`がdashを指す世界になった瞬間、bashismsは実際にスクリプトを壊すバグになった。

### Alpine Linux：コンテナ時代のPOSIX準拠

2010年代以降、Alpine Linuxの台頭がPOSIX準拠の重要性をさらに高めた。

Alpine Linuxはmusl libcとBusyBoxを基盤とした軽量Linuxディストリビューションだ。Dockerイメージのサイズが5MB未満と極めて小さく、コンテナ環境で広く採用されている。Alpine Linuxの`/bin/sh`はBusyBox ash――POSIX準拠の最小限シェルだ。bashは標準では含まれていない。

DockerのベースイメージとしてAlpineを選択した瞬間、そのコンテナ内で動くシェルスクリプトはPOSIX準拠を求められる。あるいは、明示的に`apk add bash`してbashをインストールし、shebangを`#!/bin/bash`に変えるかだ。後者はイメージサイズを増大させ、Alpine Linuxを選んだ意味を減じる。

GitHub ActionsやGitLab CIのランナーにおいても、シェルスクリプトの実行環境は必ずしもbashではない。`run:`ステップがどのシェルで実行されるかは、ランナーの構成に依存する。POSIX準拠のスクリプトであれば、ランナーのシェルが何であっても動く。

---

## 4. ハンズオン――POSIX準拠を体で覚える

理論だけではPOSIX準拠は身につかない。実際にbashismsが壊れる様子を体験し、POSIX準拠のコードに書き換える演習を行う。

### 環境構築

Docker環境を前提とする。Alpine Linux（BusyBox ash）とDebian（dash/bash）の両方を使い分ける。

```bash
docker run -it alpine:3.21 /bin/sh
# コンテナ内で:
apk add bash
```

あるいは、本記事に付属する`setup.sh`スクリプトを使えば、演習環境の構築を一括で行える。

```bash
bash setup.sh
```

### 演習1: bashismsが壊れる瞬間を体験する

まず、典型的なbashismを含むスクリプトをdash/ashで実行し、どのように壊れるかを体験する。

```sh
# bashisms_demo.sh を作成
cat << 'SCRIPT' > /tmp/bashisms_demo.sh
#!/bin/sh
# このスクリプトは /bin/sh を宣言しているが、bashisms を含む

# bashism 1: [[ ]]
if [[ -f /etc/passwd ]]; then
    echo "passwd found"
fi

# bashism 2: 配列
files=(one.txt two.txt three.txt)
echo "Count: ${#files[@]}"

# bashism 3: function キーワード
function greet {
    echo "hello"
}
greet

# bashism 4: source
echo 'echo sourced' > /tmp/helper.sh
source /tmp/helper.sh

# bashism 5: == in test
if [ "$USER" == "root" ]; then
    echo "root user"
fi
SCRIPT
chmod +x /tmp/bashisms_demo.sh
```

bashで実行すると、このスクリプトは正常に動作する。

```bash
bash /tmp/bashisms_demo.sh
# → passwd found
# → Count: 3
# → hello
# → sourced
# → root user（rootの場合）
```

dashまたはBusyBox ashで実行するとどうなるか。

```sh
# Alpine Linux の場合
/bin/sh /tmp/bashisms_demo.sh
# → /tmp/bashisms_demo.sh: line 5: [[: not found
# → /tmp/bashisms_demo.sh: line 9: syntax error: unexpected "("
# （以降のエラーは最初のエラーで中断される場合もある）
```

この体験が重要だ。`#!/bin/sh`と書いたスクリプトがbashでは動くのに、dashやashでは壊れる。原因はすべて、POSIX非準拠の構文を使っていることにある。

### 演習2: bashismsをPOSIX準拠に書き換える

壊れたスクリプトを一つずつPOSIX準拠に修正する。

```sh
cat << 'SCRIPT' > /tmp/posix_demo.sh
#!/bin/sh
# POSIX準拠版

# 修正1: [[ ]] → [ ]
if [ -f /etc/passwd ]; then
    echo "passwd found"
fi

# 修正2: 配列 → 位置パラメータ
set -- one.txt two.txt three.txt
echo "Count: $#"

# 修正3: function キーワード → name() 構文
greet() {
    echo "hello"
}
greet

# 修正4: source → .（ドットコマンド）
echo 'echo sourced' > /tmp/helper.sh
. /tmp/helper.sh

# 修正5: == → =
if [ "$USER" = "root" ]; then
    echo "root user"
fi
SCRIPT
chmod +x /tmp/posix_demo.sh
```

このスクリプトはbash、dash、BusyBox ash、いずれでも動く。

```sh
# Alpine Linux (BusyBox ash) で実行
/bin/sh /tmp/posix_demo.sh
# → passwd found
# → Count: 3
# → hello
# → sourced
# → root user（rootの場合）
```

### 演習3: checkbashismsで自動検出する

Debianのdevscriptsパッケージに含まれる`checkbashisms`は、`/bin/sh`スクリプトからbash固有の構文を検出するツールだ。

```sh
# Debianベースの環境で
apt-get update && apt-get install -y devscripts

# bashismsを含むスクリプトをチェック
checkbashisms /tmp/bashisms_demo.sh
```

出力例:

```
possible bashism in /tmp/bashisms_demo.sh line 5 ([[ used):
if [[ -f /etc/passwd ]]; then
possible bashism in /tmp/bashisms_demo.sh line 9 (arrays):
files=(one.txt two.txt three.txt)
possible bashism in /tmp/bashisms_demo.sh line 13 (function keyword):
function greet {
possible bashism in /tmp/bashisms_demo.sh line 19 (source):
source /tmp/helper.sh
possible bashism in /tmp/bashisms_demo.sh line 22 (== in test):
if [ "$USER" == "root" ]; then
```

`checkbashisms`はlintianシステム（Debianパッケージの品質検査ツール）のチェックの一つに基づいている。DebianがUbuntuに先駆けてdash移行を推進する過程で、既存スクリプトのbashisms検出が必要とされ、このツールが発展した。

### 演習4: ShellCheckでPOSIX準拠度を検証する

ShellCheck（第5回で紹介）の`--shell=sh`オプションは、POSIX sh準拠の観点からスクリプトを静的解析する。

```sh
# ShellCheckのインストール（Alpineの場合）
apk add shellcheck

# あるいはDebianの場合
# apt-get install -y shellcheck

# POSIX sh としてチェック
shellcheck --shell=sh /tmp/bashisms_demo.sh
```

ShellCheckの出力は`checkbashisms`よりも詳細で、修正方法の提案も含まれる。

```
In /tmp/bashisms_demo.sh line 5:
if [[ -f /etc/passwd ]]; then
   ^-- SC3010 (warning): In POSIX sh, [[ ]] is undefined.
                          Use [ ] instead.

In /tmp/bashisms_demo.sh line 9:
files=(one.txt two.txt three.txt)
      ^-- SC3030 (warning): In POSIX sh, arrays are undefined.

In /tmp/bashisms_demo.sh line 13:
function greet {
^-- SC2113 (warning): Use foo() { ... } instead of
                      function foo { ... }.
```

`checkbashisms`とShellCheckは目的が異なる。`checkbashisms`はbashismsの検出に特化したヒューリスティックベースのツールで、高速だが検出漏れがある。ShellCheckはシェルスクリプトの包括的な静的解析ツールで、bashisms以外のバグ（クォート漏れ、未定義変数など）も検出する。両方を使い分けるのが実務上の最善策だ。

### 演習5: 実践的なPOSIX準拠スクリプトの書き換え

最後に、現実的なユースケース――簡易デプロイスクリプトを、bash依存版とPOSIX準拠版の両方で書く。

```sh
# bash依存版（POSIX非準拠）
cat << 'SCRIPT' > /tmp/deploy_bash.sh
#!/bin/bash
set -euo pipefail

TARGETS=(web01 web02 web03)
DEPLOY_DIR="/var/www/app"
LOG_FILE="/tmp/deploy_$(date +%Y%m%d_%H%M%S).log"

function log {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" | tee -a "$LOG_FILE"
}

function deploy_to {
    local target=$1
    log "Deploying to ${target}..."

    if [[ -z "$target" ]]; then
        log "ERROR: target is empty"
        return 1
    fi

    # シミュレーション
    log "  rsync to ${target}:${DEPLOY_DIR}"
    log "  Restarting service on ${target}"
    log "  Deploy to ${target} completed"
}

log "=== Deploy started ==="
log "Targets: ${TARGETS[*]}"

for target in "${TARGETS[@]}"; do
    deploy_to "$target"
done

log "=== Deploy finished ==="
echo "Log: $LOG_FILE"
SCRIPT
chmod +x /tmp/deploy_bash.sh
```

```sh
# POSIX準拠版
cat << 'SCRIPT' > /tmp/deploy_posix.sh
#!/bin/sh
set -eu

TARGETS="web01 web02 web03"
DEPLOY_DIR="/var/www/app"
LOG_FILE="/tmp/deploy_$(date +%Y%m%d_%H%M%S).log"

log() {
    _log_timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${_log_timestamp}] $*" | tee -a "$LOG_FILE"
}

deploy_to() {
    _deploy_target=$1
    log "Deploying to ${_deploy_target}..."

    if [ -z "$_deploy_target" ]; then
        log "ERROR: target is empty"
        return 1
    fi

    # シミュレーション
    log "  rsync to ${_deploy_target}:${DEPLOY_DIR}"
    log "  Restarting service on ${_deploy_target}"
    log "  Deploy to ${_deploy_target} completed"
}

log "=== Deploy started ==="
log "Targets: ${TARGETS}"

for target in $TARGETS; do
    deploy_to "$target"
done

log "=== Deploy finished ==="
echo "Log: $LOG_FILE"
SCRIPT
chmod +x /tmp/deploy_posix.sh
```

両方のスクリプトを実行して比較する。

```sh
# bash依存版（bashでのみ動く）
bash /tmp/deploy_bash.sh

# POSIX準拠版（どのシェルでも動く）
/bin/sh /tmp/deploy_posix.sh
```

注目すべき書き換えポイントを整理する。

第一に、`set -euo pipefail`から`set -eu`への変更。`pipefail`はPOSIX非準拠だ。パイプ内のコマンドのエラーを検出したい場合、POSIX準拠の範囲では一時ファイルやサブシェルの終了ステータスを手動でチェックする必要がある。

第二に、配列から空白区切り文字列への変更。`TARGETS=(web01 web02 web03)`が`TARGETS="web01 web02 web03"`になり、`"${TARGETS[@]}"`が`$TARGETS`（意図的にクォートしない）になる。これは要素にスペースが含まれない前提でのみ安全だ。

第三に、`function`キーワードから`name()`構文への変更。

第四に、`local`から変数名プレフィックスへの変更。`local target=$1`が`_deploy_target=$1`になる。関数名をプレフィックスにつけることで、名前衝突を避ける。これは不格好だが、POSIX標準の範囲で変数のスコープを制御する現実的な方法だ。

POSIX準拠版はbash依存版に比べて冗長で、エレガントさに欠ける。これは事実だ。だが、このスクリプトはAlpine Linuxでも、FreeBSDでも、どのPOSIX準拠シェルでも動く。ポータビリティの代償として、ある程度の冗長さを受け入れるかどうかは、プロジェクトの要件次第だ。

---

## 5. まとめと次回予告

### この回の要点

第一に、POSIXシェル標準（IEEE 1003.2-1992）は6年の策定作業を経て1992年9月17日に承認された。System V Bourne shellを基盤とし、kshの一部機能（`$(...)`構文、算術展開、チルダ展開等）を取り込んだ「最小公約数」としての標準だ。

第二に、1998年にThe Open Group、IEEE、ISO/IECの3者がAustin Groupを結成し、POSIXとSingle UNIX Specificationの統合改訂を開始した。2001年のSUSv3以後、両者は事実上同一の標準となっている。最新版は2024年6月公開のPOSIX.1-2024（Issue 8）だ。

第三に、POSIX shの「境界線」を知ることが、ポータブルなスクリプトを書く上で不可欠だ。`[[`、配列、`function`キーワード、`source`コマンド、プロセス置換――これらはいずれもPOSIX標準の外にある。`#!/bin/sh`と書いたスクリプトでこれらを使えば、dash/ashの環境で壊れる。

第四に、`/bin/sh`が何を指すかはOSとディストリビューションによって異なる。Debian/Ubuntuではdash、Alpine LinuxではBusyBox ash、macOSではzsh。この事実は、POSIX準拠の問題が理論上の問題ではなく、実務上の問題であることを示している。

第五に、`checkbashisms`（Debianのdevscripts）とShellCheck（`--shell=sh`オプション）は、POSIX準拠度を検証する実用的なツールだ。前者はbashisms検出に特化し、後者は包括的な静的解析を提供する。

### 冒頭の問いへの暫定回答

「POSIX sh準拠とは何を意味するのか？ そしてなぜ、ほとんどの開発者がそれを知らないのか」――この問いに対する暫定的な答えはこうだ。

POSIX sh準拠とは、IEEE 1003.2で定義されたシェル言語仕様の範囲内にとどまることだ。それは「bashの機能をすべて使うこと」ではなく、「どのPOSIX準拠シェルでも動くことを保証すること」だ。

なぜ多くの開発者がこれを知らないのか。それは、`/bin/sh`がbashを指す環境が長らく多数派だったからだ。bashが`/bin/sh`である世界では、bashismsはバグではなく「たまたま動くコード」だった。Debian/Ubuntuのdash移行やAlpine Linuxの台頭が、その「たまたま」を壊し始めた。

POSIX shは「最小公約数」であり「最大公約数」ではない。この契約書は、ポータビリティの最低ラインを定義しているに過ぎない。だが、この最低ラインを知らなければ、ポータブルなスクリプトを意図して書くことはできない。

### 次回予告

今回「最小公約数」として語ったPOSIX shには、その思想を純粋に体現する実装が存在する。次回のテーマは「ash/dash――POSIX原理主義と単純さの速度」だ。

Kenneth Almquistが1989年に開発したash（Almquist shell）と、そのDebian派生であるdash。機能を削ぎ落とすことで得られる速度と軽量さ。BusyBox ashとAlpine Linuxのエコシステム。Debianが`/bin/sh`をdashに変更した2006年の決断の技術的根拠。

「機能を削ぎ落とすことは、技術的にどのような価値を生むのか」――次回は、その問いに向き合う。

bashの対極にあるシェルを知ることで、POSIX sh標準の「契約書」が求める最小限が、いかに実用的であるかが見えてくるはずだ。

---

## 参考文献

- IEEE Std 1003.2-1992, "IEEE Standard for Information Technology--Portable Operating System Interfaces (POSIX)--Part 2: Shell and Utilities" <https://standards.ieee.org/ieee/1003.2/1408/>
- IEEE Std 1003.1-2024 (POSIX.1-2024), The Open Group Base Specifications, Issue 8 <https://pubs.opengroup.org/onlinepubs/9799919799.2024edition/mindex.html>
- O'Reilly, "Learning the Korn Shell", Appendix A.2: The IEEE 1003.2 POSIX Shell Standard <http://www.cs.ait.ac.th/~on/O/oreilly/unix/ksh/appa_02.htm>
- O'Reilly, "Learning the bash Shell", Appendix A.2 <https://www.oreilly.com/library/view/learning-the-bash/1565923472/apas02.html>
- Austin Group, Wikipedia <https://en.wikipedia.org/wiki/Austin_Group>
- Single UNIX Specification, Wikipedia <https://en.wikipedia.org/wiki/Single_UNIX_Specification>
- POSIX, Wikipedia <https://en.wikipedia.org/wiki/POSIX>
- Ubuntu Wiki, "DashAsBinSh" <https://wiki.ubuntu.com/DashAsBinSh>
- LWN.net, "A tale of two shells: bash or dash" <https://lwn.net/Articles/343924/>
- Alpine Linux Wiki, "Shell management" <https://wiki.alpinelinux.org/wiki/Shell_management>
- GNU Autoconf Manual, "Portable Shell" <https://www.gnu.org/software/autoconf/manual/autoconf-2.64/html_node/Portable-Shell.html>
- Autoconf, Wikipedia <https://en.wikipedia.org/wiki/Autoconf>
- ShellCheck Wiki, SC2039: In POSIX sh, something is undefined <https://www.shellcheck.net/wiki/SC2039>
- ShellCheck Wiki, SC3043: In POSIX sh, local is undefined <https://www.shellcheck.net/wiki/SC3043>
- ShellCheck Wiki, SC2113: function keyword is non-standard <https://www.shellcheck.net/wiki/SC2113>
- Greg's Wiki, "Bashism" <https://mywiki.wooledge.org/Bashism>
- Debian Manpages, checkbashisms(1) <https://manpages.debian.org/testing/devscripts/checkbashisms.1.en.html>
- Rich's sh (POSIX shell) tricks <http://www.etalabs.net/sh_tricks.html>
- BashFAQ/031: What is the difference between test, [ and [[ ? <https://mywiki.wooledge.org/BashFAQ/031>
