# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第3回：階層型とネットワーク型——リレーショナル以前の世界

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- NASAアポロ計画の部品管理から生まれたIBM IMS——階層型データベースの構造と設計思想
- CODASYLネットワーク型データベースの「セット」概念と、階層型モデルからの進化
- DL/Iの「ナビゲーション型」データアクセスとは何か——GU、GN、GNPコマンドの実態
- 階層型・ネットワーク型モデルの本質的限界——物理構造と論理構造の密結合
- JSON構造で階層型データモデルを模擬的に実装し、「ツリーを辿る」データアクセスの制約を体験する方法

---

## 1. 金融機関のレガシーシステムで見たもの

2008年のことだ。私は大手金融機関のシステム移行案件に参加していた。

当時の私は、PostgreSQLとMySQLの世界で十分に場数を踏んでいるつもりだった。リレーショナルデータベースの設計ならばER図を描き、正規化を施し、適切なインデックスを張る。それが「データベース設計」のすべてだと思っていた。

移行対象のシステムは、IBM IMS上に構築された勘定系の基幹システムだった。

最初にIMSのデータ構造の説明を受けたとき、私は正直に言って混乱した。「セグメント」「PCB」「DL/I」——聞いたこともない用語が並ぶ。だがそれ以上に衝撃だったのは、データの「構造」そのものだった。テーブルがない。行と列がない。代わりにあったのは、ツリーだ。

口座情報がルートセグメントとして存在し、その下に取引履歴セグメント、住所セグメント、連絡先セグメントが子としてぶら下がる。取引履歴の下にはさらに明細セグメントが連なる。データにアクセスするには、このツリーを上から辿っていく。ルートから子へ、子からさらにその子へ。SQLのSELECT文のように「条件に合致するものを持ってこい」と宣言するのではない。「まずこのルートを見つけ、次にこの子を辿り、さらにこの孫を辿れ」と、プログラマが一歩ずつ道順を指定する。

これが「ナビゲーション」だった。

私はそのとき初めて、自分が「当たり前」だと思っていたリレーショナルモデルが、実は特定の歴史的文脈の中から生まれた「発明」であることを実感した。テーブルに行を格納し、SQLで問い合わせる——それは自然界の法則ではない。先人たちが「ツリーを辿る」世界の限界に苦しみ、その解放を求めて生み出した革命の成果なのだ。

あなたが今、何気なくSQLを書いているその行為は、1970年代に始まった革命の恩恵の上にある。だが、革命が何を乗り越えたのかを知らなければ、その恩恵の意味も、限界も見えてこない。

今回は、リレーショナルモデル「以前」の世界を辿る。

---

## 2. アポロ計画が生んだ階層型データベース——IBM IMS

### 宇宙船の部品表という難題

1960年代のアメリカは、宇宙開発競争の渦中にあった。1961年にジョン・F・ケネディ大統領が「1960年代のうちに人間を月に送り、安全に帰還させる」と宣言し、NASAのアポロ計画が本格始動した。

アポロ宇宙船の製造を請け負ったのがNorth American Aviation（後のNorth American Rockwell）だ。宇宙船は数百万点にも及ぶ部品で構成されている。この膨大な部品表（Bill of Materials、BOM）を管理するシステムが必要だった。

1965年、North American AviationはIBMと提携し、部品管理のための自動化システムの開発に着手する。1966年、IBMから12名、North American Rockwellから10名、そしてCaterpillar Tractorから3名の合同チームが結成され、ICS/DL/I（Information Control System and Data Language/Interface）の設計・開発が始まった。

IBMチームは1967年にICSの最初のリリースを完成させ出荷した。1968年4月にシステムが設置され、同年8月14日、カリフォルニア州ダウニーのRockwell Space Divisionに設置されたIBM 2740端末に、最初の「READY」メッセージが表示された。翌1969年7月20日、アポロ11号は月面に着陸する。ICSが稼働を開始してから、わずか11ヶ月後の出来事だった。

1969年、IBMはICSをIMS/360（Information Management System/360）と改名し、商用製品として市場に投入した。アポロ計画のために生まれたデータベースが、企業の世界に降り立った瞬間だ。

### 階層型モデルの構造

IMSが採用した階層型データモデルは、その名のとおりツリー（木）構造でデータを表現する。

最も基本的な概念は「セグメント」だ。セグメントとは、関連するデータフィールドをまとめた単位であり、IMSにおけるI/O操作の最小単位でもある。現代のリレーショナルデータベースにおける「行」に相当すると考えてよいが、決定的に異なる点がある。セグメントは親子関係で結ばれ、ツリー構造を形成するのだ。

```
IMSの階層型データモデル（銀行口座の例）

                    口座 (ルートセグメント)
                   /        |         \
                  /         |          \
            取引履歴      住所情報     連絡先
            /    \
           /      \
       明細(1)   明細(2)

   ルートセグメント: 口座番号, 口座名義, 残高
     ├── 取引履歴セグメント: 取引日, 取引種別, 金額
     │     ├── 明細セグメント: 明細番号, 摘要
     │     └── 明細セグメント: 明細番号, 摘要
     ├── 住所情報セグメント: 郵便番号, 住所, 区分
     └── 連絡先セグメント: 電話番号, メール, 種別
```

