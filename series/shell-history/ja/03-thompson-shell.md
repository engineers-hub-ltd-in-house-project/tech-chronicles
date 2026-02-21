# 第3回：Thompson shell――まだ"シェル"ではなかった最初のシェル

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- UNIX V1（1971年）に搭載されたThompson shellの全体像
- 変数がない、制御構造がない、パイプすら後から追加された事実
- fork/execモデルとシェルが「カーネルの外」に置かれた設計判断の意味
- グロビング（`/etc/glob`）やif/gotoが外部コマンドだった理由
- Mashey shell（1975年）が橋渡しした「プログラミング言語としてのシェル」への道

---

## 1. 導入――「何もない」シェルへの驚き

あるとき私は、UNIX V6のマニュアルを読んでいた。

正確に言えば、Webで公開されているV6のsh(1)のマニュアルページだ。2000年代前半のことだったと思う。当時の私はbashでシェルスクリプトを日常的に書いており、`for`ループ、変数代入、`if`文、関数定義といった機能を当然のものとして使っていた。bashは「コマンドを打つ場所」であると同時に「プログラミング言語」でもある。そのことを疑ったことはなかった。

だからV6のシェルのマニュアルを読んだときの驚きは、今でも鮮明に覚えている。

変数がない。`NAME=value`のような代入構文が存在しない。名前付きの変数を定義することも、参照することもできない。`for`ループがない。`while`もない。`case`もない。`if`は——あるにはあるが、シェルの構文ではなく、`/bin/if`という独立した外部コマンドだ。関数定義など論外だ。

そしてもうひとつ、私を驚かせた事実がある。パイプがV1には存在しなかったということだ。UNIXといえばパイプ、パイプといえばUNIX。この等式が私の中にあった。だがThompson shellの最初のバージョンにパイプはなかった。パイプが追加されたのはV3（1973年）であり、UNIXの誕生から2年後のことだった。

これは一体どういうことなのか。

私たちが「シェル」と呼ぶもの——変数を持ち、制御構造を持ち、パイプでコマンドを連結し、関数を定義し、複雑なスクリプトを書ける——その「シェル」像は、最初のUNIXシェルとはまったく異なるものだった。Thompson shellは、現代の感覚では「シェル」とさえ呼びがたいほど素朴なプログラムだった。

だが、この「何もなさ」にこそ、シェルの本質が宿っている。Thompson shellは、シェルが最小限何であるべきかを示している。逆に言えば、私たちが当然と思っている機能の多くは、後から積み重ねられた上物にすぎない。

最初のUNIXシェルは、何ができて、何ができなかったのか。そして、何が「最初からあった」のか。この問いに答えることは、シェルの本質を理解する第一歩になるはずだ。

---

## 2. 歴史的背景――UNIXとThompson shellの誕生

### PDP-7の上で生まれたOS

前回、私はタイムシェアリングの誕生からMulticsにおける"shell"という概念の命名まで辿った。この流れの直接的な延長線上に、UNIXが生まれる。

Multicsプロジェクトは野心的だったが、その野心ゆえに開発は難航した。1969年、Bell Labs（AT&T）はMulticsプロジェクトからの撤退を決定する。だがMulticsに関わっていたKen ThompsonとDennis Ritchieは、Multicsの設計思想の影響を受けつつも、もっと小さく、もっと単純なシステムを作ろうとしていた。

1969年夏、ThompsonはBell Labsの片隅にあったDEC PDP-7という計算機の上で、新しいOSの原型を書き始めた。PDP-7は1965年に発売された18ビットワードのミニコンピュータで、メモリは最大でも8Kワード（約144Kバイト）しかなかった。Multicsが巨大なハードウェアの上で動く壮大なシステムだったのに対し、Thompsonが書き始めたシステムは、研究所の余り物の計算機の上で動く小さなプログラム群だった。

この対比は偶然ではない。Brian Kernighanが後に名付けた「UNICS」——Multicsの「MULTI」を「UNI」に置き換えた名称——は、その設計思想の核心を表している。Multicsの「すべてを大きく」に対する「すべてを小さく」。この哲学が、Thompson shellの設計を根底から規定することになる。

### PDP-11への移行とUNIX V1（1971年）

PDP-7上のUNIXはアセンブリ言語で書かれた実験的なシステムだったが、ThompsonとRitchieはより強力なハードウェアを必要としていた。折しもBell Labsの特許部門がワードプロセッサを求めていたこともあり、テキスト処理機能を追加する名目でDEC PDP-11/20の購入が承認された。

