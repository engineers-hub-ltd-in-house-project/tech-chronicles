# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第22回：マルチクラウドの現実——理想と実務のギャップ

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- マルチクラウドの4つのパターン——ワークロード分散、障害回避、ベストオブブリード、ポータビリティ——の実態と使い分け
- HashiCorp Terraform（2014年7月）の誕生経緯と「クラウド抽象化」の設計思想
- Pulumi（2018年6月）、Crossplane（2018年末）が示したIaCの多様化
- 2019年のハイブリッド/マルチクラウド三国志——AWS Outposts、Azure Arc、Google Anthos の同時発表が意味するもの
- Kubernetes をポータビリティレイヤーとして使う場合の構造的限界
- 「最小公倍数問題」——クラウド抽象化が各クラウドの強みを殺すメカニズム
- HashiCorp BSLライセンス変更（2023年8月）と OpenTofu フォークが突きつけたマルチクラウドツールチェーンの脆弱性
- Flexera 2024年調査に見るマルチクラウドの実態——「意図的な戦略」と「結果的な状態」の乖離

---

## 1. 「ベンダーロックインを避ける」という呪文

2017年のある金曜日、私は経営会議に呼ばれた。議題は「クラウド戦略の見直し」だった。

当時、私が支援していたプロジェクトは AWS に全面的に依存していた。EC2、RDS、S3、Lambda、CloudFront——あらゆるマネージドサービスを使い倒していた。開発速度は速く、運用も安定していた。何の問題もない、と私は思っていた。

だが経営層の認識は違った。

「AWSに依存しすぎではないか。ベンダーロックインのリスクが高い。マルチクラウドに移行すべきだ」

この言葉を聞いたとき、私の中で二つの感情がせめぎ合った。一つは理解。確かにAWS一社に全インフラを委ねるリスクは存在する。AWSの料金改定、サービス廃止、障害——いずれも自社ではコントロールできない。もう一つは懸念。マルチクラウドの「コスト」を、この会議室にいる人々は正確に理解しているだろうか。

結論から言えば、私たちはマルチクラウドへの移行を決定した。Terraformで抽象化する方針を立てた。だがその後の1年間は、想像を遥かに超える困難の連続だった。

各クラウドのマネージドサービスの差異は、表面的なAPIの違いにとどまらなかった。RDSとCloud SQLでは、フェイルオーバーの挙動が異なる。S3とCloud Storageでは、一貫性モデルが異なっていた（S3が強整合性を達成したのは2020年12月だ）。VPCの設計思想がAWSとGCPで根本的に異なる。ネットワーク接続の複雑性、運用チームの学習コスト、そしてなにより「各クラウドの最も強力なマネージドサービスを使えない」という機会損失——これらが積み重なり、最終的なコストは当初見積もりの3倍近くに膨れ上がった。

この経験を通じて、私は一つの区別を学んだ。「マルチクラウド」と「マルチクラウドネイティブ」は別物だということだ。複数のクラウドを「使っている」ことと、複数のクラウドを「使いこなしている」ことの間には、深い溝がある。

なぜ「ベンダーロックインを避ける」という一見合理的な判断が、これほどの困難を生むのか。マルチクラウドの理想と現実のギャップは、どこから来るのか。その構造を、歴史と技術の両面から解き明かしていく。

---

## 2. クラウド抽象化の系譜——CloudFormation から OpenTofu まで

### 単一クラウドの時代：CloudFormation の誕生

マルチクラウドの歴史を語るには、まずクラウドインフラの「コード化」がどう始まったかを振り返る必要がある。

2011年2月25日、AWSはCloudFormationをリリースした。JSONフォーマットでAWSリソースを宣言的に定義し、スタックとして管理する。リリース時点で15サービス中13に対応、48のリソースタイプをサポートしていた。Infrastructure as Code（IaC）の概念を実用的な形で広めた先駆的サービスだ。

だが、CloudFormationには根本的な制約があった。AWSのためのツールであり、AWSでしか使えない。当たり前のことだが、これが後に大きな意味を持つ。2011年時点ではAWSが圧倒的な市場シェアを持ち、Azure（2010年GA）もGCP（2011年正式ローンチ）もまだ黎明期にあった。「クラウド＝AWS」という認識が多くの現場で共有されていた時代、CloudFormationがAWS専用であることは誰も問題視しなかった。

### Terraform の登場——「クラウド非依存」という理想

その状況を変えたのが、Mitchell Hashimotoだった。

2011年、CloudFormationの発表翌日、Hashimotoはブログ記事を投稿した。CloudFormationのアイデアに感銘を受けつつも、本当に必要なのはオープンソースでクラウド非依存の解決策だと主張した。この構想が形になるまでに3年かかった。

2014年7月28日、Terraform 0.1がリリースされた。HashiCorp——Hashimotoが2012年にArmon Dadgarとともに設立した会社——のプロダクトとして。初期のTerraformはAWSとDigitalOceanのみをサポートしていた。反響は控えめだった。最初の18ヶ月間、ダウンロード数はほぼ停滞し、チーム内ではプロジェクトの終了すら議論されたという。

だが、Terraformの設計思想は時代の流れを正確に捉えていた。HCL（HashiCorp Configuration Language）という独自の宣言型言語で、あらゆるクラウドのリソースを統一的に記述する。「Provider」というプラグインアーキテクチャにより、新しいクラウドやサービスへの対応を拡張できる。

```hcl
# Terraform の Provider アーキテクチャ
# 同じ言語（HCL）で異なるクラウドを記述できる

# AWS のリソース
provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.medium"
}

# GCP のリソース
provider "google" {
  project = "my-project"
  region  = "asia-northeast1"
}

resource "google_compute_instance" "web" {
  name         = "web-server"
  machine_type = "e2-medium"
  zone         = "asia-northeast1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
  }
}
```

このコードを見て、何に気づくだろうか。確かに同じHCLで書かれている。だが、`aws_instance`と`google_compute_instance`のリソース定義は全く異なる。AMI IDとイメージファミリー、VPCサブネットとネットワークインターフェース——抽象化されているのは「言語」であって「概念」ではない。この点は後で詳しく論じる。

