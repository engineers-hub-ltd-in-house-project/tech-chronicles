# ファクトチェック記録：第5回

**対象記事**: 第5回「CVSの栄光と限界——SourceForge時代の記憶」
**調査日**: 2026-02-15
**調査手段**: WebSearch による一次ソース検証

---

## 1. SourceForge全盛期の統計

- **結論**: SourceForgeは2002年以降、1日約100プロジェクトのペースで成長し、2005年に登録プロジェクト数10万件を突破した。2005年5月17日時点で登録ユーザー数は1,074,424人に達していた。2007年には約150,000プロジェクトが存在し、2009年8月には月間3,300万訪問者を記録した。2013年5月時点で300,000以上のプロジェクト、300万以上の登録ユーザーを抱えていた
- **一次ソース**: Wikipedia, "SourceForge"; SourceForge Community Blog; Search Engine Journal
- **URL**: <https://en.wikipedia.org/wiki/SourceForge>, <https://sourceforge.net/blog/brief-history-sourceforge-look-to-future/>, <https://www.searchenginejournal.com/sourceforgenet-reaches-100000-open-source-project-milestone/1733/>
- **注意事項**: 第4回で「2001年末に約30,000プロジェクト」と記述済み。第5回では2002年以降の成長曲線と全盛期の規模を扱う
- **記事での表現**: 「2002年以降は1日100件のペースでプロジェクトが増加し、2005年には10万プロジェクトを突破した。登録ユーザーは100万人を超えていた」

## 2. CVSのアトミックコミット不在

- **結論**: CVSのコミットはアトミックではない。操作はディレクトリ単位で順次処理され、各ディレクトリのリポジトリロックを順番に取得する。コミットの途中で中断すると、リポジトリが不整合な状態に陥る可能性がある。トップレベルでのロックを行わない理由は、大規模プロジェクトでロック競合が頻発するためである
- **一次ソース**: Wikipedia, "Atomic commit"; durak.org CVS FAQ; GNU CVS Manual
- **URL**: <https://en.wikipedia.org/wiki/Atomic_commit>, <https://durak.org/sean/pubs/software/cvsbook/My-commits-seem-to-happen-in-pieces-instead-of-atomically.html>
- **注意事項**: CVSが元来RCSのラッパーであることが根本原因。ファイル単位のRCS操作を束ねているだけで、トランザクション機構がない
- **記事での表現**: 「CVSのコミットはアトミックではなかった。ディレクトリ単位で順次処理され、途中で中断するとリポジトリが不整合な状態に陥る」

## 3. CVSのディレクトリバージョン管理不可

- **結論**: CVSはディレクトリをバージョン管理対象として扱うことができない。ディレクトリの削除は不可能で、中のファイルをすべて削除してもディレクトリ自体は残る。空ディレクトリを作業コピーに展開しないようにするには `cvs update -P` や `cvs checkout -P` の `-P` フラグが必要。ディレクトリのリネームは各ファイルを個別にリネームする必要がある
- **一次ソース**: GNU CVS Manual v1.11.23, "Moving directories"; O'Reilly Essential CVS
- **URL**: <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Moving-directories.html>, <https://www.oreilly.com/library/view/essential-cvs/0596004591/ch03s08.html>
- **注意事項**: CVSのAtticディレクトリは、trunkのheadリビジョンがdead状態のRCSファイルを格納する場所
- **記事での表現**: 「CVSにはディレクトリをバージョン管理する仕組みが存在しなかった。ディレクトリの追加や削除、リネームは、CVSの設計が対応していない操作だった」

## 4. CVSのリネーム非対応

- **結論**: CVSにはファイルのリネーム（移動）を追跡する機能がない。リネームする場合は新旧ファイルを手動で操作する必要があり、リネーム前後の履歴の連続性が失われる。推奨される手順は「新しい名前でcvs addし、古い名前でcvs removeする」だが、これでは旧ファイルの履歴が新ファイルに引き継がれない
- **一次ソース**: Russ Allbery, "Renaming files and directories in CVS"; GNU CVS Manual
- **URL**: <https://www.eyrie.org/~eagle/notes/cvs/renaming-files.html>, <https://web.mit.edu/gnu/doc/html/cvs_14.html>
- **注意事項**: リポジトリのファイルシステムを直接操作する裏技（,vファイルを手動でリネーム）も存在したが、公式に推奨されない方法だった
- **記事での表現**: 「CVSにはファイルのリネームを追跡する機能がなかった。名前を変えるには新しいファイルとしてaddし、古いファイルをremoveするしかなく、変更履歴の連続性は断たれた」

## 5. CVSのバイナリファイル扱いの問題

- **結論**: CVSはデフォルトでテキストファイルを想定しており、行末変換（LFとCR+LFの相互変換）とキーワード展開（$Id$, $Revision$ 等）を行う。バイナリファイルに対してこれらの処理が適用されると、ファイルが破損する。バイナリファイルには `-kb` オプションで明示的に指定する必要がある。さらに、キーワード展開モードはバージョン管理されないため、同じファイルが古いリビジョンではテキスト、新しいリビジョンではバイナリという場合に対応できない
- **一次ソース**: GNU CVS Manual v1.11.23, "Binary howto"; O'Reilly Essential CVS
- **URL**: <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Binary-howto.html>, <https://www.oreilly.com/library/view/essential-cvs/0596004591/ch03s11.html>
- **注意事項**: CVSのdiff/mergeもテキスト前提であり、バイナリファイルのマージは不可能
- **記事での表現**: 「CVSはテキストファイルを前提に設計されており、バイナリファイルには行末変換やキーワード展開によってデータが破損する危険があった」

