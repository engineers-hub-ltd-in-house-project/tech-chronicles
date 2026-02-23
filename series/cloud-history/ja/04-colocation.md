# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第4回：コロケーション——自分のサーバを他人の施設に預ける

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- コロケーションというビジネスモデルが生まれた経緯と、それが解決した問題
- インターネット商用化からドットコムバブルに至る1990年代のインフラ需要の爆発
- データセンターの物理層——電力冗長化、冷却設計、ネットワーク接続の仕組み
- Uptime Instituteのティア分類とSLAの考え方
- IPMI/BMCによるリモートサーバ管理の概念と基本操作

---

## 1. 秋葉原でラックマウントサーバを買った日

2002年の秋、私は秋葉原の中古パーツ店でラックマウントサーバを購入した。

1Uの薄い筐体。両手で抱えると、金属の塊の重さが腕にずしりと伝わる。20キロ近い。これを車のトランクに積み、首都高を走って都内のデータセンターに向かう。到着すると、受付で入館手続きを済ませ、台車にサーバを載せて搬入口からフロアに入る。空調の轟音が耳を塞ぐ。温度管理されたフロアの空気はひんやりと乾いていて、外の湿った秋の空気とはまるで別世界だった。

ラックの前に立つ。19インチラックの前面パネルを開け、レールを取り付け、サーバを滑り込ませる。電源ケーブルを挿す。LANケーブルを挿す。シリアルコンソールケーブルを繋ぐ。そしてサーバの電源ボタンを押す。ファンが回り始める。BIOSのPOST画面が流れ、やがてLinuxのカーネルがブートする。

この一連の作業を、私は何度も繰り返した。サーバを追加するたびに秋葉原に行き、車で運び、ラッキングし、ケーブリングする。深夜にハードウェア障害のアラートが鳴れば、タクシーでデータセンターに駆けつける。ディスクが壊れていれば交換し、メモリが故障していれば差し替え、電源ユニットが焼けていれば予備品に入れ替える。

「物理」から逃れられない。サーバとは、突き詰めれば鉄とシリコンの塊だ。電気を食い、熱を出し、壊れる。どれだけソフトウェアが洗練されても、その下には必ず物理的な制約がある。

だが、少なくとも一つの問題は解決されていた。サーバを自分のオフィスに置く必要がなかった。電力供給の安定性、冷却設備、物理的なセキュリティ、高速なネットワーク回線——これらはすべて、データセンターという専門施設が提供してくれた。私は「サーバの中身」に集中すればよかった。「サーバを置く場所」の問題は、他人に任せることができた。

これがコロケーションだ。

自分のサーバを、他人の施設に預ける。所有権はこちらにある。ハードウェアの選定も、OSのインストールも、アプリケーションの構築も、すべて自分が行う。だが「場所」——電力、冷却、ネットワーク、物理セキュリティ——は専門の施設が担う。「何を動かすか」と「どこで動かすか」の分離。この分離が、コロケーションの本質だった。

あなたが今使っているクラウドサーバ——そのEC2インスタンスやGCEの仮想マシン——が物理的にどこにあるか、考えたことがあるだろうか。リージョンとアベイラビリティゾーンの名前は知っているかもしれない。だが、その名前の先にあるのは、コンクリートと鉄骨で建てられた巨大な建物であり、その中には何千台ものサーバが整然とラックに収められ、分厚い電力ケーブルと冷却配管が張り巡らされている。その建物の設計思想は、私が2002年にサーバを預けたデータセンターと、本質的には同じだ。

---

## 2. インターネットの商用化——データセンター需要の爆発

### NSFNETの終焉と商用インターネットの誕生

コロケーションというビジネスモデルを理解するには、1990年代のインターネット商用化の文脈を知る必要がある。

1995年4月30日、NSFNET（National Science Foundation Network）バックボーンが廃止された。1986年から約10年にわたり、米国の学術機関を結ぶインターネットの基幹回線を担ってきたNSFNETは、その役目を商用ネットワークに引き渡した。NSFは1994年2月に4つのNAP（Network Access Point）——ニューヨーク（Sprint運営）、ワシントンD.C.（MFS運営）、シカゴ（Ameritech運営）、カリフォルニア（Pacific Bell運営）——の運用契約を締結し、商用バックボーン（MCI、PSINet、SprintLink、ANSNet等）がトラフィックを引き継ぐ新体制を構築していた。

この移行は、インターネットの性質を根本的に変えた。学術ネットワークから商用ネットワークへ。公的資金による運営から、民間企業間の競争と相互接続へ。「政府が資金を出し、学術機関が運営する」モデルは、「商用ネットワークが相互接続し、利用者がアクセスを購入する」モデルに置き換わった。

### ドットコムバブルとインフラ需要

1994年12月のNetscape Navigator公開、1995年8月のNetscape IPO（初日の終値は$58.25、公募価格$28の2倍以上）は、Webの商業的可能性を世界に知らしめた。企業はこぞってWebサイトを構築し、電子商取引に参入した。Amazon.comは1994年に設立され、1995年7月にオンライン書店を開業した。eBayは1995年9月に始まった。

この急激な商用化は、インフラに対する膨大な需要を生み出した。企業がWebサイトを公開するには、サーバが必要だ。そのサーバはインターネットに接続されている必要がある。24時間365日、安定して稼働している必要がある。

だが、1990年代後半の一般的な企業に、これらの要件を自力で満たす能力はなかった。オフィスのサーバルームでは、以下の問題が避けられない。

