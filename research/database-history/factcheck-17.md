# ファクトチェック記録：第17回「Google Spanner——分散と強一貫性の両立」

## 1. Google Spanner論文

- **結論**: 2012年10月、OSDI（10th USENIX Symposium on Operating Systems Design and Implementation）にて発表。正式タイトルは「Spanner: Google's Globally-Distributed Database」。筆頭著者はJames C. Corbett。Jeffrey Dean, Sanjay Ghemawatら26名の共著。グローバル規模でデータを分散し、外部一貫性のある分散トランザクションをサポートした最初のシステム
- **一次ソース**: Corbett et al., OSDI 2012
- **URL**: <https://www.usenix.org/conference/osdi12/technical-sessions/presentation/corbett>
- **注意事項**: 2025年にACM SIGMOD Systems Awardを受賞
- **記事での表現**: 「2012年10月、GoogleはOSDIにおいて『Spanner: Google's Globally-Distributed Database』を発表した」

## 2. TrueTime API

- **結論**: Googleが開発した時刻APIで、原子時計とGPSによるハイブリッド時刻同期を使用。時刻を単一の値ではなく「不確実性区間」（TTinterval）として表現する。TT.now()はイベントの絶対時刻を含むことが保証された区間を返す。不確実性区間は通常1〜7ミリ秒。「Commit Wait」——不確実性区間の経過を待ってからコミットを確定させる
- **一次ソース**: Spanner論文 Section 3
- **URL**: <https://research.google.com/archive/spanner-osdi2012.pdf>
- **注意事項**: TrueTimeはGoogleのデータセンター内のインフラに依存しており、一般のユーザーが再現することはできない
- **記事での表現**: 「TrueTimeは時刻を不確実性区間として表現し、Commit Waitによって外部一貫性を保証する」

## 3. Paxosコンセンサスアルゴリズム

- **結論**: Leslie Lamportが1989年に提出、1998年に「The Part-Time Parliament」として論文発表。ギリシャのパクソス島の架空の議会をメタファーとして使用。2001年に「Paxos Made Simple」として簡略化した解説を発表。分散システムにおける合意形成の基礎的アルゴリズム
- **一次ソース**: Lamport, "The Part-Time Parliament", ACM Transactions on Computer Systems, 1998
- **URL**: <https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf>
- **注意事項**: SpannerはPaxosベースのレプリケーションを使用。後のRaftアルゴリズム（2014年）はPaxosの理解しやすい代替として設計された
- **記事での表現**: 「Paxosは1998年にLeslie Lamportが発表した分散合意アルゴリズムだ」

## 4. Google F1

- **結論**: 2013年、VLDB（Proceedings of the VLDB Endowment, Vol 6, No 11）にて発表。タイトルは「F1: A Distributed SQL Database That Scales」。Google広告（AdWords）のバックエンドをシャーディングされたMySQLからSpanner上のF1に移行。最後のリシャーディングは2年以上の集中的作業を要した。F1はSpanner上に構築されたSQL層
- **一次ソース**: Shute et al., VLDB 2013
- **URL**: <https://dl.acm.org/doi/10.14778/2536222.2536232>
- **注意事項**: F1の移行事例はSpannerの実用性の最大の証明。Google広告はGoogleの収益の大部分を占める最重要システム
- **記事での表現**: 「2013年、GoogleはF1論文を発表し、広告バックエンドのMySQLシャードからSpannerへの移行を報告した」

## 5. Google Cloud Spannerのリリース

- **結論**: 2017年2月14日にパブリックベータを公開。2017年5月16日に一般提供（GA）開始。ベータ時の価格は$0.90/ノード/時。GA時に99.999%（5ナイン）の可用性を約束。Google Photos等の社内サービスで使用実績
- **一次ソース**: TechCrunch, Google Cloud Blog
- **URL**: <https://techcrunch.com/2017/02/14/google-launches-cloud-spanner-a-new-globally-distributed-database-service/>
- **注意事項**: ブループリントには「2017年、商用サービス化」とあり正確。ベータが2月、GAが5月
- **記事での表現**: 「2017年2月、GoogleはCloud Spannerのパブリックベータを公開し、5月に一般提供を開始した」

## 6. NewSQLという用語の誕生

