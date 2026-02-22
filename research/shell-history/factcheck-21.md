# ファクトチェック記録：第21回「次世代シェルの挑戦――Nushell、Oil/YSH、Elvish、その先へ」

## 1. Nushellの創設者と発表時期

- **結論**: Nushellは2019年8月23日にSophia Turner（当時Jonathan Turner）によって公式ブログで発表された。共同開発者はYehuda KatzとAndres N. Robalino。Yehuda KatzがPowerShellのデモを見せたことがきっかけで、構造化シェルのアイデアが生まれた。Rust製。
- **一次ソース**: Sophia Turner, "Introducing nushell", nushell.sh blog, 2019-08-23
- **URL**: <https://www.nushell.sh/blog/2019-08-23-introducing-nushell.html>
- **注意事項**: 創設者のSophia Turnerは、Nushell発表当時はJonathan Turnerとして活動していた。記事ではSophia Turner表記を使用する。
- **記事での表現**: 「2019年8月、Sophia Turner（当時はJonathan Turnerとして知られていた）がNushellを発表した。共同開発者のYehuda KatzがPowerShellのデモを見せたことがきっかけだった」

## 2. Nushellの構造化データパイプライン

- **結論**: Nushellはテキストストリームではなく構造化データ（テーブル）をパイプラインで渡す。JSON、TOML、YAML、CSV等のファイルを自動的にテーブルとして解釈する。DataFrameはApache Arrow仕様に基づく列指向フォーマットで、Polarsエンジンを使用して高速な列操作を実現する。
- **一次ソース**: Nushell公式ドキュメント, "Dataframes"
- **URL**: <https://www.nushell.sh/book/dataframes.html>
- **注意事項**: DataFrameはNushell本体ではなくPolarsプラグインとして提供される。
- **記事での表現**: 「Nushellの`ls`はテーブルを返す。`ls | where type == "dir"`とすれば、grepもawkも不要だ」

## 3. NushellのGitHub規模

- **結論**: 2025年時点でGitHub上で約35,500スターを獲得。活発なコミュニティ開発が継続しており、2024年末時点で0.101.0がリリースされている。
- **一次ソース**: GitHub nushell/nushell
- **URL**: <https://github.com/nushell/nushell>
- **注意事項**: スター数は変動するため、記事では「3万を超える」程度の表現にする。
- **記事での表現**: 「GitHubで3万以上のスターを集め、次世代シェルの中で最も注目を集めるプロジェクトとなっている」

## 4. Oil Shell / Oils / YSHの経緯

- **結論**: Andy Chuが2016年頃にプロジェクトを開始。OSH（bash互換シェル）とOil言語（新言語）の二本立て。2023年3月にOil言語をYSHに改名（"Oil"の石油連想と"Shell Oil"社との混同を回避するため）。プロジェクト全体はOilsと呼称。Pythonで実装し、カスタムツールでC++にトランスパイルして高速化。
- **一次ソース**: Andy Chu, "Reasons for the Big Renaming to Oils, OSH, and YSH", oilshell.org, 2023-03
- **URL**: <https://www.oilshell.org/blog/2023/03/rename.html>
- **注意事項**: 2025年にドメインもoilshell.orgからoils.pubに移行。YSHの名前は"the shell with haY"に由来。
- **記事での表現**: 「Andy Chuは2016年、bashの言語設計を真正面から設計し直すプロジェクトを始めた。OSHはbash互換シェルとして既存スクリプトを実行し、YSH（旧Oil言語）は新たなシェル言語として設計された」

## 5. YSHの言語機能

- **結論**: YSHはシェルコマンド風の構文、Python/JavaScript風の型付きデータに対する式、Ruby風のコマンドブロックを持つ。変数はvar/constで宣言、型付きproc/funcをサポート。リスト、辞書、整数、浮動小数点、文字列を扱える。Wadlerアルゴリズムによるpretty printerも実装（0.22.0）。
- **一次ソース**: Oils公式, "A Tour of YSH"
- **URL**: <https://oils.pub/release/latest/doc/ysh-tour.html>
- **注意事項**: OSHとYSHは同一ランタイムの二つのモード。bin/oshとbin/yshで使い分ける。
- **記事での表現**: 「YSHでは`var x = [1, 2, 3]`のようにリストを宣言し、`for item in (x) { echo $item }`のように反復できる。bash互換のOSHから段階的にYSHへ移行するパスが設計されている」

