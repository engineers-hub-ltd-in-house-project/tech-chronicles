# フレームワークという幻想

## ——Webアプリケーションの「当たり前」を疑う

### 第2回：CGIという原点——HTTPリクエストを手で受けた時代

**連載「フレームワークという幻想——Webアプリケーションの『当たり前』を疑う」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- CGI（Common Gateway Interface）が1993年にどのような問題を解決するために生まれたのか
- プロセスフォーク、環境変数、標準入出力——CGIの仕組みの全貌
- CGIが強制した「ステートレス」という制約が、後のWeb開発にどう影響したか
- Apache + Perl CGIの環境をDockerで構築し、実際にCGIスクリプトを書いて動かす方法

---

## 1. cgi-binの中に世界があった

2001年の冬、私は共用レンタルサーバの`/cgi-bin/`ディレクトリの中に、自分が書いたPerlスクリプトをFTPでアップロードしていた。

ファイルのパーミッションを`755`に設定する。これを忘れると「500 Internal Server Error」が返る。当時の私にとって、あの白い画面に表示される無愛想なエラーメッセージは日常だった。パーミッション、改行コード、Perlのパス——どれか一つを間違えるだけで、スクリプトは動かない。

作っていたのは掲示板だった。2ちゃんねる型の簡素なもので、投稿データをテキストファイルに1行ずつ追記し、読み出すときにHTMLを組み立てて返す。データベースは使わない。テキストファイルがデータベースだった。

```perl
#!/usr/bin/perl
use CGI;

my $q = CGI->new;
my $name = $q->param('name');
my $message = $q->param('message');

# 投稿をファイルに追記
open(my $fh, '>>', 'bbs.dat') or die "Cannot open: $!";
print $fh "$name\t$message\t" . time() . "\n";
close($fh);

# HTMLを生成して返す
print $q->header('text/html');
print "<html><body>\n";
print "<h1>掲示板</h1>\n";

open(my $in, '<', 'bbs.dat') or die "Cannot open: $!";
while (my $line = <$in>) {
    chomp $line;
    my ($n, $m, $t) = split(/\t/, $line);
    print "<p><b>$n</b>: $m</p>\n";
}
close($in);

print "</body></html>\n";
```

今見れば、このコードはセキュリティの観点から問題だらけだ。入力のサニタイズがない。ファイルロックもない。複数の同時アクセスでデータが壊れる可能性がある。だが、2001年の個人サイトでは、これが「動いている」ことが全てだった。

このスクリプトが動く仕組みを、当時の私は正確には理解していなかった。`CGI->new`が何をしているのか、`param('name')`がどこからデータを取得しているのか、`print $q->header('text/html')`が実際にどんな文字列を標準出力に書き出しているのか。Perlの入門書に書いてあるとおりに書いたら動いた——それだけだった。

だが、この「動いた」の裏側には、Webアプリケーションの本質がすべて詰まっていた。

前回、私はWebアプリケーションの4つの本質的構成要素——HTTPリクエストの受信、ルーティング、ビジネスロジック、レスポンスの生成——を提示した。この掲示板スクリプトは、その4つをすべて、たった30行程度のコードで実現している。ルーティングはWebサーバがURLとファイルの対応を処理する。リクエストのパースは`CGI.pm`が行う。ビジネスロジックはファイルの読み書き。レスポンスは`print`文でHTMLを出力する。

最初のWebアプリケーションは、どのように作られていたのか。この問いの答えは、`/cgi-bin/`ディレクトリの中にある。

---

## 2. CGIの誕生——「Webサーバと外部プログラムを繋ぐ」という設計判断

### 1993年のWeb——静的HTMLの限界

1993年、Webはまだ静的なHTMLドキュメントの集合体だった。Tim Berners-Leeが1989年にCERNで提案し、1991年に最初のWebサーバ（CERN httpd）とブラウザ（WorldWideWeb）を公開して以来、Webは学術文書の共有基盤として発展してきた。しかし、全てのページは事前に作成されたHTMLファイルであり、ユーザーのリクエストに応じて動的にコンテンツを生成する仕組みは存在しなかった。

この制約を打ち破ったのが、NCSA（National Center for Supercomputing Applications）のRob McCoolである。

McCoolはイリノイ大学アーバナ・シャンペーン校の学部生であり、NCSA HTTPd——最初期のWebサーバの一つ——の開発者だった。同じNCSAで開発されていたMosaicブラウザ（Marc AndreessenとEric Binaが1993年1月にアルファ版を公開、同年4月にバージョン1.0をリリース）とともに、NCSA HTTPdはWebの爆発的普及を支えた。

### www-talkメーリングリストでの議論