**電力**: オフィスビルの電力供給は、サーバ稼働に必要な安定性と容量を持たない。停電すればサーバは落ちる。UPS（無停電電源装置）を導入しても、長時間のバッテリー持続は期待できない。自家発電設備を備えるオフィスは稀だ。

**冷却**: サーバは熱を出す。1Uのサーバ1台で200〜300Wの発熱がある。ラック1本に40台積めば8,000〜12,000W。オフィスの空調では到底追いつかない。夏場にサーバルームの温度が上がり、サーバが熱暴走して停止する——1990年代の中小企業では珍しくない光景だった。

**ネットワーク**: 企業がインターネットに接続する回線は、1990年代後半では64kbps〜1.5MbpsのISDNやT1回線が一般的だった。Webサイトを公開してアクセスが集中すれば、回線はすぐに飽和する。複数のISPとの冗長接続やBGPルーティングなど、一般企業には手が出ない。

**物理セキュリティ**: サーバに格納されているのは顧客データだ。オフィスのサーバルームに入退室管理はあるか。監視カメラは。消火設備は。

これらの問題を一挙に解決するのが、専門のデータセンター施設だった。

### ISPとデータセンターの勃興

インターネットの商用化に伴い、ISP（Internet Service Provider）が急速に増加した。1995年時点で、米国ではNetcomとUUNETが主要ISPとして台頭し、各社の年間売上は4,000万〜5,000万ドル規模に達していた。

ISPは自社のネットワーク機器を収容する施設を必要とした。また、企業顧客のサーバを預かるサービス——これがコロケーションの原型だ——にも商機を見出した。1990年代後半のドットコムバブルはこの需要を爆発的に拡大させ、専用のデータセンター施設が次々と建設された。

ニューヨークの60 Hudson Streetや111 8th Avenueに代表される「キャリアホテル」——複数のネットワーク事業者が入居し、相互に接続できるビル——は、この時代に確立されたインフラの拠点だ。これらの施設は1990年代後半から2000年代初頭に稼働を開始し、2020年代の現在もインターネット接続の重要な結節点として機能し続けている。

---

## 3. コロケーションの設計——物理層の工学

### 電力：止まらないための設計

データセンターにとって電力は生命線だ。サーバは電気で動く。電気が止まれば、すべてが止まる。この当たり前の事実を、データセンターの設計者は「絶対に電気を止めない」という工学的課題として捉えた。

電力供給の信頼性を確保するために、データセンターは複数の防護層を重ねる。

**第一層：商用電力の冗長化。** 電力会社からの受電を、複数の変電所から独立した2系統で引き込む。一方の系統が停止しても、もう一方が全負荷を担える設計だ。

**第二層：UPS（Uninterruptible Power Supply、無停電電源装置）。** 商用電力が瞬断した場合、UPSのバッテリーが即座に負荷を引き継ぐ。UPSの役割は「非常用電源が起動するまでの橋渡し」だ。通常、数分から数十分のバッテリー持続時間を確保する。

**第三層：非常用発電機。** 商用電力の長時間停止に備え、ディーゼルまたはガスタービンの自家発電設備を備える。UPSが橋渡しをしている間に発電機が起動し、電力供給を引き継ぐ。燃料タンクの容量は、24時間以上の自律運転を想定して設計されることが多い。

これらの構成要素をどう組み合わせるかが、冗長化設計のレベルを決める。

```
電力冗長化の設計パターン:

N構成:
  必要な台数だけのUPS/発電機を配置
  冗長性なし。1台でも故障すれば影響が出る

N+1構成:
  必要台数 + 1台の予備を配置
  例: 3台必要なら4台配置。1台故障しても残り3台で継続
  → Tier II/III相当

2N構成:
  完全に独立した2系統を構築
  例: 3台必要なら、A系統3台 + B系統3台 = 6台配置
  一方の系統を完全停止してもサービス継続可能
  → Tier IV相当

2N+1構成:
  2N構成に加え、各系統にさらに1台の予備を追加
  最も高い信頼性。ただしコストも最大
```

私が2002年にサーバを預けたデータセンターは、おそらくN+1相当の設計だった。UPSと発電機はあったが、完全二重化ではなかった。一度だけ、商用電力の瞬断でUPSへの切り替わりが発生したことがある。館内のサーバは停止しなかったが、切り替わりの瞬間に微妙な電圧変動があったらしく、一部の古いサーバのディスクにエラーが記録された。「電力は止まらなかった。だが完全に安定していたわけでもない」——N+1と2Nの差は、こうした微妙な品質の違いに現れる。

### 冷却：熱との戦い

サーバは電気エネルギーの大半を熱に変換する。1Uサーバ1台の消費電力が300Wなら、その300Wのほぼすべてが最終的に熱となってデータセンターの空間に放出される。ラック1本に20台積めば6,000W。100本のラックで600kW。この熱を効率的に除去しなければ、サーバは熱暴走して停止する。

1992年、IBMのDr. Robert F. Sullivanがホットアイル/コールドアイルレイアウトを考案した。この設計は、データセンターの冷却効率を飛躍的に向上させた。

```
ホットアイル/コールドアイルレイアウト（上から見た図）:

    冷気 ↑↑↑ 冷気 ↑↑↑ 冷気    ← レイズドフロアからの冷気

    ┌────────┐         ┌────────┐
    │ ラック  │ コールド │ ラック  │
    │（前面）│ アイル   │（前面）│  ← サーバの吸気面が向き合う
    │  →→→  │  冷気   │  ←←←  │
    └────────┘         └────────┘

    ┌────────┐         ┌────────┐
    │ ラック  │ ホット   │ ラック  │
    │（背面）│ アイル   │（背面）│  ← サーバの排気面が向き合う
    │  ←←←  │  暖気   │  →→→  │
    └────────┘         └────────┘

    暖気 ↓↓↓ 暖気 ↓↓↓ 暖気    → 天井を通ってCRACユニットへ

CRAC: Computer Room Air Conditioning（コンピュータルーム空調装置）
```

