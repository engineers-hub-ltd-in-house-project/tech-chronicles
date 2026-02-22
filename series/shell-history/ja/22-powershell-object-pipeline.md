# 第22回：PowerShellという異なるパラダイム――オブジェクトパイプラインの世界

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- Jeffrey Snoverの「Monad Manifesto」（2002年）――Unix哲学への根本的批判と「prayer-based parsing」の問題提起
- PowerShell 1.0（2006年）の誕生――テキストではなく.NETオブジェクトがパイプラインを流れる設計
- オブジェクトパイプラインの技術的仕組み――ByValue/ByPropertyNameバインディング、フォーマッティングレイヤーの分離
- Verb-Noun命名規則とcmdlet設計――自己文書化するコマンド体系
- PowerShell Core（2016年）によるクロスプラットフォーム化とオープンソース化の意味
- テキストパイプラインとオブジェクトパイプラインの本質的なトレードオフ

---

## 1. 導入――テキストを流さないパイプに出会った日

私がPowerShellを初めて触ったのは、2010年代前半のことだった。

当時、あるプロジェクトでWindows Server環境の管理を担当することになった。それまでの私のキャリアはLinux/Unix一色だった。Slackware 3.5に始まり、bash、tcsh、kshを渡り歩き、サーバ管理のスクリプトはすべてbashで書いてきた。Windowsの管理といえばGUIをクリックするものだと思っていた。

「PowerShellを使ってください」と言われたとき、正直なところ身構えた。Microsoft製のシェルなど、Unixエンジニアの自分には縁のないものだと。だが、先方のインフラチームが既にPowerShellでサーバ管理を自動化しており、その環境に合わせる必要があった。

最初に打ったコマンドを覚えている。

```powershell
Get-Process | Where-Object { $_.CPU -gt 100 } | Sort-Object CPU -Descending | Select-Object -First 5 Name, CPU, WorkingSet
```

画面に表示されたのは、プロセス名、CPU使用量、メモリ使用量が整然と並んだテーブルだった。ここまでなら、bashで`ps aux | sort -k3 -rn | head -5`と書くのと大差ない。だが、決定的な違いがあった。

`$_.CPU -gt 100`——この`$_`はテキストの「行」ではない。**.NETオブジェクト**だ。`CPU`はそのオブジェクトの**プロパティ**であり、テキストの「第3カラム」ではない。`-gt 100`は**数値比較**であり、文字列のソートではない。

bashの世界では、`ps aux`の出力はテキストだ。CPUの値を取り出すには`awk '{print $3}'`と書く。だが、`ps`の出力フォーマットが変われば——たとえばカラムの順序が変われば——この`$3`は壊れる。第5回で語ったクォーティング地獄と同じ構造の脆さだ。

PowerShellでは、`Get-Process`が返すのはテキストではなく`System.Diagnostics.Process`オブジェクトの配列だ。`.CPU`プロパティは常に`.CPU`プロパティであり、出力の見た目が変わっても壊れない。

これは私にとって、認識の転換だった。第6回でパイプの天才性を語り、第21回で次世代シェルのテーブル指向を語ったが、その「源流」はここにあった。PowerShellは、Nushellの10年以上前に、テキストストリームとは異なるパイプラインの形を実現していたのだ。

あなたは、パイプラインを流れるものが「テキスト」以外でもよいと初めて知ったとき、何を感じただろうか。それとも、まだその経験がないだろうか。

---

## 2. 歴史的背景――Monad Manifestoと「祈り駆動パース」への反乱

### Jeffrey Snoverという人物

PowerShellの物語は、一人のエンジニアの執念から始まる。

Jeffrey P. Snoverは、DEC（Digital Equipment Corporation）でネットワーク・システム管理プロジェクトの開発マネージャーを務め、その後TivoliでCTOオフィスのアーキテクトとして働いた後、1999年にMicrosoftに入社した。Management and Services Divisionのdivisional architectとして着任した彼は、Windowsの管理自動化が抱える根本的な問題に直面していた。