2016年末までにTerraformは750人以上のコントリビューターを獲得し、Azure、GCP、OpenStackを含む数十のプロバイダーをサポートするに至った。マルチクラウドの「共通語」として急速に普及していった。

### IaCの多様化——Pulumi と Crossplane

Terraformの成功は、IaCの分野に新たな挑戦者を呼び込んだ。

2018年6月18日、Pulumiがローンチされた。創業者のJoe Duffy、Eric Rudder、Luke Hobanは、いずれもMicrosoftでの開発経験を持つエンジニアだった。Pulumiのアプローチは明確にTerraformと異なっていた。HCLのような独自言語ではなく、TypeScript、Python、Go、Javaといった汎用プログラミング言語でインフラを定義する。

```typescript
// Pulumi: TypeScript でインフラを定義
import * as aws from "@pulumi/aws";
import * as gcp from "@pulumi/gcp";

// AWS の EC2 インスタンス
const awsInstance = new aws.ec2.Instance("web", {
    ami: "ami-0abcdef1234567890",
    instanceType: "t3.medium",
});

// GCP の Compute Instance
const gcpInstance = new gcp.compute.Instance("web", {
    machineType: "e2-medium",
    zone: "asia-northeast1-a",
    bootDisk: {
        initializeParams: {
            image: "debian-cloud/debian-12",
        },
    },
    networkInterfaces: [{
        network: "default",
    }],
});
```

「インフラの記述に、なぜわざわざ新しい言語を学ばなければならないのか」——Pulumiの問いかけは鋭かった。条件分岐、ループ、型チェック、テスト、パッケージ管理——汎用言語のエコシステムをそのままインフラ定義に使える。だが同時に、「宣言的であること」の価値——コードを見れば最終状態がわかるという明快さ——とのトレードオフも存在した。

同じ2018年末、全く異なるアプローチが登場した。Upbound社が開発したCrossplaneだ。Crossplaneは、Kubernetesのカスタムリソース定義（CRD）を使ってクラウドリソースを管理する。つまり、Kubernetes自体をクラウドのコントロールプレーンとして使うのだ。

```yaml
# Crossplane: Kubernetes CRD でクラウドリソースを定義
apiVersion: database.aws.crossplane.io/v1beta1
kind: RDSInstance
metadata:
  name: my-database
spec:
  forProvider:
    region: ap-northeast-1
    dbInstanceClass: db.t3.medium
    engine: postgres
    engineVersion: "16"
    masterUsername: admin
  writeConnectionSecretToRef:
    name: db-credentials
    namespace: default
```

Terraform、Pulumi、Crossplane——この3つのアプローチは、マルチクラウド抽象化の3つの哲学を体現している。

```
マルチクラウドIaCの3つのアプローチ:

┌──────────────┬────────────────────┬──────────────────┬─────────────────┐
│              │ Terraform          │ Pulumi           │ Crossplane      │
├──────────────┼────────────────────┼──────────────────┼─────────────────┤
│ 言語         │ HCL（独自DSL）     │ 汎用言語         │ Kubernetes YAML │
│              │                    │ (TS/Python/Go等) │ (CRD)           │
├──────────────┼────────────────────┼──────────────────┼─────────────────┤
│ 抽象化の     │ 言語レベル         │ 言語レベル       │ APIレベル       │
│ レイヤー     │ （HCLで統一）      │ （型で統一）     │ （K8s APIで統一）│
├──────────────┼────────────────────┼──────────────────┼─────────────────┤
│ 状態管理     │ tfstate ファイル   │ Pulumi Service   │ Kubernetes      │
│              │ (S3/GCS等)         │ or self-managed  │ etcd            │
├──────────────┼────────────────────┼──────────────────┼─────────────────┤
│ リコンシ     │ plan → apply       │ preview → up     │ 継続的          │
│ リエーション │ （手動実行）       │ （手動実行）     │ （自動収束）    │
├──────────────┼────────────────────┼──────────────────┼─────────────────┤
│ マルチクラウド│ Provider切替       │ Provider切替     │ Provider切替    │
│ 対応方式     │ （同一HCL構文）    │ （同一言語）     │ （同一API体系） │
└──────────────┴────────────────────┴──────────────────┴─────────────────┘
```

いずれのアプローチも、根本的な問題は共有している。言語やAPIを統一しても、各クラウドのリソースモデルの差異は抽象化できない。EC2とCompute Engineは、同じ「仮想マシン」であっても、ネットワーキングモデル、ストレージの接続方式、メタデータサービスの仕様が異なる。この差異は、抽象化レイヤーの「下」に常に存在し続ける。

### Terraform のライセンス危機——OpenTofu という分岐点

マルチクラウドの歴史に、思いがけない衝撃が走ったのは2023年のことだった。

2023年8月10日、HashiCorpはTerraformを含む全製品のライセンスをMPL（Mozilla Public License）からBSL v1.1（Business Source License）に変更すると発表した。BSLは内部利用は無料だが、HashiCorpのTerraform CloudやEnterpriseと競合するサービスでの利用を制限する。

オープンソースコミュニティの反応は激烈だった。わずか5日後の8月15日、OpenTFマニフェストが公開され、ライセンス撤回を要求した。8月25日にはフォークの発表。そして9月20日、Linux FoundationがOpenTofuとしてプロジェクトを受け入れた。HashiCorpの発表からわずか41日間の出来事だ。

さらに2024年4月24日、IBMがHashiCorpを64億ドルで買収すると発表した。

この一連の出来事が突きつけた問いは、マルチクラウドの議論において極めて重要だ。「ベンダーロックインを避けるためにTerraformでクラウドを抽象化する」——だがそのTerraform自体がライセンス変更というリスクを持っていた。抽象化レイヤーへの依存は、クラウドベンダーへの依存とは異なるが、依存であることに変わりはない。ロックインの対象が「クラウドベンダー」から「IaCツールベンダー」に移っただけだと言えなくもない。

