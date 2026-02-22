# 第18回：fish――意図的にPOSIXを捨てたシェル

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- fishの誕生（Axel Liljencrantz, 2005年）と「POSIX互換を意図的に放棄する」という設計判断の背景
- fishの設計原則――Discoverability、User Friendliness、"Configurability is the root of all evil"
- POSIX非互換の具体的内容：`set`による変数代入、`function/end`構文、コマンド置換`(...)`
- 構文ハイライトとオートサジェスチョンが「設定なし」で動作する技術的仕組み
- Universal Variables――セッション間で変数を共有する独自の永続化機構
- fish 2.0（ridiculousfish / Peter Ammon, 2013年）による再生と、fish 4.0（2025年）のRust移行
- fishのWeb-based configuration（fish_config）というGUIアプローチ
- POSIX非互換のコスト（既存スクリプトの非互換）とメリット（一貫した言語設計）の実践的評価

---

## 1. 導入――「動かない」という衝撃

私がfishを初めて試したのは、2015年頃のことだ。

当時の私はzshを対話用シェルとして使い、スクリプトには`#!/bin/bash`を書く生活を送っていた。前回見たOh My Zshの設定もそれなりに整え、プロンプトのカスタマイズにも満足していた。fishの存在はHacker Newsの記事で知った。「設定なしで構文ハイライトが動く」「オートサジェスチョンがデフォルトで有効」という評判に興味を引かれ、手元のマシンにインストールした。

ターミナルでfishと打った瞬間、世界が変わった。

コマンドを打ち始めると、存在しないコマンド名が赤く表示される。正しいコマンド名に修正すると、即座に色が変わる。パスを入力すると、存在するディレクトリは下線付きで、存在しないパスは赤く表示される。入力途中で、過去に実行したコマンドがグレーの文字でサジェスチョンされる。右矢印キーを押すだけで補完が確定する。

これらすべてが、`.fishrc`に一行も書かずに動いていた。

zshで同じことを実現するには、前回見たようにzsh-syntax-highlightingプラグインをインストールし、zsh-autosuggestionsプラグインを追加し、それぞれの設定を`.zshrc`に記述する必要がある。fishでは、すべてがデフォルトだった。

だが、感動はそこまでだった。

次にやったのは、いつもの癖で環境変数を設定しようとしたことだ。`export PATH="$HOME/.local/bin:$PATH"`と打った。動かない。`export`がない。`for f in *.log; do ... done`と書いた。動かない。`do`も`done`もない。手元にあった数十行のbashスクリプトをfishで実行しようとした。一行も通らなかった。

この「動かない」という体験が、私にとってのfishの原点だ。

あなたは、この「動かない」をどう感じるだろうか。不便だと感じるだろうか。欠陥だと感じるだろうか。それとも、「なぜ動かないのか」を考えてみたいと思うだろうか。

fishが「動かない」のは、バグではない。設計だ。そしてその設計判断の背景には、1970年代から50年以上にわたって積み重なったシェル言語の問題に対する、根本的な異議申し立てがある。

---

## 2. 歴史的背景――fishはどこから来たのか

### Axel Liljencrantzの決断（2005年）

2005年2月13日、Axel LiljencrantzはLWN.netで新しいシェルを発表した。fish――friendly interactive shellの頭文字を取った名前だ。

fishのスローガンは"Finally, a command line shell for the 90s"。2005年に「90年代のための」シェルを標榜するこの皮肉は、当時のシェルの現状に対する痛烈な批判だった。2005年時点で、ターミナルに構文ハイライトはなく、タイポしたコマンドは実行して初めてエラーになり、過去のコマンド履歴を参照するにはCtrl-Rを押してインクリメンタル検索するか、`history | grep`とパイプを繋ぐ必要があった。Webブラウザやテキストエディタでは当たり前だった視覚的フィードバックが、シェルには存在しなかった。90年代のGUIアプリケーションが実現していた水準にすら、シェルは達していなかった。

Liljencrantzの判断は明確だった。既存のシェルの問題を「修正」するのではなく、新しいシェルを一から設計する。その際、POSIX互換性という制約を意図的に外す。

この判断は、前回見たzshとは対照的だ。zshはksh互換、tcsh互換、bash互換を追求し、あらゆるシェルの機能を取り込む「最大主義」を選んだ。fishは逆だ。過去との互換性を捨て、言語設計を一から考え直す道を選んだ。

