# UNIXという思想

## ――パイプ、プロセス、ファイル――すべてはここから始まった

### 第21回：「WSL――WindowsがUNIXに屈服した日」

**連載「UNIXという思想――パイプ、プロセス、ファイル――すべてはここから始まった」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- MicrosoftがLinuxを「癌」と呼んだ2001年から「Microsoft loves Linux」へ至る15年間の方針転換の経緯
- WSL 1（2016年）のsyscall変換レイヤー（pico process）アーキテクチャとその限界
- WSL 2（2019年）のHyper-V軽量VM方式への転換と、実際のLinuxカーネル搭載という決断
- Windows NTの「すべてはオブジェクトである」とUNIXの「すべてはファイルである」という設計思想の根本的差異
- WSLg、systemdサポート、Docker Desktop統合に見る段階的進化
- WSL 2環境の構築と、WindowsとLinuxの境界を体験するハンズオン

---

## 1. デュアルブートの終わった日

2020年の春、私は長年続けてきた習慣を捨てた。デュアルブートである。

1990年代後半からずっと、私のメインマシンにはWindowsとLinuxが共存していた。Slackwareから始まり、Red Hat、Debian、Ubuntu――Linuxディストリビューションは変遷したが、「起動時にGRUBメニューでOSを選択する」という儀式は20年以上変わらなかった。Windowsは事務作業とクライアントとのやり取りに使い、開発作業はLinuxで行う。二つの世界を切り替えるために、毎回再起動が必要だった。

WSL 2の存在を知ったのは2019年のことだ。「WindowsカーネルにLinuxカーネルが載る」という話を聞いたとき、正直に言えば半信半疑だった。MicrosoftがLinux環境を本気で提供するなど、2001年のスティーブ・バルマーの発言を知る世代の人間には信じがたい話だった。

だが実際にWSL 2を触ってみて、考えが変わった。`wsl`コマンドを叩くと、数秒でLinuxのシェルが立ち上がる。`apt`でパッケージを入れ、`gcc`でコンパイルし、`docker`でコンテナを動かす。すべてWindowsのデスクトップの中で完結する。ファイルシステムの境界を超えてWindowsのファイルにもアクセスできるし、VS Codeからシームレスにリモート接続もできる。

再起動が不要になった。GRUBメニューが消えた。20年以上続けてきたデュアルブートの習慣が、不要になったのだ。

これは便利になったという話ではない。MicrosoftがUNIX/Linuxの設計思想を「代替不可能なもの」として受け入れたという事実の話だ。かつて「癌」と呼んだものを、自らのOSの中に抱え込んだ。この転換は何を意味するのか。UNIXの設計思想がどれほど深く現代のソフトウェア開発に根を下ろしているかを、これほど端的に示す事例は他にない。

---

## 2. MicrosoftとUNIX/Linux――30年の相克

### 「すべてはオブジェクトである」という別の道

WSLの歴史を語る前に、WindowsとUNIXの設計思想の根本的な違いを理解しておく必要がある。

第6回で取り上げたUNIXの「すべてはファイルである」という原則を覚えているだろうか。通常のファイル、デバイス、ソケット、パイプ――UNIXはこれらすべてをファイルディスクリプタという統一インタフェースで扱う。`open()`, `read()`, `write()`, `close()`の四つのシステムコールで、あらゆるI/O操作を抽象化した。

Windows NTは、これとは異なる道を選んだ。「すべてはオブジェクトである」という設計思想だ。

Windows NTの設計者はDave Cutlerである。CutlerはDEC（Digital Equipment Corporation）でVAX/VMSオペレーティングシステム（1978年）を設計した人物だ。1988年にMicrosoftに移籍し、NTカーネルの設計を率いた。Cutlerが持ち込んだのは、VMSのオブジェクト管理の思想だった。

NTカーネルの中核にはObject Managerが存在する。ファイル、スレッド、プロセス、レジストリキー、イベント、ミューテックス――すべてのカーネルリソースが「オブジェクト」として管理され、それぞれが属性リストを持ち、個別のACL（Access Control List）によって保護される。UNIXがファイルディスクリプタという単一の抽象化で統一したのに対し、NTは型付きオブジェクトという、より構造化された抽象化を選んだ。

