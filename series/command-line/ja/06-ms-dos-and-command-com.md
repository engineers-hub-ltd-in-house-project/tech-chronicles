# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第6回：MS-DOSとCOMMAND.COM――もうひとつのCLI系譜

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- CP/M（1974年, Gary Kildall）からMS-DOS（1981年）への系譜――パーソナルコンピュータのCLIがUNIXとは別の道を歩んだ経緯
- COMMAND.COMの設計――内部コマンドと外部コマンドの区分、バッチファイル、メモリ制約下での工夫
- UNIX CLIとDOS CLIの設計思想の根本的な違い――パス区切り文字、大文字小文字、ワイルドカード展開、パイプ実装
- MS-DOS 2.0（1983年）がUNIXから学んだことと、学べなかったこと
- cmd.exe（1993年, Windows NT）からPowerShell（2006年）への進化の道筋
- DOSBoxを使った実際のMS-DOS CLI環境の体験

---

## 1. UNIXだけがCLIではない

1990年代後半、私はUNIXの世界に足を踏み入れた。Slackware 3.5のbashプロンプトで`ls`、`cd`、`grep`を覚え、パイプでコマンドを繋ぎ、シェルスクリプトを書いた。UNIXのCLIは、私にとって「コマンドラインとはこういうものだ」という基準になった。

だが、それ以前の記憶がある。

Windows 95のDOS窓だ。`dir`と打てばファイル一覧が表示された。`cd`でディレクトリを移動した。`copy`でファイルをコピーした。UNIXを知る前の私にとって、それが「コマンドライン」だった。

UNIXのシェルに触れた後、改めてDOS窓を開いたとき、奇妙な違和感を覚えた。パイプ（`|`）は存在する。リダイレクション（`>`）もある。だが`grep`がない。`awk`がない。`sed`がない。パイプの先に繋げるツールが圧倒的に少ない。コマンドのオプションは`-`ではなく`/`で始まる。パスの区切りは`/`ではなく`\`だ。同じ「コマンドライン」のはずなのに、何かが根本的に違う。

当時の私はその違和感を「DOSはUNIXの劣化コピーだ」と片付けた。恥ずかしい話だ。UNIXの世界だけを正統と見なし、別の系譜を「劣った模倣」と断じた。

その認識は間違いだった。DOS/WindowsのCLIは、UNIXとは異なる制約の下で、異なる設計判断を積み重ねた結果だった。パスの区切りが`\`である理由にも、ワイルドカード展開がアプリケーション側で行われる理由にも、パイプが一時ファイルを経由する理由にも、それぞれの合理性がある。

UNIXだけがCLIの歴史ではない。WindowsのCLIはどのように進化したのか。そしてなぜ、UNIXのCLIとこれほどまでに異なる姿になったのか。答えは、1974年の海軍大学院にまで遡る。

---

## 2. CP/Mから始まるもうひとつの系譜

### Gary Kildallの発明

コマンドラインインターフェースの歴史を語るとき、多くの技術者はUNIXのシェル――Thompson shell、Bourne shell、C shell――から語り始める。だが、パーソナルコンピュータの世界では、まったく別の系譜が存在する。その起点にいるのがGary Kildallだ。

1974年、Naval Postgraduate School（海軍大学院）の教官だったGary Kildallは、Intel Intellec-8開発システム上でCP/M（Control Program for Microcomputers）の最初の動作プロトタイプを完成させた。Shugart Associates製の8インチフロッピーディスクドライブを接続し、マイクロプロセッサからディスクストレージにアクセスするためのオペレーティングシステムだった。Kildallはこのソフトウェアを、自ら設計したPL/M（Programming Language for Microcomputers）で記述した。

Kildallの発明は二つの層からなる。一つはBIOS（Basic Input Output System）――ハードウェアの差異を吸収する抽象化レイヤー。もう一つはCP/M本体――ディスクのファイル管理とユーザーインターフェースを提供するOS。この二層構造は、後にMS-DOSにそのまま継承される。

Kildallと妻のDorothyは「Intergalactic Digital Research」（後にDigital Research, Inc.に改名）を設立し、CP/Mを商業化した。1981年9月までに25万以上のライセンスが販売された。CP/Mはマイクロコンピュータ向けの最初の商用オペレーティングシステムとなり、1970年代後半から1980年代初頭にかけて、8ビットマイクロコンピュータの事実上の標準OSとなった。

### CCPの設計思想

CP/Mのコマンドインターフェースは**CCP（Console Command Processor）**と呼ばれた。ここにCP/M独自の設計思想が表れている。

CP/Mのメモリモデルは三層構造だった。最下位にBIOS、その上にBDOS（Basic Disk Operating System）、そして最上位にCCPが配置される。BIOSとBDOSはメモリ常駐だが、CCPは違った。アプリケーションの実行時、CCPはメモリから追い出される。64KBという限られたメモリ空間を、できる限りアプリケーションに使わせるためだ。アプリケーションが終了すると、CCPはディスクから自動的に再ロードされる。

```
CP/Mのメモリマップ（64KB空間）:

