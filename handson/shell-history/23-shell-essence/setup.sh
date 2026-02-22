#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/shell-history-handson-23"

echo "============================================================"
echo " 第23回ハンズオン：シェルの本質に立ち返る"
echo " 対話・自動化・システム接点"
echo "============================================================"

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================================
echo ""
echo ">>> 基本パッケージのインストール"
# ============================================================
if command -v apt-get > /dev/null 2>&1; then
  apt-get update -qq && apt-get install -y -qq dash zsh file > /dev/null 2>&1
  echo "基本パッケージのインストール完了"
else
  echo "apt-get が利用できません。ローカル環境で実行中と判断します。"
  echo "dash, zsh が未インストールの場合は手動でインストールしてください。"
fi

# ============================================================
echo ""
echo "============================================================"
echo " 演習1: シェル環境の現状把握"
echo "============================================================"
# ============================================================

echo ""
echo "--- 対話シェル ---"
echo "現在のシェル (SHELL): ${SHELL:-不明}"
echo "実行中のシェル: $(ps -p $$ -o comm= 2>/dev/null || echo '不明')"
echo ""

echo "--- 利用可能なシェル (/etc/shells) ---"
if [ -f /etc/shells ]; then
    grep -v '^#' /etc/shells | grep -v '^$' || true
else
    echo "/etc/shells が見つかりません"
fi
echo ""

echo "--- /bin/sh の実体 ---"
if [ -L /bin/sh ]; then
    echo "/bin/sh -> $(readlink -f /bin/sh)"
else
    echo "/bin/sh はシンボリックリンクではありません"
    file /bin/sh 2>/dev/null || true
fi
echo ""

echo "--- インストール済みシェルのバージョン ---"
for shell in bash zsh fish dash ksh; do
    if command -v "$shell" > /dev/null 2>&1; then
        case "$shell" in
            bash) ver=$("$shell" --version 2>/dev/null | head -1) ;;
            zsh)  ver=$("$shell" --version 2>/dev/null) ;;
            fish) ver=$("$shell" --version 2>/dev/null) ;;
            dash) ver="dash (バージョン番号は非表示)" ;;
            ksh)  ver=$("$shell" --version 2>/dev/null | head -1) ;;
        esac
        echo "  $shell: $ver"
    fi
done

# ============================================================
echo ""
echo "============================================================"
echo " 演習2: 三軸評価ワークシート"
echo "============================================================"
# ============================================================

cat << 'WORKSHEET'

【Layer 1: 対話用シェル】
  Q1. 普段の対話シェルは何ですか？
  Q2. そのシェルを選んだ理由は？
      a) 最初から入っていた  b) 誰かに勧められた
      c) 自分で比較検討した  d) 特に意識していない
  Q3. 以下の対話機能を使っていますか？
      [ ] コマンド補完（Tab）     [ ] ヒストリ検索（Ctrl+R）
      [ ] 構文ハイライト         [ ] 自動サジェスト
      [ ] カスタムプロンプト     [ ] エイリアス/関数

【Layer 2: スクリプト用シェル】
  Q4. shebangに何を書きますか？
      a) #!/bin/bash  b) #!/bin/sh  c) #!/usr/bin/env bash  d) その他
  Q5. bashism を意識していますか？
      a) 意識している  b) 意識していない  c) シェル以外で書く
  Q6. set -euo pipefail を使っていますか？
      a) 常に使う  b) 時々使う  c) 知らない/使わない

【Layer 3: システム/CI用シェル】
  Q7. CI/CDのシェルを意識していますか？
      a) 明示的に指定  b) デフォルトに任せている
  Q8. Dockerfileの RUN 命令で使うシェルを意識していますか？
      a) Alpine系でash/shを意識  b) bash前提  c) Dockerfileを書かない

【読み方】
  - Q2でa/d → シェルを「与えられている」状態
  - Q2でc   → シェルを「選んでいる」状態
  - Q5でb   → Layer 2 が Layer 1 に依存している（要注意）
  - Q7/Q8でb → Layer 3 を見直す機会あり

