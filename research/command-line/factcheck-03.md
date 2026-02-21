# ファクトチェック記録：第3回「対話の始まり――CTSSとタイムシェアリングの革命」

## 1. J.C.R. Lickliderの「Man-Computer Symbiosis」（1960年）

- **結論**: 1960年3月、IRE Transactions on Human Factors in Electronics, volume HFE-1, pages 4-11に発表。人間とコンピュータの補完的関係を構想し、リアルタイムの対話的コンピューティングの思想的基盤を提供した。Lickliderは後にARPA（後のDARPA）の情報処理技術局（IPTO）局長（1962-1964年）として、MITのProject MACなどタイムシェアリング研究に資金を提供した
- **一次ソース**: J.C.R. Licklider, "Man-Computer Symbiosis", IRE Transactions on Human Factors in Electronics, 1960
- **URL**: <https://groups.csail.mit.edu/medg/people/psz/Licklider.html>
- **注意事項**: 論文はCTSSの開発に直接影響したかの因果関係証明は困難だが、時代の知的気運として連動している
- **記事での表現**: 1960年、Lickliderは「人間とコンピュータの共生」を論文で構想した。バッチ処理全盛の時代に、リアルタイムの対話を夢見た先見の論文である

## 2. John McCarthyのタイムシェアリング提案（1959年）

- **結論**: 1959年1月1日、John McCarthyはMITのP.M. Morse教授宛のメモ「A Time Sharing Operator Program for our Projected IBM 709」を書いた。汎用コンピュータのタイムシェアリングを最初に記述した文書とされる。同年、英国のChristopher Stracheyも独立にタイムシェアリングの概念を記述している
- **一次ソース**: John McCarthy, "Memorandum to P. M. Morse Proposing Time-Sharing", 1959
- **URL**: <http://jmc.stanford.edu/computing-science/timesharing-memo.html>
- **注意事項**: McCarthyの主張は口頭で行われることが多く、FanoとCorbatoが1966年のScientific American記事でStracheyにクレジットを与えた際、McCarthyが異議を唱えた経緯がある
- **記事での表現**: 1959年、McCarthyはMITで「タイムシェアリング・オペレータプログラム」のメモを書き、複数ユーザーが1台のコンピュータを同時に使う構想を最初に文書化した

## 3. CTSS（Compatible Time-Sharing System, 1961年）

- **結論**: MITのFernando Corbato（計算センター副所長）が、Marjorie DaggettおよびRobert Daleyと共に開発。1961年11月にMITのIBM 709上で初の公開デモンストレーション。世界初の汎用タイムシェアリングOSとされる。1962年にIBM 7090、後にIBM 7094に移行。1963年夏にMIT計算センターで定常サービス開始、1968年まで運用。「Compatible」の名称は、バッチモードで動作するバイナリプログラムが対話的にも実行可能であることに由来
- **一次ソース**: Multicians.org, "Compatible Time-Sharing System (1961-1973) Fiftieth Anniversary"
- **URL**: <https://multicians.org/thvv/compatible-time-sharing-system.pdf>
- **注意事項**: 1961年11月のデモは4台のFlexowriter端末を使用し4人の同時ユーザーを実現。初期のコンソールコマンドはlogin, logout, input, edit, fap, mad, madtrn, load, use, start, skippm, listf, printf, xdump, xundump
- **記事での表現**: 1961年11月、CorbatoはMITでCTSSの公開デモンストレーションを行った。4人のユーザーが同時に1台のIBM 709を対話的に使用する、世界初の汎用タイムシェアリングの実証だった

## 4. CTSSの技術的詳細（メモリ構成・スケジューリング）

- **結論**: CTSSはIBM 7094を改造し、通常1バンクのコアメモリを2バンク（各32,768語、36ビットワード）に拡張した。Aバンクにスーパーバイザ（OS）、Bバンクにユーザープログラムを配置。メモリ境界レジスタでユーザープログラムのアクセスをBバンクに制限。プロセッサ割り当てスケジューリングはタイムクォンタム200ミリ秒、多段フィードバックキューで制御。スーパーバイザはソフトウェア割り込みでのみ呼び出し可能（現代OSのプロテクトモードカーネルに相当）
- **一次ソース**: Multicians.org, "The IBM 7094 and CTSS"; Wikipedia, "Compatible Time-Sharing System"
- **URL**: <https://www.multicians.org/thvv/7094.html>, <https://en.wikipedia.org/wiki/Compatible_Time-Sharing_System>
- **注意事項**: IBM 7094への特別なハードウェア改造（RPQ: Request for Price Quotation）はMIT専用。メモリ保護、クロック割り込み、特定命令のトラップ機能が追加された
- **記事での表現**: CTSSのIBM 7094は2バンクのコアメモリを持ち、Aバンクにスーパーバイザ、Bバンクにユーザープログラムを配置した。200ミリ秒のタイムクォンタムと多段フィードバックキューによるスケジューリングを実装した

