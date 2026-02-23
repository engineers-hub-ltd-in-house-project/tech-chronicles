#!/bin/bash
# scripts/write-episode.sh
#
# tech-chronicles 連載記事の自動執筆スクリプト
# Claude Code CLI をローカルで呼び出し、1エピソードずつ処理する
#
# Usage:
#   ./scripts/write-episode.sh <series> [episode] [-m model]
#
# Examples:
#   ./scripts/write-episode.sh cloud-history 8        # 第8回のみ
#   ./scripts/write-episode.sh cloud-history 8-12     # 第8-12回を連続
#   ./scripts/write-episode.sh cloud-history           # 未執筆を全自動検出

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs"
PROMPT_FILE="$SCRIPT_DIR/prompts/write-episode.md"

MODEL="opus"
DRY_RUN=false

usage() {
  cat <<'EOF'
Usage: write-episode.sh [options] <series> [episode]

Arguments:
  series    シリーズ名 (例: cloud-history, web-framework)
  episode   エピソード番号 | 範囲 | 省略で自動検出
            例: 8, 8-12, (省略 = auto)

Options:
  -m, --model MODEL   opus | sonnet (default: opus)
  -n, --dry-run       実行せず対象エピソードを表示
  -h, --help          ヘルプ
EOF
}

# --- Parse options ---

while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--model) MODEL="$2"; shift 2 ;;
    -n|--dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "Error: 不明なオプション: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

SERIES="${1:?Error: シリーズ名を指定してください。 ./scripts/write-episode.sh --help で使い方を確認}"
EPISODE_ARG="${2:-auto}"

# --- Validate ---

if [[ ! -f "$PROJECT_ROOT/blueprints/${SERIES}.md" ]]; then
  echo "Error: blueprints/${SERIES}.md が見つかりません"
  echo "利用可能なシリーズ:"
  find "$PROJECT_ROOT/blueprints" -maxdepth 1 -name '*.md' \
    ! -name '_template.md' ! -name 'README.md' \
    -exec basename {} .md \; | sort | sed 's/^/  /'
  exit 1
fi

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Error: プロンプトファイルが見つかりません: $PROMPT_FILE"
  exit 1
fi

case "$MODEL" in
  opus)   MODEL_ID="claude-opus-4-6" ;;
  sonnet) MODEL_ID="claude-sonnet-4-6" ;;
  *) echo "Error: 不明なモデル: $MODEL (opus|sonnet)"; exit 1 ;;
esac

# --- Episode detection ---

detect_pending_episodes() {
  local readme="$PROJECT_ROOT/series/${SERIES}/ja/README.md"
  if [[ ! -f "$readme" ]]; then
    echo "1"
    return
  fi
  grep -oP '第\K[0-9]+(?=回.*執筆予定)' "$readme" || true
}

build_episode_list() {
  local arg="$1"
  if [[ "$arg" == "auto" ]]; then
    detect_pending_episodes
  elif [[ "$arg" =~ ^([0-9]+)-([0-9]+)$ ]]; then
    seq "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
  elif [[ "$arg" =~ ^[0-9]+$ ]]; then
    echo "$arg"
  else
    echo "Error: 不正なエピソード指定: $arg" >&2
    exit 1
  fi
}

# --- Setup ---

mkdir -p "$LOG_DIR"
mapfile -t EPISODES < <(build_episode_list "$EPISODE_ARG")

