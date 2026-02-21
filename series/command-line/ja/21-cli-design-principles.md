# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第21回：CLIデザインの原則――man, --help, 12 Factor CLI

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 1971年11月3日に発行されたUNIX Programmer's Manualが確立した、manページの構造と設計思想の歴史的起源
- POSIX Utility Syntax Guidelinesが定めた13のガイドラインと、コマンドライン引数の規約が生まれた背景
- GNUプロジェクトが導入したlong option（--verbose）とgetopt_longの設計判断、および--helpと--versionの標準化
- 終了コードの規約（0は成功、非0は失敗）とsysexits.hの歴史
- Jeff Dickeyの「12 Factor CLI Apps」（2018年）とclig.dev（2020年）が整理した、現代のCLIデザイン原則
- サブコマンドパターン（git, docker）の設計思想と、CLIの「発見可能性」をどう確保するか

---

## 1. 引数の設計に悩んだ夜

私が初めて業務用のCLIツールを自作したのは、2000年代半ばのことだ。複数のサーバにデプロイされたアプリケーションのログを収集し、特定のパターンを集計して報告するツールだった。

機能は明確だった。だが、引数の設計で手が止まった。

ホスト名はどう渡す。位置引数か、`-h`フラグか。パターンは正規表現を受けるのか、固定文字列か。出力形式はJSON、CSV、それとも人間が読めるテーブルか。冗長モードは`-v`か、`--verbose`か。エラーが起きたときの終了コードは何を返すべきか。ヘルプメッセージはどの形式で出すべきか。

当時の私は、GNUスタイルのlong optionとPlan 9スタイルの単一文字フラグの間で揺れていた。第15回で語ったPlan 9のrcシェルは、UNIXの慣習に縛られない簡潔な引数設計を持っていた。一方、自分が毎日使っているGNU coreutilsは`--color=auto`や`--recursive`といった長いオプション名で操作の意図を明示していた。

結局、私は周囲のエンジニアが「直感的に使える」ことを優先し、GNU風の設計を選んだ。`--host`、`--pattern`、`--format`。`-v`で冗長モード。`--help`でヘルプ表示。ありふれた設計だ。

だが、あの判断の根拠は何だったのか。「みんなそうしているから」という以上の理由を、当時の私は持っていなかった。

「良いCLIツール」とは何か。その問いに答えるための知識体系は、実は50年以上にわたって蓄積されてきた。manページの構造は1971年に始まり、POSIX Utility Syntax Guidelinesは13のガイドラインを定め、GNUコーディング標準はlong optionの規約を整備し、2018年にはJeff Dickeyが12 Factor CLI Appsを発表した。2020年にはclig.devがモダンCLIの包括的なガイドラインをまとめた。

あなたは、自分が作るCLIツールの設計判断を、どこまで意識的に行っているだろうか。

---

## 2. manページ――50年間生き続けるドキュメント設計

### 1971年11月3日、最初のマニュアル

CLIツールの設計原則を語るなら、まずドキュメントから始めなければならない。ツールはドキュメントなしには使えないからだ。

1971年11月3日、UNIX Programmer's Manualの初版が発行された。Dennis RitchieとKen Thompsonが、マネージャーのDoug McIlroyの要請を受けて執筆したものだ。初版は61個のコマンドを文書化し、数十のシステムコールとライブラリルーチンを含んでいた。物理的なバインダーに綴じられたページの集合であり、これがmanページの原型だ。

McIlroyがマニュアルの存在を強く求めたことは、単なる管理者としての律儀さではない。McIlroyは、マニュアルの品質がソフトウェアの品質を規定すると考えていた。Sandy Fraserの証言によれば、「マニュアルに高い基準を要求したことが、マニュアルに記載されるプログラム自体の品質向上にもつながった」。ドキュメントの質を追求することが、ツールの質を追求することと等価であるという洞察は、50年後の今も変わらない。

manページのフォーマットはroff（後のnroff/troff）で記述された。Joe F. Ossannaが実装したroffは、元はベル研究所の特許部門向けの文書フォーマッティングシステムとして開発されたものだ。UNIXの開発チームがPDP-11の購入を正当化するために提案した文書処理という名目が、結果的にmanページのフォーマッティング基盤を生んだ。技術の歴史には、こうした偶然の連鎖が多い。

### manページの構造が確立したもの

初版のmanページから、以下のヘッダー構造が確立された。

```
NAME        -- コマンド名と一行の説明
SYNOPSIS    -- 使用法（構文）
DESCRIPTION -- 詳細な説明
OPTIONS     -- オプションの説明（初期は省略されることも多い）
SEE ALSO    -- 関連するコマンドやドキュメント
BUGS        -- 既知の不具合
AUTHORS     -- 作者（質問の送り先としても機能）
```

この構造は、意図的に設計されたものというより、初期のタイムシェアリングシステムのリファレンスドキュメントに類似した形式を踏襲したものだ。だが、結果としてこの構造は驚くほどの耐久性を示した。

SYNOPSISセクションの表記法を見てほしい。

