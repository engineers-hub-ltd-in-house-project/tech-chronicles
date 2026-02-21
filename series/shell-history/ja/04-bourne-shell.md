# 第4回：Bourne shell――シェルがプログラミング言語になった日

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- Stephen BourneがALGOL 68の経験をシェルに持ち込んだ経緯
- Bourne shell（1979年、UNIX V7）が導入した言語機能の全体像
- 変数展開、ワード分割、グロビングという「処理パイプライン」の設計
- `fi`、`esac`、`done`というALGOL 68由来の構文が生まれた理由
- シェルが「コマンドインタプリタ」から「プログラミング言語」へ変貌した意味

---

## 1. 導入――最初のシェルスクリプト

私が初めて書いたシェルスクリプトのことを、今でも覚えている。

2000年代前半、サーバ管理を始めて間もない頃だった。毎日、数十台のサーバのログファイルを確認し、エラーを含む行を手作業で探していた。`grep ERROR /var/log/syslog`を何十回も打つ日々に嫌気がさし、ある日、こう書いた。

```sh
for f in /var/log/*.log; do
  grep ERROR "$f"
done
```

この3行が動いた瞬間の感動は、今でも鮮明だ。手作業で何十分もかかっていた仕事が、一瞬で終わる。`for`ループ、ワイルドカード展開、変数の参照――これらが組み合わさって、反復作業を自動化する。シェルは「コマンドを打つ場所」であるだけでなく、「プログラムを書く場所」でもあったのだ。

だが、その直後に私は3時間を無駄にした。

ファイル名にスペースを含むログファイルが1つだけ存在していた。`"$f"`のダブルクォートを外した瞬間、スクリプトは壊れた。`/var/log/error report.log`というファイル名が、`/var/log/error`と`report.log`という2つの引数に分割され、`grep`はどちらのファイルも見つけられなかった。

当時の私は、この現象を「バグ」だと思った。シェルのバグだと。だが後に理解する。これはバグではなく設計だ。1976年から1979年にかけて、Stephen BourneがBourne shellを設計したとき、変数展開の後にワード分割とグロビングが走るという処理パイプラインを意図的に選んだ。この設計判断は、当時のUNIXの哲学と整合していた。問題は、その設計判断が47年後の今も生き続けていることだ。

シェルは「コマンドを打つ場所」なのか、「プログラミング言語」なのか。この問いは、Bourne shellから始まる。Thompson shellは「コマンドインタプリタ」だった。名前付き変数も、制御構造も、関数もなかった。Bourne shellがそれらすべてを内蔵し、シェルを「プログラミング言語」に変えた。だがその言語設計には、47年後の私たちをなお苦しめる原罪が潜んでいた。

あなたの`.bashrc`や`.zshrc`に書かれているスクリプトは、すべてBourne shellの遺産の上に成り立っている。その遺産がどのようにして生まれたのか。今回はその物語を語る。

---

## 2. 歴史的背景――ALGOL 68プログラマが書いたシェル

### Stephen Bourne――Cambridge大学からBell Labsへ

Bourne shellの設計を理解するには、その作者の経歴を知る必要がある。

Stephen Richard Bourne（1944年1月7日生まれ）はイギリスの計算機科学者だ。King's College Londonで数学の学士号を取得した後、Cambridge大学Trinity Collegeでコンピュータサイエンスのディプロマと数学の博士号を取得した。

Cambridge大学計算機研究所での彼の仕事が、後のシェル設計を決定づける。BourneはMichael Guyと共にALGOL 68Cコンパイラの開発に従事した。ALGOL 68Cは、CAMAL（Cambridge Algebra System）という代数処理システムのために開発されたALGOL 68の方言だ。このコンパイラは、自分自身の言語で書かれた最初のコンパイラの一つだった。BourneはALGOL 68の改訂委員会にも参加しており、この言語の設計思想を深く内面化していた。

このALGOL 68の経験が、後にBourne shellの構文設計に直接的な影響を与えることになる。

Cambridge大学を離れた後、BourneはBell LabsのUNIX V7チームに合流し、9年間在籍した。彼がBourne shellの開発を始めたのは1976年のことだ。

### Thompson shellの限界とBourne shellの動機

前回述べたように、Thompson shellは「コマンドインタプリタ」としては十分だったが、「プログラミング言語」としては根本的に不足していた。名前付き変数がなく、制御構造はシェルの外部コマンドとして実装されており、関数定義もできなかった。

