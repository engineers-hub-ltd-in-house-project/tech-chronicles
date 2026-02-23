# UNIXという思想

## ――パイプ、プロセス、ファイル――すべてはここから始まった

### 第22回：「UNIX哲学の限界――何がうまくいかなかったか」

**連載「UNIXという思想――パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- UNIXのテキストストリームが「型なし」であることの根本的な限界と、構造化データ時代との不適合
- X Window Systemの「mechanism not policy」原則がGUIの世界で裏目に出た経緯と、CDE/KDE/GNOMEの断片化
- ステートレスなフィルタモデルが状態管理を必要とする現代的ワークロードに対応できない理由
- 終了コード（0-255）だけに依存するエラーハンドリングの貧弱さ
- uid/gidベースのセキュリティモデルの粗い粒度と、Capability-based securityという代替思想
- PowerShellのオブジェクトパイプラインとNushellの構造化データシェルが提示した「UNIX哲学の先」

---

## 1. 敬愛するものを批判する困難

この連載を始めて21回、私はUNIX哲学の力を語り続けてきた。パイプの合成可能性、「一つのことをうまくやれ」の設計原則、「すべてはファイルである」の抽象化の威力。1969年にKen ThompsonとDennis RitchieがPDP-7の前で練り上げた設計哲学が、半世紀以上を経た今なお現代のソフトウェア設計の基盤であることを、繰り返し確認してきた。

だが今回は、その逆をやらなければならない。UNIX哲学の限界を、正面から語る。

きっかけは2015年頃の出来事だ。あるプロジェクトで、複数のAPIから取得したJSONデータを結合・変換してレポートを生成する処理を書いていた。最初は「UNIX的に」やろうとした。`curl`でAPIを叩き、`jq`でJSONをパースし、パイプで繋いで`awk`で集計する。

途中まではうまくいった。だが処理が複雑になるにつれ、壁にぶつかった。あるAPIのレスポンスに含まれるIDを使って別のAPIを呼ぶ必要がある。つまり、パイプラインの途中で「状態」を保持し、それに基づいて分岐する処理が必要だった。さらに、APIがエラーを返した場合のリトライロジック、部分的な失敗からのリカバリ。シェルスクリプトの中に一時ファイルが増え、トラップハンドラが複雑化し、やがてスクリプト全体が読解不能になった。

結局、Pythonで書き直した。30分で終わった。辞書型のデータ構造、例外処理、ループの中での条件分岐――プログラミング言語なら当たり前のことが、シェルパイプラインでは異常に困難だった。

私はUNIXを深く敬愛している。だからこそ、その限界を語る責任がある。原則を「教条」にしてはならない。原則が適用できない領域を見極めること。それが「原則を知る」ことの本当の価値だ。

UNIX哲学は万能ではない。その限界はどこにあるのか。

---

## 2. UNIX哲学が前提とした世界――そしてその前提が崩れた瞬間

### テレタイプ端末の世界

UNIX哲学の設計前提を理解するには、それが生まれた環境を知る必要がある。

1969年のBell Labs。Ken ThompsonとDennis RitchieがUNIXを開発していた当時、ユーザインタフェースはテレタイプ端末（ASR-33）だった。1秒間に10文字を印字する電動タイプライターで、コンピュータとの対話はすべてテキストで行われた。画面はない。マウスもない。あるのはキーボードと紙だけだ。

この環境では、「テキストは万能インタフェースである」という前提は完全に正しかった。入力はテキスト、出力もテキスト。プロセス間の通信もテキスト。ファイルの中身もテキスト。世界がテキストでできている以上、テキストを共通インタフェースにするのは合理的な設計判断だった。

パイプが前提とするフィルタモデルもまた、この世界に最適化されていた。データは行指向のテキストストリームとして流れ、各コマンドはその中から必要な部分を抽出・変換・集計する。`grep`は行単位でパターンマッチし、`sort`は行単位でソートし、`uniq`は隣接する重複行を除去する。すべてが「テキストの行」という単位で動く。

### 1984年――GUIの衝撃

1984年1月24日、Apple Macintoshが発売された。GUIを標準インタフェースとした最初の商業的成功を収めたパーソナルコンピュータだ。デスクトップメタファー、アイコン、マウス操作、ドラッグ＆ドロップ――Macintoshが提示したのは、テキスト以外のインタフェースが大衆に受け入れられるという事実だった。

同じ1984年、MITではBob ScheiflerとJim Gettys（Project Athena）がX Window Systemの開発を開始していた。UNIXの世界にもGUIが来る。だがその設計原則は、Macintoshとは根本的に異なるものだった。

