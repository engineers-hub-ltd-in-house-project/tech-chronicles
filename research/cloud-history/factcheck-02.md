# ファクトチェック記録：第2回「メインフレームとタイムシェアリング——計算資源を共有した最初の時代」

## 1. MIT CTSS（Compatible Time-Sharing System）の開発経緯

- **結論**: CTSSは1961年にFernando Corbato、Robert Daley、Marjorie Merwin Daggettによって開発が開始された。1961年7月にIBM 709上で最初のタイムシェアリングコマンドが動作し、1961年11月にMITで最初の公開デモンストレーションが行われた。定常的なサービス提供は1963年夏から1968年まで
- **一次ソース**: Compatible Time-Sharing System (1961-1973) Fiftieth Anniversary Commemorative Overview; ACM Turing Award page for Fernando Corbato
- **URL**: <https://multicians.org/thvv/compatible-time-sharing-system.pdf>; <https://amturing.acm.org/award_winners/corbato_1009471.cfm>
- **注意事項**: CTSSは「初の汎用タイムシェアリングOS」とされる。特殊用途のシステムでは他にも主張があるが、汎用かつ公開デモンストレーションを行った最初のシステムとして広く認知されている
- **記事での表現**: 「1961年11月、Fernando CorbatがMITで世界初の汎用タイムシェアリングシステムCTSSのデモンストレーションを行った」

## 2. Fernando Corbato のチューリング賞受賞

- **結論**: 1990年にACMチューリング賞を受賞。授賞理由は「汎用・大規模なタイムシェアリングおよびリソースシェアリング計算機システムCTSSとMulticsの概念を組織し、開発をリードした先駆的業績」。2019年7月12日に93歳で死去
- **一次ソース**: ACM, A.M. Turing Award Laureate - Fernando J. Corbato
- **URL**: <https://amturing.acm.org/award_winners/corbato_1009471.cfm>
- **注意事項**: 生年は1926年。スペイン系の名前で正式にはCorbato（アクセント付き）
- **記事での表現**: 「Corbatoは1990年にチューリング賞を受賞した。CTSSとMulticsの開発をリードした功績による」

## 3. CTSSにおける最初のコンピュータパスワード

- **結論**: CTSSは最初にパスワードによるログイン認証を実装したコンピュータシステムとされる。パスワードは平文で保存されており、1966年春にAllan Scherrが全ユーザーのパスワードリストを入手した——最初のコンピュータパスワードハッキング事例
- **一次ソース**: Wikipedia "Password"; CyberNews "First computer password"
- **URL**: <https://en.wikipedia.org/wiki/Password>; <https://cybernews.com/security/first-computer-password/>
- **注意事項**: 「最初のパスワードそのもの」は記録に残っていない。パスワードの概念をコンピュータに導入した最初のシステムとしてCTSSが広く認められている
- **記事での表現**: 「CTSSはコンピュータにパスワード認証を導入した最初のシステムでもある」

## 4. Multicsの開発経緯

- **結論**: Multicsの開発契約は1964年8月にMIT Project MAC、Bell Telephone Laboratories、General Electric Company間で締結。Bell Labsは1964年11月からソフトウェア開発に参加。設計は1965年に開始。最初のGE-645は1967年1月にMITに納入。Bell Labsは1969年にプロジェクトから撤退し、その一部のメンバーがUnixを開発した
- **一次ソース**: Multicians.org, "Multics History"; Wikipedia "Multics"
- **URL**: <https://multicians.org/history.html>; <https://en.wikipedia.org/wiki/Multics>
- **注意事項**: ブループリントには「Multics（1964年〜）」とあるが、プロジェクト構想は1964年、設計開始は1965年、ハードウェア納入は1967年が正確な時系列。約50人のプログラマがMIT・GE・Bell Labsで開発に従事
- **記事での表現**: 「1964年、MIT Project MAC、General Electric、Bell Labsの共同プロジェクトとしてMulticsの開発が始まった」

## 5. Project MAC（MIT）

- **結論**: 1963年7月1日に正式発足。ARPA（Advanced Research Projects Agency）とNSFから資金援助。MIT提案は1963年1月1日にARPAに提出、1963年3月1日に資金承認。初代ディレクターはRobert M. Fano。1963-70年のARPA支出は約2,500万ドル
- **一次ソース**: Britannica "Project MAC"; Multicians.org "Project MAC"
- **URL**: <https://www.britannica.com/topic/Project-Mac>; <https://multicians.org/project-mac.html>
- **注意事項**: MACは当初「Machine-Aided Cognition」または「Multiple Access Computer」の略とされたが、Fanoは意図的に曖昧にしていたとされる
- **記事での表現**: 「1963年、MITはARPAの支援を受けてProject MACを発足させた。タイムシェアリング研究の一大拠点となるプロジェクトである」

## 6. IBM System/360 Model 67とCP-67/CMS

- **結論**: System/360 Model 67は1965年8月に発表。動的アドレス変換（DAT）ハードウェアにより仮想メモリをサポートした最初の量産IBMシステム。CP-67はIBMケンブリッジ科学センターで開発されたハイパーバイザ（仮想マシンモニタ）。CP-40をS/360-67向けに再実装したもの。1967年4月までにCP-40・CP-67とも日常的に稼働していた
- **一次ソース**: Wikipedia "IBM System/360 Model 67"; Wikipedia "CP-67"; IBM VM History
- **URL**: <https://en.wikipedia.org/wiki/IBM_System/360_Model_67>; <https://en.wikipedia.org/wiki/CP-67>; <https://www.vm.ibm.com/history/>
- **注意事項**: CP-67/CMSは「最初の仮想マシンOS」とされる。各ユーザーに仮想360を提供し、CPUとメインストレージを多重化した
- **記事での表現**: 「CP-67は各ユーザーに仮想的なIBM 360を提供した——現代の仮想マシン技術の直系の祖先である」

