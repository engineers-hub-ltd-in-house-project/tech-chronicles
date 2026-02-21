#!/bin/bash
# =============================================================================
# 第21回ハンズオン：CLIデザインの原則を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 推奨環境: docker run -it --rm ubuntu:24.04 bash
# 必要なツール: grep, awk, sort, find, curl, man (apt-get でインストール)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/command-line-handson-21"

echo "=== 第21回ハンズオン：CLIデザインの原則を体験する ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# -------------------------------------------------------
echo "=========================================="
echo " 演習1: manページの構造を読み解く"
echo "=========================================="
echo ""

apt-get update -qq && apt-get install -y -qq man-db coreutils grep gawk > /dev/null 2>&1
echo "[準備完了] man-db, coreutils, grep, gawk をインストールしました"
echo ""

echo "--- manページのセクション構造 ---"
echo ""
echo "manページは8つのセクションに分類される:"
echo "  Section 1: General Commands"
echo "  Section 2: System Calls"
echo "  Section 3: Library Functions"
echo "  Section 4: Special Files"
echo "  Section 5: File Formats"
echo "  Section 6: Games"
echo "  Section 7: Miscellaneous"
echo "  Section 8: System Administration"
echo ""

echo "--- grepのmanページの構造（冒頭） ---"
man grep 2>/dev/null | head -40 || echo "(manページが利用できない環境です)"
echo ""
echo "→ NAME, SYNOPSIS, DESCRIPTIONのヘッダー構造は"
echo "  1971年の初版から50年以上変わっていない。"
echo ""

echo "--- SYNOPSISの表記法 ---"
echo ""
echo "manページのSYNOPSISには以下の表記規約がある:"
echo "  [-abc]    オプショナルなオプション（角括弧）"
echo "  -a|-b     排他的な選択肢（パイプ文字）"
echo "  file ...  繰り返し可能な引数（省略記号）"
echo "  FILE      ユーザーが置き換えるべきメタ引数（大文字/斜体）"
echo ""
echo "例: grep [-cilnvx] [-e pattern] [file ...]"
echo "  → -c, -i, -l, -n, -v, -x はオプショナルなオプション"
echo "  → -e pattern はオプショナルでpatternを引数に取る"
echo "  → file は0個以上のファイル名を受け取る"
echo ""

# -------------------------------------------------------
echo "=========================================="
echo " 演習2: 終了コードの動作を確認する"
echo "=========================================="
echo ""

echo "--- 基本的な終了コード ---"
echo ""

echo "true の終了コード:"
true
echo "  \$? = $?"
echo ""

echo "false の終了コード:"
false || true  # set -e で止まらないように
echo "  \$? = 1 （falseは常に1を返す）"
echo ""

echo "--- grepの終了コード ---"
echo "hello world" | grep "hello" > /dev/null 2>&1
echo "  'hello' を検索 → \$? = $? （見つかった）"

echo "hello world" | grep "xyz" > /dev/null 2>&1 || true
echo "  'xyz' を検索   → \$? = 1 （見つからなかった）"

grep --invalid-option 2> /dev/null || true
echo "  不正なオプション → \$? = 2 （エラー）"
echo ""

echo "--- 終了コードによる制御フロー ---"
echo ""
echo "hello world" > "${WORKDIR}/test.txt"

echo '&& と || による条件実行:'
grep -q "hello" "${WORKDIR}/test.txt" && echo "  'hello' が見つかった（&&で実行）"
grep -q "missing" "${WORKDIR}/test.txt" || echo "  'missing' が見つからなかった（||で実行）"
echo ""

echo "--- sysexits.h の主要な終了コード ---"
echo ""
echo "  EX_OK        (0)   成功"
echo "  EX_USAGE     (64)  コマンドラインの使用法エラー"
echo "  EX_DATAERR   (65)  入力データの形式エラー"
echo "  EX_NOINPUT   (66)  入力ファイルが存在しない"
echo "  EX_SOFTWARE  (70)  内部ソフトウェアエラー"
echo "  EX_OSERR     (71)  OSエラー"
echo "  EX_CANTCREAT (73)  出力ファイルを作成できない"
echo "  EX_TEMPFAIL  (75)  一時的な失敗（リトライ可能）"
echo "  EX_NOPERM    (77)  権限不足"
echo "  EX_CONFIG    (78)  設定エラー"
echo ""
echo "→ 終了コードは、呼び出し側が障害の種類を判断するための'返り値'だ。"
echo "  0が成功で非0が失敗という規約は、シェルの && || if の動作の基盤である。"
echo ""

