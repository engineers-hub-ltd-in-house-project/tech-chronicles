# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第9回：正規表現――CLIを支えるパターン言語

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 正規表現の数学的起源――Stephen Kleeneの「正規集合」理論（1951年）
- Ken ThompsonによるQED実装（1968年）――理論がソフトウェアになった瞬間
- POSIX BRE/EREの標準化とその歴史的文脈
- Perlが正規表現を「メインストリーム」に引き上げた経緯とPCREの誕生
- NFA（非決定性有限オートマトン）とDFA（決定性有限オートマトン）――二つのエンジンの設計思想
- バックトラッキングの危険性――ReDoS攻撃と2019年Cloudflare障害
- RE2とripgrepが示す「安全な正規表現」の未来
- 正規表現を段階的に学ぶハンズオン演習

---

## 1. 「呪文」を解読した日

2000年代前半のある日、私は正規表現を「呪文」だと思っていた。

Webサーバのログファイルから特定のパターンを抽出する必要があった。先輩エンジニアが書いたシェルスクリプトの中に、こんな行があった。

```bash
grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}.*"GET /api/.*" [45][0-9]{2}' access.log
```

意味はわかる――IPアドレスで始まり、GETリクエストの/api/配下で、400番台か500番台のステータスコードを返した行を抽出している。だが、その構文の意味を一文字ずつ追えるかと言えば、当時の私には無理だった。`[0-9]{1,3}` が「1桁から3桁の数字」を意味することも、`[45][0-9]{2}` が「400番台または500番台の3桁のコード」を表すことも、理解はしていても身体に馴染んでいなかった。

正規表現は「覚えるもの」だと思っていた。`*` は0回以上の繰り返し、`+` は1回以上、`?` は0回か1回、`[]` は文字クラス――暗記すれば使える、そう信じていた。

転機は、正規表現の「文法」を体系的に理解したときに訪れた。暗記ではなく構造を知った瞬間、grep、sed、awkが一気に手に馴染んだ。それまでバラバラに見えていた構文規則が、一つの体系の中に位置づけられた。`*` がなぜ「0回以上」なのか。`[]` がなぜ「文字クラス」と呼ばれるのか。`()` と `|` がなぜセットで使われるのか。それぞれに理由があり、その理由は60年以上前の数学理論にまで遡る。

あなたは、`grep -E '[0-9]+'` の中の `+` が、いつ、誰によって、なぜ発明されたか知っているだろうか。あなたが毎日使っている正規表現の構文の一つ一つに、数学者の定理と、ハッカーの実装判断と、標準化委員会の妥協が凝縮されている。

---

## 2. 数学から生まれたパターン言語

### 神経回路網と有限オートマトン

正規表現の歴史は、コンピュータサイエンスよりも古い。

1943年、神経生理学者Warren McCullochと論理学者Walter Pittsは、"A Logical Calculus of the Ideas Immanent in Nervous Activity" を発表した。神経回路網を数学的にモデル化した論文だ。この論文で提示されたMcCulloch-Pitts神経回路は、後の人工ニューラルネットワークの原型となるが、もう一つの系譜――有限オートマトン理論――の出発点にもなった。

Stephen Cole Kleene（1909年1月5日 - 1994年1月25日）は、Alonzo Churchの学生として再帰理論を研究したアメリカの数学者だ。Amherst Collegeで学士号を取得後、1934年にPrinceton大学で博士号を得た。1935年からWisconsin大学Madisonの数学科で教鞭をとり、ほぼ全キャリアをそこで過ごした。再帰理論、算術階層、計算可能性の理論などで知られるが、彼の名を最も広く世に伝えているのは「正規表現」の発明だ。

1951年、KleeneはRAND Corporationの研究メモ RM-704 として "Representation of Events in Nerve Nets and Finite Automata" を執筆した。この論文は、McCulloch-Pittsの神経回路網が応答できる「事象」の種類を数学的に特徴づけることを目的としていた。KleeneはMcCulloch-Pitts神経回路網を有限オートマトンとして一般化し、有限オートマトンが認識できる言語のクラスを「正規集合」（regular sets）として定義した。

そして、この正規集合を記述するための記法として、KleeneはRとSという二つの事象に対する三つの演算を定義した。

```
Kleeneが定義した三つの基本演算:

  1. 連接（Concatenation）: RS
     → 事象Rの後に事象Sが続くパターン

  2. 選択（Union / Alternation）: R | S
     → 事象Rまたは事象Sのいずれか

  3. 閉包（Closure / Kleene Star）: R*
     → 事象Rの0回以上の繰り返し

  この三つの演算の組み合わせで、有限オートマトンが
  認識できるすべてのパターンを記述できる。
  これがKleeneの定理（Kleene's Theorem）である。
```

この研究メモは、1956年にPrinceton University Pressから出版された "Automata Studies"（Claude ShannonとJohn McCarthy 編）に正式収録された。「正規表現」（regular expression）という用語自体は、この1956年版で初めて使われた。

Kleeneの業績が革新的だったのは、「パターンの記述」と「パターンの認識」が等価であることを証明した点だ。正規表現で記述できるパターンの集合と、有限オートマトンで認識できるパターンの集合は完全に一致する。この数学的等価性は、Kleeneの定理として知られ、正規表現をソフトウェアに実装するための理論的基盤となった。

だが、1956年の時点で、この理論は純粋に数学の領域にあった。正規表現が「プログラムで使える技術」になるには、さらに12年を要する。

### Ken Thompsonの革新――理論を実装に変えた瞬間

1968年6月、CACMにわずか4ページの論文が掲載された。Ken Thompson, "Programming Techniques: Regular expression search algorithm"（Communications of the ACM, Vol.11, No.6, pp.419-422）。

この論文が、正規表現の歴史における転換点だ。

Thompsonは、MITのCTSS（Compatible Time-Sharing System）上のQEDエディタに正規表現機能を実装する過程で、Kleeneの理論をアルゴリズムに変換した。具体的には、正規表現をNFA（非決定性有限オートマトン）に変換し、そのNFAをIBM 7094のマシンコードにコンパイルする手法を示した。

