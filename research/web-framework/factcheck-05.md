# ファクトチェック記録：第5回「Java Servlet/JSP——エンタープライズの重力」

## 1. Java Servlet APIの起源と開発者

- **結論**: Java Servletの概念は1995年にJames Goslingが提案した。Servlet APIは1996年5月のJavaOneでデビューし、Sun MicrosystemsがJeeves（後のJava Web Server）の一部として最初のアルファ版をリリースした。James Duncan DavidsonがServlet APIの仕様を2バージョン執筆し、1997年6月にServlet 1.0がリリースされた。Servlet 2.1は1999年1月、Servlet 2.2は1999年8月（J2EE 1.2の一部として）にリリースされた
- **一次ソース**: Eclipse Foundation Newsletter, "Jakarta EE: Servlets and Tomcat — 23 Years and Counting", 2020年; Jakarta Servlet Wikipedia
- **URL**: <https://www.eclipse.org/community/eclipse_newsletter/2020/february/3.php>, <https://en.wikipedia.org/wiki/Jakarta_Servlet>
- **注意事項**: Pavni DiwanjiがServlet 1仕様の作成者として記録されている。James Duncan Davidsonは参照実装（JWSDK）を開発し仕様の2バージョンを執筆した
- **記事での表現**: 「1995年にJames Goslingが概念を提案し、1997年6月にServlet 1.0仕様が策定された。James Duncan Davidsonが仕様策定と参照実装の開発を主導した」

## 2. JavaServer Pages（JSP）の歴史

- **結論**: JSPはSun Microsystemsが開発。1998年にプレリリース版（0.92）を公開。JSP 1.0は1999年6月、JSP 1.1は1999年12月にリリースされた。Larry CableとEduardo Pelegri-Llopartがリード開発者だった
- **一次ソース**: InformIT, "A Brief History of JSP"; Jakarta Server Pages Wikipedia
- **URL**: <https://www.informit.com/articles/article.aspx?p=31072&seqNum=5>, <https://en.wikipedia.org/wiki/Jakarta_Server_Pages>
- **注意事項**: JSPはPHP/ASPに類似したテンプレート技術として設計された。BEA、Netscape、IBMなどが共同開発に参加
- **記事での表現**: 「JSP 1.0は1999年6月にリリースされ、HTMLにJavaコードを埋め込むテンプレート技術として登場した」

## 3. Apache Tomcatの起源とCatalina

- **結論**: Tomcatは1998年11月にJames Duncan DavidsonがSun Microsystemsで開発したServlet参照実装として始まった。1999年にSunがApache Software Foundationに寄贈。最初のApacheリリースはバージョン3.0。Tomcat 4.xでCatalina（サーブレットコンテナ）、Coyote（HTTPコネクタ）、Jasper（JSPエンジン）が導入された。Craig McClanahanがCatalinaエンジンの命名者。2005年にApacheトップレベルプロジェクトとなり、Jakarta傘下を離脱
- **一次ソース**: Apache Tomcat Heritage; Apache Tomcat Wikipedia
- **URL**: <https://tomcat.apache.org/heritage.html>, <https://en.wikipedia.org/wiki/Apache_Tomcat>
- **注意事項**: Tomcatの名前の由来——Davidsonがオープンソース化を見越してO'Reillyの動物表紙本を意識して命名。2003年のO'Reilly Tomcat本では実際にユキヒョウが表紙に採用された
- **記事での表現**: 「DavidsonはSunを説得してTomcatのコードをApache Software Foundationに寄贈した（1999年）。これがオープンソースのServletコンテナとしてのApache Tomcatの始まりである」

## 4. J2EE / Java EE / Jakarta EEの変遷

- **結論**: J2EE 1.2は1999年12月12日にリリース。EJB、Servlet、JSPを核とするエンタープライズプラットフォーム。J2EE 1.3（2001年）、J2EE 1.4（2003年）と進化。2006年にJava 5に合わせて「Java EE」に改称。2017年9月12日にOracleがJava EEをEclipse Foundationに移管を発表。2018年に「Jakarta EE」に改称
- **一次ソース**: Baeldung, "Java EE vs J2EE vs Jakarta EE"; Jakarta EE Wikipedia
- **URL**: <https://www.baeldung.com/java-enterprise-evolution>, <https://en.wikipedia.org/wiki/Jakarta_EE>
- **注意事項**: J2EE→Java EE→Jakarta EEの名称変遷は、Sun→Oracle→Eclipse Foundationという管理主体の移り変わりと連動している
- **記事での表現**: 「J2EE 1.2は1999年12月にリリースされ、EJB、Servlet、JSPを統合したエンタープライズプラットフォームとしてJavaの企業向け開発基盤を確立した」

