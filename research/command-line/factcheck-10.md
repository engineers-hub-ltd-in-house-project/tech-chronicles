# ファクトチェック記録：第10回「UNIX哲学の功罪――『一つのことをうまくやれ』は本当に正しいか」

## 1. Doug McIlroyのUNIX哲学原典（1978年）

- **結論**: McIlroyはBell System Technical Journal Vol.57, No.6, 1978年7-8月号 pp.1899-1904のForewordでUNIX哲学を文書化した。共著者はE. N. PinsonとB. A. Tague
- **一次ソース**: M. Douglas McIlroy, E. N. Pinson, B. A. Tague, "UNIX Time-Sharing System: Foreword", The Bell System Technical Journal, Vol.57, No.6, Part 2, July-August 1978, pp.1899-1904
- **URL**: <https://onlinelibrary.wiley.com/doi/10.1002/j.1538-7305.1978.tb02135.x>
- **注意事項**: 原文は "Make each program do one thing well" であり、"Do one thing and do it well" はPeter Salusによる後年の要約
- **記事での表現**: McIlroyが1978年のBSTJ Forewordで述べた原則として引用。原文ママで記載

## 2. Peter Salusによる要約（1994年）

- **結論**: Peter H. Salusは1994年の著書で McIlroy の哲学を3点に要約した。(1) Write programs that do one thing and do it well. (2) Write programs to work together. (3) Write programs to handle text streams, because that is a universal interface.
- **一次ソース**: Peter H. Salus, "A Quarter Century of Unix", Addison-Wesley, 1994
- **URL**: <https://en.wikipedia.org/wiki/Unix_philosophy>
- **注意事項**: この3点セットが最も広く引用される「UNIX哲学」の定義。McIlroyの1978年原文はより詳細で5項目ある
- **記事での表現**: Salusの要約版と McIlroy の原典版を並列し、簡略化の過程を示す

## 3. Eric Raymond "The Art of UNIX Programming"（2003年）

- **結論**: Eric S. Raymondは2003年にAddison-Wesley Professionalから出版。UNIX哲学を17のルール（Rule of Modularity, Clarity, Composition, Separation, Simplicity, Parsimony, Transparency, Robustness, Representation, Least Surprise, Silence, Repair, Economy, Generation, Optimization, Diversity, Extensibility）に整理した
- **一次ソース**: Eric S. Raymond, "The Art of UNIX Programming", Addison-Wesley Professional, 2003, ISBN 0-13-142901-9
- **URL**: <http://www.catb.org/esr/writings/taoup/html/>
- **注意事項**: オンラインで全文公開されている。17のルールはChapter 1に記載
- **記事での表現**: Raymondの体系化としてルール名を列挙し、McIlroyの原典との距離を論じる

## 4. Rob Pike "Notes on Programming in C"（1989年）

- **結論**: Rob Pikeは1989年2月21日付で "Notes on Programming in C" を執筆。5つのプログラミングルールを提示した。Rule 5 "Data dominates" が特に有名。Ken Thompsonはルール3と4を "When in doubt, use brute force" と言い換えた
- **一次ソース**: Rob Pike, "Notes on Programming in C", February 21, 1989
- **URL**: <https://www.lysator.liu.se/c/pikestyle.html>
- **注意事項**: 厳密にはUNIX哲学への「批判」ではなく、プログラミングスタイルに関するエッセイ。ただし「単純さ」を重視する姿勢はUNIX哲学の過度な教条化への暗黙の批判と読める
- **記事での表現**: Pikeの5つのルールを紹介し、「単純さ」と「データ中心」の思想がUNIX哲学の別側面であることを示す

## 5. Plan 9 from Bell Labs

- **結論**: Plan 9はBell Labsで1980年代半ばから開発。初版1992年（大学向け）、第2版1995年、第3版2000年（オープンソースライセンス）、第4版2002年4月（Lucent Public License 1.02）。2021年3月23日にPlan 9 FoundationへMITライセンスで移管
- **一次ソース**: Rob Pike, Dave Presotto, Sean Dorward, Bob Flandrena, Ken Thompson, Howard Trickey, Phil Winterbottom, "Plan 9 from Bell Labs", Computing Systems, Vol.8, No.3, 1995
- **URL**: <https://9p.io/plan9/about.html>, <https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs>
- **注意事項**: "Everything is a file" をUNIXより徹底し、ネットワークリソースもファイルとして扱う。9Pプロトコルとper-process namespacesが核心設計
- **記事での表現**: UNIX哲学を極限まで推し進めた実験として紹介。per-process namespacesがLinuxのnamespacesに影響を与えた点に言及

## 6. Jeffrey Snover "Monad Manifesto"とPowerShell

