# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第7回：Xen、KVM——オープンソース仮想化が切り拓いた道

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Xenが準仮想化（paravirtualization）で実現した「ゲストOSとハイパーバイザの協調」という設計思想
- 2003年のSOSP論文「Xen and the Art of Virtualization」が示した性能と、VMwareとの設計上の対比
- KVM（Kernel-based Virtual Machine）がLinuxカーネルに統合された経緯と、その設計判断の革新性
- QEMU + KVMの協調動作モデルと、virtioによるI/O性能改善の仕組み
- AWS EC2がXenからNitro（KVMベース）へ移行した技術的背景
- libvirt/virshによる仮想マシン管理の実践——クラウドAPIの原型を体験する

---

## 1. VMwareのライセンス請求書を見たとき

2007年のある日、私はVMware vSphereのライセンス更新見積書を前にして、思わず声を上げた。

前年にVMware ESXを導入し、サーバ統合を進めた結果は素晴らしかった。第6回で述べたとおり、物理サーバ10台を2台に統合し、コストを大幅に削減できた。経営陣も満足していた。だが、その成功がさらなる仮想化の展開を後押しし、仮想マシンの数は増え続けた。vCenterの管理画面に並ぶ仮想マシンの数だけ、VMwareのライセンスコストも膨らんでいく。

当時のVMware ESXのライセンスは物理CPUソケット単位で課金されていた。CPUソケットが増えれば、ライセンス費用も比例して増える。vMotionやHA（High Availability）などの高度な機能を使うには、上位エディションのライセンスが必要で、その費用はさらに跳ね上がった。サーバ統合で削減したハードウェアコストの一部が、VMwareのライセンスに置き換わっただけではないか——そんな疑念が頭をよぎった。

そのとき、同僚のLinuxエンジニアが言った。「Xenを試してみないか。オープンソースだ」。

私はXenの名前は知っていた。ケンブリッジ大学から出てきた仮想化技術で、準仮想化（paravirtualization）という独自のアプローチを取っていることも聞いていた。だが、VMwareの安定性と管理ツールの充実度に慣れた身には、オープンソースの仮想化は未知の領域だった。

CentOS 5にXenをインストールし、最初の仮想マシンを立ち上げた日のことは今でも覚えている。`xm create` コマンドで仮想マシンが起動する。VMwareのGUIとは対照的な、テキストベースの世界。だが、動いた。しかも、VMwareのライセンスなしで。

その後、KVM（Kernel-based Virtual Machine）がLinuxカーネルに統合されたと聞いたとき、私は「仮想化はもはやOSの標準機能になった」と確信した。特別なソフトウェアを買う必要がない。Linuxカーネルそのものがハイパーバイザなのだ。この事実が持つ意味は、技術的にも経済的にも、計り知れないものだった。

VMwareが仮想化の可能性を証明した。だが、その恩恵を広く行き渡らせたのは、オープンソースだった。仮想化の「民主化」——それはXenとKVMによって実現された。そしてこの民主化がなければ、AWSがあの規模でクラウドを構築することはできなかったはずだ。

あなたが今日 `aws ec2 run-instances` で起動するインスタンスの裏側には、このオープンソース仮想化の系譜がある。その系譜を辿ってみよう。

---

## 2. Xen——準仮想化という第三の道

### ケンブリッジ大学のXenoServersプロジェクト

Xenの歴史は、1999年にケンブリッジ大学Computer Laboratoryで始まったXenoServersプロジェクトに遡る。

Ian Pratt（Senior Lecturer）率いるチームは、インターネット上に分散した計算資源を、認証されたユーザーが購入・利用できるインフラストラクチャの構築を目指していた。このビジョンを実現するには、1台の物理マシン上で複数のユーザーのワークロードを安全かつ効率的に分離して実行する技術が必要だった。そしてそのためには、仮想化が不可欠だった。

研究学生のKeir Fraserがこのアイデアを掴み、コアとなるハイパーバイザの実装に取り組んだ。Fraserのアプローチは、VMwareとは根本的に異なるものだった。

前回（第6回）で述べたとおり、VMwareはバイナリトランスレーションという手法で、ゲストOSを一切修正せずにx86仮想化を実現した。ゲストOSは「自分が仮想化されている」ことを知らない。VMwareはゲストOSを「騙す」のだ。

Fraserは逆のアプローチを取った。ゲストOSのカーネルを修正し、ハイパーバイザの存在を「知らせる」。ゲストOSとハイパーバイザが協調して動く設計だ。これが準仮想化（paravirtualization）である。

### SOSP 2003——「Xen and the Art of Virtualization」

2003年、Ian Pratt率いるチーム（Paul Barham、Boris Dragovic、Keir Fraser、Steven Hand、Tim Harris、Alex Ho、Rolf Neugebauer、Ian Pratt、Andrew Warfield）は、ACMのSOSP（Symposium on Operating Systems Principles）で「Xen and the Art of Virtualization」と題する論文を発表した。オペレーティングシステム研究の最高峰の会議で、Xenの設計思想と性能を世に問うた。

論文のタイトルは、ロバート・M・ピアシグの著作「Zen and the Art of Motorcycle Maintenance」（禅とオートバイ修理技術）のもじりだ。技術的な論文にしては洒落たタイトルだが、内容は極めて実践的だった。

論文の核心は、準仮想化のトレードオフを明確に示したことにある。

```
VMwareの完全仮想化 vs Xenの準仮想化:

完全仮想化（VMware）:
  ゲストOS ──→ [センシティブ命令を実行]
                      ↓
              バイナリトランスレーション
              （命令を動的に書き換え）
                      ↓
              VMMがシミュレーション
                      ↓
              結果をゲストOSに返す

  利点: ゲストOS無修正（Windowsも動く）
  欠点: 翻訳のオーバーヘッドが存在


準仮想化（Xen）:
  ゲストOS ──→ [ハイパーコールを発行]
                      ↓
              Xenハイパーバイザが処理
                      ↓
              結果をゲストOSに返す

  利点: オーバーヘッドが極めて小さい
  欠点: ゲストOSのカーネル修正が必要
        （Windowsは修正できない）
```

