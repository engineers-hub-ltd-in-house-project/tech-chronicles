# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第2回：ファイルからデータベースへ——データ管理の夜明け

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- パンチカードから磁気テープ、そしてディスクへ——ストレージメディアの進化がデータ管理をどう変えたか
- ISAM（Indexed Sequential Access Method）が解決した問題と、それでも残った限界
- ファイルベースのデータ管理が抱える6つの根本問題——冗長性、不整合、依存性、孤立、並行アクセス、セキュリティ
- CSVファイルへの複数プロセスからの同時書き込みで、データが壊れる過程を観察する方法

---

## 1. Perlスクリプトとファイルロックの日々

1999年、私はPerlでCGIスクリプトを書いていた。

当時の典型的なWebアプリケーションは、データの保存先にテキストファイルを使っていた。掲示板、アクセスカウンタ、ゲストブック——1990年代後半のWebにあふれていたこれらのアプリケーションは、その大半がCSVやタブ区切りのテキストファイルにデータを格納していた。MySQLは存在していたが、レンタルサーバで使える環境は限られていた。PostgreSQLとなればなおさらだ。テキストファイルは「誰でも使える」データストアだった。

私が最初に書いたデータ管理のコードは、こんな形をしていた。

```perl
# データをファイルに追記する
open(my $fh, '>>', 'data.csv') or die "Cannot open: $!";
flock($fh, 2);  # 排他ロック
print $fh "$id,$name,$email\n";
close($fh);
```

`flock`——Perlの公式ドキュメントによれば、これはファイルに対する「アドバイザリーロック」を提供する関数だ。共有ロック（読み取り用）と排他ロック（書き込み用）の二種類がある。排他ロックを取得すれば、他のプロセスが同時に書き込むことを防げる。理屈の上では。

だが、アドバイザリーロックには致命的な制約がある。`flock`を使っていないプログラムからは何の保護もされないのだ。別のスクリプトが同じファイルを`flock`なしで開けば、ロックは無視される。そしてCGI環境では、Webサーバがリクエストごとにプロセスを生成する。ピーク時には数十のプロセスが同時に同一ファイルにアクセスする。ロックの取得待ちでプロセスが溜まり、タイムアウトし、最悪の場合はデータが壊れる。

ある日、運営していた小規模なWebサービスの掲示板データが壊れた。ファイルの途中から文字化けのような意味不明なバイト列が並んでいる。原因を追うと、二つのプロセスが同時にファイルを書き込み、一方の書き込みが他方を途中で上書きしていた。`flock`は使っていた。だが、ファイルを開いてから`flock`を呼ぶまでの一瞬の隙間に、別のプロセスが割り込んでいたのだ。

そのとき私は、データの管理をテキストファイルで行うことの根本的な限界を、身をもって知った。

この「テキストファイルでデータを管理する」という営みは、コンピュータの歴史と同じだけの歴史を持っている。1950年代のパンチカード、1960年代の磁気テープ、そしてディスク。データを物理的なメディアに記録し、プログラムから読み書きする——その原始的な行為から、データベースという概念が生まれるまでには、長い試行錯誤の歴史があった。

あなたのプロジェクトで、設定ファイルやCSVファイルにデータを保存したことはあるだろうか。そのとき、「これ以上は無理だ」と感じた瞬間はあっただろうか。その「無理」の正体を、50年以上前の先人たちも同じように感じていた。

---

## 2. パンチカードからディスクへ——記録メディアの革命

データベースの歴史を語るには、まずデータの「入れ物」の歴史から始めなければならない。なぜなら、データの管理方法はストレージメディアの制約に規定されるからだ。

### パンチカードの時代

コンピュータによるデータ処理の起源は、1890年の米国国勢調査にまで遡る。Herman Hollerithは1880年代後半に、パンチカードによるデータ記録の仕組みを発明した。穴の位置でデータを符号化し、電気的に読み取る。この仕組みを使った集計機（タビュレーティングマシン）は、1890年の国勢調査をわずか6ヶ月で集計し、500万ドルと2年以上の労力を節約したと報告されている。

Hollerithの会社は1911年にComputing-Tabulating-Recording Company（CTR）に統合され、1924年にInternational Business Machines Corporation——IBMと改名された。1950年代半ばでも、パンチカードの売上はIBMの収益の約20%、利益の約30%を占めていた。パンチカードはデータ処理の基盤であり、IBMの屋台骨だった。

