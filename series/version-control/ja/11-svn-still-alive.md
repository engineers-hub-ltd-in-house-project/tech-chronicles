# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第11回：Subversionは死んだのか？——今なお現役の理由

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- 2020年代においてもSubversionが使われ続けている具体的な現場と理由
- 巨大バイナリファイル管理におけるSubversionの構造的優位性とGit LFSの限界
- パスベースアクセス制御が企業のガバナンス要件にどう応えるか
- svn:externalsとgit submoduleの設計思想の違いと実務上の差異
- 部分チェックアウト、ファイルロックなど、Subversionが今なお優位な機能群
- 「全部git」という思考停止に対する具体的な反論の視座

---

## 1. 「まだSVNを使っているのですか？」

2022年のことだ。ある企業のインフラ基盤の構築支援に入ったとき、私はプロジェクトのバージョン管理がSubversionであることを知った。

正直に言えば、驚いた。GitHubやGitLabが当たり前の時代に、`svn checkout` から始まるワークフローが現役で動いている。しかも、その企業は技術的に遅れているわけではなかった。クラウドインフラはAWS上に構築され、CI/CDパイプラインも整備されていた。ただ、ソースコードとインフラ定義の一部が、Subversionリポジトリで管理されていた。

「なぜSubversionなのですか？」と私が聞くと、担当のエンジニアは淡々と答えた。「ドキュメントと設計書のバイナリファイルが大量にあるんです。パスごとにアクセス権を分けたいプロジェクトもある。Gitに移行する話は何度も出たけど、そのたびにこの二つの問題で止まるんですよ」

この答えは、私にとって新鮮だった。というよりも、私自身が「全部git」という前提に無自覚に染まっていたことに気づかされた。

Stack Overflow Developer Surveyによれば、開発者の93%以上がGitを使用している。SVNを含むその他のバージョン管理システムは、合計しても7%程度に過ぎない。この数字だけを見れば、「Subversionは死んだ」と結論づけたくなる。

だが、7%とは何人だ。Stack Overflowの調査回答者が数万人規模であることを考えれば、「少数派」は決して「不在」ではない。そして、その少数派がSubversionを使い続けている理由は、怠惰でも無知でもなく、合理的な判断に基づいている場合が少なくない。

この回では、「gitの時代に、Subversionを使い続ける合理性はあるのか」という問いに正面から向き合う。答えを先に言えば——ある。ただし、その合理性は無条件ではなく、特定の問題空間に限定される。重要なのは、その境界線がどこにあるかを知ることだ。

あなたのプロジェクトでは、本当にGitが最適解だろうか。この問いに自信を持って答えられるだろうか。

---

## 2. Subversionの「現在地」——開発は続いている

### 1.14 LTS——静かだが着実な更新

Subversionは死んでいない。少なくとも、ソフトウェアとしては生きている。

Apache Subversion 1.14.0は2020年5月27日にLTS（Long Term Support）としてリリースされた。The Apache Software Foundationは公式にこのリリースを発表し、「最も完全なSubversionリリース」と位置づけた。以後、セキュリティ修正とバグ修正のリリースが継続されている。1.14.1（2021年2月）、1.14.2（2022年4月）、1.14.3（2023年12月）、1.14.4（2024年10月）、そして最新の1.14.5（2024年12月8日、CVE-2024-46901対応）。

新機能の開発は事実上停止している。1.14が最後のメジャーリリースであり、次期バージョンのロードマップは公開されていない。だが、セキュリティ修正が継続的にリリースされているということは、Apache Software Foundationがこのプロジェクトを維持する意志を持っているということだ。エンタープライズ環境で使い続けるにあたって、「既知の脆弱性が放置される」という事態は回避されている。

1.14の注目すべき新機能の一つが、実験的なshelving/checkpointing機能だ。これは、コミットせずに作業中の変更のスナップショットを保存・復元する機能である。集中型VCSの宿命的制約——「サーバに接続しなければコミットできない」——を部分的に緩和する試みだ。Gitのstashに相当する機能を、Subversionの枠組みの中で実現しようとしている。実験的機能であり本番環境での使用は推奨されないが、Subversionが自らの弱点を認識し、それに対処しようとしている姿勢は注目に値する。

### 象徴的な事実——ASF自身の移行

興味深い事実がある。Subversionの開発母体であるApache Software Foundation自身のプロジェクトが、順次Gitに移行していることだ。Apache TomcatやApache Mavenをはじめ、多くのASFプロジェクトがGitリポジトリに移行した。ASFはinfra.apache.orgでSVN→Git移行ガイドを公式に提供しており、svn2gitによる変換、gitbox.apache.orgへのプッシュ、旧SVNリポジトリの読み取り専用化という手順が整備されている。

