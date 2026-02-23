# ファクトチェック記録：第5回「ホスティングサービス——サーバ管理を他人に委ねる」

## 1. さくらインターネットの設立時期と経緯

- **結論**: 1996年12月23日に田中邦裕がホスティングサーバ事業を開始。舞鶴工業高等専門学校在学中に学生寮内でサーバを貸し出したことがきっかけ。1998年4月に大阪で有限会社インフォレストを設立、1999年にさくらインターネット株式会社を設立
- **一次ソース**: さくらインターネット公式 沿革ページ、Wikipedia
- **URL**: <https://www.sakura.ad.jp/corporate/corp/history/>
- **注意事項**: 「1996年設立」はサービス開始時期であり、法人設立は1999年。ブループリントの「1996年設立」は事業開始として正確
- **記事での表現**: 「さくらインターネットは1996年にサービスを開始した（法人化は1999年）」

## 2. Rackspaceの設立時期と経緯

- **結論**: 1996年にRichard Yoo、Dirk Elmendorf、Patrick Condonが創業（当初はCymitar Technology Group）。1998年にRackspaceに改名。「Fanatical Support」を差別化ポイントとした
- **一次ソース**: Rackspace Wikipedia、Rackspace公式サイト
- **URL**: <https://en.wikipedia.org/wiki/Rackspace_Technology>
- **注意事項**: ブループリントでは「1998年」としているが、創業自体は1996年。1998年はRackspaceへの改名時期
- **記事での表現**: 「Rackspace（1996年創業、1998年に現社名に改名）」

## 3. Virtuozzoの歴史とVPSの起源

- **結論**: SWsoft（1997年設立）が2000年にOS レベル仮想化のコンテナ技術を初めて商用リリース。Virtuozzo for Linuxは2001年にリリース。2007年にSWsoftはParallelsに改名
- **一次ソース**: Virtuozzo Wikipedia、OpenVZ Wiki History
- **URL**: <https://en.wikipedia.org/wiki/Virtuozzo_(company)>
- **注意事項**: ブループリントの「Virtuozzo（2001年）」は正確
- **記事での表現**: 「SWsoft社が2001年にリリースしたVirtuozzoは、OSレベル仮想化によるVPSを商用化した先駆者だった」

## 4. Linodeの設立と歴史

- **結論**: 2003年6月16日にChristopher Akerが設立。当初はUML（User Mode Linux）で仮想化。2008年にXenに移行、2015年にKVMに移行。2022年にAkamaiが約9億ドルで買収
- **一次ソース**: Linode Wikipedia、Akamai公式
- **URL**: <https://en.wikipedia.org/wiki/Linode>
- **注意事項**: 初期プランは256MB RAM、10GBストレージで月額約20ドル
- **記事での表現**: 「2003年、Christopher AkerがLinodeを設立。月額20ドルで256MBのRAMと10GBのストレージを持つVPSを提供した」

## 5. DigitalOceanの設立

- **結論**: 2011年にBen Uretsky、Moisey Uretsky、Mitch Wainerらが設立。2012年1月にベータ版をローンチ。2012年にTechStarsインキュベータプログラムを卒業
- **一次ソース**: DigitalOcean Wikipedia、Ben Uretsky Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/DigitalOcean>
- **注意事項**: ブループリントでは「2011年」としている。設立自体は2011年だがプロダクトローンチは2012年
- **記事での表現**: 「DigitalOcean（2011年設立）」

## 6. SoftLayerの歴史

- **結論**: 2005年にLance Crosbyらが設立。専用サーバ、マネージドホスティング、クラウドを提供。2013年6月にIBMが買収（推定20億ドル超）。2018年にIBM Cloudに改名
- **一次ソース**: IBM Cloud Wikipedia（旧SoftLayer）
- **URL**: <https://en.wikipedia.org/wiki/SoftLayer>
- **注意事項**: ブループリントに記載あり
- **記事での表現**: 「SoftLayer（2005年設立、2013年にIBMが買収）」