当時のWindows管理は、GUIに依存していた。サーバを100台管理するとき、GUIでは一つ一つクリックして設定するしかない。Unixの世界にはシェルスクリプトがあり、パイプがあり、自動化の文化があった。Windowsにはそれがなかった。

だが、SnoverはUnixのシェルをそのまま移植すればよいとは考えなかった。彼はUnixのパイプライン——テキストストリームの世界——に根本的な欠陥を見出していた。

### Monad Manifesto（2002年）

2002年8月8日、Snoverは「Monad Manifesto」と題する内部文書を書いた。この文書が、PowerShellの設計思想のすべての出発点だ。

Manifestoの中で、Snoverはまず既存の管理自動化の問題を4,000語以上にわたって分析した。そして、Unix のパイプラインについてこう書いた——Unixは「composability（合成可能性）の欠陥のある実装」を提供しており、コマンドの接続は「非構造化テキスト」を通じて行われ、「awkward, inconsistent, and imprecise（不格好で、一貫性がなく、不正確な）テキスト操作ユーティリティ」に依存していると。

Snoverはこの問題に鮮烈な名前を付けた。**「prayer-based parsing（祈り駆動パース）」**である。

> テキストをパースして、正しくパースできたことを祈る。最初の3行を削除して、4行でなかったことを祈る。30列目から40列目を切り出して、スペースがタブでなかったことを祈る。整数にキャストして、32ビットだったことを祈る。

この言葉は、第6回で私が語った「パイプ芸」の脆さを、一言で射抜いている。`ps aux | grep nginx | grep -v grep | awk '{print $2}' | xargs kill`——この一連のパイプラインのすべてのステップで、私たちはパースの成功を「祈っている」のだ。

Snoverの解決策は明快だった。テキストを流すのをやめる。代わりに、**.NETオブジェクト**をパイプラインに流す。オブジェクトにはプロパティがあり、型がある。パースは不要になる。列番号に依存する脆いコードは過去のものになる。

### Monadから PowerShellへ

Monad Manifestoに基づく開発は、2003年初頭に始まった。プロジェクト名は「Monad」、コマンドシェルの実行ファイルは`msh`（Monad Shell）だった。

2003年10月、ロサンゼルスのProfessional Developers Conferenceで、Monadは初めて公の場に姿を現した。Microsoftはパブリックベータを段階的にリリースし——Beta 1が2005年6月17日、Beta 2が2005年9月11日、Beta 3が2006年1月10日——開発者からのフィードバックを取り入れていった。

2006年4月25日、Microsoftは重要な発表を行った。MonadをWindows PowerShellに改名したのだ。同時にRelease Candidate 1を公開。この改名は単なる名前の変更ではなかった。PowerShellは「アドオン製品」から「Windowsの構成要素」に位置づけが変わったことを意味していた。

そして2006年11月14日、バルセロナのITForumのキーノートにおいて、Windows PowerShell 1.0の最終リリースが発表された。対応OSはWindows XP SP2、Windows Server 2003 SP1、Windows Vistaだった。

Monad Manifestoから4年余り。Snoverの構想が、製品として世に出た瞬間だった。

### オープンソース化とクロスプラットフォーム（2016年）

PowerShellが最初の10年間にWindows専用だったことは、Unix/Linuxエンジニアの世界からその存在を見えにくくした。私がPowerShellに触れたのが2010年代前半になってからだったのも、そのためだ。

転機は2016年8月18日に訪れた。MicrosoftはPowerShellをオープンソース化し（MITライセンス）、Linux・macOSへのクロスプラットフォーム対応を発表した。ソースコードはGitHubで公開された。この新たなPowerShellは「PowerShell Core」と呼ばれ、.NET Coreの上で動作する。一般提供（GA）はPowerShell Core 6.0として2018年1月10日に実現した。

