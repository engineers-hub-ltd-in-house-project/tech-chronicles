# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第5回：CVSの栄光と限界——SourceForge時代の記憶

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- SourceForge全盛期におけるCVSのデファクトスタンダードとしての地位
- CVSがオープンソース文化の爆発的成長にどう貢献したか
- CVSの四大構造的弱点——アトミックコミットの不在、ディレクトリのバージョン管理不可、リネーム非対応、バイナリファイル扱いの問題
- 各弱点がなぜ「設計上の限界」であり「バグ」ではないのか
- CVSの限界が次世代VCSの要件定義書になった歴史的経緯
- CVSの弱点を実際の操作で体験するハンズオン

---

## 1. cvs update が返した「C」の文字

2000年代の前半、私はSourceForgeに登録されたあるOSSプロジェクトに参加していた。プロジェクトの名前は書けないが、当時のWebアプリケーション開発で広く使われていたPHPのライブラリだった。

私がそのプロジェクトに参加したきっかけは単純だ。業務で使っていたライブラリにバグを見つけ、パッチを書いて送ったら、コミット権限をもらったのだ。当時はそういう時代だった。パッチを何本か送れば、「じゃあ自分でコミットしてくれ」と言われる。SourceForgeのプロジェクト管理画面でDeveloperとして追加され、SSH鍵を登録すれば、その日からコミッターだった。

私がそのプロジェクトで最初に体験した衝撃は、`cvs update` が返す一文字のステータスコードだった。

```
U src/parser.php
M src/utils.php
C src/config.php
```

`U` は「更新された」、`M` は「ローカルに変更がある」、そして `C` は——「衝突」（Conflict）。

初めて `C` を見たとき、端末の前で固まった。`config.php` を開くと、見慣れない記号が差し込まれていた。

```
<<<<<<< config.php
$default_charset = 'UTF-8';
=======
$default_charset = 'EUC-JP';
>>>>>>> 1.15
```

CVSのマージが失敗し、衝突マーカーが挿入されたのだ。自分の変更と他の開発者の変更が、同じ行を触っていた。

コンフリクトの解消自体は難しくなかった。だが、そのとき私が感じた不安は技術的なものではなかった。「この `C` が出たということは、リポジトリ上のファイルと自分のファイルの両方が変更されていたということだ。では、もし `cvs commit` の途中でネットワークが切れたら何が起きるのか。複数のファイルを一度にコミットしたとき、一部だけがコミットされて残りが取り残されることはないのか」。

答えは、ある。CVSではそれが起きる。そしてそれは「バグ」ではなく「設計」だった。

CVSは何を成し遂げ、何に失敗したのか。この問いに答えるには、CVSが栄光の頂点にいた時代を正確に描く必要がある。CVSの成功がなければ、その限界も見えてこないからだ。

---

## 2. SourceForge時代——CVSがOSSの基盤だった頃

### 100日で100プロジェクトが生まれる世界

前回、1999年11月のSourceForge開設と、2001年末までに約30,000プロジェクトが登録されたことを書いた。だが、SourceForgeの成長曲線の本当の勢いが見えてくるのは、2002年以降だ。

2002年以降、SourceForgeには1日約100件のペースで新規プロジェクトが登録されるようになった。毎日100件だ。週末も含めて、毎日新しいOSSプロジェクトが100個生まれていた。年間にすれば3万件以上、これが何年も続いた。

2005年、SourceForgeの登録プロジェクト数は10万件を突破した。登録ユーザー数は100万人を超え、2005年5月17日時点で1,074,424人に達していた。2007年には約15万プロジェクトが登録されていた。

この数字が意味するものを考えてほしい。10万を超えるOSSプロジェクトの大半が、CVSをバージョン管理システムとして使っていたのだ。SourceForgeが提供する標準のリポジトリがCVSだったからだ。プロジェクトを登録すれば、CVSリポジトリが自動的に作成される。開発者は `cvs checkout` でソースコードを取得し、`cvs commit` で変更を送信する。それが「OSSに参加する」ということの実際の操作だった。

### 匿名アクセスがもたらした参入障壁の低下

前回触れた `:pserver:` による匿名アクセスは、この時代にその真価を発揮した。

SourceForge上のプロジェクトでは、匿名CVSアクセスが標準的に提供されていた。つまり、アカウントを持っていなくても、誰でもソースコードをチェックアウトできた。Webブラウザでソースコードを閲覧する「ViewCVS」というツールも提供されていたが、実際にコードを読み、ビルドし、手元で修正するには、`cvs checkout` が最も自然なワークフローだった。

