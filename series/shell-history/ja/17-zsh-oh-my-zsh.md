# 第17回：zsh――最大主義のシェルとOh My Zsh文化

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- zshの誕生（Paul Falstad, Princeton大学, 1990年）と「すべてのシェルの最良の部分を統合する」という設計思想
- Peter Stephensonの30年にわたるメンテナンスと、zshの二段階の補完システム進化（compctl→compsys）
- zle（Zsh Line Editor）のウィジェット機構――コマンドライン編集をプログラマブルに再定義する設計
- zsh固有のグロビング機能――glob qualifiers（グロブ修飾子）がfindコマンドを不要にする世界
- Oh My Zsh（Robby Russell, 2009年）の功罪――zshを普及させたが、本質を覆い隠した
- プラグインマネージャの変遷――antigen、antibody、zinit、antidote、sheldonの系譜
- Oh My Zshなしでzshをセットアップする方法と、起動速度の劇的な差

---

## 1. 導入――「zsh使ってます」の内実

Oh My Zshを入れた日のことを覚えている。

2012年頃だったと思う。同僚のターミナルに表示されていたカラフルなプロンプトが気になった。「何を使っているのか」と聞くと、「Oh My Zshだよ、入れてみなよ」と返ってきた。curlで一行のインストールコマンドを実行すると、ターミナルの見た目が一変した。Gitブランチがプロンプトに表示され、テーマを変えればさらに華やかになる。「これがzshか」と思った。

だが、それは間違いだった。私が見ていたのはzshではなく、Oh My Zshだった。

テーマを選び、プラグインを追加し、プロンプトをカスタマイズする。その作業は楽しかった。だが、zsh自体が何をしているのか、bashと何が根本的に異なるのかを、私はまったく理解していなかった。`setopt`や`zstyle`というコマンドの存在すら知らなかった。Oh My Zshが生成する`.zshrc`の中身を読んだこともなかった。

数年後、ある若手エンジニアに「どのシェルを使っているか」と尋ねたことがある。「Oh My Zshを入れたのでzshです」という答えが返ってきた。その瞬間、既視感を覚えた。かつての私と同じだ。フレームワークを入れたことと、ツールを理解したことは、まったく別のことだ。

転機は、zshの起動が遅くなったときに訪れた。Oh My Zshにプラグインを20個以上積み、Powerlevel10kをテーマに設定していた私の`.zshrc`は、新しいターミナルウィンドウを開くたびに2秒以上かかるようになっていた。2秒。ターミナルを日に数十回開く人間にとって、2秒は許容できない待ち時間だ。

原因を調べるために、初めてzshの内部に踏み込んだ。`zmodload zsh/zprof`でプロファイリングし、何がボトルネックなのかを特定した。compinitの再実行、nvmの遅延読み込み、不要なプラグインの読み込み。一つずつ潰していく過程で、Oh My Zshの裏側でzshが何をしているのかが見え始めた。

そしてあるとき、実験的にOh My Zshを完全に外し、素のzshに自分で設定を書いてみた。`zstyle`で補完を設定し、`bindkey`でキーバインドを定義し、`zle -N`でカスタムウィジェットを作る。起動時間は200ミリ秒を切った。そして気づいた。zshは、Oh My Zshが見せていたものとはまったく異なる深さを持つシェルだった。

あなたはzshの何を知っているだろうか。Oh My Zshのテーマとプラグインの先に、何があるのかを見たことはあるだろうか。

---

## 2. 歴史的背景――zshはどこから来たのか

### Paul Falstadの野心（1990年）

1990年、Princeton大学の学生Paul Falstadは、一つのシェルを書き始めた。

当時のシェルの世界は、第9回で見たように「二つの文化」に分裂していた。Bourne系シェル（sh、ksh）はスクリプティングに優れていたが、対話的機能は貧弱だった。一方、C shell系（csh、tcsh）は対話的機能――ヒストリ、ジョブコントロール、コマンドライン編集――を充実させていたが、スクリプティング言語としては第7回で見た通り重大な欠陥を抱えていた。

Falstadの目標は明確だった。kshの強力なスクリプティング機能と、tcshの対話的快適さを、一つのシェルに統合すること。「すべてのシェルの最良の部分を取り込む」という、後に「最大主義（maximalist）」と呼ばれる設計思想の出発点がここにある。

