# 第19回：シェル設定文化論――dotfiles、プロンプト、そしてアイデンティティ

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- ドットファイルの起源――Rob Pikeが「バグ」と呼んだUnix V2のlsコマンドのショートカット
- rc命名規約のルーツ――MITのCTSS RUNCOM（1963年頃、Louis Pouzin）から現代の.bashrcまで
- Bourne shellの`.profile`（1979年）からbashの`.bash_profile`/`.bashrc`、zshの5段階初期化に至るシェル設定ファイルの進化
- login shell / non-login shell / interactive / non-interactiveの4象限と、初期化ファイルの読み込み順序の全容
- XDG Base Directory Specification（2003年）がホームディレクトリの秩序に果たした役割
- GitHub上のdotfiles文化（Zach Holman, 2010年頃）とdotfiles管理ツールの系譜（GNU Stow → yadm → chezmoi）
- Starship（2019年、Rust製）によるクロスシェルプロンプトの統一という新しい発想
- dotfilesが映し出す「エンジニアのアイデンティティ」の意味

---

## 1. 導入――設定ファイルを持ち運ぶ人々

私の`.zshrc`は、17年分の堆積物だ。

正確に言えば、現在の`.zshrc`の直接の祖先は2009年頃にzshへ移行したときに書き始めたものだが、その中にはbash時代の`.bashrc`から移植したエイリアスや関数が含まれている。さらにその一部は、2000年代前半にサーバ管理の現場で書いた`.profile`の断片にまで遡る。一つひとつのエイリアス、一つひとつの環境変数設定に、当時の現場の記憶が染みついている。

転職のたびに、新しいマシンが届くたびに、私が最初にやることは決まっていた。dotfilesを持ち込むことだ。GitHubのプライベートリポジトリからcloneし、シンボリックリンクを張る。ターミナルを開いた瞬間に「自分の環境」が立ち上がる。プロンプトの色、エイリアスの手触り、パス設定の順序。これがないと、借り物の机で仕事をしているような落ち着かなさがある。

あなたにも、同じ感覚はないだろうか。

ある日、若手のエンジニアに聞かれた。「dotfilesって何ですか」と。彼はmacOSでzshを使っている。Oh My Zshを入れ、テーマを設定し、いくつかのプラグインを有効にしている。だが、自分の`.zshrc`が何をしているのか、なぜそのファイル名なのか、ログインシェルと非ログインシェルで読み込まれるファイルが違うことを知らなかった。

これは彼の責任ではない。シェルの設定ファイルの仕組みは、知らなくても日常の開発は回る。だが、「なぜ`.bashrc`という名前なのか」「なぜドットで始まるファイルは隠されるのか」「なぜログインシェルと非ログインシェルで読み込みファイルが異なるのか」――これらの問いの答えを知ることは、シェルという道具の設計思想を理解することに直結する。

そして、dotfilesをGitHubに公開し、管理ツールで整理し、転職のたびに持ち運ぶ文化。この文化は、2010年代に急速に広まった。エンジニアにとってdotfilesとは何なのか。単なる設定ファイルの集合なのか、それとも技術的なアイデンティティの表現なのか。

この回では、ドットファイルの起源から現代のdotfiles文化まで、シェル設定の60年の歴史を辿る。

---

## 2. 歴史的背景――ドットファイルはどこから来たのか

### RUNCOMとrc命名規約（1963年）

シェルの設定ファイルに付く「rc」という接尾辞。`.bashrc`、`.zshrc`、`.vimrc`。この二文字の起源を知るエンジニアは多くない。

rcは「run commands」の略であり、そのルーツは1963年頃にLouis PouzinがMITのCTSS（Compatible Time-Sharing System）上で開発したRUNCOMに遡る。CTSSは第2回で見た、タイムシェアリングの先駆的システムだ。RUNCOMは、ファイルに格納されたコマンド群を一括実行する仕組みだった。バッチ処理的なコマンドの束を定義し、それを「実行する（run）」ためのものだ。

Pouzinは1965年にMulticsのシェル設計に関する論文を発表し、その中でRUNCOMについて記述している。Multicsから直接的に影響を受けたUnixは、この命名規約を受け継いだ。Bourne shellの設定ファイルは`.profile`だったが、cshが`.cshrc`という名前を採用したことで、「rc」がシェル設定ファイルの慣用的な接尾辞として定着した。以後、`.bashrc`、`.zshrc`、`.vimrc`、`.screenrc`と、Unixの設定ファイル全般に「rc」が広がっていった。

60年以上前のMITの実験的システムの命名規約が、2026年の今も毎日触る設定ファイルの名前に生き続けている。この事実は、コンピュータの歴史における命名の慣性力を物語る。

### ドットファイルの誕生――「バグ」としての隠しファイル

ドットファイルがなぜ「隠し」ファイルなのか。この問いに対する答えは、意外なものだ。

