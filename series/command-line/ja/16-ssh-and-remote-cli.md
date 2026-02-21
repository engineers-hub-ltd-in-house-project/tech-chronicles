# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第16回：SSHとリモートCLI――距離を超えるテキストインターフェース

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- telnetからrsh/rlogin、そしてSSHへと至るリモートアクセスプロトコルの進化史と、それぞれが解決しようとした課題
- 1995年、Helsinki University of Technologyでのパスワード盗聴事件がSSH誕生の直接的契機となった経緯
- SSHプロトコルの3層アーキテクチャ（Transport Layer、User Authentication、Connection Protocol）と、暗号化チャネル・ポートフォワーディング・SFTPの仕組み
- OpenSSHが1999年にOpenBSDプロジェクトから生まれ、事実上の標準実装となるまでの道のり
- SSH-1からSSH-2への進化と、RFC 4251-4254による標準化の意義
- Mosh（2012年、MIT）がSSHの限界をどのように克服したか――UDPベースのState Synchronization Protocolと予測的ローカルエコー
- テキストストリームがリモート操作において持つ構造的な帯域効率の優位性

---

## 1. 距離が消えた日

2000年代の初め、私はWebサーバの管理を日常業務としていた。クライアントのサイトが動いているサーバは、データセンターのラック内にある。物理的にはそこにあるが、私の手元にはない。自宅の机に座り、ターミナルを開き、コマンドを一つ打つ。

```
ssh admin@203.0.113.42
```

数秒後、プロンプトが返ってくる。あたかも目の前にあるかのように、数十キロメートル先のサーバを操作できる。ファイルを確認し、ログを読み、設定を書き換え、サービスを再起動する。すべてテキストの入出力だけで完結する。

この体験は、いま振り返ればCLIの本質的な強みを最も端的に示していた。テキストストリームは軽い。帯域をほとんど消費しない。1990年代のISDN回線でも、2000年代の家庭用ADSLでも、SSHの操作は実用的だった。

だが、SSHに辿り着く前には、暗号化なしの時代があった。telnetでログインし、パスワードが平文でネットワークを流れていた時代だ。私自身、1990年代後半にtelnetでリモートサーバに接続していた。当時は「パスワードが盗聴されるかもしれない」という感覚が希薄だった。ネットワーク上を流れるパケットを誰かが覗いているとは、想像すらしていなかった。

ある時期を境に、telnetの接続先がすべてSSHに変わった。「telnetは使うな」という指示が来たのだ。理由を聞くと、「パスワードが丸見えだから」と言われた。その一言が、リモートアクセスの歴史を凝縮していた。

CLIはなぜリモート操作の「唯一解」であり続けるのか。GUIのリモートデスクトップが存在するのに、なぜエンジニアはSSHを手放さないのか。そこには、テキストストリームという抽象が持つ構造的な優位性がある。

あなたは、自分が毎日使っているSSH接続の裏で、どのような技術史が流れているか、考えたことがあるだろうか。

---

## 2. リモートアクセスの歴史――平文の時代から暗号化の時代へ

### telnet：最初のリモートアクセスプロトコル

コンピュータをネットワーク越しに操作するという発想は、インターネットそのものと同じくらい古い。

1969年、ARPANETの最初の4ノードが接続された年に、リモートアクセスの最初の提案が生まれた。RFC 15（1969年9月、Steve Carr, University of Utah）は、テレタイプ的な接続をARPANET上で実現するサブシステムを記述していた。これがtelnetの原型だ。

当初のtelnetは非公式なプロトコルであり、正式な仕様として標準化されたのは1983年のことだった。RFC 854とRFC 855（1983年5月、J. PostelとJ. Reynolds, ISI）がInternet Standard 8として発行され、telnetプロトコルの正式な定義となった。

telnetの設計の核心はNetwork Virtual Terminal（NVT）という抽象化にある。NVTは、あらゆる端末の違いを吸収する仮想的な端末だ。接続元のマシンも接続先のマシンも、自分のローカルな端末特性をNVTにマッピングする。異なるアーキテクチャのマシン同士が、この仮想端末を介して通信する。第4回で語ったVT100のようなハードウェア端末の差異を、ソフトウェアで吸収する仕組みだ。

```
telnetの通信モデル:

  ユーザ端末                    リモートホスト
  ┌──────────┐                 ┌──────────┐
  │ ローカル  │  NVT形式の      │ ローカル  │
  │ 端末特性  │  テキスト       │ 端末特性  │
  │    ↓     │ ──────────→    │    ↑     │
  │ NVT変換  │    TCP接続      │ NVT変換  │
  │          │ ←────────── │          │
  └──────────┘   (平文!!)       └──────────┘

  問題: すべてのデータが平文で流れる
  → パスワードも、コマンドも、出力も、
    ネットワーク上で傍受可能
```

telnetの設計は、ネットワークが「信頼できる」ことを前提としていた。ARPANETは限られた研究機関のネットワークであり、悪意あるユーザーの存在は想定されていなかった。パスワードが平文で流れることは、設計上の欠陥ではなく、当時の前提条件の反映だった。

だが、ネットワークが拡大し、インターネットが商用化されるにつれ、この前提は崩壊した。

### Berkeley r-commands：信頼に基づくリモートアクセス

1983年、BSD 4.2でBerkeley r-commands（rsh、rlogin、rcp）が導入された。telnetがあるのに、なぜ新しいリモートアクセスの仕組みが必要だったのか。

