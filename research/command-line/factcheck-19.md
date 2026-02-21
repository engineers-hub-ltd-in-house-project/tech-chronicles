# ファクトチェック記録：第19回「モダンターミナルエミュレータの競争――GPU描画とプロトコル拡張」

## 1. xterm の起源と歴史

- **結論**: xtermは1984年夏、Jim Gettyの学生Mark VandevoordがVAXStation 100（VS100）用のスタンドアロン端末エミュレータとして開発した。X Window Systemより前に誕生し、その後Xの一部として統合された。Thomas E. Dickeyが1990年代から拡張・メンテナンスを継続し、現在もアクティブに開発されている。DEC VT102/VT220の機能を実装
- **一次ソース**: Wikipedia, xterm; invisible-island.net (Thomas Dickey)
- **URL**: <https://en.wikipedia.org/wiki/Xterm>, <https://invisible-island.net/xterm/>
- **注意事項**: xtermの誕生は1984年で、X Window Systemの開発と並行。Mark Vandevoordが原作者、Thomas Dickeyが長年のメンテナ
- **記事での表現**: xterm（1984年、Mark Vandevoorde）として記述。Thomas Dickeyの長年のメンテナンスに言及

## 2. rxvt / urxvt（rxvt-unicode）

- **結論**: rxvtはRob Nationが開発した軽量なxterm代替。Mark Olesenがメンテナンスを引き継いだ。rxvt-unicode（urxvt）は2003年11月にMarc Lehmannがrxvtからフォークして開発開始。Unicode完全対応、Xftフォント対応、クライアント-サーバ方式による省メモリ設計が特徴
- **一次ソース**: Wikipedia, rxvt; software.schmorp.de
- **URL**: <https://en.wikipedia.org/wiki/Rxvt>, <https://software.schmorp.de/pkg/rxvt-unicode.html>
- **注意事項**: rxvtはxtermの「軽量版」として設計。Tektronix 4014エミュレーション等を省略
- **記事での表現**: rxvt→urxvt（2003年、Marc Lehmann）の系譜として記述

## 3. iTerm2

- **結論**: George Nachmanが開発。iTerm（2006年）の後継として2010年頃から開発開始。v1.0は2011年、v2.0は2014年7月。macOS専用、GPL-2.0ライセンス。分割ペイン、Instant Replay、プロファイル、インライン画像表示（独自プロトコル、OSC 1337）等の機能を持つ
- **一次ソース**: Wikipedia, iTerm2; iterm2.com; GitHub gnachman/iTerm2
- **URL**: <https://en.wikipedia.org/wiki/ITerm2>, <https://iterm2.com/>
- **注意事項**: macOS標準のTerminal.appの事実上の代替として広く普及。インライン画像プロトコルは独自仕様
- **記事での表現**: iTerm2（2010年頃、George Nachman）として記述

## 4. Alacritty

- **結論**: Joe Wilmが2017年1月6日にブログで公開を発表。Rust製、OpenGL（ES 2.0）によるGPU描画。「既存のターミナルエミュレータへの不満」が動機。タブやスプリットを意図的に省略したミニマリスト設計。テキストファイルによる設定。大画面のテキスト描画で約500FPSを達成
- **一次ソース**: jwilm.io (Joe Wilm blog); Wikipedia, Alacritty; GitHub alacritty/alacritty
- **URL**: <https://jwilm.io/blog/announcing-alacritty/>, <https://en.wikipedia.org/wiki/Alacritty>
- **注意事項**: 「GPU描画のターミナル」を最初に広く認知させたプロジェクト。性能重視でタブ・スプリットなし
- **記事での表現**: Alacritty（2017年、Joe Wilm、Rust/OpenGL）として記述

## 5. kitty

- **結論**: Kovid Goyal（Calibre電子書籍管理ソフトの作者）が2017年に初回リリース。GPLv3ライセンス。GPU描画に加え、独自のプロトコル拡張（kittyグラフィックスプロトコル、kittyキーボードプロトコル）を積極的に策定。画像表示は24bit RGB、32bit RGBA、PNGをサポート。"kittens"フレームワークによる拡張機能（icatなど）
- **一次ソース**: sw.kovidgoyal.net/kitty; Wikipedia, kitty (terminal emulator); GitHub kovidgoyal/kitty
- **URL**: <https://sw.kovidgoyal.net/kitty/>, <https://en.wikipedia.org/wiki/Kitty_(terminal_emulator)>
- **注意事項**: プロトコル拡張を業界標準にすることを目指している。kittyキーボードプロトコルはiTerm2、Ghostty、foot、WezTerm等で採用が進む
- **記事での表現**: kitty（2017年、Kovid Goyal）として記述。プロトコル拡張の先駆者として言及

## 6. Windows Terminal

- **結論**: MicrosoftがBuild 2019（2019年5月）で発表。ソースコードは2019年5月3日にGitHubで公開。プレビュー版v0.2は2019年7月10日。安定版v1.0は2020年5月19日リリース。MITライセンスのオープンソース。DirectWrite/DirectXベースのテキストレンダリング。タブ、分割ペイン、GPU描画、Unicode/絵文字完全対応
- **一次ソース**: devblogs.microsoft.com/commandline; Wikipedia, Windows Terminal; GitHub microsoft/terminal
- **URL**: <https://devblogs.microsoft.com/commandline/introducing-windows-terminal/>, <https://en.wikipedia.org/wiki/Windows_Terminal>
- **注意事項**: Microsoftが公式にモダンターミナルエミュレータを開発したことは歴史的に重要。cmd.exe/PowerShellのホスト環境として
- **記事での表現**: Windows Terminal（2019年発表、2020年v1.0）として記述