パンチカードによるデータ管理には、物理的な制約が付きまとう。1枚のカードに記録できるのは80文字（80桁）。1万件の顧客レコードを管理するには1万枚のカードが必要で、それを物理的に並べ替え、保管し、検索しなければならない。「ID順にソートする」という操作は、カードソーターという機械に何度もカードを通す作業を意味した。1回の通過で1桁しかソートできないため、8桁のIDなら8回の通過が必要だ。

データの「検索」は、物理的にカードをめくることだった。

### 磁気テープ——シーケンシャルアクセスの世界

1951年、データ管理の世界に最初の転換点が訪れる。Eckert-Mauchly Computer Corporation（後にRemington Randに買収）が開発したUNISERVOドライブが、UNIVAC Iコンピュータ用に導入された。Computer History Museumの記録によれば、磁気テープが初めてコンピュータデータの記録に使われた瞬間である。0.5インチ幅のニッケルメッキ・リン青銅の金属ストリップに、最大100万文字を格納できた。

翌1952年には、IBMがModel 726磁気テープユニットをIBM 701とともに発表する。以降、磁気テープは1950年代から1960年代にかけてデータ処理の標準ストレージとなった。

磁気テープの衝撃は、その容量効率にある。1959年に発表されたIBM 1401——IBMが「コンピュータ業界のフォード・モデルT」と称し、12,000台以上が製造された大衆的ビジネスコンピュータ——は、パンチカードと磁気テープの両方に対応していた。IBMの公式記録によれば、1本2ポンドの磁気テープに1,200万文字を格納できた。同じ容量のパンチカードは16万枚、80箱、800ポンドだ。容量は劇的に改善された。

だが、磁気テープには本質的な制約がある。シーケンシャルアクセスだ。

テープの途中にあるデータを読むには、先頭から順にテープを送らなければならない。カセットテープで特定の曲を聴くために早送りする——あの感覚に近い。10万件目のレコードを読むには、先行する9万9999件分のテープを物理的に送る必要がある。

この制約は、1960年代のデータ処理のワークフローを完全に規定した。マスターファイル（顧客台帳、在庫台帳など）は磁気テープに保存される。日中に発生した取引データはパンチカードに記録され、夜間のバッチ処理でマスターファイルを更新する。更新のためには、マスターテープを先頭から末尾まで読みながら、該当するレコードを新しいテープに書き出す。テープ上のレコードは識別番号でソートされている必要があり、取引データも同じ順序にソートしてからマージする。磁気テープ上のレコードの繰り返しマージによるソートは、膨大な時間を消費した。

「リアルタイム」という概念は存在しなかった。朝の時点で見ている在庫データは、前日夜のバッチ処理の結果だ。今この瞬間の在庫数を知ることは、原理的に不可能だった。

### ディスク——ランダムアクセスの夜明け

1956年9月13日、データ管理の歴史を根底から変える装置が出荷される。IBM 305 RAMAC（Random Access Method of Accounting and Control）だ。

RAMACのIBM 350ディスクユニットは、24インチ径のディスクを50枚重ね、500万文字を格納した。Computer History Museumの記録によれば、1レコードの平均アクセス時間は600ミリ秒。現代の感覚では途方もなく遅いが、テープを巻き戻す時間と比べれば革命的だった。任意のレコードに直接アクセスできる——ランダムアクセス——という概念が、商用コンピュータの世界に初めて導入されたのだ。

重量は1トン超。フォークリフトで運び、大型貨物機で輸送された。月額レンタル3,200ドル。1,000台以上が製造され、1961年に製造終了。だがRAMACが切り拓いた「ランダムアクセス・ストレージ」という概念は、以後のデータ管理のすべてを方向づけた。

1964年4月7日、IBMはSystem/360を発表する。商用・科学計算の両方をカバーする初のコンピュータファミリーだ。そのオペレーティングシステムOS/360は、少なくとも1台のDirect Access Storage Device（DASD）を必要とした最初期のOSの一つだった。「ディスクが標準装備」という前提が、ここで確立される。

ディスクの登場は、データ管理に根本的な変化をもたらした。テープの時代は「先頭から順に読む」しかなかった。ディスクの時代は「任意の場所に直接飛べる」。この物理的な能力の変化が、ISAM——データ管理に「索引」という概念を導入したアクセス方式——を可能にした。

---

## 3. ファイルベースのデータ管理が抱えた闇

ストレージがパンチカードからテープ、テープからディスクへと進化しても、データの管理方式そのものはすぐには変わらなかった。1960年代の企業コンピューティングにおけるデータ管理は、依然として「ファイルベース」だった。アプリケーションプログラムがそれぞれ独自のファイルを持ち、独自のフォーマットで読み書きする。この方式が企業の成長とともにどのような問題を引き起こしたかを、技術的に掘り下げたい。

