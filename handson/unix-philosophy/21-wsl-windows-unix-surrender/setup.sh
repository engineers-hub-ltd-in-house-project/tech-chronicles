#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-21"

echo "============================================"
echo " 第21回ハンズオン"
echo " WSL――WindowsがUNIXに屈服した日"
echo "============================================"
echo ""
echo "作業ディレクトリ: $WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習1: WindowsとLinuxのファイルシステム境界"
echo "============================================"
echo ""

echo "=== WSL環境情報 ==="
echo "カーネルバージョン: $(uname -r)"
if [ -f /etc/os-release ]; then
    echo "ディストリビューション: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')"
fi
echo "アーキテクチャ: $(uname -m)"
echo ""

# WSL環境かどうかを判定
IS_WSL=false
if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
    echo "WSL環境を検出した。Microsoft製Linuxカーネルが動作している。"
else
    echo "注意: WSL環境ではない。一部の演習は動作しない。"
fi
echo ""

echo "--- Linux側のルートファイルシステム ---"
ls /
echo ""
echo "UNIXの伝統的なディレクトリ構造が見える。"
echo "/bin, /etc, /home, /proc, /sys, /usr, /var..."
echo "この構造は1979年のVersion 7 Unixから基本的に変わっていない。"
echo ""

if [ "$IS_WSL" = true ] && [ -d "/mnt/c" ]; then
    echo "--- Windows側のファイルシステム（/mnt/c） ---"
    ls /mnt/c/ 2>/dev/null | head -10
    echo ""
    echo "/mnt/c/ はWindowsのCドライブをマウントしたもの。"
    echo "9Pプロトコル経由でアクセスしている。"
    echo ""

    echo "--- ファイルシステムの種類を確認 ---"
    df -T / /mnt/c 2>/dev/null || echo "(df コマンドの実行に失敗)"
    echo ""
    echo "Linux側はext4、Windows側は9p（Plan 9 File Protocol）。"
    echo "第18回で取り上げたPlan 9の遺産がここに生きている。"
else
    echo "(WSL環境でないため、Windows FSの確認はスキップ)"
fi

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習2: WSL 2のLinuxカーネル機能"
echo "============================================"
echo ""

echo "--- namespaces（カーネルの隔離機能） ---"
ls -la /proc/self/ns/ 2>/dev/null || echo "(namespaceの確認に失敗)"
echo ""
echo "各エントリがカーネルnamespaceのIDを示す。"
echo "mnt, pid, net, uts, ipc, user..."
echo "第20回で扱ったDockerコンテナも、"
echo "この同じnamespace機構で隔離されている。"
echo ""

echo "--- cgroups ---"
cat /proc/self/cgroup 2>/dev/null || echo "(cgroupsの確認に失敗)"
echo ""
echo "cgroupsはプロセスのリソース使用量を制限する機構だ。"
echo "WSL 2は実際のLinuxカーネルを動かしているため、"
echo "namespacesもcgroupsも完全に利用可能。"
echo "WSL 1ではこれらは利用できなかった。"
echo ""

echo "--- /proc/version: カーネルの素性 ---"
cat /proc/version
echo ""
if [ "$IS_WSL" = true ]; then
    echo "'microsoft'の文字列が含まれている。"
    echo "Microsoftが独自にビルドしたLinuxカーネルだ。"
    echo "2001年に『Linuxは癌だ』と言った企業が、"
    echo "今やLinuxカーネルを自社でビルドして配布している。"
fi

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習3: Windowsプロセスとの相互運用"
echo "============================================"
echo ""

if [ "$IS_WSL" = true ]; then
    echo "--- WSLからWindowsのexeを直接実行 ---"
    echo "Windowsのホスト名:"
    hostname.exe 2>/dev/null || echo "(hostname.exeの実行に失敗)"
    echo ""

    echo "--- WSL環境変数で見るOS間の統合 ---"
    echo "PATH内のWindows実行パス:"
    echo "$PATH" | tr ':' '\n' | grep -i "windows\|mnt/c" | head -5
    echo ""
    echo "WSLのPATHにはWindows側の実行パスが含まれている。"
    echo "これにより、Linux側からWindows実行ファイルを"
    echo "パス指定なしで呼び出せる。"
    echo ""

    echo "--- UNIXパイプでWindowsコマンドとLinuxコマンドを連携 ---"
    echo ""
    echo "ipconfig.exeの出力をLinuxのgrepでフィルタ:"
    ipconfig.exe 2>/dev/null | grep "IPv4" || echo "(ipconfig.exeの実行に失敗)"
    echo ""
    echo "LinuxのgrepがWindowsのipconfig.exeの出力をフィルタしている。"
    echo "二つのOSの世界がUNIXのパイプで繋がっている。"
    echo "パイプというUNIXの発明（1973年、Doug McIlroy）が、"
    echo "OS境界すら超える力を見せている。"