1975年に登場したMashey shell（PWB shell）がThompson shellに制御構造と単純な変数を追加したが、その拡張はThompson shellの上に建て増しされたものであり、根本的な限界を克服するには至らなかった。

Bourne shellは、Thompson shellやMashey shellの漸進的な改良ではなかった。一から書き直された新しいシェルだ。Mashey shellの機能の同等物を含みつつも、設計思想は根本的に異なっていた。このことを示す逸話がある。Bell Labs内部では、移行を支援するために「Mashey shellプログラマのためのBourne shellプログラミング」という講座が一時期開かれていたという。講座が必要なほど、二つのシェルは異なっていたのだ。

### UNIX V7と1978年の論文

Bourne shellは1979年のUNIX V7でリリースされた。V7はUNIXの歴史における重要なマイルストーンであり、大学や研究機関に広く配布された版だ。Bourne shellはこのV7のデフォルトシェルとなり、実行ファイル名はThompson shellと同じ`sh`が使われた。

論文の発表はリリースの1年前だった。1978年、BourneはBell System Technical Journalに"The UNIX Shell"と題した論文を発表した（Vol. 57, No. 6, Part 2, pp.1971-1990）。この論文でBourneはシェルを「コマンドプログラミング言語」と位置づけ、「アルゴリズム記述言語に見られるいくつかの機構を提供するインタフェース」と定義した。

「コマンドプログラミング言語」という表現に注目してほしい。Thompson shellは「コマンドインタプリタ」だった。Bourneはそこに「プログラミング言語」の性質を明示的に付け加えた。これは単なるレトリックではなく、設計思想の根本的な転換を表している。

### Bourneの最後の追加――関数

Bourneは1983年まで継続的にシェルの開発を続けた。彼の最後の追加機能は関数定義だった。Bourne自身は、関数をもっと早く追加すべきだったと後に振り返っている。関数は公式にはAT&TのSystem V Release 2（SVR2, 1984年）で組み込まれ、SVR2では`unset`や`echo`のビルトイン化、ビルトインコマンドのリダイレクトサポートも追加された。

1983年をもってBourneはシェルの開発を区切りとした。これ以上の機能追加は、シェルの単純さと優雅さを損なうと判断したのだ。この判断には、ALGOL 68の設計哲学——言語の一貫性と整合性を重視する姿勢——が反映されているように私には思える。

---

## 3. 技術論――Bourne shellの言語設計

### 「すべては文字列」の世界

Bourne shellの言語設計を一言で表すなら、「すべては文字列」だ。

整数型も、浮動小数点型も、配列型も、構造体もない。変数の値は常に文字列であり、算術演算すら組み込みでは行えない（`expr`コマンドを外部で呼ぶ必要があった）。コマンドの引数は文字列であり、パイプで流れるデータも行区切りの文字列だ。

この設計は、Thompson shellの「すべてはテキスト」という暗黙の前提を、プログラミング言語の次元に持ち込んだものだ。ALGOL 68のような型付き言語を熟知していたBourneが、なぜ型なしの言語を設計したのか。答えはシェルの役割にある。シェルは他のプログラムを起動し、組み合わせるための「糊（glue）」だ。プログラム間のインタフェースはテキストストリームであり、そのテキストを加工する言語もまた、テキストを基本単位とするのが自然だった。

だが「すべては文字列」の設計は、後に深刻な問題を引き起こす。ワード分割とグロビングという処理が、変数展開のたびに暗黙的に走るからだ。この処理パイプラインについては後で詳しく述べる。

### Bourne shellが導入した言語機能

Bourne shellが導入した主要な機能を、Thompson shellとの対比で整理しよう。

```
Bourne shell（V7, 1979年）が追加した主要機能:

  Thompson shell にあった機能           Bourne shell で追加された機能
  ─────────────────────────────         ─────────────────────────────────
  コマンド実行（fork/exec）            名前付き変数（NAME=value）
  入出力リダイレクト（>, <）           位置パラメータ（$1, $2, ..., $9）
  パイプ（|）                          特殊変数（$?, $#, $0, $!, $$）
  逐次実行（;）                        制御構造（if/then/fi, for/do/done,
  バックグラウンド実行（&）              while/do/done, case/in/esac,
  グロビング（外部→内蔵化）              until/do/done）
                                       関数定義（SVR2で追加）
                                       ヒアドキュメント（<<）
                                       コマンド置換（`command`）
                                       環境変数（export）
                                       trapによるシグナルハンドリング
                                       サブシェル（(commands)）
                                       fd 2> によるエラー出力の分離
```

