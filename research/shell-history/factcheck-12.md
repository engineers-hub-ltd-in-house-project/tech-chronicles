# ファクトチェック記録：第12回「ash/dash——POSIX原理主義と単純さの速度」

## 1. Kenneth Almquistによるashの開発と公開（1989年）

- **結論**: Kenneth Almquistは1989年5月30日、comp.sources.unix Usenetニュースグループにashを投稿した。Volume 19, Issue 1として公開され、Rich Salzが承認・モデレーションを行った。ashは「System V shellの再実装」と説明され、4.2BSD、4.3BSD、System V Release 1-3、System III、およびVersion 7で動作すると記されていた。開発動機はAT&Tのライセンス問題の回避であり、BSDライセンスで公開された
- **一次ソース**: comp.sources.unix, Volume 19, Issue 1, "v19i001: A reimplementation of the System V shell, Part01/08", 1989年5月30日
- **URL**: <https://groups.google.com/g/comp.sources.unix/c/A6cnyKX-Gq4/m/dGKOOmXndCcJ>
- **注意事項**: ashは「public domain」として公開されたとする記述と「BSDライセンス」とする記述が混在する。原初の投稿はpublic domainに近い形だが、後のBSD組み込み時にBSDライセンスの文脈で扱われた
- **記事での表現**: 「1989年5月30日、Kenneth Almquistはcomp.sources.unix Usenetニュースグループに、8パートに分かれたシェルのソースコードを投稿した。"A reimplementation of the System V shell"——System Vシェルの再実装である」

## 2. ashのBSDへの組み込み（4.3BSD-Net/2, 1991年）

- **結論**: ashは4.3BSD-Net/2（1991年6月）で/bin/shとして採用され、AT&Tのコードに依存しないBourne shell互換シェルとしてBSD配布物に組み込まれた。これはAT&TとBerkeley間のライセンス紛争の中で、自由に再配布可能なシェルを確保するための決断だった。4.4BSD（1993年）、4.4BSD-Lite（1994年6月）でも引き続き/bin/shとして使用された
- **一次ソース**: Almquist shell, Wikipedia; Ash (Almquist Shell) Variants, in-ulm.de
- **URL**: <https://en.wikipedia.org/wiki/Almquist_shell>, <https://www.in-ulm.de/~mascheck/various/ash/>
- **注意事項**: 4.3BSD-RenoではなくNet/2が正確な組み込みポイント
- **記事での表現**: 「1991年6月の4.3BSD-Net/2リリースで、ashはAT&T由来のBourne shellに代わる/bin/shとして採用された。AT&TとBerkeleyのライセンス戦争の中で、自由に再配布可能なシェルを確保する——それがashの役割だった」

## 3. Herbert Xuによるdash（Debian Almquist shell）の開発

- **結論**: Herbert Xuは1997年にashをNetBSDからDebian Linuxに移植した。2002年9月、バージョン0.4.1のリリース時にこのポートは「dash」（Debian Almquist shell）に改名された。Xuの主な関心はPOSIX準拠とスリムな実装にあった。Xuはもともと1997年にDebianカーネルメンテナとして活動を開始し、Linuxカーネルの暗号サブシステムの共同メンテナでもある
- **一次ソース**: Almquist shell, Wikipedia; Linux.com "30 Linux Kernel Developers in 30 Weeks: Herbert Xu"
- **URL**: <https://en.wikipedia.org/wiki/Almquist_shell>, <https://www.linux.com/news/30-linux-kernel-developers-30-weeks-herbert-xu/>
- **注意事項**: Herbert Xuの移植元は「NetBSD」のashであることを正確に記述する
- **記事での表現**: 「1997年、Herbert XuはNetBSD版のashをDebian Linuxに移植した。2002年9月、バージョン0.4.1で、このポートは正式にdash——Debian Almquist shellと命名された」

## 4. Debian/Ubuntuにおけるdashのデフォルト化

