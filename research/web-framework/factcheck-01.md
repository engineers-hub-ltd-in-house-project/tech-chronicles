# ファクトチェック記録: web-framework 第1回

「フレームワークなしでWebを作れるか」

---

## 1. Stack Overflow Developer Survey 2024 -- Webフレームワーク利用率

- **結論**: 2024年調査（回答者65,000人超）で、React 41.6%、Node.js 40.7%、Next.js 18.6%、Express 18.2%がプロフェッショナル開発者の利用率上位。Node.jsは2020年の51%をピークに依然最も使われるWeb技術
- **一次ソース**: Stack Overflow, "2024 Developer Survey - Technology", 2024年
- **URL**: <https://survey.stackoverflow.co/2024/technology>
- **注意事項**: 調査はStack Overflowユーザーが対象のため、母集団にバイアスがある。利用率は「過去1年間に使用した」の定義
- **記事での表現**: 「Stack Overflow Developer Survey 2024によれば、Reactの利用率は41.6%、Node.jsは40.7%に達する」

## 2. CGI仕様の誕生 -- 1993年、NCSA httpd、Rob McCool

- **結論**: CGIは1993年にNCSA（National Center for Supercomputing Applications）で誕生。Rob McCoolがNCSA HTTPdの開発者としてCGI仕様を策定。1993年11月に最初の仕様案（当初「Common Gateway Protocol」と呼称）を提案し、同年12月に「Common Gateway Interface」に改称。仕様文書は<http://hoohoo.ncsa.uiuc.edu/cgi/> に公開された
- **一次ソース**: Wikipedia, "Common Gateway Interface"; Cybercultural, "1993: CGI Scripts and Early Server-Side Web Programming"
- **URL**: <https://en.wikipedia.org/wiki/Common_Gateway_Interface>, <https://cybercultural.com/p/1993-cgi-scripts-and-early-server-side-web-programming/>
- **注意事項**: Rob McCoolはNCSA HTTPd（Apacheの直接の前身）の開発者でもある。NCSA HTTPd v0.3は1993年4月22日に公開
- **記事での表現**: 「1993年、NCSAのRob McCoolがCGI仕様を策定した。当初Common Gateway Protocolと呼ばれたこの仕様は、Webサーバと外部プログラムの間の共通インターフェースを定義するものだった」

## 3. RFC 3875 -- CGI/1.1の正式仕様化（2004年）

- **結論**: RFC 3875は2004年10月にD. RobinsonとK. Coar（The Apache Software Foundation）によって公開。ステータスは「Informational」であり、正式なInternet Standardではない。1993年から使われてきたCGI/1.1の「current practice」を文書化したもの
- **一次ソース**: RFC Editor, "RFC 3875: The Common Gateway Interface (CGI) Version 1.1", 2004年10月
- **URL**: <https://www.rfc-editor.org/rfc/rfc3875>
- **注意事項**: Informationalステータスであり、Standards Trackではない点に注意
- **記事での表現**: 「CGIの仕様が正式にRFC 3875として文書化されたのは2004年のことだ。1993年の誕生から11年——それほど長い間、CGIは事実上の標準として機能し続けた」

## 4. Next.js初回リリース -- 2016年10月25日、Guillermo Rauch、ZEIT

- **結論**: Next.jsは2016年10月25日にZEIT（現Vercel）からオープンソースとして公開。創設者はGuillermo Rauch（現Vercel CEO）。初期からサーバサイドレンダリング（SSR）と静的サイト生成（SSG）を提供
- **一次ソース**: Wikipedia, "Next.js"; Vercel/Next.js GitHub Releases
- **URL**: <https://en.wikipedia.org/wiki/Next.js>, <https://github.com/vercel/next.js/releases>
- **注意事項**: ZEITは2020年4月にVercelに社名変更
- **記事での表現**: 「2016年10月、Guillermo RauchのZEIT（現Vercel）がNext.jsをオープンソースとして公開した」

## 5. React初回リリース -- 2013年5月、Jordan Walke、Facebook

- **結論**: ReactはFacebookのソフトウェアエンジニアJordan Walkeが2011年に開発。初期プロトタイプは「FaxJS」と呼ばれていた。XHP（FacebookのPHP向けHTMLコンポーネントライブラリ）に着想を得ている。2011年にFacebookのニュースフィードに、2012年にInstagramに導入。2013年5月のJSConf USで一般公開
- **一次ソース**: Wikipedia, "React (software)"; RisingStack Engineering, "The History of React.js on a Timeline"
- **URL**: <https://en.wikipedia.org/wiki/React_(software)>, <https://blog.risingstack.com/the-history-of-react-js-on-a-timeline/>
- **注意事項**: 公開時はJSXに対する懐疑的な反応が多かった
- **記事での表現**: 「2013年5月、FacebookのJordan WalkeがJSConf USでReactを公開した」

## 6. Node.js -- Ryan Dahl、2009年11月8日、JSConf EU

