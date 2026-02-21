# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第13回：CLIとGUIの融合――IDEのターミナル、GUIのコマンドパレット

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- EmacsのM-xコマンド（1976年）が「名前でコマンドを実行する」パラダイムを確立した経緯
- Sublime TextのCommand Palette（2011年）がモダンエディタのUXを変革した理由
- VS Codeの統合ターミナル（2016年）がCLIとGUIの境界を溶かした設計思想
- macOS Spotlight（2005年）、Quicksilver（2003年）からRaycast（2020年）に至るランチャーの系譜
- コマンドパレットが「想起（recall）」と「再認（recognition）」を融合するハイブリッド設計である理由
- fzf（2013年）がCLI上で実現したfuzzy matchingの威力
- dmenu（2006年）からrofiに至る「UNIX的コマンドパレット」の設計
- キーボード駆動のGUIパターンをVS Code、fzf、dmenuで体験する

---

## 1. GUIの皮をかぶったCLI

2018年頃のことだ。私はVS Codeに移行して数ヶ月が経っていた。

それまではVimを20年近く使い続けてきた。`.vimrc`を育て、プラグインを厳選し、キーバインドを体に染み込ませた環境だ。移行には相当の抵抗があった。「GUIのエディタに堕落するのか」という、今にして思えば馬鹿げた自尊心が邪魔をしていた。

だが、VS Codeを使い始めて数週間後、私はあることに気づいた。

Ctrl+Shift+Pを押す。テキスト入力欄が現れる。`git checkout`とタイプすると、ブランチ一覧が表示される。選択してEnter。この動作は、見た目こそGUIだが、本質的にやっていることは「名前を指定してコマンドを実行する」行為だ。これはCLIではないか。

さらに気づく。Ctrl+Pでファイル名の一部をタイプすれば、プロジェクト内のファイルがfuzzy matchingで絞り込まれる。これは`find . -name "*keyword*"`の高速版だ。Ctrl+Shift+Fで全文検索すれば、`grep -r`と同じことが視覚的に表示される。

私が20年間Vimで叩いてきた`:w`、`:q`、`:s/old/new/g`、`:e filename`。これらはすべて「テキストを入力してコマンドを実行する」操作だ。VS CodeのCommand Paletteは、これと同じことを、より発見しやすい形で包み直している。

そして既視感に襲われた。EmacsのM-xだ。1976年から存在するあの仕組み。M-xを押し、コマンド名をタイプし、Enterで実行する。Emacsがとうの昔に実現していたことを、モダンIDEが再発明している。名前は「Command Palette」と洗練されたが、本質は何も変わっていない。

この連載は第11回でGUIの衝撃を、第12回でCLIが死ななかった理由を検証した。だが、CLIとGUIは本当に「対立」しているのか。むしろ、最も生産的なツールは両者の融合に向かっているのではないか。今回はその問いに取り組む。

---

## 2. 名前でコマンドを実行する――50年の系譜

### Emacs M-x：コマンドパレットの原型（1976年）

CLIとGUIの融合を語るうえで、まず遡るべきはEmacsのM-xコマンドだ。

1976年夏、MIT AI LabでRichard StallmanとGuy Steeleは、多数のTECO（Text Editor and Corrector）マクロパッケージを統一する作業に取り組んでいた。TECOは行指向のテキストエディタであり、マクロによって拡張可能だった。当時のMIT AI Labでは、各研究者が独自のTECOマクロ集を作り、名前の衝突やキーバインドの競合が問題になっていた。

Steeleは統一的なコマンド体系を設計し、Stallmanとともに実装した。この統合マクロパッケージが「EMACS」（Editing MACroS）と名付けられた。

EMacsの設計で画期的だったのは、M-x（Meta-xキー）による「名前指定コマンド実行」の仕組みだ。David A. Moonが設計した「MM（Meta-Meta）マクロ」の概念を発展させたもので、すべてのコマンドに説明的な英語名を与え、キーバインドに割り当てられていないコマンドでも名前を指定すれば実行できるようにした。

```
Emacs M-x の動作モデル:

  ユーザー操作:
    1. M-x（Meta-x）を押す
    2. ミニバッファにコマンド名をタイプする
       例: "replace-string"
    3. Enterで実行
    4. 引数を入力する

  設計思想:
    - すべてのコマンドは「名前」を持つ
    - キーバインドは「ショートカット」にすぎない
    - 名前を知っていれば、どのコマンドでも実行可能
    - Tab補完で名前の一部から候補を絞り込める

  → 50年後のCommand Paletteと本質的に同じ構造
```

この設計がなぜ重要か。それは、キーバインドの限界を突破したからだ。人間が記憶できるキーバインドの数には限界がある。Ctrl+何か、Alt+何か、Ctrl+Alt+何かと組み合わせても、せいぜい数十個が実用的な上限だ。だがEmacsのコマンドは数千個ある。M-xは、この「有限のキーバインド」と「膨大なコマンド」のギャップを埋める仕組みだった。

