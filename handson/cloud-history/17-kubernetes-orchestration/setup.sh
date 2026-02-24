#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-17"

echo "=============================================="
echo " 第17回ハンズオン: Kubernetesの宣言的インフラを体験する"
echo "=============================================="
echo ""

# --- 前提条件の確認 ---
echo ">>> 前提条件を確認中..."

if ! command -v docker &> /dev/null; then
    echo "ERROR: docker がインストールされていません"
    echo "Docker Desktop または Docker Engine をインストールしてください"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "ERROR: Docker デーモンが起動していません"
    echo "Docker Desktop を起動するか、sudo systemctl start docker を実行してください"
    exit 1
fi

echo "Docker: OK"

# --- 作業ディレクトリの作成 ---
echo ""
echo ">>> 作業ディレクトリを作成: $WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# --- kindのインストール ---
echo ""
echo ">>> kindをインストール中..."

if command -v kind &> /dev/null; then
    echo "kind: 既にインストール済み ($(kind version))"
else
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) KIND_ARCH="amd64" ;;
        aarch64|arm64) KIND_ARCH="arm64" ;;
        *) echo "ERROR: サポートされていないアーキテクチャ: $ARCH"; exit 1 ;;
    esac
    curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-${KIND_ARCH}"
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    echo "kind: インストール完了 ($(kind version))"
fi

# --- kubectlのインストール ---
echo ""
echo ">>> kubectlをインストール中..."

if command -v kubectl &> /dev/null; then
    echo "kubectl: 既にインストール済み ($(kubectl version --client --short 2>/dev/null || kubectl version --client -o yaml | grep gitVersion | head -1))"
else
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) KUBECTL_ARCH="amd64" ;;
        aarch64|arm64) KUBECTL_ARCH="arm64" ;;
        *) echo "ERROR: サポートされていないアーキテクチャ: $ARCH"; exit 1 ;;
    esac
    KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/kubectl
    echo "kubectl: インストール完了"
fi

# --- 既存クラスタの確認 ---
echo ""
if kind get clusters 2>/dev/null | grep -q "kind"; then
    echo ">>> 既存のkindクラスタを検出。削除して再作成します..."
    kind delete cluster
fi

# =============================================
# 演習1: ローカルKubernetesクラスタの構築
# =============================================
echo ""
echo "=============================================="
echo " 演習1: ローカルKubernetesクラスタの構築"
echo "=============================================="
echo ""

echo ">>> kindクラスタを作成中（コントロールプレーン1 + ワーカー2）..."
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

echo ""
echo ">>> クラスタの状態を確認"
kubectl cluster-info
echo ""
kubectl get nodes
echo ""

echo ">>> Deploymentの作成（Nginx 3レプリカ）"
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-demo
  labels:
    app: web-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-demo
  template:
    metadata:
      labels:
        app: web-demo
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 128Mi
EOF

echo ""
echo ">>> Podの起動を待機中..."
kubectl rollout status deployment/web-demo --timeout=120s

echo ""
echo ">>> Podの状態を確認"
kubectl get pods -o wide
echo ""
echo "注目: 3つのPodがワーカーノードに分散配置されている"
echo "KubernetesのSchedulerが自動的に最適な配置を決定した"

# =============================================
# 演習2: Reconciliation Loopの観察
# =============================================
echo ""
echo "=============================================="
echo " 演習2: Reconciliation Loopの観察"
echo "=============================================="
echo ""

echo ">>> 現在のPod一覧"
kubectl get pods

echo ""
echo ">>> Podを1つ手動で削除する"
POD_NAME=$(kubectl get pods -l app=web-demo -o jsonpath='{.items[0].metadata.name}')
echo "削除するPod: $POD_NAME"
kubectl delete pod "$POD_NAME"

echo ""
echo ">>> 5秒待って再確認..."
sleep 5
kubectl get pods

