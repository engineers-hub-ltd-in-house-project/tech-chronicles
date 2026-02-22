# ファクトチェック記録：第24回「bash ありきの世界を疑え――あなたは何を選ぶか」

## 1. Stack Overflow Developer Survey 2025 における bash/shell 利用率

- **結論**: 2025年調査で Bash/Shell は開発者の約49%が使用。JavaScript（66%）、Pythonに次ぐ広い利用率を維持
- **一次ソース**: Stack Overflow, "2025 Stack Overflow Developer Survey", 2025
- **URL**: <https://survey.stackoverflow.co/2025/>
- **注意事項**: 49,000以上の回答、177カ国、62問、314技術を対象とした大規模調査
- **記事での表現**: 「2025年のStack Overflow Developer Surveyでは、Bash/Shellを使う開発者は約49%に達する」

## 2. Bash 5.3 のリリース（2025年7月）

- **結論**: Bash 5.3 は2025年7月3日にリリース。前バージョン5.2から約3年ぶりのメジャーリリース
- **一次ソース**: Chet Ramey, bash-announce メーリングリスト, 2025年7月
- **URL**: <https://lists.gnu.org/archive/html/bash-announce/2025-07/msg00000.html>
- **注意事項**: 新機能として current execution context でのコマンド置換、GLOBSORT変数、Readline 8.3同梱。C23標準への更新
- **記事での表現**: 「2025年7月、Bash 5.3がリリースされた。前バージョンから3年ぶりのメジャーリリースである」

## 3. fish shell 4.0 の Rust 書き換え完了（2025年2月）

- **結論**: fish 4.0 は2025年2月27日に安定版リリース。C++からRustへの完全書き換え。約2年の開発期間、2,600以上のコミット、200人以上のコントリビューター
- **一次ソース**: fish shell 公式ブログ "Fish 4.0: The Fish Of Theseus"
- **URL**: <https://fishshell.com/blog/rustport/>
- **注意事項**: 元のC++ 57k行がRust 75k行に。ncurses依存を排除。Rust 1.70以上が必要
- **記事での表現**: 「2025年2月、fish 4.0がリリースされた。C++で書かれていた57,000行のコードがRust 75,000行に書き換えられた」

## 4. Nushell の最新バージョン（0.110.0, 2026年1月）

- **結論**: 2026年1月時点で Nushell 0.110.0 がリリース。まだ1.0には到達していないが、活発な開発が続く
- **一次ソース**: Nushell GitHub Releases
- **URL**: <https://github.com/nushell/nushell/releases>
- **注意事項**: 2025年中に0.108.0（10月）、0.109.0（11月）、0.109.1（12月）と頻繁なリリース
- **記事での表現**: 「Nushellは2026年1月時点でバージョン0.110.0に達し、安定版1.0に向けて着実に成熟を重ねている」

## 5. Oils (OSH/YSH) の進捗

- **結論**: Oils 0.37.0 が最新（2025年12月）。OSH spec tests: 2,705テスト中2,420パス。Alpine Linux上で /bin/sh, /bin/ash, /bin/bash を OSH で置き換えるテストハーネスも構築
- **一次ソース**: Andy Chu, Oils 公式ブログ
- **URL**: <https://oils.pub/blog/2025/12/release-0.37.0.html>
- **注意事項**: YSH にクロージャ、オブジェクト、名前空間が追加され、PythonやJavaScriptに近い表現力を獲得。NLnetグラント目標を達成
- **記事での表現**: 「OilsのOSHモードは2,705のspec testのうち2,420をパスし、bash互換シェルとしての成熟度を示している」

## 6. POSIX.1-2024 (Issue 8) の策定

- **結論**: IEEE Std 1003.1-2024 が2024年6月14日に公開。POSIX Base Specifications Issue 8。Austin Group（IEEE、The Open Group、ISO/IEC JTC 1/SC 22/WG 15の合同）による策定
- **一次ソース**: IEEE Xplore
- **URL**: <https://ieeexplore.ieee.org/document/10555529/>
- **注意事項**: 前版 Issue 7 (2018年版) からの改訂。シェルとユーティリティの標準インタフェースを定義
- **記事での表現**: 「2024年6月にはPOSIX.1-2024（Issue 8）が公開され、シェルの標準仕様は約30年にわたる改訂を重ねている」

## 7. Elvish shell の現状

- **結論**: 2025年時点で Elvish は 0.21.0〜0.22.0。pre-1.0 の段階だが、対話・スクリプティングの両面で安定的に利用可能。Go言語で実装
- **一次ソース**: Elvish Shell 公式サイト
- **URL**: <https://elv.sh/>
- **注意事項**: 構造化データ、名前空間、例外処理を備える。fnm等のツールとの統合も進む
- **記事での表現**: 「Elvishはpre-1.0ながら、構造化データ、名前空間、例外処理を備え、次世代シェルの一角を占める」

## 8. AI CLI ツールの台頭（2025-2026年）

- **結論**: 2025年後半にClaude Code、GitHub Copilot CLI（2025年9月25日パブリックプレビュー）、Gemini CLIが登場。ターミナルがAIエージェントとの対話の場に変容
- **一次ソース**: 各社公式発表、GitHub Copilot CLI リリース
- **URL**: <https://github.com/github/copilot-cli>
- **注意事項**: GitHub Copilot CLIはMCP対応、Claude Sonnet 4.5やGPT-5をモデル選択可能。旧gh copilot拡張は2025年10月25日に廃止
- **記事での表現**: 「2025年にはClaude Code、GitHub Copilot CLI、Gemini CLIが相次いで登場し、ターミナルはAIエージェントとの対話の場へと変容しつつある」

## 9. Starship プロンプトの普及

- **結論**: Starship はRust製のクロスシェルプロンプト。Bash, Fish, ZSH, Ion, Tcsh, Elvish, Nu, Xonsh, Cmd, PowerShell に対応。2025年時点で広く普及
- **一次ソース**: Starship 公式サイト
- **URL**: <https://starship.rs/>
- **注意事項**: シェルの「上」にプロンプトという横断的レイヤーを構築した点が重要
- **記事での表現**: 「Starshipはシェルを超えた横断的なプロンプトレイヤーとして、10種以上のシェルに対応する」

## 10. Alpine Linux / Docker コンテナ環境における /bin/sh

- **結論**: Alpine Linuxは2025年時点でもDockerベースイメージとして広く採用。約5MBのフットプリント。2016年にDocker公式イメージライブラリがUbuntuからAlpineに切り替え
- **一次ソース**: Docker Hub Alpine 公式イメージ、The New Stack
- **URL**: <https://hub.docker.com/_/alpine>
- **注意事項**: Alpine の /bin/sh は BusyBox ash。軽量性・セキュリティが採用理由
- **記事での表現**: 「Alpine Linuxの約5MBのフットプリントは、コンテナ環境でのシェル選択がいかにシステム設計と直結するかを示している」

## 11. GitHub Actions のデフォルトシェル挙動

- **結論**: Linux/macOSランナーではbashがデフォルト、Windowsではpwshがデフォルト。bash使用時は `--noprofile --norc -eo pipefail` が暗黙的に付与。コンテナ内ではデフォルトが /bin/sh
- **一次ソース**: GitHub Docs, "Workflow syntax for GitHub Actions"
- **URL**: <https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions>
- **注意事項**: コンテナジョブではbashではなくshがデフォルトになる点に注意
- **記事での表現**: 「GitHub Actionsのランナーはbashをデフォルトとするが、コンテナ内では/bin/shに切り替わる」
