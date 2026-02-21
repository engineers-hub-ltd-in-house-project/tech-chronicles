# 第6回：パイプとUNIX哲学――テキストストリームの天才性と限界

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- Doug McIlroyが1964年に構想し、Ken Thompsonが1973年に実装したパイプの歴史
- パイプのカーネル実装——バッファ、背圧、プロセス間通信の仕組み
- 「すべてはテキスト」という暗黙の契約の成立と、その前提が崩れた背景
- jq、yq、xsvといった「橋渡しツール」の登場と役割
- Nushellが「テーブル」をパイプの単位にした根本的な転換の意味

---

## 1. 導入――パイプ芸の栄光と黄昏

2000年代後半、私はサーバ運用の現場で「パイプ芸」を磨いていた。

あるとき、nginxのプロセスを特定して停止する必要があった。私は何の躊躇もなくこう打った。

```sh
ps aux | grep nginx | grep -v grep | awk '{print $2}' | xargs kill
```

5つのコマンドがパイプでつながれ、テキストが左から右へ流れていく。`ps`がプロセス一覧をテキスト行として出力し、`grep`がnginxを含む行を抽出し、`grep -v`が自分自身を除外し、`awk`がPID列を抜き出し、`xargs`がそれを`kill`の引数に渡す。各コマンドは自分の仕事だけを行い、次のコマンドにテキストを渡す。

これがUNIX哲学の真髄だ——と、当時の私は信じていた。

だが、あるとき状況が変わった。Kubernetesの運用を始め、`kubectl`の出力をパイプで処理しようとしたときのことだ。

```sh
kubectl get pods -o json | ???
```

JSONが返ってくる。構造化されたデータだ。ネストされたオブジェクト、配列、数値と文字列の型区別。`grep`で行を抽出する？ `awk`でフィールドを切り出す？ どちらも、JSONの構造を理解しない。改行位置やインデントに依存する脆弱なパイプラインを書くことはできるが、それは「パイプ芸」ではなく「綱渡り」だ。

私はそのとき初めて、自分が長年頼ってきた「テキスト行をパイプで流す」というパラダイムの限界に直面した。

「すべてはテキスト」の哲学は、いつから限界を見せ始めたのか。そしてその限界は、パイプという発明そのものの欠陥なのか、それとも「テキスト」という前提の問題なのか。

前回、私たちはクォーティング地獄——Bourne shellの言語設計の「原罪」——を解剖した。今回は、シェルの設計思想のもう一つの核心に踏み込む。パイプだ。Doug McIlroyが1964年に夢想し、Ken Thompsonが1973年に一晩で実装した、この「天才的な発明」の全体像を、その栄光と限界の両面から語る。

---

## 2. 歴史的背景――ガーデンホースの夢から一晩の実装まで

### McIlroyの構想――1964年10月11日

パイプの歴史は、1本のメモから始まる。

1964年10月11日、Doug McIlroyはBell Labsの内部メモにこう書いた。

> "We should have some ways of connecting programs like garden hose--screw in another segment when it becomes necessary to massage data in another way."
>
> （プログラムをガーデンホースのように接続する方法があるべきだ——データを別の方法で加工する必要が生じたら、別のセグメントをねじ込めばよい。）

このメモが書かれた1964年、Bell Labsの計算機環境はIBM 7090/7094によるバッチ処理が中心だった。プログラムの出力を別のプログラムの入力に直接つなぐという発想は、当時の計算機利用のあり方からすれば大胆なものだった。プログラムの出力はファイルに書き出し、次のプログラムがそのファイルを読む——それが標準的なワークフローだった。

McIlroyの構想は、この中間ファイルを排除することにあった。データがプログラムからプログラムへ直接流れる。ガーデンホースの比喩は、そのイメージを鮮明に伝えている。水道管の各セグメントが独立しているように、各プログラムも独立している。必要なセグメントをねじ込み、不要なセグメントを外す。データの流れは一方向で、各セグメントは入力を受け取り、加工し、出力する。

だが、この構想が実装されるまでには約9年の歳月を要した。

### Ken Thompsonの一夜――1973年1月15日

1969年にKen ThompsonとDennis Ritchieが開発を始めたUNIXは、当初パイプを持たなかった。Thompson shellにはリダイレクション（`>`、`<`）やバックグラウンド実行（`&`）が実装されていたが、プログラム間の直接接続は実現されていなかった。

McIlroyは部門長の立場からパイプの実装を求め続けた。彼自身の言葉によれば、「ほとんど管理権限を行使してパイプを導入させるところだった」という。

転機は1973年に訪れた。1月15日——この日付はパイプの「誕生日」として記録されている——Ken Thompsonは「一晩の熱狂的な作業（one feverish night）」で、pipe()システムコールをカーネルに追加し、シェルにパイプ構文を組み込み、さらに多数のユーティリティプログラムをパイプ対応に書き換えた。McIlroyによれば、Thompsonは彼の提案をそのまま実装したのではなく、「少し良いもの」を発明した。

1973年2月に公開されたVersion 3 Unixのマニュアルには、パイプが正式に記載された。

### パイプ記号の変遷

当初、パイプの記号は`>`だった。これはリダイレクションと同じ記号であり、構文的に紛らわしかった。Version 4で、Ken Thompsonはパイプ記号を`|`（垂直バー）に変更した。McIlroyはこの記法の功績をThompsonに帰している。

