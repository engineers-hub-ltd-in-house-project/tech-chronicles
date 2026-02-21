# 第5回：クォーティング地獄――シェル言語設計の原罪

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- シェルの処理パイプライン（変数展開→ワード分割→グロビング→クォート除去）の全体像
- ワード分割（word splitting）がなぜ「バグ」ではなく「設計」であるのか
- IFS（Internal Field Separator）の設計意図と挙動
- シングルクォート・ダブルクォート・バックスラッシュの意味の違い
- `"$@"`と`$*`の決定的な差、そしてBourne shellに配列がなかった代償
- ShellCheck（Vidar Holen, 2012年〜）による静的解析がもたらした変革

---

## 1. 導入――スペースが壊した本番環境

あれは2000年代後半、サーバ運用の日常にインフラ自動化が浸透し始めた頃のことだ。

私は数百行のbashデプロイスクリプトを運用していた。毎晩のバッチ処理でログファイルを収集し、アーカイブし、特定の条件に合致するファイルを別のサーバに転送する。何ヶ月も問題なく動いていたそのスクリプトが、ある朝、突然壊れた。

原因を追うと、開発チームの誰かが`/var/log/app/error report_20080315.log`というファイルを手動で作成していた。ファイル名に半角スペースが1つ入っている。たったそれだけのことだ。

私のスクリプトには、こう書かれていた。

```sh
for logfile in $(find /var/log/app -name "*.log" -mtime -1); do
  gzip $logfile
done
```

`$(find ...)`の結果がワード分割され、`/var/log/app/error`と`report_20080315.log`という2つの別々の引数に分裂した。`gzip`は存在しないファイルを圧縮しようとしてエラーを吐き、後続の転送処理も巻き添えで失敗した。

当時の私はこの現象を「ファイル名にスペースを入れたやつが悪い」と思った。だが、今ならわかる。悪いのはスペースを入れた人間ではない。変数展開の結果にワード分割を走らせるシェルの設計と、その設計を理解せずにスクリプトを書いた私自身だ。

`$logfile`と`"$logfile"`の間には、深い溝がある。ダブルクォートの有無で、スクリプトが動いたり壊れたりする。この溝は、1976年から1979年にかけてStephen BourneがBourne shellを設計したときに掘られた。そして47年後の今も、毎日どこかのサーバで、誰かのスクリプトを壊し続けている。

なぜシェルスクリプトはこんなにも壊れやすいのか。それは「バグ」なのか「設計」なのか。

この問いに答えるために、シェルの処理パイプラインを一段ずつ解剖する。前回はBourne shellの言語機能の全体像を描いた。今回は、その言語設計の最も暗い部分——クォーティング地獄——に正面から踏み込む。

---

## 2. 歴史的背景――1979年の設計判断が今も生きている理由

### ワード分割という設計判断

前回の記事で、Bourne shellの処理パイプラインを概略として示した。今回はその各段階を詳細に解剖する。だがその前に、なぜこの処理パイプラインが「こうなった」のかを歴史的に理解しておく必要がある。

1979年、Stephen BourneがUNIX V7とともにBourne shellをリリースしたとき、UNIXのファイルシステムには今日のような複雑さはなかった。ファイル名の最大長は14バイト。慣習として、ファイル名にはアルファベット、数字、ハイフン、アンダースコア、ドットのみを使うのが普通だった。スペースを含むファイル名は「存在しうるが、誰も使わない」ものだった。

この文脈において、ワード分割の設計は合理的だった。シェルの変数に格納される値は、多くの場合「複数の引数をスペース区切りで連結したもの」だった。コマンドの出力も行指向・空白区切りが前提だ。変数展開の結果をスペースで分割して複数の引数にする処理は、当時のUNIXの「すべてはテキスト」という哲学と完全に整合していた。

問題は、この設計判断が47年後の2026年にも生き続けていることだ。現代のファイルシステムは数百バイトのファイル名を許容し、macOS/Windowsとの相互運用でスペースを含むファイル名は日常的に存在する。だが、シェルのワード分割は1979年と同じルールで動いている。

### IFS――ワード分割を制御する不可視の変数

ワード分割の挙動を決定するのは、IFS（Internal Field Separator）という特殊変数だ。Bourne shellから存在するこの変数のデフォルト値は、スペース・タブ・改行の3文字である。

