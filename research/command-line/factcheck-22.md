# ファクトチェック記録：第22回「AI+CLI――Claude Code, GitHub Copilot CLI, 自然言語シェルの時代」

## 1. SHRDLU（自然言語インターフェースの起源）

- **結論**: SHRDLUはTerry Winogradが1968-1970年にMITで開発した自然言語理解プログラム。仮想の「積み木の世界（blocks world）」内のオブジェクトを英語の指示で操作できた。DEC PDP-6上でMicro PlannerとLispで実装された
- **一次ソース**: Wikipedia, "SHRDLU"; Terry Winograd PhD thesis, 1970
- **URL**: <https://en.wikipedia.org/wiki/SHRDLU>
- **注意事項**: SHRDLUの成功はAI研究者に過度な楽観を与えたが、制約された環境外では機能しなかった。名前の由来はLinotype機のキー配列ETAOIN SHRDLU
- **記事での表現**: 「1970年、MITのTerry WinogradはSHRDLUを開発した。『赤いブロックの上に緑の円錐を置け』と英語で指示すると、仮想空間内のオブジェクトが動く。自然言語でコンピュータを操作する最初期の試みだった」

## 2. GitHub Copilot in the CLI（gh copilot拡張）

- **結論**: 2023年11月8日にパブリックプレビュー開始。2024年3月21日にGA（一般提供）。`gh copilot suggest`と`gh copilot explain`の2コマンドが中核。2025年10月25日に廃止され、新しいGitHub Copilot CLIに置き換えられた
- **一次ソース**: GitHub gh-copilot releases; GitHub Docs
- **URL**: <https://github.com/github/gh-copilot>、<https://docs.github.com/en/copilot/how-tos/use-copilot-for-common-tasks/use-copilot-in-the-cli>
- **注意事項**: gh copilot拡張と、2025年9月25日発表の新GitHub Copilot CLI（エージェント型）は別物。記事では時系列を明確に区別する
- **記事での表現**: 「2023年11月、GitHubはCopilot in the CLIをパブリックプレビューとして公開し、2024年3月にGAに達した。`gh copilot suggest`で自然言語からコマンドを提案し、`gh copilot explain`でコマンドの意味を説明する」

## 3. Warp AI

- **結論**: Warpは2020年6月にZach Lloyd（元Google Principal Engineer）が創業。2022年4月に公開ベータ。2023年4月にWarp AIを発表し、OpenAI LLMベースのチャット機能をターミナルに統合した
- **一次ソース**: Wikipedia "Warp (terminal)"; TechCrunch 2023/3/16; Sequoia Capital spotlight
- **URL**: <https://en.wikipedia.org/wiki/Warp_(terminal)>、<https://techcrunch.com/2023/03/16/warp-brings-an-ai-bot-to-its-terminal/>
- **注意事項**: TechCrunch記事は2023年3月だが、Warp AI機能の正式発表は2023年4月。2023年6月にはWarp Drive（チーム共有機能）も追加
- **記事での表現**: 「2023年、WarpはOpenAIのLLMを統合したAIチャット機能をターミナルに組み込んだ。コマンドの提案、エラーのデバッグ支援を自然言語で行える」

## 4. Claude Code

- **結論**: 2025年2月にAnthropicがリサーチプレビューとして発表。2025年5月にGA。ターミナルから自然言語でコーディングタスクを委任するエージェント型CLIツール。ファイル読み書き、コマンド実行、gitワークフローを自然言語で操作。2025年11月時点で年間収益10億ドル超
- **一次ソース**: Anthropic公式; GitHub anthropics/claude-code; Medium "The Evolution of Claude Code in 2025"
- **URL**: <https://github.com/anthropics/claude-code>、<https://code.claude.com/docs/en/overview>
- **注意事項**: 収益10億ドルは年間換算（annualised revenue）であり、実際の累計収益ではない
- **記事での表現**: 「2025年2月、AnthropicはClaude Codeをリサーチプレビューとして公開した。3か月後の5月にGAに到達した。ターミナルに棲むエージェントが、コードベースを理解し、ファイルを読み書きし、テストを実行し、gitにコミットする」

## 5. MCP（Model Context Protocol）

- **結論**: 2024年11月にAnthropicがオープンスタンダードとして発表。AIアシスタントとデータソース・ツールを接続するプロトコル。Language Server Protocol (LSP)のメッセージフロー思想を再利用し、JSON-RPC 2.0で通信。Servers: Prompts/Resources/Tools、Clients: Roots/Sampling
- **一次ソース**: Anthropic "Introducing the Model Context Protocol"; modelcontextprotocol.io; Wikipedia
- **URL**: <https://www.anthropic.com/news/model-context-protocol>、<https://modelcontextprotocol.io/specification/2025-11-25>
- **注意事項**: MCPはAnthropicが提案したが、オープンスタンダードとして設計されており、Anthropic製品に限定されない
- **記事での表現**: 「2024年11月、AnthropicはModel Context Protocol（MCP）をオープンスタンダードとして発表した。Language Server Protocolの思想を受け継ぎ、AIアシスタントと外部ツール・データソースを接続する共通プロトコルだ」

## 6. Amazon Q Developer CLI（旧Fig）

- **結論**: Figは2020年にローンチし、ターミナルのオートコンプリートを提供するスタートアップ。2023年8月にAmazonに買収。2024年9月1日にFigのスタンドアロン製品は終了し、Amazon Q for command lineに統合された
- **一次ソース**: TechCrunch 2023/8/29; AWS公式ドキュメント
- **URL**: <https://techcrunch.com/2023/08/29/amazon-fig-command-line-terminal-generative-ai/>、<https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line.html>
- **注意事項**: FigはIDE的な機能（オートコンプリート）をCLIに持ち込んだ先駆者。$2.2Mのシード資金調達
- **記事での表現**: 「2023年8月、AmazonはターミナルのオートコンプリートツールFigを買収した。2024年9月にFigは終了し、Amazon Q Developer CLIとして再出発した」

