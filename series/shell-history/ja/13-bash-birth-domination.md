# 第13回：Bashの誕生と席巻――世界を飲み込んだGNUシェル

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- Brian Foxが1988年にFSF従業員としてbash開発を開始した経緯――Richard Stallmanの「自由なシェル」構想
- 1989年6月8日のbash 0.99ベータリリースと、GNUプロジェクトにおけるシェルの戦略的位置づけ
- Chet Rameyが1990年にプライマリメンテナとなり、35年以上にわたって維持してきた事実
- bash 2.0（1996年）から5.2（2022年）に至る「蓄積型進化」の全貌
- Linuxディストリビューションがbashをデフォルトに据えた歴史的必然
- macOS 10.3 Panther（2003年）でAppleがtcshからbashに切り替えた決断
- bashの「吸収と蓄積」という設計思想――Bourne shell互換を保ちつつcsh/kshの機能を取り込んだ構造
- GNU Readlineの設計と、bashの対話的インタフェースとしての進化

---

## 1. 導入――「Linuxのシェル＝bash」を疑ったことがあるか

Slackware 3.5のインストールが終わり、初めてターミナルに向き合ったとき、私はbashというものを意識していなかった。

1990年代後半、私のLinux体験はSlackwareから始まった。インストーラーの質問に一つずつ答え、何度かの失敗と再インストールを経て、ようやくログインプロンプトにたどり着く。`bash-2.05$`か、あるいは`bash$`か――正確な表示は覚えていないが、そこにあったのは間違いなくbashだった。

だが、それが「bash」であることを私は知らなかった。正確に言えば、それがシェルであること、シェルにはbash以外の選択肢があること、そしてシェルを「選ぶ」という行為が存在することを知らなかった。ターミナルに出てくるもの、コマンドを打てば結果が返ってくるもの。それが私の「シェル」の理解のすべてだった。

その認識が変わったのは、大学の計算機室でBSD環境に触れたときだ。プロンプトの見た目が違う。補完の挙動が違う。聞けば「tcsh」というシェルだという。「bashとtcshは違うものなのか」。その疑問が、シェルの歴史への関心の出発点だった。

今、2020年代のエンジニアの多くが、かつての私と同じ状態にあるのではないだろうか。bashを使っている。あるいはzshを使っている。だが、なぜbashがあらゆるLinuxディストリビューションのデフォルトシェルだったのか。なぜmacOSが16年間bashをデフォルトに据え続けたのか。なぜCI/CDパイプラインの`run:`ステップがデフォルトでbashを使うのか。その「なぜ」を問うたことがあるだろうか。

bashは技術的に最も優れたシェルだからデフォルトになったのではない。bashが「デフォルト」の座を獲得し、30年以上維持できた理由は、技術だけでは説明できない。GNU、FSF、Linux、そしてソフトウェアライセンスという、技術の外側にある力学が深く絡んでいる。

この回では、bashの誕生から覇権確立に至る道のりを辿る。

---

## 2. 歴史的背景――GNUの「自由なシェル」が世界を変えた

### Richard Stallmanの構想と「自由なシェル」の戦略的意味

bashの誕生を理解するためには、1980年代のGNUプロジェクトの文脈に立ち戻る必要がある。

1983年9月27日、Richard StallmanはGNUプロジェクトを発表した。「完全に自由なオペレーティングシステム」を作るという野心的な構想だ。GNUは"GNU's Not Unix"の再帰的頭字語であり、UNIX互換でありながらUNIXではない――AT&Tのライセンスに縛られない――システムを目指した。

GNUプロジェクトは、自由なOSを構成する要素を一つずつ作っていった。Emacs（1985年）、GCC（1987年）、GNU Coreutils（ls, cp, mv等のUNIXコマンド群）。だが、OSの根幹をなすコンポーネントがひとつ欠けていた。シェルだ。

UNIXにおいてシェルは単なるアプリケーションではない。ブートスクリプト、パッケージ管理、cron、ユーザーの対話環境――システムのあらゆる層がシェルに依存している。自由なOSにとって、自由なシェルは不可欠だった。

StallmanとFSF（Free Software Foundation）は、自由なシェルの開発を戦略的に重要なプロジェクトと位置づけた。FSFが自ら資金を投じて開発者を雇用したプロジェクトは限られている。bashはその数少ない一つだった。

### Brian Fox――bashを生んだプログラマ

1959年生まれのBrian Jhan Foxは、1985年からFSFでStallmanと共に働いていた。GNU Makeinfo、GNU Info、GNU Fingerなど、複数のGNUプログラムの作者だ。そしてもう一つ、bashと不可分の存在であるGNU Readlineライブラリの作者でもある。

