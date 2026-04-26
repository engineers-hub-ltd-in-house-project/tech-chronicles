# フレームワークという幻想

## ——Webアプリケーションの「当たり前」を疑う

### 第5回：Java Servlet/JSP——エンタープライズの重力

**連載「フレームワークという幻想——Webアプリケーションの『当たり前』を疑う」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Java Servlet APIはなぜ「HTTPリクエストの処理」をオブジェクト指向で抽象化したのか
- J2EEが企業システムの基盤に選ばれた技術的・ビジネス的理由とその代償
- web.xml、WAR、フィルタチェーンに埋め込まれた設計思想の読み解き方
- 素のServletでWebアプリケーションを構築し、CGI/PHPとの構造的な違いを体感する方法

---

## 1. web.xmlの200行に面食らった日

2004年の冬、私はあるエンタープライズ案件でJava Servlet/JSPのプロジェクトに初めて本格的に関わることになった。それまでの私の世界はPHPだった。前回書いたように、素のPHPでWebシステムを作り、`htmlspecialchars()` を忘れてXSSの脆弱性を埋め込み、痛い思いをしながらもなんとか動くものを作る——そういう開発が私の日常だった。

Java Servletの案件は、規模が違った。大手企業の社内業務システムで、開発チームは20人以上。私はPHPの経験を買われてWeb開発要員として参加したのだが、初日に渡されたプロジェクトの構成を見て面食らった。

まず、ディレクトリ構造が複雑だった。`src/main/java/` の下に何層にもわたるパッケージ。`WEB-INF/` の中に鎮座する `web.xml` は200行を超えていた。サーブレットのマッピング、フィルタの定義、セキュリティ制約、セッションタイムアウト——すべてがXMLで宣言的に記述されていた。

```xml
<servlet>
    <servlet-name>UserServlet</servlet-name>
    <servlet-class>com.example.servlet.UserServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>UserServlet</servlet-name>
    <url-pattern>/user/*</url-pattern>
</servlet-mapping>
<filter>
    <filter-name>AuthenticationFilter</filter-name>
    <filter-class>com.example.filter.AuthenticationFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>AuthenticationFilter</filter-name>
    <url-pattern>/admin/*</url-pattern>
</filter-mapping>
```

PHPなら `.htaccess` に数行書くか、あるいはスクリプトの先頭で `if` 文を書けば済む処理が、XMLの定義ファイルとJavaクラスに分離されている。「なぜこんなに回りくどいのだ」というのが正直な感想だった。

そしてデプロイだ。PHPならFTPでファイルをアップロードすれば即座に反映される。だがJavaでは、コンパイルし、WARファイル（Web Application Archive）にパッケージングし、Tomcatのwebappsディレクトリに配置し、Tomcatを再起動する。コードを1行修正するだけでも、この儀式を踏む必要があった。

Tomcatの設定ファイル `server.xml` もまた別の迷宮だった。Connector、Host、Context、Valve——聞き慣れない概念が並ぶ。ポート番号を変えるだけならまだしも、複数のWebアプリケーションを同一サーバで動かそうとすると、Contextの設定がたちまち複雑になる。

「なぜわざわざこんな面倒なことを？」——私はそう思った。PHPなら簡単にできることを、Javaはなぜこれほどまでに儀式的にするのか。

だが、プロジェクトが進むにつれて、その「面倒さ」の意味が見えてきた。20人の開発チームが同じコードベースで作業するとき、PHPの「自由さ」は混沌を生む。どのファイルがどのURLに対応するのか、認証チェックはどこで行われているのか、セッション管理はどうなっているのか——PHPではすべてが開発者個人の裁量に委ねられていた。だがJavaでは、`web.xml` という一つのファイルを見れば、アプリケーションの構造が一望できた。URLマッピング、フィルタチェーン、セキュリティ制約——すべてが宣言的に定義されている。

冗長さは、設計の意図だった。そしてその設計の意図は、私がPHPで経験したことのない「大規模開発」という現実から来ていた。

なぜ企業のWebシステムはJavaで作られたのか。そしてその選択は、果たして正しかったのか。第5回では、この問いに向き合う。

---

## 2. Javaがエンタープライズを制した理由——1997年からのServlet史

### Servlet APIの誕生——CGIへの回答

Java Servletの歴史は、CGIの限界への回答として始まった。

1995年、Javaの生みの親James GoslingがServletの概念を提案した。当時、WebのサーバサイドプログラミングはCGI（Common Gateway Interface）が主流だったが、CGIには根本的な問題があった。第2回で詳しく述べたように、CGIはHTTPリクエストごとに新しいプロセスを起動する。リクエストが100件来れば、100個のプロセスが起動する。これはサーバにとって重い負荷であり、大量のリクエストを処理する必要があるエンタープライズシステムには適さなかった。

Java Servletは、この問題に対するJava流の回答だった。Servletはプロセスではなくスレッドで動作する。JVM（Java Virtual Machine）という一つのプロセスの中で、各リクエストをスレッドとして処理する。プロセス起動のオーバーヘッドがないため、CGIと比較してはるかに高いスループットを実現できた。

1996年5月のJavaOneカンファレンスでServlet APIがデビューし、2カ月後にSun MicrosystemsがJeeves（後のJava Web Server）の一部として最初のアルファ版をリリースした。James Duncan Davidsonが仕様策定と参照実装の開発を主導し、1997年6月にServlet 1.0仕様が策定された。

