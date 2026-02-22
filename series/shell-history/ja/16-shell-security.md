# 第16回：シェルとセキュリティ――インジェクション、eval、権限昇格

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- Shellshock（CVE-2014-6271）の技術的メカニズム――環境変数に格納された関数定義の解析バグが25年間潜伏していた事実
- シェルインジェクションの仕組み――変数展開、コマンド置換、メタ文字がなぜ攻撃経路になるのか
- `eval`が「最も危険なビルトイン」と呼ばれる理由――二重解析がもたらすインジェクションリスク
- setuidシェルスクリプトの歴史的脆弱性――UNIX初期から知られていたレースコンディション問題
- CGIスクリプト時代のシェルインジェクション――Web黎明期の教訓
- 安全なシェルスクリプティングの原則――クォーティング、`--`オプション終端、ShellCheckによる静的解析
- シェルの柔軟性とセキュリティの脆弱性が表裏一体であるという構造的事実

---

## 1. 導入――「自分のスクリプトは大丈夫か」

2014年9月24日の朝、ニュースを見て手が止まった。

「Shellshock」――bashに致命的な脆弱性が発見された。CVSS（共通脆弱性評価システム）のベーススコアは10.0。最高値だ。影響を受けるのはbash 1.03から4.3まで。つまり、1989年から2014年までの25年間にリリースされた、事実上すべてのbashが対象だった。

私はそのとき、複数のサーバで運用しているbashスクリプト群のことを真っ先に考えた。デプロイスクリプト、ログ収集スクリプト、監視スクリプト。外部入力を受け取ってコマンドに渡している箇所はないか。環境変数を介して悪意あるコードが注入される経路はないか。

正直に言えば、そのときの私は、自分のスクリプトのセキュリティに自信を持てなかった。

クォーティングには気を遣っていた。`"$variable"`とダブルクォートで囲むことは習慣になっていた。だが、それはワード分割の防止が主な動機であって、セキュリティを意識してのことではなかった。外部入力のサニタイズについて体系的に考えたことがあったかと問われれば、答えは「なかった」だ。

Shellshockは、私に一つの事実を突きつけた。シェルの柔軟性――変数展開、コマンド置換、関数エクスポート、eval――これらの機能は、すべて攻撃者にとっての「入口」にもなり得る。シェルが便利であればあるほど、攻撃面（attack surface）は広がる。これは設計上のトレードオフであり、個々のスクリプトのバグではなく、シェルというパラダイムに内在する構造的な問題だ。

あなたが書いたシェルスクリプトは、セキュリティの観点から検証されたことがあるだろうか。外部から渡される値を無検証のままコマンドに渡していないだろうか。`eval`を使っていないだろうか。そもそも、シェルスクリプトのセキュリティリスクをどこまで理解しているだろうか。

---

## 2. 歴史的背景――シェルとセキュリティの50年

### setuidスクリプト――UNIX初期からの既知リスク

シェルスクリプトのセキュリティ問題は、Shellshockよりはるかに前から知られていた。その最も古い事例の一つが、setuidシェルスクリプトだ。

UNIXにはsetuid（Set User ID）という機構がある。実行ファイルにsetuidビットを設定すると、そのファイルを実行したとき、実行者の権限ではなくファイル所有者の権限で動作する。たとえばroot所有のsetuidプログラムは、一般ユーザーが実行してもroot権限で動く。`passwd`コマンドがパスワードファイルを書き換えられるのは、この仕組みによる。

だが、setuidをシェルスクリプトに適用すると、深刻なセキュリティホールが生じる。問題は複数ある。

第一に、TOCTOU（Time of Check, Time of Use）レースコンディション。カーネルがスクリプトファイルのsetuidビットを検査する時点と、インタプリタ（`/bin/sh`）がそのファイルを実際に開いて読み込む時点の間に、タイムギャップが存在する。攻撃者はこのギャップの間にシンボリックリンクを差し替えて、別のスクリプトを実行させることができる。

第二に、IFS（Internal Field Separator）変数の操作。Bourne系シェルでは、IFS変数がコマンドラインの分割方法を決定する。攻撃者がsetuidスクリプトの実行前にIFSを操作すれば、スクリプト内のコマンド呼び出しを乗っ取ることができる。たとえばIFSに`/`を設定すると、`/bin/sh`というパスが`bin`と`sh`に分割されてしまう。

第三に、シンボリックリンクの悪用。`#!/bin/sh`で始まるsetuidスクリプトに対して、`-i`という名前のシンボリックリンクを作成すると、カーネルは`/bin/sh -i`として起動する。`-i`はインタラクティブモードのフラグだ。結果として、root権限の対話的シェルが手に入る。

これらの問題はUNIXコミュニティで早くから認識されていた。BSD系UNIXは早い段階でsetuidシェルスクリプトを無効化した。カーネルがスクリプトのsetuidビットを単純に無視するのだ。Linuxカーネルも同様の措置を取っている。一方、System V系UNIXは当初setuidスクリプトを許可していたが、これは後に脆弱性の温床となった。

