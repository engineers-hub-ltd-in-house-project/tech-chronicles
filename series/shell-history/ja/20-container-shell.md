# 第20回：コンテナ時代のシェル――Docker, CI/CD, そして/bin/sh問題

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- Docker（2013年）の登場がシェルに与えた構造的な影響――「シェルが常に存在する」前提の崩壊
- Alpine LinuxとBusyBox ash――5MBの軽量イメージが突きつけた「bashは当たり前ではない」という現実
- Dockerfileのshell form vs exec form――`/bin/sh -c`を経由するか否かがPID 1とシグナルハンドリングを左右する
- SHELL命令（Docker 1.12, 2016年）――Dockerfileのデフォルトシェルを制御する手段
- マルチステージビルド（Docker 17.05, 2017年）とシェルの関係――ビルド環境とランタイム環境の分離
- distrolessとscratchイメージ――シェルが存在しないコンテナという選択肢
- CI/CDパイプラインにおけるシェル依存のリスク――GitHub ActionsとGitLab CIのデフォルト挙動の違い
- Kubernetes Ephemeral Containers（v1.25 GA, 2022年）――シェルなきコンテナのデバッグ手法

---

## 1. 導入――bashが存在しないコンテナに出会った日

私がDockerに初めて本格的に触れたのは2014年のことだ。

当時、私はインフラの自動化に日々取り組んでいた。数百行のbashデプロイスクリプトを書き、テスト環境の構築を自動化し、本番環境の設定管理に奔走していた。Dockerが2013年3月にSolomon Hykesの手でPyCon 2013の場で公開されたとき、私はその動画を見て「これは面白い」とは思ったが、すぐに本番で使おうとは考えなかった。

状況が変わったのは2015年頃だ。Docker Hub上で公式イメージが充実し始め、チームでの開発環境統一にDockerを導入することになった。最初はUbuntuベースのイメージを使い、いつも通りbashでスクリプトを書いていた。何の問題もなかった。

転機は、Alpine Linuxベースのイメージに切り替えたときに訪れた。

あるとき、CI環境で動かしていたシェルスクリプトが突然失敗した。エラーメッセージを見て、私は目を疑った。`/bin/bash: not found`。Alpine LinuxのDockerイメージには、bashが存在しなかったのだ。

5MB。Alpine Linuxの公式Dockerイメージはわずか5MBだった。この軽量さを実現するために、Alpine Linuxはbashではなく、BusyBox版のash（Almquist shell）を`/bin/sh`として採用していた。第12回で見たash——Kenneth Almquistが1989年にcomp.sources.unixに投稿した、あの軽量POSIXシェルの系譜だ。

私は慌ててスクリプトを修正した。bashの配列構文を使っていた箇所、`[[ ]]`による条件判定、`${variable//pattern/replacement}`によるパラメータ展開。これらはすべてbash拡張であり、POSIX shでは動かない。第11回で語った「POSIX準拠」の話が、ここで現実の問題として突きつけられた。

あなたは、自分が書いたシェルスクリプトがPOSIX準拠かどうか、即座に答えられるだろうか。

コンテナ時代が到来して、シェルの世界には根本的な変化が起きた。それは「シェルが当たり前に存在する」という前提の崩壊だ。bashどころか、シェルそのものが存在しないコンテナすらある。この回では、Dockerの登場からdistrolessイメージ、CI/CDパイプライン、Kubernetesのデバッグまで、コンテナがシェルに突きつけた問いを掘り下げる。

---

## 2. 歴史的背景――Dockerの登場とシェルの関係

### Dockerが変えたもの（2013年）

2013年3月13日、Solomon HykesがPyCon 2013のライトニングトークで披露したデモは、わずか5分だった。だが、あの5分がソフトウェアの配布と実行の方法を不可逆に変えた。

Docker以前、アプリケーションのデプロイは「環境構築」と不可分だった。Rubyのバージョン、ライブラリの依存関係、設定ファイルのパス、OSのパッケージ。これらを揃えるために、私たちはシェルスクリプトを書いた。数百行、ときには千行を超えるbashスクリプトで、パッケージのインストール、設定ファイルの配置、サービスの起動を自動化していた。

