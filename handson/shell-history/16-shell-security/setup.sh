#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-16"

echo "============================================"
echo " 第16回ハンズオン: シェルとセキュリティ"
echo " インジェクション、eval、権限昇格"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

# -------------------------------------------
# セクション1: 作業ディレクトリの準備
# -------------------------------------------
echo "--- セクション1: 作業ディレクトリの準備 ---"
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# 必要なパッケージのインストール
echo "必要なパッケージをインストール中..."
if command -v apt-get >/dev/null 2>&1; then
    apt-get update -qq && apt-get install -y -qq shellcheck >/dev/null 2>&1
    echo "パッケージインストール完了"
elif command -v shellcheck >/dev/null 2>&1; then
    echo "ShellCheck は既にインストール済み"
else
    echo "警告: ShellCheck をインストールできません。演習4はスキップされます。"
fi
echo ""

# -------------------------------------------
# セクション2: 演習1 - シェルインジェクションの基本
# -------------------------------------------
echo "=== 演習1: シェルインジェクションの基本 ==="
echo ""

# テストデータの作成
mkdir -p "${WORKDIR}/data"
echo "alice: engineer" > "${WORKDIR}/data/users.txt"
echo "bob: designer" >> "${WORKDIR}/data/users.txt"
echo "charlie: manager" >> "${WORKDIR}/data/users.txt"
echo "secret_token=abc123" > "${WORKDIR}/data/config.txt"
echo "db_password=hunter2" >> "${WORKDIR}/data/config.txt"

# 脆弱なスクリプトの作成
cat << 'VULN_SCRIPT' > "${WORKDIR}/vulnerable_grep.sh"
#!/bin/sh
# 脆弱なスクリプト: 変数がクォートされていない
pattern=$1
echo "検索パターン: $pattern"
echo "--- 結果 ---"
grep -r $pattern ./data/ 2>/dev/null || echo "(マッチなし)"
VULN_SCRIPT
chmod +x "${WORKDIR}/vulnerable_grep.sh"

# 安全なスクリプトの作成
cat << 'SAFE_SCRIPT' > "${WORKDIR}/safe_grep.sh"
#!/bin/sh
# 安全なスクリプト: 変数がクォートされ、--でオプション終端
pattern="$1"
echo "検索パターン: $pattern"
echo "--- 結果 ---"
grep -r -- "$pattern" ./data/ 2>/dev/null || echo "(マッチなし)"
SAFE_SCRIPT
chmod +x "${WORKDIR}/safe_grep.sh"

echo "--- テスト1: 正常な入力 ---"
cd "${WORKDIR}"
./vulnerable_grep.sh "alice"

echo ""
echo "--- テスト2: ワード分割による意図しない検索（脆弱版）---"
echo "入力: 'alice ./data/config.txt'"
./vulnerable_grep.sh "alice ./data/config.txt"
echo ""
echo "【解説】クォートなしの変数展開により、パターンが'alice'と"
echo "'./data/config.txt'の2つの引数に分割された。"
echo "grepは'alice'を./data/config.txtからも検索し、意図しないファイルの内容が露出する。"

echo ""
echo "--- テスト3: 同じ入力を安全版で実行 ---"
./safe_grep.sh "alice ./data/config.txt"
echo ""
echo "【解説】ダブルクォートにより、パターン全体が一つの文字列として扱われる。"
echo "'alice ./data/config.txt'という文字列は存在しないためマッチしない。"
echo ""

# -------------------------------------------
# セクション3: 演習2 - evalの危険性
# -------------------------------------------
echo "=== 演習2: evalの危険性 ==="
echo ""

echo "--- evalの二重解析の可視化 ---"
echo ""
echo "通常のecho:"
var='hello; echo INJECTED'
echo "  echo \"\$var\" の結果: $var"
echo "  → セミコロンは文字列の一部として表示される"
echo ""
echo "evalを使った場合の解析過程:"
echo "  eval echo \"\$var\" が実行するコマンド:"
echo "  → 第1段階: eval echo \"hello; echo INJECTED\""
echo "  → 第2段階: echo hello; echo INJECTED"
echo "  → 結果: 2つのコマンドとして実行される"
echo ""
echo "実行結果:"
eval echo "$var"
echo ""
echo "【解説】'INJECTED' が別コマンドとして実行された。"
echo "evalは受け取った文字列をシェルコマンドとして再解析するため、"
echo "メタ文字（セミコロン等）がコマンド区切りとして機能する。"

echo ""
echo "--- 安全な代替: caseによるホワイトリスト方式 ---"
echo ""

cat << 'SAFE_CONFIG' > "${WORKDIR}/safe_config.sh"
#!/bin/sh
# evalを使わない安全な設定読み込み

config_name=""
config_email=""
config_role=""

while IFS='=' read -r key value; do
    case "$key" in
        name)  config_name="$value" ;;
        email) config_email="$value" ;;
        role)  config_role="$value" ;;
        *)     echo "  [警告] 未知のキー '$key' を無視" >&2 ;;
    esac
done << 'CONFIG'
name=John Doe
email=john@example.com
role=engineer
malicious='; rm -rf / #
CONFIG

echo "  name  = $config_name"
echo "  email = $config_email"
echo "  role  = $config_role"
echo "  （悪意ある入力は安全に無視された）"
SAFE_CONFIG
chmod +x "${WORKDIR}/safe_config.sh"
sh "${WORKDIR}/safe_config.sh"
echo ""

# -------------------------------------------
# セクション4: 演習3 - Shellshockの仕組み
# -------------------------------------------
echo "=== 演習3: Shellshockの仕組み ==="
echo ""

