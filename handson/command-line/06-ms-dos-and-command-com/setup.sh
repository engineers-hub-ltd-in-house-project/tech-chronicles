#!/bin/bash
# =============================================================================
# 第6回ハンズオン：MS-DOSとCOMMAND.COM――もうひとつのCLI系譜
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: bash, grep, awk, sort, wc (通常プリインストール済み)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/cli-handson-06"

echo "=== 第6回ハンズオン：MS-DOSとCOMMAND.COM ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# =============================================================================
echo "=============================================="
echo "[演習1] DOS CLIとUNIX CLIの対照表"
echo "=============================================="
echo ""
echo "DOS/Windowsの世界に実際に触れる前に、"
echo "まずコマンドの対応関係を整理する。"
echo ""
echo "+-----------------------+------------------+-------------------+"
echo "| 操作                  | DOS/cmd.exe      | UNIX/bash         |"
echo "+-----------------------+------------------+-------------------+"
echo "| ファイル一覧          | DIR              | ls                |"
echo "| ディレクトリ移動      | CD               | cd                |"
echo "| ファイルコピー        | COPY             | cp                |"
echo "| ファイル移動          | MOVE             | mv                |"
echo "| ファイル削除          | DEL              | rm                |"
echo "| ファイル内容表示      | TYPE             | cat               |"
echo "| ディレクトリ作成      | MD (MKDIR)       | mkdir             |"
echo "| ディレクトリ削除      | RD (RMDIR)       | rmdir             |"
echo "| 画面クリア            | CLS              | clear             |"
echo "| テキスト検索          | FIND             | grep              |"
echo "| パス区切り            | \\                | /                 |"
echo "| オプション指定        | /スイッチ        | -フラグ           |"
echo "| 環境変数参照          | %VAR%            | \$VAR             |"
echo "| ワイルドカード展開    | アプリ側         | シェル側          |"
echo "| パイプ実装            | 一時ファイル経由 | カーネルバッファ  |"
echo "| 大文字小文字          | 区別しない       | 区別する          |"
echo "+-----------------------+------------------+-------------------+"
echo ""
echo "コマンド名の類似性は高い。DIR/ls、COPY/cp、DEL/rm。"
echo "だが設計思想の違いは表面的な類似の下に隠れている。"
echo ""

# =============================================================================
echo "=============================================="
echo "[演習2] パイプとリダイレクションの違いを実感する"
echo "=============================================="
echo ""

# テスト用ログファイルを作成
mkdir -p "${WORKDIR}/logs"
for i in $(seq 1 20); do
    if [ $((i % 3)) -eq 0 ]; then
        STATUS="ERROR"
    else
        STATUS="OK"
    fi
    CPU=$((RANDOM % 100))
    echo "Line $i: server-$(printf "%02d" "$i") status=${STATUS} cpu=${CPU}" >> "${WORKDIR}/logs/server.log"
done

echo "--- 1. UNIXパイプライン: 真のストリーミング ---"
echo ""
echo "  コマンド: cat server.log | grep ERROR | wc -l"
RESULT=$(cat "${WORKDIR}/logs/server.log" | grep ERROR | wc -l)
echo "  結果: ${RESULT}"
echo ""
echo "  UNIXでは3つのプロセスが同時に起動し、"
echo "  データがカーネルバッファを通じてリアルタイムに流れる。"
echo ""

echo "--- 2. DOSパイプのシミュレーション: 一時ファイル方式 ---"
echo ""
echo "  DOSの \"cmd1 | cmd2\" は内部的に以下と等価:"
echo ""
echo "  Step 1: cmd1 > %TEMP%\\pipe001.tmp"
cat "${WORKDIR}/logs/server.log" > "${WORKDIR}/pipe001.tmp"
FILESIZE=$(wc -c < "${WORKDIR}/pipe001.tmp")
echo "          -> 一時ファイルに書き出し (${FILESIZE} bytes)"
echo ""
echo "  Step 2: cmd2 < %TEMP%\\pipe001.tmp"
RESULT=$(grep ERROR < "${WORKDIR}/pipe001.tmp" | wc -l)
echo "          -> 一時ファイルから読み込み (結果: ${RESULT} 行)"
echo ""
echo "  Step 3: DEL %TEMP%\\pipe001.tmp"
rm "${WORKDIR}/pipe001.tmp"
echo "          -> 一時ファイル削除"
echo ""
echo "  結果は同じだが、DOS方式ではcmd1が完全に終了するまで"
echo "  cmd2は実行を開始できない。巨大なデータでは"
echo "  一時ファイルのディスク容量も必要になる。"
echo ""

echo "--- 3. ワイルドカード展開の違い ---"
echo ""

# テスト用ファイル作成
touch "${WORKDIR}/report-jan.txt"
touch "${WORKDIR}/report-feb.txt"
touch "${WORKDIR}/report-mar.txt"
touch "${WORKDIR}/data.csv"

