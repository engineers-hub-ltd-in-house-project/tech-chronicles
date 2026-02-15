# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第10回：Subversionの黄金時代と陰り

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Subversionが2005年から2010年にかけて企業の開発現場を席巻した背景と経緯
- TortoiseSVN、Eclipse統合、Visual Studio統合がSubversion普及に果たした役割
- Subversion 1.5のマージ追跡（svn:mergeinfo）の仕組みと、その実装が遅延した経緯
- Subversionの構造的弱点——リネーム追跡の不在、オフライン作業の制約、大規模リポジトリでの性能劣化
- GitHubの登場（2008年）がSubversionの覇権を終わらせた経緯
- 「パラダイム内の最適化」と「パラダイムシフト」の違い

---

## 1. 覇者の風景——2007年の現場

私が当時関わっていたWebシステム開発の現場では、Subversionは空気のような存在だった。

2007年頃のことだ。プロジェクトに参加する初日、渡されるドキュメントには必ずSubversionリポジトリのURLが記載されていた。`svn checkout` を実行し、作業コピーを取得する。コードを書き、`svn update` で最新の変更を取り込み、`svn commit` で自分の変更をリポジトリに反映する。このサイクルは、朝のコーヒーのように自然だった。

Windows環境の開発者はTortoiseSVNを使っていた。エクスプローラ上のファイルにオーバーレイアイコンが表示される——緑のチェックマークは「最新」、赤い丸は「変更あり」。右クリックすれば、コミット、更新、ログの確認、差分の表示、すべてがメニューから操作できた。コマンドラインに馴染みのない開発者でも、Subversionを使いこなしていた。

Eclipse使いのJava開発者は、SubclipseかSubversiveプラグインを入れていた。IDE内でコミット履歴が確認でき、差分ビューでファイルの変更箇所が視覚的に表示された。Visual Studioの.NET開発者にはAnkhSVNやVisualSVNがあった。主要なIDEすべてにSubversion統合が存在し、開発者はVCSの操作をIDEの一部として自然に行っていた。

「バージョン管理に何を使っていますか？」と聞けば、答えはほぼ「Subversion」だった。CVSからの移行は完了し、Gitという名前はまだLinuxカーネル開発者のための道具に過ぎなかった。2009年のEclipseコミュニティ調査では、SVNが58%のシェアを握り、Gitはわずか2%だった。

これが、Subversionの黄金時代の風景だ。

だが、私は今、その時代を振り返りながら考える。あれほど盤石に見えた覇権が、なぜわずか数年で崩れ去ったのか。Subversionは何に「勝てなかった」のか。そして、それは技術的な敗北だったのか、それとも別の力学が働いたのか。

---

## 2. 黄金時代の構築——Subversionはいかにして覇権を握ったか

### 着実なリリースサイクル

Subversion 1.0が2004年2月23日にリリースされてから、開発チームは着実にバージョンを重ねた。1.1（2004年9月）、1.2（2005年5月）、1.3（2005年12月）、1.4（2006年9月）。各メジャーリリースは、既存機能の安定性向上と、ユーザーからの要望に応える新機能を着実に積み上げた。

1.1ではFSFSバックエンドがデフォルトとなり、Berkeley DB依存からの脱却が完了した。前回の第9回で解説したFSFSの透過的な構造——1リビジョン＝1ファイル、テキストエディタで中身が読める——は、運用管理者にとって大きな安心材料だった。

1.2ではDAV自動バージョニングのサポートが強化され、WebDAVクライアントからの透過的なバージョン管理が可能になった。1.3では全般的な性能改善が行われた。1.4ではsvnsyncによるリポジトリのミラーリングが導入され、地理的に分散したチームでのリードレプリカ運用が可能になった。

この時期のSubversionの強みは、「CVSの正統な後継者」としての信頼感だった。CVSのユーザーインターフェースを継承しつつ、CVSの弱点——非アトミックコミット、ディレクトリのバージョン管理不可、バイナリファイルの扱い——をすべて解決した。CVSからの移行パスは明確であり、学習コストは最小限だった。

### ツールエコシステムの充実

Subversionの普及を技術的な機能だけで説明することはできない。ツールエコシステムの充実が、普及の決定的な推進力だった。

**TortoiseSVN**の存在は、Windows環境でのSubversion普及において決定的だった。Tim Kempが2002年にTortoiseCVSに触発されて開発を開始し、Stefan Kungがプロジェクトに参加してコードの大部分を書き直した。最初の公開リリースはバージョン0.4（2003年1月24日）、安定版1.0は2004年2月23日——Subversion 1.0と同日——にリリースされた。

