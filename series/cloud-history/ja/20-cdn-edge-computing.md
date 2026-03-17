# クラウドの考古学

## ——メインフレームからサーバーレスへ、計算資源の民主化史

### 第20回：CDN、エッジコンピューティング——計算を「ユーザーの近く」に持っていく

**連載「クラウドの考古学——メインフレームからサーバーレスへ、計算資源の民主化史」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- CDNの起源——Tim Berners-Leeの1995年の課題とAkamai Technologies（1998年設立）の誕生
- CDNの基本原理——キャッシュ、PoP（Point of Presence）、オリジンシールドの仕組み
- メインフレーム集中型→クライアント/サーバ分散→クラウド再集中→エッジ分散という「計算の振り子」の構造
- Cloudflare Workers（2017年）が採用したV8 Isolatesモデルの技術的革新
- AWS Lambda@Edge（2016年プレビュー、2017年GA）のCloudFront統合型アプローチ
- Fastly Compute@Edge（2019年）のWebAssemblyベースの設計判断
- Deno Deploy（2021年）、Vercel Edge Functions（2022年）によるエッジの民主化
- エッジにおける状態管理の課題——Workers KV、Durable Objects、D1の系譜
- WinterCG/WinterTC（2022年〜）によるエッジランタイム間の標準化の動き

---

## 1. レイテンシーという物理法則

2019年のある日、私はCloudflare Workersに初めてエッジ関数をデプロイした。

それまで、あるAPIは東京リージョンのEC2インスタンスで動いていた。日本国内のユーザーには問題ない。だが、ヨーロッパやアメリカ西海岸からのリクエストには200ミリ秒以上のレイテンシーが乗る。光の速度は秒速約30万キロメートル。東京からフランクフルトまで約9,000キロメートル。光ファイバーの中を信号が往復するだけで60ミリ秒かかる。プロトコルのオーバーヘッド、ルーティングの迂回、TLSハンドシェイク——実際のレイテンシーはその数倍になる。

物理法則は交渉できない。

Cloudflare Workersにデプロイし直すと、同じAPIが世界中のエッジロケーションで動き始めた。フランクフルトのユーザーにはフランクフルトのエッジが応答し、サンフランシスコのユーザーにはサンフランシスコのエッジが応答する。レイテンシーは劇的に下がった。200ミリ秒が20ミリ秒になった。

だが、この体験は私に一つの問いを投げかけた。

私たちは今、「計算する場所」の移動を再び経験している。メインフレームの集中処理から始まり、クライアント/サーバモデルで計算が分散し、クラウドで再び集中した。そして今、エッジコンピューティングが計算を再びユーザーの近くに分散させようとしている。この振り子運動は偶然ではない。そこには、時代ごとの技術的制約と経済的合理性が作用している。

なぜ「計算する場所」は揺れ動くのか。そしてエッジコンピューティングは、この振り子の終着点なのか、それとも次の揺り戻しの始まりなのか。

---

## 2. CDNの誕生——「コンテンツをユーザーの近くに置く」という発想

### Tim Berners-Leeの課題（1995年）

CDN（Content Delivery Network）の歴史は、Web自体の苦悩から始まる。

1990年代半ば、World Wide Webは爆発的に成長していた。だが同時に「World Wide Wait（世界規模の待ち時間）」という皮肉な呼び名がつくほど、Webは遅かった。ユーザーの増加にサーバーとネットワークの能力が追いつかない。人気のあるWebサイトにアクセスが集中すると、サーバーは応答不能に陥る。ネットワークの特定のリンクに負荷が集中し、輻輳が起きる。

1995年初頭、World Wide Webの発明者Tim Berners-LeeはMITの同僚たちに一つの課題を投げかけた。「インターネットコンテンツの配信を根本的に改善する新しい方法を発明せよ」。

この課題に応えたのが、MIT応用数学教授のTom Leightonだった。Leightonはアルゴリズム研究の第一人者であり、MIT計算機科学研究所のアルゴリズムグループを率いていた。Leightonは、Web配信の問題が本質的に応用数学とアルゴリズムの問題であると見抜いた。

大学院生のDanny Lewinとともに、Leightonは分散サーバーネットワーク上にコンテンツを知的に複製・配信するためのアルゴリズムを開発した。ユーザーのリクエストを、コンテンツのコピーを持つ最も近いサーバーに誘導する。どのサーバーにどのコンテンツを配置するかを動的に最適化する。障害が発生したサーバーを自動的に迂回する。

1997年9月、LeightonとLewinはMIT $50K Entrepreneurship Competitionに参加した。そして1998年8月20日、Akamai Technologiesが法人化された。社名の「Akamai」はハワイ語で「賢い」を意味する。

### Akamaiの商用化——CDNの原型

Akamaiの商用サービスが本格的に動き始めたのは1999年だ。

1999年2月、AkamaiはDisneyのWebサイトに埋め込まれたピクセルを通じて初のライブトラフィックを配信した。目に見えない1ピクセルの画像だが、これがCDNの商用配信の始まりだった。

翌月、Akamaiの真価が試される事態が発生した。ESPNのMarch Madness（全米大学バスケットボールトーナメント）のストリーミング配信と、Entertainment TonightのStar Wars新作予告編の公開。いずれも歴史的なアクセス集中が予想されるイベントだった。Akamaiの分散配信ネットワークは、このトラフィックの波を捌ききった。単一のオリジンサーバーでは到底対応できない負荷を、世界中に分散されたエッジサーバーが吸収したのだ。

1999年4月に商用サービスが正式に開始され、同年10月29日にNASDAQに上場した。

CDNの基本原理は、驚くほどシンプルだ。

```
CDNの基本原理:

  従来のアーキテクチャ（CDNなし）:

  ユーザー（東京）─────────── 9,000km ──────────→ オリジンサーバー
  ユーザー（ロンドン）──────── 数百km ──────────→ （フランクフルト）
  ユーザー（NY）────────────── 6,000km ──────────→

  問題: 全リクエストがオリジンに集中
       遠距離のユーザーは高レイテンシー
       オリジン障害 = 全ユーザーに影響

  CDNを導入したアーキテクチャ:

  ユーザー（東京）───→ PoP（東京）──┐
                       キャッシュHIT → 即座に応答
                                     │
  ユーザー（ロンドン）→ PoP（ロンドン）──┐
                       キャッシュHIT → 即座に応答
                                        │
  ユーザー（NY）────→ PoP（NY）──┐      │
                     キャッシュMISS     │
                         │              │
                         └──→ オリジンサーバー
                              （必要なときだけ）

  PoP = Point of Presence（エッジサーバーの設置拠点）
```

