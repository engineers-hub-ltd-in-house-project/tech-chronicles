# フレームワークという幻想

## ——Webアプリケーションの「当たり前」を疑う

### 第6回：ASP/ColdFusion——選ばれなかった主流

**連載「フレームワークという幻想——Webアプリケーションの『当たり前』を疑う」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 1990年代後半のWeb技術の主役交代——なぜASPやColdFusionは「主流候補」から脱落したのか
- ASP Classic（VBScript）とColdFusion（CFML）の設計思想の違い
- ASP.NET WebFormsが挑んだ「ステートフルなWeb開発」という実験の功罪
- ViewState、PostBack、サーバコントロールが現代のPhoenix LiveView/HTMXにつながる系譜
- 負けた技術が遺した「サーバ側でステートを保持する」という設計判断の再評価

---

## 1. 引き継ぎノートに `<%@ Language="VBScript" %>` と書かれていた日

2000年代中盤、私は中堅SIerの下請けとして、ある業務システムの保守案件に入っていた。引き継ぎ担当の先輩から渡されたソースコード一式を眺めていて、目を疑った。`.asp` という拡張子のファイルが数百本並んでいる。中を開くと、見慣れない構文がずらりと並んでいた。

```asp
<%@ Language="VBScript" %>
<%
    Dim conn, rs, sql
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open "Provider=SQLOLEDB;Data Source=...;User ID=...;Password=..."

    sql = "SELECT id, name, email FROM users WHERE active = 1"
    Set rs = conn.Execute(sql)
%>
<html><body>
<table>
<% Do While Not rs.EOF %>
    <tr>
        <td><%= rs("id") %></td>
        <td><%= Server.HTMLEncode(rs("name")) %></td>
        <td><%= rs("email") %></td>
    </tr>
<%
    rs.MoveNext
Loop
rs.Close
conn.Close
%>
</table>
</body></html>
```

ASP Classicだ。私は当時PHPには慣れていたが、VBScriptで書かれたWebアプリケーションは初見だった。`<%...%>` の構造はPHPの `<?php ?>` と似ている——というより、ほぼ同一だ。だが中身はVisual Basic系の構文で、`Dim`、`Set`、`Server.CreateObject` といったCOMオブジェクト由来のキーワードが並ぶ。先輩は引き継ぎノートに一行だけ書いていた。「Microsoftが昔やっていたPHPみたいなものです」。

確かに「PHPみたいなもの」と言えなくもない。だが私はその表現に違和感を覚えた。同じことができるのに、なぜPHPではなくこちらが選ばれたのか。なぜ世界はPHPで埋め尽くされ、ASPは「過去の技術」として保守案件の片隅に追いやられたのか。同じ年に生まれたColdFusionに至っては、私はその時まで名前すら知らなかった。

歴史は勝者の物語だけではない。負けた技術にも、それが当時の問題に対して提示した解があり、現代の技術に静かに受け継がれた遺伝子がある。

なぜASPやColdFusionは「主流」になれなかったのか。彼らが提示した解は何だったのか。第6回では、この問いに向き合う。

---

## 2. 兄弟が作った言語と、巨人が作ったプラットフォーム

### Allaire兄弟のCold Fusion——1995年7月、データベース駆動Webの先駆け

物語の起点は、1995年のミネソタ州にある。

1995年7月2日、Joseph J. AllaireとJeremy Allaireの兄弟は、自分たちの会社Allaire Corporationから「Cold Fusion 1.0」を発表した。当時の彼らの問題意識は明快だった——HTMLは静的だ。データベースに格納されたデータをWebで動的に表示するには、当時の常識ではC言語でCGIプログラムを書くか、Perlを習得する必要があった。「もっとHTMLに近い書き方で、データベース駆動Webを作れないか」——それがAllaire兄弟の出発点だった。

彼らが選んだ解は、独特だった。新しい言語を作ったのではない。HTMLにそっくりな「タグ」を増やしたのだ。最初の名前は Database Markup Language（DBML）。その後すぐに ColdFusion Markup Language（CFML）に改名された。

```html
<cfquery name="users" datasource="myDB">
    SELECT id, name, email FROM users WHERE active = 1
</cfquery>

<table>
<cfoutput query="users">
    <tr>
        <td>#id#</td>
        <td>#name#</td>
        <td>#email#</td>
    </tr>
</cfoutput>
</table>
```

`<cfquery>` でSQLを発行し、`<cfoutput>` で結果をループする。`#name#` というシャープ記号で囲んだ部分が変数の埋め込みになる。HTMLしか書いたことのないデザイナにも、SQLさえ書ければデータベース駆動のページが作れる。Allaire兄弟が「HTMLの拡張」という発想を取ったのは、このターゲット層を意識した設計判断だった。

