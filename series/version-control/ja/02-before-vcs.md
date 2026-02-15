# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第2回：すべてはcp -rから始まった——バージョン管理以前の世界

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- バージョン管理ツールが存在しなかった時代のソースコード管理の実態
- パンチカードからファイルシステムへ——「コードが物理的なモノだった時代」の意味
- diffコマンドの誕生とLCSアルゴリズムの原理
- patchコマンドが変えたソフトウェア配布の文化
- diff/patchの限界——なぜこれだけでは「バージョン管理」にならないのか

---

## 1. httpd.conf.bak の思い出

前回、私はgitを使わずにcp、diff、patchだけで「バージョン管理もどき」を体験してもらった。あの作業を100回繰り返す覚悟があるか、と問うた。答えは明白だろう。

だが、今回はさらに時間を巻き戻す。

2000年代前半、私はあるWebシステムの運用を担当していた。Apache、PHP、MySQL——いわゆるLAMP環境だ。当時の私にとって「設定ファイルの管理」とは、こういうことだった。

```
httpd.conf
httpd.conf.bak
httpd.conf.20040315
httpd.conf.20040315.bak
httpd.conf.old
httpd.conf.new
httpd.conf.working
```

笑ってほしい。だが、笑いながらも既視感を覚える人は少なくないはずだ。

問題は、この7つのファイルのうち、どれが「本当に動いていた設定」なのか、3ヶ月後にはもう誰にもわからなくなることだった。`.bak` は何のバックアップなのか。`.old` と `.20040315` のどちらが古いのか。`.working` は本当にworkingなのか。

あるとき、本番サーバの設定変更に失敗して、深夜にサービスが停止した。原因を調べると、`httpd.conf.bak` だと思って戻したファイルが、実は2週間前のバックアップで、その間に入れた別の変更がすべて巻き戻っていた。

この体験は、私に二つのことを教えた。第一に、ファイル名に日付やラベルを付けるだけの「管理」は、変更が蓄積するにつれて破綻する。第二に、破綻してから気づいても遅い。

tarballでのバックアップも試した。`tar czf project_20040401.tar.gz /etc/httpd/` のように、プロジェクト全体を定期的にアーカイブする。これは個別ファイルの `.bak` よりはましだった。だが、「何が変わったか」を知るためには、tarballを展開してdiffを取る必要があった。そしてtarballは増え続けた。

これが、バージョン管理ツールが存在しない世界の日常だった。正確に言えば、2004年の時点で CVS も Subversion も存在していた。私が知らなかっただけだ。知っていれば使っていた。知る機会がなかった——それだけのことだが、「それだけのこと」が生む損失は、経験してみなければわからない。

ここで一つ、時間のスケールを大きく変えてみたい。私のhttpd.conf.bakは2004年の話だ。では、1960年代のプログラマは、どうやってソースコードを管理していたのか。そもそも「ファイル」という概念すら自明ではなかった時代に。

---

## 2. ソースコードが「モノ」だった時代

### パンチカードの世界（1950-60年代）

2020年代のエンジニアにとって、ソースコードはテキストファイルだ。エディタで開き、編集し、保存する。ファイルはディスク上のバイト列であり、コピーは瞬時に完了する。これが当たり前すぎて、疑問にすら思わない。

だが、1950年代から1960年代にかけて、ソースコードは物理的な「モノ」だった。パンチカード——80列12行の厚紙に穴を開けてデータを記録する媒体——が、プログラムの実体だった。

1枚のパンチカードには1行分のコードが記録できる。100行のプログラムは100枚のカードの束になる。1,000行なら1,000枚。カードの束を順序通りに保ち、カードリーダーに正しい順序で投入することが、プログラムを「実行する」ことの物理的な前提だった。

この世界で「バージョン管理」とは何を意味するか。コピーを取るとは、カードデッキを物理的に複製することだ。デュプリケータという装置を使い、1枚ずつカードを複写する。時間もコストもかかる。「気軽にバックアップ」などという発想は生まれようがない。

Fred Brooksは、IBM System/360のプロジェクトマネージャを務めた経験をもとに、1975年に "The Mythical Man-Month" を著した。OS/360の開発は1963年から1966年にかけて行われ、ピーク時には約1,000人の開発者が参加し、プロジェクト全体で5,000人年の工数が投入された。

