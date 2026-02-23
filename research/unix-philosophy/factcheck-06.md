# ファクトチェック記録: 第6回「"Everything is a file"——抽象化の極致」

## 1. UNIX First Edition（1971年）における特殊ファイル（デバイスファイル）

- **結論**: UNIX First Edition（1971年11月3日）のProgrammer's Manualには、特殊ファイル（special files）の項目が含まれている。Dennis Ritchieがデバイスファイルの概念を考案し、ハードウェアデバイスをファイルシステム内のファイルとして扱えるようにした
- **一次ソース**: K. Thompson, D.M. Ritchie, "UNIX Programmer's Manual", November 3, 1971
- **URL**: <https://www.nokia.com/bell-labs/about/dennis-m-ritchie/1stEdman.html>
- **注意事項**: V1では/devディレクトリに特殊ファイルが配置されていた。ブロックデバイスとキャラクタデバイスの区分はこの時点で既に存在
- **記事での表現**: 「1971年11月、UNIX First EditionのProgrammer's Manualには既に"special files"の項が設けられていた。Dennis Ritchieが導入したこの概念により、ハードウェアデバイスはファイルシステム内のファイルとして表現されるようになった」

## 2. UNIXにおけるファイルの7種類（POSIX定義）

- **結論**: POSIXが定義するUNIXファイルタイプは7種類——通常ファイル（regular）、ディレクトリ（directory）、シンボリックリンク（symbolic link）、FIFO（名前付きパイプ）、ブロックデバイス（block special）、キャラクタデバイス（character special）、ソケット（socket）
- **一次ソース**: POSIX.1 (IEEE 1003.1), Unix file types — Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Unix_file_types>
- **注意事項**: ls -lの先頭文字で区別可能（-, d, l, p, b, c, s）
- **記事での表現**: 「POSIXが定義するUNIXのファイルタイプは7種類ある。通常ファイル、ディレクトリ、シンボリックリンク、名前付きパイプ（FIFO）、ブロックデバイス、キャラクタデバイス、ソケット——これらすべてがファイルディスクリプタという統一的なインタフェースで操作される」

## 3. VFS（Virtual File System）の歴史——Sun Microsystems、1985年

- **結論**: 最初のVFS機構はSun MicrosystemsがSunOS 2.0（1985年5月リリース、4.2BSDベース）で導入した。NFSをサポートするために、ローカルのUFSとリモートのNFSを透過的に扱う抽象レイヤーが必要となったことが動機。VFS interfaceとvnode interfaceの二層構造で設計された
- **一次ソース**: R. Sandberg et al., "Design and Implementation of the Sun Network Filesystem", USENIX Summer Conference, 1985
- **URL**: <https://cs.ucf.edu/~eurip/papers/sandbergnfs.pdf>
- **注意事項**: Sun以外のUNIXベンダーもNFSコードのライセンスに伴いVFS設計を模倣した
- **記事での表現**: 「1985年、Sun MicrosystemsはSunOS 2.0でVFS（Virtual File System）層を導入した。NFSという新しいファイルシステムをカーネルに統合するため、ローカルとリモートのファイルシステムを透過的に扱う抽象レイヤーが必要になったのだ」

## 4. Linux /procファイルシステムの起源と歴史

- **結論**: procfsの概念はUNIX V8（8th Edition、1984年）に遡る。Tom J. Killianが実装し、1984年6月のUSENIXで"Processes as Files"として発表。Linuxでは1992年9月のv0.97.3で初めて/procが追加され、1992年12月のv0.98.6でプロセス以外のシステム情報にも拡張された。Plan 9のprocファイルシステムから明示的に影響を受けている
- **一次ソース**: Tom J. Killian, "Processes as Files", USENIX, June 1984
- **URL**: <https://en.wikipedia.org/wiki/Procfs>
- **注意事項**: 元々はptrace()システムコールの代替として設計された。Linux版は後にプロセス以外の情報も大量に含むようになり、本来の設計意図を超えて肥大化した
- **記事での表現**: 「/procの歴史はLinux以前に遡る。1984年、Tom J. KillianがUNIX V8に実装し、USENIXで"Processes as Files"として発表した。プロセスの情報をファイルとして読み取れるようにするこの仕組みは、Plan 9を経由してLinuxに受け継がれ、1992年のLinux v0.97.3で導入された」