bashの開発に着手する以前、FSFは別の開発者にBourne shell互換シェルの開発を委ねていた。だが、進捗はStallmanの期待に達しなかった。1988年1月10日、StallmanはFoxにbash開発を委ねた。Foxはこの日からコーディングを開始する。

名前は"Bourne-Again SHell"。Stephen Bourneの名前と"born again"（再生）を掛け合わせた、GNU文化らしい言葉遊びだ。Bourne shellの再実装であると同時に、プロプライエタリなシェルの呪縛からの「再生」を暗示する。頭字語を取ればBASH。技術的正確さとユーモアを両立させる命名は、GNUプロジェクトの伝統だった（GNU自体が"GNU's Not Unix"という再帰的頭字語である）。

Foxの設計目標は明確だった。Bourne shellとの互換性を維持しつつ、cshの対話的機能（ヒストリ、エイリアス、ジョブコントロール）とKorn shellのスクリプティング機能（算術展開、関数など）を取り込む。さらに、POSIX sh標準への準拠を目指す。既存のシェルスクリプトがそのまま動き、対話的な使い勝手も良く、標準にも準拠する。野心的だが、GNUプロジェクトにとっては譲れない要件だった。

1989年6月8日、Foxはbash 0.99をベータ版としてリリースした。GNUプロジェクトが10年近く求めていた「自由なシェル」が、ついに形になった瞬間だ。

### GNU Readlineの誕生

bashと並行して、Foxが1988年に作成したGNU Readlineライブラリは、bashの対話性を支える基盤となった。

POSIXはシェルに行編集機能を要求している。コマンドラインでカーソルを動かし、文字を挿入・削除し、ヒストリを呼び出す。tcshが革新した対話的機能（第8回参照）に匹敵する行編集を、Bourne系シェルにも提供する必要があった。

Readlineの設計判断として重要なのは、行編集機能をシェル本体から分離し、独立したライブラリとして実装したことだ。これにより、bashだけでなく、GDB（GNUデバッガ）、Python対話モード、MySQLクライアントなど、あらゆるCLIプログラムがReadlineの恩恵を受けられるようになった。

Emacsキーバインド（デフォルト）とviキーバインドの両方をサポートし、`~/.inputrc`で細かくカスタマイズできる。第8回で論じた「emacsモード vs viモードの戦い」は、Readlineの設計に直接反映されている。

FoxはReadlineのバージョン1.05まで開発し、その後Chet Rameyに引き継いだ。Rameyは1998年以降、Readlineの単独メンテナとして現在に至る。bashとReadlineが同じ人物によって維持されていること――この事実は、bashの対話的機能の進化にとって決定的に重要だ。

### Chet Ramey――35年にわたるメンテナンスの驚異

ソフトウェアの歴史において、30年以上にわたって一つのプロジェクトを維持し続ける個人は稀だ。Chet Rameyはその稀有な例の一人である。

Case Western Reserve Universityの所属で、同大学でB.S.を取得したRameyは、1989年からbashプロジェクトに参加した。Brian Foxと共同でメンテナンスを行い、バグ修正や機能追加に携わった。Foxが1993年頃にbashの日常的な開発から離れた後、Rameyがプライマリメンテナの座を引き継いだ。

Rameyのメンテナンス哲学は、一言で言えば「互換性と安定性」だ。bashの後方互換性は極めて高い。bash 1.xで書かれたスクリプトが、bash 5.xでもほぼ問題なく動く。これは偶然ではなく、Rameyの意図的な設計判断の結果だ。

同時に、Rameyは新機能の追加にも積極的だった。配列、連想配列、プログラマブル補完、正規表現マッチ、コプロセス――bashの主要機能の多くは、Rameyのメンテナンス期に追加されたものだ。互換性を壊さずに機能を積み上げるという、極めて困難なバランスを、Rameyは35年以上にわたって保ち続けている。

2026年現在もRameyはbashのメンテナンスを続けている。一人の人間の献身が、数十億のデバイスで動くソフトウェアを支えているという事実は、オープンソースの強さと脆さを同時に示している。

### Linuxとの合流――bashが「デフォルト」になった必然

1991年8月25日、Linus Torvaldsがcomp.os.minixに「小さなプロジェクト」を投稿した。Linuxカーネルの誕生だ。だが、カーネルだけではOSにならない。ユーザーランド――コマンド群、シェル、ライブラリ――が必要だ。

