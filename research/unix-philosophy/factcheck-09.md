# ファクトチェック記録：第9回「BSDとSystem V——分裂の始まり」

## 1. BSDの起源と1BSDのリリース

- **結論**: 1BSD（Berkeley Software Distribution）は1978年3月9日にリリースされた。Bill Joyがバークレーの大学院生として1977年にコンパイル作業を開始し、V6 UNIXへのアドオンとして配布した。主要コンポーネントはPascalコンパイラとex行エディタ。約30本のテープが無料配布された
- **一次ソース**: Wikipedia "Berkeley Software Distribution"; Kirk McKusick, "Twenty Years of Berkeley Unix", O'Reilly Open Sources
- **URL**: <https://en.wikipedia.org/wiki/Berkeley_Software_Distribution>, <https://www.oreilly.com/openbook/opensources/book/kirkmck.html>
- **注意事項**: 「1977年にBSD誕生」とする記述もあるが、これはJoyが作業を開始した年。正式リリースは1978年3月9日
- **記事での表現**: 「1977年、カリフォルニア大学バークレー校の大学院生だったBill Joyが、UNIXの改良版を集め始めた。翌1978年3月9日、最初のBerkeley Software Distribution（1BSD）がリリースされた」

## 2. 2BSDと3BSDのリリース

- **結論**: 2BSDは1979年5月リリース。vi（exのビジュアル版）とC shell（csh）を含む。3BSDは1979年末リリース。VAX向けの完全なOS（仮想メモリ実装を含む）
- **一次ソース**: Wikipedia "History of the Berkeley Software Distribution"
- **URL**: <https://en.wikipedia.org/wiki/History_of_the_Berkeley_Software_Distribution>
- **注意事項**: 3BSDの仮想メモリ実装の成功が、DARPAの資金提供を引き出す大きな要因となった
- **記事での表現**: 「1979年5月の2BSDにはviエディタとC shellが含まれ、同年末の3BSDでVAX向け仮想メモリ実装を伴う完全なオペレーティングシステムとなった」

## 3. DARPAの資金提供とCSRGの設立

- **結論**: 1979年秋、Bob Fabryがバークレーの拡張UNIX開発の提案書を作成。1980年4月にDARPAとの契約を締結し、18ヶ月の契約でCSRG（Computer Systems Research Group）を設立。4.2BSDの設計を指導する運営委員会がDARPAのDuane Adamsにより1981年4月に組織された
- **一次ソース**: Wikipedia "Computer Systems Research Group"; Kirk McKusick, "Twenty Years of Berkeley Unix"
- **URL**: <https://en.m.wikipedia.org/wiki/Computer_Systems_Research_Group>, <https://www.oreilly.com/openbook/opensources/book/kirkmck.html>
- **注意事項**: 運営委員会にはBell LabsのDennis Ritchieも参加していた
- **記事での表現**: 「1980年、DARPAはバークレーのCSRGに資金を提供し、UNIXの拡張開発を委託した」

## 4. 4.2BSDとTCP/IP実装（1983年）

- **結論**: 4.2BSDは1983年8月にリリース。TCP/IPネットワーキングプロトコルスイートをカーネルに直接実装した最初のBSD。Berkeley socketsもこのリリースで導入。BBNの公式実装とBSD実装が競合したが、DARPAのテストによりBSD版が優れていると判定された
- **一次ソース**: Wikipedia "Berkeley sockets"; Klara Systems "History of FreeBSD - Part 4: BSD and TCP/IP"
- **URL**: <https://en.wikipedia.org/wiki/Berkeley_sockets>, <https://klarasystems.com/articles/history-of-freebsd-part-4-bsd-and-tcp-ip/>
- **注意事項**: Berkeley socketsは現代のすべての主要OSにおけるネットワークプログラミングの事実上の標準APIとなった
- **記事での表現**: 「1983年8月の4.2BSDがTCP/IPをカーネルに実装し、Berkeley socketsという革新的なネットワークプログラミングAPIを導入した。このAPIは現代のすべての主要OSに受け継がれている」