```
Thompson NFAの構築（Thompson's Construction）:

  正規表現 → NFA → マシンコード

  例: 正規表現 "a(b|c)*d" の変換過程

  1. リテラル 'a' → 状態遷移 [S0] --a--> [S1]
  2. 選択 'b|c' → 分岐
       [S1] --ε--> [S2] --b--> [S3] --ε--> [S5]
       [S1] --ε--> [S4] --c--> [S3] --ε--> [S5]
  3. 閉包 '(b|c)*' → 選択構造にループ追加
       [S5] --ε--> [S1]  （ループバック）
       [S1] --ε--> [S6]  （スキップ）
  4. リテラル 'd' → [S6] --d--> [S7（受理状態）]

  ε遷移: 入力文字を消費せずに状態を移動する遷移
```

Thompsonの手法の核心は、正規表現の各構成要素（リテラル、選択、閉包、連接）に対して、対応するNFAの断片を生成し、それらを組み合わせて全体のNFAを構築することにあった。この手法は後に「Thompson's construction」（Thompsonの構成法）として知られるようになる。

前回の記事で触れたように、ThompsonはQEDで正規表現を実装した後、1969年にPDP-7上でedエディタを開発する際にこの技術を簡略化して再利用した。edの正規表現は、QEDが持っていた選択（alternation）や括弧（grouping）を削り、`*`演算子のみを残した簡素なものだった。PDP-7のメモリ制約の中での設計判断だ。

だが、1968年の論文に記述されたThompson NFAの完全な手法は、正規表現エンジン実装の基本設計図として、半世紀以上にわたって参照され続けている。

### 二つの流れ――理論と実装の乖離

Kleeneの定理が証明した「正規表現と有限オートマトンの等価性」は、実装の世界では必ずしも単純に適用されなかった。ここに、正規表現エンジンの二大流派の源流がある。

ThompsonのNFA方式は、正規表現からNFAを構築し、入力文字列に対してNFAのすべての可能な状態を同時に追跡する。この方式は入力の長さに対して線形時間で動作する。一文字読むたびに、現在いる可能性のあるすべての状態を次の状態に遷移させる。状態の数は正規表現の長さに比例するため、一文字あたりの処理量は正規表現の長さに比例する。全体の計算量はO(mn)――正規表現の長さmと入力の長さnの積だ。

一方、DFA（決定性有限オートマトン）方式は、NFAを事前にDFAに変換してから実行する。DFAは常に一つの状態にしかいないため、一文字あたりの処理はO(1)であり、全体の計算量はO(n)だ。ただし、NFAからDFAへの変換で状態数が指数的に増加する場合がある（いわゆる「状態爆発」）。

```
二つのエンジン方式:

  Thompson NFA方式:
    正規表現 → NFA構築 → 複数状態を同時追跡
    計算量: O(mn)  (m=正規表現の長さ, n=入力の長さ)
    メモリ: O(m)   (状態リストのサイズ)
    特徴: 構築が速い、実行は状態追跡のオーバーヘッドあり

  DFA方式:
    正規表現 → NFA構築 → DFA変換 → 単一状態の遷移
    計算量: O(n)   (入力の長さのみに依存)
    メモリ: O(2^m) (最悪ケースの状態数)
    特徴: 実行が最速、構築コストとメモリが大きい可能性

  バックトラッキングNFA方式（後に主流化）:
    正規表現 → NFA構築 → 一つの経路を試行 → 失敗したら戻る
    計算量: O(2^n) (最悪ケース、指数時間)
    メモリ: O(n)   (バックトラックのスタック)
    特徴: 後方参照等の拡張が容易、最悪ケースが危険
```

1973年にgrepが誕生した当初、grepはThompsonのNFA方式を用いていた。同じ頃、Al Ahoはegrep（拡張grep）のためにDFA方式のアルゴリズムを設計した。egrepは正規表現の複雑さにかかわらず、入力サイズに対して線形時間で動作した。

この二つの方式は、いずれもKleeneの定理の範囲内――つまり「正規表現と有限オートマトンの等価性」の範囲内――で動作する。だが、後に登場する第三の方式――バックトラッキングNFA――は、この範囲を逸脱することになる。その話は後述する。

---

## 3. 標準化と拡張の時代

### POSIX BRE/ERE――二つの方言

1970年代から1980年代にかけて、正規表現の構文はツールごとに微妙に異なっていた。edの正規表現、grepの正規表現、egrepの正規表現、sedの正規表現――基本は共通しているが、メタ文字の扱いに差異があった。

最も厄介な差異は、特殊文字のエスケープ規則だった。edとgrepでは、括弧 `(` `)` や波括弧 `{` `}` はリテラル文字として扱われ、特殊な意味を持たせるにはバックスラッシュ `\(` `\)` でエスケープする必要があった。一方、egrepでは括弧 `(` `)` がそのまま特殊文字（グルーピング）として機能し、リテラルとして使うときにバックスラッシュが必要だった。

```
同じパターンの表記の違い（"abc" または "xyz" にマッチ）:

  ed/grep (BRE):     \(abc\|xyz\)    ← 特殊文字にバックスラッシュ
  egrep (ERE):       (abc|xyz)       ← バックスラッシュ不要

同じパターンの表記の違い（3桁の数字にマッチ）:

  ed/grep (BRE):     [0-9]\{3\}      ← 波括弧にバックスラッシュ
  egrep (ERE):       [0-9]{3}        ← バックスラッシュ不要
```

この混乱を整理したのが、1992年に承認されたPOSIX.2標準（IEEE Std 1003.2-1992）だ。POSIXは正規表現を二つの方言として標準化した。

BRE（Basic Regular Expression）は、ed/grepの伝統を引き継ぐ構文だ。メタ文字 `(`, `)`, `{`, `}` にバックスラッシュが必要。`+` や `?` や `|` はメタ文字として定義されていない。最も保守的な正規表現だ。

ERE（Extended Regular Expression）は、egrepの伝統を引き継ぐ構文だ。`(`, `)`, `{`, `}` はそのままメタ文字として機能する。`+`（1回以上）、`?`（0回または1回）、`|`（選択）が使える。BREの拡張であり、より簡潔にパターンを記述できる。

