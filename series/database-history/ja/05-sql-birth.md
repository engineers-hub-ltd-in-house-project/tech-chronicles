# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第5回：SQLの誕生——データベースに「言葉」が生まれた日

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- SEQUELが生まれるまでの経緯——SQUAREの挫折と英語風構文への転換
- Donald ChamberlinとRaymond Boyceが1974年に発表した論文の核心
- SEQUELからSQLへの改名の裏にあった商標問題
- SQLの宣言的設計が50年の技術変化に耐えた理由
- クエリオプティマイザという「翻訳者」の発明
- SQL標準化の歴史——SQL-86からSQL:2023まで
- SQLの設計上のトレードオフ——NULLの三値論理と集合演算の罠
- EXPLAIN ANALYZEでオプティマイザの判断を観察する方法

---

## 1. SELECT文に感動した日

2002年頃、私はPHPとMySQLで中規模のWebシステムを作っていた。

当時の私のデータアクセスは、何をするにもファイルの直接操作だった。Perlでopen関数を呼び、ファイルハンドルをつかみ、一行ずつ読み、正規表現で分割し、条件に合うものだけを配列にpushする。必要なデータを取得するたびに、「どこのファイルを開き」「どの順番で読み」「どうフィルタするか」を自分で書いていた。

MySQLに触れてSQLを書き始めたとき、最初に感動したのは`SELECT`文だった。

```sql
SELECT name, email FROM users WHERE age > 30;
```

たったこれだけだ。「usersテーブルから、ageが30より大きいレコードのnameとemailを取り出せ」。ファイルを開く処理もない。レコードを一件ずつ舐める処理もない。条件に合うものだけを拾い集める処理もない。私は「何がほしいか」を宣言しただけで、MySQLが勝手にデータを返してきた。

これは些細なことではない。当時の私にとっては革命だった。

だが同時に、JOINには混乱した。二つのテーブルを「結合」するという概念が、直感的に理解できなかった。`INNER JOIN`と`LEFT JOIN`の違いに戸惑い、`ON`句に何を書けばいいのか分からず、結果としてサブクエリを多用する冗長なSQLを書いていた。JOINが腑に落ちたのは、前回（第4回）で語ったCoddの関係代数——特に結合操作の概念——を理解してからのことだ。

あの頃の私は、SQLが「なぜあのような形」をしているのか考えもしなかった。`SELECT ... FROM ... WHERE`という構文が、なぜこの順番なのか。なぜ手続き的に「まずテーブルを開き、次にフィルタし、最後に列を選ぶ」という順序ではないのか。SQLがこの形をしている理由には、半世紀前の設計判断がある。

あなたは、SQLを「なぜあの形なのか」と考えたことがあるだろうか。もしないなら、今回の記事が、その問いに向き合うきっかけになれば幸いだ。

---

## 2. SQUAREの挫折——最初の言語は数学すぎた

### Coddのリレーショナルモデルから言語へ

前回見たように、Edgar F. Coddは1970年の論文でリレーショナルモデルを提唱し、関係代数と関係論理というデータ操作の数学的基盤を定義した。だがCoddの論文は「モデル」を定義しただけであり、具体的な問い合わせ言語の設計には踏み込んでいない。

リレーショナルモデルがいかに優れた数学的基盤を持っていても、現場のプログラマやエンドユーザーが日常的に使える「言葉」がなければ、モデルは理論のまま終わる。データベースに語りかける「言語」が必要だった。

1971年、IBMのT.J. Watson Research Center（ニューヨーク州ヨークタウンハイツ）にいたDonald D. Chamberlinは、Coddのリレーショナルモデルに関する社内セミナーに参加した。Chamberlinは1944年カリフォルニア州サンノゼ生まれ、Harvey Mudd College（1966年BS）、Stanford大学（1967年MS、1971年PhD、電気工学）を経てIBMに入社したばかりだった。

Coddの講演を聞いたChamberlinは衝撃を受けた。階層型データベースIMSではプログラマがデータの物理的な格納構造を熟知していなければならなかったのに対し、リレーショナルモデルではデータの論理的な構造だけを知っていればよい。この「解放」に魅了されたChamberlinは、リレーショナルモデルの実用化に取り組み始める。

### SQUARE——数学的に正確、だが使えない

ChamberlinとRaymond F. Boyceが最初に設計したリレーショナル言語は、SQUARE（Specifying Queries As Relational Expressions）だった。

SQUAREは関係代数の操作を忠実に反映した集合指向のデータ副言語であり、関係的完全性——関係代数で表現できるすべての問い合わせを表現できる能力——を備えていた。1975年にCommunications of the ACM, Vol.18, No.11に"Specifying Queries as Relational Expressions: The SQUARE Data Sublanguage"として発表されている（著者: Boyce, Chamberlin, King）。

だがSQUAREには致命的な問題があった。

SQUAREの構文は数学的な表記に依存しており、上付き文字（superscript）と下付き文字（subscript）を多用していた。紙の上では美しい。だがコンピュータの端末に上付き・下付き文字を入力する手段は、1970年代には存在しなかった。テレタイプ端末やCRT端末のキーボードは、大文字と小文字のアルファベット、数字、いくつかの記号しか扱えない。

数学的に正確であることと、実用的に使えることは、まったく別の問題だった。

この経験が、ChamberlinとBoyceに決定的な方向転換をもたらす。数学的記法を捨て、英語風のキーワードで構成された構文を採用する。専門家でなくても読み書きできる「構造化された英語」としてデータベースに問い合わせる言語——SEQUELの構想はここから始まった。