OpenTofuの誕生により、Terraformの互換フォークが利用可能になった。だがこれもまた、マルチクラウドのツールチェーンの断片化という新たな問題を生んでいる。

---

## 3. 2019年——ハイブリッド/マルチクラウド三国志

### 3大クラウドが同時に「外」へ出た年

2019年は、クラウドの歴史において転換点となった年だ。AWS、Microsoft、Googleの3大クラウドベンダーが、ほぼ同時期にハイブリッド/マルチクラウド戦略を打ち出した。

**AWS Outposts**——2018年11月のre:Invent 2018で発表、2019年12月にGA。AWSのハードウェアを顧客のデータセンターに設置し、AWSと同じAPIでオンプレミスのリソースを管理する。「クラウドに来い」と言い続けてきたAWSが、自ら顧客のデータセンターに「行く」という方針転換は、業界を驚かせた。

**Google Anthos**——2019年4月のCloud Nextで発表、即日GA。GKE（Google Kubernetes Engine）をベースに、オンプレミスだけでなくAWSやAzure上のワークロードも管理できるマルチクラウドプラットフォーム。100%ソフトウェアベースで、ハードウェアを選ばない点がOutpostsとの明確な差異だった。

**Azure Arc**——2019年11月のMicrosoft Igniteで、CEO Satya Nadellaが基調講演で発表。Azureの管理プレーンを任意のインフラ——オンプレミスはもちろん、AWSやGCP上のリソースさえも——に拡張するサービス。

```
2019年: ハイブリッド/マルチクラウド三国志

                     ┌─────────────────────┐
                     │  顧客のデータセンター │
                     │  (オンプレミス)       │
                     └──────┬──────────────┘
                            │
            ┌───────────────┼───────────────┐
            │               │               │
   ┌────────▼───────┐ ┌────▼────────┐ ┌────▼────────────┐
   │ AWS Outposts   │ │ Google      │ │ Azure Arc       │
   │                │ │ Anthos      │ │                 │
   │ 発表: 2018/11  │ │ 発表: 2019/4│ │ 発表: 2019/11   │
   │ GA:   2019/12  │ │ GA:  即日   │ │                 │
   ├────────────────┤ ├─────────────┤ ├─────────────────┤
   │ AWSハードウェア│ │ ソフトウェア│ │ ソフトウェア    │
   │ をオンプレに   │ │ ベース      │ │ ベース          │
   │ 設置           │ │ (GKE基盤)   │ │ (Azure管理      │
   │                │ │             │ │  プレーン拡張)  │
   ├────────────────┤ ├─────────────┤ ├─────────────────┤
   │ AWS API互換    │ │ K8s API     │ │ Azure API       │
   │                │ │ + 他クラウド│ │ + 他クラウド    │
   │                │ │   対応      │ │   対応          │
   └────────────────┘ └─────────────┘ └─────────────────┘

   方針: 自社HWで      方針: K8sで     方針: 管理
   オンプレ延伸        抽象化          プレーンで統一
```

3社のアプローチの違いは示唆的だ。

AWSは自社のハードウェアとソフトウェアスタックをそのまま顧客のデータセンターに持ち込んだ。「AWSのやり方」をオンプレミスに延伸する戦略であり、他クラウドとの共存は想定していない。AWSの自信と支配的ポジションの表れだ。

Googleは、Kubernetesという自社発のオープンソース技術をポータビリティレイヤーとして活用した。Kubernetes上であれば、AWS上でもAzure上でもオンプレミスでも同じように動く——という理想を掲げた。後発のGCPが市場シェアで勝てない以上、「場所を問わない」価値で差別化する戦略は合理的だった。

Microsoftは、Azure Arc で「管理プレーンの統一」に賭けた。リソースがどこにあろうと、Azureのコントロールプレーンから管理する。エンタープライズにおけるAzure ADとの統合、ガバナンスとコンプライアンスの一元管理という、Microsoft の強みを最大限に活用する戦略だ。

だが皮肉なことに、Google Anthosはその後の数年で名称変更を繰り返した。Google Distributed Cloud、そしてGKE Enterpriseへ。名前の変遷は、マルチクラウドプラットフォームのポジショニングの難しさを象徴している。

### 3社の思惑が示す構造的矛盾

3社が同時にハイブリッド/マルチクラウドに乗り出した事実は、二つのことを意味している。

第一に、顧客のニーズが無視できないレベルに達したこと。規制要件（データローカリゼーション）、レガシーシステムの移行困難性、そしてコスト構造の問題——全てをパブリッククラウドに載せることが現実的でないケースが増えていた。

第二に、しかし各社のアプローチは根本的に「自社のやり方を広げる」方向だったこと。AWSはAWSのAPIを、GoogleはKubernetesを、MicrosoftはAzureの管理プレーンを——各社が「自社の世界」を外に広げようとした。これは「ベンダーロックインの解消」ではなく、「ロックインの範囲の拡大」と言った方が正確だ。

---

## 4. マルチクラウドの4つのパターンとその現実

### パターンの分類

Flexeraの2024年調査によれば、組織は平均2.4のパブリッククラウドプロバイダーを利用している。だがこの数字には注意が必要だ。「意図的なマルチクラウド戦略」と「結果的に複数クラウドを使っている状態」は、全く異なるものだ。

マルチクラウドのパターンを整理すると、大きく4つに分類できる。

