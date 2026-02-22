# 第21回：次世代シェルの挑戦――Nushell、Oil/YSH、Elvish、その先へ

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- Nushell（2019年-）の構造化データパイプライン――テキストストリームに代わる「テーブル」という発想
- Oil Shell / Oils（2016年-）の二重戦略――bash互換のOSHと新言語YSHによる段階的移行パス
- Elvish（2014年-）の言語設計――構造化データ、名前空間、例外処理、クロージャを備えたシェル
- Xonsh、Murexなど「その先」の挑戦者たち――Python統合、型付きパイプ
- 各シェルが選んだ「互換性 vs 革新性」のトレードオフと、テキストストリームの限界への回答

---

## 1. 導入――`ls`の結果がテーブルで返ってきた日

私がNushellを初めて触ったのは、2020年の秋だった。

きっかけは些細なことだ。Hacker Newsに流れてきた投稿に「A new type of shell」という見出しがあり、Rust製のシェルという説明に惹かれてインストールした。当時、私はzshを対話用に、POSIX shをスクリプト用に使い分ける日常を送っていた。第19回で語ったdotfiles文化の真っただ中にあり、自分のシェル環境にはそれなりの自信を持っていた。

`ls`と打った瞬間、画面に表示されたものは、私がこの24年間見慣れてきたものとは根本的に異なっていた。

ファイル名がずらりと並ぶテキストの羅列ではない。名前、型、サイズ、更新日時が整然と並んだ**テーブル**が表示されたのだ。まるでスプレッドシートか、データベースのクエリ結果のように。

```
╭────┬──────────────┬──────┬──────────┬──────────────╮
│  # │     name     │ type │   size   │   modified   │
├────┼──────────────┼──────┼──────────┼──────────────┤
│  0 │ Cargo.toml   │ file │  2.4 KiB │ 2 hours ago  │
│  1 │ src          │ dir  │  4.0 KiB │ 3 hours ago  │
│  2 │ README.md    │ file │    892 B │ 1 day ago    │
│  3 │ target       │ dir  │  4.0 KiB │ 2 hours ago  │
╰────┴──────────────┴──────┴──────────┴──────────────╯
```

そして`ls | where type == "dir"`と打つと、ディレクトリだけが抽出された。`ls | sort-by size | reverse`と打つと、サイズの大きい順に並び替えられた。`grep`も`awk`も`sort`も使っていない。パイプラインを流れているのはテキストではなく、**構造化されたデータ**だ。

私は衝撃を受けた。同時に、既視感があった。この感覚は、かつてPowerShellを初めて触ったときに感じたものと同じだ。オブジェクトがパイプラインを流れる世界。だが、NushellはPowerShellとは異なり、Unixの血を引くシェルだった。

もう一つの衝撃は、同じ頃にAndy ChuのOil Shellプロジェクトのブログ記事を読んだときに訪れた。bashの言語設計の問題点を一つ一つ分析し、「シェル言語を真面目に設計し直す」という途方もない目標を掲げている人間がいる。しかも、既存のbashスクリプトとの互換性を保ちながら、だ。これは白紙から書き直すNushellとはまったく異なるアプローチだった。

あなたは、自分が日常的に使っているシェルのパイプラインを流れるものが「テキスト」である必要があるのか、考えたことがあるだろうか。Thompson shellが1971年に生み出し、第6回で語ったパイプの思想——「プログラムの出力を別のプログラムの入力に繋ぐ」——は、50年以上にわたってテキストストリームとして実装されてきた。だが、それは「唯一の正解」だったのか。

この回では、テキストストリームの限界とPOSIX互換性の呪縛に、異なるアプローチで挑む次世代シェルたちの物語を追う。

---

## 2. 歴史的背景――なぜ「次世代」が必要とされたのか

### テキストストリームの限界

第6回で私は、パイプとUnix哲学について語った。テキストストリームの「天才性」と「限界」の両面を。50年を経た今、その限界は技術的負債として確実に蓄積されている。

