# ファクトチェック記録：第4回「Coddの革命——リレーショナルモデルの誕生」

## 1. Edgar F. Coddの生没年・経歴

- **結論**: Edgar Frank "Ted" Codd、1923年8月19日生まれ（イングランド・ドーセット州ポートランド島フォーチュンズウェル）、2003年4月18日没（享年79歳）。オックスフォード大学で数学と化学を学び、第二次世界大戦中はRAFのパイロットとして従軍。1948年にニューヨークに移りIBMに入社。マッカーシズムを嫌い1953年にカナダ・オタワへ移住するも、1957年に元上司との偶然の再会を機に米国に帰国。1961年にIBM奨学金でミシガン大学に入学し、計算機科学の修士号と博士号を取得。1967年（一部ソースでは1968年）にIBM San Jose Research Laboratoryに移る
- **一次ソース**: Britannica, "Edgar Frank Codd"; ACM A.M. Turing Award, "Edgar F. Codd"; IBM History, "Edgar Codd"
- **URL**: <https://www.britannica.com/biography/Edgar-Frank-Codd>, <https://amturing.acm.org/award_winners/codd_1000892.cfm>, <https://www.ibm.com/history/edgar-codd>
- **注意事項**: 生年月日について一部ソースで8月19日と8月23日の記載が分かれる。Britannica・ACMでは19日。Wikipedia冒頭では19日。IBM San Jose着任時期は1967年説（ミシガン大学博士取得後）と1968年説がある
- **記事での表現**: 1923年生まれ、2003年没で記述。着任時期は「1960年代後半」と幅を持たせる

## 2. Coddの1969年IBM内部レポートと1970年の論文

- **結論**: 1969年8月19日にIBM Research Report RJ599として"Derivability, Redundancy, and Consistency of Relations Stored in Large Data Banks"を社内発表。翌1970年6月、改訂版を"A Relational Model of Data for Large Shared Data Banks"としてCommunications of the ACM, Vol.13, No.6, pp.377-387に発表
- **一次ソース**: IBM Research Report RJ599 (1969); Communications of the ACM, Vol.13, No.6 (1970)
- **URL**: <https://dl.acm.org/doi/10.1145/362384.362685>, <https://sigmod.org/publications/dblp/db/labs/ibm/RJ599.html>
- **注意事項**: 1969年の内部レポートが先行しており、1970年の論文はその改訂版。論文の革新性を語る際に1969年の存在にも言及すべき
- **記事での表現**: 「1969年にIBM内部レポートRJ599として初版を発表し、翌1970年にCommunications of the ACMに改訂版が掲載された」

## 3. リレーショナルモデルの核心概念——データの論理的独立性

- **結論**: Coddの論文の主要な主張は、データの物理的な格納方法からアプリケーションプログラムを独立させること。論文冒頭でCoddは「データ型の成長やデータ表現の変更からの独立性」を目標として明示。データを数学的な「リレーション」（n項関係）として定義し、物理構造に依存しない論理的なデータ操作を提唱した
- **一次ソース**: E.F. Codd, "A Relational Model of Data for Large Shared Data Banks", CACM 1970
- **URL**: <https://www.seas.upenn.edu/~zives/03f/cis550/codd.pdf>
- **注意事項**: 論文原文では"data independence"という用語が明確に定義されている
- **記事での表現**: 「Coddはデータの論理的独立性——アプリケーションプログラムがデータの物理的格納方法から独立していること——を中核概念として提唱した」

## 4. 関係代数の基本操作

- **結論**: Coddが定義した関係代数の基本操作は8つ。集合論に基づく4操作（和、交差、差、直積）と、リレーショナルモデル固有の4操作（選択、射影、結合、除算）。これらの操作により、リレーショナルデータに対する任意の問い合わせを表現できることが後に証明された
- **一次ソース**: Wikipedia, "Relational algebra"; E.F. Codd, "Relational Completeness of Data Base Sublanguages" (1972)
- **URL**: <https://en.wikipedia.org/wiki/Relational_algebra>
- **注意事項**: 1970年の原論文では関係代数の完全な定義はなく、1972年の論文"Relational Completeness of Data Base Sublanguages"で形式的に定義・証明された
- **記事での表現**: 「選択、射影、結合、和、差を含む関係代数の基本操作」と記述し、全8操作を網羅する必要は本文の文脈次第

