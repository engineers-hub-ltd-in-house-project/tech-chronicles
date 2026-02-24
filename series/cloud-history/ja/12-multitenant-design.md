# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第12回：マルチテナント設計——クラウドの核心イノベーション

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- マルチテナンシーがクラウドのコスト効率の源泉であると同時に、最大のリスクでもある二面性
- メインフレームのCP-40/VM/370（1967年〜1972年）から現代のクラウドまで、マルチテナンシーの系譜
- Salesforce（1999年）がSaaSモデルで確立したマルチテナントアーキテクチャの原型
- Noisy Neighbor問題のメカニズムとCPU Steal Time
- Spectre/Meltdown（2018年1月）がマルチテナント環境に突きつけた根本的問い
- 計算・ストレージ・ネットワークの3軸における隔離設計
- AWS Nitro Systemの「No Operator Access」設計とテナント間分離
- Firecracker（2018年）——マイクロVMによる軽量かつ安全な隔離
- gVisor、Kata Containers——コンテナ時代の隔離技術の選択肢
- cgroupsとnamespaceを使った簡易マルチテナント環境の構築ハンズオン

---

## 1. 隣人の顔が見えない部屋

私が「Noisy Neighbor」という言葉の意味を身体で理解したのは、2013年のある水曜日の午後だった。

運用中のWebサービスが、突然レスポンスタイムの急激な悪化を見せた。アプリケーションのコードは変えていない。デプロイもしていない。データベースのクエリプランにも異常はない。だがEC2インスタンス上でtopコマンドを叩くと、見慣れない数字が目に入った。CPU Steal Time——「st」の値が15%を超えている。

CPU Steal Timeとは、仮想CPUが物理CPUの割り当てをハイパーバイザから待機している時間の割合だ。同じ物理ホスト上の「誰か」がCPUを占有しているため、自分のインスタンスが順番待ちをしている。その「誰か」が誰なのか、私には知る術がない。

これがマルチテナンシーの現実だ。クラウドの料金が安いのは、物理ホストを複数の顧客で共有しているからだ。この「同居」がクラウドのコスト効率の源泉であり、同時に最大の設計課題でもある。

前回、IaaSの本質を「抽象化のレイヤー」として読み解いた。計算・ストレージ・ネットワークの三本柱が、APIで統合的に制御可能な「プログラマブルインフラ」を構成している。だが、抽象化の裏側で最も重要な設計判断が行われている場所がある。それが、マルチテナント設計だ。

なぜ複数のテナントが一台の物理マシンを共有できるのか。その共有はどこまで安全なのか。隔離の限界はどこにあるのか。この回では、クラウドの核心イノベーションであるマルチテナンシーの光と影を、技術の根底まで掘り下げる。

あなたの仮想マシンの「隣人」が誰なのか——考えたことはあるだろうか。

---

## 2. マルチテナンシーの系譜——メインフレームからクラウドへ

### 仮想マシンの原点——CP-40とVM/370

マルチテナンシーの思想は、クラウドコンピューティングよりも遥かに古い。その起源は、第2回で触れたメインフレームの時代に遡る。

1964年末、IBMケンブリッジ科学センター（Cambridge Scientific Center）のRobert Creasyは、MITおよびリンカーン研究所の研究者と協力し、CP-40（Control Program-40）の設計を開始した。1967年1月に本番運用を開始したCP-40は、完全仮想化を世界で初めて実装したオペレーティングシステムであった。単一のIBM System/360上に14の仮想マシン環境を生成し、各ユーザに対してあたかも専用の計算機を提供するかのように振る舞った。

この系譜はCP-67（1967年〜1972年）を経て、1972年8月2日に発表されたVM/370に至る。VM/370のControl Program（CP）は、物理マシンのリソースを仮想的に分割し、各ユーザに仮想マシンを割り当てる。各仮想マシンの上ではCMS（Conversational Monitor System）が動作し、同一メインフレーム上で数百から数千のユーザが同時に対話的作業を行うことを可能にした。

ここで注目すべきは、VM/370が実現した「分離」の設計思想だ。各ユーザは自分専用の仮想マシンを持ち、他のユーザの仮想マシンの存在を意識しない。メモリ空間は分離され、ディスクは個別に割り当てられ、CPUタイムはフェアシェアスケジューラによって配分される。物理的な一台のマシンを論理的に分割し、各テナントに独立した実行環境を提供する——この概念は、半世紀を経た現在のクラウドにおけるマルチテナンシーと、原理的に同じである。