Scheiflerらは「Provide mechanism rather than policy. In particular, place user interface policy in the clients' hands.（メカニズムを提供せよ、ポリシーではなく。特に、ユーザインタフェースのポリシーはクライアントの手に委ねよ）」という原則を掲げた。これはUNIX哲学の直接的な延長だ。カーネルがファイルシステムのメカニズムを提供し、ポリシーはアプリケーションに委ねるのと同じ構造である。

問題は、GUIの世界でこの原則が裏目に出たことだ。

### 断片化の30年

Macintoshの統一されたGUI体験とは対照的に、UNIXの世界ではデスクトップ環境が果てしなく分裂した。

```
UNIXデスクトップ環境の断片化の歴史:

1984年  X Window System（MIT）         -- メカニズムのみ提供
1987年  X11リリース（X11R1）           -- プロトコル標準化
1988年  Motif（OSF）                    -- ウィジェットツールキット
1993年  CDE発表（HP/IBM/SunSoft/USL）  -- 商用UNIXの統一デスクトップ試み
1996年  KDE発表（Matthias Ettrich）     -- CDEへのフリーソフトウェア対抗
1997年  GNOME開始（de Icaza/Mena）     -- KDEのQtライセンス問題への対抗
2011年  GNOME 3リリース               -- 物議を醸すUI刷新
        → MATE（GNOME 2フォーク）
        → Cinnamon（Linux Mint）
        → Budgie（Solus）
        → Pantheon（elementaryOS）
        → COSMIC（Pop!_OS）
```

CDE、KDE、GNOME、MATE、Cinnamon、Budgie、Pantheon、COSMIC――30年以上にわたってデスクトップ環境が増殖し続けた。これは「多様性」と呼ぶこともできるが、同時に「統一的なGUI体験をUNIXが提供できなかった」という事実の裏返しでもある。

Macintoshは（そしてWindowsも）「ポリシー」を規定した。ボタンはこう見える、メニューはここにある、ウィンドウはこう操作する。UNIX/Linuxは「メカニズム」を提供し、ポリシーの決定をコミュニティに委ねた。その結果、企業のデスクトップ市場ではWindows、消費者のモバイル市場ではiOS/Androidが支配し、UNIX/Linuxはサーバルームに押し込められた。

UNIX哲学の「mechanism not policy」は、テキストベースのCLIの世界では強力に機能した。だがGUIの世界では、ユーザが求めるのは統一された体験であり、選択肢の爆発ではない。この不適合は、UNIX哲学の限界の最も目に見える表れだった。

### データの複雑化――テキストでは足りない

もう一つの前提崩壊は、データの複雑化だ。

1970年代のUNIXが扱っていたデータの大半は、行指向のテキストだった。`/etc/passwd`はコロン区切りのテキストファイルであり、ログファイルは1行1エントリのテキストストリームであり、設定ファイルはキーバリューのテキストだった。

だが21世紀のソフトウェアが扱うデータは、根本的に異なる。

```
1970年代のデータ:
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin

2020年代のデータ:
{
  "users": [
    {
      "id": 1,
      "name": "root",
      "groups": ["root", "admin"],
      "permissions": {
        "read": ["*"],
        "write": ["*"],
        "execute": ["*"]
      },
      "metadata": {
        "created_at": "2024-01-15T10:30:00Z",
        "last_login": "2026-02-20T08:45:12Z",
        "mfa_enabled": true
      }
    }
  ]
}
```

ネストされた構造、型情報（文字列、数値、真偽値、配列）、日時フォーマット。UNIXのテキストストリームモデルでは、この種のデータを「行」と「フィールド」に分解して処理するしかない。`grep`でJSONの中身を検索することは不可能ではないが、構造を無視した文字列マッチに過ぎない。

XML（1998年、W3C勧告）、JSON（2001年、Douglas Crockford考案）、Protocol Buffers（2001年、Google内部開発、2008年オープンソース化）――構造化データ形式の台頭は、テキストストリームの限界への応答だった。

---

## 3. 五つの限界――UNIX哲学の構造的な弱点

### 限界1：テキストストリームの型なし問題

UNIXパイプラインの根本的な問題は、パイプを流れるデータに「型」がないことだ。

`ls -l`の出力を考えてみよう。

```
-rw-r--r-- 1 user group 4096 Feb 20 10:30 document.txt
drwxr-xr-x 2 user group 4096 Feb 19 14:22 src/
```

この出力を受け取る次のコマンドは、これが「ファイル一覧」であることを知らない。単なるテキストの羅列として扱う。ファイルサイズが4列目にあるという知識は、人間がmanページを読んで得る暗黙知であり、パイプラインのプロトコルとして定義されていない。

