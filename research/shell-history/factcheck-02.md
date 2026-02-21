# ファクトチェック記録：第2回「シェル以前の世界――テレタイプ、モニタプログラム、そして対話の誕生」

## 1. パンチカードとバッチ処理の時代（1950-60年代）

- **結論**: 1950-60年代のコンピュータはパンチカードによる入出力が主流だった。プログラマはパンチカードにプログラムを記述し、カウンター越しにオペレータに提出して実行結果を待つ「closed shop」方式が一般的だった。ターンアラウンドタイムは数時間から数日に及ぶこともあった。IBM 709xなどの大型計算機は200万ドル（現在の約2,400万ドル相当）程度で、アイドル時間の削減が経済的に重要だった。Margaret Hamiltonのチームによるアポロ計画のシミュレーションでは、1回の実行に15,000-20,000枚のパンチカードが必要だったとされる
- **一次ソース**: Wikipedia "Computer programming in the punched card era"; IBM "The punched card"
- **URL**: <https://en.wikipedia.org/wiki/Computer_programming_in_the_punched_card_era>
- **注意事項**: ターンアラウンドタイムは環境により大きく異なる。「数時間から数日」は一般的な記述
- **記事での表現**: 「1950-60年代、プログラマはパンチカードにプログラムを打ち込み、オペレータに提出し、結果を数時間から翌日まで待った」

## 2. John McCarthyのタイムシェアリング提案（1959年）

- **結論**: John McCarthyは1959年1月1日付で、MITのP.M. Morse教授宛に"A Time Sharing Operator Program for our Projected IBM 709"と題するメモを執筆し、タイムシェアリングの概念を提案した。ただし、この日付が誤りで実際は1960年ではないかとの指摘もある。イギリスのChristopher Stracheyも1959年に独立して同様の概念を提案している
- **一次ソース**: John McCarthy, "Memorandum to P. M. Morse", 1959; McCarthy, "Reminiscences on the Theory of Time-Sharing"
- **URL**: <http://jmc.stanford.edu/computing-science/timesharing-memo.html>
- **注意事項**: 日付の正確性に議論がある。1959年または1960年
- **記事での表現**: 「1959年、John McCarthyはMITのMorse教授宛にタイムシェアリングの構想を記したメモを送った」

## 3. CTSS（Compatible Time-Sharing System）の開発（1961年）

- **結論**: CTSSはMITのFernando J. Corbatóが中心となり、Marjorie Merwin-DaggettおよびRobert Daleyとともに開発した。1961年11月にMITの改造IBM 709上でデモンストレーションされた。1963年夏からMIT Computation Centerの一般ユーザーにルーティンサービスとして提供開始。CTSSは最初の汎用タイムシェアリングOSと位置づけられる。IBMの7090（1962年に導入、後に7094にアップグレード）上で稼働した
- **一次ソース**: Corbató, Daggett, Daley, "An Experimental Time-Sharing System", AFIPS Spring Joint Computer Conference, 1962; Multicians.org
- **URL**: <https://en.wikipedia.org/wiki/Compatible_Time-Sharing_System>
- **注意事項**: 1961年11月のデモは「Experimental Time-Sharing System」と呼ばれていた。CTSS自体は1962年頃から本格化
- **記事での表現**: 「1961年11月、Fernando CorbatóはタイムシェアリングシステムのデモンストレーションをMITで実施した。4台の端末から同時にプログラムを実行できるこのシステムは、CTSSと名付けられた」

## 4. CTSSとコンピュータパスワードの発明

- **結論**: CTSSは複数ユーザーがファイルを共有する環境を実現したため、個人のファイルを保護するメカニズムが必要だった。Corbatóはパスワード認証を導入し、CTSSは世界初のコンピュータパスワードシステムを持つシステムとして広く認知されている。Corbatóは1990年にACMチューリング賞を受賞した
- **一次ソース**: ACM Turing Award Citation; MIT News obituary (2019)
- **URL**: <https://amturing.acm.org/award_winners/corbato_1009471.cfm>
- **注意事項**: 「世界初」には議論の余地があるが、広く引用されている
- **記事での表現**: 「タイムシェアリングは必然的にセキュリティの問題を生んだ。Corbatóは各ユーザーにパスワードを設定する仕組みを導入した。CTSSは世界初のパスワード認証システムを持つコンピュータとして知られる」

## 5. IBM 7094のハードウェア仕様とCTSS用改造

