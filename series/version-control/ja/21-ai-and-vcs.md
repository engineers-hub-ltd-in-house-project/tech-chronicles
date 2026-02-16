# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第21回：GitHub Copilotとgit——AIが介在するバージョン管理

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- AI支援コーディングツールの歴史——2013年のCodota（現Tabnine）から2025年のClaude Codeまで、AIがコード生成に関与するようになった経緯
- GitHub Copilotの技術的基盤——OpenAI Codexの仕組み、学習データの構成、そしてマルチモデルアーキテクチャへの進化
- AI生成コードと著作権の法的争点——2022年のクラスアクション訴訟、米国著作権局の2025年報告書、EU/米国双方の法的見解
- バージョン管理における「著者」概念の動揺——Co-authored-byトレーラーの慣習と限界、gitの帰属モデルが前提としていたもの
- AIが介在するワークフローにおけるトレーサビリティの設計——git logで追跡可能な運用の構築方法
- SLSA（Supply-chain Levels for Software Artifacts）とソフトウェア来歴追跡の動向

---

## 1. 「このコードは、誰が書いたのか」

2024年のある日、私はClaude Codeを使って、あるマイクロサービスのリファクタリングを行っていた。

ターミナルに自然言語で指示を出す。「このモジュールのエラーハンドリングを統一してほしい。既存のパターンに合わせて」。数秒後、Claude Codeが複数のファイルにわたる変更を提案する。差分を確認する。意図通りだ。承認する。変更が適用される。

私はgit diffで変更内容を確認し、git commitを実行した。コミットメッセージの末尾には自動的にこう追記されていた。

```
Co-Authored-By: Claude <noreply@anthropic.com>
```

ここで、私は手を止めた。

このコミットの「著者」は誰なのか。

git logを見れば、Author欄には私の名前がある。Co-authored-byトレーラーにはClaudeの名前がある。だが、実際のコード変更を「書いた」のはAIだ。私がやったのは、自然言語で指示を出し、生成されたコードをレビューし、承認しただけだ。

これは「私が書いたコード」なのだろうか。

バージョン管理システムは、その誕生以来、一つの前提に立っていた。コードを書くのは人間であり、コミットの著者は変更を行った人間である、という前提だ。RCSもCVSもSubversionもGitも、この前提を疑ったことはない。git blameが表示する名前は、そのコードを「書いた人間」の名前であるはずだった。

その前提が、今、揺らいでいる。

AIがコードを書く時代に、バージョン管理の「著者」概念はどう変わるべきなのか。あるいは、変わらなくてもよいのか。あなたはこの問いについて、考えたことがあるだろうか。

---

## 2. AI支援コーディングの歴史——予測から生成へ

### コード補完の始まり

AIがコードの生成に関与するようになった歴史は、多くの開発者が想像するよりも長い。

2013年、イスラエルのテルアビブで、Dror WeissとEran YahavがCodotaを設立した。Technion（イスラエル工科大学）での10年以上の学術研究に基づき、AIによるコード補完ツールを開発するためだった。2018年にJava IDE向けの初のAIベースコード補完を提供した。

同じ2018年、カナダのWaterloo大学の学生Jacob JacksonがTabnineを作成した。深層学習モデルをローカルで実行し、コード補完を提供するツールだった。2019年にCodotaがTabnineを買収し、大規模言語モデル技術を活用したコード生成へとシフトした。2021年5月、同社は社名をTabnineに変更した。

この時期のAIコーディングツールが行っていたのは、主に「予測」だった。開発者が書いているコードのパターンを読み取り、次に来るであろうコードを補完する。IDEのインテリセンスの延長線上にある技術であり、コードを「書く」主体はあくまで人間だった。AIは補助輪であり、著者ではなかった。

### GitHub Copilotの衝撃

転換点は2021年に訪れた。

2021年6月29日、GitHubはAIペアプログラマー「GitHub Copilot」のテクニカルプレビューをVisual Studio Code向けに公開した。Copilotを支えていたのはOpenAI Codex——GPT-3をベースに、54百万の公開GitHubリポジトリから収集されたソースコードでファインチューニングしたモデルだった。OpenAI Codexの正式発表（2021年8月10日）より約2か月先行しての公開だった。

Copilotが従来のコード補完ツールと決定的に異なっていたのは、その生成能力の質と量だ。数行のコメントやシグネチャから、関数全体を生成できた。自然言語のコメントから実装コードを推論できた。コードの「予測」ではなく「生成」——これが質的な転換だった。

約1年後の2022年6月21日、GitHub Copilotは一般提供（GA）を開始した。有料サブスクリプション（当初月額10ドル、年額100ドル）として提供され、個人開発者からエンタープライズまでを対象とした。

その後の普及速度は驚異的だった。2025年7月時点で、GitHub Copilotの累計利用者は2,000万人を超えた。有料サブスクライバーは130万人、導入組織は50,000以上に達し、Fortune 100企業の90%が開発ワークフローに組み込んでいる。

2023年に発表された生産性研究は、この普及を加速させた。95名のプロの開発者を対象にJavaScriptでHTTPサーバを実装するタスクを課した実験で、Copilot使用群は非使用群と比較して55.8%速くタスクを完了した（95%信頼区間: 21-89%）。使用群の平均所要時間は1時間11分、非使用群は2時間41分だった。この研究は2022年5月15日から6月20日にかけて実施され、Copilotの一般提供開始直前のタイミングだった。

