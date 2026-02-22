# 第15回：GPLv3とbashデフォルト時代の終焉――AppleがmacOSのデフォルトをzshに変えた日

**シリーズ**: bash ありきの世界を疑え――シェルの根源から対話と自動化の未来を考える

**著者**: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）

---

**この回で学べること**:

- GPLv2からGPLv3への改訂（2007年6月29日）で何が変わったのか――Anti-Tivoization条項、特許保護、DRM対策の三本柱
- bash 3.2（2006年10月）がGPLv2最終版であり、bash 4.0（2009年2月）でGPLv3に移行した事実
- AppleがGPLv3ソフトウェアを体系的に排除した歴史――Samba、GCC、GNU coreutilsからbashまで
- macOSのデフォルトシェルがtcsh→bash（2003年）→zsh（2019年）と変遷した16年間の物語
- bash 3.2.57がmacOSに凍結され続けている現状と、その実害――13年分の新機能が使えない世界
- GPLv2とGPLv3の技術的差異が企業のソフトウェア選定をどう支配するか
- ソフトウェアライセンスが技術の進化を阻害することも、促進することもあるという両義性

---

## 1. 導入――"The default interactive shell is now zsh."

2019年秋、macOS Catalinaにアップデートした日のことを覚えている。

ターミナルを開いた瞬間、見慣れないメッセージが表示された。

```
The default interactive shell is now zsh.
To update your account to use zsh, please run `chsh -s /bin/zsh`.
For more information, please visit https://support.apple.com/kb/HT208050.
```

私はこのメッセージの意味を即座に理解した。Appleがbashを捨てた――正確に言えば、bashのライセンスを受け入れることを拒んだのだ。だが、多くの開発者にとってこのメッセージは唐突だっただろう。「なぜ突然zshなのか」「bashの何が問題だったのか」。そもそも、シェルのデフォルトが変わることが何を意味するのかすら、考えたことがない人もいたはずだ。

私自身は、この変更を予見していた。macOSの`/bin/bash`がバージョン3.2.57のまま凍結されていることは、何年も前から気づいていた。連想配列が使えない。globstarが使えない。`mapfile`が使えない。2006年にリリースされたbash 3.2の上で、13年分の新機能が存在しない世界。Homebrewで最新のbashをインストールし、`/usr/local/bin/bash`をログインシェルに設定する。そういう「回避策」を当たり前のように行っていた。

だが、回避策を知っていることと、なぜ回避策が必要になったかを理解していることは別だ。macOSのbashが凍結された理由は、技術的な怠慢ではない。ライセンスの問題だ。より正確に言えば、2007年にFree Software Foundationが公表したGPLv3という「新しい契約書」が、Appleの事業モデルと根本的に衝突した。その衝突の結果、bashはmacOSのデフォルトの座を失った。

この話は、技術者が思っている以上に重要だ。ソフトウェアライセンスは、コードの品質とは無関係に、技術の採用と廃棄を決定する力を持つ。bashの覇権が揺らいだのは、bashが劣っていたからではない。bashの「契約書」が変わったからだ。

あなたが日常的に使っているツールのライセンスを、最後に確認したのはいつだろうか。そのライセンスが変更されたとき、何が起こるかを想像したことはあるだろうか。

---

## 2. 歴史的背景――GPLv3がもたらした断層線

### GPLv2からGPLv3へ――16年ぶりの契約改訂

GPLv2（GNU General Public License version 2）は1991年に公表された。フリーソフトウェア運動の法的基盤として、15年以上にわたりオープンソースの世界を支えてきた。Linuxカーネル、GCC、bash、Samba――数え切れないソフトウェアがGPLv2の下でリリースされた。

2007年6月29日、Free Software Foundation（FSF）はGPLv3を公表した。1年半の公開協議、数千のコメント、4つのドラフトを経ての公表だった。GPLv2からの改訂は、三つの柱で構成されていた。

**第一の柱：Anti-Tivoization条項**。これがGPLv3の最も論争的な変更点だった。「Tivoization」とは、Richard StallmanがTiVo社のデジタルビデオレコーダーを指して名づけた造語だ。TiVoはGPLv2のLinuxカーネルを使用していたが、ハードウェアの署名検証機能により、ユーザーが改変したカーネルを実行できないようにしていた。GPLv2の「ソースコードを公開する」義務は果たしていた。だが、実質的にユーザーはソフトウェアを改変する自由を行使できなかった。

