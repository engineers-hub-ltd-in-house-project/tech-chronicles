# UNIXという思想

## ——パイプ、プロセス、ファイル――すべてはここから始まった

### 第4回：「"Do one thing and do it well"——単一責務の起源」

**連載「UNIXという思想——パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 「一つのことをうまくやれ」という原則がどのような文脈で生まれ、誰によって言語化されたのか
- Doug McIlroyの1978年の原典、Peter Salusの三原則、Eric Raymondの17のルールの系譜
- UNIXコマンド群——cat、grep、sort、uniq、wc、cut——の設計分析と責務の境界
- Robert C. Martinの単一責務原則（SRP）とUNIX哲学の接続と差異
- 単機能コマンドのパイプラインとPythonスクリプトの設計思想の違いを体験するハンズオン

---

## 1. 「スーパーツール」を作ろうとした日

2005年頃のことだ。私は、あるサーバ運用チームのために「なんでもできる」監視スクリプトを書いていた。

ログファイルを監視し、特定のパターンを検出し、集計し、レポートを生成し、閾値を超えたらメールで通知する。一つのシェルスクリプトの中に、すべてを詰め込んだ。ファイルの読み取り、正規表現マッチング、カウント処理、ソート、フォーマット整形、SMTP送信——1本のスクリプトに800行近い処理が入っていた。

最初のうちは動いた。だが要件が変わるたびに、スクリプトは肥大化した。「エラーだけでなくワーニングも拾いたい」「集計の粒度を時間単位から分単位にしたい」「通知先をメールだけでなくSlackにも」——要望が来るたびに条件分岐を足し、関数を追加し、グローバル変数が増殖した。3ヶ月後、そのスクリプトは私自身でも読めない代物になっていた。テストなど不可能だった。入力条件の組み合わせが多すぎて、どのパスを通るか予測できなかった。

ある夜、そのスクリプトを捨てて、同じ処理をUNIXコマンドのパイプラインで書き直した。

```bash
tail -f /var/log/syslog | grep -E 'error|warning' | \
  awk '{print $1, $2, $3, $5}' | sort | uniq -c | sort -rn
```

5つのコマンドを`|`で繋いだだけのワンライナーだ。それぞれのコマンドは、自分の仕事だけをしている。tailはファイルの末尾を読む。grepはパターンを探す。awkはフィールドを抽出する。sortは並べる。uniqは重複を数える。どのコマンドも、他のコマンドの存在を知らない。どのコマンドも、自分の入力がどこから来るかを気にしない。

私は800行のスクリプトを捨て、このワンライナーと、通知部分を独立させた小さなスクリプトを組み合わせた。メンテナンスは劇的に楽になった。grepのパターンを変えれば検索条件が変わる。awkのフィールド指定を変えれば出力形式が変わる。通知先を変えたければ、通知スクリプトだけを変える。800行のスクリプトでは不可能だった、部品単位での変更が可能になった。

「一つのことをうまくやれ」——UNIXの最も有名な原則を、私は痛みとともに学んだ。

だが、この原則は本当にソフトウェア設計の普遍的原則なのか。あらゆる場面で「一つのこと」に分割することが正しいのか。そもそも「一つのこと」とは何か。その境界は誰が、どうやって引くのか。

---

## 2. 「一つのことをうまくやれ」——原典を辿る

### McIlroyの1978年——UNIX哲学の最初の言語化

UNIX哲学として引用される文言の中で最も有名なものは、おそらくこれだろう。

> Write programs that do one thing and do it well. Write programs to work together. Write programs to handle text streams, because that is a universal interface.

「一つのことをうまくやるプログラムを書け。協調して動くプログラムを書け。テキストストリームを扱うプログラムを書け。なぜならそれが万能のインタフェースだから」——この三文は、Peter H. Salusが1994年の著書『A Quarter Century of UNIX』で、Doug McIlroyの思想を簡潔にまとめたものとして広く流布している。

だが原典は、1978年に遡る。

1978年7月、Bell System Technical Journal第57巻第6号がUNIX特集号として刊行された。Doug McIlroyは、E. N. PinsonおよびB. A. Tagueとともに、この特集号の序文（Foreword）を執筆した。序文はHenri Bergsonの引用から始まる。「知性とは……人工物を作る能力であり、特にツールを作るためのツールを作る能力である」。

そして、McIlroyはUNIXの「スタイル」を次のように記述した。