原理は単純だ。サーバの吸気面（前面）同士を向かい合わせにすると、その通路にはCRAC（Computer Room Air Conditioning）ユニットからの冷気だけが満たされる。これがコールドアイルだ。サーバは冷気を吸い込み、内部のCPUやメモリを冷却し、温まった空気を背面から排出する。背面同士が向き合う通路——ホットアイル——には暖気が溜まり、天井を通ってCRACユニットに戻される。

冷気と暖気が混ざらないように分離する。これだけのことで冷却効率は劇的に向上する。混合してしまうと、冷気の温度が上がり、サーバの冷却に必要な空調能力が増大する。NYSERDAの調査によれば、大規模データセンターの約3分の2がこのレイアウトを採用している。

レイズドフロア（二重床）も重要な要素だ。床下の空間を空調のプレナム（送気チャンバー）として利用し、穴あきタイルから冷気をコールドアイルに送り込む。床下の配線整理という実用的な利点もあった。

### ネットワーク：インターネットへの接続

コロケーション施設の第三の柱がネットワーク接続だ。

データセンターにサーバを置く最大の理由の一つは、高速で冗長なネットワーク接続を得ることにある。1990年代後半、企業のオフィスからのインターネット接続はISDN（64kbps〜128kbps）やT1回線（1.544Mbps）が主流だった。データセンターは、これとは桁違いの帯域を提供した。

大規模なコロケーション施設は複数のネットワーク事業者（キャリア）と直接接続されている。これが「キャリアニュートラル」の概念だ。

```
キャリアニュートラルなコロケーション施設のネットワーク構成:

                ┌─────────────────────┐
                │  コロケーション施設  │
                │                     │
    ISP A ◆────┤  ┌──────────────┐  ├────◆ ISP D
                │  │ 顧客サーバ    │  │
    ISP B ◆────┤  │  ラック群     │  ├────◆ ISP E
                │  └──────────────┘  │
    ISP C ◆────┤                     │
                │  ┌──────────────┐  │
                │  │ IXP          │  │  ← インターネットエクスチェンジ
                │  │ (ピアリング) │  │     ポイント
                │  └──────────────┘  │
                └─────────────────────┘

◆ = 物理的な回線引き込み（ファイバー）
```

キャリアニュートラルとは、特定のネットワーク事業者に縛られないことを意味する。顧客は複数のISPから最適な事業者を選択でき、冗長化のために複数のISPと契約することもできる。1998年にJay AdelsonとAl Averyが設立したEquinixは、まさにこのキャリアニュートラルの理念を中核に据えたデータセンター事業者だった。社名のEquinixは「Equality, Neutrality, Internet eXchange」に由来する。ネットワーク事業者による囲い込みを排し、競合するネットワーク同士が対等に接続できる場を提供する。両者はDigital Equipment Corporation（DEC）の施設管理者出身で、キャリア間の接続の非効率さを現場で目の当たりにしていた。

コロケーション施設はIXP（Internet Exchange Point）の物理的な拠点としても機能した。IXPとは、複数のネットワーク事業者がBGP（Border Gateway Protocol）を使ってトラフィックを直接交換する場所だ。最初のIXPであるCIX（Commercial Internet eXchange）は、UUNET、PSINet、CERFNETがNSFNETの利用規程（AUP）に縛られずにトラフィックを交換するために設立された。コロケーション施設内のクロスコネクト——物理的なケーブル1本で2つのネットワークを直結する——は、通信事業者の中継回線よりもはるかに低いレイテンシーと低コストで相互接続を実現した。

---

## 4. Uptime Instituteのティア分類とSLA——信頼性の定量化

### ティア分類：データセンターの「格付け」

データセンターの信頼性をどう評価するか。顧客がコロケーション施設を選ぶとき、「うちの施設は信頼性が高い」という営業トークだけでは判断できない。客観的な指標が必要だ。

Uptime Instituteが1990年代半ばに策定したティア分類システムは、この問題に対する業界標準の回答となった。2020年代の現在、122カ国以上で4,000件を超えるTier認証が発行されている。

```
Uptime Institute ティア分類:

Tier I  : Basic Capacity（基本容量）
           - 単一の電力・冷却経路
           - 冗長コンポーネントなし
           - メンテナンス時にはサービス停止が必要
           - 年間稼働率: 99.671%（年間最大28.8時間のダウンタイム）

Tier II : Redundant Capacity（冗長容量）
           - 冗長コンポーネント（N+1のUPS、発電機等）
           - 単一の配電経路
           - メンテナンス時にサービス停止が発生しうる
           - 年間稼働率: 99.741%（年間最大22.7時間）

Tier III: Concurrently Maintainable（同時保守可能）
           - 冗長コンポーネント + 冗長配電経路
           - 計画停止なしでメンテナンス可能
           - 非計画停止（障害）には脆弱
           - 年間稼働率: 99.982%（年間最大1.6時間）

Tier IV : Fault Tolerant（耐障害性）
           - 独立した複数系統の電力・冷却
           - 計画停止・非計画停止のいずれでもサービス継続
           - 単一障害点（SPOF）の排除
           - 年間稼働率: 99.995%（年間最大26.3分）
```

