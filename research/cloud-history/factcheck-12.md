# ファクトチェック記録：第12回「マルチテナント設計——クラウドの核心イノベーション」

調査実施日：2026-02-24

---

## 1. Salesforce マルチテナントアーキテクチャ（1999年）

- **結論**: Salesforceは1999年3月8日、Marc Benioff、Parker Harris、Dave Moellenhoff、Frank Dominguezの4名により設立。サンフランシスコのテレグラフヒル、1449 Montgomery Streetの賃貸アパートで創業。マルチテナントアーキテクチャを採用し、全顧客のデータを共通のデータベーステーブルに格納、OrgIDで論理的に分離するメタデータ駆動型設計。「The End of Software」「NO SOFTWARE」をスローガンに掲げ、2000年2月7日にサンフランシスコのRegency Theaterで正式ローンチイベントを開催（1,500人参加）。
- **一次ソース**: Salesforce, "The History of Salesforce", Salesforce Newsroom; Salesforce Architects, "Platform Multitenant Architecture"
- **URL**: <https://www.salesforce.com/news/stories/the-history-of-salesforce/> / <https://architect.salesforce.com/fundamentals/platform-multitenant-architecture>
- **注意事項**: Force.comプラットフォームとして体系化されたのは後年。設立日（1999年3月8日）とローンチイベント（2000年2月7日）を混同しないこと。
- **記事での表現**: 1999年3月、元Oracle幹部のMarc Benioffは、Parker Harrisらと共にSalesforceを設立した。全顧客のデータを単一のデータベースに格納し、OrgIDで論理的に分離するマルチテナントアーキテクチャを採用。「The End of Software」というスローガンとともに、SaaSモデルのマルチテナント設計の原型を確立した。

---

## 2. Spectre/Meltdown脆弱性（2018年）

- **結論**: 2018年1月3日に公開（当初の協調開示予定日は1月9日だったが前倒し）。Jann Horn（Google Project Zero）が2017年6月1日にIntel等に報告。CVE番号はMeltdown: CVE-2017-5754、Spectre: CVE-2017-5753（Variant 1）およびCVE-2017-5715（Variant 2）。Meltdownの発見者は3グループが独立に発見: Jann Horn（Google Project Zero）、Werner HaasとThomas Prescher（Cyberus Technology）、Daniel Grussら（グラーツ工科大学）。KPTI（Kernel Page Table Isolation）パッチの性能影響はワークロードにより5-30%。AWSは2018年1月4日からEC2 HVMインスタンスへのライブパッチを開始。
- **一次ソース**: CISA, "Meltdown and Spectre Side-Channel Vulnerability Guidance", 2018; Brendan Gregg, "KPTI/KAISER Meltdown Initial Performance Regressions", 2018
- **URL**: <https://www.cisa.gov/news-events/alerts/2018/01/04/meltdown-and-spectre-side-channel-vulnerability-guidance> / <https://www.brendangregg.com/blog/2018-02-09/kpti-kaiser-meltdown-performance.html>
- **注意事項**: CVE番号が「2017」なのは報告時期が2017年のため。PVインスタンスは再起動が必要だった。syscall頻度の高い処理ほど影響大。
- **記事での表現**: 2018年1月3日、Meltdown（CVE-2017-5754）とSpectre（CVE-2017-5753、CVE-2017-5715）が公開された。プロセッサの投機的実行に起因するこれらの脆弱性は、マルチテナント環境において、ハードウェアレベルの隔離の限界を実証した。ソフトウェア緩和策（KPTI）は5-30%の性能劣化を伴った。

---

## 3. AWS Firecracker（2018年）