**PoP（Point of Presence）。** CDN事業者が世界各地に設置するエッジサーバーの拠点だ。Akamaiは2020年代に入り、世界130か国以上、4,000以上のPoPを運用している。ユーザーのリクエストはDNSの仕組みを使って最も近いPoPに誘導される。

**キャッシュ。** PoPに配置されたエッジサーバーは、オリジンサーバーから取得したコンテンツのコピーを保持する。同じコンテンツへのリクエストが来たら、オリジンに問い合わせずにエッジから直接応答する。これがキャッシュヒットだ。キャッシュに存在しないコンテンツへのリクエスト（キャッシュミス）だけがオリジンに到達する。

**オリジンシールド。** CDNの進化とともに、PoPとオリジンサーバーの間にもう一つの層が追加された。複数のPoPからオリジンへのリクエストが集中するのを防ぐため、中間層のキャッシュ（オリジンシールド）を設置する。PoPがキャッシュミスを起こしても、オリジンシールドにキャッシュがあればオリジンへの到達を防げる。

```
オリジンシールドの構造:

  PoP（東京）──────┐
                    │
  PoP（大阪）──────┤
                    ├──→ オリジンシールド ──→ オリジンサーバー
  PoP（ソウル）────┤     （アジア太平洋）
                    │
  PoP（シンガポール）┘

  PoP（ロンドン）──┐
                    │
  PoP（パリ）──────┼──→ オリジンシールド ──→ オリジンサーバー
                    │     （ヨーロッパ）
  PoP（フランクフルト）┘

  効果: オリジンサーバーへのリクエストを大幅に削減
        オリジンの負荷を軽減し、障害リスクを低減
```

### CDNの限界——「静的コンテンツ」の壁

Akamaiが確立したCDNの仕組みは、画像、CSS、JavaScript、動画といった静的コンテンツの配信において革命的だった。世界中のユーザーに高速にコンテンツを届けるという問題を、エレガントに解決した。

だが、CDNには根本的な制約があった。**CDNはコンテンツを「配る」ことはできるが、コンテンツを「作る」ことはできない。**

ユーザーごとにパーソナライズされたページ、リアルタイムのAPI応答、認証処理——これらの動的なコンテンツは、キャッシュが効かない。リクエストごとに異なる結果を返す必要があるからだ。動的コンテンツの処理は、依然としてオリジンサーバー——つまりクラウドのリージョンにあるサーバー——で行わなければならなかった。

```
CDNの限界:

  静的コンテンツ（画像、CSS、JS）:
  ユーザー → PoP → キャッシュHIT → 即座に応答  ✓ 高速

  動的コンテンツ（API、パーソナライズ）:
  ユーザー → PoP → キャッシュ不可 → オリジンサーバー → 応答
                                     ^^^^^^^^^^^^
                                     ここが遠い = レイテンシー
```

この制約が、CDNの次の進化——エッジコンピューティング——を呼び込む動機となった。コンテンツを配るだけでなく、**エッジで計算そのものを実行する**。それができれば、動的コンテンツすらユーザーの近くで生成できる。

---

## 3. 計算の振り子——集中と分散の70年史

エッジコンピューティングの技術論に入る前に、「計算する場所」の歴史的な揺れ動きを整理しておきたい。この振り子運動を理解することが、エッジコンピューティングの本質を掴む鍵だ。

```
計算の振り子——70年の変遷:

  集中                                             分散
  ◄──────────────────────────────────────────────────►

  1960年代  メインフレーム（集中）
            │ 全てが一台の大型計算機に集中
            │ 端末はダム端末（表示のみ）
            │
  1980年代  │              PC + クライアント/サーバ（分散）
            │              │ 計算力がデスクトップに移動
            │              │ ファットクライアントの時代
            │              │
  2000年代  │  Webアプリケーション（やや集中）
            │  │ ブラウザ = シンクライアント化
            │  │ サーバサイドレンダリング
            │  │
  2010年代  クラウド（集中）
            │ 巨大データセンターに計算が集約
            │ AWS/GCP/Azure のリージョン
            │ SaaS + API経済
            │
  2020年代  │              エッジコンピューティング（分散）
            │              │ 計算が再びユーザーの近くへ
            │              │ CDN + サーバーレス の融合
            │              │ V8 Isolates / WebAssembly
            ▼              ▼
```

この振り子運動は、偶然ではない。各時代の技術的制約と経済的要因が作用している。

**メインフレーム時代（1960年代〜）。** 計算機は高価であり、集中管理が唯一の合理的選択だった。第2回で詳しく述べたように、IBMのSystem/360がタイムシェアリングを実現し、一台の計算機を複数のユーザーが共有した。計算は「計算機のある場所」で行われ、ユーザーはダム端末で遠隔からアクセスした。

**PC/クライアントサーバ時代（1980年代〜）。** パーソナルコンピュータの登場で、計算力がユーザーの手元に移動した。第3回で取り上げたクライアント/サーバモデルでは、処理がクライアント（PC）とサーバーに分散された。ファットクライアントの時代だ。計算が分散に向かった理由は明快だ——PCの計算力が十分に安くなり、集中処理の必要性が薄れたからだ。

**Web/クラウド時代（2000年代〜2010年代）。** Webアプリケーションの台頭で、ブラウザが新しいシンクライアントとなった。計算の主体はサーバーサイドに戻った。そしてクラウドの登場で、計算は巨大データセンターに集約された。集中に戻った理由も明快だ——規模の経済（大規模データセンターの方がコスト効率が高い）と運用の効率性（集中管理の方が運用しやすい）だ。

**エッジ時代（2020年代〜）。** そして今、計算が再びユーザーの近くに分散し始めている。なぜか。三つの要因がある。

