# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第13回：BitKeeper事件——Linuxカーネルとプロプライエタリの衝突

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- LinuxカーネルがBitKeeperを採用した技術的・現実的理由（2002年）
- BitKeeperの無償ライセンスに付された「非競合条項」の内容と、OSSコミュニティ内の対立構造
- Andrew Tridgell（Samba開発者）のリバースエンジニアリングの経緯と手法
- BitMover社による無償ライセンス打ち切りの時系列（2005年4月）
- Richard StallmanとLinus Torvaldsの「原則 vs 実用主義」の論争
- BitKeeper事件がOSSの自由とツール選択の関係に投げかけた根本的な問い
- BitKeeperが実現していた技術的先進性——分散リポジトリ、リネーム追跡、高精度マージ

---

## 1. 「自由」のツールで「自由」を作れなかった日

2002年の初め、私はLinuxカーネルのメーリングリスト（LKML）を購読していた。正確に言えば、購読していたがすべてを読む余裕はなく、Subject行を眺めて気になるスレッドだけを追いかける、という付き合い方だった。

そのころのLKMLには、技術的な議論と同じくらいの頻度で、ある種の「政治的」な議論が流れていた。BitKeeperに関する議論だ。

Linus TorvaldsがLinuxカーネルの開発にBitKeeperというプロプライエタリなバージョン管理ツールを採用する——このニュースに対する反応は、真っ二つに割れていた。「最高のツールを使うべきだ」という実用派と、「フリーソフトウェアの象徴であるLinuxカーネルにプロプライエタリなツールを使うのは矛盾だ」という原則派。私自身はどちらかと言えば前者に近かったが、後者の懸念も理解できた。

当時の私は、Subversionの導入を検討している現場にいた。CVSからの移行先としてSubversionは合理的な選択だと考えていたし、実際にそう進めた。だが、LKMLの議論を追いかけるうちに、私は気づいた。Linuxカーネルの開発規模——数千人の開発者が並行して作業し、毎日数百のパッチが飛び交う——において、CVSもSubversionも根本的に不十分なのだ。

Linusが直面していた問題は、私の現場の問題とは桁が違った。そして、その桁違いの問題を解決できるツールが、当時はBitKeeperしかなかった。

このことが、やがて巨大な爆発を引き起こす。

**OSS開発にプロプライエタリツールを使うことの矛盾は、どう爆発したのか。** この問いは、単なる歴史上の出来事ではない。「最善のツールを使う自由」と「ソフトウェアの自由」が衝突したとき、何を選ぶべきか——この問いは、2026年の現在もなお有効だ。

あなたの開発環境を見回してほしい。GitHub、Slack、JetBrains IDE、Docker Desktop——プロプライエタリなツールはどれだけあるだろうか。それらが突然、ライセンスを変更したら？ あなたのワークフローは、誰の手の中にあるのか。

---

## 2. BitKeeperとLinuxカーネル——採用の経緯

### 1991年から2002年——パッチの手動適用という「職人技」

Linuxカーネルの開発プロセスを理解するには、まず2002年以前の状況を知る必要がある。

Linusが1991年にLinuxカーネルの開発を開始してから最初の10年間、カーネル開発にバージョン管理ツールは使われていなかった。開発者はメーリングリストにパッチ（unified diff形式のテキスト）を投稿し、各サブシステムのメンテナがレビューする。レビューを通過したパッチはLinusの信頼する副官（lieutenant）に送られ、最終的にLinus自身がソースツリーに手動で適用してリリースを行う。

このワークフローは、驚くほど長い間機能していた。だが、2000年代に入ると、カーネルへの貢献者の数は急増し、パッチの量はLinusの処理能力を超え始めた。

問題は三つあった。

第一に、Linusがボトルネックだった。すべてのパッチは最終的にLinusのソースツリーに適用される必要がある。Linusの処理速度がカーネル開発全体のスループットの上限を規定していた。

第二に、パッチの追跡が困難だった。メーリングリストに投稿されたパッチが、どの段階にあるのか——レビュー中か、却下されたか、適用済みか——を体系的に追跡する仕組みがなかった。パッチが「消失」することもあった。

第三に、並行開発の統合が手作業だった。複数のサブシステムが独立に開発を進め、その成果を統合する工程は、本質的にマージ操作だ。だが、VCSを使わない環境では、マージは人間の判断と手作業に完全に依存していた。

### Larry McVoyの提案——1998年

この問題に対する一つの解を提示したのが、Larry McVoyだった。