準仮想化では、ゲストOSはセンシティブ命令を直接実行しない。代わりに、ハイパーコール（hypercall）と呼ばれる明示的なインターフェースを通じてハイパーバイザにサービスを要求する。これはOSのシステムコールと類似した概念だ。ユーザープログラムがカーネルの機能を利用するためにシステムコールを発行するように、ゲストOSのカーネルがハイパーバイザの機能を利用するためにハイパーコールを発行する。

```
ハイパーコールの概念（Xenの設計）:

通常のOS（仮想化なし）:
  ユーザプログラム ──→ [システムコール] ──→ カーネル ──→ ハードウェア

準仮想化OS（Xen上）:
  ユーザプログラム ──→ [システムコール] ──→ ゲストカーネル
                                                 ↓
                                           [ハイパーコール]
                                                 ↓
                                           Xenハイパーバイザ
                                                 ↓
                                            ハードウェア

  ハイパーコールの例:
  - ページテーブルの更新
  - 仮想割り込みの設定
  - I/Oデバイスへのアクセス
  - タイマー設定
```

SOSP論文のベンチマーク結果は印象的だった。XenoLinux（Xen用に修正されたLinuxカーネル）上のアプリケーション性能は、ネイティブLinuxとほぼ同等であり、ハイパーコールのオーバーヘッドはわずか1-3マイクロ秒程度だった。VMwareのバイナリトランスレーションでは実現困難な低オーバーヘッドを、カーネルの修正という代償と引き換えに達成した。

### 準仮想化の設計的な美しさと限界

準仮想化の設計には、技術的な美しさがある。

完全仮想化では、ハイパーバイザはゲストOSの挙動を「事後的に」捕捉する。ゲストOSがセンシティブ命令を実行しようとした時点で介入し、処理を代行する。これは反応的（reactive）なアプローチだ。

準仮想化では、ゲストOS自身がハイパーバイザとの対話を意識している。ゲストOSは「自分が仮想化環境にいる」ことを前提にコーディングされており、ハイパーバイザへの要求を明示的に発行する。これは協調的（cooperative）なアプローチだ。

協調的なアプローチの利点は、不要な処理を省けることにある。完全仮想化では、ゲストOSが「ハードウェアに直接アクセスしようとして失敗し、ハイパーバイザが介入する」という無駄な往復が発生する。準仮想化では、最初からハイパーバイザに正しい方法で要求するため、この往復が不要だ。

だが、限界も明確だった。ゲストOSのカーネルを修正する必要がある、という制約だ。

Linuxのようなオープンソースのカーネルであれば修正は可能だ。実際、Xenチームは早い段階でLinuxカーネルのXen対応パッチを作成した。だがWindowsは別だ。Microsoftがカーネルのソースコードを公開していない以上、Windowsを準仮想化で動かすことはできない。

2000年代半ばのサーバ市場において、Windowsが動かないということは致命的ではなかった——Linuxサーバの割合は増加し続けていた。だが、デスクトップ仮想化やWindowsワークロードを持つ企業にとっては、この制約は看過できなかった。

この制約は、Intel VT-xとAMD-Vの登場によって解消に向かう。ハードウェア仮想化支援があれば、Xenでもカーネルを修正していないゲストOS（Windows含む）を動かせる。これがXenのHVM（Hardware Virtual Machine）モードだ。HVMモードでは、QEMUベースのデバイスエミュレーションを使い、未修正のゲストOSに対して仮想ハードウェアを提供する。

```
Xenの2つの動作モード:

PV（Paravirtualization）モード:
  ┌───────────────────────────────┐
  │ ゲストOS（カーネル修正済み） │
  │ ── ハイパーコールでXenと通信  │
  └───────────────────────────────┘
  ┌───────────────────────────────┐
  │ Xenハイパーバイザ             │
  └───────────────────────────────┘
  ┌───────────────────────────────┐
  │ 物理ハードウェア              │
  └───────────────────────────────┘

  → 高性能、ただしLinux等のみ対応

HVM（Hardware Virtual Machine）モード:
  ┌───────────────────────────────┐
  │ ゲストOS（未修正、Windowsも可）│
  │ ── 通常のハードウェアアクセス  │
  └───────────────────────────────┘
  ┌───────────────────────────────┐
  │ QEMU（デバイスエミュレーション）│
  ├───────────────────────────────┤
  │ Xenハイパーバイザ              │
  │ ── VT-x/AMD-Vでトラップ       │
  └───────────────────────────────┘
  ┌───────────────────────────────┐
  │ 物理ハードウェア（VT-x/AMD-V）│
  └───────────────────────────────┘

  → ゲストOS無修正、ただしPVより
    I/Oオーバーヘッドが大きい

PVHVM（PV on HVM）:
  HVMモードの上でPVドライバを使用
  → 両方の利点を組み合わせる
```

Xenは柔軟だった。準仮想化とハードウェア支援仮想化の両方をサポートし、さらには両者を組み合わせたPVHVM（PV on HVM）モードまで提供した。この適応力が、XenをAWSのEC2の基盤に選ばせた理由の一つだった。

### XenSourceとCitrix——オープンソースの商用化

学術プロジェクトから始まったXenは、やがて商用化の道を歩む。

Ian Pratt、Keir Fraser、Simon Crosbyらケンブリッジ大学の出身者がXenSource Inc.を設立し、Xenの商用製品化を推進した。XenSourceはXenをベースとしたエンタープライズ向け仮想化製品を開発し、VMwareの対抗馬としてポジションを確立しようとした。

2007年、Citrix SystemsがXenSourceを約5億ドルで買収した。Citrixはリモートデスクトップとアプリケーション配信の分野で強みを持つ企業であり、サーバ仮想化とデスクトップ仮想化を統合するプラットフォームの構築を目指した。Citrixの買収により、Xenの商用製品はXenServer（後にCitrix Hypervisor、現在のXenServerに再度改名）として発展していく。

一方、オープンソースのXenプロジェクトは独自の道を歩み続けた。2013年4月、XenプロジェクトはLinux FoundationのCollaborative Projectとして移管された。Amazon、AMD、Cisco、Citrix、Google、Intel、Oracle、Samsungなどがメンバーとして名を連ねた。ベンダー中立な立場での開発体制が確立され、「Xen Project」という新しい商標が、商用利用の「Xen」商標と区別された。

