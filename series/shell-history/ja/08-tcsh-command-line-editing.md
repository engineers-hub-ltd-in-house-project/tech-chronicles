# 第8回：tcshとコマンドライン編集――シェルがUIになった瞬間

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- コマンドライン補完の起源――TENEXオペレーティングシステムのEscape認識
- Ken Greerがカーネギーメロン大学でtcshを生み出した経緯（1975〜1983年）
- GNU Readline（1988年, Brian Fox）がコマンドライン編集をライブラリとして分離した設計判断
- termcap/terminfoとシェルの関係――端末制御の抽象化
- viモード vs emacsモード――二つのエディタ文化がシェルに持ち込まれた歴史
- 補完なし（dash）、基本補完（bash）、高度な補完（zsh）の生産性の差

---

## 1. 導入――TABキーを押した日

大学のBSD環境でcshを使い始めた頃の話だ。

前回語ったとおり、私はFreeBSDのワークステーションでcshと出会い、Bourne shellとはまったく異なる構文の世界に足を踏み入れた。だが、cshとの出会いで最も衝撃を受けたのは、構文の違いではなかった。

ある日、先輩が私の隣でtcshを使っているのを見た。長いファイル名を入力する場面で、先輩はファイル名の最初の数文字だけを打ち、TABキーを押した。すると、残りのファイル名が自動的に補完された。ディレクトリ名を入力するとき、途中まで打ってTABを押すと、候補が一覧表示される。もう一度TABを押すと、候補の中から選択できる。

「何だ、それは」

私はそれまで、コマンドもファイル名も、すべて手で打っていた。長いパス名を間違えないように慎重にタイプし、タイプミスをしたらBackspaceで戻ってやり直す。それが当たり前だった。先輩の画面を覗き込んで、TABキーひとつでファイル名が補完される様子を見たとき、自分がどれほど非効率な操作をしていたかを思い知った。

「tcshを使え。cshの上位互換だ」と先輩は言った。

tcsh――TENEX C shell。名前の「T」は、1969年にBBN（Bolt, Beranek and Newman）で開発されたTENEXオペレーティングシステムに由来する。TENEXが持っていたコマンド補完機能に着想を得て、Ken Greerがカーネギーメロン大学でC shellに補完機能を移植した。それがtcshの始まりだ。

今日、あなたがシェルでTABキーを押すたびに起きることの起源は、ここにある。

コマンドライン補完は、いつ、どのようにして生まれたのか。そして、コマンドライン編集はシェルの何を変えたのか。

前回、私たちはcshが「対話的シェル」という概念を実質的に発明したことを見た。今回は、その対話的シェルがさらに進化し、「ユーザインタフェース」と呼べるものになった瞬間を辿る。

---

## 2. 歴史的背景――補完の発明とコマンドライン編集の誕生

### TENEXとEscape認識――補完の原点

コマンドライン補完の歴史は、UNIXよりも古い。

最も初期の例はBerkeley Timesharing System（SDS 940上で動作）に見られる。このシステムでは、ユーザが入力した文字列が曖昧でなければ、インタプリタが自動的にコマンドを補完した。ただし、曖昧な場合は何も起こらなかった。

TENEXの開発チームは、ここに重要な変更を加えた。「Escape認識（escape recognition）」と呼ばれる仕組みだ。ユーザが部分的なコマンドを入力し、Escapeキーを押すと、システムが残りを補完する。入力が曖昧な場合はビープ音を鳴らし、`?`を入力するとマッチするコマンドの一覧を表示する。

```
; DIR<Escape>
→ DIRECTORY (ファイル一覧)

; CONN<Escape>
→ CONNECT

; CO?
→ CONNECT  CONTINUE  COPY
```

TENEXの補完は、単にタイプ量を減らす利便性の話ではなかった。補完は、ユーザが「自分が何を入力できるか」をシステムに問い合わせる手段だった。コマンド名を全部覚えていなくても、最初の数文字を入力して`?`を押せば候補が分かる。これはマニュアルを引かなくても操作できるインタフェースの原型であり、「発見可能性（discoverability）」の概念をコマンドラインに持ち込んだ最初期の実装だ。