ここでGNUプロジェクトとの合流が起きた。GNUはカーネル（GNU Hurd）の完成に苦しんでいたが、ユーザーランドのツール群は既に充実していた。GCC、GNU Coreutils、Emacs、そしてbash。LinuxカーネルとGNUユーザーランドの組み合わせが、後に「GNU/Linux」あるいは単に「Linux」と呼ばれるOSの基盤となった。

このとき、bashがLinuxのデフォルトシェルになったのは必然だった。Linuxのユーザーランドがそもそもの始まりからGNUツール群で構成されているのだから、GNUのシェルであるbashがデフォルトになるのは自然な帰結だ。

1993年、Patrick VolkerdingがSlackwareをリリースした。初期のLinuxディストリビューションとして最大のシェアを持ち、1990年代半ばにはLinux市場の約80%を占めたとされる。Slackwareのデフォルトシェルはbashだった。同年、Ian MurdockがDebianを創設。1994年にはMarc EwingがRed Hatを設立。これらの主要ディストリビューションがすべてbashをデフォルトシェルとして採用した。

ここで注目すべきは、bashが選ばれた理由だ。当時、自由に使えるBourne shell互換のシェルは、bashだけではなかった。前回論じたashもあったし、pdksh（パブリックドメインksh）もあった。だが、bashには決定的な強みがあった。

第一に、FSFの公式プロジェクトとしての信頼性。GNUプロジェクトが保証する品質と継続性は、個人プロジェクトにはない安心感を提供した。

第二に、機能の充実度。Bourne shell互換だけでなく、cshの対話的機能やkshのスクリプティング機能を取り込んだbashは、「一つで全部できる」シェルだった。ディストリビューション側からすれば、bashを入れておけば大多数のユーザーの要求を満たせる。

第三に、ライセンス。bashはGPLで提供されていた。GPLv2はLinuxカーネル自体のライセンスでもあり、GNU/Linuxエコシステム全体の哲学と整合していた。

### Appleの選択――macOSがbashをデフォルトにした2003年

bashの支配はLinuxの世界にとどまらなかった。

2002年のmacOS 10.2 Jaguarでは、BSD由来のtcshがデフォルトのインタラクティブシェルだった。macOSの基盤はDarwin――FreeBSDとMach microkernel（および初期にはNeXTSTEPの系譜）から成るUNIX認証OSだ。BSD系のデフォルトシェルがtcshであることは、その出自からして自然だった。

2003年、macOS 10.3 Pantherで状況が変わった。Appleはデフォルトシェルをtcshからbashに変更した。開発者ビルド7B44でこの変更が確認され、Slashdotで報じられた際には「LinuxユーザーへのアピールではないかAppleがtcshからbashに切り替えた」と話題になった。

この決断の背景には、macOS開発者コミュニティの変化がある。Mac OS XがUNIXベースになったことで、Linux/UNIXの経験を持つ開発者がmacOSに流入していた。彼らにとって、bashは馴染みのあるシェルだ。tcshは第7回で論じた通り、「対話の革命」をもたらしたシェルだが、2000年代にはBourne系シェル（特にbash）がメインストリームだった。Appleは開発者の期待に応えた。

macOS 10.3 Panther（2003年）からmacOS 10.14 Mojave（2018年）まで、約16年間にわたってbashがmacOSのデフォルトシェルであり続けた。ただし、macOSに同梱されたbashのバージョンは3.2のまま凍結されていた。bash 3.2は2006年10月のリリースであり、GPLv2ライセンスの最終バージョンだ。bash 4.0（2009年）以降はGPLv3に移行したが、AppleはGPLv3を受け入れなかった。この問題は第15回で詳しく論じる。

---

## 3. 技術論――「蓄積型進化」の構造

### bashの設計思想：吸収と蓄積

bashの設計思想を一言で表現するなら、「吸収と蓄積」だ。

Bourne shellの構文と互換性を基盤として維持しつつ、cshから対話的機能を、kshからスクリプティング拡張を、そして独自の改良を積み上げていく。何かを捨てるのではなく、何かを加えていく。この「蓄積型進化」こそが、bashを「デフォルト」にした力であり、同時にbashの言語としての複雑さの根源でもある。

bashが各シェルから吸収した機能を整理する。

