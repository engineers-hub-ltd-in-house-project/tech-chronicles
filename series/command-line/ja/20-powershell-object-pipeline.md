# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第20回：PowerShell――テキストパイプラインへの根本的批判

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Jeffrey Snoverが2002年のMonad Manifestoで指摘した、UNIXテキストパイプラインの構造的問題と「prayer-based parsing」という批判の本質
- PowerShell 1.0（2006年）が実装した.NETオブジェクトパイプラインの設計思想――テキストではなく型付きオブジェクトを流すという根本的な転換
- Verb-Noun命名規則、フォーマッティングレイヤーの分離、型システムの統合など、PowerShellの言語設計上の革新
- テキストパイプラインとオブジェクトパイプラインのトレードオフ――可読性、デバッグ容易性、外部ツールとの相互運用性、パフォーマンス
- Nushell（2019年）が提示した第三のアプローチ――テーブル指向パイプラインによるUNIXとPowerShellの統合
- 構造化データパイプラインの系譜が、CLIの未来にとって何を意味するのか

---

## 1. シェルというよりプログラミング言語

私がPowerShellに初めて触れたのは、2000年代後半のことだ。Windows Serverの管理を依頼されたプロジェクトで、Active Directoryのユーザー管理を自動化する必要があった。

それまでの私のWindows管理経験は、cmd.exeのバッチファイルとVBScriptの組み合わせだった。第6回で語ったcmd.exeの世界は、UNIX育ちの私にとって「似て非なるもの」だった。パイプはあるがgrepがない。リダイレクトはあるがawk的なフィルタがない。複雑な処理をしようとすると、すぐにVBScriptに逃げなければならなかった。シェルとプログラミング言語が分断されている世界だ。

PowerShellを起動して最初に打ったコマンドは、`Get-Process`だった。

画面にプロセスの一覧が表示された。ここまでは`ps`コマンドと同じだ。だが、次のコマンドで世界が変わった。

```powershell
Get-Process | Where-Object { $_.CPU -gt 100 } | Select-Object Name, CPU
```

CPU使用時間が100秒を超えるプロセスの名前とCPU時間だけを抽出する。この一行を読んだとき、私は「これはシェルというよりプログラミング言語だ」と思った。

bash + coreutilsで同等のことをするなら、こうなる。

```bash
ps aux | awk '$3 > 10.0 { printf "%-20s %s\n", $11, $3 }'
```

動く。だが、ここには構造的な問題がある。`$3`は「3列目」を意味するが、`ps`の出力フォーマットが変われば壊れる。列の区切りがスペースなのかタブなのかも、出力を見て「祈る」しかない。プロセス名にスペースが含まれていれば、`$11`以降のフィールドがずれる。

PowerShellの`Where-Object { $_.CPU -gt 100 }`は、そのような脆弱性を持たない。`$_`はパイプラインを流れる.NETオブジェクトであり、`.CPU`はそのオブジェクトのプロパティだ。列番号ではなくプロパティ名でアクセスする。出力フォーマットが変わろうと、プロパティ名が変わらない限り、このコマンドは正しく動作する。

感心した。これは正当な批判だ。テキストパイプラインの弱点を、真正面から突いている。

だが同時に、Linuxに戻って`cat access.log | grep 404 | awk '{print $7}' | sort | uniq -c | sort -rn | head -20`と打つと、テキストの「気楽さ」に安心する自分がいた。型を意識しなくていい。オブジェクトのプロパティ名を覚えなくていい。テキストは、テキストだ。`grep`で切り、`sed`で置換し、`awk`で集計する。道具はシンプルで、組み合わせは無限だ。

「テキストを流す」のではなく「オブジェクトを流す」パイプラインは、UNIXの限界を超えたのか。あなたは、この問いにどう答えるだろうか。

---

## 2. Monad Manifesto――パイプラインへの宣戦布告

### Jeffrey Snoverの問題意識

PowerShellの起源を理解するには、Jeffrey Snoverという人物と、彼が1999年にMicrosoftに入社した当時のWindowsの管理環境を知る必要がある。

1999年のWindowsサーバ管理は、GUIが前提だった。Active Directory、IIS、Exchange Server――これらの管理は、Microsoft Management Console（MMC）のスナップインを開き、マウスでクリックして設定するものだった。

これは小規模環境では問題ない。だが、数十台、数百台のサーバを管理する大規模環境では破綻する。同じ設定を100台のサーバに適用するのに、100回マウスをクリックするのか。設定の再現性はどう保証するのか。変更の履歴はどう追跡するのか。

UNIX/Linuxの世界は、この問題をとうの昔に解決していた。シェルスクリプトとSSHだ。設定はテキストファイルであり、操作はコマンドラインで行い、スクリプトで自動化する。第12回で語った「CLIが死ななかった理由」の核心がここにある。

Snoverはこの状況を痛感していた。Windowsの管理自動化には、UNIXのようなCLI基盤が必要だ。だが、UNIXのパイプラインをそのまま移植すれば済むのか。Snoverの答えは「否」だった。

