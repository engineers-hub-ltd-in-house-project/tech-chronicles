# UNIXという思想

## ——パイプ、プロセス、ファイル――すべてはここから始まった

### 第8回：「小さなツールの組み合わせ——合成可能性の設計」

**連載「UNIXという思想——パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 「組み合わせて使える」ために個々のツールが満たすべき設計条件——stdin/stdout/stderr、テキスト行指向、終了コード、副作用の最小化
- Doug McIlroyが1978年のBell System Technical Journalで定式化した設計指針の原文と、その背景
- Brian Kernighanの『Software Tools』（1976年）が提唱した「ツールボックスアプローチ」の思想
- stderrが生まれた経緯——Bell Labsの写植機で「美しく印字されたエラーメッセージ」が引き起こした惨事
- シェルが「接着剤」として果たす役割——Bourne shell（1979年）の設計思想
- 合成可能性（composability）と関数型プログラミングのパイプ演算子 `|>` の思想的接続
- UNIXの合成可能性がマイクロサービスのAPI設計にどう受け継がれているか

---

## 1. 保守不能なシェルスクリプトが教えてくれたこと

2003年頃、私はあるプロジェクトでサーバ運用を自動化するシェルスクリプトを書いていた。最初は50行ほどの素朴なスクリプトだった。ログを収集し、エラーを検出し、管理者にメールを送る。シンプルな処理だ。

だが要件は膨らんだ。「ディスク使用率もチェックしてほしい」「特定のプロセスが死んでいたら再起動してほしい」「レポートをCSVで出力してほしい」「異常があったらSlack——当時はIRCだったが——に通知してほしい」。要件が一つ増えるたびに、スクリプトに `if` 文が追加された。条件分岐が条件分岐を呼び、関数が関数を呼び、グローバル変数が散乱した。半年後、そのスクリプトは800行を超えていた。

そしてある日、そのスクリプトが壊れた。原因を探ろうとスクリプトを開いた。読めなかった。自分で書いたコードが、半年後の自分には解読不能だった。どこでログを解析しているのか。どこでメールを送っているのか。処理の流れが変数の状態に依存していて、頭の中でスクリプト全体をシミュレートしなければ何が起きるか予測できない。

私はそのスクリプトを捨てた。そして、UNIXのコマンド群に立ち返った。

`grep` はパターンを検索するだけだ。`awk` はフィールドを処理するだけだ。`sort` は並べ替えるだけだ。`mail` はメールを送るだけだ。それぞれが一つのことしかしない。だがパイプで繋ぐと、800行のシェルスクリプトが実現していた機能の大半を、数行のパイプラインで代替できた。

```bash
# 800行のスクリプトが行っていた処理の一部
df -h | awk '$5+0 > 80 {print $6, $5}' | mail -s "Disk Alert" admin@example.com
```

この経験から、私は一つの問いに行き着いた。`grep` と `awk` と `sort` が「組み合わせて使える」のは、なぜなのか。偶然ではないはずだ。これらのコマンドが組み合わせ可能であるためには、何らかの設計上の条件が満たされているはずだ。その条件とは何なのか。

あなたが日常的に書いているパイプラインを思い出してほしい。`cat file | grep pattern | sort | uniq -c | sort -rn | head -10`——このパイプラインの各段が「当たり前」に接続できるのは、個々のコマンドがある規約に従っているからだ。その規約を明確にしたのは誰で、いつのことだったのか。

---

## 2. 合成可能性の設計規約——McIlroy、Kernighan、そしてRaymond

### McIlroyの設計指針（1978年）

合成可能性の設計規約を最初に文書化したのは、Doug McIlroyだった。

1978年7月、Bell System Technical Journal第57巻第6号がUNIX特集号として刊行された。その序文（Foreword）をMcIlroyはE.N. PinsonおよびB.A. Tagueと共同で執筆し、UNIXの設計思想を初めて公式に定式化した。

McIlroyが記した指針の中で、合成可能性に直接関わるものを抜粋する。

> Make each program do one thing well. To do a new job, build afresh rather than complicate old programs by adding new "features."
>
> Expect the output of every program to become the input to another, as yet unknown, program. Don't clutter output with extraneous information. Avoid stringently columnar or binary input formats. Don't insist on interactive input.

「あらゆるプログラムの出力が、まだ見ぬ別のプログラムの入力になることを想定せよ」——この一文が、合成可能性の核心だ。プログラムを書く時点では、その出力が将来どのプログラムに渡されるかわからない。だからこそ、出力は余計な情報で汚してはならない。厳密な列形式やバイナリ形式を強制してはならない。対話的な入力を要求してはならない。

McIlroyの指針が優れているのは、「何をすべきか」だけでなく「何をすべきでないか」を明確にした点だ。「余計な出力を混ぜるな」「バイナリにするな」「対話を強制するな」——これらの禁止事項は、合成可能性を破壊する行為を具体的に列挙している。

### Kernighanの「ツールボックスアプローチ」（1976年）

McIlroyの定式化に先立つ1976年、Brian W. KernighanはP.J. Plaugerとの共著『Software Tools』をAddison-Wesleyから出版した。同書はRatfor（Rational Fortran）で記述されたプログラム群を通じて、ソフトウェアを「ツール」として設計し組み合わせるアプローチを体系的に提示した。

