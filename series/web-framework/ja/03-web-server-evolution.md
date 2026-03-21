# フレームワークという幻想

## ——Webアプリケーションの「当たり前」を疑う

### 第3回：Webサーバの進化——Apache, mod_perl, FastCGI

**連載「フレームワークという幻想——Webアプリケーションの『当たり前』を疑う」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- CGIの「遅さ」が何に起因し、なぜ深刻な問題だったのか
- Apache HTTP Serverが1年で市場を制覇できた構造的理由
- mod_perlとFastCGI——同じ問題に対する異なる設計思想の比較
- CGI vs FastCGIのパフォーマンス差をApache Benchで実測する方法

---

## 1. httpd.confの1行が世界を変えた日

1999年頃、私はあるWebシステムの運用を任されていた。Perl CGIで書かれた社内向けの業務アプリケーションで、ユーザー数は50人程度。開発当初は問題なく動いていた。

だが、月末の集計処理の時期になると状況が一変する。朝9時、全員が一斉にログインしてレポートを生成し始めると、サーバのロードアベレージが跳ね上がる。ブラウザには「このページは表示できません」のエラーが断続的に出る。topコマンドを叩くと、大量のPerlプロセスがメモリを食い潰しているのが見える。

```
  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
14231 www-data  20   0  8212 5648 1424 R 12.0  2.2   0:01.23 perl
14232 www-data  20   0  8196 5632 1412 R 11.3  2.2   0:01.15 perl
14233 www-data  20   0  8204 5640 1416 R 10.7  2.2   0:01.18 perl
14234 www-data  20   0  8188 5624 1408 R 10.2  2.1   0:01.12 perl
...
```

50人のユーザーがほぼ同時にリクエストを送ると、50個のPerlプロセスが起動される。1プロセスあたり5〜6MBのメモリを消費する。当時のサーバは物理メモリ256MB。単純計算で、CGIプロセスだけで300MB——物理メモリを超える。スワップが発生し、ディスクI/Oがボトルネックになり、レスポンスタイムが秒単位に膨れ上がる。

この問題を先輩エンジニアに相談した。返ってきた答えは「mod_perl入れろ」だった。

httpd.confに数行追加して、Apacheを再起動する。それだけで、世界が変わった。

同じ50人の同時アクセスで、ロードアベレージは劇的に下がった。レスポンスタイムはミリ秒単位に戻った。Perlプロセスが毎回起動されなくなった代わりに、ApacheのプロセスサイズがPerlインタプリタを抱え込んだ分だけ大きくなったが、プロセスの生成と破棄のオーバーヘッドが消えたことの効果は圧倒的だった。

あのとき私が感じたのは、感動と同時に、恐怖だった。「こんなに変わるのか」という感動。そして「CGIのときに自分が見ていたものは、本質的な処理コストではなく、プロセス起動のオーバーヘッドだったのか」という恐怖。自分がパフォーマンスについて何も理解していなかったことを突きつけられた。

CGIの「遅さ」をどう克服したか。その試行錯誤の歴史は何を教えてくれるか。第3回では、この問いに向き合う。

---

## 2. Apacheの台頭——パッチの集合体が覇権を握るまで

### NCSA HTTPdの停滞とApacheの誕生

第2回で触れたように、Rob McCoolが1994年中頃にNCSAを去り、Netscape Communications Corporationに移籍したことで、NCSA HTTPdの開発は停滞した。しかしNCSA HTTPdは既に多くのサイトで稼働しており、各地の管理者たちが独自にバグ修正パッチを書いていた。

1995年初頭、Brian Behlendorfがこれらのパッチを集約するプロジェクトを立ち上げた。BehlendorfとCliff Skolnickがメーリングリストと共有スペースを用意し、カリフォルニアのベイエリアに開発者がアクセスできるマシンを設置した。1995年4月、最初の公式リリースであるApache 0.6.2が公開される。そして1995年12月1日、Apache 1.0がリリースされた。

ここで注目すべきは、Apacheの成長速度である。Netcraftの調査データが、その異常なスピードを物語る。

1995年8月——Netcraftが初めてWebサーバ調査を実施した時点で、NCSA HTTPdが57%のシェアを持ち、CERN httpdが19%、そしてApacheはわずか3.5%だった。それがわずか8か月後の1996年4月には、Apacheとその派生が29%で首位に立った。NCSA HTTPdは26%に後退した。さらに1996年12月には、Apacheのシェアは41%（247,419サイト）にまで拡大した。

1年足らずで3.5%から41%へ。この急成長には構造的な理由がある。

### Apacheが勝てた理由——モジュールアーキテクチャ

Apacheが単なる「NCSA HTTPdのパッチ集」を超えた存在になれた最大の理由は、モジュールアーキテクチャの採用にある。

NCSA HTTPdは機能がサーバ本体にハードコードされていた。新機能の追加にはサーバ本体のコードを修正する必要がある。対してApacheは、コア機能を最小限に抑え、機能拡張をモジュールとして分離した。

