# ファクトチェック記録：第11回「商用UNIXの栄華と黄昏——Solaris, AIX, HP-UX」

## 1. Sun Microsystems の設立と SunOS/Solaris の歴史

- **結論**: Sun Microsystemsは1982年2月24日、Scott McNealy、Andy Bechtolsheim、Vinod Khoslaによって設立された。Bill Joy（BSD開発者）がまもなく参加し、共同創業者に数えられる。社名「SUN」はStanford University Networkの頭文字。1982年後半からSunOS（4.2BSDベース）を提供。1980年代後半、AT&TとSunが共同でSystem V Release 4（SVR4）を開発。SunはSVR4をベースにSolaris 2.xを開発し、1991年にSolarisとしてリリース。SunOS 1.0〜4.1.4はBSDベース、SunOS 5.0以降はSVR4ベースでSolarisブランドとなった
- **一次ソース**: Wikipedia "Sun Microsystems", ETHW "Sun Microsystems", Wikipedia "SunOS"
- **URL**: <https://en.wikipedia.org/wiki/Sun_Microsystems>, <https://ethw.org/Sun_Microsystems>, <https://en.wikipedia.org/wiki/SunOS>
- **注意事項**: SunOS→Solarisの名称変更は段階的。SunOS 4.1.xは後にSolaris 1.xと遡及的に呼ばれた
- **記事での表現**: Sun Microsystemsは1982年に設立され、BSDベースのSunOSを提供。1991年にSVR4ベースのSolarisへ移行した

## 2. IBM AIX の歴史

- **結論**: AIXは1986年にIBM RT PC向けに最初にリリースされた。System V Releases 1/2ベースに4.2/4.3 BSDのソースコードを組み込んでいた。1985年にIBM Watson研究所で「AMERICA architecture」の研究が開始、1986年にIBM AustinでRS/6000の開発開始。1990年2月、POWER命令セットを搭載した最初のコンピュータ「RISC System/6000」（RS/6000）が出荷され、AIX Version 3がリリースされた。RS/6000は後にeServer pSeries → System p → Power Systemsと改名
- **一次ソース**: Wikipedia "IBM AIX", Wikipedia "IBM RS/6000"
- **URL**: <https://en.wikipedia.org/wiki/IBM_AIX>, <https://en.wikipedia.org/wiki/IBM_RS/6000>
- **注意事項**: AIXの最初のリリース年は1986年（RT PC向け）だが、主要プラットフォームとしてはRS/6000（1990年）から
- **記事での表現**: IBMは1986年にAIXをRT PC向けにリリース。1990年、POWERアーキテクチャを搭載したRS/6000とともにAIX Version 3を投入し、エンタープライズUNIX市場に本格参入した

## 3. HP-UX の歴史

- **結論**: HP-UXは1984年に最初にリリースされた（HP Integral PC向けのHP-UX 1.0）。System III（後にSystem V）ベース。PA-RISCの開発は1982年にHP Laboratoriesで開始（Precision Architecture）。1986年にPA-RISC搭載のHP 9000 Series 840が出荷。HP 9000ブランドは1984年に導入。2026年1月にHP-UXの最後のサポートバージョンが終了（The Register報道）
- **一次ソース**: Wikipedia "HP-UX", Wikipedia "PA-RISC", The Register "The last supported version of HP-UX is no more"
- **URL**: <https://en.wikipedia.org/wiki/HP-UX>, <https://en.wikipedia.org/wiki/PA-RISC>, <https://www.theregister.com/2026/01/05/hpux_end_of_life/>
- **注意事項**: HP-UXはSystem IIIベースで開始し、後にSystem Vベースに移行。PA-RISCは2008年末に廃止、後継はItanium（IA-64）
- **記事での表現**: Hewlett-Packardは1984年にHP-UXをリリース。1986年にPA-RISCアーキテクチャ搭載のHP 9000シリーズとともにエンタープライズ市場に展開した

## 4. IRIX（SGI）と Tru64 UNIX（DEC）の歴史

