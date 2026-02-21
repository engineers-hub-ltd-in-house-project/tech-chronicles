# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第12回：なぜCLIは死ななかったのか――自動化・再現性・組み合わせの力

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- CLIが40年間「死ぬ」と言われ続けながら生き残った構造的理由
- SSH（1995年）がCLIとリモート管理を不可分にした経緯
- Infrastructure as Code（IaC）の系譜とCLI依存の必然性
- Docker CLI（2013年）、kubectl（2014年）がCLIを開発の中心に引き戻した過程
- CLIの4つの構造的優位性：組み合わせ可能性・再現性・リモート操作・バージョン管理親和性
- CI/CD環境という「GUIが存在しない世界」でのCLIの必然性
- WIMPパラダイムの限界と、テキストストリームが持つ普遍性
- 100個のMarkdownファイルから特定パターンを抽出してCSVに変換するタスクで、GUIとCLIの差を体験する

---

## 1. 30台のサーバと、ある夜の気づき

2000年代後半のことだ。私はあるWeb企業のインフラを管理していた。

サーバは30台。すべてLinuxで、SSHで接続して管理する。当時はまだ「クラウド」という言葉が普及する前だ。物理サーバをデータセンターのラックに積み、ネットワークケーブルを手で結線し、OSをインストールし、Apacheの設定を書き、iptablesのルールを設定する。すべてCLIだった。

ある晩、セキュリティパッチの適用を30台すべてに行う必要が生じた。1台あたりの作業は15分程度。だが30台となると7時間半だ。しかも手作業であるから、20台目あたりで設定を一つ飛ばしたことに気づき、最初からやり直す羽目になった。

翌朝、私はシェルスクリプトを書いた。

```bash
#!/bin/bash
SERVERS="web01 web02 web03 ... web30"
for host in $SERVERS; do
    echo "=== Patching $host ==="
    ssh "$host" 'sudo apt-get update && sudo apt-get upgrade -y'
done
```

この十数行のスクリプトが、7時間半の手作業を20分に変えた。しかもこのスクリプトは記録として残る。次のパッチ適用時にも使える。新しいメンバーに引き継げる。バージョン管理もできる。

それから数年後、サーバの台数は100台を超えた。だが作業時間はほとんど変わらなかった。スクリプトを少し書き換えるだけで済んだからだ。

同じ頃、「CLIは古い」と言っていた同僚がいた。彼はGUIの管理画面から手動でサーバを設定していた。10台までは問題なかった。だが100台になったとき、彼は白旗を上げた。「CLIしかない」と悟った彼は、それから3ヶ月かけてシェルスクリプトとAnsibleを習得した。

この話にCLIが死ななかった理由のエッセンスが凝縮されている。CLIが生き残ったのは「古くからあるから」ではない。テキストベースのインターフェースが持つ構造的な優位性が、スケールする問題の解決に不可欠だったからだ。

前回、第11回でGUIの衝撃と認知モデルの違いを検証した。GUIの「再認（recognition）」に基づく発見しやすさは認知科学的に実証された強みだ。にもかかわらず、40年間「死ぬ」と言われ続けたCLIはなぜ開発者の基本ツールであり続けるのか。今回はその答えに正面から取り組む。

---

## 2. CLIを不滅にした歴史的転換点

### SSH――暗号化されたリモートCLIの誕生（1995年）

CLIが「死なない」歴史を語るうえで、最初に触れるべきはSSH（Secure Shell）だ。

1995年、ヘルシンキ工科大学の研究員Tatu Ylonenは、大学ネットワークへのパスワードスニッフィング攻撃を受けた。当時、リモートサーバへの接続手段はtelnetやrloginだったが、これらは通信を平文で流す。パスワードがネットワーク上を暗号化なしで通過するのだから、盗聴は容易だった。

Ylonenは自分自身のためにSSH（Secure Shell）を開発し、1995年7月にフリーソフトウェアとして公開した。年末までに50カ国で20,000ユーザーに達した。1999年にはOpenBSDプロジェクトのTheo de Raadtらが自由なSSH実装であるOpenSSHを開発し、OpenBSD 2.6（1999年12月1日）に同梱した。OpenSSHは事実上の標準となり、あらゆるLinux/UNIXシステムに搭載された。

SSHが決定的だったのは、**CLIとリモート管理を不可分にした**ことだ。SSHは暗号化されたテキストストリームのトンネルを提供する。帯域消費は極めて小さい。300kbps程度の回線でも実用的に操作できる。VNCやRDPのようなGUIリモートデスクトップは、画面転送のために数Mbpsの帯域を要求し、レイテンシにも敏感だ。

SSHの普及は、「リモートのサーバを管理する」という行為がCLIを前提とする世界を確立した。2000年代にインターネット上のサーバ台数が爆発的に増加するにつれ、SSHを通じたCLI管理はインフラエンジニアの日常となった。GUIリモートデスクトップは帯域コストとレイテンシの面で現実的ではなく、CLIは「古いから使う」のではなく「リモート管理に最も効率的だから使う」ものとなった。

