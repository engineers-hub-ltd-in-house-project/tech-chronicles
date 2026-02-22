# ファクトチェック記録：第13回「Bashの誕生と席巻――世界を飲み込んだGNUシェル」

## 1. Brian Foxによるbash開発開始時期

- **結論**: Brian Jhan Fox（1959年生まれ）は1988年1月10日にbashのコーディングを開始した。Richard Stallmanが以前の開発者の進捗に不満を持ち、Foxに開発を委ねた
- **一次ソース**: Brian Fox (programmer), Wikipedia; Chet Ramey "Geek of the Week" interview
- **URL**: <https://en.wikipedia.org/wiki/Brian_Fox_(programmer)>
- **注意事項**: FoxはFSFの従業員として開発に従事。1985年からFSFでStallmanと共に働いていた
- **記事での表現**: 「1988年1月10日、Brian Foxはbashのコーディングを開始した」

## 2. bashの最初のリリース日

- **結論**: bash 0.99（ベータ版）は1989年6月8日にリリースされた
- **一次ソース**: Brian Fox (programmer), Wikipedia; GNU Bash history
- **URL**: <https://en.wikipedia.org/wiki/Bash_(Unix_shell)>
- **注意事項**: ベータ版としてのリリース。バージョン番号は0.99
- **記事での表現**: 「1989年6月8日、bashはバージョン0.99のベータとして世に出た」

## 3. GNUプロジェクトにおけるシェルの位置づけ

- **結論**: StallmanとFSFは、自由なシェルがBSDとGNUのコードから構築される完全に自由なシステムにとって戦略的に不可欠と考え、数少ない自己資金プロジェクトの一つとしてFoxを雇用して開発させた
- **一次ソース**: Multiple Wikipedia sources on Brian Fox and GNU Project
- **URL**: <https://en.wikipedia.org/wiki/Brian_Fox_(programmer)>
- **注意事項**: GNUプロジェクトの発表は1983年9月27日（Richard Stallman）
- **記事での表現**: 「FSFが自ら資金を投じて開発させた数少ないプロジェクトの一つ」

## 4. bashの名前の由来

- **結論**: Bourne-Again SHellの頭字語。Stephen Bourne（Bourne shellの作者）の名前と「born again」（再生・復活）の語呂合わせ
- **一次ソース**: GNU Bash Reference Manual; The Architecture of Open Source Applications
- **URL**: <https://www.gnu.org/software/bash/manual/html_node/What-is-Bash_003f.html>, <https://aosabook.org/en/v1/bash.html>
- **注意事項**: 二重の言葉遊び（Bourne→born、shell→SH）
- **記事での表現**: 「Bourne-Again SHell――Stephen Bourneの名前と『born again（再生）』を掛けた、GNU文化らしい命名」

## 5. Chet Rameyのbashメンテナ就任

- **結論**: Chet Rameyは1989年からbashプロジェクトに参加しバグ修正を行い、1990年からプライマリメンテナとなった。Case Western Reserve Universityの所属。Brian Foxは1993年頃まで関与し、その後Rameyが単独メンテナに
- **一次ソース**: Chet Ramey "Geek of the Week" interview, Simple Talk; Wikipedia
- **URL**: <https://www.red-gate.com/simple-talk/opinion/geek-of-the-week/chet-ramey-geek-of-the-week/>
- **注意事項**: Rameyは2026年現在も35年以上メンテナンスを続けている
- **記事での表現**: 「1990年、Case Western Reserve UniversityのChet Rameyがプライマリメンテナとなった」

## 6. Brian FoxのGNU Readline開発

- **結論**: Brian Foxは1988年にGNU Readlineを作成。POSIXが要求するシェルの行編集機能を実装するため。バージョン1.05の後、Chet Rameyに引き継がれ、1998年以降Rameyが単独メンテナ
- **一次ソース**: GNU Readline, Wikipedia; Two-Bit History
- **URL**: <https://en.wikipedia.org/wiki/GNU_Readline>, <https://twobithistory.org/2019/08/22/readline.html>
- **注意事項**: FoxはFSFでReadlineとHistoryライブラリの両方を開発
- **記事での表現**: 「FoxはbashだけでなくGNU Readlineライブラリも作成した」

