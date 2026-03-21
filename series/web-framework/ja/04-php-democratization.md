# フレームワークという幻想

## ——Webアプリケーションの「当たり前」を疑う

### 第4回：PHP——Webの民主化とその代償

**連載「フレームワークという幻想——Webアプリケーションの『当たり前』を疑う」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- PHPはなぜ「テンプレート言語」として生まれ、なぜWebを席巻したのか
- shared-nothingアーキテクチャの合理性と、CGIの思想との連続性
- register_globalsに象徴されるPHPセキュリティ問題の構造的原因
- 素のPHPでWebアプリケーションを構築し、フレームワークが隠蔽しているものを体感する方法

---

## 1. htmlspecialcharsを忘れた日

2002年の秋、私は素のPHPで社内向けのWebシステムを開発していた。フレームワークなど使っていない。というより、当時のPHPの世界にはまだ「フレームワーク」という概念が根付いていなかった。CakePHPの登場は2005年、Laravelに至っては2011年のことだ。私がやっていたのは、HTMLの中にPHPコードを埋め込み、MySQLにクエリを投げ、結果をテーブルに表示する——それだけだった。

テストは書いていない。というより、PHPのコードにテストを書くという発想自体が、当時の私にはなかった。PHPUnitの最初のリリースは2004年で、それすらまだ先の話だ。

ある日、上司から連絡が入った。「検索フォームに変な文字を入れたらページのレイアウトが崩れる」。確認すると、検索キーワードのフィールドにHTMLタグが入力されており、そのままページに出力されていた。`<script>alert('test')</script>` ——クロスサイトスクリプティング（XSS）の典型的な脆弱性だった。

原因は単純だ。ユーザーの入力値を `echo` でそのまま出力していた。`htmlspecialchars()` でエスケープするという、今では初歩中の初歩とされる対策を、私は怠っていた。

```php
<!-- 脆弱なコード -->
<p>検索結果: <?php echo $_GET['q']; ?></p>

<!-- 修正後 -->
<p>検索結果: <?php echo htmlspecialchars($_GET['q'], ENT_QUOTES, 'UTF-8'); ?></p>
```

たった1つの関数呼び出しの欠如が、セキュリティホールになる。そしてPHPは、この関数を呼び忘れることを許す言語だった。テンプレートエンジンのように自動エスケープしてくれるわけではない。出力のたびに開発者が自分でエスケープしなければならない。100箇所の出力があれば、100回 `htmlspecialchars()` を書く。1箇所でも忘れれば、そこが脆弱性になる。

このとき私は、PHPという言語の本質的な特徴——「簡単に書けるが、安全に書くのは簡単ではない」——を身をもって学んだ。

なぜPHPはこれほどまでにWebを席巻し、そしてなぜ嫌われたのか。第4回では、この問いに向き合う。

---

## 2. 「Personal Home Page Tools」——テンプレート言語として生まれた言語

### Rasmus Lerdorfの「個人的な問題解決」

PHPの起源は、驚くほど個人的なものだった。

1994年、デンマーク系カナダ人のプログラマRasmus Lerdorfは、自分のオンライン履歴書へのアクセスを追跡するために、C言語でCGIバイナリのセットを書いた。彼はこれを「Personal Home Page Tools」——略してPHP Toolsと名付けた。

1995年6月8日、LerdorfはUsenetのcomp.infosystems.www.authoring.cgiグループに「Personal Home Page Tools (PHP Tools) version 1.0」のリリースを告知した。この時点でPHPは、CGIスクリプトのためのユーティリティライブラリとテンプレートエンジンに過ぎなかった。

1995年9月、LerdorfはPHPを拡張し、一時的にFI（Forms Interpreter）と改名した。フォーム処理機能が追加され、HTMLフォームからのデータを扱えるようになった。そして1995年10月、LerdorfはコードをPHP/FIとして完全に書き直した。

ここで注目すべきは、PHPの出自である。PHPは「プログラミング言語を作ろう」という動機から生まれたのではない。「HTMLの中にちょっとした動的処理を埋め込みたい」という、きわめて実用的な動機から生まれた。この出自が、PHPのその後の30年を決定づけることになる。

### `<?php ?>` ——HTMLに埋め込む言語という設計

PHPの最も根源的な設計判断は、`<?php ?>` タグによるHTMLとの混在にある。

```php
<html>
<body>
  <h1>こんにちは、<?php echo $name; ?>さん</h1>
  <p>今日は <?php echo date('Y年m月d日'); ?> です。</p>

  <?php if ($is_member): ?>
    <p>会員限定コンテンツ</p>
  <?php else: ?>
    <p>ログインしてください</p>
  <?php endif; ?>
</body>
</html>
```

このコードを見て何を思うだろうか。Perl CGIの経験がある開発者なら、衝撃を受けたはずだ。第2回で見たように、CGIでは `print "Content-type: text/html\n\n"` と書き、HTMLを文字列としてprint文で出力しなければならなかった。HTMLの中にプログラムを埋め込むのではなく、プログラムの中からHTMLを出力する——CGIとはそういうものだった。

PHPはこの関係を逆転させた。HTMLが主で、PHPが従。HTMLファイルの中に、必要な箇所だけPHPコードを挿入する。HTMLを知っている人間なら、PHPの基本的な構文を覚えるだけで動的なWebページを作れる。