```
マルチクラウドの4つのパターン:

パターン1: ワークロード分散（最も一般的）
┌──────────────────┐    ┌──────────────────┐
│      AWS         │    │      GCP         │
│  基幹システム    │    │  データ分析/ML   │
│  (EC2, RDS)      │    │  (BigQuery, AI)  │
└──────────────────┘    └──────────────────┘
→ 各クラウドの強みを活かし、ワークロード単位で配置
→ クラウド間のデータ移動とレイテンシが課題

パターン2: 障害回避（DR/フェイルオーバー）
┌──────────────────┐    ┌──────────────────┐
│      AWS         │    │      Azure       │
│  プライマリ      │ →  │  DR環境          │
│  全サービス稼働  │    │  最小構成で待機  │
└──────────────────┘    └──────────────────┘
→ AWS障害時にAzureへフェイルオーバー
→ コストは二重だが、可用性を最大化
→ 実際の切替訓練をしないDR環境は「保険料だけ払う保険」

パターン3: ベストオブブリード
┌──────────┐ ┌──────────┐ ┌──────────┐
│  AWS     │ │  GCP     │ │  Azure   │
│  S3      │ │ BigQuery │ │  Azure AD│
│  Lambda  │ │ Vertex AI│ │  Teams連携│
└──────────┘ └──────────┘ └──────────┘
→ 各クラウドの「最強のサービス」を選んで組み合わせる
→ 統合の複雑性とデータ転送コストが急増する

パターン4: ポータビリティ（最も困難）
┌──────────────────────────────────────────┐
│         抽象化レイヤー                    │
│    (Terraform / Kubernetes / Crossplane)  │
├──────────────┬───────────────────────────┤
│      AWS     │          GCP              │
│  同じワーク  │  同じワークロードを       │
│  ロードを実行│  実行可能                 │
└──────────────┴───────────────────────────┘
→ 同じワークロードを複数クラウドで実行可能にする
→ 「最小公倍数問題」により、各クラウドの強みを放棄
```

Flexeraの2024年調査では、57%の組織が「異なるクラウドにアプリケーションがサイロ化している」と回答し、49%が「クラウド間のDR/フェイルオーバー」を実装していると回答した。つまり、最も多いのはパターン1（ワークロード分散）であり、パターン4（ポータビリティ）を実現している組織は少数派だ。

### 最小公倍数問題——抽象化が殺すもの

パターン4のポータビリティを追求したとき、必ず直面するのが「最小公倍数問題」（Lowest Common Denominator Problem）だ。

各クラウドが提供する機能の「共通部分」だけを使うことで、ポータビリティを実現する。だがその「共通部分」は、各クラウドの最も強力な機能を含まない。

具体例を挙げよう。

AWSのDynamoDBは、ミリ秒単位のレイテンシでペタバイト規模のデータを処理できるフルマネージドNoSQLデータベースだ。グローバルテーブル、DynamoDB Streams、オンデマンドキャパシティ——いずれもDynamoDB固有の機能であり、他のクラウドに直接対応するものはない。

「ポータビリティのために」DynamoDBの代わりに、クラウド非依存のMongoDBを自前で運用する選択をしたとしよう。フルマネージドの運用負荷ゼロ、自動スケーリング、サーバーレス課金——DynamoDBが提供するこれらの価値を、すべて放棄することになる。代わりに得られるのは「理論上の」ポータビリティだ。

```
最小公倍数問題の構造:

AWS固有の強み        GCP固有の強み       Azure固有の強み
┌─────────────┐    ┌──────────────┐    ┌──────────────┐
│ DynamoDB    │    │ BigQuery     │    │ Azure AD     │
│ Aurora      │    │ Spanner      │    │ Cosmos DB    │
│ Lambda@Edge │    │ Vertex AI    │    │ Azure DevOps │
│ SQS/SNS     │    │ Pub/Sub      │    │ Service Bus  │
│ CloudFront  │    │ Cloud CDN    │    │ Front Door   │
└──────┬──────┘    └──────┬───────┘    └──────┬───────┘
       │                  │                    │
       └──────────┬───────┴────────────────────┘
                  │
                  ▼
        ┌─────────────────┐
        │   共通部分       │
        │  (最小公倍数)    │
        │                 │
        │ ・仮想マシン     │
        │ ・ブロック       │
        │   ストレージ    │
        │ ・VPC/ネット     │
        │   ワーク        │
        │ ・ロード         │
        │   バランサー    │
        └─────────────────┘

  上の「共通部分」だけを使うと
  各クラウドの最も強力な
  マネージドサービスを放棄する
  = コモディティ製品しか使えない
```

CIO.comが「マルチクラウドの11のダークシークレット」として指摘したように、「複数のクラウドで同じワークロードを実行することは、すべてを最小公倍数に合わせることを意味し、コモディティ製品を提供する可能性を高める」のだ。

AWSのソリューションアーキテクトが自社ブログで率直に述べているように、マルチクラウドの「ベストオブブリード」を追求するなら各クラウドの固有サービスを使わざるを得ず、「ポータビリティ」を追求するなら各クラウドの固有サービスを諦めなければならない。この二つの目標は構造的に矛盾している。

### Kubernetesはポータビリティの銀の弾丸か

「Kubernetesを使えばマルチクラウドのポータビリティは解決する」——この主張は、2019年のAnthos発表以降、繰り返し聞かれるようになった。だが実態はどうか。

McKinsey Digitalの分析は、「Kubernetesは本当にマルチクラウドのポータビリティを提供するか」という問いに対して、慎重な結論を出している。Kubernetesが抽象化するのはコンピュートレイヤーだ。コンテナのデプロイ、スケーリング、サービスディスカバリ——これらはKubernetesのAPIで統一的に扱える。

だがアプリケーションはコンピュートだけでは動かない。

**ストレージ**。PersistentVolumeをリクエストすると、AWS上ではEBS、GCP上ではPersistent Diskが割り当てられる。ボリュームのスナップショット、暗号化、パフォーマンス特性はクラウドごとに異なり、データの移行は自明ではない。

**ネットワーク**。KubernetesのServiceにtype: LoadBalancerを指定すると、AWS上ではELB/ALB、GCP上ではCloud Load Balancingが作成される。ロードバランサーの挙動、SSL証明書の管理、WAFの統合はクラウドごとに異なる。

**マネージドサービス**。RDSやCloud SQLをPodから使う場合、接続文字列、認証方式（IAM認証 vs Cloud SQL Proxy）、フェイルオーバーの挙動がクラウドごとに異なる。

**ID/アクセス管理**。AWS IAMロールによるPodのサービスアカウント連携（IRSA）と、GCPのWorkload Identity Federationは、全く異なる設定を必要とする。

