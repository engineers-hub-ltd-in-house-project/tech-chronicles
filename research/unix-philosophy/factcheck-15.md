# ファクトチェック記録：第15回「サーバOSとしてのLinux支配——なぜ企業はLinuxを選んだか」

## 1. IBM の Linux への10億ドル投資（2000年〜2001年）

- **結論**: 2000年12月、IBM CEO Lou Gerstner が翌2001年に Linux 事業へ10億ドルを投資すると発表。ハードウェア、ソフトウェア、サービスの全領域にわたる投資で、約1,500名の開発者を Linux に投入。この投資により Linux は企業のサーバルームに本格的に進出した
- **一次ソース**: CNN Money, "IBM to spend $1B on Linux", Dec. 12, 2000
- **URL**: <https://money.cnn.com/2000/12/12/technology/ibm_linux/>
- **注意事項**: 投資発表は2000年12月だが、実際の投資実行は2001年。複数のソースで2001年の投資として言及される
- **記事での表現**: 「2000年12月、IBMのCEO Lou Gerstnerは翌年にLinux事業へ10億ドルを投資すると発表した。ハードウェア、ソフトウェア、サービスにわたる全方位的な投資だった」

## 2. Red Hat Enterprise Linux の初リリースとサブスクリプションモデル

- **結論**: RHEL の前身「Red Hat Linux Advanced Server」は2002年3月23日にGA。2003年に「Red Hat Enterprise Linux AS/ES/WS」に改称。同時にコミュニティ向け Red Hat Linux を終了し、Fedora Core（2003年11月6日リリース）とRHELに分離。サブスクリプションモデルはオープンソース業界初の試みとして2002年に導入
- **一次ソース**: Red Hat, "RHELvolution: A brief history of Red Hat Enterprise Linux releases"
- **URL**: <https://www.redhat.com/en/blog/rhelvolution-brief-history-red-hat-enterprise-linux-releases-early-days-rhel-5>
- **注意事項**: 「最初のオープンソースソフトウェアサブスクリプションビジネス」はRed Hat自身の主張
- **記事での表現**: 「2002年、Red Hatは『Red Hat Linux Advanced Server』をリリースし、オープンソースソフトウェアのサブスクリプションビジネスという新しいモデルを開拓した」

## 3. Red Hat の IPO（1999年）とIBMによる買収（2019年）

- **結論**: Red Hat は1999年8月11日に IPO。1株14ドルで600万株を発行し、初日に株価は50ドルに達した。当時ウォール街史上8番目に大きい初日上昇率。2012年に年間売上10億ドルを突破し、初のオープンソース企業としてのマイルストーン。2019年7月9日、IBM が約340億ドル（1株190ドル）で買収完了。当時のテック業界最大級の買収
- **一次ソース**: Red Hat Wikipedia; CNBC, "IBM closes its $34 billion acquisition of Red Hat"
- **URL**: <https://en.wikipedia.org/wiki/Red_Hat>, <https://www.cnbc.com/2019/07/09/ibm-closes-its-34-billion-acquisition-of-red-hat.html>
- **注意事項**: IPO時点ではオープンソースでの収益化は未実証のモデルだった
- **記事での表現**: 「1999年8月、Red HatはIPOを果たし、初日の株価上昇はウォール街の歴史に刻まれた。2019年、IBMが340億ドルでRed Hatを買収したとき、『無料のソフトウェア』のビジネスモデルの到達点が示された」

## 4. LAMP スタックの命名と普及

- **結論**: LAMP（Linux, Apache, MySQL, PHP/Perl）の頭字語は、1998年12月のドイツのコンピュータ誌『Computertechnik』で Michael Kunze が提唱。無料のオープンソースソフトウェアの組み合わせが高価な商用パッケージの代替になりうることを示した。その後 O'Reilly Media と MySQL が普及に貢献
- **一次ソース**: Wikipedia, "LAMP (software bundle)"
- **URL**: <https://en.wikipedia.org/wiki/LAMP_(software_bundle)>
- **注意事項**: 元記事はドイツ語。正式な初出は Computertechnik 1998年12月号
- **記事での表現**: 「1998年、ドイツのコンピュータ誌でMichael Kunzeが『LAMP』という頭字語を生み出した。Linux、Apache、MySQL、PHP——この無料の組み合わせが、dotcomブームのインフラを支えることになる」

## 5. Amazon Web Services の開始（2006年）