Tier IとTier IVの差は数字以上に大きい。Tier Iでは年間28.8時間のダウンタイムが許容される。月に1回、2時間のメンテナンス停止があっても仕様の範囲内だ。一方、Tier IVでは年間のダウンタイムが26.3分以内。UPSの交換も、発電機の点検も、冷却装置の修理も、すべてサービスを稼働させたまま実施できる設計が求められる。

この差はコストに直結する。Tier IVの施設を建設するには、電力系統、冷却系統、ネットワーク経路のすべてを完全に二重化する必要がある。建設コストはTier Iの数倍に達する。だが、金融機関や医療機関のように「1分たりとも止められない」システムにとっては、このコストは正当化される。

私が経験した範囲では、中小企業のWebサービスにTier IV施設は過剰だった。多くの場合、Tier IIまたはTier IIIの施設で十分だ。だが、障害が起きたときにTier IIとTier IIIの違いが如実に現れる。Tier IIの施設でUPSの交換が必要になったとき、「来月の深夜にメンテナンス停止があります」と通知が来る。Tier IIIなら、そのメンテナンスはサービスを稼働させたまま行われる。この差を「小さい」と見るか「致命的」と見るかは、ビジネスの性質による。

### SLA：信頼性を契約にする

ティア分類がデータセンターの「設計上の信頼性」を示すのに対し、SLA（Service Level Agreement）は「契約上の保証」を提供する。

SLAの概念は1980年代後半の通信事業者に起源を持つ。ネットワークサービスの品質を定量的に測定し、一定の水準を下回った場合に補償を行う——この仕組みが、1990年代にITIL（Information Technology Infrastructure Library）フレームワークを通じてIT業界全体に広まった。

コロケーション事業者のSLAは、典型的に以下の項目を定義する。

**電力可用性**: 「99.99%の電力稼働率を保証する。」これは年間52.6分以内のダウンタイムを意味する。SLAを下回った場合、月額料金の一定割合がクレジットとして返還される。

**ネットワーク可用性**: 施設のネットワークインフラの稼働率保証。ただし、顧客が契約するISPの障害はSLAの対象外であることが多い。

**温湿度管理**: サーバルームの温度を18〜27℃、湿度を40〜60%の範囲に維持する。

**物理セキュリティ**: 入退室管理、監視カメラ、生体認証の提供。

SLAの重要性は、単なる「保証」にとどまらない。SLAは「信頼性の定量化」という概念を確立した。「うちのデータセンターは信頼できます」ではなく、「99.99%の電力稼働率を保証し、それを下回った場合は月額料金の10%をクレジットします」——この具体性が、コロケーション事業者と顧客の間に透明な関係を築いた。

この概念は、そのままクラウドに引き継がれている。AWSのEC2のSLAは99.99%の月間稼働率を保証し、99.99%〜99.0%の場合は10%のクレジット、99.0%未満の場合は30%のクレジットを返還する。クラウドのSLAは、コロケーション時代に確立された「信頼性の契約化」の直系の子孫だ。

---

## 5. コロケーションの限界——「場所」は解決しても「運用」は残る

### 物理サーバの調達リードタイム

コロケーションは「場所」の問題を解決した。だが、サーバそのものの調達と運用は、依然として顧客の責任だった。

サーバを追加したい。まず、要件を定義する。CPUは何が必要か。メモリはどれだけ要るか。ストレージの容量は。RAID構成は。次に、ベンダーに見積もりを依頼する。発注する。納品を待つ。納品されたら検品し、OSをインストールし、アプリケーションを構成し、データセンターに搬入し、ラッキングし、ケーブリングし、動作確認する。

このプロセスに、最短でも1〜2週間。通常は数週間から1ヶ月。カスタム構成やサーバの在庫状況によっては2ヶ月以上かかることもあった。

Webサービスのトラフィックが急増したとき——たとえばテレビで紹介されてアクセスが10倍になったとき——この調達リードタイムは致命的だ。2週間後にサーバが届いても、ビジネスチャンスは今日なのだ。

### キャパシティプランニングの困難

調達リードタイムが長いということは、将来のリソース需要を事前に予測して発注しなければならないことを意味する。これがキャパシティプランニングだ。

「来月のトラフィックは今月の1.5倍になるだろう」と予測して、サーバを追加発注する。予測が当たればよい。だが、外れたらどうなるか。

過小予測した場合: サーバが足りず、サービスが遅延する。あるいは落ちる。機会損失が発生する。

過大予測した場合: 使われないサーバが遊んでいる。ハードウェアの減価償却費と月額のラック料金が無駄になる。

どちらに外れても損失が発生する。だが実務では「足りないよりはマシ」という判断で過剰に調達する傾向があった。その結果、サーバの平均利用率は驚くほど低かった。多くの環境で、CPUの平均利用率が10〜20%に留まっていた。80%以上のCPU容量が、ピーク時に備えて「遊んでいる」状態だ。

この非効率が、後のクラウドコンピューティングの動機の一つとなる。「必要なときに必要なだけリソースを調達し、不要になったら返却する」——EC2の従量課金モデルは、コロケーション時代のキャパシティプランニングの苦痛を直接的に解消するものだった。

### 深夜の障害対応

物理サーバは壊れる。ディスクは故障する。メモリにはビットエラーが発生する。電源ユニットは経年劣化で出力が不安定になる。ファンは止まる。

コロケーションの場合、ハードウェア障害の対応は顧客の責任だ。データセンター側が提供するのは「場所と環境」であって、サーバの中身には手を出さない。

深夜3時、監視システムがアラートを発する。ディスクのS.M.A.R.T.値が閾値を超えた。RAID5構成のディスク1本が脱落し、デグレード状態で動いている。もう1本壊れたらデータが消える。

