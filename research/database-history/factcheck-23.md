# ファクトチェック記録：第23回「データモデリングの本質——正規化、非正規化、そしてその先」

## 1. Coddの正規化理論（1970-1972年）

- **結論**: Edgar F. Coddは1970年に「A Relational Model of Data for Large Shared Data Banks」をCommunications of the ACM, Vol.13, pp.377-387に発表。1971年に「Further Normalization of the Data Base Relational Model」で第2正規形（2NF）と第3正規形（3NF）を定義した。IBMの内部レポートは1971年8月31日付、書籍版は1972年にPrentice-Hall刊行の『Data Base Systems』に収録
- **一次ソース**: Codd, E.F., "A Relational Model of Data for Large Shared Data Banks", Communications of the ACM, 1970; Codd, E.F., "Further Normalization of the Data Base Relational Model", 1971
- **URL**: <https://dl.acm.org/doi/10.1145/362384.362685>, <https://www.semanticscholar.org/paper/Further-Normalization-of-the-Data-Base-Relational-Codd/7be40103ca2c4114e07bb327bf5f902d5b081808>
- **注意事項**: 1970年論文では第1正規形のみ定義。2NF/3NFは1971年の「Further Normalization」論文で導入
- **記事での表現**: Coddは1970年のリレーショナルモデル論文で第1正規形を定義し、翌1971年の「Further Normalization」論文で第2正規形と第3正規形を追加した

## 2. Boyce-Codd正規形（BCNF、1974年）

- **結論**: Raymond F. BoyceとEdgar F. Coddが1974年に「Recent Investigations in Relational Database Systems」で発表。IFIP Congress, pp.1017-1021。ただしChris Dateは、BCNFと実質同等の定義がIan Heathにより1971年に既に提示されていたと指摘している
- **一次ソース**: Codd, E.F. and Boyce, R.F., "Recent Investigations in Relational Database Systems", IFIP Congress, 1974
- **URL**: <https://en.wikipedia.org/wiki/Boyce%E2%80%93Codd_normal_form>
- **注意事項**: Heath normal formとも呼ばれることがある（Chris Dateの指摘）
- **記事での表現**: 1974年、Boyce-Codd正規形（BCNF）が定義され、3NFでは対処できない特定の異常を排除した

## 3. 第4正規形（4NF、Ronald Fagin、1977年）

- **結論**: Ronald Faginが1977年に「Multivalued Dependencies and a New Normal Form for Relational Databases」で第4正規形を提唱。多値従属性（Multivalued Dependency）という概念を導入し、BCNFの次のレベルの正規化を定義した
- **一次ソース**: Fagin, R., "Multivalued Dependencies and a New Normal Form for Relational Databases", ACM Transactions on Database Systems, 1977
- **URL**: <https://dl.acm.org/doi/10.1145/320557.320571>
- **注意事項**: 関数従属性は多値従属性の特殊ケース
- **記事での表現**: 1977年、Ronald Faginが多値従属性と第4正規形を定義した

## 4. 第5正規形（5NF、Ronald Fagin、1979年）

- **結論**: Ronald Faginが1979年のACM SIGMOD論文「Normal Forms and Relational Database Operators」で射影-結合正規形（PJ/NF）として提唱。結合従属性に基づく正規形で、関係スキーマの正規化において必要な最高レベルとされる
- **一次ソース**: Fagin, R., "Normal Forms and Relational Database Operators", ACM SIGMOD, 1979
- **URL**: <https://en.wikipedia.org/wiki/Fifth_normal_form>
- **注意事項**: PJ/NF（Project-Join Normal Form）とも呼ばれる
- **記事での表現**: 1979年、Faginが第5正規形（射影-結合正規形）を定義し、正規化理論の体系が完成に近づいた

## 5. Peter ChenのERモデル（1976年）

- **結論**: Peter Pin-Shan Chenが1976年にACM Transactions on Database Systems, Vol.1, No.1, pp.9-36に「The Entity-Relationship Model—Toward a Unified View of Data」を発表。当時MITスローン経営大学院の助教授。台湾生まれ、ハーバード大学でPh.D.取得（1973年）。論文の初期版は1975年9月のVLDB国際会議で発表
- **一次ソース**: Chen, P.P., "The Entity-Relationship Model—Toward a Unified View of Data", ACM TODS, 1976
- **URL**: <https://dl.acm.org/doi/10.1145/320434.320440>
- **注意事項**: 5,000以上の被引用数を持つデータベース分野の基礎的文献
- **記事での表現**: 1976年、MITのPeter ChenがER（Entity-Relationship）モデルを提唱し、概念モデリングという新しい分野を切り開いた

## 6. Ralph Kimballのディメンショナルモデリング（1996年）

- **結論**: Ralph Kimballが1996年に『The Data Warehouse Toolkit』初版を出版。スタースキーマ（ファクトテーブルとディメンションテーブル）によるディメンショナルモデリングを体系化。第3版（2013年、Margy Rossとの共著）が最新版。Kimballの手法はボトムアップアプローチで、ビジネス要件からデータマートを構築する
- **一次ソース**: Kimball, R., "The Data Warehouse Toolkit", Wiley, 1996
- **URL**: <https://en.wikipedia.org/wiki/Ralph_Kimball>, <https://www.wiley.com/en-us/The+Data+Warehouse+Toolkit:+The+Definitive+Guide+to+Dimensional+Modeling,+3rd+Edition-p-9781118530801>
- **注意事項**: Kimballのアプローチは非正規化（スタースキーマ）を前提とし、Bill Inmonの正規化アプローチと対立するものとして議論されてきた
- **記事での表現**: 1996年、Ralph Kimballが『The Data Warehouse Toolkit』でディメンショナルモデリングを体系化し、スタースキーマという非正規化設計パターンを分析用途の標準とした