WORKSHEET

# ============================================================
echo ""
echo "============================================================"
echo " 演習3: bashism の検出と POSIX 準拠化"
echo "============================================================"
# ============================================================

echo ""
echo "--- 3-1: bashism を含むスクリプト ---"

cat > "${WORKDIR}/test_bashism.sh" << 'SCRIPT'
#!/bin/sh
# このスクリプトには bashism が含まれている

# bashism 1: 配列
files=(foo bar baz)
echo "${files[0]}"

# bashism 2: [[ ]] 条件式
name="hello"
if [[ "$name" == "hello" ]]; then
    echo "match"
fi

# bashism 3: ブレース展開
for i in {1..5}; do
    echo "$i"
done
SCRIPT

echo "test_bashism.sh を作成しました。"
echo "#!/bin/sh と宣言しているが、bash固有の機能を使っています。"
echo ""

echo "bash で実行:"
bash "${WORKDIR}/test_bashism.sh" 2>&1 || true
echo ""

echo "dash で実行:"
dash "${WORKDIR}/test_bashism.sh" 2>&1 || true
echo ""

echo "--- 3-2: POSIX 準拠版 ---"

cat > "${WORKDIR}/test_posix.sh" << 'SCRIPT'
#!/bin/sh
# POSIX準拠版: bashism を排除

# 配列の代わりにスペース区切り文字列
files="foo bar baz"
echo "$files" | cut -d' ' -f1

# [[ ]] の代わりに [ ]、== の代わりに =
name="hello"
if [ "$name" = "hello" ]; then
    echo "match"
fi

# ブレース展開の代わりにカウンタ
i=1
while [ "$i" -le 5 ]; do
    echo "$i"
    i=$((i + 1))
done
SCRIPT

echo "test_posix.sh を作成しました（POSIX準拠版）。"
echo ""

echo "bash で実行:"
bash "${WORKDIR}/test_posix.sh" 2>&1
echo ""

echo "dash で実行:"
dash "${WORKDIR}/test_posix.sh" 2>&1
echo ""
echo "教訓: #!/bin/sh と書くなら、dash でも動くように書くべきである。"

# ============================================================
echo ""
echo "============================================================"
echo " 演習4: シェルの起動速度比較"
echo "============================================================"
# ============================================================

echo ""
echo "各シェルを1000回起動して速度を比較します..."
echo ""

for shell in dash bash zsh; do
    if command -v "$shell" > /dev/null 2>&1; then
        start_time=$(date +%s%N 2>/dev/null || echo "0")
        count=0
        while [ "$count" -lt 1000 ]; do
            "$shell" -c "exit" 2>/dev/null
            count=$((count + 1))
        done
        end_time=$(date +%s%N 2>/dev/null || echo "0")
        if [ "$start_time" != "0" ] && [ "$end_time" != "0" ]; then
            elapsed=$(( (end_time - start_time) / 1000000 ))
            echo "  $shell: ${elapsed}ms (1000回起動)"
        else
            echo "  $shell: 計測完了（ナノ秒タイマー非対応）"
        fi
    else
        echo "  $shell: 未インストール"
    fi
done

echo ""
echo "教訓: システムスクリプトでシェルを繰り返し起動する場合、"
echo "      dash の軽量さが積み重なって大きな差になる。"
echo "      Debian/Ubuntu が /bin/sh を dash にした理由がここにある。"

# ============================================================
echo ""
echo "============================================================"
echo " 演習完了"
echo "============================================================"
# ============================================================

echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo "作成されたファイル:"
ls -la "${WORKDIR}/"
echo ""
echo "後片付け: rm -rf ${WORKDIR}"
echo ""
echo "三つの軸で自分のシェル環境を見直してみてください。"
echo "  Layer 1（対話）: 手に馴染むシェルを選ぶ"
echo "  Layer 2（スクリプト）: 可搬性を重視する"
echo "  Layer 3（システム/CI）: 軽量性を重視する"