## 5. Linux sysfs（/sys）ファイルシステムの歴史

- **結論**: sysfsはLinuxカーネル2.6（2003年12月リリース）で導入された。Patrick Mochelが2.5開発サイクル中に設計。/procの肥大化を解消し、デバイスモデルの情報をエクスポートするためのファイルシステムとして設計された。カーネル2.4の問題点（統一的なドライバ-デバイス関係の表現方法の欠如、ホットプラグ機構の不在、procfsの乱雑化）を解決することが動機
- **一次ソース**: Patrick Mochel, "The sysfs Filesystem", Ottawa Linux Symposium, 2005
- **URL**: <https://www.kernel.org/doc/ols/2005/ols2005v1-pages-321-334.pdf>
- **注意事項**: ブループリントでは2004年と記載されているが、カーネル2.6.0のリリースは2003年12月。sysfsに関するOLS論文は2005年
- **記事での表現**: 「2003年、Patrick MochelはLinuxカーネル2.6にsysfs（/sysファイルシステム）を導入した。肥大化した/procの負担を軽減し、デバイスモデルの情報を構造化された形でユーザ空間に公開するためだ」

## 6. FUSE（Filesystem in Userspace）の歴史

- **結論**: Miklos SzerediがFUSEの開発を2001年に開始。最初の安定版（v1.0）は2003年2月19日リリース。2004年にLinuxカーネル2.6サポートを追加。2005年にLinuxカーネル2.6.14にマージされた。カーネルモジュール（fuse.ko）、ユーザ空間ライブラリ（libfuse）、マウントユーティリティ（fusermount）の3コンポーネントで構成される
- **一次ソース**: Miklos Szeredi, "Introducing FUSE: Filesystem in USErspace", LWN.net, 2001
- **URL**: <https://lwn.net/2001/1115/a/fuse.php3>
- **注意事項**: FUSEにより非特権ユーザでもファイルシステムの実装・マウントが可能に。sshfs、ntfs-3g、s3fsなど多数のユーザ空間ファイルシステムがFUSE上に構築された
- **記事での表現**: 「2001年、Miklos SzerediがFUSE（Filesystem in Userspace）の開発を開始した。2005年にLinuxカーネル2.6.14に正式にマージされ、非特権ユーザでもファイルシステムを実装・マウントできるようになった」

## 7. Plan 9の設計——9Pプロトコル、per-process名前空間、ユニオンマウント

- **結論**: Plan 9 from Bell Labs（1992年初公開、2002年オープンソース化）はRob Pike、Ken Thompson、Dave Presotto、Phil Winterbottomらが設計。9P（後のStyx、最新版は9P2000）は14のメッセージで構成されるファイル指向プロトコル。per-process名前空間により各プロセスグループが独自のファイルシステムビューを持つ。rfork()はビットベクタ引数で親子プロセス間の属性共有/コピーを細粒度で制御。ユニオンディレクトリにより複数のサービスを一つのディレクトリにマウント可能
- **一次ソース**: Rob Pike et al., "Plan 9 from Bell Labs", USENIX Summer Conference, 1990/1995
- **URL**: <https://9p.io/plan9/about.html>
- **注意事項**: Plan 9はUNIXの「すべてはファイル」を完全に実現した。ネットワーク、ウィンドウシステム、プロセスまでファイルシステムとして扱う
- **記事での表現**: 「Plan 9は、UNIXの"すべてはファイルである"を限界まで徹底した。9Pプロトコル（わずか14メッセージ）であらゆるリソースをファイル操作に還元し、per-process名前空間で各プロセスが独自のファイルシステムビューを持つ」

## 8. UTF-8の発明——Rob PikeとKen Thompson、1992年

