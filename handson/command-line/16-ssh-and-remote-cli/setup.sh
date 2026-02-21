#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/command-line-handson-16"

echo "=============================================="
echo " 第16回ハンズオン: SSHとリモートCLI"
echo " ――距離を超えるテキストインターフェース"
echo "=============================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================
# 環境セットアップ
# ============================================
echo ""
echo "--- 環境セットアップ ---"
apt-get update -qq && apt-get install -y -qq openssh-client openssh-server net-tools > /dev/null 2>&1
echo "OpenSSH インストール完了"
echo ""

# ============================================
# 演習1: SSHの基礎を確認する
# ============================================
echo "=============================================="
echo " 演習1: SSHの基礎を確認する"
echo "=============================================="
echo ""

echo "--- OpenSSHのバージョン ---"
ssh -V
echo ""
echo "→ OpenSSHのバージョンとリンクされた暗号ライブラリが表示される。"
echo "  OpenSSHは1999年にOpenBSDプロジェクトから生まれた。"
echo ""

echo "--- SSHがサポートする暗号アルゴリズム ---"
echo ""
echo "鍵交換アルゴリズム:"
ssh -Q kex 2>/dev/null | head -10
echo "..."
echo ""

echo "暗号化アルゴリズム:"
ssh -Q cipher 2>/dev/null | head -10
echo "..."
echo ""

echo "MAC (Message Authentication Code):"
ssh -Q mac 2>/dev/null | head -10
echo "..."
echo ""

echo "→ SSH-2では暗号アルゴリズムがネゴシエーション可能。"
echo "  クライアントとサーバが共通にサポートするアルゴリズムを自動選択する。"
echo ""

# ============================================
# 演習2: SSH鍵ペアの生成と構造
# ============================================
echo "=============================================="
echo " 演習2: SSH鍵ペアの生成と構造"
echo "=============================================="
echo ""

echo "--- Ed25519鍵ペアの生成 ---"
ssh-keygen -t ed25519 -f "${WORKDIR}/test_key" -N "" -C "handson@example.com"
echo ""

echo "--- 秘密鍵の内容（先頭のみ） ---"
head -3 "${WORKDIR}/test_key"
echo "..."
echo ""
echo "→ PEM形式でエンコードされた秘密鍵。"
echo "  絶対に他人に渡してはならない。"
echo ""

echo "--- 公開鍵の内容 ---"
cat "${WORKDIR}/test_key.pub"
echo ""
echo "→ この公開鍵をリモートサーバの ~/.ssh/authorized_keys に追加することで、"
echo "  パスワードなしでSSH認証が可能になる。"
echo ""

echo "--- 鍵のフィンガープリント ---"
ssh-keygen -l -f "${WORKDIR}/test_key.pub"
echo ""
echo "→ フィンガープリントは鍵のハッシュ値。"
echo "  ホスト鍵の検証時に使用する。"
echo ""

echo "--- 鍵の種類の比較 ---"
echo "  RSA:     最も古い方式、互換性が高い（2048bit以上推奨）"
echo "  ECDSA:   楕円曲線暗号、RSAより短い鍵で同等の安全性"
echo "  Ed25519: 現在の推奨、高速かつ安全、鍵が短い"
echo ""

rm -f "${WORKDIR}/test_key" "${WORKDIR}/test_key.pub"

# ============================================
# 演習3: SSHサーバのホスト鍵を確認する
# ============================================
echo "=============================================="
echo " 演習3: SSHサーバのホスト鍵を確認する"
echo "=============================================="
echo ""

echo "--- ホスト鍵の生成 ---"
mkdir -p /etc/ssh
ssh-keygen -A 2>/dev/null
echo ""

echo "--- 生成されたホスト鍵 ---"
ls -la /etc/ssh/ssh_host_*_key.pub 2>/dev/null
echo ""

echo "--- 各ホスト鍵のフィンガープリント ---"
for keyfile in /etc/ssh/ssh_host_*_key.pub; do
    if [ -f "$keyfile" ]; then
        echo "$(basename "$keyfile"):"
        ssh-keygen -l -f "$keyfile"
        echo ""
    fi
done