1つのIMSデータベースには最大255種のセグメントタイプを定義でき、階層の深さは最大15レベルまで許容される。ルートセグメント——ツリーの頂点で、親を持たないセグメント——が1つだけ存在し、すべてのアクセスはこのルートを起点とする。

この構造は、アポロ宇宙船の部品表管理にとって自然な表現だった。宇宙船（ルート）の下にステージ（第一段、第二段、第三段）があり、各ステージの下にモジュールがあり、各モジュールの下に個別の部品がある。現実の物理的な「もの」の構成そのものが、すでに階層構造をなしている。

### DL/I——ナビゲーションの言語

IMSにおけるデータアクセスは、DL/I（Data Language/Interface）と呼ばれるインターフェースを通じて行われる。DL/Iの最も重要な特徴は、それが「ナビゲーション型」のアクセスであるということだ。

DL/Iの主要なコマンドを見てみよう。

**GU（Get Unique）**——指定した条件に合致するセグメントを、データベースの先頭から検索して1件取得する。常にデータベースの先頭から検索が始まる。

**GN（Get Next）**——現在の位置から、階層構造を上から下、左から右の順に次のセグメントを取得する。GUで位置を定めた後、GNを繰り返すことでデータを順次辿っていく。

**GNP（Get Next within Parent）**——現在の親セグメントの範囲内で、次の子セグメントを取得する。親を超えない。

COBOLプログラムからDL/Iを呼び出す場合、コードは次のような形をとる。

```cobol
* 口座番号 12345 の口座セグメントを取得
CALL 'CBLTDLI' USING GU-FUNC
                      ACCOUNT-PCB
                      ACCOUNT-SEGMENT
                      ACCOUNT-SSA.

* 取得した口座の下にある取引履歴セグメントを順次取得
PERFORM UNTIL STATUS-CODE NOT = SPACES
    CALL 'CBLTDLI' USING GNP-FUNC
                          ACCOUNT-PCB
                          TRANSACTION-SEGMENT
                          TRANSACTION-SSA
    IF STATUS-CODE = SPACES
        DISPLAY TRANSACTION-DATE TRANSACTION-AMOUNT
    END-IF
END-PERFORM.
```

ここで重要なのは、プログラマが「データのどこにいるか」を常に意識しなければならない点だ。GUでルートの位置を定め、GNPで子を辿り、さらに深い階層に降りる。これは、ファイルシステムでディレクトリツリーを`cd`コマンドで移動するのに似ている。自分がツリーのどこにいるかを見失えば、意図しないセグメントを取得してしまう。

SQLの`SELECT * FROM transactions WHERE account_id = 12345`とは根本的に異なる。SQLは「何がほしいか」を宣言する。DL/Iは「どう辿るか」を手続き的に記述する。この違いこそが、後にCoddが批判した「ナビゲーション」と「宣言」の対立の本質だ。

### 階層型モデルの限界

階層型モデルは、データが自然にツリー構造をなす場面——部品表、組織図、文書のカテゴリ——では見事に機能する。だが、現実の世界のデータは、必ずしもツリーに収まらない。

典型的な例が、多対多の関係だ。

ある大学のデータベースを考えよう。「学生」と「講義」の関係は多対多だ。一人の学生は複数の講義を履修し、一つの講義には複数の学生が参加する。

```
階層型モデルで多対多を表現しようとすると……

パターン1: 学生をルートにする
    学生A ── 講義X
           ── 講義Y
    学生B ── 講義X  ← 講義Xのデータが重複！
           ── 講義Z

パターン2: 講義をルートにする
    講義X ── 学生A
           ── 学生B
    講義Y ── 学生A  ← 学生Aのデータが重複！
    講義Z ── 学生B  ← 学生Bのデータが重複！
```

どちらのパターンを選んでも、データの重複が避けられない。講義Xの教室が変更になれば、パターン1では学生Aの下の講義Xと学生Bの下の講義Xの両方を更新しなければならない。更新漏れが発生すれば、同じ講義の教室情報が学生によって異なるという不整合が生じる。第2回で見たファイルベースのデータ管理と同じ問題——データの冗長性と不整合——が、階層型モデルの内部で再現されるのだ。

さらに深刻なのは、挿入と削除の異常だ。階層型モデルでは、子セグメントは親セグメントなしには存在できない。新しい講義を登録したいが、まだ履修する学生がいない場合、学生をルートとするモデルではその講義をどこにも格納できない。逆に、ある学生の最後の履修を削除すると、その学生自身の情報まで失われる可能性がある。

これらの問題はIMSの設計者たちも認識しており、「論理的子セグメント」や「仮想ペアレント」と呼ばれる仕組みで部分的な回避策を提供した。だが、それらは本質的な解決ではなく、データベース構造の複雑化とプログラムの肥大化を招いた。

