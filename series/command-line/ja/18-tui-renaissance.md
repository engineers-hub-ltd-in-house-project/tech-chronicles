# ターミナルは遺物か

## ――コマンドラインの本質を問い直す

### 第18回：TUIの復権――Charm, Bubbletea, Ink, Textual

**連載「ターミナルは遺物か――コマンドラインの本質を問い直す」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- CUIからTUIへ――テキストベースUIの60年にわたる変遷と、2020年代に「復権」が起きた構造的理由
- Norton Commander（1986年）からMidnight Commander（1994年）、mutt（1995年）まで、ncurses時代のTUIが果たした役割と衰退の経緯
- Bubbletea（2020年、Go、Elm Architecture）、Ink（2017年、React for CLI）、Textual（2021年、Python、CSSライクレイアウト）、Ratatui（2023年、Rust）――モダンTUIフレームワーク四者の設計思想と技術的差異
- Elm Architecture（Model-Update-View）がTUIにもたらした宣言的UI設計の革新
- Wish（Charm社）によるSSH越しのTUI配信という新しいパラダイム
- lazygit、k9s、htopなど実用TUIアプリケーションの「ちょうどよさ」の正体

---

## 1. ターミナルの中のGUI

lazygitを初めて触ったのは2020年の初夏だった。

Gitの操作は、私にとって完全にCLIの領域だった。`git status`、`git add -p`、`git commit`、`git log --oneline --graph`。これらのコマンドを20年以上打ち続けてきた。GitのGUIクライアントも試したことはある。SourceTree、GitKraken、VS CodeのGit統合。だが、どれも「もどかしさ」が残った。マウスでファイルを選択してステージングする操作が、`git add -p`でハンクを選ぶ操作より速いとは思えなかった。

lazygitを起動したとき、最初の印象は「これはターミナルの中のGUIだ」というものだった。画面は複数のパネルに分割され、左側にファイル一覧、右側にdiff、下部にログが表示されている。キーボードだけで操作する。ファイルの選択はカーソルキーで、ステージングはスペースキー一つで、コミットは`c`を押すだけだ。

だが、これはGUIではない。ターミナルエミュレータの中で動いている。SSHの向こう側でも動く。tmuxのペインの中でも動く。`.gitconfig`を書き換える必要もない。バイナリ一つをダウンロードして起動するだけだ。

lazygitの作者Jesse Duffieldが2018年8月にこのツールを公開してから5年後、彼はブログで「TUIは、CLIの組み合わせ可能性とGUIの発見可能性を両立する」と書いた。この一文が、私がこの回で語りたいことの核心を突いている。

lazygitだけではない。htopを使ったことがあるだろう。プロセス一覧がリアルタイムで更新され、CPUやメモリの使用率がバーグラフで表示される。k9sを使ったことがあるだろう。Kubernetesのポッドやデプロイメントが、ターミナルの中でリアルタイムに更新されるダッシュボードとして表示される。これらはすべて、ターミナルの中で動く「グラフィカルな」インターフェースだ。

CLIでもGUIでもない。テキストベースだが、対話的で、視覚的で、直感的だ。この「第三の領域」が、なぜ今、再び注目されているのか。

あなたは、自分が毎日使っているツールのうち、いくつが「TUI」に分類されるか、考えたことがあるだろうか。

---

## 2. TUIの第一世代――ncursesの時代

### テキストベースUIの原点

TUI――Text-based User Interface、あるいはTerminal User Interface――は、2020年代に突然現れた概念ではない。その歴史は、ターミナルが「対話的な画面」を持った瞬間まで遡る。

第5回で語ったANSIエスケープシーケンスが、TUIの技術的な基盤を提供した。カーソルを任意の位置に移動し、文字の色や属性を変更し、画面の特定の領域を書き換える。これらの機能があって初めて、テキストベースの「画面設計」が可能になった。

だが、エスケープシーケンスを直接操作してUIを構築するのは、あまりにも低レベルで煩雑だった。端末ごとにサポートするシーケンスが異なる。VT100のエスケープシーケンスはwyse60では動かない。IBM 3270は根本的に異なるプロトコルを使う。第5回で語ったtermcap/terminfoデータベースがこの差異を吸収するレイヤーとして機能したが、アプリケーション開発者が毎回terminfoを叩くのは非効率だ。

この問題を解決したのがcursesライブラリだ。1978年にUCBのKen Arnoldが開発した元のcursesは、端末の差異を抽象化し、ウィンドウ、カーソル移動、入力処理のAPIを提供した。1993年11月、Zeyd Ben-Halimがcursesのフリーソフトウェア再実装としてncurses（new curses）のv1.8.1をリリースした。1996年にThomas E. Dickeyがメンテナンスを引き継ぎ、以来30年近くにわたって開発が続いている。ncursesは、Linuxのターミナルアプリケーションの事実上の標準ライブラリとなった。

### Norton Commander――二画面ファイルマネージャの原型

ncursesがUNIXの世界でTUIの基盤を提供した一方、DOS/Windowsの世界では別の進化が起きていた。

1986年5月、John SochaはNorton Commanderを公開した。Peter Norton Computing（のちにSymantecが1990年に買収）から発売されたこのツールは、MS-DOSのコマンドラインの上に、二画面のファイルマネージャを構築した。Sochaは1984年秋、Cornell大学の大学院生時代に開発を始め、当初は「Visual DOS（VDOS）」と呼んでいた。