PDP-11は1970年に発売された16ビットのミニコンピュータで、メモリは最大56Kバイト。PDP-7よりも格段に強力だったが、現代の基準では依然として極めて限られた資源だ。この56Kバイトの中に、カーネル、ユーザプログラム、そしてシェルが収まらなければならなかった。

1971年11月3日、PDP-11上に移植されたUNIXの最初の版——UNIX V1——がリリースされた。このV1に含まれていたコマンドインタプリタが、後にThompson shellと呼ばれるプログラムだ。

### Thompson shellの機能――あるものと、ないもの

Thompson shellが備えていた機能を列挙してみよう。驚くほど短いリストになる。

**V1（1971年）から存在した機能:**

第一に、コマンドの実行。ユーザーが入力したコマンド名を探し、fork/execで子プロセスとして実行する。これがシェルの最も根源的な機能だ。

第二に、入出力リダイレクト。`>filename`で標準出力をファイルに、`<filename`で標準入力をファイルから読み取る。この構文はV1から存在していた。Multicsでは入出力の切り替えに開始と終了の別コマンドが必要だったが、Thompson shellではコマンドラインに`>`や`<`を添えるだけでよかった。この簡潔さは、Multics的な複雑さへの反発であり、UNIXの「小さく、単純に」という思想の表れだ。

第三に、逐次実行。`;`（セミコロン）でコマンドを区切ることで、複数のコマンドを順番に実行できた。`command1 ; command2`はcommand1を実行した後にcommand2を実行する。

第四に、バックグラウンド実行。`&`を末尾に付けることで、コマンドを非同期に実行し、シェルは即座に次の入力を受け付ける。`command &`はcommandの完了を待たずにプロンプトを返す。

第五に、ファイル名のワイルドカード展開（グロビング）。ただし、これはシェル自身の機能ではなかった。`*`や`?`を含む引数を検出すると、シェルは外部コマンド`/etc/glob`を呼び出してファイル名の展開を委譲した。この点については後で詳しく述べる。

**V3（1973年）で追加された機能:**

パイプ。`|`記号でコマンドの標準出力を次のコマンドの標準入力に接続する。この機能はDoug McIlroyの1964年の着想に基づき、1973年1月15日にThompsonが実装した。

**Thompson shellに存在しなかった機能:**

名前付き変数。`NAME=value`のような変数代入は不可能だった。位置パラメータ（`$1`、`$2`...）はあったが、それ以上のものはない。

制御構造の構文。`if`、`for`、`while`、`case`といったシェル組み込みの制御構造は存在しなかった。`if`と`goto`は外部コマンド（`/bin/if`と`/bin/goto`）として提供されていた。

関数定義。関数を定義して再利用するという概念自体が、Thompson shellにはなかった。

コメント構文。コメントを書く専用の構文すらなかった。代わりに`:`というビルトインコマンドがあり、これは引数をすべて無視して単に成功を返すだけのものだった。プログラマはこの`:` の後にテキストを書くことでコメントの代用とした。

環境変数へのアクセス。環境変数の仕組み自体がこの時代にはまだ存在しなかった。

### パイプの誕生――McIlroyの夢とThompsonの一夜

パイプの歴史は、Thompson shellの歴史の中でも特に劇的だ。

Doug McIlroyは、UNIXが生まれる以前からパイプの概念を着想していた。1964年10月11日、McIlroyはBell Labsの内部メモにこう記した。

> We should have some ways of connecting programs like garden hose--screw in another segment when it becomes necessary to massage data in another way.
>
> （プログラムをガーデンホースのように接続する方法が必要だ。データを別の方法で加工する必要が生じたら、別のセグメントをねじ込めばよい。）

このメモが書かれた1964年、Bell LabsのコンピューティングはIBM 7090/7094によるバッチ処理が主流だった。パイプというアイデアが実装されるには、まずUNIXというOSの誕生を待たねばならなかった。

McIlroyはUNIX開発チームのマネージャとして、パイプの実装を強く推し続けた。McIlroy自身の証言によれば「マネージャとしての権限を使ってパイプを実装させる寸前まで行った」という。

そして1973年1月15日、Ken Thompsonが動いた。McIlroyの回想によれば、「one feverish night（熱狂的な一夜）」の出来事だった。Thompsonはその一夜で、pipe()システムコールを実装し、シェルにパイプを統合し、`pr`や`ov`などの複数のユーティリティをフィルタとして使えるように改修した。McIlroyは後にこう述べている。「彼は私が提案した通りのpipeシステムコールを実装しなかった。もう少しだけ優れたものを発明した……。彼はその同じ夜に、すべてのプログラムを変更した」。

