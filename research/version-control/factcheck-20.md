# ファクトチェック記録：第20回「CI/CDとgitの密結合——インフラがVCSを前提とする時代」

## 1. CruiseControl——最初のCIサーバ

- **結論**: CruiseControlは2001年にThoughtWorksのMatt Foemmelが作成した、最初の広く使われたCIソフトウェアである。Martin FowlerとMatt Foemmelが2001年に「Continuous Integration」の論文を発表し、CIの概念を確立した
- **一次ソース**: CruiseControl Wikipedia; Martin Fowler, "Continuous Integration", 2006（2000年の原版を改訂）
- **URL**: <https://en.wikipedia.org/wiki/CruiseControl>, <https://cruisecontrol.sourceforge.net/>
- **注意事項**: CIの概念自体はそれ以前にXP（Extreme Programming）の文脈で存在していた
- **記事での表現**: 「2001年、ThoughtWorksのMatt FoemmelがCruiseControlを作成した。最初の広く使われたCIサーバである」

## 2. Jenkins（Hudson）の歴史

- **結論**: Hudsonは2004年夏にSun MicrosystemsのKohsuke Kawaguchiが開発を開始し、2005年2月に初公開。2008年JavaOneでDuke's Choice Awardを受賞。2009年にOracleがSunを買収（74億ドル、2010年1月完了）。2010年12月にOracleが「Hudson」の商標を主張。2011年1月29日のコミュニティ投票により「Jenkins」に改名。OracleはHudsonのフォークを継続したが、2017年に廃止
- **一次ソース**: Wikipedia "Jenkins (software)", Wikipedia "Kohsuke Kawaguchi", The Register interview (2018)
- **URL**: <https://en.wikipedia.org/wiki/Jenkins_(software)>, <https://en.wikipedia.org/wiki/Kohsuke_Kawaguchi>
- **注意事項**: KawaguchiはInfraDNAを2010年4月に設立し、CloudBeesと合併（2010年11月）
- **記事での表現**: 「2005年、Sun MicrosystemsのKohsuke KawaguchiがHudsonを公開した。OracleによるSun買収後の商標争いを経て、2011年にコミュニティ投票でJenkinsに改名された」

## 3. Travis CI

- **結論**: Travis CIは2011年にベルリンで設立。GitHubと統合した最初のホステッドCIサービスの一つ。OSSプロジェクトに無償でCIサービスを提供した最初のCIサービス（2020年12月に無償提供を終了）。2019年にIdera, Inc.に買収
- **一次ソース**: Wikipedia "Travis CI", Travis CI公式サイト
- **URL**: <https://en.wikipedia.org/wiki/Travis_CI>, <https://www.travis-ci.com/about-us/>
- **注意事項**: GitHubとの密結合が特徴。.travis.ymlによる設定をリポジトリのルートに配置する方式を普及させた
- **記事での表現**: 「2011年、Travis CIがベルリンで設立された。GitHubリポジトリと統合し、OSSプロジェクトに無償でCIサービスを提供した最初のサービスだった」

## 4. AWS CloudFormation

- **結論**: AWS CloudFormationは2011年2月25日にリリース。ローンチ時点で15のAWSサービスのうち13をサポートし、48のリソースタイプに対応。最初のクラウドベンダーによるIaCサービス。JSON（後にYAML）でインフラを宣言的に定義
- **一次ソース**: AWS公式ブログ, Wikipedia "AWS CloudFormation"
- **URL**: <https://en.wikipedia.org/wiki/AWS_CloudFormation>
- **注意事項**: Mitchell Hashimotoは翌日にブログを投稿し、クラウド非依存版の必要性を指摘（後のTerraformにつながる）
- **記事での表現**: 「2011年2月、AWSがCloudFormationをリリースした。クラウドベンダーとして初のIaCサービスであり、JSON形式でインフラを宣言的に定義する仕組みだった」

## 5. Terraform

- **結論**: HashiCorpは2012年にMitchell HashimotoとArmon Dadgarが設立。Terraform 0.1は2014年7月にリリース。初期はAWSとDigitalOceanのみサポート。最初の18か月はダウンロードがほぼ停滞。2016年末には750人以上のコントリビューターとAzure、GCP、OpenStack等のプロバイダに対応。HCL（HashiCorp Configuration Language）による宣言的定義
- **一次ソース**: HashiCorp公式 "The Story of HashiCorp Terraform", Wikipedia "Terraform (software)", Wikipedia "HashiCorp"
- **URL**: <https://www.hashicorp.com/en/resources/the-story-of-hashicorp-terraform-with-mitchell-hashimoto>, <https://en.wikipedia.org/wiki/Terraform_(software)>
- **注意事項**: Hashimotoは2011年のCloudFormationリリース翌日にブログ投稿し、クラウド非依存ソリューションの必要性を指摘
- **記事での表現**: 「2014年7月、HashiCorpがTerraform 0.1をリリースした。CloudFormationの思想をクラウド非依存で実現するツールだった」

## 6. IaC（Infrastructure as Code）の歴史——構成管理ツール

- **結論**: CFEngine（1993年、Mark Burgess）が収束原理を導入。Puppet（2005年リリース）が宣言的マニフェストを普及。Chef（2009年リリース）が命令型モデルを採用。Ansible（2012年、Michael DeHaanが開発）がエージェントレス・YAML定義で簡素化。Red HatがAnsibleを2015年10月に1.5億ドルで買収
- **一次ソース**: 各ツールのWikipedia記事、The New Stack "A Brief DevOps History"
- **URL**: <https://thenewstack.io/a-brief-devops-history-the-roots-of-infrastructure-as-code/>
- **注意事項**: 構成管理（Puppet/Chef/Ansible）とインフラプロビジョニング（Terraform/CloudFormation）は異なるレイヤーだが、総称してIaCと呼ばれることがある
- **記事での表現**: 「2005年のPuppet、2009年のChef、2012年のAnsible——構成管理ツールの進化は、インフラを『コードで定義する』文化を段階的に根付かせた」

