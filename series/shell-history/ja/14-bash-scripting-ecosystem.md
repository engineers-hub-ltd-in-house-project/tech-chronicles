# 第14回：bashスクリプティングの生態系――.bashrcからCI/CDまで

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- bashスクリプトが対話的設定（.bashrc）からシステム起動（initスクリプト）、CI/CDパイプラインまで、どこまで浸透しているか
- `set -euo pipefail`の各オプションの由来――POSIX標準のもの2つとbash拡張1つの組み合わせである事実
- trapコマンドの仕組みとERRトラップがbash拡張である事実
- SysV initからsystemdへの移行がbashスクリプトの役割をどう変えたか
- Travis CIからGitHub Actionsに至るCI/CDにおけるbashの位置づけ
- DockerfileのRUN命令がデフォルトで`/bin/sh -c`を使う事実とその含意
- bats-core（Bash Automated Testing System）によるテストの試みと限界
- bashスクリプトの「50行の壁」「100行の壁」――Googleの Shell Style Guideの基準
- ShellCheck（2012年, Vidar Holen）による静的解析の意義
- 「bash vs Python」論争の構造化――行数、依存管理、ポータビリティの3軸

---

## 1. 導入――「もうbashでは限界だ」と気づいた瞬間

2000年代後半、私は数百行のbashデプロイスクリプトと格闘していた。

当時の現場では、アプリケーションのデプロイ手順をbashスクリプトにまとめるのが「自動化」の標準的なアプローチだった。sshでリモートサーバに接続し、gitでコードを引っ張り、依存関係をインストールし、設定ファイルを配置し、サービスを再起動する。最初は50行程度のスクリプトだった。それが半年後には300行を超えていた。

300行のbashスクリプトは、書いた本人にとってすら読みにくい。3ヶ月前の自分が書いた条件分岐の意図が分からない。変数名のタイポで本番環境のファイルが消えかけたことがある。`rm -rf ${DEPLOY_DIR}/old`と書いたつもりが、変数が未定義で`rm -rf /old`が実行される寸前だった。`set -u`を設定していなかった。

テストを書こうとして気づいた。bashスクリプトにはまともなテストフレームワークがない。関数を切り出してユニットテストを書こうにも、関数の戻り値は終了ステータス（0-255の整数）か、標準出力に吐いた文字列をキャプチャするしかない。モックもスタブも存在しない。

エラーハンドリングは輪をかけて困難だった。`set -e`を設定すればコマンド失敗時にスクリプトが終了する。だが、`set -e`の挙動は直感に反する場面が多い。`if`文の条件部では`set -e`は無視される。パイプラインの途中のコマンドが失敗しても、パイプライン全体の終了ステータスは最後のコマンドのものになる（`pipefail`を設定しない限り）。

ある日、同僚のPythonエンジニアが私のデプロイスクリプトを見て言った。「これ、Pythonで書き直したら半分の行数で、しかもテスト付きで書けますよ」。反論できなかった。

その日から、私は「bashスクリプトの限界」を意識するようになった。bashは万能ではない。だが、どこからが限界なのか。その境界線を引くためには、bashスクリプトが実際にどこで使われ、何を担い、何に失敗しているのかを知る必要がある。

あなたのプロジェクトには、何行のbashスクリプトがあるだろうか。そのスクリプトにテストはあるだろうか。エラーが起きたとき、何が起こるかを正確に予測できるだろうか。

---

## 2. 歴史的背景――bashスクリプトが浸透した領域

### .bashrcから始まる――シェル設定ファイルの世界

bashスクリプトの最も身近な存在は、`~/.bashrc`だ。

ターミナルを開くたびに読み込まれるこのファイルは、エイリアス定義、PATH設定、プロンプトのカスタマイズ、シェルオプションの設定など、対話的な使い勝手を調整するスクリプトである。多くのエンジニアにとって、最初に書くbashスクリプトは`.bashrc`の編集だ。

だが`.bashrc`は、その単純さの裏に複雑な初期化の仕組みを隠している。bashの初期化ファイルは、ログインシェルか非ログインシェルか、対話的か非対話的かによって読み込まれるファイルが異なる。

```
ログインシェル（ssh接続、ttyログイン等）:
  /etc/profile → ~/.bash_profile → (~/.bash_login → ~/.profile)

非ログインシェル（ターミナルエミュレータで新しいタブを開く等）:
  ~/.bashrc

非対話的シェル（スクリプト実行）:
  $BASH_ENV で指定されたファイル（設定されていれば）
```

この二段構えの初期化は、ログイン時に一度だけ実行すべき処理（PATH設定、環境変数のエクスポート）と、シェルを開くたびに実行すべき処理（エイリアス、プロンプト設定）を分離する意図がある。だが実際には、多くのユーザーが`.bash_profile`に`.bashrc`を読み込む1行（`source ~/.bashrc`）を書いて、この分離を事実上無効化している。