### Infrastructure as Code――CLIで「インフラを書く」時代

サーバの台数が増えるにつれ、手作業での管理は限界を迎えた。10台なら手動で設定できる。100台なら怪しい。1,000台になったら不可能だ。

この問題に最初に体系的に取り組んだのが、構成管理ツールの系譜だ。

```
構成管理ツールの系譜:

  1993年  CFEngine (Mark Burgess)
          ── 最初の本格的構成管理ツール
          ── 宣言的言語でシステムの望ましい状態を記述

  2005年  Puppet (Luke Kanies)
          ── Ruby製の宣言的構成管理
          ── カタログ/マニフェストによるサーバ設定の一元管理

  2009年  Chef (Adam Jacob)
          ── Rubyベースの「レシピ」でインフラを記述
          ── "Infrastructure as Code" の概念を広めた

  2012年  Ansible (Michael DeHaan)
          ── エージェントレス、SSHベース
          ── YAMLによるPlaybook
          ── 2015年Red Hatが買収

  共通点: すべてCLIを主要インターフェースとして採用
          GUI管理画面は「補助」であり、本体はCLIとテキストファイル
```

これらのツールに共通するのは、**インフラの設定をテキストファイルとして記述し、CLIで適用する**という設計だ。Puppetのマニフェスト、Chefのレシピ、AnsibleのPlaybook。いずれもテキストファイルだ。テキストファイルであるから、Gitで管理できる。差分が取れる。レビューできる。ロールバックできる。

「Infrastructure as Code」という用語が定着したのは2000年代後半とされる。だが、その本質は単純だ。**インフラの状態をコードとして記述し、バージョン管理し、自動的に適用する。** そのインターフェースはCLIであり、GUIではなかった。

なぜGUIではなかったのか。答えは自明だ。GUIの操作は記録できない。再現できない。バージョン管理できない。差分が取れない。コードレビューできない。1,000台のサーバを同一の状態に保つには、人間の「クリック操作」ではなく、コンピュータが実行できる「テキスト命令」が必要だった。

### Docker CLIとkubectl――CLIが開発ワークフローの中心に戻った

2013年3月、Solomon HykesがPyCon 2013でDocker 0.1を公開した。コンテナ技術自体は新しいものではなかったが、Dockerはそれを開発者にとって使いやすいCLIツールとしてパッケージングした。

```bash
docker build -t myapp .
docker run -p 8080:80 myapp
docker push myapp
```

この3行のコマンドで、アプリケーションのビルド、実行、配布が完結する。Dockerの設計で注目すべきは、**Dockerfileというテキストファイルでコンテナの構築手順を宣言的に記述し、CLIで操作する**という点だ。GUIのコンテナ管理ツールも存在するが、Dockerの本質はCLIとテキストファイルにある。

翌2014年6月、GoogleがKubernetesを発表した。Joe Beda、Brendan Burns、Craig McLuckieらが開発し、GoogleのBorgクラスタマネージャに触発されたコンテナオーケストレーションシステムだ。2015年7月21日にv1.0がリリースされた。

Kubernetesの操作手段はkubectlだ。

```bash
kubectl apply -f deployment.yaml
kubectl get pods
kubectl logs pod-name
kubectl scale deployment myapp --replicas=5
```

YAMLファイルでクラスタの望ましい状態を宣言し、kubectlで適用する。Docker CLIと同じパターンだ。テキストファイルとCLI。Infrastructure as Codeの系譜はここで完成した。

2014年7月にはHashiCorpがTerraform 0.1をリリースした。Mitchell HashimotoとArmon Dadgarが開発したこのツールは、クラウドインフラそのものをテキストファイル（HCL: HashiCorp Configuration Language）で宣言し、CLIから適用する。

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

```bash
terraform init
terraform plan
terraform apply
```

AWS CLIも2013年9月にGAとなり、クラウドリソースの管理をコマンドラインに一元化した。

```
2013-2015年のCLI復権:

  2013年3月   Docker 0.1  ── コンテナ操作をCLIに
  2013年9月   AWS CLI GA  ── クラウド管理をCLIに
  2014年6月   Kubernetes発表 ── コンテナオーケストレーションをCLIに
  2014年7月   Terraform 0.1  ── インフラ定義をCLIに

  → 「サーバを管理する」から「インフラ全体をコードとして管理する」へ
  → すべてのツールがCLIを主要インターフェースとして選んだ
  → GUIは「可視化」には使われたが、「操作」の中心にはならなかった
```

この2013年から2015年の期間は、CLIの歴史における「再征服」だった。GUIに押されて「古い技術」と見なされかけていたCLIが、クラウドネイティブの文脈で「唯一合理的な選択」として復権した。

---

## 3. CLIの4つの構造的優位性

