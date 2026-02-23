#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-12"

echo "============================================"
echo " 第12回ハンズオン: GNU宣言とFSF"
echo " 自由ソフトウェアという思想"
echo "============================================"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================
# 演習1: GNU coreutilsの特定
# ============================================
echo "--- 演習1: GNU coreutilsの特定 ---"
echo ""

echo "coreutilsに含まれるコマンド一覧:"
dpkg -L coreutils | grep '/usr/bin/' | sort
echo ""

echo "主要コマンドのバージョン確認:"
for cmd in ls cat sort cp mv rm mkdir chmod head tail wc cut; do
    if command -v "$cmd" > /dev/null 2>&1; then
        version=$("$cmd" --version 2>&1 | head -1 || true)
        echo "  $cmd: $version"
    fi
done
echo ""

# ============================================
# 演習2: GNUコンポーネントの確認
# ============================================
echo "--- 演習2: GNUコンポーネントの確認 ---"
echo ""

echo "Bashバージョン:"
bash --version | head -1
echo ""

echo "GNU grepバージョン:"
grep --version | head -1
echo ""

echo "GNU sedバージョン:"
sed --version | head -1
echo ""

echo "glibc（GNU Cライブラリ）バージョン:"
ldd --version 2>&1 | head -1
echo ""

echo "GCCのインストールと確認:"
if command -v gcc > /dev/null 2>&1; then
    gcc --version | head -1
else
    echo "  GCCはインストールされていません"
    echo "  apt-get install -y gcc でインストールできます"
fi
echo ""

# ============================================
# 演習3: BusyBoxとの比較
# ============================================
echo "--- 演習3: BusyBoxとの比較（GNU coreutils側の情報） ---"
echo ""

echo "GNU coreutils ls のサイズ:"
ls -la /usr/bin/ls
echo ""

echo "GNU coreutils ls のオプション数:"
ls_opts=$(ls --help 2>&1 | grep -c '^ *-' || true)
echo "  約 ${ls_opts} 個のオプション"
echo ""

echo "BusyBox環境との比較は以下のコマンドで確認:"
echo "  docker run --rm alpine:3.20 sh -c 'ls -la /bin/ls; wc -c < /bin/busybox'"
echo "  docker run --rm alpine:3.20 sh -c 'ls --help 2>&1 | grep -c \"^ *-\"'"
echo ""

# ============================================
# 演習4: GPLライセンスの確認
# ============================================
echo "--- 演習4: GPLライセンスの確認 ---"
echo ""

for pkg in coreutils bash grep; do
    copyright_file="/usr/share/doc/${pkg}/copyright"
    if [ -f "$copyright_file" ]; then
        echo "${pkg} のライセンス（先頭20行）:"
        head -20 "$copyright_file"
        echo "..."
        echo ""
    fi
done

# ============================================
# 演習5: ソースコードへのアクセス
# ============================================
echo "--- 演習5: ソースコードへのアクセス ---"
echo ""

echo "ソースコード取得の準備（dpkg-dev）:"
if command -v dpkg-source > /dev/null 2>&1; then
    echo "  dpkg-dev は既にインストールされています"
else
    echo "  apt-get install -y dpkg-dev でインストール後、以下を実行:"
fi
echo ""
echo "  cd /tmp"
echo "  apt-get source coreutils"
echo "  ls coreutils-*/src/ | head -20"
echo "  wc -l coreutils-*/src/ls.c"
echo "  head -30 coreutils-*/src/ls.c"
echo ""

echo "============================================"
echo " ハンズオン環境のセットアップ完了"
echo " 作業ディレクトリ: ${WORKDIR}"
echo "============================================"
