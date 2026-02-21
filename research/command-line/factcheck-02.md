# ファクトチェック記録：第2回「コマンドライン以前の世界――パンチカードとバッチ処理」

## 1. Herman Hollerithのパンチカードと1890年国勢調査

- **結論**: Herman Hollerith（1860年2月29日 - 1929年11月17日）はドイツ系アメリカ人の統計学者・発明家。1880年国勢調査後、国勢調査局は1888年に効率的な集計方法を競争形式で募集。Hollerithの電気機械式集計機が採用され、1890年国勢調査で初めて使用された。集計を6ヶ月で完了し、詳細分析を2年で終えた（1880年国勢調査は8年以上を要した）。500万ドルと2年以上の労力を節約した
- **一次ソース**: U.S. Census Bureau, "The Hollerith Machine"
- **URL**: <https://www.census.gov/history/www/innovations/technology/the_hollerith_tabulator.html>
- **注意事項**: Hollerithの機械はピンが穿孔カードを通過し、水銀に接触して電気回路を完成させる仕組み
- **記事での表現**: 1890年の国勢調査で初めて電気機械式の集計が行われ、前回8年かかった作業を2年に短縮した

## 2. Hollerithのパンチカードサイズとドル札

- **結論**: 1890年のHollerithカードは当時のドル紙幣と同じサイズに設計された。初期のカードは22列×8パンチ位置。その後24列×10位置を経て、1928年にIBMが80列のフォーマットを導入（Clair D. Lakeの設計、長方形の穴で列を密に配置）。ANSI X3.21-1967で標準化
- **一次ソース**: IBM, "The punched card"
- **URL**: <https://www.ibm.com/history/punched-card>
- **注意事項**: 80列フォーマットの導入は1928年だが、標準として広く使われるようになったのは1930年代以降
- **記事での表現**: Hollerithはカードのサイズを当時のドル紙幣と同じにした。1928年にIBMが80列フォーマットを導入し、この数字は後にターミナルの横幅として受け継がれる

## 3. HollerithからIBMへの系譜

- **結論**: 1911年、Hollerithの企業を含む4社が合併してComputing-Tabulating-Recording Company（CTR）を設立。Thomas J. Watsonの社長就任後、1924年にInternational Business Machines Corporation（IBM）に改名
- **一次ソース**: National Museum of American History, "From Herman Hollerith to IBM"
- **URL**: <https://americanhistory.si.edu/collections/object-groups/tabulating-equipment/from-herman-hollerith-to-ibm>
- **注意事項**: なし
- **記事での表現**: Hollerithの会社は1911年に他社と合併し、1924年にIBMとなる

## 4. UNIVAC I（1951年）

- **結論**: 1951年6月14日、米国国勢調査局にUNIVAC Iが納入・献呈された。J. Presper EckertとJohn Mauchlyが設計（ENIACの設計者）。重量16,000ポンド、真空管5,000本、毎秒約1,000回の計算能力。1952年11月4日、アイゼンハワーの大統領選勝利を正確に予測し全国的に有名に
- **一次ソース**: U.S. Census Bureau, "UNIVAC I"; HISTORY.com, "UNIVAC computer dedicated"
- **URL**: <https://www.census.gov/about/history/bureau-history/census-innovations/technology/univac-i.html>, <https://www.history.com/this-day-in-history/june-14/univac-computer-dedicated>
- **注意事項**: Eckert-Mauchly Computer Corporationはコスト超過のためRemington Randに売却された
- **記事での表現**: 1951年、UNIVAC Iが国勢調査局に納入された。パンチカードから磁気テープへの移行を象徴するマシンだった

## 5. IBM 701（1952年）

- **結論**: IBM 701 Electronic Data Processing Machine（開発名: Defense Calculator）は1952年5月21日に発表。IBMの最初の商用科学計算コンピュータ。Jerrier HaddadとNathaniel Rochesterが設計。毎秒16,000回以上の加減算、2,000回以上の乗除算。3年間で19台を販売（研究所、航空会社、連邦政府向け）。IBMは「computer」という語がUNIVACと結びつきすぎていたため「electronic data processing machine」と呼んだ
- **一次ソース**: IBM, "IBM 700 Series"; Wikipedia, "IBM 701"
- **URL**: <https://www.ibm.com/history/700>, <https://en.wikipedia.org/wiki/IBM_701>
- **注意事項**: IASマシン（プリンストン）をベースに設計
- **記事での表現**: 1952年、IBMは最初の商用科学計算機IBM 701を発表した。「コンピュータ」という語を避け「電子データ処理機」と名付けた

## 6. IBM 1401（1959年）とIBM 1403プリンター

- **結論**: IBM 1401は1959年10月5日に発表。「コンピュータ産業のModel T」と呼ばれ、1960年代半ばには世界のコンピュータの半数以上を占めた（10,000台以上設置）。付属のIBM 1403プリンターは当時の競合の4倍の速度で、毎分600行（モデル3は最大1,400行）を印刷。132列フォーマットが標準化
- **一次ソース**: IBM, "The IBM 1401"; Computer History Museum, "IBM 1401 Demo Lab"
- **URL**: <https://www.ibm.com/history/1401>, <https://computerhistory.org/exhibits/ibm1401/>
- **注意事項**: 1402カードリーダー/パンチは毎分800枚のカード読み取り、250枚のパンチが可能
- **記事での表現**: 1959年のIBM 1401は「コンピュータ産業のModel T」と呼ばれ、1960年代半ばには世界のコンピュータの半数以上を占めた

## 7. IBM System/360とJCL