UNIX V3ではパイプの記法はまだ洗練されていなかったが、V4でThompsonが`|`（パイプ文字）記法を導入し、マニュアルの記述が大幅に簡素化された。McIlroyはこの`|`記法の導入もThompsonの功績として評価している。

McIlroyの着想からThompsonの実装まで、9年。一つのアイデアが具体的な技術になるまでに必要だった時間である。

---

## 3. 技術論――「小さなシェル」の設計思想

### fork/exec――シェルが「ただのプログラム」であること

Thompson shellの設計で最も重要な判断は、シェルをカーネルの外に置いたことだ。

Multicsのシェルはカーネルと密接に統合されていた。シェルがカーネルの一部であるということは、シェルの変更にカーネルの再構築が必要になることを意味する。Thompson shellは異なる道を選んだ。シェルは特権を持たない通常のユーザプログラムとして実装された。

この設計を可能にしたのが、fork/execモデルだ。

```
Thompson shellのコマンド実行モデル:

  ┌──────────────┐
  │    shell     │ ← ユーザプログラム（特権なし）
  │  (親プロセス) │
  └──────┬───────┘
         │ fork()
         │ ┌──────────────┐
         ├─│  子プロセス   │
         │ │ (shellの複製) │
         │ └──────┬───────┘
         │        │ exec()
         │ ┌──────┴───────┐
         │ │  外部コマンド  │
         │ │  (ls, cat等)  │
         │ └──────┬───────┘
         │        │ 終了
         │ wait() │
  ┌──────┴───────┐
  │    shell     │ ← 次のコマンドを待つ
  │  (親プロセス) │
  └──────────────┘
```

シェルは以下の手順でコマンドを実行する。

第一に、fork()システムコールで自分自身を複製する。これにより、シェルと同一の子プロセスが生まれる。

第二に、子プロセスがexec()システムコールを呼び、自分自身を実行したいコマンドのプログラムで置き換える。

第三に、親プロセス（シェル）はwait()で子プロセスの終了を待つ。子プロセスが終了したら、次のコマンドの入力を待つ。

Thompson自身が1976年の論文"The UNIX Command Language"で記しているように、「ほとんどのUNIXユーザーはログオンするとシェルというプログラムに出会う。シェルの仕事はユーザーが指定したプログラムを実行することだ」。そして重要なのは、このシェルがOSの一部ではなく、特別な権限も持たないことだ。

この設計がもたらした帰結は深い。シェルが「ただのプログラム」であるなら、誰でも別のシェルを書ける。気に入らなければ替えればよい。実際にこの設計判断が、後のBourne shell、C shell、ksh、bash、zsh、fish、Nushellという多様なシェルの系譜を可能にした。もしシェルがカーネルに組み込まれていたら、UNIXのシェル文化は今とはまったく異なるものになっていただろう。

### 入出力リダイレクトの設計

Thompson shellにおける入出力リダイレクトの実装は、fork/execモデルと密接に結びついている。

```
リダイレクトの実行手順:

  $ command > output.txt

  1. shell が fork() → 子プロセス生成
  2. 子プロセスが output.txt を open() し、
     そのファイルディスクリプタを標準出力(fd 1)に dup2()
  3. 子プロセスが exec("command") → コマンド実行
  4. command は標準出力に書き込むが、
     実際にはファイルに書き込まれる
  5. command は自分の出力が
     リダイレクトされていることを知らない
```

ここで重要なのは、実行されるコマンドが自分の出力先がリダイレクトされていることを知る必要がないという点だ。コマンドは単に標準出力に書き込む。それがターミナルに行くのかファイルに行くのかは、コマンドの関知するところではない。この「コマンドはリダイレクトを意識しない」という原則は、Thompson shellの設計の中でも最も重要なもののひとつであり、パイプの実装にもそのまま適用された。

### `/etc/glob`――外部化されたグロビング

Thompson shellでは、ファイル名のワイルドカード展開は外部コマンド`/etc/glob`に委譲されていた。Dennis Ritchieが書いたこのプログラムは、`*`（任意の文字列にマッチ）や`?`（任意の1文字にマッチ）を含む引数を受け取ると、ファイルシステムを走査してマッチするファイル名のソート済みリストを生成し、元のコマンドに渡した。

```
Thompson shellでのグロビングの動作:

  $ ls *.c

  1. shell が引数 "*.c" に * を検出
  2. shell が /etc/glob を呼び出す
     /etc/glob ls *.c
  3. /etc/glob が *.c をマッチするファイル名に展開
     → foo.c bar.c baz.c
  4. /etc/glob が ls foo.c bar.c baz.c を実行
```