telnetは汎用的なプロトコルだった。あらゆる端末とあらゆるホストの間で動作するように設計されている。その汎用性の代償として、手続きが煩雑だった。rloginは、UNIX同士の接続に特化することで、ログイン手続きを簡素化した。`.rhosts`ファイルにリモートホストのユーザー名を記述しておけば、パスワードなしでログインできる。

```
Berkeley r-commands の仕組み:

  ~/.rhosts ファイル:
    trusted-host.example.com admin
    → trusted-host の admin ユーザーからの接続を信頼

  rlogin: リモートログイン（端末設定の伝播あり）
  rsh:    リモートシェルコマンド実行
  rcp:    リモートファイルコピー

  利便性: パスワード入力不要（信頼ホスト設定時）
  代償:   通信は平文、認証はIPアドレスベースの信頼
         → IPスプーフィング攻撃に脆弱
```

rshは単一のコマンドをリモートで実行する。`rsh remote-host ls -la`と打てば、リモートホストでlsが実行され、結果がローカルに表示される。rcpはファイルのリモートコピーだ。これらはUNIXの操作モデルに密着しており、UNIX管理者にとって直感的だった。

しかし、セキュリティの観点からは、r-commandsはtelnetと同じ問題を抱えていた。通信は平文であり、認証はIPアドレスの「信頼」に依存していた。IPスプーフィング（送信元IPアドレスの偽装）が可能な攻撃者にとって、r-commandsの信頼モデルは容易に突破できる。

1990年代半ばまで、この「信頼に基づくリモートアクセス」の世界が続いた。ネットワーク管理者たちは、ネットワーク上を流れるパスワードが平文であることを知っていた。知っていたが、暗号化されたリモートアクセスの手段が存在しなかったのだ。

### 1995年：盗聴事件とSSHの誕生

転機は1995年に訪れた。

フィンランドのHelsinki University of Technology（現Aalto University）で、Tatu Ylonenと同僚たちは大学ネットワーク上でのパスワード盗聴攻撃を経験した。telnetもrloginもFTPも、パスワードを平文で送信していた。ネットワーク上のパケットを傍受すれば、パスワードは丸見えだ。攻撃者はネットワークスニッフィングによって、大学の研究者たちのパスワードを窃取していた。

Ylonenはこの経験に突き動かされ、暗号化されたリモートアクセスプロトコルを設計・実装した。SSH（Secure Shell）だ。

1995年7月、YlonenはSSH（後にSSH-1と呼ばれるバージョン）をフリーソフトウェアとして公開した。ソースコード付きで、誰でも無償で使用できた。反応は爆発的だった。1995年末までに、50カ国で2万人のユーザーがSSHを採用した。Ylonenは毎日150通のサポートメールを処理していたという。

この急速な普及は、暗号化されたリモートアクセスに対する需要がいかに大きかったかを物語る。telnetやrloginのセキュリティ問題は、誰もが知っていた。解決策が存在しなかっただけだ。SSHが登場した瞬間、堰を切ったように移行が始まった。

1995年12月、YlonenはSSH Communications Securityを設立し、SSHの商用化に乗り出した。この決断が、後のSSHの自由なソフトウェアとしての発展に複雑な影を落とすことになる。

### SSH-1からSSH-2へ：プロトコルの進化

SSHの初期バージョン（SSH-1）は、暗号化リモートアクセスという概念を実証した。だが、SSH-1にはプロトコル設計上の問題があった。CRC-32補償攻撃をはじめとするセキュリティ上の脆弱性が発見され、プロトコルの根本的な再設計が必要になった。

SSH-2は、SSH-1とは互換性を持たない新しいプロトコルとして設計された。主要な改善点は以下の通りだ。

第一に、鍵交換メカニズムの刷新。SSH-2ではDiffie-Hellman鍵交換が導入され、前方秘匿性（Perfect Forward Secrecy）が実現された。一つのセッション鍵が漏洩しても、過去や将来のセッションの暗号化は破られない。

第二に、暗号化アルゴリズムの強化。AES（Advanced Encryption Standard）が追加され、3DESのようなより弱い暗号を置き換えた。暗号アルゴリズムはクライアントとサーバの間でネゴシエーション可能であり、将来の暗号技術の進歩に対応できる柔軟性を持つ。

第三に、データ完全性検証の改善。SSH-2ではMAC（Message Authentication Code）としてSHA-1やHMAC-MD5が使用可能となり、データの改竄検出がより堅牢になった。

第四に、チャネル多重化の導入。一つのSSH接続上で、複数のシェルセッション、ファイル転送、ポートフォワーディングを同時に実行できるようになった。

```
SSHプロトコルの進化:

  SSH-1 (1995年):
    ├── 暗号化リモートアクセスの概念実証
    ├── サーバ鍵 + ホスト鍵の認証
    ├── CRC-32によるデータ完全性チェック
    └── 脆弱性: CRC-32補償攻撃、鍵交換の弱さ

  SSH-2 (1996年-):
    ├── Diffie-Hellman鍵交換（前方秘匿性）
    ├── ホスト鍵のみの認証（簡素化）
    ├── AES, SHA-1/SHA-256 などの強力な暗号
    ├── MAC（Message Authentication Code）
    ├── チャネル多重化（一接続で複数セッション）
    └── RFC 4251-4254 として2006年に標準化
```

SSH-2は2006年1月、IETFによってRFC 4251（プロトコルアーキテクチャ）、RFC 4252（認証プロトコル）、RFC 4253（トランスポート層プロトコル）、RFC 4254（接続プロトコル）として標準化された。SSH-1は事実上非推奨となり、2006年以降、SSH-2が唯一の標準プロトコルとなった。

