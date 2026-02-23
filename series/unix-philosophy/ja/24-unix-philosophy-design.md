# UNIXという思想

## ――パイプ、プロセス、ファイル――すべてはここから始まった

### 第24回：「UNIX――技術ではなく設計哲学として」

**連載「UNIXという思想――パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- UNIX哲学の定式化の系譜――McIlroy（1978年）、Salus（1994年）、Gancarz（1995年）、Raymond（2003年）が残した言葉の変遷
- UNIX哲学を5つの原則に蒸留する試み――シンプルさ、合成可能性、インタフェースの統一、テキスト表現、制約の受容
- UNIXの設計哲学が影響を与えた5つの領域――OS設計、プログラミング言語、ソフトウェアアーキテクチャ、開発文化、インフラストラクチャ
- UNIX系譜図の全体像――Research Unix（1969年）からmacOS、Android、WSLに至る57年の系譜
- 自分のプロジェクトにUNIX哲学を適用する設計レビューの実践方法

---

## 1. 棚卸し

この連載を書き始めたのは、ある問いに答えるためだった。

「Docker、Kubernetes、マイクロサービス――モダンな技術スタックの裏側で、50年以上前の設計哲学がなぜ今も生きているのか？」

第1回で私はこの問いを提示し、23回にわたって答えを探してきた。Multicsの挫折からUNIXの誕生を語り、Ken ThompsonとDennis Ritchieの仕事を辿り、パイプとフィルタの思想を解剖し、UNIX戦争の顛末を追い、Linuxの台頭を見届け、systemdの論争に立ち会い、Plan 9の実験を振り返り、macOSとWSLを経て、マイクロサービスへの思想の転生を確認した。

そして最終回の今、私は1999年のSlackwareの黒い画面の前に、もう一度立っている。

あのとき私は24歳だった。`cat /var/log/messages | grep error | wc -l`と打ち込んで鳥肌が立った日のことを、第1回で書いた。三つのコマンドがそれぞれの仕事だけをこなし、パイプで繋がれた瞬間に、どの単体コマンドにも存在しない機能が出現する。あの感覚は、27年経った今も変わらない。

2026年の今、私はターミナルの前にいる。違うのは、Slackwareではなくmacの画面であること。そしてときどき、そのターミナルからClaude Codeに問いかけていること。だがターミナルの向こうにあるのは、依然としてUNIXの設計哲学の上に構築された世界だ。

24回の連載を書くことは、24年分のUNIXとの付き合いの棚卸しだった。書いているうちに気づいたことがある。私はUNIXを「使って」きたのではなく、UNIXの設計哲学に「育てられて」きたのだ。サーバを管理するときも、インフラを自動化するときも、マイクロサービスを設計するときも、私の判断基準の根底にはUNIXの原則があった。シンプルに作れ。組み合わせ可能にしろ。インタフェースを統一しろ。それらは意識的に参照するものではなく、呼吸のように身についた設計の文法だった。

この最終回では、23回の旅路を振り返り、UNIX哲学の本質を蒸留する。そして、この設計哲学から私たちは何を受け継ぎ、何を次の世代に伝えるべきかを問う。

あなたがこの連載を読んでくれたのなら――あなた自身のUNIXとの付き合いを、ここで一度、棚卸ししてみてほしい。

---

## 2. UNIX哲学の言葉たち――定式化の系譜

UNIX哲学を語る上で、まず確認しておかなければならないことがある。「UNIX哲学」とは、単一の文書に記された教義ではない。それは複数の人物が、異なる時代に、異なる角度から言語化してきた設計原則の集合体だ。

### McIlroyの原点（1978年）

UNIX哲学を最初に文書化したのは、パイプの発明者でもあるDoug McIlroyだ。1978年、Bell System Technical Journal（Vol. 57, No. 6）に掲載された「UNIX Time-Sharing System: Foreword」で、McIlroyはE. N. PinsonおよびB. A. Tagueとともに、UNIXの「特徴的なスタイル」を次のように記した。

> Make each program do one thing well. To do a new job, build afresh rather than complicate old programs by adding new "features".
>
> Expect the output of every program to become the input to another, as yet unknown, program. Don't clutter output with extraneous information. Avoid stringently columnar or binary input formats. Don't insist on interactive input.
>
> Design and build software, even operating systems, to be tried early, ideally within weeks. Don't hesitate to throw away the clumsy parts and rebuild them.
>
> Use tools in preference to unskilled help to lighten a programming task, even if you have to detour to build the tools and expect to throw some of them out after you've finished using them.

