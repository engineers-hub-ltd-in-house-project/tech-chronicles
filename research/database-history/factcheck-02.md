# ファクトチェック記録：第2回「ファイルからデータベースへ——データ管理の夜明け」

## 1. パンチカードの歴史とHerman Hollerith

- **結論**: Herman Hollerithは1880年代後半にパンチカードによるデータ記録を発明。1890年の米国国勢調査で使用され、500万ドルと2年以上の労力を節約した。集計は6ヶ月で完了。Hollerithの会社は1911年にCTR（Computing-Tabulating-Recording Company）に統合され、1924年にIBMと改名された
- **一次ソース**: IBM, "The punched card"
- **URL**: <https://www.ibm.com/history/punched-card>
- **注意事項**: 1950年代半ばでもパンチカード売上はIBMの収益の約20%、利益の約30%を占めていた
- **記事での表現**: パンチカードによるデータ処理の起源として、Hollerithの1890年国勢調査での実績を記述

## 2. 磁気テープストレージの登場（1951年）

- **結論**: 磁気テープが初めてコンピュータデータの記録に使用されたのは1951年、UNIVAC Iの UNISERVO ドライブ。Eckert-Mauchly Computer Corporation が開発し、Remington Randに買収後に発売。0.5インチ幅のニッケルメッキ・リン青銅の金属ストリップを使用。最大100万文字を格納可能
- **一次ソース**: Computer History Museum, "Tape unit developed for data storage"
- **URL**: <https://www.computerhistory.org/storageengine/tape-unit-developed-for-data-storage/>
- **注意事項**: IBMは1952年にModel 726磁気テープユニットをIBM 701とともに発表。月額レンタル850ドル
- **記事での表現**: 1951年のUNIVAC I用UNISERVOを磁気テープストレージの始まりとして記述

## 3. IBM 305 RAMAC——世界初の商用ハードディスクドライブ（1956年）

- **結論**: IBM 305 RAMACは1956年9月13日に出荷開始。RAMACはRandom Access Method of Accounting and Controlの略。IBM 350ディスクユニットは24インチ径のディスク50枚で500万文字を格納。平均アクセス時間600ミリ秒。月額レンタル3,200ドル。重量1トン超。1,000台以上が製造され、1961年に製造終了
- **一次ソース**: Computer History Museum, "First commercial hard disk drive shipped"; IBM, "RAMAC"
- **URL**: <https://www.computerhistory.org/storageengine/first-commercial-hard-disk-drive-shipped/>, <https://www.ibm.com/history/ramac>
- **注意事項**: 記事中ではランダムアクセス・ストレージの登場がISAMなどの新しいアクセス方式を可能にした文脈で言及する
- **記事での表現**: 1956年のIBM 305 RAMACを、シーケンシャルアクセスからランダムアクセスへの転換点として記述

## 4. IBM 1401——ビジネスコンピューティングの大衆化（1959年）

- **結論**: IBM 1401は1959年10月5日に発表。12,000台以上が生産。1964年までに全コンピュータの40%がIBM 1401ファミリー。パンチカードと磁気テープの両方に対応。1本の2ポンドの磁気テープに1200万文字を格納可能（同容量のパンチカードは16万枚、80箱、800ポンド）。IBMは「コンピュータ業界のフォード・モデルT」と称した
- **一次ソース**: IBM, "The IBM 1401"
- **URL**: <https://www.ibm.com/history/1401>
- **注意事項**: 磁気テープの容量効率の劇的な改善を示す好例
- **記事での表現**: IBM 1401を、パンチカードから磁気テープへのデータ処理の移行期における象徴的なマシンとして記述

## 5. ISAM（Indexed Sequential Access Method）の開発

- **結論**: ISAMはIBMが1960年代初頭に開発。IBM 7080コンピュータ向けのISAM（Indexed Sequential Data Organization、ISDO）が起源。OS/360とともに普及。パンチカード・磁気テープからDirect Access Storage Device（DASD）への移行に伴い、シーケンシャルアクセスとランダムアクセスの両方を可能にするアクセス方式として開発された
- **一次ソース**: Wikipedia, "ISAM"
- **URL**: <https://en.wikipedia.org/wiki/ISAM>
- **注意事項**: ISAMは後の1972年にVSAM（Virtual Storage Access Method）に置き換えられた。VSAMはOS/VS1（1972年）およびOS/VS2（1973年）とともにリリース
- **記事での表現**: ISAMを、ランダムアクセス・ストレージの登場により可能になった新しいデータアクセス方式として記述

## 6. IBM System/360（1964年）とDASDs

- **結論**: IBM System/360は1964年4月7日に発表。商用・科学計算の両方をカバーする初のコンピュータファミリー。OS/360はDASDs（少なくとも1台のDirect Access Storage Device）を必要とした最初期のOSの一つ。OS/360は初期リリースで約100万行のコード
- **一次ソース**: IBM, "The IBM System/360"
- **URL**: <https://www.ibm.com/history/system-360>
- **注意事項**: System/360がDASDs要件を標準化したことで、ISAMなどのアクセス方式が広く普及する基盤となった
- **記事での表現**: System/360を、テープからディスクへの移行を加速させた基盤として記述

## 7. Charles BachmanとIDS（Integrated Data Store）——世界初のDBMS