TortoiseSVNの革新性は、バージョン管理操作をWindowsエクスプローラのシェル拡張として統合したことにある。専用のGUIアプリケーションを起動する必要がなく、通常のファイル操作の延長線上でバージョン管理が行えた。ファイルのオーバーレイアイコンは、バージョン管理の状態を常に視覚的に伝えた。これは、コマンドライン操作に抵抗感を持つ層——特に当時のWindows中心の企業開発現場——に対して、バージョン管理のハードルを大幅に下げた。

**Eclipse統合**も重要だった。SubclipseはSubversionコアコミッターが開発・保守するプラグインで、最新のSubversion機能との同期が保証されていた。Subversiveは Eclipse Foundation公式のSVN統合として、Eclipse Indigo（2011年）以降のリリースにバンドルされた。Java開発者——当時のエンタープライズ開発の主力——にとって、EclipseからSubversionを操作することは日常の開発フローの一部だった。

**Visual Studio統合**については、AnkhSVN（Apache License下の無料プラグイン）とVisualSVN（TortoiseSVNを内部利用する商用製品）の二つが主要な選択肢だった。AnkhSVNはVisual Studio .NET 2002/2003向けの1.x系から始まり、VS 2005で導入されたSCC APIに対応するために2.0で完全に書き直された。.NET開発者にとっても、Subversionは統合された開発ツールチェーンの一部として機能した。

### 企業への浸透

Subversionが企業に受け入れられた理由は、ツールの充実だけではない。集中型アーキテクチャそのものが、企業のガバナンス要件に適合していたのだ。

単一の中央リポジトリは、「唯一の真実」を提供した。誰がいつ何を変更したか、その完全な記録が一箇所に集約されている。監査証跡として利用でき、コンプライアンス要件を満たしやすい。

パスベースのアクセス制御（`authz` ファイル）により、リポジトリ内の特定のディレクトリに対して、ユーザーやグループごとに読み取り/書き込みの権限を細かく設定できた。「開発チームAは `/trunk/module-a/` に書き込めるが、`/trunk/module-b/` は読み取りのみ」といった制御が、Subversionの標準機能で実現できた。分散型VCSでは、リポジトリ全体が複製されるため、このレベルのパスベースアクセス制御は原理的に困難だ。

Apache HTTP Serverとの統合も企業にとって魅力的だった。`mod_dav_svn` を使えば、既存のApache認証基盤（LDAP、Active Directory連携）をそのまま利用できた。HTTPSによる通信の暗号化も標準的に利用可能だった。企業の既存インフラとの親和性が高かったのだ。

こうして、2005年から2010年にかけて、Subversionは企業の開発現場のデファクトスタンダードとなった。オープンソースプロジェクトの旗手であったApache Software Foundation自身がSubversionを公式VCSとして採用していたことも、その信頼性を裏付けた。

---

## 3. 陰り——Subversionの構造的弱点

### マージ追跡の遅すぎた到来

Subversionの黄金時代を語るうえで避けて通れないのが、マージ追跡機能の問題だ。

CVS時代、ブランチ間のマージは悪夢だった（第6回参照）。CVSにはマージ追跡機能が一切なく、開発者が手動で「どのリビジョンからどのリビジョンまでをマージしたか」を記録しなければならなかった。Subversionはこの問題を「正しくやり直す」はずだった。

だが、Subversion 1.0にはマージ追跡機能がなかった。1.1にも、1.2にも、1.3にも、1.4にもなかった。待望のマージ追跡が実装されたのは、1.5——2008年6月19日リリース——まで待たなければならなかった。Subversion 1.0のリリースから4年以上が経過していた。

この遅延は偶然ではない。Hyrum K. WrightとDewayne E. Perryは2009年の論文"Subversion 1.5: A Case Study in Open Source Release Mismanagement"で、1.5のリリースプロセスが「長く困難な開発・テスト・リリースサイクル」であったことを分析している。マージ追跡の設計は複雑であり、その実装は当初の見積もりをはるかに超えた。リリースの遅延はユーザーと開発者の双方に混乱と失望をもたらした。

Subversion 1.5で導入されたマージ追跡の仕組みは、`svn:mergeinfo` というバージョン管理されたプロパティだ。マージが実行されると、マージ先のファイルやディレクトリに `svn:mergeinfo` プロパティが設定され、マージ元のパスとマージ済みリビジョンのリストが記録される。

```
svn:mergeinfo の値の例:
/branches/feature-x:234-289,305,310-320
/branches/bugfix-y:401-415
```

この形式は「`/branches/feature-x` のリビジョン234から289、305、310から320がマージ済み」という意味だ。`svn merge` コマンドはこのプロパティを参照し、未マージのリビジョンだけを自動的に適用する。

仕組みとしては理にかなっている。だが、実際の運用では多くの問題が露呈した。