setuidスクリプトの問題は、シェルスクリプトのセキュリティにおける最初の教訓を示している。シェルは「信頼できる入力を処理するための道具」として設計されており、「信頼できない入力を安全に処理する」ことは設計目標に含まれていなかった。

### CGI時代――Webがシェルを危険にさらした

1990年代半ば、World Wide Webの急速な普及がシェルスクリプトに新たなリスクをもたらした。CGI（Common Gateway Interface）である。

CGIは、Webサーバが外部プログラムを呼び出して動的にHTMLを生成する仕組みだ。そしてCGIスクリプトの多くは、シェルスクリプトやPerlスクリプトで書かれていた。問題は、CGIスクリプトがHTTPリクエストのパラメータ――URLのクエリ文字列やフォームの入力値――を環境変数やコマンドライン引数として受け取ることだった。

典型的な脆弱コードはこうだ。

```bash
#!/bin/sh
# 危険なCGIスクリプトの例（絶対に真似しないこと）
echo "Content-Type: text/html"
echo ""
echo "<html><body>"
echo "<h1>検索結果</h1>"
# ユーザーの入力をそのままgrepに渡している
grep "$QUERY_STRING" /var/data/catalog.txt
echo "</body></html>"
```

`QUERY_STRING`にはユーザーが自由にテキストを入力できる。攻撃者が`; cat /etc/passwd`と入力すれば、grepの後に`cat /etc/passwd`が実行される。セミコロンがシェルのコマンド区切り文字として解釈されるからだ。

W3CのWWW Security FAQは1990年代からCGIスクリプトの危険性を警告していた。「ユーザーが正当に入力できる文字を特定し、それ以外のすべてを除去またはエスケープせよ」という原則が示されていた。だが、Web黎明期の開発者の多くは、経験の浅いプログラマだった。UC Davisのセキュリティ研究室の報告は、CGIスクリプトが「経験の浅い開発者によって書かれ、ネットワーク経由でデフォルトで外部に公開される」ため、システムの脆弱性の主要な源泉だと指摘していた。

シェルインジェクションは、CGI時代に「理論的な問題」から「現実の脅威」へと変わった。インターネットに接続されたWebサーバ上で、任意のユーザーがシェルにコマンドを注入できる。これは、ローカル環境でのsetuidスクリプトの悪用とは次元が異なるリスクだった。

### Shellshock――25年間眠っていた時限爆弾

2014年9月12日、Stephane Chazelasはbashのメンテナであるchet Rameyに一通のメールを送った。Chazelasは英国のロボティクス企業SeeByte社のUnix/Linuxネットワーク管理者で、彼はこのバグを「Bashdoor」と呼んだ。

Chazelasが発見した問題は、bashの「関数エクスポート」機能に潜んでいた。

bashには、シェル関数を環境変数を介して子プロセスにエクスポートする機能がある。親プロセスで定義した関数を、子プロセスのbashでも利用可能にする仕組みだ。この機能を実現するために、bashは環境変数の値を走査し、`() {`で始まる値を見つけると、それを関数定義として解釈して評価する。

問題は、この評価が関数定義の終了で止まらなかったことだ。関数定義の後に続くコマンドも実行してしまう。

```bash
# Shellshockの検証（パッチ適用済み環境では「vulnerable」は表示されない）
env x='() { :;}; echo vulnerable' bash -c "echo this is a test"
```

この一行が意味することを分解する。環境変数`x`に`() { :;}; echo vulnerable`という値を設定する。新しいbashプロセスが起動すると、環境変数を走査し、`x`の値が`() {`で始まることを検出する。bashはこれを関数定義として解析し始める。`() { :;}`――これは何もしない関数だ。だが、セミコロンの後に`echo vulnerable`が続いている。脆弱なbashはこのコマンドも実行してしまう。

この機能は、Brian Foxが1989年8月5日にbashに追加したものだった。bash 1.03（1989年9月1日リリース）に含まれた。つまり、この脆弱性は25年間にわたりbashのソースコードに潜伏していた。

2014年9月24日、パッチとともにCVE-2014-6271として公表された。CVSS v2のベーススコアは10.0――最高値だ。影響範囲はbash 1.14から4.3まで。事実上、世界中のLinuxサーバ、macOSマシン、組み込みデバイスのbashが影響を受けた。

公表直後から、Shellshockは活発に悪用された。最も深刻な攻撃ベクトルはCGIスクリプトを介したものだった。Apache HTTPサーバはCGIスクリプトを実行する際、HTTPリクエストのヘッダ情報を環境変数として渡す。`User-Agent`ヘッダは`HTTP_USER_AGENT`環境変数に、`Referer`ヘッダは`HTTP_REFERER`環境変数になる。攻撃者は、HTTPリクエストのUser-Agentヘッダに悪意ある関数定義を埋め込むだけで、サーバ上で任意のコマンドを実行できた。

