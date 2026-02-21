# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第15回：Plan 9の夢――UNIXの先にあったもの

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Plan 9 from Bell Labsが1980年代後半にUNIXの創造者たち自身によって設計された経緯と、UNIXの何が不満だったのか
- 「Everything is a file」を文字通り実践した9Pプロトコルの設計思想と、ネットワーク・プロセス・ウィンドウをファイルとして扱う仕組み
- per-process namespaces（プロセスごとの名前空間）がもたらす強力な抽象化
- UTF-8が1992年9月2日、New Jerseyのダイナーで発明された経緯
- rcシェルがBourne shellのどの問題を解決しようとしたか
- Plan 9が商業的に成功しなかった理由と、その思想が現代技術（Linux /proc、namespaces、FUSE、Docker、WSL）に与えた影響
- 9front（Plan 9の現代フォーク）を使ったPlan 9の体験方法

---

## 1. UNIXを作った人間がUNIXに不満を持つとき

2010年代の半ば、私はPlan 9 from Bell Labsのドキュメントを読み始めた。きっかけは些細なことだった。UTF-8の歴史を調べていて、それがPlan 9というオペレーティングシステムの中で生まれたという記述に行き当たったのだ。

UTF-8。現在のWeb、現在のOS、現在のプログラミング言語がほぼ例外なく採用している文字エンコーディング。あなたがこの文章を読んでいるブラウザも、UTF-8でこの日本語を解釈している。その基盤技術が、聞いたこともないOSから来ているのか。

ドキュメントを読み進めるうちに、知的な興奮が湧いてきた。Plan 9は、UNIXの「次」として設計されたオペレーティングシステムだった。しかも、設計者はUNIXそのものを作った人間たちだ。Ken Thompson。Rob Pike。Dennis Ritchie。UNIXを生み出したBell Labsの研究者たちが、自分たちの作品に不満を持ち、その不満を解消するために新しいOSを設計した。

「Everything is a file」――UNIXの有名な設計原則がある。ファイル、ディレクトリ、デバイス、パイプ。これらをすべてファイルとして統一的に扱うことで、同じインターフェース（open, read, write, close）で多様なリソースにアクセスできる。この連載の第7回で語ったパイプの設計にも、この思想が息づいていた。

だが、UNIXは自らの原則に忠実ではなかった。ネットワーク接続はファイルではない。Berkeley socket APIという独自のシステムコールで操作する。プロセスの制御もファイルではない。kill、wait、ptrace、ioctlという専用のシステムコールが必要だ。ウィンドウシステムは言うまでもない。X Window Systemは「Everything is a file」の対極にある複雑な通信プロトコルだ。

Plan 9の設計者たちは、この矛盾を正面から解決しようとした。ネットワークもファイルにする。プロセスもファイルにする。ウィンドウもファイルにする。文字通り、すべてをファイルにする。その徹底ぶりは、UNIXの設計者自身がUNIXの不徹底を最も深く理解していたことの証だ。

あなたは、UNIXの創造者たちがUNIXの何に不満だったのか、考えたことがあるだろうか。

---

## 2. Plan 9の誕生――UNIXの後継を目指して

### Bell Labsの次の一手

1980年代後半、Bell LabsのComputing Science Research Centerで、新しいオペレーティングシステムの研究が始まった。コードネームはPlan 9 from Bell Labs。名前の由来はEd Woodの1959年の低予算SF映画『Plan 9 from Outer Space』だ。史上最悪の映画と評されるこのB級作品の名を、最先端のOS研究に冠したのは、Bell Labsらしいユーモアだった。

プロジェクトを率いたのは、Rob Pike、Ken Thompson、Dave Presotto、Phil Winterbottomの四人。Dennis Ritchieが研究部門長として支援した。この顔ぶれを見てほしい。Ken ThompsonはUNIXの共同設計者であり、C言語の前身であるB言語の設計者だ。Rob PikeはUNIXのテキストエディタsamの作者であり、後にGoプログラミング言語の共同設計者となる人物だ。Dennis RitchieはC言語の設計者であり、UNIXのもう一人の共同設計者だ。UNIXを作った人間たちが、UNIXの後継を設計しようとしていた。

Plan 9は内部で数年間使われた後、1992年に第1版が大学向けにリリースされた。1995年に第2版が書籍とCD-ROM形式で公開された。2000年6月に第3版がインターネット上で無料公開され、2002年4月に第4版がLucent Public License 1.02で公開された。2021年3月23日、Plan 9のコピーライトはBell LabsからPlan 9 Foundationに移管され、MITライセンスで再リリースされた。

### UNIXの何が不満だったのか

UNIXが1970年代に設計されたとき、コンピュータは単体で動くものだった。一台のマシンに一つのファイルシステム、一つのプロセス空間、一つの端末。ネットワークは後から追加された要素だ。Berkeley socket APIがBSD 4.2に導入されたのは1983年のことであり、UNIXの初期設計には存在しなかった。

この「後付け」が、UNIXの設計に歪みをもたらした。「Everything is a file」と言いながら、ネットワーク接続はファイルではない。socket()、connect()、bind()、listen()、accept()という独自のシステムコールが必要だ。ファイルシステムのopen/read/write/closeという統一的なインターフェースからはみ出している。

Plan 9の設計者たちは、UNIXの問題を三つの観点から整理した。

第一に、「Everything is a file」の不徹底。ネットワーク、グラフィックス、プロセス制御が、ファイルインターフェースの外に存在している。結果として、ioctl（入出力制御）という汎用的だが非構造的なシステムコールが肥大化した。ioctlは「ファイルインターフェースでは表現できない操作のゴミ捨て場」と化していた。

