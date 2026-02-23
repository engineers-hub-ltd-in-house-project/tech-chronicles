# UNIXという思想

## ——パイプ、プロセス、ファイル――すべてはここから始まった

### 第15回：「サーバOSとしてのLinux支配——なぜ企業はLinuxを選んだか」

**連載「UNIXという思想——パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 1990年代末のdotcomブームにおけるLAMPスタックの台頭と、Linux+Apacheがインターネットインフラの標準となった経緯
- IBMの10億ドル投資（2001年）が企業のLinux採用を正当化した構造的意味
- Red Hat Enterprise Linux（2002年）のサブスクリプションモデルが切り拓いた「無料ソフトウェアの有料サポート」というビジネスモデル
- Google、Amazonに代表されるWeb企業がLinux+x86アーキテクチャで構築したスケールアウト型インフラの設計思想
- Microsoft "Get the Facts" キャンペーンやSCO訴訟といった逆風が、結果的にLinuxの法的・商業的正当性を確認した皮肉
- サーバOSとしてのLinux支配が、技術的優位性だけでなくビジネスモデルの革新と市場構造の変化によって実現された背景

---

## 1. 「Linuxで大丈夫なのか」

2003年の春、私は金融系システムのインフラ更改プロジェクトに参加していた。当時動いていたのはSolaris 8。Sun SPARC上で安定稼働しているシステムを、x86サーバとLinuxに移行する——それがプロジェクトの骨子だった。

技術的な検証は私の担当だった。Red Hat Linux Advanced Server 2.1を評価環境に構築し、Oracle 9iを載せ、負荷テストを回す。結果は良好だった。パフォーマンスはSPARCと遜色なく、場合によってはx86のほうが速い。コストは半分以下。技術的には移行に問題ないという結論を出した。

だが、経営層の反応は「Linuxで大丈夫なのか」だった。

この問いには二つの層があった。一つは純粋な技術的懸念——無料のOSが、金を払って買った商用UNIXと同じ信頼性を提供できるのか。もう一つはビジネス上の懸念——何か問題が起きたとき、誰が責任を取るのか。Sunに電話すればエンジニアが飛んでくる。Linuxの場合、誰に電話すればいい。

この二つの懸念は、2000年代初頭のLinux採用における最大の障壁だった。技術的には十分な水準に達していたが、「企業が業務に使うOS」としての信頼が確立されていなかった。無料であることが、逆に不安を生む。「タダより高いものはない」という日本の諺が、IT部門の会議室で何度も引用されるのを聞いた。

結局、そのプロジェクトではRed Hatとサポート契約を結ぶことで経営層の承認を得た。年間のサブスクリプション費用はSolarisのライセンスよりはるかに安かった。だが重要だったのは金額ではない。「何かあったときに電話できる相手がいる」——この一点が、Linux採用の決め手になった。

振り返れば、これはLinuxのサーバ市場制覇の縮図だった。技術的な優位性だけではOSは選ばれない。ビジネスモデル、サポート体制、エコシステム——技術の外側にある要素が、企業の意思決定を動かす。「無料のOS」が「企業の基幹システム」に採用されるまでには、技術とは異なるレイヤーでの革新が必要だった。

あなたの現場では、技術選定の最終判断を下すのは誰だろうか。そしてその判断基準は、純粋に技術的なものだろうか。

---

## 2. LAMPスタックからIBMの10億ドルまで——企業がLinuxを選ぶまで

### dotcomブームとLAMPスタック

LinuxがサーバOSとして台頭した最初の大きな波は、1990年代末のdotcomブームだった。

1998年12月、ドイツのコンピュータ誌『Computertechnik』で、Michael Kunzeが「LAMP」という頭字語を生み出した。Linux、Apache、MySQL、PHP/Perl——この4つのオープンソースソフトウェアの組み合わせが、高価な商用パッケージに代わりうることを示した論考だった。O'Reilly MediaとMySQL ABがこの概念の普及に貢献し、LAMPスタックはWebアプリケーション開発の事実上の標準となっていく。

dotcomブームの時代、無数のスタートアップがWebサービスを立ち上げた。彼らに共通していたのは、潤沢とは言えない予算と、スピード最優先の開発体制だ。商用UNIXサーバに何百万円も投じる余裕はない。Windows NTのライセンス費用すら節約したい。LAMPスタックは、その切実なニーズに完璧に応えた。

Linux + Apache + MySQL + PHP/Perlのすべてが無料だ。安価なx86サーバにインストールすれば、その日からWebサービスを公開できる。ApacheはすでにWebサーバ市場で圧倒的なシェアを持っていた。MySQLは商用データベースの数分の一のコストで動作した。PHPは学習コストが低く、HTMLに埋め込むだけでダイナミックなページを生成できた。

2000年3月10日にdotcomバブルが頂点を迎え、その後崩壊する。だがバブルの崩壊は、LAMPスタックの普及を止めるどころか加速させた。コスト削減圧力が強まり、商用ソフトウェアのライセンス費用を削る動きが全業界で広がった。「安価なx86サーバ + Linux + オープンソース」という組み合わせは、バブル崩壊後のコスト意識に合致していた。

### IBMの賭け——10億ドルの意味

2000年12月、IBMのCEO Lou GerstnerがeBusiness Expoで発表した内容は、企業IT史における転換点だった。「IBMは来年、Linux事業に10億ドルを投資する」。

