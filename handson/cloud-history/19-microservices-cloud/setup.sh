#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-19"

echo "=========================================="
echo "クラウドの考古学 第19回 ハンズオン"
echo "マイクロサービスとクラウド"
echo "=========================================="

# --- 作業ディレクトリの作成 ---
echo ""
echo "=== 作業ディレクトリの準備 ==="
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"
mkdir -p order-service inventory-service payment-service

# --- 在庫サービス ---
echo "=== 在庫サービスの作成 ==="
cat > inventory-service/app.py << 'PYTHON_EOF'
from flask import Flask, jsonify, request
import time
import random

app = Flask(__name__)

inventory = {
    "item-001": {"name": "Laptop", "stock": 10},
    "item-002": {"name": "Mouse", "stock": 50},
    "item-003": {"name": "Keyboard", "stock": 30},
}

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy", "service": "inventory"})

@app.route("/check/<item_id>", methods=["GET"])
def check_stock(item_id):
    delay = random.uniform(0.01, 0.05)
    time.sleep(delay)
    if item_id not in inventory:
        return jsonify({"error": "Item not found"}), 404
    item = inventory[item_id]
    return jsonify({
        "item_id": item_id,
        "name": item["name"],
        "stock": item["stock"],
        "available": item["stock"] > 0,
        "response_time_ms": round(delay * 1000, 1)
    })

