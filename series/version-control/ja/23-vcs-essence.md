# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第23回：バージョン管理の本質に立ち返る——変更・協調・歴史

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- バージョン管理の「三つの本質」——変更の記録（What changed?）、協調の仕組み（Who changed it, and how do we integrate?）、歴史の保存（Why did it change?）
- SCCS（1972年）からGit（2005年）まで、50年以上の歴史を「三つの本質」で再評価する視座
- IEEE 828が定義したソフトウェア構成管理の4活動——識別・制御・状態記録・監査——とバージョン管理の関係
- Fred Brooksの「本質的複雑さと偶有的複雑さ」の区別がバージョン管理に示唆するもの
- Conway's Lawが示す組織構造とバージョン管理設計の相互作用
- 自分の開発ワークフローを「三つの本質」で再評価するための具体的な方法

---

## 1. 24年間の問いに、答えを出す

先日、私はあるカンファレンスで講演を依頼された。テーマは「バージョン管理の選び方」だった。

準備のために過去の資料を整理していると、2003年頃に書いたメモが出てきた。CVSからSubversionに移行する際に、チーム内の勉強会用に作った一枚のスライドだ。そこにはこう書かれていた。

> バージョン管理の目的
>
> 1. いつ、何が変わったかを記録する
> 2. 複数人で同時に作業できるようにする
> 3. 過去の状態に戻れるようにする

20年以上前の自分が書いた三行だ。CVSからSubversionに移行する理由を説明するために、まず「そもそもバージョン管理とは何か」を整理したのだろう。当時の私は、この三行がバージョン管理の「本質」を捉えているとは思っていなかった。単なる整理のための箇条書きだった。

だが、2026年の今、改めてこの三行を読み返すと、奇妙なことに気づく。

この連載で22回にわたって語ってきた内容——SCCSのインターリーブドデルタ、RCSのリバースデルタ、CVSのCopy-Modify-Mergeモデル、Subversionのアトミックコミット、Gitのコンテンツアドレッサブルストレージ、Jujutsuのオペレーションログ、Pijulのパッチ理論——これらすべてが、結局のところこの三行のどれかを「より良く実現する」ための試みだった。

ツールは変わった。アルゴリズムは進化した。設計思想は革新された。だが、バージョン管理が解こうとしている問題の本質は、50年間変わっていない。

これは停滞だろうか。私はそうは思わない。問題の本質が変わらないということは、その問題が人間のソフトウェア開発という営みに深く根ざしていることを意味する。ツールが変わっても本質が変わらないなら、本質を理解することの価値は、特定のツールの使い方を覚えることの価値を遥かに凌ぐ。

結局、バージョン管理の本質とは何なのか。この連載の23回目にして、ようやくこの問いに正面から向き合う。

あなたは、バージョン管理に何を求めているだろうか。git addとgit commitの手順ではなく、その背後にある「なぜバージョン管理が必要なのか」という問いに、自分の言葉で答えられるだろうか。

---

## 2. 50年の歴史を俯瞰する——三つの本質の系譜

### 構成管理という上位概念

バージョン管理の歴史を俯瞰する前に、一つ上の抽象度で考える必要がある。バージョン管理（Version Control）は、ソフトウェア構成管理（Software Configuration Management, SCM）の一部分だ。

SCMの概念は、1950年代のハードウェア構成管理に遡る。航空機や兵器システムの部品管理——どの部品がどのバージョンで、どの組み合わせで使われているか——を追跡するための仕組みだった。ソフトウェアが複雑化するにつれて、同じ問題がコードにも適用されるようになった。

1983年、IEEEはSCMの標準としてIEEE 828を制定した。この標準は、ソフトウェア構成管理の4つの活動を定義している。

**構成識別（Configuration Identification）。** 管理対象となる構成項目を特定し、一意の識別子を付与すること。バージョン管理の文脈では、「どのファイルのどのバージョンか」を識別する仕組みだ。SCCSのデルタ番号、Subversionのリビジョン番号、GitのSHA-1ハッシュ——いずれも構成識別の実装だ。

**構成制御（Configuration Control）。** 変更要求を評価し、承認または却下し、変更を実装するプロセス。CVSのCopy-Modify-Mergeモデル、GitのPull Requestワークフロー、JujutsuのSmartlogはすべて、変更を制御するための仕組みだ。

**構成状態記録（Configuration Status Accounting）。** 各構成項目の現在の状態と変更履歴を記録・報告すること。git logはまさにこの活動だ。だが、構成状態記録が求めるのは単なるログではない。「なぜその変更が行われたか」までを含む。

**構成監査（Configuration Audit）。** 構成項目が要求仕様に適合しているかを検証すること。CI/CDパイプラインが自動テストを実行し、マージ前にビルドが通ることを確認する——これは構成監査の現代的な実装だ。

