#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-24"

echo "============================================================"
echo " 第24回ハンズオン：bash ありきの世界を疑え"
echo " あなたは何を選ぶか――シェル選定の評価マトリクス"
echo "============================================================"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo ">>> 基本パッケージのインストール"
# ============================================================
if command -v apt-get > /dev/null 2>&1; then
  apt-get update -qq && apt-get install -y -qq jq file procps > /dev/null 2>&1
  echo "基本パッケージのインストール完了"
else
  echo "apt-get が利用できません。ローカル環境で実行中と判断します。"
  echo "jq が未インストールの場合は手動でインストールしてください。"
fi

# ============================================================
echo ""
echo "============================================================"
echo " 演習1: 現状のシェル構成を可視化する"
echo "============================================================"
echo ""

echo "--- Layer 1: 対話用シェル ---"
echo "  デフォルトシェル: $SHELL"
if [ -n "${BASH_VERSION:-}" ]; then
    echo "  実行中: bash $BASH_VERSION"
elif [ -n "${ZSH_VERSION:-}" ]; then
    echo "  実行中: zsh $ZSH_VERSION"
else
    echo "  実行中: $(ps -p $$ -o comm= 2>/dev/null || echo '不明')"
fi
echo ""

echo "--- 利用可能なシェル ---"
if [ -f /etc/shells ]; then
    grep -v '^#' /etc/shells | grep -v '^$' || true
else
    echo "  /etc/shells が見つかりません"
fi
echo ""

echo "--- /bin/sh の実体 ---"
if [ -L /bin/sh ]; then
    echo "  /bin/sh -> $(readlink -f /bin/sh)"
else
    echo "  /bin/sh はシンボリックリンクではありません"
    file /bin/sh 2>/dev/null || true
fi
echo ""

echo "--- インストール済みシェルのバージョン ---"
for shell in bash zsh fish dash ksh nu; do
    if command -v "$shell" > /dev/null 2>&1; then
        case "$shell" in
            bash) ver=$("$shell" --version 2>/dev/null | head -1) ;;
            zsh)  ver=$("$shell" --version 2>/dev/null) ;;
            fish) ver=$("$shell" --version 2>/dev/null) ;;
            dash) ver="dash (バージョン表示なし)" ;;
            ksh)  ver=$("$shell" --version 2>/dev/null | head -1) ;;
            nu)   ver=$("$shell" --version 2>/dev/null) ;;
        esac
        echo "  $shell: $ver"
    fi
done
echo ""

echo "--- プロンプトツール ---"
if command -v starship > /dev/null 2>&1; then
    echo "  Starship: $(starship --version 2>/dev/null | head -1)"
else
    echo "  Starship: 未インストール"
fi
echo ""

# ============================================================
echo ""
echo "============================================================"
echo " 演習2: シェル選定評価マトリクスの作成"
echo "============================================================"
echo ""

cat > "${WORKDIR}/shell-evaluation-matrix.md" << 'MATRIX'
# シェル選定評価マトリクス

## チーム情報

- チーム名: ________________
- 人数: ____名
- 主要プラットフォーム: [ ] Linux  [ ] macOS  [ ] Windows (WSL)
- 主要コンテナ基盤: [ ] Alpine  [ ] Debian  [ ] distroless  [ ] なし

## Layer 1: 対話用シェル

### 評価基準（1-5点で採点）

| 基準 | bash | zsh | fish | Nushell | 重み |
|------|------|-----|------|---------|------|
| チーム内の習熟度 | __ | __ | __ | __ | x3 |
| 補完の充実度 | __ | __ | __ | __ | x2 |
| 箱出しの体験 | __ | __ | __ | __ | x1 |
| カスタマイズ性 | __ | __ | __ | __ | x1 |
| 起動速度 | __ | __ | __ | __ | x1 |
| 合計(重み付き) | __ | __ | __ | __ | - |

### 結論
- 推奨: ______________
- 方針: [ ] 自由選択  [ ] 推奨あり  [ ] 統一

## Layer 2: スクリプト用シェル

### 評価基準（1-5点で採点）