この4つの段落が、すべての始まりだ。1978年――UNIXが誕生してからわずか9年後のことである。注目すべきは、McIlroyが「設計原則」ではなく「特徴的なスタイル」という言葉を使っている点だ。教条ではなく、実践の中から浮かび上がったパターンとして記述している。

### Salusの蒸留（1994年）

16年後、Peter H. Salusは著書『A Quarter Century of UNIX』（1994年）で、McIlroyの哲学を3つの原則に蒸留した。

1. 一つのことをうまくやるプログラムを書け（Write programs that do one thing and do it well）
2. 協調して動くプログラムを書け（Write programs to work together）
3. テキストストリームを扱うプログラムを書け（Write programs to handle text streams, because that is a universal interface）

この3原則は、McIlroyの原文よりも簡潔で、引用しやすい。だが、McIlroyが述べた「早期にプロトタイプを作り、拙い部分は捨てて作り直せ」という原則と、「ツールを使え、そのツールを作るための寄り道を厭うな」という原則は、この蒸留の過程で落ちている。

### Gancarzの体系化（1995年）

翌年、Mike Gancarzは『The UNIX Philosophy』（1995年）で、UNIX哲学を9つの原則として体系化した。

1. Small is beautiful（小さいことは美しい）
2. Make each program do one thing well（各プログラムには一つのことをうまくやらせよ）
3. Build a prototype as soon as possible（できるだけ早くプロトタイプを作れ）
4. Choose portability over efficiency（効率より移植性を選べ）
5. Store data in flat text files（データはフラットテキストファイルに格納せよ）
6. Use software leverage to your advantage（ソフトウェアの梃子を活用せよ）
7. Use shell scripts to increase leverage and portability（シェルスクリプトで梃子と移植性を高めよ）
8. Avoid captive user interfaces（ユーザを捕囚するインタフェースを避けよ）
9. Make every program a filter（すべてのプログラムをフィルタにせよ）

Gancarzの貢献は、McIlroyが暗黙としていた原則を明示化したことにある。「効率より移植性を選べ」という第4の原則は、1973年にKen ThompsonとDennis RitchieがUNIXカーネルをアセンブリからCに書き直した判断――移植性を獲得するために実行速度を犠牲にした判断――を、設計原則として定式化したものだ。

### Raymondの展開（2003年）

Eric S. Raymondは2003年の著書『The Art of UNIX Programming』で、UNIX哲学を17のルールに展開した。Modularity（モジュール性）、Clarity（明晰さ）、Composition（合成）、Separation（分離）、Simplicity（シンプルさ）、Parsimony（節約）、Transparency（透明性）、Robustness（堅牢さ）、Representation（表現）、Least Surprise（最小の驚き）、Silence（沈黙）、Repair（修復）、Economy（経済性）、Generation（生成）、Optimization（最適化）、Diversity（多様性）、Extensibility（拡張性）。

17のルールは、それ以前の定式化と比べて圧倒的に詳細だ。だが詳細であるがゆえに、「UNIX哲学の本質は何か」という問いに対しては、かえって焦点がぼやける。

### 定式化の変遷が示すもの

1978年のMcIlroy（4つの段落）、1994年のSalus（3原則）、1995年のGancarz（9原則）、2003年のRaymond（17ルール）。原則の数が増えていく過程は、UNIX哲学の「発見」の歴史であると同時に、言語化することの困難さの証でもある。

本質的なことは、4人が異なる言葉で同じ核心を指し示しているということだ。その核心を、私なりに蒸留してみたい。

---

## 3. 5つの原則――UNIX哲学の蒸留

23回にわたってUNIXの歴史と技術を語ってきた結果、私はUNIX哲学の本質を5つの原則に蒸留できると考えるに至った。これは私個人の解釈であり、McIlroyやRaymondの定式化とは異なる。だが24年間UNIXと歩んできた経験を通じて、この5つがUNIX哲学の骨格だと確信している。

### 原則1：シンプルさを選べ（Complexity is the enemy）

第2回で語ったMulticsの挫折が、この原則の起源だ。

