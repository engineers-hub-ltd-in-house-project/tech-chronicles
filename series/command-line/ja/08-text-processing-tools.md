# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第8回：テキスト処理の系譜――ed, grep, sed, awk

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- edエディタの設計――QED（1965-66年）からの系譜と、ラインエディタという概念の意味
- grepの誕生――Lee McMahonのFederalist Papers分析と、edの `g/re/p` コマンドの独立
- sedの設計思想――「対話なきエディタ」という逆説的な発明
- awkのパターン-アクションモデル――テキストフィルタからプログラミング言語への飛躍
- 四つのツールが形成する「テキストストリーム生態系」の構造
- edを実際に操作し、「画面のない時代のテキスト編集」を体験するハンズオン

---

## 1. 名前の中に歴史がある

ある日、私は正規表現を学び始めた頃の記憶を辿っていた。2000年代前半、Webサーバのログ分析を日常とする中で、`grep`は毎日のように使う道具だった。だが、その名前の由来を知ったのは、使い始めてからしばらく後のことだ。

grepとは何の略か。調べてみると、それはedエディタのコマンド `g/re/p` だという。global、regular expression、print。ファイル全体（global）から正規表現（regular expression）にマッチする行を表示（print）する。edの対話的コマンドが、そのまま独立したツールの名前になっている。

この事実を知ったとき、私は歴史の連続性に驚いた。`grep`は、1969年に生まれたedエディタのコマンド体系の中から切り出されたものだった。そしてsedの名前は「stream editor」――ストリームエディタ、つまりedの非対話版だ。awkは三人の開発者――Alfred Aho、Peter Weinberger、Brian Kernighan――の頭文字である。

UNIXのテキスト処理ツール群の名前には、その出自が刻まれている。edから始まり、grep、sed、awkへと広がるこの系譜は、単なる「便利なコマンドの歴史」ではない。テキストストリームという共通インターフェースの上に構築された、生態系の進化史だ。

なぜ、1960年代に設計されたラインエディタのコマンド体系が、50年以上経った今もサーバログの分析に使われているのか。なぜ、ed、grep、sed、awkは互いに置き換えられることなく共存し続けているのか。その答えを探るには、これらのツールが生まれた順序と、それぞれが解決しようとした問題を理解する必要がある。

---

## 2. edから始まった――ラインエディタの時代

### QEDの系譜

edの物語は、edより前に始まる。

1965年から1966年にかけて、UCバークレーのButler LampsonとL. Peter Deutschは、Berkeley Timesharing System（SDS 940上で稼働）のためにQEDエディタを開発した。QED――Quick Editorの略――は、行指向のテキストエディタだった。画面全体を表示する今日のエディタとは異なり、QEDはテキストを行番号で管理し、コマンドで行を指定して操作する。

QEDの原版は比較的単純なものだったが、Ken ThompsonがこのエディタをMITのCTSS（Compatible Time-Sharing System, IBM 7094）に移植したとき、決定的な機能が加わった。正規表現だ。ThompsonはQEDのCTSS版に、非決定性有限オートマトン（NFA）をコンパイルして正規表現を処理する仕組みを組み込んだ。1968年、Thompsonはこの手法をCACM（Communications of the ACM）に論文として発表した。"Regular expression search algorithm"（Vol.11, No.6, pp.419-422, June 1968）である。

この論文は、正規表現を数学的概念から実用的なソフトウェア技術に変換した転換点だった。Stephen Kleeneが1956年に定式化した正規表現の理論は、Thompsonの論文によって「プログラムに組み込めるアルゴリズム」になった。そしてこのアルゴリズムは、edを経由して、grep、sed、awk、そして現代のあらゆるプログラミング言語の正規表現エンジンへと受け継がれていく。

### 1969年8月――edの誕生

1969年8月、Ken ThompsonはPDP-7上でUNIXの最初期の要素を書いた。アセンブラ、シェル、そしてエディタ。そのエディタがedだった。

edはQEDの系譜を引くラインエディタである。だが、Thompson はQEDの機能をそのまま移植したわけではない。PDP-7の制約――メモリの少なさ、処理能力の限界――の中で、QEDの正規表現を大幅に簡略化した。QEDが持っていた選択（alternation）や括弧（parentheses）を削り、`*`演算子（直前の文字の0回以上の繰り返し）のみを残した。

この簡略化は制約であると同時に、設計判断でもあった。必要最小限の正規表現で、実用的なテキスト編集を可能にする。edの設計は、UNIXの哲学――無駄を削ぎ落とし、本質だけを残す――を体現していた。

### 「画面のない」エディタとは何か

今日のエンジニアがedに初めて触れると、まず戸惑うのは「何も見えない」ことだ。

edはラインエディタである。画面全体にファイルの内容を表示する機能は持たない。テレタイプ端末――紙に印字する端末――の時代に設計されたエディタだからだ。CRT端末が普及する前、「画面」という概念は存在しなかった。あるのは印字された紙と、コマンドを入力するキーボードだけだ。

edを使うとき、ユーザーはまずどの行を操作するかをアドレスで指定し、次にコマンドを入力する。行を見たければ明示的に表示コマンドを打つ。自分がファイルのどこにいるのかは、自分で記憶しておく必要がある。

