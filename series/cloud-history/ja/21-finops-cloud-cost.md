# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第21回：FinOps——クラウドコストという新しい工学

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- クラウドのコストモデルの本質——CapEx（資本的支出）からOpEx（運用支出）への構造転換が何をもたらしたか
- AWS Reserved Instances（2009年3月）、Spot Instances（2009年12月）、Savings Plans（2019年11月）の進化と設計思想
- FinOps Foundation（2019年2月設立、2020年6月Linux Foundation傘下）の成立経緯と背景
- FinOpsフレームワークの3フェーズ——Inform（可視化）、Optimize（最適化）、Operate（運用）
- タグ戦略によるコスト配賦と「コストはアーキテクチャの問題である」という原則
- DHH / 37signals のクラウド離脱（2022年）が投げかけた問い
- Infracostを使ったTerraformコードからのコスト事前見積もり

---

## 1. 請求書が突きつけた現実

2015年のある月曜日の朝、私はAWSのマネジメントコンソールにログインし、請求ダッシュボードを開いた。表示された金額に、文字通り血の気が引いた。

前月比で3倍近い請求額だった。

原因を追うのに半日かかった。開発環境のEC2インスタンスが3ヶ月間、止め忘れで回りっぱなしだった。誰かが検証用に立ち上げた`m4.xlarge`が4台。月額にして一台あたり約150ドル。3ヶ月で1,800ドル。それだけなら「授業料」で済む。だが本当の衝撃はその次にあった。

S3のデータ転送費用が想定の10倍になっていた。

アプリケーションのログをS3に保存し、別のリージョンの分析基盤に転送するパイプラインを組んでいた。データ量の見積もりが甘かった。ストレージ費用は安い。だがリージョン間のデータ転送には1GBあたり0.02ドルがかかる。月間数テラバイトのログを転送すれば、転送費用だけで数百ドルに膨らむ。しかもNAT Gatewayを経由していたため、そのデータ処理料金まで加算されていた。

「クラウドは安い」——私はそう信じていた。物理サーバーを買わなくていい。データセンターの電気代も冷却費用も不要。使った分だけ支払う。理屈としては正しい。だが実際にはクラウドの料金体系は、見かけの単純さとは裏腹に、驚くほど複雑だった。コンピュート、ストレージ、データ転送、APIリクエスト、ロードバランサー、DNS問い合わせ、ログ保存——あらゆる操作に価格がつけられ、それらが組み合わさって最終的な請求額を構成する。

この経験から、私はクラウドのコスト管理を真剣に学び始めた。Reserved InstancesとSavings Plansを組み合わせ、Spot Instancesを開発環境に活用し、タグ戦略を整備してチーム別のコスト配賦を実現した。結果として年間のクラウド支出を40%削減した。だがその過程で気づいたのは、コスト最適化が単なる「節約術」ではなく、アーキテクチャ設計そのものと不可分な工学的実践だということだった。

なぜクラウドのコスト管理は一つの専門分野——FinOps——として確立されるに至ったのか。「従量課金」は本当にコスト最適だったのか。この問いを、クラウド料金体系の進化と、その背後にある設計思想から読み解いていく。

---

## 2. 「使った分だけ支払う」という革命とその代償

### CapExからOpExへの構造転換

クラウド以前のインフラ調達は、資本的支出（CapEx）の世界だった。

サーバーを買う。ラックマウントする。ネットワーク機器を設置する。数千万円の初期投資が必要で、その減価償却を3〜5年かけて行う。需要が読めなければ過剰投資になり、需要が予想を超えれば機会損失になる。第1回で私が語った「物理サーバーを自分の手で組み立てた」時代の話だ。サーバーの購入決裁を取るだけで数週間かかり、納品にさらに数週間。ビジネスのスピードとインフラ調達のスピードには常にギャップがあった。

2006年、AWS EC2が「使った分だけ支払う」モデルで登場した。第8回で詳しく論じた通り、これはインフラの調達モデルを根本から変えた。CapExからOpEx（運用支出）への転換だ。サーバーを「買う」のではなく「借りる」。初期投資ゼロ。APIを一つ叩けば数分でサーバーが立ち上がり、不要になれば停止すればいい。課金は秒単位。

この転換がもたらした恩恵は計り知れない。スタートアップは数千万円の初期投資なしにインフラを構築できるようになった。大企業はピーク需要に合わせた過剰投資から解放された。開発チームはインフラのプロビジョニングを待つことなく、必要な時に必要なだけの計算資源を手に入れられるようになった。

だが、この「使った分だけ」モデルには、見落とされがちな前提があった。

**「使った分」を正確に把握し、制御できること。**

物理サーバーの時代、コストは予測可能だった。サーバーを買えば、その費用は固定だ。電気代は多少変動するが、大枠は予算で管理できる。クラウドは違う。すべてが変動費になった。そして変動費は、誰も見ていなければ際限なく膨らむ。

### クラウド料金体系の構造的複雑さ

AWSの料金体系を例に、その構造的複雑さを見てみよう。

```
クラウドコストの構成要素（AWSの場合）:

┌────────────────────────────────────────────────────────────┐
│ 月額請求書                                                   │
├────────────────────────────────────────────────────────────┤
│                                                              │
│  コンピュート (EC2, Lambda, Fargate, ECS...)                 │
│  ├─ インスタンス時間 × 時間単価                              │
│  ├─ vCPU数 × メモリ × アーキテクチャ × リージョン           │
│  └─ OS (Linux/Windows) × テナンシー (共有/専有)             │
│                                                              │
│  ストレージ (S3, EBS, EFS, Glacier...)                       │
│  ├─ 保存量 (GB/月)                                          │
│  ├─ ストレージクラス (Standard/IA/Glacier/Deep Archive)      │
│  ├─ リクエスト数 (PUT/GET/LIST...)                           │
│  └─ ライフサイクル移行コスト                                 │
│                                                              │
│  データ転送                                                  │
│  ├─ リージョン外への転送 (egress)  ← 最大の罠              │
│  ├─ リージョン間転送                                        │
│  ├─ AZ間転送                                                │
│  └─ NAT Gateway データ処理料                                │
│                                                              │
│  ネットワーク (ELB, Route 53, CloudFront, VPC...)            │
│  ├─ ロードバランサー時間 + LCU                              │
│  ├─ DNS問い合わせ数                                         │
│  └─ VPCエンドポイント/NATゲートウェイ時間                   │
│                                                              │
│  データベース (RDS, DynamoDB, ElastiCache...)                 │
│  ├─ インスタンス時間                                        │
│  ├─ ストレージ                                              │
│  ├─ I/O (DynamoDB: RCU/WCU)                                 │
│  └─ バックアップ保持                                        │
│                                                              │
│  その他 (CloudWatch, KMS, Secrets Manager, Support...)       │
│  ├─ メトリクス/ログ量                                       │
│  ├─ API呼び出し数                                           │
│  └─ サポートプラン (% of monthly spend)                     │
│                                                              │
└────────────────────────────────────────────────────────────┘
```