```
AI支援コーディングツールの進化:

  2013         2018         2021           2022           2024           2025
  │            │            │              │              │              │
  ▼            ▼            ▼              ▼              ▼              ▼
Codota設立    Tabnine作成   Copilot        Copilot GA     Copilot        Claude Code
              (Jackson)     Preview        CodeWhisperer  Multi-Model    GA
                            Codex発表      Cursor登場     Cursor $60M    Cursor $2.3B
                                                          Universe 2024
  │            │            │              │              │              │
  └────────────┘            └──────────────┘              └──────────────┘
  「予測」の時代             「生成」の始まり              「エージェント」の時代
  ・パターン補完             ・関数全体の生成              ・自律的なコード変更
  ・IDE内で完結              ・自然言語→コード            ・マルチファイル操作
  ・著者は人間               ・著者性が曖昧に             ・AI主導の開発フロー
```

### エージェントの時代へ

2023年以降、AI支援コーディングは「生成」からさらに「エージェント」へと進化した。

2023年3月、Anysphere社がCursorをリリースした。MIT出身の4名——Michael Truell、Sualeh Asif、Arvid Lunnemark、Aman Sanger——が創業した同社は、VSCodeをフォークし、AIをエディタの中核に組み込んだ。単なるコード補完ではなく、「エージェントモード」でファイルの生成・編集・実行を自律的に行える。2025年1月にはARR（年間経常収益）1億ドルを突破し、2025年11月には23億ドルの資金調達で評価額293億ドルに達した。マーケティング費用ゼロでの急成長だったと報じられている。

2024年4月、AmazonはCodeWhispererをAmazon Q Developerに改名し、より広範なAI開発支援プラットフォームへと位置づけ直した。

2025年2月、AnthropicがClaude Codeのプレビューをリリースした。ターミナルで動作するエージェント型コーディングツールであり、コードベース全体を理解した上でファイルの作成・編集、テストの実行、gitの操作を自然言語で指示できる。2025年5月にClaude 4とともに一般提供が開始された。

2024年10月のGitHub Universe 2024では、Copilot自体がマルチモデルアーキテクチャに移行した。AnthropicのClaude 3.5 Sonnet、GoogleのGemini 1.5 Pro、OpenAIのGPT-4o/o1-preview/o1-miniを開発者が選択可能になった。2025年2月にはエージェントモード、5月にはコーディングエージェント（クラウド上で自律的にタスクを実行しPull Requestを作成するモード）が発表された。

この変遷において注目すべきは、AIの役割が段階的に拡大してきたことだ。

第一段階では、AIはIDEの中で行の続きを予測する補助ツールだった。キーボードを叩いているのは人間であり、AIの提案を採用するかどうかも人間が判断していた。

第二段階では、AIが関数やクラス全体を生成するようになった。人間がコメントやシグネチャで意図を伝え、AIがそれを実装する。人間は「レビューア」の役割に近づいた。

第三段階——現在——では、AIがエージェントとして複数ファイルにまたがる変更を自律的に行い、テストを実行し、gitにコミットする。人間は「指示者」であり「承認者」だ。

この変遷は、バージョン管理の「著者」概念に対して、段階的に圧力をかけてきた。第一段階では問題にならなかった。第二段階では曖昧さが生じた。第三段階では、問題が顕在化している。

---

## 3. バージョン管理の「著者」概念が前提としていたもの

### gitの帰属モデル

gitのコミットには、二つの「名前」が記録される。AuthorとCommitterだ。

```bash
git log --format='Author:    %an <%ae>%nCommitter: %cn <%ce>%nDate:      %ai%nMessage:   %s' -1
```

典型的な出力はこうなる。

```
Author:    Yusuke Sato <yusuke@example.com>
Committer: Yusuke Sato <yusuke@example.com>
Date:      2026-02-15 14:30:00 +0900
Message:   Refactor error handling in auth module
```

Authorは変更を「作成した人」、Committerはそのコミットを「リポジトリに適用した人」だ。多くの場合、両者は同一人物であり、区別を意識する必要はない。だが、git format-patchとgit amでパッチを適用する場合や、git cherry-pickを行う場合には両者が異なりうる。Linuxカーネルの開発ワークフローでは、パッチの作成者（Author）とそれをマージした管理者（Committer）が異なることが日常的だった。

ここで重要なのは、gitの帰属モデルが暗黙に前提としていたことだ。

第一に、AuthorもCommitterも「人間」であるという前提。gitは名前とメールアドレスをフリーテキストとして受け付けるため、技術的にはどんな文字列でも設定できる。だが、設計意図としては人間を想定していた。git blameが表示する名前は、「この行を最後に変更した人間の名前」であり、責任の所在を示すものだった。

第二に、Authorが変更の「知的創作者」であるという前提。コードを書くという行為は知的活動であり、Author欄はその活動の主体を記録する。コードレビューを通じて変更が改善されたとしても、Authorはコードを実際に書いた人間の名前のままだ。レビューアの貢献は、コミットメッセージのReviewed-byトレーラーで記録されることはあるが、Authorにはならない。

第三に、一つのコミットに対して一人のAuthorが対応するという前提。gitの設計上、一つのコミットには一つのAuthorフィールドしかない。ペアプログラミングで二人が協同してコードを書いた場合でも、git commitのAuthorは一人だけだ。