Kernighanのアプローチは明快だ。複雑な問題を解くために巨大なプログラムを書くのではなく、小さなツールを作り、それらを組み合わせて問題を解く。各ツールは一つの機能に特化し、テキストを入力として受け取り、テキストを出力する。ツールの組み合わせ方はユーザが決める。

1981年には同書のPascal版『Software Tools in Pascal』が出版され、ツールボックスアプローチがFortranの世界を越えて広まった。さらに1984年、KernighanはRob Pikeとの共著『The UNIX Programming Environment』をPrentice Hallから出版し、UNIXの環境下でツールをどう設計し、どう組み合わせるかを体系的に解説した。出版から40年以上が経過した現在も、掲載されたほとんどの例が現代のUNIX系システムで動作する。

Kernighanの「ツールボックスアプローチ」が重要なのは、合成可能性を抽象的な原則としてではなく、具体的なプログラム設計の実践として示した点にある。理念だけなら誰でも語れる。だがKernighanは実際に動くツールを書き、それらを組み合わせてみせた。

### Peter Salus、Mike Gancarz、Eric Raymondによる体系化

McIlroyとKernighanが実践と指針で示したUNIX哲学は、その後複数の著者によって体系化された。

1994年、Peter H. Salusは『A Quarter Century of UNIX』で、McIlroyのUNIX哲学を三つの原則に煮詰めた。

1. Write programs that do one thing and do it well.（一つのことをうまくやるプログラムを書け）
2. Write programs to work together.（協調して動くプログラムを書け）
3. Write programs to handle text streams, because that is a universal interface.（テキストストリームを扱うプログラムを書け。それが万能インタフェースだからだ）

この三原則は、McIlroyの指針を凝縮したものとして広く引用されている。第二の原則「協調して動くプログラムを書け」が、合成可能性そのものだ。

1995年、Mike Gancarzは『The UNIX Philosophy』（Digital Press）で、9つの主要原則と10の副次的原則を定義した。合成可能性に直結する原則として「Make every program a filter」（すべてのプログラムをフィルタにせよ）がある。フィルタとは、入力を受け取り、変換を施し、出力するプログラムだ。フィルタであることは、パイプラインの一段として機能するための必要条件だ。

2003年、Eric S. Raymondは『The Art of UNIX Programming』（Addison-Wesley）で、UNIX哲学を17のルールに体系化した。合成可能性に関連するルールを抽出する。

- **Rule of Modularity**: Write simple parts connected by clean interfaces.（単純な部品を清潔なインタフェースで接続せよ）
- **Rule of Composition**: Design programs to be connected to other programs.（他のプログラムと接続されるよう設計せよ）
- **Rule of Silence**: When a program has nothing surprising to say, it should say nothing.（驚くべきことがなければ何も言うな）
- **Rule of Repair**: When you must fail, fail noisily and as soon as possible.（失敗するなら大声で、できるだけ早く）

RaymondのRule of Silenceは、合成可能性にとって決定的に重要だ。不必要な出力を行うプログラムは、パイプラインの後段に雑音を流し込む。進捗バー、ステータスメッセージ、「処理完了」の通知——これらはすべて、後段のプログラムにとってはパースすべきゴミだ。UNIXのコマンドが「沈黙」するのは、無愛想だからではない。合成可能性のためだ。

この規則の起源は1969年のテレタイプ端末の時代にまで遡る。低速の印字端末では、不要な出力の一行一行がユーザの時間を深刻に浪費した。だがテレタイプの時代が終わっても、沈黙の規則が生き残った理由は明確だ。パイプラインのためだ。

---

## 3. 合成可能性の四条件

McIlroyの指針、Kernighanの実践、Raymondの体系化——これらを統合すると、UNIXにおける合成可能性の設計条件は四つに集約できる。

### 条件1：統一的なインタフェース（stdin/stdout/stderr）

UNIXのコマンドが組み合わせ可能である最大の理由は、すべてのコマンドが同じインタフェースでデータを受け渡すことだ。標準入力（stdin、ファイルディスクリプタ0）からデータを読み、標準出力（stdout、ファイルディスクリプタ1）にデータを書く。エラーは標準エラー出力（stderr、ファイルディスクリプタ2）に書く。

この三つのストリームが合成可能性の基盤だ。

```
合成可能性を支える三つのストリーム:

  stdin (fd 0)    stdout (fd 1)    stderr (fd 2)
       │                │                │
       ▼                ▼                ▼
  ┌─────────────────────────────────────────┐
  │           プログラム A                    │
  │                                         │
  │  stdin から読む → 処理 → stdout に書く   │
  │                       → stderr にエラー  │
  └─────────────────────────────────────────┘
       │                │                │
       ▼                ▼                ▼
  パイプで接続      パイプで接続     端末に表示
  （前段の出力）    （後段の入力）   （ユーザに直接）
```

パイプ `|` は、前段のstdoutを後段のstdinに接続する。stderrは接続されず、端末に直接出力される。この分離が重要だ。データの流れ（stdout）とエラーの報告（stderr）が混ざらない。

stderrの誕生には有名なエピソードがある。Bell Labsの研究者たちは、Graphic SystemsのC/A/T写植機を使って文書を印字していた。写植機はフィルム上に文字を露光する装置で、出力には化学現像という手間のかかるプロセスが必要だった。ある日、研究者が文書を写植にかけ、フィルムを現像し、乾かし、確認した。そこに美しく組版された一行があった。「cannot open file foobar」と。エラーメッセージがstdoutに混ざり、文書と一緒に写植されてしまったのだ。

