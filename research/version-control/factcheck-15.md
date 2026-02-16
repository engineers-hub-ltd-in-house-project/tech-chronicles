# ファクトチェック記録：第15回「Gitオブジェクトモデル——blob, tree, commit, tag」

調査日: 2026-02-16

---

## 1. Plan 9 Ventiと内容アドレス可能ストレージの思想的ルーツ

- **結論**: VentiはSean QuinlanとSean Dorwardが開発したPlan 9のネットワークストレージシステムで、ブロックの内容のSHA-1ハッシュをブロック識別子として使用する。2002年のUSENIX FAST '02で論文が発表され、Best Paper Awardを受賞した。gitの内容アドレス可能ストレージは、このVentiやMonotoneから着想を得た設計であり、CAS（Content-Addressable Storage）の系譜に位置づけられる
- **一次ソース**: Quinlan, S. and Dorward, S., "Venti: A New Approach to Archival Data Storage", USENIX FAST '02, 2002
- **URL**: <https://www.usenix.org/conference/fast-02/venti-new-approach-archival-data-storage>, <https://en.wikipedia.org/wiki/Content-addressable_storage>
- **注意事項**: gitがVentiから「直接」影響を受けたかは文献上明示的ではない。MonotoneがSHA-1ベースのCASを先行実装し、gitはMonotoneのアイデアを参考にしたことは明確。Ventiは「CAS思想の源流の一つ」として位置づけるのが正確
- **記事での表現**: Plan 9のVentiを思想的ルーツとして紹介しつつ、gitへの直接的影響はMonotone経由であった点を明記する

## 2. gitオブジェクトのSHA-1ハッシュ計算方法

- **結論**: gitはオブジェクトのSHA-1ハッシュを計算する際、「{type} {size}\0{content}」というヘッダを内容に付加した上でSHA-1を計算する。例えばblobオブジェクトの場合、"blob 11\0hello world"という文字列のSHA-1が計算される。typeにはblob/tree/commit/tagのいずれかが入り、sizeはcontentのバイト数（10進数）
- **一次ソース**: Git SCM, "Git Internals - Git Objects", Pro Git Book
- **URL**: <https://git-scm.com/book/en/v2/Git-Internals-Git-Objects>
- **注意事項**: このヘッダ付加は全オブジェクトタイプで共通。ハッシュ計算後、zlib DEFLATEで圧縮して.git/objects/{先頭2文字}/{残り38文字}に格納
- **記事での表現**: ヘッダフォーマットを正確に示し、読者が手動で検証できる具体例を提供する

## 3. SHA-256への移行状況

- **結論**: Git 2.29（2020年10月）でSHA-256リポジトリの実験的サポートが導入。Git 2.42（2023年8月）でSHA-256リポジトリは「実験的な好奇心」ではなくなったと宣言。Git 2.51（2025年8月）で内部のplumbingがSHA-256をさらに理解・サポート。Git 2.52-rc0ではSHA1-SHA256の相互運用性作業が開始。brian m. carlsonの見積もりでは移行に200-400パッチが必要で、約100が完了。Git 3.0（2026年末目標）でSHA-256がデフォルトになる予定
- **一次ソース**: Git SCM, "hash-function-transition Documentation"; Help Net Security, "Git 2.51"; Phoronix, "Git 2.52-rc0"; LWN.net, "Git considers SHA-256, Rust, LLMs, and more"
- **URL**: <https://git-scm.com/docs/hash-function-transition>, <https://www.helpnetsecurity.com/2025/08/19/git-2-51-sha-256/>, <https://www.phoronix.com/news/Git-2.52-rc0-Released>, <https://lwn.net/Articles/1042172/>
- **注意事項**: 2026年2月現在、GitHub/GitLab/BitbucketのSHA-256完全対応はまだ。Git 3.0の2026年末リリースは「目標」であり確定ではない
- **記事での表現**: SHA-256移行は進行中であること、Git 3.0でデフォルト化が目標であることを記述し、2026年現在の具体的状況も併記する