### 1973年——San Jose研究所への移動

1973年、ChamberlinはIBM T.J. Watson Research CenterからSan Jose Research Laboratory（カリフォルニア州サンノゼ）に移った。ここはCoddがリレーショナルモデルの論文を書いた場所であり、リレーショナルモデルの実装可能性を実証するSystem Rプロジェクトが動き始めていた。

ChamberlinはSystem RプロジェクトにおいてSEQUELの設計と実装を担当することになる。相棒のRaymond F. Boyceも同じラボに在籍していた。

---

## 3. SEQUEL——データベースに「言葉」が生まれた日

### 1974年6月——SIGFIDET 1974

1974年6月、ミシガン州アナーバーで開催されたACM SIGFIDET（現SIGMOD）ワークショップに、一本の論文が提出された。Proceedings の249ページ目に収録されたその論文のタイトルは、"SEQUEL: A Structured English Query Language"。著者はDonald D. ChamberlinとRaymond F. Boyce。

このワークショップは、データベースの歴史にとって特別な場だった。ネットワーク型データモデルの提唱者であるCharles Bachmanと、リレーショナルモデルの提唱者であるEdgar F. Coddの両者が参加し、それぞれのデータモデルの優位性を主張する特別セッションが開かれた。SEQUEL論文は、その論争の渦中に生まれたのだ。

### SEQUELの設計思想

SEQUELの設計において、ChamberlinとBoyceが掲げた目標は明確だった。

一つ目は、リレーショナルデータベースに対する問い合わせを、束縛変数（bound variable）や量化子（quantifier）を使わずに表現すること。関係論理（relational calculus）に基づく言語は数学的に厳密だが、`∀`（全称量化子）や`∃`（存在量化子）といった記号は、数学のトレーニングを受けていない人間にとって壁になる。SEQUELは、これらの概念を英語のキーワード（`SELECT`, `FROM`, `WHERE`, `GROUP BY`など）で置き換えた。

二つ目は、一階述語論理と同等の表現力を保つこと。英語風にしたからといって表現力を犠牲にしてはならない。SEQUELは関係的に完全——関係代数で表現できるすべての操作を表現できる——であることが論文中で示された。

この二つの目標を同時に達成したことが、SEQUELの革新性だ。

```
SEQUELの設計目標

  ┌──────────────────────────────────────────────────┐
  │                  SEQUEL                          │
  │                                                  │
  │   ┌─────────────────┐  ┌─────────────────┐     │
  │   │ 表現力          │  │ 使いやすさ      │     │
  │   │ （関係的完全性） │  │ （英語風構文）  │     │
  │   │                 │  │                 │     │
  │   │ 一階述語論理と  │  │ 量化子・束縛    │     │
  │   │ 同等の問い合わせ│  │ 変数を排除      │     │
  │   │ 能力            │  │ 非専門家でも    │     │
  │   │                 │  │ 読み書き可能    │     │
  │   └─────────────────┘  └─────────────────┘     │
  │                                                  │
  │   SQUAREは前者のみ、SEQUELは両方を達成          │
  └──────────────────────────────────────────────────┘
```

### 宣言的であること——「何を」と「どうやって」の分離

SEQUELの最も根源的な特徴は、宣言的（declarative）であることだ。

手続き型（procedural）の言語では、プログラマは「どうやって」データを取得するかを一つ一つ指示する。ファイルを開き、インデックスを辿り、条件を評価し、結果を集める。IMS（階層型データベース）のDL/IやCODASYL系のDMLは手続き型だった。第3回で見たように、DL/Iでは`GU`でルートセグメントを取得し、`GNP`で子セグメントを辿るというナビゲーション的なアクセスが必要だった。

SEQUELは違う。

```sql
-- SEQUEL(SQL)の場合: 「何がほしいか」だけを宣言する
SELECT employee_name, department
FROM employees
WHERE salary > 50000;
```

このSQL文には、テーブルの物理的な格納位置を指定するコードはない。インデックスを使うかフルスキャンするかの指定もない。レコードをどの順番で読むかの指示もない。プログラマは「何がほしいか」を宣言するだけで、「どうやって取るか」はデータベースエンジンに委ねる。

この「何を」と「どうやって」の分離こそ、Coddが1970年の論文で提唱した「データの論理的独立性」を言語レベルで実現したものだ。

だが考えてみてほしい。「何がほしいか」だけを宣言して、誰がそれを「効率的に取得する方法」に翻訳するのか。この翻訳を担う存在が、後にクエリオプティマイザと呼ばれることになる。その話は、System Rの節で改めて語る。

### DDL/DML/DCLの統合

1974年のSEQUEL論文はデータの問い合わせ（SELECT）が中心だった。だがSEQUELの設計は、問い合わせだけに留まらなかった。

1976年、ChamberlinらはSEQUEL 2を発表し、言語を大幅に拡張した。データの挿入（INSERT）、更新（UPDATE）、削除（DELETE）。テーブルやビューの定義（CREATE TABLE, CREATE VIEW）。整合性制約（ASSERTION）。トリガー。これらの機能が一つの言語体系に統合された。

最終的にSQLは、三つのサブ言語を一つの体系に包含することになった。