```
設計思想の対比:

UNIX: "Everything is a file"
┌─────────────────────────────────────────┐
│ ファイルディスクリプタ (fd)              │
│   open() / read() / write() / close()   │
│                                         │
│ 通常ファイル ─┐                         │
│ デバイス ─────┤                         │
│ パイプ ───────┤── すべて同一のfd操作     │
│ ソケット ─────┤                         │
│ /proc ────────┘                         │
└─────────────────────────────────────────┘

Windows NT: "Everything is an object"
┌─────────────────────────────────────────┐
│ Object Manager                          │
│   型付きオブジェクト + ACL               │
│                                         │
│ File Object ──────┐                     │
│ Thread Object ────┤                     │
│ Process Object ───┤── 型ごとの操作      │
│ Event Object ─────┤   + 共通ハンドル    │
│ Registry Key ─────┘                     │
└─────────────────────────────────────────┘
```

この設計の違いは、単なる実装の差異ではない。哲学の差異だ。UNIXは「シンプルな統一インタフェースの力」を信じた。NTは「型安全な構造化の力」を信じた。どちらが正しいかは一概に言えないが、一つ明確なことがある。UNIXの設計思想は、パイプ、リダイレクト、シェルスクリプトという強力な「組み合わせの文化」を生んだ。この文化こそが、開発者がUNIX環境を手放せない理由であり、MicrosoftがWSLを作らざるを得なかった根本原因だ。

### 敵対の時代――2001年の「癌」発言

MicrosoftとLinux/オープンソースの関係は、長く険しいものだった。

2001年6月1日、MicrosoftのCEOスティーブ・バルマーはChicago Sun-Timesのインタビューで、歴史に残る発言をした。

> "Linux is a cancer that attaches itself in an intellectual property sense to everything it touches."
> （Linuxは知的財産の観点から、触れるものすべてに取り付く癌だ）

バルマーが攻撃していたのは、厳密にはLinuxそのものではなくGPL（GNU General Public License）のコピーレフト条項だ。GPLソフトウェアを組み込んだ製品はソースコードの公開義務が生じる。Microsoftのビジネスモデル――プロプライエタリソフトウェアのライセンス販売――にとって、これは存在そのものへの脅威と映った。

同じインタビューでバルマーはLinuxを"good competition"とも評しており、技術的品質を否定していたわけではない。だが「癌」という言葉の衝撃は大きく、MicrosoftとオープンソースコミュニティのHallenge関係を象徴するフレーズとなった。

この時期のMicrosoftは、ハロウィーン文書（1998年にリークされた内部メモ）でLinuxを競合脅威として分析し、FUD（Fear, Uncertainty, Doubt）戦略でオープンソースの普及を阻止しようとしていた。SCO-Linux訴訟（2003年〜）でSCO側を間接的に支援したとされる動きもあった。MicrosoftとLinuxは、技術ではなく政治とビジネスモデルの次元で対立していた。

### ナデラの転換――2014年の「Microsoft loves Linux」

転機は、2014年2月のサティア・ナデラのCEO就任だった。

ナデラが就任後に進めた方針転換は、段階的だが徹底的だった。2014年10月、サンフランシスコでのクラウドイベントで、ナデラは「Microsoft ♥ Linux」と書かれたスライドをスクリーンに映し出した。会場には驚きと困惑が入り混じった。当時、Azure上のVMの20%がLinuxで稼働していた。ナデラはWired誌に対し「古い戦いに興味はない。新しいものに飛びつかなければ生き残れない」と語った。

ナデラの転換は、一回限りのパフォーマンスではなかった。その後の動きを時系列で追うと、戦略の体系性が見えてくる。

```
Microsoftのオープンソース戦略転換:

2014年2月  サティア・ナデラ CEO就任
2014年10月 「Microsoft ♥ Linux」宣言
2014年11月 .NET Coreオープンソース化・クロスプラットフォーム対応発表
2015年      Visual Studio Codeリリース（オープンソース）
2016年3月  WSL発表（Build 2016）
2016年8月  WSL 1 ベータ提供開始（Windows 10 Anniversary Update）
2016年11月 Linux Foundation加入
2018年6月  GitHub買収発表（75億ドル）
2019年5月  WSL 2発表（実際のLinuxカーネル搭載）
2021年      WSLg（Linux GUIアプリサポート）
2022年      WSLでsystemdサポート
2025年5月  WSLオープンソース化（Build 2025）
```

