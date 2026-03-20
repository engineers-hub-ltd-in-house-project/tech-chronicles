# ファクトチェック記録：第23回「オンプレミス回帰——クラウドの限界とハイブリッドの現実」

## 1. DHH/37signalsのクラウド離脱宣言と実績

- **結論**: 2022年10月19日、DHH（David Heinemeier Hansson）が「Why We're Leaving the Cloud」をブログに投稿。37signalsのクラウド費用は年間320万ドルに達していた。2022年12月に約60万ドル相当のDellサーバを発注、最終的にハードウェア投資は約70万ドル。2023年中にBasecamp、HEY含む7つの主要アプリケーションをAWSおよびGoogle Cloudから移行。追加人員なしで実行。インフラコストを半分から3分の2削減し、年間約200万ドルの節約を達成。5年間で1,000万ドル以上の節約を見込む。残存クラウド費用は年間130万ドル（AWS S3の4年契約分）
- **一次ソース**: DHH, "Why We're Leaving the Cloud", 2022年10月; 37signals Dev Blog, "Our cloud spend in 2022"; DHH, "Our cloud-exit savings will now top ten million over five years"
- **URL**: <https://basecamp.com/cloud-exit>, <https://dev.37signals.com/our-cloud-spend-in-2022/>, <https://world.hey.com/dhh/our-cloud-exit-savings-will-now-top-ten-million-over-five-years-c7d9b5bd>
- **注意事項**: 37signalsは比較的小規模（従業員約80名）で、ワークロードが予測可能な企業。すべての企業に当てはまるケースではない
- **記事での表現**: DHHの宣言の経緯、具体的なコスト数値、タイムライン、結果を詳述。ただし「すべての企業がクラウドを離れるべき」という文脈では使用しない

## 2. Dropboxの「Magic Pocket」移行

- **結論**: Dropboxは2015年10月7日までに約90%のファイルをAWS S3から自社インフラ（Magic Pocket）に移行完了。4つのデータセンターで運用。2015〜2016年の移行期間中にサードパーティデータセンター費用が9,250万ドル減少、自社データセンター費用が5,300万ドル増加し、差し引き3,950万ドルの節約。2018年のS-1（IPO目論見書）によれば、2年間で7,460万ドルの運用コスト削減を達成。粗利率はQ1 2016の46%からQ4 2017の70%に改善
- **一次ソース**: Dropbox S-1 Filing (2018); InfoQ, "Dropbox Develops Magic Pocket, Moves Away From AWS", 2016年3月; GeekWire, "Dropbox saved almost $75 million over two years by building its own tech infrastructure", 2018年
- **URL**: <https://www.infoq.com/news/2016/03/Dropbox-AWS/>, <https://www.geekwire.com/2018/dropbox-saved-almost-75-million-two-years-building-tech-infrastructure/>
- **注意事項**: Dropboxはエクサバイト規模のストレージを扱う特殊なケース。自社でストレージシステムを開発・運用できるエンジニアリング力があった
- **記事での表現**: 大規模ストレージワークロードにおけるオンプレ回帰の先駆的事例として言及。規模とエンジニアリング能力が前提条件であることを明記

## 3. Andreessen Horowitz「The Cost of Cloud, a Trillion Dollar Paradox」

- **結論**: 2021年、a16zのMartin CasadoとSarah Wangが論文を発表。上場ソフトウェア企業50社の財務報告を分析し、「大規模運用においてクラウドのコストはインフラ費用を2倍にしうる」と結論。推定1,000億ドルの時価総額がクラウドコストの影響で失われているとの試算。粗利1ドルの節約につき時価総額が24〜25倍上昇するとの分析
- **一次ソース**: Martin Casado, Sarah Wang, "The Cost of Cloud, a Trillion Dollar Paradox", Andreessen Horowitz, 2021年
- **URL**: <https://a16z.com/the-cost-of-cloud-a-trillion-dollar-paradox/>
- **注意事項**: a16zはインフラ関連スタートアップに投資するVCであり、クラウド代替ソリューションへの投資動機がある点に留意。反論も多数あり（VentureBeat等）
- **記事での表現**: クラウドコスト議論を加速させた論考として紹介。ただしVCのポジショントークである可能性にも言及

