# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第20回：CI/CDとgitの密結合——インフラがVCSを前提とする時代

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 継続的インテグレーション（CI）の起源——2001年のCruiseControlから2011年のTravis CIまで、CIツールがgitと結びつくまでの変遷
- Infrastructure as Code（IaC）の歴史——CFEngine（1993年）からPuppet、Chef、Ansible、Terraform、CloudFormationへの進化
- GitOpsの誕生——2017年にWeaveworksのAlexis Richardsonが提唱した概念の設計原理と、その4原則
- Reconciliation Loop（リコンシリエーションループ）の仕組み——Flux CDとArgoCDが実現する「宣言的状態管理」
- gitが「開発ツール」から「インフラの基盤」へ変質した構造的な経緯
- gitをSingle Source of Truthとすることの利点とリスク
- 簡易的なGitOpsパイプラインの構築を通じた、宣言的状態管理の体験

---

## 1. すべてがGitリポジトリに収束する

2020年代に入ってから、私の仕事の風景は一変した。

以前はアプリケーションコードとインフラの管理は別の世界だった。コードはGitリポジトリに入れる。インフラはAWSのマネジメントコンソールを手で操作するか、手順書に沿ってコマンドを叩く。デプロイは担当者がSSHでサーバに入り、手動で行う。コードの世界とインフラの世界は、緩やかにつながってはいたが、明確に分離していた。

今は違う。

Terraformの`.tf`ファイルがGitリポジトリに入っている。AWS CDKのTypeScriptコードがGitリポジトリに入っている。Kubernetesのマニフェスト——Deployment、Service、ConfigMap——がGitリポジトリに入っている。GitHub Actionsのワークフロー定義（`.github/workflows/`）がGitリポジトリに入っている。監視設定、アラートルール、ダッシュボードの定義すらGitリポジトリに入っている。

すべてがGitリポジトリに収束していく。

私はこの変化を肌で感じてきた。CDK、Terraform、CloudFormation——IaC（Infrastructure as Code）の現場で日常的にこれらのツールを使い、インフラの変更をgit commitで記録し、Pull Requestでレビューし、マージでデプロイする。コードもインフラも、同じワークフローの中にある。便利だ。効率的だ。

だが、ここで立ち止まって考えたい。

**gitがインフラの「前提条件」になったとき、何が起きるのか。**

gitは元来、ソースコードのバージョン管理のために設計されたツールである。Linus Torvaldsが2005年にGitを作ったとき、彼が想定していたのはLinuxカーネルのソースコードの管理だった。インフラの状態管理ではない。デプロイの制御ではない。監視設定の管理ではない。

それが今、ソフトウェア開発のあらゆるレイヤーがgitを前提として動いている。CIパイプラインはgit pushをトリガーにして起動する。CDパイプラインはgitのブランチ戦略に基づいてデプロイ先を決定する。GitOpsは、Gitリポジトリを「Single Source of Truth（信頼できる唯一の情報源）」とし、インフラの望ましい状態をgitで宣言的に管理する。

この密結合は、便利さと引き換えに何を差し出しているのか。今回は、CI/CDとgitの歴史的な関係を辿りながら、その問いに向き合う。

---

## 2. CI/CDの歴史——gitとの密結合はいつ始まったか

### 継続的インテグレーションの黎明

CI/CDは一夜にして生まれた概念ではない。その起源を辿ると、gitとの出会いは実は比較的最近のことだとわかる。

「継続的インテグレーション（Continuous Integration）」という概念自体は、1990年代後半のExtreme Programming（XP）の文脈で生まれた。Kent Beckが提唱したXPの12のプラクティスの一つとして「Continuous Integration」が含まれていた。しかし、当時これを自動化するツールは存在しなかった。

2001年、ThoughtWorksのMatt FoemmelがCruiseControlを作成した。最初の広く使われたCIサーバである。Martin FowlerとFoemmelが同年に発表した「Continuous Integration」の論文は、この実践を体系的に定義した。CruiseControlはJavaベースのフレームワークで、ソースコード管理システムの変更を検知し、ビルドとテストを自動実行する。

ここで注目すべきは、CruiseControlの時代にはまだgitが存在しなかったということだ。CruiseControlがサポートしていたのはCVSとSubversionだった。CIの概念は、gitとは独立して生まれ、発展した。

### Hudsonの登場とJenkinsへの変遷

2005年2月、Sun MicrosystemsのKohsuke KawaguchiがHudsonを公開した。CruiseControlの後継として、より使いやすいWebインターフェースとプラグインアーキテクチャを備えたCIサーバだった。2008年のJavaOneカンファレンスでDuke's Choice Awardを受賞し、Java開発者コミュニティの間で急速に普及した。

Hudsonの運命が大きく動いたのは、2009年のOracleによるSun Microsystems買収（74億ドル、2010年1月完了）だった。2010年12月、Oracleが「Hudson」の商標権を主張し、コミュニティとの間に亀裂が生じた。2011年1月29日、コミュニティ投票によりプロジェクト名を「Jenkins」に変更することが承認された。OracleはHudsonのフォークを継続したが、開発者コミュニティの大半はJenkinsに移行し、Hudsonは2017年に廃止された。

Jenkinsはプラグインエコシステムの拡張を通じて、あらゆるバージョン管理システム、ビルドツール、デプロイ先をサポートする「万能CI/CDサーバ」へと成長した。Gitサポートもプラグインの一つとして提供され、Jenkins自体はGitに依存しない設計だった。

