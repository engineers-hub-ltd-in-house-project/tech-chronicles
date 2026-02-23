# 第21回ハンズオン：WSL――WindowsがUNIXに屈服した日

## 概要

WSL 2環境でWindowsとLinuxの境界を体験する。ファイルシステムの二重構造、カーネル機能、OS間の相互運用、性能特性の差異を実際に手を動かして確認する。

## 演習一覧

| # | 演習内容                             | 学べること                                        |
| - | ------------------------------------ | ------------------------------------------------- |
| 1 | WindowsとLinuxのファイルシステム境界 | /mnt/c のマウント構造、9Pプロトコル、ext4 vs NTFS |
| 2 | WSL 2のLinuxカーネル機能確認         | namespaces、cgroups、/procファイルシステム        |
| 3 | Windowsプロセスとの相互運用          | WSLからのWindows exe実行、OS間パイプライン        |
| 4 | ファイルシステム性能比較             | Linux FS vs Windows FS の性能差、VMの境界         |

## 動作環境

- Windows 10 バージョン2004以降、またはWindows 11
- WSL 2が有効化されていること
- 任意のLinuxディストリビューション（Ubuntu推奨）がインストール済み

### WSL 2のセットアップ（未インストールの場合）

PowerShell（管理者権限）で以下を実行:

```powershell
wsl --install
```

再起動後、WSLディストリビューションのセットアップが完了する。

## 実行方法

```bash
chmod +x setup.sh
./setup.sh
```

## 注意事項

- このハンズオンはWSL 2環境での実行を前提としている
- 演習4のWindows FS性能テストは `/mnt/c` へのアクセスが必要
- Docker関連の演習はDocker Desktopがインストールされている場合のみ動作する
- 非WSL環境（通常のLinux）でも一部の演習は動作するが、OS間の境界体験は得られない

## ライセンス

MIT