```
edの基本操作:

  $ ed                   ← edを起動
  a                      ← 追加モード（append）に入る
  Hello, World.          ← テキストを入力
  This is line two.
  .                      ← ピリオドで入力モードを終了
  1,2p                   ← 1行目から2行目を表示（print）
  Hello, World.
  This is line two.
  1s/World/UNIX/         ← 1行目の"World"を"UNIX"に置換
  1p                     ← 1行目を表示して確認
  Hello, UNIX.
  w test.txt             ← ファイルに書き込み（write）
  28                     ← 書き込んだバイト数が表示される
  q                      ← 終了（quit）
```

この操作体系を見て、あなたは何かに気づくだろう。`p`はprint、`s`はsubstitute、`w`はwrite、`q`はquit。そして `g/re/p` は「すべての行に対して正規表現reにマッチする行を表示する」。`g`はglobal、つまりファイル全体を対象とする接頭辞だ。

edのコマンド体系は、単なるエディタのインターフェースを超えた意味を持っていた。この体系の中から、独立したツールが次々と切り出されていくことになる。

### 二つの系譜――エディタとフィルタ

edを起点として、UNIXのテキスト処理は二つの系譜に分岐する。

一つはエディタの系譜だ。ed → em（1976年、George Coulouris、Queen Mary College、"editor for mortals"――「人間のためのエディタ」という名前が、edの操作性への批判を物語る）→ ex → vi（1976年、Bill Joy、UC Berkeley）→ vim（1988年、Bram Moolenaar）。ラインエディタからフルスクリーンエディタへ、表示能力の進化とともにエディタは進化した。

もう一つはフィルタの系譜だ。edのコマンド体系から、特定の操作を非対話的に実行するツールが分離していった。grep（1973年）、sed（1973-74年）、awk（1977年）。この系譜は対話的なエディタとは逆方向に進化した。人間が一行ずつコマンドを打つのではなく、プログラムが自動的にテキストを処理する。パイプラインの中で、他のツールと組み合わせて使う「フィルタ」としての進化だ。

```
二つの系譜:

  エディタの系譜（対話的・画面表示の進化）:

    QED (1965) → ed (1969) → em (1976) → ex/vi (1976) → vim (1988)
                    │
                    │ コマンド体系の分離
                    ↓
  フィルタの系譜（非対話的・パイプライン向け）:

    g/re/p → grep (1973)
    s/re/replacement/ → sed (1973-74)
    パターン-アクション → awk (1977)
```

本稿が追うのは、後者――フィルタの系譜だ。edのコマンド体系が、どのように独立したツールとして切り出され、パイプラインの中でテキストストリームを操作する生態系を形成したのか。

---

## 3. grep――edからの独立

### Federalist Papersとテキスト検索

grepの誕生には、学術的なテキスト分析が関わっている。

Bell Labsの研究者Lee McMahon（1931-1989）は、異色の経歴の持ち主だった。St. Louis Universityで学士号をsumma cum laudeで取得し、Harvard大学で心理学の博士号を得た。1963年にBell Labsに入り、テキスト分析と初期UNIXの開発に携わった。

McMahonはThe Federalist Papers――1787-88年に書かれたアメリカ合衆国憲法を擁護する85篇の論文集――の著者帰属問題に取り組んでいた。これらの論文はAlexander Hamilton、James Madison、John Jayの3名が執筆し、すべてPublius（パブリアス）というペンネームで発表された。どの論文を誰が書いたのか、テキストの語彙パターンから特定しようとする研究だった。

この分析には、大量のテキストから特定のパターンを検索する能力が不可欠だった。McMahonはedの `g/re/p` コマンドを使おうとしたが、問題があった。edは対話的エディタであり、ファイル全体をメモリにロードする設計だった。大量のテキストファイルに対して逐次的に検索するには不向きだった。

McMahonはKen Thompsonに相談した。Thompsonは、edの正規表現エンジンを抽出し、標準入力または指定ファイルを行単位で逐次処理するスタンドアロンプログラムとして書き出した。ファイル全体をメモリにロードする必要はない。一行読み、正規表現と照合し、マッチすれば出力し、次の行に進む。この設計は任意のサイズのファイルを処理できた。

Thompson本人は後年、こう語っている。

> "grep was a private command of mine for quite a while before I made it public."
>
> （grepはかなり長い間、私の個人用コマンドだった。公開するまでにしばらくかかった。）

grepはVersion 4 UNIX（1973年11月）のマニュアルに初めて掲載された。マニュアルの日付は1973年3月3日だが、これはマニュアルの最終更新日であり、ツールの作成日ではない可能性が高い。

### grepの設計――edとの決定的な違い

grepがedから独立したツールとなった際、技術的に最も重要な変更は「メモリモデル」だった。

edは編集のためにファイル全体をバッファに読み込む。ランダムアクセス（任意の行に移動できること）が編集には不可欠だからだ。10行目を編集した後に3行目に戻り、さらに15行目に移動する――こうした操作には、全行がメモリ上にある必要がある。

grepは検索に特化したことで、この制約を解消した。検索は本質的にシーケンシャル（順次的）だ。ファイルの先頭から末尾まで、一行ずつ順に調べればよい。前の行に戻る必要はない。したがって、grepは一度に一行分のメモリがあれば動作する。

```
メモリモデルの違い:

  ed（エディタ）:
    ファイル全体をバッファにロード → ランダムアクセス可能
    [行1][行2][行3]...[行N] がすべてメモリ上に存在
    → ファイルサイズの制約を受ける

  grep（フィルタ）:
    一行ずつ読み、処理し、捨てる → シーケンシャルアクセスのみ
    [行1] → 処理 → 破棄 → [行2] → 処理 → 破棄 → ...
    → ファイルサイズに制約されない
```

