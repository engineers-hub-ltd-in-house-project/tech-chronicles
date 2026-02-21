# ファクトチェック記録：第9回「正規表現――CLIを支えるパターン言語」

## 1. Stephen Kleeneの正規表現理論

- **結論**: Stephen Cole Kleene（1909年1月5日 - 1994年1月25日）はアメリカの数学者・論理学者。1951年にRAND Corporationの研究メモ "Representation of Events in Nerve Nets and Finite Automata" を執筆。これが1956年にPrinceton University Pressの "Automata Studies"（C. Shannon & J. McCarthy 編）に収録された。この論文で正規表現の概念と、正規表現と有限オートマトンが同じ言語クラスを記述するという定理（Kleeneの定理）を証明した。
- **一次ソース**: Stephen Cole Kleene, "Representation of Events in Nerve Nets and Finite Automata", RAND Research Memorandum RM-704, 1951; reprinted in Automata Studies, Princeton University Press, 1956
- **URL**: <https://www.rand.org/pubs/research_memoranda/RM704.html>
- **注意事項**: RANDメモは1951年だが、正式出版は1956年。「regular expression」という用語自体は1956年版で初出。Kleeneの名前の発音は「クレイニー」（KLAY-nee）。Alonzo Churchの学生であり、再帰理論の創始者の一人。1990年に国家科学メダル受賞。
- **記事での表現**: 1951年のRAND研究メモ、1956年のAutomata Studiesでの正式出版、として記述する

## 2. Ken ThompsonのQED正規表現実装（1968年）

- **結論**: Ken ThompsonはMITのCTSS上のQEDエディタに正規表現機能を実装。1968年6月、CACM（Communications of the ACM）Vol.11, No.6, pp.419-422に "Programming Techniques: Regular expression search algorithm" を発表。非決定性有限オートマトン（NFA）を構築する手法（後にThompson's constructionと呼ばれる）を記述。正規表現をIBM 7094のマシンコードにコンパイルする方法を示した。
- **一次ソース**: Ken Thompson, "Regular expression search algorithm", Communications of the ACM, Vol.11, No.6, pp.419-422, June 1968
- **URL**: <https://dl.acm.org/doi/10.1145/363347.363387>
- **注意事項**: この論文は正規表現を数学的概念から実用的なソフトウェア技術に変換した転換点。ACM Digital Libraryによると734引用、14,500ダウンロード。
- **記事での表現**: 第8回でも言及済み。本稿ではThompson NFAの手法を中心に、理論から実装への転換として詳述する

## 3. Henry Spencerの正規表現ライブラリ

- **結論**: Henry Spencer（1955年生まれ）はカナダのプログラマ。3つの正規表現ライブラリを作成した：(1) 1986年1月19日にUsenet mod.sourcesに投稿された「旧ライブラリ」（book library）、(2) 1993年頃に4.4BSDに寄贈されたPOSIX.2準拠の「BSDライブラリ」、(3) 1999年にTcl 8.1に組み込まれた「Tclライブラリ」（Unicode対応）。彼のAPIはEighth Edition Research UnixのAPIに準拠していた。
- **一次ソース**: Henry Spencer regex library, garyhouston.github.io; Wikipedia "Henry Spencer"
- **URL**: <https://garyhouston.github.io/regex/>, <https://en.wikipedia.org/wiki/Henry_Spencer>
- **注意事項**: Perl 2（1988年6月）でHenry Spencerの正規表現パッケージが採用されたことが、Perlの正規表現機能の基盤となった。Spencerのライブラリは非プロプライエタリなregex(3)の代替として広く使われた。
- **記事での表現**: 1986年のUsenet投稿を起点とし、BSD・Perl・Tclへの影響を記述する

## 4. POSIX BRE/ERE標準

- **結論**: POSIX.2標準（IEEE Std 1003.2-1992）で正規表現がBRE（Basic Regular Expression）とERE（Extended Regular Expression）として標準化された。BREはed/grep系の構文、EREはegrep系の構文に対応。BREでは `(`, `)`, `{`, `}` にバックスラッシュエスケープが必要、EREでは不要。GNU grepではBREとEREは表記法の違いだけで機能的に同等。
- **一次ソース**: The Open Group, POSIX.1-2017 (IEEE Std 1003.1-2017), Chapter 9: Regular Expressions
- **URL**: <https://pubs.opengroup.org/onlinepubs/9699919799/xrat/V4_xbd_chap09.html>
- **注意事項**: BREは「最も古い正規表現フレーバー」に相当。EREは元のgrepが持っていなかったメタ文字を追加した「拡張」。1992年に国際的に承認。
- **記事での表現**: POSIXによる標準化がツール間の互換性を保証した重要な出来事として記述

## 5. PCRE（Perl Compatible Regular Expressions）

- **結論**: Philip Hazelが1997年夏に開発を開始。当初はExim MTAのために開発された。PCREはPerlの正規表現機能をCライブラリとして実装し、POSIX BRE/EREより強力な構文を提供。Apache、Nginx、PHP、R等の主要OSSで採用。2015年にPCRE2（改訂API）がフォーク。PCRE 7.xとPerl 5.9.xの時期には両プロジェクト間で機能の相互移植が行われた。
- **一次ソース**: Philip Hazel, "A Brief History of PCRE"; PCRE公式サイト
- **URL**: <https://www.pcre.org/>, <https://help.uis.cam.ac.uk/system/files/documents/techlink-hazel-pcre-brief-history.pdf>
- **注意事項**: PCREはバックトラッキングNFAベースであり、ReDoS脆弱性の対象となりうる。
- **記事での表現**: Perlの正規表現機能がPCREを通じてエコシステム全体に波及した経緯を記述

