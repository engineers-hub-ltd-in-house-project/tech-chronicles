# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第3回：クライアント/サーバモデル——計算の分散が始まった日

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- メインフレーム集中型からクライアント/サーバ分散型への移行が何を解決したか
- Novell NetWare、Sun Microsystems、Windows NT Serverが担った役割
- RPC、CORBA、DCOMなど分散通信技術の設計思想
- シンクライアントとファットクライアントのトレードオフ
- ソケット通信でクライアント/サーバの仕組みを体感する方法

---

## 1. 初めてファイルサーバにアクセスした日

1990年代の半ば、私はある中規模企業のオフィスで、初めてネットワーク越しのファイル共有を体験した。

デスクの上にはIBM PC互換機が置いてある。Windows 3.1が動いている。だが、そのPCのハードディスクには、仕事で使うデータはほとんど入っていない。Excelのスプレッドシートも、Wordの文書も、経理部門が作った月次レポートも、すべて「Fドライブ」にある。Fドライブは、物理的にはこのPCの中には存在しない。廊下の向こうのサーバルームに置かれた、Novell NetWareが動くファイルサーバの中にある。

私はファイルマネージャを開き、Fドライブをダブルクリックする。少しの遅延の後、ディレクトリの一覧が表示される。ファイルを開く。編集する。保存する。操作感は、ローカルのファイルとほとんど変わらない。だが、このファイルは廊下の向こう側にある別の計算機に格納されている。

「自分のPCにデータがないのに使える」——今となっては当たり前の体験だが、メインフレームのターミナルしか知らなかった私にとって、これは新鮮な驚きだった。メインフレームのターミナルは「ダム端末」だ。処理はすべてメインフレーム側で行い、端末は入出力の窓口にすぎない。だが、このオフィスのPCは違う。PCにはCPUがあり、メモリがあり、Windows 3.1が動いている。Excelの計算はPC側で行い、データの読み書きだけをサーバに依頼する。「計算する場所」と「データを保存する場所」が分離されている。

これが、クライアント/サーバモデルだった。

その後、インターネットの普及とともに、「向こう側」はオフィスの廊下の先から、大洋を越えた先のデータセンターにまで拡大した。だが根底にある発想は同じだ。計算を「手元」と「向こう側」に分ける。この分割は何を解決し、何を生み出したのか。

---

## 2. メインフレーム集中型からの脱却——パーソナルコンピュータが変えた力学

### IBM PCの衝撃——「計算力が個人の手元に来た」

1981年8月12日、IBMはIBM PC（Model 5150）を発売した。Intel 8088プロセッサ（4.77MHz）、最大256KBのメモリ。基本価格$1,565。フロリダ州ボカラトンのチームがPhilip Don Estridgeの指揮のもとに開発した。

スペックだけを見れば、当時のメインフレームの足元にも及ばない。だが、IBM PCの意義はスペックにはない。「IBMが作った」という事実にある。

1980年代初頭、企業のIT部門は保守的だった。「計算機はメインフレームかミニコンピュータ」が常識であり、Apple IIやCommodore 64は「おもちゃ」と見なされていた。だがIBMが——メインフレームの王者であるIBMが——パーソナルコンピュータを出した。これで企業の購買部門は稟議を通せるようになった。「IBMの製品です」の一言が、パーソナルコンピュータを企業に持ち込む切符になったのだ。

さらに重要なのは、IBMがアーキテクチャを公開したことだ。IBM PCの設計は公開仕様に基づいており、サードパーティがBIOSを独自に実装することで互換機を製造できた。Compaq、Dell、HPをはじめとする無数のメーカーがIBM PC互換機を製造し、価格競争が激化した。計算力はメインフレーム室から解放され、個々の机の上に降りてきた。

### 問題の所在——分散した計算力をどうつなげるか

だが、計算力が個人の手元に来たことは、新しい問題を生んだ。

メインフレームの時代、データは一箇所に集中していた。すべてのユーザーが同じデータにアクセスし、同じ処理ルールが適用される。データの整合性を保つのは比較的容易だった。

パーソナルコンピュータが普及すると、データは分散した。各人のPCにファイルが散在する。経理部のAさんが持っているスプレッドシートと、Bさんが持っているスプレッドシートのどちらが最新版なのか、誰にもわからない。フロッピーディスクをスニーカーネット——つまり人間が歩いて運ぶ——でやり取りする。バージョン管理など存在しない。

この「分散したPCをどうつなげるか」という問題が、クライアント/サーバモデルの動機となった。

### LANの登場——計算機を物理的につなげる

1980年代、LAN（Local Area Network）技術が実用化した。Ethernetは1973年にXerox PARCのRobert Metcalfeが発明し、1980年にDEC、Intel、Xeroxの3社が共同で仕様を策定した（DIX Ethernet）。1983年にはIEEE 802.3として標準化された。

LANは、同じオフィスや建物の中にある計算機を物理的に接続するインフラだ。Ethernetケーブル（当初は同軸ケーブル、後にツイストペアケーブル）で計算機同士を結び、データをやり取りする。

