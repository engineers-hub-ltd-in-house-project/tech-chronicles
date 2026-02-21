# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第10回：UNIX哲学の功罪――「一つのことをうまくやれ」は本当に正しいか

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Doug McIlroyが1978年に文書化したUNIX哲学の原典とその歴史的文脈
- Peter Salusの3行要約とEric Raymondの17のルール――「UNIX哲学」の変遷と膨張
- Rob Pikeの5つのルールとKen Thompsonの "When in doubt, use brute force"
- Plan 9が推し進めた「UNIX哲学の極限」――per-process namespacesと9P
- テキストストリームの構造的限界――スキーマレスなデータ形式の功罪
- パイプラインのエラー処理問題と `set -o pipefail` の不完全さ
- Jeffrey Snoverの「Monad Manifesto」――テキストパースへの根本批判
- jq、yq、Nushell――構造化データパイプラインという回答

---

## 1. 「芸術的だが読めない」ワンライナー

2000年代後半のある日、私はサーバのログ分析のために、こんなワンライナーを書いた。

```bash
find . -name "*.log" -mtime -7 -exec grep -l "ERROR" {} \; | xargs grep -c "ERROR" | sort -t: -k2 -rn | head -20
```

意味はこうだ。過去7日以内に更新されたログファイルから "ERROR" を含むものを探し、各ファイルのERROR出現回数をカウントし、多い順にソートして上位20件を表示する。UNIX的な「小さなツールをパイプでつなぐ」哲学の教科書的な実践だ。

当時の私は、このワンライナーに一種の美学を感じていた。一つひとつのコマンドはシンプルで、それぞれが「一つのこと」をうまくやっている。`find`はファイルを見つけ、`grep`はパターンを探し、`sort`は並べ替え、`head`は先頭を切り出す。組み合わせの美しさ。UNIX哲学の体現だ。

だが、三ヶ月後に同じワンライナーを見返したとき、私は自分が書いたものを理解するのに数分を要した。`-exec {} \;` の意味は覚えていても、なぜ `-mtime -7` が「7日以内」なのか（`-7` はマイナスではなく「7より小さい」を意味する）を即座に思い出せなかった。`sort -t: -k2 -rn` がコロン区切りの第2フィールドを数値降順でソートすることを、他の人間が一目で読み取れるだろうか。

決定的だったのは、後輩エンジニアの一言だ。彼はサーバのJSON形式のログを分析する場面で、私に聞いた。

「佐藤さん、なぜjqで一発なのにsed/awk三段で書くんですか」

彼の言う通りだった。構造化されたJSONログを `sed` と `awk` でテキストとして解体し、必要な情報を抽出するより、`jq` でキーを指定して値を取り出すほうが、可読性も堅牢性も圧倒的に高い。私は「UNIX哲学」に忠実であろうとするあまり、テキストパイプラインの限界を見て見ぬふりをしていた。

UNIX哲学は、間違いなくソフトウェア設計における最も影響力のある思想の一つだ。だが、普遍的な設計原則なのか、それとも特定の時代と制約が生んだ思想なのか。この回では、UNIX哲学の「原典」に立ち返り、その功績を認めた上で、限界を正面から検証する。

あなたは、自分が「UNIX哲学」だと思っているものが、誰の、いつの言葉かを正確に答えられるだろうか。

---

## 2. 「UNIX哲学」は一つではない

### McIlroyの原典（1978年）

「UNIX哲学」を最初に文書化したのは、Doug McIlroyだ。パイプの発明者であり、第7回で詳しく取り上げた人物である。

1978年7-8月号のBell System Technical Journal（Vol.57, No.6, Part 2）に掲載された "UNIX Time-Sharing System: Foreword" で、McIlroyはE. N. PinsonおよびB. A. Tagueとの共著として、UNIXのソフトウェアツールの設計原則を記した。その核心部分を引用する。

> (i) Make each program do one thing well. To do a new job, build afresh rather than complicate old programs by adding new "features".
>
> (ii) Expect the output of every program to become the input to another, as yet unknown, program. Don't clutter output with extraneous information. Avoid stringently columnar or binary input formats. Don't insist on interactive input.
>
> (iii) Design and build software, even operating systems, to be tried early, ideally within weeks. Don't hesitate to throw away the clumsy parts and rebuild them.
>
> (iv) Use tools in preference to unskilled help to lighten a programming task, even if you have to detour to build the tools and expect to throw some of them out after you've finished using them.

注目すべきは、McIlroyが「一つのことをうまくやれ」だけを言っているのではないことだ。出力は他のプログラムの入力になることを想定せよ。余計な情報で出力を汚すな。厳密な列フォーマットやバイナリ入力フォーマットを避けよ。対話的な入力を強制するな。ソフトウェアは数週間で試作せよ。不器用な部品は捨てて作り直せ。ツールを使え、自分でツールを作ることすら厭うな。