この時系列を見ると、WSLは孤立した製品ではなく、Microsoftの全社的なオープンソース戦略の一環であることがわかる。.NETのオープンソース化、VS Codeのリリース、Linux Foundationへの加入、GitHubの買収――これらすべてが、同じ方向を向いている。プロプライエタリソフトウェアの販売からクラウドサービスへのビジネスモデル転換の中で、開発者エコシステムの中心にいることが最重要課題となった。そして開発者エコシステムの中心には、UNIX/Linuxがあった。

2019年の時点で、Azure上のVM容量の過半数がLinuxで稼働していた。Microsoftのクラウドプラットフォーム上で、LinuxがWindowsを上回った。これは皮肉ではなく、ナデラが「クラウドファースト」を掲げた戦略の必然的帰結だった。クラウド上のワークロードの過半数がLinuxで動いている以上、Microsoftがクラウド企業として成功するにはLinuxを全面的に支援するしかない。

---

## 3. WSLの技術的アーキテクチャ――二つの世代

### WSL 1（2016年）：syscall変換という大胆な挑戦

2016年3月30日、Build 2016の基調講演でKevin Gallo（Windows Developer Platform ディレクター）がWSLを発表した。当時の名称は「Bash on Ubuntu on Windows」。発表の瞬間、会場は沸き立った。Channel9チームが配信へのアクセス殺到をDDoS攻撃と誤認したほどの反響だった。

WSL 1のアーキテクチャは、極めて大胆なものだった。仮想マシンもエミュレーションも使わず、Windows NTカーネル上でLinuxのシステムコールを直接変換するという方式だ。

```
WSL 1のアーキテクチャ:

┌─────────────────────────────────────┐
│ Linux ELFバイナリ                    │
│ (bash, gcc, apt, etc.)              │
├─────────────────────────────────────┤
│ Pico Process                        │
│ (最小限のWindows プロセス)           │
├─────────────────────────────────────┤
│ lxss.sys / lxcore.sys               │
│ (Linux syscall → NT syscall 変換)   │
│                                     │
│ fork() → NtCreateProcess()          │
│ open() → NtOpenFile()               │
│ read() → NtReadFile()               │
│ pipe() → NtCreateNamedPipe()        │
│ ...                                 │
├─────────────────────────────────────┤
│ Windows NTカーネル                    │
└─────────────────────────────────────┘

Linuxカーネルは存在しない。
NT上のドライバがLinux syscallを逐一翻訳する。
```

pico processとは、Microsoftの研究部門が開発した最小プロセス概念だ。通常のWindowsプロセスが持つWin32サブシステムとの紐づけを排除し、空のアドレス空間を持つ最小限のプロセスとして動作する。このpico processの中でLinuxのELFバイナリが実行され、Linux系のシステムコールが発行されると、lxcore.sysドライバがそれをWindows NTの対応するシステムコールに変換する。

この設計には明確な利点があった。Linuxのバイナリが、仮想マシンのオーバーヘッドなしに、ほぼネイティブに近い速度で動作する。Windowsのファイルシステムへのアクセスも高速だった。NTFSのファイルがそのままLinux側からも見えるため、OS間のファイル共有に余分なコストがかからない。

だが、この方式には本質的な限界があった。Linuxカーネルが提供するシステムコールは300以上存在し、その一つ一つを正確にNTカーネルの動作に変換する必要がある。しかもLinuxのシステムコールの振る舞いは微妙な部分が多い。エッジケースやカーネル固有の動作まで完全に再現することは、事実上不可能だった。Dockerのような高度なカーネル機能（namespaces、cgroups）に依存する技術は、WSL 1では動作しなかった。

第20回でDockerとKubernetesを扱ったが、コンテナの本質はLinuxカーネルのnamespaceとcgroupsという機能にある。WSL 1にはLinuxカーネルそのものが存在しない以上、これらのカーネル機能を再現することは根本的に困難だった。

### WSL 2（2019年）：Linuxカーネルを搭載するという決断

2019年5月6日、MicrosoftはWSL 2を発表した。そしてそのアーキテクチャは、WSL 1とは根本的に異なるものだった。

WSL 2は、Hyper-Vの軽量仮想化技術を使って、実際のLinuxカーネルを動かす。Microsoftが独自にビルドしたLinuxカーネル（初期バージョン4.19）が、Windows上の軽量VM内で起動する。

