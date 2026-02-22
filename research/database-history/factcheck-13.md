# ファクトチェック記録：第13回「Memcached, Redis——キャッシュ層という発明」

## 1. Memcachedの誕生（2003年、Brad Fitzpatrick、LiveJournal）

- **結論**: Memcachedは2003年5月22日にBrad FitzpatrickがLiveJournalのために開発した。当初はPerlで書かれ、その後Anatoly VorobeyによりCで書き直された
- **一次ソース**: Brad Fitzpatrick本人のツイート（2018年3月）で「May 2003」にPerlプロトタイプを書いたと証言。memcached.org公式サイト、Wikipedia
- **URL**: <https://x.com/bradfitz/status/969331235183972352>, <https://memcached.org/about>, <https://en.wikipedia.org/wiki/Memcached>
- **注意事項**: Anatoly VorobeyはLiveJournalの社員としてC版への書き直しを担当した。LiveJournalのサーバに余剰RAMがあり、それを有効活用するためにmemcachedが生まれた
- **記事での表現**: 「2003年5月、Brad FitzpatrickはLiveJournalのために、分散メモリキャッシュシステムmemcachedを開発した。当初Perlで書かれたプロトタイプは、同僚のAnatoly VorobeyによってCで書き直された」

## 2. Redisの誕生（2009年、Salvatore Sanfilippo "antirez"、LLOOGG）

- **結論**: Redisは2009年4月にSalvatore Sanfilippo（antirez）が初版をリリースした。動機はイタリアのスタートアップLLOOGG（リアルタイムWebログ分析ツール）のスケーラビリティ改善
- **一次ソース**: Salvatore Sanfilippo Wikipedia、Redis Wikipedia、Brachiosoft Blogの詳細な経緯記事
- **URL**: <https://en.wikipedia.org/wiki/Salvatore_Sanfilippo>, <https://en.wikipedia.org/wiki/Redis>, <https://blog.brachiosoft.com/en/posts/redis/>
- **注意事項**: antirezは最初MySQLを使っていたがディスクI/Oのボトルネックに直面し、Tcl言語でLMDB（LLOOGG Memory Database）というプロトタイプを作った後、Cで本格実装したのがRedis。antirezは2020年6月30日にメンテナの座を退いた
- **記事での表現**: 「2009年、イタリアのプログラマSalvatore Sanfilippo（antirez）は、自身のスタートアップLLOOGGのためにRedisを開発した。MySQLのディスクI/Oボトルネックを解決するため、メモリ上でデータを処理するシステムを構想した」

## 3. Facebookのmemcached大規模運用論文（2013年、NSDI）

- **結論**: 「Scaling Memcache at Facebook」はRajesh Nishtalaら13名の著者による論文で、2013年4月にUSENIX NSDI（Networked Systems Design and Implementation）で発表された
- **一次ソース**: USENIX公式、Engineering at Meta
- **URL**: <https://www.usenix.org/conference/nsdi13/technical-sessions/presentation/nishtala>, <https://engineering.fb.com/2013/04/15/core-infra/scaling-memcache-at-facebook/>
- **注意事項**: 数十億リクエスト/秒を処理し、数兆アイテムを保持するシステムの設計。一貫性、障害処理、レプリケーション、負荷分散の課題と解決策を記述
- **記事での表現**: 「2013年、FacebookのRajesh Nishtalaらは NSDI で『Scaling Memcache at Facebook』を発表し、毎秒数十億リクエストを処理するキャッシュ層の設計を公開した」

## 4. Redis Clusterのリリース（2015年、Redis 3.0）

- **結論**: Redis Clusterは2015年4月1日にリリースされたRedis 3.0で安定版として登場した
- **一次ソース**: Redis GitHub Releases、Google Groups（redis-db）での公式アナウンス
- **URL**: <https://github.com/redis/redis/releases>, <https://groups.google.com/g/redis-db/c/dO0bFyD_THQ/m/Uoo2GjIx6qgJ>
- **注意事項**: Redis Cluster はハッシュスロット（16384スロット）を使用してデータを分散する
- **記事での表現**: 「2015年4月、Redis 3.0のリリースとともに、Redis Clusterが安定版として提供された」

## 5. Redis Pub/Subの導入（Redis 2.0）

- **結論**: Pub/Sub機能はRedis 2.0（2010年）で導入された
- **一次ソース**: Redis公式ドキュメント、antirezのブログ
- **URL**: <https://redis.io/docs/latest/develop/pubsub/>, <https://oldblog.antirez.com/post/redis-weekly-update-3-publish-submit.html>
- **注意事項**: Pub/Subはat-most-onceのメッセージ配信。メッセージは永続化されない
- **記事での表現**: 「2010年のRedis 2.0でPub/Sub（Publish/Subscribe）メッセージング機能が導入された」

## 6. Redis Luaスクリプティングの導入（Redis 2.6）

- **結論**: Luaスクリプティング（EVALコマンド）はRedis 2.6（2012年10月23日）で導入された
- **一次ソース**: Redis公式ドキュメント
- **URL**: <https://redis.io/docs/latest/develop/programmability/>
- **注意事項**: Luaインタプリタがサーバに組み込まれ、redis.call/redis.pcallでRedisコマンドを実行可能
- **記事での表現**: 「2012年のRedis 2.6でLuaスクリプティングが導入された」

## 7. Redis HyperLogLogの導入（Redis 2.8.9、2014年）