この図の中で、最も見落とされがちなのがデータ転送費用だ。S3にデータを入れるのは無料だが、出すのは有料。リージョン間の転送にも費用がかかる。NAT Gatewayを経由するだけで、本来無料のはずのS3アクセスにデータ処理料金が加算される。あるスタートアップは、VPCエンドポイントの設定が欠けていたことに気づかず、NAT Gateway経由のS3アクセスだけで一日あたり900ドル以上を支払っていたという報告がある。

データ転送費用は「イングレス無料・エグレス有料」というクラウドベンダー共通の構造を持つ。これは単なる料金設定ではなく、戦略的なロックイン機構でもある。データをクラウドに入れるのは容易だが、出すには費用がかかる。マルチクラウド戦略やクラウド離脱を検討する際、この非対称性が意思決定に影響を与える。第22回で取り上げるマルチクラウドの議論でも、このデータ転送費用は重要な論点になるだろう。

### 「クラウドは安い」幻想の崩壊

クラウドの初期、多くの企業が「オンプレミスよりクラウドの方が安い」という単純な比較でクラウド移行を決断した。だがその比較には構造的な問題があった。

オンプレミスのコストには、物理的に目に見えるものが多い。サーバーの購入費用、ラックの使用料、電気代、冷却費用、ネットワーク回線費用。これらは調達部門や経理部門が把握している。一方、クラウドのコストはAPI呼び出し一つ一つに分散している。開発者が`aws ec2 run-instances`を一行叩けば、毎時課金が始まる。その開発者が退職しても、インスタンスは動き続ける。

Flexeraの2025年版「State of the Cloud Report」は、この問題の規模を定量的に示している。クラウド支出の27%が無駄にされている。84%の組織がクラウド支出管理を最大の課題と回答している。組織は予算を平均17%超過している。Gartnerは2025年のパブリッククラウド支出を7,234億ドルと予測している。その27%——約1,950億ドル——が無駄に消えている計算だ。

この無駄の原因は技術的なものだけではない。組織的な問題が大きい。物理サーバーの時代、インフラの調達権限はIT部門に集中していた。購入には稟議が必要で、予算管理のプロセスが機能していた。クラウドはこの統制を解体した。開発者がクレジットカード一枚でインフラを調達できる。これは開発速度の面では革命的だったが、コスト管理の面では無政府状態を生んだ。

---

## 3. クラウド料金モデルの進化——RIからSavings Plansへ

### Reserved Instances（2009年）——最初のコミットメント

AWSがOn-Demand一本の料金体系を脱し、最初のコミットメントモデルを導入したのは2009年3月12日のことだ。Reserved Instances（RI）と名付けられたこの仕組みは、1年または3年の利用をコミットする代わりに、On-Demandに比べて大幅な割引を提供するものだった。

RIの設計思想は明確だ。クラウドの「いつでもやめられる」柔軟性と引き換えに、予測可能な需要に対してはコミットメントによる割引を提供する。物理サーバーの購入に比べれば遥かに柔軟だが、完全な従量課金に比べれば拘束力がある。その中間に最適解がある、というAWSの判断だ。

```
クラウド料金モデルの進化:

  柔軟性 高い                                  割引率 高い
    ←──────────────────────────────────────→
    │                                          │
    │  On-Demand                               │
    │  (2006年〜)                              │
    │  ・柔軟性最大                            │
    │  ・割引なし                              │
    │  ・時間単位→秒単位に改善                 │
    │                                          │
    │          Savings Plans                   │
    │          (2019年〜)                      │
    │          ・$/hrでコミット                │
    │          ・インスタンス変更自由          │
    │          ・最大66%割引(Compute SP)       │
    │                                          │
    │                  Reserved Instances      │
    │                  (2009年〜)              │
    │                  ・インスタンスタイプ固定│
    │                  ・1年 or 3年            │
    │                  ・最大72%割引           │
    │                                          │
    │                          Spot Instances  │
    │                          (2009年〜)      │
    │                          ・中断リスクあり│
    │                          ・最大90%割引   │
    │                                          │
    柔軟性 低い                                  割引率 最大
```

同年12月14日には、Spot Instancesが登場した。AWSの余剰キャパシティを大幅な割引価格で利用できるが、AWSが必要とすれば2分間の通知で中断される。当初は入札方式で、利用者が価格を提示し、市場価格を上回れば利用可能、下回れば中断されるという仕組みだった。

RIとSpot Instancesの登場は、クラウドの料金体系が「均一な従量課金」から「需要特性に応じた複数プラン」へと進化した転換点だ。だがこの進化は、同時にコスト最適化の複雑さを増すことにもなった。

### RIの進化と課題

RIは導入後も継続的に改良された。当初はAvailability Zone単位・インスタンスタイプ固定だったが、リージョンスコープの導入で同一リージョン内の任意のAZに適用可能になった。2016年にはConvertible RIが追加され、期間中にインスタンスタイプを変更できるようになった（割引率は低下するが）。