2012年、Rob Pikeが"A lesson in shortcuts"と題してこう書いた。Unix V2でファイルシステムが階層構造に書き換えられたとき、`.`（カレントディレクトリ）と`..`（親ディレクトリ）というエントリが導入された。`ls`コマンドの出力からこの二つを除外するために、Ken ThompsonまたはDennis Ritchieが以下のようなコードを書いた。

```c
/* 実際に書かれたもの（アセンブラだが、C相当） */
if (name[0] == '.') continue;

/* 本来書くべきだったもの */
if (strcmp(name, ".") == 0 || strcmp(name, "..") == 0) continue;
```

ドットで始まるすべてのファイルを非表示にするのではなく、`.`と`..`だけを除外するのが正しい実装だった。だが、ショートカットとして最初の一文字だけをチェックした。この実装上の手抜きが、「ドットで始まるファイルは隠される」という慣習を生んだ。

Pikeはこれを「悪い先例が生まれた」と評した。この簡略化に倣った他のプログラマたちが同じ省略を行い、ドットファイルが「隠しファイル」として機能する世界が定着した。やがて、プログラマたちはホームディレクトリに設定ファイルを置く際、意図的にドットを先頭に付けるようになった。「見えなくていい」ファイルはドットで始める。これが慣習として固まった。

Plan 9（PikeとThompsonらが開発したUnixの後継OS）には、ドットファイルの仕組みが存在しない。設定ファイルは`$HOME/lib`のような明示的なディレクトリに置かれる。Pikeの視点からすれば、ドットファイルはUnixの設計判断ではなく、`ls`コマンドの実装バグから生まれた副産物だった。

しかし、副産物は文化になった。`.profile`、`.cshrc`、`.bashrc`、`.zshrc`、`.vimrc`、`.gitconfig`、`.ssh/`――現代のエンジニアのホームディレクトリは、ドットファイルで溢れている。

### `.profile`からの系譜――Bourne shell（1979年）

ドットファイルの中で、シェルの設定ファイルは特別な位置を占める。その原点は、1979年にUNIX V7と共にリリースされたBourne shellの`~/.profile`だ。

Bourne shellの初期化は単純だった。ログイン時に、まず`/etc/profile`（システム全体の設定）が読み込まれ、次にユーザーの`~/.profile`が読み込まれる。これだけだ。ファイルは一つ。読み込みの条件分岐はない。ログインすれば読まれる。

この単純さは、1979年の使用パターンを反映している。当時のUnixユーザーは、端末からログインし、シェルを使い、ログアウトする。シェルの起動は常に「ログイン」だった。ターミナルエミュレータの中で新しいシェルを起動する、tmuxのペインでシェルを開く、スクリプトの中でサブシェルを起動する――こうした「ログイン以外のシェル起動」が日常化するのは、もう少し先の話だ。

### cshの`.cshrc`と`.login`（1978年）

Bill Joyのcsh（第7回参照）は、設定ファイルを二つに分けた。`.cshrc`（すべてのcsh起動時に読み込み）と`.login`（ログイン時のみ読み込み）だ。

この分離は重要な概念の導入だった。「すべてのシェル起動時に必要な設定」と「ログイン時にのみ必要な設定」は異なるという認識だ。エイリアスやプロンプト設定はすべてのシェルで必要だが、環境変数の設定や`stty`の実行はログイン時に一度だけ行えばよい。

cshのこの設計判断が、後のbashとzshの初期化ファイル構造に直接影響を与えている。

### bashの三すくみ――`.bash_profile` vs `.bashrc` vs `.profile`

bashの初期化ファイルの読み込み順序は、多くのエンジニアにとって混乱の種だ。公式のBash Reference Manualから、正確な仕様を整理する。

**対話的ログインシェル**（`bash --login`、またはターミナルからのログイン時）:

1. `/etc/profile`を読み込む（存在する場合）
2. 次に、以下の順序で最初に見つかったファイルを一つだけ読み込む:
   - `~/.bash_profile`
   - `~/.bash_login`
   - `~/.profile`

**対話的非ログインシェル**（ターミナルエミュレータからの起動など）:

1. `~/.bashrc`を読み込む

**非対話的シェル**（スクリプト実行時）:

1. `BASH_ENV`環境変数が設定されていれば、その値が指すファイルを読み込む

```
bashの初期化ファイル読み込みフロー:

               bash起動
                  |
          ログインシェルか？
           /              \
         yes               no
          |                 |
    /etc/profile      対話的か？
          |            /       \
  ~/.bash_profile    yes       no
  （なければ）        |         |
  ~/.bash_login    ~/.bashrc  $BASH_ENV
  （なければ）
  ~/.profile
```

この構造が混乱を招く理由は明確だ。ターミナルエミュレータ（iTerm2、GNOME Terminal、Windows Terminal等）からシェルを起動するとき、そのシェルが「ログインシェル」か「非ログインシェル」かは、ターミナルエミュレータの設定に依存する。macOSのTerminal.appはデフォルトでログインシェルとしてbashを起動するが、多くのLinuxターミナルエミュレータは非ログインシェルとして起動する。