Thompsonが記号を変更した理由について、興味深い逸話がある。彼はロンドンでの講演に際し、「醜い構文を見せるに堪えなかった」ため、`|`記号を採用した。この変更によってVersion 4のマニュアルにおけるパイプ構文の記述は大幅に簡素化された。

`|`記号は今日、「パイプ文字」と呼ばれるまでにパイプと一体化した。Thompson shellで採用されたこの記法は、後続のほぼすべてのUNIXシェル、さらにはMS-DOSにも受け継がれている。

### UNIX哲学の定式化――1978年

パイプの実装は、単なる機能追加にとどまらなかった。パイプは、UNIXの設計思想そのものを定式化する触媒となった。

1978年、Doug McIlroyはBell System Technical Journalの前書きで、UNIXの設計思想を次のように要約した。この要約は後にPeter H. Salusの著書 "A Quarter Century of UNIX"（1994年）に引用され、広く知られることになる。

> Write programs that do one thing and do it well.
> Write programs to work together.
> Write programs to handle text streams, because that is a universal interface.
>
> （一つのことをうまく行うプログラムを書け。協調して動くプログラムを書け。テキストストリームを扱うプログラムを書け、それが普遍的インタフェースだから。）

ここで注目すべきは第三の原則だ。「テキストストリームを扱え、それが普遍的インタフェースだから」。パイプを通じてプログラム間を流れるのは、バイナリデータでも構造化オブジェクトでもなく、テキストだ。この「テキストが普遍的インタフェースである」という宣言が、以後数十年にわたるUNIXツールの設計を規定した。

そしてこの宣言こそが、今日、揺らぎ始めている前提でもある。

---

## 3. 技術論――パイプの内側と「すべてはテキスト」の構造

### パイプのカーネル実装

パイプはシェルの構文として目に見えるが、その実体はカーネルが提供するプロセス間通信（IPC）の仕組みだ。パイプの動作を正確に理解するために、カーネルレベルの実装を見ておく。

シェルが`cmd1 | cmd2`を処理するとき、以下の手順が実行される。

```
パイプの実行モデル:

  1. シェルがpipe()システムコールを発行
     → カーネルがバッファを確保し、
       2つのファイルディスクリプタを返す
       fd[0]: 読み出し端（read end）
       fd[1]: 書き込み端（write end）

  2. シェルがfork()で子プロセスを2つ生成

  3. 子プロセス1（cmd1）:
     - fd[1]を標準出力（stdout, fd 1）に複製
     - 不要なfdをclose
     - exec()でcmd1を実行

  4. 子プロセス2（cmd2）:
     - fd[0]を標準入力（stdin, fd 0）に複製
     - 不要なfdをclose
     - exec()でcmd2を実行

  ┌──────────┐   fd[1]→バッファ→fd[0]   ┌──────────┐
  │   cmd1   │ ─────────────────────────→ │   cmd2   │
  │  stdout  │     カーネル空間の         │  stdin   │
  └──────────┘     リングバッファ         └──────────┘
       ↑                                       │
    fork+exec                              fork+exec
       │                                       │
  ┌────────────────────────────────────────────────┐
  │                    シェル                       │
  │              pipe() → fork() × 2               │
  └────────────────────────────────────────────────┘
```

この実装の要点は3つある。

第一に、パイプラインの各コマンドは独立したプロセスとして並行に実行される。`cmd1`と`cmd2`は同時に走る。`cmd1`がすべてのデータを出力し終わるのを待ってから`cmd2`が処理を始めるのではない。

第二に、データはカーネル空間のバッファを介して受け渡される。ディスクへの書き込みは発生しない。これが中間ファイルを使うよりもパイプが高速な理由だ。

第三に、バッファには容量制限がある。UNIX V6ではパイプバッファはルートデバイス上のiノードで表現され、固定サイズ4,096バイトだった。V7でもこの4KBが伝統的サイズとして維持された。現代のLinux（カーネル2.6.11以降）では16ページ、すなわち65,536バイト（64KB）に拡大されている。

### 背圧（バックプレッシャー）の仕組み

パイプのバッファ容量が有限であることは、重要な設計上の帰結をもたらす。背圧（バックプレッシャー）だ。

```
パイプの背圧メカニズム:

  ケース1: バッファに空きがある（通常動作）
  ┌──────┐  write()  ┌─────────────────┐  read()  ┌──────┐
  │ cmd1 │ ────────→ │ █████░░░░░░░░░░ │ ────────→│ cmd2 │
  └──────┘           └─────────────────┘          └──────┘
                      ↑ データあり  ↑ 空き

  ケース2: バッファが満杯（書き手ブロック）
  ┌──────┐  BLOCK!   ┌─────────────────┐  read()  ┌──────┐
  │ cmd1 │ ────×───→ │ ████████████████ │ ────────→│ cmd2 │
  └──────┘           └─────────────────┘          └──────┘
  書き手は              バッファ満杯
  スリープ

  ケース3: バッファが空（読み手ブロック）
  ┌──────┐  write()  ┌─────────────────┐  BLOCK!  ┌──────┐
  │ cmd1 │ ────────→ │ ░░░░░░░░░░░░░░░ │ ───×───→ │ cmd2 │
  └──────┘           └─────────────────┘          └──────┘
                      バッファ空          読み手は
                                          スリープ
```