## 7. bash各メジャーバージョンの主要機能

- **結論**:
  - bash 2.0（1996年12月23日）: 配列変数、プログラマブル補完、shoptビルトイン
  - bash 3.0（2004年8月）: 正規表現マッチ演算子 `=~`
  - bash 3.2（2006年10月）: macOS Leopard以降に同梱されたバージョン（GPLv2最終版）
  - bash 4.0（2009年2月20日）: 連想配列、コプロセス（coproc）、`**`グロブ、大文字小文字変換展開
  - bash 5.0（2019年1月14日）: EPOCHSECONDS, EPOCHREALTIME, BASH_ARGV0
  - bash 5.2（2022年12月31日）: 最新安定版
- **一次ソース**: GNU Bash CHANGES file; TLDP; LWN.net; BashFAQ/061
- **URL**: <https://tiswww.case.edu/php/chet/bash/CHANGES>, <https://tldp.org/LDP/abs/html/bashver4.html>, <https://lwn.net/Articles/320546/>
- **注意事項**: bash 3.2はGPLv2ライセンスの最終バージョンであり、macOSに長期間同梱された
- **記事での表現**: 各バージョンの機能を時系列で整理

## 8. macOSがbashをデフォルトにした経緯

- **結論**: macOS 10.2 Jaguar（2002年）ではtcshがデフォルトだった。macOS 10.3 Panther（2003年）でbashがデフォルトシェルに変更された。開発者ビルド7B44で切り替えが確認された
- **一次ソース**: Slashdot "Apple Switches tcsh for bash" (2003); OSnews
- **URL**: <https://apple.slashdot.org/story/03/08/26/146205/apple-switches-tcsh-for-bash>, <https://www.osnews.com/story/4340/apple-switching-from-tcsh-to-bash/>
- **注意事項**: Linuxユーザーへのアピールが動機の一つとされている
- **記事での表現**: 「2003年、AppleはmacOS 10.3 Pantherでデフォルトシェルをtcshからbashに変更した」

## 9. Linuxディストリビューションでのbash採用

- **結論**: 初期のLinuxディストリビューション（Slackware 1993年、Debian 1993年、Red Hat 1994年）はbashをデフォルトシェルとして採用。Slackwareは1990年代半ばまでLinux市場の約80%を占めた。GNUツールチェーンとしてbashが標準的に含まれていた
- **一次ソース**: Linux Today; Wikipedia (Linux distribution)
- **URL**: <https://www.linuxtoday.com/blog/linux-distributions-history/>, <https://en.wikipedia.org/wiki/Linux_distribution>
- **注意事項**: GNUユーザーランドの一部としてbashが自然にLinuxに含まれた
- **記事での表現**: 「Linux = GNU/Linux であり、GNUのシェルであるbashがデフォルトになるのは必然だった」

## 10. bashの設計思想と機能蓄積

- **結論**: bashはBourne shell互換をベースに、cshの対話的機能（ヒストリ、エイリアス）とkshのスクリプティング機能（算術展開、配列等）を取り込んだ。POSIX sh準拠を目標としつつ、独自拡張を追加
- **一次ソース**: GNU Bash Reference Manual; The Architecture of Open Source Applications (Volume 1)
- **URL**: <https://www.gnu.org/software/bash/manual/bash.html>, <https://aosabook.org/en/v1/bash.html>
- **注意事項**: 「蓄積型進化」として、互換性を保ちながら機能を積み上げるアプローチ
- **記事での表現**: 「bashの設計思想は『吸収と蓄積』である。Bourne shell互換を保ちつつ、cshの対話的機能、kshのスクリプティング機能を取り込んだ」
