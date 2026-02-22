# ファクトチェック記録：第14回「bashスクリプティングの生態系」

## 1. SysV initからsystemdへの移行時期と経緯

- **結論**: Lennart Poetteringは2010年4月30日にブログ記事「Rethinking PID 1」でsystemdの構想を発表した。Kay Sieversとの共同開発で、Red Hat在籍時にプロジェクトを開始。Fedora 15（2011年5月）が最初にsystemdをデフォルト採用した主要ディストリビューション。その後、Arch Linux・openSUSE（2012年）、RHEL 7（2014年）、Debian 8 Jessie・Ubuntu 15.04（2015年）が続いた。Debianでは2014年2月にTechnical Committeeが4:4の票割れの末、議長Bdale Garbeeの裁定でsystemdを採用する激しい議論があった。systemdはシェルスクリプトベースのinitスクリプトを宣言的なユニットファイルに置き換え、並列起動・依存関係管理・cgroups活用を実現し、init系のbash依存を大幅に削減した
- **一次ソース**: Lennart Poettering, "Rethinking PID 1", 2010; systemd Wikipedia; LWN.net "Debian decides on systemd", 2014
- **URL**: <https://0pointer.de/blog/projects/systemd.html>, <https://en.wikipedia.org/wiki/Systemd>, <https://lwn.net/Articles/585319/>
- **注意事項**: systemdの0.1リリースは2010年3月とする資料もあるが、公式発表は2010年4月のブログ記事が広く認知されている。Debianの投票はsystemd vs Upstartが主な論点
- **記事での表現**: 「2010年、Lennart Poetteringが"Rethinking PID 1"を発表し、systemdの構想を世に問うた。Fedora 15が2011年に最初に採用し、2015年のDebian 8とUbuntu 15.04を以て、主要ディストリビューションのsystemd移行はほぼ完了した」

---

## 2. Travis CIの歴史とbash使用

- **結論**: Travis CIは2011年初頭にSven FuchsとJosh Kalderimisを中心にサイドプロジェクトとして開始された。GitHubのオープンソースプロジェクト向けに無料CIサービスを提供した最初のサービスである。Travis CIは`.travis.yml`の各フェーズをコンパイルして単一のbashスクリプトに変換して実行する（travis-buildリポジトリがこの変換を担当）。2019年1月23日、Idera, Inc.に買収された。買収後、多くのオープンソースプロジェクトがGitHub Actionsなどへ移行した
- **一次ソース**: Travis CI Wikipedia; Idera, Inc. press release, 2019-01-23; travis-ci/travis-build GitHub repository
- **URL**: <https://en.wikipedia.org/wiki/Travis_CI>, <https://github.com/travis-ci/travis-build>
- **注意事項**: travis-buildリポジトリの説明は「.travis.yml => build.sh converter」と明記されている
- **記事での表現**: 「2011年に始まったTravis CIは、GitHubのオープンソースプロジェクトに無料CIを提供した先駆者である。その仕組みは明快だった。`.travis.yml`の各フェーズは最終的に単一のbashスクリプトにコンパイルされ、ワーカー上で実行される」

---

## 3. GitHub Actionsの登場とbashデフォルト

- **結論**: GitHub Actionsは2018年10月のGitHub Universeカンファレンスでベータとして発表され、2019年11月13日に一般提供（GA）された。Linux/macOSランナーにおける`run:`ステップのデフォルトシェルはbashである。具体的には`bash --noprofile --norc -eo pipefail {0}`として実行される。Windowsではデフォルトがpwshとなる
- **一次ソース**: GitHub Actions documentation, "Workflow syntax for GitHub Actions"
- **URL**: <https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions>
- **注意事項**: bashのデフォルトオプションに`-eo pipefail`が含まれている。`set -e`と`set -o pipefail`に相当するが、`-u`（nounset）は含まれていない
- **記事での表現**: 「2019年11月にGAとなったGitHub Actionsは、Linux/macOSランナーでのデフォルトシェルをbashとした。しかも`bash --noprofile --norc -eo pipefail`で実行される」

---

## 4. bats-coreの歴史

- **結論**: bats（Bash Automated Testing System）はSam Stephensonが2011年に作成した。TAP（Test Anything Protocol）準拠のbash用テスティングフレームワーク。オリジナルリポジトリ（sstephenson/bats）は2016年頃から開発が停滞。2017年9月19日、コミット0360811からbats-core/bats-coreとしてフォークされた。2021年4月29日、オリジナルリポジトリはアーカイブされ読み取り専用となった
- **一次ソース**: bats-core/bats-core GitHub repository; sstephenson/bats GitHub repository (archived)
- **URL**: <https://github.com/bats-core/bats-core>, <https://github.com/sstephenson/bats>
- **注意事項**: bats-coreのREADMEには「write access to the original repository could not be obtained」と明記されている
- **記事での表現**: 「2011年にSam Stephensonが作成したbats（Bash Automated Testing System）は、bashスクリプトにテスト文化をもたらそうとした意欲的な試みだった。オリジナルの開発が停滞した後、2017年にbats-coreとしてコミュニティフォークされた」

---

## 5. set -euo pipefailの各オプションの意味と歴史