なぜPOSIX互換を捨てたのか。Liljencrantzが問題にしたのは、POSIX shの構文が持つ根本的な一貫性の欠如だ。第5回で見たクォーティング地獄、`$variable`と`"$variable"`の意味の違い、`test`と`[`と`[[`の混在、`export`と`declare`と`typeset`と`local`の乱立。これらは歴史的経緯から生じた複雑さであり、POSIX互換を維持する限り解消できない。fishは、この歴史的負債を一括清算する道を選んだ。

### 開発停滞とridiculousfishによる再生

fishの初期バージョン（1.x系列）はLiljencrantzが一人で開発・メンテナンスしていた。バージョン1.0から1.23.1まで、SourceForge上でリリースが続いた。だが、最終の1.xリリースは2009年3月だった。その後、Liljencrantzの開発活動は停滞した。

2011年後半、ridiculousfishというハンドル名で知られるPeter Ammonが、fishの開発に関わり始めた。AmmonはAppleのエンジニアとしても知られる人物だ。2012年に「fishfish」というフォークのベータ版を公開し、それまでの貢献者たちの作業を統合した。

この統合が実を結び、2013年5月にfish 2.0がリリースされた。fish 2.0は事実上のリブートだった。コードベースはGitHubに移行し、開発体制がオープンなコミュニティモデルに転換した。Liljencrantzが一人で抱えていたプロジェクトが、コミュニティの手に渡った瞬間だ。

### fish 3.0――実用主義への歩み寄り（2018年）

fish 3.0は2018年12月28日にリリースされた。このリリースには、fishの哲学に関わる重要な変更が含まれていた。

`&&`と`||`演算子の追加だ。

fishは当初、論理演算子として`and`と`or`というコマンドだけを提供していた。`cmd1 && cmd2`ではなく`cmd1; and cmd2`と書く。これはfishの「英語に近い構文」という設計思想に沿っていた。だが、bashやzshから移行するユーザーにとって、`&&`が使えないことは大きな障壁だった。

fish 3.0は`&&`と`||`を追加した。POSIX非互換という原則を維持しつつも、移行の痛みを軽減する実用的な判断だった。純粋主義と実用主義の間で、fishは実用主義を選んだ。

### fish 4.0――テセウスの船（2025年）

2025年2月27日、fish 4.0.0がリリースされた。このリリースの最大の特徴は、コードベースがC++からRustに完全に移行したことだ。

このプロジェクトは"The Fish of Theseus"（テセウスの船のfish版）と名付けられた。テセウスの船のパラドクス――すべての部品を一つずつ入れ替えた船は、元の船と同じ船なのか。fishチームはこの問いに倣い、コンポーネントを一つずつRustに移植する方法を採った。最初のRust PRは2023年1月28日にオープンされ、2023年2月19日にマージされた。最後のC++コードが削除されたのは2024年1月だ。約2年間で2,600以上のコミットが積み重ねられ、200人以上のコントリビュータが参加した。

なぜRustなのか。fishチームが公式ブログで説明した理由は二つある。第一に、C++のツールチェーンとコミュニティエコシステムの課題。第二に、並行処理の問題だ。Rustの「恐れのない並行性（fearless concurrency）」――SendトレイトとSyncトレイトによるコンパイル時の安全性保証――が、シェルのような並行処理を多用するプログラムに適していると判断された。

移行期間中も、fishは常に動作する状態を維持した。C++とRustが混在するコードベースが段階的にRust純粋になっていく過程は、「動くソフトウェアを維持しながら基盤を入れ替える」という困難な技術課題の成功例だ。

---

## 3. 技術論――fishの設計思想と言語構造

### 三つの設計原則

fishの公式Design documentには、三つの設計原則が明記されている。

第一の原則は**Discoverability（発見しやすさ）** だ。プログラムの機能は、ユーザーが可能な限り簡単に発見できるように設計されるべきだ。言語は均一であるべきで、ユーザーがコマンド/引数の構文を一度理解すれば、言語全体を理解でき、タブ補完で新しい機能を発見できるようにする。すべてがタブ補完可能で、すべてのタブ補完に説明が付いている。

第二の原則は**User Friendliness（ユーザーフレンドリー）** だ。これは「初心者向け」という意味ではない。ユーザーの意図を推測し、合理的なデフォルトを提供するという意味だ。

