# ファクトチェック記録：第16回「SaaSモデル——ソフトウェアを『所有しない』時代」

## 1. ASP（Application Service Provider）の歴史

- **結論**: ASPモデルは1990年代後半（1998-1999年頃）に登場。企業がサブスクリプション料金を支払い、データセンターでホストされたアプリケーションにインターネット経由でアクセスする形態。2000年までに世界で500社以上のASPが設立。代表的企業にUSinternetworking（1998年1月設立、1999年4月IPO、2002年1月倒産）がある。ASPとSaaSの決定的な違いは、ASPがサードパーティ製クライアントサーバーアプリの単なるホスティングだったのに対し、SaaSは自社開発のマルチテナントアプリケーションを提供する点にある。ASPの衰退原因はシングルテナントアーキテクチャによる高コスト、アプリケーション品質の低さ、インターネットインフラの未成熟、ドットコムバブル崩壊（2001-2002年）。
- **一次ソース**: SmartBear, "The Pre-History of Software as a Service"; TechTarget, "What is application service provider (ASP)?"
- **URL**: <https://smartbear.com/blog/the-pre-history-of-software-as-a-service/>、<https://www.techtarget.com/searchapparchitecture/definition/application-service-provider-ASP>
- **注意事項**: ASP市場のピーク規模（約36億ドル、2001年初頭）は複数ソースで確認できるが正確な数字はソースにより若干異なる
- **記事での表現**: 1990年代後半にASPモデルが登場し、2000年までに500社以上が設立されたが、シングルテナント構造の高コストとドットコムバブル崩壊で大半が消滅した

## 2. Salesforce創業と「No Software」キャンペーン

- **結論**: 1999年3月8日、Marc Benioff（当時Oracle副社長）、Parker Harris、Dave Moellenhoff、Frank Dominguezの4名がサンフランシスコのテレグラフヒルの賃貸アパート（1449 Montgomery Street）で創業。広告の専門家Bruce Campbell（レーガン大統領の「Morning in America」キャンペーンを手がけた人物）がゴーストバスターズ風の「No Software」ロゴを制作。2000年2月7日、Regency Theaterで1,500人を集めた「The End of Software」ローンチイベント。Siebel Systemsカンファレンス前で俳優による偽の抗議デモを仕掛けるゲリラマーケティング。2004年6月23日NYSE上場（ティッカー: CRM）、初値11ドル→初日終値17.20ドル（+56.4%）。
- **一次ソース**: Salesforce公式, "The History of Salesforce"; Marc Benioff著 "Behind the Cloud"
- **URL**: <https://www.salesforce.com/news/stories/the-history-of-salesforce/>
- **注意事項**: 「No Software」と「The End of Software」は同一キャンペーンの異なる表現
- **記事での表現**: 1999年3月8日にMarc Benioffら4名がSalesforceを創業し、「No Software」ロゴとゲリラマーケティングでSaaSの時代を宣言した

## 3. Google Apps（2006年）ローンチ

- **結論**: 2006年2月に「Gmail for Your Domain」テスト開始。2006年8月28日に「Google Apps for Your Domain」として正式ローンチ（Gmail、Google Talk、Google Calendar、Page Creator）。2016年9月29日に「G Suite」にリブランド。2020年10月6日に「Google Workspace」にリブランド。
- **一次ソース**: Wikipedia, "Google Workspace"; Lexnet, "A Brief History of Google Workspace"
- **URL**: <https://en.wikipedia.org/wiki/Google_Workspace>
- **注意事項**: 当初無料で提供、有料版（Premier Edition）は2007年に追加
- **記事での表現**: 2006年8月28日にGoogleがGoogle Apps for Your Domainを発表、企業向けクラウドオフィスの出発点となった

## 4. Slack（2013年）の歴史