第二に、分散環境への未対応。UNIXは一台のマシンで動くことを前提に設計されている。NFSやRFSなどのリモートファイルシステムが後から追加されたが、それらはカーネルの特別なサブシステムであり、一般のアプリケーションが透過的にネットワークリソースを扱えるものではなかった。

第三に、名前空間のグローバル性。UNIXではファイルシステムの名前空間はすべてのプロセスで共有される。あるプロセスが`/tmp`にファイルを作れば、すべてのプロセスからそのファイルが見える。これは単純だが、セキュリティの分離やカスタマイズの柔軟性を制限する。

Plan 9はこれらの問題を、根本的な設計の見直しで解決しようとした。

---

## 3. Plan 9の技術的設計――すべてはファイルである

### 9Pプロトコル：統一のための通信規約

Plan 9の設計の核心は、9Pプロトコルにある。

9P（Plan 9 Filesystem Protocol）は、すべてのリソースへのアクセスを統一するネットワークプロトコルだ。ローカルのファイルも、リモートのファイルも、ネットワーク接続も、プロセス情報も、ウィンドウも、すべて9Pプロトコルを通じて操作される。サービスを提供したいプログラムは9Pを話すサーバとして振る舞い、そのサービスを利用したいプログラムは9Pを話すクライアントとして振る舞う。

```
Plan 9の設計原則:

  UNIX:
    ファイル操作    → open/read/write/close システムコール
    ネットワーク    → socket/connect/bind/listen/accept システムコール
    プロセス制御    → kill/wait/ptrace システムコール
    デバイス操作    → ioctl システムコール
    グラフィックス  → X11プロトコル（独自の通信規約）
    → 5種類の異なるインターフェース

  Plan 9:
    ファイル操作    → 9Pプロトコル
    ネットワーク    → 9Pプロトコル（/net 経由）
    プロセス制御    → 9Pプロトコル（/proc 経由）
    デバイス操作    → 9Pプロトコル（/dev 経由）
    グラフィックス  → 9Pプロトコル（/dev/draw 経由）
    → 1種類の統一インターフェース
```

9Pの主要な操作は、ファイルシステムの操作と対応する。`walk`でディレクトリ階層を辿り、`open`でファイルを開き、`read`と`write`でデータを読み書きし、`clunk`でファイルハンドルを閉じる。NFSがブロック単位でアクセスするのに対し、9Pはバイト単位でアクセスする。これにより、ファイルに見せかけた仮想的なリソース（プロセスの状態やネットワーク接続のステータスなど）を自然に表現できる。

9Pの本質的な洞察は、「すべてのサービスはファイルサーバとして表現できる」という点にある。Webサーバはファイルサーバだ。データベースはファイルサーバだ。メールシステムもファイルサーバだ。この統一的な視点から見れば、それぞれに固有のプロトコル（HTTP、SQL、SMTP）を設計する必要はない。9Pという単一のプロトコルで、すべてのリソースに一貫したインターフェースでアクセスできる。

第4版で9Pは9P2000に改訂された。ファイル名の制約の緩和、ディレクトリの最終更新者メタデータの追加、認証ファイルの導入などの改善が含まれている。

### /proc：プロセスをファイルとして制御する

Plan 9には、プロセスを操作する専用のシステムコールが存在しない。kill()もwait()もptrace()もない。代わりに、/procファイルシステムがある。

/proc配下には、実行中の各プロセスがプロセスIDを名前とするディレクトリとして存在する。/proc/1、/proc/2、/proc/3。各ディレクトリの中には、プロセスの情報と制御を行うためのファイルが含まれている。

```
Plan 9の/proc構造:

  /proc/
  ├── 1/
  │   ├── ctl       ← テキスト命令でプロセスを制御
  │   ├── status    ← プロセスの状態（テキスト形式）
  │   ├── mem       ← プロセスの仮想メモリイメージ
  │   ├── note      ← プロセスへのノート（UNIXのシグナルに相当）
  │   ├── notepg    ← プロセスグループへのノート
  │   └── text      ← 実行バイナリのイメージ
  ├── 2/
  │   ├── ctl
  │   ├── status
  │   ...

  プロセスの停止:
    $ echo stop > /proc/42/ctl

  プロセスの終了:
    $ echo kill > /proc/42/ctl

  プロセスの状態確認:
    $ cat /proc/42/status
```

プロセスを停止したければ、`echo stop > /proc/42/ctl`と書く。プロセスを終了したければ、`echo kill > /proc/42/ctl`と書く。プロセスの状態を確認したければ、`cat /proc/42/status`と読む。すべてが、ファイルの読み書きで完結する。

この設計の優美さは、特別なツールが不要だという点にある。UNIXではkillコマンド、psコマンド、topコマンドなどのプロセス管理専用ツールが必要だ。Plan 9では、cat、echo、grepといった汎用のテキスト処理ツールでプロセスを管理できる。「Everything is a file」が本物であれば、ファイル操作ツールは同時にプロセス管理ツールでもある。

LinuxとBSDも/procファイルシステムを持つが、Plan 9ほど徹底していない。Linuxの/procにはプロセス情報以外にもカーネルパラメータ（/proc/sys）や各種統計情報が雑多に詰め込まれており、Plan 9の/procのような一貫した構造を持たない。Linuxの/procは「Plan 9的なアイデアを部分的に取り入れたが、完全には実践しなかった」例だ。

