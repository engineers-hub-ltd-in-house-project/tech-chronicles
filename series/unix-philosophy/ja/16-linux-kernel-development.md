# UNIXという思想

## ——パイプ、プロセス、ファイル――すべてはここから始まった

### 第16回：「Linuxカーネル開発モデル——"大聖堂"と"バザール"の実態」

**連載「UNIXという思想——パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Eric Raymondの「The Cathedral and the Bazaar」（1997年）が描いたオープンソース開発の二つのモデルと、Netscapeのソースコード公開への直接的影響
- Linuxカーネル開発の実際のワークフロー——マージウィンドウ、RCリリース、約9〜10週間のリリースサイクル
- サブシステムメンテナの階層構造と、LKMLを中心としたパッチレビュープロセスの実態
- BitKeeper騒動（2005年）からGit誕生に至る経緯と、それがカーネル開発にもたらした変革
- 「安定APIなし」というカーネル内部のポリシーと、ユーザ空間ABIの後方互換性保証の二重構造
- Linus Torvaldsのコミュニケーションスタイルの功罪と、2018年のCode of Conduct導入に至る経緯
- 4,000万行超・約4,800名の開発者が参加する世界最大のオープンソースプロジェクトの統治構造

---

## 1. メーリングリストの洗礼

2006年の秋、私はLinux Kernel Mailing List（LKML）を初めて通読しようとした。

きっかけは些末なことだった。運用しているサーバでカーネルパニックが発生し、原因を追跡するうちにカーネルのバグトラッカーに辿り着いた。そこから関連するLKMLのスレッドに行き着き、開発者たちのやり取りを読み始めた。

衝撃だった。

まず、メールの量が尋常ではない。1日に数百通のパッチ、レビューコメント、議論が飛び交う。技術的な議論の密度も凄まじい。カーネルのメモリ管理の細部について、数十通にわたるスレッドが展開される。パッチの1行1行に対して「この変数名は誤解を招く」「このロック取得の順序ではデッドロックの可能性がある」といった具体的な指摘が返る。

そして、Linus Torvaldsのメールを読んだ。

率直だった。ときに辛辣だった。提出されたパッチに対して、技術的な問題点を容赦なく指摘する。言葉を選ばない。「This is garbage」に類する表現が、世界中に公開されたメーリングリスト上に、送信者の実名付きで飛ぶ。パッチの著者がIntelやGoogleのエンジニアであろうと関係ない。コードの質だけが問われる。

当時の私には、この開発プロセスが理解できなかった。会社のコードレビューでは、どれだけ問題のあるコードであっても相手の感情に配慮した言い方をする。だがLKMLでは、コードの質が人間関係の礼儀より優先されているように見えた。これが世界で最も重要なオープンソースプロジェクトの日常なのかと、画面の前で呆然とした。

それから20年近くが経った。Linuxカーネルは4,000万行を超えるコードベースに成長し、約4,800名の開発者が毎年貢献している。このプロジェクトがどのように統治されているのか——その問いに対する答えは、Eric Raymondが1997年に描いた「バザール」モデルとも、多くの人が想像する「民主的な共同開発」とも、実態はかなり異なる。

あなたが関わっているプロジェクトの開発プロセスは、どのような構造を持っているだろうか。そしてその構造は、意図的に設計されたものだろうか。それとも自然に形成されたものだろうか。

---

## 2. 「大聖堂」と「バザール」——エッセイが変えた世界

### Raymondのエッセイとその衝撃

1997年5月27日、ドイツ・ヴュルツブルクで開催されたLinux Kongressの壇上に、Eric S. Raymondが立った。彼が発表したエッセイ「The Cathedral and the Bazaar」は、ソフトウェア開発の方法論に関する認識を根底から揺るがすことになる。

Raymondのエッセイの核心は、ソフトウェア開発に二つのモデルがあるという対比だった。

「大聖堂」モデルは、少数の精鋭が密室で設計・実装し、完成度の高いものをリリースする。GNU EmacsやGCC——Free Software Foundationのプロジェクトがこのモデルの典型だとRaymondは論じた。大聖堂の建設のように、緻密な計画と熟練した職人の手で、完璧な作品を作り上げる。

「バザール」モデルは、Linuxカーネルの開発から着想された。誰でも参加でき、リリースは頻繁で、コードベースは常に流動的だ。混沌とした市場——バザール——のように、多様な参加者がそれぞれの動機で貢献し、その集合体として品質が担保される。

Raymondは自身のfetchmail（メール取得ユーティリティ）の開発経験を素材に、バザールモデルの有効性を論証した。彼が提示した「十分な目玉があれば、すべてのバグは浅い（Given enough eyeballs, all bugs are shallow）」——いわゆる「Linusの法則」——は、オープンソース開発の正当性を支える格言となった。多くの人間がコードを見れば、バグは速やかに発見・修正される。大聖堂の中の少数精鋭では見落とすバグも、バザールの無数の目が捉える。

### Netscapeの決断

このエッセイは、学術的な議論にとどまらなかった。