1993年、McCoolはwww-talkメーリングリストにおいて、「Webサーバが外部プログラムを実行し、その出力をHTTPレスポンスとして返す」仕組みの仕様策定を主導した。当時のWebサーバはNCSA HTTPdだけではなかった。Tim Berners-LeeのCERN httpd、Tony SandersのPlexusサーバなど、複数のサーバが並立していた。各サーバで独自の仕組みを作るのではなく、共通の仕様を定めようというのがMcCoolの提案だった。

1993年12月4日までに、McCoolはCGI仕様をHTMLドキュメントとしてまとめ、NCSAのサーバ（hoohoo.ncsa.uiuc.edu/cgi/）で公開した。他のWebサーバ開発者がこれを採用し、CGIはWebの事実上の標準となった。

このとき下された設計判断の本質は、「Webサーバと外部プログラムの分離」である。Webサーバ自体には動的コンテンツ生成の機能を組み込まない。代わりに、任意の外部プログラムを呼び出すためのインターフェースを定める。このアプローチには、深い設計思想がある。

第一に、言語非依存性。CGIは外部プログラムの実装言語を規定しない。C、Perl、Python、シェルスクリプト——標準入出力と環境変数を扱えるプログラムであれば何でもよい。これはUNIX哲学の「一つのことをうまくやる」「テキストストリームを共通インターフェースとする」の直接的な体現だった。

第二に、プロセス分離によるセキュリティと安定性。CGIスクリプトはWebサーバとは独立したプロセスとして動作する。スクリプトがクラッシュしても、Webサーバ本体は影響を受けない。これは後のコンテナ化やマイクロサービスの思想に通じる「障害の局所化」の原型である。

### McCoolの退場とApacheの誕生

1994年中頃、McCoolはNCSAを離れ、Netscape Communications Corporationに移籍した。NCSA HTTPdの開発は停滞する。しかし、このWebサーバは既に多くのサイトで使われており、管理者たちは独自にバグ修正やパッチを開発していた。

Brian BehlendorfがこれらのパッチをApacheの起源として集約し、1995年4月にApache HTTP Server 0.6.2を公開した。「a patchy server」——パッチの集合体——という名前の由来がそれを物語る。Apache 1.0は1995年12月1日にリリースされ、1年以内にNCSA HTTPdを抜いて最も使用されるWebサーバとなった。

McCoolが策定したCGI仕様は、彼が去った後も、Apacheを通じてWebの基盤であり続けた。個人の仕事が公共のインフラになる——オープンソースの本質がここにある。

### 11年後の正式仕様化

CGIが正式にRFCとして文書化されたのは、誕生から11年後のことである。1997年11月にKen Coarを中心とするワーキンググループが発足し、NCSAの定義をより厳密に文書化する作業を開始した。その成果がRFC 3875——「The Common Gateway Interface (CGI) Version 1.1」——であり、2004年10月に公開された。著者はD. RobinsonとK. Coar（The Apache Software Foundation）。

11年間、CGIは正式な規格なしに事実上の標準として機能し続けた。仕様書が公開される前に、実装が世界を変えていた。この事実は、Webという技術の性格をよく表している。完璧な仕様を作ってから実装するのではなく、動くものを作って公開し、使われながら仕様が固まっていく。後にRoy FieldingがREST（Representational State Transfer）をHTTPの既存の慣行から事後的に抽出した博士論文（2000年）にも、同じパターンが見える。

---

## 3. CGIの仕組み——プロセスフォーク、環境変数、標準入出力

CGIの仕組みを理解するには、UNIXのプロセスモデルを理解する必要がある。CGIはWeb固有の技術ではない。UNIXが持っていたプロセス間通信の仕組みを、Webサーバと外部プログラムの連携に転用したものだ。

### リクエストの流れ——全体像

ブラウザからCGIスクリプトにリクエストが届き、レスポンスが返るまでの全体像を示す。

