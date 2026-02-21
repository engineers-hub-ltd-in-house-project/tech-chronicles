# 第12回：ash/dash――POSIX原理主義と単純さの速度

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- Kenneth Almquistが1989年にashを開発した動機――AT&Tライセンス戦争とBSD自由化の文脈
- ashが4.3BSD-Net/2（1991年）で/bin/shとして採用された経緯とその歴史的意味
- Herbert Xuによるdash（Debian Almquist shell）の誕生（1997年移植、2002年命名）
- Debian/Ubuntuが/bin/shをdashに変更した技術的根拠――起動速度の差とブートプロセスへの影響
- BusyBox ashとAlpine Linuxのエコシステム――コンテナ時代の軽量シェル
- dashとbashのバイナリサイズ・起動速度・依存ライブラリの具体的比較
- distrolessイメージに見る「シェルなし」という極北
- 機能を削ぎ落とす設計判断のトレードオフ

---

## 1. 導入――alpineコンテナで/bin/bashが見つからなかった日

Dockerのベースイメージにalpineを選んだのは、合理的な判断だった。

プロジェクトのコンテナイメージを軽量化する必要があった。当時のベースイメージはubuntuで、圧縮状態でも70MB以上あった。デプロイのたびにレジストリからのpullに時間がかかり、CI/CDパイプラインのボトルネックになっていた。同僚が「alpineにすればイメージサイズが10分の1になる」と言った。5MB。確かに魅力的な数字だ。

`FROM alpine:3.x`に書き換え、ビルドを回した。アプリケーション自体は問題なく動いた。だが、デバッグのためにコンテナ内にシェルで入ろうとしたとき、問題が起きた。

```
$ docker exec -it myapp /bin/bash
OCI runtime exec failed: exec failed: unable to start container process:
exec: "/bin/bash": stat /bin/bash: no such file or directory
```

`/bin/bash`が存在しない。Alpine Linuxにはbashがデフォルトで入っていないのだ。

`/bin/sh`ならば存在する。しかし、それはbashではない。BusyBox ash――Kenneth Almquistが1989年に開発したashの系譜を引く、POSIX準拠の最小限シェルだ。

より深刻な問題はデバッグの不便さではなかった。Dockerfileの`RUN`命令やENTRYPOINTスクリプトの中に、bash依存の構文が紛れ込んでいたことだ。`[[ ... ]]`、配列、`source`コマンド。手元のUbuntu環境では`/bin/sh`がbash（あるいはdash経由でも、これらはshebangが`#!/bin/bash`だったから動いていた）だった。Alpine環境ではそれらが全て壊れた。

前回、POSIX shという「契約書」について語った。その契約書を純粋に体現するシェルが存在する。bashが機能を積み上げてきたのとは正反対に、機能を削ぎ落とすことで価値を生み出すシェルだ。

機能を削ぎ落とすことは、技術的にどのような価値を生むのか。この問いに答えるために、ash/dashの歴史と設計思想に踏み込む。

---

## 2. 歴史的背景――BSDの自由を支えた軽量シェル

### AT&Tライセンス戦争とashの誕生

ashの誕生を理解するには、1980年代末のBSD世界が直面していた法的問題を知る必要がある。

1980年代、AT&Tは自社のUNIXコードの知的財産権を積極的に主張し始めた。UCB（University of California, Berkeley）のBSDはAT&T UNIXのコードを含んでおり、自由に再配布することができなかった。BSDの開発者たちは、AT&Tのコードに依存しない「自由な」UNIXを作るという野心的な計画を進めていた。

この文脈で、/bin/shは問題だった。UNIXの心臓部であるシェルが、AT&T由来のBourne shellだったからだ。Bourne shellのソースコードはAT&Tのライセンスに縛られている。BSDを自由に配布するためには、Bourne shellの代替が必要だった。

1989年5月30日、Kenneth Almquistはcomp.sources.unix Usenetニュースグループに、8パートに分かれたソースコードを投稿した。Volume 19, Issue 1。Rich Salzが承認・モデレーションを行ったその投稿のタイトルは"A reimplementation of the System V shell"――System Vシェルの再実装である。

