# ファクトチェック記録：第20回「DockerとKubernetes――UNIX原則の現代的帰結」

## 1. chroot の起源

- **結論**: chrootはVersion 7 Unix（1979年）の開発過程で導入された。V7ディストリビューションのテストに使用された。Bill Joyは1982年3月18日にBSD向けにchrootを追加した（4.2BSDリリースの17か月前）
- **一次ソース**: Wikipedia "chroot"; Chris's Wiki "ChrootHistory"
- **URL**: <https://en.wikipedia.org/wiki/Chroot>, <https://utcc.utoronto.ca/~cks/space/blog/unix/ChrootHistory>
- **注意事項**: ブループリントでは「1979年、Bill Joy、V7 UNIX」としているが、より正確にはchrootはV7（1979年）で登場し、Bill JoyがBSDに追加したのは1982年。記事ではこの区別を明確にする
- **記事での表現**: 「1979年、Version 7 Unixの開発過程でchrootシステムコールが導入された。Bill Joyは1982年にBSD向けにこの機能を取り込み、インストールとビルドシステムのテストに活用した」

## 2. FreeBSD Jails

- **結論**: FreeBSD Jailsは1999年にPoul-Henning Kampが開発し、2000年3月14日リリースのFreeBSD 4.0で初めて公式搭載された。R&D Associates, Inc.（Derrick T. Woolworthが所有するWebホスティングプロバイダ）からの委託プロジェクトとして開発
- **一次ソース**: Wikipedia "FreeBSD jail"; Klara Systems "FreeBSD Jails - The Beginning of FreeBSD Containers"
- **URL**: <https://en.wikipedia.org/wiki/FreeBSD_jail>, <https://klarasystems.com/articles/freebsd-jails-the-beginning-of-freebsd-containers/>
- **注意事項**: ブループリントの「2000年」は正確。FreeBSD 4.0のリリース日が2000年3月14日
- **記事での表現**: 「2000年、FreeBSD 4.0でPoul-Henning KampによるJailsが搭載された。chrootの概念をネットワークやプロセスの分離にまで拡張した」

## 3. Solaris Zones

- **結論**: Solaris Zonesは2004年2月にSolaris 10のベータビルド51で公開され、2005年1月31日のSolaris 10正式リリースで一般提供された
- **一次ソース**: Wikipedia "Solaris Containers"; softpanorama.org "Solaris Zones History"
- **URL**: <https://en.wikipedia.org/wiki/Solaris_Containers>, <https://softpanorama.org/Solaris/Virtualization/Zones/solaris_zones_history.shtml>
- **注意事項**: ブループリントでは「2004年」としているが、ベータ公開が2004年、正式リリースが2005年1月。記事では「Solaris 10（2005年）で正式リリース」と記述するのが正確
- **記事での表現**: 「Solaris Zones（2004年ベータ公開、2005年1月Solaris 10正式リリース）」

## 4. Linux cgroups

- **結論**: 2006年にGoogleのエンジニアPaul MenageとRohit Sethが「process containers」として開発を開始。2007年後半に「control groups（cgroups）」に名称変更（"container"という用語のカーネル内での意味の混乱を避けるため）。Linux 2.6.24（2008年1月リリース）でメインラインにマージ
- **一次ソース**: Wikipedia "cgroups"
- **URL**: <https://en.wikipedia.org/wiki/Cgroups>
- **注意事項**: ブループリントの「2006年、Google、Rohit Seth, Paul Menage」は正確。ただし正式マージは2008年1月のカーネル2.6.24
- **記事での表現**: 「2006年、Googleのエンジニア Paul MenageとRohit Sethが"process containers"として開発を開始し、2007年に"control groups"（cgroups）と改名、2008年1月のLinux 2.6.24でメインラインにマージされた」

## 5. Linux namespaces

- **結論**: 最初のnamespace（mount namespace）は2002年8月3日、Linux 2.4.19でAl Viroにより導入された。CLONE_NEWNSフラグを使用。Plan 9 from Bell Labsの名前空間機能に触発された設計。以降の主要なnamespace追加時系列:
  - Mount: 2.4.19 (2002年)
  - UTS, IPC: 2.6.19 (2006年)
  - PID: 2.6.24 (2008年)
  - Network: 2.6.29 (2009年)
  - User: 3.8 (2013年)
  - Cgroup: 4.6 (2016年)
  - Time: 5.6 (2020年)
- **一次ソース**: Wikipedia "Linux namespaces"; LWN.net "Namespaces in operation, part 1"
- **URL**: <https://en.wikipedia.org/wiki/Linux_namespaces>, <https://lwn.net/Articles/531114/>
- **注意事項**: ブループリントの「2002年〜段階的導入」は正確。Plan 9からの影響も検証済み
- **記事での表現**: 「2002年、Linux 2.4.19でmount namespaceが導入された。Plan 9の名前空間機能に触発されたこの設計は、以後15年以上にわたり段階的に拡張された」

## 6. LXC（Linux Containers）

- **結論**: 2008年8月に初回リリース。IBMのエンジニアが開発。namespaces（2002年〜）とcgroups（2006年〜）をベースとする。初期のDocker（2013年）はLXCのラッパーとして実装されていた
- **一次ソース**: Wikipedia "LXC"
- **URL**: <https://en.wikipedia.org/wiki/LXC>
- **注意事項**: ブループリントの「LXC（2008年）」は正確
- **記事での表現**: 「2008年、Linux Containers（LXC）がリリースされた。namespacesとcgroupsを組み合わせ、Linuxカーネルの機能だけでコンテナ環境を提供する最初の本格的な実装だった」

