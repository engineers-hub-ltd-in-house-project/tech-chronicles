# ファクトチェック記録：第5回「SQLの誕生——データベースに『言葉』が生まれた日」

## 1. SEQUEL（Structured English Query Language）の誕生と1974年の論文

- **結論**: 1974年、IBMのDonald D. ChamberlinとRaymond F. Boyceが、1974 ACM SIGFIDET（現SIGMOD）ワークショップ（ミシガン州アナーバー）にて"SEQUEL: A Structured English Query Language"を発表。論文はProceedings pp.249-264に収録。SEQUELはEdgar F. Coddのリレーショナルモデルを実装するための問い合わせ言語として設計された。SEQUELは束縛変数や量化子を使わずに、一階述語論理と同等の表現力を持つ操作を定義した
- **一次ソース**: Donald D. Chamberlin, Raymond F. Boyce, "SEQUEL: A Structured English Query Language", Proceedings of the 1974 ACM SIGFIDET Workshop on Data Description, Access and Control, 1974
- **URL**: <https://dl.acm.org/doi/10.1145/800296.811515>, <https://s3.us.cloud-object-storage.appdomain.cloud/res-files/2705-sequel-1974.pdf>
- **注意事項**: 1974年のSIGFIDETワークショップはCoddとBachmanの両者が参加し、リレーショナルモデルとネットワーク型モデルの比較討論が行われた重要な場でもあった
- **記事での表現**: 「1974年6月、ミシガン州アナーバーで開催されたACM SIGFIDETワークショップにて発表された」

## 2. SQUARE——SEQUELの前身

- **結論**: ChamberlinとBoyceの最初のリレーショナル言語はSQUARE（Specifying Queries As Relational Expressions）。1975年にCACM Vol.18, No.11に論文"Specifying Queries as Relational Expressions: The SQUARE Data Sublanguage"として発表（著者: Boyce, Chamberlin, King）。SQUAREは集合指向のデータ副言語で関係的完全性を持っていたが、上付き・下付き文字を使う数学的表記が扱いにくく、SEQUELへと発展した
- **一次ソース**: R.F. Boyce, D.D. Chamberlin, W.F. King, "Specifying Queries as Relational Expressions: The SQUARE Data Sublanguage", CACM 18(11), November 1975
- **URL**: <https://dl.acm.org/doi/10.1145/361219.361221>
- **注意事項**: SQUAREの論文は1975年出版だが、研究自体は1974年のSEQUEL発表以前に行われていた
- **記事での表現**: 「ChamberlinとBoyceの最初の試みはSQUARE（Specifying Queries As Relational Expressions）だった。関係的に完全な言語だったが、数学的な上付き・下付き文字表記が実用上の壁となり、英語風の構文を採用したSEQUELへと発展した」

## 3. SEQUELからSQLへの改名（商標問題）

- **結論**: SEQUELの名称は、イギリスのHawker Siddeley Dynamics Engineering Limited社が保有する商標と衝突したため、母音を削除して"SQL"に改名された。IBMは1977年頃にSQLへの改名を行った（一部ソースでは1980年）。正式な発音は「エス・キュー・エル」だが、共同開発者のChamberlin自身を含め多くの英語話者が「シークェル」と発音する
- **一次ソース**: Wikipedia, "SQL"; Donald Chamberlin, "50 Years of Queries", CACM 2024
- **URL**: <https://en.wikipedia.org/wiki/SQL>, <https://cacm.acm.org/research/50-years-of-queries/>
- **注意事項**: 改名の正確な時期についてはソース間で1977年説と1980年説がある。SEQUEL 2の論文（1976年）時点ではまだSEQUELの名称を使用しており、System R Phase 1（1976-1977年）の期間にSQLに改名されたとする説が有力
- **記事での表現**: 「イギリスの航空機メーカーHawker Siddeley社が保有する商標との衝突により、SEQUELからSQLへと改名を余儀なくされた」

## 4. Raymond F. Boyceの早世

- **結論**: Raymond F. Boyce（1946年-1974年6月16日）。Purdue大学で計算機科学の博士号を1972年に取得。IBM Yorktown Heights研究所を経てSan Jose研究所に移り、SEQUELの共同開発およびBoyce-Codd正規形（BCNF）の共同定義に貢献。1974年6月16日、27歳でくも膜下出血（脳動脈瘤破裂）により急逝。妻Sandyと生後10ヶ月の娘Kristinを残した
- **一次ソース**: Wikipedia, "Raymond F. Boyce"; The 1995 SQL Reunion transcript
- **URL**: <https://en.wikipedia.org/wiki/Raymond_F._Boyce>, <https://www.mcjones.org/System_R/SQL_Reunion_95/sqlr95-Ray.html>
- **注意事項**: BoyceはSEQUELの発表と同年の1974年に亡くなっている。SEQUELのその後の発展を見届けることなく逝去した
- **記事での表現**: 「1974年6月、SEQUEL論文の発表とほぼ同時期に、Boyceはくも膜下出血のため27歳で急逝した。SQLの世界的普及を、その共同発明者は見届けることなく世を去った」

