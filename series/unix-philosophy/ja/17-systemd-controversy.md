# UNIXという思想

## ――パイプ、プロセス、ファイル――すべてはここから始まった

### 第17回：「systemd論争――UNIXの原則は死んだのか」

**連載「UNIXという思想――パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- SysV init（1983年〜）のシェルスクリプトベースの初期化設計と、ランレベルによるサービス管理の仕組み
- Upstart（2006年）のイベント駆動型設計がSysV initの限界をどう乗り越えようとしたか
- Lennart Poetteringの「Rethinking PID 1」（2010年4月30日）が提示したsystemdの設計思想と技術的動機
- systemdの中核技術――ソケットアクティベーション、cgroups統合、宣言的ユニットファイル
- Debian Technical Committeeのsystemd採択投票（2014年2月）とコミュニティの分裂、Devuanフォークの誕生
- systemdの「範囲拡大」批判――init、ログ、ネットワーク、DNS、コンテナ管理への拡張
- UNIX哲学の「一つのことをうまくやれ」原則とsystemdの設計判断の衝突と接点

---

## 1. PID 1への違和感

2013年の春、私は管理していたサーバ群のOSをFedoraからRHEL系に切り替える準備を進めていた。

テスト環境を構築してまず気づいたのは、起動が速いことだった。SysV initの時代は、サービスが一つずつ順番に立ち上がっていくのを端末の前で待っていた。Apacheの起動、PostgreSQLの起動、postfixの起動——それぞれが前のサービスの起動完了を待ってから次に進む。数十秒、場合によっては1分以上かかることも珍しくなかった。それがsystemdでは、数秒で終わる。画面にログが流れる間もなく、ログインプロンプトが表示される。

速い。それは認める。

だが次に気づいたのは、`/etc/init.d/`が空になっていることだった。

私はサーバの運用で、SysV initスクリプトを何百本と書いてきた。サービスの起動、停止、ステータス確認——すべてシェルスクリプトで書く。中身を読めばサービスが何をしているのかがわかる。PIDファイルの場所、ログの出力先、依存サービスの確認——すべてがテキストとして、`/etc/init.d/`の中に透明に存在していた。

それが消えた。代わりにあるのは`/usr/lib/systemd/system/`配下のユニットファイル。INIスタイルの宣言的な設定ファイルだ。シェルスクリプトではない。`ExecStart=`にバイナリのパスが書いてある。依存関係は`After=`と`Requires=`で宣言されている。簡潔といえば簡潔だ。だが、シェルスクリプトの中で自在に条件分岐を書き、環境変数を設定し、前処理を走らせていた柔軟性は、どこに行ったのか。

さらに違和感を覚えたのは、`/var/log/messages`をcatで読もうとしたときだった。ファイルがない。ログはjournaldが管理するバイナリ形式のジャーナルに格納され、`journalctl`コマンドでしか読めない。`grep`も`awk`も`tail -f`も、直接は使えない。

私は端末の前で手を止めた。

これは何だ。`cat`で読めないログ。シェルスクリプトで書けないinit。`/etc/init.d/`のない`/etc/`。私が20年以上かけて身につけてきたUNIXの「作法」が、ことごとく通用しない。起動は速くなった。依存関係の解決は賢くなった。だが「一つのことをうまくやれ」はどこに行ったのか。initデーモンがログを管理し、ネットワークを設定し、DNSの解決までやるのか。

あなたのLinuxシステムのPID 1は何だろうか。そしてそのPID 1が、initだけでなくログもネットワークもデバイス管理も担っていることを、意識したことはあるだろうか。

---

## 2. SysV initからsystemdへ――何が問題だったのか

### SysV initの設計と限界

systemdが何であるかを理解するには、まずsystemdが置き換えたものを理解する必要がある。

SysV init——System V initは、1983年にAT&TがリリースしたUNIX System Vに由来するinit設計だ。UNIXにおけるPID 1、すなわちカーネルが起動する最初のユーザ空間プロセスの設計方法の一つである。

SysV initの設計は、シンプルだった。カーネルが`/sbin/init`を起動する。initは`/etc/inittab`を読み、デフォルトのランレベルを決定する。ランレベルとは、システムの動作モードを数値で表現したものだ。

```
SysV initのランレベル:

ランレベル  意味
─────────────────────────────────
  0         シャットダウン
  1 (S)     シングルユーザモード（メンテナンス）
  2         マルチユーザ（ネットワークなし）※ディストロにより異なる
  3         マルチユーザ（テキストモード、フルネットワーク）
  4         未定義（カスタム用途に予約）
  5         マルチユーザ（GUIログイン）
  6         リブート
─────────────────────────────────

ランレベルの切り替え:
  # init 3       ← テキストモードへ切り替え
  # telinit 5    ← GUIモードへ切り替え
```

各ランレベルに対応するディレクトリ`/etc/rc.d/rc0.d/`から`/etc/rc.d/rc6.d/`が存在し、その中にシンボリックリンクが格納される。リンク先は`/etc/init.d/`にある実際のサービススクリプトだ。リンク名の先頭がS（Start）なら起動、K（Kill）なら停止。続く2桁の数字が実行順序を決定する。

```
/etc/rc.d/rc3.d/ の中身（例）:

S10network → ../init.d/network     起動順序10: ネットワーク
S12syslog  → ../init.d/syslog      起動順序12: syslog
S20httpd   → ../init.d/httpd       起動順序20: Apache
S25postfix → ../init.d/postfix     起動順序25: Postfix
S30mysqld  → ../init.d/mysqld      起動順序30: MySQL
K15httpd   → ../init.d/httpd       停止順序15: Apache
```