TENEXの後継であるTOPS-20は、この補完機能をさらに進化させた。COMND JSYSというシステムコールを通じて、コマンドインタプリタだけでなく任意のプログラムが補完機能を利用できるようにした。補完が「特定のシェルの機能」から「OSのサービス」に昇格した瞬間だ。この設計思想――補完を特定のアプリケーションから分離し、再利用可能な基盤として提供する――は、後のGNU Readlineの設計に思想的に通じるものがある。

### Ken Greerとtcshの誕生――1975年から1983年へ

Ken Greerは、カーネギーメロン大学でTENEXの補完機能に触れ、その体験をC shellに移植しようと考えた。

1975年9月、GreerはTENEXスタイルのファイル名補完コードの開発を開始した。これは一朝一夕の仕事ではなかった。6年以上の歳月を経て、1981年12月にこのコードがC shellにマージされた。

1983年9月、Fairchild A.I. LabsのMike Ellisがコマンド補完機能を追加した。ファイル名だけでなく、コマンド名も補完できるようになった。そして1983年10月3日、Greerはこの改良版C shellのソースコードをnet.sourcesニュースグループに投稿した。

tcshの「t」はTENEXに由来する。TENEX C shell――TENEXの補完機能を受け継いだC shellだ。

tcshの重要な設計判断の一つは、cshとの完全な後方互換性を維持したことだ。tcshは新しい機能を追加しただけで、cshの既存の構文や挙動を変更しなかった。これはユーザにとって移行コストがゼロであることを意味した。cshの`.cshrc`をそのまま使えるし、cshで書かれたスクリプトもそのまま動く。tcshへの移行は、シェルのバイナリを差し替えるだけで完了した。

### Paul Placewayと継続的な開発

Ken Greerの後、tcshの開発はPaul Placeway（オハイオ州立大学）に引き継がれた。Placewayは長年にわたりtcshのメンテナを務め、コマンドライン編集機能の強化や移植性の改善に注力した。

1990年代にはChristos Zoulasがリードメンテナとなり、2025年現在もメンテナンスを継続している。tcshは40年以上にわたり活発にメンテナンスされ続けているシェルだ。最新安定版は6.24.16（2025年7月リリース）であり、年に1回程度のバグ修正リリースが今も続いている。

### Korn shellのコマンドライン編集――もう一つの流れ

tcshがcshの系譜でファイル名補完を実現していた同じ時期、Bourne shellの系譜でも対話的操作の改善が進んでいた。

1983年、David Korn（Bell Labs）がKorn shell（ksh）を発表した。kshはBourne shell互換の構文を持ちながら、cshの対話的機能を取り込んだ「全部入り」のシェルだった。kshが特に革新的だったのは、コマンドライン編集機能の実装だ。

kshは、シェルとして初めてemacsモードとviモードの2つのコマンドライン編集モードを実装した。Bell LabsのMike Veachがemacsモードを、Pat Sullivanがviモードを実装した。ユーザは自分が使い慣れたエディタのキーバインドで、コマンドラインを編集できるようになった。

これはtcshのファイル名補完とは異なるアプローチだった。tcshが「入力を補完する」機能に注力したのに対し、kshは「入力を編集する」機能に注力した。補完と編集――この2つの概念が合流するのは、GNU Readlineの登場を待つことになる。

### GNU Readline――入力編集のライブラリ化

1988年、Brian FoxはGNU Readlineを作成した。

FoxはFSF（Free Software Foundation）の最初の有給従業員であり、Richard Stallmanの指示のもとでGNUプロジェクトの各種ツールを開発していた。Readlineは、POSIXが要求するシェルの行編集機能を実装するために作られた。

Readlineの設計における最も重要な判断は、コマンドライン編集機能をシェルから分離し、独立したライブラリとして実装したことだ。