```
POSIX BREとEREの構文比較:

  機能          BRE           ERE           意味
  ─────────────────────────────────────────────────
  リテラル       a             a            文字 'a'
  任意の一文字   .             .            改行以外の任意の文字
  0回以上       a*            a*           'a'の0回以上の繰り返し
  1回以上       なし          a+           'a'の1回以上の繰り返し
  0回か1回     なし          a?           'a'の0回または1回
  文字クラス    [abc]         [abc]        a,b,cのいずれか
  行頭          ^             ^            行の先頭
  行末          $             $            行の末尾
  グルーピング   \(abc\)       (abc)        グループ化
  選択          \(a\|b\)     (a|b)        aまたはb
  繰り返し回数  a\{3\}        a{3}         'a'のちょうど3回
  後方参照      \1            \1           1番目のグループの再参照
```

GNU grepでは、`grep`（BREモード）と `grep -E`（EREモード）は表記法の違いだけで機能的に同等だ。GNU拡張として、BREでも `\+`、`\?`、`\|` が使える。だが、他の実装（BSD grep等）ではBREとEREの機能差が残る場合がある。POSIX準拠の範囲でポータブルなスクリプトを書く際には、この差異を意識する必要がある。

POSIXによる標準化は、正規表現の「方言問題」を完全に解決したわけではない。だが、少なくともBRE/EREという二つの基準線を設けたことで、ツール間の互換性に最低限の保証を与えた。この標準化がなければ、grep、sed、awkの正規表現はさらに断片化していただろう。

### Henry Spencerのライブラリ――自由な実装

POSIX標準化と並行して、正規表現の実装にも重要な動きがあった。

Henry Spencer（1955年生まれ）はカナダのプログラマで、1986年1月19日にUsenetのmod.sourcesグループに正規表現ライブラリを投稿した。AT&Tのregex(3)ライブラリ（UNIX標準の正規表現ライブラリ）の非プロプライエタリな代替実装だ。Eighth Edition Research UnixのAPIに準拠していた。

Spencerのライブラリは、自由に利用できる正規表現実装として広く採用された。最も重要な採用先の一つが、Perl 2（1988年6月リリース）だ。Larry WallはPerl 2でSpencerの正規表現パッケージを組み込み、Perlの正規表現エンジンの基盤とした。

Spencerは後に二つの追加ライブラリを作成した。1993年頃に4.4BSDに寄贈されたPOSIX.2準拠のBSDライブラリと、1999年にTcl 8.1に組み込まれたUnicode対応のTclライブラリだ。

Spencerの1986年のライブラリは、正規表現の歴史における重要な結節点だ。AT&Tの商用ライセンスの制約なく正規表現を実装できたことで、BSDシステム、Perl、その他多くのソフトウェアに正規表現が浸透した。自由なソフトウェアという理念が、技術の普及を加速させた例の一つだ。

### Perl――正規表現をメインストリームに

1987年12月18日、Larry WallはPerl 1.0をリリースした。Unisys社で勤務中に開発を開始したPerlは、「Practical Extraction and Report Language」（実用的な抽出・報告言語）として、awkでは処理しきれないテキスト処理タスクのために設計された。

Perlが正規表現の歴史において果たした役割は、計り知れない。

第一に、Perlは正規表現を言語の中核機能に据えた。他の言語では正規表現はライブラリ関数として呼び出すものだったが、Perlでは言語構文に組み込まれた。`if ($line =~ /pattern/) { ... }` という構文は、正規表現をテキスト処理の第一級市民にした。

第二に、Perlは正規表現の構文を拡張した。Perl 1の時点で、BREの `\(` `\)` をEREの `(` `)` に変更し、構文を簡潔にした。その後のバージョンで、後方参照、先読み（lookahead）、後読み（lookbehind）、名前付きキャプチャ、非貪欲マッチング（`*?`, `+?`）など、POSIX BRE/EREにはない機能が次々と追加された。

第三に、Perlの正規表現は事実上の業界標準となった。Java、Python、JavaScript、Ruby、PHP――主要なプログラミング言語の正規表現は、程度の差こそあれPerlの構文と意味論を参照している。「Perl互換」が正規表現の品質基準になった。

だが、Perlの正規表現エンジンには、KleeneやThompsonの理論から逸脱した設計判断があった。バックトラッキングだ。

Perlの正規表現エンジンは、後方参照や先読み/後読みといった拡張機能を実現するために、バックトラッキングNFA方式を採用した。バックトラッキングとは、パターンマッチングが失敗したとき、以前の分岐点まで戻って別の経路を試す手法だ。この方式は、Kleeneの定理の範囲を超える機能（特に後方参照）を実現できる。後方参照をサポートするパターンマッチングは、正規言語の範囲を超え、NP完全であることが知られている。

バックトラッキングの問題は、最悪ケースの計算量が指数時間になりうることだ。この問題は、1968年のThompsonの論文が提示したNFA方式では発生しない。だが、Perlの拡張機能の魅力は圧倒的であり、多くの言語がPerlのバックトラッキング方式を採用した。

### PCRE――Perlの正規表現を世界に

1997年夏、Philip HazelはPCRE（Perl Compatible Regular Expressions）の開発を始めた。動機は明確だ。Hazelが開発していたExim MTA（メール転送エージェント）で、Perlの強力な正規表現機能をCライブラリとして利用したかったのだ。

PCREは、Perlの正規表現構文をCライブラリとして再実装したものだ。POSIX BRE/EREよりはるかに強力な構文を提供し、後方参照、先読み/後読み、非貪欲マッチング、名前付きキャプチャグループなどをサポートする。

PCREの影響は、Exim一つに留まらなかった。Apache HTTPサーバ、Nginx、PHP、R、Nmap、KDE、Postfix――主要なオープンソースプロジェクトが次々とPCREを採用した。Perlをインストールしなくても、Perl互換の正規表現が使えるようになった。

PCREはバックトラッキングNFAモデルに基づいている。つまり、Perlの正規表現エンジンと同じ設計上の限界――最悪ケースの指数時間――を引き継いでいる。この限界は、後に深刻な実害をもたらすことになる。