```
吸収元            主な機能
─────────────    ───────────────────────────────────
Bourne shell      基本構文、リダイレクト、パイプ、変数、
                  制御構造（if/for/while/case）、関数
csh/tcsh          ヒストリ展開（!コマンド）、
                  エイリアス（alias）、
                  チルダ展開（~）、
                  ジョブコントロール（fg/bg/Ctrl-Z）、
                  ディレクトリスタック（pushd/popd）
ksh               算術展開 $((...))、
                  拡張パターンマッチング @()/+()/*() 等、
                  コマンドライン編集（emacs/viモード）、
                  select文、
                  FPATH的な関数ロード機構
POSIX sh          コマンド置換 $(...)（バッククォートに加えて）、
                  算術展開の標準構文、
                  シェルビルトインの仕様
bash独自          プログラマブル補完（complete/compgen）、
                  プロセス置換 <()/>(）、
                  [[ ... ]] 拡張条件式、
                  配列変数（インデックス/連想）、
                  正規表現マッチ =~、
                  コプロセス（coproc）
```

この表が示すのは、bashが「最良の部分を全部取り込む」という方針で設計されたことだ。第10回で論じたKorn shellが「全部入り」を目指した最初のシェルだったとすれば、bashはその方針をさらに徹底した存在だ。

### バージョン史：36年の機能蓄積

bashの進化を、メジャーバージョンごとに追う。

**bash 0.99（1989年6月8日）**。Brian Foxによる最初のベータリリース。Bourne shell互換の基本機能に加え、cshのヒストリ、エイリアス、ジョブコントロールを搭載。GNU Readline統合による行編集機能。この時点で既に「Bourne shell + cshの対話機能 + kshの一部機能」という統合の方向性は明確だった。

**bash 1.x（1989年-1996年）**。初期の安定化期間。バグ修正と基本機能の充実。Brian FoxからChet Rameyへのメンテナ移行もこの時期に起きた。

**bash 2.0（1996年12月23日）**。大きな転換点だ。配列変数が導入された。Bourne shellには配列がなく、kshには存在したが、bashがこれを取り込んだことで、シェルスクリプトのデータ構造が一段階拡張された。プログラマブル補完の基盤も整備され、`shopt`ビルトインが追加された。bash 2.0は「bashがBourne shell互換の域を超えて、独自の言語になり始めた」バージョンだ。

**bash 3.0（2004年8月）**。`[[ ... ]]`条件式内での正規表現マッチ演算子`=~`が導入された。これにより、外部コマンドの`grep`や`expr`に頼らず、シェル内で正規表現マッチングが可能になった。

**bash 3.2（2006年10月）**。技術的には小さなリリースだが、歴史的に重要なバージョンだ。bash 3.2はGPLv2ライセンスで提供された最後のバージョンであり、AppleがmacOSに同梱し続けたのはこのバージョンだった。macOS上でbash 3.2が13年間凍結されたことは、GPLv2とGPLv3の分岐がもたらした具体的な影響だ。

**bash 4.0（2009年2月20日）**。bashの言語拡張の中でも最大級のリリースだ。連想配列（`declare -A`）、コプロセス（`coproc`）、`**`再帰グロブ（`shopt -s globstar`有効時）、大文字小文字変換の変数展開（`${var^^}`、`${var,,}`）、シェル互換性レベルの概念（`compat31`、`compat32`等のshoptオプション）が追加された。

連想配列の導入は、bashスクリプティングの表現力を大きく広げた。キーと値のペアをシェル変数として扱えるようになったことで、設定管理やデータ変換のスクリプトが書きやすくなった。だが同時に、bash 4.0の連想配列はbash固有の拡張であり、POSIX shにも他のシェル（dashやash）にも存在しない。この機能に依存するスクリプトは、ポータビリティを失う。

コプロセス（`coproc`）は、kshのコプロセス機能に触発されたもので、バックグラウンドプロセスとの双方向パイプ通信を可能にする。実際の使用頻度は低いが、bashが「あらゆる機能を取り込む」方針を貫いていることの証左だ。

**bash 4.4（2016年9月）**。`${parameter@operator}`構文が導入され、変数の属性操作がより柔軟になった。`@Q`（クォーティング）、`@E`（エスケープ展開）、`@P`（プロンプト展開）、`@A`（代入文形式）など。

**bash 5.0（2019年1月14日）**。`EPOCHSECONDS`（UNIX時刻を秒単位で返す変数）、`EPOCHREALTIME`（マイクロ秒精度のUNIX時刻）、`BASH_ARGV0`（`$0`の値を設定可能にする変数）が追加された。新しいloadableビルトイン（`rm`、`stat`、`fdflags`）も導入された。

**bash 5.2（2022年12月31日）**。最新の安定版リリース。バグ修正と細かな機能改善が中心だが、内部のメモリアライメントが16バイト境界に変更されるなど、低レベルの最適化も含まれている。