### 「prayer-based parsing」という告発

2002年8月、SnoverはMonad Manifestoと題するホワイトペーパーを執筆した。この文書は、後のPowerShellの設計思想を余すところなく記述した、一種の宣言書だ。

Manifestoの中で、Snoverは従来のUNIXパイプラインにおけるテキスト処理を「prayer-based parsing」――祈りに基づくパース――と呼んだ。

この表現は辛辣だが、的確だ。UNIXのパイプラインでは、コマンドの出力はテキストであり、そのテキストの「形式」は各コマンドが独自に決める。次のコマンドは、そのテキストを「パース」して必要な情報を取り出す。だが、そのパースは脆弱だ。

Snoverが描いた典型的なシナリオはこうだ。コマンドの出力から必要なデータを取り出すために、先頭の3行か4行を捨てる。30列目から40列目を切り出す。そのスペースがタブではないことを祈る。それを整数にキャストする。

「祈る」のだ。テキストのフォーマットが想定どおりであることを。列の区切りが一貫していることを。ヘッダー行の数が変わらないことを。この「祈り」が裏切られたとき、パイプラインは黙って壊れる。エラーメッセージなしに、間違ったデータを返す。

Snoverの指摘は、UNIXのテキストパイプラインの本質的な弱点を突いている。テキストストリームは「スキーマレス」だ。データの構造に関する情報が、パイプラインの中を流れない。各コマンドは、前のコマンドの出力がどのような構造を持つか知らない。人間が「知っている」だけであり、その知識はコマンドラインの中にもスクリプトの中にもエンコードされていない。

### Windowsのアーキテクチャという文脈

Snoverの批判を理解するには、もう一つの文脈が必要だ。WindowsとUNIXの設計哲学の根本的な違いである。

UNIXは「すべてはファイルである」という思想に基づいている。第15回で語ったPlan 9は、これを極端に推し進めた。設定はテキストファイルであり、プロセス情報は`/proc`ファイルシステムとして公開され、デバイスは`/dev`の下にファイルとして見える。テキストストリームが普遍的インターフェースとして機能するのは、この設計思想の帰結だ。

Windowsは異なる道を歩んだ。Windowsでは、システムの情報は「APIが返す構造化データ」として公開される。レジストリ、WMI（Windows Management Instrumentation）、COM（Component Object Model）、.NET Framework。これらはすべて、構造化されたオブジェクトを返すAPIだ。テキストファイルではない。

この違いが、UNIXパイプラインをWindowsに移植する際の根本的な障壁になる。Windowsの管理情報はテキストとして公開されていないのだから、テキストパイプラインで処理するには、まず構造化データをテキストに変換し、テキストとして処理し、必要に応じて再び構造化データに戻す必要がある。この変換の各段階で、情報が失われ、脆弱性が生まれる。

Snoverの洞察は、この問題を逆転させたことにある。テキストパイプラインをWindowsに持ち込むのではなく、Windowsの構造化データモデルをパイプラインに持ち込む。テキストではなく、.NETオブジェクトを流す。

これがMonad Manifestoの核心であり、PowerShellの設計原理だ。

---

## 3. オブジェクトパイプラインの設計

### .NETオブジェクトがパイプラインを流れる

PowerShell 1.0は2006年11月14日、スペイン・バルセロナのIT Forumで正式にリリースされた。コードネーム「Monad」として2003年から開発されていたものが、2006年4月にWindows PowerShellに改名され、約半年後に世に出た。

PowerShellのパイプラインを流れるのは、テキストではなく.NETオブジェクトだ。この違いを具体例で見る。

```
UNIXテキストパイプライン:

  ps aux | grep nginx | awk '{print $2}'

  ps aux  →  テキスト行の集合（文字列）
             "root  1234  0.0  0.5  ... nginx: master process"
             "www   1235  0.0  0.3  ... nginx: worker process"
          →  grepが「nginx」を含む行をフィルタ（文字列マッチ）
          →  awkが「2列目」を切り出す（位置ベースのパース）
  出力: "1234" "1235"（文字列）

  問題点:
  - 「2列目」の意味はpsの出力フォーマットに依存
  - grep "nginx" は、コマンド名だけでなく引数にnginxを含む行もマッチ
  - 出力は文字列であり、数値としての検証はされない

PowerShellオブジェクトパイプライン:

  Get-Process -Name nginx | Select-Object Id

  Get-Process  →  System.Diagnostics.Processオブジェクトの集合
                   各オブジェクトは以下のプロパティを持つ:
                   .Id (int), .ProcessName (string), .CPU (double),
                   .WorkingSet64 (long), .StartTime (DateTime), ...
              →  -Name nginx がProcessNameプロパティで厳密にフィルタ
              →  Select-Object がIdプロパティを抽出
  出力: Idプロパティを持つオブジェクト（型付き）

  利点:
  - プロパティ名によるアクセス（位置に依存しない）
  - 型情報が保持される（Idはint型）
  - フィルタ条件が明確（プロセス名での完全一致）
```

