# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第22回：AI+CLI――Claude Code, GitHub Copilot CLI, 自然言語シェルの時代

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 自然言語でコンピュータを操作する試みの歴史的起源――1970年のSHRDLUから2025年のLLMベースCLIツールまでの系譜
- GitHub Copilot in the CLI（2023年）、Warp AI（2023年）、Claude Code（2025年）など、AI+CLIツールの登場と設計思想の違い
- LLMベースのコマンド生成が持つ構造的な限界――ハルシネーション、コンテキスト依存性、セキュリティリスク
- Model Context Protocol（MCP）がAIとCLIツールの統合にもたらした変化
- 「AIがCLIを不要にする」のではなく「AIがCLIをアクセシブルにする」という構造的関係

---

## 1. AIが生成したコマンドを、誰が監査するのか

2025年の春、私はClaude Codeをリサーチプレビューとして触り始めた。日常の開発タスクをターミナルから自然言語で指示する体験は、率直に言って衝撃的だった。

「このディレクトリの中で、最近1週間以内に変更されたTypeScriptファイルだけを一覧にしてくれ」

私がそう打つと、Claude Codeは即座に`find`コマンドを組み立てた。`-name "*.ts"`、`-mtime -7`、適切なディレクトリパスの指定。パイプで`sort`に繋ぎ、見やすい形に整えて返してくる。第7回で語ったパイプの組み合わせ、第8回で語ったテキスト処理ツールの系譜、第9回で語った正規表現――これらを自然言語の裏側で組み立てている。

だが、私はここで立ち止まった。

Claude Codeが生成したコマンドの中に、`-mtime -7`という`find`のオプションがある。これは「7日以内に変更された」ファイルを意味する。正しい。だが、もしこれが`-mtime 7`（ハイフンなし）だったら、意味は「ちょうど7日前に変更された」に変わる。`-mtime +7`なら「7日より前に変更された」になる。`find`の`-mtime`における`+`、`-`、なしの三つの意味の違いは、CLIを知らなければ見落とす。

生成されたコマンドが正しいかどうかを判断するには、結局、CLIの知識が必要なのだ。

この逆説は、AIとCLIの関係を考える上で本質的だ。自然言語でコマンドを指示する時代に、CLIの知識は不要になるのか。あるいは、AIが生成するコマンドの「監査者」として、CLIの理解はむしろ不可欠になるのか。

この問いに答えるために、自然言語でコンピュータを操作しようとした60年の歴史を辿り、2025年に花開いたAI+CLIの現在地を見定めたい。

あなたは、AIが生成したコマンドを、どこまで「信頼」しているだろうか。

---

## 2. 自然言語インターフェースの夢と挫折――SHRDLUからLLMへ

### 1970年、積み木の世界

自然言語でコンピュータを操作するという夢は、CLIの歴史とほぼ同じだけの長さを持つ。

1970年、MITのTerry WinogradはSHRDLUを開発した。DEC PDP-6上でMicro PlannerとLispで実装されたこのプログラムは、仮想の「積み木の世界（blocks world）」を英語の指示で操作できた。「赤いブロックの上に緑の円錐を置け（Put the green cone on the red block）」と入力すると、仮想空間内のオブジェクトが動く。「それを持ち上げろ（Pick it up）」と言えば、直前に言及した「それ」が何かを文脈から推論する。

SHRDLUは人工知能の歴史における画期だった。自然言語でコンピュータに「命令」を出し、コンピュータが文脈を理解して「実行」する。これは、第3回で語ったCTSSの対話的コンピューティングがもたらした「人間とコンピュータの対話」という概念の、究極の形に見えた。

だが、SHRDLUの成功は過度な楽観を生んだ。積み木の世界は閉じた環境だ。オブジェクトの種類は限定され、操作は「置く」「持ち上げる」「移動する」に限られる。曖昧性は制御されている。この閉じた世界の外に出た途端、自然言語理解は破綻した。

1980年代、研究の焦点はNLIDB（Natural Language Interface to Databases）に移った。データベースに対して英語で問い合わせを行うシステムだ。「売上が100万ドルを超えた顧客を表示せよ」と入力すると、SQLクエリに変換される。だが、自然言語の曖昧性は構造化されたデータベースクエリとは根本的に相容れず、実用的な精度を達成できなかった。「大きな注文」と言ったとき、「大きい」の基準をシステムは知らない。