> (i) Make each program do one thing well. To do a new job, build afresh rather than complicate old programs by adding new "features".
>
> (ii) Expect the output of every program to become the input to another, as yet unknown, program. Don't clutter output with extraneous information. Avoid stringently columnar or binary input formats. Don't insist on interactive input.
>
> (iii) Design and build software, even operating systems, to be tried early, ideally within weeks. Don't hesitate to throw away the clumsy parts and rebuild them.
>
> (iv) Use tools in preference to unskilled help to lighten a programming task, even if you have to detour to build the tools and expect to throw some of them out after you've finished using them.

4つの原則だ。注目すべきは、最初の原則が「一つのことをうまくやれ」だけでは終わっていないことだ。「新しい仕事が来たら、古いプログラムに新しい"機能"を付け足して複雑にするのではなく、一から作り直せ」——この後半部分が、原典には含まれている。

私は、この後半部分こそが本質だと考えている。「一つのことをうまくやる」プログラムは、最初から一つのことだけを狙って作られる。既存のプログラムに機能を追加した結果、たまたま「一つのこと」に収まっているわけではない。設計時点で「このプログラムは何をやらないか」を決めているのだ。

2番目の原則も見逃せない。「すべてのプログラムの出力が、まだ存在しない別のプログラムの入力になることを期待せよ」——まだ存在しない（as yet unknown）。この一句が重要だ。プログラムを書く時点で、その出力を誰がどう使うかはわからない。だからこそ、出力に余計な情報を混ぜるな。厳密なカラム形式やバイナリ形式を強制するな。対話的入力を要求するな。

「一つのことをうまくやる」プログラムは、単に小さいだけではない。組み合わせ可能な形を備えている。入力を標準入力から受け取り、出力を標準出力に送り、エラーを標準エラー出力に送る。この規約に従うことで、まだ存在しないプログラムとの接続が可能になる。

### Peter Salusの三原則——蒸留された哲学

Peter H. Salusは歴史家であり言語学者だ。1994年に刊行された『A Quarter Century of UNIX』は、100人以上のUNIX関係者へのインタビューに基づくUNIX史の包括的記録である。この中でSalusは、McIlroyの4つの原則を3つに蒸留した。

1. Write programs that do one thing and do it well.
2. Write programs to work together.
3. Write programs to handle text streams, because that is a universal interface.

McIlroyの原則(iii)（早期にプロトタイプを作り、拙い部分は捨てて作り直せ）と原則(iv)（プログラマの負荷軽減にはツールを使え）が省略され、ソフトウェアの設計そのものに関わる3原則に絞り込まれている。

この蒸留には功罪がある。3原則は覚えやすく引用しやすい。だが、McIlroyの原典にあった「早期に試作し、拙い部分は捨てて作り直せ」という原則——今日のアジャイル開発やプロトタイピングの先駆と言える思想——が、UNIX哲学の「公式版」から落ちてしまった。

### Mike Gancarzの9原則——体系化の試み

Mike Gancarzは1995年に『The UNIX Philosophy』（Digital Press）を出版し、UNIX哲学をより体系的に整理した。9つの基本原則と10の副次原則を提示している。基本原則には次のようなものが含まれる。

- Small is beautiful（小さいものは美しい）
- Make each program do one thing well（各プログラムに一つのことをうまくやらせよ）
- Build a prototype as soon as possible（できるだけ早くプロトタイプを作れ）
- Choose portability over efficiency（効率より移植性を選べ）

Gancarzの貢献は、McIlroyが暗黙に前提としていた設計原則——「Small is beautiful」のような美学的原則——を明示化したことにある。「小さいものは美しい」は、「一つのことをうまくやれ」の前提条件だ。小さくなければ、「一つのこと」に集中することは難しい。

### Eric Raymondの17のルール——百科事典的整理

2003年、Eric S. Raymondは『The Art of UNIX Programming』（Addison-Wesley）を出版した。この本は、UNIX哲学の最も包括的な整理として知られている。Raymondは17のルールを提示した。

1. Rule of Modularity: Write simple parts connected by clean interfaces.
2. Rule of Clarity: Clarity is better than cleverness.
3. Rule of Composition: Design programs to be connected with other programs.
4. Rule of Separation: Separate policy from mechanism; separate interfaces from engines.
5. Rule of Simplicity: Design for simplicity; add complexity only where you must.
6. Rule of Parsimony: Write a big program only when it is clear by demonstration that nothing else will do.
7. Rule of Transparency: Design for visibility to make inspection and debugging easier.
8. Rule of Robustness: Robustness is the child of transparency and simplicity.
9. Rule of Representation: Fold knowledge into data, so program logic can be stupid and robust.
10. Rule of Least Surprise: In interface design, always do the least surprising thing.
11. Rule of Silence: When a program has nothing surprising to say, it should say nothing.
12. Rule of Repair: Repair what you can — but when you must fail, fail noisily and as soon as possible.
13. Rule of Economy: Programmer time is expensive; conserve it in preference to machine time.
14. Rule of Generation: Avoid hand-hacking; write programs to write programs when you can.
15. Rule of Optimization: Prototype before polishing. Get it working before you optimize it.
16. Rule of Diversity: Distrust all claims for one true way.
17. Rule of Extensibility: Design for the future, because it will be here sooner than you think.

