# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第1回：なぜデータベースの歴史を学ぶのか

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 「PostgreSQL＝空気」になった世界で、私たちが見失っているもの
- データベースが解決する4つの根本問題——永続化、整合性、検索、並行制御
- 2025年のデータベース利用状況と、ORMが覆い隠した「SQLの層」
- テキストファイルとPythonスクリプトだけでデータを管理し、並行アクセスで壊れる瞬間を体験する方法

---

## 1. 「フレームワークのデフォルトだから」

ある日、私は実務経験4年ほどの若いエンジニアに聞いた。

「なぜPostgreSQLを選んだの？」

彼女は少し戸惑った顔をして、こう答えた。「フレームワークのデフォルトだからです」

間違ってはいない。Next.jsのチュートリアルはVercel Postgresを使い、RailsはPostgreSQLを推奨し、Djangoの公式ドキュメントもPostgreSQLを筆頭に挙げる。フレームワークのデフォルトに従うのは合理的な判断だ。

だが、私が気になったのは答えの内容ではない。答え方だ。

彼女にとって、データベースの選択は「考える」ものではなく「受け入れる」ものだった。フレームワークがPostgreSQLを使うのだから、自分もPostgreSQLを使う。ORMがSQLを生成するのだから、自分はSQLを書かない。マイグレーションツールがスキーマを管理するのだから、自分は`CREATE TABLE`の意味を考えない。

これは彼女の責任ではない。2020年代のWeb開発は、データベースを意識しないで済むよう、念入りに設計されている。Prismaは型安全なクエリビルダを提供し、Drizzle ORMはTypeScriptの型推論でスキーマを表現し、Active Recordはテーブル定義とオブジェクト定義を一体化する。開発者がSQLに触れずにアプリケーションを構築できる世界が、すでに実現している。

だが、「触れずに済む」と「知らなくていい」は違う。

私が同じ質問をされたら——「なぜPostgreSQLを選んだのか」——こう答えるだろう。「このプロジェクトはトランザクションの整合性が重要で、JSONBカラムで半構造化データも扱いたく、将来的にpgvectorでセマンティック検索を追加する可能性があるから。MySQLでも技術的には可能だが、PostgreSQLの拡張性がより適している」と。

この答えは、24年分のデータベースとの格闘から出てくる。MySQL 3.xをソースからコンパイルした1990年代後半。phpMyAdminでテーブルを設計し、正規化という言葉すら知らなかった2000年代初頭。MongoDBに飛びつき、スキーマレスの自由に酔い、そして痛い目に遭った2010年代。それらの経験が堆積して、「なぜPostgreSQLか」という問いに答えられる地層を形成している。

彼女にその地層がないのは、当然だ。経験は積み重ねるものであって、転送できるものではない。だが、地層の「読み方」は伝えられる。50年分のデータベースの歴史を辿ることで、なぜリレーショナルモデルが生まれ、何を解決し、何を犠牲にし、そして50年後の今もなお支配的であるのかを理解できる。

この連載は、その地層を読む旅だ。

あなたが今使っているデータベース——PostgreSQLでもMySQLでもDynamoDBでもいい——を選んだ理由は何だろうか。「フレームワークのデフォルトだから」と答えたあなたに、問いたいことがある。そのフレームワークの開発者は、なぜそのデータベースをデフォルトにしたのか。

---

## 2. 数字が語る「データベースの今」

問いの背景を共有するために、まず現在地を確認しよう。2020年代半ばのデータベースの世界は、どのような地形をしているのか。

### PostgreSQLの「空気化」

2025年のStack Overflow Developer Surveyで、PostgreSQLは開発者の55.6%に使用されていると報告された。プロフェッショナル開発者に限れば58.2%に達する。2位のMySQLは40.5%で、その差は15ポイント。3位のSQLite（32%）、4位のMongoDB（26%）、5位のRedis（22%）と続く。

この数字の意味を正しく理解するには、歴史的な推移を見る必要がある。PostgreSQLがStack Overflow調査に登場した2018年、その利用率は33%だった。当時のトップはMySQLで59%。わずか7年でPostgreSQLとMySQLの順位は逆転し、差は開き続けている。

一方、DB-Enginesランキング——検索エンジン結果、求人数、SNS言及等を総合したスコアで測る指標——では、2026年2月時点の上位はOracle（スコア1204）、MySQL（868）、Microsoft SQL Server（708）、PostgreSQL（672）の順だ。ここでPostgreSQLが4位にとどまるのは、OracleやSQL Serverが大企業のレガシーシステムに深く根を下ろしているためだ。「新たに選ばれている」データベースと「依然として稼働している」データベースの間には、大きな乖離がある。

