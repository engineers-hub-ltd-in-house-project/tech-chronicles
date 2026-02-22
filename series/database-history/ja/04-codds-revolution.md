# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第4回：Coddの革命——リレーショナルモデルの誕生

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Edgar F. Coddの人物像——数学者がデータベースの世界を変えるまでの道程
- 1970年の論文「A Relational Model of Data for Large Shared Data Banks」の核心的主張
- リレーショナルモデルの三つの柱——データの論理的独立性、関係代数、正規化理論
- IBMの内部抵抗——IMSチームとの対立とCoddの孤独な戦い
- 関係代数の基本操作をSQLで再現し、正規化の各段階で更新異常が消える過程を体験する方法

---

## 1. 正規化を「暗記」していた自分

2004年頃のことだ。私はPHPとMySQLで中規模のWebシステムを開発していた。

当時の私にとって、正規化とは「ルール」だった。第一正規形——繰り返しグループを排除する。第二正規形——部分関数従属を排除する。第三正規形——推移的関数従属を排除する。データベースの教科書に書いてある手順を丸暗記し、テーブル設計のたびに機械的に適用する。なぜそうするのかは深く考えなかった。「そういうルールだから」で十分だと思っていた。

転機が訪れたのは、あるプロジェクトで設計レビューを受けたときだ。レビュアーは私よりも20年近くキャリアが長いベテランで、私のER図をしばらく眺めた後、こう言った。

「この設計は正規化されている。だが、なぜ正規化するのか説明できるか」

私は「データの冗長性を排除して、更新異常を防ぐためです」と答えた。教科書の模範解答だ。

「では、更新異常とは何だ。具体的に、この設計で正規化しなかったらどう壊れるか言えるか」

私は言葉に詰まった。抽象的には理解していたつもりだが、具体的にどう壊れるかを自分の言葉で説明できなかった。

「Coddの原論文を読め」と、そのベテランは言った。

それから数週間、私はEdgar F. Coddが1970年にCommunications of the ACMに発表した"A Relational Model of Data for Large Shared Data Banks"を読んだ。正確には、読もうとして挫折し、解説記事を読み、もう一度原論文に戻るという往復を何度か繰り返した。数学的な記法に慣れるまで時間がかかった。

だが、論文の主張を理解したとき、正規化が「ルール」ではなく「論理的帰結」であることが初めて腑に落ちた。

Coddが解決しようとした問題は、前回（第3回）で見た階層型モデルとネットワーク型モデルの限界そのものだった。データの物理構造にプログラムが縛られている。アクセスパスが固定されている。データベースの構造を変更すれば、すべてのプログラムを修正しなければならない。この「縛り」からの解放——データの論理的独立性——こそが、Coddの論文の核心だった。

正規化は、その独立性を保証するための数学的手段だったのだ。

あなたは、正規化を「ルール」として暗記していないだろうか。もしそうなら、今回の記事が、その「ルール」を「理解」に変えるきっかけになれば幸いだ。

---

## 2. 一人の数学者——Edgar F. Coddという人物

### オックスフォードからIBMへ

Edgar Frank Codd——通称"Ted"Codd——は1923年、イングランド南部ドーセット州ポートランド島のフォーチュンズウェルで生まれた。父は皮革製造業者、母は学校教師。オックスフォード大学に全額奨学金で入学し、数学と化学を学んだ。第二次世界大戦中はイギリス空軍（RAF）のパイロットとして従軍している。

1948年、Coddはニューヨークに渡り、数学者を募集していたIBMに入社した。だが1953年、冷戦下のマッカーシズム（赤狩り）に嫌気がさし、カナダのオタワに移住する。IBMを辞めたわけではなかったが、アメリカの政治的空気に耐えられなかったのだ。1957年、偶然元上司と再会したことをきっかけにアメリカに戻り、1961年にはIBM奨学金でミシガン大学に入学。計算機科学の修士号、続いて博士号を取得した。

1960年代後半、博士号を得たCoddはIBMのSan Jose Research Laboratory（カリフォルニア州サンノゼ）に着任する。当時このラボはディスクストレージの研究が主な業務であり、ソフトウェアの革新的研究が生まれる場とは誰も思っていなかった。

だがCoddは、そこでデータベースの世界を根底から変える論文を書くことになる。

### 1969年のIBM内部レポート

Coddがリレーショナルモデルの着想を最初に文書化したのは、1969年8月19日付のIBM Research Report RJ599、"Derivability, Redundancy, and Consistency of Relations Stored in Large Data Banks"（大規模共有データバンクに格納されたリレーションの導出可能性、冗長性、および一貫性）だ。

このレポートはIBMの社内文書であり、外部には公開されなかった。だがこの中で、Coddはすでにリレーショナルモデルの骨格を描いている。データを数学的な「リレーション」として定義し、データの物理的格納方法からアプリケーションを独立させるという根本的な構想が、ここに記されていた。

