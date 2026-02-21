# ファクトチェック記録：第5回「ANSIエスケープシーケンス――端末の表現力の拡張」

## 1. ECMA-48の初版（1976年9月）

- **結論**: ECMA-48の初版は1976年9月に発行された。ANSI X3.64は1979年に採択。ISO 6429は1983年に国際標準化。ECMA-48は現在第5版（1991年）
- **一次ソース**: ECMA International, "ECMA-48 - Control functions for coded character sets"
- **URL**: <https://ecma-international.org/publications-and-standards/standards/ecma-48/>
- **注意事項**: ECMA-48（1976年）が先で、ANSI X3.64（1979年）が後。ANSIは1994年にX3.64を撤回し、国際標準ISO 6429に委ねた。1981年にFIPS publication 86として米国政府に採用
- **記事での表現**: 「ECMA-48の初版は1976年9月に発行され、ANSI X3.64は1979年に採択された。VT100（1978年）はECMA-48の初版に準拠していた」

## 2. termcapデータベース（Bill Joy, 1977-1978年）

- **結論**: Bill Joyが1977年9月に「ttycap」として開発開始。1BSDで1978年3月にttycapとして初リリース。3BSD（1979年12月）でtermcapとして標準化。UCバークレーの大学院生時代。viエディタのポータブルな画面制御のために開発
- **一次ソース**: Wikipedia, "Termcap"
- **URL**: <https://en.wikipedia.org/wiki/Termcap>
- **注意事項**: ブループリントには「1978年, Bill Joy」とあるが、開発開始は1977年9月。1BSDリリースが1978年3月。ITS（Incompatible Timesharing System）の端末データストアに影響を受けた
- **記事での表現**: 「Bill Joyは1977年にttycapとして開発を開始し、1978年の1BSDで初めてリリースした。viエディタを異なる端末で動作させるためのポータブルな抽象化レイヤーだった」

## 3. curses ライブラリ（Ken Arnold, UCB）

- **結論**: Ken Arnoldが1978年にUCバークレーでBSD UNIX向けに開発。名前は "cursor optimization" の駄洒落。termcapライブラリの関数を再利用して構築。viエディタなどカーソル指向プログラムのサポートが目的
- **一次ソース**: Wikipedia, "curses (programming library)"
- **URL**: <https://en.wikipedia.org/wiki/Curses_(programming_library)>
- **注意事項**: ブループリントの「1978年, Ken Arnold, UCB」は正確
- **記事での表現**: 「Ken Arnoldは1978年にUCバークレーでcursesライブラリを開発した。名前は "cursor optimization" の駄洒落である」

## 4. ncurses（1993年）

- **結論**: 元はPavel Curtisが1982年頃にpcursesとして作成。Zeyd Ben-Halimが1991年後半に開発を引き継ぎ、1993年11月にncurses 1.8.1として初の主要リリース。Eric S. Raymondがバージョン1.8.8（1995年5月）まで駆動。1996年以降Thomas Dickeyがメンテナ
- **一次ソース**: Wikipedia, "ncurses"
- **URL**: <https://en.wikipedia.org/wiki/Ncurses>
- **注意事項**: ブループリントの「1993年」は正確。ncursesは "new curses" の略
- **記事での表現**: 「ncursesは1993年にncurses 1.8.1としてリリースされ、1996年以降Thomas Dickeyがメンテナンスを担当している」

## 5. terminfoデータベース（AT&T System V）

- **結論**: terminfoはUNIX System V Release 2（1984年頃）に搭載され、termcapの後継として位置づけられた。バイナリ形式で格納され、ディレクトリ階層を利用した検索でtermcapより高速。BSDはtermcapを使い続け、System Vはterminfoを採用
- **一次ソース**: Wikipedia, "Terminfo"
- **URL**: <https://en.wikipedia.org/wiki/Terminfo>
- **注意事項**: termcap→terminfoの移行はBSD vs System Vの文化対立の一面
- **記事での表現**: 「terminfoはAT&TのUNIX System V Release 2で導入され、termcapのバイナリ版後継として位置づけられた」

## 6. 端末間の非互換性問題（1970-80年代）

- **結論**: 1970年代後半〜1980年代初頭、Lear-Siegler, Data General, DEC, Hazeltine, Heath/Zenith, HP, IBM, Televideo, Wyseなど多数のメーカーが互換性のないエスケープシーケンスを使用。VT100のANSI X3.64準拠が収束の契機。ただしANSI準拠端末間でもファンクションキーや文字属性に差異が残存
- **一次ソース**: Wikipedia, "ANSI escape code" / Columbia University "What's a Terminal?"
- **URL**: <https://en.wikipedia.org/wiki/ANSI_escape_code>
- **注意事項**: Hazeltine 1500のカーソル移動は ~, DC1, X, Y という独自方式（ESCではなく~を使用）
- **記事での表現**: 「1970年代後半、端末メーカー各社は独自のエスケープシーケンスを実装していた。同じ『カーソルを移動する』操作が、メーカーごとに異なるバイト列を要求した」

