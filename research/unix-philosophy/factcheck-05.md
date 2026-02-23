# ファクトチェック記録：第5回「パイプとフィルタ——ソフトウェア合成の原点」

## 1. Doug McIlroyのパイプ提案メモ（1964年）

- **結論**: Doug McIlroyは1964年10月11日付のBell Labs内部メモで、プログラム間のデータ受け渡しを「ガーデンホース」に喩えて提案した。原文は "We should have some ways of coupling programs like garden hose--screw in another segment when it becomes necessary to massage data in another way. This is the way of IO also."
- **一次ソース**: Dennis Ritchieのページに保存されたMcIlroyのメモ（"Prophetic Petroglyphs"として知られる）
- **URL**: <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/mdmpipe.html>
- **注意事項**: メモの日付は1964年10月11日。当時Bell LabsのコンピューティングはIBM 7090/7094でバッチモードが主流だった。パイプが実際にUNIXに実装されるのは1973年であり、約9年のギャップがある
- **記事での表現**: 「1964年10月11日、Doug McIlroyはBell Labsの内部メモに一つのアイデアを記した。"プログラムをガーデンホースのように繋ぎ合わせる方法が必要だ——データを別の方法で加工する必要が出てきたら、別のセグメントをねじ込めばいい"」

## 2. Ken Thompsonによるパイプの実装（1973年）

- **結論**: 1973年、Ken ThompsonはVersion 3 Unixにpipe()システムコールを追加した。McIlroyはこの実装を「one feverish night（熱狂的な一夜）」と表現した。翌日には「an unforgettable orgy of one-liners（忘れがたいワンライナーの饗宴）」が繰り広げられた
- **一次ソース**: M. Douglas McIlroy, "A Research UNIX Reader: Annotated Excerpts from the Programmer's Manual, 1971-1986"
- **URL**: <https://www.cs.dartmouth.edu/~doug/reader.pdf>
- **注意事項**: パイプの実装日は1973年1月15日前後とされる。Version 3 Unixは1973年2月リリース。McIlroyが名前「pipe」とシェル構文を提案し、Thompsonが「やる」と宣言した
- **記事での表現**: 「1973年のある夜、Ken Thompsonは熱狂的な作業でpipe()システムコールを実装し、シェルと複数のユーティリティにパイプを組み込んだ。翌日、Bell Labsの研究者たちは"忘れがたいワンライナーの饗宴"に興じた」

## 3. パイプ以前のデータ受け渡し——中間ファイル方式

- **結論**: パイプ導入以前、UNIXではプログラム間のデータ受け渡しに中間ファイル（一時ファイル）を使用していた。シェルが一つのプロセスの出力をファイルに書き、次のプロセスにそのファイルを読ませる方式。ディスク容量とI/Oオーバーヘッドがコストだった
- **一次ソース**: Pipeline (Unix) - Wikipedia、およびMcIlroyの各種インタビュー
- **URL**: <https://en.wikipedia.org/wiki/Pipeline_(Unix)>
- **注意事項**: 中間ファイル方式ではプロセスの並行実行ができず、全データがディスクに書かれてからでないと次の処理を開始できなかった
- **記事での表現**: 「パイプが存在しなかった時代、プログラムの出力を別のプログラムに渡すには中間ファイルを使うしかなかった」

## 4. パイプのシェル構文の変遷

- **結論**: Version 3 Unix（1973年）ではリダイレクト記号（< と >）を使うパイプ構文が導入されたが、数ヶ月で現在の形に改められた。Thompson が `|` 記号を提案し、Version 4 Unix（1973年11月）で採用された。`^`（キャレット）は `|` を入力できない端末向けの代替記号としてVersion 6まで使われた
- **一次ソース**: Thompson shell - Wikipedia、McIlroy "A Research UNIX Reader"
- **URL**: <https://en.wikipedia.org/wiki/Thompson_shell>
- **注意事項**: Bourne shellでも後方互換性のために `^` がパイプ記号として使えた。McIlroyは最初の構文がほぼ1ページの説明を要したのに対し、`|` 記号の導入で4文になったと記述
- **記事での表現**: 「最初のパイプ構文はリダイレクション記号を流用した冗長なものだった。Thompsonが `|` 記号を提案し、パイプラインの記述は4文で済むようになった」

## 5. pipe()システムコールとカーネルバッファの仕組み

- **結論**: pipe()システムコールは2つのファイルディスクリプタを返す。fd[0]が読み出し側、fd[1]が書き込み側。初期のUNIXではバッファサイズは504バイト、V7で4KB。Linux 2.6.11以前はシステムページサイズ（4096バイト）、2.6.11以降は16ページ（65,536バイト）。バッファはカーネルメモリ内の循環バッファとして実装
- **一次ソース**: pipe(7) - Linux manual page
- **URL**: <https://man7.org/linux/man-pages/man7/pipe.7.html>
- **注意事項**: Linux 2.6.35以降、fcntl(2)のF_GETPIPE_SZ/F_SETPIPE_SZでパイプ容量を動的に変更可能。PIPE_BUF（通常4096バイト）以下の書き込みはアトミックに行われる
- **記事での表現**: 「パイプのバッファはカーネルメモリ内に確保される。初期UNIXではわずか504バイト。現代のLinuxでは65,536バイト（16ページ）がデフォルトだ」

