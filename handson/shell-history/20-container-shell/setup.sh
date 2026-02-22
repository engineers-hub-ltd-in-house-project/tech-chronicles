#!/bin/bash
# =============================================================================
# 第20回ハンズオン：コンテナ時代のシェル――Docker, CI/CD, そして/bin/sh問題
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 前提: Docker Engine 20.10以降がインストールされていること
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-20"

echo "=== 第20回ハンズオン：コンテナ時代のシェル ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# --- Dockerの確認 ---
echo "[準備] Docker環境の確認..."
if ! command -v docker > /dev/null 2>&1; then
  echo "エラー: Dockerがインストールされていません"
  echo "Docker Engine 20.10以降をインストールしてください"
  exit 1
fi

docker_version=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "unknown")
echo "  Docker version: ${docker_version}"
echo ""

# --- 必要なイメージのプル ---
echo "[準備] 必要なDockerイメージをプル中..."
docker pull alpine:3.21 -q
docker pull debian:bookworm -q
echo "  完了"
echo ""

# =============================================================================
# 演習1: シェル環境の確認
# =============================================================================
echo "=== 演習1: Alpine と Debian のシェル環境を比較する ==="
echo ""

echo "--- Debian (bookworm) の /bin/sh ---"
docker run --rm debian:bookworm sh -c '
echo "  /bin/sh -> $(readlink -f /bin/sh)"
echo "  bash version: $(bash --version | head -1)"
echo "  dash test: $(dash -c "echo available" 2>/dev/null || echo "not available")"
'
echo ""

echo "--- Alpine (3.21) の /bin/sh ---"
docker run --rm alpine:3.21 sh -c '
echo "  /bin/sh -> $(readlink -f /bin/sh 2>/dev/null || echo "direct binary")"
echo "  BusyBox version: $(busybox 2>&1 | head -1)"
echo "  bash test: $(bash --version 2>/dev/null || echo "bash: not found")"
'
echo ""

echo "--- bash拡張の互換性テスト ---"
echo ""

echo "[Debian /bin/bash]"
docker run --rm debian:bookworm bash -c '
# 配列
arr=(one two three)
echo "  配列: ${arr[1]}"
# [[ ]] テスト
if [[ "hello" == "hello" ]]; then
  echo "  [[ ]] テスト: OK"
fi
# パターン置換
text="hello-world"
echo "  パターン置換: ${text//-/_}"
'
echo ""

echo "[Alpine /bin/sh (BusyBox ash)]"
docker run --rm alpine:3.21 sh -c '
# POSIX互換の変数展開
name="world"
echo "  変数展開: Hello, ${name} (OK)"

# bash拡張は使えない
echo "  --- 以下はエラーになる ---"

# [[ ]] テスト
if [[ "hello" == "hello" ]] 2>/dev/null; then
  echo "  [[ ]] テスト: OK"
else
  echo "  [[ ]] テスト: 構文エラー（ash非対応）"
fi
' 2>&1 || true
echo ""

echo "=> Debian の /bin/sh は dash、Alpine の /bin/sh は BusyBox ash"
echo "   どちらも bash ではなく、bash拡張は使えない"
echo ""

# =============================================================================
# 演習2: shell form vs exec form のプロセスツリー
# =============================================================================
echo "=== 演習2: shell form vs exec form のプロセスツリー ==="
echo ""

echo "--- shell form: sh -c 経由で起動 ---"
docker run --rm -d --name handson20-shell-form alpine:3.21 \
  sh -c "sleep 3600" > /dev/null

sleep 1
echo "  プロセスツリー:"
docker exec handson20-shell-form ps -o pid,ppid,comm 2>/dev/null || \
  docker exec handson20-shell-form ps aux
docker stop handson20-shell-form > /dev/null 2>&1
echo ""

echo "--- exec form: 直接起動 ---"
docker run --rm -d --name handson20-exec-form alpine:3.21 \
  sleep 3600 > /dev/null

sleep 1
echo "  プロセスツリー:"
docker exec handson20-exec-form ps -o pid,ppid,comm 2>/dev/null || \
  docker exec handson20-exec-form ps aux
docker stop handson20-exec-form > /dev/null 2>&1
echo ""

echo "=> shell form では PID 1 が 'sh'、exec form では PID 1 が 'sleep'"
echo "   この違いがシグナルハンドリングに影響する"
echo ""

# =============================================================================
# 演習3: PID 1 とシグナルハンドリング（SIGTERM の挙動差）
# =============================================================================
echo "=== 演習3: PID 1 とシグナルハンドリングの実証 ==="
echo ""

