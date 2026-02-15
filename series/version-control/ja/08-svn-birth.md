# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第8回：Subversionの誕生——"CVS done right"

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- Subversionが生まれた経緯——CollabNet、Karl Fogel、Jim Blandy、Ben Collins-Sussmanの役割
- CVSの具体的な欠陥とSubversionが「正しくやり直した」設計判断
- アトミックコミット、ディレクトリバージョニング、リネーム対応の技術的意義
- Subversionのリビジョン番号設計——なぜ連番が合理的だったのか
- Apache/WebDAV（mod_dav_svn）とsvnserveの二つのネットワークアーキテクチャ
- FSFS vs Berkeley DB——リポジトリバックエンドの進化
- Subversionサーバの構築と基本操作のハンズオン

---

## 1. 「全部、正しく作り直してくれ」

2006年の初夏だったと思う。私はある受託開発の現場で、CVSからSubversionへの移行作業をしていた。

移行自体は `cvs2svn` というツールを使えば、それほど難しい作業ではなかった。CVSリポジトリのRCSファイル群を読み取り、Subversionのリポジトリに変換する。コミット履歴も、タグも、ブランチも——可能な限り保持される。だが、私が覚えているのはツールの使い方ではない。移行後に初めて `svn commit` を実行した瞬間の感覚だ。

5つのファイルを同時に変更し、コミットした。Subversionは「Committed revision 1.」と返した。リビジョン1。たった一つの数字が、5つのファイルの変更をまとめて表している。

CVSでは、こうはいかなかった。5つのファイルをコミットすると、それぞれのファイルが独立にリビジョン番号を進める。`main.c` が 1.15 になり、`util.h` が 1.8 になり、`Makefile` が 1.22 になる。「この5つの変更は一つの論理的な単位だ」ということを、CVSのリビジョン番号は表現できなかった。同じコミットメッセージが5つのファイルに個別に記録されるだけだ。

Subversionでは違った。リビジョン1は、リポジトリ全体のスナップショットだ。その時点で何がどう変わったかが、一つの番号で完全に特定できる。

次に、私はディレクトリを作成した。`mkdir src/utils` に相当する操作をSubversionで行い、コミットした。「Committed revision 2.」CVSでは、ディレクトリの作成はバージョン管理の対象外だった。空のディレクトリを追加しても、CVSリポジトリには何も記録されない。ディレクトリの存在自体が、履歴の外にあった。

さらに、ファイルのリネーム。`svn move old_name.c new_name.c` を実行すると、Subversionは「このファイルは old_name.c からリネームされたものだ」という情報を記録した。CVSでは、リネームは「旧ファイルの削除 + 新ファイルの追加」としてしか表現できず、履歴の連続性が断たれた。

アトミックコミット。ディレクトリのバージョニング。リネームの追跡。どれもCVSで「あれば良いのに」と思っていた機能ばかりだった。

私はSubversionのコミットログを眺めながら思った。これは「新しいツール」ではない。CVSの「あるべき姿」だ。CVSが最初からこうあるべきだった形を、誰かが正しく作り直したのだ。

その「誰か」とは何者だったのか。そして「正しく作り直す」とは、具体的に何を意味していたのか。

---

## 2. CVSを知り尽くした者たち——Subversionの誕生

### CollabNetの呼びかけ

2000年2月。カリフォルニアに本社を置くCollabNet社が、一人の開発者に連絡を取った。Karl Fogelである。

CollabNetは1999年にTim O'Reilly、Brian Behlendorf、Bill Portelliによって設立された企業だ。Brian BehlendorfはApache HTTP Serverの主要開発者であり、Apache Software Foundationの創設メンバーでもあった。CollabNetの事業は、分散した開発チームのためのコラボレーションツールの提供だった。そのCollabNetが、CVSの後継となるオープンソースのバージョン管理システムを作りたいと考えていた。

なぜKarl Fogelだったのか。Fogelは1999年に『Open Source Development with CVS』（Coriolis OpenPress）を出版していた。CVSの内部構造と運用を網羅した専門書であり、当時のCVSコミュニティにおける最も体系的な文献の一つだった。CVSの専門書を書いた人間ほど、CVSの長所と限界を深く理解している者はいない。

しかし話はそこで終わらない。CollabNetがFogelに連絡を取ったとき、Fogelはまさにその瞬間、友人のJim Blandyと新しいバージョン管理システムの設計を議論していた。偶然の一致というにはあまりにもタイミングが良い。だが、考えてみれば不思議ではない。2000年という時点で、CVSの限界は広く認識されていた。CVSを深く知る者であれば、「次」を考えるのは自然なことだった。