この初期化の複雑さは、`.bashrc`に何を書くべきかという基本的な問いすら自明でないことを示している。bashスクリプティングの世界は、最も身近な`.bashrc`の時点で既に一筋縄ではいかない。

### initスクリプト――bashがシステムを起動していた時代

`.bashrc`が個人の環境を整えるスクリプトなら、initスクリプトはシステム全体を起動するスクリプトだった。

SysV init（System V init）の時代、Linuxシステムの起動シーケンスはシェルスクリプトによって制御されていた。`/etc/init.d/`ディレクトリに置かれた各サービスの起動スクリプトは、`start`、`stop`、`restart`、`status`などの引数を受け取り、対応する処理を実行する。典型的なinitスクリプトは100行から300行に及んだ。

```bash
#!/bin/sh
# SysV initスクリプトの典型的な構造（簡略化）
case "$1" in
    start)
        echo "Starting myservice..."
        start-stop-daemon --start --pidfile /var/run/myservice.pid \
            --exec /usr/bin/myservice -- --config /etc/myservice.conf
        ;;
    stop)
        echo "Stopping myservice..."
        start-stop-daemon --stop --pidfile /var/run/myservice.pid
        ;;
    restart)
        $0 stop
        sleep 1
        $0 start
        ;;
    status)
        if [ -f /var/run/myservice.pid ]; then
            echo "myservice is running"
        else
            echo "myservice is not running"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
```

起動順序は、`/etc/rc.d/`配下のシンボリックリンクのファイル名に埋め込まれた連番（S01, S02, ...）で制御されていた。S10のスクリプトはS20のスクリプトより先に実行される。この「ファイル名で起動順序を決める」仕組みは素朴だが、依存関係の複雑化には耐えられなかった。

2010年、Lennart Poetteringが"Rethinking PID 1"と題したブログ記事でsystemdの構想を発表した。Poetteringは「シェルスクリプトは遅く、不必要に読みにくく、冗長で脆い」と断じた。systemdのユニットファイルは、数百行のinitスクリプトが担っていた責務を、数十行の宣言的な設定で置き換えた。

