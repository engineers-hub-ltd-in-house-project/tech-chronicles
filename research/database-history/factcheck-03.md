# ファクトチェック記録：第3回「階層型とネットワーク型——リレーショナル以前の世界」

## 1. IBM IMS の起源とアポロ計画

- **結論**: 1965年、North American Aviation（後のNorth American Rockwell）がアポロ宇宙船の製造契約を獲得し、部品表（BOM）管理のためにIBMと提携。1966年にIBM 12名、North American Rockwell 10名、Caterpillar Tractor 3名の合同チームがICS/DL/I（Information Control System and Data Language/Interface）の設計・開発を開始した
- **一次ソース**: IBM, "History of IMS: Beginnings at NASA"; InformIT, "IBM Information Management System: From Apollo to Enterprise"
- **URL**: <https://www.ibm.com/docs/en/zos-basic-skills?topic=now-history-ims-beginnings-nasa>, <https://www.informit.com/articles/article.aspx?p=1805466>
- **注意事項**: 「200万部品」という数字はブループリントの表現だが、実際には「millions of parts」とされており正確な数字は一次ソースで確認できず。「数百万点の部品」と表現すべき
- **記事での表現**: 「アポロ宇宙船の数百万点に及ぶ部品の部品表（BOM）を管理するため、IBMとNorth American Aviationは1965年に提携した」

## 2. ICS/IMS のリリース時期

- **結論**: IBMチームは1967年にICSの最初のリリースを完成・出荷。1968年4月にICSが設置され、1968年8月14日にカリフォルニア州ダウニーのRockwell Space DivisionのIBM 2740端末に最初の「READY」メッセージが表示された。1969年にIMS/360として商用リリースされた
- **一次ソース**: IBM, "Information Management Systems"; InformIT, "History of IMS: Beginnings at NASA"
- **URL**: <https://www.ibm.com/history/information-management-system>, <https://www.informit.com/articles/article.aspx?p=377307>
- **注意事項**: ブループリントに「IMS（1966年）」とあるが、開発開始が1966年であり、最初の出荷は1967年、設置は1968年、商用リリースは1969年。記事では正確な時系列を記述する
- **記事での表現**: 「1966年に開発が始まり、1968年に最初のインストールが完了、1969年にIMS/360として商用化された」

## 3. Charles Bachman の1973年チューリング賞

- **結論**: Charles W. Bachmanは1973年にACMチューリング賞を受賞（第8回受賞者）。受賞講演「The Programmer as Navigator」はCommunications of the ACM vol.16, no.11, November 1973に掲載された。講演ではコペルニクスの地動説への転換になぞらえ、データベース中心のコンピューティング世界を提唱した
- **一次ソース**: ACM A.M. Turing Award, "Charles W Bachman"; Bachman, "The Programmer as Navigator", Communications of the ACM, 1973
- **URL**: <https://amturing.acm.org/award_winners/bachman_9385610.cfm>, <https://people.csail.mit.edu/tdanford/6830papers/bachman-programmer-as-navigator.pdf>
- **注意事項**: 第2回で既にBachmanとIDS、チューリング賞について言及済み。第3回では講演内容「ナビゲーション」の概念をより詳しく掘り下げる
- **記事での表現**: 「Bachmanの受賞講演『The Programmer as Navigator』は、コペルニクスの地動説になぞらえて、データの周りをプログラムが航行する新しいパラダイムを宣言した」

## 4. CODASYL DBTG の仕様策定

- **結論**: CODASYLは1965年にList Processing Task Forceを設立。1967年にData Base Task Group（DBTG）に改名。1969年10月に最初の言語仕様を公開。1971年4月にDBTGレポート（DDL、サブスキーマDDL、DML仕様）を正式公開した。DBTGの議長はRCAのWilliam Olleだった
- **一次ソース**: Wikipedia, "Data Base Task Group"; Wikipedia, "CODASYL"; CODASYL DBTG Report, April 1971
- **URL**: <https://en.wikipedia.org/wiki/Data_Base_Task_Group>, <https://en.wikipedia.org/wiki/CODASYL>
- **注意事項**: ブループリントに「CODASYL（1969年）とネットワーク型データベース」とあるのは最初の仕様公開年として正確。正式なDBTGレポートは1971年4月
- **記事での表現**: 「1969年にCODASYL DBTGが最初のネットワーク型データベース仕様を公開し、1971年4月の正式レポートで業界標準となった」

## 5. ネットワーク型データベースの構造（セット、オーナー、メンバー）

- **結論**: CODASYLネットワークモデルの基本構造は「セット」で、1つのオーナーレコードタイプと1つ以上のメンバーレコードタイプからなる。セットはポインタベースのリンクで物理的に接続される。メンバーレコードタイプは複数のセットに属することができ、多対多の関係を表現可能
- **一次ソース**: Oxford Reference, "CODASYL network model"; db-book.com, "Appendix D Network Model"
- **URL**: <https://www.oxfordreference.com/display/10.1093/oi/authority.20110803095621304>, <https://www.db-book.com/db6/appendices-dir/d.pdf>
- **注意事項**: セットの物理実装はポインタチェインだが、論理的には1:Nの関係を表現する。多対多はメンバーが複数セットに属することで実現
- **記事での表現**: セットの概念図をASCIIアートで描き、オーナー・メンバー関係とポインタチェインを視覚的に説明する