```
Apache HTTP Server のアーキテクチャ（Apache 1.x）

┌─────────────────────────────────────────────────┐
│              Apache Core                         │
│  ┌───────────────────────────────────────────┐  │
│  │  HTTP プロトコル処理                        │  │
│  │  接続管理                                  │  │
│  │  リクエスト処理パイプライン                   │  │
│  └───────────────────────────────────────────┘  │
│                                                  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │ mod_cgi  │ │ mod_auth │ │mod_alias │ ...    │
│  └──────────┘ └──────────┘ └──────────┘        │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │ mod_ssl  │ │mod_rewrite│ │mod_perl │ ...    │
│  └──────────┘ └──────────┘ └──────────┘        │
│                                                  │
│  モジュールはリクエスト処理パイプラインの          │
│  各フェーズにフックできる                         │
└─────────────────────────────────────────────────┘
```

Apacheのリクエスト処理は、複数のフェーズに分かれたパイプラインとして設計されていた。URLの変換（mod_alias、mod_rewrite）、認証（mod_auth）、コンテンツ生成（mod_cgi、mod_perl）、ログ記録（mod_log_config）——各フェーズにモジュールが「フック」する。モジュールはApacheのAPIを通じてリクエスト情報にアクセスし、処理結果をパイプラインに返す。

この設計が意味したのは、誰でもモジュールを書いてApacheの機能を拡張できるということだ。CGI以外の方法でWebアプリケーションを実行したければ、その方法をモジュールとして実装すればよい。後にmod_perl、mod_php、mod_python、mod_fastcgiが生まれた土壌は、このモジュールアーキテクチャにあった。

### 同時多発的に現れた「CGIの代替」

1996年、CGIの遅さを解決するためのアプローチが同時多発的に現れた。興味深いのは、それぞれが異なる設計思想に基づいていたことだ。

| アプローチ | 開発元                      | リリース         | 設計思想                       |
| ---------- | --------------------------- | ---------------- | ------------------------------ |
| mod_perl   | Gisle Aas → Doug MacEachern | 1996年3月        | インタプリタをサーバに組み込む |
| FastCGI    | Open Market (Mark R. Brown) | 1996年4月        | CGIプロセスを常駐させる        |
| NSAPI      | Netscape (Rob McCool)       | 1996年           | サーバ固有APIで拡張する        |
| ISAPI      | Microsoft                   | 1996年 (IIS 2.0) | サーバ固有APIで拡張する        |

NSAPIとISAPIは、それぞれNetscape Enterprise ServerとMicrosoft IIS専用のプロプライエタリなAPIだった。サーバプロセス内でDLL/共有ライブラリとして動作し、高速ではあるが、特定のサーバに完全にロックインされる。Rob McCoolがNCSAを去った後にNetscapeで開発したNSAPIが、自らが策定したCGIの「遅さ」に対する解答だったというのは、歴史の皮肉である。

対して、mod_perlとFastCGIは、Apacheを中心とするオープンなエコシステムから生まれた。この2つは同じ問題——「CGIのプロセス起動コストをどう削減するか」——に対する、根本的に異なるアプローチを取った。

---

## 3. 2つの解法——mod_perlとFastCGI

### mod_perl——インタプリタを飲み込んだサーバ

mod_perlの歴史は、1996年3月25日に始まる。Gisle AasがApacheにPerlインタプリタを組み込む最初の実装をリリースした。「プルーフ・オブ・コンセプト」と呼ぶべきものだった。

この試みに即座に反応したのがDoug MacEachernだった。MacEachernはPerl埋め込みの問題に取り組み、ドキュメント（perlembed manpage）を整備し、バグを修正した。1996年5月1日にリリースされたバージョン0.50a1が、mod_perlの本格的な第一歩となった。同年8月、PAUSE（Perl Authors Upload Server）がmod_perlを使った最初の本番サーバとなった。

mod_perlのアプローチは大胆だった。Perlインタプリタをサーバプロセスに組み込むことで、プロセス起動のオーバーヘッドを根本的に排除する。

```
CGIモデル:
リクエスト → fork() → Perlインタプリタ起動 → モジュール読込 → スクリプト実行 → 終了
リクエスト → fork() → Perlインタプリタ起動 → モジュール読込 → スクリプト実行 → 終了
（毎回同じ初期化コストが発生する）

mod_perlモデル:
[Apache起動時] → Perlインタプリタ組込 → モジュール読込（1回だけ）

リクエスト → Apache子プロセス内のPerlで実行 → レスポンス返却（プロセス存続）
リクエスト → Apache子プロセス内のPerlで実行 → レスポンス返却（プロセス存続）
（初期化コストはApache起動時の1回のみ）
```

CGIでは、1回のリクエストを処理するために以下の手順が毎回必要だった。

1. fork()でプロセスを生成する
2. exec()でPerlインタプリタを起動する
3. Perlがスクリプトをコンパイルする
4. `use CGI;`などのモジュールを読み込む
5. スクリプトを実行する
6. 標準出力にレスポンスを書き出す
7. プロセスが終了する

