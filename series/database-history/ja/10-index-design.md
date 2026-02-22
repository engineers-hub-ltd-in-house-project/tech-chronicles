# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第10回：インデックス設計——データベースの「速さ」の正体

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- B-Treeの誕生——1970年にBayerとMcCreightがBoeing研究所で発明したデータ構造が、なぜ50年経った今もデータベースの中核にあるのか
- B+Treeの構造とO(log n)の検索が「速い」理由——ディスクI/Oの物理的制約から読み解く
- 複合インデックスと最左一致の法則——なぜカラムの順序が決定的に重要なのか
- インデックスの選択性（Selectivity）——オプティマイザがインデックスを「使う」「使わない」を判断する基準
- EXPLAIN ANALYZEの読み方——実行計画から問題を特定する技術

---

## 1. 一本のインデックスが変えた夜

2008年頃、私は本番環境の障害対応に追われていた。

ECサイトの商品検索が突然遅くなった。応答時間が通常の数十ミリ秒から5秒以上に跳ね上がり、タイムアウトが頻発している。ユーザーからの問い合わせが殺到し、カスタマーサポートの電話は鳴り止まない。深夜2時、私はSSH越しにMySQLサーバに接続していた。

最初に`SHOW PROCESSLIST`を叩く。スロークエリが山のように積み上がっている。問題のクエリを特定し、`EXPLAIN`を実行した瞬間、原因は一目で分かった。`type: ALL`——フルテーブルスキャンだ。100万行を超える商品テーブルを、先頭から末尾まで一行ずつ舐めている。

原因を遡ると、前日にリリースされた新機能が、新しいWHERE句の条件を追加していた。`category_id`と`status`のAND条件だ。`category_id`の単体インデックスは存在していたが、`category_id`と`status`の複合インデックスはなかった。MySQLのオプティマイザは、既存のインデックスでは十分に絞り込めないと判断し、フルテーブルスキャンを選択していたのだ。

```sql
CREATE INDEX idx_category_status ON products (category_id, status);
```

この一行を実行した。

クエリの応答時間は5秒から3ミリ秒に変わった。約1,700倍の改善だ。インデックス作成にかかった時間は数十秒。障害の発生から解決まで約30分。だが、その30分の間にどれだけの売上が失われたかは、翌日の会議で知ることになる。

この経験は、私にインデックスの本質を叩き込んだ。インデックスとは「データベースを速くするもの」ではない。インデックスとは「データベースがフルテーブルスキャンを避けるための道しるべ」だ。適切なインデックスがなければ、データベースはどれだけ高性能なハードウェアの上で動いていても、全行を愚直に走査するしかない。100万行なら数秒で済むが、1億行になれば数分、10億行になれば——実用に耐えない。

なぜ同じSQLでも、インデックスの有無で100倍、1,000倍の速度差が生まれるのか。その答えは、50年以上前にBoeingの研究所で生まれたデータ構造にある。

---

## 2. B-Treeの誕生——ディスクの物理的制約が生んだデータ構造

### Boeingの研究所から

1970年、Rudolf BayerとEdward M. McCreightは、Boeing Scientific Research Laboratoriesで一つの論文を書き上げた。「Organization and Maintenance of Large Ordered Indexes」——大規模順序付きインデックスの構成と保守。この論文は1970年11月15日にヒューストンで開催されたACM SIGFIDET Workshop（後のSIGMOD）で発表され、1972年にActa Informatica誌に正式出版された。

BayerとMcCreightが解決しようとした問題は明確だった。大量のデータをディスクに格納し、効率的に検索・挿入・削除する方法だ。

1970年当時のコンピュータ環境を想像してほしい。メインメモリは極めて高価で容量が限られている。データの大部分はディスク上に置かれる。そしてディスクアクセスは、メモリアクセスと比較して桁違いに遅い。メモリの参照が数百ナノ秒で完了するのに対し、ディスクの読み取りは数ミリ秒を要する。この差は1万倍以上だ。

二分探索木（Binary Search Tree）はメモリ上では効率的なデータ構造だが、ディスク上では致命的な弱点がある。木の高さがlog₂(n)に比例するため、100万件のデータに対して約20段の木になる。各段のノードが別々のディスクブロックに格納されていれば、1回の検索に20回のディスクアクセスが必要だ。1回のディスクアクセスに10ミリ秒かかるとすれば、検索1回に200ミリ秒。これは実用に耐えない。