## 5. Donald D. Chamberlinの経歴

- **結論**: Donald Chamberlin、1944年カリフォルニア州サンノゼ生まれ。Harvey Mudd College（1966年BS）、Stanford大学（1967年MS、1971年PhD、電気工学）。1971年にIBM T.J. Watson Research Center（ニューヨーク州ヨークタウンハイツ）入社。1973年にSan Jose（後のAlmaden）研究所に移動。System Rプロジェクトのマネージャーの一人。2003年にIBM Fellow。2009年退職。2024年にCACMに"50 Years of Queries"を発表
- **一次ソース**: Wikipedia, "Donald D. Chamberlin"; Computer History Museum, "Donald Chamberlin"
- **URL**: <https://en.wikipedia.org/wiki/Donald_D._Chamberlin>, <https://computerhistory.org/profile/donald-chamberlin/>
- **注意事項**: ChamberlinはSQL以降もXQuery（XML問い合わせ言語）の開発にも貢献
- **記事での表現**: 「ChamberlinはStanford大学で電気工学の博士号を取得後、1971年にIBMに入社した」

## 6. System R プロジェクト（1974-1979年）の3フェーズ

- **結論**: IBM San Jose Research LaboratoryでのSystem Rプロジェクトは3段階で進行。Phase 0（1974-1975年）: XRMストレージマネージャ上のシングルユーザープロトタイプ。SEQUELのサブセットを実装、JOINや並行制御なし。Phase 1（1976-1977年）: マルチユーザー対応のフルシステム構築。RSS（Relational Storage System）とRDS（Relational Data System）の2層アーキテクチャ。B-Treeインデックス、ロック機構、リカバリ機能。1977年6月にPratt & Whitneyで初の顧客インストール。Phase 2（1978-1979年）: フィールドテストと性能評価。3つの外部顧客サイトでの実験運用
- **一次ソース**: Donald D. Chamberlin, "A History and Evaluation of System R", CACM; IBM History, "The relational database"
- **URL**: <https://people.eecs.berkeley.edu/~brewer/cs262/SystemR.pdf>, <https://www.ibm.com/history/relational-database>
- **注意事項**: Phase 0でのSEQUEL→SEQUEL 2→SQLの言語進化もこの間に起きている
- **記事での表現**: 「System Rは1974年から1979年にかけて3段階で開発された」

## 7. Patricia Selingerとコストベースクエリオプティマイザ

- **結論**: Patricia Selinger（旧姓Griffiths）はSystem Rチームの主要メンバー。1979年のACM SIGMOD論文"Access Path Selection in a Relational Database Management System"（共著: Astrahan, Chamberlin, Lorie, Price）でコストベースのクエリ最適化手法を発表。動的計画法を用いたJOIN順序決定アルゴリズムは、現在のほぼすべてのRDBMSのクエリオプティマイザの基盤となっている
- **一次ソース**: P. Griffiths Selinger et al., "Access Path Selection in a Relational Database Management System", ACM SIGMOD 1979, pp.23-34
- **URL**: <https://en.wikipedia.org/wiki/Patricia_Selinger>, <https://www.ibm.com/history/patricia-selinger>
- **注意事項**: SelingerはIBMで初の女性Fellow候補の一人でもあった
- **記事での表現**: 「Patricia Selingerが1979年に発表したコストベースのクエリ最適化は、SQLの宣言的性質を実用化する決定的な技術だった」

## 8. SQL標準化の歴史

- **結論**: SQL-86（1986年）: ANSIが初めて標準化、ISO 9075として1987年にISO化。SQL-89: 小規模改訂、PRIMARY KEY, FOREIGN KEY, DEFAULT, CHECK制約を追加。SQL-92: 大規模改訂、約600ページ。「SQL 2」とも呼ばれる。SQL:1999（SQL3）: オブジェクトリレーショナル機能、再帰CTE、トリガー、正規表現。2,000ページ超。SQL:2003: ウィンドウ関数、XML対応、MERGE文、自動生成列。SQL:2006: XML拡張。SQL:2008: TRUNCATE、INSTEAD OFトリガー。SQL:2011: テンポラルデータベース。SQL:2016: JSON対応、行パターン認識。SQL:2023（第9版）: プロパティグラフクエリ（SQL/PGQ, Part 16）、JSON型追加、GREATEST/LEAST関数など
- **一次ソース**: Wikipedia, "SQL"; Wikipedia, "ISO/IEC 9075"; LearnSQL.com, "History of SQL Standards"; ANSI Blog, "The SQL Standard"
- **URL**: <https://en.wikipedia.org/wiki/SQL>, <https://learnsql.com/blog/history-of-sql-standards/>, <https://blog.ansi.org/ansi/sql-standard-iso-iec-9075-2023-ansi-x3-135/>
- **注意事項**: SQL:1999以降、標準の規模が膨大化（2,000ページ超）し、一般ユーザーがアクセスしにくくなった
- **記事での表現**: 年号ごとに主要な追加機能を明記