だが、Subversion自体のソースコードリポジトリは、今もSVNで管理されている。

この事実は象徴的だ。Subversionの開発者たちは、自分たちのツールの限界を誰よりもよく知っている。それでも、Subversionの開発にSubversionを使い続けている。これは「自分たちの製品を信じている」という表明であると同時に、「Subversionが適切な場面ではSubversionを使う」という実践でもある。

### Blenderの移行——SVN離脱の事例

一方で、Subversionから離脱した注目すべき事例もある。

オープンソースの3DCGソフトウェアBlenderは、長年にわたりバイナリファイル（マニュアル、翻訳データ、ライブラリ、テストファイル）の管理にSubversionを使用していた。2023年5月、Blender開発者ブログで「Sunsetting Subversion」が発表された。Git LFSの成熟とGiteaへの移行により、Gitでバイナリ管理が実用的になったと判断したのだ。

Blender Studioが公開したベンチマーク調査は、この判断を裏付けるデータを提供している。Springフィルム（3,000以上のコミット）プロジェクトでは、SVNサーバのリポジトリサイズが247.9GBだったのに対し、Git LFS（.blend圧縮あり）は転送速度でSVNとvanilla Gitの双方を上回った。ただし、vanilla Gitでは大きなバイナリファイルの`git add`に1分以上、repackingで32GB RAMを消費するという問題が報告されており、Git LFSなしのGitではバイナリ管理が非実用的であることも同時に示された。

Blenderの移行は「SVNの敗北」を意味するだろうか。私はそうは思わない。Blenderの判断は、Git LFSという「SVNの弱点を補うGitの拡張」が十分に成熟したことを示している。裏を返せば、Git LFSなしのGitでは、SVNのバイナリ管理能力に及ばないということでもある。

---

## 3. Subversionが今なお優位な領域

### 巨大バイナリファイルの管理

Subversionが最も明確な優位性を持つのが、巨大バイナリファイルの管理だ。

Gitの内部設計は、テキストファイルの差分管理に最適化されている。内容アドレッサブルストレージ（第15回で詳述予定）は、ファイル内容のSHA-1ハッシュをキーとしてオブジェクトを格納する。テキストファイルであれば、packファイル内で差分圧縮が効率的に機能する。だが、バイナリファイル——画像、3Dモデル、音声ファイル、動画、PDF——では、わずかな変更でもファイル全体のハッシュが変わり、差分圧縮の効果が大幅に低下する。

Git LFSはこの問題に対する解だが、本質的な制約がある。

第一に、Git LFSはバイナリファイルの差分圧縮を行わない。各バージョンのファイルがそのまま別サーバに保存される。100MBのPSDファイルを100回更新すれば、LFSサーバには約10GBのストレージが消費される。Subversionでは、FSFSバックエンドがバイナリファイルに対してもxdelta差分を計算し、差分のみを保存する。変更が局所的であれば、ストレージ効率はLFSより大幅に優れる。

第二に、コスト構造の問題がある。GitHub、GitLab、Bitbucketのいずれも、LFSストレージには追加料金が発生する。GitHubの場合、無料枠は1GBのストレージと1GB/月の帯域幅だ。ゲーム開発や映像制作のプロジェクトでは、この枠を容易に超える。一方、Subversionリポジトリを自社サーバで運用すれば、ストレージコストはディスク価格のみだ。

第三に、Git LFSのワークフローの複雑さがある。`.gitattributes` ファイルでLFS追跡対象を指定し、チームの全員がGit LFSをインストールし、適切に設定する必要がある。設定を忘れた一人の開発者がバイナリファイルを通常のGitオブジェクトとしてコミットすれば、リポジトリが膨張する。Subversionでは、バイナリファイルもテキストファイルも同じワークフローで管理される。特別な設定は不要だ。

ゲーム開発の現場が、この問題を最も鋭く体現している。Epic Games自身がUnreal Engineの開発にPerforce（集中型VCS）を使用し、サードパーティの開発者にもPerforceを推奨している。Unreal EngineはPerforceとSubversionの双方を公式にサポートしている。Gitのサポートも存在するが、大量のバイナリアセット（テクスチャ、メッシュ、オーディオファイル）を扱うゲーム開発では、集中型VCSの方が適しているという判断だ。