前回（第12回）で触れたように、McVoyはSun MicrosystemsでTeamWare（1992年発表の分散型ソースコード管理システム）に携わった経験を持つ。TeamWareの設計思想——各開発者がリポジトリの完全なコピーを持ち、変更をピアツーピアで同期する——を、McVoyは1998年9月にLinuxカーネルメーリングリストで新しいバージョン管理システムの構想として提案した。

1999年3月にself-hostingを達成し、2000年5月4日に最初の公開リリースを行ったBitKeeperは、以下の技術的特徴を持っていた。

```
BitKeeperの主要な技術的特徴（2000年時点）:

1. 分散リポジトリ
   - 各開発者がリポジトリの完全なコピーを保持
   - オフラインでのコミット、履歴参照が可能
   - TeamWareから継承された設計思想

2. ファイルのリネーム追跡
   - CVS/Subversionの致命的弱点を解決
   - ファイルの移動・改名を履歴として正確に追跡

3. 高精度な自動マージ
   - diff3の変種ではなく、全履歴を活用したマージアルゴリズム
   - コンフリクト解決の精度が当時の競合を大幅に凌駕

4. アトミックなチェンジセット
   - リポジトリ全体の状態を一つの単位として記録
   - CVSのファイル単位コミットの問題を解決

5. チェックサムによるデータ完全性検証
   - すべてのファイルアクセスでチェックサムを検証
   - データ破損を即座に検出
```

これらの機能は、当時のOSS系バージョン管理ツール——CVS、Subversion、GNU arch、Monotone——のいずれも実現していなかったものだ。特に、分散リポジトリとリネーム追跡の組み合わせは、Linuxカーネルの開発モデルに対する「解」として、他に選択肢がなかった。

### 2002年2月——採用の決断

2002年2月、Linus TorvaldsはLinuxカーネル2.5系列（開発版）の管理にBitKeeperを導入した。

Torvaldsの立場は、徹底した実用主義だった。自らの言葉で「私はフリーソフトウェアの狂信者ではない。オープンソースツールが優れていればそれを使うし、商用ツールが優れていればそちらを使う」と公言した。Linusにとって、カーネル開発のスループットを最大化することが最優先事項であり、ツールのライセンスは二次的な問題だった。

BitKeeperの導入効果は劇的だった。

それまでLinusの肩に集中していたパッチ適用作業が、信頼された副官たちに分散された。各サブシステム——アーキテクチャ、ドライバ、ファイルシステム——の開発が、BitKeeperリポジトリのフォークとして独立に進行し、準備ができた段階でLinusのツリーにマージされる。`pull` リクエストという操作が、メーリングリストでの「パッチ添付メール」に代わった。

カーネルリリースのペースは倍以上に加速したとされる。BitKeeperの分散ワークフローとアトミックなチェンジセットが、数百人の開発者からの貢献を効率的に統合することを可能にした。

だが、この技術的成功には代償があった。

### 「悪魔との取引」——非競合条項

BitKeeperはプロプライエタリ製品だった。McVoyはOSSコミュニティへの配慮として、無償のコミュニティ版ライセンスを提供した。オープンソースやフリーソフトウェアのプロジェクトに携わる開発者は、BitKeeperを無料で使用できる。

ただし、条件があった。

BitKeeperの無償ライセンスには「非競合条項」が付されていた。ライセンス文書（バージョン1.38）には、こう記されている。

> 「このライセンスにおける他のいかなる条項にもかかわらず、あなたおよび/またはあなたの雇用主がBitKeeper Softwareと実質的に類似する機能を含む製品を開発、製造、販売、および/または再販する場合、またはBitMoverの合理的な判断においてBitKeeper Softwareと競合する場合、このライセンスはあなたには利用できません。」

つまり、CVS、Subversion、GNU arch、ClearCaseなどの競合バージョン管理ツールの開発に参加する開発者は、BitKeeperを無償で使用できない。この制限は、BitKeeperの使用期間中だけでなく、使用終了後1年間も継続する。

この条項は、OSSコミュニティの一部にとって受け入れがたいものだった。バージョン管理ツールの開発に携わるOSS開発者——すなわち、CVSやSubversionの開発者——が、自分たちの仕事のためにLinuxカーネルのソースツリーにアクセスする手段を制限されるのだ。

Linux重鎮のAlan Coxを含む複数の主要カーネル開発者が、BitKeeperの使用を拒否した。ライセンス条件への反発と、プロプライエタリツールへの依存に対する原則的な立場だった。