一つずつ、重要なものを見ていこう。

### 変数――名前と値の束縛

Thompson shellには名前付き変数がなかった。Bourne shellは`NAME=value`の構文で変数代入を導入した。

```sh
# 変数代入（= の前後にスペースを入れてはならない）
DIR=/var/log
COUNT=0
```

位置パラメータ（`$1`, `$2`, ... `$9`）はスクリプトに渡された引数を参照する。特殊変数はシェルの状態を示す。

```
特殊変数:
  $?  直前のコマンドの終了ステータス
  $#  位置パラメータの個数
  $0  スクリプト自身の名前
  $!  直前のバックグラウンドプロセスのPID
  $$  現在のシェルのPID
  $*  すべての位置パラメータ（1つの文字列として）
  $@  すべての位置パラメータ（個別の文字列として）
```

`$*`と`$@`の区別は、後のエピソードで詳しく扱うクォーティング問題の核心に関わる。ここでは「二つが異なる」という事実だけを記憶しておいてほしい。

### 制御構造――ALGOL 68の影

Bourne shellの制御構造の構文は、一目見て「何かが違う」と感じるだろう。

```sh
# 条件分岐
if condition; then
  commands
elif condition; then
  commands
else
  commands
fi

# ケース分岐
case word in
  pattern1) commands ;;
  pattern2) commands ;;
  *) commands ;;
esac

# ループ
for name in word1 word2 word3; do
  commands
done

while condition; do
  commands
done

until condition; do
  commands
done
```

`fi`は`if`を逆さにしたもの。`esac`は`case`を逆さにしたもの。`done`はループの終端を示す。C言語であれば中括弧`{}`で済む話だ。なぜこのような独特の構文になったのか。

答えはStephen BourneのALGOL 68の経験にある。ALGOL 68では、条件分岐は`if ~ then ~ elif ~ then ~ else ~ fi`、ケース分岐は`case ~ in ~ esac`、ループは`for/while ~ do ~ od`と記述する。Bourne shellの構文は、このALGOL 68のクロージング・トークン（閉じトークン）をほぼそのまま借用している。

ただし一つだけ変更がある。ALGOL 68のループ終端は`od`だが、Bourne shellでは`done`になった。理由は実用的なものだ。`od`はUNIXにおいてバイナリファイルを8進数で表示するコマンド（octal dump）として既に存在していた。キーワードとコマンド名の衝突を避けるため、`od`は`done`に置き換えられた。

このALGOL 68の影響は、シェルの構文だけにとどまらなかった。Bourne shellのCソースコード自体が、ALGOL 68風のプリプロセッサマクロで書かれていた。`/usr/src/cmd/sh/mac.h`には次のようなマクロが定義されていた。

```c
/* Bourne shellソースコードのALGOL 68風マクロ（mac.h） */
#define IF    if(
#define THEN  ){
#define ELSE  } else {
#define ELIF  } else if (
#define FI    ;}
#define BEGIN {
#define END   }
#define WHILE while(
#define DO    ){
#define OD    ;}
#define FOR   for
#define REP   do{
#define PER   }while(
#define DONE  ;)
#define LOOP  for(;;){
#define POOL  }
#define SWITCH switch(
#define IN    ){
#define ENDSW }
```

これにより、Bourne shellのCソースコードは次のように書かれていた。

```c
IF (n=to-from)<=1 THEN return FI
FOR j=1; j<=n; j*=2 DONE
```

C言語を知っている者が読むと面食らうが、ALGOL 68を知っている者には自然に読める。Russ Coxが自身のブログで分析しているように、このマクロ群はコンパイル結果に一切影響しない純粋なスタイル変換だ。だがBourneの頭の中では、CコードはALGOL 68のプログラムとして読み書きされていたのである。

このマクロは後世にも影響を残した。Bourne shellのソースコードとUNIX 4.2BSDのfingerコマンドが、International Obfuscated C Code Contest（IOCCC、国際難読Cコード大会）誕生のインスピレーションの一つになったとされている。

### ヒアドキュメント――スクリプト内のテキスト埋め込み