```
ls [-alrtS] [file ...]
grep [-cilnvx] [-e pattern] [file ...]
```

角括弧`[]`はオプショナルな要素を示す。`...`は繰り返しを示す。イタリック体（または下線）はユーザーが置き換えるべきメタ引数を示す。この表記法は、1971年から今日まで、ほぼそのまま使われている。SYNOPSISのフォーマットだけで、CLIツールの全体像を把握できる。引数の設計が良ければ良いほど、SYNOPSISは簡潔になる。

manページはさらに、8つのセクションに分類された。

```
Section 1: General Commands（一般コマンド）
Section 2: System Calls（システムコール）
Section 3: Library Functions（ライブラリ関数）
Section 4: Special Files（特殊ファイル）
Section 5: File Formats（ファイルフォーマット）
Section 6: Games（ゲーム）
Section 7: Miscellaneous（その他）
Section 8: System Administration（システム管理）
```

`man 1 printf`（コマンドとしてのprintf）と`man 3 printf`（C関数としてのprintf）を区別できるのは、このセクション分けのおかげだ。初版では単に長い印刷物のセクションに過ぎなかったものが、後に`man(1)`コマンドによるオンライン参照を可能にする分類体系として機能するようになった。

### manページが教えるCLI設計

manページの構造は、CLIツールの設計に対する暗黙の制約として機能している。

SYNOPSISに書けないほど複雑な引数設計は、そもそもユーザーが理解できない。DESCRIPTIONが数ページに渡るなら、ツールの責務が大きすぎる可能性がある。OPTIONSセクションに100を超えるオプションがあるなら、サブコマンドへの分割を検討すべきだ。

McIlroyがmanページの品質を追求したことの本質は、ドキュメンタビリティ（文書化可能性）がソフトウェア設計の品質指標であるという洞察にある。manページに明瞭に記述できないCLIは、設計に問題がある。

---

## 3. オプションの流儀――UNIXからGNUへ、そしてPOSIXへ

### UNIX伝統のオプション構文

UNIXのコマンドラインオプションは、歴史的にハイフン1つ（`-`）に続く単一の英数字で表現されてきた。`ls -l`の`-l`、`grep -i`の`-i`、`ps -ef`の`-ef`。この慣習は、テレタイプの時代にキーストロークを最小化する必要があったことに由来する。第4回で語った300bpsのボーレートの世界では、`--long-listing`と打つ余裕はなかった。

オプションの統一的なパースを可能にするために、getopt関数が開発された。その起源は1980年頃に遡る。1985年のUNIFORUM会議（テキサス州ダラス）で、AT&Tがgetoptをパブリックドメインとして公開する意図で発表した。だが、AT&Tの担当者がライセンスに関する質問をはぐらかしたことに業を煮やしたHenry Spencerが、その場で独自の互換実装を書くと宣言した。Spencerの実装は1984年4月28日のコーディング日付を持ち、BSDは今もSpencerのバージョンを使用している。

このエピソードは、getoptの技術的な側面よりも、ソフトウェアの自由をめぐる1980年代の緊張を象徴している。第14回で語ったGNUプロジェクトの背景とも通底する話だ。

getoptは1988年にPOSIX.1-1988（IEEE Std 1003.1-1988）で標準化され、Cプログラムにおけるコマンドラインオプションのポータブルなパースが可能になった。

### POSIX Utility Syntax Guidelines

POSIXは、getoptの標準化にとどまらず、コマンドラインユーティリティの構文全体を規定するガイドラインを策定した。POSIX Utility Syntax Guidelines（Base Definitions 12.2節）は13のガイドラインで構成されている。

主要なガイドラインを要約する。

```
ガイドライン1:  ユーティリティ名は2文字以上9文字以下、小文字と数字のみ
ガイドライン2:  オプション名は単一の英数字文字
ガイドライン3:  オプションは'-'区切り文字で始まる
ガイドライン4:  オプション引数を持たない複数のオプションは1つの'-'の後に
               グループ化できる（例: -lrt）
ガイドライン5:  オプションとそのオプション引数は別々の引数とする
ガイドライン7:  オプション引数は任意の文字列を取れる
ガイドライン9:  すべてのオプションはオペランドの前に指定する
ガイドライン10: 最初のオペランドが'-'で始まる場合、'--'でオプションの
               終了を示すべきである
ガイドライン13: 標準入力/標準出力を示すオペランドとして'-'を使用する
```

これらのガイドラインは、歴史的なUNIXコマンドの「カオス」を整理する試みだった。POSIXの策定者たちは、「歴史的なユーティリティの混乱は、将来のユーティリティの設計を妨げるべきではない」と明言している。既存のコマンド（歴史的互換性のために変更できないもの）と、将来のコマンド（ガイドラインに準拠すべきもの）を区別したのだ。

ガイドライン10の`--`（ダブルダッシュ）は、実用上きわめて重要だ。`grep`で`-error`というパターンを検索したいとき、`grep -error`ではオプションとして解釈されてしまう。`grep -- -error`と書くことで、`--`以降はオペランドであることを明示できる。この規約がなければ、ハイフンで始まる文字列を安全に扱う方法がない。