結果、`.bash_profile`に書いた設定がLinuxのターミナルでは反映されない、`.bashrc`に書いた設定がmacOSのTerminal.appでは反映されない、という事態が起きる。

この問題の実務的な解決策として、多くのユーザーが`.bash_profile`の中で`.bashrc`をsourceする慣習が定着した。

```bash
# ~/.bash_profile
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
```

このワークアラウンドは、ログインシェルでも非ログインシェルでも`.bashrc`が読み込まれることを保証する。設計としては美しくないが、実用的な解だ。そして、この「美しくないが動く」解が広まっている事実こそが、bashの初期化ファイル設計が現代の使用パターンに適合していないことを示している。

### zshの5段階――全方位への対応

zshの初期化ファイルはさらに複雑だ。5段階のファイルが、特定の条件下で順番に読み込まれる。

```
zshの初期化ファイル（読み込み順序）:

ファイル名        すべて  ログイン  対話的  読み込み順
─────────────────────────────────────────────────────
.zshenv            ○        -        -      1番目
.zprofile          -        ○        -      2番目
.zshrc             -        -        ○      3番目
.zlogin            -        ○        -      4番目
.zlogout           -        ○        -      終了時

○ = 読み込み条件
各ファイルに /etc/ 版（グローバル）と $ZDOTDIR/ 版（ユーザー）がある
```

**`.zshenv`** は、すべてのzsh呼び出しで読み込まれる。対話的シェルでもスクリプト実行でも、ログインシェルでも非ログインシェルでも。ここには、あらゆる状況で必要な環境変数（`PATH`等）を設定する。

**`.zprofile`** は、ログインシェルでのみ読み込まれる。`.zshrc`の前に実行される。Bourne shellの`.profile`に相当する。

**`.zshrc`** は、対話的シェルでのみ読み込まれる。エイリアス、プロンプト設定、補完設定、キーバインド等をここに書く。

**`.zlogin`** は、ログインシェルでのみ、`.zshrc`の後に読み込まれる。cshの`.login`に相当する。`.zprofile`との違いは読み込み順序だけだ。`.zprofile`は`.zshrc`の前、`.zlogin`は`.zshrc`の後に読み込まれる。

**`.zlogout`** は、ログインシェルの終了時に読み込まれる。一時ファイルの削除等に使う。

zshがここまで複雑な初期化ファイル構造を持つ理由は、第17回で見たzshの「最大主義」の設計思想と一致する。Bourne shell互換（`.profile`相当の`.zprofile`）、csh互換（`.login`相当の`.zlogin`）、そして独自の要件（`.zshenv`、`.zshrc`）を全方位的にカバーしようとした結果だ。

### fishの割り切り――XDG準拠と単一ファイル

前回見たfishは、この問題に対して根本的に異なるアプローチを取った。

fishの設定ファイルは`~/.config/fish/config.fish`の一つだ。このファイルは、対話的シェルでも非対話的シェルでも読み込まれる。ログインシェルと非ログインシェルの区別はない。対話的シェルでのみ実行したいコードは、`status is-interactive`で条件分岐する。

```fish
# ~/.config/fish/config.fish
set -gx EDITOR vim

if status is-interactive
    # 対話的シェルでのみ実行
    alias ll "ls -la"
end
```

注目すべきは、fishが最初からXDG Base Directory Specificationに準拠している点だ。設定ファイルは`~/.config/fish/`に置かれ、`~/.fishrc`のようなホームディレクトリ直下のドットファイルは使わない。

XDG Base Directory Specificationは、2003年にfreedesktop.orgが策定した仕様だ。ホームディレクトリがドットファイルで溢れる問題に対して、設定ファイルは`$XDG_CONFIG_HOME`（デフォルト`~/.config`）、データファイルは`$XDG_DATA_HOME`（デフォルト`~/.local/share`）、キャッシュは`$XDG_CACHE_HOME`（デフォルト`~/.cache`）に配置するという標準を定めた。

bashとzshは、2026年現在もXDG Base Directoryに準拠していない。`.bashrc`と`.zshrc`はホームディレクトリ直下に置かれる。zshは`$ZDOTDIR`変数で設定ファイルのディレクトリを変更できるが、デフォルトは`$HOME`だ。これはBourne shell以来の慣習との後方互換性のためだ。fishは後方互換性の制約がなかったからこそ、XDGに準拠できた。

---

## 3. 技術論――dotfiles管理ツールの系譜とプロンプト文化

### dotfilesの課題と管理ツールの進化

シェルの設定ファイルが増え、複数のマシンで同じ環境を再現したいという要求が生まれると、dotfiles管理は技術的な課題になった。

最も素朴な方法は、設定ファイルをGitリポジトリに入れ、手動でシンボリックリンクを張ることだ。

```bash
# 素朴な方法
cd ~
git clone git@github.com:username/dotfiles.git
ln -s ~/dotfiles/.bashrc ~/.bashrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
# ... 以下、ファイルの数だけ繰り返し
```