- **結論**: IRIXはSilicon Graphics（SGI）がMIPSワークステーション/サーバ向けに開発したOS。1988年のリリース3.0でIRIXの名称を採用。System Vベース+BSD拡張。XFSファイルシステムとOpenGL APIを生み出した。1990年代初頭にはSMPで先駆的存在（1〜1,024プロセッサ以上のシングルシステムイメージ）。2006年9月6日にMIPS/IRIX開発終了を発表。Tru64 UNIXはDECがAlpha ISA向けに開発した64bit UNIX。OSF/1ベース（Machカーネル）。1995年にOSF/1 AXPからDigital UNIXに改名。1998年CompaqによるDEC買収後、Tru64 UNIXに改名。2002年HPのCompaq買収後、AdvFS、TruCluster等の技術をHP-UXに移植する計画を発表。最終保守リリースは2010年10月
- **一次ソース**: Wikipedia "IRIX", Wikipedia "Tru64 UNIX", Wikipedia "DEC Alpha"
- **URL**: <https://en.wikipedia.org/wiki/IRIX>, <https://en.wikipedia.org/wiki/Tru64_UNIX>, <https://en.wikipedia.org/wiki/DEC_Alpha>
- **注意事項**: IRIXはXFSとOpenGLの発祥地として技術史的に重要。Tru64はMachカーネルベースという点でユニーク
- **記事での表現**: SGIのIRIXはXFSファイルシステムとOpenGLを生み出し、DECのTru64 UNIXはAlphaプロセッサ上で64bit UNIXの先駆となった

## 5. Solaris ZFS の開発・リリース

- **結論**: ZFSの開発は2001年にSun MicrosystemsでJeff Bonwick、Bill Moore、Matthew Ahrensのチームにより開始。2004年9月14日に発表。2005年10月31日にSolaris開発トランクに統合。2005年11月16日にOpenSolarisのbuild 27として開発者向けリリース。2006年6月、Solaris 10 6/06アップデートで正式一般公開
- **一次ソース**: Wikipedia "ZFS", Klara Systems "History of ZFS - Part 1", OpenZFS "History"
- **URL**: <https://en.wikipedia.org/wiki/ZFS>, <https://klarasystems.com/articles/history-of-zfs-part-1-the-birth-of-zfs/>, <https://openzfs.org/wiki/History>
- **注意事項**: ブループリントには「ZFS（2004年）」とあるが、発表が2004年、Solaris統合が2005年、一般公開が2006年。記事では正確な経緯を記述する
- **記事での表現**: ZFSは2001年にSunで開発が始まり、2004年に発表、2005年にSolarisに統合、2006年にSolaris 10で一般公開された

## 6. DTrace の開発・リリース

- **結論**: DTraceの開発は2001年にSun MicrosystemsでBryan Cantrillにより開始。Adam LeventhalとMike Shapiroが参加しコアチームを形成。2003年11月に初めて利用可能に。2005年1月、Solaris 10の一部として正式リリース。CDDLでオープンソース化されたOpenSolarisの最初のコンポーネント（2005年1月25日）。InfoWorld（2005年）とWall Street Journal Technology Innovation Awards（2006年、最優秀賞）で受賞
- **一次ソース**: Wikipedia "DTrace", Oracle "DTrace Tutorial", Brendan Gregg "DTrace Tools"
- **URL**: <https://en.wikipedia.org/wiki/DTrace>, <https://www.oracle.com/solaris/technologies/dtrace-tutorial.html>, <https://www.brendangregg.com/dtrace.html>
- **注意事項**: ブループリントには「DTrace（2005年）」とあるが、開発開始は2001年、初利用は2003年、正式リリースはSolaris 10（2005年1月）
- **記事での表現**: DTraceは2001年にBryan Cantrillが開発を開始し、2005年1月にSolaris 10の一部として正式リリースされた

## 7. Solaris Zones / Containers