## 5. 関係論理と"Relational Completeness"（1972年）

- **結論**: 1972年、CoddはIBM Research Report RJ987として"Relational Completeness of Data Base Sublanguages"を発表（Courant Computer Science Symposia Series 6に収録）。この論文でリレーショナル演算（関係論理）を形式的に定義し、関係代数との等価性を証明。「関係的完全性（relational completeness）」の概念を導入し、データベース問い合わせ言語の表現力を評価する基準を確立した
- **一次ソース**: E.F. Codd, "Relational Completeness of Data Base Sublanguages", IBM RJ987, 1972
- **URL**: <https://www.inf.unibz.it/~franconi/teaching/2006/kbdb/Codd72a.pdf>
- **注意事項**: この論文でCoddの削減アルゴリズム（Codd's reduction algorithm）も提示された
- **記事での表現**: 「1972年の論文で関係代数と関係論理の等価性を証明し、問い合わせ言語の表現力を測る『関係的完全性』の基準を確立した」

## 6. 正規化理論の発展

- **結論**: 1NF（第一正規形）は1970年の原論文で定義。2NFと3NFは1971年の論文"Further Normalization of the Data Base Relational Model"（IBM Research Report RJ909）で定義。BCNF（Boyce-Codd正規形）は1974年にRaymond F. BoyceとCoddが定義。4NF（第四正規形）は1977年にRonald Faginが導入、5NF（第五正規形）は1979年にFaginが導入
- **一次ソース**: Codd (1970), Codd (1971) IBM RJ909, Codd & Boyce (1974), Fagin (1977, 1979)
- **URL**: <https://en.wikipedia.org/wiki/Database_normalization>, <https://en.wikipedia.org/wiki/Boyce%E2%80%93Codd_normal_form>
- **注意事項**: 正規化の目的はCodd自身の言葉で「挿入、更新、削除における望ましくない依存関係からリレーションの集合を解放すること」と述べられている
- **記事での表現**: 年号と著者を正確に記述。正規化の目的は「更新異常の排除」として説明

## 7. IBMの内部抵抗——IMSチームとの対立

- **結論**: IBMはIMS（階層型データベース）を主力製品として推進しており、Coddのリレーショナルモデルの実用化に消極的だった。IBMはIMSを唯一の戦略的製品と宣言し、Coddの研究は会社の方針に反するとして批判された。組織的にもIBM San Jose Research Laboratory（主にディスクストレージの研究拠点）からの重要なソフトウェアイノベーションは前例がなかった。Codd自身はSystem Rプロジェクトのチームメンバーではなかった。Coddが顧客にリレーショナルモデルの可能性を直接見せ、顧客からIBMへの圧力が生まれたことが商用化を後押しした
- **一次ソース**: National Academies Press, "Funding a Revolution" Chapter 6; The Register, "Codd almighty! How IBM cracked System R" (2013); IBM History, "The relational database"
- **URL**: <https://www.nationalacademies.org/read/6323/chapter/8>, <https://www.theregister.com/2013/11/20/ibm_system_r_making_relational_really_real/>, <https://www.ibm.com/history/relational-database>
- **注意事項**: IBM内部の政治的対立は複数のソースで一致して報告されている
- **記事での表現**: 「IBMはIMS収益を守るために、Coddのリレーショナルモデルの商用化を当初拒否した」

## 8. Coddの12の規則（1985年）