ただし、メインフレーム時代のマルチテナンシーには現代と決定的に異なる点がある。「テナント」が同一組織内のユーザだったことだ。大学の研究者たち、あるいは同一企業の社員たちが計算機を共有していた。信頼関係がある者同士の共有と、見知らぬ他者との共有では、隔離に求められる要件が根本的に異なる。クラウドは、この前提を覆した。

### Salesforce——SaaSにおけるマルチテナントの確立

マルチテナンシーが「異なる組織間の共有」として商業的に確立されたのは、SaaS（Software as a Service）の文脈が先だった。

1999年3月、元Oracle幹部のMarc Benioffは、Parker Harrisらと共にSalesforceを設立した。「The End of Software」というスローガンを掲げ、ソフトウェアを「購入・インストール」するのではなく「サービスとして利用する」モデルを打ち出した。

Salesforceのマルチテナントアーキテクチャの核心は、全顧客のデータを共通のデータベーステーブルに格納し、OrgIDで論理的に分離するメタデータ駆動型設計にある。単一のコードベースと単一のデータベースインフラで全顧客にサービスを提供する。利点は運用効率——バグ修正も新機能も一度のデプロイで全顧客に適用できる。欠点は、隔離がソフトウェアの実装に依存すること——プログラミングミス一つで、あるテナントのデータが別のテナントに見えてしまうリスクが常に存在する。

この設計思想は、SaaSモデルの原型として業界に広く影響を与え、形を変えてIaaSにも適用されていく。

### IaaSにおけるマルチテナンシー——共有の次元が変わった

SaaSのマルチテナンシーが「アプリケーション層」での共有なら、IaaSのマルチテナンシーは「インフラ層」での共有だ。AWS EC2のデフォルトでは、複数の顧客のインスタンスが同一の物理サーバ上で稼働する。あなたのm5.largeインスタンスと、別の顧客のt3.microインスタンスが、同じ物理ホストのCPUとメモリを分け合っている可能性がある。

SaaSでは、サービス提供者がテナント間隔離の全責任を負う。IaaSでは、クラウド事業者はインフラ層の隔離を提供し、その上のOS・アプリケーション層の隔離は利用者の責任だ。前回解説したShared Responsibility Modelは、マルチテナンシーの文脈でこそ最も重要な意味を持つ。

```
マルチテナンシーの歴史的系譜:

  1967年 CP-40 / 1972年 VM/370
  │  同一組織内のユーザ間でメインフレームを共有
  │  仮想マシンによるハードウェアレベルの分離
  │
  1999年 Salesforce
  │  異なる組織間でSaaSアプリケーションを共有
  │  OrgIDによる論理的なデータ分離
  │
  2006年 AWS EC2
  │  異なる組織間で物理サーバを共有
  │  ハイパーバイザによるVM分離
  │
  2018年 Firecracker (microVM)
     マイクロVMによる軽量かつ高速な隔離
     サーバーレス/コンテナ時代のマルチテナンシー

  ── 共通する原理 ──
  「物理リソースを仮想的に分割し、
   各テナントに独立した実行環境を提供する」
```

半世紀にわたるマルチテナンシーの歴史を貫く問いは一つだ。「共有の利益を最大化しながら、隔離の安全性をどう担保するか」。この問いに対する答えは、時代とともに精緻化されてきたが、完全には解決されていない。

---

## 3. マルチテナンシーの技術設計——3軸の隔離

### 隔離の設計軸

マルチテナンシーにおける隔離は、大きく3つの軸で設計される。計算の隔離、ストレージの隔離、ネットワークの隔離だ。IaaSの三本柱と同じ構造であり、各軸において異なる技術と異なるトレードオフが存在する。

```
マルチテナンシーの3軸:

  ┌─────────────────────────────────────────────────┐
  │                計算の隔離                        │
  │  VM / コンテナ / microVM / ユーザ空間カーネル    │
  │  問い: CPUとメモリをどう分離するか              │
  ├─────────────────────────────────────────────────┤
  │              ストレージの隔離                    │
  │  論理的分離（暗号化） / 物理的分離              │
  │  問い: データの残留と漏洩をどう防ぐか           │
  ├─────────────────────────────────────────────────┤
  │              ネットワークの隔離                  │
  │  VPC / セキュリティグループ / VXLAN             │
  │  問い: テナント間の通信をどう遮断するか         │
  └─────────────────────────────────────────────────┘
```

### 計算の隔離——VMからマイクロVMへ

計算の隔離は、マルチテナンシーにおいて最も注目される領域であり、技術の進化も最も激しい。隔離技術は、大きく4つのアプローチに分類できる。