翌1970年6月、Coddはこの内部レポートを改訂し、"A Relational Model of Data for Large Shared Data Banks"としてCommunications of the ACM, Vol.13, No.6に発表した。わずか11ページの論文だ。だがこの11ページが、データベースの歴史を二つに分けることになる——「Codd以前」と「Codd以後」に。

---

## 3. 論文の核心——データの物理構造からの解放

### Coddが見た問題

Coddの論文が解決しようとした問題を理解するには、当時の状況を思い出す必要がある。

前回見たように、1960年代のデータベースは階層型（IBM IMS）とネットワーク型（CODASYL系）が主流だった。どちらのモデルも、プログラムはデータベースの物理構造——セグメントの階層、ポインタチェインの接続関係——を知っていなければデータにアクセスできない。

Coddは論文の冒頭で、この状況を明確に問題として提示している。

> Future users of large data banks must be protected from having to know how the data is organized in the machine (the internal representation).
>
> （大規模データバンクの将来のユーザーは、データが機械内部でどのように組織化されているか（内部表現）を知ることから保護されなければならない。）

さらにCoddは、プログラムとデータの関係について、より具体的な懸念を述べている。

> Activities of users at terminals and most application programs should remain unaffected when the internal representation of data is changed and even when some aspects of the external representation are changed.
>
> （端末のユーザーの活動やほとんどのアプリケーションプログラムは、データの内部表現が変更されたとき、さらには外部表現の一部が変更されたときでさえ、影響を受けないままであるべきだ。）

これがCoddの言う「データ独立性（data independence）」だ。データの物理的な格納方法が変わっても、データの論理的な構造（テーブルの追加やカラムの追加）が変わっても、既存のプログラムは修正なしに動き続けるべきだという主張である。

第3回で見たIMSのDL/Iコードを思い出してほしい。口座のセグメント階層にアクセスするために、プログラマは`GU`でルートを検索し、`GNP`で子を辿り、物理的なセグメント構造を正確に把握している必要があった。もしセグメント階層が変更されれば——たとえば「取引履歴」の下に新しい「付帯情報」セグメントが追加されれば——既存のすべてのプログラムを修正し、再テストしなければならない。

Coddは、この「縛り」を数学で断ち切ろうとした。

### リレーション——数学的な抽象

Coddの解決策の核心は、データをn項関係（n-ary relation）——すなわち「リレーション」——として定義することにある。

リレーションとは、数学的には定義域（ドメイン）の直積の部分集合だ。平たく言えば、テーブルのことだ。だが、Coddが定義した「リレーション」と、私たちが日常的に使う「テーブル」には決定的な違いがある。

リレーションは純粋に論理的な構造であり、物理的な格納方法を一切指定しない。

ディスク上にどう並べるか、インデックスをどう構築するか、データへのアクセスパスをどう設定するか——リレーションの定義にはこれらの情報が一切含まれない。リレーションが定義するのは、データの「意味」だけだ。

```
リレーショナルモデルの基本概念

リレーション（Relation）= テーブル
  ┌─────────────────────────────────────────────┐
  │ 社員番号 │  氏名      │ 部署コード │ 給与    │  ← 属性（Attribute）= 列
  ├─────────────────────────────────────────────┤
  │ E001     │ 田中太郎   │ D01        │ 500000  │  ← タプル（Tuple）= 行
  │ E002     │ 鈴木花子   │ D02        │ 600000  │
  │ E003     │ 佐藤一郎   │ D01        │ 450000  │
  └─────────────────────────────────────────────┘

  ドメイン（Domain）: 各属性がとりうる値の集合
    - 社員番号: 英字1文字 + 数字3桁の文字列
    - 氏名: 任意の文字列
    - 部署コード: 英字1文字 + 数字2桁の文字列
    - 給与: 0以上の整数
```

Coddの用語では、テーブルが「リレーション」、行が「タプル」、列が「属性」、列の取りうる値の集合が「ドメイン」に対応する。これらはすべて数学的に定義された概念であり、物理的な実装とは無関係だ。

この抽象化がもたらした革命的な変化を理解するために、階層型モデルとの違いを改めて考えよう。

階層型モデル（IMS）では、データの「構造」と「アクセス方法」が一体化している。セグメントの親子関係は、そのままデータへの物理的なアクセスパスを規定する。口座→取引履歴→明細というセグメント階層は、同時に「口座から辿って取引履歴を取得し、さらに明細を辿る」というアクセスパスでもある。

リレーショナルモデルでは、データの「構造」と「アクセス方法」が完全に分離されている。テーブル（リレーション）はデータの論理的な構造だけを定義し、そのデータにどうアクセスするか（インデックスを使うか、フルスキャンするか）はデータベースエンジンが判断する。プログラマは「何がほしいか」を宣言すればよい。「どう取得するか」は機械に任せる。

### 関係代数——データ操作の数学的基盤

Coddはリレーションを定義しただけではない。リレーションに対する操作を、数学的に厳密に定義した。それが関係代数（relational algebra）だ。

1970年の原論文では関係代数の基本的な概念が導入され、1972年の論文"Relational Completeness of Data Base Sublanguages"（IBM Research Report RJ987）において形式的な定義と証明が行われた。

