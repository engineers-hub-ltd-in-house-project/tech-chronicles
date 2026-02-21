# ファクトチェック記録：第18回「TUIの復権――Charm, Bubbletea, Ink, Textual」

## 1. Norton Commander の初期リリース

- **結論**: Norton Commanderは1986年5月にリリースされた。開発者はJohn Sochaで、Peter Norton Computing（1990年にSymantecが買収）から発売。1984年秋にCornell大学の大学院生だったSochaが開発を開始し、当初は「Visual DOS（VDOS）」と呼んでいた。1986年から1998年まで生産され、最終DOS版は5.51（1998年7月1日）
- **一次ソース**: Wikipedia, Norton Commander; softpanorama.org
- **URL**: <https://en.wikipedia.org/wiki/Norton_Commander>
- **注意事項**: InfoWorld（1988年1月）はv1.0を「way ahead of the pack」と評価。速度、省メモリ、2パネル同時表示を高評価
- **記事での表現**: Norton Commander（1986年、John Socha）として記述。二画面ファイルマネージャの原型として言及

## 2. Midnight Commander の初期リリース

- **結論**: Miguel de Icazaが1994年に開発を開始。v0.3は1994年5月リリース（極めてプリミティブ）、v0.14（1994年9月）で初めてNorton Commander的な動作に。v1.0は1994年10月29日リリース。GNUプロジェクトの一部
- **一次ソース**: Wikipedia, Midnight Commander; softpanorama.org
- **URL**: <https://en.wikipedia.org/wiki/Midnight_Commander>
- **注意事項**: Miguel de IcazaはのちにGNOMEプロジェクト、Mono、Xamarinの創設者として知られる
- **記事での表現**: Midnight Commander（1994年、Miguel de Icaza）として記述

## 3. mutt メールクライアント

- **結論**: Michael Elkinsが1995年に開発・公開。ELMメールクライアントのインターフェースを基に一から書かれた。v1.0は1999年10月リリース。2015年以降Kevin McCarthyが主要メンテナ
- **一次ソース**: Wikipedia, Mutt (email client); mutt.org
- **URL**: <https://en.wikipedia.org/wiki/Mutt_(email_client)>
- **注意事項**: 初期開発1995年、v1.0リリースは1999年
- **記事での表現**: mutt（1995年、Michael Elkins）として記述

## 4. ncurses ライブラリ

- **結論**: Zeyd Ben-HalimがPavel Curtisのpcursesライブラリをベースにncursesとして1993年11月にv1.8.1をリリース。Eric S. Raymondがformとmenuライブラリを追加（1995年まで）。1996年にThomas E. Dickeyがメンテナンスを引き継ぎ、現在まで継続
- **一次ソース**: invisible-island.net (Thomas Dickey); Wikipedia, ncurses
- **URL**: <https://invisible-island.net/ncurses/>
- **注意事項**: 元のcursesライブラリはKen Arnold（1978年、UCB）が開発
- **記事での表現**: ncurses（1993年）、Thomas Dickeyが1996年からメンテナンス

## 5. Charm / Bubbletea

- **結論**: Charm社はToby PadillaとChristian Rochaが2019年に設立。Bubbleteaは2020年10月頃に公開。Elm Architectureに基づく設計（Model-Update-View）。Go言語で実装。2023年11月にGoogleのGradient Venturesからの出資を受けた
- **一次ソース**: GitHub charmbracelet/bubbletea; TechCrunch（2023年11月2日）; Internet Archive snapshots (2020年10月)
- **URL**: <https://github.com/charmbracelet/bubbletea>, <https://techcrunch.com/2023/11/02/charm-offensive-googles-gradient-backs-this-startup-to-bring-more-pizzazz-to-the-command-line/>
- **注意事項**: Elm Architectureは元々Evan Czaplickiが2012年のHarvard大学の論文で設計したElm言語から生まれたパターン
- **記事での表現**: Bubbletea（2020年、Charm社）、Elm Architectureに基づくTUIフレームワーク

## 6. Ink（React for CLI）

- **結論**: Vadim Demedesが2017年に公開。ReactのコンポーネントモデルをCLIに適用。YogaライブラリによるFlexboxレイアウト。Node.js/TypeScript環境で動作
- **一次ソース**: GitHub vadimdemedes/ink; vadimdemedes.com
- **URL**: <https://github.com/vadimdemedes/ink>
- **注意事項**: Ink 3が主要なメジャーアップデート
- **記事での表現**: Ink（2017年、Vadim Demedes）として記述