1994年、Manaris、Pritchard、Dominickが「Developing a Natural Language Interface for the Unix Operating System」を発表した。UNIXコマンドを自然言語で操作しようという試みだ。だが、これも実験段階にとどまった。UNIXコマンドの組み合わせは事実上無限であり、ルールベースの自然言語処理では対応しきれなかった。

自然言語でコンピュータを操作する夢は、50年にわたって「あと少し」の場所で足踏みしていた。

### LLMが変えたもの

状況を根本から変えたのは、大規模言語モデル（LLM）の登場だ。

ルールベースの自然言語処理が失敗した理由は、人間の言語の曖昧性と多様性を有限のルールで捕捉しようとしたことにある。LLMは異なるアプローチを取る。膨大なテキストデータから言語パターンを学習し、統計的な予測によって自然言語を「理解」する。正確に言えば、理解しているのではなく、「理解しているかのように振る舞う」。だが、その振る舞いの精度は、SHRDLUの時代とは次元が異なる。

LLMが自然言語→コマンド変換に適している理由は構造的だ。

第一に、CLIコマンドは自然言語に比べて構文が厳密に定義されている。`find -name "*.ts" -mtime -7`というコマンドの構文は、POSIXと各コマンドのmanページで規定されている。LLMが生成すべきターゲットの構造が明確だ。

第二に、インターネット上には膨大なCLIコマンドの使用例が存在する。Stack Overflowの質問と回答、ブログ記事のコマンド例、GitHubのシェルスクリプト。LLMの学習データには、「こういうタスクにはこういうコマンドを使う」という対応関係が大量に含まれている。

第三に、CLIコマンドの正しさは検証可能だ。生成されたコマンドを実行すれば、成功か失敗かが終了コードで返ってくる。第21回で語った終了コードの規約が、AIの出力を検証する仕組みとして機能する。

この三つの条件が揃ったことで、自然言語→コマンド変換は初めて実用的な精度に達した。2023年以降、AI+CLIツールが次々と登場したのは偶然ではない。

---

## 3. AI+CLIツールの系譜――2022年から2025年へ

### 2022-2023年：先駆者たちの登場

AI+CLIの歴史を時系列で整理する。

**Warp AI（2023年4月）。** Warpは2020年6月にZach Lloyd（元Google Principal Engineer）が創業し、2022年4月に公開ベータを開始したRust製ターミナルエミュレータだ。第19回で語ったモダンターミナルエミュレータの文脈に位置する。2023年4月、WarpはOpenAIのLLMを統合したAIチャット機能を発表した。ターミナルの中でAIに質問し、コマンドの提案やエラーのデバッグ支援を受けられる。Warpのアプローチは「ターミナルエミュレータの中にAIを埋め込む」というものだ。ユーザーの作業コンテキスト――現在のディレクトリ、直前のコマンド出力、エラーメッセージ――をAIが参照できる。

**GitHub Copilot in the CLI（2023年11月プレビュー、2024年3月GA）。** GitHubは`gh copilot`というGitHub CLI拡張として、自然言語→コマンド変換機能を提供した。`gh copilot suggest`で「こういうことがしたい」と自然言語で伝えると、シェルコマンド、gitコマンド、またはGitHub CLIコマンドを提案する。`gh copilot explain`で「このコマンドは何をしているのか」を説明させることもできる。既存のCLIツール（GitHub CLI）の拡張として実装されている点が特徴的だ。

**Aider（2023年）。** Paul Gauthierが開発したAiderは、AI+CLIツールの中でも独自の位置にある。ターミナル上でLLMとペアプログラミングを行い、コードの変更をgitに自動コミットする。CLIネイティブかつgitネイティブなワークフローを徹底しており、100以上のプログラミング言語に対応する。GPT-4o、Claude 3.5 Sonnetなど複数のLLMをバックエンドとして選択できる。Aiderのアプローチは「AIをCLIのワークフローに溶け込ませる」ことだ。差分（diff）、コミット、ブランチといったgitの概念を中心に据え、AIがコードを「書く」のではなく「編集する」モデルを採用している。

**Open Interpreter（2023年）。** Open InterpreterはLLMにexec()関数を与え、Python、JavaScript、シェルコマンドをローカル環境で実行させるオープンソースツールだ。GitHub上で50,000以上のスターを獲得した。コード実行前にユーザーの承認を求める安全機能を持つ。このツールのアプローチは「LLMをローカル環境のオペレーターにする」ことであり、CLIコマンドの生成にとどまらず、コード実行まで踏み込む。

