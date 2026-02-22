# ファクトチェック記録：第22回「PowerShellという異なるパラダイム――オブジェクトパイプラインの世界」

## 1. Jeffrey Snover と Monad Manifesto

- **結論**: Jeffrey P. Snoverが2002年8月8日にMonad Manifestoを執筆。Monadの開発は2003年初頭に開始された。Snoverは1999年にMicrosoftに入社し、Management and Services Divisionのdivisional architectとして着任。それ以前はTivoliのCTOオフィスのアーキテクト、DEC（Digital Equipment Corporation）でコンサルティングエンジニア兼開発マネージャーを務めていた
- **一次ソース**: Jeffrey P. Snover, "Monad Manifesto", August 8, 2002; Wikipedia "Jeffrey Snover"
- **URL**: <https://www.jsnover.com/Docs/MonadManifesto.pdf>, <https://en.wikipedia.org/wiki/Jeffrey_Snover>
- **注意事項**: Manifestoの日付は文書内に「Aug 8, 2002」と明記。開発開始は2003年初頭
- **記事での表現**: 「2002年8月、Jeffrey Snoverが『Monad Manifesto』を書いた。MicrosoftのManagement and Services Division Architectだった彼は...」

## 2. "prayer-based parsing" 概念

- **結論**: Snoverは Monad Manifesto の中で、Unix のテキストストリーム処理を「prayer-based parsing」と呼んで批判した。「テキストをパースして、正しくパースできたことを祈る」——最初の3行を削除して4行でなかったことを祈る、30-40列を切り出してスペースがタブでなかったことを祈る、整数にキャストして32ビットだったことを祈る、という具体例を挙げた
- **一次ソース**: Jeffrey P. Snover, "Monad Manifesto", 2002; The New Stack記事
- **URL**: <https://www.jsnover.com/Docs/MonadManifesto.pdf>, <https://thenewstack.io/jeffrey-snover-remembers-the-fight-to-launch-powershell/>
- **注意事項**: Manifestoでは Unix の実装を「flawed implementation」of composabilityと表現
- **記事での表現**: 「Snoverはこれを『prayer-based parsing（祈り駆動パース）』と呼んだ」

## 3. Monad から PowerShell への改名

- **結論**: 2006年4月25日、MicrosoftはMonadを「Windows PowerShell」に正式改名。同時にRelease Candidate 1を公開。改名の意味は、単なるアドオンではなくWindowsの構成要素として位置づけられたこと
- **一次ソース**: Microsoft Windows Server Blog, "Monad's new name - Windows PowerShell", April 25, 2006; Keith Hill's Blog
- **URL**: <https://www.microsoft.com/en-us/windows-server/blog/2006/04/25/monads-new-name-windows-powershell>, <https://rkeithhill.wordpress.com/2006/04/25/new-name-for-monad-windows-powershell/>
- **注意事項**: 最初の公開デモは2003年10月のProfessional Developers Conference（ロサンゼルス）
- **記事での表現**: 「2006年4月25日、MonadはWindows PowerShellに改名された」

## 4. PowerShell 1.0 リリース日

- **結論**: 2006年11月14日、ITForum（バルセロナ）のキーノートでWindows PowerShell 1.0の最終リリースが発表された。対応OS: Windows XP SP2, Windows Server 2003 SP1, Windows Vista
- **一次ソース**: PowerShell Team Blog, "It's a Wrap! Windows PowerShell 1.0 Released!"
- **URL**: <https://devblogs.microsoft.com/powershell/its-a-wrap-windows-powershell-1-0-released/>
- **注意事項**: Windows Server 2008ではオプションコンポーネントとして同梱
- **記事での表現**: 「2006年11月14日、Windows PowerShell 1.0がリリースされた」

## 5. PowerShell Core（オープンソース化・クロスプラットフォーム）

- **結論**: 2016年8月18日、MicrosoftはPowerShellをオープンソース化し、クロスプラットフォーム対応（Windows, macOS, Linux）を発表。GitHubでソースコード公開。MITライセンス。PowerShell Core 6.0のGA（一般提供）は2018年1月10日
- **一次ソース**: Scott Hanselman's Blog, "Announcing PowerShell on Linux"; PowerShell Wikipedia
- **URL**: <https://www.hanselman.com/blog/announcing-powershell-on-linux-powershell-is-open-source>, <https://en.wikipedia.org/wiki/PowerShell>
- **注意事項**: Core 6.0は.NET Coreベース。「PowerShell Core」という名称はこの時に生まれた
- **記事での表現**: 「2016年8月18日、MicrosoftはPowerShellをオープンソース化し、Linux・macOSへの対応を発表した」

## 6. PowerShell バージョン履歴

- **結論**:
  - 1.0: 2006年11月（Windows XP SP2/Server 2003 SP1/Vista）
  - 2.0: 2009年10月（Windows 7/Server 2008 R2に統合、リモーティング、ジョブ、モジュール）
  - 3.0: 2012年9月（Windows 8/Server 2012、ワークフロー）
  - 4.0: 2013年10月（Windows 8.1/Server 2012 R2、DSC）
  - 5.0: 2016年2月（Windows 10、クラス、PackageManagement）
  - 5.1: 2016年8月（Desktop/Coreの2エディション）
  - Core 6.0: 2018年1月（クロスプラットフォーム、オープンソース、.NET Core）
  - 7.0: 2020年3月（.NET Core 3.1、「Core」名称を廃止し「PowerShell」に統一）
  - 7.5: 2025年1月（.NET 9.0.1、最新安定版）