この方法には問題がある。リンクの管理が手動であること、マシンごとに異なる設定が必要な場合に対応できないこと、機密情報（APIキー、SSHの設定等）の扱いが難しいことだ。

この問題に対して、複数のツールが異なるアプローチで解を提示してきた。

#### GNU Stow（1993年、Bob Glickstein）

GNU Stowは、元々ソフトウェアパッケージの管理用に開発されたシンボリックリンクファームマネージャだ。`/usr/local/stow/`配下にパッケージごとのディレクトリを作り、そこから`/usr/local/`へシンボリックリンクを張る――これが本来の用途だった。

2012年頃、Brandon Invergoがブログ記事でGNU Stowをdotfiles管理に転用する方法を紹介し、この手法が広まった。

```
GNU Stowによるdotfiles管理の構造:

~/dotfiles/
├── bash/
│   └── .bashrc          → ~/.bashrc にリンク
├── git/
│   └── .gitconfig       → ~/.gitconfig にリンク
├── vim/
│   └── .vimrc           → ~/.vimrc にリンク
└── zsh/
    └── .zshrc           → ~/.zshrc にリンク

コマンド: cd ~/dotfiles && stow bash git vim zsh
→ 各パッケージのファイルが ~ にシンボリックリンクされる
```

GNU Stowの利点は、ツール自体がシンプルで、dotfilesの物理的な配置がディレクトリ構造として可視化される点だ。だが、マシンごとの設定の出し分けや、機密情報の暗号化には対応していない。

#### yadm（Tim Byrne）

yadmはホームディレクトリ自体をGitリポジトリとして扱う。シンボリックリンクを使わない。`~/.bashrc`はそのまま`~/.bashrc`として存在し、Gitで追跡される。

```bash
# yadmの使い方
yadm init
yadm add ~/.bashrc ~/.zshrc ~/.vimrc
yadm commit -m "Initial dotfiles"
yadm remote add origin git@github.com:username/dotfiles.git
yadm push
```

「Gitの使い方を知っていれば、yadmの使い方も知っている」がyadmのコンセプトだ。`yadm`コマンドは内部的に`git`コマンドを呼び出しているに過ぎない。

yadmの特徴的な機能は、OSやホスト名に基づく代替ファイル（alternate files）だ。`~/.bashrc##os.Darwin`と`~/.bashrc##os.Linux`のように、条件付きのファイルを用意できる。

#### chezmoi（Tom Payne, 2018年）

chezmoiはGo言語で書かれたdotfiles管理ツールだ。名前はフランス語の「chez moi」（私の家）に由来する。

chezmoiがGNU Stowやyadmと根本的に異なるのは、テンプレート機能を持つ点だ。GoのテンプレートエンジンにアクセスでA、設定ファイルの中にマシン固有の値を埋め込める。

```
chezmoiのアーキテクチャ:

ソースディレクトリ                    ターゲット（$HOME）
~/.local/share/chezmoi/               ~/
├── dot_bashrc.tmpl          →        .bashrc（テンプレート展開済み）
├── dot_gitconfig             →        .gitconfig（コピー）
└── private_dot_ssh/          →        .ssh/（パーミッション保持）
    └── config                →        .ssh/config

テンプレート例（dot_bashrc.tmpl）:
  export GOPATH="{{ .chezmoi.homeDir }}/go"
  {{ if eq .chezmoi.os "darwin" }}
  export BROWSER="open"
  {{ else }}
  export BROWSER="xdg-open"
  {{ end }}
```

chezmoiはシンボリックリンクではなくファイルコピー方式を採用する。ソースディレクトリの内容をテンプレート処理し、結果をホームディレクトリにコピーする。これにより、ターゲットのファイルは通常のファイルであり、どのツールからも読み書きできる。

さらに、chezmoiは1Password、Bitwarden、pass等のパスワードマネージャとの統合を持ち、機密情報をテンプレート内で安全に扱える。

```
dotfiles管理ツールの比較:

                GNU Stow    yadm       chezmoi
──────────────────────────────────────────────────
方式            symlink     git直接    コピー+テンプレート
マシン別設定    不可        代替ファイル  テンプレート
機密情報管理    不可        暗号化     パスワードマネージャ連携
学習コスト      低          低         中
依存            Perl        Git+bash   Go（単一バイナリ）
設計思想        UNIX的      Git的      宣言的
```

### GitHub dotfiles文化の形成

dotfiles管理ツールの発展と並行して、2010年代にはGitHub上でdotfilesを公開する文化が急速に広まった。

その先駆者の一人が、GitHub社員のZach Holmanだ。2010年頃、Holmanは自身のdotfilesリポジトリを公開した。Holmanのアプローチは「トピック指向」だった。Ruby、Git、システムライブラリ等のトピックごとにディレクトリを分け、`.zsh`拡張子のファイルは自動的にシェルに読み込まれ、`.symlink`拡張子のファイルは`$HOME`にシンボリックリンクされる。この構造は、多くの後続のdotfilesリポジトリに影響を与えた。

