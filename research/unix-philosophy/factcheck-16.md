# ファクトチェック記録：第16回「Linuxカーネル開発モデル——"大聖堂"と"バザール"の実態」

## 1. Eric Raymond「The Cathedral and the Bazaar」の発表時期と出版経緯

- **結論**: 1997年5月27日、ドイツ・ヴュルツブルクのLinux Kongressで初めて発表された。1999年にO'Reilly Mediaから書籍として出版。Raymond自身のfetchmail開発経験とLinuxカーネル開発の観察に基づく
- **一次ソース**: Eric S. Raymond, "The Cathedral and the Bazaar", First Monday, 1997; Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/The_Cathedral_and_the_Bazaar>, <http://www.catb.org/~esr/writings/cathedral-bazaar/>
- **注意事項**: エッセイは発表後も改訂が続き、1998年2月9日のバージョン1.29で「free software」を「open source」に変更。書籍出版は1999年（Open Publication Licenseで公開された初の商業出版物の一つ）
- **記事での表現**: 1997年5月にLinux Kongressで発表、1999年にO'Reillyから書籍化

## 2. 「The Cathedral and the Bazaar」がNetscape/Mozillaに与えた影響

- **結論**: 1998年1月22日、NetscapeがNetscape Communicatorのソースコード公開を発表。Raymond のエッセイがこの決定に直接的に影響した。Netscape社内でFrank HeckerがRaymondのエッセイを「外部からの独立した検証」として引用し、ソースコード公開を主張した
- **一次ソース**: Frank Hecker, "Open Sources: Voices from the Open Source Revolution", O'Reilly, 1999; Wikipedia
- **URL**: <https://www.oreilly.com/openbook/opensources/book/netrev.html>, <https://en.wikipedia.org/wiki/The_Cathedral_and_the_Bazaar>
- **注意事項**: Mozillaプロジェクトの開始は1998年3月31日。Netscapeの決定はオープンソース運動の転換点として広く認識されている
- **記事での表現**: Netscapeのソースコード公開決定にRaymondのエッセイが直接的に影響した事実を記述

## 3. BitKeeper騒動とGitの誕生（2005年）

- **結論**: Linuxカーネル開発は2002年からBitKeeper（Larry McVoyのBitMover社の商用VCS）を使用。2005年にAndrew TridgellがBitKeeperプロトコルをリバースエンジニアリングしたことでライセンスが取り消された。Linus Torvaldsは2005年4月3日にGitの開発を開始した
- **一次ソース**: Graphite Blog, "BitKeeper, Linux, and licensing disputes"; Linux Journal, "A Git Origin Story"; Wikipedia
- **URL**: <https://graphite.com/blog/bitkeeper-linux-story-of-git-creation>, <https://en.wikipedia.org/wiki/BitKeeper>
- **注意事項**: BitKeeper以前の10年間（1991年〜2002年）はパッチベースのシステムで管理されていた。BitKeeper使用にはライセンス制約があり、開発者は競合するVCSプロジェクトに参加できなかった
- **記事での表現**: BitKeeperの無料ライセンス失効を契機にLinusが2005年4月にGitを開発開始

## 4. Linux Foundationの設立経緯

- **結論**: 前身のOSDL（Open Source Development Labs）は2000年8月14日設立。創設メンバーはIBM、HP、Intel、NEC、Computer Associates等。2007年1月22日にOSDLとFree Standards Groupが合併してThe Linux Foundationが設立された
- **一次ソース**: Wikipedia, "Open Source Development Labs"; Wikipedia, "Linux Foundation"
- **URL**: <https://en.wikipedia.org/wiki/Open_Source_Development_Labs>, <https://en.wikipedia.org/wiki/Linux_Foundation>
- **注意事項**: ブループリントには「Linux Foundation（2000年〜）」とあるが、正確にはOSDLが2000年設立、Linux Foundationとしての設立は2007年
- **記事での表現**: OSDL（2000年）からLinux Foundation（2007年）への変遷として正確に記述

## 5. Linuxカーネルのリリースサイクル

- **結論**: 約9〜10週間ごとに新しいメインラインカーネルがリリースされる。マージウィンドウ約2週間 + RCフェーズ6〜10週間。RCはrc6からrc9程度まで続く。Linusが週に1回程度RCをリリース
- **一次ソース**: Linux Kernel Documentation, "How the development process works"
- **URL**: <https://docs.kernel.org/process/2.Process.html>
- **注意事項**: この構造は2024年・2025年においても一貫している
- **記事での表現**: 約9〜10週間サイクル、マージウィンドウ2週間+RCフェーズの構成で記述

## 6. カーネル開発者の所属企業と統計

- **結論**: 2024年時点で約4,807名の著者。企業貢献が全コミットの84.3%。2025年時点で11,089名のアクティブコントリビュータ、1,780組織。6.15カーネルには2,068名が貢献し262名が初参加。2024年の主要貢献者: Krzysztof Kozlowski (Linaro), Jakub Kicinski (Meta), Kent Overstreet (Bcachefs), Arnd Bergmann (Linaro), Andy Shevchenko (Intel)
- **一次ソース**: Phoronix, LWN.net, Linux Foundation statistics
- **URL**: <https://www.phoronix.com/news/2024-Linux-Git-Stats>, <https://lwn.net/Articles/1022414/>
- **注意事項**: 2024年はコミット数が10年間で最低だったが、開発活動自体は活発
- **記事での表現**: 企業が8割超の貢献を占める事実を強調