```
tcsh: 補完 + 編集 = シェル内蔵
ksh:  編集 = シェル内蔵
readline: 補完 + 編集 = 独立ライブラリ

┌──────────────────────────────────────────────┐
│  GNU Readline (ライブラリ)                    │
│  ┌──────────────┐ ┌──────────────────────────┐│
│  │ 行編集エンジン │ │ ヒストリ管理             ││
│  │ - emacs mode  │ │ - 検索                   ││
│  │ - vi mode     │ │ - 展開（!記法）          ││
│  │ - カスタムバインド│ │ - ファイル保存/読込   ││
│  └──────────────┘ └──────────────────────────┘│
│  ┌──────────────────────────────────────────┐ │
│  │ 補完フレームワーク                        │ │
│  │ - ファイル名補完                          │ │
│  │ - カスタム補完関数                        │ │
│  └──────────────────────────────────────────┘ │
└──────────────────────────────────────────────┘
       │           │           │           │
    ┌──┴──┐    ┌──┴──┐    ┌──┴──┐    ┌──┴──┐
    │ bash │    │ gdb  │    │python│    │ ftp  │
    └─────┘    └─────┘    └─────┘    └─────┘
```

この設計の意義は絶大だった。Readlineを使うプログラムは、シェルに限らない。GDB（デバッガ）、PythonのREPL、FTPクライアント、SQLクライアント――コマンドライン入力を受け付けるあらゆるプログラムが、Readlineをリンクするだけでコマンドライン編集機能を得られるようになった。

さらに重要なことに、Readlineの設定は`~/.inputrc`ファイルで統一的に管理される。bashでもGDBでもPythonでも、同じキーバインドが使える。ユーザは一度設定すれば、Readlineを使うすべてのプログラムで同じ操作感を得られる。これは「入力編集の標準化」だった。

最初の公開リリースは1989年、Bash 1.14に同梱された形で世に出た。バージョン1.05以降、Chet Ramey（Case Western Reserve University）がメンテナンスを引き継ぎ、1998年以降は唯一のメンテナとして今日まで開発を続けている。

---

## 3. 技術論――コマンドライン編集の仕組みと設計空間

### 端末制御の抽象化――termcapからterminfoへ

コマンドライン編集を理解するには、まず端末制御の仕組みを知る必要がある。

シェルがコマンドライン編集を実現するとき、「カーソルを左に3文字移動する」「現在の行を消去する」「文字を挿入する」といった操作が必要になる。問題は、これらの操作を実現するエスケープシーケンスが端末ごとに異なることだ。VT100とxterm、あるいはwyse60では、カーソル移動のエスケープシーケンスが違う。

この問題を解決するために作られたのが、termcap（terminal capability）データベースだ。1978年、Bill JoyがBerkeley Unix用に最初のtermcapライブラリを作成した。Joy自身がviエディタとcshの開発者であることを思い出してほしい。端末非依存のエディタとシェルを作るために、端末能力の抽象化が必要だったのだ。

```
端末制御の抽象化レイヤー:

┌────────────────────────────────────────┐
│ アプリケーション（シェル、エディタ等）  │
│ 「カーソルを左に動かせ」               │
└──────────────┬─────────────────────────┘
               │ termcap/terminfo API
┌──────────────┴─────────────────────────┐
│ termcap/terminfo データベース           │
│ vt100: \e[D    xterm: \e[D             │
│ wyse60: \eD    screen: \e[D            │
└──────────────┬─────────────────────────┘
               │ エスケープシーケンス出力
┌──────────────┴─────────────────────────┐
│ 端末（エミュレータ）                    │
└────────────────────────────────────────┘
```

termcapはASCIIテキスト形式のデータベースで、各端末の能力（カーソル移動、画面消去、色変更、アンダーライン等）を記述する。プログラムは端末の種類を`$TERM`環境変数で判定し、termcapデータベースから該当するエスケープシーケンスを取得する。

後にtermcapの後継としてterminfo（コンパイル済みデータベース）が開発され、ncursesライブラリとともに今日のUNIX系OSの標準となった。

コマンドライン編集は、このtermcap/terminfoの上に構築されている。シェルがカーソルを移動させるとき、文字を挿入・削除するとき、プロンプトを再描画するとき――すべての操作は、termcap/terminfoを通じて端末に適切なエスケープシーケンスを送ることで実現される。

