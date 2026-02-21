# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第11回：GUIの衝撃――Xerox Alto, Macintosh, そして"CLIは死ぬ"という予言

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Doug Engelbartの「Mother of All Demos」（1968年）がGUIの原点に与えた影響
- Xerox Alto（1973年）とAlan KayのSmalltalk――GUIパラダイムの誕生
- Steve JobsのXerox PARC訪問（1979年）からMacintosh（1984年）への道筋
- Ben Shneidermanの「直接操作」理論――GUIが認知的に優れている理由
- 再認（recognition）と想起（recall）――GUIとCLIの認知モデルの根本的な違い
- Windows 95の「衝撃」と、「CLIは死ぬ」という予言が外れ続けた理由
- GUIとCLIの操作を同一タスクで比較し、「再現可能性」と「自動化容易性」の差を体験する

---

## 1. 「もうコマンドプロンプトは要らない」と思った日

1995年の夏の終わり、私は大学の計算機室でWindows 95のインストールを手伝っていた。

まだLinuxに本格的に触れる前の時期だ。8月24日の発売から数日後、研究室の予算で購入されたパッケージを開封し、インストーラを走らせた。再起動後に現れた画面を、今でも覚えている。左下に「スタート」ボタン。デスクトップにアイコン。マウスでクリックすれば、何かが起動する。それまでDOS窓で `dir` や `copy` を打っていた私にとって、「もうコマンドプロンプトは要らないのだ」という感覚は鮮烈だった。

Rolling Stonesの "Start Me Up" がテレビCMから流れていた。ソフトウェアの発売が、音楽チャートのリリースと同じ扱いで報道されていた。深夜販売に行列ができたと聞いた。初日で7億2,000万ドルの売上。ソフトウェアが「文化的イベント」になった、おそらく初めての瞬間だった。

だが、数ヶ月が経った頃、私はDOS窓を開いていた。ファイルの一括リネームがエクスプローラでは面倒だったからだ。100個のファイルの名前を規則的に変えたいとき、GUIでは一つひとつクリックしてリネームするしかない。DOSの `for` ループなら一行で済む。Windows 95のスタートメニューは美しかったが、美しさでは解決できない作業があった。

あの日から30年。「CLIは死ぬ」という予言は、1984年のMacintosh発売時にも、1995年のWindows 95発売時にも、2007年のiPhone登場時にも繰り返された。そのたびに外れた。だが、この予言がなぜ繰り返されたのかを理解するには、GUIがもたらした「衝撃」の本質を知る必要がある。

GUIの登場は、本当にCLIの「終わり」を意味したのか。それとも、CLIとGUIは根本的に異なる認知モデルに基づくインターフェースであり、「どちらが優れているか」という問い自体が間違っているのか。答えを出す前に、GUIの歴史を最初から辿ろう。

---

## 2. GUIの源流――「コンピュータと人間の関係」を変えた人々

### Engelbartのデモンストレーション（1968年）

GUIの歴史を語るとき、多くの人はXerox PARCから始める。だが、物語はそれよりも前に遡る。

1968年12月9日、サンフランシスコで開催されたACM/IEEEのFall Joint Computer Conferenceにて、Stanford Research InstituteのDoug Engelbartが90分間のライブデモンストレーションを行った。後に「Mother of All Demos」と呼ばれることになるこの発表で、Engelbartはマウス、ハイパーテキスト、ウィンドウ、ビデオ会議、共同リアルタイム編集など、現代コンピューティングの基礎要素を一挙に披露した。

Engelbartが開発したのはNLS（oN-Line System）と呼ばれるシステムだ。22フィート（約6.7メートル）の大型スクリーンにEidophorビデオプロジェクタで映像を投影し、自身のコンピュータ操作をリアルタイムで会場に見せた。マウスでテキストの任意の位置をクリックし、ハイパーリンクで文書間を移動し、離れた場所にいる同僚と同じ文書を同時に編集する。1968年にである。

この時代、コンピュータとの対話手段はテレタイプ端末のコマンドラインが主流だった。第3回で触れたCTSSのタイムシェアリング環境、第4回で追ったテレタイプからCRT端末への進化は、「テキストを打ち込んでテキストが返ってくる」という対話モデルだ。Engelbartはそれとはまったく異なるビジョンを示した。画面上のオブジェクトを指し示し、直接操作する。テキストコマンドではなく、視覚的なフィードバックで対話する。

だが、Engelbartのデモは時代に先駆けすぎていた。NLSのハードウェアは高価で、研究所の外に広がることはなかった。それでもこのデモは、後のGUI開発者たちに決定的な影響を与えた。Xerox PARCのAlan Kayは、このデモから直接的なインスピレーションを受けたと語っている。

### Sketchpadの先駆（1963年）