### AWS EC2を支えたXen

Xenの歴史を語る上で、AWSとの関係は避けて通れない。

2006年8月25日、AWSがEC2の限定パブリックベータを開始したとき、その基盤にはXenハイパーバイザが使われていた。最初のインスタンスタイプ（m1.small）は、Xenの上で動く仮想マシンだった。その後の10年間で、AWSは27以上のインスタンスタイプをXenベースで提供した。

AWSがXenを選んだ理由は複合的だ。オープンソースであるため、ライセンスコストがかからない。ソースコードにアクセスできるため、AWS固有のニーズに合わせてカスタマイズできる。準仮想化による高い性能。そしてLinuxワークロードとの高い親和性。

AWSのインフラを支えたXen——この事実は、オープンソース仮想化の影響力を雄弁に物語る。学術論文から始まったプロジェクトが、世界最大のクラウドプラットフォームの基盤となった。

---

## 3. KVM——Linuxカーネルがハイパーバイザになる

### Avi Kivityの問い——「なぜ仮想化はカーネルの外にあるのか？」

Xenが準仮想化で仮想化の世界を揺るがしていた2006年、イスラエルのスタートアップQumranetで働くAvi Kivityは、全く異なるアプローチを考えていた。

Kivityは当初、QumranetでXen関連の仕事をしていた。だが、Xenのアーキテクチャに対する不満が募っていた。Xenはハイパーバイザとして独自のカーネルを持ち、その上でLinux（Dom0と呼ばれる管理用ドメイン）を動かし、その管理用ドメインを通じてゲストVMを管理する。つまり、Linuxカーネルの「下」にもう一つのカーネル（Xenハイパーバイザ）が存在する構造だ。

```
Xenのアーキテクチャ:

  ┌──────────┐  ┌──────────┐  ┌──────────┐
  │ DomU     │  │ DomU     │  │ Dom0     │
  │ (ゲスト) │  │ (ゲスト) │  │ (管理用) │
  │ VM-A     │  │ VM-B     │  │ Linux    │
  └──────────┘  └──────────┘  └──────────┘
  ┌────────────────────────────────────────┐
  │ Xenハイパーバイザ                      │
  │ （独自のマイクロカーネル的存在）       │
  │ ── CPUスケジューリング                 │
  │ ── メモリ管理                          │
  │ ── 割り込み処理                        │
  └────────────────────────────────────────┘
  ┌────────────────────────────────────────┐
  │ 物理ハードウェア                       │
  └────────────────────────────────────────┘

  Dom0:
  - 特権を持つ管理用Linux
  - デバイスドライバはDom0のLinuxが担当
  - ゲストVMの起動・停止・管理を行う
  - Dom0がダウンすると全VMに影響

  問題点:
  - Xenハイパーバイザ自体がLinuxとは
    別のコードベース → 保守コスト
  - Linuxカーネルの進化をXenに反映するのに
    タイムラグが発生
  - デバイスドライバの管理が複雑
```

Kivityは問うた。Intel VT-xとAMD-Vが登場した今、ハードウェアがトラップを処理してくれる。ならば、Linuxカーネル自体をハイパーバイザにすればいいのではないか。Linuxは既に優れたCPUスケジューラ、メモリ管理、デバイスドライバスタックを持っている。なぜこれらを捨てて、Xenの独自カーネルにスケジューリングやメモリ管理を任せる必要があるのか。

この問いが、KVMの設計思想の原点となった。

### 2006年10月——カーネルメーリングリストへの投稿

2006年10月19日、Avi KivityはLinuxカーネルメーリングリスト（LKML）にKVMのパッチを投稿した。

KVMの設計は驚くほどシンプルだった。Linuxカーネルにローダブルモジュール（kvm.ko）として組み込まれ、`/dev/kvm` というデバイスファイルを通じてユーザ空間からアクセスできる。KVMモジュールがロードされると、LinuxカーネルはIntel VT-xまたはAMD-Vのハードウェア仮想化拡張を使って、仮想マシンの実行環境を提供する。

KVMの革新は「何をしなかったか」にある。KVMは自前のCPUスケジューラを持たない。Linuxカーネルのスケジューラをそのまま使う。メモリ管理もLinuxのメモリ管理機構をそのまま使う。デバイスドライバもLinuxのものを使う。KVMが担当するのは、VT-x/AMD-Vの制御——VMEntryとVMExitの処理、仮想マシンのCPUコンテキスト管理——だけだ。

```
KVMのアーキテクチャ:

  ┌──────────────────────────────────────┐
  │ ユーザ空間                           │
  │                                      │
  │ ┌──────────┐  ┌──────────┐  通常の  │
  │ │ QEMU     │  │ QEMU     │  Linux   │
  │ │ (VM-A)   │  │ (VM-B)   │  プロセス│
  │ └──────────┘  └──────────┘          │
  ├──────────────────────────────────────┤
  │ Linuxカーネル                        │
  │                                      │
  │ ┌────────────────────────┐           │
  │ │ KVMモジュール          │           │
  │ │ /dev/kvm               │           │
  │ │ ── VMEntry/VMExit処理  │           │
  │ │ ── 仮想CPUコンテキスト │           │
  │ └────────────────────────┘           │
  │                                      │
  │ Linux既存機能（そのまま活用）:       │
  │ ── CPUスケジューラ（CFS等）          │
  │ ── メモリ管理（ページング、KSM）     │
  │ ── デバイスドライバ                  │
  │ ── ネットワークスタック              │
  │ ── セキュリティ（SELinux, cgroups）  │
  └──────────────────────────────────────┘
  ┌──────────────────────────────────────┐
  │ 物理ハードウェア（VT-x/AMD-V必須）  │
  └──────────────────────────────────────┘

  各VMは通常のLinuxプロセス:
  - psコマンドで見える
  - cgroupsでリソース制限可能
  - SELinuxでセキュリティポリシー適用可能
  - numactl等でNUMAノード配置指定可能
```