```
CI/CDツールの進化とバージョン管理の関係:

  2001        2005        2011        2018        2019
  │           │           │           │           │
  ▼           ▼           ▼           ▼           ▼
CruiseControl Hudson    Travis CI   Actions発表  Actions GA
  │           │           │           │           │
  ├─CVS───────┤           │           │           │
  ├─SVN───────┼───────────┤           │           │
  │           ├─Git───────┼───────────┼───────────┤
  │           │           │           │           │
  └───────────┘           └───────────┘           │
  VCSに非依存             GitHubと密結合          │
  (プラグイン方式)         (.travis.yml)           │
                                                  │
                                      ┌───────────┘
                                      ▼
                                 GitHubに内蔵
                                 (.github/workflows/)
```

### Travis CI——CIとGitHubの密結合の始まり

CIとgitの密結合が始まった転換点を一つ挙げるとすれば、2011年のTravis CIの登場だろう。

ベルリンで設立されたTravis CIは、GitHubリポジトリと統合した最初のホステッドCIサービスの一つだった。OSSプロジェクトに無償でCIサービスを提供した最初のサービスでもある。

Travis CIが革新的だった理由は二つある。

第一に、CIの設定がリポジトリの一部になった。`.travis.yml`というYAMLファイルをリポジトリのルートに配置するだけで、CIパイプラインが定義できた。Jenkins時代には、CIの設定はJenkinsサーバのWeb UIで行うものだった。ジョブの設定、ビルドスクリプト、通知先——これらはJenkinsサーバ側に保存され、リポジトリとは独立していた。Travis CIは、CIの設定を「コード」としてリポジトリに含める文化を広めた。

第二に、GitHubのWebhookとの統合が前提だった。Travis CIは、GitHubにプッシュされたコミットやPull Requestを自動的に検知し、ビルドとテストを実行する。CIの「トリガー」がgitのイベント（push、pull_request）と直結した。CruiseControlやJenkinsの時代は、CIサーバがVCSをポーリング（定期的にチェック）する方式が一般的だった。Travis CIは、gitのイベントがCIを「駆動」する世界を実現した。

この変化は小さく見えて、実は根本的だった。CIの設定がリポジトリに入り、CIの起動がgitのイベントに紐づいた瞬間、CIはgitから切り離せなくなった。

前回触れたGitHub Actionsは、この密結合をさらに深化させた。2018年10月に発表され、2019年11月に正式リリースされたGitHub Actionsは、CI/CDをGitHubプラットフォームの「中」に取り込んだ。Travis CIはGitHubの「外」にある外部サービスだったが、GitHub Actionsは GitHubそのものの機能だ。`.github/workflows/`ディレクトリにYAMLファイルを配置するだけで、GitHub上で直接ビルド、テスト、デプロイが実行される。

CruiseControlの時代、CIはVCSに対して中立だった。Jenkinsの時代、CIはプラグインを通じてgitをサポートした。Travis CIの時代、CIはGitHubと密結合した。GitHub Actionsの時代、CIはGitHub自体に内蔵された。

この20年の変遷は、CIがgitから徐々に切り離せなくなっていく歴史でもある。

---

## 3. Infrastructure as Code——「すべてをコードにする」思想

### 構成管理ツールの進化

CI/CDがgitと密結合していった一方で、もう一つの大きな潮流が並行して進行していた。Infrastructure as Code——インフラをコードで定義し、管理する思想だ。

IaCの歴史は、1993年にMark BurgessがCFEngineを開発したことに遡る。CFEngineは「収束原理」を導入した。システムが定義された目標状態に自動的に収束する——この概念は、後のすべてのIaCツールの思想的基盤となった。

しかし、IaCが実用的な形で広まり始めたのは2000年代後半からだ。

2005年、Puppetがリリースされた。宣言的なマニフェストファイルでシステムの「望ましい状態」を定義し、Puppetエージェントがその状態を実現する。ユーザー、パッケージ、サービスの設定を、手作業ではなくコードで管理する文化の礎を築いた。

2009年、Chefがリリースされた。Puppetの宣言型アプローチに対し、Chefは命令型（手順を記述する）モデルを採用した。Rubyのコード（レシピ）でインフラの構成手順を定義する。レシピを組み合わせたクックブックという概念で、構成の再利用と共有を可能にした。

2012年、Michael DeHaanがAnsibleを開発した。Ansibleの革新は「エージェントレス」という設計だった。PuppetやChefはターゲットマシンにエージェントをインストールする必要があったが、AnsibleはSSH接続だけで動作する。YAML形式のPlaybookによる定義は、それまでの構成管理ツールと比較して圧倒的に読みやすかった。2015年10月、Red HatがAnsibleを1億5,000万ドルで買収した。

これらの構成管理ツールに共通するのは、インフラの状態を「ファイル」として表現するという発想だ。ファイルとして表現されたインフラの状態は、当然ながらバージョン管理の対象になる。Puppetのマニフェスト、Chefのクックブック、AnsibleのPlaybook——これらはすべてGitリポジトリに格納され、変更履歴が追跡されるようになった。

### CloudFormation、Terraform——宣言的インフラの完成

構成管理ツールがサーバ「内部」の状態（パッケージ、設定ファイル、サービス）を管理するのに対し、クラウド時代に必要になったのはサーバ「自体」を含むインフラ全体の管理だった。VPC、EC2インスタンス、RDS、S3バケット——クラウドリソースそのものをコードで定義する必要が生じた。

2011年2月、AWSがCloudFormationをリリースした。クラウドベンダーとして初のIaCサービスであり、JSONテンプレート（後にYAMLも対応）でAWSリソースを宣言的に定義する仕組みだった。ローンチ時点で15のAWSサービスのうち13をサポートし、48のリソースタイプに対応していた。マネジメントコンソールを手でクリックする代わりに、テンプレートファイルを書き、そのファイルをCloudFormationに渡せば、定義どおりのインフラが構築される。