ashはBourne shellのクリーンルーム再実装だった。AT&Tのソースコードを参照せず、公開されたマニュアルと仕様に基づいて書かれた。Almquist自身の説明によれば、ashは「4.2BSD、4.3BSD、System V Release 1-3、System III、そしておそらくVersion 7」で動作する。つまり、当時存在したほぼ全てのUNIX環境で動く、ポータブルなBourne shell互換シェルだった。

重要なのは、ashがパブリックドメインに近い条件で公開されたことだ。AT&Tのライセンスに縛られない、自由に使えるBourne shell互換シェル。これこそがBSDの自由化に必要なピースだった。

### 4.3BSD-Net/2への組み込み

1991年6月、UCBは4.3BSD-Net/2をリリースした。AT&T由来のコードを可能な限り排除した、「ほぼ自由な」BSDリリースだ。このNet/2で、ashはAT&T由来のBourne shellに代わる`/bin/sh`として正式に採用された。

この決断の意味は大きい。UNIXシステムにおいて、`/bin/sh`はあらゆるシステムスクリプトが依存する基盤だ。ブート処理、パッケージ管理、cron——それらすべてが`/bin/sh`を前提として書かれている。その`/bin/sh`をAT&T由来のBourne shellからashに置き換えるということは、システムの根幹を入れ替えるに等しい。

ashの設計がこれを可能にした。ashはBourne shellとの高い互換性を持ちながら、コードは完全に独立していた。既存のシェルスクリプトがそのまま動き、かつAT&Tのライセンスに縛られない。この組み合わせが、BSD自由化の重要な一歩を支えた。

1993年の4.4BSD、1994年の4.4BSD-Lite（AT&Tコードを完全に排除した決定版）でも、ashは引き続き`/bin/sh`であり続けた。4.4BSD-Liteは後のFreeBSD、NetBSD、OpenBSDの源流となったから、ashの血統はBSD世界の隅々にまで行き渡ることになった。

今日に至るまで、FreeBSD、NetBSD、DragonFly BSD、MINIXの`/bin/sh`はashの派生だ。FreeBSD 14ではrootのデフォルトシェルも`/bin/sh`（ash派生）に変更された。ashは30年以上にわたってBSD系OSの基盤であり続けている。

### Herbert Xuとdash（Debian Almquist shell）の誕生

ashのもう一つの重要な系譜は、Linuxの世界で生まれた。

1997年、Herbert XuはNetBSD版のashをDebian Linuxに移植した。Xuは同年にDebianカーネルメンテナとして活動を開始した人物で、後にLinuxカーネルの暗号サブシステムの共同メンテナとしても知られることになる。

Xuの関心はPOSIX準拠とスリムな実装にあった。NetBSD版のashをDebianで動くように移植し、Debianパッケージとして維持する。当初、このパッケージは単に「ash」と呼ばれていた。

2002年9月、バージョン0.4.1のリリースに際して、このパッケージは正式に**dash**——Debian Almquist shellと命名された。Debian固有の拡張と修正が蓄積され、もはやNetBSD版のashとは異なるプロジェクトになっていたからだ。

dashという名前の選択は示唆的だ。Debianの「D」とAlmquistの「ash」を組み合わせた命名だが、dashには「突進する」「素早く動く」という意味もある。意図的かどうかは不明だが、dashの最大の特徴——速度——を暗示する名前になっている。

### Debianの決断：/bin/shをdashに変更する

dashが単なる「代替シェル」から「デフォルトシステムシェル」へと昇格したのは、2006年のことだ。

2006年10月、Ubuntu 6.10（Edgy Eft）がデフォルトの`/bin/sh`をbashからdashに変更した。Ubuntu WikiのDashAsBinShページには、この変更の動機が率直に記されている。

> The major reason to switch the default shell was efficiency. bash is an excellent full-featured shell appropriate for interactive use; indeed, it is still the default login shell. However, it is rather large and slow to start up and operate by comparison with dash.

「切り替えの主な理由は効率性だ。bashは対話的な利用に適した優れた多機能シェルであり、デフォルトのログインシェルであり続ける。しかし、dashに比べて大きく、起動と動作が遅い」——簡潔にして本質的な説明だ。