## 7. GitOps——概念の誕生

- **結論**: 2017年3月2日、WeaveworksのCEO Alexis RichardsonがブログでGitOpsという用語を初めて使用。Weaveworksチームが「Kubernetesを本番環境で信頼性高く大規模に運用するための方法論」として発見・命名。2018年にWeaveworksが「Guide to GitOps」を公開し、CIやIaCとの違いを解説。GitOpsは「Kubernetesのための運用モデル」と再定義
- **一次ソース**: Alexis Richardson, "GitOps - Operations by Pull Request", Weaveworks Blog, 2017-03-02; Schlomo Schapiro, "How did GitOps get started? An interview with Alexis Richardson", 2021
- **URL**: <https://medium.com/weaveworks/what-is-gitops-really-e77329f23416>, <https://schlomo.schapiro.org/2021/02/gitops-interview-alexis-richardson.html>
- **注意事項**: GitOpsの4原則: (1) 宣言的、(2) バージョン管理・イミュータブル、(3) 自動Pull、(4) 継続的リコンシリエーション
- **記事での表現**: 「2017年3月、WeaveworksのAlexis RichardsonがGitOpsという用語をブログで発表した」

## 8. Flux CD

- **結論**: FluxはWeaveworksが2016年に開発しオープンソース化。2019年にCNCFサンドボックスプロジェクトとして採択。2020年4月にFlux v2の再設計を決定（Kubernetesコントローラーランタイムとカスタムリソース定義を活用）。2021年にFlux v2リリース。2022年11月にCNCF Graduatedステータスを達成
- **一次ソース**: Flux公式サイト, CNCF, BusinessWire, Weaveworks Blog
- **URL**: <https://fluxcd.io/>, <https://v2-0.docs.fluxcd.io/blog/2022/11/flux-is-a-cncf-graduated-project/>
- **注意事項**: Weaveworks閉鎖後もCNCFプロジェクトとして継続
- **記事での表現**: 「WeaveworksがGitOpsの実装として2016年に公開したFluxは、2022年にCNCF Graduatedステータスを達成した」

## 9. ArgoCD

- **結論**: ArgoCDはIntuitが社内プロジェクトとして開発し、2018年1月にオープンソース化。Applatixの買収（2018年）が背景にある。2019年にCNCFインキュベーティングプロジェクトとして採択。2022年にGraduated。Kubernetesコントローラーとして実装され、Gitリポジトリで定義された望ましい状態とクラスタの実状態を継続的に監視・同期
- **一次ソース**: Red Hat Blog, Intuit Blog, Argo CD公式ドキュメント
- **URL**: <https://argo-cd.readthedocs.io/en/stable/>, <https://www.intuit.com/blog/news-social/cloud-native-computing-foundation-accepts-argo-as-an-incubator-project/>
- **注意事項**: Electronic Arts、MLB、Tesla、Ticketmasterなどが本番環境で使用
- **記事での表現**: 「2018年、IntuitがArgoCDをオープンソース化した。Kubernetesコントローラーとして、Gitの宣言的状態とクラスタの実状態を継続的に同期する」

## 10. Weaveworksの閉鎖

- **結論**: 2024年2月にWeaveworksが事業を停止。CEO Alexis RichardsonがLinkedInで発表。2014年設立、総額6,100万ドル以上の資金調達（最終ラウンドは2020年の3,600万ドル）。2022年の経済低迷と追加投資の不在が原因。GitOpsの概念を提唱し、Flux（CNCF Graduated）を開発した企業として知られる。Richardson氏はFluxの継続を保証
- **一次ソース**: Alexis Richardson LinkedIn投稿 (2024-02-05), The New Stack, TechCrunch, The Register
- **URL**: <https://thenewstack.io/end-of-an-era-weaveworks-closes-shop-amid-cloud-native-turbulence/>, <https://techcrunch.com/2024/02/05/cloud-native-container-management-platform-weaveworks-shuts-its-doors/>
- **注意事項**: GitOpsの提唱者が閉鎖したが、概念とツール（Flux）はCNCFの下で存続。GitOpsが特定企業に依存しないオープンな概念であることの証左ともいえる
- **記事での表現**: 「2024年2月、GitOpsの提唱者であるWeaveworksが事業を停止した。しかしFluxはCNCFの下で存続している。概念がその提唱者を超えて生き続けるという、オープンソースの本質を体現している」

## AWS CDK（補足）

- **結論**: AWS CDK（Cloud Development Kit）は2019年7月11日にGA（一般提供）。TypeScriptとPythonを初期サポート。2019年11月25日にJavaとC#のサポートを追加。2021年にCDK v2がリリース。汎用プログラミング言語でインフラを定義する「コードファースト」アプローチ
- **一次ソース**: Wikipedia "AWS Cloud Development Kit", AWS公式ブログ
- **URL**: <https://en.wikipedia.org/wiki/AWS_Cloud_Development_Kit>
- **注意事項**: CloudFormation（YAML/JSON）の上位レイヤーとして動作
- **記事での表現**: 「2019年にGAとなったAWS CDKは、TypeScriptやPythonでインフラを定義するコードファーストアプローチを実現した」