CloudFormationの登場は、IaCの概念を一気に具体化した。だが、一つの問題があった。CloudFormationはAWS専用だ。マルチクラウド環境、あるいはクラウドベンダーを横断したインフラ管理には対応できない。

Mitchell Hashimotoは、CloudFormationリリースの翌日にブログを投稿し、この思想をクラウド非依存で実現する必要性を指摘した。そして2014年7月、HashiCorpがTerraform 0.1をリリースした。初期はAWSとDigitalOceanのみのサポートだったが、プロバイダプラグインのアーキテクチャにより、任意のクラウドサービスやSaaSに対応可能な設計だった。HCL（HashiCorp Configuration Language）による宣言的定義は、CloudFormationのJSON/YAMLよりも読みやすいと評価された。

Terraformは最初の18か月間、ダウンロード数がほぼ横ばいだった。しかし徐々にコミュニティが成長し、2016年末には750人以上のコントリビューターとMicrosoft Azure、Google Cloud、OpenStackを含む数十のプロバイダに対応するまでになった。

さらに2019年7月、AWSがCDK（Cloud Development Kit）を一般提供した。CDKはCloudFormationの上位レイヤーとして動作し、TypeScriptやPythonといった汎用プログラミング言語でインフラを定義する「コードファースト」アプローチを実現した。YAML/JSONの宣言的定義に代えて、条件分岐やループを含むプログラミング言語の表現力をインフラ定義に持ち込んだ。

```
IaCツールのレイヤー構造:

  汎用言語によるインフラ定義
  ┌─────────────────────────────────────────┐
  │  AWS CDK (TypeScript/Python)            │ 2019年GA
  │  Pulumi (TypeScript/Python/Go)          │
  └──────────────────┬──────────────────────┘
                     │ 生成
  宣言的インフラ定義  ▼
  ┌─────────────────────────────────────────┐
  │  CloudFormation (JSON/YAML) -- AWS専用   │ 2011年
  │  Terraform (HCL) -- クラウド非依存       │ 2014年
  └──────────────────┬──────────────────────┘
                     │ プロビジョニング
  構成管理            ▼
  ┌─────────────────────────────────────────┐
  │  Puppet (マニフェスト)                   │ 2005年
  │  Chef (レシピ/クックブック)              │ 2009年
  │  Ansible (Playbook/YAML)                │ 2012年
  └──────────────────┬──────────────────────┘
                     │ 構成適用
                     ▼
  ┌─────────────────────────────────────────┐
  │  実際のインフラ (サーバ、ネットワーク、   │
  │  データベース、ストレージ...)             │
  └─────────────────────────────────────────┘

  ↑ これらすべてのファイルがGitリポジトリに収束する
```

### IaCとgitの出会い

ここで重要なのは、IaCツールの歴史においてgitは「後から来た」という事実だ。

CFEngine（1993年）やPuppet（2005年）が登場した頃、GitはまだLinuxカーネルの開発用ツールに過ぎなかった。初期のIaCツールは、ファイルベースの定義をバージョン管理することを想定していたが、それがGitである必然性はなかった。CVSでもSubversionでも構わなかった。

しかし2010年代に入り、GitHubの普及とともにGitが事実上の標準バージョン管理となると、IaCファイルは自然とGitリポジトリに格納されるようになった。そしてCI/CDの設定ファイル（`.travis.yml`、`Jenkinsfile`、`.github/workflows/`）もGitリポジトリに含まれるようになった。

アプリケーションコード、IaCの定義、CI/CDの設定——三つのレイヤーがすべてGitリポジトリに収束した。この収束が、次に述べるGitOpsの思想を可能にした。

---

## 4. GitOps——gitを「Single Source of Truth」にする思想

### GitOpsの誕生

2017年3月2日、WeaveworksのCEO Alexis Richardsonがブログ記事「Operations by Pull Request」でGitOpsという用語を発表した。

Weaveworksのチームは、Kubernetesを本番環境で信頼性高く大規模に運用する中で、あるパターンを発見した。インフラの望ましい状態をGitリポジトリで宣言的に定義し、それを自動的にクラスタに適用する。変更はPull Requestを通じてレビューし、マージされた変更が自動的に反映される。ロールバックはgit revertで行う。彼らはこのパターンを「GitOps」と名づけた。

2018年、WeaveworksはGitOpsのガイドを公開し、CI/CDやIaCとの違いを明確にした。GitOpsは「Kubernetesのための運用モデル」と定義された。

GitOpsの4原則は以下のように整理される。

第一の原則は「宣言的（Declarative）」だ。システムの望ましい状態は宣言的に記述されなければならない。「手順」ではなく「状態」を記述する。Kubernetesのマニフェスト（YAML）は本質的に宣言的であり、この原則に合致している。

第二の原則は「バージョン管理され、イミュータブル（Versioned and Immutable）」だ。望ましい状態はGitリポジトリに保存され、変更履歴が完全に追跡される。Gitの特性——全履歴の保持、暗号学的ハッシュによる完全性保証——がこの原則を支える。

第三の原則は「自動的にPullされる（Pulled Automatically）」だ。承認された変更は、エージェントによって自動的にシステムに適用される。ここでのキーワードは「Pull」だ。従来のCI/CDパイプラインは変更を「Push」する——CIサーバがクラスタに対してkubectl applyを実行する。GitOpsでは、クラスタ内のエージェントがGitリポジトリから変更を「Pull」する。この違いは後述する。