バッファが満杯になると、write()を呼んだプロセス（書き手）はカーネルによってスリープ状態にされる。読み手がバッファからデータを読み出してバッファに空きができると、書き手が起こされて書き込みを再開する。逆にバッファが空のとき、read()を呼んだプロセス（読み手）はスリープ状態になり、書き手がデータを書き込むと起こされる。

この背圧メカニズムは、明示的なフロー制御なしにプロデューサー/コンシューマーパターンを実現する。パイプラインの中で最も遅いコマンドが全体の速度を決定し、高速なコマンドは自動的に減速される。プログラマが何も意識しなくても、データの流量は自動的に調整される。

これは今日の分散システムにおけるバックプレッシャーの概念——Reactive Streamsなどで明示的に設計される仕組み——の、最も素朴にして最も洗練された原型だ。1973年のカーネルが、明示的なプロトコルなしに背圧を実現していた。

### PIPE_BUFとアトミック書き込み

パイプに関してもう一つ理解しておくべき概念がPIPE_BUFだ。これはカーネルが保証するアトミック（不可分）書き込みの最大サイズを定義する。

POSIX.1はPIPE_BUFとして最低512バイトを要求し、Linuxでは4,096バイトに設定されている。PIPE_BUFバイト以下のwrite()は、途中で他のプロセスの書き込みが割り込むことなく、一つのまとまりとして書き込まれることが保証される。

これは、複数のプロセスが同じパイプに書き込む場合に重要になる。行単位のテキスト出力が混ざり合わずに読み手に届くためには、1行がPIPE_BUFバイト以内に収まっている必要がある。

### テキストストリームの暗黙の契約

パイプの実装はバイトストリームを流す。カーネルはデータの内容に関知しない。改行もスペースも、カーネルにとっては単なるバイトだ。

にもかかわらず、UNIXのツール群は「テキスト行」を前提として設計されている。ここに、UNIXにおけるパイプ利用の最も重要な——そして最も脆弱な——暗黙の契約がある。

```
テキストストリームの暗黙の契約:

  1. データは行指向である
     - 各レコードは改行（\n）で区切られる
     - 最後のレコードも改行で終わる

  2. フィールドは空白区切りである
     - フィールド間はスペースまたはタブで区切られる
     - 代替として特定の区切り文字（:, ,, \t）を使う場合もある

  3. テキストはASCIIまたはUTF-8である
     - バイナリデータはパイプに流さない（流してもよいが、
       テキスト処理ツールは正しく扱えない）

  この契約を前提として設計されたツール群:
  ┌──────────────────────────────────────────────┐
  │  grep   -- 行単位のパターンマッチ            │
  │  sed    -- 行単位のストリーム編集            │
  │  awk    -- フィールド区切りのレコード処理    │
  │  sort   -- 行単位のソート                    │
  │  uniq   -- 行単位の重複除去                  │
  │  cut    -- フィールド抽出                    │
  │  wc     -- 行/単語/バイト数のカウント        │
  │  head   -- 先頭N行の抽出                     │
  │  tail   -- 末尾N行の抽出                     │
  │  join   -- フィールドベースの結合            │
  │  paste  -- 行単位の結合                      │
  │  tr     -- 文字単位の変換                    │
  └──────────────────────────────────────────────┘
```

この契約はどのRFCにも、どのPOSIX標準にも明文化されていない。KernighanとPikeが1984年の "The UNIX Programming Environment" で描いたテキスト処理の伝統として、慣習的に成立したものだ。

そしてこの暗黙の契約が成立していた限り、パイプは驚くほどうまく機能した。`ps`の出力を`grep`で絞り込み、`awk`でフィールドを抽出し、`sort`で並べ替え、`uniq`で重複を除去する。各ツールはテキスト行を受け取り、テキスト行を返す。入力と出力のインタフェースが暗黙的に一致しているから、ツールの組み合わせが自由自在に機能する。

### パイプ芸の典型的パターン

テキストストリームの暗黙契約が生きている限り、パイプは強力だ。典型的なパイプラインのパターンを示す。

```sh
# パターン1: ログ分析
# 特定の時間帯のエラーを集計する
cat /var/log/syslog \
  | grep "ERROR" \
  | grep "2026-02-21" \
  | awk '{print $5}' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -10

# パターン2: プロセス管理
# 特定のプロセスのPIDを取得して停止する
ps aux | grep '[n]ginx' | awk '{print $2}' | xargs kill

# パターン3: テキスト変換
# CSVの特定列を抽出してソートする（単純な場合）
cut -d',' -f2,5 data.csv | sort -t',' -k1 | uniq
```

これらのパイプラインは、テキストストリームの暗黙契約が成立する限りにおいて、正確に動作する。`ps`の出力が空白区切りのテキスト行であること、`grep`が行単位でパターンマッチすること、`awk`がフィールドを空白で分割すること——これらすべてが、暗黙の契約の上に成り立っている。

### 契約が崩れるとき

だが、この暗黙の契約は、構造化データの時代に崩壊し始めた。

JSON、YAML、TOML、Protocol Buffers、MessagePack——現代のソフトウェアが扱うデータ形式は、テキスト行指向のフラットな構造から大きく離れている。ネストされたオブジェクト、配列、型情報（文字列・数値・真偽値の区別）、空白を含む値——これらはすべて、テキストストリームの暗黙契約に反する性質だ。

具体例で見よう。以下はKubernetesの`kubectl`が返すJSON出力の一部だ。