```
# Shellshock攻撃のHTTPリクエスト例（CGIベクトル）
GET /cgi-bin/vulnerable.cgi HTTP/1.1
Host: target.example.com
User-Agent: () { :;}; /bin/cat /etc/passwd
```

CGI以外にも攻撃ベクトルは存在した。DHCPクライアントがDHCPサーバからの応答を環境変数経由で処理する場合、悪意あるDHCPサーバが攻撃コードを送り込める。OpenSSHの`ForceCommand`機能を使用している場合、認証済みユーザーが制限されたコマンドを回避して任意のコマンドを実行できる。

Shellshockは単一の脆弱性ではなかった。最初のパッチ（CVE-2014-6271対応）は不完全で、Tavis Ormandyがバイパスを発見し、CVE-2014-7169として報告された。その後も関連する脆弱性が次々と報告され、最終的にCVE-2014-6277、CVE-2014-6278、CVE-2014-7186、CVE-2014-7187を含む6つのCVEからなる脆弱性ファミリとなった。

パッチ適用後、bashは環境変数から関数をインポートする際、変数名が`BASH_FUNC_`で始まり`()`で終わる場合のみ関数定義として解釈するように変更された。Michal Zalewskiが提案したプレフィックスとEric Blakeが提案したサフィックスを組み合わせた方式だ。

### Shellshockが問いかけたもの

Shellshockが技術的に興味深いのは、これが「実装のバグ」であると同時に「設計の問題」でもあった点だ。

関数エクスポート機能それ自体は、便利で合理的な機能だ。親シェルで定義した関数を子プロセスでも使えるようにする。だが、この機能を実現するために、bashは環境変数の値をコードとして評価するという設計判断を行った。環境変数はプロセス間でデータを共有するための仕組みであり、任意のコードを共有するための仕組みではない。データをコードとして評価する――これは、あらゆるインジェクション攻撃の根幹にあるパターンだ。SQLインジェクション、XSS（クロスサイトスクリプティング）、そしてシェルインジェクション。データとコードの境界が曖昧になるところに、脆弱性が生まれる。

bashの関数エクスポートは、まさにこの境界を曖昧にした。そして25年間、誰もその危険性に気づかなかった。

---

## 3. 技術論――シェルインジェクションの解剖学

### シェルの処理パイプラインと攻撃面

シェルインジェクションを理解するには、シェルがコマンドラインをどのように処理するかを知る必要がある。第5回で詳述したシェルの処理パイプラインを、セキュリティの観点から再訪する。

```
シェルの処理パイプライン（セキュリティ視点）:

  入力文字列
      |
  [1] トークン化（Tokenization）
      |  ← メタ文字（;, |, &, &&, ||）がコマンドを分割
      |     攻撃: セミコロンやパイプの注入
      |
  [2] 変数展開（Parameter Expansion）
      |  ← $variable の値が展開される
      |     攻撃: 変数の値にメタ文字を含める
      |
  [3] コマンド置換（Command Substitution）
      |  ← $(command) や `command` が実行される
      |     攻撃: コマンド置換の中に悪意あるコマンドを埋め込む
      |
  [4] ワード分割（Word Splitting）
      |  ← IFSに基づいて文字列を分割
      |     攻撃: IFS操作、スペースを含む値による意図しない分割
      |
  [5] グロビング（Pathname Expansion）
      |  ← *, ?, [...] がファイル名に展開される
      |     攻撃: グロブパターンによる意図しないファイル参照
      |
  [6] クォート除去（Quote Removal）
      |
  コマンド実行
```

この処理パイプラインのあらゆる段階で、攻撃者は悪意あるデータを注入する余地がある。最も一般的な攻撃パターンを見ていく。

### パターン1: メタ文字注入

シェルのメタ文字――セミコロン（`;`）、パイプ（`|`）、アンパサンド（`&`）、バッククォート（`` ` ``）、ドル記号と括弧（`$()`）――をデータに混入させ、意図しないコマンドを実行させる。

```bash
# 危険なスクリプト
#!/bin/sh
echo "ファイルを検索します: $1"
find /data -name "$1" -print

# 安全な入力
# ./search.sh "report.txt"
# → find /data -name "report.txt" -print