2013年頃には、GitHubが公式にdotfiles.github.ioというサイトを開設し、dotfilesの管理手法やツールを紹介した。他者のdotfilesを覗き、自分の設定を改善する。新しいツールやテクニックを発見する。自分の環境を公開し、フィードバックを得る。dotfilesリポジトリは、エンジニアの技術的嗜好を外部に表現する場になった。

この文化には功罪がある。

功の面は、知識の共有だ。bashのベストプラクティス、zshの便利なプラグイン、Gitの効率的な設定。dotfilesリポジトリを通じて、他のエンジニアの知恵に触れることができる。

罪の面は、コピペ文化との紙一重の関係だ。他人のdotfilesをそのまま持ってきて、何が設定されているのかを理解せずに使う。Oh My Zshのテーマとプラグインを大量に有効にし、起動が遅くなる。前回のfishの話題で触れた「設定可能性は諸悪の根源」というfishの哲学は、この問題を鋭く突いている。

### プロンプト――シェルの顔

dotfiles文化において、最も視覚的な要素がプロンプトだ。

シェルのプロンプトは、Bourne shellの時代から存在する。`PS1`環境変数で設定し、ユーザー名、ホスト名、カレントディレクトリ等を表示する。

```bash
# 最もシンプルなプロンプト
PS1='$ '

# Bourne shell伝統的なプロンプト
PS1='\u@\h:\w\$ '
# => yusuke@hostname:/home/yusuke$
```

bashの`PS1`はエスケープシーケンスを使って情報を埋め込む。`\u`がユーザー名、`\h`がホスト名、`\w`がカレントディレクトリ。これはBourne shellの`$PS1`を拡張したものだ。

zshでは`PROMPT`変数（`PS1`のエイリアス）でプロンプトを設定する。zshのプロンプトエスケープは`%n`（ユーザー名）、`%m`（ホスト名）、`%~`（カレントディレクトリ）とbashとは異なる。さらにzshは右プロンプト`RPROMPT`をサポートする。

```zsh
# zshのプロンプト
PROMPT='%n@%m:%~%# '
RPROMPT='%D{%H:%M}'  # 右側に時刻を表示
```

2000年代後半からOh My Zshの普及に伴い、プロンプトのカスタマイズは一大ジャンルになった。Gitブランチの表示、言語バージョンの表示、前回コマンドの実行時間、エラーステータスの色分け。情報密度の高いプロンプトが流行した。

この流れの中で登場したのが、Powerlevel10k（Roman Perepelitsa）だ。zsh専用のテーマで、非同期レンダリングとインスタントプロンプト機能により、情報量の多いプロンプトでも遅延なく表示する。`p10k configure`コマンドによる対話的な設定ウィザードが、導入の敷居を下げた。

### Starship――クロスシェルプロンプトの統一

2019年、Matan Kushnerらが開発を開始したStarshipは、プロンプトの世界に新しい発想を持ち込んだ。クロスシェル対応だ。

従来、プロンプトの設定はシェルごとに異なっていた。bashの`PS1`とzshの`PROMPT`は構文が異なり、fishのプロンプトは`fish_prompt`関数で定義する。シェルを変えれば、プロンプトの設定も書き直す必要があった。

Starshipはこの問題を解決する。Rust製の単一バイナリとして動作し、bash、zsh、fish、PowerShell、Elvish、Nushell、Ion、Tcsh、Xonsh等の多数のシェルに対応する。設定は`~/.config/starship.toml`（TOML形式）の一つのファイルで行う。

```toml
# ~/.config/starship.toml
[character]
success_symbol = "[>](bold green)"
error_symbol = "[>](bold red)"

[directory]
truncation_length = 3

[git_branch]
symbol = " "

[nodejs]
format = "via [Node $version](bold green) "
```

Starshipの設計には、いくつかの注目すべき判断がある。

第一に、Rust製であること。プロンプトはコマンドの実行前に毎回評価される。遅いプロンプトは、ターミナルの操作感を直接的に悪化させる。RustはGoやPythonよりも起動速度で優位に立ち、シェルスクリプトで書かれたプロンプトとは比較にならない速度を実現する。

第二に、XDG Base Directoryに準拠した設定ファイルの配置。`~/.config/starship.toml`はfishと同じ思想だ。

第三に、「シェルに依存しないプロンプト」という概念の実現。シェルの乗り換え時に、プロンプトの設定を書き直す必要がない。bashからzshに移行しても、zshからfishに移行しても、プロンプトは変わらない。

これは、シェルの「対話的機能」の一部がシェルの外に分離される動きの一例だ。プロンプトという、シェルの最も目に見える要素が、シェルとは独立したツールとして切り出される。この分離は、第9回で論じた「対話とスクリプティングの乖離」の延長線上にある。

---

## 4. ハンズオン――シェル初期化ファイルを実験で確認する

ここからは、シェルの初期化ファイルの読み込み順序を実験で確認し、dotfiles管理ツールとStarshipを実際に体験する。

### 環境構築

Docker環境を前提とする。

```bash
docker run -it ubuntu:24.04 /bin/bash
```