この違いは、単なる構文の違いではない。データモデルの根本的な転換だ。

UNIXのテキストパイプラインでは、パイプラインを流れるデータは「意味のないバイト列」だ。各コマンドが独自にテキストを解釈し、意味を付与する。`awk '{print $2}'`は「スペースで区切った2番目のフィールド」という意味を人間が付与しているにすぎない。

PowerShellのオブジェクトパイプラインでは、パイプラインを流れるデータは「型情報を持つオブジェクト」だ。各プロパティの名前と型がオブジェクト自身に埋め込まれている。`.Id`がプロセスIDであることは、オブジェクトのメタデータとして保持されており、人間が「祈る」必要はない。

### Verb-Noun命名規則という発見可能性

PowerShellの設計上の革新は、パイプラインだけではない。コマンドレット（cmdlet）の命名規則もまた、UNIXのCLI文化に対する批判的応答だ。

UNIXのコマンド名は、歴史的経緯の塊だ。`ls`はlistの略、`grep`は`g/re/p`（edのglobal regular expression print）の略、`awk`は三人の作者の頭文字。覚えるしかない。第8回で語ったように、これらの名前には美しい歴史がある。だが、新しいユーザーが「ファイルの一覧を見たい」と思ったとき、`ls`という名前からその機能を推測することは困難だ。

PowerShellはこの問題をVerb-Noun命名規則で解決した。すべてのコマンドレットは「動詞-名詞」の形式に従う。動詞は承認済みリストから選択される。Get（取得）、Set（設定）、New（作成）、Remove（削除）、Start（開始）、Stop（停止）。名詞は操作対象を示す。Process、Service、Item、ChildItem。

```
PowerShellの命名規則:

  Get-Process      プロセスを取得する
  Stop-Process     プロセスを停止する
  Get-Service      サービスを取得する
  Start-Service    サービスを開始する
  Get-ChildItem    子アイテム（ファイル/フォルダ）を取得する
  New-Item         新しいアイテムを作成する
  Remove-Item      アイテムを削除する

  規則:
  - 動詞は承認済みリスト（約100種）から選択
  - 名詞は単数形
  - PascalCase形式
  - Get-Verbで承認済み動詞の一覧を取得可能
```

この命名規則の一貫性は、「発見可能性」を生む。UNIXでは、新しいコマンドを知るにはmanページを読むか、人に聞くか、Webで検索するしかない。PowerShellでは、「プロセスに関するコマンドが知りたい」と思えば`Get-Command *-Process`と打てばよい。「何かを取得するコマンドが知りたい」と思えば`Get-Command Get-*`と打てばよい。

第13回で語った「再認（recognition）」と「想起（recall）」の区分で言えば、UNIXのコマンド名は「想起」に依存し、PowerShellの命名規則は「再認」を促進する設計だ。

### フォーマッティングレイヤーの分離

PowerShellのもう一つの設計上の判断は、「データの取得」と「データの表示」を分離したことだ。

UNIXのコマンドは、出力フォーマットが固定されている。`ls -l`の出力形式は`ls`コマンドが決める。`ps aux`の出力形式は`ps`コマンドが決める。表示形式を変えたければ、別のオプション（`ls -1`、`ps -o`）を使うか、テキスト処理で加工するしかない。

PowerShellでは、コマンドレットはオブジェクトを返すだけだ。そのオブジェクトをどう「表示」するかは、フォーマッティングシステムが決める。

```powershell
# 同じGet-Processの結果を異なる形式で表示

Get-Process | Format-Table Name, CPU, WorkingSet
# テーブル形式で表示

Get-Process | Format-List Name, CPU, WorkingSet
# リスト形式で表示

Get-Process | ConvertTo-Json
# JSON形式で出力

Get-Process | ConvertTo-Csv
# CSV形式で出力

Get-Process | Export-Clixml -Path processes.xml
# CLIXMLとして保存（オブジェクトの完全なシリアライズ）
```

データの取得と表示の分離は、パイプラインの堅牢性に直結する。UNIXでは、パイプラインの途中でテキストの「見た目」が変わると、後続のコマンドが壊れる。PowerShellでは、パイプラインを流れるのはオブジェクトであり、テキスト表示は最後の段階でのみ行われる。パイプラインの途中で「見た目」が問題になることはない。

---

## 4. テキスト vs オブジェクト――トレードオフの深層

### オブジェクトパイプラインが勝る場面

PowerShellのオブジェクトパイプラインが、テキストパイプラインに対して明確に優位な場面がある。

**第一に、構造化データの処理だ。** JSON、XML、CSVのような構造化データを扱う場合、テキストパイプラインは力業になる。第10回で語ったように、UNIXのテキスト処理ツール群はJSONを想定して設計されていない。`jq`が2012年に登場するまで、UNIXパイプラインでJSONを扱う標準的な方法はなかった。PowerShellでは、構造化データはそのままオブジェクトとしてパイプラインを流れる。