### ISAMの登場と限界

ディスクの普及とともに、IBMは1960年代初頭にISAM（Indexed Sequential Access Method）を開発した。ISAMはIBM 7080コンピュータ向けのIndexed Sequential Data Organization（ISDO）を起源とし、OS/360とともに広く普及した。

ISAMの仕組みは、書籍の索引に似ている。データファイルの先頭にインデックス（索引）領域を設け、各レコードのキー値とディスク上の物理位置を対応づける。検索時には、まずインデックスを読んで目的のレコードの位置を特定し、そこに直接ジャンプする。シーケンシャルアクセス（先頭から順に読む）とランダムアクセス（任意のレコードに直接飛ぶ）の両方を提供する——それがISAMの革新だった。

```
ISAM の構造（概念図）

┌─────────────────────────────┐
│  マスターインデックス       │  ← トラックインデックスのどのブロックか
├─────────────────────────────┤
│  シリンダーインデックス     │  ← どのシリンダー（トラック群）か
├─────────────────────────────┤
│  トラックインデックス       │  ← どのトラック上のどのレコードか
├─────────────────────────────┤
│                             │
│  データ領域                 │  ← 実際のレコード群（キー順に配置）
│  ┌──┬──┬──┬──┬──┬──┐      │
│  │01│02│03│04│05│06│ ...  │
│  └──┴──┴──┴──┴──┴──┘      │
│                             │
├─────────────────────────────┤
│  オーバーフロー領域         │  ← 追加レコードの格納先
└─────────────────────────────┘
```

ISAMは、在庫管理システムや初期のデータベース管理において、バッチ処理のためのシーケンシャル処理と、個別問い合わせのためのランダム検索の両方が不可欠だったアプリケーションに適していた。

だが、ISAMには根本的な弱点があった。

第一に、物理構造への依存だ。インデックスはディスク上の物理位置（シリンダー、トラック）を直接指し示す。ディスクの構成が変われば、インデックスも作り直しになる。データの論理的な構造と物理的な配置が密結合している。

第二に、レコードの追加と削除の非効率さだ。ISAMではデータがキー順に物理的に配置されている。新しいレコードを途中に挿入するには、オーバーフロー領域にレコードを追加し、チェインでつなぐ。追加が増えるとオーバーフロー領域が肥大化し、検索性能が劣化する。定期的にファイル全体を再編成（リオーガナイズ）する必要があった。

1972年、IBMはISAMの後継としてVSAM（Virtual Storage Access Method）をOS/VS1とともにリリースする。VSAMはデバイス依存性を排除し、よりしなやかなレコード管理を実現した。だが、VSAMもまた「ファイルベース」のアクセス方式であり、データベースではない。

### 6つの根本問題

ISAMやVSAMが解決したのは「効率的なファイルアクセス」であり、「データ管理」ではない。企業のデータが増え、アプリケーションが増え、部門ごとに異なるプログラマが異なるファイルを異なるフォーマットで作成する——その結果、ファイルベースのデータ管理は6つの根本問題に直面した。

**問題1: データの冗長性（Data Redundancy）**

人事部は従業員の名前と住所を`employee.dat`に持っている。経理部は給与計算のために`payroll.dat`に同じ従業員の名前と住所を持っている。営業部は`sales_staff.dat`にまた同じ情報を持っている。同一のデータが組織のあちこちに複製される。これがデータの冗長性だ。

冗長性はストレージの浪費だけの問題ではない。真の問題は次に来る。

**問題2: データの不整合（Data Inconsistency）**

従業員の住所が変わった。人事部は`employee.dat`を更新した。だが経理部の`payroll.dat`は更新されなかった。営業部の`sales_staff.dat`も古いままだ。同一人物の住所が、部門ごとに異なる——これがデータの不整合だ。

ファイルベースのシステムでは、データの一貫性を保証する仕組みが存在しない。各部門が各自のファイルを各自のプログラムで更新する。「すべてのコピーを同時に更新する」ことを強制する仕組みはどこにもない。整合性の維持は、運用ルールと人間の注意力に依存する。

**問題3: プログラムとデータの依存性（Program-Data Dependence）**

ファイルの物理構造——レコードの長さ、フィールドの並び順、データ型——は、アプリケーションプログラムのコードに直接埋め込まれている。COBOLプログラムのDATA DIVISIONには、ファイルのレコードレイアウトが一字一句定義されている。