IFSの設計意図は明確だ。コマンドの出力やユーザーの入力をフィールド（単語）に分割するための区切り文字を定義する。`read`コマンドがIFSに基づいて入力を分割するのはもちろん、変数展開やコマンド置換の結果もIFSに基づいてワード分割される。

ここで重要なのは、IFSが「暗黙的に」作用するという点だ。変数展開のたびに、シェルはIFSを参照してワード分割を行う。プログラマが明示的に「ここでワード分割せよ」と指示するのではない。未クォートの変数展開は、常にワード分割の対象になる。この「暗黙性」が、クォーティング地獄の根源だ。

### POSIXが追認した「原罪」

1992年、IEEE 1003.2（POSIX Shell and Utilities）が策定された。策定には6年を要した。この標準は、Bourne shellとKorn shell（ksh88）のサブセットを基盤として設計された。

ワード分割に関して、POSIX標準は興味深い判断を下した。IFSのデフォルト値（スペース・タブ・改行）使用時はSystem V shell互換の挙動を、非デフォルトIFS使用時はKorn shell互換の挙動を許容する形で標準化したのだ。つまり、2つの異なる実装の挙動を両方とも「正しい」と認めた。

この標準化の意味は重い。1979年のBourne shellの設計判断——変数展開の後にワード分割が走るという処理パイプライン——が、国際標準として固定化された。以降、すべてのPOSIX準拠シェル（bash, dash, ksh, zsh --emulate sh）はこの挙動を実装しなければならない。

ワード分割は「バグ」ではない。「設計」であり、しかも「標準化された設計」だ。修正することは、もはや不可能に近い。

### ファイル名とワード分割の衝突

David A. Wheelerは2009年の論文 "Fixing Unix/Linux/POSIX Filenames" で、UNIXのファイル名設計の問題を体系的に論じた。Wheelerはこう指摘する——「よく設計されたシステムでは、簡単なことは簡単であるべきだ。そして『わかりやすく簡単な方法』が正しい方法であるべきだ」。

だがシェルにおいて、ファイル名を安全に扱うことは簡単ではない。変数に格納されたファイル名を別のコマンドに渡す——このごく基本的な操作が、ダブルクォートなしでは壊れる。「わかりやすく簡単な方法」（`cat $filename`）は正しい方法ではなく、正しい方法（`cat "$filename"`）は追加のクォーティングを要求する。

Wheelerの言葉を借りれば、シェルのファイル名処理には「鋭い縁（sharp edges）」がある。そしてその鋭い縁は、1979年の設計判断に由来し、1992年のPOSIX標準化によって永久に固定された。

---

## 3. 技術論――シェルの処理パイプライン詳解

### 5段階の処理パイプライン

シェルがコマンドラインを処理する過程を、正確に5段階に分解する。前回は概略を示したが、今回はクォーティングの観点から各段階を詳しく見ていく。

```
シェルの処理パイプライン（詳細版）:

  ユーザーが入力したコマンドライン
  例: echo $greeting world *.txt
        │
        ▼
  ┌────────────────────────────────────────────┐
  │ 1. トークン化 (Tokenization)               │
  │    コマンドラインをトークンに分割            │
  │    演算子（|, ;, &, &&, ||等）で区切る       │
  │    クォートされた文字列は1トークンとして保持 │
  │                                              │
  │    結果: ["echo", "$greeting", "world",      │
  │           "*.txt"]                           │
  └──────────────────┬─────────────────────────┘
                     │
                     ▼
  ┌────────────────────────────────────────────┐
  │ 2. 展開 (Expansion)                        │
  │    a. ブレース展開 {a,b} → a b（bash拡張） │
  │    b. チルダ展開 ~ → /home/user            │
  │    c. パラメータ/変数展開 $var → 値         │
  │    d. コマンド置換 $(cmd) → 出力            │
  │    e. 算術展開 $((1+2)) → 3                │
  │                                              │
  │    例: $greeting → "hello there"             │
  │    結果: ["echo", "hello there", "world",    │
  │           "*.txt"]                           │
  └──────────────────┬─────────────────────────┘
                     │
                     ▼
  ┌────────────────────────────────────────────┐
  │ 3. ワード分割 (Word/Field Splitting)       │
  │    IFS（デフォルト: スペース/タブ/改行）    │
  │    に基づいて展開結果を分割                 │
  │    ※ 未クォートの展開結果のみ対象           │
  │    ※ リテラル文字列は対象外                 │
  │                                              │
  │    例: "hello there" → "hello", "there"      │
  │    結果: ["echo", "hello", "there", "world", │
  │           "*.txt"]                           │
  └──────────────────┬─────────────────────────┘
                     │
                     ▼
  ┌────────────────────────────────────────────┐
  │ 4. パス名展開 (Pathname Expansion/Globbing)│
  │    *, ?, [...] を含むトークンを              │
  │    マッチするファイル名に展開                │
  │    ※ 未クォートのパターンのみ対象           │
  │                                              │
  │    例: *.txt → "a.txt", "b.txt", "c.txt"    │
  │    結果: ["echo", "hello", "there", "world", │
  │           "a.txt", "b.txt", "c.txt"]         │
  └──────────────────┬─────────────────────────┘
                     │
                     ▼
  ┌────────────────────────────────────────────┐
  │ 5. クォート除去 (Quote Removal)            │
  │    展開の結果使われなかったクォート文字を    │
  │    除去し、最終的な引数リストを確定          │
  │                                              │
  │    最終結果: echo hello there world          │
  │              a.txt b.txt c.txt               │
  └────────────────────────────────────────────┘
```