┌──────────────────────────────┐ 0xFFFF
│  BIOS                        │ ← ハードウェア抽象化（常駐）
├──────────────────────────────┤
│  BDOS                        │ ← ディスク/ファイル管理（常駐）
├──────────────────────────────┤
│  CCP                         │ ← コマンドプロセッサ
│  （アプリ実行時は上書きされる）│    （非常駐：アプリに明け渡す）
├──────────────────────────────┤
│                              │
│  TPA                         │ ← トランジェントプログラムエリア
│  （Transient Program Area）   │    （アプリケーション実行領域）
│                              │
├──────────────────────────────┤ 0x0100
│  システム予約（0x0000-0x00FF）│
└──────────────────────────────┘ 0x0000
```

CCPの内蔵コマンドは6つだけだった。`DIR`（ディレクトリ一覧）、`ERA`（ファイル削除）、`REN`（リネーム）、`SAVE`（メモリ内容をファイルに保存）、`TYPE`（ファイル内容の表示）、`USER`（ユーザー番号の切り替え）。それ以外の機能はすべて「トランジェントコマンド」として`.COM`拡張子のファイルでディスク上に存在した。`PIP.COM`（ファイルコピー）、`STAT.COM`（ファイル/ディスク情報の表示）などだ。

この「内蔵コマンド」と「トランジェントコマンド」の区分は、メモリ制約から生まれた必然的な設計だった。頻繁に使うコマンドだけをCCP内に組み込み、それ以外はディスクから必要に応じてロードする。UNIXのシェルとは異なる発想だ。UNIXでは、シェル自体がプロセスの一つであり、外部コマンドは別プロセスとしてfork/execで実行される。CP/Mには「プロセス」の概念がない。シングルタスクOSであり、メモリ上にはOSとアプリケーションが一つだけ存在する。

### IBMとの運命的な交差

1980年、IBMはパーソナルコンピュータ市場への参入を決めた。「Project Chess」と呼ばれたこの極秘プロジェクトのために、OSが必要だった。当時の8ビットPCの標準OSはCP/Mだった。IBMはまずDigital Researchを訪ねた。

この訪問をめぐる逸話は、コンピュータ史上最も有名な「もし」の一つとなった。「Gary Kildallは飛行機に乗りに行って、IBMとの会議をすっぽかした」という伝説だ。だが、この物語は大幅に歪曲されている。Kildallの友人Thomas Rolanderの証言によれば、Kildallはその朝に飛行していたが、午後の会議には出席した。交渉が決裂した本当の理由は、ライセンス条件の不一致だった。Digital ResearchはCP/Mを一括料金で提供することを拒んだ。既存の顧客との「最恵国待遇」契約が、IBMへの特別価格提供を不可能にしていたのだ。

IBMはMicrosoftに話を持ちかけた。Microsoftは当時、プログラミング言語（BASIC）の会社であり、OSは持っていなかった。だがBill Gatesは取引を逃さなかった。

### 86-DOSからMS-DOSへ

MicrosoftがIBMに提供したOSは、自社開発品ではなかった。

1980年4月、ワシントン州タクウィラにあるSeattle Computer Products（SCP）のエンジニア、Tim Patersonは、ある問題に直面していた。SCPは1979年11月からIntel 8086プロセッサボードを出荷していたが、8086用のOSがなかった。Digital ResearchはCP/Mの8086版（CP/M-86）を1979年11月にリリースすると発表していたが、その日程は何度も延期された。OSがなければ、ハードウェアは売れない。

Patersonは自らOSを書くことにした。CP/Mのルック&フィールを模倣し、8086プロセッサ向けに最適化したOS――QDOS（Quick and Dirty Operating System）だ。開発は1980年4月に始まり、7月にバージョン0.10が完成した。約4ヶ月の開発期間は、「Quick and Dirty」という名前に偽りがなかった。ただし、QDOSはCP/Mの単なるコピーではなかった。FAT12ファイルシステムの導入とディスクセクタバッファリングの改善という、独自の技術的改善が含まれていた。

Microsoftは1980年12月にSCPから86-DOS（QDOSの後継版）の非独占ライセンスを25,000ドルで取得した。1981年5月にはTim Patersonを雇用し、IBM PC（Intel 8088プロセッサ搭載）への移植作業を行わせた。1981年7月、Microsoftは86-DOSの全権利をSCPから50,000ドルで購入し、7月27日にMS-DOSと改名した。

1981年8月12日、IBMは初のパーソナルコンピュータIBM PC 5150を発表した。そのOSとして提供されたのがPC DOS 1.0――MS-DOSのIBMブランド版だった。PC DOS 1.0は、IBM PC向けの3つのOS選択肢の一つとして用意されたが（他の2つはCP/M-86とUCSD p-System）、最も低価格だったPC DOSが市場を制覇した。

```
パーソナルコンピュータCLIの系譜:

1974  CP/M (Gary Kildall, Digital Research)
        │ ← CCP: 内蔵コマンド + トランジェントコマンド
        │   ファイルシステム: FCB方式、8.3形式
        │
        ↓ 設計をクローン
1980  QDOS / 86-DOS (Tim Paterson, Seattle Computer Products)
        │ ← CP/M互換 + FAT12ファイルシステム
        │
        ↓ Microsoft買収
1981  MS-DOS 1.0 / PC DOS 1.0 (IBM PC)
        │ ← COMMAND.COM: CP/MのCCPを継承
        │
        ↓ UNIXの影響
1983  MS-DOS 2.0
        │ ← 階層的ディレクトリ、リダイレクション、パイプ
        │   パス区切りに \ を採用
        │
        ↓ 継続的改良
1993  cmd.exe (Windows NT 3.1, Therese Stowell)
        │ ← 32ビット化、コマンド拡張、履歴機能
        │
        ↓ 根本的な再設計
2006  PowerShell 1.0 (Jeffrey Snover)
        ← オブジェクトパイプライン、.NET統合
