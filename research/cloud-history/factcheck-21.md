# ファクトチェック記録：第21回「FinOps——クラウドコストという新しい工学」

## 1. AWS Reserved Instances の発表日

- **結論**: AWS Reserved Instancesは2009年3月12日に発表された。Linux/OpenSolarisインスタンスを対象に、1年または3年の期間で一括前払い＋低い時間単価で利用可能とする料金モデル。初期は米国リージョンのみで提供開始
- **一次ソース**: AWS, "Amazon EC2 Introduces Reserved Instances"
- **URL**: <https://aws.amazon.com/about-aws/whats-new/2009/03/12/amazon-ec2-introduces-reserved-instances/>
- **注意事項**: AWSの最初のコミットメントプログラム。以後、リージョンスコープ、Convertible RI等の改良が追加された
- **記事での表現**: 「2009年3月12日、AWSはReserved Instancesを発表した。1年または3年の期間でキャパシティを予約し、時間単価を大幅に引き下げるモデルだ」

## 2. AWS Spot Instances の発表日

- **結論**: AWS Spot Instancesは2009年12月14日に発表された。Jeff Barrが「Amazon EC2 Spot Instances – And Now How Much Would You Pay?」というブログ記事で紹介。AWSの余剰キャパシティを入札方式で利用する仕組み
- **一次ソース**: AWS, "Announcing Amazon EC2 Spot Instances"
- **URL**: <https://aws.amazon.com/about-aws/whats-new/2009/12/14/announcing-amazon-ec2-spot-instances/>
- **注意事項**: 当初は入札方式だったが、2017年のアップデートで料金モデルが変更され、入札は不要になった
- **記事での表現**: 「同年12月、Spot Instancesが登場した。AWSの余剰キャパシティを大幅な割引価格で利用できるが、いつ中断されるかわからないという制約付きだ」

## 3. AWS Savings Plans の発表

- **結論**: AWS Savings Plansは2019年11月（AWS re:Invent 2019時期）に発表された。Reserved Instancesよりも柔軟な代替として、インスタンスタイプではなく使用金額（$/hour）に対するコミットメントモデル。Compute Savings Plans（最大66%割引）とEC2 Instance Savings Plans（最大72%割引）の2種類。2020年8月にLambda、Fargateにも適用拡大
- **一次ソース**: AWS News Blog, "New – Savings Plans for AWS Compute Services"
- **URL**: <https://aws.amazon.com/blogs/aws/new-savings-plans-for-aws-compute-services/>
- **注意事項**: RI（キャパシティベースのコミットメント）からSP（支出ベースのコミットメント）への転換が重要なポイント
- **記事での表現**: 「2019年11月、AWSはSavings Plansを発表した。RIがインスタンスタイプに紐づいていたのに対し、Savings Plansは使用金額に対するコミットメントだ」

## 4. FinOps Foundation の設立と経緯

- **結論**: FinOps Foundationは2019年2月に、J.R. Storment（Cloudability共同創業者）によって設立された。2020年6月29日にLinux Foundation傘下に加入。2026年時点で96,000人以上のコミュニティ、15,000社以上が参加、Fortune 50のうち93社が参加。設立メンバーにはApptio、Cloudeasier、Kubecost、ProsperOps、VMware等
- **一次ソース**: FinOps Foundation, "About"; Linux Foundation Press Release
- **URL**: <https://www.finops.org/about/>, <https://www.linuxfoundation.org/press/press-release/finops-foundation-quickly-gains-industry-wide-support-to-advance-cloud-financial-management-and-education>
- **注意事項**: ブループリントでは「2019年、Linux Foundation傘下」とあるが、正確には2019年2月設立、2020年6月にLinux Foundation傘下に加入
- **記事での表現**: 「2019年2月、J.R. StormentがFinOps Foundationを設立した。2020年6月にLinux Foundation傘下に加入し、クラウドコスト管理のベストプラクティスを標準化する組織として急速に成長した」