タクシーに飛び乗り、データセンターに向かう。受付で入館手続き。エレベーターで該当フロアに上がる。ラックの前でベゼルを外し、故障したディスクのLEDを確認する。スペアディスクを挿入し、リビルドが始まるのを見届ける。すべてが正常に戻ったことを確認して、また帰る。

この経験を何度も繰り返すと、「リモートからハードウェアを管理できないか」という切実な願望が生まれる。これがIPMI/BMCの価値だ。

### IPMI/BMC——リモートの手

IPMI（Intelligent Platform Management Interface）は、1998年にIntelが主導して策定したサーバのリモート管理仕様だ。サーバのマザーボードに搭載されたBMC（Baseboard Management Controller）という専用のマイクロコントローラが、サーバ本体のOSとは独立して動作し、ハードウェアの監視と制御を担う。

BMCの決定的な特徴は、サーバ本体の電源状態に依存しないことだ。サーバの電源がオフでも、OSがフリーズしていても、BMCは独立した電源で動作し、ネットワーク経由でアクセスできる。

```
IPMI/BMCのアーキテクチャ:

    ┌─────────────────────────────────────┐
    │  サーバ本体                         │
    │  ┌────────────────────────────────┐ │
    │  │ OS (Linux / Windows)          │ │
    │  │  └── アプリケーション          │ │
    │  └────────────────────────────────┘ │
    │                                      │
    │  ┌────────────────────────────────┐ │
    │  │ BMC（マイクロコントローラ）    │ │  ← OS とは独立して動作
    │  │  - 温度センサー監視            │ │
    │  │  - ファン回転数監視            │ │
    │  │  - 電源状態制御                │ │
    │  │  - シリアルコンソール          │ │
    │  │  - 独立したNICを持つ           │ │
    │  └─────────────┬──────────────────┘ │
    └─────────────────┼──────────────────────┘
                       │ 専用の管理ネットワーク
                       ▼
              ┌──────────────────┐
              │ 管理端末          │
              │ (ipmitool等)     │
              └──────────────────┘
```

IPMI v1.0（1998年9月）は基本的なハードウェア監視を提供した。v1.5（2001年2月）でIPMI over LANが追加され、ネットワーク経由のリモート管理が可能になった。これがコロケーション環境における遠隔管理の転換点だった。v2.0（2004年2月）ではSerial over LANが追加され、BIOSの設定画面やOSの起動プロセスさえもリモートから操作できるようになった。

深夜3時のディスク障害。IPMI以前は、データセンターに駆けつけるしかなかった。IPMIがあれば、自宅のPCからBMCにアクセスし、サーバの電源状態を確認し、必要に応じてリモートからリブートし、シリアルコンソール経由でOSのログを確認できる。ハードウェアの物理的な交換はさすがにリモートでは不可能だが、「今すぐ行く必要があるのか、明日の朝でよいのか」の判断をリモートで下せるだけでも、運用者の生活の質は劇的に変わった。

このIPMI/BMCの「OSとは独立したリモート管理チャネル」という設計思想は、クラウドにもそのまま受け継がれている。AWS EC2インスタンスのシリアルコンソール接続機能、GCPのCompute Engineのシリアルポートログ——いずれもBMCの思想を仮想化環境で再現したものだ。

---

## 6. ハンズオン——IPMI/BMCの概念とサーバのリモート管理を体感する

ここからは、IPMI/BMCの概念を擬似的に再現し、コロケーション時代の「リモートからの物理サーバ管理」を体感する。実際のIPMI対応ハードウェアがなくても、その設計思想を理解できるよう、ソフトウェアで管理チャネルの概念を再現する。

### 環境

- Docker（Ubuntu 24.04ベースコンテナ）
- Python 3（標準ライブラリのみ使用）
- Linux標準ツール

### 演習1：BMCシミュレータ——OSとは独立した管理チャネル

BMCの核心的な設計思想——「サーバ本体のOSとは独立した管理チャネル」——を再現する。

```bash
# Docker環境に入る
docker run -it --rm --name colo-handson ubuntu:24.04 bash

# 必要なツールをインストール
apt-get update && apt-get install -y python3 procps iproute2 net-tools
```

BMCシミュレータを作成する。このプログラムは「サーバ本体」とは独立して動作し、ハードウェアセンサーの情報を提供する管理サービスだ。