GPLv3のAnti-Tivoization条項は、消費者向け製品にGPLv3ソフトウェアを配布する場合、ユーザーが改変版を実行するために必要な情報――暗号鍵、インストール手順、署名検証の回避方法――の提供を義務づけた。

**第二の柱：明示的な特許保護**。GPLv2には暗黙の特許ライセンスしかなかった。GPLv3では、ソフトウェアの貢献者と配布者が、受領者に対して特許権を行使しないことを明示的に約束する条項が追加された。さらに、GPLv3ソフトウェアのユーザーに対して特許訴訟を起こした場合、そのソフトウェアを使用する権利が自動的に失効する仕組みが組み込まれた。

**第三の柱：DRM/技術的保護手段への対策**。GPLv3は、GPLv3ソフトウェアを含む製品に対してDRM回避禁止法（米国のDMCA、EUの著作権指令等）を適用することを実質的に不可能にする条項を含んでいた。

この三つの柱は、FSFの観点からは「ソフトウェアの自由を守るための当然の進化」だった。だが、ハードウェアとソフトウェアを統合して製品を作る企業――とりわけAppleにとっては、事業モデルの根幹に関わる制約だった。

### Appleにとっての「不都合な真実」

Appleのビジネスモデルを考えてみよう。Appleはハードウェアとソフトウェアを密に統合し、閉じたエコシステムの中でユーザー体験を管理する。iPhoneのiOS、MacのmacOS、それぞれのApp Store。ハードウェア上でどのソフトウェアが動作するかを、Appleがコントロールする。このコントロールこそが、Appleの製品品質と収益の源泉だ。

GPLv3のAnti-Tivoization条項は、まさにこのコントロールを脅かすものだった。もしmacOSにGPLv3のソフトウェアを同梱すれば、Appleはユーザーがそのソフトウェアを改変してインストールするために必要な情報を提供しなければならない。これは、Appleのセキュリティモデルやソフトウェア署名の仕組みと衝突する可能性がある。

特許条項も無視できない。Appleは膨大な特許ポートフォリオを持つ。GPLv3ソフトウェアを配布することで、それらの特許に関する暗黙のライセンスが発生するリスクを、Appleの法務部門は受け入れがたいと判断したのだろう。

Apple自身は、GPLv3排除の方針を公式に表明したことはない。だが、行動は雄弁だった。

### 「Great GPL Purge」――AppleのGPLv3排除の軌跡

2012年の分析によれば、macOSに同梱されるGPLライセンスのパッケージ数は、OS X 10.5 Leopard（2007年）の47から、10.6 Snow Leopard（2009年）の44、10.7 Lion（2011年）の29へと着実に減少していた。

最も象徴的な排除は、Sambaだ。Sambaはオープンソースのファイル共有ソフトウェアで、WindowsのSMBプロトコルを実装している。macOSのファイル共有機能の中核を担っていた。だが、Samba 3.2（2008年）でGPLv3に移行した。

2011年、OS X 10.7 LionでAppleはSambaを排除し、自社製の「SMBX」で置き換えた。SMBXはMicrosoftの新しいSMB2プロトコルをサポートしていたから、技術的な改善と言えなくもない。だが、排除の動機がGPLv3であったことは、タイミングからして明白だった。

GCCの排除はさらに大がかりだった。GCCはGNU Compiler Collection――C、C++、Objective-Cなどのコンパイラスイートだ。macOSの開発ツールチェーンの中核だった。GCCがGPLv3に移行すると、AppleはClang/LLVMの開発に本格的に投資した。Clangは2007年7月にオープンソース化が承認され、Apache 2.0ライセンスで公開された。Xcode 4.x（2013年頃まで）ではLLVM-GCCが暫定的に使用されたが、その後完全にClangに置き換えられた。AppleがmacOSに同梱した最後のGCCはバージョン4.2だった。

GNU coreutilsも同様の運命を辿った。macOSの`ls`、`cp`、`cat`といった基本コマンドは、GNU版からBSD版に置き換えられていった。BSD版はBSDライセンス――GPLよりもはるかに制約の少ないライセンス――で公開されている。

そしてbash。bash 3.2（2006年10月）はGPLv2でリリースされた最後のメジャーバージョンだった。bash 4.0（2009年2月20日）がGPLv3でリリースされると、Appleはbashの更新を凍結した。macOSの`/bin/bash`は3.2.57のまま、以後二度と更新されなかった。

### 2003年から2019年――bashのmacOS16年史

