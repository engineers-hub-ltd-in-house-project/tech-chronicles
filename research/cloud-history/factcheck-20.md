# ファクトチェック記録：第20回「CDN、エッジコンピューティング——計算を『ユーザーの近く』に持っていく」

## 1. Akamai Technologies の設立経緯

- **結論**: Tim Berners-Leeが1995年初頭にMITで「Webの混雑を解消する根本的に新しい方法を発明せよ」という課題を提示。MIT応用数学教授Tom Leightonが大学院生Danny Lewinとともにアルゴリズムを開発。1998年8月20日にAkamai Technologiesを法人化。1999年2月にDisneyサイトで初のライブトラフィックを配信。1999年4月に商用サービス開始。1999年10月29日にNASDAQ上場。Danny Lewinは2001年9月11日のテロで犠牲となった
- **一次ソース**: Akamai Technologies, "Akamai Company History"
- **URL**: <https://www.akamai.com/company/company-history>
- **注意事項**: MIT $50K Entrepreneurship Competitionに1997年9月に参加。共同創業者にはPreetish Nijhawan、Jonathan Seelig、Randall Kaplanも含まれる
- **記事での表現**: 「1995年初頭、World Wide Webの発明者Tim Berners-LeeはMITの同僚たちに一つの課題を投げかけた——Webの混雑を解消する根本的に新しい方法を発明せよ。MIT応用数学教授のTom Leightonと大学院生のDanny Lewinがこの課題に取り組み、分散サーバネットワークにコンテンツをキャッシュし、ユーザーに最も近いサーバから配信するアルゴリズムを開発した。1998年8月20日、Akamai Technologiesが法人化された」

## 2. CDNの技術的起源と商用化

- **結論**: Akamaiが1999年2月にDisneyサイトで初のライブトラフィックを配信（ピクセル埋め込み）。1999年3月にESPNのMarch MadnessとEntertainment TonightのStar Wars予告編を配信し、歴史的なユーザー需要に対応。Speedera Networks（1999年設立）が競合として存在し、2005年にAkamaiが買収
- **一次ソース**: Akamai Company History; CDN Handbook, "The History of Content Delivery Networks"
- **URL**: <https://www.akamai.com/company/company-history>, <https://www.cdnhandbook.com/cdn/history/>
- **注意事項**: CDN業界は1990年代後半の数社から始まり、現在は無料CDNティアが個人ブログにも提供される時代に
- **記事での表現**: CDNの起源をAkamaiの商用化（1999年）から説明し、静的コンテンツ配信の基本概念（キャッシュ、PoP）を解説

## 3. Cloudflare Workers（2017年）

- **結論**: Cloudflare Workersは2017年9月に発表された。Google ChromeのV8エンジンのIsolate技術を基盤とする。V8 IsolatesはJavaScriptランタイムのオーバーヘッドを一度だけ支払い、個々のスクリプトはほぼゼロの追加オーバーヘッドで実行可能。コンテナベースのサーバーレスとは根本的に異なるアプローチ
- **一次ソース**: Cloudflare Blog (multiple posts)
- **URL**: <https://blog.cloudflare.com/tag/workers/>
- **注意事項**: V8 Isolatesはブラウザ標準のJavaScript APIを実装しており、エッジでの実行を軽量かつ高速にする
- **記事での表現**: 「2017年9月、CloudflareはWorkersを発表した。技術的に画期的だったのは、コンテナではなくV8 Isolatesを採用したことだ」

## 4. AWS Lambda@Edge（2016年プレビュー、2017年GA）

- **結論**: 2016年のre:Inventでプレビュー発表（Werner Vogelsが紹介）。2017年7月17日にGA（一般提供）。CloudFrontのエッジロケーションでNode.js関数を実行可能。初期はリクエスト/レスポンスの変更に限定、実行時間制限50ms
- **一次ソース**: AWS, "Lambda@Edge now Generally Available"
- **URL**: <https://aws.amazon.com/about-aws/whats-new/2017/07/lambda-at-edge-now-generally-available/>
- **注意事項**: Lambda@EdgeはCloudFrontのトリガーとして動作する点で、Cloudflare Workersの「全リクエストがエッジで処理される」モデルとは異なる
- **記事での表現**: 「2016年のre:InventでプレビューとしてLambda@Edgeが発表され、2017年7月にGAとなった」

## 5. Deno Deploy（2021年ベータ）

- **結論**: 2021年にBeta 1がリリース。32リージョンで動作するサーバーレスエッジプラットフォーム。AWS LambdaやCloudflare Workersとは独立した新システム。V8 Isolatesを使用。GA目標はQ4 2021だったがQ3 2022に延期
- **一次ソース**: Deno Blog, "Deno Deploy Beta 1"
- **URL**: <https://deno.com/blog/deploy-beta1>
- **注意事項**: ブラウザ互換のJavaScript APIを提供。Deno CLIのワークフローを補完するホスティングサービスとして設計
- **記事での表現**: 「2021年、Deno DeployがBeta 1をリリースした。V8 Isolatesを基盤とし、32リージョンのエッジでサーバーサイドJavaScriptを実行する」