- **DDL（Data Definition Language）**: データの構造を定義する。`CREATE TABLE`, `ALTER TABLE`, `DROP TABLE`。データベースのスキーマ——テーブル、列、型、制約——を宣言する言語だ。
- **DML（Data Manipulation Language）**: データを操作する。`SELECT`, `INSERT`, `UPDATE`, `DELETE`。データの問い合わせと変更を行う言語だ。
- **DCL（Data Control Language）**: データへのアクセスを制御する。`GRANT`, `REVOKE`。誰がどのデータに対してどの操作を行えるかを定義する言語だ。

この統合は重要だ。階層型データベースIMSでは、データの定義は専用のユーティリティで行い、データの操作はDL/Iで行い、アクセス制御はまた別の仕組みで行っていた。SQLはこれらをすべて一つの言語に統合した。データベースに関するすべての宣言を、一つの「言葉」で行えるようにしたのだ。

### SEQUELからSQLへ——商標問題

SEQUELの名前は長く続かなかった。

イギリスのHawker Siddeley Dynamics Engineering Limited社——航空機・軍事システムのメーカー——が"SEQUEL"を商標として保有していたのだ。IBMは法的な衝突を避けるため、母音を削除して"SQL"に改名した。この改名は1976年から1977年頃、System RのPhase 1期間中に行われたとされる。

改名後の正式な発音は「エス・キュー・エル」だ。だが共同開発者のChamberlin自身を含め、多くの英語話者は今でも「シークェル」と発音する。50年経っても発音が統一されない言語は珍しい。だが考えてみれば、これはSQLがいかに広く、いかに多様な人々に使われているかの証左でもある。

ちなみに、SEQUELという名前自体が、UC BerkeleyのINGRESプロジェクトが使っていた問い合わせ言語QUEL（Query Language）に対する掛け言葉だったという説がある。SEQUELはQUELの「続編（sequel）」というわけだ。真偽は定かではないが、当時のIBMとBerkeleyの間に健全な競争意識があったことは確かだ。

---

## 4. System Rとクエリオプティマイザ——「翻訳者」の発明

### System Rの3段階

SQLの設計は、System Rプロジェクトの中で具現化された。

System Rは1974年から1979年にかけて、IBM San Jose Research Laboratoryで開発されたリレーショナルデータベースの研究プロトタイプだ。このプロジェクトの目的は、Coddのリレーショナルモデルが実用的なデータベースシステムとして実装可能であることを実証することにあった。

開発は3段階で進行した。

**Phase 0（1974-1975年）**: 初期プロトタイプ。XRMストレージマネージャ上にシングルユーザーシステムを構築。SEQUELのサブセットを実装したが、JOINも並行制御もリカバリもなかった。この段階の目的は、SEQUELの構文と基本的な操作が「使えるか」の検証だった。

**Phase 1（1976-1977年）**: 本格的なマルチユーザーシステム。RDS（Relational Data System）とRSS（Relational Storage System）の2層アーキテクチャを採用。B-Treeインデックス、ロック機構、ログベースのリカバリを実装した。言語はSEQUEL 2（後にSQL）に拡張され、INSERT、UPDATE、DELETE、ビュー、整合性制約が追加された。1977年6月には航空エンジンメーカーのPratt & Whitneyで、初の外部顧客へのインストールが行われた。

**Phase 2（1978-1979年）**: フィールドテストと性能評価。3つの外部顧客サイトで実験運用が行われ、実際のビジネスワークロードに対するSQLの実用性が検証された。この段階で発見された問題の一つに、ロック機構の「コンボイ現象（convoy phenomenon）」がある——高負荷時にロック待ちのトランザクションが列を成し、スループットが劇的に低下する現象だ。

### Patricia Selinger——クエリオプティマイザの母

SQLが宣言的であるということは、「何がほしいか」を書くだけでよいということだ。だが裏を返せば、データベースエンジンが「どうやって取得するか」を自分で判断しなければならない。同じSQLでも、実行方法は複数存在する。

たとえば次のクエリを考えよう。

```sql
SELECT e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_code = d.dept_code
WHERE d.location = 'Tokyo';
```

このクエリを実行する方法は一つではない。

1. まず`departments`をフィルタして`location = 'Tokyo'`の行を絞り、次に`employees`と結合する
2. まず`employees`と`departments`を全結合し、次に`location = 'Tokyo'`でフィルタする
3. `employees`にインデックスがあれば、それを使って`dept_code`で直接探索する

どの方法が最も効率的かは、テーブルのサイズ、インデックスの有無、データの分布に依存する。この判断を自動的に行う仕組みが、クエリオプティマイザだ。

1979年、System RチームのPatricia Selinger（旧姓Griffiths）らは、ACM SIGMOD Conferenceで画期的な論文を発表した。"Access Path Selection in a Relational Database Management System"（共著: Astrahan, Chamberlin, Lorie, Price）。この論文は、コストベースのクエリ最適化という概念を初めて体系的に定式化したものだ。

Selingerのアプローチは次のようなものだった。

1. クエリから考えられるすべての実行計画（アクセスパス）を列挙する
2. 各実行計画のコスト（ディスクI/O回数、CPU使用量など）を統計情報に基づいて推定する
3. 最もコストの低い実行計画を選択する

この手法の核心は、動的計画法（dynamic programming）を用いたJOIN順序の最適化にある。N個のテーブルを結合する場合、可能なJOIN順序はN!通りある。3テーブルなら6通り、5テーブルなら120通り、10テーブルなら360万通りだ。すべての組み合わせを愚直に評価するのは現実的ではない。Selingerの動的計画法アルゴリズムは、部分問題の最適解を再利用することで、計算量を劇的に削減した。