この発表のインパクトを理解するには、当時のIBMの立場を知る必要がある。IBMはAIX（自社の商用UNIX）を販売しており、Linuxへの投資は自社製品との共食いになりうる。にもかかわらず10億ドルを投じるという判断は、市場の潮流を読み切った戦略的決断だった。

IBMの10億ドル投資は、ハードウェア、ソフトウェア、サービスの全領域にわたるものだった。約1,500名の開発者がLinux関連の業務に投入された。具体的には、Linuxカーネルへのコード貢献、自社ハードウェア（POWER、S/390メインフレーム、xSeriesサーバ）でのLinux対応、Linux上でのDB2やWebSphereの稼働確認と最適化、そしてLinux導入のコンサルティングサービスだ。

この投資が企業のLinux採用にもたらした効果は、技術的な貢献以上のものだった。IBMという名前が持つ意味を考えてほしい。1960年代からメインフレームで企業のIT基盤を支えてきた巨人が、「Linuxに賭ける」と宣言したのだ。IT部門の責任者が上層部に「Linuxを採用したい」と提案するとき、「IBMも10億ドル投資している」と言えることの意味は計り知れない。かつて「IBMを選んで首になった人はいない」と言われたように、IBMの支持はLinux採用のリスクを劇的に下げた。

1999年末には、IBMはS/390メインフレーム向けのLinuxカーネルパッチを公開し、2000年1月にはMarist CollegeがS/390向け最初のLinuxディストリビューションを配布した。メインフレームという最も保守的な領域にまでLinuxが浸透し始めた瞬間だった。IBMにとってLinuxは、自社のハードウェアプラットフォーム全体を横断する共通OS層として位置づけられた。x86サーバからPOWERサーバ、メインフレームまで、同じLinuxが動く——このメッセージは、異種混合環境を抱える大企業に強く響いた。

2002年2月には、IBMの投資はほぼ回収されたと報じられた。投資した10億ドルが2年足らずで回収される——これはLinux関連のハードウェア、ソフトウェア、サービスの売上がそれだけ急成長したことを意味する。

### Red Hat Enterprise Linux——「無料のOS」のビジネスモデル

IBMの投資が「企業がLinuxを検討する正当性」を与えたとすれば、Red Hatのサブスクリプションモデルは「企業がLinuxを購入する方法」を確立した。

2002年3月23日、Red Hatは「Red Hat Linux Advanced Server」をリリースした。これがRHELの最初のバージョンだ。2003年には「Red Hat Enterprise Linux AS/ES/WS」に改称され、同時にコミュニティ向けのRed Hat Linuxは終了し、Fedora Core（2003年11月6日リリース）とRHELに分離された。

この分離の戦略的意味は明確だった。Red Hat Linuxの6ヶ月ごとのリリースサイクルは、ビジネスユーザにとって過度に破壊的だった。企業は安定性を求める。一方で、オープンソースコミュニティは最新技術の迅速な統合を求める。この二つの要求は根本的に相容れない。Red Hatの解は、Fedoraで最新技術の実験を行い、十分に成熟した技術をRHELに取り込むという二段構えの開発モデルだった。

RHELのビジネスモデルの革新性は、ソフトウェア自体は無料で、サポートとメンテナンスに課金するという点にある。ソースコードはGPLに基づいて公開される。誰でも自由にダウンロードし、コンパイルし、使用できる。だがRed Hatのサブスクリプションを購入すれば、テスト済みのバイナリ、セキュリティパッチ、バグフィックス、10年間のライフサイクルサポート、そして技術サポート窓口へのアクセスが得られる。

```
Red Hatのサブスクリプションモデル:

  従来の商用ソフトウェア          Red Hatモデル
  ┌────────────────────┐        ┌────────────────────┐
  │ ソフトウェアライセンス│        │ ソースコード      │
  │ （購入必須・高額）    │        │ （無料・GPL公開）  │
  ├────────────────────┤        ├────────────────────┤
  │ 保守契約              │        │ サブスクリプション │
  │ （年間費用）          │        │ （年間費用）      │
  │ - パッチ              │        │ - テスト済みバイナリ│
  │ - アップデート        │        │ - セキュリティパッチ│
  │ - 技術サポート        │        │ - 10年サポート     │
  │                      │        │ - 技術サポート窓口 │
  │                      │        │ - 認定ハードウェア │
  └────────────────────┘        └────────────────────┘

  合計コスト: 高い                合計コスト: 大幅に低い
  ロックイン: 強い                ロックイン: 弱い
  （他社製品への移行困難）        （ソースは公開されている）
```

このモデルが冒頭の私のエピソードに直結する。「何かあったときに電話できる相手がいる」——それがサブスクリプションの本質だ。ソフトウェアの価値ではなく、安心の価値に課金する。企業の購買プロセスにおいて「無料」は説明しにくいが、「年間サブスクリプション契約」は従来の調達プロセスにそのまま載る。

1999年8月11日、Red HatはIPOを果たし、初日の株価上昇率はウォール街史上8番目を記録した。1株14ドルで発行された株は、その日のうちに50ドルに達した。だがIPO時点では、オープンソースソフトウェアでの収益化は証明されていないモデルだった。それが2012年には年間売上10億ドルを突破する。オープンソース企業として初のマイルストーンだった。

2019年7月9日、IBMはRed Hatを約340億ドルで買収した。1株190ドル。2000年代初頭に「Linuxで大丈夫なのか」と問われていたOSの最大手ディストリビュータが、テック業界史上最大級の買収額で評価された。これは「無料のソフトウェア」のビジネスモデルがどこまで到達しうるかの証明だ。