**第一に、レイテンシーの物理的限界。** クラウドのリージョンは世界に数十箇所。日本からアメリカ東海岸のリージョンまで、光速でも往復100ミリ秒以上かかる。リアルタイムアプリケーション——ゲーム、ビデオ通話、IoTデバイス制御——にとって、この遅延は致命的だ。計算をユーザーの近くに持っていけば、レイテンシーを桁違いに削減できる。

**第二に、データ主権とプライバシー規制。** GDPR（EU一般データ保護規則、2018年施行）をはじめとするデータローカライゼーション規制が、データの越境移転を制限している。ユーザーのデータを特定の地域内で処理する必要がある場合、エッジコンピューティングは自然な解になる。

**第三に、エッジランタイム技術の成熟。** V8 IsolatesとWebAssemblyの登場により、エッジでの軽量な計算実行が技術的に実現可能になった。これがなければ、エッジコンピューティングは「CDN＋キャッシュ」の域を出なかっただろう。

---

## 4. エッジコンピューティングの実行モデル——V8 Isolates vs コンテナ vs WebAssembly

### Cloudflare Workers（2017年）——V8 Isolatesの革新

2017年9月、CloudflareはWorkersを発表した。CDN事業者がエッジで「任意のコードを実行する」プラットフォームを提供する——この発想は、CDNの概念を根本から拡張するものだった。

技術的に画期的だったのは、V8 Isolatesの採用だ。

AWS Lambdaに代表される従来のサーバーレスプラットフォームは、コンテナ（またはマイクロVM）上で関数を実行する。コンテナの起動にはコールドスタートが伴う。第18回で取り上げたように、このコールドスタートは数百ミリ秒から数秒に及ぶことがある。

Cloudflare Workersは、コンテナを使わない。代わりに、Google ChromeのJavaScriptエンジンであるV8のIsolate機能を使う。

V8 Isolateとは何か。V8エンジンの中に作られる軽量な実行コンテキストだ。ブラウザの各タブが互いに隔離された環境で動くのと同じ仕組みが、サーバーサイドに応用されている。一つのV8プロセスの中に複数のIsolateが共存し、それぞれが独立したメモリ空間を持つ。

```
実行モデルの比較:

  コンテナベース（Lambda / Lambda@Edge）:

  ┌──────────────────────────────────────┐
  │ ホストOS                             │
  │  ┌────────────┐  ┌────────────┐     │
  │  │ コンテナA   │  │ コンテナB   │     │
  │  │ ┌────────┐ │  │ ┌────────┐ │     │
  │  │ │ OS層   │ │  │ │ OS層   │ │     │
  │  │ │ランタイム│ │  │ │ランタイム│ │     │
  │  │ │ 関数A  │ │  │ │ 関数B  │ │     │
  │  │ └────────┘ │  │ └────────┘ │     │
  │  └────────────┘  └────────────┘     │
  │                                      │
  │  起動時間: 数百ms〜数秒              │
  │  メモリ: 各コンテナに数十〜数百MB    │
  │  隔離: 強い（OS層で分離）            │
  └──────────────────────────────────────┘

  V8 Isolateベース（Cloudflare Workers）:

  ┌──────────────────────────────────────┐
  │ V8ランタイム（1プロセス）            │
  │  ┌──────┐ ┌──────┐ ┌──────┐        │
  │  │Isolate│ │Isolate│ │Isolate│        │
  │  │  A   │ │  B   │ │  C   │        │
  │  │ 関数A │ │ 関数B │ │ 関数C │        │
  │  └──────┘ └──────┘ └──────┘        │
  │                                      │
  │  起動時間: 5ms未満                   │
  │  メモリ: 各Isolateに数MB             │
  │  隔離: 中（V8の仕組みで分離）        │
  └──────────────────────────────────────┘

  WebAssemblyベース（Fastly Compute）:

  ┌──────────────────────────────────────┐
  │ Wasmランタイム（Lucet→Wasmtime）     │
  │  ┌──────┐ ┌──────┐ ┌──────┐        │
  │  │ Wasm │ │ Wasm │ │ Wasm │        │
  │  │モジュール│ │モジュール│ │モジュール│        │
  │  │  A   │ │  B   │ │  C   │        │
  │  └──────┘ └──────┘ └──────┘        │
  │                                      │
  │  起動時間: 35マイクロ秒（Fastly公称） │
  │  メモリ: 各モジュールに数MB           │
  │  隔離: 強い（Wasmサンドボックス）     │
  │  言語: Rust, Go, JS（コンパイル経由） │
  └──────────────────────────────────────┘
```

V8 Isolateの利点は明確だ。

**起動時間が桁違いに短い。** コンテナの起動が数百ミリ秒〜数秒であるのに対し、V8 Isolateの起動は5ミリ秒未満だ。エッジでの処理は一瞬のレスポンスが求められる。コールドスタートに数百ミリ秒かけている場合ではない。

**メモリ効率が高い。** V8ランタイムのオーバーヘッドは一度だけ支払えばよく、個々のIsolateのメモリ消費は数メガバイトに収まる。これにより、一台のサーバーで数千の異なるテナントのコードを同時に実行できる。CDNのPoPは世界中に分散しているが、各PoPの計算リソースは限られている。メモリ効率は死活問題だ。

**ブラウザ標準のAPIが使える。** V8 Isolateはブラウザと同じWeb APIを実装している。`fetch()`、`Request`、`Response`、`ReadableStream`——フロントエンド開発者にとって馴染みのあるAPIがそのまま使える。

だが、トレードオフもある。

**言語がJavaScript/TypeScriptに限定される。** V8はJavaScriptエンジンだ。RustやGoで書かれたコードは直接実行できない（WebAssembly経由でサポートされるようになったが、ネイティブ実行ではない）。

**実行時間とメモリに厳しい制約がある。** Cloudflare Workersの無料プランでは実行時間10ミリ秒、有料プランでも30秒。メモリは128MB。重い計算処理やバッチ処理には向かない。

**隔離の強度がコンテナより弱い。** V8 Isolateの隔離はV8エンジンの実装に依存する。コンテナのようにOSレベルで隔離されているわけではない。セキュリティの観点では、コンテナやマイクロVMの方が堅牢だ。

### AWS Lambda@Edge（2016年プレビュー、2017年GA）

AWSのアプローチは、Cloudflareとは異なる。