### Co-authored-byの登場と限界

この第三の前提に対する最初の「パッチ」が、Co-authored-byトレーラーだった。

Co-authored-byは、gitの公式仕様ではない。GitHubが導入した慣習だ。コミットメッセージの末尾に`Co-authored-by: Name <email>`という行を追加すると、GitHubのWeb UIがこれをパースし、コミットに複数の著者を表示する。GitLabも同様のパースに対応している。

```
Refactor error handling in auth module

Unified exception handling across all API endpoints.
Applied consistent logging patterns.

Co-authored-by: Alice <alice@example.com>
Co-authored-by: Bob <bob@example.com>
```

この仕組みは、ペアプログラミングやモブプログラミングの文脈で生まれた。複数の人間が協同してコードを書いた場合に、全員の貢献を記録するための仕組みだ。

しかし、Co-authored-byは本質的に「自己申告」である。誰がどの部分をどの程度書いたかは記録されない。全員が等しく貢献したのか、一人が主に書いて他の人はレビューしただけなのか——その区別はない。

そして今、この仕組みがAIの帰属表示に転用されている。

```
Refactor error handling in auth module

Co-Authored-By: Claude <noreply@anthropic.com>
```

この記法が意味するものは何だろうか。Claudeは「共著者」なのだろうか。Claudeがコードの大部分を生成し、人間はレビューしただけの場合と、人間がコードを書きCopilotが数行を補完した場合と、同じCo-authored-byトレーラーで記録される。貢献の度合いは区別されない。

さらに根本的な問題がある。Co-authored-byのメールアドレス`noreply@anthropic.com`は、実在のアカウントに紐づいていない。GitHubのコントリビューションカウンターにClaudeは現れない。Co-authored-byは人間のコラボレーションを想定して設計された仕組みであり、AIの帰属表示のために設計されたものではない。

### git blameの意味が変わる

git blameを考えてみよう。

git blameは、ファイルの各行について、最後にその行を変更したコミットの情報を表示する。Author名、コミットハッシュ、日時が行ごとに表示される。

```bash
git blame src/auth/handler.ts
```

```
a1b2c3d4 (Yusuke Sato  2026-02-15) export async function handleAuth(req: Request) {
a1b2c3d4 (Yusuke Sato  2026-02-15)   const token = extractToken(req);
a1b2c3d4 (Yusuke Sato  2026-02-15)   if (!token) {
a1b2c3d4 (Yusuke Sato  2026-02-15)     throw new AuthError('TOKEN_MISSING', 'No token provided');
a1b2c3d4 (Yusuke Sato  2026-02-15)   }
```

Author欄には私の名前がある。だが、このコードを実際に「書いた」のはClaude Codeだ。私は指示を出し、生成結果をレビューし、承認しただけだ。

git blameは元来、「このコードの責任者は誰か」を問うためのツールだった。バグが見つかったとき、誰に聞けばそのコードの意図がわかるのか。誰がそのコードの変更理由を説明できるのか。git blameは、その問いに対する答えを提供していた。

AIが介在する場合、git blameの情報は何を意味するのだろうか。

私の名前がAuthor欄にある以上、私がそのコードに対する責任を持つ——この解釈は、ある意味では正しい。私が指示を出し、レビューし、承認した。問題があれば私が対応すべきだ。

だが、コードの「意図」を説明できるかどうかは別の問題だ。AIが生成したコードの一行一行について、なぜそう書かれたのかを私は説明できるだろうか。AIの推論過程は私には見えない。同じ指示を出しても、異なるコードが生成されることもある。コードの「理由」がAuthorの頭の中にない——これは、git blameが暗黙に前提としていた世界とは異なる。

---

## 4. 学習データの著作権と法的争点

### Copilot訴訟——オープンソースとAIの衝突

GitHub Copilotの普及は、技術的な議論だけでなく、法的な争点も引き起こした。

2022年11月、プログラマー兼弁護士のMatthew Butterickが、GitHub、Microsoft、OpenAIを相手にクラスアクション訴訟を提起した。訴訟の核心は、Copilotの学習データとして使用された公開GitHubリポジトリのコードに付されていたオープンソースライセンスの帰属表示（attribution）が、Copilotの出力において省略されている——という主張だった。

多くのオープンソースライセンス（MIT、Apache 2.0、GPL等）は、コードの再利用時にライセンス表示と著作権表示を含めることを要求する。MITライセンスの条件は明確だ。「上記の著作権表示および本許諾表示を、ソフトウェアのすべてのコピーまたは重要な部分に含めなければならない」。Copilotが学習データから派生したコードを出力する際、元のライセンス表示は含まれない。この点が法的に問題になりうるかが争点だった。

カリフォルニア北部地区連邦地裁のJon Tigar判事は、2023年5月に判断を下した。当初の22の請求のうち20が棄却された。著作権侵害の請求は、コピーされたコードの具体的な事例が示されていないことを理由に棄却された。存続したのは契約違反とDMCA（デジタルミレニアム著作権法）違反の2件のみだった。その後、2024年7月にはDMCA 1202(b)条項違反の請求も棄却された。

2024年10月、原告は第九巡回区控訴裁判所に上訴許可を申請した。2026年2月現在、訴訟は係属中である。

