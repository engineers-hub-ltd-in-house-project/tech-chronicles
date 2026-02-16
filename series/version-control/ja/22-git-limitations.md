# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第22回：gitの限界——次世代VCSへの要求仕様

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Gitが抱える設計上の制約——スケーリング問題、UXの非一貫性、ステージングモデルの複雑さ、SHA-1からの移行の困難
- 世界最大規模のコードベースがGitで直面した現実——Microsoft（300GB/350万ファイル）、Google（20億行/独自VCS）、Meta（Git→Mercurial→Sapling）の選択
- パッチ理論の数学的基盤——Darcsが開拓しPijulが厳密化した、圏論のpushoutに基づくマージモデル
- 次世代VCSの設計思想——Jujutsu（Git互換・オペレーションログ・自動スナップショット）、Sapling（スケーラビリティ・Smartlog）、Pijul（パッチ理論）
- Git互換性と革新のジレンマ——既存エコシステムとの互換を維持しつつ設計を刷新することの困難と、各プロジェクトの戦略的選択
- Git 3.0の計画——SHA-256デフォルト化、Rust必須ビルド要件、2026年後半リリース目標

---

## 1. 「gitでは、もう無理だ」

2023年のある日、私はあるクライアントの開発チームから相談を受けた。

「モノレポのgit statusが30秒かかるんです。CIのcloneに20分。開発者が50人を超えたあたりから、全員が同じことを言い始めました。gitが遅い、と」

リポジトリの中身を見た。ソースコードだけで数十万ファイル、履歴は数万コミット。巨大ではあるが、世界的な基準で見れば中規模だ。MicrosoftのWindowsリポジトリは300GB・350万ファイル。GoogleのPiperは20億行以上のコード。Metaのリポジトリは数百万のファイルと数百万のコミットを抱えている。私のクライアントの規模は、それらに比べれば控えめだった。

それでも、gitは苦しんでいた。

shallow cloneを導入した。sparse checkoutを設定した。partial cloneを試した。git gc --aggressiveを定期実行するスクリプトを書いた。症状は改善した。だが、それは対症療法であって根本治療ではなかった。新しい開発者がチームに入るたびに同じ設定手順を案内し、CIパイプラインのclone設定を微調整し、「なぜこの設定が必要なのか」を説明し続ける日々が続いた。

この体験は、私にある問いを突きつけた。

gitは、2005年にLinus Torvaldsが解こうとした問題を見事に解いた。Linuxカーネルの分散開発に必要な速度、分散性、データの完全性を実現した。だが、2026年の開発環境が突きつける問題は、2005年のそれとは異なる。モノレポのスケーリング、AI支援開発における帰属管理、コマンドの複雑さ——これらはgitの設計が想定していなかった課題だ。

gitを超えるバージョン管理は、何を解決すべきなのか。そして、実際にそれを試みているプロジェクトは、どこまで進んでいるのか。

あなたは、gitに何を諦めているだろうか。

---

## 2. Gitの設計的制約——21年間の蓄積

### スケーリングの壁

Gitの内部設計は、第15回で詳述した通り、内容アドレッサブルストレージに基づいている。すべてのオブジェクト（blob、tree、commit、tag）はSHA-1ハッシュで識別され、`.git/objects`ディレクトリに格納される。この設計は優美であり、データの完全性を保証し、重複排除を自然に実現する。

だが、この設計にはスケーリングの壁がある。

第18回で論じたように、Gitはリポジトリの全履歴をローカルに保持する分散型VCSだ。git cloneを実行すると、すべてのコミット、すべてのtreeオブジェクト、すべてのblobが転送される。小規模なリポジトリでは問題にならないが、規模が大きくなると状況は劇的に変わる。

Microsoftは2017年、Windowsのコードベース——約300GB、350万ファイル——をGitに移行した。この移行は技術的な偉業だったが、素のGitでは不可能だった。移行前の計測では、git checkoutに最大3時間、git statusに約10分を要した。Microsoftは GVFS（Git Virtual File System）を開発し、ファイルシステムを仮想化することでこの問題に対処した。実際にアクセスされるまでファイルをダウンロードしない方式により、cloneを12時間超から数分に、checkoutを2-3時間から30秒に、statusを10分から4-5秒に短縮した。約3,500人のWindows開発者がこの仕組みの上でGitを運用している。

だが、GVFSは本質的にGitの設計を迂回する仕組みだ。Gitは「全履歴をローカルに保持する」ことを前提としている。GVFSは「必要なファイルだけを遅延ダウンロードする」ことでその前提を覆した。これはGitの設計思想との矛盾だ。後にMicrosoftはGVFSからScalarへと移行し、より軽量なアプローチを採ったが、根本的な問題——Gitの内部設計が大規模リポジトリを想定していないこと——は変わっていない。

Googleはさらに先を行った。Googleの内部リポジトリPiperは、約10億ファイル、約3,500万コミット、86TBのデータ、20億行以上のコードを保持している。1日あたり40,000件以上のコミットが行われる。2016年のACM論文「Why Google Stores Billions of Lines of Code in a Single Repository」では、「商用・OSSのバージョン管理システムで、このスケールを単一リポジトリでサポートできるものは見つからなかった」と述べられている。Googleは独自のPiperを構築する道を選んだ。Gitは選択肢にすら入らなかった。

