# scripts

tech-chronicles の執筆自動化スクリプト群。

## write-episode.sh

Claude Code CLI をローカルで呼び出し、1エピソード分の執筆からPR作成までを自動実行する。複数エピソードの連続実行に対応しており、回しっぱなしで放置できる。

### 前提条件

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) がインストール済みで認証済みであること
- `gh` CLI が認証済みであること（PR作成に使用）
- `npm ci` 済みであること（lint/format に必要）
- 作業ツリーがクリーンであること（未コミットの変更がないこと）

### 基本的な使い方

```bash
# 単発実行（第8回のみ）
./scripts/write-episode.sh cloud-history 8

# 範囲指定（第8回〜第12回を連続実行）
./scripts/write-episode.sh cloud-history 8-12

# 自動検出（READMEから未執筆エピソードを全て検出して連続実行）
./scripts/write-episode.sh cloud-history
```

### オプション

| オプション      | 説明                                   | デフォルト |
| --------------- | -------------------------------------- | ---------- |
| `-m, --model`   | 使用モデル（`opus` or `sonnet`）       | `opus`     |
| `-n, --dry-run` | 対象エピソードの表示のみ（実行しない） | -          |
| `-h, --help`    | ヘルプ表示                             | -          |

```bash
# sonnet で実行（低コスト）
./scripts/write-episode.sh -m sonnet cloud-history 8

# 対象確認だけ（実行しない）
./scripts/write-episode.sh -n cloud-history
```

### 1エピソードの処理フロー

1. `draft/{series}-{NN}` ブランチを main から作成
2. `claude -p` でプロンプト（`scripts/prompts/write-episode.md`）を投入
3. Claude Code がファクトチェック → 本文執筆 → ハンズオン作成 → README更新 → lint/format を実行
4. 変更を全てコミット
5. ブランチをプッシュし、`gh pr create` でPRを作成
6. main に戻り、次のエピソードへ

### 出力

実行中のコンソール出力:

```
========================================
 Write Episode
========================================
シリーズ:       cloud-history
エピソード:     8 9 10
モデル:         claude-opus-4-6
合計:           3 回
ログ:           /path/to/logs/
========================================

--- Episode 8 ---
ブランチ: draft/cloud-history-08
ログ:     logs/cloud-history-08-20260223-230000.log
開始:     23:00:00
Claude Code 実行中...
[ok] 完了 (38分12秒)

--- Episode 9 ---
...

========================================
 Summary
========================================
所要時間: 1時間52分
成功:     3 (8 9 10)
失敗:     0 (なし)
スキップ: 0 (なし)
========================================
```

### ログ

各エピソードの Claude Code 出力は `logs/` に保存される（`.gitignore` 済み）。

```
logs/cloud-history-08-20260223-230000.log
logs/cloud-history-09-20260223-233812.log
```

失敗時はこのログを確認すること。

### エラー処理

| 状況               | 動作                                     |
| ------------------ | ---------------------------------------- |
| Claude Code が失敗 | ログに記録してスキップ、次のエピソードへ |
| 変更ファイルなし   | ブランチを削除してスキップ               |
| ブランチが既に存在 | そのエピソードをスキップ                 |
| 未コミット変更あり | 開始前にエラー終了                       |

スクリプト終了時、1件でも失敗があれば exit code 1 を返す。

### 運用例

```bash
# 寝る前に cloud-history の残り全部を回す
./scripts/write-episode.sh cloud-history &

# 翌朝、GitHub で PR を確認してレビュー・マージ
```

### 新シリーズの追加

`blueprints/{new-series}.md` がリポジトリに存在すれば、スクリプトの変更なしでそのまま使える。

```bash
./scripts/write-episode.sh web-framework
```

## ディレクトリ構成

```
scripts/
  write-episode.sh              -- 実行スクリプト
  prompts/
    write-episode.md            -- Claude Code に渡すプロンプト
  README.md                     -- このファイル
```
