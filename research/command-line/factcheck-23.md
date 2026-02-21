# ファクトチェック記録：第23回「コマンドラインの本質に立ち返る――テキスト・組み合わせ・自動化」

## 1. CTSS（Compatible Time-Sharing System）の開発時期と開発者

- **結論**: 1961年7月にIBM 709上でいくつかのタイムシェアリングコマンドが動作し始め、1961年11月にFernando J. CorbatóがMITで「Experimental Time-Sharing System」をデモンストレーションした。Marjorie DaggettとRobert Daleyとの共同開発。世界初のパスワードログイン、初期のテキストエディタ・メッセージングシステムを実装
- **一次ソース**: Wikipedia, "Compatible Time-Sharing System"; Multicians.org, "Compatible Time-Sharing System (1961-1973) Fiftieth Anniversary"
- **URL**: <https://en.wikipedia.org/wiki/Compatible_Time-Sharing_System>, <https://multicians.org/thvv/compatible-time-sharing-system.pdf>
- **注意事項**: 「世界初の汎用タイムシェアリングOS」とされるが、特殊目的のシステムでは他にも主張がある
- **記事での表現**: 「1961年、Fernando CorbatóがMITでCTSSをデモンストレーションした。コンピュータと人間が対話するという概念が、ここで初めて実用的に証明された」

## 2. UNIXパイプの発明（1973年1月）

- **結論**: Doug McIlroyが1964年に「プログラムを庭のホースのように連結すべきだ」と提案。Ken Thompsonが1973年1月15日にpipe()システムコールを一晩で実装（UNIX V3）。McIlroyの証言によれば「The next day saw an unforgettable orgy of one-liners」
- **一次ソース**: The New Stack, "Pipe: How the System Call That Ties Unix Together Came About"; Wikipedia, "Pipeline (Unix)"; Unix Heritage Wiki
- **URL**: <https://thenewstack.io/pipe-how-the-system-call-that-ties-unix-together-came-about/>, <https://en.wikipedia.org/wiki/Pipeline_(Unix)>
- **注意事項**: 日付の1月15日はUnix Heritage Wikiで言及されている
- **記事での表現**: 「1973年1月15日、Ken Thompsonは一晩でpipe()システムコールを実装した」

## 3. Doug McIlroyのUNIX哲学（1978年）

- **結論**: 1978年、Bell System Technical JournalにDoug McIlroyが「Make each program do one thing well」「Expect the output of every program to become the input to another, as yet unknown, program」などの原則を記述。1994年にPeter H. Salusが「A Quarter Century of UNIX」で三つの規則として要約：「Write programs that do one thing and do it well. Write programs to work together. Write programs to handle text streams, because that is a universal interface.」
- **一次ソース**: Doug McIlroy, Bell System Technical Journal, 1978; Peter H. Salus, "A Quarter Century of UNIX", 1994
- **URL**: <https://en.wikipedia.org/wiki/Unix_philosophy>, <https://en.wikiquote.org/wiki/Doug_McIlroy>
- **注意事項**: McIlroyの原典は1978年のBSTJだが、三行の要約はSalusによるもの
- **記事での表現**: McIlroyの原典とSalusの要約を区別して引用する

## 4. ANSI X3.64標準（1979年）

- **結論**: 最初の標準はECMA-48（1976年採択）。ANSI X3.64は1979年に採択。最初にこれをサポートした普及端末はDEC VT100（1978年導入）。1981年にFIPS publication 86として米国政府での使用が採択。1994年にANSIは国際標準ISO 6429を採用し自身の標準を撤回
- **一次ソース**: Wikipedia, "ANSI escape code"; NIST FIPS 86
- **URL**: <https://en.wikipedia.org/wiki/ANSI_escape_code>, <https://nvlpubs.nist.gov/nistpubs/Legacy/FIPS/fipspub86.pdf>
- **注意事項**: ECMA-48が先行しており、ANSI X3.64はその後の採択
- **記事での表現**: 「1979年にANSI X3.64として標準化されたエスケープシーケンスは、テキストストリームの上に視覚表現を構築するプロトコルだった」

## 5. GNUプロジェクトの発表（1983年9月27日）

- **結論**: 1983年9月27日、Richard M. Stallmanがnet.unix-wizardsニュースグループにGNUプロジェクトの初期アナウンスを投稿。GNU Manifestoは1985年3月にDr. Dobb's Journalに掲載。GNUプロジェクトの戦略は「まずツールを再実装し、最後にカーネルを作る」
- **一次ソース**: GNU Project, "The GNU Manifesto"; Wikipedia, "GNU Manifesto"
- **URL**: <https://www.gnu.org/gnu/manifesto.html>, <https://en.wikipedia.org/wiki/GNU_Manifesto>
- **注意事項**: アナウンスは1983年だがManifestoの出版は1985年
- **記事での表現**: 「1983年9月27日、Richard StallmanがGNUプロジェクトを発表した」

## 6. Plan 9とUTF-8の発明（1992年）