Metaもまた、Gitの限界に直面した組織だ。2012年頃、FacebookのコードベースはLinuxカーネルの数倍に成長していた。Gitの基本操作——コミット、ステータス確認——に最大45分を要する状態に達し、MercurialへのVCS移行を決断した。その後、Mercurialを大幅にカスタマイズし、バックエンドをFacebook独自の分散オブジェクトストア「Eden」に置き換えた。だが、Mercurialコミュニティとの方向性の相違から、最終的にSaplingとしてフォークした。

これらの事例が示すのは、Gitの分散設計が大規模なコードベースに対して構造的な制約を持つという事実だ。Gitは「全員が全履歴を持つ」ことを前提とする。だが、数百万のファイルと数百万のコミットを持つリポジトリでは、「全員が全履歴を持つ」こと自体がボトルネックになる。partial clone、sparse checkout、shallow cloneといった機能はGitに順次追加されてきたが、いずれも後付けの対策であり、設計の根幹に手を入れるものではない。

### UXの非一貫性

Gitのもう一つの構造的な問題は、ユーザーインターフェースの非一貫性だ。

2013年、MITのSantiago Perez De RossoとDaniel Jacksonは、論文「What's Wrong with Git? A Conceptual Design Analysis」をOnward! 2013で発表した。この論文はGitの概念設計を体系的に分析し、いくつかの根本的な問題を指摘した。

第一に、コマンド構文の恣意性。git pullはgit fetchとgit mergeの組み合わせだが、git branchとgit checkoutの組み合わせのショートカットはgit checkout -bだ。コマンドの名前と実際の動作の対応関係に一貫した規則がない。

第二に、コマンドのオーバーロード。git checkoutはブランチの切り替えにも使えるし、ファイルの復元にも使える。git resetはステージングの取り消しにも、コミットの巻き戻しにも、作業ディレクトリの復元にも使える。同じコマンドがフラグやパラメータによって全く異なる動作をする。Git 2.23（2019年8月）でgit switchとgit restoreが導入され、checkoutのオーバーロードは部分的に解消されたが、後方互換性のためにcheckoutも残されている。

第三に、用語の不統一。ステージングエリアは「staging area」「index」「cache」の三つの名前で呼ばれる。いずれも同じものを指しているが、ドキュメントやエラーメッセージでの使い分けは一貫していない。

第四に、plumbing（配管）とporcelain（陶器）の断絶。Gitの内部コマンド（plumbing）とユーザー向けコマンド（porcelain）は概念的に分離されているが、porcelainコマンドの動作を理解するためにplumbingレベルの知識が必要になる場面が少なくない。「配管工でなければ陶器を使えない」という状況だ。

これらの問題は、Gitが21年間にわたって機能追加を重ねてきた結果でもある。Gitは2005年の誕生以来、膨大な数の機能が追加されてきた。だが、その過程で命名規則やコマンド体系の一貫性を維持することは、後方互換性の制約もあり、容易ではなかった。

Perez De RossoとJacksonはこの研究の延長線上で、Gitless——Gitの概念的再設計——を提案した。ステージングエリアの廃止、コマンドのオーバーロードの排除、トラッキング状態の簡素化。これらの改善案は、後に登場する次世代VCSの設計に影響を与えている。

### SHA-1からの脱却

Gitが抱えるもう一つの技術的負債は、ハッシュアルゴリズムだ。

Gitはオブジェクトの識別にSHA-1を使用している。SHA-1は2005年のGit誕生時には十分安全だと考えられていたが、2017年にGoogleとCWI Amsterdamが実用的なSHA-1衝突（SHAttered攻撃）を実証した。理論的には、悪意のある攻撃者が同じSHA-1ハッシュを持つ異なるGitオブジェクトを作成できる。

Git 3.0ではSHA-256をデフォルトのハッシュアルゴリズムに切り替える計画が進行している。2026年後半のリリースが目標だ。Brian m. carlsonがほぼすべてのSHA-256関連作業を担当しており、推定200-400パッチのうち約100が完了している。Git 2.42（2023年8月）でSHA-256リポジトリが「実験的好奇心」の段階を脱し、Git 2.45（2024年）でSHA-1/SHA-256の相互運用パッチが着手された。

だが、移行は容易ではない。SHA-1ハッシュはGitのあらゆる場所に埋め込まれている。コミットハッシュ、ツリーハッシュ、blobハッシュ——すべてのオブジェクト参照がSHA-1に依存している。SHA-256への移行は、Gitのデータモデルの根幹に関わる変更だ。さらに、GitHubやGitLabをはじめとするGitホスティングサービス、CI/CDパイプライン、コードレビューツール——すべてのGitエコシステムがSHA-256に対応する必要がある。全依存プロジェクトの対応状況が最大の障壁だと指摘されている。

加えて、Git 3.0ではRustを必須ビルド要件にする計画もある。Patrick Steinhardtが「試験気球」としてオプションのRustモジュールを導入するパッチを提出した。2005年以来Cで書かれてきたGitにとって、これは大きなアーキテクチャ変更だ。一方で、Rustコンパイラがサポートしないプラットフォームでのビルドが不可能になるため、プラットフォーム互換性の議論を引き起こしている。