中小規模のゲームスタジオ（5〜50名程度）にとって、Subversionはコスト面で魅力的な選択肢だ。Perforceは強力だが、商用ライセンスのコストは小規模チームにとって無視できない。Subversionは完全に無料であり、Unreal Engineとの統合も公式にサポートされている。2024年8月にも、Subversionをセットアップしてゲーム開発に使用する方法を解説する技術ブログが公開されている。「死んだツール」に対して書かれる記事ではない。

### パスベースのアクセス制御

Subversionの二つ目の優位性は、パスベースのアクセス制御だ。

前回でも触れたが、改めて技術的な詳細を掘り下げる。Subversionの `authz` ファイルによるアクセス制御は、リポジトリ内のディレクトリパスに対して、ユーザーまたはグループごとにread（`r`）またはread-write（`rw`）の権限を設定できる。

```
# authz ファイルの例

[groups]
dev-team-a = alice, bob, charlie
dev-team-b = dave, eve
managers = frank, grace

[/]
* = r

[/trunk/module-a]
@dev-team-a = rw

[/trunk/module-b]
@dev-team-b = rw

[/trunk/confidential]
@managers = rw
* =
```

この例では、全ユーザーにリポジトリのルートへの読み取り権限を付与しつつ、`/trunk/module-a` への書き込みはdev-team-aのメンバーのみ、`/trunk/confidential` はmanagersのみがアクセスでき、それ以外のユーザーは存在すら確認できない。

この粒度のアクセス制御は、Gitの分散型アーキテクチャでは原理的に実現が困難だ。Gitでは `git clone` した時点で、リポジトリ内の全履歴と全ファイルがクローン先に複製される。特定のディレクトリだけを除外して複製することはできない（partial cloneやsparse checkoutは作業ツリーの制限であり、オブジェクトストア全体を制限するものではない）。

この問題は、以下のような環境で切実になる。

**規制産業（医療機器、航空宇宙、金融）**——FDA 21 CFR Part 11やISO 13485は、電子記録に対するアクセス制御と監査証跡を要求する。「誰がいつ何にアクセスしたか」を証明する必要がある環境では、中央リポジトリでのパスベースアクセス制御は、コンプライアンスの基盤となる。

**マルチテナント型のリポジトリ**——複数のプロジェクトやクライアント向けのコードを単一リポジトリで管理する場合、あるクライアントのコードが別のクライアントの開発者に見えてはならない。Gitではリポジトリを分離するしか方法がないが、Subversionでは単一リポジトリ内でパスベースに分離できる。

**社内のIP（知的財産）保護**——特定のモジュールの実装を一部のチームにしか公開したくない場合、Gitでは別リポジトリにするか、モノレポを諦めるかの二択になる。Subversionなら、同一リポジトリ内で細粒度のアクセス制御を適用できる。

Apache HTTP Serverの `mod_authz_svn` モジュールとLDAP/Active Directory連携を組み合わせれば、既存の企業認証基盤とシームレスに統合される。「Subversionのためだけに特別な認証基盤を構築する」必要はない。

### 部分チェックアウト（Sparse Checkout）

Subversion 1.5で導入されたsparse checkoutは、大規模リポジトリの運用において実用的な機能だ。

`--depth` オプションにより、チェックアウトの深さを4段階で指定できる。

```
svn checkout --depth=empty    リポジトリURL  作業コピー   # ルートのみ
svn checkout --depth=files    リポジトリURL  作業コピー   # ファイルのみ（サブディレクトリなし）
svn checkout --depth=immediates リポジトリURL  作業コピー # 直下のみ（再帰なし）
svn checkout --depth=infinity リポジトリURL  作業コピー   # 全て（デフォルト）

# 後から特定のディレクトリだけを追加
svn update --set-depth=infinity 作業コピー/特定ディレクトリ
```

このdepth設定は「sticky」——一度設定すると作業コピーに記憶され、以後の `svn update` でもその範囲だけが更新される。必要に応じて `--set-depth` で後から範囲を拡大・縮小できる。

Gitにもsparse-checkout機能はある（Git 1.7.0、2010年に導入）。だが、Gitのsparse-checkoutは「作業ツリーの範囲」を制限するものであり、`git clone` 時にはリポジトリ全体のオブジェクトがダウンロードされる。partial clone（`--filter=blob:none` 等）と組み合わせれば、初回のダウンロード量を削減できるが、設定は複雑であり、すべてのGitサーバがpartial cloneをサポートしているわけではない。