あるいは、本記事に付属する`setup.sh`スクリプトで一括構築できる。

```bash
bash setup.sh
```

### 演習1: bashの初期化ファイル読み込み順序を実験する

```bash
echo "=== 演習1: bash初期化ファイルの読み込み順序 ==="

# テスト用の初期化ファイルを作成
mkdir -p /tmp/bash-init-test
export HOME=/tmp/bash-init-test

cat > /tmp/bash-init-test/.bash_profile << 'EOF'
echo "[LOADED] .bash_profile"
EOF

cat > /tmp/bash-init-test/.bashrc << 'EOF'
echo "[LOADED] .bashrc"
EOF

cat > /tmp/bash-init-test/.profile << 'EOF'
echo "[LOADED] .profile"
EOF

echo "--- ケース1: 対話的ログインシェル ---"
echo "(bash --login を実行)"
bash --login -c "echo 'done'"
echo ""

echo "--- ケース2: 対話的非ログインシェル ---"
echo "(bash を実行)"
bash -c "echo 'done'"
echo ""

echo "--- ケース3: .bash_profileがない場合 ---"
rm /tmp/bash-init-test/.bash_profile
bash --login -c "echo 'done'"
echo ""
echo "=> .bash_profileがなければ.profileにフォールバック"

echo ""
echo "--- ケース4: .bash_profileから.bashrcをsource ---"
cat > /tmp/bash-init-test/.bash_profile << 'EOF'
echo "[LOADED] .bash_profile"
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
EOF
echo "(.bash_profileに.bashrcのsourceを追加)"
bash --login -c "echo 'done'"
echo ""
echo "=> これがbashの初期化ファイルの定番パターン"

rm -rf /tmp/bash-init-test
```

### 演習2: zshの5段階初期化ファイルを実験する

```bash
echo "=== 演習2: zshの5段階初期化 ==="

apt-get update -qq && apt-get install -y -qq zsh >/dev/null 2>&1

mkdir -p /tmp/zsh-init-test
export ZDOTDIR=/tmp/zsh-init-test

cat > /tmp/zsh-init-test/.zshenv << 'EOF'
echo "[1] .zshenv (すべてのzshで読み込み)"
EOF

cat > /tmp/zsh-init-test/.zprofile << 'EOF'
echo "[2] .zprofile (ログインシェルで読み込み)"
EOF

cat > /tmp/zsh-init-test/.zshrc << 'EOF'
echo "[3] .zshrc (対話的シェルで読み込み)"
EOF

cat > /tmp/zsh-init-test/.zlogin << 'EOF'
echo "[4] .zlogin (ログインシェルで、.zshrcの後に読み込み)"
EOF

echo "--- ケース1: 対話的ログインシェル ---"
zsh --login -c "echo '---'"
echo ""

echo "--- ケース2: 対話的非ログインシェル ---"
zsh -c "echo '---'"
echo ""

echo "--- ケース3: 非対話的（スクリプト実行）---"
echo 'echo "script running"' > /tmp/zsh-test-script.zsh
zsh /tmp/zsh-test-script.zsh
echo ""
echo "=> .zshenvはスクリプト実行でも読み込まれる（注意）"

rm -rf /tmp/zsh-init-test /tmp/zsh-test-script.zsh
unset ZDOTDIR
```

### 演習3: login shellとnon-login shellの違い

```bash
echo "=== 演習3: login shell判定の確認 ==="
echo ""

echo "--- bashでの確認方法 ---"
echo "ログインシェルの場合:"
bash --login -c 'shopt -q login_shell && echo "  login shell: yes" || echo "  login shell: no"'
echo ""
echo "非ログインシェルの場合:"
bash -c 'shopt -q login_shell && echo "  login shell: yes" || echo "  login shell: no"'
echo ""

echo "--- zshでの確認方法 ---"
echo "ログインシェルの場合:"
zsh --login -c '[[ -o login ]] && echo "  login shell: yes" || echo "  login shell: no"'
echo ""
echo "非ログインシェルの場合:"
zsh -c '[[ -o login ]] && echo "  login shell: yes" || echo "  login shell: no"'
echo ""

echo "=> ターミナルエミュレータによってデフォルトが異なる"
echo "   macOS Terminal.app → ログインシェル"
echo "   多くのLinuxターミナル → 非ログインシェル"
echo "   tmux/screen → 非ログインシェル（設定次第）"
```

### 演習4: GNU Stowでdotfiles管理を体験する