- **結論**: 2018年11月、AWS re:Inventで発表・オープンソース化（Apache License 2.0）。Rustで記述されたVMM。Linux KVM上で動作するmicroVMを提供。Chromium OSのcrosvmからフォーク。起動時間125ms未満、メモリオーバーヘッド5MiB未満。AWS LambdaとFargateの基盤として使用。ベアメタルインスタンス上で数千のmicroVMを実行可能。
- **一次ソース**: AWS Open Source Blog, "Announcing the Firecracker Open Source Technology", 2018; AWS News Blog, "Firecracker - Lightweight Virtualization for Serverless Computing", 2018
- **URL**: <https://aws.amazon.com/blogs/opensource/firecracker-open-source-secure-fast-microvm-serverless/> / <https://aws.amazon.com/blogs/aws/firecracker-lightweight-virtualization-for-serverless-computing/>
- **注意事項**: 完全な仮想マシンではなく最小限の機能のmicroVM。ネットワークはvirtio-netのみ、ブロックデバイスはvirtio-blkのみ。GPUやPCIパススルーは非サポート。
- **記事での表現**: 2018年11月、AWSはFirecrackerをオープンソースとして公開した。Rustで記述されたこのVMMは、125ms未満で起動し5MiB未満のメモリオーバーヘッドしか消費しないmicroVMを生成する。コンテナの軽量性と仮想マシンのセキュリティ分離を両立し、LambdaおよびFargateの基盤として稼働する。

---

## 4. Noisy Neighbor問題

- **結論**: マルチテナント環境において、あるテナントが共有リソース（CPU、ディスクI/O、ネットワーク帯域等）を過剰消費し、同一物理ホスト上の他テナントの性能を劣化させる問題。CPU Steal Time（Linuxのtopコマンド「st」値）は仮想CPUが物理CPU割り当てを待機している時間の割合。5%で警戒、10%超で体感劣化。緩和策: リソースリミット/クォータ、Intel RDT、専用インスタンス/ホスト等。
- **一次ソース**: TechTarget, "What is noisy neighbor"; Microsoft Learn, "Noisy Neighbor Antipattern - Azure Architecture Center"; Site24x7, "What is CPU steal time"
- **URL**: <https://www.techtarget.com/searchcloudcomputing/definition/noisy-neighbor-cloud-computing-performance> / <https://learn.microsoft.com/en-us/azure/architecture/antipatterns/noisy-neighbor/noisy-neighbor>
- **注意事項**: CPU、ネットワーク帯域、ディスクI/O、ラストレベルキャッシュなど複数のリソース次元で発生。AWS NitroはCPUスレッドやL1/L2キャッシュを顧客間で共有しない設計。
- **記事での表現**: Noisy Neighbor問題はマルチテナント環境の根本的課題。LinuxのCPU Steal Time（topの「st」値）がこれを可視化する指標であり、10%超でアプリケーション応答性に影響。

---

## 5. AWS Nitro Systemとセキュリティ/分離

- **結論**: Nitro Systemは3コンポーネント構成: Nitro Cards（I/O仮想化）、Nitro Security Chip（ハードウェアRoot of Trust）、Nitro Hypervisor（リソース分離）。2022年公開のホワイトペーパーで「No Operator Access」設計を詳述——AWSオペレータでもEC2インスタンスのメモリやストレージにアクセス不可。暗号鍵はNitro Cardsの保護された揮発メモリにのみ平文で存在。L1/L2キャッシュやCPUスレッドを顧客間で共有しない設計。Nitro Enclavesは2019年12月発表、2020年10月28日GA。親インスタンスからCPU/メモリを物理的に分割した完全隔離VM環境。
- **一次ソース**: AWS, "The Security Design of the AWS Nitro System" whitepaper, 2022; AWS, "The EC2 approach to preventing side-channels"
- **URL**: <https://docs.aws.amazon.com/whitepapers/latest/security-design-of-aws-nitro-system/security-design-of-aws-nitro-system.html> / <https://docs.aws.amazon.com/whitepapers/latest/security-design-of-aws-nitro-system/the-ec2-approach-to-preventing-side-channels.html>
- **注意事項**: Nitroの基本アーキテクチャは第11回で扱い済み。本稿ではセキュリティ/分離の側面に焦点。
- **記事での表現**: AWSは2022年のホワイトペーパーで「No Operator Access」設計を詳述。AWSオペレータであってもインスタンスのメモリやストレージにアクセス不可。L1/L2キャッシュやCPUスレッドを顧客間で共有しない保守的な設計により、サイドチャネル攻撃を排除。