ここには「テキストストリーム」という言葉は直接登場しない。だが、(ii)の内容――出力を他のプログラムの入力にすること、余計な装飾を避けること、厳密なフォーマットを避けること――は、テキストストリームによるプログラム間連携を前提としている。

### Salusの要約（1994年）

McIlroyの原典は4項目からなる比較的詳細なものだが、世間で最も広く引用される「UNIX哲学」は、これを圧縮した3行だ。Peter H. Salusが1994年の著書 "A Quarter Century of Unix"（Addison-Wesley）でまとめたものである。

> 1. Write programs that do one thing and do it well.
> 2. Write programs to work together.
> 3. Write programs to handle text streams, because that is a universal interface.

McIlroyの原典と比較すると、Salusの要約ではいくつかの変化が見られる。まず、(iii)の「早く試作し、不器用な部品は捨てて作り直せ」というプロトタイピングの原則が消えている。次に、(iv)の「ツールを使え」も消えている。そして、原典にはなかった「text streams」が「universal interface」として明示的に登場している。

この3行要約は簡潔で覚えやすい。だからこそ広まった。しかし、McIlroyの原典にあった「早期に試作し、捨てることを恐れるな」という実践的な姿勢が抜け落ち、「テキストストリーム」が普遍的インターフェースとして神格化された点には留意すべきだ。

### Raymondの17のルール（2003年）

Eric S. Raymondは2003年の著書 "The Art of UNIX Programming"（Addison-Wesley Professional）で、UNIX哲学を17のルールに体系化した。

```
Eric Raymondの17のルール (2003年):

  1. Rule of Modularity     -- シンプルな部品をきれいなインターフェースで接続せよ
  2. Rule of Clarity        -- 巧妙さより明瞭さを選べ
  3. Rule of Composition    -- 他のプログラムと接続できるように設計せよ
  4. Rule of Separation     -- ポリシーとメカニズムを分離せよ
  5. Rule of Simplicity     -- 単純さを追求し、複雑さは必要な場合のみ加えよ
  6. Rule of Parsimony      -- 大きなプログラムは必要性が実証されるまで書くな
  7. Rule of Transparency   -- 検査とデバッグを容易にする設計をせよ
  8. Rule of Robustness     -- 堅牢性は透明性と単純さの子である
  9. Rule of Representation -- 知識をデータに折り込め。ロジックを愚かで頑健にせよ
 10. Rule of Least Surprise -- 最も驚きの少ない設計をせよ
 11. Rule of Silence        -- 特に言うことがなければ何も出力するな
 12. Rule of Repair         -- 回復できないなら派手に失敗せよ
 13. Rule of Economy        -- プログラマの時間はマシンの時間より貴重だ
 14. Rule of Generation     -- 手書きを避け、プログラムでプログラムを書け
 15. Rule of Optimization   -- 磨く前にプロトタイプを作れ。最適化の前に動かせ
 16. Rule of Diversity      -- 「唯一の正しい方法」を主張するすべてに疑いを持て
 17. Rule of Extensibility  -- 未来のために設計せよ。未来は思ったより早く来る
```

Raymondの功績は、散逸していた「UNIX的な知恵」を一冊に集約し、体系化した点にある。しかし、McIlroyの4項目から17のルールへの膨張は、一つの問題を提起する。**これらすべてが本当に「UNIX哲学」なのか、それともRaymondが「良いソフトウェア設計の原則」をUNIXの名の下に統合したのか。**

Rule 16の「唯一の正しい方法を疑え」は、Perlの "There's more than one way to do it"（TMTOWTDI）を想起させるが、Pythonの "There should be one-- and preferably only one --obvious way to do it" とは真っ向から対立する。これは「UNIX哲学」なのか、それともRaymond個人の設計哲学なのか。17のルール全体を「UNIX哲学」として引用する際には、その来歴を意識すべきだ。

### Pikeの5つのルールとThompsonの一言

Rob Pikeは1989年2月21日付の "Notes on Programming in C" で、5つのプログラミングルールを提示した。

> Rule 1. You can't tell where a program is going to spend its time. Bottlenecks occur in surprising places, so don't try to second guess and put in a speed hack until you've proven that's where the bottleneck is.
>
> Rule 2. Measure. Don't tune for speed until you've measured, and even then don't unless one part of the code overwhelms the rest.
>
> Rule 3. Fancy algorithms are slow when n is small, and n is usually small. Fancy algorithms have big constants.
>
> Rule 4. Fancy algorithms are buggier than simple ones, and they're much harder to implement. Use simple algorithms as well as simple data structures.
>
> Rule 5. Data dominates. If you've chosen the right data structures and organized things well, the algorithms will almost always be self-evident. Data structures, not algorithms, are central to programming.