20年間の成功は、20年間の技術的負債でもある。Gitはその成功ゆえに、根本的な設計変更が極めて困難なソフトウェアになった。

---

## 3. パッチ理論——マージの数学的基盤

### Darcsが開いた扉

Gitの設計的制約を理解した上で、「別のアプローチ」を考えた先人がいた。

2002年6月、物理学者のDavid Roundyは、GNU arch（当時の分散型VCS）のメーリングリストで、Tom Lordと新しいパッチフォーマットについて議論していた。この議論からコードが生まれることはなかったが、Roundyの頭の中にひとつの理論が芽生えた。「パッチの理論（Theory of Patches）」だ。

Roundyの着想は、量子力学の演算子との類推から生まれた。量子力学では、演算子の適用順序が結果に影響する（非可換性）。同様に、バージョン管理のパッチも、適用順序によって結果が変わりうる。だが、特定の条件下ではパッチの順序を入れ替えても結果が同じになる（可換性）。Roundyは、パッチの可換性を自動的に判定し、安全に順序を入れ替える仕組みを考案した。

この理論に基づいて、RoundyはDarcs（Darcs Advanced Revision Control System）を開発した。最初はC++で実装し、2002年秋にHaskellで書き直し、2003年4月に公開した。

Darcsの革新性は、「スナップショット」ではなく「パッチ」を中心に据えたデータモデルにある。Gitはリポジトリの状態のスナップショット（commit）を記録し、ブランチ間のマージは共通祖先からの差分を統合する操作だ。一方、Darcsはパッチの集合としてリポジトリを表現する。ブランチという概念すら不要だ。任意のパッチを選択的に適用したり、パッチの順序を並べ替えたりできる。cherry-pickがGitでは特別な操作であるのに対し、Darcsではパッチの選択的適用が自然な基本操作だ。

だが、Darcsには深刻な問題があった。特定のパッチの組み合わせにおいて、マージの計算量が指数的に爆発する可能性があったのだ。最悪ケースではO(2^h)——hは履歴の深さ——に達する。Darcs 2.0（2008年4月）で「darcs-2」セマンティクスを導入して問題を軽減したが、完全には解決できなかった。

この指数的マージ問題は、Darcsの実用性を著しく制限した。Darcsは美しい理論に基づいていたが、大規模なプロジェクトでの信頼性に懸念があった。結果として、Darcsは広く普及することなく、ニッチなVCSにとどまった。

### Pijulの挑戦——圏論による再定式化

Darcsのパッチ理論を救い出そうとしたのが、Pijulだ。

2015年、フランスの研究者Pierre-Etienne MeunierとFlorent Beckerは、自己集合に関する学術論文を執筆中に、バージョン管理の問題について議論していた。Beckerは当時Darcsのコア貢献者であり、Darcsの指数的マージ問題を身をもって知っていた。二人は、パッチ理論を数学的により厳密な基盤の上に再構築することで、この問題を解決できるのではないかと考えた。

彼らが依拠したのは、Samuel MimramとCinzia di Giustoの論文「A Categorical Theory of Patches」（2013年）だ。この論文は、パッチ理論を圏論（カテゴリ理論）の枠組みで定式化した。

圏論の用語で説明すると、こうなる。ファイル（作業ディレクトリの状態）をオブジェクト、パッチを射（arrow）とする圏を定義する。二人の開発者が同じファイルを同時に編集した場合、それぞれの変更をマージする操作は、圏論でいう「pushout」として定義される。pushoutとは、二つの射が共通の始点から出発するとき、それぞれの終点を「合流」させるオブジェクトのことだ。

```
       パッチA
元の状態 ───────→ Aの編集後
   │                  │
   │ パッチB           │ B'（Aの文脈でのB）
   ▼                  ▼
Bの編集後 ───────→ マージ結果（pushout）
       A'（Bの文脈でのA）
```

Darcsがパッチの交換（commutation）を中心概念に据えていたのに対し、Pijulはpushout（合併）を中心に据えた。この再定式化により、Darcsで問題だった指数的マージコストが解消された。Pijulのパッチ適用は`O(p * c * log(h))`——pはパッチサイズ、cはコンテキストサイズ、hは履歴の深さ——で済む。

二つのパッチが非互換の場合——つまり、同じ行を同時に編集した場合——pushoutは圏内に存在しないことがある。Pijulはこの問題に対して、圏の「自由余極限完備化（free co-completion）」という手法で対処する。コンフリクトをファイルの特殊な状態として表現し、圏の中に保持する。コンフリクトは「エラー」ではなく「まだ解決されていない状態」として扱われるのだ。

Pijulは2017年1月に最初の動作版を公開し、2020年11月にアルファ版をリリースした。Rustで実装され、GPL2ライセンスで公開されている。

パッチ理論に基づくVCSは、Gitとは根本的に異なるマージモデルを提供する。Gitの3-way mergeは共通祖先からの差分を統合する操作であり、マージの結果は操作の順序に依存しうる。パッチ理論に基づくマージは、数学的に一意の結果を保証する。理論的には、cherry-pickやrebaseが「情報の損失なし」に行えるはずだ。