Norton Commanderの設計は、DOSのユーザーにとって革命的だった。それまでDOSでファイルを操作するには、`dir`でファイル一覧を表示し、`copy`や`del`で個別に操作する必要があった。Norton Commanderは、常に二つのファイルパネルを並べて表示し、ファンクションキーで操作する統一的なインターフェースを提供した。F5でコピー、F6で移動、F7でディレクトリ作成、F8で削除。画面の下部には、これらのキーバインドが常に表示されている。

InfoWorld誌は1988年1月の記事で、v1.0をリリースから2年経っても「way ahead of the pack（群を抜いて先頭）」と評した。速度、省メモリ、直感的なインターフェースが評価された。Norton Commanderは1986年から1998年まで、13以上のバージョンが商業リリースされた。

### Midnight Commander とmutt――UNIX世界のTUI

Norton Commanderの成功は、UNIX/Linux世界にも波及した。1994年、Miguel de Icaza（のちにGNOME、Mono、Xamarinの創設者として知られる）がGNU Midnight Commander（mc）の開発を開始した。最初のリリースは1994年10月29日のv1.0だ。Norton Commanderの二画面設計を踏襲しつつ、UNIXのファイルシステム、パーミッション、シンボリックリンクに対応した。GNUプロジェクトの一部として自由ソフトウェアライセンスで公開されたことで、Linuxディストリビューションに広く収録された。

私がSlackware 3.5でLinuxに入門した1990年代後半、mcはすでにインストールされていた。GUIが起動しない環境で、mcは「視覚的にファイルを操作できる」貴重なツールだった。ファイルの内容をF3で表示し、内蔵エディタでF4で編集する。FTPサイトにF9のメニューから接続する。これはCLIの操作性を超えた、テキストベースの「デスクトップ環境」だった。

同じ時代、メールの世界でもTUIが活躍していた。1995年、Michael Elkinsがmuttをリリースした。ELMメールクライアントのインターフェースを参考にしつつ一から書かれたmuttは、テキストベースのメールリーダーとして、今日に至るまで使われ続けている。muttの設計思想は、そのキャッチフレーズ「All mail clients suck. This one just sucks less.」に凝縮されている。機能の網羅性よりも、テキスト操作の効率性を追求した。

### 衰退期――GUIの勝利と「TUIの死」

1990年代後半から2000年代にかけて、TUIは衰退期に入った。Windows 95/98/XPの普及によりGUIが「普通の」インターフェースとなり、Linux世界でもGNOMEやKDEの成熟によりX Window Systemが日常的に使われるようになった。

第11回で語ったように、GUIは「発見可能性」において圧倒的な優位を持つ。メニューバーをクリックすれば利用可能な機能が一覧できる。アイコンは操作の意味を視覚的に伝える。TUIはこの点で、CLIよりはましだがGUIには遠く及ばない。Norton CommanderのF5=コピーという対応は覚える必要があった。

さらに、Webアプリケーションの普及がTUIの衰退を加速させた。2000年代以降、サーバ管理でさえWebベースの管理画面（Webmin、phpMyAdmin）が普及した。ターミナルを開いてmcでファイルを操作する代わりに、ブラウザでファイルマネージャにアクセスする。TUIが提供していた「テキストベースの視覚的操作」は、GUIとWebアプリケーションによって代替可能に見えた。

2000年代後半、「TUIは死んだ」という見方は、ほぼ業界のコンセンサスだった。htop（2004年、Hisham Muhammad）のような例外はあったが、それは「topの改善版」という位置づけに過ぎなかった。新しいTUIフレームワークを開発する動機は、ほぼ存在しなかった。

だが、TUIは死んでいなかった。眠っていただけだ。

---

## 3. モダンTUIフレームワークの設計革新

### 復権の背景――なぜ2020年代に再びTUIなのか

TUIが復権した理由は複数ある。そのどれか一つが決定的だったわけではなく、複数の要因が同時に作用した。

第一に、CLIツール自体の復権だ。第17回で語ったRust製CLIツール群の台頭は、「ターミナルで作業する」ことの価値を再認識させた。Docker CLI、kubectl、Terraform――2010年代以降、インフラストラクチャの操作はCLIに回帰した。ターミナルで過ごす時間が増えれば、ターミナル内のUXを改善する動機が生まれる。

第二に、ターミナルエミュレータの進化だ。第5回で語ったANSIエスケープシーケンスの制約は、現代のターミナルエミュレータでは大幅に緩和されている。True Color（24ビットカラー）、Unicode完全サポート、高速描画。ncurses時代には不可能だった表現が、2020年代のターミナルでは可能になった。

第三に、モダンなプログラミング言語とフレームワーク設計の進化だ。ncursesは強力だが、そのAPIはC言語の時代の設計を反映している。ポインタ操作、手動のメモリ管理、命令的な描画ロジック。これを現代のプログラマが「楽しい」と感じるのは難しい。新しいフレームワークは、Elm Architecture、React的な宣言的UI、CSSライクなレイアウトといった、Web開発の世界で磨かれた設計パターンをTUIに持ち込んだ。