```json
{
  "items": [
    {
      "metadata": {
        "name": "nginx-deployment-abc123",
        "namespace": "production",
        "labels": {
          "app": "nginx",
          "version": "1.25"
        }
      },
      "status": {
        "phase": "Running",
        "containerStatuses": [
          {
            "name": "nginx",
            "ready": true,
            "restartCount": 0
          }
        ]
      }
    }
  ]
}
```

このデータから「productionネームスペースで稼働中のPodのうち、readyがtrueのコンテナ名」を抽出したいとしよう。

`grep`で"ready"の行を探す？ JSONのインデントに依存するから、フォーマットが変わると壊れる。`awk`で5番目のフィールドを切り出す？ JSONにはフィールド番号という概念がない。`sed`で正規表現を書く？ ネストされた構造を正規表現で正しく解析することは原理的に不可能だ。

テキストストリームの暗黙契約は、「1行1レコード、フィールドは空白区切り」という前提の上に成り立っていた。JSONはその前提をことごとく破る。1つのレコードが複数行にまたがり、フィールドの区切りはコロンとカンマの組み合わせであり、値には空白や改行が含まれうる。

これは`grep`や`awk`の「バグ」ではない。これらのツールは、テキスト行を処理するために設計された。設計通りに動いている。問題は、世界が変わったことだ。

---

## 4. 橋渡しツールと新しいパイプラインの形

### jq――JSONのためのawk

テキストストリームと構造化データの溝を最初に体系的に埋めたツールが、jqだ。

2012年、Stephen Dolanがjqをリリースした。「JSONのためのsed」と形容されるこのツールは、ポータブルCで書かれ、ランタイム依存がゼロだ。jqはJSONの構造を理解し、パイプライン的なフィルタ構文でデータを変換する。

先ほどのKubernetesのJSON出力から「readyがtrueのコンテナ名」を抽出する場合、jqではこう書ける。

```sh
kubectl get pods -o json | jq '
  .items[]
  | select(.metadata.namespace == "production")
  | select(.status.phase == "Running")
  | .status.containerStatuses[]
  | select(.ready == true)
  | .name
'
```

jqの構文にはパイプ記号`|`が使われている。これは偶然ではない。jqは、UNIXパイプの「データを変換しながら流す」という思想を、JSON構造の内部に持ち込んだ。UNIXパイプがプロセス間でテキスト行を流すのに対し、jqのパイプはフィルタ間でJSONの値を流す。

jqが解決した問題は明確だ。構造化データであるJSONを、テキスト処理ツール（grep/awk/sed）で無理やり扱う代わりに、JSONの構造を理解するツールでパイプライン的に処理する。`grep`がテキスト行のためのフィルタであるように、jqはJSONのためのフィルタだ。

### yqとxsv――橋渡しツールの拡大

jqの成功は、同じアプローチを他のデータ形式に拡張する動きを生んだ。

Mike Farahが開発したyqは、jqの構文をYAMLに拡張した。Goで書かれた単一バイナリで、YAML、JSON、XML、CSV、TOMLなど複数の形式を扱える。Kubernetesのマニフェスト（YAML）を日常的に操作するインフラエンジニアにとって、yqは不可欠なツールとなった。

Andrew Gallant（BurntSushi）が開発したxsvは、Rustで書かれた高速なCSVコマンドラインツールキットだ。CSVデータのインデックス作成、スライス、分析、分割、結合を提供する。「コマンドはシンプル、高速、合成可能であるべき」という設計思想は、まさにUNIX哲学の現代的な再解釈だ。

```
橋渡しツールの位置づけ:

  テキスト行の世界               構造化データの世界
  ┌─────────────────────┐       ┌─────────────────────┐
  │ grep, sed, awk      │       │ JSON, YAML, CSV     │
  │ sort, uniq, cut     │       │ TOML, XML           │
  │ head, tail, wc      │       │ Protocol Buffers    │
  └─────────┬───────────┘       └──────────┬──────────┘
            │                               │
            │    ┌───────────────────┐      │
            └───→│  橋渡しツール群    │←────┘
                 │  jq  (JSON)       │
                 │  yq  (YAML等)     │
                 │  xsv (CSV)        │
                 │  xmlstarlet (XML) │
                 └───────────────────┘
                         │
                         ▼
                 テキスト行として出力
                 → 従来のツール群で処理可能
```

これらの橋渡しツールの共通点は、構造化データを理解した上で、UNIXパイプラインに組み込めるインタフェースを提供することだ。入力として構造化データを受け取り、出力としてテキスト行（または別の構造化データ）を返す。既存のUNIXツール群との互換性を維持しながら、構造化データの世界とテキストの世界を接続する。

だが、これは本質的には「翻訳」だ。構造化データをテキスト行に変換し、テキスト処理ツールで扱えるようにする。変換の過程で、構造化データの持つ型情報やネスト構造は失われる。jqで抽出した値を`sort`や`uniq`で処理するとき、それらのツールはjqの出力を「単なるテキスト行」として扱う。データがもともと数値であったか文字列であったかは、sortにはわからない（`-n`オプションで数値ソートを明示しない限り）。

橋渡しツールは有用だ。だが、それはテキストストリームのパラダイム内での「修繕」であり、パラダイム自体の転換ではない。

### Nushell――パイプラインの再発明

パラダイムの転換を試みたのがNushellだ。

2019年5月10日に最初のコミットが行われ、同年8月23日にJonathan Turner, Yehuda Katz, Andres Robalinoの3人によって公式に発表されたNushellは、パイプラインの「単位」そのものを変えた。テキスト行ではなく、構造化されたテーブルがパイプラインを流れる。