```ini
# systemd ユニットファイルの例
[Unit]
Description=My Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/myservice --config /etc/myservice.conf
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Fedora 15（2011年）が最初にsystemdをデフォルト採用し、Arch Linux、openSUSE（2012年）、RHEL 7（2014年）、そしてDebian 8 Jessie、Ubuntu 15.04（2015年）と主要ディストリビューションが続いた。Debianでは2014年2月にTechnical Committeeが4:4の票割れの末、議長Bdale Garbeeの裁定でsystemdを採用するという激しい議論があった。

systemdの普及により、システム起動における「数百行のbashスクリプト」の時代は終わった。bashは起動プロセスの主役の座を降りた。だが、これはbashスクリプトの「退場」ではない。役割が変わっただけだ。

### CI/CD――bashスクリプトの新たな棲み家

initスクリプトでの役割を失いつつあったbashは、別の領域で新たな居場所を見つけた。CI/CD（継続的インテグレーション/継続的デリバリー）だ。

2011年に始まったTravis CIは、GitHubのオープンソースプロジェクトに無料CIを提供した先駆者である。その仕組みは明快だった。`.travis.yml`の各フェーズ（`before_install`、`install`、`script`等）は最終的に単一のbashスクリプトにコンパイルされ、ワーカー上で実行される。CIパイプラインの「実体」はbashスクリプトだったのだ。

2019年11月に一般提供（GA）となったGitHub Actionsは、CI/CDの新たな標準となった。GitHub Actionsのワークフローにおける`run:`ステップは、Linux/macOSランナーではデフォルトでbashが使われる。具体的には、次のコマンドとして実行される。

```
bash --noprofile --norc -eo pipefail {0}
```

この`-eo pipefail`は注目に値する。`-e`は`set -e`（エラー時即座終了）に、`-o pipefail`はパイプラインの失敗検知に相当する。GitHub自身が、bashスクリプトのベストプラクティスの一部をデフォルトに組み込んだのだ。ただし`-u`（未定義変数のエラー）は含まれていない。これはおそらく、多くの既存スクリプトが未定義変数に依存しているための互換性上の判断だろう。

GitHub Actionsのワークフローを書いたことがある人なら、`run:`ステップの中身がbashスクリプトであることは知っているだろう。だが、そのbashが`-eo pipefail`で実行されていることを意識している人は多くない。

### DockerfileのRUN命令――/bin/shの罠

2013年に登場したDockerは、コンテナ技術の標準となった。Dockerfileの`RUN`命令は、shell form（`RUN command`）とexec form（`RUN ["executable", "param1"]`）の二つの書き方がある。

shell formの場合、コマンドはデフォルトで`/bin/sh -c`を介して実行される。`/bin/bash`ではない。これは多くの開発者が見落としている事実だ。

Alpine Linuxベースのイメージ（`alpine:*`）では、`/bin/sh`はBusyBox ashへのシンボリックリンクだ。第12回で論じた通り、ashはPOSIXに準拠する最小限のシェルであり、bashの拡張機能（配列、`[[`、プロセス置換等）は使えない。

```dockerfile
# これは /bin/sh -c で実行される
RUN echo "hello"

# bash が必要な場合は明示的に指定する
RUN ["/bin/bash", "-c", "echo hello"]

# Docker 1.12（2016年）以降、SHELL命令でデフォルトを変更可能
SHELL ["/bin/bash", "-c"]
RUN echo "now using bash"
```

Docker 1.12（2016年7月GA）で導入されたSHELL命令により、shell formで使用されるデフォルトシェルを変更できるようになった。だが、多くのDockerfileは今もこの事実を意識せず、bash依存のコマンドをshell formで書いてAlpine環境でエラーに遭遇する。

これは第11回、第12回で論じた「bashとPOSIX shの境界」という問題が、コンテナ時代においても繰り返されていることを意味する。

---

## 3. 技術論――bashスクリプティングのベストプラクティスと限界

### set -euo pipefail の解剖

bashスクリプトのベストプラクティスとして最も広く知られているのが、スクリプト冒頭の`set -euo pipefail`だ。だが、この3つのオプションの由来と動作を正確に理解している開発者は多くない。

```bash
#!/bin/bash
set -euo pipefail
```

この1行は、3つの独立したオプションの組み合わせだ。

**`set -e`（errexit）**。1979年のBourne shell（UNIX V7）から存在し、POSIXで標準化されている。コマンドが非ゼロの終了ステータスを返した際に、シェルを即座に終了させる。

だが、`set -e`の挙動は直感に反する場面が多く、「最も誤解されているシェルオプション」とも呼ばれる。`if`文の条件部、`&&`や`||`の右辺、`!`で否定されたコマンドでは、`set -e`によるスクリプト終了は発動しない。

```bash
set -e

# これはスクリプトを終了させない
if false; then echo "yes"; fi

# これもスクリプトを終了させない
false || echo "recovered"

# これはスクリプトを終了させる
false
echo "この行は実行されない"
```

**`set -u`（nounset）**。POSIXで標準化。未設定の変数を参照した際にエラーとする。前述の「変数が未定義で`rm -rf /old`が実行される」事故を防ぐ。

```bash
set -u

# これはエラーになる
echo "$UNDEFINED_VAR"
# bash: UNDEFINED_VAR: unbound variable

# デフォルト値を使えば安全
echo "${UNDEFINED_VAR:-default_value}"
```

**`set -o pipefail`**。bash 3.0（2004年7月27日リリース）で導入されたbash拡張であり、POSIX標準ではない。パイプライン中の最後に失敗したコマンドの終了ステータスをパイプライン全体の終了ステータスとする。

```bash
# pipefail なし：grep がマッチしなくてもパイプラインは成功
set +o pipefail
echo "hello" | grep "world" | cat
echo "Exit: $?"  # 0（cat の終了ステータス）

# pipefail あり：grep の失敗がパイプライン全体の失敗になる
set -o pipefail
echo "hello" | grep "world" | cat
echo "Exit: $?"  # 1（grep の終了ステータス）
```

ここで見落とすべきでない事実がある。`set -euo pipefail`の3つのオプションのうち、POSIX標準なのは`-e`と`-u`の2つだけだ。`pipefail`はbash拡張であり、dashやBusyBox ashでは使えない。つまり`set -euo pipefail`と書いた瞬間、そのスクリプトはbash（またはzsh等の互換シェル）でしか動作しなくなる。

GitHub Actionsが`bash --noprofile --norc -eo pipefail`をデフォルトにしているのは、bashの存在を前提としている。CI/CDという「制御された環境」だからこそ可能な前提だ。

### trap――クリーンアップの技法

`set -euo pipefail`がエラー検知の仕組みなら、`trap`はエラー発生時（およびスクリプト終了時）のクリーンアップの仕組みだ。

```bash
#!/bin/bash
set -euo pipefail

TMPDIR=""

cleanup() {
    if [[ -n "${TMPDIR}" && -d "${TMPDIR}" ]]; then
        rm -rf "${TMPDIR}"
        echo "Cleaned up: ${TMPDIR}"
    fi
}

trap cleanup EXIT

TMPDIR=$(mktemp -d)
echo "Working in: ${TMPDIR}"
# ... 作業 ...
# スクリプトが正常終了しても異常終了してもcleanupが実行される
```

`trap`自体はPOSIX標準のコマンドだ。`EXIT`シグナル（スクリプト終了時）、`INT`（Ctrl-C）、`TERM`（kill）、`HUP`（端末切断）などのシグナルに対してハンドラを設定できる。

だが、bashスクリプトで多用される`ERR`トラップは、実はbash拡張である。POSIX仕様書自身がこう記している。「KornShellはset -eが終了を引き起こす場面でトリガーされるERRトラップを使用する。これは拡張として許容されるが、他のシェルが使用していないため義務化しなかった」。

```bash
# ERR トラップ（bash拡張）
trap 'echo "Error on line $LINENO: command failed with exit code $?"' ERR

# これはPOSIX準拠シェルでは動作しない
```

`trap cleanup ERR`と書いた瞬間、そのスクリプトはbash依存となる。`trap cleanup EXIT`はPOSIX準拠だが、`trap handler ERR`はそうではない。この区別を知らないまま「ベストプラクティス」を模倣すると、ポータビリティを失う。

### bashスクリプティングの限界

bashスクリプトの技術的な限界は、複数の軸で現れる。

**型システムの不在**。bashには文字列以外の型がない。配列と連想配列は存在するが、それらの要素もすべて文字列だ。整数演算は`$(( ... ))`構文で可能だが、浮動小数点は扱えない。構造体もクラスもない。データ構造が必要になった瞬間、bashは力不足になる。

**エラーハンドリングの脆弱性**。`set -e`は「あらゆるエラーを捕捉する」わけではない。前述の通り、`if`文の条件部や`&&`/`||`の右辺では無効化される。例外機構（try/catch）は存在しない。関数の「戻り値」は0-255の整数か、標準出力に書いた文字列をキャプチャするしかない。構造化されたエラー情報を伝達する手段がない。

**テストの困難さ**。2011年にSam Stephensonが作成したbats（Bash Automated Testing System）は、bashスクリプトにテスト文化をもたらそうとした意欲的な試みだった。batsはTAP（Test Anything Protocol）準拠のテスティングフレームワークで、シェル関数やコマンドの出力・終了ステータスを検証できる。

```bash
# bats テストの例
@test "addition using bc" {
    result="$(echo '2+2' | bc)"
    [ "$result" -eq 4 ]
}

@test "check file existence" {
    run ls /etc/passwd
    [ "$status" -eq 0 ]
}
```

オリジナルのbatsプロジェクトは2016年頃から開発が停滞し、メンテナへのアクセスが得られなくなった。2017年9月にbats-coreとしてコミュニティフォークされ、現在も活発に開発が続いている。

bats-coreの存在は重要だが、PythonのpytestやJavaScriptのJestと比較すれば、その限界は明白だ。モック、スタブ、フィクスチャ、パラメトライズドテスト、カバレッジ計測――汎用プログラミング言語のテストエコシステムが提供するこれらの機能は、batsでは限定的にしか実現できない。bashスクリプトは、構造上テストが書きにくいのだ。

**リファクタリングの困難さ**。静的型付けのない言語では、変数名の変更や関数シグネチャの変更が安全にできるかどうかはテストに依存する。だが、前述の通りテストが書きにくい。そしてIDEのサポートも限定的だ。bashスクリプトに対するリネームリファクタリングや参照検索を正確に行えるIDEは、2026年現在でも存在しない。

2012年にVidar HolenがHaskellで書き始めたShellCheckは、bashスクリプトの静的解析ツールとして事実上の標準となった。GitHub上で39,000以上のスターを獲得し、Haskellで書かれたリポジトリとしてはPandocに次ぐ第2位に位置する。ShellCheckはクォーティングの問題（SC2086）、未使用変数、非推奨構文など、シェルスクリプトの典型的な問題を指摘してくれる。

だが、ShellCheckは「bashスクリプトをより安全にする」ツールであって、「bashスクリプトの設計上の限界を超える」ツールではない。型の誤りを検出することはできないし、ビジネスロジックの正しさを検証することもできない。

### 「bash vs Python」論争の構造化

「これ、Pythonで書くべきでは？」。bashスクリプトがある程度の規模になると、必ずこの問いが浮上する。この論争を感情ではなく構造で整理する。

**行数**。Googleの Shell Style Guide は「100行を超えるスクリプトであれば、Pythonで書くべきである。スクリプトは成長するものだということを念頭に置くこと」と明言している。この100行という閾値は、私の経験とも概ね一致する。ただし、私はさらに厳しく「50行」を目安にしている。50行を超えたら、少なくともPythonへの書き換えを検討すべきだ。

**依存管理**。bashスクリプトの最大の利点の一つは「追加の依存がない」ことだ。bashはほぼすべてのUNIX系OSに存在する。Pythonスクリプトを書けば、Pythonのバージョン管理、仮想環境、pip依存の管理が必要になる。この追加コストは無視できない。

だが、この利点はbashの範囲内に留まる場合に限られる。curlでAPIを叩いてJSONをパースする必要があれば、jqが必要になる。CSVを処理するならawkかperlが必要になる。結局、bashスクリプトも「外部コマンドへの依存」からは逃れられない。

**ポータビリティ**。bashスクリプトは「bashが存在する環境」でしか動かない。Alpine Linuxのデフォルトにはbashは入っていない。第12回で論じた通り、POSIX sh準拠でスクリプトを書けばポータビリティは高まるが、bashの便利な拡張機能は使えなくなる。

Pythonはほぼすべての環境で利用可能だが、バージョンの問題がある。Python 2と3の互換性問題は記憶に新しい。だが、2026年現在ではPython 3.8以降を前提にすれば、大きなポータビリティの問題はない。

**整理すると、bashスクリプトが適切な領域は次の通りだ**。

```
bashが適切な場面:
- 外部コマンドの呼び出しが主な処理（パイプ接続、ファイル操作）
- 50行以下の「接着剤」（glue）スクリプト
- setup.sh、install.sh のような環境構築スクリプト
- CI/CDの個別ステップ（数行〜十数行）

Pythonに切り替えるべき場面:
- データ構造の操作が必要（JSON、CSV、XML）
- エラーハンドリングが複雑
- テストを書く必要がある
- 100行を超える見込みがある
- 複数人でメンテナンスする
```

この境界線は固定ではない。チームのスキルセット、プロジェクトの要件、実行環境の制約によって変動する。だが、「bashで書けるからbashで書く」という判断は危険だ。「bashで書くべきかどうか」を問う習慣こそが、bashスクリプティングの限界を知る第一歩だ。

---

## 4. ハンズオン――bashスクリプティングの実践と限界を体感する

ここまでの議論を、手を動かして確認する。bashスクリプティングのベストプラクティスを実践し、同時にその限界を体感する。

### 環境構築

Docker環境を前提とする。Ubuntu 24.04にはbash 5.2が搭載されている。

```bash
# Ubuntu環境（bash 5.2）
docker run -it ubuntu:24.04 /bin/bash
```

あるいは、本記事に付属する`setup.sh`スクリプトで一括構築できる。

```bash
bash setup.sh
```

### 演習1: set -euo pipefail の挙動を体感する

`set -e`、`set -u`、`set -o pipefail`それぞれの挙動を、意図的にエラーを起こして確認する。

```bash
echo "=== 演習1: set -euo pipefail の挙動 ==="

# --- set -e の基本挙動 ---
echo ""
echo "--- set -e: エラーで即座終了 ---"

bash -e -c '
echo "1. この行は実行される"
false
echo "2. この行は実行されない"
' 2>&1 || echo "(スクリプトがエラーで終了した)"

# --- set -e が無視される場面 ---
echo ""
echo "--- set -e が無視される場面 ---"

bash -e -c '
# if の条件部では -e は無視される
if false; then echo "yes"; else echo "if: -e は無視された"; fi

# && の右辺が失敗してもスクリプトは続く
true && false || echo "&&/||: -e は無視された"

# ! で否定されたコマンド
! false
echo "!: -e は無視された"
echo "スクリプトはまだ実行中"
'

# --- set -u: 未定義変数の検知 ---
echo ""
echo "--- set -u: 未定義変数の検知 ---"

bash -u -c '
echo "定義済み: ${HOME}"
echo "未定義参照の試み..."
echo "${UNDEFINED_VAR}"
' 2>&1 || echo "(未定義変数でエラーになった)"

echo ""
echo "デフォルト値を使えばエラーを回避:"
bash -u -c '
echo "デフォルト値: ${UNDEFINED_VAR:-safe_default}"
echo "成功"
'

# --- pipefail の効果 ---
echo ""
echo "--- pipefail: パイプラインの失敗検知 ---"

echo "pipefail OFF:"
bash -c '
echo "data" | grep "missing" | cat
echo "  終了ステータス: $?"
'

echo "pipefail ON:"
bash -c '
set -o pipefail
echo "data" | grep "missing" | cat
echo "  終了ステータス: $?"
' 2>/dev/null || echo "  (pipefail でパイプラインが失敗として検知された)"
```

### 演習2: trap によるクリーンアップの実装

スクリプト終了時のクリーンアップをtrapで実装する。正常終了、Ctrl-C中断、エラー終了の各場面でクリーンアップが実行されることを確認する。

```bash
echo "=== 演習2: trap によるクリーンアップ ==="

cat << 'SCRIPT' > /tmp/trap_demo.sh
#!/bin/bash
set -euo pipefail

TMPDIR=""

cleanup() {
    local exit_code=$?
    echo "[cleanup] 終了コード: ${exit_code}"
    if [[ -n "${TMPDIR}" && -d "${TMPDIR}" ]]; then
        rm -rf "${TMPDIR}"
        echo "[cleanup] 一時ディレクトリを削除: ${TMPDIR}"
    fi
    echo "[cleanup] クリーンアップ完了"
}

# EXIT トラップ（POSIX準拠）
trap cleanup EXIT

# 一時ディレクトリの作成
TMPDIR=$(mktemp -d)
echo "一時ディレクトリ: ${TMPDIR}"
echo "test data" > "${TMPDIR}/test.txt"
echo "ファイル作成: ${TMPDIR}/test.txt"

# 引数に応じてエラーを発生させる
case "${1:-normal}" in
    normal)
        echo "正常終了のケース"
        ;;
    error)
        echo "エラー発生のケース"
        false  # set -e によりここでスクリプトが終了
        ;;
    *)
        echo "Usage: $0 [normal|error]"
        ;;
