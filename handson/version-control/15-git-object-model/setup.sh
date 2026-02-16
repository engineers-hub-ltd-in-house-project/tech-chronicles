#!/bin/bash
# =============================================================================
# 第15回ハンズオン：Gitオブジェクトモデル——blob, tree, commit, tagの内部を解剖する
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: git, python3, xxd
# 推奨環境: docker run -it --rm ubuntu:24.04 bash
#            apt update && apt install -y git python3 xxd
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-15"

echo "=== 第15回ハンズオン：Gitオブジェクトモデルの内部を解剖する ==="
echo ""

# 既存ディレクトリのクリーンアップ
if [ -d "${WORKDIR}" ]; then
  rm -rf "${WORKDIR}"
fi
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# gitの設定（Docker環境用）
git config --global user.email "handson@example.com" 2>/dev/null || true
git config --global user.name "Handson User" 2>/dev/null || true
git config --global init.defaultBranch main 2>/dev/null || true

# --- 演習1: SHA-1ハッシュの手動検証 ---
echo "[演習1] SHA-1ハッシュを手動で検証する"
echo ""

# テスト用のファイル内容を用意
echo -n "Hello, Git Object Model!" > test_content.txt

# gitが計算するハッシュを確認
GIT_HASH=$(git hash-object test_content.txt)
echo "git hash-object の結果: ${GIT_HASH}"

# 手動でSHA-1を計算する
SIZE=$(wc -c < test_content.txt | tr -d ' ')
echo "ファイルサイズ: ${SIZE} バイト"
echo "ヘッダ: \"blob ${SIZE}\\0\""

