# ファクトチェック記録：第6回「MS-DOSとCOMMAND.COM――もうひとつのCLI系譜」

## 1. CP/Mの開発とGary Kildall

- **結論**: Gary Kildallは1974年にCP/M（Control Program for Microcomputers）の最初の動作プロトタイプをPacific Groveで実証した。Intel Intellec-8開発システム上で、Shugart Associates製8インチフロッピーディスクドライブを接続して動作させた。Kildallは自ら設計したPL/M（Programming Language for Microcomputers）でCP/Mを記述した。BIOSの発明者でもある。妻Dorothyとともに「Intergalactic Digital Research」（後にDigital Research, Inc.に改名）を設立し、CP/Mを商業化した。1981年9月までに25万以上のCP/Mライセンスが販売された
- **一次ソース**: IEEE Milestone認定, Computer History Museum
- **URL**: <https://ethw.org/Milestones:The_CP/M_Microcomputer_Operating_System,_1974>, <https://computerhistory.org/blog/gary-kildall-40th-anniversary-of-the-birth-of-the-pc-operating-system/>
- **注意事項**: CP/Mはマイクロプロセッサ向けの最初の商用OSであり、後のMS-DOSのルック&フィールのモデルとなった。CP/MのコマンドインタフェースはCCP（Console Command Processor）と呼ばれ、DIR, ERA, REN, SAVE, TYPE, USERが内蔵コマンド、PIP.COMやSTAT.COMなどがトランジェントコマンドだった
- **記事での表現**: 「1974年、Naval Postgraduate Schoolの教官だったGary Kildallが開発したCP/Mは、マイクロコンピュータ向けの最初の商用OSだった」

## 2. 86-DOS（QDOS）とTim Paterson

- **結論**: Tim Patersonは1978年6月にワシントン大学を卒業後、Seattle Computer Products（SCP）に入社。SCP製の8086プロセッサボードにOSがなく販売が低迷していたため、Digital ResearchがCP/Mの8086版を遅延させている状況を受け、1980年4月からQDOS（Quick and Dirty Operating System）の開発を開始した。1980年7月にバージョン0.10が完成。1980年12月に86-DOS 0.33としてリリースされた
- **一次ソース**: Wikipedia "86-DOS", "Tim Paterson"
- **URL**: <https://en.wikipedia.org/wiki/86-DOS>, <https://en.wikipedia.org/wiki/Tim_Paterson>
- **注意事項**: 86-DOSはCP/Mのルック&フィールをクローンした8086向けOS。FAT12ファイルシステムの導入とディスクセクタバッファリングの改善がCP/Mとの主な違い。開発期間は約4ヶ月
- **記事での表現**: 「1980年4月、Seattle Computer ProductsのTim Patersonは、CP/Mの8086版が一向にリリースされない状況にしびれを切らし、自ら互換OSの開発を始めた。QDOS――Quick and Dirty Operating Systemという名が、その開発の切迫感を物語っている」

## 3. MS-DOS 1.0のリリースとIBM PC

- **結論**: Microsoftは1980年12月にSCPから86-DOSの非独占ライセンスを25,000ドルで取得。1981年5月にTim Patersonを雇用してIBM PC（Intel 8088搭載）への移植を行った。1981年7月にSCPから全権利を50,000ドルで購入。1981年7月27日にMS-DOSに改名。IBMはこれをPC DOS 1.0として1981年8月にIBM PC 5150とともにリリースした
- **一次ソース**: Wikipedia "MS-DOS", "86-DOS", Computer History Museum
- **URL**: <https://en.wikipedia.org/wiki/MS-DOS>, <https://en.wikipedia.org/wiki/86-DOS>, <https://computerhistory.org/blog/microsoft-ms-dos-early-source-code/>
- **注意事項**: IBMはPC DOS 1.0をIBM PC向けの3つのOS選択肢の一つとして提供した。Microsoftは1年以内に70社以上にMS-DOSをライセンスした
- **記事での表現**: 「1981年8月、IBMは初のパーソナルコンピュータIBM PC 5150を発売した。そのOSとして選ばれたのがPC DOS 1.0――Microsoftが86-DOSを買い取り、改名したものだった」

## 4. MS-DOS 2.0のUNIX的機能とパイプの実装

