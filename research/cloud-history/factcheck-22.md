# ファクトチェック記録：第22回「マルチクラウドの現実——理想と実務のギャップ」

## 1. HashiCorp Terraform の初期リリース

- **結論**: Terraform 0.1 は 2014年7月28日にリリースされた。HashiCorp は 2012年に Mitchell Hashimoto と Armon Dadgar が共同設立。Hashimoto は 2011年の AWS CloudFormation 発表翌日にブログ記事を書き、クラウド非依存のオープンソース IaC ツールの必要性を主張していた。初期は AWS と DigitalOcean のみ対応。最初の18ヶ月はダウンロード数が停滞し、プロジェクト終了も検討されたが、2016年末までに750人以上のコントリビューターと数十のプロバイダー（Azure、GCP、OpenStack等）を獲得した
- **一次ソース**: HashiCorp, "The Story of HashiCorp Terraform with Mitchell Hashimoto"; Wikipedia, "Terraform (software)"
- **URL**: <https://www.hashicorp.com/en/resources/the-story-of-hashicorp-terraform-with-mitchell-hashimoto>, <https://en.wikipedia.org/wiki/Terraform_(software)>
- **注意事項**: Terraform 1.0 GA は 2021年6月。BSL ライセンス変更は 2023年8月（別項目で詳述）
- **記事での表現**: 2014年7月、Mitchell Hashimoto が Terraform 0.1 をリリースした。CloudFormation の「クラウド固有」という制約に対する、「クラウド非依存」の回答だった

## 2. AWS CloudFormation のリリース

- **結論**: AWS CloudFormation は 2011年2月25日にリリースされた。リリース時点で AWS の15サービス中13に対応し、48のリソースタイプをサポート。JSON フォーマットでインフラを宣言的に定義（YAML 対応は2016年）
- **一次ソース**: AWS, "Introducing AWS CloudFormation", February 25, 2011
- **URL**: <https://aws.amazon.com/about-aws/whats-new/2011/02/25/introducing-aws-cloudformation/>
- **注意事項**: IaC の先駆的サービスだが、AWS 専用であることが Terraform 誕生の動機となった
- **記事での表現**: 2011年2月、AWS は CloudFormation をリリースし、インフラのコード化という概念を広めた。だがそれは AWS のみの世界だった

## 3. Pulumi のローンチ

- **結論**: Pulumi は 2018年6月18日にローンチされた。創業チームは Joe Duffy、Eric Rudder、Luke Hoban の3名。Madrona Venture Group と Tola Capital から500万ドルのシード投資を獲得。JavaScript、TypeScript、Python、Go をサポートし、AWS、Azure、GCP、Kubernetes に対応
- **一次ソース**: Pulumi, "Pulumi Launches Cloud Development Platform", June 18, 2018
- **URL**: <https://info.pulumi.com/press-release/pulumi-launches-cloud-development-platform-to-help-teams-get-code-to-the-cloud-faster>
- **注意事項**: Terraform が独自の HCL を使うのに対し、Pulumi は汎用プログラミング言語を使う点が差異
- **記事での表現**: 2018年6月、Pulumi は「使い慣れたプログラミング言語でインフラを定義する」というアプローチでローンチされた

## 4. Crossplane のオープンソース化

- **結論**: Crossplane は Upbound 社（Rook ストレージオーケストレーターの開発元）により、KubeCon NA 2018 に先立ちオープンソースとして公開された。Kubernetes 上にクラウドリソースの抽象化レイヤーを構築する「ユニバーサルコントロールプレーン」を目指す。CNCF プロジェクトとして採用
- **一次ソース**: InfoQ, "Upbound Release Preview of 'Crossplane', a Universal Control Plane API for Cloud Computing", January 2019
- **URL**: <https://www.infoq.com/news/2019/01/upbound-crossplane/>
- **注意事項**: ブループリントでは「2019年」とあるが、公開は2018年末（KubeCon NA 2018前）。InfoQ の報道は2019年1月
- **記事での表現**: 2018年末にオープンソースとして公開された Crossplane は、Kubernetes のカスタムリソース定義を使ってクラウドリソースを宣言的に管理するアプローチを提示した

## 5. AWS Outposts の発表と GA

- **結論**: AWS Outposts は 2018年11月28日の re:Invent 2018 で発表（プライベートプレビュー）。2019年12月3日の re:Invent 2019 で一般提供（GA）開始
- **一次ソース**: Amazon Press Center, "Amazon Web Services Announces AWS Outposts", November 2018; "AWS Announces General Availability of AWS Outposts", December 2019
- **URL**: <https://press.aboutamazon.com/2018/11/amazon-web-services-announces-aws-outposts>, <https://press.aboutamazon.com/2019/12/aws-announces-general-availability-of-aws-outposts>
- **注意事項**: Outposts は AWS のハードウェアを顧客のデータセンターに設置する形態。ハイブリッドクラウド戦略の一環
- **記事での表現**: AWS は 2018年11月の re:Invent で Outposts を発表し、2019年12月に GA を開始した。AWS のインフラを顧客のオンプレミス環境に延伸するという、AWS にとっての180度の転換だった

## 6. Azure Arc の発表

- **結論**: Microsoft は 2019年11月の Microsoft Ignite（オーランド）で Azure Arc を発表。CEO Satya Nadella が基調講演で紹介。Azure の管理プレーンを AWS や GCP を含む任意のインフラに拡張するサービス
- **一次ソース**: Redmond Magazine, "Ignite 2019 Keynote Recap: Nadella Unveils Azure Arc"; TechCrunch, "The 7 most important announcements from Microsoft Ignite"
- **URL**: <https://redmondmag.com/articles/2019/11/04/ignite-2019-keynote-recap.aspx>, <https://techcrunch.com/2019/11/04/the-7-most-important-announcements-from-microsoft-ignite/>
- **注意事項**: Azure Arc は競合クラウド上のリソースも Azure で管理できる点が特徴的
- **記事での表現**: 2019年11月、Microsoft Ignite で Satya Nadella が Azure Arc を発表した。Azure の管理プレーンを任意のインフラ——AWS や GCP 上のリソースさえも——に拡張するという大胆な提案だった