```
クライアント（ブラウザ）
    │
    │  HTTP Request
    │  GET /cgi-bin/hello.pl?name=Yusuke HTTP/1.1
    │  Host: example.com
    │
    ▼
┌───────────────────────────────────────────────┐
│  Apache HTTP Server (httpd)                   │
│                                               │
│  1. リクエストを受信                            │
│  2. URLが /cgi-bin/ 以下であることを検出         │
│  3. ScriptAlias で指定されたディレクトリから      │
│     該当するスクリプトファイルを特定              │
│  4. fork() でプロセスを生成                     │
│  5. 環境変数を設定                              │
│  6. exec() でスクリプトを起動                   │
└───────────┬───────────────────────────────────┘
            │ fork() + exec()
            │
            ▼
┌───────────────────────────────────────────────┐
│  CGIスクリプト (hello.pl)                      │
│  [新しいプロセスとして起動]                      │
│                                               │
│  環境変数から読み取り:                           │
│    REQUEST_METHOD = "GET"                     │
│    QUERY_STRING   = "name=Yusuke"             │
│    SERVER_NAME    = "example.com"             │
│    SCRIPT_NAME    = "/cgi-bin/hello.pl"       │
│                                               │
│  標準出力に書き込み:                             │
│    Content-type: text/html                    │
│    (空行)                                      │
│    <html><body>Hello, Yusuke!</body></html>   │
│                                               │
│  → プロセス終了                                 │
└───────────┬───────────────────────────────────┘
            │ 標準出力 → HTTPレスポンスボディ
            ▼
┌───────────────────────────────────────────────┐
│  Apache HTTP Server                           │
│                                               │
│  7. スクリプトの標準出力を受け取る               │
│  8. HTTPレスポンスとしてクライアントに返す        │
└───────────┬───────────────────────────────────┘
            │
            │  HTTP Response
            │  HTTP/1.1 200 OK
            │  Content-type: text/html
            │  ...
            │
            ▼
クライアント（ブラウザ）
```

この図から明らかなように、CGIの本質は「UNIXのプロセス間通信をHTTPに適用した」ことにある。fork/exec、環境変数、標準入出力——これらはすべて、UNIXが1970年代から持っていた仕組みだ。Rob McCoolの慧眼は、新しいプロトコルや仕組みを発明するのではなく、既存のUNIXの仕組みをWebに転用したことにある。

### 環境変数——リクエスト情報の受け渡し

CGIスクリプトは、HTTPリクエストの情報を環境変数から受け取る。RFC 3875で定義されたメタ変数は17種類ある。主要なものを以下に示す。

| 環境変数        | 内容                                   | 例                                |
| --------------- | -------------------------------------- | --------------------------------- |
| REQUEST_METHOD  | HTTPメソッド                           | GET, POST, PUT, DELETE            |
| QUERY_STRING    | URLの`?`以降のクエリ文字列             | name=Yusuke&age=52                |
| CONTENT_LENGTH  | リクエストボディのバイト数（POST時）   | 42                                |
| CONTENT_TYPE    | リクエストボディのMIMEタイプ（POST時） | application/x-www-form-urlencoded |
| PATH_INFO       | スクリプトパス以降の追加パス情報       | /users/123                        |
| SCRIPT_NAME     | CGIスクリプト自体のパス                | /cgi-bin/app.pl                   |
| SERVER_NAME     | サーバのホスト名                       | example.com                       |
| SERVER_PORT     | サーバのポート番号                     | 80                                |
| SERVER_PROTOCOL | リクエストのプロトコルとバージョン     | HTTP/1.1                          |
| REMOTE_ADDR     | クライアントのIPアドレス               | 192.168.1.100                     |
| HTTP_USER_AGENT | ブラウザの識別情報                     | Mozilla/5.0 ...                   |
| HTTP_COOKIE     | クライアントから送信されたcookie       | session_id=abc123                 |

この設計は極めてシンプルだが、制約もある。環境変数は文字列しか扱えない。HTTPヘッダの複雑な構造（例えば、`Accept`ヘッダの品質値付きリスト）は、文字列として渡された後にスクリプト側でパースする必要がある。後のJava Servlet APIが`HttpServletRequest`というオブジェクトでリクエスト情報を構造化したのは、この環境変数方式の制約を克服するためだった。

### GETとPOST——2つのデータ受け渡し方式

CGIにおいて、クライアントからサーバにデータを送る方法は大きく2つある。

**GETリクエスト**の場合、データはURLのクエリ文字列として送られる。Webサーバは`QUERY_STRING`環境変数にこの文字列を格納し、CGIスクリプトはそれを読み取る。

```perl
# GETリクエストでのデータ受け取り（手動パース）
my $query = $ENV{'QUERY_STRING'};      # "name=Yusuke&age=52"
my %params;
for my $pair (split(/&/, $query)) {
    my ($key, $value) = split(/=/, $pair);
    $value =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;  # URLデコード
    $params{$key} = $value;
}
print "Name: $params{'name'}\n";       # "Name: Yusuke"
```

**POSTリクエスト**の場合、データはHTTPリクエストのボディとして送られる。CGIスクリプトは標準入力（STDIN）からデータを読み取る。何バイト読み取るかは`CONTENT_LENGTH`環境変数で判断する。