この「高価な写植の無駄」に対する不満が十分な音量で、適切な人物の前で発せられた。数日後、stderrが生まれた。Version 6 UNIXまではdiagnostics（診断メッセージ）はstdoutの一部だったが、この経験を経て、データとエラーは異なるストリームに分離された。

stderrの誕生は、合成可能性の設計が「美学」ではなく「実用上の痛み」から生まれたことを示している。エラーメッセージがデータに混入すれば、パイプラインの後段は正しく動作しない。stderrという別チャネルを設けることで、データの流れを汚さずにエラーを報告できるようになった。

### 条件2：テキスト行指向の入出力

第二の条件は、データがテキストの行として構造化されていることだ。

前回（第7回）で詳しく論じたように、UNIXのツール群はテキストストリームを前提としている。改行（`\n`）がレコード区切り、スペースやタブがフィールド区切り。この単純な構造が、ツール間のデータ受け渡しを可能にする。

`grep` の出力はテキスト行だ。`sort` はテキスト行を受け取り、並べ替えて出力する。`awk` はテキスト行をフィールドに分解し、処理する。すべてが「テキスト行」という共通のデータ単位を前提としている。

この共通前提があるからこそ、`grep` と `sort` は互いの存在を「知らなくても」組み合わせられる。`grep` は `sort` のために出力しているのではない。ただテキスト行を出力しているだけだ。`sort` は `grep` からデータを受け取っているのではない。ただテキスト行を受け取っているだけだ。両者の間には「テキスト行」という暗黙の合意だけがある。

McIlroyの指針における「Avoid stringently columnar or binary input formats」（厳密な列形式やバイナリ入力形式を避けよ）は、この条件を守るための禁止事項だ。固定幅の列形式は、フィールドの追加や変更を困難にする。バイナリ形式は、`grep` や `sort` では処理できない。テキスト行指向を守ることで、ツール間の結合度を最小限に保つ。

### 条件3：終了コードによるエラー伝播

第三の条件は、プログラムの成功・失敗を終了コードで報告することだ。

UNIXの慣習では、成功は終了コード0、失敗は非ゼロで表す。この慣習はシェルの制御構造と直結している。

```bash
# &&（AND）: 左のコマンドが成功（終了コード0）なら右を実行
grep "ERROR" /var/log/syslog && echo "Errors found"

# ||（OR）: 左のコマンドが失敗（終了コード非ゼロ）なら右を実行
grep "ERROR" /var/log/syslog || echo "No errors"

# if文: 終了コードで分岐
if grep -q "ERROR" /var/log/syslog; then
    echo "Errors found"
fi
```

0が「成功」である理由は、設計上の合理性がある。成功のパターンは一つしかない——「正常に完了した」。だが失敗には複数の理由がある。ファイルが見つからない（1）、権限がない（2）、引数が不正（3）。非ゼロの値で失敗の種類を区別できる。BSDシステムの `/usr/include/sysexits.h` は、この終了コードの体系化を試みたヘッダファイルだ。

終了コードが合成可能性に寄与するのは、シェルがパイプラインの制御を終了コードに基づいて行うからだ。`set -e` を指定したシェルスクリプトでは、いずれかのコマンドが非ゼロの終了コードを返した時点でスクリプト全体が停止する。`set -o pipefail` を指定すれば、パイプラインの途中でどのコマンドが失敗しても、パイプライン全体が失敗として扱われる。

```bash
set -euo pipefail

# パイプラインのいずれかが失敗すれば全体が停止
curl -s https://api.example.com/data | jq '.items[]' | sort > output.txt
```

終了コードは、パイプラインにおける「エラー伝播のプロトコル」だ。各コマンドは自身の成功・失敗を終了コードで報告し、シェルがそれを解釈してパイプラインの制御を行う。このプロトコルがなければ、パイプラインの途中で起きた障害を検出する手段がない。

### 条件4：副作用の最小化

第四の条件は、各コマンドが外部状態への副作用を最小限に抑えることだ。

理想的なUNIXのフィルタは「純粋」だ。stdinからデータを読み、処理し、stdoutに書く。それ以外のことはしない。ファイルを変更しない。グローバルな状態を書き換えない。ネットワーク通信をしない。

```
純粋なフィルタ:
  stdin → [処理] → stdout
  副作用なし。入力が同じなら出力は常に同じ。

副作用のあるプログラム:
  stdin → [処理] → stdout
              ↓
         ファイル書き込み
         データベース更新
         ネットワーク通信
```

`grep` は純粋なフィルタだ。与えられた入力からパターンに一致する行を抽出し、出力する。入力が同じなら出力は常に同じだ。`sort` も同様だ。`cat` も同様だ。

この「純粋さ」は関数型プログラミングの「参照透過性」に通じる概念だ。副作用がないプログラムは、順序を入れ替えても、並列に実行しても、結果が変わらない。パイプラインの各段が純粋なフィルタであれば、パイプラインの動作は予測可能であり、デバッグが容易だ。

もちろん、すべてのUNIXコマンドが純粋なフィルタではない。`tee` はstdoutへの出力とファイルへの書き込みを同時に行う。`mv` はファイルを移動する。`rm` はファイルを削除する。だがパイプラインの「中間段」に置かれるコマンド——フィルタとして機能するコマンド——は、可能な限り純粋であるべきだ。副作用のあるコマンドは、パイプラインの「最初」（データの生成）か「最後」（結果の格納）に置く。