ただし、BitKeeperの使用はあくまでオプションだった。パッチをプレーンなdiff形式でメーリングリストに投稿する従来のワークフローは引き続き機能していた。BitKeeperを使わないことは可能だったが、BitKeeperを使う開発者と使わない開発者の間に、ワークフローの分断が生じていた。

---

## 3. 原則と実用主義の衝突——コミュニティの論争

### Richard Stallmanの警告

BitKeeperのLinuxカーネル採用に対して、最も声高に異議を唱えたのはRichard Stallmanだった。

GNUプロジェクトの創設者であり、フリーソフトウェア運動の父であるStallmanにとって、Linuxカーネルは「フリーソフトウェアのフラッグシップ」だった。そのフラッグシップの開発インフラが、プロプライエタリなツールに依存する——これは、原則の問題だった。

2002年10月13日、StallmanはLKMLに「Bitkeeper outrage, old and new」の件名でメールを投稿した。フリーソフトウェアの原則から見て、BitKeeperの使用は容認できないという立場を明確にした。

Stallmanの議論の核心は、こうだ。BitKeeperはフリーソフトウェアではない。したがって、BitKeeperのユーザーはBitMoverに対して従属的な立場に置かれる。BitMoverがライセンス条件を変更すれば、ユーザーはそれに従うか、ツールを失うかの二択を迫られる。フリーソフトウェアプロジェクトが、プロプライエタリツールに依存することは、プロジェクトの自律性を損なう。

この論争は感情的にエスカレートし、StallmanをLKMLから追放すべきかという議論にまで発展した。技術コミュニティにおいて、原則と実用のどちらを優先すべきかという問いは、常に火種になる。

### Linus Torvaldsの反論

Torvaldsの立場は一貫していた。自分にとって重要なのは、カーネル開発のスループットを最大化することだ。そのためにBitKeeperが最善のツールであるなら、それを使う。ツールのライセンスは技術的判断とは別の問題だ。

Torvaldsは、フリーソフトウェアのSCM（Source Code Management）で、カーネル規模の開発を処理できるものは存在しないと判断していた。CVSは論外だった。Subversionは集中型であり、カーネルの分散的な開発モデルに合わない。GNU archは性能と使いやすさに問題があった。Monotoneは技術的に興味深いが、カーネル規模の性能に達していなかった。

消去法で残ったのがBitKeeperだった。

この構図は、原則と実用主義の古典的な対立だ。Stallmanにとって、ソフトウェアの自由は譲れない原則であり、いかなる実用的メリットもそれを上回ることはない。Torvaldsにとって、ツールは問題を解くための手段であり、ライセンスは副次的な属性だ。

どちらが「正しい」かを判定することは、この連載の目的ではない。だが、歴史は一つの教訓を残した——Stallmanの懸念は、3年後に現実のものとなった。

### 静かな緊張——2002年から2005年

BitKeeperの採用後、Linuxカーネル開発は技術的には順調に進んだ。だが、コミュニティ内の緊張は消えなかった。

非競合条項をめぐる摩擦は継続していた。BitMoverは、競合するバージョン管理ツールの開発に関わる開発者がBitKeeperを使用できないよう、ライセンスを厳格に運用した。この「知的境界線」は、OSSコミュニティの「自由にコードを書き、自由にツールを選ぶ」という文化と根本的に衝突していた。

McVoyの立場にも理解すべき点はあった。BitKeeperの開発と維持には膨大なコストがかかる。無償で提供している以上、競合製品の開発にBitKeeperが利用されることは、事業の存続を脅かす。非競合条項は、BitMoverにとって合理的な自衛策だった。

だが、OSSコミュニティの多くのメンバーにとって、この「自衛策」はOSSの基本精神——ソフトウェアの自由な利用、研究、改変、再配布——に対する制約だった。自由なソフトウェアを開発する行為そのものが、ツールの利用権を奪う根拠になる。この構造的矛盾は、いつか爆発する運命にあった。

---

## 4. 爆発——Andrew Tridgellとソースの解放

### Andrew Tridgell——プロトコル解析の達人

2005年、事態を動かしたのはAndrew Tridgellだった。

Tridgellは、OSSの世界で特異な才能を持つ人物だ。最も有名な成果はSamba——MicrosoftのSMB/CIFSプロトコルをリバースエンジニアリングし、LinuxからWindowsファイル共有にアクセスすることを可能にしたソフトウェアだ。さらにrsyncアルゴリズムの共同発明者でもある。プロプライエタリなプロトコルを解析し、フリーな実装を作る——これはTridgellの得意技であり、使命でもあった。

