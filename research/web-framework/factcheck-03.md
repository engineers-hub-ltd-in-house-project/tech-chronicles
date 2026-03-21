# ファクトチェック記録：第3回「Webサーバの進化——Apache, mod_perl, FastCGI」

## 1. Apache HTTP Serverの誕生とバージョン履歴

- **結論**: Apache HTTP Server 0.6.2は1995年4月にリリース。1.0は1995年12月1日にリリース。NCSA HTTPdのパッチ集約から始まった。Brian Behlendorfがメーリングリスト・共有スペースを立ち上げ、開発を主導した
- **一次ソース**: Apache HTTP Server Project, "About Apache"
- **URL**: <https://httpd.apache.org/ABOUT_APACHE.html>
- **注意事項**: 「a patchy server」という名前の由来はBrian Behlendorf自身が後年語ったもの。第2回で簡潔に触れているため、第3回ではApacheの技術的進化（モジュールアーキテクチャ、MPM）に焦点を当てる
- **記事での表現**: Apache 1.0が1995年12月にリリースされ、1年以内にNCSA HTTPdを抜いて最も使用されるWebサーバとなった事実を前提として記述

## 2. Apacheの市場シェア推移（Netcraft調査）

- **結論**: 1995年8月のNetcraft初回調査ではNCSA HTTPdが57%、Apacheは3.5%。1996年4月にApacheが29%で首位に。1996年12月には41%（247,419サイト）
- **一次ソース**: Netcraft Web Server Survey (December 1996), Cybercultural "1995: Apache and Microsoft IIS Shake Up Web Server Market"
- **URL**: <https://news.netcraft.com/archives/1996/12/01/december_1996_web_server_survey.html>, <https://cybercultural.com/p/1995-apache-microsoft-iis-web-server-market/>
- **注意事項**: 調査時期によって数値が異なる。1996年4月の29%は「Apacheとその派生」の合算値
- **記事での表現**: Netcraft調査を引用し、Apacheが1年足らずで市場を制覇した事実を記述

## 3. mod_perlの誕生と開発経緯

- **結論**: 最初のmod_perlはGisle Aasが開発し、1996年3月25日にリリース。Doug MacEachernがPerl埋め込みの問題に取り組み、1996年5月1日にバージョン0.50a1を公開。1996年8月にPAUSE（Perl Authors Upload Server）が最初のmod_perl本番サーバとなった。1999年のApacheConでASFプロジェクトに
- **一次ソース**: mod_perl: History, The Apache Software Foundation
- **URL**: <https://perl.apache.org/about/history.html>
- **注意事項**: 「Doug MacEachernが作った」と単純化しがちだが、最初のプルーフ・オブ・コンセプトはGisle Aas。MacEachernは初期から関与し、その後の開発を主導した
- **記事での表現**: Gisle Aasの最初の実装（1996年3月）とDoug MacEachernの貢献（1996年5月〜）の両方を正確に記述

## 4. mod_perlのパフォーマンス