この問題は、実務で致命的な形で現れる。

```bash
# ファイルサイズでソートしたい
ls -l | sort -k5 -n

# だが、ファイル名にスペースが含まれていたら？
# 列の解釈がずれ、結果が壊れる

# 日付フォーマットが変わったら？
# ロケール設定が変わったら？
# 出力フォーマットがOSのバージョンで異なったら？
```

1994年に出版された『The UNIX-HATERS Handbook』（Simson Garfinkel, Daniel Weise, Steven Strassmann編）は、この問題を容赦なく指摘した。テキストパースに依存するパイプラインの脆弱さ、シェルスクリプトのクォート処理の不合理さ。Dennis Ritchie自身がこの本に反序文（Anti-Foreword）を寄せたのは、批判の一部を認めていたからだろう。

Eric S. Raymondも後に「古典的なシェルスクリプトは脆弱であり、データ構造と真の手続き的合成をサポートする言語に置き換えられるべきだという主張は正当だった」と認めている。PerlやPythonが「スクリプト言語」と呼ばれるようになったのは、まさにこの脆弱なシェルスクリプトの代替として登場したからだ。

### 限界2：GUIアプリケーションとの根本的な不適合

UNIX哲学はCLIの世界で生まれ、CLIの世界で磨かれた。標準入力、標準出力、標準エラー出力という三つのストリーム。テキストベースの対話モデル。パイプによる合成。これらはすべて、テキスト端末を前提とした設計だ。

GUIアプリケーションは、この前提に収まらない。

GUIには「イベント」がある。マウスクリック、キー入力、ウィンドウのリサイズ、ドラッグ＆ドロップ。これらは「行指向のテキストストリーム」として表現できない。GUIにはレイアウトがある。ウィジェットの配置、フォントの選択、色の指定。これらは`stdout`に文字列を出力するモデルでは扱えない。

```
UNIX哲学のI/Oモデル:

       stdin          stdout
テキスト → [プロセス] → テキスト
                ↓
              stderr
              テキスト

GUIアプリケーションのI/Oモデル:

  マウスイベント ──┐
  キーイベント ────┤
  タイマーイベント ┤→ [イベントループ] → 画面描画
  ネットワークI/O ─┤                  → サウンド出力
  D-Busメッセージ ─┘                  → ファイルI/O
                                      → ネットワークI/O
```

UNIXのプロセスモデルは「入力を受け取り、処理し、出力する」というバッチ処理の延長線上にある。GUIは「イベントを待ち受け、状態を更新し、画面を再描画する」というイベント駆動モデルだ。この二つのモデルは、根本的に異なる。

X Window Systemは「メカニズムのみ提供」の原則に従ったが、その結果、UNIX上のGUIアプリケーションは「パイプで繋ぐ」ことができない。あるGUIアプリケーションの出力を別のGUIアプリケーションの入力にする、というUNIX哲学の核心が、GUIの世界では成立しない。AppleScriptやCOM/OLEのようなアプリケーション間連携は存在するが、それはUNIXのパイプモデルとは異質なものだ。

### 限界3：状態管理の不在

UNIX哲学のフィルタモデルは、本質的にステートレスだ。`grep`は各行を独立に処理する。`sort`は全入力を読み込んでソートするが、内部状態を次のパイプラインに引き継がない。各コマンドはパイプラインの中で独立したプロセスとして動き、共有する状態はテキストストリームだけだ。

現代のソフトウェアが扱う多くのタスクは、状態を必要とする。

```
ステートレスなフィルタモデルでは困難なタスク:

1. セッション管理
   - ユーザのログイン状態を保持する
   - 複数のリクエストにまたがるコンテキストを管理する

2. トランザクション処理
   - 複数の操作をアトミックに実行する
   - 失敗時にロールバックする

3. ストリーム処理の状態保持
   - 移動平均の計算（直近N個の値を保持する必要がある）
   - 重複排除（過去に見た値を記憶する必要がある）
   - セッションウィンドウの管理

4. 依存関係のあるパイプライン
   - ステップAの結果に基づいてステップBの処理を分岐する
   - エラー発生時に前のステップからやり直す
```

UNIXのパイプラインは「データフロー」としては美しいが、「制御フロー」が必要な場面では力不足だ。条件分岐、ループ、例外処理――これらはシェルスクリプトの構文で対応できるが、パイプラインの「合成可能性」は失われる。結局、複雑な処理にはプログラミング言語が必要になる。

