# ファクトチェック記録：第4回「PHP——Webの民主化とその代償」

## 1. PHP/FIの誕生（Rasmus Lerdorf、1994-1995年）

- **結論**: Rasmus Lerdorfが1994年にCGIバイナリのセットとしてPHPを作成。1995年6月8日にUsenetグループcomp.infosystems.www.authoring.cgiで「Personal Home Page Tools (PHP Tools) version 1.0」として公開。1995年9月にForms Interpreter (FI)として拡張、1995年10月にPHP/FI として完全書き直し
- **一次ソース**: PHP Manual, "History of PHP"; Rasmus Lerdorf Usenet post (1995-06-08)
- **URL**: <https://www.php.net/manual/en/history.php.php>
- **注意事項**: 「Personal Home Page」は後に「PHP: Hypertext Preprocessor」（再帰的頭字語）に改称
- **記事での表現**: Rasmus Lerdorfが1994年に自身のオンライン履歴書のアクセス追跡用にC言語で書いたCGIバイナリが起源。1995年6月にPHP Tools 1.0として公開

## 2. PHP 3（1998年、Zeev SuraskiとAndi Gutmans）

- **結論**: テルアビブ在住のZeev SuraskiとAndi Gutmansが、大学プロジェクトのeコマースアプリケーション開発でPHP/FI 2.0の性能不足に不満を抱き、1997年にパーサを完全書き直し。PHP 3.0は1998年6月に公式リリース
- **一次ソース**: PHP Manual, "History of PHP"
- **URL**: <https://www.php.net/manual/en/history.php.php>
- **注意事項**: PHP 3でPHPは「個人のホームページツール」から本格的なプログラミング言語への転換点を迎えた
- **記事での表現**: 1997年、イスラエル・テルアビブの2人の開発者がPHP/FIを完全に書き直し、1998年6月にPHP 3として公開した

## 3. PHP 4（Zend Engine、2000年5月）とPHP 5（OOP強化、2004年7月）

- **結論**: PHP 4.0は2000年5月22日リリース、Zend Engine 1.0搭載。PHP 5.0は2004年7月1日リリース、Zend Engine 2.0搭載。PHP 5ではオブジェクト指向プログラミングが大幅に強化（イテレータ、例外処理等）
- **一次ソース**: PHP Wikipedia; PHP Manual
- **URL**: <https://en.wikipedia.org/wiki/PHP>
- **注意事項**: 「Zend」はZeevとAndiの名前を組み合わせた造語
- **記事での表現**: 2000年5月のPHP 4（Zend Engine 1.0）、2004年7月のPHP 5（Zend Engine 2.0）で本格的なOOP対応

## 4. PHP 6の頓挫とPHP 7（2015年12月3日）

- **結論**: 2005年にUnicode（UTF-16内部表現、ICUライブラリ組み込み）対応としてPHP 6が開発開始されたが、開発者不足とUTF-16のパフォーマンス問題で2010年3月に公式に断念。残りの非Unicode機能はPHP 5.4に統合。混乱回避のため2014年のコミュニティ投票（賛成58、反対24）でバージョン7に飛ぶことを決定。PHP 7.0は2015年12月3日リリース、phpng（Dmitry Stogov, Xinchen Hui, Nikita Popov）ベースのZend Engine 3搭載、PHP 5.6比で最大2倍の性能向上
- **一次ソース**: PHP RFC: php6; PHP Wikipedia
- **URL**: <https://wiki.php.net/rfc/php6>, <https://en.wikipedia.org/wiki/PHP>
- **注意事項**: PHP 6の書籍が既に出版されていたことも混乱の一因
- **記事での表現**: PHP 6はUnicode対応の野心的計画だったが2010年に頓挫。バージョン番号は7に飛び、2015年12月にPHP 7がリリースされた。性能はPHP 5.6の約2倍

## 5. PHP 8とJITコンパイラ（2020年11月26日）

- **結論**: PHP 8.0は2020年11月26日にGA（一般提供）リリース。主要機能はJIT（Just-In-Time）コンパイラ、名前付き引数、アトリビュート、Union型、match式等。JITはOPcacheの一部として実装され、ホットコードを機械語に変換。数値計算で顕著な性能向上
- **一次ソース**: PHP.Watch; Kinsta Blog; Zend Blog
- **URL**: <https://php.watch/versions/8.0/JIT>, <https://kinsta.com/blog/php-8/>
- **注意事項**: JITによるWeb アプリケーション全般の性能向上は数値計算ほど劇的ではない
- **記事での表現**: 2020年11月のPHP 8でJITコンパイラが導入された

## 6. WordPressの誕生と普及（2003年〜）

- **結論**: 2003年5月27日、Matt MullenwegとMike Littleが開発停止したb2/cafelogをフォークしてWordPress最初のバージョンをリリース。Mullenwegは2003年1月24日のブログ投稿でフォーク構想を表明、Littleが最初にコメントで参加表明。W3Techs（2026年1月時点）によると、全Webサイトの43.5%がWordPressで運営
- **一次ソース**: WordPress.org; W3Techs; WPBeginner
- **URL**: <https://en.wikipedia.org/wiki/WordPress>, <https://www.wpbeginner.com/news/the-history-of-wordpress/>
- **注意事項**: b2/cafelogはMichel ValdrighiがPHP+MySQLで開発したブログソフトウェア
- **記事での表現**: 2003年5月、Matt MullenwegとMike Littleがb2/cafelogをフォークしてWordPressを公開した。2026年現在、全Webサイトの約43%がWordPressで運営されている

