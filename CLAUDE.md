# tech-chronicles プロジェクト指示書

## プロジェクト概要

バージョン管理の歴史を語る全24回の技術史連載「git ありきの世界に警鐘を鳴らす」の執筆基盤。
著者ペルソナ: 佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead、52歳、エンジニア歴24年超）。
ライセンス: CC BY-SA 4.0（記事）、MIT（コード/ハンズオン）。

## ディレクトリ構造と命名規則

```
blueprints/version-control.md       -- 執筆指示書（文体・構成・全24回設計）
series/version-control/ja/{NN}-{slug}.md  -- 本文
research/version-control/factcheck-{NN}.md -- ファクトチェック記録
handson/version-control/{NN}-{slug}/      -- ハンズオン（README.md + setup.sh）
guides/                             -- AI活用ガイド
```

ファイル名の `{NN}` は2桁ゼロ埋め連番（01, 02, ...）。`{slug}` は英語ケバブケース。

## 執筆ワークフロー（必須手順）

記事を執筆する際は、以下の順序を厳守すること。

### Step 1: ファクトチェック（WebSearch必須）

- `blueprints/version-control.md` の該当回仕様を読み、調査項目を洗い出す
- **歴史的事実・統計データは必ずWebSearchで一次ソースを検証する**
- モデルの知識のみでの事実記述は禁止。検証できなかった事実は「未検証」と明記する
- 各項目について「結論」「一次ソース」「URL」「記事での表現」を記録する
- 出力先: `research/version-control/factcheck-{NN}.md`

### Step 2: 本文執筆

- `blueprints/version-control.md` の文体・構成ルールに従う
- 前回記事を読み、重複回避を確認する
- 5部構成テンプレート:
  1. 導入 -- 問いの提示（1,000-2,000字）
  2. 歴史的背景（3,000-6,000字）
  3. 技術論（3,000-6,000字）
  4. ハンズオン（2,000-4,000字）
  5. まとめと次回予告（500-1,500字）
- 合計 10,000-25,000字（図解・コードブロックは文字数に算入しない。品質・わかりやすさ優先）
- 出力先: `series/version-control/ja/{NN}-{slug}.md`

### Step 3: ハンズオン資材

- `handson/version-control/{NN}-{slug}/README.md` -- 概要、学べること、動作環境
- `handson/version-control/{NN}-{slug}/setup.sh` -- 自動セットアップスクリプト
- setup.sh の構造: `set -euo pipefail`, `WORKDIR` 変数, セクション分けのecho（Episode 1を踏襲）

### Step 4: README更新

- `series/version-control/ja/README.md` の目次テーブルで該当回のステータスを「公開済」に変更し、リンクを追加

### Step 5: 品質チェック

- `npm run check`（markdownlint + dprint）を実行し、エラーがあれば修正する

## 文体ルール

詳細は `blueprints/version-control.md` を参照。要点のみ以下に記載。

- 一人称「私」、である調
- 技術的に正確、一次ソース明記
- 歴史的事実は年号・人名・バージョン番号を正確に記述
- 著者の体験は「私は」で開始、歴史的事実は客観的に記述
- 読者に問いかけ、考えさせる
- 技術の功罪を両面から語る

### 禁止事項

- 「〜ですね」「〜しましょう」など過度にカジュアルなブログ調
- 「〜と言われています」「一般的に〜」など主語を曖昧にする表現
- 「いかがでしたか？」で締める
- 箇条書きの羅列で終わらせる（必ず散文で語る）
- git/GitHubの礼賛、懐古趣味（「昔はよかった」）

## ファクトチェック記録フォーマット

```markdown
## N. 調査項目名

- **結論**: 検証済みの事実
- **一次ソース**: 著者名, タイトル, 出版年
- **URL**: <https://...>
- **注意事項**: 補足情報
- **記事での表現**: 記事中での記述案
```

## ツールチェーン

| コマンド               | 説明                                 |
| ---------------------- | ------------------------------------ |
| `npm run lint`         | markdownlint-cli2 による構文チェック |
| `npm run lint:fix`     | 自動修正                             |
| `npm run format`       | dprint によるフォーマット            |
| `npm run format:check` | フォーマットチェック（修正なし）     |
| `npm run check`        | lint + format:check の両方実行       |

pre-commitフック（lefthook）でコミット時に自動チェックが実行される。

## 参照ファイル

- 執筆指示書（全24回設計・文体・著者ペルソナ）: `blueprints/version-control.md`
- Claude向けガイド: `guides/ai-guide-claude.md`
- ワークフロー全体像: `guides/workflow-overview.md`
- 既存記事・ファクトチェック: `series/` と `research/` 配下
