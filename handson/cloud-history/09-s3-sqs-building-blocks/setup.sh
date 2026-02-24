#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-09"

echo "============================================================"
echo " クラウドの考古学 第9回 ハンズオン"
echo " S3、SQS——クラウドの基本構成要素を体験する"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "推奨実行環境:"
echo "  docker run -it --rm --name s3-sqs-handson ubuntu:24.04 bash"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo "============================================================"
echo " 環境セットアップ"
echo "============================================================"
echo ""

apt-get update -qq && apt-get install -y -qq \
  curl unzip python3 jq > /dev/null 2>&1
echo "必要なパッケージをインストールしました"

# ============================================================
echo ""
echo "============================================================"
echo " 演習1: S3互換API（MinIO）の操作体験"
echo "============================================================"
echo ""

echo "--- AWS CLI v2のインストール ---"
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install --update 2>/dev/null || ./aws/install
rm -rf awscliv2.zip aws
echo "AWS CLI v2 インストール完了"
aws --version
echo ""

echo "--- AWS CLI設定（ローカル学習用） ---"
mkdir -p ~/.aws
cat > ~/.aws/credentials << 'EOF'
[default]
aws_access_key_id = minioadmin
aws_secret_access_key = minioadmin
EOF

cat > ~/.aws/config << 'EOF'
[default]
region = us-east-1
output = json
EOF
echo "AWS CLI設定完了（MinIO接続用のダミー認証情報）"
echo ""

echo "--- S3操作コマンドの確認 ---"
echo ""
echo "MinIOが起動している場合、以下のコマンドで操作できる:"
echo ""
echo "  ENDPOINT=http://localhost:9000"
echo ""
echo "  # バケット作成"
echo "  aws s3 mb s3://my-bucket --endpoint-url \$ENDPOINT"
echo ""
echo "  # オブジェクト操作"
echo "  aws s3 cp file.txt s3://my-bucket/file.txt --endpoint-url \$ENDPOINT  # PUT"
echo "  aws s3 cp s3://my-bucket/file.txt ./dl.txt --endpoint-url \$ENDPOINT  # GET"
echo "  aws s3 ls s3://my-bucket/ --endpoint-url \$ENDPOINT                   # LIST"
echo "  aws s3 rm s3://my-bucket/file.txt --endpoint-url \$ENDPOINT           # DELETE"
echo ""
echo "S3 APIの本質: PUT/GET/DELETE——HTTPの3つの動詞で全操作が完結する。"
echo ""

# ============================================================
echo ""
echo "============================================================"
echo " 演習2: オブジェクトストレージの特性"
echo "============================================================"
echo ""

echo "--- フラット名前空間の理解 ---"
echo ""
echo "S3にはディレクトリが存在しない。"
echo "「images/photo-001.jpg」の「images/」はディレクトリではなく、"
echo "キー名の一部にすぎない。S3コンソールがディレクトリのように"
echo "見せているのは、「/」区切りのプレフィックスによる模倣だ。"
echo ""
echo "  aws s3 ls s3://my-bucket/ --recursive --endpoint-url \$ENDPOINT"
echo "  # images/photo-001.jpg"
echo "  # images/photo-002.jpg"
echo "  # logs/2024-01-01.json"
echo ""
echo "--- メタデータの確認 ---"
echo ""
echo "  aws s3api head-object --bucket my-bucket --key images/photo-001.jpg \\"
echo "    --endpoint-url \$ENDPOINT"
echo ""
echo "オブジェクトごとにContentLength, ContentType, ETag等のメタデータが"
echo "APIで取得可能。ファイルシステムとの根本的な違いだ。"
echo ""

# ============================================================
echo ""
echo "============================================================"
echo " 演習3: SQSの核心——Visibility Timeoutを体験する"
echo "============================================================"
echo ""

cat > "${WORKDIR}/simple_queue.py" << 'PYEOF'
#!/usr/bin/env python3
"""簡易メッセージキュー -- SQS概念デモ

SQSの核心概念を模倣した実装:
1. メッセージの永続化
2. Visibility Timeout（受信後の非表示期間）
3. At-Least-Once Delivery（少なくとも1回の配信保証）
4. 明示的な削除（処理完了後にコンシューマが削除）
"""
import time, uuid, threading
from collections import deque
from dataclasses import dataclass

@dataclass
class Message:
    message_id: str
    body: str
    receipt_handle: str = ""
    visible_after: float = 0
    receive_count: int = 0