initは対象のランレベルに入る際、まずKスクリプトを番号順に実行してサービスを停止し、次にSスクリプトを番号順に実行してサービスを起動する。それぞれのスクリプトは独立したシェルスクリプトであり、`start`、`stop`、`restart`、`status`といった引数に応じた処理を行う。

この設計には明確な美点がある。すべてがテキストだ。シンボリックリンクの名前を見れば起動順序がわかる。initスクリプトを`cat`すれば、サービスの起動手順が一目瞭然だ。`grep`で特定の設定を探せる。`vi`でスクリプトを編集すれば、起動手順をカスタマイズできる。UNIXの「テキストは万能インタフェース」という原則に忠実な設計だった。

だが、この設計には根本的な限界があった。

**逐次起動。** S10のスクリプトが完了するまで、S12は実行されない。S12が完了するまで、S20は実行されない。サービス間に実際の依存関係がなくても——たとえばApacheとPostfixは互いに依存しない——起動は直列に行われる。マルチコアCPUが当たり前の時代に、起動処理がシングルスレッドで走るのだ。

**暗黙的な順序依存。** S20のApacheがS10のネットワークに依存していることは、番号の順序から「暗黙的に」推測される。だがこの依存関係はどこにも明示的に宣言されていない。番号を間違えれば、ネットワークが上がる前にApacheが起動を試みて失敗する。この暗黙の依存関係を管理するのは、システム管理者の知識と経験に委ねられていた。

**プロセス追跡の不在。** SysV initはサービスを起動した後、そのプロセスを追跡しない。サービスがforkして新しいプロセスを生成し、元のプロセスが終了した場合、initは新しいプロセスの存在を知らない。PIDファイル（`/var/run/httpd.pid`など）でプロセスIDを記録する慣行はあったが、PIDファイルの更新忘れ、ファイルの不整合、PIDの再利用といった問題が常につきまとった。

**サービス復旧の困難。** サービスがクラッシュした場合、SysV initは何もしない。サービスが落ちたことを検知する仕組みがないのだ。monit、supervisord、daemontoolsといった外部ツールでプロセス監視を行う運用が広まったが、これはinitシステムの責務をアドホックに補完するものであり、統一的な解決策ではなかった。

### Upstartの挑戦

SysV initの限界を最初に体系的に解決しようとしたのは、CanonicalのScott James Remnantが2006年に開発したUpstartだった。

Upstartの設計思想はイベント駆動だった。「ネットワークが利用可能になった」「ファイルシステムがマウントされた」「ハードウェアが検出された」——こうしたイベントに応じてサービスを起動・停止する。SysV initの「番号順に起動する」という静的なモデルとは根本的に異なるアプローチだ。

Ubuntu 6.10 "Edgy Eft"（2006年10月）で初採用されたUpstartは、その後Red Hat Enterprise Linux 6（2010年）やGoogle Chrome OSでも採用された。SysV initの問題を認識し、代替を模索していたのはCanonicalだけではなかったのだ。

だがUpstartの支配は長くは続かなかった。2010年、Red HatのLennart PoetteringとKay Sieversが、さらに野心的な代替を提示する。

### Poetteringの「Rethinking PID 1」

2010年4月30日、Lennart Poetteringは「Rethinking PID 1」と題したブログ記事を公開した。この記事は、SysV initの問題を体系的に分析し、PID 1のあるべき姿を根本から問い直すものだった。

Poetteringの分析は、いくつかの技術的論点に集約される。

第一に、起動の高速化だ。Poetteringは「速く効率的な起動のために重要なのは二つ。より少なく起動すること、そしてより並列に起動することだ」と書いた。SysV initの逐次起動モデルは、マルチコアCPUを活用できない。サービス間の依存関係を適切に解決した上で、独立したサービスを並列に起動すれば、起動時間は劇的に短縮できる。

第二に、ソケットベースのアクティベーションだ。この発想はinetdに由来する。サービスが使用するソケットを、サービスの起動前にsystemdが作成しておく。サービスAがサービスBに依存している場合、サービスBのソケットが既に存在していれば、サービスAはサービスBの起動完了を待たずに起動できる。サービスBへの接続要求はソケットのバッファに蓄積され、サービスBが起動した時点で処理される。

第三に、cgroups統合だ。Linuxカーネルのcgroups（control groups）を使えば、サービスが生成したすべてのプロセスをカーネルレベルで追跡できる。PIDファイルの不整合やプロセスのfork問題を根本的に解決する。サービスをcgroupに閉じ込めることで、リソース制限（CPU、メモリ、I/O帯域）も可能になる。

第四に、シェルスクリプトの排除だ。SysV initスクリプトは事実上のプログラムであり、その実行にはシェルの起動が必要だ。起動時に数十のシェルスクリプトを解釈・実行するオーバーヘッドは無視できない。また、シェルスクリプトの品質はスクリプト作成者のスキルに依存し、エッジケースの処理が不完全なスクリプトが多数存在した。宣言的な設定ファイルでサービスの起動条件を記述すれば、このオーバーヘッドと品質のばらつきを排除できる。

Poetteringは、macOSのlaunchdからも着想を得たことを記事中で認めている。launchdはAppleが2005年にMac OS X 10.4 Tigerで導入したinit代替であり、ソケットベースのアクティベーションや宣言的な設定ファイル（plist形式）といった設計を先行して実装していた。