### Jim Blandy——名前と設計の原点

Jim Blandyという名前は、Subversionの歴史においてもっと語られるべきだ。

Blandyは「Subversion」という名前の考案者であり、データストアの基本設計を構想した人物である。CVSへの不満——ファイル単位でしか履歴を管理できないこと、ディレクトリの変更を追跡できないこと、アトミックなコミットができないこと——が、彼を新しいバージョン管理システムの設計へと駆り立てた。

BlandyとFogelの関係は、CVSの歴史そのものと重なっている。二人は1995年にCyclic Softwareを共同創設した。CVSに対する商用サポートを提供した最初の企業だ。1997年にはFogelがCVSに匿名リードオンリーリポジトリアクセスのサポートを追加している。つまり、CVSのエコシステムを技術的に支え、拡張してきた当事者たちが、CVSの限界を最も正確に認識し、その後継を設計したのである。

CollabNetからの依頼を受けたFogelは即座に承諾した。BlandyはRed Hat Software（当時の雇用主）から、事実上無期限でこのプロジェクトに参加する許可を得た。Red HatがBlandyをSubversionプロジェクトに「寄贈」したのだ。オープンソースの世界では、企業が開発者の労働力を他のOSSプロジェクトに提供するという形態が珍しくなかった。

### Ben Collins-Sussman——開発の推進力

CollabNetはKarl Fogelに加え、Ben Collins-Sussmanを雇用した。Collins-SussmanはSubversionのコア開発を推進し、後にSVN BookこことVersion Control with Subversion（通称「SVN Book」）の共著者となる。

2000年5月、詳細設計が開始された。目標は明確だった。CVSと同じ操作感を維持しながら、CVSの既知の欠陥をすべて修正すること。SVN BookはSubversionの設計目標を次のように記している——CVSの上位互換として機能するバージョン管理システムを構築し、CVSの弱点を修正しつつ、CVSユーザーが違和感なく移行できるようにする。

「CVSを正しくやり直す」——"CVS done right"。この言葉がSubversionのコミュニティで自然に広まっていった。公式なスローガンではなかったが、プロジェクトの本質を的確に表現していた。

### セルフホスティングへの道

開発の進捗は、三つのマイルストーンで追跡できる。

2000年10月20日、Milestone 1が達成された。基本的な作業コピーの操作が実装され、XMLファイルを使ったcheckout、update、commitが可能になった。まだ実用的なものではなかったが、アーキテクチャの骨格が形になった瞬間だった。

2001年5月15日、Milestone 2。WebDAVレイヤーを介したcheckout、update、commitが動作するようになった。ネットワーク越しのバージョン管理——SubversionがCVSの後継たる所以の機能が実現した。

そして2001年8月30日、Milestone 3。開発開始から14ヶ月。Subversionはセルフホスティングを達成した。これは技術的に極めて重要なマイルストーンだ。Subversionの開発チームはCVSの使用を停止し、Subversion自身のソースコードをSubversionで管理し始めた。自分たちのツールが、自分たちの開発ワークフローを支えるに足る品質に達したということだ。

ここから2年半の安定化と機能追加を経て、2004年2月23日、Subversion 1.0が正式にリリースされた。CVSの後継としての約束を果たす準備が整った。

---

## 3. CVSの何を「正しく」したのか——Subversionの設計思想

### アトミックコミット——「半分だけコミット」の恐怖の終焉

CVSの最も深刻な欠陥の一つは、コミットがアトミックでなかったことだ。

CVSのコミットは、ファイル単位で個別に処理される。10個のファイルを一度にコミットすると、CVSは内部的に10回の独立した更新を中央リポジトリに対して行う。もし5個目のファイルの更新中にネットワーク障害が発生したら、どうなるか。

5個のファイルは新しいリビジョンでコミットされ、残りの5個は古いリビジョンのままだ。リポジトリは「半分だけ更新された」不整合な状態になる。CVSにはこの中間状態を自動的に検出し、ロールバックする仕組みがなかった。開発者が手動で気づき、残りのファイルを再度コミットするしかない。

Subversionは、この問題をアーキテクチャの根幹から解決した。Subversionのコミットは、リポジトリに対するアトミックトランザクションとして実装されている。「アトミック」とは、すべての変更が適用されるか、まったく適用されないかのどちらかであることを意味する。プログラムのクラッシュ、システムのクラッシュ、ネットワーク障害、他のユーザーの操作——何が起きても、リポジトリは整合性のある状態を維持する。