Cold Fusionは1996年2月の1.5でファンクリックを獲得し、1990年代後半には企業のイントラネット案件で広く使われた。だがその後の歴史は穏やかではない。2001年1月16日、Allaire CorporationはWebデザインツールFlash／Dreamweaverで知られるMacromediaへの買収合意を発表する。3月20日に合併が完了し、Jeremy AllaireはMacromediaのCTOに就任した。買収後、Cold FusionはJVMベースに全面再実装され、2002年5月のColdFusion MX 6.0として生まれ変わる。

そして2005年4月18日、AdobeがMacromediaの買収（株式交換、約34億ドル）を発表。同年12月3日に取引完了。ColdFusionはAdobe製品となり、現在もAdobe ColdFusion 2023として開発が続く。さらに2015年1月29日、オープンソースのCFMLエンジン「Lucee」がスイスの開発者によってRailo 4.2からフォークされ、現在もコミュニティ駆動で進化している。

「死んだ」と言われ続けて30年、ColdFusionはまだ生きている。生きているが、主流の座にはいない。なぜか。

### Microsoftの Active Server Pages——1996年12月、IISに同梱された「PHP」

ColdFusionが先行した1995年から1年後、巨人が動いた。

1996年12月、Microsoftは Internet Information Services（IIS）3.0 と同時に「Active Server Pages」（ASP）をリリースした。Windows NT 4.0 Option Packという名のアドオンパッケージとして配布され、Windows系サーバの標準的なWeb開発環境となった。後継のASP 2.0は1997年9月（IIS 4.0）、ASP 3.0は2000年11月（IIS 5.0）。これら3バージョンが、後に「Classic ASP」と総称されるものだ。

ASPの設計判断は、ColdFusionと対照的だった。Microsoftは新しいタグ言語を作らず、既存のスクリプト言語をそのまま使う方針を取った。デフォルトのスクリプト言語はVBScript（Visual Basicの軽量版）。`<%@ Language="JScript" %>` と書けばJScript（Microsoft版JavaScript）にも切り替えられた。`<%...%>` というタグ構文は、PHPの `<?php ?>` とほぼ同じ発想だ。

```asp
<%@ Language="VBScript" %>
<%
    Dim conn
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.Open ConnectionString
%>
<html><body>
    <h1>ようこそ <%= Session("username") %> さん</h1>
</body></html>
```

PHPと違うのは、その背後にあるCOM（Component Object Model）の存在だ。`Server.CreateObject("ADODB.Connection")` という呼び出しは、Windowsシステムに登録されたCOMオブジェクトをインスタンス化する。データベース接続にはADO（ActiveX Data Objects）、ファイルアクセスにはScripting.FileSystemObject——Windowsプラットフォームに深く根を張った設計だった。

「Microsoft Tax」という言葉がある。ASPを使うには Windows Server とIISが必要で、それは商用ライセンスを意味した。一方PHPはApache + Linux上で無償で動く。1990年代後半から2000年代初頭、Webサーバとして爆発的に普及したのはApacheだった。1996年4月時点でApacheが市場シェア1位を獲得して以降、その地位は20年以上揺るがなかった。Microsoftのプラットフォーム戦略は、Web開発のもう一つの主流から見れば「閉じた選択」だった。

### ASP.NETの再発明——2002年1月、WebFormsという賭け

Classic ASPには重大な問題があった。スクリプト言語であるVBScriptは型がなく、大規模開発でメンテナンスが困難だった。ファイル中にHTMLとビジネスロジックが混在し、テストも書きづらい。Microsoftは2000年に発表した「.NET戦略」の中で、ASPを根本から再設計する道を選んだ。

2002年1月、.NET Framework 1.0と同時にASP.NET 1.0がリリースされた。これは単なるASPのバージョンアップではない。完全な別物だった。

ASP.NETの中核は「Web Forms」と呼ばれるフレームワークだった。Microsoftは大胆な賭けに出る——HTTPのステートレス性を隠蔽し、Windowsデスクトップアプリケーション（Windows Forms）と同じイベント駆動プログラミングモデルをWebに持ち込むのだ。

```aspx
<%@ Page Language="C#" %>
<script runat="server">
    void SubmitButton_Click(object sender, EventArgs e)
    {
        ResultLabel.Text = "ようこそ、" + NameTextBox.Text + "さん";
    }
</script>

<form runat="server">
    <asp:TextBox ID="NameTextBox" runat="server" />
    <asp:Button ID="SubmitButton" Text="送信"
                OnClick="SubmitButton_Click" runat="server" />
    <asp:Label ID="ResultLabel" runat="server" />
</form>
```