「Rethinking PID 1」は技術的に説得力のある文書だった。SysV initの問題を具体的に指摘し、各問題に対する解決策を明示した。ここまでは多くのエンジニアが同意できる。問題はその先にあった。

---

## 3. systemdの設計と論争

### ユニットファイル——命令から宣言へ

systemdがSysV initと最も異なる点は、サービスの定義方法だ。シェルスクリプトの代わりに、INIスタイルの宣言的なユニットファイルを使用する。

SysV initスクリプトとsystemdユニットファイルを比較すると、設計思想の違いが鮮明になる。

```
SysV initスクリプト（/etc/init.d/httpd）:
─────────────────────────────────────
#!/bin/bash
# chkconfig: 2345 85 15
# description: Apache HTTP Server

. /etc/rc.d/init.d/functions

HTTPD=/usr/sbin/httpd
PIDFILE=/var/run/httpd/httpd.pid
CONFFILE=/etc/httpd/conf/httpd.conf

start() {
    echo -n "Starting httpd: "
    # 設定ファイルの構文チェック
    $HTTPD -t -f $CONFFILE 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "FAILED (configuration error)"
        return 1
    fi
    # PIDファイルの存在チェック
    if [ -f $PIDFILE ]; then
        PID=$(cat $PIDFILE)
        if kill -0 $PID 2>/dev/null; then
            echo "already running (pid $PID)"
            return 0
        fi
        rm -f $PIDFILE
    fi
    $HTTPD -f $CONFFILE
    RETVAL=$?
    [ $RETVAL -eq 0 ] && touch /var/lock/subsys/httpd
    echo
    return $RETVAL
}

stop() {
    echo -n "Stopping httpd: "
    if [ -f $PIDFILE ]; then
        kill $(cat $PIDFILE)
        RETVAL=$?
        [ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/httpd
    fi
    echo
}

case "$1" in
    start)  start ;;
    stop)   stop ;;
    restart) stop; start ;;
    status) status -p $PIDFILE httpd ;;
    *)  echo "Usage: $0 {start|stop|restart|status}" ;;
esac
```

```
systemdユニットファイル（/usr/lib/systemd/system/httpd.service）:
─────────────────────────────────────
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd.service(8)

[Service]
Type=notify
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

ユニットファイルの簡潔さは一目瞭然だ。`[Unit]`セクションで名前と依存関係を宣言し、`[Service]`セクションで起動方法とプロセス管理を定義し、`[Install]`セクションでどの「ターゲット」（SysV initのランレベルに相当）に関連付けるかを指定する。

SysV initスクリプトが40行以上の手続き的なシェルスクリプトで表現していたものを、ユニットファイルは十数行の宣言で置き換えている。PIDファイルの管理、ロックファイルの作成、プロセスの存在確認——SysV initスクリプトで開発者が自ら実装しなければならなかったボイラープレートは、systemdが内部で処理する。

依存関係は明示的だ。`After=network.target`は「ネットワークが利用可能になった後に起動する」という順序依存を宣言する。`Requires=`は「このサービスが動いていなければ自分も起動しない」という強い依存を表す。`Wants=`は「このサービスがあれば起動するが、なくても自分は起動する」という弱い依存を表す。SysV initでは番号の順序で暗黙的に表現されていた依存関係が、ユニットファイルでは明示的にグラフ化される。

`Type=notify`は、サービスが起動完了時にsystemdに通知を送る方式を意味する。SysV initでは「プロセスが起動した=サービスが利用可能」と仮定するしかなかったが、systemdではサービス自身が「準備完了」を宣言できる。

`PrivateTmp=true`は、サービスに専用の`/tmp`ディレクトリを与えるセキュリティ機能だ。他のサービスやユーザの一時ファイルが見えない、名前空間による分離を実現する。initスクリプトでは実現困難だった機能が、1行の宣言で有効になる。

### 並列起動とソケットアクティベーション

systemdの並列起動の仕組みは、依存関係グラフに基づいている。

```
systemdの並列起動（概念図）:

  systemd起動
      │
      ├──→ local-fs.target（ファイルシステムマウント）
      │         │
      ├──→ network.target（ネットワーク設定）
      │         │
      │    ┌────┤
      │    │    │
      │    ▼    ▼
      │  httpd  postfix    ← 相互に依存しないため並列起動
      │    │
      │    ▼
      │  php-fpm           ← httpdに依存するため、httpdの後に起動
      │
      └──→ syslog.target
               │
               ▼
            journald

  SysV init: S10 → S12 → S20 → S25 → S30（直列）
  systemd:   依存関係のないサービスは同時に起動（並列）
```

依存関係のないサービスは同時に起動される。ネットワークが立ち上がった時点で、ApacheとPostfixは並列に起動を開始できる。SysV initではこの並列性を実現する手段がなかった。

ソケットアクティベーションは、さらに踏み込んだ最適化だ。systemdはサービスの起動前に、そのサービスが使用するソケットを作成する。サービスAがサービスBに接続する必要がある場合、サービスBのソケットは既に存在しているため、サービスAはサービスBの起動完了を待たずに起動を開始できる。サービスBへの接続要求はカーネルのソケットバッファに蓄積され、サービスBが起動してソケットをacceptした時点で処理される。

この設計により、依存関係があるサービス間でも並列起動が可能になる。結果として、systemdは「完全なユーザ空間の起動を約900ミリ秒で」完了すると、Poetteringは2013年の「The Biggest Myths」で述べている。

### cgroups統合——プロセス追跡の革新

systemdの技術的基盤として最も重要なのは、Linuxカーネルのcgroups（control groups）との統合だ。

```
systemdとcgroupsの関係:

  systemd (PID 1)
      │
      ├── system.slice
      │     ├── httpd.service
      │     │     ├── /usr/sbin/httpd (PID 1234)
      │     │     ├── /usr/sbin/httpd (PID 1235)  ← worker
      │     │     └── /usr/sbin/httpd (PID 1236)  ← worker
      │     │
      │     ├── postfix.service
      │     │     ├── /usr/libexec/postfix/master (PID 2001)
      │     │     ├── pickup (PID 2002)
      │     │     └── qmgr (PID 2003)
      │     │
      │     └── mysqld.service
      │           └── /usr/sbin/mysqld (PID 3001)
      │
      └── user.slice
            └── user-1000.slice
                  └── session-1.scope
                        ├── bash (PID 4001)
                        └── vim (PID 4002)

  各サービスのすべてのプロセスがcgroupで捕捉される。
  forkしてもdouble-forkしても、逃げられない。