### OpenSSH：自由な実装が標準となる

SSHの歴史において、もう一つの重要な転換点がある。OpenSSHの誕生だ。

Tatu YlonenのSSH実装は、当初はフリーソフトウェアとして公開されたが、バージョンが上がるにつれ、ライセンスは徐々に制約的になっていった。SSH Communications Securityが商用化を進めるにつれ、自由に使えるSSH実装の入手が困難になった。

1999年、OpenBSDプロジェクトがこの問題に立ち向かった。Tatu Ylonenのssh 1.2.12――最後の自由に利用可能なバージョン――を基に、セキュリティを重視した再実装を行った。主要開発者はTheo de Raadt、Markus Friedl、Niels Provos、Bob Beck、Aaron Campbell、Dug Song。Theo de Raadtの回想によれば、まず非ポータブルな部分を除去してコードの可読性を高め、セキュリティホールを発見しやすくすることから始めたという。

1999年12月1日、OpenSSH 1.2.2がOpenBSD 2.6の一部としてリリースされた。

OpenSSHの成功は、技術的な品質だけでなく、ライセンスの自由さによるところが大きい。BSD系のライセンスで提供されたOpenSSHは、あらゆるオペレーティングシステムに組み込むことができた。Linux各ディストリビューション、macOS、FreeBSD、NetBSD――ほぼすべてのUNIX系OSがOpenSSHを標準のSSH実装として採用した。

2018年以降、Microsoftも動いた。Windows 10にOpenSSHクライアントとサーバが組み込まれた。1995年にフィンランドの大学で始まったSSHの物語は、25年の歳月を経て、すべての主要オペレーティングシステムの標準機能となった。

OpenSSHの歴史は、第14回で語ったGNU coreutilsの物語と共鳴する。商用ソフトウェアの制約がきっかけとなり、自由な実装が生まれ、その実装が事実上の標準となる。この構図は、オープンソースソフトウェアの歴史において繰り返し現れるパターンだ。

---

## 3. SSHの技術設計――暗号化されたテキストストリーム

### プロトコルアーキテクチャ：3層構造

SSH-2のプロトコルは、明確に分離された3つの層で構成されている。この層構造が、SSHの柔軟性と拡張性の源泉だ。

```
SSH-2 プロトコルアーキテクチャ:

  ┌─────────────────────────────────────────────┐
  │        Connection Protocol (RFC 4254)        │
  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────────┐   │
  │  │Shell │ │SFTP  │ │Port  │ │X11       │   │
  │  │      │ │      │ │Fwd   │ │Forwarding│   │
  │  └──────┘ └──────┘ └──────┘ └──────────┘   │
  │  チャネル多重化: 一つの接続に複数のチャネル   │
  ├─────────────────────────────────────────────┤
  │    User Authentication Protocol (RFC 4252)   │
  │    パスワード認証 / 公開鍵認証 / ホストベース │
  ├─────────────────────────────────────────────┤
  │      Transport Layer Protocol (RFC 4253)     │
  │    鍵交換(DH) / サーバ認証 / 暗号化 / MAC    │
  │    → 完全性検証、前方秘匿性                  │
  ├─────────────────────────────────────────────┤
  │              TCP (ポート22)                   │
  └─────────────────────────────────────────────┘
```

最下層のTransport Layer Protocol（RFC 4253）は、暗号化の基盤を提供する。クライアントとサーバが接続を確立すると、まずプロトコルバージョンの交換が行われ、続いてDiffie-Hellman鍵交換によってセッション鍵が生成される。このセッション鍵を使って、以降のすべての通信が暗号化される。サーバ認証もこの層で行われる。ホスト鍵のフィンガープリントを検証することで、接続先が本当に意図したサーバであることを確認する。

「The authenticity of host 'example.com' can't be established.」というメッセージを見たことがあるだろう。あれは、Transport Layerのサーバ認証が、初回接続で既知のホスト鍵を持っていない状態であることを示している。中間者攻撃（Man-in-the-Middle Attack）を防ぐための仕組みだ。

中間層のUser Authentication Protocol（RFC 4252）は、ユーザー認証を担う。パスワード認証、公開鍵認証、ホストベース認証など、複数の認証メカニズムをサポートする。公開鍵認証は、パスワードをネットワーク上に流さずに認証を行える。秘密鍵はローカルマシンに保持され、その鍵で生成した署名だけがサーバに送られる。

最上層のConnection Protocol（RFC 4254）は、暗号化されたトンネルの上に複数の論理的なチャネルを構築する。シェルセッション、ファイル転送（SFTP）、ポートフォワーディング、X11フォワーディング――これらすべてが、一つのTCP接続の上で多重化される。

この設計の美しさは、関心の分離にある。暗号化の仕組みを変更しても、上位層の認証やチャネル管理には影響しない。新しい認証メカニズムを追加しても、トランスポート層や接続層を変更する必要がない。

### ポートフォワーディング：トンネルの力

SSHのポートフォワーディングは、暗号化されたトンネルを通じて任意のTCPトラフィックを転送する機能だ。これは、SSHが単なるリモートシェル以上の存在であることを示す。

