# ファクトチェック記録：第17回「zsh――最大主義のシェルとOh My Zsh文化」

## 1. zshの誕生とPaul Falstad

- **結論**: Paul Falstadが1990年にPrinceton大学の学生として最初のバージョンを作成した。名前の由来はYale大学教授Zhong Shaoのログイン名「zsh」。初期の設計目標はkshとtcshの長所を統合すること
- **一次ソース**: Wikipedia, "Z shell"
- **URL**: <https://en.wikipedia.org/wiki/Z_shell>
- **注意事項**: Zhong ShaoはPrinceton大学のティーチングアシスタントだった（後にYale大学教授）
- **記事での表現**: 「1990年、Princeton大学の学生Paul Falstadは、kshの強力なスクリプティング機能とtcshの対話的快適さを併せ持つシェルを目指してzshを開発した。名前の由来は、Princeton大学のティーチングアシスタントZhong Shaoのログイン名だった」

## 2. Peter Stephenson（長期メンテナ）

- **結論**: 1990年代からzshの開発に参加。FAQの執筆を開始し、その後シェルの開発を調整。"A User's Guide to the Z-Shell"の著者。物理学のPh.D.を持ち、Oxfordで学んだ後、2000年からCambridge Silicon Radioでソフトウェアエンジニアとなった
- **一次ソース**: zsh.sourceforge.io, "A User's Guide to the Z-Shell"
- **URL**: <https://zsh.sourceforge.io/Guide/zshguide.html>
- **注意事項**: "From Bash to Z Shell"（2004年, Apress）の共著者でもある（Oliver Kiddle, Peter Stephenson, Jerry Peek）
- **記事での表現**: 「Peter Stephensonは1990年代からzshの開発に参画し、FAQと包括的なユーザーガイドを執筆した。彼の30年以上にわたる貢献がzshの安定性と成熟を支えている」

## 3. Oh My Zsh（Robby Russell, 2009年）

- **結論**: 2009年8月にRobby Russellが公開。当初はPlanet Argon社のチーム向けに作成。2,400人以上のコントリビュータ、300以上のプラグイン、140以上のテーマ。MITライセンス。2013年12月時点で500人超のコントリビュータ達成
- **一次ソース**: GitHub, "ohmyzsh/ohmyzsh"; Open Source Stories, "Robby Russell and the happy little accidental success of Oh My Zsh"
- **URL**: <https://github.com/ohmyzsh/ohmyzsh>, <https://www.opensourcestories.org/stories/2023/robby-russell-ohmyzsh/>
- **注意事項**: GitHubリポジトリの説明文の数字は定期的に更新されている。2024年時点で2,300+コントリビュータ、300+プラグインという記述あり
- **記事での表現**: 「Robby Russellが2009年8月に公開したOh My Zshは、2,400人以上のコントリビュータと300以上のプラグインを擁するコミュニティへと成長した」

## 4. macOS Catalinaでのzshデフォルト化（2019年）

- **結論**: 2019年6月4日のWWDC 2019でAppleが発表。macOS Catalinaから新規ユーザーアカウントのデフォルトシェルがzshに変更。既存ユーザーの設定は維持。GPLv3ライセンス回避が主な理由
- **一次ソース**: The Register, "Dissed Bash boshed: Apple makes fancy zsh default in forthcoming macOS 'Catalina' 10.15"; Apple Slashdot
- **URL**: <https://www.theregister.com/2019/06/04/apple_zsh_macos_catalina_default/>
- **注意事項**: macOS上のbashは3.2（GPLv2最終版）のまま据え置かれていた。第15回で詳述済み
- **記事での表現**: 第15回で詳述済みのため簡潔に言及。「2019年のmacOS Catalinaでのデフォルト化はzshの認知度を劇的に高めた」

## 5. zshのcompletion system（compctl→compsys）

- **結論**: 初期のcompletionはcompctlコマンドベース（tcshのcompleteコマンドに触発）。zsh 3.1.6で新しいcompletion system（compsys）が導入。compinitを呼ぶだけでコンテキストに応じた補完が動作する。compsysはシェル関数のライブラリとして実装。zsh 4.0（2001年）で安定版に
- **一次ソース**: Peter Stephenson, "A User's Guide to the Z-Shell", Chapter 6
- **URL**: <https://zsh.sourceforge.io/Guide/zshguide06.html>
- **注意事項**: compctlは後方互換性のために残されているが、compsysへの移行が推奨
- **記事での表現**: 「zshの補完システムは二段階の進化を遂げた。初期のcompctlからzsh 3.1.6で導入されたcompsys――シェル関数のライブラリとして設計されたこの新システムは、コンテキスト感知型の補完を実現した」

## 6. zle（Zsh Line Editor）のウィジェット機構

- **結論**: zleはzshの行編集エンジン。ウィジェットはzleの基本単位で、zle -Nで新しいウィジェットを登録し、bindkeyでキーにバインドする。$BUFFER、$CURSOR、$LBUFFERなどの変数でコマンドライン操作が可能。組み込みウィジェットはドット付き（.widget-name）で参照可能
- **一次ソース**: zsh.sourceforge.io, "Zsh Line Editor"
- **URL**: <https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html>
- **注意事項**: zleウィジェットはシェル関数として実装されるため、任意のzshコードを実行可能
- **記事での表現**: 「zleのウィジェット機構は、コマンドライン編集の各操作をシェル関数として定義し再定義できるようにした。$BUFFERや$CURSORといった変数を通じて行編集の状態に直接アクセスできる」