Nushellの着想は興味深い経緯を持つ。Yehuda KatzがJonathan TurnerにPowerShellのデモを見せ、「構造化シェルの考え方をより関数的にするプロジェクトに参加しないか」と提案したことが契機だ。PowerShellのオブジェクトパイプライン（これについては第22回で詳述する）からインスピレーションを受けつつ、UNIXのパイプライン哲学と関数型プログラミングを融合させた。

Nushellで`ls`コマンドを実行すると、テキスト行ではなくテーブルが返る。

```
> ls
╭────┬──────────────┬──────┬──────────┬────────────╮
│  # │     name     │ type │   size   │  modified  │
├────┼──────────────┼──────┼──────────┼────────────┤
│  0 │ Cargo.toml   │ file │    2.5KB │ 2 days ago │
│  1 │ src          │ dir  │    4.0KB │ 1 hour ago │
│  2 │ README.md    │ file │    1.2KB │ 3 days ago │
│  3 │ tests        │ dir  │    4.0KB │ 5 days ago │
╰────┴──────────────┴──────┴──────────┴────────────╯
```

このテーブルは単なる表示形式ではない。各列には型がある。`name`は文字列、`size`はバイト数（数値）、`modified`は日時だ。この型情報がパイプラインを通じて保持される。

```nu
# Nushellでのパイプライン
ls | where size > 1kb | sort-by modified | select name size
```

`where size > 1kb`は、`size`列が1KB超の行をフィルタする。ここで`size`は数値として比較される。テキストの辞書順比較ではない。`sort-by modified`は日時として正しくソートする。「2 days ago」と「1 hour ago」を文字列としてソートしたら順序が狂うが、Nushellでは内部的に日時型として扱われるから正しい順序になる。

これをbashの従来のパイプラインで再現しようとすると、こうなる。

```sh
# bashでの同等処理（近似）
ls -la --time-style=+%s | awk 'NR>1 && $5 > 1024 {print $5, $6, $9}' \
  | sort -k2 -n
```

`awk`でサイズを数値比較し、UNIXタイムスタンプでソートする。だが、ファイル名にスペースが含まれていたら壊れる（前回のクォーティング地獄の再来だ）。型情報はない。すべてがテキストだ。

Nushellが示したのは、パイプの「天才的な発明」——データを一方向に流し、各段階で変換する——はテキストに限定される必然性がないということだ。構造化データをパイプラインの単位にすれば、型情報を保持したまま変換・フィルタ・集計ができる。

### 3つのアプローチの比較

同じデータ処理タスクを3つのアプローチで実装し、その違いを整理する。

タスク: Webサーバのアクセスログから、レスポンスコード別のリクエスト数を集計し、上位5件を表示する。

```
アプローチ1: 伝統的パイプ（awk/sort/uniq）
──────────────────────────────────────────
cat access.log \
  | awk '{print $9}' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -5

前提: ログが空白区切りで、9番目のフィールドがレスポンスコード
長所: 高速、どのUNIX系OSでも動作、追加ツール不要
短所: フィールド番号のハードコード、ログ形式変更で壊れる

アプローチ2: jqパイプ（JSONログの場合）
──────────────────────────────────────────
cat access.json \
  | jq -r '.status_code' \
  | sort \
  | uniq -c \
  | sort -rn \
  | head -5

前提: ログがJSON形式（1行1JSONオブジェクト）
長所: フィールド名でアクセス、構造変更に強い
短所: jqのインストールが必要、テキスト世界への変換が発生

アプローチ3: Nushellのテーブル処理
──────────────────────────────────────────
open access.json --raw
  | lines
  | each { from json }
  | group-by status_code
  | transpose key value
  | each { |row| { code: $row.key, count: ($row.value | length) } }
  | sort-by count --reverse
  | first 5

前提: Nushellがインストールされていること
長所: 型安全、構造化処理、可読性が高い
短所: 学習コスト、既存スクリプトとの互換性なし
```

三者の違いは「データの抽象度」にある。伝統的パイプはテキスト行というフラットな抽象化で動く。jqは構造化データを理解するがパイプライン全体はテキスト世界に留まる。Nushellはパイプライン全体を構造化データで統一する。

どのアプローチが「正解」かは、文脈による。ログが安定したテキスト形式であり、ワンライナーで済む分析なら、伝統的パイプが最も効率的だ。JSONログを日常的に扱うなら、jqは不可欠だ。データ分析を頻繁に行い、型安全性と可読性を重視するなら、Nushellが優れている。

---

## 5. ハンズオン――テキストパイプと構造化パイプを体験する

理論を手で確かめよう。同じデータ処理タスクを、伝統的パイプ（awk/sed/grep）、jqパイプ、そしてNushellのテーブル処理で実装し、可読性と堅牢性を比較する。

### 環境構築

Docker環境を前提とする。jqとNushellもインストールする。

```bash
docker run -it ubuntu:24.04 bash
# コンテナ内で:
apt-get update && apt-get install -y jq curl
```

あるいは、本記事に付属する`setup.sh`スクリプトを使えば、演習環境の構築を一括で行える。

```bash
bash setup.sh
```

### 演習1：パイプの基本――データが流れる様子を可視化する

まず、パイプの動作を段階的に確認する。各段階でデータがどう変換されるかを目に見える形にする。

