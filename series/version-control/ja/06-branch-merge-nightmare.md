# git ありきの世界に警鐘を鳴らす

## ——バージョン管理の根源から未来を考える

### 第6回：ブランチとマージの悪夢——CVS時代の苦い教訓

**連載「git ありきの世界に警鐘を鳴らす」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- CVS時代に「ブランチが怖い」という文化が生まれた技術的背景
- CVSのブランチがRCSのリビジョン番号体系に基づく構造的な制約を抱えていたこと
- マージ追跡の不在が開発現場にもたらした具体的な痛み
- 「トランクベース開発」がCVS時代に事実上の標準だった理由
- CVSのブランチとGitのブランチの設計思想の根本的な違い
- CVSでブランチ作成・マージを実際に行い、その痛みを体感するハンズオン

---

## 1. 金曜日の午後、ブランチマージに費やした一日

2003年頃のことだ。私はあるWebアプリケーションの開発チームで、リリースブランチからトランクへのマージ作業を任されていた。

リリースブランチは、約3か月前に切られたものだった。本番環境で見つかったバグを修正するためのブランチで、その間に15件ほどのバグフィックスがコミットされていた。一方、トランクではバージョン2.0に向けた新機能の開発が進んでいた。ファイル数にして200以上、開発者は5人。3か月間のトランクのコミット数は、数百に達していた。

金曜日の午前中、私はマージを始めた。

```
cvs update -j release-1.5
```

端末に表示される出力を見ながら、私は嫌な予感がしていた。`U` や `M` が流れていく中に、`C` が次々と現れる。コンフリクト——衝突だ。

```
RCS file: /cvsroot/project/src/auth/login.php,v
retrieving revision 1.12
retrieving revision 1.12.2.5
Merging differences between 1.12 and 1.12.2.5 into login.php
rcsmerge: warning: conflicts during merge
C src/auth/login.php
```

この `C` が、一つや二つではなかった。数えると、30ファイル以上でコンフリクトが発生していた。

一つひとつのコンフリクトを解消すること自体は、技術的に難しい作業ではない。衝突マーカーを読み、トランク側の変更とブランチ側の変更を理解し、正しい統合結果を書く。だが、30ファイル以上のコンフリクトを、ファイル間の依存関係を考慮しながら解消するのは、集中力と時間を要する作業だった。

さらに厄介だったのは、マージ対象のブランチで、既にトランクの変更を一部取り込む「逆マージ」が行われていたことだ。つまり、ブランチ側で `cvs update -j HEAD` のような操作が途中で行われており、どの変更がブランチ固有で、どの変更がトランクから取り込んだものかの区別がつかなくなっていた。

CVSはマージの履歴を記録しない。一度マージした変更を、次回のマージで除外する仕組みがない。だから、3か月分の変更を一括でマージすると、既にマージ済みの変更と未マージの変更が混ざり合い、コンフリクトの原因が「本当の衝突」なのか「二重マージ」なのか判別できなかった。

結局、その日は夜までかかった。マージ作業を終え、テストを通し、`cvs commit` するまでに丸一日を費やした。そして翌週、そのマージコミットに起因するバグが2件見つかった。

この経験は私だけのものではない。CVSを使っていた開発者なら、似たような体験を持っているはずだ。「ブランチマージの日」は、チーム全体が憂鬱になるイベントだった。

なぜ「ブランチが怖い」という文化が生まれたのか。その答えは、CVSのブランチモデルの技術的構造にある。

---

## 2. CVSのブランチモデル——RCSの番号体系が強いた制約

### ブランチは「番号」だった

CVSのブランチを理解するには、RCSのリビジョン番号体系に立ち返る必要がある。

RCSでは、すべてのリビジョンに番号が振られる。トランク（主系列）のリビジョンは `1.1`, `1.2`, `1.3` と連番で増えていく。ブランチは、この番号体系の「拡張」として表現される。

リビジョン `1.4` からブランチを作成すると、CVSは最初の未使用の偶数整数を選び、ブランチ番号 `1.4.2` を割り当てる。そのブランチ上のリビジョンは `1.4.2.1`, `1.4.2.2`, `1.4.2.3` と続く。