Brooksがこの本で描いた「ソフトウェアの複雑性」の問題は、今読んでも色褪せない。だが、当時のソースコード管理が具体的にどう行われていたかを想像してみてほしい。1,000人の開発者が、パンチカードの束として存在するソースコードを共有し、変更し、統合する。変更の追跡も、並行作業の調整も、すべて人間の手作業と紙の記録に頼るしかなかった。

バージョン管理の必要性は、ソフトウェアの規模が人間の記憶と手作業を超えた瞬間から存在していた。ツールが追いついていなかっただけだ。

### ファイルシステムの誕生——Multicsの遺産（1964年-）

パンチカードの世界からファイルの世界への転換点を示すプロジェクトがある。Multics（Multiplexed Information and Computing Service）だ。

1964年、MITのProject MAC（Fernando Corbato主導）、GE（General Electric）、Bell Labsの三者共同でMulticsプロジェクトが開始された。Multicsの野心は大きかった。タイムシェアリングOS——複数のユーザーが同時に一台のコンピュータを使える仕組み——を、当時の技術で実現しようとした。

Multicsが後のコンピューティングに残した最大の遺産の一つは、**階層的ファイルシステム**だ。ディレクトリの中にディレクトリを作れる。ファイルを名前で管理できる。今のファイルシステムの原型がここにある。

Ken Thompsonは後に、「Multicsから取り入れたのは階層的ファイルシステムとシェルだ」と述べている。Multicsからの直接的な影響を明言した証言だ。

しかし、Multicsプロジェクトは遅延を重ねた。Bell Labsは1969年に離脱する。GEは1970年にコンピュータ事業をHoneywellに売却した。Multicsそのものは最終的に完成し、数十年にわたって稼働したが、当初の壮大なビジョンからは後退した形だった。

重要なのは、Bell Labsを離脱したメンバーの中に、Ken ThompsonとDennis Ritchieがいたことだ。彼らは、Multicsでの経験をもとに、もっと小さく、もっとシンプルなシステムを作ろうとした。それがUNIXだ。

### UNIXの誕生——9KBのメモリで始まった革命（1969年-）

1969年、Ken ThompsonはBell LabsにあったPDP-7上で、UNIXの原型を書き始めた。

PDP-7の標準メモリは4Kワード——バイトに換算すると約9KBだ。2020年代のスマートフォンが数GBのメモリを搭載していることを考えると、その制約の厳しさは想像を絶する。

Thompsonの動機は、ファイルシステムの実験だった。ファイルの「名前」と「データ」を分離するというアイデア——ディレクトリがファイルの名前と場所を管理し、実際のデータは別の場所に格納される——を試したかった。このアイデアはMulticsから受け継いだものだが、Multicsの複雑さを削ぎ落とし、最小限の形で実装した。

1971年、UNIXはPDP-11/20に移植された。PDP-11/20のメモリは24KB。そのうち12KBをOSが使った。残りの12KBでユーザプログラムが動く。

この極度に制約された環境が、UNIXの設計哲学を形作った。「一つのことをうまくやる小さなプログラムを、パイプで組み合わせる」。この哲学は、メモリもディスクも潤沢にある現代のコンピュータでは「美しい設計思想」として語られるが、当時は美学ではなく必然だった。大きなプログラムを書く余裕がなかったから、小さなプログラムを組み合わせるしかなかったのだ。

そして、この初期UNIXには、バージョン管理ツールは存在しなかった。ソースコードは単なるファイルとしてファイルシステム上に置かれ、管理は開発者の記憶と規律に委ねられていた。PDP-7版UNIXのソースコードはBell Labs外に公開されず、後年になってオリジナルのリスティング（紙の印刷物）から再構成されるまで、事実上失われていた。

バージョン管理がなかった時代のソースコードは、こうして消えていく可能性と常に隣り合わせだった。

### diff の誕生——「違い」を見つける機械（1974年）

UNIXの世界に、やがて一つの重要なツールが生まれる。

1970年代中盤、Bell LabsのDouglas McIlroyとJames W. Huntは、二つのテキストファイルの差分を自動的に検出するプログラムを開発した。`diff` である。

McIlroyは、UNIXの歴史において特別な位置を占める人物だ。彼はUNIXパイプ——あるプログラムの出力を別のプログラムの入力として渡す仕組み——を発明した。「小さなプログラムを組み合わせる」というUNIXの哲学は、McIlroyのパイプによって実装上の裏付けを得た。そのMcIlroyが、diffを開発したのは自然なことだった。「二つのファイルの違いを見つける」という、一つのことをうまくやるプログラムだ。