1984年にStallmanがGNU Emacsを開発した際にもこの設計は継承された。GNU EmacsのM-xは現在もまったく同じ原理で動作している。`M-x execute-extended-command`。この50年間変わらない仕組みが、2010年代にSublime TextのCommand Paletteとして「再発見」される。

### Vim：exコマンドという別の系譜

Emacsと双璧をなすVimの世界にも、「テキスト入力でコマンドを実行する」仕組みがある。

1991年11月2日、Bram MoolenaarはVim（Vi Imitation）のVersion 1.14をFred Fish disk #591で公開した。Vimのコロン（:）キーで入るexコマンドモードは、ed（1969年）→ex（1976年、Bill Joy）→vi→Vimという系譜を引き継いでいる。

```
ed/ex/vi/Vimのコマンド入力系譜:

  ed (1969年, Ken Thompson):
    コマンドは1文字 → p(print), d(delete), s(substitute)
    すべてがテキスト入力ベース

  ex (1976年, Bill Joy):
    edを拡張。:set, :map, :source などの設定コマンド追加

  vi (1976年, Bill Joy):
    exにビジュアルモードを追加。:で「exモード」に戻れる

  Vim (1991年, Bram Moolenaar):
    viを大幅拡張。:コマンドは数百に
    :help, :PlugInstall, :Git blame ...

  → コロンキーは「CLIへの入口」
  → GUIモードの中にCLIが埋め込まれている構造
```

Vimの設計で注目すべきは、「ビジュアルモード」と「コマンドモード」の明確な分離だ。ノーマルモードとインサートモードで視覚的にテキストを編集し（GUI的操作）、コロンキーでコマンドラインに降りる（CLI的操作）。この二つのモードを1キーで切り替えられる設計は、CLIとGUIの融合の原初的形態と見なせる。

### Sublime TextのCommand Palette――ゲームチェンジャー（2011年）

EmacsのM-xもVimのexコマンドも、「コマンド名を正確に知っている」ことを前提としていた。`M-x replace-string`と打つには、`replace-string`というコマンド名を記憶している必要がある。Tab補完で一部から推測はできるが、そもそも何という名前のコマンドがあるのかを知らなければ始まらない。

2011年、Jon SkinnerのSublime Text 2がこの問題を解決した。

Sublime Text 2のCommand Palette（Ctrl+Shift+P / Cmd+Shift+P）は、以下の点でEmacsのM-xを決定的にアップデートした。

第一に、**fuzzy matching**だ。`replace-string`を実行したければ、`reps`とだけタイプすれば候補に表示される。文字の一部をあいまいに入力するだけで、システムが意図を推測する。正確な名前を知っている必要はない。

第二に、**リアルタイムフィルタリング**だ。1文字タイプするごとに候補リストが即座に更新される。この即応性が「探索的操作」を可能にした。何という名前のコマンドがあるかわからなくても、キーワードを入力して「発見」できる。

第三に、**視覚的なリストの提示**だ。候補がドロップダウンリストとして表示され、キーバインドが横に併記される。ユーザーは「ああ、このコマンドにはキーバインドがあったのか」と視覚的に学習できる。

```
EmacsのM-x vs Sublime TextのCommand Palette:

  Emacs M-x (1976年):
    ┌──────────────────────────┐
    │ M-x replace-str[TAB]     │ ← Tab補完。前方一致のみ
    │ replace-string           │ ← 候補が1つに確定して補完
    └──────────────────────────┘
    特性: コマンド名を「ほぼ知っている」人向け
    問題: 何があるかわからないと使えない

  Sublime Text Command Palette (2011年):
    ┌──────────────────────────────────────────┐
    │ > reps                                    │ ← あいまい入力
    ├──────────────────────────────────────────┤
    │ ▸ Replace String          Ctrl+H         │ ← 候補リスト
    │   Replace in Files        Ctrl+Shift+H   │    キーバインド表示
    │   Toggle Regular Expression               │    スコアリング順
    └──────────────────────────────────────────┘
    特性: コマンド名を「なんとなく」知っている人向け
    強み: 何があるかわからなくても探索できる
```

Jon Skinner自身は、macOSのHelp > Searchメニュー（メニュー項目をテキスト入力で検索できる機能）から着想を得たと述べている。興味深いのは、macOSのこの機能自体が「GUIメニューをCLI的に検索する」仕組みだという点だ。GUIの中にCLIを埋め込む発想は、OSレベルですでに存在していた。

Sublime Text 2.0は2012年6月26日に正式リリースされ、Command Paletteはモダンエディタの標準機能となった。Atom（2014年パブリックベータ）、VS Code（2015年）、そしてJetBrains IDEの「Search Everywhere」（ダブルShift）と「Find Action」（Ctrl+Shift+A）。すべてがSublime Textの設計を参照し、あるいは並行して同じ解にたどり着いている。

---

## 3. 想起と再認の融合――コマンドパレットの設計思想

### 認知科学から見たCLIとGUIの本質的違い

第11回で、Ben Shneidermanの「直接操作」の原則とCLI/GUIの認知モデルの違いを分析した。ここでは、その議論をさらに掘り下げる。

