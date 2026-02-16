# ファクトチェック記録：第13回「BitKeeper事件——Linuxカーネルとプロプライエタリの衝突」

調査日: 2026-02-16

---

## 1. BitKeeper / BitMover社の設立と開発経緯

- **結論**: Larry McVoy（1962年マサチューセッツ州コンコード生まれ）がSun MicrosystemsでTeamWareに携わった後、BitMover社を設立。1999年3月にself-hostingを達成、1999年5月に早期アクセスベータ、2000年5月4日に最初の公開リリース。プロプライエタリな分散型バージョン管理システムとして提供
- **一次ソース**: Wikipedia, "Larry McVoy"; Wikipedia, "BitKeeper"
- **URL**: <https://en.wikipedia.org/wiki/Larry_McVoy> / <https://en.wikipedia.org/wiki/BitKeeper>
- **注意事項**: McVoyはSunでTeamWare（1992年発表の分散型SCM）に携わった経験を基にBitKeeperを設計。BitMover社の設立は2000年
- **記事での表現**: 「Larry McVoyはSun MicrosystemsでTeamWareに携わったエンジニアだ。2000年にBitMover社を設立し、BitKeeperを商用の分散型バージョン管理システムとして提供した」

## 2. BitKeeperのLinuxカーネル開発での採用（2002年2月）

- **結論**: 2002年2月、Linus TorvaldsがLinuxカーネル2.5系列の開発ワークフローにBitKeeperを導入。それまでの10年間（1991-2002年）、カーネル開発はメーリングリストでのパッチ送付とLinusによる手動適用で管理されていた。BitKeeperの採用により開発サイクルが大幅に加速し、数百人の開発者からの貢献をボトルネックなく処理可能に
- **一次ソース**: Wikipedia, "BitKeeper"; kernel.org, "BitKeeper for Kernel Developers" (OLS 2002)
- **URL**: <https://en.wikipedia.org/wiki/BitKeeper> / <https://www.kernel.org/doc/ols/2002/ols2002-pages-197-212.pdf>
- **注意事項**: 採用の決め手はBitKeeperの分散アーキテクチャ。サブシステムごとの独立した開発とLinusのツリーへのマージが容易になった
- **記事での表現**: 「2002年2月、Linus TorvaldsはLinuxカーネル2.5系列の開発にBitKeeperを導入した。それまでの10年間、カーネル開発はメーリングリストでのパッチ送付とLinusによる手動適用で管理されていた」

## 3. BitKeeperの無償ライセンス条件（非競合条項）

- **結論**: BitKeeperの無償コミュニティ版ライセンスには非競合条項が含まれていた。「BitKeeperと実質的に類似する機能を含む製品、またはBitMoverの合理的な判断においてBitKeeperと競合する製品を開発・製造・販売する場合、このライセンスは利用不可」。具体的にCVS、GNU arch、Subversion、ClearCaseなどの競合ツールの開発に参加する開発者はBitKeeperを無償で使用できなかった。使用期間中＋終了後1年間の制限
- **一次ソース**: LWN.net, "The BitKeeper non-compete clause"
- **URL**: <https://lwn.net/Articles/12120/>
- **注意事項**: この非競合条項がOSSコミュニティ内で最大の論争点となった
- **記事での表現**: 「BitKeeperの無償ライセンスには『非競合条項』が付されていた。CVS、Subversion、GNU archなどの競合ツールの開発に参加する開発者は、BitKeeperを無償で使用できない。使用期間中と終了後1年間、この制限は継続する」

## 4. Andrew Tridgell（Samba開発者）によるリバースエンジニアリング

- **結論**: Andrew Tridgell（1967年生まれ、オーストラリアのコンピュータプログラマ）はSambaファイルサーバの作者であり、rsyncアルゴリズムの共同発明者。2005年、OSDLの第2代フェローとしてBitKeeperのプロトコルを解析。Tridgellの手法は「BitKeeperサーバにtelnetで接続してhelpと入力した」ことから始まったと主張。Tridgell自身はBitKeeperを購入・使用していないため、ライセンスに同意しておらず違反していないと主張。Sambaで行ったのと同様の「クリーンルーム」プロトコル解析だと位置づけた
- **一次ソース**: LWN.net, "How Tridge reverse engineered BitKeeper"; Wikipedia, "Andrew Tridgell"
- **URL**: <https://lwn.net/Articles/132938/> / <https://en.wikipedia.org/wiki/Andrew_Tridgell>
- **注意事項**: TridgellはSambaでMicrosoftのSMBプロトコルをリバースエンジニアリングした実績がある。同じ手法をBitKeeperに適用
- **記事での表現**: 「Andrew TridgellはSambaでMicrosoftのSMBプロトコルをリバースエンジニアリングした実績を持つ。同じ手法でBitKeeperのプロトコルに臨んだ」