このシーケンシャル処理モデルは、grepをパイプライン向けのフィルタとして理想的な存在にした。標準入力から一行ずつ読み、正規表現とマッチする行だけを標準出力に流す。入力がファイルでもパイプでも動作する。grepは自分の入力元を知る必要がない。

grepの設計は、「edの一部機能を切り出した」以上の意味を持っていた。それは「対話的操作」から「フィルタ処理」へのパラダイムシフトだった。人間がコマンドを一つずつ打つのではなく、プログラムが自動的にテキストストリームを処理する。前回見たパイプの発明（1973年1月）と、grepの誕生（1973年）が同じ年であることは偶然ではない。パイプとフィルタは、同時期に育まれた双子の概念だった。

### grepの派生――egrep、fgrep

grepの成功は、派生ツールの誕生を促した。

egrepは拡張正規表現（Extended Regular Expression）を扱う。grepの正規表現がedに由来する基本的なもの（Basic Regular Expression, BRE）であったのに対し、egrepは `+`（一回以上の繰り返し）、`?`（0回または1回）、`|`（選択）、括弧によるグルーピングを追加した。egrepはAl Ahoがデザインした、決定性有限オートマトン（DFA）ベースのアルゴリズムを使用しており、正規表現の複雑さにかかわらず入力サイズに対して線形時間で動作した。

fgrepは固定文字列（Fixed string）の検索に特化した。正規表現を使わず、リテラル文字列のマッチングだけを高速に実行する。Aho-Corasickアルゴリズムを実装しており、複数のパターンを同時に検索できた。

これらの派生は、POSIX標準では `grep -E`（egrep相当）、`grep -F`（fgrep相当）として統合された。別々のバイナリではなく、一つのgrepコマンドのオプションとして扱われるようになった。だが、egrep、fgrepという名前は長く使われ続け、今日でもエイリアスとして残っている環境は多い。

---

## 4. sed――対話なきエディタ

### 「g/re/d」の予見

sedの誕生には、先見の明があった。

grepが `g/re/p`（パターンにマッチする行を表示する）を独立させたツールであるなら、次に `g/re/d`（パターンにマッチする行を削除する）を独立させるべきだろうか。`g/re/s/old/new/`（パターンにマッチする行で置換を行う）はどうか。edのグローバルコマンドには、p（print）以外にも多くの操作がある。それぞれに専用ツールを作るのか。

Lee McMahonは、この問題の行く末を見通した。grepのような単機能ツールが次々と必要になることを予見し、edのコマンド体系を非対話的に適用できる汎用のストリームエディタを設計した。それがsedだ。1973年から1974年にかけて開発された。

sed――stream editor――という名前は、その設計思想を端的に表している。edが対話的エディタであるのに対し、sedは「ストリーム」に対して動作するエディタだ。人間がコマンドを一行ずつ打つのではなく、あらかじめ記述されたスクリプト（コマンドの列）をテキストストリームに適用する。

### sedの処理モデル

sedの動作は、シンプルなループで表現できる。

```
sedの処理サイクル:

  1. 入力ストリームから一行読む → パターンスペースに格納
  2. スクリプト内のすべてのコマンドを順に適用
  3. パターンスペースの内容を出力ストリームに書き出す
  4. パターンスペースをクリアし、1に戻る

  ┌──────────────────────────────────┐
  │ 入力ストリーム                      │
  │  行1 → 行2 → 行3 → ... → 行N    │
  └──────────┬───────────────────────┘
             ↓
  ┌──────────────────────────────────┐
  │ パターンスペース（作業バッファ）     │
  │  現在処理中の1行                   │
  │                                   │
  │  コマンド1: s/foo/bar/            │
  │  コマンド2: /^#/d                 │
  │  コマンド3: ...                   │
  └──────────┬───────────────────────┘
             ↓
  ┌──────────────────────────────────┐
  │ 出力ストリーム                      │
  │  処理済みの行が順に流れる           │
  └──────────────────────────────────┘
```

ここで重要なのは、sedがgrepと同じシーケンシャル処理モデルを採用している点だ。一行読み、処理し、出力し、次の行に進む。前の行に戻ることは原則としてない（ホールドスペースという二次バッファを使った高度な操作は例外だが、基本の処理サイクルはシーケンシャルだ）。

この設計は、sedをパイプラインのフィルタとして理想的な存在にする。grepと同様、sedは標準入力から読んで標準出力に書く。パイプの中間に配置でき、任意のサイズのデータを処理できる。

### edの操作をストリームに適用する

sedのコマンド構文は、edのそれを忠実に踏襲している。

```bash
# edのコマンド
1,5s/old/new/g       # 1行目から5行目で "old" を "new" に全置換
g/pattern/d           # pattern にマッチする行を削除
3,7p                  # 3行目から7行目を表示

# sedのコマンド（ほぼ同じ構文）
sed '1,5s/old/new/g' file    # 1行目から5行目で "old" を "new" に全置換
sed '/pattern/d' file         # pattern にマッチする行を削除
sed -n '3,7p' file            # 3行目から7行目を表示（-nで自動出力を抑制）
```