第四に、SSH越しのリモートアクセスという、TUIの構造的優位性が再評価された。第16回で語ったように、GUIのリモート操作は帯域に依存する。VNCやRDPは高速な回線を前提とする。TUIはテキストストリームだ。SSHの帯域で十分動作する。クラウドネイティブの時代、リモートサーバ上で視覚的に操作できるインターフェースの価値は、むしろ高まっている。

### Bubbletea――Elm Architectureをターミナルに

2020年10月、Charm社のChristian RochaとToby Padillaが開発したBubbleteaが公開された。Go言語で実装されたこのフレームワークは、TUIアプリケーションの設計に根本的な変革をもたらした。

その核心は、Elm Architectureの採用にある。

Elm Architectureは、2012年にEvan CzaplickiがHarvard大学の論文として発表したElm言語から生まれたUIアーキテクチャパターンだ。Model（状態）、Update（状態遷移）、View（描画）という三つの関数でアプリケーション全体を構成する。Reduxをはじめ、Web開発の世界で広く影響を与えたパターンでもある。

Bubbleteaは、このパターンをそのままTUIに適用した。

```go
// Bubbleteaのプログラム構造（概念図）

type Model struct {
    choices  []string
    cursor   int
    selected map[int]struct{}
}

func (m Model) Init() tea.Cmd {
    return nil  // 初期コマンド（なし）
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
    switch msg := msg.(type) {
    case tea.KeyMsg:
        switch msg.String() {
        case "up":
            m.cursor--
        case "down":
            m.cursor++
        case "enter":
            // 選択状態を切り替え
            if _, ok := m.selected[m.cursor]; ok {
                delete(m.selected, m.cursor)
            } else {
                m.selected[m.cursor] = struct{}{}
            }
        case "q":
            return m, tea.Quit
        }
    }
    return m, nil
}

func (m Model) View() string {
    s := "What should we buy?\n\n"
    for i, choice := range m.choices {
        cursor := " "
        if m.cursor == i {
            cursor = ">"
        }
        checked := " "
        if _, ok := m.selected[i]; ok {
            checked = "x"
        }
        s += fmt.Sprintf("%s [%s] %s\n", cursor, checked, choice)
    }
    s += "\nPress q to quit.\n"
    return s
}
```

このコードが示すのは、TUIアプリケーションの構造が驚くほどシンプルになることだ。

`Model`はアプリケーションの状態をすべて保持する。カーソルの位置、選択状態、表示データ。`Update`はイベント（キー入力、タイマー、外部メッセージ）を受け取り、状態を更新する。`View`は現在の状態から画面全体の文字列を生成する。

ncursesのアプローチと比較してみよう。ncursesでは、画面の「どの部分を更新するか」をプログラマが管理する。ウィンドウを作成し、そのウィンドウの特定の座標に文字を書き込み、明示的にリフレッシュを呼ぶ。これは命令的（imperative）な設計だ。

```
ncurses（命令的）:
  1. ウィンドウを作成する
  2. カーソルを(3, 5)に移動する
  3. "Hello"と書き込む
  4. 属性を太字に変更する
  5. "World"と書き込む
  6. 画面をリフレッシュする

  → プログラマが「何を、どこに、どの順番で描画するか」を管理

Bubbletea（宣言的）:
  1. 状態（Model）を定義する
  2. 状態から画面全体の文字列を返す（View）
  3. イベントが来たら状態を更新する（Update）

  → フレームワークが差分計算と描画を管理
```

この「宣言的」アプローチの利点は、状態の管理が一箇所に集約されることだ。ncursesで複雑なTUIを書くと、画面のどの部分がどの状態に対応しているかの追跡が困難になる。Bubbleteaでは、`View`関数が状態から画面を完全に再生成する。状態が正しければ、画面も正しい。

Charm社はBubbleteaに加え、Lipgloss（スタイリングライブラリ）、Bubbles（プリメイドTUIコンポーネント群）、Glamour（Markdownレンダリング）など、TUI開発のためのエコシステム全体を構築した。これらのライブラリを組み合わせることで、視覚的に洗練されたTUIアプリケーションを、比較的少ないコードで構築できる。

### Ink――React的コンポーネントモデルをターミナルに

2017年、Vadim DemedesはInkを公開した。Inkの発想は大胆だ――Reactのコンポーネントモデルを、そのままターミナルに持ち込む。

InkはReactの実際の再帰的レンダリングエンジンを使用し、Yogaライブラリ（Facebookが開発したFlexboxレイアウトエンジン）によるレイアウト計算を行う。Web開発者が慣れ親しんだJSXの構文で、ターミナルのUIを記述できる。

```jsx
// Inkのコンポーネント例（概念図）

import React, { useState } from 'react';
import { render, Box, Text } from 'ink';

const Counter = () => {
  const [count, setCount] = useState(0);

  useInput((input, key) => {
    if (input === '+') setCount(prev => prev + 1);
    if (input === '-') setCount(prev => prev - 1);
    if (input === 'q') process.exit();
  });

  return (
    <Box flexDirection="column" padding={1}>
      <Text bold>Counter App</Text>
      <Box marginTop={1}>
        <Text>Count: </Text>
        <Text color="green">{count}</Text>
      </Box>
      <Text dimColor>
        Press + / - to change, q to quit
      </Text>
    </Box>
  );
};

render(<Counter />);
```