だが根本的な課題は残った。RIは「キャパシティベースのコミットメント」だ。特定のインスタンスタイプに紐づくため、アーキテクチャの変更——たとえばEC2からFargateへの移行、あるいはインスタンスファミリーの変更——が起きると、RIの価値が失われる。3年契約のRIを購入した翌月に、より効率的な新世代インスタンスがリリースされるということは珍しくない。

RI管理はそれ自体が専門技能になった。どのインスタンスタイプをどの期間で購入するか。前払いか一部前払いか前払いなしか。Standard RIかConvertible RIか。これらの組み合わせを最適化するには、利用パターンの分析、将来の需要予測、そしてAWSの料金改定動向の把握が必要だ。中規模以上の企業では、RI管理だけで担当者がつくようになった。

### Savings Plans（2019年）——コミットメントの再定義

2019年11月、AWSはSavings Plansを発表した。これはRIの課題に対する根本的な回答だった。

Savings Plansの革新は、コミットメントの単位を「インスタンスタイプ」から「支出金額」に変えたことだ。「m5.xlargeを1年間使います」ではなく、「コンピュートに毎時10ドルを1年間支払います」というコミットメントモデルだ。

```
Reserved Instances vs Savings Plans:

  Reserved Instances (2009年〜):
    コミットメント: 特定のインスタンスタイプ × 期間
    例: "m5.xlarge × 1年 × 前払い"

    ┌─────────────┐     RI適用
    │  m5.xlarge  │ ←── ○ 割引適用
    └─────────────┘
    ┌─────────────┐     RI適用外
    │  m6i.xlarge │ ←── × 割引なし（新世代に変更したら無駄に）
    └─────────────┘
    ┌─────────────┐     RI適用外
    │   Fargate   │ ←── × 割引なし（コンテナに移行したら無駄に）
    └─────────────┘

  Savings Plans (2019年〜):
    コミットメント: 毎時の支出金額 × 期間
    例: "$10/hr × 1年"

    ┌─────────────┐     SP適用
    │  m5.xlarge  │ ←── ○ 割引適用
    └─────────────┘
    ┌─────────────┐     SP適用
    │  m6i.xlarge │ ←── ○ 割引適用（インスタンス変更OK）
    └─────────────┘
    ┌─────────────┐     SP適用（Compute SPの場合）
    │   Fargate   │ ←── ○ 割引適用（サービス変更もOK）
    └─────────────┘
```

Savings Plansには2種類ある。Compute Savings Plans（最大66%割引）は、EC2、Fargate、Lambdaを問わず、リージョンも問わず適用される。EC2 Instance Savings Plans（最大72%割引）は、特定リージョン内のEC2に限定されるが、インスタンスファミリー内での変更は自由だ。

この設計変更の意味は深い。RIは「インフラの固定化」を暗に要求していた。コスト最適化のためにアーキテクチャの進化を犠牲にする、という本末転倒が起きうる構造だった。Savings Plansは「支出額は確定するが、何に使うかは自由」というモデルにより、コスト最適化とアーキテクチャの進化を両立させた。

AWSはRIの販売を継続しているが、多くの利用者にとってSavings Plansの方が好ましいと公式に認めている。RIからSavings Plansへの進化は、クラウドベンダー自身も料金体系の最適解を模索し続けていることを示している。

---

## 4. FinOpsの誕生——なぜ「コスト管理」が専門分野になったのか

### 問題の顕在化（2015年頃〜）

クラウド利用の初期、コスト管理は片手間の仕事だった。利用料金は小さく、月に一度請求書を確認すれば十分だった。だがクラウド利用が拡大し、企業のIT予算に占めるクラウド支出の割合が増大するにつれ、状況は変わった。

2015年頃から、クラウドコスト問題の顕在化が加速した。企業のクラウド支出が年間数百万ドルから数千万ドル規模に達し、従来の予算管理プロセスでは追いつかなくなった。開発チームは高速にリソースをプロビジョニングし、財務チームは月末の請求書で初めて実態を知る。この断絶が、クラウドコスト管理を単なるIT運用の一部ではなく、独立した専門分野にする圧力を生んだ。

### クラウドコスト管理ツールの登場

市場の需要に応じて、クラウドコスト管理に特化したツールが相次いで登場した。

2011年、Mat Ellis、J.R. Storment、Jon FrisbyがCloudabilityをポートランドで創業した。クラウドの課金・利用データを収集・分析し、無駄を可視化するツールだ。同時期にCloudHealth Technologies（2012年設立、2018年にVMwareが買収）も登場した。

AWS自身も2013年にCost Explorerを導入し、利用者が自分の支出を可視化できるようにした。だがCost Explorerは「見る」ためのツールであり、「最適化する」ためのツールではない。可視化と最適化の間には、大きなギャップがある。

2007年に創業したApptioは、IT支出管理（Technology Business Management）というより広い文脈でクラウドコストに取り組んでいた。2019年にCloudabilityを買収し、TBMとクラウドコスト管理を統合した。そして2023年6月、IBMがApptioを46億ドルで買収した。IT支出管理ツール企業に46億ドルの値がつくこと自体が、この領域の市場規模と戦略的重要性を物語っている。

### FinOps Foundationの設立（2019年）

2019年2月、J.R. StormentがFinOps Foundationを設立した。Stormentは前述の通りCloudabilityの共同創業者であり、数百社のクラウドコスト管理を支援してきた実務家だ。彼がFinOps Foundationを設立した動機は、クラウドコスト管理のベストプラクティスを体系化し、組織横断的に共有することだった。

「FinOps」という言葉は「Finance」と「DevOps」の合成語だ。DevOpsが開発と運用の壁を壊したように、FinOpsは技術と財務の壁を壊すことを目指す。従来のIT予算管理では、財務チームが年次予算を策定し、IT部門がその枠内で運用する。クラウドの従量課金モデルでは、この直線的なプロセスが機能しない。支出額は開発チームの日々の意思決定——どのインスタンスタイプを選ぶか、データをどのリージョンに配置するか、ログをどれだけ保持するか——によって変動する。