この訴訟は、最終的な判決がどうなるにせよ、重要な問いを提起した。AIモデルが公開されたコードから「学習」する行為は、著作権法上の「複製」にあたるのか。AIが生成したコードは、学習データの「派生物」なのか。オープンソースライセンスの帰属要件は、AI経由の出力にも適用されるのか。

これらの問いは、バージョン管理の文脈に直結する。gitリポジトリに格納されたオープンソースコードが、AIの学習データとして使われ、AIが生成したコードが別のgitリポジトリにコミットされる。このサイクルにおいて、元のコードの著作権とライセンスはどこに帰属するのか。gitの世界では、ライセンスファイルはリポジトリのルートに置かれ、すべてのコードに適用される。だが、AIが生成したコードの「出自」は、git logには記録されていない。

### AI生成コードの著者性——法的見解の現在地

AI生成コードの著作権に関する法的見解は、2024-2025年にかけて各国で明確化が進んだ。

米国では、Thaler v. Perlmutter判決（D.C.巡回区）において、AI生成物は人間の実質的な知的関与なしには著作権保護を受けられないことが確認された。米国著作権局の2025年報告書「Copyright and Artificial Intelligence」は、AIへのプロンプト入力だけでは創作的著者性に不十分との見解を示した。報告書は「AIシステムは予測不能であり、同じプロンプトから異なる出力が生成されうる」ことを理由に挙げている。

EUでも類似の方向性が示されている。2024年12月の加盟国政策質問書では、AI生成コンテンツは「創作過程における人間の関与が重大な場合にのみ」著作権保護の対象となるとする見解が多数を占めた。

両法域に共通するのは、「人間の実質的な関与」を著作権保護の条件とする立場だ。

この法的見解は、開発の現場にとって実務的な意味を持つ。AIが生成したコードに著作権が認められない場合、そのコードはパブリックドメインに近い状態になる。企業が開発したプロプライエタリソフトウェアの一部がAI生成コードで構成されている場合、その部分には著作権による保護が及ばない可能性がある。

逆に、AIが既存のコード（特にコピーレフトライセンスのコード）から学習し、類似したコードを出力した場合、そのコードは元のライセンスの影響を受けるのか。この問いには、まだ明確な答えがない。

gitのコミットログには、コードの著者名とコミットメッセージが記録される。だが、そのコードがAIによって生成されたものか、人間が一行一行書いたものかは区別されない。法的な帰属とgitの帰属は異なるレイヤーの話だが、gitリポジトリが「証拠」として参照される場面（ライセンスコンプライアンスの監査、知的財産権の主張）において、この区別の不在は問題になりうる。

---

## 5. トレーサビリティの設計——AIが介在するワークフローをどう記録するか

### 現状のアプローチとその限界

AIが介在する開発ワークフローのトレーサビリティを確保するために、現在いくつかのアプローチが採られている。

**1. Co-authored-byトレーラー**

前述の通り、AIツールが自動的にCo-authored-byトレーラーをコミットメッセージに付与する方式。Claude Codeは`Co-Authored-By: Claude <noreply@anthropic.com>`を、GitHub Copilotのコーディングエージェントは`Co-authored-by: copilot-swe-agent`を付与する。

利点は、既存のgitの仕組みの上で動作するため、追加のインフラが不要なことだ。git logで検索可能であり、GitHub/GitLabのUIでも表示される。

限界は多い。AIの「貢献度」が記録されない。コードの何パーセントがAI生成なのか、どの行がAI生成なのかは不明だ。また、Co-authored-byはコミット単位であり、行単位の帰属情報は持たない。

**2. コミットメッセージでの明示**

AIの関与をコミットメッセージの本文に記述する方式。

```
Refactor error handling in auth module

Generated by Claude Code with manual review.
Changes: unified exception types, added structured logging.
Human modifications: adjusted error messages for i18n compatibility.
```

この方式は、AIの関与の詳細を自由記述できるため、情報量は多い。だが、構造化されていないため、機械的な解析には向かない。また、記述するかどうか、何を記述するかは開発者に委ねられ、一貫性を保つのが難しい。

**3. gitのnotesやカスタムトレーラー**

git notesを使ってコミットにメタデータを付与する方式や、独自のトレーラー（例: `AI-Tool: claude-code@1.0`, `AI-Contribution: high`）を定義する方式が模索されている。

```
Refactor error handling in auth module

AI-Tool: claude-code/1.0.23
AI-Model: claude-sonnet-4-5-20250929
AI-Prompt-Summary: Unify error handling across auth module
Human-Review: approved
Co-Authored-By: Claude <noreply@anthropic.com>
```

この方式は構造化されており、機械的な解析が可能だ。だが、標準化されておらず、ツール間・組織間での互換性がない。gitのトレーラーはフリーフォーマットであり、キー名の規約は存在しない。

### ソフトウェアサプライチェーンとの接点

AIが生成したコードのトレーサビリティの問題は、より広い文脈——ソフトウェアサプライチェーンセキュリティ——の中に位置づけることができる。

SLSA（Supply-chain Levels for Software Artifacts）は、OpenSSFが策定したソフトウェアサプライチェーンのセキュリティフレームワークだ。SLSAは「来歴（provenance）」——ソフトウェアアーティファクトがどこで、いつ、どのように生成されたかの検証可能な記録——を中心的な概念に据えている。