関係代数の基本操作は、大きく二つのグループに分けられる。

**集合論に基づく操作：**

- **和（Union）**: 二つのリレーションの和集合を返す
- **差（Difference）**: 一方のリレーションにあって他方にないタプルを返す
- **直積（Cartesian Product）**: 二つのリレーションのすべての組み合わせを返す

**リレーショナルモデル固有の操作：**

- **選択（Selection）**: 条件に合致するタプルを抽出する（SQLの`WHERE`に相当）
- **射影（Projection）**: 特定の属性だけを取り出す（SQLの`SELECT 列名`に相当）
- **結合（Join）**: 共通の属性値を持つタプルを結びつける（SQLの`JOIN`に相当）

```
関係代数の基本操作（SQLとの対応）

【選択 (Selection)】σ
  σ(部署コード='D01')(社員) → WHERE 部署コード = 'D01'

  社員                           結果
  ┌──────┬────────┬──────┐      ┌──────┬────────┬──────┐
  │E001  │田中太郎│ D01  │ ──→ │E001  │田中太郎│ D01  │
  │E002  │鈴木花子│ D02  │      │E003  │佐藤一郎│ D01  │
  │E003  │佐藤一郎│ D01  │      └──────┴────────┴──────┘
  └──────┴────────┴──────┘

【射影 (Projection)】π
  π(氏名)(社員) → SELECT 氏名 FROM 社員

  社員                           結果
  ┌──────┬────────┬──────┐      ┌────────┐
  │E001  │田中太郎│ D01  │ ──→ │田中太郎│
  │E002  │鈴木花子│ D02  │      │鈴木花子│
  │E003  │佐藤一郎│ D01  │      │佐藤一郎│
  └──────┴────────┴──────┘      └────────┘

【結合 (Join)】⋈
  社員 ⋈ 部署 → SELECT * FROM 社員 JOIN 部署 ON ...

  社員                     部署
  ┌──────┬──────┐          ┌──────┬──────────┐
  │E001  │ D01  │          │ D01  │営業部    │
  │E002  │ D02  │          │ D02  │開発部    │
  └──────┴──────┘          └──────┴──────────┘

  結果
  ┌──────┬──────┬──────────┐
  │E001  │ D01  │営業部    │
  │E002  │ D02  │開発部    │
  └──────┴──────┴──────────┘
```

ここで重要なのは、これらの操作がすべて「リレーションを入力として受け取り、リレーションを出力として返す」という性質を持つことだ。数学の用語で言えば、関係代数は「閉じている」。この閉包性によって、操作を自由に組み合わせられる。選択の結果に射影を適用し、その結果を別のリレーションと結合する——このような操作の連鎖が可能だ。

1972年の論文で、Coddはさらに踏み込んだ。関係代数とは別に「関係論理（relational calculus）」を定義し、両者が同等の表現力を持つことを証明したのだ。この証明は、Coddの削減アルゴリズム（reduction algorithm）によって行われた。関係論理で表現できるすべての問い合わせは、関係代数でも表現できる。この等価性の証明により、「関係的完全性（relational completeness）」という概念が確立された。

関係的完全性は、データベース問い合わせ言語の表現力を測る基準となった。ある問い合わせ言語が「関係的に完全」であるとは、関係代数で表現できるすべての操作をその言語でも表現できることを意味する。後にSQLがこの基準に照らして評価されることになる。

---

## 4. 正規化理論——「なぜそうするのか」の数学

### 更新異常という問題

正規化理論は、Coddのリレーショナルモデルの中でも最も実務に直結する部分だ。だが、その本質は多くの教科書で見落とされている。

正規化の目的は、Codd自身の言葉を借りれば、「挿入、更新、削除における望ましくない依存関係からリレーションの集合を解放すること」だ。

抽象的に聞こえるかもしれないが、具体例を見ればすぐにわかる。

次のテーブルを考えよう。

```
非正規化された「受注」テーブル

┌────────┬────────┬──────────┬────────┬──────────┬──────┐
│受注番号│顧客名  │顧客住所  │商品名  │商品単価  │数量  │
├────────┼────────┼──────────┼────────┼──────────┼──────┤
│ 001    │山田商事│東京都港区│ボルトA │ 100      │ 50   │
│ 001    │山田商事│東京都港区│ナットB │ 50       │ 100  │
│ 002    │鈴木工業│大阪市北区│ボルトA │ 100      │ 200  │
│ 003    │山田商事│東京都港区│ワッシャC│ 30       │ 500  │
└────────┴────────┴──────────┴────────┴──────────┴──────┘
```

このテーブルには三つの異常が潜んでいる。

**更新異常（Update Anomaly）**: 山田商事の住所が「東京都港区」から「東京都千代田区」に変わったとする。このテーブルでは、山田商事の情報が3行に重複しているため、3箇所すべてを更新しなければならない。1箇所でも更新を漏らせば、同じ顧客の住所が行によって異なるという不整合が生じる。

