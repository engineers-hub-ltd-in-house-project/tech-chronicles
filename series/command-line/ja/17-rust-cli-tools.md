# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第17回：Rust製CLIツールの波――ripgrep, fd, bat, eza

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 50年間使われてきたcoreutilsを「書き直す」動機と、その結果生まれたUX革命の本質
- ripgrep（2016年、Andrew Gallant）の高速化技術――Teddy SIMDアルゴリズム、並列ディレクトリ走査、.gitignore互換グロブエンジン
- fd、bat、exa/eza、delta、zoxide、starshipなどRust製CLIツール群の設計思想と、coreutilsとの互換性・断絶のトレードオフ
- Rust言語（2015年1.0安定版）がCLIツール開発に適していた構造的理由――ゼロコスト抽象化、シングルバイナリ配布、メモリ安全性
- 「速さ」だけではないモダンCLIツールの革新――デフォルト値の再設計、色とUnicode、開発者ワークフローへの統合
- coreutilsとの互換性を捨てることの意味と、それでもなお移行が進む理由

---

## 1. grepが遅いと感じた日

2018年のある日、私は大規模なRailsプロジェクトのコードベースを前にしていた。数千のRubyファイル、数万行のコード。特定のメソッド呼び出しを探す必要があった。いつものように`grep -r`を打つ。

```
grep -rn "current_user" --include="*.rb" app/
```

結果が返ってくるまで、数秒かかった。数秒。たかが数秒だ。だが、この「たかが数秒」が一日に何十回も繰り返されると、それは無視できない摩擦になる。

同僚が「ripgrepを試してみたら」と言った。半信半疑で`rg current_user app/`と打った。

結果は一瞬だった。文字通り、Enterキーを離す前に結果が表示されていた。しかも、`.gitignore`に記録されたファイルは自動的に除外され、`vendor/`や`node_modules/`のような巨大ディレクトリを検索対象から外すために`--exclude`を手動で指定する必要がなかった。出力はファイル名が色付きで表示され、マッチした行の該当部分がハイライトされている。

「なぜ今まで我慢していたのか」――これが率直な感想だった。

だが、この体験は単なる「速いgrep」の話ではない。考えてみてほしい。grepは1973年にKen Thompsonが書いたツールだ。第8回で語ったように、Lee McMahonがFederalist Papersの分析のために必要としたことがきっかけで生まれた。50年以上の歴史を持つツールを、なぜ今さら「書き直す」のか。grepが壊れているわけではない。50年間、確実に動き続けている。

ここには、CLIツールの進化に関する本質的な問いがある。「動いている」ことと「最適である」ことは別だ。50年前の設計が50年前の制約の下では最適だったとしても、2016年のハードウェアとソフトウェアの環境では、別の最適解がありうる。

あなたは、自分が毎日使っているCLIツールの設計が、いつの時代の制約を反映しているか、考えたことがあるだろうか。

---

## 2. Rust製CLIツール群の台頭――2015年からの時系列

### Rust 1.0：CLIツール革命の土壌

2015年5月15日、Rust言語の1.0安定版がリリースされた。Mozillaの研究プロジェクトとして2010年頃から開発が続いていたRustは、この安定版リリースによって本番利用可能な言語となった。1年後には1,400人以上のコントリビュータが参加し、パッケージレジストリcrates.ioには5,000以上のライブラリが登録されていた。

Rustの設計思想が、CLIツール開発に極めて適していたことは偶然ではない。

第一に、ゼロコスト抽象化。高レベルな抽象（イテレータ、パターンマッチ、ジェネリクス）を使っても、手書きのCコードと同等のパフォーマンスが得られる。CLIツールにとって、これは「読みやすいコードを書いても速さを犠牲にしない」ことを意味する。

第二に、シングルバイナリ配布。Rustコンパイラが生成するのは、依存ライブラリをすべて静的リンクした単一の実行ファイルだ。Pythonのようなランタイムのインストールも、Node.jsのような`node_modules`ディレクトリも不要。バイナリをダウンロードして`PATH`の通った場所に置くだけで使える。CLIツールの配布モデルとして、これ以上にシンプルなものはない。

第三に、メモリ安全性。Rustの所有権システムは、ガベージコレクションなしにメモリ安全を保証する。C/C++のパフォーマンスとPythonのような安全性を両立する。CLIツールは多様な入力を処理するため、バッファオーバーフローやuse-after-freeのような脆弱性は致命的だ。Rustはこれらをコンパイル時に排除する。