SLSAのv1.1は、段階的なセキュリティレベル（Level 0〜3）を定義する。Level 1は来歴の文書化を要求し、Level 2はビルドシステムのソース認識と改ざん防止の署名を要求する。Level 3はビルド定義のソース由来性と堅牢化されたCIプロセスを要求する。

現時点のSLSAは、主にビルドプロセスとアーティファクトの来歴に焦点を当てており、ソースコードの作成過程（誰が、あるいは何がコードを書いたか）までは対象としていない。だが、AIが生成したコードがソフトウェアサプライチェーンの一部を構成するようになると、コードの来歴——そのコードはAIによって生成されたのか、どのモデル・バージョンで生成されたのか、どのようなプロンプトから生成されたのか——が、サプライチェーンの完全性にとって重要な情報になる。

AIサプライチェーンセキュリティへのSLSAの適用は、Googleを含む複数の組織が検討を始めている。データポイズニング（学習データの汚染）やモデル改ざんのリスクに対して、来歴追跡が有効な防御策になりうるためだ。

```
ソフトウェアの「来歴」——現在と将来:

  現在のSLSAが対象とする範囲:
  ┌─────────────────────────────────────────────┐
  │                                             │
  │  ソースコード → ビルド → アーティファクト    │
  │  (Git repo)     (CI/CD)   (バイナリ/コンテナ)│
  │                                             │
  │  来歴: どのソースから、どのビルドで生成？    │
  └─────────────────────────────────────────────┘

  AIが介在する場合に必要になる拡張:
  ┌─────────────────────────────────────────────┐
  │                                             │
  │  プロンプト → AI生成 → コード → ビルド → ...│
  │  (指示)       (Model)   (Git)    (CI/CD)    │
  │                                             │
  │  来歴: 誰の指示で、どのモデルで、           │
  │        どのバージョンで生成？                │
  │        人間のレビューは経たか？              │
  └─────────────────────────────────────────────┘
```

### gitが記録していないもの

ここまでの議論をまとめると、AIが介在する開発ワークフローにおいて、gitが記録していないものが明確になる。

第一に、コードの「生成方法」。そのコードが手書きなのか、AIが生成したのか、AIが生成した後に人間が修正したのか。gitのコミットにはこの区別がない。

第二に、AIの「モデルとバージョン」。Claude Sonnet 4.5で生成されたコードとGPT-4oで生成されたコードは、同じ指示に対して異なる出力を生成しうる。だが、どのモデルが使われたかはコミットに記録されない。

第三に、「プロンプト」。AIに対してどのような指示が与えられたか。コードの「なぜ」を理解するためには、プロンプトの情報が重要だが、gitには記録されない。

第四に、人間の「レビューの深度」。AIが生成したコードを人間が詳細にレビューしたのか、差分を流し見しただけで承認したのか。この違いはコードの品質に直結するが、gitには記録されない。

gitは1970年代のSCCS以来続いてきた「人間がコードを書く」前提の上に設計されている。この前提が崩れたとき、gitの帰属モデルでは十分に表現できない情報が生じる。問題は、この情報がなくても開発は回るのか、それともいずれ必要になるのか——という点にある。

あなたの開発チームでは、AIが生成したコードをどのように記録しているだろうか。Co-authored-byトレーラーだけで十分だと考えているだろうか。

---

## 6. ハンズオン：AI支援開発のワークフローをgitで追跡可能にする

このハンズオンでは、AI支援開発におけるコードの帰属情報をgitで追跡可能にする仕組みを構築する。Co-authored-byトレーラーの仕組みを理解し、カスタムトレーラーによるメタデータの記録、git logを使った解析手法を体験する。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y git
```

### 演習1：gitトレーラーの基本

```bash
WORKDIR="${HOME}/vcs-handson-21"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=== 演習1: gitトレーラーの基本 ==="
echo ""

# gitの設定
git config --global user.email "developer@example.com"
git config --global user.name "Developer"
git config --global init.defaultBranch main

# リポジトリを作成
git init --quiet ai-workflow-repo
cd ai-workflow-repo

# 手書きのコードをコミット（従来のワークフロー）
cat > app.py << 'PYEOF'
def hello():
    return "Hello, World!"
PYEOF

git add app.py
git commit --quiet -m "Add hello function (hand-written)"

# git logでAuthor情報を確認
echo "--- 従来のコミット ---"
git log --format='Author:  %an <%ae>%nMessage: %s%n' -1
echo ""

# Co-authored-byトレーラー付きのコミット（AI協同作業）
cat > app.py << 'PYEOF'
def hello(name: str = "World") -> str:
    """Generate a greeting message."""
    if not name or not name.strip():
        raise ValueError("Name cannot be empty")
    return f"Hello, {name.strip()}!"
PYEOF

git add app.py
git commit --quiet -m "$(cat <<'EOF'
Enhance hello function with validation and type hints

Added parameter validation and type annotations.

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

echo "--- AI協同作業のコミット ---"
git log --format='Author:  %an <%ae>%nMessage: %s%n%b' -1
echo ""

# git interpret-trailersでトレーラーを解析
echo "--- トレーラーの解析 ---"
git log --format='%B' -1 | git interpret-trailers --parse
echo ""
echo "-> Co-authored-byはgitのトレーラー機構で解析可能"
echo "   ただし、AIの貢献度や生成方法は記録されていない"
```

### 演習2：カスタムトレーラーによるAIメタデータの記録

```bash
echo ""
echo "=== 演習2: カスタムトレーラーによるAIメタデータの記録 ==="
echo ""