| 基準 | POSIX sh | bash | Oils/YSH | Python | 重み |
|------|----------|------|----------|--------|------|
| 可搬性 | __ | __ | __ | __ | x3 |
| チーム内の習熟度 | __ | __ | __ | __ | x3 |
| エラー処理の堅牢性 | __ | __ | __ | __ | x2 |
| テスト容易性 | __ | __ | __ | __ | x2 |
| 既存資産との互換性 | __ | __ | __ | __ | x2 |
| 合計(重み付き) | __ | __ | __ | __ | - |

### 結論
- shebang標準: ______________
- bash使用時のルール: ______________
- シェルスクリプト→他言語の切り替え基準: ____行超

## Layer 3: CI/CD・システム用シェル

### 評価基準

| 基準 | 回答 |
|------|------|
| CI/CDのshell指定 | [ ] 明示  [ ] デフォルト任せ |
| Dockerベースイメージ | ______________ |
| /bin/sh の実体を把握 | [ ] はい  [ ] いいえ |
| POSIX準拠テスト | [ ] 実施  [ ] 未実施 |

### 結論
- CI/CD標準シェル: ______________
- Docker内シェル方針: ______________

## 総合判断

### 現在の構成
- 対話: ______________
- スクリプト: ______________
- CI/CD: ______________

### 理想の構成
- 対話: ______________
- スクリプト: ______________
- CI/CD: ______________

### ギャップと移行計画
1. ______________________________________________
2. ______________________________________________
3. ______________________________________________
MATRIX

echo "評価マトリクスを作成しました: ${WORKDIR}/shell-evaluation-matrix.md"
echo ""
echo "テキストエディタで開き、以下の手順で記入してください:"
echo "  1. チーム情報を記入する"
echo "  2. 各Layerの評価基準を1-5点で採点する"
echo "  3. 重みを掛けて合計点を算出する"
echo "  4. 各Layerの推奨シェルを決定する"
echo "  5. 現在の構成と理想の構成のギャップを分析する"
echo ""

# ============================================================
echo ""
echo "============================================================"
echo " 演習3: シェル移行シミュレーション"
echo "============================================================"
echo ""

# テスト用のJSONデータを作成
cat > "${WORKDIR}/shell-history.json" << 'JSON'
[
  {"name": "Thompson shell", "year": 1971, "author": "Ken Thompson", "posix": false, "category": "original"},
  {"name": "Bourne shell", "year": 1979, "author": "Stephen Bourne", "posix": true, "category": "bourne-family"},
  {"name": "C shell", "year": 1979, "author": "Bill Joy", "posix": false, "category": "csh-family"},
  {"name": "Korn shell", "year": 1983, "author": "David Korn", "posix": true, "category": "bourne-family"},
  {"name": "bash", "year": 1989, "author": "Brian Fox", "posix": true, "category": "bourne-family"},
  {"name": "ash", "year": 1989, "author": "Kenneth Almquist", "posix": true, "category": "bourne-family"},
  {"name": "zsh", "year": 1990, "author": "Paul Falstad", "posix": true, "category": "bourne-family"},
  {"name": "fish", "year": 2005, "author": "Axel Liljencrantz", "posix": false, "category": "next-gen"},
  {"name": "PowerShell", "year": 2006, "author": "Jeffrey Snover", "posix": false, "category": "next-gen"},
  {"name": "Nushell", "year": 2019, "author": "Sophia Turner", "posix": false, "category": "next-gen"},
  {"name": "Oils/YSH", "year": 2016, "author": "Andy Chu", "posix": true, "category": "next-gen"},
  {"name": "Elvish", "year": 2016, "author": "Qi Xiao", "posix": false, "category": "next-gen"}
]
JSON

echo "シェルの歴史データを作成しました: ${WORKDIR}/shell-history.json"
echo ""

# --- タスク1: POSIX準拠のシェルだけを抽出 ---
echo "--- タスク1: POSIX準拠のシェルを抽出し、年代順に表示する ---"
echo ""

echo "【bash + jq での実装】"
if command -v jq > /dev/null 2>&1; then
    jq -r '.[] | select(.posix == true) | "\(.year) \(.name) (\(.author))"' \
        "${WORKDIR}/shell-history.json" | sort -n
else
    echo "  (jq がインストールされていません: sudo apt install jq)"
fi
echo ""

echo "【Nushell での実装（参考コマンド）】"
echo '  open shell-history.json | where posix == true | sort-by year | select year name author'
echo ""

