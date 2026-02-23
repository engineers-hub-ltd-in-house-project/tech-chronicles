# ファクトチェック記録：第1回「クラウドなしでサーバを立てられるか」

## 1. クラウドインフラ市場規模（IaaS）

- **結論**: 2024年の世界IaaS市場は前年比22.5%成長し、1,718億ドル（約171.8B USD）に達した。2025年のパブリッククラウド支出全体は7,234億ドル（約723.4B USD）と予測されている
- **一次ソース**: Gartner, "Gartner Says Worldwide IaaS Public Cloud Services Market Grew 22.5% in 2024", 2025年8月
- **URL**: <https://www.gartner.com/en/newsroom/press-releases/2025-08-06-gartner-says-worldwide-iaas-public-cloud-services-market-grew-22-point-5-percent-in-2024>
- **注意事項**: IaaSのみの数値とパブリッククラウド全体（IaaS+PaaS+SaaS等）の数値を混同しないこと。2024年のパブリッククラウド全体の支出は約5,957億ドル
- **記事での表現**: 「Gartnerの調査によれば、2024年の世界IaaS市場は1,718億ドルに達した」

## 2. AWS/Azure/GCPの市場シェア

- **結論**: 2025年Q2時点でAWS 30%、Azure 20%、GCP 13%。上位3社で63%を占める。2024年のIaaS市場ではAWSが売上648億ドル・シェア37.7%でトップ、Microsoftが23.9%で2位。上位5社で82.1%
- **一次ソース**: Synergy Research Group, Q2 2025データ; Gartner IaaS市場シェア2024
- **URL**: <https://www.gartner.com/en/newsroom/press-releases/2025-08-06-gartner-says-worldwide-iaas-public-cloud-services-market-grew-22-point-5-percent-in-2024>
- **注意事項**: Synergy ResearchとGartnerで市場定義・シェア数値が異なる。IaaS単独とクラウドインフラ全体では数値が変わる
- **記事での表現**: 「AWS、Azure、GCPの三強がIaaS市場の8割以上を占める寡占構造」

## 3. Stack Overflow Developer Survey 2024のクラウド利用率

- **結論**: AWS 52.2%（プロフェッショナル開発者）、Azure 29.7%、GCP 24.9%。65,000人以上が回答
- **一次ソース**: Stack Overflow, "2024 Stack Overflow Developer Survey", 2024年
- **URL**: <https://survey.stackoverflow.co/2024/technology>
- **注意事項**: 回答者は自己選択バイアスがある。複数回答可のため合計は100%を超える
- **記事での表現**: 「Stack Overflow Developer Survey 2024によれば、プロフェッショナル開発者の52%がAWSを利用している」

## 4. Gitの利用率

- **結論**: 開発者の70%以上がGitを主要なバージョン管理システムとして使用。GitHub利用者は2024年時点で1億人以上、2025年初頭には1.5億人以上
- **一次ソース**: Stack Overflow Developer Survey; GitHub公式統計
- **URL**: <https://survey.stackoverflow.co/2024/>
- **注意事項**: 「94%」という数値はStack Overflow Survey 2022のデータ。最新調査でも圧倒的多数である点は変わらない
- **記事での表現**: 「開発者の大多数がGitを使い、GitHubの利用者は1億人を超えた」

## 5. AWS EC2のベータ公開日

- **結論**: 2006年8月25日にAmazon EC2の限定パブリックベータを発表。正式GA（ベータラベル除去）は2008年10月23日
- **一次ソース**: AWS公式アナウンスメント, "Announcing Amazon Elastic Compute Cloud (Amazon EC2) - beta", 2006年8月24日
- **URL**: <https://aws.amazon.com/about-aws/whats-new/2006/08/24/announcing-amazon-elastic-compute-cloud-amazon-ec2---beta/>
- **注意事項**: 「2006年」はベータ公開。正式版は2008年。EC2開発は南アフリカ・ケープタウンのチーム（Chris Pinkham, Willem van Biljon）が主導
- **記事での表現**: 「2006年8月、AWSはEC2のパブリックベータを公開した」

## 6. NIST SP 800-145 クラウドコンピューティングの定義