2020年3月にリリースされたPowerShell 7.0では、名称から「Core」が外され、再び単に「PowerShell」に統一された。Windows PowerShell（5.1まで）とPowerShell Core（6.x）の二つの系統を一つに収束させる意図だ。.NET Core 3.1をベースとし、ForEach-Object -Parallelによる並列処理や、パイプラインチェーン演算子（`&&`と`||`——bashから借りた構文だ）が追加された。

2025年1月にはPowerShell 7.5が.NET 9.0.1ベースでリリースされ、2026年2月現在の最新安定版となっている。

そして2026年1月、PowerShellの父Jeffrey Snoverが引退した。23年間のMicrosoft、その後のGoogle Distinguished Engineer（SRE部門）を経て、Snoverは「Philosopher-Errant（放浪する哲学者）」を自称し、テクノロジーカンファレンスでの講演を続けている。2012年にはBruce Payette、James Truherと共にUSENIX LISA Outstanding Achievement Awardを受賞しており、PowerShellの技術的功績はUnixコミュニティからも認められている。

GitHubのPowerShell/PowerShellリポジトリは、2026年2月時点で5万を超えるスターを集めている。Windows専用シェルとして生まれたPowerShellは、20年かけて、クロスプラットフォームのオープンソースシェルに変貌した。

---

## 3. 技術論――オブジェクトパイプラインの設計と思想

### テキストパイプラインとの根本的な違い

PowerShellのパイプラインを理解するには、まずUnixのパイプラインとの違いを明確にする必要がある。

Unixのパイプラインでは、すべてのコマンドの入出力は**バイトストリーム**だ。`ls -l`の出力は文字列であり、`grep`はその文字列を行単位でパターンマッチし、`awk`は空白文字でフィールドを分割する。データの構造は暗黙の約束事にすぎない。

```
Unix パイプライン:

  ls -l  ──→  grep ".txt"  ──→  awk '{print $5, $9}'  ──→  sort -n
         バイト        バイト           バイト            バイト
       ストリーム    ストリーム       ストリーム        ストリーム

  ※ 各ステップで「テキストをパースして構造を推測する」工程が発生
  ※ ls の出力フォーマットが変わると awk の $5, $9 は壊れる
```

PowerShellのパイプラインでは、コマンド（cmdlet）の入出力は**.NETオブジェクト**だ。`Get-ChildItem`の出力は`FileInfo`/`DirectoryInfo`オブジェクトであり、各オブジェクトには`Name`、`Length`、`LastWriteTime`といったプロパティがある。プロパティにはそれぞれ型がある——`Length`は`Int64`、`LastWriteTime`は`DateTime`だ。

```
PowerShell パイプライン:

  Get-ChildItem ──→ Where-Object ──→ Sort-Object ──→ Select-Object
                .NET          .NET          .NET          .NET
              オブジェクト  オブジェクト  オブジェクト  オブジェクト

  ※ パースは不要。プロパティ名で直接アクセスする
  ※ 型情報が保持されるため、数値比較・日付比較が正確に行える
```

この違いは些末なものではない。根本的なパラダイムの転換だ。

テキストパイプラインでは、コマンド間のデータ交換のたびに「シリアライズ（オブジェクトをテキストに変換）→パース（テキストからデータを抽出）」というコストが発生する。PowerShellではこのコストがゼロになる。オブジェクトがそのままパイプラインを流れるからだ。

### パイプラインバインディング

PowerShellのパイプラインで特筆すべきは、上流のcmdletから流れてくるオブジェクトを、下流のcmdletがどのように受け取るかの仕組みだ。PowerShellは二つのバインディング方式を提供する。

**ByValue（値による）バインディング**: 下流のcmdletパラメータが期待する.NET型と、上流から流れてくるオブジェクトの型が一致する場合に自動的にバインドされる。たとえば、`Get-Process`が返す`Process`オブジェクトを`Stop-Process`がそのまま受け取れる。