```
コストベースクエリオプティマイザの動作

     SQL文
       │
       ▼
  ┌──────────────┐
  │ パーサー     │  SQL文を構文解析
  └──────┬───────┘
         ▼
  ┌──────────────┐
  │ プランナー   │  実行計画の候補を列挙
  │              │
  │  Plan A: 推定コスト 1,200  │
  │  Plan B: 推定コスト 340    │  ← 統計情報
  │  Plan C: 推定コスト 15,000 │    を参照
  └──────┬───────┘
         ▼
  ┌──────────────┐
  │ 最適計画選択 │  Plan B を選択
  └──────┬───────┘
         ▼
  ┌──────────────┐
  │ エグゼキュータ│  Plan B に従って実行
  └──────────────┘
```

Selingerの論文が発表された1979年から45年以上が経つが、コストベースクエリ最適化の基本的な枠組みは現在のほぼすべてのRDBMS——PostgreSQL、MySQL、Oracle、SQL Server——に受け継がれている。動的計画法によるJOIN順序の決定は、今もクエリオプティマイザの中核をなす技術だ。

クエリオプティマイザの存在こそが、SQLの宣言的性質を実用に堪えるものにした。もしオプティマイザがなければ、「何がほしいか」を宣言するだけでは性能が出ない。プログラマが自分で最適な実行計画を指定しなければならなくなり、それは結局、手続き型言語と変わらなくなる。SQLの宣言性とオプティマイザの最適化は、切り離せない表裏の関係にある。

### Raymond Boyceの早世

ここで、一つの悲劇について触れなければならない。

1974年6月16日、Raymond F. Boyceはくも膜下出血（脳動脈瘤破裂）のため、27歳で急逝した。SEQUEL論文の発表とほぼ同時期のことだ。Purdue大学で計算機科学の博士号を1972年に取得したばかりの若き研究者は、妻Sandyと生後10ヶ月の娘Kristinを残してこの世を去った。

BoyceはSEQUELの共同開発者であるだけでなく、第4回で紹介したBoyce-Codd正規形（BCNF）の共同定義者でもある。SQLが世界中のデータベースの標準言語となり、BCNFがデータベース設計の基礎知識として教えられる今日、その共同発明者がいずれの成果も見届けることなく逝ったという事実は、技術史の残酷な一面だ。

ChamberlinはBoyceの死後もSQLの発展に生涯を捧げた。System Rプロジェクトを率い、SQLの商用化を推進し、2003年にはIBM Fellowに任命された。2009年にIBMを退職した後も、2024年にはCommunications of the ACMに"50 Years of Queries"と題した回顧論文を発表し、SQL誕生から半世紀の歴史を振り返っている。

---

## 5. SQLの設計上のトレードオフ——50年の議論

### NULLと三値論理

SQLには、設計上の議論が50年にわたって続いている問題がいくつかある。その中で最も根深いのが、NULLの扱いだ。

通常のプログラミング言語は二値論理（TRUE / FALSE）で動作する。SQLは違う。NULLの存在により、SQLは三値論理（TRUE / FALSE / UNKNOWN）で動作する。

NULLは「値がない」ことを表す。だが「値がない」にも種類がある。「まだ入力されていない」のか、「そもそも適用されない」のか、「分からない」のか。SQLのNULLはこれらを区別しない。そしてNULLとの比較は、TRUEでもFALSEでもない第三の値——UNKNOWN——を返す。

```sql
-- NULLとの比較はUNKNOWNを返す
SELECT * FROM employees WHERE bonus = NULL;    -- 何も返さない！
SELECT * FROM employees WHERE bonus <> NULL;   -- これも何も返さない！
SELECT * FROM employees WHERE bonus IS NULL;   -- これが正しい書き方
```

`bonus = NULL`がTRUEにならないのは直感に反する。だがSQLの論理では、NULLとの`=`比較はUNKNOWNを返し、`WHERE`句はUNKNOWNの行を結果に含めない。これを理解していないと、バグの原因になる。

三値論理の影響はさらに広がる。

```sql
-- 三値論理のAND/OR
-- TRUE AND UNKNOWN = UNKNOWN
-- FALSE AND UNKNOWN = FALSE
-- TRUE OR UNKNOWN = TRUE
-- FALSE OR UNKNOWN = UNKNOWN
-- NOT UNKNOWN = UNKNOWN
```

この振る舞いは数学的には一貫しているが、多くのプログラマの直感に反する。

Codd自身も、SQLのNULL実装には不満を持っていた。1990年の著書『The Relational Model for Database Management: Version 2』で、Coddは2種類のNull——"Missing but Applicable"（A-values: 値は存在するが未知）と"Missing but Inapplicable"（I-values: そもそもその属性が適用されない）——に分けるべきだと提案している。

C.J. DateとHugh Darwenはさらに踏み込み、『The Third Manifesto』でNULLの存在自体がリレーショナルモデルの原則に反すると主張した。Coddが定義したリレーションは集合論に基づいており、集合の要素は「存在する」か「存在しない」かの二択であって、「不明」という状態は想定されていないからだ。

だが現実のデータには「値がない」状況が頻繁に発生する。NULLを排除すれば、デフォルト値やセンチネル値（-1, "N/A"など）で代用するしかなく、それはそれで別の問題を引き起こす。NULLの三値論理は、50年経った今も「最もましな妥協」として使われ続けている。

