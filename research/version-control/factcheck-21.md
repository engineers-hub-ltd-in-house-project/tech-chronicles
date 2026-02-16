# ファクトチェック記録：第21回「GitHub Copilotとgit——AIが介在するバージョン管理」

調査日：2026-02-16

---

## 1. GitHub Copilotの発表・公開時期

- **結論**: テクニカルプレビューは2021年6月29日にVisual Studio Code向けに公開。JetBrains向けプラグインは2021年10月29日、Neovimプラグインは2021年10月27日に公開。一般提供（GA）は2022年6月21日に有料サブスクリプションとして開始
- **一次ソース**: Wikipedia, "GitHub Copilot"; Visual Studio Magazine, 2021年6月29日
- **URL**: <https://en.wikipedia.org/wiki/GitHub_Copilot>
- **注意事項**: テクニカルプレビューとGAの間に約1年のギャップがある
- **記事での表現**: 「2021年6月29日、GitHubはAIペアプログラマー『GitHub Copilot』のテクニカルプレビューを公開した。約1年後の2022年6月21日に一般提供が開始された」

## 2. OpenAI Codexの概要と公開時期

- **結論**: OpenAI CodexはGPT-3をベースに、54百万のGitHub公開リポジトリから収集した159GBのPythonコードを含むソースコードでファインチューニングしたモデル。2021年8月10日に発表。GitHub Copilotのテクニカルプレビュー（2021年6月）はCodexの公式発表より約2か月先行
- **一次ソース**: Wikipedia, "OpenAI Codex"
- **URL**: <https://en.wikipedia.org/wiki/OpenAI_Codex>
- **注意事項**: Copilotのプレビューが先行し、Codex自体の正式発表が後だった点が興味深い
- **記事での表現**: 「GitHub Copilotを支えていたのはOpenAI Codex——GPT-3をソースコードでファインチューニングしたモデルだった。54百万の公開GitHubリポジトリから収集されたコードが学習データに含まれていた」

## 3. GitHub Copilotの利用統計

- **結論**: 2025年4月時点で1,500万人以上の開発者が利用（12か月で400%増）、2025年7月には累計2,000万ユーザーを突破。有料サブスクライバーは130万人。50,000以上の組織が導入。Fortune 100企業の90%が利用（2025年時点）。コード生成比率は約46%、Javaでは最大61%
- **一次ソース**: TechCrunch, "GitHub Copilot crosses 20M all-time users," 2025年7月30日; Microsoft earnings reports
- **URL**: <https://techcrunch.com/2025/07/30/github-copilot-crosses-20-million-all-time-users/>
- **注意事項**: 「all-time users」は累計利用者であり、月間アクティブユーザーとは異なる
- **記事での表現**: 「2025年7月時点でGitHub Copilotの累計利用者は2,000万人を超え、Fortune 100企業の90%が導入している」

## 4. GitHub Copilot生産性研究

- **結論**: 2022年5月15日〜6月20日に実施。プロの開発者95名を対象にJavaScriptでHTTPサーバを実装する実験。Copilot使用群は非使用群と比較して55.8%速くタスクを完了（95%信頼区間: 21-89%）。使用群の平均所要時間1時間11分、非使用群2時間41分。経験年数の少ない開発者、高齢の開発者、日常的にプログラミング時間が長い開発者ほど恩恵が大きかった
- **一次ソース**: Peng, S., Kalliamvakou, E., Cihon, P., Demirer, M. "The Impact of AI on Developer Productivity: Evidence from GitHub Copilot." arXiv:2302.06590, 2023年2月
- **URL**: <https://arxiv.org/abs/2302.06590>
- **注意事項**: 単一タスク（HTTPサーバ構築）での測定であり、日常的な開発全般への一般化には留意が必要。タスクの完了率自体には有意差なし
- **記事での表現**: 「2023年に発表された実験では、95名のプロ開発者を対象にHTTPサーバの実装タスクでCopilot使用群が55.8%速くタスクを完了したと報告された」

## 5. GitHub Copilot著作権訴訟

- **結論**: 2022年11月、プログラマー兼弁護士のMatthew ButterickがGitHub、Microsoft、OpenAIを相手にクラスアクション訴訟を提起。カリフォルニア北部地区連邦地裁のJon Tigar判事が2023年5月に判断を下し、当初の22の請求のうち20を棄却。契約違反とDMCA違反の2件のみ存続。著作権侵害請求はコピーされたコードの具体例の不足を理由に棄却。2024年7月にはDMCA 1202(b)条項違反の請求も棄却。2024年10月に原告が第九巡回区控訴裁判所に上訴許可を申請
- **一次ソース**: Joseph Saveri Law Firm, "GitHub Copilot Intellectual Property Litigation"; The Register, 2024年7月8日
- **URL**: <https://www.saverilawfirm.com/our-cases/github-copilot-intellectual-property-litigation>
- **注意事項**: 訴訟は2026年2月現在も進行中（控訴審段階）
- **記事での表現**: 「2022年11月、Matthew ButterickがGitHub・Microsoft・OpenAIを相手にクラスアクション訴訟を提起した。Copilotの学習データとして使われたオープンソースコードのライセンス帰属表示が省略されているという主張だった」

## 6. AI コーディングアシスタントの歴史