興味深いのは、Ubuntu 6.10のブート速度改善がUpstart（当時導入された新しいinitシステム）の功績と誤解されがちだった事実だ。Ubuntu Wikiはこの誤解を明確に否定している。Ubuntu 6.10のUpstartは主にSystem V互換モードで動作しており、小さな挙動変更しかなかった。ブート速度の改善の主因は、`/bin/sh`のdash移行だった。

なぜ`/bin/sh`の変更がブート速度に影響するのか。UNIXシステムのブートプロセスでは、大量のシステムスクリプトが`/bin/sh`経由で実行される。SysV initスクリプト、udevルール、各種初期化処理——これらすべてが`#!/bin/sh`で始まるスクリプトだ。一つひとつのスクリプト実行におけるシェルの起動時間の差は小さくとも、数十、数百のスクリプトが実行されるブートプロセス全体では、その差が累積して顕著な効果をもたらす。

Debianは2011年2月リリースのDebian 6（Squeeze）で、公式にdashをデフォルトの`/bin/sh`とした。Ubuntuが先行して移行を実施したことで、bash依存スクリプト（bashisms）の問題が広く認識され、多くのパッケージのスクリプトがPOSIX準拠に修正された。この5年間の「慣らし期間」があったからこそ、Debianの公式移行は比較的スムーズに進んだ。

### BusyBoxとAlpine Linux：コンテナ時代の軽量シェル

ashのもう一つの重要な系譜が、BusyBoxを通じて広がった。

1995年、Bruce PerensはDebianのインストーラー用に、単一の実行ファイルに多数のUNIXコマンドを収めるツールを開発した。BusyBox――「The Swiss Army knife of Embedded Linux」（組み込みLinuxのスイスアーミーナイフ）と呼ばれることになるこのプロジェクトの目的は、単一のフロッピーディスクにブート可能なシステム（レスキューディスク兼インストーラー）を収めることだった。Perensは1996年にこれを「意図した用途において完成」と宣言した。

BusyBoxは300以上のUNIXコマンドを単一の実行ファイルに統合する。`ls`も`grep`も`sed`も`awk`も、すべてひとつのバイナリだ。そしてその中に、ashの実装も含まれている。dashのバージョン0.3.8-5がBusyBoxに組み込まれ、BusyBox ashとして進化した。

2005年、Gentoo開発者のNatanael CopaがAlpine Linuxを発表した。元々は"A Linux Powered Integrated Network Engine"の略称で、VPNやファイアウォール向けの組み込みディストリビューションだった。Alpine Linuxはmusl libc、BusyBox、OpenRCを基盤とし、glibc、GNU Core Utilities、systemdを使わない。この「GNU以外」の選択が、Alpine Linuxの軽量さの源泉だ。

Alpine LinuxのDockerイメージサイズはわずか約5MB。Ubuntuの約188MB、Debianの約114MBと比較すれば、その差は歴然としている。Docker Hubでのpull数は1.35億を超え、Debianの3,500万を大きく上回る。Dockerコンテナの約20%がAlpine Linuxベースだとする推計もある。

Alpine Linuxの`/bin/sh`はBusyBox ash。bashは標準では含まれていない。つまり、Docker Hubで最も人気のあるベースイメージにおいて、`/bin/sh`はbashではないのだ。

---

## 3. 技術論――機能を削ることの設計論

### なぜdashは速いのか

dashがbashより速い理由は、単純に「機能が少ないから」ではない。より正確に言えば、機能の削減がコードパスの短縮、依存ライブラリの削減、バイナリサイズの縮小という連鎖反応を生み、それが起動速度と実行速度の両面で効果を発揮するのだ。

具体的な数値で比較する。環境やバージョンにより変動するが、一般的な傾向は以下の通りだ。

```
指標                dash             bash            比率
──────────────    ──────────       ──────────      ──────
バイナリサイズ    約 120KB         約 1,200KB       1/10
主要な依存        libc のみ        libc + readline  --
                                   + ncurses
起動時間(1回)     約 0.9ms         約 2.8ms         約 1/3
1,000回起動       約 0.9秒         約 2.8秒         約 1/3
メモリ使用量      極小             小               --
```

