# ファクトチェック記録：第3回「クライアント/サーバモデル——計算の分散が始まった日」

## 1. IBM PC（5150）の発売日と仕様

- **結論**: IBM PC 5150は1981年8月12日に発売。Intel 8088プロセッサ（4.77MHz）、16KB〜256KBメモリ、ISA拡張スロット5基。基本価格$1,565。フロリダ州ボカラトンのチームがWilliam C. LoweおよびPhilip Don Estridgeの指揮のもとに開発した
- **一次ソース**: IBM Archives, Wikipedia "IBM Personal Computer"
- **URL**: <https://en.wikipedia.org/wiki/IBM_Personal_Computer>
- **注意事項**: 「パーソナルコンピュータの登場」として言及する際、IBM PCが最初のPCではないが、事実上の業界標準（IBM PC互換機）を確立した点が重要
- **記事での表現**: 1981年8月、IBMはIBM PC（Model 5150）を発売した。Intel 8088プロセッサ、最大256KBのメモリ。価格は$1,565から

## 2. Novell NetWareの歴史とLAN市場支配

- **結論**: 最初のNetWare製品は1983年にリリース（NetWare 68/S-Net）。1980年代後半から1990年代前半にかけてLAN OS市場を支配し、市場シェアは63〜70%に達した。世界中で50万以上のNetWareベースネットワーク、5,000万以上のユーザーを擁した。IPX/SPXプロトコルを使用（XeroxのIDP/SPPに由来）。NetWare 5（1998年）でTCP/IPを主要プロトコルに切り替え
- **一次ソース**: Wikipedia "NetWare", Wikipedia "Novell"
- **URL**: <https://en.wikipedia.org/wiki/NetWare>, <https://en.wikipedia.org/wiki/Novell>
- **注意事項**: NetWare 386（1989年）が大きな転機。Windows NTの登場（1993年）以降、徐々にシェアを失った
- **記事での表現**: 1980年代後半から1990年代前半、Novell NetWareはLAN OS市場で60%以上のシェアを誇った。世界中で50万を超えるNetWareベースネットワークが稼働し、5,000万以上のユーザーが利用していた

## 3. Sun Microsystemsの設立と「The Network is the Computer」

- **結論**: 1982年2月24日、Scott McNealy、Andy Bechtolsheim、Vinod Khoslaの3名のスタンフォード大学院生が設立。Bill Joy（BSD開発者）がまもなく合流し、4人の共同創業者とされる。「The Network is the Computer」はJohn Gageが1984年に考案したスローガン（Scott McNealyの発案ではない）。SUNは「Stanford University Network」に由来
- **一次ソース**: Wikipedia "Sun Microsystems", Wikipedia "The Network is the Computer", IEEE Spectrum
- **URL**: <https://en.wikipedia.org/wiki/Sun_Microsystems>, <https://en.wikipedia.org/wiki/The_Network_is_the_Computer>
- **注意事項**: ブループリントでは「1984年」と記載されているが、Sunの設立は1982年。スローガンが1984年。両者を混同しないこと
- **記事での表現**: 1982年に設立されたSun Microsystemsは、1984年にJohn Gageが考案した「The Network is the Computer」というスローガンを掲げた

## 4. Windows NT Serverの発売

- **結論**: Windows NT 3.1（最初のWindows NTリリース）は1993年7月27日に発売。Advanced Server版も同日。250人のプログラマが560万行のコードを書き、開発費は1億5,000万ドル。ワークステーション版$495、サーバ版$1,495。発売後約30万コピーを販売
- **一次ソース**: Wikipedia "Windows NT 3.1", Microsoft TechCommunity
- **URL**: <https://en.wikipedia.org/wiki/Windows_NT_3.1>, <https://techcommunity.microsoft.com/blog/sbs/30-years-of-windows-server/3884810>
- **注意事項**: NT 3.1のバージョン番号はWindows 3.1との整合性を持たせるため。NT自体は新規設計のOS
- **記事での表現**: 1993年7月、MicrosoftはWindows NT 3.1を発売した。250人のプログラマが560万行のコードを書いた新規設計のOSだった

## 5. RPC（Remote Procedure Call）の歴史

- **結論**: RPCの概念は少なくとも1976年から文献に登場。Andrew D. BirellとBruce Jay Nelsonが1984年にACM Transactions on Computer Systemsに「Implementing Remote Procedure Calls」を発表。Xerox PARCのCedar環境で実装された。1994年にACM Software System Award受賞、2007年にSigOps Hall of Fame入り
- **一次ソース**: Birrell & Nelson, "Implementing Remote Procedure Calls", ACM TOCS, Vol. 2, No. 1, February 1984
- **URL**: <https://dl.acm.org/doi/10.1145/2080.357392>
- **注意事項**: RPC自体の概念はBirrell/Nelson以前から存在するが、実用的な実装と論文化は彼らの功績
- **記事での表現**: 1984年、Xerox PARCのAndrew BirellとBruce Nelsonが「Implementing Remote Procedure Calls」を発表した。ローカルのプロシージャ呼び出しと同じ構文で、ネットワーク越しの処理を呼び出す仕組みだ