```
【CGI vs Servlet：リクエスト処理モデルの比較】

CGI:
  リクエスト1 → [プロセス起動] → Perlインタプリタ → [処理] → [プロセス終了]
  リクエスト2 → [プロセス起動] → Perlインタプリタ → [処理] → [プロセス終了]
  リクエスト3 → [プロセス起動] → Perlインタプリタ → [処理] → [プロセス終了]
  ※ リクエストごとにプロセスを起動・終了

Servlet:
  JVMプロセス（常駐）
  ├── リクエスト1 → [スレッド1] → Servletインスタンス → [処理] → レスポンス
  ├── リクエスト2 → [スレッド2] → Servletインスタンス → [処理] → レスポンス
  └── リクエスト3 → [スレッド3] → Servletインスタンス → [処理] → レスポンス
  ※ 1つのJVMプロセス内でスレッドを使い回す
```

この設計の違いは、単なるパフォーマンスの差ではない。思想の違いだ。CGIは「リクエストごとに使い捨ての環境を作る」という思想であり、PHPのshared-nothingアーキテクチャもこの延長線上にある。一方Servletは「常駐するプロセスの中でリクエストを処理する」という思想だ。常駐するからこそ、データベースコネクションプールを保持できる。常駐するからこそ、初期化コストを一度だけ負担すれば済む。そして常駐するからこそ、メモリリークやスレッド安全性の問題と向き合わなければならない。

### JSPの登場——JavaのPHP化？

Servletの問題は、HTMLの生成が苦痛だったことだ。Javaコードの中にHTMLを文字列として埋め込む——これはCGIのPerl CGIと同じ苦行である。

```java
// Servletの中でHTMLを生成する苦行
out.println("<html>");
out.println("<head><title>ユーザー一覧</title></head>");
out.println("<body>");
out.println("<table>");
for (User user : users) {
    out.println("<tr><td>" + user.getName() + "</td></tr>");
}
out.println("</table>");
out.println("</body>");
out.println("</html>");
```

この問題を解決するために、Sun MicrosystemsはJSP（JavaServer Pages）を開発した。1998年にプレリリース版（0.92）が公開され、1999年6月にJSP 1.0がリリースされた。Larry CableとEduardo Pelegri-Llopartがリード開発者を務めた。

JSPの発想は、PHPやASPと同じだ。HTMLの中にJavaコードを埋め込む。

```jsp
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head><title>ユーザー一覧</title></head>
<body>
<table>
<% for (User user : users) { %>
    <tr><td><%= user.getName() %></td></tr>
<% } %>
</table>
</body>
</html>
```

見覚えのある構造だろう。PHPの `<?php ... ?>` がJSPの `<% ... %>` に変わっただけだ。実際、JSPの仕様策定にはBEA、Netscape、IBMなどが参加しており、PHP/ASPのテンプレート的アプローチを意識して設計されたことは間違いない。

だがJSPには、PHPとは決定的に異なる点がある。JSPは初回アクセス時にJavaのサーブレットクラスにコンパイルされる。つまり、テンプレートのように見えるが、実体はServletなのだ。この「コンパイル」というステップがあるため、JSPには型チェックが働く。PHPのように「変数名のタイポがそのまま実行時に空文字列になる」ということは起きない。

### J2EE——Javaがエンタープライズの言語になった瞬間

1999年12月12日、Sun Microsystemsは J2EE（Java 2 Platform, Enterprise Edition）1.2をリリースした。これは単なるライブラリの寄せ集めではない。エンタープライズアプリケーション開発のための統合プラットフォームだった。

J2EEは、Servlet、JSP、EJB（Enterprise JavaBeans）、JDBC、JMS（Java Message Service）、JNDI（Java Naming and Directory Interface）といった技術を一つの仕様の下に統合した。企業が求めるあらゆる機能——Webフロントエンド、ビジネスロジック、データベース接続、メッセージング、トランザクション管理、ディレクトリサービス——を、Javaだけで実現できる。

なぜ企業はJavaを選んだのか。理由はいくつかある。

第一に、型安全性だ。PHPやPerlは動的型付け言語であり、変数の型を間違えてもコンパイル時にはわからない。Javaは静的型付けであり、コンパイルの段階で多くのバグを検出できる。20人以上の開発チームで数十万行のコードを書くとき、この差は決定的だった。

第二に、JVMの安定性だ。JVMは「Write Once, Run Anywhere」という理念の下に設計されており、OSに依存しない実行環境を提供した。Solaris上で開発し、Linux上でテストし、Windows上でも動作する——このポータビリティは、異機種環境が混在する大企業にとって魅力的だった。

第三に、スレッドモデルだ。前述の通り、Java Servletはスレッドベースでリクエストを処理する。そしてJava言語自体がマルチスレッドプログラミングを言語仕様レベルでサポートしていた。`synchronized` キーワード、`Thread` クラス、`wait()`/`notify()` メカニズム——これらはJava 1.0から存在した。大量の同時リクエストを処理する必要があるエンタープライズシステムにとって、これは重要な要素だった。

第四に、そしておそらく最も大きな理由として、ベンダーサポートがあった。IBM（WebSphere）、BEA Systems（WebLogic）、Oracle（Oracle Application Server）、Sun Microsystems（iPlanet/Sun ONE）——主要なITベンダーがこぞってJ2EE準拠のアプリケーションサーバを販売した。企業のIT部門にとって、「IBMがサポートしている技術」という事実は、技術的な優劣以上に重要だった。問題が起きたときに電話できる先がある。SLA（Service Level Agreement）がある。PHPのコミュニティに問い合わせても、誰も責任を取ってくれない。だがIBMなら、契約に基づいてサポートを提供してくれる。