IEEE 828が定義したこの4活動は、バージョン管理ツールが担う機能の「全体像」を示している。現代のバージョン管理ツールは、このうち識別・制御・状態記録の3活動を中心的に担い、監査はCI/CDツールに委譲している。だが、本質的にはこの4活動がソフトウェアの変更管理に必要な全体を構成する。

### 変更の記録——What changed?

バージョン管理の最も原始的な動機は、「何が変わったか」を知りたいという欲求だ。

1972年、Bell LabsのMarc J. Rochkindは、OS/360の開発現場でこの問題に直面していた。ソフトウェアのリリース後、顧客ごとにカスタマイズされたバージョンが派生し、どのバージョンにどの修正が含まれているかを追跡することが困難になっていた。Rochkindが開発したSCCSは、この問題に対する最初の体系的な回答だった。SCCSはファイルの変更をデルタ（差分）として記録し、任意のバージョンを再構成できる仕組みを提供した。

1976年、Bell LabsのJames W. HuntとM. Douglas McIlroyは、二つのファイルの差分を計算するdiffアルゴリズムを開発した。最長共通部分列（LCS）の計算に基づくこのアルゴリズムは、「何が変わったか」を機械的に特定する基盤技術となった。diffが出力する差分情報をpatchコマンドで適用する——この組み合わせは、バージョン管理の最も原始的な形態だ。

だが、「何が変わったか」をどう記録するかは、一つの答えに収束しなかった。

SCCSはインターリーブドデルタ方式を採用した。最新バージョンを基準とし、過去のバージョンを差分として保存するのではなく、すべてのバージョンの行を一つのファイルにインターリーブ（交互に挿入）する。どの行がどのバージョンに属するかをメタデータで管理する。この方式では、任意のバージョンの復元が高速だが、ファイルサイズは変更が増えるほど膨張する。

RCSはリバースデルタ方式を選んだ。最新バージョンをフルテキストで保持し、過去のバージョンへは逆方向の差分（リバースデルタ）を適用して復元する。最も頻繁にアクセスされる最新バージョンの取得が高速である一方、古いバージョンの復元にはデルタの連鎖を辿る必要がある。

Gitはスナップショット方式を採った。各コミットは、リポジトリ全体のスナップショット——すべてのファイルの内容をSHA-1ハッシュで参照するtreeオブジェクト——を記録する。差分は保存時には計算されず、必要時に動的に計算される。packファイルによる圧縮で、実質的にはデルタ圧縮が行われるが、これは論理的にはスナップショットモデルの上での最適化だ。

三者の設計判断は異なるが、解いている問題は同じだ。「What changed?」——ファイルの内容がいつ、どう変わったかを記録し、再現可能にすること。この問題は、1972年のSCCSから2026年のJujutsuに至るまで、すべてのバージョン管理ツールが最初に解かなければならない問題だ。

### 協調の仕組み——Who changed it, and how do we integrate?

バージョン管理の第二の本質は、協調だ。一人で一つのファイルを編集しているなら、cp file.bak で十分だ。だが、複数の人間が同じコードベースを同時に変更する場合、「誰が何を変えたか」を追跡し、「それらの変更をどう統合するか」を解決する仕組みが必要になる。

Fred Brooksは1975年の著書『The Mythical Man-Month』で、チームの通信コストがメンバー数の二乗に比例して増大することを指摘した。n人のチームではn(n-1)/2の通信経路が生じる。5人なら10本、10人なら45本、50人なら1,225本だ。この通信コストの爆発が、大規模ソフトウェア開発を困難にする根本原因の一つだ。

バージョン管理の「協調」機能は、この通信コストを構造化し、管理可能にする仕組みだと言える。開発者同士が直接調整する代わりに、バージョン管理システムが変更の統合を仲介する。

SCCSとRCSは、ロック方式でこの問題に対処した。ファイルを編集するには、まずロックを取得する。ロックを持つ開発者だけが変更をコミットできる。他の開発者はロックが解放されるまで待つ。これは悲観的並行制御（pessimistic concurrency control）だ。コンフリクトは原理的に発生しないが、直列化のコストが高い。

CVSは、この問題に対する革命的な回答を提供した。Copy-Modify-Mergeモデルだ。開発者は各自がリポジトリのコピーを取得し（copy）、自由に変更し（modify）、変更をリポジトリに戻す際にマージする（merge）。楽観的並行制御（optimistic concurrency control）だ。コンフリクトは発生しうるが、多くの場合、変更は異なるファイルや異なる行に対して行われるため、自動的に統合できる。

この設計判断の背景には、1968年にMelvin Conwayが指摘した洞察がある。「組織はそのコミュニケーション構造を反映したシステムを設計する」——Conway's Lawだ。CVSが登場した1986年、ソフトウェア開発チームは地理的に一箇所に集まっていることが多かったが、プロジェクトの規模は拡大し、同時並行作業の必要性が高まっていた。Copy-Modify-Mergeモデルは、この時代の組織構造——同一ネットワーク内で共同作業する中規模チーム——に適した協調モデルだった。