### 集合演算の直感に反する挙動

もう一つ、SQLの設計でしばしば議論になるのが、集合演算の扱いだ。

リレーショナルモデルにおいて、リレーション（テーブル）は数学的な集合だ。集合には重複する要素がない。だがSQLのテーブルは、デフォルトでは重複行を許容する。`SELECT`の結果も、重複を含む。重複を排除するには明示的に`DISTINCT`を指定しなければならない。

```sql
-- 重複を含む結果
SELECT dept_code FROM employees;
-- D01, D02, D01, D03 ← 重複あり

-- 重複を排除
SELECT DISTINCT dept_code FROM employees;
-- D01, D02, D03
```

なぜSQLはデフォルトで重複を排除しないのか。理由はパフォーマンスだ。重複排除にはソートやハッシュ処理が必要で、大量データでは無視できないコストがかかる。多くの実用的なクエリでは重複が問題にならないため、デフォルトで重複を許容し、必要なときだけ`DISTINCT`で排除する設計が選ばれた。

この決定は実用的には妥当だが、理論的にはリレーショナルモデルからの逸脱だ。SQLのテーブルは厳密にはリレーション（集合）ではなくマルチセット（多重集合、バッグ）だ。この違いは通常は問題にならないが、集合演算（`UNION`, `INTERSECT`, `EXCEPT`）を使うときに混乱を招くことがある。

```sql
-- UNIONは重複を排除する（集合としての和）
SELECT dept_code FROM employees
UNION
SELECT dept_code FROM former_employees;

-- UNION ALLは重複を残す（多重集合としての和）
SELECT dept_code FROM employees
UNION ALL
SELECT dept_code FROM former_employees;
```

`UNION`はデフォルトで重複を排除するのに、`SELECT`はデフォルトで重複を残す。この非対称性は、SQLの設計が理論的純粋さと実用的性能のあいだで揺れ動いた痕跡だ。

### QUELとの競合——なぜSQLが勝ったのか

SQLの設計上のトレードオフを語る上で、もう一つの問い合わせ言語にも触れておく必要がある。UC BerkeleyのINGRESプロジェクトが開発したQUEL（Query Language）だ。

QUELはCoddが提案した関係論理（タプル関係論理）に基づく言語であり、多くのデータベース研究者はQUELの方がSQLよりも理論的に優れていると評価していた。特にクエリの合成可能性（composability）——クエリの結果を別のクエリに入力として使う操作のしやすさ——においてQUELはSQLよりも洗練されていた。INGRESのリーダーであるMichael Stonebraker自身も、QUELの方が「作りやすい」言語だったと述べている。

だがSQLが勝った。

勝因は技術的な優位性ではなく、商用化と標準化だ。

1979年、Larry EllisonらのRelational Software, Inc.（後のOracle Corporation）がOracle V2を発表した。世界初の商用SQLデータベースだ。1981年にはIBMがSQL/DSを、1983年にはDB2を市場に投入した。SQLは商用製品の言語として先行した。

決定的だったのは1986年のANSI標準化だ。ANSIがSQL-86として標準を制定したとき、QUELは標準に選ばれなかった。この瞬間、SQLは「業界標準」の座を確保し、QUELは過去のものとなった。INGRESもQUELからSQLへの移行を余儀なくされたが、この移行には約3年を要し、その間にOracleやDB2に市場シェアを奪われた。

この歴史は、前回の記事で語ったCoddのリレーショナルモデルとIMSの関係に似ている。技術的に「正しい」ものが市場で勝つとは限らない。標準化とエコシステムの形成が、技術の勝敗を決する。

---

## 6. SQL標準化の50年——SQL-86からSQL:2023まで

### 標準化への道

SQLが「特定のベンダーの言語」から「業界標準」になるまでには、時間がかかった。

1970年代後半から1980年代前半にかけて、Oracle、IBM（SQL/DS、DB2）、その他のベンダーがそれぞれ独自にSQLを実装した。だが各社の「SQL」は微妙に異なっていた。同じSQLが異なるデータベースで動かないという状況は、ユーザーにとって大きな問題だった。

1986年、ANSI（American National Standards Institute）がSQLの最初の標準を制定した。SQL-86だ。翌1987年にはISO 9075としてISO標準にもなった。ここからSQL標準化の歴史が始まる。

### 主要な標準の進化

**SQL-86（1986年）**: 最初の標準。基本的なSELECT、INSERT、UPDATE、DELETE、CREATE TABLE、GRANT/REVOKEを定義。だが範囲は限定的で、多くの機能がベンダー拡張に委ねられた。

**SQL-89（1989年）**: 小規模改訂。PRIMARY KEY、FOREIGN KEY、DEFAULT、CHECK制約を追加。SQLの「参照整合性」の基盤が標準化された。

**SQL-92（1992年）**: 大規模改訂。約600ページに拡大し、「SQL 2」とも呼ばれた。OUTER JOIN、CASE式、CAST、文字列関数、日時型が追加された。SQL-92は「安定した基盤」として、今日に至るSQLの中核を形成した。

**SQL:1999（1999年）**: 「SQL 3」。2,000ページを超える大規模標準となった。再帰共通テーブル式（recursive CTE）、トリガー、ユーザー定義型、ロール（ROLE）、正規表現が追加された。オブジェクトリレーショナル機能の導入も行われたが、実装するベンダーは限定的だった。