第一に、`svn:mergeinfo` プロパティは個々のファイルやディレクトリに設定される。大規模なマージでは、多数のファイルに個別の `svn:mergeinfo` が設定され、プロパティの管理が複雑化する。プロパティ自体がバージョン管理されているため、マージを重ねるごとにプロパティが肥大化し、`svn diff` の出力が `svn:mergeinfo` の変更で埋め尽くされることもあった。

第二に、そしてこれがより深刻な問題だが、リネームを含むマージは依然として問題が多かった。

### リネーム追跡の不在

Subversionの設計における最も痛い弱点の一つが、真のリネーム追跡の欠如だ。

`svn move` コマンドは、内部的には `svn copy` + `svn delete` として処理される。ファイルをリネームすると、リポジトリ内では「新しい名前でのコピー」と「古い名前での削除」の二つの操作として記録される。問題は、この二つの操作が「概念的に結びついている」という情報が、サーバに伝達されず、リポジトリにも保存されないことだ。

この設計上の限界は、マージ時に壊滅的な影響を与える。

具体例を考えよう。ブランチAで `util.c` を `helper.c` にリネームしたとする。同時期にトランクで `util.c` に新しい関数を追加したとする。ブランチAをトランクにマージしようとすると、Subversionは「ブランチAで `util.c` が削除された」という事実と、「トランクで `util.c` が変更された」という事実を見つける。`util.c` の削除が実はリネームの一部であることを、Subversionは知らない。結果として、ツリーコンフリクトが発生する。

```
ツリーコンフリクトの例:

  trunk:    util.c に関数を追加
  branch-A: util.c → helper.c にリネーム

  マージ結果:
  C  util.c     ← ツリーコンフリクト
                   （ローカルで変更済み、受信側で削除）

  Subversionの視点:
  「util.c がローカルで変更されているが、
   マージ元では削除されている。どうすべきか？」

  本来あるべき動作:
  「util.c の変更を helper.c に適用する」

  → Subversionはリネームを追跡できないため、
    この判断ができない
```

Subversion 1.6（2009年3月リリース）ではツリーコンフリクトの「検出」が改善され、コンフリクトの種類がより正確に報告されるようになった。だが、リネーム追跡そのものは実装されなかった。Apache JIRAのSVN-3630（"Rename tracking"）は長年にわたる未解決の課題であり続けた。

この問題は、「ブランチを積極的に使い、頻繁にマージする」という開発スタイルにおいて、致命的な障壁となった。Gitでは、ブランチ間でのファイルのリネームは自動的に追跡され、マージ時に適切に処理される。Gitがリネーム追跡をヒューリスティクスで実現しているのに対し、Subversionはそもそもリネームの概念を持たない。この差は、ブランチを多用する開発スタイルが主流になるにつれて、決定的な意味を持つようになった。

### オフライン作業の制約

集中型アーキテクチャに内在する制約として、オフライン作業の問題がある。

Subversionでは、`.svn` ディレクトリ内に各ファイルの「pristineコピー」（最後にサーバから取得した時点のファイル内容）が保持されている。このため、ネットワーク接続なしでも `svn status`（変更状態の確認）、`svn diff`（変更内容の差分表示）、`svn revert`（変更の取り消し）は実行できる。

だが、コミットはできない。

オフライン環境でコードを書き、ビルドし、テストし、バグを修正する——ここまでは可能だ。しかし、その変更を「記録」することはできない。コミットにはサーバへの接続が必須だ。

2005年から2010年にかけて、ソフトウェア開発の現場は変化していた。リモートワークはまだ一般的ではなかったが、出張先のホテルから、新幹線の中から、あるいは海外のカンファレンス会場から開発を続けたいという需要は確実に存在した。私自身、顧客先のネットワークからSubversionサーバにアクセスできず、丸一日の変更を帰社後にまとめてコミットした経験が何度もある。複数の論理的な変更を一つの巨大なコミットにまとめざるを得ない——これは「アトミックコミット」の理念とは正反対の事態だ。

この問題に対する回避策は存在した。SVK（Subversion上に分散型レイヤーを構築するPerlツール）や、git-svn（Gitをフロントエンドとして使い、Subversionリポジトリと同期する仕組み）が、オフラインコミットの需要に応えた。だが、これらの回避策が必要であること自体が、Subversionの集中型アーキテクチャの構造的制約を浮き彫りにしていた。

### 大規模リポジトリでの性能劣化

Subversionの性能問題は、リポジトリの規模が大きくなるほど顕在化した。

集中型アーキテクチャでは、ほとんどの操作がサーバとの通信を伴う。`svn log` でコミット履歴を確認するのも、`svn blame` で行ごとの著者を調べるのも、サーバへのリクエストが必要だ。リポジトリが大規模になり、チームの人数が増えれば、サーバへの同時リクエストが増加し、応答時間が劣化する。

