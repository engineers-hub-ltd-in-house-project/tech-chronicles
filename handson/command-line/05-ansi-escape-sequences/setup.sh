#!/bin/bash
# =============================================================================
# 第5回ハンズオン：ANSIエスケープシーケンス――端末の表現力の拡張
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: printf, tput, seq (通常プリインストール済み)
# 推奨: ncurses-bin (tput用。なければ自動インストールを試みる)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/cli-handson-05"

echo "=== 第5回ハンズオン：ANSIエスケープシーケンス ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# tputの存在確認とインストール
if ! command -v tput &>/dev/null; then
  echo "tput が見つかりません。ncurses-bin のインストールを試みます..."
  if command -v apt-get &>/dev/null; then
    apt-get update -qq && apt-get install -y -qq ncurses-bin 2>/dev/null || true
  fi
fi

# --- 演習1: SGRパラメータの基本操作 ---
echo "================================================================"
echo "[演習1] SGRパラメータの基本操作"
echo "================================================================"
echo ""

echo "--- 文字属性 ---"
echo ""
printf "  \033[1m太字(Bold)\033[0m\n"
printf "  \033[2m暗い(Dim)\033[0m\n"
printf "  \033[3mイタリック(Italic)\033[0m\n"
printf "  \033[4m下線(Underline)\033[0m\n"
printf "  \033[7m反転(Reverse)\033[0m\n"
printf "  \033[9m取り消し線(Strikethrough)\033[0m\n"
printf "  \033[1;4m太字+下線\033[0m\n"
printf "  \033[1;3;4m太字+イタリック+下線\033[0m\n"
echo ""

echo "--- 基本8色（前景色 SGR 30-37）---"
echo ""
for i in $(seq 30 37); do
    printf "  \033[${i}m SGR ${i} \033[0m"
done
echo ""
echo ""

echo "--- 基本8色（背景色 SGR 40-47）---"
echo ""
for i in $(seq 40 47); do
    printf "  \033[${i}m SGR ${i} \033[0m"
done
echo ""
echo ""

echo "--- 明るい色（前景色 SGR 90-97）---"
echo ""
for i in $(seq 90 97); do
    printf "  \033[${i}m SGR ${i} \033[0m"
done
echo ""
echo ""

echo "--- 太字(1) + 通常色 → 明るい色になるか確認 ---"
echo ""
for i in $(seq 30 37); do
    printf "  通常:\033[${i}m##\033[0m  太字:\033[1;${i}m##\033[0m"
    bright=$((i + 60))
    printf "  明るい色:\033[${bright}m##\033[0m"
    echo ""
done
echo ""
echo "  → 多くの端末で、太字(SGR 1)は明るい色として描画される"
echo "    これが8色を事実上16色に拡張した歴史的慣習"
echo ""

echo "--- リセット忘れの影響 ---"
echo ""
printf "  \033[31m赤色のテキスト..."
echo "リセットを忘れると..."
echo "  この行も赤のまま..."
printf "  \033[0mリセットした。ここから通常色。\n"
echo ""
echo "  → ESC[0m でリセットしないと後続テキストに影響する"
echo ""

# --- 演習2: カーソル制御とプログレスバー ---
echo "================================================================"
echo "[演習2] カーソル制御とプログレスバー"
echo "================================================================"
echo ""

echo "--- カーソル移動の基本 ---"
echo ""
echo "  ESC[nA : カーソルをn行上に移動"
echo "  ESC[nB : カーソルをn行下に移動"
echo "  ESC[nC : カーソルをn列右に移動"
echo "  ESC[nD : カーソルをn列左に移動"
echo "  ESC[n;mH : カーソルをn行m列に移動"
echo "  ESC[2J : 画面全体をクリア"
echo "  ESC[K  : カーソルから行末までクリア"
echo ""

echo "--- デモ: 簡易プログレスバー ---"
echo ""
WIDTH=40
printf "  ["
for i in $(seq 1 $WIDTH); do
    printf "#"
    sleep 0.02
done
printf "] Done!\n"
echo ""

echo "--- デモ: 上書き型プログレスバー ---"
echo ""
echo "  \\r（キャリッジリターン）で行頭に戻り上書き:"
echo ""
for i in $(seq 0 100); do
    FILLED=$((i * WIDTH / 100))
    EMPTY=$((WIDTH - FILLED))
    FILL_STR=""
    EMPTY_STR=""
    j=0
    while [ $j -lt $FILLED ]; do
        FILL_STR="${FILL_STR}#"
        j=$((j + 1))
    done
    j=0
    while [ $j -lt $EMPTY ]; do
        EMPTY_STR="${EMPTY_STR}-"
        j=$((j + 1))
    done
    printf "\r  [%s%s] %3d%%" "$FILL_STR" "$EMPTY_STR" "$i"
    sleep 0.02
done
echo ""
echo ""

echo "--- デモ: 複数行の動的更新 ---"
echo ""
echo "  ESC[nA（カーソルを上に移動）で複数行を動的に更新:"
echo ""
echo "  CPU:    [--------------------]   0%"
echo "  Memory: [--------------------]   0%"
echo "  Disk:   [--------------------]   0%"