```bash
# SourceForgeプロジェクトの典型的な匿名チェックアウト
cvs -d :pserver:anonymous@cvs.sourceforge.net:/cvsroot/projectname login
cvs -d :pserver:anonymous@cvs.sourceforge.net:/cvsroot/projectname checkout modulename
```

この二行のコマンドが、世界中の開発者とOSSプロジェクトを繋ぐインターフェースだった。

あなたが今 `git clone https://github.com/user/repo.git` と打つとき、その一行には、CVSの二行分の思想が凝縮されている。認証なしでリポジトリにアクセスできること。ソースコード全体を手元に取得できること。この二つは、CVSとSourceForgeの時代に確立された「OSSの作法」だ。

### CVSを使わずにOSSに参加することは不可能だった

2000年代前半、主要なOSSプロジェクトの大半がCVSを使っていた。Apache HTTP Server、Mozilla、Python、PHP、FreeBSD、GNOME、KDE——これらのプロジェクトはいずれもCVSでソースコードを管理していた。

OSSプロジェクトに貢献するためのワークフローは、おおむね以下のようなものだった。

まず、`cvs checkout` でソースコードを取得する。次に、変更を加えて `cvs diff -u` でunified diff形式のパッチを生成する。そして、そのパッチをメーリングリストまたはバグトラッカーに投稿する。コミット権限を持つメンテナがパッチをレビューし、問題がなければ `patch` コマンドで適用して `cvs commit` する。

このワークフローは、CVSの設計に深く依存していた。`cvs diff` がunified diff形式を出力できること。作業コピーがリポジトリの特定リビジョンと対応していること。パッチが適用可能かどうかを `cvs update` で検証できること。CVSはOSS開発のインフラそのものだったのだ。

だが、10万プロジェクト、100万ユーザーの規模に達したとき、CVSの構造的な弱点は、もはや見て見ぬふりができないほど顕在化していた。

---

## 3. 四つの致命的弱点——CVSの設計が許さなかったもの

CVSの弱点は、「バグ」ではない。設計上の限界だ。CVSがRCSのラッパーとして生まれた出自に起因する、構造的な制約である。この区別は重要だ。バグは修正できるが、設計上の限界はアーキテクチャの再設計なしには解決できない。

### 弱点1：アトミックコミットの不在

CVSの最も深刻な構造的弱点は、アトミックコミットが存在しないことだ。

「アトミック」（atomic）とは、「不可分」を意味する。アトミックコミットとは、複数のファイルに対する変更をひとつの不可分な単位として記録する機能だ。すべてのファイルが一括してコミットされるか、一つもコミットされないか、そのどちらかしか起きない。中間状態は存在しない。

CVSでは、これが保証されない。`cvs commit` は各ファイルを順番に処理する。ディレクトリ単位でリポジトリのロックを取得し、そのディレクトリ内のファイルをコミットし、ロックを解放する。次のディレクトリに移り、同じことを繰り返す。

この設計の帰結は三つある。

第一に、コミットの途中でプロセスが中断されると、一部のファイルだけがコミットされ、残りは古いリビジョンのまま取り残される。ネットワーク切断、プロセスのkill、マシンのクラッシュ——いずれの場合も、リポジトリは不整合な中間状態に陥る。

第二に、同時に二人の開発者がコミットすると、それぞれのコミットのファイルがインターリーブする可能性がある。開発者Aのコミットのファイル1が書き込まれた後、開発者Bのコミットのファイル1が書き込まれ、その後に開発者Aのファイル2が書き込まれる——という具合に、二つのコミットが混ざり合うことがある。

第三に、CVSには「チェンジセット」——ある一つの論理的変更を構成するファイル群の集合——を記録する仕組みがない。`cvs commit` で複数のファイルを同時にコミットしても、CVSはそれらのファイルが同じ論理的変更の一部であることを記録しない。共通のコミットメッセージだけが、唯一の手がかりになる。

なぜCVSはリポジトリ全体をロックしないのか。理由は単純で、それをやると大規模プロジェクトではロック競合が頻発し、使い物にならなくなるからだ。CVSは「ロック競合の頻度を下げること」と「読み書きがインターリーブするリスク」のトレードオフで、前者を選んだのだ。

gitでは、すべてのコミットがリポジトリ全体のスナップショットとして記録される。コミットはアトミックであることが保証される。あなたが `git commit` したとき、変更が「半分だけ記録される」ことは原理的にあり得ない。この安心感を、CVSの時代の開発者は持っていなかった。