```
CGI（Perl）のモデル:
┌──────────────────────────────────────┐
│  プログラム（Perl）                    │
│                                      │
│  #!/usr/bin/perl                     │
│  print "Content-type: text/html\n\n";│
│  print "<html>";                     │
│  print "<body>";                     │
│  print "<h1>Hello, $name</h1>";      │  ← HTMLはプログラムの出力
│  print "</body>";                    │
│  print "</html>";                    │
└──────────────────────────────────────┘

PHPのモデル:
┌──────────────────────────────────────┐
│  HTML文書                             │
│                                      │
│  <html>                              │
│  <body>                              │
│  <h1>Hello, <?php echo $name; ?></h1>│  ← プログラムはHTMLの中に埋め込む
│  </body>                             │
│  </html>                             │
└──────────────────────────────────────┘
```

この設計が意味したのは、「プログラミング未経験のWebデザイナーでもPHPを扱える」ということだ。HTMLを書ける人間は当時すでに大量にいた。彼らにとって、`<?php echo $variable; ?>` は、新しいHTMLタグを覚える程度のハードルだった。

### PHP 3——「本物の言語」への転換

Lerdorfの個人プロジェクトだったPHPに転機が訪れたのは1997年のことだ。イスラエル・テルアビブの大学生だったZeev SuraskiとAndi Gutmansが、eコマースアプリケーションの開発でPHP/FI 2.0を使おうとした。しかし、性能が不十分で機能も足りなかった。

2人はパーサを完全に書き直す決断を下した。そして1998年6月、PHP 3.0が公式にリリースされた。PHP 3は、Lerdorfの個人ツールを「本物のプログラミング言語」に変えた転換点だった。拡張モジュールの仕組みが導入され、データベース、プロトコル、APIへのアクセスが容易になった。複数の開発者がモジュールを書いて機能を追加できるようになったのだ。

PHP 3のリリースから間もなく、SuraskiとGutmansはさらにPHPの内部エンジンを書き直し始めた。このエンジンは2人の名前——ZeevとAndi——を組み合わせて「Zend Engine」と名付けられた。Zend Engine 1.0を搭載したPHP 4.0は2000年5月22日にリリースされた。

### PHPのバージョン史——30年の進化

PHPの進化を時系列で追うと、その変遷は「テンプレート言語」から「本格的プログラミング言語」への長い旅路であることがわかる。

```
PHPバージョン史（主要マイルストーン）

1995年  PHP/FI 1.0 ─── Rasmus Lerdorfの個人ツール
  │                    CGIバイナリ + テンプレート
  │
1998年  PHP 3.0 ─────── Suraski & Gutmansによる完全書き直し
  │                    「本物の言語」への転換
  │
2000年  PHP 4.0 ─────── Zend Engine 1.0
  │                    出力バッファリング、セッション管理
  │                    ★ register_globals デフォルト有効
  │
2002年  PHP 4.2.0 ───── register_globals デフォルト無効化
  │                    セキュリティ意識の転換点
  │
2004年  PHP 5.0 ─────── Zend Engine 2.0、本格的OOP
  │                    例外処理、イテレータ、PDO
  │
2005年  --------─────── CakePHP登場（PHP初のMVCフレームワーク）
  │
2010年  --------─────── PHP 6（Unicode対応）断念
  │                    PHP 5.3.3にPHP-FPMマージ
  │
2012年  PHP 5.4.0 ───── register_globals完全削除
  │                    トレイト、短縮配列構文、ビルトインWebサーバ
  │
2015年  PHP 7.0 ─────── Zend Engine 3（phpng）
  │                    PHP 5.6比で約2倍の性能向上
  │                    ★ バージョン6はスキップ
  │
2020年  PHP 8.0 ─────── JITコンパイラ
  │                    名前付き引数、アトリビュート、Union型
  │
2026年  現在 ──────────  W3Techs調査でサーバサイド言語シェア75%以上
                        WordPress（全Webサイトの約43%）が牽引
```

ここで特筆すべきは、PHP 6が存在しないことだ。2005年にUnicode（UTF-16内部表現）への全面対応を目指してPHP 6の開発が始まったが、UTF-16がWeb文脈ではほとんど使われないこと、パフォーマンスの問題、開発者の不足により、2010年3月に公式に断念された。非Unicode機能はPHP 5.4に取り込まれ、次のメジャーバージョンは2014年のコミュニティ投票（賛成58、反対24）でPHP 7とすることが決まった。PHP 6の書籍が既に出版されていたことも、混乱回避の理由だった。

---

## 3. なぜPHPはWebを席巻したのか——「Webの民主化」の構造

### レンタルサーバという配布チャネル

PHPの普及を語る上で避けて通れないのが、レンタルサーバ（共有ホスティング）という配布チャネルの存在である。

2000年代初頭、Webサイトをインターネットに公開する最も一般的な方法は、レンタルサーバを借りることだった。月額数百円から数千円で、FTPでファイルをアップロードすればWebサイトが公開できる。そしてこれらのレンタルサーバには、ほぼ例外なくApache + PHP + MySQLが事前にインストールされていた。

なぜか。PHPの実行モデルが、共有ホスティングと相性が極めてよかったからだ。

第3回で解説したmod_phpを思い出してほしい。PHPインタプリタはApacheのモジュールとして組み込まれ、CGI比で3〜5倍の性能向上を実現した。ホスティング事業者にとっては、1台のサーバで多数のユーザーを収容できることを意味する。ユーザーにとっては、`.php` ファイルをFTPでアップロードするだけで、サーバ設定を一切触らずに動的なWebサイトが動く。

JavaのServletを動かすにはTomcatを設定しなければならない。PerlのCGIを動かすにはcgi-binのパーミッションを理解しなければならない。RubyやPythonのWebアプリケーションをデプロイするには、サーバのプロセス管理を知らなければならない。PHPは、それらすべてを不要にした。FTPで`.php`ファイルを置く。それだけでよかった。