なぜグロビングはシェルの内部に実装されなかったのか。答えはPDP-11のメモリ制約にある。シェル本体のバイナリサイズを極力小さく保つため、シェルの「本質」ではないと判断された機能は外部に追い出された。グロビングだけでなく、`if`も`goto`も外部コマンドだったことを思い出してほしい。

この設計判断は後のBourne shell（V7, 1979年）で覆される。Bourne shellはグロビングをシェル内蔵にした。だがThompson shellが選んだ「外部化」のアプローチは、UNIXの哲学——「ひとつのプログラムはひとつのことをうまくやれ」——と整合していたとも言える。

「glob」という名前の由来については、"global"の略でファイルシステム全体を検索する意図だったとされる。この名称はC言語の標準ライブラリ関数`glob()`、そして現代のプログラミングにおける「グロブパターン」という用語として生き続けている。

### `/bin/if`と`/bin/goto`――外部コマンドとしての制御構造

Thompson shellの設計思想を最も端的に示すのが、制御構造の扱いだ。

`/bin/if`は条件判定と条件実行を1つのコマンドに統合したものだ。現代のBourne系シェルにおける`test`コマンドと`if`構文を組み合わせたような働きをする。

```sh
# Thompson shell での条件実行
if -r file command
# file が読み取り可能なら command を実行する
```

`/bin/goto`の実装はさらに興味深い。gotoコマンドはシェル自体とは別のプログラムでありながら、シェルスクリプトの実行位置を変更する必要があった。この矛盾をどう解決したか。`/bin/goto`はlseek(2)システムコールを使い、現在実行中のスクリプトファイル内で`: LABEL`という行を探し、ファイルディスクリプタの読み取り位置をその行に移動させた。シェルが次の行を読もうとしたとき、ファイルディスクリプタはすでにラベルの位置を指しているため、結果としてシェルの実行がそのラベルに「飛ぶ」。

```sh
# Thompson shell でのスクリプト制御
: loop
echo "繰り返し処理"
# ...何かの処理...
goto loop
```

`: loop`は実際にはコメントではない。`:`はすべての引数を無視して成功を返すビルトインコマンドであり、`goto`がラベルとして認識するためのマーカーに過ぎない。`:`の本来の存在理由は「何もしないコマンド」であり、ラベルとしての使用は副産物だ。

この設計は16ビットマシンのメモリ制約に対する合理的な回答だった。制御構造をシェルに内蔵すれば、シェルのバイナリサイズが膨らむ。それを外部コマンドにすれば、シェルは小さいまま保てる。必要なときだけ`/bin/if`や`/bin/goto`がメモリにロードされればよい。

だが、この設計には重大な限界もあった。外部コマンドとしてのif/gotoでは、ネストされた条件分岐や複雑なループを表現することが極めて困難だった。Thompson shell上で「プログラミング」をしようとすれば、すぐにこの壁に突き当たる。Thompson shell時代のシェルスクリプトは、コマンドの逐次実行と簡単な条件分岐程度が限界だった。

### Multics shell vs Thompson shell――設計思想の対比

Thompson shellの設計をより深く理解するために、Multicsのシェルとの対比を整理しておこう。

```
                    Multics shell          Thompson shell
─────────────────────────────────────────────────────────
カーネルとの関係     密接に統合             完全に分離（ユーザプログラム）
プロセスモデル       カーネルが管理         fork/exec
I/Oリダイレクト      開始/終了の2コマンド   > < の簡潔な構文
ファイル名展開       シェル内蔵             /etc/glob（外部コマンド）
制御構造             組み込み               /bin/if, /bin/goto（外部コマンド）
変数                 あり                   名前付き変数なし
ハードウェア         GE-645（大型）         PDP-11（ミニコン）
設計思想             包括的・統合的         最小限・分離的
```

この対比表が示すのは、Thompson shellが単にMulticsの「簡易版」ではないということだ。Thompson shellは、Multicsとは異なる設計哲学——機能を最小限に絞り、各機能を独立したプログラムに分離する——に基づいて設計された。この哲学は、後にDoug McIlroyが定式化したUNIXの設計原則「ひとつのプログラムはひとつのことをうまくやれ」と完全に一致している。

### Mashey shell――Thompson shellからBourne shellへの橋渡し

Thompson shellの限界は、UNIXが研究用のシステムから実務用のシステムへと広がるにつれて顕在化した。