```

CP/MからMS-DOS、cmd.exe、PowerShellに至る系譜は、UNIXのシェル史とは完全に独立した進化の道筋だ。この二つの系譜は、異なる制約の下で、異なる設計判断を積み重ねてきた。

---

## 3. 二つのCLI文化の分岐点

### COMMAND.COMの設計

MS-DOSのコマンドインタプリタCOMMAND.COMは、CP/MのCCPの設計思想を直接継承している。内部コマンド（COMMAND.COMのバイナリに組み込まれたコマンド）と外部コマンド（ディスク上の`.COM`や`.EXE`ファイル）の区分は、CCPの「内蔵コマンド」と「トランジェントコマンド」の区分そのものだ。

COMMAND.COMの内部コマンドには、`DIR`、`COPY`、`DEL`、`REN`、`TYPE`、`CD`、`MD`、`RD`などが含まれる。これらはCOMMAND.COMが常にメモリ上に保持する常駐部分に組み込まれている。DOSも64KB〜640KBという限られたメモリ空間で動作するOSであり、頻繁に使うコマンドをメモリに常駐させ、ディスクアクセスのオーバーヘッドを避ける設計は合理的だった。

COMMAND.COMには対話モードとバッチモードの二つの動作モードがあった。対話モードではプロンプト（`C:\>`）を表示してユーザーの入力を待つ。バッチモードでは`.BAT`拡張子のテキストファイルからコマンドを逐次読み出して実行する。バッチファイルには`IF`、`GOTO`、`FOR`などの制御構文が用意されていた。

```bat
@ECHO OFF
REM MS-DOSバッチファイルの例
IF "%1"=="" GOTO USAGE
DIR %1 /B > FILELIST.TXT
FOR %%F IN (%1) DO ECHO Processing: %%F
GOTO END

:USAGE
ECHO Usage: PROCESS.BAT [filespec]

:END
```

`AUTOEXEC.BAT`は、DOSの起動時に自動実行されるバッチファイルだ。環境変数の設定、デバイスドライバの初期化、常駐プログラムのロードなど、システムの初期設定を記述する。UNIXにおける`.profile`や`.bashrc`に相当するが、シェルの設定ファイルではなくOSの起動スクリプトという位置づけだった。

### パス区切り文字：`\`の誕生

UNIXを知る者にとって、Windowsのパス区切り文字`\`は常に違和感の種だ。なぜ`/`ではないのか。この問いの答えは、1981年まで遡る。

MS-DOS 1.0は、コマンドオプションの指定にスラッシュ`/`を使用していた。たとえば`DIR /W`は横長表示、`DIR /P`はページ表示だ。この慣習はCP/Mからではなく、DEC（Digital Equipment Corporation）のOSに由来する。Microsoftの8080プロセッサ向けツール群――F80 FORTRANコンパイラ、M80マクロアセンブラなど――は、1977年以前から`/`をスイッチ文字として使用していた。Microsoft自身が「スラッシュのスイッチ文字はDECから来た」と述べている。

MS-DOS 2.0（1983年3月）でディレクトリ機能を導入する際、問題が発生した。パス区切り文字として`/`を使いたいところだが、`/`は既にスイッチ文字として使われている。`DIR /P`は「ページ表示」なのか「/Pというディレクトリの内容を表示」なのか、区別がつかない。

IBMはDOS 1.xとの互換性維持を強く要求した。既存のプログラムが`/`をスイッチ文字として使っている以上、`/`をパス区切りに転用することは許されない。Microsoftは代替文字を探し、視覚的に最も近い`\`（バックスラッシュ）を選択した。

```
パス区切り文字の分岐:

UNIXの世界:
  /usr/local/bin/grep
  ↑ Multics由来（1960年代）

DOSの世界:
  C:\DOS\COMMAND.COM
  ↑ / がスイッチ文字として先約されていたため
    視覚的に近い \ を採用（1983年, MS-DOS 2.0）

スイッチ文字の系譜:
  DEC OS → Microsoft 8080ツール (1977年以前) → MS-DOS 1.0 (1981年)
  dir /w    copy /v    format /s
  ↑ UNIXの -w, --width とは異なる伝統
```

この設計判断は、40年以上経った今も影響を及ぼしている。Webの世界ではURL（`https://example.com/path/to/page`）が`/`を使う。UNIXの文化から来たプログラマは`/`が「正しい」と感じ、Windowsの`\`は「間違い」に見える。だが歴史的経緯を知れば、それは「間違い」ではなく「別の合理的選択」だったことがわかる。

### ワイルドカード展開：誰の仕事か

UNIXとDOS/Windowsの間で、見過ごされがちだが根本的に異なる設計判断がもう一つある。ワイルドカード（`*`や`?`）の展開をどこで行うか、という問題だ。

UNIXでは、シェルがワイルドカードを展開する。`ls *.txt`と入力すると、シェルは`*.txt`にマッチするすべてのファイル名をリストアップし、`ls file1.txt file2.txt file3.txt`として`ls`コマンドに渡す。`ls`コマンド自身はワイルドカードの展開を一切行わない。展開はシェルの仕事だ。

DOSおよびWindowsでは、この責任がアプリケーション側にある。COMMAND.COMはワイルドカードを展開せず、`*.txt`という文字列をそのままプログラムに渡す。プログラムが自らワイルドカードを解釈し、マッチするファイルを探す。C言語のランタイムライブラリがこの展開を補助する場合もあるが、原則としてプログラムの責任だ。