## 6. Elvishの創設者と発表時期

- **結論**: ElvishはQi Xiao（xiaq）が2014年頃から開発を開始。Go言語で実装。2025年時点でpre-1.0（バージョン0.21.x）だが、日常的な対話利用とスクリプティングに十分な安定性を持つ。
- **一次ソース**: Elvish公式サイト, GitHub elves/elvish
- **URL**: <https://elv.sh/>, <https://github.com/elves/elvish>
- **注意事項**: ブループリントではXiaoyi Chenと記載されているが、正確にはQi Xiao。
- **記事での表現**: 「2014年頃、Qi XiaoはElvishの開発を始めた。Go言語で書かれたこのシェルは、構造化データパイプライン、名前空間、例外処理、クロージャを備える」

## 7. Elvishの技術的特徴

- **結論**: パイプラインにリスト、マップ、クロージャなどの構造化データを流せる。例外処理はfailコマンドで投げ、try特殊コマンドでキャッチする（Python/Java類似セマンティクス）。ラムダは第一級値。名前空間による変数のスコープ管理。
- **一次ソース**: Elvish公式, "Effective Elvish", "Unique Semantics"
- **URL**: <https://elv.sh/learn/effective-elvish.html>, <https://elv.sh/learn/unique-semantics.html>
- **注意事項**: POSIX互換を目標としていない独自設計。
- **記事での表現**: 「Elvishのパイプラインはテキストだけでなく、リスト、マップ、クロージャすら流せる。`try { fail "error" } catch e { echo $e }`のような例外処理も組み込まれている」

## 8. Xonshの創設者と特徴

- **結論**: Anthony Scopatzが開発。2015年頃に公開、2016年1月に正式リリース。Python 3のスーパーセットとシェルコマンドをシームレスに統合したハイブリッドシェル。Python式とシェルコマンドを一行の中で自由に混在できる。
- **一次ソース**: Anthony Scopatz, "Anthony Scopatz on xonsh", Python Podcast, 2016; xon.sh公式サイト
- **URL**: <https://xon.sh/>, <https://www.pythonpodcast.com/episodepage/anthony-scopatz-on-xonsh>
- **注意事項**: 発音は"conch"（コンク）。
- **記事での表現**: 「Anthony Scopatzが2015年頃に公開したXonsh（"conch"と発音する）は、Python 3のスーパーセットにシェル機能を統合したハイブリッドだ」

## 9. Murexの創設者と特徴

- **結論**: Laurence Morgan（GitHub: lmorg）がGo言語で開発。型付きパイプ（バイトストリームにデータ型アノテーションを付与）が特徴。80以上の組み込みコマンド。JSON、YAML、XML、CSV等をネイティブサポート。try/catchブロック、インラインスペルチェック、manページ自動解析による補完。GPLv2ライセンス。
- **一次ソース**: GitHub lmorg/murex, murex.rocks
- **URL**: <https://github.com/lmorg/murex>, <https://murex.rocks/>
- **注意事項**: POSIXパイプとの互換性を保ちつつ型情報を付加する設計。
- **記事での表現**: 「Laurence Morganが開発したMurexは、POSIXパイプのバイトストリームに型アノテーションを付加するアプローチをとった」

## 10. 次世代シェルの互換性 vs 革新性のトレードオフ

- **結論**: 各シェルの戦略は大きく異なる。Nushell: POSIX非互換、完全新設計。Oil/YSH: OSHでbash互換を保ちつつYSHで新言語を提供（段階的移行パス）。Elvish: POSIX非互換、独自設計。fish: POSIX非互換だが既存コマンドとの統合は重視。どのシェルが10年後に主流になるかは不明。
- **一次ソース**: Lobsters "Bash vs Fish vs Zsh vs Nushell" 議論; shells comparison gist
- **URL**: <https://lobste.rs/s/qoccbl/bash_vs_fish_vs_zsh_vs_nushell>
- **注意事項**: bashは依然として最も広く使われ、サポートされているシェル。
- **記事での表現**: 「Nushellは白紙からの再設計、Oil/YSHはbashとの互換性を保つ段階的移行、Elvishは独自言語設計。三者三様の戦略が『テキストストリームの限界』と『POSIX互換性の呪縛』に挑んでいる」