BayerとMcCreightの着想は、「一つのノードに複数のキーを格納する」ことだった。ディスクは一度に一つのブロック（通常4KB〜16KB）を読み込む。1ブロックに1つのキーしか格納しないのは無駄だ。1ブロックに数十〜数百のキーを格納すれば、木の高さを劇的に減らせる。

これがB-Treeだ。

論文の実験では、IBM 360/44上で100,000キーのインデックスを毎秒4トランザクション以上で維持できることを実証した。「B」が何を意味するかについて、BayerとMcCreightは一切説明していない。Boeing、balanced、between、broad、bushy、Bayerなど様々な説が提案されているが、いずれも推測に過ぎない。

### B-Treeの基本構造

B-Treeの構造を理解するために、まず単純な例を見よう。

```
B-Tree（次数 m = 4 の例）

                    [30 | 60]
                   /    |    \
          [10 | 20]  [40 | 50]  [70 | 80 | 90]
```

B-Treeの性質は以下の通りだ。

- 各ノードは最大m-1個のキーを持つ（mは次数）
- 各ノードは最大m個の子ノードを持つ
- ルートノード以外の各ノードは、最低⌈m/2⌉個の子を持つ
- すべてのリーフノードは同じ深さにある（高さバランス）
- キーはノード内で昇順に並ぶ

この構造が保証するのは、木の高さが常にlog(n)のオーダーに収まることだ。ただし、二分木のlog₂(n)ではなく、B-Treeではlog_m(n)になる。次数mが大きいほど、木は浅くなる。

実際のデータベースでは、ノードサイズをディスクのブロックサイズ（典型的には8KB〜16KB）に合わせて設計する。1ノードに数百のキーが格納できれば、数百万件のデータでも木の高さは3〜4段で済む。つまり、任意の1件のデータを見つけるのに、ディスクアクセスは3〜4回で済む。二分木の20回と比較すれば、差は歴然だ。

### B+Treeへの進化

現代のデータベースが実際に使用しているのは、B-Treeの変種であるB+Tree（Bプラスツリー）だ。B-Treeとの決定的な違いは二つある。

第一に、データ（レコードへのポインタ）はリーフノードにのみ格納される。内部ノードはキーと子ノードへのポインタだけを持つ。これにより、内部ノードにはより多くのキーを詰め込める。内部ノードの扇出（fanout）が増えれば、木の高さはさらに低くなる。

第二に、リーフノード同士が双方向リンクリストで接続される。これが範囲クエリを劇的に高速化する。

```
B+Tree の構造

内部ノード（キーのみ、データなし）
                    [30 | 60]
                   /    |    \
                  /     |     \
リーフノード（データあり、リンクリストで接続）
[10,20,25] ←→ [30,35,40,50] ←→ [60,70,80,90]
    ↓  ↓  ↓      ↓  ↓  ↓  ↓      ↓  ↓  ↓  ↓
  データへのポインタ（行のアドレス）
```

`WHERE price BETWEEN 30 AND 70`のような範囲検索を考えよう。B+Treeでは、まずルートから辿って`30`を含むリーフノードに到達する。そこからリンクリストを辿り、`70`を超えるまでリーフノードを順に読んでいけばよい。内部ノードに戻る必要はない。リーフノードがディスク上で物理的に連続していれば、シーケンシャルリード——ディスクが最も得意とする読み出しパターン——で処理できる。

対照的に、B-Treeでは範囲検索のたびに内部ノードとリーフノードを行き来する必要があり、ランダムI/Oが増える。この差は、範囲検索が頻繁なデータベースワークロードでは決定的だ。

### 計算量——なぜO(log n)は速いのか

B+Treeの検索計算量はO(log_m n)だ。ここでmはノード内のキー数（扇出）、nはデータの総数。

具体的な数値で考えてみよう。1ノードに500のキーが格納でき、データベースに1億件のレコードがあるとする。

```
木の高さ = log₅₀₀(100,000,000)
         = log(100,000,000) / log(500)
         ≈ 8 / 2.7
         ≈ 3段
```

1億件のデータから任意の1件を見つけるのに、わずか3回のディスクアクセスで済む。しかも、ルートノードと最上位の内部ノードはアクセス頻度が高いため、データベースのバッファプール（メモリキャッシュ）に常駐している可能性が高い。実質的にディスクアクセスは1〜2回で済むことが多い。