このうち、実際にビジネスロジックを実行しているのは5と6だけだ。1〜4はすべてオーバーヘッドである。特にPerlインタプリタの起動とモジュール読み込みは、単純な「Hello, World!」でも数十ミリ秒を消費した。

mod_perlは、この1〜4のコストをApacheの起動時に1回だけ支払う仕組みに変えた。Apacheの各子プロセスにPerlインタプリタが常駐し、リクエストが来ればそのインタプリタ上でスクリプトが直接実行される。

パフォーマンスへの効果は劇的だった。Apache Software Foundationが公開しているベンチマークデータによれば、MySQLカウンタースクリプトでの比較テストで、100回反復においてCGIが56秒かかるのに対し、mod_perlは2秒——約28倍の差があった。別のテストでは、mod_cgiが秒間156リクエストを処理するのに対し、mod_perlは秒間856リクエストを処理した。状況によっては「CGI比で100〜200倍の速度向上」とも言われている。

1999年にはDoug MacEachernとLincoln SteinによるO'Reilly本『Writing Apache Modules with Perl and C』が出版され、mod_perlのエコシステムは急速に拡大した。同年のApacheCon（フロリダ州オーランド）で、mod_perlは正式にApache Software Foundationのプロジェクトとなった。

#### mod_perlの代償

だが、mod_perlにはCGIにはなかった問題が生まれた。

**メモリ消費の増大**: Apacheの各子プロセスにPerlインタプリタが組み込まれるため、1プロセスあたりのメモリ使用量が大幅に増加する。CGIでは、リクエストが終わればプロセスごと消えてメモリが解放された。mod_perlでは、Apache子プロセスが生きている限り、Perlインタプリタとロードされたモジュールがメモリに居座り続ける。静的コンテンツの配信にも、この肥大化したプロセスが使われてしまう。

**グローバル変数の汚染**: CGIではプロセスがリクエストごとに消えるため、グローバル変数の初期化忘れは問題にならなかった。mod_perlでは、前のリクエストで設定されたグローバル変数が次のリクエストでも残る。これは微妙なバグの温床となった。

```perl
# CGIでは問題にならないが、mod_perlでは危険なコード
my $count;  # グローバルスコープの変数

sub handler {
    $count++;  # リクエストごとにインクリメントされる
    # CGI: 常に $count = 1 （毎回新しいプロセス）
    # mod_perl: $count が蓄積する （同じプロセスが再利用される）
}
```

**言語ロックイン**: mod_perlはPerlに特化した解決策であり、PythonやRubyのスクリプトには使えない。後にmod_python（2000年、Gregory Trubetskoy）やmod_ruby（2001年、Shugo Maeda）が作られたが、それぞれの言語ごとに個別のモジュールが必要だった。

mod_perlのアプローチは、「Webサーバとアプリケーションランタイムを一体化する」という設計判断だった。高速だが、密結合になる。この密結合が後に問題として顕在化するのは、Webアーキテクチャがより複雑になってからのことだ。

### FastCGI——プロセスの独立性を保ったまま速くする

FastCGIは、mod_perlとはまったく異なるアプローチを取った。

1996年4月29日、Open Market社のMark R. Brownが設計したFastCGI仕様が公開された。Open Market社はWebサーバ製品を開発していた企業であり、FastCGIはNetscapeのNSAPIに対するオープンな対抗として開発された側面がある。

FastCGIの核心的なアイデアは、**CGIのプロセスモデルを維持しつつ、プロセスの起動コストを排除する**ことにある。

```
CGIモデル:
Webサーバ ──fork/exec──→ [CGIプロセス起動] → 処理 → [プロセス終了]
Webサーバ ──fork/exec──→ [CGIプロセス起動] → 処理 → [プロセス終了]
Webサーバ ──fork/exec──→ [CGIプロセス起動] → 処理 → [プロセス終了]

FastCGIモデル:
                         ┌───────────────────────────┐
Webサーバ ──ソケット通信──→│ FastCGIプロセス（常駐）     │
                         │                           │
                         │ リクエスト1 → 処理 → 応答  │
                         │ リクエスト2 → 処理 → 応答  │
                         │ リクエスト3 → 処理 → 応答  │
                         │ ...                       │
                         └───────────────────────────┘
```

CGIではリクエストのたびにプロセスが起動され、終了する。FastCGIでは、アプリケーションプロセスが常駐し、複数のリクエストを処理する。Webサーバとアプリケーションプロセスの間は、UNIXドメインソケットまたはTCPソケットを介したバイナリプロトコルで通信する。

この設計には、CGIから2つのものを継承し、1つの致命的な欠点を排除した、という構造がある。

**継承したもの1: 言語非依存性。** FastCGIはプロトコル仕様であり、アプリケーション側の実装言語を規定しない。Perl、Python、Ruby、C、PHP——FastCGIプロトコルを実装できる言語であれば何でもよい。mod_perlがPerl専用だったのとは対照的だ。