2020年6月29日、FinOps FoundationはLinux Foundation傘下に加入した。設立メンバーにはApptio、Kubecost、ProsperOps、VMwareが名を連ねた。2026年時点で96,000人以上のコミュニティ、15,000社以上が参加し、Fortune 50のうち93社が参加している。

FinOps Foundationが定義する「Cloud FinOps」の書籍（J.R. StormentとMike Fullerの共著、O'Reilly刊）は、この分野のバイブルとなった。

### FinOpsフレームワーク——3つのフェーズ

FinOps Foundationが体系化したフレームワークの核心は、3つのフェーズで構成される反復的サイクルだ。

```
FinOpsフレームワーク——3フェーズの反復サイクル:

              ┌──────────┐
              │  Inform  │
              │ (可視化) │
              └────┬─────┘
                   │
    コスト配賦、予算策定、     「誰が」「何に」
    ベンチマーク、予測          「いくら」使っているか
                   │
                   ▼
  ┌──────────┐           ┌──────────┐
  │ Operate  │◀─────────▶│ Optimize │
  │  (運用)  │           │ (最適化) │
  └──────────┘           └──────────┘
       │                       │
  KPI追跡、ガバナンス     使用量最適化（リソース削減）
  ポリシー実行、           レート最適化（RI/SP購入）
  組織文化の醸成           アーキテクチャ改善

  ※ 一方向のプロセスではなく、継続的な反復サイクル
  ※ 組織の成熟度に応じて各フェーズの深さが変わる
```

**Inform（可視化）** フェーズでは、「誰が、何に、いくら使っているか」を明らかにする。タグ戦略によるコスト配賦がその中核だ。AWSの各リソースに`team:backend`、`env:production`、`project:search-api`といったタグを付与し、Cost Explorerやサードパーティツールでフィルタリングすることで、チーム別・プロジェクト別・環境別のコストを可視化する。

タグ戦略は技術的には単純だが、組織的には困難を伴う。すべてのリソースに一貫したタグを付与し続けるには、ガバナンスの仕組みが必要だ。タグが欠けたリソースを検知するルール、新規リソース作成時にタグを強制するポリシー、タグの命名規則の標準化。私の経験では、タグ戦略の設計と運用に最も時間がかかる。技術的な問題ではなく、組織のルール遵守の問題だからだ。

**Optimize（最適化）** フェーズでは、可視化されたコストを実際に削減する。ここには二つの軸がある。

一つは**使用量最適化**だ。使っていないリソースを停止する。過剰なスペックのインスタンスを適正サイズに変更する（ライトサイジング）。開発環境を夜間・週末に自動停止する。これらは「同じ仕事をより少ないリソースで行う」アプローチだ。

もう一つは**レート最適化**だ。同じリソースをより安い単価で利用する。Reserved Instances、Savings Plans、Spot Instancesの活用がこれに該当する。安定したワークロードにはRIやSavings Plans、中断可能なバッチ処理にはSpot Instancesを割り当てる。

**Operate（運用）** フェーズでは、最適化された状態を維持し、継続的に改善する。KPIの設定と追跡、予算超過時のアラート、ガバナンスポリシーの実行が含まれる。だが最も重要なのは、コスト意識を組織文化として定着させることだ。エンジニアが「このアーキテクチャ変更はコストにどう影響するか」を自然に考える文化。FinOpsの究極の目標は、ツールの導入ではなく、この文化の醸成にある。

### 「コストはアーキテクチャの問題である」

FinOpsの最も重要な洞察は、「コストはアーキテクチャの問題である」という認識だ。

マイクロサービスアーキテクチャを例に考えよう。第19回で取り上げた通り、マイクロサービスは独立したデプロイとスケーリングを可能にする。だが各サービスが独立したインフラを持つことは、リソースのフラグメンテーション（断片化）を意味する。モノリスなら1台の大きなインスタンスで済むところを、マイクロサービスでは10個の小さなインスタンスが必要になる。各インスタンスには最低限のリソースオーバーヘッドがあり、合計すると無視できないコストになる。

サーバーレスアーキテクチャ（第18回）は、この問題を一部解決する。Lambda関数はリクエストがない時にはコストがゼロだ。だがリクエスト数が増えると、EC2の方が安くなる逆転点がある。AWS Lambda一回の呼び出しは0.20ドル/100万リクエスト＋実行時間あたりの費用だ。この料金モデルでは、一定以上のトラフィックがある場合、EC2のReserved Instancesの方がコスト効率が良い。

```
コストとアーキテクチャの関係:

  Lambda vs EC2 の損益分岐点（概念図）:

  月額      │
  コスト    │                           EC2 On-Demand
            │                         ╱
            │                       ╱
            │                     ╱
            │        Lambda     ╱
            │          ╱      ╱     EC2 Reserved Instance
            │        ╱      ╱      ╱
            │      ╱      ╱     ╱
            │    ╱     ╱     ╱
            │  ╱    ╱    ╱
            │╱   ╱   ╱
            │  ╱  ╱
            │╱ ╱           損益分岐点
            ├──────────┬────────────────→ リクエスト数/月
            │          │
            │ Lambda   │  EC2 RI
            │ が安い   │  が安い
            │          │

  → アーキテクチャの選択がコストに直結する
  → 「技術的に正しい」選択と「コスト的に正しい」選択は
     必ずしも一致しない
```

データベースの選択もコストに大きく影響する。DynamoDBはリクエスト数に応じた課金で、読み込みが多く書き込みが少ないワークロードではRDS（PostgreSQL/MySQL）より安くなりうる。だが複雑なクエリが必要なワークロードでは、DynamoDBの設計制約がアプリケーション層の複雑さを増し、開発コスト（人件費）が増大する。クラウドのコスト最適化は、インフラコストだけを見ていては最適解にたどり着けない。

この認識——「コストはアーキテクチャの問題である」——がFinOpsの核心だ。コスト最適化をインフラチームだけの責任にするのではなく、アーキテクトと開発者がコストを設計パラメータの一つとして扱うことで、初めて持続可能な最適化が実現する。

---

## 5. DHHの問い——クラウドからの離脱は正解か

### 37signalsのクラウド離脱（2022年）