- **結論**: Slack Technologies（当時Tiny Speck）は2009年にStewart Butterfield（Flickr共同創業者）がバンクーバーで設立。マルチプレイヤーゲームGlitch（2011年9月ローンチ）が失敗し、開発中の内部コミュニケーションツールにピボット。2013年8月にプレビューリリース、2014年2月に一般公開。2020年12月1日、Salesforceが277億ドルでの買収を発表。2021年7月21日に買収完了。
- **一次ソース**: Wikipedia, "Slack Technologies"; TechCrunch, "The Slack origin story", 2019
- **URL**: <https://en.wikipedia.org/wiki/Slack_Technologies>、<https://techcrunch.com/2019/05/30/the-slack-origin-story/>
- **注意事項**: ローンチを2013年8月（プレビュー）とするか2014年2月（一般公開）とするかはソースにより異なる
- **記事での表現**: 2013年8月にプレビュー公開、2014年2月に一般公開。Salesforceが2020年に277億ドルで買収

## 5. SaaS市場規模データ

- **結論**: Gartner予測で2024年の世界SaaS支出は2,472億ドル（前年比20%増）。2025年には約3,000億ドル（前年比19.4%増）。エンタープライズSaaS市場は2024年に2,185億ドルでCRMが収益の51.4%。成長を牽引するのはAI導入。
- **一次ソース**: Gartner, "Market Share Alert: Enterprise Application SaaS Market Reaches $218B in 2024"; SaaStr
- **URL**: <https://www.saastr.com/gartner-saas-spend-is-actually-accelerating-will-hit-300-billion-in-2025/>
- **注意事項**: Gartnerの「エンドユーザー支出」と「市場規模」は定義が異なる場合がある
- **記事での表現**: 2024年の世界SaaS支出は2,472億ドル、2025年には約3,000億ドルに達する見通し

## 6. SaaS疲れ / サブスクリプション疲れ

- **結論**: BetterCloudの2024年レポートで企業あたり平均SaaSアプリ数は106。Zyloの2025 SaaS Management IndexではシャドーIT含め275。毎月平均7.6の新アプリが追加。平均年間SaaS支出は4,900万ドル（従業員1人あたり4,830ドル）。42%の組織がIT予算圧力からSaaS最適化に迫られている。SaaS価格は前年比約11.4%上昇。
- **一次ソース**: BetterCloud, "The big list of 2025 SaaS statistics"; Zylo, "2025 SaaS Management Index"
- **URL**: <https://www.bettercloud.com/monitor/saas-statistics/>、<https://zylo.com/reports/2025-saas-management-index/>
- **注意事項**: BetterCloud（106アプリ）とZylo（275アプリ）の差は測定方法の違い（IT管理下 vs シャドーIT含む）
- **記事での表現**: 企業あたり平均106のSaaSアプリを利用し、シャドーITを含めると275に達する

## 7. マルチテナントSaaSアーキテクチャ

- **結論**: SalesforceのCraig WeissmanとSteve Bobrowskiが2008年に「The Force.com Multitenant Architecture」ホワイトペーパーを発表（2009年ACM SIGMOD国際会議で論文発表）。メタデータ駆動型アーキテクチャで、単一共有データベース・単一スキーマにすべてのテナントを格納し、OrgIDでパーティショニング。
- **一次ソース**: Craig D. Weissman & Steve Bobrowski, "The Force.com Multitenant Architecture", 2008
- **URL**: <https://architect.salesforce.com/fundamentals/platform-multitenant-architecture>
- **注意事項**: ホワイトペーパーは2008年10月15日付と推定、SIGMOD論文は2009年
- **記事での表現**: 2008年にSalesforceがForce.comマルチテナントアーキテクチャのホワイトペーパーを発表し、メタデータ駆動型設計の原則を体系化した

## 8. GDPR（2018年）とSOC2

- **結論**: GDPR: 2012年1月25日に欧州委員会が提案、2016年4月14日に採択、2016年5月24日に発効、2018年5月25日に適用開始。罰則は最大で世界売上の4%または2,000万ユーロ。SOC 2: 起源は1992年のSAS 70、2010-2011年にAICPAがSOCレポートを導入、5つのTrust Services Criteria（セキュリティ、可用性、処理の完全性、機密性、プライバシー）に基づく。
- **一次ソース**: Wikipedia, "General Data Protection Regulation"; EDPS; Secureframe, "The History of SOC 2"
- **URL**: <https://en.wikipedia.org/wiki/General_Data_Protection_Regulation>、<https://secureframe.com/hub/soc-2/history>
- **注意事項**: SOC 2は法的義務ではなく任意の監査フレームワークだが、エンタープライズ取引では事実上の必須要件
- **記事での表現**: 2018年5月25日にGDPRが適用開始、SOC 2はエンタープライズ契約の事実上の入場券