Jakob Nielsenの「ユーザーインターフェースデザインのための10のユーザビリティヒューリスティック」の第6項は「Recognition rather than recall（想起よりも再認）」だ。オブジェクト、アクション、オプションを可視化し、ユーザーのメモリ負荷を最小限にすべき、という原則である。

GUIはこの原則を忠実に体現している。メニューバーには利用可能なアクションが列挙され、ツールバーにはアイコンが並ぶ。ユーザーは「何ができるか」を視覚的に確認し、選択する。これが「再認（recognition）」だ。見れば思い出せる。

対してCLIは「想起（recall）」を要求する。コマンド名、オプション、引数の構文を記憶から呼び出さなければならない。`grep -rn --include="*.py" "def main" .`を打つには、grep、-r、-n、--includeといった知識を記憶から想起する必要がある。目の前に選択肢は表示されない。

```
認知モデルの比較:

  再認（Recognition）― GUIの得意領域:
    ┌──────────────────────────────┐
    │ [ファイル] [編集] [表示]      │ ← 選択肢が見える
    │  新規作成   Ctrl+N           │ ← 見れば思い出す
    │  開く      Ctrl+O            │
    │  保存      Ctrl+S            │
    └──────────────────────────────┘
    認知負荷: 低（視覚的手がかりがある）
    探索コスト: 中（メニュー階層を辿る必要）
    エキスパート効率: 低（毎回メニューを辿る）

  想起（Recall）― CLIの得意領域:
    $ _                            ← 何もヒントがない
    $ grep -rn "pattern" .         ← 記憶から構築する
    認知負荷: 高（すべて記憶に依存）
    探索コスト: 高（manページを読む必要）
    エキスパート効率: 高（直接実行、組み合わせ可能）

  コマンドパレット ― 両者の融合:
    ┌──────────────────────────────┐
    │ > gr_                         │ ← 部分的な想起
    ├──────────────────────────────┤
    │ ▸ Search: Find in Files       │ ← 候補の再認
    │   Go to Reference             │    視覚的絞り込み
    │   Open Recent                 │    キーバインドの学習
    └──────────────────────────────┘
    認知負荷: 中（断片的な記憶で十分）
    探索コスト: 低（タイプするだけで発見）
    エキスパート効率: 中〜高（高速アクセス可能）
```

### コマンドパレットが解いた問題

コマンドパレットの本質は、「想起」と「再認」の間にある溝を埋めたことだ。

CLIの問題は、コマンド名を正確に想起できなければ何もできないことだ。`grep`という名前を知らなければ、テキスト検索する手段に到達できない。GUIの問題は、メニューの深い階層に機能が埋もれていることだ。「フォーマット > 段落 > インデント > 特殊」のような4階層のメニューを辿るのは、たとえ再認できても非効率だ。

コマンドパレットは両者の問題を同時に解決する。

第一に、完全な想起は不要だ。`indent`の一部、たとえば`ind`とタイプすれば候補が表示される。fuzzy matchingであれば`idt`でも通る。ユーザーに要求されるのは「だいたいこんな名前のコマンドがあったはず」という曖昧な記憶だけだ。

第二に、メニューの階層を辿る必要がない。4階層のメニューの奥にある機能でも、コマンドパレットからはワンステップでアクセスできる。すべてのコマンドがフラットに並び、テキスト入力で絞り込まれる。

第三に、学習が漸進的に行われる。初心者はコマンドパレットでコマンドを「発見」し、その横に表示されるキーバインドを「学習」する。頻繁に使うコマンドは自然にキーバインドを覚え、コマンドパレットを経由せずに直接実行するようになる。つまりコマンドパレットは、GUIからCLIへの段階的な移行を支援するトレーニング装置でもある。

```
コマンドパレットによる学習の段階:

  初心者:
    Ctrl+Shift+P → "format" と入力 → "Format Document" を発見
    → 「こんなコマンドがあるのか」（発見）

  中級者:
    Ctrl+Shift+P → "format" → "Format Document  Shift+Alt+F" を見る
    → 「ショートカットがあるのか」（学習）

  上級者:
    Shift+Alt+F を直接押す
    → コマンドパレット不要（内面化）

  → GUIの「発見しやすさ」がCLIの「効率」への橋渡しをする
```

この漸進的学習モデルは、Nielsenのヒューリスティックが見落としていた点を補う。「再認」は初心者に優しいが、エキスパートにとっては非効率だ。「想起」はエキスパートには高速だが、初心者には壁が高い。コマンドパレットは、同じユーザーが初心者から上級者へと成長する過程を、一つのインターフェースで支えている。

---

## 4. IDEの統合ターミナル――境界の溶解

### CLIがGUIの中に引っ越す

コマンドパレットが「GUIの中にCLIのパラダイムを埋め込んだ」とすれば、統合ターミナルは「GUIの中にCLI環境そのものを埋め込んだ」。