**Amazon Q Developer CLI（旧Fig、2023年買収）。** Figは2020年にローンチし、ターミナルのオートコンプリートを提供するスタートアップだった。IDE的な補完機能をCLIに持ち込んだ先駆者だ。2023年8月にAmazonに買収され、2024年9月にFigのスタンドアロン製品は終了し、Amazon Q Developer CLIに統合された。自然言語チャット、コマンドオートコンプリート、コード生成を統合している。

### 2025年：エージェント型CLIの爆発

2025年は、AI+CLIの歴史において転換点だった。「コマンドを提案する」段階から「タスクを自律的に遂行する」段階へ、質的な飛躍が起きた。

**Claude Code（2025年2月プレビュー、2025年5月GA）。** Anthropicが発表したClaude Codeは、ターミナルに棲むエージェント型コーディングツールだ。コードベースを理解し、ファイルを読み書きし、コマンドを実行し、テストを走らせ、gitにコミットする。自然言語で「この関数のテストを書いて」と指示すれば、該当するコードを読み、テストフレームワークの規約を理解し、テストコードを生成し、実行して通るところまで自律的に作業する。私はこのツールを毎日使っている。いま、まさにこの原稿の執筆環境もClaude Codeが動いているターミナルの中にある。

**OpenAI Codex CLI（2025年4月）。** OpenAIはCodex CLIをオープンソース（Apache 2.0）として公開した。Rustで構築され、ローカルのターミナルでコードを読み、変更し、実行するエージェント型ツールだ。o3、o4-miniモデルと同時に発表された。「Codex」という名称は2021年のコード生成モデルから引き継いだものだが、2025年のツールはモデルではなくCLIエージェントとして設計されている。

**Google Gemini CLI（2025年6月）。** GoogleはGemini CLIをApache 2.0ライセンスのオープンソースとして公開した。Gemini 2.5 Proモデルを使用し、100万トークンのコンテキストウィンドウを持つ。ReAct（Reason and Act）ループでタスクを遂行し、MCP対応。無料で60リクエスト/分、1,000リクエスト/日という寛大な枠が特徴だ。

**GitHub Copilot CLI（2025年9月プレビュー）。** GitHubは2023年の`gh copilot`拡張を廃止し、新しいエージェント型のGitHub Copilot CLIを発表した。Claude Sonnet 4.5をデフォルトモデルとし、Autopilotモードでタスク完了まで自律的に作業する。セッション永続性、MCP対応も備える。

### AI+CLIツールの設計思想の分類

これらのツールを俯瞰すると、設計思想は三つのパターンに分類できる。

```
1. 提案型（Suggest）:
   自然言語 → コマンド候補を提示 → 人間が確認・実行
   例: gh copilot suggest（2023年）
   特徴: 人間が最終判断を下す。安全だが効率は限定的

2. 埋め込み型（Embedded）:
   ターミナルエミュレータ内にAIを統合し、
   作業コンテキストを共有
   例: Warp AI、Amazon Q Developer CLI
   特徴: 現在の作業状態をAIが参照できる。
         ターミナル自体の進化

3. エージェント型（Agentic）:
   自然言語 → タスク分解 → コマンド実行 → 結果確認
   → 次のステップ → 完了まで自律動作
   例: Claude Code、Codex CLI、Gemini CLI、Aider
   特徴: 人間は目標を伝え、AIが手段を選ぶ。
         最も生産性が高いが、最もリスクも大きい
```

2023年は提案型が主流だった。2025年にエージェント型が爆発的に普及した。この進化は、LLMの能力向上だけでなく、エージェントが「CLIを使う」ための基盤技術が整ったことによる。その基盤技術の一つがMCPだ。

---

## 4. MCPとエージェント――AIがCLIを「使う」時代

### Model Context Protocol：AIとツールの架け橋

2024年11月、AnthropicはModel Context Protocol（MCP）をオープンスタンダードとして発表した。MCPは、AIアシスタントと外部のデータソース・ツールを接続する共通プロトコルだ。

MCPの設計は、第13回で語ったLanguage Server Protocol（LSP）の思想を受け継いでいる。LSPが「エディタ」と「言語サーバー」の間の通信を標準化したように、MCPは「AIアシスタント」と「外部ツール」の間の通信を標準化する。JSON-RPC 2.0で通信し、サーバー側はPrompts、Resources、Toolsの三つのプリミティブを提供する。