Doug McIlroyが設計したパイプは、データが一方向に流れる「アセンブリライン」だ。工場のラインでは、部品が順番に加工され、前の工程に戻ることはない。現代のソフトウェアが必要とするのは、フィードバックループ、条件分岐、エラーリカバリを含む複雑な制御フローであり、一方向のアセンブリラインでは対応しきれない。

### 限界4：エラーハンドリングの貧弱さ

UNIXのプロセスがエラーを伝える手段は、基本的に二つしかない。終了コードと標準エラー出力だ。

終了コードは0から255の整数値だ。POSIXの`exit()`関数は`int`型の引数を受け取るが、`wait()`/`waitpid()`システムコールでは下位8ビット（0-255）のみが親プロセスに渡される。Single UNIX Specificationは「status & 0377」のみが利用可能と規定している。

```
UNIXのエラー伝達モデル:

                 stdout (fd 1)
                ┌──────────────→ 正常な出力データ
[プロセス] ─────┤
                ├──────────────→ エラーメッセージ（人間向け）
                 stderr (fd 2)
                │
                └──────────────→ 終了コード（0-255）
                                  0 = 成功
                                  1-255 = 何らかのエラー

問題: 「何のエラーか」を構造的に伝える手段がない
```

0が成功、それ以外がエラー。これだけだ。「データベース接続に失敗した」「認証トークンが期限切れだ」「ディスク容量が不足している」――これらを区別する標準的な方法はない。`curl`は接続タイムアウトで終了コード28を返し、HTTP 404で終了コード22を返すが、これは`curl`独自の規約であってUNIXの標準ではない。

パイプラインにおけるエラーハンドリングはさらに深刻だ。

```bash
# このパイプラインでgrepが何もマッチしなかった場合
cat data.txt | grep "pattern" | sort | uniq -c

# grepの終了コードは1（マッチなし）だが、
# パイプラインの終了コードは最後のコマンド（uniq）の終了コードになる
# → エラーが握りつぶされる

# bashのpipefailオプションで改善できるが、
# 「どのコマンドが失敗したか」の特定は依然として困難
```

対照的に、現代のプログラミング言語は構造化された例外処理を提供する。try/catchブロック、型付きの例外クラス、スタックトレース。エラーの種類を区別し、適切なリカバリ処理を分岐し、エラーの発生箇所を特定できる。UNIXの「0か非0か」というバイナリなエラーモデルは、この世界から見れば原始的と言わざるを得ない。

### 限界5：セキュリティモデルの古さ

UNIXのセキュリティモデルは、1970年代のBell Labsの環境を前提として設計された。信頼されたユーザの小さなコミュニティが、共有の計算機を使う。この環境では、uid（ユーザID）、gid（グループID）、ファイルパーミッション（rwx）の組み合わせで十分だった。

```
UNIXの伝統的セキュリティモデル:

ファイル: /etc/shadow
所有者: root (uid 0)
グループ: shadow (gid 42)
パーミッション: -rw-r----- (640)

→ rootは読み書き可能
→ shadowグループは読み取りのみ
→ その他のユーザはアクセス不可

問題:
- 粒度が「所有者/グループ/その他」の3段階しかない
- 「特定のユーザAには読み取りを許可、
   ユーザBには拒否」という細かい制御ができない
- プロセスの権限は実行ユーザの権限と同一
  → あるプログラムに「ネットワークアクセスのみ許可、
     ファイルシステムへのアクセスは禁止」ということができない
```

setuidビットは、この粗い粒度を補うために導入されたが、セキュリティ上の悪夢となった。setuid rootされたプログラムにバッファオーバーランの脆弱性があれば、攻撃者はroot権限で任意のコードを実行できる。

インターネットに接続された世界では、この「全か無か」のセキュリティモデルは危険すぎる。Webサーバは外部からの入力を受け付けるが、ファイルシステム全体へのアクセスは必要ない。データベースサーバはデータファイルへのアクセスが必要だが、ネットワーク経由でシェルを実行される必要はない。プロセスごとに「必要最小限の権限」を付与するという最小権限の原則（Principle of Least Privilege）は、uid/gidモデルでは実現が困難だ。

1966年、J.B. DennisとE.C. Van Hornは「capability」の概念を提唱した。プロセスが持つ権限を、個別のリソースへのアクセス権（capability）のリストとして表現する。UNIXの「ユーザは誰か」ではなく、「このプロセスは何ができるか」で権限を制御する発想だ。