Inkの設計が興味深いのは、「Web開発者がTUIを書ける」という参入障壁の低さだ。Reactの経験があれば、Inkの学習コストはほぼゼロに近い。コンポーネントの分割、状態管理（`useState`、`useEffect`）、条件付きレンダリング――Web開発で毎日使っている技法が、そのままターミナルで通用する。

ただし、InkはNode.js環境を前提とする。ターミナルアプリケーションとして配布するには、Node.jsランタイムが必要だ。第17回で語ったRust製ツールの「シングルバイナリ配布」の手軽さとは対照的であり、ここにはトレードオフがある。Inkは「配布の容易さ」よりも「開発の容易さ」を優先した設計だ。

### Textual――CSSライクなスタイリングをターミナルに

2021年、Will McGuganはTextualの開発を開始した。McGuganは、Pythonのターミナル出力を美しくするRichライブラリの作者としてすでに知られていた。Textualは、Richの上に構築されたフルフレームワークであり、PythonでTUIアプリケーションを構築するための包括的な基盤を提供する。

Textualの最も特徴的な設計は、CSSライクなスタイリングシステムだ。Web開発におけるCSSがHTMLの構造とスタイルを分離したように、TextualはTUIアプリケーションのロジックとレイアウトを分離する。

```python
# Textualのアプリケーション例（概念図）

from textual.app import App, ComposeResult
from textual.widgets import Header, Footer, Static

class GreetingApp(App):
    CSS = """
    Screen {
        layout: vertical;
    }
    #greeting {
        width: 100%;
        height: auto;
        padding: 1 2;
        background: $surface;
        color: $text;
        text-align: center;
    }
    """

    def compose(self) -> ComposeResult:
        yield Header()
        yield Static("Hello, TUI World!", id="greeting")
        yield Footer()
```

CSSの`layout`、`padding`、`background`、`color`、`text-align`といったプロパティが、ターミナルの中で動作する。もちろん、CSSのすべてのプロパティがサポートされているわけではない。ターミナルの制約――固定幅フォント、限られた色空間、セル単位のレイアウト――の中で意味のあるプロパティが選択されている。

McGuganは2021年末にTextualize社を設立し、本格的に開発を進めた。2024年12月12日にTextual 1.0がリリースされた。3年の開発期間を経た安定版だ。しかし、2025年にTextualize社は事業を終了した。McGuganは自身のブログで、会社としては終わったがOSSプロジェクトとしては健全に継続していると述べている。

Textualの物語は、第17回で語ったexa→ezaの物語と通底する。技術的に優れたOSSプロジェクトの持続可能性は、企業の存続とは別の問題だ。だがTextualの場合、作者自身がプロジェクトの継続にコミットしている点で、ezaのコミュニティフォークとはまた異なるパターンを示している。

### Ratatui――Rustの型安全性をTUIに

2016年頃、Florian Dehauがtui-rsをRustのTUIフレームワークとして公開した（crates.ioでの最初のリリースv0.1.2は2016年12月25日）。tui-rsは即時モード（immediate mode）のレンダリングモデルを採用し、Rustの型システムを活かした設計で多くのTUIアプリケーションの基盤となった。

だが、2023年にDehauの活動が停滞し、プルリクエストやイシューへの対応が滞った。Orhun Parmaksizを中心とするコミュニティがフォークを立ち上げ、Ratatuiとして開発を継続した。2023年7月8日、Dehau本人がtui-rsリポジトリをアーカイブし、Ratatuiが公式の後継となった。

これは、第17回で語ったexa→ezaのフォークパターンと完全に同じ構造だ。OSSプロジェクトのメンテナが離脱した場合、コミュニティがフォークして開発を継続する。Rustエコシステムでは、このパターンが繰り返し観察される。

Ratatuiの設計は、BubbleteaやTextualとは異なるアプローチを取る。Ratatuiは「フレームワーク」よりも「ライブラリ」に近い。Elm Architectureのような特定のアーキテクチャを強制せず、ウィジェット（テーブル、リスト、チャート、ゲージなど）とレイアウトの仕組みを提供する。アプリケーションのイベントループやステート管理は、開発者が自由に設計する。

```
モダンTUIフレームワークの設計比較:

  Bubbletea (Go, 2020年)
    アーキテクチャ: Elm Architecture (Model-Update-View)
    スタイリング: Lipgloss (プログラマティック)
    配布: シングルバイナリ
    特徴: SSH越し配信 (Wish), 宣言的UI

  Ink (Node.js, 2017年)
    アーキテクチャ: React コンポーネントモデル
    スタイリング: Yoga Flexbox
    配布: npm パッケージ (Node.js必要)
    特徴: JSX構文, Web開発者の参入障壁が低い

  Textual (Python, 2021年)
    アーキテクチャ: ウィジェットベース + CSSライクレイアウト
    スタイリング: Textual CSS
    配布: pip パッケージ (Python必要)
    特徴: CSSによるロジック/レイアウト分離

  Ratatui (Rust, 2023年, tui-rsの後継)
    アーキテクチャ: 即時モードレンダリング (非強制)
    スタイリング: プログラマティック
    配布: シングルバイナリ
    特徴: 型安全性, ライブラリ的設計, 高パフォーマンス
```