17のルールは、McIlroyの4原則を様々な角度から照射したものだ。「一つのことをうまくやれ」は、Rule of Modularity（モジュール性）、Rule of Simplicity（単純性）、Rule of Parsimony（倹約）として多面的に表現されている。

ここまでの系譜を整理する。

| 年     | 人物         | 著作                        | 原則の数 |
| ------ | ------------ | --------------------------- | -------- |
| 1978年 | Doug McIlroy | BSTJ Foreword               | 4原則    |
| 1994年 | Peter Salus  | A Quarter Century of UNIX   | 3原則    |
| 1995年 | Mike Gancarz | The UNIX Philosophy         | 9原則+10 |
| 2003年 | Eric Raymond | The Art of UNIX Programming | 17ルール |

原則の数は増えている。だが核心は変わっていない。McIlroyが1978年に最初に書いた一文——「Make each program do one thing well」——が、25年間にわたって拡張され、注釈され、体系化されてきた。その一文の射程が、それだけ広かったということだ。

### Kernighan & Plauger——「ツールボックス」の実践

UNIX哲学の言語化において忘れてはならないのが、Brian W. KernighanとP. J. Plaugerによる『Software Tools』（Addison-Wesley、1976年）だ。この本はRatfor（Rational Fortran）という言語で書かれているが、その思想はUNIXそのものだ。

Kernighan & Plaugerが説いたのは「ツールボックスアプローチ」だ。プログラマは、アプリケーションごとにゼロからプログラムを書くのではなく、再利用可能な小さなプログラムを「標準ツール」として持ち、それを組み合わせて問題を解決する。各ツールは一つの仕事に特化し、他のツールと組み合わせ可能なインタフェースを備える。

1984年には、KernighanはRob Pikeとともに『The UNIX Programming Environment』（Prentice Hall）を出版し、この「ツールボックス」思想をUNIXのコマンド群とシェルの文脈で実践的に解説した。

これらの書籍は、McIlroyの原則を「どう実践するか」の文脈で世界に伝えた。原則を知ることと、原則を実践できることは別の能力だ。Kernighanの著作群は、その橋渡しを果たした。

---

## 3. UNIXコマンドの設計分析——「一つのこと」の境界はどこにあるか

UNIX哲学を語るとき、抽象的な原則だけでは不十分だ。具体的なコマンド群の設計を見ることで、「一つのこと」の境界がどこに引かれているかを理解できる。

### cat——連結する、それだけ

`cat`は「concatenate（連結する）」の略だ。Ken Thompsonが1969年にPDP-7のアセンブリ言語で最初の実装を書いた。Version 1 Unix（1971年）に収録された、最古のUNIXコマンドの一つだ。

catの仕事は、ファイルの内容を標準出力に出力することだ。複数のファイルが指定されれば、それらを連結して出力する。それだけだ。

```bash
cat file1.txt file2.txt    # 2つのファイルを連結して出力
cat < input.txt             # 標準入力から読んで標準出力に書く
```

catは行番号を振らない（GNU catには`-n`オプションがあるが、これは後年の拡張だ）。catは検索しない。catはソートしない。catは変換しない。catは「ファイルの中身を読んで出力する」という一つのことだけをやる。

ここで疑問が湧く。「ファイルの中身を読んで出力する」は本当に「一つのこと」なのか。「ファイルを読む」と「出力する」は二つの操作ではないか。

だが、UNIXの文脈では「標準入力から読んで標準出力に書く」は一つの原子操作だ。パイプラインの中では、すべてのプログラムがこの操作を行う。catの「一つのこと」は「入力を出力に中継する」——つまり、変換を伴わないデータの転送だ。

### grep——パターンにマッチする行を抽出する

`grep`はKen Thompsonが1973年に作成した。名前の由来は、edエディタのコマンド`g/re/p`（global / regular expression / print）だ。ThompsonはFederalist Papersの著者推定に関する統計分析のため、edでは処理できない大量のテキストから正規表現で行を抽出する独立ツールが必要になり、edの正規表現エンジンを独立したプログラムとして切り出した。

```bash
grep 'error' /var/log/syslog     # 'error'を含む行を抽出
grep -c 'error' /var/log/syslog  # マッチした行数だけ出力
grep -v 'debug' /var/log/syslog  # 'debug'を含まない行を抽出
```