```python
# bmc_simulator.py - BMCシミュレータ
import socket
import json
import threading
import time
import random
import os
import signal

# BMCが監視する「センサー」データ（実機ではハードウェアセンサーから取得）
class HardwareSensors:
    def __init__(self):
        self.power_state = "on"
        self.cpu_temp = 45.0
        self.inlet_temp = 22.0
        self.fan1_rpm = 3200
        self.fan2_rpm = 3150
        self.psu1_watts = 280
        self.psu2_watts = 275
        self.disk_health = {"sda": "OK", "sdb": "OK", "sdc": "OK", "sdd": "OK"}
        self.uptime_seconds = 0
        self.boot_count = 1

    def update(self):
        """センサー値を定期更新（実機では実際のハードウェアから読み取る）"""
        if self.power_state == "on":
            self.uptime_seconds += 1
            self.cpu_temp = 45.0 + random.uniform(-3, 8)
            self.inlet_temp = 22.0 + random.uniform(-1, 2)
            self.fan1_rpm = 3200 + random.randint(-100, 100)
            self.fan2_rpm = 3150 + random.randint(-100, 100)
            self.psu1_watts = 280 + random.randint(-20, 20)
            self.psu2_watts = 275 + random.randint(-20, 20)

    def to_dict(self):
        return {
            "power_state": self.power_state,
            "cpu_temp_celsius": round(self.cpu_temp, 1),
            "inlet_temp_celsius": round(self.inlet_temp, 1),
            "fan1_rpm": self.fan1_rpm,
            "fan2_rpm": self.fan2_rpm,
            "psu1_watts": self.psu1_watts,
            "psu2_watts": self.psu2_watts,
            "disk_health": self.disk_health,
            "uptime_seconds": self.uptime_seconds,
            "boot_count": self.boot_count,
        }

sensors = HardwareSensors()

def sensor_update_loop():
    while True:
        sensors.update()
        time.sleep(1)

# BMCの管理インターフェース（実機ではIPMI over LAN）
def handle_command(command):
    cmd = command.get("action", "")

    if cmd == "sensor_reading":
        return {"status": "ok", "sensors": sensors.to_dict()}

    elif cmd == "power_status":
        return {"status": "ok", "power": sensors.power_state}

    elif cmd == "power_off":
        sensors.power_state = "off"
        sensors.cpu_temp = 0
        sensors.fan1_rpm = 0
        sensors.fan2_rpm = 0
        return {"status": "ok", "message": "Server powered off"}

    elif cmd == "power_on":
        sensors.power_state = "on"
        sensors.cpu_temp = 35.0
        sensors.fan1_rpm = 3200
        sensors.fan2_rpm = 3150
        sensors.boot_count += 1
        return {"status": "ok", "message": f"Server powered on (boot #{sensors.boot_count})"}

    elif cmd == "power_cycle":
        sensors.power_state = "off"
        time.sleep(1)
        sensors.power_state = "on"
        sensors.boot_count += 1
        return {"status": "ok", "message": f"Server power cycled (boot #{sensors.boot_count})"}

    elif cmd == "sel_list":
        # System Event Log（システムイベントログ）
        events = [
            {"id": 1, "time": "2002-10-15 03:22:11", "sensor": "PSU1",
             "event": "Power Supply AC Lost"},
            {"id": 2, "time": "2002-10-15 03:22:11", "sensor": "UPS",
             "event": "UPS Switchover - Battery Mode"},
            {"id": 3, "time": "2002-10-15 03:22:45", "sensor": "PSU1",
             "event": "Power Supply AC Restored"},
            {"id": 4, "time": "2002-11-03 14:05:33", "sensor": "CPU1 Temp",
             "event": "Upper Critical - Going High - Reading 82 > Threshold 80"},
            {"id": 5, "time": "2002-11-03 14:06:01", "sensor": "Fan1",
             "event": "Fan Speed Increased to Maximum"},
        ]
        return {"status": "ok", "events": events}

    elif cmd == "simulate_disk_failure":
        sensors.disk_health["sdc"] = "FAILING - S.M.A.R.T. Predictive Failure"
        return {"status": "ok", "message": "Disk sdc marked as failing",
                "alert": "WARNING: Disk sdc S.M.A.R.T. threshold exceeded"}

    else:
        return {"status": "error", "message": f"Unknown command: {cmd}"}

# BMCサーバ起動
HOST = '127.0.0.1'
PORT = 623  # IPMIの標準ポート

update_thread = threading.Thread(target=sensor_update_loop, daemon=True)
update_thread.start()

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(5)
    print(f"BMCシミュレータ起動: {HOST}:{PORT}")
    print("（実機ではマザーボード上のマイクロコントローラとして常駐）")

    s.settimeout(120)
    try:
        while True:
            conn, addr = s.accept()
            with conn:
                data = conn.recv(4096)
                if data:
                    command = json.loads(data.decode('utf-8'))
                    response = handle_command(command)
                    conn.sendall(json.dumps(response).encode('utf-8'))
    except socket.timeout:
        pass
```

管理クライアント（ipmitoolの簡易版）を作成する。

```python
# bmc_client.py - BMC管理クライアント（ipmitool相当）
import socket
import json
import sys

HOST = '127.0.0.1'
PORT = 623

def send_command(action):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        s.sendall(json.dumps({"action": action}).encode('utf-8'))
        data = s.recv(4096)
        return json.loads(data.decode('utf-8'))

def print_sensors(data):
    s = data["sensors"]
    print(f"  電源状態       : {s['power_state']}")
    print(f"  CPU温度        : {s['cpu_temp_celsius']}°C")
    print(f"  吸気温度       : {s['inlet_temp_celsius']}°C")
    print(f"  Fan1 回転数    : {s['fan1_rpm']} RPM")
    print(f"  Fan2 回転数    : {s['fan2_rpm']} RPM")
    print(f"  PSU1 消費電力  : {s['psu1_watts']}W")
    print(f"  PSU2 消費電力  : {s['psu2_watts']}W")
    print(f"  ディスク状態   :")
    for disk, status in s['disk_health'].items():
        marker = "!!" if status != "OK" else "  "
        print(f"    {marker} {disk}: {status}")
    print(f"  稼働時間       : {s['uptime_seconds']}秒")
    print(f"  起動回数       : {s['boot_count']}回")

if len(sys.argv) < 2:
    print("使い方: python3 bmc_client.py <command>")
    print("  sensor  - センサー値を表示")
    print("  power   - 電源状態を表示")
    print("  off     - 電源オフ")
    print("  on      - 電源オン")
    print("  cycle   - 電源サイクル（再起動）")
    print("  sel     - システムイベントログ表示")
    print("  fail    - ディスク障害をシミュレート")
    sys.exit(1)

cmd = sys.argv[1]
commands = {
    "sensor": "sensor_reading",
    "power": "power_status",
    "off": "power_off",
    "on": "power_on",
    "cycle": "power_cycle",
    "sel": "sel_list",
    "fail": "simulate_disk_failure",
}

if cmd not in commands:
    print(f"不明なコマンド: {cmd}")
    sys.exit(1)

result = send_command(commands[cmd])

if cmd == "sensor":
    print("--- センサーレポート ---")
    print_sensors(result)
elif cmd == "sel":
    print("--- システムイベントログ ---")
    for event in result.get("events", []):
        print(f"  [{event['id']}] {event['time']} | {event['sensor']}: {event['event']}")
elif cmd == "power":
    print(f"電源状態: {result.get('power', 'unknown')}")
else:
    print(result.get("message", json.dumps(result)))
    if "alert" in result:
        print(f"\n*** ALERT: {result['alert']} ***")
```