ヒアドキュメントはBourne shellが導入した機能の一つだ。`<<`に続く区切り文字（delimiter）で囲まれた複数行のテキストを、コマンドの標準入力として渡す。

```sh
cat << EOF
これは複数行の
テキストブロックである。
変数展開も行われる: $HOME
EOF
```

前回のThompson shellの解説で、Thompson shellには変数もヒアドキュメントもなかったことを確認した。Thompson shellでは、スクリプトにテキストを埋め込む手段がなかった。Bourne shellのヒアドキュメントは、シェルスクリプトをより自己完結的にした。設定ファイルの生成、メール本文の作成、一時的なデータの注入――これらがスクリプト内で完結するようになった。

### コマンド置換――プログラムの出力を埋め込む

バッククォート（`` ` ``）によるコマンド置換は、Bourne shellが導入したもう一つの強力な機能だ。

```sh
# コマンドの出力を変数に格納する
TODAY=`date +%Y-%m-%d`
FILE_COUNT=`ls -1 /var/log | wc -l`
echo "今日は${TODAY}、ログファイルは${FILE_COUNT}個"
```

コマンド置換は、あるコマンドの標準出力を別のコマンドの引数やスクリプトの文脈に埋め込む。パイプが「コマンド間の直列接続」だとすれば、コマンド置換は「コマンドの出力の値化」だ。この機能によって、シェルスクリプトは外部コマンドの結果に基づいて動的に振る舞いを変えることが可能になった。

### 環境変数とexport――プロセス間のデータ受け渡し

Bourne shellは`export`コマンドにより、シェル変数を環境変数に昇格させる仕組みを導入した。

```sh
# シェル変数（子プロセスには継承されない）
GREETING="hello"

# 環境変数に昇格（子プロセスに継承される）
export GREETING
```

`export`で指定されていない変数は、子プロセスに継承されない。この設計は、プロセス間のデータ受け渡しを明示的に制御可能にした。なお、環境変数の仕組み自体はBourne、Mashey、Dennis Ritchieの三者が協力して設計したとされている。

### trapによるシグナルハンドリング

Bourne shellの`trap`コマンドは、シグナルを受信した際の動作を定義する。

```sh
# 一時ファイルの後始末をtrapで保証する
TMPFILE=/tmp/myapp.$$
trap 'rm -f $TMPFILE; exit' 0 1 2 15
```

シグナル0はスクリプトの正常終了時、1はHUP（端末切断）、2はINT（Ctrl-C）、15はTERM（終了要求）に対応する。`trap`により、スクリプトが中断された場合でも後始末を確実に行えるようになった。これはシェルスクリプトの堅牢性を飛躍的に向上させた機能だ。

### 変数展開→ワード分割→グロビング――処理パイプラインの構造

ここからが、Bourne shellの言語設計における最も重要な――そして最も問題のある――部分だ。

Bourne shellでは、コマンドライン上のテキストは実行前に複数の段階で処理される。その処理の順序を理解しなければ、シェルスクリプトのバグを理解することは不可能だ。

```
Bourne shellの処理パイプライン（概略）:

  ユーザーが入力したコマンドライン
        │
        ▼
  ┌──────────────────┐
  │ 1. トークン化     │ コマンドラインを単語（トークン）に分割
  │    (Tokenization) │ 演算子（|, ;, &等）で区切る
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │ 2. 変数展開       │ $NAME → 変数の値に置き換え
  │    (Expansion)    │ `command` → コマンドの出力に置き換え
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │ 3. ワード分割     │ 展開結果をIFSに基づいて分割
  │    (Word Split)   │ ※未クォートの展開のみ対象
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │ 4. グロビング     │ *, ?, [...] をファイル名に展開
  │    (Globbing)     │ ※未クォートのパターンのみ対象
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │ 5. クォート除去   │ クォート文字（', ", \）を除去
  │    (Quote Remove) │ 最終的な引数リストが確定
  └────────┬─────────┘
           │
           ▼
  コマンド実行（fork/exec）
