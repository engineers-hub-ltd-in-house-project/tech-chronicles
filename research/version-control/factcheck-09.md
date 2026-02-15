# ファクトチェック記録：第9回

## テーマ：Subversionの内部構造——なぜ連番リビジョンは合理的だったのか

---

## 1. FSFSリポジトリの内部構造——リビジョンファイルのフォーマット

- **結論**: FSFSでは各コミット済みリビジョンが不変（immutable）な単一ファイルとして保存される。ファイルにはnode-revision、ファイル内容の表現（representation）、変更パス情報が含まれる。リビジョンプロパティは別ファイルに保存される
- **一次ソース**: Apache Subversion Project, "FSFS structure" (libsvn_fs_fs/structure)
- **URL**: <https://svn.apache.org/repos/asf/subversion/trunk/subversion/libsvn_fs_fs/structure>
- **注意事項**: FSFSフォーマットは複数バージョンが存在し（format 1〜8+）、各バージョンで細部が異なる
- **記事での表現**: FSFSでは1リビジョン＝1ファイル。各ファイルにnode-revision（ノードのメタデータ）、representation（ファイル内容やディレクトリエントリ）、changed-paths（変更パス一覧）が格納される

## 2. Node-revisionのフォーマット

- **結論**: Node-revisionは `<name>: <value>\n` 形式のヘッダ行の連続で表現される。主要フィールド: id（識別子）、type（file/dir）、pred（前身ノード）、count（ベースからのカウント）、text（テキスト表現への参照）、props（プロパティ表現への参照）、cpath（作成時パス）、copyfrom（コピー元）、copyroot（コピールート）
- **一次ソース**: Apache Subversion Project, "FSFS structure"
- **URL**: <https://svn.apache.org/repos/asf/subversion/trunk/subversion/libsvn_fs_fs/structure>
- **注意事項**: text/propsフィールドの参照形式は `<rev> <item_index> <length> <size> <digest>` で、format 4以降はSHA1ダイジェストも含む
- **記事での表現**: node-revisionはRFC822風のヘッダ形式で記述され、ファイル種別、前身ノードへの参照、テキスト表現とプロパティ表現の場所を示す

## 3. Skip-deltaアルゴリズム

- **結論**: リビジョンNのデルタベースを選ぶには、Nを二進数で表し「最も右の1ビットを反転」する。例: 54 = 110110 → 110100 = 52がデルタベース。任意のリビジョンの復元に必要なデルタ適用はO(lg(N))回
- **一次ソース**: Apache Subversion Project, "Skip-Deltas in Subversion"
- **URL**: <https://svn.apache.org/repos/asf/subversion/trunk/notes/skip-deltas>
- **注意事項**: BDBバックエンドでは方向が逆（新しいリビジョンに対するデルタ）。FSFSでは古いリビジョンに対するデルタ。Subversion 1.8以降ではスキップデルタの前にリニアチェーンの閾値設定が追加された
- **記事での表現**: skip-deltaは「二進数表現で最も右の1ビットを反転」という規則でデルタベースを選択し、最大lg(N)回のデルタ合成で任意のリビジョンを復元可能にする

## 4. Bubble-upメソッド（コミット時のツリー構築）

- **結論**: Subversionのコミットは「bubble-up」方式で動作する。変更されたファイルの新しいnode-revisionを作成し、その親ディレクトリ、さらにその親……とルートまで遡って新しいnode-revisionを作成する。変更されていないノードは前のリビジョンのものがそのまま参照される。リポジトリのディレクトリ構造はDAG（有向非巡回グラフ）として表現される
- **一次ソース**: Apache Subversion Project, "Subversion Design"
- **URL**: <https://svn.apache.org/repos/asf/subversion/trunk/notes/subversion-design.html>
- **注意事項**: 設計文書自体は2002年10月が最後の大幅更新で一部古い記述があるが、bubble-upの説明は依然として正確
- **記事での表現**: コミット時に変更されたノードだけ新しいnode-revisionが作成され、変更のないサブツリーは前リビジョンのノードをそのまま共有する「bubble-up」方式

## 5. FSFSのシャード（shard）構造

- **結論**: Subversion 1.5（2008年リリース）でFSFSにシャードディレクトリ構造が導入された。デフォルトでは1シャードあたり1000ファイル。リビジョン0-999は db/revs/0/、1000-1999は db/revs/1/ に格納される。パッキング機能も提供され、シャード内の全リビジョンファイルを一つのpackファイルに結合可能
- **一次ソース**: Apache Subversion 1.5 Release Notes; FSFS structure document
- **URL**: <https://subversion.apache.org/docs/release-notes/1.5.html>
- **注意事項**: シャード導入以前はrevs/ディレクトリに全リビジョンファイルがフラットに配置されており、大規模リポジトリではファイルシステムの性能問題を引き起こした
- **記事での表現**: Subversion 1.5でFSFSにシャード構造が導入され、リビジョンファイルを1000個ごとのサブディレクトリに分割。大規模リポジトリでのファイルシステム性能を改善した