**継承したもの2: プロセス分離。** FastCGIアプリケーションはWebサーバとは別プロセスで動作する。アプリケーションがクラッシュしてもWebサーバは影響を受けない。mod_perlのようにサーバプロセス内でアプリケーションが動く場合、アプリケーションのバグがサーバ全体を巻き込むリスクがあった。

**排除したもの: プロセスの起動・終了コスト。** CGIの致命的な弱点——リクエストごとのfork/exec——を、プロセスの常駐化によって排除した。

#### FastCGIプロトコルの設計

FastCGIの通信プロトコルは、CGIの環境変数と標準入出力を、構造化されたバイナリメッセージに置き換えたものだ。

```
FastCGI レコードフォーマット:

┌──────────┬──────────┬──────────┬──────────┐
│ Version  │  Type    │Request ID│Content   │
│ (1 byte) │ (1 byte) │ (2 bytes)│Length    │
│          │          │          │(2 bytes) │
├──────────┴──────────┴──────────┴──────────┤
│ Padding Length (1 byte) │ Reserved (1 byte)│
├─────────────────────────┴────────────────────┤
│              Content Data                    │
│         (Content Length bytes)                │
├──────────────────────────────────────────────┤
│              Padding Data                    │
│         (Padding Length bytes)                │
└──────────────────────────────────────────────┘

主要なレコードタイプ:
  FCGI_BEGIN_REQUEST  (1)  -- リクエスト開始
  FCGI_ABORT_REQUEST  (2)  -- リクエスト中断
  FCGI_END_REQUEST    (3)  -- リクエスト完了
  FCGI_PARAMS         (4)  -- 環境変数（CGIのQUERY_STRING等に相当）
  FCGI_STDIN          (5)  -- 標準入力（POSTボディ等）
  FCGI_STDOUT         (6)  -- 標準出力（レスポンスボディ）
  FCGI_STDERR         (7)  -- 標準エラー出力
```

CGIで環境変数として渡されていた`REQUEST_METHOD`、`QUERY_STRING`などは、`FCGI_PARAMS`レコードとして送信される。CGIで標準入力として渡されていたPOSTボディは、`FCGI_STDIN`レコードとして送信される。CGIの標準出力に相当するのは、`FCGI_STDOUT`レコードだ。

注目すべきは、Request IDフィールドの存在だ。このフィールドにより、1つのソケット接続上で複数のリクエストを多重化（multiplexing）できる。CGIでは物理的に1プロセス=1リクエストだったが、FastCGIでは1プロセスが同時に複数のリクエストを処理できる設計になっている。

### 2つのアプローチの本質的な違い

mod_perlとFastCGIの設計思想の違いは、ソフトウェアアーキテクチャにおける根本的なトレードオフを体現している。

```
┌─────────────────────────────────────────────────────────┐
│                   mod_perl のアーキテクチャ                │
│                                                          │
│  ┌────────────────────────────────────────────┐         │
│  │          Apache httpd プロセス               │         │
│  │                                             │         │
│  │  ┌─────────┐  ┌──────────┐  ┌──────────┐  │         │
│  │  │ Apache  │  │  mod_perl │  │  Perl    │  │         │
│  │  │ Core    │←→│ (glue)   │←→│ Runtime  │  │         │
│  │  └─────────┘  └──────────┘  └──────────┘  │         │
│  │                                             │         │
│  │  同一プロセス空間で動作（密結合）              │         │
│  └────────────────────────────────────────────┘         │
│                                                          │
│  利点: 最高速。Apache APIに直接アクセス可能               │
│  欠点: メモリ共有。障害が波及。言語固定                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                  FastCGI のアーキテクチャ                  │
│                                                          │
│  ┌──────────────┐      ┌──────────────────┐            │
│  │ Apache httpd │      │ FastCGIプロセス    │            │
│  │              │ソケット│                  │            │
│  │ mod_fastcgi  │←────→│ アプリケーション   │            │
│  │              │通信   │ (Perl/Python/    │            │
│  │              │      │  Ruby/C/...)     │            │
│  └──────────────┘      └──────────────────┘            │
│                                                          │
│  異なるプロセス空間で動作（疎結合）                         │
│                                                          │
│  利点: プロセス分離。言語非依存。独立スケーリング           │
│  欠点: ソケット通信のオーバーヘッド。Apache APIに非アクセス │
└─────────────────────────────────────────────────────────┘
```

| 観点           | mod_perl                                 | FastCGI                                     |
| -------------- | ---------------------------------------- | ------------------------------------------- |
| 結合度         | 密結合（同一プロセス）                   | 疎結合（別プロセス、ソケット通信）          |
| 言語           | Perl専用                                 | 言語非依存                                  |
| パフォーマンス | 最高速（プロセス間通信なし）             | 高速（ソケット通信のオーバーヘッドあり）    |
| 障害分離       | なし（Perlのバグがhttpdを巻き込む）      | あり（アプリクラッシュがhttpdに影響しない） |
| メモリ効率     | 低い（全Apache子プロセスがPerlを抱える） | 高い（アプリプロセス数を独立制御可能）      |
| Apache API     | 直接利用可能                             | 利用不可                                    |
| デプロイ       | Apache再起動が必要                       | アプリプロセスだけ再起動可能                |