```

systemdは起動するサービスごとにcgroupを作成し、そのサービスのプロセスをすべてcgroup内に閉じ込める。サービスがforkしようが、double-forkしようが、プロセスはcgroupから逃げられない。PIDファイルに頼ることなく、カーネルレベルでサービスのプロセスツリーを完全に追跡できる。

この設計がもたらす利点は大きい。サービスの停止時に、そのサービスに属するすべてのプロセスを確実に停止できる。リソースの使用状況をサービス単位で監視できる。CPU使用率、メモリ消費量、I/O帯域をサービスごとに制限できる。SysV initでは「プロセスが起動した後は知らない」だった状態が、「サービスのライフサイクル全体を管理する」に変わった。

### 範囲拡大——問題の核心

ここまでの話であれば、systemdへの反対は少なかっただろう。SysV initの問題は明確だった。並列起動、依存関係の解決、プロセス追跡、宣言的な設定——いずれも合理的な改善だ。

問題は、systemdがinitシステムにとどまらなかったことにある。

Poetteringは「The Biggest Myths」（2013年1月26日）で、systemdをフル構成でビルドすると69の個別バイナリが生成されると述べた。この数字自体が、systemdの範囲の広さを物語っている。

systemdが吸収したものを列挙する。

```
systemdが包含するコンポーネント（主要なもの）:

  コンポーネント          代替された従来のツール
  ──────────────────────────────────────────────
  systemd (PID 1)        SysV init / Upstart
  systemd-journald       syslog (rsyslogd)
  systemd-logind         ConsoleKit
  systemd-networkd       ifconfig / NetworkManager の一部
  systemd-resolved       /etc/resolv.conf の手動管理
  systemd-timesyncd      ntpd / chrony の一部
  systemd-tmpfiles       /etc/rc.local での一時ファイル管理
  systemd-udevd          udev（元は独立プロジェクト）
  systemd-homed          ホームディレクトリ管理（新規）
  systemd-boot           GRUB の代替ブートローダー
  machinectl             コンテナ / VM 管理
  systemd.timer          cron
  ──────────────────────────────────────────────