**第一のアプローチ：仮想マシン（VM）。** 最も強力で最も古い隔離方式だ。ハイパーバイザが各テナントに独立した仮想マシンを割り当てる。ゲストOSのカーネルが独立しているため、あるVMの中で起きたカーネルパニックは他のVMに影響しない。隔離の強度は高いが、コストも高い。各VMがフルOSを動かすため、メモリ消費が大きく、起動時間も長い。

**第二のアプローチ：コンテナ。** Linuxのnamespacesとcgroupsを使ったプロセスレベルの隔離だ。namespacesは2002年のカーネル2.4.19で最初のマウント名前空間が導入され、PID名前空間（2008年、カーネル2.6.24）、ネットワーク名前空間（2009年、カーネル2.6.29）、ユーザ名前空間（2013年、カーネル3.8）と段階的に拡充された。cgroupsは2006年にGoogleのPaul MenageとRohit Sethが「process containers」として開発を開始し、2008年1月のカーネル2.6.24でメインラインにマージされた。

namespacesがプロセスの「見える範囲」を制限し、cgroupsがプロセスの「使える量」を制限する。この2つの組み合わせによって、単一のLinuxカーネル上で論理的に分離された環境を構築できる。VMに比べてオーバーヘッドが極めて小さく、起動も高速だ。だが、カーネルは共有されている。この事実が隔離の強度を根本的に制約する。コンテナAのプロセスが発行するシステムコールは、コンテナBのプロセスと同一のカーネルで処理される。カーネルの脆弱性は、全てのコンテナに影響する。

**第三のアプローチ：マイクロVM。** VMの隔離強度とコンテナの軽量性を両立しようとする試みだ。2018年11月、AWSはFirecrackerをオープンソースとして公開した。Rustで記述されたこの仮想マシンモニタ（VMM）は、Linux KVM上で動作し、125ms未満で起動し、5MiB未満のメモリオーバーヘッドしか消費しないマイクロVMを生成する。Chromium OSのcrosvmをフォークし、最小限のデバイスモデル（virtio-netとvirtio-blkのみ）を実装することで、攻撃面を極限まで削減した。

Firecrackerの設計思想は明快だ。「コンテナの速度でVMの隔離を実現する」。AWS LambdaとFargateの基盤として稼働しており、一台のベアメタルインスタンス上で数千のマイクロVMを同時に実行できる。サーバーレス環境では、異なるユーザの関数が同一物理ホスト上で実行されるため、マルチテナンシーの隔離要件が特に厳しい。Firecrackerは、その要件に対する回答だ。

2017年12月5日には、OpenStack Foundation（現Open Infrastructure Foundation）がKata Containersプロジェクトの発足を発表した。IntelのClear ContainersとHyper.shのrunVの統合で誕生したこのプロジェクトは、各コンテナを軽量なVMとして実行する。通常のハイパーバイザが完全なOSを起動するのに対し、Kata Containersはコンテナの実行に必要な最小限のカーネルのみを使用する。後にFirecrackerをVMMとして使用するオプションも追加された。

**第四のアプローチ：ユーザ空間カーネル。** 2018年5月、GoogleはgVisorをオープンソースとして公開した。Go言語で記述されたこのユーザ空間カーネルは、Linuxシステムコールの大部分をユーザ空間で再実装する。アプリケーションのシステムコールをgVisorの「Sentry」プロセスがインターセプトし、ホストカーネルに直接到達させない。仮想マシンほどのリソースコストをかけずに、カーネルの共有に起因するリスクを大幅に低減する。gVisorはGKE Sandbox（Google Kubernetes Engine）の基盤として組み込まれ、Google App Engine、Cloud Functions、Cloud Runでも内部的に使用されている。

```
計算の隔離アプローチ比較:

  隔離強度    高い ← ─────────────────── → 低い
  オーバーヘッド 大きい ← ─────────────────── → 小さい

  ┌──────────┬──────────┬──────────┬──────────┐
  │   VM     │ microVM  │ ユーザ空間│ コンテナ  │
  │          │          │ カーネル  │          │
  ├──────────┼──────────┼──────────┼──────────┤
  │ KVM/Xen  │Firecracker│ gVisor  │ runc     │
  │ VMware   │Kata Cont.│         │ crun     │
  ├──────────┼──────────┼──────────┼──────────┤
  │起動: 秒  │起動: ms  │起動: ms  │起動: ms  │
  │メモリ: GB│メモリ: MB│メモリ: MB│メモリ: MB│
  │カーネル: │カーネル: │カーネル: │カーネル: │
  │ 独立     │ 独立     │ 再実装   │ 共有     │
  └──────────┴──────────┴──────────┴──────────┘

  ※ カーネルが「独立」= ハードウェアレベルの分離
  ※ カーネルが「共有」= ソフトウェアレベルの分離
```