edを知っている者にとって、sedの学習コストは極めて低い。edのコマンドをそのままsedのスクリプトとして使える。違いは、edが対話的に一コマンドずつ実行するのに対し、sedはスクリプト全体を一括して適用する点だけだ。

sedの最も頻繁に使われるコマンドは `s`（substitute、置換）だ。edの `s` コマンドと同じ構文で、正規表現によるパターンマッチングと置換を行う。

```bash
# sedの代表的な使い方
sed 's/http:/https:/g' urls.txt         # httpをhttpsに全置換
sed '/^$/d' document.txt                # 空行を削除
sed -n '/ERROR/p' application.log       # ERRORを含む行だけ表示（grepと同等）
sed '1,10d' longfile.txt                # 先頭10行を削除
sed 's/  */ /g' messy.txt               # 連続スペースを1つに圧縮
```

最後の例にある `sed -n '/ERROR/p'` は、grepと同じ動作をする。sedがedのコマンド体系の汎用化であるのだから、grepの機能を内包しているのは当然だ。だが、grepが不要になったわけではない。「特定のパターンにマッチする行を表示する」というタスクにおいて、grepはsedより簡潔であり、高速だ。専用ツールと汎用ツールはそれぞれの存在意義がある。

### sedの配布

sedは1973-74年にMcMahonが開発したが、公式にUNIXのディストリビューションに含まれたのはVersion 7 UNIX（1979年1月）からだ。開発から配布までに5年以上の間隔がある。この間、sedはBell Labsの内部で使用されていたが、外部には配布されていなかった。V7はUNIXの歴史における分水嶺であり、sed、awk、make、lex、lint等の重要ツールが一挙に公式配布された。

---

## 5. awk――テキストフィルタからプログラミング言語へ

### 三人の名前

1977年、Bell LabsでAlfred Aho、Peter Weinberger、Brian KernighanはawkをVersion 7 UNIXで初配布された。名前は三人の姓の頭文字から取られた。

Alfred Ahoは形式言語理論と構文解析の専門家であり、後に "Compilers: Principles, Techniques, and Tools"（通称「ドラゴンブック」）の共著者となる人物だ。Peter Weinbergerはデータベースと数論の研究者。Brian Kernighanは "The C Programming Language"（通称K&R）の共著者であり、UNIXツールの設計と文書化に多大な貢献をした。

三人の専門領域は異なるが、Bell Labsという環境が彼らを一つのプロジェクトに結びつけた。形式言語の理論家、データ処理の実務家、そしてプログラミング言語の設計者。この組み合わせが、awkの独自性を生んだ。

### grep/sedの限界

awkが生まれた背景には、grepとsedでは解決しきれない問題があった。

grepは行のフィルタリングに特化している。パターンにマッチする行を選別することはできるが、行の中身を分解して計算することはできない。sedはedのコマンド体系を非対話的に適用できるが、本質的にはテキスト置換のツールであり、数値計算やフィールド操作には向いていない。

たとえば、CSVファイルの3番目のフィールドの数値を合計するタスクを考える。grepでは行を選別することしかできない。sedでは正規表現による文字列操作はできるが、数値計算はできない。このタスクには、フィールドの分割、数値の抽出、算術演算という、テキスト処理を超えた機能が必要だった。

awkは、この隙間を埋めるために設計された。

### パターン-アクションモデル

awkの中核は、パターン-アクションモデルだ。

```
awkの基本構造:

  パターン { アクション }

  入力の各行に対して:
    パターンがマッチすれば → アクションを実行
    パターンが省略されていれば → すべての行にアクションを適用
    アクションが省略されていれば → マッチした行を表示（print）
```

この構造はgrepの延長線上にある。grepはパターン（正規表現）にマッチする行を表示する。awkはパターンにマッチした行に対して任意のアクションを実行する。「表示する」だけでなく、「計算する」「変換する」「集計する」ことができる。

awkが革新的だったのは、入力行を自動的にフィールドに分割する機能を持っていた点だ。

```bash
# 入力行: 192.168.1.1 - - [15/Jan/2025:10:30:45 +0900] "GET /api HTTP/1.1" 200 1234
#
# awkはこの行を自動的にフィールドに分割する:
# $1 = 192.168.1.1
# $2 = -
# $3 = -
# $4 = [15/Jan/2025:10:30:45
# $5 = +0900]
# ...
# $9 = 200   （ステータスコード）
# $10 = 1234  （レスポンスサイズ）
# $0 = 行全体

# ステータスコードが200の行のURLを表示
awk '$9 == 200 {print $7}' access.log

# 全リクエストのレスポンスサイズの合計を計算
awk '{sum += $10} END {print "Total:", sum, "bytes"}' access.log

# IPアドレスごとのリクエスト数を集計
awk '{count[$1]++} END {for (ip in count) print count[ip], ip}' access.log
```

最後の例を見てほしい。awkは連想配列（キーと値のペアを格納するデータ構造）を内蔵している。`count[$1]++`は、最初のフィールド（IPアドレス）をキーとしてカウンタを増やす。`END`ブロックは全行の処理が完了した後に実行される。

これはもはやテキストフィルタではない。これはプログラミング言語だ。変数、算術演算、連想配列、制御構造（if/else、for、while）、組み込み関数（文字列操作、数学関数）、そしてBEGIN/ENDブロックによる初期化と終了処理。awkは、テキストストリームの上で動作する、完全なプログラミング言語として設計された。

### awkとgrep/sedの関係

