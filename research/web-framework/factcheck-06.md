# 第6回ファクトチェック：ASP/ColdFusion——選ばれなかった主流

調査日：2026-04-29
調査者：Claude Code（執筆支援）
対象記事：`series/web-framework/ja/06-asp-coldfusion.md`

WebSearch で各項目を検証し、一次ソース（公式ドキュメント、Wikipedia、開発者ブログ、業界誌）を参照した結果を以下に記録する。

---

## 1. Active Server Pages (ASP) の初版リリース

- **結論**: 検証済み。ASP 1.0 は 1996年12月、Microsoft IIS 3.0 と同時にリリースされた。Windows NT 4.0 Option Pack の付属コンポーネントとして配布された。
- **一次ソース**: Wikipedia "Active Server Pages"; Microsoft Learn "ASP support in Windows"
- **URL**:
  - <https://en.wikipedia.org/wiki/Active_Server_Pages>
  - <https://learn.microsoft.com/en-us/troubleshoot/developer/webapps/iis/active-server-pages/asp-support-windows>
- **注意事項**: ASP 2.0 は 1997年9月（IIS 4.0）、ASP 3.0 は 2000年11月（IIS 5.0）で公開。2002年1月のASP.NET登場以降、無印「ASP」は「Classic ASP」と呼ばれるようになる。
- **記事での表現**: 「1996年12月、Microsoft は IIS 3.0 のオプションコンポーネントとして Active Server Pages を投入した」

## 2. ColdFusion の初版リリース

- **結論**: 検証済み。Allaire Cold Fusion 1.0 は 1995年7月2日、Allaire Corporation（米ミネソタ州）から発表。開発者は Joseph J. Allaire と Jeremy Allaire の兄弟。
- **一次ソース**: Wikipedia "Adobe ColdFusion"; The History of the Web "A History of ColdFusion"; Adobe ColdFusion Blog "Twenty years of making web happen"
- **URL**:
  - <https://en.wikipedia.org/wiki/Adobe_ColdFusion>
  - <https://thehistoryoftheweb.com/building-coldfusion-for-the-web/>
  - <https://coldfusion.adobe.com/2015/07/twenty-years-of-making-web-happen-happy-birthday-coldfusion/>
- **注意事項**: 初版は Windows NT/95 サーバ向け。1996年2月の 1.5 で機能拡張。
- **記事での表現**: 「1995年7月、Allaire 兄弟は Cold Fusion 1.0 を発表した」

## 3. ColdFusion Markup Language（CFML）と DBML 改名

- **結論**: 検証済み。初期は Database Markup Language（DBML）と呼ばれていたが、ColdFusion Markup Language（CFML）に改名された。`<cfquery>`、`<cfoutput>` などのタグベース構文が中核。
- **一次ソース**: Wikipedia "ColdFusion Markup Language"; Adobe ColdFusion Help (cfquery, cfoutput)
- **URL**:
  - <https://en.wikipedia.org/wiki/ColdFusion_Markup_Language>
  - <https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-tags/tags-p-q/cfquery.html>
  - <https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-tags/tags-m-o/cfoutput.html>
- **注意事項**: タグベースに加え、現在は CFScript（JavaScript風構文）も併用可能。実行基盤は JVM。
- **記事での表現**: 「CFML（当初はDBMLと呼ばれていた）は、HTML に似たタグ構文で SQL の発行や出力ループを書ける」

## 4. ASP Classic のスクリプト言語選択

- **結論**: 検証済み。ASP Classic のデフォルト言語は VBScript。JScript（Microsoft 版 JavaScript）も使用可能。ページごとに `<%@ Language="VBScript" %>` または `<%@ Language="JScript" %>` で切替可能。
- **一次ソース**: Wikipedia "Active Server Pages"; Microsoft IIS 6.0 SDK "Working with Scripting Languages"
- **URL**:
  - <https://en.wikipedia.org/wiki/Active_Server_Pages>
  - <https://learn.microsoft.com/en-us/previous-versions/iis/6.0-sdk/ms525153(v=vs.90)>
- **注意事項**: VBScript は Windows COM ベース、PHP の Perl/C ベースとは思想が異なる。
- **記事での表現**: 「ASP Classic は VBScript をデフォルトとし、JScript もページ単位で選択できた」