1975年、Bell Labs内部のPWB（Programmer's Workbench）UNIXプロジェクトで、John MasheyはThompson shellを拡張した新しいシェルを開発した。Dick HaightやAlan Glasserも貢献したこのシェルは、PWB shellまたはMashey shellと呼ばれる。

Mashey shellの主要な革新は三つある。

第一に、制御構造のシェル内蔵化。Thompson shellでは外部コマンドだった`if`と`goto`を内部コマンドに取り込み、さらにif-then-else-endif、switch、whileといった本格的な制御構造を追加した。`onintr`による割り込み処理も導入された。

第二に、変数の導入。1文字に限定された単純な変数を導入した。一部の文字は特殊用途に予約されており、これらは後のV7における環境変数の先駆けとなった。

第三に、スクリプティングの実用化。制御構造と変数の導入により、シェルスクリプトで意味のあるプログラムが書けるようになった。

Mashey shellはResearch UNIXの本流ではなくPWBブランチで使われたため、その名は広く知られていない。だがMashey shellが果たした歴史的役割は重要だ。Thompson shellの「コマンドインタプリタ」を「プログラミング言語」へと進化させる最初の一歩を踏み出したのは、Mashey shellだった。

1979年のUNIX V7で、Stephen BourneによるBourne shellがMashey shellに取って代わる。環境変数の仕組みはBourne、Mashey、Dennis Ritchieの三者が協力して設計した。Thompson shell → Mashey shell → Bourne shell。この系譜が、私たちが今日使うbash（Bourne-Again SHell）へと繋がっている。

---

## 4. ハンズオン――Thompson shellの世界を体験する

理論はここまでにして、実際に手を動かそう。Thompson shellそのものを動かすにはPDP-11エミュレータ（SimH）上でUNIX V6を起動する必要があるが、ここではDocker環境でThompson shellの制約を再現し、「何もないシェル」の世界を体感する演習を行う。

### 環境構築

Docker環境を前提とする。以下のコマンドでUbuntu 24.04コンテナを起動する。

```bash
docker run -it ubuntu:24.04 bash
```

あるいは、本記事に付属する`setup.sh`スクリプトを使えば、演習環境の構築を一括で行える。

```bash
bash setup.sh
```

### 演習1：リダイレクトだけでデータ処理を行う

Thompson shellの最初のバージョン（V1, 1971年）にはパイプがなかった。パイプなしで、リダイレクトだけを使ってデータ処理を行うとどうなるか体験してみよう。

```bash
# --- パイプなしのデータ処理（Thompson shell V1の世界） ---

# Step 1: サンプルデータを作成する
cat > /tmp/access_log.txt << 'EOF'
192.168.1.10 GET /index.html 200
192.168.1.20 GET /about.html 200
192.168.1.10 POST /api/login 401
192.168.1.30 GET /index.html 200
192.168.1.20 GET /contact.html 404
192.168.1.10 GET /dashboard 200
192.168.1.40 POST /api/login 200
192.168.1.10 GET /settings 403
192.168.1.30 POST /api/data 500
192.168.1.20 GET /index.html 200
EOF

# Step 2: パイプなしで処理する
# 各ステップの出力を中間ファイルに保存しなければならない

# エラー応答（4xx, 5xx）だけを抽出する
grep -E ' [45][0-9]{2}$' /tmp/access_log.txt > /tmp/step1_errors.txt

# IPアドレスだけを取り出す
awk '{print $1}' /tmp/step1_errors.txt > /tmp/step2_ips.txt

# ソートする
sort /tmp/step2_ips.txt > /tmp/step3_sorted.txt

# 集計する
uniq -c /tmp/step3_sorted.txt > /tmp/step4_result.txt

# 結果を表示する
cat /tmp/step4_result.txt
```

```bash
# --- パイプありのデータ処理（V3以降の世界） ---
# 同じ処理がパイプで1行に書ける
grep -E ' [45][0-9]{2}$' /tmp/access_log.txt | awk '{print $1}' | sort | uniq -c
```

```bash
# 中間ファイルを確認する
echo "--- 中間ファイル（パイプなしの副産物） ---"
ls -la /tmp/step*.txt
echo ""
echo "パイプがなければ、4つの中間ファイルが必要だった。"
echo "パイプがあれば、中間ファイルはゼロ。"

# 掃除
rm -f /tmp/step*.txt /tmp/access_log.txt
```

パイプなしの世界では、コマンド間のデータ受け渡しにすべて中間ファイルが必要になる。Thompson shell V1のユーザーは、この中間ファイルの山と格闘していたのだ。パイプがいかに革命的だったか、この演習で実感できるだろう。

### 演習2：「変数なし」の世界を体験する