Subversionのsparse checkoutは、集中型アーキテクチャの利点を活かして、必要な部分だけをサーバから取得する。シンプルで直感的であり、特別な設定を必要としない。数百のモジュールを含む大規模リポジトリで、自分が担当する数モジュールだけをチェックアウトする——この用途において、Subversionの操作体験はGitよりも単純明快だ。

### ファイルロック

バイナリファイルの共同作業において、ファイルロックは不可欠な機能だ。

テキストファイルのコンフリクトは、多くの場合マージによって自動解決されるか、手動でも比較的容易に解決できる。だが、バイナリファイル——Photoshopの.psdファイル、Mayaの.maファイル、Excelスプレッドシート——のコンフリクトは、マージが不可能だ。二つのバージョンのどちらかを選ぶか、手作業でやり直すしかない。

Subversionのファイルロック機能は、この問題を「予防」で解決する。

`svn:needs-lock` プロパティをファイルに設定すると、そのファイルは作業コピー上で自動的に読み取り専用になる。編集するには、まず `svn lock` でロックを取得する必要がある。ロックは中央サーバで管理されるため、同時に二人のユーザーが同じファイルをロックすることはできない。編集が終わったらコミットと同時にロックが解放される。

```bash
# ファイルにsvn:needs-lockプロパティを設定
svn propset svn:needs-lock '*' design.psd

# ロック取得（他のユーザーは編集不可になる）
svn lock design.psd -m "デザイン修正中"

# 編集作業...

# コミット（ロックは自動的に解放される）
svn commit -m "Update design" design.psd
```

Git LFS Locksも同様の機能を提供する。だが、Git LFS Locksは後発の実装であり、Subversionのロック機能ほど成熟していない。また、Git LFS Locksを使うにはLFSサーバがロック機能をサポートしている必要があり、すべてのGitホスティングサービスが対応しているわけではない。

---

## 4. svn:externalsとgit submodule——依存関係管理の設計思想

### svn:externalsの仕組み

Subversionのsvn:externalsは、作業コピー内のサブディレクトリに外部リポジトリのURLをマッピングする機能だ。ディレクトリに `svn:externals` プロパティを設定すると、`svn checkout` や `svn update` の際に、指定された外部リポジトリが自動的にチェックアウトまたは更新される。

```
# svn:externals の設定例
# 形式: [-rN] URL ローカルパス

# 最新リビジョンを追従
https://svn.example.com/repos/lib-core/trunk  lib/core

# 特定リビジョンに固定
-r 4521 https://svn.example.com/repos/lib-auth/trunk  lib/auth

# サブディレクトリだけを参照（リポジトリ全体ではない）
https://svn.example.com/repos/shared-utils/trunk/date-utils  lib/date-utils
```

この設計にはいくつかの重要な特性がある。

第一に、**サブディレクトリ単位の参照**が可能だ。外部リポジトリの特定のサブディレクトリだけを作業コピーに組み込める。リポジトリ全体をチェックアウトする必要がない。大規模な共有リポジトリから必要な部分だけを取り出せるという柔軟性は、モノレポ環境で特に有用だ。

第二に、**自動更新**がデフォルトの動作だ。リビジョンを明示的に指定しない限り、`svn update` のたびに外部リポジトリの最新リビジョンが取得される。常に最新の依存ライブラリを使いたい場合、追加の操作は不要だ。

第三に、**リビジョン固定**も可能だ。`-r` オプションで特定のリビジョンに固定すれば、再現可能なビルドが保証される。SVN Bookは、本番環境向けのビルドでは明示的なリビジョン指定を推奨している。

### git submoduleとの比較

git submoduleは、外部Gitリポジトリを親リポジトリ内に組み込む機能だ。svn:externalsと同じ問題を解決しようとしているが、設計思想が根本的に異なる。

```
特性                     svn:externals           git submodule
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
参照単位               サブディレクトリ可      リポジトリ全体のみ
デフォルトの更新動作   自動（最新追従）        手動（明示的にupdate）
バージョン固定         リビジョン番号指定      コミットハッシュ固定
親のコミットとの連動   独立（個別にコミット）  連動（ハッシュが記録される）
設定の場所             svn:externalsプロパティ  .gitmodules + .git/config
学習コスト             低い                    高い
```

最も実務上のインパクトが大きいのは、「参照単位」の違いだ。

git submoduleは常にリポジトリ全体を参照する。共有ライブラリのリポジトリが100のモジュールを含んでいて、そのうちの1つだけが必要な場合でも、リポジトリ全体がクローンされる。svn:externalsなら、必要なサブディレクトリだけを指定できる。