Dockerは、この問題を「イメージ」という概念で解決した。アプリケーションとその依存関係を一つのイメージにパッケージし、どの環境でも同じように実行できる。「私のマシンでは動くのに」という悪夢からの解放だ。

だが、Dockerの登場は同時に、シェルに対する根本的な問いを突きつけた。

コンテナイメージの設計思想は「最小主義」である。実行に必要なものだけを含め、不要なものは削る。この原則に従うと、シェルの立場は揺らぐ。アプリケーションの実行にbashは必要か。`/bin/sh`は必要か。答えは「必ずしも」だ。

### Alpine Linuxの台頭――5MBの衝撃

Dockerエコシステムにおいてこの「最小主義」を体現したのが、Alpine Linuxだ。

Alpine Linuxは、2005年頃にNatanael Copaが創設した軽量Linuxディストリビューションである。元はGentoo Linuxベースの組み込み向けOSとして出発した。2014年にCライブラリをuClibcからmuslに切り替え、軽量かつPOSIX準拠の基盤を確立した。

Alpine LinuxがDockerの世界で注目されたのは、そのイメージサイズだ。Debian系のイメージが100MB超、Ubuntuが70MB前後だった時代に、Alpine Linuxの公式Dockerイメージはわずか5MB。この圧倒的な差が、CI/CDパイプラインの高速化やコンテナレジストリのストレージ節約を求める開発者を引きつけた。Docker Hub上で10億回以上ダウンロードされている実績が、その支持の広さを物語る。

Alpine Linuxが5MBを実現できた理由の一つが、BusyBoxの採用だ。BusyBoxは1990年代半ばに生まれた、一つの実行ファイルに数百のUnixユーティリティを詰め込んだプロジェクトである。ls、grep、sed、awk、そしてsh——これらすべてが一つのバイナリに含まれる。Alpine Linuxの`/bin/sh`はBusyBox版のash、つまりKenneth Almquistが1989年に書いたAlmquist shellの系譜を受け継ぐ軽量POSIXシェルだ。

ashはPOSIX準拠であるが、bashではない。bashの配列、`[[ ]]`、プロセス置換（`<(command)`）、`${var//old/new}`によるパターン置換——これらは一切使えない。Debian系でashの派生であるdashを`/bin/sh`に採用した話は第12回で見た。Alpine Linuxでは、同じ系統のBusyBox ashが`/bin/sh`を担っている。

この事実は、「bashで書けば動く」という暗黙の前提を粉砕した。

### scratchとdistroless――シェルが存在しない世界

Alpine Linuxの5MBは十分に小さいが、さらに極端な選択肢が存在する。

Dockerのscratchイメージは、文字通り「何もない」イメージだ。ファイルシステムにファイルは一つもなく、シェルもライブラリも存在しない。Go言語のように静的リンクされたバイナリを単体で実行する場合、scratchイメージの上にバイナリを置くだけでコンテナが成立する。

2017年頃、Googleはdistrolessイメージを公開した。これはscratchよりは実用的で、アプリケーションの実行に必要な最低限のシステムファイル（CA証明書、タイムゾーン情報、基本的なライブラリ）を含むが、パッケージマネージャもシェルも含まない。`gcr.io/distroless/static-debian12`のサイズは約2MiBで、Alpine（約5MiB）の半分以下である。

distrolessの思想は明確だ。「シェルが存在しなければ、シェルを通じた攻撃は不可能になる」。2014年のShellshock脆弱性（CVE-2014-6271）は、bashの環境変数処理に起因する深刻なリモートコード実行脆弱性だった。GNU Bash 1.14から4.3までが影響を受け、CGIスクリプトやOpenSSHのForceCommand経由で攻撃可能だった。この脆弱性は、シェルをコンテナに含めること自体がセキュリティリスクであることを突きつけた。

コンテナの「最小主義」は、セキュリティの観点からも合理的だったのだ。

---

## 3. 技術論――Dockerfileとシェルの深い関係

### shell form vs exec form

Dockerfileを書いたことのあるエンジニアなら、`RUN`、`CMD`、`ENTRYPOINT`命令を使ったことがあるだろう。だが、これらの命令には二つの形式があり、その違いがシェルの動作と直結していることを明確に理解している人は少ない。

