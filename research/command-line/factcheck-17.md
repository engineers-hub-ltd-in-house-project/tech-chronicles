# ファクトチェック記録：第17回「Rust製CLIツールの波――ripgrep, fd, bat, eza」

## 1. ripgrepの公開とAndrew Gallant

- **結論**: ripgrepは2016年9月にAndrew Gallant（GitHub: BurntSushi）が公開。crates.ioへの最初の公開は2016年9月13日頃（0.0.2-0.0.9が9月6日前後に公開）。紹介ブログ記事「ripgrep is faster than {grep, ag, git grep, ucg, pt, sift}」は2016年9月23日に公開。開発は2016年3月11日にリポジトリ作成から開始。Gallantはテキスト検索に関するRust作業を2.5年間行っていた
- **一次ソース**: Andrew Gallant's Blog, crates.io, GitHub releases
- **URL**: <https://burntsushi.net/ripgrep/>, <https://crates.io/crates/ripgrep/versions>, <https://github.com/BurntSushi/ripgrep/releases>
- **注意事項**: ブループリントでは「2016年」としており正確。リポジトリ作成は3月だが一般公開は9月
- **記事での表現**: 「2016年9月、Andrew Gallantはripgrepを公開した」

## 2. ripgrepの高速化技術

- **結論**: ripgrepの高速化は複数の技術による。(1) Teddy SIMDアルゴリズム: Geoffrey LangdaleがIntel Hyperscanの一部として発明。16バイトのパック比較でリテラルマッチの候補位置を検出。(2) メモリマップドI/O: 単一ファイル検索に有効、大規模ディレクトリ検索にはインクリメンタルバッファリング。ripgrepは自動選択する。(3) 並列ディレクトリ走査: デフォルトでマルチスレッド。(4) .gitignore互換グロブエンジン
- **一次ソース**: Andrew Gallant's Blog "ripgrep is faster than...", GitHub ripgrep README, ripgrep discussions #1822
- **URL**: <https://burntsushi.net/ripgrep/>, <https://github.com/BurntSushi/ripgrep/discussions/1822>
- **注意事項**: ブループリントでは「Aho-Corasick」と記載があるが、実際にはTeddyアルゴリズム（SIMDベース）がメインの高速化手法。Aho-CorasickはTeddyが使えない場合のフォールバック
- **記事での表現**: 「ripgrepはTeddyと呼ばれるSIMDベースのアルゴリズムを使い、16バイト単位のパック比較でリテラル候補位置を高速検出する」

## 3. fd（fd-find）の公開

- **結論**: fdはDavid Peter（GitHub: sharkdp）が開発したfindの代替ツール。Internet Archiveに2017年11月3日時点のスナップショットが存在し、2017年時点で公開されていたことが確認できる。Rustで書かれ、並列ディレクトリ走査、.gitignore尊重、デフォルト色付き出力を特徴とする
- **一次ソース**: GitHub sharkdp/fd, Internet Archive snapshot
- **URL**: <https://github.com/sharkdp/fd>, <https://archive.org/details/github.com-sharkdp-fd_-_2017-11-03_03-13-19>
- **注意事項**: ブループリントでは「2017年」としており整合する
- **記事での表現**: 「2017年、David Peterがfindの代替ツールfdを公開した」

## 4. bat（catクローン）の公開

- **結論**: batはDavid Peter（GitHub: sharkdp）が開発したcat(1)のクローン。Copyright表記は2018-2025。Internet Archiveに2018年5月30日のスナップショットが存在。シンタックスハイライトにsyntectライブラリ（Sublime Text構文定義を利用）を使用。Git統合機能あり
- **一次ソース**: GitHub sharkdp/bat, Internet Archive snapshots
- **URL**: <https://github.com/sharkdp/bat>, <https://archive.org/details/github.com-sharkdp-bat_-_2018-05-30_19-32-41>
- **注意事項**: ブループリントでは「2018年」としており整合する
- **記事での表現**: 「2018年、David Peterはcat(1)のクローンbatを公開した」

## 5. exa/ezaの歴史