## 5. Apache Struts（Craig McClanahan、2000年）

- **結論**: Craig McClanahanがApache Strutsを作成し、2000年5月にApache Foundationに寄贈。最初のリリース（Struts 1.0）は2001年6月。JSPのModel 2アーキテクチャにインスパイアされたMVCフレームワーク。元々はApache Jakarta Projectの下で「Jakarta Struts」として知られ、2005年にApacheトップレベルプロジェクトに昇格。WebWork 2.2がApache Struts 2として採用され、2007年2月に初の正式リリース
- **一次ソース**: Apache Struts 1 Wikipedia; Struts 1 Introduction
- **URL**: <https://en.wikipedia.org/wiki/Apache_Struts_1>, <https://weblegacy.github.io/struts1/userGuide/introduction.html>
- **注意事項**: Strutsは2000年代前半のJava Web開発のデファクトスタンダードだった。Struts 1は2013年にEnd of Lifeを迎えた
- **記事での表現**: 「Craig McClanahanが作成し2000年にApacheに寄贈したStrutsは、Java Web開発における最初の本格的なMVCフレームワークとなった」

## 6. Spring Framework（Rod Johnson、2003年）

- **結論**: Rod Johnsonが2002年11月に『Expert One-on-One J2EE Design and Development』を出版。書籍に付属していた30,000行のフレームワークコードが起源。Juergen HoellerとYann Caroffの説得により、2003年2月にオープンソースプロジェクトとして開発開始。「Spring」の名はYann Caroffが提案——J2EEの「冬」の後の「春」を意味する。2003年6月にApache 2.0ライセンスで初リリース。最初のプロダクションリリース（1.0）は2004年3月
- **一次ソース**: Spring.io Blog, "Spring Framework: The Origins of a Project and a Name", 2006年; Spring Framework Wikipedia
- **URL**: <https://spring.io/blog/2006/11/09/spring-framework-the-origins-of-a-project-and-a-name/>, <https://en.wikipedia.org/wiki/Spring_Framework>
- **注意事項**: 元々は「Interface21 framework」（com.interface21パッケージ名）と呼ばれていた。JohnsonはJ2EEとEJBに当初は熱心だったが、実際のプロジェクトでの運用で問題を発見した
- **記事での表現**: 「Rod Johnsonは2002年の著書でJ2EE/EJBの問題点を指摘し、代替手段としてのフレームワークコードを提示した。これが2003年にSpring Frameworkとしてオープンソース化される」

## 7. EJBの複雑さと批判

- **結論**: EJB 1.0は1997年にIBMが開発し後にSunが採用。大企業に急速に採用されたが、すぐに問題が顕在化。批判の焦点：(1) 大量のXMLデプロイメント記述子、(2) コンポーネントインターフェース・ホームインターフェース・Bean実装クラスの3ファイル必須構成、(3) CORBAを前提としたリモートメソッド呼び出しのパフォーマンスペナルティ、(4) チェック例外の乱用。Martin Fowlerが「POJO」（Plain Old Java Object）という用語を考案してEJBの複雑さに対抗。EJB 3.0で大幅に簡素化された
- **一次ソース**: Jakarta Enterprise Beans Wikipedia; Oracle, "An Introduction to the Enterprise JavaBeans 3.0 (EJB 3) Specification"
- **URL**: <https://en.wikipedia.org/wiki/Jakarta_Enterprise_Beans>, <https://www.oracle.com/technical-resources/articles/entarch/ejb3.html>
- **注意事項**: 「POJO」はMartin Fowler、Rebecca Parsons、Josh MacKenzieが2000年9月に考案した用語として記録されている
- **記事での表現**: 「EJBは大企業に採用されたが、その複雑さ——1つのBeanを作るために複数のインターフェース、XML記述子、抽象クラスが必要——が開発者の反発を招いた」