この比較表は、ソフトウェアアーキテクチャにおける「密結合 vs 疎結合」のトレードオフそのものだ。密結合は速いが脆い。疎結合は遅いが柔軟で堅牢だ。

後の歴史を先取りすれば、FastCGIの「疎結合」アプローチが勝利した。PHPがmod_phpからPHP-FPM（FastCGIプロセスマネージャ）に移行し、PythonがWSGI + uWSGI/Gunicornという構成を採用し、RubyがRackサーバ（Unicorn、Puma）を経由するようになったのは、すべてFastCGIの思想——「Webサーバとアプリケーションランタイムを分離する」——の延長線上にある。

なぜ疎結合が勝ったのか。理由は単純だ。Webアプリケーションが複雑になるにつれ、Webサーバとアプリケーションの関心事が乖離していったからだ。Webサーバは静的ファイルの配信、SSL終端、リバースプロキシ、ロードバランシングを担当する。アプリケーションはビジネスロジックに集中する。この2つを同じプロセスに押し込める理由はない。nginxが2004年にApacheの対抗として登場したとき、そもそもnginxにはmod_perlに相当する機能がなかった。FastCGI（やその後継のuWSGIプロトコル）を通じてアプリケーションと通信する設計が前提だった。

### もう一つの解法——SCGI

FastCGIのプロトコルはバイナリ形式で多機能だが、実装がやや複雑だった。2001年、Neil Schemenauer がSimple Common Gateway Interface（SCGI）を設計し、より簡素なテキストベースのプロトコルとして提案した。SCGIはFastCGIの簡易版と位置づけられ、Webサーバがパース済みのHTTPリクエスト情報を正規化して送信する設計だった。

SCGIが広く普及することはなかったが、「FastCGIは複雑すぎる」という声が当時のコミュニティに存在していた事実を示している。プロトコル設計における「シンプルさ vs 機能性」のトレードオフは、この領域でも例外ではなかった。

---

## 3.5 Apache 2.0——サーバ自体のアーキテクチャ変革

mod_perlやFastCGIがアプリケーション側のパフォーマンス問題を解決しようとしていた一方で、Apacheサーバ自体にもアーキテクチャ上の限界が見えていた。

Apache 1.xは「prefork」モデル——リクエストごとに子プロセスを割り当てる——で動作していた。mod_perlを使えばPerlの起動コストは消えるが、1リクエスト=1プロセスという構造自体は変わらない。同時接続数が増えればプロセス数が増え、メモリ消費が線形に増加する。

1999年、Dan Kegelが「The C10K problem」という記事を公開し、1台のサーバで1万の同時接続を処理する問題を提起した。Apache 1.xのpreforkモデルでは、1万接続=1万プロセスが必要になり、これは現実的ではない。

2000年に開発が始まり、2002年4月6日にリリースされたApache 2.0は、この問題に対してMPM（Multi-Processing Modules）というアーキテクチャを導入した。

```
Apache MPM の変遷:

┌─────────────────────────────────────────────────────┐
│  prefork MPM（Apache 1.x互換）                        │
│                                                      │
│  親プロセス                                           │
│    ├── 子プロセス1 ── [1リクエスト処理]               │
│    ├── 子プロセス2 ── [1リクエスト処理]               │
│    ├── 子プロセス3 ── [1リクエスト処理]               │
│    └── ...                                           │
│                                                      │
│  特徴: プロセスベース。スレッド安全でないモジュール    │
│        （mod_perlなど）でも安全に動作する              │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  worker MPM（Apache 2.0〜、スレッドベース）            │
│                                                      │
│  親プロセス                                           │
│    ├── 子プロセス1                                    │
│    │     ├── スレッド1 ── [1リクエスト処理]           │
│    │     ├── スレッド2 ── [1リクエスト処理]           │
│    │     └── スレッド3 ── [1リクエスト処理]           │
│    ├── 子プロセス2                                    │
│    │     ├── スレッド1 ── [1リクエスト処理]           │
│    │     └── ...                                     │
│    └── ...                                           │
│                                                      │
│  特徴: スレッドベース。メモリ効率が大幅に向上          │
│        ただしmod_perlとの互換性に問題あり              │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  event MPM（Apache 2.4〜、イベント駆動）               │
│                                                      │
│  親プロセス                                           │
│    ├── 子プロセス1                                    │
│    │     ├── リスナースレッド ── 接続受付・振り分け    │
│    │     ├── ワーカースレッド1 ── [リクエスト処理]     │
│    │     ├── ワーカースレッド2 ── [リクエスト処理]     │
│    │     └── ...                                     │
│    └── ...                                           │
│                                                      │
│  特徴: Keep-Alive接続をリスナースレッドが管理          │
│        ワーカースレッドを効率的に活用できる             │
└─────────────────────────────────────────────────────┘
```

MPMの導入は、Apacheのモジュラー設計思想の極致だった。ネットワーク接続の管理とリクエストの分配——サーバの最も基本的な機能すらもモジュールとして交換可能にした。OSの特性やワークロードに応じて、prefork、worker、eventを選択できる。