```
MCP のアーキテクチャ:

┌──────────────────┐     JSON-RPC 2.0      ┌──────────────────┐
│   MCP Client     │◄──────────────────────►│   MCP Server     │
│  (AI Assistant)  │                        │ (Tool Provider)  │
│                  │     Primitives:        │                  │
│  Claude Code     │     - Tools            │  Git Server      │
│  Gemini CLI      │     - Resources        │  Database Server │
│  Copilot CLI     │     - Prompts          │  Monitoring Tool │
└──────────────────┘                        └──────────────────┘
```

MCPがAI+CLIの文脈で重要なのは、AIエージェントが「どのツールが使えるか」を動的に発見し、「どうやって使うか」を共通のインターフェースで把握できるようになることだ。CLIツールがMCPサーバーとして自分の能力を公開すれば、AIエージェントはそのツールの使い方を学習データに頼らずに知ることができる。

### エージェントがCLIを「使う」とはどういうことか

ここで、本連載全体を貫く問いに立ち返りたい。第1回で私は「テキストという最も普遍的なインターフェースが、あらゆる時代の計算モデルに適応し続けている」と述べた。AIエージェントは、この命題の最新の検証例だ。

Claude Codeのようなエージェント型ツールが内部で何をしているかを考えてみよう。

```
ユーザーの指示:
  「このプロジェクトのテストを実行して、
   失敗しているテストを修正してくれ」

エージェントの内部動作（概念的な流れ）:
  1. プロジェクト構造を把握する
     → ls, find, cat (package.json等) を実行
  2. テストフレームワークを特定する
     → package.jsonからjest/vitest等を検出
  3. テストを実行する
     → npm test を実行
  4. 失敗したテストの出力を解析する
     → stderr/stdoutのテキストを解析
  5. 関連するソースコードを読む
     → cat, grep で該当ファイルを特定・読み込み
  6. 修正コードを生成する
     → ファイルを編集
  7. テストを再実行して確認する
     → npm test を再実行
  8. 成功を確認して結果を報告する
     → 終了コード0を確認
```

この一連の流れの中で、エージェントは何を「使って」いるか。`ls`、`find`、`cat`、`grep`、`npm`――すべてCLIコマンドだ。テストの成否は終了コードで判定し、エラーメッセージはstderrから読み取る。ファイルの内容はテキストストリームとして取得し、編集はテキストの差分として適用する。

つまり、AIエージェントは「CLIの上に立っている」のだ。テキストストリームという普遍的インターフェース、終了コードという成否の判定基準、パイプによるコマンドの組み合わせ――この連載で20回にわたって語ってきたCLIの基盤技術が、そのままAIエージェントの動作基盤になっている。

AIはCLIを「不要にする」のではない。AIはCLIを「内部的に活用する」のだ。

### テキストストリームがAIに適している理由

第10回で語ったUNIX哲学の功罪を思い出してほしい。テキストストリームには「スキーマレスである」という弱点がある。構造化データの扱いが脆弱で、PowerShellが批判した「テキストパースの脆弱性」は正当だった。

だが、AI時代において、テキストストリームの「スキーマレスさ」は予想外の利点を発揮している。LLMは構造化されたデータよりも、自然言語に近い非構造化テキストの方が得意だ。エラーメッセージの解釈、ログの意味理解、コマンド出力の要約――これらはすべて、テキストストリームをLLMが処理することで可能になる。

```
PowerShellのオブジェクトパイプライン:
  Get-Process | Where-Object {$_.CPU -gt 100}
  → 型付きオブジェクトを渡す。機械には厳密だが、
    LLMが「意味」を理解するには構造の知識が必要

UNIXのテキストパイプライン:
  ps aux | awk '$3 > 100 {print $0}'
  → テキストを渡す。スキーマレスだが、
    LLMはテキストの「意味」を推論できる
```

テキストストリームという50年前の設計判断が、AIエージェントという50年後の技術にとって最も「読みやすい」インターフェースになっている。歴史の皮肉か、それとも普遍性の証明か。

---

## 5. LLMベースのコマンド生成の限界

### ハルシネーション：存在しないオプションの生成

AIがCLIを「アクセシブルにする」一方で、その限界を直視する必要がある。最も深刻なのは、LLMのハルシネーション問題だ。

LLMは確率的にテキストを生成する。学習データに含まれるパターンから「それらしい」出力を生成するが、その出力が事実に基づく保証はない。CLIコマンドの文脈では、以下のようなハルシネーションが発生する。