## 5. FinOps フレームワークの3フェーズ

- **結論**: FinOps Foundationが定義するフレームワークは、Inform（可視化）、Optimize（最適化）、Operate（運用）の3フェーズで構成される反復的サイクル。Inform=コスト可視化・配賦・予算策定・予測、Optimize=使用量最適化とレート最適化、Operate=KPI追跡・ガバナンスポリシー実行
- **一次ソース**: FinOps Foundation, "FinOps Phases"
- **URL**: <https://www.finops.org/framework/phases/>
- **注意事項**: 3フェーズは順序ではなく反復的なサイクルとして設計されている
- **記事での表現**: 「FinOpsフレームワークは3つのフェーズで構成される——Inform（可視化）、Optimize（最適化）、Operate（運用）。これは一方向のプロセスではなく、反復的なサイクルだ」

## 6. DHH / 37signals のクラウド離脱

- **結論**: DHH（David Heinemeier Hansson）が2022年10月にクラウド離脱を発表。37signalsはBasecamp、HEYなどをAWSとGCPから自社ハードウェアに移行。クラウド時代の年間支出は約320万ドル。移行後は年間約150万ドル削減。ハードウェア投資は約60万ドルで、6ヶ月で回収。5年間で1,000万ドル以上の削減を見込む。新規人員の追加なしで移行完了
- **一次ソース**: 37signals Dev Blog, "Our cloud spend in 2022"; Basecamp, "Leaving the Cloud"
- **URL**: <https://dev.37signals.com/our-cloud-spend-in-2022/>, <https://basecamp.com/cloud-exit>
- **注意事項**: 37signalsは中規模で安定したワークロードという特殊な条件。全企業に当てはまる戦略ではない
- **記事での表現**: 「2022年10月、DHHはクラウド離脱を宣言した。年間320万ドルのクラウド支出を、60万ドルのハードウェア投資で年間150万ドル削減できるという計算だ」

## 7. Apptio の歴史と IBM による買収

- **結論**: Apptioは2007年に創業（ワシントン州ベルビュー）。IT支出管理（TBM: Technology Business Management）のSaaSを提供。2016年9月にIPO。2018年11月にVista Equity Partnersが19.4億ドルで買収。2019年にCloudabilityを買収してクラウドコスト管理機能を強化。2023年6月26日にIBMが46億ドルでの買収を発表、同年8月10日に完了。Fortune 100の半数以上、1,500以上の顧客
- **一次ソース**: IBM Newsroom; TechCrunch
- **URL**: <https://newsroom.ibm.com/2023-08-10-IBM-Completes-Acquisition-of-Apptio-Inc>, <https://techcrunch.com/2023/06/26/ibm-acquires-apptio-from-vista-for-4-6b-in-cash-to-double-down-on-hybrid-cloud-services/>
- **注意事項**: IBMが46億ドルを投じた事実は、FinOps/クラウドコスト管理市場の巨大さを示す
- **記事での表現**: 「2023年、IBMはApptioを46億ドルで買収した。IT支出管理ツール企業にこの金額が付くこと自体が、クラウドコスト管理の市場規模を物語っている」

## 8. Cloudability の歴史

- **結論**: Cloudabilityは2011年にMat Ellis、J.R. Storment、Jon Frisbyによってオレゴン州ポートランドで創業。クラウド課金・利用データの管理に特化。4,400万ドルの資金を調達。2019年にApptioが買収（買収時に90億ドル以上のクラウド支出を管理）。現在はIBM Cloudabilityとして提供
- **一次ソース**: Tracxn, TechTarget
- **URL**: <https://tracxn.com/d/companies/cloudability/>, <https://www.techtarget.com/searchcloudcomputing/definition/Cloudability>
- **注意事項**: J.R. Stormentは後にFinOps Foundationを設立（2019年2月）。Cloudabilityの実務経験がFinOps Foundationの設計思想に直結
- **記事での表現**: 「J.R. Stormentは2011年にCloudabilityを共同創業し、後に2019年にFinOps Foundationを設立した。クラウドコスト管理の現場経験がフレームワーク設計に活かされている」