Engelbartよりさらに5年前、GUIの技術的基盤はすでに示されていた。1963年、MITリンカーン研究所のIvan Sutherlandは、博士論文としてSketchpadを発表した。ライトペンを使ってコンピュータ画面上で直接図形を描画・操作できる、世界初のグラフィカル対話プログラムである。

Sketchpadが革新的だったのは、「コマンドを打つ」のではなく「画面上のオブジェクトを直接操作する」という対話モデルを実証した点にある。幾何学的制約（線の長さや角度の固定）、ウィンドウ描画、クリッピングアルゴリズムなど、後のGUIの基盤技術がここで初めて実装された。

SketchpadはAlan KayのDynabookプロジェクトに直接影響を与え、KayはXerox PARCでそのビジョンを実現に近づけた。

### Xerox Alto――GUIパラダイムの原型（1973年）

1973年3月、Xerox PARC（Palo Alto Research Center）で、Charles P. Thackerが設計したXerox Altoの最初のマシンが完成した。

Altoの仕様を列挙すれば、現代の基準では児戯に等しい。だが、1973年の時点で、このマシンが備えていたものを考えてほしい。

```
Xerox Alto (1973年):

  ディスプレイ: 606x808ピクセル ビットマップディスプレイ（縦長）
  入力デバイス: 3ボタンマウス + キーボード
  ソフトウェア:
    - Bravo（WYSIWYGワードプロセッサ）
    - Smalltalk（オブジェクト指向プログラミング環境）
    - Draw（描画プログラム）
  ネットワーク: Ethernet（Robert MetcalfeがPARCで発明）
  ストレージ: 2.5MB リムーバブルディスクパック

  → ビットマップディスプレイ + マウス + WYSIWYG
  → 「画面に見えるものが出力されるもの」という概念の実現
  → 約2,000台が製造されたが、外部には販売されなかった
```

Altoは「パーソナルコンピュータ」という概念の原型だった。一人のユーザーが一台のマシンを占有して使う。画面にはテキストだけでなく、図形やフォントが表示される。マウスで画面上のオブジェクトを選択し、操作する。テキストコマンドを「打つ」のではなく、視覚的なオブジェクトを「操作する」。

Altoの心臓部にいたのが、Alan Kayだ。KayはXerox PARCのLearning Research Groupを率い、Smalltalkプログラミング言語・環境を開発した。Smalltalkは、後のすべてのGUIの原型となるオーバーラッピングウィンドウインターフェースを実装した。複数のウィンドウが画面上に重なって表示され、ユーザーはマウスで任意のウィンドウを前面に持ってくる。

Kayのビジョンは、Altoの開発以前から存在していた。1968年頃、ユタ大学のARPAプロジェクトに在籍していたKayは、Dynabookという構想を描いていた。子供を含むあらゆる年齢のユーザーが使えるラップトップ型のパーソナルコンピュータ。Dynabookそのものは実現しなかったが、その思想はAltoを通じて現実の形を得た。

ここで重要な点がある。**Altoは商業製品ではなかった。** 約2,000台が製造されたが、Xerox社内や大学に配布されただけで、一般に販売されることはなかった。GUIというパラダイムは、研究所の中で生まれ、研究所の中に留まった。ビットマップディスプレイとマウスとウィンドウの組み合わせが「世界を変える」ことを、Xerox経営陣は理解できなかった。少なくとも、十分な速度では理解しなかった。

### Xerox Star――商用GUI第一号の挫折（1981年）

Altoの研究成果を商品化する試みが、Xerox Star 8010 Information Systemだ。1981年4月27日に発売された。GUIを搭載した最初の商用コンピュータである。

ビットマップディスプレイ、ウィンドウ、アイコン、フォルダ、マウス、イーサネットネットワーキング、ファイルサーバ、電子メール。Starが備えていた機能は、現代のデスクトップ環境とほぼ同じだ。WYSIWYG（What You See Is What You Get）という概念も、Starで初めて商用製品として実装された。

だが、Starは商業的に失敗した。理由は明白だ。基本システムの価格が約75,000ドル（2024年の貨幣価値で約259,000ドル）。追加ワークステーション1台が約16,000ドル。個人どころか、多くの企業にとっても手が出ない価格だった。

Starの失敗は、技術の良さだけでは市場を動かせないことを示した。GUIのパラダイムは正しかった。だが、それを手の届く価格で届けた者が勝つ。その「勝者」が現れるまで、あと2年を要した。

---

## 3. GUIの認知モデル――なぜ「見て触る」は強力なのか

### Steve JobsとXerox PARC（1979年）

1979年12月、Steve Jobsを含むApple Computer社の社員がXerox PARCを訪問した。この訪問は偶然ではない。XeroxはAppleの非公開株100,000株を1株10.50ドルで購入する権利を得ることと引き換えに、技術デモを提供する取り決めを結んでいた。

