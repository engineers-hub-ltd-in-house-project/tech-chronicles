# ファクトチェック記録: 第9回「シェルの二つの文化――スクリプティングと対話の乖離」

## 1. Tom Christiansen "Csh Programming Considered Harmful"

- **結論**: Tom Christiansenが1995〜1996年頃に公開。cshのスクリプティング言語としての欠陥を体系的に指摘した文書。原文冒頭で「The csh is a tool utterly inadequate for programming, and its use for such purposes should be strictly banned」と断言
- **一次ソース**: Tom Christiansen, "Csh Programming Considered Harmful"
- **URL**: <https://www-uxsup.csx.cam.ac.uk/misc/csh.html>, <http://harmful.cat-v.org/software/csh>
- **注意事項**: 公開年は1995年と1996年の両方の記述があり、正確な初出日は確定困難。ブループリントでは1995年としており、記事では「1990年代半ば」と幅を持たせるのが安全
- **記事での表現**: 「1990年代半ば、Tom Christiansenが"Csh Programming Considered Harmful"を発表した。cshのスクリプティング言語としての致命的欠陥を体系的に指摘した文書である」

## 2. Debian /bin/sh → dash 変更の経緯

- **結論**: Ubuntu 6.10（Edgy Eft, 2006年10月）が先行して/bin/shをdashに変更。Debian本体では Lenny（2009年）でrelease goalとしたが完了せず、Squeeze（6.0, 2011年2月）で正式に/bin/shをdashに変更
- **一次ソース**: Ubuntu Wiki "DashAsBinSh", LWN.net "A tale of two shells: bash or dash"
- **URL**: <https://wiki.ubuntu.com/DashAsBinSh>, <https://lwn.net/Articles/343924/>
- **注意事項**: ブループリントでは「2006年」としているが、これはUbuntuの変更年。Debian本体は2011年。記事ではこの区別を明記する
- **記事での表現**: 「2006年、Ubuntu 6.10（Edgy Eft）が/bin/shをbashからdashに変更した。Debian本体がこれに続いたのはDebian 6.0 Squeeze（2011年）だった」

## 3. shebang（#!）の歴史

- **結論**: Dennis Ritchieが1980年1月にVersion 8 Unix向けにカーネルのインタプリタディレクティブ（#!）サポートを実装。UCBのカンファレンスで着想を得た。1980年1月10日付のメールで発表
- **一次ソース**: Dennis Ritchie, email announcing kernel interpreter directive support (1980-01-10)
- **URL**: <https://www.talisman.org/~erlkonig/documents/dennis-ritchie-and-hash-bang.shtml>, <https://www.in-ulm.de/~mascheck/various/shebang/>
- **注意事項**: Version 7（1979年）にはまだshebangサポートがなかった。Version 8（1985年正式リリースだがコード自体は1980年頃から開発）で導入
- **記事での表現**: 「1980年1月、Dennis Ritchieがカーネルに#!（shebang）サポートを実装した」

## 4. checkbashismsツール

- **結論**: Debianのdevscriptsパッケージに含まれるPerlスクリプト。原型はRichard Braakman（1998年）のコード、Josip Rodin（2002年）が拡張、Julian Gilbey（2003年）がPerlで書き直し、Yann Dirsonがシェルスクリプト版を書いた経緯あり。lintianシステムのチェックをベースにしている
- **一次ソース**: Debian manpage, checkbashisms(1)
- **URL**: <https://manpages.debian.org/unstable/devscripts/checkbashisms.1.en.html>, <https://salsa.debian.org/debian/devscripts/-/blob/main/scripts/checkbashisms.pl>
- **注意事項**: 「bashism」の定義は「POSIXが要求していないシェル機能」
- **記事での表現**: 「Debianのdevscriptsに含まれるcheckbashismsは、/bin/shスクリプトからbash依存構文を検出するツールだ」

## 5. bash依存構文（bashisms）の一覧

- **結論**: POSIX shにない主要なbash拡張: `[[ ]]`（条件式）、配列（`array=()`）、連想配列、プロセス置換（`<()`, `>()`）、`local`キーワード（POSIXでは未定義だがdashも対応）、`source`（`.`はPOSIX）、`$'...'`（ANSI-C quoting）、`{1..10}`（ブレース展開）、`function`キーワード、`<<<`（ヒアストリング）
- **一次ソース**: Greg's Wiki "Bashism"
- **URL**: <https://mywiki.wooledge.org/Bashism>
- **注意事項**: `local`はPOSIX未定義だが、dash、ash等多くのシェルが対応している。Debian Policyでは`local`を許容
- **記事での表現**: bashとPOSIX shの機能差異テーブルとして整理

