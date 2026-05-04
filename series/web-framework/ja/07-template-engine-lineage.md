# フレームワークという幻想

## ——Webアプリケーションの「当たり前」を疑う

### 第7回：テンプレートエンジンの系譜——ロジックと表示の分離

**連載「フレームワークという幻想——Webアプリケーションの『当たり前』を疑う」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 「ロジックとプレゼンテーションを分離せよ」という原則の起源と、その後の30年の実装史
- SSI、Smarty、Velocity、ERB、Jinja2、Mustache、Handlebars、Twig といった主要テンプレートエンジンの設計思想の系譜
- テンプレートエンジンを評価する4つの設計軸——ロジックフル/ロジックレス、コンパイル型/インタプリタ型、サーバ/クライアント、自動エスケープ/手動エスケープ
- ERB、Jinja2、Handlebars という3つの代表エンジンを実際に動かして、設計判断の違いを体感する方法
- ReactのJSXが「テンプレートを否定した」のではなく、テンプレート議論の最終形として位置付けられる理由

---

## 1. PHPコードに窒息していたデザイナーと、Smartyの `{$user.name}` を見た日

2002年の春、私はある中堅企業の社内システム開発に常駐していた。請け負っていたのは社員向けの勤怠管理Webアプリケーションで、当時の典型的な構成——Linux、Apache、MySQL、PHP——のいわゆる LAMP スタックで作られていた。私は当時、PHP 4 にはそれなりに慣れていて、フレームワークなしの「素のPHP」で日々ファイルを書き下ろしていた。

問題は、デザイン担当の協力会社から人が入ったときに起きた。Adobe GoLive（Dreamweaverの競合だった）でHTMLとCSSを書く、ベテランのウェブデザイナーが来た。彼は私が書いた `.php` ファイルを開いた瞬間、画面を凝視したまま動かなくなった。

```php
<?php
require_once 'db.php';
$pdo = new PDO("mysql:host=localhost;dbname=hr", "user", "pass");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$stmt = $pdo->prepare("SELECT id, name, dept FROM employees WHERE active = 1 ORDER BY name");
$stmt->execute();
$employees = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html><head><title>社員一覧</title></head>
<body>
<h1>社員一覧</h1>
<table>
<?php foreach ($employees as $emp): ?>
<tr>
    <td><?php echo htmlspecialchars($emp['id'], ENT_QUOTES, 'UTF-8'); ?></td>
    <td><?php echo htmlspecialchars($emp['name'], ENT_QUOTES, 'UTF-8'); ?></td>
    <td><?php echo htmlspecialchars($emp['dept'], ENT_QUOTES, 'UTF-8'); ?></td>
</tr>
<?php endforeach; ?>
</table>
</body></html>
```

「これ、私はどこを触っていいんですか」——彼の最初の質問はそれだった。HTMLの中に `<?php` と `?>` が散らばり、`htmlspecialchars` という見たこともない関数呼び出しが各セルに埋め込まれている。彼の視点からは、HTML 文書ではなく PHP コードの森にしか見えない。「とりあえず `<table>` の `border` を消したい」という単純な要望ですら、彼にとっては危険な作業になる。間違って `?>` を削れば、ページ全体が動かなくなる。

私はその日のうちに Smarty を導入した。Smarty は 2001年に Monte Ohrt と Andrei Zmievski が公開した PHP 用テンプレートエンジンで、HTML 側にはこう書く：

```smarty
<!DOCTYPE html>
<html><head><title>社員一覧</title></head>
<body>
<h1>社員一覧</h1>
<table>
{foreach $employees as $emp}
<tr>
    <td>{$emp.id}</td>
    <td>{$emp.name}</td>
    <td>{$emp.dept}</td>
</tr>
{/foreach}
</table>
</body></html>
```

PHP コードは別ファイルに分離する：

```php
<?php
require_once 'Smarty.class.php';
require_once 'db.php';

$pdo = new PDO("mysql:host=localhost;dbname=hr", "user", "pass");
$stmt = $pdo->prepare("SELECT id, name, dept FROM employees WHERE active = 1 ORDER BY name");
$stmt->execute();

$smarty = new Smarty();
$smarty->assign('employees', $stmt->fetchAll(PDO::FETCH_ASSOC));
$smarty->display('employees.tpl');
```

デザイナーに `.tpl` ファイルだけ見せた。彼の表情が変わった。「これなら触れます」。`{$emp.name}` はデータの差し込み箇所であり、`{foreach}` は反復だ。それ以外はただのHTMLである。彼はその日のうちに、1日かけて手を入れたいと言っていたデザイン修正を、半日で終わらせて帰った。

私はそのとき、何かが分離されたのを感じた。ロジックと表示が、物理的に別ファイルになった。エンジニアとデザイナーが、別々のファイルを編集できるようになった。だが同時に、別の不安も覚えた。`{foreach}` は所詮 PHP の `foreach` の薄いラッパーである。デザイナーが書いた `{$emp.id}` の出力は HTML エスケープされているのか？　Smarty はテンプレートを PHP にコンパイルしてキャッシュするが、そのキャッシュはどこに置かれ、いつ無効化されるのか？　テンプレートに `{php}{/php}` を書けば結局PHPコードを埋め込めてしまうこの仕組みは、本当に「分離」なのか？

「ロジックと表示を分離せよ」——この原則自体には、私は抵抗がない。だがこの原則をどう実装するかは、無数の選択肢がある。テンプレートに条件分岐や反復は許すか？　関数呼び出しは？　変数代入は？　モデルのメソッドを呼べてしまっていいのか？　答えは時代によって、コミュニティによって、目的によって異なってきた。

第7回では、この「ロジックと表示の分離」という原則がどこから来て、どう実装され、どこへ向かおうとしているのかを追う。SSI から Smarty、Velocity、ERB、Jinja2、Mustache、Handlebars、そして JSX まで——テンプレートエンジン30年の系譜の中に、現代の React も Next.js も位置付けることができるはずだ。

---

## 2. 30年の系譜——「分離」のための8つの実装

### 系譜の起点：SSI（1994年）——HTML に動的な穴を開ける

物語の起点は意外と早い。1994年1月、米国イリノイ大学アーバナ・シャンペーン校の National Center for Supercomputing Applications（NCSA）で、ウェブサーバ NCSA HTTPd 1.1 がリリースされた。開発の中心にいた Rob McCool は、CGI（Common Gateway Interface）の発明者でもあり、Apache HTTP Server の前身を作った人物だ。