echo "--- 現在のbashバージョン ---"
echo "bash: ${BASH_VERSION}"
echo ""

echo "--- Shellshock脆弱性テスト ---"
echo "テストコマンド: env x='() { :;}; echo VULNERABLE' bash -c 'echo safe'"
result=$(env x='() { :;}; echo VULNERABLE' bash -c 'echo safe' 2>&1)
echo "結果: $result"
echo ""

if echo "$result" | grep -q "VULNERABLE"; then
    echo "[!] この環境はShellshockに対して脆弱です"
else
    echo "[OK] Shellshockパッチが適用済み -- 安全です"
fi

echo ""
echo "--- bashの関数エクスポート機能（正常な使い方）---"
echo ""
echo "親シェルで関数を定義:"
echo '  greet() { echo "Hello, $1!"; }'
echo '  export -f greet'
echo ""

greet() { echo "Hello, $1!"; }
export -f greet
echo "子プロセスから関数を呼び出し:"
echo -n "  "
bash -c 'greet "World"'
unset -f greet

echo ""
echo "--- 関数エクスポートの環境変数形式 ---"
demo_func() { echo "demo"; }
export -f demo_func
echo "パッチ後のbashでは、関数は以下の形式で環境変数に格納される:"
env | grep -F "BASH_FUNC" | head -3 || echo "  BASH_FUNC_demo_func%%=() { echo \"demo\"; }"
unset -f demo_func

echo ""
echo "--- Shellshockの攻撃メカニズム解説 ---"
echo ""
echo "  [脆弱なbash（パッチ前）]"
echo "  ┌──────────────────────────────────────────────┐"
echo "  │ 環境変数: x='() { :;}; malicious_command'    │"
echo "  │                                              │"
echo "  │ bashの処理:                                  │"
echo "  │   1. 値が '() {' で始まる → 関数定義と判断  │"
echo "  │   2. () { :; } を関数として登録              │"
echo "  │   3. ★バグ★ 残りも実行: malicious_command   │"
echo "  └──────────────────────────────────────────────┘"
echo ""
echo "  [修正済みbash（パッチ後）]"
echo "  ┌──────────────────────────────────────────────┐"
echo "  │ チェック1: 変数名が BASH_FUNC_*%% 形式か?    │"
echo "  │   → NO → 関数として解釈しない（安全）       │"
echo "  │   → YES → 関数定義のみ解析                  │"
echo "  │ チェック2: 関数定義の後にコマンドがあるか?    │"
echo "  │   → YES → 処理を中断（安全）                │"
echo "  └──────────────────────────────────────────────┘"
echo ""

# -------------------------------------------
# セクション5: 演習4 - ShellCheckによるセキュリティ監査
# -------------------------------------------
echo "=== 演習4: ShellCheckによるセキュリティ監査 ==="
echo ""

if ! command -v shellcheck >/dev/null 2>&1; then
    echo "ShellCheck が見つかりません。この演習をスキップします。"
else

# セキュリティ問題を含むスクリプト
cat << 'INSECURE' > "${WORKDIR}/insecure.sh"
#!/bin/bash
# 意図的にセキュリティ問題を含むスクリプト

# 問題1: 未クォートの変数展開（SC2086）
filename=$1
cat $filename

# 問題2: 未クォートのコマンド置換（SC2046）
rm $(find /tmp -name "*.tmp" -mtime +7)

# 問題3: lsの出力をパースする（SC2012）
for f in $(ls /tmp/); do
    echo "$f"
done
INSECURE

echo "--- セキュリティ問題を含むスクリプト ---"
cat "${WORKDIR}/insecure.sh"
echo ""
echo "--- ShellCheck の診断結果 ---"
shellcheck "${WORKDIR}/insecure.sh" 2>&1 || true

echo ""
echo "--- 修正版スクリプト ---"
cat << 'SECURE' > "${WORKDIR}/secure.sh"
#!/bin/bash
set -euo pipefail

# 修正1: ダブルクォートで囲み、--でオプション終端
filename="${1:?ファイル名を指定してください}"
cat -- "$filename"

# 修正2: findの-execで安全にファイル処理
find /tmp -name "*.tmp" -mtime +7 -exec rm -- {} +

# 修正3: グロブで直接ファイルを列挙
for f in /tmp/*; do
    [ -e "$f" ] || continue
    echo "${f##*/}"
done
SECURE

cat "${WORKDIR}/secure.sh"
echo ""
echo "--- 修正版の ShellCheck 診断結果 ---"
shellcheck "${WORKDIR}/secure.sh" 2>&1 && echo "[OK] ShellCheck: 問題なし" || true

fi
echo ""

# -------------------------------------------
# セクション6: まとめ
# -------------------------------------------
echo "============================================"
echo " ハンズオン完了"
echo "============================================"
echo ""
echo "学んだこと:"
echo "  1. クォーティングの有無がセキュリティに直結する"
echo "  2. evalは二重解析により任意コマンド実行を許す"
echo "  3. Shellshockはデータ（環境変数）をコード（関数定義）として"
echo "     評価する設計に起因する25年間の潜伏バグだった"
echo "  4. ShellCheckで多くのセキュリティ問題を静的に検出できる"
echo ""
echo "安全なシェルスクリプティングの原則:"
echo "  - 変数展開は必ずダブルクォートで囲む"
echo "  - evalを使わない"
echo "  - -- でオプション終端を明示する"
echo "  - set -euo pipefail を先頭に置く"
echo "  - ShellCheck で静的解析する"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
