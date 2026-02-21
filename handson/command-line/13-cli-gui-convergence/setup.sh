#!/bin/bash
# =============================================================================
# 第13回ハンズオン：キーボード駆動のGUIパターンを体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: fzf, git, curl (スクリプトが自動インストール)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/command-line-handson-13"

echo "=== 第13回ハンズオン：キーボード駆動のGUIパターンを体験する ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
    echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
    rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}/project"

# --- 依存ツールのインストール ---
echo "[準備] 必要なツールをインストール中..."
apt-get update -qq && apt-get install -y -qq fzf git curl > /dev/null 2>&1
echo "  fzf, git, curl をインストール完了"
echo ""

# --- テスト用ファイルツリーの生成 ---
echo "[準備] テスト用プロジェクトを生成中..."
cd "${WORKDIR}/project"

for dir in src lib test docs config scripts; do
    mkdir -p "$dir"
done

# 各ディレクトリにファイルを生成
for i in $(seq 1 10); do
    echo "// Application source file ${i}" > "src/app_module_${i}.js"
    echo "// Library file ${i}" > "lib/utils_${i}.py"
    echo "// Test file ${i}" > "test/test_module_${i}.rb"
    echo "# Documentation ${i}" > "docs/guide_${i}.md"
    echo "# Config file ${i}" > "config/settings_${i}.yaml"
    echo "#!/bin/bash" > "scripts/deploy_${i}.sh"
done

# 特別なファイル
echo "# README" > README.md
echo "FROM ubuntu:24.04" > Dockerfile
echo '{"name": "demo"}' > package.json
echo ".env" > .gitignore

echo "  $(find . -type f | wc -l) 個のファイルを生成"
echo ""

# --- コマンド履歴の模擬データ ---
cat > "${WORKDIR}/history.txt" << 'EOF'
git status
git log --oneline -20
git diff HEAD~1
git checkout -b feature/new-api
git merge develop
docker ps -a
docker run -it ubuntu:24.04 bash
docker-compose up -d
docker build -t myapp .
docker logs api-server
kubectl get pods -n production
kubectl logs deploy/api-server
kubectl apply -f deployment.yaml
npm install
npm run test
npm run build
npm run lint
grep -rn "TODO" src/
grep -rn "FIXME" lib/
find . -name "*.log" -mtime -7
find . -name "*.py" -exec wc -l {} +
ssh web-server-01
ssh db-server-prod
terraform plan
terraform apply
ansible-playbook deploy.yaml
EOF

echo "[準備] コマンド履歴の模擬データを生成: history.txt"
echo ""

# === 演習1: fzfによるfuzzy matching ===
echo "================================================================"
echo "[演習1] fzfによるfuzzy matching"
echo "================================================================"
echo ""

cd "${WORKDIR}/project"

echo "--- 従来のfindによる検索 ---"
echo '$ find . -type f -name "*config*"'
find . -type f -name "*config*"
echo ""

echo "--- fzfのfuzzy matching（--filterモード）---"
echo '$ find . -type f | fzf --filter "cnfg"'
find . -type f | fzf --filter "cnfg" | head -5
echo ""
echo "ポイント: 'cnfg'という不正確な入力でもconfigがマッチする"
echo ""

echo "--- さらに曖昧な入力 ---"
echo '$ find . -type f | fzf --filter "tst"'
find . -type f | fzf --filter "tst" | head -5
echo ""
echo "ポイント: 'tst'でtest/ディレクトリのファイルがマッチする"
echo ""

echo "--- 従来のgrepとの比較 ---"
echo '$ find . -type f | grep "config"  # 完全一致のみ'
find . -type f | grep "config" | head -5
echo ""
echo '$ find . -type f | fzf --filter "cnfg"  # fuzzy matching'
find . -type f | fzf --filter "cnfg" | head -5
echo ""
echo "→ grepは正確な文字列が必要。fzfは断片的な記憶で十分"
echo ""

# === 演習2: fzfとパイプラインの組み合わせ ===
echo "================================================================"
echo "[演習2] fzfとパイプラインの組み合わせ"
echo "================================================================"
echo ""

cd "${WORKDIR}"

echo "--- コマンド履歴のfuzzy検索 ---"
echo '$ cat history.txt | fzf --filter "dkr"'
cat history.txt | fzf --filter "dkr"
echo ""
echo "ポイント: 'dkr'でdocker関連コマンドがすべてマッチ"
echo ""

echo "--- kubectlコマンドの検索 ---"
echo '$ cat history.txt | fzf --filter "kub"'
cat history.txt | fzf --filter "kub"
echo ""