grepの「一つのこと」は「パターンにマッチする行を抽出する」だ。grepは行を数えない——`-c`オプションは行数を返すが、これはgrepの内部で行を数えているだけであり、集計という独立した責務を担っているわけではない。grepは行をソートしない。grepはファイルを変更しない。grepは「探す」だけだ。

興味深いのは、grepの責務の境界だ。なぜgrepは「行を置換する」機能を持たないのか。正規表現でパターンをマッチさせるなら、マッチした部分を別の文字列に置換するのは自然な拡張に見える。だが、置換はsedの仕事だ。grepは「抽出」、sedは「変換」——責務の境界が、操作の種類（抽出 vs. 変換）によって引かれている。

### sort——行を並べ替える

`sort`は、標準入力または指定されたファイルの行をソートして標準出力に出力する。

```bash
sort file.txt                  # アルファベット順にソート
sort -n file.txt               # 数値としてソート
sort -k2,2 file.txt            # 第2フィールドでソート
sort -t',' -k3,3n file.txt     # カンマ区切りの第3フィールドを数値ソート
```

sortの「一つのこと」は「行を並べ替える」だ。sortは重複を除去しない——それはuniqの仕事だ。sortは行数を数えない——それはwcの仕事だ。sortは特定の行を抽出しない——それはgrepの仕事だ。

sortには多くのオプションがある。`-n`（数値ソート）、`-r`（逆順）、`-k`（フィールド指定）、`-t`（区切り文字指定）、`-u`（重複排除）。オプションが多いのは「一つのこと」に反しないか。反しない。これらのオプションはすべて「並べ替える」という一つの操作のバリエーションだ。何を基準にソートするか、どの方向にソートするか——操作の種類は変わらない。操作のパラメータが変わるだけだ。

### uniq——隣接する重複行を畳む

`uniq`の動作を正確に理解している人は、意外と少ない。

```bash
sort file.txt | uniq         # ソート済みの入力から重複行を除去
sort file.txt | uniq -c      # 各行の出現回数を付けて出力
sort file.txt | uniq -d      # 重複している行だけを出力
```

uniqは「隣接する重複行を畳む」コマンドであり、「全体からユニークな行を抽出する」コマンドではない。入力がソートされていなければ、離れた位置にある同一行を重複と見なさない。

なぜこのような限定的な設計なのか。理由は効率だ。ファイル全体からユニークな行を抽出するには、すべての行をメモリに保持するか、ファイルを複数回走査する必要がある。隣接行の比較だけなら、前の行を1行分記憶するだけでよい。メモリ消費は定数で、ファイルサイズに依存しない。

そして、入力をソートするのはsortの仕事だ。`sort | uniq`というパイプラインを組めば、全体からユニークな行を抽出できる。uniq単体では限定的な機能に見えるが、sortと組み合わせれば完全な機能になる。この「組み合わせて完全になる」設計こそが、UNIX哲学の本質だ。

### wc——数える、それだけ

```bash
wc -l file.txt     # 行数を数える
wc -w file.txt     # 単語数を数える
wc -c file.txt     # バイト数を数える
```

`wc`（word count）の「一つのこと」は「数える」だ。行数、単語数、バイト数——数え方のバリエーションはあるが、すべて「数える」という操作だ。

wcはファイルの中身を表示しない——それはcatの仕事だ。wcはパターンマッチしない——それはgrepの仕事だ。wcは並べ替えない——それはsortの仕事だ。

### cut——フィールドを切り出す

```bash
cut -d',' -f1,3 file.csv     # カンマ区切りの第1・第3フィールドを切り出す
cut -c1-10 file.txt           # 各行の1〜10文字目を切り出す
```

`cut`の「一つのこと」は「行の中からフィールドや文字位置を切り出す」だ。cutはフィールドを追加しない——それはpasteの仕事だ。cutはフィールドの値を変換しない——それはawk（またはsed、tr）の仕事だ。

### 責務の境界はどこに引かれているか

ここまでの分析を整理する。

```
┌──────────────────────────────────────────────────────────────┐
│              UNIXコマンドの責務マップ                         │
├──────────┬───────────────────────────────────────────────────┤
│ 操作     │ コマンド                                         │
├──────────┼───────────────────────────────────────────────────┤
│ 中継     │ cat  — 入力をそのまま出力に渡す                   │
│ 抽出     │ grep — パターンにマッチする行を取り出す           │
│ 並替     │ sort — 行を指定した基準で並べ替える               │
│ 重複除去 │ uniq — 隣接する重複行を畳む                       │
│ 計数     │ wc   — 行・単語・バイトを数える                   │
│ 切出     │ cut  — 行内のフィールド・文字位置を切り出す       │
│ 結合     │ paste — 複数ファイルの行を横に結合する            │
│ 変換     │ tr   — 文字単位の置換・削除                       │
│ 編集     │ sed  — ストリーム上で行単位の変換（置換、削除等） │
│ 処理     │ awk  — フィールド指向のパターン処理と計算         │
└──────────┴───────────────────────────────────────────────────┘
```