```cobol
01 EMPLOYEE-RECORD.
   05 EMP-ID        PIC 9(5).
   05 EMP-NAME      PIC X(30).
   05 EMP-DEPT      PIC X(10).
   05 EMP-SALARY    PIC 9(7)V99.
```

ここで「住所フィールドを追加したい」としよう。ファイルのレコードレイアウトが変わる。すると、このファイルを読むすべてのプログラムを修正し、再コンパイルし、再テストしなければならない。10個のプログラムがこのファイルを使っていれば、10個すべてを修正する必要がある。フィールドを1つ追加するだけで。

これがプログラムとデータの依存性だ。データの論理的な構造の変更が、プログラムの物理的な修正を連鎖的に要求する。

**問題4: データの孤立（Data Isolation）**

各部門が独自のファイルを独自のフォーマットで管理している。人事部はCOBOLのファイル形式、営業部はFortranのファイル形式、技術部はまた別の形式。ファイル構造がバラバラであるため、部門をまたいだデータの統合は極めて困難だ。

「全従業員の中で、営業成績が上位10%かつ勤続年数10年以上の人の一覧がほしい」——このような部門横断の問い合わせは、各部門のファイルを個別にプログラムで読み出し、マージするための新しいプログラムを一から書くことを意味した。データは存在している。だが、散在するファイルの中に孤立している。

**問題5: 並行アクセスの制限（Concurrency Limitations）**

第1回で体験したとおり、ファイルベースのシステムでは並行アクセスの制御が極めて原始的だ。典型的には、ファイル全体をロックする。一人が書き込んでいる間は、他の全員が待たされる。100人が同時にアクセスするシステムでは、事実上、直列処理に退化する。

1960年代のバッチ処理中心の世界では、この制約はさほど問題にならなかった。夜間にバッチジョブが走り、翌朝に結果が出る。同時アクセスは想定外だ。だが、1960年代後半からオンライン・トランザクション処理（OLTP）の需要が高まると、この制約は致命的になる。

**問題6: セキュリティの欠如**

ファイルベースのシステムでは、アクセス制御はOSのファイルパーミッションに依存する。ファイル全体に対して「読める/読めない」「書ける/書けない」を制御するのが精一杯だ。「このファイルの中の、給与フィールドだけは人事部以外に見せない」——そのようなフィールドレベルのアクセス制御は、ファイルシステムの守備範囲外だ。

### 6つの問題が合流する地点

これら6つの問題は、個別に見ればそれぞれ深刻だが、組織の成長とともに相互に増幅し合う。データが冗長に複製されるから不整合が生じる。不整合を防ごうとすればプログラムが複雑化する。プログラムがデータの物理構造に依存しているから、変更のたびに連鎖的な修正が必要になる。データが孤立しているから、部門横断の分析ができない。並行アクセスの制限があるから、リアルタイムの業務に対応できない。

1960年代の企業は、まさにこの問題の渦中にいた。コンピュータの導入が進み、処理するデータ量は増え続ける。だが、データの管理方式は「各プログラムが各自のファイルを持つ」という原始的なモデルから抜け出せない。

この行き詰まりを打ち破ったのが、「データベース管理システム」（DBMS）という概念だった。

---

## 4. DBMSの誕生——データを「解放」する

ファイルベースのデータ管理の限界が明らかになるにつれ、データを個々のプログラムから分離し、一元的に管理するシステムの必要性が認識されるようになった。その最初の実装が、Charles W. BachmanのIDS（Integrated Data Store）だ。

### Bachmanの革命

1960年代初頭、General Electricの企業サービス部門に所属していたBachmanは、製造管理システムの開発に取り組んでいた。当時のデータ管理は、アプリケーションプログラムがファイルの読み書きを直接行う方式——まさに前節で述べた「ファイルベース」のアプローチだった。

Bachmanが構想したのは、データの管理を専門に担う独立したソフトウェア層だ。アプリケーションプログラムは、ファイルの物理構造を意識することなく、「このデータがほしい」とDBMSに要求する。物理構造の管理——レコードの配置、インデックスの維持、ディスクI/Oの最適化——はすべてDBMSが引き受ける。

```
ファイルベース:
  アプリA ──→ ファイルX
  アプリB ──→ ファイルY  （同じデータの重複）
  アプリC ──→ ファイルZ  （フォーマットが異なる）

DBMS導入後:
  アプリA ─┐
  アプリB ─┼──→ DBMS ──→ 統合データ
  アプリC ─┘
```