1998年1月22日、Netscape Communications社はNetscape Communicatorのソースコードを公開すると発表した。この決定に、Raymondのエッセイが直接的に影響していた。Netscape社内でFrank Heckerが経営陣にソースコード公開を提案する際、「The Cathedral and the Bazaar」を「外部からの独立した検証」として引用した。Microsoftの Internet Explorerに押されて市場シェアを失いつつあったNetscapeにとって、オープンソースは起死回生の賭けだった。

1998年3月31日、Netscapeのソースコードは実際に公開され、Mozillaプロジェクトが始動する。このプロジェクトが直接的に成功したかどうかは議論の余地がある。だが重要なのは、Netscapeという商用ソフトウェア企業が「ソースコードを公開する」という決断を下したことだ。この先例が、「オープンソースは企業にとっても選択肢になる」という認識を広めた。

Raymondのエッセイは発表後も改訂が続き、1998年2月9日のバージョンでは「free software」という用語を「open source」に変更している。1999年にはO'Reilly Mediaから書籍として出版された。このエッセイが、ソフトウェア業界の意思決定者たちに「オープンソースは慈善活動ではなく、合理的な開発手法である」と認識させた功績は大きい。

### エッセイが描かなかったもの

だが、Raymondのエッセイには限界がある。

「The Cathedral and the Bazaar」は、オープンソース開発の「可能性」を論じた。だがLinuxカーネルの実際の開発プロセスが、純粋な「バザール」——誰でも自由に参加し、民主的に意思決定される開放的な市場——であるかと言えば、実態はかなり異なる。

Linuxカーネルの開発プロセスは、Raymondが描いたバザールの理想像よりも、はるかに構造化されている。そこには明確なヒエラルキーがあり、権限の集中があり、厳格なコードレビュープロセスがある。自由な参加と厳格な統治——この一見矛盾する二つの要素がどう共存しているのか。それを理解するには、実際の開発ワークフローを見る必要がある。

---

## 3. Linuxカーネル開発の実態——構造化されたバザール

### リリースサイクルの構造

Linuxカーネルの開発は、約9〜10週間のリリースサイクルで回っている。このサイクルは二つのフェーズで構成される。

```
Linuxカーネルのリリースサイクル（約9〜10週間）:

  マージウィンドウ（約2週間）          RCフェーズ（約7〜8週間）
  ┌──────────────────────┐  ┌─────────────────────────────────────┐
  │ 新機能のマージ        │  │ バグ修正のみ                        │
  │ サブシステムメンテナ  │  │ rc1 → rc2 → ... → rc6〜rc9 → 正式版│
  │ がpull requestを送信 │  │ 週に1回程度、Linusがrcをリリース   │
  │                      │  │                                     │
  │ 前のリリースの直後に  │  │ 「十分に安定した」とLinusが判断     │
  │ 開始される            │  │ したら正式リリース                  │
  └──────────────────────┘  └─────────────────────────────────────┘

  例: Linux 6.14の場合
  前バージョン(6.13)リリース → マージウィンドウ開始
  → 2週間後: 6.14-rc1（マージウィンドウ終了）
  → 毎週: rc2, rc3, rc4, rc5, rc6, rc7...
  → 十分に安定: 6.14 正式リリース
  → 即座に: 6.15のマージウィンドウ開始
```

**マージウィンドウ。** 新しいカーネルリリースの直後、約2週間のマージウィンドウが開く。この期間だけが、新機能をメインラインに取り込める時間だ。各サブシステムのメンテナたちが、前のサイクルで自分のサブシステムツリーに蓄積したパッチを、Linus Torvaldsに対してgit pull requestとして送信する。Linusはそれをレビューし、問題がなければメインラインにマージする。

マージウィンドウが閉じると、Linusは最初のリリース候補（RC）である-rc1をリリースする。この時点で新機能の受け入れは終了だ。

**RCフェーズ。** rc1以降は、バグ修正のみが受け入れられる。Linusは週に1回程度のペースで新しいRCをリリースし、開発者コミュニティはそれをテストし、問題を報告し、修正パッチを送る。通常rc6からrc9程度まで続き、Linusが「十分に安定した」と判断した時点で正式版がリリースされる。

正式版がリリースされた瞬間、次のバージョンのマージウィンドウが開く。このサイクルは機械的に回り続ける。

### サブシステムメンテナの階層構造

Linuxカーネルの開発において、Linus Torvaldsが全てのパッチを直接レビューしているわけではない。4,000万行を超えるコードベースに、年間数万のパッチが投入される。一人の人間がすべてをレビューすることは物理的に不可能だ。

実際の開発は、サブシステムメンテナの階層構造によって成り立っている。

```
Linuxカーネルのメンテナ階層:

                    ┌───────────────┐
                    │ Linus Torvalds │
                    │ （最終マージ）  │
                    └───────┬───────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
  ┌─────┴─────┐      ┌─────┴─────┐      ┌─────┴─────┐
  │ ネットワーク│      │ ファイル   │      │ スケジューラ│
  │ サブシステム│      │ システム   │      │            │
  │ メンテナ   │      │ メンテナ   │      │ メンテナ   │
  └─────┬─────┘      └─────┬─────┘      └────────────┘
        │                   │
  ┌─────┼─────┐      ┌─────┼─────┐
  │     │     │      │     │     │
  NIC  無線  TCP     ext4  XFS  btrfs
  ドライバ    /IP
  メンテナ    メンテナ メンテナ

  パッチの流れ（ボトムアップ）:
  開発者 → サブメンテナ → サブシステムメンテナ → Linus
```