- **結論**: IBM 7094は1960年代中頃のIBMの最大級のコンピュータで、約0.35 MIPSの浮動小数点演算能力を持ち、標準で32K語（36ビット語）のメモリを搭載。価格は約350万ドル。CTSSのために特別な改造が施された：（1）インターバルタイマー（計算集約的なプロセスの割り込み用）、（2）第2の32K語メモリバンク（バンクA：CTSSスーパバイザ用、バンクB：ユーザープログラム用）、（3）CPUのモードビット（ユーザーによるI/O命令の直接実行を防止）
- **一次ソース**: Tom Van Vleck, "The IBM 7094 and CTSS", Multicians.org
- **URL**: <https://www.multicians.org/thvv/7094.html>
- **注意事項**: メモリの「デュアルバンク」構成はタイムシェアリングの核心技術。現代のユーザーモード/カーネルモード分離の原型
- **記事での表現**: 「CTSSはIBM 7094を特別に改造して使用していた。32K語のメモリを2バンクに分け、一方をOSに、もう一方をユーザープログラムに割り当てる。この分離こそ、複数ユーザーの同時利用を可能にした核心技術だった」

## 6. Teletype Model 33（ASR-33）

- **結論**: Teletype Corporation Model 33は1963年に商用製品として発表された。元々は米海軍向けに設計され、Western Unionの通信ネットワーク向け低コスト端末として開発された。ASCIIコード（7ビット+パリティ）を使用し、大文字のみ出力可能。価格は約1,000ドル（現在の約11,000ドル相当）と他の端末より大幅に安価だった。1970年代中頃まで、IBM以外のほぼすべてのミニコンピュータ（DEC PDP-xxシリーズ等）のコンソール端末として使用された。Ken ThompsonとDennis RitchieがUNIXを開発した際のインタフェースもModel 33テレタイプだった
- **一次ソース**: Wikipedia "Teletype Model 33"; Computer History Museum; Columbia University Computing History
- **URL**: <https://en.wikipedia.org/wiki/Teletype_Model_33>
- **注意事項**: ASR = Automatic Send-Receive（紙テープリーダー/パンチ付き）。UNIXの端末関連の慣習（tty, /dev/tty等）はテレタイプに由来する
- **記事での表現**: 「1963年に登場したTeletype Model 33は、約1,000ドルという低価格とASCII対応により、ミニコンピュータ時代の標準的な端末となった」

## 7. Louis PouzinによるRUNCOMとshellの命名（1964-1965年）

- **結論**: Louis Pouzinは1963年頃、CTSS上でRUNCOMを作成した。RUNCOMはコマンドスクリプトの実行を駆動する仕組みで、引数の置換を備えていた。Pouzinは「コマンドをプログラミング言語のように使えるようにする」という構想を持っていた。1964年末から1965年初頭にかけて、Multicsの設計時に、コマンド言語インタプリタを"shell"と命名した。1965年にはMultics shellの設計を記述する論文を発表し、5日後にはRUNCOMに制御フロー（条件分岐、ループ）を追加する設計の論文を発表した。Pouzinが1965年にフランスに帰国した後、MITのGlenda SchroederがPouzinのフローチャートをもとにMultics用の最初のシェルを実装した
- **一次ソース**: Multicians.org, "The Origin of the Shell"; Wikipedia "RUNCOM"; Wikipedia "Louis Pouzin"
- **URL**: <https://www.multicians.org/shell.html>
- **注意事項**: RUNCOMからUNIXの.rcファイル命名規則が派生した。"rc"は"run commands"の略
- **記事での表現**: 「1963年頃、PouzinはCTSS上にRUNCOM——コマンドスクリプトの実行エンジン——を作り上げた。そして1964年末、Multicsの設計段階でコマンド言語インタプリタに"shell"という名前を与えた」

## 8. RUNCOMから.rcファイルへの系譜

- **結論**: Louis PouzinがCTSS上で作成したRUNCOM（"run commands"の略）は、コマンドのバッチ実行を可能にする仕組みだった。このRUNCOMの名前が、UNIXにおける設定ファイルの".rc"接尾辞の語源となった。Kernighan & Ritchieによれば、UNIXの.rcファイルはCTSSのRUNCOMに由来する。.bashrc、.vimrc、.zshrcなど現代のdotfileの命名規則はすべてこの系譜にある
- **一次ソース**: Wikipedia "RUNCOM"; Multicians.org; TUHS mailing list archives
- **URL**: <https://en.wikipedia.org/wiki/RUNCOM>
- **注意事項**: "rc"の解釈として"run control"も広まっているが、歴史的には"run commands"が正確
- **記事での表現**: 「.bashrcの"rc"は、1963年のCTSS上のRUNCOM（run commands）に遡る。60年以上前のプログラムの名前が、今もあなたの設定ファイルに刻まれている」