```
WSL 2のアーキテクチャ:

┌─────────────────────────────────────┐
│ Linux ELFバイナリ                    │
│ (bash, gcc, apt, docker, etc.)      │
├─────────────────────────────────────┤
│ Linux カーネル (Microsoft独自ビルド)  │
│ namespaces, cgroups, ext4 等         │
│ すべてのLinux syscallをネイティブ処理 │
├─────────────────────────────────────┤
│ Hyper-V 軽量VM                      │
│ (起動時間: 約1-2秒)                  │
│ (動的メモリ割り当て)                 │
├─────────────────────────────────────┤
│ Windows NTカーネル + Hyper-Visor      │
└─────────────────────────────────────┘

実際のLinuxカーネルが動いている。
完全なsyscall互換性。Docker/コンテナも動作。
```

この設計変更は、MicrosoftがLinuxカーネルそのものをWindows上で配布するという、2001年のバルマーの発言からは想像もできない決断だった。しかも、このカーネルはMicrosoftのエンジニアが独自にビルドしたもので、WSL向けに最適化されている。ソースコードはGitHub上で公開され、カーネルのコンフィグレーションも確認できる。

WSL 1とWSL 2のトレードオフは、設計思想の違いを反映している。

```
WSL 1 vs WSL 2のトレードオフ:

                    WSL 1           WSL 2
─────────────────────────────────────────────
アーキテクチャ      syscall変換     軽量VM + Linuxカーネル
Linuxカーネル       なし            あり（実物）
syscall互換性       部分的          完全
Docker/コンテナ     非対応          対応
Linux FS性能        中程度          非常に高速（最大20倍）
Windows FS性能      高速（直接）    低速（約1/5）
ネットワーク        ホストと共有    NAT（IPアドレス別）
メモリ使用量        少ない          動的（VM分の消費あり）
起動時間            即時            約1-2秒
```

注目すべきは、Windowsファイルシステムへのアクセス性能だ。WSL 1ではNTFSのファイルを直接操作できたため、Windows側のファイルへのアクセスは高速だった。WSL 2ではVM境界を越える必要があるため、`/mnt/c/`経由のNTFSアクセスはWSL 1の約5分の1の速度に低下する。逆に、Linux側のext4ファイルシステム上での操作は、WSL 2がWSL 1を圧倒する。tarballの展開で最大20倍、`git clone`や`npm install`で2〜5倍の高速化が報告されている。

このトレードオフは、開発者の作業ディレクトリをどこに置くかという実践的な判断に直結する。WSL 2ではプロジェクトファイルをLinux側のファイルシステム（例：`/home/user/projects/`）に置くことが推奨される。Windows側のファイルシステムに置いたままWSL 2からアクセスすると、性能上の不利益を被る。

ネットワークも変わった。WSL 1ではホストマシンとネットワークスタックを共有していたため、`localhost`でそのままアクセスできた。WSL 2はNATベースの仮想ネットワークを使用し、WSL側には独自のIPアドレスが割り当てられる。再起動するとIPアドレスが変わる。これは開発環境のポートフォワーディングやネットワーク設定に影響を与える。

### 進化は止まらない――WSLg、systemd、そしてオープンソース化

WSL 2の登場後も、機能拡張は続いている。

**WSLg（2021年）** は、Linux GUIアプリケーションをWindows上で実行可能にした。内部的には、WSL 2のシステムディストリビューション（Microsoft Azure Linux 3.0ベース）内でWeston（Waylandコンポジタ）とXWayland（X11互換レイヤー）が動作し、Linux GUIアプリの画面をWindowsデスクトップに転送する。OpenGLレンダリングはD3D12 Galliumドライバ経由でGPUアクセラレーションを受けられる。CLIだけでなくGUIも、UNIX/Linuxの世界がWindowsの中に流れ込んできた。

**systemdサポート（2022年）** は、WSL 0.67.6で実現した。MicrosoftとCanonicalの共同作業の成果だ。第17回でsystemd論争を取り上げたが、systemdはLinuxのサービス管理の事実上の標準となっている。systemdなしのWSL環境では、Docker、snap、その他systemdに依存するサービスの運用に制約があった。systemdサポートの追加により、WSL内のLinux環境は「本物のLinuxディストリビューション」にまた一歩近づいた。

