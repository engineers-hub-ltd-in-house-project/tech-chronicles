# ファクトチェック記録: 第1回「なぜデータベースの歴史を学ぶのか」

調査日: 2026-02-22

---

## 1. Stack Overflow Developer Survey 2024 データベース利用率

- **結論**: PostgreSQLが49%（プロ開発者48.7%）で2年連続1位。MySQLは40.3%（プロ開発者39.4%）。SQLiteは33.1%。2018年時点ではMySQL 59%、PostgreSQL 33%だった
- **一次ソース**: Stack Overflow, "2024 Stack Overflow Developer Survey", 2024年
- **URL**: <https://survey.stackoverflow.co/2024/technology>
- **注意事項**: 複数回答可の調査。回答者は主にStack Overflowユーザーであり、全開発者の縮図とは限らない
- **記事での表現**: 2024年のStack Overflow Developer Surveyにおいて、PostgreSQLは49%の開発者に使用され、2年連続で最も人気のあるデータベースとなった

## 2. Stack Overflow Developer Survey 2025 データベース利用率

- **結論**: PostgreSQLが55.6%（プロ開発者58.2%）に急伸。前年比約7ポイント増で過去最大の年間伸び。MySQLは40.5%で15ポイント差。SQLite 32%、MongoDB 26%、Redis 22%
- **一次ソース**: Stack Overflow, "2025 Stack Overflow Developer Survey", 2025年
- **URL**: <https://survey.stackoverflow.co/2025/technology>
- **注意事項**: 3年連続でPostgreSQLが全3部門（全体・プロ・学習中以外）で1位
- **記事での表現**: 2025年調査ではPostgreSQLは55.6%に達し、MySQLとの差は15ポイントにまで開いた

## 3. DB-Engines Ranking 2026年2月時点

- **結論**: 1位Oracle（スコア1204）、2位MySQL（868）、3位Microsoft SQL Server（708）、4位PostgreSQL（672）、5位MongoDB（379）。DB-Enginesには498のDBMSが登録され、うち433がランキング対象
- **一次ソース**: DB-Engines, "DB-Engines Ranking"
- **URL**: <https://db-engines.com/en/ranking>
- **注意事項**: DB-EnginesとStack Overflowの順位が異なるのは、評価基準の違いによる。DB-Enginesは求人数・検索エンジン結果・SNS言及等を含む総合指標。Stack Overflowは開発者自身の利用申告
- **記事での表現**: DB-Enginesには498ものデータベース管理システムが登録されている。これはデータベースという技術領域の多様さと広がりを示している

## 4. PostgreSQLの成長トレンド

- **結論**: PostgreSQLは2018年のStack Overflow調査では33%だったが、2025年には55.6%に成長。DB-Enginesスコアも657.17（2025年9月）で前年比12.81ポイント増。DB-Engines DBMS of the Year 2024はSnowflakeが受賞
- **一次ソース**: DB-Engines, "Q1 2025 database industry rankings", 2025年
- **URL**: <https://db-engines.com/en/blog_post/110>
- **注意事項**: PostgreSQLの成長はクラウドDBサービス（RDS、Cloud SQL等）での採用増も影響
- **記事での表現**: PostgreSQLは2018年の33%から2025年には55.6%へと急成長を遂げた

## 5. SQLiteの普及規模

- **結論**: 世界で最も多くデプロイされたデータベース。40億台以上のスマートフォンそれぞれに数百のSQLiteデータベースファイルが存在し、アクティブなSQLiteデータベースは1兆（1e12）を超えると推定される
- **一次ソース**: SQLite公式サイト, "Most Widely Deployed SQL Database Engine"
- **URL**: <https://www.sqlite.org/mostdeployed.html>
- **注意事項**: 「最も広くデプロイされた」と「最も利用されている」は意味が異なる。SQLiteは組み込みDBであり、サーバ型DBとは用途が異なる
- **記事での表現**: SQLiteはすべてのスマートフォンに組み込まれ、アクティブなデータベース数は1兆を超える。世界で最も広く配布されたデータベースエンジンである