フルテーブルスキャンと比較しよう。1億件のテーブルを先頭から走査するなら、全ページを読む必要がある。1ページ8KBで1行が100バイトなら1ページ約80行。1億行なら約125万ページ。シーケンシャルリードだとしても、物理的に125万ページを読む時間は無視できない。

インデックス検索（3回のI/O）対フルテーブルスキャン（125万ページのI/O）。これが冒頭で述べた「1,700倍の速度差」の正体だ。

---

## 3. インデックスの解剖学——種類、設計、トレードオフ

### 複合インデックスと最左一致の法則

複合インデックス（Composite Index / Multi-Column Index）は、複数のカラムを組み合わせたインデックスだ。B+Treeにおける複合インデックスでは、キーは指定されたカラムの順に連結されてソートされる。

```sql
CREATE INDEX idx_name ON users (last_name, first_name, birth_date);
```

このインデックスは、まず`last_name`でソートし、同じ`last_name`の中では`first_name`でソートし、さらに同じ`first_name`の中では`birth_date`でソートする。電話帳と同じ原理だ。姓でまず引き、同姓なら名で引く。

この構造から、「最左一致の法則」（Leftmost Prefix Rule）が導かれる。

```
複合インデックス (last_name, first_name, birth_date) が使えるクエリ:

○ WHERE last_name = 'Tanaka'
  → インデックスのプレフィックス (last_name) に一致

○ WHERE last_name = 'Tanaka' AND first_name = 'Yusuke'
  → インデックスのプレフィックス (last_name, first_name) に一致

○ WHERE last_name = 'Tanaka' AND first_name = 'Yusuke'
    AND birth_date = '1973-01-01'
  → インデックスの全カラムに一致

× WHERE first_name = 'Yusuke'
  → last_name をスキップしている。インデックスは使えない

× WHERE birth_date = '1973-01-01'
  → last_name, first_name をスキップしている。インデックスは使えない

△ WHERE last_name = 'Tanaka' AND birth_date = '1973-01-01'
  → last_name 部分はインデックスで絞れるが、first_name をスキップして
    birth_date で絞ることはできない。last_name の一致後、残りはスキャン
```

なぜこうなるのか。B+Treeのソート構造を考えれば自明だ。電話帳は姓の五十音順に並んでいる。「田中」を探すのは簡単だ。だが「名前が裕介の人」を探すには、電話帳を先頭から末尾まで全ページ見る必要がある。名前は姓ごとにしかソートされておらず、姓をまたいだ名前のソートは存在しないからだ。

複合インデックスの設計では、カラムの順序が決定的に重要だ。順序を誤れば、そのインデックスは使われない。私が冒頭の障害対応で`(category_id, status)`の複合インデックスを追加したのは、クエリが`WHERE category_id = ? AND status = ?`という条件だったからだ。もし`(status, category_id)`の順序でインデックスを作っていたら、クエリの条件は同じでも、オプティマイザの判断は変わりうる（多くの場合は両方のカラムが等値条件なら順序は大きく影響しないが、範囲条件が混ざると話は変わる）。

### インデックスの選択性——オプティマイザの判断基準

インデックスを作れば常に速くなるわけではない。オプティマイザがインデックスを「使わない」と判断する場合がある。その判断基準の核となるのが、選択性（Selectivity）だ。

選択性は、カラム内のユニークな値の数（カーディナリティ）をテーブルの総行数で割った比率として定義される。

```
選択性 = カーディナリティ / 総行数

例：
- email カラム（ユニーク制約あり）: 選択性 = 1.0（最高）
- user_id（外部キー、1万種類、100万行）: 選択性 = 0.01
- status カラム（3種類: active, inactive, deleted）: 選択性 = 0.000003（100万行中）
- gender カラム（2種類）: 選択性 = 0.000002
```

選択性が高い（1.0に近い）カラムほど、インデックスは効果的だ。主キーやユニーク制約のカラムは選択性1.0であり、インデックスによる検索は最も効率が良い。

選択性が低いカラムにB-Treeインデックスを作成しても、効果は薄い。`status`カラムに3種類しか値がない場合、インデックスで`status = 'active'`を検索しても、テーブルの33%の行がヒットする。33%の行をインデックス経由で一つずつ取得するより、フルテーブルスキャンで一括して読んだ方が速い場合がある。これは、インデックス経由のアクセスがランダムI/O（ディスクのあちこちを読む）であるのに対し、フルテーブルスキャンはシーケンシャルI/O（ディスクを先頭から順に読む）だからだ。ランダムI/Oは1回あたりのコストがシーケンシャルI/Oよりはるかに高い。

