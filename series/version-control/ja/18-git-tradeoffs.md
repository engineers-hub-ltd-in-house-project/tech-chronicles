# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第18回：分散の代償——Gitのトレードオフ

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Gitの内容アドレス可能ストレージが、なぜ大きなバイナリファイルの管理を本質的に苦手とするのか
- Git LFS（Large File Storage）の設計——ポインタファイルとsmudge/cleanフィルタによる妥協のアーキテクチャ
- shallow clone、partial clone、sparse-checkoutが、Gitの「全履歴ローカル保持」という前提をどう緩和しているか
- MicrosoftがWindows開発のGit移行で直面した問題と、VFS for Git / Scalarによる解決策
- Gitの分散型設計がパスベースアクセス制御を原理的に不可能にしていること
- モノレポとマルチレポの判断が、Gitのトレードオフと直結している構造
- Google、Meta、Microsoftが「Gitだけでは足りない」と判断した理由

---

## 1. 300GBのリポジトリを前にして

2017年のある日、私は技術ニュースの見出しに目を疑った。「Microsoft、Windowsの開発をGitに移行」——。Windowsのソースコードは約350万ファイル、約300GBの規模だと報じられていた。

当時の私は、それなりの規模のGitリポジトリを扱った経験があった。数GBのリポジトリで`git status`の応答が遅くなり、`git clone`が何十分もかかることに苛立っていた。300GBのリポジトリなど、想像の外だった。記事を読み進めると、Microsoftが「Git Virtual File System（GVFS）」なる仮想ファイルシステムを開発したとあった。通常のGitでは、クローンに12時間以上、チェックアウトに2-3時間、`git status`に10分かかっていたものを、GVFSによりクローン数分、チェックアウト30秒、`git status` 4-5秒に短縮したという。

私は考えた。Gitは分散型バージョン管理の頂点に立つツールだ。だが、その「分散」の設計思想そのものが、大規模リポジトリという現実の前で軋みを上げている。全ての履歴をローカルに保持するという分散型の根本原理が、リポジトリの巨大化によって負債に転じる。そしてMicrosoftは、その負債を解消するために、Gitそのものに手を入れざるを得なかった。

同じ頃、私自身もプロジェクトでモノレポとマルチレポの選択を迫られていた。IaC（Infrastructure as Code）の資材、アプリケーションコード、ドキュメント、設定ファイル——これらを一つのリポジトリに集約するか、分割するか。モノレポの利便性は理解していた。だがGitで実現しようとすると、リポジトリの肥大化、CI/CDパイプラインの複雑化、アクセス制御の粗さという壁にぶつかった。Subversion時代にはパスベースのアクセス制御が当然のように使えた。Gitにはそれがない。

前回まで（第15回〜第17回）、私たちはGitの内部構造を解剖してきた。オブジェクトモデル、ブランチのポインタ実装、マージアルゴリズム。Gitの設計は精緻であり、その内部を知ることで多くの挙動が「予測可能」になった。しかし、精緻な設計にはトレードオフがある。Gitは何を得て、何を犠牲にしたのか。

**Gitは何を犠牲にして、何を得たのか。** 今回は、その問いに向き合う。

---

## 2. 内容アドレス可能ストレージの代償

### なぜGitは大きなファイルが苦手なのか

第15回で解説したとおり、Gitのオブジェクトモデルは内容アドレス可能ストレージ（Content-Addressable Storage）に基づいている。ファイルの内容からSHA-1ハッシュを計算し、そのハッシュをキーとしてオブジェクトストア（`.git/objects/`）に格納する。同一内容のファイルは同一のハッシュを持つため、自然に重複排除が行われる。この設計は、テキストファイル中心のソフトウェア開発において極めて効率的だ。

だが、この設計には本質的な制約がある。

Gitは概念的に「全体オブジェクト」（whole object）のストアだ。ファイルの内容が1バイトでも変われば、新しいblobオブジェクトが生成される。10MBのバイナリファイルを100回変更すれば、100個のblobオブジェクト——合計約1GBのデータ——がオブジェクトストアに蓄積される。

「packファイルでデルタ圧縮されるのではないか」と思うかもしれない。確かに、Gitはpackファイルの生成時（`git gc`、`git repack`、あるいは自動的なauto-packing）にオブジェクト間のデルタ圧縮を行う。しかし、デルタ圧縮はあくまで事後的な最適化であり、Gitの設計の本質ではない。そして決定的なのは、バイナリファイルのデルタ圧縮は効率が悪いということだ。

テキストファイルの場合、行単位の差分が明瞭で、デルタ圧縮は極めて効果的に機能する。1,000行のソースファイルで10行を変更した場合、デルタは10行分の差分だけを記録すればよい。しかし、バイナリファイル——PSD、MP4、3Dモデル、機械学習の重みファイルなど——は内部構造がテキストとは根本的に異なる。小さな変更でもバイナリ表現は大きく変わることがあり、デルタ圧縮の効果は限定的だ。

```
テキストファイルとバイナリファイルのデルタ圧縮効率:

  テキストファイル（source.py, 50KB）:
  ├── バージョン1 → バージョン2: 10行変更
  ├── デルタサイズ: 約500バイト（元ファイルの1%）
  └── 100バージョンの合計: 約50KB + 50KB = 約100KB

  バイナリファイル（model.psd, 50MB）:
  ├── バージョン1 → バージョン2: レイヤー1枚追加
  ├── デルタサイズ: 約10MB〜30MB（元ファイルの20%〜60%）
  └── 100バージョンの合計: 約50MB + 1GB〜3GB = 1〜3GB超

  → 同じ「1つの変更」でも、バイナリは桁違いにストレージを消費する
```