IDSの詳細な機能仕様は1962年1月に完成し、1963年夏にはプロトタイプが実データでテストされた。Communications of the ACMの記事（「How Charles Bachman Invented the DBMS, a Foundation of Our Digital World」）によれば、IDSのプロトタイプは既存の専用製造管理システムの2倍の速度で同じタスクを処理した。1964年にGE 235コンピュータ向けにソフトウェアがリリースされ、1965年にはWeyerhaeuser Lumber社向けにWEYCOSと呼ばれるシステムが構築された。BachmanはWEYCOSを「複数のアプリケーションプログラムが同時に同じデータベースにアクセスできる最初のDBMS」と位置づけている。

この功績により、Bachmanは1973年にACMチューリング賞を受賞する。受賞講演のタイトルは「The Programmer as Navigator」——プログラマはデータの海を航行する者だ、という宣言だった。

### DBMS が解決したもの

Bachman の IDS と、それに続く DBMS の概念は、ファイルベースのデータ管理が抱えていた 6 つの問題に対して、構造的な解答を示した。

**冗長性と不整合の抑制:** データを一元管理することで、同じデータの不必要な複製を排除する。一箇所を更新すれば、すべてのアプリケーションが更新後のデータを参照する。

**プログラムとデータの独立性:** アプリケーションはDBMSのインターフェースを通じてデータにアクセスする。データの物理構造が変わっても、アプリケーションの修正は不要——あるいは最小限で済む。これが「データ独立性」の概念であり、後にCoddのリレーショナルモデルで数学的に定式化される。

**データの統合:** 散在するファイルを統合し、部門横断のデータアクセスを可能にする。「全従業員の中で、営業成績が上位10%かつ勤続年数10年以上の人」——この問い合わせは、データが統合されていれば一つの操作で実行できる。

**並行アクセスの制御:** DBMS が排他制御を一元的に管理する。ファイルロックではなく、レコードレベルのロックや、後のMVCC（Multi-Version Concurrency Control）により、複数のユーザーが同時にデータを操作できる。

**セキュリティの強化:** DBMSが認証と認可を管理する。「このユーザーは、この表の、このフィールドを読める」——そのような細粒度のアクセス制御が可能になる。

### IDS から CODASYL へ

IDS は、単独のシステムとしての成功にとどまらなかった。1969年、CODASYL（Conference on Data Systems Languages）のData Base Task Group（DBTG）が、IDSを基盤としたネットワーク型データベースの言語仕様を公開する。ここでデータ定義言語（DDL）、サブスキーマ定義言語、そしてCOBOLに埋め込むデータ操作言語（DML）が標準化された。

CODASYLはもともと1959年に米国国防総省の呼びかけで設立された組織であり、COBOLの策定で知られている。そのCODASYLが、データベースの標準化にも乗り出した。これは、データ管理がもはや「各社が独自に解決する問題」ではなく、「業界全体で標準化すべき基盤技術」と認識されたことを意味する。

だが、IDSやCODASYLのネットワーク型データベースは、第3回で詳しく見るように、それ自体が新たな問題を抱えていた。データの物理構造（ポインタチェイン）と論理構造の密結合——ファイルベースの世界から抜け出したはずなのに、プログラマは依然として「データの物理的な配置」を意識しなければならなかった。

この「密結合」からの完全な解放を実現するのは、1970年のCoddのリレーショナルモデルを待たねばならない。それは第4回で語る。

---

## 5. ハンズオン: CSVファイルベースのデータ管理と同時書き込みの破壊

前回のハンズオンでは、テキストファイルによるCRUD操作と並行アクセスの問題を体験した。今回は一歩踏み込んで、「複数部門がそれぞれ独自のCSVファイルを持つ」状況を再現し、ファイルベースのデータ管理が抱える冗長性・不整合の問題を体験する。そして、ファイルロック（flock）の限界を観察する。

### 演習概要

1. 複数のCSVファイルに同じデータが重複する状況を再現する
2. 一方を更新し、他方が不整合になる様子を観察する
3. ファイルロック（flock相当）を実装しても残る問題を体験する

### 環境構築

Docker環境（`ubuntu:24.04`推奨）で実行する。

```bash
docker run -it --rm ubuntu:24.04 bash
apt-get update && apt-get install -y python3
```

### 演習1: データの冗長性と不整合を再現する