**Docker Desktop統合** は、WSL 2のアーキテクチャがコンテナ技術と相性が良いことの直接的な表れだ。Docker Desktopは`docker-desktop`という専用のWSLディストリビューション内で動作し、他のWSLディストリビューションとDocker CLIを共有できる。WSL 2がHyper-Vの軽量VMで実際のLinuxカーネルを動かしているからこそ、namespacesとcgroupsに依存するDockerが問題なく動作する。

そして**2025年5月のBuild 2025**で、MicrosoftはWSL自体をオープンソース化した。コマンドラインツール（wsl.exe、wslg.exe）、バックグラウンドサービス（wslservice.exe）、Linux側デーモンのソースコードがGitHub上で公開された。WSL 1のカーネルドライバ（Lxcore.sys）やファイルシステムリダイレクション関連のコンポーネント（P9rdr.sys、p9np.dll）はWindows本体の一部であるため非公開のままだが、それ以外のWSLの主要コンポーネントが誰でも読み、修正し、コントリビュートできるようになった。

2001年に「癌」と呼んだLinuxのカーネルを、自社OS上で動かし、その管理ツールをオープンソースで公開する。この変遷を、技術の勝利と見るか、ビジネスの必然と見るか。おそらくその両方だ。

---

## 4. なぜMicrosoftはUNIXに「屈服」したのか

「屈服」という言葉は挑発的だ。Microsoftの立場から見れば「戦略的適応」だろう。だが、事実を見れば、UNIXの設計思想がMicrosoftを動かしたことは否定できない。

### 開発者ツールチェーンの引力

現代のソフトウェア開発ツールチェーンは、UNIX/Linux環境を前提として構築されている。

Node.jsのnpm、Pythonのpip、Rubyのgem、Rustのcargo――主要な言語のパッケージマネージャは、すべてUNIX系環境でネイティブに動作するよう設計されている。Dockerはlinuxカーネルのnamespace/cgroupsを前提としている。CI/CDパイプラインの大半はLinux上で動く。Infrastructure as CodeのツールチェーンはPOSIXシェルを前提としている。

Windows上で開発する場合、これらのツールを使うためには何らかの互換レイヤーが必要だった。Cygwin、MSYS2、Git for Windows――いずれも不完全な代替手段であり、UNIX環境の完全な再現には程遠かった。

開発者がmacOSに流出していた。macOSは第19回で述べたように、DarwinというUNIXの上にAppleのUIが載った構造を持つ。開発者にとって、macOSは「UNIXが使えて、かつ洗練されたGUIを持つ」理想的な環境だった。Microsoftは、Windows上でUNIX環境を提供しなければ、開発者を失い続けることになる。WSLは、その危機感から生まれた。

### 9Pプロトコル――Plan 9の遺産がここにも

WSL 2のアーキテクチャには、興味深い技術的ディテールがある。Windows側からWSL内のLinuxファイルシステムにアクセスする際、`\\wsl.localhost\`というUNCパスを使うが、この通信にはPlan 9の9Pプロトコルの派生版が使われている。

第18回でPlan 9を取り上げた際、「Plan 9は商業的には失敗したが、そのアイデアは形を変えて現代のOSに流れ込んでいる」と述べた。WSLの9Pプロトコルの採用は、その具体例の一つだ。Plan 9で「すべてをファイルシステムとして公開する」ために設計された9Pが、WindowsとLinuxの橋渡しに使われている。技術のアイデアは、それを生んだプロジェクトが消えても、生き続ける。

### 「すべてはファイルである」の勝利

WSLの存在が証明しているのは、UNIXの設計思想の普遍性だ。

UNIXの「すべてはファイルである」「テキストストリームを共通のインタフェースにする」「小さなツールを組み合わせる」という原則は、一つのOS上のローカルな規約ではなく、ソフトウェア開発全体のインフラストラクチャとして定着した。bashスクリプト、パイプライン処理、`/proc`や`/sys`を介したシステム情報へのアクセス、`fork()`と`exec()`によるプロセス管理――これらのUNIXの作法が、開発者にとっての「母語」となっている。

Microsoftは、自社のOSの設計思想を変えたわけではない。Windows NTのObject Managerは健在であり、Win32 APIも廃止されていない。Microsoftがしたのは、UNIX/Linuxの世界をWindows上に「もう一つの層」として載せたことだ。これは妥協であり、同時に認識の表明でもある。現代のソフトウェア開発は、UNIX的な環境なしには成立しない、という認識の。

---

## 5. ハンズオン：WSL 2環境でUNIXとWindowsの境界を体験する

### 環境準備

```bash
# WSL 2環境で実行する
# WSLが未インストールの場合は、PowerShell（管理者）で以下を実行:
#   wsl --install
# 既存のWSL環境がある場合はそのまま進む