ただし、理論の優美さが実用性に直結するわけではない。Pijulは2026年現在もアルファ段階であり、Git互換性を持たない独自のデータモデルを採用している。GitHubやGitLabのエコシステムから独立しているため、既存のワークフローからの移行障壁が高い。数学的に正しいことと、実用的に普及することは、別の問題だ。

---

## 4. 次世代VCSの現在地

### Jujutsu——Gitを内側から再設計する

Pijulが「Gitとは全く異なるデータモデル」で勝負する道を選んだのに対し、別のアプローチを採ったプロジェクトがある。GoogleのMartin von Zweigbergkが開発するJujutsu（jj）だ。

2019年後半、von ZweigbergkはGitのユーザー体験に不満を抱き、趣味プロジェクトとしてJujutsuの開発を始めた。その後、Googleでのフルタイムプロジェクトに発展し、複数のGooglerが開発に参加している。Apache 2.0ライセンスで公開され、Rustで実装されている。

Jujutsuの最大の特徴は、Gitリポジトリをストレージバックエンドとして使用することだ。コミットやファイルはGitのオブジェクトとして保存される。つまり、既存のGitリポジトリに対してJujutsuのCLI（jjコマンド）でそのまま操作できる。GitHubへのpush、CI/CDパイプライン、コードレビューツール——すべての既存エコシステムがそのまま動く。

だが、Jujutsuのユーザー体験はGitとは根本的に異なる。

**作業コピーの自動スナップショット化。** Gitではファイルを編集した後、git addでステージングエリアに追加し、git commitでコミットする。この「ステージング」の手順は、前述のPerez De Rossoらの研究でも指摘された複雑さの源泉だ。Jujutsuでは、ファイルの変更は自動的にコミットとして記録される。ステージングエリアという概念自体が存在しない。コマンドを実行するたびに作業コピーがスナップショットされ、通常のコミットとして扱われる。これにより、Gitのstashも不要になる。コミットが唯一の可視オブジェクトであり、データモデルが劇的に単純化される。

**オペレーションログ。** Jujutsuはリポジトリに対するすべての操作を記録する。各操作オブジェクトには、操作後のリポジトリ状態のスナップショット（「ビュー」）が含まれる。jj undoで直前の操作を取り消せるだけでなく、jj op revertで過去の特定の操作を巻き戻せる。jj op restoreでリポジトリ全体を過去の状態に復元することも可能だ。Gitのreflogに近い機能だが、より体系的であり、すべての操作が対象になる。

**コンフリクトのファーストクラスサポート。** Gitではマージコンフリクトが発生するとマージ操作が中断され、手動解決が求められる。Jujutsuでは、コンフリクトはコミットの一部として記録される。操作はコンフリクトの有無にかかわらず完了する。コンフリクトは後から解決でき、解決結果は子孫コミットに自動的に伝播する。

```
Gitのマージ:
  ブランチA ─┐
             ├── マージコミット（コンフリクトがあれば中断）
  ブランチB ─┘

Jujutsuのマージ:
  変更A ─┐
         ├── マージコミット（コンフリクト情報を含む、操作は完了）
  変更B ─┘
         │
         ▼
  コンフリクト解決コミット（後から作成、子孫に自動伝播）
```

Jujutsuは2025年時点でGoogle内部で約900ユーザーが使用しており、急速に増加している。Linux限定のGA（一般提供）が2026年前半に予定されており、その後Google内部のMercurial統合ユーザーを移行する計画だ。

Jujutsuのアプローチは「Gitのデータ層はそのまま使い、ユーザー体験だけを刷新する」というものだ。これは、Gitのエコシステムとの互換性を最大限に維持しつつ、UXの問題を解決する戦略的に賢明な選択だ。だが、Gitのストレージ層に依存する以上、Gitのスケーリング問題は解決されない。また、Gitのブランチ（Jujutsuでは「ブックマーク」と呼ぶ）やその他の高レベルメタデータはGitの外で管理されるため、Git互換とはいえ完全な透過性があるわけではない。

### Sapling——スケーラビリティからの再出発

Jujutsuが「UXの刷新」を主眼に置いているとすれば、MetaのSaplingは「スケーラビリティ」を主眼に置いている。

Saplingの歴史は、Metaのバージョン管理の苦闘の歴史でもある。前述の通り、Facebookは2012年頃にGitからMercurialに移行し、Mercurialを大幅にカスタマイズした。バックエンドを独自の分散オブジェクトストアに置き換え、仮想ファイルシステムEdenFSを開発し、スケーラブルなサーバーMononokeを構築した。最終的にMercurialコミュニティとの方向性の相違からSaplingとしてフォークし、2022年11月15日にオープンソースとして公開した。

Saplingは三つのコンポーネントから構成される。

**Saplingクライアント（slコマンド）。** Mercurialベースのコマンドラインインターフェース。Git互換クライアントとしても動作する。Smartlog——リポジトリの状態を視覚的に表示するWeb UI——が特徴的だ。ドラッグアンドドロップでのrebase、マルチウェイのcommit splitなど、既存のどのGit UIにもない操作体験を提供する。

**Mononoke。** 高度にスケーラブルな分散ソースコントロールサーバー。Meta内部の巨大リポジトリを支えるバックエンド。ただし、2026年現在、外部利用はまだサポートされていない。

