# ファクトチェック記録：第17回「systemd論争——UNIXの原則は死んだのか」

## 1. SysV initの起源と設計

- **結論**: UNIX System Vは1983年1月にAT&Tから最初にリリースされた。SysV initはSystem V由来のinit設計で、シェルスクリプトベースの逐次起動とランレベル（/etc/inittab, /etc/rc.d/）を特徴とする
- **一次ソース**: Wikipedia, "UNIX System V"; Red Hat Documentation, "SysV Init Runlevels"
- **URL**: <https://en.wikipedia.org/wiki/UNIX_System_V>, <https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/4/html/reference_guide/s1-boot-init-shutdown-sysv>
- **注意事項**: SysV initの設計はBSD initとは異なる。BSD initはシンプルな/etc/rcスクリプト方式、SysV initはランレベルとrcN.dディレクトリ方式
- **記事での表現**: SysV init（System V init、1983年〜）のシェルスクリプトベースの逐次起動。ランレベルと/etc/rc.d/配下のシンボリックリンクによるサービス管理

## 2. systemdの誕生と初期リリース

- **結論**: systemdは2010年3月30日に初期リリースされた。Lennart PoetteringとKay Sieversが中心的開発者で、両者ともRed Hat所属。Poetteringは2010年4月30日に「Rethinking PID 1」というブログ記事を公開して設計思想を詳述した
- **一次ソース**: Lennart Poettering, "Rethinking PID 1", 2010年4月30日; Wikipedia, "systemd"
- **URL**: <https://0pointer.de/blog/projects/systemd.html>, <https://en.wikipedia.org/wiki/Systemd>
- **注意事項**: 初期リリースは2010年3月30日、ブログ記事は4月30日。systemdの「d」はdaemonの意（UNIXの慣例）
- **記事での表現**: 2010年、Red HatのLennart PoetteringとKay Sieversがsystemdを公開した

## 3. Upstartの歴史

- **結論**: Upstartは2006年にCanonicalのScott James Remnantが開発。Ubuntu 6.10 "Edgy Eft"（2006年10月）で初採用。イベント駆動型の設計。RHEL 6（2010年）やChrome OSでも採用された。2014年にメンテナンスモードに移行、Ubuntu 15.04（2015年4月）でsystemdに置き換えられた
- **一次ソース**: Wikipedia, "Upstart (software)"; Launchpad, "upstart"
- **URL**: <https://en.wikipedia.org/wiki/Upstart_(software)>, <https://launchpad.net/upstart>
- **注意事項**: Upstartの衰退にはCanonical CLAの問題も影響した（コントリビュータに再ライセンス権を付与する要件）
- **記事での表現**: Upstart（2006年、Scott James Remnant、Canonical）——イベント駆動型のinit。Ubuntu 6.10で初採用

## 4. Debian jessieでのsystemd採択

- **結論**: 2014年2月、DebianのTechnical Committeeがsystemdをデフォルトinitシステムとして採択。議長Bdale GarbeeがsystemdとUpstartの同数投票に対してcasting voteでsystemdを選択。その後、Ian Jacksonが「loose coupling」を求める決議を提案したが否決され、Jacksonは技術委員を辞任。Russ AllberyとColin Watsonも辞任した
- **一次ソース**: LWN.net, "Debian decides on systemd—for now"; Debian mailing list; Debian General Resolution vote_003
- **URL**: <https://lwn.net/Articles/585319/>, <https://lists.debian.org/debian-ctte/2014/02/msg00281.html>, <https://www.debian.org/vote/2014/vote_003>
- **注意事項**: 技術委員会の投票プロセス自体が複雑で、複数回のCFV（Call for Votes）が行われた
- **記事での表現**: Debian Technical Committeeでのsystemd採択（2014年2月）。議長のcasting voteによる決定。コミュニティの分裂

## 5. Devuanプロジェクトの誕生

- **結論**: 2014年11月27日、「Veteran Unix Admins (VUA)」を名乗るグループがDevuanプロジェクトを発表。Debianのsystemd採用に反発し、systemdフリーのDebianフォークを目指した。名前はDebian + VUAのかばん語。最初の安定版Devuan 1.0 "Jessie"は2017年5月25日リリース
- **一次ソース**: Devuan announcement; PCWorld article; Wikipedia, "Devuan"
- **URL**: <https://www.devuan.org/os/announce/>, <https://www.pcworld.com/article/436680/meet-devuan-the-debian-fork-born-from-a-bitter-systemd-revolt.html>, <https://en.wikipedia.org/wiki/Devuan>
- **注意事項**: Devuanは2026年現在もアクティブに開発が続いている（Devuan 6.1 Excalibur、Debian 13ベース）
- **記事での表現**: systemdを拒否するDevuanフォーク（2014年11月発表、2017年5月初安定版）

## 6. systemdの範囲拡大

- **結論**: 2013年1月時点で、systemdはフル構成時に69の個別バイナリを含むソフトウェアスイートとなっていた。主要コンポーネント: systemd-journald（ログ）、systemd-logind（ログイン管理）、systemd-networkd（ネットワーク設定、v209で導入）、systemd-resolved（DNS解決）、systemd-timesyncd（時刻同期）、systemd-homed（ホームディレクトリ管理）、systemd-boot（ブートローダー）、machinectl（コンテナ管理）等
- **一次ソース**: Wikipedia, "systemd"; Lennart Poettering, "The Biggest Myths", 2013年1月26日
- **URL**: <https://en.wikipedia.org/wiki/Systemd>, <http://0pointer.de/blog/projects/the-biggest-myths.html>
- **注意事項**: Poetteringは「The Biggest Myths」で30の神話に反論。systemdが「モノリシック」ではなく69の独立バイナリであると主張
- **記事での表現**: systemdは2013年時点で69の独立バイナリを含むスイートに成長。init、ログ、ネットワーク管理、DNS解決、コンテナ管理まで範囲を拡大した