```perl
# POSTリクエストでのデータ受け取り（手動パース）
my $length = $ENV{'CONTENT_LENGTH'};
my $body;
read(STDIN, $body, $length);            # 標準入力から指定バイト数を読む
# $body は "name=Yusuke&message=Hello" のような文字列
```

この2つの方式の違いは、今日のWeb開発でも本質的に変わっていない。ExpressのリクエストオブジェクトにGETパラメータが`req.query`として、POSTボディが`req.body`として分離されているのは、CGI時代の`QUERY_STRING`と`STDIN`の区別をそのまま引き継いでいる。

### 標準出力——レスポンスの生成

CGIスクリプトのレスポンスは、標準出力（STDOUT）に書き込まれる。最初にHTTPヘッダを出力し、空行を挟んでから、レスポンスボディを出力する。

```perl
#!/usr/bin/perl
# 最もシンプルなCGIスクリプト

# 1. HTTPヘッダ（Content-typeは必須）
print "Content-type: text/html\n";

# 2. 空行（ヘッダとボディの区切り）
print "\n";

# 3. レスポンスボディ
print "<html>\n";
print "<head><title>Hello CGI</title></head>\n";
print "<body>\n";
print "<h1>Hello, World!</h1>\n";
print "<p>This page was generated by a CGI script.</p>\n";
print "<p>Server time: " . localtime() . "</p>\n";
print "</body>\n";
print "</html>\n";
```

「ヘッダ → 空行 → ボディ」という構造は、HTTPレスポンスそのものの構造と同じだ。CGIスクリプトはHTTPレスポンスの「中身」を直接組み立てている。Webサーバは、スクリプトの出力に`HTTP/1.1 200 OK`などのステータス行を付加してクライアントに返す。

ここに、CGIの設計の巧みさがある。CGIスクリプトはHTTPプロトコルの全てを知る必要はない。Content-typeヘッダを出力し、空行を挟み、コンテンツを出力するだけでよい。プロトコルの複雑さはWebサーバ側が吸収する。だがスクリプトは、自分が出力しているものがHTTPレスポンスの一部であることを意識できる。完全な隠蔽ではなく、適度な抽象化。これが、CGIが「学びやすく、理解しやすい」技術であった理由だ。

### プロセスモデル——毎回の起動と終了

CGIの最も重要な特性であり、最大の制約でもあるのが、リクエストごとに新しいプロセスを起動するモデルだ。

```
リクエスト1 → fork() → [Perlインタプリタ起動] → [スクリプト実行] → [出力] → プロセス終了
リクエスト2 → fork() → [Perlインタプリタ起動] → [スクリプト実行] → [出力] → プロセス終了
リクエスト3 → fork() → [Perlインタプリタ起動] → [スクリプト実行] → [出力] → プロセス終了
```

1回のリクエストを処理するために、以下の処理が毎回発生する。

1. **fork()**: Webサーバプロセスのコピーを作成する
2. **exec()**: 子プロセスでCGIスクリプト（またはインタプリタ）を起動する
3. **インタプリタの初期化**: Perlの場合、Perlインタプリタの起動とモジュールの読み込み
4. **スクリプトのコンパイル**: ソースコードのバイトコードへの変換
5. **実行**: 実際のビジネスロジックの処理
6. **出力**: 標準出力への書き込み
7. **終了**: プロセスの破棄

このうち、実際に「有用な仕事」をしているのはステップ5と6だけだ。残りはすべてオーバーヘッドである。特にPerlやPythonのようなインタプリタ言語の場合、ステップ3と4の比重が大きい。単純な「Hello, World!」を返すスクリプトでも、Perlインタプリタの起動と`use CGI;`によるモジュール読み込みに数十ミリ秒を要する。秒間100リクエストが来れば、100回のfork/execが発生し、100回Perlインタプリタが起動し、100回モジュールが読み込まれる。

この非効率さが、後にmod_perl（1996年、Doug MacEachern）やFastCGI（1996年、Open Market社）といった解決策を生み出した。mod_perlはPerlインタプリタをApacheのプロセスに組み込み、FastCGIはCGIスクリプトを常駐プロセスとして動作させた。どちらも「プロセスの起動コストを削減する」という同じ問いに対する異なる解である。これらは第3回で詳しく取り上げる。

だが、CGIのプロセスモデルには無視できない利点もあった。

**障害の局所化**: スクリプトがメモリリークやクラッシュを起こしても、そのプロセスは次のリクエストとは無関係に終了する。常駐プロセスモデルでは、一つのリクエストの処理で破壊されたメモリ状態が次のリクエストに影響しうる。

**リソースの自動解放**: プロセスが終了すれば、ファイルディスクリプタ、メモリ、ネットワーク接続はOSによって自動的に回収される。リソースリークが原理的に発生しない。

