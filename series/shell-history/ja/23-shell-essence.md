# 第23回：シェルの本質に立ち返る――対話・自動化・システム接点

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- Thompson shell（1971年）からNushell（2019年-）まで、50年のシェル史を「三つの軸」で俯瞰するフレームワーク
- シェルの本質を構成する三つの軸――（1）対話インタフェース（Interactive）、（2）自動化の糊言語（Scripting/Glue）、（3）システム接点（System Interface）
- 各シェルが三つの軸のどこに位置するか、そのマッピングと設計思想の比較
- 「対話用シェル」「スクリプト用シェル」「CI/CD用シェル」を分けて考えるシェル選定フレームワーク
- 自分のシェル環境を三つの軸で再評価する実践的アプローチ

---

## 1. 導入――24年間の遍歴を振り返る

私がシェルというものに初めて触れたのは、1990年代後半のことだった。

Slackware 3.5をインストールし、黒い画面にカーソルが点滅するのを見た。それがbashだった。当時の私にとって、シェルは「ターミナルに出てくるあれ」以上の何物でもなかった。`ls`と打てばファイルが見え、`cd`と打てばディレクトリを移動できる。それがシェルの全てだと思っていた。

大学のBSD環境でtcshに出会い、コマンドの補完という概念を知った。2000年代前半にはサーバ管理の現場でbashスクリプトを書き、商用UNIXの案件ではkshに触れた。2000年代後半には数百行のbashデプロイスクリプトに苦しみ、「bashの限界」を体感した。2010年代にはDockerとCI/CDの波の中でAlpine LinuxのashやBusyBoxに遭遇し、2019年にはmacOS Catalinaのzsh移行を経験した。そして2020年代の今、zshを対話用に、POSIX shをスクリプト用に使い分けている。

24年間で、私が「これが最適だ」と信じたシェルは何度も変わった。tcshに感動した時期がある。bashに全幅の信頼を置いた時期がある。kshの堅実さに敬意を抱いた時期がある。そして今、zshとPOSIX shの使い分けに落ち着いている。だが、この「落ち着き」すら暫定的なものだと知っている。

この連載を22回にわたって書き続ける中で、一つの問いが繰り返し浮かんできた。

**シェルの「本質」とは何なのか。**

Thompson shellからNushellまで、50年以上の歴史を辿ってきた。各シェルは異なる設計判断を下し、異なる問題を解決しようとしてきた。だが、それらすべてに共通する何かがあるはずだ。シェルが「シェル」であるために不可欠な要素は何か。

この回では、22回分の歴史を三つの軸で整理し直す。対話、自動化、システム接点——この三つの軸が、シェルの本質を構成していると私は考えている。

あなたは自分が使っているシェルを、どの軸で選んだだろうか。あるいは、選んですらいないのだろうか。

---

## 2. 歴史的背景――50年の歴史を三つの軸で俯瞰する

### 三つの軸の定義

この連載を通じて見えてきたシェルの本質は、以下の三つの軸で整理できる。

**第一の軸：対話インタフェース（Interactive）**

人間がコンピュータとリアルタイムにやり取りする窓口としてのシェル。コマンドを打ち、結果を見て、次のコマンドを考える。この営みはThompson shell（1971年）の時代から変わらない。ただし、「対話の質」は劇的に進化してきた。ヒストリ、補完、構文ハイライト、プロンプトのカスタマイズ——これらはすべて「対話の質」を高めるための工夫だ。

**第二の軸：自動化の糊言語（Scripting/Glue）**

複数のプログラムを組み合わせ、人間の手を離れて処理を実行する仕組みとしてのシェル。Bourne shell（1979年）が確立した制御構造——`if`、`for`、`while`、関数——がこの軸の基盤だ。パイプ、リダイレクト、変数展開といった機能が、個々のコマンドを「糊」で繋ぎ合わせ、一つの自動化ワークフローを形成する。

**第三の軸：システム接点（System Interface）**

OSのカーネルと人間（またはプログラム）をつなぐ最初の接点としてのシェル。ファイルシステムへのアクセス、プロセスの生成と管理、環境変数の管理、シグナルの処理——これらはすべてシェルが担う「システム接点」の機能だ。`/bin/sh`としてシステムの起動スクリプトから呼ばれるシェルは、この軸の最も原始的な形態である。

この三つの軸は独立しているように見えるが、実際には相互に絡み合っている。対話用に設計された機能がスクリプトに持ち込まれて混乱を招くこともあれば（cshの悲劇）、システム接点としての軽量性が対話の快適さを犠牲にすることもある（dashの選択）。シェルの歴史は、この三つの軸のバランスを巡る50年の試行錯誤の記録だ。

### 第一世代：原初の統一（1971年-1978年）

Thompson shellは、三つの軸が未分化だった時代のシェルだ。

1971年11月3日にリリースされたUnix V1に搭載されたThompson shellは、Ken Thompsonが書いた単純なコマンドインタプリタだった。I/Oリダイレクション（`<`と`>`）はこの時点で既に存在し、Douglas McIlroyの提案によりパイプが後に追加された。

