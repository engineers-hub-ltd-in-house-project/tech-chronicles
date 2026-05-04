# 第7回ファクトチェック：テンプレートエンジンの系譜——ロジックと表示の分離

調査日：2026-04-29
調査者：Claude Code（執筆支援）
対象記事：`series/web-framework/ja/07-template-engine-lineage.md`

WebSearch で各項目を検証し、一次ソース（公式ドキュメント、Wikipedia、開発者ブログ、リポジトリ等）を参照した結果を以下に記録する。

---

## 1. Server Side Includes (SSI) の起源

- **結論**: 検証済み。SSI は Rob McCool が NCSA HTTPd 向けに開発した。NCSA HTTPd 1.1（1994年1月）に原始的版が登場し、1.2（1994年4月）で `<!--#include -->` 形式の現代的構文が確立された。Apache HTTP Server 1.0（1995年12月）で `mod_include` として継承され普及した。
- **一次ソース**: Wikipedia "Server Side Includes"; Wikipedia "NCSA HTTPd"; Just Solve the File Format Problem "Server Side Includes"
- **URL**:
  - <https://en.wikipedia.org/wiki/Server_Side_Includes>
  - <https://en.wikipedia.org/wiki/NCSA_HTTPd>
  - <http://justsolve.archiveteam.org/wiki/Server_Side_Includes>
- **注意事項**: SSI は CGI より軽量な「動的差し込み」を提供する仕組みで、テンプレートエンジンの最初期形態と位置付けられる。
- **記事での表現**: 「Server Side Includes（SSI）は、Rob McCool が NCSA HTTPd 1.1（1994年1月）に実装した。HTML コメント形式の `<!--#include -->` 構文は同 1.2（1994年4月）で確立され、Apache HTTP Server に継承された」

## 2. Smarty 1.0 の初版リリースと作者

- **結論**: 検証済み。Smarty は 2001年1月18日に Monte Ohrt と Andrei Zmievski によって公開された。Smarty の核心的特徴は「テンプレートをコンパイルして PHP スクリプトに変換する」点にある。
- **一次ソース**: Wikipedia "Smarty (template engine)"; Smarty 公式マニュアル（Monte Ohrt 著）; Wedevs "Smarty 1.0 Released"; documentation.help "Smarty - the compiling PHP template engine"
- **URL**:
  - <https://en.wikipedia.org/wiki/Smarty_(template_engine)>
  - <https://www.smarty.net/>
  - <https://www.smarty.net/files/docs/manual-en-2.6.pdf>
  - <https://documentation.help/PHP-Smarty/documentation.pdf>
- **注意事項**: 開発開始は 1999年末。前身として SmartTemplate（公開せず）があった。著作権は New Digital Group, Inc. が保有。
- **記事での表現**: 「Smarty は 2001年1月、Monte Ohrt と Andrei Zmievski によって公開された PHP 用テンプレートエンジンである。テンプレートを PHP スクリプトにコンパイルしてキャッシュする方式が特徴」

## 3. Apache Velocity の初版と Apache Top Level Project への昇格

- **結論**: 検証済み。Velocity 1.0 は 2001年4月、Jakarta Velocity として Apache Software Foundation の Apache Jakarta プロジェクト下でリリースされた。2006年10月26日に Apache Software Foundation Board の決議により Top Level Project（TLP）へ昇格、2007年1月7日付で「Apache Velocity」として独立。
- **一次ソース**: Wikipedia "Apache Velocity"; Apache Today "Jakarta Velocity 1.0 Released"; LiveJournal apachenews_blog "Apache Velocity moved up to Top Level"
- **URL**:
  - <https://en.wikipedia.org/wiki/Apache_Velocity>
  - <https://velocity.apache.org/>
  - <https://apachetoday.com/news_story.php3?ltsn=2001-04-02-001-06-NW-SW-DT>
  - <https://apachenews-blog.livejournal.com/92955.html>