class SimpleQueue:
    def __init__(self, visibility_timeout=30):
        self._msgs = deque()
        self._lock = threading.Lock()
        self._vt = visibility_timeout

    def send(self, body):
        m = Message(message_id=uuid.uuid4().hex[:8], body=body)
        with self._lock:
            self._msgs.append(m)
        print(f"  [SEND] {body} (ID: {m.message_id})")
        return m.message_id

    def receive(self):
        now = time.time()
        with self._lock:
            for m in self._msgs:
                if m.visible_after <= now:
                    m.receipt_handle = uuid.uuid4().hex[:8]
                    m.visible_after = now + self._vt
                    m.receive_count += 1
                    return m
        return None

    def delete(self, handle):
        with self._lock:
            for i, m in enumerate(self._msgs):
                if m.receipt_handle == handle:
                    del self._msgs[i]
                    return True
        return False

    @property
    def size(self):
        return len(self._msgs)

print("=" * 60)
print(" 簡易メッセージキュー -- SQS概念デモ")
print("=" * 60)

# --- Producer-Consumer パターン ---
print("\n--- Producer: メッセージ送信 ---")
q = SimpleQueue(visibility_timeout=3)
for task in ["img-001をリサイズ", "img-002をリサイズ", "img-003をリサイズ"]:
    q.send(task)
print(f"\nキュー内メッセージ数: {q.size}")

print("\n--- Consumer: メッセージ受信・処理・削除 ---")
processed = 0
while (m := q.receive()):
    print(f"  [RECV] {m.body} (count={m.receive_count})")
    q.delete(m.receipt_handle)
    print(f"  [DEL]  削除完了")
    processed += 1
print(f"\n処理完了: {processed}件, 残数: {q.size}")

# --- At-Least-Once Delivery デモ ---
print("\n--- At-Least-Once Delivery デモ ---")
print("メッセージを受信後、削除せずにタイムアウトさせる\n")
q2 = SimpleQueue(visibility_timeout=2)
q2.send("重要なタスク")

m = q2.receive()
print(f"  1回目受信: {m.body} (count={m.receive_count})")
print(f"  → 削除しない（処理失敗を想定）")
print(f"  → {q2._vt}秒後にメッセージが再表示される")
time.sleep(3)

m = q2.receive()
if m:
    print(f"  2回目受信: {m.body} (count={m.receive_count})")
    print("  → 同じメッセージが再配信された（At-Least-Once）")
    q2.delete(m.receipt_handle)
    print("  → 処理成功。削除完了。")

print("\n" + "=" * 60)
print(" まとめ:")
print("  Send/Receive/DeleteとVisibility Timeoutにより、")
print("  メッセージは「少なくとも1回」配信される。")
print("  消費者が処理に失敗しても、メッセージは失われない。")
print("=" * 60)
PYEOF

echo "SQSデモスクリプトを作成しました: ${WORKDIR}/simple_queue.py"
echo ""
echo "実行:"
python3 "${WORKDIR}/simple_queue.py"

# ============================================================
echo ""
echo "============================================================"
echo " 演習4: ビルディングブロックの組み合わせ設計"
echo "============================================================"
echo ""

echo "--- 画像処理パイプラインの設計 ---"
echo ""
echo "S3（ストレージ）+ SQS（メッセージング）+ EC2（計算）を"
echo "組み合わせた画像処理パイプライン:"
echo ""
echo "  1. ユーザーが画像をS3にアップロード"
echo "  2. S3イベント通知がSQSにメッセージを送信"
echo "  3. ワーカー（EC2）がSQSからメッセージを受信"
echo "  4. ワーカーがS3から元画像を取得し、リサイズ"
echo "  5. ワーカーがリサイズ済み画像をS3に保存"
echo "  6. ワーカーがSQSのメッセージを削除（処理完了）"
echo ""
echo "各コンポーネントは独立:"
echo "  ── S3は保存だけ、SQSは受け渡しだけ、EC2はリサイズだけ"
echo "  ── ワーカー数を増やせば処理速度が上がる"
echo "  ── 一つのコンポーネントの障害が全体を停止させない"
echo ""
echo "これがビルディングブロック思想の実践だ。"

# ============================================================
echo ""
echo "============================================================"
echo " 全演習完了"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "この演習で学んだこと:"
echo "  1. S3 APIはHTTPのPUT/GET/DELETEだけで全操作が完結する"
echo "  2. オブジェクトストレージにはディレクトリが存在しない"
echo "  3. SQSのVisibility Timeoutが「少なくとも1回」の配信を保証する"
echo "  4. S3+SQS+EC2の組み合わせがクラウドアーキテクチャの基本形"