2016年のre:Invent（AWSの年次カンファレンス）でWerner VogelsがLambda@Edgeのプレビューを発表し、2017年7月17日にGA（一般提供）となった。Lambda@Edgeは、CloudFront（AWSのCDN）のエッジロケーションでLambda関数を実行するサービスだ。

Lambda@Edgeのモデルは「CDNのイベントフック」に近い。CloudFrontがリクエストを処理する過程の特定のタイミング——ビューアーリクエスト、オリジンリクエスト、オリジンレスポンス、ビューアーレスポンス——にLambda関数を挿入する。

```
Lambda@Edgeのイベントモデル:

  ユーザー ─→ CloudFront Edge
              │
              ├─→ [ビューアーリクエスト]  ← Lambda@Edge
              │    リクエストヘッダの変更、認証チェック
              │
              ├─→ キャッシュ確認
              │    ├─ HIT → [ビューアーレスポンス] ← Lambda@Edge
              │    │         レスポンスヘッダの変更
              │    │
              │    └─ MISS → [オリジンリクエスト] ← Lambda@Edge
              │               オリジンURLの書き換え
              │               │
              │               ↓
              │            オリジンサーバー
              │               │
              │            [オリジンレスポンス] ← Lambda@Edge
              │               レスポンスのキャッシュ制御
              │
              └─→ ユーザーへ応答
```

Lambda@Edgeは既存のAWSエコシステムとの統合が強みだ。CloudFront、S3、DynamoDB、API Gateway——AWSのサービス群と自然に接続できる。だが、Cloudflare Workersが「全リクエストをエッジで処理する」汎用プラットフォームとして設計されているのに対し、Lambda@Edgeは「CloudFrontのイベントに反応する」という限定的な用途を前提としていた。

2021年にはCloudFront Functionsが追加され、より軽量な処理（ヘッダ操作、URLリダイレクトなど）をJavaScriptで記述できるようになった。Lambda@Edgeよりも制約が厳しい（実行時間1ミリ秒未満、ネットワークアクセス不可）が、起動が高速でコストも低い。

### Fastly Compute@Edge（2019年）——WebAssemblyという選択

2019年11月6日、FastlyはCompute@Edge（現Fastly Compute）のベータを発表した。

FastlyがCloudflareと根本的に異なるのは、実行基盤にWebAssembly（Wasm）を選択した点だ。

Fastlyは、MozillaのWebAssemblyチームの一部を買収し、Lucetというオープンソースの WebAssemblyランタイムを開発した（後にWasmtimeに移行）。起動時間はFastlyの公称値で35.4マイクロ秒——「当時の他のどのソリューションよりも100倍高速」と主張した。

WebAssemblyの利点は、言語非依存であることだ。Rust、Go、C/C++、AssemblyScript——WebAssemblyにコンパイルできる言語であれば、エッジで実行できる。V8 IsolatesがJavaScript/TypeScriptに最適化されているのに対し、WebAssemblyはシステムプログラミング言語の性能特性を活かせる。

さらに、WebAssemblyのサンドボックスモデルは、セキュリティの観点で強力だ。Wasmモジュールはデフォルトでファイルシステムやネットワークへのアクセスを持たず、明示的に許可されたリソースのみを使用できる。マルチテナント環境での隔離に適している。

FastlyはBytecode Alliance（Mozilla、Intel、Red Hatと共同設立）にも参画し、WebAssemblyエコシステムの標準化と発展に貢献している。2023年には名称をCompute@EdgeからComputeに短縮し、エッジコンピューティングの中核プラットフォームとして位置づけた。

### エッジランタイムの百花繚乱

2020年代に入ると、エッジでコードを実行するプラットフォームが次々と登場した。

**Deno Deploy（2021年）。** Deno（Node.jsの生みの親Ryan Dahlが設計した次世代JavaScriptランタイム）のクラウドサービス。V8 Isolatesを基盤とし、32リージョンのエッジでサーバーサイドJavaScriptを実行する。AWS LambdaにもCloudflare Workersにも依存しない独自のシステムとして設計された。

**Vercel Edge Functions（2022年）。** 2022年6月にパブリックベータ、同年12月にGAとなった。Next.jsフレームワークとの深い統合が特徴で、フロントエンド開発者にとってエッジコンピューティングへの最も自然な入口を提供した。`export const config = { runtime: 'edge' }` の一行を追加するだけで、サーバーレス関数がエッジで実行される。

```
エッジコンピューティングプラットフォームの系譜:

  2017  Cloudflare Workers  ─── V8 Isolates
        Lambda@Edge GA      ─── コンテナ（CloudFront統合）

  2019  Fastly Compute@Edge ─── WebAssembly（Lucet）

  2021  Deno Deploy Beta    ─── V8 Isolates
        CloudFront Functions ─── 軽量JS（Lambda@Edgeの補完）

  2022  Vercel Edge Functions ── V8 Isolates（Next.js統合）
        Netlify Edge Functions── Deno Runtime

  2023  Fastly Compute       ── WebAssembly（Wasmtime）
        （Compute@Edgeから改名）

  技術基盤の二大潮流:
  ├── V8 Isolates系: Cloudflare, Deno Deploy, Vercel
  └── WebAssembly系: Fastly, Fermyon (Spin)
```

この百花繚乱は、エッジコンピューティングがまだ標準化されていない——つまり成熟途上にある——ことを意味する。各プラットフォームは独自のAPIと制約を持ち、ポータビリティは限定的だ。あるプラットフォームで書いたコードを別のプラットフォームに移植するには、書き直しが必要になることも多い。

---

## 5. エッジの最大の課題——状態管理

### 「ステートレス」の限界

CDNの世界では、エッジサーバーはステートレス（状態を持たない）が原則だった。キャッシュされたコンテンツは一方向に配信されるだけで、ユーザーの状態を保持する必要はない。

だが、エッジで「計算」を実行するとなると話が変わる。ユーザーのセッション、カウンター、設定、一時データ——何らかの状態を保持する必要が出てくる。そして「エッジに状態を持つ」ことは、分散システムの中でも最も困難な課題の一つだ。

なぜか。エッジサーバーは世界中に分散している。あるユーザーのリクエストが東京のPoPで処理され、次のリクエストがシンガポールのPoPで処理されるかもしれない。両方のPoPが同じ「状態」を参照するにはどうすればいいか。