ハードウェアとしてのネットワークが整備された。次に必要だったのは、そのネットワーク上で「何をするか」を定義するソフトウェアだ。ここに登場したのが、ネットワークオペレーティングシステムだった。

---

## 3. Novell NetWare——LANの支配者

### ファイルサーバの誕生

1983年、Novellは最初のNetWare製品をリリースした。NetWare 68（S-Netとも呼ばれる）は、Novell独自の68000ベースのファイルサーバハードウェア上で動作した。

NetWareが解決した問題は明快だった。ネットワーク上の複数のPCから、一台のサーバに保存されたファイルやプリンタを共有する。各PCにはローカルのOSが動いており、ネットワーク経由でサーバのリソースにアクセスする。サーバはファイルの保存と共有に特化し、クライアント（PC）は表示と処理に集中する。

これがクライアント/サーバモデルの最も初期的な形態だ。

### IPX/SPXとNCP——NetWareの通信基盤

NetWareは独自のプロトコルスタックを採用した。IPX（Internetwork Packet Exchange）とSPX（Sequenced Packet Exchange）だ。これらはXerox Network Systems（XNS）のIDP/SPPプロトコルを基に、Novellが改良したものである。

その上で動作するNCP（NetWare Core Protocol）が、ファイル共有やプリンタ共有の実際の処理を担った。クライアントPC上のNetWareシェル（後にNetWareクライアント）がNCPリクエストをサーバに送り、サーバが応答する。この「リクエスト/レスポンス」のパターンは、現代のHTTPやREST APIの原型と言える。

注目すべきは、NetWareがTCP/IPではなくIPX/SPXを採用した点だ。1980年代のLAN環境では、TCP/IPはまだ「インターネット用のプロトコル」であり、オフィスのLANにはオーバースペックだと考えられていた。IPX/SPXはTCP/IPより軽量で、設定が簡単で、LAN環境に最適化されていた。IPXはコネクションレスであり、アドレス設定も自動的だった。DHCPサーバの設定に悩む必要がなかった。

この設計判断は、後に裏目に出る。インターネットの爆発的普及により、TCP/IPが事実上の標準となったとき、IPX/SPXに依存していたNetWareは大きな移行コストを抱えることになった。NetWare 5（1998年）でようやくTCP/IPが主要プロトコルとなったが、その頃にはWindows NTが市場を侵食していた。

### NetWareの黄金時代と教訓

1980年代後半から1990年代前半にかけて、Novell NetWareはLAN OS市場で60〜70%のシェアを誇った。世界中で50万を超えるNetWareベースネットワークが稼働し、5,000万以上のユーザーが利用していた。

NetWareの技術的な優位性は明確だった。ファイルサービスのパフォーマンスは競合を圧倒し、NetWare 3.x（1989年〜）はIntel 386プロセッサのプロテクトモードを直接利用する独自のOSカーネルにより、同等のハードウェア上で他のNOSを大きく上回る速度でファイルを配信した。

だが、NetWareの支配は永続しなかった。1993年7月、MicrosoftがWindows NT 3.1を発売した。250人のプログラマが560万行のコードを書き、開発費は1億5,000万ドル。Windows NTはファイル共有だけでなく、アプリケーションサーバ、データベースサーバ、Webサーバとしても機能する汎用サーバOSだった。Novellが「ファイルとプリンタの共有」に集中している間に、Microsoftは「サーバOSのすべて」を提供する戦略を取った。

ここにクライアント/サーバ時代の重要な教訓がある。技術的な優位性だけでは市場を維持できない。エコシステムの広さ——アプリケーションの豊富さ、開発ツールの充実度、人材の確保しやすさ——が最終的な勝敗を分ける。この構造は、30年後のクラウド市場でも繰り返されている。AWSが技術だけでなくサービスの幅で他社を圧倒しているのは、NetWareの衰退から学べる教訓だ。

---

## 4. Sun Microsystemsと「ネットワークはコンピュータだ」

### ワークステーションの思想

1982年2月24日、Scott McNealy、Andy Bechtolsheim、Vinod Khoslaの3名のスタンフォード大学院生がSun Microsystemsを設立した。Bill Joy——BSDの主要開発者——がまもなく合流し、4人の共同創業者となった。「SUN」は「Stanford University Network」に由来する。

Bechtolsheimがスタンフォードで設計したワークステーションは、最初からネットワーク機能を内蔵していた。これが決定的に重要だ。IBM PCは単体で動作する計算機として設計され、ネットワークは後付けの拡張だった。Sunのワークステーションは、ネットワークに接続されることを前提に設計された。

この設計思想を象徴するのが、1984年にJohn Gageが考案した有名なスローガンだ。

**「The Network is the Computer」（ネットワークはコンピュータだ）。**

このスローガンの意味するところは深い。個々のデスクトップコンピュータは、ネットワークの一部にすぎない。計算能力の本質は、ネットワークに接続されたすべてのリソースの総体にある。適切なソフトウェアがあれば、他のコンピュータの計算能力を利用できる。

