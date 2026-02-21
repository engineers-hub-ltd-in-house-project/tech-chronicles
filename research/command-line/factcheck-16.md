# ファクトチェック記録：第16回「SSHとリモートCLI――距離を超えるテキストインターフェース」

## 1. telnetの起源（RFC 15, 1969年）

- **結論**: telnetは1969年にARPANET向けに開発された。最初の提案はRFC 15（1969年9月、Steve Carr, University of Utah）。正式な仕様はRFC 854およびRFC 855（1983年5月、J. Postel, J. Reynolds）として標準化された。Network Virtual Terminal（NVT）の概念を導入
- **一次ソース**: RFC 15 (1969), RFC 854/855 (1983), Wikipedia "Telnet"
- **URL**: <https://en.wikipedia.org/wiki/Telnet>, <https://datatracker.ietf.org/doc/html/rfc854>
- **注意事項**: telnetは最初はNCP上で動作し、後にTCPに移行した。1969年時点では非公式プロトコルであり、RFC 854での標準化は1983年
- **記事での表現**: 「telnetの最初の提案は1969年のRFC 15に遡る。正式な仕様はRFC 854/855として1983年に標準化された」

## 2. rsh/rloginの歴史とBSD由来

- **結論**: rsh、rlogin、rcpはBSD 4.2（1983年）のrloginパッケージの一部として登場。Berkeley r-commandsはBSD v4.1で初公開。認証は.rhostsによる信頼ホスト方式で、パスワードも平文送信
- **一次ソース**: Wikipedia "Berkeley r-commands", Wikipedia "Remote Shell"
- **URL**: <https://en.wikipedia.org/wiki/Berkeley_r-commands>, <https://en.wikipedia.org/wiki/Remote_Shell>
- **注意事項**: r-commandsの正確な初出はBSD 4.1cの可能性もある。セキュリティ上の問題が深刻で、SSHの登場後に事実上置き換えられた
- **記事での表現**: 「1983年のBSD 4.2で、rsh、rlogin、rcpといったBerkeley r-commandsが導入された」

## 3. SSHの発明（Tatu Ylonen, 1995年）

- **結論**: SSH（SSH-1）は1995年、Helsinki University of Technology（現Aalto University）の研究者Tatu Ylonenが、大学ネットワークでのパスワード盗聴攻撃を契機に開発。1995年7月にフリーソフトウェアとして公開。1995年末までに50カ国2万ユーザーに普及。1995年12月、YlonenはSSH Communications Securityを設立
- **一次ソース**: Wikipedia "Secure Shell", ssh.com, Ylonen's homepage
- **URL**: <https://en.wikipedia.org/wiki/Secure_Shell>, <https://ylonen.org/>
- **注意事項**: Helsinki University of Technologyは2010年にAalto Universityに統合。SSH-1は後にセキュリティ上の問題が発覚
- **記事での表現**: 「1995年、Helsinki University of TechnologyのTatu Ylonenが、大学ネットワークでのパスワード盗聴事件を契機にSSHを開発し、7月にフリーソフトウェアとして公開した」

## 4. OpenSSHの誕生（1999年、OpenBSDプロジェクト）

- **結論**: OpenSSH 1.2.2はOpenBSD 2.6（1999年12月1日）の一部として最初にリリース。Tatu Ylonenのssh 1.2.12（最後のオープンなバージョン）を基に再実装。主要開発者はAaron Campbell, Bob Beck, Markus Friedl, Niels Provos, Theo de Raadt, Dug Song
- **一次ソース**: OpenSSH公式サイト "Project History"
- **URL**: <https://www.openssh.org/history.html>, <https://en.wikipedia.org/wiki/OpenSSH>
- **注意事項**: OpenSSHはOpenBSDプロジェクトの一部であり、Theo de Raadtがプロジェクトリーダー。他OS向けのポータブル版も開発
- **記事での表現**: 「1999年12月、OpenBSD 2.6の一部としてOpenSSH 1.2.2がリリースされた。Tatu Ylonenのssh 1.2.12を基に、OpenBSDチームがセキュリティを重視して再実装したものだ」

## 5. Moshの開発（2012年、MIT）

- **結論**: Mosh（mobile shell）はKeith WinsteinとHari Balakrishnanが MIT CSAILで開発。2012年のUSENIX Annual Technical Conferenceで発表。State Synchronization Protocol（SSP）というUDPベースのプロトコルを使用。AES-128 OCB3モードで暗号化。3G回線でのキーストローク応答遅延中央値がSSHの503msに対しMoshは5ms未満
- **一次ソース**: USENIX ATC '12 論文, mosh.org
- **URL**: <https://mosh.org/>, <https://www.usenix.org/conference/atc12/technical-sessions/presentation/winstein>
- **注意事項**: Moshは初回接続にSSHを使用し、その後UDP上のSSPに切り替える
- **記事での表現**: 「2012年、MITのKeith WinsteinとHari BalakrishnanがMosh（mobile shell）を発表した。UDPベースのState Synchronization Protocol上で動作し、予測的ローカルエコーにより高レイテンシ環境でもレスポンシブな操作を実現した」

## 6. SSHプロトコルの技術アーキテクチャ

- **結論**: SSH-2はRFC 4251-4254で標準化。3層構造: (1) Transport Layer Protocol（サーバ認証、暗号化、完全性検証）、(2) User Authentication Protocol、(3) Connection Protocol（チャネル多重化、ポートフォワーディング）。TCPポート22を使用。SFTPはSSH 2.0のサブシステムとして設計
- **一次ソース**: RFC 4251, Wikipedia "Secure Shell"
- **URL**: <https://datatracker.ietf.org/doc/html/rfc4251>, <https://en.wikipedia.org/wiki/Secure_Shell>
- **注意事項**: SSHプロトコル自体はTCPポート22だが、IANAに正式登録されたのは1995年
- **記事での表現**: 「SSH-2のプロトコルアーキテクチャは、Transport Layer、User Authentication、Connectionの3層で構成され、RFC 4251-4254として標準化されている」