## 6. IMS の階層型データモデル（セグメント、DL/I）

- **結論**: IMSの階層型モデルはセグメントを基本単位とし、親子関係のツリー構造で表現される。各親セグメントは0以上の子セグメントを持ち、各子セグメントは1つの親のみを持つ。1つのデータベースに最大255種のセグメントタイプ、最大15レベルの階層を持てる。DL/Iの主要コマンドはGU（Get Unique）、GN（Get Next）、GNP（Get Next within Parent）
- **一次ソース**: IBM IMS Documentation; mainframestechhelp.com, "IMS DB Hierarchical Database Structure"
- **URL**: <https://ecl.informationbuilders.com/focus/topic/shell_76/adapter/ims/02UM2.htm>, <https://www.mainframestechhelp.com/tutorials/imsdb/hierarchical-database-structure.htm>
- **注意事項**: DL/Iの「ナビゲーション型」アクセスの特徴を具体的なコマンド例で示す
- **記事での表現**: GU/GN/GNPコマンドの具体例を示し、「木を辿る」データアクセスの制約を説明する

## 7. IDMS の商用化とCullinet

- **結論**: IDMSはB.F. Goodrichで開発され、John CullinaneがCullinane Database Systems（1983年にCullinetに改名）として商用化した。1978年に株式公開、1982年4月27日にニューヨーク証券取引所に上場した最初のコンピュータソフトウェア企業となり、S&P 500にも採用された。1989年以降Computer Associates（現CA Technologies）が所有
- **一次ソース**: Wikipedia, "IDMS"; Wikipedia, "Cullinet"
- **URL**: <https://en.wikipedia.org/wiki/IDMS>, <https://en.wikipedia.org/wiki/Cullinet>
- **注意事項**: CODASYL系DBMSの商業的成功を示す具体例として使用
- **記事での表現**: 「CODASYLネットワーク型データベースの商業的代表であるIDMSを販売したCullinane Database Systemsは、1982年にNYSE上場を果たした最初のソフトウェア企業となった」

## 8. Coddの批判——データ独立性の欠如

- **結論**: Coddの1970年の論文「A Relational Model of Data for Large Shared Data Banks」は、階層型・ネットワーク型モデルの根本問題としてデータ独立性の欠如を指摘した。「アプリケーションプログラムとデータ型の成長やデータ表現の変更からの独立性」を追求した。IBMは自社のIMS収益を守るため、当初リレーショナルモデルの実装を拒否した
- **一次ソース**: Two-Bit History, "Important Papers: Codd and the Relational Model"; Codd, "A Relational Model of Data for Large Shared Data Banks", Communications of the ACM, 1970
- **URL**: <https://twobithistory.org/2017/12/29/codd-relational-model.html>, <https://dl.acm.org/doi/10.1145/362384.362685>
- **注意事項**: IBMの内部抵抗は第4回で詳しく扱う。第3回では「物理構造への依存」の問題提起に留める
- **記事での表現**: 「階層型・ネットワーク型モデルの本質的限界は、Coddが『データ独立性』と呼んだ概念の欠如にあった」

## 9. IMS の現在の使用状況

- **結論**: 2025年現在、Fortune 1000企業の95%以上がIMSを何らかの形で使用。米国上位5銀行すべてがIMSを利用。約2,000の顧客が継続利用。ドイツのAtruvia AGはIMSで年間800億件のコアバンキングトランザクションを処理（ピーク時毎秒12,000件）。IMS Version 13は単一システムで毎秒10万トランザクションの処理能力を実証
- **一次ソース**: TechTarget, "What is IBM IMS"; IBM, "IMS Product Page"; Planet Mainframe, 2022
- **URL**: <https://www.techtarget.com/searchdatacenter/definition/IMS-Information-Management-System>, <https://www.ibm.com/products/ims>
- **注意事項**: 「未だに使われている」というトーンではなく、「50年以上にわたりミッションクリティカルな環境で稼働し続けている」と敬意を持って記述する
- **記事での表現**: 「2025年現在、IMSはFortune 1000企業の95%以上で稼働し続けている。階層型データベースは『過去の遺物』ではない」

## 10. 階層型モデルの構造的制約

- **結論**: 階層型モデルでは各子ノードは1つの親のみを持つ。多対多の関係や複数の親を持つ関係は直接表現できず、データの重複が必要になる。挿入・削除異常が発生する。物理構造とプログラムが密結合しており、構造変更時にプログラムの修正が必要
- **一次ソース**: Wikipedia, "Hierarchical database model"; GeeksforGeeks, "Difference Between Hierarchical, Network and Relational Data Model"
- **URL**: <https://en.wikipedia.org/wiki/Hierarchical_database_model>, <https://www.geeksforgeeks.org/dbms/difference-between-hierarchical-network-and-relational-data-model/>
- **注意事項**: 具体例（学生の履修登録など）で多対多の制約を説明する
- **記事での表現**: ツリー構造の図解を使い、「学生と講義の多対多関係」を階層型で表現しようとすると重複が生じる例を示す