```
トランク:     1.1 → 1.2 → 1.3 → 1.4 → 1.5 → 1.6
                                  |
ブランチ:                         +→ 1.4.2.1 → 1.4.2.2 → 1.4.2.3
```

この図を見て、何か気づくだろうか。ブランチ番号は**ファイルごとに異なる**のだ。

トランク上で、`main.c` がリビジョン `1.8` で、`config.h` がリビジョン `1.4` で、`utils.c` がリビジョン `1.12` だとする。この状態からブランチを作ると、ブランチ上の番号はファイルごとにこうなる。

```
main.c:   トランク 1.8  → ブランチ 1.8.2.1, 1.8.2.2, ...
config.h: トランク 1.4  → ブランチ 1.4.2.1, 1.4.2.2, ...
utils.c:  トランク 1.12 → ブランチ 1.12.2.1, 1.12.2.2, ...
```

gitのブランチは、リポジトリ全体に対して一つのポインタだ。`feature-login` というブランチは、リポジトリの状態を表す一つのコミットハッシュを指す。CVSでは、「ブランチ」はファイルごとに異なるリビジョン番号の集合体であり、それらを束ねるのはシンボリックなタグ名だけだった。

### タグとブランチ——似て非なるもの

CVSにおけるタグとブランチの関係は、初学者を混乱させる代表的な概念だった。

タグとは、各ファイルの特定リビジョンにシンボリックな名前を付与する操作だ。`cvs tag release-1.0` を実行すると、作業コピー内の各ファイルの現在のリビジョン番号に `release-1.0` という名前が付く。ある文献はこれを「ファイル名 x リビジョン番号のマトリクスを横切る曲線」と表現している。

ブランチは、`cvs tag -b branchname` で作成する。`-b` フラグがタグとブランチを分ける。内部的には、ブランチもタグの一種だが、「そのタグを起点として新しいリビジョンをコミットできる」という点でタグと異なる。

ここで重要なのは、タグもブランチも、**ファイル単位で処理される**ということだ。`cvs tag -b release-branch` を実行すると、CVSはリポジトリ内のすべてのファイルに対して個別にブランチタグを記録する。ファイルが1,000あれば、1,000回のタグ記録操作が行われる。

gitでブランチを作成する場合を考えよう。`git branch feature-login` と打つと、`.git/refs/heads/feature-login` というファイルが一つ作成される。中身は41バイト——コミットのSHA-1ハッシュ40文字と改行文字1つだ。ファイルが1,000あっても10,000あっても、ブランチの作成は41バイトのファイルを一つ書き込むだけの操作だ。

CVSでは、ブランチの作成コストはファイル数に比例する。gitでは、ブランチの作成コストは定数だ。この差は、プロジェクトの規模が大きくなるほど拡大する。

### stickyタグの罠

CVSのブランチにはもう一つ、初心者を躓かせる仕組みがあった。「stickyタグ」だ。

`cvs update -r branchname` でブランチに切り替えると、作業コピーの各ファイルにstickyタグが設定される。stickyタグとは、そのファイルが特定のブランチまたはリビジョンに「固定」されていることを示す内部的なメタデータだ。

stickyタグが設定されている間、`cvs update` は通常のトランクのHEADではなく、そのブランチの最新リビジョンに同期する。`cvs commit` は、そのブランチに対してコミットする。ここまでは合理的に聞こえる。

問題は、ブランチでの作業を終えてトランクに戻るときに発生した。`cvs update -A` を実行してstickyタグを解除しなければ、作業コピーはブランチに固定されたままだ。これを知らずに——あるいは忘れて——トランクのつもりで作業を続けると、意図しないブランチにコミットしてしまう。

さらに厄介なケースがあった。非ブランチタグ、つまり通常のリリースタグなどにstickyが設定されると、そのファイルはコミットすらできなくなる。端末には `cvs server: sticky tag 'release-1.0' is not a branch` という不可解なエラーメッセージが表示される。CVSの利用者なら、このエラーメッセージに一度は遭遇したことがあるだろう。