## 5. SourcePuller の開発

- **結論**: 2005年4月、TridgellはBitKeeperリポジトリと相互運用可能なフリーソフトウェア「SourcePuller」を開発。これはBitKeeperのメタデータ（コミット履歴等）をBitKeeperライセンスに同意せずに取得するためのツール。2005年4月22日のLinux.Conf.Auキーノートで公開
- **一次ソース**: The Register, "Tridgell drops Bitkeeper bombshell"
- **URL**: <https://www.theregister.com/2005/04/22/tridgell_releases_sourcepuller/>
- **注意事項**: メタデータの所有権が争点。カーネル開発者はコード投稿により生成されたメタデータはコミュニティのものと主張、McVoyはBitMoverのものと主張
- **記事での表現**: 「TridgellはBitKeeperリポジトリからメタデータを取得するフリーソフトウェア『SourcePuller』を開発した」

## 6. BitMoverによる無償ライセンス打ち切り（2005年4月）

- **結論**: 2005年4月、BitMover社はBitKeeperの無償コミュニティ版の提供を終了すると発表。理由としてOSDL雇用のAndrew Tridgellによるリバースエンジニアリングを挙げた。Linus Torvaldsは2005年4月6日にLKMLに「Kernel SCM saga...」の件名でメールを投稿し、BitKeeperとの決別を公表。BitMoverはOSDL雇用の開発者（Linus Torvalds、Andrew Mortonを含む）へのライセンス提供を拒否。無償版のサポート終了日は2005年7月1日
- **一次ソース**: LWN.net, "The kernel and BitKeeper part ways"; LKML, Linus Torvalds "Kernel SCM saga..."
- **URL**: <https://lwn.net/Articles/130746/> / <https://lkml.org/lkml/2005/4/6/121>
- **注意事項**: 2005年4月3日がBitKeeper使用の最後のLinuxカーネルリリース候補（2.6.12-rc2）。4月6日にLinusが決別を公表
- **記事での表現**: 「2005年4月6日、Linus TorvaldsはLKMLに『Kernel SCM saga...』の件名でメールを投稿した。BitKeeperとの決別の公式な宣言だった」

## 7. OSDL（Open Source Development Labs）とTridgellの関係

- **結論**: OSDL（Open Source Development Labs）はLinux開発を支援する業界コンソーシアム。Linus Torvaldsは2003年からOSDLの最初のフェロー。Andrew Tridgellは2005年にOSDLの第2代フェロー。Andrew MortonもOSDLに関連。BitMoverはOSDL雇用者全員へのライセンス提供を拒否した
- **一次ソース**: Wikipedia, "Open Source Development Labs"
- **URL**: <https://en.wikipedia.org/wiki/OSDL>
- **注意事項**: TridgellのBitKeeperプロトコル解析はOSDLフェローとしての仕事とは無関係のプロジェクトだったが、BitMoverはOSDLとの関係を理由にライセンスを拒否
- **記事での表現**: 「TridgellはOSDLの第2代フェローであり、Linus TorvaldsもOSDLフェローだった。BitMoverはOSDL雇用者全員へのライセンス提供を拒否した」

## 8. Richard Stallman / FSFの批判

- **結論**: GNU Projectの創設者Richard Stallmanは、Linuxカーネルというフラッグシップのフリーソフトウェアプロジェクトにプロプライエタリツールが使用されることへの懸念を表明。LKMLでの議論は激化し、Stallmanをカーネルメーリングリストから追放するかという議論にまで発展。2002年10月13日にStallmanが「Bitkeeper outrage, old and new」の件名でLKMLに投稿
- **一次ソース**: LKML, Richard Stallman, "Bitkeeper outrage, old and new"; OSnews, "RMS and BitKeeper — the Debate Turns Ugly"
- **URL**: <https://lkml.org/lkml/2002/10/13/201> / <https://www.osnews.com/story/1982/rms-and-bitkeeper-the-debate-turns-ugly/>
- **注意事項**: Stallmanの立場はソフトウェアの自由に関する原則論。Torvaldsの立場は実用主義
- **記事での表現**: 「Richard StallmanはLKMLに『Bitkeeper outrage, old and new』を投稿し、フラッグシップのフリーソフトウェアプロジェクトにプロプライエタリツールが使われることへの懸念を表明した」