DB-Enginesに登録されているデータベース管理システムの総数は498にのぼる。うち433が現在もランキング対象として存続しており、65が開発終了（discontinued）だ。リレーショナル、ドキュメント、キーバリュー、グラフ、時系列、ベクトル——データベースの種類は増殖を続けている。

### ORMが覆い隠した「SQL層」

数字が語るもう一つの事実は、開発者とデータベースの「距離」の変化だ。

Django、Rails、Laravel、Next.js——現代の主要なWebフレームワークは、いずれもORMを標準で備えている。Pythonの世界ではDjango ORMとSQLAlchemyが支配的であり、TypeScript/JavaScript圏ではPrismaが最も広くダウンロードされているORM（npm基準）だ。Ruby on RailsのActive Record、PHPのEloquent（Laravel）もそれぞれのエコシステムで揺るぎない地位を占めている。

ORMの存在は、開発者にとって圧倒的な生産性の向上をもたらした。型安全なクエリ、自動マイグレーション、リレーション定義の宣言的記述。これらの恩恵は計り知れない。

だが、同時にORMは、データベースの「本質」を覆い隠した。

ORMを通じてデータベースを使う開発者は、`User.objects.filter(age__gte=18)` と書く。このコードの裏で `SELECT * FROM users WHERE age >= 18` というSQLが生成され、データベースのクエリオプティマイザがインデックスの使用を判断し、B+Treeを辿ってディスクI/Oを最小化し、MVCCによって他のトランザクションとの整合性を保証している——そのすべてを、知らなくても「動く」。

動くのだ。問題なく。ほとんどの場合は。

だが「ほとんどの場合」から外れたとき——N+1クエリでアプリケーションが停止したとき、デッドロックでトランザクションがアボートしたとき、100万行のテーブルでフルテーブルスキャンが走ったとき——ORMの抽象化は助けにならない。むしろ障壁になる。ORMが何を隠しているかを知らない開発者は、問題の所在さえ特定できない。

私自身、2000年代後半に大規模MySQL環境でスロークエリと格闘した経験がある。`EXPLAIN ANALYZE` を叩き、インデックスの設計を見直し、クエリの実行計画を一行ずつ読み解く日々だった。あの経験があるから、ORMが生成するSQLを見たとき、「これは遅い」と直感で判断できる。だが、その直感はORMの中にいるだけでは身につかない。

### 世界で最も多くデプロイされたデータベース

もう一つ、意外な数字を紹介しよう。

世界で最も多くデプロイされたデータベースはPostgreSQLではない。MySQLでもない。SQLiteだ。

SQLiteの公式サイトによれば、アクティブなSQLiteデータベースは1兆（10の12乗）を超える。40億台以上のスマートフォンそれぞれに数百のSQLiteデータベースファイルが含まれており、Webブラウザ、メッセージングアプリ、写真管理アプリ——日常的に使うあらゆるアプリケーションの裏側でSQLiteが稼働している。Adobe Photoshop LightroomもSQLiteを使い、Apple のmacOS/iOSの多くのネイティブアプリケーションもSQLiteに依存している。米国議会図書館が長期保存に推奨するデータフォーマットの一つにもSQLiteが選ばれている。

SQLiteは「サーバ」を持たない。ファイルが一つあるだけだ。`libsqlite3` というCライブラリがアプリケーションに組み込まれ、そのプロセス内でSQLの解析と実行を行う。にもかかわらず、ACIDトランザクションを完全にサポートし、SQLの大部分を実装している。

PostgreSQLが「開発者が選ぶデータベース」なら、SQLiteは「あらゆるソフトウェアに組み込まれたデータベース」だ。そしてSQLiteの存在は、「データベースとは何か」という問いを根本から揺さぶる。サーバもネットワークもない。あるのはファイルとライブラリだけだ。それでもSQLiteがデータベースと呼ばれるのは、データの永続化、整合性の保証、効率的な検索、並行アクセスの制御——データベースの本質的な機能を、ファイル一つの中で実現しているからだ。

---

## 3. データベースが解決する4つの問題

ここで立ち止まって、根本的な問いを考えたい。

データベースとは何か。

「データを保存するもの」——この答えは正しいが、不十分だ。データを保存するだけなら、テキストファイルでもJSONファイルでもスプレッドシートでも可能だ。事実、SQLiteが1兆デプロイされる一方で、設定ファイル（`.yaml`、`.toml`、`.json`）としてデータを管理するソフトウェアは無数に存在する。