# --- タスク2: カテゴリ別の集計 ---
echo "--- タスク2: カテゴリ別にシェルの数を集計する ---"
echo ""

echo "【bash + jq での実装】"
if command -v jq > /dev/null 2>&1; then
    jq -r '.[].category' "${WORKDIR}/shell-history.json" | sort | uniq -c | sort -rn
else
    echo "  (jq がインストールされていません)"
fi
echo ""

echo "【Nushell での実装（参考コマンド）】"
echo '  open shell-history.json | group-by category | transpose category shells | each {|g| {category: $g.category, count: ($g.shells | length)}} | sort-by count -r'
echo ""

# --- タスク3: 年代ごとの集計 ---
echo "--- タスク3: 年代ごとに登場したシェルの数を集計する ---"
echo ""

echo "【bash + jq での実装】"
if command -v jq > /dev/null 2>&1; then
    jq -r '.[].year' "${WORKDIR}/shell-history.json" | \
    while IFS= read -r year; do
        decade=$(( (year / 10) * 10 ))
        echo "${decade}s"
    done | sort | uniq -c | sort -k2n
else
    echo "  (jq がインストールされていません)"
fi
echo ""

echo "【Nushell での実装（参考コマンド）】"
echo '  open shell-history.json | insert decade {|r| $"($r.year // 10 * 10)s"} | group-by decade | transpose decade shells | each {|g| {decade: $g.decade, count: ($g.shells | length)}} | sort-by decade'
echo ""

# --- タスク4: POSIX対応率の計算 ---
echo "--- タスク4: POSIX対応率を算出する ---"
echo ""

echo "【bash + jq での実装】"
if command -v jq > /dev/null 2>&1; then
    total=$(jq 'length' "${WORKDIR}/shell-history.json")
    posix_count=$(jq '[.[] | select(.posix == true)] | length' "${WORKDIR}/shell-history.json")
    non_posix_count=$(jq '[.[] | select(.posix == false)] | length' "${WORKDIR}/shell-history.json")
    echo "  全シェル数: $total"
    echo "  POSIX準拠: $posix_count"
    echo "  POSIX非準拠: $non_posix_count"
    if [ "$total" -gt 0 ]; then
        rate=$((posix_count * 100 / total))
        echo "  POSIX対応率: ${rate}%"
    fi
else
    echo "  (jq がインストールされていません)"
fi
echo ""

echo "【Nushell での実装（参考コマンド）】"
echo '  let data = (open shell-history.json); let total = ($data | length); let posix = ($data | where posix == true | length); print $"POSIX対応率: ($posix * 100 / $total)%"'
echo ""

# ============================================================
echo ""
echo "============================================================"
echo " 演習のまとめ"
echo "============================================================"
echo ""
echo "1. 演習1で自分のシェル環境の現状を把握しました。"
echo "2. 演習2で三層モデルに基づく評価マトリクスを作成しました。"
echo "3. 演習3でJSONデータ処理を通じてbash+jqとNushellの違いを体験しました。"
echo ""
echo "--- ポイント ---"
echo ""
echo "- JSONの処理はbash単体では困難。jqという外部ツールが必要。"
echo "- Nushellは構造化データをネイティブに扱え、記述が直感的。"
echo "- 「どのシェルが最適か」は、扱うデータと目的に依存する。"
echo "- 重要なのは「選んで使う」こと。惰性で使わないこと。"
echo ""
echo "--- 追加課題（任意） ---"
echo ""
echo "以下のシェルをインストールし、同じタスクを実行してみてください:"
echo "  Nushell: cargo install nu (または https://nushell.sh/)"
echo "  fish:    各OSのパッケージマネージャーからインストール"
echo "  Oils:    https://oils.pub/"
echo ""
echo "普段使わないシェルで30分過ごすだけで、"
echo "「自分が何を選んでいるか」の解像度が上がります。"
echo ""
echo "--- 後片付け ---"
echo "作業ディレクトリ: ${WORKDIR}"
echo "評価マトリクス:   ${WORKDIR}/shell-evaluation-matrix.md"
echo "削除するには: rm -rf ${WORKDIR}"
echo ""
echo "============================================================"
echo " ハンズオン完了"
echo "============================================================"