echo "--- gitコマンドの検索 ---"
echo '$ cat history.txt | fzf --filter "gch"'
cat history.txt | fzf --filter "gch"
echo ""
echo "ポイント: 'gch'で'git checkout'がマッチする"
echo ""

echo "--- パイプラインの実用例 ---"
echo ""
echo "# ファイルをfuzzyに選んで内容を表示:"
echo '  find . -type f | fzf | xargs cat'
echo ""
echo "# gitブランチをfuzzyに選んでcheckout:"
echo '  git branch | fzf | xargs git checkout'
echo ""
echo "# コマンド履歴からfuzzyに選んで実行:"
echo '  cat history.txt | fzf | sh'
echo ""
echo "→ fzfはstdin/stdoutの原則に従う"
echo "   パイプラインのどこにでも挿入可能"
echo ""

# === 演習3: dmenuパターンのCLI再現 ===
echo "================================================================"
echo "[演習3] dmenuパターンのCLI再現"
echo "================================================================"
echo ""

echo "dmenuの設計思想: リスト生成 | 絞り込み | 実行"
echo "これをfzfでCLI上に再現する"
echo ""

# コマンドパレットスクリプトの作成
cat > "${WORKDIR}/palette.sh" << 'SCRIPT'
#!/bin/bash
# 簡易コマンドパレット（fzf使用）
# 使い方: ./palette.sh [検索文字列]
set -euo pipefail

COMMANDS="Show disk usage:df -h
List running processes:ps aux --sort=-%mem | head -20
Show network connections:ss -tuln
Show system info:uname -a
Show memory usage:free -h
Show current date:date '+%Y-%m-%d %H:%M:%S'
Show environment variables:env | sort | head -20
Show logged-in users:who
Show uptime:uptime
List installed packages:dpkg --list | wc -l
Show PATH directories:echo \$PATH | tr ':' '\n'
Count files in current dir:find . -type f | wc -l"

if [ $# -gt 0 ]; then
    SELECTED=$(echo "$COMMANDS" | fzf --filter "$1" | head -1)
else
    SELECTED=$(echo "$COMMANDS" | fzf --delimiter=":" --with-nth=1)
fi

if [ -n "$SELECTED" ]; then
    NAME="${SELECTED%%:*}"
    CMD="${SELECTED#*:}"
    echo "=== ${NAME} ==="
    echo "$ ${CMD}"
    echo "---"
    eval "$CMD"
fi
SCRIPT
chmod +x "${WORKDIR}/palette.sh"

echo "--- 簡易コマンドパレットを作成 ---"
echo ""
echo "palette.sh: コマンドを'表示名:実行コマンド'で定義し"
echo "fzfで絞り込んで実行するスクリプト"
echo ""

echo "--- 実行例1: 'disk' で検索 ---"
"${WORKDIR}/palette.sh" "disk" 2>/dev/null || true
echo ""

echo "--- 実行例2: 'mem' で検索 ---"
"${WORKDIR}/palette.sh" "mem" 2>/dev/null || true
echo ""

echo "--- 実行例3: 'sys' で検索 ---"
"${WORKDIR}/palette.sh" "sys" 2>/dev/null || true
echo ""

echo "--- 実行例4: 'pkg' で検索 ---"
"${WORKDIR}/palette.sh" "pkg" 2>/dev/null || true
echo ""

echo "=== このパターンの本質 ==="
echo ""
echo "1. コマンド一覧をテキストとして定義"
echo "2. fzfでfuzzy matchingにより絞り込み"
echo "3. 選択結果をパイプで次の処理に渡す"
echo ""
echo "→ VS CodeのCommand Paletteと同じUIパターン"
echo "   ただしCLIのstdin/stdout原則に従うため"
echo "   組み合わせ・拡張が自由"
echo ""

echo "================================================================"
echo "=== ハンズオン完了 ==="
echo "================================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ポイント:"
echo "  1. fzfはfuzzy matchingをCLIに持ち込んだ"
echo "     → GUIのCommand Paletteと同じ認知モデル"
echo "  2. fzfはstdin/stdoutに従うため、パイプラインの部品になる"
echo "     → CLIの組み合わせ可能性を保ったまま発見しやすさを追加"
echo "  3. 'リスト | 絞り込み | 実行' はdmenuパターン"
echo "     → UNIXパイプラインの文法でGUIランチャーを実現"
echo ""
echo "対話モードで試すには:"
echo "  cd ${WORKDIR}/project"
echo "  find . -type f | fzf        # ファイルをfuzzy検索"
echo "  cat ../history.txt | fzf    # コマンド履歴をfuzzy検索"
echo "  ../palette.sh               # コマンドパレット（対話モード）"