### SUSEのエンタープライズ参入

Red HatだけがエンタープライズLinux市場を開拓したわけではない。2001年、SUSEは「SUSE Linux Enterprise Server 7」をリリースした。x86、Intel Itanium、IBM S/390メインフレームに対応し、特にIBMとの協力関係のもとでメインフレームLinuxの開発に貢献した。SUSEのエンジニアリングチームは、1999年からIBM Boeblingen Lab（ドイツ）およびMarist College（米国ニューヨーク州ポキプシー）と協力してS/390向けLinuxの開発に取り組んだ。

2003年11月、NovellがSUSE Linux AGを2億1000万ドルで買収した。Novellの意図は明確で、NetWareの後継としてLinuxを自社の中核に据えることだった。この買収により、SUSEはNovellの販売網とサポート体制を得て、特にヨーロッパとアジア市場でのエンタープライズLinux展開を加速させた。

---

## 3. Linuxが企業に選ばれた構造的要因

### 技術的要因——なぜLinuxは十分だったのか

LinuxがサーバOSとして企業に受け入れられた背景には、技術的成熟と市場構造の変化が同時に起きたという事情がある。まず技術的な要因を整理する。

**ハードウェア柔軟性。** 商用UNIXは、各ベンダー独自のプロセッサアーキテクチャに密結合していた。SolarisはSPARC、AIXはPOWER、HP-UXはPA-RISC。高性能だが高価であり、ベンダーロックインが避けられない。Linuxはx86を含む複数のアーキテクチャで動作する。x86サーバは競争が激しく、価格が急速に下落していた。Intel Xeonプロセッサの性能向上はめざましく、2000年代前半には多くのワークロードでRISCプロセッサと遜色ないパフォーマンスを発揮するようになった。

```
2000年代のサーバ市場の構図:

  商用UNIX + RISC               Linux + x86
  ┌─────────────────────┐      ┌─────────────────────┐
  │ Solaris + SPARC      │      │ RHEL + Intel Xeon    │
  │ AIX + POWER          │  →   │ SLES + AMD Opteron   │
  │ HP-UX + PA-RISC      │      │ 安価な汎用サーバ     │
  ├─────────────────────┤      ├─────────────────────┤
  │ 高性能・高信頼       │      │ 十分な性能・低コスト │
  │ 高価格               │      │ 競争による価格下落   │
  │ ベンダーロックイン   │      │ ハードウェア選択自由 │
  │ 専用ハードウェア     │      │ 汎用ハードウェア     │
  └─────────────────────┘      └─────────────────────┘
```

**カーネルの成熟。** Linux 2.4カーネル（2001年1月リリース）でSMP（対称型マルチプロセッシング）対応が大幅に改善された。続くLinux 2.6カーネル（2003年12月リリース）では、O(1)スケジューラの導入、NUMAサポート、大規模メモリ対応、エンタープライズファイルシステム（ext3、XFS、JFS、ReiserFS）のサポートが実現した。これにより、データベースサーバやアプリケーションサーバとして本番環境で使用するための技術的前提条件が揃った。

**ソフトウェアエコシステム。** OracleがLinux上でのOracle Database対応を表明したことは、決定的に重要だった。企業の基幹システムにおいて、データベースはOSよりも上位の選択基準だ。Oracle、IBM DB2、そしてMySQL/PostgreSQLといったデータベースがLinux上で安定稼働することが確認されたことで、OSの選択肢としてLinuxが現実的になった。同様に、IBM WebSphere、BEA WebLogicなどのアプリケーションサーバもLinux対応を進めた。

### コスト要因——TCOの議論

「Linuxは無料だからコストが安い」という主張は、半分正しく半分間違っている。

ソフトウェアライセンス費用はゼロだが、それは総所有コスト（TCO: Total Cost of Ownership）の一部にすぎない。TCOにはハードウェア費用、導入費用、運用管理の人件費、トレーニング費用、ダウンタイムのコスト、セキュリティ対策費用が含まれる。

2003年、Microsoftは「Get the Facts」キャンペーンを展開した。IDCに委託した調査で、一般的な企業タスク5種類のうち4種類でWindows 2000のTCOがLinuxより低いと主張した。ただしWebサーバ用途ではLinuxが優位とも認めていた。Microsoftが調査を資金提供していた事実が明らかになり、結果の中立性には疑問が呈された。

TCO議論の本質は、何をコストに含めるかで結論が変わるということだ。Windowsの管理はGUIベースで直感的だが、大量のサーバを管理するにはスクリプトが必要になる。Linuxの管理はCLIベースでスクリプト化しやすいが、管理者のスキルセットが異なる。サーバ10台までならWindowsのほうがTCOが低いかもしれないが、100台を超えるとLinuxのスクリプタブルな管理体制が有利になる。

そしてここにUNIXの設計哲学の影響がある。Linuxのシステム管理は、テキストファイルベースの設定、シェルスクリプトによる自動化、パイプとフィルタによるログ解析——すべてがUNIXの原則に立脚している。この管理体制は、サーバの台数が増えるほどスケールする。`for server in $(cat server_list.txt); do ssh $server 'systemctl restart httpd'; done` ——このワンライナーで100台のサーバのApacheを再起動できる。GUIクリックで100台を管理する苦行とは対照的だ。

### スケールアウトの思想——GoogleとAmazonの選択