# 悪意ある入力（$1がクォートされていない場合）
# ./search.sh "report.txt; rm -rf /"
# → find /data -name report.txt; rm -rf / -print
```

この例では、`$1`がダブルクォートで囲まれているため、メタ文字注入は防がれる。だが、クォートがなければ（`find /data -name $1 -print`）、セミコロンがコマンド区切りとして解釈され、`rm -rf /`が実行される。

第5回で学んだクォーティングの重要性は、セキュリティの文脈ではさらに切実なものになる。

### パターン2: コマンド置換の悪用

```bash
# 危険なスクリプト
#!/bin/sh
filename="$1"
# ファイルの行数を表示する意図
echo "行数: $(wc -l < "$filename")"
```

このスクリプトは一見安全に見える。`$1`はダブルクォートで囲まれている。だが、ファイル名自体にシェルメタ文字が含まれている場合はどうだろうか。ファイル名に`$(malicious_command)`のような文字列が含まれていたとしても、ダブルクォート内であればコマンド置換は起きない――`$filename`の展開時に、その値はリテラル文字列として扱われるからだ。

問題が生じるのは、この値がクォートされずに別のコマンドに渡される場合だ。

```bash
# 危険: evalを使って動的にコマンドを構築
#!/bin/sh
cmd="wc -l $1"
eval "$cmd"
# $1 が "file.txt; cat /etc/passwd" なら
# eval "wc -l file.txt; cat /etc/passwd" が実行される
```

### パターン3: `eval`――最も危険なビルトイン

`eval`は、シェルスクリプトにおいて最も危険なビルトインコマンドだ。

`eval`は受け取った引数を連結し、その結果をシェルコマンドとして再評価する。この「再評価」が問題の核心だ。シェルは通常、コマンドラインを一度だけ解析する。だが`eval`は、その結果をもう一度シェルの処理パイプラインに通す。二重解析（double parsing）だ。

```bash
# evalの二重解析の例
var='hello; echo INJECTED'
eval echo "$var"
# 第1回の解析: eval echo "hello; echo INJECTED"
# 第2回の解析: echo hello; echo INJECTED
# 結果: "hello" と "INJECTED" の2行が出力される
```

`eval`がなぜ危険かを、より実践的な例で示す。

```bash
# 危険: ユーザー入力をevalで処理
#!/bin/sh
# 設定ファイルの読み込みを意図したコード
while IFS='=' read -r key value; do
    eval "$key='$value'"
done < config.txt

# config.txt の内容が以下の場合:
# name=John
# email=john@example.com
# → 問題なし

# config.txt の内容が以下の場合:
# name='; rm -rf / #
# → eval "name=''; rm -rf / #'" が実行される
```

`eval`の代替手段は存在する。bashの連想配列、`declare`コマンド、または配列によるコマンド構築が推奨される。

```bash
# 安全: 配列によるコマンド構築
cmd=(wc -l "$filename")
"${cmd[@]}"

# 安全: declare によるキーバリュー処理
while IFS='=' read -r key value; do
    # 入力のバリデーション
    case "$key" in
        [a-zA-Z_][a-zA-Z_0-9]*)
            declare "$key=$value"
            ;;
        *)
            echo "不正なキー: $key" >&2
            ;;
    esac
done < config.txt
```

Greg's Wiki（wooledge.org）のBashFAQ #48は、`eval`を避けるべき理由と代替手段を詳細に解説している。シェルスクリプトを書く者なら一度は読むべき文書だ。

### パターン4: オプション注入

メタ文字の注入だけが攻撃手法ではない。コマンドのオプション（フラグ）を注入する攻撃もある。

```bash
# 危険なスクリプト
#!/bin/sh
# ユーザーが指定したファイルを表示する
cat "$1"

# 攻撃: $1 に "--help" や "-" を渡す
# ./show.sh --help → catのヘルプが表示される（意図しない情報漏洩）
# ./show.sh - → 標準入力から読み取る（ハングアップ）
```

より深刻な例もある。

```bash
# 危険なスクリプト
#!/bin/sh
# ユーザーが指定したファイルを削除する
rm "$1"

# 攻撃: $1 に "-rf /" を渡す
# rm -rf / が実行される可能性がある
```

この攻撃を防ぐのが`--`（ダブルダッシュ）だ。POSIX Utility Syntax Guidelinesのガイドライン10は、最初の`--`引数をオプション終端として扱い、以降の引数はすべてオペランドとして処理すると規定している。

```bash
# 安全: -- でオプション終端を明示
rm -- "$1"
cat -- "$1"
grep -- "$pattern" "$filename"
```

`--`の後に`-rf`が来ても、それはオプションではなくファイル名として扱われる。単純だが効果的な防御策だ。

### 安全なシェルスクリプティングの原則

これまでの議論を整理し、安全なシェルスクリプティングの原則をまとめる。

**原則1: 外部入力は必ずダブルクォートで囲む**

変数展開、コマンド置換の結果は、常にダブルクォートで囲む。例外はほぼない。

```bash
# 危険
grep $pattern $filename
# 安全
grep -- "$pattern" "$filename"
```

**原則2: `eval`を使わない**

`eval`が必要だと感じたら、まず設計を見直す。配列、`declare`、関数など、`eval`を使わない代替手段を検討する。

**原則3: `--`でオプション終端を明示する**

ユーザー入力をコマンドの引数として渡す場合、`--`を挿入してオプションインジェクションを防ぐ。

**原則4: 外部コマンドの呼び出しを最小化する**

外部入力を処理する場合、シェルのメタ文字解釈を経由しない方法を選ぶ。可能であれば、シェルスクリプトではなくPythonやGoなどの言語を使う。

**原則5: ShellCheckを使う**

2012年にVidar HolenがHaskellで開発したShellCheckは、シェルスクリプトの静的解析ツールとして事実上の標準だ。SC2086（未クォートの変数展開）、SC2046（未クォートのコマンド置換）など、セキュリティに直結する警告を提供する。

```bash
# ShellCheckが検出する典型的な問題
# SC2086: Double quote to prevent globbing and word splitting.
echo $unquoted_var