```powershell
# ByValueバインディング: Processオブジェクトがそのまま渡される
Get-Process -Name "notepad" | Stop-Process
```

**ByPropertyName（プロパティ名による）バインディング**: 型が一致しない場合、PowerShellはオブジェクトのプロパティ名とパラメータ名の一致を試みる。上流のオブジェクトに`Name`というプロパティがあり、下流のcmdletに`-Name`というパラメータがあれば、自動的にバインドされる。

```powershell
# ByPropertyNameバインディング:
# CSVの"Name"列がGet-Processの-Nameパラメータにバインドされる
Import-Csv servers.csv | Get-Process
```

この仕組みにより、異なるcmdlet間の接続が型安全かつ自動的に行われる。bashでは`command1 | command2`と書いたとき、command2がcommand1の出力をどう解釈するかは完全にcommand2の実装に依存する。PowerShellでは、ランタイムがオブジェクトの型とプロパティに基づいてバインディングを解決し、一致しなければエラーを報告する。

### フォーマッティングレイヤーの分離

PowerShellの設計で私が最も感心したのは、**データと表示の分離**だ。

bashでは、`ls -l`の出力は人間が読むための整形済みテキストであると同時に、パイプラインを流れるデータでもある。この二つの役割は混在しており、分離できない。だからこそ、`ls -l | awk '{print $5}'`のような「人間向け整形の逆パース」が必要になる。

PowerShellは、この二つの役割を完全に分離した。

パイプラインを流れるのは、常にオブジェクトだ。人間が見るための整形は、パイプラインの最終段階で初めて行われる。具体的には、`Format-Table`、`Format-List`、`Format-Wide`、`Format-Custom`というフォーマットcmdletが、オブジェクトを「フォーマッティングデータ」に変換し、`Out-Host`や`Out-File`といった出力cmdletが最終的な表示を行う。

```
データ処理の流れ:

  Get-Process          オブジェクト
       |
  Where-Object         オブジェクト（フィルタ後）
       |
  Sort-Object          オブジェクト（ソート後）
       |
  Format-Table         フォーマッティングデータ ← ここで初めて「見た目」が決まる
       |
  Out-Host             画面に表示
```

重要なのは、`Format-Table`を通過した後のデータは、もはや他のcmdletで処理できないということだ。フォーマッティングは**破壊的操作**であり、パイプラインの最後に置く必要がある。逆に言えば、フォーマッティングcmdletを使わない限り、パイプラインのどの段階でもデータはオブジェクトとして完全に保持される。

PowerShellがターミナルに出力を表示するとき、明示的にFormat-*cmdletを使わなければ、デフォルトのフォーマッティングルールが適用される。オブジェクトの型に応じて、テーブル表示かリスト表示かが自動的に選択される。このルールは.ps1xmlファイルで定義されており、カスタマイズ可能だ。

### Verb-Noun命名規則

PowerShellのもう一つの特徴的な設計は、**Verb-Noun命名規則**だ。すべてのcmdletは`動詞-名詞`の形式で命名される。

```powershell
Get-Process        # プロセスを取得
Stop-Process       # プロセスを停止
Get-Service        # サービスを取得
Start-Service      # サービスを開始
Get-ChildItem      # 子項目を取得（ls相当）
Set-Location       # 場所を設定（cd相当）
Remove-Item        # 項目を削除（rm相当）
New-Item           # 新しい項目を作成（touch/mkdir相当）
```

動詞はMicrosoftが定義した「承認された動詞リスト」（Approved Verbs）から選択する。このリストは対称性を持つ——`Add`/`Remove`、`Enter`/`Exit`、`Get`/`Set`、`Push`/`Pop`、`Lock`/`Unlock`。名詞は必ず単数形だ（`Get-Process`であり、`Get-Processes`ではない）。

Unixコマンドの命名は歴史的偶然の産物だ。`ls`、`cat`、`grep`、`awk`、`sed`——これらの名前から機能を推測できるのは、既に知っている人間だけだ。PowerShellのVerb-Noun規則は、コマンド名そのものが自己文書化する。`Get-EventLog`が何をするコマンドか、PowerShellを知らなくても推測できるだろう。