# Python3でヘッダ + 内容のSHA-1を計算
MANUAL_HASH=$(python3 -c "
import hashlib
content = open('test_content.txt', 'rb').read()
header = f'blob {len(content)}\0'.encode()
sha1 = hashlib.sha1(header + content).hexdigest()
print(sha1)
")
echo "手動計算の結果:         ${MANUAL_HASH}"
echo ""

if [ "${GIT_HASH}" = "${MANUAL_HASH}" ]; then
  echo "-> 一致。gitのSHA-1計算は \"blob {size}\\0{content}\" のSHA-1"
else
  echo "-> 不一致（予期しない結果）"
fi
echo ""
echo "-> ヘッダがなければハッシュは変わる"
RAW_SHA1=$(python3 -c "
import hashlib
content = open('test_content.txt', 'rb').read()
print(hashlib.sha1(content).hexdigest())
")
echo "   内容だけのSHA-1:   ${RAW_SHA1}"
echo "   git hash-objectの値: ${GIT_HASH}"
echo "-> 両者は異なる。ヘッダの存在がgitのハッシュを特徴づける"

# --- 演習2: looseオブジェクトのzlib圧縮を解凍する ---
echo ""
echo "============================================================"
echo "[演習2] looseオブジェクトのzlib圧縮を解凍する"
echo ""

# リポジトリを初期化してオブジェクトを作成
mkdir -p "${WORKDIR}/decompress-test"
cd "${WORKDIR}/decompress-test"
git init --quiet

# ファイルを追加してblobオブジェクトを作成
echo "This is a test file for zlib decompression." > sample.txt
BLOB_HASH=$(git hash-object -w sample.txt)
echo "blobオブジェクトのハッシュ: ${BLOB_HASH}"

# looseオブジェクトのファイルパスを構築
DIR="${BLOB_HASH:0:2}"
FILE="${BLOB_HASH:2}"
OBJ_PATH=".git/objects/${DIR}/${FILE}"
echo "格納先: ${OBJ_PATH}"
echo ""

# ファイルのバイナリ内容を表示（最初の16バイト）
echo "--- 圧縮状態のバイナリ（先頭16バイト）---"
xxd -l 16 "${OBJ_PATH}"
echo ""
echo "-> 先頭バイト 78 はzlibのマジックナンバー"
echo "   78 = CMF（Compression Method and Flags）"
echo ""

# Pythonでzlib解凍して内容を確認
echo "--- zlib解凍後の内容 ---"
python3 -c "
import zlib
with open('${OBJ_PATH}', 'rb') as f:
    compressed = f.read()
decompressed = zlib.decompress(compressed)
null_pos = decompressed.index(b'\x00')
header = decompressed[:null_pos].decode()
content = decompressed[null_pos+1:]
print(f'ヘッダ: \"{header}\"')
print(f'内容:   \"{content.decode()}\"')
print(f'圧縮前: {len(decompressed)} バイト')
print(f'圧縮後: {len(compressed)} バイト')
"
echo ""
echo "-> gitオブジェクト = zlib_deflate(ヘッダ + NULLバイト + 内容)"

# --- 演習3: annotated tagオブジェクトの解剖 ---
echo ""
echo "============================================================"
echo "[演習3] annotated tagオブジェクトの解剖"
echo ""

cd "${WORKDIR}/decompress-test"

# コミットを作成
git add sample.txt
git commit --quiet -m "Initial commit for tag demo"

# lightweight tagを作成
git tag v0.1-light

# annotated tagを作成
git tag -a v0.1 -m "First annotated tag for demonstration"

echo "--- lightweight tag の内部 ---"
LIGHT_REF=$(cat .git/refs/tags/v0.1-light)
echo "refs/tags/v0.1-light の内容: ${LIGHT_REF}"
echo "オブジェクトタイプ: $(git cat-file -t "${LIGHT_REF}")"
echo "-> lightweight tag = commitへのポインタ（gitオブジェクトなし）"
echo ""

echo "--- annotated tag の内部 ---"
ANNOT_REF=$(cat .git/refs/tags/v0.1)
echo "refs/tags/v0.1 の内容: ${ANNOT_REF}"
echo "オブジェクトタイプ: $(git cat-file -t "${ANNOT_REF}")"
echo ""
echo "--- tagオブジェクトの中身 ---"
git cat-file -p "${ANNOT_REF}"
echo ""
echo "-> annotated tag = 独立したtagオブジェクト"
echo "   object: 参照先のcommit"
echo "   type: 参照先のオブジェクトタイプ"
echo "   tag: タグ名"
echo "   tagger: 作成者・日時"
echo "   メッセージ: タグの説明"

# --- 演習4: packファイルの確認 ---
echo ""
echo "============================================================"
echo "[演習4] packファイルの確認"
echo ""

cd "${WORKDIR}/decompress-test"

# 複数のコミットを作成してオブジェクトを増やす
for i in $(seq 1 10); do
  echo "Version ${i} of the file with some content that changes slightly." > sample.txt
  git add sample.txt
  git commit --quiet -m "Update ${i}"
done

echo "--- gc実行前のlooseオブジェクト数 ---"
LOOSE_COUNT=$(find .git/objects -type f ! -path "*/pack/*" ! -path "*/info/*" | wc -l)
echo "looseオブジェクト: ${LOOSE_COUNT} 個"
echo ""

# git gcでpackファイルを生成
echo "--- git gc を実行 ---"
git gc --quiet
echo ""

echo "--- gc実行後 ---"
LOOSE_AFTER=$(find .git/objects -type f ! -path "*/pack/*" ! -path "*/info/*" | wc -l)
PACK_COUNT=$(find .git/objects/pack -name "*.pack" | wc -l)
echo "looseオブジェクト: ${LOOSE_AFTER} 個"
echo "packファイル: ${PACK_COUNT} 個"
echo ""

# packファイルの中身を確認
PACK_FILE=$(find .git/objects/pack -name "*.pack" | head -1)
if [ -n "${PACK_FILE}" ]; then
  IDX_FILE="${PACK_FILE%.pack}.idx"
  echo "--- packファイルの統計 ---"
  git verify-pack -v "${IDX_FILE}" | tail -5
  echo ""
  echo "--- デルタオブジェクトの数 ---"
  DELTA_COUNT=$(git verify-pack -v "${IDX_FILE}" | grep -c "delta" || true)
  echo "${DELTA_COUNT} 個のオブジェクトがデルタ圧縮されている"
fi
echo ""
echo "-> looseオブジェクトがpackファイルに統合された"
echo "-> 類似オブジェクト間のデルタ圧縮でストレージ効率が向上"
echo "-> git verify-pack で内部を確認できる"

echo ""
echo "============================================================"
echo "全演習完了"
echo "============================================================"