## 9. Subversion / GitHub Enterprise / Jenkins / GitHub Actions

- **結論**: Subversion: CollabNetにより2000年開発開始、1.0は2004年2月23日リリース。GitHub Enterprise: 2011年11月にオンプレミス版リリース。Jenkins: Kohsuke Kawaguchiが2004年にHudsonとして開発開始、2005年2月初リリース、OracleのSun買収後の商標紛争で2011年1月にJenkinsへ改名。GitHub Actions: 2018年10月発表、2019年11月13日GA。
- **一次ソース**: Apache Software Foundation; Wikipedia, "Jenkins (software)"; GitHub Blog
- **URL**: <https://subversion.apache.org/docs/release-notes/release-history.html>、<https://en.wikipedia.org/wiki/Jenkins_(software)>、<https://github.blog/2019-08-08-github-actions-now-supports-ci-cd/>
- **注意事項**: Hudson/Jenkins論争では両プロジェクトが相手をフォークと主張、コミュニティの大多数がJenkins側に移行
- **記事での表現**: Subversion（2004年1.0リリース）からGitHub Enterprise（2011年）、Jenkins（2005年Hudson→2011年改名）、GitHub Actions（2019年GA）へ

## 10. シングルテナント vs マルチテナント設計判断

- **結論**: マルチテナント: コスト効率・一括アップデート容易だがノイジーネイバー問題・カスタマイズ制約。シングルテナント: 最大限の分離と制御だが運用コスト高。ハイブリッド: コンピュート層共有・データ層分離が現実解。
- **一次ソース**: Clerk.com; WorkOS; CloudZero
- **URL**: <https://clerk.com/blog/multi-tenant-vs-single-tenant>
- **注意事項**: 規制要件、コスト、スケーラビリティのバランスで決定される
- **記事での表現**: マルチテナントのコスト効率 vs シングルテナントの分離性、ハイブリッドモデルが実務上のベストプラクティス

## 11. SaaS料金モデルの進化

- **結論**: Microsoft Office 365: 2011年6月28日GA。Adobe Creative Cloud: 2013年5月6日にCreative Suiteの新バージョンを今後リリースしないと宣言。移行初期は収益約16%減、株価約7%下落、Change.orgで5,000人超が署名。長期的には加入者が2024年に3,000万人超、収益44億ドル→150億ドル超に成長。
- **一次ソース**: Wikipedia, "Adobe Creative Cloud"; Wikipedia, "Microsoft 365"; Tapflare, "Case Study: Adobe's Transition to a Subscription Model"
- **URL**: <https://en.wikipedia.org/wiki/Adobe_Creative_Cloud>、<https://en.wikipedia.org/wiki/Microsoft_365>、<https://tapflare.com/articles/adobe-subscription-model-case-study>
- **注意事項**: Adobe CCの「ローンチ」を2012年（発表）とするか2013年5月（永久ライセンス廃止宣言）とするかはソースにより異なる
- **記事での表現**: 2011年Office 365 GA、2013年5月AdobeがCreative Suite廃止を宣言、永久ライセンスからサブスクリプションへの不可逆的転換

## 12. SaaSバックエンドアーキテクチャ

- **結論**: テナント分離の3モデル: Database-per-Tenant（サイロ）、Schema-per-Tenant（ブリッジ）、Row-Level Security（プール）。大規模テナントに専用DB、中規模にスキーマ分離、小規模にRLSのハイブリッドが実務上のベストプラクティス。
- **一次ソース**: AWS, "Guidance for Multi-Tenant Architectures on AWS"; Microsoft Learn, "Multitenant SaaS Patterns"
- **URL**: <https://aws.amazon.com/solutions/guidance/multi-tenant-architectures-on-aws/>、<https://learn.microsoft.com/en-us/azure/azure-sql/database/saas-tenancy-app-design-patterns>
- **注意事項**: AWS Well-Architected Framework SaaS Lensが包括的リファレンス
- **記事での表現**: サイロ・ブリッジ・プールの3モデルとハイブリッド運用が現実解