Multicsは1964年にMIT、Bell Labs、GEの共同プロジェクトとして始まった。セグメント化メモリ、マルチレベルセキュリティ、動的リンク――当時考えうるすべての先進的機能を一つのOSに詰め込もうとした。結果、プロジェクトは肥大化し、Bell Labsは1969年に撤退した。

その反動としてUNIXが生まれた。PDP-7という、18ビットワード、メモリ9Kワードの限られたハードウェアの上で。制約がシンプルさを強制し、そのシンプルさが57年生き延びる設計哲学に昇華した。

この原則をRob Pikeは2015年のdotGoカンファレンスで「Simplicity is Complicated」と表現した。Go言語の設計に携わったPikeは、「機能は複雑さを増し、可読性を損なう」「シンプルさとは複雑さを隠す技術だ」と述べた。UNIXの創造者Ken Thompsonとともに、Plan 9、UTF-8、Go言語を設計してきた人間の言葉として、これは重い。

シンプルさとは、機能が少ないことではない。必要な機能だけを選び、不要な機能を捨てる判断の蓄積だ。Go言語がジェネリクスを長年導入しなかったのは、ジェネリクスが不要だったからではなく、その導入による複雑さの増大が、シンプルさの原則と両立するかを慎重に吟味したからだ。

```
Multicsの設計方針:
  「あらゆる機能を一つのシステムに統合する」
  → 肥大化、遅延、最終的な失敗

UNIXの設計方針:
  「最小限の機能で動くシステムを作る」
  → 制約から生まれたシンプルさ、57年の寿命

教訓:
  複雑さは敵だ。だが「シンプルさを選ぶ」こと自体が、
  最も複雑な設計判断の一つである。
```

### 原則2：合成可能に作れ（Composability over monolithics）

第5回で詳述したパイプとフィルタの思想が、この原則の核心だ。

1973年、Doug McIlroyのアイデアからパイプがUNIXに導入された。`grep`は検索だけをやる。`sort`はソートだけをやる。`wc`はカウントだけをやる。単体では限定的な機能しかないが、パイプで繋ぐと無限の組み合わせが生まれる。

```
# 各コマンドは単機能、だが組み合わせで無限の表現力
cat access.log | grep "500" | cut -d' ' -f4 | sort | uniq -c | sort -rn

# 等価な「モノリシック」ツールを作ることも可能だが...
# → 1つの要件変更で全体の書き直しが必要
# → テストが困難
# → 再利用不可能
```

合成可能性の条件は、第8回で分析した通り、三つある。(1) 各コンポーネントが単一の責務を持つこと。(2) コンポーネント間のインタフェースが統一されていること。(3) コンポーネントが自身の外部環境について仮定を置かないこと。

この思想は、第23回で見たように、マイクロサービスアーキテクチャとして「転生」している。James Lewisが2012年に「Microservices - Java, the Unix Way」と題して発表したのは、UNIXのパイプラインとマイクロサービスの構造的アナロジーを意識的に認識していたからだ。「Smart endpoints and dumb pipes」――この原則は、UNIXの「愚かなパイプ」モデルへの回帰そのものだ。

### 原則3：インタフェースを統一せよ（Uniform interface）

第6回で語った「Everything is a file」がこの原則の象徴だ。

通常のファイル、ディレクトリ、デバイス、ソケット、パイプ。UNIXはこれらすべてをファイルディスクリプタという統一的なインタフェースで扱う。`open()`, `read()`, `write()`, `close()`――この4つのシステムコールで、ディスク上のテキストファイルも、ネットワーク越しの通信も、キーボードからの入力も操作できる。

```
UNIXのインタフェース統一:
  通常ファイル  ─→ open() / read() / write() / close()
  デバイス      ─→ open() / read() / write() / close()
  ソケット      ─→ open() / read() / write() / close()
  パイプ        ─→ open() / read() / write() / close()

対比: 統一インタフェースがない世界:
  通常ファイル  ─→ file_open() / file_read() / file_write()
  デバイス      ─→ device_attach() / device_input() / device_output()
  ソケット      ─→ socket_connect() / socket_recv() / socket_send()
  パイプ        ─→ pipe_create() / pipe_get() / pipe_put()

統一インタフェースの効果:
  → ツールの再利用性が飛躍的に向上
  → 組み合わせの爆発的増加
  → 学習コストの劇的な低減
```