---

## 6. Linux cgroupsとnamespacesの歴史

- **結論**: Namespaces: 2002年、カーネル2.4.19にマウント名前空間（CLONE_NEWNS）導入（Plan 9にインスパイア）。PID名前空間: カーネル2.6.24（2008年）。ネットワーク名前空間: カーネル2.6.29（2009年）。ユーザ名前空間: カーネル3.8（2013年）。cgroups: 2006年にGoogleのPaul MenageとRohit Sethが「process containers」として開発開始。2007年末に「control groups」に改名。カーネル2.6.24（2008年1月）でメインラインマージ。cgroups v2はカーネル4.5で導入。
- **一次ソース**: Wikipedia, "cgroups"; Wikipedia, "Linux namespaces"; LWN.net, "Namespaces in operation, part 1", 2013
- **URL**: <https://en.wikipedia.org/wiki/Cgroups> / <https://en.wikipedia.org/wiki/Linux_namespaces>
- **注意事項**: cgroupsのマージは「2007年」とも「2008年1月」ともいえる（カーネル2.6.24の開発サイクルと正式リリース日の違い）。
- **記事での表現**: namespacesは2002年のカーネル2.4.19から段階的に導入。cgroupsは2006年にGoogleのPaul Menageらが開発開始し、2008年のカーネル2.6.24でマージ。この2つの機能の組み合わせがコンテナ技術の基盤となる。

---

## 7. メインフレームのタイムシェアリングとマルチテナンシーの起源

- **結論**: IBM CP-40は1964年末に設計開始、1967年1月に本番運用開始。Robert Creasyのリーダーシップの下、IBMケンブリッジ科学センターで開発。完全仮想化を世界で初めて実装し、単一のS/360上に14の仮想マシン環境を生成。VM/370は1972年8月2日に発表。CP（Control Program）が各ユーザに仮想マシンを割り当て、CMS（Conversational Monitor System）を実行。数百から数千の同時対話ユーザをサブ秒で処理。
- **一次ソース**: Wikipedia, "VM (operating system)"; IBM, "VM 50th Anniversary"; Wikipedia, "CP-40"
- **URL**: <https://en.wikipedia.org/wiki/VM_(operating_system)> / <https://www.vm.ibm.com/history/50th/index.html>
- **注意事項**: VM/370のマルチテナンシーは同一組織内のユーザ共有であり、現代のクラウドの異なる組織間のマルチテナンシーとは文脈が異なるが、基本概念は共通。
- **記事での表現**: 1967年、IBMケンブリッジ科学センターのRobert Creasyらが開発したCP-40は、完全仮想化を世界で初めて実装した。1972年のVM/370に至る系譜は、物理マシンを仮想的に分割し各テナントに独立した実行環境を提供するという、マルチテナンシーの原型を確立した。

---

## 8. AWS EC2の物理ホスト共有モデル

- **結論**: EC2には3つのテナンシーモデル: (1) 共有テナンシー（デフォルト、複数アカウントが物理ホスト共有）、(2) Dedicated Instances（アカウント専用の物理ハードウェア、停止・起動でホスト変更あり）、(3) Dedicated Hosts（物理サーバ全体を専有、配置制御可能、BYOLライセンス管理に有用）。Dedicated InstancesとDedicated Hostsの間に性能・セキュリティの差異はなく、違いは可視性と制御レベル。
- **一次ソース**: AWS Documentation, "Amazon EC2 Dedicated Instances"; AWS, "Amazon EC2 Dedicated Hosts FAQs"
- **URL**: <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/dedicated-instance.html> / <https://aws.amazon.com/ec2/dedicated-hosts/faqs/>
- **注意事項**: 共有テナンシーでもNitro SystemによりL1/L2キャッシュやCPUスレッドはテナント間で共有されない。Dedicated Hostsはオンデマンド・リザーブドの両方で提供。
- **記事での表現**: EC2のデフォルトは共有テナンシーで、複数顧客のインスタンスが同一物理サーバ上で稼働する。より厳格な分離が必要な場合、Dedicated Instances（アカウント専用ハードウェア）とDedicated Hosts（物理サーバ全体の専有）が選択可能。

