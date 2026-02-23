# ファクトチェック記録：第2回「Multicsの挫折——UNIXが生まれた必然」

## 1. CTSS（Compatible Time-Sharing System）の基本情報

- **結論**: CTSSは1961年11月にMITのIBM 709上で初めてデモンストレーションされた、最初の汎用タイムシェアリングシステムである。Fernando Corbato、Marjorie Daggett、Robert Daleyが開発した。1963年夏からMIT Computation Centerで定常的なサービスを開始し、1968年まで運用された。パスワードログインを最初に実装したシステムでもある
- **一次ソース**: Compatible Time-Sharing System (1961-1973) Fiftieth Anniversary Commemorative Overview; ACM Turing Award - Fernando Corbato
- **URL**: <https://multicians.org/thvv/compatible-time-sharing-system.pdf>, <https://amturing.acm.org/award_winners/corbato_1009471.cfm>
- **注意事項**: CTSSのデモは1961年11月。Corbato自身は1990年にチューリング賞を受賞している（UNIXのThompson/Ritchieの1983年とは別）
- **記事での表現**: 「1961年、MITのFernando Corbatoがリードしたチームが、最初の汎用タイムシェアリングシステムであるCTSS（Compatible Time-Sharing System）をIBM 709上で稼働させた」

## 2. Multicsプロジェクトの開始と参加組織

- **結論**: Multicsの設計は1965年に開始。MIT Project MAC、Bell Telephone Laboratories、General Electricの3者による共同プロジェクト。Fernando J. Corbatoがプロジェクトを主導した。計画段階は1964年から始まっており、GEの提案が1964年5月に選定、契約は1964年8月に締結。Bell Labsは1964年11月にMulticsソフトウェア開発に参加した
- **一次ソース**: Multics History (multicians.org); Corbato et al., "Multics--The First Seven Years"
- **URL**: <https://multicians.org/history.html>, <https://multicians.org/f7y.html>
- **注意事項**: 「1964年開始」はプロジェクト計画段階を指す場合があり、設計の正式開始は1965年とする文献もある。ブループリントは1964年と記載。計画段階（1964年）と設計開始（1965年）を区別して記述すべき
- **記事での表現**: 「1964年、CTSSの成功を受けて、次世代タイムシェアリングシステムの計画が本格化した。1965年、MIT Project MAC、Bell Telephone Laboratories、General Electricの3者は、Multics（Multiplexed Information and Computing Service）の共同開発を正式に開始した」

## 3. Multicsの設計目標と技術的野心

- **結論**: Multicsは数百人の同時ユーザへのインタラクティブアクセスを提供する「コンピュータ・ユーティリティ」の実現を目指した。主な技術的革新は：(1) セグメント化仮想メモリ（セグメンテーション+ページング）、(2) 8段階のリング保護機構、(3) 動的リンク、(4) 階層型ファイルシステム（世界初）、(5) アクセス制御リスト（ACL）によるセキュリティ、(6) 対称型マルチプロセッシング
- **一次ソース**: Multics Features (multicians.org); Schroeder & Saltzer, "A Hardware Architecture for Implementing Protection Rings", CACM 1972; Bensoussan et al., "The Multics Virtual Memory", CACM 1972
- **URL**: <https://multicians.org/features.html>, <https://multicians.org/protection.html>, <https://multicians.org/multics-vm.html>
- **注意事項**: Multicsの階層型ファイルシステムは「世界初」とする文献が複数ある（multicians.org, Wikipedia）。リング保護は当初2段階（supervisor/user）しかなく、後のGE-645/Honeywellで8段階に拡張された
- **記事での表現**: 技術的野心の具体例として、セグメント化メモリ、リング保護、動的リンク、階層型ファイルシステムを詳述する

## 4. GE-645ハードウェアのスペック

- **結論**: GE-645は36ビットワード、最大4プロセッサの対称型マルチプロセッサ構成。コアメモリは最大100万ワード（約4MB）に拡張可能。メモリサイクルタイムは2マイクロ秒。離散トランジスタ（TTL）で構成された最後期のコンピュータの一つ。速度は約435 KIPS。1965年11月のFall Joint Computer Conferenceで公表された
- **一次ソース**: GE 645 - Wikipedia; GE-645 - Computer History Wiki
- **URL**: <https://en.wikipedia.org/wiki/GE_645>, <https://gunkies.org/wiki/GE-645>
- **注意事項**: GE-645はGE-635を仮想メモリ・セグメンテーション対応に拡張したもの
- **記事での表現**: 「GE-645——36ビットワード、最大4プロセッサ構成、コアメモリ最大100万ワード。1960年代としては最先端のハードウェアだった」

## 5. Bell LabsのMultics撤退（1969年）

- **結論**: 1969年にBell LabsはMulticsプロジェクトから撤退した。Dennis Ritchieの記述によれば「1969年までに、Bell Labsの経営陣も研究者も、Multicsの約束は遅すぎ、高くつきすぎることによってのみ実現されると信じるに至った」。最後まで残ったのはKen Thompson、Dennis Ritchie、Doug McIlroy、Joe Ossannaだった
- **一次ソース**: Dennis Ritchie, "The Evolution of the Unix Time-sharing System", 1979
- **URL**: <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/hist.html>
- **注意事項**: 撤退は一斉ではなく段階的。研究者個人が順次離脱していった
- **記事での表現**: 「1969年、Bell Labsの経営陣はMulticsプロジェクトからの撤退を決定した。Ritchie自身が後に書いたように、『Multicsの約束は遅すぎ、高くつきすぎることによってのみ実現される』と皆が信じるに至ったのだ」

