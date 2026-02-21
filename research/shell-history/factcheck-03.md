# ファクトチェック記録：第3回「Thompson shell――まだ"シェル"ではなかった最初のシェル」

## 1. UNIX V1のリリース日とThompson shellの登場

- **結論**: UNIX V1は1971年11月3日にリリースされた。Ken ThompsonとDennis Ritchieが開発。Thompson shellはV1からV6（1975年5月）まで標準のコマンドインタプリタ（/bin/sh）として配布された。元々は1969年夏にDEC PDP-7上でアセンブリ言語により開発が始まり、PDP-11への移植に伴いV1がリリースされた
- **一次ソース**: Computer History Wiki "UNIX First Edition"; Research Unix Wikipedia
- **URL**: <https://gunkies.org/wiki/UNIX_First_Edition>, <https://en.wikipedia.org/wiki/Research_Unix>
- **注意事項**: PDP-7版UNIXは1969-1970年だが、正式な「First Edition」はPDP-11版の1971年11月3日
- **記事での表現**: 「1971年11月3日、UNIX V1がリリースされた。Ken ThompsonとDennis Ritchieによるこのシステムには、最初のUNIXシェル——後にThompson shellと呼ばれるコマンドインタプリタが含まれていた」

## 2. Thompson shellの入出力リダイレクト（V1から存在）

- **結論**: 入出力リダイレクション構文（`<`と`>`）はV1（1971年）から存在していた。Multicsではリダイレクトに開始・終了の別コマンドが必要だったが、UNIXではコマンドライン引数として`<filename`や`>filename`を指定するだけでよかった。これは当時としては画期的に簡潔だった
- **一次ソース**: Thompson shell Wikipedia; Ken Thompson, "The UNIX Command Language" (1976)
- **URL**: <https://en.wikipedia.org/wiki/Thompson_shell>, <https://susam.github.io/tucl/>
- **注意事項**: V1の段階ではリダイレクトのみ。パイプはまだ存在しない
- **記事での表現**: 「Thompson shellは最初のバージョンから入出力リダイレクトを備えていた。`>`と`<`という簡潔な構文は、Multicsの冗長なリダイレクト手順と対照的だった」

## 3. パイプの追加（V3, 1973年）

- **結論**: パイプはDoug McIlroyの提案に基づき、1973年にKen ThompsonがUNIX V3に実装した。McIlroyの証言によれば「one feverish night（熱狂的な一夜）」でThompsonがpipe()システムコール、シェルへのパイプ統合、prやovなどのフィルタ対応を一気に実装した。日付は1973年1月15日とされる。V3では当初別の記法が使われ、V4でThompsonが`|`（パイプ文字）記法を導入してマニュアルの記述が大幅に簡素化された
- **一次ソース**: Doug McIlroy, "A Research UNIX Reader" (1986); Pipeline (Unix) Wikipedia; Bell Labs "Prophetic Petroglyphs"
- **URL**: <https://www.cs.dartmouth.edu/~doug/reader.pdf>, <https://en.wikipedia.org/wiki/Pipeline_(Unix)>, <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/mdmpipe.html>
- **注意事項**: McIlroyのパイプの着想は1964年10月11日の内部メモに遡る（「プログラムをガーデンホースのように繋げられるべきだ」）。V3での記法とV4での`|`記法の変遷を正確に記述する
- **記事での表現**: 「1973年1月15日の夜、Ken Thompsonは『熱狂的な一夜』でpipe()システムコールを実装し、シェルにパイプを統合し、複数のユーティリティをフィルタとして使えるように改修した」

## 4. グロビングが外部コマンド`/etc/glob`だった事実

- **結論**: UNIX V1からV6まで（1971-1975年）、ファイル名のワイルドカード展開（グロビング）はシェル内蔵ではなく、外部コマンド`/etc/glob`に委譲されていた。`/etc/glob`はDennis Ritchieが作成し、`*`（任意の文字列）や`?`（任意の1文字）を含む引数を検出すると、マッチするファイル名のソート済みリストに展開してコマンドを実行した。V7のBourne shellで初めてグロビングがシェル内蔵になった
- **一次ソース**: glob(programming) Wikipedia; OSnews "The history and use of /etc/glob in early Unixes"
- **URL**: <https://en.wikipedia.org/wiki/Glob_(programming)>, <https://www.osnews.com/story/141520/the-history-and-use-of-etc-glob-in-early-unixes/>
- **注意事項**: "glob"は"global"の略で、$PATH全体を検索する意図だったとされる
- **記事での表現**: 「Thompson shellでは、`*`や`?`によるファイル名展開はシェル自身の機能ではなかった。シェルはDennis Ritchieが書いた外部コマンド`/etc/glob`を呼び出し、ワイルドカードの展開を委譲していた」