### 蓄積型進化の利点と代償

この36年間のバージョン史が示すのは、bashの「蓄積型進化」の構造だ。

```
bash のバージョン進化と機能蓄積

  bash 0.99 (1989)
  ├── Bourne shell 互換
  ├── csh の対話的機能
  └── readline 統合
        │
        ▼
  bash 2.0 (1996)
  ├── +配列変数
  ├── +プログラマブル補完
  └── +shopt ビルトイン
        │
        ▼
  bash 3.x (2004-2006)
  ├── +=~ 正規表現マッチ
  └── +各種バグ修正・改善
        │
        ▼
  bash 4.0 (2009)
  ├── +連想配列
  ├── +コプロセス (coproc)
  ├── +** 再帰グロブ
  └── +大文字小文字変換展開
        │
        ▼
  bash 5.x (2019-2022)
  ├── +EPOCHSECONDS / EPOCHREALTIME
  ├── +BASH_ARGV0
  └── +各種最適化
```

利点は明白だ。後方互換性が維持されるため、古いスクリプトが壊れない。新しい機能が追加されるため、表現力が年々向上する。ユーザーは「同じシェル」を使い続けながら、より多くのことができるようになる。

代償もまた明白だ。言語の複雑さが単調増加する。bashのマニュアルページは現在100ページを超える。変数展開だけで20種類以上の構文がある。配列の扱いは直感的とは言い難い。条件式は`[ ... ]`と`[[ ... ]]`の二系統が並存する。算術評価は`$(( ... ))`、`let`、`(( ... ))`の三通りがある。

この複雑さは、bashが「何も捨てない」ことの帰結だ。古い構文を廃止すれば既存スクリプトが壊れる。だから古い構文を残したまま新しい構文を追加する。結果として、同じことをするための方法が複数存在し、どの方法が「推奨」なのかを知るには、bashの歴史を理解する必要がある。

### プログラマブル補完：bashが「IDE風」になった瞬間

bash 2.04（2000年）で導入されたプログラマブル補完（`complete`、`compgen`ビルトイン）は、bashの対話的使い勝手を大きく変えた機能だ。

第8回で論じた通り、tcshが最初にコマンドライン補完を実装し、GNU Readlineがその機能をBourne系シェルに持ち込んだ。だが、初期のbashの補完は「ファイル名補完」が中心だった。コマンド名は補完できるが、コマンドの引数やオプションは補完できない。

プログラマブル補完は、この制約を取り払った。`complete`ビルトインを使えば、特定のコマンドに対してカスタムの補完ロジックを定義できる。

```bash
# git サブコマンドの補完定義（簡略版）
_git_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local commands="add branch checkout commit diff log merge pull push status"
    COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
}
complete -F _git_complete git
```

この仕組みの上に、bash-completionパッケージが構築された。bash-completionは、主要なコマンド（git、docker、ssh、apt-get等）に対する補完定義を集めたプロジェクトだ。bashをインストールすれば、多くのディストリビューションでbash-completionも同時にインストールされ、TABキーを押すだけでコマンドのサブコマンドやオプションが補完される。

この体験は、IDE（統合開発環境）のインテリセンスに似ている。シェルがコマンドの構文を「知っている」かのように振る舞う。bashが単なる「コマンド入力装置」から「対話的な開発環境」に近づいた瞬間だ。

zshのcompsys（第17回で詳述）やfishの自動補完（第18回で詳述）は、この方向性をさらに推し進めた。だが、bashのプログラマブル補完が先鞭をつけた「シェルがコマンドを理解する」というパラダイムは、現在のシェル体験の基盤となっている。

### bash vs ksh：影響と分岐

bashとKorn shell（ksh）の関係は、単なる「競合」ではない。影響と分岐の複雑な物語だ。

第10回で論じた通り、David Kornが1983年に発表したkshは、Bourne shell互換 + cshの対話的機能 + 独自拡張という方向性を最初に示したシェルだった。bashの設計思想はkshに強く影響されている。算術展開`$(( ... ))`、拡張パターンマッチング（`extglob`）、コマンドライン編集のemacs/viモードといった機能は、kshからbashに取り込まれたものだ。

だが、kshとbashの命運を分けたのは、技術ではなくライセンスだった。

kshはAT&Tのプロプライエタリソフトウェアだった。使用にはライセンス料が必要であり、ソースコードは非公開だった。2000年にオープンソース化されたが、それは「遅すぎた」。1990年代のLinux爆発的普及期に、kshは自由に配布できなかった。

