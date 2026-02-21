# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第3回：対話の始まり――CTSSとタイムシェアリングの革命

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 「コンピュータと対話する」という概念が、いつ、誰によって実現されたか
- John McCarthyの1959年タイムシェアリング提案とJ.C.R. Lickliderの「Man-Computer Symbiosis」
- CTSS（Compatible Time-Sharing System, 1961年）の技術的仕組みと歴史的意義
- タイムシェアリングの技術的前提条件――コンテキストスイッチ、メモリ保護、スケジューリング
- Multicsの野心とその挫折がUNIXに繋がった経緯
- simhエミュレータで初期UNIXの対話環境を追体験するハンズオン

---

## 1. プロンプトが返ってくるという感覚

1990年代の後半、私は大学の計算機室でtelnetコマンドを打っていた。

```
$ telnet remote-server.example.ac.jp
```

Enter。数秒の沈黙。そして画面に現れる `login:` の文字列。ユーザー名を入力し、パスワードを打つ。すると `$` が表示される。プロンプトだ。

物理的には数十キロ離れた場所にあるマシンが、私のキーボード入力を待っている。`ls` と打てばファイル一覧が返る。`cat` と打てばファイルの中身が表示される。回線越しに、コンピュータと「会話」している。

この体験を、当時の私は特別なものとは思わなかった。コンピュータとはそういうものだろう、と。コマンドを打てば結果が返る。それが「普通」だった。

だが前回、バッチ処理の世界を辿って気づいた。私が「普通」だと思っていた対話的コンピューティングは、数十年にわたる技術的闘争の結果だった。パンチカードを提出して翌日結果を受け取る世界から、コマンドを打って即座に結果が返る世界へ。この跳躍は、自然に起きたものではない。

「コンピュータと会話する」という概念を最初に実現したのは誰か。

その答えは1961年のMITにある。Fernando Corbatoという物理学者が、一台のIBM 709を改造し、4人のユーザーが同時に対話的にコンピュータを使う実験に成功した。Compatible Time-Sharing System――CTSSと名付けられたそのシステムは、私たちが今日「ターミナル」と呼んでいるものの直接の先祖である。

あなたがターミナルを開いてプロンプトが表示されるとき、その背後には60年以上の歴史がある。「コンピュータが人間の入力を待つ」という、かつては許されなかった贅沢が、いかにして「当然」になったのか。その物語を追おう。

---

## 2. タイムシェアリングの構想――McCarthyとLicklider

### 1959年1月、McCarthyのメモ

バッチ処理の非効率に最初に異議を唱えたのは、John McCarthyだった。

1959年1月1日、MITのMcCarthyはP.M. Morse教授宛のメモ「A Time Sharing Operator Program for our Projected IBM 709」を書いた。タイトルが示す通り、一台のIBM 709を複数のユーザーで時間分割して共有する「タイムシェアリング・オペレータプログラム」の構想である。McCarthyはこのメモで、コンピュータの応答時間を劇的に短縮し、問題解決に要する時間を5分の1に削減できると推定した。

McCarthyの提案の核心はこうだ。コンピュータのCPUは高速だが、入出力装置は遅い。人間がキーボードを打つ速度はさらに遅い。ならば、一人のユーザーがキーボード入力を考えている間に、CPUは別のユーザーの計算を処理すればよい。コンピュータの「待ち時間」を、別のユーザーの「計算時間」で埋める。この発想は単純だが、バッチ処理の経済合理性を根底から覆すものだった。

バッチ処理は「コンピュータの稼働率」を最大化するシステムだった。タイムシェアリングは「人間の応答時間」を最小化するシステムである。最適化の対象が、コンピュータから人間に逆転した。

興味深いことに、同じ1959年、英国のChristopher Stracheyも独立にタイムシェアリングの概念を記述している。McCarthyの構想は主に口頭で伝えられることが多く、MITのFanoとCorbatoが1966年のScientific American誌の記事でStracheyにクレジットを与えた際、McCarthyが異議を唱えた。Corbatoはファイルの中からMcCarthyの1959年のメモを発見して驚いたという。技術史における「誰が最初か」という問題は、常に複雑だ。

### 1960年、Lickliderの「人間とコンピュータの共生」

McCarthyの構想が「こうすべきだ」という工学的提案だったとすれば、J.C.R. Lickliderの論文は「こうなるだろう」という未来の描写だった。

1960年3月、LickliderはIRE Transactions on Human Factors in Electronicsに「Man-Computer Symbiosis」を発表した。この論文でLickliderは、人間とコンピュータが「共生」する未来を描いた。「共生」という生物学の用語を選んだことに注目してほしい。人間がコンピュータを「使う」のではなく、人間とコンピュータが互いの長所を補い合いながら「協調する」。

論文の中で、Lickliderは自身の業務時間を分析した結果を報告している。「思考」に費やされる時間のうち、大部分は実際の思考ではなく、思考の「準備」――データの検索、グラフの作成、計算の段取り――に消費されていた。もしコンピュータがこれらの準備作業をリアルタイムで代行してくれれば、人間は「本当の思考」に集中できる。