- **結論**: Charles W. BachmanがGeneral Electricで1960年代初頭に開発。1962年1月に詳細な機能仕様が完成。1963年夏にプロトタイプが実データでテストされ、既存の専用製造管理システムの2倍の速度で動作。1964年にGE 235コンピュータ向けにソフトウェアがリリース。1965年にはWeyerhaeuser Lumber向けにWEYCOS（世界初の複数アプリケーション同時DBアクセスシステム）を開発。BachmanはこのIDS開発により1973年のACMチューリング賞を受賞
- **一次ソース**: CACM, "How Charles Bachman Invented the DBMS, a Foundation of Our Digital World"
- **URL**: <https://cacm.acm.org/opinion/how-charles-bachman-invented-the-dbms-a-foundation-of-our-digital-world/>
- **注意事項**: IDSはCODASYL Data Base Task Group（DBTG）の標準の基礎となった。第3回で詳述するためここでは概要に留める
- **記事での表現**: ファイルベースのデータ管理の限界が、BachmanのIDSという「世界初のDBMS」を生み出した文脈で記述

## 8. CODASYL（1959年）とCOBOL

- **結論**: CODASYL（Conference on Data Systems Languages）は1959年に米国国防総省の呼びかけにより設立。COBOLの設計は1959年に開始。Grace Hopperが設計したFLOW-MATICを一部基盤とする。1969年10月にCODASYL DBTGが最初のネットワーク型データベースの言語仕様を公開。COBOL 1965年版でマスストレージファイルとテーブルの処理機能が追加
- **一次ソース**: Wikipedia, "CODASYL"; Wikipedia, "COBOL"
- **URL**: <https://en.wikipedia.org/wiki/CODASYL>, <https://en.wikipedia.org/wiki/COBOL>
- **注意事項**: CODASYLのネットワーク型データモデルは第3回で詳述。第2回ではCOBOLのファイル処理能力のみに言及
- **記事での表現**: COBOLを、ファイルベースのデータ処理を体系化した言語として簡潔に言及

## 9. ファイルベースシステムの根本問題

- **結論**: データベース教科書で広く認知されている問題: (1) データ冗長性（同一データの重複保存）、(2) データ不整合（重複データ間の矛盾）、(3) データ依存性（物理構造の変更がプログラムに影響）、(4) データ孤立（データが複数ファイルに散在し新規プログラムからのアクセスが困難）、(5) 並行アクセスの制限（ファイル単位のロック）、(6) セキュリティの欠如
- **一次ソース**: "Before the Advent of Database Systems" (Database Design textbook, Open Textbook)
- **URL**: <https://opentextbc.ca/dbdesign01/chapter/chapter-1-before-the-advent-of-database-systems/>
- **注意事項**: 第1回でも4つの問題（永続化、整合性、検索、並行制御）を扱ったが、第2回ではファイルベースシステム固有の問題として冗長性・不整合・依存性に焦点を当てる
- **記事での表現**: ファイルベースシステムの6つの問題を、DBMS概念誕生の動機として体系的に記述

## 10. Perlのflock()とCGI時代のファイルロック

- **結論**: Perlのflock()はファイルに対するアドバイザリーロックを提供。CGI環境ではWebサーバが複数の同時接続を処理するためにプロセスをコピーするため、複数の接続が同時に同一ファイルにアクセスする可能性がある。共有ロック（読み取り用）と排他ロック（書き込み用）の2種類。アドバイザリーロックであるため、flock()を使用しないプログラムからは保護されない
- **一次ソース**: Perl公式ドキュメント, "flock - Perldoc Browser"
- **URL**: <https://perldoc.perl.org/functions/flock>
- **注意事項**: 佐藤の体験として記述する。1990年代後半のCGI+Perlの典型的なデータ管理パターン
- **記事での表現**: 佐藤のPerlスクリプト時代の体験として、flock()によるファイルロックの実装と限界を記述

## 11. バッチ処理とシーケンシャルファイル処理（1960年代）

- **結論**: 1960年代には、磁気テープ上のプログラムをバッチで順次実行する方式が主流。マスターファイルをテープ上に保存し、顧客番号などの識別番号でソート。磁気テープ上のレコードの繰り返しマージによるソートは時間がかかった。データ処理の典型的なワークフロー: カード→カードリーダー→データ検証→テープへの書き出し→マスターファイルと同一順序にソート→バッチ処理
- **一次ソース**: Wikipedia, "Batch processing"
- **URL**: <https://en.wikipedia.org/wiki/Batch_processing>
- **注意事項**: テープベースのバッチ処理の非効率さがDASDs+ISAMへの移行動機となった
- **記事での表現**: テープ時代のデータ処理ワークフローの制約として記述

## 12. VSAM（Virtual Storage Access Method、1972年）

- **結論**: IBMが1970年代初頭に開発。OS/VS1（1972年）およびOS/VS2（1973年）とともにリリース。System/370アーキテクチャの仮想記憶システムへの移行に伴い開発。ISAMの後継として、より機能的で使いやすく、性能とデバイス依存性の問題を解決。4つのデータセット構成: KSDS（Key-Sequenced）、RRDS（Relative Record）、ESDS（Entry-Sequenced）、LDS（Linear）
- **一次ソース**: Wikipedia, "Virtual Storage Access Method"
- **URL**: <https://en.wikipedia.org/wiki/Virtual_Storage_Access_Method>
- **注意事項**: 第2回では深入りせず、ISAMの後継として簡潔に言及
- **記事での表現**: ISAMの発展形としてVSAMを簡潔に言及