そして、この命名規則は発見可能性をもたらす。`Get-Command -Noun Process`と打てば、`Process`に関連するすべてのcmdletが一覧できる。`Get-Command -Verb Remove`と打てば、「削除」に関するすべてのcmdletが見つかる。Unixでは、`man -k keyword`で近いことができるが、命名規則が統一されていないため、漏れが生じやすい。

### テキストパイプラインとオブジェクトパイプラインのトレードオフ

ここまでPowerShellの利点を語ってきたが、公平を期すためにトレードオフについても述べなければならない。

**冗長性**: `Get-ChildItem | Where-Object { $_.Length -gt 1MB } | Sort-Object Length -Descending`は、`ls -lS | head`と比べると明らかに冗長だ。対話的なワンライナーでは、bashの簡潔さに軍配が上がる場面がある。PowerShellにもエイリアス（`gci`、`where`、`sort`）が用意されているが、それでもbashのような「省略芸」には及ばない。

**起動速度**: PowerShellは.NETランタイムの初期化が必要なため、bashと比べて起動が遅い。bashが数ミリ秒で起動するのに対し、PowerShellは数百ミリ秒から1秒程度かかる。対話的利用ではさほど問題にならないが、大量のスクリプトを繰り返し実行するCI/CDパイプラインでは、この差が蓄積する。

**Unixツールチェーンとの統合**: Linux上でPowerShellを使う場合、`grep`や`awk`のようなUnixネイティブツールとの接続にはテキスト変換が必要になる。外部コマンドの出力はPowerShellにとって「ただの文字列」であり、オブジェクトパイプラインの恩恵を受けられない。PowerShellの真価が発揮されるのは、PowerShellのcmdlet同士を接続するときだ。

**学習コスト**: .NETの型システムの知識がアドバンテージになるため、.NETに馴染みのないUnix系エンジニアにとっては学習曲線がbashより急だ。`[System.IO.FileInfo]`や`[System.DateTime]`といった型名は、bash育ちの目にはなじまない。

**エコシステムの偏り**: PowerShellのモジュール（cmdlet集）はWindows/Azure管理に厚く、Linux/Unixの管理タスクには薄い。Linux上でPowerShellを使うメリットは、クロスプラットフォームスクリプトの統一くらいだというのが、正直な実感だ。

これらのトレードオフは、PowerShellが「悪い」ということではない。設計上の選択が異なれば、得られるものと失うものが変わる。bashはテキストの世界に最適化されたシェルであり、PowerShellはオブジェクトの世界に最適化されたシェルだ。問うべきは「どちらが優れているか」ではなく「どちらの世界に自分の仕事があるか」である。

---

## 4. ハンズオン――PowerShellをLinuxで体験する

### 環境構築

Docker環境（ubuntu:24.04ベース）でPowerShellをインストールし、bashとの比較を行う。`handson/shell-history/22-powershell-object-pipeline/setup.sh`にセットアップスクリプトを用意した。

```bash
# Docker環境の起動
docker run -it --rm ubuntu:24.04 bash

# PowerShellのインストール（Microsoft公式リポジトリから）
apt-get update && apt-get install -y wget apt-transport-https software-properties-common
wget -q "https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb"
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt-get update && apt-get install -y powershell

# PowerShellの起動
pwsh
```

### 演習1: オブジェクトの実体を確認する

PowerShellの世界では、すべてがオブジェクトだ。まずはその事実を体験する。

```powershell
# Get-Process の出力の「型」を確認する
Get-Process | Get-Member

# → TypeName: System.Diagnostics.Process
# → Name, CPU, WorkingSet64, Id などのプロパティが列挙される

# bashとの対比: ps aux の出力は「ただのテキスト」
# PowerShellでは、各プロセスが .NET オブジェクトとして存在する
```