Gitは、さらに分散的な協調モデルを実現した。各開発者がリポジトリの完全なコピー（クローン）を持ち、ローカルで自由にブランチを切り、コミットを重ね、準備ができたら変更を共有する。中央サーバーに常時接続している必要はない。これは、OSS開発——世界中に散らばった開発者が、異なるタイムゾーンで、非同期に協調する——という組織構造を反映した設計だ。

ここで注目すべきは、Leslie Lamportが1978年の論文「Time, Clocks, and the Ordering of Events in a Distributed System」で示した洞察との関連だ。Lamportは、分散システムにおいてイベントの全順序を定義することが本質的に困難であることを示した。分散型VCSにおいて、異なるリポジトリで並行して行われたコミットの「順序」をどう定義するか——これはLamportが提起した問題のバージョン管理における変形だ。

Gitはこの問題をDAG（有向非巡回グラフ）で解いた。コミットは時系列ではなく、因果関係（親コミットへの参照）によって順序付けられる。並行して行われたコミットの間には「どちらが先か」という順序がない。マージコミットが二つの並行した流れを合流させるとき、初めて順序が確定する。

Subversionの連番リビジョンモデルでは、すべてのコミットに全順序が存在する。リビジョン1234の次はリビジョン1235だ。これが可能なのは、中央サーバーがすべてのコミットを直列化するからだ。分散型VCSではこの直列化が原理的に不可能であり、DAGによる半順序が必然的な選択となる。

協調の仕組みは、時代とともに進化してきた。だが、その根底にある問題——複数の人間が同じものを同時に変更するとき、どう統合するか——は変わらない。ロック、Copy-Modify-Merge、分散DAG——これらは同じ問題に対する異なる解だ。

### 歴史の保存——Why did it change?

バージョン管理の第三の本質は、歴史の保存だ。「何が変わったか」を記録するだけでなく、「なぜ変わったか」を記録し、後から参照可能にすること。

この第三の本質は、最も軽視されがちであり、かつ最も重要だ。

SCCSとRCSの時代、変更の理由は短いコメント——いわゆるログメッセージ——として記録された。ciコマンド（RCS）でファイルをチェックインする際に、変更理由を一行程度で記述する。だが、ファイル単位の管理では、複数ファイルにまたがる変更の「なぜ」を記録する場所がなかった。

CVSは、コミットログによって変更の理由を記録する仕組みを提供した。だが、第5回で論じたように、CVSにはアトミックコミットがなかった。複数ファイルの変更が一つの論理的な単位として記録されないため、「なぜこの一連の変更が行われたか」を後から追跡することが困難だった。

Subversionは、アトミックコミットとリビジョン単位のログメッセージによって、この問題を改善した。リビジョン1234で行われた変更は、すべてのファイル変更とその理由を一つの単位として記録する。svn log -r 1234 で、その変更の全貌と理由を確認できる。

Gitは、この「なぜ」の記録をさらに豊かにした。Gitのコミットメッセージは、一行の要約と、改行を挟んだ詳細な説明を持つ構造になっている。Gitコミュニティには「メッセージの本文ではwhatとwhyを説明せよ。howはコードが語る」という慣行がある。さらに、git blameコマンドは、ファイルの各行が「いつ」「誰によって」「どのコミットで」変更されたかを表示する。これは「歴史の保存」の最も直接的な実装だ。

だが、ここで根本的な問いが生じる。「なぜ変わったか」を記録する仕組みが存在することと、実際に有用な「なぜ」が記録されることは、別の問題だ。

git logを開いてみてほしい。「fix bug」「update」「WIP」——このようなメッセージがいくつ見えるだろうか。ツールは「なぜ」を記録する場所を提供するが、そこに何を書くかは人間次第だ。

Fred Brooksは1986年の論文「No Silver Bullet」で、ソフトウェアの複雑さを「本質的複雑さ（essential complexity）」と「偶有的複雑さ（accidental complexity）」に分類した。本質的複雑さは問題領域そのものに内在する複雑さであり、ツールでは排除できない。偶有的複雑さは、ツールや手法の不備によって生じる複雑さであり、改善可能だ。

この区別をバージョン管理に適用すると、こうなる。「何が変わったか」の記録は、ツールが自動化できる——これは偶有的複雑さの排除だ。diffアルゴリズムが差分を計算し、ツールが保存する。人間の介入は不要だ。

「なぜ変わったか」の記録は、本質的に人間の営みだ。変更の理由——ビジネス要件の変化、バグの修正、技術的負債の返済、パフォーマンスの改善——を理解し、言語化し、後の読者に伝わる形で記述すること。これはツールでは自動化できない。コミットメッセージの入力欄を設けることはツールの仕事だが、そこに何を書くかは人間の判断だ。