## 6. svnadmin dumpフォーマット

- **結論**: ダンプフォーマットにはバージョン1、2、3がある。バージョン1は最古の形式。バージョン2でUUIDレコードが追加。バージョン3はデルタダンプをサポートし、Text-delta/Prop-deltaヘッダが追加された。フォーマットはRFC822スタイルのヘッダ行で構成される。先頭行は必ず `SVN-fs-dump-format-version: N`
- **一次ソース**: Apache Subversion Project, "Subversion dumpfile format"
- **URL**: <https://svn.apache.org/repos/asf/subversion/trunk/notes/dump-load-format.txt>
- **注意事項**: ダンプファイルはリポジトリのポータブルな表現であり、異なるバックエンド間の移行にも使用される
- **記事での表現**: svnadmin dumpはリポジトリの完全なポータブル表現を生成する。バージョン3ではデルタ形式をサポートし、大規模リポジトリのダンプサイズを大幅に削減できる

## 7. 連番リビジョンが集中型アーキテクチャの帰結である理由

- **結論**: 連番リビジョンは中央サーバが一元的に番号を割り振るため衝突が原理的に発生しない。分散型VCSでは各開発者が独立にコミットするため、連番は実現不可能。Gitは代わりにSHA-1（後にSHA-256）ハッシュを採用。コミット内容のハッシュにより一意性を確保する
- **一次ソース**: SVN Book "Version Control the Subversion Way"; Git documentation "hash-function-transition"
- **URL**: <https://svnbook.red-bean.com/en/1.6/svn.basic.in-action.html>, <https://git-scm.com/docs/hash-function-transition>
- **注意事項**: Gitの短縮ハッシュ（7文字程度）は大規模リポジトリで衝突の可能性があるため、リポジトリ規模に応じて長さが調整される
- **記事での表現**: 連番リビジョンは集中型VCSの構造的利点であり、分散型では原理的に実現不可能。これは優劣ではなくアーキテクチャの帰結である

## 8. Linus Torvaldsによる「CVS done right」批判

- **結論**: 2007年5月3日、GoogleでのTech TalkにてLinus Torvaldsは「Subversionは自分が知る中で最も無意味なプロジェクトだ」「CVS done rightというスローガンから始めたら、どこにも行けない。CVSを正しくやる方法などない」と発言した
- **一次ソース**: LinusTalk200705Transcript - Git SCM Wiki
- **URL**: <https://git.wiki.kernel.org/index.php/LinusTalk200705Transcript>
- **注意事項**: この発言はLinusの誇張的な表現であり、Subversion開発者への直接的な侮辱ではなく、集中型VCSの設計パラダイム自体への批判として文脈を理解すべき
- **記事での表現**: Linusの批判は集中型パラダイムそのものへの問題提起であり、Subversionの実装品質への批判ではないことを強調して紹介する

## 9. Gitのコンテンツアドレッサブルストレージ設計

- **結論**: Gitは根本的にコンテンツアドレッサブルファイルシステムとして設計された。各オブジェクト（blob, tree, commit, tag）はその内容のSHA-1ハッシュで識別される。同一内容は同一ハッシュとなり自動的に重複排除される。ファイル破損はハッシュ不一致で即座に検出可能
- **一次ソース**: Git Documentation, "Git Objects" (Pro Git Book Chapter 10.2)
- **URL**: <https://git-scm.com/book/en/v2/Git-Internals-Git-Objects>
- **注意事項**: SHA-1からSHA-256への移行が進行中（hash-function-transition）。Linus自身は2005年の初期リリースからわずか3週間後にSHA-1の選択について議論している
- **記事での表現**: Gitは「コンテンツアドレッサブルファイルシステム」であり、内容のハッシュがそのまま識別子となる。Subversionの連番リビジョンとは根本的に異なる設計思想

## 10. リビジョンプロパティ（revprops）の保存形式

- **結論**: リビジョンプロパティ（svn:date, svn:author, svn:log）はFSFSでは db/revprops/ ディレクトリ配下にリビジョン番号のファイルとして保存される。形式はsvn_hash_writeによるハッシュダンプ形式。リビジョンプロパティはバージョン管理されない（変更すると以前の値は失われる）
- **一次ソース**: SVN Book "Repository Administration"; Subversion API documentation
- **URL**: <https://subversion.apache.org/docs/api/1.7/group__svn__props__revision__props.html>
- **注意事項**: リビジョンツリー自体は不変（immutable）だが、リビジョンプロパティは変更可能。これは設計上の意図的な判断
- **記事での表現**: リビジョンプロパティはリビジョンデータとは別ファイルに保存され、コミットメッセージの事後修正などのユースケースに対応する

---

_ファクトチェック実施日: 2026-02-15_
_検証項目数: 10_
_未検証項目: なし_