**シンプルなプログラミングモデル**: 「リクエストを受けて、処理して、出力して、終了する」——これ以上にシンプルなプログラミングモデルはない。グローバル変数の汚染も、スレッドセーフの考慮も必要ない。

後にPHPが採用した「shared-nothing」アーキテクチャ——リクエストごとに状態をリセットし、共有状態を持たない——は、CGIのプロセスモデルの利点を言語レベルで継承したものだ。

---

## 3.5 CGIが強制した「ステートレス」——見えない設計判断

CGIのプロセスモデルは、もう一つの重大な帰結をもたらした。ステートレス性の強制である。

HTTPプロトコル自体がステートレスに設計されている。各リクエストは独立しており、サーバは前のリクエストの情報を保持しない。だが、CGIはこのステートレス性を物理的に体現した。リクエストが終わればプロセスごと消える。変数も消える。ファイルハンドルも消える。メモリ上のすべてが消える。状態を持ちたくても、持てない。

これは、今日のWeb開発者が当然のように使っている「セッション」という概念がまだ存在しなかった時代の話だ。

ユーザーがログインしたことを「覚えて」おくには、どうすればよいか。CGIスクリプトは次のリクエストでは別のプロセスとして起動されるから、変数に記憶しても無駄だ。

解決策は3つあった。

**1. Hidden フィールド**: HTMLフォームに`<input type="hidden" name="session" value="abc123">`を埋め込み、フォーム送信のたびにセッション情報をクライアントからサーバに送り返す。画面遷移がすべてフォーム送信に依存するという制約がある。

**2. URLリライティング**: `http://example.com/cgi-bin/app.pl?sid=abc123`のように、全てのURLにセッションIDを付加する。リンクの生成時にセッションIDを埋め込む必要があり、漏洩リスクもある。

**3. Cookie**: 1994年にNetscapeのLou Montulliが発明した仕組み。HTTPレスポンスヘッダの`Set-Cookie`でブラウザにデータを保存させ、以降のリクエストで自動的に送信させる。CGIスクリプトは`HTTP_COOKIE`環境変数からcookieを読み取れる。

```perl
# Cookieの設定（レスポンスヘッダで送信）
print "Set-Cookie: session_id=abc123; path=/\n";
print "Content-type: text/html\n\n";

# Cookieの読み取り（次のリクエストで）
my $cookie = $ENV{'HTTP_COOKIE'};    # "session_id=abc123"
```

Cookieの発明は、CGIが強制したステートレス制約に対する最初の体系的な解決策だった。Montulliが1995年に特許を出願し（US Patent 5,774,670、1998年認可）、1997年にIETF標準となったこの仕組みは、今日に至るまでWebの状態管理の基盤である。

興味深いのは、cookieが「ステートレスなHTTPにステートフルな振る舞いを実現する」という問題を、プロトコルレベルで変更するのではなく、ヘッダの追加という最小限の拡張で解決したことだ。既存のものを壊さずに機能を追加する——この設計思想は、Web技術の進化に繰り返し現れるパターンである。

---

## 4. ハンズオン——Apache + Perl CGIの環境をDockerで構築する

ここからは手を動かそう。1990年代後半のCGI環境を、2026年のDocker上に再現する。実際にCGIスクリプトを書き、リクエストが環境変数と標準入出力を通じて処理される様子を体験する。

### 環境構築

Docker環境でApache HTTP ServerとPerlをセットアップする。

```bash
# Debian/Apache/Perl環境を構築
docker run -it --rm -p 8080:80 --name cgi-lab debian:bookworm-slim bash
```

コンテナ内で以下を実行する。

```bash
# 必要なパッケージをインストール
apt-get update && apt-get install -y apache2 perl curl

# CGIモジュールを有効化
a2enmod cgi

# cgi-binディレクトリの確認
ls -la /usr/lib/cgi-bin/

# Apacheを起動
apachectl start
```

### 演習1: 最初のCGIスクリプト——Hello, World!

最もシンプルなCGIスクリプトを書く。

```bash
cat > /usr/lib/cgi-bin/hello.pl << 'SCRIPT'
#!/usr/bin/perl
print "Content-type: text/html\n\n";
print "<html><body>\n";
print "<h1>Hello from CGI!</h1>\n";
print "<p>This page was generated by a Perl CGI script.</p>\n";
print "<p>Server time: " . localtime() . "</p>\n";
print "</body></html>\n";
SCRIPT

chmod 755 /usr/lib/cgi-bin/hello.pl
```

アクセスしてみる。