第四に、クロスプラットフォームサポート。Rustのコンパイラはlinux、macOS、Windows向けのバイナリを同一のコードベースから生成できる。第6回で語ったように、UNIX CLIとWindows CLIは異なる文化を持つが、Rust製ツールはその両方で動作する。

これらの特性が組み合わさった結果、2015年以降、Rustを使ったCLIツールの開発が爆発的に増加した。

### exa（2015年）：最初の波

Rust製CLIツールの先駆者の一つが、Benjamin Sago（GitHub: ogham）が2015年2月に公開したexaだ。lsの代替として設計されたexaは、色分け表示、Gitステータスの統合、ツリー表示、拡張属性の表示など、lsが持たない機能を備えていた。

exaの意義は、単にlsを「速くした」ことにはない。lsの出力を「再設計した」ことにある。lsは1971年のUNIX V1から存在するツールだ。その出力フォーマットは、テレタイプ端末の制約――限られた画面幅、モノクロ表示――を前提としている。exaは、現代のターミナルエミュレータが持つ256色やTrue Colorの描画能力を前提として、出力を再デザインした。

しかし、exaの物語には影がある。開発者のSagoが不在となり、プロジェクトのメンテナンスが停滞した。2023年9月、Sago本人がメンテナンス停止を公式に案内し、コミュニティフォークであるezaへの移行を推奨した。ezaの最初のリリースは2023年7月31日（v0.10.3）だった。オープンソースプロジェクトの持続可能性という、技術以外の課題がここに見える。

### ripgrep（2016年）：パフォーマンスの衝撃

2016年9月23日、Andrew Gallant（GitHub: BurntSushi）はブログ記事「ripgrep is faster than {grep, ag, git grep, ucg, pt, sift}」を公開した。ripgrep（コマンド名`rg`）は、grep、The Silver Searcher（ag）、git grep、その他の検索ツールを網羅的にベンチマークし、ほぼすべてのケースでripgrepが最速であることを実証した。

Gallantは、このブログ記事を書く以前から、Rustにおけるテキスト検索に2年半以上取り組んでいた。ripgrepは単なる「Rustで書き直したgrep」ではなく、テキスト検索の理論と実装を深く理解した上で設計されたツールだ。その高速化技術については次章で詳述する。

ripgrepの公開は、Rust製CLIツールの「パフォーマンスの衝撃」を業界に知らしめた転機となった。「Rustで書けば速くなる」という素朴な理解を超えて、「Rustの型システムとパフォーマンス特性を活かせば、従来のCプログラムをも凌駕する設計が可能になる」ことを実証した。

### fd（2017年）とbat（2018年）：sharkdpの貢献

David Peter（GitHub: sharkdp）は、Rust製CLIツールのエコシステムにおいて際立った貢献をした開発者だ。

2017年、Peterはfindの代替ツールfdを公開した。findはUNIXの古典的なファイル検索ツールだが、その構文は独特だ。`find . -name "*.rb" -type f`という記法に馴染むまでには時間がかかる。fdは`fd "*.rb"`と打つだけで同じ結果を返す。正規表現がデフォルト。`.gitignore`を尊重する。並列ディレクトリ走査で高速。出力は色付き。findの「できること」を制限する代わりに、「日常的に使うこと」を極限まで簡略化した設計だ。

2018年、Peterは今度はcatの代替ツールbatを公開した。batは「A cat(1) clone with wings」を名乗る。catの機能に加えて、シンタックスハイライト（Sublime Textの構文定義を利用するsyntectライブラリを使用）、行番号表示、Git差分の表示、自動ページング（出力が端末の高さを超える場合にlessに接続）を備える。

Peterはさらにhyperfineというベンチマーキングツールも開発した。名前はセシウム133の超微細準位（hyperfine levels）に由来する。時間の基本単位「秒」の定義に使われる物理現象から名前を取るあたりに、このツールが「精密な時間計測」に対して持つ姿勢が見える。hyperfineは、前述のripgrep対grepのようなベンチマーク比較を行う際のデファクトスタンダードとなっている。

### 2019年以降：波は広がる

Rust製CLIツールの波は、grep、find、cat、lsといったcoreutilsの代替にとどまらなかった。

2019年にリリースされたstarshipは、Bash、Zsh、Fish、PowerShellを含むほぼすべての主要シェルで動作するクロスシェルプロンプトだ。各シェルのプロンプト設定ファイル（`.bashrc`、`.zshrc`など）を個別にカスタマイズする代わりに、starshipの設定ファイル一つで統一的なプロンプトを定義できる。Git情報、言語バージョン、コマンド実行時間などのモジュールをTOML設定ファイルで構成する。