```

initデーモンがログを管理する。initデーモンがネットワークを設定する。initデーモンがDNSの名前解決をする。initデーモンが時刻同期をする。initデーモンがブートローダーになる。initデーモンがコンテナを管理する。initデーモンがcronの仕事をする。

「一つのことをうまくやれ」——UNIX哲学の第一原則への明白な違反に見える。

SlackwareのPatrick Volkerding はこの点を端的に批判した。「サービス、ソケット、デバイス、マウント等を一つのデーモンで制御しようとするのは、UNIXの"一つのことをうまくやれ"という概念に反する」。

Poettering自身は「The Biggest Myths」でこの批判に反論している。systemdは「一つのモノリシックなバイナリ」ではなく、69の独立したバイナリの集合体であると。各バイナリはそれぞれ独立した責務を持ち、明確に分離されている。journaldはログの責務を持ち、networkdはネットワーク設定の責務を持つ。それらが同じプロジェクトのリポジトリに存在し、同じリリースサイクルで提供されているだけだ、と。

さらにPoetteringは、systemdの中にもUNIXの精神が宿っていると主張する。たとえばcgroupfsを通じてすべてのサービスがファイルシステム上に公開されるのは、「すべてはファイルである」というUNIXの原則の反映だ、と。

この論争の核心は「"一つのこと"の粒度をどこに置くか」という問いだ。systemdのコンポーネントを個別に見れば、それぞれが一つのことをやっている。だがプロジェクト全体として見れば、かつて独立していた多数のツールを一つのプロジェクトに統合している。UNIX哲学が想定した「小さなツールの疎結合」とは、明らかに異なる設計判断だ。

### journald——テキスト文化との決裂

systemdの範囲拡大の中で、最も激しい批判を浴びたのがjournaldだ。

2011年のLinux Kernel Summitで、PoetteringとSieversはjournalをsyslog代替として提案した。従来のsyslog（rsyslogd等）は、ログをテキストファイルとして`/var/log/`に書き出す。journaldはログを構造化されたバイナリ形式で保存する。

技術的な動機は理解できる。テキスト形式のsyslogには問題がある。暗号学的な改ざん検出ができない。構造化されたクエリ（「特定のサービスの、特定の時間範囲の、特定の重要度のログ」）が非効率だ。バイナリデータを含められない。ユーザごとのアクセス制御が粗い。

journaldはこれらの問題に対処した。ログエントリは構造化されたフィールドを持ち、暗号学的ハッシュチェーン（gitに着想）で改ざんを検出できる。`journalctl`コマンドで高度なフィルタリングが可能だ。

だが、この設計はUNIXの根幹にある文化——テキスト文化——と正面から衝突する。

`/var/log/messages`をcatで読む。grepで特定のパターンを探す。awkで集計する。tail -fでリアルタイム監視する。sedで整形する。パイプで繋いで複雑なログ分析パイプラインを組み立てる。UNIXの管理者が日常的に行ってきたこれらの作業が、journaldのバイナリログでは直接的にはできなくなる。

`journalctl`は強力なツールだ。`journalctl -u httpd --since "1 hour ago" -p err`のようなコマンドで、高度なフィルタリングが一発でできる。だがそれは、UNIXの「小さなツールを組み合わせる」モデルを、「一つの高機能なツールに統合する」モデルで置き換えることに他ならない。

これは第7回で論じた「テキストストリーム」の原則への挑戦だ。テキストが「万能インタフェース」として機能してきたのは、あらゆるツールがテキストを読み書きできるからだ。バイナリログは、その万能性を放棄する代わりに、構造化と完全性を得る。トレードオフとして理解はできる。だが、UNIXの設計哲学からの逸脱であることは否定しがたい。

### Debianの分裂

systemd論争が最も激しく表面化したのは、2014年のDebian Technical Committee（技術委員会）の投票だ。

Debian 8 "jessie"のデフォルトinitシステムを何にするか——この問いを巡って、技術委員会は長い議論を重ねた。候補はsystemdとUpstart。複数回のCall for Votes（投票呼びかけ）が行われ、投票文言の修正が繰り返され、手続き上の混乱が続いた。

最終的に、systemdとUpstartの票数が同数となり、技術委員会議長のBdale Garbeeがcasting vote（決定票）でsystemdを選択した。

だが争いはここで終わらなかった。

Ian Jacksonは「loose coupling」を求める決議を提案した。「いかなるパッケージも、特定のinitシステムがPID 1として動いていることに依存してはならない」——つまり、systemdがデフォルトであっても、他のinitシステムでもDebianが動作することを保証する、という提案だ。この提案は否決された。Jacksonは技術委員を辞任した。同様にRuss AllberyとColin Watsonも辞任した。

2014年11月27日、「Veteran Unix Admins」を名乗るグループがDevuanプロジェクトを発表した。systemdフリーのDebianフォークだ。「Devuan」という名前はDebianとVUA（Veteran Unix Admins）のかばん語だ。最初の安定版Devuan 1.0 "Jessie"は2017年5月25日にリリースされ、2026年現在もアクティブに開発が続いている。

Debianという、25年以上の歴史を持つプロジェクトのコミュニティが、initシステムの選択を巡ってフォークにまで至った。この事実は、systemd論争が単なる技術的な意見の相違ではなく、ソフトウェアの設計哲学に関する根本的な対立だったことを示している。

### 採用の波

論争の激しさとは裏腹に、systemdの採用は急速に進んだ。

Fedora 15（2011年5月）が最初のメジャーディストリビューション採用だった。Arch LinuxとopenSUSEが2012年に続いた。RHEL 7（2014年6月）。Debian 8 jessie（2015年4月）。Ubuntu 15.04 vivid（2015年4月）。2015年以降、ほぼすべての主要Linuxディストリビューションがsystemdを採用した。

systemdを採用していない主要ディストリビューションは、Slackware、Gentoo（選択制）、Devuan、Alpine Linux（OpenRC使用）など、限定的だ。

この急速な普及は、systemdが技術的に問題を解決していたことの証左だ。ディストリビューションのメンテナたちは、思想的な純粋さよりも実用的なメリットを選んだ。起動の高速化、依存関係の自動解決、プロセスの確実な追跡、統一的なサービス管理インタフェース——これらの利点は、UNIX哲学との齟齬を補って余りあるものだった。

---

## 4. ハンズオン：SysV initとsystemdの設計を比較する

このハンズオンでは、SysV initスクリプトとsystemdユニットファイルを実際に比較し、systemdのジャーナルログ、cgroups管理、タイマー機能を体験する。従来のsyslog/cron/initスクリプトとの違いを肌で感じてほしい。

### 環境構築

```bash
# Ubuntu 24.04のDocker環境を使用
docker pull ubuntu:24.04
```

### 演習1：SysV initスクリプトの構造を理解する

SysV initスクリプトの「作法」を確認する。UNIXの伝統的なサービス管理がどのように行われていたかを知ることが、systemdの設計判断を理解する前提となる。

```bash
docker run --rm ubuntu:24.04 bash -c '
echo "=== SysV initスクリプトの基本構造 ==="
echo ""
echo "SysV initスクリプトは、以下の引数に対応するシェル関数を実装する:"
echo "  start   -- サービスを起動する"
echo "  stop    -- サービスを停止する"
echo "  restart -- サービスを再起動する"
echo "  status  -- サービスの状態を表示する"
echo ""

cat << "SYSV_SCRIPT"
#!/bin/bash
# /etc/init.d/myapp -- SysV initスクリプトの典型例

DAEMON=/usr/local/bin/myapp
PIDFILE=/var/run/myapp.pid
NAME=myapp

start() {
    echo -n "Starting $NAME: "
    if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        echo "already running"
        return 0
    fi
    $DAEMON --daemon --pidfile=$PIDFILE
    echo "done"
}

stop() {
    echo -n "Stopping $NAME: "
    if [ -f "$PIDFILE" ]; then
        kill $(cat "$PIDFILE")
        rm -f "$PIDFILE"
        echo "done"
    else
        echo "not running"
    fi
}

