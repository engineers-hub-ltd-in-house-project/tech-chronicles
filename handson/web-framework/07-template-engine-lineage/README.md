# 第7回ハンズオン：テンプレートエンジン3種を同時に動かす

## 概要

ERB（Ruby）、Jinja2（Python）、Handlebars（Node.js）の3つのテンプレートエンジンで、まったく同じデータから HTML を生成する。出力を `diff` で比較しながら、設計判断（ロジックフル/ロジックレス、自動エスケープの有無、コンパイル戦略）の違いを実機で体感する。

## 学べること

- ERB の `<%= %>` `<% %>` 構文と「Ruby の表現力をそのまま使える」設計
- Jinja2 の `{{ }}` `{% %}` 構文、`autoescape`、フィルタチェーン（`| selectattr`、`| rejectattr`）
- Handlebars の `{{ }}` `{{# }}` 構文、ヘルパー登録、自動エスケープと `{{{ }}}` の二重カッコ/三重カッコの使い分け
- 自動エスケープの有無が現実の HTML 出力にどう現れるか（`<urgent>` vs `&lt;urgent&gt;`）
- ロジックフル vs ロジック制限——同じ集計を3つのエンジンでどう書くか

## 動作環境

- Linux（Docker `ubuntu:24.04` 推奨。WSL2 / macOS / 任意の Linux でも可）
- Ruby 3.0+（ERB は標準ライブラリ。`ruby-erb` パッケージ含む）
- Python 3.10+（`python3-jinja2` または `pip install Jinja2`）
- Node.js 20+ / npm（`handlebars` パッケージ）
- diffutils（`diff` コマンド）

## 演習一覧

| 演習  | 内容                                                         | 所要時間目安 |
| ----- | ------------------------------------------------------------ | ------------ |
| 演習1 | ERB で `data.json` から HTML を生成し、出力を観察            | 5分          |
| 演習2 | Jinja2 で同じデータをレンダリング、`autoescape` の挙動を確認 | 5分          |
| 演習3 | Handlebars でヘルパー関数を登録し、ロジック制限を体感        | 10分         |
| 演習4 | 3つの出力を `diff` で比較、`<urgent>` のエスケープ差異を確認 | 5分          |
| 演習5 | 「優先度 high かつ未完了」の件数計算を3エンジンで書き比べる  | 10分         |

## セットアップ

```bash
./setup.sh
```

このスクリプトは作業ディレクトリ `~/web-framework-handson-07` 配下に共通データ `data.json` と各エンジンのテンプレート/レンダラーを配置し、すべての演習を順次実行して出力を観察する。

最後に `diff` で3つの出力を比較し、自動エスケープの有無による差異を表示する。

## 動作確認の見どころ

- 演習1：ERB の `<%= task[:title] %>` の出力に、`<urgent>` がそのまま `<urgent>` として残っていることを確認（素の ERB は自動エスケープしない）
- 演習2：Jinja2 の出力で `<urgent>` が `&lt;urgent&gt;` に変換されていることを確認（`autoescape=select_autoescape(['html'])` の効果）
- 演習3：Handlebars でも `{{title}}` の出力が自動エスケープされ、ヘルパー `{{cssState done}}` が JS 側で定義されたロジックを呼び出している構造を確認
- 演習5：ERB と Jinja2 はテンプレートの中で集計が完結する。Handlebars は JavaScript 側に `countHighPending` ヘルパーを登録する必要がある——ロジック境界の差を体感

## ファイル構成

```text
~/web-framework-handson-07/
├── data.json              共通データ（3エンジンとも参照）
├── template.erb           演習1: ERB テンプレート
├── render_erb.rb          演習1: Ruby レンダラー
├── template.j2            演習2: Jinja2 テンプレート
├── render_jinja.py        演習2: Python レンダラー
├── template.hbs           演習3: Handlebars テンプレート
├── render_hbs.js          演習3: Node.js レンダラー
├── package.json
├── node_modules/
└── out_*.html             各エンジンの出力結果
```

## トラブルシュート

- Ruby が見つからない: `apt-get install -y ruby ruby-erb`（Ubuntu）または `brew install ruby`（macOS）
- Jinja2 が見つからない: `pip3 install Jinja2` または `apt-get install -y python3-jinja2`
- Node.js が見つからない: `apt-get install -y nodejs npm`
- ファイル書き込み権限エラー: `~/web-framework-handson-07` の所有者を確認

## 後片付け

```bash
rm -rf ~/web-framework-handson-07
```

## ライセンス

MIT