### Readlineのアーキテクチャ

GNU Readlineは、3つの主要コンポーネントから構成される。

**行編集エンジン**は、文字の挿入・削除、カーソル移動、カット&ペースト（kill & yank）を処理する。emacsモードとviモードの2つの編集モードを持ち、`~/.inputrc`の`set editing-mode`ディレクティブで切り替えられる。

**ヒストリ管理**は、過去に入力されたコマンドの保存・検索・展開を担う。cshの`!`記法によるヒストリ展開もサポートする。ヒストリはファイルに永続化され、セッション間で共有できる。

**補完フレームワーク**は、TABキーが押されたときに呼ばれる補完関数の仕組みを提供する。デフォルトではファイル名補完が行われるが、アプリケーション（bashなど）がカスタム補完関数を登録することで、コマンド名やオプション、変数名など、文脈に応じた補完を実現できる。

```
Readlineの入力処理フロー:

キー入力
  │
  ├─ 通常文字 → バッファに挿入 → 画面再描画
  │
  ├─ 編集キー → 編集コマンド実行
  │   ├─ Ctrl-A (emacs) / 0 (vi) → 行頭移動
  │   ├─ Ctrl-E (emacs) / $ (vi) → 行末移動
  │   ├─ Ctrl-K (emacs) / d$ (vi) → 行末まで削除(kill)
  │   ├─ Ctrl-Y (emacs) / p (vi) → ペースト(yank)
  │   └─ Ctrl-R → インクリメンタル逆方向検索
  │
  ├─ TAB → 補完関数呼び出し
  │   ├─ 候補が1つ → 補完実行
  │   ├─ 候補が複数 → 共通接頭辞を補完 + 候補一覧表示
  │   └─ 候補なし → ビープ音
  │
  └─ Enter → 行確定 → アプリケーションに返却
```

### emacsモード vs viモード――二つの文化の衝突

Readlineがemacsモードをデフォルトに選んだのは、偶然ではない。GNU Readlineの生みの親Brian FoxはFSFの従業員であり、FSFの創始者はRichard Stallman――Emacsの作者だ。GNUプロジェクトのツールがemacsキーバインドをデフォルトにするのは、自然な帰結だった。

一方、kshが最初に実装したコマンドライン編集では、emacsモードとviモードが対等な位置づけだった。Bell LabsにはEmacsとvi（ed系列）の両方のユーザがいたからだ。

```
emacsモードの主要キーバインド:
Ctrl-A : 行頭に移動
Ctrl-E : 行末に移動
Ctrl-F : 1文字右に移動
Ctrl-B : 1文字左に移動
Ctrl-D : カーソル位置の文字を削除
Ctrl-K : カーソルから行末まで削除(kill)
Ctrl-Y : 最後にkillしたテキストを貼り付け(yank)
Ctrl-R : ヒストリの逆方向インクリメンタル検索
Ctrl-P : ヒストリの前のコマンド（↑キー）
Ctrl-N : ヒストリの次のコマンド（↓キー）

viモードの主要操作:
（挿入モード）
  Escape : コマンドモードに移行
（コマンドモード）
  h, l   : 左右に移動
  w, b   : 単語単位で移動
  0, $   : 行頭、行末に移動
  x      : カーソル位置の文字を削除
  dw     : 単語を削除
  dd     : 行全体を削除
  i, a   : 挿入モードに移行
  /      : ヒストリの逆方向検索
  k, j   : ヒストリの前/次のコマンド
```

emacsモードはすべてのキーバインドが修飾キー（Ctrl, Meta/Alt）との組み合わせであり、常に「入力モード」にいる。viモードは「挿入モード」と「コマンドモード」を切り替える必要がある。

どちらが「優れている」かは、ユーザのバックグラウンドに依存する。Emacsユーザはemacsモードが自然に感じ、viユーザはviモードが自然に感じる。重要なのは、Readlineがこの選択をユーザに委ねたことだ。`~/.inputrc`に一行書くだけで、Readlineを使うすべてのプログラムの編集モードが切り替わる。