## 7. Docker

- **結論**: 2013年3月13日にオープンソースとして公開。Solomon Hykesが2013年3月15日のPyCon 2013で5分間のライトニングトーク"The Future of Linux Containers"として初めて公開デモ。dotCloud社（PaaS企業）の内部ツールとして開発されていた。初期はLXCをデフォルト実行環境として使用
- **一次ソース**: Docker Blog "Docker: Nine Years YOUNG"; Wikipedia "Docker (software)"; PyCon video
- **URL**: <https://www.docker.com/blog/docker-nine-years-young/>, <https://en.wikipedia.org/wiki/Docker_(software)>, <https://pyvideo.org/pycon-us-2013/the-future-of-linux-containers.html>
- **注意事項**: ブループリントの「2013年、Solomon Hykes、dotCloud」は正確
- **記事での表現**: 「2013年3月、Solomon HykesはPyCon 2013のライトニングトークで"The Future of Linux Containers"と題して、dotCloud社で内部開発していたDockerを初めて公開デモした」

## 8. Kubernetes

- **結論**: 2014年6月6日にGoogleがオープンソースプロジェクトとして発表。2014年7月にGitHubで公開。Google内部のBorgクラスタ管理システムの設計経験に基づく。Joe Beda、Brendan Burns、Craig McLuckieが中心開発者。2015年7月21日にv1.0リリース、同時にCloud Native Computing Foundation（CNCF）設立・寄贈
- **一次ソース**: Google Cloud Blog "From Google to the world: The Kubernetes origin story"; Wikipedia "Kubernetes"; TechCrunch
- **URL**: <https://cloud.google.com/blog/products/containers-kubernetes/from-google-to-the-world-the-kubernetes-origin-story>, <https://en.wikipedia.org/wiki/Kubernetes>, <https://techcrunch.com/2015/07/21/as-kubernetes-hits-1-0-google-donates-technology-to-newly-formed-cloud-native-computing-foundation-with-ibm-intel-twitter-and-others/>
- **注意事項**: ブループリントの「2014年、Google、Borgの公開版」は正確
- **記事での表現**: 「2014年6月、GoogleはKubernetesをオープンソースとして発表した。社内のコンテナオーケストレーションシステムBorgの設計知見を公開版として再構築したものだ」

## 9. Docker imageのレイヤー構造とUnionFS

- **結論**: Dockerイメージのレイヤー構造はUnion File Systemに基づく。歴史的にAUFS（UnionFSの再実装、Linuxメインラインには未マージ）がデフォルトだったが、2018年頃からoverlay2に移行。OverlayFSはLinux 3.18（2014年）でカーネルメインラインにマージ。Copy-on-Write（CoW）戦略を使用
- **一次ソース**: Docker Docs "OverlayFS storage driver"; Wikipedia "OverlayFS"
- **URL**: <https://docs.docker.com/engine/storage/drivers/overlayfs-driver/>, <https://en.wikipedia.org/wiki/OverlayFS>
- **注意事項**: ブループリントの「AUFS、overlayfs」は正確
- **記事での表現**: 「Dockerイメージのレイヤー構造はUnion File Systemに基づく。当初はAUFSを使用していたが、現在はLinux 3.18でカーネルにマージされたOverlayFS（overlay2ドライバ）がデフォルトだ」

## 10. OCI（Open Container Initiative）

- **結論**: 2015年6月22日にDockerとCoreOSを中心に設立。Runtime Specification（runtime-spec）、Image Specification（image-spec）、Distribution Specification（distribution-spec、2020年v1.0）の3仕様を策定。DockerはruncをOCIに寄贈し、Runtime Specのリファレンス実装とした
- **一次ソース**: Open Container Initiative公式サイト; Wikipedia "Open Container Initiative"
- **URL**: <https://opencontainers.org/about/overview/>, <https://en.wikipedia.org/wiki/Open_Container_Initiative>
- **注意事項**: ブループリントには明示的な記載がないが、コンテナの標準化として言及する価値がある
- **記事での表現**: 「2015年6月、DockerとCoreOSを中心にOpen Container Initiative（OCI）が設立され、コンテナのランタイムとイメージフォーマットの標準仕様が策定された」

## 11. Kubernetesのpodとsidecarパターン

- **結論**: Kubernetesのpodは複数のコンテナを同一ノードに配置し、ネットワークとストレージを共有する単位。sidecarパターンはメインアプリケーションコンテナの横に補助コンテナを配置し、ログ収集やメトリクス取得などの運用タスクを担当させる。単一責務原則（separation of concerns）に基づく設計
- **一次ソース**: Kubernetes Blog "Kubernetes Multicontainer Pods: An Overview"
- **URL**: <https://kubernetes.io/blog/2025/04/22/multi-container-pods-overview/>
- **注意事項**: UNIXのパイプ＆フィルタとの直接的なアナロジーとして記述する
- **記事での表現**: 「Kubernetesのsidecarパターン——メインコンテナの横に補助コンテナを配置する設計——は、UNIXのパイプラインで各フィルタが独立して一つの仕事をこなす構造と共鳴する」