Huntが初期のプロトタイプを開発し、McIlroyが最終版を完成させた。彼らのアルゴリズムは1976年にBell Labs Computing Science Technical Report #41として発表された。diffがUnixに同梱されたのは1974年のUnix第5版からだ。論文の発表（1976年）より実装が先行していたことになる。

前回も触れたが、diffは50年後の今でもソフトウェア開発の基盤として生き続けている。gitの `git diff` が表示する出力は、このdiffの直系の子孫だ。だが前回は「diffが存在する」という事実だけを伝えた。今回は、diffが内部で何をしているのかに踏み込む。

### patch の誕生——「違い」を適用する革命（1985年）

diffの誕生から約10年後、もう一つの革命が起きる。

1985年5月24日、Larry WallがUSENETのmod.sources（後のcomp.sources.unix）にpatchコマンドのバージョン1.3を投稿した。Wallは当時、NASAジェット推進研究所（JPL）で働いていたプログラマであり、後にプログラミング言語Perlの作者となる人物だ。

diffには、1970年代から `ed` スクリプト形式で差分を出力する機能があった。だが、context diff形式——変更箇所の前後の文脈を含む差分——を受け取って、元のファイルに変更を適用するプログラムは存在しなかった。Wallは、context diff形式のパッチがベースファイルにわずかな変更が加わっていても正しく適用できる利点に気づき、patchを作った。

なぜこれが「革命」だったのか。1985年当時、ソフトウェアの配布手段は限られていた。USENETは1979年にTom TruscottとJim Ellis（Duke University）によって構想され、1980年に公開されたネットワークで、UUCPをトランスポートプロトコルとして使う、いわば「貧者のARPANET」だった。帯域は極めて限られていた。

この環境で、ソフトウェアの新バージョンを配布するとき、ソースコード全体を再配布するのは現実的ではなかった。だが、diff + patchの組み合わせがあれば、変更された部分——差分——だけを配布すればよい。100KBのソースコードのうち、変更が1KBなら、1KBだけ送ればよい。これは帯域が限られた時代において決定的な利点だった。

patchは、分散型のソフトウェア開発モデル——後にオープンソースと呼ばれるようになるもの——を先取りし、促進した。「誰かがソフトウェアを公開し、別の誰かが修正を差分として送り返す」というワークフローは、patchなしには成立しなかった。

### tarball の文化（1979年-）

diff/patchと並んで、もう一つ言及すべきツールがある。`tar`だ。

tarは1979年1月、Version 7 AT&T UNIXで登場した。名前は "tape archive" の略で、元々は磁気テープへのデータ書き込み用に設計された。ファイルやディレクトリ構造をひとまとめにしてアーカイブする機能を持つ。

tar アーカイブは俗に「tarball」と呼ばれるようになった。語源は実世界のタールボール——タールの塊で、周囲のあらゆるものがくっつく——にちなむ。ソースファイル、ビルドスクリプト、ドキュメント、設定ファイルをひとまとめにして配布する形式として、tarballは1980年代後半からGNUプロジェクトをはじめとするOSSの標準的な配布形式となった。POSIX.1-1988で標準化され、2001年にPOSIX.1-2001として改訂されている。

diff/patchがソフトウェアの「変更の配布」を可能にし、tarballがソフトウェアの「全体の配布」を可能にした。この二つの組み合わせが、1980年代から1990年代のOSS配布の基盤を形成した。

私が1990年代後半にSlackwareをインストールしたとき、パッケージの中身はtarballだった。設定ファイルの変更をメーリングリストで共有するとき、patchを添付した。これらのツールは、当時の日常の一部だった。

---

## 3. diffの内部——LCSアルゴリズムの世界

ここからは、diffが内部で何をしているのかを掘り下げる。前回はdiffの「使い方」を見た。今回は「仕組み」を見る。

### 二つのファイルの「違い」を見つけるとは、何を意味するか

二つのテキストファイルA、Bがあるとする。diffは、AをBに変換するための「最小の操作列」を求める。操作は「行の追加」と「行の削除」の二種類だ（「変更」は「削除してから追加」として表現される）。