Pikeのルールは、McIlroyの「UNIX哲学」とは色合いが異なる。「一つのことをうまくやれ」や「テキストストリーム」には触れていない。代わりに、「計測なき最適化をするな」「単純なアルゴリズムを使え」「データ構造が支配する」という、プログラミングの実践に焦点を当てている。

Ken ThompsonはPikeのルール3と4を、さらに簡潔に言い換えた。**"When in doubt, use brute force."** 迷ったら力業で解け。凝ったアルゴリズムより愚直な実装のほうが正しく動く。この経験則は、UNIXの設計そのものに反映されている。

ここで見えてくるのは、「UNIX哲学」と呼ばれるものが、実は複数の異なる思想の緩やかな集合体だということだ。McIlroyの「小さなツールの組み合わせ」、Pikeの「データ構造が支配する」、Thompsonの「力業で解け」。これらは互いに矛盾しないが、強調点が異なる。「UNIX哲学」を一枚岩の教義として扱うことは、歴史的に正確ではない。

---

## 3. UNIX哲学の構造的限界

UNIX哲学が偉大な設計思想であることは疑いない。だが、あらゆる思想にはそれが生まれた時代の制約が刻印されている。UNIX哲学が前提とする世界と、2020年代の現実との間には、いくつかの構造的な乖離がある。

### テキストストリームは「スキーマレス」である

UNIX哲学の中核にある「テキストストリーム」は、プログラム間連携のための事実上の標準インターフェースだ。どんなプログラムの出力もテキストであり、どんなプログラムもテキストを入力として受け取る。この普遍性がパイプラインの力の源泉だ。

だが、テキストストリームには根本的な問題がある。**スキーマが存在しない。**

`ls -l` の出力を考えてみよう。

```
drwxr-xr-x 2 yusuke staff  4096 Feb 10 14:30 Documents
-rw-r--r-- 1 yusuke staff 12345 Feb 10 14:30 report.txt
```

この出力を `awk '{print $5}'` でファイルサイズを取得できる。だが、この「第5フィールド」という約束はどこにも定義されていない。`ls` のマニュアルにも出力フォーマットの厳密な仕様はない。ファイル名にスペースが含まれていれば `awk` のフィールド分割は破綻する。ロケールによって日付のフォーマットが変わり、フィールドの位置がずれる。

これがテキストストリームの本質的な脆弱性だ。出力のフォーマットは慣習に過ぎず、構文的な契約（schema）が存在しない。パイプラインの各段は、前段の出力フォーマットを「知っている」ことを暗黙に前提とする。前段のフォーマットが変わればパイプラインは静かに壊れる。エラーにならず、誤った結果を返す。

```
テキストストリームの構造的問題:

  プログラムA ──テキスト──→ プログラムB ──テキスト──→ プログラムC

  問題1: AとBの間に「フォーマットの契約」がない
         → Aの出力形式が変わると、Bは壊れるか誤った結果を返す

  問題2: 型情報が失われる
         → 数値もファイルパスも日付もすべて「文字列」
         → "12345" が数値なのかIDなのかファイルサイズなのか、
           テキストからは判別できない

  問題3: 構造が失われる
         → ネストされたデータ（JSON, YAML, XML）は
           行指向のパイプラインと相性が悪い
```

### パイプラインのエラー処理問題

UNIXパイプラインのもう一つの構造的な弱点は、エラー処理だ。

```bash
# このパイプラインで、grepがエラーを起こしたらどうなるか？
cat access.log | grep "ERROR" | sort | uniq -c | sort -rn | head -10
```

デフォルトのbashでは、パイプラインの終了コードは**最後のコマンド**の終了コードだ。`grep` が失敗しても（例えばファイルが存在しない場合）、最後の `head -10` が正常終了すれば、パイプライン全体は「成功」を返す。途中のエラーは黙殺される。

bash 3.0以降では `set -o pipefail` を設定することで、パイプライン中のいずれかのコマンドがゼロ以外の終了コードを返した場合に、パイプライン全体がそのコードを返すようになる。だが、この解決は不完全だ。

第一に、`pipefail` はbash固有のオプションであり、POSIX shには存在しない。dashやashでは使えない。ポータブルなシェルスクリプトでは頼れない。

第二に、`pipefail` はどのコマンドが失敗したかを伝えない。パイプラインの途中で失敗した場合、最も右側のゼロ以外の終了コードが返るだけだ。

第三に、パイプラインの各段は並行して実行される。`grep` がエラーを起こしても、`sort` や `uniq` はすでに走り始めている。エラーが検出されるのは全段の実行が終わった後だ。「途中で止める」という選択肢がない。