`<asp:TextBox>` や `<asp:Button>` といった「サーバコントロール」を配置し、`OnClick="..."` でイベントハンドラを指定する。Visual Basicでデスクトップアプリケーションを作ったことのあるWindows開発者なら、何の違和感もないコードだ。HTTPのリクエスト・レスポンスサイクルは、フレームワークの内側に隠蔽されている。

そして2009年3月18日、Microsoftは「Mix 2009」カンファレンスでASP.NET MVC 1.0を発表する。WebFormsの完全な置き換えではなく、代替アプローチとして提供された。MVC 1.0はMicrosoft Public License（MS-PL）でCodePlex上にソースコードが公開され、Microsoftにとって異例のオープンな立ち位置を取った。WebFormsの「重さ」を嫌う開発者たちは、急速にMVCへ移行していった。

### .NET Coreの登場と、WebFormsという技術の終焉

2016年6月27日、.NET Core 1.0がリリースされる。Linux、macOSでも動く、クロスプラットフォームで軽量な.NETの再出発だった。だがこの再出発で、ASP.NET WebFormsは置き去りにされた。

System.Web.UI 名前空間の膨大なコード資産は、.NET Coreには移植されない。Microsoftはこの判断を貫き、現在に至るまでWebForms向けの自動移行ツールを公式には提供していない。WebFormsで書かれたアプリケーションは、.NET Framework 4.x の延命に身を委ねるか、Blazorなどの後継フレームワークへの全面書き直しを迫られた。

2002年から2016年までの14年間、Web Formsはエンタープライズの一角で確実に使われ続けた——だが、その流れはここで途切れた。

そして奇妙なことに、Web Formsが終焉を迎えた2016年から数年経った2018年、Elixirコミュニティで「Phoenix LiveView」という技術が脚光を浴び始める。「サーバ側でステートを保持し、差分HTMLをクライアントに送る」——これは、まさにWeb Formsが2002年に挑戦した設計判断と同じ系譜だった。

歴史は繰り返す、と言うのは安易だ。だが、忘れられた技術が遺した思想の種が、別の言語、別の文脈で芽吹くことはある。

---

## 3. 設計判断を比較する——3つの「`<%...%>`」と1つの「`<cf*>`」

### 同じタグ、違う思想

ここで一度、設計の比較を整理しよう。1990年代後半に登場した4つの主要なサーバサイド技術は、見た目の構文こそ似ているが、設計判断は大きく異なっていた。

```
                  PHP            ASP Classic       ColdFusion       ASP.NET WebForms
                  (1995)         (1996)            (1995)           (2002)
                  -----          -----             -----            -----
出発点            テンプレート   COMスクリプト      タグ拡張          GUI抽象化
                  言語           ホスト             (HTML流)
スクリプト        独自構文       VBScript/         CFML             C#/VB.NET
                                JScript            (タグ+CFScript)
HTML埋め込み      <?php ?>       <%...%>           <cf*>タグ         サーバコントロール
                                                                    (<asp:*>)
状態管理          shared-        セッション+        セッション+       ViewState +
                  nothing        Application       CFML変数         Session +
                                                                    PostBack
プラットフォーム  ほぼ全OS       Windows/IIS       JVM (現代)       Windows + .NET
                                                  CFMX 6.0以降     (現代は.NET Core
                                                                    ではWebForms不可)
オープン性        OSS            プロプラ          プロプラ+        プロプラ
                                                  Lucee(OSS)       (MVCはMS-PL)
ライセンス        無料           OS/IIS同梱        商用/Lucee無料    .NET Framework同梱
```

PHPは「HTMLにちょっとした処理を埋め込む」というLerdorfの極めて個人的な動機から始まり、shared-nothingアーキテクチャ（リクエストごとに状態がリセットされる）という極端な選択を貫いた。ASP Classicは「Windows COMオブジェクトをWebで使うスクリプトホスト」という位置づけで、Microsoftプラットフォーム戦略の一部だった。ColdFusionは「HTMLデザイナでも書けるDB駆動Web」を目指し、新しいタグ族を作った。そしてASP.NET WebFormsは「Windowsデスクトップ開発の体験をそのままWebに」という野心を持ち、HTTPの本質であるステートレス性すら隠蔽しようとした。

### ColdFusionのタグ族——「マークアップ言語」という発想の限界

ColdFusionの最大の特徴は、CFMLというタグベース言語そのものにある。