```
Kubernetes のポータビリティの現実:

     ┌─────────────────────────────────────────┐
     │        アプリケーション                   │
     ├─────────────────────────────────────────┤
     │  Kubernetes API （ポータブル）            │
     │  ├─ Deployment, Service, ConfigMap      │
     │  ├─ Pod スケジューリング                 │
     │  └─ コンテナライフサイクル管理           │
     ├─────────────────────────────────────────┤
     │  クラウド固有レイヤー（非ポータブル）     │
     │  ├─ ストレージ (EBS vs PD vs Managed    │
     │  │   Disk)                              │
     │  ├─ ロードバランサー (ALB vs Cloud LB   │
     │  │   vs Azure LB)                       │
     │  ├─ DNS (Route 53 vs Cloud DNS vs       │
     │  │   Azure DNS)                         │
     │  ├─ 認証/認可 (IRSA vs Workload         │
     │  │   Identity vs AAD Pod Identity)      │
     │  ├─ マネージドDB (RDS vs Cloud SQL      │
     │  │   vs Azure SQL)                      │
     │  ├─ シークレット管理 (Secrets Manager   │
     │  │   vs Secret Manager vs Key Vault)    │
     │  └─ モニタリング (CloudWatch vs Cloud   │
     │      Monitoring vs Azure Monitor)       │
     └─────────────────────────────────────────┘

  Kubernetes がポータブルなのは上半分だけ。
  アプリケーションが実際に依存する下半分は
  クラウド固有のまま。
```

真のポータビリティを達成するには、下半分のクラウド固有レイヤーもすべて抽象化するか、あるいはクラウド固有サービスを一切使わず自前で構築するか、いずれかの道を選ぶ必要がある。前者はCrossplaneのようなツールが目指す方向だが、抽象化レイヤーの複雑性と運用コストが加わる。後者は最小公倍数問題そのものであり、各クラウドの強みを放棄する。

私の経験では、Kubernetesのポータビリティが真に活きるのは、ステートレスなコンピュートワークロード——つまり、外部依存が少なく、コンテナ内で完結するバッチ処理やAPIサーバー——に限られる。そしてそれはアプリケーション全体のほんの一部にすぎない。

---

## 5. マルチクラウドの隠れたコスト

### 金銭的コスト

マルチクラウドのコストは、前回（第21回）で論じたFinOpsの視点から見ると極めて深刻だ。

**抽象化ツールのライセンスと運用コスト**。Terraform Cloud/Enterprise、Pulumi Cloud、Crossplaneの運用——抽象化レイヤーの導入と維持には、ツールのライセンス費用、インフラ費用、人件費が発生する。

**クラウド間データ転送コスト**。これが最大の罠だ。クラウドベンダーは、データの「入口」（ingress）は無料にするが、「出口」（egress）に課金する。AWS、GCP、Azure間でデータを移動するたびに、egress料金が発生する。マルチクラウドアーキテクチャでは、クラウド間のデータフローが必然的に増える。

```
データ転送コストの非対称性:

インターネット → AWS:  $0.00/GB  (ingress は無料)
AWS → インターネット:  $0.09/GB  (egress は有料)
AWS → GCP:           $0.09/GB  (クラウド間は高い)
同一リージョン内:      $0.01/GB  (AZ間)

月間 10TB のクラウド間データ転送:
  10,000 GB × $0.09 = $900/月 = $10,800/年

これはデータ転送だけのコスト。
コンピュートもストレージも別途発生する。
```

**重複するマネージドサービスのコスト**。DRのためにAWSとAzureの両方にRDBMSを維持する場合、データベースの費用が二重になる。しかもスタンバイ側のリソースは、平常時には価値を生まない。

### 人的コスト——最も見落とされる変数

私が経験した中で最も過小評価されていたのが、人的コストだ。

AWSに精通したエンジニアが、そのままGCPを同レベルで運用できるわけではない。VPCのサブネット設計、IAMのポリシーモデル、ロギングとモニタリングのアーキテクチャ——これらはクラウドごとに根本的に設計思想が異なる。

AWSのVPCは、サブネットがアベイラビリティゾーンに紐づく。GCPのVPCはグローバルであり、サブネットはリージョンに紐づく。この違いは、ネットワーク設計のメンタルモデルそのものが異なることを意味する。AWSで培った「常識」が、GCPでは通用しない場面が多々ある。

```
AWS と GCP のVPC設計思想の違い:

AWS:                              GCP:
┌─ VPC (10.0.0.0/16) ──────┐    ┌─ VPC (グローバル) ────────┐
│                           │    │                           │
│  ┌─ AZ-a ──────────────┐ │    │  ┌─ asia-northeast1 ───┐ │
│  │ Subnet-1            │ │    │  │ Subnet-1            │ │
│  │ 10.0.1.0/24         │ │    │  │ 10.0.1.0/24         │ │
│  └─────────────────────┘ │    │  │ (全AZにまたがる)     │ │
│                           │    │  └─────────────────────┘ │
│  ┌─ AZ-c ──────────────┐ │    │                           │
│  │ Subnet-2            │ │    │  ┌─ us-central1 ────────┐ │
│  │ 10.0.2.0/24         │ │    │  │ Subnet-2            │ │
│  └─────────────────────┘ │    │  │ 10.0.2.0/24         │ │
│                           │    │  │ (全AZにまたがる)     │ │
│  サブネット = AZ単位      │    │  └─────────────────────┘ │
│  VPC = リージョン単位     │    │                           │
│                           │    │  サブネット = リージョン  │
└───────────────────────────┘    │              単位         │
                                 │  VPC = グローバル         │
                                 └───────────────────────────┘

同じ「VPC」「サブネット」という用語を使いながら、
設計思想が根本的に異なる。
```

マルチクラウドを運用する組織は、各クラウドの専門家をそれぞれ確保するか、あるいは全クラウドに精通したジェネラリストを育成するか、いずれかを選ばなければならない。前者は人件費が膨らみ、後者は各クラウドの深い知識が犠牲になる。いずれにしても、単一クラウドの運用と比較して大幅な人的投資が必要だ。