**SQL:2003（2003年）**: ウィンドウ関数（OVER句）、XML対応（SQL/XML）、MERGE文、自動生成列（GENERATED ALWAYS）が追加された。ウィンドウ関数はSQLのデータ分析能力を飛躍的に拡張した。

**SQL:2011（2011年）**: テンポラルデータベース（時制テーブル）の導入。データの時間的な変遷を扱う機能が標準化された。

**SQL:2016（2016年）**: JSON対応。`JSON_VALUE`, `JSON_QUERY`, `JSON_TABLE`など、JSONデータをSQLから操作する機能が追加された。行パターン認識（MATCH_RECOGNIZE）も導入された。

**SQL:2023（2023年）**: 最新の標準（第9版、ISO/IEC 9075:2023）。最大の目玉はPart 16として追加されたSQL/PGQ（Property Graph Queries）——SQLからプロパティグラフデータを問い合わせる機能だ。リレーショナルテーブルのデータをグラフとして扱い、パス探索やパターンマッチングを行える。さらにJSONデータ型の正式追加、GREATEST/LEAST関数、LPAD/RPAD関数なども導入された。

```
SQL標準の進化（1986-2023年）

  SQL-86 ─── 基本DML/DDL ─────────────── "最初の一歩"
    │
  SQL-89 ─── PRIMARY KEY, FOREIGN KEY ── "参照整合性"
    │
  SQL-92 ─── OUTER JOIN, CASE, CAST ──── "安定した基盤"
    │
  SQL:1999 ── CTE, トリガー, 正規表現 ── "2,000ページ超"
    │
  SQL:2003 ── ウィンドウ関数, XML ────── "分析能力の拡張"
    │
  SQL:2011 ── テンポラルDB ──────────── "時間の導入"
    │
  SQL:2016 ── JSON対応 ──────────────── "半構造化データ"
    │
  SQL:2023 ── グラフクエリ, JSON型 ──── "グラフの統合"
```

### 標準と現実の乖離

ここで正直に言わなければならないことがある。SQL標準は、現実のSQLの使い方と必ずしも一致しない。

各RDBMSは標準の一部しか実装していない。PostgreSQLはSQL標準への準拠度が高いことで知られるが、それでもSQL:2023のすべての機能を実装しているわけではない。MySQLは歴史的にSQL標準への準拠度が低く、独自の拡張が多い。OracleのPL/SQL、SQL ServerのT-SQL、PostgreSQLのPL/pgSQLは、いずれもSQL標準にはない手続き型拡張だ。

現場のエンジニアが日常的に書くSQLは、純粋なANSI SQLではなく、使っているRDBMS固有の方言であることが多い。それでもSQL標準は「共通語」としての役割を果たしている。異なるRDBMSを行き来するとき、SQLの基本的な構文と意味論が共有されていることの価値は計り知れない。

---

## 7. ハンズオン: SQLの宣言的性質を体験する

今回のハンズオンでは、SQLの宣言的性質を体験する。同じ結果を返す複数のSQLを書き、`EXPLAIN ANALYZE`でオプティマイザの判断を観察する。

### 演習概要

1. 同じ結果を返す複数のSQL文を書き、オプティマイザの判断を比較する
2. インデックスの有無でオプティマイザの判断が変わることを確認する
3. NULLの三値論理の挙動を体験する
4. ウィンドウ関数でSQLの宣言的な表現力を実感する

### 環境構築

Docker環境で PostgreSQL を使用する。

```bash
docker run -it --rm -e POSTGRES_PASSWORD=handson postgres:17 bash -c "
  su - postgres -c 'pg_ctl start -D /var/lib/postgresql/data -l /tmp/pg.log -o \"-c listen_addresses=localhost\" && sleep 2 && psql'
"
```

もしくは、以下のセットアップスクリプトを使用する。

```bash
# handson/database-history/05-sql-birth/setup.sh を実行
bash setup.sh
```

### 演習1: 同じ結果を返す複数のSQL——オプティマイザの判断

```sql
-- テストデータの作成
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    dept_code TEXT NOT NULL,
    salary INTEGER NOT NULL,
    hire_date DATE NOT NULL
);

CREATE TABLE departments (
    dept_code TEXT PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT NOT NULL
);

-- 大量データの投入（オプティマイザの判断を観察するため）
INSERT INTO departments VALUES
    ('D01', 'Sales', 'Tokyo'),
    ('D02', 'Engineering', 'Osaka'),
    ('D03', 'Marketing', 'Tokyo'),
    ('D04', 'HR', 'Nagoya'),
    ('D05', 'Finance', 'Tokyo');

INSERT INTO employees (name, dept_code, salary, hire_date)
SELECT
    'Employee_' || i,
    'D0' || (1 + (i % 5)),
    300000 + (random() * 500000)::int,
    '2010-01-01'::date + (random() * 5000)::int
FROM generate_series(1, 100000) AS s(i);

-- 統計情報の更新（オプティマイザが正確な判断をするために必要）
ANALYZE employees;
ANALYZE departments;
```

同じ結果を返す3つのクエリを比較する。