この原則は、RESTful APIにおけるHTTPメソッド（GET, POST, PUT, DELETE）の統一、gRPCにおけるProtocol Buffersのインタフェース定義言語（IDL）として現代に受け継がれている。異なるものを同じように扱えること――それが抽象化の威力であり、合成可能性の前提条件だ。

### 原則4：テキストで表現せよ（Human-readable data）

第7回で論じたテキストストリームの思想がこの原則の根底にある。

UNIXの世界では、プログラム間のデータ交換は原則としてテキストで行われる。テキストは人間が読める。テキストは`grep`で検索できる。テキストは`sed`で変換できる。テキストは`diff`で比較できる。テキストは`cat`で結合できる。テキストは`sort`でソートできる。

この原則は、第22回で指摘した限界も持つ。構造化データの型なし問題、バイナリデータの扱いにくさ、PowerShellが提示した「オブジェクトパイプライン」という代替案。だが限界があることと、原則として有効であることは矛盾しない。

2026年の今、設定ファイルはYAMLやTOMLで書かれ、APIレスポンスはJSONで返され、インフラの定義はTerraformのHCLで記述される。これらはすべてテキストだ。人間が読め、バージョン管理でき、`diff`で差分を確認できる。UNIXの「テキストで表現せよ」という原則は、形を変えて生き続けている。

### 原則5：制約を受け入れよ（Constraints breed creativity）

この原則は、他の4つの原則を生み出した「母なる原則」だ。

UNIXがシンプルだったのは、PDP-7が貧弱だったからだ。パイプが発明されたのは、メモリにすべてのデータを載せられなかったからだ。テキストが共通インタフェースになったのは、テレタイプ端末がテキストしか表示できなかったからだ。

制約は敵ではない。制約は設計を研ぎ澄ます砥石だ。

第2回で私が伝えたかったことの核心がここにある。Multicsは制約を取り除こうとした。あらゆる機能を、あらゆるユーザに、あらゆる状況で提供しようとした。UNIXは制約を受け入れた。限られたハードウェアの上で、限られた機能を、限られた方法で提供した。そしてその「限られた方法」が、半世紀以上にわたって有効な設計原則になった。

この原則は、Go言語の設計にも表れている。Go言語は長年、ジェネリクスを持たず、例外機構を持たず、継承を持たなかった。これらの「欠落」は制約であり、Go言語のプログラマはその制約の中で、シンプルで明晰なコードを書くことを学んだ。Ken ThompsonとRob Pikeが、2007年にGo言語の開発を始めたとき、3人の設計者全員の合意がなければ機能を追加しないという原則を定めた。これは「制約を受け入れよ」の現代的な実践だ。

---

## 4. 系譜図――UNIXが遺したもの

UNIX哲学が影響を与えた領域を、具体的に確認しよう。

### OS設計

```
UNIXの系譜（1969年〜2026年）

Research Unix (1969-1979, Bell Labs)
├── BSD (1977-, UC Berkeley)
│   ├── 4.2BSD → SunOS → Solaris (Sun/Oracle)
│   ├── 4.3BSD → FreeBSD, OpenBSD, NetBSD
│   ├── NeXTSTEP → Darwin
│   │   └── macOS / iOS / iPadOS (Apple, UNIX 03認証済み)
│   └── BSDの知的遺産 → eBPF (Berkeley Packet Filter → Linux)
│
├── System V (1983-, AT&T)
│   ├── AIX (IBM)
│   ├── HP-UX (HP/HPE)
│   └── SVR4 (1989, AT&T+Sun) → UnixWare → SCO
│
├── Minix (1987, Andrew Tanenbaum)
│   └── 影響 → Linux (1991, Linus Torvalds)
│       ├── Android (2008, Google) → 39億デバイス
│       ├── ChromeOS (Google)
│       ├── WSL2 (Microsoft, 2019)
│       ├── SteamOS (Valve)
│       └── Top500スーパーコンピュータの100%
│
└── Plan 9 (1992, Bell Labs)
    ├── Inferno
    └── 思想的遺産 → 9P, UTF-8, /proc, goroutine
```

2026年現在、この系譜図が示す現実は圧倒的だ。

macOS Sequoia（15.0）はThe Open GroupによるUNIX 03認証を受けている。Apple Siliconとx86-64の両アーキテクチャで認証済みだ。最初のUNIX認証はMac OS X 10.5 Leopard（2007年10月26日）にまで遡る。