Ajeet D'Souzaが開発したzoxideは、cdコマンドの代替だ。ディレクトリの使用頻度と最終アクセス時刻を記録し、`z foo`と打つだけで、過去にアクセスした中から「foo」にマッチする最も関連性の高いディレクトリにジャンプする。autojumpやzの後継にあたるが、Rustの速度でデータベースを検索する。

Dan Davisonが開発したdeltaは、gitのdiff出力を大幅に改善する。シンタックスハイライト付きのdiff表示、サイドバイサイド表示、行レベルおよび単語レベルの差分ハイライト（Levenshtein編集距離アルゴリズムを使用）を提供する。`~/.gitconfig`にdeltaをページャとして設定するだけで、`git diff`や`git log`の出力が劇的に見やすくなる。

```
Rust製CLIツールの系譜:

  2015年
    └── exa (Benjamin Sago) ─→ 2023年 eza (コミュニティフォーク)
        lsの代替: 色、Git統合、ツリー表示

  2016年
    └── ripgrep (Andrew Gallant)
        grepの代替: SIMD高速化、.gitignore、色付き出力

  2017年
    └── fd (David Peter)
        findの代替: 簡潔な構文、並列走査、.gitignore

  2018年
    ├── bat (David Peter)
    │   catの代替: シンタックスハイライト、Git差分、ページング
    └── hyperfine (David Peter)
        ベンチマーキングツール: 統計分析、ウォームアップ

  2019年
    ├── starship
    │   クロスシェルプロンプト: TOML設定、モジュール構成
    └── delta (Dan Davison)
        git diff viewer: シンタックスハイライト、サイドバイサイド

  2020年頃
    └── zoxide (Ajeet D'Souza)
        cdの代替: 頻度ベースのスマートジャンプ
```

この系譜が示すのは、Rust製CLIツールの波が単発の現象ではなく、2015年のRust 1.0安定版以降、継続的に広がり続けている潮流だということだ。一つのツールの成功が次のツールの開発者を触発し、エコシステム全体が成長していった。

---

## 3. ripgrepの技術的深層――なぜこれほど速いのか

### パフォーマンスの源泉

ripgrepが従来のgrepより桁違いに速い理由は、単に「Rustで書いたから」ではない。Andrew Gallantは、テキスト検索の理論と実装に深い専門性を持つ開発者であり、ripgrepにはその知見が凝縮されている。

ripgrepの高速化は、大きく四つの技術的柱から成る。

#### 第一の柱：Teddy SIMDアルゴリズム

ripgrepの心臓部にあるのは、Rustのregexクレート（Gallant自身が開発）に組み込まれたリテラル最適化だ。多くの正規表現は、実際にはリテラル文字列の検索を含んでいる。`error`という文字列を検索する場合、正規表現エンジンをフル稼働させる必要はない。まず「`error`」というバイト列が存在する位置を高速に特定し、その位置でのみ正規表現エンジンを起動すればよい。

このリテラル検索に使われるのが、Teddy SIMDアルゴリズムだ。Geoffrey LangdaleがIntelのHyperscan正規表現ライブラリの一部として発明したこのアルゴリズムは、SSE/AVXのSIMD命令を使い、16バイト（または32バイト）を一度に処理する。入力テキストの各位置で、複数のリテラルパターンに対するパック比較を同時に実行し、マッチ候補の位置を検出する。

```
Teddy SIMDアルゴリズムの概念:

  従来のバイト単位の検索:
    "The quick brown fox" → 1バイトずつ比較
    T → h → e →   → q → u → i → c → k → ...
    各バイトで「fox」の先頭 'f' と比較
    → 19回の比較操作

  TeddyのSIMD検索:
    "The quick brown fox" → 16バイト単位で比較
    [The quick brown ] → 16バイトを一度にパック比較
    [fox             ] → 残りを比較
    → 2回のSIMD操作 + 候補位置の検証

  実際にはさらに洗練されており:
    - 複数のリテラルパターンを同時に検索可能
    - ハッシュバケットを使って候補を絞り込む
    - 検証ステップでフルマッチを確認
```

このSIMDベースの最適化が効く場面は多い。ripgrepはまず正規表現パターンからリテラル部分を抽出し、Teddyアルゴリズムで候補位置を高速に絞り込む。その候補位置でのみ、正規表現エンジンが完全なマッチングを行う。この二段階アプローチにより、複雑な正規表現の検索であっても、リテラル検索に近い速度が実現される。