```
ワイルドカード展開の責任:

UNIX:
  ユーザー入力: ls *.txt
        ↓
  シェルが展開: ls file1.txt file2.txt file3.txt
        ↓
  lsコマンド: argv[1]="file1.txt", argv[2]="file2.txt", ...
  → lsはワイルドカードの存在を知らない

DOS/Windows:
  ユーザー入力: DIR *.TXT
        ↓
  COMMAND.COM: DIRに "*.TXT" をそのまま渡す
        ↓
  DIRコマンド: 自分で *.TXT にマッチするファイルを検索
  → アプリケーションがワイルドカードを解釈する
```

この差異にはトレードオフがある。UNIX方式は一貫性が高い。どのコマンドに対しても、シェルが同じルールでワイルドカードを展開する。プログラマはargvに入ってくるのが常に展開済みのファイル名であることを前提にコードを書ける。一方で、プログラムがワイルドカードを独自に解釈したい場合（たとえばリモートサーバ上のファイルに対するパターンマッチ）には制約となる。

DOS/Windows方式は柔軟性が高い。プログラムは引数に`*`が含まれるかどうかを自分で判断し、適切に処理できる。だが、プログラムごとにワイルドカードの挙動が異なりうるという問題がある。あるプログラムは`?`を「任意の1文字」と解釈し、別のプログラムは無視するかもしれない。

### パイプ：一時ファイルという妥協

MS-DOS 2.0（1983年3月）は、UNIXの影響を強く受けた。階層的ディレクトリ構造、ファイルハンドル、リダイレクション、そしてパイプが導入された。だが、パイプの実装はUNIXとは根本的に異なるものだった。

UNIXのパイプは、カーネルが管理するメモリバッファを介して二つのプロセスを接続する。`cmd1 | cmd2`と書くと、`cmd1`と`cmd2`は同時に実行され、`cmd1`の標準出力が`cmd2`の標準入力にリアルタイムに流れ込む。これはマルチタスクOSだからこそ可能な実装だ。

MS-DOSはシングルタスクOSだった。二つのプログラムを同時に実行することができない。したがって、DOSのパイプは次のように実装された。

1. `cmd1`を実行し、その標準出力を一時ファイルに書き出す
2. `cmd1`が終了したら、`cmd2`を実行し、一時ファイルを標準入力として読み込ませる
3. 一時ファイルを削除する

```
パイプの実装比較:

UNIX（マルチタスク）:
  cmd1 | cmd2

  cmd1 ─── カーネルバッファ ─── cmd2
  (同時に実行、データがリアルタイムに流れる)

MS-DOS（シングルタスク）:
  cmd1 | cmd2

  Step 1: cmd1 → 出力 → 一時ファイル (cmd1終了)
  Step 2: 一時ファイル → 入力 → cmd2 (cmd2終了)
  Step 3: 一時ファイル削除

  (逐次実行、ディスクI/Oを経由)
```

この違いは、単なる実装の差異ではなく、根本的なアーキテクチャの帰結だ。UNIXはマルチプロセス・マルチタスクを前提に設計された。パイプはプロセス間通信のメカニズムであり、OSの中核機能だ。一方、DOSは「一度に一つのプログラムだけ」という設計で始まった。パイプはUNIXからの借用概念であり、シングルタスクの制約の中で「形だけ」再現したものだった。

実用上の差異もあった。UNIXのパイプではストリーミング処理が可能だ。巨大なログファイルをパイプで処理する場合、データはメモリバッファを通じて少しずつ流れる。ファイル全体をメモリに載せる必要はない。DOSのパイプでは、最初のコマンドの出力がすべて一時ファイルに書き出されるまで、次のコマンドは開始されない。大きなデータを処理する場合、一時ファイルのためのディスク容量が必要になる。

### 大文字小文字の区別

もう一つの根本的な違いが、ファイル名の大文字小文字の扱いだ。

UNIXのファイルシステムはケースセンシティブだ。`README`と`readme`と`Readme`は三つの別々のファイルとして共存できる。

CP/MおよびMS-DOSのFAT（File Allocation Table）ファイルシステムはケースインセンシティブだった。さらに、FAT12/FAT16ではファイル名が大文字に変換されて格納された。ユーザーが`readme.txt`と入力しても、ディスク上には`README.TXT`として記録される。ファイル名は8文字+拡張子3文字の「8.3形式」に制限されていた。

```
ファイル名の扱いの違い:

UNIX:
  $ ls
  README.md  readme.txt  Readme.doc
  → 3つの別々のファイルとして共存可能
  → ケースセンシティブ

MS-DOS:
  C:\>DIR
  README  TXT    1,234  1995-01-15
  → readme.txt も Readme.Txt も同じファイル
  → FAT12/FAT16は大文字に変換して格納
  → ケースインセンシティブ、ケース非保存

Windows 95 (VFAT):
  → ロングファイルネーム対応（255文字）
  → ケースインセンシティブだがケース保存
  → 内部的に8.3形式のエイリアスも保持
```

この設計差異も、時代の制約から生まれたものだ。CP/Mは64KBのメモリと8インチフロッピーディスクで動作するOSだった。ファイル名の比較処理を大文字に統一することで、単純化と効率化を図った。UNIXはミニコンピュータ上で動作し、より豊富なリソースを前提としていたため、ケースセンシティブという「正確だがコストの高い」設計を採用できた。

---

## 4. MS-DOSからWindows、そしてPowerShellへ

### MS-DOS 2.0：UNIXに学んだ世代

MS-DOS 2.0（1983年3月）は、DOS/Windows CLIの歴史における分水嶺だった。IBM PC/XT向けに開発されたこのバージョンは、UNIXから多くの機能を借用した。