---

## 3. CODASYLとネットワーク型データベース——多対多への挑戦

### Bachmanの問題意識

第2回で、Charles W. BachmanのIDS（Integrated Data Store）が世界初のDBMSの概念を生み出したことを見た。IDSは1963年にGeneral Electricでプロトタイプがテストされ、1964年にリリースされた。Bachmanが1973年のチューリング賞受賞講演「The Programmer as Navigator」で語ったのは、まさにこのIDSとその後継が拓いた「ナビゲーション」の世界だった。

Bachmanの講演は、コペルニクスの地動説への転換になぞらえて展開される。かつてのプログラマは、メモリを中心とした「天動説」的世界観の中にいた——データはプログラムの従属物であり、プログラムがデータの配置を決める。だがデータベースの登場により、世界は「地動説」へと転換する。データこそが中心であり、プログラムはデータの周りを航行する「ナビゲーター」だ。

この講演が描いた世界観は、CODASYLのネットワーク型データベースモデルに結実した。

### CODASYLの成立

CODASYL（Conference on Data Systems Languages）は、1959年に米国国防総省の呼びかけで設立された組織であり、COBOL言語の策定で知られている。1965年、CODASYLはList Processing Task Forceを設立し、COBOLにデータベース操作機能を追加する検討を開始した。1967年にこの作業部会はData Base Task Group（DBTG）と改名される。

1969年10月、DBTGはネットワーク型データベースモデルの最初の言語仕様を公開した。そして1971年4月、正式なDBTGレポートが発行される。このレポートは、データ定義言語（DDL）、サブスキーマ定義言語、そしてCOBOLに埋め込むデータ操作言語（DML）を標準化した。データベース技術の標準化における画期的文書である。

### セットという概念

CODASYLネットワーク型モデルの核心は「セット」という構造にある。セットは、1つの「オーナー」レコードタイプと1つ以上の「メンバー」レコードタイプから構成される。オーナーからメンバーへの1対多の関係を表現するものだ。

```
CODASYLネットワークモデルのセット構造

  ENROLLMENT セット          OFFERING セット
  (学生が講義を履修)         (講義が学生に提供される)

  ┌──────────┐              ┌──────────┐
  │  学生    │              │  講義    │
  │ (OWNER)  │              │ (OWNER)  │
  └──┬───────┘              └──┬───────┘
     │                         │
     │  ENROLLMENT セット      │  OFFERING セット
     │                         │
  ┌──▼───────┐              ┌──▼───────┐
  │  履修    │              │  履修    │
  │ (MEMBER) │◄────────────►│ (MEMBER) │
  └──────────┘              └──────────┘
          同一の「履修」レコード

  ポインタチェインによる実装:

  学生A ──→ 履修(A,X) ──→ 履修(A,Y) ──→ 学生A（循環）
                │                │
                ▼                ▼
  講義X ──→ 履修(A,X) ──→ 履修(B,X) ──→ 講義X（循環）
  講義Y ──→ 履修(A,Y) ──→ 履修(C,Y) ──→ 講義Y（循環）
```

ここが階層型モデルとの決定的な違いだ。階層型モデルでは、各子は1つの親しか持てない。ネットワーク型モデルでは、1つのメンバーレコードが複数のセットに属することができる。先ほどの「学生と講義」の例で言えば、「履修」レコードが「学生」からのセットと「講義」からのセットの両方に属することで、多対多の関係をデータの重複なしに表現できる。

セットの物理実装は、ポインタチェインだ。オーナーレコードからメンバーレコードへのポインタが連鎖し、最後のメンバーからオーナーへ戻る循環リスト構造をなす。データへのアクセスは、このポインタチェインを辿って行われる。

### ナビゲーション——プログラマが辿る道

CODASYLのデータ操作言語（DML）は、IMSのDL/Iと同様にナビゲーション型だ。プログラマは「現在の位置」を持ち、そこからポインタを辿ってデータを取得する。

典型的なCODASYL DMLの操作を擬似的に示す。

```
FIND FIRST 学生 USING 学生番号 = 'S001'
    -- 学生S001のレコードを見つけ、「現在のレコード」にする

FIND FIRST 履修 WITHIN ENROLLMENT
    -- ENROLLMENTセットの最初のメンバー（履修レコード）を取得

PERFORM UNTIL DB-STATUS = END-OF-SET
    GET 履修
    -- 現在の履修レコードのデータを取得
    FIND OWNER WITHIN OFFERING
    -- OFFERINGセットのオーナー（講義レコード）を取得
    GET 講義
    -- 講義名を表示
    FIND NEXT 履修 WITHIN ENROLLMENT
    -- ENROLLMENTセットの次のメンバーに移動
END-PERFORM
```

この操作は「学生S001が履修しているすべての講義を取得する」という問い合わせだ。SQLなら1行で書ける。

```sql
SELECT c.講義名
FROM 履修 e JOIN 講義 c ON e.講義ID = c.講義ID
WHERE e.学生番号 = 'S001';
```