だが、Thompson shellにはプログラミング言語としての制御構造がなかった。`if`や`for`は外部コマンドとして実装されていた。つまり、第二の軸——自動化の糊言語——はまだ萌芽の段階にあった。第一の軸（対話）と第三の軸（システム接点）は未分化のまま、一つのシェルに同居していた。

1975年のUnix V6の時点で、Thompson shellの限界は明らかになっていた。Programmer's WorkbenchのJohn Masheyが改良を試みたが、根本的な設計の制約を超えることはできなかった。

### 第二世代：対話とスクリプティングの分裂（1979年-1983年）

1979年は、シェルの歴史における最初の大きな分岐点だった。この年、二つのシェルがほぼ同時に世に出た。

Unix V7に搭載されたStephen BourneのBourne shellは、第二の軸——自動化——に大きく振った設計だった。1976年から開発が始まったこのシェルは、`if`/`then`/`fi`、`for`/`do`/`done`、`while`、`case`といった制御構造を組み込み、シェルをプログラミング言語にした。その代償として、Bourne shell自身もBill Joyの指摘のとおり対話性は犠牲にされた。ヒストリもなく、コマンドライン編集もなく、エイリアスもなかった。

一方、Bill JoyがUC Berkeleyで開発したC shell（csh）は、1979年5月に2BSDの一部として公開された。cshは第一の軸——対話——に全力を注いだシェルだった。ヒストリ機構、エイリアス、ジョブ制御、ディレクトリスタック、チルダ記法。これらはすべて、人間がシェルの前に座って対話的に作業することを前提とした機能だ。だが、cshのスクリプティング能力は信頼性に問題があった。Tom Christiansenが後に"Csh Programming Considered Harmful"（1996年）で詳述した通り、cshで複雑なスクリプトを書くことは苦痛だった。

ここに、シェルの歴史における最初の根本的対立が生まれた。**Bourne shellは自動化に、C shellは対話に最適化された。一つのシェルが両方を兼ねることはできなかった。** 第9回で「シェルの二つの文化」として語ったこの分裂は、1979年にその種が蒔かれたのだ。

### 第三世代：統合への最初の試み（1983年-1992年）

分裂を見たDavid Kornは、統合を試みた。

1983年7月14日、USENIXで発表されたKorn shell（ksh）は、Bourne shellのソースコードをベースにしながら、C shellの対話機能——ヒストリ、エイリアス——を取り込み、さらにvi/Emacsスタイルのコマンドライン編集を追加した。Mike Veachがemacsモード、Pat Sullivanがviモードのコードを書いた。

kshは「全部入り」を目指した最初のシェルだった。第一の軸（対話）と第二の軸（自動化）の両方を一つのシェルで提供しようとした。そしてそれは、一定の成功を収めた。商用UNIX環境では、kshは長年にわたってデファクトスタンダードだった。私が2000年代前半に商用UNIXの案件で触れたkshは、Bourne shellの堅実さとcshの対話性の両方を兼ね備えたシェルだった。

ただし、kshはAT&Tのプロプライエタリソフトウェアだった。自由に再配布できないという制約が、kshの普及を大きく制限した。

この時期のもう一つの重要な出来事は、POSIX シェル標準の策定だ。IEEE P1003.2は6年の策定期間を経て、1992年9月17日にIEEE Standards Boardで承認された。この標準は、第三の軸——システム接点——を定義するものだった。POSIX標準は二部構成で、1003.2がシェルスクリプトの可搬性（第二の軸）を定義し、1003.2a（User Portability Extensions）が対話的利用（第一の軸）を定義した。注目すべきは、スクリプティングが「本体」で対話が「拡張」とされたことだ。POSIX標準にとって、シェルの核心は自動化とシステム接点であり、対話は二次的な関心事だった。

### 第四世代：GNUの覇権と最大主義（1989年-2009年）

1989年6月8日、Brian Foxはbashのベータ版（v0.99）をリリースした。GNUプロジェクトのための自由なシェルとして開発されたbashは、Bourne shell互換を基本としつつ、kshの対話機能とcshの一部の機能を取り込んだ。

bashの設計思想は明快だった——「全部やる」。対話もスクリプティングもシステム接点も、一つのシェルで提供する。そしてGPL（当初v2）というライセンスにより、自由に再配布できた。kshが持っていた技術的な統合と、自由ソフトウェアとしての再配布自由度が組み合わさった結果、bashはLinuxディストリビューションのデファクトスタンダードとなった。

翌1990年、Paul FalstadがPrinceton大学の学生としてzshの初版を書いた。名前はPrinceton大学のTA、Zhong Shaoのログイン名"zsh"に由来する。当初はAmiga用のcshサブセットとして構想されたが、kshとtcshの交差点を目指す方向に発展した。zshは「最大主義」のシェルだ。三つの軸のすべてにおいて、可能な限り最高の機能を提供しようとする。

bashが「全部やる」なら、zshは「全部やる、しかも最高に」だ。拡張グロビング、プログラマブル補完、スペル修正、浮動小数点演算——zshは対話でもスクリプティングでも、bashの上を行く機能を次々と実装した。