このアーキテクチャの美しさは、既存のLinuxエコシステムをそのまま活用できることにある。仮想マシンはLinuxにとって「ちょっと特殊なプロセス」にすぎない。`ps` コマンドで仮想マシンのプロセスが見える。`top` でCPU使用率が確認できる。`cgroups` でリソース制限をかけられる。SELinuxでセキュリティポリシーを適用できる。Linuxの運用ツール、監視ツール、デバッグツールがそのまま使える。

### わずか2ヶ月でカーネルにマージ

KVMが投稿されてからLinuxカーネルにマージされるまでの速度は、異例だった。

2006年10月19日に初投稿、12月10日にアップストリームカーネルにマージ。わずか2ヶ月足らずだ。2007年2月5日にリリースされたLinux 2.6.20に含まれ、正式に世に出た。

Linuxカーネルへの新機能の追加は通常、長期間のレビューと議論を経る。KVMが異例の速度でマージされた理由はいくつかある。

第一に、パッチのサイズが小さかった。KVMは既存のLinuxの機能をほとんどそのまま使い、追加したのはVT-x/AMD-Vの制御に必要なコードだけだった。小さなパッチはレビューが容易だ。

第二に、Linuxカーネルのメンテナたちが、仮想化をカーネルの標準機能として取り込む価値を認めた。Xenは長年にわたってLinuxカーネルとの統合に苦労していた。Xenのパッチはカーネルに対して大量の変更を要求し、メインラインへのマージが難航していた（Xenのdom0サポートがLinuxカーネルにマージされたのは2011年のことだ）。KVMはこの問題を、設計のシンプルさによって回避した。

第三に、Intel VT-xとAMD-Vの存在だ。ハードウェアが仮想化を直接サポートする以上、カーネル側で必要なコードは最小限で済む。KVMの登場タイミングは、ハードウェアの進化と完璧に同期していた。

### QEMU + KVM——役割分担の妙

KVMはCPU仮想化を担当するが、仮想マシンにはCPU以外にもディスク、ネットワーク、グラフィックス、USBといったデバイスが必要だ。KVMはこれらのデバイスのエミュレーションを行わない。その役割はQEMUに委ねられた。

QEMUは2003年にフランスのプログラマFabrice Bellardが開発したオープンソースのエミュレータだ。Bellardは他にもFFmpeg（動画・音声処理ライブラリ）やTiny C Compilerの開発者として知られ、オープンソース界隈では伝説的な存在だ。

QEMUは単体では完全なCPUエミュレーション（ソフトウェアによる命令の解釈実行）を行い、異なるアーキテクチャ間のエミュレーション（例えばx86上でARM命令を実行する）も可能だ。だが、同じアーキテクチャでの仮想化においては、CPUエミュレーションは非効率だ。

KVMとQEMUの組み合わせは、この問題を優雅に解決する。

```
QEMU + KVMの協調動作:

  ┌────────────────────────────────────────┐
  │ QEMU プロセス（ユーザ空間）            │
  │                                        │
  │ ┌─────────────────┐  ┌──────────────┐ │
  │ │ デバイスモデル   │  │ 仮想CPU      │ │
  │ │ ── 仮想ディスク  │  │ (vCPUスレッド)│ │
  │ │ ── 仮想NIC      │  │              │ │
  │ │ ── 仮想VGA      │  │   ioctl()    │ │
  │ │ ── 仮想USB      │  │   /dev/kvm   │ │
  │ └─────────────────┘  └──────┬───────┘ │
  └─────────────────────────────┼──────────┘
                                │
  ┌─────────────────────────────┼──────────┐
  │ Linuxカーネル + KVMモジュール          │
  │                             │          │
  │                      ┌──────┴───────┐  │
  │                      │ KVM         │  │
  │                      │ VMEntry     │  │
  │                      │   ↓         │  │
  │                      │ ゲストコード │  │
  │                      │ 実行        │  │
  │                      │   ↓         │  │
  │                      │ VMExit      │  │
  │                      └──────┬───────┘  │
  │                             │          │
  └─────────────────────────────┼──────────┘
                                │
  ┌─────────────────────────────┼──────────┐
  │ 物理CPU（VT-x/AMD-V）      │          │
  │                             ↓          │
  │              ゲストコードをネイティブ   │
  │              速度で実行                │
  └────────────────────────────────────────┘

  動作フロー:
  1. QEMUがioctl()で/dev/kvmにvCPU実行を要求
  2. KVMがVMEntryでゲストコードに制御を渡す
  3. ゲストコードがネイティブ速度で実行される
  4. I/Oアクセス等でVMExitが発生
  5. KVMがVMExitの理由を判定:
     a) KVMで処理可能 → カーネル内で処理し2へ戻る
     b) QEMUの処理が必要 → ユーザ空間に戻る
  6. QEMUがデバイスエミュレーションを処理
  7. 1へ戻る
```

CPU命令の実行はKVMがハードウェア仮想化支援を使ってネイティブ速度で行い、I/Oデバイスのエミュレーションはユーザ空間のQEMUが担当する。この分業体制により、CPUバウンドなワークロードでは物理マシンとほぼ同等の性能が出る。

### virtio——I/O性能のボトルネックを解消する

QEMU + KVMの組み合わせでCPU仮想化は解決した。だがI/Oに課題が残った。

QEMUのデバイスエミュレーションは、物理的なハードウェア（例えばIntelの e1000ネットワークカードやIDE/SATAディスクコントローラ）を忠実にソフトウェアでシミュレーションする。ゲストOSは「本物のe1000が搭載されている」と認識し、既存のデバイスドライバで動作する。互換性は高いが、性能は犠牲になる。物理ハードウェアの複雑な挙動を一つ一つソフトウェアでシミュレーションするからだ。

この問題を解決したのが、virtio（Virtual I/O）だ。

2008年、IBMのRusty Russellが「virtio: towards a de-facto standard for virtual I/O devices」をACM SIGOPS Operating Systems Reviewに発表した。virtioは、仮想化環境に最適化された準仮想化I/Oフレームワークだ。

virtioの発想はXenの準仮想化と共通する。物理ハードウェアのエミュレーションを忠実に行う代わりに、「仮想化環境であること」を前提とした効率的なインターフェースを設計する。ゲストOSにvirtioドライバをインストールすれば、ハイパーバイザと直接的かつ効率的にデータをやり取りできる。