CODASYLのDMLでは、プログラマが自らポインタチェインを辿り、セットからセットへ渡り歩かなければならない。プログラマはデータベースの物理構造——どのセットがどのレコードタイプを持ち、ポインタがどう繋がっているか——を熟知している必要がある。Bachmanが「ナビゲーター」と呼んだのは、この行為だ。

### CODASYL系DBMSの商業的成功

CODASYL DBTGの仕様に基づいて、複数のベンダーが商用データベース製品を開発した。

最も有名なのがIDMS（Integrated Database Management System）だ。B.F. Goodrichで開発されたIDMSは、John Cullinane率いるCullinane Database Systems（後のCullinet）によって商用化された。Cullinetは1978年に株式公開を果たし、1982年4月27日、ニューヨーク証券取引所（NYSE）に上場した最初のコンピュータソフトウェア企業となった。さらにS&P 500指数に採用された最初のソフトウェア企業でもある。データベースソフトウェアが、ウォール街に認められた瞬間だった。

他にもHoneywell社のIDS/2（BachmanのIDSの後継）、Digital Equipment Corporation（DEC）社のVAX DBMS、Univac社のDMS 1100などが市場に投入された。1970年代から1980年代にかけて、CODASYL系ネットワーク型データベースは企業コンピューティングの主流の一つだった。

---

## 4. 「ナビゲーション」の代償——物理構造と論理構造の密結合

### 何が問題だったのか

階層型モデル（IMS）とネットワーク型モデル（CODASYL）は、ファイルベースのデータ管理が抱えていた問題——データの冗長性、不整合、プログラムとデータの依存性——を大幅に改善した。データの一元管理、並行アクセスの制御、セキュリティの向上。これらはBachmanがIDSで確立し、IMSとCODASYLが発展させた成果だ。

だが、これらのシステムには根本的な限界が残されていた。

第一の問題は、**物理データ構造と論理データ構造の密結合**だ。IMSでは、データのアクセスパスはセグメントの階層構造によって固定される。CODASYLでは、セットの定義とポインタチェインの構造がアクセスパスを規定する。どちらの場合も、プログラムはデータベースの物理的な構造——セグメントの並び、ポインタの接続関係——を「知って」いなければデータにアクセスできない。

これは、データベースの構造を変更したとき、その構造に依存するすべてのプログラムを修正しなければならないことを意味する。新しいセグメントタイプを追加する、セットの構造を変更する——そのたびに、アプリケーションプログラムの修正と再テストが必要になる。第2回で見たファイルベースの「プログラムとデータの依存性」問題が、形を変えて残っていたのだ。

第二の問題は、**アクセスパスの硬直性**だ。階層型モデルでは、データへのアクセスは常にルートからツリーを下る方向で行われる。ネットワーク型モデルでは、あらかじめ定義されたセット構造に沿ってポインタを辿る。どちらの場合も、設計時に想定されていなかったアクセスパターンに対応するのが困難だ。

銀行の口座システムを例に取ろう。「口座→取引履歴」の階層で設計されたIMSデータベースに対して、「2024年1月の全口座の取引合計」を求めたい場合、どうなるか。すべてのルートセグメント（口座）を順次読み、その下のすべての取引履歴セグメントを辿り、日付で絞り込み、金額を集計する——データベース全体のフルスキャンに近い操作が必要になる。SQLならば`SELECT SUM(amount) FROM transactions WHERE date BETWEEN '2024-01-01' AND '2024-01-31'`と書けば、データベースエンジンが最適な実行計画を立てる。だがDL/Iでは、プログラマ自身が効率的な辿り方を設計しなければならない。

第三の問題は、**プログラマへの認知負荷**だ。ナビゲーション型のデータアクセスでは、プログラマは常に「自分が今、データベースのどこにいるか」を把握していなければならない。複雑なデータ構造を持つシステムでは、数十のセグメントタイプや数百のセットが存在し、それらの間を正確にナビゲートするコードを書くことは、高度な専門技能を要求する作業だった。

あるセットのオーナーから別のセットのメンバーへ、そこからさらに別のセットのオーナーへ——この「航行」の途中でプログラマが位置を見失うと、意図しないデータを取得したり、無限ループに陥ったりする。バグの原因は「ツリーの辿り方を間違えた」ことにあるが、その発見と修正は容易ではない。

### 比較から見えるもの

ここで、三つのモデルの特徴を整理しよう。

```
                階層型         ネットワーク型     リレーショナル
                (IMS)         (CODASYL)         (後に登場)
データ構造      ツリー         有向グラフ         テーブル(リレーション)
関係の表現      親子(1:N)      セット(1:N,      外部キー(1:N,
                1親のみ       複数セット可)      M:N直接表現)
アクセス方式    ナビゲーション  ナビゲーション     宣言型(SQL)
物理独立性      低い           低い               高い
スキーマ変更    影響大         影響大             影響小
多対多          データ重複     連関レコード       結合テーブル
プログラマ      物理構造を     物理構造を         論理構造のみ
が知るべきもの  理解必須       理解必須           意識すればよい
```