前回の第11回でGUIの強みを分析したように、ここではCLIの強みを構造的に整理する。CLIが40年間死ななかった理由は、ノスタルジーではなく構造にある。

### 第一の優位性：組み合わせ可能性（Composability）

第7回で詳述したUNIXパイプの設計思想が、ここでも効いている。CLIのコマンドはテキストを入力として受け取り、テキストを出力する。この単純な約束事が、無限の組み合わせを可能にする。

```bash
# 3つのコマンドの組み合わせで「今日のエラー件数」を取得
grep "ERROR" /var/log/app.log | grep "2026-02-21" | wc -l
```

この「組み合わせ可能性」はGUIには存在しない。GUIアプリケーションは自己完結している。Excelのデータを直接Photoshopに流し込むことはできない。だがCLIでは、csvtoolの出力をawkに渡し、その結果をgnuplotに渡してグラフを生成する、といった連鎖が自然に書ける。

Neal Stephensonは1999年のエッセイ "In the Beginning was the Command Line" で、この点を鋭く指摘した。GUIアプリケーションは「モノリス」だ。すべての機能を一つのアプリケーション内に閉じ込める。CLIツールは「モジュール」だ。小さなツールを組み合わせることで、設計者が想定しなかった問題を解決できる。

```
GUIとCLIの設計モデルの違い:

  GUI（モノリス型）:
    ┌─────────────────────────────┐
    │  アプリケーションA          │
    │  ┌──────┐ ┌──────┐ ┌────┐ │
    │  │機能1 │ │機能2 │ │... │ │
    │  └──────┘ └──────┘ └────┘ │
    │  データはアプリ内に閉じる   │
    └─────────────────────────────┘
    → 機能の組み合わせはアプリの設計に制約される
    → アプリ間のデータ連携はコピー&ペーストかファイル経由

  CLI（モジュール型）:
    ┌────┐    ┌────┐    ┌────┐    ┌────┐
    │ A  │ -> │ B  │ -> │ C  │ -> │ D  │
    └────┘    └────┘    └────┘    └────┘
    テキストストリーム(stdin/stdout)で接続
    → 各ツールは独立。組み合わせは使用者が決める
    → 設計者が想定しなかった用途にも対応可能
```

この組み合わせ可能性は、問題の規模が大きくなるほど価値を発揮する。1つのファイルを操作するだけなら、GUIのほうが直感的だ。だが1,000個のファイルを条件に応じて処理するなら、CLIの組み合わせ以外に現実的な手段はない。

### 第二の優位性：再現性（Reproducibility）

CLIの操作はテキストだ。テキストであるから、記録できる。

```bash
# この操作は「記録」であり「手順書」であり「実行可能コード」である
grep -r "TODO" src/ | grep -v node_modules | sort > todo-list.txt
```

この1行は三つの性質を同時に持っている。まず、何を行ったかの**記録**だ。次に、同じことを再度行うための**手順書**だ。そして、コピーして実行すればまったく同じ結果を得られる**実行可能コード**だ。

GUIの操作にはこの三重の性質がない。GUIでファイルを整理する操作は、操作者の頭の中にしか残らない。翌日同じ操作をしたければ、記憶を頼りに手作業をやり直す。新しいチームメンバーに引き継ぐには、スクリーンショット付きの手順書を作成する必要がある。その手順書は「実行可能」ではない。人間が読んで、手で再現するものだ。

```
再現性の比較:

  GUIの操作:
    1. フォルダを開く（操作は記憶の中）
    2. メニューから「並べ替え」を選ぶ（手順書が必要）
    3. 条件を設定する（スクリーンショットが必要）
    4. 結果を確認する（再現には手作業が必要）
    → 記録: 困難（画面録画？）
    → 再現: 手作業
    → 自動化: 非常に困難

  CLIの操作:
    $ find . -name "*.md" -mtime -7 | sort -t/ -k3
    → 記録: コマンド自体が記録
    → 再現: コマンドをコピーして実行
    → 自動化: スクリプトに組み込むだけ
```

この再現性は、科学的研究においてもCLIが不可欠とされる理由だ。データ分析のパイプラインをシェルスクリプトやMakefileとして記録すれば、同じデータから同じ結果を再現できる。GUIツールで行った分析を第三者が再現するのは、操作の一つひとつを正確に再現する必要があるため、はるかに困難だ。

### 第三の優位性：リモート操作の容易性

SSHの節で述べたように、CLIはリモート操作において圧倒的に有利だ。

テキストストリームの帯域コストは極めて小さい。コマンドの入力は数十バイト、出力も通常は数キロバイトだ。対して、GUIリモートデスクトップは画面全体のピクセルデータを転送する。解像度1920x1080のフルカラー画面を秒間30フレーム転送すれば、数Mbpsの帯域を消費する。圧縮技術の進歩でこの差は縮まったが、構造的な非対称は残っている。