## 6. CORBAの歴史

- **結論**: CORBA 1.0はObject Management Group（OMG）により1991年に採択・公開された（正式仕様は1991年10月）。言語やプラットフォームに依存しない分散オブジェクト通信の標準を目指した。IDL（Interface Definition Language）を定義
- **一次ソース**: OMG CORBA History, Wikipedia "Common Object Request Broker Architecture"
- **URL**: <https://www.omg.org/corba/history_of_corba.htm>, <https://en.wikipedia.org/wiki/Common_Object_Request_Broker_Architecture>
- **注意事項**: CORBAは標準化を目指したが、実装の複雑さから実用では苦戦した
- **記事での表現**: 1991年、Object Management Group（OMG）はCORBA 1.0を公開した。言語やプラットフォームに依存しない分散オブジェクト通信の標準だった

## 7. DCOM（Distributed Component Object Model）

- **結論**: DCOMは1996年にWindows NT 4.0とともに導入された。元々は「Network OLE」と呼ばれていた。MicrosoftのCOM（Component Object Model）を拡張し、ネットワーク越しのコンポーネント通信を実現。DCE/RPC（のMicrosoft拡張版であるMSRPC）を基盤とする
- **一次ソース**: Wikipedia "Distributed Component Object Model"
- **URL**: <https://en.wikipedia.org/wiki/Distributed_Component_Object_Model>
- **注意事項**: CORBAのMicrosoft版として競合関係にあった
- **記事での表現**: 1996年、MicrosoftはWindows NT 4.0とともにDCOM（Distributed Component Object Model）を発表した。COMをネットワークに拡張し、分散コンポーネント間の通信を実現した

## 8. Berkeleyソケットの歴史

- **結論**: Berkeleyソケット（BSD sockets）はカリフォルニア大学バークレー校のCSRG（Computer Systems Research Group）が開発し、1983年8月のBSD 4.2で導入された。DARPA資金により開発。William N. Joy、Samuel J. Leffler、Robert S. Fabryらが主要貢献者。Rob Gurwitzが1981年秋にTCP/IPプロトタイプを提供し、Joyが4.1a（1982年4月）から統合・改良
- **一次ソース**: Wikipedia "Berkeley sockets"
- **URL**: <https://en.wikipedia.org/wiki/Berkeley_sockets>
- **注意事項**: 現代のすべてのOSがBerkeleyソケットインターフェースの派生を実装している
- **記事での表現**: 1983年、BSD 4.2がBerkeleyソケットAPIを導入した。TCP/IPをカーネルに直接実装し、ネットワークプログラミングの標準インターフェースとなった

## 9. シンクライアント/ファットクライアントの用語

- **結論**: 「シンクライアント」という用語は1993年にOracle社のサーバマーケティング担当VPであるTim Negrisが考案。Larry Ellisonが自身のスピーチや取材で頻繁に使用し、広く普及した。ファットクライアント（シッククライアント）はその対比概念として1990年代に定着
- **一次ソース**: Wikipedia "Thin client"
- **URL**: <https://en.wikipedia.org/wiki/Thin_client>
- **注意事項**: シンクライアントの概念自体はメインフレーム時代の端末に遡るが、用語としては1990年代
- **記事での表現**: 「シンクライアント」という用語は1993年にOracle社のTim Negrisが考案し、Larry Ellisonがスピーチで繰り返し使用して広まった

## 10. 3層アーキテクチャの起源

- **結論**: 3層アーキテクチャ（Three-tier architecture）は1992年にJohn J. Donovanが設立したOpen Environment Corporation（OEC、マサチューセッツ州ケンブリッジ）で開発された。OECはCambridge Technology Groupの一部門として始まり、1992年にスピンアウト。1995年2月にNASDAQに上場（ティッカーOPEN）。2001年に閉鎖
- **一次ソース**: Wikipedia "Multitier architecture", Wikipedia "John J. Donovan"
- **URL**: <https://en.wikipedia.org/wiki/Multitier_architecture>, <https://en.wikipedia.org/wiki/John_J._Donovan>
- **注意事項**: 3層アーキテクチャは2層（クライアント/サーバ）の限界を克服するために考案された
- **記事での表現**: 1992年、John J. DonovanのOpen Environment Corporationが3層アーキテクチャを考案した。プレゼンテーション層、ビジネスロジック層、データ層を分離する設計だ