この比較表は、リレーショナルモデルが「なぜ革命的だったか」を逆説的に示している。階層型とネットワーク型の限界を知って初めて、Coddが1970年の論文で提唱した「データ独立性」の意味が理解できる。

Coddはこう述べた。アプリケーションプログラムは、「データ型の成長やデータ表現の変更から独立している」べきだと。つまり、データベースの物理構造が変わっても、プログラムは修正なしに動き続けるべきだと。

階層型モデルもネットワーク型モデルも、この要件を満たしていなかった。プログラムはデータベースの物理構造に縛られていた。そしてIBMは、自社の主力製品IMSの収益を守るために、Coddのリレーショナルモデルの実装を当初拒否した。革命は、内部からの抵抗を受けることもある。

この物語は第4回で詳しく語る。

### 階層型データベースは「過去の遺物」か

ここで一つ、重要な事実を記しておきたい。

2025年現在、IMSはFortune 1000企業の95%以上で何らかの形で稼働し続けている。米国の上位5銀行すべてがIMSを使用しており、約2,000の顧客が継続的にIMSを利用している。ドイツのAtruvia AGは、IMSで年間800億件のコアバンキングトランザクションを処理している。ピーク時には毎秒12,000件の処理速度を達成する。IMS Version 13は、単一システムで毎秒10万トランザクションの処理能力を実証した。

階層型データベースは「過去の遺物」ではない。特定の用途——大量のトランザクションを高速かつ確実に処理する必要がある金融系基幹システム——において、50年以上にわたりミッションクリティカルな環境で稼働し続けている。

リレーショナルモデルが「正しい」からといって、階層型モデルが「間違っている」わけではない。技術の評価は、その技術が解こうとした問題とのセットでなされるべきだ。IMSは「アポロ宇宙船の部品を管理する」「銀行の勘定処理を1秒たりとも止めない」という問題を解くために設計され、その目的において驚異的な成功を収めている。

---

## 5. ハンズオン: 階層型データモデルの制約を体験する

今回のハンズオンでは、階層型データモデルをJSON構造で模擬的に実装し、「ツリーを辿る」データアクセスの制約を体験する。そして同じデータをリレーショナルモデルで再構成し、柔軟性の差を比較する。

### 演習概要

1. 階層型データモデルをJSONで実装し、ナビゲーション型のデータアクセスを体験する
2. 階層型モデルで多対多の関係を表現しようとしたときの問題を観察する
3. 同じデータをリレーショナルモデル（SQLite）で再構成し、宣言型クエリの柔軟性を体験する

### 環境構築

Docker環境（`ubuntu:24.04`推奨）で実行する。

```bash
docker run -it --rm ubuntu:24.04 bash
apt-get update && apt-get install -y python3 sqlite3
```

### 演習1: 階層型データモデルのナビゲーション