第三の原則は**"Configurability is the root of all evil"（設定可能性は諸悪の根源）** だ。これは刺激的な宣言だが、fishの設計文書はこう説明する。「プログラム内のすべての設定オプションは、プログラムがユーザーの本当の意図を自分で判断できないことの証であり、プログラムとプログラマの両方の失敗と見なすべきだ」。

この第三の原則は、zshやbashの哲学と正反対だ。zshの`setopt`には数百のオプションがある。bashにも`shopt`が数十ある。fishの設計思想は、「オプションの数は少なければ少ないほどよい」という立場だ。

三つの原則を図にすると、fishの設計の全体像が見えてくる。

```
fishの設計原則と既存シェルとの対比:

                   設定の多さ
                      |
               bash __|__ zsh
              (shopt)|    (setopt: 数百)
                     |
    fish             |
    (最小限) --------+-----------> 機能の多さ
                     |
                     |
    dash             |
    (POSIX最小限)    |
                     |
                  互換性の高さ

 横軸: 機能の多さ
 縦軸: 設定の多さ

 dash: 機能少、設定少、互換性高
 bash: 機能中、設定中、互換性高
 zsh:  機能多、設定多、互換性中
 fish: 機能中、設定少、互換性低（意図的）
```

### POSIX非互換の具体的内容

fishとbashの構文の違いは、表面的なものではなく、言語設計の思想の違いを反映している。

**変数代入。** bashでは`VAR=value`と書く。fishでは`set VAR value`と書く。なぜか。bashの`VAR=value`は、等号の前後にスペースを入れると意味が変わる。`VAR = value`はコマンド`VAR`に引数`=`と`value`を渡す。この空白感度（whitespace sensitivity）は第5回で見たクォーティング地獄の一因だ。fishの`set`コマンドはこの問題を排除する。すべての引数は通常のコマンド引数として処理される。

```bash
# bash
export PATH="$HOME/.local/bin:$PATH"
MY_VAR="hello world"

# fish
set -gx PATH $HOME/.local/bin $PATH
set MY_VAR "hello world"
```

fishの`set`は、スコープの指定も統一的に扱う。`set -l`でローカル変数、`set -g`でグローバル変数、`set -U`でユニバーサル変数、`-x`でエクスポート。bashでは`local`、`declare`、`export`、`typeset`、`readonly`と複数のビルトインが乱立しているが、fishでは`set`一つで完結する。

**制御構造。** bashの`if ... then ... elif ... then ... else ... fi`に対して、fishは`if ... else if ... else ... end`と書く。`for ... do ... done`は`for ... end`になる。

```bash
# bash
for f in *.log; do
    if [ -s "$f" ]; then
        echo "$f is not empty"
    fi
done

# fish
for f in *.log
    if test -s "$f"
        echo "$f is not empty"
    end
end
```

fishの`end`は、Bourne shell由来の`fi`/`esac`/`done`という非対称な終端子を統一する。`if`は`end`で閉じ、`for`も`end`で閉じ、`while`も`end`で閉じ、`function`も`end`で閉じる。構文の均一性（uniformity）がここにある。

**コマンド置換。** bashの`` `command` ``（バッククォート）と`$(command)`に対して、fishは`(command)`と書く。ドル記号が不要だ。

```bash
# bash
current_branch=$(git branch --show-current)

# fish
set current_branch (git branch --show-current)
```

**パイプとリダイレクト。** パイプ`|`とリダイレクト`>`はbashとほぼ同じだが、stderr のリダイレクトが異なる。bashの`2>&1`に対して、fishは`2>&1`も使えるが、`&>`でstdoutとstderrの両方をリダイレクトする構文も用意されている。

### Universal Variables――セッション間の変数共有

fishの最も独創的な機能の一つが、Universal Variables（ユニバーサル変数）だ。

通常のシェル変数は、そのシェルセッション内でのみ有効だ。bashで`export`した環境変数は子プロセスに継承されるが、別のターミナルウィンドウで起動した別のbashセッションには伝わらない。そのため、永続的な設定は`.bashrc`に書く必要がある。

fishのユニバーサル変数は、この問題を根本的に解決する。`set -U`で設定した変数は、同一マシン上のすべてのfishセッションで即座に共有され、シェルの再起動後も永続する。