**第二に、複雑なフィルタリングだ。** 「CPU使用時間が100秒を超え、かつメモリ使用量が500MB以上のプロセス」をフィルタする場合、PowerShellでは直感的に書ける。

```powershell
Get-Process | Where-Object { $_.CPU -gt 100 -and $_.WorkingSet64 -gt 500MB }
```

テキストパイプラインでは、同じフィルタリングに複数のツールとパースロジックが必要になり、列の位置や数値フォーマットの仮定に依存する。

**第三に、型安全性だ。** オブジェクトパイプラインでは、`.CPU`が数値であることが型として保証される。テキストパイプラインでは、「数字に見える文字列」を扱っているにすぎない。文字列比較と数値比較の混同によるバグは、シェルスクリプトの古典的な落とし穴だ。

### テキストパイプラインが勝る場面

だが、テキストパイプラインにも、オブジェクトパイプラインでは代替しがたい強みがある。

**第一に、普遍性だ。** テキストは最も普遍的なインターフェースである。あらゆるプログラミング言語、あらゆるOS、あらゆるプロトコルがテキストを扱える。この連載の核心メッセージ――「テキストという最も普遍的なインターフェースが、あらゆる時代の計算モデルに適応し続けている」――は、テキストパイプラインの強みの源泉でもある。

PowerShellのオブジェクトパイプラインは.NETに依存する。.NETランタイムがない環境では機能しない。`Get-Process`が返すのは.NETの`System.Diagnostics.Process`オブジェクトであり、このオブジェクトの存在は.NETエコシステムの中でのみ意味を持つ。

テキストは違う。`ps aux`の出力は、Pythonで読めるし、Rubyで読めるし、Cで読める。SSHの向こう側のFreeBSDでも読める。20年前に書かれたシェルスクリプトでも読める。テキストの普遍性は、50年間変わらないCLIの生命線だ。

**第二に、可視性とデバッグ容易性だ。** テキストパイプラインでは、パイプラインの任意の段階で`cat`や`less`を挟めば、データの内容を目で確認できる。テキストは人間が直接読める。

```bash
# パイプラインの途中経過を目視確認
ps aux | grep nginx        # ← ここで一旦止めて出力を確認
ps aux | grep nginx | tee /dev/stderr | awk '{print $2}'
                           # ↑ teeでstderrに出力しつつ後続に渡す
```

PowerShellのオブジェクトは、テキストではない。`Get-Process`の結果をパイプラインの途中で「見る」とき、表示されるのはフォーマッティングシステムが生成したテキスト表現であり、オブジェクトそのものではない。パイプラインのデバッグには、`Get-Member`でオブジェクトの構造を調べ、`Select-Object`で必要なプロパティを確認し、`Format-List *`で全プロパティを展開するという手順が必要になる。直感性はテキストに劣る。

**第三に、外部ツールとの相互運用性だ。** UNIXのエコシステムには、50年分のテキスト処理ツールが蓄積されている。`grep`、`sed`、`awk`、`sort`、`uniq`、`cut`、`tr`、`wc`――これらのツールはすべて、テキストストリームという共通インターフェースで接続される。

PowerShellが外部コマンドとパイプで接続するとき、.NETオブジェクトはテキストに変換される。つまり、外部コマンドとの接続点で、オブジェクトパイプラインの利点は失われる。PowerShellのエコシステムの「中」にいる限りはオブジェクトの恩恵を受けられるが、「外」に出た瞬間にテキストの世界に戻る。

### 根本的なトレードオフ

このトレードオフは、より深い設計判断に根ざしている。

テキストパイプラインの設計は「最小公約数」のアプローチだ。すべてのプログラムがテキストを出力できる。すべてのプログラムがテキストを入力として受け取れる。テキストという最も単純なデータ形式を共通インターフェースとすることで、あらゆるプログラムの組み合わせが可能になる。代償として、構造情報が失われる。

オブジェクトパイプラインの設計は「最大公約数」のアプローチだ。すべてのコマンドレットが型付きオブジェクトを出力し、型付きオブジェクトを入力として受け取る。プロパティ名と型情報がパイプラインを通じて保持される。代償として、.NETエコシステムへの依存が生まれる。

どちらが「正しい」かは、文脈による。そして、この問いに対する第三の回答が、2019年に登場する。

---

## 5. Nushell――テーブル指向パイプラインの挑戦

### UNIXでもPowerShellでもない

2019年8月23日、Jonathan Turner、Andres Robalino、Yehuda Katzの三人がNushellを公開した。Rustで実装された新しいシェルだ。初期コミットは2019年5月10日に遡る。

Nushellの設計思想は、UNIXのテキストパイプラインともPowerShellのオブジェクトパイプラインとも異なる。Nushellは「テーブル指向パイプライン」とでも呼ぶべきアプローチを取る。