```bash
# 典型的なパイプラインの構造
#
# [データ生成]  →  [フィルタ]  →  [フィルタ]  →  [結果の格納]
# (副作用あり)    (純粋)        (純粋)        (副作用あり)
#
cat access.log | grep "404" | awk '{print $7}' | sort | uniq -c | sort -rn > report.txt
# ↑ファイル読み   ↑純粋       ↑純粋           ↑純粋  ↑純粋      ↑ファイル書き込み
```

この構造は、副作用を「端」に押しやり、中間の処理を純粋に保つという設計パターンだ。関数型プログラミングの世界では「純粋な核を副作用のある殻で包む」（Functional Core, Imperative Shell）と呼ばれるパターンに対応する。UNIXのパイプラインは、この設計パターンを1970年代から実践していたことになる。

---

## 4. シェル——「接着剤」としての設計

### Bourne shellの登場（1979年）

四つの条件——統一的なインタフェース、テキスト行指向、終了コード、副作用の最小化——を個々のコマンドが満たしていても、それだけでは合成は実現しない。コマンドを「繋ぐ」仕組みが必要だ。その仕組みがシェルだ。

1976年にStephen BourneがBell Labsで開発を開始し、1979年のVersion 7 UNIXでリリースされたBourne shell（sh）は、Thompson shellの後継として設計された。Bourne shellは対話的なコマンドインタプリタであると同時に、プログラミング言語としての機能を備えていた。変数、条件分岐、ループ、ヒアドキュメント、コマンド置換——これらの機能が、コマンドの組み合わせを「自動化」する手段を提供した。

シェルの本質的な役割は、小さなツール群を束ねる「接着剤」だ。各コマンドは独立したプログラムとして設計されているが、それらを特定の順序で実行し、パイプで繋ぎ、条件に応じて分岐させ、ループで繰り返す——この「接着」の仕事はシェルが担う。

```bash
#!/bin/sh
# シェルの「接着剤」としての機能

# パイプ: コマンドの出力を次のコマンドの入力に繋ぐ
grep "ERROR" /var/log/syslog | wc -l

# リダイレクト: 入出力先を変更する
sort < input.txt > output.txt

# コマンド置換: コマンドの出力を変数に格納する
count=$(grep -c "ERROR" /var/log/syslog)

# 条件分岐: 終了コードに基づいて分岐する
if [ "$count" -gt 0 ]; then
    echo "Found $count errors"
fi

# ループ: コマンドを繰り返し実行する
for file in /var/log/*.log; do
    grep -c "ERROR" "$file"
done
```

シェルスクリプトがプログラミング言語として「貧弱」に見えるのは、意図的な設計だ。シェルの役割は「自ら計算を行う」ことではなく、「他のプログラムを組み合わせる」ことにある。複雑な文字列処理は `sed` に任せる。数値計算は `awk` に任せる。ファイル操作は `find` と `xargs` に任せる。シェルは指揮者であり、演奏者ではない。

### V7 UNIXのコマンド群——ツールボックスの中身

1979年のVersion 7 UNIXのマニュアル・セクション1（Commands）には、数百のコマンドが収録されていた。それぞれが独立したプログラムだ。

V7のコマンド群は、機能ごとに分類すると驚くほど体系的だ。

```
V7 UNIXのコマンド群（機能分類の例）:

  テキスト処理:  cat, head, tail, grep, sed, awk, sort,
                 uniq, wc, cut, paste, tr, comm, diff
  ファイル操作:  cp, mv, rm, ln, chmod, chown, find
  テキスト表示:  more, pr, fmt
  アーカイブ:    tar, cpio, ar
  プロセス管理:  ps, kill, nice, nohup
  通信:          mail, write, mesg
  開発:          cc, ld, make, yacc, lex
  シェル:        sh, test, expr, true, false
```

この一覧を眺めて気づくのは、各コマンドの守備範囲が明確に限定されていることだ。`cat` はファイルの連結だけ。`head` は先頭行の表示だけ。`tail` は末尾行の表示だけ。`grep` はパターン検索だけ。`sort` はソートだけ。`uniq` は重複除去だけ。`wc` は行数・語数・バイト数のカウントだけ。

一つ一つのコマンドは「些細」に見える。`cat` が単独でできることは、ファイルの内容を表示するだけだ。だがパイプラインの一段として組み込まれると、`cat` は「データをパイプラインに投入する」役割を果たす。`sort` と `uniq` を組み合わせると「ソートしてから重複を除去する」という機能が出現する。`grep` と `wc -l` を組み合わせると「パターンに一致する行を数える」という機能が出現する。

個々のツールは単純だ。だが組み合わせることで、どの単体ツールにも存在しない機能が創発する。この「創発」がUNIXの合成可能性の本質だ。

### 接着剤の設計パターン

シェルが「接着剤」として提供する接続パターンは、以下のように整理できる。