## 5. CTSSと世界最初のパスワードログイン

- **結論**: CTSSは世界で最初にパスワードログインを実装したコンピュータシステムとされる。Fernando Corbatoが考案。個人のファイルを保護するため、ユーザーが自分のファイルにのみアクセスできるようにする目的だった。パスワードは平文で保存されており、ハッシュ化や暗号化はなかった。1966年春、MITの学生Allan Scherrがマスターパスワードファイルの印刷を要求し、全ユーザーのパスワードを入手した——世界最初のパスワードハッキングとされる
- **一次ソース**: CyberNews, "First computer password shaped our digital world"; Wikipedia, "Password"
- **URL**: <https://cybernews.com/security/first-computer-password/>, <https://en.wikipedia.org/wiki/Password>
- **注意事項**: 最初に使われたパスワードの具体的な文字列は記録に残っていない
- **記事での表現**: CTSSは世界初のパスワードログインシステムを実装した。ファイルのプライバシー保護が目的だったが、パスワードは平文保存であり、1966年には早くも最初のパスワードハッキングが発生した

## 6. Fernando Corbatoの経歴とチューリング賞

- **結論**: Fernando Jose Corbato（1926年7月1日 - 2019年7月12日）。アメリカの物理学者・計算機科学者。MITの計算センターおよびProject MACでCTSSとMulticsの開発を主導。1990年、ACMチューリング賞を受賞。受賞理由は「汎用・大規模・タイムシェアリングおよびリソース共有コンピュータシステムCTSSとMulticsの概念の組織化と開発を主導した先駆的業績」。Corbatoが考案したCTSSの多段プロセッサスケジューリングアルゴリズムの変種は、現代のほとんどのタイムシェアリングシステムで使用されている
- **一次ソース**: ACM, "Fernando Corbato - A.M. Turing Award Laureate"
- **URL**: <https://amturing.acm.org/award_winners/corbato_1009471.cfm>
- **注意事項**: Corbatoは2019年7月12日に93歳で死去
- **記事での表現**: Corbatoは1990年にチューリング賞を受賞した。CTSSの多段フィードバックキュースケジューリングは、現代OSのプロセススケジューラの原型となっている

## 7. Project MAC（1963年、MIT）

- **結論**: 1963年7月1日、DARPAからの200万ドルの助成金で設立。初代ディレクターはRobert Fano。MACの頭字語の意味は議論があり、「Machine-Aided Cognition」「Multiple-Access Computer」の両方が言われる。DARPA側のプログラムマネージャーはJ.C.R. Licklider（当時IPTO局長）。Project MACはCTSSの運用基盤であり、後のMultics開発の母体となった。後にMIT CSAIL（Computer Science and Artificial Intelligence Laboratory）へ発展
- **一次ソース**: Multicians.org, "Project MAC"; Britannica, "Project MAC"
- **URL**: <https://multicians.org/project-mac.html>, <https://www.britannica.com/topic/Project-Mac>
- **注意事項**: LickliderはMITのRLEでの研究後にARPAへ移り、後にProject MACのディレクターも務めた
- **記事での表現**: 1963年、DARPAの200万ドルの助成で設立されたProject MACは、タイムシェアリング研究の拠点となった。背後にはLickliderの構想があった

## 8. Multics（1964-1969年）