```fish
# 一度設定すれば、すべてのfishセッションで有効
set -U fish_greeting "Welcome back."
set -U -x EDITOR vim
```

ユニバーサル変数は`~/.config/fish/fish_variables`ファイルに保存される。変更はアトミックなファイル置換（rename）で行われ、inotify（Linux）やkqueue（macOS/BSD）を使って他のfishセッションに即座に通知される。

この設計は、「設定ファイルを手書きする」というシェルの伝統的なアプローチに対する根本的な代替案だ。

```
変数スコープの比較:

bash:
  local変数 → 関数内のみ
  グローバル変数 → セッション内のみ
  export変数 → 子プロセスに継承
  永続設定 → .bashrc に手書き

fish:
  local変数 (set -l) → ブロック内のみ
  グローバル変数 (set -g) → セッション内のみ
  ユニバーサル変数 (set -U) → 全セッション共有 + 永続
  永続設定 → set -U で完了（ファイル編集不要）
```

変数のスコープ検索は「内側から外側へ」行われる。local → global → universal の順だ。つまり、ユニバーサル変数をグローバル変数でオーバーライドでき、グローバル変数をローカル変数でオーバーライドできる。

### 構文ハイライトとオートサジェスチョン

fishの対話的機能の核心が、構文ハイライトとオートサジェスチョンだ。

**構文ハイライト** は、コマンドラインの各要素をリアルタイムで色分けする。文字を入力するたびに、fishはコマンドラインをパースし、各トークンの種類を判定して色を割り当てる。

- 存在するコマンド → デフォルトの色（通常は緑系）
- 存在しないコマンド → 赤
- 文字列リテラル → 黄色系
- 有効なパス → 下線付き
- 存在しないパス → 赤
- パイプ、リダイレクト → シアン系
- コメント → グレー

重要なのは、この判定が入力のたびにリアルタイムで行われることだ。コマンド名を打ち間違えた瞬間に赤くなり、正しく修正すると即座に色が変わる。実行してエラーを確認するという従来のフィードバックループを、入力段階に前倒ししている。

**オートサジェスチョン** は、現在の入力に基づいて候補をグレーの文字で表示する。候補のソースは二つある。第一がコマンド履歴だ。過去に実行したコマンドの中から、現在の入力で始まるものを検索する。第二が補完システムだ。履歴にマッチがなければ、ファイルパスやコマンドオプションの補完が候補になる。

右矢印キーを押すとサジェスチョン全体が確定し、Alt-右矢印で単語単位の確定もできる。この操作体系は、Webブラウザの検索窓のオートコンプリートに近い。

zshで同等の機能を実現するには、zsh-autosuggestionsプラグインとzsh-syntax-highlightingプラグインを導入し、`.zshrc`に設定を追加する必要がある。bashには同等の組み込み機能が存在しない。fishでは、これらがインストール直後から設定なしで動作する。

### Web-based Configuration（fish_config）

fishは、シェルの設定をブラウザ上で行う`fish_config`コマンドを提供する。

`fish_config`を実行すると、ローカルにWebサーバーが起動し、ブラウザが開く。ブラウザ上で、プロンプトのスタイル、カラースキーム、関数一覧、変数一覧、ヒストリを視覚的に確認・変更できる。テーマの切り替えもプレビュー付きで行える。

この機能は、fishの「Discoverability」原則の具体的な表現だ。利用可能な設定を一覧で表示し、変更結果をリアルタイムでプレビューする。`.bashrc`をテキストエディタで開き、設定項目のドキュメントを別のウィンドウで参照しながら編集する――そのワークフローとは根本的に異なるアプローチだ。

コマンドラインからも`fish_config prompt show`でプロンプトのデモ表示、`fish_config theme save`でテーマの保存が可能だ。GUIとCLIの両方のインタフェースを提供している点は、fishの実用主義的な一面を示している。

---

## 4. fishのPOSIX非互換性のコストとメリット

### コスト――既存資産との断絶

fishがPOSIX互換を捨てたことのコストは明確だ。

**既存のシェルスクリプトが動かない。** これが最大のコストだ。インターネット上にある膨大なbashスクリプト、Stack Overflowの回答、CI/CDパイプラインのrun命令――これらはfishでは動作しない。fishをログインシェルとして使っていても、スクリプトの先頭に`#!/usr/bin/env fish`と書くことはほとんどない。`#!/bin/sh`か`#!/bin/bash`と書く。fishは対話用シェルとしての利用がほぼすべてであり、スクリプティング言語としての普及は限定的だ。