テキストストリームの問題は明確だ。構造化されたデータ——JSONファイル、CSVテーブル、APIレスポンス——を扱うとき、私たちは常に「パース」という余計な工程を挟む。`ls -l`の出力からファイルサイズだけを取り出すために`awk '{print $5}'`と書く。だが、`ls -l`の出力フォーマットが変われば、この`awk`は壊れる。カラム位置に依存した脆いパースだ。

JSON処理はさらに顕著だ。2010年代以降、APIから返されるデータはほぼすべてJSON形式になった。だが、bashにはJSONを解析する能力がない。`jq`という外部ツールが事実上の標準となり、`curl -s https://api.example.com/users | jq '.[] | .name'`のような呪文が日常になった。パイプラインを流れるのはテキストであり、`jq`が毎回テキストをパースして構造化し、また再びテキストに戻すという無駄が発生する。

この問題は1990年代から認識されていた。第10回で語ったKorn shellのDavid Kornも、シェルの限界を意識していたはずだ。だが、POSIX標準がテキストストリームを前提として固定され（第11回）、bashがその標準を世界に広めた（第13回）ことで、テキストストリームは「シェルの本質」と見なされるようになった。

本当にそうだろうか。

### POSIX互換性の呪縛

第11回で私は、POSIX シェル標準を「誰も読まない契約書」と呼んだ。だがこの契約書は、50年にわたってシェルの進化を縛り続けてきた。

fishは第18回で見た通り、意図的にPOSIX互換性を捨てた。だが、fishの革新は主に対話体験にあり、パイプラインを流れるデータの性質そのものは変えなかった。テキストはテキストのままだ。

2016年頃から、より根本的な問いを持った挑戦者たちが現れ始める。「テキストストリームを超えたパイプラインは可能か」「シェル言語をゼロから設計し直したらどうなるか」「bash互換性を保ちながら言語を進化させることは可能か」。

これらの問いに対して、まったく異なるアプローチで回答を試みたのが、Nushell、Oil/YSH、Elvishだ。

### Nushellの誕生（2019年）

2019年8月23日、Sophia Turner（当時はJonathan Turnerとして活動していた）がブログ記事「Introducing nushell」を公開した。共同開発者はYehuda KatzとAndres N. Robalino。Rust製のシェルだった。

きっかけは興味深い。Yehuda KatzがPowerShellのデモをSophia Turnerに見せたのだ。PowerShellの「オブジェクトパイプライン」——テキストではなく.NETオブジェクトがパイプラインを流れる設計——に触発されたKatzは、「この発想をUnixの世界に持ち込めないか」と考えた。Sophia TurnerはRustに精通しており（Rustコンパイラチームにも関わっていた）、パフォーマンスと安全性を両立する実装が可能だった。

Nushellの設計思想は明確だ。パイプラインを流れるのはテキストではなく**テーブル**（構造化データ）である。すべてのコマンドはテーブルを受け取り、テーブルを返す。JSONもYAMLもCSVも、Nushellにとっては同じ「テーブル」だ。

2025年2月時点で、NushellはGitHubで3万以上のスターを集めており、次世代シェルの中で最も広い注目を集めるプロジェクトとなっている。バージョンは0.101.0に達し、まだ1.0には至っていないが、日常利用に十分な安定性を備えている。

### Oil Shell / Oilsの始動（2016年）

Andy Chuは、Nushellとはまったく異なるアプローチを選んだ。

2016年頃、ChuはOil Shellプロジェクトを開始した。彼の問題意識は「bashは壊れているが、bashスクリプトはどこにでもある」という現実にあった。数十億行のbashスクリプトが世界中のインフラで動いている。それらを捨てて新しいシェルに移行することは非現実的だ。では、bashと互換性を保ちながら、言語として進化させることはできないか。

Chuが設計したのは二つのモードを持つ一つのシェルだ。**OSH**（bin/osh）はbash互換モードであり、既存のbashスクリプトをほぼそのまま実行できる。**YSH**（bin/ysh、旧Oil言語）は新たに設計されたシェル言語であり、型付き変数、式、関数、構造化データを備える。この二つは同一のランタイム上で動き、段階的にOSHからYSHへ移行できるパスが用意されている。

