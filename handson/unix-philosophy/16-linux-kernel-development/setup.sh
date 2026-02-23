#!/bin/bash
# =============================================================================
# 第16回ハンズオン：Linuxカーネル開発の現場を覗く
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 推奨環境: Docker が利用可能なホスト環境
# 必要なツール: docker
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-16"

echo "=== 第16回ハンズオン：Linuxカーネル開発の現場を覗く ==="
echo ""

# 作業ディレクトリの作成
mkdir -p "${WORKDIR}"

# --- Dockerイメージの取得 ---
echo "[準備] Dockerイメージの取得"
docker pull ubuntu:24.04
echo ""

# --- 演習1: カーネルソースツリーの構造を理解する ---
echo "============================================================"
echo "[演習1] カーネルソースツリーの構造を理解する"
echo "============================================================"
echo ""

docker run --rm ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq git > /dev/null 2>&1

echo "=== Linuxカーネルのソースツリー構造（shallow clone） ==="
git clone --depth 1 https://github.com/torvalds/linux.git /tmp/linux 2>/dev/null

echo ""
echo "=== トップレベルディレクトリ ==="
ls -1 /tmp/linux/ | head -30
echo ""

echo "=== 各ディレクトリの役割 ==="
echo "arch/       -- アーキテクチャ固有のコード（x86, ARM, RISC-V等）"
echo "block/      -- ブロックI/Oレイヤー"
echo "crypto/     -- 暗号化サブシステム"
echo "drivers/    -- デバイスドライバ（全コードの約40%）"
echo "fs/         -- ファイルシステム"
echo "include/    -- ヘッダファイル"
echo "init/       -- カーネル初期化"
echo "ipc/        -- プロセス間通信"
echo "kernel/     -- コアカーネル（スケジューラ、シグナル等）"
echo "lib/        -- カーネル内ライブラリ"
echo "mm/         -- メモリ管理"
echo "net/        -- ネットワークスタック"
echo "scripts/    -- ビルドスクリプト、ツール"
echo "security/   -- セキュリティフレームワーク（SELinux, AppArmor等）"
echo "sound/      -- サウンドサブシステム"
echo "tools/      -- ユーザ空間ツール"
echo ""

echo "=== ソースコードの規模 ==="
echo "総ファイル数（.c + .h）:"
find /tmp/linux -name "*.c" -o -name "*.h" | wc -l
echo ""
echo "ドライバのファイル数（drivers/配下）:"
find /tmp/linux/drivers -name "*.c" -o -name "*.h" | wc -l
echo ""
echo "アーキテクチャ固有のファイル数（arch/配下）:"
find /tmp/linux/arch -name "*.c" -o -name "*.h" | wc -l
echo ""

echo "=== サポートしているアーキテクチャ ==="
ls /tmp/linux/arch/
echo ""

echo "=== ファイルシステム実装 ==="
ls /tmp/linux/fs/
'
echo ""

# --- 演習2: MAINTAINERSファイルを読む ---
echo "============================================================"
echo "[演習2] MAINTAINERSファイルを読む"
echo "============================================================"
echo ""

docker run --rm ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq git > /dev/null 2>&1
git clone --depth 1 https://github.com/torvalds/linux.git /tmp/linux 2>/dev/null

echo "=== MAINTAINERSファイルの規模 ==="
wc -l /tmp/linux/MAINTAINERS
echo ""

echo "=== MAINTAINERSファイルの先頭（フォーマット説明） ==="
head -80 /tmp/linux/MAINTAINERS
echo ""

echo "=== ext4ファイルシステムのメンテナ情報 ==="
grep -A 10 "^EXT4 FILE SYSTEM" /tmp/linux/MAINTAINERS
echo ""

echo "=== メンテナンスステータスの種類 ==="
echo "S: Supported   -- 積極的にメンテナンスされている"
echo "S: Maintained  -- メンテナがいるが限定的"
echo "S: Odd Fixes   -- 時折修正が入る程度"
echo "S: Orphan      -- メンテナ不在"
echo "S: Obsolete    -- 廃止予定"
echo ""

echo "=== ステータス別の件数 ==="
echo -n "Supported:  " && grep -c "^S:.*Supported" /tmp/linux/MAINTAINERS || echo 0
echo -n "Maintained: " && grep -c "^S:.*Maintained" /tmp/linux/MAINTAINERS || echo 0
echo -n "Odd Fixes:  " && grep -c "^S:.*Odd Fixes" /tmp/linux/MAINTAINERS || echo 0
echo -n "Orphan:     " && grep -c "^S:.*Orphan" /tmp/linux/MAINTAINERS || echo 0
echo -n "Obsolete:   " && grep -c "^S:.*Obsolete" /tmp/linux/MAINTAINERS || echo 0
'
echo ""