この設計判断の帰結として、Subversionではコミットごとにリポジトリ全体で一意のリビジョン番号が割り当てられる。CVSではファイルごとに独立したリビジョン番号（`main.c` は 1.15、`util.h` は 1.8）だったが、Subversionではコミット操作全体が一つのリビジョン（例えばリビジョン234）として記録される。

```
CVSのコミット（非アトミック）:
  main.c:  1.14 → 1.15  ← 個別に成功
  util.h:  1.7  → 1.8   ← 個別に成功
  config.h: 1.3  → 1.4   ← ここでネットワーク障害 → 未更新のまま
  Makefile: 1.21 → ???   ← コミットされず

  → リポジトリが不整合な状態に

Subversionのコミット（アトミック）:
  main.c, util.h, config.h, Makefile
  → トランザクション開始
  → すべての変更を準備
  → 全て成功 → リビジョン 234 として確定
  → 途中で失敗 → 全変更がロールバック → リポジトリは変更前の状態
```

### ディレクトリのバージョニング——構造の変化を記録する

CVSはファイルの内容の変更を追跡したが、ディレクトリの構造変更は追跡しなかった。ディレクトリの追加、削除、移動はCVSの管理対象外だった。

これは日常的な開発で問題を引き起こした。プロジェクトの構造をリファクタリングし、ソースファイルをサブディレクトリに整理するような作業は、CVSでは履歴を破壊する行為だった。新しいディレクトリ構造にファイルをコピーすると、そのファイルの過去の履歴はコピー元に残り、コピー先では「新しいファイル」として扱われる。

Subversionは、ファイルだけでなくディレクトリ、コピー、リネーム、削除と復活もバージョン管理の対象とした。ディレクトリツリーの変更を記録する——これがSubversionの根本的な設計思想だ。

ファイルの移動やリネームも追跡される。`svn move old_name.c new_name.c` を実行すると、Subversionは「new_name.c は old_name.c の名前が変わったものである」という情報を履歴に記録する。`svn log new_name.c` を実行すれば、リネーム前の old_name.c 時代の履歴も遡ることができる。

ただし、注意が必要な点がある。Subversionのリネーム対応は、内部的には「コピー＋削除」として実装されている。完全な「移動追跡」ではなく、あくまで「コピー元の情報を保持したコピー操作」と「元ファイルの削除」の組み合わせだ。この実装上の制約は、後にマージ操作において問題を引き起こすことがある。だが、CVSがリネームをまったく追跡できなかったことと比較すれば、大きな前進だった。

### リビジョン番号の設計——人間が理解できる識別子

Subversionのリビジョン番号設計は、集中型VCSの利点を最大限に活かしたものだ。

各リビジョンには一意の自然数が割り当てられる。最初のリビジョンはゼロ（空のルートディレクトリのみ）で、コミットのたびに1ずつ増加する。リビジョン234は、リポジトリのツリー全体のある一時点のスナップショットだ。

この設計が可能なのは、Subversionが集中型だからだ。すべてのコミットは中央サーバを経由する。中央サーバがリビジョン番号を一元的に割り振るため、番号の衝突は原理的に発生しない。分散型VCSでは、各開発者がローカルで独立にコミットするため、連番リビジョンは実現できない。これがgitがSHA-1（後にSHA-256）ハッシュをコミット識別子として採用した理由だ。

連番リビジョンの実用上の利点は大きかった。「リビジョン234を見てくれ」と言えば、チーム全員にとって同じ意味を持つ。`svn log -r 234` で正確にその時点の変更を参照できる。`svn diff -r 200:234` で、リビジョン200から234までの差分を取得できる。人間が覚えやすく、会話の中で使いやすい識別子だった。

`a3f2e1b` のような40文字のハッシュ値と比較すれば、連番リビジョンの人間工学的な優位性は明白だ（gitでは先頭7文字程度の短縮形が使われるが、大規模リポジトリでは衝突の可能性がある）。

### ネットワークアーキテクチャ——二つの選択肢

Subversionは、ネットワーク越しのリポジトリアクセスに二つのアーキテクチャを提供した。

**Apache httpd + mod_dav_svn**