だが、この時代に二つの重要な「分離」が起きている。

一つは、Debian/Ubuntuによる`/bin/sh`のdashへの変更だ。Ubuntu 6.10（2006年10月）で、システムの`/bin/sh`をbashからdash（Debian Almquist Shell）に切り替えた。理由はパフォーマンスだ。dashはbashより起動・実行が大幅に高速で、OpenOffice.orgのconfigureスクリプトの実行時間が2分半も短縮された。システムのブート速度も改善された。

この決定は、三つの軸の明確な分離を宣言するものだった。対話用のデフォルトログインシェルはbashのまま、システムスクリプト用の`/bin/sh`はdashに——つまり、**第一の軸と第二・第三の軸を、別のシェルで担ってもよい**という判断だ。

もう一つの分離は、2009年のOh My Zshの登場だ。Robby Russellが公開したこのフレームワークは、zshの対話機能——テーマ、プラグイン、エイリアス——を簡単に導入できるようにした。Oh My Zshの成功は、多くのエンジニアにとってシェルが「対話のためのツール」として認識されていることを示していた。Oh My Zshユーザーの多くは、zshのスクリプティング機能や組み込みモジュールに関心を持っていない。テーマとプラグインが動けばそれでよいのだ。

### 第五世代：意図的な破壊と再構築（2005年-現在）

2005年2月13日、Axel Liljencrantzがfishの初版をリリースした。fishは意図的にPOSIXを捨てた。これは第二の軸——スクリプティングの可搬性——を放棄する代わりに、第一の軸——対話——に全力を注ぐ宣言だった。構文ハイライト、高度な自動補完、ウェブベースの設定インタフェース。fishは「人間が対話的に使うこと」以外のすべてを二次的な関心事とした。

fishのPOSIX離脱は過激に見えるが、理に適っている。第9回で語った「シェルの二つの文化」の歴史を振り返れば、対話とスクリプティングの両立がいかに困難かは明らかだ。fishは「両立しない」という現実を受け入れ、対話に特化することを選んだのだ。

2016年8月18日、PowerShellがオープンソース化（MITライセンス）され、Linux・macOS対応が発表された。前回の第22回で語ったように、PowerShellはテキストではなく.NETオブジェクトをパイプラインに流す。これは第二の軸——自動化——のパラダイムそのものを変える試みだった。Jeffrey Snoverが"Monad Manifesto"（2002年）で提起した「prayer-based parsing（祈り駆動パース）」の問題——テキストをパースして正しくパースできたことを祈る、という構造的脆さ——への回答である。

2019年8月23日、Sophia Turner（旧Jonathan Turner）、Yehuda Katz、Andres RobalinoによりNushellが発表された。Rust製のNushellは、PowerShellの構造化データアプローチとUnixのパイプライン哲学を融合させた。テキストでもオブジェクトでもない「テーブル」がパイプラインを流れる。JSON、TOML、YAMLをネイティブに理解する。Nushellは三つの軸すべてを新しい基盤の上で再構築しようとしている。

同年、AppleはmacOS Catalinaでデフォルトシェルをbashからzshに変更した。理由はbash 4.0以降のGPLv3ライセンスを避けるためだ。AppleはGPLv3のコードをOSに含めない方針を採っており、bash 3.2（2007年リリース）で止まっていた。Catalina搭載のzshはバージョン5.7.1（MITライセンス）だった。

この出来事は、第三の軸——システム接点——におけるシェルの選択が、技術的な判断だけでなく、ライセンスという法的・政治的な要因にも左右されることを示した。ユーザーが「選んだ」のではない。Appleが「選んだ」のだ。

Andy ChuのOils（旧Oil Shell）は、bash互換のOSHと新言語YSHの二層構成で、既存のbashスクリプトからの段階的移行を提案する。Qi XiaoのElvishは、Go言語で実装され、構造化データをパイプラインで流しつつ、名前空間やクロージャといったプログラミング言語の機能を備える。

これらの次世代シェルは、それぞれ異なるアプローチで三つの軸のバランスを再定義しようとしている。共通しているのは、50年間の蓄積を踏まえた上で、新しい回答を模索しているということだ。

---

## 3. 技術論――三つの軸で見るシェルのマッピング

### シェルの座標系

50年の歴史を三つの軸で整理すると、各シェルの設計思想がより明確に見えてくる。以下に、主要なシェルを三つの軸上にマッピングする。

```
             対話（Interactive）
                  ▲
                  │
        fish ●    │    ● zsh
                  │         ● tcsh
                  │
        ● csh     │    ● ksh    ● bash
                  │
──────────────────┼──────────────────────▶ 自動化（Scripting）
                  │
        ● Thompson│    ● Bourne shell
                  │
        ● Elvish  │    ● dash/ash   ● POSIX sh
                  │         ● Oils/YSH
                  │
         Nushell ● │   ● PowerShell
                  │
                  ▼
          システム接点（System Interface）
```