echo "=== WSL環境情報 ==="
echo "カーネルバージョン: $(uname -r)"
echo "ディストリビューション: $(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
echo "アーキテクチャ: $(uname -m)"
echo ""
echo "WSLのLinuxカーネルはMicrosoftが独自にビルドしたものだ。"
echo "'microsoft' の文字列がカーネルバージョンに含まれていることを確認する。"
```

### 演習1：二つの世界の境界を確認する

```bash
echo "=== 演習1: WindowsとLinuxのファイルシステム境界 ==="
echo ""

echo "--- Linux側のルートファイルシステム ---"
ls /
echo ""
echo "これはext4上のLinuxファイルシステムだ。"
echo "UNIXの伝統的なディレクトリ構造が見える。"
echo ""

echo "--- Windows側のファイルシステム（/mnt/c） ---"
ls /mnt/c/ 2>/dev/null | head -10
echo ""
echo "/mnt/c/ はWindowsのCドライブをマウントしたものだ。"
echo "9Pプロトコル経由でアクセスしている。"
echo ""

echo "--- ファイルシステムの種類を確認 ---"
df -T / /mnt/c 2>/dev/null
echo ""
echo "Linux側はext4、Windows側は9p（Plan 9 File Protocol）と表示される。"
echo "第18回で取り上げたPlan 9の遺産が、ここに生きている。"
```

### 演習2：syscall互換性とLinuxカーネル機能を確認する

```bash
echo "=== 演習2: WSL 2のLinuxカーネル機能 ==="
echo ""

echo "--- namespaces（カーネルの隔離機能） ---"
ls -la /proc/self/ns/
echo ""
echo "WSL 2は実際のLinuxカーネルを動かしているため、"
echo "namespaceの情報が/proc配下にファイルとして存在する。"
echo "UNIXの「すべてはファイルである」原則そのものだ。"
echo ""

echo "--- cgroups ---"
cat /proc/self/cgroup 2>/dev/null
echo ""
echo "cgroupsもカーネル機能として利用可能。"
echo "これがあるからこそ、WSL 2上でDockerが動作する。"
echo ""

echo "--- /proc/version: カーネルの素性 ---"
cat /proc/version
echo ""
echo "Microsoftがビルドしたカーネルであることがわかる。"
echo "2019年の初期ビルドはLinux 4.19系だったが、"
echo "現在は継続的にアップデートされている。"
```

### 演習3：Windowsプロセスとの相互運用

```bash
echo "=== 演習3: WSLからWindowsコマンドを呼び出す ==="
echo ""

echo "--- WSLからWindowsのexeを直接実行 ---"
echo "Windowsのホスト名:"
hostname.exe 2>/dev/null || echo "(Windows実行ファイルへのアクセス不可)"
echo ""

echo "--- UNIXパイプでWindowsコマンドとLinuxコマンドを連携 ---"
echo "WSLの特異な点は、UNIXのパイプで"
echo "LinuxコマンドとWindowsコマンドを繋げられることだ。"
echo ""
echo "例: ipconfig.exe | grep IPv4"
echo "（Windows側のネットワーク設定をLinuxのgrepで検索する）"
echo ""
ipconfig.exe 2>/dev/null | grep "IPv4" || echo "(WSL環境外では実行不可)"
echo ""
echo "LinuxのgrepがWindowsのipconfig.exeの出力をフィルタしている。"
echo "二つのOSの世界がパイプで繋がっている。"
echo "UNIXのパイプは、OS境界すら超える。"
```

### 演習4：ファイルシステム性能の境界を体感する

```bash
echo "=== 演習4: ファイルシステム性能比較 ==="
echo ""
echo "WSL 2のファイルシステム性能は、"
echo "ファイルの置き場所によって劇的に異なる。"
echo ""