パイプラインを流れるデータは、テーブルだ。行と列を持つ構造化データ。だが、それは.NETオブジェクトではない。Nushell独自の型システムで管理される軽量な値（Value）だ。

```
三つのパイプラインモデルの比較:

  UNIXテキストパイプライン:
    データ形式: バイトストリーム（テキスト）
    型情報: なし
    パース: 各コマンドが個別に実行
    依存関係: なし（どの言語・OSでも動作）
    例: ls -l | grep ".md" | awk '{print $9}'

  PowerShellオブジェクトパイプライン:
    データ形式: .NETオブジェクト
    型情報: .NET型システムで完全に保持
    パース: 不要（プロパティアクセス）
    依存関係: .NETランタイム
    例: Get-ChildItem *.md | Select-Object Name

  Nushellテーブル指向パイプライン:
    データ形式: テーブル（行と列の構造化データ）
    型情報: Nushell独自の型で保持（int, string, date等）
    パース: 多くのフォーマットをネイティブサポート
    依存関係: Nushellバイナリのみ
    例: ls | where name =~ ".md" | select name
```

Nushellでディレクトリの内容を表示すると、テキストの羅列ではなく、構造化されたテーブルが返る。各行がファイルやディレクトリを表し、列にはname、type、size、modifiedといったフィールドが並ぶ。このテーブルは内部的にも構造化データとして保持されており、表示とデータ構造が一致している。

```nu
# Nushellでのパイプライン例

# ディレクトリ内のMarkdownファイルを、サイズ順に表示
ls | where name =~ "\.md$" | sort-by size | reverse

# JSONファイルを読み込み、フィルタして表示
open data.json | where age > 30 | select name age

# CSVファイルを読み込み、集計
open sales.csv | group-by region | each { |g| { region: $g.group, total: ($g.items | get amount | math sum) } }
```

ここにNushellの特徴が表れている。`open`コマンドは、ファイルの拡張子からフォーマットを自動判定し、JSON、YAML、CSV、TOML、SQLiteなどを構造化データとして読み込む。テキストとして読み込んでから`jq`や`awk`でパースする必要がない。かといって、.NETオブジェクトに変換するわけでもない。ファイルの中身がそのままテーブルになる。

### PowerShellの思想をUNIXの土壌に

Nushellが興味深いのは、PowerShellの「構造化データパイプライン」という思想を、UNIX/Linuxのエコシステムに持ち込もうとしている点だ。

PowerShellは.NETに深く結びついている。WindowsのシステムAPIが.NETオブジェクトを返すから、.NETオブジェクトをパイプラインで流すことに自然な必然性があった。だが、UNIX/Linuxの世界には.NETの必然性がない。

Nushellは、.NETの代わりに独自の軽量型システムを持つ。そして、UNIX/Linuxの世界で一般的なデータフォーマット――JSON、YAML、CSV、TOML――をネイティブにサポートすることで、既存のエコシステムとの接続点を確保している。

さらにNushellは、Apache Arrowベースのデータフレーム処理もサポートしている。Polarsエンジンを利用した高速な列指向演算により、大量のデータを効率的に処理できる。これはPowerShellにもUNIXツール群にもなかった機能だ。

だが、Nushellには大きな課題もある。POSIX非互換であることだ。既存のシェルスクリプトはNushellでは動作しない。パイプラインの演算子の構文も、bash/zshとは異なる。50年分のシェルスクリプト資産との断絶は、普及の最大の障壁だ。

これは、第15回で語ったPlan 9のジレンマと構造的に同じだ。技術的には優れた設計であっても、既存のエコシステムとの互換性を断つことのコストは極めて大きい。Plan 9がUNIXを置き換えられなかったように、Nushellがbash/zshを置き換えることは容易ではない。

### 構造化データパイプラインの系譜

PowerShellとNushellは、CLIの歴史において重要な系譜を形成している。

1973年、Doug McIlroyとKen Thompsonがパイプを発明した。テキストストリームが普遍的インターフェースとなった。第7回で語ったように、これはCLIの本質的な強さの源泉だ。

2006年、Jeffrey SnoverがPowerShellで「テキストではなくオブジェクトを流す」というパラダイムを実現した。テキストパイプラインの限界を正面から指摘し、型付きデータの利点を証明した。

2019年、Jonathan TurnerらがNushellで「テーブル指向パイプライン」を提示した。.NETに依存せず、複数のデータフォーマットをネイティブに扱い、UNIXとPowerShellの両方の思想を取り込もうとした。

この系譜が示すのは、「パイプラインを流れるデータの形式」という問いが、CLIの設計において未だ決着していないということだ。テキストか、オブジェクトか、テーブルか。あるいは、まだ発明されていない第四のアプローチか。

---

## 6. ハンズオン：三つのパイプラインを体感する

### 環境構築

```bash
# Docker環境で実行（ubuntu:24.04ベース）
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：テキストパイプラインの強さと脆さ

```bash
apt-get update && apt-get install -y procps