### GNUが導入したlong option

1983年に発表されたGNUプロジェクトは、UNIXのコマンドライン構文に重要な拡張を加えた。long optionだ。

GNUは当初、`+verbose`のように`+`記号でlong optionを示していた。だが、これはすぐに`--verbose`という`--`（ダブルダッシュ）形式に変更された。getopt_long関数がGNU拡張として開発され、`--verbose`、`--output=file.txt`、`--no-color`といった読みやすいオプションの統一的なパースが可能になった。

GNUのlong optionが解決した問題は、「記憶の限界」だ。`tar -xzf`の各フラグが何を意味するか、即座に答えられる人間は多くない（x=extract, z=gzip, f=file）。だが、`tar --extract --gzip --file=archive.tar.gz`なら、コマンドの意図は自明だ。

GNU Coding Standardsは、すべてのGNUプログラムが以下を守るべきだと規定している。

```
1. getopt_longを使用して引数をデコードする
2. 単一文字オプションに対応するlong optionを定義する
3. --help オプションでヘルプメッセージを標準出力に表示し、
   終了コード0で終了する
4. --version オプションでプログラム名、バージョン、
   著作権情報を標準出力に表示し、終了コード0で終了する
```

--helpと--versionの標準化は、地味だが深い意味を持つ。あらゆるGNUプログラムで`--help`が同じ動作をするという保証は、ユーザーがツールの最初の一歩を踏み出す障壁を下げる。名前も用途も知らないコマンドでも、`command --help`と打てば、そのツールが何をするものかを知ることができる。これは第13回で語った「発見可能性」の問題に対するGNUの回答だ。

### 三つの流儀の比較

ここまでの歴史を整理すると、CLIオプションの設計には三つの流儀が存在する。

```
1. UNIX伝統スタイル:
   - 単一文字オプション（-l, -a, -r）
   - グループ化可能（-lar）
   - getoptでパース
   - 利点: 簡潔、タイプ量が少ない
   - 欠点: 覚えにくい、自己説明性が低い
   - 例: ls -la, grep -rn, ps -ef

2. GNU long optionスタイル:
   - ダブルダッシュ + 名前（--verbose, --recursive）
   - 値は=で指定（--output=file.txt）
   - getopt_longでパース
   - 単一文字のエイリアスも併用（-v = --verbose）
   - 利点: 自己説明的、プログラム間で一貫性
   - 欠点: タイプ量が多い
   - 例: ls --all --long, grep --recursive --line-number

3. サブコマンドスタイル:
   - tool command [options] [arguments]
   - 各サブコマンドが独自のオプションを持つ
   - 利点: 大規模ツールの名前空間を整理できる
   - 欠点: 入力が長くなる、コマンド名の発見が必要
   - 例: git commit -m "msg", docker run --rm -it ubuntu
```

現実のCLIツールの多くは、これらのスタイルを組み合わせて使用している。gitは典型的な例だ。`git`がサブコマンドスタイル、各サブコマンド（`commit`、`log`、`diff`等）がUNIX伝統+GNU long optionの混合スタイルを採用している。

---

## 4. 終了コードとエラーメッセージ――沈黙の規約

### 0は成功、非0は失敗

CLIツールの設計において、最も見過ごされがちだが最も重要な要素の一つが、終了コードだ。

UNIXの規約では、プログラムが正常に終了した場合は終了コード0を返し、異常終了した場合は非0の値を返す。C言語の標準では、`EXIT_SUCCESS`（0）と`EXIT_FAILURE`（1）が定義されている。この「0が成功」という一見直感に反する規約には、合理的な理由がある。成功の形は一つだが、失敗の形は多様だからだ。0以外の254通りの値で、失敗の種類を伝えることができる。

```bash
# 終了コードの利用例

# grepは、パターンが見つかれば0、見つからなければ1を返す
grep "pattern" file.txt
echo $?  # 0（見つかった）または 1（見つからなかった）

# パイプラインの制御
grep "ERROR" logfile.txt && echo "エラーあり" || echo "エラーなし"

# シェルスクリプトでの条件分岐
if command; then
    echo "成功"
else
    echo "失敗（終了コード: $?）"
fi
```

終了コードは、パイプラインとシェルスクリプトの基盤だ。`&&`（前のコマンドが成功したら次を実行）と`||`（前のコマンドが失敗したら次を実行）は、終了コードの0/非0に基づいて動作する。CLIツールが終了コードを適切に返さなければ、シェルスクリプトの制御フローが破綻する。

### sysexits.h――失敗の分類学

任意の非0値で異常終了を示すだけでは、失敗の原因を呼び出し側に伝えることが困難だ。1980年、Eric Allmanはdelivermail（後のsendmail）のためにsysexits.hを作成し、終了コードの標準的な分類を定義した。