さらに問題は、Gitの分散型設計と組み合わさったときに深刻化する。`git clone`はデフォルトで全てのオブジェクトをダウンロードする。つまり、巨大バイナリの全バージョンがローカルにコピーされる。1GBのバイナリファイルが100バージョンあれば、クローンするだけで数十GBのデータ転送が発生する。そしてそのバイナリファイルを二度と開かないとしても、ローカルのオブジェクトストアに永続的に保持される。

これがGitの内容アドレス可能ストレージの本質的なトレードオフだ。ハッシュによる完全性保証と重複排除を得る代わりに、バイナリの差分管理能力を犠牲にしている。集中型VCSであるSubversionは、サーバ側でファイルの差分を管理し、クライアントには必要なリビジョンだけを送信できた。Gitにはその「サーバが差分を管理する」というアーキテクチャが原理的に存在しない。

### packファイルの限界

Gitのpackファイル形式は、オブジェクトの格納効率を改善する精巧な仕組みだ。`git gc`が実行されると、loose objectsがpackファイルにまとめられ、類似オブジェクト間のデルタ圧縮が適用される。packファイルは、git-pack-objectsのヒューリスティクスに基づいてデルタチェーンを構築する。ファイル名とサイズが類似するオブジェクトを候補とし、最も効率的なデルタを選択する。

だが、このヒューリスティクスには限界がある。デルタ圧縮のウィンドウサイズ（デフォルト10）は、比較対象となるオブジェクトの数を制限する。巨大なバイナリオブジェクトはデルタ圧縮の候補検索自体に時間がかかり、CPUとメモリを大量に消費する。`git gc`の実行時間が数時間に及ぶことすらある。

結局のところ、packファイルのデルタ圧縮は「テキスト中心のリポジトリ」を前提とした最適化であり、大量のバイナリファイルを含むリポジトリに対しては限定的な効果しか発揮できない。

---

## 3. Git LFS——妥協のアーキテクチャ

### ポインタファイルという発明

2015年4月、Git Merge 2015カンファレンスで、GitHub開発者のRick OlsonがGit LFS（Large File Storage）を発表した。GitHubはクライアントとサーバのリファレンス実装をオープンソースとして公開し、Atlassianをはじめとする複数の企業が開発に参画した。

Git LFSの設計思想は、「Gitのオブジェクトストアにバイナリファイルを入れない」というものだ。代わりに、Gitのリポジトリにはポインタファイル——約130バイトの小さなテキストファイル——を格納し、実体はGit LFSサーバに保存する。

ポインタファイルの中身は以下の形式だ。

```
version https://git-lfs.github.com/spec/v1
oid sha256:4d7a214614ab2935c943f9e0ff69d22eadbb8f32b1258daaa5e2ca24d17e2393
size 12345678
```

3つのフィールドで構成される。`version`はLFS仕様のバージョン、`oid`は実体ファイルのSHA-256ハッシュ、`size`はファイルサイズだ。このポインタファイルがGitのblobオブジェクトとしてオブジェクトストアに格納される。130バイトであれば、100バージョンあっても合計13KBにすぎない。

### smudge/cleanフィルタの仕組み

Git LFSは、Gitの**smudge/cleanフィルタ**機構を利用して透過的に動作する。この機構はGitのフィルタドライバとして実装されており、`git lfs install`を実行すると、グローバルのgitconfigにフィルタ設定が追加される。

```
Git LFSのsmudge/cleanフィルタ:

  ステージング時（git add）:
  ┌──────────┐    cleanフィルタ    ┌──────────────┐
  │ 実体ファイル │ ──────────────→ │ ポインタファイル │
  │ (50MB PSD) │                  │  (130バイト)   │
  └──────────┘                    └──────────────┘
       │                                │
       ↓                                ↓
  .git/lfs/objects/            .git/objects/（通常のblob）
  （ローカルLFSストア）

  チェックアウト時（git checkout）:
  ┌──────────────┐   smudgeフィルタ   ┌──────────┐
  │ ポインタファイル │ ──────────────→ │ 実体ファイル │
  │  (130バイト)   │                  │ (50MB PSD) │
  └──────────────┘                    └──────────┘
       ↑                                    ↑
  .git/objects/                   ローカルLFSストア
  （ポインタblob）               or リモートLFSサーバ
```

cleanフィルタは、`git add`時に実体のバイナリをローカルLFSストア（`.git/lfs/objects/`）に保存し、ポインタファイルをGitのステージングエリアに渡す。smudgeフィルタは、`git checkout`時にポインタファイルの先頭100バイトを読んでLFSポインタかどうかを判定し、LFSポインタであればOIDに基づいてローカルLFSストアからファイルを取得する。ローカルにない場合は、リモートのLFSサーバからHTTP APIでダウンロードする。

この設計により、`git clone`でダウンロードされるのはポインタファイルだけになる。巨大なバイナリの実体は、実際にそのファイルをチェックアウトするまでダウンロードされない。

### Git LFSの妥協と限界

Git LFSは巧みな解決策だが、Gitの設計上の制約から生まれた「妥協」でもある。

第一の妥協は、**LFSサーバへの依存**だ。LFSの実体ファイルはリモートサーバに保存される。サーバがダウンしていればファイルを取得できない。これは、Gitの「全ての履歴をローカルに保持し、オフラインでも完全に動作する」という分散型の根本理念と矛盾する。Git LFSを使った時点で、そのリポジトリは事実上、集中型の要素を持つことになる。