```
Webアプリケーションのデプロイ比較（2000年代初頭）

Java (Servlet/JSP):
  1. JDKをインストール
  2. Tomcatをインストール・設定
  3. web.xmlを書く
  4. WARファイルにパッケージング
  5. Tomcatにデプロイ
  → 専用サーバまたはVPSが必要

Perl (CGI):
  1. スクリプトをcgi-binに配置
  2. パーミッションを755に設定
  3. シバン行（#!/usr/bin/perl）を確認
  4. モジュールのインストール（CPAN）
  → パーミッション管理の知識が必要

PHP:
  1. .phpファイルをFTPでアップロード
  → 以上
```

この圧倒的な手軽さが、PHPの普及を駆動した。プログラミングの専門教育を受けていないWebデザイナーでも、HTMLにPHPタグを埋め込むだけで動的なWebサイトを作れた。「Webの民主化」とは、まさにこの現象を指す。

### shared-nothingアーキテクチャ——CGIの思想を洗練させた設計

PHPの技術的な設計で最も重要なのは、shared-nothingアーキテクチャである。

PHPはデフォルトでshared-nothingアーキテクチャを採用する唯一の主要言語だ。その意味を理解するために、PHPのリクエスト処理モデルを見てみよう。

```
PHPのリクエスト処理モデル（shared-nothing）

リクエスト1:
┌──────────────────────────────────────────────┐
│ HTTPリクエスト受信                             │
│     ↓                                        │
│ PHPランタイム起動（モジュール初期化）            │
│     ↓                                        │
│ .phpファイル読み込み・パース・実行               │
│     ↓                                        │
│ 変数確保、DB接続、クエリ実行、HTML生成           │
│     ↓                                        │
│ HTTPレスポンス送信                             │
│     ↓                                        │
│ ★ 全ての変数・状態を破棄                       │
└──────────────────────────────────────────────┘

リクエスト2:
┌──────────────────────────────────────────────┐
│ HTTPリクエスト受信                             │
│     ↓                                        │
│ PHPランタイム起動（完全にクリーンな状態）        │
│     ↓                                        │
│ .phpファイル読み込み・パース・実行               │
│     ↓                                        │
│ ...（リクエスト1の状態は一切残っていない）        │
└──────────────────────────────────────────────┘
```

各リクエストは完全に独立している。リクエスト1で確保したメモリ、接続したデータベースハンドル、設定した変数——すべてはリクエストの完了とともに破棄される。リクエスト2は、リクエスト1が存在したことすら知らない。

この設計は、第2回で見たCGIの「リクエストごとにプロセスを起動し、処理が終わったら終了する」モデルの直系である。CGIはプロセスレベルで状態を分離していたが、PHPはそれをランタイムレベルに洗練させた。mod_phpやPHP-FPMでは、プロセス自体は再利用されるが、PHPコードの実行環境（変数、オブジェクト、接続）はリクエストごとにリセットされる。

この設計がもたらす利点は明白だ。

第一に、メモリリークの影響が限定的である。リクエストごとに状態がリセットされるため、コードにメモリリークがあっても、そのリクエストの処理が終われば解放される。長時間稼働するアプリケーションサーバで問題になるメモリリークが、PHPではほとんど致命的にならない。

第二に、水平スケーリングが容易である。各リクエストが独立しているため、ロードバランサーの背後にPHPサーバを増やせば、ほぼ線形にスループットが向上する。リクエスト間で状態を共有しないから、サーバ間の同期を考える必要がない。

第三に、デプロイが単純である。新しいコードをサーバに配置するだけでよい。次のリクエストから新しいコードが実行される。アプリケーションサーバの再起動は不要だ。

一方、代償もある。リクエストごとにフレームワークの初期化、設定の読み込み、データベース接続の確立が必要になる。この「ブートストラップコスト」は、リクエスト数が増えると無視できなくなる。後年のPHP 7で性能が劇的に改善されたのは、このブートストラップの最適化が大きな要因だった。

### WordPressという爆発的触媒

PHPの普及を語る上で、WordPressの存在は避けて通れない。

2003年5月27日、Matt MullenwegとMike Littleは、開発が停止していたb2/cafelogというPHP製ブログソフトウェアをフォークして、WordPressの最初のバージョンをリリースした。Mullenwegは同年1月24日のブログ投稿でフォーク構想を表明し、Littleが最初にコメントで参加を表明した。

WordPressの成功は、PHPの設計思想と完全に調和していた。`.php`ファイルをアップロードすればインストールできる手軽さ。共有ホスティングで動く低い動作要件。HTMLとPHPの混在によるテーマのカスタマイズのしやすさ。PHPの「民主的な」設計が、WordPressという「民主的な」CMSを可能にし、WordPressの爆発的普及がPHPのシェアを押し上げた。

W3Techsの2026年1月時点の調査によると、全Webサイトの約43%がWordPressで運営されている。そしてサーバサイドプログラミング言語が検出可能なWebサイトの75%以上がPHPを使用している。この数字の裏には、WordPressというキラーアプリケーションの存在がある。

---

## 4. PHPの代償——「簡単に書ける」の裏側

### register_globals——自動変数展開という地雷

PHPの「簡単さ」がセキュリティ上の災厄をもたらした象徴的な例が、register_globalsである。

register_globalsは、HTTPリクエストのGET/POST/COOKIEパラメータを、自動的にPHPのグローバル変数として展開する機能だった。