第四の原則は「継続的にリコンサイル（Reconciled Continuously）」だ。エージェントはGitリポジトリで定義された望ましい状態と、クラスタの実際の状態を継続的に比較し、差異があれば自動的に修正する。これがReconciliation Loop（リコンシリエーションループ）だ。

### PushモデルとPullモデル

GitOpsの設計原理を理解するうえで、PushモデルとPullモデルの違いは重要だ。

従来のCI/CDパイプライン（PushモデルGFは、以下のように動作する。

```
Pushモデル（従来のCI/CD）:

  開発者
    │
    ▼ git push
  Git リポジトリ
    │
    ▼ Webhook / イベント
  CI/CDサーバ（Jenkins, GitHub Actions等）
    │
    ▼ kubectl apply / terraform apply / deploy
  本番環境（Kubernetesクラスタ等）

  特徴:
  - CI/CDサーバが本番環境への「書き込み権限」を持つ
  - CI/CDサーバから本番環境へ「Push」する
  - CI/CDサーバが単一障害点になりうる
  - 本番環境が「望ましい状態」からドリフトしても検知できない
```

GitOps（Pullモデル）は、以下のように動作する。

```
Pullモデル（GitOps）:

  開発者
    │
    ▼ git push
  Gitリポジトリ（Single Source of Truth）
    ▲
    │ 継続的にPull（ポーリング / Webhook）
  GitOpsエージェント（クラスタ内で稼働）
    │
    │ Reconciliation Loop:
    │   1. Observe: Gitリポジトリの状態を監視
    │   2. Diff:    望ましい状態 vs 実際の状態を比較
    │   3. Act:     差異があれば自動的に修正
    │
    ▼
  本番環境（Kubernetesクラスタ）

  特徴:
  - エージェントがクラスタ「内部」で稼働する
  - 外部からの書き込みアクセスが不要
  - クラスタの実状態とGitの宣言的状態を継続的に比較
  - ドリフト（意図しない変更）を自動検知・修正
```

Pushモデルでは、CI/CDサーバが本番環境への書き込み権限を持つ。これはセキュリティ上のリスクだ。CI/CDサーバが侵害されれば、本番環境にも直接影響が及ぶ。

Pullモデルでは、GitOpsエージェントがクラスタ内部で稼働し、Gitリポジトリから変更をPullする。外部からクラスタへの直接的な書き込みアクセスは不要だ。これにより、攻撃面が縮小する。

さらにPullモデルの本質的な利点は、Reconciliation Loopにある。エージェントはGitリポジトリの状態とクラスタの実状態を継続的に比較する。誰かがkubectlで手動変更を加えたり、障害で一部のリソースが失われたりしても、エージェントが差異を検知し、Gitリポジトリで定義された状態に自動的に復元する。

これは、制御理論のフィードバックループと同じ原理だ。目標値（Gitリポジトリの宣言的状態）と実測値（クラスタの実状態）を比較し、偏差があれば修正する。CFEngineが1993年に導入した「収束原理」が、Kubernetesとgitの組み合わせで再発明されたとも言える。

### FluxとArgoCD——GitOpsの実装

GitOpsの概念を具体的なソフトウェアとして実装したのが、Flux CDとArgoCDだ。

Flux CDは、Weaveworksが2016年に開発しオープンソース化した。GitOpsの概念が命名される以前から、実質的にGitOpsのパターンを実装していたツールだ。2019年にCNCF（Cloud Native Computing Foundation）サンドボックスプロジェクトとして採択され、2020年にKubernetesコントローラーランタイムとカスタムリソース定義を活用した全面再設計（Flux v2）が決定された。2022年11月、CNCF Graduatedステータスを達成した。Graduatedは CNCFの最高成熟度レベルであり、セキュリティ、長期的存続可能性、ガバナンスの厳格な審査を通過したことを意味する。

ArgoCDは、Intuitが社内プロジェクトとして開発し、2018年1月にオープンソース化した。背景にはApplatixの買収（2018年）がある。ArgoCDはKubernetesコントローラーとして実装され、Gitリポジトリで定義された望ましい状態とクラスタの実状態を継続的に監視・同期する。Electronic Arts、MLB（Major League Baseball）、Tesla、Ticketmasterなどが本番環境で使用している。2022年にCNCF Graduatedステータスを達成した。

FluxとArgoCDはアプローチが異なる。Fluxはマルチテナント対応や複数Gitリポジトリの同期を重視し、よりモジュラーな設計を採用している。ArgoCDはWebベースのUIを提供し、視覚的なアプリケーション状態の確認とデプロイ管理に強みがある。だが、両者の根底にある思想は同じだ。Gitリポジトリを唯一の情報源とし、Reconciliation Loopでクラスタの状態を維持する。

### GitOps提唱者の退場

ここで、一つの事実を記録しておく必要がある。

2024年2月、GitOpsの概念を提唱したWeaveworksが事業を停止した。CEO Alexis RichardsonがLinkedInで閉鎖を発表した。2014年に設立され、総額6,100万ドル以上の資金調達を行ったWeaveworksは、2022年の経済低迷と追加投資の不在により、事業継続が困難になった。

しかし、FluxはCNCFの下で存続している。Richardson氏はFluxの継続を保証するため複数の大規模組織と協力していると述べた。

この出来事は、二つのことを示している。

第一に、概念はその提唱者を超えて存続しうるということ。GitOpsはWeaveworksの商標ではなく、オープンな概念だ。Weaveworksが消えても、GitOpsの思想とそれを実装するツール（Flux、ArgoCD）は生き続ける。これはオープンソースの本質を体現している。