カーネルソースツリーのMAINTAINERSファイルに、各サブシステムの責任者が定義されている。ネットワークスタック、ファイルシステム、デバイスドライバ、メモリ管理、スケジューラ——それぞれに専門のメンテナがいる。さらにその下に、個別のドライバやサブモジュールを担当するサブメンテナが存在する。ネットワークサブシステムの下にNICドライバのメンテナ、無線ネットワーキングのメンテナ、TCP/IPスタックのメンテナがいる、という具合だ。

パッチは下から上へ流れる。開発者がパッチを作成し、該当するサブシステムのメーリングリストに投稿する。サブメンテナがレビューし、問題がなければサブシステムメンテナのツリーに取り込まれる。サブシステムメンテナはさらにテストを行い、マージウィンドウでLinusにpull requestを送る。

この構造について、カーネルの公式ドキュメントは興味深い記述をしている。「外部から見ればLinusがCEOの階層組織に見えるが、企業テンプレートは当てはまらない。Linuxは（めったに表明されない）相互の尊敬、信頼、便宜によって結びついた無政府状態だ」。形式的には階層だが、実質的には信頼のネットワークだ。Linusはサブシステムメンテナを信頼し、メンテナはサブメンテナを信頼する。この信頼の連鎖がなければ、この規模のプロジェクトは回らない。

### パッチレビューのプロセス

パッチがメインラインにマージされるまでの道のりは、決して平坦ではない。

開発者はまずパッチを作成し、`git format-patch`でメール送信可能な形式に整形し、`git send-email`で関連するメーリングリストに投稿する。GitHubのPull Requestではない。メーリングリストへのメール送信だ。2020年代においても、Linuxカーネル開発はメーリングリストベースのワークフローを維持している。

投稿されたパッチは、そのサブシステムの開発者たちからレビューを受ける。コードの正確性、パフォーマンスへの影響、既存のコーディングスタイルとの整合性、他のサブシステムへの副作用——あらゆる観点から検証される。レビューの結果、修正が必要であれば、開発者はパッチを改訂して再投稿する。この修正と再投稿のサイクルが何度も繰り返されることは珍しくない。

レビューが完了し、メンテナがパッチを受け入れると、そのパッチはサブシステムメンテナのgitツリーに取り込まれる。さらに-nextツリー（linux-next）に統合され、他のサブシステムとの統合テストが行われる。ここで問題が見つかることもある。複数のサブシステムが同時に変更されると、個別には正しいパッチが組み合わさって問題を起こすことがある。

このプロセス全体が、公開されたメーリングリスト上で行われる。すべてのレビューコメント、すべての議論、すべての意思決定が、アーカイブとして永続的に記録される。透明性は絶対的だ。

### なぜメーリングリストなのか

2020年代の多くのオープンソースプロジェクトがGitHub/GitLabのPull Requestモデルに移行する中、Linuxカーネルが頑なにメーリングリストベースのワークフローを維持していることに疑問を持つ人は多い。

理由はいくつかある。

第一に、スケールの問題だ。Linuxカーネルの開発規模は、GitHubのPull Requestモデルが想定する規模を超えている。6.15カーネルの1リリースサイクルだけで14,612件のチェンジセットが投入され、2,068名の開発者が貢献した。このスケールでのコードレビューは、Webブラウザ上のインタフェースよりもメールクライアントのほうが効率的だという判断がある。

第二に、分散性だ。メーリングリストは特定のプラットフォームに依存しない。GitHubが落ちても、メーリングリストは機能する。カーネル開発者は自分の好みのメールクライアントで作業でき、オフラインでもメールを読みパッチをレビューできる。UNIX哲学の「テキストストリーム」原則が、ここでも生きている。

第三に、アーカイブの永続性だ。LKMLのアーカイブは1990年代から残っている。特定の設計判断がなぜ行われたのか、10年前のメールスレッドを遡って確認できる。プラットフォームの移行やサービス終了のリスクがない。

ただし、メーリングリストベースのワークフローが新規参入者にとって高いハードルであることも事実だ。`git send-email`の設定は複雑であり、メールでのパッチ投稿に慣れていない若い世代の開発者にとって、最初の一歩が困難だという指摘はLKML自身の中でも繰り返し議論されている。

---

## 4. Gitの誕生——カーネル開発が生んだ道具

### BitKeeperの時代

Linuxカーネル開発の歴史において、バージョン管理の問題は常に付きまとっていた。

Linuxの最初の10年間——1991年から2002年まで——は、パッチとtarballによる管理だった。開発者はパッチをメーリングリストに送り、Linusが手動でそれを適用する。この方法は、プロジェクトの初期には機能した。だがカーネルが巨大化し、開発者の数が増えるにつれて、パッチの管理は人間の手に負えなくなっていった。