echo "  UNIXでの展開（シェルが行う）:"
# shellcheck disable=SC2086
echo "  \$ echo ${WORKDIR}/report-*.txt"
echo "  $(echo ${WORKDIR}/report-*.txt)"
echo ""
echo "  シェルが *.txt を展開してから echo に渡している。"
echo "  echoコマンド自体はワイルドカードを知らない。"
echo ""

echo "  引数の数を確認:"
# shellcheck disable=SC2086
set -- ${WORKDIR}/report-*.txt
echo "  report-*.txt は ${#} 個のファイルに展開された:"
for arg in "$@"; do
    echo "    - $(basename "$arg")"
done
echo ""
echo "  DOS/Windowsでは:"
echo "  C:\\> PROGRAM *.TXT"
echo "  -> PROGRAMは引数として \"*.TXT\" という文字列を受け取る"
echo "  -> プログラム自身がFindFirstFile/FindNextFileで展開する"
echo ""

# =============================================================================
echo "=============================================="
echo "[演習3] バッチファイル vs シェルスクリプト"
echo "=============================================="
echo ""
echo "同じタスク「ログファイルからERRORを含む行を抽出し、"
echo "出現回数をカウントする」を3つの方法で書く。"
echo ""

# テスト用ログ作成
cat > "${WORKDIR}/app.log" << 'LOGEOF'
2025-01-15 10:00:01 INFO  Server started on port 8080
2025-01-15 10:00:15 ERROR Connection refused: db-primary
2025-01-15 10:01:02 INFO  Request processed: /api/users
2025-01-15 10:01:45 ERROR Timeout: cache-server (5000ms)
2025-01-15 10:02:00 WARN  High memory usage: 85%
2025-01-15 10:02:30 ERROR Connection refused: db-primary
2025-01-15 10:03:00 INFO  Request processed: /api/orders
2025-01-15 10:03:15 ERROR Disk space low: /var/log (92%)
2025-01-15 10:04:00 INFO  Backup completed
2025-01-15 10:04:30 ERROR Connection refused: db-replica
LOGEOF

echo "--- 方法1: DOSバッチファイル (.BAT) の擬似コード ---"
echo ""
echo '  @ECHO OFF'
echo '  REM ERROR行のカウント（DOSバッチ）'
echo '  SET COUNT=0'
echo '  FOR /F "tokens=*" %%L IN ('"'"'FIND /C "ERROR" app.log'"'"') DO SET COUNT=%%L'
echo '  ECHO Error count: %COUNT%'
echo '  REM -> FIND /C は行数を返すが、出力形式のパースが必要'
echo '  REM -> 文字列処理が非常に困難'
echo ""

echo "--- 方法2: UNIX シェルスクリプト (bash) ---"
echo ""
echo "  コマンド: grep -c ERROR app.log"
echo "  結果: $(grep -c ERROR "${WORKDIR}/app.log")"
echo ""
echo "  エラー種別ごとの集計:"
echo "  grep ERROR app.log | awk '{print \$4}' | sort | uniq -c | sort -rn"
grep ERROR "${WORKDIR}/app.log" | awk '{print $4}' | sort | uniq -c | sort -rn | sed 's/^/  /'
echo ""
echo "  -> パイプで小さなツールを連結して一行で実現"
echo ""

echo "--- 方法3: PowerShell（構文の紹介）---"
echo ""
echo '  # PowerShellの場合:'
echo '  Get-Content app.log |'
echo '    Where-Object { $_ -match "ERROR" } |'
echo '    Group-Object { ($_ -split "\s+")[3] } |'
echo '    Sort-Object Count -Descending |'
echo '    Format-Table Count, Name'
echo ""
echo '  # -> オブジェクトパイプラインでテキストのパースを最小化'
echo '  # -> Where-Object: フィルタ（grepに相当）'
echo '  # -> Group-Object: グルーピング（sort | uniq -cに相当）'
echo '  # -> プロパティ名でアクセスするため、列位置に依存しない'
echo ""

echo "--- 設計思想の比較 ---"
echo ""
echo "  DOSバッチ:  テキスト処理能力が貧弱。"
echo "              複雑な処理には外部ツールが必要。"
echo "              FIND, SORT程度しか標準提供されない。"
echo ""
echo "  UNIXシェル: 豊富なテキスト処理ツール群。"
echo "              パイプで組み合わせて強力な処理を実現。"
echo "              だがテキストの「見た目」に依存する。"
echo ""
echo "  PowerShell: オブジェクトを流すパイプライン。"
echo "              型情報を保持するためパースの脆弱性がない。"
echo "              だが冗長で、即興的なワンライナーには不向き。"
echo ""

# =============================================================================
echo "=============================================="
echo "ハンズオン完了"
echo "=============================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "作成されたファイル:"
find "${WORKDIR}" -type f | sort | sed "s|^${WORKDIR}|  ${WORKDIR}|"
echo ""
echo "クリーンアップ: rm -rf ${WORKDIR}"