```
I/Oの性能比較:

エミュレートデバイス（e1000等）:
  ゲストOS → e1000ドライバ → [I/Oポートアクセス]
     → VMExit → QEMU（e1000エミュレーション）
     → ホストカーネルのネットワークスタック
     → 物理NIC

  問題: VMExitが頻繁に発生し、
        エミュレーション処理のオーバーヘッドが大きい

virtioデバイス（virtio-net等）:
  ゲストOS → virtio-netドライバ
     → [共有メモリのリングバッファに直接書き込み]
     → ホストカーネルのvhostスレッドが処理
     → 物理NIC

  改善: VMExitの回数を大幅に削減
        データコピーを最小化
        バッチ処理による効率化
```

virtioは、vrings（仮想リング）と呼ばれるリングバッファベースのデータ転送メカニズムを採用している。ゲストOSとホストが共有メモリ上のリングバッファを通じてデータをやり取りすることで、VMExitの回数を減らし、データコピーを最小化する。

virtioはKVMだけでなく、Xen、VirtualBox、さらにはVMwareでも利用可能な設計となっている。ハイパーバイザに依存しない標準的なI/Oフレームワークとして、仮想化エコシステム全体の共通基盤となった。

### Red HatによるQumranet買収

KVMの成功は、Qumranetの価値を急速に高めた。

2008年9月4日、Red HatがQumranetを1億700万ドルで買収した。Red HatはKVMの開発リソース、そしてKVMのコアメンテナたちを獲得した。

この買収は、Red Hatの仮想化戦略を根本的に転換した。それまでRed HatはXenをRHEL（Red Hat Enterprise Linux）5の仮想化基盤として採用していた。だが、RHEL 6以降はKVMをデフォルトのハイパーバイザとし、Red Hat Enterprise Virtualization（RHEV、後にRed Hat Virtualization）というVMware対抗製品を展開した。

エンタープライズLinuxの最大手がKVMを全面的に支持したことで、KVMはデータセンター仮想化の主要な選択肢として確立された。

---

## 4. XenからNitroへ——AWSの仮想化基盤の進化

### AWSがXenを超えた日

2017年11月6日、AWSは re:Invent カンファレンスでC5インスタンスファミリーを発表した。このインスタンスは、Xenベースではなく、Nitroハイパーバイザという新しい基盤の上で動いていた。

NitroはKVMのコアカーネルモジュールをベースとしている。だが、QEMUは使っていない。ネットワーク処理、ストレージアクセス、セキュリティ機能を専用のNitroカードと呼ばれるハードウェアにオフロードし、ホストCPUの負荷を最小化する設計だ。

```
AWS仮想化基盤の進化:

2006-2017: Xenベース
  ┌────────────┐ ┌────────────┐
  │ EC2        │ │ EC2        │
  │ インスタンス│ │ インスタンス│
  └────────────┘ └────────────┘
  ┌─────────────────────────────┐
  │ Dom0（管理用Linux）         │
  │ ── ネットワーク処理         │
  │ ── ストレージ処理           │
  │ ── セキュリティ             │
  │ ── 管理API                  │← ホストCPUを消費
  ├─────────────────────────────┤
  │ Xenハイパーバイザ           │
  └─────────────────────────────┘
  │ 物理ハードウェア            │

  問題: Dom0がホストCPUの
        相当部分を消費

2017-: Nitro（KVMベース）
  ┌────────────┐ ┌────────────┐
  │ EC2        │ │ EC2        │
  │ インスタンス│ │ インスタンス│
  └────────────┘ └────────────┘
  ┌─────────────────────────────┐
  │ 軽量ハイパーバイザ          │
  │ （KVMベース、最小構成）     │← 最小限のCPU使用
  └─────────────────────────────┘
  │ 物理ハードウェア            │
  │ ┌─────────┐ ┌─────────┐   │
  │ │ Nitro   │ │ Nitro   │   │
  │ │ Card    │ │ Card    │   │
  │ │ (NW)    │ │ (EBS)   │   │← 専用HWで処理
  │ └─────────┘ └─────────┘   │
  │ ┌─────────────────────┐   │
  │ │ Nitro Security Chip │   │
  │ └─────────────────────┘   │

  改善: ホストCPUのほぼ全てを
        顧客のインスタンスに提供
```

XenからNitroへの移行は、2006年から2017年までの11年間のクラウド運用経験が凝縮された判断だった。Xenのアーキテクチャでは、Dom0（管理用Linux）がネットワーク処理やストレージI/Oを担当するため、ホストCPUのかなりの部分をAWS側の処理に消費していた。Nitroでは、これらの処理を専用ハードウェアにオフロードすることで、物理CPUのほぼ全てを顧客のインスタンスに提供できるようになった。

この移行は、オープンソース仮想化の進化の集大成とも言える。Xenで始まり、KVMベースのNitroへと進化した。オープンソースの仮想化技術が、世界最大のクラウドプラットフォームの基盤を形作り続けている。

### libvirt——仮想化管理の標準化

仮想化技術の多様化は、管理ツールの標準化という課題を生んだ。Xenには `xm`（後に `xl`）コマンド、KVMにはQEMUのコマンドライン引数、VMwareには独自のCLI。仮想化技術ごとに異なる管理インターフェースを学ぶ必要があった。

この問題を解決するために、2005年にRed HatのDaniel Veillardがlibvirtの開発を開始した。libvirtは、KVM、Xen、VMware ESXi、QEMUなど異なる仮想化技術を統一的に管理するAPIとデーモンを提供する。

libvirtのCLIインターフェースがvirshだ。virshを使えば、バックエンドがKVMでもXenでも、同じコマンドで仮想マシンを管理できる。

```bash
# KVMでもXenでも同じコマンド体系:
virsh list                    # 稼働中のVMを一覧
virsh start vm-name           # VM起動
virsh shutdown vm-name        # VMシャットダウン
virsh suspend vm-name         # VMサスペンド
virsh resume vm-name          # VMレジューム
virsh snapshot-create vm-name # スナップショット作成
```