**挿入異常（Insertion Anomaly）**: 新しい商品「ピンD」を登録したい。だがこのテーブルでは、受注と無関係に商品だけを登録する方法がない。受注番号も顧客名も存在しない商品は、行として挿入できないのだ。

**削除異常（Deletion Anomaly）**: 受注番号002を削除すると、鈴木工業の顧客情報も同時に消える。鈴木工業の他の受注がなければ、この顧客が存在したという事実ごと失われる。

これらの異常は、テーブルの設計が「データの依存関係」を正しく反映していないことに起因する。顧客の住所は顧客名に依存する情報であって、受注番号には依存しない。商品の単価は商品名に依存する情報であって、受注番号には依存しない。にもかかわらず、これらの情報がすべて一つのテーブルに押し込められているから、異常が生じるのだ。

### 正規化の段階

Coddは1970年の原論文で第一正規形（1NF）を定義し、翌1971年の論文"Further Normalization of the Data Base Relational Model"（IBM Research Report RJ909）で第二正規形（2NF）と第三正規形（3NF）を定義した。さらに1974年には、Raymond F. Boyceとともにボイス-コッド正規形（BCNF）を定義している。

各正規形は、前の正規形の制約をすべて満たした上で、さらに厳しい制約を追加するものだ。

**第一正規形（1NF）**: リレーションのすべての属性がスカラ値（原子的な値）であること。繰り返しグループや配列を許容しない。これはリレーショナルモデルの最も基本的な前提であり、1970年の原論文で定義された。

**第二正規形（2NF）**: 1NFを満たし、かつ、すべての非キー属性がキー全体に完全関数従属していること。部分関数従属——キーの一部だけに依存する属性——が存在しない。

先ほどの受注テーブルで言えば、「顧客名」と「顧客住所」は受注番号だけで決まるので、キーの一部（受注番号）への部分関数従属がある。これを分離することで2NFが達成される。

**第三正規形（3NF）**: 2NFを満たし、かつ、すべての非キー属性がキーに対して推移的に依存しない。ある非キー属性が、別の非キー属性を介してキーに間接的に依存する関係を排除する。

たとえば「部署コード→部署名→部署所在地」という依存がある場合、「部署所在地」はキーから「部署名」を介して推移的に依存している。3NFでは、この推移的依存を分離する。

**ボイス-コッド正規形（BCNF）**: 3NFをさらに強化したもので、すべての関数従属において決定子がスーパーキーであることを要求する。3NFの特殊なケースで問題となりうる状況を解消する。

```
正規化の段階と解消される異常

                            解消される問題
  1NF  ─── 繰り返しグループ ──→ データの原子性の保証
   │
  2NF  ─── 部分関数従属 ──────→ キーの一部への依存を排除
   │
  3NF  ─── 推移的関数従属 ────→ 非キー間の依存を排除
   │
  BCNF ─── 非キー→キーの依存 ─→ すべての決定子がスーパーキー
   │
  4NF  ─── 多値従属性 ────────→ 独立した多値属性を分離
   │
  5NF  ─── 結合従属性 ────────→ 分解しても情報が失われない
```

正規化の各段階は、「なぜそうするのか」が数学的に定義されている。第一正規形は「リレーションの定義を満たすため」、第二正規形以降は「更新異常を段階的に排除するため」だ。ルールの丸暗記ではなく、各段階が「何の異常を解消するか」を理解すれば、正規化は論理的必然として腑に落ちる。

後年の1977年にRonald Faginが第四正規形（4NF）を、1979年に第五正規形（5NF）を導入した。だがCoddが確立した1NF〜3NFの枠組みが正規化理論の根幹であり、実務上はBCNFまでの理解が大半の設計場面で十分だ。

---

## 5. IBMの内部抵抗——革命は内側から阻まれる

### IMSという既得権益

Coddの論文は、学術界では高い評価を受けた。だがCoddの雇用主であるIBM自身が、リレーショナルモデルの商用化に最も強く抵抗した。

理由は単純だ。IBMにはIMS（Information Management System）という階層型データベースの主力製品があった。第3回で見たように、IMSはアポロ計画の遺産であり、Fortune 1000企業の大多数が利用する巨大な収益源だった。IBMはIMSを「唯一の戦略的データベース製品」と位置づけており、これと競合する可能性のある技術の推進は、社内で強い逆風を受けた。

さらに組織的な問題もあった。Coddが所属するSan Jose Research Laboratoryは、それまで主にディスクストレージの研究を行っていた拠点であり、ソフトウェアの重要なイノベーションが生まれる場所とは見なされていなかった。ニューヨークの本社やメインフレーム部門から見れば、サンノゼの研究者が提唱する理論的なデータベースモデルは、既存のビジネスを脅かす「余計なもの」だったのだ。

Coddの研究は「会社の方針に反する」として批判され、リソースの割り当ても限定的だった。IMSの事業部門は、リレーショナルデータベースがIMSの市場を侵食することを警戒し、積極的に妨害したという報告もある。