2005年当時、TridgellはOSDL（Open Source Development Labs）の第2代フェローだった。Linus TorvaldsもOSDLのフェローであり、Andrew Morton（Linusに次ぐカーネルの副メンテナ）もOSDLに関連していた。

Tridgellが行ったのは、BitKeeperのネットワークプロトコルの解析だった。彼の手法は、Sambaで培ったものと本質的に同じだ。Tridgellは後に、「BitKeeperサーバにtelnetで接続して、helpと入力しただけだ」と説明した。BitKeeperのサーバプロセスにTCPで接続すると、対話的なコマンドインターフェースが応答する。そのインターフェースが返す情報を分析することで、プロトコルの構造を理解した。

Tridgellは、BitKeeperを購入も使用もしていなかった。したがって、BitKeeperのライセンスに同意したことはない。ライセンスに同意していない以上、ライセンスの非競合条項に違反することは論理的に不可能だ——これがTridgellの立場だった。

### SourcePuller——メタデータの解放

Tridgellが開発したのは「SourcePuller」と呼ばれるツールだった。このツールは、BitKeeperリポジトリからメタデータ（コミット履歴、変更内容）を取得する。BitKeeperの完全な互換クライアントではなく、データの「読み出し」に特化したものだ。

2005年4月のLinux.Conf.Auキーノートで、Tridgellはこのツールを公開した。デモンストレーションでは、BitKeeperサイトにtelnetで接続し、プロトコルの基本的な操作を実演した。

ここで争点になったのは、メタデータの所有権だった。カーネル開発者たちは、自分たちのコード投稿によって生成されたメタデータ——コミットログ、変更履歴——はコミュニティのものだと主張した。Larry McVoyは、BitKeeperによって管理されるメタデータはBitMoverのものだと主張した。

この争いの構造は、後のクラウドサービス時代に繰り返し現れることになる。ユーザーのデータが他者のインフラストラクチャに依存するとき、そのデータの「所有権」は誰にあるのか。BitKeeper事件は、この問いの先駆的な事例だった。

### Larry McVoyの最後通告

McVoyはかねてから警告していた。BitKeeperのプロトコルをリバースエンジニアリングしようとする者がいれば、無償ライセンスを打ち切ると。

Tridgellの行動は、McVoyにとってまさにその「一線を越える行為」だった。McVoyはTridgellの行為をライセンス違反（正確には、リバースエンジニアリングを禁じるエンドユーザーライセンス契約への違反の教唆）と見なした。

2005年4月、BitMover社はBitKeeperの無償コミュニティ版の提供終了を発表した。さらに、OSDL雇用の開発者——Linus Torvalds、Andrew Mortonを含む——への商用ライセンスの提供も拒否した。TridgellがOSDLのフェローであったことが、その理由だった。

無償版のサポート終了日は2005年7月1日と設定された。

### 2005年4月3日〜6日——歴史の転換点

時系列を正確に追おう。

2005年4月3日、Linus Torvaldsは2.6.12-rc2をリリースした。これがBitKeeperで管理された最後のLinuxカーネルリリース候補となった。

同日、Torvaldsはgitの開発を開始した。

2005年4月6日、TorvaldsはLKMLに「Kernel SCM saga...」の件名でメールを投稿した。

> 「多くの方がすでにご存知のように、ここ1、2ヶ月（もっと長く感じますが ;）、BKの使用をめぐる問題の解決を試みてきました。うまくいっていません。結果として、カーネルチームは代替を検討しています。」

この短いメールが、ソフトウェア開発の歴史を変えた。

```
BitKeeper事件の時系列:

  1998年9月  McVoyがLKMLで分散型VCSの構想を提案
  2000年5月  BitKeeper最初の公開リリース
  2002年2月  LinuxカーネルがBitKeeperを採用（2.5系列）
  2002年10月 StallmanがLKMLに「Bitkeeper outrage」を投稿
  2005年3月  TridgellがBitKeeperプロトコルを解析
  2005年4月3日  2.6.12-rc2リリース（BitKeeper最後のリリース候補）
  2005年4月3日  Torvaldsがgitの開発を開始
  2005年4月6日  Torvaldsが「Kernel SCM saga...」をLKMLに投稿
  2005年4月7日  gitがself-hostingを達成
  2005年4月22日 Tridgellがlinux.conf.auでSourcePullerを公開
  2005年7月1日  BitKeeper無償版のサポート終了
  2016年5月9日  BitKeeperがApache License 2.0でオープンソース化
```