2022年10月、Ruby on Railsの作者であり37signals（Basecamp、HEYの開発元）のCTOであるDHH（David Heinemeier Hansson）が、クラウドからの離脱を宣言した。

37signalsのクラウド支出は年間約320万ドルに達していた。DHHは自社のワークロードを分析し、クラウドの従量課金モデルが自社にとって最適ではないと結論づけた。約60万ドルのハードウェア投資で、年間約150万ドルのコスト削減が可能だという計算だった。60万ドルのハードウェアは6ヶ月で投資回収できる。5年間で1,000万ドル以上の削減を見込んだ。

2023年、37signalsは実際にBasecamp、HEY、その他5つのアプリケーションをAWSとGCPから自社ハードウェアに移行した。新規人員の追加なしで。

DHHの主張の核心は次の点にある。「クラウドは、需要が不確実で急激にスケールする可能性があるワークロードに最適だ。だが37signalsのように、需要が予測可能で安定しているワークロードでは、クラウドの柔軟性のプレミアムは無駄なコストだ」。

この主張は正しいのか。

### コスト構造の非対称性

37signalsの事例を一般化して捉えるのは危険だ。しかし、DHHが指摘した構造的な問題は、多くの企業に当てはまる。

クラウドの従量課金モデルには、構造的な非対称性がある。クラウドベンダーは規模の経済で効率を追求しているが、そのマージンは利用者に完全には還元されない。AWSの営業利益率は30%を超える。この利益率の中に、データセンターの運用効率、ハードウェアの大量調達、自社設計チップ（Graviton）の開発投資——そしてクラウドベンダーの利益——が含まれている。

安定したワークロードを持つ企業にとって、クラウドの「柔軟性プレミアム」は実質的に保険料だ。需要が急増した時にスケールアウトできるという保険。だが需要が安定している場合、この保険料は純粋なコストになる。

DHHの計算は単純だった。

```
37signalsのクラウド離脱の経済学:

  クラウド時代:
    年間クラウド支出:  $3,200,000
    人件費の追加:      $0（既存チームが運用）
    合計:              $3,200,000/年

  自社ハードウェア移行後:
    ハードウェア投資:  $600,000（初年度のみ）
    年間運用コスト:    $1,700,000（推定）
    合計:              $1,700,000/年（2年目以降）

  削減効果:
    年間削減:          $1,500,000
    5年間累計削減:     $10,000,000以上
    投資回収期間:      約6ヶ月
```

だが、この計算には含まれていないものがある。自社ハードウェアの故障リスク、セキュリティパッチの適用工数、キャパシティプランニングの労力、災害対策の設計——これらの「隠れたコスト」は人件費に吸収されている。37signalsの場合、既存チームにこれらのスキルがあり、追加の人員が不要だったからこの計算が成立した。

### FinOpsが教えてくれること

DHHの事例とFinOpsは、対立するものではない。むしろ同じ問いの異なる解を示している。

FinOpsの本質は「クラウドを安くする方法」ではない。**「技術的判断がコストに与える影響を可視化し、情報に基づいた意思決定を可能にすること」**だ。その結論がクラウドの継続利用であれ、オンプレミスへの回帰であれ、あるいはハイブリッドであれ。

37signalsのDHHは、自社のワークロードを精密に分析し、クラウドのコストモデルが自社に不適合であることを定量的に証明した上で、離脱を決断した。これは見方を変えれば、FinOpsのInformフェーズ——コストの可視化と分析——を徹底的に実行した結果だ。

問題は、多くの企業がこの分析すらできていないことだ。「クラウドは高い、オンプレに戻ろう」という感覚的な判断も、「クラウドはデフォルト、他の選択肢は検討しない」という思考停止も、どちらも情報に基づいた判断ではない。FinOpsが目指すのは、そのどちらでもなく、データに基づいて最適な選択を行う能力を組織に根付かせることだ。

---

## 6. ハンズオン——Infracostでインフラコストを事前に見積もる

ここでは、Infracostを使ってTerraformコードからデプロイ前にインフラコストを見積もる演習を行う。Infracostは2020年にオープンソースとしてリリースされたツールで、「Shift FinOps Left」——設計段階でコストを可視化する——というコンセプトを実現する。

### 演習1：Infracostのセットアップとコスト見積もり