これは一見単純に聞こえるが、組み合わせの数を考えると、計算量は爆発的に増大する。100行のファイルAを105行のファイルBに変換する方法は、膨大な数が考えられる。その中から「最小の操作列」を見つけるのが、diffアルゴリズムの仕事だ。

### 最長共通部分列（LCS）という発想

この問題を解く鍵が、**LCS（Longest Common Subsequence、最長共通部分列）** という概念だ。

二つの列（ここではファイルの行の列）から、元の順序を保ったまま取り出せる最長の共通部分を見つける。LCSに含まれない行が「変更された行」ということになる。

具体例で考えよう。

```
ファイルA:          ファイルB:
1: #include         1: #include
2: int main() {     2: int main() {
3:   printf("A");   3:   int x = 1;
4:   return 0;      4:   printf("B");
5: }                5:   return 0;
                    6: }
```

この二つのファイルのLCSは以下の4行だ。

```
#include
int main() {
  return 0;
}
```

LCSに含まれない行がdiffの出力となる。ファイルAの `printf("A");` が削除され、ファイルBの `int x = 1;` と `printf("B");` が追加された——これがdiffの結論だ。

### Hunt-McIlroyアルゴリズム（1976年）

Hunt と McIlroy が1976年のCSTR #41で発表したアルゴリズムは、このLCS問題を効率的に解く方法を提供した。基本的な動的計画法（DP）によるLCS計算はO(NM)の計算量を必要とする（N、Mはそれぞれのファイルの行数）。Hunt-McIlroyアルゴリズムは、典型的な入力に対してこの計算量を大幅に削減する改良を加えた。

Hunt-McIlroyアルゴリズムは、diffコマンドで使われた最初の非ヒューリスティックな（つまり、常に最適解を求める）アルゴリズムの一つであり、LCSに基づく差分検出アルゴリズムの系譜の出発点となった。

### Myersのアルゴリズム（1986年）——gitの心臓部

Hunt-McIlroyから10年後、もう一つの重要なアルゴリズムが登場する。

1986年、Eugene W. Myersが "An O(ND) Difference Algorithm and Its Variations" をAlgorithmica誌に発表した。Myersは、LCS問題と「最短編集スクリプト」問題が数学的に等価であることを証明し、「編集グラフ」上の最短経路探索として問題を再定式化した。

Myersのアルゴリズムの計算量はO(ND)だ。ここでNは二つのファイルのサイズの合計、Dは最小編集距離（差分の大きさ）を表す。この計算量の意味を理解してほしい。

Dが小さいとき——つまり、二つのファイルの差分が小さいとき——アルゴリズムは非常に高速に動作する。これは現実のソフトウェア開発において極めて重要な特性だ。なぜなら、バージョン管理で比較されるファイルの多くは、直前のバージョンからわずかな変更しか加わっていないからだ。1,000行のファイルの10行を変更したとき、D=10であり、O(N * 10) ≒ O(N) で済む。

Myersのアルゴリズムの実装は、Hunt-Szymanski アルゴリズムに基づくSystem 5のdiff実装と比較して、2倍から4倍高速に動作した。

そして、ここが重要だ。**Myersのアルゴリズムは、gitのデフォルトdiffアルゴリズムである。** あなたが `git diff` を実行するたびに、内部ではMyersのアルゴリズムが動いている。1986年の論文が、2020年代の開発者の日常を支えている。

### diff出力フォーマットの進化

diffアルゴリズムが「どう差分を計算するか」の問題だとすれば、diff出力フォーマットは「差分をどう表現するか」の問題だ。

#### normal diff（1974年-）

最も原始的な形式。`ed` スクリプトに近い形式で、変更のあった行番号と操作（追加・削除・変更）だけを示す。

```
3c3,4
< printf("A");
---
> int x = 1;
> printf("B");
```

`3c3,4` は「元ファイルの3行目を、新ファイルの3〜4行目に変更する」という意味だ。`a`は追加（add）、`d`は削除（delete）、`c`は変更（change）を表す。

#### context diff（1981年-）

1981年7月にリリースされたBerkeley Unix 2.8BSDで、context diff形式（`-c`オプション）と再帰的比較（`-r`オプション）が追加された。

context diffは、変更箇所の前後数行（デフォルトでは3行）の文脈を含める。なぜ文脈が必要なのか。それは、patchを適用するときに、元のファイルが差分取得時と微妙に異なっていても、文脈を手がかりに正しい適用箇所を特定できるようにするためだ。