```

この処理パイプラインの中で、ステップ2（変数展開）とステップ3（ワード分割）の間に潜む問題が、シェルスクリプトのバグの最大の温床になる。

具体例で示そう。

```sh
filename="error report.log"
cat $filename
# ↓ 変数展開後:
# cat error report.log
# ↓ ワード分割後:
# "cat" "error" "report.log" （3つの引数に分割される）
# → cat は "error" と "report.log" の2つのファイルを開こうとする
```

変数`filename`の値は`error report.log`という1つのファイル名だ。だが、ダブルクォートで囲まずに`$filename`と書くと、変数展開の後にワード分割が走り、スペースの位置で文字列が2つに分割される。結果、`cat`は2つの別々のファイルを開こうとし、スクリプトは壊れる。

```sh
# 正しい書き方（ダブルクォートで囲む）
cat "$filename"
# ↓ 変数展開後（クォート内なのでワード分割されない）:
# cat "error report.log"
# ↓ クォート除去後:
# "cat" "error report.log" （2つの引数）
# → 期待通りの動作
```

ダブルクォートで変数参照を囲むことで、ワード分割を抑制できる。だがこの「ダブルクォートで囲む」ことを忘れた瞬間、スクリプトは壊れる。そして、忘れやすいのだ。なぜなら、ファイル名にスペースが含まれない限り、クォートがなくても正しく動作するからだ。バグは特定の入力でのみ顕在化する。これが「クォーティング地獄」の入り口だ。

### IFS――ワード分割の制御変数

ワード分割の挙動を制御するのが、IFS（Internal Field Separator）という特殊変数だ。デフォルト値はスペース、タブ、改行の3文字。

```sh
# IFSのデフォルトでの挙動
data="apple:banana:cherry"
for item in $data; do
  echo "$item"
done
# 出力: apple:banana:cherry（区切りが : ではないため1要素）

# IFSを変更してワード分割の挙動を変える
IFS=":"
for item in $data; do
  echo "$item"
done
# 出力:
# apple
# banana
# cherry
```

IFSの変更はワード分割の規則を根本から変える。CSVの解析やPATHの分割に使えるが、グローバルなIFS変更はスクリプト全体に副作用をもたらすため、扱いには細心の注意が必要だ。

### サブシェル――括弧による環境の隔離

Bourne shellは括弧`()`でコマンドをグルーピングし、サブシェル内で実行する機構を導入した。

```sh
# サブシェル内の変数変更は親シェルに影響しない
VAR="parent"
(
  VAR="child"
  echo "サブシェル内: $VAR"   # → child
)
echo "親シェル: $VAR"          # → parent
```

サブシェルは`fork()`による子プロセスの生成で実現される。子プロセス内での変数変更やディレクトリ移動は親プロセスに影響しない。この「環境の隔離」は、スクリプトの一部分だけを独立した文脈で実行したい場合に有用だ。

### Bourne shellの言語設計――まとめと対比

Bourne shellの言語設計を、同時代の他の言語と対比して位置づけてみよう。

```
                  ALGOL 68     C言語        Bourne shell
                  (1968年)     (1972年)     (1979年)
────────────────────────────────────────────────────────
型システム       強い静的型   弱い静的型   型なし（すべて文字列）
制御構造         if/fi等      if/{}        if/fi等（ALGOL風）
変数スコープ     ブロック     関数/ファイル グローバル＋ローカル
エラー処理       例外         戻り値       終了ステータス（$?）
主な用途         汎用         システム     コマンドの糊付け
```

Bourne shellは、ALGOL 68の構文を借用しつつも、C言語よりもさらに型に無頓着な言語として設計された。この設計は、シェルの役割——他のプログラムを起動し、結合し、制御する「糊」——に最適化されている。だが、スクリプトが数十行を超えて複雑化すると、型なし設計の代償が顕在化する。変数に格納された文字列が数値なのかファイルパスなのかコマンド名なのか、シェルは区別しない。すべてはただの文字列だ。

---

## 4. ハンズオン――Bourne shellの言語機能を体験する

理論を確認したら、実際に手を動かそう。Bourne shell（`/bin/sh`）の言語機能を、現代のシェル環境で体験する。POSIX sh準拠の構文のみを使い、bash拡張は使わない。

### 環境構築

Docker環境を前提とする。以下のコマンドでUbuntu 24.04コンテナを起動する。

```bash
docker run -it ubuntu:24.04 bash
```

あるいは、本記事に付属する`setup.sh`スクリプトを使えば、演習環境の構築を一括で行える。

```bash
bash setup.sh
```

### 演習1：変数と制御構造の基本

Thompson shellでは不可能だった変数と制御構造を使って、実用的なスクリプトを書いてみよう。

```sh
# --- Bourne shellの変数と制御構造 ---

