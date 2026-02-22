#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-22"

echo "============================================================"
echo " 第22回ハンズオン：PowerShellという異なるパラダイム"
echo " オブジェクトパイプラインの世界"
echo "============================================================"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo ">>> 基本パッケージのインストール"
# ============================================================
apt-get update -qq && apt-get install -y -qq wget apt-transport-https software-properties-common jq > /dev/null 2>&1
echo "基本パッケージのインストール完了"

# ============================================================
echo ""
echo ">>> PowerShellのインストール"
# ============================================================
if ! command -v pwsh > /dev/null 2>&1; then
  echo "PowerShell をインストール中..."
  wget -q "https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb" -O /tmp/packages-microsoft-prod.deb
  dpkg -i /tmp/packages-microsoft-prod.deb
  rm /tmp/packages-microsoft-prod.deb
  apt-get update -qq && apt-get install -y -qq powershell > /dev/null 2>&1
  echo "PowerShell インストール完了: $(pwsh --version)"
else
  echo "PowerShell は既にインストール済み: $(pwsh --version)"
fi

# ============================================================
echo ""
echo ">>> サンプルデータの作成"
# ============================================================

cat > "${WORKDIR}/servers.json" << 'EOF'
[
  {"name": "web-01", "region": "us-east", "cpu": 45.2, "memory": 72.1, "status": "running"},
  {"name": "web-02", "region": "us-east", "cpu": 78.9, "memory": 88.3, "status": "running"},
  {"name": "db-01", "region": "us-west", "cpu": 23.1, "memory": 95.7, "status": "running"},
  {"name": "db-02", "region": "us-west", "cpu": 12.4, "memory": 45.2, "status": "stopped"},
  {"name": "api-01", "region": "eu-west", "cpu": 67.3, "memory": 62.8, "status": "running"},
  {"name": "api-02", "region": "eu-west", "cpu": 91.2, "memory": 78.5, "status": "running"},
  {"name": "cache-01", "region": "us-east", "cpu": 34.5, "memory": 50.1, "status": "running"},
  {"name": "worker-01", "region": "ap-east", "cpu": 55.8, "memory": 83.2, "status": "running"}
]
EOF
echo "servers.json 作成完了"

# ============================================================
echo ""
echo ">>> 演習1: オブジェクトの型とプロパティの確認"
# ============================================================

echo ""
echo "--- PowerShell: Get-Process の型情報を表示 ---"
pwsh -NoProfile -Command '
Get-Process | Get-Member -MemberType Property | Select-Object -First 10 Name, MemberType, Definition | Format-Table -AutoSize
'

echo ""
echo "--- PowerShell: プロセスオブジェクトのプロパティに直接アクセス ---"
pwsh -NoProfile -Command '
$proc = Get-Process | Sort-Object CPU -Descending | Select-Object -First 3
$proc | Format-Table Name, Id, CPU, WorkingSet64 -AutoSize
'

# ============================================================
echo ""
echo ">>> 演習2: bash + jq vs PowerShell ―― JSON処理の比較"
# ============================================================

echo ""
echo "--- bash + jq: CPU 70%以上のrunningサーバを地域ごとに集計 ---"
jq '[.[] | select(.status == "running" and .cpu > 70)] | group_by(.region) | map({region: .[0].region, count: length, avg_cpu: (map(.cpu) | add / length)})' "${WORKDIR}/servers.json"

echo ""
echo "--- PowerShell: 同じタスク ---"
pwsh -NoProfile -Command "
\$servers = Get-Content '${WORKDIR}/servers.json' | ConvertFrom-Json
\$servers |
  Where-Object { \$_.status -eq 'running' -and \$_.cpu -gt 70 } |
  Group-Object region |
  ForEach-Object {
    [PSCustomObject]@{
      Region  = \$_.Name
      Count   = \$_.Count
      AvgCpu  = (\$_.Group | Measure-Object cpu -Average).Average
    }
  } | Format-Table -AutoSize
"

# ============================================================
echo ""
echo ">>> 演習3: フォーマッティングレイヤーの体験"
# ============================================================

echo ""
echo "--- PowerShell: 同じデータを異なるフォーマットで出力 ---"
pwsh -NoProfile -Command '
$procs = Get-Process | Sort-Object CPU -Descending | Select-Object -First 3 Name, CPU, WorkingSet64

Write-Host "`n=== Format-Table ==="
$procs | Format-Table -AutoSize

Write-Host "=== Format-List ==="
$procs | Format-List

Write-Host "=== ConvertTo-Csv ==="
$procs | ConvertTo-Csv -NoTypeInformation

Write-Host "`n=== ConvertTo-Json ==="
$procs | ConvertTo-Json
'

# ============================================================
echo ""
echo ">>> 演習4: Verb-Noun の発見可能性"
# ============================================================

echo ""
echo "--- PowerShell: Process に関連する全コマンド ---"
pwsh -NoProfile -Command '
Get-Command -Noun Process | Format-Table Name, CommandType -AutoSize
'

echo ""
echo "--- PowerShell: Get 動詞のコマンド数 ---"
pwsh -NoProfile -Command '
$count = (Get-Command -Verb Get).Count
Write-Host "Get-* コマンドの数: $count"
'

# ============================================================
echo ""
echo "============================================================"
echo " ハンズオン完了"
echo ""
echo " 作業ディレクトリ: ${WORKDIR}"
echo " PowerShell対話モード: pwsh"
echo ""
echo " 試してみよう:"
echo "   pwsh                              # PowerShellを起動"
echo "   Get-Process | Sort-Object CPU -Descending | Select-Object -First 5"
echo "   Get-ChildItem | Where-Object { \$_.Length -gt 1KB }"
echo "   Get-Command -Noun *Item*          # Item関連コマンドを発見"
echo "   Get-Help Get-Process -Examples    # 使用例を表示"
echo "============================================================"