- **結論**: 1964年、MITのProject MAC、Bell Labs、GEの3者共同プロジェクトとして計画開始（GEの提案は1964年5月に選定、契約は1964年8月、Bell Labsは1964年11月参加）。正式な設計開始は1965年。Fernando Corbatoが主導。GE-645上で動作。最初のGE-645は1967年1月にMITに納入。Bell Labsは1969年に撤退（これが後にUNIXの誕生につながる）。1970年、GEのコンピュータ事業がHoneywellに売却。Honeywellが商用製品として販売し、1985年まで運用された。革新的機能: 階層ファイルシステム、リング構造によるセキュリティ（0-7の8段階）、アクセス制御リスト（ACL）、単一レベルストア、動的リンク
- **一次ソース**: Multicians.org, "Multics History"; Wikipedia, "Multics"
- **URL**: <https://multicians.org/history.html>, <https://en.wikipedia.org/wiki/Multics>
- **注意事項**: Multicsの複雑さへの反動がUNIXの設計哲学（シンプルさの追求）につながった
- **記事での表現**: Multicsは「ユーティリティとしてのコンピューティング」を目指した野心的プロジェクトだった。Bell Labsの撤退が、Ken ThompsonとDennis RitchieによるUNIX誕生の契機となった

## 9. Dartmouth Time-Sharing System（DTSS, 1964年）

- **結論**: Dartmouth Collegeで1963年から開発開始。John KemenyとThomas Kurtzが主導。学部生を含む全構成員にコンピューティングを提供する哲学。1964年5月1日午前4時に運用開始——KemenyとKurtzが隣り合う端末で同時にRUNを入力し、正しい結果が返った瞬間がタイムシェアリングとBASICの誕生とされる。BASIC言語はこのシステム向けに設計された（Kemenyが1963年9月にドラフト開始）
- **一次ソース**: Wikipedia, "Dartmouth Time-Sharing System"; Dartmouth Library, "Sharing the Computer"
- **URL**: <https://en.wikipedia.org/wiki/Dartmouth_Time-Sharing_System>, <https://www.dartmouth.edu/library/rauner/exhibits/sharing-the-computer.html>
- **注意事項**: DTSSの哲学（コンピューティングの民主化）はCTSSの研究志向と対比される
- **記事での表現**: 1964年5月1日、Dartmouth CollegeのDTSSが運用を開始。MITが研究者向けにタイムシェアリングを追求したのに対し、Dartmouthは学部生を含む全員へのコンピューティング開放を目指した

## 10. タイムシェアリングの技術的前提条件

- **結論**: タイムシェアリングの実現に必要だった技術: (1) コンテキストスイッチ——実行中のプロセスの状態を保存し、別のプロセスの状態を復元する機構、(2) メモリ保護——各ユーザープログラムが他のプログラムやOSのメモリ領域にアクセスできないようにするハードウェア機構、(3) タイマー割り込み——一定時間経過後にCPU制御をOSに戻すハードウェア割り込み、(4) プロセススケジューリング——複数プロセスへのCPU時間配分アルゴリズム。CTSSではタイムクォンタム200ms、多段フィードバックキュー
- **一次ソース**: Wikipedia, "Time-sharing"; Wikipedia, "Context switch"
- **URL**: <https://en.wikipedia.org/wiki/Time-sharing>, <https://en.wikipedia.org/wiki/Context_switch>
- **注意事項**: これらの技術は現代のOSでも基本的に同じ原理で動作している
- **記事での表現**: タイムシェアリングは、コンテキストスイッチ、メモリ保護、タイマー割り込み、プロセススケジューリングという4つの技術的前提を必要とした。これらはすべて現代OSの基盤でもある

## 11. simh（コンピュータ歴史シミュレータ）

- **結論**: SIMH（Simulator for Historical Computers / Computer History Simulation Project）は1993年にBob Supnik（元DEC副社長）が開始した、歴史的コンピュータのオープンソースエミュレータ。約20種類のマシンをシミュレート。PDP-11エミュレータではUNIX v1, v4, v5, v6, v7が動作可能。PDP-7, PDP-8, PDP-10, VAXなどもサポート。ネットワークインターフェースのエミュレーションも可能
- **一次ソース**: GitHub, "simh/simh"; Computer History Wiki, "SIMH"
- **URL**: <https://github.com/simh/simh>, <https://gunkies.org/wiki/SIMH>
- **注意事項**: CTSSそのもののシミュレーションは困難（IBM 7094のシミュレータは限定的）。ハンズオンではsimh上の初期UNIXで「対話的シェルの原体験」を提供するアプローチが現実的
- **記事での表現**: simhは歴史的コンピュータのエミュレータで、PDP-11上の初期UNIXなどを実体験できる。1970年代の対話的コンピューティング環境を追体験する手段として活用する