**コマンドラインでのワンライナーの互換性。** ドキュメントやチュートリアルに書かれたbashワンライナーを、fishのプロンプトにそのままペーストできない場面が頻繁に発生する。`export VAR=value`、`VAR=value command`、`$(command)`、`command 2>/dev/null`――日常的に使うこれらの構文が、fishでは異なる書き方を要求する。

fishの公式ドキュメントには"Fish for bash users"というページが用意されており、bashとfishの構文対照表が整備されている。このページの存在自体が、互換性のコストを認めた上での対策だ。

```
bashとfishの構文対照表（主要な差異）:

bash                          fish
--------------------------    --------------------------
VAR=value                     set VAR value
export VAR=value              set -gx VAR value
VAR=value command             env VAR=value command
unset VAR                     set -e VAR
echo $VAR                     echo $VAR （同じ）
"$VAR"                        "$VAR" （同じ、ただしword splitなし）
$(command)                    (command)
`command`                     (command)
if [...]; then ... fi         if ...; end
for x in ...; do ... done     for x in ...; end
cmd1 && cmd2                  cmd1 && cmd2 （fish 3.0以降）
cmd1 || cmd2                  cmd1 || cmd2 （fish 3.0以降）
foo() { ... }                 function foo ... end
source file                   source file （同じ）
$?                            $status
!!                            なし（ただしプラグインあり）
```

### メリット――一貫性と安全性

fishがPOSIX互換を捨てたことで得たメリットも、また明確だ。

**ワード分割の廃止。** これはfishの最も重要な設計判断の一つだ。第5回で詳述したように、POSIX shでは変数展開の後にワード分割（word splitting）が行われる。`$variable`がスペースを含む場合、自動的に複数の引数に分割される。これがクォーティング地獄の根源だった。

fishはワード分割を行わない。`set myvar "hello world"`の後に`echo $myvar`と書けば、`hello world`が一つの引数として渡される。ダブルクォートで囲む必要がない。変数がリスト（配列）の場合のみ、各要素が個別の引数として展開される。

```fish
# fish: ワード分割が起きない
set myvar "hello world"
echo $myvar         # => "hello world"（一つの引数）
touch $myvar        # => "hello world"という名前のファイルが一つ作られる

# bash: ワード分割が起きる
myvar="hello world"
echo $myvar         # => "hello" "world"（二つの引数、ただしechoでは見た目同じ）
touch $myvar        # => "hello"と"world"の二つのファイルが作られる！
```

この違いは些細に見えるかもしれない。だが、第5回で見た数々のバグ――スペースを含むファイル名でスクリプトが壊れる問題、`"$@"`と`$*`の違いを忘れて引数が化ける問題――の根本原因が、このワード分割だった。fishはこの根本原因を除去した。

**構文の均一性。** 前述の通り、fishの制御構造はすべて`end`で終わる。`fi`も`done`も`esac`もない。関数定義も`function ... end`だ。この均一性は、言語の学習コストを下げる。「コマンド/引数の構文を一度理解すれば、言語全体を理解できる」というDiscoverabilityの原則が、ここに具現化されている。

**イベントハンドラ。** fishの関数は、イベントに応じて自動的に実行されるよう設定できる。`function --on-variable`で変数の変更を監視し、`function --on-event`でカスタムイベントに応答する。

```fish
# 変数が変更されたときに自動実行
function notify_path_change --on-variable PATH
    echo "PATH was modified"
end

# カスタムイベントへの応答
function on_deploy --on-event deploy
    echo "Deployment started"
end
emit deploy  # イベントを発火
```

これらの機能は、POSIX互換の制約から解放されたことで可能になった。POSIX shの枠組みの中では、変数の変更を監視する仕組みは存在しない。

---

## 5. ハンズオン――fishの世界を体験する

ここからは、fishをインストールし、POSIX互換を捨てたシェルの世界を実際に体験する。

### 環境構築

Docker環境を前提とする。

```bash
docker run -it ubuntu:24.04 /bin/bash
```

あるいは、本記事に付属する`setup.sh`スクリプトで一括構築できる。