echo "=== 演習1: テキストパイプラインの強さと脆さ ==="
echo ""

# まず、psの出力を確認する
echo "--- ps auxの出力（先頭5行） ---"
ps aux | head -5
echo ""

# テキストパイプラインでプロセス情報を取得
echo "--- テキストパイプラインでCPU使用率上位5件 ---"
ps aux --sort=-%cpu | head -6
echo ""

# awkで特定列を抽出（正常に動作する例）
echo "--- awkで特定列を抽出 ---"
ps aux | awk 'NR>1 {printf "PID=%-8s CPU=%-6s MEM=%-6s CMD=%s\n", $2, $3, $4, $11}'  | head -10
echo ""

# テキストパイプラインの脆さを体験する
echo "--- テキストパイプラインの脆弱性 ---"
echo ""
echo "以下のコマンドは、プロセス名にスペースを含む場合に壊れる:"
echo '  ps aux | awk "{print \$11}"'
echo ""
echo "実際に試す:"
ps aux | awk '{print $11}' | head -10
echo ""
echo "→ \$11はCOMMAND列の「最初の単語」のみを返す。"
echo "  引数を含むコマンド名（例: /usr/bin/python3 script.py）の場合、"
echo "  \$11は'/usr/bin/python3'のみ。script.pyは\$12に入る。"
echo "  列番号ベースのパースは、出力フォーマットの仮定に依存する。"
echo "  これがSnoverの言う'prayer-based parsing'だ。"
echo ""

# ps -oで出力フォーマットを制御（テキストパイプラインの堅牢な使い方）
echo "--- ps -oで出力フォーマットを明示指定（堅牢なアプローチ） ---"
ps -eo pid,pcpu,pmem,comm --sort=-pcpu | head -10
echo ""
echo "→ ps -oを使えば、列の順序とフォーマットを明示的に指定できる。"
echo "  これはテキストパイプラインの脆弱性を緩和する方法だが、"
echo "  各コマンドごとに出力制御オプションを覚える必要がある。"
```

### 演習2：PowerShellのオブジェクトパイプラインを体感する

```bash
echo ""
echo "=== 演習2: PowerShellのオブジェクトパイプラインを疑似体験 ==="
echo ""
echo "PowerShellの実行にはpwshが必要だが、ここではPowerShellの"
echo "パイプラインの動作原理をbashで再現して理解する。"
echo ""

# /procからプロセス情報をJSON構造として取得する
echo "--- /procからプロセス情報を構造化データとして取得 ---"
echo ""

apt-get install -y jq > /dev/null 2>&1

# プロセス情報をJSON配列として構造化
echo "プロセス情報をJSON形式で構造化:"
ps -eo pid,pcpu,pmem,comm --no-headers | head -10 | awk '{
  printf "{\"pid\": %s, \"cpu\": %s, \"mem\": %s, \"name\": \"%s\"}\n", $1, $2, $3, $4
}' | jq -s '.'
echo ""

echo "--- jqによる構造化データのフィルタリング ---"
echo ""
echo "CPU使用率が0より大きいプロセスをフィルタ（PowerShell的アプローチ）:"
ps -eo pid,pcpu,pmem,comm --no-headers | awk '{
  printf "{\"pid\": %s, \"cpu\": %s, \"mem\": %s, \"name\": \"%s\"}\n", $1, $2, $3, $4
}' | jq -s '[.[] | select(.cpu > 0)] | sort_by(-.cpu) | .[:5]'
echo ""

echo "→ jqを使えば、プロパティ名でアクセスし、型付きの比較が可能になる。"
echo "  .cpu > 0 は数値比較であり、文字列比較ではない。"
echo "  これはPowerShellの Where-Object { \$_.CPU -gt 0 } と同等の操作だ。"
echo "  つまり、UNIXでも構造化データを流せば、prayer-based parsingを回避できる。"
echo "  その道具がjqであり、Nushellはこれをシェルの基本機能として組み込んだ。"
```

### 演習3：テキスト vs 構造化データの堅牢性比較

```bash
echo ""
echo "=== 演習3: テキスト vs 構造化データの堅牢性比較 ==="
echo ""

# テストデータを作成
mkdir -p /tmp/pipeline-test
cat > /tmp/pipeline-test/data.json << 'JSONEOF'
[
  {"name": "Alice Johnson", "age": 32, "department": "Engineering", "salary": 95000},
  {"name": "Bob Smith", "age": 45, "department": "Sales", "salary": 78000},
  {"name": "Carol Williams", "age": 28, "department": "Engineering", "salary": 88000},
  {"name": "David Lee", "age": 51, "department": "Management", "salary": 120000},
  {"name": "Eve Brown", "age": 35, "department": "Engineering", "salary": 102000},
  {"name": "Frank O'Brien", "age": 42, "department": "Sales", "salary": 82000}
]
JSONEOF

