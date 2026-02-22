# ファクトチェック記録：第19回「シェル設定文化論――dotfiles、プロンプト、そしてアイデンティティ」

## 1. RUNCOM（CTSS）とrc命名規約の起源

- **結論**: Louis PouzinがCTSS上で開発した「RUNCOM」（circa 1963年）が、rc命名規約の起源である。RUNCOMは「run commands」の略で、ファイルに格納されたコマンド群を実行する仕組みだった。Pouzinは1965年にMulticsシェルの設計に関する論文を発表し、その中でRUNCOMについて記述している。Unixの`.bashrc`等の「rc」はこのRUNCOMの化石（fossil）である
- **一次ソース**: Louis Pouzin, CTSS RUNCOM; Wikipedia "RUNCOM"
- **URL**: <https://en.wikipedia.org/wiki/RUNCOM>
- **注意事項**: 年代は「circa 1963」であり、1964年とする資料もある。本記事では「1963年頃」と記述する
- **記事での表現**: 「rc命名規約のルーツは、1963年頃にLouis PouzinがMITのCTSS上で開発したRUNCOM（run commands）に遡る」

## 2. Rob Pikeによるドットファイルの起源（「バグ」としての隠しファイル）

- **結論**: Rob Pikeが2012年にGoogle+に投稿した"A lesson in shortcuts"によると、ドットファイルの隠し機能は意図的な設計ではなく、Unix V2のファイルシステム書き換え時にKen ThompsonまたはDennis Ritchieが`ls`コマンドに`.`と`..`を除外するショートカットを実装した際の副作用である。`if (name[0] == '.') continue;`と書くべきところを、`.`と`..`の完全一致チェックにしなかった
- **一次ソース**: Rob Pike, "A lesson in shortcuts", Google+ (2012年)
- **URL**: <https://glenda.0x46.net/articles/dotfiles/>
- **注意事項**: Plan 9にはドットファイルが存在しない。Pikeは「設定ファイルは$HOME/cfgや$HOME/libに置けばよい」と主張した
- **記事での表現**: 「Rob Pikeが2012年に指摘したように、ドットファイルの隠し機能はUnixの設計判断ではなく、lsコマンドの実装上のショートカットが生んだ副産物だった」

## 3. Bourne shellの.profileファイル（UNIX V7, 1979年）

- **結論**: Bourne shell（1979年、UNIX V7）はユーザーの初期化ファイルとして`~/.profile`を読み込む。ログイン時、まず`/etc/profile`が実行され、次にユーザーの`~/.profile`が実行される。これがUnixにおけるシェル設定ファイルの始まりである
- **一次ソース**: Bourne shell documentation; Wikipedia "Bourne shell"
- **URL**: <https://en.wikipedia.org/wiki/Bourne_shell>
- **注意事項**: bashの`.bash_profile`は`.profile`との後方互換性のために存在する
- **記事での表現**: 「Bourne shellが導入した~/.profileは、ユーザーごとのシェル設定の原点である」

## 4. bashの初期化ファイル読み込み順序

- **結論**: bashの初期化ファイルはシェルの種類によって異なる。対話的ログインシェル: `/etc/profile` → `~/.bash_profile`（または`~/.bash_login`または`~/.profile`、最初に見つかったもの）。対話的非ログインシェル: `~/.bashrc`のみ。非対話的シェル: `BASH_ENV`環境変数が指すファイル
- **一次ソース**: GNU Bash Reference Manual, "Bash Startup Files"
- **URL**: <https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html>
- **注意事項**: `.bash_profile`、`.bash_login`、`.profile`は排他的で、最初に見つかったもののみ読み込まれる。多くのユーザーが`.bash_profile`から`.bashrc`をsourceする慣習がある
- **記事での表現**: 「bashのスタートアップファイルの読み込み順序は、ログインシェルと非ログインシェルで異なる」

## 5. zshの5段階初期化ファイル

- **結論**: zshの初期化ファイルは5段階: `.zshenv`（すべてのシェル呼び出しで読み込み） → `.zprofile`（ログインシェルで、`.zshrc`の前に読み込み） → `.zshrc`（対話的シェルで読み込み） → `.zlogin`（ログインシェルで読み込み） → `.zlogout`（ログインシェル終了時に読み込み）。各段階に`/etc/`版と`$ZDOTDIR/`版がある
- **一次ソース**: zsh.sourceforge.io, "An Introduction to the Z Shell - Startup Files"
- **URL**: <https://zsh.sourceforge.io/Intro/intro_3.html>
- **注意事項**: `$ZDOTDIR`が設定されていない場合は`$HOME`が使われる。`.zprofile`と`.zlogin`の両方がある点が混乱の原因
- **記事での表現**: 「zshは5段階の初期化ファイルを持つ。この複雑さは、あらゆるユースケースに対応しようとした結果だ」

## 6. XDG Base Directory Specification