```
EX_USAGE    (64)  -- コマンドラインの使用法エラー
EX_DATAERR  (65)  -- 入力データの形式エラー
EX_NOINPUT  (66)  -- 入力ファイルが存在しない
EX_NOUSER   (67)  -- 指定されたユーザーが存在しない
EX_NOHOST   (68)  -- 指定されたホストが存在しない
EX_UNAVAIL  (69)  -- サービスが利用不可能
EX_SOFTWARE (70)  -- 内部ソフトウェアエラー
EX_OSERR   (71)  -- OSエラー
EX_OSFILE   (72)  -- OSファイルが見つからない
EX_CANTCREAT(73)  -- 出力ファイルを作成できない
EX_IOERR   (74)  -- I/Oエラー
EX_TEMPFAIL (75)  -- 一時的な失敗（リトライ可能）
EX_PROTOCOL (76)  -- プロトコルエラー
EX_NOPERM   (77)  -- 権限不足
EX_CONFIG   (78)  -- 設定エラー
```

終了コードの範囲が64から始まるのは、低い番号（1〜63）が既に他のプログラムで使用されている可能性を避けるためだ。sysexits.hはPOSIX標準には含まれていないが、FreeBSD、OpenBSD、GNU Cライブラリが採用しており、事実上の標準として広く参照されている。

特にEX_USAGE（64）は重要だ。CLIツールが不正な引数を受け取ったとき、このコードを返すことで、呼び出し側は「プログラムのバグではなく、呼び出し方の問題だ」と判断できる。EX_TEMPFAIL（75）も重要で、ネットワークエラーなど一時的な障害を示すことで、リトライロジックの判断材料になる。

### stderrの分離――エラーメッセージの行き先

終了コードと並んで重要なのが、エラーメッセージの出力先だ。

UNIXのV6まで、エラーメッセージは標準出力に混在していた。この設計が問題を起こしたのは、パイプラインの出力を植字機に送る場面だった。Dennis Ritchieの証言によれば、複数回にわたって植字実行の結果がエラーメッセージに汚染され、無駄になった。この経験から、Ritchieは標準エラー出力（stderr, ファイルディスクリプタ2）の概念を作成した。

```
標準入力  (stdin,  fd 0) -- プログラムへの入力
標準出力  (stdout, fd 1) -- プログラムの正常な出力
標準エラー (stderr, fd 2) -- エラーメッセージ、診断情報
```

この三つのストリームが分離されていることの設計上の意味は深い。CLIツールが正常な出力をstdoutに、エラーメッセージをstderrに書き分けることで、パイプラインの下流は正常なデータのみを受け取り、エラーメッセージは端末に表示される。

```bash
# stdoutとstderrの分離が活きる例

# 正常な出力はファイルに、エラーは端末に表示
find / -name "*.log" > results.txt 2>/dev/null

# パイプラインの途中でエラーは端末に表示される
cat input.txt | sort | uniq 2>/dev/stderr | wc -l
```

良いCLIツールは、この分離を厳密に守る。進捗メッセージ、警告、エラーはstderrへ。処理結果のデータのみがstdoutを流れる。この規約を破るツールは、パイプラインの中で「毒」になる。

### エラーメッセージの設計

エラーメッセージ自体にも設計原則がある。良いエラーメッセージは三つの情報を含む。

```
1. 何が起きたか（事実の記述）
2. なぜ起きたか（原因の推定）
3. どうすればよいか（修正方法の提案）

良い例:
  error: file 'config.yaml' not found
  hint: create the file with 'myapp init' or specify a path with --config

悪い例:
  Error: operation failed
```

Rustのコンパイラは、エラーメッセージ設計の模範として広く認知されている。エラーの箇所を正確に示し、原因を説明し、修正候補まで提示する。CLIツールのエラーメッセージも、同じ設計思想に従うべきだ。

---

## 5. 12 Factor CLIと現代のデザインガイドライン

### Jeff Dickeyの「12 Factor CLI Apps」

2018年10月、HerokuのCLI開発者Jeff Dickeyは「12 Factor CLI Apps」をMediumで発表した。Herokuが提唱した「The Twelve-Factor App」（Webアプリケーションの設計原則）をCLIアプリケーション向けに翻案したものだ。Dickeyは同時に、oclif（Open CLI Framework）というNode.js/TypeScript製のCLIフレームワークもオープンソースで公開しており、HerokuとSalesforceのCLIの共通基盤として使用されている。

12の要素を要約する。

```
1.  Great help is essential
    -- ヘルプは不可欠。CLI内ヘルプとWeb上のドキュメントの両方を提供する
2.  Prefer flags to args
    -- 位置引数よりフラグを優先する。明示性が可読性を生む
3.  What version am I on?
    -- バージョン情報はデバッグの出発点。--versionで表示可能にする
4.  Mind the stderr
    -- 人間向けの情報はstderrに、機械向けの出力はstdoutに分離する
5.  Be fancy! (but only when interactive)
    -- 対話的な端末では色やプログレスバーを使い、
       パイプの中ではプレーンテキストに戻る
6.  Prompt if you can
    -- 足りない情報があれば対話的に尋ねる（非対話モードでは失敗させる）
7.  Use tables
    -- 表形式の出力を提供し、データの可読性を高める
8.  Speed is a feature
    -- 速度はUXの一部。起動時間は100ms以下を目指す
9.  Encourage contributions
    -- オープンソースにし、プラグインアーキテクチャで拡張性を確保する
10. Be clear about subcommands
    -- サブコマンドは2階層まで。深すぎるネストは混乱を招く
11. Follow XDG-spec
    -- 設定ファイルはXDG Base Directory仕様に従う
12. Handle things going wrong
    -- エラー時は有用な情報を提供し、デバッグログを残す
```

