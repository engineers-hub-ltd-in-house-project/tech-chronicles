# ファクトチェック記録：第18回「fish――意図的にPOSIXを捨てたシェル」

## 1. fishの誕生とAxel Liljencrantz

- **結論**: fishの最初のリリースは2005年2月13日。開発者はAxel Liljencrantz。「friendly interactive shell」の略称。Liljencrantzはバージョン1.0から1.23.1（最終1.xリリースは2009年3月）までの主要開発者・メンテナだった
- **一次ソース**: LWN.net, "Fish - The friendly interactive shell", 2005年; Wikipedia, "fish (Unix shell)"
- **URL**: <https://lwn.net/Articles/136518/>, <https://en.wikipedia.org/wiki/Fish_(Unix_shell)>
- **注意事項**: Wikidata (Q307263) にも初回リリース日2005年2月13日の記録あり
- **記事での表現**: 「2005年2月、Axel LiljencrantzはLWN.netでfishを公開した」

## 2. "Finally, a command line shell for the 90s"スローガン

- **結論**: fishの公式スローガン。fishプロジェクトの初期から使用されている。「90年代のための」という皮肉を込めた表現で、2005年時点で「90年代レベルの使いやすさすら実現できていなかった」既存シェルへの批判を含む
- **一次ソース**: fishshell.com公式サイト
- **URL**: <https://fishshell.com/>
- **注意事項**: ブループリントにもこのスローガンが記載されている
- **記事での表現**: 「"Finally, a command line shell for the 90s"――このスローガンは、2005年時点のシェルが1990年代のUI水準にすら達していないという痛烈な批判だった」

## 3. ridiculousfish（Peter Ammon）とfish 2.0

- **結論**: ridiculousfish（Peter Ammon）が2011年後半に開発に参加し、2012年に「fishfish」というフォークのベータ版をリリース。これが統合されてfish 2.0となり、2013年5月17日にリリースされた。ridiculousfishはAppleのエンジニアとしても知られる
- **一次ソース**: ridiculousfish.com, "fish shell 2.0"; GitHub fish-shell/fish-shell releases
- **URL**: <https://ridiculousfish.com/blog/posts/fish_shell.html>, <https://github.com/fish-shell/fish-shell/releases>
- **注意事項**: Wikidataでは2.0のリリース日を2013年5月17日と記録。一部ソースでは9月1日とする記述もあるが、GitHubリリースページの記録を優先
- **記事での表現**: 「ridiculousfishことPeter Ammonが2012年にfishfishフォークを公開し、これが統合されてfish 2.0（2013年）となった」

## 4. fish 3.0のリリースと主要変更

- **結論**: fish 3.0.0は2018年12月28日にリリース。主要な変更点: `&&`と`||`演算子の追加（POSIX互換シェルからの移行を容易に）、`math`がビルトイン化、プライベートモード（`fish --private`）の追加、feature flagsメカニズムの導入
- **一次ソース**: GitHub, "Release fish 3.0.0 (released December 28, 2018)"
- **URL**: <https://github.com/fish-shell/fish-shell/releases/tag/3.0.0>
- **注意事項**: `&&`と`||`の追加はPOSIX非互換を維持しつつも移行の痛みを軽減する実用的判断
- **記事での表現**: 「fish 3.0（2018年12月）は`&&`と`||`演算子を追加し、bashからの移行障壁を意識的に下げた」

## 5. fish 4.0のRust移行

- **結論**: fish 4.0.0は2025年2月27日にリリース。C++からRustへの完全な書き換え。「The Fish of Theseus」（テセウスの船のfish版）と称されるアプローチで、コンポーネントを一つずつ移植し、常に動作するfishを維持しながら移行した。最初のRust PRは2023年1月28日にオープンされ、2023年2月19日にマージ。最後のC++コードは2024年1月に削除。2,600以上のコミット、200人以上のコントリビュータが参加
- **一次ソース**: fishshell.com, "Fish 4.0: The Fish Of Theseus"; GitHub Release
- **URL**: <https://fishshell.com/blog/rustport/>, <https://github.com/fish-shell/fish-shell/releases/tag/4.0.0>
- **注意事項**: ブループリントでは「fish 4.0（2024年, Rust移行完了）」とあるが、正確なリリース日は2025年2月27日。Rust 1.70以上が必要
- **記事での表現**: 「fish 4.0（2025年2月）はC++からRustへの完全移行を達成した。"The Fish of Theseus"と名付けられたこのプロジェクトは、約2年間で2,600以上のコミットを経て完了した」

## 6. fishの設計原則（公式ドキュメントから）

- **結論**: fishの公式Design documentには以下の原則が明記されている: (1) Discoverability（発見しやすさ）, (2) User Friendliness（ユーザーフレンドリー）, (3) Configurability is the root of all evil（設定可能性は諸悪の根源）。最後の原則は「設定オプションは、プログラムがユーザーの意図を自分で判断できないことの証」という思想
- **一次ソース**: fishshell.com, "Design"
- **URL**: <https://fishshell.com/docs/current/design.html>
- **注意事項**: 「Configurability is the root of all evil」は直訳すると強い表現だが、公式ドキュメントの原文
- **記事での表現**: 「fishの公式設計文書は"Configurability is the root of all evil"と宣言する」

