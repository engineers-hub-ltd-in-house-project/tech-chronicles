#!/bin/bash
# =============================================================================
# 第4回ハンズオン：テレタイプの記憶を追体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: stty, cat, sleep, kill (通常プリインストール済み)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/cli-handson-04"

echo "=== 第4回ハンズオン：テレタイプの記憶を追体験する ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# --- 演習1: stty -a のパラメータ解読 ---
echo "================================================================"
echo "[演習1] stty -a のパラメータ解読"
echo "================================================================"
echo ""

echo "--- 現在の端末設定 ---"
echo '$ stty -a'
stty -a 2>/dev/null || echo "(Docker環境ではpty設定が限定的な場合があります)"
echo ""

echo "--- 主要パラメータの歴史的由来 ---"
echo ""
echo "  speed (ボーレート):"
echo "    テレタイプ時代の通信速度。Model 33は110ボー（約10文字/秒）。"
echo "    VT100は最大19200bps。現代のptyでは38400が一般的。"
echo ""
echo "  rows/columns:"
echo "    VT100の24行80列が事実上の標準。80列はパンチカードに由来。"
echo "    IBM 3270（1971年）が80x24を普及させた。"
echo ""
echo "  intr = ^C:"
echo "    ASCII ETX（End of Text, 値3）。SIGINTシグナルを送信。"
echo "    テレタイプ時代のINTERRUPTキーの名残。"
echo ""
echo "  eof = ^D:"
echo "    ASCII EOT（End of Transmission, 値4）。入力の終端を示す。"
echo "    テレタイプの送信終了信号に由来。"
echo ""
echo "  susp = ^Z:"
echo "    ASCII SUB（Substitute, 値26）。SIGTSTPを送信しプロセスを一時停止。"
echo "    ジョブ制御のために転用された制御文字。"
echo ""
echo "  erase = ^? (DEL, 127):"
echo "    紙テープの全ビット穿孔（1111111）。穿孔済みの文字を無効化するため。"
echo ""
echo "  kill = ^U:"
echo "    現在の入力行全体を削除。テレタイプでは行を取り消す唯一の手段。"
echo ""
echo "  onlcr:"
echo "    Output NL to CR-LF。LFをCR+LFに変換する。"
echo "    UNIXは内部でLFのみ使用するが、端末には CR+LF が必要だった名残。"
echo ""

# onlcr 実験
echo "--- onlcr の効果を確認 ---"
echo '$ printf "Line1\nLine2\nLine3\n"'
printf "Line1\nLine2\nLine3\n"
echo ""
echo "上記が正常に表示されるのは、onlcr がLFをCR+LFに変換しているため。"
echo "onlcr を無効にすると、LF後にカーソルが左端に戻らず階段状になる。"
echo "(安全のためここでは実行しない。試す場合: stty -onlcr)"
echo ""

# --- 演習2: 制御文字の動作実験 ---
echo "================================================================"
echo "[演習2] 制御文字の動作実験"
echo "================================================================"
echo ""

echo "--- ASCII制御文字とターミナルの対応 ---"
echo ""
echo "  BEL (Ctrl+G, ASCII 7):"
echo "    テレタイプの物理ベルを鳴らす制御コード。1870年代から存在。"
echo '    $ printf "\a"  # ターミナルのベル音（またはビジュアルベル）'
printf "\a" 2>/dev/null || true
echo ""
echo ""

echo "  BS (Ctrl+H, ASCII 8):"
echo "    Backspace。カーソルを1文字戻す。"
echo '    $ printf "ABCD\b\b--\n"  # CDを--で上書き'
printf "ABCD\b\b--\n"
echo ""

echo "  CR (Ctrl+M, ASCII 13):"
echo "    Carriage Return。カーソルを行頭に戻す（テレタイプのキャリッジ動作）。"
echo '    $ printf "OLD TEXT\rNEW\n"  # OLD TEXTの先頭をNEWで上書き'
printf "OLD TEXT\rNEW\n"
echo ""

echo "  LF (Ctrl+J, ASCII 10):"
echo "    Line Feed。紙を1行送る（テレタイプの紙送り動作）。"
echo "    UNIXでは改行文字として使用。"
echo ""