### 弱点2：ディレクトリのバージョン管理不可

CVSはファイルをバージョン管理するが、ディレクトリをバージョン管理しない。この一文の意味を、具体的に考えてみよう。

ソフトウェアのリファクタリングにおいて、ディレクトリ構造の変更は日常的な操作だ。モジュールをサブディレクトリに分割する。不要になったディレクトリを削除する。ディレクトリ名を変更する。CVSでは、これらの操作がすべて困難、あるいは不可能だった。

空のディレクトリを新規に作成することは可能だった。だが、ディレクトリをリポジトリから削除することは不可能だった。中のファイルをすべて `cvs remove` しても、ディレクトリの骨格はリポジトリに残り続ける。`cvs checkout -P` や `cvs update -P` の `-P` フラグ（空ディレクトリを除外する）で運用上の回避はできたが、リポジトリそのものからディレクトリが消えることはなかった。

ディレクトリのリネームは、さらに厄介だった。CVSのマニュアル自身が認めている——「ディレクトリの移動やリネームを行う通常の方法は、ディレクトリ内の各ファイルを一つずつリネーム（移動）することである」。つまり、ディレクトリレベルの操作は存在せず、ファイル単位の操作の繰り返しで代用するしかなかった。

なぜこの設計になったのか。CVSが内部的にRCSの ,v ファイルを使っているからだ。RCSはファイルの履歴を管理するツールであり、ディレクトリの概念は持っていない。CVSはRCSの上にディレクトリレベルの管理層を追加したが、それは「ファイルをディレクトリ構造に沿って配置する」だけであり、「ディレクトリの変更を履歴として記録する」ものではなかった。

### 弱点3：リネーム（ファイル移動）の非対応

ファイルのリネームが追跡できないことは、ディレクトリ問題と根が同じだが、実務上のインパクトはさらに大きかった。

ソフトウェア開発において、ファイル名は変わる。クラスの責務が変われば、クラス名が変わり、ファイル名も変わる。モジュール分割によって、ファイルが別のディレクトリに移動する。これはリファクタリングの最も基本的な操作だ。

CVSでファイルをリネームする「推奨される」手順は、こうだ。

```bash
# CVSでのファイルリネーム（推奨手順）
cvs remove old_name.c
cvs add new_name.c
cvs commit -m "Rename old_name.c to new_name.c"
```

この操作で何が起きるか。`old_name.c` の ,v ファイルはAtticディレクトリに移動し、`new_name.c` はリビジョン1.1から始まる新しい ,v ファイルとして作成される。`old_name.c` の変更履歴と `new_name.c` の変更履歴は、完全に切断される。`cvs log new_name.c` を実行しても、リネーム前の履歴は表示されない。

もう一つの方法として、リポジトリのファイルシステムを直接操作するという裏技があった。リポジトリディレクトリに入り、,v ファイルを手動でリネームする。この方法なら履歴は保持されるが、公式に推奨される方法ではなく、操作を誤ればリポジトリが破損するリスクがあった。

gitでは `git mv old_name.c new_name.c` で済む。gitは内容のハッシュでファイルを追跡するため、ファイル名が変わっても内容が同じであればリネームとして検出できる。この「内容アドレッシング」という設計判断が、CVSには存在しなかった。

### 弱点4：バイナリファイルの扱い

CVSはテキストファイルを前提に設計されている。この前提は、二つの危険な処理に現れる。行末変換とキーワード展開だ。

行末変換は、リポジトリ内の標準形式（LFのみ）とクライアントOS上の形式（WindowsではCR+LF）を相互変換する処理だ。テキストファイルでは便利だが、バイナリファイルにこの変換が適用されると、データが破損する。

キーワード展開は、CVSがRCSから継承した機能だ。ファイル内に `$Id$`、`$Revision$`、`$Date$`、`$Author$` といった特定のキーワードが埋め込まれていると、CVSはcheckout時やupdate時にこれらを自動的に展開する。

```
# キーワード展開の例
$Id$
    ↓ checkout後
$Id: config.c,v 1.15 2003/07/12 14:30:25 sato Exp $
```

テキストファイルでは、ソースコード内にリビジョン情報を自動的に埋め込む便利な機能だった。だが、バイナリファイルの中にたまたま `$Id$` というバイト列が存在すると、CVSはそれをキーワードとして解釈し、展開してしまう。画像ファイル、コンパイル済みバイナリ、圧縮アーカイブ——いずれも、バイト列のパターン次第ではキーワード展開によって静かに破損する可能性があった。