この構想の実現には、一つの前提条件があった。コンピュータが人間の入力にリアルタイムで応答すること、つまり対話的コンピューティングが必要だったのだ。

Lickliderは1962年、ARPA（後のDARPA）の情報処理技術局（IPTO）局長に就任した。この立場を利用して、彼はタイムシェアリング研究に資金を注ぎ込んだ。MITのProject MAC、UCLA、UC Berkeleyへの研究助成。Lickliderの資金提供がなければ、タイムシェアリングの研究はこれほど急速には進まなかっただろう。

思想家が権力を持つと、世界が変わる。Lickliderはそのまれな例だ。

---

## 3. CTSSの誕生――1961年11月、MITの実験

### Fernando Corbatoの挑戦

思想を現実に変えたのは、Fernando Jose Corbato（1926-2019）だった。

CorbatoはMIT計算センターの副所長であり、物理学のPhDを持つ研究者だった。計算センターは大学の研究者にコンピュータ資源を提供する組織であり、Corbatoはバッチ処理の非効率を日々目の当たりにしていた。研究者がカードデッキを提出し、数時間後にエラーメッセージを受け取り、カードを修正して再提出する。この繰り返しが研究の進捗を致命的に遅くしていた。

Corbatoは、McCarthyの構想を実装に移すことを決意した。Marjorie DaggettとRobert Daleyの二人のプログラマと共に、MITのIBM 709上にタイムシェアリングシステムの開発を開始した。

1961年11月、Corbatoはデモンストレーションを行った。4台のFlexowriter端末（電動タイプライター型の端末）が接続され、4人のユーザーが同時にログインしてプログラムの編集・コンパイル・実行を行う。各ユーザーには、あたかも自分がコンピュータを独占しているかのような環境が提供された。

このシステムはCompatible Time-Sharing System――CTSSと名付けられた。「Compatible」という名称には重要な意味がある。バッチモードで動作する既存のバイナリプログラムが、対話モードでもそのまま実行できることを意味していた。既存のソフトウェア資産との互換性を維持しながら、新しいパラダイムを導入する。このプラグマティズムが、CTSSの成功の鍵だった。

### CTSSのハードウェア構成

CTSSが動作したIBM 7094は、通常の製品仕様とは異なる改造が施されていた。MIT専用の特注仕様（IBMの用語でRPQ: Request for Price Quotation）である。

通常のIBM 7094はコアメモリを1バンク持つ。CTSSの7094は、これを2バンクに拡張した。各バンクは32,768語（1語は36ビット）の容量を持つ。

```
IBM 7094 for CTSS（MIT特注改造）:

┌─────────────────────────────────────┐
│        メモリバンクA（32K語）        │
│   タイムシェアリング・スーパーバイザ  │
│   （OS本体）                        │
│   ソフトウェア割り込みでのみアクセス  │
├─────────────────────────────────────┤
│   メモリ境界レジスタ（保護機構）     │
├─────────────────────────────────────┤
│        メモリバンクB（32K語）        │
│   ユーザープログラム                 │
│   （現在実行中の1人分）              │
└─────────────────────────────────────┘

追加ハードウェア:
- クロック割り込み（タイマー）
- メモリ保護機構
- 特定命令のトラップ機能
```

バンクAにはスーパーバイザ（今日で言うOSカーネル）が常駐する。バンクBには現在実行中のユーザープログラムが配置される。メモリ境界レジスタが両者の間に壁を作り、ユーザープログラムがスーパーバイザのメモリ領域にアクセスすることを防ぐ。スーパーバイザの機能はソフトウェア割り込み（現代のシステムコールに相当）でのみ呼び出せる。

この設計は、現代のOSにおけるカーネル空間/ユーザー空間の分離の原型だ。あなたのLinuxマシンが `sudo` を要求するとき、その背後にある「特権レベルの分離」という概念は、1961年のCTSSにまで遡る。

### CTSSのスケジューリング

CTSSの最も革新的な技術的貢献は、プロセッサスケジューリングアルゴリズムだった。

複数のユーザーが同時にコンピュータを使うためには、CPUの時間をユーザー間で配分しなければならない。CTSSは「タイムクォンタム」という概念を導入した。各ユーザープログラムには200ミリ秒のCPU時間が割り当てられる。200ミリ秒が経過すると、クロック割り込みが発生し、CPUの制御がスーパーバイザに戻る。スーパーバイザは現在のユーザープログラムの状態（レジスタの内容、プログラムカウンタなど）を保存し、次のユーザープログラムの状態を復元して実行を再開する。これがコンテキストスイッチだ。

```
CTSSのタイムシェアリング動作:

時間 →
─────────────────────────────────────────→

ユーザーA: [実行200ms]         [実行200ms]         [実行200ms]
ユーザーB:          [実行200ms]         [入力待ち...]
ユーザーC:                              [実行200ms]
ユーザーD:                                       [実行200ms]
スーパーバイザ: [切替][切替][切替][切替][切替][切替][切替]

← 各ユーザーにとっては「自分がコンピュータを独占している」ように見える →
```