Thompson shellには名前付き変数がなかった。変数が使えないとスクリプトがどうなるか体験してみよう。

```bash
# --- 変数が使える世界（現代のシェル） ---
echo "=== 変数ありの世界 ==="

TARGET_DIR="/etc"
FILE_COUNT=$(ls -1 "$TARGET_DIR" | wc -l)
echo "${TARGET_DIR} には ${FILE_COUNT} 個のファイルがある"

# 同じ値を複数回使える
echo "対象: ${TARGET_DIR}"
echo "個数: ${FILE_COUNT}"
```

```bash
# --- 変数なしの世界（Thompson shellの制約） ---
echo "=== 変数なしの世界 ==="

# パスを何度も直接書くしかない
echo "/etc には $(ls -1 /etc | wc -l) 個のファイルがある"

# 変更したければ、すべての箇所を手動で書き換える必要がある
# /etc を /usr に変えるなら:
echo "/usr には $(ls -1 /usr | wc -l) 個のファイルがある"

echo ""
echo "変数がなければ、値の再利用ができない。"
echo "同じパスを何度も手で書く必要がある。"
echo "修正時には全箇所を漏れなく変更しなければならない。"
```

変数がないという制約は、スクリプトの保守性に直結する。Thompson shellでは、短いコマンドの連続実行はできたが、値の再利用や抽象化は不可能だった。

### 演習3：if/gotoが外部コマンドだった世界を再現する

Thompson shellでは`if`と`goto`が外部コマンドだった。この概念を現代のシェル上で再現してみよう。

```bash
# --- /bin/ifの簡易再現 ---
# Thompson shellの/bin/ifは、条件判定とコマンド実行を1つにまとめたものだった

# 外部コマンドとしてのifを作成する
cat > /tmp/fake_if << 'SCRIPT'
#!/bin/sh
# Thompson shellの/bin/ifの簡易再現
# 使い方: fake_if -r filename command [args...]
# -r: ファイルが読み取り可能かテスト

if [ "$1" = "-r" ]; then
  shift
  testfile="$1"
  shift
  if [ -r "$testfile" ]; then
    exec "$@"
  fi
elif [ "$1" = "-w" ]; then
  shift
  testfile="$1"
  shift
  if [ -w "$testfile" ]; then
    exec "$@"
  fi
fi
SCRIPT
chmod +x /tmp/fake_if

# 使ってみる
echo "テスト用ファイルを作成"
echo "hello" > /tmp/testfile.txt

echo ""
echo "--- /bin/if の動作再現 ---"
echo "条件: /tmp/testfile.txt が読み取り可能なら cat を実行"
/tmp/fake_if -r /tmp/testfile.txt cat /tmp/testfile.txt

echo ""
echo "条件: /tmp/nonexistent が読み取り可能なら cat を実行"
/tmp/fake_if -r /tmp/nonexistent cat /tmp/nonexistent
echo "(何も表示されない = 条件が偽なのでコマンドは実行されない)"

# 掃除
rm -f /tmp/fake_if /tmp/testfile.txt
```

```bash
# --- /bin/gotoの概念を再現する ---
# gotoはlseek()でスクリプトファイル内の位置を変更していた
# 現代のシェルでこの概念を示す

cat > /tmp/goto_demo.sh << 'DEMO'
#!/bin/sh
# Thompson shellでは : がラベルマーカーとして使われた
# /bin/goto は ": label" の行を探してジャンプした

echo "=== gotoの概念デモ ==="
echo "Thompson shellのgotoは、スクリプトファイル内の"
echo "': label' という行にジャンプする仕組みだった。"
echo ""
echo "現代のシェルにgotoは存在しない。"
echo "代わりにwhile/for/caseなどの構造化された制御構造を使う。"
echo ""
echo "--- Thompson shell風（概念的再現） ---"
echo ': start'
echo 'echo "処理A"'
echo 'goto end'
echo ': middle'
echo 'echo "ここはスキップされる"'
echo ': end'
echo 'echo "処理完了"'
echo ""
echo "--- 現代のシェル ---"
echo 'echo "処理A"'
echo '# 構造化プログラミングにより goto は不要'
echo 'echo "処理完了"'
DEMO
chmod +x /tmp/goto_demo.sh
sh /tmp/goto_demo.sh

# 掃除
rm -f /tmp/goto_demo.sh
```

`goto`が外部コマンドであるという設計は、現代の感覚では奇妙に映る。だが1971年のPDP-11という文脈では、シェルのバイナリサイズを最小に保つための合理的な判断だった。

### 演習4：fork/execモデルを観察する