```
*** file_a.c    2004-03-15 10:00:00
--- file_b.c    2004-03-16 14:30:00
***************
*** 1,5 ****
  #include
  int main() {
!   printf("A");
    return 0;
  }
--- 1,6 ----
  #include
  int main() {
+   int x = 1;
!   printf("B");
    return 0;
  }
```

`!` は変更された行、`+` は追加された行、`-` は削除された行を示す。前後の変更のない行も含まれており、これが「文脈」だ。

#### unified diff（1990年-）

1990年8月、Wayne Davisonがunified diff形式を開発し、USENETのcomp.sources.miscに "unidiff" として投稿した。Richard Stallmanが1ヶ月後にGNUプロジェクトのdiffにこの機能を統合し、1991年1月リリースのGNU diff 1.15でunified diff形式が正式にデビューした。

```diff
--- file_a.c    2004-03-15 10:00:00
+++ file_b.c    2004-03-16 14:30:00
@@ -1,5 +1,6 @@
 #include
 int main() {
-  printf("A");
+  int x = 1;
+  printf("B");
   return 0;
 }
```

unified形式は、context形式より**コンパクト**だ。context形式では変更前と変更後のブロックを別々に表示するため、変更のない行が重複して表示される。unified形式はこの重複を排除し、`-`（削除）と `+`（追加）のプレフィックスで変更の方向を示す。

なぜunified形式が標準になったのか。理由は二つある。第一に、人間の可読性が高い。変更前と変更後が隣り合って表示されるため、何がどう変わったかが直感的に把握できる。第二に、帯域効率が良い。同じ情報をより少ないバイト数で表現できる。帯域が限られたUSENETやメーリングリストの時代には、この差は無視できなかった。

gitが `git diff` で表示する形式は、このunified diff形式だ。1990年にDavisonが設計した形式が、35年後の今もそのまま使われている。

### patchの仕組み——堅牢さの設計

patchコマンドの内部動作にも触れておく。

patchはdiffの出力を受け取り、元のファイルに変更を適用する。ここで重要なのは、patchが必ずしも「完全に一致するファイル」に対して適用されるとは限らないことだ。ベースファイルに別の変更が加わっている可能性がある。

Larry Wallは、この状況に対処するために **fuzz factor** という仕組みを設計した。パッチの行番号が元のファイルとずれている場合、patchは前後数行の範囲で適用箇所を探す。文脈（context）が一致する場所が見つかれば、行番号がずれていてもパッチを適用できる。

適用できなかった部分は `.rej`（reject）ファイルに書き出される。これは「手動で解決してほしい」というpatchからの通知だ。

また、`-R`（reverse）オプションを使えば、パッチを逆方向に適用——つまり変更を取り消す——こともできる。

このfuzz factorの仕組みは、堅牢さの設計として優れている。完全な一致を要求すると、ベースファイルがわずかでも変更されただけでパッチが適用できなくなる。かといって、曖昧すぎるマッチングは誤適用の危険がある。Wallは、context diffの「文脈」をマッチングの根拠とすることで、堅牢性と柔軟性のバランスを取った。

### diff/patchでは解けない問題

diff/patchは強力なツールだ。だが、バージョン管理の三つの本質——前回定義した「変更の記録」「協調の仕組み」「歴史の保存」——のうち、diff/patchが対応できるのは「変更の記録」の一部だけだ。

具体的に、diff/patchでは解けない問題を列挙する。

**ファイルの追加・削除の追跡**。diffは「二つのファイルの差分」を取るツールだ。ファイルが新しく追加された場合や削除された場合、diffだけでは追跡できない。`diff -r`（再帰的diff）を使えばディレクトリ間の比較はできるが、それは差分の「検出」であって「管理」ではない。

**ファイル名の変更（リネーム）の追跡**。`utils.c` を `helpers.c` にリネームした場合、diffにはそれが「utils.cの削除とhelpers.cの新規追加」に見える。リネームという意味のある操作が、二つの無関係な操作に分解されてしまう。

**バイナリファイルの差分**。diffはテキストファイルを前提としている。画像、コンパイル済みバイナリ、データベースファイルなど、テキストでないファイルの差分は意味のある形で計算できない。

**メタデータの管理**。「いつ変更されたか」「誰が変更したか」「なぜ変更したか」——これらのメタデータは、diff/patchの世界には存在しない。ファイルのタイムスタンプは残るが、それはファイルシステムの機能であり、diffの機能ではない。

