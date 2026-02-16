# ファクトチェック記録：第12回「分散型VCSの思想——なぜ"中央"をなくしたかったのか」

調査日: 2026-02-16

---

## 1. GNU arch（Tom Lord、2001年）

- **結論**: Tom Lordが2001年11月に開発開始。当初はシェルスクリプトの集合体で、コマンド名はlarch。後にCで書き直されtla（Tom Lord's Arch）となった。2003年にGNUプロジェクトの一部となった。2005年8月にLordがメンテナンスを辞任。2009年時点でdeprecatedステータス
- **一次ソース**: GNU Project, "GNU arch"; Wikipedia, "GNU arch"
- **URL**: <https://www.gnu.org/software/gnu-arch/> / <https://en.wikipedia.org/wiki/GNU_arch>
- **注意事項**: GNU archの後継として、CanonicalがBazaar（baz、後にbzr）を開発。baz→Bazaar-NG（bzr）→GNU Bazaarの系譜
- **記事での表現**: 「Tom Lordは2001年11月にGNU archの開発を開始した。CVSに代わる分散型リビジョン管理システムとして設計され、各リビジョンがグローバルに一意な識別子を持ち、分散環境での変更のマージやcherry-pickを可能にした」

## 2. Monotone（Graydon Hoare、2003年）

- **結論**: Graydon Hoareが2002年夏に開発開始、2003年4月6日に最初の公開リリース。SHA-1ハッシュでリビジョンを識別し、SQLiteバックエンドを使用。公開鍵暗号によるチェンジセット署名、netsyncプロトコルによるP2P同期を実現。MonotoneのSHA-1ベースのリビジョン識別はGitのオブジェクトモデルに直接影響を与えた
- **一次ソース**: LWN.net, "The Monotone version control system" (2005年4月); GitHub, graydon/monotone
- **URL**: <https://lwn.net/Articles/132000/> / <https://github.com/graydon/monotone>
- **注意事項**: Graydon Hoareは後にRustプログラミング言語の作者としても知られる。MonotoneはGitの誕生に影響を与えたが、性能面の問題からLinuxカーネル開発には採用されなかった
- **記事での表現**: 「2003年4月、Graydon HoareがMonotoneの最初の公開リリースを行った。SHA-1ハッシュによるリビジョン識別、SQLiteバックエンド、公開鍵暗号による署名——MonotoneのこれらのアイデアはGitに直接影響を与えた」

## 3. Darcs（David Roundy、2002-2003年）

- **結論**: David Roundyが2002年6月にGNU arch向けの新パッチフォーマット設計の議論から出発。最初はC++で実装、2002年秋にHaskellで書き直し、2003年4月に公開リリース。パッチ理論（theory of patches）に基づく設計で、パッチを第一級市民として扱い、パッチ間の順序を半順序集合として表現
- **一次ソース**: Wikipedia, "Darcs"; Roundy, D., "Darcs: distributed version management in haskell"
- **URL**: <https://en.wikipedia.org/wiki/Darcs> / <https://www.researchgate.net/publication/221562944_Darcs_distributed_version_management_in_haskell>
- **注意事項**: DarcsのHaskell実装は型システムによる正確性保証とQuickCheckによるランダムテストを活用。パッチ理論は後のPijulにも影響
- **記事での表現**: 「David Roundyは2002年にGNU archの新パッチフォーマット議論から着想を得て、独自のパッチ理論を構築した。2003年4月にHaskellで書かれたDarcsを公開リリースした」

## 4. BitKeeper（Larry McVoy、1998-2000年）

- **結論**: Larry McVoyがSun MicrosystemsのTeamWare（1992年発表、1993年商用化の分散型SCM）の設計概念を基に構想。1998年9月にLinuxカーネルメーリングリストで提案。1999年3月にself-hosting、1999年5月に早期アクセスβ、2000年5月4日に最初の公開リリース。BitMover社を2000年に設立
- **一次ソース**: Wikipedia, "BitKeeper"; Wikipedia, "Larry McVoy"; Wikipedia, "Sun WorkShop TeamWare"
- **URL**: <https://en.wikipedia.org/wiki/BitKeeper> / <https://en.wikipedia.org/wiki/Larry_McVoy> / <https://en.wikipedia.org/wiki/Sun_WorkShop_TeamWare>
- **注意事項**: TeamWareはSun内部でSolarisやJavaのソース管理に使用された大規模分散型VCSの先駆。BitKeeperはTeamWareの設計を継承しつつ商用製品として発展。2016年にオープンソース化
- **記事での表現**: 「BitKeeperの設計には前史がある。Larry McVoyはSun Microsystemsで分散型SCMであるTeamWare（1992年発表）に携わり、その設計思想をBitKeeperに持ち込んだ」

## 5. TeamWare（Sun Microsystems、1992年）

- **結論**: Sun Microsystemsが1992年11月にSPARCworks/TeamWareとして発表、1993年に商用化。分散型ソースコードリビジョン管理システム。Sun内部でSolaris、Java等の大規模ソースツリー管理に使用。最大の展開はSun自身の内部
- **一次ソース**: Wikipedia, "Sun WorkShop TeamWare"
- **URL**: <https://en.wikipedia.org/wiki/Sun_WorkShop_TeamWare>
- **注意事項**: 分散型VCSの概念は1990年代初頭からSun内部で実践されていた。TeamWareからBitKeeper、そしてGitへの思想的系譜が存在する
- **記事での表現**: 「Sun MicrosystemsのTeamWare（1992年）は、商用環境で実用化された最初の分散型VCSの一つである」