12の要素の中で、私が特に注目するのは第4項と第5項だ。

第4項「Mind the stderr」は、前節で語ったstdoutとstderrの分離を改めて強調している。Dickeyは、人間向けのメッセージ（進捗、ヘント、警告）はstderrに、機械が処理すべきデータはstdoutに送ることを強く推奨している。これはUNIXの伝統と完全に一致するが、多くのモダンなCLIツールがこの原則を無視している現実への警告でもある。

第5項「Be fancy! (but only when interactive)」は、現代のCLI設計における重要な判断だ。人間がターミナルで対話的に使っている場合は、色、絵文字、プログレスバー、スピナーを使ってリッチなフィードバックを提供する。だが、パイプの中や`> file.txt`でリダイレクトされている場合は、ANSIエスケープシーケンスを含まないプレーンテキストに戻る。isatty(3)関数で端末接続を判定し、出力を切り替える。これは、CLIツールが「二つの顔」を持つべきだということだ。人間向けの顔と、機械向けの顔。

```bash
# isattyの判定イメージ
# 対話モード:
$ myapp list
┌──────────┬────────┬──────────────┐
│ Name     │ Status │ Last Updated │
├──────────┼────────┼──────────────┤
│ project1 │ active │ 2 hours ago  │
│ project2 │ draft  │ 3 days ago   │
└──────────┴────────┴──────────────┘

# パイプ/リダイレクト時:
$ myapp list | head
project1  active  2024-01-15T10:30:00Z
project2  draft   2024-01-12T14:22:00Z
```

### clig.dev――モダンCLIの包括的ガイドライン

2020年12月、Aanand Prasad（Squarespace）、Ben Firshman（Docker Compose共同作成者、Replicate）、Carl Tashian（Smallstep）、Eva Parish（Squarespace）の四人がCommand Line Interface Guidelines（clig.dev）を公開した。Hacker Newsのフロントページに3日間掲載され、公開数時間で1万5千ビューを達成した。

clig.devは、50年分のCLI設計の知恵を現代のコンテキストで再整理したものだ。その原則は多岐にわたるが、中核にあるのは以下のコンセプトだ。

**「人間ファースト」の設計。** CLIツールは、まず人間が使いやすいように設計し、次にスクリプトから使いやすいように設計する。逆ではない。これは一見、パイプラインの自動化を重視するUNIX哲学と矛盾するように思えるが、clig.devの論点は異なる。人間にとって使いやすいCLIは、エラーメッセージが明確で、ヘルプが充実し、デフォルト値が賢い。そうしたツールは、結果的にスクリプトからも扱いやすくなる。

**出力の設計。** 出力先がターミナルかパイプかで出力を切り替えるべきだ（12 Factor CLIの第5項と同じ）。人間向けには表、色、相対時間（「2時間前」）を使い、機械向けにはJSON、TSV、ISO 8601タイムスタンプを使う。`--json`フラグで機械可読出力を選択できるようにする。

**堅牢性の原則。** Postelの法則（送信するものには厳格に、受信するものには寛容に）を適用する。入力の解釈は寛容に、出力の生成は厳格に。だが、曖昧な入力を黙って「推測」して処理するのは危険だ。曖昧な場合はユーザーに確認を求めるか、エラーを返すべきだ。

**変更の管理。** CLIのインターフェースはAPIだ。オプション名、終了コード、出力フォーマットを変更すると、それに依存するスクリプトが壊れる。Semantic Versioningに従い、破壊的変更はメジャーバージョンアップに限定する。

### サブコマンドパターンの設計

clig.devと12 Factor CLIの両方が強調するのが、サブコマンドパターンの設計だ。

単一のCLIツールが提供する機能が増えると、フラットなオプション空間では管理しきれなくなる。サブコマンドは、この問題に対する構造的な解答だ。

```
サブコマンドパターンの構文:
  tool [global-options] command [command-options] [arguments]

例:
  git --no-pager log --oneline -20
  ^^^^                              グローバルオプション（全サブコマンドに影響）
       ^^^^^^^^^^                   サブコマンドオプション
                    ^^^             サブコマンド
  docker container ls --format "table {{.Names}}\t{{.Status}}"
```

サブコマンドパターンは、CVS（1990年）やSubversionを経て、git（2005年）やDocker（2013年）で広く普及した。gitの設計が特に注目に値するのは、サブコマンドの「拡張性」だ。gitは、PATH上に`git-<subcmd>`という名前の実行ファイルがあれば、それを`git <subcmd>`として実行できる仕組みを持つ。これにより、コアチームが意図しなかった機能をサードパーティが拡張として追加できる。