2002年、LinusはBitKeeperを導入した。BitMover社のLarry McVoyが開発した分散型バージョン管理システムだ。商用ソフトウェアだが、オープンソース開発者には無料ライセンスが提供されていた。ただし制約があった。BitKeeperを無料で使う開発者は、競合するバージョン管理システムのプロジェクトに参加してはならない、という条件だ。

この制約は、自由ソフトウェアコミュニティの一部から批判を受けた。Richard Stallmanは、プロプライエタリなツールに依存することへの懸念を繰り返し表明した。だがLinusは実利を優先した。BitKeeperは当時最も優れた分散型VCSであり、カーネル開発の効率を劇的に改善した。

### 騒動と決裂

2005年、事態が急転する。

SambaプロジェクトのAndrew TridgellがBitKeeperのプロトコルをリバースエンジニアリングし、SourcePullerというツールを作成した。BitKeeperリポジトリからデータを取得できるツールだ。BitMover社はこれをライセンス違反と見なし、オープンソース開発者向けの無料ライセンスを撤回した。

2005年4月、Linuxカーネルの開発者たちは突如として主要なコラボレーションツールを失った。数千人の開発者が日常的に依存していたインフラが、一夜にして使えなくなった。

Linusの対応は素早かった。2005年4月3日、彼はGitの開発を開始した。既存のオープンソースVCS——CVS、Subversion——はLinusの要求を満たさなかった。分散型であること、巨大なコードベースを高速に扱えること、データの完全性を暗号学的に保証できること。これらの要件を満たすVCSを、Linusは自ら作ることにした。

Gitの最初の動作するバージョンは、開発開始から数週間で完成した。2005年6月には、LinuxカーネルのバージョンリリースがGitを使って行われるようになった。

BitKeeper騒動は、オープンソースプロジェクトがプロプライエタリなツールに依存するリスクを鮮烈に示した。だが皮肉なことに、この騒動がなければGitは生まれなかった。そしてGitは、単にLinuxカーネル開発のツールにとどまらず、ソフトウェア開発のあり方そのものを変革することになる。この経緯については、姉妹連載の「git ありきの世界に警鐘を鳴らす」で詳しく扱っている。

### バージョン番号の哲学

カーネル開発を語る上で、バージョン番号の体系にも触れておく必要がある。

Linux 2.6.0は2003年12月にリリースされ、2.6系は8年間続いた。2011年7月22日、2.6.39の次のバージョンは2.6.40ではなく、3.0としてリリースされた。技術的な革新があったからではない。マイナーバージョン番号が大きくなりすぎたから変えた——それだけの理由だ。

3.0リリース時には、古いプログラムとの互換性のためにuname26 personalityが追加された。`uname -r`が3.xを返すと動作しなくなるプログラムのために、3.xを2.6.40+xとして報告する仕組みだ。バージョン番号を変えただけで互換性の問題が生じる——この事実は、ソフトウェアの世界でバージョン番号がいかに「約束」として機能しているかを示している。

以降も同じパターンが続く。3.19の次は4.0、4.20の次は5.0。Linusは5.0のリリース時に「マイナー番号が指と足の指で数えられる20を超えたから」と冗談めかして説明した。6.0も同様だ。メジャーバージョンの増分に技術的な意味はない。6.8から6.9への変化と、5.19から6.0への変化に、質的な差はない。

この方針は、セマンティックバージョニングに慣れた多くの開発者にとって違和感があるかもしれない。だがLinusの判断は明確だ。カーネルのバージョン番号は「互換性の約束」ではなく「リリースの識別子」にすぎない。互換性はバージョン番号ではなく、ポリシーによって保証される。

---

## 5. 「安定APIなし」という設計判断

### 二つの世界——カーネル内部とユーザ空間

Linuxカーネルの開発ポリシーの中で、最も議論を呼ぶものの一つが「安定なカーネル内部APIは存在しない」という方針だ。

この方針を明文化したのは、Greg Kroah-Hartman（Linuxカーネルのstableブランチメンテナ）が執筆した「stable-api-nonsense.rst」というドキュメントだ。カーネルソースツリーのDocumentation/processディレクトリに含まれているこの文書の題名自体が、方針を端的に表している。「安定API」は「ナンセンス」だと。

だが注意が必要だ。この方針はカーネル「内部」のインタフェースに限定される。Linuxカーネルには二つの明確に異なるインタフェース層がある。

```
Linuxカーネルのインタフェース二重構造:

  ユーザ空間アプリケーション
  ─────────────────────────────
        │ syscallインタフェース
        │ （安定ABI: 後方互換性保証）
        │ open(), read(), write(), ioctl()...
  ─────────────────────────────
  カーネル空間
        │ カーネル内部API
        │ （安定性の保証なし）
        │ 内部関数、データ構造、モジュールAPI
  ─────────────────────────────
  ハードウェア

  ユーザ空間 → カーネル: 安定。壊さない。
  カーネル内部: 自由に変更可能。モジュールは再コンパイル必須。
```

