# ファクトチェック記録：第2回「CGIという原点——HTTPリクエストを手で受けた時代」

## 1. CGI仕様の誕生——Rob McCool、NCSA、1993年

- **結論**: CGIは1993年、NCSA（National Center for Supercomputing Applications）においてRob McCoolが中心となって策定した。McCoolはNCSA HTTPdの開発者であり、www-talkメーリングリストでの議論を経て、1993年12月4日までにCGI仕様をHTMLドキュメントとしてまとめた（hoohoo.ncsa.uiuc.edu/cgi/）。他のWebサーバ開発者（CERN httpd、Plexusなど）もこれを採用し、事実上の標準となった
- **一次ソース**: Wikipedia "Common Gateway Interface", Cybercultural "1993: CGI Scripts and Early Server-Side Web Programming"
- **URL**: <https://en.wikipedia.org/wiki/Common_Gateway_Interface>, <https://cybercultural.com/p/1993-cgi-scripts-and-early-server-side-web-programming/>
- **注意事項**: 第1回記事で「当初はCommon Gateway Protocolと呼ばれていた」と記述しているが、WebSearchでは「Common Gateway Protocol」から改称されたという情報は確認できなかった。第2回では「Common Gateway Interface」として一貫して記述する
- **記事での表現**: 「1993年、NCSAのRob McCoolがwww-talkメーリングリストでの議論を主導し、CGI仕様を策定した」

## 2. NCSA HTTPdの歴史とApacheへの系譜

- **結論**: NCSA HTTPdは1993年にRob McCoolが開発。McCoolは1994年中頃にNCSAを離れNetscapeに移籍。開発停滞後、Brian Behlendorfらがパッチを集約し、1995年4月にApache 0.6.2を公開。Apache 1.0は1995年12月1日リリース。1年以内にNCSAを抜き最も使用されるWebサーバとなった
- **一次ソース**: Apache HTTP Server Project "ABOUT_APACHE", Wikipedia "NCSA HTTPd", Wikipedia "Rob McCool"
- **URL**: <https://httpd.apache.org/ABOUT_APACHE.html>, <https://en.wikipedia.org/wiki/NCSA_HTTPd>, <https://en.wikipedia.org/wiki/Rob_McCool>
- **注意事項**: McCoolはイリノイ大学アーバナ・シャンペーン校の学部生時代にNCSA HTTPdを開発した
- **記事での表現**: 「Rob McCoolがNCSAを離れた後、残されたパッチを集めて作られたのがApacheだった——'a patchy server'という名前の由来がそれを物語る」

## 3. RFC 3875——CGI/1.1の正式仕様化（2004年）

- **結論**: 1997年11月にKen Coarを中心とするワーキンググループが発足し、NCSAのCGI定義をより正式に文書化する作業を開始。結果としてRFC 3875が2004年10月に公開された。著者はD. RobinsonとK. Coar（The Apache Software Foundation）。Informational RFCであり、Internet Standardではない
- **一次ソース**: RFC Editor, IETF Datatracker
- **URL**: <https://www.rfc-editor.org/rfc/rfc3875>, <https://datatracker.ietf.org/doc/html/rfc3875>
- **注意事項**: 1993年の誕生から2004年のRFC化まで11年間、CGIは正式な規格なしに事実上の標準として機能し続けた
- **記事での表現**: 「CGIが正式にRFC 3875として文書化されたのは2004年——誕生から11年後のことである。それほど長い間、事実上の標準として正式な規格なしに機能し続けた」

## 4. CGIの仕組み——環境変数・標準入出力・プロセスフォーク