## 4. zlib圧縮とlooseオブジェクトの格納形式

- **結論**: gitのlooseオブジェクトは「{type} {size}\0{content}」をzlib DEFLATE（RFC 1950/1951）で圧縮したものを格納する。格納先は .git/objects/{SHA-1先頭2文字}/{SHA-1残り38文字}。先頭2文字をディレクトリ名にするのは、1ディレクトリに大量のファイルが集中することを避けるため（ファイルシステム性能対策）
- **一次ソース**: Git SCM, "Git Internals - Git Objects"; blog.vmsplice.net, "Git Internals of how objects are stored"
- **URL**: <https://git-scm.com/book/en/v2/Git-Internals-Git-Objects>, <http://blog.vmsplice.net/2016/05/git-internals-of-how-objects-are-stored.html>
- **注意事項**: looseオブジェクトはデルタ圧縮されない（packファイルのみ）。圧縮レベルはcore.compression/core.looseCompressionで設定可能
- **記事での表現**: 格納プロセスを段階的に説明し、ファイルシステム操作だけで実装されている点を強調する

## 5. packファイルの形式とデルタ圧縮

- **結論**: packファイルは4バイトシグネチャ（'PACK'）、4バイトバージョン番号（現在はバージョン2）、4バイトオブジェクト数のヘッダで始まる。デルタ圧縮は2種類: OBJ_OFS_DELTA（パック内の相対オフセットでベースオブジェクトを指定）とOBJ_REF_DELTA（20バイトのSHA-1でベースオブジェクトを指定）。デルタデータはcopy命令（ベースオブジェクトからバイト範囲をコピー）とinsert命令（新データを挿入）の列で構成される
- **一次ソース**: Git SCM, "Packfiles" (Pro Git); Git SCM, "pack-format Documentation"; gitformat-pack(5)
- **URL**: <https://git-scm.com/book/en/v2/Git-Internals-Packfiles>, <https://git-scm.com/docs/pack-format>, <https://man7.org/linux/man-pages/man5/gitformat-pack.5.html>
- **注意事項**: OFS_DELTAの方がコンパクト（3-5%縮小）。デルタチェーンの深さはpack.depth（デフォルト50）で制限される。packファイルには.idxファイル（インデックス）が付随する
- **記事での表現**: 概念モデルとしてスナップショット型でありながら、ストレージ層ではデルタ圧縮を行う二層構造を強調する

## 6. annotated tag vs lightweight tagの内部構造

- **結論**: lightweight tagは.git/refs/tags/{tag名}にcommitのSHA-1を書き込んだ41バイトのファイル。gitオブジェクトは作成されない。annotated tagは独立したtagオブジェクトを.git/objectsに作成する。tagオブジェクトには参照先オブジェクトのSHA-1、オブジェクトタイプ、タグ名、tagger情報（名前、メール、日時）、メッセージ、オプションのGPG署名が含まれる。git describeはデフォルトでannotated tagのみを対象とする
- **一次ソース**: Git SCM, "git-tag Documentation"; initialcommit.com, "What is an Annotated Tag in Git?"
- **URL**: <https://git-scm.com/docs/git-tag>, <https://initialcommit.com/blog/git-annotated-tag>
- **注意事項**: tag -a, -s, -uで作成されたタグがannotated tag。lightweight tagは単なる参照であり、gitオブジェクトモデルの4つ目のオブジェクトタイプではない（tagオブジェクトが4つ目）
- **記事での表現**: 4つのオブジェクトタイプの説明でtagオブジェクト（annotated tag）を正確に区別する

## 7. treeオブジェクトのエントリ形式