**並行する変更の自動統合**。前回のハンズオンで `diff3` を使った3-way mergeを体験してもらった。だが、diff3は単一ファイルの統合であり、プロジェクト全体の並行変更を自動的に管理する仕組みではない。

これらの「解けない問題」が、バージョン管理ツールの必要性を定義した。1972年、Bell LabsのMarc RochkindがSCCS（Source Code Control System）を開発し、1982年にはPurdue UniversityのWalter TichyがRCS（Revision Control System）を開発した。彼らが解こうとしたのは、まさにここで列挙した問題群だった。

---

## 4. ハンズオン：diffの内部を体験し、限界を知る

ここからは手を動かす時間だ。

前回のハンズオンではcp、diff、patchの基本操作を体験した。今回は二つのことをする。第一に、diffの内部で何が起きているのかを手作業でトレースする。第二に、diff/patchだけでは管理が破綻するシナリオを実際に体験する。

### 環境の準備

前回と同じ環境で十分だ。

```bash
# Docker環境の場合
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y diffutils patch
```

### 演習1：LCSを手でトレースする

diffが内部で行っているLCS計算を、手作業で追体験する。

以下の二つの短いテキストを考えよう。

```
テキストA: A B C D E F
テキストB: A C B D E G
```

LCSを求めるには、動的計画法（DP）の表を作る。各セルには「その位置までの最長共通部分列の長さ」が入る。

```
    ""  A  C  B  D  E  G
""   0  0  0  0  0  0  0
A    0  1  1  1  1  1  1
B    0  1  1  2  2  2  2
C    0  1  2  2  2  2  2
D    0  1  2  2  3  3  3
E    0  1  2  2  3  4  4
F    0  1  2  2  3  4  4
```

表の読み方は以下の通りだ。

- テキストAの文字とテキストBの文字が一致する場合、左上のセルの値 + 1
- 一致しない場合、左のセルと上のセルの大きい方

右下のセル（4）がLCSの長さだ。表を右下から左上にたどることで、LCS自体を復元できる。

この場合のLCSは `A, D, E` の長さ3......ではない。実は `A, B, D, E` が長さ4のLCSだ。表の右下から逆順にたどると確認できる。

このLCS `A, B, D, E` に含まれない文字が「差分」だ。テキストAでは `C`（3番目）と `F`（6番目）が削除対象、テキストBでは `C`（2番目）と `G`（6番目）が追加対象となる。

実際にコマンドで確認してみよう。

```bash
cd /tmp
# テスト用ファイルを作成
printf 'A\nB\nC\nD\nE\nF\n' > text_a.txt
printf 'A\nC\nB\nD\nE\nG\n' > text_b.txt

# diffを実行
diff text_a.txt text_b.txt
```

diffの出力と、手作業で求めたLCSの結果を照合してほしい。diff が求めた「最小の変更」は、LCSに基づいている。

### 演習2：diff出力フォーマットを比較する

同じファイルの差分を、三つの形式で出力して比較する。

```bash
cd /tmp

# サンプルファイルを作成
cat > original.c << 'EOF'
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
EOF

cat > modified.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <name>\n", argv[0]);
        return 1;
    }
    printf("Hello, %s!\n", argv[1]);
    return 0;
}
EOF

# normal diff
echo "=== Normal Diff ==="
diff original.c modified.c
echo ""

# context diff
echo "=== Context Diff (-c) ==="
diff -c original.c modified.c
echo ""

# unified diff
echo "=== Unified Diff (-u) ==="
diff -u original.c modified.c
```

三つの出力を見比べてほしい。同じ「差分」を表現しているのに、表現形式がまったく異なる。normal形式は最もコンパクトだが人間が読みにくい。context形式は文脈を含むが冗長。unified形式は文脈を含みつつコンパクト。gitが unified形式を採用した理由が、この比較で体感できるはずだ。

### 演習3：tarball + diff/patch 管理が破綻する体験

ここが今回のハンズオンの核心だ。複数のファイルを含むプロジェクトを、tarball + diff/patchだけで管理してみる。