この図は厳密な定量的マッピングではなく、各シェルの設計思想の重心を示す概念図だ。いくつかの注目すべきパターンが浮かび上がる。

### パターン1：対話とスクリプティングの対角線

図の左上から右下にかけて、一つの対角線が引ける。cshからfishに至る「対話重視」の系譜と、Bourne shellからdash/POSIXに至る「スクリプティング重視」の系譜だ。

csh（1979年）は対話に全振りし、スクリプティングの信頼性を犠牲にした。fishはcshの精神をさらに推し進め、POSIXとの互換性そのものを破棄した。これは対話の極北である。

一方、Bourne shell（1979年）はスクリプティングに全振りし、対話性を犠牲にした。POSIX標準（1992年）はBourne shellの設計を「契約」として標準化した。dashはその契約を最小限・最高速で履行するシェルだ。これは自動化の極北である。

この対角線の存在は、一つの重要な事実を示している。**対話と自動化は、設計上のトレードオフ関係にある**——少なくとも、従来のシェル設計の枠組みにおいては。

対話に最適な構文と、スクリプティングに最適な構文は、しばしば矛盾する。対話では簡潔さが重要だ。`ls -la`と打つのに3文字以上打ちたくない。エイリアスや省略記法は対話の友だ。だがスクリプトでは、簡潔さよりも明確さと予測可能性が重要だ。エイリアスがスクリプト内で展開されると、環境依存のバグが生まれる。

### パターン2：「全部入り」の誘惑

ksh（1983年）、bash（1989年）、zsh（1990年）は、この対角線の中間地帯を目指した「全部入り」シェルだ。

kshは最初に統合を試みた。Bourne shellのスクリプティング能力とcshの対話機能を一つのシェルに収めた。bash はkshのアプローチをGPLライセンスの下で再実装し、Linuxのデファクトスタンダードとなった。zshはさらに先を行き、三つの軸すべてで最高水準を目指した。

「全部入り」の利点は明白だ。一つのシェルを学べば、対話もスクリプティングもシステム管理もできる。ユーザーは複数のシェルを使い分ける必要がない。

だが、「全部入り」には代償がある。bashのバイナリサイズは1MBを超え、起動時間もdashの数倍かかる。zshは設定ファイル群の複雑さが初心者を遠ざける。そして何より、「全部入り」は「全部が中途半端」になるリスクを常に孕んでいる。bashの対話機能はzshやfishに劣り、bashのスクリプティング構文はPythonやRubyの表現力に遠く及ばない。

これは設計における普遍的なジレンマだ。スイスアーミーナイフは便利だが、専用の包丁やノコギリには及ばない。

### パターン3：システム接点という見落とされがちな軸

三つの軸の中で、最も見落とされがちなのが第三の軸——システム接点——だ。

シェルは、OSのカーネルとユーザー空間をつなぐ最初の接点である。シェルなしには、ファイルを開くことも、プロセスを起動することも、環境変数を設定することもできない。システムのブートプロセスは`/bin/sh`を呼び出す。`init`や`systemd`が起動スクリプトを実行するとき、そこにはシェルがいる。

この軸で最も重要なのは、**軽量性**と**可搬性**だ。システムの起動時に呼ばれるシェルは、高速に起動し、依存関係が最小限でなければならない。dashがDebian/Ubuntuの`/bin/sh`として選ばれた理由はここにある。bashの豊富な機能は、システムスクリプトの実行には不要であり、起動速度という代償の方が大きい。

Alpine Linuxが`/bin/sh`としてBusyBox ashを採用しているのも同じ理由だ。コンテナ環境では、ベースイメージのサイズと起動速度が重要だ。Alpine Linuxのベースイメージは約5MBであり、この小ささを実現するために、bashではなくBusyBox ashが選ばれている。

PowerShell（2006年、オープンソース化は2016年）は、この第三の軸を独自の方法で再定義した。Windows環境において、GUIに依存していたシステム管理を、コマンドラインからのオブジェクト操作に置き換えた。PowerShellにとってのシステム接点は、ファイルシステムやプロセスだけでなく、Active Directory、レジストリ、証明書ストアなど、Windows固有のシステムリソースを含む。

Nushellもまた、システム接点を再考している。`sys`コマンドでシステム情報を構造化データとして取得し、`ps`コマンドの結果をテーブルとしてフィルタリング・ソートする。テキストのパースを介さずに、システムの情報に直接アクセスする。これは「prayer-based parsing」からの解放であると同時に、第三の軸の進化でもある。

### シェル選定のフレームワーク

三つの軸を理解した上で、実践的なシェル選定を考えよう。要点は単純だ。**三つの軸を、一つのシェルで満たす必要はない。**

以下のフレームワークで考えることを提案する。