名前の由来は、Princeton大学のティーチングアシスタントだったZhong Shaoのログイン名「zsh」だ。Falstadはそのログイン名がシェルの名前として響きがよいと感じた。Zhong Shaoは後にYale大学の教授となるが、zshの開発そのものには関わっていない。名前を借りただけだ。技術史において、こうした偶然の命名は珍しくない。

バージョン1.0のリリース時点で、zshはすでに野心的だった。ksh互換のスクリプティング機能に加え、tcsh由来のコマンドライン編集機能、そしてFalstad独自の拡張が盛り込まれていた。だが、1990年代前半のzshはまだ荒削りだった。ドキュメントは不十分で、ユーザーコミュニティも小さかった。

### Peter Stephensonの時代

zshの成熟に最も大きく貢献した人物を一人挙げるなら、Peter Stephensonだ。

1990年代にzshの開発コミュニティに参加したStephensonは、まずFAQの執筆から始めた。シェルの普及において、ドキュメントの整備は開発そのものと同等以上に重要だ。Stephensonはその後、開発の調整役を担い、"A User's Guide to the Z-Shell"という包括的なガイドを執筆した。このガイドは今日でもzshの最も詳細な文書の一つだ。

Stephensonの本業はソフトウェアエンジニアだ。Oxford大学で物理学の博士号を取得し、9年間物理学の研究者を務めた後、2000年からCambridge Silicon Radio（後のQualcomm）でソフトウェアエンジニアとなった。つまり、zshの30年以上にわたるメンテナンスは、本業の傍らで行われてきた。オープンソースプロジェクトの持続可能性について考えるとき、Stephensonのようなメンテナの存在は見落とされがちだが、彼なしに今日のzshは存在しない。

2004年にはOliver Kiddle、Jerry Peekとの共著で"From Bash to Z Shell: Conquering the Command Line"（Apress）を出版している。bashからzshへの移行を体系的に解説した初めての書籍だった。

### zshの技術的進化

zshの進化は、いくつかの重要なマイルストーンで区切られる。

**zsh 3.0（1996年8月）** は最初の大きな転換点だった。sh/kshエミュレーションが改善され、再帰グロビング（`**/`パターン）が導入された。これは後にbash 4.0（2009年）でglobstarオプションとして取り込まれる機能だが、zshでは13年早く実装されていた。

**zsh 3.1系列** では、シェルの歴史において最も重要な機能の一つが導入された。新しいcompletion system（compsys）だ。これについては技術論のセクションで詳述する。

**zsh 4.0（2001年）** は、3.1系列の安定版リリースとして位置づけられた。compsysが正式に安定版となり、新しいモジュールシステムが整備された。連想配列のサポートもこの系列で安定化した。bashに連想配列が追加されたのは2009年のbash 4.0だ。zshは約10年先行していた。

**zsh 5.0（2012年）** 以降は、安定性と互換性の維持に重点が移った。新機能の追加は慎重に行われ、既存のスクリプトとの互換性が優先された。

### ライセンスと普及

zshはMIT-likeなパーミッシブライセンスの下で配布されている。GPLではない。この事実は、第15回で見たmacOS Catalinaのデフォルトシェル変更と直結する。AppleがGPLv3のbashを避けてzshを選んだ理由の一つが、このライセンスだった。

2019年のmacOS Catalinaでのデフォルト化は、zshの認知度を劇的に高めた。だが、zshはそれ以前から静かに、しかし着実にユーザーを増やしていた。Archlinux、Gentoo、Kali Linuxなどのディストリビューションでは、技術的に熟練したユーザーが対話用シェルとしてzshを選択する例が増えていた。2020年にはKali Linuxもバージョン2020.4でデフォルトシェルをbashからzshに変更した。

macOSとKali Linuxという、まったく異なる性格のプラットフォームが相次いでzshをデフォルトに採用した事実は、zshが「特定のニッチ」ではなく「汎用的な対話用シェル」としての地位を確立したことを示している。

---

## 3. 技術論――zshの深層構造

### zshは「より良いbash」ではない

最初に断言しておく。zshは「より良いbash」ではない。bashとの互換性は高いが、設計思想が根本的に異なる。bashが「POSIX shの拡張」として進化してきたのに対し、zshは「あらゆるシェルの良い部分を統合する最大主義」を掲げている。この違いは、使い込むほど顕著になる。

以下の比較は、表面的な構文の違いではなく、設計思想の違いを示すものだ。