NCSA HTTPd 1.1 には Server Side Includes（SSI）という機能が原始的な形で含まれていた。1.2（同年4月）で構文が整理され、HTML コメント形式の指令——`<!--#include file="header.html" -->`、`<!--#exec cmd="date" -->`、`<!--#echo var="DATE_LOCAL" -->`——が導入された。1995年12月リリースの Apache HTTP Server 1.0 は、`mod_include` という形で SSI を継承した。

SSI が解いたのは「静的HTMLに、動的な要素を差し込みたい」という最小要求だった。ヘッダ・フッタを共通化したい。最終更新日時を出したい。アクセスカウンタを表示したい。CGI スクリプトをまるごと書くほどでもないが、完全に静的でもない——その間を埋める仕組みとして SSI は普及した。

SSI が画期的だったのは、HTMLパーザに優しい設計だ。すべての指令は HTML コメント `<!-- -->` の形を取る。SSI を解釈しないブラウザやエディタで開いても、HTML として壊れない。これは後の Mustache の `{{name}}`（HTML 上は単なるテキスト）と同じ思想で、「テンプレートはHTMLとしても妥当であるべき」という設計哲学の系譜の最初のサンプルである。

```ssi
<!--#include file="header.html" -->
<h1>こんにちは</h1>
<p>最終更新: <!--#echo var="DATE_LOCAL" --></p>
<!--#include file="footer.html" -->
```

シンプルだが、これは紛れもなくテンプレートエンジンの一形態だ。ロジックは極小（差し込みと条件分岐のみ）、表示優先、HTMLとして妥当——後に「ロジックレステンプレート」と呼ばれる思想の遠い祖先である。

### インラインテンプレート言語の系譜：PHP・ASP・JSP・CFML

第4回〜第6回で見てきたように、SSI の次に登場したのは「言語そのものがテンプレート」というアプローチだった。

| 言語        | 初版       | 構文                     |
| ----------- | ---------- | ------------------------ |
| PHP         | 1995年6月  | `<?php ... ?>` `<?= ?>`  |
| ColdFusion  | 1995年7月  | `<cfquery>` `<cfoutput>` |
| ASP Classic | 1996年12月 | `<%...%>` `<%= %>`       |
| JSP         | 1999年9月  | `<%...%>` `<%= %>`       |

これらは「テンプレートに言語を埋め込んだ」というより、「言語処理系がHTMLを地の文として解釈する」という構造を取った。`.php` ファイルは原則 HTML を出力し、`<?php ... ?>` で囲まれた部分だけがコードとして実行される。`.asp` も `.jsp` も `.cfm` も基本構造は同じだ。

このアプローチの強みは導入の容易さである。HTMLを書ける人間は、ほぼそのままサーバサイド開発を始められた。これが PHP の爆発的普及の主因だったことは第4回で見た通りだ。

弱みもまた明白だった。第一に、ロジックと表示が物理的に同じファイルに混在する。第二に、表示用の関数（HTML エスケープ、フォーマット、URL 生成）を毎回手で呼ぶ必要があり、忘れれば XSS や SQL インジェクションの温床になる。第三に、デザイナーがファイルを開けない——冒頭の私の現場のような事態が、世界中で起きていた。

### Smarty（2001年）——PHPの上に「もう一段の言語」を重ねる

Smarty が解こうとしたのは、まさにこの第三の問題だった。「PHPはHTMLにコードを埋め込む言語として作られたのに、なぜさらにテンプレートエンジンが必要なのか」——この問いへの Smarty の答えは、「PHP は表現力がありすぎる」だった。

PHP では `<?php $obj->loadFromDatabase(); ?>` のような重い処理を、テンプレート相当のファイルに気軽に書けてしまう。これを構造的に防ぐためには、テンプレート専用の、表現力を絞った別の言語が必要だ——それが Smarty の発想である。

Smarty の構文：

```smarty
{* これはコメント *}
{$user.name}                            {* 変数出力 *}
{$user.name|escape:'html'}              {* 修飾子（モディファイア）*}
{if $user.is_admin}管理者{/if}          {* 条件分岐 *}
{foreach $items as $item}{$item.title}{/foreach}
{include file="header.tpl"}
```

Smarty の特徴は、テンプレートを PHP スクリプトに**コンパイル**してキャッシュすることだ。初回アクセス時に `.tpl` を解析して `templates_c/` 配下に PHP ファイルとして書き出し、以降はその PHP を実行する。ランタイムでパースし続けるインタプリタ型ではなく、ビルド時変換に近い。これにより「テンプレート言語の遅さ」という弱点を克服した。

ただし当時の Smarty には注意点もあった。デフォルトでは出力の自動エスケープが**無効**で、`{$user.name|escape:'html'}` のように修飾子を毎回書く必要があった。`htmlspecialchars()` を書き忘れると XSS、というPHP生の問題は、Smartyでも構造的には解決していなかった。後の Smarty 3 系で `default_modifiers` による自動エスケープが導入されるが、デフォルト OFF の遺産は長く残った。

### Apache Velocity（2001年）と FreeMarker（1999年〜）——Java 陣営の選択肢

Smarty とほぼ同じ時期、Java 陣営でも「JSP のスクリプトレットを排除したい」という議論が起きていた。第5回で見たように、JSP の `<% Java code %>` は強力だが、ロジックと表示の混在を加速させた。これに対する応答が、JSP の外側で動くテンプレートエンジン群——Velocity と FreeMarker だった。

Apache Velocity 1.0 は 2001年4月、Apache Software Foundation の Apache Jakarta プロジェクト下でリリースされた。その後、2006年10月の Apache Software Foundation Board の決議を経て、2007年1月に Top Level Project（TLP）に昇格、現在の「Apache Velocity」となった。

Velocity の構文（Velocity Template Language, VTL）：

```velocity
## コメント
$user.name                              ## 参照
$user.name.toUpperCase()                ## メソッド呼び出し
#if($user.isAdmin)管理者#end             ## 条件分岐
#foreach($item in $items)
    $item.title
#end
#parse("header.vm")
```

Velocity は Smarty と思想を共有する一方、Java らしく「Java オブジェクトのメソッド呼び出しをテンプレートから許可する」という設計を取った。`$user.name.toUpperCase()` のように、ドット記法で Java メソッドを直接呼べる。表現力は強いが、その分テンプレートに「ロジック」が漏れやすい。