## 5. if/gotoが外部コマンドとして実装されていた事実

- **結論**: Thompson shellでは`if`と`goto`は外部コマンド（`/bin/if`、`/bin/goto`）として実装されていた。シェル本体には制御構造が組み込まれておらず、これらは別プログラムだった。`/bin/goto`は独特な実装で、スクリプトファイル内の`: LABEL`という行をlseek(2)で探し、ファイルディスクリプタの位置を変更することでシェルの実行位置を移動させた。コメント機能もなく、`:`ビルトインコマンドが引数を無視して成功するだけのもので、プログラマはこれをコメント代わりに使った
- **一次ソース**: Thompson shell Wikipedia; v6sh.org
- **URL**: <https://en.wikipedia.org/wiki/Thompson_shell>, <https://v6sh.org/>
- **注意事項**: この設計は16ビットマシン（PDP-11）のメモリ制約によるものとされる。/bin/exit、/bin/goto、/bin/if、/etc/globがThompson shellの外部補助コマンド群
- **記事での表現**: 「Thompson shellの設計は徹底的にミニマリスティックだった。`if`と`goto`という制御構造でさえ、シェル本体ではなく`/bin/if`と`/bin/goto`という独立した外部コマンドとして実装されていた」

## 6. Mashey shell（PWB shell, 1975年）

- **結論**: John MasheyらがPWB（Programmer's Workbench）UNIXのために開発したシェル。1975年中頃にリリース。Dick Haight、Alan Glasserも貢献。if-then-else-endif、switch、whileなどの制御構造をシェル内部に取り込んだ。1文字に限定された単純な変数を導入（一部の文字は予約済みで、後のV7環境変数の先駆け）。V7（1979年）でBourne shellに置き換えられた。環境変数の仕組みはStephen Bourne、John Mashey、Dennis Ritchieが協力して設計した
- **一次ソース**: PWB shell Wikipedia; in-ulm.de Mashey shell documentation
- **URL**: <https://en.wikipedia.org/wiki/PWB_shell>, <https://www.in-ulm.de/~mascheck/bourne/PWB/>
- **注意事項**: Mashey shellはV6ベースのPWB/UNIXで使用された。Research UNIXの本流ではなくPWBブランチ
- **記事での表現**: 「1975年、John MasheyはPWB UNIXのためにThompson shellを拡張した。制御構造（if-then-else-endif、switch、while）をシェル内部に取り込み、変数を導入した——シェルが『プログラミング言語』に近づく最初の一歩である」

## 7. fork/execモデルとシェルの設計

- **結論**: fork()システムコールは1969-1970年のPDP-7版UNIXでKen Thompsonにより実装された。シェルはカーネルの外部に置かれた通常のユーザプログラムとして設計され、fork()で子プロセスを生成し、exec()で外部コマンドを実行するモデルを採用した。これはMulticsのシェル（カーネルとより密接に統合されていた）とは対照的な設計判断だった。シェルが特権を持たない通常のプログラムであるという設計は、後のすべてのUNIXシェルの基盤となった
- **一次ソース**: Ken Thompson, "The UNIX Command Language" (1976); Dennis Ritchie, "The Evolution of the Unix Time-sharing System" (1979)
- **URL**: <https://susam.github.io/tucl/>, <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/hist.html>
- **注意事項**: fork-execモデルはThompsonが「simple and expedient（単純で好都合）」な方法として設計したもの
- **記事での表現**: 「シェルはカーネルの外に置かれた、特権を持たない通常のユーザプログラムだった。fork()で自分自身を複製し、子プロセスでexec()を呼んで外部コマンドを実行する——この設計は後のすべてのUNIXシェルの基盤となった」

## 8. PDP-7とPDP-11のハードウェア的制約