だが、worker MPMやevent MPMの恩恵を受けるには、アプリケーション側がスレッドセーフでなければならない。mod_perlはスレッドセーフの保証が難しく、prefork MPMでしか安全に動作しないことが多かった。これは、mod_perlの「密結合」設計が、サーバ自体の進化を阻害するという皮肉な結果をもたらした。

FastCGIの「疎結合」モデルでは、こうした問題は原理的に発生しない。WebサーバがどのMPMを使おうと、ソケットの向こう側のアプリケーションプロセスは影響を受けないからだ。

---

## 4. ハンズオン——CGI vs FastCGIのパフォーマンス比較

ここからは手を動かそう。CGIとFastCGIのパフォーマンス差を、Apache Bench（ab）を使って実測する。

Apache Benchは、元々Adam Twiss（Zeus Technology）が1996年に「ZeusBench」として開発し、後にApacheグループに寄贈されたベンチマークツールだ。シンプルだが、CGI vs FastCGIの差を体感するには十分である。

### 環境構築

Docker環境でApache HTTP Server、Perl、FastCGI環境をセットアップする。

```bash
# Ubuntu環境でApache, Perl, FastCGI関連パッケージをセットアップ
docker run -it --rm -p 8080:80 --name fcgi-lab ubuntu:24.04 bash
```

コンテナ内で以下を実行する。

```bash
# 必要なパッケージをインストール
apt-get update && apt-get install -y \
  apache2 \
  perl \
  libcgi-pm-perl \
  libfcgi-perl \
  libapache2-mod-fcgid \
  curl \
  apache2-utils \
  time

# CGIモジュールを有効化
a2enmod cgi
a2enmod cgid

# FastCGI (fcgid) モジュールを有効化
a2enmod fcgid

# cgi-binディレクトリの確認
ls -la /usr/lib/cgi-bin/
```

### 演習1: CGIスクリプトの準備

まず、ベンチマーク用のCGIスクリプトを作成する。意図的にPerlモジュールをいくつか読み込み、実際のWebアプリケーションに近い状況を再現する。

```bash
# CGIスクリプト: 少し「重い」処理をシミュレート
cat > /usr/lib/cgi-bin/bench_cgi.pl << 'SCRIPT'
#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use POSIX qw(strftime);
use File::Basename;

my $q = CGI->new;
my $now = strftime("%Y-%m-%d %H:%M:%S", localtime);
my $pid = $$;

print $q->header('text/html');
print <<HTML;
<html>
<body>
<h1>CGI Benchmark</h1>
<p>Time: $now</p>
<p>PID: $pid</p>
<p>Mode: CGI (new process per request)</p>
</body>
</html>
HTML
SCRIPT

chmod 755 /usr/lib/cgi-bin/bench_cgi.pl
```

動作確認する。

```bash
# Apacheを起動
apachectl start

# CGIスクリプトの動作確認
curl http://localhost/cgi-bin/bench_cgi.pl
```

2回呼び出して、PIDが毎回変わることを確認する。

```bash
curl -s http://localhost/cgi-bin/bench_cgi.pl | grep PID
curl -s http://localhost/cgi-bin/bench_cgi.pl | grep PID
```

PIDが異なれば、リクエストごとに新しいプロセスが起動されている証拠だ。

### 演習2: FastCGIスクリプトの準備

次に、同等の処理を行うFastCGIスクリプトを作成する。

```bash
# FastCGIスクリプト用ディレクトリ
mkdir -p /var/www/fcgi-bin

# FastCGIスクリプト
cat > /var/www/fcgi-bin/bench_fcgi.pl << 'SCRIPT'
#!/usr/bin/perl
use strict;
use warnings;
use FCGI;
use POSIX qw(strftime);
use File::Basename;

my $request = FCGI::Request();
my $count = 0;

# FastCGIのイベントループ: プロセスは常駐し、リクエストを繰り返し処理する
while ($request->Accept() >= 0) {
    $count++;
    my $now = strftime("%Y-%m-%d %H:%M:%S", localtime);
    my $pid = $$;

    print "Content-type: text/html\r\n\r\n";
    print <<HTML;
<html>
<body>
<h1>FastCGI Benchmark</h1>
<p>Time: $now</p>
<p>PID: $pid</p>
<p>Request count: $count</p>
<p>Mode: FastCGI (persistent process)</p>
</body>
</html>
HTML
}
SCRIPT

chmod 755 /var/www/fcgi-bin/bench_fcgi.pl
```

このスクリプトの核心は`while ($request->Accept() >= 0)`のループだ。CGIスクリプトは「実行して終了」だが、FastCGIスクリプトは「リクエストを待ち、処理し、また待つ」を繰り返す。プロセスは常駐し、Perlインタプリタとモジュールは最初の1回だけロードされる。