## 4. クラウドリパトリエーション統計

- **結論**: Barclays CIO Survey（2024年末）によると、86%のCIOがパブリッククラウドのワークロードの一部をプライベートクラウドまたはオンプレミスに戻す計画。2020年後半の43%から大幅増加。ただしIDC調査（2024年10月）では、全ワークロードをクラウドから移す組織はわずか約8%。大多数は本番データ、バックアップ、コンピュートリソースなど特定要素のみを移行
- **一次ソース**: Barclays CIO Survey 2024; IDC Survey (October 2024)
- **URL**: <https://www.puppet.com/blog/cloud-repatriation>, <https://www.eetimes.eu/cloud-repatriation-on-the-rise-83-of-cios-plan-workload-shifts-in-2024/>
- **注意事項**: 「86%がリパトリエーションを計画」は「一部のワークロード」であり、全面撤退ではない。見出しの数字だけを切り取ると誤解を招く
- **記事での表現**: 統計の正確な文脈（一部ワークロードの移行であること）を明示した上で引用

## 5. Gartner パブリッククラウド支出予測

- **結論**: Gartnerの予測（2024年11月発表）によると、2025年の世界パブリッククラウド支出は7,234億ドル、2024年の5,957億ドルから21.5%増。全セグメントで二桁成長。クラウドインフラ＆プラットフォームサービス（CIPS）は2025年に3,010億ドル（前年比24.2%増）。2029年には1.42兆ドルに到達する見通し
- **一次ソース**: Gartner Press Release, "Gartner Forecasts Worldwide Public Cloud End-User Spending to Total $723 Billion in 2025", November 19, 2024
- **URL**: <https://www.gartner.com/en/newsroom/press-releases/2024-11-19-gartner-forecasts-worldwide-public-cloud-end-user-spending-to-total-723-billion-dollars-in-2025>
- **注意事項**: リパトリエーションの動きがある一方、クラウド市場全体は成長を続けている事実
- **記事での表現**: オンプレ回帰論とクラウド成長が共存している構造を示すために使用

## 6. GPU/AIインフラのオンプレ回帰とTCO

- **結論**: NVIDIA H100 GPU 8基構成のサーバでは、約8,556時間（約11.9ヶ月）でオンプレミスとクラウドのコストが損益分岐点に達する。高稼働率ワークロードでは4ヶ月未満で損益分岐。稼働率20%未満ではクラウドレンタルのほうが経済的。H100クラウド料金（2025年末時点）: オンデマンド$1.49〜$6.98/時間。H100購入価格: 約$25,000/基、DGX H200/B200（8GPU）システムは$400,000〜$500,000
- **一次ソース**: Lenovo Press, "On-Premise vs Cloud: Generative AI Total Cost of Ownership (2025 Edition)"; GMI Cloud pricing analysis
- **URL**: <https://lenovopress.lenovo.com/lp2225-on-premise-vs-cloud-generative-ai-total-cost-of-ownership-2025-edition>, <https://www.gmicloud.ai/blog/h100-gpu-pricing-2025-cloud-vs-on-premise-cost-analysis>
- **注意事項**: Lenovoはオンプレミスハードウェアベンダーであるため、オンプレ有利な結果が出やすい可能性がある。ただし損益分岐の計算ロジック自体は妥当
- **記事での表現**: AI/GPUワークロードにおけるTCO分析として引用。クラウドが有利なケース（変動ワークロード、実験段階）も併記

## 7. Flexera 2025 State of the Cloud Report