四つのフレームワークは、それぞれ異なる言語コミュニティの「文化」を反映している。Goの実用主義がBubbletea、JavaScriptのReact文化がInk、Pythonの「美しいコード」志向がTextual、Rustの「ゼロコスト抽象化」がRatatuiに表れている。TUIという同じ目標に向かいながら、アプローチが異なるのは、まさに各言語エコシステムの設計哲学の違いだ。

---

## 4. TUIの構造的優位性――CLIでもGUIでもない「第三のパラダイム」

### 「ちょうどよさ」の正体

lazygit、htop、k9s――これらのTUIアプリケーションに共通するのは、CLIの「組み合わせ可能性」とGUIの「発見可能性」の間にある「ちょうどよさ」だ。だが、「ちょうどよい」とは具体的に何を意味するのか。

第11回で語った認知モデルの枠組みで考える。GUIは「再認（recognition）」に依存する。メニューを見れば何ができるかがわかる。CLIは「想起（recall）」に依存する。コマンド名とオプションを記憶から呼び出す必要がある。

TUIは、この二つの中間に位置する。lazygitを例に取ると、画面の各パネルに情報が視覚的に表示されている（再認）。だが、操作はキーボードショートカットで行う（想起）。ただし、画面下部にキーバインドのヒントが常に表示されているため、すべてを記憶する必要はない（再認による想起の補助）。

```
認知モデルから見たインターフェースの位置づけ:

  CLI (純粋なコマンドライン)
    [想起 ████████████████████ 再認]
    → コマンド、オプション、パイプラインをすべて記憶から呼び出す
    → 組み合わせ可能性は最大。発見可能性は最小

  TUI (テキストベースUI)
    [想起 ██████████ 再認 ██████████]
    → 情報は視覚的に表示。操作はキーボード
    → ヒントやステータスバーが想起を補助
    → 組み合わせ可能性は中程度。発見可能性も中程度

  GUI (グラフィカルUI)
    [想起 ████ 再認 ████████████████]
    → メニュー、ボタン、アイコンで操作を提示
    → 組み合わせ可能性は最小。発見可能性は最大
```

だが、TUIの「ちょうどよさ」は認知モデルだけでは説明しきれない。構造的な優位性がある。

### SSH越しの透過的アクセス

TUIの構造的優位の一つ目は、SSH越しの透過的アクセスだ。

GUIアプリケーションをリモートサーバで実行するには、X11フォワーディング、VNC、RDPといったプロトコルが必要だ。これらはいずれも、帯域とレイテンシに敏感だ。第16回で語ったように、テキストストリームはGUIプロトコルに比べて圧倒的に帯域効率が良い。

TUIアプリケーションはターミナルの中で動く。SSHセッションの中で動く。追加のプロトコルは不要だ。lazygitをリモートサーバのGitリポジトリで実行する場合、`ssh server 'lazygit'`で足りる。

Charm社のWishフレームワークは、この特性をさらに推し進めた。WishはSSHサーバとBubbleteaを統合し、SSHで接続するだけでTUIアプリケーションにアクセスできる環境を提供する。各SSHセッションが独自のBubbleteaプログラムを持ち、pty（疑似端末）の入出力が接続される。ウィンドウサイズの変更にも対応する。

この設計から生まれたのがSoft Serve――SSHでアクセスするセルフホスト型Gitサーバだ。`ssh git.example.com`と打つだけで、TUIベースのGitリポジトリブラウザが目の前に現れる。Webブラウザを開く必要はない。

### プロセスの軽量性

二つ目は、プロセスの軽量性だ。

VS Code（Electron）のメモリ使用量は数百MBに達する。GitKrakenも同様だ。lazygitのメモリ使用量は、リポジトリのサイズにもよるが、通常数十MB以下だ。k9sも同様に軽量だ。

この差は、リモートサーバやリソースが限られた環境では決定的だ。コンテナ内、組み込みシステム上、低スペックのVPS上――GUIアプリケーションは動かないが、TUIアプリケーションは動く。

### ターミナルエコシステムとの統合

三つ目は、ターミナルエコシステムとの統合だ。

TUIアプリケーションは、tmux/screenのペインの中で動く。シェルスクリプトから起動できる。パイプラインの一部として（入力を受け取り、結果を出力する形で）動作できるものもある。ターミナルの中に生きるすべてのツールと、自然に共存する。

GUIアプリケーションは、このエコシステムの外にいる。VS CodeはGitの操作を統合しているが、それはVS Codeの「中」でのみ有効だ。lazygitはtmuxの1ペインで動き、隣のペインでvimが動き、別のペインでテストが走る。すべてがターミナルという統一的な環境の中に収まる。

### TUIの限界

公平を期すために、TUIの限界も述べる。

第一に、表現力の制約だ。セル単位のレイアウト、限られた色空間（True Colorでも24ビット）、固定幅フォント。画像の表示は、kittyプロトコルやSixelなどの拡張に依存し、すべてのターミナルエミュレータでサポートされているわけではない。複雑なグラフやチャートの表示には限界がある。

第二に、マウス操作の不完全性だ。TUIはマウスイベントを処理できるが、GUIほどの精緻さはない。ドラッグ&ドロップ、ホバー効果、右クリックメニューといったGUIの標準的な操作パターンは、TUIでは制限される。

第三に、テキスト入力の制約だ。日本語のようなIME（Input Method Editor）を必要とする言語の入力は、TUIでは問題が生じる場合がある。ターミナルエミュレータのIMEサポートに依存し、アプリケーション側での制御が困難だ。