階層的ディレクトリ構造が導入された。MS-DOS 1.xはCP/Mと同様、フラットなファイルシステムだった。ディレクトリの概念がなく、ディスク上のすべてのファイルが一つの名前空間に並んでいた。ハードディスク（IBM PC/XTは10MBの固定ディスクを搭載）が登場し、数百のファイルを一つの場所に置くことが非現実的になったとき、Microsoftは二つの選択肢を検討した。CP/M方式の「ディスクを複数の論理ドライブに分割する」アプローチと、UNIX方式の「階層的ディレクトリ構造」だ。Microsoftは後者を選んだ。ディレクトリ構造はスケーラブルであり、パーティション分割には限界があった。

ファイルハンドルも導入された。MS-DOS 1.xではCP/Mから継承したFCB（File Control Block）方式でファイルを管理していた。MS-DOS 2.0では、UNIXスタイルのハンドルベースのファイル管理が追加された。ファイル名でファイルを開き、以降の操作はすべてファイルハンドル（整数値）を通じて行う。stdin、stdout、stderrという標準入出力の概念もこの時に導入された。

リダイレクション（`>`、`>>`、`<`）とパイプ（`|`）もMS-DOS 2.0で追加された。ただし前述の通り、パイプは一時ファイルを経由する実装だった。

興味深いのは、MicrosoftがこのUNIX的機能を導入した背景だ。Microsoftは当時、Xenixという自社のUNIX系OSも販売していた。1983年にByte誌が「Xenixはマルチユーザー版MS-DOSの未来だ」と評したように、Microsoftの戦略はMS-DOSを段階的にXenixに近づけ、最終的にシングルユーザーXenixと区別がつかないレベルにすることだった。マルチユーザー機能はXenixの差別化ポイントとして意図的に省かれた。

### cmd.exe：32ビットの世界へ

1993年、Windows NT 3.1の登場とともにcmd.exeがリリースされた。Therese Stowellが開発したこの32ビットコマンドプロセッサは、16ビットのCOMMAND.COMの後継として設計された。

cmd.exeは、COMMAND.COMとの互換性を維持しながら、いくつかの重要な改良を加えた。`IF`、`SET`、`FOR`コマンドの拡張、遅延環境変数展開（`!変数!`構文）、コマンド履歴（矢印キーでアクセス）、自動パス補完（Tabキー）などだ。

だがcmd.exeの基本設計は、依然としてCOMMAND.COMの延長線上にあった。テキストベースのパイプ、`.BAT`バッチファイルによるスクリプティング、`/`スイッチによるオプション指定。1970年代のCP/Mから受け継いだ設計思想が、1990年代の32ビットOSの上でもそのまま動いていた。

### Windows Script Host：過渡期のスクリプティング

1998年、MicrosoftはWindows 98とともにWindows Script Host（WSH）を提供した。VBScriptとJScriptによるスクリプティング環境だ。`cscript.exe`（コマンドライン）と`wscript.exe`（GUI）の二つのインターフェースを持ち、COMオブジェクトを操作してWindowsのシステム管理を自動化できた。

WSHはDOSのバッチファイルの限界を超えるために生まれた。バッチファイルの制御構文は貧弱で、文字列処理も算術演算も困難だった。WSHはその問題をVBScript/JScriptという高水準言語で解決した。だが、WSHはコマンドラインツールとの統合が弱かった。パイプに組み込むことが難しく、UNIXのシェルスクリプトのように「小さなツールを組み合わせる」使い方には向いていなかった。

### PowerShell：テキストパイプラインへの異議

2002年8月、MicrosoftのJeffrey Snoverは「Monad Manifesto」と題する白書を発表した。この文書は、UNIXのテキストパイプラインに対する根本的な批判を含んでいた。

Snoverの主張はこうだ。UNIXのパイプはテキストストリームを流す。`ps aux | grep nginx | awk '{print $2}'`のようなパイプラインは、テキストの「見た目」に依存する。列の位置が変わればawkのフィールド番号を修正しなければならない。出力形式の変更がパイプラインを壊す。テキストは「ユニバーサルインターフェース」であると同時に、「スキーマレスデータ」でもある。構造化されていないテキストをパースする脆弱性が、UNIXパイプラインの本質的な弱点だ。

Snoverの解決策は、テキストの代わりに.NETオブジェクトをパイプラインに流すことだった。`Get-Process | Where-Object {$_.CPU -gt 100} | Select-Object Name, CPU`――各コマンド（PowerShellでは「コマンドレット」）はオブジェクトを受け取り、オブジェクトを出力する。プロパティ名でデータにアクセスするため、出力形式の変更に影響されない。

```
テキストパイプライン vs オブジェクトパイプライン:

UNIX (bash):
  $ ps aux | grep nginx | awk '{print $2}'
  → テキスト出力をgrepで絞り込み、awkで2列目を抽出
  → 列の位置が変わると壊れる
  → 出力フォーマットに依存

PowerShell:
  PS> Get-Process -Name nginx | Select-Object -Property Id
  → プロセスオブジェクトをパイプラインに流す
  → プロパティ名(Id)でアクセス
  → 表示フォーマットに依存しない
```

2003年10月のProfessional Development Conferenceで初の公開デモが行われ、2006年4月25日にMonadからWindows PowerShellに改名。2006年11月14日にPowerShell 1.0が正式リリースされた。

PowerShellの設計は、DOSのCLI系譜がUNIXのCLIに対して長年抱えていた劣等感を、根本からひっくり返す試みだった。テキストストリームを真似るのではなく、テキストストリームの限界を指摘し、新しいパラダイムを提案した。それが成功したかどうかは、本連載の第20回で詳しく議論する。