echo ""
echo "考察:"
echo "  - 削除したPodのStatusは 'Terminating' になる"
echo "  - 即座に新しいPodが作成される（名前が異なる）"
echo "  - Deployment Controllerが 'replicas: 3' の"
echo "    Desired Stateを検知し、Actual Stateとの差分を"
echo "    修正した（Reconciliation Loop）"
echo ""
echo "  これが宣言的インフラの本質:"
echo "    管理者は「あるべき状態」を宣言するだけ"
echo "    Kubernetesが自律的にその状態を維持する"

# =============================================
# 演習3: スケーリングとローリングアップデート
# =============================================
echo ""
echo "=============================================="
echo " 演習3: スケーリングとローリングアップデート"
echo "=============================================="
echo ""

echo ">>> 現在のレプリカ数: 3"
kubectl get deployment web-demo

echo ""
echo ">>> レプリカ数を5に増やす"
kubectl scale deployment web-demo --replicas=5
sleep 5
kubectl get pods -l app=web-demo

echo ""
echo ">>> レプリカ数を2に減らす"
kubectl scale deployment web-demo --replicas=2
sleep 5
kubectl get pods -l app=web-demo

echo ""
echo ">>> ローリングアップデート: nginx:1.27 → nginx:1.27-alpine"
kubectl set image deployment/web-demo nginx=nginx:1.27-alpine
kubectl rollout status deployment/web-demo --timeout=120s

echo ""
echo ">>> 更新後のPodを確認"
kubectl get pods -l app=web-demo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
echo ""

echo ">>> デプロイ履歴"
kubectl rollout history deployment/web-demo

echo ""
echo ">>> ロールバック: 前のバージョンに戻す"
kubectl rollout undo deployment/web-demo
kubectl rollout status deployment/web-demo --timeout=120s

echo ""
echo ">>> ロールバック後のPodを確認"
kubectl get pods -l app=web-demo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'
echo ""

# =============================================
# 演習4: ServiceとDNSによるサービスディスカバリ
# =============================================
echo ""
echo "=============================================="
echo " 演習4: ServiceとDNSによるサービスディスカバリ"
echo "=============================================="
echo ""

echo ">>> レプリカ数を3に戻す"
kubectl scale deployment web-demo --replicas=3
sleep 5

echo ""
echo ">>> Serviceを作成"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web-demo-svc
spec:
  selector:
    app: web-demo
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

echo ""
echo ">>> Serviceの状態を確認"
kubectl get service web-demo-svc
echo ""
kubectl describe service web-demo-svc

echo ""
echo ">>> Service経由でアクセス（DNS名で解決）"
kubectl run test-client --rm -i --restart=Never \
  --image=curlimages/curl:latest -- \
  curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" \
  http://web-demo-svc.default.svc.cluster.local

echo ""
echo ">>> Endpointsを確認（PodのIPが自動登録されている）"
kubectl get endpoints web-demo-svc

echo ""
echo "考察:"
echo "  - 'web-demo-svc.default.svc.cluster.local' という"
echo "    DNS名でServiceにアクセスできる"
echo "  - 背後のPodのIPアドレスが変わっても、DNS名は安定"
echo "  - EndpointsにPodのIPが自動登録される"
echo "  - PodをスケールするとEndpointsも自動更新される"

# =============================================
# まとめ
# =============================================
echo ""
echo "=============================================="
echo " ハンズオン完了"
echo "=============================================="
echo ""
echo "このハンズオンで体験したこと:"
echo "  1. kindによるローカルKubernetesクラスタの構築"
echo "  2. Reconciliation Loop: Podを削除しても自動復旧"
echo "  3. 宣言的スケーリング: レプリカ数の増減"
echo "  4. ローリングアップデートとロールバック"
echo "  5. ServiceによるDNSベースのサービスディスカバリ"
echo ""
echo "クリーンアップ:"
echo "  kind delete cluster"
echo ""
echo "=============================================="