```bash
# Apache設定にFastCGIの設定を追加
cat > /etc/apache2/conf-available/fcgi-benchmark.conf << 'CONF'
# FastCGI (mod_fcgid) の設定
FcgidWrapper /var/www/fcgi-bin/bench_fcgi.pl .fcgi
FcgidMaxRequestLen 1048576

<Directory "/var/www/fcgi-bin">
    AllowOverride None
    Options +ExecCGI
    Require all granted
    SetHandler fcgid-script
</Directory>

Alias /fcgi-bin/ /var/www/fcgi-bin/

<Location /fcgi-bin/>
    SetHandler fcgid-script
    Options +ExecCGI
</Location>
CONF

a2enconf fcgi-benchmark

# Apacheを再起動
apachectl restart
```

FastCGIスクリプトの動作確認をする。

```bash
curl http://localhost/fcgi-bin/bench_fcgi.pl
curl http://localhost/fcgi-bin/bench_fcgi.pl
```

2回呼び出して、PIDが同じであり、Request countが増加していることを確認する。同じプロセスが複数のリクエストを処理している証拠だ。

### 演習3: Apache Benchによるパフォーマンス比較

いよいよベンチマークだ。Apache Bench（ab）を使って、CGIとFastCGIのパフォーマンスを比較する。

```bash
echo "=== CGI Benchmark ==="
echo "100リクエスト、同時接続数10"
ab -n 100 -c 10 http://localhost/cgi-bin/bench_cgi.pl 2>&1 | \
  grep -E '(Requests per second|Time per request|Failed requests)'

echo ""
echo "=== FastCGI Benchmark ==="
echo "100リクエスト、同時接続数10"
ab -n 100 -c 10 http://localhost/fcgi-bin/bench_fcgi.pl 2>&1 | \
  grep -E '(Requests per second|Time per request|Failed requests)'
```

典型的な結果は以下のようになる（環境によって数値は異なる）。

```
=== CGI Benchmark ===
100リクエスト、同時接続数10
Requests per second:    45.23 [#/sec] (mean)
Time per request:       221.097 [ms] (mean)
Failed requests:        0

=== FastCGI Benchmark ===
100リクエスト、同時接続数10
Requests per second:    312.87 [#/sec] (mean)
Time per request:       31.962 [ms] (mean)
Failed requests:        0
```

この差は、プロセス起動コストの有無をそのまま反映している。CGIでは100リクエストに対して100回のfork/exec + Perlインタプリタ起動が発生する。FastCGIでは、常駐プロセスがソケット経由でリクエストを受け取り、即座に処理を返す。

さらに負荷を上げてみよう。

```bash
echo "=== CGI Benchmark (高負荷) ==="
echo "1000リクエスト、同時接続数50"
ab -n 1000 -c 50 http://localhost/cgi-bin/bench_cgi.pl 2>&1 | \
  grep -E '(Requests per second|Time per request|Failed requests|Complete requests)'

echo ""
echo "=== FastCGI Benchmark (高負荷) ==="
echo "1000リクエスト、同時接続数50"
ab -n 1000 -c 50 http://localhost/fcgi-bin/bench_fcgi.pl 2>&1 | \
  grep -E '(Requests per second|Time per request|Failed requests|Complete requests)'
```

同時接続数が増えると、CGIではプロセスの生成・破棄のオーバーヘッドが蓄積し、パフォーマンス差がさらに拡大する。場合によっては、CGI側でFailed requestsが発生する——プロセス数の上限に達し、新しいリクエストを処理できなくなるのだ。1999年に私が経験した「月末の集計処理でサーバが落ちる」問題の再現である。

### 演習4: プロセスの挙動を観察する

ベンチマーク実行中に、別のターミナルからプロセスの挙動を観察する。

```bash
# 別ターミナルで（docker exec -it fcgi-lab bash）

# CGIベンチマーク中のプロセス観察
watch -n 0.5 'ps aux | grep -E "(perl|fcgi)" | grep -v grep | wc -l'
```

CGIベンチマーク中は、perlプロセスの数が同時接続数に応じて増減するのが見える。FastCGIベンチマーク中は、プロセス数が安定していることが確認できる。

### 何が見えたか

このハンズオンで確認できたことは明快だ。CGIとFastCGIの間には、アプリケーションのコードはほぼ同じであるにもかかわらず、パフォーマンスに大きな差がある。その差の本質は、「プロセスの起動と終了」というオーバーヘッドの有無にある。

FastCGIスクリプトの`while ($request->Accept() >= 0)`ループは、CGIの「起動→処理→終了」モデルを「待機→処理→待機」モデルに変えた。たったこれだけの変更が、数倍から数十倍のパフォーマンス差を生む。

ここには、ソフトウェアエンジニアリングの重要な教訓がある。パフォーマンスのボトルネックは、しばしばアプリケーションのコードそのものではなく、アプリケーションの実行環境にある。コードを最適化する前に、そのコードがどのように実行されているかを理解すべきだ。

---

## 5. まとめと次回予告

### この回の要点

第3回では、CGIの「遅さ」に対する1996年の同時多発的な解決策を掘り下げた。