バージョン管理の歴史は、「偶有的複雑さの排除」の歴史でもある。手動のcp -rからSCCS/RCSへ、RCSからCVSへ、CVSからSubversionへ、SubversionからGitへ——各世代のツールは、前世代の偶有的複雑さを排除してきた。ファイルロックの不便さ、非アトミックコミットの危険性、中央サーバーへの依存——これらは偶有的複雑さであり、ツールの進化によって解消されてきた。

だが、「なぜ変わったか」を記録する行為の本質的複雑さは、50年間変わっていない。SCCSの時代もGitの時代も、人間が変更の理由を言語化し、記録する必要がある。この本質は、AI時代になっても変わらないだろう。

---

## 3. 三つの本質で各VCSを再評価する

### 評価のフレームワーク

ここまでに整理した「三つの本質」——変更の記録（What changed?）、協調の仕組み（Who changed it, and how do we integrate?）、歴史の保存（Why did it change?）——で、この連載で取り上げたバージョン管理ツールを再評価してみよう。

これは優劣をつけるための評価ではない。各ツールが、それぞれの時代の制約の中で、三つの本質にどう応えようとしたかを理解するための整理だ。

### SCCS/RCS——「変更の記録」を解いた先駆者

SCCSとRCSは、三つの本質のうち「変更の記録」に集中的に取り組んだ。

変更の記録においては、両者とも優れた解を提供した。SCCSのインターリーブドデルタ、RCSのリバースデルタは、それぞれ異なるトレードオフを持つが、いずれもファイルの変更履歴を完全に記録し、任意のバージョンを復元する機能を実現した。

協調の仕組みにおいては、ロック方式による悲観的並行制御を採用した。これは「協調」というよりも「排他」に近い。一人がファイルを編集している間、他の開発者は待つ。だが、当時の技術的制約——低速なネットワーク、単一マシンでの開発——を考えれば、これは合理的な選択だった。

歴史の保存においては、ファイル単位のログメッセージを提供した。だが、複数ファイルにまたがる変更の「なぜ」を記録する仕組みはなかった。これは設計の限界ではなく、時代の制約だ。SCCSとRCSが想定していたのは、個々のファイルの管理であって、プロジェクト全体の構成管理ではなかった。

### CVS——「協調」を解いた革命

CVSの最大の功績は、三つの本質のうち「協調」に革命をもたらしたことだ。

Copy-Modify-Mergeモデルは、ロック方式の制約から開発者を解放した。複数の開発者が同じファイルを同時に編集し、変更を後からマージできる。これは「協調」の設計における根本的なパラダイムシフトだった。

だが、CVSは「変更の記録」においては構造的な弱点を持っていた。アトミックコミットの不在——複数ファイルの変更が一つの単位として記録されない——は、「何が変わったか」の記録の粒度を粗くした。あるファイルの変更と別のファイルの変更が論理的に一つの単位であっても、CVSのレベルではそれを保証できなかった。

「歴史の保存」においても、アトミックコミットの不在は影響した。ファイル単位のログメッセージは存在するが、「この一連の変更はなぜ行われたか」を一箇所に記録する仕組みがない。複数のファイルログを人間が突き合わせて、変更の全体像を再構成する必要があった。

### Subversion——三つの本質のバランス

Subversionは、三つの本質に対してバランスの取れた解を提供した最初のツールだ。

アトミックコミットにより、「変更の記録」は論理的な単位で行われるようになった。リビジョン番号の一意性により、「いつ、何が変わったか」が明確に識別できる。

協調においては、CVSのCopy-Modify-Mergeモデルを継承しつつ、ディレクトリのバージョン管理やリネーム追跡を加えた。だが、集中型モデルの制約により、オフライン作業やブランチの柔軟性には限界があった。

歴史の保存においては、リビジョン単位のログメッセージが「なぜ」の記録場所を提供した。svn log -r NNNで、変更の理由を含む完全な情報にアクセスできる。svn blameもファイルの行単位での変更追跡を可能にした。

Subversionが「CVS done right」と呼ばれた理由は、技術的な改善だけではない。三つの本質に対するバランスの良さが、実用上の信頼性と使いやすさを生んだのだ。

### Git——「協調」の再定義と「歴史」の深化

Gitは、三つの本質のそれぞれに対して、根本的に新しい解を提供した。

変更の記録において、Gitのスナップショットモデルはデルタ方式とは異なるアプローチだ。各コミットはリポジトリ全体の状態を記録する。差分ではなく状態が記録の基本単位である。この設計により、任意の二つのコミット間の差分を動的に計算でき、ブランチ間の比較が自然に行える。

協調において、Gitの分散モデルは「中央」を前提としない。各開発者が完全なリポジトリを持ち、ローカルでブランチを切り、コミットを重ね、準備ができたら共有する。Pull Requestモデル（GitHubによる拡張）は、コードレビューを協調の標準的なプロセスに組み込んだ。

歴史の保存において、Gitは複数の層で「なぜ」の記録を可能にした。コミットメッセージ、マージコミットのメッセージ、タグのアノテーション、git blameによる行単位の追跡。さらに、git bisectは「いつバグが混入したか」を二分探索で特定する。これは「歴史」を単なる記録ではなく、調査のための道具として活用する機能だ。