awkは grep と sed の機能を内包している。

```bash
# grepと同等（パターンにマッチする行を表示）
awk '/ERROR/' application.log
# → grep 'ERROR' application.log

# sedのs（置換）と同等
awk '{gsub(/http:/, "https:"); print}' urls.txt
# → sed 's/http:/https:/g' urls.txt

# awkにしかできないこと（フィールド演算と集計）
awk -F',' '$3 > 1000 {sum += $3; n++} END {print "Average:", sum/n}' data.csv
```

ではgrepやsedは不要か。そうではない。grepは行のフィルタリングという単一の機能に最適化されており、awkより高速だ。sedはedのコマンド体系に慣れたユーザーにとって直感的であり、特に `s` コマンドによる置換はawkの`gsub`より簡潔に書ける。

UNIX哲学は「一つのことをうまくやるプログラムを書け」と説く。grep、sed、awkはそれぞれの強みを持ち、パイプラインの中で組み合わせて使う。grepで行を絞り込み、awkでフィールドを抽出し、sortで並べ替え、uniqで集計する。各ツールは「一つのこと」に専念し、パイプが組み合わせを可能にする。

### awkの拡張（1985年）

1977年の初版awkには、ユーザー定義関数がなかった。1985年、三人の原作者はawkを大幅に拡張した。ユーザー定義関数、複数入力ストリーム、計算正規表現が追加された。この拡張版はnawk（new awk）と呼ばれ、System V Release 3.1（1987年）で広く配布された。

1988年、Aho、Weinberger、Kernighanは "The AWK Programming Language"（Addison-Wesley）を出版した。この書籍はawkの事実上の言語仕様となり、今日まで参照され続けている。

GNU版のawkであるgawkは、1986年にPaul Rubinが執筆を開始し、Jay Fenlasonが完成させた。gawkはPOSIX仕様に準拠しつつGNU拡張を追加し、Linux環境での標準的なawk実装となった。

---

## 6. テキストストリーム生態系

### 四つのツールの役割分担

ed、grep、sed、awkは、テキストストリームという共通インターフェースの上に構築された生態系を形成している。

```
テキスト処理ツールの生態系:

  入力テキストストリーム
  │
  ├─→ grep: 行の選別（フィルタリング）
  │    パターンにマッチする行だけを通す
  │    最も高速、最も単純
  │
  ├─→ sed: 行の変換（トランスフォーメーション）
  │    edのコマンド体系をストリームに適用
  │    置換、削除、挿入
  │
  ├─→ awk: 行の分析（プログラミング）
  │    フィールド分割、算術演算、集計
  │    パターン-アクション + プログラミング言語
  │
  └─→ パイプラインでの組み合わせ:
       grep → sed → awk の多段処理が可能
       各ツールは標準入力から読み、標準出力に書く
```

この四つのツール（edは直接パイプラインに使うことは少ないが、コマンド体系の源流として）が50年以上共存し続けている理由は、それぞれが異なる抽象レベルで問題を解決しているからだ。

grepは「どの行を残すか」という問題を解く。sedは「行をどう変換するか」という問題を解く。awkは「行のデータからどう計算するか」という問題を解く。抽象レベルが上がるほどツールは複雑になるが、単純なタスクには単純なツールで十分だ。行を選別するだけならgrepが最適であり、awkを持ち出す必要はない。

### 共通規約――行指向テキスト処理

これらのツールが互いに組み合わせられるのは、すべてが同じ規約に従っているからだ。

第一に、入力はテキストストリームとして読み取られる。バイナリデータではなく、改行文字で区切られたテキスト行の列だ。

第二に、処理は行単位で行われる。一行を読み、処理し、結果を出力して、次の行に進む。ファイル全体をメモリにロードする必要はない。

第三に、出力はテキストストリームとして書き出される。次のツールがそれを受け取れる形式で出力する。

この規約は、第7回で見たMcIlroyのUNIX哲学の第三条――「テキストストリームを扱うプログラムを書け。それがユニバーサルインターフェースだからだ」――の体現だ。grep、sed、awkのいずれも、この規約を厳密に守っている。だからこそ、任意の順序で組み合わせることができる。

### 実践例――パイプラインの中のgrep/sed/awk

具体的なパイプラインの例を通じて、各ツールの役割分担を見る。

```bash
# Apacheアクセスログの分析例

# 1. grepで行を絞り込む → awkでフィールドを抽出・集計
grep ' 500 ' access.log | awk '{print $7}' | sort | uniq -c | sort -rn | head -10
# 「500エラーを返しているURLの上位10件」

# 2. sedで変換 → grepで絞り込む → awkで集計
sed 's/\[//; s/\]//' access.log | grep '15/Jan/2025' \
    | awk '{split($4, t, ":"); print t[2]":00"}' | sort | uniq -c
# 「特定日のアクセス数を時間帯別に集計」

# 3. awkだけで完結する複雑な分析
awk '$9 >= 400 {
    error[$9]++
    url[$9" "$7]++
}
END {
    print "=== エラーコード分布 ==="
    for (code in error) print code, error[code]
    print "\n=== エラーURL詳細 ==="
    for (key in url) print url[key], key
}' access.log | sort -rn
# 「エラーコードの分布とURL別の内訳を一括分析」
```

第一の例では、grepが行のフィルタリングという「一つのこと」を担当し、awkがフィールド抽出という「一つのこと」を担当している。sort、uniq -c、headもそれぞれ「一つのこと」だ。パイプラインは、単機能ツールの組み合わせだ。