考えてみてほしい。これは、2020年代のクラウドコンピューティングの思想そのものだ。あなたのラップトップは、AWSのリージョンに配置された数千台のサーバの「入り口」にすぎない。計算能力の本質は、ネットワークの向こう側にある。Sunが1984年に掲げたビジョンを、AWSは2006年にEC2で現実のものとした。

### NFS——ネットワーク越しのファイルシステム

Sunが1984年に開発したNFS（Network File System）は、クライアント/サーバモデルの洗練された実装だった。

NFSの設計思想は「透過性」にある。ユーザーから見れば、リモートサーバ上のファイルもローカルのファイルも、同じディレクトリツリーの一部として見える。`mount` コマンドでリモートのファイルシステムをローカルのディレクトリツリーにマウントすれば、あとは通常のファイル操作でアクセスできる。

```
ローカルのディレクトリツリー:

/
├── home/         （ローカルディスク）
├── usr/          （ローカルディスク）
└── shared/       （NFSマウント → サーバ 192.168.1.10:/export/shared）
```

NFSは「ステートレス」に設計された。サーバはクライアントの状態を保持しない。各リクエストは独立しており、サーバが再起動しても、クライアントは再接続するだけでよい。このステートレス設計は、信頼性の向上とスケーラビリティの確保に寄与した。

このステートレスの設計思想は、20年後のRESTful API設計の原則と共鳴する。Roy Fieldingが2000年の博士論文で定式化したRESTの制約——特にステートレス性——の実践的な先駆けが、1984年のNFSにある。

---

## 5. クライアント/サーバモデルの設計原則——処理の分散と通信の抽象化

### 2層アーキテクチャの基本構造

クライアント/サーバモデルの最も基本的な形態は、2層（two-tier）アーキテクチャだ。

```
┌─────────────────────────────────────────────────┐
│ 2層アーキテクチャ（Client/Server）              │
│                                                  │
│  ┌──────────┐        ┌──────────────┐           │
│  │ クライアント│  ←→  │   サーバ     │           │
│  │          │  ネット │              │           │
│  │ - UI     │  ワーク │ - データ管理 │           │
│  │ - ビジネス│        │ - ストレージ │           │
│  │   ロジック│        │              │           │
│  └──────────┘        └──────────────┘           │
│                                                  │
│  クライアント側で処理の大半を担う                │
│  サーバはデータの読み書きに特化                  │
└─────────────────────────────────────────────────┘
```

クライアントはUI（ユーザーインターフェース）を描画し、ビジネスロジック（計算、検証、フォーマット変換など）を実行する。サーバはデータの保存、検索、更新を担う。両者はネットワークを介して通信する。

この分割には明確な利点がある。

**第一に、計算負荷の分散。** メインフレームの時代、すべての処理を一台の計算機が担っていた。ユーザー数が増えると、メインフレームの負荷が増大する。クライアント/サーバモデルでは、UI処理とビジネスロジックの一部がクライアントPC側で実行されるため、サーバの負荷が軽減される。

**第二に、ユーザー体験の向上。** メインフレームのターミナルは文字ベースの表示しかできなかった。クライアントPCではGUI（グラフィカルユーザーインターフェース）が利用できる。Excelのようなスプレッドシートがリアルタイムに再計算される体験は、メインフレームのターミナルでは実現できない。

**第三に、コスト構造の変化。** メインフレームは1台あたり数百万ドル規模の投資だった。クライアント/サーバモデルでは、安価なPCとサーバの組み合わせで同等の機能を実現できる（と、当時は考えられていた）。

### ファットクライアントの問題

だが、2層アーキテクチャには深刻な問題があった。

ビジネスロジックがクライアント側に配置されるということは、数百台、数千台のクライアントPCすべてにアプリケーションをインストールし、更新する必要があるということだ。新しいバージョンのアプリケーションをリリースするたびに、全PCへのデプロイが必要になる。IT部門の管理負荷は膨大だった。

さらに、クライアントPCの性能がばらつくと、動作が不安定になる。メモリが足りないPC、古いOS、不整合なDLL。「DLL地獄」と呼ばれた問題は、1990年代のWindows開発者にとっては悪夢だった。

こうしたクライアントは「ファットクライアント」（fat client）または「シッククライアント」（thick client）と呼ばれた。対照的に、処理をサーバ側に集中させ、クライアントは表示だけを担う設計を「シンクライアント」（thin client）と呼ぶ。「シンクライアント」という用語自体は、1993年にOracle社のTim Negrisが考案し、CEOのLarry Ellisonがスピーチで繰り返し使ったことで広まった。

ファットクライアントとシンクライアントのトレードオフは、次のように整理できる。

```
ファットクライアント                シンクライアント
├── クライアント側で処理         ├── サーバ側で処理
├── リッチなUI                   ├── シンプルなUI
├── オフラインでも動作可能       ├── ネットワーク必須
├── デプロイ・更新が困難         ├── サーバ側で一元管理
├── クライアントの性能に依存     ├── サーバの性能に依存
└── PC毎の構成差異が問題         └── ネットワーク帯域が問題
```