Teddyアルゴリズムが利用できない場合（SIMDが利用不可、またはリテラル最適化が適用できないパターンの場合）は、Aho-Corasickアルゴリズムがフォールバックとして使用される。Aho-CorasickのDFA（決定性有限オートマトン）実装では、遷移テーブルがメモリ上で連続的に配置され、入力の各バイトに対して単一のテーブルルックアップだけで状態遷移が完了する。

#### 第二の柱：スマートなI/O戦略

ripgrepは、ファイルの読み取り戦略を状況に応じて自動的に切り替える。

単一のファイルを検索する場合、メモリマップドI/Oが選択される。ファイルの内容をメモリ空間に直接マッピングすることで、ファイルシステムとのデータコピーを最小化する。

大量のファイルを含むディレクトリを検索する場合は、インクリメンタルバッファリングが選択される。各ファイルを固定サイズのバッファに読み込みながら検索を進める。メモリマップドI/Oは個々のファイルに対しては効率的だが、数千のファイルを連続して検索する場合、mmap/munmapのシステムコール呼び出しのオーバーヘッドが無視できなくなるためだ。

この自動選択は、ユーザーが意識する必要のない最適化だ。`rg pattern`と打つだけで、ripgrepが最適な戦略を選択する。

#### 第三の柱：並列ディレクトリ走査

大規模なコードベースを検索する場合、ボトルネックとなるのは正規表現エンジンの速度だけではない。ファイルシステムの走査――ディレクトリを再帰的に辿り、ファイルの一覧を取得する処理――が全体の速度を支配する場合がある。

ripgrepはデフォルトでマルチスレッドのディレクトリ走査を行う。複数のスレッドが並行してディレクトリツリーを探索し、発見されたファイルを検索キューに投入する。検索スレッドはキューからファイルを取り出し、内容を検索する。ディレクトリの走査と内容の検索が並行して進むため、I/O待ちの時間が最小化される。

#### 第四の柱：.gitignore互換グロブエンジン

ripgrepの「速さ」には、「検索しないファイルの速さ」も含まれる。

grepで大規模プロジェクトを検索する場合、`node_modules/`、`vendor/`、`.git/`、ビルド成果物のディレクトリなど、検索対象から除外したいディレクトリを`--exclude`オプションで手動指定する必要がある。ripgrepは`.gitignore`ファイルを自動的に解析し、そこに記述されたパターンに一致するファイルやディレクトリを検索対象から除外する。

これは「小さな改善」に見えるかもしれない。だが、現代の典型的なWebプロジェクトでは、`node_modules/`ディレクトリだけで数万のファイルを含む。これらを最初から除外することで、検索対象のファイル数が一桁、場合によっては二桁減る。ripgrepの「速さ」の相当部分は、この「賢い除外」に由来する。

### UXの再発明

ripgrepが「速いgrep」にとどまらない理由は、UX（ユーザーエクスペリエンス）の全面的な再設計にある。

grepの出力は、デフォルトでは色なしの素朴なテキストだ。ファイル名、行番号、マッチした行が同じスタイルで表示される。ripgrepは、ファイル名を目立たせ、マッチした部分を色付きでハイライトし、ファイル間に空行を挿入する。この「些細な」UIの違いが、大量の検索結果を素早くスキャンする際の認知的負荷を大幅に下げる。

デフォルトの再帰検索も重要だ。grepで再帰検索をするには`grep -r`または`grep -R`オプションが必要だ。ripgrepは引数なしで再帰検索を行う。ファイルを検索するツールが再帰検索をデフォルトにするのは、現代の開発者のワークフローを考えれば自然な設計だ。

Unicode対応もripgrepの特徴だ。grepの実装によってはUnicode文字の扱いに問題がある。ripgrepはデフォルトでUnicodeをサポートし、かつそのパフォーマンスコストを最小限に抑えている。

これらの設計判断は、いずれも「grepの仕様に縛られない自由」から生まれている。grepはPOSIX標準に準拠する必要がある。50年分の既存のシェルスクリプトがgrepの振る舞いに依存している。ripgrepはそのしがらみを持たない。ゼロからUXを再設計できる立場にある。

---

## 4. 互換性と断絶のトレードオフ

### coreutilsとの関係

Rust製CLIツール群は、coreutilsを「置き換える」のか、それとも「補完する」のか。この問いには、明確な答えがない。