## 7. SSH-1からSSH-2への進化

- **結論**: SSH-2はSSH-1と互換性がない。SSH-2ではDiffie-Hellman鍵交換を導入、AES暗号を追加、MACベースのデータ整合性検証を改善。一つのSSH接続上で複数のシェルセッションを実行可能に。SSH-2はRFC 4251-4254（2006年1月）として標準化。SSH-1はサーバ鍵とホスト鍵の両方を認証に使用したが、SSH-2はホスト鍵のみ
- **一次ソース**: TechTarget "SSH2 vs SSH1", Wikipedia "Secure Shell"
- **URL**: <https://www.techtarget.com/searchsecurity/tip/An-introduction-to-SSH2>, <https://en.wikipedia.org/wiki/Secure_Shell>
- **注意事項**: SSH-1にはCRC-32補償攻撃などの脆弱性が発見されている。2006年のRFC発行時点でSSH-1は事実上非推奨
- **記事での表現**: 「SSH-2はSSH-1と互換性を持たない新設計であり、Diffie-Hellman鍵交換、AES暗号化、MACベースの完全性検証などの改善を導入した」

## 8. 1995年のフィンランド大学ネットワーク盗聴事件

- **結論**: Tatu Ylonenと同僚たちが、Helsinki University of Technologyのネットワーク上でパスワード盗聴攻撃を経験。当時のtelnet、rlogin、FTPは平文でパスワードを送信しており、攻撃者がネットワーク上でパケットを傍受してパスワードを窃取可能だった。この事件が直接的な動機となりSSHが開発された
- **一次ソース**: machaddr.substack.com "SSH: The Origins of How Tatu Ylönen Secured the Internet", Wikipedia
- **URL**: <https://machaddr.substack.com/p/ssh-the-origins-of-how-tatu-ylonen>, <https://en.wikipedia.org/wiki/Secure_Shell>
- **注意事項**: 盗聴事件の正確な日付は公開資料では特定できず。「1995年初頭」程度の記述が一般的
- **記事での表現**: 「1995年、Helsinki University of Technologyで、Ylonenと同僚たちはネットワーク上でのパスワード盗聴攻撃を経験した。telnetもrloginもFTPもパスワードを平文で送信していた」

## 9. OpenSSHの普及状況

- **結論**: OpenSSHは事実上すべてのLinuxディストリビューション、macOS、FreeBSD、OpenBSD等に標準搭載されている。Windows 10（2018年以降）にもOpenSSHクライアント/サーバが組み込まれた。6sense.comの調査ではSSHクライアントツール市場でのシェアは6.89%だが、これはWinSCP/PuTTY等のGUIツールとの比較であり、サーバ側の実装としてはOpenSSHが圧倒的多数
- **一次ソース**: 6sense.com, OpenSSH公式
- **URL**: <https://6sense.com/tech/secure-shell-ssh/openssh-market-share>, <https://www.openssh.org/press.html>
- **注意事項**: サーバ側SSHデーモンとしてのOpenSSHのシェアは別指標。ほぼすべてのLinux/BSD/macOSサーバがOpenSSHを使用している
- **記事での表現**: 「OpenSSHは事実上すべてのLinux、BSD、macOSに標準搭載されており、Windows 10以降にもクライアント・サーバの両方が組み込まれた」

## 10. Moshの技術的特徴（SSP、予測的ローカルエコー）

- **結論**: Moshの主要技術は3つ: (1) State Synchronization Protocol（SSP）: UDPベース、状態同期型プロトコル。サーバ・クライアント双方でターミナル状態を保持。(2) 予測的ローカルエコー: キーストロークをサーバの応答を待たずに表示。未確認の予測は下線で表示。(3) ステートレスローミング: クライアントのIP変更に自動追従。ハートビートは3秒ごと。AES-128 OCB3で暗号化・認証
- **一次ソース**: mosh.org, USENIX ATC '12 論文
- **URL**: <https://mosh.org/>, <https://mosh.org/mosh-paper.pdf>
- **注意事項**: Moshは初回接続にSSHを使用するため、SSHの完全な代替ではない。SSHのポートフォワーディング等の機能は非サポート
- **記事での表現**: 「Moshは、UDPベースのState Synchronization Protocol上で、クライアント・サーバ双方にターミナル状態を保持する。予測的ローカルエコーにより、サーバの応答を待たずにキーストロークを画面に反映し、サーバからの確認後に表示を確定する」

## 補足調査

### SSH ControlMasterとProxyJump

- **結論**: OpenSSH 3.9（2004年8月18日）でControlMaster/ControlPath/ControlPersistによる接続多重化をサポート。ProxyJumpはOpenSSH 7.3で導入。多段SSH接続をシンプルに構成可能
- **URL**: <https://man.openbsd.org/ssh_config>

### VNC/RDPとSSHの帯域比較

- **結論**: SSH（テキストベース）は最も帯域効率が高い。RDPはグラフィカル命令を送信するため中程度。VNCはピクセルベースのスクリーンキャプチャを送信するため最も帯域消費が大きい。SSHは衛星回線やIoT環境のような超低帯域接続でも実用的
- **URL**: <https://www.wpfastestcache.com/blog/remote-server-access-rdp-ssh-or-vnc/>