gitには、この概念に相当するものがない。`git checkout feature-login` でブランチを切り替え、`git checkout main` で戻る。現在のブランチは `.git/HEAD` ファイルに記録されており、状態は常に明示的だ。`git status` を叩けば、今どのブランチにいるかが一目でわかる。CVSでは、自分が今どのブランチにいるかを確認するために `cvs status` を実行し、stickyタグの欄を確認する必要があった。しかもその情報はファイルごとに異なる可能性があった——同じ作業コピー内で、あるファイルはブランチ上、別のファイルはトランク上、ということが起こり得たのだ。

---

## 3. マージ追跡の不在——CVSのブランチが「怖い」本当の理由

### ブランチは切れる。だが、帰ってこれるのか

CVSでブランチを切ること自体は、コマンド一つで済む。

```bash
cvs tag -b release-branch
cvs update -r release-branch
```

二行のコマンドで、ブランチが作成され、作業コピーがそのブランチに切り替わる。ここまでは問題ない。

本当の恐怖は、マージのときにやってくる。

ブランチでの作業が完了し、その変更をトランクに統合する。CVSでの手順はこうだ。

```bash
# トランクに戻る
cvs update -A

# ブランチの変更をトランクにマージ
cvs update -j release-branch
```

`cvs update -j` は、ブランチの分岐点から現在のブランチHEADまでの変更を、トランクの作業コピーに適用する。内部的にはrcsmergeが呼ばれ、diff3による3-way mergeが実行される。共通祖先（ブランチの分岐点）、トランクの現在リビジョン、ブランチの現在リビジョンの三者を比較し、矛盾のない変更は自動的に統合され、矛盾する変更にはコンフリクトマーカーが挿入される。

ここまでは、gitの `git merge` と原理的には同じだ。3-way mergeという手法自体は、CVSもgitも共有している。

では、何が違うのか。

### 二度目のマージが地獄を生む

違いは、**二度目のマージ**で露わになる。

現実のソフトウェア開発では、ブランチは一度マージして終わりではない。リリースブランチでバグ修正が続けられ、定期的にトランクにマージする。あるいは、トランクの変更をブランチに取り込む「逆マージ」が行われる。ブランチとトランクの間で、変更が行き来するのだ。

gitでは、これは問題にならない。`git merge` はコミットグラフ上にマージコミットを記録し、次回のマージでは「前回のマージコミット以降の変更」だけを対象にする。gitはマージの履歴を知っている。

CVSは、マージの履歴を知らない。

一度目のマージを行った後、ブランチでさらに修正が加えられたとする。二度目のマージで `cvs update -j release-branch` を再度実行すると、CVSは前回マージした変更を含めて、ブランチの分岐点からのすべての変更を再度マージしようとする。既にトランクに取り込まれた変更と、新たに追加された変更の区別がつかないのだ。

その結果、以下のいずれか、あるいはすべてが起こる。

第一に、既にマージ済みの変更を再適用することで、意味不明なコンフリクトが大量に発生する。「この変更はもう入っているはずなのに、なぜ衝突するのか」と首をかしげることになる。

第二に、コンフリクトにならない場合でも、既にマージ済みの変更が二重に適用されて、コードが壊れる。同じ行の追加が二回適用されれば、その行が重複する。

第三に、上記の問題を回避しようとして手動で変更を選別すると、本来マージすべき変更を見落とすリスクが生じる。

### CVSマニュアルが認めた「歯ぎしり」

この問題に対する公式の回避策は、マージのたびにタグを打つことだった。GNU CVSマニュアルは、マージ後に以下の操作を推奨している。

```bash
# 一度目のマージ後、ブランチにタグを打つ
cvs tag -r release-branch merged-to-trunk-20030701

# 二度目のマージでは、前回のマージポイントからの差分だけを適用
cvs update -j merged-to-trunk-20030701 -j release-branch
```

二つの `-j` オプションを使い、一つ目の `-j` で「前回マージした時点」を、二つ目の `-j` で「現在のブランチHEAD」を指定する。これにより、前回以降の変更だけがマージ対象になる。

だが、この運用には厳格な規律が必要だった。マージ後のタグ付けを忘れたら、次回のマージは破滅的な結果を招く。CVSマニュアル自身が、ブランチのマージ後にすぐタグを打つべきだと述べ、「さもなければ、歯ぎしりなしに再度マージすることは二度とできない」と警告していたほどだ。