```
zshとbashの設計思想比較:

bash:
  ├── 基盤: POSIX sh準拠
  ├── 拡張: 後方互換性を維持しつつ機能追加
  ├── 補完: bash-completionパッケージ（外部）
  ├── 行編集: GNU Readline（外部ライブラリ）
  └── 方針: 蓄積型進化、互換性最優先

zsh:
  ├── 基盤: POSIX sh + ksh + csh + 独自拡張
  ├── 拡張: 独自の型システム、モジュール機構
  ├── 補完: compsys（組み込み、シェル関数ベース）
  ├── 行編集: zle（組み込み、ウィジェット機構）
  └── 方針: 最大主義、機能統合、内部一貫性
```

### グロブ修飾子（Glob Qualifiers）――findを不要にする構文

zshのグロビングは、bashのそれとは次元が異なる。

bashでは、`*.txt`でカレントディレクトリのテキストファイルにマッチし、bash 4.0以降なら`**/*.txt`で再帰的にマッチできる。ここまではzshも同じだ。だが、zshにはglob qualifiers（グロブ修飾子）がある。

グロブ修飾子は、パターンの末尾に括弧で付加する修飾子だ。ファイルタイプ、パーミッション、更新日時、サイズなど、`find`コマンドでしか表現できなかった条件を、グロブパターンだけで記述できる。

```zsh
# --- ファイルタイプ修飾子 ---
ls **/*(.);       # 通常ファイルのみ（ディレクトリを除く）
ls **/*(/)        # ディレクトリのみ
ls **/*(@)        # シンボリックリンクのみ

# --- パーミッション修飾子 ---
ls **/*(x)        # 実行可能ファイル
ls **/*(f:o+w:)   # その他（others）に書き込み権限があるファイル

# --- 時間修飾子 ---
ls **/*(.mh-1)    # 1時間以内に変更された通常ファイル
ls **/*(.mw+4)    # 4週間以上前に変更された通常ファイル

# --- サイズ修飾子 ---
ls **/*(.Lm+10)   # 10MB以上の通常ファイル
ls **/*(.Lk-100)  # 100KB未満の通常ファイル

# --- 修飾子の組み合わせ ---
ls **/*(.mh-1Lk+100)  # 1時間以内に変更された100KB以上のファイル

# --- ソート ---
ls **/*(Om)       # 更新日時の古い順
ls **/*(oL)       # サイズの小さい順

# --- 数量制限 ---
ls **/*(om[1,5])  # 更新日時の新しいものから5つだけ
```

同じことを`find`で書くとこうなる。

```bash
# findによる同等の操作
find . -type f -name "*.txt" -mmin -60 -size +100k
```

`find`は強力だが、独自のフラグ体系を持つ外部コマンドだ。zshのグロブ修飾子は、シェルのグロビング構文そのものを拡張している。パイプも外部コマンドも不要で、シェルの展開段階で完結する。これは設計思想の違いだ。bashは外部ツールとの連携を前提とし、zshは機能をシェル内部に統合する。

### compsys――文脈を理解する補完システム

第8回で、tcshがTAB補完を発明した歴史を見た。zshのcompsysは、その概念を極限まで推し進めた。

zshには二つの補完システムが存在する。旧式のcompctlと、新式のcompsysだ。compctlはtcshのcompleteコマンドに触発されたもので、補完ルールをコマンドとして一括設定する方式だった。zsh 3.1.6で導入されたcompsysは、根本的に異なるアーキテクチャを持つ。

compsysの核心は、補完がシェル関数のライブラリとして実装されている点だ。TABを押した瞬間に、現在のコンテキスト（カーソル位置のコマンド、引数の位置、直前の単語）に基づいてシェル関数が呼び出され、補完候補が動的に生成される。

```zsh
# compsysの初期化（.zshrcに記述）
autoload -Uz compinit
compinit

# zstyleによる補完の詳細設定
# 大文字小文字を区別しない補完
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 補完候補をメニュー選択式で表示
zstyle ':completion:*' menu select

# 補完候補にグループ名を表示
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'

# killの補完にプロセスリストを使用
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
```

`zstyle`のコンテキスト文字列（`:completion:*`の部分）は、補完が適用される条件を階層的に指定する。これにより、「`git`コマンドのブランチ補完」と「`ssh`コマンドのホスト補完」で異なる表示スタイルを適用する、といった細粒度の制御が可能になる。

bashの補完システム（bash-completionパッケージ）も強力だが、外部スクリプトの集合であり、補完関数の作成手順がzshほど体系化されていない。zshのcompsysは、補完のためのDSL（ドメイン固有言語）を内蔵していると言ってもよい。