```
SSHポートフォワーディングの仕組み:

  ローカルフォワーディング (-L):
    ローカルマシン:8080 → SSHトンネル → リモート:80
    $ ssh -L 8080:internal-server:80 bastion-host
    → localhost:8080 にアクセスすると、
      bastion-host 経由で internal-server:80 に到達

  リモートフォワーディング (-R):
    リモート:9090 → SSHトンネル → ローカル:3000
    $ ssh -R 9090:localhost:3000 remote-server
    → remote-server:9090 にアクセスすると、
      SSHトンネル経由でローカルの3000番ポートに到達

  ダイナミックフォワーディング (-D):
    $ ssh -D 1080 remote-server
    → localhost:1080 がSOCKSプロキシとして動作
    → すべてのTCPトラフィックをSSHトンネル経由で転送
```

ローカルフォワーディング（`-L`）は、ローカルマシンのポートへの接続を、SSHトンネルを通じてリモート側の任意のホスト・ポートに転送する。ファイアウォールの内側にある内部サーバに、外部からセキュアにアクセスする手段として広く使われている。

リモートフォワーディング（`-R`）は逆方向の転送だ。リモートマシンのポートへの接続を、SSHトンネルを通じてローカル側に転送する。NATの内側にあるマシンのサービスを外部に公開する手段として利用できる。

ダイナミックフォワーディング（`-D`）はさらに汎用的だ。SOCKSプロキシとして動作し、任意のTCPトラフィックをSSHトンネル経由で転送する。

これらの機能が示しているのは、SSHが「テキストを暗号化して送るプロトコル」を超えた存在だということだ。SSHは、暗号化されたネットワークトンネルを構築するための汎用的な基盤であり、その上にあらゆるサービスを通すことができる。

### SFTPとSCP：ファイル転送の進化

FTP（File Transfer Protocol）は、telnetと同様に平文でパスワードとデータを送信するプロトコルだった。SSHの暗号化チャネルの上に構築されたファイル転送プロトコルがSFTP（SSH File Transfer Protocol）だ。

SFTPはSSH-2のサブシステムとして設計されており、SSHの接続プロトコル上で動作する。つまり、SSHのポート22を共有し、SSHの暗号化と認証の恩恵をすべて受ける。FTPのように別ポートを開く必要もなく、ファイアウォール設定も単純になる。

SCP（Secure Copy）はSSHの初期から存在するファイル転送機能であり、rcp（remote copy）のセキュア版だ。SCPはシンプルだが、SFTPと比べると機能は限定的で、ディレクトリのリスト表示やファイルの部分転送といった高度な操作には対応しない。

### 多段接続とProxyJump

実際のインフラストラクチャでは、セキュリティ上の理由から、直接SSHで接続できないサーバが存在する。踏み台サーバ（bastion host）を経由して内部サーバに到達する多段接続が必要になる。

OpenSSH 7.3で導入されたProxyJumpディレクティブは、この多段接続を劇的に簡素化した。

```
~/.ssh/config による多段接続:

  # 踏み台サーバ
  Host bastion
      HostName bastion.example.com
      User admin

  # 内部サーバ（踏み台経由）
  Host internal-db
      HostName 10.0.1.50
      User dbadmin
      ProxyJump bastion

  接続:
  $ ssh internal-db
  → 自動的に bastion を経由して 10.0.1.50 に接続
```

ProxyJump以前は、ProxyCommandディレクティブでnetcatやsshコマンドを手動で指定する必要があった。ProxyJumpはこの操作を一つのキーワードに凝縮した。複数の踏み台を経由する場合も、カンマ区切りで指定するだけでよい。

OpenSSH 3.9（2004年8月）で導入されたControlMasterとControlPathディレクティブも、多段接続の効率化に貢献した。同じホストへの複数の接続を、一つのTCPコネクション上で多重化する。初回接続のみTCPハンドシェイクと認証が行われ、以降の接続は既存のコネクションに「相乗り」する。接続速度の向上とサーバ側の負荷軽減の両方が得られる。

### テキストストリームの帯域効率

SSHがリモート操作の主役であり続ける理由の一つは、テキストストリームの帯域効率にある。

VNC（Virtual Network Computing）は、画面のピクセルデータをネットワーク越しに転送する。画面が変更されるたびに、変更された領域のビットマップが送信される。RDP（Remote Desktop Protocol）はVNCよりも効率的で、グラフィカルな描画命令を送信する。ローカルマシンがその命令をレンダリングするため、ビットマップの転送よりは帯域を消費しない。

一方、SSHで流れるのはテキストだ。キーストロークが数バイト、コマンドの出力が数十から数千バイト。画面全体を描画する必要がない。変更された文字列だけが送信される。

```
リモートアクセスの帯域効率比較:

  プロトコル    送信データの性質         帯域消費
  ─────────────────────────────────────────────
  SSH/telnet    テキスト文字列           最小
                (キーストローク+出力)    数KB/s程度

  RDP           グラフィカル描画命令     中
                (レンダリングはローカル) 数十KB〜数MB/s

  VNC           ピクセルデータ           大
                (画面キャプチャの差分)   数百KB〜数MB/s

  → SSHは衛星回線やIoT環境のような
    超低帯域接続でも実用的
```

この帯域効率の差は、ネットワーク環境が劣悪なほど顕著になる。衛星回線、3G/4Gモバイル回線、国際回線――高レイテンシ・低帯域の環境では、GUIリモートデスクトップの操作は事実上不可能になるが、SSHは依然として実用的だ。

私自身、VPN越しにRDP（リモートデスクトップ接続）でWindows環境を操作しようとして、あまりの遅さに苛立ちSSHに戻った経験が何度もある。テキストストリームが帯域に優しいという事実は、単なる技術的トリビアではない。リモートワークの生産性に直結する構造的な優位性だ。

---

## 4. SSHの限界とMoshの挑戦

### SSHの構造的な弱点