- **結論**: XDG Base Directory Specificationは2003年にfreedesktop.orgによって策定された。XDGは"X Desktop Group"の略。`$XDG_CONFIG_HOME`（デフォルト`~/.config`）、`$XDG_DATA_HOME`（デフォルト`~/.local/share`）、`$XDG_CACHE_HOME`（デフォルト`~/.cache`）などの環境変数で、設定・データ・キャッシュファイルの配置を標準化する。freedesktop.orgは2000年3月にHavoc Pennington（Red HatのGNOME開発者）が設立
- **一次ソース**: freedesktop.org, "XDG Base Directory Specification"
- **URL**: <https://specifications.freedesktop.org/basedir/latest/>
- **注意事項**: fishは最初からXDG Base Directoryに準拠（`~/.config/fish/`）。bashとzshはXDG準拠していない（`~/.bashrc`、`~/.zshrc`）
- **記事での表現**: 「2003年のXDG Base Directory Specificationは、ホームディレクトリの乱雑さを整理する試みだった」

## 7. GitHub上のdotfiles文化

- **結論**: circa 2010年にGitHub社員のZach Holmanが自身のdotfilesリポジトリを公開し、トピック指向のdotfiles管理手法を広めた。Holmanは元々Ryan Batesのdotfilesをフォークしていたが、独自のアプローチに発展させた。2013年頃にGitHubはdotfiles.github.ioサイトを開設。2010年代にGitHub上でのdotfiles公開が大きなトレンドとなった
- **一次ソース**: GitHub, "holman/dotfiles"; dotfiles.github.io
- **URL**: <https://github.com/holman/dotfiles>, <https://dotfiles.github.io/>
- **注意事項**: dotfilesの共有自体はGitHub以前から存在するが、GitHubが文化的なムーブメントに発展させた
- **記事での表現**: 「2010年頃、GitHub社員のZach Holmanがdotfilesリポジトリを公開し、設定ファイルの共有が文化となった」

## 8. GNU Stow

- **結論**: GNU StowはBob Glicksteinが1993年に開発した。元々は`/usr/local`配下のソフトウェアパッケージ管理用のシンボリックリンクファームマネージャとして設計された。dotfiles管理への転用は2012年頃にBrandon Invergoが紹介して普及した
- **一次ソース**: GNU Project, "GNU Stow"; Brandon Invergo blog (2012)
- **URL**: <https://www.gnu.org/software/stow/>, <https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html>
- **注意事項**: GNU Stowはシンボリックリンクベースのアプローチ
- **記事での表現**: 「GNU Stow（1993年、Bob Glickstein）は元々ソフトウェアパッケージ管理用だったが、2012年頃からdotfiles管理に転用された」

## 9. chezmoi

- **結論**: chezmoiはTom Payneが2018年に開発した、Go言語製のdotfiles管理ツール。名前はフランス語で「chez moi」（私の家）の意。テンプレート機能により、複数マシンへの異なる設定の配布が可能。シンボリックリンクではなくファイルコピー方式を採用
- **一次ソース**: GitHub, "twpayne/chezmoi"; chezmoi.io
- **URL**: <https://github.com/twpayne/chezmoi>, <https://www.chezmoi.io/>
- **注意事項**: MITライセンス（Copyright 2018 Tom Payne）
- **記事での表現**: 「chezmoi（Tom Payne, 2018年）はGo製のdotfiles管理ツールで、テンプレート機能による複数マシン対応が特徴だ」

## 10. yadm

- **結論**: yadm（Yet Another Dotfiles Manager）はTim Byrneが開発。ホームディレクトリを直接Gitリポジトリとして管理するアプローチ。GNU GPLv3ライセンス。OS・ホスト名に基づく代替ファイル（alternate files）機能と、機密ファイルの暗号化機能を持つ
- **一次ソース**: yadm.io; GitHub "yadm-dev/yadm"
- **URL**: <https://yadm.io/>, <https://github.com/yadm-dev/yadm>
- **注意事項**: 「Gitの使い方を知っていれば、yadmの使い方も知っている」がコンセプト
- **記事での表現**: 「yadm（Tim Byrne）は、ホームディレクトリを直接Gitリポジトリとして扱うアプローチだ」

## 11. Starship

- **結論**: Starshipは2019年にMatan Kushnerらが開発を開始した、Rust製のクロスシェルプロンプト。bash、fish、zsh、PowerShell、Elvish、Nushell等の多数のシェルに対応。TOML設定ファイル（`~/.config/starship.toml`）で設定する。高速で、Git情報やプログラミング言語バージョン等をプロンプトに表示する
- **一次ソース**: starship.rs; GitHub "starship/starship"
- **URL**: <https://starship.rs/>, <https://github.com/starship/starship>
- **注意事項**: XDG Base Directoryに準拠した設定ファイル配置
- **記事での表現**: 「Starship（2019年、Matan Kushner他、Rust製）は、クロスシェルプロンプトの統一という新しい発想を実現した」

## 12. Powerlevel10k

- **結論**: Powerlevel10kはRoman Perepelitsaが開発したzshテーマ。Powerlevel9kの後継で、非同期レンダリングとインスタントプロンプト機能により高速動作する。`p10k configure`コマンドで対話的に設定可能。GitHub上で37,000以上のスター
- **一次ソース**: GitHub "romkatv/powerlevel10k"
- **URL**: <https://github.com/romkatv/powerlevel10k>
- **注意事項**: zsh専用のテーマであり、クロスシェル対応ではない
- **記事での表現**: 「Powerlevel10k（Roman Perepelitsa）は非同期レンダリングにより、zshプロンプトの速度問題を解消した」
