# ファクトチェック記録：第4回「テレタイプからCRT端末へ――"tty"の起源と端末の進化」

## 1. Teletype Model 33（1963年）

- **結論**: 1963年に商用製品として発表。元々は米国海軍向けに設計。ASCIIを最初に商用利用した端末。110ボー（毎秒約10文字）、7ビットASCIIエンコーディング、大文字のみ。20mA電流ループインターフェース。ASR（自動送受信）、KSR（キーボード送受信）、RO（受信のみ）の3モデル。8.5インチ幅の紙に10文字/インチで印字、74文字行。1975年までに50万台以上が生産された
- **一次ソース**: Wikipedia, "Teletype Model 33"
- **URL**: <https://en.wikipedia.org/wiki/Teletype_Model_33>
- **注意事項**: XON/XOFF（Ctrl-Q/Ctrl-S）のフロー制御はModel 33の割り当てが事実上の標準になった
- **記事での表現**: 1963年、Teletype Model 33が登場した。ASCIIを最初に商用実装したこの端末は、110ボーで動作し、50万台以上が生産された

## 2. ASCIIの歴史（1963年、1967年改定）

- **結論**: ASCIIの最初の版は1963年に発行。1967年に大幅改定。Bob Bemer（「ASCIIの父」と呼ばれる）がESC（エスケープ）文字、バックスラッシュ、波括弧を導入。7ビットで128文字、うち33文字が制御文字。X3委員会が策定。1963年にAT&TのTWXネットワークでTeletype Model 33と共に最初の商用利用
- **一次ソース**: Wikipedia, "ASCII"; ETHW, "American Standard Code for Information Interchange ASCII, 1963"
- **URL**: <https://en.wikipedia.org/wiki/ASCII>, <https://ethw.org/Milestones:American_Standard_Code_for_Information_Interchange_ASCII,_1963>
- **注意事項**: Bemerのエスケープ文字の導入は後のターミナル制御シーケンスの基盤となった
- **記事での表現**: 1963年、ASCIIの最初の版が発行された。Bob Bemerが導入したESC文字は、後にターミナル制御シーケンスの鍵となる

## 3. キャリッジリターン（CR）とラインフィード（LF）の起源

- **結論**: 機械式タイプライターとテレタイプの物理動作に由来。CRはキャリッジ（印字ヘッド搭載台）を左端に戻す動作、LFは紙を1行送る動作。テレタイプでは印字ヘッドが右端から左端に戻るのに時間がかかるため（Model 33では0.2秒、2文字分の時間）、CRとLFを分離する必要があった。Baudot符号では1870年代から別々の制御文字として存在。UNIXはLFのみ、DOS/WindowsはCR+LFを改行に採用
- **一次ソース**: Wikipedia, "Newline"; Wikipedia, "Carriage return"
- **URL**: <https://en.wikipedia.org/wiki/Newline>, <https://en.wikipedia.org/wiki/Carriage_return>
- **注意事項**: この改行コードの差異は2026年の今もGitの設定等で問題になる
- **記事での表現**: CRとLFが別々の文字である理由は、テレタイプの印字ヘッドが物理的に戻るための時間が必要だったからだ

## 4. Teletype社の歴史と「tty」の起源

- **結論**: 1902年、Charles Krumが電信タイプライターを発明（Joy Morton出資）。Morkrum社としてスタートし、競合Kleinschmidt Electric Companyと合併後、Teletype Corporationに改名。1930年にAT&Tが買収しWestern Electricの一部に。「tty」はTeletypeの略。DECのRT-11 OSでシリアル通信回線を「tt」で始まるデバイス名にしたのが広まり、UNIXでも/dev/ttyとして採用された。1970年、RitchieとThompsonがPDP-11上のUNIX開発でModel 33テレタイプをインターフェースとして使用
- **一次ソース**: computer.rip, "a history of the tty"; Wikipedia, "Teleprinter"
- **URL**: <https://computer.rip/2024-02-25-a-history-of-the-tty.html>, <https://en.wikipedia.org/wiki/Teleprinter>
- **注意事項**: 「tty」がDEC由来かAT&T由来かは議論があるが、いずれにせよTeletype社の名前に遡る
- **記事での表現**: /dev/ttyのttyはTeletype Corporationに遡る。UNIXの開発者たちはModel 33テレタイプをインターフェースとして使っていた

## 5. DEC VT05（1970年）

- **結論**: 1970年11月、Fall Joint Computer Conferenceで発表。DECの最初の自立型CRTコンピュータ端末。72列x20行の大文字のみASCII表示。最大2400ボーの非同期通信（300ボー以上ではフィル文字が必要）。前方スクロールと直接カーソルアドレッシングのみをサポート。点滅・太字・下線・反転などの文字修飾なし。後のVT50/VT52シリーズの基盤となった
- **一次ソース**: Wikipedia, "VT05"; vt100.net, "Digital's Video Terminals"
- **URL**: <https://en.wikipedia.org/wiki/VT05>, <https://vt100.net/dec/vt_history>
- **注意事項**: 紙を使わない最初のDEC端末として画期的だったが、機能は限定的
- **記事での表現**: 1970年、DEC VT05が登場した。紙テープからCRTへの移行を象徴する初のDEC製ビデオ端末だった

## 6. DEC VT52（1975年）