### zle（Zsh Line Editor）――プログラマブルな行編集

bashはGNU Readlineをコマンドライン編集のバックエンドとして使用している。Readlineは多くのプログラム（Python REPL、MySQL CLIなど）で共有される汎用ライブラリだ。一方、zshはzle（Zsh Line Editor）という独自の行編集エンジンを内蔵している。

zleの設計の核心は「ウィジェット」だ。コマンドライン上での各操作――カーソル移動、文字削除、単語単位の操作、ヒストリ検索――はすべて「ウィジェット」として定義されている。そして、ユーザーは自分のウィジェットをシェル関数として作成し、任意のキーにバインドできる。

```zsh
# カスタムウィジェットの例: コマンドラインの先頭にsudoを追加
function prepend-sudo {
    if [[ "$BUFFER" != sudo\ * ]]; then
        BUFFER="sudo $BUFFER"
        CURSOR=$(( CURSOR + 5 ))
    fi
}
zle -N prepend-sudo        # ウィジェットとして登録
bindkey '^S' prepend-sudo  # Ctrl-Sにバインド

# カスタムウィジェットの例: 直前のコマンドの出力をクリップボードにコピー
function copy-last-output {
    local last_output=$(fc -ln -1 | eval)
    echo -n "$last_output" | xclip -selection clipboard 2>/dev/null \
        || echo -n "$last_output" | pbcopy 2>/dev/null
    zle -M "出力をコピーしました"
}
zle -N copy-last-output
```

zleの変数群は、コマンドラインの状態に直接アクセスする手段を提供する。

```
zle変数:
  $BUFFER   -- コマンドライン全体の文字列
  $CURSOR   -- カーソル位置（0始まり）
  $LBUFFER  -- カーソルの左側の文字列
  $RBUFFER  -- カーソルの右側の文字列
  $WIDGET   -- 現在実行中のウィジェット名
  $KEYMAP   -- 現在のキーマップ名
```

組み込みウィジェットはドット付き（`.accept-line`、`.backward-char`など）で参照可能だ。ユーザーがウィジェットをオーバーライドしても、ドット付きの名前で元の組み込み版を呼び出せる。

この設計は、GNU Readlineの`.inputrc`による設定とは質的に異なる。Readlineはキーバインドの変更とマクロの定義が可能だが、任意のシェルコードを実行することはできない。zleはシェル関数そのものがウィジェットになる。コマンドライン編集の各段階で、シェルの全機能にアクセスできるのだ。

### zshのオプション体系

zshのもう一つの特徴は、`setopt`/`unsetopt`で制御できるオプションの豊富さだ。bashにも`shopt`があるが、zshのオプション数はその数倍に達する。

```zsh
# 対話的操作を変えるオプション
setopt AUTO_CD            # ディレクトリ名だけでcd（cdを省略）
setopt EXTENDED_GLOB      # 拡張グロビングを有効化
setopt GLOB_DOTS          # ドットファイルもグロブでマッチ
setopt CORRECT            # コマンドのタイポを自動修正提案
setopt HIST_IGNORE_DUPS   # 連続する重複をヒストリに記録しない
setopt SHARE_HISTORY      # 複数のzshセッション間でヒストリを共有
setopt INTERACTIVE_COMMENTS  # 対話モードでも#コメントを許可
```

`AUTO_CD`は些細な機能に見えるが、ターミナルで日常的に作業する人間にとって、`cd /var/log`の代わりに`/var/log`と打つだけでディレクトリが移動できることの快適さは無視できない。`CORRECT`はタイポを検出して修正案を提示する。これらの機能は、zshが「対話的快適さ」を追求するシェルであることを端的に示している。

---

## 4. Oh My Zshの功罪

### 2009年の爆発

2009年8月、Robby RussellはOh My Zshを公開した。

Russellはポートランドのウェブ開発会社Planet Argonの創設者で、当初はチーム内でzshの設定を共有するためのフレームワークとして作成した。curlで一行のコマンドを実行するだけでインストールが完了するという手軽さが、急速な普及を後押しした。

Oh My Zshの成長は驚異的だった。2013年12月に500人のコントリビュータを突破し、2025年現在では2,400人以上のコントリビュータ、300以上のプラグイン、140以上のテーマを擁するコミュニティに成長した。MITライセンスの下で開発されている。

### Oh My Zshが解決した問題

Oh My Zshの功績は明確だ。

