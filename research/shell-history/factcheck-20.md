# ファクトチェック記録：第20回「コンテナ時代のシェル――Docker, CI/CD, そして/bin/sh問題」

## 1. Docker初回リリース日と経緯

- **結論**: Dockerは2013年3月13日、PyCon 2013（サンタクララ）でSolomon Hykesによって公開された。元はdotCloud社（2010年Y Combinator参加、2011年ローンチ）の内部プロジェクトであり、当初はLXCをデフォルト実行環境として使用していた。2013年にdotCloud社はDocker Inc.に改名
- **一次ソース**: Docker公式ブログ "11 Years of Docker: Shaping the Next Decade of Development", Wikipedia "Docker (software)"
- **URL**: <https://www.docker.com/blog/docker-11-year-anniversary/>, <https://en.wikipedia.org/wiki/Docker_(software)>
- **注意事項**: dotCloudの共同創業者はKamel Founadi、Solomon Hykes、Sebastien Pahl
- **記事での表現**: 「2013年3月、PyCon 2013でSolomon HykesがDockerを公開した」

## 2. Alpine Linuxの歴史とDocker採用

- **結論**: Alpine LinuxはNatanael Copaが2005-2006年頃に創設。元はGentoo Linuxベースの組み込み向けディストリビューション。2014年にuClibcからmuslに移行。Dockerエコシステムでは5MBの軽量イメージとして人気を博す。Docker Hub上で10億回以上のダウンロード
- **一次ソース**: Wikipedia "Alpine Linux", Alpine Linux公式Wiki, Docker Hub "alpine" 公式イメージ
- **URL**: <https://en.wikipedia.org/wiki/Alpine_Linux>, <https://hub.docker.com/_/alpine>
- **注意事項**: Alpine Linuxの正確な初回リリース年は2005年と2006年で情報が分かれる
- **記事での表現**: 「Alpine Linuxは2005年頃にNatanael Copaが創設した軽量ディストリビューションで、Docker公式イメージはわずか5MBである」

## 3. BusyBox ashとAlmquist shellの関係

- **結論**: Almquist shell（ash）はKenneth Almquistが1989年5月30日にcomp.sources.unixに投稿。System V Release 4のBourne shellクローンとして作成。高速・軽量でPOSIX準拠。BusyBoxにはバージョン0.52（2001年）からashの変種が組み込まれた。Alpine Linuxの/bin/shはBusyBox ash
- **一次ソース**: Wikipedia "Almquist shell", Baeldung "Difference Between BusyBox and Alpine Docker Images"
- **URL**: <https://en.wikipedia.org/wiki/Almquist_shell>, <https://www.baeldung.com/linux/busybox-vs-alpine-docker-images>
- **注意事項**: dashはashのDebian派生版。BusyBox ashとdashは同根だが別実装
- **記事での表現**: 「Alpine Linuxの/bin/shはBusyBox版のash（Almquist shell）であり、bashではない」

## 4. Dockerfile shell form vs exec form

- **結論**: shell formは`RUN command`形式で、`/bin/sh -c command`として実行される。exec formは`RUN ["executable", "param1"]`形式で、シェルを介さず直接実行。shell formではシェルの変数展開・パイプが使えるが、プロセスがPID 1にならない（/bin/sh -cの子プロセスになる）。exec formではシェル処理（変数展開等）が行われないが、プロセスが直接PID 1となりシグナルを受信できる
- **一次ソース**: Docker公式ドキュメント "Dockerfile reference", Docker公式ブログ "Docker Best Practices: Choosing Between RUN, CMD, and ENTRYPOINT"
- **URL**: <https://docs.docker.com/reference/dockerfile/>, <https://www.docker.com/blog/docker-best-practices-choosing-between-run-cmd-and-entrypoint/>
- **注意事項**: CMDとENTRYPOINTではシグナルハンドリングの違いが特に重要
- **記事での表現**: 「shell formは/bin/sh -cを通じてコマンドを実行し、exec formはシェルを介さず直接コマンドを起動する」

## 5. Docker SHELL命令（Docker 1.12, 2016年）

- **結論**: SHELL命令はDocker 1.12で導入（2016年リリース）。shell formのデフォルトシェルを変更可能にする。Linuxのデフォルトは`["/bin/sh", "-c"]`、Windowsは`["cmd", "/S", "/C"]`。RUN、CMD、ENTRYPOINTのshell formに影響。GitHub moby/moby PR #22489で実装
- **一次ソース**: Docker公式ドキュメント "Dockerfile reference", GitHub moby/moby Release v1.12.0
- **URL**: <https://docs.docker.com/reference/dockerfile/>, <https://github.com/moby/moby/releases/tag/v1.12.0>
- **注意事項**: Windows環境でcmdとPowerShellを切り替えるユースケースが主な動機の一つ
- **記事での表現**: 「2016年のDocker 1.12でSHELL命令が導入され、Dockerfileのshell formで使用されるシェルを明示的に指定できるようになった」

## 6. Docker マルチステージビルド（Docker 17.05, 2017年）

- **結論**: マルチステージビルドはDocker 17.05（2017年5月4日リリース）で導入。一つのDockerfileに複数のFROM命令を記述可能。ビルド時の依存関係とランタイムを分離し、最終イメージの大幅な軽量化を実現。GoのDockerfileで600MB→10MB以下への削減が可能
- **一次ソース**: Docker Engine v17.05 Release Notes, Docker公式ブログ "Multi-Stage Builds"
- **URL**: <https://docs.docker.com/engine/release-notes/17.05/>, <https://www.docker.com/blog/multi-stage-builds/>
- **注意事項**: Docker 17.06 CEとする資料もあるが、17.05が初出
- **記事での表現**: 「2017年5月のDocker 17.05でマルチステージビルドが導入された」