- **結論**: CGIはWebサーバが外部プログラムを新プロセスとして起動し、リクエスト情報を環境変数（REQUEST_METHOD, QUERY_STRING, CONTENT_LENGTH, CONTENT_TYPE等）で渡し、プログラムの標準出力をHTTPレスポンスとして返す仕組み。RFC 3875で定義されるメタ変数はAUTH_TYPE, CONTENT_LENGTH, CONTENT_TYPE, GATEWAY_INTERFACE, PATH_INFO, PATH_TRANSLATED, QUERY_STRING, REMOTE_ADDR, REMOTE_HOST, REMOTE_IDENT, REMOTE_USER, REQUEST_METHOD, SCRIPT_NAME, SERVER_NAME, SERVER_PORT, SERVER_PROTOCOL, SERVER_SOFTWAREの17種
- **一次ソース**: RFC 3875, Apache HTTP Server Documentation
- **URL**: <https://datatracker.ietf.org/doc/html/rfc3875>, <https://httpd.apache.org/docs/2.4/howto/cgi.html>
- **注意事項**: POSTメソッドの場合、リクエストボディは標準入力から読み取る。CONTENT_LENGTHで読み取るバイト数を判断する
- **記事での表現**: 「環境変数と標準入出力——UNIXプログラマなら誰でも知っているこの2つの仕組みが、CGIの全てだった」

## 5. CGIのパフォーマンス問題——プロセス生成コスト

- **結論**: CGIの主要な問題はパフォーマンスである。リクエストごとに新しいプロセスを生成（fork/exec）し、処理完了後に破棄する。このプロセス生成・破棄のオーバーヘッドは、特にPerlやPythonなどのインタプリタ言語では、実際の処理よりもプロセス起動コストの方が大きくなることがあった。同時接続数が増えると壊滅的なパフォーマンス劣化を招いた
- **一次ソース**: FastCGI Archives, O'Reilly "Web Performance Tuning"
- **URL**: <https://fastcgi-archives.github.io/FastCGI_A_High-Performance_Web_Server_Interface_FastCGI.html>, <https://www.oreilly.com/library/view/web-performance-tuning/1565923790/apbs08.html>
- **注意事項**: CGIの「遅さ」は必ずしもプロトコル自体の問題ではなく、実装方式（リクエストごとのfork/exec）に起因する
- **記事での表現**: 「リクエストが来るたびにPerlインタプリタを起動し、スクリプトをコンパイルし、実行し、プロセスを破棄する——この一連のオーバーヘッドが、CGIの致命的な弱点だった」

## 6. Perl——CGI時代の支配的言語

- **結論**: Perlは1987年12月18日にLarry WallがUnisys在籍中にバージョン1.0をリリース。1990年代にCGIスクリプティング言語として爆発的に普及した。正規表現・文字列処理の強力さ、CGI.pmモジュールの存在、CPANリポジトリの充実が普及を後押しした。「Webのグルー（接着剤）」と呼ばれた
- **一次ソース**: Wikipedia "Perl", EDN "Perl programming language released, December 18, 1987", perl.com "Perl and CGI"
- **URL**: <https://en.wikipedia.org/wiki/Perl>, <https://www.edn.com/perl-programming-language-released-december-18-1987/>, <https://www.perl.com/article/perl-and-cgi/>
- **注意事項**: Perlは元々「Pearl」と名付けられたが、既存のPEARL言語の存在を知り「a」を削除した
- **記事での表現**: 「1990年代後半のWeb開発において、PerlはCGIと同義語だった。正規表現の強力さ、テキスト処理の柔軟さ、そしてLincoln SteinのCGI.pmモジュールが、PerlをWebプログラミングの第一言語に押し上げた」

## 7. CGI.pm——Lincoln Steinの貢献