- **一次ソース**: Wikipedia "PowerShell"; Microsoft Learn; IT-Connect
- **URL**: <https://en.wikipedia.org/wiki/PowerShell>, <https://www.it-connect.tech/chapitres/powershell-version-history/>
- **注意事項**: 7.0で「PowerShell Core」から「PowerShell」に名称を戻した。7.4がLTS版（2026年11月までサポート）
- **記事での表現**: バージョン表として整理

## 7. Verb-Noun 命名規則

- **結論**: PowerShellのcmdletはVerb-Noun形式（例: Get-Process, Set-Location, Remove-Item）で統一。動詞はMicrosoftが定義した「承認された動詞リスト」（Approved Verbs）から選択。対称性あり（Add/Remove, Enter/Exit, Get/Set, Push/Pop等）。名詞は単数形。この規則により自己文書化と発見可能性を実現
- **一次ソース**: Microsoft Learn, "Approved Verbs for PowerShell Commands"
- **URL**: <https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.5>
- **注意事項**: カスタムcmdletでも承認された動詞の使用が強く推奨されている
- **記事での表現**: 「Get-Process, Set-Location, Remove-Item——すべてのコマンドがVerb-Noun形式で統一されている」

## 8. .NETオブジェクトパイプラインの設計

- **結論**: PowerShellのパイプラインはバイトストリームではなく.NETオブジェクトを渡す。cmdletの出力はStructured .NET objectsであり、受信側cmdletはByValue（型一致）またはByPropertyName（プロパティ名一致）でパイプライン入力を受け取る。テキストのシリアライズ/デシリアライズが不要
- **一次ソース**: Microsoft Learn, "about_Pipelines"
- **URL**: <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7.5>
- **注意事項**: 各オブジェクトはコレクション全体が処理されるのを待たず、一つずつパイプラインを流れる（ストリーミング処理）
- **記事での表現**: 「パイプラインを流れるのはテキストではなく.NETオブジェクトだ」

## 9. フォーマッティングレイヤーの分離

- **結論**: PowerShellはデータ（オブジェクト）と表示（フォーマット）を明確に分離。Format-Table, Format-List, Format-Wide, Format-Customがフォーマットを担当し、Out-Host, Out-Fileが出力を担当。フォーマットcmdletはデータを「フォーマッティングデータ」に変換し、それ以降は他のcmdletで処理できない。データ処理はフォーマット前に行う必要がある
- **一次ソース**: Microsoft Learn, "Using Format commands to change output view"
- **URL**: <https://learn.microsoft.com/en-us/powershell/scripting/samples/using-format-commands-to-change-output-view?view=powershell-7.5>
- **注意事項**: デフォルトではPowerShellがオブジェクトの型に応じて最適なフォーマットを自動選択する
- **記事での表現**: 「PowerShellはデータと表示を分離した。パイプラインにはオブジェクトが流れ、人間が見る段階で初めてテーブルやリストに整形される」

## 10. Jeffrey Snoverの経歴・引退

- **結論**: Snoverは2022年にMicrosoftを退社（23年在籍）し、GoogleにDistinguished Engineer（SRE部門）として転職。2026年1月に引退。引退後は「Philosopher-Errant」を自称し、Science & Technology Conference参加・講演を行っている。Microsoft在籍中は2012年にBruce Payette、James Truherと共にUSENIX LISA Outstanding Achievement Awardを受賞。2015年にTechnical Fellowに昇格
- **一次ソース**: The Register, "PowerShell architect retires after decades at the prompt", January 22, 2026; Wikipedia
- **URL**: <https://www.theregister.com/2026/01/22/powershell_snover_retires/>, <https://en.wikipedia.org/wiki/Jeffrey_Snover>
- **注意事項**: Snoverは Microsoft で一度降格されたと公言している（PowerShell開発への注力が評価されなかった時期がある）
- **記事での表現**: 「2026年1月、PowerShellの父Jeffrey Snoverが引退した。23年のMicrosoft、その後のGoogleを経て」

## 11. PowerShell GitHubリポジトリ統計

- **結論**: PowerShell/PowerShellリポジトリは2026年2月時点で約51,500スターを獲得。MITライセンス
- **一次ソース**: GitHub, PowerShell/PowerShell
- **URL**: <https://github.com/PowerShell/PowerShell>
- **注意事項**: Nushellの約31,000スターと比較すると規模の差がある
- **記事での表現**: 「GitHubで5万以上のスターを集めるPowerShellリポジトリ」

## 12. NushellとPowerShellの関係

- **結論**: Nushellの誕生にPowerShellは直接的な影響を与えた。Yehuda KatzがPowerShellのデモをSophia Turner（当時Jonathan Turner）に見せ、「PowerShellの構造化シェルの発想を、オブジェクト指向ではなく関数型に寄せて作れないか」と提案したのがきっかけ
- **一次ソース**: Nushell公式ブログ "Introducing nushell", 2019; The Changelog Podcast #363
- **URL**: <https://www.nushell.sh/blog/2019-08-23-introducing-nushell.html>, <https://changelog.com/podcast/363>
- **注意事項**: Nushellの公式サイトでもPowerShellをインスピレーション源として明記
- **記事での表現**: 「Nushellがインスピレーションを受けたと公言しているその源流がPowerShellだ」