次に大きいのは、「更新の自動性」の違いだ。git submoduleは特定のコミットに固定され、親リポジトリで `git submodule update` を明示的に実行しなければ更新されない。更新後には、親リポジトリでsubmoduleの参照コミットの変更をコミットする必要がある。svn:externalsは、リビジョンを指定しなければ `svn update` で自動的に最新が取得される。

どちらが「正しい」かは、ユースケースに依存する。再現可能なビルドを重視するならgit submoduleの「明示的な固定」は安全だ。常に最新の共有コードを使いたいならsvn:externalsの「自動更新」は便利だ。重要なのは、両者の設計思想の違いを理解した上で選択することだ。

---

## 5. ハンズオン：svn:externalsとgit submoduleの比較体験

svn:externalsとgit submoduleの動作の違いを、実際に手を動かして確認しよう。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y subversion git
```

### 演習1：svn:externalsで外部リポジトリを組み込む

```bash
WORKDIR="${HOME}/vcs-handson-11"
mkdir -p "${WORKDIR}"

echo "=== 演習1: svn:externals で外部リポジトリを組み込む ==="

# 共有ライブラリ用リポジトリの作成
svnadmin create "${WORKDIR}/shared-repo"
SHARED_URL="file://${WORKDIR}/shared-repo"

svn mkdir -m "Create trunk" "${SHARED_URL}/trunk" --quiet
svn checkout "${SHARED_URL}/trunk" "${WORKDIR}/shared-wc" --quiet
cd "${WORKDIR}/shared-wc"

# 共有ライブラリにモジュールを追加
mkdir -p utils math
cat > utils/string-helpers.sh << 'LIBEOF'
#!/bin/bash
to_upper() { echo "$1" | tr '[:lower:]' '[:upper:]'; }
to_lower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }
LIBEOF

cat > math/calc.sh << 'LIBEOF'
#!/bin/bash
add() { echo $(( $1 + $2 )); }
multiply() { echo $(( $1 * $2 )); }
LIBEOF

svn add utils math --quiet
svn commit -m "Add shared library modules" --quiet

# メインプロジェクト用リポジトリの作成
svnadmin create "${WORKDIR}/main-repo"
MAIN_URL="file://${WORKDIR}/main-repo"

svn mkdir -m "Create trunk" "${MAIN_URL}/trunk" --quiet
svn checkout "${MAIN_URL}/trunk" "${WORKDIR}/main-wc" --quiet
cd "${WORKDIR}/main-wc"

cat > app.sh << 'APPEOF'
#!/bin/bash
source lib/utils/string-helpers.sh
echo "Hello from main project"
echo "Upper: $(to_upper 'hello world')"
APPEOF

svn add app.sh --quiet
svn commit -m "Add main application" --quiet

# svn:externals の設定（サブディレクトリだけを参照）
echo "--- svn:externals を設定 ---"
svn propset svn:externals \
  "${SHARED_URL}/trunk/utils lib/utils" . --quiet
svn commit -m "Add externals for shared utils" --quiet

# svn update で外部リポジトリが自動取得される
echo ""
echo "--- svn update で外部リポジトリを取得 ---"
svn update --quiet
echo ""
echo "--- ディレクトリ構造 ---"
find . -not -path '*/.svn/*' -type f | sort
echo ""
echo "-> lib/utils/ に共有ライブラリのutils部分だけが取得された"
echo "-> math/ は取得されていない（サブディレクトリ単位の参照）"
```

### 演習2：svn:externalsの自動更新を確認する

```bash
echo ""
echo "=== 演習2: svn:externals の自動更新 ==="