- **結論**: 1975年9月に発表。24行x80列表示。95のASCII文字に加え32のグラフィック文字をサポート。双方向スクロール。独自のエスケープシーケンスによるカーソル制御（ESC + 1文字が基本、直接カーソル位置指定はESC Y + 座標2文字）。VT100の前身
- **一次ソース**: Wikipedia, "VT52"
- **URL**: <https://en.wikipedia.org/wiki/VT52>
- **注意事項**: VT52のエスケープシーケンスは独自仕様で、ANSI標準ではない。VT100がANSI準拠へ移行した
- **記事での表現**: 1975年、VT52は24行80列の画面と独自エスケープシーケンスによるカーソル制御を提供した

## 7. DEC VT100（1978年）

- **結論**: 1978年8月に発表。ANSI X3.64標準（1977年末発行）に準拠した最初の端末の一つ。24x80または14x132文字表示。12インチ画面。完全なUS ASCIIキャラクターセット（128コード）。50～19,200 bpsの通信速度。Intel 8080マイクロプロセッサを初めて搭載したDEC端末。VTシリーズ合計で600万台以上が販売された
- **一次ソース**: Wikipedia, "VT100"; Columbia University, "The DEC VT100 Terminal"
- **URL**: <https://en.wikipedia.org/wiki/VT100>, <https://www.columbia.edu/cu/computinghistory/vt100.html>
- **注意事項**: VT100のANSI準拠が事実上の業界標準となり、後のターミナルエミュレータの基準となった
- **記事での表現**: 1978年、VT100はANSI X3.64に準拠した決定版端末として登場し、VTシリーズ累計600万台以上の販売の礎を築いた

## 8. IBM 3270（1971年）

- **結論**: 1971年にIBMが発表。ブロックモード端末で、文字単位ではなくデータブロック単位で通信しホストへの割り込みを最小化する設計。80x24表示が標準。同軸ケーブルによる高速独自通信インターフェース。IBM 2260の後継。80x24の画面サイズはこの端末の普及により業界標準となった
- **一次ソース**: Wikipedia, "IBM 3270"; righto.com, "IBM, sonic delay lines, and the history of the 80x24 display"
- **URL**: <https://en.wikipedia.org/wiki/IBM_3270>, <http://www.righto.com/2019/11/ibm-sonic-delay-lines-and-history-of.html>
- **注意事項**: 80x24はIBM 3270の成功により事実上の標準となったが、80列はパンチカードに由来する
- **記事での表現**: 1971年のIBM 3270は80x24のブロックモード端末で、この画面サイズが業界標準として定着した

## 9. ベル文字（BEL, ASCII 7）

- **結論**: ASCII値7。テレプリンターとテレタイプライターに搭載された小さな電気機械式ベルを鳴らすための制御コード。1870年代のBaudot符号の時代からベル文字は存在していた。ビデオ端末はスピーカーやブザーで同じ機能を代替。現代のターミナルエミュレータではシステムサウンドの再生やビジュアルベルとして実装されている。C言語（1972年頃）で`\a`エスケープシーケンスとして導入
- **一次ソース**: Wikipedia, "Bell character"
- **URL**: <https://en.wikipedia.org/wiki/Bell_character>
- **注意事項**: echo -e '\a' で現在のターミナルでもベル音を鳴らせる
- **記事での表現**: ASCIIのBEL文字（値7）は、テレタイプの物理的なベルを鳴らすための制御コードだった

## 10. xterm（1984年）

- **結論**: 1984年夏、Jim GettyがVAXStation 100向けの作業を開始した際、学生のMark Vandevoorde がスタンドアローンのターミナルエミュレータとして作成。DEC VT102の仕様をベースとし、後にVT220, VT320, VT420, VT520, Tektronix 4014の機能を統合。X Window System向けのターミナルエミュレータで、ハードウェア端末をソフトウェアで置き換えた代表的な例
- **一次ソース**: Wikipedia, "xterm"
- **URL**: <https://en.wikipedia.org/wiki/Xterm>
- **注意事項**: 現在もThomas Dickeyによりメンテナンスされている
- **記事での表現**: 1984年、xtermがX Window System向けに作成された。ハードウェア端末をソフトウェアで置き換える時代の幕開けだった

## 11. Ctrl+C, Ctrl+D, Ctrl+Zの制御文字

- **結論**: ASCIIの制御文字として定義。Ctrl+C（ETX, ASCII 3）はUNIXでSIGINT信号を送信しプロセスを中断。Ctrl+D（EOT, ASCII 4）はEnd of Transmissionに由来し、UNIXではEOFを示す。Ctrl+Z（SUB, ASCII 26）はUNIXでSIGTSTP信号を送信しプロセスを一時停止。これらはテレタイプ時代の制御文字がUNIXのシグナル機構に転用されたもの
- **一次ソース**: stty man page; Linus Akesson, "The TTY demystified"
- **URL**: <https://man7.org/linux/man-pages/man1/stty.1.html>, <https://www.linusakesson.net/programming/tty/>
- **注意事項**: stty -aコマンドで現在の制御文字の割り当てを確認できる
- **記事での表現**: Ctrl+CがSIGINTを送るのは、テレタイプ時代のETX（End of Text）制御文字がUNIXのシグナル機構に転用された結果だ