データベースが「ただのファイル」ではない理由は、ファイルベースのデータ管理が直面する4つの根本的問題を、体系的に解決しているからだ。

### 問題1: 永続化——電源を切ってもデータが消えない保証

データをメモリに保持するだけなら簡単だ。Pythonの辞書に `users = {}` と書けばいい。だが、プロセスが終了した瞬間にデータは消える。サーバが再起動したら、それまでの蓄積は霧散する。

「ファイルに書けばいいだろう」——その通りだ。だが問題は「いつ」「どのように」書くかだ。

毎回の変更をファイルに書き込む（同期書き込み）なら安全だが、ディスクI/Oがボトルネックになる。メモリに溜めてから一括で書き込む（バッファリング）なら速いが、書き込みの前にクラッシュしたらデータが失われる。

この問題を解決するのがWAL（Write-Ahead Logging）だ。データを変更する「前に」、変更内容をログファイルに記録する。クラッシュからの復旧時には、ログを再生することでデータの一貫性を回復できる。PostgreSQLも、MySQLも、SQLiteさえも、この仕組みを実装している。

### 問題2: 整合性——データが矛盾しない保証

ユーザーAの口座から1万円を引き出し、ユーザーBの口座に1万円を入金する。この二つの操作は、どちらか一方だけが実行されてはならない。Aの残高が減ったのにBの残高が増えていなければ、1万円が消失する。

これがトランザクションの「原子性」（Atomicity）だ。複数の操作を一つの不可分な単位として扱い、すべて成功するか、すべて失敗するかの二択にする。

1983年、Andreas ReuterとTheo Haerderがこの概念を含む4つの性質をACIDという頭字語で定式化した——原子性（Atomicity）、一貫性（Consistency）、分離性（Isolation）、永続性（Durability）。Jim Grayがその先駆的研究で原子性・一貫性・永続性を特徴づけていたが、Haerder と Reuter が分離性を加え、現代的なACIDの定義を確立した。

テキストファイルでこれを自前で実装してみるといい。送金処理の途中でプロセスが強制終了されたとき、データの整合性をどう保証するか。ロールバックの仕組みをどう作るか。考え始めると、その複雑さに愕然とするだろう。

### 問題3: 検索——100万件のデータから0.001秒で結果を返す

テキストファイルから特定のデータを探すには、ファイルを先頭から末尾まで読む（シーケンシャルスキャン）しかない。100万行のCSVファイルから1件のレコードを探すには、最悪の場合100万行すべてを読む必要がある。

データベースはこの問題を、インデックスによって解決する。1972年にRudolf BayerとEdward McCreightが発表したB-Treeアルゴリズム——その改良型であるB+Tree——は、現代のほぼすべてのリレーショナルデータベースの基盤だ。B+Treeインデックスを使えば、100万行のテーブルからの検索は、ツリーの高さ分（通常3〜4回）のディスクアクセスで完了する。O(n)がO(log n)になる。

本番環境で `EXPLAIN ANALYZE` を叩いたことがある人なら知っているだろう。適切なインデックスを一本追加するだけで、クエリの実行時間が数秒から数ミリ秒に改善される。あの瞬間の感動を、私は今でも覚えている。

### 問題4: 並行制御——複数のユーザーが同時にデータを触る

これが最も難しく、そしてデータベースが「ただのファイル」と決定的に異なる領域だ。

10人のユーザーが同時にECサイトの在庫数を更新する状況を考えてほしい。在庫が10個ある。10人が同時に「在庫を1つ減らす」操作を行う。正しい結果は在庫0だ。だが、ロック機構がなければ、全員が「在庫10」を読み取り、「10 - 1 = 9」を書き込む。結果は在庫9——9個の注文が闇に消える。

これが競合状態（Race Condition）だ。

ファイルベースのシステムでもロックは実装できる。UNIXの `flock` システムコールは、ファイル単位の排他ロックを提供する。だが、ファイルロックには根本的な限界がある。ロックの粒度がファイル全体になるため、一人が書き込んでいる間は他の全員が待たされる。100人が同時にアクセスするシステムで、全員が一つのファイルロックを奪い合う——それは実用に耐えない。

データベースは、この問題をより洗練された方法で解決する。行レベルロック、MVCC（Multi-Version Concurrency Control）、楽観的ロック、悲観的ロック。これらの仕組みにより、「読み取りは書き込みをブロックせず、書き込みは読み取りをブロックしない」という、一見矛盾する要件を実現している。