**EdenFS。** 仮想ファイルシステム。チェックアウト時にすべてのファイルを実体化するのではなく、アクセスされたファイルだけをオンデマンドで提供する。MicrosoftのGVFS/Scalarと同様のアプローチだが、Sapling専用に最適化されている。

Saplingのアプローチは、Jujutsuとは異なる哲学に基づいている。Jujutsuが「既存のGitリポジトリの上で動く」ことを重視するのに対し、Saplingは「大規模リポジトリに対応するために、サーバーサイドからクライアントサイドまでフルスタックで再設計する」というアプローチだ。Git互換のクライアントモードも提供しているが、Saplingの真価はMononokeサーバーとEdenFSの組み合わせによるスケーラビリティにある。

しかし、Mononokeが外部利用を公式にサポートしていない現状では、Meta以外の組織がSaplingのスケーラビリティを最大限に活用するのは難しい。Git互換クライアントとして使う場合、Jujutsuとの差別化ポイントはSmartlogのUIや「スタッキングワークフロー」（コミットを積み重ねてレビューに出す方式）だ。

### 三者の比較——設計思想の違い

Pijul、Jujutsu、Saplingの三つの次世代VCSを並べると、設計思想の違いが鮮明になる。

```
┌─────────────┬────────────────┬────────────────┬────────────────┐
│             │    Pijul       │   Jujutsu      │   Sapling      │
├─────────────┼────────────────┼────────────────┼────────────────┤
│ 設計の軸    │ 理論的正しさ   │ UXの刷新       │ スケーラビリティ│
│ データモデル│ パッチ理論     │ Gitオブジェクト │ Mercurial派生  │
│ Git互換性   │ なし           │ 高い（バック   │ クライアント   │
│             │                │ エンド共有）   │ モードで対応   │
│ ステージング│ なし           │ なし           │ なし           │
│ マージモデル│ pushout        │ Gitの3-way     │ Gitの3-way     │
│             │ （数学的一意） │ merge互換      │ merge互換      │
│ スケーリング│ 未検証         │ Gitに依存      │ EdenFS+        │
│             │                │                │ Mononokeで対応 │
│ 実装言語    │ Rust           │ Rust           │ Rust/Python    │
│ ライセンス  │ GPL2           │ Apache 2.0     │ GPL2           │
│ 成熟度      │ アルファ       │ オープンベータ │ 本番運用       │
│             │ （2020年〜）   │ （Google内    │ （Meta内部）   │
│             │                │  約900ユーザー）│                │
│ 開発元      │ コミュニティ   │ Google         │ Meta           │
└─────────────┴────────────────┴────────────────┴────────────────┘
```

三者に共通するのは、ステージングエリアの廃止だ。Perez De Rossoらの研究が指摘したGitの概念的複雑さの源泉であるステージングエリアを、三者ともに排除している。これは、Gitの設計に対する批判が広く共有されていることの証左だ。

一方、最も大きな分岐点はGit互換性の扱いだ。JujutsuはGitのストレージを直接使うことで最高レベルの互換性を実現し、SaplingはGit互換クライアントモードを提供し、PijulはGit互換性を持たない。この選択は、各プロジェクトの普及戦略と直結している。

---

## 5. Git互換性と革新のジレンマ

次世代VCSの設計者が直面する最大のジレンマは、Git互換性と革新のトレードオフだ。

Gitは2026年現在、開発者の圧倒的多数が使用するVCSだ。GitHubのユーザー数は1億人を超え、GitHub Actionsが年間数十億のCI/CDジョブを実行している。GitLabやBitbucketも含めれば、Gitベースのエコシステムはソフトウェア開発のインフラそのものだ。このエコシステムとの互換性なしに新しいVCSを普及させることは、現実的には極めて困難だ。

Jujutsuが採った戦略——Gitリポジトリをバックエンドとして使う——は、この問題に対する最も実用的な回答の一つだ。開発者はjjコマンドを使いながら、gitコマンドと併用することもできる。チームの全員がJujutsuを使う必要はない。一人だけJujutsuに移行し、残りのチームメンバーはGitを使い続けることができる。移行の摩擦を最小限に抑える設計だ。

しかし、この戦略にはGitの設計制約を引き継ぐという代償がある。Gitのオブジェクトモデルに準拠する以上、Gitが苦手とする巨大バイナリの管理や、パスベースのアクセス制御は、Jujutsuでも同様に困難だ。Jujutsuの革新はUI/UXレイヤーに限定され、データモデルレイヤーでの革新はGitの制約の中でしか行えない。

Pijulが選んだ道——Git互換性を持たない独自のデータモデル——は、理論的には最も自由度が高い。パッチ理論に基づく数学的に厳密なマージモデルは、Gitの3-way mergeにはない性質を持つ。だが、GitHubにpushできない、CI/CDパイプラインがそのまま動かない、チームメンバー全員が移行する必要がある——これらの障壁は、技術的な優位性を帳消しにしうる。

Saplingは両者の中間に位置する。独自のサーバーサイドインフラ（Mononoke/EdenFS）で大規模リポジトリに対応しつつ、Git互換クライアントモードで既存エコシステムへの接続も維持する。だが、Mononokeの外部サポートが提供されない限り、Saplingのスケーラビリティの恩恵を受けられるのは事実上Meta内部に限られる。