### /net：ネットワークをファイルとして操作する

Plan 9のネットワーキングは、UNIXのBerkeley socket APIとは根本的に異なる。Plan 9にはsocket()システムコールが存在しない。代わりに、/netファイルシステムを操作する。

TCP接続を確立する手順を見てみよう。

```
Plan 9でのTCP接続の手順:

  1. /net/tcp/clone を開く
     → 新しいコネクション番号（例: 5）が返される

  2. /net/tcp/5/ctl に接続先を書き込む
     $ echo 'connect 204.178.31.2!80' > /net/tcp/5/ctl

  3. /net/tcp/5/data を読み書きしてデータを送受信
     $ echo 'GET / HTTP/1.0\r\n\r\n' > /net/tcp/5/data
     $ cat /net/tcp/5/data

  4. /net/tcp/5/ctl を閉じて接続を終了

  比較:
    UNIX:  fd = socket(AF_INET, SOCK_STREAM, 0);
           connect(fd, &addr, sizeof(addr));
           write(fd, data, len);
           read(fd, buf, sizeof(buf));
           close(fd);
           → 専用システムコール群が必要

    Plan 9: open, read, write, close のみ
           → ファイル操作と同一
```

/net/csはコネクションサーバだ。名前解決を行う。たとえば`echo 'tcp!plan9.bell-labs.com!http' > /net/cs`と書き込み、読み出すと`/net/tcp/clone 204.178.31.2!80`のような応答が返る。DNS解決もファイルの読み書きで完結する。

この設計の利点は、ネットワークプログラミングが通常のファイルI/Oと同じ知識で書けることだ。さらに重要なのは、ネットワークスタックの仮想化が名前空間の操作だけで実現できることだ。/netを別のマシンの/netでマウントすれば、そのマシンのネットワークスタックをリモートから利用できる。VPNの実装すらファイルシステムの操作として表現できる。

### per-process namespaces：プロセスごとの世界

Plan 9の最も革新的な設計の一つが、per-process namespacesだ。

UNIXでは、ファイルシステムの名前空間はすべてのプロセスで共有される。`/usr/local/bin`は、どのプロセスから見ても同じディレクトリだ。Plan 9では、プロセスごとに名前空間が独立している。同じ`/bin`というパスが、プロセスAとプロセスBで異なるディレクトリを指すことができる。

```
per-process namespacesの例:

  UNIX:
    プロセスA: /dev/audio → サウンドカード
    プロセスB: /dev/audio → サウンドカード（同一リソース）
    → すべてのプロセスで共有される名前空間

  Plan 9:
    プロセスA: /dev/audio → ローカルのサウンドカード
    プロセスB: /dev/audio → リモートマシンのサウンドカード
    → プロセスごとに異なるリソースを指せる

  実現方法:
    プロセスBの名前空間で:
    $ bind /net/remote-machine/dev/audio /dev/audio
    → 以降、プロセスBの/dev/audioはリモートのサウンドカードを指す
    → 他のプロセスには影響しない
```

各プロセスは自分の名前空間に対してbind（結合）やmount（マウント）を実行できる。この操作は他のプロセスに影響しない。つまり、プロセスは自分の世界を自由にカスタマイズできる。

per-process namespacesがもたらす恩恵は大きい。サンドボックス化が自然にできる。信頼できないプログラムには、制限された名前空間を与えればよい。/netの一部しか見えない名前空間を構成すれば、それはファイアウォールとして機能する。これはすべて、特別なセキュリティ機構ではなく、名前空間の操作という汎用的な仕組みで実現される。

この発想は、後にLinuxのnamespaces機能として部分的に実装された。2002年のLinux 2.4.19でmount namespaceが導入され、その後PID namespace、network namespace、user namespaceなどが追加された。Linuxのnamespaces機能はPlan 9のper-process namespacesに直接影響を受けている。そして、Linuxのnamespacesこそが、Docker等のコンテナ技術の基盤となった。Plan 9のアイデアは、コンテナという形で現代のインフラストラクチャに浸透している。

### UTF-8：ダイナーのプレイスマットに描かれた設計

Plan 9から生まれた最も広く普及した技術がUTF-8だ。その誕生の物語は、コンピュータサイエンス史の中でも特に劇的だ。

1992年、Plan 9チームは多言語対応を進めていた。当時のUnicode実装の候補はUTF-16（当初はUCS-2）だった。だが、UTF-16にはPlan 9チームにとって受け入れがたい問題があった。ASCII互換性がない。ヌルバイトが含まれるためC言語の文字列関数が使えない。バイトオーダーの問題がある。Plan 9は分散OSであり、異なるアーキテクチャのマシン間でテキストを交換する。バイトオーダーの違いは致命的だった。

1992年9月2日の夜、X/Open（UNIXの標準化団体）のメンバーがKen ThompsonとRob Pikeに電話をかけてきた。FSS/UTFという新しいエンコーディング方式の設計案について意見を求めたのだ。PikeとThompsonはその提案を検討したが、自分たちならもっとよい設計ができると考えた。

その夜、New Jerseyのダイナーで食事をしながら、二人はテーブルに敷かれたプレイスマット（紙のランチョンマット）にUTF-8の設計を書き出した。ASCIIと完全な後方互換性を持ち、ヌルバイトを含まず、バイトオーダーに依存しない可変長エンコーディング。数学的な優美さと実用的な堅牢性を兼ね備えた設計が、一枚の紙の上に生まれた。