```
問題1: 存在しないオプションフラグの生成
  LLMが生成: grep --color-match=red "pattern" file.txt
  実際:      --color-match というオプションは存在しない
             正しくは --color=always など

問題2: 文法的に正しいが意味が異なるコマンドの生成
  LLMが生成: find . -name "*.log" -delete -mtime +30
  意図:      30日以上古い.logファイルを削除
  実際:      -deleteは-mtimeの前に評価される。
             すべての.logファイルが先に削除され、
             -mtime +30の条件は死んだファイルに適用される
             （findのオプション評価順序の問題）

問題3: OS固有のコマンドの混同
  LLMが生成: ls --color=auto  （GNU coreutils）
  環境:      macOS（BSD ls。--color=autoは存在しない。
             代わりに -G を使う）
```

2025年12月に発表された研究では、LLMがシェルコマンド中で存在しないパッケージ名をハルシネーションする問題が指摘されている。特に量子化されたモデル（4-bit）ではハルシネーション率が顕著に上昇する。これはサプライチェーン攻撃のベクターにもなりうる。AIが推薦した架空のパッケージ名を、悪意ある第三者がパッケージレジストリに登録するという攻撃手法だ。

### コンテキスト依存性：環境を知らないAI

CLIコマンドは環境に強く依存する。同じタスクでも、OS、シェルの種類、インストールされているツール、現在のディレクトリ構造、環境変数によって、正しいコマンドは変わる。

```
コンテキスト依存性の例:

環境1（Ubuntu + bash + GNU coreutils）:
  sed -i 's/old/new/g' file.txt
  → -i オプションでバックアップ拡張子なしのインプレース編集

環境2（macOS + zsh + BSD sed）:
  sed -i '' 's/old/new/g' file.txt
  → BSD sedの-iは引数が必須。空文字列''を渡す必要がある

環境3（Alpine Linux + ash + BusyBox）:
  sed -i 's/old/new/g' file.txt
  → BusyBox sedはGNU互換だが一部のオプションが未実装
```

第14回で語ったGNUツールとBSDツールの非互換性の問題が、AIの時代にも健在だ。LLMは「一般的な使い方」を学習しているが、ユーザーの実行環境が何であるかを正確に把握することは容易ではない。

Claude Codeのようなエージェント型ツールは、この問題を部分的に解決している。エージェントは実行環境を直接調査できる――`uname -a`でOSを確認し、`which sed`でコマンドのパスを調べ、`sed --version`でバージョンを特定する。だが、この調査自体がCLIコマンドに依存している。

### 破壊的コマンドのリスク

CLIコマンドの一部は、実行結果が不可逆だ。`rm -rf /`は極端な例だが、`DROP TABLE`、`git push`の強制上書き、`chmod -R 777 /`といったコマンドは、実行した瞬間に取り返しがつかない結果をもたらす。

AIエージェントが自律的にコマンドを実行する場合、このリスクは増大する。提案型のツールなら人間が確認してから実行するが、エージェント型のツールは確認なしに実行を進める場合がある。

各ツールはこのリスクに対して異なるアプローチを取っている。

```
安全性のアプローチ:

Claude Code:
  - 権限レベルの段階的設定（読み取り専用/実行許可等）
  - 破壊的コマンドの実行前に人間の承認を要求
  - CLAUDE.mdファイルによるプロジェクト固有のルール設定
  - hooksによるコマンド実行の制御

Open Interpreter:
  - デフォルトで全コード実行前にユーザー確認
  - Autopilotモードでは確認スキップ可能（要注意）

Codex CLI:
  - サンドボックス環境での実行をサポート

Gemini CLI:
  - ReActループ内でツール呼び出しを段階的に実行
```

安全性と生産性のトレードオフは、CLIの歴史において常に存在してきた。UNIXは伝統的に「ユーザーは自分が何をしているか知っている」という前提で設計されてきた。`rm`にデフォルトの確認プロンプトがないのは、そのためだ。AIエージェントの時代に、この前提は再考を迫られている。AIエージェントは「自分が何をしているか」を本当に知っているのか。

---

## 6. ハンズオン：AI+CLIの現在を体験する

### 環境構築

```bash
# Docker環境で実行（ubuntu:24.04ベース）
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：AIが生成しうるコマンドの正確性を検証する

この演習では、AIが生成しそうなコマンドのパターンを手動で検証し、CLIの知識がなぜ必要かを体験する。

```bash
apt-get update && apt-get install -y coreutils findutils grep gawk