- **結論**: PDP-7（1965年発売）は18ビットワードマシンで、メモリは最大144Kバイト（8Kワード）。1969年にThompsonがUNIXの原型を書いた。PDP-11（1970年発売）は16ビットマシンで、UNIX V1はPDP-11/20上で稼働した。PDP-11/20のメモリは最大56Kバイト。1973年にUNIX V4がC言語で書き直された
- **一次ソース**: Computer History Wiki "PDP-7 UNIX"; History of Unix Wikipedia
- **URL**: <https://gunkies.org/wiki/PDP-7_UNIX>, <https://en.wikipedia.org/wiki/History_of_Unix>
- **注意事項**: Thompson shellの外部コマンド設計（if/gotoを外部化）は、この限られたメモリでの動作を前提としたもの
- **記事での表現**: 「PDP-11/20の最大56Kバイトというメモリ制約の中で、シェル本体をできる限り小さく保つ必要があった。if/gotoを外部コマンドにした設計判断は、この制約に対する合理的な回答だった」

## 9. Doug McIlroyのパイプ着想（1964年メモ）

- **結論**: 1964年10月11日、Doug McIlroyはBell Labs内部メモの中で「プログラムをガーデンホースのように接続する方法が必要だ」と記した。「データを別の方法で加工する必要が生じたら、別のセグメントをねじ込めばよい」という構想。当時のBell LabsはIBM 7090/7094でバッチ処理が主流だった。McIlroyはUNIX開発チームのマネージャとして、パイプの実装を強く推した
- **一次ソース**: Bell Labs "Prophetic Petroglyphs" (Dennis Ritchie's page); Doug McIlroy oral history, CHM
- **URL**: <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/mdmpipe.html>, <https://www.computerhistory.org/collections/catalog/102740539/>
- **注意事項**: メモの現存する10ページ目に4つの重要項目がまとめられており、パイプの提案はその第1項
- **記事での表現**: 「1964年10月11日、McIlroyはタイプライターで打った内部メモに書いた——『プログラムをガーデンホースのように接続する方法が必要だ』。この着想が実装されるまでに、9年の歳月が必要だった」

## 10. Thompson shellの変数と名前付き変数の不在

- **結論**: Thompson shellは位置パラメータ（$1, $2...）を持っていたが、名前付き変数は持たず、環境変数へのアクセスもなかった。変数が導入されたのはMashey shell（1975年）であり、さらにV7のBourne shell（1979年）で本格的な変数システムが実装された
- **一次ソース**: Thompson shell Wikipedia; v6sh.org
- **URL**: <https://en.wikipedia.org/wiki/Thompson_shell>, <https://v6sh.org/>
- **注意事項**: Thompson shellのクォーティングはBourne shellとは異なる動作をする（シングルクォートの扱いが異なる）
- **記事での表現**: 「Thompson shellには名前付き変数が存在しなかった。$1、$2のような位置パラメータはあったが、`NAME=value`のような変数代入は不可能だった」

## 11. Ken Thompson "The UNIX Command Language" (1976年)

- **結論**: UNIXシェルについて書かれた最初の論文。1976年に"Structured Programming (Infotech state of the art report)"に掲載された。シェルのI/Oリダイレクト、パイプ、コマンド実行モデルについて記述。Thomsonは「ほとんどのUNIXユーザーはログオンするとシェルというプログラムに出会う。シェルの仕事はユーザーが指定したプログラムを実行することだ」と記述
- **一次ソース**: Ken Thompson, "The UNIX Command Language", Structured Programming, Infotech (1976)
- **URL**: <https://susam.github.io/tucl/>, <https://github.com/susam/tucl>
- **注意事項**: GitHub上でThompsonの許可を得てスキャン・転写・再配布されている
- **記事での表現**: 「1976年、Thompson自身がシェルについての最初の論文を書いている。"The UNIX Command Language"と題されたこの論文で、彼はシェルの設計思想を簡潔に記述した」

## 12. UNIX V6のThompson shellソースコード

- **結論**: UNIX V6のThompson shellのソースコード（sh.c）は`/usr/source/s2/sh.c`に格納されていた。TUHS（The Unix Heritage Society）がV6の完全なディストリビューションをホストしており、研究者がオリジナルの実装を調査・コンパイルできる。GitHubにも複数のミラーが存在する。設計は意図的にミニマリスティックで、コメント機能すら`:`ビルトイン（引数を無視して成功するだけ）で代用していた
- **一次ソース**: GitHub golegen/Thompson-Shell; v6sh.org
- **URL**: <https://github.com/golegen/Thompson-Shell>, <https://v6sh.org/>
- **注意事項**: SimHエミュレータでPDP-11をエミュレートし、UNIX V6上でThompson shellを実際に体験できる
- **記事での表現**: 「UNIX V6のThompson shellのソースコードは今もTUHSで公開されている。sh.cというたった1つのCファイルに、世界最初のUNIXシェルの全実装が収められている」