### 認知的コスト——複雑性の税金

マルチクラウド環境では、障害対応の複雑性が指数関数的に増大する。

「アプリケーションが遅い」——単一クラウドなら、CloudWatchでメトリクスを確認し、X-Rayでトレースを追い、VPCフローログでネットワークを確認する。一つのエコシステム内で完結する。

マルチクラウドでは、まず「どのクラウドのどのコンポーネントに問題があるのか」の切り分けから始まる。AWS上のAPIサーバーがGCP上のBigQueryに問い合わせ、結果をAzure上のCosmos DBに書き込む——こんなアーキテクチャでは、障害の原因特定だけで半日を費やすことも珍しくない。モニタリングツールの統合、ログの集約、分散トレーシングの横断——いずれも単一クラウドなら不要だった作業が、マルチクラウドでは必須になる。

私はこれを「複雑性の税金」と呼んでいる。マルチクラウドを選択した瞬間から、あらゆる運用タスクにこの税金がかかり続ける。

---

## 6. ハンズオン：Terraform でマルチクラウドの現実を体験する

ここまでの議論を実感するために、Terraformを使ってAWSとGCPに同じ構成をデプロイするハンズオンを行う。目的は「何が抽象化でき、何ができないか」を手を動かして確認することだ。

### 演習1：同じ「Webサーバー + データベース」をAWSとGCPで定義する

```bash
#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-22"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=========================================="
echo "演習1: マルチクラウドTerraform構成の比較"
echo "=========================================="

# --- AWS 構成 ---
mkdir -p aws-web

cat > aws-web/main.tf << 'TF_EOF'
# AWS: Web サーバー + RDS PostgreSQL
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "multicloud-demo"
  }
}

# AWS では サブネットは AZ に紐づく
resource "aws_subnet" "web_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "web-subnet-a"
  }
}

resource "aws_subnet" "web_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "web-subnet-c"
  }
}

# --- EC2 インスタンス ---
resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.web_a.id

  tags = {
    Name = "web-server"
  }
}

# --- RDS PostgreSQL ---
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet"
  subnet_ids = [aws_subnet.web_a.id, aws_subnet.web_c.id]
}

resource "aws_db_instance" "main" {
  identifier          = "demo-db"
  engine              = "postgres"
  engine_version      = "16.1"
  instance_class      = "db.t3.medium"
  allocated_storage   = 20
  db_name             = "appdb"
  username            = "admin"
  password            = "change-me-in-production"
  skip_final_snapshot = true

  db_subnet_group_name = aws_db_subnet_group.main.name

  # AWS 固有: IAM 認証の有効化
  iam_database_authentication_enabled = true

  tags = {
    Name = "demo-database"
  }
}

# --- セキュリティグループ ---
resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
TF_EOF

echo "AWS 構成を作成しました: aws-web/main.tf"

# --- GCP 構成 ---
mkdir -p gcp-web

cat > gcp-web/main.tf << 'TF_EOF'
# GCP: Web サーバー + Cloud SQL PostgreSQL
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "my-project-id"
  region  = "asia-northeast1"
}

# --- VPC ---
# GCP の VPC はグローバル（リージョンをまたぐ）
resource "google_compute_network" "main" {
  name                    = "multicloud-demo"
  auto_create_subnetworks = false
}

# GCP では サブネットはリージョンに紐づく（全AZにまたがる）
resource "google_compute_subnetwork" "web" {
  name          = "web-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "asia-northeast1"
  network       = google_compute_network.main.id

  # GCP 固有: Private Google Access
  private_ip_google_access = true
}

# --- Compute Engine インスタンス ---
resource "google_compute_instance" "web" {
  name         = "web-server"
  machine_type = "e2-medium"
  zone         = "asia-northeast1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.web.id

    access_config {
      # Ephemeral public IP
    }
  }

  # GCP 固有: メタデータでSSH鍵を管理
  metadata = {
    enable-oslogin = "true"
  }
}

# --- Cloud SQL PostgreSQL ---
resource "google_sql_database_instance" "main" {
  name             = "demo-db"
  database_version = "POSTGRES_16"
  region           = "asia-northeast1"

  settings {
    tier = "db-custom-2-7680"  # GCP 固有: カスタムマシンタイプ

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id

      # GCP 固有: Private Service Access が必要
    }

    backup_configuration {
      enabled    = true
      start_time = "02:00"
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "appdb" {
  name     = "appdb"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "admin" {
  name     = "admin"
  instance = google_sql_database_instance.main.name
  password = "change-me-in-production"
}

# --- ファイアウォールルール ---
# GCP 固有: ファイアウォールはVPCレベル（AWSはSGがインスタンスレベル）
resource "google_compute_firewall" "web" {
  name    = "allow-http"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}
TF_EOF

echo "GCP 構成を作成しました: gcp-web/main.tf"
```

### 演習2：差異の分析——何が「同じ」で何が「違う」か