## 7. Bill Inmonのデータウェアハウス（1992年）

- **結論**: Bill Inmonが1992年に『Building the Data Warehouse』をQED Technical Publishing Groupから出版。データウェアハウスを「統合的、主題指向、時系列、非揮発性」のリポジトリとして定義。第3正規形（3NF）による正規化設計を推奨するトップダウンアプローチ。第4版は2005年刊行
- **一次ソース**: Inmon, W.H., "Building the Data Warehouse", QED Technical Publishing Group, 1992
- **URL**: <https://en.wikipedia.org/wiki/Bill_Inmon>
- **注意事項**: 「データウェアハウスの父」と称される。Kimballとの論争は1990年代〜2000年代のデータ業界における最大の議論の一つ
- **記事での表現**: 1992年、Bill Inmonが『Building the Data Warehouse』でデータウェアハウスの概念を確立し、3NFによる正規化設計を分析基盤にも適用する手法を提唱した

## 8. Eric EvansのDDD（2003年）

- **結論**: Eric Evansが2003年に『Domain-Driven Design: Tackling Complexity in the Heart of Software』を出版。境界づけられたコンテキスト（Bounded Context）、集約（Aggregate）、エンティティ、値オブジェクトなどの概念を体系化。DDDはデータモデルをビジネスドメインの構造に合わせて設計する手法
- **一次ソース**: Evans, E., "Domain-Driven Design: Tackling Complexity in the Heart of Software", Addison-Wesley, 2003
- **URL**: <https://en.wikipedia.org/wiki/Domain-driven_design>
- **注意事項**: 「Domain-Driven Design」という用語自体がEvansの造語
- **記事での表現**: 2003年、Eric Evansが『Domain-Driven Design』で境界づけられたコンテキストと集約の概念を提唱し、データモデリングにドメインの境界という視点を持ち込んだ

## 9. Greg Youngのイベントソーシング/CQRS

- **結論**: Greg Youngが2007年にイベントソーシングの定義を定式化し、CQRS（Command Query Responsibility Segregation）という用語を造語した。CQRSはBertrand Meyerの「Command Query Separation（CQS）」原則（1988年、『Object-Oriented Software Construction』）に着想を得ている。2010年のCQRS Documents PDFが主要文献。2016年の講演「A Decade of DDD, CQRS, Event Sourcing」で「CQRSはイベントソーシングへのステッピングストーンだった」と述懐。EventStoreDB（現KurrentDB）をイベントソーシング専用データベースとして開発
- **一次ソース**: Young, G., "CQRS Documents", 2010; Meyer, B., "Object-Oriented Software Construction", Prentice Hall, 1988
- **URL**: <https://cqrs.files.wordpress.com/2010/11/cqrs_documents.pdf>, <https://www.kurrent.io/cqrs-pattern>
- **注意事項**: Martin Fowlerも2005年にEvent Sourcingパターンを記事として公開、2011年にCQRSの解説記事を公開している
- **記事での表現**: Greg Youngは2007年にイベントソーシングの定義を定式化し、CQRSという用語を造語した。読み取りと書き込みのモデルを分離するこのパターンは、データモデリングの根本的な前提を覆すものだった

## 10. マイクロサービスとDatabase per Serviceパターン

- **結論**: マイクロサービスアーキテクチャにおける「Database per Service」パターンは、各サービスが自身のデータベースを所有し、他のサービスのデータベースに直接アクセスしないという原則。Chris Richardson（microservices.ioの創設者、『Microservices Patterns』著者）とSam Newmanが主要な提唱者。DDDの境界づけられたコンテキストに概念的に対応する
- **一次ソース**: Richardson, C., "Microservices Patterns", Manning, 2018; Newman, S., "Building Microservices", O'Reilly, 2015
- **URL**: <https://microservices.io/patterns/data/database-per-service.html>
- **注意事項**: このパターンは非正規化を超えて、データの物理的分散を前提とする
- **記事での表現**: マイクロサービスの「Database per Service」パターンは、DDDの境界づけられたコンテキストをデータベースレベルで実現し、各サービスが自身のデータモデルを完全に所有する

## 11. Martin FowlerのEvent Sourcing記事とCQRS記事

- **結論**: Martin Fowlerが2005年12月12日にEvent Sourcingパターンの記事を公開。2011年7月14日にCQRSの解説記事を公開。CQRSについて「ほとんどのシステムにとってCQRSはリスクのある複雑性を加える」と警告している
- **一次ソース**: Fowler, M., "Event Sourcing", martinfowler.com, 2005; Fowler, M., "CQRS", martinfowler.com, 2011
- **URL**: <https://martinfowler.com/eaaDev/EventSourcing.html>, <https://www.martinfowler.com/bliki/CQRS.html>
- **注意事項**: Fowlerの記事はパターンの普及に大きく貢献したが、本人は過度な適用に慎重な立場
- **記事での表現**: Martin Fowlerは2005年にEvent Sourcingパターンを、2011年にCQRSパターンを記事として体系化し、同時にその過度な適用に警鐘を鳴らした