- **結論**: クラウド予算の27%が無駄になっている（未使用リソース、過剰プロビジョニング、放置サービス）。84%の組織がクラウド支出の管理を最大の課題と回答。クラウド予算は計画を17%超過。33%の組織が年間1,200万ドル以上をパブリッククラウドに支出。70%の組織がクラウド予算の行き先を把握できていない
- **一次ソース**: Flexera, "2025 State of the Cloud Report"
- **URL**: <https://www.flexera.com/blog/finops/the-latest-cloud-computing-trends-flexera-2025-state-of-the-cloud-report/>
- **注意事項**: 自己申告ベースの調査であり、「無駄」の定義が主観的な面がある
- **記事での表現**: クラウドコスト管理の難しさを示す統計として使用

## 8. データローカリゼーション規制とDORA

- **結論**: EU GDPR: EU市民のデータはEEA内またはそれと同等の保護水準を持つ管轄区域に保存が必要。違反時は全世界売上の4%または2,000万ユーロのいずれか高い方の制裁金。DORA（Digital Operational Resilience Act）: 2022年12月採択、2025年1月17日施行。金融機関に対し重要ICTプロバイダーの出口戦略を義務付け。2025年11月18日、欧州監督当局がCTPP（Critical ICT Third-Party Providers）リストを公表し、Google Cloud、Microsoft、AWSが指定。ロシア、中国は厳格なデータローカリゼーション法を施行
- **一次ソース**: EU GDPR; EU DORA Regulation; AWS Blog, "AWS designated as a critical third-party provider under EU's DORA regulation"
- **URL**: <https://aws.amazon.com/blogs/security/aws-designated-as-a-critical-third-party-provider-under-eus-dora-regulation/>, <https://www.digital-operational-resilience-act.com/>
- **注意事項**: DORAは「オンプレミス回帰」を義務付けるものではなく、「出口戦略の策定」を義務付けるもの。混同しないよう注意
- **記事での表現**: 規制がクラウド一辺倒の戦略に制約を加える要因として紹介。DORAの趣旨を正確に記述

## 9. ハイブリッドクラウド設計パターン

- **結論**: 主要パターン3つ: (1) クラウドバースティング——通常はオンプレで稼働し、需要スパイク時にクラウドへスケールアウト。(2) データティアリング——アクセス頻度に応じてオンプレ/クラウドにデータを配置。(3) ディザスタリカバリ——主ワークロードはオンプレ、バックアップ/DRサイトとしてクラウドを活用。ライフサイクルポリシーで低コストオブジェクトティアに移行し、長期保存コストを最大70%削減可能。DRティア分類: Tier-1（ゼロデータロス、同期レプリケーション）、Tier-2（分単位RPO、非同期レプリケーション）、Tier-3（定期バックアップのみ）
- **一次ソース**: IBM, "How to Design a Hybrid Cloud Architecture"; Google Cloud Architecture Center
- **URL**: <https://www.ibm.com/think/topics/design-hybrid-cloud-architecture>, <https://docs.cloud.google.com/architecture/disaster-recovery>
- **注意事項**: ハイブリッドクラウドの実装は組織のネットワーク環境やスキルセットに大きく依存する
- **記事での表現**: 技術論セクションでハイブリッドクラウドの3つの設計パターンとして解説

## 10. AWS Outposts / Azure Stack HCI

- **結論**: AWS Outpostsはサブスクリプション型の完全マネージドサービス。AWSがハードウェアからソフトウェア更新まで管理。Azure Stack HCIはCisco、Dell、HPE、Lenovo等のパートナーハードウェアと連携するライセンスモデル。顧客がハードウェアとソフトウェアライセンスを前払い購入。Outpostsは高い導入コストと一部AWSネイティブサービス（Glue等）の非対応が指摘されている
- **一次ソース**: AWS, "On-Premises Private Cloud - AWS Outposts Family"; TechTarget comparison
- **URL**: <https://aws.amazon.com/outposts/>, <https://www.techtarget.com/searchdatacenter/tip/AWS-Outposts-vs-Azure-Stack-vs-HCI>
- **注意事項**: 第22回でAWS Outposts、Azure Arc、Google Anthosの2019年同時発表には言及済み。重複を避ける
- **記事での表現**: ハイブリッドクラウドを実現するためのベンダーソリューションとして簡潔に言及。第22回との重複を最小限に