チェックアウトのサイズは特に問題だった。Subversionではリポジトリ全体のチェックアウトが基本だ（Subversion 1.5で導入された疎チェックアウトは緩和策だが、Gitのsparse-checkoutほど柔軟ではない）。リポジトリに数百のモジュール、数万のファイルが含まれる場合、初回の `svn checkout` には相当な時間を要した。ネットワーク遅延が加われば、その影響は倍増する。200msのレイテンシでリモートユーザーのコミット時間が25%増加するという報告もある。

Gitとの対比は明確だ。Gitではすべての操作がローカルリポジトリに対して行われる。`git log` はローカルの `.git` ディレクトリを参照するだけであり、ネットワーク通信は発生しない。`git commit` もローカル操作だ。リモートとの同期が必要なのは `git push` と `git fetch` だけだ。この設計の違いは、日常的な操作の体感速度に圧倒的な差を生んだ。

Linus Torvaldsは2007年5月のGoogle Tech Talkで、ネットワーク遅延がVCS操作に与える影響を痛烈に指摘した。「3秒待たなければならないなら、人は操作をしなくなる」——これはユーザー体験の問題であると同時に、開発プラクティスの問題でもある。ブランチの作成やマージ、コミット履歴の確認が「一瞬」で終わるなら、開発者はこれらの操作をより頻繁に行い、より小さな単位で変更を記録するようになる。逆に、これらの操作に時間がかかるなら、開発者はそれらを避けるようになる。

Subversionの性能問題は、技術的な限界であると同時に、開発プラクティスの進化を阻害する障壁でもあった。

---

## 4. パラダイムシフト——GitHubが変えたもの

### Git単体ではなかった

Subversionの衰退を語るとき、「Gitが技術的に優れていたからSubversionは負けた」という単純な図式は、歴史を正確に反映していない。

Gitは2005年4月に誕生した。だが、Gitの初期の普及は極めて限定的だった。Linuxカーネル開発コミュニティとその周辺のハッカー文化圏では急速に受け入れられたが、一般的な開発者やエンタープライズ環境にはなかなか浸透しなかった。

理由は明確だ。Gitの初期のインターフェースは、率直に言って不親切だった。コマンド体系は複雑で、概念モデルの理解には相当な学習コストを要した。`git rebase -i` の対話的インターフェース、detached HEADの概念、staging areaの存在——これらは強力だが、CVSやSubversionの線形的なワークフローに慣れた開発者にとっては、異質なパラダイムだった。

TortoiseSVNのような洗練されたGUIクライアントも、Git側には当初は存在しなかった（TortoiseGitの初期リリースは2008年）。Eclipse統合についても、EGitとJGitがEclipseに移管されたのは2009年5月であり、Eclipse Heliosに同梱されたのは2010年6月のことだ。ツールエコシステムの成熟度において、2008年時点ではSubversionが圧倒的に優位だった。

### GitHubという触媒

2008年、GitHubが公開された。これがSubversionの運命を決定的に変えた転換点だった。

GitHubが提供したのは、Gitリポジトリのホスティングだけではない。Pull Requestモデルによるコラボレーションの仕組み、Issues/Wiki/READMEの統合、ソーシャルコーディングの概念——これらが一体となって、ソフトウェア開発の「場」を再定義した。

GitHubの功績は、「Gitを使いやすくした」ことではなく、「Gitを使う理由を作った」ことにある。オープンソースプロジェクトに参加するには、GitHubにアカウントを作り、リポジトリをforkし、変更を加えてPull Requestを送る。このワークフローは、SourceForge時代のメーリングリストベースのパッチ投稿と比較して、圧倒的にアクセスしやすかった。

結果として、オープンソースプロジェクトがGitHub上に集積していった。そこにコントリビュートするためにはGitを使う必要がある。Gitを使い始めた開発者は、ブランチ操作の軽快さやローカルコミットの便利さを体験する。そして業務プロジェクトでも「なぜGitを使わないのか」と問い始める。

「GitがSVNに勝ったのではなく、GitHubが勝った」という表現がある。これは半分は正しく、半分は正しくない。Gitの技術的優位性——軽量ブランチ、高速なマージ、オフラインコミット、完全なローカル履歴——は、GitHubが普及する前から存在していた。だが、それだけではSubversionの覇権を崩すには至らなかった。GitHubが「Gitを使う動機」を大量に供給したことで、Gitの技術的優位性が初めて大規模に認知されたのだ。

### 数字が語る逆転

Eclipse.orgでの推移が、この逆転を端的に示している。

2009年のEclipseコミュニティ調査では、SVNが58%、Gitが2%だった。2011年末、Eclipse.orgのプロジェクトにおいてGitがSVNを超えた。InfoQは「Git surpasses CVS, SVN at Eclipse.org」と報じた。SVNのリポジトリは急速に減少し、Git化されていった。