---

## 5. ハンズオン：DOS CLIを体験する

DOSのCLI環境を実際に触り、UNIXとの違いを体感しよう。ここではDOSBox（オープンソースのDOSエミュレータ、2002年リリース）を使用する。

### 演習1：DOSの基本操作とUNIXとの比較

```bash
# Docker環境でDOSBoxをインストールして実行
docker run --rm -it ubuntu:24.04 bash -c '
echo "=============================================="
echo "[演習1] DOS CLIとUNIX CLIの対照表"
echo "=============================================="
echo ""
echo "DOS/Windowsの世界に実際に触れる前に、"
echo "まずコマンドの対応関係を整理する。"
echo ""
echo "┌───────────────────┬──────────────────┬───────────────────┐"
echo "│ 操作              │ DOS/cmd.exe      │ UNIX/bash         │"
echo "├───────────────────┼──────────────────┼───────────────────┤"
echo "│ ファイル一覧      │ DIR              │ ls                │"
echo "│ ディレクトリ移動  │ CD               │ cd                │"
echo "│ ファイルコピー    │ COPY             │ cp                │"
echo "│ ファイル移動      │ MOVE             │ mv                │"
echo "│ ファイル削除      │ DEL              │ rm                │"
echo "│ ファイル内容表示  │ TYPE             │ cat               │"
echo "│ ディレクトリ作成  │ MD (MKDIR)       │ mkdir             │"
echo "│ ディレクトリ削除  │ RD (RMDIR)       │ rmdir             │"
echo "│ 画面クリア        │ CLS              │ clear             │"
echo "│ テキスト検索      │ FIND             │ grep              │"
echo "│ ファイル検索      │ (なし)           │ find              │"
echo "│ パス区切り        │ \\                │ /                 │"
echo "│ オプション指定    │ /スイッチ        │ -フラグ           │"
echo "│ 環境変数参照      │ %VAR%            │ \$VAR             │"
echo "│ ワイルドカード展開│ アプリ側         │ シェル側          │"
echo "│ パイプ実装        │ 一時ファイル経由 │ カーネルバッファ  │"
echo "│ 大文字小文字      │ 区別しない       │ 区別する          │"
echo "└───────────────────┴──────────────────┴───────────────────┘"
echo ""
echo "コマンド名の類似性は高い。DIR/ls、COPY/cp、DEL/rm。"
echo "だが設計思想の違いは表面的な類似の下に隠れている。"
echo ""
echo "=============================================="
'
```

### 演習2：cmd.exeの機能とUNIXシェルの比較

```bash
# cmd.exeとbashの設計差異を実際に確認する
docker run --rm -it ubuntu:24.04 bash -c '
echo "=============================================="
echo "[演習2] パイプとリダイレクションの違いを実感する"
echo "=============================================="
echo ""

# テスト用ファイルを作成
mkdir -p /tmp/dos-handson
cd /tmp/dos-handson

for i in $(seq 1 20); do
    echo "Line $i: server-$(printf "%02d" $i) status=$([ $((i % 3)) -eq 0 ] && echo ERROR || echo OK) cpu=$((RANDOM % 100))" >> server.log
done

echo "--- 1. UNIXパイプライン: 真のストリーミング ---"
echo ""
echo "  コマンド: cat server.log | grep ERROR | wc -l"
echo "  結果: $(cat /tmp/dos-handson/server.log | grep ERROR | wc -l)"
echo ""
echo "  UNIXでは3つのプロセスが同時に起動し、"
echo "  データがカーネルバッファを通じてリアルタイムに流れる。"
echo ""
echo "  確認: /proc にパイプのファイルディスクリプタが見える"
echo "  $ ls -la /proc/self/fd/"
ls -la /proc/self/fd/ 2>/dev/null | head -5
echo "  ..."
echo ""

echo "--- 2. DOSパイプのシミュレーション: 一時ファイル方式 ---"
echo ""
echo "  DOSの \"cmd1 | cmd2\" は内部的に以下と等価:"
echo ""
echo "  Step 1: cmd1 > %TEMP%\\pipe001.tmp"
cat /tmp/dos-handson/server.log > /tmp/dos-handson/pipe001.tmp
echo "          → 一時ファイルに書き出し ($(wc -c < /tmp/dos-handson/pipe001.tmp) bytes)"
echo ""
echo "  Step 2: cmd2 < %TEMP%\\pipe001.tmp"
RESULT=$(grep ERROR < /tmp/dos-handson/pipe001.tmp | wc -l)
echo "          → 一時ファイルから読み込み (結果: $RESULT 行)"
echo ""
echo "  Step 3: DEL %TEMP%\\pipe001.tmp"
rm /tmp/dos-handson/pipe001.tmp
echo "          → 一時ファイル削除"
echo ""
echo "  → 結果は同じだが、DOS方式ではcmd1が完全に終了するまで"
echo "    cmd2は実行を開始できない。巨大なデータでは"
echo "    一時ファイルのディスク容量も必要になる。"
echo ""

echo "--- 3. ワイルドカード展開の違い ---"
echo ""

# テスト用ファイル作成
touch /tmp/dos-handson/report-jan.txt
touch /tmp/dos-handson/report-feb.txt
touch /tmp/dos-handson/report-mar.txt
touch /tmp/dos-handson/data.csv

echo "  UNIXでの展開（シェルが行う）:"
echo "  $ echo /tmp/dos-handson/report-*.txt"
echo "  $(echo /tmp/dos-handson/report-*.txt)"
echo ""
echo "  シェルが *.txt を展開してから echo に渡している。"
echo "  echoコマンド自体はワイルドカードを知らない。"
echo ""
echo "  確認: 引数の数を数えるスクリプト"

count_args() {
    echo "  引数の数: $#"
    for arg in "$@"; do
        echo "    - $arg"
    done
}

echo "  $ count_args /tmp/dos-handson/report-*.txt"
count_args /tmp/dos-handson/report-*.txt
echo ""
echo "  → シェルが3つのファイル名に展開してから関数に渡した"
echo ""
echo "  DOS/Windowsでは:"
echo "  C:\\> PROGRAM *.TXT"
echo "  → PROGRAMは引数として \"*.TXT\" という文字列を受け取る"
echo "  → プログラム自身がFindFirstFile/FindNextFileで展開する"
echo ""

# クリーンアップ
rm -rf /tmp/dos-handson

echo "=============================================="
'
```