第二の妥協は、**既存のGitワークフローとの摩擦**だ。LFS追跡対象のファイルパターンは`.gitattributes`で明示的に設定する必要がある。設定を忘れたバイナリファイルは通常のGitオブジェクトとして格納され、後から移行するには`git lfs migrate`でリポジトリの履歴を書き換える必要がある。

第三の妥協は、**`git diff`やgit bisectとの不整合**だ。LFS管理下のバイナリファイルに対して`git diff`を実行すると、ポインタファイルの差分が表示される。バイナリの中身の差分ではない。カスタムdiffドライバを設定すれば改善できるが、標準のワークフローからは外れる。

第四の妥協は、**ストレージコストの移転**だ。Gitリポジトリのサイズは縮小するが、LFSサーバ上のストレージ使用量は増加する。GitHub、GitLab、Bitbucketのいずれも、LFSストレージには容量制限と追加課金が存在する。無料枠は1-5GB程度であり、大規模プロジェクトでは無視できないコストになる。

これらの妥協は、Git LFSが「Gitの設計を変えずに、その上に後付けで載せた」解決策であることを示している。本質的には、Gitのオブジェクトモデルにバイナリファイルを格納するのではなく、外部のストレージに逃がす——という設計だ。それ自体は合理的だが、Gitの分散型という設計の強みを部分的に手放していることは自覚すべきだ。

---

## 4. 巨大リポジトリの壁——shallow clone、partial clone、sparse-checkout

### 全履歴ローカル保持の呪い

Gitの分散型設計の核心は、全ての履歴をローカルに保持することだ。これにより、オフラインでのコミット、ログ閲覧、ブランチ操作が可能になる。だが、リポジトリが巨大化すると、この「全履歴ローカル保持」がボトルネックになる。

Microsoftの例を再び引こう。2017年5月、MicrosoftはWindowsの開発をGitに移行したと発表した。約4,000人のエンジニアのうち約3,500人がGitに移行し、約350万ファイル、約300GBのリポジトリを扱うことになった。標準のGitでは、クローンに12時間以上、チェックアウトに2-3時間、`git status`に10分を要していた。

Microsoftだけではない。Googleは2015年時点で86TB、20億行のコードを単一リポジトリ（Piper）で管理しているが、Gitは使用していない。Piperは社内で開発された、Perforceを再実装したシステムだ。Metaは2022年にSaplingをオープンソースとして公開した。Mercurialの拡張として始まり、独自のストレージフォーマットとワイヤプロトコルを持つシステムに発展したものだ。数千万のファイルとコミットを扱う。

Google、Meta、Microsoft——いずれも「Gitの標準機能だけでは足りない」と判断し、独自のソリューションを開発している。この事実は、Gitのスケーラビリティに構造的な限界があることを示している。

ただし、Gitも手をこまねいていたわけではない。巨大リポジトリへの対応として、3つの主要な機能が段階的に導入されてきた。

### shallow clone——履歴の切り捨て

shallow cloneは最もシンプルな対策だ。`git clone --depth N`で、直近N件のコミット履歴だけをダウンロードする。

```bash
# 直近1コミットだけをクローン
git clone --depth 1 https://github.com/large/repo.git

# 直近10コミットをクローン
git clone --depth 10 https://github.com/large/repo.git
```

shallow cloneは、CI/CDパイプラインで広く使われている。ビルドやテストの実行には最新のソースコードがあればよく、全履歴は不要な場合が多い。大規模リポジトリでは、クローン時間を最大10倍短縮できるという報告がある。

だが、shallow cloneにはトレードオフがある。全履歴がないため、`git log`で過去のコミットを遡れない。`git bisect`でバグの混入コミットを特定する二分探索も、shallow clone内の範囲に制限される。`git blame`も不完全な結果を返す。後から`git fetch --unshallow`で完全な履歴を取得することは可能だが、その時点で全オブジェクトをダウンロードすることになる。

shallow cloneは「今のコードが動けばよい」ケースには適しているが、「なぜこうなったか」を追跡する用途には不向きだ。

### partial clone——オブジェクトの遅延取得

Git 2.19前後（2018年）で段階的に導入されたpartial cloneは、shallow cloneよりも洗練されたアプローチだ。コミットの履歴グラフは完全にダウンロードしつつ、blobオブジェクト（ファイルの実体）のダウンロードを遅延させる。

```bash
# blobをダウンロードしない（コミットとツリーのみ）
git clone --filter=blob:none https://github.com/large/repo.git

# 指定サイズ以上のblobをダウンロードしない
git clone --filter=blob:limit=1m https://github.com/large/repo.git
```

`--filter=blob:none`を指定すると、クローン時にblobオブジェクトは一切ダウンロードされない。ファイルの内容が必要になったとき——`git checkout`、`git diff`、ファイルを開くとき——に、リモートサーバからオンデマンドで取得する。GitLab の報告によれば、partial cloneにより平均88.6%のクローン時間削減が達成され、最大のリポジトリでは99%以上の削減を達成した。

partial cloneはshallow cloneと異なり、コミットの履歴グラフは完全に保持される。`git log`、`git bisect`、`git blame`は正常に動作する（ただし、blobが必要な操作ではネットワークアクセスが発生する）。

partial cloneの意味を考えよう。Gitの根本原理は「全てのオブジェクトをローカルに保持する」ことだった。partial cloneはその原理を緩和し、「メタデータ（コミット、ツリー）はローカルに保持するが、データ（blob）は必要に応じて取得する」モデルに移行する。これは実質的に、集中型VCSの「サーバにデータがあり、必要な部分をチェックアウトする」というモデルに近づいている。