Rob Pike自身の回想によれば、9月8日（火曜日）の午前3時22分、Ken ThompsonがPlan 9をUTF-8に変換し終えた旨のメールを送信した。設計から実装まで、わずか一週間足らずだった。Plan 9のカーネル、ライブラリ、ユーティリティ、エディタ――すべてがUTF-8に切り替えられた。

1993年1月25日から29日にかけて、サンディエゴで開催されたUSENIXカンファレンスでUTF-8は正式に発表された。X/Openはこの設計をFSS-UTFの仕様として採用した。

```
UTF-8の設計原則（Plan 9チームの要件）:

  1. ASCII互換: 0x00-0x7F はASCIIと同一のバイト値
     → 既存のC言語コードが変更なしで動作する

  2. ヌルバイトなし: U+0000以外の文字はヌルバイトを含まない
     → C言語の文字列関数（strlen, strcpy等）がそのまま使える

  3. 自己同期: 任意のバイト位置から文字境界を特定できる
     → ストリーム処理で中間から読み始めても文字化けしない

  4. バイトオーダー非依存: マルチバイト文字もバイト列で表現
     → リトルエンディアン/ビッグエンディアンの問題がない

  5. ソート順保存: バイト列としてのソートがUnicodeコードポイント順と一致
     → 文字列比較関数の変更が不要
```

現在、UTF-8はWebページの98%以上で使われるエンコーディングだ。Linux、macOS、Windowsの最新バージョンすべてがUTF-8をデフォルトまたは主要なエンコーディングとしてサポートしている。Go、Rust、Pythonなどの現代のプログラミング言語はUTF-8を前提に設計されている。ダイナーのプレイスマットに書かれた設計が、全世界のコンピューティングの文字表現の基盤となった。

### rcシェル：Bourne shellの問題を正す

Plan 9はシェルも新しく設計した。rc（run commands）は、Tom DuffがBell LabsでPlan 9のために1980年代後半に設計・実装したシェルだ。

rcの設計目標は、Bourne shellの問題を修正し、不要な複雑さを排除することだった。Tom Duffはrcの論文でこう述べている。「Bourneシェルの最もよく知られた欠点を修正し、可能な限り簡素化しようとした」。

Bourne shellの最大の問題は、入力の再走査だ。Bourne shellではコマンド置換や変数展開の結果が再びシェルの字句解析にかけられる。変数にスペースを含む値が格納されている場合、展開時にIFS（Internal Field Separator）によって予期しない分割が起きる。

```
Bourne shell の問題とrcの解決:

  Bourne shell:
    $ file="my document.txt"
    $ cat $file
    → "my" と "document.txt" の二つの引数に分割される
    → cat: my: No such file or directory

    $ file="hello; rm -rf /"
    $ echo $file
    → 再走査により危険なコマンドが実行される可能性

  rc:
    $ file='my document.txt'
    $ cat $file
    → "my document.txt" が一つの引数として渡される
    → 再走査しないため、IFS分割が起きない

  rcの変数はリスト（文字列の配列）:
    $ dirs=(src bin lib)
    $ echo $dirs(2)
    bin
    → 配列として自然に扱える
```

rcでは変数の値は文字列ではなくリスト（文字列の配列）だ。`dirs=(src bin lib)`と代入すれば、`$dirs`は三要素のリストになる。`$dirs(2)`で二番目の要素にアクセスできる。Bourne shellでは変数は常に単一の文字列であり、リストの扱いは空白区切りの文字列を間接的に使う不安定な方法に頼っていた。

rcの構文はBourne shellよりも規則的だ。if文の構文は`if(test) command`であり、`fi`のような逆読みのキーワードは存在しない。関数定義は`fn name { commands }`であり、Bourne shellの`name() { commands; }`よりも一貫性がある。

この設計思想は後にByron RakitzisによるUNIX向けの独立した再実装にも引き継がれ、一部のUNIXユーザーはrcを日常のシェルとして使っている。

### Acmeエディタ：テキストが操作のすべて

Rob Pikeが設計・実装したAcmeエディタは、Plan 9の「テキストがインターフェースである」という思想の具現化だ。1993年に最初のリリースが行われ、1994年に論文「Acme: A User Interface for Programmers」として発表された。

Acmeはテキストエディタであると同時に、ファイルマネージャであり、シェルであり、プログラミング環境だ。通常のエディタのようにメニューバーやツールバーは存在しない。代わりに、ウィンドウ上部のタグ行にテキストとしてコマンドが書かれている。そのテキストをマウスの中クリックで「実行」する。

たとえばタグ行に「Get Put Undo」と表示されていたとする。「Put」という文字列を中クリックすれば、ファイルが保存される。「Undo」を中クリックすれば、直前の操作が取り消される。だが、重要なのは、タグ行は編集可能な普通のテキストだということだ。「ls -l」とタグ行に書き加え、中クリックすれば、ls -lコマンドが実行され、結果が新しいウィンドウに表示される。任意のコマンドをテキストとして書き、実行できる。

AcmeはNiklaus WirthのOberonシステムの影響を受けている。だが、Plan 9の思想と融合することで、独自の世界を形成した。AcmeのウィンドウはPlan 9の9Pプロトコルを通じてファイルとして外部からアクセスできる。外部プログラムがAcmeのウィンドウに文字を書き込んだり、選択範囲を読み取ったりできる。エディタの拡張が、プラグインAPIではなく、ファイルシステムインターフェースで行われる。ここでも「Everything is a file」の原則が貫かれている。

### Rio：ウィンドウもファイルである