```html
<cfset name = "Yusuke">
<cfset items = ["apple", "banana", "cherry"]>

<cfif name eq "Yusuke">
    <h1>こんにちは、#name# さん</h1>
</cfif>

<ul>
<cfloop array="#items#" index="item">
    <li>#item#</li>
</cfloop>
</ul>

<cfquery name="users" datasource="myDB">
    SELECT * FROM users WHERE name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">
</cfquery>
```

`<cfset>` で変数代入、`<cfif>` で条件分岐、`<cfloop>` でループ、`<cfquery>` でSQL発行。すべてが「タグ」として表現される。HTMLを書ける人なら、ある日突然これを覚えても、見よう見まねで動くものが作れる——それがAllaire兄弟の戦略だった。

そして注目すべきは `<cfqueryparam>` だ。これはSQLインジェクション対策のためのタグで、PHPのプレースホルダー（PDO::prepare）に相当する。1995年の段階で、SQLインジェクションを防ぐ正規の機構をフレームワーク自身が用意していた。同時期のPHPがmysql_real_escape_stringの安全な使用を開発者に丸投げしていたのとは対照的だ。

ただしタグベース構文には限界もあった。ロジックが複雑になると、タグでループや条件をネストするのは読みづらい。後にCFScriptという、JavaScript風のスクリプト構文が併用可能になり、複雑なロジックはCFScriptで、表示寄りの処理はタグで——という使い分けが定着した。

タグベース言語という発想自体が、結局は「HTMLを拡張する」というアプローチの限界を示している。HTMLは元々データの構造を記述するための言語であって、フローロジックを表現するために設計されたものではない。CFMLは果敢にその境界を越えようとしたが、最終的には「タグだけでは足りない」という結論にたどり着いた。

### ASP.NET WebFormsの賭け——HTTPのステートレス性を隠蔽する

WebFormsの設計は、当時の他の技術とは別格の野心を持っていた。

HTTPはステートレスだ。あるリクエストで設定したテキストボックスの値は、次のリクエストでは消える。フォームのチェックボックスが何個ONだったか、選択されたラジオボタンはどれだったか——HTTPの仕様上、サーバはクライアントの「前回の状態」を知る方法を持たない。

WebFormsはこの制約を、`__VIEWSTATE` という隠しフィールドで突破した。ページ上のすべてのサーバコントロールの状態を、ASP.NETがBase64エンコードして1つの`<input type="hidden">`に詰め込み、ブラウザに送る。フォームがサブミットされるとき、ブラウザはその隠しフィールドも一緒に送り返す。サーバはそれをデコードし、各コントロールの状態を復元する。

```html
<!-- ASP.NETが自動生成するHTML（簡略化） -->
<form method="post" action="default.aspx">
    <input type="hidden" name="__VIEWSTATE"
           value="/wEPDwUKLTI..." />
    <input type="text" name="NameTextBox" value="Yusuke" />
    <input type="submit" name="SubmitButton" value="送信" />
</form>
```

これにより、開発者は「フォームの状態を自前で管理する」という負担から解放された。さらに `__doPostBack()` というJavaScript関数が自動生成され、ボタンのクリックやドロップダウンの変更が、サーバ側のC#メソッド呼び出しに自動的にマッピングされる。Visual Studioのデザイナでフォームを作り、ボタンをダブルクリックすればイベントハンドラが生成される——Windows Formsとほぼ同じ体験だ。

```
[ブラウザ]                          [ASP.NET サーバ]
  Page_Load (初回)
    Render → HTML+VIEWSTATE     →  HTML出力
                                    
  ユーザーがボタンクリック
    POST + VIEWSTATE             →  Page_Load
                                    VIEWSTATEデコード
                                    SubmitButton_Click 実行
                                    Render → 新しい HTML+VIEWSTATE
                                  ←  HTML出力
```

設計としては美しい。だが代償も大きかった。

第一に、ViewStateの肥大化。GridViewのようなリッチなコントロールにデータを大量にバインドすると、ViewStateは数十KB、ときには数百KBに膨れ上がる。回線が遅い環境では、ページ遷移のたびにこの巨大な隠しフィールドを送受信することになる。「ViewStateを切る」というアンチパターンが生まれ、開発者はViewStateの肥大化と機能の利便性のバランスに腐心した。

第二に、ページライフサイクルの複雑性。Page_Load、Page_Init、Page_PreRender、SaveViewState、LoadViewState——イベントの発火順序を理解しないと、思った通りに動かない。ASP.NET MVPやMicrosoft Pressから「ASP.NET ページのライフサイクル完全理解」のような書籍が次々と出版された事実は、その複雑さの裏返しだ。