```python
# hierarchical_navigation.py -- 階層型データモデルでのナビゲーション体験
import json

# 階層型データベース（JSON構造でIMSの概念を模擬）
# ルートセグメント: 口座、子セグメント: 取引履歴、孫セグメント: 明細
hierarchical_db = [
    {
        "segment_type": "ACCOUNT",
        "account_id": "A001",
        "name": "Tanaka Taro",
        "balance": 1500000,
        "children": {
            "TRANSACTION": [
                {
                    "tx_id": "T001",
                    "date": "2024-01-15",
                    "type": "deposit",
                    "amount": 500000,
                    "children": {
                        "DETAIL": [
                            {"detail_id": "D001", "memo": "Salary January"}
                        ]
                    }
                },
                {
                    "tx_id": "T002",
                    "date": "2024-01-20",
                    "type": "withdrawal",
                    "amount": 30000,
                    "children": {
                        "DETAIL": [
                            {"detail_id": "D002", "memo": "ATM withdrawal"}
                        ]
                    }
                },
            ]
        }
    },
    {
        "segment_type": "ACCOUNT",
        "account_id": "A002",
        "name": "Suzuki Hanako",
        "balance": 2300000,
        "children": {
            "TRANSACTION": [
                {
                    "tx_id": "T003",
                    "date": "2024-01-10",
                    "type": "deposit",
                    "amount": 800000,
                    "children": {
                        "DETAIL": [
                            {"detail_id": "D003", "memo": "Salary January"}
                        ]
                    }
                },
            ]
        }
    },
]


class HierarchicalNavigator:
    """IMSのDL/Iを模擬したナビゲーター"""

    def __init__(self, db):
        self.db = db
        self.current_root_idx = -1
        self.current_root = None
        self.current_child_type = None
        self.current_child_idx = -1
        self.current_child = None
        self.steps = 0  # ナビゲーション操作の回数を記録

    def gu(self, account_id):
        """GU (Get Unique) -- ルートセグメントを検索"""
        self.steps += 1
        for i, root in enumerate(self.db):
            if root["account_id"] == account_id:
                self.current_root_idx = i
                self.current_root = root
                self.current_child_type = None
                self.current_child_idx = -1
                self.current_child = None
                return root
        return None

    def gn_root(self):
        """GN (Get Next) -- 次のルートセグメントへ移動"""
        self.steps += 1
        self.current_root_idx += 1
        if self.current_root_idx < len(self.db):
            self.current_root = self.db[self.current_root_idx]
            self.current_child_type = None
            self.current_child_idx = -1
            self.current_child = None
            return self.current_root
        return None

    def gnp(self, child_type):
        """GNP (Get Next within Parent) -- 親の範囲内で次の子を取得"""
        self.steps += 1
        if self.current_root is None:
            return None
        children = self.current_root.get("children", {}).get(child_type, [])
        if self.current_child_type != child_type:
            self.current_child_type = child_type
            self.current_child_idx = 0
        else:
            self.current_child_idx += 1
        if self.current_child_idx < len(children):
            self.current_child = children[self.current_child_idx]
            return self.current_child
        self.current_child = None
        return None


# === 問い合わせ1: 口座A001の全取引を取得する ===
print("=== 問い合わせ1: 口座A001の全取引（階層型ナビゲーション） ===")
print()

nav = HierarchicalNavigator(hierarchical_db)

# GU: ルートセグメント（口座A001）を検索
account = nav.gu("A001")
if account:
    print(f"  GU -> 口座: {account['account_id']} {account['name']}")

    # GNP: 子セグメント（取引履歴）を順次取得
    while True:
        tx = nav.gnp("TRANSACTION")
        if tx is None:
            break
        print(f"  GNP -> 取引: {tx['tx_id']} {tx['date']} {tx['type']} {tx['amount']}")

print(f"\n  ナビゲーション操作回数: {nav.steps}")

# === 問い合わせ2: 全口座の2024年1月の入金合計 ===
print("\n=== 問い合わせ2: 全口座の2024年1月入金合計（階層型ナビゲーション） ===")
print()

nav2 = HierarchicalNavigator(hierarchical_db)
total_deposits = 0

# 全ルートセグメントを順次辿る
nav2.current_root_idx = -1
while True:
    account = nav2.gn_root()
    if account is None:
        break
    print(f"  GN -> 口座: {account['account_id']} {account['name']}")

    # 各口座の取引履歴を順次辿る
    while True:
        tx = nav2.gnp("TRANSACTION")
        if tx is None:
            break
        if tx["date"].startswith("2024-01") and tx["type"] == "deposit":
            total_deposits += tx["amount"]
            print(f"    GNP -> 入金発見: {tx['amount']}")

print(f"\n  2024年1月の入金合計: {total_deposits}")
print(f"  ナビゲーション操作回数: {nav2.steps}")
print()
print("  注目: プログラマは全ルートを辿り、各ルートの子を辿り、")
print("  条件に合うものを自分で判別している。")
print("  これが「ナビゲーション」型アクセスの本質だ。")
print("  SQLなら: SELECT SUM(amount) FROM transactions")
print("           WHERE date LIKE '2024-01%' AND type = 'deposit'")
print("  と1行で書ける。")
```

### 演習2: 多対多の関係における階層型モデルの限界

```python
# many_to_many_problem.py -- 階層型モデルで多対多を表現する問題
import json

# 階層型モデルで学生-講義の多対多を表現する
# パターン1: 学生をルートにする
student_root_db = [
    {
        "student_id": "S001",
        "name": "Yamada",
        "courses": [
            {"course_id": "C101", "course_name": "Database", "room": "A301"},
            {"course_id": "C102", "course_name": "Networks", "room": "B205"},
        ]
    },
    {
        "student_id": "S002",
        "name": "Sato",
        "courses": [
            {"course_id": "C101", "course_name": "Database", "room": "A301"},
            {"course_id": "C103", "course_name": "OS", "room": "C110"},
        ]
    },
]

print("=== 階層型モデルでの多対多の問題 ===")
print()

# 問題1: データの冗長性
print("[問題1] データの冗長性")
course_copies = {}
for student in student_root_db:
    for course in student["courses"]:
        cid = course["course_id"]
        if cid not in course_copies:
            course_copies[cid] = []
        course_copies[cid].append(student["student_id"])

for cid, students in course_copies.items():
    if len(students) > 1:
        print(f"  講義 {cid} のデータが {len(students)} 回重複: "
              f"学生 {', '.join(students)} の下にそれぞれ存在")

# 問題2: 更新不整合のシミュレーション
print()
print("[問題2] 更新不整合のシミュレーション")
print("  講義C101の教室を A301 -> D401 に変更する")
print()

# 学生S001の下のC101だけ更新し、S002の下は更新し忘れる
student_root_db[0]["courses"][0]["room"] = "D401"
# student_root_db[1]["courses"][0]["room"] はA301のまま

for student in student_root_db:
    for course in student["courses"]:
        if course["course_id"] == "C101":
            print(f"  学生{student['student_id']}から見た C101 の教室: "
                  f"{course['room']}")

print()
print("  >>> 同じ講義C101の教室情報が学生によって異なる!")
print("  >>> これがデータの不整合。階層型モデルでは、多対多の関係を")
print("  >>> 表現するためにデータを重複させるしかなく、")
print("  >>> 更新漏れによる不整合が構造的に避けられない。")
```