```
UNIXパイプラインのエラー伝播:

  cmd1 | cmd2 | cmd3 | cmd4

  デフォルト:
    → 終了コード = cmd4の終了コード
    → cmd1, cmd2, cmd3のエラーは無視される

  set -o pipefail:
    → 終了コード = 最後にゼロ以外を返したコマンドの終了コード
    → 改善はされるが、どのコマンドが失敗したか特定できない
    → パイプラインの「途中で停止」はできない

  根本的な問題:
    → テキストストリームにはエラー情報を乗せる仕組みがない
    → 「帯域外通信」（stderr, 終了コード）に頼るしかない
```

### 状態管理の不在

UNIXのコマンドラインツールは、原則としてステートレスだ。入力を受け取り、処理し、出力する。状態は保持しない。この設計は、ツールの組み合わせ可能性を高める一方で、「状態を持つ処理」を困難にする。

たとえば、「直前のログエントリの内容に応じて現在の行の処理を変える」という要件は、ステートレスなパイプラインでは困難だ。`awk` は変数を持てるので不可能ではないが、awk自体が「小さなプログラミング言語」になっている。「一つのことをうまくやれ」という原則と「awkで複雑な状態管理をする」ことは、矛盾する。

---

## 4. UNIX哲学を批判した人々

### Jeffrey Snoverの「Monad Manifesto」（2002年）

UNIX哲学のテキストストリームに対する最も体系的な批判は、意外にもMicrosoft社内から生まれた。

2002年8月8日、MicrosoftのJeffrey Snoverは "Monad Manifesto" と題する社内文書を執筆した。この文書は、後にPowerShellとなるシェルの設計思想を述べたものだ。Snoverはこの中で、UNIXのテキストベースパイプラインを **"prayer-based parsing"** （祈りに頼るパース）と呼んで批判した。

Snoverの批判の核心はこうだ。UNIXのパイプラインでは、プログラムの出力はテキストであり、次のプログラムはそのテキストを解析して意味を取り出す。だが、テキストの「どの部分が何を意味するか」は慣習に過ぎない。`ls -l` の出力の5番目のフィールドがファイルサイズであることは、どこにも保証されていない。パースが成功することを「祈って」いるだけだ。

Snoverの提案は、テキストの代わりに .NETオブジェクトをパイプラインで渡すことだった。オブジェクトはプロパティとメソッドを持ち、型情報を保持する。ファイルサイズは文字列の5番目のフィールドではなく、`Length` というプロパティとして明示的にアクセスできる。

```
UNIXパイプラインとPowerShellパイプラインの比較:

  UNIX:
    ls -l | awk '{print $5}' | sort -rn | head -5
    → テキスト → テキスト → テキスト → テキスト
    → 各段で「パース」が必要
    → フォーマット変更に脆弱

  PowerShell:
    Get-ChildItem | Sort-Object Length -Descending | Select-Object -First 5
    → オブジェクト → オブジェクト → オブジェクト → オブジェクト
    → プロパティ名で直接アクセス
    → 型情報が保持される
```

PowerShell 1.0は2006年11月14日にリリースされた。Snoverの構想から4年の歳月を経ていた。

PowerShellのオブジェクトパイプラインは、テキストパイプラインの脆弱性を解消した。だが、別の代償を払った。テキストは「見れば読める」が、オブジェクトは「型を知らなければ触れない」。テキストパイプラインでは `| less` で途中経過を確認できるが、オブジェクトパイプラインでは `| Format-List` や `| Get-Member` で明示的に展開する必要がある。テキストの「透明性」は、UNIX哲学の利点の一つでもあった。

### Plan 9――UNIX哲学の極限

Plan 9 from Bell Labsは、UNIX哲学を批判したのではなく、UNIX哲学を極限まで推し進めた実験だ。1980年代半ばからBell Labsで開発され、1992年に初版がリリースされた。Rob Pike、Ken Thompson、Dave Presotto、Howard Trickey、Phil Winterbottomらが中心となった。UNIXの創造者自身が「UNIXの次」を設計したのだ。

Plan 9の核心は二つの設計原則にある。

第一に、**"Everything is a file" の徹底。** UNIXでも "Everything is a file" は掲げられていたが、実際にはネットワークソケット、プロセス間通信、グラフィックスデバイスなどはファイルとして扱えない。Plan 9ではこれらすべてをファイルシステムとして公開した。ネットワーク接続は `/net/tcp` 配下のファイルとして読み書きでき、プロセスの情報は `/proc` 配下のファイルとしてアクセスできる（Linuxの `/proc` はPlan 9に影響を受けている）。ウィンドウシステムも `/dev/draw` と `/dev/mouse` というファイルインターフェースで操作される。