rm -f "${WORKDIR}/test.txt"

# -------------------------------------------------------
echo "=========================================="
echo " 演習3: stdoutとstderrの分離を体験する"
echo "=========================================="
echo ""

echo "--- stdoutとstderrが分離されている利点 ---"
echo ""
echo "findコマンド（権限エラーのあるディレクトリ）:"
echo ""
echo "  全出力（stdout + stderr）:"
find /etc -name "*.conf" 2>&1 | head -5
echo "  ..."
echo ""
echo "  stdoutのみ（stderrを抑制）:"
find /etc -name "*.conf" 2>/dev/null | head -5
echo "  ..."
echo ""

echo "--- 正しい出力設計のパターン ---"
echo ""
echo "良い設計:"
echo "  stdout → 処理結果のデータ（パイプで次のコマンドに渡せる）"
echo "  stderr → 進捗表示、警告、エラーメッセージ"
echo ""
echo "悪い設計:"
echo "  stdout → データとエラーが混在"
echo "  → パイプの下流で正常なデータとエラーメッセージを区別できない"
echo ""

# curlの出力設計を確認
apt-get install -y -qq curl > /dev/null 2>&1
echo "--- curlの出力設計 ---"
echo "  curl -o file URL  → ダウンロードデータはfileに、進捗はstderrに"
echo "  curl -s URL       → データはstdoutに（-sでstderrの進捗を抑制）"
echo "  curl URL | jq .   → データをパイプで処理（進捗はstderrで端末に表示）"
echo ""
echo "→ curlはstdout/stderrの分離を正しく実装した好例だ。"
echo "  進捗バーはstderrに表示されるため、パイプの下流を汚染しない。"
echo ""

# -------------------------------------------------------
echo "=========================================="
echo " 演習4: CLIオプションの三つの流儀を比較する"
echo "=========================================="
echo ""

echo "--- 1. UNIX伝統スタイル（単一文字オプション） ---"
echo ""
echo "  ls -la          （-l と -a のグループ化）"
ls -la /etc/*.conf 2>/dev/null | head -5
echo "  ..."
echo ""

echo "--- 2. GNU long optionスタイル ---"
echo ""
echo "  ls --all --long  （同じ操作をlong optionで）"
ls --all --long /etc/*.conf 2>/dev/null | head -5
echo "  ..."
echo ""
echo "→ どちらも同じ結果だが、long optionは自己説明的。"
echo "  スクリプトの中では --all --long の方が意図が明確。"
echo ""

echo "--- 3. --help の統一性を確認 ---"
echo ""
echo "あらゆるGNUプログラムで --help が動作する:"
echo ""
echo "[ls --help の冒頭]:"
ls --help 2>&1 | head -5
echo "..."
echo ""
echo "[grep --help の冒頭]:"
grep --help 2>&1 | head -5
echo "..."
echo ""

echo "--- 4. -- （オプション終端マーカー）の重要性 ---"
echo ""
echo "ハイフンで始まるファイル名の扱い:"
touch "${WORKDIR}/-test-file.txt"
echo ""
echo "  rm -test-file.txt      → オプションとして解釈されてエラー"
echo "  rm -- -test-file.txt   → '--' 以降はオペランドとして扱われる"
echo ""
rm -- "${WORKDIR}/-test-file.txt" 2>/dev/null || true
echo "  grep -- '-pattern' file → '-pattern' がパターンとして扱われる"
echo ""
echo "→ POSIXガイドライン10: '--' はオプションの終わりを示す。"
echo "  この規約がなければ、'-'で始まるファイル名や検索パターンを"
echo "  安全に扱う方法がない。"
echo ""

# -------------------------------------------------------
echo "=========================================="
echo " ハンズオン完了"
echo "=========================================="
echo ""
echo "このハンズオンで体験したこと:"
echo "  1. manページの構造（NAME, SYNOPSIS, DESCRIPTION）と表記規約"
echo "  2. 終了コード（0=成功, 非0=失敗）とシェルの制御フロー"
echo "  3. stdout/stderrの分離とパイプラインへの影響"
echo "  4. UNIX伝統/GNU long option/--ダブルダッシュの三つの流儀"
echo ""
echo "→ これらの原則は50年間蓄積されてきたCLI設計の知恵だ。"
echo "  次にCLIツールを作るとき、これらを意識して設計してほしい。"
echo ""

# クリーンアップ
rm -rf "${WORKDIR}"
echo "[クリーンアップ完了] 作業ディレクトリを削除しました: ${WORKDIR}"