- **結論**: Plan 9は1980年代後半からBell Labsで開発開始。Rob Pike、Ken Thompson、Dave Presotto、Phil Winterbottomが主導。1992年にUTF-8がKen ThompsonとRob Pikeにより発明――ニュージャージーのダイナーのプレイスマットの上で設計された（1992年9月）。1992年9月8日午前3:22にKen Thompsonがメールで実装完了を報告。Plan 9は1992年に大学に配布開始
- **一次ソース**: Rob Pike, "The history of UTF-8 as told by Rob Pike"; Wikipedia, "Plan 9 from Bell Labs"
- **URL**: <https://doc.cat-v.org/bell_labs/utf-8_history>, <https://en.wikipedia.org/wiki/Plan_9_from_Bell_Labs>
- **注意事項**: UTF-8の設計は一晩で行われた
- **記事での表現**: 「1992年9月、Ken ThompsonとRob Pikeはニュージャージーのダイナーでプレイスマットの上にUTF-8を設計した」

## 7. Eric Raymond "The Art of UNIX Programming"（2003年）

- **結論**: 2003年出版。17のルールを定義（Rule of Modularity, Clarity, Composition, Separation, Simplicity, Parsimony, Transparency等）。UNIXの歴史と文化を1969年から2003年まで網羅
- **一次ソース**: Eric S. Raymond, "The Art of Unix Programming", 2003
- **URL**: <http://www.catb.org/esr/writings/taoup/html/>
- **注意事項**: なし
- **記事での表現**: 「Eric Raymondが2003年に『The Art of UNIX Programming』で17のルールとして体系化した」

## 8. Docker初期リリース（2013年3月）

- **結論**: 2013年3月13日（一部ソースでは15日）、PyCon Santa ClaraでSolomon Hykesがライトニングトークで発表。dotCloudの内部プロジェクトとして開発。オープンソースとして公開
- **一次ソース**: Wikipedia, "Docker (software)"; Docker Blog
- **URL**: <https://en.wikipedia.org/wiki/Docker_(software)>, <https://www.docker.com/blog/docker-nine-years-young/>
- **注意事項**: 正確な日付は3月13日と15日の二説あり
- **記事での表現**: 「2013年3月、Solomon HykesがPyConでDockerを発表した」

## 9. Kubernetes発表（2014年6月）

- **結論**: 2014年6月6日にGoogleが発表。Joe Beda、Brendan Burns、Craig McLuckieが考案・開発。6月10日にDockerCon 2014でEric Brewerが基調講演で発表。内部システムBorgの思想を受け継ぐ。2015年7月21日にv1.0リリースと同時にCNCF設立
- **一次ソース**: Wikipedia, "Kubernetes"; Google Cloud Blog
- **URL**: <https://en.wikipedia.org/wiki/Kubernetes>, <https://cloud.google.com/blog/products/containers-kubernetes/from-google-to-the-world-the-kubernetes-origin-story>
- **注意事項**: 発表日と初期コミット日が微妙に異なる（6月6日 vs 6月7日）
- **記事での表現**: 「2014年6月、GoogleがKubernetesをオープンソースとして発表した」

## 10. ripgrepの初期リリース（2016年9月）

- **結論**: Andrew Gallant（BurntSushi）により2016年9月にリリース。crates.ioでの最初のバージョンは2016年9月13日。初期ベンチマーク比較ブログ記事と同時公開
- **一次ソース**: GitHub, "BurntSushi/ripgrep"; Andrew Gallant Blog
- **URL**: <https://github.com/BurntSushi/ripgrep>, <https://burntsushi.net/ripgrep/>
- **注意事項**: なし
- **記事での表現**: 「2016年9月、Andrew Gallantがripgrepをリリースした」

## 11. SSH（Secure Shell）の発明（1995年）

- **結論**: 1995年、Helsinki University of TechnologyのTatu Ylönenが開発。大学ネットワークでのパスワードスニッフィング攻撃がきっかけ。1995年7月にフリーウェアとしてリリース。年末までに50か国2万ユーザーに普及。1995年12月にSSH Communications Securityを設立
- **一次ソース**: Wikipedia, "Secure Shell"; SSH.com
- **URL**: <https://en.wikipedia.org/wiki/Secure_Shell>
- **注意事項**: SSH-1が最初のバージョン
- **記事での表現**: 「1995年、Tatu YlönenがHelsinki University of TechnologyでSSHを開発した」

## 12. cronの起源（1975年）

- **結論**: Ken Thompsonが開発。1975年5月にリリース。1977年にUnix Version 7に含まれる。マルチユーザー版は1979年にPurdue大学のRobert Brownが開発。名前はギリシャ語のChronos（時間）に由来
- **一次ソース**: Wikipedia, "cron"
- **URL**: <https://en.wikipedia.org/wiki/Cron>
- **注意事項**: 最初のcronは非常にシンプルな実装だった
- **記事での表現**: 「1975年、Ken Thompsonが開発したcronは、コマンドの自動実行を時間軸上に配置する仕組みだった」
