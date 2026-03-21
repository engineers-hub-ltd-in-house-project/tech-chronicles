# ファクトチェック記録：第24回「計算資源の民主化——『他人の計算機を借りる』とは何だったのか」

## 1. CTSS（Compatible Time-Sharing System）の歴史

- **結論**: 1961年11月、MITのFernando J. Corbatoが IBM 709 上で実験的タイムシェアリングシステムを実演。これが公開された最初のタイムシェアリングデモとされる。1963年夏からMIT Computation Centerで定常サービスを開始し、1968年まで運用された。ハードウェアは改造版IBM 7094（「blue machine」）で、32K語の36ビットワード・コアメモリを2バンク搭載していた
- **一次ソース**: MIT CSAIL, "Compatible Time-Sharing System (1961-1973) Fiftieth Anniversary"
- **URL**: <https://people.csail.mit.edu/saltzer/Multics/CTSS-Documents/CTSS_50th_anniversary_web_03.pdf>
- **注意事項**: 「最初のタイムシェアリングシステム」については他にも主張があるが、公開デモとしてはCTSSが最初とされる
- **記事での表現**: 1961年、MITのFernando Corbatoが IBM 709 上でタイムシェアリングの実験を公開デモンストレーションした

## 2. John McCarthyの「計算の公共事業化」発言（1961年）

- **結論**: 1961年、MITの100周年記念式典でJohn McCarthyが「Computing may someday be organized as a public utility just as the telephone system is a public utility」と発言。タイムシェアリング技術が将来、水道や電気のようなユーティリティモデルで計算資源を提供しうると予見した
- **一次ソース**: John McCarthy, MIT Centennial Celebration speech, 1961
- **URL**: <https://en.wikipedia.org/wiki/John_McCarthy_(computer_scientist)>
- **注意事項**: この概念は1960年代後半に人気を博したが、当時のハードウェア・ソフトウェア・通信技術の限界により1970年代半ばには下火になった。2000年代にクラウドコンピューティングとして復活
- **記事での表現**: 1961年、John McCarthyはMIT100周年記念で「計算はいつか電話システムのような公共事業として組織されるかもしれない」と述べた

## 3. J.C.R. Lickliderの「Intergalactic Computer Network」構想（1962-1963年）

- **結論**: 1962年8月、BBN在籍中のLickliderが「Intergalactic Computer Network」の構想をメモとして記述。1963年、ARPA（後のDARPA）情報処理技術局長として、同僚宛のメモで「Members and Affiliates of the Intergalactic Computer Network」と題した。この構想がARPANET、ひいてはインターネットの思想的基盤となった
- **一次ソース**: Internet Hall of Fame, "J.C.R. Licklider Inductee Biography"
- **URL**: <https://www.internethalloffame.org/inductee/jcr-licklider/>
- **注意事項**: Lickliderのビジョンには今日のクラウドコンピューティングに相当する概念が含まれていた
- **記事での表現**: 1962年、J.C.R. Lickliderは「銀河間コンピュータネットワーク」という壮大な構想を描き、誰もがネットワーク越しに計算資源にアクセスできる世界を予見した

## 4. パーソナルコンピュータの歴史（Altair 8800、Apple II、IBM PC）

- **結論**: Altair 8800は1975年1月にMITS社から発売。Intel 8080 CPU、2MHz、基本メモリ256バイト（最大64KB拡張可能）。Apple IIは1977年4月発売、プラスチック筐体・キーボード一体型・カラーグラフィックス対応。IBM PCは1981年8月発売、Intel 8088プロセッサ搭載、オープンアーキテクチャを採用
- **一次ソース**: Computer History Museum, "Timeline of Computer History"
- **URL**: <https://www.computerhistory.org/timeline/computers/>
- **注意事項**: Altair 8800が「最初のパーソナルコンピュータ」かどうかは議論があるが、大衆向け市販品としては先駆的存在
- **記事での表現**: 1975年のAltair 8800、1977年のApple II、1981年のIBM PC——計算資源は組織の独占から個人の手へと移った

## 5. AWS EC2のベータ公開（2006年）とLambdaの発表（2014年）