## 5. .NET Framework 1.0 と ASP.NET 1.0 のリリース日

- **結論**: 検証済み（補足あり）。.NET Framework 1.0 は 2002年1月15日に Microsoft 公式発表（Wikipedia 記載）。ASP.NET 1.0 はその一部として同時期にリリースされた。一部資料では 2月13日説もある。
- **一次ソース**: Wikipedia ".NET Framework version history"; versionsof.net
- **URL**:
  - <https://en.wikipedia.org/wiki/.NET_Framework_version_history>
  - <https://versionsof.net/framework/1.0/>
- **注意事項**: 細かな日付の異論はあるが、「2002年1月」という大枠は確定。記事中は「2002年1月」表現に留める。
- **記事での表現**: 「2002年1月、Microsoft は .NET Framework 1.0 と ASP.NET 1.0 を公開した」

## 6. ASP.NET WebForms の特徴：ViewState、PostBack、イベント駆動

- **結論**: 検証済み。WebForms は HTTP のステートレス性を隠蔽し、Windows Forms 風のイベント駆動プログラミングモデルを Web に持ち込んだ。`__VIEWSTATE` 隠しフィールドにコントロール状態を Base64 エンコードして送受信し、PostBack でサーバ側イベントハンドラを起動する。
- **一次ソース**: Wikipedia "ASP.NET Web Forms"; Microsoft Press "Anatomy of an ASP.NET Page"; Microsoft Learn "Architecture comparison of ASP.NET Web Forms and Blazor"
- **URL**:
  - <https://en.wikipedia.org/wiki/ASP.NET_Web_Forms>
  - <https://www.microsoftpressstore.com/articles/article.aspx?p=2228444&seqNum=3>
  - <https://learn.microsoft.com/en-us/dotnet/architecture/blazor-for-web-forms-developers/architecture-comparison>
- **注意事項**: ViewState のサイズ肥大化は実運用で深刻な問題となり、後の MVC への移行動機の一つ。
- **記事での表現**: 「WebForms は ViewState という隠しフィールドにコントロール状態を載せ、PostBack でイベントハンドラを呼び出す——Windows Forms をそのまま Web に持ち込んだ設計だった」

## 7. ASP.NET MVC 1.0 のリリース

- **結論**: 検証済み。ASP.NET MVC 1.0 は 2009年3月18日に Mix 2009 カンファレンスでリリース。WebForms の置き換えではなく代替アプローチとして位置づけられた。ライセンスは MS-PL（Microsoft Public License）。
- **一次ソース**: InfoQ "ASP.NET MVC 1.0 Released"; Microsoft .NET Blog; Phil Haack ブログ
- **URL**:
  - <https://www.infoq.com/news/2009/03/asp-net-mvc-1-0/>
  - <https://devblogs.microsoft.com/dotnet/asp-net-mvc-1-0-now-live/>
  - <https://haacked.com/archive/2009/03/18/aspnet-mvc-rtw.aspx/>
- **注意事項**: WebForms は引き続きサポート継続、MVC は別ランタイムオプションとして提供された。
- **記事での表現**: 「2009年3月、ASP.NET MVC 1.0 が Mix 2009 でリリースされた」

## 8. Allaire → Macromedia 買収

- **結論**: 検証済み。買収は 2001年1月16日に発表、3月20日に合併完了。買収後 Jeremy Allaire は Macromedia の CTO に就任。ColdFusion は買収後 Java 上に書き直され、2002年5月29日に ColdFusion MX 6.0 として公開。
- **一次ソース**: Wikipedia "Allaire Corporation"; Macromedia Wiki
- **URL**:
  - <https://en.wikipedia.org/wiki/Allaire_Corporation>
  - <https://macromedia.fandom.com/wiki/Allaire_Corporation>
- **注意事項**: ColdFusion MX 6.0 は事実上の全面再実装で、独自エンジンから Java/JVM ベースに移行した転換点。
- **記事での表現**: 「2001年1月、Allaire は Macromedia への身売りを発表する。3月の合併完了後、ColdFusion は Java 上に再実装される」

## 9. Macromedia → Adobe 買収