LINUX_DIR="/tmp/wsl-bench-linux"
WIN_DIR="/mnt/c/temp/wsl-bench-win"
FILE_COUNT=1000

# Linux FS上でのテスト
mkdir -p "$LINUX_DIR"
echo "--- Linux FS上（ext4）での小ファイル作成: ${FILE_COUNT}個 ---"
START=$(date +%s%N)
for i in $(seq 1 $FILE_COUNT); do
    echo "test" > "$LINUX_DIR/file_$i.txt"
done
END=$(date +%s%N)
LINUX_TIME=$(( (END - START) / 1000000 ))
echo "所要時間: ${LINUX_TIME}ms"
rm -rf "$LINUX_DIR"
echo ""

# Windows FS上でのテスト（/mnt/cが存在する場合のみ）
if [ -d "/mnt/c" ]; then
    mkdir -p "$WIN_DIR" 2>/dev/null
    if [ -d "$WIN_DIR" ]; then
        echo "--- Windows FS上（9P/NTFS）での小ファイル作成: ${FILE_COUNT}個 ---"
        START=$(date +%s%N)
        for i in $(seq 1 $FILE_COUNT); do
            echo "test" > "$WIN_DIR/file_$i.txt"
        done
        END=$(date +%s%N)
        WIN_TIME=$(( (END - START) / 1000000 ))
        echo "所要時間: ${WIN_TIME}ms"
        rm -rf "$WIN_DIR"
        echo ""

        echo "--- 結果 ---"
        if [ "$WIN_TIME" -gt 0 ] && [ "$LINUX_TIME" -gt 0 ]; then
            RATIO=$((WIN_TIME / LINUX_TIME))
            echo "Windows FS / Linux FS = 約${RATIO}倍の差"
        fi
        echo ""
        echo "Linux FS上の操作が圧倒的に速い。"
        echo "WSL 2ではプロジェクトファイルをLinux側に置くべき理由がここにある。"
        echo "VMの境界がそのまま性能特性に現れている。"
    else
        echo "(Windows側ディレクトリの作成に失敗――権限の問題)"
    fi
else
    echo "(WSL環境外のため/mnt/cが存在しない)"