```bash
curl http://localhost/cgi-bin/hello.pl
```

出力される。

```html
<html><body>
<h1>Hello from CGI!</h1>
<p>This page was generated by a Perl CGI script.</p>
<p>Server time: Fri Mar 21 10:00:00 2026</p>
</body></html>
```

ここで起きていることを整理する。curlがHTTPリクエストを送信し、ApacheがURLの`/cgi-bin/`プレフィックスを検出し、`/usr/lib/cgi-bin/hello.pl`を新しいプロセスとして起動し、そのスクリプトの標準出力をHTTPレスポンスのボディとしてクライアントに返した。

`chmod 755`を忘れたら、Apacheは「Permission denied」でスクリプトを実行できず、500エラーを返す。2001年に私が繰り返し遭遇したあのエラーだ。

### 演習2: 環境変数の可視化——CGIが受け取る情報の全貌

CGIスクリプトが受け取る環境変数をすべて表示するスクリプトを書く。

```bash
cat > /usr/lib/cgi-bin/env.pl << 'SCRIPT'
#!/usr/bin/perl
print "Content-type: text/html\n\n";
print "<html><body>\n";
print "<h1>CGI Environment Variables</h1>\n";
print "<table border='1'>\n";
print "<tr><th>Variable</th><th>Value</th></tr>\n";

# CGI関連の環境変数のみを表示
my @cgi_vars = qw(
    REQUEST_METHOD QUERY_STRING CONTENT_LENGTH CONTENT_TYPE
    PATH_INFO SCRIPT_NAME SERVER_NAME SERVER_PORT SERVER_PROTOCOL
    REMOTE_ADDR REMOTE_HOST GATEWAY_INTERFACE
    HTTP_USER_AGENT HTTP_ACCEPT HTTP_HOST HTTP_COOKIE
);

for my $var (@cgi_vars) {
    my $val = $ENV{$var} // "(not set)";
    print "<tr><td>$var</td><td>$val</td></tr>\n";
}

print "</table>\n";
print "</body></html>\n";
SCRIPT

chmod 755 /usr/lib/cgi-bin/env.pl
```

様々なパラメータでアクセスしてみる。

```bash
# 基本的なGETリクエスト
curl http://localhost/cgi-bin/env.pl

# クエリ文字列付き
curl "http://localhost/cgi-bin/env.pl?name=Yusuke&role=engineer"

# PATH_INFOを含むアクセス
curl http://localhost/cgi-bin/env.pl/extra/path/info

# カスタムUser-Agentを指定
curl -H "User-Agent: MyCustomBrowser/1.0" http://localhost/cgi-bin/env.pl
```

クエリ文字列付きのリクエストでは、`QUERY_STRING`に`name=Yusuke&role=engineer`が設定される。`/cgi-bin/env.pl/extra/path/info`でアクセスすると、`SCRIPT_NAME`は`/cgi-bin/env.pl`、`PATH_INFO`は`/extra/path/info`となる。CGIの仕様は、スクリプトのパスとそれ以降の追加パス情報を明確に分離している。

この`PATH_INFO`の仕組みは、後にPHPの`index.php/controller/action`パターンや、Railsの`/users/123`のようなRESTfulルーティングの原型となった。

### 演習3: フォーム処理——GETとPOSTの違い

HTMLフォームからデータを受け取るCGIスクリプトを書く。

```bash
# フォームを表示する静的HTMLを作成
cat > /var/www/html/form.html << 'HTML'
<html>
<head><title>CGI Form Example</title></head>
<body>
<h1>CGI Form Example</h1>

<h2>GET Method</h2>
<form action="/cgi-bin/form.pl" method="GET">
  <label>Name: <input type="text" name="name"></label><br>
  <label>Message: <input type="text" name="message"></label><br>
  <input type="submit" value="Send (GET)">
</form>

<h2>POST Method</h2>
<form action="/cgi-bin/form.pl" method="POST">
  <label>Name: <input type="text" name="name"></label><br>
  <label>Message: <input type="text" name="message"></label><br>
  <input type="submit" value="Send (POST)">
</form>
</body>
</html>
HTML
```