Linuxのサーバ市場支配を決定づけたのは、Web企業のインフラストラクチャ設計だった。

Googleは1998年の創業時から、商用UNIXサーバやハイエンドストレージを使わないという選択をした。代わりに、安価なx86サーバにLinuxを載せ、大量に並べた。初期のGoogleサーバは合板のプラットフォームにマザーボードとハードディスクを載せた自作品で、ラックマウントサーバですらなかった。カスタムLinuxベースのWebサーバ（GWS: Google Web Server）を自社開発し、巨大なクラスタを構築した。

この設計思想の核心は、「個々のサーバは壊れることを前提とする」ことだ。高価なハードウェアの信頼性に依存するのではなく、ソフトウェアレベルで冗長性と耐障害性を実現する。安いサーバが1台壊れても、残りのサーバが処理を引き継ぐ。この「スケールアウト」の設計は、商用UNIXの「スケールアップ」（より高性能なサーバに置き換える）とは根本的に異なるアプローチだった。

```
スケールアップ vs スケールアウト:

  スケールアップ（商用UNIX）        スケールアウト（Linux + x86）
  ┌─────────────────────────┐    ┌──┬──┬──┬──┬──┬──┬──┬──┐
  │                           │    │  │  │  │  │  │  │  │  │
  │    大型の高価なサーバ      │    │  │  │  │  │  │  │  │  │
  │    1台で全処理を担う      │    │  │  │  │  │  │  │  │  │
  │                           │    │  │  │  │  │  │  │  │  │
  │   SPARC / POWER           │    └──┴──┴──┴──┴──┴──┴──┴──┘
  │   高信頼ハードウェア      │    安価なx86サーバを大量に並べる
  │   障害 = 重大インシデント │    1台の障害 = 日常的なイベント
  └─────────────────────────┘    ソフトウェアで冗長性を確保
```

Linuxはこのスケールアウト設計に完璧にフィットした。無料だからサーバの台数に比例するライセンスコストがない。軽量だから最小限のリソースでも動作する。オープンソースだからカーネルレベルでカスタマイズできる。Googleは自社のワークロードに最適化したLinuxカーネルを使い、不要な機能を削ぎ落とし、自社のファイルシステム（GFS: Google File System）やジョブスケジューラを統合した。

2006年、Amazon Web Servicesが開始された。3月14日にS3（ストレージサービス）、8月25日にEC2（仮想サーバサービス）のベータ版を公開した。EC2はXenベースの仮想化基盤上でLinux仮想マシンを提供した。初期のEC2は1種類のインスタンスタイプと1リージョン（US East）、Linux専用だった。Windows対応は2008年10月まで待たなければならなかった。

AWSの登場は、Linuxサーバ市場のダイナミクスを根本的に変えた。企業はもはや自社でサーバを調達する必要がない。「サーバを借りる」時代が始まり、その借りるサーバのデフォルトがLinuxだった。クラウドコンピューティングの普及により、LinuxはサーバOSの「デフォルト選択」の地位を確立していく。

### 逆風と試練——SCO訴訟とFUD

Linux のサーバ市場進出は、順風満帆ではなかった。

2003年3月6日、SCO Group（旧Caldera International）がIBMを提訴した。LinuxにUNIXの知的財産が不正にコピーされたと主張し、当初10億ドル、後に50億ドルの損害賠償を請求した。SCOはさらに、Linuxを商用利用する企業に対してもライセンス料を求める姿勢を見せた。

この訴訟はLinux陣営にとって深刻なFUD（Fear, Uncertainty, Doubt）として機能した。企業の法務部門は「Linuxを使うと訴えられるかもしれない」という懸念を持った。MicrosoftのSteve BallmerがLinuxを「知的財産に対する癌（cancer）」と呼んだ発言（2001年）も、この文脈で繰り返し引用された。

だが結果は、Linuxの正当性を確認する方向に転んだ。訴訟は長期化し、SCO側の主張は次々と退けられた。2007年9月にSCOは破産申請。2010年のSCO対Novell訴訟では、UNIX著作権はNovellに帰属するという陪審評決が下された。2016年3月、SCO対IBMの訴訟は棄却され、2021年にIBMが破産管財人に1,425万ドルを支払って最終的に和解した。当初50億ドルを請求した訴訟の結末としては象徴的だ。

SCO訴訟の皮肉は、Linuxを脅かすはずだった訴訟が、結果的にLinuxの法的リスクの低さを証明したことだ。FUDは一時的に企業の採用を躊躇させたが、判決が出るにつれてLinuxの法的地位は明確になっていった。IBMがSCO訴訟で全力で反論したことも、企業にとっての安心材料となった。

---

## 4. エンタープライズLinuxの生態系

### CentOS——無料のRHEL互換が生んだ巨大な生態系

RHELのサブスクリプションモデルは商業的に成功したが、すべての組織がサブスクリプション費用を支払えるわけではない。ここでRHELのソースコードがGPLで公開されている事実が重要になる。

CentOSは、RHELのソースコードからRed Hatの商標を除去して再コンパイルした、バイナリ互換のディストリビューションだった。つまり、RHEL用に認定されたソフトウェアがそのまま動作し、RHELと同一のセキュリティパッチが適用される。サブスクリプション費用はゼロだが、サポート窓口もない。