---

この4つの問題——永続化、整合性、検索、並行制御——は、1970年にEdgar F. Coddがリレーショナルモデルを提唱する以前から存在していた。パンチカードの時代から、人類はデータをどう保存し、どう検索し、どう整合性を保つかという問いと格闘してきた。データベースとは、その50年にわたる格闘の結晶だ。

`CREATE TABLE` で一瞬でテーブルが作れる2026年の今、この4つの問題がどれほど根深いものだったかを知る人間は少ない。だが知らないことは、恥ではない。知らないことを「知ろうとしない」ことが問題なのだ。

---

## 4. ハンズオン: テキストファイルでデータベースを「再発明」する

ここで手を動かしてみよう。データベースが何を解決しているかを本当に理解するには、データベースなしでデータを管理してみるのが最も効果的だ。

### 演習概要

テキストファイル（CSV）とPythonスクリプトだけで簡易的なCRUDシステムを構築し、以下の3つの問題を体験する:

1. 基本的なCRUD操作の実装
2. 検索性能の限界
3. 並行アクセスによるデータ破壊

### 環境構築

Docker環境（`ubuntu:24.04`推奨）で実行する。Pythonは標準で含まれている。

```bash
docker run -it --rm ubuntu:24.04 bash
apt-get update && apt-get install -y python3
```

### 演習1: CSVベースのCRUDを実装する

まず、テキストファイルでデータを管理する最もシンプルな方法を実装する。

```python
# filedb.py -- テキストファイルによる簡易データ管理
import csv
import os
import time

DATA_FILE = "users.csv"
FIELDNAMES = ["id", "name", "email", "age"]

def init_db():
    """データファイルを初期化する"""
    if not os.path.exists(DATA_FILE):
        with open(DATA_FILE, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
            writer.writeheader()

def create_user(name, email, age):
    """ユーザーを追加する"""
    # IDの採番: 最終行のIDに1を足す
    next_id = 1
    with open(DATA_FILE, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            next_id = int(row["id"]) + 1

    with open(DATA_FILE, "a", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
        writer.writerow({
            "id": next_id,
            "name": name,
            "email": email,
            "age": age,
        })
    return next_id

def read_user(user_id):
    """IDでユーザーを検索する"""
    with open(DATA_FILE, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if int(row["id"]) == user_id:
                return row
    return None

def read_all_users():
    """全ユーザーを取得する"""
    with open(DATA_FILE, "r") as f:
        reader = csv.DictReader(f)
        return list(reader)

def update_user(user_id, **kwargs):
    """ユーザー情報を更新する"""
    rows = read_all_users()
    updated = False
    for row in rows:
        if int(row["id"]) == user_id:
            row.update(kwargs)
            updated = True
    if updated:
        with open(DATA_FILE, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
            writer.writeheader()
            writer.writerows(rows)
    return updated

def delete_user(user_id):
    """ユーザーを削除する"""
    rows = read_all_users()
    new_rows = [r for r in rows if int(r["id"]) != user_id]
    if len(new_rows) < len(rows):
        with open(DATA_FILE, "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
            writer.writeheader()
            writer.writerows(new_rows)
        return True
    return False

if __name__ == "__main__":
    init_db()
    # 基本的なCRUD操作
    uid = create_user("Alice", "alice@example.com", 30)
    print(f"Created user with id={uid}")
    create_user("Bob", "bob@example.com", 25)
    create_user("Charlie", "charlie@example.com", 35)

    print(f"Read user 1: {read_user(1)}")
    print(f"All users: {read_all_users()}")

    update_user(2, name="Robert", age=26)
    print(f"Updated user 2: {read_user(2)}")

    delete_user(3)
    print(f"After delete: {read_all_users()}")
```

このスクリプトを実行すると、CRUD操作は問題なく動く。テキストファイルでもデータ管理は「できる」のだ。ここまでは順調に見える。

### 演習2: 検索性能の壁に直面する

次に、データ量を増やして検索性能の限界を体験する。

