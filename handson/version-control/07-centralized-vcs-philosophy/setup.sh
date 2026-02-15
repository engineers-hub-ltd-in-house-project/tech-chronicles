#!/bin/bash
# =============================================================================
# 第7回ハンズオン：集中型VCSのメリットをシミュレーションする
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: cvs, subversion
#   apt install cvs subversion / brew install cvs subversion
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/vcs-handson-07"

echo "=== 第7回ハンズオン：集中型VCSのメリットをシミュレーションする ==="
echo ""

# CVSがインストールされているか確認
if ! command -v cvs &> /dev/null; then
    echo "エラー: CVSがインストールされていません"
    echo "  Ubuntu/Debian: sudo apt install cvs"
    echo "  macOS: brew install cvs"
    echo "  Docker: docker run -it --rm ubuntu:24.04 bash"
    echo "          apt update && apt install -y cvs subversion"
    exit 1
fi

# Subversionがインストールされているか確認
if ! command -v svnadmin &> /dev/null; then
    echo "エラー: Subversionがインストールされていません"
    echo "  Ubuntu/Debian: sudo apt install subversion"
    echo "  macOS: brew install subversion"
    exit 1
fi

# 作業ディレクトリの作成
rm -rf "${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# CVSリポジトリの初期化
export CVSROOT="${WORKDIR}/cvsrepo"
cvs init

echo "  -> CVSリポジトリを初期化しました: ${CVSROOT}"
echo ""

# プロジェクトの作成とインポート
mkdir -p "${WORKDIR}/project-import/src"
cd "${WORKDIR}/project-import"

cat > src/app.c << 'SRCEOF'
#include <stdio.h>

int main(void) {
    printf("Centralized VCS Demo\n");
    return 0;
}
SRCEOF

cat > src/config.h << 'SRCEOF'
#ifndef CONFIG_H
#define CONFIG_H
#define APP_VERSION "1.0"
#define APP_NAME "CVS Demo"
#endif
SRCEOF

cvs import -m "Initial import" myproject vendor start 2>&1
cd "${WORKDIR}"
rm -rf project-import

echo "  -> プロジェクトをインポートしました"
echo ""

# --- 演習1: 中央リポジトリの唯一性 ---
echo "================================================================"
echo "[演習1] 中央リポジトリの唯一性"
echo "================================================================"
echo ""
echo "  同一リポジトリから二つの作業コピーを作成し、"
echo "  中央リポジトリが唯一の正であることを確認します。"
echo ""

cvs checkout -d workspace-alice myproject 2>&1
cvs checkout -d workspace-bob myproject 2>&1
echo ""

echo "  -> 二人の開発者をシミュレートしました"
echo "  -> alice: ${WORKDIR}/workspace-alice"
echo "  -> bob:   ${WORKDIR}/workspace-bob"
echo "  -> 両方とも同じ中央リポジトリ（${CVSROOT}）を参照しています"
echo ""

# --- 演習2: コミットの即時反映 ---
echo "================================================================"
echo "[演習2] コミットの即時反映——一貫性の体験"
echo "================================================================"
echo ""

# Aliceがファイルを変更してコミット
cd "${WORKDIR}/workspace-alice"
sed -i 's/1.0/1.1/' src/config.h
cvs commit -m "Alice: Bump version to 1.1" 2>&1
echo ""

echo "  -> Aliceがバージョンを1.1に変更してコミットしました"
echo ""

# Bobのupdate前の状態
cd "${WORKDIR}/workspace-bob"
echo "  --- Bobのupdate前のconfig.h ---"
cat src/config.h
echo ""

# Bobがupdate
cvs update 2>&1
echo ""

echo "  --- Bobのupdate後のconfig.h ---"
cat src/config.h
echo ""

echo "  -> Aliceのコミットは中央リポジトリに即座に反映され、"
echo "     Bobがupdateすることで最新版を取得できます"
echo "  -> 「正しいバージョンはどれか」に曖昧さがありません"
echo "  -> これが集中型VCSの一貫性です"
echo ""

# --- 演習3: Subversionのパスベースアクセス制御 ---
echo "================================================================"
echo "[演習3] Subversionのパスベースアクセス制御"
echo "================================================================"
echo ""

cd "${WORKDIR}"

# SVNリポジトリの作成
svnadmin create "${WORKDIR}/svnrepo"

# authzファイルの作成
cat > "${WORKDIR}/svnrepo/conf/authz" << 'AUTHZEOF'
[groups]
developers = alice, bob
managers = carol

[/]
* = r

[/trunk/src]
@developers = rw

[/trunk/config/production]
@developers = r
@managers = rw

[/trunk/docs/internal]
@managers = rw
* =
AUTHZEOF

# svnserve.confの設定
cat > "${WORKDIR}/svnrepo/conf/svnserve.conf" << 'CONFEOF'
[general]
anon-access = none
auth-access = write
authz-db = authz
password-db = passwd
CONFEOF

# パスワードファイルの作成
cat > "${WORKDIR}/svnrepo/conf/passwd" << 'PASSWDEOF'
[users]
alice = alice_pass
bob = bob_pass
carol = carol_pass
PASSWDEOF

