# ファクトチェック記録：第7回「パイプの発明――1973年1月のコンピュータサイエンス史」

## 1. Doug McIlroyのパイプ構想メモ（1964年）

- **結論**: McIlroyは1964年10月11日付のBell Labs内部メモで、プログラム間をパイプで接続する構想を記した。「庭のホース」の比喩が有名。メモの10ページ目がDennis Ritchieのオフィスの壁に磁石で貼られていた
- **一次ソース**: Dennis Ritchie, "Prophetic Petroglyphs", Bell Labs; M. D. McIlroy, internal Bell Labs memo, October 11, 1964
- **URL**: <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/mdmpipe.html>
- **注意事項**: 原文には "when it becomes when it becomes" という重複があるが、これはタイプライターで打たれた原本のままの表記。引用は "We should have some ways of connecting programs like garden hose--screw in another segment when it becomes necessary to massage data in another way." が一般的
- **記事での表現**: 1964年10月11日、Bell LabsのDoug McIlroyは内部メモで「プログラム同士を庭のホースのように接続する方法があるべきだ」と書いた

## 2. Ken Thompsonによるパイプ実装（1973年1月15日）

- **結論**: Ken Thompsonは1973年1月15日（日付は記録されている）の一夜でpipeシステムコールを実装し、シェルに組み込み、pr、ovなどのユーティリティをフィルタとして使えるよう修正した。Third Edition Unix（1973年2月）に収録
- **一次ソース**: Unix Heritage Wiki, "features:pipes"; Peter H. Salus, "A Quarter Century of Unix", 1994; Dennis Ritchie, "The Evolution of the Unix Time-sharing System"
- **URL**: <https://wiki.tuhs.org/doku.php?id=features:pipes>, <https://cscie26.dce.harvard.edu/~dce-lib113/reference/unix/unix2.html>
- **注意事項**: "one feverish night" はMcIlroyの証言に基づく。Third Edition Unixのカーネルソースコードは現存しない
- **記事での表現**: 1973年1月15日、Ken Thompsonは一夜でpipeシステムコールを書き、シェルに統合し、複数のユーティリティをフィルタ対応に改修した

## 3. McIlroyの"wonderful orgy"エピソード

- **結論**: パイプ実装の翌日、Bell Labsのチームでワンライナーの「饗宴」が起きた。McIlroyは「wonderful orgy of 'look at this one'」と表現。一週間以内に秘書までもがパイプを使い始めた
- **一次ソース**: McIlroy oral history, Computer History Museum; Peter H. Salus, "A Quarter Century of Unix"
- **URL**: <https://www.computerhistory.org/collections/catalog/102740539/>
- **注意事項**: "even our secretaries were using pipes" という証言あり
- **記事での表現**: 翌朝、チームはワンライナーの饗宴に沸いた。「これを見ろ、あれを見ろ」の応酬が終日続き、一週間もすれば秘書までパイプを使っていた

## 4. McIlroyのUNIX哲学の原典引用

- **結論**: McIlroyは1978年にBSTJ（Bell System Technical Journal）でUNIXの「特徴的なスタイル」として原則を記述。1994年にPeter H. Salusが "A Quarter Century of Unix" で三箇条に要約: "Write programs that do one thing and do it well. Write programs to work together. Write programs to handle text streams, because that is a universal interface."
- **一次ソース**: M. D. McIlroy, BSTJ, 1978; Peter H. Salus, "A Quarter Century of Unix", Addison-Wesley, 1994
- **URL**: <https://en.wikipedia.org/wiki/Unix_philosophy>
- **注意事項**: 三箇条の要約はSalus版が最も広く引用される。McIlroy自身の1978年の記述はより詳細で多数の原則を含む
- **記事での表現**: McIlroyの思想をPeter H. Salusが1994年に三箇条に凝縮した引用を使用

## 5. UNIXパイプの技術的実装