興味深いことに、このトレードオフは2020年代にもそのまま存在する。SPAのReactアプリケーションはファットクライアント的だ。サーバーサイドレンダリング（SSR）のNext.jsはシンクライアント的だ。Webアプリケーションか、ネイティブアプリケーションか。この選択は、1990年代のファットクライアント vs シンクライアント論争の現代版だ。

### 3層アーキテクチャへの進化

2層アーキテクチャの限界を克服するために生まれたのが、3層（three-tier）アーキテクチャだ。1992年、John J. DonovanがマサチューセッツのOpen Environment Corporation（OEC）で考案した。

```
┌──────────────────────────────────────────────────────────┐
│ 3層アーキテクチャ                                        │
│                                                           │
│  ┌────────────┐   ┌────────────────┐   ┌──────────────┐ │
│  │ プレゼン   │   │ アプリケーション│   │ データ       │ │
│  │ テーション │→→→│ サーバ         │→→→│ ベース       │ │
│  │ 層         │   │ （ビジネス     │   │ サーバ       │ │
│  │            │   │  ロジック層）  │   │              │ │
│  │ ブラウザ   │   │ Java / C# /   │   │ Oracle /     │ │
│  │ PCアプリ   │   │ PHP ...        │   │ SQL Server   │ │
│  └────────────┘   └────────────────┘   └──────────────┘ │
│                                                           │
│  UIの変更 → プレゼンテーション層のみ修正                 │
│  業務ルール変更 → アプリケーション層のみ修正             │
│  DB移行 → データ層のみ修正                               │
└──────────────────────────────────────────────────────────┘
```

3層アーキテクチャの核心は「関心の分離」だ。

- **プレゼンテーション層**: ユーザーインターフェース。表示と入力の受付を担当する
- **アプリケーション層（ビジネスロジック層）**: 業務ロジックの実行。計算、検証、ワークフローを担当する
- **データ層**: データの永続化。データベースの読み書きを担当する

各層は独立してデプロイ・スケーリング・更新が可能だ。ビジネスロジックを変更しても、クライアントPC側のアプリケーションを更新する必要がない。データベースを移行しても、アプリケーション層のインターフェースが変わらなければ、他の層には影響しない。

この「関心の分離」と「独立したスケーリング」の思想は、クラウドアーキテクチャの根幹そのものだ。AWSのアーキテクチャパターン——ELB（ロードバランサ）+ EC2（アプリケーション）+ RDS（データベース）——は、3層アーキテクチャのクラウド版にほかならない。マイクロサービスは3層の各層をさらに細分化したものと見ることもできる。

---

## 6. RPC、CORBA、DCOM——分散通信の技術史

### RPC——ローカル呼び出しのように見せるマジック

クライアントとサーバが通信するとき、低レベルではソケットを介したバイト列の送受信が行われる。だが、アプリケーション開発者がバイト列の組み立てと解析を毎回書くのは非効率だ。

この問題に対するエレガントな解決策がRPC（Remote Procedure Call）だった。RPCの概念自体は1970年代から存在するが、実用的な実装として画期的だったのは、1984年にXerox PARCのAndrew BirellとBruce Nelsonが発表した「Implementing Remote Procedure Calls」だ。この論文は1994年にACM Software System Awardを受賞し、2007年にSigOps Hall of Fameに選出された。

RPCの発想は単純にして強力だ。ネットワーク越しの通信を、ローカルの関数呼び出しと同じインターフェースで行えるようにする。

```
ローカル呼び出し:
  result = calculate(x, y)
  → 同じプロセス内で関数が実行される

RPC呼び出し:
  result = calculate(x, y)
  → 見た目は同じだが、裏側では:
    1. 引数 x, y をシリアライズ（マーシャリング）
    2. ネットワーク経由でサーバに送信
    3. サーバ側でデシリアライズ
    4. サーバ側で calculate(x, y) を実行
    5. 結果をシリアライズしてクライアントに返送
    6. クライアント側でデシリアライズして result に格納
```

RPCは「ネットワークの存在を隠蔽する」試みだ。開発者はネットワークを意識せずに、あたかもローカルの関数を呼ぶようにリモートの処理を呼び出せる。

だが、この「隠蔽」には落とし穴がある。ネットワークは遅延する。パケットは消失する。サーバはダウンする。ローカル呼び出しでは起きない障害モードが、RPCでは日常的に発生する。この問題は後に「分散コンピューティングの誤謬」（Fallacies of Distributed Computing）として定式化されることになる。「ネットワークは信頼できる」「遅延はゼロだ」「帯域幅は無限だ」——これらはすべて誤りだ。

RPCの「透過的なリモート呼び出し」の理念と、分散システムの現実との間のギャップ。この緊張関係は、2020年代のマイクロサービスアーキテクチャにおけるgRPCでも、GraphQLでも、そのまま継続している。

### CORBA——言語を超える野望

1991年、Object Management Group（OMG）はCORBA（Common Object Request Broker Architecture）1.0を公開した。