チームの誰か一人がこの規律を守らなければ、チーム全体が影響を受ける。5人のチームで3か月間ブランチを運用すれば、誰かがマージ後のタグ付けを忘れる確率は決して低くない。そしてそれが起きたとき、マージの痛みは何倍にも膨れ上がる。

### トランクベース開発が「強制」された理由

CVS時代に「トランクベース開発」が事実上の標準だったことは、偶然ではない。

Paul Hammantは、トランクベース開発の歴史を論じる中で、「マージがバグだらけだった初期には、事実上トランクモデルを強いられた」と述べている。全員がトランクのHEADリビジョンに一日に何度も同期し、小さな変更をコミットすることで、コンフリクトの痛みを最小化する。これがCVS時代の生存戦略だった。

ブランチを切ることは「コスト」だった。ブランチの作成自体はコマンド一つだが、その後のマージ、stickyタグの管理、マージ追跡のための運用規律——これらのコストは、ブランチの寿命が長くなるほど指数関数的に増大した。

だから、CVS時代の開発者は合理的な判断としてブランチを避けた。リリースブランチのような「やむを得ない場合」にのみブランチを切り、可能な限り短命に保ち、マージの回数を最小化する。「ブランチを切るなら、できるだけ早くマージしろ」——これがCVS時代のブランチに関する鉄則だった。

このプラクティスは、ブランチが高コストであるという技術的制約から生まれた合理的な適応だった。だが、それが「文化」として固定化したとき、ある副作用をもたらした。「ブランチは危険なもの」「ブランチは最後の手段」という認識が、開発者の思考を制約したのだ。

あなたがgitで毎日何十本もブランチを切り、feature branchワークフローを当たり前のように使っているなら、それはCVS時代の開発者が「不可能」だと思っていたことを日常的にやっていることになる。その「当たり前」が実現されるまでに、ブランチモデルの根本的な再設計が必要だった。

---

## 4. ハンズオン：CVSのブランチとマージの痛みを体感する

ここからは、CVSのブランチとマージを実際に操作し、その痛みを手で確かめる。「ブランチが怖い」という感覚は、頭で理解するだけでは不十分だ。自分の端末で `C`（Conflict）の文字を見てほしい。

### 環境の準備

```bash
# Docker環境（推奨）
docker run -it --rm ubuntu:24.04 bash
apt update && apt install -y cvs

# 既に前回のハンズオン環境がある場合はそのまま利用可能
```

### 演習1：ブランチの作成と番号体系の確認

CVSのブランチが内部的にどう表現されているかを確認する。

```bash
WORKDIR="${HOME}/vcs-handson-06"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# リポジトリの初期化
export CVSROOT="${WORKDIR}/cvsrepo"
cvs init

# プロジェクトの作成
mkdir -p "${WORKDIR}/project-import/src"
cd "${WORKDIR}/project-import"

cat > src/main.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"

int main(void) {
    printf("App v%s\n", VERSION);
    return 0;
}
SRCEOF

cat > src/config.h << 'SRCEOF'
#ifndef CONFIG_H
#define CONFIG_H
#define VERSION "1.0"
#endif
SRCEOF

cat > src/utils.c << 'SRCEOF'
#include <string.h>

int string_length(const char *s) {
    return strlen(s);
}
SRCEOF

cvs import -m "Initial import" myproject vendor start
cd "${WORKDIR}"
rm -rf project-import
cvs checkout myproject
cd myproject

# 何回かコミットして履歴を積む
sed -i 's/1.0/1.1/' src/config.h
cvs commit -m "Bump to v1.1"

sed -i 's/1.1/1.2/' src/config.h
cvs commit -m "Bump to v1.2"

# ブランチを作成
cvs tag -b release-1
echo "--- ブランチ作成完了 ---"

# 各ファイルのブランチ番号を確認
echo ""
echo "=== ブランチの内部番号を確認 ==="
cvs status src/main.c 2>&1 | grep -E "(Repository|Sticky)"
cvs status src/config.h 2>&1 | grep -E "(Repository|Sticky)"
cvs status src/utils.c 2>&1 | grep -E "(Repository|Sticky)"
```