責務の境界は、**操作の種類**によって引かれている。「抽出」と「変換」は別の操作だ。「並べ替え」と「重複除去」は別の操作だ。「計数」と「切り出し」は別の操作だ。各コマンドは、一つの操作を担当する。

そしてsedとawkは、他のコマンドに比べて責務の範囲が広い。sedは行単位の変換全般を担い、awkはフィールド指向のパターン処理と計算を担う。これらは「スイスアーミーナイフ」的なツールであり、厳密な意味での「一つのこと」からはやや逸脱している。だが注意深く見ると、sedの責務は「ストリーム上での編集」であり、awkの責務は「フィールド指向のテキスト処理」だ。それぞれの中に複数の機能があるが、責務としては一つのドメインに収まっている。

「一つのこと」の粒度は、絶対的なものではない。catの粒度とawkの粒度は明らかに異なる。重要なのは、各コマンドが「何をやらないか」を明確に定義していることだ。grepは置換しない。sortは抽出しない。wcは変換しない。cutは結合しない。この「やらないことの明確さ」が、UNIXコマンドの組み合わせ可能性を支えている。

---

## 4. 単一責務原則（SRP）——24年後の再発明

### Robert C. Martinの定式化

2002年、Robert C. Martin（通称Uncle Bob）は『Agile Software Development, Principles, Patterns, and Practices』（Prentice Hall）を出版した。この書籍の第8章で、Martinは「単一責務原則（Single Responsibility Principle, SRP）」を定式化した。

> A class should have only one reason to change.
>
> クラスは変更する理由をただ一つだけ持つべきである。

McIlroyが1978年に「Make each program do one thing well」と書いてから、24年が経っていた。

McIlroyの原則は「プログラム」について語り、Martinの原則は「クラス」について語っている。McIlroyの原則はUNIXのコマンドラインツールの設計指針であり、Martinの原則はオブジェクト指向プログラミングの設計指針だ。文脈は異なる。だが、根底にある思想は同じだ。

「一つのことをうまくやれ」（McIlroy）と「変更する理由をただ一つだけ持て」（Martin）。前者は機能の集中を要求し、後者は変更の局所化を要求している。言い換えれば、McIlroyの原則は「何をするか」の観点から単一性を定義し、Martinの原則は「何が変わるか」の観点から単一性を定義している。

この違いは重要だ。UNIXの`grep`は「パターンマッチで行を抽出する」という一つの機能に集中している。だが、SRPの観点から見ると、grepの「変更理由」は複数ある。正規表現エンジンの改良、出力フォーマットの変更、パフォーマンスの最適化——これらは異なる「変更理由」だ。

つまり、McIlroyの「一つのこと」とMartinの「一つの理由」は、同じ方向を向いているが、同じものではない。McIlroyの原則はプログラム間の責務分割に焦点を当て、Martinの原則はプログラム内部のモジュール分割に焦点を当てている。UNIXコマンドの「一つのこと」は、SRPの「一つの理由」より粒度が大きい。

### マイクロサービスとの接続

McIlroyの原則が、24年後にMartinのSRPとして再発明されたとすれば、さらに12年後——2014年に、Martin FowlerとJames Lewisが「Microservices」の概念を明確化したとき——UNIX哲学は三度目の再発明を経験した。

マイクロサービスの基本原則は「一つのサービスは一つのビジネス機能を担う」だ。モノリシックなアプリケーションを、独立してデプロイ可能な小さなサービスに分割する。各サービスは独自のデータストアを持ち、APIを通じて他のサービスと通信する。

```
UNIXパイプライン         マイクロサービス
┌─────┐ │ ┌─────┐      ┌─────────┐ API ┌─────────┐
│ grep├─┤─┤ sort│      │ Service ├─────┤ Service │
└─────┘ │ └─────┘      │    A    │     │    B    │
  stdin  pipe stdout     └─────────┘     └─────────┘
```

`grep | sort`において、grepとsortはパイプ（標準入出力）で繋がれた独立したプロセスだ。マイクロサービスにおいて、Service AとService BはAPI（HTTP/gRPC）で繋がれた独立したサービスだ。