### 演習3: リレーショナルモデルとの比較

```python
# relational_comparison.py -- リレーショナルモデルで同じデータを表現する
import sqlite3
import os

DB_FILE = "university.db"
if os.path.exists(DB_FILE):
    os.remove(DB_FILE)

conn = sqlite3.connect(DB_FILE)
cur = conn.cursor()

# リレーショナルモデル: 正規化されたテーブル
cur.executescript("""
    CREATE TABLE students (
        student_id TEXT PRIMARY KEY,
        name TEXT NOT NULL
    );

    CREATE TABLE courses (
        course_id TEXT PRIMARY KEY,
        course_name TEXT NOT NULL,
        room TEXT NOT NULL
    );

    -- 多対多は結合テーブルで表現（データの重複なし）
    CREATE TABLE enrollments (
        student_id TEXT REFERENCES students(student_id),
        course_id TEXT REFERENCES courses(course_id),
        PRIMARY KEY (student_id, course_id)
    );

    INSERT INTO students VALUES ('S001', 'Yamada');
    INSERT INTO students VALUES ('S002', 'Sato');

    INSERT INTO courses VALUES ('C101', 'Database', 'A301');
    INSERT INTO courses VALUES ('C102', 'Networks', 'B205');
    INSERT INTO courses VALUES ('C103', 'OS', 'C110');

    INSERT INTO enrollments VALUES ('S001', 'C101');
    INSERT INTO enrollments VALUES ('S001', 'C102');
    INSERT INTO enrollments VALUES ('S002', 'C101');
    INSERT INTO enrollments VALUES ('S002', 'C103');
""")

print("=== リレーショナルモデルでの多対多 ===")
print()

# 問い合わせ1: 学生S001の全講義
print("[問い合わせ1] 学生S001の全講義 (SQL: JOIN)")
rows = cur.execute("""
    SELECT s.name, c.course_name, c.room
    FROM students s
    JOIN enrollments e ON s.student_id = e.student_id
    JOIN courses c ON e.course_id = c.course_id
    WHERE s.student_id = 'S001'
""").fetchall()
for row in rows:
    print(f"  {row[0]}: {row[1]} (教室: {row[2]})")

# 問い合わせ2: 講義C101の全受講者
print()
print("[問い合わせ2] 講義C101の全受講者 (SQL: JOIN)")
rows = cur.execute("""
    SELECT c.course_name, s.name
    FROM courses c
    JOIN enrollments e ON c.course_id = e.course_id
    JOIN students s ON e.student_id = s.student_id
    WHERE c.course_id = 'C101'
""").fetchall()
for row in rows:
    print(f"  {row[0]}: {row[1]}")

# 教室の更新（1箇所の更新で全員に反映される）
print()
print("[更新] 講義C101の教室を A301 -> D401 に変更")
cur.execute("UPDATE courses SET room = 'D401' WHERE course_id = 'C101'")

rows = cur.execute("""
    SELECT s.name, c.course_name, c.room
    FROM students s
    JOIN enrollments e ON s.student_id = e.student_id
    JOIN courses c ON e.course_id = c.course_id
    WHERE c.course_id = 'C101'
""").fetchall()
for row in rows:
    print(f"  {row[0]}: {row[1]} (教室: {row[2]})")

print()
print("  >>> 1箇所の更新が全員に即座に反映される。")
print("  >>> データの重複がないため、不整合が発生しない。")
print("  >>> これがリレーショナルモデルの「正規化」の恩恵だ。")

# 問い合わせの柔軟性
print()
print("[柔軟性] 階層型では困難な問い合わせ")
print("  「2科目以上履修している学生」")
rows = cur.execute("""
    SELECT s.name, COUNT(e.course_id) AS course_count
    FROM students s
    JOIN enrollments e ON s.student_id = e.student_id
    GROUP BY s.student_id
    HAVING COUNT(e.course_id) >= 2
""").fetchall()
for row in rows:
    print(f"  {row[0]}: {row[1]}科目")

print()
print("  >>> 階層型モデルでは、このような集約クエリを実行するには")
print("  >>> 全ルートを辿り、子を数え、プログラムで集約する必要がある。")
print("  >>> SQLは「何がほしいか」を宣言するだけで、")
print("  >>> データベースエンジンが最適な実行計画を立てる。")

conn.close()
if os.path.exists(DB_FILE):
    os.remove(DB_FILE)
```

---

## 6. ナビゲーションの終わりと、宣言の始まり

第3回を振り返ろう。

**IBM IMSは、アポロ計画という人類史的プロジェクトから生まれた。** 1966年に開発が始まり、1968年にNASAのRockwell Space Divisionでインストールされ、1969年にIMS/360として商用化された。階層型データモデルは、宇宙船の部品表のように自然なツリー構造を持つデータに対して、高速かつ確実なアクセスを提供した。