- **結論**: 1992年9月、Rob PikeとKen ThompsonがNew Jerseyのダイナーのプレースマット（紙ナプキン）の上でUTF-8を設計した。Ken Thompsonがビットパッキングを考案。その晩のうちにPlan 9をUTF-8に変換した。1992年9月8日午前3:22にKen Thompsonがメールで変換完了を報告。自己同期（self-synchronizing）特性によりどの位置からでも文字境界を検出可能
- **一次ソース**: Rob Pike, "UTF-8 history" (email), 2003
- **URL**: <https://doc.cat-v.org/bell_labs/utf-8_history>
- **注意事項**: X/Open委員会がオースティンで会議中にPikeとThompsonに電話。Plan 9が最初にUTF-8を完全サポートしたOS
- **記事での表現**: 「1992年9月、Rob PikeとKen ThompsonはNew Jerseyのダイナーでプレースマットの上にUTF-8を設計した。Thompsonがビットパッキングを考案し、その夜のうちにPlan 9全体をUTF-8に変換した」

## 9. /dev/null, /dev/zero, /dev/urandomの歴史

- **結論**: /dev/nullはUNIX Version 4（1973年）の時代から存在するとされる（Wikipediaでは"empty regular file in Version 4 Unix"と記載）。/dev/zeroはELF共有ライブラリの読み込みに使用される重要なデバイスファイル。/dev/urandomは1994年にLinuxで導入され、その後他のUnix系OSにも広がった。Theodore Ts'oが/dev/randomと/dev/urandomを実装
- **一次ソース**: Null device — Wikipedia; /dev/random — Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Null_device>, <https://en.wikipedia.org/wiki//dev/random>
- **注意事項**: /dev/nullの正確な初出バージョンについては追加検証が望ましい
- **記事での表現**: 「/dev/nullは初期のUNIXから存在するデバイスファイルで、書き込まれたデータをすべて破棄する。/dev/zeroは無限のゼロバイトを生成する。/dev/urandomは1994年にLinuxに導入された擬似乱数デバイスだ」

## 10. ioctl()——「すべてはファイル」の限界と批判

- **結論**: ioctl()はUNIXの「すべてはファイル」パラダイムを破る代表的なシステムコール。read()/write()だけではハードウェアデバイスの全機能にアクセスできないため、デバイス固有の操作にioctl()が必要。ドキュメント化の不十分さ、イントロスペクション不能、32ビット/64ビット互換性の問題（1993年の型変更に起因）、コンテナセキュリティの迂回リスクなどが批判されている
- **一次ソース**: Jonathan Corbet, "ioctl() forever?", LWN.net, 2022
- **URL**: <https://lwn.net/Articles/897202/>
- **注意事項**: Linuxの無線ネットワーキングサブシステムはioctl()から脱却に成功。ただし、ファイルシステムやブロックレイヤーでは依然として多用されている
- **記事での表現**: 「ioctl()は"すべてはファイル"の原則に対する最も顕著な例外だ。open/read/write/closeだけではデバイスの全機能を表現できない——この限界に対する妥協としてioctl()は存在する」

## 11. REST APIの統一インタフェースとの関連

- **結論**: Roy FieldingがRESTを定義した2000年の博士論文では、UNIXのPipe-and-Filterスタイルが代替アーキテクチャスタイルとして検討されている。RESTの「統一インタフェース」制約（リソースの識別、表現によるリソース操作、自己記述メッセージ、HATEOAS）は、UNIXの「すべてをファイルとして統一的に操作する」発想と構造的に類似するが、Fieldingの論文で直接的な因果関係が明示されているわけではない
- **一次ソース**: Roy T. Fielding, "Architectural Styles and the Design of Network-based Software Architectures", University of California, Irvine, 2000
- **URL**: <https://ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm>
- **注意事項**: 直接的な影響関係の主張は慎重に。構造的なアナロジーとして語るのが適切
- **記事での表現**: 「RESTの"統一インタフェース"制約は、UNIXの"すべてはファイル"と構造的に類似する。リソースに対する操作の標準化——UNIXではopen/read/write/close、RESTではGET/POST/PUT/DELETE——という設計思想は、異なる文脈で同じ原理を表現している」