この処理パイプラインの中で、ステップ2（展開）とステップ3（ワード分割）の間に、クォーティング地獄の本質がある。

### ワード分割の詳細な挙動

ワード分割は、以下の条件をすべて満たすときに発生する。

第一に、対象がパラメータ展開（`$var`）、コマンド置換（`$(cmd)`）、算術展開（`$((expr))`）の結果であること。リテラル文字列（コマンドラインに直接書かれた文字列）はワード分割の対象にならない。

第二に、対象がダブルクォートで囲まれていないこと。`"$var"`のようにダブルクォートで囲まれた展開結果は、ワード分割の対象にならない。

第三に、IFSが空文字列でないこと。`IFS=''`（空文字列）に設定されている場合、ワード分割は行われない。

この3つの条件を理解すれば、クォーティング地獄の大半は回避できる。だが問題は、第二の条件——ダブルクォートの存在——を忘れやすいことだ。

具体例で見よう。

```sh
# 変数に「スペースを含むファイル名」を代入
filename="error report.log"

# 未クォートの変数展開 → ワード分割が発生
cat $filename
# シェルの処理:
#   展開: cat error report.log
#   ワード分割: "cat" "error" "report.log" （3引数）
#   → error と report.log を別々のファイルとして開こうとする

# ダブルクォート付きの変数展開 → ワード分割が抑制される
cat "$filename"
# シェルの処理:
#   展開: cat "error report.log"
#   ワード分割: スキップ（ダブルクォート内）
#   クォート除去: "cat" "error report.log" （2引数）
#   → 意図通りの動作
```

ダブルクォート2文字の有無が、スクリプトの正否を分ける。そしてこの差は、ファイル名にスペースが含まれない限り表面化しない。これこそが時限爆弾の本質だ。テスト環境では正しく動くが、本番環境の特定のファイル名でのみ壊れる。

### グロビングの罠――ワード分割の先にあるもう一つの地雷

ワード分割だけがクォーティング地獄の原因ではない。処理パイプラインのステップ4——パス名展開（グロビング）——もまた、未クォートの変数展開を予期しない方法で書き換える。

```sh
# 変数にアスタリスクを含む値を代入
message="Error: file *.log not found"

# 未クォートの展開 → グロビングが発生
echo $message
# シェルの処理:
#   展開: echo Error: file *.log not found
#   ワード分割: "echo" "Error:" "file" "*.log" "not" "found"
#   グロビング: *.log → カレントディレクトリの.logファイルに展開
#   → "echo" "Error:" "file" "a.log" "b.log" "not" "found"
#   → echo は全く意図しない文字列を出力する

# ダブルクォート付き → ワード分割もグロビングも抑制
echo "$message"
# → "Error: file *.log not found" （意図通り）
```

前回のThompson shellの解説で触れたように、グロビングはもともとUNIXの初期バージョン（V1-V6、1969-1975年）では外部コマンド `/etc/glob` として実装されていた。Dennis Ritchieが実装したこのコマンドは、ワイルドカードパターンをファイル名に展開する役割を担っていた。Bourne shell（V7、1979年）でグロビングはシェル内蔵化されたが、「展開結果を呼び出されたプログラムに渡す」という基本設計は変わらなかった。