## 5. AT&T System IIIとSystem Vのリリース

- **結論**: System IIIは1981年末に発表、1982年にBell Labs外部へ初リリース。V7 UNIX、PWB/UNIX 2.0、CB UNIX 3.0、UNIX/RT、UNIX/32Vの統合。System Vは1983年1月にリリース（内部名Unix 5.0）。System V Release 2（SVR2）は1984年、SVR3は1987年
- **一次ソース**: Wikipedia "UNIX System III"; Wikipedia "UNIX System V"
- **URL**: <https://en.wikipedia.org/wiki/UNIX_System_III>, <https://en.wikipedia.org/wiki/UNIX_System_V>
- **注意事項**: ブループリントでは「System V（1983年）」としており正確
- **記事での表現**: 「AT&Tは1982年にSystem IIIを、1983年1月にSystem Vをリリースし、UNIXの商用化路線を明確にした」

## 6. BSDとSystem Vの技術的差異

- **結論**: 主要な技術的差異は以下の通り:
  - シグナル処理: BSD = reliable signals（ハンドラがリセットされない、システムコール自動再開）、System V = unreliable signals（V7方式、ハンドラ呼び出し後にデフォルトにリセット）
  - ネットワーキング: BSD = Berkeley sockets、System V = STREAMS + TLI（Transport Layer Interface）
  - ファイルシステム: BSD = FFS（Fast File System、1983年）、System V = s5fs
  - 端末制御: BSD = termios（ジョブ制御対応）、System V = termio
  - IPC: BSD = sockets、System V = メッセージキュー、共有メモリ、セマフォ
- **一次ソース**: W. Richard Stevens, "Advanced Programming in the UNIX Environment"; Wikipedia各項目
- **URL**: <https://en.wikipedia.org/wiki/Berkeley_sockets>, <https://en.wikipedia.org/wiki/Transport_Layer_Interface>
- **注意事項**: Linuxは両方の特徴を取り入れている（Berkeley sockets + System V IPC）
- **記事での表現**: 各差異を技術論セクションで詳述

## 7. psコマンドのBSD構文とSystem V構文

- **結論**: `ps aux`（BSD構文、ハイフンなし）と`ps -ef`（System V構文、ハイフン付き）の差異は歴史的経緯による。V5 UNIX（1974年）のpsマニュアルでは`ps a`のようにハイフンなしで使用。BSD系はこの元の構文を維持、System V系はハイフン付き構文を採用。出力形式も異なり、BSDは%CPU/%MEM/STAT、System VはPPID/STIME
- **一次ソース**: Wikipedia "ps (Unix)"; Ask Ubuntu "standard syntax and BSD syntax"
- **URL**: <https://en.wikipedia.org/wiki/Ps_(Unix)>
- **注意事項**: 現代のLinuxのpsコマンド（procps）は両方の構文をサポートしている
- **記事での表現**: 「`ps aux`と`ps -ef`——同じ機能を持つコマンドが二つの構文で書かれる。この些細に見える違いの背後に、UNIXの分裂の歴史がある」

## 8. BSD FFS（Fast File System）

- **結論**: Marshall Kirk McKusickがバークレーの大学院生としてV7ファイルシステムのレイアウトを最適化し、4.2BSD（1983年）とともにリリース。シリンダグループの導入によりディスクを小チャンクに分割。アクセス速度は従来の最大10倍。論文はACM Transactions on Computer Systems, Vol.2, No.3, 1984年8月に掲載
- **一次ソース**: McKusick et al., "A Fast File System for UNIX", ACM TOCS, 1984
- **URL**: <https://dsf.berkeley.edu/cs262/FFS.pdf>
- **注意事項**: FFSの設計思想（シリンダグループ、複数ブロックサイズ）は現代のファイルシステムにも影響を与えている
- **記事での表現**: 「McKusickが設計したFFS（Fast File System）は、従来のファイルシステムの最大10倍のアクセス速度を実現した」