# 変数代入（= の前後にスペースを入れてはならない）
LOG_DIR="/var/log"
THRESHOLD=3

echo "=== Bourne shellの変数と制御構造 ==="
echo ""

# for...in...do...done ループ
echo "--- for ループ ---"
for file in /etc/hostname /etc/hosts /etc/nonexistent; do
  if [ -f "$file" ]; then
    echo "${file}: 存在する ($(wc -l < "$file") 行)"
  else
    echo "${file}: 存在しない"
  fi
done

echo ""

# case...in...esac 分岐
echo "--- case 分岐 ---"
SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
  bash)  echo "Bourne-Again SHell を使用中" ;;
  zsh)   echo "Z Shell を使用中" ;;
  dash)  echo "Debian Almquist SHell を使用中" ;;
  sh)    echo "Bourne Shell互換を使用中" ;;
  *)     echo "不明なシェル: ${SHELL_NAME}" ;;
esac

echo ""

# while...do...done ループ
echo "--- while ループ ---"
count=1
while [ "$count" -le 5 ]; do
  echo "  カウント: ${count}"
  count=$((count + 1))
done
```

`fi`は`if`を閉じ、`esac`は`case`を閉じ、`done`はループを閉じる。C言語の中括弧`{}`ではなく、ALGOL 68の流儀で開始キーワードの逆綴りが閉じトークンになる。

### 演習2：変数展開とワード分割の罠

Bourne shellの設計における最大の罠を、意図的に踏んでみよう。

```sh
# --- ワード分割の罠を体験する ---

echo "=== ワード分割の罠 ==="
echo ""

WORK_DIR="/tmp/bourne-demo"
mkdir -p "$WORK_DIR"

# スペースを含むファイル名を作成する
echo "内容A" > "${WORK_DIR}/error report.log"
echo "内容B" > "${WORK_DIR}/access_log.txt"

echo "--- 作成したファイル ---"
ls -la "${WORK_DIR}/"
echo ""

# 罠1: クォートなしの変数展開
echo "--- 罠1: クォートなしの変数展開 ---"
TARGET="${WORK_DIR}/error report.log"

echo "変数の値: ${TARGET}"
echo ""

echo "クォートなし: cat \$TARGET"
cat $TARGET 2>&1 || true
echo ""

echo "クォートあり: cat \"\$TARGET\""
cat "$TARGET"
echo ""

# 罠2: for ループでのワード分割
echo "--- 罠2: for ループでのワード分割 ---"
FILES="${WORK_DIR}/error report.log ${WORK_DIR}/access_log.txt"

echo "クォートなし: for f in \$FILES"
for f in $FILES; do
  echo "  引数: '$f'"
done
echo ""

echo "※ 'error' と 'report.log' が別々の引数になった"
echo "※ これがBourne shellの『ワード分割』の挙動"
echo ""

# 正しい方法: 個別に変数を使う
echo "--- 正しいアプローチ ---"
for f in "${WORK_DIR}/error report.log" "${WORK_DIR}/access_log.txt"; do
  if [ -f "$f" ]; then
    echo "  $(basename "$f"): 存在する"
  fi
done

# 掃除
rm -rf "${WORK_DIR}"
```

クォートなしの`$TARGET`がワード分割によって2つの引数に分裂する様子を確認してほしい。これは「バグ」ではなく、Bourne shellの設計通りの動作だ。変数展開の後にワード分割が走る。この処理パイプラインを理解していなければ、シェルスクリプトは常に時限爆弾を抱えることになる。

### 演習3：ヒアドキュメントとコマンド置換

Thompson shellにはなかった2つの機能を組み合わせてみよう。

```sh
# --- ヒアドキュメントとコマンド置換 ---

echo "=== ヒアドキュメントとコマンド置換 ==="
echo ""

# コマンド置換で情報を収集する
HOSTNAME=`hostname`
KERNEL=`uname -r`
DATE=`date '+%Y-%m-%d %H:%M:%S'`
UPTIME=`uptime -p 2>/dev/null || uptime`

# ヒアドキュメントでレポートを生成する
cat << REPORT
========================================
 システムレポート
========================================
ホスト名:     ${HOSTNAME}
カーネル:     ${KERNEL}
日時:         ${DATE}
稼働時間:     ${UPTIME}
========================================
REPORT

echo ""
echo "上記のレポートは、コマンド置換とヒアドキュメントの"
echo "組み合わせで生成された。Thompson shellでは不可能だった。"
echo ""