並走したのが FreeMarker だ。FreeMarker 1 は 1999年末に SourceForge.net 上で Benjamin Geer と Mike Bayer によって公開された（後者は後に Python の SQLAlchemy を作る人物）。2002年初頭に Jonathan Revusky が JavaCC で書き直した FreeMarker 2 が事実上の主流となり、2015年7月に Apache Incubator 入り、現在は Apache FreeMarker として開発されている。

FreeMarker は Velocity より構文が冗長な代わりに、型安全性と詳細なエラーメッセージを重視した設計を取った。Velocity と FreeMarker は、Java サーバサイドにおける「JSP 以外」の選択肢として長く競合した。

JSP 自体も、2002年6月リリースの JSTL 1.0（JSR-052）によって、`<c:if>` `<c:forEach>` `<c:out>` といったタグライブラリで「スクリプトレットなしの JSP」が書けるようになる。これは「JSP 自身をロジックレスに近づける」試みだった。Java の世界では、外部エンジン（Velocity / FreeMarker）と内製の標準化（JSTL）が並行して進んだ。

### ERB（1999年）——Ruby 標準ライブラリとしてのテンプレート

Ruby の世界では、テンプレートは早い時期から標準ライブラリ化されていた。ERB（Embedded Ruby）は 1999年に関将俊（Masatoshi SEKI）によって公開された。当初は ERb / ERbLight と呼ばれており、Ruby 標準ライブラリに取り込まれる際に ERB へ改称された。

```erb
<%# コメント %>
<h1>こんにちは、<%= @user.name %></h1>
<% if @user.admin? %>
  <p>管理者です</p>
<% end %>
<ul>
<% @items.each do |item| %>
  <li><%= item.title %></li>
<% end %>
</ul>
```

`<%= %>`（出力）と `<% %>`（評価のみ）は、見ての通り ASP / JSP の `<%...%>` を意識した構文だ。Ruby は基本に忠実な選択をした——「Ruby のあらゆる式が、テンプレートからそのまま使える」という、表現力の上限を Ruby そのものに置く設計である。

これは Smarty とは正反対の哲学だ。Smarty は「PHP の表現力を制限したい」と考え、Ruby の ERB は「Ruby の表現力をそのままテンプレートで使えればいい」と考えた。後にこの哲学的差異は、Ruby on Rails が 2005年に登場した際、`.html.erb` を標準テンプレートとして採用したことで決定的になる。Rails の世界では、ヘルパー関数とインスタンス変数の規律で「ロジックの混入」を防ぐという、慣習による分離が選ばれた。

### Jinja2（2008年）——Python における表現力と安全性の両立

Python の世界では、Django が 2005年から「制限の多いテンプレート言語」として独自のテンプレートを提供していた。Django テンプレートでは `{{ }}` で変数出力、`{% %}` で制御を書くが、メソッド呼び出しに引数を渡せない、Pythonの式の大半が書けない、という強い制約があった。これは「デザイナーがロジックを書けないようにする」ための意図的な設計だった。

これに対する応答が Jinja2 だった。Jinja2 は 2008年5月、Armin Ronacher（後に Flask を作るオーストリアの開発者、Pocoo プロジェクト主宰）によって公開された。Pocoo は Python 製の bulletin board を作る試みで、本体は完成しなかったが、Jinja、Werkzeug、Pygments、後に Flask など多くのライブラリを生んだ。

Jinja2 は「Django の制限は厳しすぎる、もっと Python に近い表現力をテンプレートに与えたい」という動機で設計された。

```jinja2
{# コメント #}
<h1>こんにちは、{{ user.name }}</h1>
{% if user.is_admin %}
  <p>管理者です</p>
{% endif %}
<ul>
{% for item in items %}
  <li>{{ item.title|upper }}</li>
{% endfor %}
</ul>
{% extends "base.html" %}
{% block content %}{% endblock %}
```

Jinja2 の特徴は、構文が Django と互換的でありながら、Python 式の大半（リスト内包、辞書アクセス、スライス、フィルタチェーン）を許す点と、テンプレート継承（`extends` / `block`）という強力な再利用機構を備えた点だ。さらに Jinja2 はデフォルトで自動エスケープを推奨し、Sandbox モードによる「信頼できないテンプレートの実行」も検討された。

Jinja2 のもうひとつの貢献は、PHP 陣営にも波及したことだ。Twig（2009年〜、Fabien Potencier と Sensio Labs）は、Jinja2 と Django テンプレートに強い影響を受けた PHP 用テンプレートエンジンとして生まれた。実は Twig の初期コードは Armin Ronacher が個人ブログ用に書いたものを Fabien Potencier が引き取って書き直したという経緯があり、Jinja2 と直接の血縁関係にある。Twig は Symfony 2 以降の標準テンプレートエンジンとなり、Drupal 8 にも採用された。

### Mustache（2009年）と Handlebars（2010年）——ロジックレスという宣言

ここまで見てきたエンジンはどれも「ロジックフル」だ。条件分岐、反復、メソッド呼び出し、フィルタ、継承、マクロ——テンプレートの中で書けることを増やす方向に進化してきた。これに対して 2009年、Chris Wanstrath（GitHub 共同創業者、ハンドル名 defunkt）は真逆の宣言をした。

Mustache の Ruby gem 初版は 2009年10月6日。`mustache(5)` の man ページの最初の一行は明快だ：「Logic-less templates」。テンプレートに if 文も else 句も for ループも置かない、と宣言した。Google の CTemplate と「et」というライブラリにインスパイアされている。

```mustache
{{! コメント }}
<h1>こんにちは、{{user.name}}</h1>
{{#user.isAdmin}}
  <p>管理者です</p>
{{/user.isAdmin}}
<ul>
{{#items}}
  <li>{{title}}</li>
{{/items}}
</ul>
```

`{{#user.isAdmin}}...{{/user.isAdmin}}` は条件分岐ではなく**セクション**である。`user.isAdmin` が真（または非空配列）ならブロックがレンダリングされ、配列ならその各要素ごとにブロックが繰り返される。条件と反復を「セクション」という同一概念に統合したのだ。