デモを担当したのは、PARCのエンジニアLarry Teslerだ。Teslerは後にAppleに移籍することになるが、この日のデモでSmalltalsk-76の環境、ネットワーク、そして最も重要なマウス駆動のGUIを披露した。

Jobsの反応は伝説になっている。Teslerの回想によれば、Jobsは部屋の中を歩き回り、画面上の操作を見始めると飛び跳ね始め、「なぜこれを使って何もしていないのか！　これは最も素晴らしいものだ。革命的だ！」と叫んだという。

この訪問がAppleのGUI開発に影響を与えたことは間違いない。だが、よくある「JobsがXeroxからGUIを盗んだ」という物語は単純化に過ぎる。Apple LisaもMacintoshも、PARC訪問以前からプロジェクトとして進行していた。1979年秋の文書には、すでにMacintoshがユーザーフレンドリーなインターフェース、ビットマップスクリーン、グラフィック機能を備えることが記されている。PARCのデモはAppleの方向性を「確認」し「加速」したが、方向性自体はApple独自のものだった。

### Apple Lisa（1983年）とMacintosh（1984年）

1983年1月19日、Apple Lisaが発表された。GUIを搭載した量産パーソナルコンピュータとしては最初のものだ。Motorola 68000 CPU（5MHz）、1MB RAM、5MBハードドライブを搭載し、価格は9,995ドル。現在の貨幣価値で約32,000ドルに相当する。

Lisaは技術的に先進的だったが、9,995ドルという価格と、動作の遅さにより商業的に失敗した。Xerox Starと同じパターンだ。GUIの良さは理解されたが、まだ「高すぎる」技術だった。

転機は翌年に訪れる。

1984年1月22日、Super Bowl XVIIIの第3クォーター中に、Ridley Scott監督による60秒のテレビCMが全米に放映された。George Orwellの小説『1984年』をモチーフにした映像で、灰色のドローンの群れの中を走る女性アスリートが、巨大スクリーンに映る「Big Brother」にハンマーを投げつける。

> _"On January 24th, Apple Computer will introduce Macintosh. And you'll see why 1984 won't be like '1984'."_

2日後の1月24日、De Anza CollegeのFlint Auditoriumで開催されたApple年次株主総会で、Steve Jobs自らがMacintoshを発表した。価格2,495ドル。Lisaの4分の1。9インチモノクロディスプレイ、Motorola 68000（8MHz）、128KB RAM。マウスとキーボードが付属する。

Macintoshが到達した地点を整理しよう。

```
GUI の商用化の道のり:

  1973年 Xerox Alto     ── 研究用。非売品。約2,000台
  1981年 Xerox Star     ── 75,000ドル。商業的失敗
  1983年 Apple Lisa     ──  9,995ドル。商業的失敗
  1984年 Apple Macintosh ──  2,495ドル。最初の商業的成功

  → 10年かけて、GUIの価格が30分の1になった
  → 技術の問題ではなく、コストの問題だった
  → 「正しい技術」を「手が届く価格」で届けた者が勝つ
```

Macintoshは発売後の約3ヶ月半で70,000台を販売した。Xerox Starの全販売台数をはるかに上回る。GUIは初めて「大衆」に届いた。

Steve Jobsは「コンピュータは精神のための自転車（bicycle for the mind）である」と語った。1973年のScientific American誌に掲載された動物の移動効率のデータに基づく比喩だ。コンドルが最も効率的な動物だが、自転車に乗った人間はあらゆる動物を凌駕する。コンピュータは、人間の知的能力を拡張する「自転車」だ。

Macintoshが体現したのは、この「自転車」を「誰でも乗れる」ようにするというビジョンだった。CLIは自転車というよりも、マニュアル車のトランスミッションに近い。仕組みを理解し、操作を覚えた者には強力だが、初心者には敷居が高い。GUIは、その敷居を取り払った。

### Ben Shneidermanの「直接操作」（1983年）

GUIの「なぜ使いやすいか」を理論的に根拠づけたのが、メリーランド大学のBen Shneidermanだ。1983年、IEEE Computer誌に発表した論文 "Direct Manipulation: A Step Beyond Programming Languages" で、「直接操作」（direct manipulation）の概念を体系化した。

Shneidermanが定義した直接操作の3つの原則は以下の通りだ。

第一に、**操作対象の継続的な可視化（continuous representation of the object of interest）。** ファイルはアイコンとして画面に表示され続ける。CLIでは `ls` を打たなければファイルの存在すら見えないが、GUIではデスクトップに常に表示されている。

第二に、**迅速で可逆的かつ段階的な操作（rapid, reversible, incremental actions）。** ドラッグ＆ドロップでファイルを移動し、気に入らなければ元に戻す。CLIで `mv` を実行した後に「やっぱり違った」と思っても、元のパスを覚えていなければ戻せない。GUIでは操作の結果が即座に視覚的にフィードバックされ、「元に戻す（Undo）」が使える。

