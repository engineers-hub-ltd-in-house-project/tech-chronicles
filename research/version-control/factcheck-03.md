# ファクトチェック記録：第3回

**対象記事**: 第3回「SCCS/RCS——自動化への第一歩」
**調査日**: 2026-02-15
**調査手段**: WebSearch による一次ソース検証

---

## 1. SCCS の開発経緯と原論文

- **結論**: 1972年、Marc RochkindがBell LabsにてSNOBOL4言語でIBM System/370（OS/360 MVT）上に開発。1973年にC言語でUNIX（PDP-11）向けに書き直し。最初の公開リリースはSCCS v4（1977年2月18日）
- **一次ソース**: Rochkind, M. J., "The Source Code Control System," IEEE Transactions on Software Engineering, Vol. SE-1, No. 4, pp. 364-370, December 1975
- **URL**: <https://dl.acm.org/doi/10.1109/TSE.1975.6312866>
- **注意事項**: 開発は1972年だが論文発表は1975年。IEEE TSE初期の最も影響力のある論文の一つとされる。Rochkind自身による回顧論文が2024年にIEEE TSEに掲載されている
- **記事での表現**: 「1972年、Bell LabsのMarc RochkindはSCCS（Source Code Control System）をSNOBOL4言語で開発した。翌1973年にはC言語でUNIX向けに書き直された（Rochkind, IEEE TSE, 1975）」

## 2. RCS の開発経緯と原論文

- **結論**: 1982年、Walter F. TichyがPurdue Universityで開発。SCCSの改良版として設計。プロプライエタリなSCCSに対するフリーな代替手段という動機もあった
- **一次ソース**: Tichy, W. F., "RCS—A System for Version Control," Software—Practice and Experience, Vol. 15, No. 7, pp. 637-654, July 1985
- **URL**: <https://www.gnu.org/software/rcs/tichy-paper.pdf>
- **注意事項**: 初期の技術レポート "Design, Implementation and Evaluation of a Revision Control System" は1982年3月25日付でPurdue e-Pubsに登録。論文の正式発表は1985年だが、ソフトウェアのリリースは1982年
- **記事での表現**: 「1982年、Purdue UniversityのWalter F. TichyがRCS（Revision Control System）を発表した（Tichy, Software—Practice and Experience, 1985）」

## 3. SCCS インターリーブドデルタ（weave）形式

- **結論**: 全リビジョンの全行を一つのデータブロックに「織り込む」（weave）方式。制御行（^AI serial, ^AD serial, ^AE serial）で各行がどのリビジョンに属するかを示す
- **一次ソース**: BitKeeper Documentation, "Document the SCCS weave"; Oracle Solaris manpages, sccsfile(4)
- **URL**: <https://www.bitkeeper.org/src-notes/SCCSWEAVE.html>
- **注意事項**: ^AI = insert（挿入開始）、^AD = delete（削除開始）、^AE = end（ブロック終了）。serial番号はデルタ（変更セット）に対応。任意のリビジョンの取り出し時間はアーカイブ全体のサイズに比例する（均一な取り出し時間）
- **記事での表現**: 「SCCSのインターリーブドデルタは、全リビジョンの行を制御命令とともに一つのファイルに織り込む。どのリビジョンを取り出しても時間は均一だが、リビジョンが増えるほどファイル全体が大きくなる」

## 4. RCS リバースデルタ形式

- **結論**: トランク上の最新リビジョンを完全な形で保存し、それより古いリビジョンは逆方向のデルタ（リバースデルタ）として保存。ブランチにはフォワードデルタを使用
- **一次ソース**: Tichy, W. F., "RCS—A System for Version Control," 1985; GNU RCS Manual
- **URL**: <https://www.gnu.org/software/rcs/manual/rcs.html>
- **注意事項**: 最新リビジョンの取り出しは単純なコピー操作で高速。古いリビジョンほど多くのデルタを適用する必要があり遅くなる。Tichyは「最新リビジョンが最も頻繁に使われる」ため合理的と主張
- **記事での表現**: 「RCSのリバースデルタ方式は、最新リビジョンを完全な形で保存し、古いリビジョンを逆方向の差分として保持する。最もよく使われる最新版の取り出しが最速になる設計だ」

## 5. SCCS s.ファイルの命名規則と構造

- **結論**: SCCSファイルは `s.filename` という命名規則。6つの論理部分で構成: (1) チェックサム、(2) デルタテーブル（各変更の情報・統計）、(3) ユーザ名（変更権限のあるユーザ）、(4) フラグ（内部キーワード定義）、(5) コメント（説明情報）、(6) ボディ（テキスト行と制御行の混在）
- **一次ソース**: Oracle Solaris manpages, sccsfile(4)
- **URL**: <https://docs.oracle.com/cd/E86824_01/html/E54775/sccsfile-4.html>
- **注意事項**: チェックサムは最初の行に配置。ボディ部分がインターリーブドデルタの実体。ロックファイルは `p.filename` として別に管理
- **記事での表現**: 「SCCSは管理対象ファイルごとに `s.filename` という管理ファイルを作成する。内部は6つのセクション（チェックサム、デルタテーブル、ユーザ名、フラグ、コメント、ボディ）から構成される」

