# ファクトチェック記録：第4回「コロケーション——自分のサーバを他人の施設に預ける」

## 1. インターネットの商用化とNSFNETの廃止

- **結論**: NSFNETバックボーンは1995年4月30日に廃止された。NSFは4つのNetwork Access Point（NAP）の運用契約を1994年2月に締結し、商用バックボーン（MCI、PSINet、SprintLink、ANSNet等）への移行を完了した
- **一次ソース**: National Science Foundation, "Birth of the Commercial Internet"
- **URL**: <https://www.nsf.gov/impacts/internet>
- **注意事項**: 1994年のNetscape Navigator公開（12月）と1995年のNetscape IPOがWeb商用化を加速した
- **記事での表現**: 1995年4月30日、NSFNETバックボーンが廃止され、インターネットは完全に商用ネットワークへと移行した

## 2. Equinix設立（1998年）

- **結論**: Equinixは1998年6月22日にJay AdelsonとAl Averyによって設立された。両者はDigital Equipment Corporation（DEC）の施設管理者だった。社名は「Equality, Neutrality, Internet eXchange」に由来する
- **一次ソース**: Wikipedia, "Equinix"; Equinix公式情報
- **URL**: <https://en.wikipedia.org/wiki/Equinix>
- **注意事項**: 初期の資金調達は約1,200万ドル。1999年にバージニア州アッシュバーンで最初のデータセンターを取得。キャリアニュートラルなIBX施設を設計した
- **記事での表現**: 1998年、Jay AdelsonとAl Averyがキャリアニュートラルなデータセンターを掲げてEquinixを設立した。ネットワーク事業者による囲い込みを排し、競合するネットワーク同士が対等に接続できる場を提供するというコンセプトだった

## 3. Uptime Instituteのティア分類

- **結論**: Uptime Instituteが1990年代半ばにティア分類システムを策定。Tier I（Basic Capacity、99.671%稼働率）、Tier II（Redundant Capacity）、Tier III（Concurrently Maintainable）、Tier IV（Fault Tolerant）の4段階。2025年時点で122カ国以上、4,000件以上のTier認証が発行されている
- **一次ソース**: Uptime Institute, "Tier Classification System"
- **URL**: <https://uptimeinstitute.com/tiers>
- **注意事項**: Tier Iの年間最大ダウンタイムは28.8時間。Tier IIIは計画停止なしでメンテナンス可能。Tier IVは障害耐性を持つ
- **記事での表現**: Uptime Instituteが1990年代半ばに策定したティア分類は、Tier I（基本容量）からTier IV（耐障害性）までの4段階でデータセンターの信頼性を評価する業界標準となった

## 4. ホットアイル/コールドアイル冷却設計

- **結論**: ホットアイル/コールドアイルレイアウトは1992年にIBMのDr. Robert F. Sullivanが考案した。サーバラックの前面（吸気側）同士が向き合う通路をコールドアイル、背面（排気側）同士が向き合う通路をホットアイルとする
- **一次ソース**: ENERGY STAR, "Move to a Hot Aisle/Cold Aisle Layout"; TechTarget解説
- **URL**: <https://www.energystar.gov/products/data_center_equipment/16-more-ways-cut-energy-waste-data-center/move-hot-aislecold-aisle-layout>
- **注意事項**: レイズドフロア（二重床）からの冷気供給が一般的。NYSERDAの調査では大規模DCの約2/3が採用
- **記事での表現**: 1992年、IBMのRobert F. Sullivanが考案したホットアイル/コールドアイルレイアウトは、サーバの吸気面と排気面を交互に向き合わせることで冷却効率を最大化する設計手法である

## 5. IPMI/BMC仕様の歴史

- **結論**: IPMI v1.0は1998年9月16日に発表された（Intel主導）。v1.5（2001年2月21日、IPMI over LAN追加）、v2.0（2004年2月12日、Serial over LAN追加）と進化。BMC（Baseboard Management Controller）はマザーボード上の専用マイクロコントローラで、温度・ファン速度・電源状態等を監視する
- **一次ソース**: Wikipedia, "Intelligent Platform Management Interface"
- **URL**: <https://en.wikipedia.org/wiki/Intelligent_Platform_Management_Interface>
- **注意事項**: IPMI v1.5でLAN経由のリモート管理が実現し、データセンターでの遠隔管理が可能になった
- **記事での表現**: 1998年にIntelが主導して策定したIPMI仕様は、BMCを介したサーバのリモート監視・管理を標準化した。2001年のv1.5でLAN経由の管理が可能となり、データセンターにおける遠隔運用の基盤となった