2016年5月、VS Code 1.2で統合ターミナルが導入された。Ctrl+\`（バッククォート）で開くこのターミナルパネルは、OS上のフルターミナルエミュレータと同等の機能を持つ。bash、zsh、PowerShell、何でも動く。

この機能の導入は、開発者のワークフローを根本的に変えた。

それまでは「エディタで書く→ターミナルに切り替える→コマンドを打つ→エディタに戻る」というコンテキストスイッチが必要だった。Alt+TabやCtrl+Tabで画面を切り替えるたびに、認知的なコストが発生する。ウィンドウを行き来するのは、物理的なデスク上で書類を移動するのと同じ負荷がある。

統合ターミナルはこのコンテキストスイッチを消滅させた。コード編集とCLI操作が同一のウィンドウ内で行われる。エディタ領域とターミナル領域は画面分割で同時に表示できる。ファイルパスはエディタからターミナルにドラッグ&ドロップで渡せる。エラーメッセージのファイル名をクリックすれば、エディタがそのファイルの該当行にジャンプする。

```
開発ワークフローの変化:

  統合ターミナル以前:
    ┌─────────────┐     ┌─────────────┐
    │  エディタ    │ ←→ │  ターミナル  │
    │  (GUI)      │     │  (CLI)       │
    └─────────────┘     └─────────────┘
    Alt+Tabで切り替え。認知的コスト発生。
    コンテキストが断絶する。

  統合ターミナル以後:
    ┌─────────────────────────────┐
    │  エディタ（GUI）             │
    │  ┌──────────────────────┐  │
    │  │ コード編集領域         │  │
    │  │                      │  │
    │  ├──────────────────────┤  │
    │  │ ターミナル（CLI）     │  │
    │  │ $ npm test            │  │
    │  └──────────────────────┘  │
    └─────────────────────────────┘
    コンテキストが統合されている。
    CLIの出力からエディタへのジャンプが可能。
```

VS Codeの統合ターミナルは2016年6月のVersion 1.3でxterm.jsを採用し、大幅に機能が強化された。複数ターミナルのサポート、カスタムキーバインド、ワード単位のジャンプ、カーソル点滅、フォントサイズの変更が可能になった。ターミナルはもはや「GUIの付属品」ではなく、開発環境の中核要素となった。

### Emacsはすべてを先取りしていた

ここで再びEmacsに目を向ける必要がある。

Emacsは1976年の時点で、M-xによるコマンドパレットの原型を持っていた。そしてEmacsには`M-x shell`と`M-x term`がある。シェルバッファとターミナルエミュレータだ。Emacs内でbashを動かし、コマンドの出力をバッファとして操作し、テキスト検索やコピーを行い、その結果をコード編集に反映する。

Emacsが数十年前に実現していたことのリスト：

- **名前指定コマンド実行**（M-x）→ Command Palette
- **統合ターミナル**（M-x shell / M-x term）→ VS Codeの統合ターミナル
- **ファイル検索**（M-x find-file）→ Ctrl+P（Quick Open）
- **全文検索**（M-x grep / M-x rgrep）→ Ctrl+Shift+F
- **バッファ切り替え**（C-x b）→ Ctrl+Tab（タブ切り替え）
- **分割表示**（C-x 2, C-x 3）→ エディタの分割ビュー

VS Codeが「イノベーション」として提供した機能の多くは、Emacsの世界では数十年の歴史を持つ。だが、この指摘は「Emacsのほうが偉い」という主張ではない。重要なのは、Emacsのこれらの機能が一般の開発者に広く普及しなかったという事実だ。

Emacsの学習曲線は急峻だ。M-xの存在を知るまでにチュートリアルを読む必要があり、M-x shellが使えることを知るにはさらに深い知識が要る。EmacsのUI（1970年代のテキストベースデザイン）は、2010年代の開発者が期待する視覚的洗練さを持たなかった。

VS CodeとSublime Textの功績は、Emacsが原理的に解決していた問題を、モダンなUIデザインと低い学習曲線で再パッケージしたことだ。この「再パッケージ」は軽視されるべきではない。技術的に正しい解決策が、UIの洗練によって初めて多数のユーザーに届く。これは技術史において繰り返されるパターンだ。

---

## 5. ランチャーとコマンドパレット――OSレベルの融合

### Quicksilver（2003年）：最初のキーボード駆動ランチャー

コマンドパレットの思想は、エディタの外にも広がっている。その起源を辿ると、macOSのアプリケーションランチャーに行き着く。

2003年、Nicholas Jitkoff（Blacktree社）がQuicksilverを開発した。キーボードショートカットで起動し、テキスト入力でアプリケーション、ファイル、連絡先、ブックマークを横断検索する。入力に応じてリアルタイムに候補が絞り込まれ、Enterで実行する。

Quicksilverの革新は、**OSのすべてのリソースをテキスト入力で操作可能にした**ことだ。アプリケーションの起動だけでなく、「ファイルを選択→メールに添付→特定の相手に送信」といったアクションの連鎖を、すべてキーボードから指を離さずに実行できた。

### Spotlight（2005年）：Appleの回答

2005年4月29日、AppleはmacOS Tiger（10.4）でSpotlightを導入した。Cmd+Spaceで起動し、テキスト入力でアプリケーション、ファイル、メール、連絡先を横断検索する。Quicksilverの影響は明白だ。Quicksilverが実証したユースケースを、AppleがOS標準機能として取り込んだ。

だがSpotlightは当初、Quicksilverほどの拡張性を持たなかった。アプリケーション起動とファイル検索には使えたが、アクションの連鎖やカスタムワークフローには対応していなかった。この制約が、サードパーティランチャーの市場を残した。

### Alfred（2010年）とRaycast（2020年）

2010年、Andrew PeppellerとVero Peppeller（英国）がAlfredをリリースした。Spotlightの制約に不満を覚えたユーザーに向け、Workflowと呼ばれる拡張機構を提供した。Alfred Workflowは、入力→処理→出力のパイプラインを視覚的に設計できる仕組みであり、概念的にはUNIXパイプラインのGUI表現だ。

2020年にはRaycastが登場した。Alfred同様のランチャー機能に加え、ウィンドウ管理、クリップボード履歴、スニペット、計算機を標準搭載する。拡張機能はTypeScriptで書け、React的なUI構築が可能だ。

```
ランチャーの系譜:

  2003年  Quicksilver (Nicholas Jitkoff)
          └─ キーボード駆動のOS操作。アクション連鎖。
             Spotlightより2年先行

  2005年  Spotlight (Apple, macOS Tiger)
          └─ OS標準のテキスト入力検索
             Quicksilverの成功を取り込む

  2010年  Alfred (Andrew & Vero Peppeller)
          └─ Workflow拡張。UNIXパイプの精神
             Spotlightの制約を補う

  2020年  Raycast
          └─ TypeScript拡張。統合ツール
             開発者向けに最適化

  共通原則:
    キーボードショートカットで起動
    → テキスト入力でfuzzy検索
    → 候補リストから選択して実行
    → エディタのCommand Paletteと同じUIパターン