esac

echo "スクリプト完了"
SCRIPT
chmod +x /tmp/trap_demo.sh

echo "--- 正常終了 ---"
bash /tmp/trap_demo.sh normal

echo ""
echo "--- エラー終了 ---"
bash /tmp/trap_demo.sh error 2>/dev/null || true

echo ""
echo "--- ERRトラップ（bash拡張） ---"

bash -c '
trap '\''echo "[ERR] エラー発生: 行 $LINENO, コマンド: $BASH_COMMAND"'\'' ERR
echo "コマンド1: 成功"
true
echo "コマンド2: 失敗を発生させる"
false
echo "この行は実行されない（set -e がない場合は実行される）"
' 2>&1 || true

rm -f /tmp/trap_demo.sh
```

### 演習3: bats-core によるbashスクリプトのテスト

bats-coreをインストールし、bashスクリプトのテストを書いて実行する。

```bash
echo "=== 演習3: bats-core によるテスト ==="

# bats-core のインストール
apt-get update -qq && apt-get install -y -qq git >/dev/null 2>&1

git clone --depth 1 https://github.com/bats-core/bats-core.git /tmp/bats-core 2>/dev/null
/tmp/bats-core/install.sh /usr/local 2>/dev/null

echo "bats バージョン: $(bats --version)"