- **結論**: IBM System/360は1964年4月7日に発表。商用・科学計算の両方に対応した初の汎用コンピュータファミリー。OS/360は1964年発表だが安定版は1968年まで要した（初期リリース約100万行のコード）。JCL（Job Control Language）はOS/360向けに1965年に導入。Fred Brooksは「The Design of Design」でJCLを「誰かがどこかで作った最悪のプログラミング言語」と呼んだ
- **一次ソース**: Wikipedia, "IBM System/360"; Wikipedia, "Job Control Language"
- **URL**: <https://en.wikipedia.org/wiki/IBM_System/360>, <https://en.wikipedia.org/wiki/Job_Control_Language>
- **注意事項**: System/360のローエンドモデル（360/30）は毎秒1,800～34,500命令の処理能力。JCLの複雑さは「プログラマよりコンピュータの方が高価」という時代の設計判断
- **記事での表現**: JCLの複雑さは「コンピュータの時間の方がプログラマの時間より高価」という時代の優先順位を映している

## 8. コンピュータのレンタルコスト（1960年代）

- **結論**: IBM 7090のレンタル料は月額約63,500ドル（2024年換算で約514,000ドル）、電気代別。購入価格は290万ドル（2025年換算で約2,300万ドル）。IBM 701のレンタル料は月額12,000～20,000ドル
- **一次ソース**: Wikipedia, "IBM 7090"; EDN, "IBM delivers 7090 mainframe computers"
- **URL**: <https://en.wikipedia.org/wiki/IBM_7090>, <https://www.edn.com/ibm-delivers-7090-mainframe-computers-november-30-1959/>
- **注意事項**: コスト比較の文脈で使用。プログラマの年俸と比較してコンピュータが桁違いに高価だった事実を示す
- **記事での表現**: IBM 7090のレンタル料は月額63,500ドル（現在の貨幣価値で約50万ドル）。プログラマが待つのではなく、コンピュータを待たせないことが経済合理性だった

## 9. パンチカードプログラミングのワークフロー

- **結論**: (1)プログラマがコーディングシートに手書き→(2)キーパンチオペレータがIBM 026/029で穿孔→(3)別のオペレータがIBM 059で検証→(4)カードデッキをコンピュータ室のカウンターに提出→(5)バッチ処理で実行→(6)結果が印刷出力またはパンチカードとしてキュビーホールに返却。FORTRANは80列カードの先頭72列のみ使用（残り8列はシーケンス番号用。デッキを落とした場合にカードソーターで復元可能）
- **一次ソース**: Wikipedia, "Computer programming in the punched card era"
- **URL**: <https://en.wikipedia.org/wiki/Computer_programming_in_the_punched_card_era>
- **注意事項**: 軽負荷のシステムでは1時間以内に再実行可能だったが、繁忙時は数時間～翌日待ちも
- **記事での表現**: プログラマはコードをコーディングシートに手書きし、キーパンチオペレータに渡し、穿孔されたカードデッキをコンピュータ室に提出して結果を待った

## 10. J.C.R. Lickliderの「Man-Computer Symbiosis」（1960年）

- **結論**: 1960年発表。IRE Transactions on Human Factors in Electronicsに掲載。人間とコンピュータの補完的関係を構想。「リアルタイム」の思考プロセスにコンピュータを参加させることを目指した。対話的コンピューティングの思想的基盤。Lickliderは後にARPA（後のDARPA）の情報処理技術局長としてタイムシェアリング研究に資金提供
- **一次ソース**: J.C.R. Licklider, "Man-Computer Symbiosis", IRE Transactions on Human Factors in Electronics, 1960
- **URL**: <https://groups.csail.mit.edu/medg/people/psz/Licklider.html>
- **注意事項**: この論文が直接CTSSに影響したかは因果関係の証明が難しいが、時代の知的気運として連動している
- **記事での表現**: 1960年、Lickliderは「人間とコンピュータの共生」を構想した。バッチ処理の時代に「リアルタイムの対話」を夢見た先見の明

## 11. CTSS（Compatible Time-Sharing System, 1961年）

- **結論**: 1961年春、MITのFernando Corbato（計算センター副所長）がIBM 709向けに設計開始。Marjorie DaggettとRobert Daleyと共に開発。1961年11月に最初の公開デモンストレーション（MITにて）。4台の磁気テープドライブを使用し、4人の同時ユーザーがFlexowriter端末を使用。最初の汎用タイムシェアリングOS。1963年夏にMIT計算センターで定常サービス開始、1968年まで運用
- **一次ソース**: Multicians.org, "Compatible Time-Sharing System (1961-1973) Fiftieth Anniversary"
- **URL**: <https://multicians.org/thvv/compatible-time-sharing-system.pdf>
- **注意事項**: 第3回の予告として言及するが、詳細は第3回に譲る
- **記事での表現**: 1961年、MITのCorbatoが世界初の汎用タイムシェアリングシステムCTSSを実演した。バッチ処理の時代に終わりを告げる最初の一撃だった

## 12. Fred Brooksと「人月の神話」

- **結論**: Frederick P. Brooks Jr.はIBM System/360のプロジェクトマネージャー、後にOS/360のソフトウェアプロジェクトマネージャー。1975年に「The Mythical Man-Month: Essays on Software Engineering」を出版。OS/360の開発経験から「遅れているプロジェクトに人員を追加するとさらに遅れる」（ブルックスの法則）を導出。OS/360の初期リリース（1966年）は遅延・メモリ超過・コスト超過・性能不足
- **一次ソース**: Wikipedia, "The Mythical Man-Month"
- **URL**: <https://en.wikipedia.org/wiki/The_Mythical_Man-Month>
- **注意事項**: JCLへの批判は「The Design of Design」（2010年）での発言
- **記事での表現**: Brooksが「人月の神話」で描いたOS/360の混乱は、バッチ処理時代のソフトウェア開発の難しさを象徴している