else
    echo "(WSL環境でないため、Windows相互運用テストはスキップ)"
fi

# -------------------------------------------------
echo ""
echo "============================================"
echo " 演習4: ファイルシステム性能比較"
echo "============================================"
echo ""

LINUX_DIR="$WORKDIR/bench-linux"
FILE_COUNT=1000

echo "WSL 2のファイルシステム性能は、"
echo "ファイルの置き場所によって劇的に異なる。"
echo ""

# Linux FS上でのテスト
mkdir -p "$LINUX_DIR"
echo "--- Linux FS上（ext4）での小ファイル作成: ${FILE_COUNT}個 ---"
START=$(date +%s%N)
for i in $(seq 1 $FILE_COUNT); do
    echo "test content $i" > "$LINUX_DIR/file_$i.txt"
done
END=$(date +%s%N)
LINUX_TIME=$(( (END - START) / 1000000 ))
echo "所要時間: ${LINUX_TIME}ms"
rm -rf "$LINUX_DIR"
echo ""

# Windows FS上でのテスト（WSL環境かつ/mnt/cが存在する場合のみ）
if [ "$IS_WSL" = true ] && [ -d "/mnt/c" ]; then
    WIN_DIR="/mnt/c/temp/wsl-bench-win"
    mkdir -p "$WIN_DIR" 2>/dev/null
    if [ -d "$WIN_DIR" ]; then
        echo "--- Windows FS上（9P/NTFS）での小ファイル作成: ${FILE_COUNT}個 ---"
        START=$(date +%s%N)
        for i in $(seq 1 $FILE_COUNT); do
            echo "test content $i" > "$WIN_DIR/file_$i.txt"
        done
        END=$(date +%s%N)
        WIN_TIME=$(( (END - START) / 1000000 ))
        echo "所要時間: ${WIN_TIME}ms"
        rm -rf "$WIN_DIR"
        echo ""

        echo "--- 結果比較 ---"
        echo "Linux FS:   ${LINUX_TIME}ms"
        echo "Windows FS: ${WIN_TIME}ms"
        if [ "$LINUX_TIME" -gt 0 ]; then
            RATIO=$((WIN_TIME / LINUX_TIME))
            echo "差: 約${RATIO}倍"
        fi
        echo ""
        echo "Linux FS上の操作が圧倒的に速い。"
        echo "WSL 2ではプロジェクトファイルをLinux側（/home/...）に"
        echo "置くことが強く推奨される理由がここにある。"
        echo "VMの境界がそのまま性能特性に現れている。"
    else
        echo "(Windows側ディレクトリの作成に失敗)"
    fi
else
    echo "(WSL環境でないため、Windows FSとの性能比較はスキップ)"
    echo "Linux FS上の結果のみ: ${LINUX_TIME}ms (${FILE_COUNT}ファイル作成)"
fi

# -------------------------------------------------
echo ""
echo "============================================"
echo " まとめ"
echo "============================================"
echo ""
echo "WSL 2の本質:"
echo "  1. 実際のLinuxカーネルがHyper-V軽量VM上で動作する"
echo "  2. namespaces/cgroupsが利用可能（Dockerも動作する）"
echo "  3. Windows FSとLinux FSの間には性能の壁がある"
echo "  4. 9Pプロトコル（Plan 9由来）がOS間の橋渡しをする"
echo "  5. UNIXのパイプはOS境界を超えて機能する"
echo ""
echo "Microsoftは2001年にLinuxを「癌」と呼んだ。"
echo "2019年に自社OS上でLinuxカーネルを動かし始めた。"
echo "2025年にWSLをオープンソース化した。"
echo ""
echo "この変遷は、UNIXの設計思想が「選択肢の一つ」から"
echo "「開発者にとっての必需品」になったことの証左だ。"

# クリーンアップ
rm -rf "$WORKDIR"
echo ""
echo "（作業ディレクトリをクリーンアップ完了）"