各ファイルのリビジョン番号が異なることに注目してほしい。`main.c` は `1.1.1.1` からのブランチ、`config.h` は `1.3` からのブランチになっているはずだ。同じブランチ名 `release-1` でも、ファイルごとに分岐点が異なる。

### 演習2：ブランチとトランクの並行開発

```bash
# ブランチに切り替え
cvs update -r release-1

# ブランチでバグ修正
cat > src/main.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"

int main(void) {
    printf("App v%s\n", VERSION);
    printf("(stable release)\n");
    return 0;
}
SRCEOF
cvs commit -m "[release-1] Add stable release indicator"

cat > src/utils.c << 'SRCEOF'
#include <string.h>

int string_length(const char *s) {
    if (s == NULL) return 0;  /* バグ修正: NULLチェック追加 */
    return strlen(s);
}
SRCEOF
cvs commit -m "[release-1] Fix NULL pointer bug in string_length"

# トランクに戻る
cvs update -A

# トランクで新機能開発
cat > src/main.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"
#include "utils.h"

int main(void) {
    printf("App v%s\n", VERSION);
    printf("String length: %d\n", string_length("hello"));
    return 0;
}
SRCEOF

cat > src/utils.h << 'SRCEOF'
#ifndef UTILS_H
#define UTILS_H
int string_length(const char *s);
#endif
SRCEOF
cvs add src/utils.h

sed -i 's/1.2/2.0/' src/config.h
cvs commit -m "Start v2.0 development"

echo ""
echo "=== トランクとブランチの並行開発が完了 ==="
echo "トランク: v2.0開発中（main.cに新機能追加）"
echo "ブランチ: v1.2のバグ修正（NULLチェック等）"
```

### 演習3：最初のマージ——コンフリクトとの遭遇

```bash
echo ""
echo "=== 演習3: ブランチからトランクへのマージ ==="

# トランクにいることを確認
cvs update -A

# ブランチの変更をマージ
echo "--- マージ実行 ---"
cvs update -j release-1 2>&1

echo ""
echo "--- マージ結果の確認 ---"
# コンフリクトが発生したファイルを確認
grep -rl "<<<<<<" src/ 2>/dev/null && echo "コンフリクトが発生しました" || echo "コンフリクトなし"

# main.c のコンフリクトを確認
echo ""
echo "--- main.c の内容 ---"
cat src/main.c
```

`main.c` でコンフリクトが発生しているはずだ。トランクとブランチの両方で `main.c` を変更したからだ。コンフリクトマーカーを確認してほしい。

```bash
# コンフリクトを手動で解消
cat > src/main.c << 'SRCEOF'
#include <stdio.h>
#include "config.h"
#include "utils.h"

int main(void) {
    printf("App v%s\n", VERSION);
    printf("(stable release)\n");
    printf("String length: %d\n", string_length("hello"));
    return 0;
}
SRCEOF

cvs commit -m "Merge release-1 to trunk (first merge)"
echo "--- 最初のマージ完了 ---"
```

### 演習4：二度目のマージ——マージ追跡の不在を体感する

ここからが本題だ。最初のマージ後にブランチでさらに修正を加え、二度目のマージを行う。

```bash
echo ""
echo "=== 演習4: 二度目のマージ——マージ追跡不在の恐怖 ==="

# ブランチに切り替えて追加修正
cvs update -r release-1

cat > src/utils.c << 'SRCEOF'
#include <string.h>

int string_length(const char *s) {
    if (s == NULL) return 0;
    return (int)strlen(s);  /* 型キャストを追加 */
}
SRCEOF
cvs commit -m "[release-1] Add explicit cast in string_length"

# トランクに戻る
cvs update -A

# 二度目のマージを試みる（タグなし——これが地獄の入り口）
echo "--- 二度目のマージを実行（タグなし） ---"
cvs update -j release-1 2>&1

echo ""
echo "--- マージ結果の確認 ---"
grep -rl "<<<<<<" src/ 2>/dev/null && echo "コンフリクトが発生しました！" || echo "コンフリクトなし"
echo ""
echo "--- utils.c の内容を確認 ---"
cat src/utils.c
echo ""
echo "--- main.c の内容を確認 ---"
cat src/main.c
```