## 7. OpenAI Codex CLI

- **結論**: 2025年4月16日にオープンソースとして発表。o3/o4-miniモデルと同時発表。Rustで構築。ローカルターミナルでコードを読み、変更し、実行するエージェント型ツール。Apache 2.0ライセンス
- **一次ソース**: OpenAI公式 "Introducing Codex"; TechCrunch 2025/4/16; GitHub openai/codex
- **URL**: <https://openai.com/index/introducing-codex/>、<https://techcrunch.com/2025/04/16/openai-debuts-codex-cli-an-open-source-coding-tool-for-terminals/>、<https://github.com/openai/codex>
- **注意事項**: "Codex"はもともとOpenAIのコード生成モデル（2021年）の名称だったが、2025年のCLIツールとしてブランドを再利用。混同に注意
- **記事での表現**: 「2025年4月、OpenAIはCodex CLIをオープンソースで公開した。Rustで構築されたこのツールは、ローカルのターミナルでコードを読み、変更し、実行するエージェント型ツールだ」

## 8. Google Gemini CLI

- **結論**: 2025年6月25日にオープンソース（Apache 2.0）として発表。Gemini 2.5 Proを使用し、100万トークンのコンテキストウィンドウ。ReAct（reason and act）ループでタスク遂行。MCP対応。無料で60リクエスト/分、1000リクエスト/日
- **一次ソース**: Google公式ブログ; GitHub google-gemini/gemini-cli; InfoQ 2025/7
- **URL**: <https://blog.google/innovation-and-ai/technology/developers-tools/introducing-gemini-cli-open-source-ai-agent/>、<https://github.com/google-gemini/gemini-cli>
- **注意事項**: Gemini CLIの寛大な無料枠は競合他社との差別化ポイント
- **記事での表現**: 「2025年6月、GoogleはGemini CLIをApache 2.0ライセンスのオープンソースとして公開した。100万トークンのコンテキストウィンドウを持ち、ReActループでタスクを遂行する」

## 9. Aider

- **結論**: Paul Gauthierが2023年に開発・公開。ターミナルでLLMとペアプログラミングを行うオープンソースツール。Gitとネイティブに統合し、変更を自動コミット。100以上のプログラミング言語対応。GPT-4o/Claude 3.5 Sonnetを推奨
- **一次ソース**: GitHub Aider-AI/aider; Internet Archive snapshot 2023-07-05
- **URL**: <https://github.com/Aider-AI/aider>
- **注意事項**: Aiderの最初のアーカイブは2023年7月5日。CLIネイティブかつgitネイティブなワークフローが特徴
- **記事での表現**: 「2023年、Paul GauthierはAiderを公開した。ターミナル上でLLMとペアプログラミングを行い、変更をgitに自動コミットする。CLIとgitのワークフローに最も忠実なAIコーディングツールだ」

## 10. Open Interpreter

- **結論**: 2023年に開発開始。LLMにexec()関数を与え、Python/JavaScript/Shellのコードをローカルで実行させるオープンソースツール。コード実行前にユーザー確認を求める安全機能。GitHub 50K+スター
- **一次ソース**: GitHub openinterpreter/open-interpreter
- **URL**: <https://github.com/openinterpreter/open-interpreter>
- **注意事項**: コード実行前の確認プロセスは安全機能だが、Autopilotモードでは確認をスキップできるため注意が必要
- **記事での表現**: 「2023年に登場したOpen Interpreterは、LLMにローカル環境でのコード実行能力を与えた。Python、JavaScript、シェルコマンドを実行する前に、必ずユーザーの承認を求める」

## 11. LLMのハルシネーション問題（コマンド生成における）

- **結論**: LLMがコマンドやパッケージ名をハルシネーションする問題が研究で確認されている。存在しないオプションフラグの生成、架空のパッケージ名の推薦（パッケージハルシネーション）が報告されている。量子化モデル（4-bit）でハルシネーション率が上昇
- **一次ソース**: arxiv.org 2512.08213 "Investigating Package Hallucinations of Shell Command"
- **URL**: <https://arxiv.org/html/2512.08213>
- **注意事項**: パッケージハルシネーションはサプライチェーン攻撃のベクターになりうる。AIが推奨した架空のパッケージ名を悪意ある第三者が登録する攻撃手法（dependency confusion）
- **記事での表現**: 「LLMが生成するコマンドには、存在しないオプションフラグや架空のパッケージ名が含まれることがある。これは『ハルシネーション』と呼ばれ、セキュリティ上のリスクをもたらす」

## 12. 自然言語→コマンド変換の学術的歴史

- **結論**: 1960年代のELIZA（1966年、MIT、Joseph Weizenbaum）、SHRDLU（1970年、MIT、Terry Winograd）が自然言語理解の先駆。1980年代はルールベースのNLIDB（自然言語データベースインターフェース）に焦点。1994年にManaris, Pritchard, Dominickが「Developing a Natural Language Interface for the Unix Operating System」を発表
- **一次ソース**: dgp.toronto.edu "Natural Language as an Interface Style"; Wikipedia "Command-line interface"
- **URL**: <https://www.dgp.toronto.edu/public_user/byron/papers/nli.html>
- **注意事項**: NLIの歴史は長いが、実用的な自然言語→コマンド変換はLLMの登場（2020年代）まで実現しなかった
- **記事での表現**: 「自然言語でコンピュータを操作する試みは1960年代に遡る。だが、制約された環境を超えて実用的な精度を達成したのは、LLMの登場を待たなければならなかった」