# SC2091: Remove surrounding $() to avoid executing output.
$(some_command)

# SC2046: Quote this to prevent word splitting.
rm $(find . -name "*.tmp")
```

**原則6: `set -euo pipefail`を先頭に置く**

```bash
#!/bin/bash
set -euo pipefail
# -e: コマンドが失敗したら即座にスクリプトを終了
# -u: 未定義の変数を参照したらエラー
# -o pipefail: パイプラインの途中のコマンドが失敗してもエラーを検出
```

この設定は、エラーが暗黙のうちに無視されてスクリプトが予期しない状態で進行するのを防ぐ。セキュリティの観点からは、エラーの無視が攻撃の成功を助けることがある。

### シェルの柔軟性とセキュリティのトレードオフ

ここで立ち止まって考えたい。なぜシェルはこれほどインジェクションに弱いのか。

答えは、シェルの設計思想に根ざしている。第4回で見たように、Bourne shellは「すべてはテキスト」という前提の上に構築された。変数の値はテキストであり、コマンドの引数もテキストであり、パイプで流れるデータもテキストだ。シェルは、このテキストを解釈して実行する。テキストの解釈が柔軟であればあるほど、シェルは便利になる。だが同時に、悪意あるテキストが注入されたときの被害も大きくなる。

SQLインジェクションとの対比が分かりやすい。SQLもまた、データとコードが同じテキストストリームの中に混在するため、インジェクションに弱い。この問題に対するSQLの回答は「プリペアドステートメント」だった。データとコードを構造的に分離する仕組みだ。

シェルには、プリペアドステートメントに相当する仕組みがない。ダブルクォートは防御策の一つだが、すべてのケースをカバーするわけではない。`eval`のように、意図的にデータをコードとして再評価する仕組みすら存在する。

この構造的な問題が、次世代シェルの設計動機の一つになっている。第21回で扱うNushellは構造化データのパイプラインを採用し、テキストの暗黙的な解釈を排除している。fishはPOSIX互換を捨てることで、シェル言語のより安全な設計を模索している。Oil/YSHは既存のシェルとの互換性を保ちつつ、より安全な言語機能を追加しようとしている。

シェルのセキュリティ問題は、個々のスクリプトの修正だけでは根本的に解決しない。シェルというパラダイムそのものが、データとコードの境界を曖昧にする設計の上に成り立っている。この事実を認識した上で、防御的にスクリプトを書くしかない。

---

## 4. ハンズオン――シェルインジェクションを体験し、防御する

ここからは、安全なDocker環境内でシェルインジェクションを実際に体験する。攻撃を理解することが、最も効果的な防御への第一歩だ。

### 環境構築

Docker環境を前提とする。

```bash
docker run -it ubuntu:24.04 /bin/bash
```

あるいは、本記事に付属する`setup.sh`スクリプトで一括構築できる。

```bash
bash setup.sh
```

### 演習1: シェルインジェクションの基本パターン

クォーティングの有無がセキュリティにどう影響するかを体験する。

```bash
echo "=== 演習1: シェルインジェクションの基本 ==="

# --- 脆弱なスクリプトの作成 ---
mkdir -p /tmp/security-lab
cat << 'VULN_SCRIPT' > /tmp/security-lab/vulnerable_grep.sh
#!/bin/sh
# 脆弱なスクリプト: 変数がクォートされていない
pattern=$1
echo "検索パターン: $pattern"
echo "--- 結果 ---"
grep -r $pattern /tmp/security-lab/data/ 2>/dev/null
VULN_SCRIPT
chmod +x /tmp/security-lab/vulnerable_grep.sh

cat << 'SAFE_SCRIPT' > /tmp/security-lab/safe_grep.sh
#!/bin/sh
# 安全なスクリプト: 変数がクォートされ、--でオプション終端
pattern="$1"
echo "検索パターン: $pattern"
echo "--- 結果 ---"
grep -r -- "$pattern" /tmp/security-lab/data/ 2>/dev/null
SAFE_SCRIPT
chmod +x /tmp/security-lab/safe_grep.sh

# テストデータの作成
mkdir -p /tmp/security-lab/data
echo "alice: engineer" > /tmp/security-lab/data/users.txt
echo "bob: designer" >> /tmp/security-lab/data/users.txt
echo "secret_token=abc123" > /tmp/security-lab/data/config.txt