## 7. Textual（Python TUIフレームワーク）

- **結論**: Will McGuganが2021年に開発開始。Richライブラリの上に構築。McGuganは2021年末にTextualize社を設立。Textual 1.0は2024年12月12日リリース（3年の開発期間）。Textualize社は2025年に事業を終了したが、OSSプロジェクトとしては継続中
- **一次ソース**: textual.textualize.io; X/Twitter (@willmcgugan); sourcery.ai interview
- **URL**: <https://textual.textualize.io/blog/2025/05/07/the-future-of-textualize/>
- **注意事項**: CSSライクなスタイリングシステムが特徴。会社は終了したがOSSコミュニティは健全
- **記事での表現**: Textual（2021年、Will McGugan）として記述。CSSライクレイアウトに言及

## 8. Ratatui（Rust TUIフレームワーク）

- **結論**: Florian Dehauが元のtui-rsを2016年頃に公開（v0.1.2は2016年12月25日）。2023年にメンテナンス停止後、コミュニティがフォークしてRatatuiとして継続。2023年7月8日にDehauがtui-rsリポジトリをアーカイブし、Ratatuiが公式後継に。Orhun Parmaksizが主導
- **一次ソース**: crates.io/crates/tui; GitHub ratatui/ratatui; blog.orhun.dev
- **URL**: <https://github.com/ratatui/ratatui>, <https://blog.orhun.dev/ratatui-0-23-0/>
- **注意事項**: exa→ezaと同様のコミュニティフォークパターン
- **記事での表現**: tui-rs（2016年、Florian Dehau）→ Ratatui（2023年、コミュニティフォーク）

## 9. lazygit

- **結論**: Jesse Duffieldが2018年8月5日にリリース。Go言語で実装。2023年にプロジェクト5周年を迎えた
- **一次ソース**: jesseduffield.com blog "Lazygit Turns 5"; GitHub jesseduffield/lazygit
- **URL**: <https://jesseduffield.com/Lazygit-5-Years-On/>, <https://github.com/jesseduffield/lazygit>
- **注意事項**: TUI Git クライアントとして非常に人気が高い
- **記事での表現**: lazygit（2018年、Jesse Duffield）として記述

## 10. htop

- **結論**: Hisham Muhammadが2004年5月に公開。v1.0は2011年11月20日。v2.0は2016年2月11日（FreeBSD/macOS対応）。2019年にMuhammadの活動が低下し、2020年にhtop-devコミュニティが引き継ぎ（v3.0リリース、Unicode対応）
- **一次ソース**: htop.dev; GitHub htop-dev/htop; Wikipedia
- **URL**: <https://htop.dev/>, <https://en.wikipedia.org/wiki/Htop>
- **注意事項**: topの代替として設計。htop→htop-devのメンテナンス移行はOSSの持続性の事例
- **記事での表現**: htop（2004年、Hisham Muhammad）として記述

## 11. k9s（Kubernetes TUI）

- **結論**: Fernand Galianaが開発。最初のコミットは2019年2月1日。Go言語で実装。2020年11月時点でGitHub星約10,000
- **一次ソース**: GitHub derailed/k9s; k9scli.io
- **URL**: <https://github.com/derailed/k9s>
- **注意事項**: Kubernetes管理のためのTUIとして広く利用
- **記事での表現**: k9s（2019年、Fernand Galiana）として記述

## 12. Wish（SSH TUIフレームワーク）

- **結論**: Charm社が開発。SSHサーバ上でBubbleteaアプリケーションを提供するフレームワーク。各SSHセッションが独自のtea.Programを持ち、pty入出力が接続される。ウィンドウサイズ変更にも対応。Soft Serve（セルフホスト型Gitサーバ）がWishの代表的な応用例
- **一次ソース**: GitHub charmbracelet/wish; charm.land blog
- **URL**: <https://github.com/charmbracelet/wish>
- **注意事項**: SSH経由でTUIを配信する新しいパラダイム
- **記事での表現**: Wish（Charm社）として記述。SSH越しのTUI配信に言及