```bash
bash setup.sh
```

### 演習1: fishの構文ハイライトとオートサジェスチョン

```bash
# fishのインストール
apt-get update -qq && apt-get install -y -qq fish >/dev/null 2>&1

echo "=== 演習1: fishの対話的機能を体験する ==="
echo ""

# fishを起動
echo "--- fishを起動します ---"
echo "以下の操作を試してください:"
echo ""
echo "1. 存在しないコマンドを入力（赤く表示される）:"
echo "   asdfgh"
echo ""
echo "2. 存在するコマンドを入力（色が変わる）:"
echo "   echo hello"
echo ""
echo "3. パスを入力（存在するパスは下線付き）:"
echo "   ls /etc"
echo "   ls /nonexistent"
echo ""
echo "4. コマンドを実行後、同じ先頭文字を入力:"
echo "   （グレーのサジェスチョンが表示される）"
echo "   右矢印キーで確定"
echo ""
echo "=> これらすべてが設定ファイルなしで動作する"
echo ""

fish -c "echo 'fishが動作しています。バージョン:'; fish --version"
```

### 演習2: bashとfishの構文比較

```bash
echo "=== 演習2: bashとfishの構文比較 ==="

# --- bash版 ---
echo "--- bash版 ---"
bash << 'BASH_SCRIPT'
# 変数代入
greeting="Hello, World"
echo "bash: $greeting"

# 環境変数のエクスポート
export MY_ENV="from_bash"
echo "bash env: $MY_ENV"

# 配列
arr=(apple banana cherry)
echo "bash array: ${arr[1]}"  # banana (0-indexed)

# forループ
for fruit in "${arr[@]}"; do
    echo "  bash fruit: $fruit"
done

# コマンド置換
files=$(ls /etc/*.conf 2>/dev/null | head -3)
echo "bash files: $files"

# 条件分岐
if [ -d /etc ]; then
    echo "bash: /etc exists"
fi
BASH_SCRIPT

echo ""

# --- fish版 ---
echo "--- fish版 ---"
fish << 'FISH_SCRIPT'
# 変数代入
set greeting "Hello, World"
echo "fish: $greeting"

# 環境変数のエクスポート
set -gx MY_ENV "from_fish"
echo "fish env: $MY_ENV"

# リスト（fishの配列）
set arr apple banana cherry
echo "fish list: $arr[2]"  # banana (1-indexed)

# forループ
for fruit in $arr
    echo "  fish fruit: $fruit"
end

# コマンド置換
set files (ls /etc/*.conf 2>/dev/null | head -3)
echo "fish files: $files"

# 条件分岐
if test -d /etc
    echo "fish: /etc exists"
end
FISH_SCRIPT

echo ""
echo "=> 主な違い:"
echo "   変数代入: VAR=value → set VAR value"
echo "   配列: 0-indexed → 1-indexed"
echo "   制御構造: do/done/fi → end"
echo "   コマンド置換: \$(cmd) → (cmd)"
```

### 演習3: ワード分割の違いを体験する

```bash
echo "=== 演習3: ワード分割の違い ==="

mkdir -p /tmp/word-split-test
cd /tmp/word-split-test

echo ""
echo "--- bash: ワード分割が起きる ---"
bash << 'BASH_SCRIPT'
cd /tmp/word-split-test
myvar="hello world"

# クォートなしで変数を使う
echo "引数の数（クォートなし）:"
bash -c 'echo "$#"' _ $myvar
# => 2（"hello"と"world"に分割される）

echo "引数の数（クォートあり）:"
bash -c 'echo "$#"' _ "$myvar"
# => 1

# ファイル作成の違い
touch $myvar 2>/dev/null || true
echo "touchの結果（クォートなし）:"
ls -1 /tmp/word-split-test/
rm -f hello world

touch "$myvar" 2>/dev/null || true
echo "touchの結果（クォートあり）:"
ls -1 /tmp/word-split-test/
rm -f "hello world"
BASH_SCRIPT

echo ""
echo "--- fish: ワード分割が起きない ---"
fish << 'FISH_SCRIPT'
cd /tmp/word-split-test
set myvar "hello world"

# クォートなしでも変数は一つの引数
echo "引数の数（クォートなし）:"
bash -c 'echo "$#"' _ $myvar
# => 1（分割されない）

# ファイル作成
touch $myvar 2>/dev/null; or true
echo "touchの結果（クォートなし）:"
ls -1 /tmp/word-split-test/
rm -f "hello world"
FISH_SCRIPT

echo ""
echo "=> bashでは \$myvar がスペースで分割されて2つの引数になる"
echo "   fishでは \$myvar は常に1つの引数として扱われる"
echo "   第5回で見た「クォーティング地獄」の根本原因がここにある"

rm -rf /tmp/word-split-test
```