```bash
# フォームデータを処理するCGIスクリプト
cat > /usr/lib/cgi-bin/form.pl << 'SCRIPT'
#!/usr/bin/perl
use strict;
use warnings;

my %params;
my $method = $ENV{'REQUEST_METHOD'};

if ($method eq 'GET') {
    # GETの場合: QUERY_STRINGから読み取り
    my $query = $ENV{'QUERY_STRING'} || '';
    for my $pair (split(/&/, $query)) {
        my ($key, $value) = split(/=/, $pair, 2);
        $value //= '';
        $value =~ s/\+/ /g;
        $value =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        $params{$key} = $value;
    }
} elsif ($method eq 'POST') {
    # POSTの場合: STDINから読み取り
    my $length = $ENV{'CONTENT_LENGTH'} || 0;
    my $body = '';
    read(STDIN, $body, $length);
    for my $pair (split(/&/, $body)) {
        my ($key, $value) = split(/=/, $pair, 2);
        $value //= '';
        $value =~ s/\+/ /g;
        $value =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        $params{$key} = $value;
    }
}

# レスポンスを生成
print "Content-type: text/html\n\n";
print "<html><body>\n";
print "<h1>Form Result</h1>\n";
print "<p>Method: $method</p>\n";
print "<p>Name: $params{'name'}</p>\n" if $params{'name'};
print "<p>Message: $params{'message'}</p>\n" if $params{'message'};
print "<hr>\n";
print "<a href='/form.html'>Back to form</a>\n";
print "</body></html>\n";
SCRIPT

chmod 755 /usr/lib/cgi-bin/form.pl
```

curlでGETとPOSTの両方をテストする。

```bash
# GETリクエスト
curl "http://localhost/cgi-bin/form.pl?name=Yusuke&message=Hello+CGI"

# POSTリクエスト
curl -X POST http://localhost/cgi-bin/form.pl \
  -d "name=Yusuke&message=Hello+CGI"
```

GETの場合、データは`QUERY_STRING`環境変数から取得される。POSTの場合、データは`STDIN`から`CONTENT_LENGTH`バイト分読み取られる。外から見れば結果は同じだが、データの流れるパスが全く異なる。このスクリプトでは、`CGI.pm`を使わずに手動でURLデコードとパラメータ解析を行っている。`CGI.pm`の`param()`メソッドがやっていることの本質がここにある。

### 演習4: CGIで簡易カウンター——ステートレスの壁

CGIのステートレス性を体感するために、アクセスカウンターを実装する。

```bash
cat > /usr/lib/cgi-bin/counter.pl << 'SCRIPT'
#!/usr/bin/perl
use strict;
use warnings;
use Fcntl qw(:flock);

my $count_file = '/tmp/cgi_counter.dat';

# ファイルロックを使ってカウンターを更新
open(my $fh, '+>>', $count_file) or die "Cannot open: $!";
flock($fh, LOCK_EX) or die "Cannot lock: $!";

# ファイル先頭に移動して読み込み
seek($fh, 0, 0);
my $count = <$fh> || 0;
chomp $count;
$count++;

# ファイルを書き戻す
seek($fh, 0, 0);
truncate($fh, 0);
print $fh "$count\n";
close($fh);

# レスポンス
print "Content-type: text/html\n\n";
print "<html><body>\n";
print "<h1>Access Counter</h1>\n";
print "<p>You are visitor number: <strong>$count</strong></p>\n";
print "<p>Process ID: $$</p>\n";
print "<p>Each request runs in a new process.</p>\n";
print "<p>The counter persists because it is stored in a file,</p>\n";
print "<p>not in memory (which is destroyed when the process ends).</p>\n";
print "</body></html>\n";
SCRIPT

chmod 755 /usr/lib/cgi-bin/counter.pl
```

```bash
# 3回アクセスしてカウンターとプロセスIDの変化を確認
curl http://localhost/cgi-bin/counter.pl
curl http://localhost/cgi-bin/counter.pl
curl http://localhost/cgi-bin/counter.pl
```

3回のアクセスで、カウンターは1、2、3と増えるが、プロセスID（`$$`）は毎回異なる値を示す。これがCGIのプロセスモデルだ。プロセスは毎回新しく作られ、毎回消える。状態をプロセス内に保持することはできない。

カウンターの値がリクエストをまたいで保持されるのは、ファイルシステムという外部ストレージに保存しているからだ。`flock`によるファイルロックは、複数のCGIプロセスが同時にカウンターファイルにアクセスしたときのデータ競合を防ぐための仕組みである。この「外部ストレージに状態を保存する」パターンは、後のRedisやMemcachedによるセッション管理、さらにはデータベースベースのセッションストアへと受け継がれていく。

### 何が見えたか

このハンズオンで体験したことは、以下のことを物語っている。

CGIスクリプトが受け取るのは環境変数と標準入力だけであり、返すのは標準出力だけだ。これ以上に透明なインターフェースはない。何が起きているかが、すべて目に見える。Express.jsの`req.query.name`は便利だ。だが、その裏で`QUERY_STRING`相当の文字列が解析されていることを知っているかどうかで、問題が起きたときの対処能力が変わる。

---

