#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-24"

echo "============================================"
echo " 第24回ハンズオン"
echo " UNIX――技術ではなく設計哲学として"
echo "============================================"
echo ""
echo "作業ディレクトリ: $WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習1: コンポーネントの責務分析"
echo "============================================"
echo ""

mkdir -p "$WORKDIR/src"

echo "--- 架空のモノリシッククラスを作成 ---"
cat > "$WORKDIR/src/app.py" << 'PYTHON'
# 典型的な「モノリシック」なファイル
class UserService:
    def authenticate(self, username, password): pass
    def get_profile(self, user_id): pass
    def update_profile(self, user_id, data): pass
    def send_notification(self, user_id, message): pass
    def generate_report(self, user_id): pass
    def export_to_csv(self, user_id): pass
    def validate_email(self, email): pass
    def reset_password(self, user_id): pass
    def log_activity(self, user_id, action): pass
    def check_permission(self, user_id, resource): pass
PYTHON

echo "UserServiceクラスのメソッド数:"
grep -c "def " "$WORKDIR/src/app.py"
echo ""
echo "メソッド一覧:"
grep "def " "$WORKDIR/src/app.py" | sed 's/.*def /  - /' | sed 's/(.*/:/'
echo ""
echo "問い: この10個のメソッドは、単一の責務に属するか？"
echo "      UNIXコマンドなら、これは10個の独立したコマンドになるだろう。"
echo ""

echo "--- UNIX哲学に基づく分割案 ---"
cat > "$WORKDIR/src/refactored_structure.txt" << 'TEXT'
UNIX哲学に基づく責務分割:

モノリシック:
  UserService (10メソッド)
    ├── authenticate()      → 認証
    ├── get_profile()       → プロフィール取得
    ├── update_profile()    → プロフィール更新
    ├── send_notification() → 通知送信
    ├── generate_report()   → レポート生成
    ├── export_to_csv()     → CSV出力
    ├── validate_email()    → メール検証
    ├── reset_password()    → パスワードリセット
    ├── log_activity()      → 活動ログ
    └── check_permission()  → 権限チェック

UNIX的分割:
  AuthService         → authenticate(), reset_password()
  ProfileService      → get_profile(), update_profile()
  NotificationService → send_notification()
  ReportService       → generate_report(), export_to_csv()
  ValidationService   → validate_email()
  AuditService        → log_activity()
  PermissionService   → check_permission()

UNIXコマンドとのアナロジー:
  grep  = AuthService     (認証というパターンマッチング)
  cat   = ProfileService  (データの読み書き)
  mail  = NotificationService (メッセージ送信)
  awk   = ReportService   (データの集計・変換)
  test  = ValidationService (条件の検証)
  logger = AuditService   (ログの記録)
  chmod = PermissionService (権限の制御)
TEXT

cat "$WORKDIR/src/refactored_structure.txt"

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習2: インタフェースの統一性チェック"
echo "============================================"
echo ""

mkdir -p "$WORKDIR/config"

echo "--- APIインタフェース定義を作成 ---"
cat > "$WORKDIR/config/interfaces.json" << 'JSON'
{
  "services": [
    {
      "name": "UserAPI",
      "endpoints": [
        {"method": "GET",    "path": "/users/{id}",     "response": "JSON"},
        {"method": "PUT",    "path": "/users/{id}",     "response": "JSON"},
        {"method": "DELETE", "path": "/users/{id}",     "response": "JSON"}
      ]
    },
    {
      "name": "OrderAPI",
      "endpoints": [
        {"method": "POST",   "path": "/orders",          "response": "JSON"},
        {"method": "GET",    "path": "/orders/{id}",     "response": "JSON"},
        {"method": "PATCH",  "path": "/order/update",    "response": "XML"}
      ]
    },
    {
      "name": "NotificationAPI",
      "endpoints": [
        {"method": "POST",   "path": "/notify/send",     "response": "plain text"},
        {"method": "GET",    "path": "/notify/history",   "response": "CSV"}
      ]
    }
  ]
}
JSON

echo "レスポンスフォーマットの不統一を検出:"
echo ""
jq -r '.services[] | .name as $svc |
  .endpoints[] | "\($svc): \(.method) \(.path) -> \(.response)"' "$WORKDIR/config/interfaces.json"
echo ""
echo "--- 問題点 ---"
jq -r '.services[] | .name as $svc |
  .endpoints[] | select(.response != "JSON") |
  "  警告: \($svc) の \(.method) \(.path) は \(.response) を返す（JSONではない）"' "$WORKDIR/config/interfaces.json"
echo ""
echo "UNIXの原則: すべてのコマンドはテキストストリームを入出力とする。"
echo "現代の翻訳: すべてのAPIはJSON（または統一フォーマット）を入出力とする。"

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習3: 設計レビューチェックリスト"
echo "============================================"
echo ""

cat > "$WORKDIR/checklist.md" << 'MARKDOWN'
# UNIX哲学 設計レビューチェックリスト

## 基本5原則

### 1. シンプルさを選べ (Complexity is the enemy)
- [ ] このコンポーネントの責務を一文で説明できるか？
- [ ] 不要な機能や「将来使うかもしれない」機能を含んでいないか？
- [ ] 設定項目は必要最小限か？

### 2. 合成可能に作れ (Composability over monolithics)
- [ ] このコンポーネントは他のコンポーネントと組み合わせ可能か？
- [ ] 入力と出力のフォーマットは他のコンポーネントと互換性があるか？
- [ ] 外部依存は最小限か？

### 3. インタフェースを統一せよ (Uniform interface)
- [ ] すべてのコンポーネントが同じインタフェース規約に従っているか？
- [ ] エラーレスポンスのフォーマットは統一されているか？
- [ ] 命名規則は一貫しているか？

### 4. テキストで表現せよ (Human-readable data)
- [ ] 設定ファイルは人間が読める形式か？
- [ ] ログは構造化テキスト（JSON等）で出力されているか？
- [ ] データはdiffで差分確認可能か？

### 5. 制約を受け入れよ (Constraints breed creativity)
- [ ] 「あったら便利」な機能を安易に追加していないか？
- [ ] 技術選定で「何でもできる」ものより「一つのことに特化した」ものを選んでいるか？
- [ ] 制約を設計の味方にできているか？

## 追加チェック（McIlroyの原則より）

### 6. 愚かなパイプ (Dumb pipes)
- [ ] 通信層にビジネスロジックが漏れていないか？
- [ ] メッセージブローカーやAPIゲートウェイが肥大化していないか？

### 7. 早期プロトタイプ (Prototype early)
- [ ] 設計を数週間以内に検証できる方法はあるか？
- [ ] 最小限の実装で仮説を検証しているか？

### 8. 捨てる覚悟 (Throw away and rebuild)
- [ ] 技術的負債を抱えたまま機能追加を続けていないか？
- [ ] 作り直す判断を先送りにしていないか？
MARKDOWN

cat "$WORKDIR/checklist.md"

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習完了"
echo "============================================"
echo ""
echo "作成されたファイル:"
echo "  $WORKDIR/src/app.py                    -- モノリシッククラスの例"
echo "  $WORKDIR/src/refactored_structure.txt   -- UNIX的分割案"
echo "  $WORKDIR/config/interfaces.json         -- APIインタフェース定義"
echo "  $WORKDIR/checklist.md                   -- 設計レビューチェックリスト"
echo ""
echo "このチェックリストを、あなた自身のプロジェクトの"
echo "コードレビューやアーキテクチャレビューで使ってみてほしい。"
echo ""
echo "UNIXを使えとは言わない。"
echo "UNIXの設計哲学を「知って」使え。"