Plan 9のウィンドウシステムであるrioも、同じ原則に従う。初期のPlan 9では8 1/2（はちとにぶんのいち）という名のウィンドウシステムが使われ、後にrioに置き換えられた。rioもRob Pikeの設計だ。

rioの各ウィンドウは、rcシェルのインスタンスを実行している。そしてウィンドウ自体が、/dev/consや/dev/drawといったファイルとしてアクセス可能だ。ウィンドウに文字を書き込みたければ、対応する/dev/consにwriteすればよい。ウィンドウのグラフィックスを操作したければ、/dev/drawにwriteすればよい。

UNIXにおけるX Window Systemとの違いは劇的だ。X11はクライアント・サーバモデルの通信プロトコルであり、固有のライブラリ（Xlib、XCB）とデータ構造を持つ。GUIアプリケーションの開発者は、ファイルI/Oとは別の体系を学ぶ必要がある。Plan 9のrioでは、ウィンドウ操作はファイル操作と同一だ。テキスト処理ツールがそのままGUIの操作に使える。

---

## 4. なぜPlan 9はUNIXを置き換えられなかったか

### 技術的成功と商業的失敗

Plan 9は技術的には多くの専門家から高く評価された。「Everything is a file」の徹底、9Pプロトコルによる統一的なリソースアクセス、per-process namespacesによる柔軟な分離、UTF-8の発明。どれをとっても、UNIXの設計を洗練させた成果だった。

だが、Plan 9は商業的には成功しなかった。UNIXを置き換えることはできなかった。

Eric S. Raymondは『The Art of UNIX Programming』（2003年）の中でこう評している。Plan 9が失敗したのは、UNIXに対する改善が十分ではなかったからだ、と。技術的に優れていることと、移行コストに見合う価値があることは、別の問題だ。

失敗の原因は複合的だった。

第一に、ライセンスの問題。第1版（1992年）は大学向け限定であり、入手手続きが煩雑だった。技術者が自由に試せる環境ではなかった。オープンソースとして公開されたのは2000年の第3版からであり、それまでの8年間で機会を逸した。

第二に、UNIXとの非互換性。Plan 9はUNIXではない。UNIXのプログラムはPlan 9上で動作しない。FirefoxもLibreOfficeも、macOSやBSD、Linuxには移植されたが、Plan 9には移植できなかった。新しいOSのために、すべてのソフトウェアをゼロから書き直す必要があった。ソフトウェアエコシステムの不在は致命的だ。

第三に、ネットワーク効果の壁。UNIXは1990年代までに巨大なユーザーベースを持っていた。ツール、ライブラリ、ドキュメント、教育資料、コミュニティ――すべてがUNIX（およびGNU/Linux）を中心に構築されていた。技術的に優れた代替品が現れても、既存のエコシステムの引力を超えることは極めて難しい。これは、この連載の第6回でMS-DOSが技術的に劣りながらも市場を支配した構図と同じ力学だ。

第四に、AT&T/Lucentの商業的無関心。Plan 9の開発者たちは卓越した研究者であり科学者だったが、商業的なソフトウェア開発者ではなかった。ユーザーが何を必要としているか、どのようにして技術を普及させるかについて、十分な関心が払われなかった。2000年、Rob Pike自身がUtah 2000で「Systems Software Research is Irrelevant（システムソフトウェア研究は無関係になった）」と題する講演を行い、システムソフトウェア研究が孤立し、硬直化し、産業界にとって無関係になりつつある現状を嘆いた。Plan 9の創造者自身が、その普及の困難さを最もよく理解していた。

### 「実現されなかった正解」

Plan 9の商業的失敗をもって、Plan 9の設計思想が間違っていたと結論づけるのは早計だ。

市場の勝者が技術的に最善であるとは限らない。VHSがBetamaxに勝ったのは画質が優れていたからではない。QWERTYキーボードが残っているのは最も効率的な配列だからではない。同じように、UNIXがPlan 9に勝ったのは、UNIXの設計がPlan 9よりも優れていたからではない。

Plan 9は「失敗した未来」ではなく、「実現されなかった正解の一つ」だ。そして、その正解は、形を変えて現代の技術に生き続けている。

---

## 5. Plan 9の遺産――形を変えて生き続けるアイデア

### UTF-8：最も成功した遺産

Plan 9の遺産の中で、最も広く浸透しているのはUTF-8だ。

2026年現在、Webページの98%以上がUTF-8を使用している。HTML5はUTF-8をデフォルトエンコーディングとして推奨している。Go、Rust、Swift、Kotlin――現代のプログラミング言語はソースコードのエンコーディングとしてUTF-8を前提としている。Linuxカーネル、macOS、Windows 10以降もUTF-8を主要なエンコーディングとしてサポートする。

1992年にダイナーのプレイスマットに書かれた設計が、30年以上を経て、全世界のコンピューティングの文字表現を統一した。Plan 9が商業的に失敗したにもかかわらず、Plan 9から生まれたUTF-8は、歴史上最も成功した文字エンコーディングとなった。

### /proc：プロセスのファイル化

Plan 9の/procの思想は、LinuxとBSDの/procファイルシステムに影響を与えた。Linuxの/procは、Plan 9ほど一貫してはいないが、プロセス情報をファイルとして公開するという基本的な発想はPlan 9から来ている。`cat /proc/cpuinfo`、`cat /proc/meminfo`、`ls /proc/1234/fd`――Linuxの日常的な管理操作のこれらは、Plan 9的な世界観の部分的な実装だ。

