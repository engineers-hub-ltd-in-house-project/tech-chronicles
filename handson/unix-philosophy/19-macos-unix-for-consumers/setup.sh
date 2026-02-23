#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-19"

echo "============================================"
echo " 第19回ハンズオン: macOSのUNIX層を探索する"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================
echo ""
echo ">>> Docker環境の準備"
echo "============================================"
docker pull ubuntu:24.04

# ============================================
echo ""
echo ">>> 演習2: BSDコマンドとGNUコマンドの差異を体験する"
echo "============================================"
docker run --rm ubuntu:24.04 bash -c '
echo "=== BSDコマンドとGNUコマンドの差異 ==="
echo ""

echo "--- GNU sed のバージョン ---"
sed --version 2>&1 | head -1
echo ""

echo "--- sed -i の差異 ---"
echo "Hello World" > /tmp/test.txt
echo "GNU sed (Linux):    sed -i \"s/Hello/Goodbye/\" file"
sed -i "s/Hello/Goodbye/" /tmp/test.txt
echo "結果: $(cat /tmp/test.txt)"
echo ""
echo "BSD sed (macOS):    sed -i \"\" \"s/Hello/Goodbye/\" file"
echo "  → -i の後に空文字列のバックアップ拡張子が必要"
echo ""

echo "--- ポータブルな sed -i ---"
echo "Hello World" > /tmp/portable.txt
sed -i.bak "s/Hello/Portable/" /tmp/portable.txt && rm /tmp/portable.txt.bak
echo "結果: $(cat /tmp/portable.txt)"
echo ""

echo "--- date コマンドの差異 ---"
echo "GNU date (Linux):   date -d \"+1 day\""
date -d "+1 day" "+%Y-%m-%d"
echo "BSD date (macOS):   date -v+1d"
echo "  → 異なるオプション体系"
echo ""

echo "--- readlink の差異 ---"
ln -sf /tmp/test.txt /tmp/link.txt
echo "GNU readlink: readlink -f /tmp/link.txt"
readlink -f /tmp/link.txt
echo "BSD readlink: -f オプションが非対応の場合がある"
'

# ============================================
echo ""
echo ">>> 演習3: XNUカーネルの構造をソースコードから確認する"
echo "============================================"
docker run --rm ubuntu:24.04 bash -c '
echo "=== XNUカーネルのソースコード構造 ==="
echo ""
echo "xnu/"
echo "├── bsd/           ← FreeBSD由来のBSD層"
echo "│   ├── kern/      ← UNIXプロセスモデル"
echo "│   ├── vfs/       ← 仮想ファイルシステム"
echo "│   ├── net/       ← ネットワークスタック"
echo "│   └── sys/       ← システムコール定義"
echo "├── osfmk/         ← Machマイクロカーネル層"
echo "│   ├── kern/      ← タスク、スレッド、スケジューラ"
echo "│   ├── vm/        ← 仮想メモリ管理"
echo "│   ├── ipc/       ← Machポート、メッセージ"
echo "│   ├── arm64/     ← ARM64固有コード"
echo "│   └── x86_64/    ← x86_64固有コード"
echo "├── iokit/          ← IOKitドライバフレームワーク"
echo "└── libkern/        ← カーネル空間ライブラリ"
echo ""
echo "Machタスク ←→ BSDプロセスの二重表現:"
echo "  fork() → BSD層がtask_create()を呼び出し"
echo "  → Machタスクを作成 → BSDプロセス構造体を初期化"
'

# ============================================
echo ""
echo ">>> 演習4: launchdとsystemdの設定比較"
echo "============================================"
docker run --rm ubuntu:24.04 bash -c '
echo "=== launchd vs systemd ==="
echo ""
echo "--- launchd (macOS, 2005年〜) ---"
echo "設定形式: plist (XML)"
echo ""
echo "<?xml version=\"1.0\"?>"
echo "<plist version=\"1.0\">"
echo "  <dict>"
echo "    <key>Label</key>"
echo "    <string>com.example.myservice</string>"
echo "    <key>ProgramArguments</key>"
echo "    <array><string>/usr/local/bin/myservice</string></array>"
echo "    <key>KeepAlive</key><true/>"
echo "    <key>Sockets</key>  <!-- ソケットアクティベーション -->"
echo "  </dict>"
echo "</plist>"
echo ""
echo "--- systemd (Linux, 2010年〜) ---"
echo "設定形式: INI (ユニットファイル)"
echo ""
echo "[Unit]"
echo "Description=My Service"
echo ""
echo "[Service]"
echo "ExecStart=/usr/local/bin/myservice"
echo "Restart=always"
echo ""
echo "[Install]"
echo "WantedBy=multi-user.target"
echo ""
echo "共通点: 宣言的設定、ソケットアクティベーション、自動再起動"
echo "launchd (2005) が systemd (2010) に影響を与えた"
'

# ============================================
echo ""
echo ">>> 演習5: macOSのアーキテクチャ移行の歴史"
echo "============================================"
docker run --rm ubuntu:24.04 bash -c '
echo "=== macOSのアーキテクチャ移行 ==="
echo ""
echo "  1984年  Motorola 68000系"
echo "    ↓"
echo "  1994年  PowerPC"
echo "    ↓"
echo "  2006年  Intel x86/x86_64"
echo "    ↓"
echo "  2020年  Apple Silicon (ARM64)"
echo ""
echo "Machのアーキテクチャ抽象化が移行を支えた。"
echo "XNUのアーキテクチャ固有コードは osfmk/ 配下に分離され、"
echo "カーネルの大部分はアーキテクチャ変更の影響を受けない。"
echo ""
echo "Apple Silicon (arm64e):"
echo "  - 標準ARM64 + Pointer Authentication (PAC)"
echo "  - ROP攻撃への耐性を向上"
echo "  - カーネル空間・ユーザ空間の両方で有効"
'

# ============================================
echo ""
echo "============================================"
echo " 全演習完了"
echo "============================================"
echo ""
echo "macOS環境をお持ちの場合は、記事本文の演習1も"
echo "Terminal.appで実行してみてください。"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
