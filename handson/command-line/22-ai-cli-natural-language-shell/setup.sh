#!/bin/bash
# =============================================================================
# 第22回ハンズオン：AI+CLIの現在を体験する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 推奨環境: docker run -it --rm ubuntu:24.04 bash
# 必要なツール: find, grep, sed, awk, sort (apt-get でインストール)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/command-line-handson-22"

echo "=== 第22回ハンズオン：AI+CLIの現在を体験する ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# -------------------------------------------------------
echo "=========================================="
echo " 演習1: コマンドの正確性を検証する"
echo "=========================================="
echo ""

apt-get update -qq && apt-get install -y -qq coreutils findutils grep gawk > /dev/null 2>&1
echo "必要なパッケージをインストールしました。"
echo ""

# テスト用のファイルを作成
mkdir -p "${WORKDIR}/mtime-test"
cd "${WORKDIR}/mtime-test"
for i in $(seq 1 10); do
    touch -d "$i days ago" "file_${i}.txt"
    echo "Content of file $i" > "file_${i}.txt"
done
touch -d "2 hours ago" "recent.ts"
touch -d "3 days ago" "old.ts"
touch -d "10 days ago" "ancient.ts"

echo "--- findの-mtimeオプションの挙動を検証する ---"
echo ""

echo "テスト用ファイルを作成しました（file_1.txt〜file_10.txt、*.ts）"
echo ""

echo "1. -mtime -7 （7日以内に変更されたファイル）:"
find . -name "*.txt" -mtime -7 | sort
echo ""

echo "2. -mtime 7 （ちょうど7日前に変更されたファイル）:"
find . -name "*.txt" -mtime 7 | sort
echo ""

echo "3. -mtime +7 （7日より前に変更されたファイル）:"
find . -name "*.txt" -mtime +7 | sort
echo ""

echo "→ -mtime の +/-/なし の違いを知らなければ、"
echo "  AIが生成したfindコマンドの正しさを判断できない。"
echo ""
echo "  -mtime -N: N日以内（N*24時間以内）"
echo "  -mtime N:  ちょうどN日前（N*24時間からN*24+24時間前）"
echo "  -mtime +N: N日より前（N*24+24時間より前）"
echo ""

# -------------------------------------------------------
echo "=========================================="
echo " 演習2: 環境依存のコマンドの差異を確認する"
echo "=========================================="
echo ""

echo "--- GNU sed vs BSD sed のインプレース編集 ---"
echo ""

# テスト用ファイル
echo "Hello World" > "${WORKDIR}/test_sed.txt"

echo "現在の環境:"
sed --version 2>&1 | head -1
echo ""

echo "GNU sed のインプレース編集:"
echo '  sed -i "s/Hello/Hi/g" file.txt'
echo "  → バックアップ拡張子なしでそのまま編集"
echo ""

echo "BSD sed（macOS）のインプレース編集:"
echo '  sed -i "" "s/Hello/Hi/g" file.txt'
echo "  → -i の後に空文字列の引数が必須"
echo ""

echo "ポータブルな代替手段:"
echo '  sed "s/Hello/Hi/g" file.txt > file.tmp && mv file.tmp file.txt'
echo "  → 一時ファイル経由。どの環境でも動作する"
echo ""

# 実際にGNU sedで実行
sed -i 's/Hello/Hi/g' "${WORKDIR}/test_sed.txt"
echo "実行結果:"
cat "${WORKDIR}/test_sed.txt"
echo ""

echo "→ AIが生成したsedコマンドがGNU前提かBSD前提かを"
echo "  判断するには、GNU/BSDの違いの知識が必要。"
echo ""

# -------------------------------------------------------
echo "=========================================="
echo " 演習3: findの評価順序の罠を体験する"
echo "=========================================="
echo ""