```
┌─────────────────────────────────────────────────────────────────┐
│                   シェル選定の三層モデル                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Layer 1: 対話用シェル（Interactive Shell）                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ 目的: 日常のターミナル操作                              │   │
│  │ 重視: 補完、ヒストリ、構文ハイライト、カスタマイズ性    │   │
│  │ 候補: zsh, fish, bash, Nushell, Elvish                  │   │
│  │ 選定基準: 自分の手に馴染むか。毎日使って快適か          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Layer 2: スクリプト用シェル（Scripting Shell）                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ 目的: 自動化スクリプト、デプロイ、タスクランナー        │   │
│  │ 重視: POSIX準拠、可搬性、堅牢性、予測可能性            │   │
│  │ 候補: POSIX sh, bash (strict mode), Oils/YSH            │   │
│  │ 選定基準: 他の環境でも同じ結果を再現できるか           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Layer 3: システム/CI用シェル（System/CI Shell）                │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ 目的: システム起動、CI/CDパイプライン、コンテナ         │   │
│  │ 重視: 軽量性、高速起動、最小依存関係                    │   │
│  │ 候補: dash, ash/BusyBox, POSIX sh                       │   │
│  │ 選定基準: 存在しているか、高速か、壊れにくいか         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

この三層を分けて考えることの利点は、各層に最適なツールを選べることだ。

Layer 1でfishを使う人が、Layer 2のスクリプトを`#!/usr/bin/env fish`で書く必要はない。fishの対話性を享受しつつ、スクリプトは`#!/bin/sh`で書けばよい。Layer 1でzshのOh My Zshを満喫しつつ、Layer 3のDockerfileでは`/bin/sh`を使えばよい。

Debian/Ubuntuが2006年に`/bin/sh`をdashに変更したのは、まさにこの三層分離の先駆的実践だった。対話用シェル（bash）とシステム用シェル（dash）を分けることで、システムの起動速度を改善しつつ、ユーザーの対話体験を損なわなかった。

### 各シェルの三軸評価

具体的に、主要なシェルを三つの軸で評価してみよう。

**bash:**

- 対話: ○（GNU Readline、プログラマブル補完、ヒストリ。ただしzshやfishに比べると見劣りする）
- 自動化: ◎（Bourne shell互換、豊富な拡張機能、圧倒的な情報量とコミュニティ）
- システム接点: ○（多くのLinuxディストリビューションで利用可能。ただし起動速度とバイナリサイズはdashに劣る）

**zsh:**

- 対話: ◎（最高水準の補完、グロビング、プロンプト。Oh My Zshのエコシステム）
- 自動化: ◎（bash互換性が高い。独自の拡張機能も強力）
- システム接点: ○（macOSデフォルト。ただしLinux環境ではデフォルトでインストールされていないことが多い）

**fish:**

- 対話: ◎（構文ハイライト、自動サジェスト、ウェブ設定。学習コスト最小）
- 自動化: △（POSIX非互換。fishスクリプトは他環境での実行を保証できない）
- システム接点: ×（`/bin/sh`として使用不可。システムスクリプトには不向き）

**dash/ash:**

- 対話: △（最小限の機能。ヒストリは基本的なもののみ）
- 自動化: ○（POSIX準拠。軽量・高速。ただし拡張機能はない）
- システム接点: ◎（最小バイナリ、最速起動、最小依存関係。`/bin/sh`として最適）

**Nushell:**

- 対話: ○（構造化データ表示、テーブル操作。ただしエコシステムは発展途上）
- 自動化: ○（構造化パイプライン。ただしPOSIX非互換、既存スクリプトの流用不可）
- システム接点: △（`/bin/sh`として使用不可。まだシステムレベルでの採用例は少ない）

**PowerShell:**

- 対話: ○（タブ補完、予測インテリセンス。ただしUnixユーザーには馴染みにくい構文）
- 自動化: ◎（オブジェクトパイプライン、型安全、豊富なcmdlet。Windowsシステム管理に最適）
- システム接点: ◎（Windowsではシステム管理の標準。ただしUnix系OSでのシステム統合は限定的）

### 「最適なシェル」は存在しない

この評価から見えてくるのは、**すべての軸で◎を取るシェルは存在しない**という事実だ。

zshは三つの軸すべてで高い評価を得ているが、システム接点においてはdashに及ばない。bashは三つの軸のすべてで「そこそこ」の評価だが、どの軸でも突出していない。fishは対話で圧倒的だが、自動化とシステム接点では使えない。

これは欠陥ではない。設計上の必然だ。

対話に最適な設計（人間にとっての直感性、簡潔な構文、視覚的フィードバック）と、自動化に最適な設計（予測可能性、可搬性、堅牢なエラー処理）と、システム接点に最適な設計（軽量性、高速起動、最小依存関係）は、しばしば矛盾する。一つのツールですべてを満たそうとすれば、どこかで妥協が生まれる。

だからこそ、三層に分けて考えることに意味がある。

---

## 4. ハンズオン――自分のシェル環境を「三つの軸」で再評価する

この回のハンズオンは、コードを書くものではない。自分のシェル環境を棚卸しし、三つの軸で再評価するワークシートを実行する。

### 演習1：現状把握——自分のシェル環境を調査する

まず、自分が現在使っているシェルの状況を正確に把握しよう。