## 9. SQLの宣言的性質——「何を」と「どう」の分離

- **結論**: SQLは宣言型言語として設計された。ユーザーは「何が欲しいか（WHAT）」を記述し、「どう取得するか（HOW）」はDBMSのクエリオプティマイザに委ねる。この設計はCoddの論文で提唱された「データの論理的独立性」の直接的な実現である。SEQUELの設計においてChamberlinとBoyceは、一階述語論理の量化子や束縛変数を使わず、英語風のキーワードテンプレートでリレーショナルデータベースへの問い合わせを表現する方針を採用した
- **一次ソース**: 1974年SEQUEL論文; SQL Wikipedia
- **URL**: <https://dl.acm.org/doi/10.1145/800296.811515>, <https://en.wikipedia.org/wiki/SQL>
- **注意事項**: SQLの宣言的性質は「純粋な宣言型」と言い切れない側面もある（ORDER BY、GROUP BYなどは手続き的要素を含む）。ただし本質的設計思想として宣言性を強調するのは妥当
- **記事での表現**: 「SEQUELの革新性は、数学的記法を英語風の構文に翻訳し、『何がほしいか』を宣言するだけでデータを取得できるようにした点にある」

## 10. SQL DDL/DML/DCLの分離

- **結論**: SQLはデータ定義言語（DDL: CREATE, ALTER, DROP）、データ操作言語（DML: SELECT, INSERT, UPDATE, DELETE）、データ制御言語（DCL: GRANT, REVOKE）に大別される。この分離はSEQUEL/SQL初期から段階的に確立された。SEQUEL 2（1976年）でINSERT, DELETE, UPDATE、ビュー定義、整合性制約、トリガーが追加された
- **一次ソース**: SEQUEL 2 paper (1976); SQL Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/SQL>
- **注意事項**: 最初のSEQUEL論文（1974年）はDML（問い合わせ）が中心で、DDLやDCLの完全な定義は後の拡張による
- **記事での表現**: 「SQLはデータの定義（DDL）、操作（DML）、制御（DCL）を一つの言語体系の中で統合した」

## 11. QUELとの競合——なぜSQLが勝ったか

- **結論**: UC Berkeley INGRESプロジェクトのQUEL（Query Language）はタプル関係論理に基づく問い合わせ言語。多くの関係代数の専門家はQUELの方が理論的に優れていると評価していた。しかし1986年のANSI標準でSQLが採択されたことが決定的な転換点となり、INGRESもQUELからSQLへの移行を余儀なくされた（Ingres version 6で対応、約3年を要した）。SQLの勝因は、商用化が先行したこと（Oracle, SQL/DS, DB2）と、ANSI標準化という「お墨付き」を得たこと
- **一次ソース**: Wikipedia, "QUEL query languages"; Wikipedia, "Ingres (database)"; Holistics Blog, "A Short Story About SQL's Biggest Rival"
- **URL**: <https://en.wikipedia.org/wiki/QUEL_query_languages>, <https://www.holistics.io/blog/quel-vs-sql/>
- **注意事項**: QUELとSQLの技術的優劣は今でも議論がある。Stonebraker自身はQUELの方が「作りやすい」と述べている
- **記事での表現**: 「QUELは技術的に洗練されていたが、SQLが商用化と標準化で先行したことが勝敗を決した」

## 12. NULLの三値論理——SQLの設計上のトレードオフ

- **結論**: SQLは二値論理（TRUE/FALSE）ではなく三値論理（TRUE/FALSE/UNKNOWN）を採用。NULLとの比較はUNKNOWNを返し、WHERE句ではUNKNOWNの行は結果に含まれない。C.J. DateとHugh Darwenは『The Third Manifesto』でNULLの存在自体がリレーショナルモデルの原則に反すると主張。Codd自身も1990年の『The Relational Model for Database Management: Version 2』で、SQLのNULL実装は不十分とし、2種類のNull（"Missing but Applicable"のA-valuesと"Missing but Inapplicable"のI-values）に分けるべきと提案した
- **一次ソース**: Wikipedia, "Null (SQL)"; C.J. Date, Hugh Darwen, "The Third Manifesto"
- **URL**: <https://en.wikipedia.org/wiki/Null_(SQL)>
- **注意事項**: NULLの問題は50年経っても解決されておらず、SQLの「原罪」とも言える設計判断である
- **記事での表現**: 「NULLと三値論理は、SQLの設計における最も議論の多いトレードオフの一つであり続けている」
