# ファクトチェック記録：第12回「なぜCLIは死ななかったのか――自動化・再現性・組み合わせの力」

## 1. SSH（Secure Shell）の歴史

- **結論**: SSH1はTatu Ylonen（ヘルシンキ工科大学研究員）が1995年に開発。大学ネットワークへのパスワードスニッフィング攻撃がきっかけ。1995年7月にフリーソフトウェアとして公開。年末までに50カ国20,000ユーザーが採用。1995年12月にSSH Communications Security Corp.を設立
- **一次ソース**: O'Reilly "SSH, The Secure Shell: The Definitive Guide, 2nd Edition", Chapter 1; machaddr.substack.com SSH origins記事
- **URL**: <https://www.oreilly.com/library/view/ssh-the-secure/0596008953/ch01s05.html>, <https://machaddr.substack.com/p/ssh-the-origins-of-how-tatu-ylonen>
- **注意事項**: ヘルシンキ工科大学（Helsinki University of Technology）は2010年にアールト大学に統合
- **記事での表現**: 1995年、ヘルシンキ工科大学のTatu Ylonenがパスワードスニッフィング攻撃への対処としてSSHを開発。年末までに50カ国20,000ユーザーに普及

## 2. OpenSSHの誕生

- **結論**: OpenSSH開発は1999年9月26日に開始。OpenBSD 2.6（1999年12月1日リリース）にOpenSSH 1.2.2として初めて同梱。Tatu YlonenのSSH 1.2.12のオープンソース版を基に、Theo de Raadtらが開発
- **一次ソース**: OpenSSH公式プロジェクト履歴
- **URL**: <https://www.openssh.org/history.html>
- **注意事項**: OpenSSHはBSDライセンスで再実装された点が重要
- **記事での表現**: 1999年、OpenBSDプロジェクトのTheo de Raadtらが自由なSSH実装としてOpenSSHを開発。以降、事実上の標準SSH実装となった

## 3. Docker CLIの初リリース

- **結論**: Docker 0.1は2013年3月にオープンソースとしてリリース。PyCon 2013（サンタクララ）で初公開。Solomon HykesがフランスのdotCloud社内プロジェクトとして開発。dotCloudはY Combinator Summer 2010で設立、2013年にDocker Inc.に改名
- **一次ソース**: Wikipedia "Docker (software)"; jpetazzo.github.io "From dotCloud to Docker"
- **URL**: <https://en.wikipedia.org/wiki/Docker_(software)>, <https://jpetazzo.github.io/2017/02/24/from-dotcloud-to-docker/>
- **注意事項**: 初期はLXCをデフォルト実行環境として使用
- **記事での表現**: 2013年3月、Solomon HykesがPyCon 2013でDocker 0.1を公開。コンテナ管理のCLIツールとして登場

## 4. Kubernetesとkubectlの歴史

- **結論**: Kubernetes は2014年6月6日にGoogleが発表。DockerCon 2014（6月10日）でEric Brewerが発表。開発者はJoe Beda、Brendan Burns、Craig McLuckie。GoogleのBorgクラスタマネージャに触発。v1.0は2015年7月21日リリース。CNCFの最初のシード技術として提供
- **一次ソース**: Kubernetes公式ブログ "10 Years of Kubernetes"; Google Cloud Blog
- **URL**: <https://kubernetes.io/blog/2024/06/06/10-years-of-kubernetes/>, <https://cloud.google.com/blog/products/containers-kubernetes/from-google-to-the-world-the-kubernetes-origin-story>
- **注意事項**: kubectlはKubernetes本体と同時にリリース。単独のリリース日は不明
- **記事での表現**: 2014年6月、GoogleがKubernetesを発表。kubectlコマンドを通じてコンテナオーケストレーションを操作する設計

## 5. Infrastructure as Codeの起源

- **結論**: 概念の起源はCFEngine（1993年、Mark Burgess）。用語としての"Infrastructure as Code"は2007-2009年頃に定着。Andrew Clay-Shafer、Adam Jacob（Chef共同創設者）、Luke Kanies（Puppet創設者）らが使用。AWS EC2の登場（2006年）とRuby on Rails 1.0がスケーリング問題を顕在化させ、IaCの必要性を加速
- **一次ソース**: The New Stack "A Brief DevOps History: The Roots of Infrastructure as Code"; Wikipedia "Infrastructure as code"
- **URL**: <https://thenewstack.io/a-brief-devops-history-the-roots-of-infrastructure-as-code/>, <https://en.wikipedia.org/wiki/Infrastructure_as_code>
- **注意事項**: IaCの明確な「命名者」は特定できない
- **記事での表現**: Infrastructure as Codeの概念はCFEngine（1993年）に遡るが、用語として定着したのは2000年代後半。クラウドの普及がCLIによるインフラ管理を必然にした

## 6. Terraformの初リリース