## 7. Google distrolessイメージ

- **結論**: GoogleContainerTools/distrolessは2017年頃にGoogleが公開。アプリケーションとそのランタイム依存関係のみを含み、パッケージマネージャ・シェル・その他のプログラムを含まない。gcr.io/distroless/static-debian12は約2MiBで、Alpine（約5MiB）の50%、Debian（124MiB）の2%未満。ENTRYPOINTはexec form（ベクター形式）で指定する必要がある
- **一次ソース**: GitHub GoogleContainerTools/distroless, Docker Docs "Distroless images"
- **URL**: <https://github.com/GoogleContainerTools/distroless>, <https://docs.docker.com/dhi/core-concepts/distroless/>
- **注意事項**: 2017年swampUP 2017でMatthew Mooreがデモ
- **記事での表現**: 「Googleのdistrolessイメージはシェルを含まない——パッケージマネージャも、デバッグユーティリティも存在しない」

## 8. Docker PID 1問題とtini/dumb-init

- **結論**: コンテナ内のPID 1プロセスはLinuxカーネルから特別扱いされ、デフォルトのシグナルハンドラが適用されない。shell formで起動したプロセスは/bin/sh -cの子プロセスとなりPID 1にならないため、docker stopのSIGTERMを受信できない。tini（krallin/tini）はDocker Engine自体に組み込まれ、`docker run --init`で利用可能。dumb-init（Yelp/dumb-init、2016年1月公開）はシグナルプロキシとゾンビプロセス回収を行う
- **一次ソース**: GitHub krallin/tini, Yelp Engineering Blog "Introducing dumb-init", GitHub Yelp/dumb-init
- **URL**: <https://github.com/krallin/tini>, <https://engineeringblog.yelp.com/2016/01/dumb-init-an-init-for-docker.html>
- **注意事項**: Docker 1.13（2017年1月）で`--init`フラグが導入されtiniが組み込まれた
- **記事での表現**: 「shell formでは/bin/sh -cがPID 1となり、実際のアプリケーションプロセスはSIGTERMを受信できない」

## 9. Kubernetes Ephemeral Containers

- **結論**: Ephemeral ContainersはKubernetes v1.25（2022年8月23日リリース）でStable（GA）に昇格。kubectl execとは異なり、kubectl debugで既存Podに一時的なデバッグコンテナを追加可能。distrolessイメージなどシェルを含まないコンテナのデバッグに特に有用
- **一次ソース**: Kubernetes公式ブログ "Kubernetes v1.25: Combiner", Kubernetes公式ドキュメント "Ephemeral Containers"
- **URL**: <https://kubernetes.io/blog/2022/08/23/kubernetes-v1-25-release/>, <https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/>
- **注意事項**: v1.23でBeta、v1.25でStable
- **記事での表現**: 「2022年のKubernetes 1.25でEphemeral ContainersがGA（安定版）となり、シェルを持たないコンテナのデバッグが公式にサポートされた」

## 10. GitHub Actions / GitLab CI のシェル設定

- **結論**: GitHub Actionsはデフォルトで`/bin/bash --noprofile --norc -eo pipefail`を使用。ただしコンテナ内ジョブではshがデフォルト。GitLab CIはUnix系でsh/bashがデフォルト。どちらもワークフロー/ジョブレベルでシェルを指定可能
- **一次ソース**: GitHub Docs "Setting a default shell and working directory", GitLab Docs "Types of shells supported by GitLab Runner"
- **URL**: <https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/setting-a-default-shell-and-working-directory>, <https://docs.gitlab.com/runner/shells/>
- **注意事項**: GitHub Actionsのコンテナジョブでshがデフォルトになる点は重要な落とし穴
- **記事での表現**: 「GitHub Actionsはデフォルトでbash --noprofile --norc -eo pipefailを使用するが、コンテナ内ジョブではshがデフォルトとなる」

## 11. Shellshock脆弱性とコンテナ

- **結論**: Shellshock（CVE-2014-6271）は2014年9月24日に公開されたbashの脆弱性。GNU Bash 1.14〜4.3に影響。環境変数に埋め込まれた関数定義の後にある任意コマンドが実行される。CGIスクリプト、OpenSSH ForceCommand、DHCPクライアント等が攻撃ベクター。コンテナにbashが存在する限り影響を受ける
- **一次ソース**: CISA Alert, NVD CVE-2014-6271, Qualys Blog
- **URL**: <https://www.cisa.gov/news-events/alerts/2014/09/25/gnu-bourne-again-shell-bash-shellshock-vulnerability-cve-2014-6271-cve-2014-7169-cve-2014-7186-cve>, <https://nvd.nist.gov/vuln/detail/cve-2014-6271>
- **注意事項**: コンテナでbashを排除する動機の一つがセキュリティ（攻撃面の削減）
- **記事での表現**: 「2014年のShellshock脆弱性は、コンテナにシェルを含めること自体がリスクであることを示した」

## 12. scratchイメージ

- **結論**: Docker scratchイメージは空のイメージで、ファイルやライブラリを一切含まない。ビルドの出発点として使用。シェルが存在しないため、shell formのCMD/ENTRYPOINTは使用不可、exec formのみ。Go等の静的リンクバイナリに最適。pull/run/tagは不可
- **一次ソース**: Docker Hub "scratch" 公式イメージ
- **URL**: <https://hub.docker.com/_/scratch/>
- **注意事項**: distrolessはscratchに必要最小限のシステムファイルを加えたもの
- **記事での表現**: 「scratchイメージは文字通り『何もない』状態から始まる——シェルも、ライブラリも、ファイルシステムも存在しない」