```
エッジでの状態管理の困難さ:

  リクエスト1: ユーザー → PoP（東京）
               カウンターを +1 → カウンター = 1

  リクエスト2: ユーザー → PoP（シンガポール）
               カウンターの値は？
               ├── 東京のPoPに問い合わせる？ → レイテンシー増加
               ├── 全PoPでリアルタイム同期？ → 非現実的
               └── 結果整合性を許容する？   → アプリ次第

  CAP定理の制約:
  ・一貫性（Consistency）
  ・可用性（Availability）
  ・分断耐性（Partition tolerance）
  → 分散システムではこの3つを同時に満たせない
```

Cloudflareは、この課題に段階的に取り組んだ。その進化は、エッジにおける状態管理の難しさと解法の発展を端的に示している。

### Workers KV（2018年）——結果整合性のKey-Valueストア

2018年9月、CloudflareはWorkers KVのベータを発表した（2019年5月にGA）。

Workers KVは、グローバルに分散されたKey-Valueストアだ。値はCloudflareの全PoPで読み取り可能であり、書き込みは数秒以内に全PoPに伝播する。読み取りは高速だが、書き込みは結果整合性（Eventually Consistent）——つまり、書き込んだ直後に別のPoPから読み取ると、古い値が返る可能性がある。

```
Workers KVのデータフロー:

  書き込み:
  Worker（東京）──→ KV書き込み ──→ 中央ストレージ
                                     │
                                     ├──→ PoP（東京）に伝播    〜数秒
                                     ├──→ PoP（ロンドン）に伝播 〜数秒
                                     └──→ PoP（NY）に伝播       〜数秒

  読み取り:
  Worker（ロンドン）──→ PoP（ロンドン）のKVキャッシュ ──→ 即座に応答
                         │
                         └─ キャッシュが古い可能性あり（結果整合性）

  適するユースケース: 設定値、Feature Flag、静的データ
  適さないユースケース: カウンター、在庫数、残高
```

Workers KVは「読み取りが多く、書き込みが少ない」ワークロードに最適化されている。設定値の配信、Feature Flagの管理、URLリダイレクトのルールストア——こうした用途には十分だ。だが、カウンターの増減や在庫管理のように強い一貫性が求められる用途には向かない。

### Durable Objects（2020年）——強整合性のステートフルオブジェクト

Workers KVが結果整合性の限界を露呈する中、2020年9月、CloudflareはDurable Objectsを発表した。

Durable Objectsのアプローチは根本的に異なる。Workers KVがデータを全PoPに分散するのに対し、Durable Objectsは「各オブジェクトが世界のどこか一箇所に存在する」というモデルを採る。特定のオブジェクト（例えばチャットルームや共同編集のドキュメント）への全アクセスが、そのオブジェクトが存在するロケーションに集約される。

```
Durable Objectsの動作モデル:

  チャットルーム "room-42" のDurable Object
  → フランクフルトに配置（ユーザーの分布から自動決定）

  ユーザーA（東京）──────→ フランクフルトの "room-42" ←── ユーザーB（ロンドン）
                           │
                           │ 単一のJavaScript
                           │ オブジェクトとして存在
                           │
                           │ ・メモリ内の状態は強整合
                           │ ・WebSocketで双方向通信
                           │ ・永続ストレージへの書き込み

  利点: 強整合性（単一箇所で処理するため競合なし）
  代償: そのオブジェクトへのアクセスは一箇所に集中
        → 遠距離のユーザーにはレイテンシーが増加
```

このモデルは、エッジの「分散」の理念と矛盾するように見える。だが、現実の多くのアプリケーションには「特定のリソースに対する一貫したアクセス」が必要だ。チャットルームの参加者一覧、共同編集のカーソル位置、ゲームの対戦状態——これらは「最新の正確な値」が必要であり、結果整合性では成り立たない。

Durable Objectsは、「全てをエッジに分散する」のではなく、「状態の種類に応じて最適な配置を選ぶ」というプラグマティックな解答だ。

### D1（2022年）——エッジのSQLデータベース

2022年5月、CloudflareはD1を発表した。SQLiteベースのリレーショナルデータベースをエッジで動かすという野心的な試みだ。

Workers KV（Key-Value）→ Durable Objects（ステートフルオブジェクト）→ D1（SQL）——この進化は、エッジにおける状態管理の抽象度が段階的に上がっていることを示している。

```
Cloudflareのエッジデータストレージの進化:

  2018  Workers KV ──────── 結果整合性 / Key-Value
        │                   読み取り最適化
        │                   設定値、Feature Flag向き
        │
  2020  Durable Objects ─── 強整合性 / オブジェクト
        │                   単一箇所に集約
        │                   リアルタイム協調処理向き
        │
  2022  D1 ──────────────── SQL / リレーショナル
                            SQLiteベース
                            汎用的なデータ永続化

  抽象度の上昇:
  Key-Value → ステートフルオブジェクト → SQL

  これはクラウドの歴史の再演でもある:
  S3（オブジェクトストレージ）→ DynamoDB（KV）→ RDS（SQL）
```

エッジのデータストレージはまだ発展途上だ。クラウドのリージョンにあるデータベース（RDS、DynamoDB、Cloud SQL）の成熟度には遠く及ばない。だが方向性は明確だ。エッジは「計算だけ」のプラットフォームから、「計算＋状態」のプラットフォームへと進化しつつある。

---

## 6. エッジランタイムの標準化——WinterCGからWinterTCへ

### APIの分断という問題

エッジコンピューティングの急速な発展は、一つの深刻な問題を生み出した。各プラットフォームのAPIが互換性を持たないのだ。

Cloudflare Workersで動くコードが、Deno Deployではそのまま動かない。Vercel Edge FunctionsのコードをFastly Computeに移植するには書き直しが必要だ。各プラットフォームは「Web標準」を謳いつつも、独自の拡張やサブセットを実装している。

この状況は、ブラウザ戦争の歴史を想起させる。1990年代後半、Internet ExplorerとNetscape Navigatorが独自のJavaScript APIを実装し、開発者は「このブラウザでは動くがあのブラウザでは動かない」問題に苦しんだ。W3Cの標準化がこの問題を解決するのに10年以上かかった。