第三の例では、awkが単体で複雑な分析を完結させている。awkはプログラミング言語であるから、これが可能だ。だが、読みやすさの観点では、第一の例のようにツールを組み合わせた方が各段階の意図が明確になる。

この「組み合わせ」か「単一ツールでの完結」かの判断は、タスクの複雑さとチームの習熟度による。私の経験では、パイプラインの各段階が3〜4個のツールで収まるならば組み合わせが読みやすく、それを超えるならawkスクリプトにまとめた方がメンテナンスしやすい。

### なぜ50年間互換性が保たれているのか

ed（1969年）、grep（1973年）、sed（1973-74年）、awk（1977年）。これらのツールのいずれもが、50年近く経った現在もほぼ同じインターフェースで使われている。なぜか。

第一の理由は、POSIX標準化だ。POSIXはこれらのツールの振る舞いを標準仕様として定義し、異なるOS間での互換性を保証した。Linux、macOS、BSD系のいずれでも、grep、sed、awkは同じ基本構文で動作する（GNU拡張とBSD実装の間に差異はあるが、POSIX準拠の範囲では互換だ）。

第二の理由は、テキストストリームという抽象の普遍性だ。テキストは人間が読め、プログラムが処理でき、あらゆるシステム間で受け渡しできる。この普遍性は、データ形式の流行が変わっても揺るがない。JSONが台頭しようとYAMLが普及しようと、テキストである限りgrep/sed/awkで処理できる。

第三の理由は、ツールの単純さだ。grepは行をフィルタリングする。それだけだ。sedは行を変換する。awkは行を分析する。各ツールの責務が明確であり、「この機能はいずれ不要になる」という種類のものではない。テキストを行単位で処理するという需要は、コンピューティングが存在する限りなくならない。

---

## 7. ハンズオン：edで体験する「画面のない時代」

テキスト処理ツールの系譜を理解するには、その起点であるedを実際に操作するのが最も効果的だ。そしてgrep、sed、awkをパイプラインで組み合わせ、「フィルタの系譜」がどのように機能するかを体験する。

### 演習1：edを使ったテキスト編集

```bash
# edを体験する（Docker環境推奨）
docker run --rm -it ubuntu:24.04 bash -c '
echo "=============================================="
echo "[演習1] edを使ったテキスト編集"
echo "=============================================="
echo ""

echo "--- edでファイルを作成する ---"
echo ""

# edコマンドをスクリプト的に実行する
ed <<EOF
a
The ed editor was written by Ken Thompson in 1969.
It is a line-oriented text editor for UNIX.
The command g/re/p became the grep command.
The substitute command (s) became the core of sed.
AWK added programming capabilities to text processing.
.
w /tmp/history.txt
q
EOF

echo "history.txt の内容:"
cat -n /tmp/history.txt
echo ""

echo "--- edのg/re/pコマンドを使う ---"
echo ""
echo "edの中で g/re/p を実行:"
echo "  g/command/p → \"command\" を含む行を全表示"
echo ""

ed /tmp/history.txt <<EOF
g/command/p
q
EOF

echo ""
echo "→ これがgrepの語源: g(lobal) / re(gular expression) / p(rint)"
echo ""

echo "--- edのsコマンドを使う ---"
echo ""
echo "edの中で置換を実行:"
echo "  1,\$s/UNIX/Unix/g → 全行でUNIXをUnixに置換"
echo ""

ed /tmp/history.txt <<EOF
1,\$s/UNIX/Unix/g
w
q
EOF

echo "置換後の内容:"
cat -n /tmp/history.txt
echo ""
echo "→ これがsedの語源: s(tream) + ed(itor)"
echo ""

rm -f /tmp/history.txt
echo "=============================================="
'
```

### 演習2：grep、sed、awkの段階的パイプライン