ワード分割の後にグロビングが走るということは、変数に格納された文字列の中に`*`や`?`や`[`が含まれていれば、それがファイル名パターンとして解釈される可能性があるということだ。これは、ワード分割とは別種の「鋭い縁」だ。

### 3種類のクォーティング

シェルには3種類のクォーティング機構がある。これらの違いを正確に理解することが、クォーティング地獄を生き延びるための地図だ。

```
シェルのクォーティング機構:

  種類              挙動                           主な用途
  ──────────────────────────────────────────────────────────────
  シングルクォート  すべての特殊文字を無効化       リテラル文字列
  'text'            変数展開もコマンド置換も       変数展開したくない場合
                    行われない                     正規表現パターン

  ダブルクォート    $, `, \ の特殊意味を保持       変数展開は行いたいが
  "text"            ワード分割とグロビングを       ワード分割は防ぎたい場合
                    抑制する                       ほとんどの場合の正解

  バックスラッシュ  直後の1文字のみをクォート       特定の1文字だけを
  \c                改行の直前では行継続            エスケープしたい場合
```

具体例で違いを確認しよう。

```sh
name="world"

# シングルクォート: すべてリテラル
echo 'Hello $name'
# 出力: Hello $name  （$nameが展開されない）

# ダブルクォート: 変数展開は行うがワード分割を抑制
echo "Hello $name"
# 出力: Hello world  （$nameが展開される）

# バックスラッシュ: 1文字だけエスケープ
echo Hello \$name
# 出力: Hello $name  （$の前のバックスラッシュが$をリテラル化）
```

ここで注意すべきは、ダブルクォート内で特殊意味を保持する文字だ。ダブルクォートの中では、`$`（変数展開）、`` ` ``（コマンド置換）、`\`（エスケープ）、`"`（ダブルクォート終端）、そして改行が特殊意味を保つ。それ以外の文字はすべてリテラルとして扱われる。

```sh
# ダブルクォート内でのバックスラッシュの挙動
echo "Price: \$100"    # → Price: $100  （\$は$をリテラル化）
echo "Path: C:\\Users"  # → Path: C:\Users  （\\は\をリテラル化）
echo "Say \"hello\""   # → Say "hello"  （\"は"をリテラル化）
echo "Tab:\there"      # → Tab:\there  （\tは特殊意味なし、\がそのまま残る）
```

最後の例に注目してほしい。ダブルクォート内でのバックスラッシュは、`$`, `` ` ``, `"`, `\`, 改行の前でのみエスケープ文字として機能する。`\t`や`\n`はCの文字列リテラルのようには解釈されない。これもまた、シェルの「鋭い縁」の一つだ。

### "$@" vs "$\*"――配列なき時代の妥協

Bourne shellには配列変数が存在しなかった。配列変数が初めてシェルに導入されたのはksh88であり、bashに取り込まれたのは1996年のbash 2.0だ。POSIX shにも配列は含まれない。

この「配列の不在」が、シェルスクリプトにおける引数の扱いを複雑にしている。スペースを含む複数のファイル名を安全にリストとして保持し、ループで処理する——この基本的な操作が、配列なしでは困難だ。

Bourne shellが提供した妥協策が、位置パラメータ（`$1`, `$2`, ...）と特殊変数`$@`、`$*`だ。だが、この2つの特殊変数の挙動の違いは、シェルスクリプトの中でも最もわかりにくい部分の一つだ。

```sh
# 位置パラメータの設定
set -- "error report.log" "access log.txt" "debug.log"

# $* をダブルクォートで囲む: すべてのパラメータを1つの文字列に結合
echo "--- \"\$*\" ---"
for arg in "$*"; do
  echo "  arg: '$arg'"
done
# 出力:
#   arg: 'error report.log access log.txt debug.log'
# → 1つの引数になる（IFSの最初の文字で結合される）

# $@ をダブルクォートで囲む: 各パラメータを個別の文字列として保持
echo "--- \"\$@\" ---"
for arg in "$@"; do
  echo "  arg: '$arg'"
done
# 出力:
#   arg: 'error report.log'
#   arg: 'access log.txt'
#   arg: 'debug.log'
# → 3つの引数がそれぞれ保持される（スペースを含んでいても）
```