エッジランタイムの世界で同じ轍を踏まないために、2022年に標準化の動きが始まった。

### WinterCG（2022年）——標準化の試み

2022年4月22日、Cloudflareの James SnellがW3Cに「Web-interoperable Runtimes Community Group」を提案した。略称WinterCG。Deno（Luca Casonato）、Node.js（Benjamin Gruenbaum、Tobias Nießen）などの関係者が共同提案者として名を連ねた。

2022年5月、WinterCGはW3C傘下のCommunity Groupとして正式に活動を開始した。

WinterCGの目的は明確だ。ブラウザ以外の環境——バックエンドサーバー、サーバーレス、エッジランタイム、IoT——で実装されるべきWeb標準APIの共通サブセットを定義すること。これを「Minimum Common API」と呼ぶ。

`fetch()`、`Request`、`Response`、`URL`、`ReadableStream`、`TextEncoder`、`crypto.subtle`——これらのAPIがどのエッジランタイムでも同じように動けば、コードのポータビリティは飛躍的に向上する。

2024年12月、WinterCGはさらに大きな一歩を踏み出した。W3CのCommunity GroupからEcma InternationalのTC55（Technical Committee 55）——通称WinterTC——に移行したのだ。Ecma Internationalは、JavaScript（ECMAScript）やJSON（ECMA-404）の標準化団体だ。WinterTCへの移行は、エッジランタイムのAPI互換性が「コミュニティの議論」から「公式な標準化プロセス」に格上げされたことを意味する。

```
エッジランタイム標準化の流れ:

  ブラウザの歴史との対比:

  ブラウザ:
  1995  ブラウザ戦争（IE vs Netscape）
  1996  W3C HTML/CSS標準化
  2004  WHATWG設立（HTML5）
  2015  ES2015（ECMAScript標準化）
  → 10年以上かけてAPIの互換性を確立

  エッジランタイム:
  2017  Cloudflare Workers（独自API）
  2019  Fastly Compute@Edge（独自API）
  2021  Deno Deploy（独自API）
  2022  WinterCG設立（W3C Community Group）
        Minimum Common APIの策定開始
  2024  WinterTC（Ecma TC55）に移行
        公式な標準化プロセスへ
  → まだ始まったばかり
```

標準化の道のりは長い。だがその方向性は正しい。エッジランタイムが標準化されれば、ベンダーロックインへの懸念が薄れ、エッジコンピューティングの採用が加速するだろう。第15回で取り上げた「PaaSが苦戦した理由」の一つがベンダーロックインへの恐怖だったことを思い出してほしい。コンテナの標準化（Docker、OCI）がPaaS 2.0の登場を可能にしたように、エッジランタイムの標準化が「エッジ 2.0」を準備する。

---

## 7. ハンズオン——エッジ関数の動作とレイテンシーを体験する

ここでは、Cloudflare Workers（Wrangler CLI）を使ってエッジ関数をデプロイし、従来のリージョン型デプロイとの性能差を確認する。Cloudflareのアカウント（無料プランで十分）が必要だ。

### 演習1：エッジ関数のデプロイとレイテンシー計測

```bash
# === エッジ関数の構築とデプロイ ===

# 前提: Node.js 18以上がインストールされていること

WORKDIR="${HOME}/cloud-history-handson-20"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=========================================="
echo "演習1: Cloudflare Workersでエッジ関数をデプロイ"
echo "=========================================="

# --- Wrangler CLIのインストール ---
npm init -y
npm install wrangler --save-dev

# --- エッジ関数のコード ---
mkdir -p src
cat > src/index.js << 'JS_EOF'
export default {
  async fetch(request, env, ctx) {
    const start = Date.now();

    // リクエスト元の情報を取得
    const cf = request.cf || {};
    const clientInfo = {
      // Cloudflareが付与するメタ情報
      country: cf.country || "unknown",
      city: cf.city || "unknown",
      colo: cf.colo || "unknown",  // 処理したデータセンターの空港コード
      region: cf.region || "unknown",
      latitude: cf.latitude || "unknown",
      longitude: cf.longitude || "unknown",
    };

    // 簡単な「計算」をエッジで実行
    // 現在時刻のフォーマットとリクエスト情報の整形
    const now = new Date();
    const response = {
      message: "Hello from the Edge!",
      timestamp: now.toISOString(),
      processing_location: {
        datacenter: clientInfo.colo,
        country: clientInfo.country,
        city: clientInfo.city,
      },
      client: {
        country: clientInfo.country,
        region: clientInfo.region,
      },
      performance: {
        edge_processing_ms: Date.now() - start,
        note: "この処理はあなたに最も近いエッジで実行された",
      },
      explanation: {
        what_happened: [
          "1. あなたのリクエストはDNSで最寄りのCloudflare PoPに到達",
          `2. ${clientInfo.colo}のエッジサーバーでV8 Isolateが起動`,
          "3. このJavaScript関数がエッジで実行された",
          "4. オリジンサーバーへの通信は発生していない",
          "5. レスポンスがエッジから直接返された",
        ],
      },
    };

    return new Response(JSON.stringify(response, null, 2), {
      headers: {
        "Content-Type": "application/json",
        "X-Edge-Location": clientInfo.colo,
        "X-Processing-Time": `${Date.now() - start}ms`,
      },
    });
  },
};
JS_EOF

# --- wrangler.toml（設定ファイル） ---
cat > wrangler.toml << 'TOML_EOF'
name = "cloud-history-edge-demo"
main = "src/index.js"
compatibility_date = "2024-01-01"

# 全世界のエッジロケーションにデプロイされる
# リージョンの指定は不要（これがエッジの特徴）
TOML_EOF

echo ""
echo "=== ローカルでのテスト ==="
echo "以下のコマンドでローカル開発サーバーを起動:"
echo "  npx wrangler dev"
echo ""
echo "別のターミナルからリクエスト:"
echo "  curl -s http://localhost:8787 | python3 -m json.tool"
echo ""
echo "=== デプロイ ==="
echo "Cloudflareアカウントでログイン後:"
echo "  npx wrangler login"
echo "  npx wrangler deploy"
echo ""
echo "デプロイ後のURL（例）:"
echo "  https://cloud-history-edge-demo.<your-subdomain>.workers.dev"
```

### 演習2：エッジ vs リージョンのレイテンシー比較