2023年3月、ChuはOil言語をYSHに改名した。理由は率直だ——「Oil」という名前が石油を連想させ、「Oil Shell」が石油会社のShell Oilと混同されるためだった。YSHの名は「the shell with Hay」に由来する（Hayはプロジェクトの重要な機能の一つ）。プロジェクト全体はOilsと呼ばれるようになった。

実装面でも独自のアプローチがある。OilsはPythonで書かれているが、カスタムツールでC++にトランスパイルして高速化する。インタプリタの保守性と実行速度を両立するための工夫だ。

### Elvishの登場（2014年頃）

Qi Xiaoは、NushellやOilsよりも早くから動いていた。

2014年頃、Qi XiaoはElvishの開発を始めた。Go言語で実装されたこのシェルは、POSIX互換性を目指さず、白紙から設計された。だが、Nushellのように「テーブル」を前面に出すのではなく、**汎用プログラミング言語としてのシェル**を志向した。

Elvishの特徴は、構造化データのパイプライン、名前空間によるスコープ管理、ラムダ（無名関数）が第一級値であること、そしてtry/catchによる例外処理だ。従来のシェルでは、エラー処理は終了コード（`$?`）の確認か、`set -e`による一律の中断しかなかった。Elvishは「外部コマンドが非ゼロで終了すると例外が発生する」というセマンティクスを持ち、それをtryで捕捉できる。

2025年時点でElvishはバージョン0.21.xであり、Nushellと同様にpre-1.0だ。コミュニティの規模はNushellに比べれば小さいが、言語設計の精密さにおいて独自の支持を集めている。

---

## 3. 技術論――三者三様の設計思想

### Nushell：テーブルが世界を変える

Nushellの核心は、パイプラインを流れるデータの型を変えたことにある。

従来のUnixシェルでは、すべてのコマンドの入出力はバイトストリーム（実質的にはテキスト）だ。`ls`の出力は文字列であり、`grep`はその文字列を行単位で検索し、`awk`は空白文字でフィールドを分割する。データの構造は暗黙の約束事であり、コマンドの組み合わせが変われば壊れる。

Nushellは、この暗黙の約束事を明示的な**型**に変えた。`ls`コマンドは文字列ではなくテーブルを返す。テーブルの各列には名前と型がある。`name`列は文字列、`size`列はファイルサイズ（単位付き）、`modified`列は日時だ。

```nu
# ディレクトリ内のファイルをサイズ順に表示
ls | sort-by size | reverse

# 1MiB以上のファイルだけ抽出
ls | where size > 1MiB

# 特定の拡張子だけ集計
ls **/*.rs | get size | math sum
```

この設計の利点は複数ある。第一に、パースが不要になる。`awk '{print $5}'`のような脆い列番号指定ではなく、`get size`と列名で直接アクセスできる。第二に、型安全性が得られる。数値と文字列を間違えて比較することがなくなる。第三に、エラーメッセージが改善される。パイプラインのどの段階でどのような型の不整合が起きたかを、シェルが具体的に報告できる。

さらにNushellは、データ処理の高性能化にも取り組んでいる。Polarsプラグインを通じて、Apache Arrow仕様に基づく列指向データフォーマットを利用できる。数百万行のCSVファイルをシェル上で直接集計するような作業が、現実的な速度で実行可能だ。

```nu
# Polarsプラグインによる大規模データ処理
polars open sales.csv
  | polars group-by region
  | polars agg (polars col amount | polars sum)
  | polars sort-by amount
  | polars collect
```

ただし、Nushellには代償がある。POSIX互換性は一切ない。既存のbashスクリプトはNushellでは動かない。`for f in *.txt; do echo "$f"; done`のような基本的なbash構文すら異なる。Nushellの世界に入るということは、シェルの語彙を一から学び直すということだ。

これは設計上の意図的な選択である。Sophia Turnerたちは、テキストストリームの限界を根本的に解決するには、POSIX互換性という足かせを外す必要があると判断した。

### Oil/YSH：互換性と革新の両立

Andy Chuは、Nushellとは正反対の哲学を持っていた。

世界には数十億行のbashスクリプトが存在する。CI/CDパイプライン、Dockerfile、インフラの自動化スクリプト。第14回で語った「bashスクリプティングの生態系」は、簡単には捨てられない。Chuの戦略は、この現実を直視した上で、段階的な進化の道を用意することだった。