PostgreSQLのオプティマイザは、テーブルの統計情報（`pg_statistic`テーブルに格納される）を参照してインデックスの使用可否を判断する。統計情報は`ANALYZE`コマンド（またはauto-vacuumによる自動実行）で収集される。統計情報が古い場合、オプティマイザは誤った判断を下すことがある。私が経験した障害の中には、テーブルの大量データ投入後に`ANALYZE`が実行されておらず、オプティマイザが古い統計情報に基づいてフルテーブルスキャンを選択していたケースがあった。

### B+Tree以外のインデックス

B+Treeはデータベースインデックスの主役だが、万能ではない。特定のユースケースに特化したインデックスが複数存在する。

**ハッシュインデックス**は、ハッシュ関数を使ってキーから直接バケット位置を計算する。等値検索（`=`）でO(1)の平均計算量を実現するが、範囲検索（`BETWEEN`、`<`、`>`）には一切対応できない。ハッシュの概念自体は1953年にIBMのHans Peter Luhnが社内メモランダムで記述したほど古い。PostgreSQLではバージョン10（2017年）でWALロギングがサポートされ、ようやくクラッシュセーフなインデックスとして実用的になった。

**ビットマップインデックス**は、カーディナリティの低いカラムに特化した構造だ。各ユニーク値に対してビット列を保持し、ビットのAND/OR演算で高速なフィルタリングを実現する。概念はIsrael SpieglerとRafi Maayanの1985年の研究に遡る。Oracleが7.3.4で実装し、データウェアハウスの分析クエリで広く使われている。ただし、行単位のロックが必要なOLTP環境には不向きだ。

**GiST**（Generalized Search Tree）は、1995年にJoseph Hellerstein、Jeffrey Naughton、Avi Pfefferが発表した汎用検索木フレームワークだ。B+TreeやR-Treeなどの異なる検索木を、同一のインフラストラクチャで実装できるよう一般化した。PostgreSQLの空間データ（PostGIS）のインデックスはGiSTを基盤としている。

**GIN**（Generalized Inverted Index）は、PostgreSQL 8.2（2006年）で導入された転置インデックスだ。一つのカラム値が複数の要素を含む場合——全文検索のtsvector、配列、JSONB——に適している。「この単語を含む文書はどれか」という検索を高速化する。

**BRIN**（Block Range Index）は、PostgreSQL 9.5（2016年）で導入された。テーブルの物理的なブロック範囲ごとに値の要約（最小値・最大値）だけを保持する。時系列データのように、物理的な格納順と値の大小関係に相関があるカラムに対して、B+Treeの数百分の一のサイズで有効なインデックスを提供する。

```
インデックスの種類と適性

                    等値検索  範囲検索  全文検索  空間検索  サイズ
─────────────────────────────────────────────────────────
B+Tree              ◎        ◎        ×        ×        中
Hash                ◎        ×        ×        ×        中
Bitmap              ○        △        ×        ×        小
GiST                ○        ○        ○        ◎        中
GIN                 ◎        △        ◎        ×        大
BRIN                △        ○        ×        ×        極小

◎=最適  ○=対応  △=限定的  ×=非対応
```

### インデックスのコスト——無料の昼食はない

インデックスは検索を高速化するが、コストがある。

**書き込み性能の低下**。テーブルに行を挿入するたび、そのテーブルに定義されたすべてのインデックスも更新される。B+Treeのノード分割（ノードがいっぱいになったとき、二つに分ける操作）はI/Oコストが高い。テーブルに10本のインデックスがあれば、1回のINSERTが11回の書き込み操作（テーブル本体 + 10本のインデックス）に相当する。OLTPシステムで書き込みが支配的なワークロードでは、インデックスの過剰作成が深刻なボトルネックになる。

**ストレージの消費**。インデックスはテーブル本体とは別にディスク領域を占有する。大規模なテーブルでは、インデックスの合計サイズがテーブル本体を上回ることも珍しくない。私は、10GBのテーブルに対して合計25GBのインデックスが存在するシステムを見たことがある。ディスクは安いとは言え、バッファプール（メモリ）に載りきらないインデックスはディスクI/Oを引き起こし、検索速度の低下につながる。