```bash
echo "=========================================="
echo "演習2: AWS vs GCP 差異分析"
echo "=========================================="

cat > "${WORKDIR}/analysis.md" << 'MD_EOF'
# マルチクラウド差異分析: AWS vs GCP

## 1. ネットワーク設計の差異

| 項目           | AWS                          | GCP                           |
|----------------|------------------------------|-------------------------------|
| VPC スコープ   | リージョン単位               | グローバル                    |
| サブネット     | AZ に紐づく                  | リージョンに紐づく（全AZ）   |
| ファイアウォール| Security Group (インスタンス) | Firewall Rule (VPC)          |
| 公開IP         | Elastic IP (明示的)          | Ephemeral/Static (access_config) |
| DNS            | Route 53 (別サービス)        | Cloud DNS (別サービス)        |

→ 「同じ HCL で書ける」が、概念モデルが異なるため
  ネットワーク設計のアプローチが根本的に変わる

## 2. データベースサービスの差異

| 項目           | AWS RDS                      | GCP Cloud SQL                 |
|----------------|------------------------------|-------------------------------|
| インスタンス   | db.t3.medium (定義済みサイズ) | db-custom-2-7680 (カスタム)  |
| 認証           | IAM DB Authentication        | Cloud SQL Proxy + IAM        |
| プライベート接続| VPC内サブネットグループ      | Private Service Access       |
| フェイルオーバー| Multi-AZ (自動)              | HA構成 (リージョナル)        |
| バックアップ   | 自動 (保持期間指定)          | 手動 + 自動 (時刻指定)       |

→ 「PostgreSQL 16」という同じエンジンを使っても、
  接続方式、認証、HA構成が全く異なる

## 3. 抽象化可能な部分と不可能な部分

### 抽象化できる部分（Terraform の恩恵）:
- 宣言的な構成定義 → 同じ HCL 言語で記述
- 状態管理 → tfstate で統一的に管理
- 変更計画 → plan で差分を事前確認
- プロバイダーの切替 → provider ブロックの変更

### 抽象化できない部分（マルチクラウドの壁）:
- リソースのプロパティ名と構造 → 完全に異なる
- ネットワークの概念モデル → VPC/サブネットの粒度が異なる
- 認証・認可の方式 → IAM モデルが根本的に異なる
- マネージドサービスの挙動 → フェイルオーバー、バックアップ等
- 料金モデル → 課金単位、ディスカウント体系が異なる
MD_EOF

echo "差異分析ドキュメントを作成しました: analysis.md"
echo ""
echo "=== 重要な学び ==="
echo ""
echo "1. Terraform は「言語」を統一するが「概念」は統一しない"
echo "   AWSとGCPで同じ「VPC」でもモデルが異なる"
echo ""
echo "2. データベースの「PostgreSQL 16」は同じでも"
echo "   接続方式・認証・HA構成はクラウド固有"
echo ""
echo "3. 真のポータビリティには Terraform コードの書き換えが必要"
echo "   provider を変えるだけでは動かない"
echo ""
echo "4. マルチクラウドの「コスト」はインフラ費用だけではない"
echo "   設計・学習・運用の人的コストが最大の変数"
```

### 演習3：マルチクラウド判断マトリクスの作成