`Get-Member`は、パイプラインを流れるオブジェクトの型とメンバ（プロパティ、メソッド）を表示するcmdletだ。bashには相当するものがない——テキストには「型」も「プロパティ」もないからだ。

```powershell
# オブジェクトのプロパティに直接アクセス
$proc = Get-Process | Sort-Object CPU -Descending | Select-Object -First 1
$proc.Name          # プロセス名
$proc.CPU           # CPU使用量（数値）
$proc.StartTime     # 起動時刻（DateTime型）

# DateTimeオブジェクトのメソッドを呼ぶ
$proc.StartTime.ToString("yyyy-MM-dd HH:mm:ss")
$proc.StartTime.DayOfWeek  # 曜日
```

オブジェクトが持つプロパティやメソッドを直接呼び出せる。`$proc.StartTime.DayOfWeek`のような操作をbashで再現しようとすれば、`date`コマンドの複雑なフォーマット指定が必要になるだろう。

### 演習2: bash vs PowerShell――同じタスクの比較

サーバ一覧のJSONファイルを処理する。

```powershell
# === サンプルデータの準備（PowerShell）===
@'
[
  {"name": "web-01", "region": "us-east", "cpu": 45.2, "memory": 72.1, "status": "running"},
  {"name": "web-02", "region": "us-east", "cpu": 78.9, "memory": 88.3, "status": "running"},
  {"name": "db-01", "region": "us-west", "cpu": 23.1, "memory": 95.7, "status": "running"},
  {"name": "db-02", "region": "us-west", "cpu": 12.4, "memory": 45.2, "status": "stopped"},
  {"name": "api-01", "region": "eu-west", "cpu": 67.3, "memory": 62.8, "status": "running"},
  {"name": "api-02", "region": "eu-west", "cpu": 91.2, "memory": 78.5, "status": "running"}
]
'@ | Set-Content /tmp/servers.json
```

```bash
# === bash + jq: CPU 70%以上の running サーバを地域ごとに集計 ===
jq '[.[] | select(.status == "running" and .cpu > 70)]
  | group_by(.region)
  | map({
      region: .[0].region,
      count: length,
      avg_cpu: (map(.cpu) | add / length)
    })' /tmp/servers.json
```

```powershell
# === PowerShell: 同じタスク ===
$servers = Get-Content /tmp/servers.json | ConvertFrom-Json
$servers |
  Where-Object { $_.status -eq "running" -and $_.cpu -gt 70 } |
  Group-Object region |
  ForEach-Object {
    [PSCustomObject]@{
      Region  = $_.Name
      Count   = $_.Count
      AvgCpu  = ($_.Group | Measure-Object cpu -Average).Average
    }
  }
```

bashでは`jq`という外部ツールの独自構文に依存する。`group_by`、`map`、`add`——これらは`jq`の関数であり、bashの機能ではない。PowerShellでは、`Where-Object`（フィルタ）、`Group-Object`（グループ化）、`Measure-Object`（集計）がシェルのネイティブ機能として統合されている。そして、パイプラインのすべての段階でデータはオブジェクトのままだ。

### 演習3: フォーマッティングレイヤーの体験

PowerShellのデータと表示の分離を体感する。

```powershell
# 同じデータを、異なるフォーマットで表示する
$procs = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5

# テーブル表示（デフォルト）
$procs | Format-Table Name, CPU, WorkingSet64 -AutoSize

# リスト表示
$procs | Format-List Name, CPU, WorkingSet64

# CSV出力（データとしてエクスポート）
$procs | Select-Object Name, CPU, WorkingSet64 | ConvertTo-Csv -NoTypeInformation

# JSON出力
$procs | Select-Object Name, CPU, WorkingSet64 | ConvertTo-Json
```

注目すべきは、`$procs`というデータは一つしかないにもかかわらず、`Format-Table`、`Format-List`、`ConvertTo-Csv`、`ConvertTo-Json`という異なるフォーマットで自在に出力できる点だ。データはオブジェクトとして一度だけ取得し、表示方法は後から選ぶ。