```
帯域消費の比較（概算）:

  SSH (CLIセッション):
    入力: 数十バイト/秒（キーストローク）
    出力: 数KB〜数十KB/秒（コマンド出力）
    レイテンシ耐性: 高い（200ms程度まで実用的）

  RDP/VNC (GUIリモートデスクトップ):
    転送: 数Mbps（画面更新に依存）
    レイテンシ耐性: 低い（100ms超で操作感が著しく悪化）

  → 低帯域・高レイテンシ環境ではCLIが圧倒的に有利
  → 海外リージョンのサーバ管理、モバイル回線でのアクセス
```

この特性は、クラウドの普及とともに決定的な重要性を帯びた。東京のオフィスからUS East（バージニア）のAWSインスタンスを管理する。RTT（Round Trip Time）は150ms前後だ。SSHなら全く問題ない。GUIリモートデスクトップなら、マウスカーソルの動きが遅延して操作が困難になる。

### 第四の優位性：バージョン管理との親和性

CLIの操作はテキストだ。設定ファイルもテキストだ。スクリプトもテキストだ。テキストはGitで管理できる。

```bash
# Terraformの設定変更を差分として確認
git diff main.tf
# 変更前:
#   instance_type = "t2.micro"
# 変更後:
#   instance_type = "t2.small"
```

この差分はコードレビューできる。「なぜインスタンスタイプを変更したのか」をプルリクエストのコメントで議論できる。問題があればrevertできる。

GUIの設定画面で行った変更は、この「差分」「レビュー」「revert」の対象にならない。管理画面のボタンをクリックしてインスタンスタイプを変更した場合、その操作の記録は（監査ログがあれば）残るが、「なぜ変更したか」のコンテキストは失われる。

```
バージョン管理の比較:

  CLIベース（テキストファイル + Git）:
    1. 変更をコードとして記述
    2. git diff で差分を確認
    3. Pull Requestでコードレビュー
    4. CI/CDで自動テスト
    5. マージしてデプロイ
    6. 問題があればgit revertで即座に元に戻す
    → 変更の理由、レビュー、テスト、ロールバックが一貫したワークフロー

  GUIベース（管理画面操作）:
    1. 管理画面にログイン
    2. 設定項目を目視で確認
    3. 値を変更してボタンをクリック
    4. 監査ログに操作が記録される（かもしれない）
    5. 問題があれば手動で元の値に戻す
    → 変更の理由は別途ドキュメントに記録する必要がある
    → ロールバックは手作業
```

2024年のDORA State of DevOps Reportは、39,000人以上の専門家を調査し、トップパフォーマーの特性を分析した。デプロイの自動化、小さなバッチサイズ、手動プロセスの排除が高パフォーマンスの鍵だと結論づけている。デプロイパイプラインに手動タスクがあるとデプロイ頻度が下がり、バッチサイズが増大し、リスクが高まるという悪循環が生じる。

この「手動タスクの排除」は、GUIの操作をCLIのスクリプトに置き換えることそのものだ。

---

## 4. ヘッドレス環境――GUIが存在しない世界

CLIが死なない理由の中で、見落とされがちだが決定的なものがある。**GUIが物理的に存在しない環境**の存在だ。

### CI/CDという「画面のない世界」

ソフトウェアのビルド、テスト、デプロイを自動化するCI/CD（Continuous Integration / Continuous Delivery）環境には、ディスプレイがない。キーボードもマウスもない。あるのはCPU、メモリ、ストレージ、ネットワークだけだ。

Jenkins（前身のHudsonは2005年にSun MicrosystemsのKohsuke Kawaguchiが開発）は、CI/CD市場の初期の支配者だった。2010年にはCI市場の推定70%を占有していたとされる。GitHub Actions（2019年GA）、GitLab CI、CircleCIといったモダンなCI/CDプラットフォームもすべて同じ原則に従う。**ワークフローの定義はYAMLなどのテキストファイルで行い、実行されるのはCLIコマンドだ。**

```yaml
# GitHub Actionsの設定例
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm install
      - run: npm test
      - run: npm run build
```

この設定ファイルの中身を見てほしい。`npm install`、`npm test`、`npm run build`。すべてCLIコマンドだ。CI/CD環境が実行するのは、人間がターミナルで打つのと同じコマンドだ。ここにGUIの出る幕はない。

CI/CDの普及は、CLIの存在意義を根本的に変えた。CLIは「人間がコンピュータと対話するためのインターフェース」から、「コンピュータがコンピュータに指示を出すためのインターフェース」にもなった。人間が介在しない自動化パイプラインにおいて、GUIは原理的に使用できない。テキストコマンドだけが、この世界の共通言語だ。

### コンテナの中の世界

Dockerコンテナの中には、デフォルトではGUIが存在しない。

```bash
docker run -it ubuntu:24.04 bash
```