```bash
echo "=== 演習4: GNU Stowによるdotfiles管理 ==="

apt-get install -y -qq stow >/dev/null 2>&1

# テスト用のホームディレクトリとdotfilesリポジトリ
TEST_HOME=/tmp/stow-test-home
DOTFILES=$TEST_HOME/dotfiles

mkdir -p "$TEST_HOME"
mkdir -p "$DOTFILES/bash"
mkdir -p "$DOTFILES/git"
mkdir -p "$DOTFILES/vim"

# dotfilesの作成
cat > "$DOTFILES/bash/.bashrc" << 'EOF'
# My .bashrc managed by GNU Stow
alias ll='ls -la'
alias gs='git status'
export EDITOR=vim
EOF

cat > "$DOTFILES/git/.gitconfig" << 'EOF'
[user]
    name = Test User
    email = test@example.com
[core]
    editor = vim
EOF

cat > "$DOTFILES/vim/.vimrc" << 'EOF'
set number
set expandtab
set shiftwidth=4
EOF

echo "--- dotfilesリポジトリの構造 ---"
find "$DOTFILES" -type f | sort | sed "s|$TEST_HOME/||"
echo ""

echo "--- stowでシンボリックリンクを作成 ---"
cd "$DOTFILES"
HOME="$TEST_HOME" stow -t "$TEST_HOME" bash git vim
echo ""

echo "--- リンクの確認 ---"
ls -la "$TEST_HOME/.bashrc" "$TEST_HOME/.gitconfig" "$TEST_HOME/.vimrc" 2>/dev/null | \
    awk '{print $NF, $((NF-1)), $(NF-2)}' | column -t
echo ""

echo "--- unstow（リンク解除）---"
HOME="$TEST_HOME" stow -t "$TEST_HOME" -D bash
ls -la "$TEST_HOME/.bashrc" 2>/dev/null || echo "  .bashrc のリンクが解除された"
echo ""

echo "=> GNU Stowはシンボリックリンクの作成/解除を自動化する"
echo "   ディレクトリ構造 = リンク先の構造"

rm -rf "$TEST_HOME"
```

### 演習5: Starshipプロンプトの体験

```bash
echo "=== 演習5: Starshipプロンプトの体験 ==="

# Starshipのインストール
if ! command -v starship > /dev/null 2>&1; then
    echo "[準備] Starshipをインストール中..."
    apt-get install -y -qq curl >/dev/null 2>&1
    curl -sS https://starship.rs/install.sh | sh -s -- --yes 2>/dev/null
fi

echo ""
echo "--- Starshipのバージョン ---"
starship --version
echo ""

# 設定ファイルの作成
mkdir -p /tmp/starship-test
export STARSHIP_CONFIG=/tmp/starship-test/starship.toml

echo "--- 設定1: ミニマル ---"
cat > "$STARSHIP_CONFIG" << 'TOML'
format = "$directory$character"

[character]
success_symbol = "[>](bold green)"
error_symbol = "[>](bold red)"

[directory]
style = "bold cyan"
truncation_length = 2
TOML

echo "設定内容:"
cat "$STARSHIP_CONFIG"
echo ""
echo "プロンプト表示:"
starship prompt 2>/dev/null || echo "(starship promptコマンドで確認)"
echo ""

echo "--- 設定2: 情報量多め ---"
cat > "$STARSHIP_CONFIG" << 'TOML'
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$nodejs\
$python\
$rust\
$line_break\
$character"""

[character]
success_symbol = "[->](bold green)"
error_symbol = "[->](bold red)"

[directory]
style = "bold cyan"

[git_branch]
symbol = "git:"
TOML

echo "設定内容:"
cat "$STARSHIP_CONFIG"
echo ""
echo "プロンプト表示:"
starship prompt 2>/dev/null || echo "(starship promptコマンドで確認)"
echo ""

echo "=> Starshipの特徴:"
echo "   1. クロスシェル: bash/zsh/fish/PowerShell等に対応"
echo "   2. Rust製: 高速な起動"
echo "   3. TOML設定: シェルに依存しない統一的な設定"
echo "   4. XDG準拠: ~/.config/starship.toml"

rm -rf /tmp/starship-test
unset STARSHIP_CONFIG
```

---

## 5. まとめと次回予告

### この回の要点

第一に、ドットファイルの起源は意図的な設計ではなく、Unix V2の`ls`コマンド実装におけるショートカットの副産物だった。Rob Pikeが2012年に指摘したように、`.`と`..`を除外するための簡略化されたチェック`if (name[0] == '.') continue;`が、「ドットで始まるファイルは隠される」という慣習を生んだ。Plan 9にはこの仕組みが存在しない。

第二に、「rc」命名規約のルーツは、1963年頃にLouis PouzinがMITのCTSS上で開発したRUNCOM（run commands）にある。60年以上前の命名規約が、`.bashrc`、`.zshrc`、`.vimrc`として今なお生き続けている。

第三に、シェルの初期化ファイルは時代とともに複雑化した。Bourne shellの`.profile`一つから、bashの`.bash_profile`/`.bashrc`/`.profile`の三すくみ、zshの5段階初期化へ。この複雑さは、「ログインシェル/非ログインシェル」「対話的/非対話的」の組み合わせと、過去のシェルとの後方互換性の維持が原因だ。fishは後方互換性を切り捨てることで、設定ファイルを一つ（`~/.config/fish/config.fish`）に統一した。