**ユーザ空間ABI。** カーネルが提供するシステムコールインタフェース——`open()`, `read()`, `write()`, `close()`, `ioctl()`等——は極めて安定している。後方互換性は少なくとも2年間保証され、実際にはほぼ無期限に維持される。Linusはこの点について「ユーザ空間のプログラムを壊すことは絶対に許さない」という強い立場を取っている。10年前にコンパイルされたバイナリが最新のカーネルで動作しなくなるような変更は、カーネル側のバグとして扱われる。

**カーネル内部API。** 一方、カーネル内部の関数やデータ構造には安定性の保証がない。ローダブルカーネルモジュール（LKM）は、カーネルのバージョンが変わるたびに再コンパイルが必要になりうる。バイナリモジュールに安定したABIを提供する義務は、カーネルの側にはない。

Linusは1999年にこの方針について「バイナリモジュールだけを使う人間は、時折冷や汗をかいて目覚めるべきだ」と発言している。

### なぜ安定APIを拒否するのか

カーネル内部APIを安定させないという判断は、一見すると不便に思える。特にプロプライエタリなドライバを提供するハードウェアベンダーにとっては頭痛の種だ。NVIDIAのGPUドライバがカーネルのメジャーバージョンアップのたびに問題を起こすのは、この方針が直接的な原因だ。

だがカーネル開発者の観点からは、この方針には合理性がある。

第一に、リファクタリングの自由だ。安定APIを約束すると、内部構造の改善が困難になる。古い、非効率な、あるいはセキュリティ上問題のあるインタフェースを変更するためには、まず新しいインタフェースを作り、古いものを「非推奨」にし、移行期間を設け、最終的に古いものを削除する——この一連のプロセスが必要になる。カーネル開発者にとってこのオーバーヘッドは、内部コードの品質向上の障壁になる。

第二に、パフォーマンスの最適化だ。カーネル内部のデータ構造やアルゴリズムを最適化する際、既存のAPIに制約されると最適な実装を選べなくなることがある。安定APIの不在は、最良の実装を自由に選ぶための条件だ。

第三に、セキュリティ修正の迅速さだ。脆弱性が発見されたとき、安定APIの制約があると修正の選択肢が狭まる。内部構造を自由に変更できることは、セキュリティ対応の速度と品質を確保する上で重要だ。

この方針は、UNIX哲学の観点から見ても興味深い。「小さなツールを組み合わせる」という原則は、ツール間のインタフェースの安定性を前提としている。UNIXコマンドがパイプで連携できるのは、「テキスト行」という安定したインタフェースが存在するからだ。カーネルはユーザ空間に対してはこの原則に従う——syscallという安定したインタフェースを提供する。だがカーネル内部では、安定性よりも進化の速度を優先する。外向きの安定性と内向きの自由——この二重構造は、大規模ソフトウェアの設計判断として示唆に富む。

---

## 6. ハンズオン：Linuxカーネル開発の現場を覗く

このハンズオンでは、Linuxカーネルのソースツリーを探索し、コミットログを読み、開発プロセスの規模と構造を体感する。さらに、簡単なカーネルモジュールのコードを読み、カーネル開発の「手触り」を掴む。

### 環境構築

```bash
# Ubuntu 24.04のDocker環境を使用
docker pull ubuntu:24.04
```

### 演習1：カーネルソースツリーの構造を理解する

Linuxカーネルのソースツリーには、サブシステムごとにディレクトリが分かれている。この構造自体が、カーネルの設計を反映している。

```bash
docker run --rm ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq git > /dev/null 2>&1

echo "=== Linuxカーネルのソースツリー構造（shallow clone）==="
git clone --depth 1 https://github.com/torvalds/linux.git /tmp/linux 2>/dev/null

echo ""
echo "=== トップレベルディレクトリ ==="
ls -1 /tmp/linux/ | head -30
echo ""

echo "=== 各ディレクトリの役割 ==="
echo "arch/       -- アーキテクチャ固有のコード（x86, ARM, RISC-V等）"
echo "block/      -- ブロックI/Oレイヤー"
echo "crypto/     -- 暗号化サブシステム"
echo "drivers/    -- デバイスドライバ（全コードの約40%）"
echo "fs/         -- ファイルシステム"
echo "include/    -- ヘッダファイル"
echo "init/       -- カーネル初期化"
echo "ipc/        -- プロセス間通信"
echo "kernel/     -- コアカーネル（スケジューラ、シグナル等）"
echo "lib/        -- カーネル内ライブラリ"
echo "mm/         -- メモリ管理"
echo "net/        -- ネットワークスタック"
echo "scripts/    -- ビルドスクリプト、ツール"
echo "security/   -- セキュリティフレームワーク（SELinux, AppArmor等）"
echo "sound/      -- サウンドサブシステム"
echo "tools/      -- ユーザ空間ツール"
echo ""

echo "=== ソースコードの規模 ==="
echo "総ファイル数:"
find /tmp/linux -name "*.c" -o -name "*.h" | wc -l
echo ""
echo "ドライバのファイル数（drivers/配下）:"
find /tmp/linux/drivers -name "*.c" -o -name "*.h" | wc -l
echo ""
echo "アーキテクチャ固有のファイル数（arch/配下）:"
find /tmp/linux/arch -name "*.c" -o -name "*.h" | wc -l
echo ""

echo "=== サポートしているアーキテクチャ ==="
ls /tmp/linux/arch/
echo ""

echo "=== ファイルシステム実装 ==="
ls /tmp/linux/fs/
'
```

