#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/cloud-history-handson-23"

echo "═══════════════════════════════════════════════════════════════"
echo "  第23回ハンズオン: TCO比較シミュレータ"
echo "  クラウド vs オンプレミスのコスト分析"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# --- ディレクトリ作成 ---
echo ">>> 作業ディレクトリを作成: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# --- 依存ツール確認 ---
echo ">>> 依存ツールを確認..."
if ! command -v bc &> /dev/null; then
  echo "  bc がインストールされていません。インストールしてください:"
  echo "    Ubuntu/Debian: sudo apt-get install -y bc"
  echo "    macOS: brew install bc"
  exit 1
fi
echo "  bc: OK"
echo ""

# =====================================================================
# 演習1: TCO比較スクリプト
# =====================================================================
echo ">>> 演習1: TCO比較スクリプトを作成..."

cat > tco_compare.sh << 'SCRIPT'
#!/bin/bash
# tco_compare.sh -- クラウド vs オンプレミス TCO比較シミュレータ
# 前提: 一般的なWebアプリケーションサーバ構成
set -euo pipefail

cat << 'HEADER'
═══════════════════════════════════════════════════════════════
  TCO比較シミュレータ: クラウド vs オンプレミス
  対象: Webアプリケーションサーバ（8 vCPU / 32GB RAM 相当）
═══════════════════════════════════════════════════════════════
HEADER

# --- パラメータ定義 ---
# クラウド（AWS EC2 m6i.2xlarge 相当、東京リージョン）
CLOUD_HOURLY_ONDEMAND=0.464
CLOUD_HOURLY_RESERVED_1Y=0.293
CLOUD_HOURLY_RESERVED_3Y=0.186
CLOUD_STORAGE_GB_MONTH=0.096
CLOUD_STORAGE_GB=500
CLOUD_NETWORK_GB=0.114
CLOUD_NETWORK_GB_MONTH=1000

# オンプレミス
ONPREM_SERVER_COST=8000
ONPREM_DEPRECIATION_YEARS=5
ONPREM_POWER_MONTHLY=150
ONPREM_NETWORK_MONTHLY=500
ONPREM_DATACENTER_MONTHLY=300
ONPREM_MAINTENANCE_YEARLY=1200
ONPREM_ADMIN_HOURS_MONTHLY=8
ONPREM_ADMIN_HOURLY_RATE=75

MONTHS=36

echo ""
echo "【前提条件】"
echo "  サーバ構成: 8 vCPU / 32GB RAM / 500GB SSD"
echo "  比較期間: ${MONTHS}ヶ月（$(echo "scale=1; $MONTHS / 12" | bc)年）"
echo "  月間データ転送: ${CLOUD_NETWORK_GB_MONTH}GB"
echo ""

# --- クラウドTCO計算 ---
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "【クラウド TCO（${MONTHS}ヶ月）】"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cloud_compute_od=$(echo "scale=2; $CLOUD_HOURLY_ONDEMAND * 730 * $MONTHS" | bc)
cloud_storage=$(echo "scale=2; $CLOUD_STORAGE_GB_MONTH * $CLOUD_STORAGE_GB * $MONTHS" | bc)
cloud_network=$(echo "scale=2; $CLOUD_NETWORK_GB * $CLOUD_NETWORK_GB_MONTH * $MONTHS" | bc)
cloud_total_od=$(echo "scale=2; $cloud_compute_od + $cloud_storage + $cloud_network" | bc)

echo "  オンデマンド:"
printf "    コンピュート:   \$%'.2f\n" "$cloud_compute_od"
printf "    ストレージ:     \$%'.2f\n" "$cloud_storage"
printf "    ネットワーク:   \$%'.2f\n" "$cloud_network"
printf "    合計:           \$%'.2f\n" "$cloud_total_od"
echo ""

cloud_compute_1y=$(echo "scale=2; $CLOUD_HOURLY_RESERVED_1Y * 730 * $MONTHS" | bc)
cloud_total_1y=$(echo "scale=2; $cloud_compute_1y + $cloud_storage + $cloud_network" | bc)

echo "  1年リザーブド:"
printf "    コンピュート:   \$%'.2f\n" "$cloud_compute_1y"
printf "    合計:           \$%'.2f\n" "$cloud_total_1y"
echo ""