```bash
#!/bin/sh
# 演習1: 自分のシェル環境の調査

echo "=== 演習1: シェル環境の現状把握 ==="
echo ""

# 1. 現在の対話シェル
echo "--- 対話シェル ---"
echo "現在のシェル (SHELL): $SHELL"
echo "実行中のシェル: $(ps -p $$ -o comm=)"
echo ""

# 2. /etc/shells に登録されたシェル
echo "--- 利用可能なシェル (/etc/shells) ---"
if [ -f /etc/shells ]; then
    cat /etc/shells | grep -v '^#' | grep -v '^$'
else
    echo "/etc/shells が見つかりません"
fi
echo ""

# 3. /bin/sh の実体
echo "--- /bin/sh の実体 ---"
if [ -L /bin/sh ]; then
    echo "/bin/sh -> $(readlink -f /bin/sh)"
else
    echo "/bin/sh はシンボリックリンクではありません"
    file /bin/sh
fi
echo ""

# 4. 各シェルのバージョン
echo "--- インストール済みシェルのバージョン ---"
for shell in bash zsh fish dash ksh; do
    if command -v "$shell" > /dev/null 2>&1; then
        case "$shell" in
            bash) ver=$("$shell" --version 2>/dev/null | head -1) ;;
            zsh)  ver=$("$shell" --version 2>/dev/null) ;;
            fish) ver=$("$shell" --version 2>/dev/null) ;;
            dash) ver="dash (バージョン表示なし)" ;;
            ksh)  ver=$("$shell" --version 2>/dev/null | head -1) ;;
        esac
        echo "  $shell: $ver"
    fi
done
echo ""

# 5. CI/CDやDockerで使っているシェル
echo "--- システム/CI環境 ---"
if [ -f Dockerfile ]; then
    echo "Dockerfile の SHELL 指定:"
    grep -i "^SHELL\|^RUN" Dockerfile | head -5
fi
if [ -f .github/workflows/*.yml ] 2>/dev/null; then
    echo "GitHub Actions の shell 指定:"
    grep "shell:" .github/workflows/*.yml 2>/dev/null | head -5
fi
echo ""
echo "=== 調査完了 ==="
```

このスクリプトを実行すると、自分の環境で「対話用シェル」「システムの`/bin/sh`」「利用可能なシェル」が一覧される。多くの人は、自分の`/bin/sh`が何であるかすら知らないだろう。

### 演習2：三軸評価ワークシート

次に、自分の環境を三つの軸で評価する。以下のワークシートを埋めてほしい。

```bash
#!/bin/sh
# 演習2: 三軸評価ワークシート

echo "=== 演習2: 三軸評価ワークシート ==="
echo ""
echo "以下の質問に答えて、自分のシェル環境を三つの軸で評価してください。"
echo ""

echo "【Layer 1: 対話用シェル】"
echo "  Q1. 普段の対話シェルは何ですか？: $SHELL"
echo "  Q2. そのシェルを選んだ理由は何ですか？"
echo "      a) 最初から入っていた（デフォルト）"
echo "      b) 誰かに勧められた"
echo "      c) 自分で比較検討して選んだ"
echo "      d) 特に意識していない"
echo "  Q3. 以下の対話機能を使っていますか？"
echo "      [ ] コマンド補完（Tab）"
echo "      [ ] ヒストリ検索（Ctrl+R）"
echo "      [ ] 構文ハイライト"
echo "      [ ] 自動サジェスト"
echo "      [ ] カスタムプロンプト"
echo "      [ ] エイリアス/関数"
echo "      [ ] ディレクトリスタック（pushd/popd）"
echo ""

echo "【Layer 2: スクリプト用シェル】"
echo "  Q4. シェルスクリプトのshebangに何を書きますか？"
echo "      a) #!/bin/bash"
echo "      b) #!/bin/sh"
echo "      c) #!/usr/bin/env bash"
echo "      d) その他"
echo "  Q5. スクリプト内で bash 固有の機能（bashism）を意識していますか？"
echo "      a) 意識している（配列、プロセス置換等を避ける）"
echo "      b) 意識していない（bash前提で書く）"
echo "      c) スクリプトはシェル以外の言語で書く"
echo "  Q6. set -euo pipefail を使っていますか？"
echo "      a) 常に使う"
echo "      b) 時々使う"
echo "      c) 知らない / 使わない"
echo ""

echo "【Layer 3: システム/CI用シェル】"
echo "  Q7. CI/CDパイプラインのシェルを意識していますか？"
echo "      a) 意識している（明示的に指定している）"
echo "      b) 意識していない（デフォルトに任せている）"
echo "  Q8. Dockerfileの RUN 命令で使うシェルを意識していますか？"
echo "      a) Alpine系でash/shを意識している"
echo "      b) bash前提で書いている"
echo "      c) Dockerfileを書かない"
echo ""

echo "【評価結果の読み方】"
echo "  - Q2でa/dを選んだ人: シェルを「与えられている」状態"
echo "  - Q2でcを選んだ人: シェルを「選んでいる」状態"
echo "  - Q5でbを選んだ人: Layer 2が Layer 1に依存している"
echo "  - Q7/Q8でbを選んだ人: Layer 3を意識する機会がある"
echo ""
echo "=== ワークシート完了 ==="
```