```
【J2EEのエコシステム（2000年代前半）】

┌─────────────────────────────────────────────────────┐
│                    J2EE仕様 (Sun Microsystems)       │
│  ┌──────────┬──────────┬──────────┬──────────┐      │
│  │ Servlet  │   JSP    │   EJB   │  JDBC    │      │
│  │  /JSP    │          │         │          │      │
│  ├──────────┼──────────┼──────────┼──────────┤      │
│  │   JMS    │   JNDI   │   JTA   │  JAAS    │      │
│  └──────────┴──────────┴──────────┴──────────┘      │
└─────────────────────────────────────────────────────┘
                         ↓ 実装
┌──────────────┬──────────────┬──────────────────────┐
│ IBM          │ BEA Systems  │ Sun Microsystems     │
│ WebSphere    │ WebLogic     │ iPlanet/Sun ONE      │
├──────────────┼──────────────┼──────────────────────┤
│ Oracle       │ JBoss        │ Apache               │
│ OC4J         │ (Red Hat)    │ Tomcat（Servlet/JSP）│
└──────────────┴──────────────┴──────────────────────┘
```

J2EEの世界は、PHPのそれとはまるで異なっていた。PHPは「個人が安価なレンタルサーバで動かす」言語だった。J2EEは「企業がライセンス料を支払ってアプリケーションサーバを購入し、専門のチームが運用する」プラットフォームだった。その差は、技術の差ではなく、文化の差だった。

### Strutsの登場——JavaにMVCを持ち込んだ男

J2EEが企業向けのプラットフォームとしての地位を確立しつつある中、JavaのWeb開発にはまだ重要なピースが欠けていた。Servlet/JSPはHTTPリクエストを処理する手段を提供したが、アプリケーション全体をどう構成するかについてはガイダンスを提供していなかった。

結果として、2000年前後のJava Web開発の現場には2つの問題が蔓延していた。

一つは「Model 1」と呼ばれるアーキテクチャの問題だ。JSPページがスタンドアロンで存在し、ビジネスロジックもデータベースアクセスもページ遷移も、すべてJSPの中に書かれる。PHPの素のスクリプトと同じ問題——ロジックとプレゼンテーションの混在——がJSPでも再現された。

もう一つは、Servletをコントローラとして使う「Model 2」アーキテクチャの実装が、プロジェクトごとにバラバラだったことだ。Sun MicrosystemsのJSP仕様でModel 2アーキテクチャが言及されていたが、それはあくまでアーキテクチャの概念であり、具体的なフレームワークではなかった。

Craig McClanahanは、この状況にフレームワークという回答を持ち込んだ。2000年5月、McClanahanが作成したStrutsがApache Foundationに寄贈された。2001年6月にStruts 1.0がリリースされると、Java Web開発の世界に急速に広まった。

Strutsは、JSPのModel 2アーキテクチャを具体的なフレームワークとして実装したものだ。ActionServletがフロントコントローラとして全リクエストを受け、`struts-config.xml` の設定に基づいて適切なActionクラスにディスパッチする。Actionクラスがビジネスロジックを実行し、結果をActionFormに格納し、JSPビューに転送する。

```
【Struts 1のリクエスト処理フロー】

ブラウザ
  │
  ▼
ActionServlet（フロントコントローラ）
  │
  │ struts-config.xml を参照
  │
  ▼
ActionMapping（URLとActionの対応定義）
  │
  ▼
Action（ビジネスロジック）
  │
  ├── ActionForm（リクエストパラメータの格納）
  │
  ▼
ActionForward（遷移先の定義）
  │
  ▼
JSP（ビュー）
  │
  ▼
ブラウザ
```

Strutsは2000年代前半のJava Web開発におけるデファクトスタンダードとなった。だがその成功は、皮肉にもJavaのWeb開発の「重さ」を象徴するものでもあった。`struts-config.xml` というまた別の設定ファイルが加わり、ActionFormという冗長なデータ転送クラスが必要になり、1つの画面を作るためにAction、ActionForm、JSP、そして設定ファイルへのエントリが必要になった。Strutsは後にStruts 1として区別されるようになり、2013年にEnd of Lifeを迎えた。

### EJBの悲劇とSpringの誕生

J2EEのエコシステムの中で、最も野心的で、最も批判を受けた技術がEJB（Enterprise JavaBeans）だった。

EJBの目的は崇高だった。ビジネスロジックをコンポーネント化し、トランザクション管理、セキュリティ、永続化、同時実行制御をコンテナに委譲する。開発者はビジネスロジックだけを書けばよい——という理想だ。

現実は違った。1つのEJBを作るために、コンポーネントインターフェース、ホームインターフェース、Bean実装クラスの3つのJavaファイルに加え、XMLデプロイメント記述子が必要だった。IBMやSun Microsystemsといった大手ベンダーが説得力を持って推進したこともあり、大企業はEJBを急速に採用した。だが問題はすぐに顕在化した。

EJBの初期バージョンではリモートメソッド呼び出しがCORBA経由で行われた。だが、大多数のエンタープライズアプリケーションは分散コンピューティングなど必要としていない。同一JVM内でビジネスロジックを呼び出しているだけなのに、CORBAのオーバーヘッドが課される。これはパフォーマンスの観点から明らかな無駄だった。

