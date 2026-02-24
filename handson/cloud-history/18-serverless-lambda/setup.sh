#!/bin/bash
set -euo pipefail

############################################################
# 第18回ハンズオン: サーバーレス（Lambda）
# LocalStackを使ったAWS Lambda体験
############################################################

WORKDIR="${HOME}/cloud-history-handson-18"

echo "=========================================="
echo " 第18回: サーバーレス（Lambda）ハンズオン"
echo "=========================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

# ----- 前提条件チェック -----
echo "--- 前提条件チェック ---"

if ! command -v docker &> /dev/null; then
    echo "ERROR: docker が見つかりません。Docker をインストールしてください。"
    exit 1
fi

if ! command -v aws &> /dev/null; then
    echo "ERROR: aws CLI が見つかりません。AWS CLI v2 をインストールしてください。"
    exit 1
fi

echo "OK: docker, aws CLI が利用可能"
echo ""

# ----- 作業ディレクトリの準備 -----
echo "--- 作業ディレクトリの準備 ---"
mkdir -p "${WORKDIR}/functions"
cd "${WORKDIR}"
echo "OK: ${WORKDIR} を作成"
echo ""

# ----- LocalStackの起動 -----
echo "--- LocalStack の起動 ---"

cat > docker-compose.yml << 'COMPOSE_EOF'
version: '3.8'
services:
  localstack:
    image: localstack/localstack:3.8
    ports:
      - "4566:4566"
    environment:
      - SERVICES=lambda,s3,sqs,logs,iam
      - LAMBDA_EXECUTOR=docker
      - DOCKER_HOST=unix:///var/run/docker.sock
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - "./volume:/var/lib/localstack"
COMPOSE_EOF

docker compose up -d
echo "LocalStack の起動を待機中（15秒）..."
sleep 15
echo "OK: LocalStack 起動完了"
echo ""

# ----- AWS CLI設定 -----
export AWS_DEFAULT_REGION=ap-northeast-1
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_ENDPOINT_URL=http://localhost:4566

# ----- IAMロール作成 -----
aws iam create-role \
  --role-name lambda-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }' > /dev/null 2>&1 || true

############################################################
# 演習1: Lambda関数の作成と呼び出し
############################################################
echo "=========================================="
echo " 演習1: Lambda関数の作成と呼び出し"
echo "=========================================="
echo ""

cat > functions/hello.py << 'PYTHON_EOF'
import json
import datetime

def handler(event, context):
    """最もシンプルなLambda関数。"""
    print(f"Event received: {json.dumps(event)}")
    print(f"Function name: {context.function_name}")
    print(f"Remaining time (ms): {context.get_remaining_time_in_millis()}")

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from Lambda!',
            'timestamp': datetime.datetime.now().isoformat(),
            'event': event
        })
    }
PYTHON_EOF

cd functions && zip -q hello.zip hello.py && cd ..

aws lambda create-function \
  --function-name hello-function \
  --runtime python3.12 \
  --handler hello.handler \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --zip-file fileb://functions/hello.zip \
  --timeout 30 \
  --memory-size 128 > /dev/null

echo "Lambda関数 'hello-function' を作成しました"
echo ""

echo "--- 関数の呼び出し ---"
aws lambda invoke \
  --function-name hello-function \
  --payload '{"name": "serverless", "action": "test"}' \
  --cli-binary-format raw-in-base64-out \
  /tmp/output-ex1.json > /dev/null

echo "レスポンス:"
python3 -m json.tool < /tmp/output-ex1.json
echo ""
echo "[考察] Lambda関数はイベント(payload)を受け取り、処理結果を返す。"
echo "       サーバの起動・停止を意識する必要がない。"
echo ""

############################################################
# 演習2: S3イベント → Lambda（イベント駆動）
############################################################
echo "=========================================="
echo " 演習2: S3イベント → Lambda"
echo "=========================================="
echo ""

cat > functions/s3_handler.py << 'PYTHON_EOF'
import json

def handler(event, context):
    """S3にファイルがアップロードされたときに呼び出される関数。"""
    for record in event.get('Records', []):
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        size = record['s3']['object'].get('size', 0)
        print(f"New file: s3://{bucket}/{key} ({size} bytes)")

    return {
        'statusCode': 200,
        'body': json.dumps({'processed': len(event.get('Records', []))})
    }
PYTHON_EOF

cd functions && zip -q s3_handler.zip s3_handler.py && cd ..

aws lambda create-function \
  --function-name s3-handler \
  --runtime python3.12 \
  --handler s3_handler.handler \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --zip-file fileb://functions/s3_handler.zip \
  --timeout 60 \
  --memory-size 256 > /dev/null

aws s3 mb s3://my-upload-bucket > /dev/null 2>&1 || true

aws s3api put-bucket-notification-configuration \
  --bucket my-upload-bucket \
  --notification-configuration '{
    "LambdaFunctionConfigurations": [{
      "LambdaFunctionArn": "arn:aws:lambda:ap-northeast-1:000000000000:function:s3-handler",
      "Events": ["s3:ObjectCreated:*"]
    }]
  }' > /dev/null

echo "S3バケット 'my-upload-bucket' にイベント通知を設定しました"
echo ""

echo "--- S3にファイルをアップロード ---"
echo "Hello, Serverless!" > /tmp/test-upload.txt
aws s3 cp /tmp/test-upload.txt s3://my-upload-bucket/test.txt
sleep 3
echo ""
echo "[考察] S3へのアップロードが「イベント」となり、Lambda関数が自動起動する。"
echo "       サーバの待ち受けやポーリングは不要。これがイベント駆動の本質。"
echo ""