## 9. Multics（Multiplexed Information and Computing Service）

- **結論**: Multicsは1964年に計画が開始され、1965年にMITのProject MAC、Bell Labs、GE（General Electric）の共同プロジェクトとして正式に開発が始まった。Fernando Corbatóが主導。目標は「コンピュータ・ユーティリティ」——電気や水道のように、必要なときにいつでもコンピューティング能力を利用できるサービスの実現。GEのGE-645は1967年1月にMITに納入された。Bell Labsは1969年にプロジェクトから撤退。1970年にGEのコンピュータ部門がHoneywellに売却された後、商用製品として販売され、1985年に終了
- **一次ソース**: Multicians.org "Multics History"; Wikipedia "Multics"; Corbató et al. "Multics--The First Seven Years"
- **URL**: <https://multicians.org/history.html>
- **注意事項**: Bell Labsの撤退（1969年）がUNIX誕生の直接的な契機となった
- **記事での表現**: 「1965年、MIT、Bell Labs、GEの三者によるMulticsプロジェクトが始動した。目標は壮大だった——コンピューティングを電気のようなユーティリティにすること」

## 10. Dartmouth Time-Sharing System（DTSS）とBASIC

- **結論**: Dartmouth Time-Sharing System（DTSS）は1964年3月にサービス開始。John G. KemenyとThomas E. Kurtzが開発。DTSSと共にBASICプログラミング言語が誕生し、1964年5月1日に最初のBASICプログラムが実行された。6月に一般ユーザーに公開。DTSSの設計動機は、Dartmouth大学の全学生にコンピュータへのアクセスを提供することだった。McCarthyがKurtzに「タイムシェアリングをやるべきだ」と助言したことが契機
- **一次ソース**: Dartmouth College Library, "Sharing the Computer"; Wikipedia "Dartmouth BASIC"
- **URL**: <https://www.dartmouth.edu/library/rauner/exhibits/sharing-the-computer.html>
- **注意事項**: CTSSが1961年デモ、DTSSが1964年運用開始で、両者は独立に開発された
- **記事での表現**: 「1964年3月、Dartmouth大学でもタイムシェアリングシステムが稼働を始めた。KemenyとKurtzが開発したこのシステムは、BASIC言語と共に全学生にコンピュータを開放した」

## 11. Glenda Schroederによる最初のシェル実装

- **結論**: Glenda Schroederは、Louis Pouzinの設計（フローチャート）をもとに、Multics上で最初のコマンドライン・ユーザーインタフェース・シェルを実装したアメリカのソフトウェアエンジニアである。1965年にMIT Computation Centerのスタッフとして勤務。GEの無名の技術者の支援を受けて実装した。また、PouzinおよびCrismanとともに最初の電子メールシステムの研究論文を共著している
- **一次ソース**: Wikipedia "Glenda Schroeder"; Multicians.org "The Origin of the Shell"
- **URL**: <https://en.wikipedia.org/wiki/Glenda_Schroeder>
- **注意事項**: Schroederの貢献はしばしば見落とされがちだが、最初のシェルの「実装者」としての功績は重要
- **記事での表現**: 「Pouzinがフランスに帰国した後、MITのGlenda Schroederが彼の設計をもとにMultics上で最初のシェルを実装した」

## 12. UNIXの誕生とテレタイプの関係（1969-1971年）

- **結論**: Bell LabsがMulticsプロジェクトから撤退した1969年夏、Ken ThompsonとDennis Ritchieは、Bell Labs内のDEC PDP-7上で新しいOSの構築を始めた。1970年にBrian Kernighanが"Unix"の名前を提案（Multicsのもじり）。1970年にPDP-11に移植。1971年11月にUNIX V1がリリースされた。開発にはTeletype Model 33が端末として使用された。UNIXにおける"tty"（端末デバイス）の名前はteletypeに由来する
- **一次ソース**: Wikipedia "Ken Thompson"; Computer History Museum; Wikipedia "History of Unix"
- **URL**: <https://en.wikipedia.org/wiki/Unix>
- **注意事項**: PDP-7上での開発はThompsonが妻子の不在中に「1週間で3つのプログラム（OS、シェル、エディタ）を書いた」という逸話がある
- **記事での表現**: 「1969年、Multicsから撤退したBell LabsのThompsonとRitchieは、PDP-7とTeletype端末を使って新しいOSの開発を始めた。これが後にUNIXと呼ばれるシステムである」