```
# ~/.inputrc
set editing-mode vi
```

この一行の影響範囲は広い。bash、GDB、Python REPL、PostgreSQLクライアント（psql）、MySQL/MariaDBクライアント――Readlineをリンクしているプログラムすべてがviモードになる。逆に言えば、この一行を書かない限り、これらすべてのプログラムはemacsモードで動作する。

### inputrcの条件分岐――プログラムごとの設定

`~/.inputrc`はもう一つ強力な機能を持つ。`$if`ディレクティブによる条件分岐だ。

```
# ~/.inputrc: アプリケーション別の設定
$if Bash
  # bashでのみ有効な設定
  set show-all-if-ambiguous on
  "\C-p": history-search-backward
  "\C-n": history-search-forward
$endif

$if python
  # Python REPLでのみ有効な設定
  set editing-mode vi
$endif

# 共通設定
set bell-style visible
set colored-stats on
set completion-ignore-case on
```

アプリケーション名で条件分岐できるため、「bashではemacsモード、Pythonではviモード」といった使い分けが可能だ。

### 補完の進化――ファイル名補完からプログラマブル補完へ

tcshが最初に実装した補完はファイル名補完だった。TABを押すとカレントディレクトリのファイル名が補完される。その後、コマンド名補完が追加された（Mike Ellis, 1983年）。

しかし、補完の真のポテンシャルはここで終わらなかった。

tcshは`complete`ビルトインコマンドを通じて、プログラマブル補完を実現した。特定のコマンドに対して、どのような引数を補完候補として提示するかを定義できる。

```csh
# tcshのプログラマブル補完
# killコマンドの引数としてシグナル名を補完
complete kill 'p/1/(-HUP -INT -KILL -TERM)/'

# sshコマンドの引数としてknown_hostsのホスト名を補完
complete ssh 'p/1/$hostlist/'

# gitコマンドの第1引数としてサブコマンドを補完
complete git 'p/1/(add commit push pull status diff log branch checkout)/'
```

bashも後にプログラマブル補完機能を実装した。bash 2.04（2000年頃）で`complete`と`compgen`ビルトインが導入され、任意のコマンドに対するカスタム補完関数を定義できるようになった。Ian Macdonaldが立ち上げたbash-completionプロジェクトは、数百のコマンドに対する補完定義を集積したコレクションであり、今日のbashの補完体験の基盤となっている。

zshはcompletion systemをさらに洗練させた。`compctl`（初期の仕組み）から`compsys`（新しいzsh completion system、`compinit`で初期化）への進化を経て、コマンドのサブコマンド、オプション、引数の型まで認識する高度な補完を実現した。

```
補完機能の進化:

tcsh (1981-83)     bash (2000-)        zsh (compsys)
──────────────     ──────────          ──────────────
ファイル名補完     complete/compgen    _complete framework
コマンド名補完     補完関数の登録      サブコマンド認識
complete builtin   bash-completion     オプション/引数型認識
                   プロジェクト        候補のグループ化
                                       候補の説明表示
                                       近似マッチ
```

### tcshとReadline――2つの系譜

コマンドライン編集の歴史には、大きく分けて2つの系譜がある。

**tcshの系譜**（シェル内蔵型）では、補完と編集の機能がシェル自体に内蔵されている。tcshはcshに補完とコマンドライン編集を追加し、すべてをシェルの中で完結させた。zshもこの系譜に属する。zshのZLE（Zsh Line Editor）は独自の行編集エンジンであり、Readlineには依存しない。fishも同様に独自の行編集・補完エンジンを持つ。

**GNU Readlineの系譜**（ライブラリ型）では、補完と編集の機能がシェルから分離されたライブラリとして提供される。bashはReadlineをリンクして行編集機能を実現する。この設計により、bash以外のプログラム（GDB、Python REPL等）もReadlineの恩恵を受けられる。