macOSにおけるbashの歴史を振り返ると、一つのアイロニーが浮かび上がる。

2003年、Mac OS X 10.3 Panther。Appleはデフォルトシェルをtcshからbashに変更した。この時点でbashはGPLv2だった。AppleにとってGPLv2は許容範囲内であり、bashの選択は合理的だった。LinuxでデファクトスタンダードのシェルをmacOSにも導入する。開発者にとって魅力的な選択だった。

16年間、bashはmacOSのデフォルトシェルとして君臨した。開発者はmacOSのターミナルを開けばbashが立ち上がることを前提にスクリプトを書き、チュートリアルを書き、ワークフローを構築した。

だがその16年の途中、2007年にGPLv3が公表され、2009年にbash 4.0がGPLv3でリリースされた。この時点で、macOSのbashは未来を失った。更新されることのないソフトウェア。それが、世界で最も普及したデスクトップOSの一つに同梱されるデフォルトシェルの正体だった。

2019年6月3日、WWDC 2019でAppleはmacOS Catalinaを発表した。その変更点の一つが「デフォルトシェルのzshへの変更」だった。2019年10月7日にCatalinaがリリースされると、新規ユーザーアカウントにはzshがデフォルトシェルとして設定された。既存ユーザーのシェルは変更されなかったが、ターミナルを開くたびにzshへの移行を促すメッセージが表示された。

zshが選ばれた理由は明快だ。zshはMITライセンスで公開されている。GPLv3の制約がない。Bourne shell互換でありbashとの互換性も高い。Paul Falstadが1990年にPrinceton大学で作成して以来、長年にわたりコミュニティに支えられてきた成熟したシェルだ。

Appleは公式には「zshはBourne shellと高い互換性があり、bashともほぼ互換」と説明した。技術的な互換性を理由に挙げたのだ。ライセンスには一言も触れなかった。だが、経緯を知る者にとって、その沈黙こそが雄弁だった。

---

## 3. 技術論――GPLv2 vs GPLv3の断層と凍結されたbash

### GPLv2とGPLv3の技術的差異

ライセンスの差異は法律文書の問題であり、エンジニアの多くは「自分には関係ない」と考えがちだ。だが、GPLv2とGPLv3の差異は、ソフトウェアの配布・利用に直接影響する技術的な含意を持つ。

```
GPLv2（1991年）とGPLv3（2007年）の主要な差異:

                        GPLv2           GPLv3
------------------------------------------------------
ソースコード公開        義務            義務
Tivoization            許容            禁止（消費者向け製品）
特許ライセンス          暗黙            明示的
DRM回避禁止法の適用     制限なし        実質的に制限
ライセンスの互換性      限定的          改善（Apache 2.0と互換）
ハードウェア制限        言及なし        インストール情報の提供義務
```

技術者にとって最も直接的な影響は、Anti-Tivoization条項だ。GPLv3ソフトウェアを組み込んだ消費者向け製品を販売する場合、ユーザーが改変版をインストールするために必要な「インストール情報」を提供しなければならない。この「インストール情報」には、暗号鍵、署名証明書、ブートローダーの設定情報などが含まれ得る。

Appleの製品――iPhone、Mac、Apple TV――はいずれもソフトウェア署名によるセキュリティモデルを採用している。GPLv3ソフトウェアを同梱すれば、この署名モデルに穴を開ける情報を提供する義務が生じる可能性がある。Apple法務部門がこのリスクを忌避したのは、事業上合理的な判断だった。

### 凍結されたbash 3.2の実害

macOSの`/bin/bash`が3.2.57で凍結されたことは、macOS上で開発を行うエンジニアに具体的な実害をもたらしている。

bash 4.0（2009年）で追加された主要機能が使えない。

```bash
# 連想配列（bash 4.0）-- macOSの/bin/bashでは使えない
declare -A colors
colors[red]="#ff0000"
colors[blue]="#0000ff"
echo "${colors[red]}"  # エラー

# globstar（bash 4.0）-- **による再帰的グロブ
shopt -s globstar
echo **/*.txt  # bash 3.2ではglobstarが存在しない

# coproc（bash 4.0）-- コプロセス
coproc myproc { cat; }  # bash 3.2ではcoprocessが存在しない

# case文の ;;& と ;& ターミネータ（bash 4.0）
case "$val" in
    a*) echo "starts with a" ;;&  # fall-through -- bash 3.2ではエラー
    ab*) echo "starts with ab" ;;
esac
```