Androidは39億台のアクティブデバイスで稼働し、グローバルモバイルOS市場の約73%を占める。そのすべてがLinuxカーネルの上に構築されている。

Top500スーパーコンピュータの100%がLinuxで稼働している。2017年11月以降、7年連続でこの状態が続いている。世界最速のEl Capitan（1.742 EFLOPS）も、2位のFrontier（1.353 EFLOPS）も、3位のAurora（1.012 EFLOPS）も、すべてLinuxだ。

スマートフォンからスーパーコンピュータまで、UNIXの系譜に連なるOSが支配している。1969年にPDP-7の前でKen Thompsonが書いた設計思想の子孫たちだ。

### プログラミング言語

UNIXとC言語は不可分の関係にある。第3回で語った通り、Dennis Ritchieが設計したCは、UNIXを移植可能にするために生まれた言語だった。1973年のVersion 4でUNIXカーネルがCで書き直されたことは、ソフトウェア史における転換点だ。2025年末にユタ大学の収納室から発見された1973年のUNIX V4テープは、カーネルとコアユーティリティがCで書き直された最初のバージョンの現存する唯一の完全なコピーとされる。Computer History MuseumがそのデータをSimHで実行可能な形で復元し、Internet Archiveで公開したことは、計算機科学史の保存という観点で画期的だ。

2026年1月のTIOBEインデックスで、Cは第2位の座にある。1973年に生まれた言語が、53年を経てなおプログラミング言語の最前線に立っている。

そしてC言語の思想的後継者たちがいる。Go言語は、UNIXの創造者Ken Thompson、Plan 9の設計者Rob Pike、そしてRobert Griesemerの3人が2007年にGoogleで開発を始めた。UNIX哲学のシンプルさと合成可能性が、言語設計のレベルで体現されている。Rustはメモリ安全性を型システムで保証するという、C言語が残した課題への回答だ。SwiftはObjective-Cの後継として、AppleのUNIX系OS（macOS、iOS）のネイティブ言語となっている。

### ソフトウェアアーキテクチャ

第23回で詳述した通り、マイクロサービスアーキテクチャはUNIX哲学の「転生」だ。Martin FowlerとJames Lewisが2014年に定式化した原則――「Smart endpoints and dumb pipes」「Services organized around business capabilities」「Decentralized data management」――は、UNIXの「一つのことをうまくやれ」「愚かなパイプで繋げ」「プロセスを独立させよ」の現代版だ。

12-Factor App（2011年、Heroku、Adam Wiggins）は、UNIXの設計原則をクラウドネイティブ・アプリケーションに翻訳した。特に第6の原則「Concurrency」は、UNIXのプロセスモデルを明示的に参照している。

### 開発文化

UNIXがオープンソース文化に与えた影響は計り知れない。第12回で語ったGNU宣言（1983年、Richard Stallman）は、AT&TがUNIXのソースコードへのアクセスを制限したことへの直接的な反応だった。「ソフトウェアは自由であるべきだ」という思想は、UNIXの文化から生まれた。

BSDライセンスとGPLという二つの主要なオープンソースライセンスは、ともにUNIXの文脈から誕生している。BSDはUC BerkeleyのUNIX派生物のライセンスとして、GPLはGNUプロジェクトのライセンスとして。

### インフラストラクチャ

第20回で論じたDockerとKubernetesは、UNIXの原則を現代のインフラストラクチャに適用した結果だ。Dockerコンテナは、UNIXのプロセス分離（chroot、namespaces、cgroups）を洗練させた技術だ。Kubernetesのポッドは、UNIXのプロセスグループの分散版と見ることができる。

eBPF（extended Berkeley Packet Filter）は、BSDの知的遺産がLinuxカーネルの中で新たな命を得た例だ。2024-2025年にかけて、オブザーバビリティ、セキュリティ、ネットワーキングの各領域でeBPFの採用が急速に進んだ。カーネルのソースコードを変更することなく、カーネル内でサンドボックス化されたプログラムを実行できるこの技術は、UNIXの「カーネルは小さく保て、機能拡張はユーザ空間で」という原則の現代的な実践だ。

---

## 5. ハンズオン：UNIX哲学による設計レビュー

最終回のハンズオンは、技術を操作するものではなく、思考を操作するものにしたい。あなた自身のプロジェクトに、UNIX哲学を適用する設計レビューを行おう。

### 環境準備