## 6. DAG（有向非巡回グラフ）によるコミット管理

- **結論**: 分散型VCSではDAGでコミット履歴を表現。各コミットが親コミットを参照し、サイクルのないグラフを構成。コミットIDは内容と親のハッシュから計算されるため、データの改竄を検出可能（Merkle DAGの性質）。この構造はMonotone、Git、Mercurial等で共通
- **一次ソース**: Eric Sink, "DVCS and DAGs, Part 1"; IPFS Docs, "Merkle Directed Acyclic Graphs"
- **URL**: <https://ericsink.com/entries/dvcs_dag_1.html> / <https://docs.ipfs.tech/concepts/merkle-dag/>
- **注意事項**: DAGは非線形な開発履歴（ブランチ・マージ）を自然に表現できる。集中型VCSの線形リビジョン番号とは根本的に異なるモデル
- **記事での表現**: 「分散型VCSはDAG（有向非巡回グラフ）でコミット履歴を表現する。各コミットのIDは内容と親コミットのハッシュから計算され、Merkle木の性質により、履歴全体の完全性が暗号学的に保証される」

## 7. Mercurial（Matt Mackall、2005年4月19日）

- **結論**: Matt Mackallが2005年4月19日にMercurialを発表。BitKeeperの無料版撤回（2005年4月初旬）を受けて、Linuxカーネル用の代替として開発。Pythonで実装（バイナリdiff部分はC）。Linus TorvaldsのGit開始と数日差
- **一次ソース**: Wikipedia, "Mercurial"; Architecture of Open Source Applications, "A Short History of Version Control"
- **URL**: <https://en.wikipedia.org/wiki/Mercurial> / <https://aosabook.org/en/v1/mercurial.html>
- **注意事項**: LinuxカーネルはGitを採用したが、MercurialはMozilla Firefox、Facebook（後にMeta）等で採用された
- **記事での表現**: 「2005年4月19日、Matt MackallがMercurialを発表した。BitKeeper問題への応答としてGitとほぼ同時に登場した」

## 8. Bazaar（Canonical、2004-2005年）

- **結論**: 2004年初頭、CanonicalがGNU archをベースにBazaar（baz）の開発を開始。性能と柔軟性の限界から、2005年にゼロから書き直したBazaar-NG（bzr）をbazの後継として発表。2008年にGNU Bazaarとしてリリース1.2がGNUプロジェクトの一部に。Pythonで実装。2025年6月、CanonicalがLaunchpadでのBazaarサポート終了を発表
- **一次ソース**: Wikipedia, "GNU Bazaar"; Jelmer Vernooij, "Bazaar-NG: 7 years of hacking on a distributed version control system"
- **URL**: <https://en.wikipedia.org/wiki/GNU_Bazaar> / <https://www.jelmer.uk/pages/bzr-a-retrospective.html>
- **注意事項**: BazaarはUbuntu/Launchpadのエコシステムで広く使用されたが、Git/GitHubの普及に押されて衰退
- **記事での表現**: 「CanonicalはGNU archを基盤にBazaar（baz）を開発し、2005年にはゼロから書き直したBazaar-NG（bzr）を後継として発表した」

## 9. 分散型VCSの基本原理——全履歴のローカル保持

- **結論**: 分散型VCSの核心は、完全なコードベースと全履歴が各開発者のマシンにミラーリングされること。同期はピアツーピアでパッチ（チェンジセット）を交換して行う。中央サーバは必須ではなく、コンベンションとして運用される
- **一次ソース**: Wikipedia, "Distributed version control"
- **URL**: <https://en.wikipedia.org/wiki/Distributed_version_control>
- **注意事項**: 「分散」は「中央サーバがない」ではなく「中央サーバが必須ではない」という意味。実際の運用では多くのプロジェクトが事実上の中央リポジトリを持つ
- **記事での表現**: 「分散型VCSでは、完全なリポジトリ——コードベースとその全履歴——が各開発者のマシンに複製される。同期はピアツーピアでチェンジセットを交換して行う」

## 10. 分散型VCSの思想的背景——OSSコミュニティの開発モデル

- **結論**: Linuxカーネル開発がDVCSの動機の代表例。数千人の開発者がメーリングリストでパッチを交換する開発モデルは、中央サーバ型のVCSとは相容れなかった。Linus Torvaldsはpull-onlyモデル（メンテナが何を取り込むか決定する）を採用。GitHubのPull Requestモデルはこの系譜
- **一次ソース**: Wikipedia, "Distributed version control"
- **URL**: <https://en.wikipedia.org/wiki/Distributed_version_control>
- **注意事項**: 分散型VCSの思想は、技術的要件（オフライン作業、性能）と文化的要件（コミュニティの自律性、フォークの自由）の両面から動機づけられた
- **記事での表現**: 「Linuxカーネルの開発モデルは、分散型VCSの思想と深く共鳴していた。数千人の開発者がメーリングリストでパッチを交換し、各サブシステムのメンテナが取り込みを判断する。この自律分散的な構造は、中央サーバ型VCSの前提と根本的に相容れなかった」