- **結論**: 1985年10月14日と10月21日の2回にわたり、Computerworld誌に"Is your DBMS really relational?"と"Does your DBMS run by the rules?"として発表。実際には0番から12番まで13の規則。ベンダーが非リレーショナルシステムを「リレーショナル」と偽ってマーケティングすることへの批判が動機
- **一次ソース**: E.F. Codd, "Is your DBMS really relational?", Computerworld, Oct 14, 1985; "Does your DBMS run by the rules?", Computerworld, Oct 21, 1985
- **URL**: <https://en.wikipedia.org/wiki/Codd%27s_12_rules>, <https://www.computerworld.com/article/1381158/codd-s-12-rules.html>
- **注意事項**: ブループリントでは「Coddの12の規則（1985年）」と記載。実際は13規則（0番を含む）である点に注意
- **記事での表現**: 「1985年にComputerworld誌で発表した13の規則（0番から12番）」

## 9. チューリング賞（1981年）

- **結論**: 1981年ACMチューリング賞をEdgar F. Coddに授与。授賞式は1981年11月9日、ロサンゼルスのACM年次大会にてACM会長Peter Denningから授与。受賞理由は「データベース管理システムの理論と実践への基本的かつ継続的な貢献」
- **一次ソース**: ACM A.M. Turing Award, "Edgar F. Codd"
- **URL**: <https://amturing.acm.org/award_winners/codd_1000892.cfm>
- **注意事項**: なし
- **記事での表現**: 「1981年、リレーショナルモデルの理論的・実践的貢献が認められ、ACMチューリング賞を受賞した」

## 10. System RとSEQUEL/SQLの誕生

- **結論**: 1973年にIBM San Jose Research LaboratoryでSystem Rプロジェクトが発足。Donald ChamberlinとRaymond Boyceが1974年にSEQUEL（Structured English Query Language）を開発。Phase 0（1974-1975年）、Phase 1（1976-1977年）、Phase 2（1978-1979年）の3フェーズ。SEQUELは英国Hawker Siddeley Dynamics Engineering Limitedの商標問題によりSQLに改名。Patricia Selinger がコストベースオプティマイザを開発。System Rの成果はSQL/DS（1981年）、DB2（1983年）として商用化
- **一次ソース**: IBM History, "The relational database"; Donald Chamberlin & Raymond Boyce, "SEQUEL: A Structured English Query Language" (1974)
- **URL**: <https://www.ibm.com/history/relational-database>, <https://s3.us.cloud-object-storage.appdomain.cloud/res-files/2705-sequel-1974.pdf>
- **注意事項**: System Rの開発にCodd自身は参加していない点は重要。ChamberlinとBoyceの最初の試みはSQUARE（Specifying Queries in A Relational Environment）だったが、上付き/下付き文字表記が使いにくく、SEQUELに発展
- **記事での表現**: 本回では詳細に扱わず（第5回のテーマ）、System Rの存在とIBM内部の二重構造（IMS vs リレーショナル）の文脈で言及

## 11. Ingresプロジェクト（UC Berkeley）

- **結論**: 1974年、UC BerkeleyのMichael StonebrakerとEugene Wongが率いるINGRES（Interactive Graphics and Retrieval System）プロジェクトが始動。IBM System Rとほぼ同時期に、リレーショナルモデルの実装可能性を実証。StonebrakerはINGRESの後にPostgresプロジェクト（1986年〜）を率い、これが後のPostgreSQLの源流となる。Stonebrakerは2014年チューリング賞を受賞
- **一次ソース**: UC Berkeley EECS, "INGRES- A Relational Data Base System"; ACM Turing Award, "Michael Stonebraker"
- **URL**: <https://www2.eecs.berkeley.edu/Pubs/TechRpts/1974/28785.html>, <https://amturing.acm.org/award_winners/stonebraker_1172121.cfm>
- **注意事項**: Ingresが後のPostgreSQLの間接的な源流である点は、この連載の後の回との接続に重要
- **記事での表現**: System Rとの対比でIngresにも言及。「学術界からの実装実証」として位置づけ