2015年にPCRE2（改訂API版）がフォークされ、初代PCREは「PCRE1」と呼ばれるようになった。PCRE1はバグ修正のみで積極的な開発は終了している。

---

## 4. バックトラッキングの代償

### なぜ指数時間が発生するのか

バックトラッキングNFA方式の正規表現エンジンでは、特定のパターンと入力の組み合わせに対して、マッチングの計算量が指数的に増大する。

その仕組みを、簡単な例で理解する。

```
バックトラッキングの指数爆発:

  正規表現:  (a+)+b
  入力:      aaaaaaaaaaaaaaaaaa  （aが18個、bなし）

  エンジンの動作:
  1. (a+) が 18個の 'a' をすべてマッチ → 外側の + でループ
  2. 'b' が見つからない → 失敗
  3. バックトラック: (a+) を17個に縮小 → 残り1個を外側の+で再試行
  4. 'b' が見つからない → 失敗
  5. さらにバックトラック: (a+) を16個に → 残り2個を分割...
     ...分割の組み合わせは 2^17 通り存在する

  入力長nに対して、試行回数は O(2^n) に達する

  Thompson NFA方式なら:
  → すべての可能な状態を同時追跡
  → 入力の各文字で状態リストを更新するだけ
  → O(mn) で完了（mはパターン長、nは入力長）
```

`(a+)+b` というパターンは、「1個以上のaの、1回以上の繰り返しの後にbが続く」を意味する。入力が `aaa...a`（aだけでbがない）の場合、エンジンはまず最も長いマッチを試み、失敗するとバックトラックして別の分割を試す。aを何個ずつの塊に分けるかの組み合わせは指数的に増加するため、入力長が18文字でも、エンジンは26万回以上の試行を行う可能性がある。入力長が30文字なら10億回を超える。

この種の正規表現は「悪い正規表現」（evil regex）と呼ばれる。入れ子になった量指定子（nested quantifiers）や、曖昧な選択構造が典型的なパターンだ。

### ReDoS――正規表現によるサービス妨害

バックトラッキングの指数爆発は、セキュリティ上の脅威になる。ReDoS（Regular Expression Denial of Service）だ。

ReDoSは2003年のUsenix Security（Scott A. CrosbyとDan S. Wallach）で初めて形式的に発表された。攻撃者が悪意のある入力を送り込むことで、サーバ側の正規表現エンジンを指数時間の計算に陥れ、サービスを停止させる。

2019年7月2日、Cloudflareは世界規模の障害を経験した。27分間にわたるサービスダウンで、最悪時にはトラフィックが82%減少した。原因は、WAF（Web Application Firewall）のルールに含まれていた一つの正規表現だった。

この正規表現が過剰なバックトラッキングを引き起こし、全サーバのCPU使用率が100%に達した。Cloudflareのポストモーテム（事後分析）は、複数の問題を指摘している。第一に、使用していた正規表現エンジンに計算量の保証がなかった。第二に、テストスイートにCPU消費量を検出する仕組みがなかった。第三に、WAFルールの変更が段階的デプロイではなく一括グローバルデプロイで行われていた。

Cloudflareの障害は、バックトラッキング型正規表現エンジンのリスクを広く知らしめた。正規表現は「文字列検索のツール」であると同時に、「計算量を制御できなければ武器にもなる」ものだ。

### Russ Coxの警鐘

2007年1月、GoogleのRuss Coxは "Regular Expression Matching Can Be Simple And Fast (but is slow in Java, Perl, PHP, Python, Ruby, ...)" と題したブログ記事を公開した。

Coxの主張は明快だ。Ken Thompsonが1968年に示したNFA方式は、正規表現の長さmと入力の長さnに対してO(mn)で動作する。一方、現代の主要な言語（Perl、Python、Java、Ruby等）のバックトラッキング方式は、最悪ケースでO(2^n)の指数時間がかかる。40年前の手法の方が、現代の実装より速いケースが存在する。

Coxはブログ記事で、パターン `a?{n}a{n}` を入力 `a{n}`（aがn個）に対してマッチングする実験を示した。Thompson NFA方式は入力長に対して線形時間で動作するのに対し、Perlのバックトラッキング方式は指数時間を要した。n=29（わずか29文字）の場合、Thompson NFA方式はマイクロ秒単位で完了するのに対し、Perlは数十秒以上を要した。

```
Coxの実験結果（概念図）:

  パターン: a?{n}a{n}  （aの任意出現n回 + aのn回）
  入力:     a{n}        （aがn個）

  Thompson NFA:    O(mn)  → n=29 でマイクロ秒
  Perl (backtrack): O(2^n) → n=29 で数十秒以上

  性能比: Thompson NFA方式は約100万倍高速
```

この記事は、正規表現エンジンの設計選択が持つ意味を再認識させた。「Perlの正規表現は強力だ」という常識に対して、「だがThompsonの手法の方が本質的に安全だ」という対抗命題を突きつけた。

Coxのブログシリーズは全4回にわたり、正規表現エンジン実装に関する最も重要な技術文書の一つとなっている。そしてCoxの主張は、後にRE2という形で実装に結実する。

---

## 5. 安全な正規表現への回帰

### RE2――Thompsonの再来

2010年3月、GoogleはRE2をオープンソースとして公開した。Russ CoxがGoogle Code Searchのために開発した正規表現エンジンだ。

RE2の設計目標は明確だ。安全性（safety）が第一。信頼できない入力（untrusted input）から正規表現を受け取っても、計算量が制御不能にならないことを保証する。具体的には、入力サイズに対して線形時間、固定スタック容量で動作する。

RE2は、Thompsonの1968年の論文に立ち返り、オートマトン理論に基づく実装を採用した。バックトラッキングを使わないため、指数時間の爆発は原理的に発生しない。ただし、バックトラッキングが必要な機能――特に後方参照――はサポートしない。

```
RE2の設計上のトレードオフ:

  採用した機能:
    - リテラル、文字クラス、量指定子 (*, +, ?, {n,m})
    - グルーピング、選択（alternation）
    - アンカー (^, $, \b)
    - キャプチャグループ
    - Unicode サポート
    - 名前付きキャプチャ

  採用しなかった機能:
    - 後方参照 (\1, \2 等)
    - 先読み/後読み (lookahead/lookbehind)
    - 再帰パターン
    → これらはバックトラッキングが必要であり、
      線形時間保証と両立しない
```