cloud_compute_3y=$(echo "scale=2; $CLOUD_HOURLY_RESERVED_3Y * 730 * $MONTHS" | bc)
cloud_total_3y=$(echo "scale=2; $cloud_compute_3y + $cloud_storage + $cloud_network" | bc)

echo "  3年リザーブド:"
printf "    コンピュート:   \$%'.2f\n" "$cloud_compute_3y"
printf "    合計:           \$%'.2f\n" "$cloud_total_3y"

# --- オンプレミスTCO計算 ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "【オンプレミス TCO（${MONTHS}ヶ月）】"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

onprem_depreciation=$ONPREM_SERVER_COST
onprem_power=$(echo "scale=2; $ONPREM_POWER_MONTHLY * $MONTHS" | bc)
onprem_network=$(echo "scale=2; $ONPREM_NETWORK_MONTHLY * $MONTHS" | bc)
onprem_datacenter=$(echo "scale=2; $ONPREM_DATACENTER_MONTHLY * $MONTHS" | bc)
onprem_maintenance=$(echo "scale=2; $ONPREM_MAINTENANCE_YEARLY * $MONTHS / 12" | bc)
onprem_admin=$(echo "scale=2; $ONPREM_ADMIN_HOURS_MONTHLY * $ONPREM_ADMIN_HOURLY_RATE * $MONTHS" | bc)
onprem_total=$(echo "scale=2; $onprem_depreciation + $onprem_power + $onprem_network + $onprem_datacenter + $onprem_maintenance + $onprem_admin" | bc)

printf "    サーバ購入費:   \$%'.2f\n" "$onprem_depreciation"
printf "    電力費用:       \$%'.2f\n" "$onprem_power"
printf "    ネットワーク:   \$%'.2f\n" "$onprem_network"
printf "    DC費用:         \$%'.2f\n" "$onprem_datacenter"
printf "    保守費用:       \$%'.2f\n" "$onprem_maintenance"
printf "    管理工数:       \$%'.2f\n" "$onprem_admin"
printf "    合計:           \$%'.2f\n" "$onprem_total"

# --- 比較結果 ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "【比較結果（${MONTHS}ヶ月）】"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "  クラウド（オンデマンド）: \$%'.2f\n" "$cloud_total_od"
printf "  クラウド（1年RI）:       \$%'.2f\n" "$cloud_total_1y"
printf "  クラウド（3年RI）:       \$%'.2f\n" "$cloud_total_3y"
printf "  オンプレミス:            \$%'.2f\n" "$onprem_total"
echo ""

cloud_monthly_od=$(echo "scale=2; $cloud_total_od / $MONTHS" | bc)
onprem_monthly_after_purchase=$(echo "scale=2; ($onprem_total - $onprem_depreciation) / $MONTHS" | bc)
if [ "$(echo "$cloud_monthly_od > $onprem_monthly_after_purchase" | bc)" -eq 1 ]; then
  breakeven=$(echo "scale=1; $onprem_depreciation / ($cloud_monthly_od - $onprem_monthly_after_purchase)" | bc)
  echo "  損益分岐点（vs オンデマンド）: 約${breakeven}ヶ月"
fi

echo ""
echo "※ この試算は単一サーバ・単一ワークロードの概算です"
echo "═══════════════════════════════════════════════════════════════"
SCRIPT

chmod +x tco_compare.sh
echo "  作成完了: tco_compare.sh"

# =====================================================================
# 演習2: ワークロード分類ツール
# =====================================================================
echo ">>> 演習2: ワークロード分類ツールを作成..."

cat > workload_classifier.sh << 'SCRIPT'
#!/bin/bash
# workload_classifier.sh -- ワークロード配置判定ツール
set -euo pipefail

cat << 'HEADER'
═══════════════════════════════════════════════════════════════
  ワークロード配置判定ツール
  各ワークロードの特性を入力し、最適な配置を判定します
═══════════════════════════════════════════════════════════════
HEADER