第二に、**per-process namespaces。** UNIXではファイルシステムの名前空間はシステム全体で共有されるが、Plan 9ではプロセスごとに独立した名前空間を持てる。プロセスAから見える `/net` とプロセスBから見える `/net` は、まったく異なるファイルサーバを指していてもよい。この設計により、プロセスごとに「自分だけの仮想マシン」を構築できる。

Plan 9はこれらの原則を9P（ナインピー）というプロトコルで実現した。すべてのリソースは9Pを通じてファイルとして公開され、ネットワーク越しにも透過的にアクセスできる。

```
Plan 9のper-process namespaces:

  プロセスA:                      プロセスB:
  /net/tcp → ローカルネットワーク   /net/tcp → リモートネットワーク
  /dev/cons → ローカル端末         /dev/cons → SSH先の端末
  /mnt/data → ローカルディスク     /mnt/data → リモートファイルサーバ

  → 各プロセスが「自分だけのマシン」を見ている
  → Linuxのnamespaces, cgroups, Docker等に思想的影響を与えた
```

Plan 9は技術的に先駆的だったが、商業的には成功しなかった。2002年の第4版でLucent Public License下のオープンソースとなり、2021年にはPlan 9 FoundationによりMITライセンスで再公開された。だが、UNIXとの互換性を捨てたこと、既存のソフトウェアエコシステムが使えないこと、十分なユーザーベースを獲得できなかったことにより、主流にはなれなかった。

Plan 9が証明したのは、UNIX哲学の「到達点」と「限界」の両面だ。"Everything is a file" を徹底すれば美しいシステムが作れる。だが、その美しさだけでは既存のエコシステムに勝てない。設計思想の正しさと市場での成功は別の問題である。

### JSONという「構造化テキスト」の台頭

2001年、Douglas CrockfordはJavaScript Object Notation（JSON）を開発し、2002年にjson.orgでその仕様を公開した。JSONは2006年にIETFのRFC 4627として標準化され、2017年にはRFC 8259として更新された。

JSONの重要性は、テキストストリームと構造化データの「間」を埋めた点にある。JSONはテキストだ。`cat` で読めるし、`grep` でパターンを探せる。だが同時に、キーと値のペア、配列、ネストといった構造を持つ。型情報は限定的（文字列、数値、真偽値、null）だが、テキストストリームの完全なスキーマレス状態よりは遥かにましだ。

```
テキスト → JSON → オブジェクト（構造化度の連続体）:

  テキストストリーム          JSON                     オブジェクト
  ─────────────────────────────────────────────────────────────────
  スキーマ:  なし             暗黙的（慣習）            明示的（型定義）
  型情報:    なし             限定的                    完全
  可読性:    高い             高い                      低い（要変換）
  パース:    困難（正規表現）  容易（パーサ標準化済み）  不要
  ツール:    sed, awk, grep   jq, yq                   言語固有API
  パイプ:    UNIX pipe        UNIX pipe + jq            PowerShell等
```

JSONの普及により、「テキストストリームか構造化オブジェクトか」という二項対立は崩れた。テキストの可読性と構造化データの堅牢性を兼ね備えた中間地点が生まれたのだ。

---

## 5. 構造化パイプラインの時代

### jq――「sed for JSON」

Stephen Dolanが2012年にリリースしたjqは、JSONデータのためのコマンドラインプロセッサだ。ポータブルCで実装され、ランタイム依存がない。「sed for JSON data」と称されるように、UNIXのテキスト処理ツールの設計哲学を構造化データに適用した。

jqが解決したのは、「JSONをテキスト処理ツールで扱う苦痛」だ。

```bash
# sed/awkでJSONからnameフィールドを抽出する試み（脆弱）
cat data.json | grep '"name"' | sed 's/.*"name": *"\([^"]*\)".*/\1/'

# jqで同じことをする（堅牢）
cat data.json | jq -r '.name'
```

前者は正規表現によるテキストパースであり、JSONの構造を理解していない。インデントが変わるだけで壊れる。後者はJSONの構造を理解した上でフィールドにアクセスするため、フォーマットの変動に強い。

jqはUNIXパイプラインに自然に組み込める。標準入力からJSONを受け取り、加工して標準出力に出す。テキストストリームのエコシステムを壊さずに、構造化データの処理能力を追加した。これはUNIX哲学の「否定」ではなく「拡張」だ。

Mike Farahが開発したyqは、jqの思想をYAMLに拡張したツールだ。Go言語で実装され、jqライクな構文でYAML、JSON、XML、CSV、TOMLなど複数のフォーマットを操作できる。Kubernetes、Docker Compose、GitHub Actionsなど、YAMLが設定ファイルの標準となった現代のインフラでは、yqの実用価値は高い。

### Nushell――構造化パイプラインの再発明