`"$@"`はダブルクォートの規則における唯一の例外だ。通常、ダブルクォートで囲まれた文字列は1つのワードとして扱われる。だが`"$@"`だけは、各位置パラメータを個別のワードとして展開する。`"$1" "$2" "$3"`と書いたのと同じ効果を得られる。

なぜこの例外が必要なのか。配列変数がないからだ。複数の値を「リスト」として安全に保持し、他のコマンドに渡す手段が、`"$@"`以外に存在しなかった。`"$@"`は、Bourne shellの配列不在という設計的制約に対する、唯一にして最も重要な救済措置だ。

未クォートの`$@`と`$*`は、どちらもワード分割の対象になる。スペースを含むパラメータが分裂する。これが意図した挙動である場面はほぼない。

```
"$@" vs $* vs "$*" の挙動比較:

  位置パラメータ: "error report.log" "access log.txt"
  IFS=<space><tab><newline>（デフォルト）

  記法      展開結果                                    引数数
  ─────────────────────────────────────────────────────────
  "$@"      "error report.log" "access log.txt"        2
  "$*"      "error report.log access log.txt"           1
  $@        "error" "report.log" "access" "log.txt"    4
  $*        "error" "report.log" "access" "log.txt"    4
```

この表が示す通り、スペースを含む引数を安全に扱えるのは`"$@"`だけだ。他のすべての形式は、ワード分割によって引数が分裂する。

### ShellCheck――静的解析がもたらした革命

クォーティング地獄との戦いにおいて、2012年は転換点だった。

Vidar Holenが開発したShellCheckは、シェルスクリプトの静的解析ツールだ。このツールの起源は興味深い。ShellCheckは2012年、FreenodeのIRCチャンネル `#bash` に常駐するボットとして生まれた。チャンネルに貼り付けられたシェルスクリプトの断片を解析し、問題を指摘する。初期バージョンにはエラーコードすらなく、平文の英語メッセージでフィードバックを返すだけだった。

HolenはHaskellでShellCheckを実装した。理由は「最も楽しく興味深い言語だったから」だという。ShellCheckは彼にとって最初の本格的なHaskellプロジェクトだった。その後、ShellCheckはGitHubに公開され、MITのSIPB（Student Information Processing Board）が公開した "Writing Safe Shell Scripts" ガイドで言及されたことを契機に知名度が急上昇した。GitHubで最もスターの多いHaskellプロジェクトとなった。

ShellCheckが検出する警告の中で、最も頻出するものの一つがSC2086だ。

```
SC2086: Double quote to prevent globbing and word splitting.
（ダブルクォートを使ってグロビングとワード分割を防いでください。）
```

この警告は、未クォートの変数展開を検出する。たとえば`cat $filename`と書けば、ShellCheckはSC2086を報告し、`cat "$filename"`と修正することを提案する。

SC2086と並んで重要な警告がSC2046だ。

```
SC2046: Quote this to prevent word splitting.
（ワード分割を防ぐためにクォートしてください。）
```

SC2046は、未クォートのコマンド置換を検出する。`$(cmd)`の結果もワード分割の対象であり、`"$(cmd)"`とダブルクォートで囲む必要がある。

さらにSC2048は、`$@`や`$*`の誤用を検出する。

```
SC2048: Use "$@" (with quotes) to prevent whitespace problems.
（空白の問題を防ぐために、"$@"（クォート付き）を使ってください。）
```

ShellCheckの登場以前、クォーティングの知識は経験的に――つまり、本番環境でスクリプトが壊れることで――習得するしかなかった。ShellCheckは、その痛みを伴う学習プロセスを、コードを書いた時点でのフィードバックに変えた。これは、シェルスクリプティングにおける静的解析の革命だった。

---

## 4. ハンズオン――意図的にクォーティングの罠を踏む

理論を理解したら、実際に手を動かして罠を踏んでみよう。クォーティング地獄を「知識」から「体験」に変えることが、この演習の目的だ。

### 環境構築

Docker環境を前提とする。ShellCheckもインストールする。

```bash
docker run -it ubuntu:24.04 bash
# コンテナ内で:
apt-get update && apt-get install -y shellcheck
```