### Coddの反撃

だがCoddは、学術的な正しさだけに頼らなかった。戦略的に動いた。

Coddは、IBMの顧客企業に直接リレーショナルモデルの可能性を見せた。顧客がその将来性を理解し、IBMに対してリレーショナルデータベース製品の開発を要求する——この外圧こそが、IBMの内部抵抗を突破する力となった。

1973年、IBMのSan Jose Research Laboratoryで、リレーショナルモデルの実装可能性を実証するプロジェクトが発足した。System Rだ。チームにはDonald ChamberlinとRaymond Boyceが参加し、後にSQLの原型となるSEQUEL（Structured English Query Language）を開発する。Patricia Selinger はコストベースのクエリオプティマイザを設計した。

重要な事実がある。Codd自身は、System Rプロジェクトのチームメンバーではなかった。リレーショナルモデルの提唱者でありながら、その実装プロジェクトから排除されていた。IBM内部の政治的力学がどれほど複雑だったかを物語るエピソードだ。

### 学術界からの援軍——Ingresプロジェクト

IBMが内部で葛藤している間に、学術界は動いていた。

1974年、カリフォルニア大学バークレー校のMichael StonebrakerとEugene Wongは、INGRES（Interactive Graphics and Retrieval System）プロジェクトを立ち上げた。System Rとほぼ同時期に、リレーショナルモデルが実用的なデータベースシステムとして実装可能であることを独立に実証したのだ。

INGRESからは多くの技術的成果が生まれた。B-Treeインデックスの活用、ビューの問い合わせ書き換え、整合性制約のためのルール/トリガーの概念——これらは後のリレーショナルデータベースに広く採用された。Stonebraker自身は後にPostgresプロジェクト（1986年〜）を率い、これが現在のPostgreSQLの源流となる。Stonebrakerは2014年にチューリング賞を受賞した。

System Rの商用化はさらに時間を要した。IBMがリレーショナルデータベースの最初の商用製品SQL/DSを市場に投入したのは1981年、続いてDB2が1983年に登場する。Coddの論文から実に11年、13年の歳月だ。

だがその間に、IBM社外から先を越されることになる。1979年、Larry Ellison率いるRelational Software, Inc.（後のOracle Corporation）が、世界初の商用リレーショナルデータベースOracle V2をリリースした。Coddの論文とSystem Rの研究成果を読んだEllison が、IBMよりも先に商用化を果たしたのだ。この話は第6回で詳しく語る。

### 1981年——チューリング賞

1981年、Edgar F. CoddにACMチューリング賞が授与された。授賞式は1981年11月9日、ロサンゼルスで開催されたACM年次大会で行われた。ACM会長Peter Denningから賞が授与され、受賞理由は「データベース管理システムの理論と実践への基本的かつ継続的な貢献」だった。

チューリング賞は計算機科学における最高の栄誉とされる。Coddの受賞は、リレーショナルモデルが単なる理論的提案ではなく、計算機科学全体に影響を与えた根本的な貢献であることを、学術界が公式に認めたことを意味する。

1985年には、Computerworld誌に「あなたのDBMSは本当にリレーショナルか？」という2部構成の記事を発表し、「Coddの12の規則」（正確には0番から12番の13規則）を提示した。これはベンダーが非リレーショナルなシステムを「リレーショナル」と偽って販売するマーケティング手法への痛烈な批判であり、リレーショナルデータベースが満たすべき基準を厳密に定義したものだ。

2003年4月18日、Edgar F. Coddは79歳で逝去した。だが彼が1970年に発表した11ページの論文は、半世紀以上を経た現在もデータベースの世界を支配し続けている。

---

## 6. ハンズオン: 関係代数と正規化を体験する

今回のハンズオンでは、関係代数の基本操作をSQLで再現し、正規化の各段階を実際のテーブルで体験する。正規化によって更新異常が消える過程を、手を動かしながら確認しよう。

### 演習概要

1. 関係代数の基本操作（選択、射影、結合、和、差）をSQLで再現する
2. 正規化されていないテーブルで更新異常を発生させる
3. 正規化の各段階（1NF→2NF→3NF）でテーブルを分解し、異常が解消される過程を確認する

### 環境構築

Docker環境（`ubuntu:24.04`推奨）で実行する。

```bash
docker run -it --rm ubuntu:24.04 bash
apt-get update && apt-get install -y sqlite3
```

### 演習1: 関係代数の基本操作をSQLで再現する