- **結論**: HyperLogLogはRedis 2.8.9で導入された。PFADD、PFCOUNT、PFMERGEコマンドが追加された
- **一次ソース**: antirezのブログ、Redis公式ドキュメント
- **URL**: <https://antirez.com/news/75>, <https://redis.io/docs/latest/develop/data-types/probabilistic/hyperloglogs/>
- **注意事項**: PFプレフィックスはHyperLogLogアルゴリズムの発明者Philippe Flajoletに因む。最大12KBのメモリで標準誤差0.81%のカーディナリティ推定が可能
- **記事での表現**: 「2014年のRedis 2.8.9でHyperLogLogデータ構造が追加された。コマンド名のPFプレフィックスは、アルゴリズムの発明者Philippe Flajoletへの敬意を表している」

## 8. Redis Streamの導入（Redis 5.0、2018年10月）

- **結論**: Streamデータ型はRedis 5.0（2018年10月）で導入された。ログデータ構造を抽象化した追記型のデータ構造
- **一次ソース**: Redis公式ドキュメント、InfoQ記事
- **URL**: <https://redis.io/docs/latest/develop/data-types/streams/>, <https://www.infoq.com/news/2018/10/Redis-5-Released/>
- **注意事項**: コンシューマグループによる分散処理をサポート。Pub/SubやListとは異なり、信頼性のあるメッセージ処理に適する
- **記事での表現**: 「2018年10月のRedis 5.0でStreamデータ型が導入された」

## 9. Redisのライセンス変更（2024年）とValkeyフォーク

- **結論**: 2024年3月、Redis 7.4以降のライセンスがBSD 3-clauseからRSALv2/SSPLv1のデュアルライセンスに変更された。これを受けてLinux FoundationがValkey（Redis 7.2.4のフォーク）を発表。AWS、Google Cloud、Oracle等が支援。2025年にはRedis 8でAGPLv3も追加
- **一次ソース**: Redis公式ブログ、Linux Foundation公式発表
- **URL**: <https://redis.io/blog/redis-adopts-dual-source-available-licensing/>, <https://www.linuxfoundation.org/press/linux-foundation-launches-open-source-valkey-community>, <https://redis.io/blog/agplv3/>
- **注意事項**: Redis 7.2.x以前はBSD 3-clauseのまま。ValkeyはBSDライセンスを維持
- **記事での表現**: 「2024年3月、Redis Labs はRedis 7.4以降のライセンスをBSDからRSALv2/SSPLv1に変更した。これに対しLinux Foundationは Valkey をフォークとして立ち上げ、AWS、Google Cloud、Oracleが支援に加わった」

## 10. memcachedの分散ハッシュ / Consistent Hashing

- **結論**: memcachedクライアントはConsistent Hashingを使用してキーを複数サーバに分散する。memcachedサーバ自体は分散のロジックを持たず、クライアントライブラリが担当する
- **一次ソース**: memcached公式ドキュメント、libketamaの実装
- **URL**: <https://memcached.org/about>, <https://www.aboutwayfair.com/tech-innovation/consistent-hashing-with-memcached-or-redis-and-a-patch-to-libketama>
- **注意事項**: memcachedのアーキテクチャはピアツーピア（中央ノードなし）で、各キャッシュノードが独立に動作する。分散ロジックはクライアント側
- **記事での表現**: 「memcachedのサーバ自体は分散のロジックを持たない。キーの分散はクライアントライブラリがConsistent Hashingで行う」

## 11. Redis永続化メカニズム（RDB / AOF）

- **結論**: RedisはRDB（スナップショット）とAOF（Append Only File）の2つの永続化方式を提供する。Redis 4.0以降はRDBとAOFのハイブリッド永続化もサポート
- **一次ソース**: Redis公式ドキュメント
- **URL**: <https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/>
- **注意事項**: RDBはforkして子プロセスがスナップショットを書き出す。AOFはデフォルトで毎秒fsync。ハイブリッドではRDBスナップショットの間の操作をAOFで記録
- **記事での表現**: 「Redisは2つの永続化メカニズムを提供する。RDBは定期的なスナップショット、AOFはすべての書き込み操作をログに追記する」

## 12. Cache Aside / Write Through / Write Behind パターン

- **結論**: キャッシュ戦略の主要パターンとして広く知られる。Cache Aside（Lazy Loading）はアプリケーションがキャッシュとDBを個別に管理する。Write ThroughはキャッシュとDBに同時に書き込む。Write Behind（Write Back）はキャッシュに先に書き込み、DBへの書き込みを遅延させる
- **一次ソース**: 分散システム設計の標準的な用語として複数の技術文献に記載
- **URL**: <https://en.wikipedia.org/wiki/Cache_stampede>
- **注意事項**: 各パターンにはトレードオフがある。Cache Asideはキャッシュミス時のレイテンシ増大、Write Throughは書き込みレイテンシ増大、Write Behindはデータ損失リスク
- **記事での表現**: 各パターンの利点とトレードオフを散文で解説

## 13. Thundering Herd / Cache Stampede

- **結論**: Cache Stampedeは、キャッシュが期限切れになった際に大量のリクエストが同時にバックエンドDBに殺到する問題。Thundering Herdは類似の概念でより一般的な用語
- **一次ソース**: Wikipedia（Cache stampede）、各種技術ブログ
- **URL**: <https://en.wikipedia.org/wiki/Cache_stampede>
- **注意事項**: 解決策としてRequest Coalescing（ロックによる排他）、Probabilistic Early Expiration（確率的な早期更新）、Stale While Revalidateパターン等がある
- **記事での表現**: 「Cache Stampedeとは、人気のあるキャッシュキーが失効した瞬間に、大量のリクエストがバックエンドDBに殺到する問題だ」