```
各クローン方式の比較:

  通常のclone:
  ├── ダウンロード: 全コミット + 全ツリー + 全blob
  ├── ローカル保持: 全履歴の完全なコピー
  ├── オフライン操作: 全て可能
  └── 用途: 開発者の日常作業

  shallow clone (--depth N):
  ├── ダウンロード: 直近Nコミット + そのツリー + そのblob
  ├── ローカル保持: 部分的な履歴
  ├── オフライン操作: 直近N件の範囲のみ
  └── 用途: CI/CD、一時的なビルド

  partial clone (--filter=blob:none):
  ├── ダウンロード: 全コミット + 全ツリー（blobなし）
  ├── ローカル保持: 履歴グラフは完全、blobは遅延取得
  ├── オフライン操作: log/bisectは可能、ファイル内容はネットワーク必要
  └── 用途: 大規模リポジトリの日常開発

  sparse-checkout:
  ├── ダウンロード: （clone方式に依存）
  ├── 作業ディレクトリ: 指定ディレクトリのみ展開
  ├── オフライン操作: （clone方式に依存）
  └── 用途: モノレポの部分的な作業
```

### sparse-checkout——作業ディレクトリの絞り込み

sparse-checkoutは、クローンの範囲ではなく、作業ディレクトリに展開するファイルの範囲を絞り込む機能だ。Git 2.25（2020年1月）でcone modeが導入され、実用性が大幅に向上した。

```bash
# sparse-checkoutを有効化（cone modeがデフォルト）
git sparse-checkout init

# 特定のディレクトリだけを作業ディレクトリに展開
git sparse-checkout set src/frontend docs/api

# 確認
git sparse-checkout list
```

cone modeの「cone」（円錐）は、リポジトリのツリー構造を上から見たときに、指定したディレクトリとその親ディレクトリが円錐形に展開される様子を表している。cone modeはディレクトリ単位の指定に限定される代わりに、ハッシュベースのアルゴリズムで高速なパターンマッチングを実現する。

sparse-checkoutはpartial cloneと組み合わせると特に効果的だ。

```bash
# partial clone + sparse-checkout
git clone --filter=blob:none --sparse https://github.com/large/monorepo.git
cd monorepo
git sparse-checkout set src/my-service
```

この組み合わせにより、「コミット履歴は完全に保持しつつ、作業に必要なディレクトリのファイルだけをダウンロード・展開する」という挙動が実現する。Subversionの部分チェックアウト（`svn checkout --depth`）に近い体験をGitで得られる。

### MicrosoftのVFS for GitからScalarへ

Microsoftは、上記の標準機能では不十分と判断し、より根本的な解決策を開発した。

2017年2月に発表されたGVFS（Git Virtual File System、後にVFS for Gitに改名）は、ファイルシステムレベルでGitの動作を仮想化する。作業ディレクトリにはファイルが存在するように見えるが、実際にはファイルを開くまでダウンロードされない。オペレーティングシステムのファイルシステムドライバにフックし、ファイルアクセスをインターセプトしてオンデマンドでオブジェクトを取得する。

VFS for Gitは劇的な効果を示したが、ファイルシステムドライバへの依存というアーキテクチャ上の制約があった。Windows以外のOSではmacOSのみ対応（しかも限定的）で、Linuxには非対応だった。

MicrosoftはVFS for Gitの運用経験と、Gitの新機能（partial clone、sparse-checkout、FSMonitor等）の成熟を踏まえ、2020年2月にScalarを発表した。Scalarは仮想ファイルシステムを使わず、Gitの既存機能を最適な設定で組み合わせるツールだ。partial clone、background prefetch（1時間ごとのバックグラウンドフェッチ）、sparse-checkout、FSMonitor（ファイルシステム変更の監視）、commit-graph、multi-pack-index——これらの機能を自動的に有効化し、大規模リポジトリでの性能を最適化する。

ScalarはGit 2.38（2022年10月）でGit本体に統合された。VFS for Gitは2.32をもってメンテナンスモードに入り、新規導入にはScalarが推奨されている。

この経緯は示唆的だ。Gitの本体が徐々に大規模リポジトリへの対応を進め、かつてはGitの外部に構築する必要があった機能が、標準の一部になりつつある。だが、Google（Piper）やMeta（Sapling）のような超大規模環境には、依然としてGitの標準機能では対応できない領域が残っている。

---

## 5. 分散型の影——パスベースアクセス制御の不在

### Subversionが持ち、Gitが持たないもの

Gitのトレードオフを語るとき、避けて通れないのがアクセス制御の問題だ。

Subversionは、svnserveまたはApache httpd + mod_dav_svnの構成で、ファイルパスに基づく細粒度のアクセス制御を実現していた。`authz`設定ファイルで、ディレクトリごと、さらにはファイルごとに、ユーザーやグループの読み書き権限を設定できた。

```
# Subversionのauthz設定例
[/]
* = r                    # 全ユーザーがルートを読める

[/secret/project-x]
* =                      # デフォルトはアクセス不可
@core-team = rw          # core-teamグループのみ読み書き可

[/docs]
* = r                    # 全ユーザーが読める
@writers = rw            # writersグループは書き込み可
```

この「パスベースアクセス制御」は、企業のソフトウェア開発で極めて重要な機能だった。一つのリポジトリの中に、全社公開のコード、特定チームのみアクセス可能なコード、機密性の高い設定ファイルを混在させることができた。