- **結論**: AWS は2006年3月14日に Amazon S3 をリリース、続いて2006年8月25日に Amazon EC2 の限定パブリックベータを開始。EC2 はXenベースで構築され、初期はLinuxのみをサポート。1種類のインスタンスタイプと1リージョン（US East）から出発。Windows対応は2008年10月
- **一次ソース**: AWS, "Happy 15th Birthday Amazon EC2"; Wikipedia, "Amazon Elastic Compute Cloud"
- **URL**: <https://aws.amazon.com/blogs/aws/happy-15th-birthday-amazon-ec2/>, <https://en.wikipedia.org/wiki/Amazon_Elastic_Compute_Cloud>
- **注意事項**: EC2正式GA（一般提供）は2008年。2006年はベータ段階
- **記事での表現**: 「2006年、AmazonはEC2のベータ版を公開した。XenベースのLinux仮想マシンを1種類のインスタンスタイプで提供するところから始まった」

## 6. Google のインフラストラクチャ（Linux + 自社ハードウェア）

- **結論**: Google は初期（1998年〜）からLinuxベースの自社カスタムサーバを使用。汎用的なラックマウントサーバを購入する代わりに、合板のプラットフォームにマザーボードとHDDを載せた自作サーバを構築。カスタムLinuxベースのWebサーバ（GWS）を開発。2001年〜2006年にはコロケーション施設からモジュラー・コンテナベースのアーキテクチャへ移行
- **一次ソース**: Data Center Knowledge, "Google Servers circa 1999"; Wikipedia, "Google data centers"
- **URL**: <https://www.datacenterknowledge.com/archives/2007/03/14/google-servers-circa-1999>, <https://en.wikipedia.org/wiki/Google_data_centers>
- **注意事項**: 初期ハードウェアの詳細はStanford時代（1998年）のもの
- **記事での表現**: 「Googleは安価なx86サーバにLinuxを載せ、大量に並べるという戦略を選んだ。高価な商用UNIXサーバではなく、壊れることを前提にした安価なハードウェアとLinuxの組み合わせが、Googleのスケールを支えた」

## 7. Microsoft "Get the Facts" キャンペーン（2003年〜2007年）

- **結論**: 2003年中頃、Microsoft は "Get the Facts" キャンペーンを開始。Windows と Linux の TCO、セキュリティ、信頼性を比較し、Windows の優位性を主張。IDC に委託した2002年のレポートでは、5つの一般的な企業タスクのうち4つで Windows 2000 が Linux より TCO が低いと主張（ただし Web サーバ用途では Linux が優位）。2007年8月にサイトを閉鎖
- **一次ソース**: LWN.net, "The facts behind Microsoft's anti-Linux 'Get the Facts' campaign"
- **URL**: <https://lwn.net/Articles/315627/>
- **注意事項**: Microsoft が調査を委託・資金提供していた事実が批判の対象となった
- **記事での表現**: 「2003年、MicrosoftはLinux対抗の『Get the Facts』キャンペーンを展開した。委託調査でWindowsのTCO優位を主張したが、調査の中立性には疑問が呈された」

## 8. SCO対IBM訴訟（2003年〜2021年）

- **結論**: 2003年3月6日、SCO Group（旧Caldera International）がIBMを提訴。LinuxにUNIXの知的財産が不正にコピーされたと主張し、当初10億ドル、後に50億ドルの損害賠償を請求。2007年9月、SCOが破産申請。2010年、SCO対Novell訴訟でUNIX著作権はNovellにあるとの陪審評決。2016年3月、SCO対IBMの訴訟は却下。2021年、IBMが破産管財人に1,425万ドルを支払い和解。実質的にSCOは全面敗訴
- **一次ソース**: Wikipedia, "SCO Group, Inc. v. International Business Machines Corp."
- **URL**: <https://en.wikipedia.org/wiki/SCO_Group,_Inc._v._International_Business_Machines_Corp.>
- **注意事項**: SCO訴訟はLinux陣営にとってFUD（恐怖・不確実性・疑念）として機能したが、結果的にLinuxの法的正当性を確認する形で決着
- **記事での表現**: 「2003年、SCO GroupがIBMを提訴し、LinuxにUNIXの知的財産が含まれると主張した。企業のLinux採用にFUDが広がったが、結果的にSCOは全面敗訴した」

## 9. SUSE Linux Enterprise Server の歴史