- **結論**: Solaris Zones（後のSolaris Containers）はOS レベルの仮想化技術。2004年2月にSolaris 10のbuild 51ベータで初公開。2005年のSolaris 10正式リリースで一般公開。BSD Jailsの概念から着想を得て、Dan PriceとAndy Tuckerらが開発。OS仮想化として初の本格的なプロダクション対応実装とされる。2007年頃からSolaris ZonesにResource Managementを組み合わせたものを「Solaris Containers」と呼ぶようになった。Joyentが2006年にSolaris Zonesベースのホスティング事業を構築
- **一次ソース**: Wikipedia "Solaris Containers", O'Reilly "Oracle Solaris 10 Virtualization Essentials"
- **URL**: <https://en.wikipedia.org/wiki/Solaris_Containers>, <https://www.oreilly.com/library/view/oracle-solaris-10/9780137084067/ch06.html>
- **注意事項**: Zonesは「コンテナの先駆」としてDockerとの思想的接続が指摘されている。ただし技術的にはLinuxのcgroups/namespacesとは独立した実装
- **記事での表現**: Solaris Zonesは2005年にSolaris 10で公開されたOS レベルの仮想化技術で、現代のコンテナ技術の先駆となった

## 8. IBM AIX WPAR（Workload Partitions）

- **結論**: WPARは2007年にAIX Version 6.1で導入。2年間のベータテストを経てリリース。RBAC（Role-based Access Control）とともにAIX 6の二大機能で、カーネルレベルの根本的変更が伴ったためバージョン番号が5.3→6に上がった。AIXのOS仮想化技術で、LPARの補完的位置づけ。2008年11月のAIX V6.1 TL2で機能強化
- **一次ソース**: IBM Redbooks "Workload Partition Management in IBM AIX Version 6.1", Wikipedia "Workload Partitions"
- **URL**: <https://www.redbooks.ibm.com/abstracts/sg247656.html>, <https://en.wikipedia.org/wiki/Workload_Partitions>
- **注意事項**: WPARはSolaris Zonesに触発された技術とされるが、直接の引用は確認できず
- **記事での表現**: IBMは2007年にAIX 6.1でWPAR（Workload Partitions）を導入し、Solaris Zonesと同様のOS レベルの仮想化をAIXに実装した

## 9. Oracle による Sun Microsystems 買収

- **結論**: 2009年4月20日、SunとOracleが買収合意を発表。買収額は約74億ドル（1株9.50ドル）。Sun の現金・負債を差し引いた実質額は約56億ドル。2010年1月21日、EU競争委員会が無条件承認。2010年1月27日に買収完了
- **一次ソース**: Wikipedia "Acquisition of Sun Microsystems by Oracle Corporation", Oracle Press Release
- **URL**: <https://en.wikipedia.org/wiki/Acquisition_of_Sun_Microsystems_by_Oracle_Corporation>, <https://www.oracle.com/corporate/pressrelease/oracle-buys-sun-042009.html>
- **注意事項**: ブループリントには「2010年」とあるが、発表は2009年4月、完了が2010年1月。買収後、OracleはOpenSolarisプロジェクトを廃止し、Solaris 11を事実上のクローズドソースに戻した
- **記事での表現**: 2009年4月にOracleがSun Microsystemsの買収を発表し、2010年1月に約74億ドルで買収を完了した

## 10. 商用UNIX市場の衰退

- **結論**: 2006年第2四半期、UNIX系サーバは世界サーバ市場の約35%（43億ドル）を占めたが、前年比で売上1.6%減、出荷数1.8%減（IDC調べ）。Windows/Linuxに対してUNIXエンタープライズサーバ市場は縮小傾向にあり、それは少なくとも10年間続いていた。1990年代後半にUNIXサーバ市場を支配していたSunは、2005年にIBMに追い抜かれた。1990年代後半〜2000年代前半にLinuxの信頼性・安定性・コスト効率が認められ、Red Hat/SUSEなどの商用ディストリビューションがエンタープライズ採用を加速させた
- **一次ソース**: Network World "The long, slow death of commercial Unix", ServerWatch "The State of Enterprise Unix"
- **URL**: <https://www.networkworld.com/article/966988/the-long-slow-death-unix.html>, <https://www.serverwatch.com/guides/the-state-of-enterprise-unix/>
- **注意事項**: 具体的な年次市場シェア推移の詳細データは限定的。IDCデータの引用は間接的
- **記事での表現**: 商用UNIXサーバ市場は2000年代半ばから明確な縮小傾向にあり、Linux/x86サーバの台頭によりシェアを侵食されていった