OSH（Oils Shell）は、bashのほぼ完全な互換シェルだ。既存のbashスクリプトをOSHに切り替えても、ほとんどのスクリプトはそのまま動く。だが、OSHは単なるbashクローンではない。より良いエラーメッセージ、より安全なデフォルト設定、そしてYSHへの移行パスを提供する。

YSH（旧Oil言語）は、シェルの構文を維持しながらモダンなプログラミング言語の機能を取り入れた新言語だ。

```ysh
# YSHの変数宣言（型付き）
var name = 'world'
var items = ['apple', 'banana', 'cherry']
var config = {host: 'localhost', port: 8080}

# for-inループ
for item in (items) {
  echo "Item: $item"
}

# if文（式を使った条件）
if (len(items) > 2) {
  echo "Many items"
}

# proc（手続き）の定義
proc greet (name) {
  echo "Hello, $name"
}
greet 'YSH'
```

YSHの特徴的な設計判断は「シェルコマンド風の構文」と「Python/JavaScript風の式」を共存させていることだ。変数は`var`/`const`で宣言し、リスト`[]`と辞書`{}`を自然に扱える。`echo`や`ls`のようなコマンド呼び出しはシェルらしい構文のままだが、式の中では`len(items)`のようなプログラミング言語風の関数呼び出しが使える。

この「二つの世界の共存」は、bashからの移行を段階的に行えるように設計されている。既存のbashスクリプトをOSHで動かし、問題のある箇所からYSHの構文に書き換えていく。一度にすべてを捨てる必要はない。

```ysh
# OSH（bash互換）からYSHへの段階的移行の例

# Step 1: OSHモードで既存スクリプトを実行（bashと同じ）
name="world"
echo "Hello, $name"

# Step 2: YSHモードに切り替え、型安全な変数宣言に
var name = 'world'
echo "Hello, $name"

# Step 3: 配列やデータ構造もYSH風に
var servers = ['web-01', 'web-02', 'db-01']
for server in (servers) {
  echo "Checking $server..."
}
```

### Elvish：プログラミング言語としてのシェル

Elvishは、Nushellともoil/YSHとも異なる路線を歩んでいる。

Qi Xiaoが設計したElvishは、シェルであると同時に汎用プログラミング言語であることを目指している。構造化データのパイプラインはNushellと共通するが、Elvishが重視するのは**言語としての一貫性**だ。

Elvishのパイプラインは二つのチャネルを持つ。一つは従来のバイトストリーム（外部コマンドとの互換性のため）、もう一つは**値チャネル**だ。値チャネルにはリスト、マップ、クロージャなど、あらゆるElvishの値を流すことができる。

```elvish
# リストをパイプラインに流す
put apple banana cherry | each {|fruit| echo "I like "$fruit }

# マップの操作
var config = [&host=localhost &port=8080]
echo $config[host]  # localhost

# 例外処理
try {
  fail "something went wrong"
} catch e {
  echo "Caught: "$e[reason]
}

# クロージャ（第一級関数）
var greet = {|name| echo "Hello, "$name }
$greet world
```

Elvishの例外処理は、従来のシェルにおけるエラー処理の貧弱さに対する直接的な回答だ。bashでは外部コマンドの失敗は`$?`で確認するか、`set -e`で一律に中断するしかない。`set -e`の問題点は第5回で触れた——条件文の中で予期せず発動するなど、挙動が直感に反する場面が多い。Elvishでは、外部コマンドが非ゼロの終了コードを返すと例外が発生し、`try`ブロックで捕捉できる。これはPythonやJavaの例外処理と同じセマンティクスだ。

名前空間もElvishの重要な特徴だ。bashでは変数も関数もフラットなグローバル空間に存在するため、名前の衝突が起きやすい。大規模なスクリプトでは関数名にプレフィクスを付けるなどの手動の工夫が必要だった。Elvishは言語レベルで名前空間をサポートし、モジュール化されたスクリプティングを可能にする。

### その先の挑戦者たち