だが、Gitの設計には、三つの本質の観点から見た課題もある。

ステージングエリア（index）は、「変更の記録」のプロセスに中間状態を導入する。これは精密な制御を可能にする一方、概念的な複雑さを増す。第22回で紹介したPerez De Rossoらの研究が指摘した通り、ステージングエリアは初学者にとって最大の混乱の源泉だ。Jujutsu、Sapling、Pijulがいずれもステージングエリアを廃止した事実は、この設計判断が「偶有的複雑さ」の追加であった可能性を示唆する。

また、Gitの分散モデルは「協調」の自由度を最大化する一方、「誰がどの変更を統合する権限を持つか」を制度的に定義する仕組みを持たない。この空白を埋めたのがGitHubのPull Requestモデルだが、これはGit自体の機能ではなく、プラットフォームによる拡張だ。

### 三つの本質の進化マトリクス

ここまでの分析を一覧にまとめると、バージョン管理の進化の方向性が見えてくる。

```
三つの本質の進化マトリクス

            変更の記録        協調の仕組み          歴史の保存
            (What changed?)   (Who & How?)          (Why?)
───────────────────────────────────────────────────────────────
SCCS/RCS    デルタ方式        ファイルロック        ファイル単位
(1972-82)   ファイル単位      （排他的）            ログコメント

CVS         デルタ方式        Copy-Modify-Merge     ファイル単位
(1986)      ファイル単位      （楽観的並行制御）    ログメッセージ
            非アトミック                            非アトミック

SVN         デルタ方式        Copy-Modify-Merge     リビジョン単位
(2000)      リビジョン単位    集中型サーバー        ログメッセージ
            アトミック                              blame対応

Git         スナップショット  分散DAG               コミット単位
(2005)      コンテンツ        ブランチ＝ポインタ    構造化メッセージ
            アドレッサブル    Pull Request（拡張）   blame, bisect

Jujutsu     Gitバックエンド   分散DAG               オペレーション
(2019-)     自動スナップ      コンフリクトの         ログによる
            ショット          ファーストクラス化     完全な操作履歴
───────────────────────────────────────────────────────────────
```

このマトリクスから読み取れるのは、三つの本質が均等に進化してきたわけではないということだ。

「変更の記録」は、SCCSの時代からすでに高い水準にあった。差分の計算と保存は、アルゴリズムの改良によって効率化されたが、基本的な概念は50年間変わっていない。

「協調の仕組み」は、最も劇的な進化を遂げた領域だ。ファイルロックからCopy-Modify-Merge、そして分散DAGへ——各世代で根本的なパラダイムシフトが起きている。これは、ソフトウェア開発の組織形態が変化し続けてきたことの反映だ。単一マシンから社内ネットワーク、そしてインターネット経由のグローバル協調へ。

「歴史の保存」は、ツール側の進化が最も遅い領域だ。コミットメッセージの構造はGitで改善されたが、「なぜ変わったか」を記録する行為の本質は人間に委ねられたままだ。AI時代において、ここに最も大きな変革の余地がある。

---

## 4. ハンズオン：自分のワークフローを「三つの本質」で再評価する

このハンズオンは、これまでの連載と趣が異なる。特定のツールをインストールして操作するのではなく、自分自身の開発ワークフローを「三つの本質」の観点から分析し、改善点を見つける演習だ。Gitリポジトリを対象に、三つの本質がどう実現されているかを具体的に検証する。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash

# 必要なパッケージのインストール
apt update && apt install -y git

# gitの設定
git config --global user.email "developer@example.com"
git config --global user.name "Developer"
git config --global init.defaultBranch main
```

### 演習1：「変更の記録」を検証する——git diffの解剖

```bash
WORKDIR="${HOME}/vcs-handson-23"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=== 演習1: 変更の記録を検証する ==="
echo ""

# サンプルリポジトリを作成
git init eval-project
cd eval-project

# 初期ファイルを作成
cat > app.py << 'PYEOF'
class UserService:
    def __init__(self, db):
        self.db = db

    def get_user(self, user_id):
        return self.db.query(f"SELECT * FROM users WHERE id = {user_id}")

    def list_users(self):
        return self.db.query("SELECT * FROM users")
PYEOF

git add app.py
git commit -m "Add initial UserService implementation"

# 変更を加える（SQLインジェクション対策）
cat > app.py << 'PYEOF'
class UserService:
    def __init__(self, db):
        self.db = db

    def get_user(self, user_id):
        return self.db.query("SELECT * FROM users WHERE id = %s", (user_id,))

    def list_users(self, limit=100):
        return self.db.query("SELECT * FROM users LIMIT %s", (limit,))
PYEOF

echo "--- git diff: 何が変わったかを確認 ---"
git diff
echo ""