```
シェル内蔵型:               ライブラリ型:

┌─────────┐                ┌─────────┐  ┌──────┐
│  tcsh   │                │  bash   │  │ gdb  │ ...
│ ┌─────┐ │                └────┬────┘  └──┬───┘
│ │補完 │ │                     │           │
│ │編集 │ │                ┌────┴───────────┴───┐
│ └─────┘ │                │  GNU Readline      │
└─────────┘                └────────────────────┘

┌─────────┐
│  zsh    │
│ ┌─────┐ │
│ │ ZLE │ │
│ │補完 │ │
│ └─────┘ │
└─────────┘
```

どちらの設計にも利点がある。シェル内蔵型は、シェルの内部状態（変数、関数、エイリアス等）を補完に利用しやすい。ライブラリ型は、統一的な操作感を複数のプログラムに提供できる。bashがReadlineを選んだのはGNUプロジェクトの設計方針であり、zshがZLEを選んだのはより高度なカスタマイズ性を追求した結果だ。

---

## 4. ハンズオン――補完と編集の進化を体感する

理論を語るだけでは、補完の価値は伝わらない。実際に手を動かして、補完なし、基本補完、高度な補完の差を体感しよう。

### 環境構築

Docker環境を前提とする。

```bash
docker run -it ubuntu:24.04 bash
# コンテナ内で:
apt-get update && apt-get install -y tcsh dash zsh bash-completion
```

あるいは、本記事に付属する`setup.sh`スクリプトを使えば、演習環境の構築を一括で行える。

```bash
bash setup.sh
```

### 演習1: 補完なし（dash）の世界

dashはDebian/Ubuntuの`/bin/sh`として使われるPOSIX準拠の最小シェルだ。dashにはコマンドライン補完機能がない。この「補完なしの世界」を体験することで、補完が日常の操作にどれほど貢献しているかを実感できる。

```bash
# dashを起動
dash

# 以下の操作を手で入力してみる（TABは効かない）
ls /usr/share/doc/
# ↑ パス名を最後まで手で打つ必要がある

ls /usr/share/doc/bash/
# ↑ bash/ まで全部手動

cat /usr/share/doc/bash/copyright
# ↑ copyright も手動

# dashを終了
exit
```

TABキーを押しても何も起こらない。すべてのパスを正確に手入力しなければならない。1970年代のシェルユーザは、この環境で日常的に作業していた。

### 演習2: tcshの補完を体験する

tcshの補完は、TENEXの「Escape認識」から発展したファイル名補完とコマンド名補完を持つ。

```bash
# tcshを起動
tcsh

# TABキーでファイル名が補完される
ls /usr/sh<TAB>
# → /usr/share/ と補完される

ls /usr/share/do<TAB>
# → /usr/share/doc/ と補完される

# 曖昧な場合はビープ音 + 候補一覧
ls /usr/b<TAB>
# → /usr/bin/ と /usr/... の候補一覧が表示される

# コマンド名補完
whi<TAB>
# → which と補完される

# tcshを終了
exit
```

### 演習3: bashの補完とReadlineの設定

bashはGNU Readlineを通じてコマンドライン編集と補完を提供する。bash-completionパッケージが追加されると、プログラマブル補完も利用できる。

```bash
# bashでのReadline操作

# Ctrl-A: 行頭に移動
# Ctrl-E: 行末に移動
# Ctrl-R: ヒストリの逆方向インクリメンタル検索
# Ctrl-K: カーソルから行末まで削除
# Ctrl-Y: 削除したテキストを貼り付け

# Readlineの設定を確認
bind -V | head -20

# 現在の編集モードを確認
bind -V | grep editing-mode

# viモードに切り替え
set -o vi
# Escapeキーを押してコマンドモードに入り、
# h/lでカーソル移動、wで単語移動、
# /でヒストリ検索ができる

# emacsモードに戻す
set -o emacs
```

### 演習4: bash補完関数を書いてみる

bashのプログラマブル補完の仕組みを理解するために、簡単なカスタム補完関数を書いてみる。