bash 4.3（2014年）で追加されたnameref変数も使えない。

```bash
# nameref変数（bash 4.3）-- 変数への参照
declare -n ref=myvar
myvar="hello"
echo "$ref"  # "hello" -- bash 3.2では使えない
```

bash 4.4（2016年）の`${parameter@operator}`変換も使えない。

```bash
# パラメータ変換（bash 4.4）
name="hello world"
echo "${name@U}"  # "HELLO WORLD" -- bash 3.2では使えない
echo "${name@Q}"  # "'hello world'" -- クォートされた形式
```

bash 5.0（2019年）の`$EPOCHSECONDS`や`$EPOCHREALTIME`も使えない。

```bash
# エポック秒（bash 5.0）
echo "$EPOCHSECONDS"   # 1708000000 -- bash 3.2では未定義
echo "$EPOCHREALTIME"  # 1708000000.123456
```

これらの機能が使えないことで、macOS開発者は二つの選択肢を迫られる。

**選択肢1：bash 3.2の機能範囲内でスクリプトを書く**。これは事実上、2006年のbashの機能セットに自分を制限することを意味する。連想配列の代わりに名前にプレフィックスを付けた個別変数を使う、globstarの代わりに`find`コマンドを使う、といった「回避策」が必要になる。

**選択肢2：Homebrewでbash 5.xをインストールする**。`brew install bash`で最新のbashが手に入る。だが、`/bin/bash`は3.2.57のままだ。スクリプトの先頭に`#!/bin/bash`と書けば、macOSの古いbashが使われる。`#!/usr/local/bin/bash`（Intel Mac）か`#!/opt/homebrew/bin/bash`（Apple Silicon Mac）と書く必要がある。あるいは`#!/usr/bin/env bash`と書いてPATHに依存する方法もあるが、PATHの設定を前提にするスクリプトのポータビリティには疑問が残る。

いずれの選択肢も、「bashがデフォルトで最新である」ことを前提にした世界からの逸脱だ。Linuxであれば、ディストリビューションのパッケージマネージャが最新のbashを提供してくれる。macOSでは、そうはいかない。

### ライセンスが生んだ技術革新――Clang/LLVMの事例

GPLv3がもたらしたのは、制約だけではない。一つの技術革新を生んだ事例がある。Clang/LLVMだ。

GCCがGPLv3に移行したことを受け、AppleはClang/LLVMの開発に本格的に投資した。結果として、Clangは多くの面でGCCを超えるコンパイラになった。エラーメッセージの質、コンパイル速度、モジュラーアーキテクチャ、IDEとの統合性――いずれもGCCに対する明確な改善だった。

Clangの成功は、ライセンスの制約が技術革新を促進することもあるという逆説を示している。AppleがGCCを使い続けることができたなら、Clangは生まれなかったかもしれない。あるいは、はるかに遅いペースで開発されていたかもしれない。

だが、bashの場合は事情が異なる。AppleはClangのように「新しいシェル」を自社開発するのではなく、既存の代替品――zshを選んだ。シェルは、コンパイラほどAppleの事業に直結していなかった。投資の優先度が違ったのだ。

### ライセンスが技術選定を支配する構造

この一連の出来事から、ソフトウェアライセンスが技術選定を支配する構造が見えてくる。

```
ライセンスが技術選定を支配するメカニズム:

  1. ソフトウェアのライセンスが変更される
          |
  2. 企業の法務部門がリスクを評価する
          |
  3. リスクが許容範囲を超える場合:
     |                              |
  3a. 代替品が存在する            3b. 代替品が存在しない
     → 代替品に移行                 → 自社開発、または凍結
     (bash→zsh, Samba→SMBX)        (GCC→Clang/LLVM)
          |
  4. エンジニアは結果に従う
```

この構造の中で、エンジニアの技術的判断は最下流に位置する。ライセンスの変更は上流で起き、法務の判断は中流で行われ、エンジニアは下流で「bashが3.2.57のまま動かない」という現実に対処する。

これはbashに限った話ではない。あなたが今使っているツール、ライブラリ、フレームワークのライセンスが明日変わったとき、同じ構造が作動する。2024年のHashiCorpのTerraformライセンス変更（MPL 2.0からBSL 1.1へ）とOpenTofuのフォーク誕生は、まさにこの構造の最新の事例だ。

---

## 4. ハンズオン――bash 3.2の制約を体感し、POSIX準拠に書き換える