Thompson shellの核であるfork/execモデルを、現代のシェル上で観察してみよう。

```bash
# --- fork/execモデルの観察 ---

echo "=== 現在のシェルのPID ==="
echo "PID: $$"

echo ""
echo "=== 外部コマンド実行時のfork ==="
echo "親シェル(PID $$)がforkして子プロセスを生成し、"
echo "子プロセスがexecでコマンドに置き換わる。"
echo ""

# 子プロセスのPIDを確認する
echo "lsコマンドのPIDを確認:"
sh -c 'echo "  子プロセスのPID: $$"'

echo ""
echo "=== バックグラウンド実行（&）==="
echo "Thompson shellのV1からバックグラウンド実行は存在した。"
sleep 1 &
BG_PID=$!
echo "バックグラウンドプロセスのPID: ${BG_PID}"
echo "シェルは即座に次のコマンドを受け付ける。"
wait ${BG_PID}
echo "バックグラウンドプロセス完了。"

echo ""
echo "=== リダイレクトとfork/execの関係 ==="
echo "リダイレクトは、fork後・exec前に子プロセスが行う。"
echo "コマンド自身はリダイレクトを知らない。"

# リダイレクトの実演
echo "この文はファイルに書き込まれる" > /tmp/redirect_demo.txt
echo "リダイレクト先の内容:"
cat /tmp/redirect_demo.txt

# 掃除
rm -f /tmp/redirect_demo.txt
```

### 演習5：Thompson shellの機能一覧を実際に確認する

Thompson shellが持っていた機能と持っていなかった機能を、現代のシェルで対比しながら確認する。

```bash
echo "============================================"
echo " Thompson Shell 機能チェックリスト"
echo "============================================"
echo ""
echo "--- Thompson shellにあった機能 ---"
echo ""

echo "[1] コマンド実行"
echo "  現代: ls -la /tmp"
ls -la /tmp > /dev/null 2>&1 && echo "  → 動作確認OK"

echo ""
echo "[2] 入出力リダイレクト (V1, 1971年から)"
echo "  現代: echo hello > /tmp/ts_test.txt"
echo "hello" > /tmp/ts_test.txt
cat /tmp/ts_test.txt
echo "  → 動作確認OK"

echo ""
echo "[3] 逐次実行 ; (V1から)"
echo "  現代: echo A ; echo B"
echo "A" ; echo "B"
echo "  → 動作確認OK"

echo ""
echo "[4] バックグラウンド実行 & (V1から)"
echo "  現代: sleep 0.1 &"
sleep 0.1 &
wait
echo "  → 動作確認OK"

echo ""
echo "[5] パイプ | (V3, 1973年から)"
echo "  現代: echo hello | tr a-z A-Z"
echo "hello" | tr a-z A-Z
echo "  → 動作確認OK"

echo ""
echo "--- Thompson shellになかった機能 ---"
echo ""

echo "[6] 名前付き変数"
echo "  現代: NAME=\"world\" ; echo \$NAME"
NAME="world" ; echo "$NAME"
echo "  → Thompson shellではこれが不可能だった"

echo ""
echo "[7] 制御構造(for/while/case)"
echo "  現代: for i in 1 2 3; do echo \$i; done"
for i in 1 2 3; do echo "$i"; done
echo "  → Thompson shellではfor/while/caseがなかった"

echo ""
echo "[8] 関数定義"
echo "  現代: greet() { echo \"Hello, \$1\"; }; greet World"
greet() { echo "Hello, $1"; }; greet "World"
echo "  → Thompson shellでは関数定義が不可能だった"

# 掃除
rm -f /tmp/ts_test.txt
```

この演習は、私たちが「当然」と思っている機能のどれがThompson shell由来で、どれが後の世代で追加されたものかを明確にするためのものだ。リダイレクト、逐次実行、バックグラウンド実行——これらは1971年からある。変数、制御構造、関数——これらはすべて後から積み上げられた層だ。

---

## 5. まとめと次回予告

### この回の要点

第一に、Thompson shellは1971年のUNIX V1に搭載された最初のUNIXシェルである。その機能は徹底的にミニマルだった。入出力リダイレクト（`>`、`<`）、逐次実行（`;`）、バックグラウンド実行（`&`）、そして外部コマンドとしてのグロビング（`/etc/glob`）と制御構造（`/bin/if`、`/bin/goto`）。名前付き変数もなく、関数定義もなく、パイプすらV1には存在しなかった。