# テスト対象のスクリプト（関数ライブラリ）
cat << 'LIBRARY' > /tmp/string_utils.sh
#!/bin/bash

# 文字列を大文字に変換
to_upper() {
    echo "${1}" | tr '[:lower:]' '[:upper:]'
}

# 文字列が空かどうか
is_empty() {
    [[ -z "${1:-}" ]]
}

# ファイルの行数を返す
count_lines() {
    local file="${1}"
    if [[ ! -f "${file}" ]]; then
        echo "Error: file not found: ${file}" >&2
        return 1
    fi
    wc -l < "${file}"
}
LIBRARY

# bats テストファイル
cat << 'TEST' > /tmp/test_string_utils.bats
#!/usr/bin/env bats

setup() {
    source /tmp/string_utils.sh
}

@test "to_upper: 小文字を大文字に変換" {
    result=$(to_upper "hello world")
    [ "$result" = "HELLO WORLD" ]
}

@test "to_upper: 既に大文字の文字列" {
    result=$(to_upper "HELLO")
    [ "$result" = "HELLO" ]
}

@test "is_empty: 空文字列" {
    run is_empty ""
    [ "$status" -eq 0 ]
}

@test "is_empty: 非空文字列" {
    run is_empty "hello"
    [ "$status" -eq 1 ]
}