## 11. OpenZFS / btrfs への技術継承

- **結論**: Oracle による Sun買収後、ZFSのオープンソース版は「OpenZFS」として独立発展。2013年9月にOpenZFSプロジェクトが「ZFSプロジェクトの真のオープンソース後継」として発表。Linux、FreeBSD等の基盤となる。btrfsはLinuxにおけるZFSの機能（スナップショット、チェックサム、コピーオンライト）を提供することを主目標として開発。CDDLライセンスとGPLの非互換性がLinux上でのZFS採用を遅らせた要因
- **一次ソース**: Wikipedia "OpenZFS", OpenZFS "History"
- **URL**: <https://en.wikipedia.org/wiki/OpenZFS>, <https://openzfs.org/wiki/History>
- **注意事項**: btrfsがZFSの「クローン」というわけではなく、同様のユースケースを対象とした独立設計
- **記事での表現**: ZFSの遺産はOpenZFSとしてオープンソースコミュニティに継承され、btrfsはLinuxネイティブな代替として開発された

## 12. eBPF と DTrace の関係

- **結論**: 元々のBPF（Berkeley Packet Filter）は1992年にSteven McCanneとVan Jacobsonが論文発表。パケットフィルタリング専用の仮想マシン。2012〜2014年にLinuxカーネルで汎用仮想マシンに書き換えられ、eBPF（extended BPF）となった。Linux 3.18（2014年）でeBPF仮想マシンが正式統合。bpftraceはAlastair Robertsonが開発し、DTraceの設計哲学に影響を受けたトレーシング言語。Brendan Greggはbpftraceを「DTrace 2.0」と位置づけている。eBPFはDTraceにない機能も持つが、DTraceにあってbpftraceにない機能（speculative tracing等）もある
- **一次ソース**: Wikipedia "Berkeley Packet Filter", Wikipedia "eBPF", Brendan Gregg "bpftrace (DTrace 2.0) for Linux 2018"
- **URL**: <https://en.wikipedia.org/wiki/Berkeley_Packet_Filter>, <https://en.wikipedia.org/wiki/EBPF>, <https://www.brendangregg.com/blog/2018-10-08/dtrace-for-linux-2018.html>
- **注意事項**: eBPFはDTraceの「移植」ではなく独立した技術だが、bpftrace等のツールレベルでDTraceの影響を受けている
- **記事での表現**: DTraceの設計思想はLinuxのeBPFエコシステムに受け継がれ、bpftraceは「DTrace 2.0」と呼ばれている

## 13. SPARC / POWER / PA-RISC / Alpha アーキテクチャと商用UNIXの密結合

- **結論**: SPARCは1984年にSunの小チームが開発開始、1986年に完成、1987年に製品出荷。Berkeley RISC-IIに直接基づく。1990年代がピーク。1990年末時点でSunはワークステーション出荷の3分の1以上のシェアを占め、HPが約20%で2位。PA-RISCは1982年にHP Laboratoriesで開発開始、1986年に初製品出荷、2008年末に廃止。IBM POWERは1985年に研究開始、1990年にRS/6000で製品化。DEC Alphaは64bit RISCで、1998年にCompaq、2002年にHPに移り、2007年に廃止
- **一次ソース**: IEEE Spectrum "Chip Hall of Fame: Sun SPARC", Wikipedia "SPARC", Wikipedia "PA-RISC"
- **URL**: <https://spectrum.ieee.org/chip-hall-of-fame-sun-microsystems-sparc-processor>, <https://en.wikipedia.org/wiki/SPARC>, <https://en.wikipedia.org/wiki/PA-RISC>
- **注意事項**: 各アーキテクチャが「自社OS＋自社プロセッサ」の垂直統合モデルだった点が、Linux/x86の水平分業モデルとの対比で重要
- **記事での表現**: 各社は自社プロセッサ（SPARC、POWER、PA-RISC、Alpha）とOSを垂直統合していた