## 7. Warp

- **結論**: Zach Lloyd（元Google Principal Engineer、Google Docs担当）が2020年6月に創業。Rust製。2022年にmacOS版を公開。2023年4月にWarp AI（OpenAI LLM統合）を発表。2023年6月にWarp Drive（コマンド共有機能）を導入。IDEライクなテキスト編集、ブロック単位のコマンド出力が特徴。プロプライエタリ
- **一次ソース**: Wikipedia, Warp (terminal); Sequoia Capital spotlight; SE Radio 581
- **URL**: <https://en.wikipedia.org/wiki/Warp_(terminal)>, <https://sequoiacap.com/article/warp-spotlight/>
- **注意事項**: プロプライエタリであり、AI統合を前面に押し出した初のターミナルエミュレータ。Sequoia Capital等のVC支援
- **記事での表現**: Warp（2022年公開、Zach Lloyd、Rust）として記述

## 8. Ghostty

- **結論**: Mitchell Hashimoto（HashiCorp共同創設者、Vagrant/Terraform/Consul等の作者）が2021年から個人プロジェクトとして開発開始。Zig言語で実装。2024年12月26日にv1.0を公開リリース（MITライセンス）。macOSではSwiftUI + Metal、LinuxではGTK + OpenGLのプラットフォームネイティブUI。xterm互換性が極めて高く、kittyキーボードプロトコル、kittyグラフィックスプロトコル等のモダン仕様にも対応
- **一次ソース**: mitchellh.com; ghostty.org; GitHub ghostty-org/ghostty
- **URL**: <https://mitchellh.com/writing/ghostty-is-coming>, <https://ghostty.org/>
- **注意事項**: HashiCorp創業者の個人プロジェクト。非営利法人による運営を選択（VC資金を取らない方針）。Zig言語の大規模実用例としても注目
- **記事での表現**: Ghostty（2024年12月、Mitchell Hashimoto、Zig）として記述

## 9. Sixel グラフィックスプロトコル

- **結論**: DECのドットマトリクスプリンタ（LA50等）向けに開発されたビットマップ形式。6ピクセル高×1ピクセル幅のパターン（64パターン）をASCII文字にマッピング。VT240/VT241で画面表示に転用。VT330/VT340ではカラーSixelをサポート（16色同時表示、4096色パレット、800×480ピクセル）。ランレングス符号化による圧縮。7ビットシリアル通信で送信可能
- **一次ソース**: Wikipedia, Sixel; vt100.net VT3xx Programmer Reference Manual
- **URL**: <https://en.wikipedia.org/wiki/Sixel>, <https://vt100.net/docs/vt3xx-gp/chapter14.html>
- **注意事項**: 1980年代のDECプリンタ/端末由来の古い規格だが、2020年代にターミナルでの画像表示手段として再評価
- **記事での表現**: Sixel（DEC由来、6ピクセル高のビットマップ形式）として記述

## 10. kittyキーボードプロトコル

- **結論**: Kovid Goyalが策定した、レガシーターミナルキーボードプロトコルの問題を解決する仕様。修飾キーの正確な報告、キーのリリースイベント、曖昧さのないキーエンコーディングを実現。2025年1月時点で、iTerm2、foot、WezTerm、Ghostty等が実装し、事実上の標準になりつつある。Microsoft Terminal（Windows Terminal）は対応作業中
- **一次ソース**: sw.kovidgoyal.net/kitty/keyboard-protocol; GitHub microsoft/terminal issues
- **URL**: <https://sw.kovidgoyal.net/kitty/keyboard-protocol/>, <https://github.com/microsoft/terminal/issues/18383>
- **注意事項**: VT100時代のキーボードプロトコルの限界（修飾キーの曖昧さ、Ctrl+文字の衝突等）を解消する試み
- **記事での表現**: kittyキーボードプロトコルとして記述。デファクト標準化の過程に言及

## 11. ターミナルの入力遅延（レイテンシ）

- **結論**: Dan Luuのブログ記事（2017年頃）がターミナルエミュレータの入力遅延を計測・比較し話題になった。beuke.orgの測定ではTypometer（ソフトウェアベースの遅延測定ツール）を使用。kittyが最良の遅延を記録。Alacrittyは約6.9ms、Neovim in tmux in Alacrittyで約8.3ms。キーボード遅延やディスプレイ遅延は含まない純粋なソフトウェアスタック遅延
- **一次ソース**: danluu.com/term-latency; beuke.org/terminal-latency
- **URL**: <https://danluu.com/term-latency/>, <https://beuke.org/terminal-latency/>
- **注意事項**: 遅延の感覚は個人差が大きい。計測方法により結果が変わる。GPU描画が必ずしも低遅延を意味するわけではない
- **記事での表現**: Dan Luuの計測を引用しつつ、GPU描画の効果と限界を議論

## 12. iTerm2インライン画像プロトコル

- **結論**: iTerm2が策定した独自のOSC 1337シーケンスによる画像表示仕様。`\033]1337;File=[args]:base64_data\007`の形式。PNG、GIF（アニメーション対応、v2.9.20150512以降）、PDF、PICT等のmacOS対応フォーマットを表示可能。imgcatコマンドで利用。WezTerm等の他のターミナルエミュレータも互換実装を持つ
- **一次ソース**: iterm2.com/documentation-images.html
- **URL**: <https://iterm2.com/documentation-images.html>
- **注意事項**: macOS依存の設計だが、プロトコル自体は他のターミナルでも実装可能。kittyプロトコルとは競合関係
- **記事での表現**: iTerm2インライン画像プロトコル（OSC 1337）として記述