```bash
# grep、sed、awkをパイプラインで組み合わせる
docker run --rm -it ubuntu:24.04 bash -c '
echo "=============================================="
echo "[演習2] grep / sed / awk のパイプライン"
echo "=============================================="
echo ""

# サンプルのアクセスログを生成
mkdir -p /tmp/handson
RANDOM=42
for i in $(seq 1 200); do
    IP="10.0.0.$((RANDOM % 30 + 1))"
    CODES=(200 200 200 200 200 200 200 301 404 404 500)
    CODE=${CODES[$((RANDOM % 11))]}
    METHODS=("GET" "GET" "GET" "POST" "PUT" "DELETE")
    METHOD=${METHODS[$((RANDOM % 6))]}
    PATHS=("/index.html" "/api/users" "/api/orders" "/api/products" "/login" "/static/app.js" "/health" "/api/v2/items")
    URLPATH=${PATHS[$((RANDOM % 8))]}
    HOUR=$((RANDOM % 24))
    MIN=$((RANDOM % 60))
    SEC=$((RANDOM % 60))
    SIZE=$((RANDOM % 5000 + 100))
    printf "%s - - [15/Jan/2025:%02d:%02d:%02d +0900] \"%s %s HTTP/1.1\" %d %d\n" \
        "$IP" "$HOUR" "$MIN" "$SEC" "$METHOD" "$URLPATH" "$CODE" "$SIZE" \
        >> /tmp/handson/access.log
done

echo "access.log を生成した（200行）"
echo ""

echo "--- Step 1: grep で行を絞り込む ---"
echo ""
echo "  grep \" 404 \" access.log | head -5"
grep " 404 " /tmp/handson/access.log | head -5 | sed "s/^/  /"
echo "  ..."
COUNT_404=$(grep -c " 404 " /tmp/handson/access.log)
echo ""
echo "  → 404エラーの行: ${COUNT_404}件"
echo ""

echo "--- Step 2: sed で不要部分を変換 ---"
echo ""
echo "  sedで日時フォーマットからブラケットを除去:"
echo "  sed \"s/\\[//; s/\\]//\" でブラケット除去"
grep " 404 " /tmp/handson/access.log | head -3 | sed "s/\[//; s/\]//" | sed "s/^/  /"
echo "  ..."
echo ""

echo "--- Step 3: awk でフィールドを抽出・集計 ---"
echo ""
echo "  404エラーのURL別集計:"
echo "  grep \" 404 \" access.log | awk '"'"'{print \$7}'"'"' | sort | uniq -c | sort -rn"
echo ""
grep " 404 " /tmp/handson/access.log | awk "{print \$7}" | sort | uniq -c | sort -rn | sed "s/^/  /"
echo ""

echo "--- Step 4: awk 単体での高度な分析 ---"
echo ""
echo "  全ステータスコードの分布とバイト数合計:"
echo ""
awk "{
    code[\$9]++
    bytes[\$9] += \$10
}
END {
    printf \"  %-8s %-10s %-15s\n\", \"Code\", \"Count\", \"Total Bytes\"
    printf \"  %-8s %-10s %-15s\n\", \"----\", \"-----\", \"-----------\"
    for (c in code)
        printf \"  %-8s %-10d %-15d\n\", c, code[c], bytes[c]
}" /tmp/handson/access.log | sort -k1
echo ""

echo "--- 比較: 同じタスクを各ツールで ---"
echo ""
echo "  タスク: 404エラーの行を表示する"
echo ""
echo "  grep版:  grep \" 404 \" access.log"
echo "  sed版:   sed -n \"/ 404 /p\" access.log"
echo "  awk版:   awk '"'"'/  404  /{print}'"'"' access.log"
echo ""
echo "  → 結果は同じだが、grepが最も簡潔で高速"
echo "  → 各ツールには最適な用途がある"
echo ""

rm -rf /tmp/handson
echo "=============================================="
'
```

### 演習3：edの `g/re/p` からgrepへの変遷を追体験する

```bash
# edのg/re/pコマンドとgrepの等価性を確認する
docker run --rm -it ubuntu:24.04 bash -c '
echo "=============================================="
echo "[演習3] edのg/re/pからgrepへ"
echo "=============================================="
echo ""

# テスト用ファイルを作成
cat > /tmp/federalist.txt << TEXTEOF
Federalist No. 1: General Introduction (Hamilton)
Federalist No. 2: Concerning Dangers from Foreign Force (Jay)
Federalist No. 10: The Utility of the Union as a Safeguard (Madison)
Federalist No. 51: The Structure of the Government (Madison)
Federalist No. 68: The Mode of Electing the President (Hamilton)
Federalist No. 70: The Executive Department Further Considered (Hamilton)
Federalist No. 78: The Judiciary Department (Hamilton)
Federalist No. 84: Certain General and Miscellaneous Objections (Hamilton)
TEXTEOF

echo "テストファイル（Federalist Papersの一部）:"
cat -n /tmp/federalist.txt
echo ""

echo "--- edの g/re/p コマンド ---"
echo ""
echo "  edで Hamilton を含む行を全表示:"
echo "  g/Hamilton/p"
echo ""
ed /tmp/federalist.txt <<EOF
g/Hamilton/p
q
EOF
echo ""

echo "--- grepコマンド（edから独立したツール）---"
echo ""
echo "  grep Hamilton federalist.txt"
echo ""
grep Hamilton /tmp/federalist.txt | sed "s/^/  /"
echo ""

echo "→ 結果は同じ。grepはedの g/re/p を"
echo "  スタンドアロンのフィルタとして切り出したもの"
echo ""

echo "--- grepの利点: パイプラインで使える ---"
echo ""
echo "  grep Hamilton federalist.txt | wc -l"
HAMILTON_COUNT=$(grep -c Hamilton /tmp/federalist.txt)
echo "  → Hamilton が著者の論文: ${HAMILTON_COUNT}篇"
echo ""
echo "  grep Madison federalist.txt | wc -l"
MADISON_COUNT=$(grep -c Madison /tmp/federalist.txt)
echo "  → Madison が著者の論文: ${MADISON_COUNT}篇"
echo ""
echo "  edではこの「パイプに流す」操作ができない"
echo "  フィルタとして独立したからこそ、組み合わせが可能になった"
echo ""

rm -f /tmp/federalist.txt
echo "=============================================="
'
```

これらの演習で、三つのことが体験できたはずだ。第一に、edのラインエディタとしての操作体系。画面なしでテキストを編集する「不便さ」と、そのコマンド体系の論理性。第二に、edの `g/re/p` コマンドがgrepとして独立したことの意味。対話的操作がフィルタに変わることで、パイプラインに組み込めるようになった。第三に、grep、sed、awkのそれぞれが異なる抽象レベルで問題を解き、パイプラインの中で役割分担していること。

---

## 8. まとめと次回予告

### この回の要点