この設計判断は、「PCREの大部分の機能をカバーしつつ、安全性を絶対に妥協しない」という方針の表れだ。実際のプログラミングにおいて、後方参照を使う場面は全体の数パーセントに過ぎない。大多数のユースケースは、RE2でカバーできる。

RE2はGoogleの内部で広く使われ、Code SearchやBigtableなどのシステムに組み込まれた。また、Go言語の標準ライブラリの `regexp` パッケージは、RE2と同じパターン言語・同じ実装方針を共有している。Go言語でバックトラッキング方式ではなくRE2方式が採用されたのは、言語設計者の一人がRuss Cox本人であるからだ。

### Rust regexクレートとripgrep

RE2の設計思想は、さらに次の世代に引き継がれた。

Andrew Gallant（BurntSushi）は、Rustのregexクレートを開発する際、RE2に強くインスパイアされた実装を採用した。有限オートマトンベースで、線形時間保証を維持している。RustのregexライブラリとGoのregexpパッケージは、RE2を共通の祖先とする兄弟だ。

ripgrep（2016年）は、このRust regexクレートの上に構築されている。第17回で詳しく取り上げる予定だが、ripgrepの圧倒的な検索速度の一因は、正規表現エンジンの設計にある。

ripgrepの最適化戦略は多層的だ。まず正規表現からリテラル文字列を抽出し、Aho-CorasickアルゴリズムやSIMD命令（Intel HyperscanのTeddyアルゴリズム）による高速な文字列検索を実行する。正規表現エンジン本体が起動するのは、リテラル検索でマッチの可能性がある箇所を検証するときだけだ。

```
Thompson NFA → RE2 → Rust regex → ripgrep

  1968年: Thompson NFA（CACM論文）
    → 正規表現をNFAに変換し、すべての状態を同時追跡
    → 線形時間保証の理論的基盤

  2010年: RE2（Russ Cox / Google）
    → Thompson NFAの現代的再実装
    → 安全性を最優先、後方参照を排除

  2015年頃: Rust regexクレート（Andrew Gallant）
    → RE2の設計思想をRustで再実装
    → SIMDやリテラル最適化を追加

  2016年: ripgrep
    → Rust regexクレートの上に構築
    → リテラル検索 + 正規表現の多層最適化
    → grepの10倍以上の速度を実現
```

この系譜は、1968年のThompsonの論文から半世紀以上にわたる「安全な正規表現」の追求の歴史だ。バックトラッキング方式が主流となった数十年の間に、その危険性が顕在化し、改めてThompsonの原点に回帰する動きが生まれた。歴史は直線的には進まない。時に原点に立ち返ることで、新しい地平が開ける。

### 二つの世界の共存

現在の正規表現の世界は、二つの流派が共存している。

バックトラッキング方式は、Perl、Python、Java、JavaScript、Ruby、.NET、PCRE/PCRE2で使われている。後方参照、先読み/後読み、条件付きパターンなど、豊富な拡張機能を持つ。だが、最悪ケースの計算量は保証されない。

オートマトン方式は、RE2、Go regexp、Rust regex、そしてripgrepで使われている。機能はバックトラッキング方式より限定的だが、計算量が入力サイズに対して線形であることが保証されている。

どちらが「正しい」かという問いには、一意の答えがない。信頼できない入力を処理するサーバサイドアプリケーションでは、オートマトン方式が安全だ。一方、開発者が自分で書く正規表現で、入力が信頼できる場合には、バックトラッキング方式の豊富な機能が便利だ。

重要なのは、この二つの選択肢があることを知っていることだ。正規表現エンジンの設計は、機能と安全性のトレードオフだ。そのトレードオフを理解していなければ、Cloudflareのような障害を引き起こすかもしれない。

---

## 6. 正規表現の体系――呪文ではなく文法として

### 正規表現の構成要素

正規表現を「暗記すべき記号の羅列」ではなく「体系的な文法」として捉え直す。

正規表現の構成要素は、大きく四つに分類できる。

```
正規表現の四つの構成要素:

  1. マッチ対象（何にマッチするか）
     ─────────────────────────────
     a        → リテラル文字 'a'
     .        → 任意の一文字（改行以外）
     [abc]    → 文字クラス: a, b, c のいずれか
     [a-z]    → 範囲指定: a から z の任意の文字
     [^abc]   → 否定文字クラス: a, b, c 以外
     \d       → 数字 [0-9]           (Perl/PCRE拡張)
     \w       → 単語文字 [a-zA-Z0-9_] (Perl/PCRE拡張)
     \s       → 空白文字             (Perl/PCRE拡張)

  2. 量指定子（何回マッチするか）
     ─────────────────────────────
     *        → 0回以上（Kleene Star）
     +        → 1回以上（ERE/Perl）
     ?        → 0回または1回（ERE/Perl）
     {n}      → ちょうどn回
     {n,m}    → n回以上m回以下
     {n,}     → n回以上

  3. 構造（パターンの組み合わせ方）
     ─────────────────────────────
     AB       → 連接: AのあとにB（暗黙の演算子）
     A|B      → 選択: AまたはB
     (A)      → グルーピング: Aをグループ化
     \1       → 後方参照: 1番目のグループの再参照

  4. アンカー（位置の指定）
     ─────────────────────────────
     ^        → 行の先頭
     $        → 行の末尾
     \b       → 単語の境界（Perl/PCRE拡張）
```

この四つの構成要素の組み合わせで、あらゆる正規表現パターンが構築される。Kleeneが定義した三つの基本演算（連接、選択、閉包）は、上の分類では「量指定子」の `*` と「構造」の連接・選択に対応する。Kleeneの理論を知っていれば、正規表現の構文は演算の応用に過ぎない。

### grep -E、sed、awk、Perl/Python での書き比べ

同じパターンを異なるツールで書く場合、構文の差異を意識する必要がある。