```php
// URL: example.com/page.php?admin=1

// register_globals = On の場合
// $admin は自動的に "1" に設定される

if ($admin) {
    // 管理者向け処理
    show_admin_panel();
}
```

このコードの恐ろしさがわかるだろうか。URLのクエリパラメータに `?admin=1` を追加するだけで、`$admin` 変数が自動的に設定され、管理者パネルにアクセスできてしまう。変数の初期化を怠ったコードは、外部から任意の変数を注入される危険にさらされた。

register_globalsは、PHPの「簡単さ」の帰結だった。変数の宣言を不要にし、外部からの入力を直接変数として使えるようにした。初心者にとっては直感的だった。だが、その「直感的さ」は、セキュリティの根本原則——「外部入力は信頼してはならない」——と真っ向から対立していた。

PHP 4.2.0（2002年）でregister_globalsはデフォルトで無効化された。これはPHPのセキュリティ意識における大きな転換点だった。しかし、多くのホスティングサーバは互換性のために有効のまま運用を続け、多くのチュートリアルもregister_globalsを前提としたコードを掲載し続けた。register_globalsが完全に削除されたのはPHP 5.4.0（2012年）のことだ。10年かかった。

### SQLインジェクション——直接クエリの誘惑

PHPのもう一つのセキュリティ上の問題は、SQLインジェクションへの脆弱性だった。これはPHP言語自体の欠陥というよりも、PHPの「簡単さ」が誘導した危険なコーディングパターンの問題だった。

```php
// 危険なコード——SQLインジェクションに脆弱
$username = $_POST['username'];
$password = $_POST['password'];

$sql = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
$result = mysql_query($sql);
```

PHPの初期のMySQL関数群（`mysql_connect()`, `mysql_query()`等）は、SQLクエリを文字列として組み立てて実行するという、最も危険なパターンを最も簡単に書ける設計だった。プリペアドステートメントを使うには、追加のステップが必要だった。「簡単な方法」が「危険な方法」と一致していたのだ。

```php
// 安全なコード——プリペアドステートメント（PDO、PHP 5.1以降）
$stmt = $pdo->prepare("SELECT * FROM users WHERE username = :username AND password = :password");
$stmt->execute(['username' => $username, 'password' => $password]);
```

PDO（PHP Data Objects）がPHP 5.1（2005年）で導入され、プリペアドステートメントが標準的に使えるようになった。しかし、旧来の`mysql_*`関数群が非推奨になったのはPHP 5.5.0（2013年）、完全に削除されたのはPHP 7.0（2015年）のことだ。ここでも、安全な方法が「標準」になるまでに10年以上を要した。

### なぜPHPは嫌われたのか——構造的な問題

PHPが嫌われた理由は、個々のセキュリティ問題だけではない。言語設計そのものに、批判の対象となる構造的な問題があった。

第一に、関数命名の一貫性のなさだ。`str_replace()` はアンダースコア区切りだが `strlen()` は区切りなし。`strpos()` は引数が `(haystack, needle)` の順だが、`array_search()` は `(needle, haystack)` の順だ。これは、PHPが長い歴史の中で多くの開発者によって関数が追加されてきた結果だが、一貫した命名規則がなかったことの帰結である。

第二に、型システムの曖昧さだ。PHPの型変換（type juggling）は、時に予想外の結果をもたらす。

```php
// PHPの型変換の予想外な挙動（PHP 7以前）
var_dump(0 == "foo");    // true（PHP 7以前）
var_dump("" == null);    // true
var_dump("0" == false);  // true
var_dump("0" == null);   // false
```

等価演算子 `==` が型を自動変換して比較するため、直感に反する結果が生じる。PHP 8で `0 == "foo"` は `false` を返すよう修正されたが、この種の「暗黙の型変換」は長年にわたって多くのバグの温床だった。

第三に、グローバルスコープの汚染だ。PHPのファイルは、`include`や`require`で読み込まれると、呼び出し元のスコープの変数にアクセスできる。名前空間がPHP 5.3（2009年）で導入されるまで、大規模なアプリケーションでは関数名やクラス名の衝突が頻発した。

だが、ここで公平に述べなければならない。これらの「問題」の多くは、PHPが「テンプレート言語」として生まれたことに起因する。HTMLの中に埋め込む少量のコードで、厳密な型システムや名前空間が必要だろうか。PHPは、Webの「99%のユースケース」——小〜中規模の動的Webサイト——に最適化された言語だった。その設計判断は、当時のコンテキストでは合理的だったのだ。

問題は、PHPの用途がその設計の想定範囲を超えて拡大したことにある。テンプレート言語として始まったPHPで、数十万行のエンタープライズアプリケーションを構築する。それは、スプーンでトンネルを掘るようなものだ——不可能ではないが、道具の使い方を間違えている。

### PHPの反撃——PHP 7とPHP 8

PHPは嫌われるだけの言語ではなかった。PHPコミュニティは、批判を受け止め、言語を進化させ続けた。

2015年12月3日にリリースされたPHP 7.0は、PHPの歴史における最大の転換点の一つだった。phpng（PHP next generation）と呼ばれたプロジェクトで、Dmitry Stogov、Xinchen Hui、Nikita PopovらがZend Engineを全面的にリファクタリングした。結果は劇的だった——PHP 5.6と比較して約2倍の性能向上を達成した。

この性能向上は、shared-nothingアーキテクチャの弱点——リクエストごとのブートストラップコスト——を大幅に軽減した。WordPressのようなアプリケーションでは、同じハードウェアで処理できるリクエスト数がほぼ倍増した。