```sql
-- relational_algebra.sql -- 関係代数の基本操作をSQLで体験する

-- テスト用テーブルの作成
CREATE TABLE employees (
    emp_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    dept_code TEXT NOT NULL,
    salary INTEGER NOT NULL
);

CREATE TABLE departments (
    dept_code TEXT PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT NOT NULL
);

INSERT INTO employees VALUES ('E001', 'Tanaka', 'D01', 500000);
INSERT INTO employees VALUES ('E002', 'Suzuki', 'D02', 600000);
INSERT INTO employees VALUES ('E003', 'Sato', 'D01', 450000);
INSERT INTO employees VALUES ('E004', 'Yamada', 'D03', 550000);

INSERT INTO departments VALUES ('D01', 'Sales', 'Tokyo');
INSERT INTO departments VALUES ('D02', 'Engineering', 'Osaka');
INSERT INTO departments VALUES ('D03', 'Marketing', 'Tokyo');

-- === 選択 (Selection): σ(dept_code='D01')(employees) ===
-- 条件に合致するタプル（行）を抽出する
.print '=== 選択 (Selection): dept_code = D01 ==='
SELECT * FROM employees WHERE dept_code = 'D01';

-- === 射影 (Projection): π(name, salary)(employees) ===
-- 特定の属性（列）だけを取り出す
.print ''
.print '=== 射影 (Projection): name, salary ==='
SELECT DISTINCT name, salary FROM employees;

-- === 結合 (Join): employees ⋈ departments ===
-- 共通の属性値でリレーションを結びつける
.print ''
.print '=== 結合 (Join): employees JOIN departments ==='
SELECT e.emp_id, e.name, d.dept_name, d.location
FROM employees e
JOIN departments d ON e.dept_code = d.dept_code;

-- === 選択 + 射影 + 結合の組み合わせ ===
-- 「東京にある部署の社員名と部署名」
-- 関係代数: π(name, dept_name)(σ(location='Tokyo')(employees ⋈ departments))
.print ''
.print '=== 組み合わせ: 東京の部署の社員名と部署名 ==='
SELECT e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_code = d.dept_code
WHERE d.location = 'Tokyo';

-- === 和 (Union) ===
-- 二つのリレーションの和集合
CREATE TABLE former_employees (
    emp_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    dept_code TEXT NOT NULL,
    salary INTEGER NOT NULL
);
INSERT INTO former_employees VALUES ('E005', 'Ito', 'D01', 480000);
INSERT INTO former_employees VALUES ('E006', 'Watanabe', 'D02', 520000);

.print ''
.print '=== 和 (Union): 現社員 ∪ 元社員 ==='
SELECT emp_id, name FROM employees
UNION
SELECT emp_id, name FROM former_employees;

-- === 差 (Difference) ===
-- 一方にあって他方にないタプル
-- 「全部署のうち、社員が所属していない部署」を求める
CREATE TABLE all_dept_codes AS SELECT dept_code FROM departments;
CREATE TABLE used_dept_codes AS SELECT DISTINCT dept_code FROM employees;

.print ''
.print '=== 差 (Difference): 社員が所属していない部署 ==='
SELECT dept_code FROM all_dept_codes
EXCEPT
SELECT dept_code FROM used_dept_codes;

.print ''
.print '注目: すべての操作が「何がほしいか」の宣言だけで完結している。'
.print '「どのインデックスを使うか」「どの順序で走査するか」は一切書いていない。'
.print 'これがCoddが実現した「データの論理的独立性」の恩恵だ。'
```

上記をファイルに保存して実行する。

```bash
cat > /tmp/relational_algebra.sql << 'EOF'
-- （上記のSQL文をここに貼り付ける）
EOF
sqlite3 :memory: < /tmp/relational_algebra.sql
```

### 演習2: 正規化されていないテーブルで更新異常を体験する

```sql
-- update_anomalies.sql -- 更新異常を実際に発生させる

CREATE TABLE orders_denormalized (
    order_id TEXT,
    customer_name TEXT,
    customer_address TEXT,
    product_name TEXT,
    unit_price INTEGER,
    quantity INTEGER
);

INSERT INTO orders_denormalized VALUES ('001', 'Yamada Corp', 'Tokyo Minato', 'Bolt-A', 100, 50);
INSERT INTO orders_denormalized VALUES ('001', 'Yamada Corp', 'Tokyo Minato', 'Nut-B', 50, 100);
INSERT INTO orders_denormalized VALUES ('002', 'Suzuki Inc', 'Osaka Kita', 'Bolt-A', 100, 200);
INSERT INTO orders_denormalized VALUES ('003', 'Yamada Corp', 'Tokyo Minato', 'Washer-C', 30, 500);

.print '=== 非正規化テーブルの初期状態 ==='
SELECT * FROM orders_denormalized;

-- 更新異常: Yamada Corpの住所を変更（1箇所だけ更新してしまう）
.print ''
.print '=== 更新異常: Yamada Corpの住所を1箇所だけ更新 ==='
UPDATE orders_denormalized
SET customer_address = 'Tokyo Chiyoda'
WHERE order_id = '001' AND product_name = 'Bolt-A';

SELECT order_id, customer_name, customer_address, product_name
FROM orders_denormalized
WHERE customer_name = 'Yamada Corp';

.print ''
.print '>>> 同じ顧客の住所が行によって異なる！これが更新異常だ。'

-- 挿入異常: 受注なしで新商品を登録しようとする
.print ''
.print '=== 挿入異常: 受注なしの新商品を登録できない ==='
.print '商品 Pin-D (単価 20) を登録したいが、'
.print 'order_id も customer_name も存在しない商品は挿入できない。'
.print 'INSERT INTO orders_denormalized VALUES (NULL, NULL, NULL, Pin-D, 20, NULL);'
.print '→ 受注と無関係に商品マスタを管理する手段がない。'

-- 削除異常: 受注002を削除するとSuzuki Incの情報が消える
.print ''
.print '=== 削除異常: 受注002を削除 ==='
DELETE FROM orders_denormalized WHERE order_id = '002';

.print 'Suzuki Incの情報を検索:'
SELECT * FROM orders_denormalized WHERE customer_name = 'Suzuki Inc';
.print '>>> Suzuki Incの顧客情報が完全に消失した。これが削除異常だ。'
```