どのアプローチを選択するかは、ワークロードの特性と、許容できるリスクの水準によって決まる。信頼できるコードしか実行しないなら、コンテナの軽量な隔離で十分かもしれない。信頼できないコードを実行するサーバーレス環境では、Firecrackerのようなマイクロ VM の強力な隔離が必要だ。「隔離の強度」と「リソース効率」は常にトレードオフの関係にある。

### ストレージの隔離——データは本当に消えるのか

ストレージの隔離では、データの残留（data remanence）が焦点となる。ディスクを「フォーマット」しても物理的にデータは消えない。マルチテナント環境では、あるテナントが使い終わたストレージ領域を別のテナントが使用する可能性がある。AWSのEBSボリュームは割り当て前にゼロ初期化されるが、利用者側で追加できる最も実効的な防衛策はサーバーサイド暗号化（SSE）だ。テナントごとに異なる鍵でデータを暗号化すれば、たとえ物理的にデータが残留していても鍵がなければ復号できない。

### ネットワークの隔離——見えない壁をどう構築するか

ネットワークの隔離は前回VPCとVXLANの仕組みで詳しく解説した。マルチテナンシーの文脈で強調したいのは、テナント間のトラフィックが物理的に完全分離されているわけではない点だ。あるテナントのパケットと別のテナントのパケットは同じ物理スイッチを通過し、VXLANのVNIとセキュリティグループで論理的に隔離されている。

見落とされがちなのは帯域幅の共有だ。同一物理ホスト上のインスタンスは物理NICの帯域幅を共有する。Nitro Systemはネットワーク処理を専用Nitro Cardにオフロードし、テナントごとの帯域幅制限をハードウェアレベルで実施している。

---

## 4. Noisy Neighborとサイドチャネル——マルチテナンシーの暗部

### Noisy Neighbor問題——共有が生む性能干渉

冒頭で触れた私の体験は、Noisy Neighbor問題の典型例だ。マルチテナント環境において、あるテナントのワークロードが共有リソースを過剰に消費し、同一物理ホスト上の他テナントの性能を劣化させる。

Noisy Neighbor問題はCPUだけではない。ディスクI/O、ネットワーク帯域、そして見落とされがちだがラストレベルキャッシュ（LLC: Last Level Cache）でも発生する。現代のx86プロセッサでは、LLC（L3キャッシュ）が同一ソケット上の全コアで共有されている。あるテナントのワークロードがLLCを集中的に使用すると、他テナントのキャッシュラインがエビクション（追い出し）され、キャッシュミスが増加して性能が劣化する。

LinuxのCPU Steal Time（topコマンドの「st」値）は、この問題を可視化する最も直接的な指標だ。仮想CPUが物理CPUの割り当てをハイパーバイザから待機している時間の割合を示す。一般にこの値が5%を超えると警戒すべきであり、10%を超えるとアプリケーションの応答性に明らかな影響が現れる。

クラウドプロバイダはこの問題に対して多層的な緩和策を講じている。Kubernetesのresource requests/limitsによるリソースクォータ、Intel RDT（Resource Director Technology）によるLLCとメモリ帯域幅のパーティショニング、そしてハードウェアレベルのテナント分離だ。AWSのNitro Systemは、L1/L2キャッシュやCPUスレッドを顧客間で共有しない設計を採用している。これは保守的だが効果的なアプローチであり、Noisy Neighbor問題の大部分を物理レベルで排除する。

しかし、Noisy Neighbor問題は「完全には解決できない」ことを認識しておくべきだ。共有を前提とする以上、何らかの次元で干渉は起きうる。問題は「ゼロにする」ことではなく、「許容可能な水準に抑える」ことだ。そしてその許容水準を判断するためには、Noisy Neighbor問題のメカニズムを理解している必要がある。

### Spectre/Meltdown——ハードウェアの信頼が揺らいだ日

Noisy Neighbor問題が性能に対するリスクだとすれば、Spectre/Meltdownはセキュリティに対する根本的な脅威だった。

2018年1月3日、プロセッサの投機的実行に起因する2つの脆弱性——MeltdownとSpectre——が公開された。Google Project ZeroのJann Hornが2017年6月にIntel等に報告し、グラーツ工科大学のDaniel Grussら、Cyberus TechnologyのWerner Haasらが独立に発見した。