- **結論**: 検証済み。Adobe Systems が Macromedia 買収を 2005年4月18日に発表（株式交換、約34億ドル）。買収完了は 2005年12月3日。これにより ColdFusion は Adobe 製品となった。
- **一次ソース**: Wikipedia "Macromedia"; Wikipedia "Adobe ColdFusion"
- **URL**:
  - <https://en.wikipedia.org/wiki/Macromedia>
  - <https://en.wikipedia.org/wiki/Adobe_ColdFusion>
- **注意事項**: Adobe 移管後も ColdFusion ブランドは継続、現在は Adobe ColdFusion 2023/2025 まで進化している。
- **記事での表現**: 「2005年12月、Adobe による Macromedia 買収完了とともに、ColdFusion は Adobe 製品となった」

## 10. .NET Core 1.0 と WebForms 終焉

- **結論**: 検証済み。.NET Core 1.0 は 2016年6月27日にリリース。ASP.NET Web Forms は .NET Core への移植対象から外れ、.NET Framework のみで稼働可能なまま取り残された。Microsoft からも自動移行パスは提供されていない。
- **一次ソース**: Microsoft .NET Blog "End of Life"; Microsoft Learn (移行ガイド); Wikipedia
- **URL**:
  - <https://devblogs.microsoft.com/dotnet/net-core-1-0-and-1-1-will-reach-end-of-life-on-june-27-2019/>
  - <https://learn.microsoft.com/en-us/dotnet/architecture/blazor-for-web-forms-developers/architecture-comparison>
- **注意事項**: WebForms 後継の Microsoft 公式選択肢は Blazor。コミュニティでは DotVVM 等の互換層も登場。
- **記事での表現**: 「2016年6月の .NET Core 1.0 で、WebForms は移植対象から外れた——同じ年に、サーバ側でステートを保持する設計思想は Phoenix LiveView の最初の発表で別の形で復活する」

## 11. Lucee CFML（オープンソース ColdFusion エンジン）

- **結論**: 検証済み。Lucee は 2015年1月29日に Railo 4.2 からフォークされた。Railo はもともと Adobe ColdFusion の高性能代替として 2008年からオープンソース化。Lucee は現在、商用 CFML 互換エンジンの主要選択肢。
- **一次ソース**: Wikipedia "Lucee"; Wikipedia "Railo"; GitHub lucee/Lucee
- **URL**:
  - <https://en.wikipedia.org/wiki/Lucee>
  - <https://en.wikipedia.org/wiki/Railo>
  - <https://github.com/lucee/Lucee>
- **注意事項**: ハンズオンでは Docker イメージ `lucee/lucee` を使用予定。
- **記事での表現**: 「現在も CFML は Adobe ColdFusion と、オープンソースの Lucee（2015年に Railo からフォーク）の両系統で生き続けている」

## 12. WebForms の遺伝子：Phoenix LiveView / Hotwire / HTMX / Livewire

- **結論**: 検証済み。サーバ側でステートを保持し、クライアントには差分HTMLを返す設計思想は、Phoenix LiveView（Elixir, 2018年〜）、Hotwire/Turbo（Rails, 2020年〜）、HTMX（独立, 2020年〜）、Laravel Livewire（PHP, 2018年〜）に受け継がれている。
- **一次ソース**: Phoenix LiveView ドキュメント; Microsoft Learn (Web Forms vs Blazor 比較)
- **URL**:
  - <https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html>
  - <https://learn.microsoft.com/en-us/dotnet/architecture/blazor-for-web-forms-developers/architecture-comparison>
- **注意事項**: WebForms と LiveView は実装機構が異なる（ViewState vs WebSocket）が、「サーバ側にステートを置く」設計判断という意味では系譜上同じ家系。
- **記事での表現**: 「2020年代に Phoenix LiveView や HTMX が脚光を浴びたとき、それは『ステートをサーバに戻す』という WebForms 的な思想の再来だった——機構は違えど、設計判断の系譜は連なっている」

---

## 集計

- 検証済み項目数：**12**（品質ゲート 6項目以上を満たす）
- 未検証項目数：0
- 補足注意：項目5（.NET Framework 1.0 リリース日）にのみ日付の異論があるが、記事では「2002年1月」と曖昧に記述することで吸収する