**shell form**は、コマンドを文字列として記述する形式だ。

```dockerfile
RUN apt-get update && apt-get install -y curl
CMD echo "Hello, World"
ENTRYPOINT /app/server --port 8080
```

この場合、Dockerはコマンドを`/bin/sh -c "apt-get update && apt-get install -y curl"`のように実行する。つまり、`/bin/sh`が起動され、`-c`オプションでコマンド文字列が渡される。シェルの機能——変数展開、パイプ、リダイレクト、`&&`による連鎖——がすべて使える。

**exec form**は、JSON配列としてコマンドを記述する形式だ。

```dockerfile
RUN ["apt-get", "update"]
CMD ["echo", "Hello, World"]
ENTRYPOINT ["/app/server", "--port", "8080"]
```

この場合、Dockerはシェルを介さず、直接`execve`システムコールでプロセスを起動する。変数展開もパイプもリダイレクトも使えない。その代わり、プロセスがコンテナ内のPID 1として直接起動される。

この「PID 1」の違いが、実は決定的に重要だ。

### PID 1問題とシグナルハンドリング

Linuxカーネルは、PID 1のプロセスを特別扱いする。通常のプロセスがシグナルハンドラを登録していない場合、カーネルはデフォルトの動作（SIGTERMならプロセス終了）を実行する。だが、PID 1に対しては、ハンドラが登録されていないシグナルは無視される。

shell formでCMDやENTRYPOINTを指定した場合、PID 1は`/bin/sh -c`であり、実際のアプリケーションプロセスはその子プロセスとなる。`docker stop`が送信するSIGTERMは、PID 1である`/bin/sh`に到達するが、`/bin/sh`は子プロセスにシグナルを転送しない。結果として、アプリケーションはSIGTERMを受信できず、10秒のタイムアウト後にSIGKILLで強制終了される。

```
shell form の場合:
  PID 1: /bin/sh -c "/app/server --port 8080"
    PID 2: /app/server --port 8080  ← SIGTERMが届かない

exec form の場合:
  PID 1: /app/server --port 8080    ← SIGTERMを直接受信
```

この問題に対処するため、tini（krallin/tini）やdumb-init（Yelp製、2016年1月公開）といった軽量initプロセスが開発された。これらはPID 1として動作し、シグナルの転送とゾンビプロセスの回収を行う。Dockerは2017年1月のバージョン1.13でtiniを内蔵し、`docker run --init`フラグで利用可能とした。

だが、そもそもexec formを使えば、この問題は発生しない。shell formの便利さとexec formの正確さ。このトレードオフは、シェルの「便利だが暗黙的」という性質そのものを映し出している。

### SHELL命令――デフォルトシェルの制御

2016年のDocker 1.12で、SHELL命令が導入された。

```dockerfile
SHELL ["/bin/bash", "-c"]
RUN echo "Now using bash"
```

SHELL命令は、shell formのRUN、CMD、ENTRYPOINTで使用されるデフォルトシェルを変更する。Linuxにおけるデフォルトは`["/bin/sh", "-c"]`だ。

この命令の導入背景には、Windows環境での需要があった。Windows上のDockerでは、cmdとPowerShellという二つの異なるシェルがあり、Dockerfile内でシェルを切り替える手段が必要だった。だが、Linux環境でも意味がある。Alpine Linuxのashではなくbashを使いたい場合や、エラー時の挙動を`set -euo pipefail`で制御したい場合だ。

```dockerfile
FROM ubuntu:24.04
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -fsSL https://example.com/install.sh | bash
```

この例では、`pipefail`オプションにより、パイプの途中でエラーが発生しても検出できる。`/bin/sh -c`のデフォルトでは、パイプの最後のコマンドの終了コードしか見ないため、`curl`が失敗しても`bash`が成功すればエラーにならない。

### マルチステージビルドとシェルの分離

2017年5月のDocker 17.05で導入されたマルチステージビルドは、「ビルド環境」と「実行環境」を明確に分離する手段を提供した。