第一に、zshのセットアップの障壁を劇的に下げた。素のzshは、初回起動時に設定ウィザードが表示され、ユーザーに数十のオプションについて判断を求める。多くのユーザーにとって、この初期設定は威圧的だ。Oh My Zshはこの障壁を一行のインストールコマンドに置き換えた。

第二に、プラグインの発見と導入を標準化した。gitプラグイン、dockerプラグイン、kubectlプラグイン――これらを`.zshrc`の一行で有効化できる仕組みを提供した。プラグインの品質はまちまちだが、「探す場所」と「導入手順」が統一されていることの価値は大きい。

第三に、テーマによるプロンプトのカスタマイズを広めた。カラフルなプロンプト、Gitのブランチ表示、コマンド実行時間の表示――これらの視覚的な改善が「zshは格好いい」という認知を形成し、bashからの移行動機となった。

### Oh My Zshが隠した問題

だが、Oh My Zshの功績と同じ数だけ、見過ごされている問題がある。

**起動速度の劣化。** Oh My Zshはzshの起動プロセスに顕著なオーバーヘッドを追加する。デフォルト設定でも数百ミリ秒のコストが生じ、プラグインを20個以上有効化すると1秒を超えることも珍しくない。ある調査では、Oh My Zsh自体のロードが起動時間の55%以上を占め、completion systemの初期化が30%程度、構文ハイライトプラグインが14%程度を占めるという結果が報告されている。最適化により842ミリ秒から108ミリ秒に改善した事例もあるが、その最適化ができるのは、Oh My Zshの内部構造を理解している人だけだ。

**zshの本質的機能の覆い隠し。** Oh My Zshを通じてzshを知ったユーザーの多くは、テーマとプラグインしか知らない。`zstyle`によるcompletion設定、`zle -N`によるカスタムウィジェット、グロブ修飾子、`setopt`オプション群――zshの本当の力はこれらにある。だが、Oh My Zshはこれらを抽象化してしまう。抽象化は便利だが、学習の機会を奪う。

**プラグインマネージャの乱立。** Oh My Zshの成功はzshプラグインエコシステムの爆発を招いた。だが、Oh My Zsh自体のプラグイン管理は単純なsourceベースだ。より高速・高機能なプラグイン管理を求めて、antigen、antibody、zinit（旧zplugin）、sheldon、antidoteなど、数多くのプラグインマネージャが登場した。

antigenは最初期のzshプラグインマネージャだったが、読み込み速度が遅かった。antibodyはGo言語で書き直すことで高速化したが、後にメンテナンスが停止し非推奨となった。zinit（旧zplugin）はTurboモードによる非同期読み込みで起動を高速化したが、学習曲線が急だった。antibodyの後継として生まれたantidoteはネイティブzsh実装で手軽さと速度を両立し、sheldonはRust実装で高速性を追求している。

この乱立は、zshエコシステムの成熟過程とも言えるが、新規ユーザーにとっては「何を選べばよいか分からない」という状況を生んでいる。

---

## 5. ハンズオン――Oh My Zshなしでzshを理解する

ここからは、Oh My Zshを使わずにzshをセットアップし、zshの本質的な機能を体験する。

### 環境構築

Docker環境を前提とする。

```bash
docker run -it ubuntu:24.04 /bin/bash
```

あるいは、本記事に付属する`setup.sh`スクリプトで一括構築できる。

```bash
bash setup.sh
```

### 演習1: 素のzshとOh My Zshの起動速度比較

```bash
# zshのインストール
apt-get update -qq && apt-get install -y -qq zsh git curl time >/dev/null 2>&1

echo "=== 演習1: 起動速度の比較 ==="

# --- 素のzshの起動速度 ---
echo "--- 素のzsh（設定なし）---"
echo "exit" | zsh -f --timings 2>&1 | tail -1 || true
# -f: 設定ファイルを読み込まない
for i in 1 2 3 4 5; do
    /usr/bin/time -f "%e秒" zsh -f -c "exit" 2>&1
done

echo ""
echo "--- Oh My Zsh付きzsh ---"
# Oh My Zshをインストール（非対話的に）
export RUNZSH=no
export CHSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 2>/dev/null

for i in 1 2 3 4 5; do
    /usr/bin/time -f "%e秒" zsh -c "exit" 2>&1
done

echo ""
echo "=> 起動速度の差を確認。プラグインなしでもOh My Zshはオーバーヘッドを追加する"
```

### 演習2: zstyleによる補完設定