2020年11月26日にリリースされたPHP 8.0は、JIT（Just-In-Time）コンパイラを導入した。OPcacheの一部として実装されたJITは、ホットパス（頻繁に実行されるコード）を実行時に機械語にコンパイルする。数値計算やCPUバウンドな処理では顕著な性能向上を実現した。

PHP 8はまた、名前付き引数、アトリビュート（アノテーション）、Union型、match式など、現代的な言語機能を追加した。かつて「ダサい」と嘲笑されたPHPは、いまや型安全性を強化し、静的解析ツール（PHPStan、Psalm）と組み合わせることで、堅牢なアプリケーション開発が可能な言語に進化している。

---

## 4. ハンズオン——素のPHPでWebアプリケーションを作る

ここからは手を動かそう。フレームワークを使わない「素のPHP」で、Webアプリケーションの基本要素——ルーティング、データベース接続、テンプレート分離——を自分で実装する。PHPが隠蔽しているものはほとんどないが、フレームワークが何を隠蔽しているのかを、素のPHPを通じて体感する。

### 環境構築

Docker環境でPHP + SQLiteのセットアップを行う。

```bash
# Ubuntu環境でPHP環境をセットアップ
docker run -it --rm -p 8080:8080 --name php-lab ubuntu:24.04 bash
```

コンテナ内で以下を実行する。

```bash
# 必要なパッケージをインストール
apt-get update && apt-get install -y \
  php-cli \
  php-sqlite3 \
  php-mbstring \
  curl

# 作業ディレクトリを作成
mkdir -p /var/www/app/templates
cd /var/www/app
```

### 演習1: PHPビルトインWebサーバで「Hello World」

PHP 5.4以降にはビルトインWebサーバが搭載されている。開発用途であれば、Apacheすら不要だ。

```bash
# 最小限のPHPスクリプト
cat > /var/www/app/index.php << 'PHP'
<?php
// PHPの最も原始的なWebアプリケーション
// CGIの print "Content-type: text/html\n\n" に相当する処理を
// PHPは自動的に行ってくれる

echo "<html><body>";
echo "<h1>Hello from raw PHP</h1>";
echo "<p>PHP Version: " . phpversion() . "</p>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";
echo "<p>Request URI: " . htmlspecialchars($_SERVER['REQUEST_URI']) . "</p>";
echo "</body></html>";
PHP

# ビルトインWebサーバを起動（バックグラウンド）
php -S 0.0.0.0:8080 -t /var/www/app &

# 動作確認
sleep 1
curl http://localhost:8080/
```

`$_SERVER['REQUEST_URI']` でリクエストURIを取得できる。CGIでは環境変数 `REQUEST_URI` を自分で読む必要があったが、PHPはスーパーグローバル変数としてこれを提供する。

### 演習2: 自作ルーティング

フレームワークが最初に提供するのはルーティングだ。URLとPHPの処理を対応づける仕組みを、自分で実装する。

```bash
cat > /var/www/app/index.php << 'ROUTER'
<?php
/**
 * 素のPHPによるルーティング実装
 *
 * フレームワークのルーティングが何をしているかを理解するために、
 * 自分で実装する。本質は「URLパスを解析して、対応する処理を呼び出す」
 * それだけだ。
 */

// リクエスト情報の取得
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// ルーティングテーブル——URLパスと処理の対応表
// フレームワークはこれを宣言的に定義する仕組みを提供するが、
// 本質的にはこの配列と同じことをしている
$routes = [
    'GET' => [
        '/'          => 'handleHome',
        '/about'     => 'handleAbout',
        '/tasks'     => 'handleTaskList',
        '/tasks/new' => 'handleTaskForm',
    ],
    'POST' => [
        '/tasks' => 'handleTaskCreate',
    ],
];

// ルーティングの実行
if (isset($routes[$method][$path])) {
    $handler = $routes[$method][$path];
    $handler();  // 対応する関数を呼び出す
} else {
    http_response_code(404);
    echo "<html><body><h1>404 Not Found</h1>";
    echo "<p>Path: " . htmlspecialchars($path) . "</p>";
    echo "</body></html>";
}

// --- ハンドラ関数 ---

function handleHome(): void {
    echo "<html><body>";
    echo "<h1>素のPHP タスク管理アプリ</h1>";
    echo "<nav>";
    echo '<a href="/tasks">タスク一覧</a> | ';
    echo '<a href="/about">このアプリについて</a>';
    echo "</nav>";
    echo "</body></html>";
}

function handleAbout(): void {
    echo "<html><body>";
    echo "<h1>このアプリについて</h1>";
    echo "<p>フレームワークを使わない素のPHPで構築されたタスク管理アプリケーション。</p>";
    echo "<p>ルーティング、データベース、テンプレートを全て手動で実装している。</p>";
    echo '<p><a href="/">トップへ戻る</a></p>';
    echo "</body></html>";
}

function handleTaskList(): void {
    echo "<html><body>";
    echo "<h1>タスク一覧</h1>";
    echo "<p>（データベース未接続）</p>";
    echo '<p><a href="/tasks/new">新規タスク</a></p>';
    echo '<p><a href="/">トップへ戻る</a></p>';
    echo "</body></html>";
}

function handleTaskForm(): void {
    echo "<html><body>";
    echo "<h1>新規タスク</h1>";
    echo '<form method="POST" action="/tasks">';
    echo '<label>タイトル: <input type="text" name="title"></label><br>';
    echo '<label>説明: <textarea name="description"></textarea></label><br>';
    echo '<button type="submit">作成</button>';
    echo "</form>";
    echo '<p><a href="/tasks">一覧へ戻る</a></p>';
    echo "</body></html>";
}

function handleTaskCreate(): void {
    $title = htmlspecialchars($_POST['title'] ?? '', ENT_QUOTES, 'UTF-8');
    $description = htmlspecialchars($_POST['description'] ?? '', ENT_QUOTES, 'UTF-8');

    echo "<html><body>";
    echo "<h1>タスク作成完了</h1>";
    echo "<p>タイトル: {$title}</p>";
    echo "<p>説明: {$description}</p>";
    echo '<p><a href="/tasks">一覧へ戻る</a></p>';
    echo "</body></html>";
}
ROUTER

# ビルトインサーバを再起動
kill %1 2>/dev/null
php -S 0.0.0.0:8080 -t /var/www/app &
sleep 1

# ルーティングのテスト
echo "=== GET / ==="
curl -s http://localhost:8080/

echo ""
echo "=== GET /about ==="
curl -s http://localhost:8080/about

echo ""
echo "=== GET /tasks ==="
curl -s http://localhost:8080/tasks

echo ""
echo "=== GET /nonexistent (404) ==="
curl -s -o /dev/null -w "HTTP Status: %{http_code}" http://localhost:8080/nonexistent

echo ""
echo "=== POST /tasks ==="
curl -s -X POST -d "title=テスト&description=説明文" http://localhost:8080/tasks
```