## 9. Alan Coxら反対派の立場

- **結論**: Linux重鎮のAlan Coxを含む複数の主要開発者がBitKeeperの採用を拒否。理由はBitMoverのライセンス条件と、プロジェクトがプロプライエタリ開発者に制御を委ねることへの懸念。パッチはBitKeeperを使わずにプレーンなdiffとして投稿可能だったため、BitKeeperの使用はあくまでオプション
- **一次ソース**: Wikipedia, "BitKeeper"; Wikipedia, "Alan Cox (computer programmer)"
- **URL**: <https://en.wikipedia.org/wiki/BitKeeper> / <https://en.wikipedia.org/wiki/Alan_Cox_(computer_programmer)>
- **注意事項**: BitKeeper非使用者は従来通りのパッチワークフローを継続。二重のワークフローが併存
- **記事での表現**: 「Alan Coxを含む複数の主要カーネル開発者がBitKeeperの使用を拒否した。ライセンス条件への反発と、プロプライエタリツールへの依存に対する原則的な立場だった」

## 10. Linus Torvaldsの立場とBitKeeper採用の理由

- **結論**: Torvaldsの立場は実用主義。「自分はフリーソフトウェアの狂信者ではない。オープンソースツールが優れていればそれを使うし、商用ツールが優れていればそちらを使う」と公言。BitKeeper採用の決め手は分散アーキテクチャ——サブグループが独立に開発しLinusのツリーにマージできること。従来Linusに集中していたパッチ適用作業を信頼された副官に分散可能に
- **一次ソース**: InfoWorld, "Linus Torvalds' BitKeeper blunder"; Linux Journal, "A Git Origin Story"
- **URL**: <https://www.infoworld.com/article/2211030/linus-torvalds-bitkeeper-blunder.html> / <https://www.linuxjournal.com/content/git-origin-story>
- **注意事項**: Torvaldsは当時、利用可能なフリーソフトウェアのSCMでカーネル規模の開発を処理できるものがないと判断
- **記事での表現**: 「Torvaldsの立場は徹底した実用主義だった。フリーソフトウェアの原則よりも、開発効率を優先した」

## 11. BitKeeperのオープンソース化（2016年5月9日）

- **結論**: 2016年5月9日、BitKeeper バージョン7.2ceがApache License 2.0の下でオープンソースとしてリリース。Gitの誕生から11年後
- **一次ソース**: LWN.net, "BitKeeper goes open source"; Slashdot, "11 Years After Git, BitKeeper Is Open-Sourced"
- **URL**: <https://lwn.net/Articles/686986/> / <https://news.slashdot.org/story/16/05/10/1840255/11-years-after-git-bitkeeper-is-open-sourced>
- **注意事項**: オープンソース化の時点で、Gitはすでにデファクトスタンダードの地位を確立していた
- **記事での表現**: 「2016年5月9日、BitKeeperはApache License 2.0の下でオープンソース化された。Gitの誕生から11年が経過していた」

## 12. BitKeeperの技術的機能

- **結論**: BitKeeperの主要機能：(1) 分散リポジトリ、(2) ファイルのリネーム追跡、(3) 全履歴を使った高精度な自動マージ（diff3変種ではなく全履歴活用）、(4) チェックサムによるデータ完全性検証、(5) ネストされたリポジトリ（サブモジュール）、(6) アトミックなチェンジセット。特にリネーム追跡とマージの精度は当時の競合（CVS、Subversion）を大幅に凌駕
- **一次ソース**: BitKeeper公式サイト; DeepWiki, "bitkeeper-scm/bitkeeper"
- **URL**: <https://www.bitkeeper.org/> / <https://deepwiki.com/bitkeeper-scm/bitkeeper>
- **注意事項**: BitKeeperのマージ品質はLinusが評価した最大の技術的利点の一つ
- **記事での表現**: 「BitKeeperは分散リポジトリ、ファイルのリネーム追跡、全履歴を活用した高精度マージ、チェックサムによるデータ完全性検証を実現していた。当時のOSS系VCSのいずれもこの完成度に達していなかった」