```zsh
echo "=== 演習2: zstyleによる補完設定 ==="

# Oh My Zshを無効化して素のzshrcを作成
cat << 'ZSHRC' > /tmp/minimal.zshrc
# --- 最小限のzsh設定 ---

# 補完システムの初期化
autoload -Uz compinit
compinit

# 大文字小文字を区別しない補完
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# メニュー選択式の補完
zstyle ':completion:*' menu select

# 補完候補に色を付ける
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# グループ表示
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- マッチなし --%f'

# キャッシュの使用
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

echo "補完設定が読み込まれました"
echo "以下を試してください:"
echo "  ls -<TAB>       -- lsのオプション補完"
echo "  cd /u<TAB>      -- パス補完（大文字小文字無視）"
echo "  kill <TAB>      -- プロセスID補完"
ZSHRC

zsh -c "source /tmp/minimal.zshrc && echo '設定読み込み成功'"
echo ""
echo "=> zstyleの ':completion:*' はコンテキストパターン"
echo "   特定のコマンドだけ異なる補完設定を適用できる"
```

### 演習3: グロブ修飾子の体験

```bash
echo "=== 演習3: グロブ修飾子 ==="

# テスト用ディレクトリ構造を作成
mkdir -p /tmp/glob-lab/{src,docs,logs}
touch /tmp/glob-lab/src/{main.py,utils.py,test_main.py}
touch /tmp/glob-lab/docs/{readme.md,api.md}
touch /tmp/glob-lab/logs/{app.log,error.log}
mkdir -p /tmp/glob-lab/src/lib
touch /tmp/glob-lab/src/lib/helper.py
chmod +x /tmp/glob-lab/src/main.py
ln -s /tmp/glob-lab/src/main.py /tmp/glob-lab/run

# zshで実行
zsh << 'ZSH_SCRIPT'
setopt EXTENDED_GLOB

echo "--- テスト用ファイル構造 ---"
find /tmp/glob-lab -type f -o -type l | sort

echo ""
echo "--- 通常ファイルのみ（ディレクトリとリンクを除く）---"
echo "  パターン: /tmp/glob-lab/**/*(.) "
print -l /tmp/glob-lab/**/*(.)

echo ""
echo "--- ディレクトリのみ ---"
echo "  パターン: /tmp/glob-lab/**/*(/) "
print -l /tmp/glob-lab/**/*(/);

echo ""
echo "--- シンボリックリンクのみ ---"
echo "  パターン: /tmp/glob-lab/**/*(@) "
print -l /tmp/glob-lab/**/*(@)

echo ""
echo "--- 実行可能ファイルのみ ---"
echo "  パターン: /tmp/glob-lab/**/*(*) "
print -l /tmp/glob-lab/**/*(*)

echo ""
echo "--- .pyファイルを更新日時の新しい順で ---"
echo "  パターン: /tmp/glob-lab/**/*.py(om) "
print -l /tmp/glob-lab/**/*.py(om)

echo ""
echo "--- 最新の3ファイルだけ ---"
echo "  パターン: /tmp/glob-lab/**/*(om[1,3]) "
print -l /tmp/glob-lab/**/*(om[1,3])

echo ""
echo "=> findコマンドなしで、グロブだけでファイルをフィルタリングできる"
echo "   (.)=通常ファイル, (/)=ディレクトリ, (@)=シンボリックリンク"
echo "   (om)=更新日時順, ([1,3])=先頭3件"
ZSH_SCRIPT

rm -rf /tmp/glob-lab
```

### 演習4: zleカスタムウィジェット