これらの制約は、TUIが「すべてのユースケースでGUIを置き換える」ものではないことを示している。TUIが適しているのは、テキスト中心のデータを扱い、キーボード主体の操作が自然で、リモートアクセスや軽量性が重要な場面だ。Git操作、プロセス監視、Kubernetes管理、ログ閲覧――これらのタスクは、TUIの「ちょうどよさ」が最大限に発揮される領域である。

---

## 5. ハンズオン：モダンTUIを体験する

### 環境構築

```bash
# Docker環境で実行（ubuntu:24.04ベース）
docker run -it --rm ubuntu:24.04 bash
```

### 演習1：ncurses――古典的TUIの基礎を体験する

```bash
apt-get update && apt-get install -y libncurses-dev gcc

echo "=== 演習1: ncursesによる古典的TUI ==="
echo ""

# ncursesを使った最小のTUIプログラム
cat > /tmp/hello_tui.c << 'CCODE'
#include <ncurses.h>
#include <string.h>

int main() {
    initscr();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    start_color();

    init_pair(1, COLOR_GREEN, COLOR_BLACK);
    init_pair(2, COLOR_YELLOW, COLOR_BLACK);

    int row, col;
    getmaxyx(stdscr, row, col);

    const char *title = "ncurses TUI Demo";
    const char *msg = "Use arrow keys to move the cursor. Press 'q' to quit.";

    attron(A_BOLD | COLOR_PAIR(1));
    mvprintw(1, (col - strlen(title)) / 2, "%s", title);
    attroff(A_BOLD | COLOR_PAIR(1));

    attron(COLOR_PAIR(2));
    mvprintw(3, (col - strlen(msg)) / 2, "%s", msg);
    attroff(COLOR_PAIR(2));

    /* Draw a box */
    int box_y = 5, box_x = 10;
    int box_h = 10, box_w = col - 20;
    for (int i = box_x; i < box_x + box_w; i++) {
        mvaddch(box_y, i, '-');
        mvaddch(box_y + box_h, i, '-');
    }
    for (int i = box_y; i <= box_y + box_h; i++) {
        mvaddch(i, box_x, '|');
        mvaddch(i, box_x + box_w - 1, '|');
    }

    int cy = box_y + box_h / 2;
    int cx = box_x + box_w / 2;

    while (1) {
        move(cy, cx);
        refresh();
        int ch = getch();
        /* Erase old position */
        mvaddch(cy, cx, ' ');
        switch (ch) {
            case KEY_UP:    if (cy > box_y + 1) cy--; break;
            case KEY_DOWN:  if (cy < box_y + box_h - 1) cy++; break;
            case KEY_LEFT:  if (cx > box_x + 1) cx--; break;
            case KEY_RIGHT: if (cx < box_x + box_w - 2) cx++; break;
            case 'q': goto done;
        }
        mvaddch(cy, cx, '@');
    }
done:
    endwin();
    return 0;
}
CCODE

gcc -o /tmp/hello_tui /tmp/hello_tui.c -lncurses

echo "ncursesプログラムをコンパイルしました。"
echo "実行: /tmp/hello_tui"
echo ""
echo "→ ncursesでは、initscr()で端末を初期化し、mvprintw()で"
echo "  特定の座標に文字を描画し、getch()で入力を待つ。"
echo "  すべてが命令的（imperative）だ。"
echo "  プログラマが「どこに何を描画するか」を完全に管理する。"
echo ""
echo "  このアプローチは強力だが、複雑なUIでは状態管理が困難になる。"
echo "  モダンTUIフレームワークは、この問題を宣言的設計で解決した。"
```

### 演習2：Bubbleteaの設計パターンを理解する

