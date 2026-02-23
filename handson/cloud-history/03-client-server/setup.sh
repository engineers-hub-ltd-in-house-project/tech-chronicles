#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-03"

echo "============================================================"
echo " クラウドの考古学 第3回 ハンズオン"
echo " ソケット通信でクライアント/サーバモデルを体感する"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo "============================================================"
echo " 環境セットアップ"
echo "============================================================"
echo ""

apt-get update -qq && apt-get install -y -qq python3 net-tools iproute2 procps > /dev/null 2>&1
echo "必要なパッケージをインストールしました"

# ============================================================
echo ""
echo "============================================================"
echo " 演習1: 最小のクライアント/サーバ通信"
echo "============================================================"
echo ""

cat > "${WORKDIR}/server.py" << 'PYEOF'
import socket

HOST = '127.0.0.1'
PORT = 8080

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(1)
    print(f"サーバ起動: {HOST}:{PORT} で接続待ち")

    conn, addr = s.accept()
    with conn:
        print(f"接続: {addr}")
        data = conn.recv(1024)
        if data:
            message = data.decode('utf-8')
            print(f"受信: {message}")
            response = f"サーバが受信しました: {message}"
            conn.sendall(response.encode('utf-8'))
            print(f"送信: {response}")
PYEOF

cat > "${WORKDIR}/client.py" << 'PYEOF'
import socket

HOST = '127.0.0.1'
PORT = 8080

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    message = "Hello from client"
    s.sendall(message.encode('utf-8'))
    print(f"送信: {message}")

    data = s.recv(1024)
    print(f"受信: {data.decode('utf-8')}")
PYEOF

echo "server.py と client.py を作成しました"
echo ""
echo "--- 演習1実行 ---"
echo ""

python3 "${WORKDIR}/server.py" &
SERVER_PID=$!
sleep 1

python3 "${WORKDIR}/client.py"
wait ${SERVER_PID} 2>/dev/null || true

echo ""
echo "→ socket() → bind() → listen() → accept() のパターンは"
echo "  1983年のBSD 4.2で定義され、40年以上変わっていない"

# ============================================================
echo ""
echo "============================================================"
echo " 演習2: 計算の分散（RPCの原型）"
echo "============================================================"
echo ""

cat > "${WORKDIR}/rpc_server.py" << 'PYEOF'
import socket
import json

HOST = '127.0.0.1'
PORT = 8081

def add(x, y):
    return x + y

def multiply(x, y):
    return x * y

def factorial(n):
    result = 1
    for i in range(1, n + 1):
        result *= i
    return result

functions = {
    'add': add,
    'multiply': multiply,
    'factorial': factorial,
}

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(5)
    print(f"RPCサーバ起動: {HOST}:{PORT}")

    for _ in range(103):  # 100回ベンチマーク + 3回デモ呼び出し
        conn, addr = s.accept()
        with conn:
            data = conn.recv(4096)
            if data:
                request = json.loads(data.decode('utf-8'))
                func_name = request['function']
                args = request['args']
                if func_name in functions:
                    result = functions[func_name](*args)
                    response = {'status': 'ok', 'result': result}
                else:
                    response = {'status': 'error', 'message': f'Unknown: {func_name}'}
                conn.sendall(json.dumps(response).encode('utf-8'))
PYEOF

cat > "${WORKDIR}/rpc_client.py" << 'PYEOF'
import socket
import json
import time

HOST = '127.0.0.1'
PORT = 8081

def remote_call(func_name, *args):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        request = {'function': func_name, 'args': list(args)}
        s.sendall(json.dumps(request).encode('utf-8'))
        data = s.recv(4096)
        response = json.loads(data.decode('utf-8'))
        if response['status'] == 'ok':
            return response['result']
        else:
            raise Exception(response['message'])

def local_add(x, y):
    return x + y

print("=== ローカル呼び出し ===")
start = time.time()
for _ in range(100):
    local_add(3, 5)
local_time = time.time() - start
print(f"100回のローカル呼び出し: {local_time*1000:.2f} ミリ秒")

print("")
print("=== リモート呼び出し（RPC）===")
start = time.time()
for _ in range(100):
    remote_call('add', 3, 5)
remote_time = time.time() - start
print(f"100回のRPC呼び出し: {remote_time*1000:.2f} ミリ秒")