Nushell、Oil/YSH、Elvish以外にも、シェルの未来を模索するプロジェクトは存在する。

**Xonsh**は、Anthony Scopatzが2015年頃に公開したPython-シェルハイブリッドだ。Python 3のスーパーセットとして設計されており、Python式とシェルコマンドを一行の中で自由に混在させることができる。

```python
# Xonsh: Pythonとシェルのハイブリッド
import json

# シェルコマンドの結果をPython変数に
files = $(ls -la)

# Pythonの式を直接シェルの中で使う
for f in p'/tmp'.glob('*.log'):
    echo @(f.name)
```

Xonshの発想は明快だ——Pythonを知っているエンジニアにとって、わざわざ別のシェル言語を学ぶ必要があるのか。Pythonそのものをシェルにしてしまえばいい。ただし、起動速度がPythonインタプリタに依存するため、対話的な応答性ではネイティブシェルに劣る。

**Murex**は、Laurence MorganがGo言語で開発した型付きシェルだ。MurexはNushellのように独自のデータ型を導入するのではなく、POSIXパイプのバイトストリームに**型アノテーション**を付加するアプローチをとった。パイプを流れるデータがJSONなのかCSVなのかプレーンテキストなのかをシェルが認識し、それに応じた処理を自動的に適用する。80以上の組み込みコマンド、try/catchブロック、インラインスペルチェック、manページ自動解析による補完といった機能を備える。

### 設計思想の比較

これらの次世代シェルが採用した戦略を整理すると、以下のようになる。

```
互換性（POSIX/bash）
  高 ←──────────────────────────→ 低

  Oil/YSH     Murex     Elvish    Nushell
  (OSHは      (POSIX     (独自     (完全に
   bash互換    パイプ     言語)     新規設計)
   YSHは新)    +型注釈)

データモデル
  テキスト ←──────────────────────→ 構造化

  bash/sh     Oil/YSH   Elvish    Nushell
  (純粋な     (テキスト  (値       (テーブル
   バイト      +型付き   チャネル)  指向)
   ストリーム)  変数)
```

この図が示すのは、「テキストストリームの限界」と「POSIX互換性の呪縛」に対して、各プロジェクトが異なる座標に立っているということだ。Nushellは両方を完全に断ち切った。Oil/YSHはbash互換性を保ちながら段階的に新しいデータモデルを導入する。Elvishは互換性を捨てたが、テーブル一辺倒ではなく汎用プログラミング言語としての道を選んだ。Murexは既存のPOSIXパイプに型情報を載せるという折衷案を提示した。

どのアプローチが「正解」かは、まだ誰にもわからない。

---

## 4. ハンズオン――次世代シェルを体験する

理屈だけでは実感がわかない。実際に触れて、テキストストリームとの違いを体感してもらいたい。

このハンズオンでは、Nushellをインストールし、同じタスクをbashとNushellで実装して比較する。さらにOil/YSH（Oils）のOSHモードとYSHモードも体験する。

### 環境構築

Docker環境（ubuntu:24.04ベース）で実行する。`handson/shell-history/21-next-gen-shells/setup.sh`にセットアップスクリプトを用意した。

```bash
# Docker環境の起動
docker run -it --rm ubuntu:24.04 bash

# 基本パッケージのインストール
apt-get update && apt-get install -y curl wget jq git

# Nushellのインストール（バイナリリリースからダウンロード）
NUSHELL_VERSION="0.101.0"
wget -qO /tmp/nu.tar.gz \
  "https://github.com/nushell/nushell/releases/download/${NUSHELL_VERSION}/nu-${NUSHELL_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
tar xzf /tmp/nu.tar.gz -C /tmp
cp /tmp/nu-${NUSHELL_VERSION}-x86_64-unknown-linux-gnu/nu /usr/local/bin/
chmod +x /usr/local/bin/nu
```

### 演習1: bash vs Nushell——JSON処理の比較

同じJSON処理タスクを、bashとNushellそれぞれで実装する。

