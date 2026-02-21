# ファクトチェック記録：第1回「なぜこの連載を書くのか――bash ありきの世界への違和感」

## 1. Stack Overflow Developer Surveyにおけるbash/シェルの利用率

- **結論**: 2024年のStack Overflow Developer Surveyにおいて、Bash/Shellは「Programming, scripting, and markup languages」部門で33.9%の利用率を記録し、全体6位にランクインしている。JavaScript（62.3%）、HTML/CSS（52.3%）、Python（51%）、SQL（51%）、TypeScript（38.5%）に次ぐ位置。2025年調査でもBash/Shellは上位に位置する
- **一次ソース**: Stack Overflow, "2024 Stack Overflow Developer Survey", 2024
- **URL**: <https://survey.stackoverflow.co/2024/technology>
- **注意事項**: この数値は「使用言語」としての回答率であり、対話的シェルとしての利用率とは異なる。シェルスクリプトを書く行為と対話的にbashを使う行為は区別されていない
- **記事での表現**: 「2024年のStack Overflow Developer Surveyでは、Bash/Shellは利用言語として全体の約34%に達し、第6位に位置している」

## 2. macOS Catalinaでのデフォルトシェルのbashからzshへの変更（2019年）

- **結論**: Apple は macOS Catalina（2019年10月リリース）でデフォルトのログインシェルおよび対話的シェルをbashからzshに変更した。主な理由はbash 4.0以降がGPLv3ライセンスに移行したことで、AppleはGPLv3のTivoization禁止条項を受け入れられなかった。macOSに同梱されていたbashは2007年リリースのbash 3.2（GPLv2最終版）のまま更新されていなかった
- **一次ソース**: Apple Support, "Use zsh as the default shell on your Mac"; 各種技術メディア報道（2019年6月WWDC発表時）
- **URL**: <https://support.apple.com/guide/terminal/change-the-default-shell-trml113/mac>
- **注意事項**: zshのライセンスは厳密にはMIT-Modern-Variantであり、純粋なMITライセンスとは若干異なるが、BSDスタイルの寛容なライセンスである
- **記事での表現**: 「2019年秋、macOS Catalinaはデフォルトシェルをbashからzshに変更した。AppleがGPLv3のbash 4.x以降を採用せず、10年以上bash 3.2を同梱し続けた末の決断である」

## 3. "shell"という用語の起源（Louis Pouzin, Multics）

- **結論**: "shell"という用語は1964年末から1965年初頭にかけて、Louis Pouzinがコマンド言語インタプリタを表す概念としてMulticsの文脈で命名した。Pouzinはコマンドをプログラミング言語のように使う手法を説明する論文を書き、その中でこの用語を造語した。Pouzinが1965年にフランスに帰国した後、MITのGlenda SchroederがPouzinのフローチャートをもとにMultics用の最初のシェルを実装した
- **一次ソース**: Multicians.org, "The Origin of the Shell"
- **URL**: <https://www.multicians.org/shell.html>
- **注意事項**: ブループリントでは「1964年」としているが、正確には1964年末から1965年初頭にかけての命名。また、概念の提唱者はPouzinだが、実装者はGlenda Schroeder（MIT）である
- **記事での表現**: 「1964年末、フランス人エンジニアのLouis PouzinがMulticsのコマンドプロセッサを指して"shell"という言葉を造語した」

## 4. Thompson shellとUNIX V1（1971年）

- **結論**: Thompson shellはKen Thompsonによって開発され、1971年11月3日にリリースされたUNIX Version 1に搭載された最初のUNIXシェルである。Version 1からVersion 6（1975年）まで使用された。スクリプティング機能はなく、if/gotoは外部コマンドとして実装されていた。入出力リダイレクト（<, >）はV1から存在。パイプ（|）はV3（1973年）で追加
- **一次ソース**: Thompson shell, Wikipedia; Ken Thompson's original Unix shell documentation
- **URL**: <https://en.wikipedia.org/wiki/Thompson_shell>
- **注意事項**: パイプの追加時期（V3, 1973年）は正確。Thompson shellには変数も制御構造もなく、対話的なコマンド実行に特化していた
- **記事での表現**: 「1971年、Ken ThompsonがUNIX V1とともに世に送り出した最初のシェルには、変数も制御構造もなかった」

## 5. Bourne shell（Stephen Bourne, 1979年, UNIX V7）

- **結論**: Stephen BourneがBell Labsで1976年から開発を開始し、1979年にUNIX Version 7とともにリリースされた。Thompson shellの後継として、スクリプティング言語としての機能（if/for/while/case/here document/変数/関数）を備えた。言語設計にはAlgol 68の影響がある（fi, esac, doneなどの構文）
- **一次ソース**: Bourne, S.R. "The UNIX Shell" Bell System Technical Journal, Vol. 57, No. 6（1978年）; Wikipedia "Bourne shell"
- **URL**: <https://en.wikipedia.org/wiki/Bourne_shell>
- **注意事項**: 論文発表は1978年だがリリースはV7（1979年）。/bin/shとして標準シェルの座を確立した
- **記事での表現**: 「1979年、Stephen BourneのBourne shellがUNIX V7に搭載され、シェルはコマンドインタプリタからプログラミング言語へと変貌した」