CORBAの野望は壮大だった。異なるプログラミング言語で書かれた、異なるOS上で動作するオブジェクトが、ネットワーク越しに透過的に通信できる標準を作る。C++で書かれたクライアントがJavaで書かれたサーバのメソッドを呼び出し、Cobolで書かれた別のサービスにデータを渡す——言語の壁を越えた分散オブジェクト通信の夢だ。

CORBAはIDL（Interface Definition Language）を導入した。サービスのインターフェースをIDLで定義し、各言語向けのスタブコードを自動生成する。

```
// CORBA IDL の例
interface Calculator {
    double add(in double x, in double y);
    double subtract(in double x, in double y);
};
```

このIDLから、C++、Java、Pythonなど各言語のクライアントスタブとサーバスケルトンが生成される。開発者は生成されたコードを使って、言語を意識せずにリモートオブジェクトのメソッドを呼び出せる。

CORBAの設計思想自体は先見的だった。だが、仕様の複雑さ、実装間の非互換性、パフォーマンスの問題が足を引っ張った。Michi Henningは2006年のACM Queue誌上で「The Rise and Fall of CORBA」と題して、CORBAがなぜ期待通りに普及しなかったかを分析している。仕様が複雑すぎて正しく実装するのが困難であり、異なるベンダーのORB（Object Request Broker）間の相互運用性が十分に確保されなかった。

CORBAが実現しようとした「言語を超えた分散通信の標準化」は、形を変えて現代に生きている。REST API、gRPC、GraphQL——いずれもサービス間の通信を標準化する試みだ。特にgRPCのProtocol BuffersによるIDL定義とコード生成は、CORBAのIDLの直系の子孫と言ってよい。

### DCOM——Microsoftの回答

1996年、MicrosoftはWindows NT 4.0とともにDCOM（Distributed Component Object Model）を発表した。元々は「Network OLE」と呼ばれていた。

DCOMはCORBAに対するMicrosoftの回答だった。CORBAが言語やプラットフォームに依存しない標準を目指したのに対し、DCOMはWindows環境に最適化された分散コンポーネント技術だった。MSRPC（MicrosoftのDCE/RPC拡張）を基盤とし、COMコンポーネントをネットワーク越しに呼び出す仕組みを提供した。

CORBA vs DCOMの対立は、1990年代後半の「分散オブジェクト戦争」の主戦場だった。だが、2000年代に入るとWebが急速に普及し、HTTPベースのSOAP/XML、そしてREST APIが分散通信の主流となった。CORBAもDCOMも、Webの前に敗れ去った。

ここから得られる教訓がある。分散通信の標準化は、「最も洗練された技術」ではなく、「最も広く利用可能な技術」が勝つ。HTTPは分散オブジェクト通信の技術としては原始的だ。だが、すべてのブラウザ、すべてのOS、すべてのプログラミング言語がHTTPをサポートしている。この「偏在性」が、CORBAやDCOMの技術的優位を打ち負かした。

クラウドの世界でも同じ構造がある。AWSのAPIはHTTP/RESTベースだ。最も洗練されたプロトコルではないが、最も広く利用可能なプロトコルだ。

---

## 7. Berkeleyソケット——すべてのネットワーク通信の原点

### BSD 4.2がもたらしたもの

クライアント/サーバモデルの技術史を語る上で、Berkeleyソケットに触れないわけにはいかない。

1983年8月、カリフォルニア大学バークレー校のCSRG（Computer Systems Research Group）は、BSD 4.2をリリースした。このリリースに含まれていたのが、Berkeleyソケット（BSD sockets）APIだ。DARPA（Defense Advanced Research Projects Agency）の資金提供のもと、William N. Joy、Samuel J. Leffler、Robert S. Fabryらが開発した。

Berkeleyソケットは、ネットワーク通信のための統一的なプログラミングインターフェースを定義した。`socket()`、`bind()`、`listen()`、`accept()`、`connect()`、`send()`、`recv()`——これらの関数が、TCP/IPネットワーク通信の標準APIとなった。

```c
// サーバ側の基本的なフロー
int server_fd = socket(AF_INET, SOCK_STREAM, 0);  // ソケット作成
bind(server_fd, &addr, sizeof(addr));               // アドレスにバインド
listen(server_fd, backlog);                         // 接続待ち開始
int client_fd = accept(server_fd, ...);             // クライアント接続受付
recv(client_fd, buffer, size, 0);                   // データ受信
send(client_fd, response, size, 0);                 // データ送信
```

重要なのは、このAPIが40年以上にわたって基本的な形を変えずに生き続けていることだ。2020年代の今日、Python、Java、Go、Rustのいずれでネットワークプログラミングを行おうとも、その基盤には（直接的にせよ間接的にせよ）Berkeleyソケットの抽象化がある。

Berkeleyソケットは「ファイルディスクリプタ」の概念を拡張した。Unixの「すべてはファイルである」という哲学に従い、ネットワーク接続もファイルディスクリプタとして扱われる。ファイルに対する `read()`/`write()` と同じ感覚で、ネットワーク接続に対して `recv()`/`send()` を行う。この一貫した抽象化が、ネットワークプログラミングの敷居を大幅に下げた。