if local_time > 0:
    print(f"\nRPCのオーバーヘッド: ローカルの約{remote_time/local_time:.0f}倍")

print(f"\nadd(10, 20) = {remote_call('add', 10, 20)}")
print(f"multiply(6, 7) = {remote_call('multiply', 6, 7)}")
print(f"factorial(10) = {remote_call('factorial', 10)}")
PYEOF

echo "rpc_server.py と rpc_client.py を作成しました"
echo ""
echo "--- 演習2実行 ---"
echo ""

python3 "${WORKDIR}/rpc_server.py" &
RPC_SERVER_PID=$!
sleep 1

python3 "${WORKDIR}/rpc_client.py"
wait ${RPC_SERVER_PID} 2>/dev/null || true

echo ""
echo "→ ローカル呼び出しとRPCの実行時間の差がネットワークのコスト"
echo "  1984年のBirell/Nelsonの論文が定式化した問題は今も生きている"

# ============================================================
echo ""
echo "============================================================"
echo " 演習3: 複数クライアントの同時接続"
echo "============================================================"
echo ""

cat > "${WORKDIR}/concurrent_server.py" << 'PYEOF'
import socket
import threading
import time

HOST = '127.0.0.1'
PORT = 8082

client_count = 0
lock = threading.Lock()

def handle_client(conn, addr):
    global client_count
    with lock:
        client_count += 1
        current = client_count
    with conn:
        while True:
            data = conn.recv(4096)
            if not data:
                break
            message = data.decode('utf-8')
            time.sleep(0.1)
            response = f"[Server] thread#{current}: {message}"
            conn.sendall(response.encode('utf-8'))

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(10)
    print(f"マルチスレッドサーバ起動: {HOST}:{PORT}")

    # 一定時間後に自動終了
    s.settimeout(10)
    try:
        while True:
            conn, addr = s.accept()
            thread = threading.Thread(target=handle_client, args=(conn, addr))
            thread.daemon = True
            thread.start()
    except socket.timeout:
        pass
PYEOF

cat > "${WORKDIR}/concurrent_client.py" << 'PYEOF'
import socket
import threading
import time

HOST = '127.0.0.1'
PORT = 8082

results = []
lock = threading.Lock()

def client_task(client_id, num_requests):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((HOST, PORT))
        for i in range(num_requests):
            message = f"Request {i} from client {client_id}"
            s.sendall(message.encode('utf-8'))
            data = s.recv(4096)
            with lock:
                results.append(data.decode('utf-8'))

threads = []
start = time.time()

for i in range(5):
    t = threading.Thread(target=client_task, args=(i, 3))
    threads.append(t)
    t.start()

for t in threads:
    t.join()

elapsed = time.time() - start

print(f"5クライアント x 3リクエスト = {len(results)}リクエスト完了")
print(f"合計時間: {elapsed:.2f}秒")
print(f"逐次実行なら 15 x 0.1秒 = 1.5秒以上かかるはず")
print(f"→ スレッドによる並行処理で {elapsed:.2f}秒に短縮")
PYEOF

echo "concurrent_server.py と concurrent_client.py を作成しました"
echo ""
echo "--- 演習3実行 ---"
echo ""

python3 "${WORKDIR}/concurrent_server.py" &
CONC_SERVER_PID=$!
sleep 1

python3 "${WORKDIR}/concurrent_client.py"

kill ${CONC_SERVER_PID} 2>/dev/null || true
wait ${CONC_SERVER_PID} 2>/dev/null || true

echo ""
echo "→ 1台のサーバが複数クライアントを同時に処理するモデルは"
echo "  1990年代のアプリケーションサーバの原型であり"
echo "  現代のWebサーバにも受け継がれている"

# ============================================================
echo ""
echo "============================================================"
echo " ハンズオン完了"
echo "============================================================"
echo ""
echo "このハンズオンで体感したこと:"
echo ""
echo "1. クライアント/サーバ通信の基盤はBSD 4.2（1983年）以来変わらない"
echo "2. RPCはネットワークの遅延を隠蔽できない"
echo "3. 並行接続の処理モデルがシステムのスケーラビリティを決定する"
echo ""
echo "作業ファイルは ${WORKDIR} にあります"