# 共有ライブラリを更新
cd "${WORKDIR}/shared-wc"
cat >> utils/string-helpers.sh << 'LIBEOF'
trim() { echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'; }
LIBEOF
svn commit -m "Add trim function to string-helpers" --quiet

# メインプロジェクトでsvn update
cd "${WORKDIR}/main-wc"
echo ""
echo "--- svn update を実行 ---"
svn update 2>&1
echo ""
echo "--- 更新後の string-helpers.sh ---"
cat lib/utils/string-helpers.sh
echo ""
echo "-> svn update だけで外部リポジトリの最新変更が自動取得された"
echo "-> 追加の操作（submodule update等）は不要"
```

### 演習3：git submoduleで同じことを試みる

```bash
echo ""
echo "=== 演習3: git submodule で同じことを試みる ==="

# 共有ライブラリ用Gitリポジトリ
mkdir -p "${WORKDIR}/git-shared"
cd "${WORKDIR}/git-shared"
git init --bare --quiet

mkdir -p "${WORKDIR}/git-shared-wc"
cd "${WORKDIR}/git-shared-wc"
git init --quiet
git config user.email "handson@example.com"
git config user.name "Handson User"

mkdir -p utils math
cat > utils/string-helpers.sh << 'LIBEOF'
#!/bin/bash
to_upper() { echo "$1" | tr '[:lower:]' '[:upper:]'; }
to_lower() { echo "$1" | tr '[:upper:]' '[:lower:]'; }
LIBEOF

cat > math/calc.sh << 'LIBEOF'
#!/bin/bash
add() { echo $(( $1 + $2 )); }
multiply() { echo $(( $1 * $2 )); }
LIBEOF

git add -A && git commit -m "Add shared library modules" --quiet
git remote add origin "${WORKDIR}/git-shared"
git push origin main --quiet 2>/dev/null || git push origin master --quiet 2>/dev/null

# メインプロジェクト用Gitリポジトリ
mkdir -p "${WORKDIR}/git-main"
cd "${WORKDIR}/git-main"
git init --quiet
git config user.email "handson@example.com"
git config user.name "Handson User"

cat > app.sh << 'APPEOF'
#!/bin/bash
echo "Hello from main project"
APPEOF

git add app.sh && git commit -m "Add main application" --quiet

# git submodule でリポジトリ全体を追加
echo "--- git submodule add で共有リポジトリを追加 ---"
git submodule add "${WORKDIR}/git-shared" lib/shared --quiet 2>&1
git commit -m "Add shared library as submodule" --quiet

echo ""
echo "--- ディレクトリ構造 ---"
find lib/ -type f -not -path '*/.git/*' | sort
echo ""
echo "-> リポジトリ全体（utils/ と math/ の両方）が取得された"
echo "-> svn:externals のようにサブディレクトリだけを参照することはできない"
```

### 演習4：git submoduleの手動更新

```bash
echo ""
echo "=== 演習4: git submodule の手動更新 ==="

# 共有ライブラリを更新
cd "${WORKDIR}/git-shared-wc"
cat >> utils/string-helpers.sh << 'LIBEOF'
trim() { echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'; }
LIBEOF
git add -A && git commit -m "Add trim function" --quiet
MAIN_BRANCH=$(git branch --list main master | head -1 | tr -d ' *')
git push origin "${MAIN_BRANCH}" --quiet 2>/dev/null

# メインプロジェクトで確認
cd "${WORKDIR}/git-main"
echo "--- git pull をしても submodule は更新されない ---"
cat lib/shared/utils/string-helpers.sh
echo ""
echo "-> trim 関数がまだ存在しない"

echo ""
echo "--- git submodule update --remote を実行 ---"
git submodule update --remote --quiet 2>/dev/null
echo ""
cat lib/shared/utils/string-helpers.sh
echo ""
echo "-> trim 関数が取得された"
echo ""
echo "--- しかし、この変更を親リポジトリにコミットする必要がある ---"
git status
echo ""
echo "-> lib/shared に 'new commits' がある"
echo "-> git add && git commit で親リポジトリの参照を更新する必要がある"
echo ""
echo "--- svn:externals との違い ---"
echo "  svn:externals: svn update だけで完了（追加操作なし）"
echo "  git submodule: submodule update + 親リポジトリのコミットが必要"
echo "  svn:externals: サブディレクトリ単位で参照可能"
echo "  git submodule: リポジトリ全体のみ参照可能"
```

### 演習で見えたこと

四つの演習を通じて、svn:externalsとgit submoduleの動作の違いを確認した。

svn:externalsは、サブディレクトリ単位での参照が可能であり、`svn update` で外部リポジトリが自動更新される。大規模な共有リポジトリから必要な部分だけを取り出せる柔軟性と、日常的な操作のシンプルさが強みだ。

git submoduleは、常にリポジトリ全体を参照し、特定のコミットに固定される。更新には明示的な操作が必要で、親リポジトリへのコミットも伴う。再現可能性は高いが、操作の手順は多い。

どちらが「正しい」かではなく、プロジェクトの要件に応じて適切な方を選択すべきだ。常に最新の共有ライブラリを追従したいプロジェクトではsvn:externalsの方が運用コストが低く、厳密なバージョン固定が必要なプロジェクトではgit submoduleの方が安全だ。

---

## 6. 「全部git」に対する反論の構造

### 意思決定のフレームワーク

ここまでの議論を整理し、「SubversionとGitのどちらを選ぶべきか」を判断するためのフレームワークを提示する。

技術選定は、トレードオフの評価だ。万能のツールは存在しない。以下の五つの軸で評価すると、判断の見通しがよくなる。

**軸1：リポジトリ内のファイル構成**
テキストファイル中心のプロジェクトでは、Gitの差分圧縮と分散型の利点が最大限に活きる。大量のバイナリファイルを含むプロジェクトでは、Subversionの差分保存とファイルロックが優位になる。

**軸2：アクセス制御の要件**
リポジトリ全体を全員がアクセスできる環境ならGitで問題ない。パスベースの細粒度アクセス制御が必要な場合、Subversionが直接的な解を提供する。

**軸3：チームの地理的分散度**
同一拠点のチームで、安定したネットワーク接続がある場合、集中型VCSの制約は顕在化しにくい。分散したリモートチーム、オフラインでの作業が多い環境では、Gitの分散型アーキテクチャが決定的に有利だ。

**軸4：ブランチ戦略**
ブランチを頻繁に作成・マージする開発スタイルでは、Gitの軽量ブランチと高速マージが圧倒的に有利だ。トランクベースの開発で、ブランチを最小限にするスタイルなら、Subversionでも十分に運用できる。

**軸5：エコシステムとの統合**
GitHub Actions、GitLab CI、ArgoCD、Terraform——2020年代のCI/CDツールとDevOpsエコシステムは、ほぼ全面的にGitを前提としている。このエコシステムとの統合が重要な場合、Gitを選ばない理由を探す方が難しい。

```
評価マトリクス:

                          Subversion優位    Git優位
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ファイル構成     バイナリ大量      ◄━━━━━━━━━━━━━━━►  テキスト中心
アクセス制御     パスベース必須    ◄━━━━━━━━━━━━━━━►  リポジトリ単位で可
チーム分散度     同一拠点・常時接続 ◄━━━━━━━━━━━━━━━► リモート分散
ブランチ戦略     トランクベース    ◄━━━━━━━━━━━━━━━►  フィーチャーブランチ
エコシステム     レガシーCI        ◄━━━━━━━━━━━━━━━►  GitHub/GitLab統合
```

この五つの軸のうち、三つ以上がSubversion側に寄る場合、Subversionは合理的な選択肢だ。三つ以上がGit側に寄るなら、Git一択だ。問題は、二対三で拮抗する場合だ。そのとき、「みんなGitを使っているから」ではなく、各軸の重みづけをプロジェクトの文脈に応じて判断できるかどうかが、エンジニアの技術選定力を分ける。

### 「適材適所」は思考停止ではない

「適材適所」という言葉は、しばしば思考停止の隠れ蓑として使われる。「まあ、ケースバイケースですよね」と言って議論を打ち切る用途だ。

だが、ここで私が言いたいのは、そういう類の「適材適所」ではない。

具体的な判断基準を持ち、自分のプロジェクトの要件を正確に評価し、その評価に基づいてツールを選択する——これが本来の「適材適所」だ。「Gitを使う理由を説明できるか？」と問われたとき、「みんな使っているから」以外の答えを持っているか。「Subversionではなくgitを選んだ根拠は？」と聞かれたとき、五つの軸に沿って説明できるか。

逆も同様だ。Subversionを使い続けている現場が「なぜSubversionなのか」を説明できないなら、それは惰性であり、合理的な選択ではない。移行コストの見積もりすら行っていないなら、「現状維持」ではなく「思考停止」と呼ぶべきだ。

重要なのは、選択の根拠を持つことだ。ツールは目的のための手段であり、手段を目的化してはならない。

---

## 7. まとめと次回予告

### この回の要点

第一に、Subversionは死んでいない。Apache Subversion 1.14.5（2024年12月）に至るまでセキュリティ修正が継続されており、ソフトウェアとしてのメンテナンスは維持されている。ただし、新機能の開発は事実上停止しており、1.14が最後のメジャーリリースである。

第二に、Subversionが今なお優位な領域が存在する。巨大バイナリファイルの管理（Git LFSとの差分圧縮効率・コスト構造の違い）、パスベースのアクセス制御（分散型VCSでは原理的に困難）、部分チェックアウト（シンプルで直感的な操作）、ファイルロック（バイナリファイルの同時編集防止）——これらは、特定の問題空間でSubversionが合理的な選択肢であることを示している。

第三に、svn:externalsはgit submoduleと異なる設計思想を持つ。サブディレクトリ単位の参照と自動更新というsvn:externalsの特性は、特定のユースケースでgit submoduleよりも運用コストが低い。

第四に、技術選定は五つの軸（ファイル構成、アクセス制御、チーム分散度、ブランチ戦略、エコシステム統合）で評価できる。「全部git」は、多くの場合は正しいが、すべての場合に正しいわけではない。

第五に、Blenderの事例が示すように、Git LFSの成熟により、かつてSVNが不可欠だった領域でもGitへの移行が現実的になりつつある。Subversionの優位領域は縮小傾向にあるが、消滅してはいない。

### 冒頭の問いへの暫定回答

gitの時代に、Subversionを使い続ける合理性はあるのか。

ある。ただし、その合理性は無条件ではない。巨大バイナリの管理、パスベースのアクセス制御、部分チェックアウト、ファイルロック——これらの要件が強い場合に限り、Subversionは合理的な選択肢だ。それ以外の場合、2020年代のエコシステムとの統合を考えれば、Gitを選ばない理由を見つける方が難しい。

ただし、「合理性がない」ことと「移行すべき」は同義ではない。既存のSubversion環境が安定して運用されており、移行のコストとリスクがメリットを上回るなら、「移行しない」という判断もまた合理的だ。重要なのは、その判断が評価に基づいていることだ。

### 次回予告

第10回と第11回で、Subversionの栄光、衰退、そして今なお残る存在意義を見てきた。第3章「Subversion——CVSを正しく作り直す試み」はこれで完結する。

次回からは、第4章「分散型VCSの夜明け」に入る。

**第12回「分散型VCSの思想——なぜ"中央"をなくしたかったのか」**

分散型バージョン管理は、技術的必然だったのか、それとも思想的選択だったのか。GNU arch、Monotone、Darcs——Gitが登場する前に、分散型VCSの思想を切り拓いた先駆者たちがいた。彼らは何を目指し、何を実現し、そして何が足りなかったのか。

「サーバが落ちたら全員が止まる」——この恐怖体験から出発した分散型VCSの思想が、オープンソースコミュニティの自律分散的な開発スタイルとどう共鳴したのか。次回は、Gitの「前夜」を語る。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Apache Subversion, "Release History." <https://subversion.apache.org/docs/release-notes/release-history.html>
- Apache Subversion, "1.14 LTS Release Notes." <https://subversion.apache.org/docs/release-notes/1.14>
- The Apache Software Foundation, "Apache Subversion 1.14.0-LTS." GlobeNewsWire (2020年5月28日) <https://www.globenewswire.com/news-release/2020/05/28/2040151/0/en/The-Apache-Software-Foundation-Announces-Apache-Subversion-1-14-0-LTS.html>
- Apache Infrastructure, "SVN to Git migration." <https://infra.apache.org/svn-to-git-migration.html>
- Collins-Sussman, B., Fitzpatrick, B.W. & Pilato, C.M., "Version Control with Subversion (SVN Book)." <https://svnbook.red-bean.com/>
- SVN Book, "Path-Based Authorization." <https://svnbook.red-bean.com/en/1.8/svn.serverconfig.pathbasedauthz.html>
- SVN Book, "Externals Definitions." <https://svnbook.red-bean.com/en/1.7/svn.advanced.externals.html>
- SVN Book, "Sparse Directories." <https://svnbook.red-bean.com/en/1.8/svn.advanced.sparsedirs.html>
- SVN Book, "Locking." <https://svnbook.red-bean.com/en/1.7/svn.advanced.locking.html>
- King, A., "Git Submodules are not SVN Externals." (2012年) <https://alexking.org/blog/2012/03/05/git-submodules-vs-svn-externals>
- Blender Developers Blog, "Sunsetting Subversion." (2023年5月15日) <https://code.blender.org/2023/05/sunsetting-subversion/>
- Blender Studio, "Benchmarking Version Control Solutions for Creative Collaboration." <https://studio.blender.org/blog/benchmarking-version-control-git-lfs-svn-mercurial/>
- Stack Overflow Blog, "Beyond Git: The other version control systems developers use." (2023年1月) <https://stackoverflow.blog/2023/01/09/beyond-git-the-other-version-control-systems-developers-use/>
- Epic Games, "Collaboration and Version Control in Unreal Engine." <https://dev.epicgames.com/documentation/en-us/unreal-engine/collaboration-and-version-control-in-unreal-engine>
- Execution Unit, "How I setup Subversion to work with Unreal." (2024年8月) <https://www.executionunit.com/blog/2024/08/21/how-i-setup-subversion-to-work-with-unreal/>