`drivers/`ディレクトリがカーネル全体の相当な部分を占めていることに注目してほしい。Linuxカーネルの巨大さは、カーネル「コア」の肥大化ではなく、膨大なハードウェアドライバのサポートに起因している。

### 演習2：MAINTAINERSファイルを読む

MAINTAINERSファイルは、各サブシステムの責任者を定義するカーネル開発の「組織図」だ。

```bash
docker run --rm ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq git > /dev/null 2>&1
git clone --depth 1 https://github.com/torvalds/linux.git /tmp/linux 2>/dev/null

echo "=== MAINTAINERSファイルの規模 ==="
wc -l /tmp/linux/MAINTAINERS
echo ""

echo "=== MAINTAINERSファイルの先頭（フォーマット説明） ==="
head -80 /tmp/linux/MAINTAINERS
echo ""

echo "=== ネットワークサブシステムのメンテナ情報 ==="
grep -A 10 "^NETWORKING \[GENERAL\]" /tmp/linux/MAINTAINERS || \
  grep -A 10 "^NETWORKING" /tmp/linux/MAINTAINERS | head -15
echo ""

echo "=== ext4ファイルシステムのメンテナ情報 ==="
grep -A 10 "^EXT4 FILE SYSTEM" /tmp/linux/MAINTAINERS
echo ""

echo "=== メンテナンスステータスの種類 ==="
echo "S: Supported   -- 積極的にメンテナンスされている"
echo "S: Maintained  -- メンテナがいるが限定的"
echo "S: Odd Fixes   -- 時折修正が入る程度"
echo "S: Orphan      -- メンテナ不在"
echo "S: Obsolete    -- 廃止予定"
echo ""

echo "=== ステータス別の件数 ==="
echo -n "Supported:  " && grep -c "^S:.*Supported" /tmp/linux/MAINTAINERS || echo 0
echo -n "Maintained: " && grep -c "^S:.*Maintained" /tmp/linux/MAINTAINERS || echo 0
echo -n "Odd Fixes:  " && grep -c "^S:.*Odd Fixes" /tmp/linux/MAINTAINERS || echo 0
echo -n "Orphan:     " && grep -c "^S:.*Orphan" /tmp/linux/MAINTAINERS || echo 0
echo -n "Obsolete:   " && grep -c "^S:.*Obsolete" /tmp/linux/MAINTAINERS || echo 0
'
```

MAINTAINERSファイルのエントリ構造に注目してほしい。M（メンテナのメールアドレス）、L（メーリングリスト）、S（ステータス）、F（管理対象ファイルパターン）——この構造化された記述が、カーネル開発の分散型統治の骨格だ。

### 演習3：コミットログからカーネル開発の規模を体感する

```bash
docker run --rm ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq git > /dev/null 2>&1
git clone --depth 5000 https://github.com/torvalds/linux.git /tmp/linux 2>/dev/null

cd /tmp/linux

echo "=== 直近のコミットログ（最新20件） ==="
git log --oneline -20
echo ""

echo "=== マージコミットの構造 ==="
echo "（Linusのマージコミットには、サブシステムの説明が含まれる）"
git log --merges --oneline -10
echo ""

echo "=== コミッターのドメイン別集計（直近5000コミット） ==="
echo "（どの組織から貢献があるかを示す）"
git log --format="%ae" -5000 2>/dev/null | \
  sed "s/.*@//" | sort | uniq -c | sort -rn | head -20
echo ""

echo "=== 直近5000コミットの著者数 ==="
git log --format="%an" -5000 | sort -u | wc -l
echo ""

echo "=== サブシステム別の変更頻度（直近5000コミット） ==="
echo "（どのディレクトリが最も活発に開発されているか）"
git log --pretty=format: --name-only -5000 2>/dev/null | \
  grep -v "^$" | cut -d/ -f1 | sort | uniq -c | sort -rn | head -15
'
```

コミッターのドメイン別集計に注目してほしい。intel.com、linaro.org、google.com、redhat.com、meta.com——企業ドメインが上位を占めるはずだ。2024年の統計では、企業貢献が全コミットの84.3%を占めている。Linuxカーネル開発は「ボランティアの善意」で回っているのではなく、企業が自社の利益のために開発者を投入し、その結果がオープンソースとして共有されるエコシステムなのだ。

### 演習4：カーネルモジュールのコード構造を読む

カーネルモジュールの基本的な構造を確認し、カーネル開発の「作法」を理解する。