そして、AWSのEC2インスタンス同士がVPC内で通信するとき、その基盤にあるのもBerkeleyソケットだ。40年前のAPIが、クラウドネイティブなマイクロサービス間通信の土台を支えている。

---

## 8. ハンズオン——ソケット通信でクライアント/サーバモデルを体感する

ここからは、Berkeleyソケットを使って簡易的なクライアント/サーバアプリケーションを構築し、「計算を分散する」ことの意味を体感する。

### 環境

- Docker（Ubuntu 24.04ベースコンテナ）
- Python 3（標準ライブラリのみ使用）
- Linux標準ツール

### 演習1：最小のクライアント/サーバ通信

まず、最も基本的なクライアント/サーバ通信を実装する。

```bash
# Docker環境に入る
docker run -it --rm --name cs-handson ubuntu:24.04 bash

# 必要なツールをインストール
apt-get update && apt-get install -y python3 net-tools iproute2 procps
```

サーバ側のコードを作成する。

```python
# server.py - 最小のTCPサーバ
import socket

HOST = '127.0.0.1'
PORT = 8080

# ソケット作成 → バインド → リッスン → アクセプト
# これはBSD 4.2（1983年）で定義されたパターンそのものだ
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(1)
    print(f"サーバ起動: {HOST}:{PORT} で接続待ち")

    while True:
        conn, addr = s.accept()
        with conn:
            print(f"接続: {addr}")
            data = conn.recv(1024)
            if data:
                message = data.decode('utf-8')
                print(f"受信: {message}")
                response = f"サーバが受信しました: {message}"
                conn.sendall(response.encode('utf-8'))
                print(f"送信: {response}")
```

クライアント側のコードを作成する。

```python
# client.py - 最小のTCPクライアント
import socket

HOST = '127.0.0.1'
PORT = 8080

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    message = "Hello from client"
    s.sendall(message.encode('utf-8'))
    print(f"送信: {message}")

    data = s.recv(1024)
    print(f"受信: {data.decode('utf-8')}")
```

```bash
# ターミナル1でサーバを起動
python3 server.py &

# ターミナル2（同じコンテナ内）でクライアントを実行
python3 client.py
```

このシンプルな例が、クライアント/サーバモデルの骨格だ。サーバは `listen()` で待ち受け、クライアントは `connect()` で接続する。データはバイト列としてネットワークを流れる。Novell NetWareのNCP、Sun NFSのRPC、あるいはHTTPリクエスト——すべての高レベルプロトコルの基盤に、このソケット通信のパターンがある。

### 演習2：計算の分散——RPCの原型を体験する

RPCの概念を手で実装し、「ローカル呼び出しとリモート呼び出しの違い」を体感する。

```python
# rpc_server.py - 簡易RPCサーバ
import socket
import json

HOST = '127.0.0.1'
PORT = 8081

# サーバ側で実行される「リモート」関数群
def add(x, y):
    return x + y

def multiply(x, y):
    return x * y

def factorial(n):
    result = 1
    for i in range(1, n + 1):
        result *= i
    return result

# 関数テーブル
functions = {
    'add': add,
    'multiply': multiply,
    'factorial': factorial,
}

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(5)
    print(f"RPCサーバ起動: {HOST}:{PORT}")

    while True:
        conn, addr = s.accept()
        with conn:
            data = conn.recv(4096)
            if data:
                # リクエストをデシリアライズ（アンマーシャリング）
                request = json.loads(data.decode('utf-8'))
                func_name = request['function']
                args = request['args']

                print(f"RPC呼び出し: {func_name}({args})")

                # 関数を実行
                if func_name in functions:
                    result = functions[func_name](*args)
                    response = {'status': 'ok', 'result': result}
                else:
                    response = {'status': 'error', 'message': f'Unknown function: {func_name}'}

                # レスポンスをシリアライズ（マーシャリング）して返送
                conn.sendall(json.dumps(response).encode('utf-8'))
```

```python
# rpc_client.py - 簡易RPCクライアント
import socket
import json
import time

HOST = '127.0.0.1'
PORT = 8081

def remote_call(func_name, *args):
    """RPCの「透過的な」呼び出しインターフェース"""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))

        # リクエストをシリアライズ（マーシャリング）して送信
        request = {'function': func_name, 'args': list(args)}
        s.sendall(json.dumps(request).encode('utf-8'))

        # レスポンスを受信してデシリアライズ
        data = s.recv(4096)
        response = json.loads(data.decode('utf-8'))

        if response['status'] == 'ok':
            return response['result']
        else:
            raise Exception(response['message'])

# --- ローカル呼び出しとリモート呼び出しの比較 ---

# ローカル呼び出し
def local_add(x, y):
    return x + y

print("=== ローカル呼び出し ===")
start = time.time()
for _ in range(100):
    local_add(3, 5)
local_time = time.time() - start
print(f"100回のローカル呼び出し: {local_time*1000:.2f} ミリ秒")

print("\n=== リモート呼び出し（RPC）===")
start = time.time()
for _ in range(100):
    remote_call('add', 3, 5)
remote_time = time.time() - start
print(f"100回のRPC呼び出し: {remote_time*1000:.2f} ミリ秒")

print(f"\nRPCのオーバーヘッド: ローカルの約{remote_time/local_time:.0f}倍")

# RPC呼び出しの例
print(f"\nadd(10, 20) = {remote_call('add', 10, 20)}")
print(f"multiply(6, 7) = {remote_call('multiply', 6, 7)}")
print(f"factorial(10) = {remote_call('factorial', 10)}")
```