### 演習3: 正規化による異常の解消

```sql
-- normalization.sql -- 正規化の各段階で異常を解消する

-- === 正規化されたテーブル設計（3NF） ===
CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    customer_name TEXT NOT NULL,
    customer_address TEXT NOT NULL
);

CREATE TABLE products (
    product_id TEXT PRIMARY KEY,
    product_name TEXT NOT NULL,
    unit_price INTEGER NOT NULL
);

CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES customers(customer_id),
    order_date TEXT NOT NULL
);

CREATE TABLE order_items (
    order_id TEXT REFERENCES orders(order_id),
    product_id TEXT REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

-- データ投入
INSERT INTO customers VALUES ('C001', 'Yamada Corp', 'Tokyo Minato');
INSERT INTO customers VALUES ('C002', 'Suzuki Inc', 'Osaka Kita');

INSERT INTO products VALUES ('P001', 'Bolt-A', 100);
INSERT INTO products VALUES ('P002', 'Nut-B', 50);
INSERT INTO products VALUES ('P003', 'Washer-C', 30);

INSERT INTO orders VALUES ('001', 'C001', '2024-01-15');
INSERT INTO orders VALUES ('002', 'C002', '2024-01-20');
INSERT INTO orders VALUES ('003', 'C001', '2024-01-25');

INSERT INTO order_items VALUES ('001', 'P001', 50);
INSERT INTO order_items VALUES ('001', 'P002', 100);
INSERT INTO order_items VALUES ('002', 'P001', 200);
INSERT INTO order_items VALUES ('003', 'P003', 500);

-- 更新異常の解消: 住所を1箇所更新するだけで全受注に反映
.print '=== 更新異常の解消: 顧客住所を1箇所だけ更新 ==='
UPDATE customers SET customer_address = 'Tokyo Chiyoda' WHERE customer_id = 'C001';

SELECT o.order_id, c.customer_name, c.customer_address
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_name = 'Yamada Corp';

.print ''
.print '>>> すべての受注で住所が一貫して更新された。データの重複がないからだ。'

-- 挿入異常の解消: 受注なしで商品を登録できる
.print ''
.print '=== 挿入異常の解消: 受注なしで新商品を登録 ==='
INSERT INTO products VALUES ('P004', 'Pin-D', 20);
SELECT * FROM products WHERE product_id = 'P004';
.print '>>> 受注と無関係に商品マスタを管理できる。'

-- 削除異常の解消: 受注を削除しても顧客情報は残る
.print ''
.print '=== 削除異常の解消: 受注002を削除 ==='
DELETE FROM order_items WHERE order_id = '002';
DELETE FROM orders WHERE order_id = '002';

.print 'Suzuki Incの情報を検索:'
SELECT * FROM customers WHERE customer_name = 'Suzuki Inc';
.print '>>> 受注を削除しても顧客情報は独立して保持される。'

-- 結合による元のビューの再構成
.print ''
.print '=== 正規化されたテーブルをJOINで結合（元の一覧を再現） ==='
SELECT o.order_id, c.customer_name, c.customer_address,
       p.product_name, p.unit_price, oi.quantity
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_id;

.print ''
.print '>>> 正規化によってテーブルは分割されたが、JOINによって'
.print '>>> いつでも元の一覧を再構成できる。これが関係代数の「閉包性」の恩恵だ。'
.print '>>> データの冗長性を排除しつつ、情報の欠落がない。'
.print '>>> Coddが実現しようとした世界は、まさにこれだ。'
```

---

## 7. 11ページが変えた50年

第4回を振り返ろう。

**Edgar F. Coddは、数学者としてデータベースの世界に革命を起こした。** 1923年にイングランドで生まれ、オックスフォード大学で数学を学び、第二次世界大戦ではRAFパイロットとして従軍した後、1948年にIBMに入社。マッカーシズムに反発してカナダに渡り、帰国後にミシガン大学で博士号を取得し、IBM San Jose Research Laboratoryに着任した。1969年の内部レポート、翌1970年のCommunications of the ACM論文——この11ページの論文が、データベースの歴史を「Codd以前」と「Codd以後」に分けた。