```bash
# カスタム補完関数の定義
# "greet" コマンドに対して名前を補完する

# まずgreetコマンドを関数として定義
greet() {
  echo "Hello, $1!"
}

# 補完関数を定義
_greet_completion() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local names="Alice Bob Charlie Diana"
  COMPREPLY=( $(compgen -W "$names" -- "$cur") )
}

# greetコマンドに補完関数を登録
complete -F _greet_completion greet

# 試してみる
greet A<TAB>
# → greet Alice と補完される

greet <TAB><TAB>
# → Alice Bob Charlie Diana の候補一覧が表示される
```

この仕組みが、bash-completionプロジェクトの基盤だ。git、docker、kubectl、systemctl――数百のコマンドに対して、同様の補完関数が定義されている。

### 演習5: 補完の生産性比較

同じ操作を補完なし（dash）、基本補完（bash）、高度な補完（zsh）で行い、操作の効率を比較する。

```bash
# テスト用のディレクトリ構造を作成
mkdir -p /tmp/completion-test/project-alpha/src/components
mkdir -p /tmp/completion-test/project-alpha/src/utils
mkdir -p /tmp/completion-test/project-beta/docs
touch /tmp/completion-test/project-alpha/src/components/header.tsx
touch /tmp/completion-test/project-alpha/src/components/footer.tsx
touch /tmp/completion-test/project-alpha/src/utils/format.ts
touch /tmp/completion-test/project-beta/docs/readme.md

# --- dashでの操作（補完なし）---
echo "=== dash: 補完なし ==="
# dash で以下のパスを手入力してみる:
# cat /tmp/completion-test/project-alpha/src/components/header.tsx
# 入力文字数: 66文字（すべて手動）

# --- bashでの操作（基本補完）---
echo "=== bash: 基本補完 ==="
# bash で同じ操作:
# cat /tmp/co<TAB>-test/pr<TAB>-al<TAB>/sr<TAB>/co<TAB>/he<TAB>
# TABキーが曖昧さを解消する分だけ自動補完
# 入力文字数: 大幅に削減

# --- zshでの操作（高度な補完）---
echo "=== zsh: 高度な補完 ==="
# zsh（デフォルト設定）で同じ操作:
# cat /tmp/c<TAB>t/p<TAB>a<TAB>/s<TAB>/c<TAB>/h<TAB>
# zshはより積極的に補完し、曖昧な場合もメニューで選択可能
```

この演習を実際にやってみると、補完による入力文字数の削減は驚くほど大きい。66文字のパスが、bashでは20文字程度の入力で済む。zshではさらに少ない。補完なしの環境で1日作業するだけで、コマンドライン補完がいかに生産性に貢献しているかを痛感するだろう。

---

## 5. まとめと次回予告

### この回の要点

第一に、コマンドライン補完の起源はTENEXオペレーティングシステム（BBN, 1969年-）にある。TENEXの「Escape認識」は、ユーザが部分的な入力からシステムに補完を要求する仕組みであり、「発見可能性」をコマンドラインに持ち込んだ最初期の実装だった。

第二に、Ken Greerが1975年にカーネギーメロン大学でTENEXスタイルの補完コードの開発を開始し、1981年にC shellにマージ、1983年にnet.sourcesで公開された。このtcsh（TENEX C shell）は、cshとの完全な後方互換性を保ちながらファイル名補完とコマンドライン編集を追加した。

第三に、同時期にKorn shell（ksh, 1983年）がemacsモードとviモードのコマンドライン編集を実装した。tcshが「補完」に注力し、kshが「編集」に注力した。この2つの流れが、後にGNU Readlineで合流する。

第四に、GNU Readline（1988年, Brian Fox, FSF）は、コマンドライン編集と補完をシェルから分離し、独立したライブラリとして実装した。これにより、bash、GDB、Python REPL等、Readlineを使うすべてのプログラムで統一的な操作感が実現された。`~/.inputrc`による一元的な設定管理も、この設計の重要な恩恵だ。

第五に、コマンドライン編集にはシェル内蔵型（tcsh, zsh）とライブラリ型（bash + Readline）の2つの設計がある。シェル内蔵型はシェルの内部状態を補完に活用しやすく、ライブラリ型は複数プログラムにわたる統一体験を提供する。どちらにも利点があり、「正解」は一つではない。