```bash
echo "=========================================="
echo "演習2: エッジ vs リージョンのレイテンシー比較"
echo "=========================================="

cd "${HOME}/cloud-history-handson-20"

# --- レイテンシー計測スクリプト ---
cat > measure-latency.sh << 'SCRIPT_EOF'
#!/bin/bash
set -euo pipefail

# 使い方: ./measure-latency.sh <URL> <回数>
URL="${1:?Usage: $0 <URL> <count>}"
COUNT="${2:-10}"

echo "=== レイテンシー計測: ${URL} ==="
echo "計測回数: ${COUNT}"
echo ""

total=0
min=999999
max=0

for i in $(seq 1 "${COUNT}"); do
  # curlでTTFB（Time To First Byte）を計測
  # time_starttransfer = DNSルックアップ + TCP接続 + TLS + サーバー処理 + 最初のバイト受信
  time_ms=$(curl -s -o /dev/null -w "%{time_starttransfer}" "${URL}" | awk '{printf "%.0f", $1 * 1000}')

  if [ "${time_ms}" -lt "${min}" ]; then min=${time_ms}; fi
  if [ "${time_ms}" -gt "${max}" ]; then max=${time_ms}; fi
  total=$((total + time_ms))

  printf "  #%2d: %4d ms (TTFB)\n" "${i}" "${time_ms}"
  sleep 0.5
done

avg=$((total / COUNT))
echo ""
echo "結果:"
echo "  最小: ${min} ms"
echo "  最大: ${max} ms"
echo "  平均: ${avg} ms"
SCRIPT_EOF
chmod +x measure-latency.sh

echo ""
echo "=== 使い方 ==="
echo ""
echo "1. エッジ関数のレイテンシーを計測:"
echo "   ./measure-latency.sh https://cloud-history-edge-demo.<subdomain>.workers.dev 10"
echo ""
echo "2. リージョン型API（東京リージョン）のレイテンシーを計測:"
echo "   ./measure-latency.sh https://<your-api>.ap-northeast-1.amazonaws.com 10"
echo ""
echo "3. 比較のポイント:"
echo "   - エッジ関数: 最寄りのPoPが応答するため低レイテンシー"
echo "   - リージョン型: 東京リージョンまでの往復が必要"
echo "   - 日本国内からの場合、差は小さい"
echo "   - 海外からアクセスすると差が顕著になる"
echo ""
echo "考察:"
echo "  TTFBの差 = ネットワーク往復時間の差 + 処理時間の差"
echo "  エッジの処理時間自体は1-5ms程度"
echo "  差の大部分はネットワーク往復時間（物理的距離に起因）"
echo ""
echo "=== CDN + エッジの効果を確認 ==="
echo ""
echo "curlでレスポンスヘッダを確認:"
echo "  curl -I https://cloud-history-edge-demo.<subdomain>.workers.dev"
echo ""
echo "注目すべきヘッダ:"
echo "  cf-ray: <hex>-<POP>  ← 処理したPoPの空港コード"
echo "  X-Edge-Location      ← エッジ関数が付与したPoP情報"
echo "  X-Processing-Time    ← エッジでの処理時間"
```

### 演習3：エッジにおける状態管理の概念

```bash
echo "=========================================="
echo "演習3: エッジの状態管理（Workers KVの概念）"
echo "=========================================="

cd "${HOME}/cloud-history-handson-20"

# --- Workers KVを使ったカウンターの例 ---
cat > src/counter.js << 'JS_EOF'
// Workers KV を使ったページビューカウンター
// 結果整合性の挙動を観察するための例

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;

    if (path === "/count") {
      // KVからカウンターを読み取り
      const currentStr = await env.PAGE_VIEWS.get("total");
      const current = parseInt(currentStr || "0", 10);

      // カウンターを+1してKVに書き込み
      const next = current + 1;
      await env.PAGE_VIEWS.put("total", next.toString());

      const cf = request.cf || {};
      return new Response(JSON.stringify({
        page_views: next,
        served_by: cf.colo || "local",
        note: "Workers KVは結果整合性。"
            + "別のPoPから即座に読むと古い値が返る可能性がある。"
            + "数秒後には全PoPで最新値が利用可能になる。",
        consistency_model: "eventually_consistent",
        propagation_delay: "通常数秒以内",
      }, null, 2), {
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({
      endpoints: {
        "/count": "カウンターを+1して現在値を返す",
      },
      explanation: {
        kv_behavior: [
          "Workers KVは結果整合性（Eventually Consistent）",
          "書き込みは数秒で全PoPに伝播する",
          "高頻度の書き込みでは競合（race condition）が発生しうる",
          "厳密なカウンターにはDurable Objectsが必要",
        ],
      },
    }, null, 2), {
      headers: { "Content-Type": "application/json" },
    });
  },
};
JS_EOF

# --- wrangler.toml にKVバインディングを追加 ---
cat > wrangler-kv.toml << 'TOML_EOF'
name = "cloud-history-edge-counter"
main = "src/counter.js"
compatibility_date = "2024-01-01"

# Workers KVネームスペースのバインディング
# デプロイ前に以下のコマンドでKVネームスペースを作成:
#   npx wrangler kv namespace create PAGE_VIEWS
# 出力されたidをここに記入する
[[kv_namespaces]]
binding = "PAGE_VIEWS"
id = "<YOUR_KV_NAMESPACE_ID>"
TOML_EOF

echo ""
echo "=== Workers KVの概念 ==="
echo ""
echo "Workers KVは結果整合性のKey-Valueストア。"
echo "全PoPで読み取り可能だが、書き込みの伝播には数秒かかる。"
echo ""
echo "この演習で理解すべきこと:"
echo "  1. エッジで状態を持つことの難しさ"
echo "  2. 結果整合性のトレードオフ"
echo "  3. ユースケースに応じた適切なストレージの選択"
echo ""
echo "  Workers KV: 読み取り多、書き込み少 → 設定値、Feature Flag"
echo "  Durable Objects: 強整合性が必要 → リアルタイム協調、カウンター"
echo "  D1: SQL + リレーショナル → 汎用データ永続化"
```

ハンズオンの詳細な手順と自動セットアップスクリプトは、本リポジトリの `handson/cloud-history/20-cdn-edge-computing/` に用意してある。