@test "count_lines: 既存ファイル" {
    tmpfile=$(mktemp)
    printf "line1\nline2\nline3\n" > "$tmpfile"
    result=$(count_lines "$tmpfile")
    rm -f "$tmpfile"
    [ "$result" -eq 3 ]
}

@test "count_lines: 存在しないファイル" {
    run count_lines "/nonexistent/file"
    [ "$status" -eq 1 ]
    [[ "$output" == *"file not found"* ]]
}
TEST

# テストの実行
echo ""
echo "--- テスト実行 ---"
bats /tmp/test_string_utils.bats

# クリーンアップ
rm -f /tmp/string_utils.sh /tmp/test_string_utils.bats
rm -rf /tmp/bats-core
```

### 演習4: ShellCheck による静的解析

問題のあるスクリプトをShellCheckで解析し、典型的な警告を確認する。

```bash
echo "=== 演習4: ShellCheck による静的解析 ==="

# ShellCheck のインストール
apt-get install -y -qq shellcheck >/dev/null 2>&1

echo "ShellCheck バージョン: $(shellcheck --version | head -2)"

# 問題のあるスクリプト（意図的にバッドプラクティスを含む）
cat << 'BADSCRIPT' > /tmp/bad_script.sh
#!/bin/bash

# 問題1: クォートされていない変数（SC2086）
filename=$1
cat $filename

# 問題2: バッククォートの使用（SC2006）
current_date=`date`

# 問題3: コマンド置換のクォーティング（SC2046）
files=$(ls *.txt)

# 問題4: 配列を文字列として扱う（SC2128）
arr=(one two three)
echo $arr

# 問題5: [ ] 内での == 使用（SC2039 in sh mode）
if [ "$filename" == "test" ]; then
    echo "match"
fi
BADSCRIPT

echo ""
echo "--- ShellCheck の解析結果 ---"
shellcheck /tmp/bad_script.sh || true

echo ""
echo "--- 修正後のスクリプト ---"
cat << 'GOODSCRIPT' > /tmp/good_script.sh
#!/bin/bash
set -euo pipefail

# 修正1: 変数をクォート
filename="${1}"
cat "${filename}"

# 修正2: $() を使用
current_date=$(date)

# 修正3: グロブは配列に格納
shopt -s nullglob
files=(*.txt)

# 修正4: 配列全体を参照
arr=(one two three)
echo "${arr[@]}"

# 修正5: = を使用（POSIX準拠）
if [ "${filename}" = "test" ]; then
    echo "match"
