# ファクトチェック記録：第10回「インデックス設計——データベースの『速さ』の正体」

## 1. B-Treeの発明（1970年、Bayer & McCreight）

- **結論**: B-Treeは1970年にRudolf BayerとEdward M. McCreightがBoeing Scientific Research Laboratoriesで発明した。論文は1970年11月15日にヒューストンで開催されたACM SIGFIDET Workshopで発表され、1972年にActa Informatica 1巻173-189頁として出版された。
- **一次ソース**: Rudolf Bayer, Edward M. McCreight, "Organization and Maintenance of Large Ordered Indexes", Acta Informatica, Vol. 1, pp. 173-189, 1972
- **URL**: <https://link.springer.com/article/10.1007/BF00288683>
- **注意事項**: 論文は1970年7月に最初に回覧され、1970年11月にACM SIGFIDET Workshopで発表、1972年にActa Informaticaに正式出版。「B」が何を意味するかはBayer & McCreightは説明しておらず、Boeing, balanced, between, broad, bushy, Bayerなどが提案されている。実験ではIBM 360/44上で100,000キーのインデックスを毎秒4トランザクション以上で維持可能と実証。
- **記事での表現**: 1970年、Boeing Scientific Research LaboratoriesのRudolf BayerとEdward M. McCreightが「Organization and Maintenance of Large Ordered Indexes」を発表した。

## 2. B+Treeの発展とデータベースへの採用

- **結論**: B+TreeはB-Treeの変種で、キー/値ペアをリーフノードにのみ格納し、リーフノード間を双方向リンクリストで接続する。現代のデータベース（MySQL/InnoDB、PostgreSQL、MongoDB等）はほぼすべてB+Treeを採用している。内部ノードに値を格納しないため、より多くのキーを内部ノードに収容でき、範囲クエリに優れる。
- **一次ソース**: Douglas Comer, "The Ubiquitous B-Tree", ACM Computing Surveys, 1979（B-Tree変種の包括的サーベイ）
- **URL**: <https://en.wikipedia.org/wiki/B%2B_tree>
- **注意事項**: B+Treeの正確な初出論文は特定しにくいが、1970年代後半にはデータベースシステムで広く採用されていた。InnoDB（MySQL）ではノードサイズがデフォルト16KBのディスクページに対応。
- **記事での表現**: B+Treeは、リーフノードにのみデータを格納し、リーフ同士をリンクリストで接続した構造だ。この設計が範囲クエリを高速にする。

## 3. ハッシュインデックスの起源

- **結論**: ハッシュの概念は1953年にIBMのHans Peter Luhnが社内メモランダムでチェイニング付きハッシュを記述したことに遡る。データベースにおけるハッシュインデックスは等値検索でO(1)の平均検索時間を提供する。PostgreSQLではバージョン10（2017年）でWALロギングとクラッシュセーフティが完全にサポートされた。
- **一次ソース**: Hans Peter Luhn, IBM internal memorandum, January 1953; Arnold Dumey（最初の公開出版）
- **URL**: <https://en.wikipedia.org/wiki/Hash_table>
- **注意事項**: ハッシュインデックスは等値検索のみ対応で、範囲検索には使えない。PostgreSQLでは長らくハッシュインデックスはWAL未対応でクラッシュセーフでなかったが、v10で改善された。
- **記事での表現**: ハッシュインデックスは等値検索でO(1)の平均検索時間を実現するが、範囲検索には対応できない。

## 4. ビットマップインデックス（Oracle 7.3）

- **結論**: ビットマップインデックスの概念はIsrael SpieglerとRafi Maayanが1985年の研究「Storage and Retrieval Considerations of Binary Data Bases」で提唱した。Oracleはバージョン7.3.4でビットマップインデックスを導入した。データウェアハウス環境で特に有効。
- **一次ソース**: Israel Spiegler, Rafi Maayan, "Storage and Retrieval Considerations of Binary Data Bases", 1985; Oracle 7.3 documentation
- **URL**: <https://www.orafaq.com/wiki/Bitmap_index>
- **注意事項**: ビットマップインデックスはカーディナリティの低い列（性別、ステータス等）に適し、大量のDMLがある環境には不向き。
- **記事での表現**: Oracleは7.3.4でビットマップインデックスを導入した。カーディナリティの低い列に対して、ビットマップ演算による高速な集計を可能にする。

## 5. GiST（Generalized Search Tree、PostgreSQL）

- **結論**: GiSTは1995年にJoseph Hellerstein、Jeffrey Naughton、Avi Pfefferが論文「Generalized Search Trees for Database Systems」で発表した（VLDB 1995、9月11日）。B+Treeの一般化であり、B+-treeやR-treeなど異なる検索木構造を単一のコードベースで統一する。PostgreSQLではO. BartunovとT. Sigaevが大きく貢献して実装された。PostGIS（地理情報システム）のインデックス基盤として利用されている。
- **一次ソース**: Joseph M. Hellerstein, Jeffrey F. Naughton, Avi Pfeffer, "Generalized Search Trees for Database Systems", VLDB 1995
- **URL**: <https://dsf.berkeley.edu/papers/vldb95-gist.pdf>
- **注意事項**: 1997年に並行性と回復に関する続報論文「Concurrency and Recovery in Generalized Search Trees」が発表された。
- **記事での表現**: GiST（Generalized Search Tree）は1995年にHellerstein、Naughton、Pfefferが発表した汎用検索木フレームワークだ。