Gitにはこの機能がない。そして、原理的に実装できない。

理由は明確だ。Gitは分散型であり、`git clone`はリポジトリの全オブジェクトをコピーする。パスベースの「読み取り制限」を実現するには、サーバが特定のオブジェクトの転送を拒否する必要がある。だが、Gitのオブジェクトモデルでは、treeオブジェクトがblobオブジェクトを参照し、commitオブジェクトがtreeオブジェクトを参照する。特定のblobを除外すると、そのblobを参照するtreeのハッシュが変わり、連鎖的にcommitのハッシュも変わる。内容アドレス可能ストレージの根幹が崩れる。

GitHub、GitLab、Bitbucket等のホスティングサービスは、ブランチ保護ルールで「書き込み」を制限する機能を提供している。だが「読み取り」の制限はリポジトリ単位だ。リポジトリにアクセスできるユーザーは、そのリポジトリの全てのファイルと全ての履歴を読める。

```
アクセス制御のアーキテクチャ比較:

  Subversion（集中型）:
  ┌─────────────────────┐
  │   SVNサーバ         │
  │  ┌──────────┐       │
  │  │ authz設定 │       │
  │  └──────────┘       │
  │  /public/  → 全員読める │
  │  /secret/  → 特定チームのみ │
  │  /config/  → 管理者のみ   │
  └─────────────────────┘
        ↓ (認可されたパスのみ)
  クライアントは許可された範囲だけ取得

  Git（分散型）:
  ┌─────────────────────┐
  │   リモートリポジトリ    │
  │  全オブジェクトが一体    │
  │  パス単位の分離不可     │
  └─────────────────────┘
        ↓ (全てまたは無し)
  クライアントは全オブジェクトを取得

  → Gitでのワークアラウンド:
    リポジトリを分割し、git submoduleで統合
    → リポジトリ単位でアクセス制御を適用
```

ワークアラウンドとして最もよく使われるのは、リポジトリの分割だ。機密コードを別リポジトリに分離し、`git submodule`や`git subtree`で統合する。だが、これはモノレポの利点——横断的なリファクタリングの容易さ、依存関係の一元管理、コード検索の統一性——を犠牲にする。

この問題は、Gitのトレードオフの中でも特に企業環境で顕在化する。私は実際に、「Subversionのパスベースアクセス制御がないとセキュリティ要件を満たせない」という理由で、2020年代に入ってもSubversionを使い続けているプロジェクトに遭遇したことがある（第11回で触れた「Subversionが今なお現役の理由」の一つだ）。

---

## 6. モノレポとマルチレポ——Gitのトレードオフが突きつける選択

### 二つの世界

ここまで見てきたGitのトレードオフ——大きなファイルの非効率、巨大リポジトリの性能問題、パスベースアクセス制御の不在——は、一つの実務的な問いに集約される。**モノレポ（monorepo）とマルチレポ（multirepo）のどちらを選ぶか。**

モノレポとは、組織の全て（または大部分）のコードを単一のリポジトリで管理する手法だ。Google、Meta、Microsoftが採用している。一方、マルチレポは、プロジェクトやサービスごとにリポジトリを分割する手法だ。

モノレポの利点は明確だ。横断的なリファクタリングが一つのコミットで完結する。依存関係の管理が一元化され、バージョンの不整合が生じにくい。コード検索が全社規模で統一され、チーム間のコード共有と知識共有が自然に行われる。新メンバーのオンボーディングも一つのリポジトリだけで済む。

マルチレポの利点もまた明確だ。各リポジトリが独立してバージョニングとリリースを管理できる。チームの自律性が高く、独自のワークフローやツールチェーンを選択できる。アクセス制御がリポジトリ単位で自然に分離される。CIパイプラインは各リポジトリに閉じ、変更の影響範囲が限定される。

問題は、Gitのアーキテクチャがモノレポに対して構造的な弱点を持つことだ。

### Gitとモノレポの構造的摩擦

Gitでモノレポを運用すると、以下の摩擦が生じる。

第一に、リポジトリの肥大化。コードが増えるにつれ、`git clone`、`git fetch`、`git status`の実行時間が増大する。partial cloneとsparse-checkoutで緩和できるが、完全には解消されない。

第二に、CIパイプラインの複雑化。モノレポの一部が変更されたとき、その変更に影響される部分だけをビルド・テストしたい。だがGitは「何が変わったか」は教えてくれるが、「何が影響を受けるか」は教えてくれない。影響分析はビルドシステム（Bazel、Nx、Turborepo等）の仕事だ。Gitのコミット粒度とビルドの粒度は一致しない。

第三に、先述のアクセス制御の問題。モノレポ内の特定ディレクトリへのアクセスを制限できないため、機密コードの管理が困難になる。

第四に、ブランチ戦略の全社統一。モノレポでは全チームが同一のブランチ戦略に従う必要がある。チームAはGitHub Flowを好み、チームBはトランクベース開発を好むとしても、同一リポジトリでは統一せざるを得ない。

Google、Meta、Microsoftがそれぞれ独自のソリューション（Piper、Sapling、VFS for Git / Scalar）を開発したのは、Gitの標準機能だけではこれらの摩擦を許容できなかったからだ。逆に言えば、これらの独自ソリューションを開発・運用するリソースを持たない組織は、Gitのトレードオフをそのまま受け入れるか、マルチレポを選択する必要がある。

### 判断の基準

私の経験では、以下の基準が判断の助けになる。