「ロジックがない」とはどういう意味か。Mustache が排除しているのは、テンプレート言語側の表現力——演算子、フィルタ、関数呼び出し、変数代入——だ。これらは Mustache のテンプレートには書けない。代わりに、表示用に整形済みのデータ（View Model）をテンプレートに渡す責任は、呼び出し側（コントローラ）が負う。

この設計判断は、Mustache を**言語非依存**にした。テンプレートエンジン側に演算機構がないので、Ruby 実装も JavaScript 実装も Python 実装も、同じテンプレートファイルをほぼ同じ意味でレンダリングできる。同じテンプレートを「サーバ（Ruby）でも、クライアント（JavaScript）でも」同じ結果に使える——この性質は、当時芽吹きつつあった Ajax / SPA（第13回〜）の世界で非常に重要だった。Mustache の各言語実装は数十に達した。

ただし、Mustache の純粋ロジックレスは現場では「不便」と感じられることもあった。「リスト要素ごとに偶数行と奇数行で背景色を変えたい」「日付をフォーマットしたい」——こうした表示ロジックすら、すべて呼び出し側で前処理して View Model に詰めねばならない。これは思想的には正しいが、現実には冗長になる。

そこに登場したのが Handlebars.js だ。2010年9月9日、Yehuda Katz（Ember.js、Ruby on Rails、Bundler 等の中心開発者）は自身のブログで Handlebars.js を発表した。Handlebars は Mustache の**厳密なスーパーセット**として設計され、`{{#if}}` `{{#each}}` `{{#unless}}` `{{#with}}` といったブロックヘルパー、ユーザ定義ヘルパー、パス式（`../`、`@index`）、partials、そして「事前コンパイル」機構を加えた。

```handlebars
<h1>こんにちは、{{user.name}}</h1>
{{#if user.isAdmin}}
  <p>管理者です</p>
{{/if}}
<ul>
{{#each items}}
  <li>{{@index}}: {{title}} {{formatDate publishedAt}}</li>
{{/each}}
</ul>
```

Handlebars は厳密なロジックレスではなくなったが、表現力を制限し、ヘルパー登録という形でロジック注入の境界を明示した。Mustache の「言語非依存」「クライアント実行可能」という遺伝子を継承しつつ、現場の生産性を取り戻したわけだ。

### Liquid（2006年〜）——もうひとつのロジック制限派

Mustache と同じく「外部の人が安全に書けるテンプレート」を狙った系譜として、Shopify の Liquid もある。Liquid は Tobias Lütke（Shopify 創業者、Ruby on Rails コアチーム経験者）が、Shopify（2006年創業）のストアフロントを「商店主自身がデザインカスタマイズできる」ようにするために設計したテンプレート言語だ。

Liquid の重要な性質は **Sandboxed execution** であり、テンプレート側から任意の Ruby コードを呼ばれることがない。これは「サードパーティに編集を許す」という独特の要求から逆算された設計だった。Liquid は GitHub Pages の Jekyll でも採用され、静的サイトジェネレータ世界で広く知られるテンプレート言語となった。

### 系譜図——30年でどう枝分かれしたか

ここまで見てきたエンジン群を、起源と影響関係で図にすると次のようになる。

```
                            SSI (1994, NCSA HTTPd)
                                │
          ┌─────────────────────┼─────────────────────┐
          │                     │                     │
 インライン埋め込み系       外部テンプレート系       静的差し込み系
          │                     │                     │
 ┌────────┼────────┐            │              （Apache mod_include）
 │        │        │            │
PHP      ASP      JSP/CFML      │
1995    1996      1999/95       │
                                │
                ┌───────────────┼───────────────┐
                │               │               │
            Java 系         Ruby 系          Python 系
                │               │               │
      ┌─────────┼──────┐        ERB         Django Template
      │         │      │        1999          2005頃
  FreeMarker  Velocity JSTL      │               │
  1999       2001     2002       │               │
                                 │               ↓
                                 │           Jinja2 (2008)
                                 │           by Armin Ronacher
                                 │               │
                                 │               ↓
                                 │           Twig (2009)
                                 │           by Fabien Potencier
                                 │
            ┌────────────────────┴────────────────────┐
            │                                         │
       ロジックフル系                          ロジックレス系
            │                                         │
      Smarty (2001)                            Mustache (2009)
      ERB / Jinja2 / Twig                      by Chris Wanstrath
      Velocity / FreeMarker                            │
                                                       ↓
                                                Handlebars (2010)
                                                by Yehuda Katz
                                                       │
                                                       ↓
                                            （言語非依存・SPA時代へ）
                                                Liquid (2006〜)
```

この図は単純化したものだが、いくつかの構造的パターンが見える。第一に、ほとんどの主要エンジンが 1999年〜2010年の十数年に集中して登場している。これは Web 開発が「動的ページ生成」というユースケースで爆発的に成熟した時期と重なる。第二に、各言語コミュニティが「自言語のテンプレート」を順番に育てている——PHP の Smarty、Java の Velocity、Ruby の ERB、Python の Jinja2。テンプレートは、その言語の生態系の重要な一部だった。第三に、2009年の Mustache を境に、流れが「言語独立・サンドボックス・クライアント実行」へとシフトしていく。これは次章で詳しく見る、SPA と JavaScript の台頭による必然だった。

---

## 3. 4つの設計軸——テンプレートエンジンを評価する座標系

テンプレートエンジンの違いは、表面の構文（`<% %>` か `{{ }}` か）ではない。本質は4つの設計軸の組み合わせにある。

### 軸1：ロジックフル vs ロジックレス——どこまでテンプレートに書かせるか

最も根本的な分岐は、「テンプレートにどこまでロジックを許すか」である。

| ロジックフル                             | 中間               | ロジックレス                    |
| ---------------------------------------- | ------------------ | ------------------------------- |
| ERB、Jinja2、Twig、Velocity、Smarty、JSP | Handlebars、Liquid | Mustache                        |
| 任意のコード/メソッド呼び出し            | 制限された制御     | 出力と分岐/反復のセクションのみ |

ロジックフル派の論拠は明快だ——「現実にはテンプレートで簡単な計算をしたい場面が多い。フォーマット、条件付きクラス名、ループ内のインデックス処理。これらを呼び出し側でいちいち前処理するのは冗長だ」。

ロジックレス派の論拠も強い——「テンプレートに表現力を許すと、ビジネスロジックが必ず混入する。混入したロジックは、テスト不可能で、再利用不可能で、デザイナーには読めない。デザインとロジックの真の分離は、テンプレートの表現力を物理的に制限することでしか達成できない」。