- **結論**: `set -e`（errexit）はVersion 7 Unix（1979年）のBourne shellから存在し、POSIXで標準化されている。`set -u`（nounset）もPOSIXで標準化。`set -o pipefail`はbash 3.0（2004年7月27日リリース）で導入。pipefailはPOSIX標準には含まれず、bashおよびzsh等の拡張機能（dashには存在しない）
- **一次ソース**: Bash Reference Manual (GNU); POSIX.1-2004 set specification
- **URL**: <https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html>, <https://pubs.opengroup.org/onlinepubs/009695399/utilities/set.html>
- **注意事項**: `set -e`の挙動は歴史的にシェル間で微妙に異なり、「最も誤解されているシェルオプション」とも呼ばれる
- **記事での表現**: 「`set -e`は1979年のBourne shellから存在するが、その挙動の細部は今なお議論を呼ぶ。`pipefail`はbash 3.0（2004年）で追加されたbash拡張であり、POSIX標準ではない」

---

## 6. Dockerfileのshell form vs exec form

- **結論**: DockerfileのRUN、CMD、ENTRYPOINTにはshell form（`RUN command`）とexec form（`RUN ["executable", "param1"]`）がある。shell formはデフォルトで`/bin/sh -c`を介して実行。SHELL命令はDocker 1.12（2016年7月28日GA）で導入。Linuxのデフォルトは`["/bin/sh", "-c"]`
- **一次ソース**: Dockerfile reference, Docker official documentation
- **URL**: <https://docs.docker.com/reference/dockerfile/>
- **注意事項**: shell formでは環境変数の展開が行われるがexec formでは行われない。デフォルトが`/bin/sh`であって`/bin/bash`ではない点に注意
- **記事での表現**: 「Dockerfileの`RUN`はデフォルトで`/bin/sh -c`を介して実行される。bashですらない」

---

## 7. bashスクリプトの行数による適切な使い分け

- **結論**: Googleの Shell Style Guide は「100行を超えるスクリプトであれば、Pythonで書くべきである。スクリプトは成長するものだということを念頭に置くこと」と明記。シェルは「小さなユーティリティや単純なラッパースクリプト」にのみ使用すべきとしている
- **一次ソース**: Google Shell Style Guide (google/styleguide repository)
- **URL**: <https://google.github.io/styleguide/shellguide.html>
- **注意事項**: 100行という基準はGoogleの社内基準であり業界全体の標準ではないが、広く引用される権威あるガイドライン
- **記事での表現**: 「Googleの Shell Style Guide は『100行を超えるならPythonで書け。スクリプトは成長するものだ』と断言する」

---

## 8. ShellCheckの歴史と機能

- **結論**: ShellCheckはVidar Holen（GitHubユーザー名: koalaman）が2012年に開発を開始した静的解析ツール。Haskellで実装。2025年時点で約39,000スター（Haskellリポジトリ中Pandocに次ぐ第2位）。シェルスクリプトの一般的な問題やバッドプラクティスを指摘する
- **一次ソース**: koalaman/shellcheck GitHub repository; Vidar Holen, "Lessons learned from writing ShellCheck"
- **URL**: <https://github.com/koalaman/shellcheck>, <https://www.vidarholen.net/contents/blog/?p=859>
- **注意事項**: 趣味プロジェクトとして始まり、HaskellはHolenにとって「最も楽しく興味深い言語」だったために選択された
- **記事での表現**: 「2012年にVidar HolenがHaskellで書き始めたShellCheckは、bashスクリプトの静的解析ツールとして事実上の標準となった」

---

## 9. systemdとinitスクリプトの関係

- **結論**: SysV initではサービスの起動・停止・状態確認をシェルスクリプト（`/etc/init.d/`配下）で行っていた。systemdはこれを宣言的なユニットファイル（INI形式）に置き換えた。Poetteringは「シェルスクリプトは遅く、不必要に読みにくく、非常に冗長で脆い」と述べている
- **一次ソース**: Lennart Poettering, "systemd for Administrators, Part III" (0pointer.de)
- **URL**: <http://0pointer.de/blog/projects/systemd-for-admins-3.html>
- **注意事項**: systemdのユニットファイルでも`ExecStartPre=`等でシェルスクリプトを呼び出すことは可能。完全にシェルを排除したわけではない
- **記事での表現**: 「Poetteringは『シェルスクリプトは遅く、不必要に読みにくく、冗長で脆い』と断じた。systemdのユニットファイルは、数百行のinitスクリプトが担っていた責務を、数十行の宣言的な設定で置き換えた」

---

## 10. bash trapコマンドの仕様

- **結論**: trapはPOSIX標準で規定されたシェル組み込みコマンド。POSIXで標準化されているのはEXITとシグナル名（INT, TERM, HUP等）。ERRトラップはPOSIX標準には含まれず、bashの拡張機能（kshにも存在）。POSIXは「KornShellはset -eが終了を引き起こす場面でトリガーされるERRトラップを使用する。これは拡張として許容されるが義務化しなかった」と明記。DEBUGトラップ、RETURNトラップもbash拡張
- **一次ソース**: POSIX.1-2004 trap specification; Bash Reference Manual (GNU)
- **URL**: <https://pubs.opengroup.org/onlinepubs/009604399/utilities/trap.html>, <https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html>
- **注意事項**: EXIT（POSIX標準）とERR（bash拡張）の混同に注意
- **記事での表現**: 「trapはPOSIX標準のコマンドだが、bashスクリプトで多用されるERRトラップは実はbash拡張である」