echo ""
echo "--- 正常な入力 ---"
/tmp/security-lab/vulnerable_grep.sh "alice"

echo ""
echo "--- メタ文字注入の試行（脆弱版）---"
echo "入力: 'alice /tmp/security-lab/data/config.txt'"
echo "（スペースによるワード分割で意図しないファイルも検索される）"
/tmp/security-lab/vulnerable_grep.sh "alice /tmp/security-lab/data/config.txt"

echo ""
echo "--- 同じ入力を安全版で実行 ---"
/tmp/security-lab/safe_grep.sh "alice /tmp/security-lab/data/config.txt"
echo "（パターン全体が一つの文字列として扱われ、マッチしない）"
```

### 演習2: evalの危険性を体験する

```bash
echo "=== 演習2: evalの危険性 ==="

# --- evalを使った脆弱なスクリプト ---
cat << 'EVAL_VULN' > /tmp/security-lab/eval_vulnerable.sh
#!/bin/sh
# 危険: evalでユーザー入力を処理
echo "--- evalを使った設定読み込み（危険）---"
while IFS='=' read -r key value; do
    eval "$key='$value'"
    echo "  設定: $key = $(eval echo \"\$$key\")"
done << 'CONFIG'
name=John
email=john@example.com
CONFIG
echo "  結果: name=$name, email=$email"
EVAL_VULN
chmod +x /tmp/security-lab/eval_vulnerable.sh
sh /tmp/security-lab/eval_vulnerable.sh

echo ""
echo "--- 悪意ある設定ファイルでの挙動（デモンストレーション）---"
cat << 'EVAL_DEMO' > /tmp/security-lab/eval_demo.sh
#!/bin/sh
# evalが二重解析する様子を可視化する
input="hello'; echo 'INJECTED"
echo "入力値: $input"
echo ""
echo "evalなし（安全）:"
key="name"
# evalを使わない安全な方法
safe_value="$input"
echo "  name=$safe_value"
echo ""
echo "evalあり（危険 -- 実行はしないがコマンドを表示）:"
echo "  eval が実行するコマンド: $key='$input'"
echo "  → name='hello'; echo 'INJECTED' と解釈される"
echo "  → 2つのコマンドに分割: (1) name='hello'  (2) echo 'INJECTED'"
EVAL_DEMO
chmod +x /tmp/security-lab/eval_demo.sh
sh /tmp/security-lab/eval_demo.sh

echo ""
echo "--- 安全な代替: readとcaseによるバリデーション ---"
cat << 'SAFE_CONFIG' > /tmp/security-lab/safe_config.sh
#!/bin/sh
# 安全: evalを使わない設定読み込み
echo "--- 安全な設定読み込み ---"

# 設定値を個別の変数で管理
config_name=""
config_email=""

while IFS='=' read -r key value; do
    # キー名のバリデーション
    case "$key" in
        name)  config_name="$value" ;;
        email) config_email="$value" ;;
        *)     echo "  警告: 未知のキー '$key' を無視" >&2 ;;
    esac
    echo "  読み込み: $key = $value"
done << 'CONFIG'
name=John
email=john@example.com
unknown=malicious'; echo INJECTED #
CONFIG

echo ""
echo "  結果: name=$config_name"
echo "  結果: email=$config_email"
echo "  （未知のキーは安全に無視された）"
SAFE_CONFIG
chmod +x /tmp/security-lab/safe_config.sh
sh /tmp/security-lab/safe_config.sh
```

### 演習3: Shellshockの仕組みを理解する

```bash
echo "=== 演習3: Shellshockの仕組み（教育用）==="

echo "--- 現在のbashバージョン ---"
bash --version | head -1

echo ""
echo "--- Shellshock検証（パッチ適用済み環境）---"
echo "テストコマンド: env x='() { :;}; echo VULNERABLE' bash -c 'echo safe'"
result=$(env x='() { :;}; echo VULNERABLE' bash -c 'echo safe' 2>&1)
echo "結果: $result"

if echo "$result" | grep -q "VULNERABLE"; then
    echo "警告: この環境はShellshockに対して脆弱です！"
else
    echo "安全: Shellshockパッチが適用されています"
fi

echo ""
echo "--- bashの関数エクスポート機能（正常な使い方）---"
echo "親シェルで関数を定義してexportし、子プロセスで使用する:"

# 関数のエクスポート（bash固有機能）
my_greeting() { echo "Hello from exported function!"; }
export -f my_greeting
bash -c 'my_greeting'
unset -f my_greeting

echo ""
echo "--- 環境変数に格納された関数定義の形式 ---"
demo_func() { echo "demo"; }
export -f demo_func
env | grep "demo_func" || echo "(BASH_FUNC_demo_func%%として格納)"
echo "パッチ後: 関数は BASH_FUNC_funcname%% という環境変数名で格納される"
unset -f demo_func