Meltdown（CVE-2017-5754）は、投機的実行の過程で発生するキャッシュ変化をサイドチャネルとして利用し、ユーザ空間からカーネルメモリの読み取りを可能にした。Spectre（CVE-2017-5753、CVE-2017-5715）は、同一物理ホスト上の異なるVMが共有する分岐予測バッファを操作することで、別のVMのメモリ内容にアクセスできる可能性を示した。

これがマルチテナンシーの文脈で重大な理由は明確だ。ハイパーバイザによるVM間の隔離は、仮想メモリとアクセス制御によって保証されている。だがSpectre/Meltdownは、ハードウェアの投機的実行という「正常な最適化」を通じて、この保護をバイパスした。ハードウェアレベルの隔離が、ハードウェア自身の最適化によって破られたのだ。

ソフトウェア緩和策のKPTI（Kernel Page Table Isolation）は5〜30%の性能劣化を伴った。AWSは翌日からライブパッチを開始したが、顧客側のパッチも別途必要だった。

Spectre/Meltdownの教訓は深い。マルチテナンシーの隔離は、ソフトウェアだけでは完全に保証できない。ハードウェアの設計、特にマイクロアーキテクチャレベルの最適化が、意図せず隔離を破る可能性がある。この事実は、その後のクラウドインフラ設計に大きな影響を与えた。

### AWS Nitro——ハードウェアで隔離を再構築する

Spectre/Meltdownへの対応として、AWSはNitro Systemのセキュリティ設計をさらに強化した。前回触れたNitro Systemのアーキテクチャを、マルチテナンシーの視点から改めて見直してみよう。

2022年にAWSが公開したホワイトペーパーは、Nitro Systemの「No Operator Access」設計を詳述している。AWSオペレータであっても、EC2インスタンスのメモリやストレージにアクセスする手段が一切存在しない。暗号鍵はNitro Cardsの保護された揮発メモリにのみ平文で存在し、ホストのメインプロセッサからはアクセスできない。

テナント間分離について、AWSはL1/L2キャッシュやCPUスレッドを顧客間で共有しない保守的な設計を採用している。Spectre/Meltdownが悪用したサイドチャネルの多くは、CPUの低レベルのリソース（キャッシュ、分岐予測バッファ等）の共有に依存する。これらを共有しないという設計判断は、パフォーマンス効率を若干犠牲にするが、サイドチャネル攻撃のリスクを根本的に排除する。

2020年10月にGAとなったNitro Enclavesは、親インスタンスからCPU/メモリを物理的に分割し、永続ストレージもネットワークも持たない完全隔離VM環境を生成する。暗号論的アテステーションでコードの完全性を検証でき、暗号鍵管理やPII処理をホストOSからも隔離された環境で実行可能だ。

```
テナント間隔離の進化:

  Xen時代（〜2017年）:
  ┌──────────────────────────────────┐
  │ [VM A: 顧客A] [VM B: 顧客B]     │
  │         Xen Hypervisor           │
  │ [Dom0: 管理VM -- root権限あり]   │
  │         物理ハードウェア          │
  └──────────────────────────────────┘
  ※ Dom0がCPUを消費。Dom0にアクセスできれば
    理論上はVM A/Bのメモリを参照可能

  Nitro時代（2017年〜）:
  ┌──────────────────────────────────┐
  │ [VM A: 顧客A] [VM B: 顧客B]     │
  │      Nitro Hypervisor（軽量）     │
  │         物理ハードウェア          │
  │ [Nitro Card: NW] [Nitro Card: EBS]│
  │ [Nitro Security Chip]            │
  └──────────────────────────────────┘
  ※ 管理VMなし。暗号鍵はNitro Card内の
    揮発メモリにのみ存在。No Operator Access

  Nitro Enclaves:
  ┌──────────────────────────────────┐
  │ [VM A] [Enclave: 機密処理]       │
  │      │    ↕ vsock通信のみ         │
  │      └────────────────────        │
  │  CPUとメモリを物理的に分割        │
  │  永続ストレージなし               │
  │  ネットワークアクセスなし         │
  └──────────────────────────────────┘
```

### EC2のテナンシーオプション——共有か専用か

AWS EC2は、マルチテナンシーに対する利用者の選択肢を3段階で提供している。共有テナンシー（デフォルト、複数顧客が物理ホストを共有）、Dedicated Instances（アカウント専用の物理ハードウェアを確保）、Dedicated Hosts（物理サーバ全体を専有し配置を完全制御）の3つだ。