あるいは、本記事に付属する`setup.sh`スクリプトを使えば、演習環境の構築を一括で行える。

```bash
bash setup.sh
```

### 演習1：ワード分割の基本メカニズム

まず、ワード分割がどのように発生し、ダブルクォートがどのように抑制するかを確認する。

```sh
# --- ワード分割の基本 ---

WORK="/tmp/quoting-demo"
mkdir -p "$WORK"

# スペースを含むファイル名を作成
echo "content A" > "$WORK/error report.log"
echo "content B" > "$WORK/access_log.txt"
echo "content C" > "$WORK/system status.log"

# 確認
echo "--- 作成したファイル ---"
ls -la "$WORK/"

echo ""
echo "--- 未クォートの変数展開 ---"
TARGET="$WORK/error report.log"
echo "変数の値: $TARGET"
echo ""

echo "cat \$TARGET (クォートなし):"
cat $TARGET 2>&1 || true
echo ""

echo "cat \"\$TARGET\" (クォートあり):"
cat "$TARGET"
```

未クォートの`$TARGET`は、スペースの位置でワード分割され、2つの別々の引数になる。ダブルクォートで囲めば、1つの引数として保持される。

### 演習2：グロビングとワード分割の複合

ワード分割だけでなく、グロビングも同時に作用する例を確認する。

```sh
# --- グロビングとワード分割の複合 ---

cd "$WORK"

echo "--- グロビングの罠 ---"
pattern="*.log"

echo "未クォート: echo \$pattern"
echo $pattern
echo ""

echo "クォートあり: echo \"\$pattern\""
echo "$pattern"
echo ""

echo "--- さらに危険な例 ---"
message="Warning: found * files"

echo "未クォート: echo \$message"
echo $message
echo ""

echo "クォートあり: echo \"\$message\""
echo "$message"
```

未クォートの`$pattern`では、`*.log`がカレントディレクトリのファイル名に展開される。`$message`に含まれる`*`も同様にグロビングの対象になる。ダブルクォートがこの両方を防ぐ。

### 演習3："$@" vs "$\*" の決定的な差

配列不在のBourne shellで、引数を安全に扱う唯一の方法を体験する。

```sh
# --- "$@" vs "$*" ---

# テスト用の関数
show_args() {
  echo "引数の数: $#"
  local i=1
  for arg in "$@"; do
    echo "  [$i]: '$arg'"
    i=$((i + 1))
  done
}

echo "--- 位置パラメータの設定 ---"
set -- "error report.log" "access log.txt" "debug.log"
echo "set -- で3つの引数を設定（うち2つはスペースを含む）"
echo ""

echo '--- for arg in "$@" ---'
for arg in "$@"; do
  echo "  arg: '$arg'"
done
echo ""

echo '--- for arg in "$*" ---'
for arg in "$*"; do
  echo "  arg: '$arg'"
done
echo ""

echo '--- for arg in $@ (クォートなし) ---'
for arg in $@; do
  echo "  arg: '$arg'"
done
echo ""

echo '"$@" だけが、スペースを含む引数を正しく保持する。'
echo '$@ (クォートなし) では、ワード分割によって引数が分裂する。'
echo '"$*" では、すべてが1つの文字列に結合される。'
```

### 演習4：IFSの操作

IFSを変更すると、ワード分割の挙動が根本から変わることを確認する。

```sh
# --- IFSの操作 ---

echo "--- デフォルトIFSでのワード分割 ---"
data="apple:banana:cherry"
for item in $data; do
  echo "  item: '$item'"
done
echo "→ デフォルトIFS（スペース/タブ/改行）ではコロンで分割されない"
echo ""

echo "--- IFSをコロンに変更 ---"
OLD_IFS="$IFS"
IFS=":"
for item in $data; do
  echo "  item: '$item'"
done
IFS="$OLD_IFS"
echo "→ IFS=':' にすると、コロンでワード分割される"
echo ""

echo "--- IFSの変更は副作用がある ---"
PATH_DEMO="/usr/bin:/usr/local/bin:/home/user/bin"
IFS=":"
echo "PATH の各コンポーネント:"
for dir in $PATH_DEMO; do
  echo "  $dir"
done
IFS="$OLD_IFS"
echo ""
echo "IFSの変更はグローバルに作用するため、"
echo "変更前の値を保存し、使用後に復元すること。"
```