### 演習4: Universal Variablesの体験

```bash
echo "=== 演習4: Universal Variables ==="

fish << 'FISH_SCRIPT'
echo "--- ユニバーサル変数の設定と確認 ---"

# ユニバーサル変数の設定
set -U my_greeting "Hello from universal"
echo "設定: set -U my_greeting 'Hello from universal'"
echo "値: $my_greeting"

echo ""
echo "--- 変数スコープの確認 ---"

# ローカル変数でオーバーライド
function test_scope
    set -l my_greeting "Hello from local"
    echo "関数内（local）: $my_greeting"
end
test_scope
echo "関数外（universal）: $my_greeting"

echo ""
echo "--- ユニバーサル変数の一覧 ---"
set -U | head -10
echo "..."

echo ""
echo "--- 保存先の確認 ---"
echo "ファイル: ~/.config/fish/fish_variables"
if test -f ~/.config/fish/fish_variables
    echo "内容（先頭5行）:"
    head -5 ~/.config/fish/fish_variables
else
    echo "（ファイルはfishの初回起動時に作成されます）"
end

echo ""
echo "=> set -U で設定した変数は:"
echo "   1. すべてのfishセッションで共有される"
echo "   2. シェルを終了しても永続する"
echo "   3. .bashrcへの手書きが不要"

# クリーンアップ
set -e -U my_greeting
FISH_SCRIPT
```

### 演習5: fishとbashの起動速度とスクリプト実行速度

```bash
echo "=== 演習5: 起動速度の比較 ==="

echo "--- bash（設定なし）---"
for i in 1 2 3 4 5; do
    /usr/bin/time -f "%e秒" bash --norc --noprofile -c "exit" 2>&1
done

echo ""
echo "--- fish（設定なし）---"
for i in 1 2 3 4 5; do
    /usr/bin/time -f "%e秒" fish -N -c "exit" 2>&1
done

echo ""
echo "--- dash（比較用）---"
if command -v dash > /dev/null 2>&1; then
    for i in 1 2 3 4 5; do
        /usr/bin/time -f "%e秒" dash -c "exit" 2>&1
    done
else
    echo "dashがインストールされていません"
fi

echo ""
echo "=> fishの起動速度はbashと同等か、やや遅い傾向がある"
echo "   dashは最速。fishは対話的機能の代償として起動コストがある"
echo "   ただし、fish 4.0のRust移行で改善が見込まれる"
```

---

## 6. まとめと次回予告

### この回の要点

第一に、fishは2005年2月にAxel Liljencrantzが発表したシェルであり、POSIX互換を意図的に放棄するという設計判断を行った。"Finally, a command line shell for the 90s"というスローガンは、2005年時点のシェルが1990年代のGUIアプリケーションの使いやすさにすら達していないという現状認識に基づく。

第二に、fishの設計原則は三つある。Discoverability（発見しやすさ）、User Friendliness（ユーザーフレンドリー）、"Configurability is the root of all evil"（設定可能性は諸悪の根源）。この第三の原則は、zshやbashの「設定で何でもできる」という哲学と正反対だ。

第三に、POSIX非互換の具体的内容は、`set`による変数代入、`function/end`構文、`(command)`によるコマンド置換、そして最も重要なのがワード分割の廃止だ。第5回で見たクォーティング地獄の根本原因を、言語設計のレベルで除去した。

第四に、fishのUniversal Variablesは、セッション間の変数共有と永続化を`.bashrc`の手書きなしで実現する。inotify/kqueueによるリアルタイム同期が、すべてのfishセッション間の一貫性を保証する。

第五に、fishは開発停滞（2009年頃）を経て、ridiculousfish（Peter Ammon）によるfish 2.0（2013年）で再生した。2025年2月のfish 4.0では、C++からRustへの完全移行が達成された。"The Fish of Theseus"プロジェクトは、動作するソフトウェアを維持しながら基盤技術を入れ替える手法の成功事例だ。