ripgrepはgrepと同じ仕事をするが、grepの振る舞いを完全に再現するわけではない。`grep -P`（PCRE）のようなオプション体系はripgrepには存在しない。逆にripgrepの`--type`オプション（`rg --type ruby pattern`でRubyファイルのみを検索）はgrepにはない。既存のシェルスクリプトでgrepをripgrepに単純置換しても、すべてが期待通りに動くとは限らない。

fdも同様だ。findの強力な`-exec`オプション、`-newer`による時刻比較、`-perm`による権限フィルタリングなど、findが持つ高度な機能の一部はfdには実装されていない。fdは「findの80%のユースケースを、20%の認知的負荷で実現する」という設計哲学に基づいている。残りの20%のユースケースでは、依然としてfindが必要だ。

batは、catとの互換性について意識的な設計をしている。パイプの出力先がターミナルでない場合（つまり`bat file | grep pattern`のようにパイプラインの中で使う場合）、batはシンタックスハイライトとページングを自動的に無効化し、catと同じプレーンテキスト出力に切り替わる。これにより、`cat`を`bat`にエイリアスしても、パイプラインが壊れない。

### デフォルト値の哲学

Rust製CLIツール群に共通するのは、「デフォルト値の再設計」という哲学だ。

grepのデフォルトは、1973年の制約を反映している。再帰検索なし（当時のディスクにはそもそもファイルが少なかった）。色なし（テレタイプは色を表示できなかった）。`.gitignore`の概念自体が存在しなかった。これらのデフォルトは、当時は合理的だった。

ripgrepのデフォルトは、2016年の環境を反映している。再帰検索あり（開発者は常にプロジェクトのルートから検索する）。色付き出力（現代のターミナルは256色以上をサポートする）。`.gitignore`を尊重（ほぼすべてのプロジェクトがGitで管理されている）。これらのデフォルトは、現代の開発者のワークフローに最適化されている。

```
デフォルト値の対比:

  grep                           ripgrep
  ─────────────────────────────────────────────────
  再帰なし (-r で有効化)         再帰がデフォルト
  色なし (--color=auto で有効化) 色付きがデフォルト
  .gitignore 無視               .gitignore 尊重
  バイナリファイルも検索         バイナリをスキップ
  隠しファイルも検索             隠しファイルをスキップ
  シンボリックリンクを辿る       シンボリックリンクを辿らない

  find                           fd
  ─────────────────────────────────────────────────
  パターン: -name "*.rb"         パターン: "\.rb$"
  大文字小文字区別あり           スマートケース（自動判定）
  シングルスレッド               マルチスレッドがデフォルト
  .gitignore 無視               .gitignore 尊重
  すべてのファイルを走査         隠しファイルをスキップ

  cat                            bat
  ─────────────────────────────────────────────────
  プレーンテキスト出力           シンタックスハイライト
  行番号なし (-n で有効化)       行番号がデフォルト
  ページングなし                 自動ページング
  Git統合なし                    Git差分のマーキング
  パイプ時も同じ出力             パイプ時はプレーンに戻る
```

この「デフォルト値の再設計」は、些細なことに見えて、実はCLIツールのUXにおける最大の革新だ。ユーザーが`--color=auto`を`.bashrc`に書く必要がない。`--exclude-dir=.git`を毎回指定する必要がない。「合理的なデフォルト」を提供することで、ツールの学習コストとタイプ量の両方を削減している。

### 既存エコシステムとの共存

重要なのは、Rust製CLIツール群がcoreutilsを「排除」しようとしているわけではないことだ。ripgrepの開発者Gallant自身、grepが必要な場面があることを認めている。POSIX互換のシェルスクリプトを書くなら、grepは必須だ。CI/CD環境で追加のツールをインストールできない場合、coreutilsに頼るしかない。

多くの開発者が採用しているのは「共存」のアプローチだ。対話的な使用（ターミナルで手動検索する場合）ではripgrep、fd、bat、ezaを使い、シェルスクリプトやCI/CDパイプラインではcoreutilsを使う。シェルのエイリアスで`alias grep='rg'`とする開発者もいるが、スクリプト内では明示的にgrepを呼ぶ。

この共存は、第10回で語ったUNIX哲学のテーマとも繋がる。「一つのことをうまくやれ」の原則は、同じ仕事をするツールが複数存在することを禁じていない。むしろ、同じ仕事に対して異なるトレードオフを持つツールが存在することは、エコシステムの健全性の証だ。

---

## 5. ハンズオン：Rust製CLIツールを体感する

### 環境構築

```bash
# Docker環境で実行（ubuntu:24.04ベース）
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：ripgrep対grepのベンチマーク

```bash
apt-get update && apt-get install -y grep ripgrep git curl time