status() {
    if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        echo "$NAME is running (PID $(cat $PIDFILE))"
    else
        echo "$NAME is not running"
    fi
}

case "$1" in
    start)   start ;;
    stop)    stop ;;
    restart) stop; sleep 1; start ;;
    status)  status ;;
    *)       echo "Usage: $0 {start|stop|restart|status}" ;;
esac
SYSV_SCRIPT

echo ""
echo "=== この設計の問題点 ==="
echo "1. PIDファイルの競合状態: killとcatの間にプロセスが消える可能性"
echo "2. PIDの再利用: 古いPIDファイルが残り、別のプロセスをkillする危険"
echo "3. forkしたプロセスの追跡不能: デーモンが子プロセスを生成すると把握できない"
echo "4. 再起動の信頼性: stop→sleep→startの間にサービスが完全に停止していない可能性"
echo "5. 並列起動不可: このスクリプトを順番に実行するため、起動が遅い"
'
```

### 演習2：systemdユニットファイルの設計を理解する

systemdのユニットファイルが、SysV initスクリプトの問題をどう解決しているかを確認する。

```bash
docker run --rm --privileged ubuntu:24.04 bash -c '
echo "=== systemdのユニットファイル構造 ==="
echo ""

echo "--- 基本的なサービスユニットファイル ---"
cat << "UNIT_FILE"
[Unit]
Description=My Application Service
After=network.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/myapp --foreground
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
NoNewPrivileges=true

# リソース制限
MemoryMax=512M
CPUQuota=50%

[Install]
WantedBy=multi-user.target
UNIT_FILE

echo ""
echo "=== SysV initとの比較 ==="
echo ""
echo "SysV init                    systemd"
echo "──────────────────────────────────────────────"
echo "シェルスクリプト              宣言的INIファイル"
echo "PIDファイルで追跡             cgroupsで追跡"
echo "再起動は手動実装              Restart=on-failure"
echo "セキュリティ機能なし          PrivateTmp, ProtectSystem等"
echo "リソース制限なし              MemoryMax, CPUQuota等"
echo "逐次起動                     依存グラフによる並列起動"
echo "start/stop/restart/status    統一的なsystemctlコマンド"
echo ""

echo "=== 依存関係の種類 ==="
echo ""
echo "After=X    : Xの後に起動する（順序のみ、依存しない）"
echo "Before=X   : Xの前に起動する"
echo "Requires=X : Xが動いていなければ自分も起動しない（強い依存）"
echo "Wants=X    : Xがあれば起動するが、なくても自分は起動する（弱い依存）"
echo "Conflicts=X: Xと同時に動かない"
echo ""
echo "重要: AfterとRequiresは独立した概念である。"
echo "Requires=Xだけで After=Xがなければ、XとYは並列に起動する。"
echo "After=Xだけで Requires=Xがなければ、順序は保証されるが"
echo "Xが停止しても自分は停止しない。"
'
```

### 演習3：systemdの実際の動作を確認する

systemdが実際にどのように動いているかを、systemctlとjournalctlで確認する。

```bash
docker run --rm --privileged ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq systemd > /dev/null 2>&1

echo "=== PID 1の正体 ==="
cat /proc/1/comm 2>/dev/null || echo "(コンテナ内ではPID 1はコンテナランタイム)"
echo ""
ls -la /sbin/init 2>/dev/null
echo ""

echo "=== systemdのユニットタイプ一覧 ==="
echo "systemdは以下の種類のユニットを管理する:"
echo ""
echo ".service  -- サービス（デーモン）"
echo ".socket   -- ソケットアクティベーション"
echo ".target   -- ユニットのグループ化（ランレベルの代替）"
echo ".timer    -- タイマー（cronの代替）"
echo ".mount    -- マウントポイント"
echo ".automount -- 自動マウント"
echo ".device   -- デバイス"
echo ".path     -- パス監視"
echo ".slice    -- リソース管理グループ"
echo ".scope    -- 外部プロセスのグループ化"
echo ".swap     -- スワップ"
echo ""

echo "=== ターゲットとランレベルの対応 ==="
echo ""
echo "SysV ランレベル    systemd ターゲット"
echo "──────────────────────────────────────"
echo "0                  poweroff.target"
echo "1 (S)              rescue.target"
echo "2, 3, 4            multi-user.target"
echo "5                  graphical.target"
echo "6                  reboot.target"
echo ""

echo "=== systemd-analyze（起動時間の分析） ==="
echo "ホストシステムで実行する場合:"
echo "  systemd-analyze                   # 起動時間の概要"
echo "  systemd-analyze blame             # サービスごとの起動時間"
echo "  systemd-analyze critical-chain    # クリティカルパスの表示"
echo "  systemd-analyze plot > boot.svg   # 起動タイムラインのSVG出力"
'
```

### 演習4：journalctlとsyslogの比較

journaldのバイナリログとsyslogのテキストログの違いを体験する。

```bash
docker run --rm ubuntu:24.04 bash -c '
echo "=== journalctlの基本的な使い方 ==="
echo ""
echo "# すべてのログを表示"
echo "journalctl"
echo ""
echo "# 特定のサービスのログ"
echo "journalctl -u httpd.service"
echo ""
echo "# 時間範囲を指定"
echo "journalctl --since \"2024-01-01 00:00:00\" --until \"2024-01-01 23:59:59\""
echo ""
echo "# 重要度でフィルタ（0:emerg〜7:debug）"
echo "journalctl -p err    # errレベル以上"
echo ""
echo "# カーネルメッセージ"
echo "journalctl -k"
echo ""
echo "# リアルタイム監視（tail -f相当）"
echo "journalctl -f"
echo ""
echo "# JSON形式で出力"
echo "journalctl -o json-pretty -n 1"
echo ""