チェック例外の乱用、抽象クラスの強制、直感に反するAPIの設計——EJBはJava開発者の間で急速に評判を落とした。Martin Fowler、Rebecca Parsons、Josh MacKenzieは2000年9月に「POJO」（Plain Old Java Object）という用語を考案し、EJBのような重いフレームワークに頼らない、普通のJavaオブジェクトの価値を訴えた。

そしてこの流れの中から、Rod Johnsonが登場する。Johnsonは2002年11月に『Expert One-on-One J2EE Design and Development』を出版した。この書籍でJohnsonはJ2EEとEJBの問題点を体系的に指摘し、代替となる30,000行のフレームワークコードを書籍に付属させた。当初は「Interface21 framework」（com.interface21パッケージ名）と呼ばれていたこのコードに目を付けたのが、Juergen HoellerとYann Caroffだった。彼らはJohnsonを説得し、2003年2月にオープンソースプロジェクトとしての開発を開始した。

プロジェクトの名前は「Spring」——Yann Caroffが提案した。J2EEの「冬」の後に来る「春」という意味だ。2003年6月にApache 2.0ライセンスで初リリースされ、2004年3月にバージョン1.0がリリースされた。

Springの核心的なアイデアは、DI（Dependency Injection）とAOP（Aspect-Oriented Programming）だった。EJBが重いコンテナとXML記述子でやろうとしていたことを、SpringはPOJOと軽量なDIコンテナで実現した。Spring以前のJ2EEの世界は、EJBコンテナに「依存」することでトランザクション管理やセキュリティを実現していた。Springは、その依存関係を逆転させた——コンテナがオブジェクトに依存するのではなく、オブジェクトがコンテナから独立して存在し、必要な依存関係は外部から注入される。

この「依存関係の逆転」は、後にJavaのWeb開発を根本から変えることになる。だがそれは、第10回以降の話だ。

---

## 3. Servlet APIの設計思想——HTTPをオブジェクトにした男たち

### HttpServletRequest/HttpServletResponse——抽象化の力

Java Servlet APIの設計を理解することは、後のすべてのWebフレームワークの設計を理解する鍵になる。なぜなら、Servlet APIが導入した抽象化は、Express.jsのreq/resオブジェクト、DjangoのHttpRequest/HttpResponse、RailsのActionDispatch::Request/ActionDispatch::Responseに至るまで、あらゆるWebフレームワークの基礎となっているからだ。

CGIの世界では、HTTPリクエストは環境変数と標準入力として渡された。`QUERY_STRING`、`REQUEST_METHOD`、`CONTENT_TYPE`——これらは文字列だ。構造化されていない。何がリクエストヘッダで何がクエリパラメータなのかは、開発者が自分で解釈しなければならなかった。

Servlet APIは、HTTPリクエストとレスポンスをオブジェクトとして抽象化した。`HttpServletRequest` はHTTPリクエストのすべてを表現するオブジェクトであり、`HttpServletResponse` はHTTPレスポンスを構築するためのオブジェクトだ。

```java
public class UserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // リクエストからパラメータを取得
        String userId = request.getParameter("id");

        // リクエストヘッダの取得
        String userAgent = request.getHeader("User-Agent");

        // セッションの取得
        HttpSession session = request.getSession();

        // レスポンスの設定
        response.setContentType("text/html; charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_OK);

        // レスポンスボディの書き込み
        PrintWriter out = response.getWriter();
        out.println("<html><body>");
        out.println("<h1>User: " + userId + "</h1>");
        out.println("</body></html>");
    }
}
```

ここで注目すべきは、HTTPメソッドに対応するメソッドの分離だ。`doGet()` はGETリクエスト、`doPost()` はPOSTリクエスト、`doPut()` はPUTリクエスト——HTTP仕様の構造がそのままJavaのメソッドに対応している。CGIやPHPでは、`$_SERVER['REQUEST_METHOD']` を自分で判別してif文で分岐していた処理が、オブジェクト指向の継承とメソッドオーバーライドで構造化された。

この設計の含意は深い。CGI/PHPのモデルでは、「リクエストを処理するスクリプト」はただのスクリプトだった。Servletのモデルでは、「リクエストを処理するオブジェクト」はクラスのインスタンスだ。クラスであるということは、継承ができる。共通の認証処理を持つ `AuthenticatedServlet` を作り、それを継承して個別のServletを実装する、といったことが型安全に行える。

```
【CGI/PHP vs Servlet：HTTPリクエスト処理の抽象化レベル】

CGI:
  環境変数（文字列）
  ├── QUERY_STRING="id=123&name=test"    ← 自分でパースする
  ├── REQUEST_METHOD="GET"                ← 自分でif文で分岐
  ├── HTTP_USER_AGENT="Mozilla/5.0..."    ← 自分で参照
  └── 標準入力（POSTボディ）              ← 自分で読み取る

PHP:
  スーパーグローバル変数（連想配列）
  ├── $_GET['id']                          ← パース済み
  ├── $_POST['name']                       ← パース済み
  ├── $_SERVER['REQUEST_METHOD']           ← 自分でif文で分岐
  └── $_SESSION['user']                    ← セッション管理込み

Servlet:
  HttpServletRequest（オブジェクト）
  ├── request.getParameter("id")           ← パース済み
  ├── request.getHeader("User-Agent")      ← 型付きアクセス
  ├── doGet() / doPost()                   ← メソッドで分離
  └── request.getSession()                 ← セッション管理込み
```