```sh
# --- パイプの基本動作 ---

WORK="/tmp/pipe-demo"
mkdir -p "$WORK"

# サンプルデータの作成
cat > "$WORK/access.log" << 'EOF'
192.168.1.10 - - [21/Feb/2026:10:15:30] "GET /index.html HTTP/1.1" 200 1234
192.168.1.20 - - [21/Feb/2026:10:15:31] "GET /api/users HTTP/1.1" 200 5678
192.168.1.30 - - [21/Feb/2026:10:15:32] "POST /api/login HTTP/1.1" 401 89
192.168.1.10 - - [21/Feb/2026:10:15:33] "GET /style.css HTTP/1.1" 200 2345
192.168.1.40 - - [21/Feb/2026:10:15:34] "GET /api/data HTTP/1.1" 500 123
192.168.1.20 - - [21/Feb/2026:10:15:35] "GET /index.html HTTP/1.1" 200 1234
192.168.1.50 - - [21/Feb/2026:10:15:36] "DELETE /api/users/5 HTTP/1.1" 403 45
192.168.1.10 - - [21/Feb/2026:10:15:37] "GET /favicon.ico HTTP/1.1" 404 0
192.168.1.30 - - [21/Feb/2026:10:15:38] "POST /api/login HTTP/1.1" 200 3456
192.168.1.40 - - [21/Feb/2026:10:15:39] "GET /api/data HTTP/1.1" 500 123
EOF

echo "=== ステップ1: 元データ ==="
cat "$WORK/access.log"
echo ""

echo "=== ステップ2: レスポンスコード列を抽出（awk） ==="
cat "$WORK/access.log" | awk '{print $9}'
echo ""

echo "=== ステップ3: ソート ==="
cat "$WORK/access.log" | awk '{print $9}' | sort
echo ""

echo "=== ステップ4: 重複カウント ==="
cat "$WORK/access.log" | awk '{print $9}' | sort | uniq -c
echo ""

echo "=== ステップ5: 降順ソート ==="
cat "$WORK/access.log" | awk '{print $9}' | sort | uniq -c | sort -rn
echo ""

echo "各段階で、テキスト行が次のコマンドに渡されている。"
echo "各コマンドは前段の出力形式（テキスト行）を前提としている。"
```

### 演習2：テキストパイプの限界――JSONデータとの格闘

テキストパイプでJSONを扱おうとすると何が起きるかを体験する。

```sh
# --- テキストパイプでJSONを扱う困難 ---

# JSONログデータの作成
cat > "$WORK/access.json" << 'EOF'
{"timestamp":"2026-02-21T10:15:30Z","ip":"192.168.1.10","method":"GET","path":"/index.html","status":200,"bytes":1234}
{"timestamp":"2026-02-21T10:15:31Z","ip":"192.168.1.20","method":"GET","path":"/api/users","status":200,"bytes":5678}
{"timestamp":"2026-02-21T10:15:32Z","ip":"192.168.1.30","method":"POST","path":"/api/login","status":401,"bytes":89}
{"timestamp":"2026-02-21T10:15:33Z","ip":"192.168.1.10","method":"GET","path":"/style.css","status":200,"bytes":2345}
{"timestamp":"2026-02-21T10:15:34Z","ip":"192.168.1.40","method":"GET","path":"/api/data","status":500,"bytes":123}
{"timestamp":"2026-02-21T10:15:35Z","ip":"192.168.1.20","method":"GET","path":"/index.html","status":200,"bytes":1234}
{"timestamp":"2026-02-21T10:15:36Z","ip":"192.168.1.50","method":"DELETE","path":"/api/users/5","status":403,"bytes":45}
{"timestamp":"2026-02-21T10:15:37Z","ip":"192.168.1.10","method":"GET","path":"/favicon.ico","status":404,"bytes":0}
{"timestamp":"2026-02-21T10:15:38Z","ip":"192.168.1.30","method":"POST","path":"/api/login","status":200,"bytes":3456}
{"timestamp":"2026-02-21T10:15:39Z","ip":"192.168.1.40","method":"GET","path":"/api/data","status":500,"bytes":123}
EOF

echo "=== タスク: ステータスコード別のリクエスト数を集計 ==="
echo ""

echo "--- 方法1: grepで無理やり抽出（脆弱） ---"
grep -o '"status":[0-9]*' "$WORK/access.json" \
  | cut -d':' -f2 \
  | sort \
  | uniq -c \
  | sort -rn
echo ""
echo "grepの正規表現はJSONの構造を理解しない。"
echo "キー名に'status'を含む別のフィールドがあれば誤抽出する。"
echo ""

echo "--- 方法2: jqで構造的に抽出（堅牢） ---"
jq -r '.status' "$WORK/access.json" \
  | sort \
  | uniq -c \
  | sort -rn
echo ""
echo "jqはJSONの構造を理解する。.statusで正確にフィールドを指定できる。"
echo ""

echo "--- 方法3: jqだけで完結（テキストツール不要） ---"
jq -s 'group_by(.status) | map({status: .[0].status, count: length}) | sort_by(-.count)' \
  "$WORK/access.json"
echo ""
echo "jqの-sオプションで全行をスラープし、jq内部でグループ化と集計を行う。"
echo "出力はJSON形式。型情報が保持されている。"
```

### 演習3：jqの構造化フィルタリング

jqのパイプライン的フィルタ構文を体験する。