## 7. W3Techs PHPサーバサイドシェア

- **結論**: W3Techs（2026年3月時点）によると、サーバサイドプログラミング言語が検出可能なWebサイトのうち約75%以上がPHPを使用。WordPressの普及が主要な牽引力
- **一次ソース**: W3Techs, "Usage Statistics and Market Share of PHP for Websites, March 2026"
- **URL**: <https://w3techs.com/technologies/details/pl-php>
- **注意事項**: サーバサイド言語が検出可能なサイトに限定した割合。全サイトではない
- **記事での表現**: W3Techsの2026年調査で、サーバサイド言語が検出可能なWebサイトの75%以上がPHPを使用

## 8. PHPのshared-nothingアーキテクチャ

- **結論**: PHPはデフォルトでshared-nothingアーキテクチャを採用する唯一の主要言語。プロセス内の全状態は単一のHTTPリクエスト/レスポンスのライフサイクル内でのみ存在し、リクエスト完了後に破棄される。共有が必要なデータはデータベースやファイルシステムに委譲。これにより線形スケーラビリティが実現
- **一次ソース**: Tideways Blog; GitHub Gist by CMCDragonkai
- **URL**: <https://tideways.com/profiler/blog/php-shared-nothing-architecture-the-benefits-and-downsides>
- **注意事項**: この設計はCGIの「リクエストごとにプロセス起動」モデルの直系の思想
- **記事での表現**: PHPのshared-nothingアーキテクチャは、リクエストごとに状態がリセットされる設計であり、CGIの思想を洗練させたものである

## 9. register_globalsとPHPセキュリティ問題

- **結論**: register_globalsはGET/POST/COOKIEデータを自動的にグローバル変数に展開する機能。PHP 4.2.0（2002年）でデフォルト無効化、PHP 5.4.0（2012年）で完全削除。この機能は変数の意図しない上書きによるXSS、SQLインジェクション、LFI/RFI等の脆弱性の温床だった
- **一次ソース**: PHP Manual; Beagle Security; Acunetix
- **URL**: <https://beaglesecurity.com/blog/vulnerability/php-register-globals-enabled.html>
- **注意事項**: PHP 4.2.0でデフォルト無効化は大きな転換点だったが、多くのホスティングが有効のまま運用し続けた
- **記事での表現**: register_globalsはPHPの「民主化」の代償の象徴。外部入力を自動的にグローバル変数に展開するこの機能は、無数のセキュリティ脆弱性を生み出した

## 10. mod_phpの性能（CGI比300-500%向上）

- **結論**: mod_php（DSO）はPHPインタプリタをApacheプロセスに組み込む方式。CGI比で300-500%の性能向上を実現。PHP設定の再パースが不要になることが主因。ただしApacheプロセスのメモリフットプリントは増大
- **一次ソース**: Layershift Blog; Chris Wiegman Blog
- **URL**: <https://blog.layershift.com/which-php-mode-apache-vs-cgi-vs-fastcgi/>
- **注意事項**: 第3回で解説したmod_perlと同じ「インタプリタ組み込み」アプローチ
- **記事での表現**: mod_phpはCGI比で3〜5倍の性能向上を実現した。第3回で見たmod_perlと同じ設計思想である

## 11. PHP-FPMの歴史

- **結論**: PHP-FPMの原作者はAndrei Nigmatulin（2004年頃から開発）。2009年半ばにモジュラー形式に変更。PHP 5.3.3（2010年7月22日リリース）でPHP本体にマージ・同梱。適応的プロセス生成、新INIフォーマット等の改善を含む
- **一次ソース**: php-fpm.org; PHP Manual
- **URL**: <https://php-fpm.org/about/>, <https://www.php.net/manual/en/install.fpm.php>
- **注意事項**: 第3回のFastCGIの「疎結合」思想の直系
- **記事での表現**: 2010年、PHP 5.3.3でPHP-FPMが本体にマージされた。FastCGIの思想をPHP専用に最適化した実装である

## 12. CakePHP（2005年）とLaravel（2011年）

- **結論**: CakePHPは2005年4月にポーランドのプログラマMichal Tatarynowiczが開発開始。Ruby on Railsに触発されたPHP初のMVCフレームワーク。バージョン1.0は2006年5月リリース。Laravelは2011年6月にTaylor Otwellがリリース。CodeIgniterの代替として開発、Bladeテンプレート、IoC、Eloquent ORM等を搭載
- **一次ソース**: CakePHP Wikipedia; Laravel Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/CakePHP>, <https://en.wikipedia.org/wiki/Laravel>
- **注意事項**: PHPフレームワークの進化は第10回で詳述予定
- **記事での表現**: 2005年のCakePHP、2011年のLaravel——PHPの世界にもフレームワーク革命は訪れた。だが本回では「フレームワーク以前」の素のPHPに焦点を当てる