```dockerfile
# ビルドステージ: bashもgccもmakeも使える
FROM ubuntu:24.04 AS builder
RUN apt-get update && apt-get install -y gcc make
COPY . /src
RUN cd /src && make

# 実行ステージ: 最小限のイメージ
FROM alpine:3.21
COPY --from=builder /src/myapp /usr/local/bin/myapp
CMD ["/usr/local/bin/myapp"]
```

ビルドステージでは、bashを含むフルのLinuxディストリビューションを使い、自由にシェルスクリプトを実行できる。だが、最終的な実行イメージにはbashを含める必要がない。ビルド成果物だけをコピーすればよい。

Go言語では、この思想がさらに徹底される。

```dockerfile
FROM golang:1.23 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o /server .

FROM scratch
COPY --from=builder /server /server
ENTRYPOINT ["/server"]
```

最終イメージはscratchベースであり、シェルは存在しない。バイナリがPID 1として直接起動される。イメージサイズは数MBに収まる。

マルチステージビルドは、シェルの役割を「ビルド時のツール」に限定し、「実行時のシェル」を不要にした。これは、シェルの歴史における重要な転換点だ。

### CI/CDパイプラインのシェル依存

コンテナ時代のもう一つの戦場が、CI/CDパイプラインだ。

GitHub Actionsのデフォルトシェルは`/bin/bash --noprofile --norc -eo pipefail`である。`-e`で任意のコマンドがエラーを返した時点でスクリプト全体が失敗し、`-o pipefail`でパイプの途中のエラーも検出する。堅実な設定だ。

だが、ここに落とし穴がある。GitHub Actionsでコンテナジョブを使う場合——つまり、`container:`キーワードでDockerコンテナ内でジョブを実行する場合——デフォルトシェルは`sh`に切り替わる。bashではない。

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container: alpine:3.21
    steps:
      - run: echo "This runs in /bin/sh, not bash"
```

このAlpine Linuxコンテナ内の`/bin/sh`はBusyBox ashだ。bash拡張を使ったスクリプトは、ここで失敗する。

GitLab CIも同様の構造を持つ。Dockerエグゼキューターのデフォルトシェルはsh/bashだが、コンテナイメージによって実際に利用可能なシェルが変わる。Alpine LinuxベースのDockerイメージを使えば、`/bin/sh`はashとなる。

CI/CDパイプラインは、シェルスクリプトが「どのシェルで実行されるか」を明示的に制御しなければ、環境依存の罠にはまる。POSIX準拠のスクリプトを書くか、明示的にbashをインストールして指定するか。この選択は、第11回で語ったPOSIX標準化の問題と地続きである。

---

## 4. ハンズオン――コンテナ環境でシェルの違いを体験する

このハンズオンでは、Docker環境で以下を体験する。

1. Alpine（ash）、Debian（bash）、scratch（シェルなし）の違い
2. shell form vs exec formの挙動差
3. PID 1問題の実証
4. CI/CDパイプラインのPOSIX準拠スクリプト化

### 前提条件

- Docker（Docker Engine 20.10以降推奨）がインストールされていること
- 付属の`setup.sh`を実行するか、以下のコマンドを手動で実行する

### 演習1: 同じスクリプトを異なるシェルで実行する

以下のスクリプト`test.sh`は、bashの機能とPOSIX shの機能を混在させて書かれている。

```bash
#!/bin/sh

echo "=== シェル環境の確認 ==="
echo "Shell: $0"
echo "sh -> $(readlink -f /bin/sh 2>/dev/null || echo 'readlink unavailable')"

# POSIX互換: これは動く
name="world"
echo "Hello, ${name}"

# bash拡張: [[ ]] による条件判定
if [[ "$name" == "world" ]]; then
  echo "[[ ]] test: OK (bash extension)"
fi

# bash拡張: 配列
arr=(one two three)
echo "Array: ${arr[1]}"

# bash拡張: パラメータ展開
text="hello-world"
echo "Pattern substitution: ${text//-/_}"
```

これをAlpineとDebianで実行する。

```bash
# Debian (bash) で実行
docker run --rm -i debian:bookworm sh -c '
cat > /tmp/test.sh << '\''SCRIPT'\''
#!/bin/sh
echo "=== Shell: $(readlink -f /bin/sh) ==="
name="world"
echo "Hello, ${name}"
if [[ "$name" == "world" ]]; then
  echo "[[ ]] test: OK"