```bash
apt-get install -y golang-go git

echo ""
echo "=== 演習2: Bubbleteaのアーキテクチャ ==="
echo ""

mkdir -p /tmp/bubbletea-demo
cd /tmp/bubbletea-demo

cat > main.go << 'GOCODE'
package main

import (
 "fmt"
 "os"

 tea "github.com/charmbracelet/bubbletea"
)

// Model: アプリケーションの状態
type model struct {
 items    []string
 cursor   int
 selected map[int]struct{}
}

func initialModel() model {
 return model{
  items: []string{
   "ncurses  (1993, C,      imperative)",
   "Ink      (2017, JS,     React model)",
   "Bubbletea(2020, Go,     Elm Architecture)",
   "Textual  (2021, Python, CSS-like)",
   "Ratatui  (2023, Rust,   immediate mode)",
  },
  selected: make(map[int]struct{}),
 }
}

// Init: 初期コマンド
func (m model) Init() tea.Cmd {
 return nil
}

// Update: イベントに応じて状態を更新
func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
 switch msg := msg.(type) {
 case tea.KeyMsg:
  switch msg.String() {
  case "ctrl+c", "q":
   return m, tea.Quit
  case "up", "k":
   if m.cursor > 0 {
    m.cursor--
   }
  case "down", "j":
   if m.cursor < len(m.items)-1 {
    m.cursor++
   }
  case " ", "enter":
   if _, ok := m.selected[m.cursor]; ok {
    delete(m.selected, m.cursor)
   } else {
    m.selected[m.cursor] = struct{}{}
   }
  }
 }
 return m, nil
}

// View: 状態から画面を生成
func (m model) View() string {
 s := "\n  TUI Frameworks - Select your favorites:\n\n"

 for i, item := range m.items {
  cursor := "  "
  if m.cursor == i {
   cursor = "> "
  }
  checked := "[ ]"
  if _, ok := m.selected[i]; ok {
   checked = "[x]"
  }
  s += fmt.Sprintf("  %s%s %s\n", cursor, checked, item)
 }

 s += "\n  j/k: move  space: select  q: quit\n\n"

 if len(m.selected) > 0 {
  s += fmt.Sprintf("  Selected: %d item(s)\n", len(m.selected))
 }

 return s
}

func main() {
 p := tea.NewProgram(initialModel())
 if _, err := p.Run(); err != nil {
  fmt.Printf("Error: %v\n", err)
  os.Exit(1)
 }
}
GOCODE

go mod init bubbletea-demo
go mod tidy

echo "Bubbleteaデモをビルド中..."
go build -o /tmp/bubbletea-demo/demo .

echo ""
echo "ビルド完了。実行: /tmp/bubbletea-demo/demo"
echo ""
echo "→ Bubbleteaのプログラムは三つの関数で構成される:"
echo "  - Init(): 初期化コマンドを返す"
echo "  - Update(msg): メッセージを受けて状態を更新する"
echo "  - View(): 現在の状態から画面全体を文字列として返す"
echo ""
echo "  ncursesとの最大の違いは「View()が毎回画面全体を返す」ことだ。"
echo "  画面のどの部分を更新するかはフレームワークが判断する。"
echo "  プログラマは「状態が正しいか」だけを気にすればよい。"

cd /
```

### 演習3：TUIアプリケーションの実用例を体験する

```bash
echo ""
echo "=== 演習3: 実用TUIアプリケーションの体験 ==="
echo ""

# htop のインストールと体験
apt-get install -y htop

echo "--- htop: プロセス監視TUI ---"
echo ""
echo "実行: htop"
echo ""
echo "  htop（2004年、Hisham Muhammad）は、topの代替として設計された"
echo "  TUIアプリケーションの古典的な成功例だ。"
echo "  - CPU/メモリ使用率をバーグラフで表示（視覚的フィードバック）"
echo "  - カーソルキーでプロセスを選択（対話的操作）"
echo "  - F9でシグナル送信、F6でソート変更（キーバインド操作）"
echo "  - 画面下部にキーヒントを常時表示（発見可能性の支援）"
echo ""
echo "  topのCLI的な出力（テキストが流れるだけ）と比較すると、"
echo "  htopは「同じ情報を、構造化された視覚的レイアウトで提供する」"
echo "  TUIの価値を端的に示している。"
echo ""

# Midnight Commander のインストール
apt-get install -y mc

echo "--- mc (Midnight Commander): ファイルマネージャTUI ---"
echo ""
echo "実行: mc"
echo ""
echo "  Midnight Commander（1994年、Miguel de Icaza）は、"
echo "  Norton Commander（1986年）の設計を継承したTUIファイルマネージャだ。"
echo "  - 二画面パネルでファイルを視覚的に比較"
echo "  - F5:コピー、F6:移動、F7:ディレクトリ作成、F8:削除"
echo "  - F9:メニュー、F10:終了"
echo "  - 内蔵エディタ（F4）と内蔵ビューア（F3）"
echo ""
echo "  1990年代のTUI設計パターンを、今日でも体験できる貴重なツールだ。"
echo ""

echo "--- ncursesとモダンTUIの比較まとめ ---"
echo ""
echo "  ncurses時代のTUI:"
echo "    - Cで直接画面を操作（命令的）"
echo "    - 端末差異の吸収が主要な価値"
echo "    - 開発者の負担が大きい（座標管理、再描画制御）"
echo ""
echo "  モダンTUIフレームワーク:"
echo "    - 宣言的UIパターン（Elm Architecture, React, CSS）"
echo "    - 状態管理の自動化（差分計算、効率的再描画）"
echo "    - Web開発の知識が転用可能"
echo "    - SSH越しの配信（Wish）"
echo ""
echo "  共通するTUIの構造的優位:"
echo "    - SSHで透過的にアクセス可能"
echo "    - GUIより圧倒的に軽量"
echo "    - tmux/screenと自然に共存"
echo "    - キーボード主体の高速操作"
```

ハンズオンの自動セットアップスクリプトは `handson/command-line/18-tui-renaissance/setup.sh` を参照してほしい。

---

## 6. まとめと次回予告

### この回の要点

第一に、TUI（Text-based User Interface）は2020年代に突然現れたものではない。Norton Commander（1986年）、Midnight Commander（1994年）、mutt（1995年）、htop（2004年）――ncursesを基盤とするTUIアプリケーションは、数十年にわたって存在し続けていた。ただし、2000年代にGUIとWebアプリケーションの普及により衰退期を迎えた。

第二に、TUIの「復権」を可能にしたのは、モダンTUIフレームワークの登場だ。Bubbletea（2020年、Go、Elm Architecture）、Ink（2017年、Node.js、React的コンポーネントモデル）、Textual（2021年、Python、CSSライクスタイリング）、Ratatui（2023年、Rust、即時モードレンダリング）――これらはWeb開発で磨かれた設計パターンをTUIに持ち込み、開発体験を根本的に改善した。