第三に、テスタビリティの低さ。サーバコントロールはASP.NETランタイムに密結合しており、ユニットテストでイベントハンドラを単独で実行するのは困難だった。テスト駆動開発（TDD）が当たり前になっていく時代に、WebFormsはその波に乗れなかった。これがMVCへの移行を加速させた直接的な理由の一つでもある。

### 系譜——LiveViewとHTMXに受け継がれた遺伝子

ここで興味深いのは、2018年以降に登場したサーバサイド・ステートフル・フレームワークの動きだ。

Phoenix LiveView（Elixir、Chris McCord、2018年〜）は、WebSocket接続を介してサーバ側でコンポーネントの状態を保持し、状態変化があれば差分HTMLをクライアントにプッシュする。クライアントは差分を適用するだけで、JavaScriptをほとんど書かずにリッチなインタラクティブUIを実現できる。

```elixir
# Phoenix LiveView の例
defmodule MyAppWeb.CounterLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("increment", _params, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def render(assigns) do
    ~H"""
    <button phx-click="increment">+</button>
    <span><%= @count %></span>
    """
  end
end
```

`assign(socket, count: 0)` は、サーバ側のソケット（WebSocket接続）に状態を保持している。`phx-click="increment"` という属性が、クライアントのクリックイベントをサーバ側の `handle_event` に紐付ける。これは、ASP.NET WebFormsの `<asp:Button OnClick="..." />` と構造的にほぼ同じ発想だ。違いは、WebFormsがリクエスト・レスポンスごとにViewStateを往復させたのに対し、LiveViewはWebSocketで持続接続を維持する点だ。

HTMX（独立、Carson Gross、2020年〜）は別のアプローチを取る。すべての状態はサーバ側にあり、クライアントは `hx-get`、`hx-post` といった属性でサーバにリクエストを投げ、返ってきたHTML断片で指定された要素を置き換える。

```html
<button hx-post="/click" hx-target="#counter" hx-swap="innerHTML">
    +
</button>
<span id="counter">0</span>
```

サーバは `/click` のPOSTリクエストを受けて、新しいカウンタ値をHTML断片として返す。クライアントはそれを `#counter` 要素の中身として差し替える。状態はサーバが完全に管理し、クライアントはほぼ「描画装置」として振る舞う。

PHPコミュニティのLaravel Livewire（Caleb Porzio、2018年〜）、Ruby on RailsのHotwire/Turbo（37signals、2020年〜）も、この「サーバ側ステートフル」の流れに連なる。SPAの複雑性に疲れた開発者たちが、再び「サーバが主、クライアントが従」という構造に戻ってきた——その動きを見ると、2002年のWebForms設計者たちは20年早すぎたのかもしれない。

ただし、機構は明確に違う。WebFormsはViewStateというステートをクライアントに送り返す形で擬似的なステートフルを実現したが、現代のフレームワークはWebSocketや無状態なHTML差分送信で同じ目的を達成する。設計判断としての「ステートはサーバに置く」は同じでも、実装機構は2020年代のWeb技術に合わせて再構築されている。

歴史を学ぶとは、同じパターンが文脈を変えて反復することを見抜く目を持つことだ。WebFormsが「失敗」したから、その思想すべてが間違っていたわけではない。実装の制約と、当時のクライアント側技術（IE6、JavaScriptが貧弱な時代）が、設計判断の良さを覆い隠してしまっただけだ。

---

## 4. ハンズオン：忘れられた技術の遺伝子を体験する

ここまでの議論を、実際に手を動かして確かめよう。3つの演習を用意した。

### 演習環境

Docker環境を前提とする。Lucee CE（CFML実行エンジン）、Node.js（EJSによるASP風表現の再現）、HTMXのデモ用Webサーバを動かす。

### 演習1：ASP Classic 風の `<%...%>` 文化を Node.js + EJS で再現する

ASP Classicの実環境を立ち上げるには、レガシーWindows Server環境が必要となる。代わりに、構文的にほぼ同等の「インラインテンプレート」をNode.js + EJSで再現し、`<%...%>` 文化が何を提供していたのかを体感する。

```bash
mkdir -p ~/web-framework-handson-06/asp-style
cd ~/web-framework-handson-06/asp-style

# package.json と最小のサーバ
cat > server.js << 'JS'
const http = require('http');
const ejs = require('ejs');

const template = `<%@ Language="EJS-as-VBScript-emulator" %>
<html><body>
<h1>ASP Classic 風のインラインテンプレート</h1>
<p>現在時刻：<%= new Date().toISOString() %></p>
<%
    const items = ["apple", "banana", "cherry"];
    const username = (query.user || "guest");