- **結論**: 2011年9月公開。クラウドの5つの基本特性を定義: (1)オンデマンド・セルフサービス、(2)広範なネットワークアクセス、(3)リソースプーリング、(4)迅速な弾力性、(5)計量可能なサービス
- **一次ソース**: NIST, "The NIST Definition of Cloud Computing", SP 800-145, 2011年9月
- **URL**: <https://csrc.nist.gov/pubs/sp/800/145/final>
- **注意事項**: 2011年が最終版の公開年。ドラフトは2009年から存在
- **記事での表現**: 「NISTは2011年にクラウドコンピューティングの5つの基本特性を定義した」

## 7. IBM System/360とタイムシェアリングの歴史

- **結論**: IBM System/360は1964年4月7日に発表。TSS/360（タイムシェアリングシステム）は360/67向けに開発されたが、遅延と不安定さに苦しみ、1967年に限定的な試用版として提供されたものの正式製品にはならなかった。代わりにCP-67（後のVM/370）が成功
- **一次ソース**: IBM公式歴史ページ; Wikipedia "IBM System/360"
- **URL**: <https://www.ibm.com/history/system-360>
- **注意事項**: System/360のタイムシェアリングは360/67モデルでの仮想メモリ対応が前提。全System/360がTSS対応だったわけではない
- **記事での表現**: 「1964年にIBMが発表したSystem/360は、メインフレームの歴史を画する製品だった」

## 8. John McCarthyの「ユーティリティコンピューティング」構想

- **結論**: 1961年、MITの100周年記念講演で「コンピューティングがいつか電話システムのような公共ユーティリティとして組織化される可能性がある」と述べた。これがクラウドコンピューティングの概念的起源とされる
- **一次ソース**: John McCarthy, MIT Centennial Speech, 1961年
- **URL**: <https://computinginthecloud.wordpress.com/2008/09/25/utility-cloud-computingflashback-to-1961-prof-john-mccarthy/>
- **注意事項**: 原文の正確な引用は複数バリエーションがある。1960年代後半にユーティリティコンピューティングの概念は人気を得たが、1970年代半ばに技術的制約から下火になった
- **記事での表現**: 「1961年、John McCarthyはMITの100周年記念講演で、コンピューティングが公共ユーティリティになり得ると予言した」

## 9. QEMUの歴史

- **結論**: 2003年にFabrice Bellardが開発開始。2005年にv0.7.1リリース。2008年にKVMプロジェクトと統合。BellardはFFmpegの作者でもあるフランス人プログラマ
- **一次ソース**: QEMU公式; Fabrice Bellard, "QEMU, a Fast and Portable Dynamic Translator", USENIX 2005
- **URL**: <https://en.wikipedia.org/wiki/QEMU>
- **注意事項**: QEMUはエミュレータ、KVMはLinuxカーネルの仮想化モジュール。QEMU+KVMの組み合わせでハードウェア支援仮想化が可能
- **記事での表現**: 「QEMUは2003年にFabrice Bellardが開発したオープンソースのマシンエミュレータ・仮想化ソフトウェアである」

## 10. VirtualBoxの歴史

- **結論**: 2007年1月17日にInnoTek GmbHがVirtualBox OSEをGPLv2で公開。2008年2月にSun MicrosystemsがInnoTekを買収。2010年1月27日にOracleがSunを買収し、開発を引き継いだ
- **一次ソース**: VirtualBox公式; Wikipedia "VirtualBox"
- **URL**: <https://en.wikipedia.org/wiki/VirtualBox>
- **注意事項**: ブループリントでは「VirtualBox（2007年、Sun/Oracle）」とあるが、正確には2007年はInnoTek時代。Sunの買収は2008年
- **記事での表現**: 「VirtualBoxは2007年にInnoTek GmbHがオープンソースとして公開し、後にSun Microsystems、Oracleへと開発が引き継がれた」

## 11. 計算資源の4要素（CPU、メモリ、ストレージ、ネットワーク）

- **結論**: NIST SP 800-145の定義において、クラウドは「ネットワーク、サーバ、ストレージ、アプリケーション、サービス」といった構成可能な計算資源の共有プールへのオンデマンドアクセスを提供するモデルと定義される。CPU/メモリ/ストレージ/ネットワークの4要素は計算資源の基本構成として広く認知されている
- **一次ソース**: NIST SP 800-145, 2011年
- **URL**: <https://csrc.nist.gov/pubs/sp/800/145/final>
- **注意事項**: 「4要素」という分類自体は特定の文献に帰属するものではなく、コンピュータサイエンスの一般的な分類
- **記事での表現**: 「計算資源の本質を構成する4つの要素——CPU、メモリ、ストレージ、ネットワーク」