CentOSの存在は、RHELの生態系を劇的に拡大した。大学、研究機関、中小企業、そして大企業の開発環境——サポート契約が必要ない場面でCentOSが使われ、本番環境でRHELが使われるというパターンが定着した。CentOSで動作確認されたソフトウェアはRHELでも動く。この互換性の輪が、RHELのエコシステムを強化した。

2014年1月、Red HatはCentOSプロジェクトを吸収し、公式にスポンサーとなった。これは競合を排除するためではなく、エコシステムの一部として取り込む戦略だった——少なくとも当時はそう理解された。

だが2020年末、Red HatはCentOS Linuxの終了を発表した。CentOS 8は当初2029年までサポートされる予定だったが、EOLが2021年12月31日に前倒しされた。CentOS Streamという「RHELの次期バージョンの開発ブランチ」に移行するという方針だ。安定したRHEL互換OSとしてのCentOSは消滅することになった。

この決定はエンタープライズLinuxコミュニティに激震をもたらした。CentOSに依存していた無数の組織が、突如として移行先を探す必要に迫られた。

反応は速かった。CloudLinuxが2021年3月にAlmaLinuxの初版をリリースした。CentOS共同創設者のGregory Kurtzerは、Rocky Linux（共同創設者の故Rocky McGaughに因む命名）を立ち上げた。いずれもRHELの1:1バイナリ互換を目指すディストリビューションだ。

2023年6月には、Red HatがRHELのソースコードへのアクセスをさらに制限する措置を取り、論争は新たな段階に入った。だがAlmaLinuxとRocky Linuxは、それぞれ異なるアプローチで互換性の維持を続けている。AWS、Google Cloud、Microsoft Azureのすべてが両者の公式イメージを提供しており、エンタープライズグレードの代替として認知されている。

この一連の出来事は、オープンソースのビジネスモデルの緊張関係を浮き彫りにしている。ソースコードが公開されている以上、クローンは常に作れる。だがサポートとエコシステムの構築には膨大な投資が必要だ。Red Hatの葛藤は、「ソフトウェアは無料、サポートは有料」モデルの構造的な課題を示している。

### Oracle Unbreakable Linux——RHELクローンのもう一つの系譜

2006年10月、OracleはRHELのクローンを「Unbreakable Linux」として発表した。年間99ドル/システムからという価格で、Red Hatのサブスクリプション費用を大幅に下回る設定だった。同年4月にRed HatがJBossを買収してOracle のアプリケーションサーバ市場を脅かしたことへの対抗措置と見られた。

Red Hatは「Unfakeable Linux」というカウンターキャンペーンで応酬した。Oracle Linuxは現在も存続しているが、市場シェアは限定的だ。Oracle自身のクラウドサービス（OCI）ではOracle Linuxが推奨されるが、他のクラウドプラットフォームでの採用は少ない。この事実は、ディストリビューションの価値がソフトウェア自体ではなくエコシステムとサポートにあることを裏付けている。

### Ubuntu Server——クラウド時代のもう一つの選択肢

エンタープライズLinux市場の構図は、2010年代にUbuntu Serverの台頭で変化した。

Canonicalは2006年6月にUbuntu 6.06 LTS（Dapper Drake）をリリースし、初めてサーバ向けの長期サポートを提供した。2007年にはグローバルパートナープログラムを開始し、エンタープライズ市場への参入を本格化させた。

Ubuntu Serverが急速にシェアを拡大した要因はクラウドとの親和性にある。AWSのEC2でUbuntuは最も人気のあるAMI（Amazon Machine Image）の一つとなり、OpenStack（2010年以降）との密接な統合により、プライベートクラウド構築でも存在感を示した。

RHELが「既存の企業ITインフラのLinux化」を主導したのに対し、Ubuntuは「クラウドネイティブなLinux環境」として独自のポジションを確立した。2020年代半ばの統計では、RHELがエンタープライズLinuxサーバの約43%を占める一方、Ubuntuは汎用デプロイメントで約34%のシェアを持つ。

```
エンタープライズLinuxの勢力図（2020年代）:

  ┌──────────────────────────────────────────────────┐
  │ エンタープライズLinux市場                          │
  │                                                    │
  │  ┌─────────────┐ ┌─────────────┐ ┌────────────┐  │
  │  │ RHEL系       │ │ Ubuntu      │ │ SLES       │  │
  │  │ (≈43%)       │ │ (≈34%)      │ │ (その他)   │  │
  │  │              │ │             │ │            │  │
  │  │ RHEL         │ │ Ubuntu      │ │ SUSE       │  │
  │  │ AlmaLinux    │ │ Server      │ │ Linux      │  │
  │  │ Rocky Linux  │ │ LTS         │ │ Enterprise │  │
  │  │ Oracle Linux │ │             │ │ Server     │  │
  │  └─────────────┘ └─────────────┘ └────────────┘  │
  │                                                    │
  │  用途: 金融・製造     クラウド・Web     SAP・HPC    │
  │        基幹システム   スタートアップ    ヨーロッパ  │
  └──────────────────────────────────────────────────┘
```

### 数字が語るLinux支配

2020年代半ばの統計は、Linuxのサーバ市場支配の度合いを雄弁に物語る。

クラウドプロバイダ（AWS、Google Cloud、Microsoft Azure）の仮想マシンの92%がLinux上で稼働している。TOP500スーパーコンピュータは2017年11月以降、100%がLinuxだ。WebサーバとしてはLinuxが約60%のシェアを持つ。