注目してほしいのは、最初のマージで既に取り込んだ変更（NULLチェックの追加）が、再度マージ対象になっていることだ。CVSはブランチの分岐点からすべての変更を再適用しようとする。最初のマージの記録がどこにも存在しないからだ。

```bash
echo ""
echo "=== 正しい方法: マージ後にタグを打つ ==="

# まずコンフリクトを解消してコミット（もしコンフリクトがあれば）
# 一旦作業をリセット
cvs update -A -C

# 一度目のマージの「模擬」として、マージポイントのタグを打つ
# 本来は一度目のマージ直後に行うべき操作
cvs tag -r release-1 merged-release1-round1

# ブランチで追加修正（上で既に行った修正が存在する状態）

# 正しい二度目のマージ: 前回のマージポイントから現在までの差分だけ
echo "--- 正しい二度目のマージ（タグ使用） ---"
cvs update -j merged-release1-round1 -j release-1 2>&1

echo ""
echo "--- 正しいマージの結果 ---"
cat src/utils.c
```

二つの `-j` を使うことで、前回のマージポイント以降の変更だけが適用される。だが、このタグを打つ運用規律を、チームの全員が、毎回のマージで、一度も忘れずに守り続ける必要がある。

### 演習5：stickyタグの混乱を体験する

```bash
echo ""
echo "=== 演習5: stickyタグの混乱 ==="

# リリースタグを打つ（ブランチではなく固定タグ）
cvs update -A
cvs tag release-1.2.1

# そのタグにupdateする
cvs update -r release-1.2.1

# ファイルを変更してコミットを試みる
echo "// test change" >> src/utils.c
echo "--- stickyタグ上でコミットを試みる ---"
cvs commit -m "Test commit on sticky tag" 2>&1 || true

echo ""
echo "--- stickyタグの状態を確認 ---"
cvs status src/utils.c 2>&1 | grep -E "(Status|Sticky)"

echo ""
echo "--- stickyタグを解除してトランクに戻る ---"
cvs update -A
cvs status src/utils.c 2>&1 | grep -E "(Status|Sticky)"
```

非ブランチタグにstickyが設定されると、コミットが拒否される。`sticky tag 'release-1.2.1' is not a branch` というエラーに遭遇したはずだ。

### 演習で見えたこと

五つの演習を通じて、CVSのブランチとマージの構造的問題を体感した。

ブランチの番号体系はファイル単位であり、プロジェクト全体の状態をスナップショットとして捉える概念がない。マージ追跡の不在は、二度目以降のマージを手動のタグ管理に依存させ、ヒューマンエラーの温床となった。stickyタグは、ブランチの切り替えに暗黙の状態を持ち込み、意図しない操作のリスクを高めた。

これらの問題は、CVSの内部構造——RCSのファイル単位リビジョン管理をラップした設計——から必然的に生じたものだ。ブランチの「コスト」は、コマンドの実行時間だけではない。マージの困難さ、運用規律の負荷、ヒューマンエラーのリスク——これらすべてを含めたコストが、CVS時代のブランチを「怖い」ものにしていた。

---

## 5. まとめと次回予告

### この回の要点

第一に、CVSのブランチはRCSのリビジョン番号体系に基づいており、ブランチ番号はファイルごとに独立して管理される。「ブランチ」は共通のタグ名で束ねられたファイル単位のリビジョン分岐の集合体であり、リポジトリ全体のスナップショットとしての一貫性を持たなかった。これに対し、Gitのブランチは41バイトのポインタファイルに過ぎず、作成コストはファイル数に依存しない。

第二に、CVSにはマージ追跡機能がなかった。一度マージした変更を記録する仕組みがないため、二度目のマージでは同じ変更を再適用してしまう問題があった。開発者はマージのたびにタグを打つ運用規律でこの問題を回避するしかなかったが、この規律の維持はチーム規模が大きくなるほど困難だった。

第三に、マージの困難さが「トランクベース開発」を事実上の標準にした。ブランチを切ることのコスト（マージ、stickyタグ管理、運用規律の負荷）が高すぎたため、全員がトランクに頻繁にコミットする開発スタイルが合理的だった。これは技術的制約から生まれた適応だが、「ブランチは危険なもの」という文化的認識としても固定化した。