SSHは優れたプロトコルだが、万能ではない。特に、モバイル環境や不安定なネットワークでの使用において、構造的な弱点を持つ。

SSHはTCP上で動作する。TCPは信頼性の高い通信を提供するが、そのために接続状態を持つ（stateful）。クライアントとサーバが一つのTCPコネクションを維持し、そのコネクションの上でデータをやり取りする。

この設計が問題になるのは、ネットワークが不安定な場合だ。Wi-Fiアクセスポイントを切り替えたとき、モバイル回線が一時的に途切れたとき、VPNが再接続されたとき――これらの状況でIPアドレスが変更されると、TCPコネクションは破棄される。SSHセッションは切断され、作業中のコマンドは失われる。

もう一つの弱点は、キーストロークの遅延だ。SSHでは、ユーザーが打った文字はまずサーバに送信され、サーバがその文字をエコーバック（返送）して初めて画面に表示される。ネットワークのラウンドトリップタイム（RTT）が大きい環境では、キーを打ってから画面に文字が表示されるまでに顕著な遅延が生じる。RTTが500msの環境では、一文字打つごとに500msの待ちが発生する。

```
SSHのキーストローク遅延:

  ユーザー              ネットワーク              サーバ
    │                                              │
    │ キーストローク 'l'                            │
    │ ─────────────────→  RTT/2  ─────────────────→│
    │                                              │ echo 'l'
    │←─────────────────  RTT/2  ←──────────────────│
    │                                              │
    │ キーストローク 's'                            │
    │ ─────────────────→         ─────────────────→│
    │                                              │ echo 's'
    │←─────────────────         ←──────────────────│

  RTT = 500ms の場合:
    "ls" と打つのに最低1秒かかる
    → 対話的操作が著しく困難になる
```

tmuxやscreenのようなターミナルマルチプレクサは、セッションの永続性の問題を部分的に解決する。SSH接続が切れても、サーバ側でtmuxセッションが維持されているため、再接続後にセッションを復元できる。だが、これはアプリケーション層の回避策であり、プロトコル層の問題を根本的に解決するものではない。

### Mosh：2012年のプロトコル再設計

2012年、MITのComputer Science and Artificial Intelligence Laboratory（CSAIL）で、Keith WinsteinとHari BalakrishnanがMosh（mobile shell）を発表した。USENIXのAnnual Technical Conferenceで発表されたこの論文は、SSHの構造的弱点を正面から解決しようとするものだった。

Moshの設計は、SSHとは根本的に異なる前提に立つ。

第一に、UDPベースの通信。MoshはState Synchronization Protocol（SSP）という独自のプロトコルを使用し、UDPの上で動作する。UDPは接続状態を持たない（stateless）プロトコルだ。TCPのように「コネクション」を維持する必要がない。クライアントのIPアドレスが変わっても、次のパケットが新しいIPアドレスから届けば、サーバは自動的にそのアドレスを新しい送信先として認識する。Wi-Fiからモバイル回線への切り替え、VPNの再接続、ノートPCのスリープと復帰――これらのすべてが、セッションの切断なしに処理される。

第二に、予測的ローカルエコー。Moshのクライアントは、サーバの挙動を予測するモデルをローカルで実行する。ユーザーがキーを打つと、サーバの応答を待たずに、クライアント側で即座に文字を表示する。「このキーストロークはおそらくカーソル位置にエコーされるだろう」という予測に基づいて表示し、サーバからの確認が届いた時点で表示を確定する。予測が未確認の間は下線で表示することで、ユーザーに「まだサーバの確認を待っている」ことを視覚的に伝える。

```
Mosh の予測的ローカルエコー:

  ユーザー              ローカル予測              サーバ
    │                      │                       │
    │ キーストローク 'l'    │                       │
    │ ─→ 即座に 'l' を表示 │ ─── UDP ───────────→ │
    │    (下線付き)        │                       │
    │ キーストローク 's'    │                       │
    │ ─→ 即座に 's' を表示 │ ─── UDP ───────────→ │
    │    (下線付き)        │                       │ 状態同期
    │                      │ ←── UDP ──────────── │
    │ ←─ 下線を除去        │                       │
    │    (サーバ確認済み)   │                       │

  結果: ユーザーが感じる遅延 ≈ 0ms
  （RTTに関係なく即座にフィードバック）
```

WinsteinとBalakrishnanの論文によれば、商用3G（EV-DO）ネットワークでの計測において、SSHのキーストローク応答遅延の中央値が503msだったのに対し、Moshでは5ms未満を達成した。予測可能なキーストロークの70%以上が即座に表示されたためだ。

第三に、状態同期モデル。SSHがバイトストリームを順序通りに転送するのに対し、MoshのSSPはクライアントとサーバの「状態」を同期する。サーバ側のターミナル状態（画面に表示されている内容）がオブジェクトとして管理され、その状態の差分がクライアントに送信される。パケットの順序が入れ替わっても、古い状態は無視され、最新の状態だけが反映される。TCPのようなパケットの再送と順序保証が不要なため、パケットロスに対する耐性が高い。

Moshの暗号化はAES-128のOCB3モードを使用し、認証と暗号化を同時に行う。ハートビートは3秒ごとに送信され、接続の生存確認とNATテーブルの維持を兼ねる。

ただし、Moshには重要な制約がある。初回接続にはSSHを使用する。Moshサーバの起動とセッション鍵の交換はSSH経由で行われ、その後UDPベースのSSPに切り替わる。つまり、MoshはSSHの代替ではなく、SSHの上に構築された補完的なプロトコルだ。また、SSHのポートフォワーディングやX11フォワーディングはMoshではサポートされない。