cd "${WORKDIR}/ai-workflow-repo"

# AIメタデータをカスタムトレーラーで記録するコミット
cat > auth.py << 'PYEOF'
import hashlib
import secrets

def generate_token(user_id: str) -> str:
    """Generate a secure authentication token."""
    random_bytes = secrets.token_bytes(32)
    payload = f"{user_id}:{random_bytes.hex()}"
    return hashlib.sha256(payload.encode()).hexdigest()

def validate_token(token: str) -> bool:
    """Validate token format."""
    if not token or len(token) != 64:
        return False
    try:
        int(token, 16)
        return True
    except ValueError:
        return False
PYEOF

git add auth.py

# 構造化されたトレーラーでAIの関与を詳細に記録
git commit --quiet -m "$(cat <<'EOF'
Add authentication token generation and validation

Implemented secure token generation using secrets module
and SHA-256 hashing. Token validation checks format and
hex encoding.

AI-Tool: claude-code/1.0
AI-Model: claude-sonnet-4-5
AI-Contribution: high
Human-Review: detailed
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

echo "--- カスタムトレーラー付きコミット ---"
git log --format='%B' -1
echo ""

# トレーラーを解析
echo "--- 全トレーラーの解析 ---"
git log --format='%B' -1 | git interpret-trailers --parse
echo ""

echo "-> AI-Tool, AI-Model, AI-Contribution, Human-Reviewなどの"
echo "   カスタムトレーラーでAIの関与を構造化して記録できる"
echo "   ただし、これは標準化されておらず、組織ごとの規約に依存する"
```

### 演習3：git logによるAI関与の分析

```bash
echo ""
echo "=== 演習3: git logによるAI関与の分析 ==="
echo ""

cd "${WORKDIR}/ai-workflow-repo"

# さらにいくつかのコミットを追加（混在ワークフロー）
cat > config.py << 'PYEOF'
import os

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///app.db")
DEBUG = os.getenv("DEBUG", "false").lower() == "true"
PYEOF
git add config.py
git commit --quiet -m "Add configuration module (hand-written)"

cat > utils.py << 'PYEOF'
from datetime import datetime, timezone

def now_utc() -> datetime:
    return datetime.now(timezone.utc)

def format_iso(dt: datetime) -> str:
    return dt.isoformat()
PYEOF
git add utils.py
git commit --quiet -m "$(cat <<'EOF'
Add utility functions for datetime handling

AI-Tool: copilot
AI-Contribution: medium
Co-Authored-By: GitHub Copilot <noreply@github.com>
EOF
)"

cat > test_app.py << 'PYEOF'
from app import hello

def test_hello_default():
    assert hello() == "Hello, World!"

def test_hello_with_name():
    assert hello("Alice") == "Hello, Alice!"

def test_hello_strips_whitespace():
    assert hello("  Bob  ") == "Hello, Bob!"
PYEOF
git add test_app.py
git commit --quiet -m "$(cat <<'EOF'
Add tests for hello function

AI-Tool: claude-code/1.0
AI-Model: claude-sonnet-4-5
AI-Contribution: high
Human-Review: detailed
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

echo "--- 全コミット履歴 ---"
git log --oneline
echo ""

# AI関与のあるコミットを抽出
echo "--- AI関与のあるコミット（Co-authored-byで検索）---"
git log --all --grep="Co-Authored-By" --oneline
echo ""

# AIツール別の集計
echo "--- AIツール別の集計 ---"
echo "Claude Code:"
git log --all --grep="AI-Tool: claude-code" --oneline
echo ""
echo "GitHub Copilot:"
git log --all --grep="AI-Tool: copilot" --oneline
echo ""
echo "手書き（AIトレーラーなし）:"
git log --all --invert-grep --grep="Co-Authored-By" --oneline
echo ""

# 比率の計算
TOTAL=$(git rev-list --count HEAD)
AI_COMMITS=$(git log --all --grep="Co-Authored-By" --oneline | wc -l)
HUMAN_ONLY=$((TOTAL - AI_COMMITS))

echo "--- AI関与の比率 ---"
echo "全コミット数:       ${TOTAL}"
echo "AI関与あり:         ${AI_COMMITS}"
echo "手書きのみ:         ${HUMAN_ONLY}"
echo ""
echo "-> git logのgrep機能でAI関与を追跡できる"
echo "   ただし、トレーラーの記述が一貫していることが前提"
```

### 演習4：git blameとAI帰属の可視化

```bash
echo ""
echo "=== 演習4: git blameとAI帰属の可視化 ==="
echo ""

cd "${WORKDIR}/ai-workflow-repo"

echo "--- app.pyのgit blame ---"
git blame app.py
echo ""

echo "--- 各行のコミットメッセージを表示 ---"
# 各行のコミットハッシュを取得し、トレーラーの有無を確認
git blame --porcelain app.py | grep "^[0-9a-f]\{40\}" | sort -u | while read hash rest; do
    MSG=$(git log --format='%s' -1 "${hash}")
    HAS_AI=$(git log --format='%B' -1 "${hash}" | grep -c "Co-Authored-By" || true)
    if [ "${HAS_AI}" -gt 0 ]; then
        echo "  ${hash:0:7}: [AI] ${MSG}"
    else
        echo "  ${hash:0:7}: [Human] ${MSG}"
    fi