この変化の速度は注目に値する。わずか2年ほどの間に、58%の覇者がマイノリティに転落した。これは「ゆるやかな衰退」ではなく、雪崩のような転換だった。

いくつかの要因がこの急速な転換を加速した。

第一に、ネットワーク効果。プロジェクトAがGitに移行すれば、Aに依存するプロジェクトBもGitの方が都合がよくなる。この連鎖がコミュニティ全体を巻き込んだ。

第二に、人材の流動性。オープンソースプロジェクトでGitを使った開発者が、自社のプロジェクトでもGitを推し進めた。「Gitを使えること」が、採用時のスキル要件に加わり始めた。

第三に、ツールエコシステムの逆転。2010年以降、新しい開発ツールやCI/CDサービスはGitを第一級にサポートし、Subversionサポートは後回しか、あるいは最初から対象外になった。Jenkins、Travis CI、CircleCI——これらのCIサービスは、Gitリポジトリとの統合を前提に設計された。

---

## 5. 技術的敗北か、時代の変化か

### パラダイム内の卓越

前回まで見てきたように、Subversionの内部設計は卓越している。

FSFSのbubble-up方式によるストレージ効率、skip-deltaによる対数的な読み取り性能、アトミックコミットによるデータの一貫性、連番リビジョンによる人間可読な識別子——これらは、集中型VCSとしての完成度が極めて高いことを示している。

ブランチ作成のcheap copy方式も、集中型の枠内では効率的な解だった。サーバ側でのブランチ作成はリポジトリの規模に関係なく定数時間で完了する。ストレージ消費もほぼゼロだ。

マージ追跡の遅延は確かに痛手だったが、1.5で実装された `svn:mergeinfo` は、集中型アーキテクチャの制約の中で合理的な設計だった。リネーム追跡の不在は構造的な弱点だが、これもcopy+delete方式というSubversionの設計思想の帰結であり、事後的に修正することが極めて困難な類の問題だった。

Subversionは「CVSを正しくやり直す」という命題に対して、見事に解を提示した。集中型VCSの範囲内で、達成可能なほぼすべてを達成した。

### パラダイムの前提が崩れたとき

だが、Subversionが解けなかった問題がある。それは、集中型パラダイムの前提条件そのものが、2000年代後半から2010年代にかけて急速に変化したことだ。

集中型VCSの前提条件を整理しよう。

```
集中型VCSの前提:
  (1) 開発者は常時ネットワーク接続を持つ
  (2) チームは同一の組織内にいる（またはVPN等で接続される）
  (3) 開発フローは比較的線形的である（ブランチは例外的）
  (4) リポジトリのサイズは管理可能な範囲に収まる
  (5) アクセス制御は中央で管理する必要がある
```

2005年以前、これらの前提はおおむね成立していた。だが、2005年以降、状況は変わった。

前提(1)について。モバイルワーク、リモートワークの増加により、「常時ネットワーク接続」は保証されなくなった。飛行機の中で、地方の顧客先で、海外のカンファレンスで——ネットワーク接続が不安定な環境での開発は珍しくなくなった。

前提(3)について。GitHubのPull Requestモデルが示したように、「ブランチを切り、レビューを受け、マージする」という開発フローが主流になりつつあった。ブランチは「例外」ではなく「常態」になった。Subversionでもブランチは作成できたが、マージのコストが高く、ブランチを多用する開発スタイルには適していなかった。

前提(4)について。ソフトウェアプロジェクトの規模は増大し続けた。モノレポ（複数のプロジェクトを単一のリポジトリで管理する手法）が注目され、リポジトリのサイズは大規模化した。Subversionでもモノレポは可能だが、チェックアウトのサイズや、全操作がサーバを経由することによる性能問題が、スケーリングの障壁となった。

前提(2)と(5)については、依然として集中型が有利な場面がある。企業内のクローズドな開発で、厳格なアクセス制御が求められる場合、Subversionのパスベースアクセス制御は分散型VCSよりもシンプルで効果的だ。この点は次回（第11回）で詳しく論じる。

### 比較表——パラダイムの対照

以下に、Subversion黄金時代の特性とGitの設計が、前提条件の変化にどう対応したかを整理する。

```
特性                  Subversion                 Git
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ブランチ作成       cheap copy（定数時間）     ポインタ更新（41バイト）
ブランチマージ     svn:mergeinfo + 手動操作   3-way merge / recursive
リネーム追跡       なし（copy+delete）        ヒューリスティック検出
オフラインコミット 不可                       可能（ローカルリポジトリ）
履歴参照の速度     サーバ依存                 ローカル完結
識別子             連番（人間可読）           SHA-1ハッシュ（完全性保証）
アクセス制御       パスベース（柔軟）         リポジトリ単位（制限的）
学習曲線           緩やか（CVSからの自然な移行）急峻（新しい概念モデル）
```