```
シェルの接続パターン:

  1. パイプライン（逐次合成）
     cmd1 | cmd2 | cmd3
     前段の stdout → 後段の stdin

  2. 条件付き実行（AND/OR）
     cmd1 && cmd2     # cmd1成功なら cmd2実行
     cmd1 || cmd2     # cmd1失敗なら cmd2実行

  3. リダイレクト（入出力の差し替え）
     cmd < input.txt          # stdinをファイルに差し替え
     cmd > output.txt         # stdoutをファイルに差し替え
     cmd 2> error.log         # stderrをファイルに差し替え
     cmd > output.txt 2>&1    # stdoutとstderrを統合

  4. コマンド置換（出力の値化）
     result=$(cmd)            # cmdの出力を変数に格納
     echo "Count: $(wc -l < file)"

  5. プロセス置換（出力のファイル化）
     diff <(cmd1) <(cmd2)     # 二つのコマンドの出力を比較

  6. xargs（出力の引数化）
     find . -name "*.log" | xargs grep "ERROR"
```

これらのパターンはそれぞれ、異なる種類の「合成」を実現する。パイプラインはデータの逐次変換。条件付き実行はエラーに基づく分岐。リダイレクトは入出力先の柔軟な切り替え。コマンド置換は出力結果の変数への取り込み。プロセス置換は複数のコマンドの出力をファイルとして扱う。xargsは出力をコマンドの引数に変換する。

シェルは、これらの接続パターンを通じて、独立したコマンド群を一つの処理パイプラインとして統合する。コマンドの設計者はシェルの存在を意識する必要はない。stdin/stdout/stderrの規約に従い、テキスト行を入出力し、終了コードを返しさえすれば、シェルが自動的に「接着」してくれる。

---

## 5. 合成可能性の思想的系譜——関数合成からマイクロサービスまで

### UNIXパイプと関数合成

UNIXのパイプラインは、数学的には関数合成（function composition）に対応する。

パイプライン `cmd1 | cmd2 | cmd3` は、三つの関数 `cmd1`、`cmd2`、`cmd3` を合成して一つの関数を作ることに等しい。入力 `x` に対して `cmd3(cmd2(cmd1(x)))` を計算する。

この構造は、関数型プログラミングの世界で「パイプ演算子」`|>` として形式化された。F#、OCaml、Elm、Elixir、Gleamなどの言語がこの演算子を採用している。

```
UNIXパイプと関数型プログラミングの |> :

  UNIX:
    cat data.txt | grep "error" | sort | uniq -c | sort -rn

  Elixir:
    data
    |> String.split("\n")
    |> Enum.filter(&String.contains?(&1, "error"))
    |> Enum.sort()
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_, count} -> -count end)
```

`|>` 演算子は、UNIXの `|` と同じく「左の式の出力を右の関数の入力に渡す」操作だ。データが左から右へ流れていく。この「左から右への流れ」は、UNIXのパイプラインを読む経験と同一だ。

さらに深い接点がある。Oleg Kiselyovは、UNIXのパイプをHaskellのIOモナドとして形式化できることを示した。モナドの `>>=`（bind）演算子は、「前の計算の結果を次の計算に渡す」操作だ。パイプの `|` と構造的に同型だ。

```
モナドの >>= とUNIXパイプの |:

  Haskell (IOモナド):
    readFile "data.txt" >>= return . lines >>= return . filter (isInfixOf "error")

  UNIX:
    cat data.txt | grep "error"

  どちらも「前の計算の出力を次の計算の入力に渡す」
```

ただし、UNIXのパイプとモナドの間には決定的な違いがある。モナドは型安全だ。Haskellのコンパイラは、型の合わない関数の合成をコンパイル時に拒否する。一方、UNIXのパイプは型なしテキストストリームを流す。型の不整合は実行時にしか発見できず、しかも多くの場合、無言で不正な結果を生む。

合成可能性という概念は同じだ。だがその実現方法は、UNIXのテキストストリームモデルと関数型プログラミングの型安全モデルで大きく異なる。UNIXは柔軟さを取り、関数型言語は安全性を取った。どちらが正しいかではない。どちらの合成可能性が、どの場面で適切かという問題だ。

### マイクロサービスにおける合成可能性

UNIXの合成可能性の設計条件は、マイクロサービスアーキテクチャにそのまま対応する。

2014年5月、RedMonkのDonnie Berkholzは「Microservices and the migrating Unix philosophy」と題した記事で、UNIXの設計哲学とマイクロサービスの構造的類似を論じた。両者の対応関係を整理する。

```
UNIXの合成可能性  →  マイクロサービスの合成可能性

条件1: stdin/stdout        →  HTTP API / gRPC / メッセージキュー
       統一的なインタフェース    統一的な通信プロトコル

条件2: テキスト行指向      →  JSON / Protocol Buffers
       共通のデータ形式         標準化されたデータ形式

条件3: 終了コード          →  HTTPステータスコード / エラーレスポンス
       エラー伝播のプロトコル   エラー伝播のプロトコル

条件4: 副作用の最小化      →  ステートレスなサービス設計
       純粋なフィルタ          単一責務・疎結合
```

UNIXのパイプラインでは、`grep` は `sort` の存在を知らない。`sort` は `uniq` の存在を知らない。各コマンドはstdin/stdoutという統一的なインタフェースを通じて、暗黙的に協調する。

マイクロサービスでも同じ構造が成り立つ。認証サービスは注文サービスの存在を知らない。注文サービスは在庫サービスの存在を知らない。各サービスはAPIという統一的なインタフェースを通じて、疎結合に協調する。