- **結論**: 2001年にSUSE Linux Enterprise Server 7をリリース（x86、Itanium、IBM S/390対応）。2003年11月4日、NovellがSUSE Linux AGを2億1000万ドルで買収を発表、2004年1月に完了。Marist College と IBM Boeblingen Lab で1999年からIBMメインフレーム向けLinux開発に協力
- **一次ソース**: Wikipedia, "SUSE Linux Enterprise"; SUSE, "Novell Completes Acquisition of SUSE Linux"
- **URL**: <https://en.wikipedia.org/wiki/SUSE_Linux_Enterprise>, <https://www.suse.com/news/novell_closing/>
- **注意事項**: SUSEの綴りは時代により異なる（S.u.S.E. → SuSE → SUSE）
- **記事での表現**: 「2001年にSUSE Linux Enterprise Server 7がリリースされ、IBMメインフレームを含む複数のアーキテクチャに対応した」

## 10. Oracle Unbreakable Linux（2006年）

- **結論**: 2006年10月、OracleがRHELのクローンを「Unbreakable Linux」として発表。年間99ドル/システムからという価格でRed Hatの半額以下。JBoss買収（2006年4月）でRed Hatに敗れた報復的意味合いもあった。Red Hatは「Unfakeable Linux」で対抗
- **一次ソース**: Wikipedia, "Oracle Linux"
- **URL**: <https://en.wikipedia.org/wiki/Oracle_Linux>
- **注意事項**: Oracle Linuxは現在も存続しているが、市場シェアは限定的
- **記事での表現**: 「2006年、OracleはRHELのクローンを半額以下で提供する『Unbreakable Linux』を発表した」

## 11. CentOS の終了と AlmaLinux / Rocky Linux の誕生

- **結論**: 2020年末、Red HatがCentOS Linuxの終了を発表。CentOS 8は2021年12月31日にEOL（当初は2029年予定）。CentOS Streamへ移行。CloudLinuxが2021年3月にAlmaLinux初リリース。CentOS共同創設者Gregory KurtzerがRocky Linuxを発表（Rocky McGaughに因む命名）。両者ともRHELの1:1バイナリ互換を目指す
- **一次ソース**: Linux Journal, "Rising from the Ashes: How AlmaLinux and Rocky Linux Redefined the Post-CentOS Landscape"
- **URL**: <https://www.linuxjournal.com/content/rising-ashes-how-almalinux-and-rocky-linux-redefined-post-centos-landscape>
- **注意事項**: 2023年6月、Red HatがRHELソースコードへのアクセスを制限し、さらに論争が拡大
- **記事での表現**: 「2020年末、Red HatがCentOSの終了を発表したとき、エンタープライズLinuxコミュニティは激震に見舞われた。だがAlmaLinuxとRocky Linuxが即座に立ち上がった」

## 12. Linux サーバ市場シェアの現況

- **結論**: 2024年時点でLinuxはサーバOS市場の44.8%を占める。AWS、Google Cloud、Microsoft Azureの仮想マシンの92%がLinux上で稼働。TOP500スーパーコンピュータの100%がLinux（2017年11月以降）。Webサーバとしては2025年12月時点でLinuxが59.4%。エンタープライズLinuxではRHELが43.1%でリード
- **一次ソース**: Command Linux, "Linux Server Market Share (2026)"; SQ Magazine, "Linux Statistics 2025"
- **URL**: <https://commandlinux.com/statistics/linux-server-market-share/>, <https://sqmagazine.co.uk/linux-statistics/>
- **注意事項**: 統計ソースにより数字は異なる。クラウドワークロードに限れば90%超
- **記事での表現**: 「2020年代半ば、クラウドプロバイダの仮想マシンの90%以上がLinux上で動いている。TOP500スーパーコンピュータは2017年以降100%がLinuxだ」

## 13. IBM メインフレームでの Linux（1999年〜）

- **結論**: 1999年12月18日、IBMがLinux 2.2.13カーネルへのS/390向けパッチを公開。Marist Collegeが2000年1月にS/390向け最初のLinuxディストリビューションを配布。SUSEが1999年からIBM Boeblingen LabおよびMarist Collegeと協力して開発
- **一次ソース**: Wikipedia, "Linux on IBM Z"; eWEEK, "10th Anniversary of Linux for the Mainframe"
- **URL**: <https://en.wikipedia.org/wiki/Linux_on_IBM_Z>, <https://www.eweek.com/servers/10th-anniversary-of-linux-for-the-mainframe-beginning-to-today/>
- **注意事項**: IBMメインフレームでのLinuxは、サーバ統合（仮想化）のユースケースとして重要
- **記事での表現**: 「1999年末、IBMはS/390メインフレーム向けLinuxカーネルパッチを公開した。メインフレームという最も保守的な領域にまでLinuxが浸透し始めた瞬間だった」