## 7. カーネルのバージョン番号体系の変遷

- **結論**: 2.6系は2003年12月から2011年まで8年間続いた。3.0は2011年7月22日リリース（2.6.39の次）。技術的な差異ではなく、マイナー番号が大きくなりすぎたために変更。以降4.0、5.0、6.0も同様の理由で増分。Linusは5.0リリース時に「指と足の指で数えられる20を超えた」と冗談を言った
- **一次ソース**: Wikipedia, "Linux kernel version history"; Greg Kroah-Hartman blog
- **URL**: <https://en.wikipedia.org/wiki/Linux_kernel_version_history>, <http://www.kroah.com/log/blog/2025/12/09/linux-kernel-version-numbers/>
- **注意事項**: 3.0リリース時にはuname26 personalityが追加され、古いプログラムが3.xを2.6.40+xとして認識できるようにした
- **記事での表現**: バージョン番号の増分は技術的ではなく実用的判断であることを明記

## 8. 「安定APIなし」ポリシー

- **結論**: Greg Kroah-Hartmanが「stable-api-nonsense.rst」をカーネルドキュメントとして執筆。カーネル内部APIには安定性の保証がない。一方、ユーザ空間に対するsyscallインタフェースは非常に安定しており、後方互換性が少なくとも2年間保証される（多くは無期限）。ローダブルカーネルモジュールは安定ABIに依存できず、新カーネルごとに再コンパイルが必要
- **一次ソース**: Linux Kernel Documentation, "stable-api-nonsense.rst"
- **URL**: <https://docs.kernel.org/next/process/stable-api-nonsense.html>, <https://github.com/torvalds/linux/blob/master/Documentation/process/stable-api-nonsense.rst>
- **注意事項**: Linusは1999年に「バイナリモジュールを使う人間は、時折冷や汗をかいて目覚めるべきだ」と発言
- **記事での表現**: ユーザ空間ABI安定 vs カーネル内部API不安定の二重構造を解説

## 9. Linusのコミュニケーションスタイルと2018年のCode of Conduct

- **結論**: Linusは率直で辛辣なコードレビューで知られる。2018年9月、Linux 4.19-rc4のリリースに際し、自身の「非専門的で不当な」振る舞いを謝罪。休暇を取り、「人の感情を理解し適切に対応する方法を学ぶための支援を受ける」と宣言。同時にContributor Covenantに基づく新しいCode of Conductを導入した。Sarah SharpやMatthew Garrettなどの開発者がコミュニケーション上の問題で離脱したことが知られている
- **一次ソース**: LKML, Linus Torvalds, "Linux 4.19-rc4 released, an apology, and a maintainership note", 2018年9月16日; The Register
- **URL**: <https://lkml.org/lkml/2018/9/16/167>, <https://www.theregister.com/2018/09/17/linus_torvalds_linux_apology_break/>
- **注意事項**: Code of Conduct導入に対するコミュニティの反応は賛否両論だった
- **記事での表現**: 辛辣なスタイルとCode of Conduct導入の両面を公平に記述

## 10. Linuxカーネルのコード規模

- **結論**: 2024年末時点で39,819,522行。2025年1月のLinux 6.14 RC1で40,063,856行を超え、4,000万行の大台を突破。2015年の2,000万行から10年で倍増。成長率は2ヶ月で約40万行。2024年は369万行追加、149万行削除
- **一次ソース**: Stackscale blog; Tom's Hardware; Phoronix
- **URL**: <https://www.stackscale.com/blog/linux-kernel-surpasses-40-million-lines-code/>, <https://www.phoronix.com/news/2024-Linux-Git-Stats>
- **注意事項**: ハードウェアアーキテクチャサポートだけで450万行以上
- **記事での表現**: 4,000万行超という規模感を具体的に記述

## 11. LKMLとメンテナ階層構造

- **結論**: LKMLがカーネル開発の主要コミュニケーションチャネル。パッチは関連するメーリングリストに投稿され、レビューを受ける。サブシステムメンテナがパッチを受け入れ、サブシステムツリーに取り込む。メンテナ間の信頼関係に基づく階層的なマージ構造。「外部から見ればLinusがCEOだが、企業テンプレートは当てはまらない。Linuxは（めったに表明されない）相互の尊敬、信頼、便宜によって結びついた無政府状態だ」
- **一次ソース**: Linux Kernel Documentation, "Feature and driver maintainers"; "How the development process works"
- **URL**: <https://docs.kernel.org/process/2.Process.html>, <https://www.kernel.org/doc/html/latest/maintainer/feature-and-driver-maintainers.html>
- **注意事項**: MAINTAINERSファイルで各サブシステムのメンテナが定義されている。ステータスはSupported, Maintained, Odd Fixes, Orphan, Obsoleteに分類される
- **記事での表現**: 形式上は階層的だが実態は信頼に基づく自律的ネットワークであることを記述