2019年8月23日、Jonathan Turner（Azure SDK開発者）はNushellを公開した。Yehuda KatzとAndres Robalinoとの共同プロジェクトだ。きっかけは、KatzがTurnerにPowerShellのデモを見せ、「構造化シェルの思想を関数型アプローチで実装できないか」と提案したことだった。

Nushellはテキストではなくテーブル（構造化データ）をパイプラインで渡す。

```bash
# 従来のUNIXパイプライン（テキスト処理）
ls -la | awk 'NR>1 {print $5, $9}' | sort -rn | head -5

# Nushell（構造化パイプライン）
ls | sort-by size --reverse | first 5 | select name size
```

Nushellのパイプラインでは、`ls` の出力はテキストではなくテーブルだ。各行が「レコード」であり、`name`、`size`、`modified` などの「カラム」を持つ。`sort-by size` はカラム名を指定してソートし、`select name size` は必要なカラムだけを選択する。

```
Nushellのパイプラインモデル:

  ls → テーブル（構造化データ）
  ┌───┬──────────────┬──────────┬──────────────┐
  │ # │     name     │   size   │   modified   │
  ├───┼──────────────┼──────────┼──────────────┤
  │ 0 │ Documents    │   4096 B │ 2 days ago   │
  │ 1 │ report.txt   │  12345 B │ 2 days ago   │
  │ 2 │ photo.jpg    │ 524288 B │ 1 week ago   │
  └───┴──────────────┴──────────┴──────────────┘

  → sort-by size → select name size → first 5
  → 各段がテーブルを受け取り、テーブルを返す
  → テキストパースは不要。カラム名で直接アクセス
```

Nushellはまた、JSON、YAML、TOML、CSV、SQLiteなどのファイルを `open` コマンドで自動的にテーブルとして読み込む。ファイルフォーマットの違いは `open` が吸収し、以降のパイプラインでは統一的にテーブルとして操作できる。

NushellはPowerShellの思想を受け継ぎつつ、テキストの可読性を維持している。テーブルの表示はテキストとしてターミナルに描画されるため、`| less` のような従来のページャとも共存できる。

### 三つのアプローチの比較

同じタスク――「カレントディレクトリのファイルをサイズ順に並べ、上位5件を表示」――を三つのアプローチで比較する。

```bash
# (1) 古典的UNIXパイプライン
ls -la | awk 'NR>1 && !/^d/ {print $5, $9}' | sort -rn | head -5

# (2) jq（JSON入力を想定）
find . -maxdepth 1 -type f -printf '{"name":"%f","size":%s}\n' | jq -s 'sort_by(.size) | reverse | .[:5] | .[] | "\(.size) \(.name)"' -r

# (3) Nushell
ls | where type == file | sort-by size --reverse | first 5 | select name size
```

(1)は簡潔だが、ファイル名のスペースに脆弱で、出力フォーマットはロケール依存。(2)は堅牢だが、JSONの生成にGNU find固有の `-printf` を使っており、ポータブルでない。(3)は可読性と堅牢性を両立するが、Nushellのインストールが前提だ。

**どのアプローチが「正しい」かは、コンテキスト次第だ。** これこそが、この回の核心にある問いへの暫定回答でもある。

---

## 6. ハンズオン：三つのパイプラインを体験する

### 環境構築

```bash
# Docker環境で実行（ubuntu:24.04ベース）
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：テキストパイプラインの限界を体験する

まず、テスト用のデータを作成し、テキストパイプラインがどこで壊れるかを体験する。

```bash
# テスト用ディレクトリの作成
mkdir -p /tmp/unix-philosophy-test && cd /tmp/unix-philosophy-test

# ファイル名にスペースを含むファイルを作成
echo "Hello World" > "my document.txt"
echo "Test" > "normal.txt"
echo "Long content here for testing" > "another file with spaces.txt"

# 古典的なUNIXパイプライン：ファイルサイズでソート
echo "--- ls -l | awk でファイルサイズを取得 ---"
ls -l | awk 'NR>1 {print $5, $9}'

echo ""
echo "→ 'my document.txt' が 'my' と 'document.txt' に分割されている"
echo "  スペースを含むファイル名でawkのフィールド分割が破綻する"
echo "  これがテキストパイプラインの構造的脆弱性"
```

### 演習2：JSONログの処理を比較する

```bash
# JSONログデータの生成
cat << 'EOF' > /tmp/unix-philosophy-test/access.json
{"timestamp":"2026-02-20T10:00:00Z","method":"GET","path":"/api/users","status":200,"duration_ms":45}
{"timestamp":"2026-02-20T10:00:01Z","method":"POST","path":"/api/users","status":201,"duration_ms":120}
{"timestamp":"2026-02-20T10:00:02Z","method":"GET","path":"/api/users/1","status":200,"duration_ms":30}
{"timestamp":"2026-02-20T10:00:03Z","method":"GET","path":"/api/products","status":500,"duration_ms":5000}
{"timestamp":"2026-02-20T10:00:04Z","method":"DELETE","path":"/api/users/2","status":404,"duration_ms":15}
{"timestamp":"2026-02-20T10:00:05Z","method":"GET","path":"/api/users","status":200,"duration_ms":55}
{"timestamp":"2026-02-20T10:00:06Z","method":"PUT","path":"/api/users/1","status":200,"duration_ms":80}
{"timestamp":"2026-02-20T10:00:07Z","method":"GET","path":"/api/products","status":500,"duration_ms":4500}
EOF