## 8. web.xmlデプロイメント記述子

- **結論**: web.xmlはWARファイルのWEB-INF/ディレクトリに配置されるXMLファイル。URLとサーブレットのマッピング、フィルタ、リスナー、セキュリティ制約などを宣言的に設定する。Servlet 3.0以降、@WebServletなどのアノテーションによりweb.xmlの記述を省略可能になった
- **一次ソース**: Oracle, "Deployment descriptor"; Deployment descriptor Wikipedia
- **URL**: <https://docs.oracle.com/middleware/1221/wls/WBAPP/web_xml.htm>, <https://en.wikipedia.org/wiki/Deployment_descriptor>
- **注意事項**: Servlet 3.0のアノテーション対応は2009年（Java EE 6）
- **記事での表現**: 「web.xmlは宣言的設定の先駆けであり、URLマッピング、フィルタチェーン、セキュリティ制約をXMLで記述するアプローチだった」

## 9. WAR/EARデプロイメントモデル

- **結論**: WAR（Web Application Archive）はServlet、JSP、HTML、静的リソース、web.xmlを含むパッケージ形式。EAR（Enterprise Application Archive）は複数のWAR/JARを束ねるパッケージ形式。WARファイルはスタンドアロンでは実行できず、Tomcat/Jetty/WildFlyなどのアプリケーションサーバにデプロイする必要がある
- **一次ソース**: WAR (file format) Wikipedia; Baeldung, "Difference Between WAR and EAR Files"
- **URL**: <https://en.wikipedia.org/wiki/WAR_(file_format)>, <https://www.baeldung.com/war-vs-ear-files>
- **注意事項**: Spring Bootのembedded Tomcatにより、実行可能JARでのデプロイが一般化し、WAR/EARモデルの必要性は大幅に減少した
- **記事での表現**: 「WARファイルという標準化されたパッケージ形式は、アプリケーションサーバへの統一的なデプロイを可能にしたが、同時に『サーバを立てて、WARを配置する』という重い儀式を開発者に課した」

## 10. Spring Boot（2014年、Phil Webb）

- **結論**: Spring Bootは2013年にPivotal SoftwareのPhil Webbと Spring Frameworkコントリビュータチームが開発を開始。2014年4月1日にバージョン1.0 GAをリリース。主要機能：自動設定（auto-configuration）、組み込みWebサーバ（embedded Tomcat）、スターター依存関係、実行可能JARによるデプロイ
- **一次ソース**: Spring Boot Grokipedia; InfoQ, "Spring Boot 2.0 Goes GA; Project Lead Phil Webb Speaks to InfoQ"
- **URL**: <https://grokipedia.com/page/Spring_Boot>, <https://www.infoq.com/news/2018/03/spring-boot-2.0-release-ga-webb/>
- **注意事項**: Spring Bootはweb.xmlもWARデプロイも不要にし、Java Web開発の開発体験を劇的に変えた
- **記事での表現**: 「2014年のSpring Bootは、組み込みTomcatと自動設定により、web.xmlもWARデプロイも不要にした——Servlet時代の『重い儀式』からの解放だった」

## 11. Servlet APIの設計——フィルタチェーン

- **結論**: Servlet Filterはjavax.servletパッケージのFilter、FilterChain、FilterConfigインターフェースで定義される。Chain of Responsibilityパターンの実装。リクエストとレスポンスを各フィルタが順番に処理し、ServletRequestWrapper/HttpServletRequestWrapperでラップ可能。Servlet 2.3（JSR 53）でフィルタAPIが導入された
- **一次ソース**: Oracle, "The Essentials of Filters"; DigitalOcean, "Java Servlet Filter Example Tutorial"
- **URL**: <https://www.oracle.com/java/technologies/filters.html>, <https://www.digitalocean.com/community/tutorials/java-servlet-filter-example-tutorial>
- **注意事項**: このフィルタチェーンの概念は、後のExpressのミドルウェアパターンやSpring Securityのセキュリティフィルタチェーンに直接影響を与えた
- **記事での表現**: 「Servlet Filterは、Chain of Responsibilityパターンに基づくリクエスト/レスポンスの逐次処理機構であり、この概念は後のWebフレームワークのミドルウェアパターンに直接受け継がれている」