%>
<p>ようこそ <%= username %> さん</p>
<ul>
<% for (const item of items) { %>
    <li><%= item %></li>
<% } %>
</ul>
</body></html>`;

http.createServer((req, res) => {
    const url = new URL(req.url, "http://localhost");
    const query = Object.fromEntries(url.searchParams);
    const html = ejs.render(template, { query });
    res.writeHead(200, { "Content-Type": "text/html; charset=UTF-8" });
    res.end(html);
}).listen(3000);

console.log("Listening on http://localhost:3000/?user=Yusuke");
JS

npm init -y > /dev/null
npm install ejs > /dev/null
node server.js
```

別ターミナルから `curl 'http://localhost:3000/?user=Yusuke'` を叩くと、`<% ... %>` で挟まれたJavaScriptブロックが実行され、`<%= ... %>` の値がHTMLに埋め込まれる。これはASP Classicの `<%@ Language="VBScript" %>` 配下の振る舞いと構造的に同型だ。

ここで考えてほしい。HTMLの中にコードを書くというこのスタイルは「ダサい」と言われる。だが、`view.tsx` の中にJSXとTypeScriptとロジックが混在するReactのコードを見たとき、構造的には何が違うだろうか。違うのは、JSXがコンポーネント抽象を持っているという点と、エディタの補完がリッチという点だ。「テンプレートに直接コードを書く」という根本的な発想は、20年以上経っても消えていない。

### 演習2：CFML（Lucee CE Docker）でタグベース構文を読み解く

ColdFusion本家を試すにはAdobeの商用ライセンスが必要だが、オープンソース実装のLuceeなら無料で動かせる。

```bash
# Lucee CEのDockerコンテナ起動
docker run -d --name lucee-handson -p 8888:8888 lucee/lucee:latest

# CFMLファイルを作る
mkdir -p ~/web-framework-handson-06/cfml
cat > ~/web-framework-handson-06/cfml/index.cfm << 'CFM'
<cfset users = [
    {id=1, name="Yusuke",  email="yusuke@example.com"},
    {id=2, name="Takeshi", email="takeshi@example.com"},
    {id=3, name="Hanako",  email="hanako@example.com"}
]>

<html><body>
<h1>CFML タグの世界</h1>

<cfif arrayLen(users) gt 0>
    <table border="1">
        <tr><th>ID</th><th>Name</th><th>Email</th></tr>
        <cfloop array="#users#" index="user">
            <tr>
                <td>#user.id#</td>
                <td>#user.name#</td>
                <td>#user.email#</td>
            </tr>
        </cfloop>
    </table>
<cfelse>
    <p>ユーザがいません</p>
</cfif>

<hr>
<p>※ #...# で囲まれた部分が変数の埋め込みになる</p>
</body></html>
CFM

# Lucee コンテナの webroot にコピーして配信
docker cp ~/web-framework-handson-06/cfml/index.cfm \
    lucee-handson:/var/www/

# ブラウザで http://localhost:8888/index.cfm を開く
curl http://localhost:8888/index.cfm
```

`<cfset>` で変数代入、`<cfloop>` でループ、`<cfif>` で条件分岐——すべてがタグだ。`#user.name#` のシャープ記法も独特だ。HTMLしか書けない人にこれを見せたとき、「自分にも書けるかもしれない」と思わせる効力は確かにある。

ただし、ロジックが複雑になると読みづらさが急速に増す。`<cfloop>` の中に `<cfif>` を入れ、その中でまた `<cfquery>` を発行すると、ネストされたタグの開閉を追うのが大変になる。これがCFScriptという第二の選択肢が必要になった理由だ。

### 演習3：HTMX で「サーバが主、クライアントが従」を体験する

WebFormsの「サーバ側でステートを保持する」思想の現代版を、HTMXで体験する。

```bash
mkdir -p ~/web-framework-handson-06/htmx
cd ~/web-framework-handson-06/htmx

cat > server.js << 'JS'
const http = require('http');

let counter = 0;

http.createServer((req, res) => {
    if (req.url === '/' && req.method === 'GET') {
        res.writeHead(200, { "Content-Type": "text/html; charset=UTF-8" });
        res.end(`<!DOCTYPE html>
<html><head>
    <script src="https://unpkg.com/htmx.org@2.0.4"></script>
</head><body>
    <h1>HTMX カウンタ</h1>
    <button hx-post="/increment"
            hx-target="#counter"
            hx-swap="innerHTML">+</button>
    <button hx-post="/decrement"
            hx-target="#counter"
            hx-swap="innerHTML">-</button>
    <p>現在値: <span id="counter">${counter}</span></p>