特別な環境は不要だ。ターミナルとテキストエディタがあればよい。以下のスクリプトは、設計レビューの枠組みを提供する。

```bash
# Docker環境（ubuntu:24.04推奨）
docker run -it --rm ubuntu:24.04 bash

# 必要なツール
apt-get update && apt-get install -y tree jq curl
```

### 演習1：コンポーネントの責務分析

自分のプロジェクト（または任意のOSSプロジェクト）のディレクトリ構成を出発点にする。

```bash
# プロジェクトのディレクトリ構造を確認する
# ここでは例としてシンプルなWebアプリケーションを想定する
mkdir -p ~/unix-review/{src,config,docs}
cd ~/unix-review

# 架空のプロジェクト構造を作成
cat > src/app.py << 'PYTHON'
# 典型的な「モノリシック」なファイル
class UserService:
    def authenticate(self, username, password): pass
    def get_profile(self, user_id): pass
    def update_profile(self, user_id, data): pass
    def send_notification(self, user_id, message): pass
    def generate_report(self, user_id): pass
    def export_to_csv(self, user_id): pass
    def validate_email(self, email): pass
    def reset_password(self, user_id): pass
    def log_activity(self, user_id, action): pass
    def check_permission(self, user_id, resource): pass
PYTHON

# UNIX哲学チェック: このクラスは「一つのことをうまくやって」いるか？
echo "=== 責務分析 ==="
echo "UserServiceクラスのメソッド数:"
grep -c "def " src/app.py
echo ""
echo "メソッド一覧:"
grep "def " src/app.py | sed 's/.*def /  - /' | sed 's/(.*/:/'
echo ""
echo "問い: この10個のメソッドは、単一の責務に属するか？"
echo "      UNIXコマンドなら、これは10個の独立したコマンドになるだろう。"
```

**考えるべきこと：** `UserService`は認証、プロフィール管理、通知、レポート生成、CSV出力、バリデーション、パスワードリセット、ログ、権限チェックの10の責務を持っている。UNIXの設計哲学に照らせば、これらはそれぞれ独立したコンポーネントであるべきだ。`grep`が検索だけをやるように、`AuthService`は認証だけを、`NotificationService`は通知だけを担う。

### 演習2：インタフェースの統一性チェック

```bash
# 複数のコンポーネントのインタフェースを比較する
cat > config/interfaces.json << 'JSON'
{
  "services": [
    {
      "name": "UserAPI",
      "endpoints": [
        {"method": "GET",    "path": "/users/{id}",     "response": "JSON"},
        {"method": "PUT",    "path": "/users/{id}",     "response": "JSON"},
        {"method": "DELETE", "path": "/users/{id}",     "response": "JSON"}
      ]
    },
    {
      "name": "OrderAPI",
      "endpoints": [
        {"method": "POST",   "path": "/orders",          "response": "JSON"},
        {"method": "GET",    "path": "/orders/{id}",     "response": "JSON"},
        {"method": "PATCH",  "path": "/order/update",    "response": "XML"}
      ]
    },
    {
      "name": "NotificationAPI",
      "endpoints": [
        {"method": "POST",   "path": "/notify/send",     "response": "plain text"},
        {"method": "GET",    "path": "/notify/history",   "response": "CSV"}
      ]
    }
  ]
}
JSON

echo "=== インタフェース統一性チェック ==="
echo ""
echo "レスポンスフォーマットの不統一を検出:"
jq -r '.services[] | .name as $svc |
  .endpoints[] | "\($svc): \(.method) \(.path) -> \(.response)"' config/interfaces.json
echo ""
echo "--- 問題点 ---"
jq -r '.services[] | .name as $svc |
  .endpoints[] | select(.response != "JSON") |
  "  警告: \($svc) の \(.method) \(.path) は \(.response) を返す（JSONではない）"' config/interfaces.json
echo ""
echo "UNIXの原則: すべてのコマンドはテキストストリームを入出力とする。"
echo "現代の翻訳: すべてのAPIはJSON（またはProtobuf等の統一フォーマット）を入出力とする。"
echo "  → OrderAPIの /order/update はパスの命名規則も不統一。"
echo "  → NotificationAPIのレスポンスがplain textやCSVなのは、合成可能性を損なう。"
```