第二に、「GitOps」という概念をビジネスにすることの困難さだ。概念を提唱し、そのオープンソース実装を主導しても、それだけではビジネスとして持続可能とは限らない。概念の価値と、その概念をマネタイズできるかどうかは、別の問題だ。

---

## 5. gitが「前提」になることのリスク

### Single Source of Truthの光と影

GitOpsは、Gitリポジトリを「Single Source of Truth（SSOT）」として位置づける。すべてのインフラの望ましい状態はGitリポジトリに記録され、そこからの逸脱は自動的に修正される。これは強力な概念だ。

だが、「Single Source of Truth」という概念には、注意深く考えるべき前提がある。

第一に、Gitリポジトリが本当に「Truth（真実）」であるためには、リポジトリの内容が常に正確で完全でなければならない。現実には、すべてのインフラ状態をGitリポジトリに記述しきれないケースがある。動的に生成されるリソース、外部サービスとの連携状態、ランタイムで変化する設定値——これらはGitリポジトリに記述することが困難だ。

第二に、gitは秘密情報（シークレット）の管理に向いていない。データベースのパスワード、APIキー、TLS証明書——これらをGitリポジトリにそのまま格納することはセキュリティ上の重大なリスクだ。GitOpsの文脈では、Sealed SecretsやExternal Secrets Operatorのようなツールで暗号化されたシークレットをGitリポジトリに格納するか、HashiCorp Vaultのような外部シークレット管理サービスと連携する必要がある。「すべてをGitに」という理念と、「シークレットをGitに入れてはならない」という制約は、本質的に矛盾する。

第三に、gitリポジトリへの書き込み権限が事実上のインフラ管理権限になる。GitOpsの世界では、mainブランチにマージされた変更は自動的に本番環境に反映される。これは、Gitリポジトリのアクセス制御がインフラのアクセス制御と同義になることを意味する。Gitのブランチ保護ルール、Pull Requestのレビュープロセス、マージ権限の管理——これらが、インフラの安全を守る最後の砦になる。

### Gitの設計とインフラ管理のミスマッチ

Gitは本来、テキストファイル（主にソースコード）の変更履歴を管理するために設計された。第18回で論じたように、Gitにはトレードオフがある。大きなバイナリファイルが苦手であること、リポジトリの肥大化に対する耐性が限定的であること。これらの特性は、インフラ管理の文脈でも顕在化する。

Terraformの`.tfstate`ファイル（状態ファイル）は、Gitリポジトリに直接格納すべきではないとされている。状態ファイルには機密情報が含まれうるし、複数人が同時に操作するとコンフリクトが生じる。Terraformは状態ファイルをS3バケットやTerraform Cloudに保存し、ステートロックで排他制御を行う設計を推奨している。Gitのマージモデルは、インフラの状態管理には適さない場合がある。

Kubernetesのマニフェストは宣言的なYAMLファイルであり、テキストファイルとしてのGit管理には適している。しかし、マニフェストの数が増えるにつれて、リポジトリの構造が複雑化する。数百のマイクロサービス、各環境（開発、ステージング、本番）ごとの設定差分、HelmチャートやKustomizeのオーバーレイ——これらを一つのGitリポジトリでどう整理するかは、自明ではない。

### ツールのロックインからパラダイムのロックインへ

前回、GitHubのプラットフォームロックインについて論じた。CI/CDの設定ファイルがプラットフォーム固有であること（`.github/workflows/` vs `.gitlab-ci.yml`）が、移行コストを高めていることを指摘した。

GitOpsは、この問題をさらに深い次元に拡張する。GitOpsの世界では、gitが単なるバージョン管理ツールではなく、インフラ運用の中核メカニズムとなる。デプロイはgit commitで行い、ロールバックはgit revertで行い、監査はgit logで行う。gitの操作がインフラの操作と等価になる。

これは「ツールのロックイン」ではなく「パラダイムのロックイン」だ。特定のホスティングサービス（GitHub、GitLab）へのロックインではなく、git自体へのロックイン。gitの分岐モデル、マージモデル、コミットモデルが、インフラ運用のあり方を規定する。

gitは優れたツールだ。だが、完璧ではない。第18回で論じた通り、gitには設計上のトレードオフがある。そのトレードオフが、インフラ運用の文脈でもそのまま継承される。

たとえば、gitは変更の「順序」を暗黙的に仮定する。コミットはDAG（有向非巡回グラフ）上の線形な列として表現される。しかし、インフラの変更は必ずしも線形ではない。複数の独立した変更が並行して進み、それぞれが異なるタイミングで本番に適用される。この非線形性と、gitの線形なコミット列との間に生じる摩擦は、運用の複雑さの一因となる。

あるいは、gitのコンフリクト解消はテキストレベルで行われる。二つのブランチが同じファイルの同じ行を変更した場合、gitはコンフリクトを報告し、手動解消を求める。ソースコードのコンフリクトであれば、開発者が意味を理解して解消できる。しかし、Terraformの`.tf`ファイルやKubernetesのマニフェストのコンフリクトは、インフラの整合性に直結する。テキストレベルのマージが、インフラレベルで正しい結果を保証するわけではない。

あなたの現場では、gitはインフラの「前提」になっているだろうか。その前提を疑ったことはあるだろうか。

---

## 6. ハンズオン：簡易GitOpsパイプラインを構築する

GitOpsの概念を理論で理解するだけでなく、手を動かして体験する。このハンズオンでは、Gitリポジトリの変更を検知し、自動的にデプロイを実行する簡易的なGitOpsパイプラインを構築する。本格的なKubernetes環境やFlux/ArgoCDは使わず、シェルスクリプトでReconciliation Loopの本質を再現する。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y git jq
```

### 演習1：宣言的な状態定義とGitリポジトリ

```bash
WORKDIR="${HOME}/vcs-handson-20"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=== 演習1: 宣言的な状態定義とGitリポジトリ ==="
echo ""