2010年、ケンブリッジ大学のRobert N.M. Watsonらは「Capsicum: practical capabilities for UNIX」をUSENIX Security Symposiumで発表した。Capsicumはcapability modeを導入し、プロセスがグローバルなOSネームスペース（ファイルシステム、IPCネームスペース）へのアクセスを放棄し、委譲されたファイルディスクリプタ（capability）のみを使用する。FreeBSD 9.0（2012年）に組み込まれ、tcpdump、gzip、OpenSSH、Google Chromium等がCapsicumプリミティブに対応した。

Linuxでは、namespaces、seccomp、SELinux、AppArmor、POSIX capabilitiesといった機構で段階的にセキュリティが強化されてきた。だが基盤のモデルは依然としてuid/gidであり、これらの拡張は「レガシーモデルの上に積み上げたパッチ」の性格を免れない。

---

## 4. 問題提起としてのPowerShell――テキストからオブジェクトへ

### Monad Manifesto

UNIX哲学のテキストストリームモデルに対する最も体系的な批判は、意外なことにMicrosoftの内部から生まれた。

2002年8月8日、MicrosoftのJeffrey Snoverは「Monad Manifesto」と題する文書を書いた。この文書は、UNIXのテキストパイプラインの限界を正面から指摘し、構造化されたオブジェクトをパイプラインで渡すシェルを提案した。

Snoverの問題認識は明確だった。UNIXはテキストファイルを編集して管理する。Windowsはオブジェクトを操作するAPIで管理する。UNIXのテキストモデルをそのままWindowsに持ち込もうとしても、APIが返す構造化データをテキストに変換し、次のコマンドで再びパースするという無駄が生じる。ならば、最初からオブジェクトをパイプラインで渡せばよい。

```
テキストパイプライン（UNIX）:

$ ps aux | grep nginx | awk '{print $2}' | xargs kill

  ps aux        → テキスト出力（フォーマットはOS/ロケール依存）
  grep nginx    → テキストのパターンマッチ（偽陽性あり）
  awk '{...}'   → 列の位置を人間が暗記（脆弱）
  xargs kill    → テキストをPIDとして解釈

オブジェクトパイプライン（PowerShell）:

PS> Get-Process nginx | Stop-Process

  Get-Process   → Processオブジェクトのコレクション
  Stop-Process  → オブジェクトのPIdプロパティを使用（型安全）
```

開発コード名「Monad」として2003年10月のPDCで初公開され、2006年11月にWindows PowerShell 1.0としてリリースされた。パイプラインを流れるのはテキストではなく.NETオブジェクトであり、プロパティやメソッドを持つ型付きデータだ。

PowerShellの設計は、UNIX哲学への批判としては本質を突いている。テキストパイプラインの脆弱さ——出力フォーマットの変更に弱い、型情報がない、エラー処理が困難——これらの問題に対して、「そもそもテキストではなくオブジェクトを渡せばよい」という回答を示した。

ただし、PowerShellには別の問題がある。.NETオブジェクトは「テキスト」ほど普遍的ではない。テキストは人間が直接読め、任意のエディタで編集でき、バージョン管理システムで差分を取れる。オブジェクトパイプラインは機械にとっては効率的だが、人間にとっての透明性を犠牲にしている。

### Nushell――構造化データシェルの新しい試み

PowerShellの問題提起から15年以上を経て、UNIX/Linuxの世界でも構造化データシェルが登場した。

2019年に公開されたNushellは、Rustで実装された現代的なシェルだ。PowerShellと関数型プログラミング言語から着想を得て、テキストストリームではなく構造化データ（テーブル）をパイプラインで渡す。

```
UNIXシェル:
$ ls -la
total 48
drwxr-xr-x   6 user group  4096 Feb 20 10:30 .
-rw-r--r--   1 user group 12288 Feb 20 10:30 document.txt

→ テキスト。列の位置を覚えてawkで切り出す

Nushell:
> ls
╭───┬──────────────┬──────┬──────────┬──────────────╮
│ # │     name     │ type │   size   │   modified   │
├───┼──────────────┼──────┼──────────┼──────────────┤
│ 0 │ document.txt │ file │ 12.0 KiB │ 2 hours ago  │
│ 1 │ src          │ dir  │  4.1 KiB │ 1 day ago    │
╰───┴──────────────┴──────┴──────────┴──────────────╯

→ テーブル。列名でアクセスできる
> ls | where size > 10kb
> ls | sort-by modified | reverse
```

Nushellでは`ls`の出力はテーブルとして構造化されており、`where size > 10kb`のような型安全なフィルタリングが可能だ。JSONやCSVの読み込みもネイティブにサポートし、`open data.json | get users | where age > 30`のような直感的なデータ操作ができる。