- **結論**: Jeffrey Snoverは2002年8月8日に "Monad Manifesto" を執筆。テキストベースパイプラインの「prayer-based parsing」を批判し、.NETオブジェクトのパイプラインを提唱した。PowerShell 1.0は2006年11月14日にリリース
- **一次ソース**: Jeffrey P. Snover, "Monad Manifesto", August 8, 2002
- **URL**: <https://www.jsnover.com/Docs/MonadManifesto.pdf>
- **注意事項**: "prayer-based parsing" はSnoverの造語で、テキストパイプラインの脆弱性を揶揄した表現
- **記事での表現**: UNIX哲学の「テキストストリーム」に対する根本的批判としてSnoverのManifestoを引用

## 7. jq（2012年）

- **結論**: Stephen Dolanが2012年10月に初版リリース。コマンドラインJSONプロセッサ。「sed for JSON data」と称される。ポータブルCで実装、ランタイム依存なし。元々はHaskellで実装されていた
- **一次ソース**: Stephen Dolan, jq project
- **URL**: <https://jqlang.github.io/jq/>, <https://github.com/jqlang/jq>
- **注意事項**: 2023年にメンテナンスがjqlangコミュニティに移管された
- **記事での表現**: テキストストリームの限界に対する解としてjqの登場を位置づける

## 8. yq

- **結論**: Mike Farahが開発したGo言語製のYAML/JSON/XML/CSV/TOMLプロセッサ。jqライクな構文でYAMLを操作する。「jq or sed of yaml files」を目指す。別途Pythonベースのyq（kislyuk/yq）も存在する
- **一次ソース**: Mike Farah, yq project
- **URL**: <https://github.com/mikefarah/yq>
- **注意事項**: Go版（mikefarah/yq）とPython版（kislyuk/yq）の2系統がある。記事ではGo版を主に扱う
- **記事での表現**: jqの思想をYAMLに拡張したツールとして簡潔に言及

## 9. Nushell

- **結論**: Jonathan Turner、Yehuda Katz、Andres Robalinoが2019年8月23日にNushellを公開。Rust製。PowerShellの構造化パイプラインの思想を関数型アプローチで再実装。テキストではなく構造化データ（テーブル）をパイプラインで渡す
- **一次ソース**: Jonathan Turner, "Introducing nushell", Nushell Blog, August 23, 2019
- **URL**: <https://www.nushell.sh/blog/2019-08-23-introducing-nushell.html>
- **注意事項**: YehudaKatzがPowerShellのデモを見せ、「構造化シェルの思想を関数型にできないか」と提案したのが発端
- **記事での表現**: UNIX哲学のテキストストリーム前提を構造化データで置き換える試みとして紹介

## 10. JSON（Douglas Crockford、2001年）

- **結論**: Douglas Crockfordが2001年にJSON（JavaScript Object Notation）を開発。2001年4月に最初のJSONメッセージが送信された。2002年にjson.orgドメインを登録し仕様を公開。RFC 4627（2006年）、ECMA-404（2013年）、RFC 8259（2017年）で標準化
- **一次ソース**: Douglas Crockford, json.org; IETF RFC 8259; ECMA-404
- **URL**: <https://www.json.org/>, <https://datatracker.ietf.org/doc/html/rfc8259>
- **注意事項**: CrockfordはJSONを「発見した」と表現している（「発明した」ではない）
- **記事での表現**: テキストストリームと構造化データの間を埋める「構造化テキスト」としてのJSONの登場

## 11. bashのpipefail

- **結論**: `set -o pipefail` はbash固有のオプション。パイプライン中で最後にゼロ以外の終了コードを返したコマンドの終了コードをパイプライン全体の終了コードとする。POSIX shには存在しない（dashは非対応）
- **一次ソース**: GNU Bash Manual
- **URL**: <https://www.gnu.org/software/bash/manual/bash.html>
- **注意事項**: パイプラインのデフォルト動作は最後のコマンドの終了コードのみを返す。これはUNIXパイプのエラー処理の脆弱性の一例
- **記事での表現**: UNIXパイプラインのエラー処理の脆弱性の具体例として使用

## 12. Ken ThompsonのUNIX哲学

- **結論**: Ken Thompsonは "When in doubt, use brute force" という格言で知られる。これはRob Pikeのルール3（小さいnにはfancyなアルゴリズムは不要）とルール4（fancyなアルゴリズムはバグが多い）の言い換え
- **一次ソース**: Eric S. Raymond, "The Art of UNIX Programming", Chapter 1
- **URL**: <http://www.catb.org/esr/writings/taoup/html/ch01s06.html>
- **注意事項**: Thompson自身の著作としての出典は明確でなく、RaymondがTAoUPで引用した形で広まった
- **記事での表現**: Thompson、Pike、McIlroyそれぞれの「UNIX哲学」の微妙な違いを示す一例として使用