AWSは、Dedicated InstancesとDedicated Hostsの間に性能やセキュリティの差異はないと明言している。共有テナンシーでもNitro Systemの保護は同等に適用される。Dedicated HostsやDedicated Instancesを選択する主な理由は、コンプライアンス要件やBYOL（Bring Your Own License）ライセンス管理であることが多い。

---

## 5. ハンズオン——cgroupsとnamespaceで簡易マルチテナント環境を構築する

ここからは、Linuxのcgroupsとnamespacesを使って簡易的なマルチテナント環境を構築し、リソースの隔離と「Noisy Neighbor」問題を実際に体験する。クラウドのマルチテナンシーの基盤技術を、自分の手で操作することで理解を深めよう。

### 環境

- Docker（Ubuntu 24.04ベースコンテナ、特権モード）

### 演習1：namespacesによるプロセス隔離

```bash
# Docker環境で作業する（namespacesの操作に特権が必要）
docker run -it --rm --privileged ubuntu:24.04 bash

# 必要なツールのインストール
apt-get update && apt-get install -y util-linux cgroup-tools stress-ng procps iproute2
```

まず、名前空間を使ってプロセスを隔離する。unsahreコマンドは、新しい名前空間を作成してその中でコマンドを実行する。

```bash
# 新しいPID名前空間とマウント名前空間でシェルを起動
unshare --pid --mount --fork bash

# procfsをマウントし直す（新しいPID名前空間用）
mount -t proc proc /proc

# プロセス一覧を確認——自分のシェルがPID 1になっている
ps aux
# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# root         1  0.0  0.0   4624  3840 pts/0    S    ...     0:00 bash
# root        11  0.0  0.0   7888  3968 pts/0    R+   ...     0:00 ps aux

echo "私のPIDは1だ。この名前空間では、私がinit(1)だ"

# この名前空間の中からは、ホスト側のプロセスが一切見えない
# これが「プロセスの隔離」の本質だ

# 名前空間から抜ける
exit
```

PID名前空間の中では、シェルのPIDが1になる。ホスト側の他のプロセスは一切見えない。これがコンテナのプロセス隔離の基盤だ。各コンテナは自分だけのプロセスツリーを持ち、他のコンテナやホストのプロセスを知覚できない。

### 演習2：cgroupsによるリソース制限

```bash
# cgroups v2が有効か確認
mount | grep cgroup2
# cgroup2 on /sys/fs/cgroup type cgroup2 ...

# テナントAとテナントBのcgroupを作成
mkdir -p /sys/fs/cgroup/tenant-a
mkdir -p /sys/fs/cgroup/tenant-b

# テナントAにCPU制限を設定（50%に制限）
# cpu.max: "quota period" — 100000マイクロ秒（100ms）の期間で50000マイクロ秒（50ms）使用可能
echo "50000 100000" > /sys/fs/cgroup/tenant-a/cpu.max

# テナントBにもCPU制限を設定（50%に制限）
echo "50000 100000" > /sys/fs/cgroup/tenant-b/cpu.max

# メモリ制限も設定（テナントA: 128MB、テナントB: 256MB）
echo $((128 * 1024 * 1024)) > /sys/fs/cgroup/tenant-a/memory.max
echo $((256 * 1024 * 1024)) > /sys/fs/cgroup/tenant-b/memory.max

echo "テナントA: CPU 50%, メモリ 128MB"
echo "テナントB: CPU 50%, メモリ 256MB"
```

### 演習3：Noisy Neighborを意図的に再現する

```bash
# テナントAでCPU負荷をかける（stress-ngでCPUを100%使用）
# cgexecでcgroup内で実行する
cgexec -g cpu,memory:tenant-a stress-ng --cpu 2 --timeout 30s &
TENANT_A_PID=$!

# 3秒待ってからテナントBでも同様の負荷をかける
sleep 3
cgexec -g cpu,memory:tenant-b stress-ng --cpu 2 --timeout 27s &
TENANT_B_PID=$!

# 両テナントのCPU使用状況をリアルタイムで観察
echo "=== 5秒ごとにCPU使用状況を確認 ==="
for i in 1 2 3 4; do
  sleep 5
  echo "--- ${i}回目の計測 ---"
  echo "テナントA CPU使用時間:"
  cat /sys/fs/cgroup/tenant-a/cpu.stat | head -3
  echo "テナントB CPU使用時間:"
  cat /sys/fs/cgroup/tenant-b/cpu.stat | head -3
  echo ""
done

# プロセスの終了を待つ
wait $TENANT_A_PID 2>/dev/null
wait $TENANT_B_PID 2>/dev/null

echo "=== Noisy Neighbor実験完了 ==="
```