4月3日から4月7日までの4日間で、Torvaldsはgitの原型を作り上げ、self-hosting（git自身のソースコードをgitで管理できる状態）を達成した。この速度は、Torvaldsが求めていたものが明確だったことを示している。BitKeeperで3年間にわたって体験した「分散型VCSとはこうあるべきだ」という具体的な知見が、gitの設計を加速させた。

BitKeeperは敵だったのではない。教師だったのだ。

---

## 5. ハンズオン：BitKeeper事件のアーカイブを読む——一次ソースに触れる

歴史を語る上で、一次ソースに当たることは不可欠だ。BitKeeper事件の主要な文書は、今もインターネット上で閲覧できる。このハンズオンでは、実際のメーリングリストアーカイブや公式文書を読み、事件の全体像を自分の目で確認する。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y curl git
```

### 演習1：LKMLアーカイブから「Kernel SCM saga」を読む

```bash
WORKDIR="${HOME}/vcs-handson-13"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "=== 演習1: LKMLアーカイブから「Kernel SCM saga」を読む ==="

# Linusの歴史的メール（2005年4月6日）のURLを記録
cat > lkml-references.txt << 'EOF'
BitKeeper事件 主要メーリングリストアーカイブ:

1. Linus Torvalds, "Kernel SCM saga..." (2005-04-06)
   https://lkml.org/lkml/2005/4/6/121
   -> BitKeeperとの決別を公表した歴史的メール

2. Richard Stallman, "Bitkeeper outrage, old and new" (2002-10-13)
   https://lkml.org/lkml/2002/10/13/201
   -> StallmanによるBitKeeper使用への抗議

3. LWN.net, "The kernel and BitKeeper part ways" (2005-04-06)
   https://lwn.net/Articles/130746/
   -> BitKeeper離脱の経緯を報じた記事

4. LWN.net, "How Tridge reverse engineered BitKeeper" (2005-04-19)
   https://lwn.net/Articles/132938/
   -> Tridgellのリバースエンジニアリング手法の解説
EOF

echo "主要アーカイブURLを lkml-references.txt に記録した"
echo ""

# gitの初期コミットログを確認する
echo "--- gitの初期コミットログを確認 ---"
echo ""
echo "gitのGitHub公式リポジトリには、2005年4月の初期コミットが含まれている。"
echo "git自身のリポジトリをクローンして、最初期のコミットを見てみよう。"
echo ""

git clone --bare https://github.com/git/git.git git-history.git 2>&1 | tail -3
echo ""

echo "--- gitの最初の10コミット ---"
git --git-dir=git-history.git log --oneline --reverse | head -10
echo ""
echo "-> 最初のコミットの日付とメッセージに注目"
echo "-> BitKeeperとの決別から数日でgitの原型が作られた"
```

### 演習2：gitの「誕生日」を確認する

```bash
echo ""
echo "=== 演習2: gitの「誕生日」を確認する ==="

# gitの最初のコミットの詳細
FIRST_COMMIT=$(git --git-dir=git-history.git rev-list --max-parents=0 HEAD | tail -1)
echo "gitの最初のコミット:"
echo ""
git --git-dir=git-history.git log --format="  ハッシュ: %H%n  著者: %an <%ae>%n  日付: %ai%n  メッセージ: %s" "${FIRST_COMMIT}"
echo ""
echo "-> Linus Torvaldsが2005年4月にgitの最初のコミットを行った"
echo "-> BitKeeper問題が表面化してから驚くべき速度で開発が進んだ"
echo ""

# 最初の1週間のコミット数を数える
echo "--- 最初の1週間のコミット活動 ---"
echo ""
echo "2005年4月のコミット数:"
git --git-dir=git-history.git log --oneline --after="2005-04-01" --before="2005-05-01" --reverse | wc -l
echo "コミット"
echo ""
echo "日ごとの内訳:"
for day in $(seq -w 3 30); do
  count=$(git --git-dir=git-history.git log --oneline --after="2005-04-${day}" --before="2005-04-$((10#$day + 1))" 2>/dev/null | wc -l)
  if [ "${count}" -gt 0 ]; then
    echo "  4月${day}日: ${count}コミット"
  fi