@app.route("/reserve/<item_id>", methods=["POST"])
def reserve_stock(item_id):
    if item_id not in inventory:
        return jsonify({"error": "Item not found"}), 404
    item = inventory[item_id]
    if item["stock"] <= 0:
        return jsonify({"error": "Out of stock"}), 409
    quantity = request.json.get("quantity", 1)
    if item["stock"] < quantity:
        return jsonify({"error": "Insufficient stock"}), 409
    item["stock"] -= quantity
    return jsonify({
        "item_id": item_id,
        "reserved": quantity,
        "remaining_stock": item["stock"]
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
PYTHON_EOF

# --- 決済サービス ---
echo "=== 決済サービスの作成 ==="
cat > payment-service/app.py << 'PYTHON_EOF'
from flask import Flask, jsonify, request
import time
import random
import os

app = Flask(__name__)
FAILURE_MODE = os.environ.get("FAILURE_MODE", "none")

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy", "service": "payment"})

@app.route("/charge", methods=["POST"])
def charge():
    data = request.json
    if FAILURE_MODE == "slow":
        delay = random.uniform(3.0, 8.0)
        time.sleep(delay)
    elif FAILURE_MODE == "error":
        if random.random() < 0.7:
            return jsonify({"error": "Payment gateway timeout"}), 500
    elif FAILURE_MODE == "intermittent":
        r = random.random()
        if r < 0.3:
            time.sleep(random.uniform(2.0, 5.0))
        elif r < 0.5:
            return jsonify({"error": "Connection refused"}), 503
    else:
        time.sleep(random.uniform(0.05, 0.15))

    return jsonify({
        "transaction_id": f"txn-{random.randint(10000, 99999)}",
        "amount": data.get("amount", 0),
        "status": "charged",
        "failure_mode": FAILURE_MODE
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002)
PYTHON_EOF

# --- 注文サービス（サーキットブレーカー付き） ---
echo "=== 注文サービスの作成 ==="
cat > order-service/app.py << 'PYTHON_EOF'
from flask import Flask, jsonify, request
import requests
import time
import threading

app = Flask(__name__)

INVENTORY_URL = "http://inventory-service:5001"
PAYMENT_URL = "http://payment-service:5002"

class CircuitBreaker:
    CLOSED = "CLOSED"
    OPEN = "OPEN"
    HALF_OPEN = "HALF_OPEN"

    def __init__(self, name, failure_threshold=3, recovery_timeout=10):
        self.name = name
        self.state = self.CLOSED
        self.failure_count = 0
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.last_failure_time = 0
        self.success_count = 0
        self.lock = threading.Lock()

    def call(self, func, *args, **kwargs):
        with self.lock:
            if self.state == self.OPEN:
                if time.time() - self.last_failure_time > self.recovery_timeout:
                    self.state = self.HALF_OPEN
                    self.success_count = 0
                    print(f"[CB:{self.name}] OPEN -> HALF_OPEN")
                else:
                    raise CircuitOpenError(
                        f"Circuit {self.name} is OPEN. "
                        f"Retry after {self.recovery_timeout}s"
                    )
        try:
            result = func(*args, **kwargs)
            with self.lock:
                if self.state == self.HALF_OPEN:
                    self.success_count += 1
                    if self.success_count >= 2:
                        self.state = self.CLOSED
                        self.failure_count = 0
                        print(f"[CB:{self.name}] HALF_OPEN -> CLOSED")
                else:
                    self.failure_count = 0
            return result
        except Exception as e:
            with self.lock:
                self.failure_count += 1
                self.last_failure_time = time.time()
                if self.failure_count >= self.failure_threshold:
                    self.state = self.OPEN
                    print(f"[CB:{self.name}] -> OPEN (failures: {self.failure_count})")
            raise

    def get_status(self):
        return {
            "name": self.name,
            "state": self.state,
            "failure_count": self.failure_count,
            "failure_threshold": self.failure_threshold,
        }

class CircuitOpenError(Exception):
    pass

payment_cb = CircuitBreaker("payment", failure_threshold=3, recovery_timeout=15)
inventory_cb = CircuitBreaker("inventory", failure_threshold=3, recovery_timeout=15)

def call_inventory(item_id):
    resp = requests.get(f"{INVENTORY_URL}/check/{item_id}", timeout=2)
    resp.raise_for_status()
    return resp.json()

def call_payment(amount):
    resp = requests.post(f"{PAYMENT_URL}/charge", json={"amount": amount}, timeout=2)
    resp.raise_for_status()
    return resp.json()

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy", "service": "order"})

@app.route("/circuit-status", methods=["GET"])
def circuit_status():
    return jsonify({
        "payment": payment_cb.get_status(),
        "inventory": inventory_cb.get_status(),
    })

@app.route("/order", methods=["POST"])
def create_order():
    data = request.json or {}
    item_id = data.get("item_id", "item-001")
    amount = data.get("amount", 1000)
    start = time.time()
    result = {"item_id": item_id, "steps": []}

    try:
        inv = inventory_cb.call(call_inventory, item_id)
        result["steps"].append({"step": "inventory_check", "status": "success", "data": inv})
    except CircuitOpenError as e:
        result["steps"].append({"step": "inventory_check", "status": "circuit_open", "error": str(e)})
        result["status"] = "failed"
        result["error"] = "Inventory service circuit is open"
        result["elapsed_ms"] = round((time.time() - start) * 1000, 1)
        return jsonify(result), 503
    except Exception as e:
        result["steps"].append({"step": "inventory_check", "status": "error", "error": str(e)})
        result["status"] = "failed"
        result["elapsed_ms"] = round((time.time() - start) * 1000, 1)
        return jsonify(result), 500

    try:
        pay = payment_cb.call(call_payment, amount)
        result["steps"].append({"step": "payment", "status": "success", "data": pay})
    except CircuitOpenError as e:
        result["steps"].append({"step": "payment", "status": "circuit_open", "error": str(e)})
        result["status"] = "failed"
        result["error"] = "Payment service circuit is open"
        result["elapsed_ms"] = round((time.time() - start) * 1000, 1)
        return jsonify(result), 503
    except Exception as e:
        result["steps"].append({"step": "payment", "status": "error", "error": str(e)})
        result["steps"].append({
            "step": "compensation",
            "action": "inventory_release_needed",
            "note": "在庫の確保を取り消す必要がある"
        })
        result["status"] = "failed"
        result["elapsed_ms"] = round((time.time() - start) * 1000, 1)
        return jsonify(result), 500

    result["status"] = "success"
    result["elapsed_ms"] = round((time.time() - start) * 1000, 1)
    return jsonify(result), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
PYTHON_EOF

# --- 共通ファイル ---
echo "=== 共通ファイルの作成 ==="
cat > requirements.txt << 'EOF'
flask==3.1.0
requests==2.32.3
EOF

cat > Dockerfile << 'DOCKERFILE_EOF'
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
DOCKERFILE_EOF

cat > docker-compose.yml << 'COMPOSE_EOF'
services:
  inventory-service:
    build:
      context: .
      dockerfile: Dockerfile
    command: python inventory-service/app.py
    ports:
      - "5001:5001"

  payment-service:
    build:
      context: .
      dockerfile: Dockerfile
    command: python payment-service/app.py
    ports:
      - "5002:5002"
    environment:
      - FAILURE_MODE=none

  order-service:
    build:
      context: .
      dockerfile: Dockerfile
    command: python order-service/app.py
    ports:
      - "5000:5000"
    depends_on:
      - inventory-service
      - payment-service
COMPOSE_EOF

# --- サービスの起動 ---
echo ""
echo "=== サービスのビルドと起動 ==="
docker compose build
docker compose up -d
echo "サービスの起動を待機中（10秒）..."
sleep 10

# --- 演習1: 正常系 ---
echo ""
echo "=========================================="
echo "演習1: マイクロサービスの構築と通信"
echo "=========================================="

echo ""
echo "=== ヘルスチェック ==="
echo "在庫サービス:"
curl -s http://localhost:5001/health | python3 -m json.tool
echo "決済サービス:"
curl -s http://localhost:5002/health | python3 -m json.tool
echo "注文サービス:"
curl -s http://localhost:5000/health | python3 -m json.tool

echo ""
echo "=== 正常系: 注文リクエスト ==="
curl -s -X POST http://localhost:5000/order \
  -H "Content-Type: application/json" \
  -d '{"item_id": "item-001", "amount": 1500}' | python3 -m json.tool

echo ""
echo "考察:"
echo "- 注文サービスが在庫サービスと決済サービスを順に呼び出す"
echo "- elapsed_msを確認: ネットワーク越しの呼び出しコストが見える"

# --- 演習2: 障害とサーキットブレーカー ---
echo ""
echo "=========================================="
echo "演習2: カスケード障害とサーキットブレーカー"
echo "=========================================="

echo ""
echo "=== 決済サービスを障害モード（error）に切り替え ==="
docker compose stop payment-service
FAILURE_MODE=error docker compose up -d payment-service
sleep 5

echo ""
echo "=== サーキットブレーカーの状態（初期） ==="
curl -s http://localhost:5000/circuit-status | python3 -m json.tool

echo ""
echo "=== 障害中のリクエスト（5回連続） ==="
for i in $(seq 1 5); do
  echo "--- リクエスト #${i} ---"
  curl -s -X POST http://localhost:5000/order \
    -H "Content-Type: application/json" \
    -d '{"item_id": "item-001", "amount": 1500}' | python3 -m json.tool
  sleep 1
done

echo ""
echo "=== サーキットブレーカーの状態（障害後） ==="
curl -s http://localhost:5000/circuit-status | python3 -m json.tool

echo ""
echo "=== 決済サービスを正常モードに戻す ==="
docker compose stop payment-service
FAILURE_MODE=none docker compose up -d payment-service
sleep 5

echo ""
echo "=== 回復待ち（15秒） ==="
sleep 16

echo ""
echo "=== 回復後のリクエスト ==="
for i in $(seq 1 3); do
  echo "--- リクエスト #${i} ---"
  curl -s -X POST http://localhost:5000/order \
    -H "Content-Type: application/json" \
    -d '{"item_id": "item-002", "amount": 800}' | python3 -m json.tool
  sleep 1
done

echo ""
echo "=== 最終的なサーキットブレーカーの状態 ==="
curl -s http://localhost:5000/circuit-status | python3 -m json.tool

echo ""
echo "=========================================="
echo "ハンズオン完了"
echo "=========================================="
echo ""
echo "クリーンアップ:"
echo "  cd ${WORKDIR} && docker compose down"
echo "  rm -rf ${WORKDIR}"
