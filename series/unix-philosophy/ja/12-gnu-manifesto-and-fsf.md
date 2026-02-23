# UNIXという思想

## ——パイプ、プロセス、ファイル――すべてはここから始まった

### 第12回：「GNU宣言とFSF——自由ソフトウェアという思想」

**連載「UNIXという思想——パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Richard Stallmanがフリーソフトウェア運動を起こした直接的な契機——1980年のXerox 9700プリンタ事件とMIT AI Labのハッカー文化の崩壊
- GNUプロジェクトの発表（1983年9月27日）からFree Software Foundation設立（1985年10月4日）に至る経緯
- GNU宣言（1985年3月、Dr. Dobb's Journal）が提示した思想——ソフトウェアは「自由であるべきだ」という主張の構造
- GNUプロジェクトが生み出したツール群——GCC（1987年）、GNU Emacs（1985年）、Bash（1989年）、coreutilsの技術的系譜
- GPL（GNU General Public License）の設計思想——コピーレフトが「自由の保存」をどう法的に実現したか
- GPLv1（1989年）、GPLv2（1991年）、GPLv3（2007年）の進化と、Tivoization問題
- 「Free Software」と「Open Source」の思想的対立——Eric Raymondの「The Cathedral and the Bazaar」（1997年）とOSI設立（1998年）
- GNU/Linux論争——GNUのユーザランドとLinuxカーネルの関係
- コピーレフトとパーミッシブライセンス（MIT、BSD、Apache 2.0）の設計思想の違い

---

## 1. ソースコードが「閉ざされた」日

1999年、私がSlackware 3.5でLinuxに入門したとき、GCC（GNU Compiler Collection）の存在を当然のものとして受け止めていた。`gcc hello.c -o hello` と打てばCプログラムがコンパイルされる。`ls`、`cat`、`grep`、`sort`——日常的に使うコマンドの大半がGNU coreutilsだった。`bash` でシェルスクリプトを書き、`gdb` でデバッグし、`make` でビルドを自動化した。これらのツールはすべて「無料」で手に入り、ソースコードを読むことができた。

私はその状態を「当たり前」だと思っていた。だが、それは当たり前ではなかった。

1970年代から1980年代初頭のUNIXの世界では、ソースコードの共有は文化だった。AT&Tが大学にUNIXのソースコードをライセンス供与し、UCバークレーのBSDがその上に革新を積み重ねた。研究者やハッカーたちは、コードを読み、修正し、改良を共有した。UNIXの急速な進化は、このソースコードの「自由な流通」に支えられていた。

だがその文化は、1980年代に急速に失われた。

AT&Tは1983年のSystem Vリリースからソフトウェアのライセンス料を本格的に徴収し始めた。商用UNIXベンダーは自社の差別化のためにコードをクローズドにした。前回（第11回）で見たように、Sun MicrosystemsもIBMもHPも、自社プロセッサと自社OSの垂直統合モデルの中でソフトウェアを囲い込んだ。ソフトウェアは「製品」になり、ソースコードは「企業秘密」になった。

この変化に対して、一人の男が反旗を翻した。Richard Stallmanだ。

Stallmanの動機を理解するには、彼が経験した一つの小さな事件から始める必要がある。1980年、MIT AI Lab（人工知能研究所）にXerox 9700レーザープリンタが導入された。以前のプリンタ（XGP）では、Stallmanがソフトウェアを改造して、印刷完了時にユーザに通知を送り、紙詰まりが起きたらログイン中の全員に警告を出す機能を追加していた。だが新しいXerox 9700のソフトウェアは、プリコンパイル済みのバイナリだけが提供され、ソースコードへのアクセスは拒否された。

プリンタは別のフロアにあった。紙詰まりが起きても誰も気づかない。印刷が終わったかどうかもわからない。以前なら自分でソフトウェアを修正して解決できた問題が、バイナリの壁に阻まれて解決できなくなった。

この事件は些細に見えるかもしれない。だがStallmanにとって、これは原則の問題だった。ソフトウェアのユーザが、自分が使うプログラムの振る舞いを理解し、修正する自由を奪われたのだ。この体験は、Stallmanがフリーソフトウェア運動を起こす直接的な契機の一つとなった。

あなたは今、自分が使っているソフトウェアのソースコードをどれだけ読めるだろうか。Docker、Kubernetes、Linux——これらがオープンソースであることを、私たちはどれだけ意識しているだろうか。そしてその「オープン」は、誰の闘いによって勝ち取られたものなのか。

---

## 2. GNUプロジェクト——「完全に自由なUNIX互換OS」の宣言

### 1983年9月27日——Usenetに投じられた一石