## 6. Edgar F. Coddとリレーショナルモデル

- **結論**: 1970年6月、IBM San Jose Research LaboratoryのEdgar F. Coddが"A Relational Model of Data for Large Shared Data Banks"をCommunications of the ACM, Vol.13, No.6, pp.377-387に発表。1981年にACMチューリング賞受賞。2002年にForbes誌が過去85年の最も重要なイノベーションの一つに選出
- **一次ソース**: ACM Digital Library, Communications of the ACM, June 1970
- **URL**: <https://dl.acm.org/doi/10.1145/362384.362685>
- **注意事項**: 内部レポートは1969年に存在（IBM Research Report RJ599）。公式発表は1970年のCACM
- **記事での表現**: 1970年、IBMのEdgar F. Coddが発表した一本の論文が、データベースの世界を永遠に変えた

## 7. ACID特性の起源

- **結論**: ACIDという頭字語は1983年にAndreas ReuterとTheo Haerderが命名。Jim Grayが原子性・一貫性・永続性を先行して特徴づけていたが、分離性（Isolation）は含んでいなかった
- **一次ソース**: Theo Haerder, Andreas Reuter, "Principles of Transaction-Oriented Database Recovery", ACM Computing Surveys, 1983年
- **URL**: <https://en.wikipedia.org/wiki/ACID>
- **注意事項**: Jim Grayは1998年にチューリング賞を受賞
- **記事での表現**: 1983年、Haerder と Reuter がACIDという概念を定式化した

## 8. ORMの普及状況

- **結論**: Python圏ではDjango ORM・SQLAlchemyが主流。Node.js/TypeScript圏ではPrismaが最も人気のあるORM。2025年時点でORMは多くのWebフレームワークに標準搭載されている。具体的な全体採用率の統計データは見つからなかった
- **一次ソース**: 各種技術ブログ・フレームワーク公式ドキュメント
- **URL**: <https://www.nucamp.co/blog/coding-bootcamp-backend-with-python-2025-modern-orm-frameworks-in-2025-django-orm-sqlalchemy-and-beyond>
- **注意事項**: 定量的な「ORM利用率」のサーベイデータは見当たらない。ただしDjango、Rails、Laravel等の主要フレームワークはすべてORM標準搭載であり、事実上の標準と言える
- **記事での表現**: Django、Rails、Laravel、Next.js——現代の主要なWebフレームワークはいずれもORMを標準で備えている。多くの開発者にとって、SQLを直接書く機会は減少している

## 9. ファイルベースデータ管理の並行アクセス問題

- **結論**: ファイルへの並行書き込みでは、適切なロック機構（flock, lockf等）なしにデータ破損・競合状態が発生する。UNIXのアドバイザリロックは協調的機構であり、全プロセスが明示的に参加しなければ機能しない
- **一次ソース**: 各種技術文書・解説記事
- **URL**: <https://apenwarr.ca/log/20101213>
- **注意事項**: ハンズオンでPythonによるファイル並行書き込みの問題を実演する際に参照
- **記事での表現**: ファイルベースのデータ管理では、複数のプロセスが同時に書き込みを行うとデータが破壊される。これはデータベースが解決する根本的な問題の一つである

## 10. データベースの本質的機能（4つの役割）

- **結論**: データベースの根本的な役割は(1)データの永続化、(2)データの整合性保証、(3)効率的な検索、(4)並行アクセスの制御。これらはDBMSの教科書で広く合意された基本機能
- **一次ソース**: Abraham Silberschatz et al., "Database System Concepts" (教科書の定番)
- **URL**: なし（書籍）
- **注意事項**: 各教科書で表現は異なるが、本質は共通している
- **記事での表現**: データベースが解決する問題は4つに集約される——永続化、整合性、検索、並行制御。この4つの課題を自前で解こうとしたことがある人間は、データベースの価値を身体で理解している