bashでは、`ps aux`の出力はテキストとして一つの形に固定される。CSVに変換したければ`awk`で加工し、JSONに変換したければ`jq`で構築し直す。データの再取得か、テキストの再パースが必要だ。

### 演習4: Verb-Nounの発見可能性

PowerShellの命名規則がもたらす発見可能性を体験する。

```powershell
# "Process" に関連する全コマンドを発見
Get-Command -Noun Process
# → Get-Process, Start-Process, Stop-Process, Wait-Process, Debug-Process

# "Get" 動詞のコマンドを探索
Get-Command -Verb Get | Measure-Object
# → 数百のGet-*コマンドが存在

# 特定のcmdletのパラメータを調査
Get-Help Get-Process -Parameter *
# → 各パラメータの型、パイプライン入力対応（ByValue/ByPropertyName）が表示される

# 使い方のサンプルを表示
Get-Help Get-Process -Examples
```

`Get-Command -Noun Process`で、プロセスに関連する操作がすべて列挙される。bashでプロセス関連のコマンドを探すには、`ps`、`kill`、`top`、`pkill`、`pgrep`、`nice`、`renice`——個別に知っている必要がある。統一された命名規則がないからだ。

### 演習で得られるもの

このハンズオンで実感してほしいのは以下の3点だ。

第一に、パイプラインを流れるものがオブジェクトであるとき、「パースの苦痛」が消滅する。`awk '{print $5}'`のようなカラム番号依存のコードは書かなくてよい。

第二に、データと表示の分離は強力だ。同じデータをテーブル、リスト、CSV、JSONなど自在に出力できる。

第三に、Verb-Noun命名規則は学習効率を劇的に向上させる。コマンド名が自己文書化するため、マニュアルを読む前にコマンドを推測できる。

同時に、冗長性と起動速度という代償も体感できたはずだ。対話的なワンライナーでは、bashの方が圧倒的に速く書ける場面がある。

---

## 5. まとめと次回予告

### まとめ

この回で見てきたのは、テキストストリームという「聖域」に対する、最も体系的で最も長期にわたる挑戦の物語だ。

Jeffrey Snoverは2002年のMonad Manifestoで、Unixのテキストパイプラインを「prayer-based parsing（祈り駆動パース）」と呼び、根本的な批判を行った。テキストをパースして正しさを祈る時代は終わりにすべきだと。彼の解決策は、.NETオブジェクトをパイプラインに流すことだった。

2006年11月14日にリリースされたWindows PowerShell 1.0は、その構想を製品として実現した。Verb-Noun命名規則による自己文書化するコマンド体系、ByValue/ByPropertyNameによる型安全なパイプラインバインディング、データと表示を分離するフォーマッティングレイヤー——これらは単なる機能追加ではなく、シェルという概念のパラダイム転換だった。

2016年のオープンソース化とクロスプラットフォーム対応により、PowerShellはWindows専用のツールから「あらゆるシステムのためのシェル」へと変貌した。2026年1月にSnoverが引退した今、GitHubで5万以上のスターを集めるPowerShellは、20年の歴史を持つ成熟したプロジェクトだ。

第21回で語ったNushellは、PowerShellのオブジェクトパイプラインに直接インスピレーションを受けて生まれた。Yehuda KatzがPowerShellのデモをSophia Turnerに見せ、「この発想をUnixの世界に、関数型の方向で持ち込めないか」と問いかけたことが始まりだった。PowerShellの「テキストを捨てる」という判断が、10年以上の時を経て、Unix系の次世代シェルにも波及した。

冒頭の問いに戻ろう——テキストではなくオブジェクトを流すシェルは、何を変えたのか。

答えは「パースの苦痛を消し、データと表示を分離し、型安全なパイプラインを可能にした」だ。ただし、冗長性、起動速度、Unixツールチェーンとの統合の弱さという代償がある。PowerShellはUnixの置き換えではない。異なる世界の異なる最適解だ。