echo "-> diffが示すのは「何が変わったか（What changed?）」"
echo "   行6: SQLインジェクション対策としてパラメータ化クエリに変更"
echo "   行9: list_usersにlimit引数を追加"
echo ""
echo "-> ここで問いかけ: この差分から「なぜ変えたか」は読み取れるか？"
echo "   diff自体は「What」を示すが「Why」は示さない"
echo ""

# コミットメッセージで「Why」を記録する
git add app.py
git commit -m "$(cat <<'COMMITEOF'
Fix SQL injection vulnerability in UserService

The get_user method was using f-string interpolation to build SQL queries,
which is vulnerable to SQL injection attacks. Changed to parameterized
queries using placeholder syntax.

Also added a limit parameter to list_users to prevent unbounded queries
that could cause performance issues with large user tables.
COMMITEOF
)"

echo "--- git log: Whyを含む完全な記録 ---"
git log -1 --format=full
echo ""

echo "-> コミットメッセージの本文が「Why（なぜ変えたか）」を記録する"
echo "   1行目: 変更の要約（What）"
echo "   本文: 変更の理由と背景（Why）"
echo "   コード: 変更の実装方法（How）"
```

### 演習2：「協調の仕組み」を検証する——マージの本質

```bash
echo ""
echo "=== 演習2: 協調の仕組みを検証する ==="
echo ""

cd "${WORKDIR}/eval-project"

# 二人の開発者が同時に作業するシナリオ
# 開発者A: 認証機能を追加
git checkout -b feature/auth
cat > auth.py << 'PYEOF'
import hashlib

class AuthService:
    def __init__(self, user_service):
        self.user_service = user_service

    def authenticate(self, username, password):
        user = self.user_service.get_user_by_name(username)
        if user and self.verify_password(password, user['password_hash']):
            return True
        return False

    def verify_password(self, password, password_hash):
        return hashlib.sha256(password.encode()).hexdigest() == password_hash
PYEOF

# app.pyにもget_user_by_nameメソッドを追加
cat > app.py << 'PYEOF'
class UserService:
    def __init__(self, db):
        self.db = db

    def get_user(self, user_id):
        return self.db.query("SELECT * FROM users WHERE id = %s", (user_id,))

    def get_user_by_name(self, username):
        return self.db.query("SELECT * FROM users WHERE name = %s", (username,))

    def list_users(self, limit=100):
        return self.db.query("SELECT * FROM users LIMIT %s", (limit,))
PYEOF

git add -A
git commit -m "Add authentication service with password verification"

# 開発者B: ロギング機能を追加（mainブランチから分岐）
git checkout main
git checkout -b feature/logging

cat > app.py << 'PYEOF'
import logging

logger = logging.getLogger(__name__)

class UserService:
    def __init__(self, db):
        self.db = db

    def get_user(self, user_id):
        logger.info("Fetching user: %s", user_id)
        return self.db.query("SELECT * FROM users WHERE id = %s", (user_id,))

    def list_users(self, limit=100):
        logger.info("Listing users with limit: %s", limit)
        return self.db.query("SELECT * FROM users LIMIT %s", (limit,))
PYEOF

git add -A
git commit -m "Add logging to UserService for observability"

echo "--- 二つのブランチの状態 ---"
git log --oneline --all --graph
echo ""

echo "-> 二人の開発者が同じファイル（app.py）を同時に変更した"
echo "   開発者A: 認証用メソッドを追加"
echo "   開発者B: ロギングを追加"
echo ""

# マージを試みる
echo "--- mainブランチでマージを実行 ---"
git checkout main
git merge feature/auth -m "Merge authentication feature"

echo ""
echo "--- feature/loggingのマージを試みる ---"
git merge feature/logging -m "Merge logging feature" 2>&1 || true
echo ""

echo "-> コンフリクトが発生した場合、それは「協調」の限界点"
echo "   ツールが自動解決できない変更の衝突は"
echo "   人間の判断（= コミュニケーション）を必要とする"
echo ""
echo "-> バージョン管理は通信コストの大部分を吸収するが"
echo "   コンフリクトという形で「人間の判断が必要な場面」を可視化する"
```

### 演習3：「歴史の保存」を検証する——git blameとgit log

```bash
echo ""
echo "=== 演習3: 歴史の保存を検証する ==="
echo ""

cd "${WORKDIR}/eval-project"

# コンフリクトがあれば解消（演習の継続のため）
git checkout --theirs app.py 2>/dev/null
git add app.py 2>/dev/null
git commit -m "Merge logging feature (resolved conflicts)" 2>/dev/null

# 追加の変更履歴を積む
cat >> app.py << 'PYEOF'

    def delete_user(self, user_id):
        logger.warning("Deleting user: %s", user_id)
        return self.db.query("DELETE FROM users WHERE id = %s", (user_id,))
PYEOF

git add app.py
git commit -m "$(cat <<'COMMITEOF'
Add delete_user method with warning log