**メンテナンスのオーバーヘッド**。PostgreSQLでは、MVCCの仕組み上、不要になった古いタプルがインデックスにも残る。VACUUMがこの不要タプルを回収するが、大量の更新がある環境ではインデックスの膨張（Index Bloat）が問題になる。定期的なREINDEXが必要になる場合もある。

インデックス設計は「とりあえず全カラムにインデックスを作れば速くなる」という単純な話ではない。検索パターンとデータの特性を理解し、必要最小限のインデックスを設計する——これがインデックス設計の本質だ。

### カバリングインデックス——テーブルへのアクセスを消す

カバリングインデックス（Covering Index）は、クエリが必要とするすべてのカラムをインデックス内に含むことで、テーブル本体へのアクセスを完全に回避する技術だ。

```sql
-- このクエリを考える
SELECT last_name, first_name FROM users WHERE last_name = 'Tanaka';

-- (last_name, first_name) の複合インデックスがあれば:
-- インデックスにlast_nameとfirst_nameの両方が含まれているため
-- テーブル本体を読む必要がない → Index-Only Scan
```

PostgreSQLはバージョン9.2（2012年）でIndex-Only Scanをサポートした。さらにバージョン11（2018年）では`INCLUDE`句が導入され、インデックスのソートキーには含めないが、Index-Only Scanのために保持する追加カラムを指定できるようになった。

```sql
-- PostgreSQL 11以降のINCLUDE句
CREATE INDEX idx_users_covering ON users (last_name)
    INCLUDE (first_name, email);
-- last_nameでソート・検索しつつ、first_nameとemailも
-- インデックスに含める。Index-Only Scanが可能になる。
```

MySQLのInnoDB ストレージエンジンでは、セカンダリインデックスに主キーカラムが暗黙的に含まれるため、主キーカラムを使うクエリではカバリングインデックスとして機能しやすい設計になっている。

---

## 4. EXPLAIN ANALYZEの読み方——実行計画という地図

### コストベースオプティマイザの誕生

クエリオプティマイザがインデックスを使うかどうかをどう判断するのか。この問いの答えは、1979年にまで遡る。

P. Griffiths Selingerらは、IBMのSystem Rプロジェクトの中で「Access Path Selection in a Relational Database Management System」をSIGMOD 1979で発表した。この論文は、I/Oコスト（ディスクページの読み込み回数）とCPU使用量に基づいて最も効率的なアクセスパスを選択する手法を確立した。コストベース最適化（Cost-Based Optimization）の誕生だ。

それ以前のクエリ処理は、ルールベース——たとえば「インデックスがあれば常に使う」「小さいテーブルを先に結合する」——で行われていた。だがルールベースは、データの分布やテーブルサイズの変化に対応できない。100万行のテーブルで選択性が0.001のカラムにインデックスがあれば使うべきだが、選択性が0.5なら使わないほうが速い。この判断はルールでは下せない。

Selingerの論文が確立した原則——テーブルの統計情報に基づいてアクセスパスのコストを見積もり、最もコストの低い計画を選ぶ——は、現在のすべての主要データベースのクエリオプティマイザの基盤となっている。

### EXPLAINの読み方

`EXPLAIN`は、クエリオプティマイザが選択した実行計画を表示するコマンドだ。`EXPLAIN ANALYZE`はさらに一歩進み、実際にクエリを実行して、見積もりと実際の数値を比較する。

PostgreSQLでの例を見よう。

```sql
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE customer_id = 42 AND status = 'shipped';
```

出力例：

```
Index Scan using idx_orders_customer_status on orders
    (cost=0.43..12.50 rows=5 width=120)
    (actual time=0.025..0.030 rows=3 loops=1)
  Index Cond: ((customer_id = 42) AND (status = 'shipped'))
Planning Time: 0.150 ms
Execution Time: 0.055 ms
```

各要素を読み解こう。

**ノードタイプ**（`Index Scan`）は、データへのアクセス方法を示す。主要なノードタイプは以下の通りだ。

```
主要なスキャンノードタイプ

Seq Scan          テーブルを先頭から末尾まで全行走査する（フルテーブルスキャン）
Index Scan        インデックスを使ってテーブルの特定行にアクセスする
Index Only Scan   インデックスだけで結果を返す（テーブルアクセスなし）
Bitmap Index Scan + Bitmap Heap Scan
                  インデックスでビットマップを構築し、テーブルをまとめて読む
```