サブコマンドの設計にはトレードオフがある。

```
利点:
  - 名前空間の整理（git log vs git commit は衝突しない）
  - 各サブコマンドが独自のオプションと引数を持てる
  - ヘルプの構造化（git help commit で特定のサブコマンドのヘルプ）
  - 拡張性（プラグインとして新しいサブコマンドを追加）

注意点:
  - 階層は2段まで（docker container ls は許容、
    tool a b c d は深すぎる）
  - サブコマンド名の発見可能性（どんなサブコマンドがあるかを
    知る方法が必要）
  - グローバルオプションとサブコマンドオプションの位置関係
    （git --no-pager log vs git log --no-pager）
```

clig.devは、サブコマンドの発見可能性について、引数なしでツールを実行した場合にサブコマンドの一覧を表示することを推奨している。`docker`と打てばサブコマンドの一覧が表示され、`docker container`と打てばcontainerサブコマンド配下のコマンド一覧が表示される。これは第13回で語ったGUIのコマンドパレットに相当するCLIの発見メカニズムだ。

---

## 6. ハンズオン：CLIデザイン原則を体験する

### 環境構築

```bash
# Docker環境で実行（ubuntu:24.04ベース）
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：manページの構造を読み解く

```bash
apt-get update && apt-get install -y man-db coreutils grep gawk

echo "=== 演習1: manページの構造を読み解く ==="
echo ""

# manページのセクション構造を確認する
echo "--- manページのセクション構造 ---"
echo ""
echo "manページは8つのセクションに分類される:"
echo "  Section 1: General Commands"
echo "  Section 2: System Calls"
echo "  Section 3: Library Functions"
echo "  Section 4: Special Files"
echo "  Section 5: File Formats"
echo "  Section 6: Games"
echo "  Section 7: Miscellaneous"
echo "  Section 8: System Administration"
echo ""

# grepのmanページの構造を確認
echo "--- grepのmanページの構造 ---"
man grep 2>/dev/null | head -60
echo ""
echo "→ NAME, SYNOPSIS, DESCRIPTIONのヘッダー構造は"
echo "  1971年の初版から50年以上変わっていない。"
echo ""

# SYNOPSISの表記法を確認
echo "--- SYNOPSISの表記法 ---"
echo ""
echo "manページのSYNOPSISには以下の表記規約がある:"
echo "  [-abc]    オプショナルなオプション（角括弧）"
echo "  -a|-b     排他的な選択肢（パイプ文字）"
echo "  file ...  繰り返し可能な引数（省略記号）"
echo "  FILE      ユーザーが置き換えるべきメタ引数（大文字/斜体）"
echo ""
echo "例: grep [-cilnvx] [-e pattern] [file ...]"
echo "  → -c, -i, -l, -n, -v, -x はオプショナルなオプション"
echo "  → -e pattern はオプショナルでpatternを引数に取る"
echo "  → file は0個以上のファイル名を受け取る"
```

### 演習2：終了コードの動作を確認する

```bash
echo ""
echo "=== 演習2: 終了コードの動作を確認する ==="
echo ""

# 成功と失敗の終了コード
echo "--- 基本的な終了コード ---"
echo ""

echo "true の終了コード:"
true
echo "  \$? = $?"
echo ""

echo "false の終了コード:"
false
echo "  \$? = $?"
echo ""

# grepの終了コード（0: 見つかった, 1: 見つからなかった, 2: エラー）
echo "--- grepの終了コード ---"
echo "hello world" | grep "hello" > /dev/null 2>&1
echo "  'hello' を検索 → \$? = $? （見つかった）"

echo "hello world" | grep "xyz" > /dev/null 2>&1
echo "  'xyz' を検索   → \$? = $? （見つからなかった）"

grep --invalid-option 2> /dev/null
echo "  不正なオプション → \$? = $? （エラー）"
echo ""

# 終了コードを使った制御フロー
echo "--- 終了コードによる制御フロー ---"
echo ""

echo "hello world" > /tmp/test.txt

echo '&& と || による条件実行:'
grep -q "hello" /tmp/test.txt && echo "  'hello' が見つかった（&&で実行）"
grep -q "missing" /tmp/test.txt || echo "  'missing' が見つからなかった（||で実行）"
echo ""

# sysexits.hの値を確認
echo "--- sysexits.h の主要な終了コード ---"
echo ""
echo "  EX_OK        (0)   成功"
echo "  EX_USAGE     (64)  コマンドラインの使用法エラー"
echo "  EX_DATAERR   (65)  入力データの形式エラー"
echo "  EX_NOINPUT   (66)  入力ファイルが存在しない"
echo "  EX_SOFTWARE  (70)  内部ソフトウェアエラー"
echo "  EX_OSERR     (71)  OSエラー"
echo "  EX_CANTCREAT (73)  出力ファイルを作成できない"
echo "  EX_TEMPFAIL  (75)  一時的な失敗（リトライ可能）"
echo "  EX_NOPERM    (77)  権限不足"
echo "  EX_CONFIG    (78)  設定エラー"
echo ""
echo "→ 終了コードは、呼び出し側が障害の種類を判断するための'返り値'だ。"
echo "  0が成功で非0が失敗という規約は、シェルの && || if の動作の基盤である。"