- **結論**: 2011年に451 Research（現S&P Global Market Intelligence傘下）のMatthew Aslettが命名。ビジネス分析レポートで使用。定義: SQLインターフェース + 分散スケーラビリティ + 強一貫性を兼ね備えた新世代データベース。3つのサブカテゴリ: (1) ゼロから構築された新アーキテクチャ、(2) シャーディングミドルウェア、(3) クラウドDBaaS
- **一次ソース**: Aslett, 451 Research, 2011; Pavlo, "What's Really New with NewSQL?", SIGMOD Record, 2016
- **URL**: <https://db.cs.cmu.edu/papers/2016/pavlo-newsql-sigmodrec2016.pdf>
- **注意事項**: 近年はNewSQLより「Distributed SQL」という用語が主流になりつつある（Matt Aslett本人も認識）
- **記事での表現**: 「2011年、451 ResearchのMatthew AslettはこうしたデータベースをNewSQLと名付けた」

## 7. SpannerとCAP定理

- **結論**: Eric Brewer（CAP定理の提唱者）自身がGoogle在籍時に「Spanner, TrueTime & The CAP Theorem」（2017年）を執筆。SpannerはCAP定理を「超えた」のではなく、技術的にはCPシステム。ネットワーク分断時には可用性を犠牲にする。ただしGoogleの内部ネットワークの品質が極めて高く、分断は非常に稀。実質的に「effectively CA」と主張可能。99.999%以上の可用性
- **一次ソース**: Brewer, "Spanner, TrueTime & The CAP Theorem", 2017
- **URL**: <https://research.google.com/pubs/archive/45855.pdf>
- **注意事項**: CAP定理を「超えた」のではなく「実用上回避している」が正確な表現
- **記事での表現**: 「SpannerはCAP定理を超えたのではない。Googleのネットワーク品質がネットワーク分断を極めて稀にすることで、実用上CAPの制約を回避しているのだ」

## 8. Spanner SIGMOD Systems Award 2025

- **結論**: 2025年、ACM SIGMOD Systems Awardを受賞。SIGMOD 2025（2025年6月22-27日、ベルリン）で表彰。大規模データ管理の理論と実践に深く影響を与えたシステムを表彰する賞
- **一次ソース**: Google Cloud Blog, SIGMOD Website
- **URL**: <https://cloud.google.com/blog/products/databases/spanner-wins-the-2025-acm-sigmod-systems-award>
- **注意事項**: 論文発表から13年後の受賞。Spannerの長期的影響力を示す
- **記事での表現**: 「2025年、SpannerはACM SIGMOD Systems Awardを受賞した」

## 9. 外部一貫性（External Consistency）の定義

- **結論**: Spanner論文において外部一貫性は次のように定義される: トランザクションT1がコミットした後にトランザクションT2がコミットを開始した場合、T2のコミットタイムスタンプはT1のコミットタイムスタンプより大きい。外部一貫性は厳密な直列化可能性（Strict Serializability）と等価であり、線形化可能性（Linearizability）をマルチリード/ライトのトランザクションに拡張したもの。Spannerはグローバル規模でこの保証を提供した最初のシステム
- **一次ソース**: Corbett et al., OSDI 2012; Google Cloud Blog, "Strict Serializability and External Consistency in Spanner"
- **URL**: <https://cloud.google.com/blog/products/databases/strict-serializability-and-external-consistency-in-spanner>
- **注意事項**: 外部一貫性は線形化可能性の特殊ケースではなく、線形化可能性が外部一貫性の特殊ケース（単一操作のトランザクションに限定した場合）
- **記事での表現**: 「外部一貫性とは、トランザクションのコミット順序が実時間の順序と一致することを保証する性質だ」

## 10. Spannerのアーキテクチャ: Splits とPaxosグループ

- **結論**: Spannerはデータベーステーブルを連続するキー範囲（split）に分割する。各splitは複数のゾーンにまたがるレプリカとして複製され、Paxosアルゴリズムで一貫性を維持する。あるsplitのレプリカ群をPaxosグループと呼ぶ。投票レプリカの過半数が稼働していれば、そのうちの1つがリーダーに選出され、書き込みを処理し、他のレプリカが読み取りを提供する
- **一次ソース**: Google Cloud Documentation, "Replication"
- **URL**: <https://docs.cloud.google.com/spanner/docs/replication>
- **注意事項**: splitの分割・移動は自動的に行われ、負荷分散やアクセスパターンの最適化に使用される
- **記事での表現**: 「Spannerはテーブルデータをsplit（連続キー範囲）に分割し、各splitをPaxosグループとして複数ゾーンに複製する」