**コスト**（`cost=0.43..12.50`）は、オプティマイザが見積もったコストだ。左の数値がスタートアップコスト（最初の行を返すまでのコスト）、右の数値がトータルコスト（全行を返すまでのコスト）。単位は任意で、絶対的な意味はない。異なる実行計画のコストを比較するために使う。

**行数の見積もり**（`rows=5`）と**実際の行数**（`rows=3`）。見積もりと実際の乖離が大きい場合、統計情報が古い（`ANALYZE`が必要）か、相関のあるカラムの統計が不十分であることを示す。

**actual time**（`actual time=0.025..0.030`）は、ミリ秒単位の実行時間だ。左がスタートアップ時間、右がトータル時間。

**Seq Scanが表示されたら、必ずしも問題ではない**。小さなテーブル（数百行程度）なら、フルテーブルスキャンの方がインデックスアクセスより速い。インデックスのルートからリーフまで辿るオーバーヘッドの方が、テーブルを丸ごと読むコストより高い場合があるからだ。

### 実行計画が教えてくれること

実行計画を読むとき、私が注目するポイントは三つだ。

第一に、**見積もり行数と実際の行数の乖離**。見積もりが100行で実際が100,000行なら、統計情報が不正確だ。`ANALYZE`を実行し、それでも改善しなければ、相関した条件の組み合わせをオプティマイザが過小評価している可能性がある。PostgreSQL 10以降では拡張統計（Extended Statistics、`CREATE STATISTICS`）で複数カラム間の相関を登録できる。

第二に、**Seq Scanの対象テーブルのサイズ**。数十行のマスタテーブルのSeq Scanは問題ない。だが数百万行のトランザクションテーブルのSeq Scanは、ほぼ確実にインデックスの欠如か不適切なクエリを意味する。

第三に、**Nested Loopの内側のスキャン**。JOINがNested Loopで実行される場合、外側テーブルの各行に対して内側テーブルが繰り返しスキャンされる。内側テーブルのスキャンがSeq Scanなら、外側の行数×内側の全行数が処理される。外側1,000行×内側100,000行=1億行の処理だ。内側テーブルにインデックスがあれば、1,000行×数回のインデックスアクセスで済む。

---

## 5. ハンズオン: インデックスの効果を体感する

今回のハンズオンでは、大量データをロードし、インデックスなし/あり/複合インデックスの各パターンでクエリ速度を計測する。EXPLAIN ANALYZEの出力を読み解き、オプティマイザがどのようにインデックスを選択するかを体験する。

### 演習概要

1. 100万行のテーブルを作成し、インデックスなしでクエリの実行速度を計測する
2. 単一カラムインデックスを追加し、速度の変化を確認する
3. 複合インデックスと最左一致の法則を体験する
4. EXPLAIN ANALYZEの出力を一行ずつ読み解く
5. カバリングインデックスによるIndex-Only Scanを体験する
6. インデックスの選択性と、オプティマイザの判断を観察する

### 環境構築

```bash
# handson/database-history/10-index-design/setup.sh を実行
bash setup.sh
```

### 演習1: インデックスなしの世界

PostgreSQLに接続する。

```bash
docker exec -it db-history-ep10-pg psql -U postgres -d handson
```

setup.shが100万行のordersテーブルを作成している。まずインデックスなしでクエリを実行する。

```sql
-- テーブルの行数を確認
SELECT COUNT(*) FROM orders;
-- → 1,000,000

-- インデックスなしで特定の顧客の注文を検索
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 42;
-- → Seq Scan（フルテーブルスキャン）
-- 全100万行を走査していることを確認する
```

Seq Scanの実行時間を記録しておこう。

### 演習2: 単一カラムインデックスの効果

```sql
-- customer_id にインデックスを追加
CREATE INDEX idx_orders_customer ON orders (customer_id);

-- 同じクエリを再実行
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 42;
-- → Index Scan（またはBitmap Index Scan + Bitmap Heap Scan）
-- 実行時間がSeq Scanと比較してどれだけ改善したかを確認する
```

### 演習3: 複合インデックスと最左一致の法則