1983年9月27日午前0時30分、Usenetのnet.unix-wizardsニュースグループに一通の投稿が現れた。投稿者はrms@mit-oz——MIT AI LabのRichard Stallmanだ。件名は「New UNIX implementation」。

冒頭はこう始まる。

> Starting this Thanksgiving I am going to write a complete Unix-compatible software system called GNU (for Gnu's Not Unix), and give it away free to everyone who can use it.

「この感謝祭からGNU（Gnu's Not Unix）と呼ぶ完全なUNIX互換ソフトウェアシステムを書き始め、使える人全員に無料で配布する。」

GNUは再帰的頭字語だ。「Gnu's Not Unix」——GNUはUNIXではない。だがUNIXと互換性があり、UNIXの設計思想を継承する。UNIXの精神を保ちながら、UNIXのライセンス制約から自由になる。その意思が名前に込められている。

Stallmanはカーネル、コンパイラ、エディタ、シェル、そしてUNIXの標準ユーティリティ群の一式をすべて自由なソフトウェアとして書くと宣言した。一人で始め、協力者を募った。

なぜStallmanはこの決断に至ったのか。

### MIT AI Labのハッカー文化の崩壊

1970年代のMIT AI Labは、ハッカー文化の聖地だった。PDP-10上で動くITS（Incompatible Timesharing System）——その名の通り「互換性のないタイムシェアリングシステム」——は、MIT独自のOSで、ハッカーたちが自由に改造し、機能を追加し、共有していた。パスワードは存在しなかった。ファイルは共有され、コードは誰もが読み、修正できた。Stallmanはこのコミュニティの中で育った。

だが1980年代初頭、この文化は急速に崩壊した。Symbolics社がMIT AI Labのハッカーを大量に引き抜き、Lispマシンのソフトウェアをクローズドにした。AT&Tは1983年のUNIX System V以降、ソフトウェアのライセンス条件を厳格化した。かつて自由に共有されていたソースコードが、NDA（秘密保持契約）の壁の向こう側に消えていった。

Stallmanは1982年から1983年末にかけて、Symbolicsのプログラマーの成果物をLisp Machine向けに独力でクローン実装するという孤独な闘いを続けた。だがこれは持続可能ではなかった。個別のソフトウェアを一つ一つクローンするのではなく、根本的な解決が必要だった——完全に自由なオペレーティングシステムを作ることだ。

1984年初頭、StallmanはMITを退職した。MITに在籍したままGNUを開発すると、MITが成果物に対して権利を主張し、配布条件を制限する可能性があったからだ。Stallmanは自由なソフトウェアを作るために、まず自分自身を制度的な制約から解放する必要があった。

### GNU宣言——1985年3月

1985年3月、Stallmanは「GNU宣言」をDr. Dobb's Journal of Software Toolsに発表した（pp. 30-34）。この文書はGNUプロジェクトの趣旨と設計思想を体系的に記述したもので、フリーソフトウェア運動の思想的基盤となった。

GNU宣言の核心は単純だ。ソフトウェアは「自由であるべきだ」。

ここで重要なのは、Stallmanが言う「free」は「無料（free as in free beer）」ではなく「自由（free as in freedom）」だということだ。Stallmanは後にこの区別を繰り返し強調することになる。自由なソフトウェアとは、ユーザが以下の四つの自由を持つソフトウェアを指す。

```
自由なソフトウェアの四つの自由（FSFによる定義）:

  Freedom 0: プログラムを、どのような目的にも実行する自由
  Freedom 1: プログラムの動作を研究し、必要に応じて改変する自由
             （ソースコードへのアクセスが前提条件）
  Freedom 2: コピーを再配布する自由
  Freedom 3: 改良版を公開し、コミュニティ全体が利益を得られるようにする自由
             （ソースコードへのアクセスが前提条件）

  ※ 番号が0から始まるのは、Freedom 0が後から追加されたため
```

この四つの自由の定義は、単なる理想論ではない。ソフトウェアの利用者が、自分が使うプログラムに対して主体性を持つための最小限の条件だ。ソースコードが読めなければ、プログラムが何をしているかわからない。修正できなければ、バグを直せない。再配布できなければ、他者を助けられない。改良版を公開できなければ、コミュニティ全体の知識が蓄積されない。

Stallmanの主張は、当時の商用ソフトウェア産業の常識と真っ向から対立した。ソフトウェアはライセンス料で利益を上げる「製品」であり、ソースコードは企業の「知的財産」として保護されるべきだ——それが1980年代のソフトウェア産業の支配的な考え方だった。Stallmanはこの前提そのものを否定した。

### 1985年10月4日——Free Software Foundation設立

GNU宣言の発表から約7か月後の1985年10月4日、StallmanはFree Software Foundation（FSF）を設立した。501(c)(3)の非営利団体として、マサチューセッツ州ボストンに本拠を置いた。FSFの目的は、GNUプロジェクトの開発を組織的に支援し、フリーソフトウェアの理念を普及させることだった。

FSFは寄付金と、GNUソフトウェアのテープ配布（当時はインターネットが限定的だった）の売上で運営された。「ソフトウェアは無料だが、テープのコピーと郵送にはコストがかかる」——この区別は、Stallmanの「free as in freedom, not as in free beer」の原則を体現していた。ソフトウェアの自由と、物理的な配布コストの回収は矛盾しない。

---

## 3. GNUが生み出したもの——カーネルなきOSの逆説

### ツール群の系譜

GNUプロジェクトは、1984年の開発開始から数年で、UNIXの主要なコンポーネントの自由な実装を次々と生み出した。

**GNU Emacs（1985年3月20日）** ——最初に完成した主要コンポーネント。Stallman自身がMIT時代に開発したオリジナルのEmacs（1976年、TECO上のマクロセット）を、完全に書き直した。バージョン13が最初の公開リリースだ。Emacsは単なるテキストエディタではない。Emacs Lispという組み込みのプログラミング言語を持ち、ユーザがエディタの振る舞いを自由にカスタマイズ・拡張できる。Stallmanの「ユーザがソフトウェアを制御すべきだ」という哲学が、設計レベルで体現されている。

**GCC（1987年3月22日）** ——GNU C Compiler。MITのFTPサイトから最初のリリースが配布された。GCCの登場は決定的だった。自由なCコンパイラが存在することで、他の自由なソフトウェアをコンパイルするための自由な基盤が確立された。商用UNIXに付属するプロプライエタリなコンパイラに依存する必要がなくなったのだ。GCCは同年12月にC++にも対応し、後に多言語対応コンパイラ群「GNU Compiler Collection」に発展した。

1997年、GCCの開発モデルをめぐる不満からEGCS（Experimental/Enhanced GNU Compiler System）がフォークされ、1999年4月にFSFがEGCSをGCCの公式後継として承認した。この出来事は、フリーソフトウェアプロジェクトにおけるガバナンスの重要性を示す初期の事例だった。

**Bash（1989年6月8日）** ——Bourne Again Shell。Brian Foxが開発した。名前はStephen BourneのBourne shell（sh）にかけたもので、GNUらしいユーモアが込められている。Bashは Bourne shellとの互換性を維持しつつ、C shellやKorn shellの機能を取り込んだ。POSIX準拠のシェルとして、事実上のLinux標準シェルとなった。

**GNU coreutils** ——`ls`、`cat`、`cp`、`mv`、`rm`、`grep`、`sort`、`uniq`、`wc`、`cut`、`paste`、`tr`、`head`、`tail`——UNIXの日常的な操作を支えるコマンド群だ。これらは個別に開発され、後に `fileutils`、`textutils`、`shellutils` の三つのパッケージに整理され、2003年にGNU coreutilsとして統合された。

**GDB** ——GNU Debugger。プログラムのデバッグに不可欠なツールで、ブレークポイントの設定、ステップ実行、変数の検査など、開発者が必要とする機能を自由なソフトウェアとして提供した。

### 「カーネルなきOS」の逆説

1990年までに、GNUプロジェクトはOSの上位層——コンパイラ、エディタ、シェル、デバッガ、コアユーティリティ、Cライブラリ（glibc）——をほぼ完成させていた。残っていたのはカーネルだ。

GNUの公式カーネルとして開発が始まったのがGNU Hurdだ。1986年に最初のカーネル試作（TRIXベース）が頓挫した後、1987年にStallmanはカーネギーメロン大学で開発されたMachマイクロカーネルの使用を提案した。だがCMUがMachを適切なライセンスで公開するかどうかの不確実性から、実際の開発開始は1990年まで遅れた。

Hurdの設計は野心的だった。Machマイクロカーネルの上に、サーバプロセスの集合体としてOSの機能を実装する。ファイルシステム、ネットワーキング、プロセス管理——これらを独立したサーバとして分離し、柔軟性とモジュール性を最大化する。第2回で見たMulticsの野心に通じるものがある。

だがこの野心が、Hurdの完成を遠ざけた。マイクロカーネルアーキテクチャの複雑さ——プロセス間通信のオーバーヘッド、デバッグの困難さ、開発者の確保——がHurdの進捗を阻んだ。

そこに1991年、フィンランドの大学生Linus TorvaldsがLinuxカーネルを公開した。モノリシックカーネルという「保守的な」設計を採用し、実用的な品質に急速に到達した。GNUのユーザランドツール群とLinuxカーネルの組み合わせ——これが「GNU/Linux」だ（この名称をめぐる論争については後述する）。

ここに歴史の皮肉がある。GNUプロジェクトはカーネル以外のすべてを用意した。Linuxカーネルは、GNUのツール群なしには実用的なOSになり得なかった。GCCがなければLinuxカーネルをコンパイルできない。glibcがなければユーザランドプログラムが動かない。Bash がなければシェルが使えない。coreutilsがなければ `ls` すら打てない。

だが世間はこのOSを「Linux」と呼んだ。GNUの貢献は、見えない基盤として埋もれた。

```
GNU/LinuxのOS構造:

  ┌─────────────────────────────────────────┐
  │          ユーザアプリケーション          │
  ├─────────────────────────────────────────┤
  │  GNU ユーザランド                       │
  │  ┌─────────┐ ┌─────────┐ ┌───────────┐ │
  │  │ Bash    │ │ GCC     │ │ coreutils │ │
  │  │ (1989)  │ │ (1987)  │ │ (ls,cat.. │ │
  │  │         │ │         │ │  grep,..) │ │
  │  ├─────────┤ ├─────────┤ ├───────────┤ │
  │  │ Emacs   │ │ GDB     │ │ glibc     │ │
  │  │ (1985)  │ │         │ │           │ │
  │  └─────────┘ └─────────┘ └───────────┘ │
  ├─────────────────────────────────────────┤
  │            Linux カーネル (1991)         │
  │          Linus Torvalds + コミュニティ    │
  ├─────────────────────────────────────────┤
  │              ハードウェア                │
  └─────────────────────────────────────────┘

  → GNUがユーザランドのほぼ全てを提供
  → LinuxカーネルがGNUの「欠けたピース」を埋めた
  → GCCなしにはLinuxカーネル自体がコンパイルできない
```

Stallmanはこの状況に異を唱え、「GNU/Linux」と呼ぶことを求めた。1994年頃から私的な依頼を始め、1996年にはEmacs 19.31のAutoconfシステムでターゲット名を「linux」から「lignux」に変更した（すぐに「linux-gnu」に変更）。1997年のエッセイ「Linux and the GNU System」で正式にGNU/Linuxの名称を提唱した。

Debianは「Debian GNU/Linux」を公式名称として採用している。だが多数派は単に「Linux」と呼び続けている。この論争は技術的な問題ではない。思想の問題だ。GNUプロジェクトの貢献を名称に反映させることは、ソフトウェアの自由という理念を可視化することでもある。Stallmanの立場から見れば、「Linux」と呼ぶことは、GNUプロジェクトの思想的貢献を不可視化し、フリーソフトウェア運動の存在を消すことに等しい。

私自身はどちらの名称も使う。技術的な文脈では「Linux」が通じやすく、思想的な文脈では「GNU/Linux」がより正確だ。重要なのは名称ではなく、GNUプロジェクトが果たした役割を理解しているかどうかだ。

---

## 4. GPL——コピーレフトという法的装置

### 著作権法を逆転させる発想

GNUプロジェクトの技術的成果——GCC、Emacs、Bash、coreutils——は、ソフトウェアの自由を実現するための「道具」だ。だが道具だけでは自由は守れない。誰かが自由なソフトウェアを受け取り、改変を加え、その改変版をプロプライエタリな製品として閉じてしまうことが可能だからだ。

Stallmanはこの問題に対して、法的な装置で対抗した。著作権法（copyright）を「逆転」させ、ソフトウェアの自由を法的に保護する仕組み——コピーレフト（copyleft）だ。

「copyleft」という用語はDon Hopkinsが1984年か1985年にStallmanに送った手紙に由来する。copyright（著作権）の意図的な反転（left = rightの反対）だ。著作権法は通常、著作者が複製・配布・改変を「制限する」ために使われる。コピーレフトはこの構造を逆手に取り、著作権法を使って「自由を保存する」。

具体的には、コピーレフトライセンスの下でソフトウェアを受け取った者は、そのソフトウェアを自由に使い、修正し、再配布できる。ただし一つの条件がある。再配布する際には、同じコピーレフトライセンスの条件を維持しなければならない。つまり、自由なソフトウェアから派生した作品も、同じく自由でなければならない。

```
コピーレフトの仕組み:

  従来の著作権:
    著作者 ──著作権──→ 制限（複製禁止、改変禁止、再配布禁止）
    → 自由の「制限」に著作権を使う

  コピーレフト:
    著作者 ──著作権──→ 条件（自由の維持義務）
    → 自由の「保存」に著作権を使う

  パーミッシブライセンス（MIT, BSD）:
    著作者 ──著作権──→ 許諾（ほぼ無条件で利用可能）
    → 派生物がクローズドになる可能性あり

  コピーレフトの連鎖:
    原著作物（GPL） → 派生物A（GPL維持義務） → 派生物B（GPL維持義務）
    → 自由が「伝染」する（批判者は「ウイルス的」と呼ぶ）
```

### Emacs GPLからGPL v1へ

Stallmanが最初に作成したコピーレフトライセンスは、1985年のEmacs General Public Licenseだ。GNU Emacsに適用された、プログラム固有のライセンスだった。このライセンスには、後のGPLの核となる条項——「派生作品はすべての第三者に対して、本ライセンスと同一の条件でライセンスされなければならない」——が既に含まれていた。

だがプログラム固有のライセンスでは、GNUプロジェクトの各ソフトウェアに個別のライセンスが必要になる。Stallmanは汎用的なライセンスの必要性を認識し、約4年の検討を経て、1989年2月25日にGNU General Public License Version 1（GPLv1）をリリースした。

GPLv1は二つの主要な問題に対処した。第一に、ソフトウェア配布者がバイナリのみを配布し、ソースコードを提供しないこと。第二に、配布者が追加の制限を加え、受取人の自由を制限すること。GPLv1はソースコードの提供を義務付け、追加制限の付加を禁止した。

### GPLv2（1991年）——Linuxカーネルのライセンス

1991年6月、GPLv2がリリースされた。GPLv2はGPLv1を洗練し、「自由か死か（Liberty or Death）」条項（第7条）を追加した。この条項は、特許やその他の理由でGPLの条件を満たせない場合、そのソフトウェアの配布自体を禁止するというものだ。部分的に自由を制限した配布を認めるくらいなら、配布そのものを止める。

GPLv2が特に重要なのは、Linus Torvaldsが1992年にLinuxカーネルのライセンスとしてGPLv2を選択したからだ。Torvaldsは当初、独自のライセンス（商用利用を禁止する条件付き）を使っていたが、GPLv2に切り替えた。この選択がLinuxカーネルの爆発的な普及の一因となった。GPLv2がソースコードの公開を保証したことで、企業も個人も安心してLinuxカーネルに貢献できるようになった。自分の貢献が第三者にクローズドにされる心配がないからだ。

ただし、Torvaldsは「GPLv2 only」——GPLv2のみ、「or any later version（またはそれ以降のバージョン）」の条項なし——を選択した。この選択が、後にGPLv3をめぐる論争の伏線となる。

### GPLv3（2007年）——Tivoizationとの闘い

2005年末、FSFはGPLv3の策定作業を開始した。2007年6月29日にGPLv3がリリースされた。

GPLv3で最も論争的だった追加条項は、Tivoization（ティボ化）の禁止だ。TiVo社はデジタルビデオレコーダーにLinuxカーネル（GPLv2）を使用していた。GPLv2の条件に従い、ソースコードも公開していた。だがTiVoのハードウェアは、デジタル署名による検証機構を持っており、ユーザが改変したソフトウェアを実行することを物理的にブロックしていた。

形式的にはGPLv2を遵守している。ソースコードは公開されている。だが実質的には、ユーザは改変版を自分のハードウェアで実行する自由を奪われている。Stallmanはこれを「自由の形骸化」と見なし、GPLv3で明示的に禁止した。

GPLv3のもう一つの重要な変更は、ソフトウェア特許への対応だ。GPLv3は特許ライセンスの暗黙的な許諾を含み、GPL ソフトウェアの配布者が受取人に対して特許権を行使することを禁止した。

Linus TorvaldsはGPLv3に対して反対の立場を明確にした。TorvaldsはTivoizationの禁止条項を過度な制限と見なし、LinuxカーネルをGPLv3に移行しない方針を示した。LinuxカーネルはGPLv2 onlyのままだ。この判断は、Stallmanの思想（ユーザの自由を最大化する）とTorvaldsの実用主義（開発者とユーザの実際のニーズを優先する）の違いを象徴している。

### コピーレフト vs パーミッシブライセンス

GPLに代表されるコピーレフトライセンスの対極にあるのが、パーミッシブライセンスだ。MIT License、BSD License（2条項、3条項）、Apache License 2.0——これらは「ほぼ無条件で利用可能」なライセンスだ。

```
ライセンスの設計思想比較:

┌────────────────┬─────────────────────────────────────────────┐
│ ライセンス     │ 設計思想                                    │
├────────────────┼─────────────────────────────────────────────┤
│ GPL            │ 「自由を保存する」                          │
│ (コピーレフト) │ 派生物も自由であることを義務付ける          │
│                │ ソースコード公開義務あり                    │
│                │ 「自由は保護しなければ失われる」            │
├────────────────┼─────────────────────────────────────────────┤
│ MIT / BSD      │ 「制約を最小化する」                        │
│ (パーミッシブ) │ 派生物のライセンスは自由（クローズド可）    │
│                │ ソースコード公開義務なし                    │
│                │ 「最も自由なライセンスは制約が最も少ない」  │
├────────────────┼─────────────────────────────────────────────┤
│ Apache 2.0     │ 「特許リスクを軽減する」                    │
│ (パーミッシブ) │ MIT/BSDに特許許諾条項を追加                │
│                │ 特許による攻撃的行使を防止                  │
│                │ 2004年リリース、企業利用を意識した設計      │
└────────────────┴─────────────────────────────────────────────┘
```

パーミッシブライセンスの下では、企業がオープンソースのコードを取り込み、独自の拡張を加え、その拡張版をクローズドソースで販売することが許される。Stallmanの視点からは、これは自由の喪失だ。パーミッシブライセンスの支持者からは、これは自由の最大化だ——利用者に最も少ない制約を課すことが、最も「自由」なライセンスだという論理だ。

BSD Licenseの歴史は古い。4条項BSD Licenseは1990年に初出し、UCバークレーのBSD配布物に適用された。MIT Licenseはさらにシンプルで、著作権表示と許諾表示の保持のみを要求する。Apache License 2.0（2004年）はMIT/BSDに特許許諾条項を追加し、企業による利用を意識した設計になっている。

どちらの設計思想が「正しい」かは、立場と文脈による。Stallmanは「コピーレフトなしでは、企業がコミュニティの成果を一方的に搾取できる」と主張する。パーミッシブライセンスの支持者は「コピーレフトの制約がかえってソフトウェアの採用を阻害する」と反論する。この論争に単純な決着はない。

---

## 5. ハンズオン：GNUツールの存在を確認する

あなたが日常的に使っているLinuxコマンドのどれがGNUプロジェクト由来なのかを確認し、BusyBoxの代替実装と比較することで、GNUの貢献を具体的に理解する。

### 環境構築

Docker上にUbuntu 24.04環境を準備する。

```bash
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：GNU coreutilsの特定

まず、あなたが使っている基本コマンドがGNU coreutilsに属することを確認する。

```bash
# coreutilsパッケージの情報を確認する
apt list --installed 2>/dev/null | grep coreutils

# coreutilsに含まれるコマンド一覧を表示する
dpkg -L coreutils | grep '/usr/bin/' | sort
```

出力を見ると、`ls`、`cat`、`cp`、`mv`、`rm`、`mkdir`、`chmod`、`chown`、`head`、`tail`、`sort`、`uniq`、`wc`、`cut`、`paste`、`tr`、`date`、`echo`、`printf`、`env`、`true`、`false`——日常的に使うコマンドの大半がGNU coreutilsであることがわかる。

```bash
# 各コマンドのバージョン情報を確認する
# GNU coreutilsのコマンドは --version でGNUであることを表示する
ls --version 2>&1 | head -1
cat --version 2>&1 | head -1
sort --version 2>&1 | head -1
```

`ls (GNU coreutils) 9.x` のような出力が表示される。これらはすべてGNUプロジェクトの成果物だ。

### 演習2：GNUツール以外のGNUコンポーネント

coreutilsだけではない。Linuxディストリビューションの基盤を成すGNUコンポーネントを確認する。

```bash
# GCC（GNU Compiler Collection）
apt-get update && apt-get install -y gcc
gcc --version | head -1

# Bash（Bourne Again Shell）
bash --version | head -1

# GNU Make
apt-get install -y make
make --version | head -1

# GNU grep（実はGNU grepは別パッケージ）
grep --version | head -1

# GNU sed
sed --version | head -1

# GNU awk (gawk)
apt-get install -y gawk
gawk --version | head -1

# glibc（GNU Cライブラリ）のバージョンを確認
ldd --version | head -1
```

GCC、Bash、Make、grep、sed、gawk、glibc——これらすべてがGNUプロジェクト由来であることが確認できる。あなたのLinux環境は、その基盤のほとんどがGNUで構成されている。

### 演習3：BusyBoxとの比較

BusyBoxはGNU coreutilsの代替実装だ。1995年にBruce Perensが作成し、後にErik Andersenがメンテナを引き継いだ。300以上のコマンドを単一のバイナリに統合し、「The Swiss Army Knife of Embedded Linux」と呼ばれる。Alpine LinuxやDockerの公式イメージの多くがBusyBoxを使っている。

```bash
# 現在のUbuntu環境でのlsのサイズを確認
ls -la /usr/bin/ls
wc -c < /usr/bin/ls

# Alpine Linux（BusyBox環境）でlsのサイズを確認するため、
# 別のターミナルで以下を実行:
# docker run -it --rm alpine:3.20 sh
# ls -la /bin/ls
# → /bin/ls は /bin/busybox へのシンボリックリンク
# wc -c < /bin/busybox
```

GNU coreutilsの`ls`は単体で数百KBのバイナリだ。一方、BusyBoxはすべてのコマンドを含めて約1MBの単一バイナリ。個々のコマンドはBusyBoxバイナリへのシンボリックリンクで、argv[0]（呼び出し名）でどの機能を実行するか決定する。

```bash
# GNU coreutilsとBusyBoxの機能差を確認する
# GNU lsのオプション数
ls --help 2>&1 | grep -c '^ *-'

# GNU sortのオプション数
sort --help 2>&1 | grep -c '^ *-'
```

GNU coreutilsのコマンドはオプションが豊富だ。BusyBoxの同名コマンドは、最も頻繁に使われるオプションのみを実装している。サイズと機能のトレードオフ——これは第4回で見た「一つのことをうまくやれ」の原則とは異なる設計判断だ。BusyBoxは組込み環境という制約の中で、実用性とサイズの最適化を選んだ。

### 演習4：GPLライセンスの確認

GNUツールのライセンスを実際に確認する。

```bash
# coreutilsのライセンスを確認
cat /usr/share/doc/coreutils/copyright | head -30

# Bashのライセンスを確認
cat /usr/share/doc/bash/copyright | head -30

# grepのライセンスを確認
cat /usr/share/doc/grep/copyright | head -30
```

いずれもGPLv3（またはGPLv2+）でライセンスされていることが確認できる。このライセンスが、あなたがこれらのツールのソースコードを読み、修正し、再配布する自由を法的に保証している。

### 演習5：ソースコードへのアクセス

GPLの核心——ソースコードへのアクセス——を体験する。

```bash
# coreutilsのソースコードを取得する
apt-get install -y dpkg-dev
cd /tmp
apt-get source coreutils 2>/dev/null

# ソースコードが展開される
ls coreutils-*/src/ | head -20

# ls コマンドのソースコードを確認する
wc -l coreutils-*/src/ls.c
head -30 coreutils-*/src/ls.c
```

`ls.c` のソースコードが読める。これがGPLの意味だ。あなたが毎日使っている `ls` コマンドの実装を、誰でも読み、理解し、修正できる。Stallmanが1980年にXerox 9700のプリンタドライバで奪われた自由を、GPLは法的に保証している。

---

## 6. まとめと次回予告

### この回の要点

- Richard Stallmanがフリーソフトウェア運動を起こした背景には、1980年代のソフトウェア産業の構造変化があった。1970年代のUNIXコミュニティでは当たり前だったソースコードの共有が、商用化の波の中で失われた。1980年のXerox 9700プリンタ事件はStallmanにとって象徴的な体験であり、ソフトウェアのユーザが自分の使うプログラムを制御する自由の重要性を確信させた

- 1983年9月27日のGNUプロジェクト発表、1985年3月のGNU宣言（Dr. Dobb's Journal）、1985年10月4日のFSF設立——Stallmanは技術だけでなく、思想と組織の両面からフリーソフトウェアの基盤を構築した。「free as in freedom, not as in free beer」——この区別は、Stallmanの運動の核心だ

- GNUプロジェクトはGNU Emacs（1985年）、GCC（1987年）、Bash（1989年）、GDB、coreutils、glibcなど、UNIXのユーザランドのほぼ全体を自由なソフトウェアとして実装した。1990年までに「カーネル以外のすべて」が揃ったが、GNU Hurdは完成しなかった。1991年にLinuxカーネルが登場し、GNUのユーザランドと結合して実用的なOSとなった

- GPL（GNU General Public License）はコピーレフトの法的実装だ。著作権法を「逆転」させ、ソフトウェアの自由を法的に保存する。Emacs GPL（1985年）→ GPLv1（1989年2月25日）→ GPLv2（1991年6月）→ GPLv3（2007年6月29日）と進化し、Tivoization禁止や特許条項を追加した。LinuxカーネルはGPLv2 onlyを維持しており、Stallmanの思想とTorvaldsの実用主義の間に立場の違いがある

- コピーレフト（GPL）とパーミッシブライセンス（MIT、BSD、Apache 2.0）は、ソフトウェアの自由に対する異なるアプローチだ。コピーレフトは「自由を保存する」ために派生物にも同じ自由を義務付ける。パーミッシブライセンスは「制約を最小化する」ことが最大の自由だと考える。どちらが「正しい」かは、立場と文脈による

### 冒頭の問いへの暫定回答

「UNIXの『自由な共有』の文化は、なぜソフトウェアの歴史を変えたのか？」

UNIXのソースコードの自由な共有は、BSDを生み、UNIXの急速な進化を可能にした。その文化が商用化によって失われたとき、Stallmanは単に嘆くのではなく、法的・技術的・組織的な基盤を構築してソフトウェアの自由を「制度化」した。GNUプロジェクトが生み出したツール群は、Linux カーネルと結合して、商用UNIXに代わる自由なOSを実現した。GPLのコピーレフトは、企業がオープンソースに貢献するインセンティブを構造的に作り出した——自分の貢献が第三者にクローズドにされないという保証があるからこそ、企業はGPLソフトウェアに安心して貢献できる。

Stallmanの思想を全面的に支持するかどうかは、あなた自身が判断すべきことだ。だが一つ確かなことがある。Stallmanが1983年に投じた一石がなければ、あなたが今使っているLinux、Docker、Kubernetes、そしてオープンソースのエコシステム全体は、現在の形では存在しなかった。

あなたが書いたコードは、どのライセンスで公開されているだろうか。その選択の意味を、あなたはどこまで理解しているだろうか。

### 次回予告

次回は「Linux誕生——Linus Torvaldsの"just a hobby"」。1991年8月25日、フィンランドの大学生がUsenetのcomp.os.minixに「I'm doing a (free) operating system (just a hobby, won't be big and professional like gnu)」と投稿した。この「趣味のプロジェクト」は、なぜ世界を制覇したのか。GNUプロジェクトがカーネル以外のすべてを用意していたこと、GPLv2がソースコードの公開を保証したこと、そしてインターネットというコラボレーション基盤が存在したこと——Linuxの成功は偶然ではなく、それ以前のすべての歴史が収束した必然だった。

---

## 参考文献

- GNU Project, "Initial Announcement": <https://www.gnu.org/gnu/initial-announcement.en.html>
- GNU Project, "The GNU Manifesto": <https://www.gnu.org/gnu/manifesto.en.html>
- GNU Project, "What is Free Software?": <https://www.gnu.org/philosophy/free-sw.en.html>
- GNU Project, "About the GNU Project": <https://www.gnu.org/gnu/thegnuproject.html>
- GNU Project, "Why Upgrade to GPLv3": <https://www.gnu.org/licenses/rms-why-gplv3.en.html>
- GNU Project, "GNU General Public License, version 1": <https://www.gnu.org/licenses/old-licenses/gpl-1.0.en.html>
- Free Software Foundation, "FSF History": <https://www.fsf.org/history/>
- Open Source Initiative, "History of the Open Source Initiative": <https://opensource.org/about/history-of-the-open-source-initiative>
- Wikipedia, "GNU Manifesto": <https://en.wikipedia.org/wiki/GNU_Manifesto>
- Wikipedia, "Free Software Foundation": <https://en.wikipedia.org/wiki/Free_Software_Foundation>
- Wikipedia, "GNU General Public License": <https://en.wikipedia.org/wiki/GNU_General_Public_License>
- Wikipedia, "GNU Project": <https://en.wikipedia.org/wiki/GNU_Project>
- Wikipedia, "GNU Compiler Collection": <https://en.wikipedia.org/wiki/GNU_Compiler_Collection>
- Wikipedia, "Bash (Unix shell)": <https://en.wikipedia.org/wiki/Bash_(Unix_shell)>
- Wikipedia, "GNU Hurd": <https://en.wikipedia.org/wiki/GNU_Hurd>
- Wikipedia, "Copyleft": <https://en.wikipedia.org/wiki/Copyleft>
- Wikipedia, "Tivoization": <https://en.wikipedia.org/wiki/Tivoization>
- Wikipedia, "GNU/Linux naming controversy": <https://en.wikipedia.org/wiki/GNU/Linux_naming_controversy>
- Wikipedia, "The Cathedral and the Bazaar": <https://en.wikipedia.org/wiki/The_Cathedral_and_the_Bazaar>
- Wikipedia, "Open Source Initiative": <https://en.wikipedia.org/wiki/Open_Source_Initiative>
- Wikipedia, "BusyBox": <https://en.wikipedia.org/wiki/BusyBox>
- Wikipedia, "Richard Stallman": <https://en.wikipedia.org/wiki/Richard_Stallman>
- Sam Williams, "Free as in Freedom: Richard Stallman's Crusade for Free Software", O'Reilly Media, 2002: <https://www.oreilly.com/openbook/freedom/>
- Eric S. Raymond, "The Cathedral and the Bazaar", 1997: <http://www.linux-kongress.org/1997/raymond.html>
