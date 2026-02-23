# Blueprints -- 執筆指示書

このディレクトリには、各連載シリーズの執筆指示書（blueprint）を格納する。

## 執筆指示書とは

執筆指示書は、AIに対する「著者の分身化マニュアル」である。著者のプロフィール、技術的バックグラウンド、文体、連載の設計思想、各回の構成を網羅的に定義する。

AIはこの指示書を参照することで、著者が書いたとしか思えない文章を生成する。指示書の品質が出力の品質を決める。

## ファイル一覧

| #  | ファイル                                           | シリーズ                       | 状態     |
| -- | -------------------------------------------------- | ------------------------------ | -------- |
| 1  | [version-control.md](./version-control.md)         | git ありきの世界に警鐘を鳴らす | 連載完結 |
| 2  | [command-line.md](./command-line.md)               | ターミナルは遺物か             | 設計完了 |
| 3  | [shell-history.md](./shell-history.md)             | bash ありきの世界を疑え        | 設計完了 |
| 4  | [database-history.md](./database-history.md)       | データベースの地層             | 設計完了 |
| 5  | [unix-philosophy.md](./unix-philosophy.md)         | UNIXという思想                 | 設計完了 |
| 6  | [cloud-history.md](./cloud-history.md)             | クラウドの考古学               | 設計完了 |
| 7  | [web-framework.md](./web-framework.md)             | フレームワークという幻想       | 設計完了 |
| 8  | [http-protocol.md](./http-protocol.md)             | HTTPを知らずにWebを語るな      | 設計完了 |
| 9  | [text-editor.md](./text-editor.md)                 | テキストエディタ戦争史         | 設計完了 |
| 10 | [container.md](./container.md)                     | コンテナという箱の中身         | 設計完了 |
| 11 | [package-management.md](./package-management.md)   | パッケージという名の依存地獄   | 設計完了 |
| 12 | [software-testing.md](./software-testing.md)       | テストを書かなかった時代       | 設計完了 |
| 13 | [character-encoding.md](./character-encoding.md)   | 文字コードの呪い               | 設計完了 |
| 14 | [authentication.md](./authentication.md)           | 認証の肖像                     | 設計完了 |
| 15 | [networking.md](./networking.md)                   | ネットワークの地図             | 設計完了 |
| 16 | [configuration.md](./configuration.md)             | 設定という名の哲学             | 設計完了 |
| 17 | [observability.md](./observability.md)             | ログという証言                 | 設計完了 |
| 18 | [build-system.md](./build-system.md)               | ビルドの呪縛                   | 設計完了 |
| 19 | [type-system.md](./type-system.md)                 | 型という制約の美学             | 設計完了 |
| 20 | [concurrency.md](./concurrency.md)                 | 並行処理の地雷原               | 設計完了 |
| 21 | [performance-history.md](./performance-history.md) | 計測せよ、推測するな           | 設計完了 |
| -- | [_template.md](./_template.md)                     | 新シリーズ作成用テンプレート   | --       |

## 使い方

1. 新しいシリーズを始めるときは `_template.md` をコピーして編集する
2. AI（Claude / ChatGPT / Gemini）に指示書全文を投入する
3. 具体的な活用方法は [guides/](../guides/) を参照