だが単純なラウンドロビン方式では不十分だった。あるユーザーが長時間の計算を実行している場合、200ミリ秒ごとにコンテキストスイッチが発生し、そのたびにプログラムのメモリ内容をディスクに退避して別のプログラムを読み込む（当時はスワップアウト/スワップイン）必要がある。このオーバーヘッドが無視できない。

Corbatoは多段フィードバックキューを考案した。最初の200ミリ秒で処理が完了しなかったプログラムは、次回はより長いタイムクォンタム（たとえば400ミリ秒）を割り当てられるが、優先度は下がる。短い処理（対話的コマンド）は高優先度のキューに留まり、即座にCPU時間を得られる。長い計算は低優先度のキューに移動し、大きなタイムクォンタムを与えられるが、順番が回ってくるまでの待ち時間は長くなる。

この設計は巧妙だった。対話的なユーザー（コマンドを打って結果を待つ人）は、応答時間が短くなる。計算集約的なジョブ（科学計算など）は、コンテキストスイッチのオーバーヘッドが減る。人間の「体感速度」を最適化しつつ、システム全体のスループットも維持する。

Corbatoが考案したこの多段フィードバックキューの変種は、現代のほとんどのOSで使用されている。Linuxの `CFS`（Completely Fair Scheduler）も、macOSのスケジューラも、根底にある思想はCTSSのスケジューリングに遡る。1990年のACMチューリング賞は、このCorbatoの「汎用・大規模タイムシェアリングおよびリソース共有コンピュータシステムCTSSとMulticsの概念の組織化と開発を主導した先駆的業績」に対して授与された。

### CTSSのコマンド体系

CTSSのユーザーインターフェースは、今日のコマンドラインの原型と呼んでよい。

初期のCTSSには、以下のコンソールコマンドが実装されていた。

| コマンド | 機能                              |
| -------- | --------------------------------- |
| `LOGIN`  | ログイン（パスワード認証）        |
| `LOGOUT` | ログアウト                        |
| `LISTF`  | ファイル一覧の表示（`ls` の先祖） |
| `INPUT`  | テキスト入力                      |
| `EDIT`   | テキスト編集                      |
| `MAD`    | MADコンパイラの実行               |
| `FAP`    | FAPアセンブラの実行               |
| `LOAD`   | プログラムのロード                |
| `START`  | プログラムの実行開始              |
| `PRINTF` | ファイルの内容を印刷              |

`LOGIN` でログインし、`LISTF` でファイルを確認し、`EDIT` でプログラムを編集し、コンパイルして実行する。この「ログイン→ファイル操作→編集→実行」という流れは、2026年の今も私たちが毎日繰り返しているワークフローだ。

特筆すべきは `LOGIN` コマンドの存在だ。CTSSは世界で最初にパスワードログインを実装したコンピュータシステムとされる。タイムシェアリングで複数のユーザーが同じコンピュータを共有する以上、個人のファイルを保護する仕組みが必要だった。Corbatoはパスワード認証を導入した。

ただし、当時のパスワードは平文でファイルに保存されていた。ハッシュ化も暗号化もない。1966年春、MITの大学院生Allan Scherrは、マスターパスワードファイルの印刷をシステムに要求するだけで、全ユーザーのパスワードを入手した。世界最初のパスワードハッキングである。セキュリティの歴史は、パスワードの歴史と同じ日に始まったと言ってよい。

### CTSSの運用

1961年11月のデモンストレーションの後、CTSSはIBM 7090、続いてIBM 7094へと移行しながら改良が続けられた。1963年夏、MIT計算センターで定常サービスが開始された。研究者たちはもはやカードデッキを提出して翌日結果を受け取る必要がなくなった。端末の前に座り、プログラムを書き、即座にコンパイルし、エラーを見て修正する。このフィードバックループの短縮が、研究の生産性を劇的に向上させた。

CTSSは1968年まで運用された。7年間の運用期間中、このシステムは単なる実験にとどまらず、後の情報科学の基盤となる多くの成果を生んだ。世界初のパスワードシステム、後にMulticsへと発展するタイムシェアリングの設計思想、そして多段フィードバックキューによるスケジューリングアルゴリズム。

---

## 4. タイムシェアリングの技術的前提条件

CTSSの歴史的意義を理解するためには、タイムシェアリングが「なぜ難しかったのか」を技術的に理解する必要がある。

### コンテキストスイッチ

タイムシェアリングの核心は、一台のCPUで複数のプログラムを「同時に」実行することだ。物理的にはCPUは一つしかないので、実際には高速に切り替えて「同時に見える」ようにする。この切り替えがコンテキストスイッチである。

コンテキストスイッチとは、現在実行中のプロセスの状態（レジスタの値、プログラムカウンタ、スタックポインタ、メモリマッピングの情報など）をメモリに退避し、次に実行するプロセスの状態をメモリから復元する操作だ。

```
コンテキストスイッチの流れ:

プロセスA実行中 → タイマー割り込み発生
  ↓
スーパーバイザに制御移行
  ↓
プロセスAの状態を保存（レジスタ、PC、フラグ等）
  ↓
次に実行すべきプロセスを選択（スケジューリング）
  ↓
プロセスBの状態を復元
  ↓
プロセスBの実行を再開
```