```

この系譜を見ると、エディタのCommand Paletteとランチャーが、異なる領域で同じUIパターンに収束していることがわかる。テキスト入力、fuzzy matching、リアルタイム候補表示、キーボードによる選択・実行。この「コマンドパレットパターン」は、特定のアプリケーションに閉じたものではなく、ヒューマンコンピュータインタラクションの普遍的なパターンとなった。

### X11の世界：dmenu（2006年）

ランチャーの思想はmacOS固有のものではない。X11（Linux/UNIX）の世界には、より原始的で、よりUNIX的なアプローチがある。

2006年、suckless.orgプロジェクトがdmenuをリリースした。dmenuはX11上の動的メニューであり、stdinからテキストリストを読み取り、ユーザーがインクリメンタルにフィルタリングして選択する。

```bash
# dmenuの基本的な使い方
echo -e "firefox\nchromium\nthunderbird\ngimp" | dmenu
# → テキスト入力で絞り込み、選択結果がstdoutに出力される
```

dmenuの設計はUNIX哲学の忠実な体現だ。stdinから入力を受け、stdoutに結果を出す。何のリストを表示するかは、dmenuの責務ではない。パイプで任意のデータを流し込める。アプリケーション一覧を渡せばランチャーになり、ファイル一覧を渡せばファイルセレクタになり、パスワードマネージャの名前一覧を渡せばパスワード選択になる。

```bash
# dmenu をアプリケーションランチャーとして使う
dmenu_path | dmenu | sh

# dmenu をファイルセレクタとして使う
find . -type f | dmenu | xargs xdg-open

# dmenu をgitブランチ切り替えに使う
git branch | dmenu | xargs git checkout
```

dmenuは、GUIのランチャーとCLIのパイプラインを最小限のインターフェースで橋渡しする。テキスト入力による絞り込みはGUI的だが、stdinからリストを受け取る設計はCLI的だ。この融合は、suckless.orgの「ソフトウェアは最小限であるべき」という思想から生まれた。

rofiはdmenuの後継として機能するツールで、ウィンドウスイッチャー、SSHランチャーなど追加機能を持ちつつ、dmenuのドロップイン代替としても動作する。

---

## 6. fzf――CLIネイティブのfuzzy matching

### 「何でも絞り込める」ツール

ここまでGUI側からの融合（コマンドパレット、ランチャー）を見てきた。だが、CLI側からも融合が進んでいる。その代表がfzfだ。

2013年、Junegunn ChoiがfzfをGitHubで公開した。fzfは汎用のコマンドラインfuzzy finderであり、stdinから受け取った任意のテキストリストに対して、インタラクティブなfuzzy matchingフィルタリングを提供する。

```bash
# ファイルをfuzzyに検索して開く
vim $(find . -type f | fzf)

# コマンド履歴をfuzzyに検索して実行
# (Ctrl+Rにバインドされている場合)
# → 履歴から「docker」を含むコマンドを探すには
#    "dock" とタイプするだけで候補が絞り込まれる

# gitブランチをfuzzyに選んでcheckout
git branch | fzf | xargs git checkout