echo ""
echo "--- Shellshockの攻撃パターン解説 ---"
echo ""
echo "パッチ前のbash（脆弱）:"
echo "  環境変数: x='() { :;}; malicious_command'"
echo "  bashの処理:"
echo "    1. 環境変数xの値が '() {' で始まることを検出"
echo "    2. 関数定義として解析: () { :; }"
echo "    3. 【バグ】関数定義の後のコマンドも実行: malicious_command"
echo ""
echo "パッチ後のbash（安全）:"
echo "  1. 変数名が BASH_FUNC_name%% 形式でなければ関数として解釈しない"
echo "  2. 関数定義の終了後にコマンドがあれば処理を中断する"
```

### 演習4: ShellCheckによるセキュリティ監査

```bash
echo "=== 演習4: ShellCheckによるセキュリティ監査 ==="

# ShellCheckのインストール
apt-get update -qq && apt-get install -y -qq shellcheck >/dev/null 2>&1

# セキュリティ問題を含むスクリプト
cat << 'INSECURE' > /tmp/security-lab/insecure.sh
#!/bin/bash
# 意図的にセキュリティ問題を含むスクリプト

# SC2086: 未クォートの変数展開
filename=$1
cat $filename

# SC2046: 未クォートのコマンド置換
rm $(find /tmp -name "*.tmp" -mtime +7)

# SC2091: $()の結果を直接実行
$(grep -l "pattern" /tmp/*.txt)

# evalの使用（ShellCheckは直接警告しないが危険）
eval "echo $1"

# SC2012: lsの出力をパースする（セキュリティリスク）
for f in $(ls /tmp/); do
    echo "$f"
done
INSECURE

echo "--- セキュリティ問題を含むスクリプト ---"
cat /tmp/security-lab/insecure.sh
echo ""
echo "--- ShellCheckの結果 ---"
shellcheck /tmp/security-lab/insecure.sh 2>&1 || true

echo ""
echo "--- 修正版スクリプト ---"
cat << 'SECURE' > /tmp/security-lab/secure.sh
#!/bin/bash
set -euo pipefail

# 修正: ダブルクォートで囲み、--でオプション終端
filename="${1:?ファイル名を指定してください}"
cat -- "$filename"

# 修正: findの結果を安全に処理（-exec または -print0 + xargs -0）
find /tmp -name "*.tmp" -mtime +7 -exec rm -- {} +

# 修正: grepの結果をループで安全に処理
while IFS= read -r -d '' match; do
    echo "マッチ: $match"
done < <(grep -rlZ "pattern" /tmp/*.txt 2>/dev/null)

# 修正: evalを排除し、直接echoを使用
echo "${1:-(未指定)}"

# 修正: グロブで直接ファイルを列挙
for f in /tmp/*; do
    [ -e "$f" ] || continue
    echo "${f##*/}"
done
SECURE

cat /tmp/security-lab/secure.sh
echo ""
echo "--- 修正版のShellCheck結果 ---"
shellcheck /tmp/security-lab/secure.sh 2>&1 || echo "ShellCheck: 問題なし"