この対立は、Web 史を通じて何度も繰り返されてきた哲学的な議論で、どちらが「正しい」とも決められない。組織の文化、プロジェクトの規模、デザイナーとエンジニアの関係性によって、最適な選択が変わる。

### 軸2：コンパイル型 vs インタプリタ型——いつテンプレートを解釈するか

第二の軸は、テンプレートをいつ解釈するかという実行モデルの違いだ。

**コンパイル型**は、テンプレートを事前に別形式（多くは元の言語のソースコード）に変換し、それを実行する。Smarty は `.tpl` を PHP コードにコンパイルして `templates_c/` にキャッシュする。JSP は `.jsp` を Java の Servlet クラスにコンパイルする。Twig は PHP クラスに変換する。Handlebars はコンパイル後の JavaScript 関数を生成する。

**インタプリタ型**は、テンプレートをそのままパース木として保持し、レンダリングのたびに走査する。素の ERB は基本的にこの方式（Ruby 2.6 以降の `eRuby::Compiler` や、`erubi` などの実装ではコンパイル化されているが）。Mustache の純粋実装も、テンプレートの AST をその場で歩く。

コンパイル型は速い代わりに、キャッシュの管理（テンプレート変更検知、無効化、ファイル権限）が必要になる。インタプリタ型は遅い代わりに、運用が単純になる。テンプレートが頻繁に変わる開発時はインタプリタが快適で、本番ではコンパイル型が望ましい——という設計判断は、現代の Webpack / Vite / esbuild の議論と構造的に同じだ。

### 軸3：サーバサイド vs クライアントサイド——どこでレンダリングするか

第三の軸は、テンプレートをどこで実行するかだ。

2000年代の前半まで、テンプレートエンジンは原則としてサーバ側で動くものだった。Smarty は PHP のサーバ上で、Velocity は JVM のサーバ上で、ERB は Rails のサーバ上で実行され、結果の HTML がブラウザに返されていた。

これが変わったのが、2010年前後の Mustache / Handlebars だった。Mustache は言語非依存仕様を持ち、JavaScript 実装（mustache.js）が早くから存在した。Handlebars.js は最初から JavaScript 実装が主流だった。これらは「同じテンプレートをサーバとクライアントの両方で使える」という性質を持つ。

なぜそれが重要だったか。Ajax の普及（第13回で扱う）以後、ブラウザはサーバから JSON を受け取り、それをクライアント側で HTML に変換するようになった。サーバ側のテンプレートエンジン（Smarty や Velocity）はこの用途に使えない。クライアントで動くテンプレートが必要だった。

この流れは Backbone.js（2010年）、Knockout.js（2010年）、AngularJS（2010年）といった初期 SPA フレームワークと同期した。AngularJS の「ディレクティブ」による双方向バインディングは、クライアントサイドテンプレートの新しい形だった。そして 2013年、Facebook の React がもう一段違う回答を出す——JSX である（後述）。

### 軸4：自動エスケープ vs 手動エスケープ——XSS をどう防ぐか

第四の軸は、安全性のデフォルト設定だ。

XSS（クロスサイトスクリプティング）は、ユーザ入力を HTML として出力するときに `<script>` タグや `onclick` 属性が紛れ込み、ブラウザで実行されてしまう脆弱性である。これを防ぐには、出力時に `<` を `&lt;` に、`>` を `&gt;` に置換する HTML エスケープを行う必要がある。

問題は「いつ、誰がエスケープするか」だ。

**手動エスケープ**派：素の PHP（`<?= htmlspecialchars($x) ?>`）、初期 Smarty、初期 ERB。テンプレート開発者が、出力箇所ごとに明示的にエスケープ関数を呼ぶ。

**自動エスケープ**派：Jinja2（`autoescape=True`）、Twig（デフォルト ON）、Rails 3 以降の ERB（HTML safe バッファ）、Handlebars（`{{x}}` は自動エスケープ、`{{{x}}}` で生出力）。テンプレートエンジンが出力箇所をすべて自動エスケープし、明示的に「生 HTML」と宣言した箇所だけスキップする。

この差は致命的だ。手動派では、1万箇所の出力のうち1箇所でもエスケープを忘れれば XSS になる。自動派では、デフォルトが安全側に倒れているので、明示的に `{{{x}}}` と書かない限り XSS は発生しない。

歴史の教訓は明確だ——自動エスケープが正しい。Jinja2 と Twig は最初から自動エスケープを推奨し、Rails も 2010年の Rails 3 で `html_safe` モデルに移行した。新規にテンプレート言語を設計するなら、自動エスケープをデフォルト ON にする以外の選択肢はない。

### MVCのVをどう実現したか——4軸の組み合わせとして

第3章（次回以降）で詳しく扱う MVC（Model-View-Controller）の文脈で見ると、テンプレートエンジンは「V＝View」をどう実装するかという回答だった。

```
              Model
                │
                ↓
          Controller
                │
                ↓ （ViewModel/データ）
     ┌──────────┴──────────┐
     │                     │
テンプレートエンジン         │
（ロジック制限のレベル）      │
     │                     │
     ↓                     │
   HTML ←─── Helper／Tag ←──┘
              （表示専用ロジック）
```

ロジックフル派は「ヘルパー」や「タグライブラリ」という抽象を介して、表示専用ロジックをテンプレートから呼ばせる。Rails のヘルパー、JSP の JSTL、Velocity の Tools サブプロジェクト、Twig のフィルタ。すべて同じ問題への異なる回答だ。

ロジックレス派は、ヘルパー機構そのものを排除する代わりに、Controller の責務を増やした。表示用整形済みデータ（View Model パターン）をテンプレートに渡す責務がコントローラに集中し、テンプレートは純粋に「データの形に従って HTML を組み立てる」だけになる。

どちらが「正しい MVC」かは決められない。Martin Fowler が `Patterns of Enterprise Application Architecture`（2002年）で論じたように、MVC には多くの変種があり、Web の文脈では「どの責務をどこに置くか」という配置の問題が常に残り続ける。

### 終着点としての JSX——テンプレートの否定か、テンプレートの完成形か

ここまで見てきたテンプレートエンジンの歴史を俯瞰すると、2013年に Facebook が公開した React の JSX（JavaScript XML）の位置付けが見えてくる。