ここまでの議論を、手を動かして確認する。bash 3.2の制約を実際に体感し、POSIX準拠のコードへ書き換える演習を行う。

### 環境構築

Docker環境を前提とする。bash 3.2とbash 5.2の両方を同一環境に用意する。

```bash
# Ubuntu環境でbash 5.2（デフォルト）と bash 3.2をビルドして比較する
docker run -it ubuntu:24.04 /bin/bash
```

あるいは、本記事に付属する`setup.sh`スクリプトで一括構築できる。

```bash
bash setup.sh
```

### 演習1: bash 3.2 vs bash 5.x――機能差異の体感

macOS環境を模擬し、bash 3.2で使えない機能を確認する。bash 3.2のソースからのビルドが必要なため、ここではbash 5.2の`--posix`モードとの比較、および機能の有無を直接確認する方法を取る。

```bash
echo "=== 演習1: bash バージョン間の機能差異 ==="

echo ""
echo "--- 現在のbashバージョン ---"
echo "bash: ${BASH_VERSION}"

# --- 連想配列（bash 4.0+）---
echo ""
echo "--- 連想配列（bash 4.0で追加）---"

if (( BASH_VERSINFO[0] >= 4 )); then
    declare -A fruits
    fruits[apple]="red"
    fruits[banana]="yellow"
    fruits[grape]="purple"
    echo "連想配列が使用可能:"
    for key in "${!fruits[@]}"; do
        echo "  ${key} -> ${fruits[$key]}"
    done
else
    echo "bash ${BASH_VERSION}: 連想配列は使用不可（bash 4.0以降が必要）"
fi

# --- globstar（bash 4.0+）---
echo ""
echo "--- globstar（bash 4.0で追加）---"

mkdir -p /tmp/globtest/sub1/sub2
touch /tmp/globtest/a.txt /tmp/globtest/sub1/b.txt /tmp/globtest/sub1/sub2/c.txt

if (( BASH_VERSINFO[0] >= 4 )); then
    shopt -s globstar
    echo "globstar有効: 再帰的にファイルを検索"
    for f in /tmp/globtest/**/*.txt; do
        echo "  ${f}"
    done
    shopt -u globstar
else
    echo "bash ${BASH_VERSION}: globstarは使用不可"
    echo "代替: find コマンドを使用"
fi

echo "findによる代替（どのバージョンでも動作）:"
find /tmp/globtest -name "*.txt" | while read -r f; do
    echo "  ${f}"
done

rm -rf /tmp/globtest

# --- nameref変数（bash 4.3+）---
echo ""
echo "--- nameref変数（bash 4.3で追加）---"

if (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 3) )); then
    target="world"
    declare -n ref=target
    echo "nameref: ref -> target = ${ref}"
    ref="hello"
    echo "refを変更 -> target = ${target}"
    unset -n ref
else
    echo "bash ${BASH_VERSION}: namerefは使用不可（bash 4.3以降が必要）"
fi

# --- ${parameter@operator}（bash 4.4+）---
echo ""
echo "--- パラメータ変換（bash 4.4で追加）---"

if (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4) )); then
    sample="hello world"
    echo "元の値: ${sample}"
    echo "大文字変換 @U: ${sample@U}"
    echo "クォート @Q: ${sample@Q}"
else
    echo "bash ${BASH_VERSION}: パラメータ変換は使用不可（bash 4.4以降が必要）"
fi

# --- $EPOCHSECONDS（bash 5.0+）---
echo ""
echo "--- エポック秒変数（bash 5.0で追加）---"

if (( BASH_VERSINFO[0] >= 5 )); then
    echo "EPOCHSECONDS: ${EPOCHSECONDS}"
    echo "EPOCHREALTIME: ${EPOCHREALTIME}"
else
    echo "bash ${BASH_VERSION}: EPOCHSECONDS/EPOCHREALTIMEは使用不可（bash 5.0以降が必要）"
    echo "代替: \$(date +%s)"
    echo "date +%s: $(date +%s)"
fi
```

### 演習2: bash依存コードをPOSIX準拠に書き換える

bash 3.2でも使えない機能に依存したスクリプトを、POSIX準拠（dashでも動作する）コードに書き換える。