このvirshの設計思想は、クラウドのAPIの原型と見ることができる。仮想マシンを「定義」し、「起動」し、「停止」し、「削除」する。状態を「確認」し、「スナップショット」を取り、「移行」する。これらの操作は、そのままAWS CLIやOpenStack CLIの設計に通じている。

仮想化管理の標準化は、クラウドの運用自動化の前提条件だった。libvirtがなければ、異なるハイパーバイザを統一的に扱うオーケストレーション層の構築は格段に困難だったはずだ。

---

## 5. ハンズオン——KVM + libvirtで仮想マシンのライフサイクル管理を体験する

ここからは、KVMとlibvirtを使って仮想マシンのライフサイクル管理を体験する。virshコマンドで仮想マシンを定義・起動・停止・削除し、クラウドAPIの原型となった「宣言的な仮想マシン管理」を手で確かめる。

### 環境

- Docker（Ubuntu 24.04ベースコンテナ、`--privileged` オプションとKVMデバイスアクセスが必要）
- ホストマシンがKVM（Intel VT-x/AMD-V）をサポートしていること

### 演習1：KVM環境のセットアップと仮想化機能の確認

```bash
# Docker環境に入る（KVMデバイスへのアクセスが必要）
docker run -it --rm --privileged \
  --device /dev/kvm:/dev/kvm \
  --name kvm-handson ubuntu:24.04 bash

# 必要なツールをインストール
apt-get update && apt-get install -y \
  qemu-system-x86 qemu-utils libvirt-daemon-system \
  libvirt-clients virtinst cpu-checker procps \
  bridge-utils iproute2 bc
```

```bash
echo "=== 演習1: KVM環境の確認 ==="
echo ""

# KVMサポートの確認
echo "--- ハードウェア仮想化サポートの確認 ---"

if [ -e /dev/kvm ]; then
  echo "/dev/kvm が存在: KVMが利用可能"
  ls -la /dev/kvm
else
  echo "/dev/kvm が存在しない"
  echo "ホストでKVMが有効化されているか確認してください"
fi
echo ""

# CPU仮想化フラグの確認
echo "--- CPU仮想化拡張の確認 ---"
if grep -q vmx /proc/cpuinfo; then
  echo "Intel VT-x (vmx) 検出"
  echo "  2005年11月にIntelが初めてリリースした"
  echo "  x86ハードウェア仮想化支援技術"
elif grep -q svm /proc/cpuinfo; then
  echo "AMD-V (svm) 検出"
  echo "  2006年にAMDがリリースした"
  echo "  x86ハードウェア仮想化支援技術"
else
  echo "仮想化拡張が見つからない"
fi
echo ""

# KVMモジュールの確認
echo "--- KVMカーネルモジュール ---"
lsmod | grep kvm || echo "(コンテナ環境ではlsmodが制限される場合があります)"
echo ""
echo "KVMはLinux 2.6.20（2007年2月）で"
echo "カーネルにマージされた。"
echo "現在のLinuxカーネルには標準で含まれている。"
echo ""

echo "=== 演習1完了 ==="
```

### 演習2：virshによる仮想マシンのライフサイクル管理

libvirtdを起動し、virshコマンドで仮想マシンを管理する。これはクラウドAPIの原型だ。

```bash
echo "=== 演習2: virshによるVM管理（クラウドAPIの原型） ==="
echo ""

# libvirtdの起動
echo "--- libvirtデーモンの起動 ---"
mkdir -p /run/libvirt
libvirtd -d 2>/dev/null || echo "libvirtd起動（エラーは無視可）"
sleep 2

# virshの接続確認
echo "--- virsh接続確認 ---"
virsh version 2>/dev/null
echo ""

# 仮想マシン用のディスクイメージを作成
echo "--- 仮想マシンのディスクイメージ作成 ---"
mkdir -p /var/lib/libvirt/images
qemu-img create -f qcow2 /var/lib/libvirt/images/test-vm.qcow2 1G
echo ""
echo "qcow2フォーマット:"
echo "  - QEMU Copy-On-Write version 2"
echo "  - 実際に使用した分だけディスクを消費（シンプロビジョニング）"
echo "  - スナップショットをサポート"
echo ""

# XML定義ファイルの作成（仮想マシンの「宣言的定義」）
echo "--- 仮想マシンのXML定義 ---"
echo "  クラウドAPIの原型: VMを宣言的に定義する"
echo ""

cat > /tmp/test-vm.xml << 'XMLEOF'
<domain type='kvm'>
  <name>test-vm</name>
  <memory unit='MiB'>256</memory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64' machine='pc'>hvm</type>
    <boot dev='hd'/>
  </os>
  <devices>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/test-vm.qcow2'/>
      <target dev='vda' bus='virtio'/>
    </disk>
    <interface type='network'>
      <source network='default'/>
      <model type='virtio'/>
    </interface>
  </devices>
</domain>
XMLEOF

echo "定義ファイルの内容:"
cat /tmp/test-vm.xml
echo ""
echo ""
echo "注目すべきポイント:"
echo "  - type='kvm' → KVMハイパーバイザを使用"
echo "  - bus='virtio' → 準仮想化I/Oドライバ（高速）"
echo "  - model type='virtio' → ネットワークもvirtio"
echo "  - memory/vcpu → リソース割り当ての宣言"
echo ""
echo "このXML定義は、AWSのEC2 LaunchTemplateや"
echo "OpenStackのFlavorに相当する概念だ。"
echo "VMの構成を「宣言的」に記述し、"
echo "APIを通じてライフサイクルを管理する。"
echo ""

echo "=== 演習2完了 ==="
```

### 演習3：仮想マシンの定義・操作・削除——CLIによるライフサイクル