Apache HTTP Serverは、1995年12月のバージョン1.0リリースから1年足らずで、Netcraft調査において3.5%から41%へとシェアを急拡大した。その原動力は、モジュールアーキテクチャにあった。CGI以外の方法でWebアプリケーションを実行するための基盤——mod_perl、mod_fastcgiなど——を、誰でも開発・導入できる設計が、Apacheのエコシステムを爆発的に拡大させた。

1996年に同時多発的に現れたCGIの代替は、大きく2つのアプローチに分かれた。mod_perlに代表される「インタプリタをサーバに組み込む」密結合アプローチ。FastCGIに代表される「プロセスを常駐させてソケットで通信する」疎結合アプローチ。mod_perlはCGI比で数十倍の速度向上を実現したが、メモリ消費の増大、グローバル変数の汚染、言語ロックインという代償があった。FastCGIはmod_perlほどの極限的な速度は出ないが、言語非依存性、プロセス分離、独立したスケーリングという柔軟性を持っていた。

長期的に見れば、FastCGIの「疎結合」思想が勝利した。PHP-FPM、uWSGI、Gunicorn、Unicorn/Puma——現代のWebアプリケーションサーバはすべて、FastCGIが示した「Webサーバとアプリケーションランタイムの分離」という設計原則の子孫である。

Apache 2.0（2002年）はMPM（Multi-Processing Modules）アーキテクチャを導入し、プロセスモデル自体をモジュールとして交換可能にした。だが、mod_perlの密結合設計はスレッドベースのMPMとの互換性に問題を抱え、サーバ自体の進化を阻害する一因となった。「密結合の罠」はここにもある。

### 冒頭の問いに対する暫定回答

「CGIの『遅さ』をどう克服したか？ その試行錯誤の歴史は何を教えてくれるか？」

教訓は明確だ。同じ問題に対する解法は一つではない。mod_perlとFastCGIは、同じ1996年に、同じ問題に対して、正反対の設計思想で挑んだ。短期的にはmod_perlの速度が圧倒的だったが、長期的にはFastCGIの柔軟性が勝った。

速度と柔軟性。密結合と疎結合。これは技術選定において繰り返し現れるトレードオフだ。「何が速いか」だけでなく、「何が変化に適応できるか」を考える視点が必要である。Webの歴史は、速度のために柔軟性を犠牲にした技術が、環境の変化によって淘汰されてきた歴史でもある。

あなたが今、技術選定の判断を迫られているなら、一つ考えてほしい。その技術は速いか？ だが、それ以上に重要な問いがある——その技術は、3年後に環境が変わったとき、適応できるか？

### 次回予告

第4回「PHP——Webの民主化とその代償」では、CGIの世界から生まれたもう一つの巨人——PHPを取り上げる。Rasmus Lerdorfが1995年に作った「Personal Home Page Tools」は、なぜこれほどまでにWebを席巻したのか。そして、なぜこれほどまでに嫌われたのか。フレームワーク以前の「素のPHP」を知ることで、PHPの設計思想——shared-nothingアーキテクチャとテンプレート言語としての出自——が持つ合理性と限界が見えてくる。

---

## 参考文献

- Apache HTTP Server Project, "About Apache" <https://httpd.apache.org/ABOUT_APACHE.html>
- Apache HTTP Server Documentation, "Multi-Processing Modules (MPMs)" <https://httpd.apache.org/docs/2.4/mpm.html>
- Netcraft Web Server Survey, December 1996 <https://news.netcraft.com/archives/1996/12/01/december_1996_web_server_survey.html>
- Cybercultural, "1995: Apache and Microsoft IIS Shake Up Web Server Market" <https://cybercultural.com/p/1995-apache-microsoft-iis-web-server-market/>
- mod_perl: History, The Apache Software Foundation <https://perl.apache.org/about/history.html>
- mod_perl: Performance Tuning, The Apache Software Foundation <https://perl.apache.org/docs/1.0/guide/performance.html>
- Lincoln Stein, Doug MacEachern, "Writing Apache Modules with Perl and C", O'Reilly, 1999年3月
- Mark R. Brown, "FastCGI Specification", Open Market, Inc., 1996年4月29日 <https://fastcgi-archives.github.io/FastCGI_Specification.html>
- FastCGI Archives, "FastCGI: A High-Performance Web Server Interface" <https://fastcgi-archives.github.io/FastCGI_A_High-Performance_Web_Server_Interface_FastCGI.html>
- Dan Kegel, "The C10K problem", 1999年 <https://www.kegel.com/c10k.html>
- Wikipedia, "ApacheBench" <https://en.wikipedia.org/wiki/ApacheBench>
- Wikipedia, "Netscape Server Application Programming Interface" <https://en.wikipedia.org/wiki/Netscape_Server_Application_Programming_Interface>
- Wikipedia, "Internet Server Application Programming Interface" <https://en.wikipedia.org/wiki/Internet_Server_Application_Programming_Interface>
- Neil Schemenauer, "SCGI: A Simple Common Gateway Interface alternative", 2001年 <https://python.ca/scgi/protocol.txt>