- **結論**:
  - **Tabnine（旧Codota）**: 2013年にDror WeissとEran YahavがCodotaをテルアビブで設立。Technionの10年以上の学術研究に基づく。2018年にJava IDE向け初のAIコード補完を提供。2018年にWaterloo大学の学生Jacob JacksonがTabnineを作成。2019年にCodotaがTabnineを買収。2021年5月に社名をTabnineに変更
  - **Amazon CodeWhisperer**: 2022年6月に発表。2024年4月にAmazon Q Developerに改名
  - **Cursor**: Anysphere社が2022年設立。MIT出身のMichael Truell、Sualeh Asif、Arvid Lunnemark、Aman Sangerが創業。2023年3月にCursorローンチ。VSCodeをフォーク。2025年1月にARR1億ドル突破。2025年11月に23億ドルの資金調達（評価額293億ドル）
- **一次ソース**: Wikipedia, "Tabnine"; Wikipedia, "Cursor (code editor)"; Contrary Research, "Anysphere Business Breakdown"
- **URL**: <https://en.wikipedia.org/wiki/Tabnine>, <https://en.wikipedia.org/wiki/Cursor_(code_editor)>
- **注意事項**: Tabnineの歴史は複雑（Codota→Tabnine買収→社名変更）
- **記事での表現**: 年表形式で主要ツールの登場時期を記述

## 7. Claude Code / MCP

- **結論**: Claude Codeは2025年2月にプレビューリリース。2025年5月にClaude 4とともに一般提供開始。Model Context Protocol（MCP）は2024年11月にAnthropicがオープンソースとして発表。数千のMCPサーバがコミュニティで構築され、主要プログラミング言語向けのSDKが提供。事実上のAI-ツール接続標準に
- **一次ソース**: Anthropic, "Introducing the Model Context Protocol," 2024年11月
- **URL**: <https://www.anthropic.com/news/model-context-protocol>
- **注意事項**: Claude Codeは2025年10月にWeb版とiOSアプリもリリース
- **記事での表現**: 「2025年、AnthropicはClaude Code——ターミナルで動作するエージェント型コーディングツール——をリリースした」

## 8. GitHub Copilotのマルチモデル化

- **結論**: 2024年10月のGitHub Universe 2024でマルチモデル対応を発表。Anthropic Claude 3.5 Sonnet、Google Gemini 1.5 Pro、OpenAI GPT-4o/o1-preview/o1-miniを選択可能に。2025年2月6日にエージェントモード発表（GPT-4o, o1, o3-mini, Claude 3.5 Sonnet, Gemini 2.0 Flash対応）。2025年5月17日にコーディングエージェント（自律モード）発表
- **一次ソース**: GitHub Newsroom, "Universe 2024"; TechCrunch, 2024年10月29日
- **URL**: <https://github.com/newsroom/press-releases/github-universe-2024>
- **注意事項**: マルチモデル化は開発者の選択肢を拡大したが、モデルごとの特性差が新たな複雑さを生む
- **記事での表現**: 「2024年10月のGitHub Universe 2024で、CopilotはAnthropicのClaude、GoogleのGemini、OpenAIの複数モデルを選択可能なマルチモデルアーキテクチャへ移行した」

## 9. AI生成コードの著作権・法的議論

- **結論**: 米国: Thaler v. Perlmutter判決でAI生成物は人間の実質的な知的関与なしには著作権保護を受けられないと確認。米国著作権局の2025年報告書でプロンプトのみでは創作的著者性に不十分と判断。EU: 2024年12月の政策質問書でAI生成コンテンツは「人間の関与が重大」な場合のみ著作権保護の対象とする見解が多数。両法域とも人間の実質的関与を要求する方向で収斂
- **一次ソース**: Thaler v. Perlmutter, D.C. Circuit; U.S. Copyright Office, "Copyright and Artificial Intelligence" report, 2025; European Parliament Briefing, 2025
- **URL**: <https://www.europarl.europa.eu/thinktank/en/document/EPRS_BRI(2025)782585>
- **注意事項**: 法的状況は流動的。各国で異なるアプローチが採用される可能性がある
- **記事での表現**: 「米国著作権局は2025年の報告書で、AIへのプロンプト入力だけでは創作的著者性に不十分との見解を示した。AI生成コードの法的帰属は未解決の問題として残っている」

## 10. Co-authored-byトレーラーの慣習

- **結論**: gitのコミットメッセージ末尾に`Co-authored-by: name <email>`の形式で記述するトレーラー。git interpret-trailersコマンドで処理可能。GitHubが2018年頃にパース・表示対応を開始し、GitLabも同様にサポート。公式のgit仕様としてではなく、プラットフォーム主導の慣習として普及。AIツール（Claude Code等）が自動的にCo-authored-byトレーラーを追加する慣行が広まっている
- **一次ソース**: GitHub Docs, "Creating a commit with multiple authors"; Deploy HQ Blog, "How to Use Git with Claude Code"
- **URL**: <https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors>
- **注意事項**: Co-authored-byはgitの公式仕様ではなく、GitHubの慣習。AIの「著者」にメールアドレスを割り当てることの意味論的妥当性は議論がある
- **記事での表現**: 「GitHubはCo-authored-byトレーラーをパースし、コミットに複数の著者を表示する機能を提供している。AIコーディングツールはこの仕組みを利用して`Co-authored-by: Claude <noreply@anthropic.com>`のようなトレーラーを自動付与している」