対策として、バイナリファイルには `-kb` オプションを指定する必要があった。

```bash
cvs add -kb image.png
```

この `-kb` が指定されていれば、行末変換もキーワード展開も行われない。だが、この指定はファイルごとに明示的に行う必要があり、指定を忘れると破損が発生する。さらに厄介なことに、キーワード展開モードはバージョン管理されない。古いリビジョンではテキストだったファイルが新しいリビジョンではバイナリになった場合、CVSにはそれを正しく扱う手段がなかった。

加えて、CVSのdiffとmergeはテキスト前提だ。バイナリファイルの差分表示やマージは不可能だった。バイナリファイルの衝突が発生した場合、「どちらのバージョンを採用するか」を人間が選ぶしかなかった。

---

## 4. ハンズオン：CVSの弱点を体験する

ここからは、CVSの弱点を実際に手を動かして確認する。前回のハンズオンでCVSの基本操作を体験した。今回は、CVSの「できないこと」を体験する。できることよりも、できないことを知る方が、ツールの本質が見えてくることがある。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y cvs

# 既に第4回のハンズオン環境がある場合はそのまま利用可能
```

### 演習1：アトミックコミットの不在を確認する

CVSのコミットがファイル単位で逐次処理されることを確認する。

```bash
WORKDIR="${HOME}/vcs-handson-05"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# リポジトリの初期化
export CVSROOT="${WORKDIR}/cvsrepo"
cvs init

# プロジェクトの作成
mkdir -p "${WORKDIR}/project-import/src"
cd "${WORKDIR}/project-import"

cat > src/main.c << 'EOF'
#include <stdio.h>
#include "config.h"

int main(void) {
    printf("Version: %s\n", VERSION);
    return 0;
}
EOF

cat > src/config.h << 'EOF'
#ifndef CONFIG_H
#define CONFIG_H
#define VERSION "1.0"
#endif
EOF

cvs import -m "Initial import" myproject vendor start
cd "${WORKDIR}"
rm -rf project-import
cvs checkout myproject
cd myproject
```

ここからがポイントだ。二つのファイルを論理的に関連する形で変更する。

```bash
# バージョン番号を2.0に上げる（二つのファイルが論理的に関連）
cat > src/config.h << 'EOF'
#ifndef CONFIG_H
#define CONFIG_H
#define VERSION "2.0"
#define NEW_FEATURE 1
#endif
EOF

cat > src/main.c << 'EOF'
#include <stdio.h>
#include "config.h"

int main(void) {
    printf("Version: %s\n", VERSION);
#if NEW_FEATURE
    printf("New feature enabled!\n");
#endif
    return 0;
}
EOF

# 二つのファイルを同時にコミット
cvs commit -m "Bump version to 2.0 and add new feature"
```

CVSの出力を観察してほしい。各ファイルが個別に処理されているのが見える。

```bash
# コミット履歴を確認
cvs log src/main.c
cvs log src/config.h
```

`main.c` と `config.h` のリビジョン番号が独立に振られていることに注目してほしい。main.c が 1.2、config.h が 1.2 だとしても、それは「同じタイミングでコミットされた」ことを意味しない。CVSは、二つのファイルが同じ論理的変更の一部であることを記録していない。

gitであれば、`git log --oneline` で一つのコミットハッシュに二つのファイルの変更が記録される。CVSにはそれがない。

### 演習2：ディレクトリの削除不能を体験する

```bash
# 新しいディレクトリとファイルを追加
mkdir -p src/experimental
cat > src/experimental/test.c << 'EOF'
#include <stdio.h>
void test_func(void) {
    printf("This is experimental.\n");
}
EOF

cvs add src/experimental
cvs add src/experimental/test.c
cvs commit -m "Add experimental module"

# 実験的モジュールが不要になったので削除を試みる
cvs remove -f src/experimental/test.c
cvs commit -m "Remove experimental module"

# ディレクトリは残っている
ls -la src/experimental/
# CVS/ ディレクトリが残る

# リポジトリ内部を確認
ls -la "${CVSROOT}/myproject/src/experimental/"
# Attic/ ディレクトリに ,v ファイルが移動している
ls -la "${CVSROOT}/myproject/src/experimental/Attic/"
```

ファイルを削除しても、リポジトリ内にディレクトリは残り続ける。,v ファイルは `Attic/` サブディレクトリに移動するが、ディレクトリ構造自体は永遠に消えない。

```bash
# -P フラグで空ディレクトリを非表示にする（運用上の回避策）
cd "${WORKDIR}"
rm -rf myproject
cvs checkout -P myproject
ls myproject/src/
# experimental/ は表示されない（-P のおかげ）