一方、bashはGPLで提供されていた。誰でも自由にコピー、改変、再配布できる。Linuxディストリビューションがbashをデフォルトに選んだのは、技術的にkshより優れていたからではない。自由に配布できたからだ。

kshが持っていてbashが持っていなかった機能は、時間をかけてbashに取り込まれた。連想配列（kshでは早くから存在、bashでは4.0で追加）、コプロセス（kshの機能がbash 4.0に取り込まれた）、浮動小数点演算（kshには存在するが、bashには2026年現在も存在しない）。bashはkshの遺産を吸収し、kshはLinuxの世界で存在感を失った。

これは技術の勝敗ではなく、ライセンスの勝敗だ。この教訓は、ソフトウェアの歴史において何度も繰り返される。

---

## 4. ハンズオン――bashの各バージョン機能を手を動かして確認する

ここまでの歴史的・技術的議論を、実際に手を動かして確認する。bash各バージョンの主要機能を使い、「蓄積型進化」を体感する。

### 環境構築

Docker環境を前提とする。Ubuntu 24.04にはbash 5.2が搭載されている。

```bash
# Ubuntu環境（bash 5.2）
docker run -it ubuntu:24.04 /bin/bash
```

あるいは、本記事に付属する`setup.sh`スクリプトで一括構築できる。

```bash
bash setup.sh
```

### 演習1: bashのバージョンと搭載機能の確認

まず、自分の環境のbashバージョンを確認し、どの機能が利用可能かを調べる。

```bash
# バージョン確認
echo "bash version: ${BASH_VERSION}"
echo "bash versinfo: ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}"

# shopt で有効化可能なオプション一覧
echo ""
echo "=== shopt オプション一覧 ==="
shopt
```

`shopt`の出力を見れば、bashがどれほど多くの挙動制御オプションを持っているかが分かる。`extglob`（拡張グロブ）、`globstar`（`**`再帰グロブ）、`nullglob`（マッチしないグロブを空文字列にする）など、各オプションはbashの異なるバージョンで追加されたものだ。

### 演習2: 配列と連想配列（bash 2.0 / 4.0の遺産）

bash 2.0で追加されたインデックス配列と、bash 4.0で追加された連想配列を使う。

```bash
# --- インデックス配列（bash 2.0+） ---
echo "=== インデックス配列 ==="
shells=("bash" "zsh" "fish" "dash" "ksh")

echo "全要素: ${shells[*]}"
echo "要素数: ${#shells[@]}"
echo "3番目: ${shells[2]}"

# 配列の反復
for shell in "${shells[@]}"; do
    echo "  - ${shell}"
done

# --- 連想配列（bash 4.0+） ---
echo ""
echo "=== 連想配列 ==="
declare -A shell_year
shell_year["Thompson shell"]=1971
shell_year["Bourne shell"]=1979
shell_year["csh"]=1978
shell_year["ksh"]=1983
shell_year["bash"]=1989
shell_year["zsh"]=1990
shell_year["fish"]=2005

for name in "${!shell_year[@]}"; do
    echo "  ${name}: ${shell_year[$name]}年"
done
```

連想配列を使えば、キーと値のペアを扱えるようになる。ただし、この構文はbash 4.0以降でしか動作しない。macOSのデフォルトbash（3.2）では`declare -A`がエラーになる。これが第15回で論じるGPLv3問題の実害の一つだ。

### 演習3: 拡張条件式 [[ ... ]] と正規表現マッチ

`[[ ... ]]`はbash独自の拡張条件式だ。POSIX shの`[ ... ]`と異なり、ワード分割が行われない、`&&`/`||`が使える、`=~`で正規表現マッチができるなどの利点がある。

```bash
# --- [[ ... ]] と [ ... ] の違い ---
echo "=== 条件式の比較 ==="

# スペースを含む変数（[ ... ] では問題になりうる）
filename="my file.txt"

# POSIX [ ... ] -- クォーティング必須
if [ -n "$filename" ]; then
    echo "[ ... ]: 変数にはクォーティングが必要"
fi

# bash [[ ... ]] -- クォーティング不要（ワード分割が起きない）
if [[ -n $filename ]]; then
    echo "[[ ... ]]: ワード分割が起きないため安全"
fi

# --- 正規表現マッチ（bash 3.0+） ---
echo ""
echo "=== 正規表現マッチ =~  ==="
version="bash-5.2.15"

if [[ $version =~ ^bash-([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "マッチした"
    echo "  メジャー: ${BASH_REMATCH[1]}"
    echo "  マイナー: ${BASH_REMATCH[2]}"
    echo "  パッチ:   ${BASH_REMATCH[3]}"
else
    echo "マッチしなかった"
fi
```