## 6. bashの誕生（Brian Fox, FSF, 1989年）

- **結論**: Brian FoxがFree Software Foundation（FSF）のもとで開発し、1989年6月8日にbeta版（version 0.99）として最初のリリースを行った。GNUプロジェクトの一環としてBourne shell互換の自由なシェルを提供することが目的。Chet Rameyが1990年から長期メンテナとして引き継いだ
- **一次ソース**: Wikipedia "Bash (Unix shell)"; Wikipedia "Brian Fox (programmer)"
- **URL**: <https://en.wikipedia.org/wiki/Bash_(Unix_shell)>
- **注意事項**: 1989年6月8日はbetaリリース日。正式版1.0のリリース日とは区別する必要がある
- **記事での表現**: 「1989年6月8日、Brian FoxはGNUプロジェクトの一環としてBash（Bourne-Again Shell）のベータ版をリリースした」

## 7. Oh My Zsh（Robby Russell, 2009年）

- **結論**: Robby Russellが2009年8月28日に公開した。当初はRussellが同僚12人のためにzshの設定を整理したものだったが、急速にコミュニティが成長。2024年時点で2,400人以上のcontributor、300以上のplugin、150以上のテーマを擁するオープンソースプロジェクトとなった
- **一次ソース**: Robby Russell, "d'Oh My Zsh" (Medium/freeCodeCamp, 2017年); Oh My Zsh公式サイト
- **URL**: <https://ohmyz.sh/>
- **注意事項**: ブループリントの「2,300人以上のcontributor、350以上のplugin」は時点により変動する。2024年時点では2,400人以上のcontributor
- **記事での表現**: 「2009年、Robby RussellがOh My Zshを公開した。同僚12人のために作った設定フレームワークは、2024年時点で2,400人以上のコントリビューターを擁するエコシステムに成長した」

## 8. fish shell（Axel Liljencrantz, 2005年）

- **結論**: Axel Liljencrantzが開発し、2005年2月13日に最初のリリースを行った。"Finally, a command line shell for the 90s"をスローガンに、POSIX非互換を明示的に選択した対話重視のシェル。構文ハイライト、オートサジェスチョンをデフォルトで提供。2024年にfish 4.0でRust実装への移行を完了
- **一次ソース**: LWN.net, "Fish - The friendly interactive shell"（2005年）; Wikipedia "Fish (Unix shell)"
- **URL**: <https://lwn.net/Articles/136232/>
- **注意事項**: fish 4.0のRust移行完了は2024年。ブループリントの記述と整合する
- **記事での表現**: 「2005年、Axel Liljencrantzが"Finally, a command line shell for the 90s"をスローガンにfish shellを公開した」

## 9. Debian/Ubuntuの/bin/shをdashに変更（2006年）

- **結論**: Ubuntu 6.10（2006年10月）で/bin/shがbashからdash（Debian Almquist Shell）に変更された。Debian自体では、Debian 6.0 Squeeze（2011年2月）で完全にdashがデフォルトの/bin/shとなった。主な理由は起動速度の改善。dashはbashと比較してスクリプト解析・実行が3-5倍速く、起動プロセスで多数のシェルスクリプトが実行される環境で顕著な効果があった
- **一次ソース**: Ubuntu Wiki, "DashAsBinSh"; LWN.net, "A tale of two shells: bash or dash"
- **URL**: <https://wiki.ubuntu.com/DashAsBinSh>
- **注意事項**: ブループリントでは「Debian 2006年」としているが、正確にはUbuntuが2006年、Debianの完全移行は2011年。ただしDebian内での議論と移行プロジェクト自体は2006年頃から始まっている
- **記事での表現**: 「2006年、Ubuntuが/bin/shをbashからdashに変更した。起動速度の3-5倍の改善が決定の根拠であった」

## 10. kernel/shell/application三層構造

- **結論**: UNIXの伝統的な概念モデルにおいて、kernel（核）がハードウェアを抽象化し、shell（殻）がユーザーとカーネルの間のインタフェースを提供し、application（応用プログラム）がその上で動作するという三層構造がある。"shell"という名称自体が、カーネル（核）を包む「殻」というメタファーに由来する
- **一次ソース**: 一般的なOS概念モデル。Louis PouzinのMulticsでのshell命名がこの核/殻のメタファーに基づく
- **URL**: <https://www.multicians.org/shell.html>
- **注意事項**: 実際のUNIXシステムではシェルも一般的なユーザープログラムの一つであり、特権的な位置にあるわけではない。三層構造は概念モデルとしての説明
- **記事での表現**: 「shellという名前そのものが、kernel（核）を包む"殻"であることを示している。ユーザーはshellを通じてkernelと対話する」