### Linux namespaces：コンテナの源流

Plan 9のper-process namespacesの影響は、Linux namespacesとして結実した。

2002年、Linux 2.4.19でmount namespaceが導入された。その後、2006年以降にPID namespace、network namespace、user namespaceなどが順次追加された。Linux namespaces機能はPlan 9のper-process namespacesに直接影響を受けている。

そしてLinux namespacesは、2013年以降のDockerを含むコンテナ技術の基盤となった。あなたが`docker run`を実行するとき、その裏ではLinux namespacesが新しいプロセスに独立した名前空間を提供している。mount namespace、PID namespace、network namespace、UTS namespace、IPC namespace――これらの組み合わせが、コンテナの分離を実現する。

Plan 9の設計者たちが1980年代後半に構想したper-process namespacesは、30年以上の歳月を経て、クラウドネイティブ時代のインフラストラクチャの根幹となった。

### FUSE：ユーザ空間ファイルシステム

Plan 9では、ファイルシステムをユーザ空間で実装することが自然だった。9Pプロトコルを話すサーバを書けば、それはファイルシステムとして名前空間にマウントできる。カーネルの修正は不要だ。

この概念は、FUSE（Filesystem in Userspace）としてLinuxに移植された。FUSEを使えば、カーネルモジュールを書くことなく、ユーザ空間でファイルシステムを実装できる。sshfs（SSH越しのリモートファイルシステム）、s3fs（Amazon S3をファイルシステムとしてマウント）、ntfs-3g（NTFS読み書き対応）などが、FUSEの上に構築されている。

### 9P in the wild：WSLとQEMU

9Pプロトコル自体も、現代の技術で使われている。

Windows Subsystem for Linux（WSL）は、WindowsとLinuxのファイルシステム間の共有に9Pを使用している。あなたがWSL上で`/mnt/c/`を通じてWindowsのファイルにアクセスしているとき、その裏では9Pプロトコルが動作している。

QEMUの仮想化環境でも、VirtFS（Plan 9 folder sharing）として9Pが使われている。ホストOSとゲストOS間でフォルダを共有する手段として、Plan 9のプロトコルが採用されている。

Plan 9のOSとしては普及しなかったが、Plan 9の設計思想とプロトコルは、現代のインフラストラクチャの至るところに浸透している。

### Goプログラミング言語

Rob PikeとKen Thompsonが2009年に発表したGoプログラミング言語にも、Plan 9の影響は色濃い。GoのgoroutineとchannelはPlan 9で使われていたAlef言語（Phil Winterbottom設計）の並行処理モデルの延長線上にある。Goのアセンブラの構文はPlan 9のアセンブラに由来する。GoのツールチェーンはPlan 9のビルドシステムの設計哲学を引き継いでいる。Plan 9のアイデアは、現代で最も広く使われているプログラミング言語の一つを通じて、間接的に世界中の開発者に届いている。

---

## 6. ハンズオン：Plan 9の世界を体験する

### 環境構築

```bash
# Docker環境で実行（ubuntu:24.04ベース）
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：LinuxにおけるPlan 9の痕跡を確認する

```bash
apt-get update && apt-get install -y procps

echo "=== 演習1: LinuxにおけるPlan 9の痕跡 ==="
echo ""

echo "--- /proc: Plan 9由来のファイルシステム ---"
echo ""
echo "プロセス一覧（/procディレクトリ）:"
ls /proc/ | head -20
echo "..."
echo ""

echo "プロセス情報をファイルとして読む:"
echo '$ cat /proc/1/status | head -10'
cat /proc/1/status 2>/dev/null | head -10
echo ""

echo "Plan 9では、プロセスの制御もファイルへの書き込みで行った。"
echo "Linuxの /proc はPlan 9の影響を受けているが、"
echo "Plan 9ほど徹底していない。"
echo ""

echo "--- /proc 配下のカーネル情報 ---"
echo ""
echo '$ cat /proc/version'
cat /proc/version
echo ""
echo '$ cat /proc/cpuinfo | head -5'
cat /proc/cpuinfo 2>/dev/null | head -5
echo ""

echo "→ Linuxの /proc はプロセス情報だけでなく"
echo "  カーネルパラメータも含む雑多な構造。"
echo "  Plan 9の /proc はプロセス専用で一貫性が高い。"
```

### 演習2：UTF-8の設計を体感する

```bash
echo ""
echo "=== 演習2: UTF-8の設計原則を体感する ==="
echo ""

echo "--- ASCII互換性の確認 ---"
echo ""
echo "ASCII文字は1バイト（Plan 9チームの要件: ASCII互換）:"
echo -n "A" | xxd | head -1
echo -n "z" | xxd | head -1
echo ""

echo "日本語は3バイト（可変長エンコーディング）:"
echo -n "あ" | xxd | head -1
echo -n "漢" | xxd | head -1
echo ""

echo "--- 自己同期性の確認 ---"
echo ""
echo "UTF-8のバイトパターン:"
echo "  0xxxxxxx         → 1バイト文字（ASCII、0x00-0x7F）"
echo "  110xxxxx 10xxxxxx → 2バイト文字"
echo "  1110xxxx 10xxxxxx 10xxxxxx → 3バイト文字"
echo "  11110xxx 10xxxxxx 10xxxxxx 10xxxxxx → 4バイト文字"
echo ""
echo "先頭バイトを見れば文字の長さがわかる。"
echo "継続バイト（10xxxxxx）は先頭バイトと区別できる。"
echo "→ ストリームの途中からでも文字境界を特定可能。"
echo "→ これがPlan 9チームの設計要件「自己同期」だ。"
echo ""