**考えるべきこと：** UNIXのコマンドはすべてテキストストリームを入出力とする。この統一性があるからこそ、パイプで自由に組み合わせられる。同様に、APIのレスポンスフォーマットが統一されていれば、クライアント側の処理を共通化でき、サービス間の合成が容易になる。

### 演習3：合成可能性の設計レビューチェックリスト

```bash
cat > ~/unix-review/checklist.sh << 'BASH'
#!/bin/bash
set -euo pipefail

echo "============================================"
echo " UNIX哲学 設計レビューチェックリスト"
echo "============================================"
echo ""

# チェックリスト項目
questions=(
  "1. 単一責務: このコンポーネントは一つのことをうまくやっているか？"
  "   → UNIXの grep は検索だけをやる。このコンポーネントの「一つのこと」は何か？"
  ""
  "2. 合成可能性: このコンポーネントは他のコンポーネントと組み合わせ可能か？"
  "   → 入力と出力のフォーマットは統一されているか？依存関係は最小か？"
  ""
  "3. インタフェースの統一: すべてのコンポーネントが同じインタフェース規約に従っているか？"
  "   → UNIXの open/read/write/close のように、操作の種類は統一されているか？"
  ""
  "4. テキスト表現: データは人間が読める形式か？"
  "   → 設定ファイル、ログ、API応答はテキストベースか？diff可能か？"
  ""
  "5. 制約の受容: 不要な機能を追加していないか？"
  "   → その機能は本当に必要か？制約を受け入れることでシンプルになる余地はないか？"
  ""
  "--- 追加チェック ---"
  ""
  "6. 愚かなパイプ: コンポーネント間の通信層にビジネスロジックが漏れていないか？"
  "   → ESBの過ちを繰り返していないか？パイプ（通信層）は愚かに保て。"
  ""
  "7. 早期プロトタイプ: 設計を早期に検証しているか？"
  "   → McIlroyの原則: 数週間以内に試せるように設計・構築せよ。"
  ""
  "8. 捨てる覚悟: 拙い部分を作り直す覚悟はあるか？"
  "   → McIlroyの原則: 拙い部分は捨てて作り直すことを躊躇うな。"
)

for q in "${questions[@]}"; do
  echo "$q"
done

echo ""
echo "============================================"
echo " このチェックリストをコードレビューやアーキテクチャ"
echo " レビューの場で使ってみてほしい。"
echo " UNIXコマンドのように、繰り返し使えるツールとして。"
echo "============================================"
BASH

chmod +x ~/unix-review/checklist.sh
bash ~/unix-review/checklist.sh
```

このチェックリストの8項目は、McIlroyの4つの段落（1978年）、この連載の5原則、そしてSOAの教訓（第23回）から導出したものだ。コードレビューやアーキテクチャレビューの場で、このチェックリストを回すだけでも、設計の質は変わる。

**なぜそうなるのか：** UNIX哲学を「教養」として知っているだけでは、設計は変わらない。チェックリストという「ツール」に変換することで、日々の設計判断に組み込める。これ自体が、UNIXの原則――「ツールを使え、そのツールを作るための寄り道を厭うな」――の実践だ。

---

## 6. まとめ――技術は変わる、原則は残る

### この連載の要点

24回にわたる連載を、最終回として振り返る。

第一に、UNIX哲学は「技術」ではなく「設計哲学」だ。UNIXというOSは、1969年にBell LabsでKen ThompsonとDennis Ritchieが始めた一つのプロジェクトに過ぎない。だがそこから生まれた設計哲学――シンプルさを選べ、合成可能に作れ、インタフェースを統一せよ、テキストで表現せよ、制約を受け入れよ――は、OSの枠を超えて、ソフトウェア設計の普遍的原則として57年間生き延びてきた。

第二に、UNIX哲学は万能ではない。第22回で語った通り、テキストストリームの型なし問題、GUIとの相性の悪さ、状態管理の不在、エラーハンドリングの貧弱さ、セキュリティモデルの古さ――限界は明確に存在する。原則を知ることの真の価値は、その原則が適用できない領域を見極められるようになることにある。

第三に、UNIX哲学は「転生」し続けている。マイクロサービスの「一つのサービスは一つのことをうまくやれ」、RESTの統一インタフェース、12-Factor Appのプロセスモデル、Dockerのコンテナ分離、Go言語のシンプルさ――これらはすべて、1969年のPDP-7の前で練り上げられた思想の子孫だ。