```bash
# サーバ起動
python3 rpc_server.py &
sleep 1

# クライアント実行
python3 rpc_client.py
```

この演習で体感してほしいのは、RPCのオーバーヘッドだ。ローカル呼び出しとリモート呼び出しは、コードの見た目はほぼ同じだ。だが実行時間は桁違いに異なる。ネットワークを経由するだけで、ソケットの作成、TCP接続の確立（3ウェイハンドシェイク）、データのシリアライズ/デシリアライズ、パケットの送受信が発生する。

1984年にBirellとNelsonが「RPCはローカル呼び出しと同じように見える」と言ったとき、彼らは同時に「だが、同じようには動かない」ことも認識していた。この差異を意識することが、分散システムを設計する上での第一歩だ。

### 演習3：複数クライアントの同時接続

クライアント/サーバモデルの重要な側面——複数のクライアントからの同時接続を扱う。

```python
# concurrent_server.py - 複数クライアント対応サーバ
import socket
import threading
import json
import time

HOST = '127.0.0.1'
PORT = 8082

client_count = 0
lock = threading.Lock()

def handle_client(conn, addr):
    global client_count
    with lock:
        client_count += 1
        current = client_count
    print(f"[クライアント#{current}] 接続: {addr}")

    with conn:
        while True:
            data = conn.recv(4096)
            if not data:
                break
            message = data.decode('utf-8')
            print(f"[クライアント#{current}] 受信: {message}")

            # 処理に時間がかかることをシミュレート
            time.sleep(0.1)

            response = f"[Server] Processed by thread for client#{current}: {message}"
            conn.sendall(response.encode('utf-8'))

    print(f"[クライアント#{current}] 切断")

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(10)
    print(f"マルチスレッドサーバ起動: {HOST}:{PORT}")

    while True:
        conn, addr = s.accept()
        thread = threading.Thread(target=handle_client, args=(conn, addr))
        thread.daemon = True
        thread.start()
```

```python
# concurrent_client.py - 複数クライアントの同時接続テスト
import socket
import threading
import time

HOST = '127.0.0.1'
PORT = 8082

def client_task(client_id, num_requests):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        for i in range(num_requests):
            message = f"Request {i} from client {client_id}"
            s.sendall(message.encode('utf-8'))
            data = s.recv(4096)
            print(f"Client {client_id}: {data.decode('utf-8')}")

# 5つのクライアントが同時に接続
threads = []
start = time.time()

for i in range(5):
    t = threading.Thread(target=client_task, args=(i, 3))
    threads.append(t)
    t.start()

for t in threads:
    t.join()

elapsed = time.time() - start
print(f"\n5クライアント × 3リクエスト = 15リクエスト完了")
print(f"合計時間: {elapsed:.2f}秒")
print(f"（逐次実行なら 15 × 0.1秒 = 1.5秒以上かかるはず）")
```

```bash
# サーバ起動
python3 concurrent_server.py &
sleep 1

# クライアント実行
python3 concurrent_client.py
```

この演習のポイントは、サーバ側のスレッディングモデルだ。各クライアント接続に対してスレッドを生成し、並行して処理する。これは1990年代のアプリケーションサーバが採用していた典型的なモデルであり、現代のWebサーバ（Apache HTTPDのprefork/workerモデル）の原型でもある。

だが、このモデルにはスケーラビリティの限界がある。クライアント数が数千に達すると、スレッド数も数千に膨れ上がり、コンテキストスイッチのオーバーヘッドとメモリ消費が問題になる。この「C10K問題」が、後のイベント駆動モデル（epoll、kqueue）やNode.jsの非同期I/O、そしてクラウドのオートスケーリングへとつながっていく。

### この演習で何がわかるか

**第一に、クライアント/サーバ通信の基盤は驚くほどシンプルだ。** `socket()` → `bind()` → `listen()` → `accept()` というパターンは40年間変わっていない。高レベルのフレームワークがどれだけ発展しても、その下にはこのシンプルなパターンがある。

**第二に、RPCはネットワークの遅延を隠蔽できない。** ローカル呼び出しとリモート呼び出しは、コードの見た目は似ているが、パフォーマンス特性はまったく異なる。この差異を無視した設計は、必ず破綻する。