- **結論**: 初期のpipe(2)システムコールはファイルディスクリプタを1つだけ返し、同じfdで読み書きした。バッファサイズは504バイト。現代Linuxではpipe(2)は2つのfd（読み取り用と書き込み用）を返す。バッファはカーネル管理のリングバッファ
- **一次ソース**: Unix Heritage Wiki; Dennis Ritchie, "The Evolution of the Unix Time-sharing System"
- **URL**: <https://toroid.org/unix-pipe-implementation>, <https://biriukov.dev/docs/fd-pipe-session-terminal/2-pipes/>
- **注意事項**: 初期実装の504バイトバッファは、PDP-11のメモリレイアウトに起因する可能性がある
- **記事での表現**: 初期のpipeシステムコールは1つのファイルディスクリプタを返すだけで、バッファサイズは504バイトだった

## 6. パイプ記法の変遷

- **結論**: 初期のパイプ記法は `>` を使用した（例: `ls > pr > lpr`）。これはI/Oリダイレクションと同じ文字を使用しており、曖昧だった。数ヶ月後に `|` 記法に置き換えられた（Thompson考案、McIlroyがクレジット）。Fourth Edition Unix（1973年11月）のmanページで `|` が記述
- **一次ソース**: Dennis Ritchie, "The Evolution of the Unix Time-sharing System"; Wikipedia, "Pipeline (Unix)"
- **URL**: <https://en.wikipedia.org/wiki/Pipeline_(Unix)>
- **注意事項**: `|` 記法はThompsonによるもの。Version 4 manページで正式化
- **記事での表現**: 当初パイプは `>` で記述されたが、リダイレクションとの曖昧さから数ヶ月で `|`（バーティカルバー）に変更された

## 7. stdin/stdout/stderrの設計史

- **結論**: stdinとstdoutはパイプと同時期に概念化。stderrは後から追加された。Dennis Ritchieによると、写植機の出力にエラーメッセージが混入し、高価な写植用紙が無駄になったことがstderr追加の動機
- **一次ソース**: Wikipedia, "Standard streams"; Dennis Ritchie, various writings
- **URL**: <https://en.wikipedia.org/wiki/Standard_streams>
- **注意事項**: stderrの追加時期は正確にはVersion 5〜6頃と推定される
- **記事での表現**: stderrは写植機の出力にエラーメッセージが混入する問題を解決するために追加された

## 8. 名前付きパイプ（FIFO）の導入

- **結論**: 名前付きパイプ（FIFO）はUNIX System III（1982年リリース）で導入された。ファイルシステム上に特殊ファイルとして存在し、無関係なプロセス間の通信を可能にする
- **一次ソース**: Wikipedia, "Named pipe"; Wikipedia, "System III"
- **URL**: <https://en.wikipedia.org/wiki/Named_pipe>
- **注意事項**: mkfifo()関数はPOSIXで標準化。mknod()でも作成可能
- **記事での表現**: 1982年のUNIX System IIIで名前付きパイプ（FIFO）が導入された

## 9. Linuxパイプバッファサイズ

- **結論**: Linux 2.6.11以前はシステムページサイズ（通常4096バイト）。Linux 2.6.11以降は16ページ = 65,536バイト（64KiB）。PIPE_BUFは4096バイト（これ以下の書き込みはアトミック保証）。Linux 2.6.35以降はfcntl(2)のF_GETPIPE_SZ/F_SETPIPE_SZで変更可能
- **一次ソース**: pipe(7) Linux manual page
- **URL**: <https://man7.org/linux/man-pages/man7/pipe.7.html>
- **注意事項**: PIPE_BUFとパイプ容量（capacity）は異なる概念
- **記事での表現**: 現代のLinuxではパイプバッファは64KiB、アトミック書き込み保証は4KiB（PIPE_BUF）

## 10. Unix Version 3 / Version 4の時系列

- **結論**: Third Edition Unix: 1973年2月。パイプを含む最初のバージョン。カーネルはアセンブリ言語。Fourth Edition Unix: 1973年11月。カーネルがCで書き直された最初のバージョン。`|` パイプ記法がmanページに記載
- **一次ソース**: Unix Heritage Wiki; Diomidis Spinellis, "unix-history-make" repository; Computer History Museum
- **URL**: <https://github.com/dspinellis/unix-history-make/blob/master/releases.md>
- **注意事項**: Third Edition Unixのカーネルソースは失われている。C言語への書き直しはVersion 4で行われた
- **記事での表現**: 1973年2月のThird Edition Unixでパイプが初めて搭載され、同年11月のFourth Editionで `|` 記法とCカーネルが登場した