Added at the request of the admin dashboard team (ticket #1234).
Includes warning-level logging because user deletion is an
irreversible operation that should be auditable.
COMMITEOF
)"

echo "--- git blame: 各行の「誰が」「いつ」「なぜ」 ---"
git blame app.py
echo ""

echo "-> git blameは各行に対して以下を表示する:"
echo "   - コミットハッシュ（識別）"
echo "   - 著者名（誰が）"
echo "   - 日時（いつ）"
echo "   - コミットメッセージ（なぜ）への参照"
echo ""

echo "--- git log --oneline: 変更の時系列 ---"
git log --oneline
echo ""

echo "--- git shortlog: 貢献者ごとの要約 ---"
git shortlog -sn
echo ""

echo "-> 「歴史の保存」が機能するかどうかは"
echo "   コミットメッセージの質に依存する"
echo "   'fix bug'と書かれた履歴は、歴史として役に立たない"
echo "   'Fix SQL injection in get_user'と書かれた履歴は、将来の開発者を助ける"
```

### 演習4：三つの本質の自己評価ワークシート

```bash
echo ""
echo "=== 演習4: 三つの本質の自己評価ワークシート ==="
echo ""

cat << 'WORKSHEET'
以下の質問に「はい / いいえ / 部分的に」で回答し、
自分のワークフローの強み・弱みを把握してください。

【変更の記録 (What changed?)】
□ コミットは論理的に一つの変更単位にまとまっているか？
  （一つのコミットに複数の無関係な変更が混在していないか）
□ コミットの粒度は適切か？
  （大きすぎず小さすぎず、レビュー可能なサイズか）
□ 差分（diff）を見て、変更の範囲が理解できるか？
□ バイナリファイルの変更も追跡できているか？

【協調の仕組み (Who changed it, and how do we integrate?)】
□ ブランチ戦略は明文化されているか？
□ マージ/リベースの方針はチーム内で統一されているか？
□ コードレビューのプロセスが定義されているか？
□ コンフリクト解消の手順が共有されているか？
□ CIがマージ前に自動テストを実行しているか？

【歴史の保存 (Why did it change?)】
□ コミットメッセージに「なぜ」が記録されているか？
□ git blameの結果が有用な情報を提供するか？
□ 半年前の変更の理由を、git logから特定できるか？
□ チケット番号やPRリンクがコミットに含まれているか？
□ コミットメッセージの書き方がチーム内で統一されているか？

【総合評価】
あなたのワークフローで最も弱い領域はどれですか？
その弱さは、ツールの問題ですか？ プロセスの問題ですか？
人間の習慣の問題ですか？
WORKSHEET