</body></html>`);
    } else if (req.url === '/increment' && req.method === 'POST') {
        counter++;
        res.writeHead(200, { "Content-Type": "text/html" });
        res.end(String(counter));
    } else if (req.url === '/decrement' && req.method === 'POST') {
        counter--;
        res.writeHead(200, { "Content-Type": "text/html" });
        res.end(String(counter));
    } else {
        res.writeHead(404);
        res.end();
    }
}).listen(3001);

console.log("Listening on http://localhost:3001/");
JS

node server.js
```

ブラウザで `http://localhost:3001/` を開き、+/- ボタンを押す。クライアント側のJavaScriptは1行も書いていない。`hx-post="/increment"` という属性だけで、ボタンクリックがサーバへのPOSTリクエストになり、返ってきたテキスト（数字）が `#counter` 要素の中身に置き換わる。

これは何をしているのか？　状態（counter変数）はサーバのメモリにある。クライアントは「ボタンを押したのでサーバに通知」と「サーバから返ってきたHTML断片で表示を更新」だけを担当する。ASP.NET WebFormsの `<asp:Button OnClick="..." />` と「サーバ側でステートを保持し、クライアントはHTMLの差分を受け取る」という設計判断が同じであることが見えるだろうか。

WebFormsはViewStateという隠しフィールドにステートを詰めてHTTPで往復させた。HTMXはそうではなく、サーバのメモリやセッションにステートを置き、HTMLの一部だけを返す。実装機構は違うが、思想——「フロントエンドJSをなるべく書かず、サーバを中心にする」——は同じ系譜だ。

そしてHTMXの作者Carson Grossは、明示的にこの系譜を意識している。彼のエッセイ「The HATEOAS Resurrection」（2022年）では、Roy Fieldingの博士論文で提示されたHATEOAS（Hypermedia as the Engine of Application State）という、本来のRESTの中核概念が、HTMXによって復活したのだと論じている。Web Formsの ViewState は、この HATEOAS の不器用な実装と見ることもできる——ステートはサーバが管理し、クライアントは次のアクションをハイパーメディアとして受け取る、という構造において。

3つの演習を通じて、見た目の違う技術の裏に流れる設計判断の連続性が見えただろうか。

---

## 5. 主流に選ばれなかった技術が遺したもの

### この回の要点

第6回では、1990年代後半から2000年代に主流候補として登場し、最終的に「主流」の座を逃した技術——ASP Classic、ColdFusion、ASP.NET WebForms——を取り上げた。

1995年7月、Allaire兄弟がCold Fusion 1.0を発表。CFMLという「HTMLを拡張するタグ言語」で、HTMLデザイナにもデータベース駆動Webを書かせる戦略だった。1996年12月、MicrosoftはIIS 3.0と同時にASP 1.0を投入。VBScriptを基盤に、Windows COMオブジェクトをWebで使えるスクリプトホストとして展開した。2002年1月、ASP.NET 1.0と同時にWebFormsが登場。HTTPのステートレス性を隠蔽し、Windowsデスクトップ開発の体験をWebに持ち込もうとした野心的な試みだった。2009年3月にASP.NET MVC 1.0が登場し、2016年6月の.NET Core 1.0でWebFormsは事実上の終焉を迎えた。

ColdFusionは2001年にMacromediaに、2005年にAdobeに買収され、現在もAdobe ColdFusion 2023として開発が続く。オープンソース実装のLuceeも2015年以降コミュニティ駆動で進化している。「死んだ」と言われ続けて30年、CFMLはまだ生きている——主流ではないが、確かに生きている。

WebFormsの「サーバ側でステートを保持する」設計判断は、表面的には2016年に終わった。だが、この思想はPhoenix LiveView（2018年〜）、Hotwire（2020年〜）、HTMX（2020年〜）、Laravel Livewire（2018年〜）に脈々と受け継がれている。実装機構は変わったが、設計判断としての遺伝子は生き続けている。

### 冒頭の問いに対する暫定回答

「Web開発の歴史で忘れられた技術は、何を教えてくれるのか？」

第一に、技術の主流・非主流を決めるのは技術的優劣だけではない、という事実だ。ASPがPHPに敗れたのはWindows Server＋IISという商用前提のせいであり、ColdFusionが脇に追いやられたのはOSSの土俵で勝負しなかったからだ。「コードのきれいさ」や「設計の洗練」だけでは、市場の勝敗は決まらない。プラットフォーム戦略、ライセンス、コミュニティ、エコシステム——技術の周辺にあるものが、同じくらい重要な役割を果たす。