```bash
# === サンプルデータの準備 ===
cat > /tmp/servers.json << 'EOF'
[
  {"name": "web-01", "region": "us-east", "cpu": 45.2, "memory": 72.1, "status": "running"},
  {"name": "web-02", "region": "us-east", "cpu": 78.9, "memory": 88.3, "status": "running"},
  {"name": "db-01", "region": "us-west", "cpu": 23.1, "memory": 95.7, "status": "running"},
  {"name": "db-02", "region": "us-west", "cpu": 12.4, "memory": 45.2, "status": "stopped"},
  {"name": "api-01", "region": "eu-west", "cpu": 67.3, "memory": 62.8, "status": "running"},
  {"name": "api-02", "region": "eu-west", "cpu": 91.2, "memory": 78.5, "status": "running"},
  {"name": "cache-01", "region": "us-east", "cpu": 34.5, "memory": 50.1, "status": "running"},
  {"name": "worker-01", "region": "ap-east", "cpu": 55.8, "memory": 83.2, "status": "running"}
]
EOF
```

```bash
# === bash + jq: CPUが70%以上のrunningサーバを地域ごとに集計 ===
echo "--- bash + jq ---"
jq -r '.[] | select(.status == "running" and .cpu > 70) | .region' /tmp/servers.json \
  | sort | uniq -c | sort -rn
# 出力:
#   2 eu-west  ← 注: api-02(91.2)とapi-01(67.3→除外) → 実際は1件ずつ
#   1 us-east
# ※ 正確な結果を得るにはjqの複雑なパイプラインが必要

# より正確なbash + jqの実装
jq '[.[] | select(.status == "running" and .cpu > 70)] | group_by(.region) | map({region: .[0].region, count: length, avg_cpu: (map(.cpu) | add / length)})' /tmp/servers.json
```

```nu
# === Nushell: 同じタスク ===
# nu を起動してから実行
open /tmp/servers.json
  | where status == "running" and cpu > 70
  | group-by region
  | transpose region servers
  | each {|row| {
      region: $row.region,
      count: ($row.servers | length),
      avg_cpu: ($row.servers | get cpu | math avg)
    }}
  | sort-by count --reverse
```

bashでは`jq`の独自構文を駆使する必要がある。`group_by`、`map`、`add`、`length`——これらはすべて`jq`の機能であり、シェルの機能ではない。Nushellでは、データの絞り込み（`where`）、グループ化（`group-by`）、集計（`math avg`）がシェルのネイティブ機能として統合されている。

### 演習2: bash vs Nushell——ログ解析の比較

```bash
# === サンプルログの生成 ===
cat > /tmp/access.log << 'EOF'
2024-01-15 10:23:45 GET /api/users 200 45ms
2024-01-15 10:23:46 POST /api/users 201 120ms
2024-01-15 10:23:47 GET /api/products 200 32ms
2024-01-15 10:23:48 GET /api/users 500 5023ms
2024-01-15 10:23:49 GET /api/products 200 28ms
2024-01-15 10:23:50 DELETE /api/users/42 204 67ms
2024-01-15 10:23:51 GET /api/users 200 41ms
2024-01-15 10:23:52 POST /api/orders 201 230ms
2024-01-15 10:23:53 GET /api/products 500 8012ms
2024-01-15 10:23:54 GET /api/users 200 39ms
EOF
```

```bash
# === bash: エンドポイントごとのエラー率と平均レスポンス時間 ===
echo "--- bash ---"
awk '{
  endpoint=$3;
  status=$4;
  gsub(/ms/, "", $5);
  time=$5;
  total[endpoint]++;
  sum_time[endpoint]+=time;
  if (status >= 500) errors[endpoint]++;
}
END {
  for (ep in total) {
    err = (ep in errors) ? errors[ep] : 0;
    printf "%s: %d reqs, %.1f%% errors, avg %.0fms\n",
      ep, total[ep], err/total[ep]*100, sum_time[ep]/total[ep]
  }
}' /tmp/access.log | sort
```

```nu
# === Nushell: 同じログ解析 ===
open /tmp/access.log
  | lines
  | parse "{date} {time} {method} {endpoint} {status} {duration}"
  | update duration {|row| $row.duration | str replace 'ms' '' | into int}
  | update status {|row| $row.status | into int}
  | group-by endpoint
  | transpose endpoint requests
  | each {|row| {
      endpoint: $row.endpoint,
      total: ($row.requests | length),
      error_rate: (($row.requests | where status >= 500 | length) / ($row.requests | length) * 100),
      avg_duration_ms: ($row.requests | get duration | math avg | math round --precision 0)
    }}
  | sort-by endpoint
```