第三に、**複雑なコマンド言語構文の排除（replacement of complex command language syntax by direct manipulation of the object）。** ファイルをゴミ箱にドラッグすれば削除できる。`rm -rf /path/to/file` というコマンドを「覚える」必要がない。

```
直接操作の3原則 (Shneiderman, 1983):

  1. 継続的な可視化
     CLI: ls を打たなければ何があるかわからない
     GUI: デスクトップにファイルが常に見えている

  2. 迅速で可逆的な操作
     CLI: mv source dest → 元に戻すには逆のmvが必要
     GUI: ドラッグ＆ドロップ → Ctrl+Z で元に戻る

  3. コマンド構文の排除
     CLI: rm -rf /path/to/file （正確な構文を覚える必要）
     GUI: ファイルをゴミ箱にドラッグ（動作が自明）
```

Shneidermanの理論は、GUIが「なんとなく使いやすい」のではなく、認知科学的に根拠のある設計原則に基づいていることを示した。人間の認知は、抽象的なコマンド体系よりも、視覚的に操作対象を直接触れる方が自然に働く。

### 再認と想起――二つの認知モデル

Shneidermanの直接操作理論をさらに深く理解するには、認知心理学の「再認（recognition）」と「想起（recall）」の区別が鍵になる。

**再認（recognition）** とは、提示された選択肢の中から正解を見つける行為だ。選択式テストがこれに当たる。GUIのメニューは再認に基づく。メニューバーをクリックすれば、利用可能なコマンドが一覧表示される。ユーザーは「どれが自分の欲しい操作か」を見て判断すればよい。

**想起（recall）** とは、手がかりなしに記憶から情報を引き出す行為だ。記述式テストがこれに当たる。CLIは想起に基づく。ファイルを削除したければ `rm` というコマンド名を記憶から引き出し、オプション（`-r` はrecursive、`-f` はforce）を思い出し、正確な構文で入力しなければならない。

認知心理学の知見では、再認は想起よりも認知的負荷が低い。なぜなら、再認では外的な手がかり（メニューの項目名、アイコンの形状）が記憶の検索を助けるからだ。想起では、そうした手がかりが存在しない。

Jakob Nielsenの10のユーザビリティヒューリスティクスの第6原則は「再認を想起より優先せよ（Recognition rather than Recall）」だ。GUIはこの原則を体現するインターフェースであり、CLIは原則的に想起に依存するインターフェースだ。

```
再認（Recognition）と想起（Recall）:

  再認ベースのインターフェース（GUI）:
    ┌──────────────────────────────┐
    │ ファイル  編集  表示  ヘルプ │
    ├──────────────────────────────┤
    │ ▶ 新規作成                   │
    │ ▶ 開く                       │
    │ ▶ 保存         Ctrl+S       │
    │ ▶ 名前を付けて保存           │
    │ ───────────────              │
    │ ▶ 印刷         Ctrl+P       │
    │ ▶ 終了         Alt+F4       │
    └──────────────────────────────┘
    → 選択肢が目の前に提示される
    → ユーザーは「見て選ぶ」だけでよい

  想起ベースのインターフェース（CLI）:
    $ _
    → 何も表示されていない
    → ユーザーは「何ができるか」を自分で知っていなければならない
    → コマンド名、オプション、構文を記憶から引き出す必要がある
```

この認知モデルの違いは、GUIがCLIより「優れている」ことを意味するのだろうか。

答えは否だ。再認は初心者にとって優位だが、エキスパートにとっては必ずしもそうではない。熟練したCLIユーザーにとって、コマンドの想起はほとんど自動化されている。`ls`、`cd`、`grep`、`awk` は「思い出す」のではなく、指が覚えている。メニューを開いて目で探すより、コマンドを直接打つ方が速い。

さらに重要なのは、想起ベースのインターフェースには再認ベースにはない構造的な利点がある点だ。コマンドはテキストだ。テキストはコピーできる。記録できる。スクリプトに組み込める。自動化できる。メニューをクリックする操作は、記録も再現も困難だ。この点については、次回の第12回で深く掘り下げる。

---

## 4. 「CLIは死ぬ」の系譜

### Windows 95――ソフトウェアがポップカルチャーになった日（1995年）

Macintoshの登場から11年後、GUIは真の意味で「大衆」のものになった。

1985年11月20日にMicrosoftがリリースしたWindows 1.0は、MS-DOSの上で動く貧弱なウィンドウシステムだった。オーバーラッピングウィンドウすら実装されておらず、タイリングウィンドウのみ。実用性は限定的だった。Windows 2.0（1987年）、3.0（1990年）、3.1（1992年）と段階的に改善されたが、それでもMS-DOSが基盤であることに変わりはなかった。

1995年8月24日、Windows 95が発売された。このリリースは、ソフトウェア史上最も大きな文化的インパクトを持つ出来事の一つだった。

