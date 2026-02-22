# ファクトチェック記録：第12回「CAP定理——分散システムの不可能三角形」

## 1. Eric BrewerのPODC 2000基調講演

- **結論**: Eric Brewerは2000年7月16-19日にオレゴン州ポートランドで開催されたACM Symposium on Principles of Distributed Computing（PODC）2000にて基調講演「Towards Robust Distributed Systems」を行い、CAP予想を提唱した
- **一次ソース**: Eric A. Brewer, "Towards Robust Distributed Systems", PODC 2000 Keynote
- **URL**: <https://people.eecs.berkeley.edu/~brewer/cs262b-2004/PODC-keynote.pdf>, <https://www.podc.org/podc2000/brewer.html>
- **注意事項**: BrewerはCAP原則を1999年頃から提唱しており、PODC 2000で「予想（conjecture）」として正式発表。Brewer自身はUC Berkeley教授で、Inktomi（1996年設立）の共同創業者。2011年からGoogleのVP of Infrastructure
- **記事での表現**: 「2000年7月、Eric BrewerはACM PODC（Symposium on Principles of Distributed Computing）の基調講演『Towards Robust Distributed Systems』において、後にCAP定理として知られる予想を提唱した」

## 2. Gilbert-Lynchによる形式証明（2002年）

- **結論**: Seth GilbertとNancy Lynch（MIT）が2002年にBrewerの予想を非同期ネットワークモデルで形式的に証明した。論文はACM SIGACT News, Volume 33, Issue 2, 2002年6月に掲載
- **一次ソース**: Seth Gilbert, Nancy Lynch, "Brewer's Conjecture and the Feasibility of Consistent, Available, Partition-Tolerant Web Services", ACM SIGACT News, Vol. 33, No. 2, June 2002
- **URL**: <https://dl.acm.org/doi/10.1145/564585.564601>
- **注意事項**: 部分同期モデルでは結果が異なる。部分同期モデルではメッセージがすべて配信される場合に利用可能でかつ一貫性のあるアトミックストレージを実装可能
- **記事での表現**: 「2002年、MITのSeth GilbertとNancy Lynchは、Brewerの予想を非同期ネットワークモデルにおいて形式的に証明し、予想を定理に昇格させた」

## 3. CAP定理の3要素の形式的定義

- **結論**: Consistency（一貫性）はGilbert-Lynchの論文では線形化可能性（linearizability）として定義。Availabilityは非障害ノードが全てのリクエストに応答を返すこと。Partition Toleranceはネットワーク分断が発生しても動作を継続すること。CAPのConsistencyはACIDのConsistencyとは異なる概念
- **一次ソース**: Gilbert & Lynch 2002, Wikipedia "CAP theorem"
- **URL**: <https://en.wikipedia.org/wiki/CAP_theorem>
- **注意事項**: CAPのConsistencyは「全クライアントが同時に同じデータを見る」=線形化可能性であり、ACIDのConsistency（データベース制約の維持）とは異なる
- **記事での表現**: 「CAPにおけるConsistencyとは線形化可能性（linearizability）を意味する。全てのノードが同時に同じデータを返すことの保証だ。これはACIDのConsistency（データベース制約の維持）とは根本的に異なる概念である」

## 4. Daniel AbadiのPACELC理論（2012年）

- **結論**: Daniel J. Abadiが2012年にIEEE Computer（Vol. 45, No. 2）に発表。正式名はPACELC（Partition時はA/Cの選択、Else時はL/Cの選択）
- **一次ソース**: Daniel J. Abadi, "Consistency Tradeoffs in Modern Distributed Database System Design: CAP is Only Part of the Story", IEEE Computer, Vol. 45, No. 2, February 2012
- **URL**: <https://www.cs.umd.edu/~abadi/papers/abadi-pacelc.pdf>, <https://ieeexplore.ieee.org/document/6127847/>
- **注意事項**: ブループリントでは「Daniel Abramov」と記載されているが、正しくは「Daniel Abadi」（当時Yale大学、後にUniversity of Maryland）。PACELC: Partition時はAvailabilityかConsistencyを選択、Else（通常時）はLatencyかConsistencyを選択
- **記事での表現**: 「2012年、Daniel AbadiはIEEE Computer誌で『CAP is Only Part of the Story』と題する論文を発表し、PACELC理論を提唱した。ネットワーク分断時のA/Cのトレードオフだけでなく、通常時のレイテンシ/一貫性のトレードオフも考慮すべきだという主張だ」

## 5. Martin Kleppmannの「Please stop calling databases CP or AP」（2015年）

- **結論**: Martin Kleppmannが2015年5月11日にブログ記事を公開。同年9月17日にはより詳細な学術論文「A Critique of the CAP Theorem」も公開
- **一次ソース**: Martin Kleppmann, "Please stop calling databases CP or AP", blog post, May 11, 2015; "A Critique of the CAP Theorem", September 2015
- **URL**: <https://martin.kleppmann.com/2015/05/11/please-stop-calling-databases-cp-or-ap.html>, <https://www.cl.cam.ac.uk/research/dtg/archived/files/publications/public/mk428/cap-critique.pdf>
- **注意事項**: Kleppmannの批判のポイント: (1) CAPのConsistencyは線形化可能性のみで定義が狭すぎる、(2) CAPのモデルは単一のread-writeレジスタで複数オブジェクトにまたがるトランザクションは考慮外、(3) ネットワーク分断のみがfailure modeでノードクラッシュ等は考慮外、(4) レイテンシについて何も言わない
- **記事での表現**: 「2015年、Martin Kleppmann（『Designing Data-Intensive Applications』著者）はブログ記事『Please stop calling databases CP or AP』で、CAP定理の過度な単純化を批判した」