このジレンマは、バージョン管理の歴史において繰り返されてきたパターンだ。

CVSはRCSの設計を拡張し、ネットワーク対応を実現した。SubversionはCVSの設計を「正しくやり直し」た。いずれも、既存のユーザーベースとの連続性を意識しながら、設計を改良した。一方、Gitは既存のCVS/Subversionとの互換性を一切持たずに登場した。Gitが成功できたのは、Linuxカーネル開発という強力なユースケースがあり、GitHubという決定的なプラットフォームが後から登場したからだ。

次世代VCSが同様の「破壊的イノベーション」を実現するためには、既存のGitエコシステムに匹敵するか、それを凌駕するプラットフォームが必要になる。あるいは、Jujutsuのように「Gitの内側から変える」アプローチが、最も現実的な道なのかもしれない。

---

## 6. ハンズオン：Jujutsuを体験する——Gitとの違いを手で確かめる

このハンズオンでは、次世代VCSであるJujutsu（jj）をインストールし、Gitとの違いを体験する。ステージングエリアの不在、作業コピーの自動スナップショット、オペレーションログによる操作の取り消しなど、Gitの設計とは異なるアプローチを実際に手を動かして確認する。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash

# 必要なパッケージのインストール
apt update && apt install -y git curl

# Jujutsuのインストール（公式バイナリ）
curl -fsSL https://github.com/jj-vcs/jj/releases/latest/download/jj-x86_64-unknown-linux-gnu.tar.gz \
  | tar xz -C /usr/local/bin
jj version
```

### 演習1：リポジトリの初期化とGitバックエンドの確認

```bash
WORKDIR="${HOME}/vcs-handson-22"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=== 演習1: リポジトリの初期化 ==="
echo ""

# gitの設定（jjのGitバックエンドが使う）
git config --global user.email "developer@example.com"
git config --global user.name "Developer"
git config --global init.defaultBranch main

# jjの設定
jj config set --user user.name "Developer"
jj config set --user user.email "developer@example.com"

# jjでリポジトリを初期化（Gitバックエンドを使用）
jj git init jj-demo
cd jj-demo

echo "--- jjのリポジトリ構造 ---"
ls -la
echo ""
echo "--- .gitディレクトリが存在する（Gitバックエンド）---"
ls -la .git/
echo ""

echo "--- jj log: 初期状態 ---"
jj log
echo ""
echo "-> jjはGitリポジトリをバックエンドとして使用する"
echo "   .gitディレクトリが存在し、gitコマンドでも操作可能"
```

### 演習2：ステージングエリアのないワークフロー

```bash
echo ""
echo "=== 演習2: ステージングなしのワークフロー ==="
echo ""

cd "${WORKDIR}/jj-demo"

# ファイルを作成
cat > hello.py << 'PYEOF'
def greet(name: str) -> str:
    return f"Hello, {name}!"

if __name__ == "__main__":
    print(greet("World"))
PYEOF

# jjではファイルを作成した時点で自動的に追跡される
echo "--- ファイル作成後のjj status ---"
jj status
echo ""

echo "--- ファイル作成後のjj log ---"
jj log
echo ""

echo "-> Gitなら 'git add hello.py && git commit' が必要"
echo "   jjでは作業コピーが自動的にスナップショットされる"
echo "   ステージングエリア（index）という概念がない"
echo ""

# コミットにメッセージを設定（describeコマンド）
jj describe -m "Add greeting function"

echo "--- describe後のjj log ---"
jj log
echo ""

# 新しい変更を開始（Gitのcommitに相当）
jj new
echo "--- jj new後のlog ---"
jj log
echo ""

echo "-> jj describeでコミットメッセージを設定"
echo "   jj newで新しい変更セットを開始（=現在のコミットを確定）"
echo "   Gitの 'git add → git commit' が不要"
```

### 演習3：オペレーションログと操作の取り消し

```bash
echo ""
echo "=== 演習3: オペレーションログと操作の取り消し ==="
echo ""

cd "${WORKDIR}/jj-demo"

# ファイルを追加
cat > utils.py << 'PYEOF'
from datetime import datetime, timezone

def now_utc() -> str:
    return datetime.now(timezone.utc).isoformat()
PYEOF

jj describe -m "Add utility functions"
jj new

# さらにファイルを追加
cat > config.py << 'PYEOF'
import os

DEBUG = os.getenv("DEBUG", "false").lower() == "true"
PYEOF

jj describe -m "Add configuration module"
jj new

echo "--- 現在のjj log ---"
jj log
echo ""

# オペレーションログを確認
echo "--- オペレーションログ ---"
jj op log --limit 5
echo ""

echo "-> jjは全ての操作を記録する"
echo "   Gitのreflogに近いが、より体系的"
echo ""

# 直前の操作を取り消す
echo "--- jj undoで直前の操作を取り消し ---"
jj undo
echo ""

echo "--- undo後のjj log ---"
jj log
echo ""

echo "-> jj undoで任意の操作を安全に取り消せる"
echo "   Gitの 'git reset' と異なり、データが失われない"
```

### 演習4：Gitとの相互運用

```bash
echo ""
echo "=== 演習4: Gitとの相互運用 ==="
echo ""