# (A) sed/awkによるテキスト処理：ステータス500のリクエストを抽出
echo "--- (A) sed/awk によるテキスト処理 ---"
grep '"status":500' /tmp/unix-philosophy-test/access.json | \
  sed 's/.*"path":"\([^"]*\)".*/\1/' | \
  sort | uniq -c | sort -rn
echo ""
echo "→ 正規表現でJSONを解析している"
echo "  フィールドの順序が変わると壊れる"

# jqのインストール
apt-get update -qq && apt-get install -y -qq jq > /dev/null 2>&1

# (B) jqによる構造化処理：同じタスク
echo "--- (B) jq による構造化処理 ---"
jq -r 'select(.status == 500) | .path' /tmp/unix-philosophy-test/access.json | \
  sort | uniq -c | sort -rn
echo ""
echo "→ .status == 500 で型を意識した比較"
echo "  .path でキー名による直接アクセス"
echo "  フィールドの順序に依存しない"
```

### 演習3：パイプラインのエラー処理を検証する

```bash
echo "--- パイプラインのエラー処理 ---"
echo ""

# デフォルト動作：途中のエラーが無視される
echo "(1) デフォルト（pipefail なし）:"
cat /nonexistent/file 2>/dev/null | grep "pattern" | wc -l
echo "終了コード: $?"
echo "→ catが失敗してもwc -lが成功するため、終了コード 0"
echo ""

# pipefail あり：エラーが伝播する
echo "(2) set -o pipefail 有効時:"
set -o pipefail
cat /nonexistent/file 2>/dev/null | grep "pattern" | wc -l
echo "終了コード: $?"
set +o pipefail
echo "→ パイプライン中の失敗が検出される"
echo "  ただし、どのコマンドが失敗したかは不明"
echo ""

# PIPESTATUS配列（bash固有）
echo "(3) PIPESTATUS配列による詳細確認:"
cat /nonexistent/file 2>/dev/null | grep "pattern" | wc -l
echo "PIPESTATUS: ${PIPESTATUS[0]} ${PIPESTATUS[1]} ${PIPESTATUS[2]}"
echo "→ bash固有のPIPESTATUS配列で各コマンドの終了コードを確認できる"
echo "  ただしPOSIX shでは使えない"
```

### 演習4：jqのパイプライン――構造化データの組み合わせ

```bash
echo "--- jqの高度なパイプライン ---"
echo ""

# 複数の集計を一度に行う
echo "エンドポイント別のリクエスト統計:"
jq -s '
  group_by(.path) |
  map({
    path: .[0].path,
    count: length,
    avg_duration_ms: (map(.duration_ms) | add / length | . * 100 | round / 100),
    error_count: map(select(.status >= 400)) | length
  }) |
  sort_by(.avg_duration_ms) |
  reverse
' /tmp/unix-philosophy-test/access.json

