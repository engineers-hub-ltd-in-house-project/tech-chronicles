# ファクトチェック記録：第2回

**対象記事**: 第2回「すべてはcp -rから始まった——バージョン管理以前の世界」
**調査日**: 2026-02-15
**調査手段**: WebSearch による一次ソース検証

---

## 1. OS/360プロジェクトの規模とソースコード管理

- **結論**: 1963年〜1966年にかけて開発。ピーク時の要員数は約1,000人、プロジェクト全体で5,000人年の工数を投入
- **一次ソース**: Brooks, F. P., "The Mythical Man-Month," Addison-Wesley, 1975
- **補足**: Brooksは IBM System/360 のプロジェクトマネージャを務め、その後 OS/360 のソフトウェアプロジェクトの設計フェーズを管理
- **ソースコード管理**: パンチカードと磁気テープが主な媒体。VCSは存在しない時代
- **記事での表現**: 「OS/360は5,000人年の工数を投入し、ピーク時には1,000人の開発者が参加した（Brooks, "The Mythical Man-Month", 1975）」

## 2. Multics プロジェクト

- **結論**: 1964年にMIT（Project MAC、Fernando Corbato主導）、GE、Bell Labsの共同プロジェクトとして開始。Bell Labsは1969年に離脱
- **一次ソース**: multicians.org（Multics公式歴史サイト）
- **URL**: <https://multicians.org/history.html>
- **階層的ファイルシステム**: Multicsが初めて階層的ファイルシステムを実装。Ken Thompsonは後に「Multicsから取り入れたのは階層的ファイルシステムとシェルだ」と述べている
- **GEの撤退**: 1970年にGEはコンピュータ事業をHoneywellに売却
- **記事での表現**: 「1964年、MITのProject MAC（Fernando Corbato主導）、GE、Bell Labsの共同でMulticsプロジェクトが開始された。Bell Labsは1969年に離脱した」

## 3. UNIXの誕生とソースコード管理

- **結論**: 1969年、Ken ThompsonがPDP-7上で最初のUNIXを開発。動機はファイルシステムの実験
- **PDP-7のメモリ**: 標準4Kワード（9KB）、最大64Kワード（144KB）
- **PDP-11/20への移行**: UNIXをより大きなマシンで使うために、Bell Labs特許部のワードプロセッサ需要と合わせてPDP-11/20を取得。24KBのメモリのうち12KBをOSが使用
- **一次ソース**: Ritchie, D. M. and Thompson, K., "The UNIX Time-Sharing System," CACM 17(7), 1974
- **ソースコード管理**: VCSは存在せず。PDP-7版UNIXのソースコードはBell Labs外に公開されず、後年にオリジナルのリスティングから再構成された
- **記事での表現**: 「PDP-7のメモリはわずか9KB（標準構成）。この制約の中でThompsonはUNIXの原型を書いた」

## 4. diffコマンドの詳細な歴史

- **結論**: 1970年代中盤にDouglas McIlroyとJames W. HuntがBell Labsで開発。Hunt が初期プロトタイプを開発し、McIlroyが最終版を完成
- **論文**: Hunt, J. W. and McIlroy, M. D., "An Algorithm for Differential File Comparison," Computing Science Technical Report #41, Bell Labs, July 1976
- **URL**: <https://www.cs.dartmouth.edu/~doug/diff.pdf>
- **Unix同梱**: Unix第5版（1974年）に同梱（第1回factcheckと一致）
- **McIlroyの経歴**: UNIXパイプの発明者としても知られる
- **アルゴリズム**: LCS（最長共通部分列）に基づく。Hunt-McIlroyアルゴリズムは基本的なLCS解法の時間・空間要件を典型的な入力に対して削減する改良版
- **記事での表現**: 「Hunt-McIlroyアルゴリズムは、最長共通部分列（LCS）問題の解法であり、diffで使われた最初の非ヒューリスティックなアルゴリズムの一つである（CSTR #41, 1976）」

## 5. Myersのアルゴリズム（1986年）

- **結論**: Eugene W. Myers, "An O(ND) Difference Algorithm and Its Variations," Algorithmica 1(2), 1986
- **URL**: <http://www.xmailserver.org/diff2.pdf>
- **git との関係**: Myersのdiffアルゴリズムはgitのデフォルトdiffアルゴリズムである
- **改善点**: LCS問題と最短編集スクリプト問題が等価であることを示し、「編集グラフ」上の最短経路探索として定式化。O(ND)の計算量（Nはファイルサイズ、Dは最小編集距離）で、差分が小さいときに特に高速
- **実用性能**: Hunt-Szymanski アルゴリズムに基づくSystem 5実装の2〜4倍高速
- **記事での表現**: 「Myersのアルゴリズム（1986年）は、差分が小さいときにO(ND)で動作し、gitの内部diffアルゴリズムとして採用されている」

