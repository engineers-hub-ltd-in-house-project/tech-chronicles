# 第18回ハンズオン：TUIの復権――Charm, Bubbletea, Ink, Textual

## 概要

ncursesによる古典的TUIプログラミングと、Bubbleteaによるモダンなアプローチの違いを体験する。
さらに、htopやMidnight Commanderといった実用TUIアプリケーションを通じて、TUIの構造的優位性を確認する。

## 演習一覧

| 演習  | 内容                          | 学べること                                          |
| ----- | ----------------------------- | --------------------------------------------------- |
| 演習1 | ncursesで最小TUIを構築        | 命令的UI設計（座標管理、手動描画）                  |
| 演習2 | Bubbleteaでリストアプリを構築 | 宣言的UI設計（Elm Architecture: Model-Update-View） |
| 演習3 | htop、mcの実用TUI体験         | TUIアプリケーションの「ちょうどよさ」               |

## 動作環境

- Docker（ubuntu:24.04ベース）
- 必要なツール: gcc, libncurses-dev, golang-go, htop, mc

## セットアップ

```bash
bash setup.sh
```

## ライセンス

MIT