Subversionの設計者がネットワークサーバとしてApache httpdを選んだのは、自然な判断だった。CollabNetの共同創設者Brian BehlendorfはApache httpd の主要開発者であり、Apache Software Foundationの創設メンバーだ。Apacheにはすでに WebDAV（Web Distributed Authoring and Versioning）モジュールが存在していた。

WebDAVはHTTPを拡張し、Webサーバ上のファイルの読み書きを可能にするプロトコルだ。さらにDeltaV（RFC 3253、2002年）はWebDAVにバージョン管理の概念を追加した。Subversionはmod_dav_svnモジュールを通じて、このWebDAV/DeltaVプロトコル上でバージョン管理操作を実現した。

HTTP/HTTPSという既知のプロトコルを使うことには、実用上の大きな利点があった。ファイアウォールはHTTPのポート80やHTTPSのポート443を通常許可している。新たにカスタムポートを開ける必要がない。プロキシサーバ経由のアクセスも可能だ。SSLによる暗号化もApacheの既存の仕組みをそのまま利用できる。

ただし、Subversionの設計者は当初DeltaVの完全な実装を目指していたが、DeltaVのバージョン管理モデルとSubversionのモデルには齟齬があり、最終的に完全準拠は断念された。Subversionは独自のHTTPベースプロトコルへと進化していった。

**svnserve——軽量な代替**

もう一つのアーキテクチャは、svnserveと呼ばれるスタンドアロンのサーバプロセスだ。svnserveはカスタムプロトコルを使い、`svn://` スキームでアクセスする。Apacheのような大規模なWebサーバを必要とせず、設定が簡単で、小規模なプロジェクトには十分な選択肢だった。SSH経由のトンネリング（`svn+ssh://`）もサポートされ、既存のSSHインフラを認証に利用できた。

```
Subversionのネットワークアーキテクチャ:

  クライアント (svn)
       |
       ├──── HTTP/HTTPS ──→ Apache httpd + mod_dav_svn
       |                         |
       |                         ├── SSL/TLS暗号化
       |                         ├── LDAP/SASL認証統合
       |                         ├── パスベースアクセス制御
       |                         └── WebDAV/DeltaVプロトコル
       |
       ├──── svn:// ─────→ svnserve
       |                         |
       |                         ├── CRAM-MD5認証
       |                         └── 軽量・高速
       |
       └──── svn+ssh:// ──→ SSH + svnserve
                                 |
                                 ├── SSH認証
                                 └── 暗号化通信
```

Apache構成は、企業環境での利用に適していた。既存のApacheインフラ、LDAP認証、パスベースのアクセス制御を活用できる。svnserve構成は、個人プロジェクトや小規模チームでの利用に適していた。この二択を提供したことで、Subversionは小規模から大規模まで幅広い環境に対応できた。

### FSFS vs Berkeley DB——リポジトリの心臓部

リポジトリのストレージバックエンドにおいて、Subversionは重要な設計変遷を経験した。

Subversionの初期設計では、Berkeley DB（BDB）が唯一のストレージバックエンドとして選ばれた。選定理由は合理的だった。オープンソースライセンス、トランザクションのサポート、高い信頼性、十分なパフォーマンス、シンプルなAPI。データベースエンジンとして成熟した選択肢であり、アトミックトランザクションの実装に適していた。

しかし、BDBには運用上の問題があった。プロセスがクラッシュした場合にリポジトリのリカバリが必要になることがあった。BDBのデータファイルは不透明なバイナリ形式であり、問題が発生したときにリポジトリの内部状態を直接確認することが困難だった。バックアップにも注意が必要で、単純なファイルコピーでは整合性が保証されなかった。

2004年9月、Subversion 1.1のリリースとともに、新しいストレージバックエンドが導入された。FSFS——"Filesystem on top of Filesystem"。名前が示すとおり、FSFSはバージョン管理されたファイルシステムをOSのファイルシステム上に直接構築する。リポジトリのデータは通常のファイルとディレクトリとして保存され、BDBのような不透明なデータベースコンテナを介さない。

FSFSの利点は明確だった。ファイルが透過的であるため、管理者がリポジトリの内部状態を直接確認できる。バックアップは単純なファイルコピーで済む。プロセスクラッシュに対する耐性が高い。大量のファイルを含むディレクトリでのパフォーマンスがBDBより優れている。ディスク使用量も少ない。

FSFSの導入は成功だった。Subversion 1.2では、新規リポジトリ作成時のデフォルトバックエンドがBDBからFSFSに変更された。Subversion 1.8では、BDBが公式に非推奨となった。FSFSはSubversionのストレージ層として決定的な勝利を収めた。