# だがリポジトリにはまだ存在する
ls "${CVSROOT}/myproject/src/experimental/"
```

### 演習3：リネームと履歴の断絶を確認する

```bash
cd "${WORKDIR}/myproject"

# 何回か変更を加えて履歴を積む
cat > src/config.h << 'EOF'
#ifndef CONFIG_H
#define CONFIG_H
#define VERSION "2.1"
#define NEW_FEATURE 1
#define APP_NAME "MyApp"
#endif
EOF
cvs commit -m "Add APP_NAME constant"

cat > src/config.h << 'EOF'
#ifndef CONFIG_H
#define CONFIG_H
#define VERSION "2.2"
#define NEW_FEATURE 1
#define APP_NAME "MyApp"
#define MAX_CONNECTIONS 100
#endif
EOF
cvs commit -m "Add MAX_CONNECTIONS constant"

# 現在の履歴を確認（3つのリビジョンがある）
echo "=== リネーム前の履歴 ==="
cvs log src/config.h 2>&1 | head -40

# config.h を settings.h にリネームする
cvs remove -f src/config.h
cp "${CVSROOT}/myproject/src/Attic/config.h,v" /tmp/config_backup.txt 2>/dev/null || true
cat > src/settings.h << 'EOF'
#ifndef SETTINGS_H
#define SETTINGS_H
#define VERSION "2.2"
#define NEW_FEATURE 1
#define APP_NAME "MyApp"
#define MAX_CONNECTIONS 100
#endif
EOF
cvs add src/settings.h
cvs commit -m "Rename config.h to settings.h"

# リネーム後の履歴を確認
echo "=== リネーム後の settings.h の履歴 ==="
cvs log src/settings.h 2>&1 | head -30
```

`settings.h` の `cvs log` には、リビジョン 1.1 から始まる履歴しか表示されない。`config.h` 時代の三つのリビジョン（1.1, 1.2, 1.3）は、完全に別のファイルの履歴として切断されている。

gitでは `git log --follow settings.h` でリネーム前の履歴まで追跡できる。CVSにはこの概念がない。

### 演習4：バイナリファイルの破損を体験する

```bash
# バイナリっぽいデータを含むファイルを作成
# $Id$ というバイト列を意図的に含める
printf 'BINARY\x00DATA\x00WITH\x00$Id$\x00INSIDE' > src/data.bin

# テキストモード（デフォルト）で追加
cvs add src/data.bin
cvs commit -m "Add binary data file (without -kb)"

# ファイルの内容を確認（キーワードが展開されている）
xxd src/data.bin | head -5

# 正しい方法：バイナリモードで管理し直す
cvs remove -f src/data.bin
cvs commit -m "Remove incorrectly added binary"

printf 'BINARY\x00DATA\x00WITH\x00$Id$\x00INSIDE' > src/data.bin
cvs add -kb src/data.bin
cvs commit -m "Add binary data file (with -kb)"