## 6. 各ディストリビューションの /bin/sh 実装

- **結論**:
  - Debian/Ubuntu: dash（Debian Almquist shell）
  - FreeBSD: ash（Almquist shell派生）
  - Alpine Linux: BusyBox ash
  - macOS: bash 3.2（sh互換モードで動作）。zshはデフォルトの対話シェルだが、/bin/shはbash
  - Red Hat/CentOS/Fedora: bash
- **一次ソース**: 各ディストリビューションのドキュメント
- **URL**: <https://wiki.ubuntu.com/DashAsBinSh>, <https://en.wikipedia.org/wiki/Almquist_shell>, <https://scriptingosx.com/2020/06/about-bash-zsh-sh-and-dash-in-macos-catalina-and-beyond/>
- **注意事項**: macOSでは対話シェルのデフォルト=zsh、/bin/sh=bash 3.2という二重構造が存在
- **記事での表現**: 各ディストリビューションの/bin/sh実装比較表

## 7. POSIX shの対話的要件

- **結論**: POSIXはシェルの対話的機能としてジョブコントロール（bg, fg, jobs）を規定。コマンドライン編集はviモードのみ標準化（emacsモードは標準化を見送り）。kshのジョブコントロールがPOSIXのベースとなった
- **一次ソース**: IEEE Std 1003.1 (POSIX.1) Shell & Utilities, The Open Group
- **URL**: <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sh.html>
- **注意事項**: emacsモードが標準化されなかった理由: emacs陣営がフルエディタの標準化に反対、Stallman自身も見送りを希望
- **記事での表現**: 「POSIXはコマンドライン編集としてviモードのみを標準化した。emacsモードは――皮肉なことに――Stallman自身の意向もあり標準化を免れた」

## 8. fishのPOSIX非互換の設計判断

- **結論**: Axel Liljencrantz（2005年）がfishを設計する際、意図的にPOSIX互換性を捨てた。設計文書に「Whenever possible without breaking the above goals, fish should follow POSIX」と明記。POSIXよりユーザビリティ・一貫性・発見可能性を優先
- **一次ソース**: fish design documentation
- **URL**: <https://fishshell.com/docs/current/design.html>
- **注意事項**: fishはスクリプティング用途を主目的としていない。対話的シェルとしての品質を最優先
- **記事での表現**: 「fishは意図的にPOSIX互換性を捨てた。対話的シェルとしてのユーザビリティを最優先する設計判断である」

## 9. zshの emulate sh / POSIX互換モード

- **結論**: zshの`emulate sh`はPOSIX完全互換ではない。より厳密には`emulate -R sh`またはargv[0]をshとして起動する必要あり。`emulate sh`だけではnotifyオプションの状態が変わらない等の差異。SH_WORD_SPLIT, NO_NOMATCHなどのオプション設定も必要
- **一次ソース**: zsh FAQ, zsh documentation
- **URL**: <https://zsh.sourceforge.io/FAQ/zshfaq02.html>, <https://zsh.sourceforge.io/Doc/Release/Invocation.html>
- **注意事項**: zshはPOSIX準拠を目標としたことがない。互換モードはあくまで「近似」
- **記事での表現**: 「zshには`emulate sh`モードがあるが、完全なPOSIX互換は保証されない」

## 10. cshのスクリプティング上の具体的欠陥

- **結論**: Tom Christiansenが指摘した主要な欠陥: (1) stderrのリダイレクトが不可能（`2>`相当がない）、(2) `$var:q`等のクォーティングの不完全性、(3) パイプラインの終了ステータスが最後のコマンドのみ、(4) ファイルディスクリプタ操作の不足、(5) シグナルハンドリングの貧弱さ、(6) 関数が存在しない（aliasで代用するしかない）
- **一次ソース**: Tom Christiansen, "Csh Programming Considered Harmful"
- **URL**: <https://www-uxsup.csx.cam.ac.uk/misc/csh.html>
- **注意事項**: cshのこれらの欠陥がBourne系シェルとの決定的な差であり、「対話用シェルとスクリプト用シェルの分離」を不可避にした
- **記事での表現**: 具体的なコード例を交えてcshのスクリプティング上の制約を解説