## 9. クラウド支出の無駄に関する統計データ

- **結論**: Flexera 2025 State of the Cloud Reportによれば、クラウド支出の27%が無駄。84%の組織がクラウド支出管理を最大の課題と回答。組織は予算を平均17%超過。Harness「FinOps in Focus」レポートによれば、2025年にインフラクラウドの無駄は445億ドルに達する見込み。Gartnerは2025年のパブリッククラウド支出を7,234億ドルと予測（前年比21.5%増）
- **一次ソース**: Flexera, "2025 State of the Cloud Report"; Gartner Press Release; Harness
- **URL**: <https://www.flexera.com/blog/finops/the-latest-cloud-computing-trends-flexera-2025-state-of-the-cloud-report/>, <https://www.gartner.com/en/newsroom/press-releases/2024-11-19-gartner-forecasts-worldwide-public-cloud-end-user-spending-to-total-723-billion-dollars-in-2025>
- **注意事項**: 「27%の無駄」はFlexeraの調査結果。調査手法により数値は異なるが、概ね20-30%の範囲で複数ソースが一致
- **記事での表現**: 「Flexeraの調査によれば、クラウド支出の27%が無駄にされている。2025年のパブリッククラウド支出が7,234億ドルという規模を考えれば、その27%は約1,950億ドルだ」

## 10. AWS Cost Explorer

- **結論**: AWS Cost Explorerは2013年に導入。AWSのコスト可視化ツールで、最大14ヶ月の日次粒度データ、38ヶ月の月次粒度データを提供。利用は無料。Reserved Instancesの推奨も提供
- **一次ソース**: AWS Documentation
- **URL**: <https://docs.aws.amazon.com/cost-management/latest/userguide/ce-what-is.html>
- **注意事項**: 導入当初の機能は限定的で、年々拡張されてきた
- **記事での表現**: 「2013年にAWSはCost Explorerを導入した。利用料金の可視化ツールだが、見るだけでは最適化にはならない」

## 11. Infracost（Terraform コスト見積もりツール）

- **結論**: Infracostは2020年6月にv0.1.0としてオープンソースリリース。Hassan Khajeh-Hosseini、Ali Khajeh-Hosseini、Alistair Scottが作成。Go言語で開発、Apache-2.0ライセンス。AWS、Azure、GCPの1,100以上のTerraformリソースに対応。CI/CDパイプラインに統合してPRにコスト見積もりを表示する「Shift FinOps Left」のコンセプト
- **一次ソース**: GitHub, infracost/infracost
- **URL**: <https://github.com/infracost/infracost>
- **注意事項**: IaCのコスト見積もりは「設計段階でコストを可視化する」というFinOpsの新しいアプローチ
- **記事での表現**: 「2020年、Infracostがオープンソースでリリースされた。Terraformのコードからデプロイ前にコストを見積もるツールだ」

## 12. Lyft のクラウドコスト最適化事例

- **結論**: Lyftは内部ツールとAWSサービスを活用し、6ヶ月でクラウド支出を40%削減。機械学習パイプライン全体をSpot Instancesで運用し、MLインフラだけで年間100万ドル以上を節約
- **一次ソース**: AWS Solutions Case Study; Finout Case Study
- **URL**: <https://aws.amazon.com/solutions/case-studies/lyft-cost-management/>, <https://www.finout.io/case-study/lyft>
- **注意事項**: Lyftの事例はFinOpsの実践的成果を示す好例
- **記事での表現**: 「Lyftは6ヶ月でクラウド支出を40%削減した。MLパイプラインをSpot Instancesで運用するだけで年間100万ドル以上の節約だ」