- **注意事項**: Java 製。`#set($name = "...")` `#foreach` `#if` のようなディレクティブを持つ。Struts、Turbine、Tapestry など同時代の Jakarta プロジェクトと統合されていた。
- **記事での表現**: 「Apache Jakarta Velocity 1.0 は 2001年4月にリリースされ、2007年1月に Top Level Project へ昇格して Apache Velocity となった」

## 4. ERB（Embedded Ruby）の作者と初版

- **結論**: 検証済み。ERB の作者は関将俊（Masatoshi SEKI）。1999年にリリースされた。最初は ERb / ERbLight と呼ばれており、Ruby 標準ライブラリに取り込まれる際に ERB へ改名された。
- **一次ソース**: ruby/erb GitHub リポジトリ; RubyKaigi 2024 講演「ERB, ancient and future」（関将俊）; stdgems.org "erb"
- **URL**:
  - <https://github.com/ruby/erb>
  - <https://rubykaigi.org/2024/presentations/m_seki.html>
  - <https://stdgems.org/erb/>
- **注意事項**: `<%= %>`（出力）、`<% %>`（評価のみ）、`<%# %>`（コメント）の構文は ASP/JSP の `<%...%>` を意識したもの。Rails の `.erb` テンプレートを通じて広く知られる。
- **記事での表現**: 「ERB は関将俊が 1999年に公開した Ruby 用テンプレートシステムである。当初は ERb / ERbLight と呼ばれ、Ruby 標準ライブラリ化に際して ERB に改称された」

## 5. Jinja2 の作者と初版

- **結論**: 検証済み。Jinja2 は Armin Ronacher（オーストリアの開発者、Pocoo プロジェクト主宰）が 2008年5月に公開した Python 用テンプレートエンジン。Pocoo は Georg Brandl らと Python 製の bulletin board を開発しようとした取り組みで、本体は完成しなかったが Jinja、Werkzeug、Pygments、後の Flask など多くのライブラリを生んだ。
- **一次ソース**: Jinja2 Documentation Release 2.0（Armin Ronacher, 2008年5月5日）; Wikipedia "Armin Ronacher"; lucumr.pocoo.org "Projects"
- **URL**:
  - <http://mitsuhiko.pocoo.org/jinja2docs/Jinja2.pdf>
  - <https://en.wikipedia.org/wiki/Armin_Ronacher>
  - <https://lucumr.pocoo.org/projects/>
- **注意事項**: Django テンプレートの「制限の多さ」へのアンサーとして設計され、Python 式に近い表現力を持つ。`{{ var }}`（出力）と `{% tag %}`（制御）の二種類の区切り。
- **記事での表現**: 「Jinja2 は Armin Ronacher が 2008年に公開した Python 用テンプレートエンジン。Pocoo プロジェクトの一環として生まれ、Django テンプレートに比べて高い表現力を持つ」

## 6. Mustache の作者・初版とロジックレス哲学

- **結論**: 検証済み。Mustache は Chris Wanstrath（GitHub 共同創業者、ハンドル名 defunkt）が 2009年に発表した Ruby 製テンプレートライブラリで、初版（Ruby gem）は 2009年10月6日。Google の CTemplate と「et」ライブラリにインスパイアされている。設計哲学は「Logic-less」——テンプレート内に if/else/for などの制御構造を持たない。`mustache(5)` の man ページに「Logic-less templates」と明示されている。
- **一次ソース**: Wikipedia "Mustache (template system)"; mustache.github.io "mustache(5) - Logic-less templates"; mustache/mustache GitHub リポジトリ
- **URL**:
  - <https://en.wikipedia.org/wiki/Mustache_(template_system)>
  - <https://mustache.github.io/mustache.5.html>
  - <https://github.com/mustache/mustache>
- **注意事項**: 言語非依存仕様で、Ruby、JavaScript、Python、PHP、Java など数十の言語に実装が存在する。波カッコ二重 `{{ }}` を「mustache（口ひげ）」に見立てた命名。
- **記事での表現**: 「Mustache は Chris Wanstrath（GitHub 共同創業者、ハンドル名 defunkt）が 2009年10月に公開したロジックレステンプレート。Google の CTemplate に着想を得ている。テンプレート内に制御構造を許さないという設計哲学を貫いた」