このコマンドで起動されるのは、最小限のLinux環境だ。Xサーバもウィンドウマネージャもない。bash（あるいはsh）とcoreutils。それだけだ。コンテナ内でアプリケーションを構築し、テストし、デプロイするすべての操作はCLIで行う。

コンテナ技術の普及は、「GUIなしの環境」を日常化した。開発者が書くDockerfileの中身は、CLIコマンドの集合だ。

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --production
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

`COPY`、`RUN`、`CMD`。Dockerfileの命令はすべてCLI操作の宣言的な表現だ。コンテナの世界は、GUIが存在しないCLIネイティブの世界である。

### クラウドのAPIはテキストだ

AWS、Google Cloud、Azureのクラウドプロバイダは、GUIの管理コンソールを提供している。だが、その管理コンソールの裏側で動いているのはREST APIだ。そしてREST APIを叩く最も直接的な手段は、CLIツールだ。

```bash
# AWS CLI
aws ec2 describe-instances --filters "Name=tag:Environment,Values=production"

# Google Cloud CLI
gcloud compute instances list --filter="labels.env=production"

# Azure CLI
az vm list --resource-group production --output table
```

クラウドプロバイダがGUI管理コンソールを提供しつつ、同時にCLIツールを提供し続けるのはなぜか。管理コンソールは「何があるかを確認する」には便利だ。だが、「100個のインスタンスの設定を一括変更する」「毎朝6時にレポートを生成する」「障害時に自動的にフェイルオーバーする」といったタスクには、CLIとスクリプトが不可欠だ。

---

## 5. WIMPの限界――GUIが超えられない壁

### メタファーの限界

前回引用したNeal Stephensonの指摘を、ここでさらに掘り下げる。

GUIはメタファーで動く。デスクトップはオフィスの机。フォルダはファイルキャビネット。ゴミ箱は紙くず入れ。このメタファーは直感的だが、メタファーが表現できない操作はGUIでは実行できない。

「机の上にある書類のうち、先週更新されたものだけを取り出し、タイトル行を抽出し、アルファベット順に並べて一覧を作る」。現実のオフィスでこの操作を行うには、1枚1枚手で確認するしかない。GUIのファイルマネージャでも、基本的には同じだ。

CLIなら:

```bash
find . -name "*.md" -mtime -7 -exec head -1 {} \; | sort
```

この操作は、デスクトップのメタファーには存在しない。メタファーの世界には「パイプ」がない。「正規表現」がない。「ループ」がない。

WIMP（Windows, Icons, Menus, Pointer）パラダイムは、GUIの基本設計だ。ウィンドウ、アイコン、メニュー、ポインタ。この4要素で構成される操作モデルは、第11回で分析した「直接操作」の原則を体現している。だが、WIMPには構造的な限界がある。

第一に、**メニューとダイアログの階層的ナビゲーション**。複雑な操作を行うには、メニューを開き、サブメニューを辿り、ダイアログボックスで設定し、OKボタンを押す。この多段階のナビゲーションは、CLIの1行コマンドと比較して、エキスパートにとって明らかに非効率だ。

第二に、**操作の組み合わせの不可能性**。GUIアプリケーションAの出力を、GUIアプリケーションBの入力にそのまま流し込むことは、通常できない。コピー&ペーストは可能だが、それは「人間が手動で中継する」操作であり、自動化できない。

第三に、**操作のスクリプト化の困難さ**。GUIの操作を「記録」して「再生」するツールは存在する（マクロレコーダー、Selenium、RPA）。だが、これらは画面上の座標やUI要素の識別に依存するため、UIの変更に脆弱だ。ボタンの位置が変わっただけで、マクロが壊れる。CLIのスクリプトは、コマンドの名前とオプションが変わらない限り動作し続ける。

```
WIMPパラダイムの構造的限界:

  1. 組み合わせ不可能性
     GUI: アプリA → [コピペ] → アプリB → [コピペ] → アプリC
     CLI: cmdA | cmdB | cmdC

  2. スクリプト化の困難
     GUI: UIマクロ → UIが変更されると壊れる
     CLI: シェルスクリプト → コマンド仕様が安定している限り動く

  3. スケーラビリティの欠如
     GUI: 1ファイルの操作 → 直感的
          100ファイルの操作 → 100回クリック
          10,000ファイルの操作 → 非現実的
     CLI: 1ファイルの操作 → 1コマンド
          100ファイルの操作 → 同じ1コマンド
          10,000ファイルの操作 → 同じ1コマンド
```

### テキストストリームの普遍性

これらの構造的優位性の根底にあるのは、「テキストストリーム」という抽象の普遍性だ。

テキストは最も汎用的なデータ形式だ。どの言語でも読み書きでき、どのOSでも処理でき、どのネットワークプロトコルでも転送できる。テキストはスキーマレスだ。送り手と受け手が事前に型を合意する必要がない。grepの出力はsedに渡せる。sedの出力はawkに渡せる。awkの出力はcurlに渡せる。