- **結論**: treeオブジェクトの各エントリは「{mode} {name}\0{20バイトSHA-1}」のバイナリ形式。modeは100644（通常ファイル）、100755（実行可能ファイル）、120000（シンボリックリンク）、040000（サブディレクトリ）、160000（gitlink/サブモジュール）のいずれか。gitが追跡するパーミッションは限定的（UNIXの柔軟なパーミッションのサブセット）
- **一次ソース**: Git SCM, "Git Internals - Git Objects"; initialcommit.com, "What is a tree in Git?"
- **URL**: <https://git-scm.com/book/en/v2/Git-Internals-Git-Objects>, <https://initialcommit.com/blog/what-is-a-tree-in-git>
- **注意事項**: treeエントリのバイナリ形式はgit cat-file -pで人間可読な形式に変換される。cat-file -pの出力は「{mode} {type} {hash}\t{name}」
- **記事での表現**: treeオブジェクトの構造をASCII図で示し、modeの意味を表形式で整理する

## 8. git gcとオブジェクトライフサイクル

- **結論**: git gcは内部でgit prune、git repack、git pack-refs等を実行する。looseオブジェクトが約6,700個を超えるとgit gc --autoが自動的にpackを実行。packファイルが50個を超えると統合される。到達不能オブジェクトはデフォルトで2週間の猶予期間後に削除される（--prune=2weeks.ago）
- **一次ソース**: Git SCM, "git-gc Documentation"; Atlassian, "Git gc: Complete Guide"
- **URL**: <https://git-scm.com/docs/git-gc>, <https://www.atlassian.com/git/tutorials/git-gc>
- **注意事項**: reflogがオブジェクトを参照している限り、git gcはオブジェクトを削除しない。reflogのデフォルト有効期限は90日（到達可能）/ 30日（到達不能）
- **記事での表現**: オブジェクトのライフサイクル（作成→loose→pack→gc）を図解する

## 9. commitオブジェクトのauthor vs committer

- **結論**: commitオブジェクトにはauthorとcommitterの2つの情報が記録される。authorは変更の原著者（パッチを書いた人）、committerはそのパッチをリポジトリに適用した人。Linuxカーネル開発では、パッチの著者（author）とそれをマージしたメンテナ（committer）が異なることが日常的であり、この区別はgitの設計当初から組み込まれていた
- **一次ソース**: Git SCM, "Git Internals - Git Objects"; Wikipedia, "Git"
- **URL**: <https://git-scm.com/book/en/v2/Git-Internals-Git-Objects>, <https://en.wikipedia.org/wiki/Git>
- **注意事項**: git logの--format=%an（author）と%cn（committer）で確認可能。git am（メールからのパッチ適用）やgit cherry-pickでは両者が異なりうる
- **記事での表現**: Linuxカーネル開発のワークフローと結びつけて、この設計判断の背景を説明する

## 10. blobオブジェクトがファイル名を持たない設計

- **結論**: gitのblobオブジェクトはファイルの内容のみを格納し、ファイル名・パーミッション・パスの情報を持たない。ファイル名とblobの対応付けはtreeオブジェクトが行う。この設計により、同一内容のファイルは名前やパスに関係なく自動的に重複排除される。リネーム検出はgit diffやgit logが類似度ベースのヒューリスティックで事後的に行う
- **一次ソース**: Git SCM, "Git Internals - Git Objects"; medium.com/gitopia, "Git: A Stupid Content Tracker"
- **URL**: <https://git-scm.com/book/en/v2/Git-Internals-Git-Objects>, <https://medium.com/gitopia/git-a-stupid-content-tracker-d0ef5b86865f>
- **注意事項**: リネーム検出の閾値はデフォルトで50%（-M50%）。git log --followで特定ファイルのリネームを追跡可能。Linusは「gitはコンテンツを追跡するのであって、ファイルを追跡するのではない」と明言している
- **記事での表現**: blobがファイル名を持たない設計の意味と帰結（重複排除、リネーム検出のヒューリスティック方式）を解説する