```sh
# --- jqの構造化フィルタリング ---

echo "=== ネストされたJSONの処理 ==="

# ネストされたJSONデータ
cat > "$WORK/servers.json" << 'EOF'
{
  "servers": [
    {
      "name": "web-01",
      "region": "ap-northeast-1",
      "status": "running",
      "resources": {
        "cpu_percent": 45.2,
        "memory_mb": 2048,
        "disk_gb": 50
      },
      "tags": ["production", "web"]
    },
    {
      "name": "api-01",
      "region": "ap-northeast-1",
      "status": "running",
      "resources": {
        "cpu_percent": 78.5,
        "memory_mb": 4096,
        "disk_gb": 100
      },
      "tags": ["production", "api"]
    },
    {
      "name": "db-01",
      "region": "us-east-1",
      "status": "running",
      "resources": {
        "cpu_percent": 92.1,
        "memory_mb": 8192,
        "disk_gb": 500
      },
      "tags": ["production", "database"]
    },
    {
      "name": "dev-01",
      "region": "ap-northeast-1",
      "status": "stopped",
      "resources": {
        "cpu_percent": 0,
        "memory_mb": 1024,
        "disk_gb": 20
      },
      "tags": ["development"]
    }
  ]
}
EOF

echo "--- 稼働中サーバの名前とCPU使用率 ---"
jq '.servers[] | select(.status == "running") | {name, cpu: .resources.cpu_percent}' \
  "$WORK/servers.json"
echo ""

echo "--- CPU使用率80%超のサーバ（アラート対象） ---"
jq '.servers[] | select(.resources.cpu_percent > 80) | .name' \
  "$WORK/servers.json"
echo ""

echo "--- リージョン別のサーバ数 ---"
jq '[.servers[] | .region] | group_by(.) | map({region: .[0], count: length})' \
  "$WORK/servers.json"
echo ""

echo "--- productionタグを持つサーバのメモリ合計 ---"
jq '[.servers[] | select(.tags | index("production")) | .resources.memory_mb] | add' \
  "$WORK/servers.json"
echo "MB"
echo ""

echo "grepやawkではネストされたJSONの処理は事実上不可能だ。"
echo "jqはJSONの構造を理解し、パイプライン的なフィルタで処理する。"
```

### 演習4：パイプのバッファと背圧を体感する

パイプのバッファサイズと背圧の仕組みを実際に確認する。

```sh
# --- パイプのバッファと背圧 ---

echo "=== パイプバッファの確認 ==="

# パイプの容量を確認（Linuxの場合）
if [ -f /proc/sys/fs/pipe-max-size ]; then
  echo "パイプ最大容量: $(cat /proc/sys/fs/pipe-max-size) バイト"
fi
echo ""

echo "--- 背圧のデモ: 高速な書き手と低速な読み手 ---"
echo "書き手（yes）が高速にデータを生成し、"
echo "読み手（head -1）が1行だけ読んで終了する。"
echo ""

# yesは毎秒数百万行を生成するが、headが終了するとパイプが閉じ、
# yesはSIGPIPEを受けて終了する
time (yes "hello" | head -1)
echo ""

echo "yesは無限にデータを生成するが、headが1行読んで終了すると"
echo "パイプが閉じ、yesはSIGPIPEシグナルを受けて停止する。"
echo "これがパイプの「背圧」の一形態だ。"
echo ""

echo "--- PIPE_BUFの確認 ---"
echo "POSIX PIPE_BUF（アトミック書き込み保証）: 最低512バイト"
if command -v getconf > /dev/null 2>&1; then
  echo "この環境のPIPE_BUF: $(getconf PIPE_BUF /) バイト"
fi
```

### 演習5：伝統的パイプ vs jq――同じタスクの比較

同じ分析タスクを両方のアプローチで実装し、可読性と堅牢性を比較する。

```sh
# --- 実践比較: IPアドレス別のアクセス集計 ---

echo "=== タスク: IPアドレス別のアクセス数とバイト合計 ==="
echo ""

echo "--- 伝統的パイプ（テキストログ） ---"
echo "IPアドレス別アクセス数:"
awk '{print $1}' "$WORK/access.log" | sort | uniq -c | sort -rn
echo ""
echo "IPアドレス別バイト合計:"
awk '{bytes[$1]+=$10} END {for(ip in bytes) print bytes[ip], ip}' \
  "$WORK/access.log" | sort -rn
echo ""

echo "--- jqパイプ（JSONログ） ---"
echo "IPアドレス別アクセス数:"
jq -r '.ip' "$WORK/access.json" | sort | uniq -c | sort -rn
echo ""
echo "IPアドレス別バイト合計:"
jq -s 'group_by(.ip) | map({ip: .[0].ip, total_bytes: (map(.bytes) | add), count: length}) | sort_by(-.total_bytes)' \
  "$WORK/access.json"
echo ""

echo "=== 比較結果 ==="
echo "テキストパイプ: フィールド番号でアクセス。ログ形式に依存。"
echo "jqパイプ: フィールド名でアクセス。構造変更に強い。"
echo "jq -sでの完全集計: 型情報保持。結果もJSON。"
```

---

## 6. まとめと次回予告

### この回の要点

第一に、パイプはDoug McIlroyが1964年10月11日のBell Labs内部メモで構想し、Ken Thompsonが1973年1月15日に「一晩の熱狂的な作業」でUNIX V3に実装した。約9年の歳月を経て実現したこの仕組みは、UNIXの設計思想そのものを定式化する触媒となった。