## 7. IBM VM/370

- **結論**: 1972年8月2日にIBMが発表。System/370の仮想メモリ対応モデルとともにリリース。CP-67/CMSの再実装。VM/SPからVM/XA、z/VMへと進化し、現在もメインフレームの仮想化基盤として使用されている
- **一次ソース**: IBM, "VM 50th Anniversary"; R. J. Creasy, "The Origin of the VM/370 Time-sharing System"
- **URL**: <https://www.vm.ibm.com/history/50th/index.html>; <https://pages.cs.wisc.edu/~stjones/proj/vm_reading/ibmrd2505M.pdf>
- **注意事項**: VM/370の系譜は CP-40 → CP-67 → CP-370 → VM/370
- **記事での表現**: 「1972年、IBMはVM/370を発表した。CP-67の概念を製品化したこのシステムは、仮想マシン技術の商用化における画期的な一歩だった」

## 8. Dartmouth Time-Sharing System（DTSS）とBASIC

- **結論**: 1964年5月1日午前4時に運用開始。John KemenyとThomas Kurtzがダートマス大学で開発をリード。BASICプログラミング言語はDTSSのために開発された。GE-225とDATANET-30を使用。1964年秋には20台のテレタイプで数百人の新入生が利用
- **一次ソース**: Wikipedia "Dartmouth Time-Sharing System"; Dartmouth College "BASIC at Dartmouth"
- **URL**: <https://en.wikipedia.org/wiki/Dartmouth_Time-Sharing_System>; <https://www.dartmouth.edu/basicfifty/basic.html>
- **注意事項**: DTSSは「最初の大規模タイムシェアリングシステムの成功例」とされる。CTSSが先だが、DTSSは大学全体への展開に成功した点で異なる
- **記事での表現**: 「1964年5月、ダートマス大学でDTSSが稼働を開始した。このシステムのためにBASIC言語が生まれた」

## 9. IBM 7094のスペックとコスト

- **結論**: 1962年9月に最初の設置。32K 36ビットワードのメモリ。動作サイクル2マイクロ秒。7インデックスレジスタ。価格は約350万ドル。MIT Computation Centerで使用され、CTSSはIBM 7094上で動作した
- **一次ソース**: Multicians.org "The IBM 7094 and CTSS"; Computer History Wiki "IBM 7094"
- **URL**: <https://www.multicians.org/thvv/7094.html>; <https://gunkies.org/wiki/IBM_7094>
- **注意事項**: CTSSは最初IBM 709上で開発され、後にIBM 7090、7094に移行した
- **記事での表現**: 「CTSSが動作したIBM 7094は、1台約350万ドル——当時の価値で約3億円——の計算機だった」

## 10. バッチ処理とパンチカードの歴史

- **結論**: IBMは1928年に80列パンチカードを開発。1950年代のIBM 650やIBM 1401はパンチカード入力に依存。プログラマはカードパンチ機でオフラインにプログラムを作成し、バッチジョブとしてメインフレームに投入した。JCL（Job Control Language）はOS/360とともに登場し、バッチジョブの制御に使用された
- **一次ソース**: IBM, "The punched card"; Wikipedia "Job Control Language"
- **URL**: <https://www.ibm.com/history/punched-card>; <https://en.wikipedia.org/wiki/Job_Control_Language>
- **注意事項**: System/360の発表は1964年。当時の低端モデル360/30のCPU処理速度は毎秒1.8K〜34.5K命令。JCLは機械にとって処理しやすく設計され、人間の利便性は二の次だった
- **記事での表現**: 「バッチ処理の時代、プログラマはパンチカードにプログラムを穿ち、ジョブの順番を待った。結果が返ってくるまで数時間、場合によっては翌日」

## 11. Multicsの技術的貢献——保護リング

- **結論**: Multicsはメモリ保護リング（protection rings）の概念を導入した。GE-645ではハードウェアのアクセス制御が不十分だったため、リング遷移をソフトウェアでトラップして実現。後継のHoneywell 6180では8つのリングをハードウェアでサポート。現代のx86プロセッサのRing 0-3はこの概念の直系の子孫
- **一次ソース**: Schroeder & Saltzer, "A Hardware Architecture for Implementing Protection Rings", 1972; Multicians.org
- **URL**: <https://multicians.org/protection.html>
- **注意事項**: Bell Labsは1969年にMulticsプロジェクトから撤退。一部のメンバー（Ken Thompson、Dennis Ritchie等）がUnixを開発。Unixの名前自体がMulticsのもじり（Uni- vs Multi-）
- **記事での表現**: 「Multicsが導入したメモリ保護リングの概念は、現代のCPUアーキテクチャにそのまま生き続けている」

## 12. SIMH（歴史的コンピュータシミュレータ）

- **結論**: SIMHはBob Supnikが開発した歴史的コンピュータのシミュレータコレクション。約20種類のマシンをシミュレート。PDP-11はUnix v1〜v7が動作する。Dockerイメージが複数存在（rattydave/alpine-simh、jguillaumes/simh-vax等）
- **一次ソース**: GitHub "simh/simh"; SIMH Classic website
- **URL**: <https://github.com/simh/simh>; <https://simh.trailing-edge.com/>
- **注意事項**: ハンズオンではsimhのPDP-11エミュレータを使用してマルチユーザー環境を体験させる方針。ただし、タイムシェアリングの「体感」という目的にはLinuxのプロセススケジューリングの可視化の方が直感的かもしれない
- **記事での表現**: 「simhは歴史的なコンピュータをソフトウェアでエミュレートするプロジェクトで、PDP-11上のUnix v6なども動作する」