```sql
-- クエリA: JOINで書く
EXPLAIN ANALYZE
SELECT e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_code = d.dept_code
WHERE d.location = 'Tokyo';

-- クエリB: サブクエリで書く
EXPLAIN ANALYZE
SELECT e.name,
       (SELECT d.dept_name FROM departments d WHERE d.dept_code = e.dept_code)
FROM employees e
WHERE e.dept_code IN (SELECT dept_code FROM departments WHERE location = 'Tokyo');

-- クエリC: EXISTS で書く
EXPLAIN ANALYZE
SELECT e.name,
       (SELECT d.dept_name FROM departments d WHERE d.dept_code = e.dept_code)
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM departments d
    WHERE d.dept_code = e.dept_code AND d.location = 'Tokyo'
);
```

3つのクエリは同じ結果を返す。だがオプティマイザの実行計画は異なる可能性がある。`EXPLAIN ANALYZE`の出力を比較し、オプティマイザがどの順序でテーブルにアクセスし、どの結合方式（Nested Loop / Hash Join / Merge Join）を選んだかを観察する。

ここで注目すべきは、SQL文には「Hash Joinを使え」「Nested Loopを使え」とは一切書いていないことだ。プログラマは「何がほしいか」を宣言しただけで、「どう取るか」はオプティマイザが判断した。これがSQLの宣言的性質だ。

### 演習2: インデックスでオプティマイザの判断が変わる

```sql
-- インデックスなしでの実行計画
EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 700000;

-- インデックスを追加
CREATE INDEX idx_employees_salary ON employees(salary);
ANALYZE employees;

-- インデックスありでの実行計画
EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 700000;

-- 比較: salary > 200000 の場合（大多数の行が該当）
EXPLAIN ANALYZE
SELECT * FROM employees WHERE salary > 200000;
```

`salary > 700000`（該当行が少ない）ではインデックスが使われるが、`salary > 200000`（大多数の行が該当）ではフルテーブルスキャンが選ばれる可能性がある。これはオプティマイザが「インデックスを使うより、テーブル全体を読んだ方が速い」と判断したからだ。SQLの宣言的性質によって、この判断は自動的に行われる。

### 演習3: NULLの三値論理を体験する

```sql
-- NULLを含むテスト用データ
CREATE TABLE test_null (
    id SERIAL PRIMARY KEY,
    value INTEGER
);

INSERT INTO test_null (value) VALUES (10), (20), (NULL), (30), (NULL);

-- NULLとの比較がUNKNOWNを返す挙動
SELECT id, value, (value = NULL) AS eq_null FROM test_null;
-- → eq_null はすべてNULL（UNKNOWN）

-- WHERE句でのNULLの扱い
SELECT * FROM test_null WHERE value = NULL;     -- 0行
SELECT * FROM test_null WHERE value <> NULL;    -- 0行
SELECT * FROM test_null WHERE value IS NULL;    -- 2行
SELECT * FROM test_null WHERE value IS NOT NULL;-- 3行

-- NOT IN にNULLが含まれる場合の罠
SELECT * FROM test_null
WHERE value NOT IN (10, 20, NULL);
-- → 0行！（value=30 も返らない）
-- 理由: 30 <> NULL → UNKNOWN, NOT UNKNOWN → UNKNOWN
--        WHERE句はUNKNOWNの行を除外する

SELECT * FROM test_null
WHERE value NOT IN (10, 20);
-- → value=30 の1行が返る（NULLがなければ期待通り動く）
```

`NOT IN`にNULLが含まれると結果が空になる。これはSQLで最も頻繁に遭遇するバグの一つだ。三値論理を理解していなければ、この挙動はまったく意味不明に見える。

### 演習4: ウィンドウ関数——SQLの表現力の進化

```sql
-- ウィンドウ関数で部署ごとの給与ランキングと統計を一度に計算
SELECT
    name,
    dept_code,
    salary,
    RANK() OVER (PARTITION BY dept_code ORDER BY salary DESC) AS salary_rank,
    AVG(salary) OVER (PARTITION BY dept_code) AS dept_avg_salary,
    salary - AVG(salary) OVER (PARTITION BY dept_code) AS diff_from_avg
FROM employees
WHERE dept_code IN ('D01', 'D02')
ORDER BY dept_code, salary DESC
LIMIT 20;
```

この1つのSQL文で、「各部署内での給与ランキング」「部署平均給与」「平均との差」を同時に計算している。手続き型言語で同じことを実現するには、データの取得、グループ化、ソート、ランク付け、平均計算、差分計算を個別にコーディングしなければならない。SQLは「何がほしいか」を宣言するだけで、データベースがすべてを処理する。

ウィンドウ関数はSQL:2003で標準化された機能だ。1974年のSEQUELにはなかった。だがその設計思想——宣言的に「何がほしいか」を記述し、「どう計算するか」はデータベースに委ねる——は、50年前のChamberlinとBoyceの設計と一貫している。

### 後片付け

```sql
DROP TABLE IF EXISTS test_null;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
```

---

## 8. なぜSQLは50年経っても「データベースの言語」であり続けるのか

第5回を振り返ろう。

**SQLの始まりはSQUAREの挫折だった。** ChamberlinとBoyceが最初に設計したリレーショナル言語SQUAREは、数学的に正確だが上付き・下付き文字の表記が実用の壁となった。この教訓が、英語風のキーワードで構成されたSEQUELを生んだ。1974年のACM SIGFIDETワークショップで発表されたSEQUEL論文は、束縛変数や量化子を使わずに一階述語論理と同等の表現力を実現した。

**SEQUELの核心は宣言的設計にある。** 「何がほしいか」を宣言し、「どう取得するか」はデータベースエンジンに委ねる。この分離はCoddのデータ独立性の直接的な言語的実現であり、Patricia Selingerのコストベースクエリオプティマイザ（1979年）によって実用化された。