## 6. BGPとインターネットエクスチェンジポイント（IXP）

- **結論**: 最初のIXPはCommercial Internet eXchange（CIX）で、Alternet/UUNET、PSI、CERFNETがNSFNETのAUPに関わらずトラフィックを交換するために設立した。現在の大半のプライベートピアリングはキャリアホテルやキャリアニュートラルなコロケーション施設内で行われている
- **一次ソース**: Wikipedia, "Peering"; Wikipedia, "Internet exchange point"
- **URL**: <https://en.wikipedia.org/wiki/Peering>
- **注意事項**: コロケーション施設はIXPやピアリングの物理的な拠点としても重要な役割を果たした
- **記事での表現**: コロケーション施設は単なる「サーバの置き場所」ではなかった。BGPピアリングやIXPの物理的拠点として、インターネットの接続構造そのものを形成した

## 7. UPSと電力冗長化設計

- **結論**: データセンターの電力冗長化にはN+1（必要台数+1台の予備）、2N（完全に独立した2系統）、2N+1（2系統それぞれに予備追加）の設計パターンがある。2N構成では片系統を完全に停止してもサービス継続が可能
- **一次ソース**: CoreSite, "Data Center Redundancy: N+1 vs 2N+1"; Mitsubishi Electric
- **URL**: <https://www.coresite.com/blog/data-center-redundancy-n-1-vs-2n-1>
- **注意事項**: Tier III以上ではN+1以上の冗長化が必須。Tier IVでは2N構成が必要
- **記事での表現**: 電力供給の冗長化設計はN+1（予備1台追加）から2N（完全二重化）まで段階がある。Tier IV施設では、一方の電源系統が完全に故障しても、もう一方の系統だけでデータセンター全体を稼働させられる

## 8. SLA（Service Level Agreement）の起源

- **結論**: SLAの概念は1980年代後半に固定回線の通信事業者から始まり、1990年代のITILフレームワークで標準化された。コロケーションにおけるSLAは電力供給の稼働率、ネットワーク可用性、温湿度管理等を定量的に規定する
- **一次ソース**: Wikipedia, "Service-level agreement"; TechTarget解説
- **URL**: <https://en.wikipedia.org/wiki/Service-level_agreement>
- **注意事項**: SLAは元々ネットワークサービスプロバイダがサービス品質を測定するために導入したもの
- **記事での表現**: SLAの概念は1980年代後半の通信事業者に起源を持ち、1990年代にITILフレームワークを通じてIT業界全体に広まった。コロケーション事業者は電力稼働率やネットワーク可用性を数値で保証するSLAを提供し、「信頼性の定量化」という概念を確立した

## 9. コロケーション市場の成長

- **結論**: グローバルデータセンターコロケーション市場は2024年時点で約694億ドル、2030年には1,654億ドルに達する見込み（CAGR 16.0%）。ニューヨークの60 Hudson Street、111 8th Avenue等のキャリアホテルは1990年代後半から稼働し、現在もインターネット接続の重要拠点である
- **一次ソース**: Grand View Research, "Data Center Colocation Market"; DCD, "The rise and rebirth of carrier hotels"
- **URL**: <https://www.grandviewresearch.com/industry-analysis/data-center-colocation-market>
- **注意事項**: 初期のコロケーションはサーバ1台分やラック1台分のスペース提供から始まった
- **記事での表現**: コロケーション市場は2024年時点で約694億ドル規模に成長し、2030年には1,654億ドルに達すると予測されている

## 10. ipmitoolコマンドラインツール

- **結論**: ipmitoolはIPMI対応システムの管理用コマンドラインツール。センサーデータの読み取り、システムイベントログの表示、LAN設定、リモート電源制御等が可能。`-I lanplus`オプションでIPMI v2.0のLAN経由接続を行う
- **一次ソース**: ipmitool man page; GitHub ipmitool/ipmitool
- **URL**: <https://github.com/ipmitool/ipmitool>
- **注意事項**: ハンズオンではIPMIのシミュレーション環境を使用するため、実機は不要
- **記事での表現**: ipmitoolコマンドを使えば、ネットワーク越しにサーバの電源状態確認、起動・停止、センサー値の監視が可能である。これはコロケーション時代の「リモートハンド」を自動化する技術の原型だ