if [[ ${#EPISODES[@]} -eq 0 ]]; then
  echo "執筆対象のエピソードがありません（全回公開済み?）"
  exit 0
fi

echo "========================================"
echo " Write Episode"
echo "========================================"
echo "シリーズ:       $SERIES"
echo "エピソード:     ${EPISODES[*]}"
echo "モデル:         $MODEL_ID"
echo "合計:           ${#EPISODES[@]} 回"
echo "ログ:           $LOG_DIR/"
echo "========================================"
echo ""

if [[ "$DRY_RUN" == true ]]; then
  echo "[dry-run] 上記の対象を処理します。-n を外して再実行してください。"
  exit 0
fi

# Ensure clean working tree
if [[ -n "$(git -C "$PROJECT_ROOT" status --porcelain)" ]]; then
  echo "Error: 作業ツリーにコミットされていない変更があります"
  echo "先にコミットまたはスタッシュしてください"
  exit 1
fi

MAIN_BRANCH="$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD)"

SUCCEEDED=()
FAILED=()
SKIPPED=()
START_TIME=$(date +%s)

# --- Main loop ---

for EP in "${EPISODES[@]}"; do
  NN=$(printf "%02d" "$EP")
  BRANCH="draft/${SERIES}-${NN}"
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  LOG_FILE="$LOG_DIR/${SERIES}-${NN}-${TIMESTAMP}.log"
  EP_START=$(date +%s)

  echo "--- Episode ${EP} ---"
  echo "ブランチ: $BRANCH"
  echo "ログ:     $LOG_FILE"
  echo "開始:     $(date '+%H:%M:%S')"

  # Skip if branch already exists
  if git -C "$PROJECT_ROOT" show-ref --verify --quiet "refs/heads/$BRANCH" 2>/dev/null; then
    echo "[skip] ブランチ $BRANCH は既に存在します"
    SKIPPED+=("$EP")
    echo ""
    continue
  fi

  # Create branch from main
  cd "$PROJECT_ROOT"
  git checkout -b "$BRANCH" "$MAIN_BRANCH" >> "$LOG_FILE" 2>&1

  # Build prompt
  PROMPT="$(cat "$PROMPT_FILE")

---

シリーズ: ${SERIES}
エピソード: ${EP}"

  # Run Claude Code
  echo "Claude Code 実行中..."
  if claude -p "$PROMPT" \
    --model "$MODEL_ID" \
    --max-turns 80 \
    >> "$LOG_FILE" 2>&1; then

    # Check if files were actually created/modified
    if [[ -z "$(git -C "$PROJECT_ROOT" status --porcelain)" ]]; then
      echo "[skip] 変更ファイルなし"
      git checkout "$MAIN_BRANCH" >> "$LOG_FILE" 2>&1
      git branch -d "$BRANCH" >> "$LOG_FILE" 2>&1
      SKIPPED+=("$EP")
      echo ""
      continue
    fi

    # Commit
    git add -A >> "$LOG_FILE" 2>&1
    git commit -m "feat: Add ${SERIES} series episode ${EP} with fact-check and handson" >> "$LOG_FILE" 2>&1

    # Push and create PR
    git push -u origin "$BRANCH" >> "$LOG_FILE" 2>&1
    gh pr create \
      --base "$MAIN_BRANCH" \
      --title "feat: Add ${SERIES} series episode ${EP} with fact-check and handson" \
      --body "$(cat <<PREOF
## Summary

- ${SERIES} シリーズ 第${EP}回の記事、ファクトチェック、ハンズオンを追加

## Generated by

Claude Code (write-episode.sh)

## Review Checklist

- [ ] 記事内容・品質
- [ ] ファクトチェック記録
- [ ] ハンズオン動作確認
- [ ] README更新
- [ ] lint/format結果
PREOF
)" >> "$LOG_FILE" 2>&1

    EP_END=$(date +%s)
    EP_DURATION=$(( EP_END - EP_START ))
    echo "[ok] 完了 ($(( EP_DURATION / 60 ))分$(( EP_DURATION % 60 ))秒)"
    SUCCEEDED+=("$EP")

  else
    EP_END=$(date +%s)
    EP_DURATION=$(( EP_END - EP_START ))
    echo "[fail] Claude Code 実行失敗 ($(( EP_DURATION / 60 ))分$(( EP_DURATION % 60 ))秒)"
    echo "       詳細: $LOG_FILE"
    FAILED+=("$EP")
  fi

  # Return to main
  git checkout "$MAIN_BRANCH" >> "$LOG_FILE" 2>&1
  echo ""
done

# --- Summary ---

END_TIME=$(date +%s)
TOTAL_DURATION=$(( END_TIME - START_TIME ))

echo "========================================"
echo " Summary"
echo "========================================"
echo "所要時間: $(( TOTAL_DURATION / 3600 ))時間$(( (TOTAL_DURATION % 3600) / 60 ))分"
echo "成功:     ${#SUCCEEDED[@]} (${SUCCEEDED[*]:-なし})"
echo "失敗:     ${#FAILED[@]} (${FAILED[*]:-なし})"
echo "スキップ: ${#SKIPPED[@]} (${SKIPPED[*]:-なし})"
echo "========================================"

# Exit with error if any failed
[[ ${#FAILED[@]} -eq 0 ]]