done
echo ""

echo "-> git blameのAuthor欄は常に人間の名前を表示する"
echo "   AI関与の有無はコミットメッセージのトレーラーから推定する必要がある"
echo "   行単位でのAI帰属は、現在のgitの仕組みでは記録できない"
```

### 演習5：commit-msg hookによるトレーラーの自動検証

```bash
echo ""
echo "=== 演習5: commit-msg hookによるトレーラーの自動検証 ==="
echo ""

cd "${WORKDIR}/ai-workflow-repo"

# commit-msg hookを作成
# AIツールが関与したコミットにトレーラーが含まれていることを検証する
mkdir -p .git/hooks
cat > .git/hooks/commit-msg << 'HOOKEOF'
#!/bin/bash
# commit-msg hook: AI関与トレーラーの検証
#
# Co-Authored-By トレーラーが存在する場合、
# AI-Tool トレーラーも存在することを要求する

COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Co-Authored-Byの存在を確認
HAS_COAUTHOR=$(echo "$COMMIT_MSG" | grep -ci "Co-Authored-By" || true)
HAS_AI_TOOL=$(echo "$COMMIT_MSG" | grep -ci "AI-Tool" || true)

if [ "$HAS_COAUTHOR" -gt 0 ] && [ "$HAS_AI_TOOL" -eq 0 ]; then
    echo ""
    echo "[WARN] Co-Authored-By trailer detected but AI-Tool trailer is missing."
    echo "       Please add AI-Tool trailer to identify the AI tool used."
    echo "       Example: AI-Tool: claude-code/1.0"
    echo ""
    echo "       Commit will proceed, but consider adding AI-Tool for traceability."
    echo ""
fi

exit 0
HOOKEOF
chmod +x .git/hooks/commit-msg

echo "--- commit-msg hookを設定 ---"
echo "AI関与のあるコミットにAI-Toolトレーラーが含まれていない場合に警告する"
echo ""

# hookが動作するコミットを実行
cat > logger.py << 'PYEOF'
import logging

def setup_logger(name: str) -> logging.Logger:
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    ))
    logger.addHandler(handler)
    return logger
PYEOF
git add logger.py

echo "--- AI-Toolトレーラーなしのコミット（警告あり）---"
git commit --quiet -m "$(cat <<'EOF'
Add logging utility

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
echo ""

echo "--- AI-Toolトレーラーありのコミット（警告なし）---"
cat >> logger.py << 'PYEOF'

def get_logger(name: str) -> logging.Logger:
    return logging.getLogger(name)
PYEOF
git add logger.py
git commit --quiet -m "$(cat <<'EOF'
Add get_logger convenience function

AI-Tool: claude-code/1.0
AI-Contribution: low
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
echo ""

