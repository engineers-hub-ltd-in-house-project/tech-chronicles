#!/bin/bash
# =============================================================================
# 第18回ハンズオン：TUIの復権――Charm, Bubbletea, Ink, Textual
# セットアップスクリプト
#
# 使い方:
#   bash setup.sh
#
# 必要なツール: gcc, libncurses-dev, golang-go, htop, mc
# 推奨環境: Docker (ubuntu:24.04)
# =============================================================================

set -euo pipefail

WORKDIR="${HOME}/command-line-handson-18"

echo "=== 第18回ハンズオン：TUIの復権 ==="
echo ""

# 作業ディレクトリの作成
if [ -d "${WORKDIR}" ]; then
  echo "既存の作業ディレクトリを削除します: ${WORKDIR}"
  rm -rf "${WORKDIR}"
fi

mkdir -p "${WORKDIR}"

# --- 演習1: ncursesによる古典的TUI ---
echo "[演習1] ncursesによる古典的TUIプログラム"
echo ""

apt-get update -qq && apt-get install -y -qq libncurses-dev gcc > /dev/null 2>&1
echo "  ncurses開発パッケージをインストールしました。"

cat > "${WORKDIR}/hello_tui.c" << 'CCODE'
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
    const char *msg = "Use arrow keys to move '@'. Press 'q' to quit.";

    attron(A_BOLD | COLOR_PAIR(1));
    mvprintw(1, (col - (int)strlen(title)) / 2, "%s", title);
    attroff(A_BOLD | COLOR_PAIR(1));

    attron(COLOR_PAIR(2));
    mvprintw(3, (col - (int)strlen(msg)) / 2, "%s", msg);
    attroff(COLOR_PAIR(2));

    /* Draw a box */
    int box_y = 5, box_x = 10;
    int box_h = 10, box_w = col - 20;
    if (box_w < 20) box_w = 20;
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
    mvaddch(cy, cx, '@');

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

gcc -o "${WORKDIR}/hello_tui" "${WORKDIR}/hello_tui.c" -lncurses

echo "  ncursesプログラムをコンパイルしました。"
echo "  実行: ${WORKDIR}/hello_tui"
echo ""
echo "  → ncursesでは、initscr()で端末を初期化し、mvprintw()で"
echo "    特定の座標に文字を描画し、getch()で入力を待つ。"
echo "    すべてが命令的（imperative）だ。"
echo "    プログラマが「どこに何を描画するか」を完全に管理する。"
echo ""

# --- 演習2: Bubbleteaのリストアプリ ---
echo "---"
echo ""
echo "[演習2] Bubbleteaによるモダン TUI"
echo ""

if command -v go > /dev/null 2>&1; then
  echo "  Go が検出されました。Bubbleteaデモをビルドします。"

  mkdir -p "${WORKDIR}/bubbletea-demo"

  cat > "${WORKDIR}/bubbletea-demo/main.go" << 'GOCODE'
package main

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
)

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

func (m model) Init() tea.Cmd {
	return nil
}

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

  cd "${WORKDIR}/bubbletea-demo"
  go mod init bubbletea-demo > /dev/null 2>&1
  go mod tidy > /dev/null 2>&1
  go build -o "${WORKDIR}/bubbletea-demo/demo" . 2>&1

  echo "  Bubbleteaデモをビルドしました。"
  echo "  実行: ${WORKDIR}/bubbletea-demo/demo"
  echo ""
  echo "  → Bubbleteaのプログラムは三つの関数で構成される:"
  echo "    - Init(): 初期コマンドを返す"
  echo "    - Update(msg): メッセージを受けて状態を更新する"
  echo "    - View(): 現在の状態から画面全体を文字列として返す"
  echo ""
  echo "    ncursesとの最大の違いは「View()が毎回画面全体を返す」ことだ。"
  echo "    画面のどの部分を更新するかはフレームワークが判断する。"

  cd /
else
  echo "  Go がインストールされていません。"
  echo "  演習2をスキップします。"
  echo "  Goのインストール: apt-get install -y golang-go"
fi

echo ""

# --- 演習3: 実用TUIアプリケーション ---
echo "---"
echo ""
echo "[演習3] 実用TUIアプリケーションの体験"
echo ""

apt-get install -y -qq htop mc > /dev/null 2>&1

echo "  htop と mc をインストールしました。"
echo ""
echo "  --- htop: プロセス監視TUI ---"
echo "  実行: htop"
echo ""
echo "  htop（2004年、Hisham Muhammad）は、topの代替として設計された"
echo "  TUIアプリケーションの古典的な成功例だ。"
echo "  - CPU/メモリ使用率をバーグラフで表示"
echo "  - カーソルキーでプロセスを選択"
echo "  - F9でシグナル送信、F6でソート変更"
echo "  - 画面下部にキーヒントを常時表示"
echo ""
echo "  --- mc (Midnight Commander): ファイルマネージャTUI ---"
echo "  実行: mc"
echo ""
echo "  Midnight Commander（1994年、Miguel de Icaza）は、"
echo "  Norton Commander（1986年）を継承したTUIファイルマネージャだ。"
echo "  - F5:コピー、F6:移動、F7:ディレクトリ作成、F8:削除"
echo "  - F3:内蔵ビューア、F4:内蔵エディタ"
echo "  - F9:メニュー、F10:終了"
echo ""

echo "=== セットアップ完了 ==="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "実行可能なプログラム:"
echo "  ${WORKDIR}/hello_tui          -- ncurses TUIデモ"
if [ -f "${WORKDIR}/bubbletea-demo/demo" ]; then
  echo "  ${WORKDIR}/bubbletea-demo/demo -- Bubbletea TUIデモ"
fi
echo "  htop                           -- プロセス監視TUI"
echo "  mc                             -- ファイルマネージャTUI"
echo ""
echo "まとめ:"
echo "  1. ncursesは命令的: プログラマが座標と描画を完全に管理する"
echo "  2. Bubbleteaは宣言的: Model-Update-Viewで状態から画面を生成する"
echo "  3. TUIの価値はCLIの操作性とGUIの視覚性を両立する「ちょうどよさ」"
echo "  4. SSH越しに動作し、tmuxと共存し、軽量に動作する構造的優位"