### tmux + SSH：現場のプラクティス

Moshが解決しようとした問題の多くは、現場では長らくtmux（あるいは前身のGNU screen）とSSHの組み合わせで対処されてきた。

tmuxはサーバ側で動作するターミナルマルチプレクサだ。SSHセッションが切断されても、tmuxのセッションはサーバ上で実行を続ける。再度SSHで接続し、`tmux attach`を実行すれば、切断前の状態をそのまま復元できる。長時間実行されるコマンド（ビルド、デプロイ、データ移行など）を、SSH接続の不安定さから守る定番の手法だ。

```
tmux + SSH の運用パターン:

  1. SSHで接続
     $ ssh server.example.com

  2. tmuxセッションを開始（またはアタッチ）
     $ tmux new -s work    # 新規セッション
     $ tmux attach -t work # 既存セッションにアタッチ

  3. 作業中にSSH接続が切れても...
     → tmuxセッションはサーバ上で継続

  4. 再接続してセッションを復元
     $ ssh server.example.com
     $ tmux attach -t work
     → 切断前の状態がそのまま表示される

  tmux内での分割:
  ┌────────────────┬────────────────┐
  │ ペイン1:       │ ペイン2:       │
  │ コード編集     │ テスト実行     │
  │ (vim)         │ (npm test)     │
  ├────────────────┴────────────────┤
  │ ペイン3: サーバログ監視         │
  │ (tail -f /var/log/app.log)     │
  └─────────────────────────────────┘
```

tmuxは第4回で語ったVT100端末からの系譜の延長線上にある。ターミナルマルチプレクサは、仮想端末を複数作成し、それぞれで独立したシェルセッションを実行する。この「端末の仮想化」は、物理端末からソフトウェア端末への移行と同じ力学だ。

Moshとtmux + SSHの組み合わせは、どちらが「正解」というものではない。Moshはプロトコル層で問題を解決し、tmux + SSHはアプリケーション層で問題を回避する。現場では、Mosh + tmuxの二重の保険をかける運用も珍しくない。

---

## 5. ハンズオン：SSHの仕組みを体験する

### 環境構築

```bash
# Docker環境で実行（ubuntu:24.04ベース）
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：SSHの基礎を確認する

```bash
apt-get update && apt-get install -y openssh-client openssh-server net-tools

echo "=== 演習1: SSHの基礎を確認する ==="
echo ""

echo "--- OpenSSHのバージョン ---"
ssh -V
echo ""
echo "→ OpenSSHのバージョンとリンクされた暗号ライブラリが表示される。"
echo "  OpenSSHは1999年にOpenBSDプロジェクトから生まれた。"
echo ""

echo "--- SSHがサポートする暗号アルゴリズム ---"
echo ""
echo "鍵交換アルゴリズム:"
ssh -Q kex 2>/dev/null | head -10
echo "..."
echo ""

echo "暗号化アルゴリズム:"
ssh -Q cipher 2>/dev/null | head -10
echo "..."
echo ""

echo "MAC (Message Authentication Code):"
ssh -Q mac 2>/dev/null | head -10
echo "..."
echo ""

echo "→ SSH-2では暗号アルゴリズムがネゴシエーション可能。"
echo "  クライアントとサーバが共通にサポートするアルゴリズムを自動選択する。"
```

### 演習2：SSH鍵ペアの生成と構造

```bash
echo ""
echo "=== 演習2: SSH鍵ペアの生成と構造 ==="
echo ""

echo "--- Ed25519鍵ペアの生成 ---"
ssh-keygen -t ed25519 -f /tmp/test_key -N "" -C "handson@example.com"
echo ""

echo "--- 秘密鍵の内容（先頭のみ） ---"
head -3 /tmp/test_key
echo "..."
echo ""
echo "→ PEM形式でエンコードされた秘密鍵。"
echo "  絶対に他人に渡してはならない。"
echo ""

echo "--- 公開鍵の内容 ---"
cat /tmp/test_key.pub
echo ""
echo "→ この公開鍵をリモートサーバの ~/.ssh/authorized_keys に追加することで、"
echo "  パスワードなしでSSH認証が可能になる。"
echo "  秘密鍵で生成した署名をサーバが公開鍵で検証する仕組みだ。"
echo ""

echo "--- 鍵のフィンガープリント ---"
ssh-keygen -l -f /tmp/test_key.pub
echo ""
echo "→ フィンガープリントは鍵のハッシュ値。"
echo "  ホスト鍵の検証時に「この鍵は正しいか」を確認するために使う。"
echo ""

echo "--- 鍵の種類の比較 ---"
echo "  RSA:     最も古い方式、互換性が高い（2048bit以上推奨）"
echo "  ECDSA:   楕円曲線暗号、RSAより短い鍵で同等の安全性"
echo "  Ed25519: 現在の推奨、高速かつ安全、鍵が短い"

rm -f /tmp/test_key /tmp/test_key.pub
```

### 演習3：SSHサーバのホスト鍵を確認する

```bash
echo ""
echo "=== 演習3: SSHサーバのホスト鍵を確認する ==="
echo ""

echo "--- ホスト鍵の生成 ---"
mkdir -p /etc/ssh
ssh-keygen -A 2>/dev/null
echo ""

echo "--- 生成されたホスト鍵 ---"
ls -la /etc/ssh/ssh_host_*_key.pub 2>/dev/null
echo ""