この操作にはコストがかかる。CTSSの時代、コンテキストスイッチにはユーザープログラム全体のメモリ内容をドラムメモリに退避し、次のユーザープログラムの内容をドラムメモリからコアメモリに読み込む作業が含まれていた（CTSSは仮想メモリを持たなかったため）。このスワップ操作に数十ミリ秒を要した。200ミリ秒のタイムクォンタムに対して、スワップに数十ミリ秒。オーバーヘッドは決して小さくなかった。

現代のOSでは、仮想メモリとMMU（Memory Management Unit）のおかげで、コンテキストスイッチのコストは大幅に低下している。メモリの物理的なスワップは（ページフォールトを除けば）不要で、ページテーブルの切り替えだけで済む。それでもコンテキストスイッチには数マイクロ秒のオーバーヘッドがあり、高性能コンピューティングでは今なお最適化の対象だ。

### メモリ保護

複数のユーザーが同じコンピュータを使う以上、あるユーザーのプログラムが別のユーザーのメモリ領域を読み書きしてはならない。さらに、ユーザープログラムがOSのメモリ領域を破壊してはならない。

CTSSでは、メモリ境界レジスタがこの保護を実現した。ユーザープログラムはバンクBのメモリにのみアクセスでき、バンクA（スーパーバイザ）へのアクセスはハードウェアによって遮断された。

現代のCPUでは、特権レベル（x86のリング0～3）やページテーブルの権限ビットがこの役割を果たしている。あなたのプログラムがセグメンテーション違反（segfault）で落ちるとき、それはCTSSの時代に導入されたメモリ保護機構の末裔が働いている。

### タイマー割り込み

バッチ処理では、一つのジョブが完了するまでCPUを占有していた。タイムシェアリングでは、一定時間が経過したらCPU制御をOSに返す仕組みが必要だ。ユーザープログラムが「自発的に」CPUを返すことを期待するのは非現実的だ（悪意あるプログラム、あるいは単に無限ループに陥ったプログラムが全ユーザーを道連れにする）。

CTSSでは、IBM 7094に追加されたクロック割り込み機構がこの問題を解決した。200ミリ秒ごとにハードウェア割り込みが発生し、現在のプログラムの実行を中断してスーパーバイザに制御を戻す。

この「非協力的プリエンプション」――実行中のプログラムの協力を必要とせずに制御を奪う仕組み――は、現代のOSにおけるプリエンプティブマルチタスクの原型だ。Windows 3.1の「協調的マルチタスク」（各プログラムが自発的にCPUを返す）が不安定だったのに対し、Windows NTやLinuxの「プリエンプティブマルチタスク」が安定しているのは、CTSSの時代に確立されたこの設計原則のおかげである。

### これらの技術が意味するもの

コンテキストスイッチ、メモリ保護、タイマー割り込み。この三つの技術が揃って初めて、タイムシェアリングは可能になった。逆に言えば、この三つが欠けていた1950年代のハードウェアでは、タイムシェアリングは実現不可能だった。

McCarthyが1959年にタイムシェアリングを構想できたのは、ハードウェアの進歩がちょうどこれらの機能を実現可能にしつつあった時期だったからだ。アイデアと技術は独立に生まれない。思想はハードウェアが許す範囲でしか実現できず、ハードウェアは思想が示す方向に進化する。

---

## 5. CTSSの先にあったもの――MulticsとProject MAC

### Project MACの設立

CTSSの成功は、より大きな構想を呼び込んだ。

1963年7月1日、DARPAからの200万ドルの助成金を得て、MITにProject MACが設立された。「MAC」の頭字語の意味は議論があり、「Machine-Aided Cognition（機械支援認知）」とも「Multiple-Access Computer（多重アクセスコンピュータ）」とも言われる。初代ディレクターはRobert Fano。DARPA側でこの助成を推進したプログラムマネージャーは、他ならぬJ.C.R. Lickliderだった。

1960年に「人間とコンピュータの共生」を論文で構想した思想家が、1962年にDARPA IPTO局長の権限を得て、1963年にMITのプロジェクトに資金を提供する。思想、権力、資金の連鎖がProject MACを生んだ。

Project MACはCTSSを運用基盤としつつ、その先のビジョンを掲げた。「コンピューティング・ユーティリティ」――電気や水道のように、コンピュータの計算資源を必要なときに必要なだけ使えるサービス。2026年のクラウドコンピューティングが実現していることを、1963年に構想していたのだ。

### Multicsの野心

「コンピューティング・ユーティリティ」の実現を目指して、1964年から新しいOSの設計が始まった。Multics（Multiplexed Information and Computing Service）。CTSSの後継として、MITのProject MAC、Bell Labs、General Electricの三者共同プロジェクトとして発足した。

GEの提案が1964年5月に選定され、8月に契約が結ばれた。Bell Labsは1964年11月にプロジェクトに参加した。Fernando Corbatoが全体を主導し、GE-645という新しいハードウェア上でゼロからOSを設計した。最初のGE-645が1967年1月にMITに納入された。