この差の根本原因は、依存ライブラリの構造にある。

dashが依存するのはlibc（Cの標準ライブラリ）のみだ。対話的な行編集機能を持たないため、readlineライブラリが不要になる。端末制御のためのncurses/terminfoも不要だ。共有ライブラリのロードはプロセス起動時のオーバーヘッドの大きな部分を占める。依存ライブラリが少なければ、それだけ起動が速い。

```
dash の依存関係:
  dash → libc

bash の依存関係:
  bash → libc
       → libreadline → libncurses → libtinfo
       → libdl
```

バイナリサイズの差も起動速度に寄与する。小さなバイナリはディスクI/Oが少なく、ページキャッシュに載りやすい。コールドスタート（初回起動）での差は特に顕著だ。

### 機能と速度のトレードオフ

dashが削ぎ落とした機能を整理する。これらはすべて、bashが「便利」にするために追加した機能だ。

**削ぎ落とされた対話的機能**:

- コマンドライン編集（readline統合）
- プログラマブル補完（bash-completion）
- コマンドヒストリの高度な管理
- プロンプトのカスタマイズ（`\u`, `\h`, `\w`等のエスケープシーケンス）
- ディレクトリスタック（`pushd`/`popd`）

**削ぎ落とされたスクリプティング機能**:

- 配列（インデックス配列、連想配列）
- `[[ ... ]]`拡張条件式
- プロセス置換（`<(...)`, `>(...)`)
- `function`キーワード
- `select`文
- `pipefail`オプション
- `{n..m}`ブレース展開
- `$'...'` ANSI-Cクォーティング（POSIX.1-2024で標準化されたが、dashは未実装）

これらの機能は、対話的な使用やスクリプティングの利便性を大幅に向上させる。だが、それぞれが実装コード（コードパス）を増やし、バイナリサイズを膨らませ、起動時の初期化処理を追加する。dashはこれらをすべて省くことで、POSIX sh準拠の最小限を実現している。

この設計判断は、明確なトレードオフだ。dashは人間が対話的に使うシェルとしては貧弱だ。TAB補完もなく、コマンドライン編集もできない。だがその代わりに、スクリプトの実行エンジンとしては極めて高速で軽量だ。

dashの位置づけは、第9回で論じた「シェルの二つの文化」の帰結として理解できる。対話用シェルとスクリプト用シェルを分離する発想だ。ユーザーはbashやzshを対話的に使い、システムスクリプトの実行にはdashを使う。`/bin/sh`がdashを指し、ログインシェルがbashを指す。この使い分けこそが、Debian/Ubuntuが採用した設計だ。

### initスクリプトからDockerfileまで――起動速度が意味を持つ場面

シェルの起動速度が「些細な差」ではなく「実質的な性能差」になる場面がある。

**SysV initスクリプト**。systemd以前のLinuxブートプロセスでは、`/etc/init.d/`以下の数十のシェルスクリプトが順次実行されていた。各スクリプトは`#!/bin/sh`で始まり、`/bin/sh`が起動される。スクリプトの数を50とすれば、bashとdashの起動時間の差（1回あたり約2ms）が50回で100ms。さらに、各スクリプト内部でサブシェルが起動される場面を考えれば、累積的な差はより大きくなる。

**Docker RUN命令**。Dockerfileの`RUN`命令はshell form（デフォルト）では`/bin/sh -c`経由で実行される。マルチステージビルドの各ステップで`/bin/sh`が起動されるため、ステップ数が多いほどシェルの起動速度が効いてくる。

```dockerfile
# shell form: 内部で /bin/sh -c "..." として実行される
RUN apt-get update && apt-get install -y package

# exec form: シェルを介さず直接実行
RUN ["apt-get", "update"]
```

ここで注目すべきは、Dockerfileにおけるshell formとexec formの違いだ。shell formは`/bin/sh -c`経由で実行されるため、変数展開やパイプが使える。exec formはシェルを介さず直接実行されるため、シェルの機能は使えないが、シグナルハンドリングが正確になる。shell formでは`/bin/sh`がPID 1となり、SIGTERMが子プロセスに正しく伝播しない問題がある。exec formではアプリケーションがPID 1となり、シグナルを直接受信する。