```bash
# BMCシミュレータを起動
python3 bmc_simulator.py &
sleep 2

# センサー値を確認（ipmitool sensor list 相当）
python3 bmc_client.py sensor

# 電源状態を確認（ipmitool chassis power status 相当）
python3 bmc_client.py power

# システムイベントログを確認（ipmitool sel list 相当）
python3 bmc_client.py sel
```

実際のipmitoolコマンドでは、以下のように操作する。

```bash
# 実機でのipmitool操作例（参考）

# リモートサーバのセンサー値を確認
# ipmitool -I lanplus -H 192.168.1.100 -U admin -P password sensor list

# リモートサーバの電源状態を確認
# ipmitool -I lanplus -H 192.168.1.100 -U admin -P password chassis power status

# リモートサーバを再起動
# ipmitool -I lanplus -H 192.168.1.100 -U admin -P password chassis power cycle

# システムイベントログを表示
# ipmitool -I lanplus -H 192.168.1.100 -U admin -P password sel list
```

### 演習2：深夜のディスク障害シナリオ

コロケーション運用の典型的な障害対応を再現する。

```bash
# BMCシミュレータが起動している状態で:

echo ""
echo "=== シナリオ: 深夜3時、監視アラート発報 ==="
echo ""

# 1. ディスク障害を発生させる
python3 bmc_client.py fail

echo ""
echo "--- リモートから状況確認 ---"
echo ""

# 2. センサーで状態を確認
python3 bmc_client.py sensor

echo ""
echo "--- 判断: ディスク1本の障害。RAID構成なら即座のデータセンター"
echo "          駆けつけは不要。明朝の交換で対応可能 ---"
```

### 演習3：電力冗長化の概念をシミュレート

データセンターの電力冗長化設計を、プロセスモデルで体感する。

```python
# power_redundancy.py - 電力冗長化シミュレータ
import random
import time

class PowerSource:
    def __init__(self, name, reliability=0.999):
        self.name = name
        self.reliability = reliability
        self.is_up = True

    def tick(self):
        """各時間ステップで障害が発生するかチェック"""
        if self.is_up:
            if random.random() > self.reliability:
                self.is_up = False
                return f"  !! {self.name} が停止しました"
        else:
            # 10%の確率で復旧
            if random.random() < 0.1:
                self.is_up = True
                return f"  >> {self.name} が復旧しました"
        return None

def simulate(name, sources, hours=8760):
    """電力構成をシミュレートし、年間ダウンタイムを計算"""
    downtime_hours = 0
    events = []

    for hour in range(hours):
        for source in sources:
            event = source.tick()
            if event:
                events.append((hour, event))

        # サーバが稼働できるか判定
        active = sum(1 for s in sources if s.is_up)
        required = len(sources) // 2 if "2N" in name else len(sources) - 1

        if active < max(1, required):
            downtime_hours += 1

    uptime_pct = ((hours - downtime_hours) / hours) * 100
    print(f"\n{'='*50}")
    print(f"構成: {name}")
    print(f"電源数: {len(sources)}")
    print(f"シミュレーション期間: {hours}時間（1年間）")
    print(f"ダウンタイム: {downtime_hours}時間")
    print(f"稼働率: {uptime_pct:.3f}%")
    if events[:5]:
        print(f"最初の5イベント:")
        for hour, event in events[:5]:
            print(f"  [{hour}h]{event}")
    return uptime_pct

print("電力冗長化設計のシミュレーション")
print("（各電源の個別信頼性: 99.9%）")

# N構成（冗長なし）: 電源1台
simulate("N（冗長なし）",
         [PowerSource("PSU-A", 0.999)])

# N+1構成: 電源2台（1台で運用可能 + 1台予備）
simulate("N+1",
         [PowerSource("PSU-A", 0.999),
          PowerSource("PSU-B", 0.999)])

# 2N構成: 完全二重化（A系統2台 + B系統2台）
simulate("2N",
         [PowerSource("A系統-1", 0.999),
          PowerSource("A系統-2", 0.999),
          PowerSource("B系統-1", 0.999),
          PowerSource("B系統-2", 0.999)])
```

```bash
python3 power_redundancy.py
```

この演習のポイントは、冗長化の段階によってダウンタイムがどう変わるかを定量的に確認することだ。個々の電源ユニットの信頼性が同じ99.9%でも、N構成、N+1構成、2N構成では年間のダウンタイムが桁違いに変わる。Uptime InstituteのTier分類が定義している「基本容量」と「耐障害性」の差は、この冗長化設計の差に直結している。

### この演習で何がわかるか