第二に、敗れた技術の設計判断は消えない。WebFormsの「サーバが状態を持つ」発想はLiveViewやHTMXに、ColdFusionの `<cfqueryparam>` のSQLインジェクション対策思想はモダンORMのプレースホルダー機能に、ASP Classicの `<%...%>` 構文はEJSやERBに——形を変えて受け継がれている。技術史は線形ではなく、同じアイデアが何度も別の文脈で再発見される。

第三に、「主流」を追うエンジニアは、次の主流を予測する力を弱める。今のメインストリームに何の疑問も持たずに乗っかる人間は、それが廃れたときに自分の依拠した知識ごと取り残される。歴史は、現在の主流が永続しないことを繰り返し教えてくれる。「負けた」技術を学ぶことは、勝者の自明性を疑う訓練になる。

あなたが今、Reactを書き、Next.jsをデプロイしているとして——その10年後、これらが「ASP Classic的扱い」になっている可能性を、真剣に検討したことがあるだろうか。私たちは、その問いから逃れられない。

### 次回予告

第7回「テンプレートエンジンの系譜——ロジックと表示の分離」では、Webアプリケーション開発の中で繰り返し議論されてきた「ロジックとプレゼンテーションをどう分けるか」という問いを掘り下げる。SSI、Smarty、Velocity、ERB、Jinja2、Handlebars——テンプレートエンジンの歴史は、「ロジックを入れるか入れないか」「コンパイル型かインタプリタ型か」という設計判断の軌跡だ。第6回で見たCFMLやASPの `<%...%>` も、その大きな流れの一部分にすぎない。次回は、その全体像を俯瞰する。

---

## 参考文献

- Wikipedia, "Active Server Pages" <https://en.wikipedia.org/wiki/Active_Server_Pages>
- Microsoft Learn, "ASP support in Windows" <https://learn.microsoft.com/en-us/troubleshoot/developer/webapps/iis/active-server-pages/asp-support-windows>
- Wikipedia, "Adobe ColdFusion" <https://en.wikipedia.org/wiki/Adobe_ColdFusion>
- Wikipedia, "Allaire Corporation" <https://en.wikipedia.org/wiki/Allaire_Corporation>
- Wikipedia, "ColdFusion Markup Language" <https://en.wikipedia.org/wiki/ColdFusion_Markup_Language>
- Adobe ColdFusion Blog, "Twenty years of making web happen – Happy Birthday, ColdFusion!" (2015) <https://coldfusion.adobe.com/2015/07/twenty-years-of-making-web-happen-happy-birthday-coldfusion/>
- The History of the Web, "A History of ColdFusion" <https://thehistoryoftheweb.com/building-coldfusion-for-the-web/>
- Wikipedia, "ASP.NET Web Forms" <https://en.wikipedia.org/wiki/ASP.NET_Web_Forms>
- Wikipedia, ".NET Framework version history" <https://en.wikipedia.org/wiki/.NET_Framework_version_history>
- Wikipedia, "ASP.NET MVC" <https://en.wikipedia.org/wiki/ASP.NET_MVC>
- InfoQ, "ASP.NET MVC 1.0 Released" (2009) <https://www.infoq.com/news/2009/03/asp-net-mvc-1-0/>
- Microsoft .NET Blog, "ASP.NET MVC 1.0 now Live!" <https://devblogs.microsoft.com/dotnet/asp-net-mvc-1-0-now-live/>
- Microsoft .NET Blog, ".NET Core 1.0 and 1.1 will reach End of Life on June 27, 2019" <https://devblogs.microsoft.com/dotnet/net-core-1-0-and-1-1-will-reach-end-of-life-on-june-27-2019/>
- Microsoft Learn, "Architecture comparison of ASP.NET Web Forms and Blazor" <https://learn.microsoft.com/en-us/dotnet/architecture/blazor-for-web-forms-developers/architecture-comparison>
- Wikipedia, "Lucee" <https://en.wikipedia.org/wiki/Lucee>
- Wikipedia, "Railo" <https://en.wikipedia.org/wiki/Railo>
- Phoenix LiveView Documentation <https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html>
- Microsoft Press, "Anatomy of an ASP.NET Page" <https://www.microsoftpressstore.com/articles/article.aspx?p=2228444&seqNum=3>
- Adobe ColdFusion Help, "cfquery" <https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-tags/tags-p-q/cfquery.html>
- Adobe ColdFusion Help, "cfoutput" <https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-tags/tags-m-o/cfoutput.html>