構造的なアナロジーは明白だ。だが、決定的な違いがある。UNIXのパイプラインは同一マシン上で同期的に動作する。マイクロサービスはネットワーク越しに非同期で動作する。ネットワークには遅延があり、分断があり、部分障害がある。UNIXのパイプが壊れれば`SIGPIPE`が飛ぶ。だがネットワーク越しのAPIが壊れたとき、呼び出し側がそれを知る方法は、タイムアウトを待つか、ヘルスチェックを行うか——いずれにしてもパイプほど単純ではない。

「一つのことをうまくやれ」という原則は、UNIXコマンドからオブジェクト指向のクラスへ、クラスからマイクロサービスへと、適用範囲を広げてきた。だが、適用範囲が広がるたびに、「組み合わせ」のコストは増大している。パイプの接続コストは無視できるほど小さい。APIの接続コストは、ネットワーク遅延、シリアライゼーション、認証、エラーハンドリングを含む。原則は普遍的でも、その実践のコストは文脈に依存する。

---

## 5. ハンズオン：パイプラインの設計思想を体感する

ここからは手を動かす。同じデータ処理タスクを、UNIXコマンドのパイプラインとPythonスクリプトの2通りで実装し、設計思想の違いを体感する。

### 環境構築

```bash
docker run -it --rm ubuntu:24.04 bash
```

コンテナ内で必要なツールを用意する。

```bash
apt-get update && apt-get install -y python3
```

### 課題：アクセスログの分析

以下の形式のアクセスログから、HTTPステータスコードごとの出現回数を集計し、出現回数の多い順に上位10件を表示する。

まず、サンプルデータを生成する。

```bash
cat << 'SCRIPT' > /tmp/gen_log.sh
#!/bin/bash
set -euo pipefail

METHODS=("GET" "POST" "PUT" "DELETE")
PATHS=("/api/users" "/api/posts" "/api/comments" "/health" "/api/auth/login" "/api/search" "/static/main.css" "/static/app.js")
CODES=(200 200 200 200 200 201 204 301 302 400 401 403 404 404 500 502 503)

for i in $(seq 1 10000); do
    method=${METHODS[$((RANDOM % ${#METHODS[@]}))]}
    path=${PATHS[$((RANDOM % ${#PATHS[@]}))]}
    code=${CODES[$((RANDOM % ${#CODES[@]}))]}
    ms=$((RANDOM % 2000))
    printf "2026-02-23T%02d:%02d:%02d %s %s %d %dms\n" \
        $((RANDOM % 24)) $((RANDOM % 60)) $((RANDOM % 60)) \
        "$method" "$path" "$code" "$ms"
done
SCRIPT
chmod +x /tmp/gen_log.sh
bash /tmp/gen_log.sh > /tmp/access.log
echo "生成完了: $(wc -l < /tmp/access.log) 行"
head -5 /tmp/access.log
```

### 演習1：UNIXパイプラインによる分析

```bash
# ステータスコードごとの出現回数（上位10件）
awk '{print $4}' /tmp/access.log | sort | uniq -c | sort -rn | head -10
```

このパイプラインを分解する。

```bash
# Step 1: awkで第4フィールド（ステータスコード）を抽出
awk '{print $4}' /tmp/access.log | head -5

# Step 2: sortでソート（uniqの前提条件）
awk '{print $4}' /tmp/access.log | sort | head -10

# Step 3: uniq -cで隣接重複行を畳み、出現回数を付ける
awk '{print $4}' /tmp/access.log | sort | uniq -c

# Step 4: sort -rnで出現回数の降順にソート
awk '{print $4}' /tmp/access.log | sort | uniq -c | sort -rn

# Step 5: head -10で上位10件に絞る
awk '{print $4}' /tmp/access.log | sort | uniq -c | sort -rn | head -10
```

5つのコマンドが、それぞれ一つの操作を担っている。awkは切り出す。sortは並べる。uniqは畳む。sortはまた並べる（今度は数値の降順で）。headは先頭を切る。各コマンドは、前のコマンドの出力が何であるかを知らない。ただ標準入力から行を読み、処理し、標準出力に書く。

### 演習2：Pythonスクリプトによる同じ分析

```bash
cat << 'EOF' > /tmp/analyze.py
"""アクセスログのステータスコード集計 — Python版"""
import sys
from collections import Counter

def main():
    counter = Counter()

    for line in sys.stdin:
        parts = line.strip().split()
        if len(parts) >= 4:
            status_code = parts[3]
            counter[status_code] += 1

    # 出現回数の降順でソートし、上位10件を表示
    for code, count in counter.most_common(10):
        print(f"{count:>7} {code}")

if __name__ == "__main__":
    main()
EOF
cat /tmp/access.log | python3 /tmp/analyze.py
```

Pythonスクリプトは1本で完結している。ファイルの読み取り、フィールドの抽出、カウント、ソート、フォーマット——すべてが一つのプログラムに内包されている。