echo "--- 各ホスト鍵のフィンガープリント ---"
for keyfile in /etc/ssh/ssh_host_*_key.pub; do
    if [ -f "$keyfile" ]; then
        echo "$(basename "$keyfile"):"
        ssh-keygen -l -f "$keyfile"
        echo ""
    fi
done

echo "→ SSHサーバは複数の種類のホスト鍵を持つ。"
echo "  初回接続時に表示される「フィンガープリント」は、"
echo "  これらの鍵のハッシュ値だ。"
echo ""
echo "  'The authenticity of host ... can't be established.'"
echo "  → このメッセージは、接続先のホスト鍵が"
echo "    ~/.ssh/known_hosts に登録されていないことを意味する。"
echo "  → 中間者攻撃（MITM）を防ぐための仕組みだ。"
```

### 演習4：ポートフォワーディングの概念を理解する

```bash
echo ""
echo "=== 演習4: SSHポートフォワーディングの概念 ==="
echo ""

echo "--- ローカルフォワーディング (-L) ---"
echo ""
echo "構文: ssh -L [ローカルポート]:[宛先ホスト]:[宛先ポート] 踏み台"
echo ""
echo "例: ssh -L 8080:internal-db:5432 bastion.example.com"
echo ""
echo "  ローカル:8080 → SSHトンネル → bastion → internal-db:5432"
echo ""
echo "  用途: ファイアウォール内のデータベースに"
echo "        ローカルマシンから安全にアクセス"
echo ""

echo "--- リモートフォワーディング (-R) ---"
echo ""
echo "構文: ssh -R [リモートポート]:[宛先ホスト]:[宛先ポート] リモート"
echo ""
echo "例: ssh -R 9090:localhost:3000 public-server.example.com"
echo ""
echo "  public-server:9090 → SSHトンネル → ローカル:3000"
echo ""
echo "  用途: NATの内側にある開発サーバを"
echo "        外部に一時的に公開"
echo ""

echo "--- ダイナミックフォワーディング (-D) ---"
echo ""
echo "構文: ssh -D [ローカルポート] リモート"
echo ""
echo "例: ssh -D 1080 remote-server.example.com"
echo ""
echo "  localhost:1080 がSOCKSプロキシとして動作"
echo "  → ブラウザのプロキシ設定で指定すれば、"
echo "    すべてのHTTPトラフィックがSSHトンネルを通過"
echo ""
echo "→ SSHは単なるリモートシェルではない。"
echo "  暗号化されたネットワークトンネルの汎用基盤だ。"
```

### 演習5：ssh_configによる効率的な接続管理

```bash
echo ""
echo "=== 演習5: ssh_configによる接続管理 ==="
echo ""

echo "--- ~/.ssh/config の例 ---"
cat << 'SSHCONFIG'

# デフォルト設定（すべてのホストに適用）
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    AddKeysToAgent yes

# 踏み台サーバ
Host bastion
    HostName bastion.example.com
    User admin
    IdentityFile ~/.ssh/id_ed25519_work

# 内部サーバ（踏み台経由、ProxyJump使用）
Host internal-*
    User deploy
    ProxyJump bastion
    IdentityFile ~/.ssh/id_ed25519_work

Host internal-web
    HostName 10.0.1.10

Host internal-db
    HostName 10.0.1.20

# 接続多重化（ControlMaster）
Host *.example.com
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600

SSHCONFIG

echo ""
echo "--- 設定のポイント ---"
echo ""
echo "1. ServerAliveInterval/CountMax:"
echo "   → 60秒ごとにキープアライブを送信、3回失敗で切断"
echo "   → NATタイムアウトやファイアウォールによる切断を防止"
echo ""
echo "2. ProxyJump:"
echo "   → OpenSSH 7.3以降で利用可能"
echo "   → 'ssh internal-web' だけで踏み台経由の接続が完了"
echo ""
echo "3. ControlMaster/ControlPath/ControlPersist:"
echo "   → OpenSSH 3.9以降で利用可能"
echo "   → 同一ホストへの複数接続を一つのTCPコネクションで多重化"
echo "   → 2回目以降の接続が瞬時に確立される"
echo ""