echo "  Subversionのauthzファイルを作成しました:"
echo ""
cat "${WORKDIR}/svnrepo/conf/authz"
echo ""

echo "  === アクセス制御の設計 ==="
echo ""
echo "  [/trunk/src]               developers = rw"
echo "    -> 開発者はソースコードを読み書きできる"
echo ""
echo "  [/trunk/config/production] developers = r, managers = rw"
echo "    -> 開発者は本番設定を読めるが変更はできない"
echo "    -> 管理者だけが本番設定を変更できる"
echo ""
echo "  [/trunk/docs/internal]     managers = rw, * = (空)"
echo "    -> 管理者だけがアクセスでき、他の全員からは見えない"
echo ""
echo "  -> ディレクトリごとに、誰が何をできるかを厳密に制御できます"
echo "  -> Gitにはこのようなパスベースのネイティブなアクセス制御がありません"
echo "  -> Gitのリポジトリは「全か無か」——クローンすれば全履歴が手に入ります"
echo ""

# --- 演習4: サーバ停止の影響 ---
echo "================================================================"
echo "[演習4] 集中型の弱点——サーバが利用不可な場合"
echo "================================================================"
echo ""

cd "${WORKDIR}/workspace-alice"

# ファイルをローカルで変更
echo "// Local change by Alice" >> src/app.c
echo "  ファイルのローカル変更は可能です（エディタが動く限り）"
echo ""

# CVSROOTを無効にしてコミット試行
ORIGINAL_CVSROOT="${CVSROOT}"
export CVSROOT="${WORKDIR}/nonexistent-repo"

echo "  --- サーバが利用不可な場合のコミット試行 ---"
cvs commit -m "Offline commit attempt" 2>&1 || true
echo ""

echo "  --- サーバが利用不可な場合のログ参照試行 ---"
cvs log src/app.c 2>&1 | head -5 || true
echo ""

# CVSROOTを元に戻す
export CVSROOT="${ORIGINAL_CVSROOT}"

# ローカル変更を戻す
cd "${WORKDIR}/workspace-alice"
cvs update -C src/app.c 2>&1 > /dev/null

echo "  -> 中央サーバが利用不可になると："
echo "     - コミットができない"
echo "     - ログの参照ができない"
echo "     - 他の開発者の変更を取得できない"
echo "  -> これが集中型VCSの根本的な制約です"
echo ""
echo "  -> 分散型VCS（Git）では、ローカルリポジトリにコミットでき、"
echo "     過去の履歴もすべて参照できます"
echo ""
echo "  -> ただし、全員が同じオフィスにいた時代、この制約は"
echo "     年に数回のサーバ障害時にしか顕在化しませんでした"
echo ""

# --- 演習5: 設計選択の比較 ---
echo "================================================================"
echo "[演習5] 設計選択の比較まとめ"
echo "================================================================"
echo ""
echo "  +------------------+-------------------+-------------------+"
echo "  | 観点             | 集中型VCS         | 分散型VCS         |"
echo "  +------------------+-------------------+-------------------+"
echo "  | 一貫性           | 強い（構造的保証）| 弱い（規約に依存）|"
echo "  | 可用性           | サーバ依存        | 高い（ローカル）  |"
echo "  | 分断耐性         | なし              | あり              |"
echo "  | アクセス制御     | パスベース（細粒度）| リポジトリ単位   |"
echo "  | バイナリ管理     | 効率的            | 非効率（LFS必要） |"
echo "  | 監査証跡         | 一元管理          | 分散（集約必要）  |"
echo "  | オフライン作業   | 不可              | 完全に可能        |"
echo "  | ブランチコスト   | 高い（CVS）       | ほぼゼロ          |"
echo "  +------------------+-------------------+-------------------+"
echo ""
echo "  どちらが「正しい」かは、利用環境と要件に依存します。"
echo "  2000年代の企業開発チームにとって、集中型は合理的な選択でした。"
echo "  2020年代のOSS/分散チームにとって、分散型が合理的です。"
echo "  ゲーム開発のように、今なお集中型が最適な領域も存在します。"
echo ""

# --- まとめ ---
echo "================================================================"
echo "=== 集中型VCSの設計哲学 まとめ ==="
echo "================================================================"
echo ""
echo "  1. 一貫性の保証"
echo "     -> 中央リポジトリが唯一の信頼できる情報源"
echo "     -> 「正しいバージョンはどれか」に曖昧さがない"
echo ""
echo "  2. アクセス制御"
echo "     -> パスベースの細粒度な権限管理が構造的に可能"
echo "     -> コンプライアンス・監査要件への対応が容易"
echo ""
echo "  3. トレードオフ"
echo "     -> サーバ停止時のリスク（分断耐性の放棄）"
echo "     -> オフライン作業の制約"
echo ""
echo "  集中型VCSは「間違い」ではなく「時代の最適解」でした。"
echo "  そして、その最適解が有効な領域は今も存在します。"
echo ""

echo "=== セットアップ完了 ==="
echo "作業ディレクトリ: ${WORKDIR}"