- **結論**: CGI.pmはLincoln Stein（MIT Genome Centre / Whitehead Institute所属の生物情報学者）が開発したPerlモジュール。CGIプログラミングにおけるフォームデータの取得・HTML生成を簡素化した。1998年にWileyから『Official Guide to Programming with CGI.pm』が出版された。Perl 5.22（2015年）で非推奨化
- **一次ソース**: Wikipedia "CGI.pm", blogs.perl.org "A Fond Farewell to CGI.pm"
- **URL**: <https://en.wikipedia.org/wiki/CGI.pm>, <https://blogs.perl.org/users/perrin_harkins/2013/06/a-fond-farewell-to-cgipm.html>
- **注意事項**: Lincoln Steinは本職がバイオインフォマティクス研究者であり、Web技術は「副業」的な貢献だった
- **記事での表現**: 「Lincoln Stein——本職はMITのゲノム研究者——が作ったCGI.pmは、CGIプログラミングの事実上の標準ライブラリとなった」

## 8. HTTP Cookieの発明——Lou Montulli、1994年

- **結論**: 1994年6月、Netscape CommunicationsのLou Montulliがhttp cookieを発明。John Giannandreaとともに最初のNetscape cookie仕様を策定。Mosaic Netscape 0.9beta（1994年10月13日リリース）でcookieをサポート。1995年に特許出願、1998年にUS patent 5774670として認可。1997年にIETF標準化
- **一次ソース**: History of Information, Wikipedia "HTTP cookie", Lou Montulli blog
- **URL**: <https://www.historyofinformation.com/detail.php?id=2102>, <https://en.wikipedia.org/wiki/HTTP_cookie>, <http://montulli.blogspot.com/2013/05/the-reasoning-behind-web-cookies.html>
- **注意事項**: cookieの概念自体は既存の「magic cookie」（UNIXプログラミングの用語）から着想を得たもの
- **記事での表現**: 「HTTPのステートレス性を補完するため、1994年にNetscapeのLou Montulliがcookieの仕組みを発明した——CGIが生み出した制約に対する最初のハックだった」

## 9. NCSA MosaicとHTMLフォームのサポート

- **結論**: NCSA Mosaicは1993年1月23日にMarc AndreessenがX Window System向けアルファ/ベータ版0.5を公開。1993年4月21日にバージョン1.0リリース。1993年11月10日のUnix版2.0でフォームサポートを追加し、最初の動的Webページの作成が可能になった。Marc Andreessenは後にNCSAを離れ、James H. ClarkとMosaic Communications Corporation（後のNetscape）を設立
- **一次ソース**: Wikipedia "NCSA Mosaic", Web Design Museum
- **URL**: <https://en.wikipedia.org/wiki/NCSA_Mosaic>, <https://www.webdesignmuseum.org/software/ncsa-mosaic-1-0-in-1993>
- **注意事項**: Mosaic 2.0のフォームサポートとCGIの組み合わせが、動的Webの実質的な起点となった
- **記事での表現**: 「1993年11月、Mosaic 2.0がHTMLフォームをサポートした。ブラウザからデータを送信し、CGIスクリプトで処理し、結果を返す——Webアプリケーションの原型がここに完成した」

## 10. CGIとステートレス性——HTTPの設計制約

- **結論**: HTTPは完全にステートレスなプロトコルとして設計された。各リクエストは独立しており、サーバは前のリクエストの情報を保持しない。CGIはこのステートレス性をそのまま継承した（リクエストごとにプロセスが起動・終了するため、状態を保持する場所がない）。この制約がWebアプリケーション開発における状態管理の課題を生み、cookieやセッション管理といった解決策が生まれた
- **一次ソース**: W3C "State in Web application design", Medium "Cookies and Sessions: Managing State in a Stateless Protocol"
- **URL**: <https://www.w3.org/2001/tag/doc/state-20060215>, <https://medium.com/@status-code/cookies-and-sessions-managing-state-in-a-stateless-protocol-c9cac6b6b78f>
- **注意事項**: ステートレス性はCGI固有の問題ではなくHTTPプロトコルの設計方針だが、CGIの「リクエストごとにプロセス起動」という仕組みがこの制約を一層強化した
- **記事での表現**: 「CGIのプロセスモデルは、HTTPのステートレス性を物理的に体現していた——リクエストが終わればプロセスごと消える。状態を持ちたくても持てない」
