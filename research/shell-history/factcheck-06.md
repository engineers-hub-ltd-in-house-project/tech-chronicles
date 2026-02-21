# ファクトチェック記録：第6回「パイプとUNIX哲学――テキストストリームの天才性と限界」

## 1. Doug McIlroyの「ガーデンホース」メモ（1964年10月11日）

- **結論**: McIlroyは1964年10月11日付のBell Labs内部メモで、プログラムを「ガーデンホース」のように接続する構想を提案した。原文は "We should have some ways of connecting programs like garden hose--screw in another segment when it becomes necessary to massage data in another way."
- **一次ソース**: Dennis Ritchieが保存した McIlroy のメモ "Prophetic Petroglyphs"
- **URL**: <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/mdmpipe.html>
- **注意事項**: メモが書かれた1964年当時、Bell Labsの計算はIBM 7090/7094でのバッチモードが中心だった。パイプが実装されたのは約9年後の1973年
- **記事での表現**: 1964年10月11日、Doug McIlroyがBell Labs内部メモで「プログラムをガーデンホースのように接続する」構想を提案した

## 2. Ken Thompsonによるパイプの実装（1973年、UNIX V3）

- **結論**: Ken ThompsonはVersion 3 Unix（1973年2月）でpipe()システムコールを実装した。McIlroyによれば「一晩の熱狂的な作業」で実装された。パイプの作成日は1973年1月15日とされる
- **一次ソース**: UNIX Heritage Wiki, Pipeline (Unix) - Wikipedia, McIlroyの証言
- **URL**: <https://wiki.tuhs.org/doku.php?id=features:pipes>, <https://en.wikipedia.org/wiki/Pipeline_(Unix)>
- **注意事項**: McIlroyの提案とは若干異なる実装をThompsonが行った（「少し良いもの」を発明した）。ThompsonはV3で既存の多くのプログラムも同じ夜に修正した
- **記事での表現**: 1973年1月15日、Ken Thompsonが「一晩の熱狂的な作業」でpipe()システムコールを実装し、同時に多数のユーティリティを書き換えた

## 3. パイプ記号の変遷（`>` → `|`）

- **結論**: 当初のパイプ記号は`>`だったが、リダイレクションと紛らわしいためThompsonが`|`記号に変更した。McIlroyはThompsonに`|`記法の功績を帰している。Version 4のマニュアルではパイプ構文の記述が大幅に簡素化された
- **一次ソース**: Pipeline (Unix) - Wikipedia, Dennis Ritchieの記録
- **URL**: <https://en.wikipedia.org/wiki/Pipeline_(Unix)>
- **注意事項**: Thompsonは「ロンドンでの講演のために」記号を変更した。醜い構文を見せたくなかったため
- **記事での表現**: ThompsonはV4でパイプ記号を`|`に変更した。McIlroyはこの記法の功績をThompsonに帰している

## 4. Doug McIlroyのUNIX哲学（1978年）

- **結論**: McIlroyは1978年にBell System Technical Journalの前書きでUNIX哲学を定式化した。Peter H. SalusのA Quarter Century of UNIX（1994年）に引用された定式は "Write programs that do one thing and do it well. Write programs to work together. Write programs to handle text streams, because that is a universal interface."
- **一次ソース**: Peter H. Salus, "A Quarter Century of UNIX", Addison-Wesley, 1994; BSTJ, 1978
- **URL**: <https://en.wikipedia.org/wiki/Unix_philosophy>
- **注意事項**: 「テキストストリームを扱え、それが普遍的インタフェースだから」という表現は、パイプの存在を前提とした哲学であり、パイプ実装後に定式化された
- **記事での表現**: 1978年、McIlroyはUNIX哲学を「テキストストリームを扱うプログラムを書け、それが普遍的インタフェースだから」と定式化した

## 5. パイプのカーネル実装（バッファサイズの変遷）

- **結論**: UNIX V6ではパイプバッファはルートデバイス上のiノードで表現され、固定サイズ4096バイトだった。V7でも4KBが伝統的サイズ。Linuxカーネル2.6.11以前はシステムページサイズ（4096バイト）、2.6.11以降は16ページ=65,536バイトに拡大。POSIX.1はPIPE_BUFとして最低512バイトを要求し、Linuxでは4,096バイト（アトミック書き込みの最大サイズ）
- **一次ソース**: pipe(7) Linux manual page, Baeldung on Linux
- **URL**: <https://man7.org/linux/man-pages/man7/pipe.7.html>, <https://www.baeldung.com/linux/pipe-buffer-capacity>
- **注意事項**: PIPE_BUF（アトミック書き込み保証サイズ）とパイプ容量（バッファ全体サイズ）は異なる概念。現代Linuxではfcntl(2)でパイプ容量の取得・設定が可能（2.6.35以降）
- **記事での表現**: UNIX V6のパイプバッファは4096バイト。現代Linux（2.6.11以降）では65,536バイト（16ページ）に拡大された

## 6. jq（JSON処理ツール、Stephen Dolan, 2012年）