**CI/CDパイプライン**。GitHub ActionsやGitLab CIの`run:`ステップは、通常`/bin/sh`または`/bin/bash`で実行される。ジョブあたり数十のステップが実行されるCI/CDパイプラインでは、各ステップでのシェル起動時間が蓄積する。特にAlpineベースのランナーを使用している場合、`/bin/sh`はBusyBox ashだ。

### dashの設計が体現するUNIX哲学

dashの設計は、UNIX哲学の原点に立ち返るものだ。

Doug McIlroyが定式化したUNIX哲学の一つに、「一つのことをうまくやるプログラムを書け」（Do One Thing and Do It Well）がある。dashはまさにこの原則に従っている。dashが「うまくやる一つのこと」は、POSIXシェル言語の高速な実行だ。対話的な使いやすさは捨てる。拡張機能は捨てる。だが、POSIX準拠のシェルスクリプトを高速に実行することについては、妥協しない。

bashは対極のアプローチだ。対話的機能もスクリプティング機能も、可能な限り取り込む。第10回で論じたKorn shellの「全部入り」思想をさらに推し進めた存在だ。bashは多機能だが、その多機能さの代償として、起動が遅く、バイナリが大きい。

どちらが「正しい」かという問いには意味がない。問われるべきは「どの場面でどちらが適切か」だ。人間が直接触る対話的シェルとしてはbash（あるいはzsh、fish）が適切だ。システムが大量に起動するスクリプト実行エンジンとしてはdashが適切だ。

### distroless：「シェルなし」という極北

dashが「最小限のシェル」を体現するならば、Googleのdistrolessイメージは「シェルなし」という極北を体現する。

distrolessイメージはアプリケーションとそのランタイム依存のみを含み、シェルもパッケージマネージャも意図的に排除する。最小のdistrolessイメージ（`gcr.io/distroless/static-debian12`）はわずか約2MiB。Alpine Linuxの5MBよりもさらに小さい。

シェルを排除するセキュリティ上の理由は明快だ。攻撃者がアプリケーションの脆弱性を突いてリモートコード実行（RCE）を獲得したとしても、シェルがなければターミナルを起動できない。ファイルシステムの探索も、追加ツールのインストールも、通常のポストエクスプロイテーション手法が使えなくなる。

これは「シェルの存在がセキュリティリスクである」という、シェルの歴史において根本的な問い直しだ。Thompson shellからNushellまで、シェルは「人間がコンピュータと対話する手段」として進化してきた。だが、コンテナ環境では、対話そのものが不要な場合がある。アプリケーションが起動し、リクエストを処理し、ログを出力する。人間がシェルでコンテナの中に入る必要がない。そのような環境では、シェルは「不要な攻撃対象面積」でしかない。

もちろん、distrolessにも代償がある。コンテナ内でのデバッグが極端に困難になる。`kubectl exec`でシェルに入れない。ログの確認も、プロセスの状態確認も、外部から行うしかない。debug版のdistrolessイメージには限定的なシェルが含まれるが、それは「シェルなし」の原則からの後退だ。

ashからdashへ、dashからBusyBox ashへ、BusyBox ashからdistroless（シェルなし）へ。「機能を削ぎ落とす」方向の進化は、最終的に「シェルそのものを削ぎ落とす」地点に到達した。この系譜は、シェルの存在意義そのものを問い直す思考実験として興味深い。

---

## 4. ハンズオン――dashの速度を自分の手で計測する

理論だけでは「機能を削ぎ落とすことの価値」は実感できない。実際にdashとbashの速度差を計測し、Alpine Linux（BusyBox ash）でPOSIX準拠スクリプトを実行する体験を通じて、この値を体で理解する。

### 環境構築

Docker環境を前提とする。Ubuntu（bash + dash）とAlpine Linux（BusyBox ash）の両方を使う。