echo "=== 演習1: コマンドの正確性を検証する ==="
echo ""

# テスト用のファイルを作成
mkdir -p /tmp/ai-cli-test
cd /tmp/ai-cli-test
for i in $(seq 1 10); do
    touch -d "$i days ago" "file_${i}.txt"
    echo "Content of file $i" > "file_${i}.txt"
done
touch -d "2 hours ago" "recent.ts"
touch -d "3 days ago" "old.ts"
touch -d "10 days ago" "ancient.ts"

echo "--- findの-mtimeオプションの挙動を検証する ---"
echo ""

echo "1. -mtime -7 （7日以内に変更されたファイル）:"
find . -name "*.txt" -mtime -7 | sort
echo ""

echo "2. -mtime 7 （ちょうど7日前に変更されたファイル）:"
find . -name "*.txt" -mtime 7 | sort
echo ""

echo "3. -mtime +7 （7日より前に変更されたファイル）:"
find . -name "*.txt" -mtime +7 | sort
echo ""

echo "→ -mtime の +/-/なし の違いを知らなければ、"
echo "  AIが生成したfindコマンドの正しさを判断できない。"
echo ""
echo "  -mtime -N: N日以内（N*24時間以内）"
echo "  -mtime N:  ちょうどN日前（N*24時間からN*24+24時間前）"
echo "  -mtime +N: N日より前（N*24+24時間より前）"
```

### 演習2：環境依存のコマンドの差異を確認する

```bash
echo ""
echo "=== 演習2: 環境依存のコマンドの差異を確認する ==="
echo ""

echo "--- GNU sed vs BSD sed のインプレース編集 ---"
echo ""

# テスト用ファイル
echo "Hello World" > /tmp/test_sed.txt

echo "現在の環境:"
sed --version 2>&1 | head -1
echo ""

echo "GNU sed のインプレース編集:"
echo '  sed -i "s/Hello/Hi/g" file.txt'
echo "  → バックアップ拡張子なしでそのまま編集"
echo ""

echo "BSD sed（macOS）のインプレース編集:"
echo '  sed -i "" "s/Hello/Hi/g" file.txt'
echo "  → -i の後に空文字列の引数が必須"
echo ""

echo "ポータブルな代替手段:"
echo '  sed "s/Hello/Hi/g" file.txt > file.tmp && mv file.tmp file.txt'
echo "  → 一時ファイル経由。どの環境でも動作する"
echo ""

# 実際にGNU sedで実行
sed -i 's/Hello/Hi/g' /tmp/test_sed.txt
cat /tmp/test_sed.txt
echo ""

echo "→ AIが生成したsedコマンドがGNU前提かBSD前提かを"
echo "  判断するには、第14回で学んだGNU/BSDの違いの知識が必要。"
```

### 演習3：findの評価順序の罠を体験する

```bash
echo ""
echo "=== 演習3: findの評価順序の罠を体験する ==="
echo ""

# テスト環境
mkdir -p /tmp/find-test
cd /tmp/find-test
touch -d "2 days ago" recent.log
touch -d "40 days ago" old.log
touch -d "60 days ago" ancient.log
echo "recent" > recent.log
echo "old" > old.log
echo "ancient" > ancient.log

echo "--- findのオプション評価順序 ---"
echo ""

echo "ファイル一覧（作成時）:"
ls -la *.log
echo ""

echo "意図: 30日以上古い.logファイルを表示する"
echo ""

echo "正しい順序:"
echo '  find . -name "*.log" -mtime +30 -print'
find . -name "*.log" -mtime +30 -print
echo ""

echo "→ findの述語は左から右に評価される。"
echo "  -deleteを使う場合、条件の後に置かないと"
echo "  意図しないファイルが削除される危険がある。"
echo ""

echo "危険な例（実行はしない）:"
echo '  find . -name "*.log" -delete -mtime +30'
echo "  → -deleteが-mtimeの前にあるため、"
echo "    すべての.logファイルが先に削除される！"
echo ""

echo "安全な例:"
echo '  find . -name "*.log" -mtime +30 -delete'
echo "  → -mtime +30の条件を満たすファイルだけが削除される"
echo ""

echo "→ AIが生成したfindコマンドの述語順序が正しいか、"
echo "  特に-deleteを含む場合は必ず人間が確認すべきだ。"

