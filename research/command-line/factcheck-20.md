# ファクトチェック記録：第20回「PowerShell――テキストパイプラインへの根本的批判」

## 1. Monad Manifesto の日付と著者

- **結論**: Jeffrey P. Snoverが2002年8月8日にMonad Manifestoを執筆した。文書のヘッダーに「Aug 8, 2002」と記載されている
- **一次ソース**: Jeffrey P. Snover, "Monad Manifesto", 2002年8月8日
- **URL**: <https://www.jsnover.com/Docs/MonadManifesto.pdf>
- **注意事項**: 文書内のメタデータには「8/22/2002」という日付も見られるが、本文中の日付は8月8日。公開日と最終改訂日の違いと考えられる
- **記事での表現**: 「2002年8月、Jeffrey Snoverは"Monad Manifesto"と題するホワイトペーパーを執筆した」

## 2. Jeffrey Snoverの経歴

- **結論**: Jeffrey Snoverは1999年にMicrosoftに入社し、Management and Services Divisionのdivisional architectを務めた。2015年にTechnical Fellowに昇進。Windows PowerShellの「父」にして主任アーキテクト。2022年にGoogleのDistinguished Engineerに転職し、2026年1月に退職（引退）
- **一次ソース**: Wikipedia, "Jeffrey Snover"; The Register, "PowerShell architect retires after decades at the prompt", 2026年1月22日
- **URL**: <https://en.wikipedia.org/wiki/Jeffrey_Snover>, <https://www.theregister.com/2026/01/22/powershell_snover_retires/>
- **注意事項**: 2012年にUSENIX LISA Outstanding Achievement Awardを受賞（Bruce Payette、James Truherと共同）
- **記事での表現**: 「Jeffrey Snoverは1999年にMicrosoftに入社し、管理技術部門のアーキテクトとしてWindowsの管理自動化に取り組んでいた」

## 3. PowerShell 1.0のリリース日

- **結論**: Windows PowerShell 1.0は2006年11月14日にリリースされた。スペインのバルセロナで開催されたIT Forumの基調講演で発表された。対応OSはWindows XP SP2、Windows Server 2003 SP1、Windows Vista
- **一次ソース**: Microsoft PowerShell Team Blog, "It's a Wrap! Windows PowerShell 1.0 Released!"
- **URL**: <https://devblogs.microsoft.com/powershell/its-a-wrap-windows-powershell-1-0-released/>
- **注意事項**: リリース後半年で約100万ダウンロードを達成
- **記事での表現**: 「2006年11月14日、Windows PowerShell 1.0が正式にリリースされた」

## 4. Monadの名称変更からPowerShellへ

- **結論**: MonadからWindows PowerShellへの名称変更は2006年4月25日に発表された。Monadの初期発表から約1年半後
- **一次ソース**: Wikipedia, "PowerShell"
- **URL**: <https://en.wikipedia.org/wiki/PowerShell>
- **注意事項**: コードネーム「Monad」（msh）での開発は2003年初頭から開始
- **記事での表現**: 「2006年4月、MonadはWindows PowerShellに改名された」

## 5. PowerShellのオープンソース化とクロスプラットフォーム対応

- **結論**: 2016年8月18日、MicrosoftはPowerShellのオープンソース化とクロスプラットフォーム対応を発表。ソースコードをGitHubに公開した。PowerShell Core 6.0のGA（General Availability）は2018年1月10日。.NET Coreベース
- **一次ソース**: Microsoft .NET Blog, "PowerShell is now open-source, and cross-platform", 2016年8月18日
- **URL**: <https://devblogs.microsoft.com/dotnet/powershell-is-now-open-source-and-cross-platform/>
- **注意事項**: PowerShell Core（.NET Core）とWindows PowerShell（.NET Framework）は別の系統。PowerShell 7で両者の統合が進んだ
- **記事での表現**: 「2016年8月18日、MicrosoftはPowerShellのオープンソース化とクロスプラットフォーム対応を発表した」

## 6. PowerShellのバージョン履歴