Nushellの興味深い点は、UNIX哲学を否定しているわけではないことだ。「小さなコマンドをパイプラインで組み合わせる」という原則はそのまま継承している。変えたのは、パイプラインを流れるデータの型だけだ。テキストを構造化データに置き換えることで、UNIX哲学の限界を超えようとしている。

ただし、NushellはPOSIX互換ではない。既存のシェルスクリプトはそのままでは動かない。これは「UNIX哲学の先」を目指す代償だ。

---

## 5. ハンズオン：UNIX哲学の限界を体験する

UNIX哲学の限界を理論で理解するだけでなく、実際に手を動かして体感してみよう。以下の演習では、UNIXパイプラインが「苦手とする」タスクに挑み、その困難さを肌で感じる。

### 環境構築

```bash
docker run -it --rm ubuntu:24.04 bash
apt-get update && apt-get install -y jq curl coreutils
```

### 演習1：型なしテキストストリームの脆弱性

テキストパースに依存するパイプラインが、いかに脆弱かを体験する。

```bash
# テスト用のデータを作成
mkdir -p /tmp/demo && cd /tmp/demo

# 「普通の」ファイル名
touch "report.txt" "data.csv" "README.md"

# 「特殊な」ファイル名（スペース、改行、ハイフン含む）
touch "my report.txt"
touch "file with  double  spaces.txt"
touch -- "-dangerous-name.txt"

# ls + grep + wc でテキストファイルを数える（一見うまくいく）
echo "--- テキストファイルの数（naiveな方法） ---"
ls | grep "\.txt$" | wc -l

# だが、ファイル名にスペースがあると問題が起きる
echo ""
echo "--- 各ファイルのサイズを取得（naiveな方法） ---"
ls -l | awk '{print $5, $9}'
# → "my report.txt" が分割されて誤った結果になる

echo ""
echo "--- 安全な方法（NUL区切り） ---"
find . -name "*.txt" -print0 | xargs -0 ls -la
# → NUL区切りで正しく処理されるが、
#    これはもはや「テキストストリーム」ではない
```

「テキストは万能インタフェース」という前提が、ファイル名にスペースが含まれるだけで崩壊する。NULバイト区切り（`-print0`/`-0`）という回避策は存在するが、それはテキストストリームモデルの限界を自ら認めた「パッチ」に過ぎない。

### 演習2：状態を持つ処理の困難さ

パイプラインの途中で「状態」を保持する処理が、いかに不自然になるかを体験する。

```bash
cd /tmp/demo

# APIレスポンスを模したJSONファイルを作成
cat > users.json << 'JSONEOF'
[
  {"id": 1, "name": "Alice", "department_id": 10},
  {"id": 2, "name": "Bob", "department_id": 20},
  {"id": 3, "name": "Charlie", "department_id": 10}
]
JSONEOF

cat > departments.json << 'JSONEOF'
[
  {"id": 10, "name": "Engineering", "budget": 500000},
  {"id": 20, "name": "Marketing", "budget": 300000}
]
JSONEOF

# タスク: 各ユーザに所属部署名を付加して表示する
# → SQLのJOINに相当する処理

echo "--- シェルパイプラインでのJOIN試行 ---"
# jqでなんとかやるが、パイプラインの「合成可能性」からは程遠い
jq -r '.[] | "\(.id)\t\(.name)\t\(.department_id)"' users.json | \
while IFS=$'\t' read -r uid uname dept_id; do
    dept_name=$(jq -r ".[] | select(.id == $dept_id) | .name" departments.json)
    echo "$uid  $uname  $dept_name"
done

echo ""
echo "--- 問題点 ---"
echo "1. whileループ内でjqを毎回起動（非効率）"
echo "2. パイプの中のwhileループはサブシェル（変数が外に出ない）"
echo "3. エラーハンドリングが困難（dept_idが存在しない場合は？）"
echo "4. jq単体でもJOINは可能だが、可読性が著しく低下する"

echo ""
echo "--- jq単体でのJOIN（読めるか？） ---"
jq -n --slurpfile users users.json --slurpfile depts departments.json '
  [$users[0][] | . as $u |
   {id: $u.id, name: $u.name,
    department: ($depts[0][] | select(.id == $u.department_id) | .name)}]
' | jq -r '.[] | "\(.id)\t\(.name)\t\(.department)"'
```

### 演習3：エラーハンドリングの限界

パイプラインにおけるエラーの「握りつぶし」を体験する。

