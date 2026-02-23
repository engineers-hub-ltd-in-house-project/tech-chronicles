#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-13"

echo "============================================================"
echo " 第13回ハンズオン：Linuxカーネルに触れる"
echo " セットアップスクリプト"
echo "============================================================"
echo ""

# -----------------------------------------------------------
# 演習環境の準備
# -----------------------------------------------------------
echo "[1/4] Docker環境の起動..."
echo "以下のコマンドでDocker環境を起動してください:"
echo ""
echo "  docker run -it --rm --privileged ubuntu:24.04 bash"
echo ""
echo "※ --privileged フラグはカーネルモジュールのロードに必要です"
echo ""

# -----------------------------------------------------------
# パッケージのインストール
# -----------------------------------------------------------
echo "[2/4] 必要なパッケージのインストール..."

if command -v apt-get &>/dev/null; then
    apt-get update -qq
    apt-get install -y -qq \
        build-essential \
        linux-headers-"$(uname -r)" \
        git \
        bc \
        flex \
        bison \
        libelf-dev \
        libssl-dev \
        kmod \
        procps 2>/dev/null || echo "一部パッケージのインストールに失敗しました（環境依存）"
else
    echo "apt-getが利用できません。手動でパッケージをインストールしてください。"
fi

# -----------------------------------------------------------
# 作業ディレクトリの作成
# -----------------------------------------------------------
echo "[3/4] 作業ディレクトリの作成..."
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# -----------------------------------------------------------
# 演習1: カーネル情報の確認
# -----------------------------------------------------------
echo ""
echo "============================================================"
echo " 演習1: カーネルバージョンの確認と/proc探索"
echo "============================================================"
echo ""
echo "現在のカーネルバージョン:"
uname -r
echo ""
echo "カーネルの詳細情報:"
uname -a
echo ""
echo "/proc/versionの内容:"
cat /proc/version
echo ""
echo "ロード済みカーネルモジュール数:"
lsmod 2>/dev/null | wc -l || echo "lsmodが利用できません"
echo ""

# -----------------------------------------------------------
# 演習2: カーネルソースコードの取得
# -----------------------------------------------------------
echo "============================================================"
echo " 演習2: カーネルソースコードの取得と構造探索"
echo "============================================================"
echo ""
echo "カーネルソースを取得します（浅いクローン）..."
if [ ! -d "${WORKDIR}/linux" ]; then
    git clone --depth 1 https://github.com/torvalds/linux.git "${WORKDIR}/linux" 2>&1 | tail -3
else
    echo "カーネルソースは既に取得済みです"
fi
echo ""
echo "ソースツリーのトップレベル構造:"
ls -d "${WORKDIR}/linux"/*/ 2>/dev/null | sed "s|${WORKDIR}/linux/||" | head -20
echo ""

# -----------------------------------------------------------
# 演習4: カーネルモジュールの準備
# -----------------------------------------------------------
echo "============================================================"
echo " 演習4: カーネルモジュールの自作準備"
echo "============================================================"
echo ""
MODULE_DIR="${WORKDIR}/hello_module"
mkdir -p "${MODULE_DIR}"

cat > "${MODULE_DIR}/hello.c" << 'CEOF'
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("handson");
MODULE_DESCRIPTION("A simple hello world kernel module");
MODULE_VERSION("0.1");

static int __init hello_init(void)
{
    printk(KERN_INFO "Hello from kernel module! This is LKM in action.\n");
    return 0;
}

static void __exit hello_exit(void)
{
    printk(KERN_INFO "Goodbye from kernel module! LKM unloaded.\n");
}

module_init(hello_init);
module_exit(hello_exit);
CEOF

cat > "${MODULE_DIR}/Makefile" << 'MEOF'
obj-m += hello.o

KDIR ?= /lib/modules/$(shell uname -r)/build

all:
	make -C $(KDIR) M=$(PWD) modules

clean:
	make -C $(KDIR) M=$(PWD) clean
MEOF

echo "カーネルモジュールのソースを作成しました: ${MODULE_DIR}/hello.c"
echo ""
echo "ビルドとロードの手順:"
echo "  cd ${MODULE_DIR}"
echo "  make"
echo "  insmod hello.ko"
echo "  dmesg | tail -5"
echo "  rmmod hello"
echo ""

# -----------------------------------------------------------
# 完了
# -----------------------------------------------------------
echo "============================================================"
echo " セットアップ完了"
echo "============================================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "各演習の詳細は記事本文を参照してください。"
echo "演習3（カーネルコンパイル）は以下のコマンドで実行できます:"
echo "  cd ${WORKDIR}/linux"
echo "  make tinyconfig"
echo "  make -j\$(nproc)"
echo ""