```bash
WORKDIR="${HOME}/vcs-handson-02"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- v1: プロジェクトの初期バージョン ---
mkdir -p project/src project/docs
cat > project/src/main.c << 'EOF'
#include <stdio.h>
#include "utils.h"

int main() {
    greet("World");
    return 0;
}
EOF

cat > project/src/utils.h << 'EOF'
#ifndef UTILS_H
#define UTILS_H
void greet(const char *name);
#endif
EOF

cat > project/src/utils.c << 'EOF'
#include <stdio.h>
#include "utils.h"

void greet(const char *name) {
    printf("Hello, %s!\n", name);
}
EOF

cat > project/docs/README.txt << 'EOF'
My Project v1
A simple greeting program.
EOF

# v1のtarballを作成
tar czf project_v1.tar.gz project/
echo "[v1] tarball作成完了"
```

ここまでは問題ない。次に、変更を加える。

```bash
# --- v2: ファイルの変更 + リネーム + 新規追加 ---

# utils.c を helpers.c にリネーム
mv project/src/utils.c project/src/helpers.c
mv project/src/utils.h project/src/helpers.h

# main.c のincludeを修正
cat > project/src/main.c << 'EOF'
#include <stdio.h>
#include "helpers.h"

int main(int argc, char *argv[]) {
    const char *name = (argc > 1) ? argv[1] : "World";
    greet(name);
    return 0;
}
EOF

# helpers.h を修正
cat > project/src/helpers.h << 'EOF'
#ifndef HELPERS_H
#define HELPERS_H
void greet(const char *name);
void farewell(const char *name);
#endif
EOF

# helpers.c を修正
cat > project/src/helpers.c << 'EOF'
#include <stdio.h>
#include "helpers.h"

void greet(const char *name) {
    printf("Hello, %s!\n", name);
}

void farewell(const char *name) {
    printf("Goodbye, %s!\n", name);
}
EOF

# 新しいファイルを追加
cat > project/src/config.h << 'EOF'
#ifndef CONFIG_H
#define CONFIG_H
#define VERSION "2.0"
#endif
EOF

# ドキュメントを更新
cat > project/docs/README.txt << 'EOF'
My Project v2
A greeting program with farewell support.
Now accepts command-line arguments.
EOF

# v2のtarballを作成
tar czf project_v2.tar.gz project/
echo "[v2] tarball作成完了"
```

さて、v1とv2の差分を取ってみよう。

```bash
# v1を展開
mkdir -p v1_extracted v2_extracted
cd v1_extracted && tar xzf ../project_v1.tar.gz && cd ..
cd v2_extracted && tar xzf ../project_v2.tar.gz && cd ..

# 再帰的diff
echo "=== v1 -> v2 の差分 ==="
diff -ruN v1_extracted/project/ v2_extracted/project/
```

出力を見てほしい。diffは `utils.c` が削除され `helpers.c` が追加されたと報告する。人間には「リネーム」だとわかるが、diffにはわからない。ファイルの内容がほぼ同じであっても、diffはそれを「偶然の一致」としか判断できない。

次に、このdiffをパッチとして保存し、適用してみる。

```bash
diff -ruN v1_extracted/project/ v2_extracted/project/ > v1_to_v2.patch

# v1から復元を試みる
cp -r v1_extracted/project/ project_restore/
cd project_restore
patch -p1 < ../v1_to_v2.patch
cd ..
```

パッチは適用できるかもしれない。だが、ここで問いたい。

このパッチファイルから、以下の情報を読み取れるだろうか。

- `utils.c` が `helpers.c` にリネームされたという事実
- この変更が「リファクタリング」の一環であるという意図
- この変更を誰が、いつ行ったかという記録

答えはNoだ。diffの出力には、変更の「内容」はあるが、「意味」はない。ファイル名の変更は検出できない。変更の理由は記録されない。変更者の情報もない。

これが、diff/patchだけでは「バージョン管理」にならない理由だ。

### 演習4：patchのfuzz factorを体験する

最後に、patchのfuzz factorを実際に体験する。

```bash
cd "${WORKDIR}"

# ベースファイル
cat > base.txt << 'EOF'
line 1: header
line 2: introduction
line 3: first paragraph
line 4: second paragraph
line 5: conclusion
line 6: footer
EOF

# 変更版
cat > changed.txt << 'EOF'
line 1: header
line 2: introduction
line 3: first paragraph (revised)
line 4: second paragraph
line 5: conclusion
line 6: footer
EOF

# パッチを作成
diff -u base.txt changed.txt > revision.patch
echo "=== パッチの内容 ==="
cat revision.patch
echo ""

# ベースファイルが少し変わっている場合（行が追加されている）
cat > base_modified.txt << 'EOF'
line 0: new preface
line 1: header
line 2: introduction
line 3: first paragraph
line 4: second paragraph
line 5: conclusion
line 6: footer
EOF

# パッチを適用（行番号がずれている）
echo "=== 修正済みベースにパッチ適用（fuzz動作） ==="
cp base_modified.txt target.txt
patch target.txt < revision.patch
echo ""
echo "=== 適用結果 ==="
cat target.txt
```