## 7. CSI（Control Sequence Introducer）のプロトコル構造

- **結論**: CSIは ESC [ (0x1B 0x5B) で構成される。8ビット表現では 0x9B 単体。CSIシーケンスの構造: CSI + パラメータ文字列(0-9;) + 中間文字(0x20-0x2F) + 終端文字(0x40-0x7E)。パラメータはセミコロンで区切る
- **一次ソース**: vt100.net, "ANSI Control Functions Summary"
- **URL**: <https://vt100.net/docs/vt510-rm/chapter4.html>
- **注意事項**: C1制御文字としての0x9Bは7ビット環境では使えないため、ESC [ が広く使われる
- **記事での表現**: 「CSIシーケンスは ESC [ で始まり、数値パラメータ（セミコロン区切り）と終端文字で構成される」

## 8. SGR（Select Graphic Rendition）パラメータ

- **結論**: SGRは CSI n m の形式。前景色は30-37、背景色は40-47。属性: 0=リセット, 1=太字, 4=下線, 7=反転。太字(1)を「明るい色」として実装する端末が多く、事実上8色が16色に拡張された
- **一次ソース**: vt100.net, "SGR - Select Graphic Rendition"
- **URL**: <https://vt100.net/docs/vt510-rm/SGR.html>
- **注意事項**: 元のANSI規格では8色（黒・赤・緑・黄・青・マゼンタ・シアン・白）
- **記事での表現**: 「SGRパラメータ30-37が前景色、40-47が背景色を指定する。太字コード(1)を明るい色として実装する端末が多く、事実上16色が利用可能になった」

## 9. 256色拡張（Todd Larason, xterm, 1999年）

- **結論**: 1999年にTodd Larasonがxtermに256色サポートのパッチを提供。パレット構成: 0-7=標準8色, 8-15=高輝度8色, 16-231=6x6x6 RGBカラーキューブ（216色）, 232-255=グレースケール24段階。エスケープシーケンス: ESC[38;5;nm（前景）, ESC[48;5;nm（背景）
- **一次ソース**: Wikipedia, "ANSI escape code" / GitHub termstandard/colors
- **URL**: <https://en.wikipedia.org/wiki/ANSI_escape_code>
- **注意事項**: セミコロン区切りはITU T.416仕様が入手困難だったためSGRパラメータと同じ方式を採用（Thomas Dickeyの証言）。正式にはコロン区切りが規格準拠
- **記事での表現**: 「1999年、Todd LarasonがxtermにRGBカラーキューブとグレースケールランプを含む256色パレットのサポートを追加した」

## 10. 24ビットTrue Color

- **結論**: 2012年にThomas Dickeyがxtermで規格準拠の24ビットカラー構文を修正。ESC[38;2;r;g;bm（前景）, ESC[48;2;r;g;bm（背景）。2016年にWindows 10のコンソールがANSIエスケープコード（24ビットカラー含む）をサポート
- **一次ソース**: Chad Austin, "I Just Wanted Emacs to Look Nice" / GitHub termstandard/colors
- **URL**: <https://chadaustin.me/2024/01/truecolor-terminal-emacs/>
- **注意事項**: 24ビットカラーの標準は ITU T.416 (ISO 8613-6) に由来
- **記事での表現**: 「24ビットTrue Colorは約1677万色の表現を可能にし、2012年以降のxtermや主要なターミナルエミュレータで広くサポートされている」

## 11. tputコマンドの歴史

- **結論**: Bill Joyが1980年10月に4BSD開発中にtputを作成。UNIX System Vで1980年代初頭に提供。terminfo/termcapデータベースを利用して端末能力を抽象的に利用するコマンド。ncursesが1995年6月にmytinfoコードを統合し-Sオプションを追加
- **一次ソース**: Wikipedia, "tput"
- **URL**: <https://en.wikipedia.org/wiki/Tput>
- **注意事項**: tputはOpen Groupが-Tオプション（端末タイプ指定）とinit/clear/resetキーワードを定義
- **記事での表現**: 「tputコマンドはtermcap/terminfoデータベースを参照し、端末の種類に応じた適切なエスケープシーケンスを出力する抽象化レイヤーである」