### 冒頭の問いへの暫定回答

「コマンドライン補完は、いつ、どのようにして生まれたのか」――この問いに対する暫定的な答えはこうだ。

コマンドライン補完は、1960年代末のTENEXに端を発し、1970年代後半にKen Greerの手でUNIXのシェル（csh）に移植された。「入力の効率化」という実用的な動機から始まったこの機能は、シェルの性格を根本的に変えた。補完が導入される前、シェルは「正確に入力しなければ何も起こらない」場所だった。補完が導入された後、シェルは「部分的な入力から残りを推測してくれる」場所になった。この変化は、シェルを「命令入力装置」から「対話的インタフェース」へと昇格させた。

コマンドライン編集の進化も同様の変化をもたらした。kshのemacs/viモード、GNU Readlineのライブラリ化、tcshの進化、zshのZLE――これらはすべて、「コマンドラインでの人間の操作をいかに快適にするか」という問いへの回答だ。そしてこの問いへの回答は、まだ続いている。fishのオートサジェスチョン、zshのメニュー補完、近似マッチ――補完と編集の進化は今も止まっていない。

### 次回予告

ここまで2回にわたり、cshの反乱とtcshの進化を辿ってきた。cshは対話的シェルを発明し、tcshはそれをUIのレベルにまで引き上げた。

だが、cshとtcshの物語は、もう一つの重要なテーマを浮かび上がらせている。「対話に最適なシェル」と「スクリプティングに最適なシェル」は、本当に同じものでよいのか？

cshは対話的には革命的だったが、スクリプティングでは致命的な欠陥を持っていた。Bourne shellはスクリプティングに優れていたが、対話的機能は貧弱だった。tcshは対話的機能を極限まで磨いたが、スクリプティングの問題はcshから引き継いだ。そしてkshやbashは、「全部入り」を目指してBourne shell互換の構文にcshの対話的機能を取り込んだ。

次回は、この「シェルの二つの文化――スクリプティングと対話の乖離」を正面から論じる。対話にはzshを使い、スクリプトの先頭には`#!/bin/sh`と書く。なぜ`#!/bin/zsh`とは書かないのか。Debianが2006年に`/bin/sh`をdashに変更した決断は何を意味するのか。「対話用シェル」と「スクリプト用シェル」の分離は、シェルの歴史が導いた必然なのか。

あなたは、対話用のシェルとスクリプト用のシェルを意識的に使い分けているだろうか。

---

## 参考文献

- tcsh, Wikipedia <https://en.wikipedia.org/wiki/Tcsh>
- TENEX (operating system), Wikipedia <https://en.wikipedia.org/wiki/TENEX_(operating_system)>
- Command-line completion, Wikipedia <https://en.wikipedia.org/wiki/Command-line_completion>
- GNU Readline, Wikipedia <https://en.wikipedia.org/wiki/GNU_Readline>
- Brian Fox (programmer), Wikipedia <https://en.wikipedia.org/wiki/Brian_Fox_(computer_programmer)>
- KornShell, Wikipedia <https://en.wikipedia.org/wiki/KornShell>
- Termcap, Wikipedia <https://en.wikipedia.org/wiki/Termcap>
- Terminfo, Wikipedia <https://en.wikipedia.org/wiki/Terminfo>
- The GNU Readline Library, Chet Ramey <https://tiswww.case.edu/php/chet/readline/rltop.html>
- GNU Readline Library documentation <https://tiswww.case.edu/php/chet/readline/readline.html>
- Readline, ArchWiki <https://wiki.archlinux.org/title/Readline>
- "Things You Didn't Know About GNU Readline", Two-Bit History, 2019 <https://twobithistory.org/2019/08/22/readline.html>
- tcsh man page (Ubuntu) <https://manpages.ubuntu.com/manpages/trusty/man1/tcsh.1.html>
- bash-completion project, GitHub <https://github.com/scop/bash-completion/>
- Programmable Completion, Bash Reference Manual <https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html>