```bash
echo "=== 演習2: bash依存コードのPOSIX準拠への書き換え ==="

# --- checkbashismsのインストール ---
apt-get update -qq && apt-get install -y -qq devscripts >/dev/null 2>&1

# --- bash依存スクリプト ---
cat << 'BASH_SCRIPT' > /tmp/bash_dependent.sh
#!/bin/bash
# bash依存の機能を使ったスクリプト

# bash拡張: [[ ]] による条件評価
filename="test file.txt"
if [[ -n "$filename" && "$filename" == *.txt ]]; then
    echo "テキストファイル: $filename"
fi

# bash拡張: 配列
files=(one.txt two.txt three.txt)
echo "ファイル数: ${#files[@]}"
for f in "${files[@]}"; do
    echo "  $f"
done

# bash拡張: $() 内のプロセス置換
echo "現在時刻: $(date +%H:%M:%S)"

# bash拡張: here string <<<
read -r first_word <<< "hello world"
echo "最初の単語: $first_word"

# bash拡張: {1..5} ブレース展開
for i in {1..5}; do
    echo "  カウント: $i"
done
BASH_SCRIPT

echo "--- bash依存スクリプトのcheckbashisms結果 ---"
checkbashisms /tmp/bash_dependent.sh 2>&1 || true

echo ""
echo "--- POSIX準拠に書き換えたスクリプト ---"

cat << 'POSIX_SCRIPT' > /tmp/posix_compliant.sh
#!/bin/sh
# POSIX準拠: dashやashでも動作する

# POSIX: [ ] による条件評価（testコマンド）
filename="test file.txt"
if [ -n "$filename" ]; then
    case "$filename" in
        *.txt) echo "テキストファイル: $filename" ;;
    esac
fi

# POSIX: 配列の代替（位置パラメータ or 個別変数）
set -- one.txt two.txt three.txt
echo "ファイル数: $#"
for f in "$@"; do
    echo "  $f"
done

# POSIX: $() によるコマンド置換（これはPOSIX準拠）
echo "現在時刻: $(date +%H:%M:%S)"

# POSIX: here stringの代替（here documentまたはパイプ）
first_word=$(echo "hello world" | cut -d' ' -f1)
echo "最初の単語: $first_word"

# POSIX: ブレース展開の代替（seqコマンド or whileループ）
i=1
while [ "$i" -le 5 ]; do
    echo "  カウント: $i"
    i=$((i + 1))
done
POSIX_SCRIPT

echo ""
echo "--- POSIX準拠スクリプトのcheckbashisms結果 ---"
checkbashisms /tmp/posix_compliant.sh 2>&1 && echo "checkbashisms: 問題なし"

echo ""
echo "--- POSIX準拠スクリプトをdashで実行 ---"
dash /tmp/posix_compliant.sh

rm -f /tmp/bash_dependent.sh /tmp/posix_compliant.sh
```

### 演習3: macOS環境を模擬した/bin/sh問題の再現

macOSとLinuxで`/bin/sh`の実体が異なることを確認する。

```bash
echo "=== 演習3: /bin/shの実体と挙動差異 ==="

# 現在の環境の /bin/sh を確認
echo "--- /bin/sh の実体 ---"
ls -la /bin/sh
readlink -f /bin/sh 2>/dev/null || echo "(readlinkが使えない環境)"

# /bin/sh としての実行とbashとしての実行の差異
echo ""
echo "--- /bin/sh vs /bin/bash の挙動差異 ---"

# bash拡張が /bin/sh で動くか確認
cat << 'TEST_SCRIPT' > /tmp/sh_test.sh
#!/bin/sh

# テスト1: [[ ]] （bash拡張）
echo "テスト1: [[ ]] 条件式"
if [[ "hello" == h* ]] 2>/dev/null; then
    echo "  [[ ]] は使用可能（bashまたは互換シェル）"
else
    echo "  [[ ]] は使用不可（純粋なPOSIXシェル）"
fi

# テスト2: 配列（bash拡張）
echo "テスト2: 配列"
arr=(a b c) 2>/dev/null
if [ "${#arr[@]}" = "3" ] 2>/dev/null; then
    echo "  配列は使用可能"
else
    echo "  配列は使用不可"
fi

# テスト3: $RANDOM（POSIX未規定だがbash/ksh/zshで使用可能）
echo "テスト3: \$RANDOM"
if [ -n "$RANDOM" ]; then
    echo "  RANDOM=${RANDOM}（使用可能）"
else
    echo "  RANDOMは未定義（純粋なPOSIXシェル）"
fi

# テスト4: local変数（POSIXでは未規定だが広く実装）
echo "テスト4: local変数"
test_local() {
    local var="local_value" 2>/dev/null
    if [ "$var" = "local_value" ]; then
        echo "  localは使用可能"
    else
        echo "  localは使用不可"
    fi
}
test_local
TEST_SCRIPT

echo ""
echo "--- /bin/bash で実行 ---"
/bin/bash /tmp/sh_test.sh

echo ""
echo "--- /bin/sh で実行 ---"
/bin/sh /tmp/sh_test.sh

echo ""
echo "--- dash で実行（POSIX準拠シェル）---"
if command -v dash >/dev/null 2>&1; then
    dash /tmp/sh_test.sh
else
    apt-get install -y -qq dash >/dev/null 2>&1
    dash /tmp/sh_test.sh
fi

rm -f /tmp/sh_test.sh
```