awkの`gsub`や連想配列を駆使するbash版と比較すると、Nushellの`parse`コマンドによるフォーマット文字列でのパース、`where`による条件フィルタ、`group-by`と`math avg`による集計は、意図が読み取りやすい。これは「テキストをパースして構造化する」工程がシェル自体に組み込まれていることの恩恵だ。

### 演習3: Oil/YSH——bashからの段階的移行

```bash
# === Oilsのインストール ===
# ※ Docker環境ではソースからビルドが必要な場合がある
# 公式のバイナリリリースが利用可能であればそちらを使用
OILS_VERSION="0.23.0"
wget -qO /tmp/oils.tar.gz \
  "https://www.oilshell.org/release/${OILS_VERSION}/oils-for-unix-${OILS_VERSION}.tar.gz"
cd /tmp && tar xzf oils.tar.gz
cd "oils-for-unix-${OILS_VERSION}"
./configure && make && make install
```

```bash
# === OSHモード: 既存bashスクリプトの実行 ===
cat > /tmp/deploy-check.sh << 'SCRIPT'
#!/usr/bin/env osh
# このスクリプトはbash構文だが、OSHで実行できる

declare -a services=("web" "api" "worker")
declare -A ports=(["web"]=80 ["api"]=8080 ["worker"]=9090)

for svc in "${services[@]}"; do
  port="${ports[$svc]}"
  echo "Checking ${svc} on port ${port}..."

  # bash拡張の [[ ]] も動く
  if [[ "${svc}" == "web" ]]; then
    echo "  → Primary service"
  fi
done

echo "All checks complete."
SCRIPT
chmod +x /tmp/deploy-check.sh
osh /tmp/deploy-check.sh
```

```ysh
# === YSHモード: 同じロジックをYSHで書き直す ===
cat > /tmp/deploy-check.ysh << 'SCRIPT'
#!/usr/bin/env ysh

var services = ['web', 'api', 'worker']
var ports = {web: 80, api: 8080, worker: 9090}

for svc in (services) {
  var port = ports[svc]
  echo "Checking $svc on port $port..."

  if (svc === 'web') {
    echo "  → Primary service"
  }
}

echo "All checks complete."
SCRIPT
chmod +x /tmp/deploy-check.ysh
ysh /tmp/deploy-check.ysh
```

両者を見比べてほしい。OSH版は見慣れたbash構文そのものだ。YSH版は、`var`による変数宣言、`[]`と`{}`によるリストと辞書、`for ... in (expr)`による反復、`===`による厳密比較を使っている。シェルスクリプトとしての読みやすさは格段に向上しているが、やっていることは同じだ。

これがOil/YSHの核心だ——捨てなくていい。少しずつ良くしていける。

### 演習で得られるもの、失われるもの

次世代シェルを触って実感すべきことは二つある。

**得られるもの**: データの構造がシェルレベルで保持されることによる、パース工程の排除と型安全性。コードの意図が読み取りやすくなること。エラーメッセージの質の向上。

**失われるもの**: 50年分のエコシステムとの即座の互換性。`man`で引けるコマンドの知識がそのまま活かせない場面がある。チームの全員が新しいシェルを学ぶコスト。既存のCI/CDパイプラインの書き換え。

この得失のバランスをどう評価するかは、あなたの現場が決めることだ。

---

## 5. まとめと次回予告

### まとめ

この回で見てきたのは、「テキストストリームの限界」と「POSIX互換性の呪縛」という二つの問題に対する、まったく異なるアプローチの数々だ。

Nushellは、パイプラインを流れるデータをテキストからテーブル（構造化データ）に変えた。2019年にSophia Turner、Yehuda Katz、Andres N. Robalino がRustで開発を始め、PowerShellのオブジェクトパイプラインの発想をUnixの世界に持ち込んだ。POSIX互換性を完全に捨て、白紙から設計することで、JSON処理やログ解析における「パースの苦痛」を根本的に解消した。