# クリーンアップ
rm -rf /tmp/security-lab
```

---

## 5. まとめと次回予告

### この回の要点

第一に、シェルスクリプトのセキュリティ問題はUNIX初期から存在する。setuidシェルスクリプトのレースコンディション、IFS操作による攻撃、シンボリックリンクの悪用――これらはBSD系UNIXが早期にsetuidスクリプトを無効化した理由であり、「シェルは信頼できない入力を安全に処理するようには設計されていない」ことを示す初期の事例だった。

第二に、Shellshock（CVE-2014-6271）はbashの関数エクスポート機能に25年間潜伏していた脆弱性だった。2014年9月12日にStephane Chazelasが発見し、9月24日に公表された。CVSSスコア10.0。環境変数に格納された関数定義の末尾に付加されたコマンドを、bashが意図せず実行するバグだった。CGI、DHCP、OpenSSH ForceCommandなど複数の攻撃ベクトルが存在し、最終的に6つのCVEからなる脆弱性ファミリとなった。

第三に、シェルインジェクションの根本原因は「データとコードの境界の曖昧さ」にある。シェルはテキストを解釈して実行する。変数展開、コマンド置換、`eval`による再評価――これらの機能は利便性とリスクの表裏一体だ。SQLインジェクションにプリペアドステートメントがあるように、シェルにも構造的な分離機構が必要だが、現在のPOSIXシェルにはそれが存在しない。

第四に、`eval`はシェルスクリプトにおいて最も危険なビルトインだ。二重解析により、外部入力が含まれる場合に任意のコマンド実行を許してしまう。配列、`declare`、`case`文によるホワイトリスト方式など、`eval`を使わない代替手段を常に検討すべきだ。

第五に、安全なシェルスクリプティングには明確な原則がある。外部入力のダブルクォート、`eval`の回避、`--`によるオプション終端、ShellCheckによる静的解析、`set -euo pipefail`の使用。これらは完璧な防御ではないが、攻撃面を大幅に縮小する。

### 冒頭の問いへの暫定回答

「シェルスクリプトのセキュリティリスクを、あなたはどこまで理解しているか」――この問いに対する暫定的な答えはこうだ。

シェルのセキュリティリスクは、個々のスクリプトの書き方の問題ではなく、シェルというパラダイムの構造的特性だ。シェルは「データとコードが同じテキストストリームに混在する」設計の上に構築されている。この設計が柔軟性の源泉であると同時に、脆弱性の源泉でもある。

Shellshockは、この構造的問題の最も劇的な顕在化だった。環境変数というデータチャネルが、関数エクスポートというコード実行の経路として使われた。そして25年間、誰もその危険性に気づかなかった。

シェルスクリプトのセキュリティを確保するには、三つのレベルの理解が必要だ。

第一のレベルは「防御的コーディング」。クォーティング、`--`、`set -euo pipefail`、ShellCheck。これは最低限の衛生管理だ。

第二のレベルは「設計判断」。シェルスクリプトがセキュリティの観点から適切なツールかどうかを判断する能力。外部入力を処理する50行以上のスクリプトには、Pythonなどの言語を検討すべきかもしれない。

第三のレベルは「構造的理解」。シェルのテキスト処理パイプラインがなぜインジェクションに弱いのかを理解し、データとコードの分離という原則を、シェルに限らずあらゆるシステム設計に適用する能力。

シェルの柔軟性は捨てがたい。だが、その柔軟性のコストを理解しない者は、無自覚に脆弱なコードを書き続ける。

### 次回予告

今回、シェルのセキュリティという暗い側面を掘り下げた。bashの覇権がもたらした功罪を、第13回から第16回にわたって四つの角度――誕生と席巻、スクリプティング生態系、ライセンスによる退位、そしてセキュリティリスク――から語ってきた。

次回からは第6章「モダンシェルの挑戦者たち」に入る。

次回のテーマは「zsh――最大主義のシェルとOh My Zsh文化」だ。

1990年にPaul FalstadがPrinceton大学で生み出したzsh。「すべてのシェルの最良の部分を取り込む」という設計思想。そしてRobby Russellが2009年に始めたOh My Zshがzshの普及を爆発的に加速させた事実。だが、Oh My Zshの華やかさの裏で、zshの本質的な機能――高度なグロビング、zsh completion system、zle（Zsh Line Editor）のウィジェット機構――は見落とされていないだろうか。

「zshは『より良いbash』なのか、それとも根本的に異なるシェルなのか」――次回は、その問いに向き合う。

---

## 参考文献

- Wikipedia, "Shellshock (software bug)" <https://en.wikipedia.org/wiki/Shellshock_(software_bug)>
- NVD, "CVE-2014-6271" <https://nvd.nist.gov/vuln/detail/cve-2014-6271>
- CISA, "GNU Bourne-Again Shell (Bash) 'Shellshock' Vulnerability", 2014 <https://www.cisa.gov/news-events/alerts/2014/09/25/gnu-bourne-again-shell-bash-shellshock-vulnerability-cve-2014-6271>
- LWN.net, "Bash gets shellshocked", 2014 <https://lwn.net/Articles/614218/>
- David Wheeler, "Shellshock" <https://dwheeler.com/essays/shellshock.html>
- GNU bug-bash mailing list, "when was shellshock introduced", 2014 <https://lists.gnu.org/archive/html/bug-bash/2014-10/msg00149.html>
- David Wheeler, "Avoid Creating Setuid/Setgid Scripts" <https://dwheeler.com/secure-programs/Secure-Programs-HOWTO/avoid-setuid.html>
- Wikipedia, "Setuid" <https://en.wikipedia.org/wiki/Setuid>
- W3C, "WWW Security FAQ: CGI Scripts" <https://www.w3.org/Security/Faq/wwwsf4.html>
- UC Davis SecLab, "CGI-BIN Specific Vulnerabilities" <https://seclab.cs.ucdavis.edu/projects/testing/papers/cgi.html>
- Greg's Wiki, "BashFAQ/048 - Eval command and security" <https://mywiki.wooledge.org/BashFAQ/048>
- Apple, "Shell Script Security" <https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting/ShellScriptSecurity/ShellScriptSecurity.html>
- OWASP, "OS Command Injection Defense Cheat Sheet" <https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html>
- Vidar Holen, "Lessons learned from writing ShellCheck" <https://www.vidarholen.net/contents/blog/?p=859>
- GitHub, "koalaman/shellcheck" <https://github.com/koalaman/shellcheck>
- Baeldung, "Safe Use of eval in Bash" <https://www.baeldung.com/linux/bash-safe-use-eval>