```bash
# Ubuntu環境（bash + dash が両方入っている）
docker run -it ubuntu:24.04 /bin/bash

# Alpine環境（BusyBox ash のみ。bash は入っていない）
docker run -it alpine:3.21 /bin/sh
```

あるいは、本記事に付属する`setup.sh`スクリプトを使えば、演習環境の構築を一括で行える。

```bash
bash setup.sh
```

### 演習1: バイナリサイズの比較

まず、dashとbashの物理的なサイズを確認する。Ubuntu環境で実行する。

```bash
# バイナリサイズの比較（Ubuntu 24.04）
ls -lh /bin/dash /bin/bash

# 典型的な出力:
# -rwxr-xr-x 1 root root 1.4M ... /bin/bash
# -rwxr-xr-x 1 root root 129K ... /bin/dash
```

bashの約1.4MBに対して、dashは約129KB。約10倍の差だ。この差はどこから来るのか。依存ライブラリを確認する。

```bash
# 依存ライブラリの比較
echo "=== dash ==="
ldd /bin/dash

echo "=== bash ==="
ldd /bin/bash
```

dashはlibc（とlinux-vdso、ld-linux）のみに依存する。bashはそれに加えてlibtinfoに依存する（readline機能のため）。この依存関係の差が、起動速度に直結する。

### 演習2: 起動速度のベンチマーク

1,000回のシェル起動にかかる時間を計測する。

```bash
# dash の起動速度
echo "=== dash 1,000回起動 ==="
time for i in $(seq 1 1000); do
    /bin/dash -c 'true'
done

# bash の起動速度
echo "=== bash 1,000回起動 ==="
time for i in $(seq 1 1000); do
    /bin/bash -c 'true'
done
```

典型的な結果では、dashはbashの2〜4倍速い。環境（CPU、ディスク速度、キャッシュ状態）によって数値は変動するが、dashが一貫して速い傾向は変わらない。

この差を「誤差」と感じるかもしれない。1回あたり数ミリ秒の差だ。だが、ブートプロセスで50のスクリプトが実行され、各スクリプト内で10回のサブシェル起動があるとすれば、500回のシェル起動が行われる。CI/CDパイプラインで100ステップのジョブが10個並列実行されれば、1,000回だ。「些細な差」は、システムレベルでは「実質的な差」に変わる。

### 演習3: スクリプト実行速度の比較

単純な起動だけでなく、実際のスクリプト実行でも速度差を確認する。

```bash
# テスト用のPOSIX準拠スクリプトを作成
cat << 'SCRIPT' > /tmp/bench_script.sh
#!/bin/sh
# ファイル処理シミュレーション
count=0
total=0
i=0
while [ "$i" -lt 500 ]; do
    count=$((count + 1))
    total=$((total + i))
    i=$((i + 1))
done
echo "count=$count total=$total"
SCRIPT
chmod +x /tmp/bench_script.sh

# dash での実行
echo "=== dash でスクリプト実行 100回 ==="
time for i in $(seq 1 100); do
    /bin/dash /tmp/bench_script.sh > /dev/null
done

# bash での実行
echo "=== bash でスクリプト実行 100回 ==="
time for i in $(seq 1 100); do
    /bin/bash /tmp/bench_script.sh > /dev/null
done
```

スクリプトの実行時間においても、dashはbashより高速だ。起動のオーバーヘッドだけでなく、シェルインタプリタ自体の実行効率もdashの方が高い。コードパスが短い分、命令キャッシュの効率も良い。

### 演習4: Alpine Linux（BusyBox ash）でのPOSIX準拠スクリプト実行

Alpine Linux環境で、POSIX準拠のスクリプトが正常に動作することを確認する。

```bash
# Alpine Linuxコンテナに入る
docker run -it alpine:3.21 /bin/sh

# /bin/sh の正体を確認
ls -la /bin/sh
# → /bin/sh は busybox へのシンボリックリンク

# BusyBox のバージョンを確認
busybox --help | head -1

# bash が存在しないことを確認
which bash 2>/dev/null || echo "bash is not installed"
```

POSIX準拠のスクリプトを書いて実行する。