この表が示すのは、どちらが「優れている」かではない。前提条件が変わったとき、どちらの設計がより適応的だったかだ。ネットワーク接続が不安定になり、ブランチが日常的になり、プロジェクトの規模が拡大した——この三つの変化に対して、Gitの分散型アーキテクチャは構造的に適合していた。Subversionの集中型アーキテクチャは、前提条件が成立する範囲内では卓越していたが、前提の変化には対応できなかった。

---

## 6. ハンズオン：Subversionのブランチ・マージとGitの比較体験

Subversionのブランチ・マージ操作を実際に体験し、Gitとの操作感の違いを確認しよう。特にリネームを含むマージでのツリーコンフリクトを再現する。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y subversion git
```

### 演習1：Subversionでブランチを作成し、マージする

```bash
WORKDIR="${HOME}/vcs-handson-10"
mkdir -p "${WORKDIR}"

# リポジトリの作成
svnadmin create "${WORKDIR}/svnrepo"
REPO_URL="file://${WORKDIR}/svnrepo"

# 標準ディレクトリ構造の作成
svn mkdir -m "Create standard layout" \
  "${REPO_URL}/trunk" \
  "${REPO_URL}/branches" \
  "${REPO_URL}/tags" --quiet

# trunkにファイルを追加
svn checkout "${REPO_URL}/trunk" "${WORKDIR}/svn-wc" --quiet
cd "${WORKDIR}/svn-wc"

cat > util.c << 'EOF'
#include <stdio.h>

void greet(const char *name) {
    printf("Hello, %s!\n", name);
}

int add(int a, int b) {
    return a + b;
}
EOF

cat > main.c << 'EOF'
#include <stdio.h>

extern void greet(const char *name);
extern int add(int a, int b);

int main(void) {
    greet("Subversion");
    printf("1 + 2 = %d\n", add(1, 2));
    return 0;
}
EOF

svn add util.c main.c --quiet
svn commit -m "Add initial source files" --quiet

echo "=== ブランチの作成（svn copy）==="
svn copy "${REPO_URL}/trunk" "${REPO_URL}/branches/feature-x" \
  -m "Create feature-x branch" --quiet

echo "-> ブランチ作成は定数時間（cheap copy）"
echo ""

echo "=== ブランチの作業コピーをチェックアウト ==="
svn checkout "${REPO_URL}/branches/feature-x" \
  "${WORKDIR}/svn-branch" --quiet
```

### 演習2：並行開発とマージ

```bash
echo ""
echo "=== 演習2: 並行開発とマージ ==="

# ブランチでの変更
cd "${WORKDIR}/svn-branch"
cat > util.c << 'EOF'
#include <stdio.h>
#include <string.h>

void greet(const char *name) {
    printf("Hello, %s! Welcome to branch.\n", name);
}

int add(int a, int b) {
    return a + b;
}

int multiply(int a, int b) {
    return a * b;
}
EOF
svn commit -m "Add multiply function in feature-x" --quiet

# trunkでの変更
cd "${WORKDIR}/svn-wc"
svn update --quiet
cat > main.c << 'EOF'
#include <stdio.h>

extern void greet(const char *name);
extern int add(int a, int b);

int main(void) {
    greet("Subversion user");
    printf("1 + 2 = %d\n", add(1, 2));
    printf("3 + 4 = %d\n", add(3, 4));
    return 0;
}
EOF
svn commit -m "Update main.c with additional calculation" --quiet

# trunkにブランチをマージ
echo ""
echo "--- trunkにfeature-xブランチをマージ ---"
svn update --quiet
svn merge "${REPO_URL}/branches/feature-x" --quiet
echo ""
echo "--- マージ後のsvn status ---"
svn status
echo ""
echo "--- マージで追加されたsvn:mergeinfo ---"
svn propget svn:mergeinfo .
echo ""
echo "-> svn:mergeinfo がディレクトリに設定されている"
echo "-> マージ済みリビジョンが記録されている"
svn commit -m "Merge feature-x into trunk" --quiet
```

### 演習3：リネームを含むマージ——ツリーコンフリクトの再現

```bash
echo ""
echo "=== 演習3: リネームを含むマージ（ツリーコンフリクト）==="

# 新しいブランチを作成
svn copy "${REPO_URL}/trunk" "${REPO_URL}/branches/refactor" \
  -m "Create refactor branch" --quiet
svn checkout "${REPO_URL}/branches/refactor" \
  "${WORKDIR}/svn-refactor" --quiet

# ブランチでファイルをリネーム
cd "${WORKDIR}/svn-refactor"
svn move util.c helper.c --quiet
svn commit -m "Rename util.c to helper.c" --quiet