### 演習4: ライセンスの確認方法

普段使っているツールのライセンスを確認する方法を学ぶ。

```bash
echo "=== 演習4: ソフトウェアライセンスの確認 ==="

# bash のライセンス確認
echo "--- bash のライセンス ---"
bash --version | head -4
echo ""
echo "bashのライセンス情報:"
if [ -f /usr/share/doc/bash/copyright ]; then
    head -20 /usr/share/doc/bash/copyright
elif [ -f /usr/share/licenses/bash/COPYING ]; then
    head -5 /usr/share/licenses/bash/COPYING
else
    echo "  bash は GPLv3+ でライセンスされている"
    echo "  確認: bash -c 'echo \$BASH_VERSION' → $(bash -c 'echo $BASH_VERSION')"
    echo "  bash 4.0以降 = GPLv3"
fi

echo ""

# dash のライセンス確認
echo "--- dash のライセンス ---"
if [ -f /usr/share/doc/dash/copyright ]; then
    head -15 /usr/share/doc/dash/copyright
else
    echo "  dash は BSD 3-Clause でライセンスされている"
fi

echo ""

# zsh のライセンス確認
echo "--- zsh のライセンス ---"
apt-get install -y -qq zsh >/dev/null 2>&1
if [ -f /usr/share/doc/zsh-common/copyright ]; then
    head -20 /usr/share/doc/zsh-common/copyright
elif [ -f /usr/share/doc/zsh/copyright ]; then
    head -20 /usr/share/doc/zsh/copyright
else
    echo "  zsh は MIT-like ライセンスでライセンスされている"
fi

echo ""
echo "--- ライセンス比較 ---"
echo "  bash 3.2以前: GPLv2"
echo "  bash 4.0以降: GPLv3"
echo "  dash:         BSD 3-Clause"
echo "  zsh:          MIT-like"
echo "  fish:         GPLv2"
echo ""
echo "  Apple が受け入れ可能: GPLv2, BSD, MIT, Apache 2.0"
echo "  Apple が拒否:         GPLv3"
```

---

## 5. まとめと次回予告

### この回の要点

第一に、GPLv3は2007年6月29日にFSFが公表したGPLv2の後継ライセンスであり、Anti-Tivoization条項、明示的特許保護、DRM対策の三つの柱で構成されている。この改訂は、ハードウェアとソフトウェアを統合して消費者向け製品を販売する企業――とりわけAppleにとって、事業モデルとの根本的な衝突をもたらした。

第二に、bash 3.2（2006年10月）はGPLv2でリリースされた最後のbashメジャーバージョンであり、bash 4.0（2009年2月20日）でGPLv3に移行した。この時点で、Appleはbashの更新を凍結する道を選んだ。2026年現在もmacOSの`/bin/bash`は3.2.57のままだ。

第三に、AppleはGPLv3ソフトウェアの体系的な排除を進めた。Samba→自社製SMBX（2011年）、GCC→Clang/LLVM、GNU coreutils→BSD版ツール、そしてbash→zsh（2019年）。OS X 10.5の47パッケージから10.7の29パッケージへ、GPLソフトウェアは着実に減少した。

第四に、macOSのデフォルトシェルはtcsh（〜2003年）→bash（2003-2019年）→zsh（2019年〜）と変遷した。zshが選ばれた理由は技術的互換性だけではない。MITライセンスであり、GPLv3の制約がないことが決定的だった。

第五に、bash 3.2.57の凍結により、macOS開発者は連想配列、globstar、nameref変数、パラメータ変換など、2009年以降の13年分のbash新機能を`/bin/bash`では使用できない。Homebrewによる最新bashのインストールという回避策は存在するが、スクリプトのポータビリティに新たな課題を生む。