cat > /tmp/pipeline-test/data.csv << 'CSVEOF'
name,age,department,salary
Alice Johnson,32,Engineering,95000
Bob Smith,45,Sales,78000
Carol Williams,28,Engineering,88000
David Lee,51,Management,120000
Eve Brown,35,Engineering,102000
Frank O'Brien,42,Sales,82000
CSVEOF

echo "--- テスト1: Engineeringの平均給与を求める ---"
echo ""

echo "[テキストパイプライン（CSV + awk）]:"
echo '  grep "Engineering" data.csv | awk -F, "{sum+=\$4; n++} END {print sum/n}"'
grep "Engineering" /tmp/pipeline-test/data.csv | awk -F, '{sum+=$4; n++} END {printf "平均給与: %.0f\n", sum/n}'
echo ""
echo "  問題: ヘッダー行にEngineeringが含まれていたら？"
echo "  問題: 名前にEngineeringが含まれる人がいたら？"
echo "  問題: 列の順序が変わったら？"
echo ""

echo "[構造化データパイプライン（JSON + jq）]:"
echo '  jq "[.[] | select(.department==\"Engineering\")] | map(.salary) | add / length" data.json'
jq '[.[] | select(.department=="Engineering")] | map(.salary) | add / length' /tmp/pipeline-test/data.json
echo ""
echo "  利点: departmentフィールドの完全一致でフィルタ"
echo "  利点: salary フィールドを名前で指定（列番号に依存しない）"
echo "  利点: ヘッダーや他のフィールドに影響されない"
echo ""

echo "--- テスト2: 名前にアポストロフィを含むデータの扱い ---"
echo ""
echo "[テキストパイプライン]:"
echo "  Frank O'Brien のアポストロフィは、awkやsedで問題を起こしうる"
grep "O'Brien" /tmp/pipeline-test/data.csv
echo ""

echo "[構造化データパイプライン]:"
jq '.[] | select(.name | contains("O'"'"'Brien"))' /tmp/pipeline-test/data.json
echo ""
echo "→ 構造化データでは、値はフィールドとして区切られているため、"
echo "  特殊文字を含むデータでもパースが壊れない。"
echo "  テキストパイプラインでは、区切り文字と値の中の同一文字の"
echo "  衝突が、古典的なバグの温床となる。"
```

### 演習4：パイプラインの設計思想を比較する

```bash
echo ""
echo "=== 演習4: 三つの設計思想の総合比較 ==="
echo ""

echo "同じタスク: 「/etcの下で、サイズが1KBを超えるファイルを、"
echo "              サイズの降順で上位5件表示する」"
echo ""

echo "[1. UNIXテキストパイプライン (bash + coreutils)]:"
echo '  find /etc -type f -exec ls -la {} + 2>/dev/null | awk "\$5 > 1024" | sort -k5 -rn | head -5'
find /etc -type f -exec ls -la {} + 2>/dev/null | awk '$5 > 1024' | sort -k5 -rn | head -5
echo ""

echo "[2. PowerShell相当 (構造化データ)]:"
echo '  # PowerShell: Get-ChildItem /etc -Recurse -File | Where-Object { $_.Length -gt 1024 } | Sort-Object Length -Descending | Select-Object -First 5 Name, Length'
echo ""

echo "[3. jqによる構造化アプローチ（bashでの近似）]:"
find /etc -type f -exec stat --format='{"name":"%n","size":%s}' {} + 2>/dev/null | jq -s '[.[] | select(.size > 1024)] | sort_by(-.size) | .[:5] | .[] | "\(.size)\t\(.name)"'
echo ""