だが決定的な違いもある。UNIXのパイプラインは同一マシン上で同期的に動く。パイプのバッファは高々数十キロバイトであり、遅延はナノ秒オーダーだ。一方、マイクロサービスはネットワーク越しに非同期で動く。遅延はミリ秒オーダーであり、ネットワーク分断・タイムアウト・部分障害という分散システム固有の困難が付きまとう。

UNIXのパイプが「失敗」するのは、コマンドがエラー終了コードを返すときだ。この失敗は決定的であり、再現可能だ。だがマイクロサービスの「失敗」は非決定的だ。同じリクエストが、ある瞬間には成功し、次の瞬間にはタイムアウトする。リトライ、サーキットブレーカー、バルクヘッド——これらの耐障害パターンは、UNIXのパイプラインには不要だった。

合成可能性の「原則」は50年間変わっていない。統一的なインタフェース。共通のデータ形式。エラー伝播のプロトコル。副作用の最小化。だが合成が行われる「環境」——同一マシンかネットワーク越しか、同期か非同期か、決定的か非決定的か——は根本的に変わった。原則を継承することと、原則が適用される文脈を理解することは、別の問題だ。

---

## 6. ハンズオン：合成可能なCLIツールを設計する

ここからは手を動かす。合成可能性の四条件——stdin/stdout/stderr、テキスト行指向、終了コード、副作用の最小化——を実際に守ったCLIツールを設計・実装し、パイプラインに組み込む体験をする。

### 環境構築

```bash
docker run -it --rm ubuntu:24.04 bash
```

コンテナ内で必要なツールを用意する。

```bash
apt-get update && apt-get install -y coreutils gawk
```

### 演習1：合成可能性の四条件を確認する

まず、既存のUNIXコマンドが四条件をどう満たしているか確認する。

```bash
# サンプルデータを作成
cat << 'EOF' > /tmp/servers.txt
web01 192.168.1.10 running 45
web02 192.168.1.11 running 72
db01 192.168.1.20 stopped 0
web03 192.168.1.12 running 91
db02 192.168.1.21 running 38
cache01 192.168.1.30 running 65
web04 192.168.1.13 stopped 0
EOF

# 条件1: stdin/stdout -- パイプで接続できる
cat /tmp/servers.txt | grep "running" | awk '{print $1, $4}' | sort -k2 -rn

# 条件2: テキスト行指向 -- 行単位で処理される
cat /tmp/servers.txt | head -3
cat /tmp/servers.txt | tail -3

# 条件3: 終了コード -- 成功/失敗が伝播する
grep "running" /tmp/servers.txt > /dev/null
echo "Exit code: $?"  # 0 (パターンが見つかった)

grep "maintenance" /tmp/servers.txt > /dev/null
echo "Exit code: $?"  # 1 (パターンが見つからなかった)

# 条件4: 副作用の最小化 -- grepは入力ファイルを変更しない
md5sum /tmp/servers.txt
grep "running" /tmp/servers.txt > /dev/null
md5sum /tmp/servers.txt  # ハッシュが同一 = ファイル未変更
```

### 演習2：合成可能なフィルタをシェル関数で作る

合成可能性の四条件を守ったフィルタをシェル関数として実装する。

```bash
# フィルタ1: CPU使用率が閾値を超えるサーバを抽出
# stdin: "name ip status cpu_percent" 形式のテキスト行
# stdout: 閾値を超えた行のみ
# stderr: エラーメッセージ
# 終了コード: 0=該当行あり, 1=該当行なし
high_cpu() {
    local threshold="${1:-80}"
    local found=0
    while IFS= read -r line; do
        cpu=$(echo "$line" | awk '{print $4}')
        if [ "$cpu" -gt "$threshold" ] 2>/dev/null; then
            echo "$line"
            found=1
        fi
    done
    return $((1 - found))
}

# フィルタ2: サーバ名とCPU使用率だけを抽出してフォーマット
# stdin: "name ip status cpu_percent" 形式のテキスト行
# stdout: "name cpu_percent%" 形式のテキスト行
format_cpu() {
    awk '{printf "%s\t%s%%\n", $1, $4}'
}

# フィルタ3: アラートメッセージを生成
# stdin: テキスト行
# stdout: "[ALERT] " プレフィックス付きの行
add_alert_prefix() {
    sed 's/^/[ALERT] /'
}

# パイプラインで組み合わせる
cat /tmp/servers.txt | grep "running" | high_cpu 60 | format_cpu | add_alert_prefix
```

各フィルタが四条件を満たしていることを確認する。`high_cpu` はstdinから読み、stdoutに書き、テキスト行を処理し、該当行の有無を終了コードで返す。`format_cpu` は純粋な変換を行い、副作用がない。`add_alert_prefix` も同様だ。

### 演習3：終了コードの活用

終了コードがパイプラインの制御にどう使われるかを体験する。

```bash
# パイプラインの終了コードはデフォルトでは最後のコマンドの終了コード
false | true
echo "Exit code: $?"  # 0 (trueの終了コード)

# set -o pipefail でパイプライン全体の終了コードを制御
set -o pipefail
false | true
echo "Exit code: $?"  # 1 (falseの終了コードが伝播)

# 実用例: grepが見つからなかった場合にスクリプトを停止
set -euo pipefail

# "maintenance" は存在しないので grep は終了コード1を返す
# set -e により、スクリプトはここで停止する
# grep "maintenance" /tmp/servers.txt | wc -l
# echo "This line is not reached"

# 安全な方法: grep の失敗を許容する
grep "maintenance" /tmp/servers.txt | wc -l || true
echo "This line IS reached"

set +euo pipefail  # 演習用にリセット
```