# ヒアドキュメントの変数展開を抑制する（クォート付きデリミタ）
echo "--- 変数展開の抑制 ---"
cat << 'NO_EXPAND'
デリミタをクォートで囲むと、変数展開が抑制される:
  $HOME は展開されない
  `date` も実行されない
これはテンプレートの記述に有用だ。
NO_EXPAND
```

### 演習4：trapによるシグナルハンドリング

Bourne shellが導入した`trap`の動作を確認する。

```sh
# --- trap によるシグナルハンドリング ---

echo "=== trap によるシグナルハンドリング ==="
echo ""

TMPFILE="/tmp/bourne-trap-demo.$$"

# trapを設定: 終了時に一時ファイルを削除する
trap 'echo "後始末: ${TMPFILE} を削除"; rm -f "$TMPFILE"' EXIT

# 一時ファイルを作成する
echo "一時データ" > "$TMPFILE"
echo "一時ファイルを作成: ${TMPFILE}"
ls -la "$TMPFILE"
echo ""

echo "このスクリプトが正常終了しても、Ctrl-Cで中断されても、"
echo "trapにより一時ファイルは確実に削除される。"
echo ""

echo "--- trapの一覧 ---"
trap
echo ""

# スクリプト終了時にtrapが発火する
echo "スクリプト終了（trapが発火する）..."
```

`trap`は、Thompson shellの時代には不可能だったスクリプトの堅牢性を実現する。外部コマンドの`/bin/if`と`/bin/goto`で条件分岐を書いていた時代から、シグナルハンドリングを備えた構造化プログラミングへ。この飛躍の大きさを、この演習で感じ取ってほしい。

### 演習5：Thompson shell時代との対比

最後に、同じタスクをThompson shell的な手法（制約あり）とBourne shellの手法で実装し、差異を体感しよう。

```sh
# --- Thompson shell時代 vs Bourne shell時代 ---

echo "=== 同じタスクの実装比較 ==="
echo ""

DEMO_DIR="/tmp/bourne-compare"
mkdir -p "$DEMO_DIR"

# テストファイルの準備
echo "ERROR: disk full" > "${DEMO_DIR}/app1.log"
echo "INFO: started" > "${DEMO_DIR}/app2.log"
echo "ERROR: timeout" > "${DEMO_DIR}/app3.log"
echo "INFO: healthy" > "${DEMO_DIR}/app4.log"
echo "ERROR: connection refused" > "${DEMO_DIR}/app5.log"

echo "--- タスク: ERRORを含むログファイルの一覧を出力 ---"
echo ""

echo "[Thompson shell的手法] (変数なし、制御構造なし)"
echo "各ファイルを1つずつ手動で確認するしかない:"
echo "  grep ERROR ${DEMO_DIR}/app1.log > /dev/null && echo app1.log"
echo "  grep ERROR ${DEMO_DIR}/app2.log > /dev/null && echo app2.log"
echo "  ... (ファイル数だけ繰り返す)"
echo ""