**SQLの勝因は技術的優位性ではなく、商用化と標準化だ。** 技術的にはQUELの方が洗練されていたとする評価もある。だがSQLはOracle V2（1979年）、IBM SQL/DS（1981年）、DB2（1983年）として商用化が先行し、1986年のANSI標準化で決定的な地位を確立した。

**SQLの設計にはトレードオフがある。** NULLの三値論理はリレーショナルモデルの純粋さからの逸脱であり、50年経った今も議論が続いている。重複行の扱い（集合とマルチセットの違い）は理論と実用の妥協だ。だがこれらのトレードオフは、SQLを実用的な言語として機能させるための代償であり、50年の生存を支えた適応でもある。

**SQLは進化し続けている。** SQL-86の素朴な言語は、SQL:2023では9,000ページを超える国際標準に成長した。ウィンドウ関数、CTE、JSON操作、そして最新のプロパティグラフクエリ。新しい要求に応じて機能は拡張されるが、その根底にある設計思想——宣言的に問い合わせる——は50年間変わっていない。

冒頭の問いに戻ろう。「なぜSQLは50年経ってもデータベースの言語であり続けるのか」——答えは、SQLが「特定の技術」ではなく「問い合わせの言葉」だからだ。

データの保管場所は変わった。ローカルのディスクからクラウドへ、単一サーバから分散クラスタへ。データの形態も変わった。行と列の表から、JSON、グラフ、ベクトルへ。だが「データに問いを投げる」という行為そのものは変わらない。「何がほしいか」を宣言し、「どう取るか」を機械に任せるというSQLの設計原則は、50年間のあらゆる技術変化に耐えるだけの普遍性を持っていた。

あなたが今日書く`SELECT`文。それは1974年にChamberlinとBoyceがAnn Arborのワークショップで発表した、あの249ページ目の論文から始まっている。そしてBoyceがその発明を見届けることなく27歳で逝ったことを、私たちは覚えておくべきだ。

次回は、リレーショナルデータベースの実装の歴史を辿る。Coddの論文とSQLという言語が揃った後、それを商用製品として実現したのは誰だったのか。1979年のOracle V2から、MySQL、PostgreSQLに至る「商用とOSSの系譜」を読み解く。

---

### 参考文献

- Donald D. Chamberlin, Raymond F. Boyce, "SEQUEL: A Structured English Query Language", _Proceedings of the 1974 ACM SIGFIDET Workshop on Data Description, Access and Control_, 1974, pp.249-264. <https://dl.acm.org/doi/10.1145/800296.811515>
- Donald D. Chamberlin, "50 Years of Queries", _Communications of the ACM_, Vol.67, No.8, August 2024. <https://cacm.acm.org/research/50-years-of-queries/>
- R.F. Boyce, D.D. Chamberlin, W.F. King III, M.M. Hammer, "Specifying Queries as Relational Expressions: The SQUARE Data Sublanguage", _Communications of the ACM_, Vol.18, No.11, November 1975, pp.621-628. <https://dl.acm.org/doi/10.1145/361219.361221>
- Donald D. Chamberlin et al., "SEQUEL 2: A Unified Approach to Data Definition, Manipulation, and Control", _IBM Journal of Research and Development_, Vol.20, No.6, 1976.
- Donald D. Chamberlin, "A History and Evaluation of System R", _Communications of the ACM_, 1981. <https://people.eecs.berkeley.edu/~brewer/cs262/SystemR.pdf>
- P. Griffiths Selinger, M.M. Astrahan, D.D. Chamberlin, R.A. Lorie, T.G. Price, "Access Path Selection in a Relational Database Management System", _Proceedings of ACM SIGMOD_, 1979, pp.23-34.
- IBM History, "The relational database". <https://www.ibm.com/history/relational-database>
- IBM History, "Patricia Selinger". <https://www.ibm.com/history/patricia-selinger>
- Wikipedia, "SQL". <https://en.wikipedia.org/wiki/SQL>
- Wikipedia, "Raymond F. Boyce". <https://en.wikipedia.org/wiki/Raymond_F._Boyce>
- Wikipedia, "Donald D. Chamberlin". <https://en.wikipedia.org/wiki/Donald_D._Chamberlin>
- Wikipedia, "QUEL query languages". <https://en.wikipedia.org/wiki/QUEL_query_languages>
- Wikipedia, "Null (SQL)". <https://en.wikipedia.org/wiki/Null_(SQL)>
- Wikipedia, "ISO/IEC 9075" (SQL:2023). <https://en.wikipedia.org/wiki/ISO/IEC_9075>
- LearnSQL.com, "The History of SQL Standards". <https://learnsql.com/blog/history-of-sql-standards/>
- The Register, "Codd almighty! Has it been 50 years of SQL already?", May 2024. <https://www.theregister.com/2024/05/31/fifty_years_of_sql/>
- Holistics Blog, "A Short Story About SQL's Biggest Rival". <https://www.holistics.io/blog/quel-vs-sql/>

---

**次回予告：** 第6回「Oracle, DB2, PostgreSQL——商用とOSSの系譜」では、リレーショナルモデルとSQLという武器を手に、データベース市場がどのような競争の中で形作られたかを辿る。1979年のOracle V2、1983年のDB2、そして1996年のPostgreSQLに至る商用とOSSの系譜を読み解く。