patchが「Hunk succeeded with fuzz」のようなメッセージを出す場合、それはfuzz factorが働いて行番号のずれを吸収したことを意味する。この堅牢性が、ベースファイルが厳密に一致しない状況でもパッチを適用可能にしている。

---

## 5. まとめと次回予告

### この回の要点

第一に、バージョン管理ツールが存在しなかった時代、ソースコードはパンチカードという物理的な「モノ」だった。1960年代のOS/360プロジェクトは5,000人年の工数を投入しながら、ソースコードの管理は手作業に頼るしかなかった。ファイルシステムの概念自体が、Multics（1964年-）とUNIX（1969年-）によって初めて確立された。

第二に、diff（1974年、Hunt/McIlroy）とpatch（1985年、Larry Wall）は、ソフトウェア開発のインフラストラクチャを根本から変えた。diffの内部ではLCSアルゴリズムが動作しており、Myersの改良（1986年）はgitのデフォルトdiffアルゴリズムとして今なお使われている。

第三に、diff出力フォーマットは、normal（1974年）→ context（1981年、Berkeley Unix）→ unified（1990年、Wayne Davison）と進化した。unified形式は人間の可読性と帯域効率のバランスに優れ、gitの標準表示形式として採用されている。

第四に、diff/patchは強力だが、ファイルの追加・削除・リネームの追跡、メタデータの管理、並行変更の自動統合は解決できない。この「解決できない問題群」が、バージョン管理ツールの必要性を定義した。

### 冒頭の問いへの暫定回答

バージョン管理ツールがなかった時代、人々はcpとtarとdiffとpatchで「なんとかしていた」。そして「なんとかならなくなった」。

その「なんとかならなくなった瞬間」——ファイルが増え、開発者が増え、変更が並行するようになり、「いつ・誰が・なぜ変えたか」を人間の記憶だけでは追えなくなった瞬間——こそが、バージョン管理ツール誕生の原動力だった。

### 次回予告

次回は、その「なんとかならなくなった瞬間」に最初に応答した人物の話だ。

1972年、Bell LabsのMarc Rochkindは、SCCS（Source Code Control System）を開発した。ファイルの変更履歴を自動的に記録し、ロック方式で同時編集を防ぐ。10年後の1982年には、Purdue UniversityのWalter TichyがRCS（Revision Control System）を発表し、SCCSの設計を改良した。

彼らが「自動化」しようとしたのは何だったのか。そして、何を自動化できて、何を自動化できなかったのか。

**第3回「SCCS/RCS——自動化への第一歩」**

あなたは `git log` で表示されるコミット履歴を、当たり前のものだと思っていないだろうか。その「当たり前」が存在しなかった世界を想像できるだろうか。次回は、その世界から「履歴の自動記録」が生まれる瞬間に立ち会う。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Brooks, F. P., "The Mythical Man-Month: Essays on Software Engineering," Addison-Wesley, 1975.
- Hunt, J. W. and McIlroy, M. D., "An Algorithm for Differential File Comparison," Computing Science Technical Report #41, Bell Labs, July 1976. <https://www.cs.dartmouth.edu/~doug/diff.pdf>
- Myers, E. W., "An O(ND) Difference Algorithm and Its Variations," Algorithmica 1(2), 1986. <http://www.xmailserver.org/diff2.pdf>
- Ritchie, D. M. and Thompson, K., "The UNIX Time-Sharing System," Communications of the ACM 17(7), July 1974.
- Wall, L., "patch version 1.3," posted to mod.sources, May 24, 1985.
- Corbato, F. J. and Vyssotsky, V. A., "Introduction and Overview of the Multics System," AFIPS Conference Proceedings 27, 1965.
- Multicians.org, "Multics History." <https://multicians.org/history.html>
- Salus, P. H., "A Quarter Century of UNIX," Addison-Wesley, 1994.