# プロセスをfuzzyに検索してkill
ps aux | fzf | awk '{print $2}' | xargs kill
```

fzfの動作はSublime TextのCommand Paletteと本質的に同じだ。テキスト入力、fuzzy matching、リアルタイムフィルタリング、候補表示、選択。だがfzfはターミナルの中で動作し、stdinからデータを受け取り、stdoutに結果を出力する。UNIXパイプラインの一部として機能する。

```
Sublime Text Command Palette vs fzf:

  Sublime Text:
    ┌──────────────────────────────┐
    │ > reps                        │ ← GUIのテキスト入力
    ├──────────────────────────────┤
    │ ▸ Replace String              │ ← GUIの候補リスト
    │   Replace in Files            │
    └──────────────────────────────┘
    データソース: エディタの内部コマンド（固定）
    出力先: エディタの内部アクション（固定）

  fzf:
    $ find . -type f | fzf
    ┌──────────────────────────────┐
    │ > reps                        │ ← CLIのテキスト入力
    ├──────────────────────────────┤
    │ ▸ src/replace_string.py       │ ← CLIの候補リスト
    │   docs/replace-guide.md       │
    └──────────────────────────────┘
    データソース: stdin（任意）
    出力先: stdout（パイプ可能）

  → 同じUIパターンだが、fzfは組み合わせ可能
```

fzfとCommand Paletteの決定的な違いは「組み合わせ可能性」だ。Command Paletteはエディタ内の操作に閉じている。fzfはUNIXパイプラインの一部として、任意のデータに対して動作する。findの出力を絞り込んでvimに渡す。git logの出力を絞り込んでcheckoutする。この組み合わせの自由度は、CLIの構造的優位性そのものだ。

fzfはGitHubで77,000以上のスターを獲得し、CLIツールとして最も人気のあるプロジェクトの一つとなった。多くのシェル設定でCtrl+R（コマンド履歴検索）やCtrl+T（ファイル検索）にバインドされ、シェルの標準的な操作を「fuzzy化」している。

### fzfが示したもの

fzfの成功は、CLIとGUIの融合が「GUIの中にCLIを入れる」一方向だけではないことを示した。CLIの中にGUIの「発見しやすさ」を持ち込むこともできる。

CLIの弱点は、コマンド名やファイル名を正確に想起する必要があることだった。だがfzfを使えば、曖昧な断片的記憶からでも目的のコマンドやファイルにたどり着ける。これはCommand Paletteと同じ「想起と再認の融合」だが、ターミナルの中で、パイプラインの文法で実現されている。

---

## 7. ハンズオン：キーボード駆動のGUIパターンを体験する

### 環境構築

```bash
# Docker環境で実行（ubuntu:24.04ベース）
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：fzf――CLIにfuzzy matchingを持ち込む

```bash
# fzfのインストール
apt-get update && apt-get install -y fzf git curl

echo "=== 演習1: fzfによるfuzzy matching ==="
echo ""

# テスト用ファイルツリーの生成
mkdir -p /tmp/fzf-demo/project
cd /tmp/fzf-demo/project

# 50個のファイルを生成
for dir in src lib test docs config; do
    mkdir -p "$dir"
    for i in $(seq 1 10); do
        echo "// ${dir}/file_${i}" > "${dir}/file_${i}.txt"
    done
done

echo "--- ファイル一覧の従来の検索方法 ---"
echo '$ find . -type f -name "*config*"'
find . -type f -name "*config*"
echo ""

echo "--- fzfによるfuzzy検索（非対話デモ）---"
echo '$ find . -type f | fzf --filter "cnfg"'
find . -type f | fzf --filter "cnfg" | head -5
echo ""
echo "→ 'cnfg'という不正確な入力でもconfigディレクトリのファイルが見つかる"
echo "→ これがfuzzy matchingの力"
echo ""

echo "--- fzfの対話モードの使い方 ---"
echo '$ find . -type f | fzf'
echo "  → テキスト入力で候補がリアルタイムに絞り込まれる"
echo "  → 矢印キーで選択、Enterで確定"
echo "  → 結果はstdoutに出力される（パイプ可能）"
```

### 演習2：fzfとパイプラインの組み合わせ

```bash
echo ""
echo "=== 演習2: fzfとパイプラインの組み合わせ ==="
echo ""

# コマンド履歴の模擬データ
cat > /tmp/fzf-demo/history.txt << 'EOF'
git status
git log --oneline -20
git diff HEAD~1
docker ps -a
docker run -it ubuntu:24.04 bash
docker-compose up -d
kubectl get pods -n production
kubectl logs deploy/api-server
npm install
npm run test
npm run build
grep -rn "TODO" src/
find . -name "*.log" -mtime -7
ssh web-server-01
ssh db-server-prod
EOF

echo "--- 通常のgrepによる検索 ---"
echo '$ grep "docker" history.txt'
grep "docker" /tmp/fzf-demo/history.txt
echo ""

echo "--- fzfのfuzzy matchingによる検索 ---"
echo '$ cat history.txt | fzf --filter "dkr"'
cat /tmp/fzf-demo/history.txt | fzf --filter "dkr"
echo ""
echo "→ 'dkr'でdockerのコマンドがマッチする"
echo "→ grepでは'docker'と正確に入力する必要がある"
echo ""

echo "--- fzfの実用例: パイプラインの部品として ---"
echo ""
echo "# ファイルをfuzzyに選んで内容を表示:"
echo '$ find . -type f | fzf | xargs cat'
echo ""
echo "# gitブランチをfuzzyに選んでcheckout:"
echo '$ git branch | fzf | xargs git checkout'
echo ""
echo "# コマンド履歴からfuzzyに選んで実行:"
echo '$ cat history.txt | fzf | sh'
echo ""
echo "→ fzfはstdin/stdoutの原則に従うため"
echo "   パイプラインのどこにでも挿入できる"
```