このルーティング実装は全部で約80行だ。LaravelやSymfonyのルーティングコンポーネントは数千行に及ぶが、本質的にやっていることは同じ——URLパスを解析して対応する処理を呼び出す。フレームワークのルーティングが追加しているのは、正規表現によるパスパラメータ、ミドルウェア、名前付きルート、グループ化などの「便利さ」である。

### 演習3: データベース接続とCRUD

SQLiteを使って、データベースの接続と基本的なCRUD操作を実装する。

```bash
cat > /var/www/app/database.php << 'DB'
<?php
/**
 * 素のPHPによるデータベース操作
 *
 * PDO（PHP Data Objects）を使う。PDOはPHP 5.1（2005年）で導入された
 * データベース抽象化レイヤーで、プリペアドステートメントを標準的に提供する。
 * これにより、SQLインジェクションを構造的に防止できる。
 */

function getDatabase(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        $pdo = new PDO('sqlite:/var/www/app/tasks.db');
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        // テーブルが存在しなければ作成
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT DEFAULT '',
                completed INTEGER DEFAULT 0,
                created_at TEXT DEFAULT (datetime('now'))
            )
        ");
    }
    return $pdo;
}

function getAllTasks(): array {
    $pdo = getDatabase();
    $stmt = $pdo->query("SELECT * FROM tasks ORDER BY created_at DESC");
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function createTask(string $title, string $description): int {
    $pdo = getDatabase();
    // プリペアドステートメント——SQLインジェクション対策の基本
    $stmt = $pdo->prepare("INSERT INTO tasks (title, description) VALUES (:title, :description)");
    $stmt->execute(['title' => $title, 'description' => $description]);
    return (int)$pdo->lastInsertId();
}

function toggleTask(int $id): void {
    $pdo = getDatabase();
    $stmt = $pdo->prepare("UPDATE tasks SET completed = NOT completed WHERE id = :id");
    $stmt->execute(['id' => $id]);
}

function deleteTask(int $id): void {
    $pdo = getDatabase();
    $stmt = $pdo->prepare("DELETE FROM tasks WHERE id = :id");
    $stmt->execute(['id' => $id]);
}
DB
```

### 演習4: テンプレートの分離

素のPHPで、ロジックとプレゼンテーションを分離する。PHPの `include` を使った原始的なテンプレートシステムだが、これがテンプレートエンジンの最も基本的な形だ。

```bash
# レイアウトテンプレート
cat > /var/www/app/templates/layout.php << 'TPL'
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title><?= htmlspecialchars($title ?? 'タスク管理', ENT_QUOTES, 'UTF-8') ?></title>
  <style>
    body { font-family: sans-serif; max-width: 800px; margin: 2rem auto; padding: 0 1rem; }
    nav { margin-bottom: 2rem; padding: 1rem; background: #f0f0f0; }
    nav a { margin-right: 1rem; }
    .task { padding: 0.5rem; border-bottom: 1px solid #ddd; }
    .completed { text-decoration: line-through; color: #999; }
    form { margin: 1rem 0; }
    input[type="text"], textarea { width: 100%; padding: 0.5rem; margin: 0.25rem 0; }
    button { padding: 0.5rem 1rem; margin: 0.25rem; cursor: pointer; }
  </style>
</head>
<body>
  <nav>
    <a href="/">トップ</a>
    <a href="/tasks">タスク一覧</a>
    <a href="/tasks/new">新規タスク</a>
  </nav>
  <?= $content ?>
</body>
</html>
TPL

# タスク一覧テンプレート
cat > /var/www/app/templates/task_list.php << 'TPL'
<h1>タスク一覧</h1>
<?php if (empty($tasks)): ?>
  <p>タスクはありません。</p>
<?php else: ?>
  <?php foreach ($tasks as $task): ?>
    <div class="task <?= $task['completed'] ? 'completed' : '' ?>">
      <strong><?= htmlspecialchars($task['title'], ENT_QUOTES, 'UTF-8') ?></strong>
      <p><?= htmlspecialchars($task['description'], ENT_QUOTES, 'UTF-8') ?></p>
      <small>作成日: <?= htmlspecialchars($task['created_at'], ENT_QUOTES, 'UTF-8') ?></small>
      <form method="POST" action="/tasks/toggle" style="display:inline">
        <input type="hidden" name="id" value="<?= (int)$task['id'] ?>">
        <button type="submit"><?= $task['completed'] ? '未完了に戻す' : '完了にする' ?></button>
      </form>
      <form method="POST" action="/tasks/delete" style="display:inline">
        <input type="hidden" name="id" value="<?= (int)$task['id'] ?>">
        <button type="submit" onclick="return confirm('削除しますか？')">削除</button>
      </form>
    </div>
  <?php endforeach; ?>
<?php endif; ?>
TPL

# タスク作成フォームテンプレート
cat > /var/www/app/templates/task_form.php << 'TPL'
<h1>新規タスク</h1>
<form method="POST" action="/tasks">
  <div>
    <label>タイトル:</label>
    <input type="text" name="title" required>
  </div>
  <div>
    <label>説明:</label>
    <textarea name="description" rows="4"></textarea>
  </div>
  <button type="submit">作成</button>
</form>
TPL
```