echo "  ESC (ASCII 27):"
echo "    Bob Bemerが1960年にASCIIに導入。"
echo "    後のターミナル制御シーケンス（VT52, VT100, ANSI）の起点となった。"
echo '    $ printf "\033[7mREVERSE\033[0m NORMAL\n"  # 反転表示の例'
printf "\033[7mREVERSE\033[0m NORMAL\n"
echo ""

echo "  DEL (ASCII 127):"
echo "    紙テープの全ビット穿孔（1111111）。穿孔済みの文字を無効化するため。"
echo "    現代のBackspaceキーに対応することが多い。"
echo ""

echo "--- シグナルと制御文字の対応 ---"
echo ""

# バックグラウンドプロセスを使ったデモ
echo "Ctrl+C -> SIGINT (プロセス中断):"
echo '  stty設定: intr = ^C'
echo '  $ sleep 100 &  # バックグラウンドで起動'
echo '  $ kill -INT $!  # SIGINTを送信（Ctrl+Cと同等）'
sleep 100 &
SLEEP_PID=$!
kill -INT $SLEEP_PID 2>/dev/null || true
wait $SLEEP_PID 2>/dev/null || true
echo "  -> プロセスが中断された"
echo ""

echo "Ctrl+Z -> SIGTSTP (プロセス一時停止):"
echo '  stty設定: susp = ^Z'
echo "  ジョブ制御で fg/bg コマンドと組み合わせて使用。"
echo ""

echo "Ctrl+D -> EOF (入力終端):"
echo '  stty設定: eof = ^D'
echo "  シェルのプロンプトでCtrl+Dを押すとログアウト。"
echo "  catコマンドの入力終了にも使用。"
echo ""

# --- 演習3: ボーレートシミュレーション ---
echo "================================================================"
echo "[演習3] ボーレートシミュレーション"
echo "================================================================"
echo ""

TEXT="The quick brown fox jumps over the lazy dog. 1234567890"

cat > "${WORKDIR}/baud_sim.sh" << 'ENDSIM'
#!/bin/bash
set -euo pipefail

TEXT="The quick brown fox jumps over the lazy dog. 1234567890"

simulate_baud() {
    local baud=$1
    local label=$2
    local chars_per_sec=$((baud / 10))  # 1文字 = start + 7data + parity + stop = 10bits
    local delay
    delay=$(awk "BEGIN {printf \"%.4f\", 1.0 / $chars_per_sec}")

    echo "--- $label ($baud baud = $chars_per_sec chars/sec) ---"
    echo -n "  "
    for (( i=0; i<${#TEXT}; i++ )); do
        echo -n "${TEXT:$i:1}"
        sleep "$delay"
    done
    echo ""
    echo ""
}

echo "=== ボーレート体感シミュレーション ==="
echo ""
echo "同じテキストを異なるボーレートで表示し、体感速度の違いを確認する。"
echo ""

simulate_baud 110 "Teletype Model 33 (1963)"
simulate_baud 300 "初期モデム/音響カプラ (1970s)"
simulate_baud 9600 "VT100標準速度 (1978)"

echo "=== 比較 ==="
echo "  110ボー:  1文字あたり約91ms。フルスクリーンエディタは不可能。"
echo "  300ボー:  1文字あたり約33ms。viが設計された速度帯。"
echo "  9600ボー: 1文字あたり約1ms。対話的操作が快適になる。"
echo "  19200ボー以上: 人間の知覚限界を超え、遅延を感じない。"
echo ""
echo "viのモーダルな設計（挿入モードとコマンドモード）は、"
echo "300ボーの低速回線でも効率的に操作するための工夫だった。"
ENDSIM
chmod +x "${WORKDIR}/baud_sim.sh"

echo "ボーレートシミュレーターを実行中..."
echo ""
bash "${WORKDIR}/baud_sim.sh"

echo ""
echo "================================================================"
echo "=== ハンズオン完了 ==="
echo "================================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "ポイント:"
echo "  1. sttyの設定項目はテレタイプ時代の物理端末の名残"
echo "  2. Ctrl+C/D/Zなどの制御文字はASCIIの制御コードに由来"
echo "  3. CR/LFの分離はテレタイプの機械的制約が原因"
echo "  4. ボーレートの制約がviのモーダル設計などUXに影響を与えた"