## 5. まとめと次回予告

### この回の要点

第2回では、CGIの誕生から仕組み、そしてその帰結としてのステートレス性を掘り下げた。要点を整理する。

CGIは1993年、NCSAのRob McCoolがwww-talkメーリングリストでの議論を主導して策定した。その本質的な設計判断は「Webサーバと外部プログラムの分離」であり、UNIXが持っていたプロセス間通信の仕組み——fork/exec、環境変数、標準入出力——をWebに転用したものだった。言語非依存性とプロセス分離によるセキュリティは、この設計がもたらした恩恵である。

CGIのプロセスモデル——リクエストごとにプロセスを起動し、処理が終われば破棄する——は、極めてシンプルだが、パフォーマンス上の致命的な弱点を持っていた。インタプリタの起動コスト、モジュールの読み込み、プロセスの生成と破棄。これらのオーバーヘッドは、同時接続数の増加とともに壊滅的な影響を及ぼした。

CGIは、HTTPのステートレス性を物理的に体現した。プロセスが終わればすべてが消える。この制約が、外部ファイルへの状態保存、hiddenフィールド、URLリライティング、そして1994年のLou MontulliによるCookieの発明へと繋がった。ステートレス性は制約であると同時に、Webのスケーラビリティの源泉でもある。

CGIは正式なRFC（RFC 3875）として文書化されるまでに11年を要した。仕様書よりも先に実装が世界を変えた。この「動くものが先、仕様は後」というパターンは、Webの進化に繰り返し現れる。

### 冒頭の問いに対する暫定回答

「最初のWebアプリケーションは、どのように作られていたのか」——答えは驚くほどシンプルだ。プログラムを書き、`/cgi-bin/`に置き、パーミッションを設定する。それだけで、そのプログラムはWebアプリケーションになった。

HTTPリクエストの情報は環境変数から受け取り、処理結果は標準出力に書き出す。入力と出力。UNIX哲学がそのまま、Webアプリケーションの原型になった。

CGIは原始的だ。リクエストのたびにプロセスを起動するのは明らかに非効率だ。だが、CGIは「HTTPリクエストを受けて処理を実行しレスポンスを返す」というWebアプリケーションの本質を、この上なく明快に体現していた。フレームワークが何千行、何万行のコードで実現していることの原型が、Perlスクリプトの`print`文と環境変数の読み取りの中にある。

### 次回予告

第3回「Webサーバの進化——Apache, mod_perl, FastCGI」では、CGIの「遅さ」をどう克服したかを追う。1996年に同時に現れた2つの解決策——PerlインタプリタをApacheに組み込むmod_perlと、CGIスクリプトを常駐プロセスとして動かすFastCGI——の設計思想を比較し、パフォーマンス問題の解決に常に複数のアプローチが存在することを示す。

「CGIの遅さをどう克服したか？ その試行錯誤の歴史は何を教えてくれるか？」——次回、この問いに向き合う。

---

## 参考文献

- Rob McCool, CGI仕様 (1993年、NCSA) — www-talkメーリングリストでの議論を経て策定。参考: <https://en.wikipedia.org/wiki/Common_Gateway_Interface>
- RFC 3875, "The Common Gateway Interface (CGI) Version 1.1", D. Robinson, K. Coar, 2004年10月 <https://www.rfc-editor.org/rfc/rfc3875>
- NCSA HTTPd — Rob McCoolがイリノイ大学で開発した最初期のWebサーバ。参考: <https://en.wikipedia.org/wiki/NCSA_HTTPd>
- Apache HTTP Server Project, "About Apache" <https://httpd.apache.org/ABOUT_APACHE.html>
- Larry Wall, Perl 1.0 (1987年12月18日リリース) <https://en.wikipedia.org/wiki/Perl>
- Lincoln Stein, "Official Guide to Programming with CGI.pm" (1998年、Wiley) — CGI.pmの作者による公式ガイド。参考: <https://en.wikipedia.org/wiki/CGI.pm>
- Lou Montulli, HTTP Cookie (1994年発明、Netscape Communications) <https://en.wikipedia.org/wiki/HTTP_cookie>
- NCSA Mosaic 2.0 (1993年11月10日) — HTMLフォームサポートの追加。参考: <https://en.wikipedia.org/wiki/NCSA_Mosaic>
- Apache HTTP Server Documentation, "Apache Tutorial: Dynamic Content with CGI" <https://httpd.apache.org/docs/2.4/howto/cgi.html>
- Cybercultural, "1993: CGI Scripts and Early Server-Side Web Programming" <https://cybercultural.com/p/1993-cgi-scripts-and-early-server-side-web-programming/>