fi
GOODSCRIPT

echo ""
shellcheck /tmp/good_script.sh && echo "ShellCheck: 問題なし"

rm -f /tmp/bad_script.sh /tmp/good_script.sh
```

### 演習5: bash vs Python の実装比較

同じタスク（テキストファイルの統計情報を出力）をbashとPythonで実装し、可読性とロバスト性を比較する。

```bash
echo "=== 演習5: bash vs Python 実装比較 ==="

# テストデータの作成
cat << 'DATA' > /tmp/access.log
2024-01-15 10:00:01 GET /api/users 200
2024-01-15 10:00:02 POST /api/users 201
2024-01-15 10:00:03 GET /api/users/1 200
2024-01-15 10:00:04 GET /api/products 200
2024-01-15 10:00:05 POST /api/orders 500
2024-01-15 10:00:06 GET /api/users 200
2024-01-15 10:00:07 GET /api/products 404
2024-01-15 10:00:08 DELETE /api/users/1 200
2024-01-15 10:00:09 GET /api/orders 200
2024-01-15 10:00:10 POST /api/users 500
DATA

# --- bash版 ---
echo "--- bash版: アクセスログ解析 ---"
cat << 'BASH_VER' > /tmp/analyze_bash.sh
#!/bin/bash
set -euo pipefail

file="${1:?Usage: $0 <logfile>}"

if [[ ! -f "${file}" ]]; then
    echo "Error: ${file} not found" >&2
    exit 1
fi

total=$(wc -l < "${file}")
echo "Total requests: ${total}"

echo ""
echo "Status code distribution:"
awk '{print $NF}' "${file}" | sort | uniq -c | sort -rn | \
    while read -r count code; do
        printf "  %s: %d (%.1f%%)\n" "${code}" "${count}" \
            "$(echo "scale=1; ${count} * 100 / ${total}" | bc)"
    done

echo ""
echo "HTTP method distribution:"
awk '{print $3}' "${file}" | sort | uniq -c | sort -rn | \
    while read -r count method; do
        printf "  %s: %d\n" "${method}" "${count}"
    done

echo ""
echo "Error requests (4xx/5xx):"
awk '$NF >= 400 {print "  " $0}' "${file}"
BASH_VER
chmod +x /tmp/analyze_bash.sh
bash /tmp/analyze_bash.sh /tmp/access.log

echo ""
echo "--- Python版: 同じアクセスログ解析 ---"

# Python がインストールされているか確認
if command -v python3 >/dev/null 2>&1; then
    cat << 'PYTHON_VER' > /tmp/analyze_python.py
#!/usr/bin/env python3
import sys
from collections import Counter
from pathlib import Path

def analyze_log(filepath):
    path = Path(filepath)
    if not path.exists():
        print(f"Error: {filepath} not found", file=sys.stderr)
        sys.exit(1)

    lines = path.read_text().strip().split("\n")
    total = len(lines)
    print(f"Total requests: {total}")

    # Parse entries
    entries = []
    for line in lines:
        parts = line.split()
        entries.append({
            "date": parts[0],
            "time": parts[1],
            "method": parts[2],
            "path": parts[3],
            "status": int(parts[4]),
        })

    # Status code distribution
    print("\nStatus code distribution:")
    status_counts = Counter(e["status"] for e in entries)
    for code, count in status_counts.most_common():
        pct = count * 100 / total
        print(f"  {code}: {count} ({pct:.1f}%)")

    # HTTP method distribution
    print("\nHTTP method distribution:")
    method_counts = Counter(e["method"] for e in entries)
    for method, count in method_counts.most_common():
        print(f"  {method}: {count}")

    # Error requests
    print("\nError requests (4xx/5xx):")
    for i, e in enumerate(entries):
        if e["status"] >= 400:
            print(f"  {lines[i]}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 analyze.py <logfile>", file=sys.stderr)
        sys.exit(1)
    analyze_log(sys.argv[1])
PYTHON_VER
    python3 /tmp/analyze_python.py /tmp/access.log
else
    echo "(python3 が見つからないためスキップ)"
fi

echo ""
echo "=== 比較のポイント ==="
echo "bash版: 13行（パイプとawk/sortの連携。簡潔だがパースが脆い）"
echo "Python版: 35行（構造化されたデータ処理。テスト・拡張が容易）"
echo ""
echo "bash版の弱点:"
echo "  - ログフォーマットが変わると壊れやすい"
echo "  - エラーメッセージにスペースが含まれると誤動作"
echo "  - ユニットテストが書きにくい"
echo ""
echo "bash版の強み:"
echo "  - Python不要で動作する"
echo "  - パイプの組み合わせが直感的"
echo "  - 少ない行数で目的を達成"