特に注目すべきは、Microsoftが自社のクラウドプラットフォームAzure上でLinuxの仮想マシンを積極的に提供しているという事実だ。かつて「Get the Facts」キャンペーンでLinuxを攻撃していたMicrosoftが、2020年代にはLinuxをAzure上の主要OSとして扱っている。この転換は、サーバOS市場におけるLinuxの地位がいかに揺るぎないものになったかを示している。

---

## 5. ハンズオン：エンタープライズLinuxの運用管理を体験する

このハンズオンでは、RHEL互換環境でエンタープライズLinuxの基本的な運用管理を体験する。systemctl、firewalld、そしてLinuxサーバの監視・管理の基本を実際に手を動かして学ぶ。

### 環境構築

Docker環境で、RHEL互換のAlmaLinux/Rocky Linuxを使用する。

```bash
# AlmaLinux 9（RHEL 9互換）のイメージを取得
docker pull almalinux:9
```

### 演習1：エンタープライズLinuxの基本情報を確認する

まず、RHEL互換ディストリビューションの基本的な情報を確認する。

```bash
docker run --rm almalinux:9 sh -c '
echo "=== OS情報 ==="
cat /etc/os-release
echo ""
echo "=== カーネルバージョン ==="
uname -r
echo ""
echo "=== RPMパッケージ数 ==="
rpm -qa | wc -l
echo ""
echo "=== インストール済みの主要パッケージ ==="
rpm -qa --qf "%{NAME}\n" | sort | head -20
'
```

AlmaLinuxがRHEL互換であることを確認してほしい。`/etc/os-release` にはAlmaLinuxの情報が表示されるが、RPMパッケージの構成はRHELと同一だ。

### 演習2：systemctlによるサービス管理

systemdはRHEL 7以降のサービス管理の中核だ。ここではsystemctlの基本操作を体験する。

```bash
docker run --privileged --rm -it almalinux:9 bash -c '
# systemdが利用可能な環境を構築
dnf install -y httpd procps-ng 2>/dev/null | tail -5
echo ""

echo "=== サービスの一覧（一部） ==="
systemctl list-unit-files --type=service 2>/dev/null | head -15 || \
  echo "(コンテナ環境ではsystemdが制限される場合がある)"
echo ""

echo "=== httpdのユニットファイル ==="
cat /usr/lib/systemd/system/httpd.service
echo ""

echo "=== ユニットファイルの構造解説 ==="
echo "[Unit] セクション: 依存関係を定義"
echo "[Service] セクション: 実行方法を定義"
echo "[Install] セクション: 有効化時の動作を定義"
echo ""

echo "=== SysV initスクリプトとの比較 ==="
echo "SysV init: /etc/init.d/httpd start (シェルスクリプト)"
echo "systemd:   systemctl start httpd   (ユニットファイル)"
echo ""
echo "SysV initスクリプトは数十〜数百行のシェルスクリプトだった。"
echo "systemdのユニットファイルは宣言的な設定ファイルだ。"
echo "手続き的（どうやるか）→ 宣言的（何をしたいか）への転換。"
'
```

ここで注目すべきは、systemdのユニットファイルがINI風の宣言的設定であることだ。SysV initの時代、サービスの起動・停止はシェルスクリプトで手続き的に記述されていた。systemdは「このサービスはこのバイナリを実行し、この条件で再起動する」という宣言的な記述に変えた。

### 演習3：RPMパッケージの管理とリポジトリ

エンタープライズLinuxの運用で最も重要な操作の一つが、パッケージの管理だ。

```bash
docker run --rm almalinux:9 sh -c '
echo "=== DNFリポジトリの確認 ==="
dnf repolist
echo ""

echo "=== パッケージの検索 ==="
dnf search httpd 2>/dev/null | head -10
echo ""

echo "=== パッケージの詳細情報 ==="
dnf info bash 2>/dev/null
echo ""

echo "=== セキュリティアップデートの確認 ==="
dnf updateinfo list --security 2>/dev/null | head -10 || \
  echo "(セキュリティアドバイザリ情報は接続環境による)"
echo ""

echo "=== パッケージグループの一覧 ==="
dnf group list 2>/dev/null | head -15
echo ""

echo "=== RPMの検証（改ざん検出） ==="
rpm -V bash 2>/dev/null
echo "(出力がなければ改ざんなし)"
'
```

`dnf updateinfo list --security` は、セキュリティ関連のアップデートだけを表示する。エンタープライズ環境では、すべてのパッケージを最新にすることよりも、セキュリティパッチだけを選択的に適用することが多い。安定性とセキュリティのバランスを取るための機能だ。

`rpm -V` はインストール済みパッケージのファイルが改ざんされていないかを検証する。ファイルのサイズ、パーミッション、チェックサムを、RPMデータベースに記録された情報と比較する。セキュリティ監査の基本的な手段だ。

### 演習4：ログ管理とjournalctl

エンタープライズLinuxの運用管理において、ログの確認は日常的な作業だ。