## 6. PDP-7のスペック

- **結論**: PDP-7はDigital Equipment Corporation（DEC）が1964年に発表した18ビットミニコンピュータ。標準メモリ容量は4Kワード（9KB）、最大64Kワード（144KB）まで拡張可能。メモリサイクルタイム1.75マイクロ秒。価格は72,000ドル。Flip-Chip技術を最初に採用したDECのコンピュータ。重量は約500kg
- **一次ソース**: PDP-7 - Wikipedia; PDP-7 - Computer History Wiki
- **URL**: <https://en.wikipedia.org/wiki/PDP-7>, <https://gunkies.org/wiki/PDP-7>
- **注意事項**: Thompsonが使用したPDP-7のメモリが標準の4Kワードだったか拡張されていたかは要確認。多くの文献は「約9KB」と表現している
- **記事での表現**: 「PDP-7——18ビットワード、標準メモリ4Kワード（約9KB）。GE-645の100万ワードに対して、0.4%にも満たない」

## 7. Ken ThompsonのSpace Travelゲームとの関連

- **結論**: Thompson は1969年、Bell LabsでMulticsの作業中にSpace Travelという太陽系シミュレーションゲームを開発した。最初はGE-645上で、次にFortranに移植してGECOS上で動作させたが、バッチ処理の遅延が問題だった。隣の部門にあった使われていないPDP-7にグラフィックス端末が接続されていることを知り、そちらに移植した。二つのマシン間でコードを移動する面倒さが、Thompson にファイルシステムの設計を促し、それがやがて独自のOSに発展した
- **一次ソース**: Space Travel (video game) - Wikipedia; Dennis Ritchie, "The Evolution of the Unix Time-sharing System"
- **URL**: <https://en.wikipedia.org/wiki/Space_Travel_(video_game)>, <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/hist.html>
- **注意事項**: Space TravelがUnixの直接的な動機というよりは、PDP-7を使い始めるきっかけ。ファイルシステムの設計はRitchieとRudd Canadayのアイデアにも基づく
- **記事での表現**: Thompsonがゲーム移植をきっかけにPDP-7上でファイルシステムを設計し、それがOS開発に発展した経緯を語る

## 8. UNIXの名前の由来

- **結論**: 1970年、Brian KernighanがUNICS（Uniplexed Information and Computing Service）という名前を提案した。Multics（Multiplexed Information and Computing Service）に対する駄洒落で、「Multicsが多重化したものの、単一版」という意味。後にUNICSからUNIXへ綴りが変化した。Kernighan自身がこの命名を自認しているが、「誰も最終的なUnixという綴りの由来を覚えていない」とも述べている
- **一次ソース**: Unix - Wikipedia; Brian Kernighan, "UNIX: A History and a Memoir", 2019
- **URL**: <https://en.wikipedia.org/wiki/Unix>
- **注意事項**: 命名の正確な経緯には複数の説がある。Peter Salusの著書ではKernighanが命名したとされるが、Kernighan自身はやや留保を付けている
- **記事での表現**: 「Brian Kernighanが『Multics（多重化された情報・計算サービス）に対するUNICS（単一の情報・計算サービス）』という駄洒落を考案した。後にUNIXと綴りが変わった」

## 9. PDP-11への移行とテキスト処理

- **結論**: 1970年にUNIXはPDP-11に移植された。Bell Labsの特許部門がワードプロセッサを必要としており、ThompsonとRitchieがUNIXにテキスト処理機能（roff、エディタ）を追加することでPDP-11の購入資金を獲得した。1971年半ばまでに、特許部門の3人のタイピストがPDP-11/20上で日常的に特許出願書類の作成・編集・整形を行っていた。1971年11月3日、UNIX Programmer's Manualが発行された
- **一次ソース**: Dennis Ritchie, "The Evolution of the Unix Time-sharing System"; History of Unix - Wikipedia
- **URL**: <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/hist.html>, <https://en.wikipedia.org/wiki/History_of_Unix>
- **注意事項**: この「ビジネスケース」の確立がUNIXの組織内での生存に重要だった
- **記事での表現**: 「ThompsonとRitchieは巧みだった。Bell Labsの特許部門にテキスト処理システムの需要があることを見つけ、UNIXにテキスト処理機能を追加することでPDP-11の購入資金を勝ち取った」

## 10. MulticsがUNIXに与えた技術的影響

- **結論**: Ritchieの論文によれば、UNIXの基本概念はMulticsの階層型ファイルシステムを使用するが、シングルレベルストア（Thompsonが最終的に悪い設計選択だと感じた機能）を除去することだった。UNIXがMulticsから受け継いだもの：(1) 階層型ファイルシステム、(2) シェル（コマンドインタプリタ）の概念、(3) リダイレクションの概念、(4) 一部のコマンド名。UNIXがMulticsから意図的に捨てたもの：(1) セグメント化メモリ（フラットなアドレス空間を選択）、(2) 動的リンク、(3) マルチレベルセキュリティ（単純なuid/gidモデルを選択）、(4) シングルレベルストア
- **一次ソース**: Dennis Ritchie, "The Evolution of the Unix Time-sharing System", 1979; multicians.org "Unix and Multics"
- **URL**: <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/hist.html>, <https://multicians.org/unix.html>
- **注意事項**: 「UNIXはMulticsの失敗から生まれた」という単純化は正確ではない。Multicsの目標自体は否定されておらず、その実現手段の複雑さが問題だった
- **記事での表現**: MulticsからUNIXへの選択的継承を詳述し、「何を受け継ぎ、何を捨てたか」を明確にする