# gitの設定
git config --global user.email "operator@example.com"
git config --global user.name "Platform Operator"
git config --global init.defaultBranch main

# 「GitOpsリポジトリ」を作成
git init --quiet gitops-repo
cd gitops-repo

# 宣言的な状態定義ファイルを作成
# 実際のGitOpsではKubernetesマニフェスト（YAML）だが、
# ここではJSON形式で「アプリケーションの望ましい状態」を定義する
cat > desired-state.json << 'EOF'
{
  "app": {
    "name": "web-frontend",
    "version": "1.0.0",
    "replicas": 2,
    "port": 8080,
    "env": {
      "LOG_LEVEL": "info",
      "MAX_CONNECTIONS": "100"
    }
  }
}
EOF

git add desired-state.json
git commit --quiet -m "Initial desired state: web-frontend v1.0.0 with 2 replicas"

echo "--- 望ましい状態（Desired State）---"
cat desired-state.json
echo ""
echo "-> Gitリポジトリに「望ましい状態」を宣言的に定義した"
echo "   これがGitOpsにおけるSingle Source of Truthとなる"
```

### 演習2：Reconciliation Loopの実装

```bash
echo ""
echo "=== 演習2: Reconciliation Loopの実装 ==="
echo ""

cd "${WORKDIR}"

# 「実際の状態」を保持するディレクトリ（本番環境のシミュレーション）
mkdir -p live-state

# 初期状態: 本番環境は空（まだデプロイされていない）
echo '{}' > live-state/current-state.json

# Reconciliation Loopスクリプトを作成
cat > reconcile.sh << 'RECONCILE_EOF'
#!/bin/bash
# 簡易Reconciliation Loop
# GitOpsエージェント（Flux/ArgoCD）の動作原理を再現する

REPO_DIR="$1"
LIVE_DIR="$2"

echo "[Reconcile] === リコンシリエーション開始 ==="

# Step 1: Observe - Gitリポジトリの望ましい状態を取得
DESIRED=$(cat "${REPO_DIR}/desired-state.json")
echo "[Reconcile] Step 1 (Observe): Gitリポジトリから望ましい状態を取得"

# Step 2: Diff - 望ましい状態と実際の状態を比較
CURRENT=$(cat "${LIVE_DIR}/current-state.json")

if [ "$DESIRED" = "$CURRENT" ]; then
    echo "[Reconcile] Step 2 (Diff): 差異なし -- 望ましい状態と一致"
    echo "[Reconcile] === リコンシリエーション完了（変更なし）==="
    return 0 2>/dev/null || exit 0
fi

echo "[Reconcile] Step 2 (Diff): 差異を検出"
echo ""
echo "  望ましい状態 (Git):"
echo "$DESIRED" | head -5
echo "  ..."
echo ""
echo "  実際の状態 (Live):"
echo "$CURRENT" | head -5
echo "  ..."
echo ""

# Step 3: Act - 差異を修正（望ましい状態を適用）
echo "[Reconcile] Step 3 (Act): 望ましい状態を適用中..."
cp "${REPO_DIR}/desired-state.json" "${LIVE_DIR}/current-state.json"

# デプロイ結果の記録（監査ログ）
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_HASH=$(cd "${REPO_DIR}" && git rev-parse --short HEAD)
echo "${TIMESTAMP} Applied commit ${COMMIT_HASH}" >> "${LIVE_DIR}/deploy-log.txt"

echo "[Reconcile] === リコンシリエーション完了（変更を適用）==="
echo "[Reconcile] 適用元コミット: ${COMMIT_HASH}"
RECONCILE_EOF
chmod +x reconcile.sh

# 初回のリコンシリエーションを実行
echo "--- 初回リコンシリエーション ---"
bash reconcile.sh gitops-repo live-state
echo ""

echo "--- 適用後の本番環境の状態 ---"
cat live-state/current-state.json
echo ""

echo "--- デプロイログ ---"
cat live-state/deploy-log.txt
echo ""

# 再度リコンシリエーションを実行（差異なし）
echo "--- 2回目のリコンシリエーション（差異なし）---"
bash reconcile.sh gitops-repo live-state
echo ""
echo "-> 差異がなければ何もしない。これがReconciliation Loopの基本動作"
```

### 演習3：git commitによるデプロイ

```bash
echo ""
echo "=== 演習3: git commitによるデプロイ ==="
echo ""

cd "${WORKDIR}/gitops-repo"

# 変更をコミット: バージョンアップとレプリカ数の変更
cat > desired-state.json << 'EOF'
{
  "app": {
    "name": "web-frontend",
    "version": "1.1.0",
    "replicas": 3,
    "port": 8080,
    "env": {
      "LOG_LEVEL": "info",
      "MAX_CONNECTIONS": "200"
    }
  }
}
EOF

git add desired-state.json
git commit --quiet -m "Update web-frontend to v1.1.0, scale to 3 replicas"

echo "--- 変更内容（git diff）---"
git log --oneline -2
echo ""
git diff HEAD~1 -- desired-state.json
echo ""

# リコンシリエーションを実行
echo "--- リコンシリエーション実行 ---"
cd "${WORKDIR}"
bash reconcile.sh gitops-repo live-state
echo ""

echo "--- 更新後の本番環境の状態 ---"
cat live-state/current-state.json
echo ""