```python
# bench_search.py -- 検索性能のベンチマーク
import csv
import time
import random
import string

DATA_FILE = "users_large.csv"
FIELDNAMES = ["id", "name", "email", "age"]

def generate_large_dataset(n):
    """N件のランダムデータを生成する"""
    print(f"Generating {n} records...")
    with open(DATA_FILE, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
        writer.writeheader()
        for i in range(1, n + 1):
            name = "".join(random.choices(string.ascii_lowercase, k=8))
            writer.writerow({
                "id": i,
                "name": name,
                "email": f"{name}@example.com",
                "age": random.randint(18, 65),
            })
    print(f"Generated {n} records.")

def search_by_id(target_id):
    """IDで検索する（シーケンシャルスキャン）"""
    with open(DATA_FILE, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if int(row["id"]) == target_id:
                return row
    return None

def search_by_name(target_name):
    """名前で検索する（シーケンシャルスキャン）"""
    with open(DATA_FILE, "r") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row["name"] == target_name:
                return row
    return None

if __name__ == "__main__":
    N = 100000
    generate_large_dataset(N)

    # 最後のレコードを検索（最悪ケース）
    target_id = N
    start = time.perf_counter()
    for _ in range(10):
        search_by_id(target_id)
    elapsed = (time.perf_counter() - start) / 10
    print(f"Search by ID (seq scan, {N} rows): {elapsed:.4f} sec")

    # データベースとの比較メッセージ
    print(f"\n--- 参考 ---")
    print(f"データベース(B+Treeインデックス)なら、")
    print(f"10万行でも数十マイクロ秒で検索が完了する。")
    print(f"差は数十倍から数百倍になる。")
```

10万行のCSVファイルをシーケンシャルスキャンで検索すると、1回の検索に何十ミリ秒もかかる。データベースのB+Treeインデックスなら、100万行でも数十マイクロ秒だ。この差はデータ量が増えるほど指数的に開いていく。

### 演習3: 並行アクセスでデータが壊れる瞬間を見る

ここが本演習の核心だ。複数のプロセスが同時にファイルを読み書きしたとき、何が起きるかを観察する。

```python
# race_condition.py -- 並行アクセスによるデータ破壊を体験する
import csv
import os
import multiprocessing
import time

DATA_FILE = "counter.csv"

def init_counter():
    """カウンタを初期化する"""
    with open(DATA_FILE, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["counter"])
        writer.writerow([0])

def read_counter():
    """カウンタの現在値を読む"""
    with open(DATA_FILE, "r") as f:
        reader = csv.reader(f)
        next(reader)  # ヘッダをスキップ
        return int(next(reader)[0])

def write_counter(value):
    """カウンタの値を書き込む"""
    with open(DATA_FILE, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["counter"])
        writer.writerow([value])

def increment_counter(n_times):
    """カウンタをN回インクリメントする（ロックなし）"""
    for _ in range(n_times):
        current = read_counter()
        # 競合状態を発生させやすくするための微小な遅延
        time.sleep(0.0001)
        write_counter(current + 1)

if __name__ == "__main__":
    WORKERS = 4
    INCREMENTS_PER_WORKER = 50

    print("=== 並行アクセスによるデータ破壊の実験 ===\n")
    print(f"ワーカー数: {WORKERS}")
    print(f"各ワーカーのインクリメント回数: {INCREMENTS_PER_WORKER}")
    print(f"期待される最終値: {WORKERS * INCREMENTS_PER_WORKER}\n")

    init_counter()
    print(f"初期値: {read_counter()}")

    # 複数プロセスで同時にインクリメント
    processes = []
    for i in range(WORKERS):
        p = multiprocessing.Process(
            target=increment_counter,
            args=(INCREMENTS_PER_WORKER,),
        )
        processes.append(p)

    start = time.perf_counter()
    for p in processes:
        p.start()
    for p in processes:
        p.join()
    elapsed = time.perf_counter() - start

    final = read_counter()
    expected = WORKERS * INCREMENTS_PER_WORKER

    print(f"\n最終値: {final}")
    print(f"期待値: {expected}")
    print(f"消失した更新: {expected - final}")
    print(f"データ損失率: {(expected - final) / expected * 100:.1f}%")
    print(f"実行時間: {elapsed:.2f} sec")

    if final != expected:
        print(f"\n>>> データが壊れた！")
        print(f">>> {expected - final}回分の更新が闇に消えた。")
        print(f">>> これが競合状態（Race Condition）である。")
        print(f">>> データベースはこの問題を、ロックとMVCCで解決する。")
    else:
        print(f"\n(今回はたまたま壊れなかった。再実行すると壊れる可能性がある)")
```

4つのプロセスが同時にカウンタをインクリメントする。期待値は200だが、実際の値は100以下になることも珍しくない。半分以上の更新が「消失」する。

これが競合状態だ。そしてこれが、データベースが解決する最も重要な問題の一つだ。