- **結論**: AWS EC2は2006年8月25日に限定パブリックベータとして公開（GA は2008年10月23日）。AWS Lambdaは2014年11月13日にre:Invent 2014に先立ちプレビューとして発表。Node.jsをサポートし、S3バケット・DynamoDBテーブル・Kinesisストリームからのイベントトリガーに対応
- **一次ソース**: AWS公式発表, "Announcing Amazon Elastic Compute Cloud (Amazon EC2) - beta"; AWS Blog, "AWS Lambda turns ten"
- **URL**: <https://aws.amazon.com/about-aws/whats-new/2006/08/24/announcing-amazon-elastic-compute-cloud-amazon-ec2---beta/>, <https://aws.amazon.com/blogs/aws/aws-lambda-turns-ten-the-first-decade-of-serverless-innovation/>
- **注意事項**: EC2のベータ開始日は8月25日だが、公式発表ページの日付は8月24日（時差の可能性）
- **記事での表現**: 2006年、AWS EC2のベータ公開で「APIの一行でサーバを借りる」時代が始まり、2014年、AWS Lambdaの登場で「サーバを意識しない」計算の時代へと進んだ

## 6. NIST SP 800-145 クラウドコンピューティングの定義（2011年）

- **結論**: 2011年9月、NISTがSP 800-145「The NIST Definition of Cloud Computing」を公開。クラウドコンピューティングを「ネットワーク経由で共有可能な構成可能コンピューティングリソースのプールへの、ユビキタスで便利なオンデマンドアクセスを可能にするモデル」と定義。5つの基本特性（オンデマンド・セルフサービス、広範なネットワークアクセス、リソースプーリング、迅速な弾力性、従量課金）、3つのサービスモデル（IaaS、PaaS、SaaS）、4つのデプロイメントモデルを規定
- **一次ソース**: NIST, "Special Publication 800-145"
- **URL**: <https://csrc.nist.gov/pubs/sp/800/145/final>
- **注意事項**: この定義は今日でもクラウドの標準的定義として広く参照されている
- **記事での表現**: 2011年、NISTがクラウドの公式定義を発表し、5つの基本特性——オンデマンド・セルフサービス、広範なネットワークアクセス、リソースプーリング、迅速な弾力性、従量課金——を明文化した

## 7. クラウド市場規模（2025-2026年）

- **結論**: クラウドインフラサービスの世界支出は2025年Q1で909億ドル（前年比21%増）。2025年通年では4,000億ドル超が見込まれる。ハイパースケーラーの設備投資は2026年に6,000億ドル超と予測（2025年比36%増）。Gartnerは2026年の世界IT支出を6.15兆ドル（前年比10.8%増）と予測
- **一次ソース**: Canalys, "Global cloud infrastructure spending rose 21% in Q1 2025"; Gartner, 2026年2月プレスリリース
- **URL**: <https://canalys.com/newsroom/global-cloud-q1-2025>, <https://www.gartner.com/en/newsroom/press-releases/2026-02-03-gartner-forecasts-worldwide-it-spending-to-grow-10-point-8-percent-in-2026-totaling-6-point-15-trillion-dollars>
- **注意事項**: 調査会社によって市場定義が異なるため、数値に幅がある
- **記事での表現**: 2025年、クラウドインフラサービス市場は年間4,000億ドルを突破し、ハイパースケーラーの設備投資は2026年に6,000億ドルを超える見通しである

## 8. AI専用インフラとGPUクラウド需要

- **結論**: NVIDIAのデータセンター売上は2025年度（FY2026）Q3で570億ドル（前年比62%増）。ハイパースケーラーのAIインフラ投資は2026年に約7,000億ドルに達する見通し（2025年の約3,650億ドルからほぼ倍増）。AmazonのCapExは2026年に2,000億ドル、Googleは1,750〜1,850億ドルを予測。NVIDIAはBlackwell・Vera Rubinの受注残が2027年までに1兆ドルに達すると見込む
- **一次ソース**: NVIDIA Newsroom, Q3 FY2026 Earnings; Futurum Group; TechCrunch
- **URL**: <https://nvidianews.nvidia.com/news/nvidia-announces-financial-results-for-third-quarter-fiscal-2026>, <https://techcrunch.com/2026/02/28/billion-dollar-infrastructure-deals-ai-boom-data-centers-openai-oracle-nvidia-microsoft-google-meta/>
- **注意事項**: CapEx予測値は各社の決算発表時点のガイダンスに基づく。実績とは異なる可能性がある
- **記事での表現**: AI専用インフラへの投資は2026年に7,000億ドル規模に達し、計算資源の需要構造を根本から変えつつある

## 9. 量子コンピューティングのクラウド提供