```bash
docker run --rm ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq git > /dev/null 2>&1
git clone --depth 1 https://github.com/torvalds/linux.git /tmp/linux 2>/dev/null

echo "=== 最小のカーネルモジュールの構造 ==="
echo "（Documentation/kbuild/modules.rstから）"
echo ""
cat << "SAMPLE"
// hello.c -- 最小のカーネルモジュール
#include <linux/init.h>
#include <linux/module.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("A minimal kernel module");

static int __init hello_init(void)
{
    pr_info("Hello, kernel world!\n");
    return 0;
}

static void __exit hello_exit(void)
{
    pr_info("Goodbye, kernel world!\n");
}

module_init(hello_init);
module_exit(hello_exit);
SAMPLE
echo ""

echo "=== カーネルモジュールの要素 ==="
echo "MODULE_LICENSE(\"GPL\") -- ライセンス宣言（必須）"
echo "  GPLでないモジュールはカーネルの一部のシンボルにアクセスできない"
echo "  EXPORT_SYMBOL_GPL()で公開されたシンボルはGPLモジュール専用"
echo ""
echo "__init / __exit -- メモリ最適化のためのアノテーション"
echo "  __init: 初期化後にメモリから解放される"
echo "  __exit: モジュールが組み込みの場合はコンパイルから除外される"
echo ""
echo "pr_info() -- カーネルのログ出力関数"
echo "  printk()のラッパー。ログレベルを含む"
echo "  dmesgコマンドで確認できる"
echo ""

echo "=== 実際のドライバの例: drivers/misc/dummy-irq.c ==="
echo "（最も簡素な実用ドライバの一つ）"
head -50 /tmp/linux/drivers/misc/dummy-irq.c 2>/dev/null || \
  echo "(ファイルが見つからない場合があります)"
echo ""

echo "=== stable-api-nonsense.rstの冒頭 ==="
head -30 /tmp/linux/Documentation/process/stable-api-nonsense.rst
'
```

### 演習5：パッチの形式を理解する

カーネル開発では、パッチはメールで送信される。その形式を確認する。

```bash
docker run --rm ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq git > /dev/null 2>&1
git clone --depth 100 https://github.com/torvalds/linux.git /tmp/linux 2>/dev/null

cd /tmp/linux

echo "=== git format-patchが生成するパッチの形式 ==="
echo "（直近のコミットをパッチ形式で表示）"
git format-patch -1 --stdout HEAD~1 | head -60
echo ""
echo "..."
echo ""

echo "=== パッチ形式の要素 ==="
echo "From: -- 著者"
echo "Date: -- 日時"
echo "Subject: [PATCH] -- タイトル（サブシステムのプレフィックス付き）"
echo "--- (区切り線)"
echo "本文 -- パッチの説明、設計判断の理由"
echo "Signed-off-by: -- DCO（Developer Certificate of Origin）署名"
echo "Reviewed-by: -- レビュー済みの記録"
echo "Acked-by: -- 承認の記録"
echo "Tested-by: -- テスト済みの記録"
echo ""

echo "=== Signed-off-byの意味 ==="
echo "Signed-off-byは、開発者がDCO（Developer Certificate of Origin）に"
echo "同意していることを示す。以下を証明する:"
echo "1. 自分が書いたコードである、または"
echo "2. オープンソースライセンスで提供されたコードに基づいている"
echo "3. 適切なライセンスの下でカーネルに提出する権利がある"
echo ""
echo "これはSCO訴訟（第15回参照）の教訓から生まれた慣行であり、"
echo "カーネルに取り込まれるすべてのコードの法的な来歴を追跡可能にする。"
'
```

Signed-off-byタグに注目してほしい。これは単なる形式ではなく、法的な意味を持つ。前回（第15回）で論じたSCO訴訟の教訓から、カーネルに取り込まれるすべてのコードの来歴を追跡可能にするための仕組みだ。

---

## 7. まとめと次回予告

### この回の要点

Linuxカーネルの開発モデルは、Eric Raymondが「The Cathedral and the Bazaar」（1997年）で描いた「バザール」の理想像とは異なる実態を持つ。誰でも参加できるという意味ではバザールだが、その内部は高度に構造化されたメンテナ階層と厳格なコードレビュープロセスを持つ。自由な参加と規律ある統治の共存——これがLinuxカーネル開発の本質だ。

Raymondのエッセイは、1998年のNetscapeのソースコード公開決定に直接的な影響を与え、オープンソース運動の正当性を広く認知させた。だがLinuxカーネルの実際の開発プロセスは、「バザール」という比喩が示す以上に構造化されている。

約9〜10週間のリリースサイクルは、2週間のマージウィンドウとRCフェーズで構成される。新機能はマージウィンドウでのみ受け入れられ、以降はバグ修正に集中する。この規律が、巨大なコードベースの安定性を維持する。

サブシステムメンテナの階層構造が、4,000万行超のコードベースと年間数万のパッチを処理する基盤だ。2024年時点で約4,800名の開発者が貢献し、企業貢献が84.3%を占める。「ボランティアの善意」ではなく、企業がビジネス上の利益のために開発者を投入するエコシステムだ。

BitKeeper騒動（2005年）は、オープンソースプロジェクトがプロプライエタリツールに依存するリスクを示すと同時に、Gitという世界標準のVCSを生み出した。カーネル開発の必要性から生まれた道具が、ソフトウェア開発全体を変革した。

「安定なカーネル内部APIは存在しない」という方針は、ユーザ空間ABIの厳格な後方互換性保証と対を成す。外向きの安定性と内向きの自由——この二重構造が、巨大なコードベースの進化と安定性を両立させている。