この実験のポイントは、cgroupsによるCPU制限がなければ、先に起動したテナントAが物理CPUを占有し、後から起動したテナントBの性能が著しく劣化するということだ。cgroupsの`cpu.max`による制限は、各テナントが使用できるCPU時間の上限を強制し、Noisy Neighbor問題を緩和する。

### 演習4：メモリ制限の効果を確認する

```bash
# テナントAの128MBメモリ制限を超えるとどうなるか
echo "テナントAのメモリ制限: $(cat /sys/fs/cgroup/tenant-a/memory.max) bytes"

# テナントAで200MBのメモリを確保しようとする
cgexec -g memory:tenant-a stress-ng --vm 1 --vm-bytes 200M --timeout 10s 2>&1 &
sleep 5

# OOM（Out of Memory）によるキルを確認
echo "テナントAのOOMイベント:"
cat /sys/fs/cgroup/tenant-a/memory.events
# oom_kill の値が0より大きければ、OOMキラーが発動している

wait 2>/dev/null

# テナントBは影響を受けていないことを確認
echo "テナントBのOOMイベント:"
cat /sys/fs/cgroup/tenant-b/memory.events
# テナントBのoom_killは0のまま
```

ここが重要だ。テナントAがメモリ制限を超えた場合、OOMキラーはテナントAのプロセスだけを殺す。テナントBには一切影響しない。これがcgroupsによるメモリ隔離だ。マンションの隣人がどれだけ騒いでも、隣人の部屋の電源ブレーカーだけが落ちて、自分の部屋は影響を受けない——そういう仕組みだ。

### 演習5：ネットワーク名前空間でテナントを分離する

```bash
# テナントAとテナントB用のネットワーク名前空間を作成
ip netns add tenant-a-ns
ip netns add tenant-b-ns

# vethペアを作成してテナントAをホストに接続
ip link add veth-a-host type veth peer name veth-a-tenant
ip link set veth-a-tenant netns tenant-a-ns
ip addr add 10.100.1.1/24 dev veth-a-host
ip link set veth-a-host up
ip netns exec tenant-a-ns ip addr add 10.100.1.2/24 dev veth-a-tenant
ip netns exec tenant-a-ns ip link set veth-a-tenant up
ip netns exec tenant-a-ns ip link set lo up

# テナントBも同様に（異なるサブネット）
ip link add veth-b-host type veth peer name veth-b-tenant
ip link set veth-b-tenant netns tenant-b-ns
ip addr add 10.100.2.1/24 dev veth-b-host
ip link set veth-b-host up
ip netns exec tenant-b-ns ip addr add 10.100.2.2/24 dev veth-b-tenant
ip netns exec tenant-b-ns ip link set veth-b-tenant up
ip netns exec tenant-b-ns ip link set lo up

# テナントAからテナントBへは直接到達できない
ip netns exec tenant-a-ns ping -c 2 -W 1 10.100.2.2 || echo "到達不可（期待通り）"

# クリーンアップ
ip netns del tenant-a-ns && ip netns del tenant-b-ns
ip link del veth-a-host 2>/dev/null && ip link del veth-b-host 2>/dev/null
```

テナントAとテナントBは独立したネットワーク名前空間に閉じ込められ、ホスト側でルーティングを設定しない限り、テナント間の直接通信はできない。これがVPCの隔離の基盤であり、クラウドのネットワークマルチテナンシーの出発点だ。

### 全体クリーンアップ