モノレポが適している条件は、チーム間のコード共有が頻繁であること、横断的なリファクタリングが定期的に必要であること、依存関係の一元管理が重要であること、そしてリポジトリの規模がGitの標準機能（sparse-checkout + partial clone）で扱える範囲に収まることだ。

マルチレポが適している条件は、チームの自律性が優先されること、各サービスの独立したリリースサイクルが重要であること、パスベースのアクセス制御が必要であること、そしてリポジトリの規模が巨大であること（特にバイナリアセットを含む場合）だ。

だが、ここで安易に「正解」を示すことは避けたい。モノレポとマルチレポの選択は、技術的なトレードオフだけでなく、組織構造、チーム文化、セキュリティ要件、インフラリソースなど、多くの要素が絡む。重要なのは、Gitのトレードオフを理解した上で選択することだ。「Gitでモノレポをやっているが、なぜか遅い」と嘆く前に、Gitのアーキテクチャが大規模モノレポに対してどのような構造的制約を持つかを知っておくべきだ。

---

## 7. ハンズオン：Gitのトレードオフを体感する

Gitの弱点を言葉で理解するだけでなく、実際に手を動かして体感する。Git LFSの設定と動作、shallow cloneの効果測定、sparse-checkoutの操作を体験する。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y git git-lfs curl time
```

### 演習1：バイナリファイルがGitリポジトリを肥大化させる様子を観察する

```bash
WORKDIR="${HOME}/vcs-handson-18"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=== 演習1: バイナリファイルによるリポジトリ肥大化 ==="
echo ""

# gitの設定
git config --global user.email "handson@example.com"
git config --global user.name "Handson User"
git config --global init.defaultBranch main

# リポジトリの初期化
git init --quiet binary-demo
cd binary-demo

# テキストファイルを作成して10回変更
echo "--- テキストファイル（10KB）を10回変更 ---"
python3 -c "print('line ' * 100, end='')" > textfile.txt
git add textfile.txt
git commit --quiet -m "Text v1"

for i in $(seq 2 10); do
  python3 -c "print('line-v${i} ' * 100, end='')" > textfile.txt
  git add textfile.txt
  git commit --quiet -m "Text v${i}"
done

# バイナリファイル（疑似）を作成して10回変更
echo "--- バイナリファイル（1MB）を10回変更 ---"
dd if=/dev/urandom of=binary.dat bs=1024 count=1024 2>/dev/null
git add binary.dat
git commit --quiet -m "Binary v1"

for i in $(seq 2 10); do
  dd if=/dev/urandom of=binary.dat bs=1024 count=1024 2>/dev/null
  git add binary.dat
  git commit --quiet -m "Binary v${i}"
done

# gc実行前のサイズ
echo ""
echo "--- gc実行前のリポジトリサイズ ---"
du -sh .git/
git count-objects -v

# gc実行
git gc --quiet

echo ""
echo "--- gc実行後のリポジトリサイズ ---"
du -sh .git/
git count-objects -v

echo ""
echo "-> テキストファイルはデルタ圧縮で効率的に格納される"
echo "   バイナリファイルはデルタ圧縮の効果が低く、サイズが大きいまま"
echo "   これがGitで巨大バイナリを管理する問題の本質"
```

### 演習2：Git LFSの動作を確認する

```bash
echo ""
echo "=== 演習2: Git LFSの動作を確認する ==="
echo ""

cd "${WORKDIR}"
git init --quiet lfs-demo
cd lfs-demo
git config user.email "handson@example.com"
git config user.name "Handson User"

# Git LFSを初期化
git lfs install --local

echo "--- .gitattributesでLFS追跡パターンを設定 ---"
git lfs track "*.bin"
cat .gitattributes
echo ""

git add .gitattributes
git commit --quiet -m "Add LFS tracking"

# バイナリファイルを追加
dd if=/dev/urandom of=large-asset.bin bs=1024 count=512 2>/dev/null
git add large-asset.bin
git commit --quiet -m "Add large binary asset"

echo "--- Gitオブジェクトストアの内容（LFS管理下）---"
echo "ポインタファイルの内容:"
git show HEAD:large-asset.bin
echo ""

echo "--- ポインタファイルのサイズ ---"
git cat-file -s HEAD:large-asset.bin
echo "バイト（実体は512KBだが、Gitには約130バイトのポインタだけが格納される）"
echo ""

echo "--- ローカルLFSストアの内容 ---"
if [ -d ".git/lfs/objects" ]; then
  find .git/lfs/objects -type f | head -5
  echo ""
  du -sh .git/lfs/objects/
  echo "（実体ファイルはここに格納されている）"
else
  echo "（ローカルLFSストアは空、またはまだ作成されていない）"
fi

echo ""
echo "--- .gitオブジェクトストアのサイズ ---"
du -sh .git/objects/
echo "（ポインタファイルだけなので小さい）"
```

### 演習3：shallow cloneの効果を体験する

```bash
echo ""
echo "=== 演習3: shallow cloneの効果を体験する ==="
echo ""

cd "${WORKDIR}"

# テスト用のリポジトリを作成（多数のコミットを持つ）
git init --quiet --bare origin-repo.git
git clone --quiet origin-repo.git work-repo
cd work-repo
git config user.email "handson@example.com"
git config user.name "Handson User"

echo "--- 100コミットのリポジトリを作成 ---"
for i in $(seq 1 100); do
  echo "content version ${i}" > "file-${i}.txt"
  git add "file-${i}.txt"
  git commit --quiet -m "Commit ${i}: add file-${i}.txt"
done
git push --quiet origin main

cd "${WORKDIR}"