### 演習4：stderrの正しい使い方

stderrをデータとエラーの分離にどう活用するかを実践する。

```bash
# 悪い例: エラーメッセージをstdoutに出力するスクリプト
bad_filter() {
    while IFS= read -r line; do
        cpu=$(echo "$line" | awk '{print $4}')
        if [ "$cpu" -gt 80 ] 2>/dev/null; then
            echo "$line"
        fi
        # 悪い: 処理状況をstdoutに出力
        echo "Processing: $line"  # これがパイプラインを壊す
    done
}

# 良い例: エラーメッセージをstderrに出力するスクリプト
good_filter() {
    while IFS= read -r line; do
        cpu=$(echo "$line" | awk '{print $4}')
        if [ "$cpu" -gt 80 ] 2>/dev/null; then
            echo "$line"
        fi
        # 良い: 処理状況をstderrに出力
        echo "Processing: $line" >&2  # stderrなのでパイプラインに影響しない
    done
}

# 悪い例: stdoutが汚染される
echo "--- bad_filter ---"
cat /tmp/servers.txt | bad_filter | wc -l  # 行数が多すぎる

# 良い例: stdoutは純粋なデータのみ
echo "--- good_filter ---"
cat /tmp/servers.txt | good_filter | wc -l  # 正しい行数
# ※ stderrの "Processing: ..." は端末に表示されるが、パイプラインには流れない
```

### 演習5：シェルの接続パターンを活用する

シェルが提供する多様な接続パターンを使い、より複雑な合成を行う。

```bash
# プロセス置換: 二つのコマンドの出力を比較
# runningなサーバとstoppedなサーバを並べて比較
diff <(grep "running" /tmp/servers.txt | awk '{print $1}') \
     <(grep "stopped" /tmp/servers.txt | awk '{print $1}')

# xargs: 出力を引数に変換
# stoppedなサーバのIPアドレスを取得して、各IPにpingを試みる
grep "stopped" /tmp/servers.txt | awk '{print $2}' | xargs -I{} echo "Would ping: {}"

# コマンド置換: 出力を変数に格納
running_count=$(grep -c "running" /tmp/servers.txt)
total_count=$(wc -l < /tmp/servers.txt)
echo "Running: $running_count / $total_count"

# tee: パイプラインの途中経過を分岐して保存
cat /tmp/servers.txt | grep "running" | tee /tmp/running_servers.txt | wc -l
echo "Saved to /tmp/running_servers.txt:"
cat /tmp/running_servers.txt
```

### 演習6：合成可能なツールの実践的な組み立て

最後に、合成可能な小さなツールを組み合わせて、実用的なデータ処理パイプラインを構築する。

```bash
# サンプルのアクセスログを作成
cat << 'EOF' > /tmp/access.log
2026-01-15 10:00:01 192.168.1.10 GET /index.html 200 1234
2026-01-15 10:00:02 192.168.1.20 GET /about.html 200 5678
2026-01-15 10:00:03 192.168.1.10 POST /api/data 201 90
2026-01-15 10:00:04 192.168.1.30 GET /index.html 200 1234
2026-01-15 10:00:05 192.168.1.10 GET /style.css 200 456
2026-01-15 10:00:06 192.168.1.20 GET /index.html 304 0
2026-01-15 10:00:07 192.168.1.10 GET /favicon.ico 404 0
2026-01-15 10:00:08 192.168.1.30 GET /about.html 200 5678
2026-01-15 10:00:09 192.168.1.10 GET /api/users 500 0
2026-01-15 10:00:10 192.168.1.40 GET /index.html 200 1234
EOF

# タスク1: エラー応答（4xx, 5xx）を返したリクエストのIPアドレスと
#          パスを集計し、頻度順に表示
echo "=== Error Requests ==="
awk '$6 >= 400 {print $3, $5}' /tmp/access.log | sort | uniq -c | sort -rn

# タスク2: IPアドレスごとの転送バイト数を集計
echo ""
echo "=== Bytes per IP ==="
awk '{bytes[$3] += $7} END {for (ip in bytes) print ip, bytes[ip]}' /tmp/access.log | sort -k2 -rn

# タスク3: 複数のフィルタを組み合わせた高度なパイプライン
# "200以外のステータスコードを返したリクエストを
#  時刻・IP・パス・ステータスの表形式で出力"
echo ""
echo "=== Non-200 Requests ==="
echo "TIME            IP              PATH            STATUS"
echo "----            --              ----            ------"
awk '$6 != 200 {printf "%-15s %-15s %-15s %s\n", $2, $3, $5, $6}' /tmp/access.log
```

---

## 7. まとめと次回予告

### この回の要点

- UNIXのコマンドが「組み合わせて使える」のは偶然ではなく、設計上の規約が守られているからだ。Doug McIlroyは1978年のBell System Technical Journalの序文で、この規約を最初に文書化した。「あらゆるプログラムの出力が、まだ見ぬ別のプログラムの入力になることを想定せよ」——この一文が合成可能性の核心だ

- Brian Kernighanは『Software Tools』（1976年、P.J. Plaugerとの共著）で、合成可能なツール設計を具体的なプログラムで実践した。Peter Salus（1994年）、Mike Gancarz（1995年）、Eric Raymond（2003年）がUNIX哲学を体系化し、合成可能性に関連するルール——Rule of Composition、Rule of Silence、Rule of Repair——を明文化した