# テスト環境のクリーンアップ
rm -rf /tmp/find-test /tmp/ai-cli-test /tmp/test_sed.txt
```

### 演習4：終了コードを使った簡易コマンド検証の仕組み

```bash
echo ""
echo "=== 演習4: 終了コードを使ったコマンド検証 ==="
echo ""

echo "--- AIが生成したコマンドを検証するパターン ---"
echo ""

echo "1. --helpでオプションの存在を確認:"
echo ""

# 存在するオプションの確認
echo "  grep --helpで--countオプションの存在を確認:"
if grep --help 2>&1 | grep -q "\-c"; then
    echo "    → -c オプションは存在する"
else
    echo "    → -c オプションは存在しない"
fi
echo ""

echo "2. --dry-runパターン（破壊的操作の事前確認）:"
echo ""
echo "  多くのCLIツールは--dry-runオプションを持つ。"
echo "  実際の操作を行わず、何が起きるかだけを表示する。"
echo ""
echo "  例:"
echo "    rsync --dry-run -av source/ dest/"
echo "    git clean --dry-run"
echo "    apt-get --dry-run install package"
echo ""

echo "3. typeコマンドでコマンドの存在を確認:"
echo ""
if type find > /dev/null 2>&1; then
    echo "  find: $(type find)"
fi

if type rg > /dev/null 2>&1; then
    echo "  rg: $(type rg)"
else
    echo "  rg: コマンドが見つからない"
    echo "  → AIがripgrepのコマンドを生成しても、"
    echo "    インストールされていなければ実行できない"
fi
echo ""

