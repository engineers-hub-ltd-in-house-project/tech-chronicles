# 第17回ハンズオン：Kubernetesの宣言的インフラを体験する

## 概要

kindを使ってローカルにKubernetesクラスタを構築し、宣言的設定とReconciliation Loopの威力を体験する。

## 学べること

- kindによるローカルKubernetesクラスタの構築
- Deploymentによるコンテナの宣言的管理
- Reconciliation Loopの動作（Podの自動復旧）
- スケーリング（レプリカ数の増減）
- ローリングアップデートとロールバック
- ServiceによるDNSベースのサービスディスカバリ

## 演習一覧

| # | 演習内容                                     | 学習ポイント                             |
| - | -------------------------------------------- | ---------------------------------------- |
| 1 | ローカルKubernetesクラスタの構築とDeployment | kind、kubectl、宣言的デプロイ            |
| 2 | Reconciliation Loopの観察                    | Pod削除→自動復旧                         |
| 3 | スケーリングとローリングアップデート         | replicas変更、イメージ更新、ロールバック |
| 4 | ServiceとDNSによるサービスディスカバリ       | ClusterIP、DNS名、Endpoints              |

## 動作環境

- Docker Desktop または Docker Engine がインストール済みであること
- bash が利用可能な環境（Linux、macOS、WSL2）
- インターネット接続（Dockerイメージの取得に必要）
- 推奨メモリ: 4GB以上

## セットアップ

```bash
chmod +x setup.sh
./setup.sh
```

## クリーンアップ

```bash
kind delete cluster
```

## ライセンス

MIT