## 7. プラグインマネージャの系譜

- **結論**: antigen（初期のプラグインマネージャ、低速）→ antibody（Go言語実装、高速化、後に非推奨）→ antidote（antibodyの後継、ネイティブzsh実装）。zinit（旧zplugin）はTurboモードで高速だが学習曲線が急。sheldonはRust製で高速。zplugも存在。性能面ではantibody、antidote、sheldon、zimfwが優秀
- **一次ソース**: GitHub, "rossmacarthur/zsh-plugin-manager-benchmark"; GitHub Gist, "Comparison of ZSH frameworks and plugin managers"
- **URL**: <https://github.com/rossmacarthur/zsh-plugin-manager-benchmark>, <https://gist.github.com/laggardkernel/4a4c4986ccdcaf47b91e8227f9868ded>
- **注意事項**: zinit（旧zplugin）のメンテナンス状況は流動的。antigenとantibodyは非推奨
- **記事での表現**: 「プラグインマネージャの変遷は、zshエコシステムの成熟過程を映し出している。antigenからantibody、そしてantidoteへ。zinit のTurboモードからsheldonのRust実装へ」

## 8. zshの高度なグロビング機能

- **結論**: 再帰グロブ（**/ パターン）、グロブ修飾子（glob qualifiers）はzsh固有。ファイルタイプ修飾子（/でディレクトリ、@でシンボリックリンク）、パーミッション修飾子（f修飾子）、時間・サイズ修飾子（m, a）。修飾子は括弧内に記述し、組み合わせ可能
- **一次ソース**: zsh.sourceforge.io, "Expansion"
- **URL**: <https://zsh.sourceforge.io/Doc/Release/Expansion.html>
- **注意事項**: **/ はbash 4.0以降でもglobstarオプションで使用可能だが、glob qualifiersはzsh固有
- **記事での表現**: 「zshのグロブ修飾子は、findコマンドの機能をシェルのグロビング構文に統合したものだ。ファイルタイプ、パーミッション、更新日時、サイズ――これらすべてをグロブパターンの末尾に付加する修飾子で表現できる」

## 9. zshのライセンス

- **結論**: MIT-likeライセンス。使用、コピー、修正、配布を許可。著作権表示の保持が条件。GPLv3ではないため、AppleがmacOSデフォルトとして採用できた
- **一次ソース**: GitHub, zsh-users/zsh, LICENCE file
- **URL**: <https://github.com/zsh-users/zsh/blob/master/LICENCE>
- **注意事項**: 正式には「MIT-like」と表現されることが多い。厳密にはMITライセンスと同一ではなく、zsh独自のパーミッシブライセンス
- **記事での表現**: 「zshはMIT-likeなパーミッシブライセンスの下で配布されている。このライセンスが、AppleがmacOS CatalinaでGPLv3のbashからzshへ移行する際の決め手となった」

## 10. zshの主要バージョンと機能追加

- **結論**: zsh 3.0（1996年8月）: sh/kshエミュレーション改善、再帰グロビング。zsh 3.1.6: 新completion system（compsys）導入。zsh 4.0（2001年）: compsys安定化、新モジュール。連想配列はzsh 4.0系列で安定サポート（bash 4.0の2009年より前）
- **一次ソース**: ZSH Release Notes (zsh.sourceforge.io/releases.html)
- **URL**: <https://zsh.sourceforge.io/releases.html>
- **注意事項**: 正確なバージョンでの連想配列導入時期の特定は困難だが、bash 4.0（2009年）よりかなり前
- **記事での表現**: 「zsh 3.0（1996年）でsh/kshエミュレーションと再帰グロビングが加わり、3.1系列で新しい補完システムが導入され、4.0（2001年）で安定版となった」

## 11. Kali Linux 2020.4でのzshデフォルト化

- **結論**: Kali Linux 2020.3で移行を開始、2020.4（2020年11月）でデフォルトシェルをbashからzshに正式変更。デスクトップイメージ（amd64/i386）とクラウドプラットフォームが対象。ARM、コンテナ、NetHunter、WSLはbashを維持
- **一次ソース**: Kali Linux Blog, "Kali Linux 2020.4 Release"
- **URL**: <https://www.kali.org/blog/kali-linux-2020-4-release/>
- **注意事項**: macOS（2019年）に続く主要プラットフォームでのzshデフォルト化事例
- **記事での表現**: 「2020年にはKali Linuxもデフォルトシェルをzshに変更し、zshの「デフォルトシェル」としての地位がmacOS以外にも広がった」

## 12. Oh My Zshの起動時間への影響

- **結論**: Oh My Zshはzshの起動時間に顕著な影響を与える。最適化前は1.35秒から3秒以上かかるケースも。Oh My Zsh自体のロードが起動時間の55%以上、completion systemが30%、構文ハイライトが14%程度。最適化により842msから108msへ改善可能
- **一次ソース**: Matthew J. Clemente, "Speeding Up My Shell (Oh My Zsh)"; Dave Dribin's Blog, "Improving Zsh Performance"
- **URL**: <https://blog.mattclemente.com/2020/06/26/oh-my-zsh-slow-to-load/>, <https://www.dribin.org/dave/blog/archives/2024/01/01/zsh-performance/>
- **注意事項**: 起動時間はプラグイン数、テーマ、環境に大きく依存
- **記事での表現**: 「Oh My Zshの起動コストは無視できない。デフォルト設定でも数百ミリ秒、プラグインを積み重ねると数秒に達することもある」