## 6. patchコマンドの歴史

- **結論**: Larry Wallが1984年に最初のバージョンを開発、1985年5月にmod.sources（後のcomp.sources.unix）にバージョン1.3を投稿
- **一次ソース**: Wall, L., "patch version 1.3," posted to mod.sources, May 24, 1985
- **動機**: diffにはed script形式の出力オプションがあったが、context diff形式の出力を受け取って適用するプログラムは存在しなかった。Wallはcontext diff形式のパッチが、ベースファイルが変更されていても正しく適用できる利点に気づいた
- **背景**: Wall は当時 NASA JPL で働いていたプログラマ。言語学のバックグラウンドを持つ
- **影響**: patchは分散型ソフトウェア開発モデル（後のオープンソースモデル）を先取りし、促進した
- **注意事項**: 「1984年リリース」と「1985年5月投稿」の両方の記述がある。開発は1984年、mod.sourcesへの正式投稿は1985年5月24日
- **記事での表現**: 「1985年、Larry Wallがpatchコマンドをmod.sourcesに投稿した（v1.3, 1985年5月24日）」

## 7. context diff と unified diff の歴史

- **context diff (-c)**:
  - Berkeley Unix 2.8BSD（1981年7月リリース）で追加
  - -r（再帰）オプションも同時に追加
  - 変更箇所の前後の文脈（コンテキスト）を含める形式
- **unified diff (-u)**:
  - Wayne Davisonが1990年8月に開発。unidiffとしてcomp.sources.miscの第14巻に投稿
  - Richard StallmanがGNUプロジェクトのdiffに1ヶ月後に統合
  - GNU diff 1.15（1991年1月リリース）でデビュー
- **注意事項**: 第1回factcheckでは「1991年、Wayne Davison」としたが、より正確には「1990年8月に開発、1991年1月にGNU diffに取り込み」
- **記事での表現**: 「Wayne Davisonが1990年にunidiffを開発し、1991年1月のGNU diff 1.15でunified diff形式が正式に取り込まれた」

## 8. 1960-70年代のコンピューティング環境

- **パンチカード→磁気テープ**: 1960年代にパンチカードが主要なデータ記憶媒体から磁気テープに徐々に置き換わった。ただしパンチカードはデータ入力とプログラミングに1980年代中盤まで使われ続けた
- **タイムシェアリングへの移行**: 1970年代中盤までに、大規模データ処理の多くがパンチカードからタイムシェアリング環境への移行を検討していた
- **ストレージ例**: IBM 1311（1962年発表）は取り外し可能なディスクパック、容量200万文字。IBM 3340（1970年代初頭）は最大70MB
- **一次ソース**: Computer History Museum Timeline <https://www.computerhistory.org/timeline/memory-storage/>
- **記事での表現**: 「1960年代のパンチカード時代には、ソースコードは物理的な『もの』だった。コピーを取るとは、カードデッキを複製することを意味した」

## 9. tarコマンドとtarball文化

- **結論**: tarは1979年1月、Version 7 AT&T UNIXで初登場
- **名前の由来**: "tape archive" の略。元々は磁気テープへの逐次I/O用に開発
- **tarball の語源**: tar アーカイブが様々なファイルを集めることから、実際のタールボール（tar ball = タールの塊で周囲のものがくっつく）にちなんだ俗称
- **OSS配布での役割**: 1980年代後半からGNUプロジェクトがtarball形式でソフトウェアを配布。ソースファイル、ビルドスクリプト、ドキュメントを一つのポータブルなファイルにまとめる標準方式に
- **標準化**: POSIX.1-1988、後にPOSIX.1-2001で標準化
- **記事での表現**: 「1979年のUnix V7でtarコマンドが登場し、tarball形式がOSSのソースコード配布の標準となった」

## 10. USENETとmod.sources

- **USENET誕生**: 1979年にTom TruscottとJim Ellis（Duke University）が構想。Steve Bellovin がシェルスクリプトを作成。Duke と UNC が最初の2つのホスト
- **正式公開**: 1980年のUSENIX Conferenceで "A News" として配布
- **トランスポート**: UUCPをトランスポートプロトコルとして使用（「貧者のARPANET」）
- **ソフトウェア配布**: mod.sources（後のcomp.sources.unix）がソフトウェア配布チャンネルとして機能。diff/patchにより、帯域が限られた環境でファイル全体ではなく差分だけを配布できた
- **記事での表現**: 「1979年に構想され1980年に公開されたUSENETは、mod.sourcesを通じてソフトウェア配布のプラットフォームとなった」