```sh
# POSIX準拠のシステム情報収集スクリプト
cat << 'SCRIPT' > /tmp/sysinfo.sh
#!/bin/sh
set -eu

# システム情報の収集（POSIX準拠）
gather_info() {
    _hostname=$(hostname 2>/dev/null || echo "unknown")
    _kernel=$(uname -r 2>/dev/null || echo "unknown")
    _arch=$(uname -m 2>/dev/null || echo "unknown")
    _uptime=$(cat /proc/uptime 2>/dev/null | cut -d' ' -f1 || echo "unknown")

    echo "Hostname : ${_hostname}"
    echo "Kernel   : ${_kernel}"
    echo "Arch     : ${_arch}"
    echo "Uptime   : ${_uptime}s"
}

# ディスク使用量の表示（POSIX準拠）
show_disk() {
    echo ""
    echo "=== Disk Usage ==="
    df -h / 2>/dev/null | while IFS= read -r line; do
        echo "  $line"
    done
}

# メモリ情報の表示（POSIX準拠）
show_memory() {
    echo ""
    echo "=== Memory ==="
    if [ -f /proc/meminfo ]; then
        _total=$(grep '^MemTotal:' /proc/meminfo | awk '{print $2}')
        _free=$(grep '^MemFree:' /proc/meminfo | awk '{print $2}')
        _avail=$(grep '^MemAvailable:' /proc/meminfo | awk '{print $2}')
        echo "  Total     : $((_total / 1024)) MB"
        echo "  Free      : $((_free / 1024)) MB"
        echo "  Available : $((_avail / 1024)) MB"
    else
        echo "  /proc/meminfo not available"
    fi
}

echo "=== System Information ==="
gather_info
show_disk
show_memory
SCRIPT
chmod +x /tmp/sysinfo.sh

# BusyBox ash で実行
/bin/sh /tmp/sysinfo.sh
```

このスクリプトはPOSIX準拠で書かれているため、BusyBox ash（Alpine Linux）でもdash（Debian/Ubuntu）でもbashでも動く。`[[`を使わず`[`を使い、配列を使わず変数を使い、`function`キーワードを使わず`name()`構文を使う。前回学んだ「契約書」の範囲内にとどまることで、どの環境でも動くスクリプトになる。

### 演習5: Dockerイメージサイズの実測比較

最後に、ベースイメージのサイズ差を実際に確認する。

```bash
# 各ベースイメージのサイズを確認
docker pull alpine:3.21
docker pull ubuntu:24.04
docker pull debian:bookworm-slim
docker pull busybox:latest

docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" | \
    grep -E '(alpine|ubuntu|debian|busybox)'
```

典型的な出力:

```
busybox:latest          4.26MB
alpine:3.21             7.83MB
debian:bookworm-slim    74.8MB
ubuntu:24.04            78.1MB
```

Alpine Linuxはubuntuの約1/10、debianの約1/10だ。この差は、BusyBox（ashを含む）とmusl libcを使い、GNUツールチェーンとglibcを排除した結果だ。シェルひとつの話ではなく、システム全体の設計思想がイメージサイズに反映されている。

---

## 5. まとめと次回予告

### この回の要点

第一に、ashは1989年5月30日にKenneth Almquistが開発した、AT&Tのライセンスに依存しないBourne shell互換シェルだ。1991年の4.3BSD-Net/2で`/bin/sh`として採用され、BSD自由化の重要なピースとなった。30年以上経った今もFreeBSD、NetBSD等のBSD系OSの`/bin/sh`として使われ続けている。

第二に、Herbert Xuが1997年にNetBSD版ashをDebianに移植し、2002年にdash（Debian Almquist shell）と命名した。Xuの関心はPOSIX準拠とスリムな実装にあった。

第三に、Ubuntu 6.10（2006年）がデフォルトの`/bin/sh`をbashからdashに変更し、Debian 6（Squeeze, 2011年）が正式に追随した。この決断の動機は起動速度の改善であり、ブート速度への効果はUpstartの功績と誤解されがちだった。

第四に、dashとbashの速度差は、依存ライブラリの差（dashはlibcのみ、bashはreadline/ncursesも必要）とバイナリサイズの差（dashは約120KB、bashは約1.2MB）に起因する。起動速度でdashはbashの2〜4倍速い。この差は、ブートプロセス・Docker・CI/CDで実質的な意味を持つ。