```sql
-- 複合インデックスを作成
CREATE INDEX idx_orders_customer_status
    ON orders (customer_id, status);

-- 最左一致でインデックスが使われるパターン
EXPLAIN ANALYZE
SELECT * FROM orders
WHERE customer_id = 42 AND status = 'shipped';
-- → Index Scanになることを確認

-- 最左のカラムだけでも使える
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 42;
-- → Index Scanになることを確認

-- 最左のカラムをスキップするとインデックスは使えない
EXPLAIN ANALYZE
SELECT * FROM orders WHERE status = 'shipped';
-- → Seq Scan になることを確認（statusだけのインデックスがないため）
```

### 演習4: EXPLAIN ANALYZEを読み解く

```sql
-- JOINを含むクエリの実行計画を確認
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT o.id, o.order_date, c.name, p.product_name
FROM orders o
JOIN customers c ON o.customer_id = c.id
JOIN products p ON o.product_id = p.id
WHERE o.customer_id = 42
    AND o.order_date >= '2024-01-01'
    AND o.order_date < '2024-07-01';

-- 出力のポイント:
-- 1. 各ノードのactual rows とestimated rowsを比較する
-- 2. Buffersの値（shared hit = キャッシュヒット、shared read = ディスク読み込み）
-- 3. JOINの方式（Nested Loop, Hash Join, Merge Join）を確認する
```

### 演習5: カバリングインデックスとIndex-Only Scan

```sql
-- 通常のインデックスでのアクセス
EXPLAIN ANALYZE
SELECT customer_id, status FROM orders WHERE customer_id = 42;
-- → Index Scan（テーブルへのアクセスが発生）

-- カバリングインデックスを作成
CREATE INDEX idx_orders_covering
    ON orders (customer_id) INCLUDE (status, order_date);

-- VACUUMでVisibility Mapを更新（Index-Only Scanに必要）
VACUUM orders;

-- 同じクエリを再実行
EXPLAIN ANALYZE
SELECT customer_id, status FROM orders WHERE customer_id = 42;
-- → Index Only Scan（テーブルへのアクセスなし）
-- Heap Fetches: 0 であることを確認する
```

### 演習6: 選択性とオプティマイザの判断

```sql
-- 選択性の低いカラムにインデックスを作成
CREATE INDEX idx_orders_status ON orders (status);

-- 選択性が低い値で検索（status = 'shipped' は全体の約33%）
EXPLAIN ANALYZE
SELECT * FROM orders WHERE status = 'shipped';
-- → オプティマイザがSeq Scanを選ぶかIndex Scanを選ぶか観察する
-- 高い確率でSeq Scanが選ばれる（全体の33%をインデックス経由で
-- ランダムアクセスするより、フルスキャンの方が速いため）

-- 選択性が高い値で検索（status = 'cancelled' が1%しかない場合）
EXPLAIN ANALYZE
SELECT * FROM orders WHERE status = 'cancelled';
-- → Index Scan が選ばれることを確認する
-- 少数の行だけインデックスで取得する方が効率的

-- 統計情報を確認する
SELECT attname, n_distinct, most_common_vals, most_common_freqs
FROM pg_stats
WHERE tablename = 'orders' AND attname = 'status';
```

### 後片付け

```bash
docker rm -f db-history-ep10-pg
```

---

## 6. インデックスは「設計」するものである

第10回を振り返ろう。

**B-Treeは1970年にBayerとMcCreightがBoeing Scientific Research Laboratoriesで発明したデータ構造であり、ディスクI/Oの物理的制約を克服するために、一つのノードに複数のキーを格納して木の高さを最小化する設計だ。** 現代のデータベースはB+Treeを採用し、リーフノードのリンクリスト接続によって範囲クエリを高速化している。1億件のデータでも木の高さは3〜4段に収まり、数回のディスクアクセスで任意の1件を特定できる。

**複合インデックスは最左一致の法則に従い、カラムの順序がインデックスの利用可否を決定する。** 電話帳が姓→名の順でソートされているように、複合インデックスは指定順にソートされており、左端のカラムからの連続したプレフィックスでのみ効率的に検索できる。

**インデックスの選択性は、オプティマイザがインデックスを使うか使わないかの判断基準だ。** カーディナリティの高いカラム（ユニーク値が多い）ほどインデックスの効果は高い。選択性の低いカラムにB-Treeインデックスを作成しても、フルテーブルスキャンに勝てないことがある。