echo "-> git commitが「デプロイ」として機能する"
echo "   変更の記録（誰が、いつ、なぜ）はgit logに残る"
```

### 演習4：git revertによるロールバック

```bash
echo ""
echo "=== 演習4: git revertによるロールバック ==="
echo ""

cd "${WORKDIR}/gitops-repo"

echo "--- ロールバック前のコミット履歴 ---"
git log --oneline
echo ""

# git revert で直前の変更を取り消す
git revert --no-edit HEAD

echo "--- ロールバック後のコミット履歴 ---"
git log --oneline
echo ""

echo "--- revert後の望ましい状態 ---"
cat desired-state.json
echo ""

# リコンシリエーションを実行
cd "${WORKDIR}"
bash reconcile.sh gitops-repo live-state
echo ""

echo "--- ロールバック後の本番環境の状態 ---"
cat live-state/current-state.json
echo ""

echo "--- 全デプロイログ ---"
cat live-state/deploy-log.txt
echo ""

echo "-> git revertが「ロールバック」として機能する"
echo "   ロールバックの履歴もgit logに監査証跡として残る"
echo "   従来のデプロイツールでは、ロールバックは別の操作だったが"
echo "   GitOpsではgitの標準操作で完結する"
```

### 演習5：ドリフト検知と自動修復

```bash
echo ""
echo "=== 演習5: ドリフト検知と自動修復 ==="
echo ""

cd "${WORKDIR}"

echo "--- 現在の本番環境の状態 ---"
cat live-state/current-state.json | jq -r '.app.version'
echo ""

# 誰かが手動で本番環境を変更してしまった（ドリフト）
echo "--- 手動変更によるドリフトをシミュレート ---"
cat > live-state/current-state.json << 'EOF'
{
  "app": {
    "name": "web-frontend",
    "version": "1.0.0-hotfix",
    "replicas": 1,
    "port": 8080,
    "env": {
      "LOG_LEVEL": "debug",
      "MAX_CONNECTIONS": "50"
    }
  }
}
EOF

echo "手動変更後の状態:"
echo "  version: $(cat live-state/current-state.json | jq -r '.app.version')"
echo "  replicas: $(cat live-state/current-state.json | jq -r '.app.replicas')"
echo ""

# リコンシリエーションを実行 → ドリフトが検知・修復される
echo "--- リコンシリエーション実行（ドリフト検知）---"
bash reconcile.sh gitops-repo live-state
echo ""

echo "--- 修復後の本番環境の状態 ---"
echo "  version: $(cat live-state/current-state.json | jq -r '.app.version')"
echo "  replicas: $(cat live-state/current-state.json | jq -r '.app.replicas')"
echo ""