Multicsの設計は、現代のOSから見ても驚くほど先進的だった。

**階層ファイルシステム。** ルートディレクトリから枝分かれするツリー構造のファイルシステムは、Multicsが最初に実装した。あなたが `/home/user/documents/report.txt` というパスを打つとき、その概念はMulticsに遡る。

**リングベースのセキュリティ。** 0から7までの8段階の特権リングを持ち、数字が小さいほど高い権限を持つ。リング0はカーネル、外側のリングはユーザープログラム。この設計はIntel x86のプロテクションリングに直接影響を与えた。

**アクセス制御リスト（ACL）。** ファイルごとに、誰が読み取り・書き込み・実行できるかを細かく制御する仕組み。UNIXのファイルパーミッション（rwx）はMulticsのACLの簡略版と言える。

**単一レベルストア。** メインメモリとディスクの区別をOSが透過的に管理し、プログラマはメモリ管理を意識する必要がない。今日の仮想メモリの概念に通じる。

**動的リンク。** プログラムの実行中に必要なライブラリを動的にロードする仕組み。共有ライブラリ（`.so` や `.dll`）の原型だ。

これらの技術革新の一つ一つが、現代のOSの基盤となっている。

### Multicsの挫折と遺産

だがMulticsは、その野心の大きさゆえに苦しんだ。

開発は遅延に次ぐ遅延だった。コードは膨大に膨らみ、性能は目標に届かなかった。1969年、Bell Labsはプロジェクトから撤退した。Multicsの複雑さとコスト超過に見切りをつけたのだ。

この撤退が、コンピュータ史上最も重要な副産物を生んだ。Bell Labsに戻ったKen ThompsonとDennis Ritchieは、Multicsでの経験を踏まえて、よりシンプルなOSを設計した。Multicsの「多重化された（Multiplexed）」に対して、「単一化された（Uniplexed）」――UNICSと名付けられ、後にUNIXとなった。Multicsが「大きく複雑で堅牢なシステム」を目指したのに対し、UNIXは「小さくシンプルで柔軟なシステム」を目指した。Multicsの反動がUNIX哲学を生んだのだ。

1970年、GEのコンピュータ事業はHoneywellに売却された。HoneywellはMulticsを商用製品として販売し、1985年まで運用が続いた。Multicsは「失敗」ではない。ただ、その影響はMulticsそのものとしてではなく、UNIXという子孫を通じて世界に広まった。

### タイムシェアリングのもう一つの系譜――Dartmouth

MITが研究者向けのタイムシェアリングを追求した一方で、異なる哲学でタイムシェアリングに取り組んだ大学がある。Dartmouth Collegeだ。

1963年から開発が始まったDartmouth Time-Sharing System（DTSS）は、John KemenyとThomas Kurtzの二人の教授が主導した。彼らの哲学は明確だった。コンピューティングは研究者だけのものではない。学部生を含むすべての大学構成員が、図書館の本棚と同じくらい気軽にコンピュータを使えるべきだ。

1964年5月1日午前4時、College Hallの地下室で、KemenyとKurtzは隣り合う端末で同時に `RUN` と入力した。両方の端末に正しい結果が返った。タイムシェアリングとBASIC言語が同時に誕生した瞬間だった。

BASICはこのシステムのために設計された言語だ。プレインイングリッシュと高校代数に似た構文で、「プログラミングの素人」が数個のコマンドを覚えるだけでプログラムを書けるように設計された。

MITのCTSS/Multicsが「コンピューティングの先端を切り拓く」ことを目指したのに対し、DartmouthのDTSSは「コンピューティングを民主化する」ことを目指した。技術の歴史は常に、先端と普及の両軸で進む。

---

## 6. ハンズオン：対話的コンピューティングの原体験

CTSSそのもののエミュレーションは困難だが、simh（Computer History Simulation Project）を使えば、初期UNIXの対話的シェル環境を体験できる。CTSSの直系の子孫であるUNIXの対話環境で、「コンピュータと会話する」原体験を追う。

### 環境準備

Docker環境で作業する。

```bash
docker run -it --rm ubuntu:24.04 bash
```

コンテナ内で必要なパッケージをインストールする。

```bash
apt-get update && apt-get install -y simh curl
```

### 演習1：simhでPDP-11上のUNIX V6を起動する

UNIX V6（1975年）は、Thompson ShellというCTSSの直接的影響を受けたコマンドシェルを持つ。まずはディスクイメージを取得し、simhで起動する。

```bash
# 作業ディレクトリを作成
mkdir -p /workspace/timesharing-handson
cd /workspace/timesharing-handson

# UNIX V6のディスクイメージを取得
# （歴史的ソフトウェアの教育利用として）
curl -L -o unix_v6_rk.dsk.gz \
  "https://www.tuhs.org/Archive/Distributions/Research/Ken_Wellsch_v6/v6.gz"
gunzip unix_v6_rk.dsk.gz
mv unix_v6_rk.dsk rk0.dsk

# simhの設定ファイルを作成
cat > pdp11.ini << 'EOF'
set cpu 11/40
set cpu u18
attach rk0 rk0.dsk
boot rk0
EOF

echo "=== UNIX V6 起動準備完了 ==="
echo "以下のコマンドで起動:"
echo "  pdp11 pdp11.ini"
echo ""
echo "起動後、'@' プロンプトが表示されたら:"
echo "  unix と入力してEnter"
echo "ログインプロンプトが表示されたら:"
echo "  root と入力（パスワードなし）"
```