```bash
echo "=========================================="
echo "演習3: マルチクラウド判断マトリクス"
echo "=========================================="

cat > "${WORKDIR}/decision-matrix.md" << 'MD_EOF'
# マルチクラウド判断マトリクス

## あなたの組織はマルチクラウドが本当に必要か？

### 判断基準チェックリスト

各項目を 1（低い）〜 5（高い）で評価する。

| #  | 判断基準                                 | スコア (1-5) | 備考 |
|----|------------------------------------------|:------------:|------|
| 1  | 規制要件でマルチクラウドが必要           |              |      |
| 2  | 単一クラウドの障害が致命的な影響を与える |              |      |
| 3  | 特定クラウドの固有サービスへの依存が少ない|              |      |
| 4  | 複数クラウドの専門家を確保できる         |              |      |
| 5  | クラウド間のデータ転送量が少ない         |              |      |
| 6  | マルチクラウドの運用コスト増を許容できる |              |      |
| 7  | 現在のクラウドベンダーとの交渉力が不十分 |              |      |
| 8  | 特定のワークロードに最適なクラウドが異なる|              |      |

### スコアの解釈

- **合計 32-40**: マルチクラウドの強い正当性がある。計画的に進める価値がある
- **合計 24-31**: 部分的なマルチクラウド（パターン1 or 3）が適切
- **合計 16-23**: 単一クラウドの深い活用を優先すべき。DRのみ検討
- **合計 8-15**: マルチクラウドのコストが便益を大きく上回る可能性が高い

### よくある「間違った理由」でのマルチクラウド

1. **「ベンダーロックインが怖い」**
   → 抽象化レイヤーへの依存（Terraform BSL問題）は考慮したか？
   → ロックインの実際のコスト（移行費用）を試算したか？

2. **「競合させて値引きを引き出す」**
   → 複数クラウドの運用コスト増 > 値引き額 になっていないか？
   → EDP（Enterprise Discount Program）で十分ではないか？

3. **「みんなやっているから」**
   → 「平均2.4クラウド」は意図的な戦略 or 結果的な状態？
   → 自組織の具体的なニーズから判断しているか？

4. **「将来の選択肢を残したい」**
   → 「将来の選択肢」のために「今日の生産性」を犠牲にしていないか？
   → YAGNI（You Aren't Gonna Need It）原則は適用できないか？
MD_EOF

echo "判断マトリクスを作成しました: decision-matrix.md"
echo ""
echo "=== このマトリクスの使い方 ==="
echo ""
echo "1. チームで各項目をスコアリングする"
echo "2. スコアが低い場合、マルチクラウドの再考を推奨"
echo "3. スコアが高い場合、どのパターンが適切か検討"
echo "   - パターン1（ワークロード分散）が最も現実的"
echo "   - パターン4（ポータビリティ）は最もコストが高い"
```

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/22-multicloud-reality/` に用意してある。

---

## 7. まとめと次回予告

### この回のまとめ

第22回では、マルチクラウドの理想と現実のギャップを、歴史的経緯と技術的構造の両面から論じた。

**クラウド抽象化の系譜は、CloudFormation（2011年）の単一クラウドIaCから始まった。** 2014年7月にMitchell HashimotoがTerraform 0.1をリリースし、「クラウド非依存」のIaCという理想が形になった。2018年にはPulumi（汎用言語アプローチ）とCrossplane（Kubernetes APIアプローチ）が登場し、抽象化の選択肢が多様化した。だが2023年8月、HashiCorpのBSLライセンス変更とOpenTofuフォークは、抽象化レイヤー自体がリスクを持つことを突きつけた。ベンダーロックインを避けるために導入したツールが、新たな依存先になる——この構造的皮肉は、マルチクラウドの議論において忘れてはならない。

**2019年、AWS Outposts、Google Anthos、Azure Arcが同時に登場した。** 3大クラウドが同時にハイブリッド/マルチクラウド戦略を打ち出した事実は、顧客ニーズの切実さを証明している。だが各社のアプローチは「自社の世界を外に広げる」方向であり、これはロックインの解消ではなく、ロックインの範囲の拡大だった。

**マルチクラウドには4つのパターンがある——ワークロード分散、障害回避、ベストオブブリード、ポータビリティ。** 最も一般的なのはワークロード分散（パターン1）であり、最も困難なのはポータビリティ（パターン4）だ。パターン4を追求すると「最小公倍数問題」に直面する——各クラウドの最も強力なマネージドサービスを放棄し、共通部分のコモディティ機能だけを使うことになる。Kubernetesはコンピュートレイヤーの抽象化を提供するが、ストレージ、ネットワーク、認証、マネージドサービスはクラウド固有のままであり、ポータビリティの約束はアプリケーションのごく一部にしか及ばない。

**マルチクラウドの隠れたコストは金銭だけではない。** 複数クラウドの専門家の確保、ネットワーク設計のメンタルモデルの切替、障害対応の複雑性——これらの人的・認知的コストは、事前の見積もりで最も過小評価される変数だ。

冒頭の問いに答えよう。「特定のクラウドに依存しない」という理想は、技術的には実現可能だが、そのコストは多くの組織にとって便益を上回る。マルチクラウドは手段であって目的ではない。「何のためにマルチクラウドにするのか」——この問いへの明確な答えがなければ、複雑性というコストだけが残る。ベンダーロックインの恐怖よりも、「この特定のクラウドを使い倒す」という判断の方が、多くの場合において合理的だ。ただし、その判断は定期的に見直されるべきであり、移行の選択肢を完全に閉ざすべきでもない。重要なのは、ロックインのリスクを「定量的に」評価し、マルチクラウドのコストと比較した上で、情報に基づいた意思決定を行うことだ。

### 次回予告

第23回では、「オンプレミス回帰——クラウドの限界とハイブリッドの現実」を取り上げる。

DHH（37signals）の「クラウドからの離脱」宣言は、クラウド業界に衝撃を与えた。Dropboxは2016年に「Magic Pocket」プロジェクトでクラウドからオンプレミスに移行し、年間数千万ドルのコスト削減を実現した。GPU/AI基盤のクラウド需要が爆発する一方で、安定したワークロードのオンプレミス回帰が進む——この一見矛盾する動きの背後にある構造を、次回で読み解く。クラウドとオンプレミスの選択は、二者択一ではない。ハイブリッドの「現実的な」設計とは何か。前回のFinOpsの視点と、今回のマルチクラウドの知見を踏まえて論じる。

---

## 参考文献

- HashiCorp, "The Story of HashiCorp Terraform with Mitchell Hashimoto". <https://www.hashicorp.com/en/resources/the-story-of-hashicorp-terraform-with-mitchell-hashimoto>
- AWS, "Introducing AWS CloudFormation", February 25, 2011. <https://aws.amazon.com/about-aws/whats-new/2011/02/25/introducing-aws-cloudformation/>
- Pulumi, "Pulumi Launches Cloud Development Platform", June 18, 2018. <https://info.pulumi.com/press-release/pulumi-launches-cloud-development-platform-to-help-teams-get-code-to-the-cloud-faster>
- InfoQ, "Upbound Release Preview of 'Crossplane', a Universal Control Plane API for Cloud Computing", January 2019. <https://www.infoq.com/news/2019/01/upbound-crossplane/>
- Amazon Press Center, "Amazon Web Services Announces AWS Outposts", November 2018. <https://press.aboutamazon.com/2018/11/amazon-web-services-announces-aws-outposts>
- Amazon Press Center, "AWS Announces General Availability of AWS Outposts", December 2019. <https://press.aboutamazon.com/2019/12/aws-announces-general-availability-of-aws-outposts>
- TechCrunch, "The 7 most important announcements from Microsoft Ignite", November 2019. <https://techcrunch.com/2019/11/04/the-7-most-important-announcements-from-microsoft-ignite/>
- InfoQ, "Google Releases Anthos, a Hybrid Cloud Platform, to General Availability", April 2019. <https://www.infoq.com/news/2019/04/gcp-anthos-ga/>
- Google Cloud Blog, "Making hybrid- and multi-cloud computing a reality". <https://cloud.google.com/blog/topics/hybrid-cloud/new-platform-for-managing-applications-in-todays-multi-cloud-world>
- HashiCorp, "HashiCorp adopts Business Source License", August 10, 2023. <https://www.hashicorp.com/en/blog/hashicorp-adopts-business-source-license>
- Linux Foundation, "Linux Foundation Launches OpenTofu", September 20, 2023. <https://www.linuxfoundation.org/press/announcing-opentofu>
- TechCrunch, "Terraform fork gets renamed OpenTofu, and joins Linux Foundation", September 2023. <https://techcrunch.com/2023/09/20/terraform-fork-gets-a-new-name-opentofu-and-joins-linux-foundation/>
- Flexera, "2024 State of the Cloud Report". <https://www.flexera.com/blog/finops/cloud-computing-trends-flexera-2024-state-of-the-cloud-report/>
- Flexera, "2025 State of the Cloud Report". <https://www.flexera.com/blog/finops/the-latest-cloud-computing-trends-flexera-2025-state-of-the-cloud-report/>
- McKinsey Digital, "Does Kubernetes really give you multicloud portability?". <https://medium.com/digital-mckinsey/does-kubernetes-really-give-you-multicloud-portability-476270a0acc7>
- Diginomica, "Kubernetes and the misconception of multi-cloud portability". <https://diginomica.com/kubernetes-and-misconception-multi-cloud-portability>
- CIO.com, "11 dark secrets of multicloud". <https://www.cio.com/article/191692/11-dark-secrets-of-multicloud.html>
- AWS Executive in Residence Blog, "Proven Practices for Developing a Multicloud Strategy". <https://aws.amazon.com/blogs/enterprise-strategy/proven-practices-for-developing-a-multicloud-strategy/>
- Wikipedia, "Terraform (software)". <https://en.wikipedia.org/wiki/Terraform_(software)>