echo "=== syslog vs journald 設計比較 ==="
echo ""
echo "特性              syslog (テキスト)          journald (バイナリ)"
echo "──────────────────────────────────────────────────────────────────"
echo "保存形式          プレーンテキスト           構造化バイナリ"
echo "閲覧方法          cat, less, grep, awk       journalctl"
echo "パイプ連携        直接可能                   journalctl出力経由"
echo "構造化クエリ      grep + awk（アドホック）    組み込みフィルタ"
echo "改ざん検出        なし                       暗号学的ハッシュチェーン"
echo "ディスク効率      非圧縮（ローテーション）  自動圧縮"
echo "アクセス制御      ファイルパーミッション     ユーザ別アクセス制御"
echo "バイナリデータ    不可                       可能"
echo ""

echo "=== journalctlの出力をUNIXツールで処理する ==="
echo "journaldのログもパイプに渡すことは可能:"
echo ""
echo "# grepでフィルタ"
echo "journalctl -u httpd --no-pager | grep \"error\""
echo ""
echo "# awkで集計"
echo "journalctl --output=short-unix --no-pager | awk \"{ print \\$1 }\" | sort | uniq -c"
echo ""
echo "# JSON出力をjqで処理"
echo "journalctl -o json --no-pager | jq \".MESSAGE\""
echo ""
echo "→ テキストパイプラインとの連携は可能だが、一段の変換が必要"
'
```

### 演習5：systemd timerとcronの比較

systemdのタイマーユニットがcronを置き換える方法を確認する。

```bash
docker run --rm ubuntu:24.04 bash -c '
echo "=== crontabエントリの例 ==="
echo ""
echo "# 毎日午前3時にバックアップを実行"
echo "0 3 * * * /usr/local/bin/backup.sh"
echo ""

echo "=== 同等のsystemd timer ==="
echo ""
echo "--- /etc/systemd/system/backup.service ---"
cat << "SERVICE"
[Unit]
Description=Daily Backup

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
Nice=19
IOSchedulingClass=idle
SERVICE
echo ""

echo "--- /etc/systemd/system/backup.timer ---"
cat << "TIMER"
[Unit]
Description=Daily Backup Timer

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
TIMER
echo ""