最後に、ルーター（`index.php`）をデータベースとテンプレートを統合した完全版に更新する。

```bash
cat > /var/www/app/index.php << 'APP'
<?php
/**
 * 素のPHPによるWebアプリケーション——完全版
 *
 * このファイルは以下の3つの責務を持つ:
 * 1. ルーティング（URLと処理の対応）
 * 2. コントローラ（ビジネスロジック）
 * 3. テンプレートレンダリング（HTMLの生成）
 *
 * フレームワークは、この3つの責務を明確に分離し、
 * それぞれに洗練されたAPIを提供する。
 * だが本質的にやっていることは、このファイルと同じだ。
 */

require_once __DIR__ . '/database.php';

// --- テンプレートレンダリング ---
function render(string $template, array $vars = []): string {
    extract($vars);
    ob_start();
    include __DIR__ . "/templates/{$template}.php";
    $content = ob_get_clean();

    // レイアウトに埋め込む
    ob_start();
    include __DIR__ . '/templates/layout.php';
    return ob_get_clean();
}

// --- ルーティング ---
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

$routes = [
    'GET' => [
        '/'          => 'handleHome',
        '/tasks'     => 'handleTaskList',
        '/tasks/new' => 'handleTaskForm',
    ],
    'POST' => [
        '/tasks'        => 'handleTaskCreate',
        '/tasks/toggle' => 'handleTaskToggle',
        '/tasks/delete' => 'handleTaskDelete',
    ],
];

if (isset($routes[$method][$path])) {
    $handler = $routes[$method][$path];
    echo $handler();
} else {
    http_response_code(404);
    echo render('layout', ['title' => '404 Not Found', 'content' => '<h1>404 Not Found</h1>']);
}

// --- ハンドラ ---
function handleHome(): string {
    return render('task_list', [
        'title' => 'タスク管理',
        'tasks' => getAllTasks(),
    ]);
}

function handleTaskList(): string {
    return render('task_list', [
        'title' => 'タスク一覧',
        'tasks' => getAllTasks(),
    ]);
}

function handleTaskForm(): string {
    return render('task_form', ['title' => '新規タスク']);
}

function handleTaskCreate(): string {
    $title = trim($_POST['title'] ?? '');
    $description = trim($_POST['description'] ?? '');

    if ($title !== '') {
        createTask($title, $description);
    }

    // PRGパターン（Post/Redirect/Get）
    header('Location: /tasks');
    exit;
}

function handleTaskToggle(): string {
    $id = (int)($_POST['id'] ?? 0);
    if ($id > 0) {
        toggleTask($id);
    }
    header('Location: /tasks');
    exit;
}

function handleTaskDelete(): string {
    $id = (int)($_POST['id'] ?? 0);
    if ($id > 0) {
        deleteTask($id);
    }
    header('Location: /tasks');
    exit;
}
APP

# サーバ再起動
kill %1 2>/dev/null
php -S 0.0.0.0:8080 -t /var/www/app &
sleep 1

# 動作確認
echo "=== タスク作成 ==="
curl -s -X POST -d "title=PHPの歴史を学ぶ&description=1995年から2026年まで" \
  -L http://localhost:8080/tasks

echo ""
echo "=== タスク作成（2つ目）==="
curl -s -X POST -d "title=shared-nothingを理解する&description=リクエストごとに状態リセット" \
  -L http://localhost:8080/tasks

echo ""
echo "=== タスク一覧 ==="
curl -s http://localhost:8080/tasks
```

### 何が見えたか

この演習で構築したタスク管理アプリケーションは、`index.php`（ルーティング + コントローラ）、`database.php`（データアクセス）、テンプレートファイル群の3つで構成される。合計200行程度のコードだ。

ここで考えてほしい。この200行のコードに、フレームワークが提供する機能のうちどれだけが含まれているか。

- **ルーティング**: ある。ただし正規表現パスパラメータ、ルートグループ、名前付きルートはない
- **コントローラ**: ある。ただし依存性注入、ミドルウェアチェーンはない
- **データベース**: ある。ただしマイグレーション、ORM、リレーション管理はない
- **テンプレート**: ある。ただし自動エスケープ、テンプレート継承、コンポーネントはない
- **セキュリティ**: 手動。`htmlspecialchars()` を忘れたら脆弱性になる
- **CSRF対策**: ない。フォームにトークンを埋め込む処理は自分で書く必要がある
- **バリデーション**: ない。入力値の検証ロジックは自分で書く必要がある
- **セッション管理**: ない。ログイン機能は自分で書く必要がある