for step in $(seq 1 20); do
    sleep 0.1
    printf "\033[3A"

    CPU=$((step * 5))
    MEM=$((step * 3))
    DISK=$((step * 2))

    CPU_FILL=$((CPU * 20 / 100))
    MEM_FILL=$((MEM * 20 / 100))
    DISK_FILL=$((DISK * 20 / 100))

    CPU_STR=""
    j=0; while [ $j -lt $CPU_FILL ]; do CPU_STR="${CPU_STR}#"; j=$((j + 1)); done
    MEM_STR=""
    j=0; while [ $j -lt $MEM_FILL ]; do MEM_STR="${MEM_STR}#"; j=$((j + 1)); done
    DISK_STR=""
    j=0; while [ $j -lt $DISK_FILL ]; do DISK_STR="${DISK_STR}#"; j=$((j + 1)); done

    printf "  CPU:    [\033[32m%-20s\033[0m] %3d%%\n" "$CPU_STR" "$CPU"
    printf "  Memory: [\033[33m%-20s\033[0m] %3d%%\n" "$MEM_STR" "$MEM"
    printf "  Disk:   [\033[34m%-20s\033[0m] %3d%%\n" "$DISK_STR" "$DISK"
done
echo ""

# --- 演習3: 256色とTrue Color ---
echo "================================================================"
echo "[演習3] 256色とTrue Colorの確認"
echo "================================================================"
echo ""

echo "--- 端末の色対応確認 ---"
echo ""
echo "  TERM=${TERM:-unknown}"
if command -v tput &>/dev/null; then
    echo "  対応色数: $(tput colors 2>/dev/null || echo '不明')"
fi
echo ""

echo "--- tput vs ハードコード ---"
echo ""
if command -v tput &>/dev/null; then
    echo "  tput による色設定:"
    printf "  $(tput setaf 1)赤$(tput sgr0) "
    printf "$(tput setaf 2)緑$(tput sgr0) "
    printf "$(tput setaf 3)黄$(tput sgr0) "
    printf "$(tput setaf 4)青$(tput sgr0)\n"
    echo ""
fi
echo "  ハードコードによる同じ操作:"
printf "  \033[31m赤\033[0m \033[32m緑\033[0m \033[33m黄\033[0m \033[34m青\033[0m\n"
echo ""

echo "--- 256色パレット ---"
echo ""
echo "  標準16色 (0-15):"
for i in $(seq 0 15); do
    printf "\033[48;5;${i}m %3d \033[0m" "$i"
    if [ $((($i + 1) % 8)) -eq 0 ]; then
        echo ""
    fi
done
echo ""

echo "  6x6x6 RGBカラーキューブ (16-231):"
for g in 0 1 2 3 4 5; do
    printf "  "
    for r in 0 1 2 3 4 5; do
        for b in 0 1 2 3 4 5; do
            idx=$((16 + 36*r + 6*g + b))
            printf "\033[48;5;${idx}m  \033[0m"
        done
        printf " "
    done
    echo ""
done
echo ""

echo "  グレースケール (232-255):"
printf "  "
for i in $(seq 232 255); do
    printf "\033[48;5;${i}m  \033[0m"
done
echo ""
echo ""

echo "--- 24ビット True Color グラデーション ---"
echo ""
echo "  赤のグラデーション:"
printf "  "
for i in $(seq 0 8 255); do
    printf "\033[48;2;${i};0;0m \033[0m"
done
echo ""

echo "  緑のグラデーション:"
printf "  "
for i in $(seq 0 8 255); do
    printf "\033[48;2;0;${i};0m \033[0m"
done
echo ""

echo "  青のグラデーション:"
printf "  "
for i in $(seq 0 8 255); do
    printf "\033[48;2;0;0;${i}m \033[0m"
done
echo ""

echo "  虹のグラデーション:"
printf "  "
for i in $(seq 0 5 255); do
    if [ "$i" -le 42 ]; then
        r=255; g=$((i * 6)); b=0
    elif [ "$i" -le 85 ]; then
        r=$(( (85 - i) * 6 )); g=255; b=0
    elif [ "$i" -le 127 ]; then
        r=0; g=255; b=$(( (i - 85) * 6 ))
    elif [ "$i" -le 170 ]; then
        r=0; g=$(( (170 - i) * 6 )); b=255
    elif [ "$i" -le 212 ]; then
        r=$(( (i - 170) * 6 )); g=0; b=255
    else
        r=255; g=0; b=$(( (255 - i) * 6 ))
    fi
    r=$((r > 255 ? 255 : (r < 0 ? 0 : r)))
    g=$((g > 255 ? 255 : (g < 0 ? 0 : g)))
    b=$((b > 255 ? 255 : (b < 0 ? 0 : b)))
    printf "\033[48;2;${r};${g};${b}m \033[0m"
done
echo ""
echo ""

echo "  滑らかなグラデーションに見えれば"
echo "  あなたの端末は24ビットTrue Colorに対応している"
echo ""

# --- まとめ ---
echo "================================================================"
echo "演習完了"
echo "================================================================"
echo ""
echo "  作業ディレクトリ: ${WORKDIR}"
echo ""
echo "  この演習で体験したこと:"
echo "  1. SGRパラメータによる文字装飾と色制御"
echo "  2. カーソル移動シーケンスによるプログレスバーの実装"
echo "  3. 256色パレットとTrue Colorグラデーションの確認"
echo ""
echo "  テキストストリームの中にESC[で始まるバイト列を"
echo "  埋め込むだけで、これだけの表現力が得られる。"
echo "  1976年のECMA-48が定めたこの仕組みは、50年近く"
echo "  経った今も現役で動き続けている。"
echo ""