rm -f /tmp/test.txt
```

### 演習3：stdoutとstderrの分離を体験する

```bash
echo ""
echo "=== 演習3: stdoutとstderrの分離を体験する ==="
echo ""

# stdoutとstderrの混在問題
echo "--- stdoutとstderrが分離されている利点 ---"
echo ""

# findは権限エラーをstderrに出力し、結果をstdoutに出力する
echo "findコマンド（権限エラーのあるディレクトリ）:"
echo "  stdout（結果）とstderr（エラー）が分離されている:"
echo ""
echo "  全出力:"
find /etc -name "*.conf" 2>&1 | head -5
echo "  ..."
echo ""
echo "  stdoutのみ（エラーを抑制）:"
find /etc -name "*.conf" 2>/dev/null | head -5
echo "  ..."
echo ""

# 正しいCLIツールの出力設計
echo "--- 正しい出力設計のパターン ---"
echo ""
echo "良い設計:"
echo "  stdout → 処理結果のデータ（パイプで次のコマンドに渡せる）"
echo "  stderr → 進捗表示、警告、エラーメッセージ"
echo ""
echo "悪い設計:"
echo "  stdout → データとエラーが混在"
echo "  → パイプの下流で正常なデータとエラーメッセージを区別できない"
echo ""

# 実例: curlの出力設計
apt-get install -y curl > /dev/null 2>&1
echo "curlの出力設計:"
echo "  curl -o file URL  → ダウンロードデータはfileに、進捗はstderrに"
echo "  curl -s URL       → データはstdoutに（-sでstderrの進捗を抑制）"
echo "  curl URL | jq .   → データをパイプで処理（進捗はstderrで端末に表示）"
echo ""
echo "→ curlはstdout/stderrの分離を正しく実装した好例だ。"
echo "  進捗バーはstderrに表示されるため、パイプの下流を汚染しない。"
```

### 演習4：CLIオプションの三つの流儀を比較する

```bash
echo ""
echo "=== 演習4: CLIオプションの三つの流儀を比較する ==="
echo ""