done
echo ""
echo "-> BitKeeperとの決別直後の集中的な開発が見て取れる"
```

### 演習3：BitKeeperの設計思想がgitにどう受け継がれたかを確認する

```bash
echo ""
echo "=== 演習3: BitKeeperの設計思想がgitに受け継がれた点を確認する ==="

# gitリポジトリを作成し、BitKeeperが先駆けた機能を試す
mkdir -p "${WORKDIR}/demo"
cd "${WORKDIR}/demo"
git init

echo ""
echo "--- 機能1: 分散リポジトリ ---"
echo "BitKeeperの核心: 各開発者がリポジトリの完全なコピーを保持"
echo ""
cat > README.md << 'FILEEOF'
# BitKeeper Legacy Demo
This repository demonstrates features that BitKeeper pioneered.
FILEEOF
git add README.md
git commit -m "Initial commit" --quiet
echo "-> git commitはローカルで完結する（サーバ不要）"
echo "-> これはBitKeeperが実現し、CVS/SVNにはなかった特徴"
echo ""

echo "--- 機能2: リネーム追跡 ---"
echo "BitKeeperの強み: ファイルの移動・改名を履歴として追跡"
echo ""
mkdir -p src
git mv README.md src/README.md
git commit -m "Move README to src/" --quiet
git log --follow --oneline -- src/README.md
echo ""
echo "-> git log --follow でリネーム前の履歴も追跡可能"
echo "-> CVSではリネーム追跡が不可能だった"
echo "-> BitKeeperはこの問題を解決した最初のVCSの一つ"
echo ""

echo "--- 機能3: 高速な分岐とマージ ---"
echo "BitKeeperの設計: サブシステムの独立開発とマージを効率化"
echo ""
git checkout -b feature-a --quiet
echo "Feature A" >> src/README.md
git add src/README.md
git commit -m "Add feature A" --quiet

git checkout main --quiet
git checkout -b feature-b --quiet
echo "Feature B" >> src/README.md
git add src/README.md
git commit -m "Add feature B" --quiet

git checkout main --quiet
git merge feature-a --no-edit --quiet
echo ""
echo "-> ブランチの作成・マージが軽量な操作として実行される"
echo "-> BitKeeperは「サブグループの独立開発→メインツリーへのマージ」"
echo "   というワークフローをLinuxカーネルに導入した"
echo "-> gitはこのワークフローをさらに洗練させた"
echo ""