この「テキストなら何でもつなげる」という性質こそが、第7回で分析したDoug McIlroyのUNIXパイプの設計思想の核心であり、50年経った今も有効な理由だ。

第10回でUNIX哲学の限界を検証した。構造化データの扱いにおいて、テキストパイプラインは確かに脆弱だ。だが、その限界を差し引いてもなお、テキストストリームの普遍性はGUIのメタファーの限界を凌駕する。テキストは「何でもつなげる」。メタファーは「設計者が想定した範囲内でしかつなげない」。

---

## 6. ハンズオン：GUIでは再現できないタスクをCLIで体験する

### 環境構築

```bash
# Docker環境で実行（ubuntu:24.04ベース）
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：100個のMarkdownファイルからパターンを抽出してCSVに変換

この演習の目的は、CLIの「組み合わせ可能性」と「再現性」を同時に体感することだ。同じタスクをGUIで行おうとしたときの困難さを想像しながら進めてほしい。

```bash
# テスト環境のセットアップ
mkdir -p /tmp/cli-power/docs && cd /tmp/cli-power/docs

# 100個のMarkdownファイルを生成
for i in $(seq -w 1 100); do
    category=$(echo "frontend backend infrastructure testing" | tr ' ' '\n' | shuf -n 1)
    priority=$((RANDOM % 3 + 1))
    status=$(echo "draft review published" | tr ' ' '\n' | shuf -n 1)

    cat > "doc_${i}.md" << INNEREOF
---
title: Document ${i}
category: ${category}
priority: ${priority}
status: ${status}
date: 2026-$(printf '%02d' $((RANDOM % 12 + 1)))-$(printf '%02d' $((RANDOM % 28 + 1)))
---

# Document ${i}: Sample Content

This is a sample document for the ${category} category.
Priority level: ${priority}
Current status: ${status}
INNEREOF
done

echo "--- 100個のMarkdownファイルを生成 ---"
ls | head -5
echo "...（合計 $(ls | wc -l) 個）"
```

```bash
# タスク: 全ファイルからメタデータを抽出し、CSVに変換する

echo "--- メタデータ抽出とCSV変換 ---"
echo ""

# CSVヘッダを出力
echo "filename,title,category,priority,status,date"

# 各ファイルからYAML frontmatterを解析してCSVに変換
for f in doc_*.md; do
    title=$(grep "^title:" "$f" | sed 's/^title: //')
    category=$(grep "^category:" "$f" | sed 's/^category: //')
    priority=$(grep "^priority:" "$f" | sed 's/^priority: //')
    status=$(grep "^status:" "$f" | sed 's/^status: //')
    date=$(grep "^date:" "$f" | sed 's/^date: //')
    echo "${f},${title},${category},${priority},${status},${date}"
done > /tmp/cli-power/metadata.csv

echo "--- 生成されたCSV（先頭10行）---"
head -11 /tmp/cli-power/metadata.csv
echo ""
echo "合計行数: $(wc -l < /tmp/cli-power/metadata.csv)"
```

GUIのファイルマネージャで同じタスクを行うことを想像してほしい。100個のMarkdownファイルを一つひとつ開き、frontmatterの各項目を手動でコピーし、Excelのセルに貼り付ける。1ファイルあたり30秒としても50分かかる。CLIなら数秒だ。

### 演習2：抽出データの分析パイプライン

```bash
cd /tmp/cli-power

echo "=== 抽出データの分析 ==="
echo ""

# カテゴリ別の文書数
echo "--- カテゴリ別文書数 ---"
tail -n +2 metadata.csv | cut -d',' -f3 | sort | uniq -c | sort -rn
echo ""

# ステータス別の文書数
echo "--- ステータス別文書数 ---"
tail -n +2 metadata.csv | cut -d',' -f5 | sort | uniq -c | sort -rn
echo ""

# 優先度1（最高）のdraft状態の文書一覧
echo "--- 優先度1のdraft文書（要対応）---"
tail -n +2 metadata.csv | awk -F',' '$4 == 1 && $5 == "draft" {print $1, $2}'
echo ""

# カテゴリ別・ステータス別のクロス集計
echo "--- カテゴリ別・ステータス別クロス集計 ---"
echo "category,draft,review,published"
for cat in frontend backend infrastructure testing; do
    draft=$(tail -n +2 metadata.csv | awk -F',' -v c="$cat" '$3==c && $5=="draft"' | wc -l)
    review=$(tail -n +2 metadata.csv | awk -F',' -v c="$cat" '$3==c && $5=="review"' | wc -l)
    published=$(tail -n +2 metadata.csv | awk -F',' -v c="$cat" '$3==c && $5=="published"' | wc -l)
    echo "${cat},${draft},${review},${published}"