### 演習3：dmenuパターンの再現

```bash
echo ""
echo "=== 演習3: dmenuパターンのCLI再現 ==="
echo ""

echo "dmenuはX11上のGUIツールだが、その設計思想は"
echo "CLIで再現できる。fzfがまさにそれだ。"
echo ""

# dmenuパターン: リスト生成 | 絞り込み | 実行
echo "--- dmenuパターン: リスト | 絞り込み | 実行 ---"
echo ""

echo "# パターン1: アプリケーションランチャー相当"
echo '$ ls /usr/bin | fzf | sh'
echo "  → /usr/binのコマンド一覧をfuzzy検索して実行"
echo ""

echo "# パターン2: ファイルオープナー相当"
echo '$ find . -type f | fzf | xargs less'
echo "  → ファイル一覧をfuzzy検索して閲覧"
echo ""

echo "# パターン3: プロセスキラー相当"
echo '$ ps aux | fzf | awk "{print \$2}" | xargs kill'
echo "  → プロセス一覧をfuzzy検索して終了"
echo ""

# 実際のデモ: 選択メニューの実装
echo "--- シェルスクリプトでコマンドパレットを実装 ---"
cat > /tmp/fzf-demo/palette.sh << 'SCRIPT'
#!/bin/bash
# 簡易コマンドパレット（fzf使用）
set -euo pipefail

# コマンドの定義: "表示名:実行コマンド"
COMMANDS="Show disk usage:df -h
List running processes:ps aux --sort=-%mem | head -20
Show network connections:ss -tuln
Show system info:uname -a
Show memory usage:free -h
Show current date:date
Show environment variables:env | sort | head -20
Show logged-in users:who
Show uptime:uptime"

# fzf --filterでコロン前を検索対象にする
SELECTED=$(echo "$COMMANDS" | fzf --filter "${1:-}" | head -1)

if [ -n "$SELECTED" ]; then
    NAME="${SELECTED%%:*}"
    CMD="${SELECTED#*:}"
    echo "=== $NAME ==="
    echo "$ $CMD"
    echo "---"
    eval "$CMD"
fi
SCRIPT
chmod +x /tmp/fzf-demo/palette.sh

echo "palette.sh の内容:"
echo '  コマンドを "表示名:実行コマンド" の形式で定義'
echo '  fzfで絞り込み、選択されたコマンドを実行'
echo ""

echo "--- 実行例: 'disk' で検索 ---"
/tmp/fzf-demo/palette.sh "disk" 2>/dev/null || true
echo ""

echo "--- 実行例: 'mem' で検索 ---"
/tmp/fzf-demo/palette.sh "mem" 2>/dev/null || true
echo ""

echo "=== このパターンの本質 ==="
echo ""
echo "1. コマンド一覧をテキストとして定義する"
echo "2. fzfでfuzzy matchingにより絞り込む"
echo "3. 選択結果をパイプで次の処理に渡す"
echo ""
echo "→ これはVS CodeのCommand Paletteと同じUIパターンを"
echo "   CLIのstdin/stdoutで実現したもの"
echo ""
echo "→ GUIのCommand Paletteとの違い:"
echo "   - データソースが固定されていない（パイプで何でも渡せる）"
echo "   - 結果がstdoutに出る（後続処理につなげられる）"
echo "   - シェルスクリプトで拡張できる"
```

ハンズオンの自動セットアップスクリプトは `handson/command-line/13-cli-gui-convergence/setup.sh` を参照してほしい。

---

## 8. まとめと次回予告

### この回の要点

第一に、「名前を指定してコマンドを実行する」パラダイムは、1976年のEmacsのM-xに始まる。Guy SteeleとRichard Stallmanが設計したこの仕組みは、有限のキーバインドと膨大なコマンドのギャップを埋める解決策であり、50年後のCommand Paletteの原型だ。

第二に、2011年のSublime TextのCommand Paletteがゲームチェンジャーとなったのは、fuzzy matchingとリアルタイムフィルタリングによって、「正確なコマンド名を知っている必要がない」インターフェースを実現したからだ。これは認知科学的には、「想起（recall）」と「再認（recognition）」を融合するハイブリッド設計である。