```
Berkeley DB (BDB) バックエンド:
  リポジトリ/
  └── db/
      ├── __db.001       ← 不透明なバイナリファイル
      ├── __db.002
      ├── log.0000000001 ← BDBトランザクションログ
      └── ...

FSFS バックエンド:
  リポジトリ/
  └── db/
      ├── revs/
      │   ├── 0/
      │   │   ├── 0      ← リビジョン0のデータ（テキスト）
      │   │   ├── 1      ← リビジョン1のデータ（テキスト）
      │   │   └── ...
      ├── revprops/
      │   ├── 0/
      │   │   ├── 0      ← リビジョン0のプロパティ
      │   │   └── ...
      ├── txn-protorevs/ ← 進行中のトランザクション
      └── current        ← 最新リビジョン番号
```

### ブランチとタグ——ディレクトリコピーという設計

Subversionのブランチとタグの実装は、CVSとは根本的に異なるアプローチを取った。

CVSでは、ブランチはRCSファイルのリビジョンツリーに枝を生やす操作であり、タグはリビジョン番号に名前を付ける操作だった。ブランチとタグは「バージョン管理システムの特別な操作」として存在していた。

Subversionには、ブランチやタグのための専用コマンドがない。代わりに、ディレクトリのコピー操作——`svn copy`——がブランチとタグの両方を実現する。

```bash
# ブランチの作成
svn copy http://svn.example.com/repos/trunk \
         http://svn.example.com/repos/branches/feature-x \
         -m "Create feature-x branch"

# タグの作成
svn copy http://svn.example.com/repos/trunk \
         http://svn.example.com/repos/tags/release-1.0 \
         -m "Tag release 1.0"
```

この設計のエレガンスは、内部実装にある。`svn copy` は「cheap copy（安価なコピー）」として実装されている。UNIXのハードリンクに似た仕組みで、コピー元のデータを物理的に複製するのではなく、内部的なリンクを作成するだけだ。100MBのディレクトリをコピーしても、消費されるストレージはほぼゼロ。リビジョン番号が一つ進むだけだ。

慣習として、Subversionのリポジトリには `/trunk`（メインの開発ライン）、`/branches`（ブランチ群）、`/tags`（タグ群）という三つのトップレベルディレクトリが設けられた。これはSubversionが強制するものではなく、コミュニティが確立した規約だ。技術的にはどのディレクトリ構造でも動作する。

ただし、ブランチがディレクトリコピーであるという設計には、重要な帰結があった。Subversionのツールは、あるディレクトリが「ブランチである」ことを構造的に知らない。/branches 配下にあるから「ブランチだろう」と推測するだけだ。この曖昧さは、後にマージ追跡（merge tracking）の実装を困難にした。Subversion 1.5（2008年）でマージ追跡が導入されるまで、「どのブランチからどの変更がマージ済みか」を追跡する仕組みはSubversionに存在しなかった。

---

## 4. 「正しくやり直す」の射程と限界

Subversionの設計目標は「CVSの上位互換」だった。この目標は、強力な推進力を与えると同時に、根本的な制約をも内包していた。

CVSの上位互換であるということは、CVSのユーザーが違和感なく移行できることを意味する。コマンド体系は意識的にCVSと似せて設計された。`cvs checkout` は `svn checkout` に、`cvs commit` は `svn commit` に、`cvs update` は `svn update` に対応する。CVSユーザーにとっての学習コストを最小化するという判断だ。

だが、「CVSを正しくやり直す」という目標設定は、CVSのパラダイム——集中型クライアント・サーバモデル——を前提として受け入れることを意味した。中央サーバがリポジトリを保持し、クライアントは作業コピーを持つ。オフラインではコミットもログの参照もできない。この前提は、2000年時点では合理的だった。前回検証したとおり、集中型VCSの設計は当時の技術的制約と組織構造に整合していた。

しかし、Subversionの開発が進む2000年代前半、世界は変わり始めていた。

オープンソース開発がグローバル化し、異なるタイムゾーンの開発者が同じプロジェクトに参加するようになった。ノートPCが普及し、移動中やオフラインでの開発が現実的な需要になった。Linuxカーネルの開発では、BitKeeperという分散型VCSがすでに使われていた（この話は後の回で詳しく取り上げる）。

Subversionが「CVSを正しくやり直す」ことに集中している間に、バージョン管理の世界は「集中型 vs 分散型」というパラダイムレベルの問いに直面し始めていたのだ。