echo "→ SSHサーバは複数の種類のホスト鍵を持つ。"
echo "  初回接続時に表示されるフィンガープリントは、"
echo "  これらの鍵のハッシュ値だ。"
echo ""
echo "  'The authenticity of host ... can't be established.'"
echo "  → 接続先のホスト鍵が ~/.ssh/known_hosts に未登録。"
echo "  → 中間者攻撃（MITM）を防ぐための仕組みだ。"
echo ""

# ============================================
# 演習4: ポートフォワーディングの概念
# ============================================
echo "=============================================="
echo " 演習4: SSHポートフォワーディングの概念"
echo "=============================================="
echo ""

echo "--- ローカルフォワーディング (-L) ---"
echo ""
echo "構文: ssh -L [ローカルポート]:[宛先ホスト]:[宛先ポート] 踏み台"
echo ""
echo "例: ssh -L 8080:internal-db:5432 bastion.example.com"
echo ""
echo "  ローカル:8080 → SSHトンネル → bastion → internal-db:5432"
echo ""
echo "  用途: ファイアウォール内のデータベースに"
echo "        ローカルマシンから安全にアクセス"
echo ""

echo "--- リモートフォワーディング (-R) ---"
echo ""
echo "構文: ssh -R [リモートポート]:[宛先ホスト]:[宛先ポート] リモート"
echo ""
echo "例: ssh -R 9090:localhost:3000 public-server.example.com"
echo ""
echo "  public-server:9090 → SSHトンネル → ローカル:3000"
echo ""
echo "  用途: NATの内側にある開発サーバを外部に一時的に公開"
echo ""

echo "--- ダイナミックフォワーディング (-D) ---"
echo ""
echo "構文: ssh -D [ローカルポート] リモート"
echo ""
echo "例: ssh -D 1080 remote-server.example.com"
echo ""
echo "  localhost:1080 がSOCKSプロキシとして動作"
echo ""
echo "→ SSHは単なるリモートシェルではない。"
echo "  暗号化されたネットワークトンネルの汎用基盤だ。"
echo ""

# ============================================
# 演習5: ssh_configによる効率的な接続管理
# ============================================
echo "=============================================="
echo " 演習5: ssh_configによる接続管理"
echo "=============================================="
echo ""

echo "--- ~/.ssh/config の例 ---"
cat << 'SSHCONFIG'

# デフォルト設定（すべてのホストに適用）
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    AddKeysToAgent yes

# 踏み台サーバ
Host bastion
    HostName bastion.example.com
    User admin
    IdentityFile ~/.ssh/id_ed25519_work

# 内部サーバ（踏み台経由、ProxyJump使用）
Host internal-*
    User deploy
    ProxyJump bastion
    IdentityFile ~/.ssh/id_ed25519_work

Host internal-web
    HostName 10.0.1.10

Host internal-db
    HostName 10.0.1.20

# 接続多重化（ControlMaster）
Host *.example.com
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600

SSHCONFIG

echo ""
echo "--- 設定のポイント ---"
echo ""
echo "1. ServerAliveInterval/CountMax:"
echo "   → 60秒ごとにキープアライブを送信、3回失敗で切断"
echo "   → NATタイムアウトやファイアウォールによる切断を防止"
echo ""
echo "2. ProxyJump:"
echo "   → OpenSSH 7.3以降で利用可能"
echo "   → 'ssh internal-web' だけで踏み台経由の接続が完了"
echo ""
echo "3. ControlMaster/ControlPath/ControlPersist:"
echo "   → OpenSSH 3.9以降で利用可能"
echo "   → 同一ホストへの複数接続を一つのTCPコネクションで多重化"
echo "   → 2回目以降の接続が瞬時に確立される"
echo ""

# ============================================
# まとめ
# ============================================
echo "=============================================="
echo " まとめ"
echo "=============================================="
echo ""
echo "1. SSHは1995年にTatu Ylonenが暗号化リモートアクセスとして開発した"
echo "2. OpenSSH（1999年）が事実上の標準実装となっている"
echo "3. SSH-2は3層アーキテクチャで暗号化・認証・チャネル管理を分離"
echo "4. ポートフォワーディングにより任意のTCPトラフィックを暗号化転送可能"
echo "5. ssh_configでProxyJump、ControlMaster等の高度な接続管理が可能"
echo "6. テキストストリームの帯域効率が、リモートCLIの構造的優位性の源泉"
echo ""
echo "=============================================="
echo " ハンズオン完了"
echo "=============================================="