```bash
docker run --rm almalinux:9 sh -c '
echo "=== journalctlの基本操作 ==="
echo "(コンテナ環境ではjournaldが制限される場合がある)"
echo ""

echo "=== 従来のログファイル ==="
ls -la /var/log/ 2>/dev/null
echo ""

echo "=== /var/log/dnf.log の確認 ==="
cat /var/log/dnf.log 2>/dev/null | head -10 || echo "(ログなし)"
echo ""

echo "=== journalctl vs 従来のsyslog ==="
echo ""
echo "従来のログ管理:"
echo "  /var/log/messages   -- システムメッセージ"
echo "  /var/log/secure     -- 認証ログ"
echo "  /var/log/httpd/     -- Apacheのログ"
echo "  テキストファイル。grep/awk/sedで検索・解析。"
echo ""
echo "journalctlのログ管理:"
echo "  journalctl -u httpd     -- 特定サービスのログ"
echo "  journalctl --since today -- 今日のログ"
echo "  journalctl -p err        -- エラー以上のログ"
echo "  構造化されたバイナリログ。メタデータで検索可能。"
echo ""
echo "UNIXのテキストストリーム原則 vs systemdの構造化ログ。"
echo "この設計判断の是非は、第17回で詳しく論じる。"
'
```

### 演習5：RHEL系とDebian系の運用管理の違い

同じタスクをRHEL系とDebian系で実行し、エンタープライズLinuxの運用管理の違いを体感する。

```bash
# RHEL系（AlmaLinux）
echo "=== RHEL系（AlmaLinux 9） ==="
docker run --rm almalinux:9 sh -c '
echo "--- パッケージインストール ---"
echo "dnf install -y nginx"
echo ""
echo "--- サービス管理 ---"
echo "systemctl start nginx"
echo "systemctl enable nginx"
echo "systemctl status nginx"
echo ""
echo "--- ファイアウォール ---"
echo "firewall-cmd --add-service=http --permanent"
echo "firewall-cmd --reload"
echo ""
echo "--- SELinux ---"
echo "getenforce"
echo "setsebool -P httpd_can_network_connect on"
echo ""
echo "--- セキュリティアップデート ---"
echo "dnf update --security"
echo ""
echo "--- パッケージ検証 ---"
echo "rpm -Va"
'

echo ""
echo "=========================================="
echo ""

# Debian系（Ubuntu Server）
echo "=== Debian系（Ubuntu） ==="
docker run --rm ubuntu:24.04 sh -c '
echo "--- パッケージインストール ---"
echo "apt update && apt install -y nginx"
echo ""
echo "--- サービス管理 ---"
echo "systemctl start nginx"
echo "systemctl enable nginx"
echo "systemctl status nginx"
echo ""
echo "--- ファイアウォール ---"
echo "ufw allow http"
echo "ufw enable"
echo ""
echo "--- AppArmor ---"
echo "aa-status"
echo "aa-enforce /etc/apparmor.d/usr.sbin.nginx"
echo ""
echo "--- セキュリティアップデート ---"
echo "apt update && apt upgrade"
echo ""
echo "--- パッケージ検証 ---"
echo "debsums --changed"
'
```

同じLinuxでありながら、運用管理の「手触り」が異なることがわかるだろう。ファイアウォールはRHEL系がfirewalld、Debian系がufw。強制アクセス制御はRHEL系がSELinux、Debian系がAppArmor。パッケージ管理はdnfとapt。だが根底にあるのは同じLinuxカーネルであり、同じUNIXの原則だ。

この違いは、前回論じたディストリビューションの「選択の束」の企業向けの表現だ。Red Hatは「セキュリティと安定性を重視する企業」向けに、SELinuxをデフォルト有効にし、長期サポートを保証し、認定ハードウェアのリストを提供する。Ubuntuは「クラウドとDevOps」向けに、軽量で迅速なデプロイメントを可能にし、最新のソフトウェアを素早く取り込む。

---

## 6. まとめと次回予告

### この回の要点

LinuxのサーバOS市場支配は、単一の要因によるものではない。技術的成熟、ビジネスモデルの革新、市場構造の変化、そして時に敵対者の失策が複合的に作用した結果だ。

1990年代末のdotcomブームで、LAMPスタック（Linux、Apache、MySQL、PHP/Perl）がWebインフラの事実上の標準となった。コスト優位性が最初の推進力だった。

2000年12月のIBMの10億ドル投資宣言が、Linuxの「企業利用の正当性」を確立した。技術そのものではなく、IBMという名前がLinux採用のリスクを下げた。1999年末に公開されたS/390メインフレーム向けLinuxは、最も保守的な領域でのLinux浸透の始まりだった。

Red Hatのサブスクリプションモデル（2002年〜）が、「無料のソフトウェアで商売する」方法を確立した。ソフトウェアではなくサポートに課金する。この革新がなければ、企業のLinux採用はここまで進まなかった。Red Hatは1999年のIPOから2019年のIBMによる340億ドルでの買収まで、オープンソースビジネスの到達点を示した。

GoogleとAmazonに代表されるWeb企業が、「安価なx86サーバ + Linux」によるスケールアウト型インフラを確立した。商用UNIXの「高価なハードウェアでスケールアップ」というモデルに対する、根本的に異なる設計思想だった。2006年のAWS開始により、LinuxはクラウドコンピューティングのデフォルトOSとなった。

SCO訴訟（2003年〜2021年）やMicrosoftの「Get the Facts」キャンペーン（2003年〜2007年）といった逆風は、一時的にFUDを拡散したが、結果的にLinuxの法的・商業的正当性を確認する形で決着した。

### 冒頭の問いへの暫定回答

「『無料のOS』が『企業の基幹システム』に使われるようになったのはなぜか。」

無料だから選ばれたのではない。無料であることは初期の推進力になったが、企業がLinuxを選んだ真の理由は以下の三つだ。