fi
arr=(one two three)
echo "Array: ${arr[1]}"
text="hello-world"
echo "Pattern: ${text//-/_}"
SCRIPT
echo "--- /bin/sh ---"
sh /tmp/test.sh
echo ""
echo "--- /bin/bash ---"
bash /tmp/test.sh
'

# Alpine (ash) で実行
docker run --rm -i alpine:3.21 sh -c '
cat > /tmp/test.sh << '\''SCRIPT'\''
#!/bin/sh
echo "=== Shell: $(readlink -f /bin/sh) ==="
name="world"
echo "Hello, ${name}"
if [[ "$name" == "world" ]]; then
  echo "[[ ]] test: OK"
fi
arr=(one two three)
echo "Array: ${arr[1]}"
text="hello-world"
echo "Pattern: ${text//-/_}"
SCRIPT
echo "--- /bin/sh (BusyBox ash) ---"
sh /tmp/test.sh
echo ""
echo "--- /bin/bash ---"
bash /tmp/test.sh 2>&1 || echo "bash: not found (Alpine has no bash)"
'
```

Debianの`/bin/sh`はdash（第12回で見た、ashのDebian版）であり、`/bin/bash`は別途インストールされている。Alpineの`/bin/sh`はBusyBox ashであり、bashは存在しない。`[[ ]]`、配列、パターン置換はいずれもbash拡張であり、ashやdashでは構文エラーとなる。

### 演習2: shell form vs exec formのPID 1を確認する

```bash
# shell form: /bin/sh -c 経由で起動
docker run --rm --name shell-form -d alpine:3.21 \
  sh -c "sleep 3600"

echo "--- shell form のプロセスツリー ---"
docker exec shell-form ps aux
docker stop shell-form

# exec form: 直接起動
docker run --rm --name exec-form -d alpine:3.21 \
  sleep 3600

echo "--- exec form のプロセスツリー ---"
docker exec exec-form ps aux
docker stop exec-form
```

shell formでは`ps aux`の出力にPID 1として`sh -c sleep 3600`が表示され、`sleep`はPID 2以降になる。exec formでは`sleep`がPID 1として直接表示される。

### 演習3: Dockerfile shell form vs exec formの挙動差

以下のDockerfileで、シグナルハンドリングの違いを確認する。

```dockerfile
# Dockerfile.shell-form
FROM alpine:3.21
RUN apk add --no-cache python3
COPY <<'EOF' /app/server.py
import signal, sys, time

def handler(signum, frame):
    print(f"Received signal {signum}, shutting down gracefully...", flush=True)
    sys.exit(0)

signal.signal(signal.SIGTERM, handler)
print("Server started (PID: {})".format(__import__('os').getpid()), flush=True)
while True:
    time.sleep(1)
EOF
# shell form: /bin/sh -c 経由
CMD python3 /app/server.py
```

```dockerfile
# Dockerfile.exec-form
FROM alpine:3.21
RUN apk add --no-cache python3
COPY <<'EOF' /app/server.py
import signal, sys, time

def handler(signum, frame):
    print(f"Received signal {signum}, shutting down gracefully...", flush=True)
    sys.exit(0)

signal.signal(signal.SIGTERM, handler)
print("Server started (PID: {})".format(__import__('os').getpid()), flush=True)
while True:
    time.sleep(1)
EOF
# exec form: 直接起動
CMD ["python3", "/app/server.py"]
```

```bash
# ビルドと実行
docker build -f Dockerfile.shell-form -t test-shell-form .
docker build -f Dockerfile.exec-form -t test-exec-form .

# shell form: SIGTERMが届かない
echo "--- shell form でdocker stop ---"
docker run --rm -d --name test-sf test-shell-form
sleep 2
time docker stop test-sf
# → 約10秒かかる（SIGTERMが無視され、SIGKILLで強制終了）