- **結論**: Ubuntu 6.10（2006年10月）がデフォルトの/bin/shをbashからdashに変更した。Debianは2011年2月リリースのDebian 6（Squeeze）で公式にdashをデフォルト/bin/shとした。Ubuntu Wikiによれば、Ubuntu 6.10のブート速度改善はUpstartの功績と誤解されがちだったが、実際にはdash移行の効果が大きかった
- **一次ソース**: Ubuntu Wiki, "DashAsBinSh"
- **URL**: <https://wiki.ubuntu.com/DashAsBinSh>
- **注意事項**: ブループリントでは「起動速度4倍の衝撃」と記載があるが、Ubuntu Wikiの記述は「bashに比べて小さく起動が速い」であり、「4倍」という具体的な数値の根拠は「dashがbashの4倍速い」とする別の記事に由来する。正確には「dashの起動時間はbashの約1/3」という表現が妥当
- **記事での表現**: 「2006年10月、Ubuntu 6.10がデフォルトの/bin/shをbashからdashに変更した。ブート速度の改善はUpstartの功績と誤解されがちだったが、実際の主要因はdash移行だった。Debianは2011年のDebian 6（Squeeze）で正式にdashをデフォルト/bin/shとした」

## 5. dashとbashのバイナリサイズ・起動速度比較

- **結論**: dashのバイナリサイズは約100KB、bashは約900KB（環境により変動）。dashの起動時間はbashの約1/3。1,000回の起動ベンチマークでdashは約0.9秒。dashはlibcのみに依存するが、bashはreadline、ncursesなどの追加ライブラリに依存する。総合的にdashはbashの2〜5倍高速とする測定結果がある
- **一次ソース**: Baeldung "Linux Shells Performance: dash vs bash"; Ubuntu Wiki "DashAsBinSh"; Neterra.cloud Blog "Dash vs Bash Shell"
- **URL**: <https://www.baeldung.com/linux/dash-vs-bash-performance>, <https://wiki.ubuntu.com/DashAsBinSh>, <https://blog.neterra.cloud/en/dash-vs-bash-shell/>
- **注意事項**: 具体的な数値は計測環境（CPU、OS、バージョン）に大きく依存する。ハンズオンでは読者自身が計測できるようにする。「4倍速い」は一部の計測条件での結果であり、一般化は避ける
- **記事での表現**: 「dashのバイナリサイズは約100KB、bashの約900KBに対して1/9以下だ。起動速度の差はさらに顕著で、1,000回の連続起動ベンチマークでdashはbashの数倍速い結果を示す。この差の根本原因は依存ライブラリにある——dashはlibcのみに依存するが、bashはreadlineやncursesを必要とする」

## 6. BusyBoxの歴史

- **結論**: BusyBoxは1995年にBruce Perensにより開発され、1996年に意図した用途において完成を宣言した。当初の目的はDebian配布用の単一フロッピーディスクにブート可能なシステム（レスキューディスク兼インストーラー）を収めることだった。その後、組み込みLinuxの事実上の標準ユーザースペースツールセットとなった。「The Swiss Army knife of Embedded Linux」の呼称で知られる。dashバージョン0.3.8-5がBusyBoxに組み込まれた
- **一次ソース**: BusyBox, Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/BusyBox>
- **注意事項**: BusyBox ashはdashの派生であり、完全に同一ではない。BusyBoxのashビルドオプションにより機能が異なる場合がある
- **記事での表現**: 「1995年、Bruce PerensはDebianインストーラー用に、単一の実行ファイルに300以上のUNIXコマンドを収めるBusyBoxを開発した。"The Swiss Army knife of Embedded Linux"——組み込みLinuxのスイスアーミーナイフだ」

## 7. Alpine Linuxの歴史

- **結論**: Alpine LinuxはNatanael Copa（Gentoo開発者）により2005年8月に発表された。元々は"A Linux Powered Integrated Network Engine"の略で、VPNやファイアウォール向けの組み込みディストリビューションだった。LEAF ProjectのBering-uClibc分岐に触発されている。Alpine 3.0でuClibcからmusl libcに移行。musl libc、BusyBox、OpenRCを使用し、glibcやGNU Core Utilities、systemdは使用しない
- **一次ソース**: Alpine Linux, Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Alpine_Linux>
- **注意事項**: 2005年発表で2010年ではない。ブループリントの記述と整合させる
- **記事での表現**: 「2005年、Gentoo開発者のNatanael CopaがAlpine Linuxを発表した。VPNとファイアウォール用途の組み込みディストリビューションとして始まったAlpineは、musl libcとBusyBoxを基盤とする軽量Linuxへと進化した」

## 8. Alpine Linux Dockerイメージのサイズと普及率