第一に、ハードウェアの自由。商用UNIXがベンダー独自のプロセッサに依存していたのに対し、Linuxは競争が激しく価格が下落するx86サーバで動作した。ハードウェアの選択自由は、調達コストの削減と交渉力の確保をもたらした。

第二に、ビジネスモデルの革新。Red Hatのサブスクリプションモデルが、「無料のソフトウェア」を企業の購買プロセスに載せる方法を確立した。ソフトウェアライセンスではなくサポート契約として購入する——この形式転換が、企業の意思決定の障壁を取り除いた。

第三に、スケールアウトの設計思想との適合。GoogleやAmazonが実証した「安価なサーバを大量に並べる」アーキテクチャにおいて、サーバ台数に比例するライセンスコストがゼロであることの価値は絶大だった。

つまりLinuxのサーバ市場支配は、技術的優位性とビジネスモデルの革新が同時に起きた結果だ。そしてその根底には、UNIXの設計哲学——テキストベースの設定、スクリプタブルな管理、パイプとフィルタによるデータ処理——が、大規模サーバ運用に本質的に適していたという事実がある。

### 次回予告

次回は「Linuxカーネル開発モデル——"大聖堂"と"バザール"の実態」。世界最大のオープンソースプロジェクトは、どのように統治されているのか。Eric Raymondが「The Cathedral and the Bazaar」（1997年）で描いたオープンソース開発の理想と、Linuxカーネル開発の現実の間には、どのような距離があるのか。メーリングリスト、パッチレビュー、サブシステムメンテナの階層構造——そしてLinus Torvaldsの率直な（ときに辛辣な）コードレビューが、どのようにして品質を維持しているのか。

あなたが関わっているプロジェクトの開発プロセスは、「大聖堂」型だろうか。それとも「バザール」型だろうか。

---

## 参考文献

- CNN Money, "IBM to spend $1B on Linux", Dec. 12, 2000: <https://money.cnn.com/2000/12/12/technology/ibm_linux/>
- HPC Wire, "IBM: Linux Investment Nearly Recouped", Feb. 1, 2002: <https://www.hpcwire.com/2002/02/01/ibm-linux-investment-nearly-recouped/>
- eWEEK, "IBM's Linux Investment: A Look at Years of Commitment": <https://www.eweek.com/enterprise-apps/ibm-s-linux-investment-a-look-at-years-of-commitment/>
- Red Hat, "RHELvolution: A brief history of Red Hat Enterprise Linux releases from early days to RHEL 5": <https://www.redhat.com/en/blog/rhelvolution-brief-history-red-hat-enterprise-linux-releases-early-days-rhel-5>
- Red Hat, "Red Hat Celebrates 10 Years of Red Hat Enterprise Linux": <https://www.redhat.com/en/about/press-releases/red-hat-celebrates-ten-years-of-red-hat-enterprise-linux>
- Red Hat Customer Portal, "Red Hat Enterprise Linux Release Dates": <https://access.redhat.com/articles/red-hat-enterprise-linux-release-dates>
- CNBC, "IBM closes its $34 billion acquisition of Red Hat": <https://www.cnbc.com/2019/07/09/ibm-closes-its-34-billion-acquisition-of-red-hat.html>
- Wikipedia, "Red Hat": <https://en.wikipedia.org/wiki/Red_Hat>
- Wikipedia, "LAMP (software bundle)": <https://en.wikipedia.org/wiki/LAMP_(software_bundle)>
- Wikipedia, "Amazon Elastic Compute Cloud": <https://en.wikipedia.org/wiki/Amazon_Elastic_Compute_Cloud>
- AWS, "Happy 15th Birthday Amazon EC2": <https://aws.amazon.com/blogs/aws/happy-15th-birthday-amazon-ec2/>
- Wikipedia, "Google data centers": <https://en.wikipedia.org/wiki/Google_data_centers>
- Data Center Knowledge, "Google Servers circa 1999": <https://www.datacenterknowledge.com/archives/2007/03/14/google-servers-circa-1999>
- Wikipedia, "SCO Group, Inc. v. International Business Machines Corp.": <https://en.wikipedia.org/wiki/SCO_Group,_Inc._v._International_Business_Machines_Corp.>
- LWN.net, "The facts behind Microsoft's 'Get the Facts' campaign": <https://lwn.net/Articles/315627/>
- Wikipedia, "SUSE Linux Enterprise": <https://en.wikipedia.org/wiki/SUSE_Linux_Enterprise>
- SUSE, "Novell Completes Acquisition of SUSE Linux": <https://www.suse.com/news/novell_closing/>
- Wikipedia, "Oracle Linux": <https://en.wikipedia.org/wiki/Oracle_Linux>
- Linux Journal, "Rising from the Ashes: How AlmaLinux and Rocky Linux Redefined the Post-CentOS Landscape": <https://www.linuxjournal.com/content/rising-ashes-how-almalinux-and-rocky-linux-redefined-post-centos-landscape>
- Wikipedia, "Linux on IBM Z": <https://en.wikipedia.org/wiki/Linux_on_IBM_Z>
- eWEEK, "10th Anniversary of Linux for the Mainframe: Beginning to Today": <https://www.eweek.com/servers/10th-anniversary-of-linux-for-the-mainframe-beginning-to-today/>
- Command Linux, "Linux Server Market Share (2026)": <https://commandlinux.com/statistics/linux-server-market-share/>
- SQ Magazine, "Linux Statistics 2025: Desktop, Server, Cloud & Community Trends": <https://sqmagazine.co.uk/linux-statistics/>