############################################################
# 演習3: SQSキュー → Lambda（非同期処理パターン）
############################################################
echo "=========================================="
echo " 演習3: SQSキュー → Lambda"
echo "=========================================="
echo ""

cat > functions/sqs_handler.py << 'PYTHON_EOF'
import json
import time

def handler(event, context):
    """SQSキューのメッセージを処理するLambda関数。"""
    processed = 0
    for record in event.get('Records', []):
        body = json.loads(record['body'])
        print(f"Processing message: {json.dumps(body)}")
        time.sleep(0.1)
        processed += 1

    print(f"Total processed: {processed} messages")
    return {'statusCode': 200, 'processed': processed}
PYTHON_EOF

cd functions && zip -q sqs_handler.zip sqs_handler.py && cd ..

aws lambda create-function \
  --function-name sqs-handler \
  --runtime python3.12 \
  --handler sqs_handler.handler \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --zip-file fileb://functions/sqs_handler.zip \
  --timeout 60 \
  --memory-size 128 > /dev/null

aws sqs create-queue --queue-name task-queue > /dev/null

QUEUE_ARN="arn:aws:sqs:ap-northeast-1:000000000000:task-queue"

aws lambda create-event-source-mapping \
  --function-name sqs-handler \
  --event-source-arn "${QUEUE_ARN}" \
  --batch-size 5 > /dev/null 2>&1 || true

QUEUE_URL=$(aws sqs get-queue-url --queue-name task-queue --query 'QueueUrl' --output text)

echo "SQSキュー 'task-queue' → Lambda 'sqs-handler' を接続しました"
echo ""

echo "--- SQSにメッセージを送信（10件） ---"
for i in $(seq 1 10); do
  aws sqs send-message \
    --queue-url "${QUEUE_URL}" \
    --message-body "{\"task_id\": ${i}, \"type\": \"process_data\"}" > /dev/null
done
echo "10件のメッセージを送信しました"
sleep 5
echo ""
echo "[考察] SQSにメッセージが到着すると、Lambda関数が自動起動する。"
echo "       メッセージが増えればLambdaの並行実行数が自動増加。"
echo "       メッセージがなくなればLambdaは実行されない（Scale to zero）。"
echo ""

############################################################
# 演習4: コールドスタートの観察
############################################################
echo "=========================================="
echo " 演習4: コールドスタートの観察"
echo "=========================================="
echo ""

cat > functions/coldstart.py << 'PYTHON_EOF'
import json
import time
import os

# --- 初期化コード（コールドスタート時のみ実行） ---
INIT_TIME = time.time()
print(f"[INIT] Function initialized at {INIT_TIME}")

# 重い初期化のシミュレーション
time.sleep(0.5)
INIT_COMPLETE = time.time()
print(f"[INIT] Initialization took {(INIT_COMPLETE - INIT_TIME)*1000:.1f} ms")
# --- 初期化コードここまで ---

invocation_count = 0

def handler(event, context):
    global invocation_count
    invocation_count += 1

    result = {
        'invocation_count': invocation_count,
        'is_cold_start': invocation_count == 1,
        'init_time_ms': round((INIT_COMPLETE - INIT_TIME) * 1000, 1),
    }

    print(f"[HANDLER] Invocation #{invocation_count}, cold_start={result['is_cold_start']}")

    return {
        'statusCode': 200,
        'body': json.dumps(result, indent=2)
    }
PYTHON_EOF

cd functions && zip -q coldstart.zip coldstart.py && cd ..

aws lambda create-function \
  --function-name coldstart-demo \
  --runtime python3.12 \
  --handler coldstart.handler \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --zip-file fileb://functions/coldstart.zip \
  --timeout 30 \
  --memory-size 128 > /dev/null

echo "--- 1回目の呼び出し（コールドスタート） ---"
aws lambda invoke \
  --function-name coldstart-demo \
  --payload '{}' \
  --cli-binary-format raw-in-base64-out \
  /tmp/cold1.json > /dev/null
python3 -m json.tool < /tmp/cold1.json
echo ""

echo "--- 2回目の呼び出し（ウォームスタート） ---"
aws lambda invoke \
  --function-name coldstart-demo \
  --payload '{}' \
  --cli-binary-format raw-in-base64-out \
  /tmp/cold2.json > /dev/null
python3 -m json.tool < /tmp/cold2.json
echo ""

echo "--- 3回目の呼び出し（ウォームスタート） ---"
aws lambda invoke \
  --function-name coldstart-demo \
  --payload '{}' \
  --cli-binary-format raw-in-base64-out \
  /tmp/cold3.json > /dev/null
python3 -m json.tool < /tmp/cold3.json
echo ""

echo "[考察] 1回目: is_cold_start=true → 初期化コードが実行される"
echo "       2回目以降: is_cold_start=false → 実行環境が再利用される"
echo "       invocation_countが増え続けるのが再利用の証拠"
echo ""

############################################################
# 完了
############################################################
echo "=========================================="
echo " ハンズオン完了"
echo "=========================================="
echo ""
echo "クリーンアップ:"
echo "  cd ${WORKDIR} && docker compose down"
echo "  rm -rf ${WORKDIR}"
echo ""
echo "本番のAWS環境では、Firecrackerによるマイクロ VMが"
echo "125ミリ秒未満で起動し、関数を隔離実行する。"
echo "LocalStackはエミュレーションであり、本番環境とは"
echo "コールドスタートの挙動が異なることに留意すること。"