- **結論**: ベンチマークテストでmod_perlはCGI比で約20-28倍の速度向上を示した（MySQL hits counterスクリプトで100回反復: CGI 56秒 vs mod_perl 2秒）。別のテストではmod_cgi 156 req/sec vs mod_perl 856 req/sec。「100-200倍の速度向上」という表現も一次ソースにある
- **一次ソース**: Practical mod_perl (O'Reilly), mod_perl Performance Tuning (Apache Software Foundation)
- **URL**: <https://perl.apache.org/docs/1.0/guide/performance.html>, <https://www.oreilly.com/library/view/practical-mod_perl/0596002270/ch09.html>
- **注意事項**: 「100-200倍」はスクリプトの複雑さやモジュール読み込み量に依存する。シンプルなスクリプトでは差が大きく、複雑な処理では差が縮まる
- **記事での表現**: 「CGI比で数十倍の速度向上」と記述し、具体的なベンチマーク結果を引用

## 5. FastCGIの誕生と設計

- **結論**: Mark R. BrownがFastCGI仕様を設計・開発し、1996年4月29日にOpen Market, Inc.から公開。Netscape NSAPI への対抗として開発された側面がある。バイナリプロトコルで、UNIXドメインソケットまたはTCPソケットを介した通信を使用。永続プロセスモデル
- **一次ソース**: FastCGI Specification (Mark R. Brown, Open Market), FastCGI Archives
- **URL**: <https://fastcgi-archives.github.io/FastCGI_Specification.html>, <https://fastcgi-archives.github.io/FastCGI_A_High-Performance_Web_Server_Interface_FastCGI.html>
- **注意事項**: Open Market社は後にFatWireに買収された。FastCGIの仕様は事実上のオープン仕様として広く実装された
- **記事での表現**: Mark R. Brownの名前とOpen Market社、1996年4月の公開日を明記

## 6. NSAPI（Netscape Server Application Programming Interface）

- **結論**: Rob McCoolがNetscape移籍後にNSAPIを開発。Netscape Enterprise Server 3.0（1996年）で導入。サーバプロセス内でプラグインとして動作するAPI。NSAPIの後にMicrosoftがISAPI、ApacheがApache APIを開発
- **一次ソース**: Wikipedia - Netscape Server Application Programming Interface
- **URL**: <https://en.wikipedia.org/wiki/Netscape_Server_Application_Programming_Interface>
- **注意事項**: NSAPIはCGIの遅さを解決する「プロプライエタリ」なアプローチの代表例。FastCGIはNSAPIへの「オープンな対抗」として位置づけられる
- **記事での表現**: 1996年に同時多発的に現れた「CGIの遅さ」への解決策の一つとして言及

## 7. ISAPI（Internet Server Application Programming Interface）

- **結論**: MicrosoftがIIS向けに開発したサーバ拡張API。IIS 2.0（1996年、Windows NT 4.0同梱）で本格導入。Extensions（アプリケーション）とFilters（リクエスト処理パイプライン）の2種類。DLLとしてコンパイルされ、サーバプロセス内で実行
- **一次ソース**: Microsoft Learn - ISAPI Extension Overview, Wikipedia - Internet Server Application Programming Interface
- **URL**: <https://en.wikipedia.org/wiki/Internet_Server_Application_Programming_Interface>
- **注意事項**: ISAPIはWindows/IIS専用であり、UNIXエコシステムとは異なるアプローチ
- **記事での表現**: CGIの遅さへの各社の対応として、NSAPI・ISAPIを並列で言及

## 8. Apache 2.0とMPMアーキテクチャ

- **結論**: Apache 2.0は2002年4月6日にGA（一般利用可能）リリース。MPM（Multi-Processing Modules）アーキテクチャを導入。prefork（プロセスベース、Apache 1.x互換）、worker（スレッドベース）、後にevent（Apache 2.4、2012年）を追加。Apache 2.4ではeventがデフォルトMPM
- **一次ソース**: Apache HTTP Server Documentation - Multi-Processing Modules
- **URL**: <https://httpd.apache.org/docs/2.4/mpm.html>
- **注意事項**: Apache 2.0の開発は2000年に開始。MPMの導入はApacheのモジュラーアーキテクチャの延長線上にある
- **記事での表現**: Apache 2.0（2002年）のMPM導入を、mod_perl/FastCGI以降のApacheの進化として記述

## 9. C10K問題

- **結論**: Dan Kegelが1999年に提唱。「1台のサーバで1万の同時接続を処理する」問題。当時のプロセス/スレッドベースのサーバ（Apache prefork等）ではスケーラビリティに限界があった。後にnginx（2004年、Igor Sysoev）やNode.js（2009年）のイベント駆動モデルが解決策となった
- **一次ソース**: Dan Kegel, "The C10K problem"
- **URL**: <https://www.kegel.com/c10k.html>
- **注意事項**: C10K問題自体は第3回の主題ではないが、mod_perl/FastCGIの限界を示す文脈で言及する価値がある
- **記事での表現**: Apache + mod_perl/FastCGIの組み合わせでも解決できなかった課題として、まとめで軽く言及

## 10. ApacheBench（ab）の歴史

- **結論**: 元々はAdam Twiss（Zeus Technology）が1996年に「ZeusBench V1.0」として開発。その後Apacheグループにライセンス（寄贈）され、「ab」に改名。1997-1998年からApache HTTP Serverにバンドルされている
- **一次ソース**: Wikipedia - ApacheBench
- **URL**: <https://en.wikipedia.org/wiki/ApacheBench>
- **注意事項**: abはシングルスレッドで動作するため、高性能サーバのベンチマークではab自体がボトルネックになりうる。ハンズオンではこの制約に言及する
- **記事での表現**: ハンズオンでCGI vs FastCGIのベンチマーク比較に使用。歴史的背景も簡潔に紹介

---

## ファクトチェックサマリー

| #  | 項目                                     | 状態     |
| -- | ---------------------------------------- | -------- |
| 1  | Apache HTTP Serverの誕生とバージョン履歴 | 検証済み |
| 2  | Apacheの市場シェア推移                   | 検証済み |
| 3  | mod_perlの誕生と開発経緯                 | 検証済み |
| 4  | mod_perlのパフォーマンス                 | 検証済み |
| 5  | FastCGIの誕生と設計                      | 検証済み |
| 6  | NSAPI                                    | 検証済み |
| 7  | ISAPI                                    | 検証済み |
| 8  | Apache 2.0とMPMアーキテクチャ            | 検証済み |
| 9  | C10K問題                                 | 検証済み |
| 10 | ApacheBench（ab）の歴史                  | 検証済み |

検証済み: 10/10（品質ゲート: 6項目以上 → 合格）