### 演習3：cmd.exeとPowerShellの設計差異

```bash
# cmd.exeバッチとPowerShellの設計思想の違いを示す
docker run --rm -it ubuntu:24.04 bash -c '
echo "=============================================="
echo "[演習3] バッチファイル vs シェルスクリプト"
echo "=============================================="
echo ""
echo "同じタスク「ログファイルからERRORを含む行を抽出し、"
echo "出現回数をカウントする」を3つの方法で書く。"
echo ""

# テスト用ログ作成
mkdir -p /tmp/handson
cat > /tmp/handson/app.log << LOGEOF
2025-01-15 10:00:01 INFO  Server started on port 8080
2025-01-15 10:00:15 ERROR Connection refused: db-primary
2025-01-15 10:01:02 INFO  Request processed: /api/users
2025-01-15 10:01:45 ERROR Timeout: cache-server (5000ms)
2025-01-15 10:02:00 WARN  High memory usage: 85%
2025-01-15 10:02:30 ERROR Connection refused: db-primary
2025-01-15 10:03:00 INFO  Request processed: /api/orders
2025-01-15 10:03:15 ERROR Disk space low: /var/log (92%)
2025-01-15 10:04:00 INFO  Backup completed
2025-01-15 10:04:30 ERROR Connection refused: db-replica
LOGEOF

echo "--- 方法1: DOSバッチファイル (.BAT) ---"
echo ""
cat << '"'"'BATEOF'"'"'
@ECHO OFF
REM ERROR行のカウント（DOSバッチ）
SET COUNT=0
FOR /F "tokens=*" %%L IN ('"'"'FIND /C "ERROR" app.log'"'"') DO SET COUNT=%%L
ECHO Error count: %COUNT%
REM → FIND /C は行数を返すが、出力形式のパースが必要
REM → 文字列処理が非常に困難
BATEOF
echo ""

echo "--- 方法2: UNIX シェルスクリプト (bash) ---"
echo ""
echo "  grep -c ERROR /tmp/handson/app.log"
echo "  結果: $(grep -c ERROR /tmp/handson/app.log)"
echo ""
echo "  エラー種別ごとの集計:"
echo "  grep ERROR /tmp/handson/app.log | awk '\''{print \$4}'\'' | sort | uniq -c | sort -rn"
grep ERROR /tmp/handson/app.log | awk "{print \$4}" | sort | uniq -c | sort -rn | sed "s/^/  /"
echo ""
echo "  → パイプで小さなツールを連結して一行で実現"
echo ""

echo "--- 方法3: PowerShell（構文の紹介）---"
echo ""
cat << '"'"'PSEOF'"'"'
  # PowerShellの場合:
  Get-Content app.log |
    Where-Object { $_ -match "ERROR" } |
    Group-Object { ($_ -split "\s+")[3] } |
    Sort-Object Count -Descending |
    Format-Table Count, Name

  # → オブジェクトパイプラインでテキストのパースを最小化
  # → Where-Object: フィルタ（grepに相当）
  # → Group-Object: グルーピング（sort | uniq -cに相当）
  # → プロパティ名でアクセスするため、列位置に依存しない
PSEOF
echo ""

echo "--- 設計思想の比較 ---"
echo ""
echo "  DOSバッチ:  テキスト処理能力が貧弱。"
echo "              複雑な処理には外部ツールが必要。"
echo "              FIND, SORT程度しか標準提供されない。"
echo ""
echo "  UNIXシェル: 豊富なテキスト処理ツール群。"
echo "              パイプで組み合わせて強力な処理を実現。"
echo "              だがテキストの「見た目」に依存する。"
echo ""
echo "  PowerShell: オブジェクトを流すパイプライン。"
echo "              型情報を保持するためパースの脆弱性がない。"
echo "              だが冗長で、即興的なワンライナーには不向き。"
echo ""

rm -rf /tmp/handson
echo "=============================================="
'
```

これらの演習で確認したように、DOS/WindowsのCLIとUNIXのCLIは、表面的にはよく似ている。ディレクトリを移動し、ファイルを一覧し、コピーし、削除する。だが設計思想のレベルでは根本的に異なる。パイプの実装、ワイルドカード展開の責任、パス区切り文字、大文字小文字の扱い。これらの違いは、偶然の産物ではなく、それぞれのOSが置かれた制約と、その制約の中での合理的な設計判断の結果だ。

---

## 6. まとめと次回予告

### この回の要点

第一に、パーソナルコンピュータのCLIはUNIXとは独立した系譜を持つ。Gary Kildallが1974年に開発したCP/Mから始まり、86-DOS（1980年, Tim Paterson）、MS-DOS 1.0（1981年）、MS-DOS 2.0（1983年）、cmd.exe（1993年, Windows NT）、PowerShell（2006年）へと進化した。この系譜はUNIXシェルの歴史と並走しながらも、異なる設計判断を積み重ねてきた。