# テスト用Pythonスクリプト
cat > "${WORKDIR}/server.py" << 'PYEOF'
import signal, sys, os, time

def handler(signum, frame):
    print(f"Received signal {signum} (SIGTERM), shutting down gracefully...", flush=True)
    sys.exit(0)

signal.signal(signal.SIGTERM, handler)
print(f"Server started (PID: {os.getpid()})", flush=True)

while True:
    time.sleep(1)
PYEOF

# shell form Dockerfile
cat > "${WORKDIR}/Dockerfile.shell-form" << 'DFEOF'
FROM alpine:3.21
RUN apk add --no-cache python3
COPY server.py /app/server.py
CMD python3 /app/server.py
DFEOF

# exec form Dockerfile
cat > "${WORKDIR}/Dockerfile.exec-form" << 'DFEOF'
FROM alpine:3.21
RUN apk add --no-cache python3
COPY server.py /app/server.py
CMD ["python3", "/app/server.py"]
DFEOF

echo "[ビルド] Dockerイメージをビルド中..."
docker build -f "${WORKDIR}/Dockerfile.shell-form" -t handson20-shell-form "${WORKDIR}" -q > /dev/null
docker build -f "${WORKDIR}/Dockerfile.exec-form" -t handson20-exec-form "${WORKDIR}" -q > /dev/null
echo "  完了"
echo ""

echo "--- shell form で docker stop ---"
docker run --rm -d --name handson20-sf handson20-shell-form > /dev/null
sleep 2
echo "  ログ (起動時):"
docker logs handson20-sf 2>&1 | head -3 | sed 's/^/    /'

echo "  docker stop 実行中（タイムアウト5秒に設定）..."
start_time=$(date +%s)
docker stop -t 5 handson20-sf > /dev/null 2>&1
end_time=$(date +%s)
elapsed=$((end_time - start_time))
echo "  停止にかかった時間: 約${elapsed}秒"
if [ "$elapsed" -ge 4 ]; then
  echo "  => SIGTERMが届かず、タイムアウト後にSIGKILLで強制終了された"
else
  echo "  => SIGTERMが処理された"
fi
echo ""

echo "--- exec form で docker stop ---"
docker run --rm -d --name handson20-ef handson20-exec-form > /dev/null
sleep 2
echo "  ログ (起動時):"
docker logs handson20-ef 2>&1 | head -3 | sed 's/^/    /'

echo "  docker stop 実行中（タイムアウト5秒に設定）..."
start_time=$(date +%s)
docker stop -t 5 handson20-ef > /dev/null 2>&1
end_time=$(date +%s)
elapsed=$((end_time - start_time))
echo "  停止にかかった時間: 約${elapsed}秒"
if [ "$elapsed" -ge 4 ]; then
  echo "  => SIGTERMが届かず、タイムアウト後にSIGKILLで強制終了された"
else
  echo "  => SIGTERMが正しく処理され、graceful shutdownが実行された"
fi
echo ""

echo "=> shell form ではPID 1が /bin/sh となり、SIGTERMがアプリに届かない"
echo "   exec form ではアプリがPID 1となり、SIGTERMを直接受信できる"
echo ""

# =============================================================================
# 演習4: POSIX準拠スクリプトへの書き換え
# =============================================================================
echo "=== 演習4: bash依存スクリプトをPOSIX sh互換に書き換える ==="
echo ""

# bash依存バージョン
cat > "${WORKDIR}/health-check-bash.sh" << 'BASHEOF'
#!/bin/bash
# bash拡張に依存したヘルスチェックスクリプト
declare -a services=("nginx" "postgres" "redis")

for svc in "${services[@]}"; do
  if [[ "$svc" == "nginx" ]]; then
    expected_proc="nginx: master"
  elif [[ "$svc" == "postgres" ]]; then
    expected_proc="postgres"
  else
    expected_proc="$svc"
  fi

  count=$(ps aux 2>/dev/null | grep -c "$expected_proc" || true)
  if [[ $count -gt 0 ]]; then
    echo "${svc}: running (${count} processes)"
  else
    echo "${svc}: not running"
  fi
done
BASHEOF

# POSIX互換バージョン
cat > "${WORKDIR}/health-check-posix.sh" << 'POSIXEOF'
#!/bin/sh
# POSIX sh互換 — Alpine (ash), Debian (dash) で動作
services="nginx postgres redis"