第一に、edは1969年にKen ThompsonがPDP-7上で開発したラインエディタであり、QED（1965-66年、Butler LampsonとL. Peter Deutsch）の系譜を引く。edのコマンド体系はUNIXテキスト処理ツール群の源流となった。

第二に、grepは1973年、Lee McMahonのFederalist Papers著者分析のためにKen Thompsonが作成した。edの `g/re/p` コマンドを独立したフィルタとして切り出し、シーケンシャル処理モデルにより任意サイズのファイルを扱えるようにした。edのランダムアクセス型メモリモデルからシーケンシャル処理への転換が、パイプライン向けフィルタの設計パターンを確立した。

第三に、sedは1973-74年にLee McMahonが開発した。grepのような単機能ツールが次々と必要になることを予見し、edのコマンド体系を非対話的にストリームに適用する汎用ツールとして設計された。sedはVersion 7 UNIX（1979年）で公式配布された。

第四に、awkは1977年にAlfred Aho、Peter Weinberger、Brian Kernighanが開発した。パターン-アクションモデルにフィールド分割と算術演算を加え、テキストフィルタをプログラミング言語に昇華させた。1985年にユーザー定義関数等の拡張が行われ、1988年に書籍 "The AWK Programming Language" が出版された。

第五に、grep、sed、awkはすべてテキストストリームという共通インターフェースの上に構築されている。行指向処理、標準入力/標準出力の規約を共有することで、パイプラインの中で自在に組み合わせることができる。この共通規約こそが、50年にわたる互換性と共存の基盤だ。

### 冒頭の問いへの暫定回答

なぜUNIXのテキスト処理ツールは50年後の今も使われているのか。

暫定的な答えはこうだ。**これらのツールは、テキストストリームという普遍的インターフェースの上に、明確に役割分担された生態系を形成しているからだ。** grepは選別、sedは変換、awkは分析。それぞれが「一つのこと」に専念し、パイプで組み合わせることで任意の複雑さに対応できる。そしてテキストという抽象は、データ形式の流行が変わっても揺るがない。JSONもYAMLもCSVも、テキストである限りこれらのツールで処理できる。

ツールの名前に歴史が刻まれている。grep は `g/re/p`、sed は stream editor、awk は三人の開発者の頭文字。これらの名前は、1960年代のラインエディタから始まり、パイプの発明を経て、テキストストリーム生態系として結実した進化の証だ。

### 次回予告

次回、第9回「正規表現――CLIを支えるパターン言語」では、ed、grep、sed、awkのすべてに共通する基盤技術――正規表現――の歴史を掘り下げる。Stephen Kleeneの数学理論（1956年）からKen ThompsonのQED実装（1968年）、Henry Spencerのライブラリ、POSIX BRE/ERE、そしてPerl互換正規表現（PCRE）に至る系譜を辿る。

あなたが普段書いている `[0-9]+` や `.*` の一つ一つに、60年以上の歴史が凝縮されている。正規表現は「呪文」ではない。数学の定理から生まれ、UNIXのツール群を通じて実用化された、パターンマッチングの体系だ。次回は、その体系の全貌に迫る。

---

## 参考文献

- Dennis Ritchie, "An incomplete history of the QED Text Editor", Nokia Bell Labs, <https://www.bell-labs.com/usr/dmr/www/qed.html>
- Ken Thompson, "Regular expression search algorithm", Communications of the ACM, Vol.11, No.6, pp.419-422, June 1968
- Wikipedia, "Ed (text editor)", <https://en.wikipedia.org/wiki/Ed_(text_editor)>
- Wikipedia, "QED (text editor)", <https://en.wikipedia.org/wiki/QED_(text_editor)>
- Wikipedia, "Grep", <https://en.wikipedia.org/wiki/Grep>
- Wikipedia, "Sed", <https://en.wikipedia.org/wiki/Sed>
- Wikipedia, "AWK", <https://en.wikipedia.org/wiki/AWK>
- Wikipedia, "Lee E. McMahon", <https://en.wikipedia.org/wiki/Lee_E._McMahon>
- Brian Kernighan, "Brian Kernighan Remembers the Origins of 'grep'", The New Stack, <https://thenewstack.io/brian-kernighan-remembers-the-origins-of-grep/>
- Russ Cox, "Regular Expression Matching Can Be Simple And Fast", <https://swtch.com/~rsc/regexp/regexp1.html>
- Alfred V. Aho, Brian W. Kernighan, Peter J. Weinberger, "The AWK Programming Language", Addison-Wesley, 1988
- GNU Awk User's Guide, "History", <https://www.gnu.org/software/gawk/manual/html_node/History.html>
- Wikipedia, "Version 7 Unix", <https://en.wikipedia.org/wiki/Version_7_Unix>
- Wikipedia, "Vi (text editor)", <https://en.wikipedia.org/wiki/Vi_(text_editor)>
- Two-Bit History, "Where Vim Came From", <https://twobithistory.org/2018/08/05/where-vim-came-from.html>
- Peter H. Salus, "A Quarter Century of Unix", Addison-Wesley, 1994
- Brian Kernighan and Rob Pike, "The UNIX Programming Environment", Prentice Hall, 1984

---

**次回：** 第9回「正規表現――CLIを支えるパターン言語」

---

_本記事は「ターミナルは遺物か――コマンドラインの本質を問い直す」連載の第8回です。_
_ライセンス：CC BY-SA 4.0_