Oil/YSH（Oils）は、Andy Chuが2016年に始めたプロジェクトで、bash互換のOSHと新言語YSHの二本立てによる段階的移行パスを提供する。世界に存在する数十億行のbashスクリプトを捨てずに、言語として進化させるという野心的な試みだ。

Elvishは、Qi Xiaoが2014年頃から開発するGo製シェルで、構造化データパイプライン、名前空間、クロージャ、try/catch例外処理を備える。シェルであると同時に汎用プログラミング言語であることを目指している。

Xonsh（Anthony Scopatz, 2015年頃）はPython 3とシェルのハイブリッド、Murex（Laurence Morgan）はPOSIXパイプに型アノテーションを付加するアプローチで、それぞれ独自の座標から問題に挑んでいる。

冒頭の問いに戻ろう——シェルの「次」は何か。テキストストリームを超えた世界は来るのか。

答えは「すでに来ている、ただし勝者はまだ決まっていない」だ。Nushellの3万スターという数字は注目度の高さを示しているが、bashの座を脅かすには至っていない。Oil/YSHの段階的移行戦略は現実的だが、プロジェクトの完成には時間がかかる。Elvishの言語設計は精緻だが、コミュニティの規模は限定的だ。

これらの次世代シェルが共通して示しているのは、「テキストストリームはシェルの本質ではなく、1971年の技術的制約に基づく実装上の選択だった」という認識だ。Thompson shellの時代にはテキストを流すことが最も合理的だった。だが、JSONとAPIの時代に、その選択を無批判に踏襲する必要はない。

### 次回予告

次世代シェルたちがテキストストリームの限界に挑む一方で、もう一つの異なるパラダイムが存在する。

PowerShell。Microsoft の Jeffrey Snover が2002年に「Monad Manifesto」で提唱し、2006年に実現したオブジェクトパイプラインの世界だ。テキストではなく .NET オブジェクトがパイプラインを流れる。Nushellがインスピレーションを受けたと公言しているその源流を、次回は辿る。

次回のテーマは「PowerShellという異なるパラダイム――オブジェクトパイプラインの世界」。Unix育ちの私が、Windows管理の現場でPowerShellに出会ったときの戸惑いと発見を、率直に語りたい。

---

## 参考文献

- Sophia Turner, "Introducing nushell", nushell.sh blog, 2019年 <https://www.nushell.sh/blog/2019-08-23-introducing-nushell.html>
- Nushell公式サイト <https://www.nushell.sh/>
- Nushell公式ドキュメント, "Dataframes" <https://www.nushell.sh/book/dataframes.html>
- GitHub, nushell/nushell <https://github.com/nushell/nushell>
- The Changelog Podcast #363, "Nushell for the GitHub era" <https://changelog.com/podcast/363>
- Andy Chu, "A Retrospective on the Oils Project", oilshell.org, 2024年 <https://www.oilshell.org/blog/2024/09/retrospective.html>
- Andy Chu, "Reasons for the Big Renaming to Oils, OSH, and YSH", oilshell.org, 2023年 <https://www.oilshell.org/blog/2023/03/rename.html>
- Oils公式サイト <https://oils.pub/>
- Oils公式ドキュメント, "A Tour of YSH" <https://oils.pub/release/latest/doc/ysh-tour.html>
- Elvish Shell公式サイト <https://elv.sh/>
- GitHub, elves/elvish <https://github.com/elves/elvish>
- Elvish公式ドキュメント, "Effective Elvish" <https://elv.sh/learn/effective-elvish.html>
- Elvish公式ドキュメント, "Unique Semantics" <https://elv.sh/learn/unique-semantics.html>
- Xonsh公式サイト <https://xon.sh/>
- GitHub, xonsh/xonsh <https://github.com/xonsh/xonsh>
- Murex公式サイト <https://murex.rocks/>
- GitHub, lmorg/murex <https://github.com/lmorg/murex>
- Lobsters, "Bash vs Fish vs Zsh vs Nushell" <https://lobste.rs/s/qoccbl/bash_vs_fish_vs_zsh_vs_nushell>