### 演習3：設計思想の比較

両者を並べて比較する。

```bash
echo "=== UNIXパイプライン ==="
time (awk '{print $4}' /tmp/access.log | sort | uniq -c | sort -rn | head -10)

echo ""
echo "=== Pythonスクリプト ==="
time (cat /tmp/access.log | python3 /tmp/analyze.py)
```

性能の差もさることながら、注目すべきは設計思想の差だ。

```
UNIXパイプライン          Pythonスクリプト
┌─────┐                  ┌────────────────────────┐
│ awk │─→ 切り出し       │                        │
└──┬──┘                  │  切り出し              │
   │                     │    ↓                   │
┌──▼──┐                  │  カウント              │
│sort │─→ 並べ替え       │    ↓                   │
└──┬──┘                  │  ソート                │
   │                     │    ↓                   │
┌──▼──┐                  │  フォーマット          │
│uniq │─→ 重複除去+計数  │                        │
└──┬──┘                  └────────────────────────┘
   │                      一つのプログラムに
┌──▼──┐                  すべてが内包されている
│sort │─→ 再ソート
└──┬──┘
   │
┌──▼──┐
│head │─→ 先頭切り出し
└─────┘
5つの独立プロセスが
パイプで接続されている
```

UNIXパイプラインでは、各コマンドが独立したプロセスとして並行動作する。awkがファイルを読み始めた瞬間から、sortはawkの出力を待ち受けている。データはパイプを通じてストリーミングされ、各プロセスは自分の処理に集中する。

Pythonスクリプトでは、すべてが逐次的に一つのプロセス内で実行される。`Counter`がメモリ上にすべてのカウント結果を保持し、`most_common()`がソートを行い、ループがフォーマットと出力を担う。

どちらが「正しい」かという問いは無意味だ。UNIXパイプラインは組み合わせの柔軟性に優れている。「ステータスコードではなくHTTPメソッドで集計したい」なら、awkのフィールド番号を変えるだけでよい。Pythonスクリプトの場合は、コードを編集して再実行する必要がある。

一方、Pythonスクリプトは複雑な処理ロジック——条件分岐、エラーハンドリング、複数のデータソースの結合——を表現しやすい。パイプラインでは困難な「状態を持つ処理」も、Pythonなら自然に書ける。

### 演習4：パイプラインの応用——複数の分析を組み合わせる

UNIXパイプラインの真の強みは、同じデータに対して異なる分析を素早く試行できることにある。

```bash
echo "--- ステータスコード別集計 ---"
awk '{print $4}' /tmp/access.log | sort | uniq -c | sort -rn

echo ""
echo "--- HTTPメソッド別集計 ---"
awk '{print $2}' /tmp/access.log | sort | uniq -c | sort -rn

echo ""
echo "--- エンドポイント別エラー率（4xx/5xx） ---"
awk '$4 >= 400 {print $3}' /tmp/access.log | sort | uniq -c | sort -rn | head -5

echo ""
echo "--- 時間帯別リクエスト数（時間単位） ---"
cut -dT -f2 /tmp/access.log | cut -d: -f1 | sort | uniq -c | sort -k2

echo ""
echo "--- レスポンスタイム1000ms超のリクエスト ---"
awk '{gsub(/ms/,"",$5); if($5+0 > 1000) print $2, $3, $4, $5"ms"}' /tmp/access.log | head -10
```

5種類の分析を、すべて同じコマンド群の組み合わせで実現している。`awk`の抽出条件を変え、`sort`のキーを変え、`head`の件数を変える。部品は同じだ。組み合わせが変わるだけだ。

Pythonで同じことをするには、5つの関数を書くか、5つのスクリプトを書く必要がある。UNIXのコマンド群は、「既に書かれたライブラリ」のように機能する。ただし、そのライブラリのインタフェースは関数呼び出しではなく、標準入出力とテキストストリームだ。

---

## 6. まとめと次回予告

### この回の要点

- Doug McIlroyは1978年のBell System Technical Journalの序文で、UNIX哲学を初めて文書化した。「Make each program do one thing well. To do a new job, build afresh rather than complicate old programs by adding new 'features'.」——この原則の後半部分「古いプログラムに新機能を足して複雑にするな」が、しばしば忘れられている

- McIlroyの4原則（1978年）→ Salusの3原則（1994年）→ Gancarzの9原則（1995年）→ Raymondの17ルール（2003年）。25年にわたって拡張・体系化されてきたが、核心は変わっていない。「一つのことをうまくやれ」

- UNIXコマンドの責務の境界は「操作の種類」によって引かれている。catは中継、grepは抽出、sortは並べ替え、uniqは重複除去、wcは計数、cutは切り出し。各コマンドは「何をやらないか」を明確に定義しており、その明確さが組み合わせ可能性を支えている