## 6. GINインデックス（PostgreSQL 8.2）

- **結論**: GIN（Generalized Inverted Index）はPostgreSQL 8.2（2006年頃リリース）で導入された。転置インデックスの一般化であり、複合値（配列、全文検索のtsvector、JSONB等）のインデックスに適している。同じキーが多数出現する場合にコンパクトに格納できる。
- **一次ソース**: PostgreSQL Documentation, "GIN Indexes"
- **URL**: <https://www.postgresql.org/docs/current/gin.html>
- **注意事項**: GINはGiSTと比較して検索は高速だが、構築と更新は遅い傾向がある。
- **記事での表現**: PostgreSQL 8.2（2006年）で導入されたGIN（Generalized Inverted Index）は、全文検索やJSONBクエリのインデックスに使われる。

## 7. BRINインデックス（PostgreSQL 9.5）

- **結論**: BRIN（Block Range Index）はPostgreSQL 9.5（2016年1月7日リリース）で導入された。Alvaro Herrera（2ndQuadrant）が2013年に「Minmax indexes」として提案したのが起源。物理的に隣接するブロック範囲ごとに要約情報を保持する設計で、時系列データなど物理的順序と値の相関がある列に特に有効。
- **一次ソース**: PostgreSQL Documentation, "BRIN Indexes"
- **URL**: <https://www.postgresql.org/docs/current/brin.html>
- **注意事項**: データの物理的順序と値の相関がない列には効果が薄い。
- **記事での表現**: PostgreSQL 9.5（2016年）はBRIN（Block Range Index）を導入した。物理的に隣接するブロック範囲の要約情報だけを保持する、極めて小さなインデックスだ。

## 8. カバリングインデックスとIndex-Only Scan

- **結論**: カバリングインデックスはクエリに必要な全カラムをインデックス内に含むことで、テーブルへのアクセスを不要にする技術。PostgreSQLはバージョン9.2でIndex-Only Scanをサポート、バージョン11（2018年）でCREATE INDEXのINCLUDE句を導入し、インデックス対象外の追加カラムを含められるようになった。MySQLのInnoDBでは、主キーカラムが暗黙的にセカンダリインデックスに含まれるため、カバリングインデックスとして機能しやすい。
- **一次ソース**: PostgreSQL Documentation, "Index-Only Scans and Covering Indexes"
- **URL**: <https://www.postgresql.org/docs/current/indexes-index-only-scans.html>
- **注意事項**: PostgreSQLではVisibility Mapの状態によりテーブルアクセスが必要になる場合がある。実測ではIndex-Only Scanにより約2.25倍のトランザクション/秒の向上が確認されている。
- **記事での表現**: カバリングインデックスは、クエリが必要とするすべてのカラムをインデックス内に含むことで、テーブル本体へのアクセスを完全に回避する。

## 9. コストベースオプティマイザの起源（System R、1979年）

- **結論**: コストベースクエリ最適化の基礎は、1979年のSIGMODで発表されたP. Griffiths Selingerらの論文「Access Path Selection in a Relational Database Management System」に遡る。IBM San Jose Research LaboratoryのSystem Rプロジェクトの一部として開発された。I/O（ページフェッチ）とCPU使用量に基づくコスト予測を行い、最も効率的なアクセスパスを選択する手法を確立した。この論文の原則は、現在のすべての主要データベースシステムのクエリオプティマイザの基盤となっている。
- **一次ソース**: P. Griffiths Selinger, M.M. Astrahan, D.D. Chamberlin, R.A. Lorie, T.G. Price, "Access Path Selection in a Relational Database Management System", SIGMOD 1979
- **URL**: <https://dl.acm.org/doi/10.1145/582095.582099>
- **注意事項**: System Rは実験的RDBMSであり、商用化はされなかったが、その設計思想はDB2やOracle等に大きな影響を与えた。
- **記事での表現**: 1979年、SelingerらがSystem Rのクエリオプティマイザに関する論文を発表した。I/OコストとCPU使用量に基づくコストベース最適化は、現在のすべての主要データベースのオプティマイザの基盤である。

## 10. インデックスの選択性（Selectivity）とカーディナリティ

- **結論**: 選択性（Selectivity）はインデックス内のユニーク値の数と総エントリ数の比率として定義される（Selectivity = Cardinality / Total Rows）。カーディナリティはインデックスがカバーする列内の異なる値の数。選択性が高いほど（ユニーク値が多いほど）インデックスの効果が高い。クエリオプティマイザは選択性を使って、インデックスを使用する価値があるかどうかを判断する。
- **一次ソース**: 各データベースドキュメント（PostgreSQL, MySQL, Oracle）
- **URL**: <https://planetscale.com/learn/courses/mysql-for-developers/indexes/index-selectivity>
- **注意事項**: 選択性の低い列（性別など2-3値）にB-Treeインデックスを作成しても効果は薄い。ビットマップインデックスが適する場合がある。
- **記事での表現**: インデックスの選択性は、カラム内のユニーク値の数を行数で割った比率だ。選択性が高いほどインデックスは効果的に絞り込みを行える。