echo ""
echo "--- 通常のclone ---"
time git clone --quiet origin-repo.git full-clone 2>&1
echo "コミット数: $(cd full-clone && git rev-list --count HEAD)"
echo "サイズ: $(du -sh full-clone/.git/ | cut -f1)"
echo ""

echo "--- shallow clone (depth=1) ---"
time git clone --quiet --depth 1 origin-repo.git shallow-clone 2>&1
echo "コミット数: $(cd shallow-clone && git rev-list --count HEAD)"
echo "サイズ: $(du -sh shallow-clone/.git/ | cut -f1)"
echo ""

echo "--- shallow clone (depth=10) ---"
time git clone --quiet --depth 10 origin-repo.git shallow-clone-10 2>&1
echo "コミット数: $(cd shallow-clone-10 && git rev-list --count HEAD)"
echo "サイズ: $(du -sh shallow-clone-10/.git/ | cut -f1)"
echo ""

echo "-> 深さを制限するほど、サイズが小さくなる"
echo "   ただし、過去のコミットへのアクセスは制限される"
```

### 演習4：sparse-checkoutで作業ディレクトリを絞り込む

```bash
echo ""
echo "=== 演習4: sparse-checkoutで作業ディレクトリを絞り込む ==="
echo ""

cd "${WORKDIR}"

# モノレポ風のリポジトリを作成
git init --quiet --bare monorepo-origin.git
git clone --quiet monorepo-origin.git monorepo-work
cd monorepo-work
git config user.email "handson@example.com"
git config user.name "Handson User"

# ディレクトリ構造を作成
mkdir -p src/frontend src/backend src/shared docs/api docs/guide
echo "import React from 'react'" > src/frontend/app.tsx
echo "from flask import Flask" > src/backend/app.py
echo "export const VERSION = '1.0'" > src/shared/constants.ts
echo "# API Reference" > docs/api/README.md
echo "# User Guide" > docs/guide/README.md
echo "# Monorepo Root" > README.md

git add .
git commit --quiet -m "Initial monorepo structure"
git push --quiet origin main

cd "${WORKDIR}"

# sparse-checkoutでクローン
echo "--- sparse-checkoutでフロントエンドだけを展開 ---"
git clone --quiet --sparse monorepo-origin.git sparse-monorepo
cd sparse-monorepo

echo "クローン直後の作業ディレクトリ:"
find . -not -path './.git/*' -not -path './.git' | sort
echo ""

echo "--- sparse-checkout set で src/frontend と src/shared を指定 ---"
git sparse-checkout set src/frontend src/shared

echo "sparse-checkout後の作業ディレクトリ:"
find . -not -path './.git/*' -not -path './.git' | sort
echo ""

echo "--- sparse-checkout list ---"
git sparse-checkout list
echo ""

echo "-> src/frontend と src/shared だけが展開された"
echo "   src/backend と docs は作業ディレクトリに存在しない"
echo "   モノレポで自分の担当部分だけを扱える"