echo ""
echo "→ group_by, map, sort_by は jq の組み込み関数"
echo "  テキストパイプラインでは困難な集計をJSON構造のまま実行できる"
echo "  結果もJSONであり、さらにパイプラインで加工可能"
```

ハンズオンの自動セットアップスクリプトは `handson/command-line/10-unix-philosophy-critique/setup.sh` を参照してほしい。

---

## 7. まとめと次回予告

### この回の要点

第一に、「UNIX哲学」は一枚岩の教義ではない。Doug McIlroyが1978年のBell System Technical Journal Forewordで記した4項目の原則が原典であり、Peter Salusの3行要約（1994年）、Eric Raymondの17のルール（2003年）は、それぞれ圧縮・拡張されたバリエーションだ。Rob Pikeの5つのルール（1989年）やKen Thompsonの "When in doubt, use brute force" は、「UNIX哲学」と呼ばれつつも異なる側面を強調している。原典に立ち返ることが、安易な教条化を避ける第一歩だ。

第二に、UNIX哲学の中核にあるテキストストリームは「スキーマレスなデータ形式」であり、構造的な限界を持つ。型情報の欠如、フォーマットの慣習依存、ネストされたデータとの相性の悪さ。これらはテキストストリームの設計そのものに内在する問題であり、使い方の問題ではない。Jeffrey Snoverが2002年のMonad Manifestoで批判した "prayer-based parsing" は、この問題の本質を突いている。

第三に、パイプラインのエラー処理は構造的に脆弱だ。デフォルトでは途中のエラーが黙殺され、`set -o pipefail` も不完全な解決に留まる。テキストストリームにはエラー情報を乗せる仕組みがなく、帯域外通信（stderr、終了コード）に頼るしかない。

第四に、Plan 9はUNIX哲学を極限まで推し進め、"Everything is a file" とper-process namespacesで美しいシステムを構築した。だが、既存エコシステムとの互換性を犠牲にした代償として主流にはなれなかった。設計思想の純粋さと実用的な普及は、別の次元の問題だ。

第五に、jq（2012年）、yq、Nushell（2019年）は、テキストストリームの限界に対する実用的な回答だ。jqはUNIXパイプラインの中に構造化データ処理を自然に組み込み、Nushellはシェルそのものをテーブルベースの構造化パイプラインに再設計した。これらはUNIX哲学の「否定」ではなく「拡張」として位置づけられる。

### 冒頭の問いへの暫定回答

UNIX哲学は普遍的な設計原則なのか、それとも特定の時代と制約の産物なのか。

暫定的な答えはこうだ。**UNIX哲学の核心――小さなプログラムを組み合わせ、複雑な処理を構築する――は普遍的な設計原則だ。だが、その実装形態としての「テキストストリーム」は、1970年代のハードウェア制約と、テキスト中心の処理が主流だった時代の産物だ。** McIlroyが「テキストストリームはユニバーサルインターフェース」と宣言した時代、データは主にテキストだった。設定ファイルも、ログも、プロセス間通信も。だが2020年代、データはJSONであり、YAMLであり、Protocol Buffersであり、構造を持っている。

UNIX哲学は偉大だが万能ではない。テキストストリームの限界を知ることが、次の進化を理解する鍵だ。jqやNushellを使うことは、UNIX哲学への裏切りではない。「小さなツールの組み合わせ」という原則を、構造化データの時代に適応させる営みだ。

### 次回予告

次回、第11回「GUIの衝撃――Xerox Alto, Macintosh, そして"CLIは死ぬ"という予言」では、視点を大きく転換する。ここまで10回にわたってCLIの世界を辿ってきたが、次回はCLIの「対立者」として登場したGUIの歴史に正面から向き合う。

1973年のXerox Alto、1984年のMacintosh、1995年のWindows 95。GUIが登場するたびに「CLIは死ぬ」と予言された。その予言は外れ続けている。だが、なぜ外れたのか。GUIとCLIの認知モデルの違い――再認（recognition）と想起（recall）――を理解することが、その答えへの入口になる。

---

## 参考文献

- M. Douglas McIlroy, E. N. Pinson, B. A. Tague, "UNIX Time-Sharing System: Foreword", The Bell System Technical Journal, Vol.57, No.6, Part 2, July-August 1978, pp.1899-1904, <https://onlinelibrary.wiley.com/doi/10.1002/j.1538-7305.1978.tb02135.x>
- Peter H. Salus, "A Quarter Century of Unix", Addison-Wesley, 1994
- Eric S. Raymond, "The Art of UNIX Programming", Addison-Wesley Professional, 2003, <http://www.catb.org/esr/writings/taoup/html/>
- Rob Pike, "Notes on Programming in C", February 21, 1989, <https://www.lysator.liu.se/c/pikestyle.html>
- Jeffrey P. Snover, "Monad Manifesto", August 8, 2002, <https://www.jsnover.com/Docs/MonadManifesto.pdf>
- Rob Pike, Dave Presotto, Sean Dorward, Bob Flandrena, Ken Thompson, Howard Trickey, Phil Winterbottom, "Plan 9 from Bell Labs", <https://9p.io/sys/doc/9.html>
- Plan 9 from Bell Labs, <https://9p.io/plan9/about.html>
- Stephen Dolan, jq -- Command-line JSON processor, <https://jqlang.github.io/jq/>
- Mike Farah, yq -- Portable command-line YAML, JSON, XML processor, <https://github.com/mikefarah/yq>
- Jonathan Turner, "Introducing nushell", Nushell Blog, August 23, 2019, <https://www.nushell.sh/blog/2019-08-23-introducing-nushell.html>
- Douglas Crockford, "Introducing JSON", <https://www.json.org/>
- IETF, "RFC 8259: The JavaScript Object Notation (JSON) Data Interchange Format", 2017, <https://datatracker.ietf.org/doc/html/rfc8259>
- Wikipedia, "Plan 9 from Bell Labs", <https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs>
- Wikipedia, "Unix philosophy", <https://en.wikipedia.org/wiki/Unix_philosophy>
- Wikipedia, "PowerShell", <https://en.wikipedia.org/wiki/PowerShell>