## 6. BASEモデルの起源

- **結論**: Dan Pritchett（eBay Technical Fellow）が2008年にACM Queue誌に「BASE: An Acid Alternative」を発表。BASEはBasically Available, Soft state, Eventually consistentの略
- **一次ソース**: Dan Pritchett, "BASE: An Acid Alternative", ACM Queue, Vol. 6, No. 3, 2008
- **URL**: <https://queue.acm.org/detail.cfm?id=1394128>
- **注意事項**: BASEはACIDの対概念として提案。同期的な結合から解放し、可用性とスケーラビリティを一貫性の代償として得るモデル
- **記事での表現**: 「2008年、eBayのDan Pritchettは『BASE: An Acid Alternative』をACM Queue誌に発表し、ACIDに対置するBASEモデル（Basically Available, Soft state, Eventually consistent）を体系化した」

## 7. Brewerの回顧記事（2012年）

- **結論**: Eric Brewerが2012年2月にIEEE Computer（Vol. 45, pp. 23-29）に「CAP Twelve Years Later: How the 'Rules' Have Changed」を発表。「2 of 3」という単純化が誤解を生んだと自ら認め、分断をどう扱うかの設計アプローチを論じた
- **一次ソース**: Eric A. Brewer, "CAP Twelve Years Later: How the 'Rules' Have Changed", IEEE Computer, Vol. 45, February 2012
- **URL**: <https://ieeexplore.ieee.org/document/6133253/>
- **注意事項**: Brewerは「3つから2つを選ぶ」という図式が過度に単純化されていると指摘。分断は常に起きるわけではなく、分断発生時の対処（検出・回復）を設計に組み込むべきだと主張
- **記事での表現**: 「2012年、Brewer自身がIEEE Computer誌で『CAP Twelve Years Later』を発表し、自らの定理が生んだ誤解を正した。『3つから2つを選ぶ』という図式は過度に単純化されたものだった」

## 8. Werner Vogelsの「Eventually Consistent」（2008年）

- **結論**: Werner Vogels（Amazon CTO）が2008年10月1日にACM Queue（Vol. 6, No. 6）に「Eventually Consistent」を発表。結果整合性の概念とその変種（因果整合性、read-your-writes整合性、セッション整合性など）を体系化
- **一次ソース**: Werner Vogels, "Eventually Consistent", ACM Queue, Vol. 6, No. 6, October 2008
- **URL**: <https://queue.acm.org/detail.cfm?id=1466448>, <https://www.allthingsdistributed.com/2008/12/eventually_consistent.html>
- **注意事項**: 結果整合性の定義: オブジェクトに新たな更新がなければ、最終的に全てのアクセスが最後に更新された値を返す
- **記事での表現**: 「2008年、AmazonのCTO Werner Vogelsは『Eventually Consistent』をACM Queue誌に発表し、結果整合性の概念とその変種を体系化した」

## 9. MongoDBのネットワーク分断時の挙動

- **結論**: MongoDBレプリカセットでネットワーク分断が発生すると、過半数のノードと通信できなくなったプライマリはステップダウンし読み取り専用のセカンダリになる。新しいパーティションで新プライマリが選出される。旧プライマリに書き込まれたがレプリケートされていなかったデータはロールバックされ失われうる。write concern: "majority"を設定することでリスクを軽減可能
- **一次ソース**: MongoDB Documentation, Replication; Kyle Kingsbury, "Jepsen: MongoDB", 2015
- **URL**: <https://aphyr.com/posts/284-jepsen-mongodb>, <https://www.mongodb.com/docs/manual/replication/>
- **注意事項**: Jepsenテストにより、MongoDBの初期バージョンでの一貫性問題が複数報告されている。MongoDB 4.0以降でマルチドキュメントトランザクション対応
- **記事での表現**: 「MongoDBのレプリカセットでネットワーク分断が発生すると、旧プライマリに書き込まれたがレプリケートされていなかったデータはロールバックされ、失われる可能性がある」

## 10. Jepsen（Kyle Kingsbury）による分散DB検証

- **結論**: Kyle Kingsbury（ハンドル名: Aphyr）が2013年頃から「Call me maybe」シリーズとして分散データベースの一貫性検証を開始。Jepsenフレームワークを用いて、クラスタにフォールトを注入し一貫性違反を検出。8年間で26のシステムで一貫性違反を発見
- **一次ソース**: Kyle Kingsbury, Jepsen analyses, <https://jepsen.io/>
- **URL**: <https://jepsen.io/>, <https://aphyr.com/posts/284-jepsen-mongodb>
- **注意事項**: JepsenはCarly Rae Jepsenの「Call Me Maybe」にちなんだ命名。MongoDB、Redis、Cassandra、CockroachDB等を含む多数のシステムを検証
- **記事での表現**: 「Kyle Kingsburyが開発したJepsenフレームワークは、分散データベースにネットワーク分断を注入し、一貫性違反を検出する。8年間で26のシステムから一貫性違反が見つかった」