第三に、ncursesの命令的アプローチ（「どこに何を描画するか」をプログラマが管理）から、BubbleteaのElm Architecture的アプローチ（「状態から画面全体を生成」をフレームワークが管理）への転換が、TUI開発の参入障壁を大幅に下げた。状態管理の一元化と差分描画の自動化が、この転換の技術的核心だ。

第四に、TUIの構造的優位性は三つある。（1）SSH越しの透過的アクセス、（2）プロセスの軽量性、（3）ターミナルエコシステム（tmux/screen、シェルスクリプト）との自然な統合。これらは、GUIでは代替困難な特性だ。

第五に、TUIは万能ではない。表現力の制約（セル単位レイアウト、限定的な色空間）、マウス操作の不完全性、IME対応の困難さという限界がある。TUIが適しているのは、テキスト中心のデータを扱い、キーボード主体の操作が自然な場面だ。

### 冒頭の問いへの暫定回答

CUIとGUIの間に、なぜ「第三の領域」が再び注目されているのか。

答えは、CLIとGUIの間に「構造的な隙間」が存在し、その隙間を埋めるための技術的基盤がようやく整ったからだ。

CLIは組み合わせ可能で、スクリプト化でき、SSH越しに動作する。だが、視覚的なフィードバックに欠け、発見可能性が低い。GUIは視覚的で発見しやすい。だが、リモートアクセスに帯域を要求し、ターミナルエコシステムと統合しにくく、重い。

TUIは、この二つの間にある「ちょうどよい」領域を占める。テキストベースだからSSHで動く。視覚的なレイアウトだから発見可能性がある。キーボード主体だから高速に操作できる。ターミナルの中にいるから、他のCLIツールと共存する。

ncurses時代にもTUIは存在したが、その開発は困難だった。C言語で座標を手動管理し、端末差異に悩まされ、再描画を最適化する。この負担が、TUIアプリケーションの数を制限していた。Bubbletea、Ink、Textual、Ratatuiは、この負担を取り除いた。Elm Architecture、Reactコンポーネント、CSSレイアウト――Web開発で20年かけて磨かれた設計パターンが、TUIの世界に流入した。

TUIは「GUIになりきれなかったCLI」ではない。テキストベースの操作性とビジュアルフィードバックを両立させた、独自のパラダイムだ。その復権は、テキストストリームという抽象が持つ普遍性の、また一つの証明である。

### 次回予告

次回、第19回「モダンターミナルエミュレータの競争――GPU描画とプロトコル拡張」では、TUIアプリケーションが動作する「基盤」そのもの――ターミナルエミュレータの進化を追う。

xtermからiTerm2、AlacrittyからGhosttyまで。なぜターミナルエミュレータに「GPU描画」が必要なのか。kittyプロトコルとは何か。Sixel画像プロトコルの限界とは。ターミナルのプロトコルが40年分の技術的負債を抱えている現実と、それを解消しようとする競争の行方を語る。

---

## 参考文献

- Wikipedia, "Norton Commander", <https://en.wikipedia.org/wiki/Norton_Commander>
- Wikipedia, "Midnight Commander", <https://en.wikipedia.org/wiki/Midnight_Commander>
- Wikipedia, "Mutt (email client)", <https://en.wikipedia.org/wiki/Mutt_(email_client)>
- NCURSES -- New Curses, invisible-island.net, <https://invisible-island.net/ncurses/>
- Wikipedia, "ncurses", <https://en.wikipedia.org/wiki/Ncurses>
- GitHub, charmbracelet/bubbletea, <https://github.com/charmbracelet/bubbletea>
- Charm, "The Next Generation of the Command Line", <https://charm.land/blog/the-next-generation/>
- TechCrunch, "Charm offensive: Google's Gradient backs this startup to bring more pizzazz to the command line", 2023, <https://techcrunch.com/2023/11/02/charm-offensive-googles-gradient-backs-this-startup-to-bring-more-pizzazz-to-the-command-line/>
- GitHub, vadimdemedes/ink, <https://github.com/vadimdemedes/ink>
- Vadim Demedes, "Building rich command-line interfaces with Ink and React", <https://vadimdemedes.com/posts/building-rich-command-line-interfaces-with-ink-and-react>
- Textual, "The future of Textualize", 2025, <https://textual.textualize.io/blog/2025/05/07/the-future-of-textualize/>
- Textual -- Home, <https://textual.textualize.io/>
- GitHub, ratatui/ratatui, <https://github.com/ratatui/ratatui>
- Orhun Parmaksiz, "From tui-rs to Ratatui: 6 Months of Cooking Up Rust TUIs", 2023, <https://blog.orhun.dev/ratatui-0-23-0/>
- Jesse Duffield, "Lazygit Turns 5: Musings on Git, TUIs, and Open Source", <https://jesseduffield.com/Lazygit-5-Years-On/>
- GitHub, jesseduffield/lazygit, <https://github.com/jesseduffield/lazygit>
- GitHub, charmbracelet/wish, <https://github.com/charmbracelet/wish>
- htop -- an interactive process viewer, <https://htop.dev/>
- GitHub, derailed/k9s, <https://github.com/derailed/k9s>
- Evan Czaplicki, "The Elm Architecture", <https://guide.elm-lang.org/architecture/>