**Coddの論文の核心は「データの論理的独立性」だ。** データの物理的な格納方法からアプリケーションプログラムを解放する。階層型モデルやネットワーク型モデルでは、プログラムはデータベースの物理構造を知っていなければデータにアクセスできなかった。Coddは、データを数学的な「リレーション」として定義し、関係代数という操作体系を与えることで、「何がほしいか」を宣言するだけでデータを取得できる世界を構想した。

**正規化理論は「ルール」ではなく「論理的帰結」だ。** リレーションの中にデータの依存関係が正しく反映されていないとき、更新異常（更新・挿入・削除の異常）が発生する。正規化の各段階（1NF→2NF→3NF→BCNF）は、これらの異常を段階的に排除するための数学的手段である。

**IBMの内部抵抗は、革命の代償だった。** IMS事業の収益を守りたいIBMは、Coddのリレーショナルモデルの商用化に消極的だった。Codd自身がSystem Rプロジェクトから排除されるという皮肉もあった。だが顧客からの圧力と、UC BerkeleyのINGRESプロジェクトを含む学術界からの実装実証が、最終的にIBMを動かした。

冒頭の問いに戻ろう。「一本の論文が、なぜ50年以上にわたってデータベースの世界を支配し続けているのか」——答えは、Coddの論文が「特定の実装」ではなく「数学的な基盤」を提供したからだ。リレーショナルモデルは、特定のハードウェアや特定のソフトウェアに依存しない。数学的な定義に基づく抽象であるがゆえに、ハードウェアが進化し、ソフトウェアが世代交代を重ねても、モデル自体は有効であり続ける。

あなたが今書いている`CREATE TABLE`文。それはCoddが1970年に定義した「リレーション」を実体化する行為だ。`SELECT ... WHERE ... JOIN ...`と書くとき、あなたは関係代数の選択・射影・結合を、人間が読める言語で表現している。Coddの論文から半世紀以上が経ったが、私たちは今なおCoddが敷いた線路の上を走っている。

次回は、そのリレーショナルモデルに「言葉」を与えた発明を辿る。1974年、IBMのDonald ChamberlinとRaymond BoyceがSEQUEL——後のSQL——を生み出した。データベースに「何がほしいか」を宣言する言語が、どのような思考から設計され、なぜ50年経った今も生き残っているのかを読み解く。

---

### 参考文献

- Edgar F. Codd, "A Relational Model of Data for Large Shared Data Banks", _Communications of the ACM_, Vol.13, No.6, June 1970, pp.377-387. <https://dl.acm.org/doi/10.1145/362384.362685>
- Edgar F. Codd, "Derivability, Redundancy, and Consistency of Relations Stored in Large Data Banks", IBM Research Report RJ599, August 19, 1969. <https://sigmod.org/publications/dblp/db/labs/ibm/RJ599.html>
- Edgar F. Codd, "Relational Completeness of Data Base Sublanguages", IBM Research Report RJ987, 1972. <https://www.inf.unibz.it/~franconi/teaching/2006/kbdb/Codd72a.pdf>
- Edgar F. Codd, "Further Normalization of the Data Base Relational Model", IBM Research Report RJ909, 1971.
- ACM A.M. Turing Award, "Edgar F. Codd". <https://amturing.acm.org/award_winners/codd_1000892.cfm>
- IBM, "Edgar Codd". <https://www.ibm.com/history/edgar-codd>
- IBM, "The relational database". <https://www.ibm.com/history/relational-database>
- Britannica, "Edgar Frank Codd". <https://www.britannica.com/biography/Edgar-Frank-Codd>
- National Academies Press, "Funding a Revolution", Chapter 6: "The Rise of Relational Databases". <https://www.nationalacademies.org/read/6323/chapter/8>
- The Register, "Codd almighty! How IBM cracked System R", November 2013. <https://www.theregister.com/2013/11/20/ibm_system_r_making_relational_really_real/>
- Two-Bit History, "Important Papers: Codd and the Relational Model". <https://twobithistory.org/2017/12/29/codd-relational-model.html>
- CockroachDB Blog, "The Codd Father". <https://www.cockroachlabs.com/blog/codd-tribute/>
- Wikipedia, "Codd's 12 rules". <https://en.wikipedia.org/wiki/Codd%27s_12_rules>
- Wikipedia, "Relational algebra". <https://en.wikipedia.org/wiki/Relational_algebra>
- Wikipedia, "Database normalization". <https://en.wikipedia.org/wiki/Database_normalization>
- UC Berkeley EECS, "INGRES- A Relational Data Base System". <https://www2.eecs.berkeley.edu/Pubs/TechRpts/1974/28785.html>
- ACM A.M. Turing Award, "Michael Stonebraker". <https://amturing.acm.org/award_winners/stonebraker_1172121.cfm>

---

**次回予告：** 第5回「SQLの誕生——データベースに『言葉』が生まれた日」では、1974年にIBMのDonald ChamberlinとRaymond BoyceがSEQUELを設計した経緯、SEQUELからSQLへの改名、SQL標準化の50年史（SQL-86からSQL:2016まで）、そしてSQLの宣言的設計が50年の技術変化に耐えた理由を解き明かす。