```bash
# === Infracostによるインフラコスト見積もり ===

# 前提: Docker環境（ubuntu:24.04推奨）
# Terraform CLI と Infracost CLI が必要

WORKDIR="${HOME}/cloud-history-handson-21"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=========================================="
echo "演習1: InfracostでTerraformコードのコストを見積もる"
echo "=========================================="

# --- Infracostのインストール ---
echo ""
echo "--- Infracostのインストール ---"
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# --- Terraformのインストール（未インストールの場合） ---
# HashiCorp公式リポジトリから
echo ""
echo "--- Terraformのインストール ---"
if ! command -v terraform &> /dev/null; then
  curl -fsSL https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip -o terraform.zip
  unzip terraform.zip -d /usr/local/bin/
  rm terraform.zip
fi

# --- Infracostの認証 ---
echo ""
echo "--- Infracost APIキーの取得 ---"
echo "無料のAPIキーを取得してください:"
echo "  infracost auth login"
echo ""
echo "または、Infracostのダッシュボードで取得したキーを設定:"
echo "  export INFRACOST_API_KEY=<your-api-key>"
echo ""

# --- サンプルTerraformコードの作成 ---
echo "--- サンプルTerraformコードの作成 ---"

mkdir -p scenario-a scenario-b

# シナリオA: 小規模Webアプリ（EC2 On-Demand）
cat > scenario-a/main.tf << 'TF_EOF'
# シナリオA: EC2ベースの小規模Webアプリ
# On-Demandインスタンスで構成

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"  # 東京リージョン
}

# --- EC2インスタンス（Webサーバー） ---
resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0abcdef1234567890"  # Amazon Linux 2023
  instance_type = "t3.medium"              # 2 vCPU, 4 GiB

  root_block_device {
    volume_size = 30   # 30 GiB gp3
    volume_type = "gp3"
  }

  tags = {
    Name        = "web-server-${count.index + 1}"
    Environment = "production"
    Team        = "backend"
  }
}

# --- RDS（データベース） ---
resource "aws_db_instance" "main" {
  allocated_storage    = 100          # 100 GiB
  storage_type         = "gp3"
  engine               = "postgres"
  engine_version       = "16.1"
  instance_class       = "db.t3.large"  # 2 vCPU, 8 GiB
  identifier           = "main-db"
  username             = "admin"
  password             = "change-me-in-production"
  skip_final_snapshot  = true
  multi_az             = true          # マルチAZ（高可用性）

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

# --- Application Load Balancer ---
resource "aws_lb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

# --- S3バケット（静的アセット + ログ） ---
resource "aws_s3_bucket" "assets" {
  bucket = "myapp-static-assets"

  tags = {
    Environment = "production"
    Team        = "frontend"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "myapp-application-logs"

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}

# --- CloudWatch（ログとメトリクス） ---
resource "aws_cloudwatch_log_group" "app" {
  name              = "/app/web-server"
  retention_in_days = 90

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}

# --- NAT Gateway（プライベートサブネットからの外部通信） ---
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = "subnet-0abcdef1234567890"

  tags = {
    Name        = "main-nat-gw"
    Environment = "production"
  }
}
TF_EOF

# シナリオB: 同じアプリをサーバーレス構成に
cat > scenario-b/main.tf << 'TF_EOF'
# シナリオB: サーバーレス構成の同じアプリ
# Lambda + API Gateway + DynamoDB

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

# --- Lambda関数（APIハンドラー） ---
resource "aws_lambda_function" "api" {
  function_name = "myapp-api"
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  memory_size   = 512   # 512 MiB
  timeout       = 30
  filename      = "dummy.zip"  # プレースホルダー

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

# --- API Gateway ---
resource "aws_apigatewayv2_api" "main" {
  name          = "myapp-api"
  protocol_type = "HTTP"

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

# --- DynamoDB（データベース） ---
resource "aws_dynamodb_table" "main" {
  name         = "myapp-data"
  billing_mode = "PAY_PER_REQUEST"  # オンデマンドキャパシティ
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

# --- S3バケット（静的アセット） ---
resource "aws_s3_bucket" "assets" {
  bucket = "myapp-static-assets-v2"

  tags = {
    Environment = "production"
    Team        = "frontend"
  }
}

# --- CloudFront（CDN） ---
resource "aws_cloudfront_distribution" "main" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.assets.bucket_regional_domain_name
    origin_id   = "s3-assets"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-assets"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = "production"
    Team        = "frontend"
  }
}

# --- CloudWatch（ログ） ---
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/myapp-api"
  retention_in_days = 30  # サーバーレスはログ保持を短めに

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
TF_EOF

echo ""
echo "=== Terraformコードのコスト見積もり ==="
echo ""
echo "--- シナリオA（EC2ベース）の見積もり ---"
echo "  cd scenario-a && infracost breakdown --path ."
echo ""
echo "--- シナリオB（サーバーレス）の見積もり ---"
echo "  cd scenario-b && infracost breakdown --path ."
echo ""
echo "--- シナリオ比較（diff） ---"
echo "  infracost diff --path scenario-b --compare-to scenario-a/infracost-base.json"
```

### 演習2：設計変更のコスト影響をシミュレーション

```bash
echo "=========================================="
echo "演習2: 設計変更のコスト影響シミュレーション"
echo "=========================================="

cd "${HOME}/cloud-history-handson-21"

# シナリオA を修正してコスト影響を確認
mkdir -p scenario-a-optimized

cat > scenario-a-optimized/main.tf << 'TF_EOF'
# シナリオA 最適化版: コスト最適化を適用
# 変更点:
# 1. EC2: t3.medium → t3.small（ライトサイジング）
# 2. RDS: multi_az = false（開発環境向け）
# 3. NAT Gateway削除 → VPCエンドポイント使用
# 4. S3ログのライフサイクルポリシー追加

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

# --- EC2（ライトサイジング: t3.medium → t3.small） ---
resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.small"               # 変更: medium → small

  root_block_device {
    volume_size = 20    # 変更: 30 → 20 GiB
    volume_type = "gp3"
  }

  tags = {
    Name        = "web-server-${count.index + 1}"
    Environment = "production"
    Team        = "backend"
  }
}

# --- RDS（コスト最適化） ---
resource "aws_db_instance" "main" {
  allocated_storage    = 50            # 変更: 100 → 50 GiB
  storage_type         = "gp3"
  engine               = "postgres"
  engine_version       = "16.1"
  instance_class       = "db.t3.medium"  # 変更: large → medium
  identifier           = "main-db"
  username             = "admin"
  password             = "change-me-in-production"
  skip_final_snapshot  = true
  multi_az             = false         # 変更: マルチAZを無効化（非本番向け）

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

# --- ALB（変更なし） ---
resource "aws_lb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"

  tags = {
    Environment = "production"
    Team        = "backend"
  }
}

# --- S3（ライフサイクルポリシー追加） ---
resource "aws_s3_bucket" "assets" {
  bucket = "myapp-static-assets"

  tags = {
    Environment = "production"
    Team        = "frontend"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "myapp-application-logs"

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}

# ログバケットにライフサイクルポリシー
resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "log-retention"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"    # 30日後にIA（低頻度アクセス）
    }

    transition {
      days          = 90
      storage_class = "GLACIER"        # 90日後にGlacier
    }

    expiration {
      days = 365                       # 365日後に削除
    }
  }
}

# --- VPCエンドポイント（NAT Gateway代替） ---
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "vpc-0abcdef1234567890"
  service_name = "com.amazonaws.ap-northeast-1.s3"

  tags = {
    Name        = "s3-endpoint"
    Environment = "production"
  }
}
# NAT Gatewayを削除 → VPCエンドポイント（無料）に置き換え

# --- CloudWatch ---
resource "aws_cloudwatch_log_group" "app" {
  name              = "/app/web-server"
  retention_in_days = 30  # 変更: 90 → 30日

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
TF_EOF

echo ""
echo "=== コスト最適化前後の比較 ==="
echo ""
echo "手順:"
echo "  1. 最適化前のベースラインを生成:"
echo "     cd scenario-a"
echo "     infracost breakdown --path . --format json --out-file infracost-base.json"
echo ""
echo "  2. 最適化後との差分を確認:"
echo "     cd ../scenario-a-optimized"
echo "     infracost diff --path . --compare-to ../scenario-a/infracost-base.json"
echo ""
echo "確認ポイント:"
echo "  - EC2のインスタンスサイズ変更の影響額"
echo "  - RDS multi_az 無効化の影響額"
echo "  - NAT Gateway削除の影響額（月額約45ドル + データ処理料金）"
echo "  - S3ストレージクラス移行の長期的な影響"
echo ""
echo "=== 重要な学び ==="
echo ""
echo "1. NAT Gatewayは月額約45ドル（固定）+ データ処理料金"
echo "   VPCエンドポイント（Gateway型）はS3/DynamoDBアクセスに対して無料"
echo "   → アーキテクチャの小さな変更が大きなコスト影響を持つ"
echo ""
echo "2. RDSのmulti_azはコストを約2倍にする"
echo "   → 本番環境以外では不要な場合が多い"
echo ""
echo "3. S3のストレージクラスの使い分けは長期的なコスト削減に直結"
echo "   → ライフサイクルポリシーの設計はアーキテクチャの一部"
echo ""
echo "4. インスタンスのライトサイジングは最も即効性がある最適化"
echo "   → CPU使用率が常に10%以下なら、サイズダウンの余地がある"
```