Linus Torvaldsは後にこう述べたとされる——「Subversionは"CVS done right"を掲げた。だが、CVSを正しくやるという目標設定それ自体に限界がある」。この批判の意味は、連載の後半で分散型VCSを扱う際に改めて検討する。

今の段階では、一つの事実を確認しておこう。Subversionは、自らが設定した目標——CVSの欠陥を修正し、CVSの上位互換として機能する集中型VCSを構築する——を、ほぼ完全に達成した。アトミックコミット、ディレクトリバージョニング、リネーム対応、連番リビジョン、柔軟なネットワークアーキテクチャ。CVSで「できなかったこと」の大部分が、Subversionでは「できるようになった」。

その達成が「十分」だったかどうかは、次の問い——つまり「何が十分なのか」——に依存する。

---

## 5. ハンズオン：Subversionサーバの構築と基本操作

Subversionの設計思想を、実際に手を動かして確認しよう。CVSとの違いを体験することで、「正しくやり直した」ことの意味が具体的に見えてくる。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y subversion
```

### 演習1：リポジトリの作成とアトミックコミット

```bash
WORKDIR="${HOME}/vcs-handson-08"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# SVNリポジトリの作成（FSFSバックエンド）
svnadmin create "${WORKDIR}/myrepo"

echo "=== リポジトリが作成された ==="
echo "バックエンド: $(cat ${WORKDIR}/myrepo/db/fs-type)"
ls "${WORKDIR}/myrepo/"
```

`svnadmin create` は FSFS バックエンドでリポジトリを作成する（Subversion 1.2以降のデフォルト）。`db/fs-type` ファイルにバックエンドの種類が記録されている。

```bash
# 作業コピーのチェックアウト
svn checkout "file://${WORKDIR}/myrepo" "${WORKDIR}/wc"
cd "${WORKDIR}/wc"

# ディレクトリ構造の作成
svn mkdir trunk branches tags
svn commit -m "Create standard directory layout"

echo ""
echo "=== リビジョン1: 標準ディレクトリ構造 ==="
svn log -r 1
```

最初のコミットでリビジョン1が作成される。ディレクトリの作成がバージョン管理されていることに注目してほしい。CVSではディレクトリの作成は履歴に記録されなかった。

```bash
# 複数ファイルのアトミックコミット
cat > trunk/main.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"

int main(void) {
    printf("%s version %s\n", APP_NAME, APP_VERSION);
    return 0;
}
SRCEOF

cat > trunk/config.h << 'SRCEOF'
#ifndef CONFIG_H
#define CONFIG_H
#define APP_NAME "SVN Demo"
#define APP_VERSION "1.0"
#endif
SRCEOF

cat > trunk/Makefile << 'SRCEOF'
CC = gcc
CFLAGS = -Wall -I.

app: main.c config.h
    $(CC) $(CFLAGS) -o app main.c

clean:
    rm -f app
SRCEOF

svn add trunk/main.c trunk/config.h trunk/Makefile
svn commit -m "Add initial source code: main.c, config.h, Makefile"

echo ""
echo "=== リビジョン2: 3つのファイルが一つのリビジョン ==="
svn log -r 2 -v
```

3つのファイルの追加が、リビジョン2として一つのアトミックな操作で記録される。`svn log -v` の `-v` オプションで、そのリビジョンで変更されたファイルの一覧が表示される。

### 演習2：リネームの追跡

```bash
echo ""
echo "=== 演習2: リネームの追跡 ==="

# ファイルのリネーム
svn move trunk/main.c trunk/app.c
svn commit -m "Rename main.c to app.c"

echo ""
echo "--- リネーム後のログ ---"
svn log -v -r 3

echo ""
echo "--- app.c の履歴（リネーム前を含む）---"
svn log trunk/app.c

echo ""
echo "-> app.c の履歴を遡ると、main.c だった頃の"
echo "   コミット（リビジョン2）も表示されます"
echo "-> CVSでは、リネームすると履歴が断絶しました"
```

### 演習3：cheap copy によるブランチとタグ

```bash
echo ""
echo "=== 演習3: ブランチとタグ ==="

# タグの作成
svn copy trunk tags/release-1.0 -m "Tag release 1.0" 2>/dev/null
svn commit -m "Tag release 1.0"

# ブランチの作成
svn copy trunk branches/feature-new-output -m "Create feature branch" 2>/dev/null
svn commit -m "Create feature branch"