done
```

```bash
echo ""
echo "=== この分析パイプラインの特性 ==="
echo ""
echo "1. 組み合わせ可能性:"
echo "   grep, sed, awk, cut, sort, uniq, wc"
echo "   → 7つのツールの組み合わせで複合分析が可能"
echo "   → GUIスプレッドシートでも可能だが、100個のファイルを"
echo "     手動で開いてコピーする前処理がボトルネック"
echo ""
echo "2. 再現性:"
echo "   このスクリプトをファイルに保存すれば、明日も来月も"
echo "   同じ分析を同じ手順で実行できる"
echo ""
echo "3. 拡張性:"
echo "   100個が10,000個になっても、スクリプトは同じ"
echo "   GUIでの手動作業は100倍になる"
```

### 演習3：スクリプト化の威力――再現可能な分析

```bash
# 分析スクリプトとして保存
cat > /tmp/cli-power/analyze-docs.sh << 'EOF'
#!/bin/bash
set -euo pipefail

# 使い方: ./analyze-docs.sh <docs_directory>
DOCS_DIR="${1:?使い方: $0 <docs_directory>}"
OUTPUT_DIR="${2:-/tmp/analysis-$(date +%Y%m%d)}"
mkdir -p "$OUTPUT_DIR"

echo "=== ドキュメント分析レポート ==="
echo "対象: ${DOCS_DIR}"
echo "日時: $(date)"
echo "出力: ${OUTPUT_DIR}"
echo ""

# Step 1: メタデータ抽出
echo "filename,title,category,priority,status,date" > "${OUTPUT_DIR}/metadata.csv"
for f in "${DOCS_DIR}"/doc_*.md; do
    [ -f "$f" ] || continue
    fname=$(basename "$f")
    title=$(grep "^title:" "$f" | sed 's/^title: //')
    category=$(grep "^category:" "$f" | sed 's/^category: //')
    priority=$(grep "^priority:" "$f" | sed 's/^priority: //')
    status=$(grep "^status:" "$f" | sed 's/^status: //')
    date_val=$(grep "^date:" "$f" | sed 's/^date: //')
    echo "${fname},${title},${category},${priority},${status},${date_val}"
done >> "${OUTPUT_DIR}/metadata.csv"

total=$(($(wc -l < "${OUTPUT_DIR}/metadata.csv") - 1))
echo "抽出文書数: ${total}"
echo ""

# Step 2: サマリ生成
{
    echo "=== ドキュメント分析サマリ ==="
    echo "生成日時: $(date)"
    echo "対象ディレクトリ: ${DOCS_DIR}"
    echo "総文書数: ${total}"
    echo ""
    echo "--- カテゴリ別 ---"
    tail -n +2 "${OUTPUT_DIR}/metadata.csv" | cut -d',' -f3 | sort | uniq -c | sort -rn
    echo ""
    echo "--- ステータス別 ---"
    tail -n +2 "${OUTPUT_DIR}/metadata.csv" | cut -d',' -f5 | sort | uniq -c | sort -rn
    echo ""
    echo "--- 要対応（優先度1 + draft）---"
    tail -n +2 "${OUTPUT_DIR}/metadata.csv" | awk -F',' '$4 == 1 && $5 == "draft" {print $1, $2}'
} > "${OUTPUT_DIR}/summary.txt"

echo "--- サマリ ---"
cat "${OUTPUT_DIR}/summary.txt"
echo ""
echo "出力ファイル:"
ls -la "${OUTPUT_DIR}/"
EOF

chmod +x /tmp/cli-power/analyze-docs.sh