```python
# redundancy_demo.py -- データの冗長性と不整合を体験する
import csv
import os

# 「人事部」と「経理部」がそれぞれ独自のファイルを持つ
HR_FILE = "hr_employees.csv"
ACCOUNTING_FILE = "accounting_payroll.csv"

HR_FIELDS = ["emp_id", "name", "address", "department"]
ACC_FIELDS = ["emp_id", "name", "address", "salary"]

def init_files():
    """両部門のファイルを初期化する（同じ従業員データを重複して保持）"""
    employees = [
        {"emp_id": "001", "name": "Tanaka", "address": "Tokyo", "department": "Sales"},
        {"emp_id": "002", "name": "Suzuki", "address": "Osaka", "department": "Engineering"},
        {"emp_id": "003", "name": "Yamada", "address": "Nagoya", "department": "Marketing"},
    ]

    # 人事部ファイル
    with open(HR_FILE, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=HR_FIELDS)
        writer.writeheader()
        for emp in employees:
            writer.writerow({k: emp[k] for k in HR_FIELDS})

    # 経理部ファイル（同じデータ + 給与情報）
    with open(ACCOUNTING_FILE, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=ACC_FIELDS)
        writer.writeheader()
        salaries = {"001": 5000000, "002": 6000000, "003": 4500000}
        for emp in employees:
            writer.writerow({
                "emp_id": emp["emp_id"],
                "name": emp["name"],
                "address": emp["address"],
                "salary": salaries[emp["emp_id"]],
            })

def update_hr_address(emp_id, new_address):
    """人事部がアドレスを更新する（経理部のファイルは更新されない）"""
    rows = []
    with open(HR_FILE, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row["emp_id"] == emp_id:
                row["address"] = new_address
            rows.append(row)
    with open(HR_FILE, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=HR_FIELDS)
        writer.writeheader()
        writer.writerows(rows)

def check_consistency():
    """両ファイルの整合性を確認する"""
    hr_data = {}
    with open(HR_FILE, "r") as f:
        for row in csv.DictReader(f):
            hr_data[row["emp_id"]] = row

    acc_data = {}
    with open(ACCOUNTING_FILE, "r") as f:
        for row in csv.DictReader(f):
            acc_data[row["emp_id"]] = row

    print("=== 整合性チェック ===")
    inconsistencies = 0
    for emp_id in hr_data:
        if emp_id in acc_data:
            hr_addr = hr_data[emp_id]["address"]
            acc_addr = acc_data[emp_id]["address"]
            if hr_addr != acc_addr:
                inconsistencies += 1
                print(f"  不整合発見! ID={emp_id}:")
                print(f"    人事部:  address={hr_addr}")
                print(f"    経理部:  address={acc_addr}")
    if inconsistencies == 0:
        print("  不整合なし")
    else:
        print(f"\n  {inconsistencies}件の不整合が発生している。")
        print("  同一データが複数ファイルに分散している限り、")
        print("  この問題は構造的に解決できない。")

if __name__ == "__main__":
    print("=== データの冗長性と不整合のデモ ===\n")

    # 初期状態: 両ファイルのデータは一致している
    init_files()
    print("[初期状態]")
    check_consistency()

    # 人事部がTanakaの住所を更新する
    # （経理部のファイルは更新されない）
    print("\n[人事部がTanakaの住所を更新]")
    update_hr_address("001", "Yokohama")

    # 不整合が発生している
    check_consistency()
```

このスクリプトは、人事部と経理部がそれぞれ独自のCSVファイルに従業員データを保持する状況を再現する。人事部が住所を更新しても、経理部のファイルは古いまま。同一人物の住所が部門ごとに異なる「データの不整合」が発生する。

### 演習2: ファイルロック（flock相当）の限界を体験する