`[[ ... ]]`と`=~`は強力だが、POSIX sh互換ではない。dashやBusyBox ashでは動作しない。前回までに学んだ通り、ポータビリティを重視するなら`[ ... ]`とPOSIX準拠の構文にとどめるべきだ。bashの拡張機能を使うなら、shebangは`#!/bin/bash`と明記し、bashが存在する環境でのみ実行されることを前提とすべきだ。

### 演習4: プロセス置換（bash独自機能）

プロセス置換（`<(...)` / `>(...)`）は、コマンドの出力をファイルのように扱う機能だ。POSIX shには存在しない、bash（およびzsh）固有の機能である。

```bash
echo "=== プロセス置換 ==="

# 二つのコマンドの出力を diff で比較
echo "--- /etc/shells と利用可能なシェルの比較 ---"

# /etc/shells の内容と、実際に存在するシェルを比較
diff <(sort /etc/shells 2>/dev/null || echo "(not available)") \
     <(for sh in /bin/sh /bin/bash /bin/dash /usr/bin/zsh /usr/bin/fish; do
         [ -x "$sh" ] && echo "$sh"
       done | sort) || true

echo ""
echo "--- 二つのディレクトリのファイル一覧を比較する例 ---"
diff <(ls /bin | head -10) <(ls /usr/bin | head -10) || true
```

プロセス置換は、一時ファイルを作成せずに二つのコマンドの出力を比較したい場合に強力だ。だが、この構文はPOSIX shにもdashにもない。Alpine Linuxの`/bin/sh`（BusyBox ash）では動作しない。便利だが、使えば使うほどbashへのロックインが深まる。

### 演習5: コプロセスとEPOCHSECONDS（bash 4.0+ / 5.0+）

比較的新しいbashの機能を体験する。

```bash
# --- EPOCHSECONDS と EPOCHREALTIME（bash 5.0+） ---
echo "=== EPOCHSECONDS / EPOCHREALTIME ==="

if [[ -n "${EPOCHSECONDS:-}" ]]; then
    echo "EPOCHSECONDS:  ${EPOCHSECONDS}"
    echo "EPOCHREALTIME: ${EPOCHREALTIME}"
    echo ""
    echo "date コマンドとの比較:"
    echo "  date +%s:    $(date +%s)"
    echo "  EPOCHSECONDS: ${EPOCHSECONDS}"
    echo ""
    echo "EPOCHSECONDS は外部コマンド (date) を呼ばずに"
    echo "UNIX 時刻を取得できる。スクリプトの高速化に有用。"
else
    echo "EPOCHSECONDS は bash 5.0 以降で利用可能"
    echo "現在の bash バージョン: ${BASH_VERSION}"
fi

# --- コプロセス（bash 4.0+） ---
echo ""
echo "=== コプロセス (coproc) ==="

# cat をコプロセスとして起動
coproc MYPROC { cat; }

# コプロセスに書き込み
echo "Hello from main process" >&"${MYPROC[1]}"

# コプロセスの出力を読み取り
read -r line <&"${MYPROC[0]}"
echo "コプロセスから受信: ${line}"

# コプロセスを終了
exec {MYPROC[1]}>&-
wait "${MYPROC_PID}" 2>/dev/null || true
echo "コプロセス終了"
```

`EPOCHSECONDS`は、`date +%s`を呼ぶ代わりにシェル変数から直接UNIX時刻を取得する。外部コマンドの起動コストがないため、タイムスタンプを頻繁に取得するスクリプトでは性能差が出る。小さな改善だが、こうした「少しだけ便利にする」機能の蓄積がbashの歴史だ。

---

## 5. まとめと次回予告

### この回の要点

第一に、bashは1988年1月10日にBrian FoxがFSF従業員として開発を開始し、1989年6月8日にバージョン0.99のベータとしてリリースされた。GNUプロジェクトが「自由なUNIX」を実現するために、自ら資金を投じて開発させた戦略的プロジェクトだった。

第二に、Chet Rameyが1990年にプライマリメンテナとなり、2026年現在まで35年以上にわたって一人でbashを維持し続けている。bashの安定性と後方互換性は、Rameyの意図的な設計判断の結果だ。