cd "${WORKDIR}/jj-demo"

# jjでの作業をGit側から確認
echo "--- Git側から見たコミットログ ---"
git log --oneline --all 2>/dev/null || echo "(Gitブランチ未作成)"
echo ""

# jjのブックマーク（Gitのブランチに相当）を作成してGitに反映
jj bookmark create main -r @-
jj git export

echo "--- ブックマーク作成・エクスポート後のgit log ---"
git log --oneline --all
echo ""

echo "--- jj logとgit logの対応 ---"
echo ""
echo "jj log:"
jj log --no-graph -T 'change_id.shortest() ++ " " ++ description.first_line() ++ "\n"' -r ..
echo ""
echo "git log:"
git log --oneline
echo ""

echo "-> jjの変更はGitバックエンドに保存される"
echo "   jj git exportでブックマークをGitブランチに反映"
echo "   GitHub/GitLabへのpushはgitコマンドまたはjj git pushで可能"
```

### 演習5：コンフリクトのファーストクラスサポート

```bash
echo ""
echo "=== 演習5: コンフリクトのファーストクラスサポート ==="
echo ""

cd "${WORKDIR}/jj-demo"

# ベースとなるコミットを作成
cat > shared.py << 'PYEOF'
def process(data):
    result = data.strip()
    return result
PYEOF

jj describe -m "Add shared processing function"
jj new

# 変更Aを作成
cat > shared.py << 'PYEOF'
def process(data):
    result = data.strip().upper()
    return result
PYEOF

jj describe -m "Change A: convert to uppercase"

# ベースに戻って変更Bを作成
jj new @--
cat > shared.py << 'PYEOF'
def process(data):
    result = data.strip().lower()
    return result
PYEOF

jj describe -m "Change B: convert to lowercase"
jj new

echo "--- コンフリクト前のjj log ---"
jj log
echo ""

# AとBをマージ（コンフリクトが発生するが操作は成功する）
echo "--- AとBのマージを試みる ---"

# 両方の変更の上に新しいコミットを作成してマージ
jj new "description('Change A')" "description('Change B')" -m "Merge A and B"

echo ""
echo "--- マージ後のjj status ---"
jj status
echo ""

echo "--- マージ後のjj log（コンフリクトマーカーに注目）---"
jj log
echo ""

echo "-> Gitではマージコンフリクトが発生すると操作が中断される"
echo "   jjではコンフリクトがコミットに記録され、操作は成功する"
echo "   コンフリクトは後から解決できる"
echo ""

# コンフリクトの内容を確認
echo "--- コンフリクトの内容 ---"
cat shared.py 2>/dev/null || echo "(コンフリクトマーカーを含むファイル)"
echo ""

