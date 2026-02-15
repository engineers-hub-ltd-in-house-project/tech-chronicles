# ファクトチェック記録：第1回

**対象記事**: 第1回「なぜこの連載を書くのか——git ありきの世界への違和感」
**調査日**: 2026-02-15
**調査手段**: Claude Deep Research

---

## 1. GitHubの開発者数

- **結論**: 登録開発者数1億8,000万人超（2025年10月時点）
- **一次ソース**: GitHub Octoverse 2025レポート
- **URL**: https://github.blog/news-insights/octoverse/octoverse-2025/
- **注意事項**: この数字は「登録総数」であり「月間アクティブ開発者数（MAD）」ではない。MADは別途発表されている場合がある
- **記事での表現**: 「GitHubの登録開発者数は1億8,000万人を超えた（Octoverse 2025）」

## 2. バージョン管理ツールにおけるGitの使用率

- **結論**: 93.87%（全回答者）、96.65%（プロフェッショナル開発者）
- **一次ソース**: Stack Overflow Developer Survey 2022
- **URL**: https://survey.stackoverflow.co/2022/
- **注意事項**: 2022年版がバージョン管理ツールに関する設問が設けられた最新の調査。2023年以降はこの設問が削除されている
- **記事での表現**: 「Stack Overflow Developer Survey 2022では、gitの使用率は93.87%」

## 3. CI/CDツールにおけるGitHub Actionsのシェア

- **結論**: 個人プロジェクト62%、組織41%（いずれも1位）
- **一次ソース**: JetBrains State of CI/CD 2025
- **URL**: https://blog.jetbrains.com/teamcity/2025/10/the-state-of-cicd/
- **記事での表現**: 「JetBrainsが2025年10月に公開したState of CI/CD調査によれば、個人プロジェクトでのCI/CDツール1位はGitHub Actionsで、利用率62%」

## 4. Gitの誕生日（最初のコミット）

- **結論**: 2005年4月7日、コミットハッシュ e83c5163316f89bfbde7d9ab23ca2e25604af290
- **一次ソース**: Gitリポジトリのコミットログ
- **注意事項**: Linus Torvaldsがカーネルメーリングリストに投稿したのは2005年4月6日（UTC）とする資料もある。タイムゾーンの違いに注意
- **記事での表現**: 「Torvalds, L., 'Initial revision of git', April 7, 2005」

## 5. diffコマンドの起源

- **結論**: 1974年、Douglas McIlroyとJames W. HuntがBell Labsで開発。Unix第5版に同梱
- **一次ソース**: Hunt, J. W. and McIlroy, M. D., "An Algorithm for Differential File Comparison," Bell Labs CSTR #41, July 1976
- **注意事項**: 1974年にUnixに同梱されたが、アルゴリズムの論文発表は1976年
- **記事での表現**: 「1974年、Bell LabsのDouglas McIlroyとJames W. Huntが開発したdiffコマンドがUnix第5版に同梱された」

## 6. patchコマンドの起源

- **結論**: 1985年、Larry Wall（後にPerlの作者となる）が公開
- **一次ソース**: Wall, L., "patch version 1.3," posted to mod.sources, May 24, 1985
- **記事での表現**: 「1985年には、後にPerlの作者となるLarry Wallがpatchコマンドを公開した」

## 7. SCCSの誕生

- **結論**: 1972年、Marc Rochkind、Bell Labs
- **一次ソース**: Rochkind, M. J., "The Source Code Control System," IEEE Transactions on Software Engineering, SE-1(4), 1975
- **注意事項**: 開発は1972年だが、論文発表は1975年

## 8. RCSの誕生

- **結論**: 1982年、Walter Tichy、Purdue University
- **一次ソース**: Tichy, W. F., "RCS -- A System for Version Control," Software: Practice and Experience, 15(7), 1985

## 9. CVSの誕生

- **結論**: Dick Gruneがシェルスクリプトとして1986年に公開。開発自体は1984年から
- **一次ソース**: Dick Gruneの個人サイト
- **注意事項**: 指示書では「1986年」としているが、Gruneのページには開発開始が1984年と記載。公開が1986年
- **記事での表現**: 「CVS（1986年にDick Gruneがシェルスクリプトとして公開、開発自体は1984年から）」

## 10. GitOpsの命名

- **結論**: 2017年、WeaveworksのAlexis Richardsonが提唱
- **一次ソース**: Weaveworks Blog, 2017
- **記事での表現**: 「2017年にWeaveworksのAlexis Richardsonが『GitOps』という概念を提唱」