## 6. RCS ,v ファイルの構造

- **結論**: RCSファイルは `filename,v` という命名規則（またはRCSサブディレクトリ内に配置）。最新リビジョンの完全なテキスト + メタデータ + リバースデルタを含む。デルタは行ベースの編集コマンド（挿入と削除）の列
- **一次ソース**: GNU RCS Manual, "comma-v particulars"; rcsfile(5) man page
- **URL**: <https://www.gnu.org/software/rcs/manual/html_node/comma_002dv-particulars.html>
- **注意事項**: 文字列値は `@` で囲み、内部の `@` は二重化。日付はY.m.d.H.M.S形式。トランクのノードはnextフィールドで降順にリンク
- **記事での表現**: 「RCSは `filename,v` という管理ファイルを生成する。最新リビジョンの完全なテキストと、古いリビジョンへのリバースデルタが格納される」

## 7. SCCS/RCS のファイルロック機構

- **結論**:
  - **SCCS**: `get -e` で排他ロックを取得（p.ファイルを生成）。`delta` でチェックインしロックを解放。`unget` でロックのみ解放。他ユーザは同じリビジョンの編集用取得不可（読み取り専用は可能）。ロック解除には特権ユーザが必要
  - **RCS**: `co -l` でロック付きチェックアウト。`ci` でチェックイン。strict locking モード（`rcs -L`）とnon-strict（`rcs -U`）を選択可能。非特権ユーザでもロック破棄可能で、ロック保持者にメール通知
- **一次ソース**: Oracle SCCS documentation; GNU RCS Manual, Quick tour
- **URL**: <https://www.gnu.org/software/rcs/manual/html_node/Quick-tour.html>
- **注意事項**: RCSのロック破棄時のメール通知機能はSCCSにはなく、UX改善の一つ
- **記事での表現**: 「SCCSもRCSもファイル単位のロック方式を採用したが、RCSはロックの柔軟性を改善した。SCCSでは特権ユーザのみがロックを解除できたが、RCSでは一般ユーザでもロックを破棄でき、保持者にメール通知が送られた」

## 8. 主要コマンド

- **結論**:
  - **SCCS**: `get`（取得）、`get -e`（編集用取得）、`delta`（チェックイン）、`prs`（履歴表示）、`unget`（ロック解放）、`admin`（管理ファイル作成）
  - **RCS**: `ci`（チェックイン）、`co`（チェックアウト）、`rcsdiff`（差分表示）、`rlog`（履歴表示）、`rcs`（属性変更）、`rcsmerge`（マージ）、`rcsclean`（クリーンアップ）
- **一次ソース**: GNU RCS Manual; Oracle SCCS manpages
- **URL**: <https://www.gnu.org/software/rcs/manual/rcs.html>
- **注意事項**: RCSは操作対象として作業ファイル名でもカンマvファイル名でも指定可能（SCCSでは管理ファイル名を指定する必要があった）
- **記事での表現**: 記事内のハンズオンでci/co/rcsdiffの実行例を示す

## 9. GNU CSSC（SCCS互換ソフトウェア）

- **結論**: GNU CSCCは「Compatibly Stupid Source Control」の略で、GNUプロジェクトによるSCCS互換実装。バグ互換性を含む完全な互換性を目指す。古いSCCS形式のソースコード取得が主目的
- **一次ソース**: GNU CSSC Project Page
- **URL**: <https://www.gnu.org/software/cssc/>
- **注意事項**: CSCCは「取得後はgitやSubversionなどの近代的なVCSに移行すること」を推奨している
- **記事での表現**: 「GNU CSCCはSCCSのフリーソフトウェア互換実装だが、プロジェクト自身が『取得後は近代的なVCSへの移行を推奨する』と述べている」

## 10. RCS の現代での利用可能性

- **結論**: GNU RCS 5.10.1がUbuntuのuniverseリポジトリで利用可能。`apt install rcs` でインストール可能。Ubuntu 22.04 LTS, 24.04 LTS, 24.10, 25.04で確認済み
- **一次ソース**: Ubuntu Packages
- **URL**: <https://packages.ubuntu.com/rcs>
- **注意事項**: ci, co, ident, merge, rcs, rcsclean, rcsdiff, rcsmerge, rlog の各コマンドが含まれる
- **記事での表現**: ハンズオンで `apt install rcs` によるインストールと基本操作を示す