## 9. UNIX Wars——OSFとUIの対立

- **結論**: 1987年、AT&TとSun MicrosystemsがUNIXの統一に向けた共同作業を開始。1988年5月、これに危機感を抱いたDEC、HP、IBMら7社が「Gang of Seven」としてOpen Software Foundation（OSF）を設立。対抗してAT&TがUnix International（UI）を設立。Scott McNealyが「OSFはOppose Sun Foreverの略」とコメント。SVR4は1988年10月18日に発表され、1989年初頭から商用製品に採用
- **一次ソース**: Wikipedia "Open Software Foundation"; Wikipedia "Unix wars"
- **URL**: <https://en.wikipedia.org/wiki/Open_Software_Foundation>, <https://en.wikipedia.org/wiki/Unix_wars>
- **注意事項**: OSFの最初の提案は1988年1月のDECのArmando Stettnerによるもの（パロアルトのHamilton Avenue会議）
- **記事での表現**: 「1988年、UNIX業界は二つの陣営に分裂した。AT&TとSunの連合に対抗してDEC、HP、IBMらがOSFを結成し、AT&T側はUIを組織した」

## 10. SVR4によるBSD機能の統合

- **結論**: System V Release 4（SVR4、1988年発表/1989年商用展開）は、AT&T USLとSun Microsystemsの共同プロジェクトとして、SVR3、4.3BSD、Xenix、SunOSの技術を統合。Berkeley sockets、FFS互換ファイルシステム、ジョブ制御などBSDの主要機能を取り込んだ。主要プラットフォームはIntel x86とSPARC
- **一次ソース**: Wikipedia "UNIX System V"
- **URL**: <https://en.wikipedia.org/wiki/UNIX_System_V>
- **注意事項**: SVR4は事実上、BSD vs System Vの技術的対立を「統合」で解消しようとした試み
- **記事での表現**: 「1989年のSVR4は、BSDの主要技術をSystem Vに取り込むことで、技術的な分裂の解消を試みた」

## 11. 4.3BSDのリリースと評価

- **結論**: 4.3BSDは1986年6月リリース。4.2BSDの貢献を性能チューニングし、Xerox Network Systemプロトコルのサポートを追加。2006年にInformationWeek誌が「史上最高のソフトウェア」と評価し、「BSDの4.3はインターネットの最大の理論的支柱」とコメント
- **一次ソース**: Wikipedia "History of the Berkeley Software Distribution"
- **URL**: <https://en.wikipedia.org/wiki/History_of_the_Berkeley_Software_Distribution>
- **注意事項**: 4.3BSDの後、VAXプラットフォームからの移行が決定された
- **記事での表現**: 「1986年6月の4.3BSDは、4.2BSDの性能を大幅に改善し、2006年にInformationWeek誌が『史上最高のソフトウェア』と評するほどの完成度に達した」

## 12. Bill Joyのバークレー離脱とSun Microsystems

- **結論**: Bill Joyは1982年にバークレーを離れ、Sun Microsystemsを共同設立。Joyの離脱後、Mike KarelsとMarshall Kirk McKusickがCSRGのリーダーシップを引き継いだ
- **一次ソース**: Wikipedia "Bill Joy"; Britannica "Bill Joy"
- **URL**: <https://en.wikipedia.org/wiki/Bill_Joy>, <https://www.britannica.com/biography/Bill-Joy>
- **注意事項**: SunのSunOSはBSD系であり、JoyはBSDの成果を商用製品に持ち込んだ
- **記事での表現**: 「1982年、JoyはバークレーからSun Microsystemsの共同創業者として転身し、BSDの成果を商用UNIXの世界に持ち込んだ」