### 演習3：シェルの使い分けを体験する

最後に、対話用シェルとスクリプト用シェルの違いを実際に体験しよう。

```bash
#!/bin/sh
# 演習3: シェルの使い分け体験

echo "=== 演習3: シェルの使い分け体験 ==="
echo ""

WORKDIR="${HOME}/shell-essence-handson"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# 1. bashism の検出
echo "--- 3-1: bashism の検出 ---"
cat > test_bashism.sh << 'SCRIPT'
#!/bin/sh
# このスクリプトには bashism が含まれている

# bashism 1: 配列
files=(foo bar baz)
echo "${files[0]}"

# bashism 2: [[ ]] 条件式
if [[ "$1" == "hello" ]]; then
    echo "hello"
fi

# bashism 3: プロセス置換
diff <(ls /tmp) <(ls /var)

# bashism 4: {1..5} ブレース展開
for i in {1..5}; do
    echo "$i"
done
SCRIPT

echo "test_bashism.sh を作成しました。"
echo "このスクリプトは #!/bin/sh と宣言しているが、bash固有の機能を使っています。"
echo ""

# dashで実行してエラーを確認
if command -v dash > /dev/null 2>&1; then
    echo "dashで実行した結果:"
    dash test_bashism.sh 2>&1 || true
    echo ""
fi

echo "bashで実行した結果:"
if command -v bash > /dev/null 2>&1; then
    bash test_bashism.sh 2>&1 || true
fi
echo ""
echo "教訓: #!/bin/sh と書いたスクリプトは、dash でも動くように書くべきである。"
echo ""

# 2. POSIX準拠スクリプトの書き方
echo "--- 3-2: POSIX準拠版 ---"
cat > test_posix.sh << 'SCRIPT'
#!/bin/sh
# POSIX準拠版: 上記の bashism を排除

# 配列の代わりにスペース区切り文字列
files="foo bar baz"
echo "$files" | cut -d' ' -f1

# [[ ]] の代わりに [ ]
if [ "$1" = "hello" ]; then
    echo "hello"
fi

# プロセス置換の代わりに一時ファイル
ls /tmp > /tmp/list_tmp.txt
ls /var > /tmp/list_var.txt
diff /tmp/list_tmp.txt /tmp/list_var.txt
rm -f /tmp/list_tmp.txt /tmp/list_var.txt

# ブレース展開の代わりに seq
i=1
while [ "$i" -le 5 ]; do
    echo "$i"
    i=$((i + 1))
done
SCRIPT

echo "test_posix.sh を作成しました。"
echo "このスクリプトは bash でも dash でも動作します。"
echo ""

if command -v dash > /dev/null 2>&1; then
    echo "dashで実行した結果:"
    dash test_posix.sh 2>&1
    echo ""
fi

# 3. 起動速度の比較
echo "--- 3-3: シェルの起動速度比較 ---"
echo "各シェルを1000回起動するテスト（数秒かかります）:"
echo ""

for shell in dash bash zsh; do
    if command -v "$shell" > /dev/null 2>&1; then
        start_time=$(date +%s%N 2>/dev/null || echo "0")
        i=0
        while [ "$i" -lt 1000 ]; do
            "$shell" -c "exit" 2>/dev/null
            i=$((i + 1))
        done
        end_time=$(date +%s%N 2>/dev/null || echo "0")
        if [ "$start_time" != "0" ] && [ "$end_time" != "0" ]; then
            elapsed=$(( (end_time - start_time) / 1000000 ))
            echo "  $shell: ${elapsed}ms (1000回)"
        else
            echo "  $shell: 計測完了（ナノ秒タイマー非対応のため数値表示不可）"
        fi
    fi
done
echo ""
echo "教訓: システムスクリプトで数百回シェルを起動する場合、dashの軽量さが活きる。"
echo ""

# 後片付け
echo "--- 後片付け ---"
echo "作業ディレクトリ: $WORKDIR"
echo "削除するには: rm -rf $WORKDIR"
echo ""
echo "=== 演習完了 ==="
```

この演習で体験してほしいのは、「対話で使うシェル」と「スクリプトで使うシェル」は異なってよい、という感覚だ。zshやfishの対話機能を存分に活用しつつ、スクリプトは`#!/bin/sh`でPOSIX準拠に書く。CI/CDではdashやashの軽量さを活かす。三層を分けて考えることで、各層に最適なツールを選べるようになる。

---

## 5. まとめと次回予告

### シェルの本質は三つの軸にある

この回では、22回分の歴史を三つの軸で整理し直した。

**第一の軸：対話インタフェース。** Thompson shell（1971年）に始まり、cshがヒストリとエイリアスを、tcshがコマンドライン編集を、zshが最大主義の補完を、fishが構文ハイライトと自動サジェストを追加してきた。50年間、人間とコンピュータの対話の質は向上し続けている。