---

## 9. gVisor（Google）サンドボックス技術

- **結論**: 2018年5月にGoogleがオープンソース公開。Go言語で記述されたユーザ空間カーネル。アプリケーションのシステムコールをSentryプロセスがインターセプトし、ホストカーネルへの直接アクセスを防ぐ。OCI準拠ランタイム「runsc」（run Sandboxed Container）を含む。2つのプラットフォーム: Ptrace、KVM。ファイルシステム操作はGoferプロセスが9Pプロトコルで処理。GKE SandboxはgVisorベース。Google内部的にApp Engine、Cloud Functions、Cloud Run等で使用。
- **一次ソース**: Google Cloud Blog, "Open-sourcing gVisor, a sandboxed container runtime", 2018; gVisor GitHub Repository
- **URL**: <https://cloud.google.com/blog/products/identity-security/open-sourcing-gvisor-a-sandboxed-container-runtime> / <https://github.com/google/gvisor>
- **注意事項**: 全システムコールを完全実装しているわけではなく非互換性あり。性能オーバーヘッドがある。GKE Sandboxの正式提供は2019年。
- **記事での表現**: 2018年5月、GoogleはgVisorを公開した。Go言語で記述されたユーザ空間カーネルが、アプリケーションのシステムコールをインターセプトし、ホストカーネルへの直接アクセスを防ぐ。仮想マシンほどのコストをかけずにコンテナの分離を強化する第三の選択肢である。

---

## 10. Kata Containers

- **結論**: 2017年12月5日、OpenStack Foundation（現Open Infrastructure Foundation）が発表。IntelのClear ContainersとHyper.shのrunVの統合。各コンテナを軽量VMとして実行し、ハイパーバイザレベルの分離を実現。コンテナ実行に必要な最小限のカーネルのみ使用。初期のデフォルトVMMはQEMU。FirecrackerをVMMとして使用するオプションもサポート。Kata Containers 3.0.0は2022年リリース。
- **一次ソース**: Business Wire, "Kata Containers Project Launches", 2017年12月5日; Kata Containers公式サイト
- **URL**: <https://www.businesswire.com/news/home/20171205005634/en/Kata-Containers-Project-Launches-to-Build-Secure-Container-Infrastructure> / <https://katacontainers.io/>
- **注意事項**: FirecrackerとKata Containersは異なるアプローチで同じ問題を解決。Kata ContainersがFirecrackerをバックエンドVMMとして使用する構成も可能。
- **記事での表現**: 2017年12月、IntelのClear ContainersとHyper.shのrunVが統合されKata Containersが誕生した。各コンテナを軽量VMとして実行し、ハイパーバイザレベルの分離を提供する。後にFirecrackerをVMMとして使用するオプションも追加された。

---

## ファクトチェック結果サマリ

| #  | 項目                       | 状態     |
| -- | -------------------------- | -------- |
| 1  | Salesforceマルチテナント   | 検証済み |
| 2  | Spectre/Meltdown           | 検証済み |
| 3  | AWS Firecracker            | 検証済み |
| 4  | Noisy Neighbor問題         | 検証済み |
| 5  | AWS Nitroセキュリティ/分離 | 検証済み |
| 6  | cgroups/namespaces歴史     | 検証済み |
| 7  | メインフレーム仮想化起源   | 検証済み |
| 8  | EC2物理ホスト共有モデル    | 検証済み |
| 9  | gVisor                     | 検証済み |
| 10 | Kata Containers            | 検証済み |

全10項目検証済み。品質ゲート（6項目以上）クリア。