for svc in $services; do
  case "$svc" in
    nginx)    expected_proc="nginx: master" ;;
    postgres) expected_proc="postgres" ;;
    *)        expected_proc="$svc" ;;
  esac

  count=$(ps aux 2>/dev/null | grep -c "$expected_proc" || true)
  if [ "$count" -gt 0 ]; then
    echo "${svc}: running (${count} processes)"
  else
    echo "${svc}: not running"
  fi
done
POSIXEOF

echo "--- bash依存バージョン (Debianで実行) ---"
docker run --rm -v "${WORKDIR}:/work:ro" debian:bookworm bash /work/health-check-bash.sh
echo ""

echo "--- bash依存バージョン (Alpineで実行 → エラー) ---"
docker run --rm -v "${WORKDIR}:/work:ro" alpine:3.21 sh /work/health-check-bash.sh 2>&1 || true
echo ""

echo "--- POSIX互換バージョン (Alpineで実行 → 成功) ---"
docker run --rm -v "${WORKDIR}:/work:ro" alpine:3.21 sh /work/health-check-posix.sh
echo ""

echo "--- POSIX互換バージョン (Debianで実行 → 成功) ---"
docker run --rm -v "${WORKDIR}:/work:ro" debian:bookworm sh /work/health-check-posix.sh
echo ""

echo "=> POSIX互換スクリプトは Alpine でも Debian でも動作する"
echo "   書き換えのポイント:"
echo "     declare -a → スペース区切り文字列"
echo "     [[ ]] → [ ] (test)"
echo "     == → ="
echo "     if/elif パターンマッチ → case 文"
echo ""

# =============================================================================
# 演習5: マルチステージビルドでシェルを排除する
# =============================================================================
echo "=== 演習5: マルチステージビルドとシェルの排除 ==="
echo ""

# テスト用Goプログラム
cat > "${WORKDIR}/main.go" << 'GOEOF'
package main

import (
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello from container (PID: %d)\n", os.Getpid())
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintln(w, "ok")
	})

	go func() {
		fmt.Printf("Server starting on :8080 (PID: %d)\n", os.Getpid())
		if err := http.ListenAndServe(":8080", nil); err != nil {
			fmt.Fprintf(os.Stderr, "Server error: %v\n", err)
			os.Exit(1)
		}
	}()

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGTERM, syscall.SIGINT)
	sig := <-sigCh
	fmt.Printf("Received %v, shutting down gracefully\n", sig)
}
GOEOF

cat > "${WORKDIR}/go.mod" << 'MODEOF'
module handson20

go 1.23
MODEOF

# マルチステージDockerfile
cat > "${WORKDIR}/Dockerfile.multistage" << 'MSEOF'
# ビルドステージ: bash/gcc/makeが使える完全な環境
FROM golang:1.23 AS builder
WORKDIR /app
COPY go.mod main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o /server .

# 実行ステージ: scratchベース（シェルなし）
FROM scratch
COPY --from=builder /server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
MSEOF

echo "[ビルド] マルチステージDockerfileでビルド中..."
docker build -f "${WORKDIR}/Dockerfile.multistage" -t handson20-multistage "${WORKDIR}" -q > /dev/null
echo "  完了"
echo ""

echo "--- イメージサイズの比較 ---"
echo "  golang:1.23 (ビルド環境):"
docker images golang:1.23 --format "    {{.Size}}" 2>/dev/null | head -1
echo "  handson20-multistage (scratch + binary):"
docker images handson20-multistage --format "    {{.Size}}" 2>/dev/null | head -1
echo ""

echo "--- scratch イメージでシェルが使えないことを確認 ---"
docker run --rm -d --name handson20-ms -p 18080:8080 handson20-multistage > /dev/null
sleep 1

echo "  curl でアクセス:"
curl -s http://localhost:18080/ 2>/dev/null | sed 's/^/    /' || echo "    (curl失敗: ポートが使用中の可能性)"
echo ""

echo "  docker exec でシェルにアクセスを試みる:"
docker exec handson20-ms sh -c "echo hello" 2>&1 | sed 's/^/    /' || true
echo ""

echo "  => scratch イメージにはシェルが存在しないため、docker exec は失敗する"
echo "     デバッグには kubectl debug (Ephemeral Containers) や"
echo "     docker debug を使う必要がある"

docker stop handson20-ms > /dev/null 2>&1

echo ""

# =============================================================================
# クリーンアップ
# =============================================================================
echo "=== クリーンアップ ==="
echo ""
echo "以下のコマンドで作成したリソースを削除できます:"
echo "  rm -rf ${WORKDIR}"
echo "  docker rmi handson20-shell-form handson20-exec-form handson20-multistage 2>/dev/null"
echo ""
echo "=== ハンズオン完了 ==="