echo "--- まとめ ---"
echo ""
echo "BitKeeperが先駆けた主要機能とgitの対応:"
echo ""
echo "  BitKeeper                    git"
echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  分散リポジトリ          →  分散リポジトリ"
echo "  リネーム追跡            →  リネーム検出（ヒューリスティック）"
echo "  全履歴マージ            →  3-way merge + recursive"
echo "  アトミックチェンジセット →  コミットオブジェクト"
echo "  チェックサム検証        →  SHA-1ハッシュによる完全性保証"
echo "  プロプライエタリ        →  GPL v2（フリーソフトウェア）"
echo ""
echo "-> BitKeeperの技術的遺産はgitに受け継がれた"
echo "-> だが、ライセンスは根本的に変わった"
echo "-> gitはフリーソフトウェアとして生まれた"
```

### 演習で見えたこと

三つの演習を通じて、BitKeeper事件の一次ソースに触れ、gitの誕生の瞬間を確認した。

LKMLアーカイブに残るTorvaldsの「Kernel SCM saga...」メールは、ソフトウェア開発史における転換点を示す文書だ。短いメールの背後に、3年にわたるBitKeeperとの共存、コミュニティ内の緊張、そして「これ以上は続けられない」という判断がある。

gitリポジトリの最初期のコミットログは、Torvaldsの開発速度を物語る。BitKeeperで3年間蓄積した「分散型VCSに必要なもの」の知見が、gitの設計を驚異的な速度で具現化させた。BitKeeperなくしてgitはなかった——技術的にも、歴史的にも。

そして、BitKeeperが先駆けた機能——分散リポジトリ、リネーム追跡、高速マージ、データ完全性保証——がgitに受け継がれている事実は、技術の継承という観点で重要だ。gitは「反BitKeeper」として生まれたのではなく、「BitKeeperが証明した分散型VCSの価値を、フリーソフトウェアとして再実装する」プロジェクトとして生まれたのだ。

---

## 6. BitKeeper事件が問いかけたもの

### ソフトウェアの自由とツール選択の関係

BitKeeper事件は、単なるライセンス紛争ではなかった。この事件は、ソフトウェア開発の根幹に関わる問いを投げかけた。

**問い1：フリーソフトウェアの開発に、プロプライエタリなツールを使うことは許容されるか？**

Stallmanの答えは「否」だった。フリーソフトウェアの開発インフラがプロプライエタリツールに依存することは、プロジェクトの自律性を損なう。依存先のベンダーがライセンスを変更すれば、プロジェクトは人質に取られる。

Torvaldsの答えは「条件付きイエス」だった。最善のツールを使うことが開発者の権利であり、ライセンスよりも技術的優位性を優先すべきだ。

歴史は、両者がどちらも「正しかった」ことを示した。Torvaldsの実用主義は、カーネル開発を3年間にわたって加速させた。Stallmanの原則論は、その3年後に「だから言ったではないか」という形で現実化した。

**問い2：OSSプロジェクトのインフラストラクチャは、誰が管理すべきか？**

BitKeeper事件で浮き彫りになったのは、開発者が生成したメタデータ——コミットログ、変更履歴——の「所有権」の問題だった。BitMover社はBitKeeperで管理されるデータの所有権を主張し、カーネル開発者たちは自分たちの貢献から生じたデータはコミュニティのものだと主張した。

この問いは、2026年の現在、さらに大きな意味を持っている。GitHubのリポジトリデータは誰のものか。CI/CDパイプラインの設定はベンダーに依存していないか。SaaSツールが提供するAPIが変更されたとき、あなたのワークフローは維持できるか。

**問い3：「自由」のコストは何か？**

BitKeeperが存在しなければ、Linuxカーネル開発は2002年から2005年の間、はるかに遅いペースで進んでいた可能性がある。「自由なツールだけを使う」という原則を貫くことのコストは、開発効率の低下だった。

一方、BitKeeperに依存し続けることのコストは、2005年4月に現実化した。依存先のベンダーがライセンスを打ち切れば、プロジェクトは即座にツールを失う。

どちらのコストがより大きいかは、状況と価値観によって異なる。だが、この問いを認識していること——コストを支払う覚悟を持ってツールを選ぶこと——が重要だ。

### 歴史の皮肉——2016年のオープンソース化

BitKeeper事件には後日談がある。

2016年5月9日、BitMover社はBitKeeper バージョン7.2ceをApache License 2.0の下でオープンソースとしてリリースした。gitの誕生から11年が経過していた。

この時点で、gitはすでにバージョン管理のデファクトスタンダードの地位を確立していた。GitHubは数千万のリポジトリを擁し、CI/CDからInfrastructure as Codeまで、あらゆる開発インフラがgitを前提に構築されていた。BitKeeperのオープンソース化は、歴史的な和解の意味はあったが、実用上のインパクトはほとんどなかった。

この事実は、一つの教訓を含んでいる。タイミングは重要だ。2002年にBitKeeperがオープンソースであったなら、gitは生まれなかったかもしれない。だが、2016年のオープンソース化は「遅すぎた」。技術のエコシステムは、一度確立されると容易には置き換わらない。

---

## 7. まとめと次回予告

### この回の要点

第一に、Linuxカーネル開発は2002年2月にBitKeeperを採用した。その動機は実用的なものだった。カーネル規模の分散開発を処理できるバージョン管理ツールが、当時はBitKeeperしかなかったのだ。BitKeeperの分散リポジトリ、リネーム追跡、高精度マージは、カーネル開発を大幅に加速させた。

第二に、BitKeeperの無償ライセンスには非競合条項が付されており、競合VCSの開発者はBitKeeperを使用できなかった。この条項は、Alan Coxを含む複数の主要開発者のBitKeeper拒否につながり、Richard StallmanとLinus Torvaldsの「原則 vs 実用主義」論争を引き起こした。

第三に、2005年4月、Andrew Tridgell（Samba開発者）がBitKeeperのプロトコルを解析し、SourcePullerを開発したことをきっかけに、BitMover社は無償ライセンスを打ち切った。OSDL雇用の開発者（Torvalds、Morton含む）へのライセンス提供も拒否された。

第四に、Linus Torvaldsは2005年4月3日にgitの開発を開始し、4月7日にはself-hostingを達成した。BitKeeperで3年間蓄積した分散型VCSの知見が、この驚異的な開発速度を可能にした。

第五に、BitKeeper事件は「ソフトウェアの自由とツール選択の関係」「開発メタデータの所有権」「自由のコスト」という根本的な問いを提起した。これらの問いは、2026年の現在もなお有効である。

### 冒頭の問いへの暫定回答

OSS開発にプロプライエタリツールを使うことの矛盾は、どう爆発したのか。

予見された通りに爆発した。

Stallmanは2002年の時点で警告していた。プロプライエタリツールへの依存はプロジェクトの自律性を損なうと。3年後、その警告は現実になった。BitMover社がライセンスを打ち切り、Linuxカーネル開発チームはツールを失った。

だが、この爆発は破滅ではなかった。むしろ創造的な破壊だった。BitKeeperの喪失は、gitという新しいツールの誕生を促した。そしてgitは、BitKeeperが実現していた機能をフリーソフトウェアとして再実装し、さらにそれを超えた。

歴史の教訓は明快だ。プロプライエタリなツールに依存することのリスクは、常に認識すべきだ。だが同時に、そのリスクが現実化したとき、OSSコミュニティは驚くべき速度で代替を生み出す能力を持っている。重要なのは、依存のリスクを認識した上で、意識的に選択することだ。

### 次回予告

BitKeeper事件によってツールを失ったLinus Torvaldsが、わずか数日でgitの原型を作り上げた。だが、gitは「バージョン管理ツール」として設計されたわけではない。

**第14回「Linus Torvaldsの決断——Gitの誕生（2005年4月）」**

2005年4月3日のメーリングリスト投稿。「10日間でGitの原型を完成」の真実。Linusの設計要件——速度、分散、データの完全性、非線形開発のサポート。なぜLinusは既存の分散型VCS（Monotone、Darcs）を選ばず、自分で作ることを選んだのか。そして、Gitは「バージョン管理ツール」ではなく「コンテンツアドレッサブルファイルシステム」として生まれたという、意外な出自を次回は追う。

あなたが日常的に使っている `git add`、`git commit`、`git push` の裏側で動いている仕組みは、Linus Torvaldsの怒りと合理主義が生んだものだ。その誕生の物語を、次回は技術的な詳細とともに語る。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- Wikipedia, "BitKeeper." <https://en.wikipedia.org/wiki/BitKeeper>
- Wikipedia, "Larry McVoy." <https://en.wikipedia.org/wiki/Larry_McVoy>
- Wikipedia, "Andrew Tridgell." <https://en.wikipedia.org/wiki/Andrew_Tridgell>
- Wikipedia, "Open Source Development Labs." <https://en.wikipedia.org/wiki/OSDL>
- Torvalds, L., "Kernel SCM saga..." Linux Kernel Mailing List (2005-04-06). <https://lkml.org/lkml/2005/4/6/121>
- Stallman, R., "Bitkeeper outrage, old and new." Linux Kernel Mailing List (2002-10-13). <https://lkml.org/lkml/2002/10/13/201>
- LWN.net, "The kernel and BitKeeper part ways." (2005-04-06). <https://lwn.net/Articles/130746/>
- LWN.net, "How Tridge reverse engineered BitKeeper." (2005-04-19). <https://lwn.net/Articles/132938/>
- LWN.net, "The BitKeeper non-compete clause." <https://lwn.net/Articles/12120/>
- LWN.net, "BitKeeper goes open source." (2016-05-09). <https://lwn.net/Articles/686986/>
- The Register, "Torvalds knifes Tridgell." (2005-04-14). <https://www.theregister.com/2005/04/14/torvalds_attacks_tridgell/>
- The Register, "Tridgell drops Bitkeeper bombshell." (2005-04-22). <https://www.theregister.com/2005/04/22/tridgell_releases_sourcepuller/>
- InfoWorld, "Linus Torvalds' BitKeeper blunder." <https://www.infoworld.com/article/2211030/linus-torvalds-bitkeeper-blunder.html>
- Linux Journal, "A Git Origin Story." <https://www.linuxjournal.com/content/git-origin-story>
- Graphite, "BitKeeper, Linux, and licensing disputes: How Linus wrote Git in 14 days." <https://graphite.com/blog/bitkeeper-linux-story-of-git-creation>
- OSnews, "RMS and BitKeeper — the Debate Turns Ugly." <https://www.osnews.com/story/1982/rms-and-bitkeeper-the-debate-turns-ugly/>
- Henson, V. and Garzik, J., "BitKeeper for Kernel Developers." Ottawa Linux Symposium (2002). <https://www.kernel.org/doc/ols/2002/ols2002-pages-197-212.pdf>
- BitKeeper Official Site. <https://www.bitkeeper.org/>