echo "→ 三つのアプローチは、同じ結果を異なる方法で得る。"
echo ""
echo "  テキストパイプライン:"
echo "    + 既存ツールの組み合わせで即座に書ける"
echo "    + 外部依存がない（coreutils のみ）"
echo "    - 列番号に依存する（\$5がサイズ列である仮定）"
echo "    - ソートキーの指定が暗黙的"
echo ""
echo "  オブジェクト/構造化データパイプライン:"
echo "    + プロパティ名で明示的にアクセス"
echo "    + 型付き比較（数値 > 1024、文字列比較ではない）"
echo "    + 操作の意図が読みやすい"
echo "    - 追加のツール（jq, PowerShell）が必要"
echo "    - テキストより冗長になる場合がある"
```

ハンズオンの自動セットアップスクリプトは `handson/command-line/20-powershell-object-pipeline/setup.sh` を参照してほしい。

---

## 7. まとめと次回予告

### この回の要点

第一に、Jeffrey Snoverは2002年のMonad Manifestoで、UNIXテキストパイプラインの構造的な弱点を正確に指摘した。テキストストリームはスキーマレスであり、パイプラインの各段階でテキストをパースする「prayer-based parsing」は脆弱だ。この批判は正当であり、テキストパイプラインの設計を盲目的に礼賛するべきではない。

第二に、PowerShell（2006年）は、.NETオブジェクトをパイプラインで流すことで、この問題を解決した。プロパティ名によるアクセス、型安全なフィルタリング、フォーマッティングレイヤーの分離。これらの設計判断は、テキストパイプラインでは実現できない堅牢性を提供する。

第三に、PowerShellの設計はWindowsのアーキテクチャ（APIが構造化データを返す）との適合性が高いが、UNIX/Linuxのエコシステム（テキストファイルと外部コマンドの文化）との相性は限定的だ。オブジェクトパイプラインの利点は、PowerShellのエコシステムの「中」にいるときに最大化される。

第四に、テキストパイプラインとオブジェクトパイプラインのトレードオフは、「普遍性 vs 型安全性」「簡潔さ vs 堅牢さ」「外部ツールとの互換性 vs エコシステム内の一貫性」という設計判断の違いに帰着する。どちらが優れているかは文脈による。

第五に、Nushell（2019年）は、テーブル指向パイプラインという第三のアプローチを提示した。.NETに依存せず、JSON/YAML/CSV等のデータフォーマットをネイティブにサポートし、UNIXとPowerShellの両方の思想を取り込む。POSIX非互換という課題はあるが、パイプラインの設計空間に新しい可能性を開いた。

### 冒頭の問いへの暫定回答

「テキストを流す」のではなく「オブジェクトを流す」パイプラインは、UNIXの限界を超えたのか。

限界の一部は超えた。構造化データの処理、型安全なフィルタリング、フォーマッティングの分離。これらの領域で、オブジェクトパイプラインはテキストパイプラインに対して明確な優位性を持つ。Snoverの批判は正当だった。

だが、テキストパイプラインが50年間生き残っている理由もまた正当だ。テキストの普遍性、可視性、外部ツールとの相互運用性。これらは、オブジェクトパイプラインでは代替しがたい。.NETランタイムがない環境で`Get-Process`は動かないが、`ps aux | grep nginx`はどのUNIX系OSでも動く。

正解は一つではない。テキストパイプラインが適する場面と、構造化データパイプラインが適する場面がある。重要なのは、両方の設計思想を理解し、文脈に応じて選択できることだ。そして、Nushellのような試みが示しているように、両者の融合もまた、探求に値する方向性である。

### 次回予告

次回、第21回「CLIデザインの原則――man, --help, 12 Factor CLI」では、「良いCLIツールとは何か」という問いに向き合う。

manページの歴史は1971年のUNIX V1に遡る。GNUコーディング標準はlong optionの規約を定めた。POSIXはUtility Conventionsを策定した。そして2018年、Jeff Dickeyは「12 Factor CLI Apps」を提唱した。50年分のCLI設計の知恵を整理し、自分でCLIツールを作るときに何を守るべきかを語る。

---

## 参考文献

- Jeffrey P. Snover, "Monad Manifesto", 2002年8月, <https://www.jsnover.com/Docs/MonadManifesto.pdf>
- Microsoft PowerShell Team, "Monad Manifesto -- the Origin of Windows PowerShell", <https://devblogs.microsoft.com/powershell/monad-manifesto-the-origin-of-windows-powershell/>
- Microsoft PowerShell Team, "It's a Wrap! Windows PowerShell 1.0 Released!", 2006年, <https://devblogs.microsoft.com/powershell/its-a-wrap-windows-powershell-1-0-released/>
- Wikipedia, "PowerShell", <https://en.wikipedia.org/wiki/PowerShell>
- Wikipedia, "Jeffrey Snover", <https://en.wikipedia.org/wiki/Jeffrey_Snover>
- Microsoft .NET Blog, "PowerShell is now open-source, and cross-platform", 2016年, <https://devblogs.microsoft.com/dotnet/powershell-is-now-open-source-and-cross-platform/>
- Microsoft Learn, "The Monad Manifesto", <https://learn.microsoft.com/en-us/powershell/scripting/developer/monad-manifesto?view=powershell-7.5>
- Microsoft Learn, "Approved Verbs for PowerShell Commands", <https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.5>
- devops-collective-inc, "The Monad Manifesto, Annotated", <https://devops-collective-inc.gitbook.io/the-monad-manifesto-annotated/about-this-book>
- Nushell, "Introducing nushell", 2019年8月23日, <https://www.nushell.sh/blog/2019-08-23-introducing-nushell.html>
- Nushell公式サイト, <https://www.nushell.sh/>
- GitHub, nushell/nushell, <https://github.com/nushell/nushell>
- John D. Cook, "Comparing the Unix and PowerShell pipelines", 2009年, <https://www.johndcook.com/blog/2009/06/09/comparing-the-unix-and-powershell-pipelines/>
- John D. Cook, "Where the Unix philosophy breaks down", 2010年, <https://www.johndcook.com/blog/2010/06/30/where-the-unix-philosophy-breaks-down/>
- The Register, "PowerShell architect retires after decades at the prompt", 2026年1月, <https://www.theregister.com/2026/01/22/powershell_snover_retires/>