# trunkでリネーム前のファイルを変更
cd "${WORKDIR}/svn-wc"
svn update --quiet
cat > util.c << 'EOF'
#include <stdio.h>
#include <string.h>

void greet(const char *name) {
    printf("Hello, %s! Welcome to branch.\n", name);
}

int add(int a, int b) {
    return a + b;
}

int multiply(int a, int b) {
    return a * b;
}

int subtract(int a, int b) {
    return a - b;
}
EOF
svn commit -m "Add subtract function to util.c" --quiet

# マージを試みる → ツリーコンフリクト発生
echo ""
echo "--- refactorブランチをtrunkにマージ ---"
svn update --quiet
svn merge "${REPO_URL}/branches/refactor" 2>&1 || true
echo ""
echo "--- svn status でコンフリクトを確認 ---"
svn status
echo ""
echo "-> 'C' はコンフリクト、ツリーコンフリクトが発生している"
echo "-> Subversionはリネームを追跡できないため、"
echo "   util.cの変更とhelper.cへのリネームを自動的に統合できない"
echo ""
echo "--- コンフリクトを解消してクリーンな状態に戻す ---"
svn revert -R . --quiet 2>/dev/null || true
```

### 演習4：同じシナリオをGitで実行する

```bash
echo ""
echo "=== 演習4: 同じシナリオをGitで実行 ==="

mkdir -p "${WORKDIR}/gitrepo"
cd "${WORKDIR}/gitrepo"
git init --quiet

# 初期ファイルの作成
cat > util.c << 'EOF'
#include <stdio.h>
#include <string.h>

void greet(const char *name) {
    printf("Hello, %s! Welcome to branch.\n", name);
}

int add(int a, int b) {
    return a + b;
}

int multiply(int a, int b) {
    return a * b;
}
EOF

cat > main.c << 'EOF'
#include <stdio.h>

extern void greet(const char *name);
extern int add(int a, int b);

int main(void) {
    greet("Git user");
    printf("1 + 2 = %d\n", add(1, 2));
    return 0;
}
EOF

git add util.c main.c
git commit -m "Initial commit" --quiet

# ブランチでファイルをリネーム
git checkout -b refactor --quiet
git mv util.c helper.c
git commit -m "Rename util.c to helper.c" --quiet

# mainブランチでリネーム前のファイルを変更
git checkout main --quiet 2>/dev/null || git checkout master --quiet 2>/dev/null
cat > util.c << 'EOF'
#include <stdio.h>
#include <string.h>

void greet(const char *name) {
    printf("Hello, %s! Welcome to branch.\n", name);
}

int add(int a, int b) {
    return a + b;
}

int multiply(int a, int b) {
    return a * b;
}

int subtract(int a, int b) {
    return a - b;
}
EOF
git add util.c
git commit -m "Add subtract function to util.c" --quiet

# マージ
echo "--- refactorブランチをmainにマージ ---"
git merge refactor --no-edit 2>&1 || true
echo ""
echo "--- git status ---"
git status
echo ""
echo "--- マージ結果の確認 ---"
if [ -f helper.c ]; then
  echo "helper.c が存在する（リネームが追跡された）"
  echo ""
  echo "--- helper.c の内容 ---"
  cat helper.c
  echo ""
  echo "-> Gitはリネームをヒューリスティックに検出し、"
  echo "   util.cへの変更をhelper.cに自動的に適用した"
else
  echo "コンフリクトが発生（内容の差が大きい場合）"