### 冒頭の問いへの暫定回答

「POSIX互換でないシェルに、存在意義はあるのか」――この問いに対する暫定的な答えはこうだ。

存在意義はある。だが、その意義には明確な範囲がある。

fishは対話用シェルとして、POSIX互換シェルでは実現できない体験を提供する。設定なしの構文ハイライト、オートサジェスチョン、ワード分割の廃止、Universal Variables。これらは、POSIX互換の制約を外したからこそ可能になった機能だ。

しかし、fishをスクリプティング言語として採用するケースはほとんどない。CI/CDパイプラインのrun命令にfishを使う人はいない。Dockerfileの`RUN`命令にfishを使う人もいない。fishは「対話の革命」をもたらしたが、「スクリプティングの標準」にはならなかった。

これは第9回で見た「シェルの二つの文化」の問題に直結する。対話とスクリプティングは、異なる最適化の方向を持つ。fishは対話の最適化を極限まで追求し、スクリプティングの互換性を切り捨てた。この選択は、fishの設計思想から見れば必然だった。

POSIX互換という「聖域」に疑問を投げたfishの功績は、zshのプラグイン（zsh-syntax-highlighting、zsh-autosuggestions）がfishの機能を模倣しようとした事実にも表れている。fishが証明したのは、「POSIX互換の枠内では実現が困難だった機能が、枠を外せば自然に実装できる」ということだ。

過去との互換性を捨てることで得られる未来がある。だが、その代償も小さくない。fishは、この問いに対するシェルの世界で最も先鋭的な回答だ。

### 次回予告

zshは最大主義、fishはPOSIX放棄。これまで見てきたシェルは、それぞれの方法で「より良いシェル」を追求してきた。

だが、エンジニアの日常には、シェルそのものの選択とは別のこだわりがある。dotfilesだ。

次回のテーマは「シェル設定文化論――dotfiles、プロンプト、そしてアイデンティティ」だ。

`.bashrc`、`.zshrc`、`.config/fish/config.fish`――シェルの設定ファイルは、エンジニアの技術的嗜好と哲学を映し出す鏡だ。dotfilesリポジトリをGitHubに公開し、転職のたびに新しいマシンに持ち運ぶ。rc命名規約のルーツはMITのCTSS RUNCOM（1964年）に遡り、60年の歴史がある。login shell、non-login shell、interactive shell、non-interactive shell――シェルの初期化ファイルの読み込み順序は、多くのエンジニアにとって謎のままだ。

「なぜエンジニアは自分のシェル設定にこだわるのか」――次回は、その問いに向き合う。

---

## 参考文献

- Axel Liljencrantz, "Fish - The friendly interactive shell", LWN.net, 2005年 <https://lwn.net/Articles/136518/>
- fishshell.com, "Design" <https://fishshell.com/docs/current/design.html>
- fishshell.com, "Fish for bash users" <https://fishshell.com/docs/current/fish_for_bash_users.html>
- fishshell.com, "Interactive use" <https://fishshell.com/docs/current/interactive.html>
- fishshell.com, "Tutorial" <https://fishshell.com/docs/current/tutorial.html>
- fishshell.com, "The fish language" <https://fishshell.com/docs/current/language.html>
- fishshell.com, "set - display and change shell variables" <https://fishshell.com/docs/current/cmds/set.html>
- fishshell.com, "fish_config" <https://fishshell.com/docs/current/cmds/fish_config.html>
- fishshell.com, "License" <https://fishshell.com/docs/current/license.html>
- fishshell.com, "Fish 4.0: The Fish Of Theseus" <https://fishshell.com/blog/rustport/>
- ridiculousfish.com, "fish shell 2.0" <https://ridiculousfish.com/blog/posts/fish_shell.html>
- GitHub, "fish-shell/fish-shell" <https://github.com/fish-shell/fish-shell>
- GitHub, "Release fish 3.0.0 (released December 28, 2018)" <https://github.com/fish-shell/fish-shell/releases/tag/3.0.0>
- GitHub, "Release fish 4.0.0 (released February 27, 2025)" <https://github.com/fish-shell/fish-shell/releases/tag/4.0.0>
- Wikipedia, "fish (Unix shell)" <https://en.wikipedia.org/wiki/Fish_(Unix_shell)>