### 演習3：タグ戦略とコスト配賦の設計

```bash
echo "=========================================="
echo "演習3: タグ戦略とコスト配賦の設計"
echo "=========================================="

cd "${HOME}/cloud-history-handson-21"

cat > tagging-strategy.md << 'MD_EOF'
# タグ戦略テンプレート

## 必須タグ（全リソースに付与）

| タグキー      | 説明                 | 値の例                        |
|---------------|----------------------|-------------------------------|
| Environment   | 環境区分             | production, staging, dev      |
| Team          | 所有チーム           | backend, frontend, platform   |
| Project       | プロジェクト名       | search-api, user-service      |
| CostCenter    | コストセンター番号   | CC-1001, CC-2003              |
| ManagedBy     | 管理方法             | terraform, manual, cdk        |

## 推奨タグ（付与を推奨）

| タグキー      | 説明                 | 値の例                        |
|---------------|----------------------|-------------------------------|
| Owner         | 担当者メールアドレス | sato@example.com              |
| Purpose       | リソースの目的       | web-server, batch-processing  |
| ExpiresAt     | 削除予定日           | 2026-04-30                    |
| Compliance    | 準拠規制             | pci-dss, hipaa, none          |

## タグ命名規則

- キー: PascalCase（例: CostCenter, ManagedBy）
- 値: lowercase-kebab（例: production, search-api）
- 最大長: キー128文字、値256文字

## ガバナンスルール

1. タグなしリソースの検知: AWS Config ルールで毎日チェック
2. 新規リソース: Service Control Policy（SCP）でタグ必須を強制
3. ExpiresAt超過リソース: 自動通知 → 7日後に自動停止
MD_EOF

cat > check-untagged.sh << 'SH_EOF'
#!/bin/bash
set -euo pipefail

# タグなしリソースを検出するスクリプト
# AWS CLIが認証済みであること

echo "=========================================="
echo "タグなしリソースの検出"
echo "=========================================="

REQUIRED_TAGS=("Environment" "Team" "Project")

echo ""
echo "--- タグなしEC2インスタンスの検出 ---"
echo ""
echo "以下のコマンドでEnvironmentタグが欠けたインスタンスを検出:"
echo ""
echo 'aws ec2 describe-instances \'
echo '  --filters "Name=instance-state-name,Values=running" \'
echo '  --query "Reservations[].Instances[?!Tags || !Tags[?Key==\`Environment\`]].[InstanceId,InstanceType,LaunchTime]" \'
echo '  --output table'
echo ""
echo "--- タグなしRDSインスタンスの検出 ---"
echo ""
echo 'aws rds describe-db-instances \'
echo '  --query "DBInstances[?!TagList || !TagList[?Key==\`Environment\`]].[DBInstanceIdentifier,DBInstanceClass]" \'
echo '  --output table'
echo ""
echo "--- チーム別コストの集計（Cost Explorer API） ---"
echo ""
echo '# 過去30日間のチーム別コストを取得'
echo 'aws ce get-cost-and-usage \'
echo '  --time-period Start=$(date -d "30 days ago" +%Y-%m-%d),End=$(date +%Y-%m-%d) \'
echo '  --granularity MONTHLY \'
echo '  --metrics "UnblendedCost" \'
echo '  --group-by Type=TAG,Key=Team \'
echo '  --output json'
echo ""
echo "=== タグ戦略の効果 ==="
echo ""
echo "タグが整備されると:"
echo "  1. 「このEC2インスタンスは誰が何のために使っているか」が即座にわかる"
echo "  2. チーム別・プロジェクト別のコスト配賦が自動化される"
echo "  3. 不要リソースの検知と削除が容易になる"
echo "  4. 予算超過時に責任チームを特定できる"
echo ""
echo "タグがないと:"
echo "  5. 誰も所有者がわからない「幽霊リソース」が増殖する"
echo "  6. コスト削減の施策を打てない（何を削減すべきかわからない）"
echo "  7. 退職者が作成したリソースが永遠に課金され続ける"
SH_EOF
chmod +x check-untagged.sh

echo ""
echo "=== 作成されたファイル ==="
echo "  tagging-strategy.md  -- タグ戦略テンプレート"
echo "  check-untagged.sh    -- タグなしリソース検出スクリプト"
echo ""
echo "タグ戦略はFinOpsのInformフェーズの基盤。"
echo "「誰が、何に、いくら使っているか」を答えられなければ、"
echo "最適化は始まらない。"
```

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/21-finops-cloud-cost/` に用意してある。

---

## 7. まとめと次回予告

### この回のまとめ

第21回では、クラウドコスト管理がなぜ一つの専門分野——FinOps——として確立されたのかを、料金体系の進化と組織的課題の両面から読み解いた。

**クラウドはCapExからOpExへの構造転換を実現した。** 初期投資ゼロ、従量課金、数分でのプロビジョニング。この恩恵は計り知れない。だが同時に、「使った分を正確に把握し制御する」という新しい課題を生んだ。Flexeraの調査によればクラウド支出の27%が無駄にされ、84%の組織がクラウド支出管理を最大の課題と回答している。物理サーバーの時代には存在しなかった「変動費の暴走」という問題が、クラウドの構造的特性から生まれた。

**AWSの料金モデルはOn-Demand一本から、コミットメントモデルへと進化した。** 2009年3月にReserved Instances（キャパシティベースのコミットメント）、同年12月にSpot Instances（余剰キャパシティの割引利用）が登場し、2019年11月にSavings Plans（支出ベースのコミットメント）が発表された。RIからSavings Plansへの進化は、「インスタンスタイプへの紐づけ」から「支出金額へのコミットメント」への転換であり、コスト最適化とアーキテクチャの進化を両立させる設計だ。

**FinOps Foundation（2019年2月設立、2020年6月Linux Foundation傘下加入）は、クラウドコスト管理のベストプラクティスを体系化した。** そのフレームワークは、Inform（可視化）、Optimize（最適化）、Operate（運用）の3フェーズで構成される反復的サイクルだ。FinOpsの最も重要な洞察は「コストはアーキテクチャの問題である」——設計判断がコストに直結するため、コスト最適化をインフラチームだけの責任にするのではなく、アーキテクトと開発者がコストを設計パラメータとして扱うべきだという認識だ。

**DHH / 37signalsのクラウド離脱（2022年）は、FinOpsの問いを極限まで突き詰めた事例だ。** 年間320万ドルのクラウド支出を、60万ドルのハードウェア投資と年間150万ドルの運用コストに置き換え、5年間で1,000万ドル以上の削減を見込んだ。安定したワークロードではクラウドの「柔軟性プレミアム」が純粋なコストになるという指摘は、すべてのクラウド利用者が検討すべき視点だ。

冒頭の問いに答えよう。「従量課金」は万能ではない。需要が不確実でスパイクするワークロードには最適だが、安定したワークロードでは過剰なプレミアムを支払うことになる。クラウドのコスト管理が専門分野になったのは、料金体系の複雑さ、変動費の不確実性、組織的な統制の困難さ、そしてアーキテクチャとコストの不可分な関係——これらが重なったためだ。FinOpsはクラウド時代の必須のエンジニアリング実践であり、その本質は「技術的判断のコスト影響を可視化し、情報に基づいた意思決定を可能にすること」にある。

### 次回予告

第22回では、「マルチクラウドの現実——理想と実務のギャップ」を取り上げる。

「ベンダーロックインを避けるためにマルチクラウド」——この主張は長年にわたって繰り返されてきた。だが実際にマルチクラウドを運用する企業が直面するのは、理想とはかけ離れた現実だ。各クラウドベンダーのサービスは独自の概念と設計思想を持ち、抽象化レイヤーを挟むほどに各クラウドの強みが失われる。データ転送のコストと遅延、認証・認可の統合、運用チームのスキルセット——マルチクラウドの「コスト」は金銭だけでは測れない。今回のFinOpsの視点も交えながら、マルチクラウドの理想と現実のギャップを、次回で論じる。

---

## 参考文献

- AWS, "Amazon EC2 Introduces Reserved Instances", March 12, 2009. <https://aws.amazon.com/about-aws/whats-new/2009/03/12/amazon-ec2-introduces-reserved-instances/>
- AWS, "Announcing Amazon EC2 Spot Instances", December 14, 2009. <https://aws.amazon.com/about-aws/whats-new/2009/12/14/announcing-amazon-ec2-spot-instances/>
- AWS News Blog, "New – Savings Plans for AWS Compute Services", November 2019. <https://aws.amazon.com/blogs/aws/new-savings-plans-for-aws-compute-services/>
- FinOps Foundation, "FinOps Framework Phases". <https://www.finops.org/framework/phases/>
- FinOps Foundation, "About the FinOps Foundation". <https://www.finops.org/about/>
- J.R. Storment, Mike Fuller, "Cloud FinOps: Collaborative, Real-Time Cloud Value Decision Making", O'Reilly Media. <https://www.oreilly.com/library/view/cloud-finops/9781492054610/>
- Linux Foundation, "FinOps Foundation Quickly Gains Industry-Wide Support", June 2020. <https://www.linuxfoundation.org/press/press-release/finops-foundation-quickly-gains-industry-wide-support-to-advance-cloud-financial-management-and-education>
- 37signals Dev Blog, "Our cloud spend in 2022". <https://dev.37signals.com/our-cloud-spend-in-2022/>
- Basecamp, "Leaving the Cloud". <https://basecamp.com/cloud-exit>
- IBM Newsroom, "IBM Completes Acquisition of Apptio Inc.", August 10, 2023. <https://newsroom.ibm.com/2023-08-10-IBM-Completes-Acquisition-of-Apptio-Inc>
- Flexera, "2025 State of the Cloud Report". <https://www.flexera.com/blog/finops/the-latest-cloud-computing-trends-flexera-2025-state-of-the-cloud-report/>
- Gartner, "Gartner Forecasts Worldwide Public Cloud End-User Spending to Total $723 Billion in 2025", November 2024. <https://www.gartner.com/en/newsroom/press-releases/2024-11-19-gartner-forecasts-worldwide-public-cloud-end-user-spending-to-total-723-billion-dollars-in-2025>
- Infracost, "Cloud cost estimates for Terraform in pull requests". <https://github.com/infracost/infracost>
- AWS, "Organizing and tracking costs using AWS cost allocation tags". <https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/cost-alloc-tags.html>