```bash
cd /tmp/demo

# テストデータ
echo -e "apple\nbanana\ncherry\ndate\nelderberry" > fruits.txt

echo "--- パイプラインの終了コード ---"

# grepがマッチしない場合（終了コード1）
echo "存在しないパターンの検索:"
cat fruits.txt | grep "fig" | sort | wc -l
echo "パイプライン終了コード: $?"
# → 0（wc自体は成功しているため）

echo ""
echo "pipefail有効時:"
set -o pipefail
cat fruits.txt | grep "fig" | sort | wc -l
echo "パイプライン終了コード: $?"
set +o pipefail
# → 1（grepの失敗が伝播する）
# だが「どのコマンドが失敗したか」は終了コードだけではわからない

echo ""
echo "--- PIPESTATUS配列（bash拡張） ---"
cat fruits.txt | grep "fig" | sort | wc -l
echo "各コマンドの終了コード: ${PIPESTATUS[@]}"
# → 0 1 0 0（2番目のgrepが失敗）
# bash固有の機能であり、POSIX標準ではない

echo ""
echo "--- 終了コードの曖昧さ ---"
# grepの終了コード1は「マッチなし」だが、
# これは「エラー」なのか「正常な結果（0件マッチ）」なのか？
# コンテキストによって解釈が異なる

grep "nonexistent_pattern" /etc/passwd
echo "終了コード: $? （マッチなし）"

grep "nonexistent_pattern" /nonexistent/file 2>/dev/null
echo "終了コード: $? （ファイルが存在しない）"

echo ""
echo "→ 終了コード1と2は異なるが、"
echo "  どちらも「エラー」として一括りにされがちだ"
echo "  構造化されたエラー情報（エラー種別、メッセージ、"
echo "  スタックトレース）は一切伝達されない"
```

### 演習4：セキュリティモデルの粗さ

uid/gidモデルの粒度の粗さを確認する。

```bash
# 現在のユーザ情報
echo "--- 現在のセキュリティコンテキスト ---"
echo "UID: $(id -u)"
echo "GID: $(id -g)"
echo "Groups: $(id -Gn)"

echo ""
echo "--- ファイルパーミッションの粒度 ---"

# テスト用ファイルを作成
echo "secret data" > /tmp/demo/secret.txt
chmod 640 /tmp/demo/secret.txt
ls -la /tmp/demo/secret.txt

echo ""
echo "制御できること:"
echo "  - 所有者(owner)の読み/書き/実行"
echo "  - グループ(group)の読み/書き/実行"
echo "  - その他(other)の読み/書き/実行"

echo ""
echo "制御できないこと:"
echo "  - 特定のユーザAには読み取り許可、ユーザBには拒否"
echo "  - プロセスに「ネットワークアクセスのみ許可」"
echo "  - プロセスに「特定のディレクトリのみアクセス許可」"
echo "  - 時間帯による条件付きアクセス制御"

echo ""
echo "--- setuidの危険性 ---"
# setuidビットが設定されたファイルを探す
echo "システム上のsetuidバイナリ:"
find /usr/bin /usr/sbin -perm -4000 -type f 2>/dev/null | head -5
echo "..."
echo "これらのプログラムに脆弱性があれば、"
echo "攻撃者はroot権限で任意のコードを実行できる"
```

これらの演習を通じて見えてくるのは、UNIX哲学が「テキスト端末での対話的な作業」に最適化された設計であり、構造化データ、状態管理、精密なエラーハンドリング、細粒度のセキュリティが求められる現代的ワークロードとは、根本的な前提が異なるということだ。

---

## 6. まとめと次回予告

### この回の要点

UNIX哲学は万能ではない。1969年のテレタイプ端末の世界で生まれた設計原則は、半世紀を超えてなお強力だが、構造的な限界を抱えている。

第一に、テキストストリームの「型なし」問題。パイプラインを流れるデータに型情報がないため、出力フォーマットの変更に弱く、構造化データの処理が不自然に困難になる。Jeffrey Snoverの「Monad Manifesto」（2002年）はこの問題を正面から指摘し、PowerShellのオブジェクトパイプラインという回答を示した。Nushell（2019年）はUNIXの世界で同じ問題に取り組んでいる。

第二に、GUIとの根本的な不適合。X Window Systemの「mechanism not policy」は、テキスト端末の世界では合理的だったが、GUIの世界ではデスクトップ環境の際限ない断片化を招いた。CDE、KDE、GNOME、そしてGNOME 3以降のフォーク群。UNIX/Linuxが消費者向けデスクトップ市場で主流になれなかった要因の一つだ。

第三に、ステートレスなフィルタモデルの限界。状態を保持する処理、依存関係のあるパイプライン、フィードバックループ――現代のソフトウェアが必要とする制御フローは、一方向のパイプラインでは表現しきれない。