JSX は構文的には HTML に近いが、実体は JavaScript の式である：

```jsx
function UserList({ users }) {
  return (
    <ul>
      {users.filter(u => u.isActive).map(user => (
        <li key={user.id}>
          {user.name} ({user.dept})
        </li>
      ))}
    </ul>
  );
}
```

JSX は4つの設計軸でどこに位置するか。

- **軸1（ロジックフル/レス）**：完全にロジックフル。`{users.filter(...).map(...)}` は完全な JavaScript 式である。Mustache の対極。
- **軸2（コンパイル/インタプリタ）**：完全にコンパイル型。Babel が JSX を `React.createElement()` 呼び出しに変換する。実行時には JSX という構文は存在しない。
- **軸3（サーバ/クライアント）**：両方。最初はクライアント中心だったが、SSR（Server-Side Rendering）の普及により今はサーバでも動く。React Server Components（2020年〜）はサーバ専用 JSX という新カテゴリを生んだ。
- **軸4（自動エスケープ）**：自動。JSX 内の `{value}` は自動エスケープされ、`dangerouslySetInnerHTML` という明示的な命名で生 HTML 注入を許可する。

JSX を「テンプレートの否定」と見る人もいる——「JSX はもうテンプレートじゃない、ただの JavaScript だ」。だが私はそう思わない。JSX は、ここまで見てきた4つの設計軸のすべてで「現代的な選択」をした、テンプレート議論のひとつの最終回答である。表現力の上限を JavaScript 自体に置く（ERB の発想）。事前コンパイルする（JSP の発想）。サーバとクライアントで同じ表現を使う（Mustache の発想）。デフォルトで安全（Jinja2 の発想）。これらの設計判断はすべて、過去の30年の議論の上に積み重なっている。

「テンプレートエンジンは、SSI から JSX まで、形を変えながら同じ問いを問い続けてきた——『ロジックと表示をどう分けるか』という問いに対する、それぞれの時代の解として」。

---

## 4. ハンズオン——同じデータを3つのエンジンで描画する

ここからは手を動かしてみよう。同じ「タスク一覧」というデータを、ERB（Ruby、ロジックフル/インタプリタ寄り）、Jinja2（Python、ロジックフル/自動エスケープ）、Handlebars（JavaScript、ロジック制限/コンパイル型）の3つのエンジンで描画し、設計判断の違いを実機で確かめる。

### 環境構築

Docker `ubuntu:24.04` を使う。手元の環境を汚さない。

```bash
docker run --rm -it \
  -v "$(pwd)/work:/work" \
  ubuntu:24.04 bash
```

コンテナ内で各言語ランタイムをインストールする。

```bash
apt-get update && apt-get install -y \
  ruby ruby-erb \
  python3 python3-pip python3-jinja2 \
  nodejs npm \
  diffutils
```

`/work` に移動して、共通のデータファイルを作る。

```bash
cd /work
mkdir -p tasks
cat > tasks/data.json <<'JSON'
{
  "title": "今週のタスク",
  "user": "佐藤",
  "tasks": [
    {"id": 1, "title": "原稿レビュー <urgent>", "done": false, "priority": "high"},
    {"id": 2, "title": "ファクトチェック", "done": true, "priority": "high"},
    {"id": 3, "title": "ハンズオン作成 & 検証", "done": false, "priority": "medium"},
    {"id": 4, "title": "設計レビュー", "done": false, "priority": "low"}
  ]
}
JSON
```

`urgent` を `<>` で囲んだのは、自動エスケープの挙動を確認するための仕掛けである。

### 演習1：ERB（Ruby）でレンダリング

```bash
cat > tasks/render_erb.rb <<'RUBY'
require 'erb'
require 'json'

data = JSON.parse(File.read('tasks/data.json'), symbolize_names: true)
template = ERB.new(File.read('tasks/template.erb'), trim_mode: '-')
puts template.result_with_hash(data: data)
RUBY

cat > tasks/template.erb <<'ERB'
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title><%= data[:title] %></title></head>
<body>
<h1><%= data[:title] %></h1>
<p>担当: <%= data[:user] %></p>
<ul>
<% data[:tasks].each do |task| -%>
  <li class="<%= task[:done] ? 'done' : 'pending' %> p-<%= task[:priority] %>">
    [<%= task[:done] ? 'x' : ' ' %>] <%= task[:title] %>
  </li>
<% end -%>
</ul>
<p>未完了: <%= data[:tasks].count { |t| !t[:done] } %> / <%= data[:tasks].length %></p>
</body></html>
ERB

ruby tasks/render_erb.rb > tasks/out_erb.html
cat tasks/out_erb.html
```

注目すべきは2点。第一に、`<% data[:tasks].each do |task| %>` は完全な Ruby のブロックである。テンプレート内に Ruby のあらゆる式を書ける。`data[:tasks].count { |t| !t[:done] }` のような複雑な集計もテンプレート内に書ける。これがロジックフルの強みであり弱みである。

第二に、`<%= task[:title] %>` の出力には `<urgent>` がそのまま `<urgent>` として出力される。素の ERB は自動エスケープしない。Rails の ActionView では `html_safe` バッファによって自動エスケープされるが、素の ERB ではそうではない。HTML セーフにするには `<%= ERB::Util.html_escape(task[:title]) %>` あるいは `<%=h task[:title] %>` を書く必要がある。

### 演習2：Jinja2（Python）でレンダリング

```bash
cat > tasks/render_jinja.py <<'PY'
import json
from jinja2 import Environment, FileSystemLoader, select_autoescape

env = Environment(
    loader=FileSystemLoader('tasks'),
    autoescape=select_autoescape(['html'])
)
template = env.get_template('template.j2')

with open('tasks/data.json', encoding='utf-8') as f:
    data = json.load(f)

print(template.render(**data))
PY

cat > tasks/template.j2 <<'J2'
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>{{ title }}</title></head>
<body>
<h1>{{ title }}</h1>
<p>担当: {{ user }}</p>
<ul>
{% for task in tasks %}
  <li class="{{ 'done' if task.done else 'pending' }} p-{{ task.priority }}">
    [{{ 'x' if task.done else ' ' }}] {{ task.title }}
  </li>
{% endfor %}
</ul>
<p>未完了: {{ tasks | rejectattr('done') | list | length }} / {{ tasks | length }}</p>
</body></html>
J2

python3 tasks/render_jinja.py > tasks/out_jinja.html
cat tasks/out_jinja.html
```