- **結論**: IBM Quantumは2016年5月4日に5量子ビットのプロセッサをクラウド経由で一般公開（IBM Quantum Experience）。Amazon Braketは2019年12月のre:Inventで発表、2020年8月13日にGA。Google Quantum AIは2024年12月9日にWillowチップを発表——105量子ビットの超伝導プロセッサで、量子ビット数を増やしながらエラー率を指数関数的に低減する「閾値以下」の量子エラー訂正を達成
- **一次ソース**: IBM Quantum Blog; AWS Press Center; Google AI Blog
- **URL**: <https://www.ibm.com/quantum/blog/quantum-five-years>, <https://press.aboutamazon.com/2020/8/aws-announces-general-availability-of-amazon-braket>, <https://blog.google/technology/research/google-willow-quantum-chip/>
- **注意事項**: 量子コンピューティングは実用段階には至っておらず、現時点では研究・実験用途が中心
- **記事での表現**: 2016年にIBMが5量子ビットのプロセッサをクラウドで公開し、2020年にAmazon Braket、2024年にはGoogleのWillowチップが閾値以下の量子エラー訂正を達成した——量子計算もまた「他人の量子コンピュータを借りる」時代に入りつつある

## 10. Kubernetesの採用率（2025年CNCF調査）

- **結論**: 2026年1月発表のCNCF年次調査（2025年データ）によると、コンテナユーザーの82%がKubernetesを本番環境で使用（2023年の66%から増加）。98%の組織がクラウドネイティブ技術を採用。生成AIモデルをホストする組織の66%がKubernetesでインファレンスワークロードを管理。クラウドネイティブ開発者は1,560万人に到達
- **一次ソース**: CNCF, "Kubernetes Established as the De Facto 'Operating System' for AI as Production Use Hits 82%"
- **URL**: <https://www.cncf.io/announcements/2026/01/20/kubernetes-established-as-the-de-facto-operating-system-for-ai-as-production-use-hits-82-in-2025-cncf-annual-cloud-native-survey/>
- **注意事項**: 調査対象はCNCFコミュニティが中心のため、一般企業全体の採用率はやや低い可能性がある
- **記事での表現**: 2025年のCNCF調査では、コンテナユーザーの82%がKubernetesを本番環境で運用し、AIインファレンスワークロードの管理にも66%の組織がKubernetesを採用している

## 11. エッジコンピューティング市場

- **結論**: グローバルエッジコンピューティング市場は2025年に214億ドル、2026年に285億ドル、2035年には2,638億ドルに達する見通し（CAGR 28%）。Cloudflare Workersは2026年のガイダンスで27.9億ドルの売上を見込む。WebAssembly（Wasm）のエッジ活用が2026年の最も重要な技術動向とされる
- **一次ソース**: GM Insights, "Edge Computing Market Size & Share, Growth Trends 2026-2035"
- **URL**: <https://www.gminsights.com/industry-analysis/edge-computing-market>
- **注意事項**: Wasm at the Edge はまだ初期段階であり、大規模本番環境での実績は限定的
- **記事での表現**: エッジコンピューティング市場は2026年に285億ドルに達し、計算資源はクラウドの巨大データセンターからユーザーの近くへと再び分散しつつある

## 12. ソブリンクラウドとデータ主権

- **結論**: ソブリンクラウド市場は2025年に約1,290億ドル、2032年までに約5,723億ドルに成長見通し（CAGR 24.16%）。2025年11月18日、EU加盟国が「欧州デジタル主権宣言」を採択。2025年1月にEU Data Actが完全施行、同年9月からクラウドプロバイダーに切替支援を義務化。2025年10月にEU Cloud Sovereignty Frameworkが8つの要件を設定。ただし2026年時点でも米国CLOUD Actの域外適用は未解決
- **一次ソース**: MarkNtel Advisors; Atlantic Council; Broadcom News
- **URL**: <https://www.prnewswire.com/news-releases/sovereign-cloud-market-to-register-a-cagr-of-24-16-through-2032-driven-by-rising-data-sovereignty-regulations--markntel-advisors-302713680.html>, <https://news.broadcom.com/sovereign-cloud/three-predictions-for-sovereign-cloud-in-2026>
- **注意事項**: 欧州クラウドインフラ市場の70%を米国3社が占有しており、主権確保には技術的・経済的な大きな課題が残る
- **記事での表現**: ソブリンクラウド市場は2025年に1,290億ドルに達し、EUは「デジタル主権宣言」を採択した——「誰の計算機を借りるか」は、技術的選択からgeopoliticalな問いへと変貌している