# exec form: SIGTERMが正しく処理される
echo "--- exec form でdocker stop ---"
docker run --rm -d --name test-ef test-exec-form
sleep 2
time docker stop test-ef
# → 即座に終了（SIGTERMを受信してgraceful shutdown）
```

shell formでは`docker stop`に約10秒かかる。これは、SIGTERMが`/bin/sh`で止まり、Pythonプロセスに到達しないためだ。10秒のタイムアウト後にSIGKILLで強制終了される。exec formでは、PythonプロセスがPID 1として直接SIGTERMを受信し、`handler`関数が呼ばれて即座にgraceful shutdownが実行される。

### 演習4: POSIX準拠スクリプトへの書き換え

bash拡張を使ったスクリプトをPOSIX sh互換に書き換える演習だ。

```bash
# === Before: bash依存のスクリプト ===
cat << 'BASH_SCRIPT'
#!/bin/bash
# bash拡張に依存
declare -a services=("web" "api" "worker")

for svc in "${services[@]}"; do
  if [[ "$svc" == "web" ]]; then
    port=80
  elif [[ "$svc" == "api" ]]; then
    port=8080
  else
    port=9090
  fi

  status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${port}/health")
  if [[ "$status" == "200" ]]; then
    echo "${svc}: healthy"
  else
    echo "${svc}: unhealthy (HTTP ${status})"
  fi
done
BASH_SCRIPT

echo "---"

# === After: POSIX sh互換のスクリプト ===
cat << 'POSIX_SCRIPT'
#!/bin/sh
# POSIX sh互換 — Alpine (ash), Debian (dash) で動作
services="web api worker"

for svc in $services; do
  case "$svc" in
    web)    port=80 ;;
    api)    port=8080 ;;
    *)      port=9090 ;;
  esac

  status=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${port}/health")
  if [ "$status" = "200" ]; then
    echo "${svc}: healthy"
  else
    echo "${svc}: unhealthy (HTTP ${status})"
  fi