だが、Snoverが提起した問い——「テキストストリームは本当にパイプラインの最適な単位なのか」——は、いまだに有効だ。この問いは、Nushell、Oil/YSH、Elvishといった次世代シェルたちに受け継がれ、それぞれ異なる回答を模索し続けている。

### 次回予告

21回にわたって、私たちはシェルの歴史を辿ってきた。Thompson shellの最小限の対話から、Bourne shellのプログラミング言語化、cshの対話革命、kshの統合、POSIXの標準化、bashの覇権、そしてzsh、fish、Nushell、PowerShellまで。

次回は、この連載を通じて見えてきた「シェルの本質」を整理する。対話、自動化、システム接点——シェルの三つの軸で、50年の歴史を俯瞰し、各シェルがどこに位置するかを再評価する。

次回のテーマは「シェルの本質に立ち返る――対話・自動化・システム接点」。24年間シェルと共に歩んだキャリアの棚卸しを、率直に行いたい。

---

## 参考文献

- Jeffrey P. Snover, "Monad Manifesto", August 8, 2002 <https://www.jsnover.com/Docs/MonadManifesto.pdf>
- Jeffrey Snover's blog, "About Jeffrey Snover" <https://www.jsnover.com/blog/about-jeffrey-snover/>
- PowerShell Team Blog, "Monad Manifesto – the Origin of Windows PowerShell" <https://devblogs.microsoft.com/powershell/monad-manifesto-the-origin-of-windows-powershell/>
- PowerShell Team Blog, "It's a Wrap! Windows PowerShell 1.0 Released!", 2006 <https://devblogs.microsoft.com/powershell/its-a-wrap-windows-powershell-1-0-released/>
- Microsoft Windows Server Blog, "Monad's new name - Windows PowerShell", April 25, 2006 <https://www.microsoft.com/en-us/windows-server/blog/2006/04/25/monads-new-name-windows-powershell>
- Scott Hanselman, "Announcing PowerShell on Linux - PowerShell is Open Source!", 2016 <https://www.hanselman.com/blog/announcing-powershell-on-linux-powershell-is-open-source>
- Microsoft Learn, "about_Pipelines" <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7.5>
- Microsoft Learn, "Using Format commands to change output view" <https://learn.microsoft.com/en-us/powershell/scripting/samples/using-format-commands-to-change-output-view?view=powershell-7.5>
- Microsoft Learn, "Approved Verbs for PowerShell Commands" <https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.5>
- Microsoft Learn, "What's New in PowerShell 7.5" <https://learn.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-75?view=powershell-7.5>
- The Register, "PowerShell architect retires after decades at the prompt", January 22, 2026 <https://www.theregister.com/2026/01/22/powershell_snover_retires/>
- The New Stack, "Jeffrey Snover Remembers the Fight to Launch PowerShell" <https://thenewstack.io/jeffrey-snover-remembers-the-fight-to-launch-powershell/>
- CoRecursive Podcast, "Navigating Corporate Giants: Jeffrey Snover and the Making of PowerShell" <https://corecursive.com/building-powershell-with-jeffrey-snover/>
- Wikipedia, "PowerShell" <https://en.wikipedia.org/wiki/PowerShell>
- Wikipedia, "Jeffrey Snover" <https://en.wikipedia.org/wiki/Jeffrey_Snover>
- GitHub, PowerShell/PowerShell <https://github.com/PowerShell/PowerShell>
- Nushell公式ブログ, "Introducing nushell", 2019 <https://www.nushell.sh/blog/2019-08-23-introducing-nushell.html>
- The Changelog Podcast #363, "Nushell for the GitHub era" <https://changelog.com/podcast/363>
- The Monad Manifesto, Annotated <https://devops-collective-inc.gitbook.io/the-monad-manifesto-annotated/about-this-book>