echo "-> 手動変更（ドリフト）はReconciliation Loopにより自動修復される"
echo "   これがGitOpsの「自己修復（Self-Healing）」特性"
echo "   本番環境の「真実」はGitリポジトリにあり"
echo "   手動変更は「なかったこと」にされる"
```

### 演習で見えたこと

五つの演習を通じて、GitOpsの核心的な概念を体験した。

演習1では、インフラの「望ましい状態」をGitリポジトリに宣言的に定義した。これがGitOpsにおけるSingle Source of Truthだ。実際のGitOpsではKubernetesマニフェスト（YAML）が使われるが、本質は同じである。「何をしたいか」を記述し、「どう実現するか」はシステムに委ねる。

演習2では、Reconciliation Loopの3ステップ——Observe（監視）、Diff（比較）、Act（修正）——を実装した。FluxやArgoCDの内部で行われていることの本質がこれだ。差異がなければ何もせず、差異があれば望ましい状態に収束させる。CFEngineの収束原理と同じ原理である。

演習3では、git commitがデプロイとして機能することを確認した。変更の記録（誰が、いつ、なぜ）がgit logに残る。これは従来のデプロイツールでは別途実装が必要だった監査証跡が、gitの標準機能で自然に実現されることを意味する。

演習4では、git revertがロールバックとして機能することを確認した。ロールバックが新しいコミットとして記録されるため、「いつ、誰がロールバックしたか」も監査証跡に残る。

演習5では、ドリフト検知と自動修復を体験した。手動変更はReconciliation Loopにより自動的に修復される。本番環境の「真実」はGitリポジトリにあり、それ以外の変更は上書きされる。これがGitOpsの自己修復特性だ。

---

## 7. まとめと次回予告

### この回の要点

第一に、CI/CDの歴史はgitとは独立して始まった。2001年のCruiseControl（CVS/SVN対応）、2005年のHudson（後のJenkins）は、特定のVCSに依存しない設計だった。CIとgitの密結合は、2011年のTravis CI（GitHubとの統合前提）から始まり、2019年のGitHub Actions（GitHubに内蔵）で頂点に達した。この20年は、CIがgitから切り離せなくなっていく歴史でもある。

第二に、Infrastructure as Codeの歴史は、インフラの状態を「ファイル」として表現する営みだった。CFEngine（1993年）、Puppet（2005年）、Chef（2009年）、Ansible（2012年）が構成管理のレイヤーを発展させ、CloudFormation（2011年）とTerraform（2014年）がクラウドリソースの宣言的定義を実現した。これらのファイルがGitリポジトリに収束したことが、GitOpsの前提条件を作った。

第三に、GitOpsは2017年にWeaveworksのAlexis Richardsonが提唱した概念であり、Gitリポジトリを「Single Source of Truth」として、インフラの宣言的な状態管理を実現する。その4原則——宣言的、バージョン管理・イミュータブル、自動Pull、継続的リコンシリエーション——は、Flux CD（2016年〜、CNCF Graduated 2022年）とArgoCD（2018年〜、CNCF Graduated 2022年）によって実装されている。

第四に、GitOpsのPullモデルは従来のPushモデルと異なり、クラスタ内のエージェントがGitリポジトリから変更をPullする設計だ。Reconciliation Loopにより、ドリフト（意図しない変更）を自動検知・修復する自己修復特性を持つ。これはCFEngineの収束原理と同じ制御理論の原理に基づいている。

第五に、gitをインフラの「前提」とすることにはリスクがある。シークレット管理とgitの相性の悪さ、テキストベースのマージがインフラの整合性を保証しない問題、そして「ツールのロックイン」ではなく「パラダイムのロックイン」——gitの設計上のトレードオフがインフラ運用にそのまま継承される構造的な問題がある。2024年2月のWeaveworks閉鎖は、GitOpsの概念がその提唱者を超えて存続しうることを示す一方、概念のマネタイズの困難さも浮き彫りにした。

### 冒頭の問いへの暫定回答

gitがインフラの「前提条件」になったとき、何が起きるのか。

起きたことは三つある。

第一に、開発とインフラの境界が消えた。アプリケーションコードもインフラ定義もCI/CD設定も、同じGitリポジトリに格納され、同じワークフロー（ブランチ、Pull Request、マージ）で管理される。開発者とインフラエンジニアが同じ「言語」で会話できるようになった。

第二に、変更の追跡可能性が飛躍的に向上した。git logがインフラの変更履歴そのものになる。いつ、誰が、なぜ変更したかがコミットメッセージに記録される。ロールバックはgit revertで行え、その履歴も残る。監査と説明責任の観点から、これは大きな進歩だ。

第三に、gitの設計上の仮定がインフラ運用を規定するようになった。gitはテキストファイルのバージョン管理のために設計された。シークレット管理、非線形な変更の並行適用、バイナリ設定ファイルの差分管理——これらはgitの設計が想定していなかった領域だ。gitの強みはそのままインフラ運用の強みになるが、gitの弱みもまたそのままインフラ運用の弱みになる。

ツールに何を載せるかを決めるのは、人間だ。gitにインフラを載せることの利点とリスクを理解した上で、意識的に選択する必要がある。

### 次回予告

**第21回「GitHub Copilotとgit——AIが介在するバージョン管理」**

次回は、さらに新しい問いに向き合う。AIがコードを書く時代、「誰が書いたか」をバージョン管理はどう記録するのか。GitHub Copilot（2021年〜）に始まるAI支援開発は急速に進化し、Claude CodeやMCPを使った開発が日常になりつつある。Co-authored-byタグの限界、AIが生成したコードのトレーサビリティ、LLMとバージョン管理の新しい関係——バージョン管理の「著者」概念が揺らぎ始めている。

あなたの開発環境では、AIとどう協調しているだろうか。そのとき、git logには何が記録されているだろうか。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Fowler, M. "Continuous Integration." martinfowler.com, 2006 (originally 2000). <https://martinfowler.com/articles/continuousIntegration.html>
- CruiseControl. SourceForge. <https://cruisecontrol.sourceforge.net/>
- Wikipedia, "Jenkins (software)." <https://en.wikipedia.org/wiki/Jenkins_(software)>
- Wikipedia, "Kohsuke Kawaguchi." <https://en.wikipedia.org/wiki/Kohsuke_Kawaguchi>
- Wikipedia, "Travis CI." <https://en.wikipedia.org/wiki/Travis_CI>
- Richardson, A. "Operations by Pull Request." Weaveworks Blog, 2017-03-02.
- Richardson, A. "What Is GitOps Really?" Medium (Weaveworks Blog). <https://medium.com/weaveworks/what-is-gitops-really-e77329f23416>
- Schapiro, S. "How did GitOps get started? An interview with Alexis Richardson." 2021. <https://schlomo.schapiro.org/2021/02/gitops-interview-alexis-richardson.html>
- Flux CD. <https://fluxcd.io/>
- Flux, "Flux is a CNCF Graduated project." 2022-11. <https://v2-0.docs.fluxcd.io/blog/2022/11/flux-is-a-cncf-graduated-project/>
- Argo CD Documentation. <https://argo-cd.readthedocs.io/en/stable/>
- Intuit Blog, "Cloud Native Computing Foundation Accepts Argo as an Incubator Project." <https://www.intuit.com/blog/news-social/cloud-native-computing-foundation-accepts-argo-as-an-incubator-project/>
- The New Stack, "End of an Era: Weaveworks Closes Shop Amid Cloud Native Turbulence." 2024. <https://thenewstack.io/end-of-an-era-weaveworks-closes-shop-amid-cloud-native-turbulence/>
- TechCrunch, "Cloud native container management platform Weaveworks shuts its doors." 2024-02-05. <https://techcrunch.com/2024/02/05/cloud-native-container-management-platform-weaveworks-shuts-its-doors/>
- Wikipedia, "AWS CloudFormation." <https://en.wikipedia.org/wiki/AWS_CloudFormation>
- HashiCorp, "The Story of HashiCorp Terraform with Mitchell Hashimoto." <https://www.hashicorp.com/en/resources/the-story-of-hashicorp-terraform-with-mitchell-hashimoto>
- Wikipedia, "Terraform (software)." <https://en.wikipedia.org/wiki/Terraform_(software)>
- Wikipedia, "AWS Cloud Development Kit." <https://en.wikipedia.org/wiki/AWS_Cloud_Development_Kit>
- The New Stack, "A Brief DevOps History: The Roots of Infrastructure as Code." <https://thenewstack.io/a-brief-devops-history-the-roots-of-infrastructure-as-code/>