fi
```

---

## 6. まとめと次回予告

### この回の要点

MicrosoftとUNIX/Linuxの関係は、ソフトウェア産業における最も劇的な方針転換の一つを物語っている。2001年にスティーブ・バルマーがLinuxを「知的財産に取り付く癌」と呼んでから、2025年にWSLをオープンソース化するまでの24年間は、UNIX設計思想の不可避性を証明する歴史だった。

WSL 1（2016年）はpico processとsyscall変換レイヤーという大胆なアプローチで、Windows NTカーネル上にLinux互換性を実現しようとした。Linuxカーネルを使わずにLinuxバイナリを動かすという設計は技術的に興味深かったが、完全なsyscall互換性の確保には限界があり、Docker等のカーネル依存技術は動作しなかった。

WSL 2（2019年）はHyper-Vの軽量VM上で実際のLinuxカーネル（Microsoft独自ビルド）を動かす方式に転換した。完全なsyscall互換性、namespaces/cgroupsのサポート、Docker動作を実現した一方で、Windowsファイルシステムへのクロスアクセス性能が低下するというトレードオフを受け入れた。

Windows NTの「すべてはオブジェクトである」という設計思想と、UNIXの「すべてはファイルである」という設計思想は、根本的に異なるアプローチだ。だが現代のソフトウェア開発において、UNIX的なツールチェーン――シェル、パイプ、パッケージマネージャ、コンテナ――は事実上の必需品となった。MicrosoftがWSLを通じてUNIX環境を提供した決断は、この現実への適応だ。

### 冒頭の問いへの暫定回答

「Microsoftが『Linux loves Windows』と言い始めた日、何が変わったのか。」

変わったのは、UNIX/Linuxの設計思想が「選択肢の一つ」から「開発者にとっての必需品」へと位置づけを変えたことだ。MicrosoftはWindows NTの設計思想を放棄したわけではない。Object ManagerもWin32 APIも健在だ。だがその上にUNIX/Linuxの世界をもう一つの層として載せた。これは、UNIXの設計哲学――「すべてはファイルである」「小さなツールを組み合わせる」「テキストを共通インタフェースにする」――が、もはや特定のOSの思想ではなく、ソフトウェア開発そのものの基盤になったことの証左だ。

バルマーの「癌」発言から、ナデラの「Microsoft loves Linux」を経て、WSLのオープンソース化に至る。この変遷は、UNIXの設計思想が持つ普遍性の証明である。ただし「屈服」という言葉には留保が必要だ。MicrosoftはUNIXの思想をWindows上に「取り込んだ」のであって、Windows自体をUNIXにしたわけではない。これは吸収であり、進化であり、そしてUNIXの思想が「代替不可能なもの」として認められた瞬間でもある。

### 次回予告

次回は「UNIX哲学の限界――何がうまくいかなかったか」。

ここまで20回にわたって、UNIX哲学の力と影響を語ってきた。だが哲学には限界がある。テキストストリームは型情報を持たない。GUIアプリケーションとの相性は悪い。ステートレスなフィルタモデルでは状態管理が困難だ。終了コードだけのエラーハンドリングは不十分だ。uid/gidベースのセキュリティモデルは粒度が粗い。

UNIX哲学を「教条」にしてはならない。原則を理解した上で、その原則が適用できない領域を見極めること。それが「原則を知る」ことの本当の価値だ。第22回では、UNIX哲学が「うまくいかなかった」場面に正面から向き合う。

---

## 参考文献

- The Register, "Ballmer: 'Linux is a cancer'", 2001年6月2日: <https://www.theregister.com/2001/06/02/ballmer_linux_is_a_cancer/>
- The Register, "Redmond top man Satya Nadella: 'Microsoft LOVES Linux'", 2014年10月20日: <https://www.theregister.com/2014/10/20/microsoft_cloud_event/>
- Windows Developer Blog, "Run Bash on Ubuntu on Windows", 2016年3月30日: <https://blogs.windows.com/windowsdeveloper/2016/03/30/run-bash-on-ubuntu-on-windows/>
- Tara Raj, "When We Brought Linux to Windows", Medium: <https://medium.com/microsoft-open-source-stories/when-linux-came-to-windows-204cf9abb3d6>
- Microsoft DevBlogs, "Announcing WSL 2", 2019年5月6日: <https://devblogs.microsoft.com/commandline/announcing-wsl-2/>
- Microsoft Learn, "Comparing WSL Versions": <https://learn.microsoft.com/en-us/windows/wsl/compare-versions>
- Microsoft DevBlogs, "The initial preview of GUI app support is now available for WSL", 2021年: <https://devblogs.microsoft.com/commandline/the-initial-preview-of-gui-app-support-is-now-available-for-the-windows-subsystem-for-linux-2/>
- GitHub, microsoft/wslg: <https://github.com/microsoft/wslg>
- Microsoft DevBlogs, "Systemd support is now available in WSL!", 2022年: <https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/>
- Windows Developer Blog, "The Windows Subsystem for Linux is now open source", 2025年5月19日: <https://blogs.windows.com/windowsdeveloper/2025/05/19/the-windows-subsystem-for-linux-is-now-open-source/>
- Build5Nines, "Linux is Most Used OS in Microsoft Azure": <https://build5nines.com/linux-is-most-used-os-in-microsoft-azure-over-50-percent-fo-vm-cores/>
- Microsoft News, "Microsoft to acquire GitHub for $7.5 billion", 2018年6月4日: <https://news.microsoft.com/source/2018/06/04/microsoft-to-acquire-github-for-7-5-billion/>
- Microsoft News, ".NET open source and cross-platform", 2014年11月12日: <https://news.microsoft.com/source/2014/11/12/microsoft-takes-net-open-source-and-cross-platform-adds-new-development-capabilities-with-visual-studio-2015-net-2015-and-visual-studio-online/>
- Wikipedia, "Windows NT": <https://en.wikipedia.org/wiki/Windows_NT>
- Wikipedia, "Dave Cutler": <https://en.wikipedia.org/wiki/Dave_Cutler>
- Wikipedia, "Windows Subsystem for Linux": <https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux>
- Docker Docs, "Docker Desktop WSL 2 backend on Windows": <https://docs.docker.com/desktop/features/wsl/>
- VS Code, "Developing in WSL": <https://code.visualstudio.com/docs/remote/wsl>