```bash
echo "=== 演習4: zleカスタムウィジェット ==="

cat << 'ZLE_DEMO'
# --- zleウィジェットのデモ ---
# 以下をzshの対話モードで試してください

# ウィジェット1: コマンドラインの先頭にsudoを追加
function prepend-sudo {
    if [[ "$BUFFER" != sudo\ * ]]; then
        BUFFER="sudo $BUFFER"
        CURSOR=$(( CURSOR + 5 ))
    fi
}
zle -N prepend-sudo
bindkey '^[s' prepend-sudo   # Alt-sにバインド

# ウィジェット2: 現在のコマンドラインをクリアしてから復元
# （一時的に別のコマンドを実行したいとき）
function push-line-and-edit {
    zle push-line    # 現在の行をスタックに保存
    zle clear-screen
    BUFFER=""
}
zle -N push-line-and-edit
bindkey '^Q' push-line-and-edit  # Ctrl-Qにバインド

# ウィジェット3: カーソル位置の単語をシングルクォートで囲む
function quote-current-word {
    local word="${LBUFFER##* }"
    local prefix="${LBUFFER% *}"
    if [[ "$LBUFFER" == "$word" ]]; then
        LBUFFER="'${word}"
    else
        LBUFFER="${prefix} '${word}"
    fi
    RBUFFER="'${RBUFFER}"
}
zle -N quote-current-word
bindkey "^['" quote-current-word  # Alt-'にバインド

echo "ウィジェットが登録されました"
echo "  Alt-s   : コマンドラインの先頭にsudoを追加"
echo "  Ctrl-Q  : 現在の行を保存して空にする（Enterで復元）"
echo "  Alt-'   : カーソル位置の単語をクォート"
ZLE_DEMO

echo ""
echo "上記の内容を ~/.zshrc に追加し、zshの対話モードで試してください"
echo ""
echo "=> zleのウィジェットはシェル関数として実装される"
echo "   \$BUFFER, \$CURSOR, \$LBUFFER, \$RBUFFER で行編集状態にアクセス"
echo "   zle -N で登録し、bindkey でキーにバインドする"
```

### 演習5: Oh My Zshありとなしの設定比較

```bash
echo "=== 演習5: Oh My Zshなしの完全な.zshrc ==="

cat << 'MINIMAL_ZSHRC'
# =================================================
# Oh My Zshなしのzsh設定例
# 起動時間: 100-200ms（Oh My Zshの1/5〜1/10）
# =================================================

# --- ヒストリ設定 ---
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # セッション間でヒストリ共有
setopt HIST_IGNORE_DUPS       # 連続する重複を記録しない
setopt HIST_IGNORE_ALL_DUPS   # 古い重複を削除
setopt HIST_REDUCE_BLANKS     # 余分な空白を削除
setopt HIST_VERIFY            # ヒストリ展開を即実行せず確認

# --- 基本オプション ---
setopt AUTO_CD                # ディレクトリ名だけでcd
setopt EXTENDED_GLOB          # 拡張グロビング
setopt CORRECT                # コマンドのタイポ修正提案
setopt INTERACTIVE_COMMENTS   # 対話モードで#コメント
setopt NO_BEEP                # ビープ音を無効化

# --- 補完設定 ---
autoload -Uz compinit
# 1日1回だけcompinit（キャッシュを使用）
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'

# --- キーバインド ---
bindkey -e                    # Emacsモード
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '^[[Z' reverse-menu-complete  # Shift-Tab

# --- プロンプト ---
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%F{cyan}(%b)%f '
setopt PROMPT_SUBST
PROMPT='%F{blue}%~%f ${vcs_info_msg_0_}%# '

# --- エイリアス ---
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
MINIMAL_ZSHRC

echo "上記の設定を ~/.zshrc として保存してください"
echo ""
echo "特徴:"
echo "  - compinitは1日1回だけ完全実行（起動高速化の鍵）"
echo "  - vcs_infoでGitブランチをプロンプトに表示"
echo "  - zstyleで補完を細かく制御"
echo "  - Oh My Zshのオーバーヘッドなし"
```

---

## 6. まとめと次回予告

### この回の要点

第一に、zshは1990年にPaul FalstadがPrinceton大学で開発したシェルであり、「すべてのシェルの最良の部分を統合する」という最大主義の設計思想を持つ。名前はティーチングアシスタントZhong Shaoのログイン名に由来する。Peter Stephensonが30年以上にわたりメンテナンスを続け、zshの成熟を支えてきた。

第二に、zshはbashの「上位互換」ではなく「異なる設計思想」のシェルだ。グロブ修飾子はfindコマンドの機能をシェル内部に統合し、compsysはコンテキスト感知型の補完をシェル関数のライブラリとして実装し、zleはコマンドライン編集のあらゆる操作をプログラマブルなウィジェットとして定義可能にする。これらはbashには存在しない機能だ。

第三に、Oh My Zsh（Robby Russell, 2009年）はzshの普及を劇的に加速させた。2,400人以上のコントリビュータと300以上のプラグインを持つコミュニティは、オープンソースエコシステムの成功事例だ。だが同時に、Oh My Zshはzshの本質的な機能を覆い隠し、起動速度の劣化をもたらし、「zshを使っている」と「Oh My Zshを入れた」を混同させる原因にもなっている。

第四に、プラグインマネージャの変遷――antigenからantibody、zinit、antidote、sheldonへ――は、zshエコシステムの成熟過程を映し出している。各ツールは速度、使いやすさ、言語実装（zshネイティブ vs Go vs Rust）のトレードオフの中で競争しており、万人に最適な選択肢は存在しない。