echo ""
echo "--- ブランチでの作業 ---"
cd "${WORKDIR}/wc"

# ブランチ上でファイルを変更
cat > branches/feature-new-output/app.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"

int main(void) {
    printf("=== %s ===\n", APP_NAME);
    printf("Version: %s\n", APP_VERSION);
    printf("Build date: %s\n", __DATE__);
    return 0;
}
SRCEOF

svn commit -m "Enhanced output format in feature branch"

echo ""
echo "--- リポジトリの構造 ---"
svn list -R "file://${WORKDIR}/myrepo" | head -20

echo ""
echo "--- trunkは変更されていないことを確認 ---"
cat trunk/app.c

echo ""
echo "-> ブランチでの変更はtrunkに影響しません"
echo "-> タグは作成時点のスナップショットとして保存されています"
```

### 演習4：リビジョン番号の力

```bash
echo ""
echo "=== 演習4: リビジョン番号の力 ==="

echo "--- 全リビジョンの一覧 ---"
svn log -q "file://${WORKDIR}/myrepo"

echo ""
echo "--- リビジョン2とリビジョン6の差分 ---"
svn diff -r 2:6 trunk/app.c 2>/dev/null || svn diff -r 2:HEAD trunk/app.c

echo ""
echo "--- リビジョン2時点のファイル内容 ---"
svn cat -r 2 "file://${WORKDIR}/myrepo/trunk/main.c"

echo ""
echo "-> リビジョン番号は人間が理解しやすい識別子です"
echo "-> 「リビジョン2を見てくれ」と言えば、全員が同じ状態を参照できます"
echo "-> これは集中型VCSだからこそ可能な設計です"
```

### 演習5：リポジトリの内部構造を覗く

```bash
echo ""
echo "=== 演習5: FSFSリポジトリの内部構造 ==="

echo "--- リポジトリのディレクトリ構造 ---"
ls -la "${WORKDIR}/myrepo/db/"

echo ""
echo "--- 現在のリビジョン番号 ---"
cat "${WORKDIR}/myrepo/db/current"

echo ""
echo "--- リビジョンファイルの一覧 ---"
ls -la "${WORKDIR}/myrepo/db/revs/0/"

echo ""
echo "--- リビジョン0（初期状態）の内容 ---"
cat "${WORKDIR}/myrepo/db/revs/0/0"

echo ""
echo "--- リビジョンプロパティ（コミットメッセージ等）---"
cat "${WORKDIR}/myrepo/db/revprops/0/1"