# 今度はキーワード展開されない
xxd src/data.bin | head -5
```

`-kb` なしで追加したバイナリファイルの中の `$Id$` が展開され、ファイルが破損することを確認してほしい。実際の開発現場では、画像ファイルやPDFがこの問題で静かに壊れていた。

### 演習で見えたこと

四つの演習を通じて、CVSの構造的弱点を体感した。

アトミックコミットの不在は、論理的に一体であるべき変更が物理的に分離されることを意味する。ディレクトリの管理不能は、プロジェクト構造の進化をバージョン管理が追跡できないことを意味する。リネームの非対応は、コードの変更履歴の連続性が断たれることを意味する。バイナリファイルの問題は、テキスト以外のアセットの管理に常にリスクが伴うことを意味する。

これらは個別の問題ではない。すべてが、CVSの出自——RCSの上に構築されたラッパーであること——に起因している。RCSはファイル単位のテキスト履歴管理ツールだった。CVSはその上に「プロジェクト」の概念を追加したが、内部のファイル単位・テキスト前提という設計は変えなかった。変えられなかった。

---

## 5. まとめと次回予告

### この回の要点

第一に、CVSは2000年代前半においてOSS開発のデファクトスタンダードだった。SourceForgeが2005年に10万プロジェクト、100万ユーザーを擁する規模に成長した基盤はCVSだった。世界中の開発者が `cvs checkout` と `cvs commit` でOSS開発に参加していた。

第二に、CVSの栄光は同時にその限界を白日の下にさらした。アトミックコミットの不在、ディレクトリのバージョン管理不可、リネーム非対応、バイナリファイルの扱い——四つの構造的弱点は、CVSがRCSのラッパーとして生まれた出自に起因する設計上の限界であり、バグとして修正できるものではなかった。

第三に、CVSの限界は、次世代VCSへの要件定義書となった。PythonプロジェクトがPEP 347でCVSからの移行を決定した際に挙げた理由は、ファイル・ディレクトリのリネーム追跡の欠如、タグ付け操作の低速さ、チェンジセット概念の不在だった。2005年以降、KDE、Python、Mozilla、FreeBSD、GNOMEといった主要OSSプロジェクトが相次いでCVSから移行した。CVSの限界が臨界点に達したのだ。

第四に、CVSの弱点はいずれも「RCSの設計をプロジェクト単位に拡張する際に、根本的な再設計を行わなかったこと」に起因する。ファイル単位のバージョニング、テキスト前提の差分管理、ロックの粒度——これらはRCSの設計そのものであり、CVSはそれをラップしただけだった。

### 冒頭の問いへの暫定回答

CVSは何を成し遂げ、何に失敗したのか。

CVSは、バージョン管理をネットワーク越しの協調開発の基盤にすることに成功した。10万のOSSプロジェクトと100万の開発者をつなぐインフラを提供した。Copy-Modify-Mergeモデルの実用性を証明し、`checkout`/`update`/`commit` のワークフローを確立した。これらの成果は、CVS以降のすべてのバージョン管理システムに引き継がれている。

CVSが失敗したのは、RCSの設計を超えることだった。ファイル単位のバージョニングを超えてプロジェクト全体のスナップショット管理へ、テキスト前提を超えて任意のファイル形式への対応へ、逐次処理を超えてアトミックな操作保証へ——これらの飛躍は、RCSの ,v ファイルの上に築かれたCVSのアーキテクチャでは原理的に不可能だった。

CVSの成功と失敗を理解することは、「既存の設計の上に機能を積み重ねることの限界」を理解することでもある。CVSの限界は、RCSの設計を変えずに拡張した帰結だ。この教訓は、ソフトウェア設計一般に通じる。

### 次回予告

次回は、CVSのもう一つの痛点——ブランチとマージ——に焦点を当てる。

CVS時代の開発者には、「ブランチは怖い」という共通認識があった。ブランチを切ると、いつかマージしなければならない。そしてCVSのマージは地獄だった。コンフリクトの嵐、失われるコンテキスト、マージ追跡の不在。

gitでは `git branch` を毎日何十回も叩く。ブランチのコストは事実上ゼロだ。だが、CVSの時代には「ブランチを切る」という判断自体がリスクだった。なぜそうだったのか。そして「ブランチが怖い」という文化は、開発プラクティスにどのような影響を残したのか。

**第6回「ブランチとマージの悪夢——CVS時代の苦い教訓」**

あなたがgitのブランチを気軽に切れるのは、先人がCVSのブランチで苦しんだからだ。その苦しみの具体的な中身を知らずに、「gitは便利だ」と言うのは、歴史への敬意を欠いていないだろうか。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- GNU CVS Manual, Version 1.11.23. <https://www.gnu.org/software/trans-coord/manual/cvs/cvs.html>
- Wikipedia, "Atomic commit." <https://en.wikipedia.org/wiki/Atomic_commit>
- Wikipedia, "SourceForge." <https://en.wikipedia.org/wiki/SourceForge>
- Fogel, K., "Open Source Development with CVS," Coriolis Group, 1999. <https://durak.org/sean/pubs/software/cvsbook/>
- PEP 347, "Migrating the Python CVS to Subversion." <https://peps.python.org/pep-0347/>
- SourceForge Community Blog, "A Brief History of SourceForge." <https://sourceforge.net/blog/brief-history-sourceforge-look-to-future/>
- Collins-Sussman, B., Fitzpatrick, B. W., Pilato, C. M., "Version Control with Subversion," O'Reilly Media, 2004. <https://svnbook.red-bean.com/>
- KDE.news, "KDE's Switch to Subversion Complete," May 5, 2005. <https://dot.kde.org/2005/05/05/kdes-switch-subversion-complete/>