```bash
# 課題: "2025-01-15" のような日付パターン（YYYY-MM-DD）にマッチ

# grep (BRE) -- バックスラッシュ必須
grep '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' file.txt

# grep -E (ERE) -- バックスラッシュ不要
grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}' file.txt

# sed (BRE) -- grepのBREと同じ構文
sed -n '/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/p' file.txt

# awk (ERE) -- grep -Eと同じ構文
awk '/[0-9]{4}-[0-9]{2}-[0-9]{2}/' file.txt

# Perl (PCRE) -- \dが使える
perl -ne 'print if /\d{4}-\d{2}-\d{2}/' file.txt

# Python (re module, PCRE系)
# import re; re.findall(r'\d{4}-\d{2}-\d{2}', text)
```

grepのBREモードでは `\{4\}` と書くが、grep -EのEREモードでは `{4}` と書く。awkはEREベースなので `{4}` でよい。Perl/Pythonでは `\d` という文字クラスショートカットが使えるため、`[0-9]` を `\d` に置き換えられる。

これらの構文差異は、歴史的な経緯の産物だ。BREはedの正規表現が起源であり、1960年代の設計が反映されている。EREはegrepの拡張。Perl/PCREはさらなる拡張。新しい方が「良い」わけではないが、構文が簡潔になる傾向はある。

### 正規表現の「読み方」

正規表現を読む際のコツは、左から右に「何にマッチするか」と「何回マッチするか」のペアとして分解することだ。

```
例: ^[A-Z][a-z]+\s\d{4}$

  ^          → 行の先頭
  [A-Z]      → 大文字アルファベット1文字
  [a-z]+     → 小文字アルファベット1文字以上
  \s         → 空白文字1文字
  \d{4}      → 数字ちょうど4文字
  $          → 行の末尾

  マッチ例: "January 2025", "March 1999"
  非マッチ例: "january 2025" (先頭が小文字)
              "Jan 25" (数字が2桁)

例: https?://[^\s/]+(/[^\s]*)?

  http       → リテラル "http"
  s?         → 's' の0回または1回（httpまたはhttps）
  ://        → リテラル "://"
  [^\s/]+    → 空白・スラッシュ以外の1文字以上（ホスト名）
  (          → グループ開始
    /[^\s]*  → スラッシュ + 空白以外の0文字以上（パス）
  )?         → グループ全体が0回または1回
```

正規表現は「呪文」ではない。数学から生まれ、UNIXのツール群を通じて実用化された、パターン記述の体系だ。体系を理解すれば、初見の正規表現も分解して読める。

---

## 7. ハンズオン：正規表現を段階的に学ぶ

正規表現を「暗記」ではなく「構造の理解」として習得するためのハンズオンを提供する。Kleeneの三つの演算から出発し、POSIX BRE/ERE/PCREの差異を実際に確認し、最後にReDoSの危険性を体験する。

### 演習1：正規表現の基礎――リテラルから文字クラスへ

```bash
# 正規表現の基礎演習（Docker環境推奨）
docker run --rm -it ubuntu:24.04 bash -c '
echo "=============================================="
echo "[演習1] 正規表現の基礎"
echo "=============================================="
echo ""

# テスト用データを作成
cat > /tmp/sample.txt << TEXTEOF
2025-01-15 INFO  Server started on port 8080
2025-01-15 ERROR Connection refused: 192.168.1.100
2025-01-15 WARN  Memory usage at 85%
2025-01-16 ERROR Timeout after 30000ms
2025-01-16 INFO  Request from 10.0.0.1 completed in 42ms
2025-01-16 DEBUG Query returned 0 rows
2025-01-17 ERROR Disk space critical: 95% used
2025-01-17 INFO  Backup completed: 1024MB transferred
TEXTEOF

echo "サンプルデータ:"
cat -n /tmp/sample.txt
echo ""

echo "--- Step 1: リテラルマッチ ---"
echo ""
echo "  grep \"ERROR\" sample.txt"
grep "ERROR" /tmp/sample.txt | sed "s/^/  /"
echo ""
echo "  → 固定文字列 ERROR を含む行を表示"
echo ""

echo "--- Step 2: 文字クラス [abc] ---"
echo ""
echo "  grep \"[EW]\" sample.txt"
echo "  → E または W を含む行"
grep "[EW]" /tmp/sample.txt | sed "s/^/  /"
echo ""

echo "--- Step 3: 範囲指定 [a-z] ---"
echo ""
echo "  grep -E \"[0-9]{1,3}%\" sample.txt"
echo "  → 1〜3桁の数字 + % を含む行"
grep -E "[0-9]{1,3}%" /tmp/sample.txt | sed "s/^/  /"
echo ""

echo "--- Step 4: 量指定子 *, +, ? ---"
echo ""
echo "  grep -E \"[0-9]+ms\" sample.txt"
echo "  → 1桁以上の数字 + ms を含む行"
grep -E "[0-9]+ms" /tmp/sample.txt | sed "s/^/  /"
echo ""

echo "--- Step 5: アンカー ^, $ ---"
echo ""
echo "  grep \"^2025-01-16\" sample.txt"
echo "  → 行頭が 2025-01-16 の行"
grep "^2025-01-16" /tmp/sample.txt | sed "s/^/  /"
echo ""

echo "--- Step 6: 組み合わせ ---"
echo ""
echo "  grep -E \"^2025-01-1[67].*ERROR\" sample.txt"
echo "  → 16日または17日のERROR行"
grep -E "^2025-01-1[67].*ERROR" /tmp/sample.txt | sed "s/^/  /"
echo ""

rm -f /tmp/sample.txt
echo "=============================================="
'
```

### 演習2：BRE/EREの構文差異を確認する