## 6. CVSのキーワード展開メカニズム

- **結論**: CVSはRCSから継承したキーワード展開機能を持つ。ファイル内の `$keyword$` 形式の文字列が、checkout/update時に `$keyword: value$` 形式に展開される。主要キーワードは `$Id$`（ファイル名・リビジョン・日時・著者の組み合わせ）、`$Revision$`（リビジョン番号）、`$Date$`（チェックイン日時）、`$Author$`（著者名）、`$Log$`（変更ログ）など。`-kn` オプションでキーワード名のみ出力、`-kb` でバイナリモード（展開しない）
- **一次ソース**: GNU CVS Manual v1.11.23, "Keyword list"
- **URL**: <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Keyword-list.html>
- **注意事項**: キーワード展開はRCSからの直接的な継承機能。Subversionにも簡易版が存在するが、gitでは廃止された
- **記事での表現**: 「CVSはファイル内の $Id$ や $Revision$ といったキーワードを自動展開する機能を持っていた。便利な反面、バイナリファイルを破損する原因にもなった」

## 7. 主要OSSプロジェクトのCVSからの移行

- **結論**: 主要OSSプロジェクトは2000年代半ば以降、CVSから順次移行した。KDEは2005年5月にSubversionへ移行（変換スクリプトの実行に38時間）。PythonはPEP 347に基づき2006年にCVSからSubversionへ移行。MozillaはCVSからMercurialへ2007年に移行。FreeBSDのsrcリポジトリは2008年5月31日にCVSからSubversionへ移行。GNOMEはCVSからSubversionを経て2009年にGitへ移行
- **一次ソース**: KDE.news; PEP 347; FreeBSD Forums; GNOME Wiki
- **URL**: <https://dot.kde.org/2005/05/05/kdes-switch-subversion-complete/>, <https://peps.python.org/pep-0347/>, <https://forums.freebsd.org/threads/version-control-in-freebsd-subversion-cvs-perforce-and-git.78144/>
- **注意事項**: 多くのプロジェクトがcvs2svnツールを使用して変換を行った。CVSからGitへの直接移行よりも、CVS→SVN→Git/Mercurialという段階的移行が多い
- **記事での表現**: 「2005年以降、KDE、Python、Mozilla、FreeBSD、GNOMEといった大規模OSSプロジェクトが相次いでCVSから移行した。これはCVSの限界が臨界点に達したことの証左だった」

## 8. PEP 347——PythonのCVSからの脱却理由

- **結論**: PEP 347は、PythonソースコードをSourceForge上のCVSリポジトリからsvn.python.org上のSubversionリポジトリへ移行することを提案した文書。移行理由として明示されたCVSの限界は: ファイルとディレクトリのリネーム・削除が履歴を保って行えないこと、アトミックでない高速なタグ付け（CVSではtagging操作に数分かかることがあった）、グローバルリビジョン番号によるチェンジセットのサポートの欠如
- **一次ソース**: PEP 347, Python Enhancement Proposals
- **URL**: <https://peps.python.org/pep-0347/>
- **注意事項**: PEP 347はCVSの限界を具体的に列挙しており、CVSからの移行理由の一次ソースとして極めて有用
- **記事での表現**: 「PythonプロジェクトがPEP 347でCVSからの移行を決定した際、その理由として挙げられたのは、ファイル・ディレクトリのリネーム追跡の欠如、タグ付けの低速さ、チェンジセット概念の不在だった」

## 9. SubversionがCVSの後継として設計された経緯

- **結論**: SubversionはCVSの「明確な後継者」として設計された。開発者のBen Collins-Sussman、Brian W. Fitzpatrick、C. Michael Pilatoは、CVSに似たルック・アンド・フィールを持つオープンソースシステムを作り、CVSの目立つ欠陥の大部分を修正することを目標とした。「CVS done right」というフレーズは広く使われた
- **一次ソース**: "Version Control with Subversion" (Subversion Book); SVN Book "Subversion for CVS Users"
- **URL**: <https://svnbook.red-bean.com/en/1.8/svn.forcvs.html>
- **注意事項**: Subversion 1.0は2004年にリリースされた
- **記事での表現**: 「Subversionは明確に『CVSの欠陥を修正する』ことを目標に設計された。CVSの限界リストは、そのままSubversionの要件定義書となった」

## 10. SourceForgeの衰退とGitHubの台頭

- **結論**: SourceForgeの四半期収益は2005年時点で100万ドル。2008年にGitHubが登場し、2011年にはReadWriteWebがGitHubのコミット数がSourceForgeとGoogle Codeを上回ったと報じた。SourceForgeは後にアドウェアバンドル等の問題で信頼を失った
- **一次ソース**: Wikipedia, "SourceForge"; Wikipedia, "GitHub"
- **URL**: <https://en.wikipedia.org/wiki/SourceForge>, <https://en.wikipedia.org/wiki/GitHub>
- **注意事項**: SourceForgeの衰退は第5回の主題ではないが、CVSの栄光期の文脈として触れる価値がある
- **記事での表現**: 「2008年のGitHub登場以降、OSSエコシステムの中心はSourceForgeからGitHubへ急速に移行した」