# --- 演習3: コミットログからカーネル開発の規模を体感する ---
echo "============================================================"
echo "[演習3] コミットログからカーネル開発の規模を体感する"
echo "============================================================"
echo ""

docker run --rm ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq git > /dev/null 2>&1
git clone --depth 5000 https://github.com/torvalds/linux.git /tmp/linux 2>/dev/null

cd /tmp/linux

echo "=== 直近のコミットログ（最新20件） ==="
git log --oneline -20
echo ""

echo "=== マージコミットの構造 ==="
echo "（Linusのマージコミットには、サブシステムの説明が含まれる）"
git log --merges --oneline -10
echo ""

echo "=== コミッターのドメイン別集計（直近5000コミット） ==="
echo "（どの組織から貢献があるかを示す）"
git log --format="%ae" -5000 2>/dev/null | \
  sed "s/.*@//" | sort | uniq -c | sort -rn | head -20
echo ""

echo "=== 直近5000コミットの著者数 ==="
git log --format="%an" -5000 | sort -u | wc -l
echo ""

echo "=== サブシステム別の変更頻度（直近5000コミット） ==="
git log --pretty=format: --name-only -5000 2>/dev/null | \
  grep -v "^$" | cut -d/ -f1 | sort | uniq -c | sort -rn | head -15
'
echo ""

# --- 演習4: カーネルモジュールのコード構造を読む ---
echo "============================================================"
echo "[演習4] カーネルモジュールのコード構造を読む"
echo "============================================================"
echo ""

docker run --rm ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq git > /dev/null 2>&1
git clone --depth 1 https://github.com/torvalds/linux.git /tmp/linux 2>/dev/null

echo "=== 最小のカーネルモジュールの構造 ==="
cat << "SAMPLE"
// hello.c -- 最小のカーネルモジュール
#include <linux/init.h>
#include <linux/module.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Your Name");
MODULE_DESCRIPTION("A minimal kernel module");

static int __init hello_init(void)
{
    pr_info("Hello, kernel world!\n");
    return 0;
}

static void __exit hello_exit(void)
{
    pr_info("Goodbye, kernel world!\n");
}

module_init(hello_init);
module_exit(hello_exit);
SAMPLE
echo ""

echo "=== カーネルモジュールの要素 ==="
echo "MODULE_LICENSE(\"GPL\") -- ライセンス宣言（必須）"
echo "  GPLでないモジュールはカーネルの一部のシンボルにアクセスできない"
echo ""
echo "__init / __exit -- メモリ最適化のためのアノテーション"
echo "  __init: 初期化後にメモリから解放される"
echo "  __exit: モジュールが組み込みの場合はコンパイルから除外される"
echo ""
echo "pr_info() -- カーネルのログ出力関数（dmesgで確認可能）"
echo ""

echo "=== stable-api-nonsense.rstの冒頭 ==="
head -30 /tmp/linux/Documentation/process/stable-api-nonsense.rst
'
echo ""

# --- 演習5: パッチの形式を理解する ---
echo "============================================================"
echo "[演習5] パッチの形式を理解する"
echo "============================================================"
echo ""

docker run --rm ubuntu:24.04 bash -c '
apt-get update -qq && apt-get install -y -qq git > /dev/null 2>&1
git clone --depth 100 https://github.com/torvalds/linux.git /tmp/linux 2>/dev/null

cd /tmp/linux

echo "=== git format-patchが生成するパッチの形式 ==="
git format-patch -1 --stdout HEAD~1 | head -60
echo ""
echo "..."
echo ""

echo "=== パッチ形式の要素 ==="
echo "From:           -- 著者"
echo "Date:           -- 日時"
echo "Subject:        -- タイトル（[PATCH]プレフィックス付き）"
echo "Signed-off-by:  -- DCO署名（法的な来歴の追跡）"
echo "Reviewed-by:    -- レビュー済みの記録"
echo "Acked-by:       -- 承認の記録"
echo "Tested-by:      -- テスト済みの記録"
echo ""
echo "Signed-off-byはDeveloper Certificate of Originへの同意を示す。"
echo "カーネルに取り込まれるすべてのコードの法的な来歴を追跡するための仕組みだ。"
'

echo ""
echo "============================================================"
echo "ハンズオン完了"
echo "============================================================"
echo ""
echo "Linuxカーネルのソースツリーを探索し、コミットログを読み、"
echo "MAINTAINERSファイルの構造を確認した。4,000万行超のコードベースが"
echo "サブシステムメンテナの階層と信頼のネットワークによって維持されている"
echo "ことを体感できたはずだ。"
echo ""
echo "「バザール」は無秩序な自由ではなく、規律ある協働だ。"