### 演習5：ShellCheckによる静的解析

実際にShellCheckを使って、クォーティング問題を検出してみよう。

```sh
# --- ShellCheckによる静的解析 ---

# 意図的に問題のあるスクリプトを作成
cat > "$WORK/buggy.sh" << 'SCRIPT'
#!/bin/sh
# 意図的にクォーティングの問題を含むスクリプト

# SC2086: 未クォートの変数展開
filename="error report.log"
cat $filename

# SC2046: 未クォートのコマンド置換
current_dir=$(pwd)
cd $current_dir

# SC2048: "$@" の代わりに $@ を使用
for arg in $@; do
  echo "$arg"
done

# SC2086: 条件式での未クォート変数
name="hello world"
if [ $name = "hello world" ]; then
  echo "match"
fi
SCRIPT

echo "--- 問題のあるスクリプト ---"
cat "$WORK/buggy.sh"
echo ""

echo "--- ShellCheck の結果 ---"
shellcheck "$WORK/buggy.sh" || true
echo ""

# 修正版を作成
cat > "$WORK/fixed.sh" << 'SCRIPT'
#!/bin/sh
# クォーティングを修正したスクリプト

# 修正: ダブルクォートで変数を囲む
filename="error report.log"
cat "$filename"

# 修正: コマンド置換もダブルクォートで囲む
current_dir=$(pwd)
cd "$current_dir"

# 修正: "$@" を使う
for arg in "$@"; do
  echo "$arg"
done

# 修正: 条件式でもダブルクォートを使う
name="hello world"
if [ "$name" = "hello world" ]; then
  echo "match"
fi
SCRIPT

echo "--- 修正後のスクリプト ---"
cat "$WORK/fixed.sh"
echo ""

echo "--- ShellCheck の結果（修正後） ---"
shellcheck "$WORK/fixed.sh" || true
```

ShellCheckが検出する警告を確認し、修正前後の違いを理解してほしい。SC2086（未クォートの変数展開）、SC2046（未クォートのコマンド置換）、SC2048（`$@`のクォーティング）――これらの警告が、クォーティング地獄の地図となる。

### 演習6：実践的な安全パターン

最後に、クォーティング地獄を回避するための実践的なパターンをまとめる。

```sh
# --- 安全なシェルスクリプティングの基本パターン ---

echo "=== 安全なパターン集 ==="
echo ""

echo "--- パターン1: 変数展開は常にダブルクォート ---"
file="$WORK/error report.log"
echo "安全: cat \"\$file\""
cat "$file"
echo ""

echo "--- パターン2: コマンド置換もダブルクォート ---"
echo "安全: dir=\"\$(pwd)\""
dir="$(pwd)"
echo "現在のディレクトリ: $dir"
echo ""

echo "--- パターン3: findの結果を安全に処理 ---"
echo "危険: for f in \$(find ...)"
echo "安全: find ... -exec / find ... -print0 | xargs -0"
echo ""
echo "find -exec の例:"
find "$WORK" -name "*.log" -exec echo "  found: {}" \;
echo ""

echo "--- パターン4: 引数の受け渡しは \"\$@\" ---"
echo "安全: func \"\$@\""
echo ""

echo "--- パターン5: 条件式でもダブルクォート ---"
value=""
echo "危険: [ \$value = \"\" ]  → 変数が空だとエラー"
echo "安全: [ \"\$value\" = \"\" ]"
if [ "$value" = "" ]; then
  echo "  空文字列を安全に判定できた"
fi
echo ""

echo "=== 原則: 迷ったらダブルクォート ==="
echo "未クォートの変数展開が安全なのは、"
echo "ワード分割やグロビングを意図的に利用する場合のみ。"
echo "それ以外は、常にダブルクォートで囲むこと。"
```

---

## 5. まとめと次回予告

### この回の要点

第一に、シェルの処理パイプラインは5段階で構成される。トークン化→展開（変数展開・コマンド置換・算術展開）→ワード分割→パス名展開（グロビング）→クォート除去。この処理順序を理解していなければ、シェルスクリプトのバグの根因を特定することは不可能だ。

第二に、ワード分割は「バグ」ではなく「設計」であり、しかもPOSIXによって「標準化された設計」だ。1979年のBourne shellにおける設計判断は、当時のUNIXのファイル名慣習（スペースを使わない前提）と整合していた。だがその前提は崩れ、設計だけが残った。