## 7. Handlebars.js の作者・初版と Mustache との関係

- **結論**: 検証済み。Handlebars.js は Yehuda Katz（Ember.js、Ruby on Rails、Bundler 等の開発で知られる）が 2010年9月9日に Mustache の拡張として発表した。Mustache の構文に「block helpers」「path-based expressions」「partials の最適化」を加えた厳密なスーパーセットで、Mustache テンプレートも Handlebars でレンダリングできる。最初のステップは「Mustache 構文をインタプリタ式から事前コンパイル式へ移すこと」だった。
- **一次ソース**: Yehuda Katz blog "Announcing Handlebars.js"（2010-09-09）; Wikipedia "Mustache (template system)"; handlebars.js GitHub
- **URL**:
  - <https://yehudakatz.com/2010/09/09/announcing-handlebars-js/>
  - <https://github.com/kpdecker/handlebars.js>
  - <https://handlebarsjs.com/>
- **注意事項**: 厳密にはロジックレスではなく「ロジック制限」型。`{{#if}}` `{{#each}}` `{{#unless}}` 等のブロックヘルパーを内蔵し、ユーザ定義ヘルパーも追加可能。
- **記事での表現**: 「Handlebars.js は Yehuda Katz が 2010年9月に Mustache の拡張として公開した。block helper や path 式を加えた Mustache のスーパーセットであり、テンプレートを事前コンパイルする」

## 8. Twig の作者と初版

- **結論**: 検証済み。Twig の初期コードは Armin Ronacher（Jinja の作者）が個人ブログ用に書いたもの。その後 Fabien Potencier（Symfony / Sensio Labs 創業者）が引き取り、2009年10月7日に「Templating Engines in PHP」記事で Twig を紹介、大幅に書き直して Sensio Labs プロジェクト化した。Symfony 2 以降の標準テンプレートエンジン。
- **一次ソース**: Wikipedia "Twig (template engine)"; fabien.potencier.org "Templating Engines in PHP"
- **URL**:
  - <https://en.wikipedia.org/wiki/Twig_(template_engine)>
  - <https://fabien.potencier.org/templating-engines-in-php.html>
  - <https://twig.symfony.com/>
- **注意事項**: 構文は Jinja2/Django テンプレートに非常に近い。PHP コードにコンパイルしてキャッシュ。
- **記事での表現**: 「Twig は Armin Ronacher が書いた初期コードを Fabien Potencier が 2009年10月から本格化させた PHP 用テンプレートエンジン。Symfony 2 の標準として採用された」

## 9. FreeMarker の起源

- **結論**: 検証済み。FreeMarker 1 は 1999年末に SourceForge.net 上で公開された。原作者は Benjamin Geer と Mike Bayer。FreeMarker 2 は 2002年初頭に Jonathan Revusky が JavaCC を用いてコア解析器/コンパイラを書き直した実質的な再実装。Apache Software Foundation の Incubator 入りは 2015年7月、TLP 昇格を経て Apache FreeMarker となった。
- **一次ソース**: Wikipedia "FreeMarker"; Apache FreeMarker "Project history"
- **URL**:
  - <https://en.wikipedia.org/wiki/FreeMarker>
  - <https://freemarker.apache.org/history.html>
- **注意事項**: Apache Velocity と同時代・同言語（Java）で競合関係にあった。Mike Bayer は後に Python の SQLAlchemy 作者として知られる。
- **記事での表現**: 「FreeMarker は 1999年末に Benjamin Geer と Mike Bayer が SourceForge で公開した Java 用テンプレートエンジン。Velocity と並ぶ Java 系の選択肢となった」

## 10. JSTL（JSP Standard Tag Library）の経緯