# テスト環境
mkdir -p "${WORKDIR}/find-test"
cd "${WORKDIR}/find-test"
touch -d "2 days ago" recent.log
touch -d "40 days ago" old.log
touch -d "60 days ago" ancient.log
echo "recent" > recent.log
echo "old" > old.log
echo "ancient" > ancient.log

echo "--- findのオプション評価順序 ---"
echo ""

echo "ファイル一覧（作成時）:"
ls -la *.log
echo ""

echo "意図: 30日以上古い.logファイルを表示する"
echo ""

echo "正しい順序:"
echo '  find . -name "*.log" -mtime +30 -print'
find . -name "*.log" -mtime +30 -print
echo ""

echo "→ findの述語は左から右に評価される。"
echo "  -deleteを使う場合、条件の後に置かないと"
echo "  意図しないファイルが削除される危険がある。"
echo ""

echo "危険な例（実行はしない）:"
echo '  find . -name "*.log" -delete -mtime +30'
echo "  → -deleteが-mtimeの前にあるため、"
echo "    すべての.logファイルが先に削除される！"
echo ""

echo "安全な例:"
echo '  find . -name "*.log" -mtime +30 -delete'
echo "  → -mtime +30の条件を満たすファイルだけが削除される"
echo ""

echo "→ AIが生成したfindコマンドの述語順序が正しいか、"
echo "  特に-deleteを含む場合は必ず人間が確認すべきだ。"
echo ""

# -------------------------------------------------------
echo "=========================================="
echo " 演習4: 終了コードを使ったコマンド検証"
echo "=========================================="
echo ""

echo "--- AIが生成したコマンドを検証するパターン ---"
echo ""

echo "1. --helpでオプションの存在を確認:"
echo ""

# 存在するオプションの確認
echo "  grep --helpで-cオプションの存在を確認:"
if grep --help 2>&1 | grep -q "\-c"; then
    echo "    → -c オプションは存在する"
else
    echo "    → -c オプションは存在しない"
fi
echo ""

echo "2. --dry-runパターン（破壊的操作の事前確認）:"
echo ""
echo "  多くのCLIツールは--dry-runオプションを持つ。"
echo "  実際の操作を行わず、何が起きるかだけを表示する。"
echo ""
echo "  例:"
echo "    rsync --dry-run -av source/ dest/"
echo "    git clean --dry-run"
echo "    apt-get --dry-run install package"
echo ""

echo "3. typeコマンドでコマンドの存在を確認:"
echo ""
if type find > /dev/null 2>&1; then
    echo "  find: $(type find)"
fi

if type rg > /dev/null 2>&1; then
    echo "  rg: $(type rg)"
else
    echo "  rg: コマンドが見つからない"
    echo "  → AIがripgrepのコマンドを生成しても、"
    echo "    インストールされていなければ実行できない"
fi
echo ""

echo "4. 終了コードによる成否判定:"
echo ""
echo "  エージェント型AIはコマンドの終了コードで"
echo "  成否を判定し、次のステップを決定する。"
echo ""
echo "  if command; then"
echo "    echo '成功: 次のステップへ'"
echo "  else"
echo "    echo '失敗: 代替手段を検討'"
echo "  fi"
echo ""
echo "→ 終了コードの規約が、AIエージェントの動作基盤になっている。"
echo ""

# -------------------------------------------------------
echo "=========================================="
echo " クリーンアップ"
echo "=========================================="
echo ""

rm -rf "${WORKDIR}"
echo "作業ディレクトリを削除しました: ${WORKDIR}"
echo ""

echo "=== 第22回ハンズオン完了 ==="
echo ""
echo "このハンズオンで体験したこと:"
echo "  1. findの-mtimeオプションの+/-/なしの挙動差異"
echo "  2. GNU sed vs BSD sedのインプレース編集の違い"
echo "  3. findの述語評価順序による-deleteの罠"
echo "  4. 終了コード・--help・typeを使ったコマンド検証パターン"
echo ""
echo "AIが生成したコマンドを「監査」するには、CLIの深い理解が不可欠だ。"