echo "[Bourne shell] (変数 + for + if)"
ERROR_COUNT=0
for logfile in "${DEMO_DIR}"/*.log; do
  if grep -q ERROR "$logfile"; then
    echo "  ERROR検出: $(basename "$logfile")"
    ERROR_COUNT=$((ERROR_COUNT + 1))
  fi
done
echo ""
echo "  合計: ${ERROR_COUNT} ファイルにERRORが含まれる"
echo ""

echo "Bourne shellの変数と制御構造により、"
echo "ファイル数が増えてもスクリプトを変更する必要がない。"
echo "これが『プログラミング言語』としてのシェルの力だ。"

# 掃除
rm -rf "$DEMO_DIR"
```

Thompson shell的な手法では、処理対象のファイルが増えるたびにスクリプトを手動で修正しなければならない。Bourne shellでは、`for`ループとグロビング（`*.log`）により、ファイル数が増減してもスクリプトは変更不要だ。これが「コマンドインタプリタ」と「プログラミング言語」の決定的な差だ。

---

## 5. まとめと次回予告

### この回の要点

第一に、Bourne shellはStephen Bourneによって1976年から開発が始まり、1979年のUNIX V7でリリースされた。BourneはCambridge大学でALGOL 68Cコンパイラを開発した経歴を持ち、その経験がシェルの構文設計に直接的な影響を与えた。`fi`、`esac`、`done`というALGOL 68由来の閉じトークンが、Bourne shellの構文を特徴づけている。

第二に、Bourne shellは「コマンドインタプリタ」を「コマンドプログラミング言語」に変えた。名前付き変数、制御構造（if/for/while/case/until）、ヒアドキュメント、コマンド置換、環境変数（export）、シグナルハンドリング（trap）、サブシェル。これらの機能が一体となり、シェルスクリプトという新しいプログラミングの形態を生み出した。

第三に、Bourne shellの言語設計は「すべては文字列」を基本とする。型システムを持たず、変数の値は常に文字列だ。この設計はシェルの「糊」としての役割に最適化されているが、スクリプトの複雑化に伴い、型なし設計の代償が顕在化する。

第四に、変数展開→ワード分割→グロビングという処理パイプラインが、Bourne shellの言語設計における最大の罠の根源だ。未クォートの変数展開がワード分割の対象となり、スペースを含む文字列が意図せず分割される。この挙動は「バグ」ではなく「設計」であり、1979年の設計判断が今日まで生き続けている。

第五に、Bourneは1983年まで開発を続け、関数定義を最後に追加した。それ以上の機能追加はシェルの単純さを損なうと判断して開発を終えた。この判断は、言語の一貫性を重視するALGOL 68的な思想の反映だったと私は考える。

### 冒頭の問いへの暫定回答

「シェルは『コマンドを打つ場所』なのか、『プログラミング言語』なのか」――この問いに対する暫定的な答えはこうだ。

Bourne shellは、シェルを明確に「プログラミング言語」に昇格させた。だが、その「プログラミング言語」は、通常の意味でのプログラミング言語とは根本的に異なる。型がない。ワード分割という暗黙的な処理が走る。変数展開とグロビングが予期しない副作用を生む。Bourne shellは「コマンドの糊付け」に最適化された言語であり、汎用プログラミング言語ではない。

シェルが「プログラミング言語」になったことは、革新であると同時に、問題の始まりでもあった。「プログラミング言語」としての能力を得たことで、人々はシェルに「プログラミング言語」としての堅牢性を期待するようになる。だがシェルは、その期待に応えるようには設計されていなかった。

この緊張は、47年後の今も解消されていない。

### 次回予告

次回は、Bourne shellの言語設計が引き起こす最も悪名高い問題——クォーティング地獄——を正面から扱う。

`"$filename"`と`$filename`の間には、深い溝がある。ダブルクォートの有無で、スクリプトが動いたり壊れたりする。シングルクォート、ダブルクォート、バッククォートの意味の違い。`"$@"`と`$*`の決定的な差。IFSの操作がもたらす副作用。そしてShellCheck（2012年、Vidar Holen）の登場と、静的解析によるシェルスクリプト品質向上の試み。

クォーティング地獄は「バグ」ではなく「設計」だ。この設計を理解せずにシェルスクリプトを書くことは、地雷原を地図なしで歩くに等しい。次回はその地図を手に入れる。

---

## 参考文献

- S.R. Bourne, "The UNIX Shell", Bell System Technical Journal, Vol. 57, No. 6, Part 2, pp.1971-1990, July-August 1978 <https://archive.org/details/bstj57-6-1971>
- Wikipedia, "Bourne shell" <https://en.wikipedia.org/wiki/Bourne_shell>
- Wikipedia, "Stephen R. Bourne" <https://en.wikipedia.org/wiki/Stephen_R._Bourne>
- Wikipedia, "ALGOL 68C" <https://en.wikipedia.org/wiki/ALGOL_68C>
- Wikipedia, "PWB shell" <https://en.wikipedia.org/wiki/PWB_shell>
- Russ Cox, "Bourne Shell Macros", research!rsc <https://research.swtch.com/shmacro>
- Sven Mascheck, "traditional Bourne shell family / history and development" <https://www.in-ulm.de/~mascheck/bourne/>
- Sven Mascheck, "Bourne Shell Manual, Version 7" <https://www.in-ulm.de/~mascheck/bourne/v7/>
- Greg's Wiki, "WordSplitting" <https://mywiki.wooledge.org/WordSplitting>
- Greg's Wiki, "IFS" <https://mywiki.wooledge.org/IFS>
- Chet Ramey, "The Architecture of Open Source Applications: The Bourne-Again Shell" <https://aosabook.org/en/v1/bash.html>