第四に、stickyタグの仕組みが、ブランチの切り替えに暗黙の状態を持ち込み、意図しないブランチへのコミットや、非ブランチタグ上での作業停止といった問題を引き起こした。

### 冒頭の問いへの暫定回答

なぜ「ブランチが怖い」という文化が生まれたのか。

その答えは明確だ。CVSの設計が、ブランチの作成は許しても、ブランチの統合を追跡・管理する仕組みを持っていなかったからだ。ブランチは「切る」ことより「戻す」ことのほうが圧倒的に難しかった。マージ追跡の不在、ファイル単位のリビジョン管理、stickyタグの暗黙的状態——これらの技術的制約が、「ブランチを切ったら地獄が待っている」という経験則を生み、やがてそれが「ブランチは怖い」という文化になった。

だが、ここで一歩引いて考えてほしい。CVS時代のトランクベース開発は、「悪い」プラクティスだったのだろうか。全員がトランクに頻繁にコミットし、小さな変更を積み重ねる。コンフリクトは早期に発見され、統合の遅延は最小化される。これは、2010年代以降に「継続的インテグレーション」の名の下に再評価された開発プラクティスと、驚くほど似ている。

CVS時代の開発者は、技術的制約に強いられてトランクベース開発を「やるしかなかった」。git時代の開発者は、ブランチが安くなったことでfeature branchワークフローを採用し——そして、Martin Fowlerが2009年に指摘したように、ブランチの長寿命化と統合遅延という新たな問題に直面した。Vincent Driessenが2010年に公開したgit-flowモデルが広く普及した後、Driessen自身が2020年に「Webアプリの継続的デリバリー環境ではgit-flowが最適でない場合がある」と追記したのは示唆的だ。

技術の「進歩」は、常に新しい問題を生む。ブランチが安くなったことは間違いなく進歩だが、安くなったブランチをどう使うかという問いは、いまだに答えが定まっていない。

### 次回予告

次回は、CVSの話をさらに一歩引いて、「集中型VCSの設計哲学」そのものを再考する。

集中型VCSは、分散型に「劣っている」のか。それとも「違う問題を解いている」のか。CVS時代の開発者が中央サーバに依存していたのは、技術的無知からではない。全員が同じオフィスにいて、同じネットワークに接続していた時代には、中央サーバは合理的な設計選択だった。

**第7回「集中型VCSの設計哲学——それは本当に『悪』だったのか？」**

あなたは「集中型は古い、分散型が正しい」と即答するだろうか。その判断の根拠を、歴史に照らして検証してみよう。

---

_佐藤裕介——Engineers Hub株式会社 CEO / Technical Lead。1990年代後半からLinux/UNIXの世界に身を置き、24年以上の開発経験を持つ。「Enable——自走できる状態を作ること」を哲学に、技術と人の関係を問い続けている。_

---

### 参考文献

- GNU CVS Manual, Version 1.11.23, "Branching and merging." <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Branching-and-merging.html>
- GNU CVS Manual, Version 1.11.23, "Branches and revisions." <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Branches-and-revisions.html>
- GNU CVS Manual, Version 1.11.23, "Merging a branch." <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Merging-a-branch.html>
- GNU CVS Manual, Version 1.11.23, "Sticky tags." <https://www.gnu.org/software/trans-coord/manual/cvs/html_node/Sticky-tags.html>
- Fogel, K., "Open Source Development with CVS," Coriolis Group, 1999. <https://durak.org/sean/pubs/software/cvsbook/>
- Hammant, P., "The origins of Trunk-Based Development," 2015. <https://paulhammant.com/2015/04/23/the-origins-of-trunk-based-development/>
- trunkbaseddevelopment.com, "Game Changers." <https://trunkbaseddevelopment.com/game-changers/>
- Driessen, V., "A successful Git branching model," nvie.com, January 5, 2010. <https://nvie.com/posts/a-successful-git-branching-model/>
- Fowler, M., "Feature Branch," martinfowler.com, September 3, 2009. <https://martinfowler.com/bliki/FeatureBranch.html>
- Pro Git, "Git Branching - Branches in a Nutshell." <https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell>
- Avery Pennarun, "A tale of five merges: cvs, svn, git, darcs, etc." <https://apenwarr.ca/log/20080319>