第三に、ダブルクォートはワード分割とグロビングの両方を抑制する。未クォートの変数展開は常にワード分割とグロビングの対象になる。シェルスクリプトにおける原則は「迷ったらダブルクォート」だ。

第四に、`"$@"`はダブルクォート規則の唯一の例外であり、各位置パラメータを個別のワードとして展開する。Bourne shellに配列変数が存在しなかったため、`"$@"`が複数の値を安全にリストとして扱う唯一の手段だった。

第五に、ShellCheck（Vidar Holen, 2012年〜）は、IRCボットから始まったシェルスクリプト静的解析ツールであり、SC2086（未クォートの変数展開）をはじめとする警告により、クォーティング問題をコードを書いた時点で検出することを可能にした。

### 冒頭の問いへの暫定回答

「なぜシェルスクリプトはこんなにも壊れやすいのか。それは『バグ』なのか『設計』なのか」――この問いに対する暫定的な答えはこうだ。

それは設計だ。シェルの処理パイプラインにおけるワード分割とグロビングは、1979年の技術的文脈では合理的な設計だった。だがその設計は、47年後の今日では「鋭い縁」となっている。David A. Wheelerが指摘したように、シェルにおいてファイル名を安全に扱うための「わかりやすく簡単な方法」は正しい方法ではなく、正しい方法は追加の記述（ダブルクォート）を要求する。

シェルスクリプトが壊れやすいのは、プログラマの怠慢だけが原因ではない。言語設計が、壊れやすいコードを書くことを容易にしている。「安全なデフォルト（safe by default）」の反対——「危険なデフォルト（dangerous by default）」——がシェルの現実だ。

だからこそ、この設計を理解しなければならない。地雷原を歩くなら、地図を持て。ダブルクォートがその地図だ。

### 次回予告

次回は、Bourne shellの言語設計のもう一つの核心——パイプとUNIX哲学——を扱う。

`ps aux | grep nginx | grep -v grep | awk '{print $2}' | xargs kill`――かつて私はこのようなパイプラインを得意げに書いていた。テキスト行を次々と加工していく「パイプ芸」は、UNIX哲学の真髄だった。だがJSON、YAML、Protocol Buffersの時代に、テキスト行指向のパイプラインは限界を見せ始めている。

Doug McIlroyが1964年にパイプを提案し、Ken Thompsonが1973年に実装した「小さなプログラムをパイプでつなぐ」思想。その天才性と限界を、次回は正面から語る。

---

## 参考文献

- S.R. Bourne, "The UNIX Shell", Bell System Technical Journal, Vol. 57, No. 6, Part 2, pp.1971-1990, July-August 1978 <https://archive.org/details/bstj57-6-1971>
- IEEE Standard 1003.2-1992, "Shell and Utilities" <https://standards.ieee.org/standard/1003_2-1992.html>
- POSIX Shell Command Language Rationale <https://pubs.opengroup.org/onlinepubs/9699919799/xrat/V4_xcu_chap02.html>
- David A. Wheeler, "Fixing Unix/Linux/POSIX Filenames" <https://dwheeler.com/essays/fixing-unix-linux-filenames.html>
- David A. Wheeler, "Filenames and Pathnames in Shell: How to do it Correctly" <https://dwheeler.com/essays/filenames-in-shell.html>
- Greg's Wiki, "WordSplitting" <https://mywiki.wooledge.org/WordSplitting>
- Greg's Wiki, "IFS" <https://mywiki.wooledge.org/IFS>
- Greg's Wiki, "Quotes" <https://mywiki.wooledge.org/Quotes>
- Wikipedia, "Glob (programming)" <https://en.wikipedia.org/wiki/Glob_(programming)>
- Wikipedia, "Internal field separator" <https://en.wikipedia.org/wiki/Internal_field_separator>
- Vidar Holen, "Lessons learned from writing ShellCheck" <https://www.vidarholen.net/contents/blog/?p=859>
- ShellCheck Wiki, SC2086 <https://www.shellcheck.net/wiki/SC2086>
- ShellCheck Wiki, SC2046 <https://www.shellcheck.net/wiki/SC2046>
- ShellCheck Wiki, SC2048 <https://www.shellcheck.net/wiki/SC2048>