- Robert C. Martinの単一責務原則（SRP、2002年）はUNIXの「Do one thing well」の再発明的側面を持つが、McIlroyが「何をするか」の観点から単一性を定義したのに対し、Martinは「何が変わるか」の観点から定義した。適用のスケールも異なる——プログラム間の分割 vs. プログラム内部のモジュール分割

- マイクロサービスは「一つのことをうまくやれ」の三度目の具現化だが、ネットワーク越しの組み合わせはパイプよりはるかに高コストである。原則は普遍的でも、実践のコストは文脈に依存する

### 冒頭の問いへの暫定回答

「"一つのことをうまくやれ"——この原則は本当にソフトウェア設計の普遍的原則なのか？」

暫定的な答えはこうだ。普遍的だ。だが、「一つのこと」の粒度は普遍的ではない。UNIXコマンドの「一つのこと」は「一つの操作」だ。SRPの「一つのこと」は「一つの変更理由」だ。マイクロサービスの「一つのこと」は「一つのビジネス機能」だ。同じ原則でも、適用する文脈によって「一つ」の意味が変わる。

そして、「一つのこと」の設計には、もう一つの面がある。「何をやるか」を決めることより、「何をやらないか」を決めることの方が難しい。grepが置換機能を持たないのは、持てなかったからではない。持たないと決めたからだ。UNIXコマンドの設計の優れた点は、各コマンドが「やらないこと」を明確に意識していることにある。

あなたが次にプログラムを設計するとき、「このプログラムは何をするか」だけでなく、「このプログラムは何をしないか」を考えてほしい。その問いが、組み合わせ可能な設計への第一歩だ。

### 次回予告

次回は「パイプとフィルタ——ソフトウェア合成の原点」。今回は「一つのことをうまくやれ」という原則を掘り下げた。だが、単機能のプログラムは、それだけでは価値を生まない。プログラムとプログラムを繋ぎ、組み合わせて新しい機能を生み出す仕組みが必要だ。それがパイプだ。

Doug McIlroyが1964年にパイプのアイデアを提案し、1973年にKen Thompsonが一晩の熱狂的な作業で実装した。パイプの内部動作——カーネル内のバッファ、ファイルディスクリプタの接続、プロセスの並行実行——をstraceで観察する。名前付きパイプ（FIFO）によるプロセス間通信を体験する。そして、パイプという「合成」の原型が、関数合成からETLパイプラインまで、どのように形を変えて生き続けているかを辿る。

`cat file | grep pattern` と `grep pattern file` は同じ結果を返す。だがこの二つには、設計思想の根本的な違いがある。あなたには、その違いが見えるだろうか。

---

## 参考文献

- M.D. McIlroy, E.N. Pinson, B.A. Tague, "UNIX Time-Sharing System: Foreword", The Bell System Technical Journal, Vol. 57, No. 6, Part 2, July-August 1978, pp. 1902-1903: <https://archive.org/details/bstj57-6-1899>
- Peter H. Salus, "A Quarter Century of UNIX", Addison-Wesley, 1994, ISBN 0-201-54777-5
- Mike Gancarz, "The UNIX Philosophy", Digital Press, 1995, ISBN 978-1-55558-123-7
- Eric S. Raymond, "The Art of UNIX Programming", Addison-Wesley, 2003: <http://www.catb.org/esr/writings/taoup/html/>
- Robert C. Martin, "Agile Software Development, Principles, Patterns, and Practices", Prentice Hall, 2002
- Brian W. Kernighan, P. J. Plauger, "Software Tools", Addison-Wesley, 1976
- Brian W. Kernighan, Rob Pike, "The UNIX Programming Environment", Prentice Hall, 1984
- cat (Unix) — Wikipedia: <https://en.wikipedia.org/wiki/Cat_(Unix)>
- Two-Bit History, "The Source History of Cat", 2018: <https://twobithistory.org/2018/11/12/cat.html>
- grep — Wikipedia: <https://en.wikipedia.org/wiki/Grep>
- Brian Kernighan Remembers the Origins of 'grep' — The New Stack: <https://thenewstack.io/brian-kernighan-remembers-the-origins-of-grep/>
- sed — Wikipedia: <https://en.wikipedia.org/wiki/Sed>
- AWK — Wikipedia: <https://en.wikipedia.org/wiki/AWK>
- Single-responsibility principle — Wikipedia: <https://en.wikipedia.org/wiki/Single-responsibility_principle>
- Unix philosophy — Wikipedia: <https://en.wikipedia.org/wiki/Unix_philosophy>