**CODASYLネットワーク型モデルは、階層型モデルの限界を乗り越えようとした。** 「セット」という概念によってレコード間の多対多の関係を表現し、IDMSに代表される商用製品は1970年代から1980年代にかけて企業コンピューティングの主流となった。Cullinane Database SystemsがNYSE上場を果たしたことは、データベースソフトウェアの産業としての成熟を象徴している。

**だが、両モデルには共通の限界があった。** 物理データ構造と論理データ構造の密結合、アクセスパスの硬直性、プログラマへの過大な認知負荷。「ナビゲーション」——プログラマがデータベースの物理構造を知り、ポインタチェインやセグメント階層を自ら辿る——というアクセス方式は、データベースの構造変更のたびにプログラムの修正を要求し、想定外の問い合わせパターンに対して脆弱だった。

冒頭の問いに戻ろう。「リレーショナルモデル以前のデータベースは、何を解決し、何に苦しんでいたのか」——階層型とネットワーク型は、ファイルベースの世界からデータ管理を解放した先駆的な功績を持つ。だがその代償として、プログラマをデータの物理構造に縛りつけた。Bachmanが誇りを込めて「ナビゲーター」と呼んだ役割は、裏を返せば「データベースの物理構造を知悉し、ポインタチェインを正確に辿れなければ仕事ができない」という制約でもあった。

2008年に私が金融機関で見たIMSのシステムは、この「ナビゲーション」の世界そのものだった。COBOLプログラムはDL/Iの呼び出しで溢れ、プログラマはセグメント階層を暗記していた。システムは30年以上にわたり一度も止まることなく動き続けていた。だがその代わり、構造の変更は極めて困難で、新しい問い合わせパターンの追加には数ヶ月のプログラム開発が必要だった。

次回は、この「ナビゲーション」の世界を根底から覆した一本の論文を読む。1970年、IBMのSan Jose Research LaboratoryでEdgar F. Coddが発表した「A Relational Model of Data for Large Shared Data Banks」——データベースを「ポインタを辿る」世界から「論理的に問い合わせる」世界に変えた、50年にわたる革命の起点だ。

あなたが今書いているSQLの`SELECT`文。それは「何がほしいか」を宣言しているだけだ。「どう辿るか」は書いていない。その「当たり前」が、どれほど革命的な概念であったかを、次回知ることになるだろう。

---

### 参考文献

- IBM, "History of IMS: Beginnings at NASA". <https://www.ibm.com/docs/en/zos-basic-skills?topic=now-history-ims-beginnings-nasa>
- IBM, "Information Management Systems". <https://www.ibm.com/history/information-management-system>
- InformIT, "IBM Information Management System: From Apollo to Enterprise". <https://www.informit.com/articles/article.aspx?p=1805466>
- InformIT, "IBM's Information Management System: Then and Now". <https://www.informit.com/articles/article.aspx?p=377307>
- Charles W. Bachman, "The Programmer as Navigator", _Communications of the ACM_, Vol.16, No.11, November 1973. <https://people.csail.mit.edu/tdanford/6830papers/bachman-programmer-as-navigator.pdf>
- ACM A.M. Turing Award, "Charles W Bachman". <https://amturing.acm.org/award_winners/bachman_9385610.cfm>
- Wikipedia, "Data Base Task Group". <https://en.wikipedia.org/wiki/Data_Base_Task_Group>
- Wikipedia, "CODASYL". <https://en.wikipedia.org/wiki/CODASYL>
- Wikipedia, "IDMS". <https://en.wikipedia.org/wiki/IDMS>
- Wikipedia, "Cullinet". <https://en.wikipedia.org/wiki/Cullinet>
- Two-Bit History, "Important Papers: Codd and the Relational Model". <https://twobithistory.org/2017/12/29/codd-relational-model.html>
- Two-Bit History, "The Most Important Database You've Never Heard of". <https://twobithistory.org/2017/10/07/the-most-important-database.html>
- TechTarget, "What is IBM IMS (Information Management System)?". <https://www.techtarget.com/searchdatacenter/definition/IMS-Information-Management-System>
- IBM, "IMS Product Page". <https://www.ibm.com/products/ims>
- Silberschatz, Korth, Sudarshan, "Appendix D: Network Model", _Database System Concepts_, 6th Edition. <https://www.db-book.com/db6/appendices-dir/d.pdf>
- Edgar F. Codd, "A Relational Model of Data for Large Shared Data Banks", _Communications of the ACM_, Vol.13, No.6, June 1970. <https://dl.acm.org/doi/10.1145/362384.362685>

---

**次回予告：** 第4回「Coddの革命——リレーショナルモデルの誕生」では、1970年のCoddの論文が何を主張し、なぜ50年以上にわたってデータベースの世界を支配し続けているのかを読み解く。関係代数という数学的基盤、データの論理的独立性という革命的概念、そしてIBMの内部抵抗——一人の数学者がデータベースの歴史を変えた物語。