- **結論**: jqはStephen Dolanが開発し、2012年10月にバージョン1.0をリリースした。初期コミットは2012年7月18日。「JSONのためのsed」と形容される。ポータブルCで書かれ、ランタイム依存がゼロ
- **一次ソース**: jq GitHub repository, Wikipedia
- **URL**: <https://github.com/jqlang/jq>, <https://en.wikipedia.org/wiki/Jq_(programming_language)>
- **注意事項**: jqは現在jqlangコミュニティによってメンテナンスされている。最新安定版は1.7.1（2023年12月リリース）
- **記事での表現**: 2012年、Stephen DolanがjqをリリースしJSON処理をパイプラインに組み込めるようにした

## 7. yq（YAML処理ツール、Mike Farah）

- **結論**: yqはMike Farahが開発したGoベースのコマンドラインYAML/JSON/XML/CSV/TOMLプロセッサ。jqライクな構文を使用。単一バイナリで依存なし
- **一次ソース**: GitHub - mikefarah/yq
- **URL**: <https://github.com/mikefarah/yq>
- **注意事項**: Python版のyq（kislyuk/yq）も存在する。Mike Farah版はGoで書かれ、V4でjqにより近い構文になった
- **記事での表現**: yq（Mike Farah開発）はjqの構文をYAMLに拡張し、構造化データ処理の橋渡しツールとなった

## 8. xsv（CSV処理ツール、Andrew Gallant/BurntSushi）

- **結論**: xsvはAndrew Gallant（BurntSushi）が開発したRust製の高速CSVコマンドラインツールキット。MIT/UNLICENSEのデュアルライセンス。「コマンドはシンプル、高速、合成可能であるべき」という設計思想
- **一次ソース**: GitHub - BurntSushi/xsv
- **URL**: <https://github.com/BurntSushi/xsv>
- **注意事項**: 最新版は0.13.0。Andrew GallantはripgrepやBurntSushi/regexの作者としても知られる
- **記事での表現**: xsv（Andrew Gallant開発、Rust製）はCSVデータの高速処理を提供する

## 9. Nushell（構造化データパイプライン、2019年）

- **結論**: Nushellは Jonathan Turner, Yehuda Katz, Andres Robalinoが開発。初期コミットは2019年5月10日。2019年8月23日に公式発表。Rustで書かれ、Unix哲学のパイプライン + PowerShellの構造化データアプローチ + 関数型プログラミングの融合を目指す
- **一次ソース**: Nushell公式ブログ "Introducing nushell"
- **URL**: <https://www.nushell.sh/blog/2019-08-23-introducing-nushell.html>
- **注意事項**: Yehuda KatzがPowerShellの構造化シェルの考え方をTurnerに見せ、それをより関数的にするプロジェクトへの参加を提案したことが契機。NushellではJSON, TOML, YAML等の構造化データをテーブルとして扱える
- **記事での表現**: 2019年、Jonathan Turner, Yehuda Katz, Andres Robalinoが開発したNushellは、テキストストリームの代わりに構造化データ（テーブル）をパイプラインの単位とした

## 10. テキストストリームの暗黙の契約

- **結論**: UNIXのテキストストリームには「1行1レコード、フィールドは空白またはタブ区切り」という暗黙の契約がある。この契約はどのRFCにも標準化されておらず、ツール間の慣習として成立している。awk, cut, sort, join等のツールはこの前提で動作する
- **一次ソース**: "The UNIX Programming Environment" by Kernighan & Pike (1984)
- **URL**: N/A（書籍）
- **注意事項**: この暗黙契約が崩れるのがJSON/YAML/Protocol Buffers等の構造化データを扱う場合。改行やフィールド区切りが一定でないため、従来のテキスト処理ツールでは適切に扱えない
- **記事での表現**: テキストストリームの暗黙契約——「1行1レコード、フィールドは空白区切り」——はRFCではなく慣習として成立した

## 11. パイプとサブプロセスの関係（fork/exec）

- **結論**: パイプラインの各コマンドは独立したプロセスとして実行され、fork()でプロセスが生成され、exec()でコマンドが実行される。パイプはカーネルが提供するプロセス間通信（IPC）の仕組みであり、書き手プロセスと読み手プロセスの間にバッファを置く。バッファが満杯になると書き手はブロックし、空になると読み手がブロックする
- **一次ソース**: K. Thompson, "UNIX Implementation", BSTJ, Vol. 57, No. 6, 1978
- **URL**: <https://users.soe.ucsc.edu/~sbrandt/221/Papers/History/thompson-bstj78.pdf>
- **注意事項**: パイプのバックプレッシャー（背圧）はバッファのフル/エンプティで自動的に制御される。これは明示的なフロー制御なしにプロデューサー/コンシューマーパターンを実現する
- **記事での表現**: パイプはカーネルが管理するバッファを介してプロセス間でデータを受け渡す。バッファが満杯で書き手ブロック、空で読み手ブロックという背圧機構が自動的に働く