- **結論**: 主要バージョンのリリース時期は以下の通り。2.0: 2009年10月（Windows 7同梱）、3.0: 2012年9月（Windows 8同梱）、4.0: 2013年10月（DSC導入）、5.0: 2016年2月（Windows 10同梱）、5.1: 2016年8月（Windows 10 Anniversary Update）、6.0: 2018年1月（Core、クロスプラットフォーム）、7.0: 2020年3月、7.5: 2025年1月（最新安定版、.NET 9ベース）
- **一次ソース**: Wikipedia, "PowerShell"; Microsoft Learn, PowerShell Support Lifecycle
- **URL**: <https://en.wikipedia.org/wiki/PowerShell>
- **注意事項**: 5.1はWindows PowerShellの最終バージョン。6.0以降はPowerShell Core / PowerShell 7系統
- **記事での表現**: バージョン履歴を時系列で記述

## 7. Monad ManifestoにおけるUNIXテキストパイプラインへの批判

- **結論**: Snoverは従来のUNIXパイプラインにおけるテキストパースを「prayer-based parsing」（祈りに基づくパース）と表現した。テキストの先頭3-4行を切り捨て、30-40列目を切り出し、タブではなくスペースであることを祈り、それを整数にキャストする――という脆弱なプロセスを批判した。Monadは.NETオブジェクトをパイプラインで渡すことで、このテキストパースの必要性を排除した
- **一次ソース**: Jeffrey Snover, "Monad Manifesto", 2002年; devops-collective-inc/monad-manifesto-annotated, Chapter 3
- **URL**: <https://www.jsnover.com/Docs/MonadManifesto.pdf>, <https://github.com/devops-collective-inc/monad-manifesto-annotated/blob/master/manuscript/chapter-3-the-traditional-approach-to-administrative-automation.md>
- **注意事項**: SnoverはLinuxが「すべてをテキストファイルとして扱う」のに対し、Windowsは「構造化データを返すAPIとして扱う」というアーキテクチャの根本的な違いを指摘した
- **記事での表現**: 「Snoverはこのテキストパースのプロセスを"prayer-based parsing"――祈りに基づくパース――と呼んだ」

## 8. PowerShellのVerb-Noun命名規則

- **結論**: PowerShellのコマンドレット（cmdlet）はVerb-Noun形式の命名規則を採用。動詞（Verb）は承認済みリスト（Get, Set, New, Remove等）から選択し、名詞（Noun）は単数形を使用する。例: Get-Process, Where-Object, Select-Object。PascalCase形式
- **一次ソース**: Microsoft Learn, "Approved Verbs for PowerShell Commands"
- **URL**: <https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.5>
- **注意事項**: この命名規則の一貫性がPowerShellの「発見可能性」の基盤
- **記事での表現**: 「PowerShellのコマンドレットはVerb-Noun形式の命名規則に従う。Get-Process、Where-Object、Select-Objectのように、動作と対象が名前に明示される」

## 9. Nushellの起源と設計

- **結論**: Nushellは2019年8月23日にJonathan Turnerが紹介。初期コミットは2019年5月10日。Jonathan Turner、Andres Robalino、Yehuda Katzが共同で作成。Rustで実装。UNIXのパイプライン哲学、PowerShellの構造化データアプローチ、関数型プログラミングからインスピレーションを得ている
- **一次ソース**: Nushell Blog, "Introducing nushell", 2019年8月23日
- **URL**: <https://www.nushell.sh/blog/2019-08-23-introducing-nushell.html>
- **注意事項**: Jonathan TurnerはMozillaでRust言語に関わっていた人物（Rust compilerチーム）。Yehuda KatzはEmber.js、Bundlerの作者として知られる
- **記事での表現**: 「2019年8月、Jonathan Turner、Andres Robalino、Yehuda Katzの三人がNushellを公開した」

## 10. Nushellの技術的特徴

- **結論**: Nushellはテーブル指向のパイプラインを採用。コマンドの出力は構造化されたテーブル（行と列）として扱われる。JSON、YAML、SQLite、Excel等のフォーマットをネイティブサポート。Apache Arrowベースのデータフレーム処理、Polarsエンジンによる高速な列指向演算。ストリーミング処理（ListStream, ByteStream）で大量データのメモリ効率的な処理が可能
- **一次ソース**: Nushell公式ドキュメント; GitHub nushell/nushell
- **URL**: <https://www.nushell.sh/>, <https://github.com/nushell/nushell>
- **注意事項**: PowerShellとの主な違いは、Nushellが.NETに依存せず、軽量でクロスプラットフォームであること。また、テーブルが可視化と内部表現の両方を兼ねる設計
- **記事での表現**: 「Nushellはパイプラインを流れるデータをテーブル――行と列を持つ構造化データ――として扱う」