echo "--- ヌルバイト非含有の確認 ---"
echo ""
echo "UTF-8では、U+0000以外の文字にヌルバイト（0x00）は現れない:"
echo -n "Hello世界" | xxd
echo ""
echo "→ C言語の文字列関数（strlen, strcmp等）がそのまま動作する。"
echo "  これがPlan 9チームがUTF-16を拒否した主要な理由だ。"
```

### 演習3：9Pプロトコルの概念をLinuxで確認する

```bash
echo ""
echo "=== 演習3: 9Pプロトコルの現代での利用 ==="
echo ""

echo "--- Linuxカーネルの9Pサポート ---"
echo ""
if [ -f /proc/filesystems ]; then
    echo '$ grep 9p /proc/filesystems'
    grep 9p /proc/filesystems 2>/dev/null || \
        echo "(このカーネルでは9pモジュールが未ロード)"
fi
echo ""

echo "9Pプロトコルは現代でも使われている:"
echo ""
echo "  1. WSL (Windows Subsystem for Linux)"
echo "     → WindowsとLinux間のファイル共有に9Pを使用"
echo "     → /mnt/c/ でWindowsのCドライブにアクセスする裏側"
echo ""
echo "  2. QEMU VirtFS"
echo "     → ホストとゲスト間のフォルダ共有に9Pを使用"
echo ""
echo "  3. Container runtimes"
echo "     → 一部の実装でファイル共有に9Pが使われる"
echo ""

echo "--- Plan 9の /net をLinuxのソケットと比較 ---"
echo ""
echo "Plan 9 でのTCP接続:"
echo '  $ cat /net/tcp/clone   → コネクション番号取得'
echo '  $ echo "connect 10.0.0.1!80" > /net/tcp/5/ctl'
echo '  $ cat /net/tcp/5/data  → データ受信'
echo ""
echo "Linux でのTCP接続（疑似ファイル /dev/tcp, bash拡張）:"
if echo "HEAD / HTTP/1.0" > /dev/tcp/example.com/80 2>/dev/null; then
    echo '  $ echo "GET /" > /dev/tcp/example.com/80'
    echo "  → bash の /dev/tcp はPlan 9的な発想の限定的な実装"
else
    echo '  $ echo "GET /" > /dev/tcp/example.com/80'
    echo "  → (この環境では /dev/tcp が利用不可)"
fi
echo ""
echo "→ Linuxではネットワークは依然としてsocket APIが主流。"
echo "  Plan 9の「ネットワークもファイル」は実現されていない。"
```

### 演習4：Linux namespacesとPlan 9の関係

```bash
echo ""
echo "=== 演習4: Linux namespaces — Plan 9の遺産 ==="
echo ""

echo "--- 現在のnamespace情報 ---"
echo ""
echo '$ ls -la /proc/self/ns/'
ls -la /proc/self/ns/ 2>/dev/null
echo ""

echo "各namespaceの説明:"
echo "  cgroup  → cgroup namespace"
echo "  ipc     → IPC namespace（Plan 9: なし、9Pで代替）"
echo "  mnt     → mount namespace（Plan 9: per-process namespace）"
echo "  net     → network namespace（Plan 9: /net のbind）"
echo "  pid     → PID namespace（Plan 9: /proc のbind）"
echo "  user    → user namespace"
echo "  uts     → UTS namespace（ホスト名等）"
echo ""

echo "--- Dockerコンテナの正体 ---"
echo ""
echo "docker run は以下のLinux機能を組み合わせる:"
echo ""
echo "  1. namespaces（Plan 9由来の概念）"
echo "     → プロセスに独立した名前空間を提供"
echo "  2. cgroups"
echo "     → リソース使用量を制限"
echo "  3. union filesystem"
echo "     → 層状のファイルシステム（Plan 9のbindに類似）"
echo ""
echo "Plan 9のper-process namespacesは、"
echo "30年以上の時を経て、コンテナ技術の基盤となった。"
echo ""