> **注意：** UNIX V6のディスクイメージの入手先やURLは変更される可能性がある。The Unix Heritage Society（TUHS）のアーカイブが最も信頼できるソースだが、利用条件を確認すること。simhでの実行が困難な場合は、演習2以降で対話的コンピューティングの本質を別の方法で体験する。

### 演習2：タイムシェアリングの疑似体験

CTSSの核心は「複数ユーザーが1台のCPUを共有する」ことだった。これをシェルスクリプトで疑似体験する。

```bash
cd /workspace/timesharing-handson

# === タイムシェアリングシミュレーター ===
cat > timesharing_sim.sh << 'ENDSIM'
#!/bin/bash
set -euo pipefail

echo "=============================================="
echo "  CTSS-STYLE TIMESHARING SIMULATOR"
echo "  Demonstrating CPU time-slicing (200ms quantum)"
echo "=============================================="
echo ""

# 4人のユーザーのジョブを定義
declare -a USERS=("CORBATO" "DAGGETT" "DALEY" "MCCARTHY")
declare -a JOBS=(
  "MAD compiler: matrix multiplication"
  "EDIT: thesis chapter 3"
  "FAP assembler: I/O routine"
  "LISP interpreter: symbolic computation"
)
declare -a REMAINING=(5 3 4 2)  # 各ユーザーの残りスライス数

QUANTUM_MS=200
TOTAL_SWITCHES=0

echo "[SUPERVISOR] System initialized. Quantum: ${QUANTUM_MS}ms"
echo "[SUPERVISOR] ${#USERS[@]} users logged in via Flexowriter terminals"
echo ""

# 多段フィードバックキューの簡易シミュレーション
ROUND=1
while true; do
    ALL_DONE=true
    echo "--- Round $ROUND (Time: $((ROUND * QUANTUM_MS))ms) ---"

    for i in "${!USERS[@]}"; do
        if [ "${REMAINING[$i]}" -gt 0 ]; then
            ALL_DONE=false
            echo "  [CPU → ${USERS[$i]}] Running: ${JOBS[$i]}"
            echo "    Context switch: save registers, load user $i memory"
            sleep 0.3  # 体感用の遅延

            REMAINING[$i]=$((REMAINING[$i] - 1))
            TOTAL_SWITCHES=$((TOTAL_SWITCHES + 1))

            if [ "${REMAINING[$i]}" -eq 0 ]; then
                echo "    *** JOB COMPLETED for ${USERS[$i]} ***"
            else
                echo "    Quantum expired (${QUANTUM_MS}ms). Preempting."
            fi
        fi
    done

    if $ALL_DONE; then
        break
    fi

    ROUND=$((ROUND + 1))
    echo ""
done

echo ""
echo "=============================================="
echo "  SIMULATION COMPLETE"
echo "  Total context switches: $TOTAL_SWITCHES"
echo "  Total simulated time: $((ROUND * QUANTUM_MS * ${#USERS[@]}))ms"
echo ""
echo "  Key insight:"
echo "  Each user experienced responsive interaction"
echo "  despite sharing a single CPU."
echo "  MCCARTHY's short job finished first (2 quanta)"
echo "  CORBATO's long job finished last (5 quanta)"
echo "  This is the multilevel feedback queue in action."
echo "=============================================="
ENDSIM
chmod +x timesharing_sim.sh

echo "=== タイムシェアリングシミュレーター作成完了 ==="
bash timesharing_sim.sh
```

このシミュレーションで注目すべき点は、McCarthyの短いジョブ（2クォンタム）が最初に完了し、Corbatoの長いジョブ（5クォンタム）が最後に完了することだ。対話的な短いコマンドは素早く応答が返り、長い計算はバックグラウンドで段階的に処理される。これが多段フィードバックキューの効果であり、CTSSの設計の核心だった。

### 演習3：対話的コンピューティングの価値を実感する

バッチ処理と対話的処理の本質的な違いを、「問題解決の過程」を通じて体験する。