**第一に、BMC/IPMIはOSとは独立した管理チャネルである。** サーバのOSがフリーズしていても、電源がオフでも、BMCは生きている。この「独立性」が、リモート管理の信頼性を支えている。クラウドのインスタンスメタデータサービスやシリアルコンソール機能は、この思想の延長線上にある。

**第二に、リモート管理は「行かなくて済む」判断を可能にする。** ディスク障害が発生しても、RAID構成が維持されていれば即座の対応は不要かもしれない。センサー値をリモートで確認し、緊急度を判断できることが、運用者の負担を大幅に軽減する。

**第三に、冗長化設計はコストと信頼性のトレードオフである。** 電源を二重化すれば信頼性は上がるが、コストも上がる。どこまで冗長化するかは、ビジネス要件とコストのバランスで決まる。この判断は、クラウドでマルチAZ構成を取るかシングルAZで済ませるかという現代の判断と、本質的に同じ問題だ。

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/04-colocation/` に用意してある。

---

## 7. まとめと次回予告

### この回のまとめ

第4回では、コロケーション——自分のサーバを専門の施設に預けるというモデル——を探った。

**インターネットの商用化がデータセンター需要を爆発させた。** 1995年のNSFNET廃止と商用バックボーンへの移行、Netscape IPOに象徴されるWebの商業化が、安定したサーバ運用環境への需要を急激に高めた。オフィスのサーバルームでは電力、冷却、ネットワーク、セキュリティのすべてが不十分だった。

**コロケーションは「場所」の問題を解決した。** 電力の冗長化（N+1、2N構成）、効率的な冷却設計（ホットアイル/コールドアイル）、キャリアニュートラルなネットワーク接続——データセンターはこれらの専門的なインフラを提供し、顧客は「サーバの中身」に集中できるようになった。1998年にEquinixが設立され、キャリアニュートラルの理念が確立された。

**信頼性の定量化が確立された。** Uptime Instituteのティア分類（Tier I〜IV）はデータセンターの設計信頼性を客観的に評価する基準を提供し、SLAは信頼性を契約上の保証として定義した。この「信頼性の定量化」の概念は、クラウドのSLAに直接引き継がれている。

**IPMI/BMCはリモート管理の基盤を築いた。** OSとは独立した管理チャネルという設計思想は、物理サーバの遠隔監視と制御を可能にし、コロケーション運用の負担を大幅に軽減した。

**だが、コロケーションの限界も明確だった。** サーバの調達リードタイムは最短でも1〜2週間。キャパシティプランニングの困難さは過剰な先行投資を招いた。ハードウェア障害の対応は顧客の責任であり続けた。「場所」は解決しても、「サーバの調達」と「運用」の問題は残された。

冒頭の問いに答えよう。「自分のサーバを自分で管理するが、場所は借りる」——このモデルは何を解決し、何を残したか。解決したのは、インフラの物理層——電力、冷却、ネットワーク、セキュリティ——の専門化と効率化だ。残したのは、サーバの調達と運用の負担、そしてキャパシティプランニングの困難さだ。この「残された問題」が、次の時代への動機となった。

### 次回予告

第5回では、「ホスティングサービス——サーバ管理を他人に委ねる」を探る。

コロケーションは「場所」の問題を解決した。次に来たのは「サーバそのものを借りる」という発想だ。さくらインターネット（1996年設立）やRackspace（1998年設立）に代表されるホスティングサービスは、サーバの調達・設置の負担から顧客を解放した。申し込みから数日でサーバが用意され、SSHでログインするだけでよい。

だが、ホスティングにも限界があった。スペック変更に数日かかる。トラフィック急増時に動的にリソースを増やすことはできない。「弾力性」——需要に応じてリソースを動的に増減する——という概念は、まだ存在しなかった。ホスティングの限界が見えたとき、クラウドへの道が開かれる。

あなたが今使っているクラウドの「オンデマンド」性——必要なときに必要なだけリソースを確保し、不要になれば即座に手放せる——は、コロケーションとホスティングの時代に蓄積された「足りない」「遅い」「融通が利かない」という痛みの裏返しだ。その痛みを知ることは、クラウドの価値を本当に理解することにつながる。

---

## 参考文献

- National Science Foundation, "Birth of the Commercial Internet - NSF Impacts". <https://www.nsf.gov/impacts/internet>
- Wikipedia, "Equinix". <https://en.wikipedia.org/wiki/Equinix>
- Uptime Institute, "Tier Classification System". <https://uptimeinstitute.com/tiers>
- Uptime Institute Blog, "Explaining the Uptime Institute's Tier Classification System". <https://journal.uptimeinstitute.com/explaining-uptime-institutes-tier-classification-system/>
- ENERGY STAR, "Move to a Hot Aisle/Cold Aisle Layout". <https://www.energystar.gov/products/data_center_equipment/16-more-ways-cut-energy-waste-data-center/move-hot-aislecold-aisle-layout>
- Wikipedia, "Intelligent Platform Management Interface". <https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface>
- Wikipedia, "Peering". <https://en.wikipedia.org/wiki/Peering>
- Wikipedia, "Internet exchange point". <https://en.wikipedia.org/wiki/Internet_exchange_point>
- Wikipedia, "Service-level agreement". <https://en.wikipedia.org/wiki/Service-level_agreement>
- Wikipedia, "National Science Foundation Network". <https://en.wikipedia.org/wiki/National_Science_Foundation_Network>
- CoreSite, "Data Center Redundancy: N+1 vs 2N+1". <https://www.coresite.com/blog/data-center-redundancy-n-1-vs-2n-1>
- GitHub, "ipmitool/ipmitool". <https://github.com/ipmitool/ipmitool>