```python
# flock_limitation.py -- ファイルロックの限界を体験する
import csv
import fcntl
import multiprocessing
import time
import os

DATA_FILE = "shared_inventory.csv"

def init_inventory():
    """在庫ファイルを初期化する"""
    with open(DATA_FILE, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["item_id", "name", "stock"])
        writer.writerow(["001", "Widget-A", 100])

def read_stock_with_lock():
    """ロック付きで在庫を読む"""
    with open(DATA_FILE, "r") as f:
        fcntl.flock(f.fileno(), fcntl.LOCK_SH)  # 共有ロック
        reader = csv.DictReader(f)
        rows = list(reader)
        fcntl.flock(f.fileno(), fcntl.LOCK_UN)
    return int(rows[0]["stock"]) if rows else 0

def update_stock_with_lock(new_stock):
    """ロック付きで在庫を書く"""
    with open(DATA_FILE, "w", newline="") as f:
        fcntl.flock(f.fileno(), fcntl.LOCK_EX)  # 排他ロック
        writer = csv.writer(f)
        writer.writerow(["item_id", "name", "stock"])
        writer.writerow(["001", "Widget-A", new_stock])
        fcntl.flock(f.fileno(), fcntl.LOCK_UN)

def purchase_item(worker_id, n_purchases):
    """在庫を1つずつ減らす（ロック付き、だが Read-Then-Write の隙間あり）"""
    for i in range(n_purchases):
        # 読み取りと書き込みが別のロック取得
        # この隙間に別プロセスが割り込む
        stock = read_stock_with_lock()
        if stock > 0:
            time.sleep(0.001)  # 処理時間のシミュレーション
            update_stock_with_lock(stock - 1)

if __name__ == "__main__":
    WORKERS = 4
    PURCHASES_PER_WORKER = 10

    print("=== ファイルロック(flock)の限界 ===\n")
    print(f"ワーカー数: {WORKERS}")
    print(f"各ワーカーの購入回数: {PURCHASES_PER_WORKER}")
    print(f"初期在庫: 100")
    print(f"期待される最終在庫: {100 - WORKERS * PURCHASES_PER_WORKER}\n")

    init_inventory()

    processes = []
    for i in range(WORKERS):
        p = multiprocessing.Process(
            target=purchase_item,
            args=(i, PURCHASES_PER_WORKER),
        )
        processes.append(p)

    for p in processes:
        p.start()
    for p in processes:
        p.join()

    final_stock = read_stock_with_lock()
    expected = 100 - WORKERS * PURCHASES_PER_WORKER

    print(f"最終在庫: {final_stock}")
    print(f"期待値:   {expected}")
    print(f"差異:     {final_stock - expected}")

    if final_stock != expected:
        print(f"\n>>> ロックを使っているのにデータが不正確!")
        print(f">>> 原因: Read(共有ロック) と Write(排他ロック) が")
        print(f">>>       別々のロック取得であるため、")
        print(f">>>       Read後〜Write前の隙間に他プロセスが介入する。")
        print(f">>> これが TOCTOU (Time of Check to Time of Use) 問題である。")
        print(f">>>")
        print(f">>> データベースはこれを、トランザクションの")
        print(f">>> 分離性(Isolation) で解決する。")
        print(f">>> BEGIN; SELECT stock FROM ... FOR UPDATE;")
        print(f">>> UPDATE ... SET stock = stock - 1; COMMIT;")
    else:
        print("\n(今回はたまたま正確だった。再実行すると不正確になる可能性がある)")
```

この演習のポイントは、`flock`を「正しく使っている」にもかかわらず問題が起きることだ。読み取りと書き込みがそれぞれ別のロック取得になるため、「読んだ値に基づいて書く」操作がアトミックにならない。これはTOCTOU（Time of Check to Time of Use）問題と呼ばれ、ファイルロックでは構造的に解決できない。

データベースのトランザクションは、`BEGIN`から`COMMIT`までの操作をアトミックな単位として扱い、この問題を根本的に解決する。`SELECT ... FOR UPDATE`は読み取りと同時にロックを取得し、`COMMIT`まで他のトランザクションの介入を防ぐ。ファイルロックの「読み取りロック」と「書き込みロック」の分離という設計上の限界を、トランザクションは乗り越えている。

---

## 6. ファイルの限界、データベースの始まり

第2回を振り返ろう。

**ストレージメディアの進化がデータ管理を規定した。** パンチカードの80文字から、磁気テープの100万文字、そしてディスクのランダムアクセスへ。1956年のIBM 305 RAMACがランダムアクセス・ストレージを実現したとき、「先頭から順に読む」しかなかった世界に「任意の場所に直接飛ぶ」可能性が開かれた。この物理的な可能性が、ISAMのようなインデックス付きアクセス方式を生み出し、さらにはデータベースという概念そのものの土壌を耕した。

**ISAMは進歩だったが、まだファイルの延長線上にあった。** シーケンシャルアクセスとランダムアクセスの両方を提供したISAMは、テープ時代のバッチ処理を超える進歩だった。だが、物理構造への依存、レコード追加時のオーバーフロー、定期的な再編成の必要性——ISAMはファイルベースのデータ管理の「改良」であって「革命」ではなかった。

**ファイルベースのデータ管理は、6つの構造的問題を抱えていた。** データの冗長性、不整合、プログラムとデータの依存性、データの孤立、並行アクセスの制限、セキュリティの欠如。これらの問題は、個別に見れば技術的に対処可能に見える。だが組織の成長とともに相互に増幅し合い、やがて手に負えなくなった。