echo "4. 終了コードによる成否判定:"
echo ""
echo "  エージェント型AIはコマンドの終了コードで"
echo "  成否を判定し、次のステップを決定する。"
echo ""
echo "  if command; then"
echo "    echo '成功: 次のステップへ'"
echo "  else"
echo "    echo '失敗: 代替手段を検討'"
echo "  fi"
echo ""
echo "→ 第21回で学んだ終了コードの規約が、"
echo "  AIエージェントの動作基盤になっている。"
```

ハンズオンの自動セットアップスクリプトは `handson/command-line/22-ai-cli-natural-language-shell/setup.sh` を参照してほしい。

---

## 7. まとめと次回予告

### この回の要点

第一に、自然言語でコンピュータを操作する試みは1970年のSHRDLU（Terry Winograd、MIT）にまで遡る。だが、閉じた環境の外では自然言語処理は破綻し、実用的な精度は50年間達成されなかった。LLMの登場が、CLIコマンドの構文の厳密性、学習データの豊富さ、終了コードによる検証可能性という三つの条件と結びつき、初めて自然言語→コマンド変換を実用レベルに引き上げた。

第二に、AI+CLIツールは2023年の提案型（gh copilot suggest、Warp AI）から、2025年のエージェント型（Claude Code、Codex CLI、Gemini CLI）へと進化した。提案型は人間が最終判断を下し、エージェント型はタスク完了まで自律的に動作する。この進化は、生産性の飛躍的向上と引き換えに、新たなリスクを生んでいる。

第三に、AIエージェントはCLIの上に立っている。テキストストリーム、終了コード、パイプライン――この連載で語ってきたCLIの基盤技術が、そのままAIエージェントの動作基盤だ。AIはCLIを「不要にする」のではなく「内部的に活用する」。テキストストリームという50年前の設計判断が、LLMにとって最も「読みやすい」インターフェースになっているのは、歴史の皮肉か普遍性の証明か。

第四に、LLMベースのコマンド生成には構造的な限界がある。存在しないオプションフラグのハルシネーション、環境依存のコマンドの混同、`find`の述語評価順序のような微妙な意味の違い。AIが生成したコマンドを「監査」するには、CLIの深い理解が不可欠だ。

第五に、Model Context Protocol（MCP、2024年11月、Anthropic）は、AIエージェントと外部ツールの接続を標準化した。Language Server Protocolの思想を受け継ぎ、CLIツールがMCPサーバーとして自分の能力を公開することで、AIエージェントはツールの使い方を動的に発見できる。

### 冒頭の問いへの暫定回答

自然言語でコマンドを指示する時代に、CLIの知識は不要になるのか。

答えは明確だ。不要にならない。むしろ、より重要になる。

AIが生成するコマンドの品質は、確実に向上し続けるだろう。だが、生成されたコマンドが「正しいかどうか」を判断する能力は、CLIの知識なしには成立しない。`-mtime -7`と`-mtime 7`の違い、GNU sedとBSD sedの非互換性、`find`の述語評価順序――これらの知識は、AIが正しいコマンドを生成した場合には不要に見え、AIが間違ったコマンドを生成した場合にのみ必要になる。つまり、「問題が起きたとき」にだけ必要になる知識だ。そして、問題が起きたときに対処できるかどうかが、エンジニアとしての信頼性を決める。

AIはCLIを「アクセシブルにする」。パイプラインの構文を知らなくても、自然言語で複雑なデータ処理を依頼できる。だが、AIが生成したコマンドを監査するには、パイプラインの構文を知っていなければならない。これは矛盾ではない。自動車のオートマチックトランスミッションがマニュアルの知識を不要にしたわけではないのと同じだ。通常の運転には不要でも、故障時の対処には必要だ。

あなたがもしAIの生成するコマンドを「信頼して実行する」だけの存在であるなら、あなたはAIの監査者ではなく、AIの実行者にすぎない。この連載で21回にわたって語ってきたCLIの知識は、あなたをAIの「監査者」にするための道具だ。

### 次回予告

次回、第23回「コマンドラインの本質に立ち返る――テキスト・組み合わせ・自動化」では、24年間CLIを使い続けた集大成として、コマンドラインの「三つの本質」を語る。

テレタイプからAIエージェントまで辿ってきた60年の歴史の中で、何が変わり、何が変わらなかったのか。テキストストリームという普遍的インターフェース、小さなツールの組み合わせ、操作のスクリプト化による再現性――この三つの軸で各時代のCLIパラダイムを再評価する。連載の終盤に向けて、歴史から本質を蒸留する回になる。

---

## 参考文献

- Terry Winograd, "Procedures as a Representation for Data in a Computer Program for Understanding Natural Language", PhD thesis, MIT, 1970
- Wikipedia, "SHRDLU", <https://en.wikipedia.org/wiki/SHRDLU>
- GitHub, "gh-copilot", <https://github.com/github/gh-copilot>
- GitHub Docs, "Using the GitHub CLI Copilot extension", <https://docs.github.com/en/copilot/how-tos/use-copilot-for-common-tasks/use-copilot-in-the-cli>
- Wikipedia, "Warp (terminal)", <https://en.wikipedia.org/wiki/Warp_(terminal)>
- TechCrunch, "Warp brings an AI bot to its terminal", March 16, 2023, <https://techcrunch.com/2023/03/16/warp-brings-an-ai-bot-to-its-terminal/>
- Anthropic, "Claude Code", <https://github.com/anthropics/claude-code>
- Claude Code Docs, "Overview", <https://code.claude.com/docs/en/overview>
- OpenAI, "Introducing Codex", 2025, <https://openai.com/index/introducing-codex/>
- TechCrunch, "OpenAI debuts Codex CLI, an open source coding tool for terminals", April 16, 2025, <https://techcrunch.com/2025/04/16/openai-debuts-codex-cli-an-open-source-coding-tool-for-terminals/>
- Google, "Introducing Gemini CLI: your open-source AI agent", June 25, 2025, <https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemini-cli-open-source-ai-agent/>
- GitHub, "google-gemini/gemini-cli", <https://github.com/google-gemini/gemini-cli>
- TechCrunch, "Amazon acquires Fig, a startup building autocomplete for the command line", August 29, 2023, <https://techcrunch.com/2023/08/29/amazon-fig-command-line-terminal-generative-ai/>
- GitHub, "Aider-AI/aider", <https://github.com/Aider-AI/aider>
- GitHub, "openinterpreter/open-interpreter", <https://github.com/openinterpreter/open-interpreter>
- Anthropic, "Introducing the Model Context Protocol", November 2024, <https://www.anthropic.com/news/model-context-protocol>
- Model Context Protocol Specification, <https://modelcontextprotocol.io/specification/2025-11-25>
- Wikipedia, "Model Context Protocol", <https://en.wikipedia.org/wiki/Model_Context_Protocol>
- arxiv.org, "Investigating Package Hallucinations of Shell Command in Original and Quantized LLMs", December 2025, <https://arxiv.org/html/2512.08213>
- GitHub, "github/copilot-cli", <https://github.com/github/copilot-cli>
- Manaris, Pritchard, Dominick, "Developing a Natural Language Interface for the Unix Operating System", 1994