echo ""
echo "-> このワークシートの目的は、ツールの機能ではなく"
echo "   ツールの「使い方」を評価することにある"
echo "   バージョン管理の本質は、ツールが提供するが"
echo "   本質を活かすかどうかは人間の運用にかかっている"
```

### 演習で見えたこと

四つの演習を通じて、バージョン管理の「三つの本質」がGitの日常的な操作にどう現れているかを確認した。

演習1では、git diffが「何が変わったか（What）」を自動的に計算し、コミットメッセージが「なぜ変わったか（Why）」を記録することを確認した。diffはツールの仕事だが、コミットメッセージは人間の仕事だ。

演習2では、ブランチとマージによる「協調」の仕組みを体験した。ツールが自動マージできる範囲では通信コストはゼロに近いが、コンフリクトが発生した瞬間に人間のコミュニケーションが必要になる。バージョン管理は通信コストを最小化する仕組みだが、ゼロにはできない。

演習3では、git blameとgit logによる「歴史の保存」を検証した。ツールは歴史を保存する場所を提供するが、歴史の質——コミットメッセージの質——は人間が決める。

演習4では、自分自身のワークフローを三つの本質で評価するワークシートを提供した。バージョン管理の本質を理解した上で、自分のチームの運用を振り返ることが、この演習の目的だ。

あなたのワークフローで最も弱い領域はどれだっただろうか。そして、その弱さを改善するために必要なのは、ツールの変更だろうか、プロセスの改善だろうか、それとも人間の習慣の見直しだろうか。

---

## 5. まとめと次回予告

### この回の要点

第一に、バージョン管理の本質は「三つの問い」に集約される。What changed?（変更の記録）、Who changed it, and how do we integrate?（協調の仕組み）、Why did it change?（歴史の保存）。SCCS（1972年）からGit（2005年）まで、すべてのバージョン管理ツールはこの三つの問いに応えようとしてきた。ツールは変わっても、問いは変わらない。

第二に、三つの本質の進化は均等ではない。「変更の記録」は初期から高い水準にあり、「協調の仕組み」は最も劇的な進化を遂げ、「歴史の保存」はツール側の進化が最も遅い。特に「なぜ変わったか」の記録は、本質的に人間の営みであり、ツールの自動化には限界がある。

第三に、Fred Brooksの「本質的複雑さと偶有的複雑さ」の区別は、バージョン管理の評価に有用だ。バージョン管理ツールの進化は、偶有的複雑さ——ファイルロック、非アトミックコミット、中央サーバー依存——の排除の歴史だ。だが、変更理由の記録という本質的複雑さは、ツールでは解消できない。

第四に、バージョン管理の設計は、その時代の組織構造を反映する。Conway's Lawが示すように、ツールの設計は開発組織のコミュニケーション構造と不可分だ。SCCSの単一マシンモデル、CVSの社内ネットワークモデル、Gitのグローバル分散モデル——いずれも、その時代の開発組織の構造が設計に反映されている。

第五に、自分のワークフローを三つの本質で評価することが、バージョン管理を「使いこなす」ための第一歩だ。gitの個々のコマンドを覚えることよりも、「自分のチームは三つの本質のうちどこが弱いか」を把握し、改善することの方が価値がある。

### 冒頭の問いへの暫定回答

結局、バージョン管理の本質とは何なのか。

この問いに対する私の暫定的な答えは、こうだ。バージョン管理とは、ソフトウェアの変更を「記録可能」「統合可能」「追跡可能」にするための仕組みである。

「記録可能」——何が変わったかを、機械が理解できる形で保存する。diffアルゴリズムの計算から、Gitのコンテンツアドレッサブルストレージまで、50年間の技術進化がこの能力を磨いてきた。

「統合可能」——複数の人間による並行した変更を、整合性を保ったまま一つにまとめる。ファイルロックからCopy-Modify-Merge、分散DAG、そしてパッチ理論のpushoutまで、協調のモデルは時代とともに進化してきた。

「追跡可能」——過去の変更の理由を、未来の人間が理解できる形で保存する。これはツールの問題であると同時に、人間の規律の問題だ。最も進んだツールを使っていても、コミットメッセージが「fix」の一言では、歴史は保存されない。

この三つが揃ったとき、バージョン管理は単なる「ファイルのバックアップ」を超えて、チームの知識基盤になる。20年前の自分がスライドに書いた三行は、今にして思えば、この本質を直感的に捉えていた。

### 次回予告

**第24回「git ありきの世界に改めて問う——あなたは何を選ぶか」**

次回は最終回だ。この連載を通じて得た知識を、明日からどう活かすかを考える。バージョン管理の歴史が教えてくれること——「最適解は常に変わる」。技術選定のフレームワークとして「なぜそのツールか」を説明できるエンジニアになるために、何が必要か。

gitを使うな、とは言わない。gitを「選んで」使え。選ぶためには、歴史を知れ——この連載の結論を、最終回で語る。

あなたは、この連載を通じて何を得ただろうか。そして、明日からのバージョン管理に、何を変えるだろうか。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Rochkind, Marc J. "The Source Code Control System." IEEE Transactions on Software Engineering, SE-1(4): 364-370, December 1975. <https://en.wikipedia.org/wiki/Source_Code_Control_System>
- Tichy, Walter F. "RCS—A System for Version Control." Software—Practice & Experience 15, 7, July 1985. <https://www.gnu.org/software/rcs/tichy-paper.pdf>
- Grune, Dick. "Concurrent Versions System." 1986. <https://dickgrune.com/Programs/CVS.orig/>
- Collins-Sussman, Ben, Fitzpatrick, Brian W., Pilato, C. Michael. "Version Control with Subversion." <https://svnbook.red-bean.com/en/1.6/svn.intro.whatis.html>
- Torvalds, Linus. Git initial commit (e83c5163316), April 7, 2005. <https://git-scm.com/book/en/v2/Getting-Started-A-Short-History-of-Git>
- Brooks, Frederick P. "No Silver Bullet—Essence and Accident in Software Engineering." 1986. <https://worrydream.com/refs/Brooks_1986_-_No_Silver_Bullet.pdf>
- Brooks, Frederick P. "The Mythical Man-Month: Essays on Software Engineering." Addison-Wesley, 1975. <https://en.wikipedia.org/wiki/The_Mythical_Man-Month>
- Conway, Melvin E. "How Do Committees Invent?" Datamation, April 1968. <https://www.melconway.com/Home/Conways_Law.html>
- Lamport, Leslie. "Time, Clocks, and the Ordering of Events in a Distributed System." Communications of the ACM, 21(7): 558-565, July 1978. <https://dl.acm.org/doi/10.1145/359545.359563>
- IEEE Std 828-1983. "IEEE Standard for Software Configuration Management Plans." <https://ieeexplore.ieee.org/document/7439689>
- Hunt, J. W., McIlroy, M. D. "An Algorithm for Differential File Comparison." Bell Laboratories Computing Science Technical Report #41, July 1976. <https://www.cs.dartmouth.edu/~doug/diff.pdf>
- Perez De Rosso, S., Jackson, D. "What's Wrong with Git? A Conceptual Design Analysis." Onward! 2013. <https://spderosso.github.io/onward13.pdf>