第二に、1973年1月15日、Doug McIlroyの1964年来の着想に基づき、Ken Thompsonが「熱狂的な一夜」でパイプを実装した。pipe()システムコール、シェルへのパイプ統合、ユーティリティのフィルタ対応が一夜にして完成した。この出来事は、UNIXの設計思想を決定づけた。

第三に、Thompson shellの最も重要な設計判断は、シェルをカーネルの外に置き、特権を持たない通常のユーザプログラムとして実装したことだ。fork/execモデルによるプロセス起動、リダイレクト時の「コマンドは自分の出力先を知らない」原則。これらの設計が、後のすべてのUNIXシェルの基盤となった。

第四に、Thompson shellの「何もなさ」は、PDP-11のメモリ制約（最大56Kバイト）に対する合理的な回答であると同時に、UNIXの「小さく、単純に」という設計哲学の体現でもあった。`if`や`goto`を外部コマンドにする設計は、シェル本体を小さく保つための選択だった。

第五に、Mashey shell（1975年）が、Thompson shellとBourne shellの間の橋渡しを果たした。制御構造の内蔵化と変数の導入により、シェルは「コマンドインタプリタ」から「プログラミング言語」への第一歩を踏み出した。

### 冒頭の問いへの暫定回答

「最初のUNIXシェルは、何ができて、何ができなかったのか」――この問いに対する答えを整理しよう。

Thompson shellは「コンピュータとの対話の最小限」を実装した。コマンドを受け取り、実行し、結果を返す。入出力の向きを変える。複数のコマンドを順番に、あるいは並行に実行する。これがThompson shellの「すべて」だ。

そして「できなかったこと」——変数、制御構造、関数、パイプ（V1）——これらの不在は、Thompson shellが「プログラミング言語」ではなく「対話ツール」として設計されたことを物語っている。シェルがプログラミング言語になるのは、次の世代を待たなければならなかった。

だが、Thompson shellが選んだ設計——カーネルの外にシェルを置く、fork/execで外部コマンドを起動する、リダイレクトは子プロセスの仕事にする——この骨格は、50年以上経った今も変わっていない。bashもzshもfishも、この骨格の上に構築されている。Thompson shellは「何もないシェル」だったが、「何もない」からこそ、後のすべてのシェルの基盤になり得た。

### 次回予告

次回は、シェルの歴史における最大の転換点を扱う。Stephen BourneによるBourne shell（1979年, UNIX V7）だ。

Bourne shellは、シェルを「コマンドインタプリタ」から本格的な「プログラミング言語」へと変貌させた。変数、here document、for/case/while/if構文、関数。Algol 68の影響を受けた`fi`、`esac`、`done`という独特の構文。そして、シェルスクリプトの「罠」の根源となるワード分割、グロビング、変数展開の処理パイプライン。

Bourne shellが「シェルをプログラミング言語にした」とき、それは革新であると同時に、今日まで続く問題の起源でもあった。シェルは「コマンドを打つ場所」なのか、「プログラミング言語」なのか。この問いは、Bourne shellから始まる。

---

## 参考文献

- Ken Thompson, "The UNIX Command Language", Structured Programming, Infotech (1976) <https://susam.github.io/tucl/>
- Dennis Ritchie, "The Evolution of the Unix Time-sharing System", Language Design and Programming Methodology, Springer-Verlag (1979) <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/hist.html>
- Doug McIlroy, "A Research UNIX Reader: Annotated Excerpts from the Programmer's Manual, 1971-1986" (1986) <https://www.cs.dartmouth.edu/~doug/reader.pdf>
- Dennis Ritchie, "Prophetic Petroglyphs" (Doug McIlroy's 1964 memo) <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/mdmpipe.html>
- Wikipedia, "Thompson shell" <https://en.wikipedia.org/wiki/Thompson_shell>
- Wikipedia, "Pipeline (Unix)" <https://en.wikipedia.org/wiki/Pipeline_(Unix)>
- Wikipedia, "Glob (programming)" <https://en.wikipedia.org/wiki/Glob_(programming)>
- Wikipedia, "PWB shell" <https://en.wikipedia.org/wiki/PWB_shell>
- Wikipedia, "Fork-exec" <https://en.wikipedia.org/wiki/Fork%E2%80%93exec>
- V6 Sh History <https://v6sh.org/>
- OSnews, "The history and use of /etc/glob in early Unixes" <https://www.osnews.com/story/141520/the-history-and-use-of-etc-glob-in-early-unixes/>
- Sven Mascheck, "Thompson Shell Manual (V6)" <https://www.in-ulm.de/~mascheck/bourne/v6/>
- Computer History Wiki, "UNIX First Edition" <https://gunkies.org/wiki/UNIX_First_Edition>