第三に、bashが「デフォルト」の座を獲得した理由は、技術的優位性だけではない。FSFの公式プロジェクトとしての信頼性、GPLによる自由な配布、そしてGNU/Linuxエコシステムとの一体性が決定的だった。kshは技術的にbashと同等以上だったが、プロプライエタリライセンスがLinux時代の覇権を阻んだ。

第四に、bashの「蓄積型進化」は、bash 2.0（1996年）の配列、bash 4.0（2009年）の連想配列・コプロセス、bash 5.0（2019年）のEPOCHSECONDSに至るまで、36年間にわたって機能を積み上げてきた。後方互換性を維持しながら機能を追加し続けた結果、言語として非常に複雑になっている。

第五に、2003年にAppleがmacOS 10.3 Pantherでデフォルトシェルをtcshからbashに変更した。これによりbashはLinuxだけでなくmacOSでもデフォルトとなり、開発者が触れるほぼすべてのUNIX系環境でbashが標準シェルとなった。

### 冒頭の問いへの暫定回答

「bashはなぜ『デフォルト』の座を獲得し、30年以上維持できたのか」――この問いに対する暫定的な答えはこうだ。

bashの覇権は、三つの力の交差点で生まれた。GNUプロジェクトの「自由なUNIX」というビジョン、Linuxの爆発的普及、そしてGPLという配布の自由。技術的にはkshもashも優れた側面を持っていたが、bashだけがこの三つの力を背景に持っていた。

そして、一度デフォルトの座を獲得すると、ネットワーク効果が働く。多くの人がbashを使うから、多くのスクリプトがbash構文で書かれる。多くのスクリプトがbash構文で書かれるから、bashをデフォルトにしておくのが安全だ。こうして「デフォルト」は自己強化される。

ただし、bashの覇権は「技術的必然」ではなく「歴史的偶然の産物」であることを忘れてはならない。GNUのライセンス哲学が違っていたら、LinuxのユーザーランドにGNUツール以外が使われていたら、bashはデフォルトにならなかったかもしれない。技術は真空の中で進化しない。社会、法律、組織の力学の中で進化する。

### 次回予告

今回、bashの誕生と覇権確立を語った。次回は、そのbashが日常の開発でどのように使われ、そしてどこに限界を見せるのかを掘り下げる。

次回のテーマは「bashスクリプティングの生態系――.bashrcからCI/CDまで」だ。

数百行のbashデプロイスクリプトを書いて運用した経験から語る、bashスクリプティングのベストプラクティスとその限界。`set -euo pipefail`の意味、trapの使い方、bats-coreによるテスト。そして「もうbashでは限界だ」と気づく瞬間――エラーハンドリングの脆弱性、型システムの不在、リファクタリングの困難さ。「bash vs Python」論争の構造化にも踏み込む。

「bashスクリプトはどこまで信頼できるのか。そして、どこからがbashの限界なのか」――次回は、その問いに向き合う。

---

## 参考文献

- Brian Fox (programmer), Wikipedia <https://en.wikipedia.org/wiki/Brian_Fox_(programmer)>
- Bash (Unix shell), Wikipedia <https://en.wikipedia.org/wiki/Bash_(Unix_shell)>
- Chet Ramey, "Bash - The GNU Shell", The Architecture of Open Source Applications, Volume 1 <https://aosabook.org/en/v1/bash.html>
- Chet Ramey, "Geek of the Week" interview, Simple Talk <https://www.red-gate.com/simple-talk/opinion/geek-of-the-week/chet-ramey-geek-of-the-week/>
- GNU Bash Reference Manual <https://www.gnu.org/software/bash/manual/bash.html>
- GNU Bash CHANGES file <https://tiswww.case.edu/php/chet/bash/CHANGES>
- GNU Readline, Wikipedia <https://en.wikipedia.org/wiki/GNU_Readline>
- Two Bit History, "Things You Didn't Know About GNU Readline" <https://twobithistory.org/2019/08/22/readline.html>
- Slashdot, "Apple Switches tcsh for bash" (2003) <https://apple.slashdot.org/story/03/08/26/146205/apple-switches-tcsh-for-bash>
- OSnews, "Apple switching from tcsh to bash" (2003) <https://www.osnews.com/story/4340/apple-switching-from-tcsh-to-bash/>
- TLDP, "Bash, version 4" <https://tldp.org/LDP/abs/html/bashver4.html>
- LWN.net, "Bash 4.0 brings new capabilities" (2009) <https://lwn.net/Articles/320546/>
- Bash 5.2 released, LWN.net (2022) <https://lwn.net/Articles/909596/>
- GNU Project, "About the GNU Project" <https://www.gnu.org/gnu/thegnuproject.en.html>