第三に、VS Codeの統合ターミナル（2016年5月、Version 1.2）はCLIとGUIの境界を物理的に溶かした。コード編集とCLI操作が同一ウィンドウ内で行われることで、コンテキストスイッチのコストが消滅した。Emacsが数十年前に実現していた「統合環境」を、モダンなUIで再パッケージした功績だ。

第四に、ランチャーの系譜――Quicksilver（2003年）、Spotlight（2005年）、Alfred（2010年）、Raycast（2020年）――とエディタのCommand Paletteは、同じUIパターンに収束している。テキスト入力、fuzzy matching、リアルタイム候補表示、キーボードによる選択・実行。この「コマンドパレットパターン」は、特定のアプリケーションに閉じない普遍的なインタラクションパターンである。

第五に、fzf（2013年、Junegunn Choi）とdmenu（2006年、suckless.org）は、CLIの側から同じ融合を実現している。fzfはstdin/stdoutの原則に従いながらfuzzy matchingを提供し、「CLIの組み合わせ可能性」と「GUIの発見しやすさ」を同時に実現した。

### 冒頭の問いへの暫定回答

CLIとGUIは対立するのか、それとも融合に向かっているのか。

暫定的な答えはこうだ。**最も生産性が高いインターフェースは、CLIの組み合わせ可能性とGUIの発見可能性を融合したものである。** コマンドパレットはGUIの視覚的発見性にCLIのテキスト入力効率を持ち込み、fzfはCLIのパイプラインにGUIの探索的操作を持ち込んだ。統合ターミナルは両者の境界そのものを消滅させた。

CLIとGUIの「40年戦争」は、勝敗ではなく融合で決着しつつある。だが、この融合は「どちらかが消滅する」ことを意味しない。テキストストリームの組み合わせ可能性（CLI）も、視覚的フィードバックの即時性（GUI）も、それぞれの文脈で不可欠だ。融合とは、両者の強みを適切な場面で使い分け、シームレスに行き来できる設計のことだ。

### 次回予告

次回、第14回「GNU coreutils――自由なUNIXツール群の再実装」では、私たちが毎日使っている`ls`、`cat`、`grep`がオリジナルのUNIXコマンドではなく、GNU Projectによる「自由な再実装」であるという事実に向き合う。

Richard Stallmanの"GNU Manifesto"（1983年）に始まるGNUプロジェクトは、なぜUNIXツールの再実装から始めたのか。GNUツールとBSDツールの微妙な差異はどこから生じたのか。あなたが毎日使っている`ls --color=auto`の`--color`オプションは、オリジナルのUNIXには存在しなかったGNU独自の拡張だ。

あなたは、自分が使っているcoreutilsがGNU版なのかBSD版なのか、意識したことがあるだろうか。

---

## 参考文献

- Wikipedia, "Emacs", <https://en.wikipedia.org/wiki/Emacs>
- "On the Origin of Emacs in 1976", <https://onlisp.co.uk/On-the-Origin-of-Emacs-in-1976.html>
- EmacsWiki, "Emacs History", <https://www.emacswiki.org/emacs/EmacsHistory>
- Wikipedia, "Vim (text editor)", <https://en.wikipedia.org/wiki/Vim_(text_editor)>
- "Where Vim Came From", Two-Bit History, 2018, <https://twobithistory.org/2018/08/05/where-vim-came-from.html>
- Wikipedia, "Sublime Text", <https://en.wikipedia.org/wiki/Sublime_Text>
- Sublime Text Blog, "Sublime Text 2.0 Released", 2012, <https://www.sublimetext.com/blog/articles/sublime-text-2-0-released>
- Digital Seams, "Why do Sublime Text and VS Code use Ctrl-Shift-P for the command bar?", <https://digitalseams.com/blog/why-do-sublime-text-and-vs-code-use-ctrl-shift-p-for-the-command-bar>
- Wikipedia, "Visual Studio Code", <https://en.wikipedia.org/wiki/Visual_Studio_Code>
- VS Code Release Notes, "May 2016 (version 1.2)", <https://code.visualstudio.com/updates/May_2016>
- VS Code Release Notes, "June 2016 (version 1.3)", <https://code.visualstudio.com/updates/June_2016>
- Wikipedia, "Quicksilver (software)", <https://en.wikipedia.org/wiki/Quicksilver_(software)>
- Wikipedia, "Atom (text editor)", <https://en.wikipedia.org/wiki/Atom_(text_editor)>
- Wikipedia, "Electron (software framework)", <https://en.wikipedia.org/wiki/Electron_(software_framework)>
- suckless.org, "dmenu", <https://tools.suckless.org/dmenu/>
- GitHub, junegunn/fzf, <https://github.com/junegunn/fzf>
- JetBrains Blog, "Double Shift to Search Everywhere", 2020, <https://blog.jetbrains.com/idea/2020/05/when-the-shift-hits-the-fan-search-everywhere/>
- Nielsen Norman Group, "10 Usability Heuristics for User Interface Design", <https://www.nngroup.com/articles/ten-usability-heuristics/>
- Nielsen Norman Group, "Recognition vs. Recall in User Interfaces", <https://www.nngroup.com/videos/recognition-vs-recall/>