echo ""
echo "--- 全ファイルを復元する ---"
git sparse-checkout disable
echo "復元後:"
find . -not -path './.git/*' -not -path './.git' | sort
```

### 演習で見えたこと

四つの演習を通じて、Gitのトレードオフを実際に確認した。

演習1では、テキストファイルとバイナリファイルのデルタ圧縮効率の違いを確認した。テキストファイルはgc後に大幅に圧縮されるが、ランダムなバイナリファイルはほぼ圧縮されない。これがGitの内容アドレス可能ストレージの本質的な制約だ。

演習2では、Git LFSがバイナリの実体をポインタファイル（約130バイト）に置き換え、Gitのオブジェクトストアを小さく保つ仕組みを確認した。実体は`.git/lfs/objects/`に別途保存される。

演習3では、shallow cloneが履歴の深さを制限することでクローンサイズを削減する効果を確認した。ただし、利用可能なコミット数が制限されるトレードオフがある。

演習4では、sparse-checkoutがモノレポの作業ディレクトリを必要な部分だけに絞り込む機能を確認した。partial cloneと組み合わせれば、巨大モノレポでも効率的に開発できる可能性を示した。

---

## 8. まとめと次回予告

### この回の要点

第一に、Gitの内容アドレス可能ストレージは、バイナリファイルの管理に本質的な弱点を持つ。ファイルの1バイトの変更でも新しいblobオブジェクトが生成され、packファイルのデルタ圧縮はバイナリに対して効率が悪い。テキスト中心のソフトウェア開発に最適化された設計であり、ゲーム開発や機械学習など大量のバイナリを扱う領域ではこの制約が深刻になる。

第二に、Git LFS（2015年、GitHub / Rick Olson）は、ポインタファイルとsmudge/cleanフィルタによってバイナリをGitのオブジェクトストアから分離する。だが、LFSサーバへの依存、既存ワークフローとの摩擦、ストレージコストの移転という妥協を伴う。Git LFSを使った時点で、そのリポジトリは集中型の要素を持つ。

第三に、shallow clone、partial clone（Git 2.19前後）、sparse-checkout（cone mode、Git 2.25）は、Gitの「全履歴ローカル保持」という前提を段階的に緩和する。partial cloneは履歴グラフを保持しつつblobの遅延取得を実現し、sparse-checkoutは作業ディレクトリを必要な部分に絞り込む。これらを組み合わせたScalar（Git 2.38で本体統合）は、大規模リポジトリへの標準的な対応策になりつつある。

第四に、Gitの分散型設計はパスベースの読み取りアクセス制御を原理的に不可能にしている。Subversionのauthzが提供していた細粒度のアクセス制御は、Gitでは実現できない。ワークアラウンドはリポジトリの分割だが、モノレポの利点と引き換えになる。

第五に、Google（Piper）、Meta（Sapling、2022年公開）、Microsoft（VFS for Git / Scalar）がそれぞれ独自のソリューションを開発した事実は、Gitの標準機能だけでは超大規模環境に対応できないことを示している。モノレポとマルチレポの選択は、Gitのトレードオフを理解した上で行うべき設計判断だ。

### 冒頭の問いへの暫定回答

Gitは何を犠牲にして、何を得たのか。

Gitが得たものは明確だ。全履歴のローカル保持によるオフライン操作の完全性、暗号学的ハッシュによるデータの完全性保証、軽量なブランチとマージによる非線形開発のサポート。これらは第15回〜第17回で詳述した。

犠牲にしたものもまた明確だ。大きなバイナリファイルの効率的な管理。巨大リポジトリでのスケーラビリティ。パスベースの細粒度アクセス制御。そして、全履歴を常にローカルに持つことによるクローンとフェッチの負荷。

これらのトレードオフは、Gitの設計が「間違っていた」ことを意味しない。2005年のLinuxカーネル開発——数百人の開発者が、テキストファイル（Cのソースコード）を中心に、高速なマージを繰り返す環境——においては、Gitの設計は最適解に近かった。問題は、Gitの利用範囲がLinuxカーネルをはるかに超えて拡大し、当初の設計前提とは異なる環境に適用されるようになったことだ。

完璧なツールは存在しない。存在するのは、特定の問題に対する特定のトレードオフを持ったツールだ。Gitの弱点を知ることは、Gitを「盲信」から解放し、適切な運用判断——Git LFSの導入、partial clone + sparse-checkoutの活用、あるいはGit以外のツールの検討——につなげる第一歩だ。

### 次回予告

**第19回「GitHubの功罪——ソーシャルコーディングが変えたもの」**

次回は、Gitの内部構造から離れ、Gitの「外側」に目を向ける。2008年に登場したGitHubは、Pull Requestモデルを発明し、OSSへの参加のハードルを劇的に下げた。しかし同時に、「Git = GitHub」という等号を作り出し、Gitの可能性を矮小化した側面もある。GitHubはgitを「民主化」したのか、「矮小化」したのか。メーリングリストベースのパッチレビューとPull Requestモデルの違い、Fork & Pullモデルの設計思想、GitHub ActionsによるCI/CD統合が開発のあり方をどう変えたかを考える。

あなたのプロジェクトでは、GitHubの機能をどこまで使っているだろうか。そして、GitHubがなくなったとしたら、あなたの開発ワークフローは機能するだろうか。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- GitHub, "Git Large File Storage." <https://git-lfs.com/>
- GitHub, git-lfs/git-lfs repository. <https://github.com/git-lfs/git-lfs>
- Git Rev News, "Edition 2 (April 15th, 2015)." <https://git.github.io/rev_news/2015/04/05/edition-2/>
- Git SCM, "Git Internals - Packfiles." Pro Git, 2nd Edition. <https://git-scm.com/book/en/v2/Git-Internals-Packfiles>
- Git SCM, "pack-heuristics Documentation." <https://git-scm.com/docs/pack-heuristics>
- Git SCM, "partial-clone Documentation (2.19.0)." <https://git-scm.com/docs/partial-clone/2.19.0>
- Git SCM, "git-sparse-checkout Documentation." <https://git-scm.com/docs/git-sparse-checkout>
- Git SCM, "scalar Documentation." <https://git-scm.com/docs/scalar>
- Ars Technica / TechCrunch, "Microsoft now uses Git and GVFS to develop Windows." 2017-05-24. <https://techcrunch.com/2017/05/24/microsoft-now-uses-git-and-gvfs-to-develop-windows/>
- Harry, B., "The largest Git repo on the planet." Azure DevOps Blog. <https://devblogs.microsoft.com/bharry/the-largest-git-repo-on-the-planet/>
- Microsoft, "Announcing GVFS (Git Virtual File System)." Azure DevOps Blog. <https://devblogs.microsoft.com/devops/announcing-gvfs-git-virtual-file-system/>
- Microsoft, "Introducing Scalar: Git at scale for everyone." Azure DevOps Blog. <https://devblogs.microsoft.com/devops/introducing-scalar/>
- Phoronix, "Git 2.38 Adds Microsoft's Scalar Repository Management Tool." <https://www.phoronix.com/news/Git-2.38-Released>
- Potvin, R. and Levenberg, J., "Why Google Stores Billions of Lines of Code in a Single Repository." Communications of the ACM, 2016. <https://cacm.acm.org/research/why-google-stores-billions-of-lines-of-code-in-a-single-repository/>
- Meta Engineering, "Sapling: Source control that's user-friendly and scalable." 2022-11-15. <https://engineering.fb.com/2022/11/15/open-source/sapling-source-control-scalable/>
- InfoQ, "Git 2.25 Improves Support for Sparse Checkout." 2020-01. <https://www.infoq.com/news/2020/01/git-2-25-sparse-checkout/>
- Muse, K., "The Secret Life of Git Large File Storage." <https://www.kenmuse.com/blog/secret-life-of-git-lfs/>
- SVN Book, "Path-Based Authorization." Version Control with Subversion, 1.7. <https://svnbook.red-bean.com/en/1.7/svn.serverconfig.pathbasedauthz.html>
- Wikipedia, "Virtual File System for Git." <https://en.wikipedia.org/wiki/Virtual_File_System_for_Git>