- **結論**: 検証済み。JSTL は JSR-052（Java Specification Request 52）として Java Community Process（JCP）で策定された。JSTL 1.0 は 2002年6月リリース、JSTL 1.1（JSP 2.0 対応）は 2003年、JSTL 1.2 は 2006年5月8日、JSTL 1.2.1 は 2011年12月7日。`<c:if>` `<c:forEach>` などのタグで JSP のスクリプトレット（`<% ... %>`）を排除する目的で導入された。
- **一次ソース**: Wikipedia "Jakarta Standard Tag Library"; JCP JSR 52 detail page
- **URL**:
  - <https://en.wikipedia.org/wiki/Jakarta_Standard_Tag_Library>
  - <https://jcp.org/en/jsr/detail?id=052>
- **注意事項**: 第5回（Java Servlet/JSP）で扱った「スクリプトレットからカスタムタグへ」の流れの具体的な制度化が JSTL である。
- **記事での表現**: 「JSP のスクリプトレットを排除する流れは、2002年6月の JSTL 1.0（JSR-052）として標準化された」

## 11. Liquid（Shopify）の起源

- **結論**: 部分的に検証済み（年代の正確な特定は限定的）。Liquid は Tobias Lütke が Shopify（2006年創業）の構築過程で開発した Ruby 製テンプレート言語。Lütke は Ruby on Rails コアチームでも活動し、Typo（ブログエンジン）、Active Merchant 等を開発した。Liquid はストアフロントを「underlying system を壊さずに」カスタマイズ可能にすることを目的に設計され、論理レス寄りの安全なテンプレート言語として位置付けられる。
- **一次ソース**: Wikipedia "Shopify"; Wikipedia "Tobias Lütke"; Liquid Weekly Podcast Episode 025
- **URL**:
  - <https://en.wikipedia.org/wiki/Shopify>
  - <https://en.wikipedia.org/wiki/Tobias_L%C3%BCtke>
  - <https://liquidweekly.com/blogs/podcast/episode-025-guest-tobi-lutke-on-creating-liquid>
- **注意事項**: Mustache（2009年）より早く「外部デザイナーに安全に書かせる」用途を想定したテンプレート言語として登場した点が興味深い。記事内では「Shopify が Liquid を開発した時期は 2006-2008 年頃」と幅を持たせて記述する。
- **記事での表現**: 「Tobias Lütke は Shopify（2006年創業）の開発過程で Liquid を生み出した。外部デザイナーが触れても安全な、ロジック制限型のテンプレート言語である」

## 12. ColdFusion CFML / ASP `<%...%>` 系譜との接続

- **結論**: 検証済み（前回記事と整合）。第6回で扱った CFML（1995年〜）、ASP Classic の `<%...%>`（1996年）、JSP の `<%...%>`（1999年）、PHP の `<?php ?>` は、いずれも「HTML 中にコードを埋め込むインラインテンプレート」の系譜に属する。本回で扱う「外部テンプレートエンジン」は、これらの「言語そのものがテンプレート」という方式の弱点（ロジックと表示の混在、デザイナーへの非親和性）への応答として登場した。
- **一次ソース**: 第6回記事 `series/web-framework/ja/06-asp-coldfusion.md`; 第4回記事 `series/web-framework/ja/04-php-democratization.md`; 第5回記事 `series/web-framework/ja/05-java-servlet-jsp.md`
- **URL**: なし（自リポジトリ内記事への内部参照）
- **注意事項**: 第6回末尾で本回の予告を行っているため、内容の連続性を保つ。
- **記事での表現**: 「PHP の `<?php ?>`、ASP の `<%...%>`、JSP の `<% %>`、CFML の `<cf...>`——いずれも『言語そのものがテンプレート』という方式だった。テンプレートエンジンの登場は、その方式が抱えた『ロジックと表示の混在』『デザイナーが触れない』という問題への応答である」

---

## 検証サマリー

- **検証済み項目数**: 12項目中 11項目が完全検証済み、1項目（Liquid の年代）が部分検証
- **品質ゲート**: 6項目以上の検証済みを満たす（充足）
- **未検証事項**: なし。Liquid の正確な公開年は記事内で「2006-2008年頃」と幅を持たせて記述する