echo ""
echo "-> FSFSのリポジトリは通常のファイルとして保存されています"
echo "-> BDBのような不透明なデータベースではなく、直接中身を確認できます"
echo "-> バックアップは単純なファイルコピーで可能です"
```

### 演習で見えたこと

五つの演習を通じて、Subversionが「CVSを正しくやり直した」ことの具体的な内容を体験した。

アトミックコミットにより、複数ファイルの変更が一つのリビジョンとして記録される。ディレクトリの作成やファイルのリネームがバージョン管理の対象になる。cheap copy によるブランチとタグの作成は、ストレージ効率に優れている。連番リビジョンは、人間にとって扱いやすい識別子だ。FSFSバックエンドは、リポジトリの内部を透過的に確認できる。

これらのすべてが、CVSでは「できなかったこと」あるいは「困難だったこと」だ。Subversionは、それらを一つ一つ、着実に解決した。

---

## 6. まとめと次回予告

### この回の要点

第一に、Subversionは2000年にCollabNetの支援のもと、Karl Fogel、Jim Blandy、Ben Collins-Sussmanという、CVSを知り尽くした開発者たちによって設計が開始された。Jim Blandyは「Subversion」の名前とデータストアの基本設計を考案し、Karl FogelはCVSの専門書を著した経験を設計に注いだ。CVSの限界を最も深く理解していた者たちが、その後継を作った。

第二に、Subversionの核心的な設計判断は、CVSの具体的な欠陥への回答だった。アトミックコミット（コミットの中断による不整合の排除）、ディレクトリバージョニング（構造変更の追跡）、リネーム対応（履歴の連続性の保持）、リポジトリ全体への連番リビジョン（人間が理解できる識別子）——これらはすべて、CVSで「あるべきだったがなかったもの」だ。

第三に、Subversionは二つのネットワークアーキテクチャ（Apache/WebDAVとsvnserve）を提供し、企業環境から個人プロジェクトまで幅広い環境に対応した。Apache構成ではHTTP/HTTPSという既知のプロトコルを使い、ファイアウォールやプロキシとの親和性を確保した。

第四に、リポジトリのストレージバックエンドは、Berkeley DB（BDB）から FSFS（Filesystem on top of Filesystem）へと進化した。FSFSは透過的なファイル構造、容易なバックアップ、プロセスクラッシュへの耐性を提供し、Subversion 1.2以降のデフォルトバックエンドとなった。

第五に、「CVSを正しくやり直す」という目標設定は、CVSの集中型パラダイムの枠内での改良を意味した。この目標は精力的に達成されたが、同時期に台頭し始めた分散型VCSの思想——全履歴のローカル保持、オフラインでのコミット——は、Subversionの設計の射程外にあった。

### 冒頭の問いへの暫定回答

CVSの後継は、何を「正しくやり直そう」としたのか。

答えは、CVSの設計における具体的な欠陥の修正だ。非アトミックなコミット、ディレクトリ管理の不在、リネーム追跡の欠如、ファイル単位のリビジョン番号。これらの問題を、集中型VCSというパラダイムの中で、一つ一つ正確に解決した。

Subversionの偉大さは、この「正しくやり直す」作業の徹底ぶりにある。CVSユーザーの操作感を維持しながら、CVSの弱点を体系的に潰していった。移行コストを最小化し、改善効果を最大化する——この現実的なアプローチは、ソフトウェアエンジニアリングのお手本と言えるものだった。

だが、「正しくやり直す」ことと「根本的に作り変える」ことは違う。CVSの欠陥を修正することに集中したSubversionは、集中型というCVSの基本的なアーキテクチャをそのまま継承した。それが正しかったのか、それとも限界だったのか。この問いの答えは、Subversionのその後の歴史が示すことになる。

### 次回予告

次回は、Subversionの内部にさらに深く踏み込む。

**第9回「Subversionの内部構造——なぜ連番リビジョンは合理的だったのか」**

Subversionの連番リビジョン番号 vs Gitの40文字ハッシュ。どちらが「正しい」のか。この問いは、単なる識別子の形式の違いを超え、集中型と分散型のアーキテクチャの本質的な差異を映し出す。リポジトリの内部構造——Copy-on-Write方式、ブランチ＝ディレクトリコピーの設計、ダンプファイルの構造——を解剖し、Subversionの設計判断の合理性を技術的に検証する。

あなたが日常的に使っている `git log` のコミットハッシュ。それが「連番リビジョン」ではなく「ハッシュ値」である理由を、考えたことがあるだろうか。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Collins-Sussman, B., Fitzpatrick, B.W. & Pilato, C.M., "Version Control with Subversion (SVN Book)." <https://svnbook.red-bean.com/>
- SVN Book, "What Is Subversion?" <https://svnbook.red-bean.com/en/1.8/svn.intro.whatis.html>
- SVN Book, "Version Control the Subversion Way." <https://svnbook.red-bean.com/en/1.6/svn.basic.in-action.html>
- SVN Book, "The Subversion Repository, Defined." <https://svnbook.red-bean.com/en/1.8/svn.reposadmin.basics.html>
- SVN Book, "httpd, the Apache HTTP Server." <https://svnbook.red-bean.com/en/1.7/svn.serverconfig.httpd.html>
- SVN Book, "Appendix D. The Berkeley DB Legacy Filesystem." <http://svnbook.red-bean.com/en/1.8/svn.berkeleydb.html>
- Subversion Release History. <https://subversion.apache.org/docs/release-notes/release-history.html>
- Subversion 1.1 Release Notes. <https://subversion.apache.org/docs/release-notes/1.1.html>
- Subversion 1.2 Release Notes. <https://subversion.apache.org/docs/release-notes/1.2.html>
- The Apache Software Foundation, "20th Anniversary of Apache Subversion," 2020. <https://news.apache.org/foundation/entry/the-apache-software-foundation-announces58>
- Fogel, K., Professional Biography. <https://producingoss.com/cv/bio.html>
- RFC 3253, "Versioning Extensions to WebDAV (DeltaV)." <https://datatracker.ietf.org/doc/html/rfc3253>
- Wikipedia, "Apache Subversion." <https://en.wikipedia.org/wiki/Apache_Subversion>
- Wikipedia, "Brian Behlendorf." <https://en.wikipedia.org/wiki/Brian_Behlendorf>