echo "=== 演習1: ripgrep対grepの比較 ==="
echo ""

# テスト用のファイルツリーを生成
echo "--- テスト用ファイルの生成 ---"
mkdir -p /tmp/bench/src
for i in $(seq 1 500); do
    cat > "/tmp/bench/src/file_${i}.txt" << 'CONTENT'
This is a sample file for benchmarking.
Each file contains multiple lines of text.
Some lines contain the word ERROR that we want to find.
Other lines contain WARNING messages.
The quick brown fox jumps over the lazy dog.
Another ERROR occurred in the processing pipeline.
DEBUG: entering function process_request
INFO: request completed successfully
ERROR: connection timeout after 30 seconds
This line is just filler text for the benchmark.
CONTENT
done

# .gitignoreが存在しない状態でのシンプルなテキスト検索
echo ""
echo "--- grep: 再帰検索 ---"
time grep -rn "ERROR" /tmp/bench/src/ > /dev/null 2>&1
echo ""

echo "--- ripgrep: 再帰検索 ---"
time rg "ERROR" /tmp/bench/src/ > /dev/null 2>&1
echo ""

echo "--- 出力フォーマットの比較 ---"
echo ""
echo "[grepの出力（先頭5行）]"
grep -rn "ERROR" /tmp/bench/src/ | head -5
echo ""
echo "[ripgrepの出力（先頭5行）]"
rg "ERROR" /tmp/bench/src/ | head -5
echo ""

echo "→ ripgrepはファイル名をグループ化し、マッチ部分を色付きで表示する。"
echo "  grepは各行にファイルパスを繰り返す。"
echo "  大量の検索結果をスキャンする際の可読性が大きく異なる。"
```

### 演習2：fd対findの比較

```bash
apt-get install -y fd-find findutils

echo ""
echo "=== 演習2: fd対findの比較 ==="
echo ""

# テスト用のディレクトリ構造を生成
mkdir -p /tmp/bench/project/{src,tests,docs,build,vendor}
touch /tmp/bench/project/src/{main.rs,lib.rs,utils.rs}
touch /tmp/bench/project/tests/{test_main.rs,test_lib.rs}
touch /tmp/bench/project/docs/{README.md,CHANGELOG.md}
touch /tmp/bench/project/build/{output.o,debug.log}
touch /tmp/bench/project/vendor/{dep1.rs,dep2.rs}
mkdir -p /tmp/bench/project/.hidden
touch /tmp/bench/project/.hidden/secret.txt

echo "--- find: .rsファイルを検索 ---"
find /tmp/bench/project -name "*.rs" -type f
echo ""

echo "--- fdfind: .rsファイルを検索 ---"
fdfind -e rs . /tmp/bench/project
echo ""

echo "--- findの構文 vs fdの構文 ---"
echo ""
echo "  find:   find /path -name '*.rs' -type f"
echo "  fd:     fdfind -e rs . /path"
echo ""
echo "  find:   find /path -name '*.md' -newer /path/README.md"
echo "  fd:     fdfind -e md --changed-within 1d . /path"
echo ""
echo "  find:   find /path \\( -name '*.rs' -o -name '*.toml' \\) -type f"
echo "  fd:     fdfind '\\.(rs|toml)$' /path"
echo ""
echo "→ fdは日常的なファイル検索を簡潔な構文で実現する。"
echo "  findの高度な機能（-exec, -perm, -newer等）が必要な場面では"
echo "  引き続きfindを使えばよい。排他ではなく共存だ。"
```

### 演習3：bat対catの比較

```bash
apt-get install -y bat

echo ""
echo "=== 演習3: bat対catの比較 ==="
echo ""

# サンプルファイルの生成
cat > /tmp/bench/sample.py << 'PYTHON'
#!/usr/bin/env python3
"""Sample script for bat demonstration."""

import sys
from pathlib import Path

def process_file(path: Path) -> list[str]:
    """Read a file and return non-empty lines."""
    if not path.exists():
        raise FileNotFoundError(f"No such file: {path}")

    with open(path) as f:
        return [line.strip() for line in f if line.strip()]

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: script.py <file>", file=sys.stderr)
        sys.exit(1)

    result = process_file(Path(sys.argv[1]))
    for line in result:
        print(line)
PYTHON

echo "--- catの出力 ---"
cat /tmp/bench/sample.py
echo ""

echo "--- batcat の出力 ---"
batcat --style=plain --paging=never /tmp/bench/sample.py
echo ""

echo "--- batcat（行番号とGit差分付き）---"
batcat --paging=never /tmp/bench/sample.py
echo ""