## 7. Google Anthos の発表とその後の変遷

- **結論**: Google は 2019年4月の Cloud Next で Anthos を発表。GKE をベースとしたハイブリッド/マルチクラウドプラットフォーム。AWS や Azure 上のワークロードも管理可能。100%ソフトウェアベース。その後、2022年に Google Distributed Cloud へリブランディング、さらに GKE Enterprise へと名称が変遷
- **一次ソース**: InfoQ, "Google Releases Anthos, a Hybrid Cloud Platform, to General Availability", April 2019; Google Cloud Blog, "Making hybrid- and multi-cloud computing a reality"
- **URL**: <https://www.infoq.com/news/2019/04/gcp-anthos-ga/>, <https://cloud.google.com/blog/topics/hybrid-cloud/new-platform-for-managing-applications-in-todays-multi-cloud-world>
- **注意事項**: Anthos ブランドは段階的に廃止され、GKE Enterprise に統合された。名称変遷自体がマルチクラウド戦略の難しさを象徴
- **記事での表現**: 2019年4月、Google は Cloud Next で Anthos を発表した。Kubernetes をポータビリティレイヤーとして、AWS や Azure 上でも動作するマルチクラウドプラットフォームだった。だが皮肉なことに、Anthos 自体が後に Google Distributed Cloud、そして GKE Enterprise へと名称を変え続けることになる

## 8. HashiCorp BSL ライセンス変更と OpenTofu フォーク

- **結論**: 2023年8月10日、HashiCorp は Terraform を含む全製品のライセンスを MPL（Mozilla Public License）から BSL v1.1（Business Source License）に変更。8月15日に OpenTF マニフェスト公開、8月25日にフォーク発表、9月20日に Linux Foundation が OpenTofu として受け入れ。2024年4月24日、IBM が HashiCorp を64億ドルで買収を発表
- **一次ソース**: HashiCorp Blog, "HashiCorp adopts Business Source License", August 10, 2023; Linux Foundation, "Announcing OpenTofu", September 20, 2023; TechCrunch, "Terraform fork gets renamed OpenTofu, and joins Linux Foundation"
- **URL**: <https://www.hashicorp.com/en/blog/hashicorp-adopts-business-source-license>, <https://www.linuxfoundation.org/press/announcing-opentofu>, <https://techcrunch.com/2023/09/20/terraform-fork-gets-a-new-name-opentofu-and-joins-linux-foundation/>
- **注意事項**: BSL は内部利用は無料だが、競合サービスでの利用を制限。OpenTofu は Gruntwork、Spacelift、env0 等が参画
- **記事での表現**: 2023年8月、HashiCorp は Terraform のライセンスを BSL に変更した。わずか41日後に Linux Foundation が OpenTofu を受け入れ、マルチクラウドの抽象化レイヤーそのものがフォークするという事態に至った

## 9. マルチクラウド採用統計

- **結論**: Flexera 2024 State of the Cloud Report によると、組織は平均2.4のパブリッククラウドプロバイダーを利用。70%がハイブリッドクラウド戦略を採用。AWS 49%、Azure 45%、GCP 21%（significant workloads ベース）。クラウド支出管理が最大の課題（84%）。FinOps チーム保有率は51%→59%に増加
- **一次ソース**: Flexera, "2024 State of the Cloud Report"; Flexera, "2025 State of the Cloud Report"
- **URL**: <https://www.flexera.com/blog/finops/cloud-computing-trends-flexera-2024-state-of-the-cloud-report/>, <https://www.flexera.com/blog/finops/the-latest-cloud-computing-trends-flexera-2025-state-of-the-cloud-report/>
- **注意事項**: 「89%がマルチクラウド」等の高い数字は、意図的なマルチクラウド戦略と、結果的に複数クラウドを使っている状態を区別していない場合がある
- **記事での表現**: Flexera の 2024年調査によれば、組織は平均2.4のパブリッククラウドを利用している。だがこの数字は「意図的なマルチクラウド戦略」と「結果的に複数クラウドを使っている状態」を区別していない

## 10. Kubernetes ポータビリティの限界

- **結論**: Kubernetes はコンピュートの抽象化を提供するが、ストレージ（EBS vs Persistent Disk）、ネットワーク（ロードバランサー実装）、マネージドサービス（RDS vs Cloud SQL）等のクラウド固有サービスとの統合部分でポータビリティが破綻する。McKinsey Digital の分析では「Kubernetes は本当にマルチクラウドのポータビリティを提供するか」に疑問を呈している。真のポータビリティには「最小公倍数」アプローチが必要で、各クラウドの固有機能を放棄することになる
- **一次ソース**: McKinsey Digital, "Does Kubernetes really give you multicloud portability?"; Diginomica, "Kubernetes and the misconception of multi-cloud portability"
- **URL**: <https://medium.com/digital-mckinsey/does-kubernetes-really-give-you-multicloud-portability-476270a0acc7>, <https://diginomica.com/kubernetes-and-misconception-multi-cloud-portability>
- **注意事項**: Kubernetes 自体のポータビリティと、アプリケーション全体のポータビリティは別問題
- **記事での表現**: Kubernetes はコンピュートレイヤーの抽象化を提供するが、アプリケーションが依存するストレージ、ネットワーク、マネージドサービスはクラウド固有のままである。ポータビリティの約束は、アプリケーションのごく一部にしか及ばない