第四に、エラーハンドリングの貧弱さ。0から255の終了コードと、非構造化なstderrだけでは、エラーの種類を区別し、適切なリカバリを行うには不十分だ。

第五に、uid/gidベースのセキュリティモデルの粗い粒度。信頼されたユーザの小さなコミュニティには十分だったこのモデルは、インターネットに接続された世界では危険なほど粗い。Capsicum（2010年）のようなcapability-based securityは、UNIXのセキュリティモデルの限界に対する一つの回答だ。

### 冒頭の問いへの暫定回答

「UNIX哲学は万能ではない。その限界はどこにあるのか。」

限界は、UNIX哲学が前提とした世界の境界にある。テキスト端末、行指向データ、信頼されたユーザコミュニティ、単一マシン上のローカル処理――これらの前提が成り立つ範囲では、UNIX哲学は今なお強力に機能する。だが前提が崩れた領域――GUI、構造化データ、分散システム、インターネット上のセキュリティ――では、UNIX哲学は「必要だが十分ではない」存在になる。

重要なのは、これがUNIX哲学の「失敗」ではなく「適用範囲の明確化」だということだ。すべての設計哲学には適用可能な領域と適用不可能な領域がある。UNIX哲学を「教条」として無批判に適用するのは、原則を知らないのと同様に危険だ。原則を理解した上で、その原則が有効な場面と限界がある場面を見分けること。それが「原則を知る」ことの本当の意味である。

### 次回予告

次回は「マイクロサービスとUNIX原則――思想の転生」。

UNIX哲学の限界を語った。だが同時に、UNIX哲学の核心――「一つのことをうまくやれ」「組み合わせ可能に作れ」「インタフェースを統一せよ」――は、形を変えて現代のソフトウェアアーキテクチャに受け継がれている。その最も顕著な例が、マイクロサービスアーキテクチャだ。

パイプがAPI/メッセージキューに、テキストストリームがJSON/gRPCに、標準入出力がHTTP/RESTに。UNIX哲学は「転生」した。だが転生先の分散システムには、UNIXのローカルパイプラインにはなかった困難――ネットワーク分断、遅延、部分障害――が待ち構えている。原則は継承できるが、文脈は常に変わる。

---

## 参考文献

- Robert W. Scheifler, Jim Gettys, "The X Window System", ACM Transactions on Graphics, 1986: <https://dl.acm.org/doi/10.1145/22949.24053>
- Don Hopkins, "The X-Windows Disaster", UNIX-HATERS Handbook Chapter 7: <https://donhopkins.medium.com/the-x-windows-disaster-128d398ebd47>
- Daniel Stone, "The real story behind Wayland and X", LCA 2013: <https://people.freedesktop.org/~daniels/lca2013-wayland-x11.pdf>
- Simson Garfinkel, Daniel Weise, Steven Strassmann (eds.), "The UNIX-HATERS Handbook", IDG Books, 1994: <https://archive.org/details/TheUnixHatersHandbook>
- Eric S. Raymond, "The Unix Hater's Handbook, Reconsidered": <http://esr.ibiblio.org/?p=538>
- Jeffrey P. Snover, "Monad Manifesto", Microsoft, 2002年8月8日: <https://www.jsnover.com/Docs/MonadManifesto.pdf>
- Microsoft Learn, "Monad Manifesto - PowerShell": <https://learn.microsoft.com/en-us/powershell/scripting/developer/monad-manifesto?view=powershell-7.5>
- The Open Group, "exit - terminate a process", POSIX.1: <https://pubs.opengroup.org/onlinepubs/009695299/functions/exit.html>
- JoNathen Sokolow, "Let's talk about exit codes": <https://www.sophiajt.com/exit-codes/>
- Robert N. M. Watson et al., "Capsicum: practical capabilities for UNIX", 19th USENIX Security Symposium, 2010: <https://www.usenix.org/legacy/event/sec10/tech/full_papers/Watson.pdf>
- Cambridge Computer Laboratory, "Capsicum: practical capabilities for UNIX": <https://www.cl.cam.ac.uk/research/security/capsicum/>
- Wikipedia, "Capability-based security": <https://en.wikipedia.org/wiki/Capability-based_security>
- Nushell公式リポジトリ: <https://github.com/nushell/nushell>
- Google, "Protocol Buffers Overview": <https://protobuf.dev/overview/>
- Wikipedia, "Common Desktop Environment": <https://en.wikipedia.org/wiki/Common_Desktop_Environment>
- Wikipedia, "X Window System": <https://en.wikipedia.org/wiki/X_Window_System>
- Wikipedia, "PowerShell": <https://en.wikipedia.org/wiki/PowerShell>