### 冒頭の問いへの暫定回答

「macOSがデフォルトシェルをbashからzshに変えたのは『技術的判断』だったのか、『ライセンス上の判断』だったのか」――この問いに対する暫定的な答えはこうだ。

両方だ。だが、因果の順序はライセンスが先だ。

GPLv3がなければ、Appleはbash 5.xへの更新を続け、bashをデフォルトシェルとして維持していた可能性が高い。GPLv3への移行がbashの更新を不可能にし、凍結された古いbashを使い続けることの技術的負債が蓄積し、最終的にzshへの移行という技術的判断に至った。ライセンスの変更が、技術的な連鎖反応を引き起こしたのだ。

この事例は、技術者に重要な教訓を突きつける。優れたソフトウェアであっても、ライセンスが変われば排除される。コードの品質は必要条件だが、十分条件ではない。ソフトウェアの「自由」をどう定義するか――FSFの定義とAppleの定義は異なる。その違いが、技術の普及と消滅を左右する。

bashの覇権は技術的必然ではなく、GNUのライセンス政策とLinuxの普及という歴史的条件の産物だった。その条件の一つ――ライセンスの安定性――が崩れたとき、覇権もまた揺らいだ。

### 次回予告

今回、bashの覇権を揺るがした「ライセンスの断層」を語った。次回は、bashの覇権がもたらした別の問題を扱う。

次回のテーマは「シェルとセキュリティ――インジェクション、eval、権限昇格」だ。

Shellshock（CVE-2014-6271）。bash 1.03から4.3まで、25年間にわたり潜伏していた脆弱性。環境変数に格納された関数定義の処理バグが、全世界のWebサーバを危険にさらした。`eval`が「最も危険なビルトイン」と呼ばれる理由。シェルの柔軟性とセキュリティの脆弱性が表裏一体であるという事実。

「シェルスクリプトのセキュリティリスクを、あなたはどこまで理解しているか」――次回は、その問いに向き合う。

---

## 参考文献

- Free Software Foundation, "FSF releases the GNU General Public License, version 3", 2007 <https://www.fsf.org/news/gplv3_launched>
- Richard Stallman, "Why Upgrade to GPLv3", GNU Project <https://www.gnu.org/licenses/rms-why-gplv3.en.html>
- FSF, "A Quick Guide to GPLv3" <https://www.gnu.org/licenses/quick-guide-gplv3.html>
- Wikipedia, "Tivoization" <https://en.wikipedia.org/wiki/Tivoization>
- Wikipedia, "GNU General Public License" <https://en.wikipedia.org/wiki/GNU_General_Public_License>
- Wikipedia, "macOS Catalina" <https://en.wikipedia.org/wiki/MacOS_Catalina>
- Wikipedia, "Z shell" <https://en.wikipedia.org/wiki/Z_shell>
- Wikipedia, "Clang" <https://en.wikipedia.org/wiki/Clang>
- OSnews, "Apple switching from tcsh to bash", 2003 <https://www.osnews.com/story/4340/apple-switching-from-tcsh-to-bash/>
- Slashdot, "Apple Remove Samba From OS X 10.7 Because of GPLv3", 2011 <https://apple.slashdot.org/story/11/03/24/1546205/apple-remove-samba-from-os-x-107-because-of-gplv3>
- Hacker News, "Apple's great GPL purge", 2012 <https://news.ycombinator.com/item?id=3559990>
- Julio Merino, "The /bin/bash baggage of macOS", 2019 <https://jmmv.dev/2019/11/macos-bash-baggage.html>
- Chet Ramey, "Bash-3.2 available for FTP", 2006 <https://sourceware.org/legacy-ml/cygwin/2006-10/msg00464.html>
- LWN.net, "Bash 4.0 released", 2009 <https://lwn.net/Articles/320366/>
- LWN.net, "Bash 4.0 brings new capabilities", 2009 <https://lwn.net/Articles/320546/>
- TLDP, "Bash, version 4" <https://tldp.org/LDP/abs/html/bashver4.html>
- The Register, "Apple makes fancy zsh default in forthcoming macOS Catalina", 2019 <https://www.theregister.com/2019/06/04/apple_zsh_macos_catalina_default/>
- Chainguard, "Updating bash on macOS" <https://edu.chainguard.dev/open-source/update-bash-macos/>
- GNU Bash Reference Manual <https://www.gnu.org/software/bash/manual/bash.html>