```bash
echo "=== 演習3: VMのライフサイクル管理 ==="
echo ""

# 仮想マシンの定義（永続化）
echo "--- Step 1: VMの定義（virsh define） ---"
virsh define /tmp/test-vm.xml 2>/dev/null
echo ""
echo "define = VMの設定を永続化する"
echo "  → AWSで言えば: LaunchTemplateの作成"
echo ""

# VMの一覧確認
echo "--- Step 2: VM一覧の確認（virsh list --all） ---"
virsh list --all 2>/dev/null
echo ""
echo "list --all = 全VM（停止中含む）を表示"
echo "  → AWSで言えば: aws ec2 describe-instances"
echo ""

# VM情報の詳細表示
echo "--- Step 3: VM情報の確認（virsh dominfo） ---"
virsh dominfo test-vm 2>/dev/null
echo ""
echo "dominfo = VMの詳細情報"
echo "  → AWSで言えば: インスタンスのDescribe"
echo ""

# VMの起動（ディスクにOSがないため起動後すぐ停止するが、
# コマンド体系の理解が目的）
echo "--- Step 4: VMの起動試行（virsh start） ---"
virsh start test-vm 2>/dev/null || \
  echo "  (OSが未インストールのため起動エラーは想定内)"
echo ""
echo "start = VMの起動"
echo "  → AWSで言えば: aws ec2 start-instances"
echo ""

# VMの削除
echo "--- Step 5: VMの定義解除（virsh undefine） ---"
virsh undefine test-vm 2>/dev/null
echo ""
echo "undefine = VMの定義を削除"
echo "  → AWSで言えば: aws ec2 terminate-instances"
echo ""

# 削除後の確認
echo "--- Step 6: 削除確認 ---"
virsh list --all 2>/dev/null
echo ""

echo "--- virshコマンドとクラウドAPIの対応 ---"
echo ""
echo "  virshコマンド          AWS CLI相当"
echo "  ─────────────────────────────────────"
echo "  virsh define           LaunchTemplate作成"
echo "  virsh start            ec2 run-instances"
echo "  virsh list             ec2 describe-instances"
echo "  virsh shutdown         ec2 stop-instances"
echo "  virsh destroy          ec2 stop-instances（強制）"
echo "  virsh undefine         ec2 terminate-instances"
echo "  virsh snapshot-create  ec2 create-snapshot"
echo "  virsh migrate          (内部的にライブマイグレーション)"
echo ""
echo "クラウドのAPIは、libvirt/virshの設計思想を"
echo "HTTP API化し、スケーラブルにしたものと見ることができる。"
echo ""

echo "=== 演習3完了 ==="
```

### 演習4：virtio vs エミュレーションの設計比較

```bash
echo "=== 演習4: virtioの設計思想を理解する ==="
echo ""

echo "--- エミュレーションデバイス vs virtioデバイス ---"
echo ""
echo "仮想マシンのXML定義で、I/Oデバイスの指定方法が"
echo "性能を大きく左右する。"
echo ""

echo "[パターンA: エミュレーションデバイス（低速だが互換性が高い）]"
echo ""
cat << 'EOF'
    <!-- ディスク: IDE（レガシーエミュレーション） -->
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/vm.qcow2'/>
      <target dev='hda' bus='ide'/>  ← IDEコントローラをエミュレーション
    </disk>

    <!-- ネットワーク: e1000（レガシーエミュレーション） -->
    <interface type='network'>
      <source network='default'/>
      <model type='e1000'/>  ← Intel e1000 NICをエミュレーション
    </interface>
EOF
echo ""
echo "  → ゲストOSの既存ドライバで動作（追加ドライバ不要）"
echo "  → 各I/O操作でVMExitが発生し、QEMUがソフトウェアで処理"
echo "  → I/O性能が低い"
echo ""

echo "[パターンB: virtioデバイス（高速、推奨）]"
echo ""
cat << 'EOF'
    <!-- ディスク: virtio-blk（準仮想化I/O） -->
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/vm.qcow2'/>
      <target dev='vda' bus='virtio'/>  ← virtioバスを使用
    </disk>

    <!-- ネットワーク: virtio-net（準仮想化I/O） -->
    <interface type='network'>
      <source network='default'/>
      <model type='virtio'/>  ← virtio NICを使用
    </interface>
EOF
echo ""
echo "  → ゲストOSにvirtioドライバが必要"
echo "    （Linux 2.6.25以降は標準搭載、Windowsは要追加）"
echo "  → 共有メモリのリングバッファで効率的にデータ転送"
echo "  → VMExitの回数を大幅に削減"
echo "  → I/O性能がエミュレーション比で数倍向上"
echo ""

echo "--- virtioの歴史的意義 ---"
echo ""
echo "2008年、IBMのRusty Russellがvirtioを発表した。"
echo "virtioは「仮想化環境に最適化されたI/O」という"
echo "準仮想化の考え方をI/Oレイヤーに適用したものだ。"
echo ""
echo "Xenの準仮想化がCPU命令レベルの最適化だったのに対し、"
echo "virtioはI/Oレベルの準仮想化と言える。"
echo ""
echo "この設計は、AWSのENA（Elastic Network Adapter）や"
echo "EBS Optimizedインスタンスの設計思想にも通じている。"
echo "仮想化のI/Oパスを最適化することで、"
echo "物理マシンに近い性能を実現する——"
echo "この目標は、メインフレームの時代から変わっていない。"
echo ""

echo "=== 演習4完了 ==="
```

### この演習で何がわかるか

**第一に、仮想マシン管理の「宣言的定義」がクラウドAPIの原型であること。** virshのXML定義ファイルは、EC2のLaunchTemplateやOpenStackのFlavorに直結する概念だ。仮想マシンを「定義（define）」し、「起動（start）」し、「停止（shutdown）」し、「削除（undefine）」する——このライフサイクル管理のパターンは、そのままクラウドのインスタンス管理に受け継がれている。

**第二に、virtioの設計が仮想化I/Oの革命であったこと。** エミュレーションデバイス（e1000、IDE）とvirtioデバイスの違いは、完全仮想化と準仮想化の違いのI/O版だ。「物理ハードウェアを忠実に再現する」のか、「仮想化に最適化されたインターフェースを新設する」のか。後者を選ぶことで、I/O性能は劇的に改善される。この選択は、AWSのNitroアーキテクチャにまで影響を与えている。