フレームワークとは、これらの「ない」を埋めるものだ。そしてPHPの世界では、2005年のCakePHP以降、無数のフレームワークがこの「ない」を埋めようとしてきた。だが重要なのは、フレームワークが提供するものの本質を理解した上で使うことだ。`htmlspecialchars()` を忘れる危険を知っているからこそ、テンプレートエンジンの自動エスケープの価値がわかる。SQLインジェクションの恐ろしさを知っているからこそ、ORMのプリペアドステートメントの重要性がわかる。

素のPHPを書いた経験は、無駄にはならない。

---

## 5. まとめと次回予告

### この回の要点

第4回では、PHPの30年の歴史を通じて、「Webの民主化」の構造と代償を掘り下げた。

Rasmus Lerdorfが1994年に作った「Personal Home Page Tools」は、CGIバイナリのセットとして始まった。1998年のPHP 3（Zeev SuraskiとAndi Gutmansによる完全書き直し）で「本物のプログラミング言語」に進化し、2000年のPHP 4（Zend Engine 1.0）、2004年のPHP 5（Zend Engine 2.0、本格的OOP対応）と着実に成長した。PHP 6はUnicode対応の野心的計画が頓挫して存在せず、2015年のPHP 7（Zend Engine 3）で約2倍の性能向上、2020年のPHP 8でJITコンパイラの導入を果たした。

PHPがWebを席巻した構造的理由は3つある。第一に、HTMLに埋め込むテンプレート言語としての出自が、Webデザイナーにとっての参入障壁を極限まで下げた。第二に、shared-nothingアーキテクチャが共有ホスティングと相性が良く、「FTPでアップロードするだけ」のデプロイを可能にした。第三に、WordPressという爆発的なキラーアプリケーションがPHPのシェアを押し上げ、2026年現在もサーバサイド言語の75%以上を占める基盤となった。

その代償として、register_globals（PHP 4.2.0でデフォルト無効化、PHP 5.4.0で完全削除）に象徴されるセキュリティ問題、`mysql_*` 関数群が誘導したSQLインジェクションの蔓延、関数命名の一貫性のなさ、型システムの曖昧さなど、構造的な問題を抱えた。これらの多くは、PHPが「テンプレート言語」として生まれたことに起因する——設計の想定範囲を超えた用途に使われた結果だ。

### 冒頭の問いに対する暫定回答

「なぜPHPはこれほどまでにWebを席巻し、そしてなぜ嫌われたのか？」

PHPがWebを席巻した理由と嫌われた理由は、同じ根を持つ。「誰でも簡単に書ける」という設計判断が、Webの民主化を実現すると同時に、安全でないコードの大量生産を許した。PHPを嫌うことは容易い。だが、PHPが存在しなければ、Webは今のようにはなっていなかった。WordPressもWikipediaもFacebook（初期）も、PHPがなければ存在しなかった。

PHPの教訓は明快だ。「簡単に書ける」と「安全に書ける」は、しばしばトレードオフの関係にある。そしてそのトレードオフを埋めるのが、フレームワークの役割だ。PHPの歴史は、「なぜフレームワークが必要とされたのか」という問いへの、最も説得力のある回答である。

あなたが日々使っているフレームワークの自動エスケープ、CSRF保護、プリペアドステートメント——それらはすべて、PHPの「素」の時代に痛い思いをした開発者たちの経験から生まれたものだ。その経験を知ることに意味はないだろうか。

### 次回予告

第5回「Java Servlet/JSP——エンタープライズの重力」では、PHPとは正反対の設計思想を持つ世界——Javaによるエンタープライズ Web開発を取り上げる。`web.xml`の冗長さ、Tomcatの設定、WARファイルのデプロイ。PHPの「簡単さ」とは対極にある重厚さの中に、大規模開発を支える設計思想がある。なぜ企業のWebシステムはJavaで作られたのか？ その選択は正しかったのか？

---

## 参考文献

- PHP Manual, "History of PHP" <https://www.php.net/manual/en/history.php.php>
- PHP Wikipedia <https://en.wikipedia.org/wiki/PHP>
- Cybercultural, "1995: PHP Launches As Server-Side CGI Scripts Toolset" <https://cybercultural.com/p/1995-php-quietly-launches-as-a-cgi-scripts-toolset/>
- W3Techs, "Usage Statistics and Market Share of PHP for Websites, March 2026" <https://w3techs.com/technologies/details/pl-php>
- Tideways, "PHP & Shared Nothing Architecture: The Benefits and Downsides" <https://tideways.com/profiler/blog/php-shared-nothing-architecture-the-benefits-and-downsides>
- WordPress Wikipedia <https://en.wikipedia.org/wiki/WordPress>
- WPBeginner, "The History of WordPress from 2003 - 2026" <https://www.wpbeginner.com/news/the-history-of-wordpress/>
- PHP RFC: php6 <https://wiki.php.net/rfc/php6>
- Zend, "PHP 7" <https://www.zend.com/blog/php-7>
- Kinsta, "What's New in PHP 8" <https://kinsta.com/blog/php-8/>
- PHP.Watch, "JIT - PHP 8.0" <https://php.watch/versions/8.0/JIT>
- Zend Engine Wikipedia <https://en.wikipedia.org/wiki/Zend_Engine>
- PHP-FPM, "About" <https://php-fpm.org/about/>
- CakePHP Wikipedia <https://en.wikipedia.org/wiki/CakePHP>
- Laravel Wikipedia <https://en.wikipedia.org/wiki/Laravel>
- Layershift, "Which PHP mode? Apache vs CGI vs FastCGI" <https://blog.layershift.com/which-php-mode-apache-vs-cgi-vs-fastcgi/>