第四に、UNIX哲学を定式化してきた先人たちの言葉は、蓄積であって矛盾ではない。McIlroyの4つの段落（1978年）、Salusの3原則（1994年）、Gancarzの9原則（1995年）、Raymondの17ルール（2003年）。それぞれが異なる角度から同じ核心を照らしている。

第五に、UNIX哲学は「知っている」だけでは不十分だ。設計レビューのチェックリストとして、日々の判断基準として、身体に染み込ませること。それが「知って使え」の意味だ。

### 冒頭の問いへの回答

「UNIX哲学から私たちは何を受け継ぎ、何を次の世代に伝えるべきか？」

受け継ぐべきものは、5つの原則だ。シンプルさを選べ。合成可能に作れ。インタフェースを統一せよ。テキストで表現せよ。制約を受け入れよ。これらは、UNIXというOSが消滅した後も有効な、ソフトウェア設計の文法だ。

そして次の世代に伝えるべきは、歴史的文脈だ。なぜシンプルさが選ばれたのか。Multicsの野心と挫折。PDP-7の制約。パイプの発明。C言語による移植性の獲得。BSD対System Vの分裂と標準化。商用UNIXの栄華と衰退。Linuxの台頭。GNU宣言の思想的背景。systemdをめぐる原理主義と実用主義の対立。Plan 9が見せた未来の残像。macOSとWSLによるUNIXの「浸透」。マイクロサービスへの思想の転生。

原則だけを伝えても、教条になる。歴史を伴って伝えることで、初めて「なぜそうなったのか」が理解できる。そして「なぜそうなったのか」を理解した人間だけが、原則が適用できない場面を見極め、原則を超える判断ができる。

### 連載を終えるにあたって

1999年のSlackwareの黒い画面から、2026年のターミナルまで。私は27年間、UNIXの設計哲学の上で仕事をしてきた。

この連載を書くことで、私自身の設計判断の根底にあった原則を、初めて体系的に言語化できた。呼吸のように身についていたものを、言葉にする作業だった。

最後にもう一度、この連載を貫いてきた一文を。

**UNIXを使えとは言わない。UNIXの設計哲学を「知って」使え。**

知った上で、その原則が有効な場面と限界がある場面を見分けよ。そのためには、UNIXがなかった時代――Multicsの巨大な野心と挫折――を知れ。

技術は変わる。だが良い設計の原則は、驚くほど長く生き延びる。

1969年に生まれた設計哲学が、57年後の今もソフトウェアの世界を静かに支配している。それが何よりの証拠だ。

あなたの設計の根底には、何があるだろうか。

---

## 参考文献

- M. D. McIlroy, E. N. Pinson, B. A. Tague, "UNIX Time-Sharing System: Foreword", Bell System Technical Journal, 57(6), July-August 1978: <https://archive.org/details/bstj57-6-1899>
- Peter H. Salus, "A Quarter Century of UNIX", Addison-Wesley, 1994
- Mike Gancarz, "The UNIX Philosophy", Digital Press, 1995
- Eric S. Raymond, "The Art of UNIX Programming", Addison-Wesley, 2003: <http://www.catb.org/esr/writings/taoup/html/>
- Rob Pike, "Simplicity is Complicated", dotGo 2015: <https://go.dev/talks/2015/simplicity-is-complicated.slide>
- Dennis Ritchie, Wikipedia: <https://en.wikipedia.org/wiki/Dennis_Ritchie>
- Ken Thompson, Wikipedia: <https://en.wikipedia.org/wiki/Ken_Thompson>
- The Open Group, "The Register of UNIX Certified Products": <https://www.opengroup.org/openbrand/register/>
- TOP500, "Operating system Family / Linux": <https://www.top500.org/statistics/details/osfam/1/>
- The Register, "UNIX V4 tape successfully recovered", December 2025: <https://www.theregister.com/2025/12/23/unix_v4_tape_successfully_recovered/>
- Martin Fowler, James Lewis, "Microservices: A Definition of This New Architectural Term", 25 March 2014: <https://martinfowler.com/articles/microservices.html>
- Adam Wiggins, "The Twelve-Factor App", 2011: <https://12factor.net/>
- ebpf.io, "What is eBPF?": <https://ebpf.io/what-is-ebpf/>
- StatCounter, "Mobile Operating System Market Share Worldwide": <https://gs.statcounter.com/os-market-share/mobile/worldwide>