Jinja2 のポイントは3つ。

第一に、`autoescape=select_autoescape(['html'])` を有効にしているので、`{{ task.title }}` の出力は自動的に HTML エスケープされる。`<urgent>` は `&lt;urgent&gt;` として出力される。XSS を構造的に防ぐデフォルトだ。

第二に、`{{ 'done' if task.done else 'pending' }}` のように Python 風の三項演算子（条件式）が書ける。Django テンプレートではこれが書けない（`{% if task.done %}done{% else %}pending{% endif %}` と冗長になる）。Jinja2 が Django テンプレートに対して提供した表現力の差はここにある。

第三に、`{{ tasks | rejectattr('done') | list | length }}` のフィルタチェーンは強力だ。Unix のパイプのように、フィルタを連結してデータを変換できる。`| upper` `| capitalize` `| date` といった組み込みフィルタも豊富にある。

### 演習3：Handlebars（Node.js）でレンダリング

```bash
cd /work && npm init -y >/dev/null && npm install handlebars >/dev/null

cat > tasks/render_hbs.js <<'JS'
const fs = require('fs');
const Handlebars = require('handlebars');

Handlebars.registerHelper('check', (done) => done ? 'x' : ' ');
Handlebars.registerHelper('cssState', (done) => done ? 'done' : 'pending');
Handlebars.registerHelper('countPending', (tasks) =>
  tasks.filter(t => !t.done).length
);

const tplSrc = fs.readFileSync('tasks/template.hbs', 'utf-8');
const data = JSON.parse(fs.readFileSync('tasks/data.json', 'utf-8'));

const template = Handlebars.compile(tplSrc);
process.stdout.write(template(data));
JS

cat > tasks/template.hbs <<'HBS'
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>{{title}}</title></head>
<body>
<h1>{{title}}</h1>
<p>担当: {{user}}</p>
<ul>
{{#each tasks}}
  <li class="{{cssState done}} p-{{priority}}">
    [{{check done}}] {{title}}
  </li>
{{/each}}
</ul>
<p>未完了: {{countPending tasks}} / {{tasks.length}}</p>
</body></html>
HBS

node tasks/render_hbs.js > tasks/out_hbs.html
cat tasks/out_hbs.html
```

Handlebars のポイントを2つ確認する。

第一に、テンプレート自体には条件式や三項演算子を書けない。`task.done ? 'done' : 'pending'` は書けない。代わりに、`Handlebars.registerHelper('cssState', ...)` で**ヘルパー関数**を JavaScript 側で定義し、テンプレートからは `{{cssState done}}` という関数呼び出しで使う。ロジックの境界が明示的になる。

第二に、`{{title}}` は自動エスケープされる。`<urgent>` は `&lt;urgent&gt;` として出力される。生 HTML を注入したい場合は `{{{title}}}` と三重カッコを書く。Yehuda Katz は「危険な操作には危険そうな見た目を与える」という設計思想を一貫させた。

### 演習4：3つの出力を比較する

```bash
diff tasks/out_erb.html tasks/out_jinja.html
diff tasks/out_jinja.html tasks/out_hbs.html
```

3つの出力は、HTML 構造としてはほぼ同一になるはずだ。ただし、ERB の出力には `<urgent>` がそのまま含まれているのに対し、Jinja2 と Handlebars の出力では `&lt;urgent&gt;` にエスケープされている、という決定的な差がある。

```bash
grep -E 'urgent' tasks/out_*.html
```

```text
tasks/out_erb.html:    [ ] 原稿レビュー <urgent>
tasks/out_jinja.html:    [ ] 原稿レビュー &lt;urgent&gt;
tasks/out_hbs.html:    [ ] 原稿レビュー &lt;urgent&gt;
```

これが「自動エスケープのデフォルト」が現実にどう違うかを示している。素の ERB（Rails ではない）は「テンプレート開発者が忘れたら XSS」、Jinja2 と Handlebars は「テンプレート開発者が忘れても安全」。設計判断の差が、セキュリティの差になる。

### 演習5：意図的に「Viewに重い計算」を入れてみる

最後に、ロジックフル/レスの哲学的差異を実機で感じる演習をする。「タスクの中で、優先度が high で、かつ完了していないものの件数」をテンプレート内で計算してみよう。

ERB（ロジックフル）：

```erb
<%= data[:tasks].count { |t| t[:priority] == 'high' && !t[:done] } %>
```

Jinja2（ロジックフル）：

```jinja2
{{ tasks | selectattr('priority', 'equalto', 'high') | rejectattr('done') | list | length }}
```

Handlebars（ロジック制限）：

```javascript
// JS 側でヘルパーを登録する必要がある
Handlebars.registerHelper('countHighPending', (tasks) =>
  tasks.filter(t => t.priority === 'high' && !t.done).length
);
```

```handlebars
{{countHighPending tasks}}
```

ERB と Jinja2 はテンプレートの中で完結する。Handlebars は JavaScript 側に「countHighPending」というヘルパーを登録しなければならない。

これは「ロジックレスは不便」と批判される典型例だ。だが裏を返せば、Handlebars の `{{countHighPending tasks}}` は、テンプレートを読むだけで「何が計算されているかは別ファイル（JS）を見ないとわからない」が、「テンプレート自身は表示しかしていない」ことが構造的に保証される。

ロジックフルは「書きやすい」が、テンプレートにビジネスロジックが混入するリスクを構造的には防げない。ロジックレスは「面倒」だが、テンプレートが純粋な表示記述であることを構造的に保証する。

正解はない。現場の規律と、デザイナーとエンジニアの分業構造によって、最適な選択は変わる。だが「自分がどちらを選び、なぜそう選んだか」を言語化できないまま使っているなら、それはテンプレートエンジンの設計判断を理解していないということだ。

---

## 5. ロジックと表示の分離はどこへ向かうのか

### この回の要点

第7回では、「ロジックとプレゼンテーションを分離せよ」という原則の30年史を辿った。

1994年の SSI が「HTML に動的な穴を開ける」という最小要求を満たして以来、各言語コミュニティは独自のテンプレートエンジンを発展させてきた。1999年の ERB と FreeMarker、2001年の Smarty と Velocity、2002年の JSTL、2008年の Jinja2、2009年の Twig と Mustache、2010年の Handlebars——どのエンジンも、ロジックと表示の分離という共通課題に対する、それぞれの時代の解だった。