```bash
cd /workspace/timesharing-handson

# テスト用のサーバーログを生成
cat > generate_logs.sh << 'ENDGEN'
#!/bin/bash
set -euo pipefail

mkdir -p logs
SERVICES=("auth" "api" "db" "cache" "worker")
LEVELS=("INFO" "INFO" "INFO" "WARN" "ERROR")
MESSAGES=(
  "Request processed successfully"
  "Connection established"
  "Query executed in 45ms"
  "Response time exceeded threshold: 2100ms"
  "Connection refused: max connections reached"
  "Authentication failed for user admin"
  "Cache hit ratio: 0.87"
  "Worker process restarted"
  "Database connection pool exhausted"
  "TLS handshake timeout"
)

for i in $(seq 1 200); do
  hour=$(printf '%02d' $((RANDOM % 24)))
  minute=$(printf '%02d' $((RANDOM % 60)))
  second=$(printf '%02d' $((RANDOM % 60)))
  service=${SERVICES[$((RANDOM % ${#SERVICES[@]}))]}
  level=${LEVELS[$((RANDOM % ${#LEVELS[@]}))]}
  msg=${MESSAGES[$((RANDOM % ${#MESSAGES[@]}))]}
  echo "2025-03-15 ${hour}:${minute}:${second} [${level}] ${service}: ${msg}"
done | sort > logs/server.log

echo "200行のサーバーログを生成: logs/server.log"
ENDGEN
chmod +x generate_logs.sh
bash generate_logs.sh

echo ""
echo "=============================================="
echo "[演習3] 対話的な問題解決 vs バッチ的な問題解決"
echo "=============================================="
echo ""

# --- バッチ的アプローチ ---
echo "=== アプローチA: バッチ的（事前に全分析を設計） ==="
echo ""
echo "バッチ処理では、実行前にすべての分析を設計する必要がある。"
echo "結果を見てから次の分析を決めることはできない。"
echo ""

cat > batch_analysis.sh << 'ENDBATCH'
#!/bin/bash
set -euo pipefail
LOG="logs/server.log"

echo "--- BATCH JOB: LOG ANALYSIS ---"
echo "STEP1: Level counts"
for level in INFO WARN ERROR; do
  count=$(grep -c "\[${level}\]" "$LOG" || true)
  echo "  ${level}: ${count}"
done
echo ""

echo "STEP2: Service counts"
for svc in auth api db cache worker; do
  count=$(grep -c "${svc}:" "$LOG" || true)
  echo "  ${svc}: ${count}"
done
echo ""

echo "STEP3: Hourly distribution"
awk '{split($2,t,":"); print t[1]":00"}' "$LOG" | sort | uniq -c | sort -rn | head -5
echo ""

echo "--- END BATCH JOB ---"
ENDBATCH
chmod +x batch_analysis.sh
bash batch_analysis.sh

echo ""
echo "=== アプローチB: 対話的（結果を見ながら探索） ==="
echo ""

# Step 1: まず全体像を把握
echo "--- Step 1: 全体像の把握（対話的判断の起点） ---"
echo '$ wc -l logs/server.log'
wc -l logs/server.log
echo ""

# Step 2: ERROR行を見る
echo "--- Step 2: ERRORを見てみる（最初の手がかり） ---"
echo '$ grep "\[ERROR\]" logs/server.log | head -5'
grep "\[ERROR\]" logs/server.log | head -5
echo ""

# Step 3: ERRORの結果を見て、サービス別に分析
echo "--- Step 3: ERRORを見て気づく →「dbとauthに多い？」 ---"
echo "    前のステップの結果を見て、次の分析を決定"
echo '$ grep "\[ERROR\]" logs/server.log | awk -F: "{print \$1}" | awk "{print \$NF}" | sort | uniq -c | sort -rn'
grep "\[ERROR\]" logs/server.log | awk '{for(i=1;i<=NF;i++) if($i ~ /:$/) print $i}' | sort | uniq -c | sort -rn
echo ""

# Step 4: 特定の問題に焦点を絞る
echo "--- Step 4: db関連のERRORに焦点 →「接続プールの問題？」 ---"
echo "    対話的に深掘り: 前の結果から仮説を立て、検証"
echo '$ grep "\[ERROR\]" logs/server.log | grep "db:"'
grep "\[ERROR\]" logs/server.log | grep "db:" || echo "  (該当なし)"
echo ""

echo "=============================================="
echo "  比較:"
echo "  バッチ的: 事前にすべての分析手順を設計。"
echo "           実行してみないとどこに問題があるかわからない。"
echo "  対話的:  結果を見て→仮説を立て→次の分析を決める。"
echo "           探索的な問題解決が可能。"
echo ""
echo "  CTSSが実現したのは、まさにこの「対話的探索」だった。"
echo "  1961年以前、プログラマはこの贅沢を持っていなかった。"
echo "=============================================="
```

対話的処理の本質は「フィードバックループの短さ」ではない。**フィードバックに基づいて次の行動を変えられること**だ。ERRORログを見て「dbサービスが多い」と気づき、dbに焦点を絞って深掘りする。この「気づき→方向転換」のサイクルは、バッチ処理では構造的に不可能だった。CTSSが人類に与えたのは、コンピュータとの対話を通じた探索的思考の手段だったのだ。

---

## 7. まとめと次回予告

### この回の要点

第一に、タイムシェアリングの構想は1959年にJohn McCarthyのメモとして文書化され、1960年にJ.C.R. Lickliderの「Man-Computer Symbiosis」によって思想的基盤が与えられた。McCarthyの工学的提案とLickliderの未来構想が、タイムシェアリング研究への道を開いた。

第二に、Fernando Corbatoは1961年11月、MITでCTSS（Compatible Time-Sharing System）のデモンストレーションを行い、世界初の汎用タイムシェアリングOSを実現した。4人のユーザーが同時に1台のIBM 709を対話的に使用した。CTSSは1963年から1968年まで定常運用された。