echo "--- スクリプトを実行 ---"
/tmp/cli-power/analyze-docs.sh /tmp/cli-power/docs /tmp/cli-power/output
```

```bash
echo ""
echo "=== このスクリプトがGUIに対して持つ優位性 ==="
echo ""
echo "1. 再現性:     いつ実行しても同じ手順で分析"
echo "2. 共有性:     チームメンバーにファイルを渡すだけ"
echo "3. バージョン管理: git commitで変更を追跡可能"
echo "4. CI/CD統合:  GitHub Actionsから自動実行可能"
echo "5. スケール:   100個でも10,000個でも同じスクリプト"
echo ""
echo "GUIの優位性:"
echo "  - 結果の可視化（グラフ、チャート）"
echo "  - 対話的なデータ探索"
echo "  - 操作の学習コストが低い"
echo ""
echo "→ 「どちらが優れているか」ではなく"
echo "   「どの場面で何が適切か」が正しい問い"
```

ハンズオンの自動セットアップスクリプトは `handson/command-line/12-why-cli-survived/setup.sh` を参照してほしい。

---

## 7. まとめと次回予告

### この回の要点

第一に、SSHの普及（1995年、Tatu Ylonen）がCLIとリモート管理を不可分にした。テキストストリームの帯域効率は、GUIリモートデスクトップに対して圧倒的に優位だ。OpenSSH（1999年）の登場以降、リモートサーバ管理はCLIを前提とする世界となった。

第二に、Infrastructure as Codeの系譜――CFEngine（1993年）、Puppet（2005年）、Chef（2009年）、Ansible（2012年）――は、すべてCLIとテキストファイルを主要インターフェースとして採用した。インフラの状態をコードとして記述し、バージョン管理し、自動適用するにはテキストが不可欠であり、GUIでは代替できなかった。

第三に、Docker CLI（2013年）、kubectl（2014年）、Terraform（2014年）がCLIを開発ワークフローの中心に引き戻した。2013年から2015年はCLIの「再征服」の時期であり、クラウドネイティブ時代においてCLIは「唯一合理的な選択」として復権した。

第四に、CLIの構造的優位性は4つに整理できる。（1）組み合わせ可能性（composability）：テキストストリームを介した無限の組み合わせ。（2）再現性（reproducibility）：コマンドが記録・手順書・実行可能コードの三重の性質を持つ。（3）リモート操作の容易性：低帯域・高レイテンシ環境での圧倒的優位。（4）バージョン管理との親和性：差分、レビュー、ロールバックが一貫したワークフロー。

第五に、CI/CD環境やDockerコンテナという「GUIが物理的に存在しない」ヘッドレス環境の普及が、CLIの存在を不可逆的なものにした。人間が介在しない自動化パイプラインにおいて、テキストコマンドは唯一の共通言語だ。

### 冒頭の問いへの暫定回答

40年間「死ぬ」と言われ続けたCLIが、なぜ開発者の基本ツールであり続けるのか。

暫定的な答えはこうだ。**CLIの生存は「ノスタルジー」ではなく「テキストストリーム」という抽象の構造的優位性に根ざしている。** テキストは組み合わせ可能であり、再現可能であり、低帯域で転送可能であり、バージョン管理可能だ。GUIはこれらの特性を構造的に持たない。GUIの「発見しやすさ」はCLIの「組み合わせやすさ」と相補的な関係にあり、一方が他方を置き換えることはできない。

そして、CI/CD、コンテナ、クラウドAPIという「GUIが存在しない世界」の拡大が、CLIの存在を不可逆にした。CLIは人間のためだけのインターフェースではなく、コンピュータがコンピュータに指示を出すためのインターフェースでもある。この二重の役割は、GUIには果たせない。

### 次回予告

次回、第13回「CLIとGUIの融合――IDEのターミナル、GUIのコマンドパレット」では、CLIとGUIの対立を超えた「融合」の動きを追う。

VS CodeのCommand Palette、EmacsのM-xコマンド、Sublime Textのfuzzy finder。これらはGUIの皮をかぶったCLIであり、CLIの「想起」問題をGUIの「再認」で補完するハイブリッド設計だ。最も生産性が高いインターフェースは、CLIの組み合わせ可能性とGUIの発見可能性を融合したものかもしれない。

あなたは、自分が毎日使っているツールの中に、CLIとGUIの融合がどれだけ進んでいるか、意識したことがあるだろうか。

---

## 参考文献

- Tatu Ylonen, SSH History, O'Reilly "SSH, The Secure Shell: The Definitive Guide, 2nd Edition", <https://www.oreilly.com/library/view/ssh-the-secure/0596008953/ch01s05.html>
- OpenSSH Project History, <https://www.openssh.org/history.html>
- Wikipedia, "Docker (software)", <https://en.wikipedia.org/wiki/Docker_(software)>
- Kubernetes Official Blog, "10 Years of Kubernetes", June 2024, <https://kubernetes.io/blog/2024/06/06/10-years-of-kubernetes/>
- Google Cloud Blog, "From Google to the world: the Kubernetes origin story", <https://cloud.google.com/blog/products/containers-kubernetes/from-google-to-the-world-the-kubernetes-origin-story>
- HashiCorp, "The Story of HashiCorp Terraform with Mitchell Hashimoto", <https://www.hashicorp.com/en/resources/the-story-of-hashicorp-terraform-with-mitchell-hashimoto>
- Wikipedia, "Terraform (software)", <https://en.wikipedia.org/wiki/Terraform_(software)>
- Wikipedia, "Puppet (software)", <https://en.wikipedia.org/wiki/Puppet_(software)>
- Wikipedia, "Ansible (software)", <https://en.wikipedia.org/wiki/Ansible_(software)>
- DORA, "Accelerate State of DevOps Report 2024", <https://dora.dev/research/2024/dora-report/>
- Wikipedia, "WIMP (computing)", <https://en.wikipedia.org/wiki/WIMP_(computing)>
- Neal Stephenson, "In the Beginning was the Command Line", 1999, <https://www.nealstephenson.com/in-the-beginning-was-the-command-line.html>
- The New Stack, "A Brief DevOps History: The Roots of Infrastructure as Code", <https://thenewstack.io/a-brief-devops-history-the-roots-of-infrastructure-as-code/>
- GitHub, "What is GitHub Actions?", <https://resources.github.com/devops/tools/automation/actions/>
- AWS CLI Documentation, <https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-welcome.html>