rm -f /tmp/access.log /tmp/analyze_bash.sh /tmp/analyze_python.py
```

---

## 5. まとめと次回予告

### この回の要点

第一に、bashスクリプトは`.bashrc`からinitスクリプト、CI/CDパイプライン、Dockerfileまで、ソフトウェア開発の広範な領域に浸透している。その浸透の深さゆえに、bashの限界を知ることは実務上重要だ。

第二に、`set -euo pipefail`の3つのオプションは、POSIX標準の`-e`と`-u`、そしてbash拡張の`pipefail`（bash 3.0, 2004年）の組み合わせだ。この「ベストプラクティス」を使った瞬間、スクリプトはbash依存となる。`trap`コマンドのERRトラップもbash拡張であり、POSIX準拠ではない。

第三に、2010年にLennart Poetteringが発表したsystemdは、SysV initの数百行のシェルスクリプトを宣言的なユニットファイルに置き換え、システム起動におけるbashの役割を大きく後退させた。だがCI/CDの世界では、Travis CI（2011年）からGitHub Actions（2019年GA）に至るまで、bashは「パイプラインの実体」として健在だ。

第四に、bashスクリプトの限界は「型システムの不在」「エラーハンドリングの脆弱性」「テストの困難さ」「リファクタリングの困難さ」に集約される。bats-core（2017年フォーク）やShellCheck（2012年, Vidar Holen）のようなツールはこれらの問題を緩和するが、根本的な解決にはならない。

第五に、Googleの Shell Style Guideは「100行を超えるならPythonで書け」と明言している。bashスクリプトは「50行以下の接着剤」として最も輝く。それを超えたら、別の言語を検討すべきだ。だが、その判断基準を持つには、bashの限界を実体験として知る必要がある。

### 冒頭の問いへの暫定回答

「bashスクリプトはどこまで信頼できるのか。そして、どこからがbashの限界なのか」――この問いに対する暫定的な答えはこうだ。

bashスクリプトは、「外部コマンドの組み合わせ」というシェル本来の役割において、今なお最も自然で効率的な手段だ。パイプで複数のコマンドをつなぎ、ファイルを操作し、環境を構築する。この「接着剤」としてのbashは信頼できる。

限界は、bashが「プログラミング言語」として使われたときに現れる。データ構造の操作、複雑な条件分岐、エラーの構造的な処理、テスト可能な設計――これらはbashの設計が想定していた範囲の外にある。Bourne shellが1979年にシェルを「プログラミング言語」に昇格させたとき（第4回参照）、その言語設計はあくまで「小さなスクリプト」を念頭に置いていた。47年後の今、その設計前提は変わっていない。

bashの限界は、bashの「欠陥」ではない。bashが解こうとした問題の「範囲」の反映だ。bashを「50行以下の接着剤」として信頼し、それを超える範囲には適切な言語を選ぶ。その使い分けこそが、bashの限界を知るということだ。

### 次回予告

今回、bashスクリプティングの生態系とその限界を語った。次回は、bashの覇権が揺らぐきっかけとなった決定的な事件を扱う。

次回のテーマは「GPLv3とbashデフォルト時代の終焉――AppleがmacOSのデフォルトをzshに変えた日」だ。

bash 3.2（2006年, GPLv2最終版）。bash 4.0（2009年, GPLv3）。AppleがGPLv3を忌避した経緯。macOSに13年間凍結されたbash 3.2。そして2019年、macOS Catalinaでの「The default interactive shell is now zsh」のメッセージ。ソフトウェアライセンスが技術選定を決める――この現実に、正面から向き合う。

「macOSがデフォルトシェルをbashからzshに変えたのは『技術的判断』だったのか、『ライセンス上の判断』だったのか」――次回は、その問いに答える。

---

## 参考文献

- Lennart Poettering, "Rethinking PID 1", 2010 <https://0pointer.de/blog/projects/systemd.html>
- Lennart Poettering, "systemd for Administrators, Part III" <http://0pointer.de/blog/projects/systemd-for-admins-3.html>
- systemd, Wikipedia <https://en.wikipedia.org/wiki/Systemd>
- LWN.net, "Debian decides on systemd" (2014) <https://lwn.net/Articles/585319/>
- Travis CI, Wikipedia <https://en.wikipedia.org/wiki/Travis_CI>
- GitHub Actions documentation, "Workflow syntax for GitHub Actions" <https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions>
- Dockerfile reference, Docker official documentation <https://docs.docker.com/reference/dockerfile/>
- Google Shell Style Guide <https://google.github.io/styleguide/shellguide.html>
- bats-core/bats-core, GitHub <https://github.com/bats-core/bats-core>
- koalaman/shellcheck, GitHub <https://github.com/koalaman/shellcheck>
- Vidar Holen, "Lessons learned from writing ShellCheck" <https://www.vidarholen.net/contents/blog/?p=859>
- GNU Bash Reference Manual <https://www.gnu.org/software/bash/manual/bash.html>
- POSIX.1-2004, trap specification <https://pubs.opengroup.org/onlinepubs/009604399/utilities/trap.html>
- POSIX.1-2004, set specification <https://pubs.opengroup.org/onlinepubs/009695399/utilities/set.html>
- TLDP, "Bash, version 3" <https://tldp.org/LDP/abs/html/bashver3.html>