## 6. 名前付きパイプ（FIFO）

- **結論**: 名前付きパイプ（FIFO: First In, First Out）はファイルシステム上に存在するパイプであり、親子関係のないプロセス間で通信できる。mknod()またはmkfifo()で作成する。通常のパイプが無名で一時的なのに対し、名前付きパイプはファイルシステム上に永続する
- **一次ソース**: Named pipe - Wikipedia、fifo(7) - Linux manual page
- **URL**: <https://en.wikipedia.org/wiki/Named_pipe>
- **注意事項**: 古いシステムではmknodで作成、POSIX準拠のシステムではmkfifoが標準。名前付きパイプはVersion 7 Unix（1979年）で導入されたとする記述がある
- **記事での表現**: 「名前付きパイプはファイルシステム上に"名前"を持つパイプであり、血縁関係のないプロセス同士を接続できる」

## 7. パイプラインの並行実行

- **結論**: UNIXパイプラインの各コマンドは独立したプロセスとして同時に実行される。2番目のプロセスは1番目のプロセスが実行中に開始される。書き込み側がバッファを満たすとブロックし、読み出し側がバッファを空にするとブロックする。この同期機構により自動的なフロー制御が実現される
- **一次ソース**: Pipeline (Unix) - Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Pipeline_(Unix)>
- **注意事項**: マルチコアシステムでは各プロセスが異なるCPUコアで真に並列実行される可能性がある
- **記事での表現**: 「パイプラインの各コマンドは独立したプロセスとして並行に動作する。バッファが満杯になれば書き込みがブロックし、空になれば読み出しがブロックする。この仕組みが、明示的な同期なしに自動的なフロー制御を実現する」

## 8. フィルタパターンの確立

- **結論**: パイプの導入により、標準入力から読み標準出力に書くプログラム——「フィルタ」——の設計パターンが確立した。McIlroyの"A Research UNIX Reader"によれば、パイプの登場が「stdin/stdout設計を"哲学"の地位に引き上げた」。tr、m4、sedなどの後続プログラムはこのストリーム変換モデルを意識的に踏襲した
- **一次ソース**: M. Douglas McIlroy, "A Research UNIX Reader"
- **URL**: <https://www.cs.dartmouth.edu/~doug/reader.pdf>
- **注意事項**: Thompsonはパイプ実装時にprやovなどの既存ユーティリティもフィルタとして使えるよう改修した
- **記事での表現**: 「パイプの出現が、stdin/stdout設計を"哲学"の地位に引き上げた。以後のUNIXプログラムは、意識的にフィルタパターンに従うようになった」

## 9. 関数型プログラミングのパイプ演算子（|>）

- **結論**: F#に2003年に「パイプフォワード演算子」（|>）が標準ライブラリに追加された。UNIXシェルの `|` 演算子にインスパイアされたもの。その後、Elixir、OCaml、Julia、R（magrittr/dplyrの`%>%`）、さらにはJavaScript（TC39提案）やC++20のranges（operator|）にも波及
- **一次ソース**: Bozhidar Batsov, "The origin of the pipeline operator (|>)", 2025
- **URL**: <https://batsov.com/articles/2025/05/22/the-origin-of-the-pipeline-operator/>
- **注意事項**: UNIXパイプはプロセス間通信であり、|>演算子は関数合成の糖衣構文。メカニズムは全く異なるが、「データを変換のチェーンに流す」という発想は共通
- **記事での表現**: 「F#は2003年にパイプフォワード演算子（|>）を導入した。UNIXの `|` から着想を得たこの演算子は、Elixir、OCaml、Juliaへと広がり、関数合成の標準的な記法となった」

## 10. ETLパターンとパイプの接続

- **結論**: ETL（Extract, Transform, Load）パターンは、データを抽出・変換・格納する3段階の処理パイプラインである。UNIXパイプラインは「コマンドラインETL」と表現されることがある。パイプの `|` がETLツール（Tableau Prep、Alteryx等）のデータフロー設計と構造的に類似
- **一次ソース**: The Data School, "Unix Pipes - Command-Line ETL for Data Prep and Analysis"
- **URL**: <https://www.thedataschool.co.uk/matthias-albert/unix-pipes-command-line-etl-for-data-prep-and-analysis/>
- **注意事項**: UNIXパイプラインはストリーム処理（リアルタイム）、ETLは通常バッチ処理。ただしモダンなストリーミングETL（Apache Kafka、Apache Flink等）はUNIXパイプに近い逐次処理モデル
- **記事での表現**: 「UNIXパイプラインは"コマンドラインのETL"だ。データの抽出、変換、格納という流れを、`|` 一文字で接続する」