echo "=== まとめ ==="
echo ""
echo "1. /proc はPlan 9が生んだ「プロセスをファイルとして扱う」思想"
echo "2. UTF-8 はPlan 9チームが1992年に設計した文字エンコーディング"
echo "3. 9P プロトコルはWSLやQEMUで現在も使われている"
echo "4. Linux namespaces はPlan 9のper-process namespacesに影響を受けた"
echo "5. Docker のコンテナ分離は、間接的にPlan 9の設計思想に由来する"
```

ハンズオンの自動セットアップスクリプトは `handson/command-line/15-plan9-dream/setup.sh` を参照してほしい。

---

## 7. まとめと次回予告

### この回の要点

第一に、Plan 9 from Bell Labsは、UNIXの創造者たち自身がUNIXの限界を克服するために1980年代後半に設計したオペレーティングシステムだ。Rob Pike、Ken Thompson、Dave Presotto、Phil Winterbottomが開発を率い、Dennis Ritchieが支援した。1992年に第1版がリリースされ、2002年に第4版がオープンソースで公開された。

第二に、Plan 9は「Everything is a file」を文字通り実践した。9Pプロトコルという統一的なファイルシステムプロトコルを通じて、ネットワーク（/net）、プロセス（/proc）、ウィンドウシステム（/dev/draw）を含むすべてのリソースをファイルとして操作できる。UNIXがsocket API、kill/ptrace、X11プロトコルと複数のインターフェースに分裂していたのに対し、Plan 9はopen/read/write/closeという単一のインターフェースに統一した。

第三に、per-process namespaces（プロセスごとの名前空間）により、各プロセスが独自のファイルシステムビューを持てる。この概念はLinux namespacesとして実装され、Docker等のコンテナ技術の基盤となった。

第四に、UTF-8は1992年9月2日、Rob PikeとKen ThompsonがNew Jerseyのダイナーでプレイスマットに設計を書き出したことから生まれた。ASCII互換性、ヌルバイト非含有、自己同期性、バイトオーダー非依存という設計原則により、現在のWebと主要OSの標準エンコーディングとなった。

第五に、Plan 9は技術的に高く評価されながら、商業的には成功しなかった。ライセンスの制約、UNIXとの非互換性、ソフトウェアエコシステムの不在、ネットワーク効果の壁が、普及を阻んだ。だが、Plan 9のアイデア（UTF-8、/proc、namespaces、FUSE、9P）は形を変えて現代技術に浸透している。

### 冒頭の問いへの暫定回答

UNIXの創造者たちは、UNIXの何が不満だったのか。

答えは明快だ。「Everything is a file」の不徹底だ。UNIXは自らの設計原則に忠実ではなかった。ネットワークはsocket APIという別体系を持ち、プロセス制御はkill/ptraceという専用のシステムコールに依存し、GUIはX11という独自のプロトコルに分裂していた。Plan 9は、この不徹底を正面から解決し、9Pという単一のプロトコルですべてを統一した。

Plan 9は「失敗した未来」ではない。「実現されなかった正解の一つ」だ。そしてその正解は、UTF-8として全世界の文字表現を統一し、namespacesとしてコンテナ技術の基盤を提供し、9Pとして仮想化インフラの通信路を担い、形を変えて現代に生きている。

「選ばれなかった未来」が30年後の世界を静かに支えている。技術史にはそういうことが起きる。

### 次回予告

次回、第16回「SSHとリモートCLI――距離を超えるテキストインターフェース」では、CLIがなぜリモート操作の「唯一解」であり続けるのかを問う。

1995年、Tatu YlonenがヘルシンキでSSH（Secure Shell）を開発した。暗号化されたリモートアクセスの実現は、テキストベースのCLIがネットワーク越しに最も効率的なインターフェースであることを改めて証明した。telnetからSSH、そしてMoshへ。テキストストリームが帯域に優しいという構造的優位性は、リモート操作の歴史を貫く原則だ。

あなたが日常的に使っているSSH接続の裏で、どのような技術史が流れているか。考えてみてほしい。

---

## 参考文献

- Rob Pike, Dave Presotto, Ken Thompson, Howard Trickey, Phil Winterbottom, "Plan 9 from Bell Labs", <https://9p.io/sys/doc/9.html>
- Plan 9 from Bell Labs, Official Site, <https://9p.io/plan9/about.html>
- Plan 9 Foundation, <https://www.plan9foundation.org/about.html>
- Wikipedia, "Plan 9 from Bell Labs", <https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs>
- Rob Pike, "The history of UTF-8 as told by Rob Pike", <https://doc.cat-v.org/bell_labs/utf-8_history>
- Markus Kuhn, "UTF-8 history" (Rob Pike's email), <https://www.cl.cam.ac.uk/~mgk25/ucs/utf-8-history.txt>
- Wikipedia, "UTF-8", <https://en.wikipedia.org/wiki/UTF-8>
- Wikipedia, "9P (protocol)", <https://en.wikipedia.org/wiki/9P_(protocol)>
- Rob Pike et al., "The Use of Name Spaces in Plan 9", <https://9p.io/sys/doc/names.html>
- Tom Duff, "Rc — The Plan 9 Shell", <https://doc.cat-v.org/plan_9/4th_edition/papers/rc>
- Wikipedia, "Acme (text editor)", <https://en.wikipedia.org/wiki/Acme_(text_editor)>
- Russ Cox, "A Tour of Acme", <https://research.swtch.com/acme>
- Wikipedia, "Rio (windowing system)", <https://en.wikipedia.org/wiki/Rio_(windowing_system)>
- Wikipedia, "Procfs", <https://en.wikipedia.org/wiki/Procfs>
- Wikipedia, "Linux namespaces", <https://en.wikipedia.org/wiki/Linux_namespaces>
- Linux Kernel Documentation, "v9fs: Plan 9 Resource Sharing for Linux", <https://docs.kernel.org/filesystems/9p.html>
- Eric S. Raymond, "Plan 9: The Way the Future Was", <https://www.catb.org/esr/writings/taoup/html/plan9.html>
- Rob Pike, "Systems Software Research is Irrelevant", 2000, <http://herpolhode.com/rob/utah2000.pdf>
- Drew DeVault, "In praise of Plan 9", 2022, <https://drewdevault.com/2022/11/12/In-praise-of-Plan-9.html>
- Yotam Nachum, "Linux Namespaces Are a Poor Man's Plan 9 Namespaces", <https://yotam.net/posts/linux-namespaces-are-a-poor-mans-plan9-namespaces/>
- Phoronix, "Plan 9 Copyright Transferred To Foundation, MIT Licensed Code Released", 2021, <https://www.phoronix.com/news/Plan-9-2021>
- The Register, "The successor to Research Unix was Plan 9 from Bell Labs", 2024, <https://www.theregister.com/2024/02/21/successor_to_unix_plan_9/>
- 9front, <https://9front.org/>