- **結論**: Terraform 0.1は2014年7月にリリース。Mitchell HashimotoとArmon Dadgarが2012年に設立したHashiCorp社が開発。初期はAWSとDigitalOceanのみ対応。AWSのCloudFormation（2011年）に対する「オープンソースでクラウドに依存しない代替」として構想
- **一次ソース**: HashiCorp公式ブログ; Wikipedia "Terraform (software)"
- **URL**: <https://www.hashicorp.com/en/resources/the-story-of-hashicorp-terraform-with-mitchell-hashimoto>, <https://en.wikipedia.org/wiki/Terraform_(software)>
- **注意事項**: Terraform 1.0は2021年6月にGA
- **記事での表現**: 2014年7月、HashiCorpがTerraform 0.1をリリース。CLIからクラウドインフラを宣言的に定義・管理するツール

## 7. 構成管理ツールの系譜（Puppet, Ansible）

- **結論**: Puppet: 2005年にLuke Kaniesが設立。Rubyで記述された宣言的構成管理ツール。最初の資金調達は2009年。Ansible: 2012年2月にMichael DeHaanがオープンソースとして公開。エージェントレスアーキテクチャ。2015年にRed Hatが買収
- **一次ソース**: Wikipedia "Puppet (software)"; Wikipedia "Ansible (software)"
- **URL**: <https://en.wikipedia.org/wiki/Puppet_(software)>, <https://en.wikipedia.org/wiki/Ansible_(software)>
- **注意事項**: Chef（2009年、Adam Jacob）もこの系譜に含まれる
- **記事での表現**: Puppet（2005年）、Chef（2009年）、Ansible（2012年）と続く構成管理ツールの系譜は、すべてCLIを主要インターフェースとして採用

## 8. Jenkins（CI/CD）の歴史

- **結論**: Hudson（Jenkinsの前身）は2004年夏にSun MicrosystemsのKohsuke Kawaguchiが開発、2005年2月に初リリース。2010年にはCI市場の推定70%を占有。OracleによるSun買収後の2011年1月にHudsonからJenkinsに改名。コミュニティ投票で承認
- **一次ソース**: Wikipedia "Kohsuke Kawaguchi"; CloudBees "What is Jenkins?"
- **URL**: <https://en.wikipedia.org/wiki/Kohsuke_Kawaguchi>, <https://www.cloudbees.com/blog/what-is-jenkins>
- **注意事項**: OracleはHudsonの開発継続を表明し、JenkinsとHudsonは一時的に並存
- **記事での表現**: CI/CDツールの代表格であるJenkins（2011年、前身Hudsonは2005年）は、ビルド・テスト・デプロイの自動化をCLIで制御する

## 9. GitHub Actionsの登場

- **結論**: 2018年10月のGitHub Universeで発表。2019年11月13日にGA。YAML定義によるワークフロー自動化。ヘッドレス環境でのCI/CD実行
- **一次ソース**: GitHub公式; Wikipedia "GitHub"
- **URL**: <https://resources.github.com/devops/tools/automation/actions/>, <https://en.wikipedia.org/wiki/GitHub>
- **注意事項**: 発表は2018年だがGAは2019年
- **記事での表現**: GitHub Actions（2019年GA）のようなCI/CD環境はGUIが存在しないヘッドレス環境。CLIが唯一のインターフェースとなる

## 10. AWS CLIの歴史

- **結論**: AWS CLI v1は2013年9月2日にGA。複数のAWSサービスをコマンドラインから一元管理するための統合ツール
- **一次ソース**: AWS CLI公式ドキュメント; GitHub aws/aws-cli
- **URL**: <https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-welcome.html>, <https://github.com/aws/aws-cli>
- **注意事項**: v2は2020年にリリース
- **記事での表現**: AWS CLI（2013年GA）は、クラウドリソースの管理をCLIに一元化した象徴的なツール

## 11. WIMPパラダイムの限界

- **結論**: WIMP（Windows, Icons, Menus, Pointer）はGUIの主要パラダイム。限界として: (1) メニュー・ダイアログの階層的ナビゲーションによる時間損失、(2) パイプ処理やバッチ処理の自動化が困難、(3) 3次元以上の入力に不向き、(4) アクセシビリティの問題
- **一次ソース**: Wikipedia "WIMP (computing)"; Interaction Design Foundation
- **URL**: <https://en.wikipedia.org/wiki/WIMP_(computing)>, <https://www.interaction-design.org/literature/book/the-glossary-of-human-computer-interaction/wimp>
- **注意事項**: Post-WIMPの議論は2010年代から活発化
- **記事での表現**: WIMPパラダイムは発見性に優れるが、コンポーザビリティとスクリプト化において構造的な限界を持つ

## 12. DORA State of DevOps Report

- **結論**: 2024年DORAレポート（第10回）で39,000人以上を調査。トップパフォーマーはオンデマンドでデプロイし、小さなバッチサイズを維持し、自動化によってリスクを除去。手動タスクがデプロイパイプラインにあるとデプロイ頻度が下がるという悪循環
- **一次ソース**: Google Cloud DORA 2024 State of DevOps Report
- **URL**: <https://dora.dev/research/2024/dora-report/>
- **注意事項**: AI活用はバッチサイズの増大と相関し、むしろパフォーマンス低下と関連するという知見もある
- **記事での表現**: DORAの調査が示すように、デプロイの自動化とCLIツールの活用は高パフォーマンスの開発チームの共通特性である