## 14. Linux cgroups / namespaces と Solaris Zones の関係

- **結論**: Linuxのmount namespaceは2002年のLinux 2.4.19で最初に利用可能に。user namespacesは2013年2月のLinux 3.18で完成。cgroupsはGoogleのエンジニアが2006年に「process containers」の名称で開発開始。2007年後半に「control groups」に改名（カーネル内での「container」という用語の混乱回避）。2008年1月、Linux 2.6.24でカーネルメインラインにマージ。LXCは2008年夏にリリース。「container」という用語はSolaris ZonesとResource Managementの組み合わせから来ている。DockerのコンテナはZonesが行っていたこと（単一カーネルでのOS レベル分離）と概念的に類似するが、Linuxのcgroups/namespaces上に構築されている
- **一次ソース**: Wikipedia "cgroups", VMware Open Source Blog "The Story of Containers"
- **URL**: <https://en.wikipedia.org/wiki/Cgroups>, <https://blogs.vmware.com/opensource/2018/02/27/the-story-of-containers/>
- **注意事項**: cgroupsの開発がSolaris Zonesに直接触発されたかどうかは明確な一次ソースがない。思想的接続は指摘されているが、技術的には独立した実装
- **記事での表現**: Googleが2006年に開発を始めたcgroupsと、2002年から段階的に実装されたLinux namespacesが、Solaris Zonesと同様のOS レベル仮想化をLinuxに実現した

## 15. HP Serviceguard

- **結論**: HP Serviceguard（旧MC/ServiceGuard）はHP-UXおよびLinux向けの高可用性クラスタソフトウェア。1990年から存在し、HPはこれをUNIX向け初の高可用性ソリューションと主張。世界で8万以上のライセンスが導入。Linux版（SG/LX）は1999年から存在
- **一次ソース**: Wikipedia "HP Serviceguard"
- **URL**: <https://en.wikipedia.org/wiki/HP_Serviceguard>
- **注意事項**: 「初のUNIX向けHAソリューション」というHPの主張は自社の見解
- **記事での表現**: HPは1990年にServiceguardを投入し、UNIX向け高可用性クラスタリングの先駆となった

## 16. OpenSolaris と Oracle による閉鎖

- **結論**: 2005年6月14日、SunはSolarisのソースコードの大部分をCDDLライセンスで公開し、OpenSolarisプロジェクトを設立。CDDLはMPL 1.1ベースの弱いコピーレフトライセンス。2004年12月1日にOSIに提出、2005年1月中旬に承認。DTraceが最初にオープンソース化されたコンポーネント（2005年1月25日）。Oracle買収後の2010年、OpenSolarisディストリビューションは廃止。OracleはSolarisカーネルのソースコード公開を停止し、Solaris 11を事実上のクローズドソースに戻した
- **一次ソース**: Wikipedia "Oracle Solaris", Wikipedia "OpenSolaris", Wikipedia "CDDL"
- **URL**: <https://en.wikipedia.org/wiki/Oracle_Solaris>, <https://en.wikipedia.org/wiki/OpenSolaris>, <https://en.wikipedia.org/wiki/Common_Development_and_Distribution_License>
- **注意事項**: OpenSolarisの廃止はオープンソースコミュニティへの大きな影響。illumos等の派生プロジェクトが継承
- **記事での表現**: SunはSolaris 10のソースコードをCDDLで公開しOpenSolarisを立ち上げたが、Oracle買収後にプロジェクトは廃止された