PHPのスーパーグローバル変数（`$_GET`、`$_POST`、`$_SERVER`）は、CGIの環境変数と標準入力を連想配列として再パッケージしたものだ。Servletの `HttpServletRequest` は、それをさらにオブジェクトとして型安全にカプセル化した。この3段階の抽象化は、「HTTPリクエストをどう扱うか」という問いに対する、それぞれの時代と言語文化の回答だ。

### web.xml——宣言的設定という思想

web.xmlは、Java Servlet開発において最も賛否が分かれる存在だった。そして、最も重要な設計思想を体現する存在でもあった。

PHPのWebアプリケーションでは、設定はコードの中に散在している。データベース接続情報は `config.php` というファイルに書かれ、URLのルーティングは `.htaccess` とファイルのディレクトリ構造で決まり、認証チェックは各スクリプトの先頭で `include('auth.php')` する。アプリケーション全体の設定が一箇所にまとまっていない。

web.xmlは、アプリケーションの構成を一箇所に宣言的に記述する思想だ。「宣言的」とは、「何をしたいか」を記述し、「どうやるか」はフレームワーク（サーブレットコンテナ）に委ねるということだ。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         version="3.1">

    <!-- サーブレット定義 -->
    <servlet>
        <servlet-name>UserServlet</servlet-name>
        <servlet-class>com.example.servlet.UserServlet</servlet-class>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>UserServlet</servlet-name>
        <url-pattern>/users/*</url-pattern>
    </servlet-mapping>

    <!-- フィルタ定義 -->
    <filter>
        <filter-name>EncodingFilter</filter-name>
        <filter-class>com.example.filter.EncodingFilter</filter-class>
        <init-param>
            <param-name>encoding</param-name>
            <param-value>UTF-8</param-value>
        </init-param>
    </filter>
    <filter-mapping>
        <filter-name>EncodingFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>

    <!-- セキュリティ制約 -->
    <security-constraint>
        <web-resource-collection>
            <web-resource-name>Admin Area</web-resource-name>
            <url-pattern>/admin/*</url-pattern>
        </web-resource-collection>
        <auth-constraint>
            <role-name>admin</role-name>
        </auth-constraint>
    </security-constraint>

    <!-- セッション設定 -->
    <session-config>
        <session-timeout>30</session-timeout>
    </session-config>

    <!-- エラーページ -->
    <error-page>
        <error-code>404</error-code>
        <location>/WEB-INF/error/404.jsp</location>
    </error-page>
</web-app>
```

このファイルを見るだけで、アプリケーションの構造が読み取れる。どのURLがどのサーブレットに対応しているか、どのフィルタがどの順序で適用されるか、どのURLパターンに認証が必要か、セッションのタイムアウトは何分か——すべてが一望できる。

web.xmlの冗長さは、設計上の意図だ。20人の開発チームが同じアプリケーションを開発するとき、「URLのルーティングはどこを見ればわかるのか」という問いに対して、web.xmlは常に同じ答えを返す。PHPの世界では、ルーティングの仕組みがプロジェクトごとに異なっていた。`.htaccess` でやるプロジェクト、フロントコントローラパターンで自前実装するプロジェクト、ディレクトリ構造に依存するプロジェクト——統一された規約がなかった。web.xmlは、その統一を強制したのだ。

もちろん、代償もあった。Servlet 3.0（2009年、Java EE 6の一部）でアノテーション `@WebServlet("/users/*")` が導入されるまで、すべてのサーブレットマッピングをXMLで記述しなければならなかった。サーブレットが50個あれば、web.xmlには100行以上のマッピング記述が並ぶ。これは明らかに冗長であり、DRY（Don't Repeat Yourself）原則に反していた。

だが忘れてはならない。web.xmlが設計された1990年代後半には、「アノテーション」という概念はJavaに存在しなかった。Javaにアノテーションが導入されたのはJava 5（2004年）である。web.xmlの冗長さは、当時の技術的制約の中での合理的な設計判断だったのだ。

### フィルタチェーン——ミドルウェアパターンの原型

Servlet 2.3（2001年、JSR 53で策定）で導入されたフィルタAPIは、後のWebフレームワークにおけるミドルウェアパターンの直接的な原型だ。

フィルタは、Chain of Responsibilityパターンに基づくリクエスト/レスポンスの逐次処理機構である。各フィルタは、リクエストを検査し、必要に応じて加工し、次のフィルタに渡す。全フィルタを通過した後、リクエストは最終的なサーブレットに到達する。レスポンスは逆順にフィルタを通過して戻る。

```java
public class LoggingFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        long start = System.currentTimeMillis();

        // 前処理：リクエストのログ出力
        HttpServletRequest req = (HttpServletRequest) request;
        System.out.println("[REQUEST] " + req.getMethod()
                + " " + req.getRequestURI());

        // 次のフィルタ（またはサーブレット）に処理を委譲
        chain.doFilter(request, response);

        // 後処理：レスポンスタイムのログ出力
        long elapsed = System.currentTimeMillis() - start;
        System.out.println("[RESPONSE] " + elapsed + "ms");
    }
}
```

```
【Servlet フィルタチェーンの処理フロー】

リクエスト →
  ┌─────────────────────────────────────────────────────┐
  │ FilterChain                                         │
  │                                                     │
  │  Filter 1        Filter 2        Filter 3           │
  │ (Encoding)  →  (Logging)   →  (Auth)     → Servlet │
  │  前処理          前処理          前処理      処理    │
  │                                                     │
  │  Filter 1   ←   Filter 2   ←   Filter 3            │
  │  後処理          後処理          後処理              │
  └─────────────────────────────────────────────────────┘
                                                 → レスポンス
```

この構造を見て、Node.jsのExpressを知っている読者は気づくだろう。Expressのミドルウェアパターンは、Servlet Filterのチェーン構造とほぼ同じだ。

```javascript
// Express.jsのミドルウェア（2010年〜）
app.use((req, res, next) => {
    console.log(`[REQUEST] ${req.method} ${req.url}`);
    const start = Date.now();
    next(); // chain.doFilter() に相当
    console.log(`[RESPONSE] ${Date.now() - start}ms`);
});
```

Servlet Filterの `chain.doFilter()` がExpressの `next()` に、Servlet Filterの `doFilter(request, response, chain)` シグネチャがExpressの `(req, res, next)` に対応している。これは偶然ではない。Expressの作者TJ HolowaychukがServletのフィルタチェーンを直接参照したかどうかは定かではないが、リクエスト処理パイプラインを連鎖的に構成するというアイデアは、Servlet Filterが2001年に確立した設計パターンだ。

同様に、Spring SecurityのセキュリティフィルタチェーンもServlet Filterの上に構築されている。DjangoのミドルウェアもRackのミドルウェアも、本質的には同じパターンだ。リクエストとレスポンスを、前処理と後処理の連鎖として処理する——このアイデアは、Servlet APIが体系化した遺産の一つである。

### WARファイル——デプロイメントの標準化と重さ

Java Servletのデプロイメントモデルは、WAR（Web Application Archive）ファイルによる標準化されたパッケージングだった。

WARファイルは、ZIPフォーマットに基づくアーカイブで、サーブレット、JSP、HTML、CSS、画像、JARライブラリ、そして `WEB-INF/web.xml` を一つのファイルにまとめる。

```
myapp.war
├── index.html
├── css/
│   └── style.css
├── js/
│   └── app.js
├── WEB-INF/
│   ├── web.xml                    ← デプロイメント記述子
│   ├── classes/
│   │   └── com/example/
│   │       └── servlet/
│   │           └── UserServlet.class
│   └── lib/
│       ├── mysql-connector-java.jar
│       └── commons-lang3.jar
└── META-INF/
    └── MANIFEST.MF
```

このモデルの利点は明確だ。アプリケーションに必要なものがすべて一つのファイルに含まれているため、デプロイが確実になる。「このサーバにはライブラリが入っていなかった」「設定ファイルを転送し忘れた」といった問題が構造的に排除される。

EAR（Enterprise Application Archive）はさらに上位のパッケージングで、複数のWARファイルとEJBを含むJARファイルを一つにまとめる。大規模なエンタープライズシステムでは、Webフロントエンド（WAR）とビジネスロジック（EJB JAR）が別々のモジュールとして開発され、EARとしてデプロイされた。

だがこのデプロイメントモデルには、PHPの世界からは信じがたいほどの重さがあった。PHPなら、ファイルをFTPでアップロードすれば即座に反映される。Javaでは、ソースコードのコンパイル→WARのビルド→アプリケーションサーバへのデプロイ→コンテキストのリロードというプロセスを踏まなければならない。開発中にコードを1行修正するたびにこの儀式を繰り返すのは、苦行以外の何物でもなかった。

この苦行は、2014年のSpring Bootまで、Javaの Web開発者たちの宿命だった。Spring Bootは組み込みTomcatと自動設定により、WARファイルを作ることなく、`java -jar myapp.jar` という一つのコマンドでWebアプリケーションを起動できるようにした。web.xmlもWARデプロイも不要にした——Servlet時代の「重い儀式」からの解放だった。

---

## 4. ハンズオン：素のServletでWebアプリケーションを作る

ここまでの議論を、実際に手を動かして体感しよう。素のJava Servletを使ってWebアプリケーションを構築し、CGI/PHPとの構造的な違いを確かめる。

### 演習環境

Docker上のUbuntu 24.04環境で、Apache Tomcat 10とJDK 21を使用する。フレームワークは一切使わない。

### 演習1：最小のServletを書く

まず、HTTPリクエストを受け取り、レスポンスを返すだけの最小のServletを作る。

```bash
# 作業ディレクトリの作成
mkdir -p ~/servlet-handson/WEB-INF/classes

# 最小のServletを作成
cat > ~/servlet-handson/WEB-INF/classes/HelloServlet.java << 'JAVA'
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class HelloServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Hello Servlet</title></head>");
        out.println("<body>");
        out.println("<h1>Hello from Java Servlet</h1>");
        out.println("<p>Method: " + request.getMethod() + "</p>");
        out.println("<p>URI: " + request.getRequestURI() + "</p>");
        out.println("<p>Query: " + request.getQueryString() + "</p>");
        out.println("<p>User-Agent: "
                + request.getHeader("User-Agent") + "</p>");
        out.println("</body></html>");
    }
}
JAVA
```

CGIスクリプトと比較してほしい。CGIでは `print "Content-type: text/html\n\n"` でレスポンスヘッダを自分で書いていた。Servletでは `response.setContentType("text/html; charset=UTF-8")` というメソッド呼び出しだ。環境変数 `QUERY_STRING` を自分でパースしていたのが、`request.getParameter("name")` というメソッド呼び出しになった。HTTPの低レベルな詳細がオブジェクトのメソッドに隠蔽されている——これが「抽象化」の意味だ。

### 演習2：web.xmlでURLマッピングを定義する

次に、web.xmlを作成してURLとServletの対応を定義する。

```bash
cat > ~/servlet-handson/WEB-INF/web.xml << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee
           https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">

    <servlet>
        <servlet-name>hello</servlet-name>
        <servlet-class>HelloServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>hello</servlet-name>
        <url-pattern>/hello</url-pattern>
    </servlet-mapping>

    <servlet>
        <servlet-name>user</servlet-name>
        <servlet-class>UserServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>user</servlet-name>
        <url-pattern>/users/*</url-pattern>
    </servlet-mapping>
</web-app>
XML
```

PHPでは、`/hello.php` というURLは `hello.php` というファイルに直接対応していた。Servletでは、URLとクラスの対応はweb.xmlで明示的に定義する。この「間接的なマッピング」が冗長に感じるかもしれない。だが、この間接性こそが、URLの構造とコードの構造を独立させる鍵だ。URLを変更したいとき、PHPではファイル名を変更しなければならない。Servletでは、web.xmlのurl-patternを変更するだけで済む。

### 演習3：フィルタチェーンを実装する

フィルタチェーンを実装し、リクエスト処理パイプラインを体験する。

```bash
cat > ~/servlet-handson/WEB-INF/classes/LoggingFilter.java << 'JAVA'
import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;

public class LoggingFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("[LoggingFilter] initialized");
    }

    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        long start = System.currentTimeMillis();

        System.out.println("[LOG] >>> " + req.getMethod()
                + " " + req.getRequestURI());

        // 次のフィルタまたはサーブレットに処理を委譲
        chain.doFilter(request, response);

        long elapsed = System.currentTimeMillis() - start;
        System.out.println("[LOG] <<< " + elapsed + "ms");
    }

    @Override
    public void destroy() {
        System.out.println("[LoggingFilter] destroyed");
    }
}
JAVA
```

web.xmlにフィルタの定義を追加する。

```xml
<!-- web.xml に追加 -->
<filter>
    <filter-name>logging</filter-name>
    <filter-class>LoggingFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>logging</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

`chain.doFilter(request, response)` ——この1行が、フィルタチェーンの核心だ。この呼び出しの前が「前処理」、後が「後処理」になる。これは、Express.jsの `next()` 呼び出しと構造的に同一だ。2001年にServlet仕様で確立されたこのパターンが、2010年のExpressに引き継がれ、2020年代の現代に至るまでWebフレームワークの基本パターンであり続けている。

### 演習4：Dockerで動かす

上記の演習をDocker環境で実際に動かす。

```bash
# Dockerfileを作成
cat > ~/servlet-handson/Dockerfile << 'DOCKERFILE'
FROM eclipse-temurin:21-jdk AS builder

# Tomcat 10のダウンロードと展開
RUN apt-get update && apt-get install -y wget && \
    wget -q https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.39/bin/apache-tomcat-10.1.39.tar.gz && \
    tar xzf apache-tomcat-10.1.39.tar.gz && \
    mv apache-tomcat-10.1.39 /opt/tomcat

# サーブレットのコンパイル
WORKDIR /build
COPY WEB-INF/classes/*.java ./
RUN javac -cp /opt/tomcat/lib/servlet-api.jar -d ./classes *.java

FROM eclipse-temurin:21-jre

COPY --from=builder /opt/tomcat /opt/tomcat
COPY --from=builder /build/classes /opt/tomcat/webapps/handson/WEB-INF/classes
COPY WEB-INF/web.xml /opt/tomcat/webapps/handson/WEB-INF/web.xml

EXPOSE 8080
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
DOCKERFILE

# ビルドと起動
cd ~/servlet-handson
docker build -t servlet-handson .
docker run -d -p 8080:8080 --name servlet-handson servlet-handson

# アクセステスト
sleep 5
curl -s http://localhost:8080/handson/hello
curl -s http://localhost:8080/handson/hello?name=World

# Tomcatのログでフィルタの動作を確認
docker logs servlet-handson | grep '\[LOG\]'

# 後片付け
docker stop servlet-handson && docker rm servlet-handson
```

Tomcatのログに `[LOG] >>> GET /handson/hello` と `[LOG] <<< Xms` が出力されるはずだ。これが、フィルタチェーンが実際に動作している証拠だ。

ここで考えてほしい。PHPでは、`echo "Hello World"` と書いたファイルをサーバに置けば、それだけでWebアプリケーションが動く。Servletでは、Javaソースコードを書き、コンパイルし、web.xmlを定義し、WARを構成し、Tomcatにデプロイする。この重さは、何のためにあるのか。

答えは、スケーラビリティと保守性だ。5ページの個人サイトなら、PHPの方が圧倒的に効率がいい。だが500画面の業務システムを20人で開発し、10年間保守するとなると、話は変わる。web.xmlによる一元的な設定管理、フィルタチェーンによる横断的関心事の分離、型安全なクラス設計——これらの「重い儀式」は、大規模開発の複雑さを管理するための構造なのだ。

---

## 5. エンタープライズの重力が残したもの

### この回の要点

第5回では、Java Servlet/JSPからJ2EE、Struts、そしてSpring Frameworkに至るまでのJavaのWeb開発史を辿り、「エンタープライズの重力」の正体を明らかにした。

1995年にJames GoslingがServletの概念を提案し、1997年にJames Duncan DavidsonがServlet 1.0仕様を策定した。1999年にはJSP 1.0とJ2EE 1.2が相次いでリリースされ、Javaはエンタープライズ Web開発のプラットフォームとしての地位を確立した。2000年にCraig McClanahanがStrutsをApacheに寄贈し、Java Web開発に初めてMVCフレームワークの標準を持ち込んだ。

Servlet APIが導入した `HttpServletRequest`/`HttpServletResponse` というHTTPリクエストのオブジェクト指向的抽象化は、後のすべてのWebフレームワークの設計に影響を与えた。web.xmlによる宣言的設定は冗長だったが、大規模開発における設定の一元管理という要求に応えるものだった。Servlet Filterのチェーンパターンは、Express.jsのミドルウェアやSpring Securityのフィルタチェーンの直接的な原型である。

一方で、EJBに象徴されるJ2EEの過度な複雑さは、開発者の反発を招いた。Rod Johnsonは2002年の著書でJ2EEの問題点を体系的に指摘し、その代替として2003年にSpring Frameworkを誕生させた。SpringはEJBの「冬」の後に来る「春」を意味し、POJOベースの軽量なDIコンテナとして、Java Web開発の方向を決定的に変えた。

### 冒頭の問いに対する暫定回答

「なぜ企業のWebシステムはJavaで作られたのか？ その選択は正しかったのか？」

企業がJavaを選んだ理由は明確だ。型安全性、JVMのポータビリティ、スレッドベースの並行処理モデル、そして何より大手ベンダーによるサポート体制。IBMやBEAが数百万円のライセンス料とともに提供するSLAは、PHPのオープンソースコミュニティには存在しなかった。企業のIT部門にとって「問題が起きたときに電話できる先がある」という安心感は、技術的優劣以上に重要だった。

その選択は正しかったのか。答えは「部分的に正しかった」だ。Servlet APIの設計、フィルタチェーンの概念、宣言的設定の思想——これらは今日のWebフレームワークに脈々と受け継がれている。EJBの失敗からSpringが生まれ、web.xmlの冗長さからアノテーションベースの設定が生まれた。過ちもまた、技術の進化を駆動した。

だが代償もあった。Javaのエンタープライズ開発は「重い」という烙印を押され、Web開発の民主化という点ではPHPに大きく後れを取った。そしてその「重さ」への反動として、2004年にRuby on Railsが登場し、「Convention over Configuration」という真逆の思想がWeb開発の潮流を変えることになる。

あなたが今使っているWebフレームワークの中には、Servlet APIの設計思想が静かに息づいている。`req`/`res` オブジェクト、ミドルウェアチェーン、ルーティング定義——これらはすべて、1997年のServlet仕様に端を発する概念だ。フレームワークが隠蔽しているものの裏に、30年近い設計の蓄積がある。その蓄積を知ることは、無駄だろうか。

### 次回予告

第6回「ASP/ColdFusion——選ばれなかった主流」では、Web開発の歴史で忘れられた技術を取り上げる。MicrosoftのASP Classic、Allaire CorporationのColdFusion——かつて主流だったこれらの技術は、なぜPHPやJavaに敗北したのか。そしてASP.NET WebFormsの「ステートフルなWeb開発」という実験は、LiveViewやHTMXといった現代の技術にどうつながるのか。「負けた」技術にも、後の技術に受け継がれたアイデアがある。歴史を学ぶとは、勝者だけを追うことではない。

---

## 参考文献

- Eclipse Foundation, "Jakarta EE: Servlets and Tomcat — 23 Years and Counting" <https://www.eclipse.org/community/eclipse_newsletter/2020/february/3.php>
- Jakarta Servlet Wikipedia <https://en.wikipedia.org/wiki/Jakarta_Servlet>
- Jakarta Server Pages Wikipedia <https://en.wikipedia.org/wiki/Jakarta_Server_Pages>
- InformIT, "A Brief History of JSP" <https://www.informit.com/articles/article.aspx?p=31072&seqNum=5>
- Apache Tomcat Heritage <https://tomcat.apache.org/heritage.html>
- Apache Tomcat Wikipedia <https://en.wikipedia.org/wiki/Apache_Tomcat>
- Baeldung, "Java EE vs J2EE vs Jakarta EE" <https://www.baeldung.com/java-enterprise-evolution>
- Jakarta EE Wikipedia <https://en.wikipedia.org/wiki/Jakarta_EE>
- Apache Struts 1 Wikipedia <https://en.wikipedia.org/wiki/Apache_Struts_1>
- Spring.io Blog, "Spring Framework: The Origins of a Project and a Name" <https://spring.io/blog/2006/11/09/spring-framework-the-origins-of-a-project-and-a-name/>
- Spring Framework Wikipedia <https://en.wikipedia.org/wiki/Spring_Framework>
- Jakarta Enterprise Beans Wikipedia <https://en.wikipedia.org/wiki/Jakarta_Enterprise_Beans>
- Oracle, "The Essentials of Filters" <https://www.oracle.com/java/technologies/filters.html>
- WAR (file format) Wikipedia <https://en.wikipedia.org/wiki/WAR_(file_format)>
- Baeldung, "Difference Between WAR and EAR Files" <https://www.baeldung.com/war-vs-ear-files>