echo "-> コンフリクトは「エラー」ではなく「まだ解決されていない状態」"
echo "   解決結果は子孫コミットに自動伝播する"
```

### 演習で見えたこと

五つの演習を通じて、Jujutsuが提供するGitとは異なるバージョン管理体験を確認した。

演習1では、JujutsuがGitリポジトリをバックエンドとして使用することを確認した。.gitディレクトリが存在し、gitコマンドでも操作可能だ。Git互換性が「バックエンドの共有」という形で実現されている。

演習2では、ステージングエリアが存在しないワークフローを体験した。ファイルの変更は自動的にスナップショットされ、jj describeでメッセージを設定し、jj newで次の変更に進む。git add + git commitの二段階が不要になる。

演習3では、オペレーションログの威力を確認した。すべての操作が記録され、jj undoで安全に取り消せる。Gitのreflogに近いが、より体系的であり、操作の粒度が細かい。

演習4では、JujutsuとGitの相互運用を確認した。jj git exportでブックマークをGitブランチに反映し、既存のGitツールチェーンとの連携が可能だ。

演習5では、コンフリクトのファーストクラスサポートを体験した。Gitではマージコンフリクトが操作を中断するが、Jujutsuではコンフリクトがコミットに記録され、操作は成功する。コンフリクトは後から解決でき、解決結果は子孫コミットに自動伝播する。

Jujutsuは「Gitの良い部分を残し、悪い部分を再設計する」というアプローチを採っている。ステージングエリアの廃止、オペレーションログ、コンフリクトのファーストクラスサポート——いずれもGitの設計上の問題点に対する具体的な回答だ。一方で、Gitのストレージ層に依存する以上、スケーリングの根本的な問題は解決されない。

あなたがGitに感じている不満は、何だろうか。そして、その不満はJujutsuのアプローチで解消されるだろうか。

---

## 7. まとめと次回予告

### この回の要点

第一に、Gitは設計上のスケーリングの壁を抱えている。「全履歴をローカルに保持する」という分散型の前提が、大規模リポジトリではボトルネックになる。Microsoftは300GBのWindowsリポジトリのためにGVFS/Scalarを開発し、Googleはgitでは対応不可能なスケールのために独自のPiperを構築し、MetaはGitからMercurial、そしてSaplingへと移行した。partial clone、sparse checkout、shallow cloneは後付けの対策であり、設計の根幹に手を入れるものではない。

第二に、GitのUXには構造的な非一貫性がある。コマンド構文の恣意性、コマンドのオーバーロード、用語の不統一は、2013年のPerez De Rossoらの研究で体系的に分析された。Git 2.23でswitchとrestoreが導入されたが、21年間の機能追加で蓄積された設計上の負債は大きい。

第三に、パッチ理論は「スナップショット」とは根本的に異なるマージモデルを提供する。David Roundyが2002年に着想し、Darcsで実装したパッチ理論は、Pierre-Etienne MeunierとFlorent BeckerによるPijulで圏論に基づく厳密な定式化を得た。マージをpushoutとして定義することで、Darcsの指数的マージ問題を解消した。

第四に、次世代VCSはそれぞれ異なるアプローチでGitの限界に挑んでいる。JujutsuはGitバックエンドを使いUXを刷新する。SaplingはMononoke/EdenFSでスケーラビリティを実現する。PijulはGit互換性を持たず、パッチ理論で理論的正しさを追求する。三者に共通するのはステージングエリアの廃止であり、共通の分岐点はGit互換性の扱いだ。

第五に、Git互換性と革新の間にはジレンマがある。既存のGitエコシステム（GitHub、GitLab、CI/CD）との互換性は普及の鍵だが、同時にGitの設計制約を引き継ぐことを意味する。Git 3.0はSHA-256デフォルト化やRust導入を計画しているが、20年間の技術的負債の解消には限界がある。

### 冒頭の問いへの暫定回答

gitを超えるバージョン管理は、何を解決すべきなのか。

この問いに対する暫定的な答えは、「Gitが解いた問題はそのまま解きつつ、Gitが解かなかった——あるいは、解いた結果として新たに生じた——問題を解く」ことだ。

Gitが解いた問題——分散開発の高速なブランチ・マージ、データの完全性、非線形開発のサポート——は、次世代VCSも解かなければならない。これらを放棄することは、退化だ。

Gitが解かなかった問題——大規模リポジトリのスケーリング、UXの一貫性、ステージングモデルの複雑さ、AIが介在する開発のトレーサビリティ——が、次世代VCSの「要求仕様」となる。

そして、Gitが解いた結果として新たに生じた問題——GitHubを中心とするエコシステムへの依存、Git互換性の呪縛、20年間の技術的負債——もまた、次世代VCSが向き合わなければならない現実だ。

Jujutsu、Sapling、Pijulの三者は、それぞれ異なる角度からこの「要求仕様」に応えようとしている。どれが正解かは、まだわからない。歴史が教えてくれるのは、「最も優れた技術」ではなく「最も適切なタイミングで適切な問題を解いた技術」が普及するということだ。CVSがRCSの限界に応えたように、GitがBitKeeper問題に応えたように。

### 次回予告

**第23回「バージョン管理の本質に立ち返る——変更・協調・歴史」**

次回は、連載の終盤にふさわしく、バージョン管理の本質に立ち返る。SCCS（1972年）からGit（2005年）、そして2026年の次世代VCSまで、50年以上の歴史を俯瞰し、バージョン管理の三つの本質——変更の記録（What changed?）、協調の仕組み（Who changed it, and how do we integrate?）、歴史の保存（Why did it change?）——で各VCSを再評価する。

ツールは変わっても、本質は変わらない。では、その「本質」とは具体的に何なのか。あなたの開発ワークフローを「三つの本質」で振り返ったとき、何が見えてくるだろうか。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Potvin, R., Levenberg, J. "Why Google Stores Billions of Lines of Code in a Single Repository." Communications of the ACM, Vol. 59 No. 7, 2016. <https://cacm.acm.org/research/why-google-stores-billions-of-lines-of-code-in-a-single-repository/>
- Harry, B. "The largest Git repo on the planet." Microsoft DevOps Blog, 2017. <https://devblogs.microsoft.com/bharry/the-largest-git-repo-on-the-planet/>
- Meta Engineering Blog. "Scaling Mercurial at Facebook." 2014. <https://engineering.fb.com/2014/01/07/core-infra/scaling-mercurial-at-facebook/>
- Meta Engineering Blog. "Sapling: Source control that's user-friendly and scalable." 2022-11-15. <https://engineering.fb.com/2022/11/15/open-source/sapling-source-control-scalable/>
- Perez De Rosso, S., Jackson, D. "What's Wrong with Git? A Conceptual Design Analysis." Onward! 2013, ACM SIGPLAN. <https://spderosso.github.io/onward13.pdf>
- Mimram, S., di Giusto, C. "A Categorical Theory of Patches." Electronic Notes in Theoretical Computer Science, 2013. <https://ar5iv.labs.arxiv.org/html/1311.3903>
- Wikipedia. "Darcs." <https://en.wikipedia.org/wiki/Darcs>
- Pijul公式サイト. <https://pijul.org/>
- Jujutsu GitHub. <https://github.com/jj-vcs/jj>
- Sapling公式サイト. <https://sapling-scm.com/>
- DeployHQ. "Git 3.0 on the Horizon." <https://www.deployhq.com/blog/git-3-0-on-the-horizon-what-git-users-need-to-know-about-the-next-major-release>
- Help Net Security. "Git 2.51: Preparing for the future with SHA-256." 2025-08-19. <https://www.helpnetsecurity.com/2025/08/19/git-2-51-sha-256/>