---

## 8. まとめと次回予告

### この回のまとめ

第20回では、CDNからエッジコンピューティングへの進化を、技術的・歴史的に読み解いた。

**CDNの起源は、1995年のTim Berners-Leeの課題に遡る。** MIT教授のTom Leightonと大学院生のDanny Lewinが分散コンテンツ配信のアルゴリズムを開発し、1998年にAkamai Technologiesを設立した。1999年の商用サービス開始以降、CDNは「コンテンツをユーザーの近くに置く」という概念を確立し、Webの高速化に決定的な貢献を果たした。だがCDNは静的コンテンツの配信に最適化されており、動的な処理——つまり「計算」——はオリジンサーバーに依存し続けた。

**「計算する場所」の歴史は振り子運動だ。** メインフレームの集中処理、PC/クライアントサーバの分散、Web/クラウドの再集中、そしてエッジの再分散。この振り子は偶然ではなく、各時代のハードウェアコスト、ネットワーク帯域、レイテンシー要件、規制要件によって駆動されている。エッジコンピューティングは、レイテンシーの物理的限界、データ主権規制、そしてエッジランタイム技術の成熟という三つの要因が重なって現実のものとなった。

**エッジコンピューティングの実行モデルは二大潮流に分かれる。** V8 Isolates系（Cloudflare Workers 2017年、Deno Deploy 2021年、Vercel Edge Functions 2022年）とWebAssembly系（Fastly Compute@Edge 2019年）。V8 Isolatesはコールドスタートの短さとJavaScript/TypeScript開発者への親和性が強み。WebAssemblyは言語非依存性とサンドボックスの堅牢さが強み。コンテナベースのLambda@Edge（2017年GA）は、AWS CloudFrontとの統合が特徴だ。

**エッジの最大の課題は状態管理だ。** Cloudflareの進化がこれを端的に示す。Workers KV（2018年、結果整合性のKey-Value）→ Durable Objects（2020年、強整合性のステートフルオブジェクト）→ D1（2022年、SQLデータベース）。エッジは「計算だけ」のプラットフォームから「計算＋状態」のプラットフォームへと進化しつつあるが、クラウドリージョンのデータベースの成熟度には遠く及ばない。

**エッジランタイムの標準化が始まった。** 2022年5月にW3C傘下でWinterCGが設立され、2024年12月にはEcma InternationalのTC55（WinterTC）に移行した。ブラウザ戦争で学んだ教訓——標準化なきプラットフォーム乱立は開発者を疲弊させる——が、エッジの世界にも適用されつつある。

冒頭の問いに答えよう。なぜ「計算する場所」は揺れ動くのか。それは、集中と分散のどちらにも固有のメリットとコストがあり、時代の技術的・経済的条件によって最適解が変わるからだ。メインフレームは計算機が高価だったから集中が合理的だった。PCは安くなったから分散が合理的になった。クラウドは規模の経済で集中が再び合理的になった。エッジはレイテンシーとデータ主権の要請で分散が再び合理的になりつつある。

そしてエッジコンピューティングは振り子の終着点ではない。次の技術的制約——量子コンピューティング、AI専用チップ、衛星インターネット——が、また新たな「最適な場所」を定義するだろう。歴史が教えるのは、「永遠に正しい配置は存在しない」ということだ。だからこそ、計算の配置を「選べる」能力が重要になる。

### 次回予告

第21回では、「FinOps——クラウドコストという新しい工学」を取り上げる。

クラウドの従量課金モデルは、インフラコストの構造を根本から変えた。「サーバーを買う」時代のCapEx（資本的支出）から、「サーバーを借りる」時代のOpEx（運用支出）へ。だが「使った分だけ支払う」はずのクラウドが、想定を遥かに超えるコストを生み出す事態が頻発した。なぜクラウドのコスト管理は一つの専門分野——FinOps——として確立されるに至ったのか。Reserved Instances（2009年）からSavings Plans（2019年）への進化、FinOps Foundation（2019年設立）の活動、そしてDHH（37signals）のクラウド離脱宣言が投げかけた問い。コスト最適化が技術的判断そのものであることを、次回で論じる。

---

## 参考文献

- Akamai Technologies, "Akamai Company History - The Akamai Story". <https://www.akamai.com/company/company-history>
- MIT News, "Professor Tom Leighton and Danny Lewin SM '98 named to National Inventors Hall of Fame", February 2, 2017. <https://news.mit.edu/2017/leighton-lewin-named-national-inventors-hall-of-fame-0202>
- Cloudflare Blog, "Cloudflare Workers: the Fast Serverless Platform". <https://blog.cloudflare.com/cloudflare-workers-the-fast-serverless-platform/>
- Cloudflare, "How Workers works". <https://developers.cloudflare.com/workers/reference/how-workers-works/>
- AWS, "Lambda@Edge now Generally Available", July 17, 2017. <https://aws.amazon.com/about-aws/whats-new/2017/07/lambda-at-edge-now-generally-available/>
- Fastly, "Fastly Launches Compute@Edge", November 6, 2019. <https://www.fastly.com/press/press-releases/fastly-expands-serverless-capabilities-launch-compute-edge>
- Deno Blog, "Deno Deploy Beta 1", 2021. <https://deno.com/blog/deploy-beta1>
- Vercel, "Edge Functions are now generally available", December 15, 2022. <https://vercel.com/changelog/edge-functions-are-now-generally-available>
- Deno Blog, "Announcing the Web-interoperable Runtimes Community Group", 2022. <https://deno.com/blog/announcing-wintercg>
- Deno Blog, "Goodbye WinterCG, welcome WinterTC", January 2025. <https://deno.com/blog/wintertc>
- Cloudflare Blog, "Introducing Workers KV", September 2018. <https://blog.cloudflare.com/introducing-workers-kv/>
- Cloudflare Blog, "Workers Durable Objects Beta: A New Approach to Stateful Serverless", September 2020. <https://blog.cloudflare.com/introducing-workers-durable-objects/>
- Cloudflare Blog, "Announcing D1: our first SQL database", May 2022. <https://blog.cloudflare.com/introducing-d1/>
- CDN Handbook, "The History of Content Delivery Networks (CDNs)". <https://www.cdnhandbook.com/cdn/history/>