done
POSIX_SCRIPT
```

変更点は以下の通りだ。

- `declare -a`による配列をスペース区切りの文字列に変更
- `"${services[@]}"`の展開を`$services`のワードスプリッティングに変更
- `[[ ]]`を`[ ]`（test命令）に変更
- `==`を`=`に変更（POSIX testでは`=`が文字列比較）
- `if-elif-else`のパターンマッチを`case`文に変更

これらの変更は機械的に行える。だが、重要なのは「最初からPOSIX shで書く習慣を持つこと」だ。コンテナ環境でスクリプトが動くことを前提にするなら、bash拡張に依存しないことが、移植性の担保となる。

---

## 5. まとめと次回予告

### この回のまとめ

コンテナ時代は、シェルの存在を「当たり前」から「選択」に変えた。

Docker（2013年）の登場は、アプリケーションのパッケージングと配布を革新すると同時に、シェルに対して「お前は本当に必要なのか」という問いを突きつけた。Alpine Linux（5MB、BusyBox ash）はbashが存在しない世界を日常にし、distrolessとscratchイメージはシェルそのものを排除した。

Dockerfileのshell formとexec formの違いは、「`/bin/sh -c`を経由するか否か」という一見些細な差でありながら、PID 1のシグナルハンドリング、graceful shutdown、ゾンビプロセスの回収という本質的な問題に直結する。SHELL命令（Docker 1.12, 2016年）はデフォルトシェルの制御を可能にし、マルチステージビルド（Docker 17.05, 2017年）はビルド時と実行時のシェルの役割を明確に分離した。

CI/CDパイプラインでは、GitHub Actionsのコンテナジョブでデフォルトシェルがbashからshに切り替わるという落とし穴があり、POSIX準拠のスクリプトを書くことの重要性が改めて浮き彫りになっている。

そして、Kubernetesの世界では、シェルを持たないコンテナのデバッグ手法としてEphemeral Containers（2022年、v1.25でGA）が確立され、「シェルがなくてもコンテナは運用できる」という方向性が公式にサポートされた。

冒頭の問いに戻ろう。コンテナ環境でシェルはどう変わったのか。答えは明確だ——シェルは「常にそこにある前提」から「必要に応じて選択するもの」に変わった。そして、シェルを選択するなら、POSIX準拠のsh互換スクリプトを書けることが、コンテナ時代の基本的なリテラシーとなっている。

### 次回予告

コンテナ時代は「bashが当たり前ではない」ことを突きつけた。だが、次に来る波はさらに根本的な問いを投げかける。

テキストストリーム。パイプ。`|`で繋がれたコマンドの連鎖。これがUnixシェルの根幹であり、第6回で語った「パイプとUNIX哲学」の核心だ。だが、2016年頃から、この根幹そのものを問い直すシェルが登場し始めた。

Nushell——パイプラインを流れるのはテキストではなく、構造化されたテーブルデータだ。Oil Shell / Oils——bashと互換性を保ちながら、言語としてのシェルを再設計する野心的な試み。Elvish——名前空間と例外処理を持つシェル。

次回のテーマは「次世代シェルの挑戦――Nushell、Oil/YSH、Elvish、その先へ」だ。テキストストリームの限界とPOSIX互換性の呪縛に、異なるアプローチで挑む次世代シェルたちの物語を追う。

---

## 参考文献

- Docker, Inc., "11 Years of Docker: Shaping the Next Decade of Development", 2024年 <https://www.docker.com/blog/docker-11-year-anniversary/>
- Wikipedia, "Docker (software)" <https://en.wikipedia.org/wiki/Docker_(software)>
- Wikipedia, "Alpine Linux" <https://en.wikipedia.org/wiki/Alpine_Linux>
- Docker Hub, "alpine" 公式イメージ <https://hub.docker.com/_/alpine>
- Wikipedia, "Almquist shell" <https://en.wikipedia.org/wiki/Almquist_shell>
- Baeldung, "Difference Between BusyBox and Alpine Docker Images" <https://www.baeldung.com/linux/busybox-vs-alpine-docker-images>
- Docker Docs, "Dockerfile reference" <https://docs.docker.com/reference/dockerfile/>
- Docker, "Docker Best Practices: Choosing Between RUN, CMD, and ENTRYPOINT" <https://www.docker.com/blog/docker-best-practices-choosing-between-run-cmd-and-entrypoint/>
- Christian Emmer, "Docker Shell vs. Exec Form" <https://emmer.dev/blog/docker-shell-vs.-exec-form/>
- GitHub, moby/moby Release v1.12.0 <https://github.com/moby/moby/releases/tag/v1.12.0>
- Docker Docs, "Engine v17.05 Release Notes" <https://docs.docker.com/engine/release-notes/17.05/>
- Docker, "Multi-Stage Builds" <https://www.docker.com/blog/multi-stage-builds/>
- GitHub, GoogleContainerTools/distroless <https://github.com/GoogleContainerTools/distroless>
- Docker Docs, "Distroless images" <https://docs.docker.com/dhi/core-concepts/distroless/>
- Docker Hub, "scratch" 公式イメージ <https://hub.docker.com/_/scratch/>
- GitHub, krallin/tini <https://github.com/krallin/tini>
- Yelp Engineering Blog, "Introducing dumb-init, an init system for Docker containers", 2016年 <https://engineeringblog.yelp.com/2016/01/dumb-init-an-init-for-docker.html>
- CISA, "GNU Bourne-Again Shell (Bash) 'Shellshock' Vulnerability" <https://www.cisa.gov/news-events/alerts/2014/09/25/gnu-bourne-again-shell-bash-shellshock-vulnerability-cve-2014-6271-cve-2014-7169-cve-2014-7186-cve>
- NVD, "CVE-2014-6271" <https://nvd.nist.gov/vuln/detail/cve-2014-6271>
- Kubernetes, "Kubernetes v1.25: Combiner", 2022年 <https://kubernetes.io/blog/2022/08/23/kubernetes-v1-25-release/>
- Kubernetes Docs, "Ephemeral Containers" <https://kubernetes.io/docs/concepts/workloads/pods/ephemeral-containers/>
- GitHub Docs, "Setting a default shell and working directory" <https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/setting-a-default-shell-and-working-directory>
- GitLab Docs, "Types of shells supported by GitLab Runner" <https://docs.gitlab.com/runner/shells/>