echo "-> commit-msg hookでトレーラーの一貫性を自動検証できる"
echo "   組織のルールに合わせてhookをカスタマイズすることで"
echo "   AI関与のトレーサビリティを強制できる"
```

### 演習で見えたこと

五つの演習を通じて、AI支援開発におけるバージョン管理のトレーサビリティについて体験した。

演習1では、Co-authored-byトレーラーの基本を確認した。gitのトレーラー機構（git interpret-trailers）で解析可能だが、AIの貢献度や生成方法といった詳細情報は記録されない。

演習2では、AI-Tool、AI-Model、AI-Contribution、Human-Reviewといったカスタムトレーラーを定義し、AIの関与をより詳細に記録する方法を試した。構造化された情報が記録できるが、標準化されていないため、組織ごとの規約に依存する。

演習3では、git logのgrep機能を使って、AI関与のあるコミットを抽出・集計する方法を確認した。トレーラーの記述が一貫していれば、リポジトリ全体のAI関与の比率を把握できる。

演習4では、git blameがAI帰属をどのように表示するか（あるいは表示しないか）を確認した。git blameのAuthor欄は常に人間の名前を表示し、AI関与の有無はコミットメッセージから推定するしかない。行単位のAI帰属は、現在のgitの仕組みでは記録できない。

演習5では、commit-msg hookを使って、AIが関与したコミットにトレーラーが含まれていることを自動的に検証する仕組みを構築した。gitのhook機構を活用すれば、組織のルールに合わせたトレーサビリティの強制が可能だ。

これらの演習で明らかになったのは、gitの既存の仕組み——トレーラー、grep、hook——を組み合わせることで、ある程度のトレーサビリティは確保できるということだ。だが同時に、「行単位のAI帰属」「プロンプトの記録」「モデルの推論過程の保存」といった、gitが設計上想定していなかった情報は記録できないことも明らかになった。

---

## 7. まとめと次回予告

### この回の要点

第一に、AI支援コーディングツールは「予測」（2013年〜、Codota/Tabnine）から「生成」（2021年〜、GitHub Copilot/Codex）を経て「エージェント」（2023年〜、Cursor/Claude Code）へと進化した。この進化は、AIがコード生成に関与する度合いを段階的に拡大し、バージョン管理の「著者」概念に圧力をかけてきた。

第二に、gitの帰属モデル（Author/Committer）は、コードを書く主体が人間であることを暗黙の前提としている。Co-authored-byトレーラーはペアプログラミングの文脈で生まれた慣習であり、AIの帰属表示に転用されているが、貢献度の区別や行単位の帰属記録はできない。

第三に、GitHub Copilotの学習データを巡るクラスアクション訴訟（2022年11月提起）は、オープンソースライセンスの帰属要件がAI経由の出力に適用されるかという未解決の問いを提起した。米国著作権局の2025年報告書と米国・EUの法的見解は、AI生成物の著作権保護に人間の実質的関与を要求する方向で収斂している。

第四に、AI支援開発のトレーサビリティ確保には、Co-authored-byトレーラー、カスタムトレーラー（AI-Tool、AI-Model等）、commit-msg hookによる検証、git logによる分析を組み合わせるアプローチが現時点では実用的だ。ただし、標準化されておらず、行単位のAI帰属やプロンプトの記録はgitの設計上の制約で対応できない。

第五に、SLSA（Supply-chain Levels for Software Artifacts）に代表されるソフトウェアサプライチェーンの来歴追跡は、現時点ではビルドプロセスに焦点を当てているが、AIが生成したコードの来歴追跡への拡張が今後の課題として浮上している。

### 冒頭の問いへの暫定回答

AIがコードを書く時代、「誰が書いたか」をバージョン管理はどう記録するのか。

現時点の答えは、「不完全にしか記録できない」だ。

gitは人間がコードを書くことを前提に設計されたシステムであり、AIの関与を記録するネイティブな仕組みを持たない。Co-authored-byトレーラーやカスタムトレーラーで一定の情報は記録できるが、コードの各行がAI生成なのか手書きなのか、どのモデルのどのバージョンで生成されたのか、どのようなプロンプトが使われたのか——これらの情報はgitの設計が想定していなかった領域にある。

しかし、この「不完全さ」をどう評価するかは、立場によって異なる。

実務の観点からは、現状のCo-authored-byトレーラーと組織内ルールの組み合わせで十分に機能しているケースが多い。AIが生成したコードも、最終的にはレビューし承認した人間が責任を持つ。git blameに人間の名前が表示されることは、責任の所在を明確にするという意味では合理的だ。

法的・コンプライアンスの観点からは、不完全さが問題になりうる。ライセンス監査やセキュリティ監査の文脈で、コードの出自を証明する必要が生じたとき、gitのログだけでは不十分な場面が出てくるかもしれない。

技術的な観点からは、gitの帰属モデルを拡張するか、gitの外側で追加のメタデータを管理するか——いずれかのアプローチが必要になるだろう。だが、どちらのアプローチが適切かは、まだ答えが出ていない。

### 次回予告

**第22回「gitの限界——次世代VCSへの要求仕様」**

次回は、gitの限界を直視する。第15回から第18回でgitの内部構造とトレードオフを論じ、第19回から今回まででgitを取り巻くエコシステムの変化を追ってきた。次回は、これらの議論を踏まえ、gitを「超える」ために何が必要なのかを考える。Pijul（パッチ理論ベース）、Jujutsu（Google）、Sapling（Meta）——次世代VCSの試みから、バージョン管理の未解決問題を整理する。

Gitは24年間にわたって改良を重ねてきた。その間に蓄積された設計上の制約と、変化し続ける開発環境との間に、どのような摩擦が生じているのか。あなたはgitに何を求め、何を諦めているだろうか。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Wikipedia, "GitHub Copilot." <https://en.wikipedia.org/wiki/GitHub_Copilot>
- Wikipedia, "OpenAI Codex." <https://en.wikipedia.org/wiki/OpenAI_Codex>
- Wikipedia, "Tabnine." <https://en.wikipedia.org/wiki/Tabnine>
- Wikipedia, "Cursor (code editor)." <https://en.wikipedia.org/wiki/Cursor_(code_editor)>
- Peng, S., Kalliamvakou, E., Cihon, P., Demirer, M. "The Impact of AI on Developer Productivity: Evidence from GitHub Copilot." arXiv:2302.06590, 2023. <https://arxiv.org/abs/2302.06590>
- TechCrunch, "GitHub Copilot crosses 20M all-time users." 2025-07-30. <https://techcrunch.com/2025/07/30/github-copilot-crosses-20-million-all-time-users/>
- GitHub Newsroom, "Universe 2024: GitHub Embraces Developer Choice with Multi-Model Copilot." 2024-10. <https://github.com/newsroom/press-releases/github-universe-2024>
- Joseph Saveri Law Firm, "GitHub Copilot Intellectual Property Litigation." <https://www.saverilawfirm.com/our-cases/github-copilot-intellectual-property-litigation>
- European Parliament Briefing, "Copyright of AI-generated works: Approaches in the EU and beyond." 2025. <https://www.europarl.europa.eu/thinktank/en/document/EPRS_BRI(2025)782585>
- Anthropic, "Introducing the Model Context Protocol." 2024-11. <https://www.anthropic.com/news/model-context-protocol>
- GitHub Docs, "Creating a commit with multiple authors." <https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors>
- SLSA, "Supply-chain Levels for Software Artifacts." <https://slsa.dev/>
- Google Cloud Blog, "Same same but also different: Google guidance on AI supply chain security." <https://cloud.google.com/transform/same-same-but-also-different-google-guidance-ai-supply-chain-security/>