classify_workload() {
  local name="$1"
  local variability="$2"
  local predictability="$3"
  local data_sensitivity="$4"
  local scale="$5"
  local growth_rate="$6"

  local cloud_score=$(( variability * 2 + growth_rate * 2 + (6 - predictability) ))
  local onprem_score=$(( predictability * 2 + data_sensitivity * 2 + scale ))

  echo "  ワークロード: ${name}"
  echo "    変動性=${variability} 予測可能性=${predictability} 機密性=${data_sensitivity} 規模=${scale} 成長率=${growth_rate}"
  echo "    クラウドスコア: ${cloud_score} / オンプレスコア: ${onprem_score}"

  if [ "$cloud_score" -gt "$((onprem_score + 3))" ]; then
    echo "    -> 推奨: クラウド"
  elif [ "$onprem_score" -gt "$((cloud_score + 3))" ]; then
    echo "    -> 推奨: オンプレミス"
  else
    echo "    -> 推奨: ハイブリッド（要詳細分析）"
  fi
  echo ""
}

echo ""
echo "【サンプルワークロードの分析】"
echo ""

classify_workload "ECサイト（セール期間あり）" 5 2 3 3 4
classify_workload "社内基幹業務システム"       1 5 4 4 1
classify_workload "AI推論サービス（本番）"     2 4 3 5 2
classify_workload "スタートアップMVP"          4 1 2 1 5
classify_workload "金融取引データ処理"         2 4 5 5 2
classify_workload "開発・テスト環境"           3 3 1 2 3

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "注: このツールは簡易的な判定です。実際の判断にはTCO分析、"
echo "    組織のスキルセット、規制要件の詳細な検討が必要です"
echo "═══════════════════════════════════════════════════════════════"
SCRIPT

chmod +x workload_classifier.sh
echo "  作成完了: workload_classifier.sh"

# =====================================================================
# 演習3: 損益分岐点の可視化
# =====================================================================
echo ">>> 演習3: 損益分岐点チャートを作成..."

cat > breakeven_chart.sh << 'SCRIPT'
#!/bin/bash
# breakeven_chart.sh -- 損益分岐点の可視化
set -euo pipefail

cat << 'HEADER'
═══════════════════════════════════════════════════════════════
  損益分岐点チャート: クラウド vs オンプレミス
  36ヶ月間の累計コスト推移
═══════════════════════════════════════════════════════════════
HEADER

CLOUD_MONTHLY=339
ONPREM_INITIAL=8000
ONPREM_MONTHLY=520

echo ""
echo "  前提: クラウド月額 \$${CLOUD_MONTHLY} / オンプレ初期 \$${ONPREM_INITIAL} + 月額 \$${ONPREM_MONTHLY}"
echo ""
echo "  月  | クラウド累計 | オンプレ累計 | 差額        | 判定"
echo "  ----+-------------+-------------+-------------+--------------"

for month in $(seq 1 36); do
  cloud_total=$((CLOUD_MONTHLY * month))
  onprem_total=$((ONPREM_INITIAL + ONPREM_MONTHLY * month))
  diff=$((cloud_total - onprem_total))

  if [ $((month % 3)) -eq 0 ] || [ "$month" -eq 1 ]; then
    printf "  %2d  | \$%'9d | \$%'9d | \$%'9d |" \
      "$month" "$cloud_total" "$onprem_total" "$diff"
    if [ "$diff" -lt 0 ]; then
      echo " オンプレ有利"
    else
      echo " クラウド有利"
    fi
  fi
done

echo ""
if [ "$((CLOUD_MONTHLY - ONPREM_MONTHLY))" -gt 0 ]; then
  echo "  結果: この構成ではクラウド月額がオンプレ月額より低いため、"
  echo "        オンプレミスの初期投資は回収できません"
else
  breakeven_month=$(echo "scale=1; $ONPREM_INITIAL / ($CLOUD_MONTHLY - $ONPREM_MONTHLY)" | bc 2>/dev/null || echo "N/A")
  echo "  損益分岐点: 約${breakeven_month}ヶ月"
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
SCRIPT

chmod +x breakeven_chart.sh
echo "  作成完了: breakeven_chart.sh"

# =====================================================================
# 完了
# =====================================================================
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  セットアップ完了"
echo ""
echo "  作業ディレクトリ: ${WORKDIR}"
echo ""
echo "  実行方法:"
echo "    cd ${WORKDIR}"
echo "    ./tco_compare.sh           # 演習1: TCO比較"
echo "    ./workload_classifier.sh   # 演習2: ワークロード分類"
echo "    ./breakeven_chart.sh       # 演習3: 損益分岐点"
echo ""
echo "  各スクリプトのパラメータを自社の環境に合わせて"
echo "  編集することで、より正確な分析が可能です"
echo "═══════════════════════════════════════════════════════════════"