fi
```

### 演習で見えたこと

四つの演習を通じて、SubversionとGitのブランチ・マージ操作の違いを体験した。

通常のマージは、Subversionでも問題なく動作する。`svn:mergeinfo` により、マージ済みリビジョンが自動的に追跡され、再マージの問題は回避される。1.5以前のSubversionや、CVSの手動マージ管理と比較すれば、大きな進歩だ。

だが、リネームを含むマージで差が露呈する。Subversionはcopy+delete方式のためリネームを追跡できず、ツリーコンフリクトが発生する。Gitはヒューリスティックなリネーム検出により、多くの場合、リネームされたファイルへの変更を自動的に適用できる。

この差は、「ブランチを切り、リファクタリングし、マージする」という現代的な開発フローにおいて決定的だ。リファクタリングにはファイルのリネームが伴うことが多い。それが自動的にマージされるか、手動で解決しなければならないかは、開発者の生産性に直接影響する。

---

## 7. まとめと次回予告

### この回の要点

第一に、Subversionは2005年から2010年にかけて、企業の開発現場のデファクトスタンダードだった。2009年のEclipseコミュニティ調査ではSVNが58%のシェアを占め、Gitはわずか2%に過ぎなかった。TortoiseSVN、Eclipse統合（Subclipse/Subversive）、Visual Studio統合（AnkhSVN/VisualSVN）という充実したツールエコシステムが、この普及を支えた。

第二に、Subversionの構造的弱点が黄金時代の裏側に存在していた。マージ追跡機能（`svn:mergeinfo`）の実装は1.5（2008年）まで遅延し、その後もリネーム追跡の不在がマージ時のツリーコンフリクトの原因となり続けた。`svn move` がcopy+deleteとして処理される設計は、事後的な修正が極めて困難な構造的問題だった。

第三に、オフライン作業の制約と大規模リポジトリでの性能劣化は、集中型アーキテクチャに内在する構造的な限界だった。これらの問題は、リモートワークの増加、ブランチ多用の開発スタイル、プロジェクトの大規模化という時代の変化に対して、Subversionの適応力を制約した。

第四に、GitHubの登場（2008年）が転換点となった。「GitがSVNに勝った」というよりも、「GitHubがソフトウェア開発の場を再定義した」と言うほうが正確だ。GitHubがGitを使う動機を大量に供給したことで、Gitの技術的優位性が広く認知され、2011年にはEclipse.orgでGitがSVNを逆転した。

第五に、Subversionの「敗北」は技術的な劣位によるものではなく、パラダイムの前提条件が変化したことによるものだ。集中型VCSとしてのSubversionの設計品質は卓越していた。だが、ネットワーク接続の不安定化、ブランチの日常化、プロジェクトの大規模化という変化に対して、集中型というパラダイムそのものが適合しなくなった。

### 冒頭の問いへの暫定回答

Subversionはなぜ「勝てなかった」のか。

端的に言えば、Subversionは「集中型VCSを極めた」が、時代が「分散型VCS」を求めるようになったからだ。これは技術の優劣の問題ではなく、前提条件の変化の問題だ。

だが、ここで安易な結論に飛びつくべきではない。「分散型が常に集中型に優る」という命題は正しくない。集中型の前提条件が成立する環境——厳格なアクセス制御が必要な企業内開発、巨大バイナリを扱うプロジェクト、ネットワーク接続が安定した同一拠点のチーム——では、Subversionは今なお合理的な選択でありうる。

重要なのは、「なぜそのツールを使うのか」を理解することだ。前提条件を知らずにツールを選ぶ人間は、前提条件が変わったときに対応できない。

### 次回予告

次回は、Subversionの「現在」を追う。

**第11回「Subversionは死んだのか？——今なお現役の理由」**

Gitが圧倒的な覇権を握った2020年代においても、Subversionを使い続けている現場は存在する。ゲーム開発の巨大バイナリ管理、医療機器や航空宇宙の規制産業、パスベースのアクセス制御が不可欠な企業——これらの現場では、Subversionが提供する「集中型ならではの利点」が、Gitの分散型の利点を上回る場合がある。

Subversionは本当に「死んだ」のか。それとも、特定の問題空間において今なお最適解であり続けているのか。「全部git」という思考停止から一歩退いて、ツール選定の本質を考えてみよう。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Apache Subversion, "Release History." <https://subversion.apache.org/docs/release-notes/release-history.html>
- Apache Subversion, "Subversion 1.5 Release Notes." <https://subversion.apache.org/docs/release-notes/1.5.html>
- Apache Subversion Blog, "Subversion 1.5 Mergeinfo - Understanding the Internals." (2008年5月) <https://subversion.apache.org/blog/2008-05-06-merge-info.html>
- Collins-Sussman, B., Fitzpatrick, B.W. & Pilato, C.M., "Version Control with Subversion (SVN Book)." <https://svnbook.red-bean.com/>
- SVN Book, "Basic Merging." <https://svnbook.red-bean.com/en/1.7/svn.branchmerge.basicmerging.html>
- SVN Book, "Dealing with Structural Conflicts." <https://svnbook.red-bean.com/en/1.6/svn.tour.treeconflicts.html>
- Wright, H.K. & Perry, D.E., "Subversion 1.5: A Case Study in Open Source Release Mismanagement." FLOSS 2009. <https://www.hyrumwright.org/papers/floss2009.pdf>
- Apache JIRA, "SVN-3630: Rename tracking." <https://issues.apache.org/jira/browse/SVN-3630>
- TortoiseSVN, "About." <https://tortoisesvn.net/about.html>
- InfoQ, "Git surpasses CVS, SVN at Eclipse.org." (2011年12月) <https://www.infoq.com/news/2011/12/eclipse-git/>
- Stack Overflow Blog, "Beyond Git: The other version control systems developers use." (2023年1月) <https://stackoverflow.blog/2023/01/09/beyond-git-the-other-version-control-systems-developers-use/>
- LinusTalk200705Transcript, Git SCM Wiki. <https://git.wiki.kernel.org/index.php/LinusTalk200705Transcript>