echo "=== systemd timerの利点 ==="
echo "1. Persistent=true: システムが停止中に実行されるべきだったタスクを"
echo "   次回起動時に実行する（cronにはこの機能がない）"
echo "2. RandomizedDelaySec: 実行時間をランダムに分散させ、サーバ群の"
echo "   同時実行による負荷集中を防ぐ"
echo "3. リソース制限: Nice=, IOSchedulingClass= でプロセスの優先度を制御"
echo "4. ログ統合: 実行結果がjournalに記録される"
echo "5. 依存関係: After=, Requires= でサービス依存を宣言できる"
echo ""
echo "=== cronの利点 ==="
echo "1. シンプル: 1行で完結する"
echo "2. 可搬性: POSIXで定義されており、あらゆるUNIX系OSで動作する"
echo "3. テキスト: crontabの内容をcatで読み、grepで探せる"
'
```

systemd timerが`Persistent=true`で「電源断時の実行漏れ」を自動補完する機能に注目してほしい。cronにはこの機能がない。anacronという補助ツールで部分的に対応していたが、それ自体がcronの設計不足を補うアドホックな追加だった。SysV init時代は、initの不足を外部ツールで補い、cronの不足をanacronで補い、syslogの不足をlogrotateで補う——そうした「ツールのツール」の積み重ねが運用の複雑さを生んでいた。systemdはそれらを統合することで複雑さを減らした、とも言える。だが統合することで新たな複雑さを生んだ、とも言える。

---

## 5. まとめと次回予告

### この回の要点

systemd論争は、UNIX哲学の解釈を巡る根本的な対立だ。

SysV init（1983年〜）はシェルスクリプトベースの逐次起動モデルであり、UNIXの「テキストは万能インタフェース」「すべてはファイルである」という原則に忠実だった。だが逐次起動、暗黙的な依存関係、プロセス追跡の不在という根本的な限界を抱えていた。Upstart（2006年、Scott James Remnant、Canonical）がイベント駆動型の設計で最初の改革を試みたが、systemd（2010年、Lennart Poettering、Kay Sievers、Red Hat）がより包括的な解決策として急速に普及した。

systemdの技術的な設計判断——並列起動、ソケットアクティベーション、cgroups統合、宣言的ユニットファイル——は、SysV initの具体的な問題に対する具体的な解決策として合理的だ。起動時間の短縮、依存関係の明示的な管理、プロセスの確実な追跡とリソース制限。これらは実用的な改善であり、ほぼすべての主要ディストリビューションがsystemdを採用した事実がその評価を裏付けている。

しかし、systemdの「範囲拡大」はUNIX哲学との根本的な緊張を生み出した。2013年時点で69の個別バイナリを含むスイートに成長し、init、ログ、ネットワーク管理、DNS解決、タイマー、コンテナ管理にまで範囲を広げた。journaldのバイナリログは、UNIXの「テキスト文化」との明確な断絶だ。Debianの技術委員会投票（2014年2月）はコミュニティを分裂させ、Devuanフォーク（2014年11月発表）を生み出した。

Poetteringの反論にも一理ある。systemdは69の独立したバイナリの集合体であり、各コンポーネントは個別の責務を持つ。問題は、「一つのこと」の粒度をどこに置くかという解釈の違いだ。個々のバイナリのレベルで見れば、systemdは「一つのことをうまくやれ」に従っている。プロジェクト全体のレベルで見れば、かつて独立していたツール群を一つの傘の下に統合している。

### 冒頭の問いへの暫定回答

「systemdはUNIXの設計哲学への裏切りなのか、それとも正当な進化なのか。」

私の暫定的な答えはこうだ——systemdはUNIX哲学の「原則」には反しているが、UNIX哲学の「精神」には沿っている面がある。

UNIX哲学の「原則」は明確だ。「一つのことをうまくやれ」「テキストを共通のインタフェースにせよ」「小さなツールを組み合わせよ」。systemdはこれらの原則に対して緊張関係にある。

だがUNIX哲学の「精神」には、もう一つの側面がある。「制約の中で最善の設計を追求する」という態度だ。PDP-7のメモリ制約がUNIXのシンプルさを生んだように、SysV initの限界がsystemdの設計を駆動した。マルチコアCPU、大規模サービス、高速起動の要求——2010年代の制約に対する、一つの解答としてsystemdは設計された。

問題は、その解答が「唯一の」解答として強制されたことだ。SysV init時代のLinuxでは、init、syslog、cron、ネットワーク設定はそれぞれ独立したツールであり、管理者は組み合わせを選択できた。systemdの世界では、これらが一つのプロジェクトに統合され、組み合わせの自由度が下がった。UNIX哲学の価値の一つは「選択の自由」にあったはずだ。

答えは単純ではない。だがこの論争が存在すること自体が、UNIX哲学の影響力の証明だ。1969年のPDP-7で生まれた設計原則が、50年以上経った2010年代のLinuxのinit設計を巡る議論の判断基準として機能している。systemdの設計者も批判者も、UNIX哲学を参照枠として使っている。その点において、UNIX哲学は死んでいない。

### 次回予告

次回は「Plan 9——UNIXの先を夢見た実験」。UNIXの設計者自身が「UNIXの次」として作ったOSの話だ。Rob Pike、Ken Thompson、Dave Presotto——Bell LabsでUNIXを作った人々が、UNIXの限界を認識し、その先を目指した。「Everything is a file」をUNIXよりも徹底し、ネットワーク、ウィンドウシステム、さらにはプロセスまでファイルシステムとして扱う。9Pプロトコル、per-process名前空間、ユニオンマウント——これらの概念は商業的には「失敗」したが、UTF-8、FUSE、Linuxのnamespace機能として形を変えて生き残っている。

Plan 9は「正しすぎたOS」だったのか。UNIXの後継が普及しなかった理由は何か。そして、Plan 9のアイデアが現代のLinuxにどう流入しているのか。

あなたが使っているLinuxのnamespace機能——Dockerのコンテナ分離を支える基盤技術——の設計思想が、1990年代のBell Labsの実験的OSに遡ることを、知っているだろうか。

---

## 参考文献

- Lennart Poettering, "Rethinking PID 1", 2010年4月30日: <https://0pointer.de/blog/projects/systemd.html>
- Lennart Poettering, "The Biggest Myths", 2013年1月26日: <http://0pointer.de/blog/projects/the-biggest-myths.html>
- Wikipedia, "systemd": <https://en.wikipedia.org/wiki/Systemd>
- Wikipedia, "init": <https://en.wikipedia.org/wiki/Init>
- Wikipedia, "UNIX System V": <https://en.wikipedia.org/wiki/UNIX_System_V>
- Wikipedia, "Upstart (software)": <https://en.wikipedia.org/wiki/Upstart_(software)>
- Wikipedia, "Devuan": <https://en.wikipedia.org/wiki/Devuan>
- Devuan Project, "Announcement of the Debian Fork", 2014年11月27日: <https://www.devuan.org/os/announce/>
- LWN.net, "Debian decides on systemd—for now", 2014年2月: <https://lwn.net/Articles/585319/>
- LWN.net, "The Journal - a proposed syslog replacement", 2011年: <https://lwn.net/Articles/468049/>
- LWN.net, "14 years of systemd": <https://lwn.net/Articles/1008721/>
- LWN.net, "Poettering: Rethinking PID 1": <https://lwn.net/Articles/385536/>
- LWN.net, "Poettering: The Biggest Myths": <https://lwn.net/Articles/534210/>
- Debian General Resolution, "init system coupling": <https://www.debian.org/vote/2014/vote_003>
- PCWorld, "Meet Devuan, the Debian fork born from a bitter systemd revolt": <https://www.pcworld.com/article/436680/meet-devuan-the-debian-fork-born-from-a-bitter-systemd-revolt.html>
- Red Hat Documentation, "SysV Init Runlevels": <https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/4/html/reference_guide/s1-boot-init-shutdown-sysv>
- Red Hat Documentation, "Working with systemd unit files": <https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_systemd_unit_files_to_customize_and_optimize_your_system/assembly_working-with-systemd-unit-files_working-with-systemd>
- freedesktop.org, "systemd.service": <https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html>
- systemd.io, "Control Group APIs and Delegation": <https://systemd.io/CGROUP_DELEGATION/>
- Red Hat Blog, "Managing cgroups with systemd": <https://www.redhat.com/en/blog/cgroups-part-four>
- Wikipedia, "Unix philosophy" (Patrick Volkerding引用): <https://en.wikipedia.org/wiki/Unix_philosophy>