- **結論**: Alpine LinuxのDockerイメージサイズは約5MB。Ubuntuは約188MB（4レイヤー）、Debianは約114MB、CentOSは約202MBと比較して極めて小さい。Docker Hubでのpull数は1.35億を超え、Debianの3,500万を大きく上回る。Dockerコンテナの約20%がAlpine Linuxベースとする推計がある
- **一次ソース**: Docker Hub alpine公式ページ; coin.host blog; Brian Christner Docker image size comparison
- **URL**: <https://hub.docker.com/_/alpine>, <https://coin.host/blog/the-advantages-of-using-alpine-linux-in-docker-images>, <https://brianchristner.io/docker-image-base-os-size-comparison/>
- **注意事項**: pull数やイメージサイズは時期により変動する。2026年2月時点の最新値は要確認。「約20%」は概算であり厳密な統計ではない
- **記事での表現**: 「Alpine LinuxのDockerイメージサイズはわずか約5MB。Ubuntuの約188MB、Debianの約114MBと比較すれば、その軽量さは一目瞭然だ」

## 9. BSD系OSにおけるash派生の採用状況

- **結論**: ashの派生はFreeBSD、NetBSD、DragonFly BSD、MINIXの/bin/shとして使用されている。FreeBSD 14ではrootのデフォルトシェルが/bin/shに変更された（以前はcsh）。各BSD系OSは独自のash派生を持ち、それぞれ異なる拡張を含む：FreeBSD /bin/sh、NetBSD /bin/sh、Debian dash
- **一次ソース**: Almquist shell, Wikipedia; FreeBSD Forums
- **URL**: <https://en.wikipedia.org/wiki/Almquist_shell>, <https://forums.freebsd.org/threads/default-shell.74659/>
- **注意事項**: 各BSD派生のash実装間には微妙な差異がある
- **記事での表現**: 「ashの血統はBSD世界に深く根を張っている。FreeBSD、NetBSD、DragonFly BSD——いずれも/bin/shとしてashの派生を採用している」

## 10. distrolessコンテナイメージ

- **結論**: GoogleのDistrolessイメージはアプリケーションとランタイム依存のみを含み、シェル・パッケージマネージャを意図的に除外する。最小のDistrolessイメージ（gcr.io/distroless/static-debian12）は約2MiBと極めて小さい。セキュリティ上の理由は攻撃対象面積の削減：シェルがなければ、攻撃者がRCE（リモートコード実行）を獲得してもターミナルを起動できない
- **一次ソース**: GitHub GoogleContainerTools/distroless; Docker Docs "Distroless images"
- **URL**: <https://github.com/GoogleContainerTools/distroless>, <https://docs.docker.com/dhi/core-concepts/distroless/>
- **注意事項**: distrolessはシェルの不在を前提とするため、デバッグ時にkubectl exec等でシェルを起動できない制約がある。debug版のdistrolessイメージには限定的なシェルが含まれる
- **記事での表現**: 「Googleのdistrolessイメージは、シェルすら含まないコンテナイメージだ。最小構成でわずか約2MiB。シェルを排除することで攻撃対象面積を極限まで削減する——『シェルがなければ、侵入者はターミナルを起動できない』という発想だ」

## 11. Dockerfile shell form vs exec form

- **結論**: DockerfileのRUN/CMD/ENTRYPOINTにはshell form（`CMD command args`）とexec form（`CMD ["cmd", "args"]`）がある。shell formは`/bin/sh -c`経由で実行され、exec formは直接実行される。最大の差異はシグナルハンドリング：shell formでは/bin/shがPID 1となり、SIGTERMが子プロセスに伝播しない。exec formではアプリケーションがPID 1となり、シグナルを直接受信する
- **一次ソース**: Docker公式ドキュメント "Dockerfile reference"; Docker Blog "Docker Best Practices"
- **URL**: <https://docs.docker.com/reference/dockerfile/>, <https://www.docker.com/blog/docker-best-practices-choosing-between-run-cmd-and-entrypoint/>
- **注意事項**: Docker 1.12（2016年）でSHELL命令が追加され、shell formで使用するシェルを変更可能になった
- **記事での表現**: 「Dockerfileのshell form（CMD command）は/bin/sh -c経由で実行される。exec form（CMD ["cmd"]）は直接実行だ。この違いはシグナルハンドリングに決定的な差を生む」