## 6. Perl 1.0と正規表現

- **結論**: Larry WallがPerl 1.0を1987年12月18日にリリース。Unisys勤務中に開発を開始。awkでは処理しきれないテキスト処理タスクのために設計された。Perl 1で `/\(...\|...\)/` を `/(…|…)/` に変更（BREからERE的構文への移行）。Perl 2（1988年6月）でHenry Spencerの正規表現パッケージを採用し、正規表現エンジンが改善された。
- **一次ソース**: perldoc perlhist; Wikipedia "Perl"
- **URL**: <https://perldoc.perl.org/5.6.2/perlhist>, <https://en.wikipedia.org/wiki/Perl>
- **注意事項**: Perlは正規表現を言語の中核機能に据えた最初の主要言語。後方参照、先読み、後読み等の拡張を追加し、「Perl正規表現」が事実上の業界標準となった。
- **記事での表現**: Perlが正規表現を「メインストリーム」に引き上げた役割を記述

## 7. ReDoS（Regular Expression Denial of Service）

- **結論**: バックトラッキング型正規表現エンジンの脆弱性を利用したDoS攻撃。2003年のUsenix Security（Crosby & Wallach）で初めて形式的に発表。2009年に再検討論文あり。2019年7月2日のCloudflare障害は、WAFルールに含まれる不適切な正規表現が過剰なバックトラッキングを引き起こし、CPU使用率100%で27分間のサービスダウンをもたらした。トラフィックは最悪時82%減少。
- **一次ソース**: Cloudflare Blog, "Details of the Cloudflare outage on July 2, 2019"; OWASP ReDoS
- **URL**: <https://blog.cloudflare.com/details-of-the-cloudflare-outage-on-july-2-2019/>, <https://owasp.org/www-community/attacks/Regular_expression_Denial_of_Service_-_ReDoS>
- **注意事項**: Cloudflareの正規表現エンジンには計算量の保証がなかった。テストスイートにCPU消費量の検出がなかった。段階的デプロイではなく一括グローバルデプロイだった。
- **記事での表現**: ReDoSの具体的事例としてCloudflare障害を記述し、バックトラッキングの危険性を示す

## 8. RE2（Russ Cox / Google）

- **結論**: 2010年3月にGoogleがオープンソース化。Russ CoxがGoogle Code Searchのために開発。安全性を第一の目標とし、入力サイズに対して線形時間、固定スタック容量で動作することを保証。バックトラッキングを排除したオートマトン理論ベースの実装。Go言語の標準regexpパッケージはRE2と同じパターン・実装を共有。PCREの大部分の機能をカバーするが、後方参照等は除外。
- **一次ソース**: Google Open Source Blog, "RE2: a principled approach to regular expression matching", March 2010; GitHub google/re2
- **URL**: <https://opensource.googleblog.com/2010/03/re2-principled-approach-to-regular.html>, <https://github.com/google/re2>
- **注意事項**: RE2はPCREに近いC++ APIを提供するが、指数時間になりうる演算子を排除している。
- **記事での表現**: Thompson NFAの思想を現代に復活させた実装として記述

## 9. Russ Coxのブログ記事シリーズ

- **結論**: 2007年1月に "Regular Expression Matching Can Be Simple And Fast (but is slow in Java, Perl, PHP, Python, Ruby, ...)" を公開。Thompson NFAの手法と、現代の多くのバックトラッキングエンジンの性能問題を比較。29文字の入力文字列に対し、Thompson NFA実装はPerlの100万倍高速。この記事はRE2開発の理論的基盤となった。
- **一次ソース**: Russ Cox, "Regular Expression Matching Can Be Simple And Fast", January 2007
- **URL**: <https://swtch.com/~rsc/regexp/regexp1.html>
- **注意事項**: Coxのブログシリーズは全4回（regexp1-regexp4）。正規表現エンジン実装に関する最も重要なリソースの一つ。
- **記事での表現**: Thompson NFAの再評価として、現代的文脈で紹介する

## 10. ripgrepの正規表現エンジン

- **結論**: Andrew Gallant（BurntSushi）が開発。RustのregexクレートはRuss CoxのRE2に強くインスパイアされた実装。有限オートマトンベースで線形時間保証。最適化戦略として、まずリテラル文字列を検索し、マッチの検証時にのみ正規表現エンジンを使用。Aho-Corasickアルゴリズムと、Intel HyperscanのTeddyアルゴリズム（SIMD）を活用。grep-matcherクレートがプラグイン可能な正規表現エンジンの抽象レイヤーを提供。
- **一次ソース**: Andrew Gallant, "ripgrep is faster than {grep, ag, git grep, ucg, pt, sift}", burntsushi.net; "Regex engine internals as a library"
- **URL**: <https://burntsushi.net/ripgrep/>, <https://burntsushi.net/regex-internals/>
- **注意事項**: Rust regexライブラリとGoのregexライブラリは共にRE2を共通の祖先とする。
- **記事での表現**: Thompson NFA → RE2 → Rust regex/ripgrep という系譜として記述