**第三に、並行接続の処理はクライアント/サーバモデルの核心課題だ。** 1台のサーバが複数のクライアントを同時に相手にする方法——スレッド、プロセスフォーク、イベント駆動——の選択は、システムのスケーラビリティを決定する。

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/03-client-server/` に用意してある。

---

## 9. まとめと次回予告

### この回のまとめ

第3回では、クライアント/サーバモデル——計算が「集中」から「分散」に移った時代——を探った。

**パーソナルコンピュータが計算力を個人の手元に解放した。** 1981年のIBM PC以降、計算力はメインフレーム室から各人のデスクに降りてきた。だが、分散した計算力をつなげるという新たな課題が生まれた。

**Novell NetWareはLAN上のファイル共有で圧倒的な地位を築いた。** 1980年代後半から1990年代前半にかけて60%以上のLAN OS市場シェアを獲得し、5,000万以上のユーザーに利用された。だが、IPX/SPXへの依存とファイル共有への特化が、TCP/IPとWindows NTの攻勢に対する脆弱性を生んだ。技術的優位だけでは市場を維持できないという教訓は、クラウド市場にも通じる。

**Sun Microsystemsは「ネットワークはコンピュータだ」と宣言した。** 1984年に掲げたこのスローガンは、40年後のクラウドコンピューティングの本質を正確に予見していた。個々の計算機は、ネットワークに接続されたリソースの総体の一部にすぎない。

**RPC、CORBA、DCOMは「分散を透過的にする」技術だった。** ネットワーク越しの通信をローカル呼び出しのように見せる試みだ。だが「分散コンピューティングの誤謬」が示すように、ネットワークの遅延と障害は隠蔽しきれない。この緊張関係は、現代のマイクロサービスアーキテクチャでも解消されていない。

**3層アーキテクチャは「関心の分離」を確立した。** プレゼンテーション、ビジネスロジック、データの3層に分離する設計は、クラウドアーキテクチャ（ELB + EC2 + RDS）の直接の先祖だ。

冒頭の問いに答えよう。計算を「手元」と「向こう側」に分けるという発想は、何を解決し、何を生み出したのか。解決したのは、メインフレーム集中型の限界——コスト、柔軟性、ユーザー体験の制約——だ。生み出したのは、分散システム固有の複雑性——ネットワーク遅延、障害モード、データ整合性の課題——だ。クライアント/サーバモデルは、この「解決」と「新たな課題」の両方を内包したまま、次の時代——データセンターとインターネットの時代——へと引き継がれた。

### 次回予告

第4回では、「コロケーション——自分のサーバを他人の施設に預ける」を探る。

クライアント/サーバモデルの普及は、必然的に「サーバをどこに置くか」という問題を顕在化させた。オフィスのサーバルームでは、電力供給の安定性、冷却、物理セキュリティ、ネットワーク帯域のすべてが不十分だ。かといって、自社でデータセンターを建設する資金力は中小企業にはない。

この問題に対する最初の解が、コロケーション——「自分のサーバを、専門の施設に預ける」——だった。私が秋葉原でラックマウントサーバを買い、車でデータセンターに運び込んだ2002年の話をしよう。サーバの物理的な重さ、ケーブリングの煩雑さ、深夜のハードウェア障害。「物理から逃れられない」時代の記録だ。

あなたは、自分が使っているクラウドサーバが物理的にどこにあるか、知っているだろうか。その物理的な場所が、なぜ重要なのか、考えたことがあるだろうか。

---

## 参考文献

- Wikipedia, "IBM Personal Computer". <https://en.wikipedia.org/wiki/IBM_Personal_Computer>
- Wikipedia, "NetWare". <https://en.wikipedia.org/wiki/NetWare>
- Wikipedia, "Novell". <https://en.wikipedia.org/wiki/Novell>
- Wikipedia, "Sun Microsystems". <https://en.wikipedia.org/wiki/Sun_Microsystems>
- Wikipedia, "The Network is the Computer". <https://en.wikipedia.org/wiki/The_Network_is_the_Computer>
- Wikipedia, "Windows NT 3.1". <https://en.wikipedia.org/wiki/Windows_NT_3.1>
- Birrell, A.D. and Nelson, B.J., "Implementing Remote Procedure Calls", ACM Transactions on Computer Systems, Vol. 2, No. 1, February 1984. <https://dl.acm.org/doi/10.1145/2080.357392>
- OMG, "CORBA History". <https://www.omg.org/corba/history_of_corba.htm>
- Henning, M., "The Rise and Fall of CORBA", ACM Queue, Vol. 4, No. 5, June 2006. <https://queue.acm.org/detail.cfm?id=1142044>
- Wikipedia, "Distributed Component Object Model". <https://en.wikipedia.org/wiki/Distributed_Component_Object_Model>
- Wikipedia, "Berkeley sockets". <https://en.wikipedia.org/wiki/Berkeley_sockets>
- Wikipedia, "Multitier architecture". <https://en.wikipedia.org/wiki/Multitier_architecture>
- Wikipedia, "Thin client". <https://en.wikipedia.org/wiki/Thin_client>