第三に、タイムシェアリングは三つの技術的前提条件を必要とした。コンテキストスイッチ（プロセス状態の保存と復元）、メモリ保護（ユーザー間およびOS/ユーザー間のアクセス制御）、タイマー割り込み（プリエンプティブな制御の奪取）。Corbatoが考案した多段フィードバックキューによるスケジューリングは、現代のOSにおけるプロセススケジューラの原型となった。

第四に、CTSSは世界初のパスワードログインシステムを実装し、また多くの技術革新を含むMulticsの母体となった。Multicsの挫折はUNIXの誕生につながり、CTSSの対話的コンピューティングの思想は形を変えて現代に生き続けている。

第五に、MITのCTSS/Multicsが「先端を切り拓く」ことを目指した一方、DartmouthのDTSSは「コンピューティングの民主化」を目指した。技術の歴史は先端と普及の両軸で進み、どちらも欠くことができない。

### 冒頭の問いへの暫定回答

「コンピュータと会話する」という概念を最初に実現したのは誰か。

暫定的な答えはこうだ。**構想はMcCarthyとLicklider、実装はCorbatoだった。** McCarthyが1959年にタイムシェアリングの工学的アイデアを提示し、Lickliderが1960年に「人間とコンピュータの共生」という思想的枠組みを提供し、Corbatoが1961年にCTSSとして実装した。

だが、「最初の実現者」を一人に帰することには注意が必要だ。CTSSはMarjorie DaggettとRobert Daleyの実装力、IBMのハードウェア改造への協力、MITの研究環境、そして何より「バッチ処理の非効率に我慢できなかった」多くの研究者の切実な需要があって初めて実現した。

あなたが `ls` と打ってプロンプトが返ってくるとき、それはCorbatoが60年以上前に実現した「贅沢」の延長線上にある。

### 次回予告

CTSSで対話的コンピューティングが実現したとき、ユーザーはFlexowriter端末――電動タイプライターの一種――を使っていた。紙に印字するテレタイプ端末だ。

だが、紙には限界がある。画面に出力された文字を消すことはできない。カーソルを動かすこともできない。出力はひたすら紙テープの上に印字され、巻物のように伸びていく。

やがて、CRT（ブラウン管）ディスプレイが端末に導入される。画面は書き換え可能になり、カーソルは自由に動くようになった。1963年のTeletype Model 33は、ASCIIの物理的な実装を提供した。1978年のDEC VT100は、ANSIエスケープシーケンスに準拠した決定版端末となった。

次回、第4回「テレタイプからCRT端末へ――"tty"の起源と端末の進化」では、あなたが毎日使っている `/dev/tty` の名前の由来と、80x24の画面がどこから来たのかを追う。`stty -a` の設定項目一つ一つに、物理端末の記憶が刻まれている。

あなたは、自分が使っている「ターミナル」が何を模倣しているか、知っているだろうか。

---

## 参考文献

- John McCarthy, "Memorandum to P. M. Morse Proposing Time-Sharing", 1959, <http://jmc.stanford.edu/computing-science/timesharing-memo.html>
- J.C.R. Licklider, "Man-Computer Symbiosis", IRE Transactions on Human Factors in Electronics, 1960, <https://groups.csail.mit.edu/medg/people/psz/Licklider.html>
- Fernando Corbato, Marjorie Daggett, Robert Daley, "An Experimental Time-Sharing System", Proceedings of the Spring Joint Computer Conference, 1962
- Multicians.org, "Compatible Time-Sharing System (1961-1973) Fiftieth Anniversary", <https://multicians.org/thvv/compatible-time-sharing-system.pdf>
- Multicians.org, "The IBM 7094 and CTSS", <https://www.multicians.org/thvv/7094.html>
- Wikipedia, "Compatible Time-Sharing System", <https://en.wikipedia.org/wiki/Compatible_Time-Sharing_System>
- ACM, "Fernando Corbato - A.M. Turing Award Laureate", <https://amturing.acm.org/award_winners/corbato_1009471.cfm>
- Multicians.org, "Multics History", <https://multicians.org/history.html>
- Wikipedia, "Multics", <https://en.wikipedia.org/wiki/Multics>
- Multicians.org, "Project MAC", <https://multicians.org/project-mac.html>
- Wikipedia, "Dartmouth Time-Sharing System", <https://en.wikipedia.org/wiki/Dartmouth_Time-Sharing_System>
- Dartmouth Library, "Sharing the Computer", <https://www.dartmouth.edu/library/rauner/exhibits/sharing-the-computer.html>
- GitHub, "simh/simh - The Computer History Simulation Project", <https://github.com/simh/simh>
- Wikipedia, "Time-sharing", <https://en.wikipedia.org/wiki/Time-sharing>

---

**次回：** 第4回「テレタイプからCRT端末へ――"tty"の起源と端末の進化」

---

_本記事は「ターミナルは遺物か――コマンドラインの本質を問い直す」連載の第3回です。_
_ライセンス：CC BY-SA 4.0_