echo "--- パイプ時の振る舞い ---"
echo "  batcat sample.py | grep 'def'  → プレーンテキストに戻る"
echo "  catのエイリアスとして使ってもパイプラインを壊さない"
echo ""
batcat --paging=never /tmp/bench/sample.py | grep "def"
echo ""
echo "→ batはターミナル直接出力時にシンタックスハイライトを適用し、"
echo "  パイプ出力時には自動的にプレーンテキストに戻る。"
echo "  UNIX哲学の「テキストストリーム」との互換性を保つ設計だ。"
```

### 演習4：デフォルト値の違いを体験する

```bash
echo ""
echo "=== 演習4: デフォルト値の違いを体験する ==="
echo ""

# .gitignoreを含むプロジェクト構造
mkdir -p /tmp/bench/gitproject/{src,node_modules/dep,build}
cd /tmp/bench/gitproject
git init -q

echo "ERROR in main source" > src/main.txt
echo "ERROR in dependency" > node_modules/dep/index.txt
echo "ERROR in build output" > build/output.txt
echo "ERROR in root" > root.txt

cat > .gitignore << 'GIT'
node_modules/
build/
GIT

git add -A && git commit -q -m "init"

echo "--- grepの結果（全ファイルを検索）---"
grep -rn "ERROR" .
echo ""

echo "--- ripgrepの結果（.gitignoreを尊重）---"
rg "ERROR" .
echo ""

echo "→ grepはnode_modules/とbuild/も検索する。"
echo "  ripgrepは.gitignoreを読み、これらを自動的にスキップする。"
echo "  現代のWebプロジェクトでは、node_modules/だけで"
echo "  数万ファイルを含むことがある。この差は圧倒的だ。"
echo ""
echo "  ripgrepで除外されたファイルも検索するには:"
echo "    rg --no-ignore ERROR ."
echo "  とすればよい。明示的なオプトインだ。"

cd /
```

### 演習5：モダンCLIツールの組み合わせ

```bash
echo ""
echo "=== 演習5: モダンCLIツールの組み合わせ ==="
echo ""

echo "--- ripgrep + fdの連携 ---"
echo ""
echo "  例: fdで見つけたファイルをripgrepで検索"
echo '  fdfind -e py . /tmp/bench | xargs rg "import"'
echo ""
fdfind -e py . /tmp/bench | xargs rg "import" 2>/dev/null || echo "  (マッチなし)"
echo ""

echo "--- 実践的なワークフロー例 ---"
echo ""
echo "  1. 特定の拡張子のファイルを検索:"
echo "     rg --type py 'pattern'"
echo "     rg -g '*.rs' 'pattern'"
echo ""
echo "  2. 置換のプレビュー:"
echo "     rg 'old_name' --replace 'new_name'"
echo ""
echo "  3. JSONからの検索:"
echo "     rg --json 'pattern' | jq '.'"
echo ""
echo "  4. fdの結果をバッチ処理:"
echo "     fdfind -e log --changed-within 1d . | xargs wc -l"
echo ""

