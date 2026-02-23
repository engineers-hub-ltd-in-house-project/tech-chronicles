# ファクトチェック記録：第22回「UNIX哲学の限界――何がうまくいかなかったか」

## 1. X Window Systemの設計と「mechanism not policy」原則

- **結論**: X Window Systemは1984年にMITのBob ScheiflerとJim Gettys（Project Athena）が共同で開発を開始した。設計原則として「Provide mechanism rather than policy. In particular, place user interface policy in the clients' hands.」を掲げた。この「ポリシーではなくメカニズムを提供する」という方針は、UNIX哲学の延長線上にあるが、結果としてデスクトップ環境の断片化（CDE、KDE、GNOME、その後のMATEやCinnamon等）を招いた
- **一次ソース**: Robert W. Scheifler, Jim Gettys, "The X Window System", ACM Transactions on Graphics, 1986
- **URL**: <https://dl.acm.org/doi/10.1145/22949.24053>
- **注意事項**: X11はバージョン11（1987年）を指す。初期のXは1984年6月にMIT Project Athenaコミュニティにメールで紹介された
- **記事での表現**: 1984年、MITのBob ScheiflerとJim GettyはX Window Systemを設計するにあたり、「ポリシーではなくメカニズムを提供せよ」という原則を掲げた。ユーザインタフェースのポリシーはクライアントに委ねる。これはUNIX哲学の延長線上にある思想だったが、その結果、UNIXの世界は統一的なGUI体験を持てないまま30年以上が過ぎた

## 2. UNIX-HATERS Handbookにおけるテキストパイプラインの脆弱性批判

- **結論**: 『The UNIX-HATERS Handbook』（1994年、Simson Garfinkel, Daniel Weise, Steven Strassmann編）は、UNIX哲学の限界を正面から批判した書籍。第8章でシェルスクリプトの脆弱性（fragile text parsing）を指摘。Eric S. Raymondも後に「シェルスクリプトはデータ構造と真の手続き的合成をサポートする言語に置き換えられるべき」という批判は正当だったと認めている
- **一次ソース**: Simson Garfinkel, Daniel Weise, Steven Strassmann (eds.), "The UNIX-HATERS Handbook", IDG Books, 1994
- **URL**: <https://archive.org/details/TheUnixHatersHandbook>
- **注意事項**: Dennis Ritchie自身がこの本に反序文（Anti-Foreword）を寄せている点は注目に値する
- **記事での表現**: 1994年に出版された『The UNIX-HATERS Handbook』は、UNIX哲学の暗部を容赦なく暴いた。テキストストリームに依存するパイプラインの脆弱さ、シェルスクリプトのクォート処理の不合理さ――これらの批判は、PerlやPythonの台頭によって事実上正当化された

## 3. PowerShellとMonad Manifesto――オブジェクトパイプラインの提案

- **結論**: Jeffrey Snoverは2002年8月8日に「Monad Manifesto」を執筆し、テキストストリームではなく.NETオブジェクトをパイプラインで渡すシェルを提案した。開発コード名「Monad」として2003年10月のPDC（Professional Development Conference）で初公開。2006年11月にWindows PowerShell 1.0としてリリース。Snoverの問題提起は「UNIXはテキストファイルを編集して管理するが、Windowsはオブジェクトを操作するAPIで管理する」という根本的な設計差異にあった
- **一次ソース**: Jeffrey P. Snover, "Monad Manifesto", Microsoft, Aug 8, 2002
- **URL**: <https://www.jsnover.com/Docs/MonadManifesto.pdf>
- **注意事項**: Snoverは2015年にMicrosoft Technical Fellowに昇進。PowerShellは2016年にオープンソース化
- **記事での表現**: 2002年、MicrosoftのJeffrey Snoverは「Monad Manifesto」を書いた。UNIXのテキストパイプラインの限界を正面から指摘し、構造化されたオブジェクトをパイプラインで渡すシェルを提案した文書だ

## 4. UNIX終了コードの8ビット制限

- **結論**: POSIXの`exit()`関数は引数として`int`型（32ビット）を受け取るが、`wait()`/`waitpid()`システムコールでは下位8ビット（0-255）のみが親プロセスに渡される。Single UNIX Specificationは「status & 0377」のみが利用可能と規定。`waitid()`（SUSv1で追加）では`siginfo_t`構造体を通じて完全な終了ステータスにアクセス可能
- **一次ソース**: The Open Group, "exit - terminate a process", POSIX.1
- **URL**: <https://pubs.opengroup.org/onlinepubs/009695299/functions/exit.html>
- **注意事項**: 実用上、0が成功、1-255がエラーだが、どのコードがどのエラーを意味するかの標準はない（一部の慣例のみ存在）
- **記事での表現**: UNIXのエラーハンドリングは0から255の終了コードに集約される。成功は0、それ以外はエラー。だが「どの種類のエラーか」を伝える手段としては貧弱すぎる

## 5. GUIとUNIXの相性問題――Macintosh（1984年）とX Window System

- **結論**: Apple Macintosh（1984年1月24日発売）は、GUIを標準とした最初の商業的成功を収めたパーソナルコンピュータ。一方、UNIXの世界ではX Window System（1984年MIT）が開発されたが、「mechanism not policy」の方針によりルック＆フィールが統一されず。CDE（1993年、HP/IBM/SunSoft/USL共同発表）、KDE（1996年、Matthias Ettrich）、GNOME（1997年、Miguel de Icaza & Federico Mena）と分裂が続いた
- **一次ソース**: Wikipedia, "Common Desktop Environment"; KDE Timeline; Wikipedia, "GNOME"
- **URL**: <https://en.wikipedia.org/wiki/Common_Desktop_Environment>
- **注意事項**: GNOMEの誕生はQtのライセンス問題（当時は商用利用有料）への対抗が動機
- **記事での表現**: 1984年、Macintoshが統一されたGUI体験を世に示した同じ年に、UNIXの世界ではX Window Systemが誕生した。だがUNIX哲学の「メカニズムは提供するがポリシーは規定しない」という原則は、GUIの世界では裏目に出た