なぜこうなるか。プロセスAがカウンタを読む（値:5）。プロセスBも同時にカウンタを読む（値:5）。Aが5+1=6を書き込む。Bも5+1=6を書き込む。2回のインクリメントで値は6にしかならない。1回分の更新が上書きされて消えた。これを「Lost Update問題」と呼ぶ。

データベースはこの問題を、トランザクションと排他制御によって解決する。`BEGIN; UPDATE counters SET value = value + 1; COMMIT;`——このSQLは、読み取りと書き込みを原子的に実行し、他のトランザクションとの干渉を防ぐ。ファイル一つで苦闘していた問題が、一行のSQLで解決する。

その「一行のSQL」の裏にある50年分の知恵を、この連載で辿っていく。

---

## 5. データの地層へ

第1回を締めくくるにあたり、ここまでの議論を整理しよう。

**データベースが解決する4つの根本問題:**

第一に、永続化。データをメモリだけでなくディスクに安全に保存し、クラッシュからも復旧できる仕組みを提供する。WALはその代表的な技術だ。

第二に、整合性。複数の操作を一つの不可分な単位として扱い、データが矛盾する中間状態に陥らないことを保証する。ACIDトランザクションがその核心にある。

第三に、検索。大量のデータから必要な情報を高速に取り出す。B+Treeインデックスは50年以上にわたってこの問題の主力解であり続けている。

第四に、並行制御。複数のユーザーが同時にデータを操作しても、結果の正しさが保証される。ロックとMVCCが、読み取りと書き込みの共存を可能にする。

これら4つの問題は、1950年代のパンチカードの時代から存在していた。そして50年以上の歳月をかけて、先人たちが一つずつ解決策を積み上げてきた。その積層が、今あなたの目の前にある「データベース」だ。

冒頭の問いに戻ろう。「なぜPostgreSQLを選んだのか」——この問いに対して、「フレームワークのデフォルトだから」ではなく、データベースの設計思想とトレードオフを踏まえて答えられるようになること。それがこの連載の目標だ。

1970年、IBMのEdgar F. Coddが _Communications of the ACM_ に発表した一本の論文——「A Relational Model of Data for Large Shared Data Banks」——は、データベースの世界を永遠に変えた。だが、Coddの論文が生まれるまでには、ファイルベースのデータ管理の限界、階層型データベースの制約、そして「データをどう構造化するか」という根本的な問いとの格闘があった。

次回は、その「格闘」の始まりを辿る。パンチカードとテープの時代——データ管理が「プログラマの個人技」だった時代から、ISAM、フラットファイル、そして「データの冗長性と不整合」という悪夢が、データベースという概念を生み出す過程を語る。

あなたに問いたい。今のあなたは、データベースを「使っている」のか。それとも、データベースに「依存している」のか。使っているなら、なぜそれを選んだのか、語れるか。語れないなら、それは「依存」だ。

依存から脱却するための第一歩として、次回、データ管理の夜明けから旅を始めよう。

---

### 参考文献

- Stack Overflow, "2024 Stack Overflow Developer Survey", 2024年. <https://survey.stackoverflow.co/2024/technology>
- Stack Overflow, "2025 Stack Overflow Developer Survey", 2025年. <https://survey.stackoverflow.co/2025/technology>
- DB-Engines, "DB-Engines Ranking", 2026年2月. <https://db-engines.com/en/ranking>
- DB-Engines, "Information on 498 Database Management Systems". <https://db-engines.com/en/systems>
- SQLite, "Most Widely Deployed SQL Database Engine". <https://www.sqlite.org/mostdeployed.html>
- Edgar F. Codd, "A Relational Model of Data for Large Shared Data Banks", _Communications of the ACM_, Vol.13, No.6, pp.377-387, June 1970. <https://dl.acm.org/doi/10.1145/362384.362685>
- Theo Haerder, Andreas Reuter, "Principles of Transaction-Oriented Database Recovery", _ACM Computing Surveys_, 1983年.
- Rudolf Bayer, Edward McCreight, "Organization and Maintenance of Large Ordered Indexes", _Acta Informatica_, Vol.1, pp.173-189, 1972年.
- Abraham Silberschatz, Henry F. Korth, S. Sudarshan, _Database System Concepts_ (教科書).

---

**次回予告：** 第2回「ファイルからデータベースへ——データ管理の夜明け」では、パンチカードとテープの時代から、ISAMの発明、フラットファイルの限界、そしてデータベース管理システム（DBMS）という概念が生まれるまでの道のりを辿る。