Rolling Stonesの "Start Me Up" を使った広告キャンペーン。深夜販売に行列する消費者たち。Computer Cityの店舗には全米で50,000人の顧客が押し寄せた。初日の売上7億2,000万ドル。4日で100万本出荷。5週間で700万本販売。ソフトウェアが初めてポップカルチャーの一部になった。

Windows 95は、「スタート」ボタン、タスクバー、デスクトップショートカットという、現在に至るまで基本的に変わっていないデスクトップGUIのパラダイムを確立した。そしてこの瞬間、多くの人が「コマンドラインの時代は終わった」と感じた。

だが、Windows 95の内側を覗いてみれば、事情は複雑だ。Windows 95はMS-DOSの上に構築されていた。起動シーケンスはMS-DOSのCOMMAND.COMから始まり、そこからGUIシェルが読み込まれる。`Ctrl+F5` で起動すれば、GUIを一切読み込まずにDOSプロンプトに入れた。GUIは基盤を「隠蔽」してはいたが、「置き換えて」はいなかった。

### 「CLIは死ぬ」の三度の予言

「CLIは死ぬ」という予言は、GUIの歴史の中で少なくとも三度、大きな声で叫ばれた。

```
「CLIは死ぬ」予言の系譜:

  第一の予言: 1984年 ── Macintosh発売
    「GUIがあれば、もうコマンドを打つ必要はない」
    → 結果: Macのターミナルは現在も健在。UNIXの血統を引く

  第二の予言: 1995年 ── Windows 95発売
    「一般ユーザーはコマンドプロンプトを見ることすらない」
    → 結果: cmd.exeは消えず、PowerShellが新たに追加された

  第三の予言: 2007年 ── iPhone登場
    「タッチスクリーンがすべてのインターフェースを置き換える」
    → 結果: 開発者のMacBookにはターミナルが常駐している

  共通パターン:
    → 新しいインターフェースは、古いものを「置き換える」のではなく
      「層を一つ追加する」
    → 各層は、それぞれ適したタスク領域を持ち続ける
```

三度の予言がすべて外れたのはなぜか。

Neal Stephensonは1999年のエッセイ "In the Beginning was the Command Line" で、この問題を鋭く分析した。Stephensonはこのエッセイで、GUIがコマンドラインの機能を「メタファーの層で隠蔽する」ものであることを指摘した。デスクトップのアイコンは「ファイル」のメタファーであり、ゴミ箱は「削除」のメタファーだ。メタファーは直感的だが、メタファーの限界を超えた操作を行おうとすると途端に無力になる。

「100個のファイルの名前を、特定のパターンに従って一括変更する」というタスクを考えてみよう。GUIのファイルマネージャでは、一つひとつ右クリックしてリネームするしかない。CLIなら `for` ループ一つで済む。メタファーの世界には「ループ」がない。「条件分岐」もない。GUIは「直感的」だが、「プログラマブル」ではない。

この「プログラマブルかどうか」という軸こそが、CLIが死なない根本的な理由だ。だが、この議論は次回に譲る。まずは、GUIとCLIの認知モデルの違いを自分の手で体験してもらいたい。

---

## 5. ハンズオン：GUIとCLIの認知モデルを体験する

### 環境構築

```bash
# Docker環境で実行（ubuntu:24.04ベース）
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：GUIが得意なこと、CLIが得意なこと

まず、同じタスクをCLIで実行し、GUIとの違いを体感する。ここでは「GUIでの操作」は読者が日常的に行っている操作と対比してほしい。

```bash
# テスト環境のセットアップ
mkdir -p /tmp/gui-vs-cli/project && cd /tmp/gui-vs-cli/project

# 100個のテストファイルを生成
for i in $(seq -w 1 100); do
    echo "Content of file ${i}" > "report_2024_draft_${i}.txt"
done

echo "--- 100個のファイルを作成 ---"
ls | head -10
echo "...（合計 $(ls | wc -l) 個）"
```

ここから、「ファイル名を `report_2024_draft_` から `report_2025_final_` に一括変更する」というタスクを実行する。

```bash
# CLIでの一括リネーム（1行で完了）
echo "--- CLIでの一括リネーム ---"
for f in report_2024_draft_*.txt; do
    mv "$f" "${f/report_2024_draft_/report_2025_final_}"
done