- **結論**: MS-DOS 2.0は1983年3月にリリース。階層的ディレクトリ構造（UNIXスタイル）、ハンドルベースのファイル管理、継承可能でリダイレクト可能なファイルハンドル、環境変数、デバイスドライバサポートなどUNIX的機能を導入。パイプはシングルタスクOSという制約のため、一時ファイルを経由して実装された。UNIXのようなカーネルバッファによるプロセス間通信ではなく、ディスクファイルを中間ストレージとして使用した
- **一次ソース**: Wikipedia "MS-DOS", OS/2 Museum
- **URL**: <https://en.wikipedia.org/wiki/MS-DOS>, <https://www.os2museum.com/wp/dos/dos-2-0-and-2-1/>
- **注意事項**: MicrosoftはXenixというUNIXベースのOSも持っており、MS-DOSの将来版をシングルユーザーXenixと区別できないレベルにする計画だった。マルチユーザー機能は意図的に省かれた
- **記事での表現**: 「MS-DOS 2.0（1983年3月）はUNIXから多くを学んだ。階層的ディレクトリ構造、ファイルハンドル、リダイレクション。だがパイプの実装は根本的に異なった。シングルタスクOSであるDOSでは、二つのプログラムを同時に実行できない。DOSのパイプは、最初のコマンドの出力を一時ファイルに書き出し、次のコマンドがそれを読み込むという方式で実現された」

## 5. パス区切り文字 `/` vs `\` の歴史