```bash
# BREとEREの構文差異を体験する
docker run --rm -it ubuntu:24.04 bash -c '
echo "=============================================="
echo "[演習2] BRE vs ERE の構文差異"
echo "=============================================="
echo ""

cat > /tmp/versions.txt << TEXTEOF
Python 3.12.0 released 2023-10-02
Go 1.21.0 released 2023-08-08
Rust 1.73.0 released 2023-10-05
Java 21 released 2023-09-19
Node 20.9.0 released 2023-10-24
TEXTEOF

echo "テストデータ:"
cat -n /tmp/versions.txt
echo ""

echo "--- 課題: メジャーバージョンが2桁以上の行を抽出 ---"
echo ""

echo "  BRE (grep): grep \"[0-9]\\{2,\\}\\.[0-9]\" versions.txt"
grep "[0-9]\{2,\}\.[0-9]" /tmp/versions.txt | sed "s/^/  /"
echo ""

echo "  ERE (grep -E): grep -E \"[0-9]{2,}\\.[0-9]\" versions.txt"
grep -E "[0-9]{2,}\.[0-9]" /tmp/versions.txt | sed "s/^/  /"
echo ""

echo "  → 同じ結果だが、EREの方が簡潔"
echo ""

echo "--- 課題: グルーピングと選択 ---"
echo ""
echo "  BRE: grep \"\\(Python\\|Rust\\)\" versions.txt"
grep "\(Python\|Rust\)" /tmp/versions.txt | sed "s/^/  /"
echo ""

echo "  ERE: grep -E \"(Python|Rust)\" versions.txt"
grep -E "(Python|Rust)" /tmp/versions.txt | sed "s/^/  /"
echo ""

echo "  → BREでは \\( \\) \\| が必要、EREでは不要"
echo ""

echo "--- 課題: sedでの置換 ---"
echo ""
echo "  sed (BRE): sed \"s/\\([0-9]\\{4\\}\\)-\\([0-9]\\{2\\}\\)-\\([0-9]\\{2\\}\\)/\\2\\/\\3\\/\\1/\" versions.txt"
echo "  → 日付を YYYY-MM-DD から MM/DD/YYYY に変換"
echo ""
sed "s/\([0-9]\{4\}\)-\([0-9]\{2\}\)-\([0-9]\{2\}\)/\2\/\3\/\1/" /tmp/versions.txt | sed "s/^/  /"
echo ""

echo "  sed -E (ERE): sed -E \"s/([0-9]{4})-([0-9]{2})-([0-9]{2})/\\2\\/\\3\\/\\1/\" versions.txt"
echo ""
sed -E "s/([0-9]{4})-([0-9]{2})-([0-9]{2})/\2\/\3\/\1/" /tmp/versions.txt | sed "s/^/  /"
echo ""
echo "  → EREの方がはるかに読みやすい"

rm -f /tmp/versions.txt
echo ""
echo "=============================================="
'
```

### 演習3：ReDoSの危険性を体験する

```bash
# バックトラッキングの指数爆発を安全に体験する
docker run --rm -it ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq python3 > /dev/null 2>&1

echo "=============================================="
echo "[演習3] バックトラッキングの指数爆発"
echo "=============================================="
echo ""

echo "--- 安全な正規表現 vs 危険な正規表現 ---"
echo ""
echo "Python の re モジュールはバックトラッキング方式を使用する。"
echo "特定のパターンと入力の組み合わせで、処理時間が指数的に増大する。"
echo ""

python3 << PYEOF
import re
import time

# 安全なパターン: a+b にマッチ
safe_pattern = re.compile(r"a+b")

# 危険なパターン: (a+)+b にマッチ（入れ子の量指定子）
evil_pattern = re.compile(r"(a+)+b")

print("パターン        入力長  時間(秒)  結果")
print("─" * 55)

for n in [10, 15, 18, 20, 22]:
    test_input = "a" * n  # bがないので必ず不一致

    # 安全なパターン
    start = time.perf_counter()
    result = safe_pattern.match(test_input)
    safe_time = time.perf_counter() - start

    # 危険なパターン（タイムアウト付き）
    start = time.perf_counter()
    try:
        # 安全のため、n>20なら計測しない
        if n <= 20:
            result = evil_pattern.match(test_input)
            evil_time = time.perf_counter() - start
        else:
            evil_time = -1  # スキップ
    except Exception:
        evil_time = -1

    if evil_time >= 0:
        print(f"a+b             {n:>5}  {safe_time:>8.6f}  不一致")
        print(f"(a+)+b          {n:>5}  {evil_time:>8.6f}  不一致")
    else:
        print(f"a+b             {n:>5}  {safe_time:>8.6f}  不一致")
        print(f"(a+)+b          {n:>5}  (スキップ: 指数時間のため)")
    print()
PYEOF

echo ""
echo "→ (a+)+b は入力長が増えると処理時間が指数的に増大する"
echo "  これがReDoS（正規表現によるサービス妨害）の原理"
echo ""
echo "--- 対策 ---"
echo ""
echo "  1. 入れ子の量指定子を避ける: (a+)+ → a+"
echo "  2. 原子的グループを使う（PCRE）: (?>a+)b"
echo "  3. バックトラッキングしないエンジンを使う:"
echo "     RE2, Go regexp, Rust regex, ripgrep"
echo ""
echo "=============================================="
'
```

これらの演習で、三つのことが体験できたはずだ。第一に、正規表現の構成要素がリテラル、文字クラス、量指定子、アンカーという四つのカテゴリに整理できること。暗記ではなく構造として理解する方法だ。第二に、BRE/EREの構文差異が歴史的な経緯の産物であること。edの時代にはバックスラッシュが必要であり、egrepの時代にそれが解消された。第三に、バックトラッキング型エンジンの危険性が実感できること。わずか20文字の入力で、計算量が数百万倍に膨らむ。

---

## 8. まとめと次回予告

### この回の要点

第一に、正規表現はStephen Cole Kleene（1909-1994）が1951年のRAND研究メモ（1956年にAutomata Studiesに正式収録）で定義した数学理論に起源を持つ。Kleeneは連接・選択・閉包の三つの基本演算で有限オートマトンが認識するパターンを記述できることを証明した。正規表現の `*`（Kleene Star）は、彼の名を冠している。

第二に、Ken Thompsonは1968年のCACM論文で、正規表現をNFAに変換して実行するアルゴリズム（Thompson's Construction）を発表した。これが理論を実装に変えた転換点であり、QED、ed、grepへと受け継がれた。Thompson NFA方式は入力サイズに対して線形時間で動作する。