### 冒頭の問いへの暫定回答

「世界最大のオープンソースプロジェクトは、どのように統治されているのか。」

答えは「構造化されたバザール」だ。参加は自由だが、統治は厳格。メーリングリストは誰にでも開かれているが、パッチがメインラインにマージされるまでには何重ものレビューを通過しなければならない。Linusが最終的なマージ権限を持つが、実質的な意思決定はサブシステムメンテナの階層に分散している。

この統治モデルは、意図的に設計されたものではない。LinusがLKMLで「組織図を作ろう」と宣言して始まったわけではない。25年以上の開発の中で、必要に迫られて自然に形成された構造だ。メンテナは、あるサブシステムに対して継続的に質の高い貢献をした開発者が、自然と信頼を得て任命される。信頼は付与されるのではなく、獲得される。

この「自然発生的な秩序」は、UNIX哲学の精神と呼応する。トップダウンの設計ではなく、ボトムアップの実践から生まれた構造。小さな単位（個々のサブシステム）が独立して機能し、それらが緩やかに結合して全体を構成する。パイプで繋がれたUNIXコマンドのように、各メンテナは自分の領域に責任を持ち、信頼という「インタフェース」で上位に接続される。

### 次回予告

次回は「systemd論争——UNIXの原則は死んだのか」。SysV initのシェルスクリプトベースの初期化から、systemdのバイナリデーモンへの転換。2010年にLennart PoetteringとKay Sieversが設計したsystemdは、Linuxの初期化プロセスを根本から変えた。起動の高速化、依存関係の自動解決、ジャーナルログ——技術的な利点は明らかだ。だが「PID 1の肥大化」「一つのことをうまくやれ、の否定」という批判も根強い。Debian jessieでのsystemd採択投票（2014年）はコミュニティを分裂させ、systemdを拒否するDevuanフォークまで生み出した。

systemdはUNIXの設計哲学への裏切りなのか。それとも時代に即した正当な進化なのか。この問いは、「UNIX哲学は時代を超えた普遍原則か、それとも特定の時代の産物か」という根本的な問いの表出だ。

あなたの使っているLinuxシステムのPID 1は、何が動いているだろうか。そしてそれが何であるかを、意識したことはあるだろうか。

---

## 参考文献

- Eric S. Raymond, "The Cathedral and the Bazaar", 1997年5月初発表、1999年O'Reilly Media刊: <http://www.catb.org/~esr/writings/cathedral-bazaar/>
- Wikipedia, "The Cathedral and the Bazaar": <https://en.wikipedia.org/wiki/The_Cathedral_and_the_Bazaar>
- Frank Hecker, "Setting Up Shop: The Business of Open-Source Software", in "Open Sources: Voices from the Open Source Revolution", O'Reilly, 1999: <https://www.oreilly.com/openbook/opensources/book/netrev.html>
- Linux Kernel Documentation, "How the development process works": <https://docs.kernel.org/process/2.Process.html>
- Linux Kernel Documentation, "Submitting patches": <https://docs.kernel.org/process/submitting-patches.html>
- Linux Kernel Documentation, "The Linux Kernel Driver Interface (stable-api-nonsense)": <https://docs.kernel.org/next/process/stable-api-nonsense.html>
- Linux Kernel Documentation, "Feature and driver maintainers": <https://www.kernel.org/doc/html/latest/maintainer/feature-and-driver-maintainers.html>
- Graphite Blog, "BitKeeper, Linux, and licensing disputes: How Linus wrote Git in 14 days": <https://graphite.com/blog/bitkeeper-linux-story-of-git-creation>
- Wikipedia, "BitKeeper": <https://en.wikipedia.org/wiki/BitKeeper>
- Wikipedia, "Linux Foundation": <https://en.wikipedia.org/wiki/Linux_Foundation>
- Wikipedia, "Open Source Development Labs": <https://en.wikipedia.org/wiki/Open_Source_Development_Labs>
- Wikipedia, "Linux kernel version history": <https://en.wikipedia.org/wiki/Linux_kernel_version_history>
- Greg Kroah-Hartman, "Linux kernel version numbers", 2025: <http://www.kroah.com/log/blog/2025/12/09/linux-kernel-version-numbers/>
- Phoronix, "The Linux Kernel Hit A Decade Low In 2024 For The Number Of New Commits Per Year": <https://www.phoronix.com/news/2024-Linux-Git-Stats>
- LWN.net, "Development statistics for the 6.15 kernel": <https://lwn.net/Articles/1022414/>
- Stackscale, "The Linux Kernel surpasses 40 Million lines of code": <https://www.stackscale.com/blog/linux-kernel-surpasses-40-million-lines-code/>
- LKML, Linus Torvalds, "Linux 4.19-rc4 released, an apology, and a maintainership note", 2018年9月16日: <https://lkml.org/lkml/2018/9/16/167>
- The Register, "Linux kernel's Torvalds: 'I am truly sorry' for my 'unprofessional' rants", 2018年9月17日: <https://www.theregister.com/2018/09/17/linus_torvalds_linux_apology_break/>