**第三に、libvirtが仮想化技術の「抽象化レイヤー」であること。** virshコマンドはバックエンドがKVMでもXenでも同じように使える。この抽象化の思想は、クラウドAPIの設計に直接的に影響を与えた。特定のハイパーバイザに依存しない管理インターフェースの存在が、クラウドの運用自動化とオーケストレーションを可能にした。

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/07-opensource-virtualization/` に用意してある。

---

## 6. まとめと次回予告

### この回のまとめ

第7回では、オープンソース仮想化がどのようにVMwareの独占を崩し、クラウドの「民主化」を推し進めたかを追った。

**Xenは準仮想化という独自のアプローチで仮想化の世界に参入した。** 2003年、ケンブリッジ大学のIan Pratt率いるチームがSOSPで発表した「Xen and the Art of Virtualization」は、ゲストOSのカーネルを修正してハイパーバイザと協調させるという設計思想を提示した。バイナリトランスレーションのオーバーヘッドを回避し、ネイティブに迫る性能を実現した。Windowsが動かないという制約はあったが、Linuxサーバの仮想化においては強力な選択肢となり、AWS EC2の初期基盤に採用された。

**KVMは「Linuxカーネル自体がハイパーバイザになる」という設計で仮想化を変えた。** 2006年にAvi KivityがLinuxカーネルメーリングリストに投稿したKVMのパッチは、わずか2ヶ月でカーネルにマージされた。Intel VT-x/AMD-Vのハードウェア仮想化支援を前提とし、Linuxの既存機能（スケジューラ、メモリ管理、デバイスドライバ）をそのまま活用する設計は、コードの簡潔さと高い性能を両立した。2008年のRed HatによるQumranet買収（1億700万ドル）により、KVMはエンタープライズLinuxの標準仮想化基盤となった。

**QEMU + KVMの協調モデルとvirtioがI/O性能を解決した。** Fabrice Bellardが2003年に開発したQEMUがデバイスエミュレーションを担当し、KVMがCPU仮想化を担当する分業体制が確立された。2008年にRusty Russellが発表したvirtioは、準仮想化I/Oフレームワークとして仮想化のI/Oボトルネックを解消し、物理マシンに近い性能を実現した。

**AWSはXenからNitro（KVMベース）へ移行した。** 2006年にXenベースでEC2を開始したAWSは、2017年にKVMベースのNitroハイパーバイザを導入した。ネットワークとストレージを専用ハードウェアにオフロードすることで、ホストCPUのほぼ全てを顧客に提供するアーキテクチャを実現した。

**libvirt/virshが仮想化管理を標準化し、クラウドAPIの原型を作った。** 2005年にRed HatのDaniel Veillardが開始したlibvirtは、異なるハイパーバイザを統一的に管理するインターフェースを提供し、仮想マシンの宣言的定義とライフサイクル管理のパターンを確立した。

冒頭の問いに答えよう。「VMwareが切り拓いた仮想化の世界を、オープンソースはどう民主化したのか？」——XenとKVMは、仮想化技術からライセンスコストの壁を取り除いた。VMwareが「x86仮想化は可能である」と証明し、XenとKVMが「x86仮想化は誰もが利用可能である」と示した。AWSはその上にクラウドを構築した。オープンソース仮想化の民主化がなければ、クラウドコンピューティングのコスト構造は根本的に異なるものになっていたはずだ。

### 次回予告

第8回では、「AWS EC2（2006年）——『サーバを借りる』概念が変わった日」を探る。

ここまでの連載で、メインフレームの時分割からクライアント/サーバモデル、コロケーション、ホスティング、VMware、そしてXen/KVMと辿ってきた。計算資源の調達は、物理的な制約から徐々に解放されてきた。だが、いずれのモデルも「サーバを用意する」という行為自体は変わっていなかった。物理サーバを買うか借りるか、仮想マシンを立てるか——いずれにしても、「サーバの準備」には時間がかかり、「サーバの維持」にはコストがかかった。

2006年8月、AWSがEC2のパブリックベータを開始する。APIを叩けば数分でサーバが立ち上がり、使い終わったら捨てる。時間単位の課金。使い捨て可能なインフラ。この瞬間、「サーバを借りる」という概念そのものが変わった。

あなたは今、EC2インスタンスを「消耗品」として扱っているだろうか。その「使い捨ての発想」がどこから来たのか——次回、それを辿る。

---

## 参考文献

- Barham, P. et al., "Xen and the Art of Virtualization", SOSP 2003. <https://www.cl.cam.ac.uk/research/srg/netos/papers/2003-xensosp.pdf>
- XenServer, "The Birth of Xen: A Journey from XenoServers to Cloud Virtualization". <https://www.xenserver.com/story>
- Wikipedia, "Xen". <https://en.wikipedia.org/wiki/Xen>
- Linux Foundation, "Xen to Become Linux Foundation Collaborative Project", 2013. <https://www.linuxfoundation.org/press/press-release/xen-to-become-linux-foundation-collaborative-project>
- HPCwire, "Citrix Acquires XenSource", 2007. <https://www.hpcwire.com/2007/08/20/citrix_acquires_xensource/>
- Wikipedia, "Kernel-based Virtual Machine". <https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine>
- LWN.net, "Ten years of KVM", 2016. <https://lwn.net/Articles/705160/>
- Kivity, A., "kvm: the Linux Virtual Machine Monitor", OLS 2007. <https://www.kernel.org/doc/ols/2007/ols2007v1-pages-225-230.pdf>
- Red Hat, "Red Hat Advances Virtualization Leadership with Qumranet, Inc. Acquisition", 2008. <https://www.redhat.com/en/about/press-releases/qumranet>
- Russell, R., "virtio: towards a de-facto standard for virtual I/O devices", ACM SIGOPS Operating Systems Review, Vol.42, No.5, 2008. <https://ozlabs.org/~rusty/virtio-spec/virtio-paper.pdf>
- IBM Developer, "Virtio: An I/O virtualization framework for Linux". <https://developer.ibm.com/articles/l-virtio/>
- Wikipedia, "Libvirt". <https://en.wikipedia.org/wiki/Libvirt>
- Wikipedia, "QEMU". <https://en.wikipedia.org/wiki/QEMU>
- Gregg, B., "AWS EC2 Virtualization 2017: Introducing Nitro", 2017. <https://www.brendangregg.com/blog/2017-11-29/aws-ec2-virtualization-2017.html>
- AWS, "Amazon EC2 performance evolution and implementation". <https://docs.aws.amazon.com/whitepapers/latest/ec2-networking-for-telecom/amazon-ec2-performance-evolution-and-implementation.html>