- **結論**: Ryan Dahlが2009年11月8日の第1回JSConf EUでNode.jsを発表。GoogleのV8 JavaScriptエンジン（2008年オープンソース化）上に構築。イベントループと低レベルI/O APIを組み合わせた。2010年1月にnpm（パッケージマネージャ）が導入された
- **一次ソース**: Wikipedia, "Node.js"; JSConf.eu 2009 Speaker List
- **URL**: <https://en.wikipedia.org/wiki/Node.js>, <https://www.jsconf.eu/2009/speaker/speakers_selected.html>
- **注意事項**: 2012年1月にDahlがプロジェクト管理をnpm作者Isaac Schlueterに移譲
- **記事での表現**: 「2009年、Ryan DahlがJSConf EUでNode.jsを発表した。GoogleのV8エンジン上にイベントループと非同期I/Oを組み合わせたこのランタイムは、JavaScriptをサーバサイドに持ち込んだ」

## 7. Express.js -- TJ Holowaychuk、2010年、Sinatra着想

- **結論**: Express.jsはTJ Holowaychukが開発。初回リリースは2010年（バージョン0.1.0は2010年2月3日、GitHub上の最初のリリースは2010年5月22日）。RubyのSinatraフレームワークに着想を得ている。Connectのミドルウェアシステムの上に構築された
- **一次ソース**: Wikipedia, "Express.js"
- **URL**: <https://en.wikipedia.org/wiki/Express.js>
- **注意事項**: 初回リリース日に2月と5月の2説あり。GitHubリリースタグ基準では5月
- **記事での表現**: 「2010年、TJ HolowaychukがRubyのSinatraに着想を得てExpress.jsを公開した」

## 8. DHH「15分でブログを作る」スクリーンキャスト -- 2005年

- **結論**: David Heinemeier Hansson（DHH）が2005年にブラジルの第6回FISL（Forum Internacional de Software Livre）で録音した音声に合わせてスクリーンキャストを制作。Ruby on Railsを使って15分でブログアプリケーションを構築するデモ。2005年11月8日にYouTubeにアップロード
- **一次ソース**: DHH公式Twitter/X投稿; Avo, "What is the 15 Minute Blog in Rails"
- **URL**: <https://x.com/dhh/status/492706473936314369>, <https://avohq.io/glossary/15-minute-blog>
- **注意事項**: デモ時点のRailsバージョンは0.x系。Rails 1.0のリリースは2005年12月
- **記事での表現**: 「2005年、DHHが『15分でブログを作る』デモを公開し、Web開発の世界に衝撃を与えた」

## 9. Django初回リリース -- 2005年7月、Lawrence Journal-World

- **結論**: Djangoは2003年秋にLawrence Journal-World新聞社のWebプログラマーAdrian HolovatyとSimon Willisonが開発を開始。2005年7月21日にBSDライセンスでバージョン0.90として公開。名前はジャズギタリストDjango Reinhardtに由来
- **一次ソース**: Simon Willison, "Introducing Django", 2005年7月17日; Wikipedia, "Django (web framework)"
- **URL**: <https://simonwillison.net/2005/Jul/17/django/>, <https://en.wikipedia.org/wiki/Django_(web_framework)>
- **注意事項**: Jacob Kaplan-MossがWillisonの離脱前にチームに参加
- **記事での表現**: 「2005年7月、カンザス州の新聞社Lawrence Journal-Worldから生まれたDjangoが公開された」

## 10. Create React App非推奨化 -- 2025年2月14日

- **結論**: Reactチームが2025年2月14日にCreate React App（CRA）を正式に非推奨化。新規Reactアプリケーションはフレームワーク（Next.js等）での作成を推奨。CRAは200万以上のプロジェクトを生み出した。非推奨化後、Next.jsの週間ダウンロード数は700万から900万超に急増
- **一次ソース**: eSparkInfo, "45+ Effective React Statistics, Facts & Insights for 2026"
- **URL**: <https://www.esparkinfo.com/software-development/technologies/reactjs/statistics>
- **注意事項**: CRA非推奨化はフレームワーク・ファースト開発への転換を象徴する出来事
- **記事での表現**: 「2025年2月、Reactチームはcreate-react-appを正式に非推奨とした。新規プロジェクトにはNext.jsなどのフレームワークを推奨している。フレームワークなしのReact開発という選択肢は、公式に退場したのである」

---

## ファクトチェック結果サマリー

| #  | 項目                                 | 状態   |
| -- | ------------------------------------ | ------ |
| 1  | Stack Overflow Survey 2024利用率     | 検証済 |
| 2  | CGI仕様の起源（1993年、Rob McCool）  | 検証済 |
| 3  | RFC 3875（CGI/1.1、2004年）          | 検証済 |
| 4  | Next.js初回リリース（2016年10月）    | 検証済 |
| 5  | React初回リリース（2013年5月）       | 検証済 |
| 6  | Node.js発表（2009年、Ryan Dahl）     | 検証済 |
| 7  | Express.js初回リリース（2010年）     | 検証済 |
| 8  | DHH「15分ブログ」デモ（2005年）      | 検証済 |
| 9  | Django初回リリース（2005年7月）      | 検証済 |
| 10 | Create React App非推奨化（2025年2月) | 検証済 |

検証済み: 10/10項目（品質ゲート基準6項目以上: クリア）