**BachmanのIDSが、DBMSという概念を生み出した。** 1963年にプロトタイプがテストされ、1964年にリリースされたIDS（Integrated Data Store）は、データの管理をアプリケーションから分離した最初のシステムだった。データの一元管理、データ独立性、並行アクセスの制御——後のすべてのデータベースに受け継がれる基本理念が、ここで確立された。

冒頭の問いに戻ろう。「最初のデータ管理は、どのように行われていたのか」——その答えは、パンチカードとテープとファイルだ。そしてその管理方式は、データが増え、ユーザーが増え、組織が複雑化するにつれて、構造的な限界に突き当たった。

私のPerlスクリプトの`flock`が壊れたのと同じ理由で、1960年代の企業のファイルベースシステムも限界を迎えた。データの管理を各プログラムに委ねている限り、冗長性と不整合は避けられない。並行アクセスの問題はファイルロックでは根本的に解決できない。データの物理構造に依存したプログラムは、変更に対して脆弱だ。

だがBachmanのIDSも、そしてその思想を受け継いだCODASYLのネットワーク型データベースも、完璧ではなかった。プログラマは依然として「データの物理的な配置」——ポインタチェインを辿る「ナビゲーション」——を意識しなければならなかった。ファイルベースの世界から一歩抜け出したとはいえ、「データの論理構造と物理構造の完全な分離」にはまだ届いていなかった。

次回は、IDSとCODASYLが切り拓いた「階層型データベース」と「ネットワーク型データベース」の世界を探る。IBMのIMS（Information Management System）——NASAアポロ計画の部品管理から生まれたシステム——と、Bachmanが標準化に貢献したCODASYLネットワークモデル。リレーショナルモデル以前の世界は、何を解決し、何に苦しんでいたのか。

あなたのプロジェクトで、データの管理方式を「設計した」ことはあるだろうか。RDBのテーブル設計は、何となくエンティティを洗い出してCREATE TABLEを書くだけの作業になっていないだろうか。次回、階層型とネットワーク型の世界を知れば、「テーブルに行を格納する」というリレーショナルモデルの単純さが、いかに革命的な抽象化だったかが見えてくるはずだ。

---

### 参考文献

- IBM, "The punched card". <https://www.ibm.com/history/punched-card>
- Computer History Museum, "Tape unit developed for data storage", 1951年. <https://www.computerhistory.org/storageengine/tape-unit-developed-for-data-storage/>
- IBM, "Magnetic tape". <https://www.ibm.com/history/magnetic-tape>
- IBM, "The IBM 1401". <https://www.ibm.com/history/1401>
- Computer History Museum, "First commercial hard disk drive shipped", 1956年. <https://www.computerhistory.org/storageengine/first-commercial-hard-disk-drive-shipped/>
- IBM, "RAMAC". <https://www.ibm.com/history/ramac>
- IBM, "The IBM System/360". <https://www.ibm.com/history/system-360>
- Thomas Haigh, "How Charles Bachman Invented the DBMS, a Foundation of Our Digital World", _Communications of the ACM_, Vol.59, No.7, pp.21-23, July 2016. <https://cacm.acm.org/opinion/how-charles-bachman-invented-the-dbms-a-foundation-of-our-digital-world/>
- Charles W. Bachman, "The Origin of the Integrated Data Store (IDS): The First Direct-Access DBMS", _IEEE Annals of the History of Computing_, 2009年. <https://tschwarz.mscs.mu.edu/Classes/DB23/HW/bachmanIDS.pdf>
- Wikipedia, "ISAM". <https://en.wikipedia.org/wiki/ISAM>
- Wikipedia, "Virtual Storage Access Method". <https://en.wikipedia.org/wiki/Virtual_Storage_Access_Method>
- Wikipedia, "CODASYL". <https://en.wikipedia.org/wiki/CODASYL>
- "Before the Advent of Database Systems", _Database Design_, 2nd Edition. <https://opentextbc.ca/dbdesign01/chapter/chapter-1-before-the-advent-of-database-systems/>
- Perl, "flock - Perldoc Browser". <https://perldoc.perl.org/functions/flock>

---

**次回予告：** 第3回「階層型とネットワーク型——リレーショナル以前の世界」では、NASAアポロ計画の部品管理から生まれたIBM IMS、CODASYLネットワーク型データベース、そしてCharles Bachmanの1973年チューリング賞講演「The Programmer as Navigator」が語った世界を辿る。リレーショナルモデル以前のデータベースは、何を解決し、何に苦しんでいたのか。