echo "リネーム完了:"
ls | head -10
echo "...（合計 $(ls | wc -l) 個）"
```

GUIのファイルマネージャで同じ操作をする場合を想像してほしい。100個のファイルを一つひとつ右クリックし、「名前の変更」を選び、テキストを修正する。1個あたり10秒としても、16分以上かかる。CLIなら3行、実行時間は1秒未満だ。

だが、ここで注意すべきことがある。**この比較はCLIに有利なタスクを選んでいる。** GUIが得意なタスク――たとえば「写真の中から目的の画像を探してフォルダに分類する」――では、サムネイル表示のあるGUIのほうが圧倒的に効率的だ。CLIで画像の内容を判断するのは困難だ。

### 演習2：「再現可能性」の差を体験する

CLIの構造的優位性の一つは「再現可能性」だ。以下の演習で、その違いを体験する。

```bash
# 作業ディレクトリの再セットアップ
rm -rf /tmp/gui-vs-cli/project/*
cd /tmp/gui-vs-cli/project

# テストデータの生成（ログファイル）
for i in $(seq 1 50); do
    timestamp=$(date -d "2026-02-01 +$((RANDOM % 20)) days" +%Y-%m-%d 2>/dev/null || echo "2026-02-$(printf '%02d' $((RANDOM % 20 + 1)))")
    status=$((RANDOM % 5))
    case $status in
        0|1|2) level="INFO" ;;
        3) level="WARN" ;;
        4) level="ERROR" ;;
    esac
    echo "${timestamp} [${level}] Request processed in $((RANDOM % 1000))ms" >> server.log
done

echo "--- 生成されたログ（先頭10行）---"
head -10 server.log
echo ""
echo "合計行数: $(wc -l < server.log)"
```

```bash
# タスク: ERRORログを日付別に集計する

echo "--- CLIでのログ分析 ---"
echo ""
echo "コマンド: grep ERROR server.log | awk '{print \$1}' | sort | uniq -c | sort -rn"
echo ""
grep "ERROR" server.log | awk '{print $1}' | sort | uniq -c | sort -rn
echo ""
echo "→ このコマンドは記録できる"
echo "  テキストファイルに保存し、いつでも再実行可能"
echo "  別のログファイルにも適用できる"
echo "  CIパイプラインに組み込める"
```

GUIでこの分析を行う場合、テキストエディタでログを開き、目視でERROR行を探し、日付を手動で数える。この手順は「記録」できない。翌日同じ分析を行いたければ、すべて手作業でやり直す必要がある。

```bash
# 分析手順をスクリプトとして保存
cat > /tmp/gui-vs-cli/analyze-errors.sh << 'EOF'
#!/bin/bash
# エラーログ分析スクリプト
# 使い方: ./analyze-errors.sh <logfile>
set -euo pipefail

LOGFILE="${1:?使い方: $0 <logfile>}"

echo "=== エラーログ分析: ${LOGFILE} ==="
echo ""

total=$(wc -l < "$LOGFILE")
errors=$(grep -c "ERROR" "$LOGFILE" || true)
echo "総行数: ${total}"
echo "ERROR行数: ${errors}"
echo "エラー率: $(echo "scale=1; ${errors} * 100 / ${total}" | bc)%"
echo ""

echo "--- 日付別ERROR件数 ---"
grep "ERROR" "$LOGFILE" | awk '{print $1}' | sort | uniq -c | sort -rn
echo ""

echo "--- 応答時間が500ms超のリクエスト ---"
grep -oP '\d+(?=ms)' "$LOGFILE" | awk '$1 > 500' | wc -l
echo "件"
EOF
chmod +x /tmp/gui-vs-cli/analyze-errors.sh

echo "--- スクリプトとして保存 ---"
cat /tmp/gui-vs-cli/analyze-errors.sh
echo ""
echo "→ この分析手順は:"
echo "  1. バージョン管理できる（git commitで差分追跡）"
echo "  2. 他のチームメンバーと共有できる"
echo "  3. CIパイプラインで自動実行できる"
echo "  4. 別のログファイルに即座に適用できる"
echo "  GUIでの手動操作には、これらの特性がない"
```

### 演習3：「発見しやすさ」の差を体験する

CLIが不利な場面も正面から体験する。

```bash
# コマンドの「発見しやすさ」の問題
echo "--- CLIの「想起」問題 ---"
echo ""
echo "Q: テキストファイルの行数を数えるコマンドは？"
echo ""
echo "知っている人: wc -l"
echo "知らない人:   ... （何を調べればいいかもわからない）"
echo ""
echo "GUIなら："
echo "  テキストエディタで開く → ステータスバーに行数が表示される"
echo "  → 「行数を数えるコマンド名」を知らなくても目的を達成できる"
echo ""

echo "--- --help による自己文書化 ---"
echo ""
echo "CLIツールは --help で機能を「発見」できる:"
echo ""
wc --help 2>&1 | head -15
echo ""
echo "→ --helpは存在するが、まず'wc'というコマンド名を知っている必要がある"
echo "  GUIのメニューとは異なり、'存在を知らないコマンド'は発見できない"
```

```bash
# aproposによるコマンド検索（CLIの「再認」への歩み寄り）
echo "--- apropos: CLIでの機能検索 ---"
echo ""

# manデータベースを更新
apt-get update -qq > /dev/null 2>&1
apt-get install -y -qq man-db > /dev/null 2>&1
mandb -q 2>/dev/null || true

echo "Q: 「行数を数える」コマンドを探したい"
echo "コマンド: apropos 'line count'"
echo ""
apropos "line count" 2>/dev/null || echo "（該当なし — キーワード選びが難しい）"
echo ""

echo "コマンド: apropos 'word count'"
echo ""
apropos "word count" 2>/dev/null || echo "（該当なし）"
echo ""

echo "→ aproposはmanページのキーワード検索ができるが:"
echo "  1. 検索キーワード自体を「想起」する必要がある"
echo "  2. ヒットするかはmanページの記述に依存する"
echo "  3. GUIの「メニューを見れば使える機能がわかる」とは根本的に異なる"
echo ""
echo "これがCLIの構造的弱点: 「何ができるか」の発見が困難"
echo "ただし、この弱点はtldr, man, --helpなどで緩和できる"
```

### 演習4：認知モデルの違いを可視化する

```bash
echo "=============================================="
echo " 認知モデルの比較: 同一タスクでの操作手順"
echo "=============================================="
echo ""

echo "タスク: 'カレントディレクトリのうち、サイズが1KB以上のファイルを"
echo "         更新日時の新しい順に5件表示する'"
echo ""

# テストファイルの準備
cd /tmp/gui-vs-cli/project
for i in $(seq 1 20); do
    dd if=/dev/urandom bs=$((RANDOM % 2048 + 100)) count=1 of="data_${i}.bin" 2>/dev/null
    sleep 0.1  # 更新日時をずらす
done

echo "--- CLI での操作 ---"
echo ""
echo "コマンド:"
echo '  find . -maxdepth 1 -type f -size +1k -printf "%T@ %s %f\n" | sort -rn | head -5 | awk "{print \$2, \$3}"'
echo ""
echo "結果:"
find . -maxdepth 1 -type f -size +1k -printf "%T@ %s %f\n" 2>/dev/null | sort -rn | head -5 | awk '{print $2, $3}' || \
    ls -lS *.bin 2>/dev/null | awk '$5 >= 1024 {print $5, $9}' | head -5
echo ""

echo "操作の認知プロセス（CLI -- 想起ベース）:"
echo "  1. 'find' コマンドの存在を知っている必要がある"
echo "  2. -size +1k オプションを記憶から引き出す"
echo "  3. -printf のフォーマット文字列を構築する"
echo "  4. sort, head, awk の組み合わせを設計する"
echo "  → 各段階で「想起」が必要。初心者には困難"
echo "  → 一度書けば記録・再利用・自動化が可能"
echo ""

echo "操作の認知プロセス（GUI -- 再認ベース）:"
echo "  1. ファイルマネージャを開く（アイコンをクリック）"
echo "  2. 「表示」メニューから「詳細」を選ぶ"
echo "  3. 「サイズ」列のヘッダをクリックしてソート"
echo "  4. 1KB未満のファイルを目視で除外"
echo "  5. 「更新日時」列のヘッダをクリックして再ソート"
echo "  → 各段階で選択肢が「見えている」。初心者でも操作可能"
echo "  → 操作手順の記録・再利用・自動化は困難"
echo ""

echo "=============================================="
echo " 結論: 優劣ではなく、認知モデルの違い"
echo "=============================================="
echo ""
echo "  GUI: 発見しやすい（再認）→ 初心者に優位"
echo "        操作が直感的 → 探索的なタスクに適する"
echo "        記録・再現が困難 → 自動化に不向き"
echo ""
echo "  CLI: 発見しにくい（想起）→ 学習コストが高い"
echo "        操作がテキスト → 組み合わせ・自動化に適する"
echo "        記録・再現が容易 → 反復タスクに強い"
```

ハンズオンの自動セットアップスクリプトは `handson/command-line/11-gui-shock/setup.sh` を参照してほしい。

---

## 6. まとめと次回予告

### この回の要点

第一に、GUIの源流はXerox PARC以前に遡る。1963年のIvan SutherlandのSketchpadがグラフィカルな対話の技術的基盤を示し、1968年のDoug Engelbartの「Mother of All Demos」がマウス、ウィンドウ、ハイパーテキストを含む未来のコンピューティングビジョンを披露した。GUIは一夜にして現れたのではなく、少なくとも20年にわたる研究の蓄積の上に成立した。

第二に、Xerox Alto（1973年）がGUIパラダイムの原型を作り、Xerox Star（1981年）が最初の商用化を試み、Apple Lisa（1983年）を経て、Macintosh（1984年、2,495ドル）が初めてGUIを「大衆に届く価格」で提供した。技術の問題ではなくコストの問題であり、「正しい技術」を「手が届く価格」で届けた者が勝った。

第三に、Ben Shneidermanの「直接操作」理論（1983年）は、GUIの使いやすさに認知科学的な根拠を与えた。操作対象の継続的な可視化、迅速で可逆的な操作、コマンド構文の排除という3つの原則は、人間の認知特性に適合する設計だ。

第四に、GUIは「再認（recognition）」に基づき、CLIは「想起（recall）」に基づく。再認は想起より認知的負荷が低いため、GUIは初心者にとって学習コストが低い。だが、エキスパートにとっては想起ベースの操作が効率で上回る場合がある。これは「優劣」ではなく「認知モデルの違い」だ。

第五に、「CLIは死ぬ」という予言は1984年（Macintosh）、1995年（Windows 95）、2007年（iPhone）と繰り返されたが、すべて外れた。Neal Stephensonが1999年のエッセイで指摘したように、GUIはCLIの機能を「メタファーの層で隠蔽する」が、メタファーの限界を超えた操作――ループ、条件分岐、自動化――にはCLIが不可欠だ。

### 冒頭の問いへの暫定回答

GUIの登場は、本当にCLIの「終わり」を意味したのか。

暫定的な答えはこうだ。**GUIの登場はCLIの終わりではなく、インターフェースのレイヤーが一つ追加されたことを意味する。** GUIは「発見しやすさ」と「直感的な操作」において構造的に優れている。だが、CLIは「組み合わせ可能性」と「再現可能性」において構造的に優れている。この二つの認知モデルは、置き換え関係ではなく補完関係にある。

GUIが「死なせようとしたCLI」は、なぜ死ななかったのか。その答えの核心――自動化、再現性、組み合わせの力――は、次回で深く掘り下げる。

### 次回予告

次回、第12回「なぜCLIは死ななかったのか――自動化・再現性・組み合わせの力」では、前回と今回で提示した問いの「答え」に正面から取り組む。

40年間「死ぬ」と言われ続けたCLIが、なぜ開発者の基本ツールであり続けるのか。SSHによるリモート操作、シェルスクリプトによる自動化、Docker CLI/kubectlに象徴されるクラウドネイティブ時代のCLI必然性。「テキストストリーム」が持つ構造的優位性――組み合わせ可能性（composability）、再現性（reproducibility）、リモート操作の容易性――を、具体的なタスク比較を通じて検証する。

あなたは、自分が毎日CLIで行っている操作のうち、GUIでは代替できないものがいくつあるか、数えたことがあるだろうか。

---

## 参考文献

- Doug Engelbart, "The Mother of All Demos", ACM/IEEE Fall Joint Computer Conference, December 9, 1968, <https://web.stanford.edu/dept/SUL/library/extra4/sloan/mousesite/1968Demo.html>
- Ivan Sutherland, "Sketchpad: A Man-Machine Graphical Communication System", PhD thesis, MIT, 1963, <https://en.wikipedia.org/wiki/Sketchpad>
- Computer History Museum, "Xerox Alto", <https://www.computerhistory.org/revolution/input-output/14/347>
- ACM Turing Award, "Alan Kay", <https://amturing.acm.org/award_winners/kay_3972189.cfm>
- Interface Experience, "Xerox Star 8010 Information System, 1981", <https://interface-experience.org/objects/xerox-star-8010-information-system/>
- Stanford University, "The Xerox PARC Visit", <https://web.stanford.edu/dept/SUL/sites/mac/parc.html>
- AppleInsider, "Macintosh launched on Jan 24, 1984 and changed the world", <https://appleinsider.com/articles/19/01/24/apple-launched-macintosh-on-january-24-1984-and-changed-the-world----eventually>
- Wikipedia, "Apple Lisa", <https://en.wikipedia.org/wiki/Apple_Lisa>
- Wikipedia, "1984 (advertisement)", <https://en.wikipedia.org/wiki/1984_(advertisement)>
- Ben Shneiderman, "Direct Manipulation: A Step Beyond Programming Languages", IEEE Computer, Vol.16, No.8, August 1983, pp.57-69, <https://www.cs.umd.edu/~ben/papers/Shneiderman1983Direct.pdf>
- Jakob Nielsen, "Memory Recognition and Recall in User Interfaces", Nielsen Norman Group, <https://www.nngroup.com/articles/recognition-and-recall/>
- The Marginalian, "Steve Jobs on Why Computers Are Like a Bicycle for the Mind (1990)", <https://www.themarginalian.org/2011/12/21/steve-jobs-bicycle-for-the-mind-1990/>
- Wikipedia, "Windows 95", <https://en.wikipedia.org/wiki/Windows_95>
- Wikipedia, "Windows 1.0", <https://en.wikipedia.org/wiki/Windows_1.0>
- Tom's Hardware, "Microsoft's Windows 95 release was 30 years ago today", <https://www.tomshardware.com/software/windows/microsofts-windows-95-release-was-30-years-ago-today-the-first-time-software-was-a-pop-culture-smash>
- Neal Stephenson, "In the Beginning was the Command Line", 1999, <https://www.nealstephenson.com/in-the-beginning-was-the-command-line.html>