## 11. TrueTimeの不確実性区間の詳細

- **結論**: TrueTimeはGPSと原子時計のハイブリッド時刻ソースを使用。各データセンターに専用のタイムマスター（GPSまたは原子時計搭載）を配置。不確実性区間（ε）は通常1〜7ミリ秒。Googleはεを6ms未満に維持するよう管理。Commit Waitでは不確実性区間の経過を待ってからコミットを確定させるが、TrueTimeの高精度により大半のケースで待ち時間はほぼゼロ
- **一次ソース**: Spanner論文 Section 3; sookocheff.com "TrueTime"
- **URL**: <https://sookocheff.com/post/time/truetime/>
- **注意事項**: Commit WaitはPaxosプロポーザルの送信と並行して行われるため、実質的なレイテンシへの影響は限定的
- **記事での表現**: 「TrueTimeの不確実性区間は通常1〜7ミリ秒。Commit Waitでこの区間の経過を待つことで外部一貫性を保証する」

## 12. Google F1のMySQL移行の詳細

- **結論**: Google広告プラットフォーム（AdWords）はシャーディングされたMySQL上で稼働していた。Googleのビジネス成長に伴うリシャーディングは2年以上の集中的作業を要し、数十チームの調整が必要だった。2012年のSpanner論文発表時点で、AdWordsフロントエンドのトラフィックはSpannerバックエンドへの移行が完了していた。移行時のデータ規模は約100TB、数百のアプリケーション、数千のユーザー、10万QPS以上、99.999%の可用性
- **一次ソース**: Google Cloud Blog, "Reflecting on Spanner paper's SIGOPS Hall of Fame Award"
- **URL**: <https://cloud.google.com/blog/products/databases/reflecting-on-spanner-papers-sigops-hall-of-fame-award>
- **注意事項**: F1移行はSpannerの最大の実用性証明。「二度とリシャーディングしたくない」という強い動機がSpanner開発を推進
- **記事での表現**: 「最後のリシャーディングに2年以上を費やしたGoogle広告チームは、二度とリシャーディングをしたくないという強い動機でSpannerへの移行を決断した」

## 13. Cloud Spannerのグラニュラーインスタンスサイジング

- **結論**: 2022年6月、Cloud Spannerはグラニュラーインスタンスサイジングを一般提供開始。最小100処理ユニット（PU）から開始可能。1ノード = 1000 PU。100 PU単位で増減可能。100 PUインスタンスは最大10データベース、約410GBのストレージをサポート。最小構成で月額約65ドルから利用可能
- **一次ソース**: Google Cloud Blog, "Use Spanner at low cost with Granular instance sizing"
- **URL**: <https://cloud.google.com/blog/products/databases/use-spanner-at-low-cost-with-granular-instance-sizing>
- **注意事項**: 従来は最小1ノード（約$650/月）だったため、コスト障壁が大幅に下がった
- **記事での表現**: 「2022年のグラニュラーインスタンスサイジング導入により、最小100処理ユニット（月額約65ドル）からSpannerを利用可能になった」

## 14. Spannerエミュレータ

- **結論**: Cloud Spannerエミュレータはローカル開発・テスト用のインメモリエミュレータ。gcloud CLIまたはDockerイメージとして提供。gRPC（localhost:9010）とREST（localhost:9020）の2つのエンドポイント。データはメモリ内のみに保持され、再起動時に消失。正確性に焦点を当てており、エミュレータ上で動作するアプリケーションは変更なしにCloud Spannerサービス上で動作すべきとされる
- **一次ソース**: Google Cloud Documentation; GitHub GoogleCloudPlatform/cloud-spanner-emulator
- **URL**: <https://github.com/GoogleCloudPlatform/cloud-spanner-emulator>
- **注意事項**: IAM API、バックアップAPIは未サポート。同時に1つの読み書きトランザクションまたはスキーマ変更のみ可能。TrueTimeの振る舞いはエミュレートされない
- **記事での表現**: 「Cloud SpannerエミュレータはDockerイメージとして提供され、ローカルでSpannerの動作を体験できる」