第三に、正規表現の構文はBRE（edの系譜）→ ERE（egrepの拡張）→ Perl/PCRE（大幅な拡張）と進化した。POSIX.2標準（1992年）がBRE/EREを標準化し、ツール間の最低限の互換性を保証した。Henry Spencerの自由な実装（1986年）がBSD・Perl等への浸透を加速させた。

第四に、Perl（1987年）は正規表現を言語の中核機能に据え、後方参照、先読み/後読み、非貪欲マッチングなどを追加した。PCRE（Philip Hazel、1997年）はPerlの正規表現をCライブラリ化し、Apache、Nginx、PHP等に浸透させた。だが両者ともバックトラッキングNFA方式を採用しており、最悪ケースの指数時間爆発のリスクを持つ。

第五に、バックトラッキングの危険性はReDoS攻撃として顕在化した。2019年のCloudflare障害（27分間のサービスダウン）は、正規表現エンジンの設計選択がもたらすリスクの具体例だ。Russ Coxは2007年のブログ記事でThompson NFA方式の優位性を再提示し、2010年にRE2として実装した。RE2の設計思想はGo言語のregexpパッケージ、Rustのregexクレート、そしてripgrepに受け継がれている。

### 冒頭の問いへの暫定回答

正規表現はなぜCLIの「共通語」になったのか。

暫定的な答えはこうだ。**正規表現がCLIの共通語になったのは、テキストストリームを処理するすべてのツールが「パターンの記述」という共通の課題を抱えていたからだ。** grep、sed、awk、Perl、Python――テキストを扱うツールはすべて、「特定のパターンにマッチする文字列を見つける」機能を必要とした。正規表現は、Kleeneの数学理論に裏打ちされた普遍的なパターン記述言語として、この共通課題に対する統一的な解を提供した。

テキストストリームがUNIXの「ユニバーサルインターフェース」であるならば、正規表現はテキストストリームを操作するための「ユニバーサル言語」だ。構文には方言がある。BRE、ERE、PCRE――歴史的経緯に由来する差異は残る。だが、文字クラス、量指定子、選択、グルーピングという基本概念は共通だ。1956年のKleeneの理論が、60年以上にわたってテキスト処理の基盤であり続けている。

そして、その歴史は安全性という課題を突きつけている。バックトラッキング方式の豊富な機能と、オートマトン方式の安全性保証。どちらを選ぶかは、コンテキスト次第だ。正規表現を「呪文」として暗記するだけでは、この判断はできない。歴史と理論を知ることで初めて、ツールの選択と限界の理解が可能になる。

### 次回予告

次回、第10回「UNIX哲学の功罪――『一つのことをうまくやれ』は本当に正しいか」では、ここまで6回にわたって見てきたUNIXの設計思想を、批判的に検証する。Doug McIlroyの原典からEric Raymondの17のルール、Rob Pikeの反論、そしてPlan 9が極端に推し進めた理想。UNIX哲学は普遍的な設計原則なのか、それとも特定の時代と制約の産物なのか。

grepとsedとawkを一行のパイプラインで組み合わせる「芸術」が、保守性と可読性の面でどのような代償を払っているのか。テキストストリームという「スキーマレスなデータ形式」の限界はどこにあるのか。そしてPowerShellのオブジェクトパイプラインやNushellの構造化パイプラインは、その限界を超えたのか。次回は、UNIX哲学の功罪に正面から向き合う。

---

## 参考文献

- Stephen Cole Kleene, "Representation of Events in Nerve Nets and Finite Automata", RAND Research Memorandum RM-704, 1951; reprinted in Automata Studies, Princeton University Press, 1956, <https://www.rand.org/pubs/research_memoranda/RM704.html>
- Ken Thompson, "Regular expression search algorithm", Communications of the ACM, Vol.11, No.6, pp.419-422, June 1968, <https://dl.acm.org/doi/10.1145/363347.363387>
- Russ Cox, "Regular Expression Matching Can Be Simple And Fast", January 2007, <https://swtch.com/~rsc/regexp/regexp1.html>
- Russ Cox, "Implementing Regular Expressions", <https://swtch.com/~rsc/regexp/>
- Google Open Source Blog, "RE2: a principled approach to regular expression matching", March 2010, <https://opensource.googleblog.com/2010/03/re2-principled-approach-to-regular.html>
- GitHub, "google/re2", <https://github.com/google/re2>
- Wikipedia, "Stephen Cole Kleene", <https://en.wikipedia.org/wiki/Stephen_Cole_Kleene>
- Wikipedia, "Regular expression", <https://en.wikipedia.org/wiki/Regular_expression>
- Wikipedia, "Perl Compatible Regular Expressions", <https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions>
- Philip Hazel, "A Brief History of PCRE", <https://help.uis.cam.ac.uk/system/files/documents/techlink-hazel-pcre-brief-history.pdf>
- PCRE Official Site, <https://www.pcre.org/>
- Henry Spencer regex library, <https://garyhouston.github.io/regex/>
- Wikipedia, "Henry Spencer", <https://en.wikipedia.org/wiki/Henry_Spencer>
- The Open Group, "Regular Expressions", POSIX.1-2017, <https://pubs.opengroup.org/onlinepubs/9699919799/xrat/V4_xbd_chap09.html>
- Wikipedia, "Perl", <https://en.wikipedia.org/wiki/Perl>
- Cloudflare Blog, "Details of the Cloudflare outage on July 2, 2019", <https://blog.cloudflare.com/details-of-the-cloudflare-outage-on-july-2-2019/>
- OWASP, "Regular expression Denial of Service - ReDoS", <https://owasp.org/www-community/attacks/Regular_expression_Denial_of_Service_-_ReDoS>
- Andrew Gallant, "ripgrep is faster than {grep, ag, git grep, ucg, pt, sift}", <https://burntsushi.net/ripgrep/>
- Andrew Gallant, "Regex engine internals as a library", <https://burntsushi.net/regex-internals/>

---

**次回：** 第10回「UNIX哲学の功罪――『一つのことをうまくやれ』は本当に正しいか」

---

_本記事は「ターミナルは遺物か――コマンドラインの本質を問い直す」連載の第9回です。_
_ライセンス：CC BY-SA 4.0_