echo "=== まとめ ==="
echo ""
echo "1. SSHは1995年にTatu Ylonenが暗号化リモートアクセスとして開発した"
echo "2. OpenSSH（1999年）が事実上の標準実装となっている"
echo "3. SSH-2は3層アーキテクチャで暗号化・認証・チャネル管理を分離"
echo "4. ポートフォワーディングにより任意のTCPトラフィックを暗号化転送可能"
echo "5. ssh_configでProxyJump、ControlMaster等の高度な接続管理が可能"
echo "6. テキストストリームの帯域効率が、リモートCLIの構造的優位性の源泉"
```

ハンズオンの自動セットアップスクリプトは `handson/command-line/16-ssh-and-remote-cli/setup.sh` を参照してほしい。

---

## 6. まとめと次回予告

### この回の要点

第一に、リモートアクセスの歴史は、信頼の前提が崩壊する過程だ。telnet（1969年/1983年標準化）はネットワークが信頼できることを前提としていた。Berkeley r-commands（1983年、BSD 4.2）はホスト間の信頼関係に依存した。いずれもパスワードを平文で送信していた。1995年、Helsinki University of Technologyでのパスワード盗聴事件が、暗号化リモートアクセスの必要性を決定的にした。

第二に、SSH（Secure Shell）は1995年にTatu Ylonenが開発し、7月にフリーソフトウェアとして公開した。年末までに50カ国2万ユーザーに普及した。SSH-2はSSH-1の脆弱性を修正した新設計であり、Diffie-Hellman鍵交換、AES暗号化、MACによるデータ完全性検証を導入した。2006年にRFC 4251-4254として標準化された。

第三に、OpenSSH（1999年、OpenBSDプロジェクト）は、Tatu Ylonenのssh 1.2.12を基に再実装された自由なSSH実装だ。事実上すべてのLinux、BSD、macOSに標準搭載され、Windows 10以降にもクライアント・サーバの両方が組み込まれた。

第四に、SSHのプロトコルアーキテクチャは、Transport Layer（暗号化・鍵交換）、User Authentication（認証）、Connection Protocol（チャネル多重化）の3層で構成される。ポートフォワーディング、SFTP、ProxyJump、ControlMasterなどの機能により、SSHは単なるリモートシェルを超えた暗号化ネットワーク基盤として機能する。

第五に、Mosh（2012年、MIT、Keith WinsteinとHari Balakrishnan）は、SSHのTCPベースの構造的弱点――IPアドレス変更によるセッション切断、高レイテンシ環境でのキーストローク遅延――をUDPベースのState Synchronization Protocolと予測的ローカルエコーで解決した。

### 冒頭の問いへの暫定回答

CLIはなぜリモート操作の「唯一解」であり続けるのか。

答えは、テキストストリームの帯域効率にある。SSHで流れるデータはテキストだ。キーストロークが数バイト、コマンドの出力が数キロバイト。GUIリモートデスクトップが画面全体のピクセルデータや描画命令を転送するのに対し、CLIは変更された文字列だけを送信する。この構造的な差は、ネットワーク環境が劣悪なほど顕著になる。

だが、帯域効率だけが理由ではない。SSHの歴史が示しているのは、テキストストリームの「組み合わせ可能性」がリモート環境でも失われないという事実だ。ローカルで`grep`、`awk`、`sort`をパイプで繋ぐのと同じように、SSH越しでも同じコマンドをパイプで繋げる。リモートの操作がローカルの操作と同じインターフェースで行える。これこそが、第7回で語ったUNIXパイプの設計思想が、ネットワーク越しにも有効であることの証明だ。

テキストストリームは距離を超える。1969年のtelnetから2012年のMoshまで、プロトコルは変わっても、「テキストを送り、テキストを受け取る」という基本構造は50年以上変わっていない。

### 次回予告

次回、第17回「Rust製CLIツールの波――ripgrep, fd, bat, eza」では、50年間使われてきたcoreutilsを「書き直す」意味はどこにあるのかを問う。

2016年、Andrew GallantがRust言語で実装したripgrepが公開された。grepの10倍以上の速度。`.gitignore`の自動読み込み。デフォルトの再帰検索と色付き出力。それは単なる「速いgrep」ではなく、CLIツールのUXを根本から再考する動きの始まりだった。fd、bat、eza、delta、zoxide、starship――Rust製CLIツール群が、50年前の設計思想をどのようにモダナイズしているのか。その波の意味を考えてみてほしい。

---

## 参考文献

- Wikipedia, "Telnet", <https://en.wikipedia.org/wiki/Telnet>
- RFC 15, Steve Carr, 1969, <https://www.rfc-editor.org/rfc/rfc15>
- RFC 854, J. Postel, J. Reynolds, "Telnet Protocol Specification", 1983, <https://datatracker.ietf.org/doc/html/rfc854>
- RFC 855, J. Postel, J. Reynolds, "Telnet Option Specifications", 1983, <https://datatracker.ietf.org/doc/html/rfc855>
- Wikipedia, "Berkeley r-commands", <https://en.wikipedia.org/wiki/Berkeley_r-commands>
- Wikipedia, "Secure Shell", <https://en.wikipedia.org/wiki/Secure_Shell>
- machaddr.substack.com, "SSH: The Origins of How Tatu Ylönen Secured the Internet", <https://machaddr.substack.com/p/ssh-the-origins-of-how-tatu-ylonen>
- Tatu Ylonen Home Page, <https://ylonen.org/>
- RFC 4251, T. Ylonen, C. Lonvick, "The Secure Shell (SSH) Protocol Architecture", 2006, <https://datatracker.ietf.org/doc/html/rfc4251>
- RFC 4252, T. Ylonen, C. Lonvick, "The Secure Shell (SSH) Authentication Protocol", 2006, <https://datatracker.ietf.org/doc/html/rfc4252>
- RFC 4253, T. Ylonen, C. Lonvick, "The Secure Shell (SSH) Transport Layer Protocol", 2006, <https://datatracker.ietf.org/doc/html/rfc4253>
- RFC 4254, T. Ylonen, C. Lonvick, "The Secure Shell (SSH) Connection Protocol", 2006, <https://datatracker.ietf.org/doc/html/rfc4254>
- OpenSSH, "Project History", <https://www.openssh.org/history.html>
- Wikipedia, "OpenSSH", <https://en.wikipedia.org/wiki/OpenSSH>
- Keith Winstein, Hari Balakrishnan, "Mosh: An Interactive Remote Shell for Mobile Clients", USENIX ATC '12, <https://mosh.org/mosh-paper.pdf>
- Mosh: the mobile shell, <https://mosh.org/>
- Jeff Geerling, "A brief history of SSH and remote access", <https://www.jeffgeerling.com/blog/brief-history-ssh-and-remote-access>
- TechTarget, "SSH2 vs. SSH1 and why SSH versions still matter", <https://www.techtarget.com/searchsecurity/tip/An-introduction-to-SSH2>
- OpenBSD, "ssh_config manual", <https://man.openbsd.org/ssh_config>