第二に、CP/MのCCP（Console Command Processor）が確立した「内蔵コマンドとトランジェントコマンドの区分」は、64KBという限られたメモリ空間での合理的な設計だった。この設計はCOMMAND.COMに直接継承された。

第三に、UNIX CLIとDOS CLIの設計差異は、それぞれのOSの制約から生まれた。パス区切りの`\`はスイッチ文字`/`との衝突を避けるためだった。ワイルドカード展開がアプリケーション側で行われるのは、シングルタスクOSの設計に起因する。パイプが一時ファイル経由なのは、マルチタスク機能の不在が理由だった。

第四に、MS-DOS 2.0（1983年3月）はUNIXから多くを学んだ。階層的ディレクトリ構造、ファイルハンドル、リダイレクション。だが、マルチタスクという前提条件の不在が、パイプをはじめとする機能の実装に根本的な制約を課した。

第五に、PowerShell（2006年）はUNIXのテキストパイプラインに対する構造的な批判から生まれた。Jeffrey Snoverの「Monad Manifesto」（2002年）は、テキストストリームの限界を指摘し、.NETオブジェクトをパイプラインに流すという新しいパラダイムを提案した。

### 冒頭の問いへの暫定回答

UNIXだけがCLIの歴史ではない。WindowsのCLIはどのように進化したのか。

暫定的な答えはこうだ。**DOS/WindowsのCLIは、UNIXとは異なる制約――シングルタスク、限られたメモリ、既存のスイッチ文字慣習――の下で、独自の設計判断を積み重ねて進化した。** それはUNIXの劣化コピーではなく、別の歴史と別の合理性を持つもうひとつのCLI文化だった。そして2006年のPowerShellは、UNIXのテキストパイプラインに対する最も知的に誠実な批判と代替案を提示した。

CLIの歴史は「UNIX一本道」ではない。異なる設計判断が異なるCLI文化を生んだ。どちらが「正しい」かではなく、それぞれの設計判断がどのような制約の中で、どのような問題を解決しようとしたのかを理解すること。それが、ツールを「使える」だけでなく「選べる」エンジニアになるための第一歩だ。

### 次回予告

次回、第7回「パイプの発明――1973年1月のコンピュータサイエンス史」では、UNIXの世界に戻り、CLIの最も強力な抽象であるパイプの誕生を語る。Doug McIlroyの1964年のメモ、Ken Thompsonによる一夜の実装、そして「小さなプログラムを組み合わせる」という思想がどのようにして生まれたのか。

`cat access.log | grep 404 | awk '{print $7}' | sort | uniq -c | sort -rn | head -20`――このワンライナーが「魔法」ではなく「設計思想の結実」であることを、あなたは次回知ることになる。

---

## 参考文献

- IEEE, "Milestones: The CP/M Microcomputer Operating System, 1974", <https://ethw.org/Milestones:The_CP/M_Microcomputer_Operating_System,_1974>
- Computer History Museum, "Gary Kildall and the 40th Anniversary of the Birth of the PC Operating System", <https://computerhistory.org/blog/gary-kildall-40th-anniversary-of-the-birth-of-the-pc-operating-system/>
- Wikipedia, "86-DOS", <https://en.wikipedia.org/wiki/86-DOS>
- Wikipedia, "Tim Paterson", <https://en.wikipedia.org/wiki/Tim_Paterson>
- Wikipedia, "MS-DOS", <https://en.wikipedia.org/wiki/MS-DOS>
- Computer History Museum, "Microsoft MS-DOS Early Source Code", <https://computerhistory.org/blog/microsoft-ms-dos-early-source-code/>
- OS/2 Museum, "Why Does Windows Really Use Backslash as Path Separator?", <https://www.os2museum.com/wp/why-does-windows-really-use-backslash-as-path-separator/>
- OS/2 Museum, "DOS 2.0 and 2.1", <https://www.os2museum.com/wp/dos/dos-2-0-and-2-1/>
- Wikipedia, "COMMAND.COM", <https://en.wikipedia.org/wiki/COMMAND.COM>
- Wikipedia, "cmd.exe", <https://en.wikipedia.org/wiki/Cmd.exe>
- Wikipedia, "PowerShell", <https://en.wikipedia.org/wiki/PowerShell>
- Microsoft DevBlogs, "It's a Wrap! Windows PowerShell 1.0 Released!", <https://devblogs.microsoft.com/powershell/its-a-wrap-windows-powershell-1-0-released/>
- Wikipedia, "CP/M", <https://en.wikipedia.org/wiki/CP/M>
- CP/M 2.2 Manual, "Section 1: CP/M Features and Facilities", <http://www.gaby.de/cpm/manuals/archive/cpm22htm/ch1.htm>
- Wikipedia, "Glob (programming)", <https://en.wikipedia.org/wiki/Glob_(programming)>
- Wikipedia, "8.3 filename", <https://en.wikipedia.org/wiki/8.3_filename>
- Wikipedia, "Windows Script Host", <https://en.wikipedia.org/wiki/Windows_Script_Host>
- Wikipedia, "DOSBox", <https://en.wikipedia.org/wiki/DOSBox>

---

**次回：** 第7回「パイプの発明――1973年1月のコンピュータサイエンス史」

---

_本記事は「ターミナルは遺物か――コマンドラインの本質を問い直す」連載の第6回です。_
_ライセンス：CC BY-SA 4.0_