第四に、2010年代にGitHub上でdotfilesを公開する文化が広まった。dotfiles管理ツールはGNU Stow（1993年、シンボリックリンク方式）→yadm（Git直接管理）→chezmoi（2018年、テンプレート+コピー方式）と進化し、マシン間の差異への対応と機密情報管理の機能が充実してきた。

第五に、Starship（2019年、Matan Kushner他、Rust製）は、クロスシェルプロンプトという発想を実現した。プロンプトの設定をシェルの外に分離し、bash/zsh/fish等のどのシェルでも同じプロンプトを使えるようにした。これはシェルの「対話的機能」の一部がシェルから独立する動きの一例だ。

### 冒頭の問いへの暫定回答

「なぜエンジニアは自分のシェル設定にこだわるのか」――この問いに対する暫定的な答えはこうだ。

dotfilesは、エンジニアの技術的判断の蓄積だ。どのエイリアスを設定するか、どのパスを通すか、どのプロンプト情報を表示するか。これらの一つひとつが、そのエンジニアの仕事のやり方を反映している。17年かけて堆積した`.zshrc`の中には、過去の現場で直面した問題と、その解決策が凝縮されている。

だが、dotfilesの意味を理解しているかどうかが、「道具を使いこなす者」と「道具に使われる者」を分ける。他人のdotfilesをコピーして「動くから良い」で終わらせるか、`.bashrc`という名前の由来、ログインシェルと非ログインシェルの違い、初期化ファイルの読み込み順序を理解した上で自分の設定を構築するか。

Rob Pikeが指摘したように、ドットファイルは「バグ」から生まれた。RUNCOM由来のrc命名規約は60年前の化石だ。bashの初期化ファイルの三すくみは現代の使用パターンに適合していない。zshの5段階初期化は必要以上に複雑だ。

しかし、これらの歴史的経緯を知ることは、シェルの設計思想を理解することそのものだ。fishがなぜ設定ファイルを一つにできたのか。Starshipがなぜプロンプトをシェルから分離したのか。これらの「なぜ」は、歴史を知らなければ見えてこない。

dotfilesは「エンジニアの指紋」だと言う人がいる。だが私は、それ以上のものだと考える。dotfilesは「エンジニアの技術史」だ。設定ファイルの一行一行に、「なぜこの設定が必要になったのか」という物語がある。その物語を読み解き、自分の言葉で語れること。それが、道具を使いこなす者の条件だ。

### 次回予告

dotfilesはエンジニアのローカル環境を映し出す鏡だった。だが、現代のエンジニアリングでは、ローカル環境だけでは完結しない。

Docker、CI/CD、Kubernetes。コンテナ環境ではシェルの存在が当たり前ではない。Alpine Linuxの`/bin/sh`はashであり、bashではない。distrolessイメージにはシェルそのものが存在しない。Dockerfileの`RUN`命令がshell formとexec formで挙動が異なることを、あなたは知っているだろうか。

次回のテーマは「コンテナ時代のシェル――Docker, CI/CD, そして/bin/sh問題」だ。

コンテナが「シェルが当たり前に存在する」前提を崩したとき、シェルの設計思想はどう問い直されるのか。次回は、その問いに向き合う。

---

## 参考文献

- Rob Pike, "A lesson in shortcuts", 2012年 <https://glenda.0x46.net/articles/dotfiles/>
- Wikipedia, "RUNCOM" <https://en.wikipedia.org/wiki/RUNCOM>
- Louis Pouzin, "The Origin of the Shell", Multicians.org <https://www.multicians.org/shell.html>
- GNU Bash Reference Manual, "Bash Startup Files" <https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html>
- zsh.sourceforge.io, "An Introduction to the Z Shell - Startup Files" <https://zsh.sourceforge.io/Intro/intro_3.html>
- zsh.sourceforge.io, "What to put in your startup files" <https://zsh.sourceforge.io/Guide/zshguide02.html>
- freedesktop.org, "XDG Base Directory Specification" <https://specifications.freedesktop.org/basedir/latest/>
- GitHub, "holman/dotfiles" <https://github.com/holman/dotfiles>
- dotfiles.github.io <https://dotfiles.github.io/>
- GNU Project, "GNU Stow" <https://www.gnu.org/software/stow/>
- Brandon Invergo, "Using GNU Stow to manage your dotfiles", 2012年 <https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html>
- yadm.io, "Yet Another Dotfiles Manager" <https://yadm.io/>
- GitHub, "yadm-dev/yadm" <https://github.com/yadm-dev/yadm>
- chezmoi.io <https://www.chezmoi.io/>
- GitHub, "twpayne/chezmoi" <https://github.com/twpayne/chezmoi>
- Starship, "Cross-Shell Prompt" <https://starship.rs/>
- GitHub, "starship/starship" <https://github.com/starship/starship>
- GitHub, "romkatv/powerlevel10k" <https://github.com/romkatv/powerlevel10k>
- Wikipedia, "Hidden file and hidden directory" <https://en.wikipedia.org/wiki/Hidden_file_and_hidden_directory>
- Baeldung, "What Is rc and What Are rc Files?" <https://www.baeldung.com/linux/rc-files>