**インデックスには書き込み性能の低下とストレージ消費というコストがある。** テーブルに定義されたすべてのインデックスは、INSERTのたびに更新される。「とりあえずインデックスを作る」のではなく、クエリパターンとデータの特性に基づいて必要最小限のインデックスを設計する姿勢が求められる。

**コストベースオプティマイザは、1979年にSelingerらがSystem Rプロジェクトで確立した原則——テーブルの統計情報に基づいてアクセスパスのコストを見積もり、最もコストの低い計画を選ぶ——に基づいている。** EXPLAIN ANALYZEは、オプティマイザの判断を可視化する窓だ。見積もり行数と実際の行数の乖離、Seq Scanの対象テーブルのサイズ、JOINの内側スキャンのノードタイプ——これらを読み解く力が、データベースの性能問題を解決する鍵になる。

冒頭の問いに戻ろう。「なぜ同じSQLでも、インデックスの有無で100倍速度が変わるのか？」

答えは明快だ。インデックスがなければ、データベースは全行を走査するしかない。B+Treeインデックスがあれば、O(log n)のディスクアクセスで目的の行に直接到達できる。1億行のフルテーブルスキャンと3回のインデックスアクセス——この差が100倍、1,000倍、場合によっては10,000倍の速度差を生む。

だが、インデックスは「貼れば速くなる魔法」ではない。適切なインデックス設計には、データの分布を理解し、クエリパターンを把握し、読み取りと書き込みのバランスを考慮する能力が求められる。インデックスはデータベースの「速さ」の正体であると同時に、エンジニアの「理解」の深さが試される場所でもある。

次回は、一台のデータベースサーバでは足りなくなったとき何が起きるのか——レプリケーションとシャーディングを取り上げる。マスタ・スレーブレプリケーションの緊急導入から始まり、シャーディングがRDBの前提（JOINやトランザクション）を破壊する過程を追う。スケーリングの壁を越える戦いは、やがてNoSQL革命への伏線となる。

あなたのプロジェクトのデータベースに、使われていないインデックスはないだろうか。あるいは、あるべきインデックスが欠けていないだろうか。`EXPLAIN ANALYZE`を一度叩いてみることをお勧めする。そこには、あなたのデータベースの「速さの正体」が映し出されている。

---

### 参考文献

- Rudolf Bayer, Edward M. McCreight, "Organization and Maintenance of Large Ordered Indexes", Acta Informatica, Vol. 1, pp. 173-189, 1972. <https://link.springer.com/article/10.1007/BF00288683>
- P. Griffiths Selinger et al., "Access Path Selection in a Relational Database Management System", SIGMOD 1979. <https://dl.acm.org/doi/10.1145/582095.582099>
- Joseph M. Hellerstein, Jeffrey F. Naughton, Avi Pfeffer, "Generalized Search Trees for Database Systems", VLDB 1995. <https://dsf.berkeley.edu/papers/vldb95-gist.pdf>
- Israel Spiegler, Rafi Maayan, "Storage and Retrieval Considerations of Binary Data Bases", 1985.
- PostgreSQL Documentation, "Indexes". <https://www.postgresql.org/docs/current/indexes.html>
- PostgreSQL Documentation, "Index-Only Scans and Covering Indexes". <https://www.postgresql.org/docs/current/indexes-index-only-scans.html>
- PostgreSQL Documentation, "GIN Indexes". <https://www.postgresql.org/docs/current/gin.html>
- PostgreSQL Documentation, "BRIN Indexes". <https://www.postgresql.org/docs/current/brin.html>
- PostgreSQL Documentation, "Using EXPLAIN". <https://www.postgresql.org/docs/current/using-explain.html>
- Markus Winand, "Use The Index, Luke!". <https://use-the-index-luke.com/>
- Oracle FAQ, "Bitmap Index". <https://www.orafaq.com/wiki/Bitmap_index>
- PlanetScale, "B-trees and database indexes". <https://planetscale.com/blog/btrees-and-database-indexes>

---

**次回予告：** 第11回「レプリケーションとシャーディング——スケールの壁を越える」では、アクセス急増でMySQLが悲鳴を上げた日の記憶から始め、マスタ・スレーブレプリケーションの仕組み、シャーディング戦略の設計、そしてスケーリングがRDBの前提を破壊する過程を追う。CAP定理への布石となるこの回で、分散データベースの世界への扉が開かれる。