## 6. テキストストリームの型なし問題と構造化データの台頭

- **結論**: XML（1998年、W3C勧告）、JSON（2001年、Douglas Crockford考案、ECMA-404として2013年標準化）、Protocol Buffers（2001年Google内部開発、2008年オープンソース化）の登場は、テキストストリームの「型なし」問題への解答。Protocol Buffersはテキストではなくバイナリ形式で、スキーマ定義によりフィールドの型を保証する
- **一次ソース**: Google, "Protocol Buffers Overview"
- **URL**: <https://protobuf.dev/overview/>
- **注意事項**: JSONはJavaScript Object Notationの略で、元来はJavaScriptのサブセットだが現在は言語独立
- **記事での表現**: UNIXのパイプラインが「テキスト」を万能インタフェースとしたのに対し、21世紀のソフトウェアはXML、JSON、Protocol Buffersといった構造化データ形式を必要とした

## 7. Nushell――構造化データシェルの試み

- **結論**: Nushell（Nu）はRustで実装された現代的なシェルで、PowerShellや関数型プログラミング言語から着想を得ている。テキストストリームではなく構造化データ（テーブル、JSON等）をパイプラインで渡す。`ls`の出力はプレーンテキストではなくテーブルとして返される。他にElvish（構造化データパイプライン対応）やOh等の代替シェルも存在する
- **一次ソース**: Nushell公式リポジトリ
- **URL**: <https://github.com/nushell/nushell>
- **注意事項**: NushellはPOSIX互換ではなく、従来のシェルスクリプトとの互換性はない
- **記事での表現**: 2019年に登場したNushellは、UNIX哲学の限界に対する一つの回答だ。パイプラインを流れるのはテキストではなく構造化データ。`ls | where size > 10mb`のような型安全なフィルタリングが可能になった

## 8. uid/gidベースのセキュリティモデルの限界

- **結論**: UNIXの伝統的なアクセス制御はuid（ユーザID）、gid（グループID）、ファイルパーミッション（rwx）の3層構造。粒度が粗く、「ファイルの所有者/グループ/その他」の3区分しかない。setuid/setgidビットは権限昇格の脆弱性（バッファオーバーランやパスインジェクション）の温床。POSIX ACLで拡張されたが、根本的な設計は変わっていない
- **一次ソース**: O'Reilly, "Practical UNIX and Internet Security, 3rd Edition", Chapter 6
- **URL**: <https://www.oreilly.com/library/view/practical-unix-and/0596003234/ch06s05.html>
- **注意事項**: Linuxではnamespaces、capabilities（POSIX capabilities）、SELinux、AppArmor等で拡張されているが、基盤モデルはuid/gid
- **記事での表現**: UNIXのセキュリティモデルは、uid/gidとファイルパーミッションの組み合わせに依存している。この設計は1970年代の信頼されたユーザコミュニティには十分だったが、インターネットに接続された世界では粒度が粗すぎる

## 9. Capability-based securityとCapsicum

- **結論**: Capability-based securityの概念はJ.B. DennisとE.C. Van Hornが1966年に提唱。Capsicumは2010年にRobert N.M. Watson（ケンブリッジ大学コンピュータ研究所）らがUSENIX Security Symposiumで発表したUNIX向けの実用的なcapabilityフレームワーク。FreeBSD 9.0（2012年）に組み込まれた。capability modeではグローバルなOSネームスペース（ファイルシステム、IPCネームスペース）へのアクセスが制限され、委譲された権利（通常はファイルディスクリプタまたはcapability）のみが利用可能
- **一次ソース**: Robert N. M. Watson et al., "Capsicum: practical capabilities for UNIX", 19th USENIX Security Symposium, 2010
- **URL**: <https://www.usenix.org/legacy/event/sec10/tech/full_papers/Watson.pdf>
- **注意事項**: tcpdump、gzip、OpenSSH、Chromium等がCapsicumプリミティブに対応
- **記事での表現**: 2010年、ケンブリッジ大学のRobert Watsonらは「Capsicum: practical capabilities for UNIX」を発表した。ファイルディスクリプタをcapabilityとして拡張し、プロセスのサンドボックス化を実現するフレームワークだ

## 10. Wayland vs X11の設計論争

- **結論**: Waylandは2008年にKristian Hogsberg（当時Red Hat）が開発を開始したX11の後継ディスプレイプロトコル。X11の問題点として、ネットワーク透過性による不要な複雑さ、クライアントとウィンドウマネージャ間の通信プロトコルとしての非効率性（Daniel Stoneの表現で「really terrible communications protocol」）が挙げられる。Waylandはゼロから現代的な用途に合わせて設計されたが、2025年時点でもX11の完全な代替には至っていない
- **一次ソース**: Daniel Stone, "The real story behind Wayland and X", LCA 2013
- **URL**: <https://people.freedesktop.org/~daniels/lca2013-wayland-x11.pdf>
- **注意事項**: Waylandは特定のデスクトップ環境に依存しないプロトコルだが、実際にはコンポジターごとの実装差異が新たな断片化を生んでいる
- **記事での表現**: X11の設計問題は「メカニズムは提供するがポリシーは規定しない」というUNIX哲学そのものに起因する。Waylandはこの40年分の技術的負債を清算しようとする試みだが、15年以上経った今もX11を完全に置き換えてはいない