- 合成可能性の設計条件は四つに集約できる。(1) 統一的なインタフェース——stdin/stdout/stderrの三つのストリーム。(2) テキスト行指向の入出力——改行で区切られた行が共通のデータ単位。(3) 終了コードによるエラー伝播——0が成功、非ゼロが失敗。(4) 副作用の最小化——フィルタはstdinから読みstdoutに書き、それ以外のことをしない

- stderrは「美学」ではなく「実用上の痛み」から生まれた。Bell Labsの写植機でエラーメッセージが美しく印字されてしまう惨事が、データとエラーのストリーム分離を動機づけた。合成可能性の設計は、理論からではなく、現場の苦痛から発展した

- シェルはコマンドを「接着」する役割を担う。パイプ、リダイレクト、条件付き実行、コマンド置換、プロセス置換、xargs——これらの接続パターンを通じて、独立したコマンド群を一つの処理パイプラインとして統合する。コマンドの設計者はシェルの存在を意識する必要がない。四条件を守れば、シェルが自動的に接着する

### 冒頭の問いへの暫定回答

「『組み合わせて使う』ために、個々のツールはどう設計されるべきなのか？」

暫定的な答えはこうだ。合成可能なツールは、四つの規約に従う。統一的なインタフェース（stdin/stdout/stderr）でデータを受け渡す。テキスト行指向で入出力する。成功・失敗を終了コードで報告する。副作用を最小限に抑える。この四つの規約は、1978年にMcIlroyが定式化し、Kernighan、Gancarz、Raymondが体系化した。

だがこの規約は「十分条件」ではない。規約に従うだけでは、良いツールにはならない。規約に従った上で、各ツールが「一つのことをうまくやる」必要がある。`grep` がファイル検索とソートと集計を全部やるツールだったら、合成可能であっても使いにくい。合成可能性と単一責務は表裏一体だ。単一責務であるから組み合わせる意味がある。組み合わせられるから単一責務でいられる。

そしてこの規約は、50年後の今も有効だ。マイクロサービスのAPI設計では、統一的なプロトコル（HTTP/gRPC）、標準化されたデータ形式（JSON/Protocol Buffers）、エラー伝播の仕組み（HTTPステータスコード）、ステートレスな設計——UNIXの四条件がそのまま適用される。文脈は変わった。ローカルのパイプラインからネットワーク越しの分散システムへ。だが合成可能性の「条件」は変わっていない。

あなたが設計しているAPIは、合成可能だろうか。そのエンドポイントの出力は、「まだ見ぬ別のサービス」の入力になることを想定しているだろうか。エラーはデータと分離されているだろうか。McIlroyの問いかけは、1978年から変わっていない。

### 次回予告

次回は「BSDとSystem V——分裂の始まり」。UNIXは一つにまとまれなかった。1977年のBSD（Berkeley Software Distribution）の誕生から、AT&T System V（1983年）との対立、「UNIX Wars」の時代へ。BSD系とSystem V系で `ps aux` と `ps -ef` が異なるのはなぜか。ソケットとSTREAMSの設計思想はどう違ったのか。分裂は技術を弱めたのか、それとも競争が技術を鍛えたのか。

UNIX哲学の「基本原則」を語り終えた今、歴史は次の段階——その原則を巡る政治と分裂の時代——に入る。

---

## 参考文献

- M.D. McIlroy, E.N. Pinson, B.A. Tague, "UNIX Time-Sharing System: Foreword", Bell System Technical Journal, Vol. 57, No. 6, pp.1899-1904, July-August 1978: <https://archive.org/details/bstj57-6-1899>
- Brian W. Kernighan, P. J. Plauger, "Software Tools", Addison-Wesley, 1976
- Brian W. Kernighan, P. J. Plauger, "Software Tools in Pascal", Addison-Wesley, 1981
- Brian W. Kernighan, Rob Pike, "The UNIX Programming Environment", Prentice Hall, 1984: <https://www.cs.princeton.edu/~bwk/upe/upe.html>
- Peter H. Salus, "A Quarter Century of UNIX", Addison-Wesley, 1994
- Mike Gancarz, "The UNIX Philosophy", Digital Press, 1995
- Eric S. Raymond, "The Art of UNIX Programming", Addison-Wesley, 2003: <http://www.catb.org/esr/writings/taoup/html/>
- Diomidis Spinellis, "The Birth of Standard Error", blog, December 11, 2013: <https://www.spinellis.gr/blog/20131211/index.html>
- Standard streams - Wikipedia: <https://en.wikipedia.org/wiki/Standard_streams>
- Exit status - Wikipedia: <https://en.wikipedia.org/wiki/Exit_status>
- Unix philosophy - Wikipedia: <https://en.wikipedia.org/wiki/Unix_philosophy>
- Bourne shell - Wikipedia: <https://en.wikipedia.org/wiki/Bourne_shell>
- Oleg Kiselyov, "UNIX pipes as IO monads": <https://okmij.org/ftp/Computation/monadic-shell.html>
- Donnie Berkholz, "Microservices and the migrating Unix philosophy", RedMonk, May 20, 2014: <https://redmonk.com/dberkholz/2014/05/20/microservices-and-the-migrating-unix-philosophy/>