**第二の軸：自動化の糊言語。** Bourne shell（1979年）が制御構造を持ち込み、POSIX（1992年）が標準化し、bashがデファクトとなり、dashが最小・最速を追求した。PowerShell（2006年）がオブジェクトパイプラインで自動化のパラダイムを変え、Nushell（2019年）が構造化データで新たな道を切り開いている。

**第三の軸：システム接点。** `/bin/sh`として起動プロセスから呼ばれ、CI/CDパイプラインを駆動し、コンテナの中で動く。軽量性と可搬性が求められるこの軸は、華やかさはないが、シェルの最も根源的な役割である。

冒頭の問いに戻ろう——シェルの「本質」とは何か。

それは、この三つの軸のすべてだ。シェルとは、人間がコンピュータと対話し（Interactive）、作業を自動化し（Scripting）、システムにアクセスする（System Interface）ための接点である。50年の歴史の中で、各シェルはこの三つの軸のバランスを異なる形で追求してきた。cshは対話に、Bourne shellは自動化に、dashはシステム接点に重心を置いた。bashとzshは三つの軸すべてを一つのシェルで満たそうとした。fishはPOSIXを捨てて対話に特化した。PowerShellはオブジェクトパイプラインで自動化を再定義した。

**ツールは変わっても、対話・自動化・システム接点という三つの本質は変わらない。** Thompson shellの時代も、Nushellの時代も、シェルが担う役割の核心は同じだ。変わるのは、各軸をどのように実装するか、三つの軸のバランスをどのように取るか、という設計判断である。

そして、一つのシェルが三つの軸すべてで最高得点を取る必要はない。三層に分けて考えれば、各層に最適なシェルを選べる。これが、この連載を通じて私が辿り着いた一つの結論だ。

### 次回予告

次回は最終回だ。

22回の歴史と、今回の三軸整理を踏まえた上で、最後の問いに向き合う。シェルは「与えられるもの」なのか、「選ぶもの」なのか。macOS CatalinaがAppleの判断でbashからzshに変わったように、多くの人はシェルを「与えられている」。だが、歴史を知った上で「選ぶ」ことには、決定的な意味がある。

次回のテーマは「bash ありきの世界を疑え――あなたは何を選ぶか」。連載タイトルと同名の最終回で、この連載のすべてを結ぶ。24年間シェルと共に歩んだ私が、最後にあなたに問いかけたいことがある。

---

## 参考文献

- Ken Thompson, "Unix Programmer's Manual", 1st Edition, November 3, 1971
- Wikipedia, "Thompson shell" <https://en.wikipedia.org/wiki/Thompson_shell>
- Stephen R. Bourne, "The UNIX Shell", Bell System Technical Journal, 1978
- Wikipedia, "Bourne shell" <https://en.wikipedia.org/wiki/Bourne_shell>
- Bill Joy, "An Introduction to the C shell", 2BSD, 1979
- Wikipedia, "C shell" <https://en.wikipedia.org/wiki/C_shell>
- Tom Christiansen, "Csh Programming Considered Harmful", 1996
- David Korn, KornShell, USENIX, July 14, 1983
- Wikipedia, "KornShell" <https://en.wikipedia.org/wiki/KornShell>
- IEEE Std 1003.2-1992, "IEEE Standard for Information Technology--Portable Operating System Interfaces (POSIX)--Part 2: Shell and Utilities" <https://ieeexplore.ieee.org/document/6880751/>
- Brian Fox, GNU Bash Beta (v0.99), June 8, 1989
- Wikipedia, "Bash (Unix shell)" <https://en.wikipedia.org/wiki/Bash_(Unix_shell)>
- Paul Falstad, zsh 1.0, 1990
- Wikipedia, "Z shell" <https://en.wikipedia.org/wiki/Z_shell>
- Axel Liljencrantz, fish 1.0, February 13, 2005
- LWN.net, "Fish - The friendly interactive shell" <https://lwn.net/Articles/136518/>
- Ubuntu Wiki, "DashAsBinSh" <https://wiki.ubuntu.com/DashAsBinSh>
- LWN.net, "A tale of two shells: bash or dash" <https://lwn.net/Articles/343924/>
- Jeffrey P. Snover, "Monad Manifesto", August 8, 2002 <https://www.jsnover.com/Docs/MonadManifesto.pdf>
- Sophia Turner, Yehuda Katz, Andres Robalino, "Introducing nushell", August 23, 2019 <https://www.nushell.sh/blog/2019-08-23-introducing-nushell.html>
- Andy Chu, Oils for Unix <https://www.oilshell.org/>
- Qi Xiao, Elvish Shell <https://elv.sh/>
- Apple Support, "Change the default shell in Terminal on Mac" <https://support.apple.com/guide/terminal/change-the-default-shell-trml113/mac>
- The Next Web, "Why does macOS Catalina use Zsh instead of Bash? Licensing" <https://thenextweb.com/news/why-does-macos-catalina-use-zsh-instead-of-bash-licensing>
- Stack Overflow Developer Survey 2024 <https://survey.stackoverflow.co/2024/>
- Doug McIlroy, "Unix Philosophy" <https://en.wikipedia.org/wiki/Unix_philosophy>