- **結論**: exaはBenjamin Sago（GitHub: ogham）が開発。Wikidata上の初期リリースは2015年2月21日（v0.1.0）。lsの代替としてRustで実装。oghamが不在となりメンテナンスが停滞。2023年9月にoghamが公式にメンテナンス停止を案内し、eza（コミュニティフォーク）への移行を推奨。ezaの最初のリリースは2023年7月31日（v0.10.3）
- **一次ソース**: Wikidata Q57838499, GitHub ogham/exa issue #1243, GitHub eza-community/eza
- **URL**: <https://github.com/ogham/exa>, <https://github.com/ogham/exa/issues/1243>, <https://github.com/eza-community/eza>
- **注意事項**: ブループリントでは「exa→eza（2014年/2023年）」と記載があるが、Wikidataの記録では初期リリースは2015年2月。2014年はリポジトリの初期コミットの可能性。記事では2014年の記述を避け「2015年」とする
- **記事での表現**: 「2015年、Benjamin Sagoがlsの代替としてexaを公開した。2023年、メンテナンスが停滞したexaのコミュニティフォークとしてezaが生まれた」

## 6. Rust 1.0安定版リリース

- **結論**: Rust 1.0は2015年5月15日にリリースされた。最初の安定版リリースであり、Rustが本番利用可能であることを示した。1年後には1,400人以上のコントリビュータと5,000以上のサードパーティライブラリがcrates.ioに登録されていた。6週間ごとのリリースサイクル（Firefoxモデル）を採用
- **一次ソース**: Rust公式ブログ "Announcing Rust 1.0"
- **URL**: <https://blog.rust-lang.org/2015/05/15/Rust-1.0/>
- **注意事項**: ブループリントでは「2010年/2015年安定版」と記載。Rust自体の開発は2010年頃から（Mozillaの研究プロジェクト）
- **記事での表現**: 「2015年5月、Rust 1.0がリリースされた。この安定版リリースが、Rust製CLIツールの爆発的な開発を可能にした」

## 7. delta（git diff viewer）

- **結論**: deltaはDan Davison（GitHub: dandavison）が開発。git、diff、grep、blame出力のシンタックスハイライト付きページャ。Rust製。サイドバイサイドビュー、行レベル・単語レベルのdiffハイライト（Levenshtein編集距離アルゴリズム）を特徴とする
- **一次ソース**: GitHub dandavison/delta
- **URL**: <https://github.com/dandavison/delta>
- **注意事項**: 正確なリリース年の特定は困難だが、Hacker Newsへの投稿（2020年5月頃）が確認できる
- **記事での表現**: 「deltaはDan DavisonによるRust製のgit diff viewer」

## 8. zoxide（cd代替）

- **結論**: zoxideはAjeet D'Souza（GitHub: ajeetdsouza）が開発。zやautojumpにインスパイアされたスマートなcd代替。ディレクトリの使用頻度を記録し、少ないキーストロークでジャンプできる。すべての主要シェルをサポート
- **一次ソース**: GitHub ajeetdsouza/zoxide
- **URL**: <https://github.com/ajeetdsouza/zoxide>
- **注意事項**: 初期リリースの正確な年は未確認だが、2020年前後の可能性が高い
- **記事での表現**: 「zoxideはAjeet D'Souzaが開発したスマートなcd代替ツール」

## 9. starship（クロスシェルプロンプト）

- **結論**: starshipは2019年にリリースされたクロスシェルプロンプト。Rust製。Bash、Fish、Zsh、Ion、Tcsh、Elvish、Nu、Xonsh、Cmd、PowerShellをサポート。高速性、イントロスペクタビリティ、クロスシェル対応を特徴とする
- **一次ソース**: starship.rs, Linux Uprising Blog (2019年9月の記事)
- **URL**: <https://starship.rs/>, <https://www.linuxuprising.com/2019/09/starship-is-minimal-and-fast-shell.html>
- **注意事項**: 初回リリースは2019年6月とされる
- **記事での表現**: 「2019年にリリースされたstarshipは、クロスシェル対応のRust製プロンプト」

## 10. hyperfine（ベンチマーキングツール）

- **結論**: hyperfineはDavid Peter（sharkdp）によるRust製コマンドラインベンチマーキングツール。名前はセシウム133の超微細準位（hyperfine levels）に由来（時間の基本単位「秒」の定義に使われる）。統計分析、ウォームアップラン、外れ値検出、CSV/JSON/Markdown出力をサポート
- **一次ソース**: GitHub sharkdp/hyperfine
- **URL**: <https://github.com/sharkdp/hyperfine>
- **注意事項**: David Peterはfd、bat、hyperfineの開発者であり、Rust CLIツールエコシステムへの重要な貢献者
- **記事での表現**: 「David Peterのhyperfineは、CLIツールのベンチマーキングに広く使われている」