第五に、Oh My Zshなしで素のzshを設定する経験は、zshの理解を深めるための最も効果的な手段だ。`zstyle`、`zle -N`、`setopt`、`autoload -Uz compinit`――これらのコマンドを自分の手で書き、結果を確認することで、初めてzshの設計思想が見えてくる。

### 冒頭の問いへの暫定回答

「zshは『より良いbash』なのか、それとも根本的に異なるシェルなのか」――この問いに対する暫定的な答えはこうだ。

zshは根本的に異なるシェルだ。

bashとの構文互換性が高いために「上位互換」と認識されがちだが、zshの設計思想は「POSIX shを拡張する」bashのそれとは本質的に異なる。bashが外部ツールとの連携を前提とし、シェル自体は薄いレイヤーであろうとするのに対して、zshは機能をシェル内部に統合し、シェルそのものを強力な対話的環境にしようとする。

グロブ修飾子がfindを不要にし、compsysが汎用の補完フレームワークを内蔵し、zleがコマンドライン編集をプログラマブルにする。これらは「bashの改良版」ではなく、「シェルとは何か」という問いに対する異なる回答だ。

Oh My Zshはzshへの入口としては優れている。だが、入口を通り過ぎることなく立ち止まってしまうユーザーが多いのも事実だ。zshの本質を知るには、Oh My Zshの先に進む必要がある。

### 次回予告

zshは「すべてを取り込む」最大主義の道を選んだ。だが、まったく逆のアプローチを取ったシェルがある。

次回のテーマは「fish――意図的にPOSIXを捨てたシェル」だ。

2005年にAxel Liljencrantzが公開したfish（Friendly Interactive Shell）。"Finally, a command line shell for the 90s"というスローガン。設定なしで動く構文ハイライト、オートサジェスチョン、そしてPOSIX非互換という意図的な選択。fishは「過去との互換性を捨てることで得られる未来」を示した。だが、その代償はどれほどのものだったのか。

「POSIX互換でないシェルに、存在意義はあるのか」――次回は、その問いに向き合う。

---

## 参考文献

- Wikipedia, "Z shell" <https://en.wikipedia.org/wiki/Z_shell>
- Peter Stephenson, "A User's Guide to the Z-Shell" <https://zsh.sourceforge.io/Guide/zshguide.html>
- Peter Stephenson, "A User's Guide to the Z-Shell", Chapter 6: Completion <https://zsh.sourceforge.io/Guide/zshguide06.html>
- zsh.sourceforge.io, "Zsh Line Editor" <https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html>
- zsh.sourceforge.io, "Expansion" <https://zsh.sourceforge.io/Doc/Release/Expansion.html>
- zsh.sourceforge.io, "Release Notes" <https://zsh.sourceforge.io/releases.html>
- zsh-users/zsh, "LICENCE" <https://github.com/zsh-users/zsh/blob/master/LICENCE>
- GitHub, "ohmyzsh/ohmyzsh" <https://github.com/ohmyzsh/ohmyzsh>
- Open Source Stories, "Robby Russell and the happy little accidental success of Oh My Zsh" <https://www.opensourcestories.org/stories/2023/robby-russell-ohmyzsh/>
- The Register, "Dissed Bash boshed: Apple makes fancy zsh default in forthcoming macOS 'Catalina' 10.15" <https://www.theregister.com/2019/06/04/apple_zsh_macos_catalina_default/>
- Kali Linux Blog, "Kali Linux 2020.4 Release" <https://www.kali.org/blog/kali-linux-2020-4-release/>
- Matthew J. Clemente, "Speeding Up My Shell (Oh My Zsh)" <https://blog.mattclemente.com/2020/06/26/oh-my-zsh-slow-to-load/>
- Dave Dribin, "Improving Zsh Performance" <https://www.dribin.org/dave/blog/archives/2024/01/01/zsh-performance/>
- GitHub, "rossmacarthur/zsh-plugin-manager-benchmark" <https://github.com/rossmacarthur/zsh-plugin-manager-benchmark>
- GitHub Gist, "Comparison of ZSH frameworks and plugin managers" <https://gist.github.com/laggardkernel/4a4c4986ccdcaf47b91e8227f9868ded>
- Oliver Kiddle, Peter Stephenson, Jerry Peek, "From Bash to Z Shell: Conquering the Command Line", Apress, 2004