## 7. fishのPOSIX非互換な構文設計

- **結論**: fishの主要なPOSIX非互換点: (1) 変数代入に`VAR=value`ではなく`set VAR value`を使用、(2) 制御構造が`do`...`done`ではなく`end`で終了、(3) 関数定義が`foo() { ... }`ではなく`function foo ... end`、(4) コマンド置換が`` `...` ``ではなく`(...)`, (5) プロセス置換が`<(...)`ではなく`psub`コマンド。公式に「Fish for bash users」ドキュメントが用意されている
- **一次ソース**: fishshell.com, "Fish for bash users"
- **URL**: <https://fishshell.com/docs/current/fish_for_bash_users.html>
- **注意事項**: fish 3.0で`&&`と`||`が追加されるまでは、`and`/`or`コマンドを使う必要があった
- **記事での表現**: bashとfishの構文比較表として提示

## 8. Universal Variables（ユニバーサル変数）

- **結論**: fishのユニバーサル変数は、同一マシン上のすべてのfishセッション間で共有される変数。`~/.config/fish/fish_variables`ファイルに保存され、変更は即座に全セッションに伝播する。同期にはinotify（Linux）やkqueue（macOS/BSD）を使用。変数スコープはlocal → global → universalの順で検索される
- **一次ソース**: fishshell.com, "set - display and change shell variables"; "The fish language"
- **URL**: <https://fishshell.com/docs/current/cmds/set.html>, <https://fishshell.com/docs/current/language.html>
- **注意事項**: ユニバーサル変数の更新はアトミックなファイル置換（rename）で行われる
- **記事での表現**: 「ユニバーサル変数は、シェルの設定管理に対するfishの回答だ。`.bashrc`に`export PATH=...`と書く代わりに、一度`set -U`で設定すれば、すべてのfishセッションで永続的に有効になる」

## 9. fishの構文ハイライトとオートサジェスチョン

- **結論**: 構文ハイライトはリアルタイムで動作し、入力中のコマンドが存在しなければ赤色で表示される。オートサジェスチョンはコマンド履歴と補完システムの両方をソースとし、入力中にグレー色で候補を表示する。fish 4.2.0以降では複数行コマンドの個別行もサジェスチョン対象となった。設定なしでデフォルトで有効
- **一次ソース**: fishshell.com, "Interactive use"; "Tutorial"
- **URL**: <https://fishshell.com/docs/current/interactive.html>, <https://fishshell.com/docs/current/tutorial.html>
- **注意事項**: zshでは構文ハイライトにzsh-syntax-highlightingプラグインが必要。fishは組み込み
- **記事での表現**: 「fishでは構文ハイライトとオートサジェスチョンがデフォルトで有効だ。設定ファイルに一行も書く必要がない」

## 10. fishのライセンス

- **結論**: fishはGPLv2（GNU General Public License version 2）の下でリリースされている。bashと同じGPLファミリーだが、v3ではなくv2。一部のコンポーネント（Alpine.js、FindRust.cmake、Dracula/Nordテーマなど）はMITライセンス
- **一次ソース**: fishshell.com, "License"
- **URL**: <https://fishshell.com/docs/current/license.html>
- **注意事項**: ブループリントでは言及されていないが、fishがGPLv2であることは重要な事実。zsh（MIT-like）やbash 4.0以降（GPLv3）との対比で意味がある
- **記事での表現**: 「fishのライセンスはGPLv2だ。bash 4.0以降のGPLv3とは異なり、v2を維持している」

## 11. fishのWeb-based configuration（fish_config）

- **結論**: `fish_config`コマンドでローカルWebサーバーを起動し、ブラウザ上でプロンプト、カラー、関数、変数、ヒストリを視覚的に設定できる。テーマの切り替え、プロンプトの選択が可能。`fish_config prompt show`でプロンプトのプレビュー、`fish_config theme`でテーマ管理も可能
- **一次ソース**: fishshell.com, "fish_config"
- **URL**: <https://fishshell.com/docs/current/cmds/fish_config.html>
- **注意事項**: これはfishの「設定よりも規約」思想の延長。設定ファイルを手書きする代わりにGUIを提供
- **記事での表現**: 「fish_configはローカルWebサーバーを起動し、ブラウザ上でシェルの見た目を設定する。.bashrcをテキストエディタで編集する世界とは、根本的に異なるアプローチだ」

## 12. GitHub統計

- **結論**: fish-shell/fish-shellリポジトリは約28,000以上のGitHub Stars（2025年時点）。主要コントリビュータ: @ridiculousfish (Peter Ammon), @faho (Fabian Homborg), @krobelus, @liljencrantz (Axel Liljencrantz), @mqudsi (Mahmoud Al-Qudsi)
- **一次ソース**: GitHub, fish-shell/fish-shell
- **URL**: <https://github.com/fish-shell/fish-shell>
- **注意事項**: Stars数は変動するため、「約28,000以上」と幅を持たせる
- **記事での表現**: 正確な数値は本文では言及せず、「GitHubで数万のStarsを獲得したプロジェクト」程度の記述にとどめる