- **結論**: MS-DOS 1.0は既に`/`をコマンドオプションのスイッチ文字として使用していた。この慣習はCP/Mからではなく、DEC（Digital Equipment Corporation）のOSとMicrosoft自身の8080用ツール（1977年以前のF80 FORTRAN, M80マクロアセンブラ等）に由来する。MS-DOS 2.0でディレクトリ機能を追加する際、IBMがDOS 1.xとの互換性維持を要求し、`/`をパス区切りに転用することを拒否。Microsoftは視覚的に最も近い`\`を代替として選択した
- **一次ソース**: OS/2 Museum, Larry Osterman（元Microsoft）
- **URL**: <https://www.os2museum.com/wp/why-does-windows-really-use-backslash-as-path-separator/>
- **注意事項**: 「CP/Mが`/`をスイッチ文字として使っていた」という通説は正確ではない。Microsoftは公式に、`/`スイッチ文字はDECから来たと述べている
- **記事での表現**: 「パス区切り文字が`\`である理由は、MS-DOS 1.0が既に`/`をコマンドスイッチとして使用していたからだ。この慣習はDECのOSに由来する。MS-DOS 2.0でディレクトリを導入する際、IBMは互換性維持を求め、`/`の転用を拒否した。Microsoftは視覚的に最も似た`\`を選んだ」

## 6. ワイルドカード展開の設計差異

- **結論**: UNIXではシェルがワイルドカード（グロブ）を展開し、展開後のファイル名リストをプログラムのargvに渡す。DOSおよびWindowsでは、コマンドインタプリタは未展開の引数をプログラムに渡し、Cランタイムライブラリまたはプログラム自身がワイルドカード展開を行う。Windowsプログラムは長いコマンドライン文字列を受け取り、分割・クォーティング・グロブ展開はプログラムの責任
- **一次ソース**: Wikipedia "glob (programming)", delorie.com DJGPP FAQ
- **URL**: <https://en.wikipedia.org/wiki/Glob_(programming)>, <http://www.delorie.com/djgpp/faq/command-line/globbing.html>
- **注意事項**: この設計差異にはトレードオフがある。UNIX方式はシェルが一貫して展開するため予測可能だが、プログラムがワイルドカードを独自解釈したい場合に制約となる。DOS/Windows方式はプログラムに柔軟性を与えるが、セキュリティバグの温床にもなりうる
- **記事での表現**: 「UNIXではシェルがワイルドカードを展開してからプログラムに渡す。DOSでは展開の責任はアプリケーション側にある。この設計判断の違いは、OSのアーキテクチャの根本的な差異を反映している」

## 7. cmd.exeとWindows NT

- **結論**: cmd.exeはWindows NT 3.1（1993年）で初めて登場した。開発者はTherese Stowell。COMMAND.COMの後継として、32ビット（後に64ビット）のコンソールアプリケーションとして実装された。IF, SET, FORコマンドの拡張、遅延環境変数展開、コマンド履歴（矢印キーアクセス）、自動パス補完などの改良が加えられた
- **一次ソース**: Wikipedia "cmd.exe"
- **URL**: <https://en.wikipedia.org/wiki/Cmd.exe>
- **注意事項**: IA-32版のOS/2およびWindows NTでは、仮想DOSマシン上でCOMMAND.COMも利用可能だった
- **記事での表現**: 「1993年、Windows NT 3.1とともにcmd.exeが登場した。Therese Stowellが開発したこの32ビットコマンドプロセッサは、COMMAND.COMの後継として設計された」

## 8. PowerShellの誕生

- **結論**: Jeffrey Snoverが2002年8月に「Monad Manifesto」と題する白書を発表。2003年10月のProfessional Development Conferenceで初の公開デモ。2005年6月17日に最初の公開ベータ版。2006年4月25日にMonadからWindows PowerShellに改名。2006年11月14日にPowerShell 1.0正式リリース。Windows XP SP2、Windows Server 2003 SP1、Windows Vista向け
- **一次ソース**: Wikipedia "PowerShell", Microsoft DevBlogs
- **URL**: <https://en.wikipedia.org/wiki/PowerShell>, <https://devblogs.microsoft.com/powershell/its-a-wrap-windows-powershell-1-0-released/>
- **注意事項**: PowerShell Core（クロスプラットフォーム、オープンソース）は2016年8月にリリース
- **記事での表現**: 「2002年8月、MicrosoftのJeffrey Snoverは『Monad Manifesto』を発表した。テキストのパースに依存するUNIXパイプラインへの根本的な批判を含むこの文書は、4年後にPowerShellとして結実する」

## 9. Windows Script Host

- **結論**: WSH 1.0は1998年にWindows 98とともにリリースされた。VBScriptとJScriptをサポート。cscript.exe（コマンドライン）とwscript.exe（GUI）の2つのインターフェースを提供。Windows 95ではService Pack後のインストールディスクにオプションとして収録、Windows NT 4.0ではService Pack 4で提供。WSH 2.0は1999年にWindows 2000とともにリリース
- **一次ソース**: Wikipedia "Windows Script Host"
- **URL**: <https://en.wikipedia.org/wiki/Windows_Script_Host>
- **注意事項**: WSHはDOSバッチファイルとPowerShellの間を埋める過渡的技術だった
- **記事での表現**: 「1998年、MicrosoftはWindows Script Host（WSH）をWindows 98とともに提供した。VBScriptとJScriptによるスクリプティング環境だったが、CLIとの統合は限定的だった」

## 10. CP/MのCCP（Console Command Processor）

- **結論**: CP/MのコマンドインタフェースはCCP（Console Command Processor）と呼ばれた。BIOSとBDOSはメモリ常駐だが、CCPはアプリケーションにより上書き可能で、アプリケーション終了後に自動的に再ロードされた。内蔵コマンドはDIR, ERA, REN, SAVE, TYPE, USER。トランジェントコマンドは.COM拡張子のファイルとしてディスク上に存在した（PIP.COM, STAT.COMなど）。COMMAND.COMの「内部コマンドと外部コマンド」の区分は、このCP/MのCCPの設計を直接継承している
- **一次ソース**: CP/M 2.2 Manual, Wikipedia "CP/M"
- **URL**: <http://www.gaby.de/cpm/manuals/archive/cpm22htm/ch1.htm>, <https://en.wikipedia.org/wiki/CP/M>
- **注意事項**: CCPがメモリ常駐でない理由は、限られたメモリ空間（64KB）を最大限アプリケーションに使わせるため
- **記事での表現**: 「CP/MのCCP（Console Command Processor）は、メモリの制約から巧みに設計されていた。アプリケーション実行時にはCCP自体がメモリから追い出され、終了後に自動再ロードされる」

## 11. FAT12とファイル名の8.3制限

- **結論**: CP/Mおよび初期のDOSは8.3形式のファイル名（最大8文字のファイル名 + 最大3文字の拡張子）を使用した。FAT12/FAT16ファイルシステムはケースインセンシティブで、ファイル名は大文字に変換して格納された。Windows 95のVFATでロングファイルネームとケース保存が実現された
- **一次ソース**: Wikipedia "8.3 filename"
- **URL**: <https://en.wikipedia.org/wiki/8.3_filename>
- **注意事項**: 大文字格納は当時のファイルシステムの単純さと、メモリ制約下での比較処理の効率化が理由
- **記事での表現**: 「CP/MもDOSも、ファイル名は8文字+拡張子3文字の『8.3形式』に制限されていた。FATファイルシステムはすべてのファイル名を大文字に変換して格納した」

## 12. DOSBoxエミュレータ

- **結論**: DOSBoxは2002年にリリースされたオープンソースのx86 DOSエミュレータ。DOSの技術が陳腐化し、Windows 2000/XP以降のプロテクトモードアーキテクチャが古いDOSゲーム/ツールとの互換性を壊した状況で開発された。2015年10月時点で2,500万回以上ダウンロード
- **一次ソース**: Wikipedia "DOSBox", DOSBox公式サイト
- **URL**: <https://en.wikipedia.org/wiki/DOSBox>, <https://www.dosbox.com/>
- **注意事項**: ハンズオンではDOSBox（またはDOSBox-X）を使用してMS-DOSのCLI環境を体験させる
- **記事での表現**: 「DOSBoxは2002年にリリースされたオープンソースのDOSエミュレータだ」