これらのエンジンは4つの設計軸——ロジックフル/レス、コンパイル/インタプリタ、サーバ/クライアント、自動/手動エスケープ——の組み合わせとして整理できる。表面の構文（`<% %>` か `{{ }}` か）の違いは、これら設計判断の結果でしかない。

そして 2013年の React の JSX は、これら4軸すべてで「現代的な解」を選んだ、テンプレート議論のひとつの最終形として位置付けられる。テンプレートを否定したのではなく、過去の議論を全部呑み込んだ上での回答だった。

### 冒頭の問いに対する暫定回答

「『ロジックとプレゼンテーションを分離せよ』——この原則はどこから来て、どこへ向かうのか？」

第一に、この原則の起源は明確だ。SSI が静的 HTML に動的差し込みを可能にした 1994年から、原則は連綿と存在してきた。だが「分離」が何を意味するかは時代とともに変わってきた。最初は「PHP コードと HTML を分けたい」だったし、その次は「デザイナーが触れるテンプレートが欲しい」だったし、その次は「サーバとクライアントで同じテンプレートを使いたい」だったし、現在は「型安全に UI を組み立てたい」になっている。

第二に、この原則の終着点は「ない」。私たちはずっと旅の途中だ。React の JSX が完成形に見えるとしても、それは現時点での回答にすぎない。Phoenix LiveView や HTMX は、サーバサイドレンダリングを別の角度から再評価しようとしている。Rust の Yew や Leptos は、コンパイル時にすべてを解決する別のアプローチを示している。次の10年で、また別のテンプレート的何かが生まれるだろう。

第三に、最も重要なこと——「ロジックと表示の分離」を実装するエンジンを選ぶとき、あなたは4つの設計軸のすべてで何かを決めている。それを意識せずに `react-create-app` を打つことと、4つの軸を理解した上で React を選ぶことは、同じ行動でも意味がまったく違う。前者はフレームワークに依存しているだけだが、後者はフレームワークを設計判断として使えている。「Enable」とは、その違いを生み出すことだ。

冒頭のデザイナーが Smarty の `{$emp.name}` を見て「これなら触れます」と言った瞬間に起きたのは、HTML を編集する権利が彼に返ってきたという事実だけではない。エンジニアが「ロジックを書く責務」を、デザイナーが「表示を書く責務」を、それぞれ独立に持てるようになったということだ。テンプレートエンジンは、人間の役割分担の道具でもあった。

### 次回予告

第8回「MVCの起源——Smalltalkから始まった設計パターン」では、ここまで見てきたテンプレートエンジンが「V＝View」を担う、より大きな設計パターン——MVC——に踏み込む。1979年に Trygve Reenskaug が Xerox PARC の Smalltalk-80 で提案したオリジナルの MVC と、1999年に Sun Microsystems が「Model 2」アーキテクチャとして再定義した Web MVC は、実は別物である。「MVC」という言葉に何を込めるかが、Web 開発のすべての設計議論の前提になっている。第8回はその前提を解きほぐす。

---

## 参考文献

- Wikipedia, "Server Side Includes" <https://en.wikipedia.org/wiki/Server_Side_Includes>
- Wikipedia, "NCSA HTTPd" <https://en.wikipedia.org/wiki/NCSA_HTTPd>
- Just Solve the File Format Problem, "Server Side Includes" <http://justsolve.archiveteam.org/wiki/Server_Side_Includes>
- Wikipedia, "Smarty (template engine)" <https://en.wikipedia.org/wiki/Smarty_(template_engine)>
- Smarty 公式サイト <https://www.smarty.net/>
- Monte Ohrt, "Smarty Manual" <https://www.smarty.net/files/docs/manual-en-2.6.pdf>
- Wikipedia, "Apache Velocity" <https://en.wikipedia.org/wiki/Apache_Velocity>
- The Apache Velocity Project <https://velocity.apache.org/>
- Apache Today, "Jakarta Velocity 1.0 Released" (2001) <https://apachetoday.com/news_story.php3?ltsn=2001-04-02-001-06-NW-SW-DT>
- ruby/erb GitHub リポジトリ <https://github.com/ruby/erb>
- Masatoshi SEKI, "ERB, ancient and future" RubyKaigi 2024 <https://rubykaigi.org/2024/presentations/m_seki.html>
- stdgems.org, "erb" <https://stdgems.org/erb/>
- Armin Ronacher, "Jinja2 Documentation Release 2.0" (2008) <http://mitsuhiko.pocoo.org/jinja2docs/Jinja2.pdf>
- Wikipedia, "Armin Ronacher" <https://en.wikipedia.org/wiki/Armin_Ronacher>
- Wikipedia, "Mustache (template system)" <https://en.wikipedia.org/wiki/Mustache_(template_system)>
- mustache.github.io, "mustache(5) - Logic-less templates" <https://mustache.github.io/mustache.5.html>
- mustache/mustache GitHub リポジトリ <https://github.com/mustache/mustache>
- Yehuda Katz, "Announcing Handlebars.js" (2010) <https://yehudakatz.com/2010/09/09/announcing-handlebars-js/>
- handlebars.js GitHub リポジトリ <https://github.com/kpdecker/handlebars.js>
- Wikipedia, "Twig (template engine)" <https://en.wikipedia.org/wiki/Twig_(template_engine)>
- Fabien Potencier, "Templating Engines in PHP" (2009) <https://fabien.potencier.org/templating-engines-in-php.html>
- Wikipedia, "FreeMarker" <https://en.wikipedia.org/wiki/FreeMarker>
- Apache FreeMarker, "Project history" <https://freemarker.apache.org/history.html>
- Wikipedia, "Jakarta Standard Tag Library" <https://en.wikipedia.org/wiki/Jakarta_Standard_Tag_Library>
- JCP, "JSR-052" <https://jcp.org/en/jsr/detail?id=052>
- Wikipedia, "Shopify" <https://en.wikipedia.org/wiki/Shopify>
- Wikipedia, "Tobias Lütke" <https://en.wikipedia.org/wiki/Tobias_L%C3%BCtke>
- React Documentation, "Writing Markup with JSX" <https://react.dev/learn/writing-markup-with-jsx>
- Martin Fowler, "GUI Architectures" <https://martinfowler.com/eaaDev/uiArchs.html>