第二に、パイプのカーネル実装はプロセス間通信の仕組みであり、バッファを介してデータを受け渡す。バッファが満杯になると書き手がブロックし、空になると読み手がブロックする背圧メカニズムにより、明示的なフロー制御なしにプロデューサー/コンシューマーパターンを実現する。

第三に、テキストストリームの「暗黙の契約」——1行1レコード、フィールドは空白区切り——は、どの標準にも明文化されていない慣習として成立した。この契約が成立する限り、UNIXのテキスト処理ツール群（grep, sed, awk, sort, uniq等）は驚くほど強力に機能する。

第四に、JSON、YAML等の構造化データの時代に、この暗黙の契約は崩壊し始めた。jq（Stephen Dolan, 2012年）、yq（Mike Farah）、xsv（Andrew Gallant）といった「橋渡しツール」は、構造化データとテキストストリームの溝を埋める役割を果たしているが、それはパラダイム内の修繕であってパラダイムの転換ではない。

第五に、Nushell（Jonathan Turner, Yehuda Katz, Andres Robalino, 2019年）は、パイプラインの「単位」そのものをテキスト行から構造化テーブルに変えた。型情報を保持したまま変換・フィルタ・集計ができるこのアプローチは、パイプの思想——データを一方向に流し、各段階で変換する——をテキストに限定しない形で再発明したものだ。

### 冒頭の問いへの暫定回答

「『すべてはテキスト』の哲学は、いつから限界を見せ始めたのか」――この問いに対する暫定的な答えはこうだ。

「すべてはテキスト」が限界を見せ始めたのは、テキスト行以外のデータ形式——JSON、YAML、Protocol Buffers——がソフトウェアの主要なデータ交換手段となった時点だ。正確な時期を特定することは難しいが、RESTful API（JSON）の普及が加速した2010年代前半がその転換点だと私は考える。

だが重要なのは、パイプそのものは限界を迎えていないということだ。パイプの本質は「データを一方向に流し、各段階で変換する」という抽象化にある。この抽象化は、データがテキスト行であるかJSONであるかテーブルであるかに依存しない。限界を迎えたのは「テキスト行が普遍的インタフェースである」という前提のほうだ。

McIlroyが1978年に「テキストストリームを扱え、それが普遍的インタフェースだから」と宣言したとき、テキスト行はたしかに普遍的だった。あらゆるプログラムがテキストを出力し、テキストを入力として受け取れた。だが今日、「普遍的インタフェース」の候補はテキスト行だけではない。構造化データが新たな普遍的インタフェースとなりうる時代が来ている。

パイプは天才的な発明だった。そして今もなお天才的だ。変わるべきは、パイプの中を流れるものの「前提」のほうだ。

### 次回予告

次回は、Bourne shellの系譜を離れ、まったく異なるシェル文化の誕生を語る。C shell——Bill JoyがBourne shellに対して起こした「反乱」だ。

1978年、UCバークレーの大学院生だったBill Joyは、Bourne shellとはまったく異なる構文のシェルを生み出した。C風の構文、ヒストリ機能、ジョブコントロール、エイリアス——cshが導入した対話的機能は、今日のシェルにも受け継がれている。だが、cshはスクリプティング言語としては「失敗」と評されることになる。Tom Christiansenの1995年の文書 "Csh Programming Considered Harmful" は、その問題を痛烈に指摘した。

対話に優れたシェルとスクリプティングに優れたシェルは、同じものでよいのか。この問いの原点を、次回は探る。

---

## 参考文献

- Doug McIlroy, "Prophetic Petroglyphs" (Bell Labs internal memo, October 11, 1964) <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/mdmpipe.html>
- K. Thompson, "UNIX Implementation", Bell System Technical Journal, Vol. 57, No. 6, Part 2, July-August 1978 <https://users.soe.ucsc.edu/~sbrandt/221/Papers/History/thompson-bstj78.pdf>
- Peter H. Salus, "A Quarter Century of UNIX", Addison-Wesley, 1994
- Brian Kernighan, Rob Pike, "The UNIX Programming Environment", Prentice Hall, 1984
- Doug McIlroy, Unix philosophy, Wikipedia <https://en.wikipedia.org/wiki/Unix_philosophy>
- Pipeline (Unix), Wikipedia <https://en.wikipedia.org/wiki/Pipeline_(Unix)>
- UNIX Heritage Wiki, "Pipes" <https://wiki.tuhs.org/doku.php?id=features:pipes>
- pipe(7) Linux manual page <https://man7.org/linux/man-pages/man7/pipe.7.html>
- Oracle Linux Blog, "An In-Depth Look at Pipe and Splice implementation in Linux kernel" <https://blogs.oracle.com/linux/post/pipe-and-splice>
- jq, Command-line JSON processor <https://github.com/jqlang/jq>
- jq (programming language), Wikipedia <https://en.wikipedia.org/wiki/Jq_(programming_language)>
- Mike Farah, yq <https://github.com/mikefarah/yq>
- Andrew Gallant, xsv <https://github.com/BurntSushi/xsv>
- Jonathan Turner, "Introducing nushell", 2019 <https://www.nushell.sh/blog/2019-08-23-introducing-nushell.html>
- The New Stack, "Pipe: How the System Call That Ties Unix Together Came About" <https://thenewstack.io/pipe-how-the-system-call-that-ties-unix-together-came-about/>