# UNIX伝統スタイル
echo "--- 1. UNIX伝統スタイル（単一文字オプション） ---"
echo ""
echo "  ls -la          （-l と -a のグループ化）"
ls -la /etc/*.conf 2>/dev/null | head -5
echo "  ..."
echo ""

# GNU long optionスタイル
echo "--- 2. GNU long optionスタイル ---"
echo ""
echo "  ls --all --long  （同じ操作をlong optionで）"
ls --all --long /etc/*.conf 2>/dev/null | head -5
echo "  ..."
echo ""
echo "→ どちらも同じ結果だが、long optionは自己説明的。"
echo "  スクリプトの中では --all --long の方が意図が明確。"
echo ""

# --helpの統一性
echo "--- 3. --help の統一性を確認 ---"
echo ""
echo "あらゆるGNUプログラムで --help が動作する:"
echo ""
echo "[ls --help の冒頭]:"
ls --help 2>&1 | head -5
echo "..."
echo ""
echo "[grep --help の冒頭]:"
grep --help 2>&1 | head -5
echo "..."
echo ""

# -- （ダブルダッシュ）の重要性
echo "--- 4. -- （オプション終端マーカー）の重要性 ---"
echo ""
echo "ハイフンで始まるファイル名の扱い:"
touch /tmp/-test-file.txt
echo ""
echo "  rm -test-file.txt      → オプションとして解釈されてエラー"
echo "  rm -- -test-file.txt   → '--' 以降はオペランドとして扱われる"
echo ""
rm -- /tmp/-test-file.txt 2>/dev/null
echo "  grep -- '-pattern' file → '-pattern' がパターンとして扱われる"
echo ""
echo "→ POSIXガイドライン10: '--' はオプションの終わりを示す。"
echo "  この規約がなければ、'-'で始まるファイル名や検索パターンを"
echo "  安全に扱う方法がない。"
```

ハンズオンの自動セットアップスクリプトは `handson/command-line/21-cli-design-principles/setup.sh` を参照してほしい。

---

## 7. まとめと次回予告

### この回の要点

第一に、manページは1971年11月3日のUNIX Programmer's Manualに起源を持ち、NAME、SYNOPSIS、DESCRIPTIONというヘッダー構造を確立した。Doug McIlroyがマニュアルの品質を追求したことは、ドキュメンタビリティがソフトウェア設計の品質指標であるという洞察の先駆けだった。manページに明瞭に記述できないCLIは、設計に問題がある。

第二に、CLIオプションの設計にはUNIX伝統スタイル（単一文字、getopt）、GNU long optionスタイル（ダブルダッシュ、getopt_long）、サブコマンドスタイルの三つの流儀がある。それぞれに利点とトレードオフがあり、現実のツールはこれらを組み合わせている。POSIX Utility Syntax Guidelinesの13のガイドラインは、この設計空間に秩序を与える試みだ。

第三に、終了コード（0が成功、非0が失敗）とstdout/stderrの分離は、CLIツールがパイプラインとシェルスクリプトの中で正しく動作するための基盤だ。sysexits.h（1980年、Eric Allman）は終了コードの標準的な分類を定義し、失敗の種類を構造化した。

第四に、Jeff Dickeyの「12 Factor CLI Apps」（2018年）は、モダンなCLI設計の12原則を整理した。特に「stderrの活用」と「対話モードとパイプモードの出力切り替え」は、現代のCLIが満たすべき基本要件だ。

第五に、clig.dev（2020年）は「人間ファースト」の設計を掲げ、50年分のCLI設計の知恵を現代のコンテキストで再整理した。CLIのインターフェースはAPIであり、破壊的変更はSemantic Versioningで管理すべきだという視点は、CLIツールをソフトウェアエンジニアリングの正規の成果物として扱うことを意味する。

### 冒頭の問いへの暫定回答

「良いCLIツール」とは何か。その設計原則はどこから来たのか。

原則は、50年の歴史が蒸留したものだ。manページの構造は「ドキュメンタブルであれ」と教え、POSIX Utility Syntax Guidelinesは「オプションの形式を統一せよ」と教え、GNUコーディング標準は「発見可能であれ」と教える。終了コードとstderrの分離は「パイプラインの市民であれ」と教え、12 Factor CLIは「二つの顔を持て――人間向けと機械向け」と教える。

これらの原則は、個々には単純だ。--helpを実装する。終了コード0で成功を示す。エラーはstderrに出す。しかし、これらを一貫して守ることが、「使い捨てのスクリプト」と「50年使われるツール」を分ける。

あなたが次にCLIツールを作るとき、まずmanページを書くところから始めてみてほしい。SYNOPSISに書けないほど複雑な設計は、見直す価値がある。

### 次回予告

次回、第22回「AI+CLI――Claude Code, GitHub Copilot CLI, 自然言語シェルの時代」では、自然言語でコマンドを指示する時代に、CLIの知識は不要になるのかを問う。

Claude Codeを日常的に使っている私の経験から言えば、AIはCLIを「不要にする」のではなく「アクセシブルにする」。だが、AIが生成したコマンドが正しいかどうかを判断するには、ここまで20回にわたって語ってきたCLIの知識が不可欠だ。21回分の歴史の上に立って、AIとCLIの融合がどこに向かうのかを語る。

---

## 参考文献

- Dennis Ritchie, Ken Thompson, "UNIX Programmer's Manual, First Edition", November 3, 1971, <https://www.bell-labs.com/usr/dmr/www/1stEdman.html>
- Wikipedia, "Man page", <https://en.wikipedia.org/wiki/Man_page>
- Two-Bit History, "The Lineage of Man", 2017, <https://twobithistory.org/2017/09/28/the-lineage-of-man.html>
- manpages.bsd.lv, "History of UNIX Manpages", <https://manpages.bsd.lv/history.html>
- The Open Group, "POSIX.1-2024, Utility Conventions (Chapter 12)", <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html>
- GNU Project, "GNU Coding Standards: Command-Line Interfaces", <https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html>
- GNU Project, "GNU Coding Standards: --help", <https://www.gnu.org/prep/standards/html_node/_002d_002dhelp.html>
- GNU Project, "GNU Coding Standards: --version", <https://www.gnu.org/prep/standards/html_node/_002d_002dversion.html>
- Wikipedia, "Getopt", <https://en.wikipedia.org/wiki/Getopt>
- Eric S. Raymond, "Set the WABAC to 1984: Henry Spencer getopt", <http://esr.ibiblio.org/?p=7552>
- Jeff Dickey, "12 Factor CLI Apps", Medium, October 10, 2018, <https://medium.com/@jdxcode/12-factor-cli-apps-dd3c227a0e46>
- Aanand Prasad, Ben Firshman, Carl Tashian, Eva Parish, "Command Line Interface Guidelines", 2020, <https://clig.dev/>
- InfoQ, "CLI Guidelines Aim to Help You Write Better CLI Programs", December 17, 2020, <https://www.infoq.com/news/2020/12/cli-guidelines-qa/>
- FreeBSD, "sysexits(3)", <https://man.freebsd.org/cgi/man.cgi?query=sysexits>
- Wikipedia, "Exit status", <https://en.wikipedia.org/wiki/Exit_status>
- Wikipedia, "Standard streams", <https://en.wikipedia.org/wiki/Standard_streams>
- Wikipedia, "Troff", <https://en.wikipedia.org/wiki/Troff>
- Lars Wirzenius, "Unix command line conventions over time", 2022, <https://blog.liw.fi/posts/2022/05/07/unix-cli/>
- Julio Merino, "CLI design: Subcommand-based interfaces", 2013, <https://jmmv.dev/2013/09/cli-design-subcommand-based-interfaces.html>
- Chris Wellons, "Conventions for Command Line Options", 2020, <https://nullprogram.com/blog/2020/08/01/>