第五に、BusyBox ash（Alpine Linux）とdistroless（シェルなし）は、「機能を削ぎ落とす」設計思想の延長線上にある。Alpine LinuxのDockerイメージサイズは約5MBと極めて小さく、distrolessは約2MiBでシェルすら含まない。

### 冒頭の問いへの暫定回答

「機能を削ぎ落とすことは、技術的にどのような価値を生むのか」――この問いに対する暫定的な答えはこうだ。

機能を削ぎ落とすことは、速度、軽量さ、信頼性、そしてセキュリティを生む。依存が少なければ壊れにくい。バイナリが小さければ起動が速い。攻撃対象面積が小さければ安全性が高い。これらの価値は、大量のスクリプトを実行するシステム環境や、軽量さが求められるコンテナ環境において、多機能さよりも重要になる場合がある。

ただし、この価値は「機能を必要としない場面」に限定される。人間が対話的に使うシェルでdashを選ぶ者はいない。dashは「道具として使う」シェルであり、「手に取って使う」シェルではない。

bashが機能を積み上げてきた30年と、dashが機能を削ぎ落としてきた30年。この二つの系譜は、同じ問い――「シェルは何をすべきか」――に対する正反対の答えだ。そして、両方の答えが正しい。ただし、場面が違う。

### 次回予告

ここまで、Thompson shell（第3回）からBourne shell（第4回）、csh（第7回）、ksh（第10回）、そしてash/dash（今回）と、シェルの歴史を辿ってきた。次回から、いよいよbashそのものに焦点を当てる。

次回のテーマは「Bashの誕生と席巻――世界を飲み込んだGNUシェル」だ。

Brian Fox（FSF）によるbashの開発開始（1988年）と最初のリリース（1989年6月8日）。GNUプロジェクトの「自由なUNIX」ビジョンにおけるシェルの位置づけ。Chet Ramey（1990年-）による30年以上にわたる長期メンテナンス。Linuxの爆発的普及とbashの覇権確立。

「bashはなぜ『デフォルト』の座を獲得し、30年以上維持できたのか」――次回は、その問いに向き合う。

---

## 参考文献

- Kenneth Almquist, "v19i001: A reimplementation of the System V shell, Part01/08", comp.sources.unix, Volume 19, 1989年5月30日 <https://groups.google.com/g/comp.sources.unix/c/A6cnyKX-Gq4/m/dGKOOmXndCcJ>
- Almquist shell, Wikipedia <https://en.wikipedia.org/wiki/Almquist_shell>
- Sven Mascheck, "Ash (Almquist Shell) Variants" <https://www.in-ulm.de/~mascheck/various/ash/>
- Ubuntu Wiki, "DashAsBinSh" <https://wiki.ubuntu.com/DashAsBinSh>
- LWN.net, "A tale of two shells: bash or dash" <https://lwn.net/Articles/343924/>
- Baeldung, "Linux Shells Performance: dash vs bash" <https://www.baeldung.com/linux/dash-vs-bash-performance>
- BusyBox, Wikipedia <https://en.wikipedia.org/wiki/BusyBox>
- Alpine Linux, Wikipedia <https://en.wikipedia.org/wiki/Alpine_Linux>
- Alpine Linux Wiki, "BusyBox" <https://wiki.alpinelinux.org/wiki/BusyBox>
- Docker Hub, Alpine official image <https://hub.docker.com/_/alpine>
- Docker Documentation, "Dockerfile reference" <https://docs.docker.com/reference/dockerfile/>
- Docker Blog, "Docker Best Practices: Choosing Between RUN, CMD, and ENTRYPOINT" <https://www.docker.com/blog/docker-best-practices-choosing-between-run-cmd-and-entrypoint/>
- GoogleContainerTools/distroless, GitHub <https://github.com/GoogleContainerTools/distroless>
- Linux.com, "30 Linux Kernel Developers in 30 Weeks: Herbert Xu" <https://www.linux.com/news/30-linux-kernel-developers-30-weeks-herbert-xu/>