```bash
# cgroupの削除
rmdir /sys/fs/cgroup/tenant-a 2>/dev/null
rmdir /sys/fs/cgroup/tenant-b 2>/dev/null
echo "クリーンアップ完了"
```

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/12-multitenant-design/` に用意してある。

---

## 6. まとめと次回予告

### この回のまとめ

第12回では、マルチテナンシー——クラウドの核心イノベーション——を、歴史・技術・リスクの三面から読み解いた。

**マルチテナンシーの起源はメインフレームにある。** CP-40（1967年）、VM/370（1972年）、Salesforce（1999年）、AWS EC2（2006年）と、共有の範囲は組織内のユーザからSaaSの顧客、IaaSの物理サーバへと拡大してきた。

**計算の隔離技術は4つのアプローチに進化した。** VM、コンテナ、マイクロVM（Firecracker）、ユーザ空間カーネル（gVisor）。隔離の強度とリソース効率は常にトレードオフの関係にある。

**Noisy Neighbor問題は本質的な課題だ。** CPU、ディスクI/O、ネットワーク帯域、LLCなど複数の次元で発生し、完全な解決は不可能だが、cgroupsによる制限からNitro Systemのハードウェアレベル分離まで、多層的な緩和策が講じられている。

**Spectre/Meltdown（2018年1月）は、ハードウェアレベルの隔離の限界を露呈した。** ソフトウェア緩和策は5〜30%の性能劣化を伴い、「隔離にはコストが伴う」事実を突きつけた。

**AWS Nitro Systemは、ハードウェアで隔離を再構築する試みだ。** 「No Operator Access」設計、CPUリソースの顧客間非共有、Nitro Enclavesによる完全隔離——Spectre/Meltdown以降のクラウドセキュリティ設計の方向性を示している。

冒頭の問いに答えよう。「なぜマルチテナンシーがクラウドのコアであり、そして最大のリスクなのか？」——マルチテナンシーは、物理リソースを複数のテナントで共有することで、一テナントあたりのコストを劇的に下げる。クラウドの経済性はここに立脚している。だが共有はリスクを伴う。性能干渉（Noisy Neighbor）、データ漏洩、サイドチャネル攻撃——共有のあるところに、隔離の課題がある。マルチテナンシーの二面性を理解することは、クラウドアーキテクトとしての基本教養だ。

### 次回予告

第13回では、「Heroku——『git pushでデプロイ』が変えたもの」を取り上げる。

IaaSの世界では、利用者がOS以上の全てを管理する。だが多くの開発者が求めていたのは、「サーバの管理をしたくない。コードを書いてデプロイするだけにしたい」という体験だった。2007年に創業したHerokuは、`git push heroku main` の一行でアプリケーションをデプロイできる世界を実現し、PaaS（Platform as a Service）の概念を広く普及させた。Adam Wigginsが2011年に提唱したThe Twelve-Factor Appは、PaaSを超えてクラウドネイティブ設計の基盤となった。

インフラを意識しない開発体験は、何を解放し、何を隠蔽したのか。次回はPaaSの光と影に踏み込む。

---

## 参考文献

- IBM, "VM 50th Anniversary". <https://www.vm.ibm.com/history/50th/index.html>
- Salesforce, "The History of Salesforce". <https://www.salesforce.com/news/stories/the-history-of-salesforce/>
- Salesforce Architects, "Platform Multitenant Architecture". <https://architect.salesforce.com/fundamentals/platform-multitenant-architecture>
- CISA, "Meltdown and Spectre Side-Channel Vulnerability Guidance", January 2018. <https://www.cisa.gov/news-events/alerts/2018/01/04/meltdown-and-spectre-side-channel-vulnerability-guidance>
- Brendan Gregg, "KPTI/KAISER Meltdown Initial Performance Regressions", February 2018. <https://www.brendangregg.com/blog/2018-02-09/kpti-kaiser-meltdown-performance.html>
- AWS Open Source Blog, "Announcing the Firecracker Open Source Technology: Secure and Fast microVM for Serverless Computing", 2018. <https://aws.amazon.com/blogs/opensource/firecracker-open-source-secure-fast-microvm-serverless/>
- AWS, "The Security Design of the AWS Nitro System" (whitepaper), 2022. <https://docs.aws.amazon.com/whitepapers/latest/security-design-of-aws-nitro-system/security-design-of-aws-nitro-system.html>
- Google Cloud Blog, "Open-sourcing gVisor, a sandboxed container runtime", May 2018. <https://cloud.google.com/blog/products/identity-security/open-sourcing-gvisor-a-sandboxed-container-runtime>
- Business Wire, "Kata Containers Project Launches to Build Secure Container Infrastructure", December 2017. <https://www.businesswire.com/news/home/20171205005634/en/Kata-Containers-Project-Launches-to-Build-Secure-Container-Infrastructure>
- Microsoft Learn, "Noisy Neighbor Antipattern - Azure Architecture Center". <https://learn.microsoft.com/en-us/azure/architecture/antipatterns/noisy-neighbor/noisy-neighbor>
- LWN.net, "Namespaces in operation, part 1: namespaces overview", January 2013. <https://lwn.net/Articles/531114/>
- AWS Documentation, "Amazon EC2 Dedicated Instances". <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/dedicated-instance.html>
- AWS, "Amazon EC2 Dedicated Hosts FAQs". <https://aws.amazon.com/ec2/dedicated-hosts/faqs/>