## 7. Linux cgroupsの歴史

- **結論**: 2006年にGoogleのPaul MenageとRohit Sethが「process containers」として開発開始。2007年末に「control groups」に改名（「container」の用語の混乱を避けるため）。2008年1月リリースのLinuxカーネル2.6.24でメインラインにマージ
- **一次ソース**: cgroups Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Cgroups>
- **注意事項**: VPSのリソース制限の基盤技術として重要
- **記事での表現**: 「cgroupsは2006年にGoogleのエンジニアが開発を開始し、2008年にLinuxカーネル2.6.24でメインラインに統合された」

## 8. LXC（Linux Containers）の歴史

- **結論**: 2008年にIBMのエンジニアらが開発。cgroupsとLinux namespacesを組み合わせて実装。カーネルパッチなしで動作する初のコンテナ実装
- **一次ソース**: LXC Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/LXC>
- **注意事項**: ハンズオンでLXCを使用する設計
- **記事での表現**: 「LXC（Linux Containers）は2008年に登場し、cgroupsとnamespacesを組み合わせた初のメインラインカーネルベースのコンテナ実装だった」

## 9. FreeBSD jailの歴史

- **結論**: 1999年にPoul-Henning Kampが開発。R&D Associates, Inc.（小規模ホスティングプロバイダ）の委託プロジェクト。FreeBSD 4.0（2000年3月14日リリース）で初導入。OSレベル仮想化の先駆的実装
- **一次ソース**: FreeBSD jail Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/FreeBSD_jail>
- **注意事項**: ホスティング事業者のニーズから生まれた技術という文脈が重要
- **記事での表現**: 「FreeBSD jailは2000年にリリースされた。小規模ホスティング事業者の委託で開発されたこの技術は、OSレベルの仮想化の先駆けだった」

## 10. cPanelの歴史

- **結論**: 1996年にSpeed Hosting社の管理パネルとして設計。J. Nick Kostonが開発。1999年にcPanel 3がリリースされ、WHM（Web Host Manager）を含む
- **一次ソース**: cPanel Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/CPanel>
- **注意事項**: 共有ホスティングの管理を簡素化した重要なツール
- **記事での表現**: 「1996年に開発が始まったcPanelは、共有ホスティングの管理を劇的に簡素化した」

## 11. ファーストサーバの歴史と2012年データ消失事故

- **結論**: 1996年7月にクボタシステム開発としてレンタルサーバ事業開始。2000年にファーストサーバ株式会社として独立。2004年にヤフー子会社化。2012年6月20日にデータ消失事故（5,698件の顧客に影響）。2019年にIDCフロンティアに吸収合併され解散
- **一次ソース**: ファーストサーバ Wikipedia、ASCII.jp
- **URL**: <https://ja.wikipedia.org/wiki/%E3%83%95%E3%82%A1%E3%83%BC%E3%82%B9%E3%83%88%E3%82%B5%E3%83%BC%E3%83%90>
- **注意事項**: 記事内では事故の教訓として言及する程度に留める。ブループリントに「ファーストサーバ」の記載あり
- **記事での表現**: ホスティング事業者の一例として名称のみ言及

## 12. 共有ホスティングとApache仮想ホスト

- **結論**: Apache HTTP Serverは1995年に初版リリース。1996年半ばまでに世界で最も人気のあるWebサーバに。IPベースの仮想ホストは初期から対応、名前ベースの仮想ホスト（Name-based Virtual Host）はApache 1.1以降で対応。HTTP/1.1のHostヘッダ（RFC 2068、1997年1月）が名前ベース仮想ホストの基盤
- **一次ソース**: Apache HTTP Server Wikipedia、Apache公式ドキュメント
- **URL**: <https://en.wikipedia.org/wiki/Apache_HTTP_Server>
- **注意事項**: 共有ホスティングの技術的基盤として重要
- **記事での表現**: 「Apache HTTP Serverの仮想ホスト機能が、1台のサーバで複数のWebサイトを収容する共有ホスティングの技術的基盤を提供した」