echo "=== まとめ ==="
echo ""
echo "1. ripgrepはSIMD最適化、並列走査、.gitignore互換で高速検索を実現"
echo "2. fdは日常的なファイル検索を簡潔な構文で実現する"
echo "3. batはシンタックスハイライト付きのcat代替でパイプ互換性を保持"
echo "4. デフォルト値の再設計が、タイプ量と認知的負荷を大幅に削減"
echo "5. coreutilsを排除するのではなく、対話的使用での体験を改善する"
```

ハンズオンの自動セットアップスクリプトは `handson/command-line/17-rust-cli-tools/setup.sh` を参照してほしい。

---

## 6. まとめと次回予告

### この回の要点

第一に、Rust 1.0安定版（2015年5月）のリリースが、CLIツール革命の土壌を作った。ゼロコスト抽象化、シングルバイナリ配布、メモリ安全性、クロスプラットフォームサポートという特性が、CLIツール開発に理想的な基盤を提供した。

第二に、ripgrep（2016年、Andrew Gallant）は単なる「速いgrep」ではなく、テキスト検索の設計を根本から再考したツールだ。Teddy SIMDアルゴリズムによるリテラル高速検索、メモリマップドI/Oとインクリメンタルバッファリングの自動選択、並列ディレクトリ走査、.gitignore互換グロブエンジンという四つの技術的柱が、その性能を支えている。

第三に、exa/eza、fd、bat、delta、zoxide、starshipなどのRust製CLIツール群は、coreutilsの機能を「再実装」しただけではない。デフォルト値の再設計、色とUnicodeの全面的サポート、開発者ワークフローへの統合（.gitignore尊重、Git差分表示）という「UXの革新」を行った。

第四に、これらのツールはcoreutilsを「排除」するものではなく「補完」するものだ。対話的な使用ではRust製ツールの優れたUXを享受し、シェルスクリプトやCI/CD環境ではPOSIX互換のcoreutilsを使う。共存のアプローチが現実的であり、健全だ。

第五に、exa→ezaの経緯が示すように、オープンソースプロジェクトの持続可能性は技術的品質だけでは保証されない。コミュニティの力がプロジェクトを救うこともあれば、メンテナの離脱がプロジェクトを停滞させることもある。

### 冒頭の問いへの暫定回答

50年間使われてきたcoreutilsを「書き直す」意味はどこにあるのか。

答えは二つある。

一つ目は、50年間に蓄積した「技術的負債」の解消だ。grepが書かれた1973年には、マルチコアCPUもSIMD命令もGitも存在しなかった。当時の制約の下で最適だった設計が、2016年の環境では足かせになっていた。ripgrepは、2016年のハードウェアとソフトウェアの環境に最適化された設計を、ゼロから実装した。

二つ目は、「デフォルト値の更新」だ。grepのデフォルトが1973年の環境に最適化されているなら、ripgrepのデフォルトは2016年の環境に最適化されている。再帰検索、色付き出力、.gitignore尊重――これらは「機能」ではなく「デフォルト」の違いだ。ツールの性能が同じでも、デフォルト値が現代のワークフローに合致しているだけで、体感的な生産性は大幅に向上する。

だが、ここで第14回のGNU coreutilsの話を思い出してほしい。coreutilsが自由なソフトウェアとして50年間普及し続けた理由は、POSIX互換性というインターフェースの安定性にある。ripgrepは速いが、10年後にripgrepがメンテナンスされている保証はない。exa→ezaの事例が示すように。一方でgrepは、POSIX標準である限り、何らかの実装が必ず存在し続ける。

速さと安定性。革新と互換性。このトレードオフに「正解」はない。あるのは、文脈に応じた「選択」だけだ。

### 次回予告

次回、第18回「TUIの復権――Charm, Bubbletea, Ink, Textual」では、CLIとGUIの間に存在する「第三の領域」を探る。

lazygitを使ったとき、「これはターミナルの中のGUIだ」と思った。htop、k9s、そしてBubbleteaで作られたツール群。CUI（Character User Interface）は1990年代に衰退したはずだ。それがなぜ、2020年代に「TUI」として復権しているのか。Charm/Bubbletea（Go、Elm Architecture）、Ink（React for CLI）、Textual（Python）、Ratatui（Rust）――モダンなフレームワークが、テキストベースのUIに何をもたらしたのか。ターミナルの中で表現できることの限界が、今まさに書き換えられている。

---

## 参考文献

- Andrew Gallant, "ripgrep is faster than {grep, ag, git grep, ucg, pt, sift}", burntsushi.net, 2016, <https://burntsushi.net/ripgrep/>
- GitHub, BurntSushi/ripgrep, <https://github.com/BurntSushi/ripgrep>
- GitHub, sharkdp/fd, <https://github.com/sharkdp/fd>
- GitHub, sharkdp/bat, <https://github.com/sharkdp/bat>
- GitHub, sharkdp/hyperfine, <https://github.com/sharkdp/hyperfine>
- GitHub, ogham/exa, <https://github.com/ogham/exa>
- GitHub, eza-community/eza, <https://github.com/eza-community/eza>
- GitHub, dandavison/delta, <https://github.com/dandavison/delta>
- GitHub, ajeetdsouza/zoxide, <https://github.com/ajeetdsouza/zoxide>
- Starship: Cross-Shell Prompt, <https://starship.rs/>
- Rust Blog, "Announcing Rust 1.0", 2015, <https://blog.rust-lang.org/2015/05/15/Rust-1.0/>
- crates.io, ripgrep versions, <https://crates.io/crates/ripgrep/versions>
- Andrew Gallant, "Regex engine internals as a library", burntsushi.net, <https://burntsushi.net/regex-internals/>
- GitHub, BurntSushi/ripgrep, Discussion #1822, "About the SIMD acceleration feature of ripgrep", <https://github.com/BurntSushi/ripgrep/discussions/1822>
- Wikidata, exa (Q57838499), <https://www.wikidata.org/wiki/Q57838499>
