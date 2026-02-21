#!/bin/bash
# =============================================================================
# 第19回ハンズオン：モダンターミナルエミュレータの競争
#   ――GPU描画とプロトコル拡張
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: ncurses-bin
# 推奨環境: Docker (ubuntu:24.04)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/command-line-handson-19"

echo "=== 第19回ハンズオン：モダンターミナルエミュレータの競争 ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# --- 演習1: ターミナルの基本情報 ---
echo "[演習1] ターミナルの基本情報を確認"
echo ""

apt-get update -qq && apt-get install -y -qq ncurses-bin > /dev/null 2>&1
echo "  ncurses-bin をインストールしました。"
echo ""

echo "  --- 環境変数 ---"
echo "  TERM=${TERM}"
echo "  COLORTERM=${COLORTERM:-未設定}"
echo "  TERM_PROGRAM=${TERM_PROGRAM:-未設定}"
echo ""

echo "  --- terminfoによる端末能力 ---"
echo "  色数: $(tput colors)"
echo "  行数: $(tput lines)"
echo "  列数: $(tput cols)"
echo ""

echo "  --- True Color (24bit) サポートの確認 ---"
for i in $(seq 0 6 255); do
  printf "\033[48;2;${i};$((255-i));$(((i*2)%256))m  "
done
printf "\033[0m\n"
echo ""
echo "  上にグラデーションが表示されれば True Color サポートあり。"
echo ""

# --- 演習2: エスケープシーケンスの互換性 ---
echo "---"
echo ""
echo "[演習2] エスケープシーケンスの互換性を検証"
echo ""

echo "  --- 基本SGR属性 ---"
echo -e "  \033[1m太字\033[0m"
echo -e "  \033[3mイタリック\033[0m"
echo -e "  \033[4m下線\033[0m"
echo -e "  \033[9m取り消し線\033[0m"
echo ""

echo "  --- スタイル付きアンダーライン（モダンターミナル向け）---"
echo -e "  \033[4:1m直線（straight）\033[0m"
echo -e "  \033[4:2m二重線（double）\033[0m"
echo -e "  \033[4:3m波線（curly）\033[0m"
echo -e "  \033[4:4m点線（dotted）\033[0m"
echo -e "  \033[4:5m破線（dashed）\033[0m"
echo ""

echo "  --- 色付きアンダーライン ---"
echo -e "  \033[4:3m\033[58;2;255;0;0m赤い波線\033[0m"
echo -e "  \033[4:3m\033[58;2;0;255;0m緑の波線\033[0m"
echo -e "  \033[4:3m\033[58;2;0;100;255m青の波線\033[0m"
echo ""

echo "  → 波線下線はkitty, Ghostty, WezTerm等で表示される。"
echo "    xterm や古いターミナルでは通常の下線にフォールバックする。"
echo ""

# --- 演習3: 大量テキスト出力の描画性能 ---
echo "---"
echo ""
echo "[演習3] 大量テキスト出力の描画性能"
echo ""

echo "  テストデータを生成中..."
seq 1 100000 > "${WORKDIR}/large_output.txt"
echo "  ${WORKDIR}/large_output.txt (10万行) を生成しました。"
echo ""

echo "  --- /dev/nullへの出力（描画なし、ベースライン）---"
echo "  time cat ${WORKDIR}/large_output.txt > /dev/null"
time cat "${WORKDIR}/large_output.txt" > /dev/null
echo ""

echo "  → 実際にターミナルに出力する場合:"
echo "    time cat ${WORKDIR}/large_output.txt"
echo "  /dev/nullとの時間差が描画コストに相当する。"
echo "  GPU描画のターミナルではこの差が小さい傾向がある。"
echo ""

echo "  --- Unicode幅計算テスト ---"
cat > "${WORKDIR}/unicode_test.txt" << 'EOF'
行01: 日本語テキストとASCII text の混在行。ターミナルは各文字の幅を計算する。
行02: 全角記号テスト: ！＠＃＄％＾＆＊（）
行03: 絵文字テスト (要対応ターミナル): Terminal Emulator Test
行04: CJK統合漢字: 漢字仮名交じり文の表示テスト。正しく整列するか確認。
行05: ハングル: 터미널 에뮬레이터 테스트
EOF
echo "  ${WORKDIR}/unicode_test.txt を生成しました。"
echo "  cat ${WORKDIR}/unicode_test.txt でUnicode表示を確認してください。"
echo ""
cat "${WORKDIR}/unicode_test.txt"
echo ""

# --- 演習4: 画像表示能力 ---
echo "---"
echo ""
echo "[演習4] ターミナルの画像表示能力"
echo ""

echo "  --- Sixelサポートの確認 ---"
echo "  赤い小さなブロックが表示されればSixel対応:"
printf '\033Pq
#0;2;100;0;0
#0~~~~~~-
#0~~~~~~-
#0~~~~~~-
#0~~~~~~-
#0~~~~~~-
#0~~~~~~\033\\'
echo ""
echo ""

echo "  --- kittyグラフィックスプロトコルの確認 ---"
echo "  kitty/Ghostty/WezTermを使っている場合のみ画像が表示される:"
printf '\033_Gf=100,a=T;iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==\033\\'
echo ""
echo ""

echo "  → 画像プロトコルの対応状況:"
echo "    Sixel:  xterm(-experimental), mlterm, foot, WezTerm等"
echo "    kitty:  kitty, WezTerm, Ghostty等"
echo "    iTerm2: iTerm2, WezTerm, mintty等"
echo ""

echo "=== セットアップ完了 ==="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "まとめ:"
echo "  1. TERM環境変数とterminfoが端末能力の検出手段だが、不十分な場合がある"
echo "  2. スタイル付きアンダーラインはモダンターミナルの識別子として機能する"
echo "  3. 大量テキスト出力の描画性能はターミナルエミュレータで大きく異なる"
echo "  4. 画像プロトコルの断片化がターミナルプロトコルの技術的負債を象徴している"