## 7. Poetteringの「Rethinking PID 1」の設計目標

- **結論**: 2010年4月30日のブログ記事で、Poetteringはsystemdの設計目標を提示: (1) 起動の高速化（より少なく起動し、より並列に起動する）、(2) ソケットベースのアクティベーション（inetdに着想）、(3) 依存関係の明示的な表現、(4) シェルスクリプトの排除（パフォーマンスとパース曖昧性の問題）、(5) cgroups統合によるプロセス追跡
- **一次ソース**: Lennart Poettering, "Rethinking PID 1", 0pointer.de, 2010年4月30日
- **URL**: <https://0pointer.de/blog/projects/systemd.html>
- **注意事項**: launchdへの言及——macOSのlaunchdから着想を得た部分がある
- **記事での表現**: Poetteringは「Rethinking PID 1」で、SysV initの問題を体系的に分析し、代替設計を提案した

## 8. systemdのcgroups統合

- **結論**: systemdはLinuxカーネルのcgroups（control groups）を活用して、サービスごとのプロセス追跡とリソース制限を実現。各サービスは独自のcgroup内で実行され、fork/double-forkしても確実に追跡可能。CPU、メモリ、I/O帯域を制限可能
- **一次ソース**: systemd.io, "Control Group APIs and Delegation"; Red Hat Blog, "Managing cgroups with systemd"
- **URL**: <https://systemd.io/CGROUP_DELEGATION/>, <https://www.redhat.com/en/blog/cgroups-part-four>
- **注意事項**: cgroups v1からv2への移行も進行中。systemdは最近のバージョンでcgroupfs v2をデフォルトでマウント
- **記事での表現**: systemdはcgroupsによりサービスのプロセスツリーを完全に追跡し、リソース制限を実現する

## 9. systemdの採用タイムライン

- **結論**: Fedora 15（2011年5月）が最初のメジャーディストリビューション採用。Arch Linux、openSUSE（2012年）。RHEL 7（2014年6月10日）。Debian 8 jessie（2015年4月）。Ubuntu 15.04 vivid（2015年4月）。2015年以降、ほぼすべての主要Linuxディストリビューションが採用
- **一次ソース**: Wikipedia, "systemd"; LWN.net, "14 years of systemd"
- **URL**: <https://en.wikipedia.org/wiki/Systemd>, <https://lwn.net/Articles/1008721/>
- **注意事項**: Gentoo、Slackware、Devuanなど非採用/選択制のディストリビューションも存在する
- **記事での表現**: Fedora 15（2011年5月）からRHEL 7（2014年6月）、Debian 8（2015年4月）へと急速に普及

## 10. Patrick Volkerding（Slackware）のsystemd批判

- **結論**: Slackwareの創始者Patrick Volkerding はsystemdを批判し、「サービス、ソケット、デバイス、マウント等を一つのデーモンで制御しようとするのは、UNIXの"一つのことをうまくやれ"という概念に反する」と述べた。Slackwareは2026年現在もsystemdを採用していない
- **一次ソース**: Wikipedia, "Unix philosophy"（Volkerding引用あり）
- **URL**: <https://en.wikipedia.org/wiki/Unix_philosophy>
- **注意事項**: Volkerding以外にも多くの批判者がいる。批判は技術的論点と哲学的論点に大別される
- **記事での表現**: Patrick Volkerding（Slackware）は「一つのデーモンですべてを制御しようとするのはUNIX哲学に反する」と批判した

## 11. systemdユニットファイルの設計

- **結論**: systemdのユニットファイルはINIスタイルの宣言的形式。[Unit]、[Service]、[Install]の3セクション構成。XDG Desktop Entry Specificationの.desktopファイル形式に着想を得た。シェルスクリプトの代わりに宣言的な設定で依存関係、起動順序、リソース制限を定義
- **一次ソース**: freedesktop.org, systemd.service(5); Red Hat Documentation
- **URL**: <https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html>, <https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_systemd_unit_files_to_customize_and_optimize_your_system/assembly_working-with-systemd-unit-files_working-with-systemd>
- **注意事項**: Type=simple（フォアグラウンド実行）、Type=forking（デーモン化）、Type=notify（readyを通知）等のサービスタイプがある
- **記事での表現**: 宣言的なINIスタイルのユニットファイルで、命令的なシェルスクリプトを置き換えた

## 12. systemd-journaldとバイナリログ

- **結論**: 2011年のKernel Summitで、PoetteringとSieversがjournalをsyslog代替として提案。journaldはバイナリ形式で構造化ログを保存し、暗号学的ハッシュチェーンで改ざん検出が可能（git着想）。批判者はテキストログのUNIXツールチェーン（cat, grep, tail）での処理が不能になることを問題視
- **一次ソース**: LWN.net, "The Journal - a proposed syslog replacement"
- **URL**: <https://lwn.net/Articles/468049/>
- **注意事項**: journaldはsyslogとの共存も可能（ForwardToSyslog設定）。journalctlコマンドで閲覧
- **記事での表現**: journaldのバイナリログは、UNIXの「テキストは万能インタフェース」原則との明確な断絶である