## 6. Fastly Compute@Edge（2019年ベータ、2021年GA）

- **結論**: 2019年11月6日にベータ発表。WebAssembly（Wasm）ベースのランタイム。起動時間35.4マイクロ秒（当時の他のソリューションの100倍高速）。Mozillaの WebAssemblyチームの一部を買収しLucetランタイムを開発。2021年にGA。2023年に名称をCompute@EdgeからComputeに短縮。Bytecode Alliance（Mozilla、Intel、Red Hatと共同設立）に参画
- **一次ソース**: Fastly Press Release, "Fastly Launches Compute@Edge"
- **URL**: <https://www.fastly.com/press/press-releases/fastly-expands-serverless-capabilities-launch-compute-edge>
- **注意事項**: Cloudflare Workers（V8 Isolates）とは異なりWebAssemblyベース。Rust、AssemblyScript対応。2023年にComputeに改名
- **記事での表現**: 「2019年11月、FastlyはCompute@Edge（現Fastly Compute）のベータを発表した。Cloudflare WorkersがV8 Isolatesを選んだのに対し、FastlyはWebAssemblyを選択した」

## 7. WinterCG / WinterTC

- **結論**: 2022年4月22日にJames Snellが提案。2022年5月にW3C傘下のWeb-interoperable Runtimes Community Group（WinterCG）として正式に活動開始。共同提案者にLuca Casonato、Romulo Cintra、Benjamin Gruenbaum、Tobias Nießen。最も重要な成果物は「Minimum Common API」（全Web互換サーバー環境でサポートすべきWebプラットフォームのサブセットの定義）。2024年12月にEcma International TC55（WinterTC）に移行
- **一次ソース**: Deno Blog, "Announcing the Web-interoperable Runtimes Community Group"
- **URL**: <https://deno.com/blog/announcing-wintercg>
- **注意事項**: WinterTCへの移行により標準策定が可能に。エッジランタイム間の互換性標準化を推進
- **記事での表現**: 「2022年5月、W3C傘下にWinterCGが設立された。エッジランタイム間のAPI互換性を標準化する試み」

## 8. Cloudflare のエッジデータストレージ製品群

- **結論**: Workers KV——2018年9月にベータ発表、2019年5月にGA。結果整合性のKey-Valueストア。Durable Objects——2020年9月にクローズドベータ発表。強整合性の状態管理。D1——2022年5月に発表（SQLデータベース）。2024年にSQLiteバックエンドのDurable ObjectsがGA
- **一次ソース**: Cloudflare Blog各記事
- **URL**: <https://blog.cloudflare.com/introducing-workers-kv/>, <https://blog.cloudflare.com/introducing-workers-durable-objects/>, <https://blog.cloudflare.com/introducing-d1/>
- **注意事項**: KV（結果整合性）→ Durable Objects（強整合性）→ D1（SQL）という進化は、エッジにおける状態管理の段階的解決を示す
- **記事での表現**: 「エッジに状態を持つ」課題の解決過程として、KV→Durable Objects→D1の系譜を説明

## 9. エッジコンピューティング市場規模

- **結論**: 調査会社により推定値に幅があるが、2024-2025年時点で約200-600億ドル規模。CAGR 27-34%で成長中。Grand View Researchでは2024年に236.5億ドル、2033年に3,277.9億ドル（CAGR 33.0%）と推計。主な成長要因はAI/リアルタイム分析、IoT、5Gインフラ、データ主権要件
- **一次ソース**: Grand View Research, "Edge Computing Market Size, Share | Industry Report, 2033"
- **URL**: <https://www.grandviewresearch.com/industry-analysis/edge-computing-market>
- **注意事項**: 調査会社間で定義が異なるため数値に大きなばらつきあり。記事では具体的な数値を断定的に記載せず、「急成長市場」として言及するのが安全
- **記事での表現**: 具体的な市場規模の数値よりも、エッジコンピューティングが急成長分野であることを示す文脈で使用

## 10. Vercel Edge Functions（2022年）

- **結論**: 2022年6月28日にパブリックベータ。2022年10月19日にリージョン指定デプロイのサポート発表。2022年12月15日にGA。V8ベースのエッジランタイム
- **一次ソース**: Vercel Changelog; InfoQ, "Vercel Launches Edge Functions to Provide Compute at the Edge"
- **URL**: <https://vercel.com/changelog/edge-functions-are-now-generally-available>, <https://www.infoq.com/news/2022/12/vercel-edge-functions-ga/>
- **注意事項**: Next.jsフレームワークとの統合が特徴。フロントエンド開発者向けのエッジコンピューティング普及に寄与
- **記事での表現**: 「2022年、VercelがEdge Functionsを発表。フロントエンドフレームワークとエッジコンピューティングの融合」
