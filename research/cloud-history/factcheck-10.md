# ファクトチェック記録：第10回「Azure、GCP——寡占と競争の構造」

## 1. Microsoft Azure の発表と公開日

- **結論**: Windows Azureは2008年10月27日のPDC（Professional Developers Conference）でRay Ozzieにより発表された。コードネームは「Project Red Dog」で、Dave CutlerとAmitabh Srivastavaが主導。商用GA（一般提供）は2010年2月1日。
- **一次ソース**: Microsoft, "Microsoft Unveils Windows Azure at Professional Developers Conference", 2008; Microsoft, "Windows Azure General Availability", 2010
- **URL**: <https://news.microsoft.com/source/2008/10/27/microsoft-unveils-windows-azure-at-professional-developers-conference/>, <https://blogs.microsoft.com/blog/2010/02/01/windows-azure-general-availability/>
- **注意事項**: 発表（2008年10月）と商用GA（2010年2月）を混同しないこと。ブループリントの「2010年2月」は商用GA日で正確
- **記事での表現**: 「2008年10月、MicrosoftはPDCでWindows Azureを発表した。コードネーム"Project Red Dog"。商用サービスとしてのGAは2010年2月1日」

## 2. Windows Azure から Microsoft Azure への改名

- **結論**: 2014年3月25日に改名を発表、4月3日から正式にMicrosoft Azureに改称。Windowsに限定されないプラットフォームであることを反映した戦略的判断
- **一次ソース**: Microsoft Azure Blog, "Upcoming Name Change for Windows Azure", 2014; Redmond Magazine, 2014
- **URL**: <https://azure.microsoft.com/en-us/blog/upcoming-name-change-for-windows-azure/>, <https://redmondmag.com/articles/2014/03/25/microsoft-changing-name-of-windows-azure.aspx>
- **注意事項**: ブループリントの「改名2014年」は正確。正確には発表が3月25日、施行が4月3日
- **記事での表現**: 「2014年、Windows AzureはMicrosoft Azureに改名された。LinuxやOSS対応を拡大し、Windowsに限定されないプラットフォームであることを明示する戦略的判断だった」

## 3. Google App Engine の公開日

- **結論**: 2008年4月にプレビュー公開（当初Python限定、20,000開発者向け）。GAは2011年9月（一部資料では2011年11月）
- **一次ソース**: Google Cloud Platform Blog, "Introducing Google App Engine + our new blog", 2008; TechCrunch, 2008
- **URL**: <https://cloudplatform.googleblog.com/2008/04/introducing-google-app-engine-our-new.html>, <https://techcrunch.com/2008/04/07/google-jumps-head-first-into-web-services-with-google-app-engine/>
- **注意事項**: ブループリントの「Google App Engine（2008年）」は正確（プレビュー公開年）
- **記事での表現**: 「2008年4月、GoogleはApp Engineをプレビュー公開した。Googleのインフラ上でWebアプリケーションを動かせる、PaaS型のサービスだった」

## 4. Google Compute Engine の公開日

- **結論**: 2012年6月28日のGoogle I/Oで限定プレビュー発表。2013年5月15日に全ユーザー利用可能に。2013年12月2日にGA
- **一次ソース**: Google Cloud Platform Blog, "Google Compute Engine is now Generally Available", 2013
- **URL**: <https://cloudplatform.googleblog.com/2013/12/google-compute-engine-is-now-generally-available.html>
- **注意事項**: ブループリントの「Compute Engine（2013年）」はGA年で正確。プレビューは2012年
- **記事での表現**: 「Googleが本格的なIaaSサービス——Compute Engineを発表したのは2012年6月。GAは2013年12月で、AWSのEC2 GA（2006年）から実に7年遅れだった」

## 5. IBM SoftLayer 買収

- **結論**: 2013年6月4日に買収発表、7月8日にクローズ。買収額は20億ドル超（報道ベース）。当時世界最大の非上場クラウドIaaS事業者。2018年にIBM Cloudに改称
- **一次ソース**: IBM/PR Newswire, "IBM Closes Acquisition of SoftLayer Technologies", 2013
- **URL**: <https://www.prnewswire.com/news-releases/ibm-closes-acquisition-of-softlayer-technologies-214589711.html>
- **注意事項**: ブループリントの「IBM SoftLayer買収（2013年）」は正確
- **記事での表現**: 「2013年、IBMはSoftLayerを買収し、クラウドIaaS市場への本格参入を図った」

## 6. Alibaba Cloud の設立

- **結論**: 2009年9月10日設立（Alibaba Group 10周年記念日と同日）。リーダーはWang Jian（元Microsoft幹部）。中国およびアジア太平洋地域で最大のクラウドプロバイダーに成長
- **一次ソース**: Alibaba Cloud Wikipedia; Alibaba Cloud公式ブログ
- **URL**: <https://en.wikipedia.org/wiki/Alibaba_Cloud>, <https://www.alibabacloud.com/blog/alibaba-cloud---pioneering-cloud-computing-timeline-and-major-breakthroughts_601113>
- **注意事項**: ブループリントの「Alibaba Cloud（2009年）」は正確
- **記事での表現**: 「2009年、Alibaba Groupはクラウドコンピューティング子会社Alibaba Cloud（阿里雲）を設立した」

## 7. クラウド市場シェア（2025年時点）

- **結論**: Q2-Q3 2025時点で、AWS 29-30%、Microsoft Azure 20%、Google Cloud 13%。三社合計で約63%。市場規模はQ3 2025で1,069億ドル（前年同期比28%増）。2025年通年で4,000億ドル超の見込み
- **一次ソース**: Synergy Research Group, 2025; Canalys, 2025
- **URL**: <https://www.statista.com/chart/18819/worldwide-market-share-of-leading-cloud-infrastructure-service-providers/>
- **注意事項**: 市場シェアは四半期ごとに変動。AWS のシェアは2021年頃の33%から漸減傾向
- **記事での表現**: 「2025年時点で、AWS約30%、Azure約20%、GCP約13%——三社で市場の6割以上を占める寡占構造だ」

## 8. Satya Nadella と Microsoft のクラウド転換

- **結論**: 2014年2月にCEO就任。「Mobile first, Cloud first」戦略を宣言。Azure中心の事業転換を推進。就任時ほぼゼロだったクラウド収益を、2023年には年間ランレート740億ドル超に成長させた
- **一次ソース**: Microsoft公式; 各種ビジネスメディア
- **URL**: <https://www.fool.com/investing/2020/01/25/how-satya-nadella-and-the-cloud-turned-microsoft-a.aspx>
- **注意事項**: NadellaのCEO就任は2014年2月4日
- **記事での表現**: 「2014年にSatya NadellaがCEOに就任し、"Mobile first, Cloud first"を掲げてAzure中心の事業転換を推進した。この判断がMicrosoftのクラウド事業を劇的に成長させた」

## 9. Google Cloud のリーダーシップと戦略転換

- **結論**: Diane GreeneがGoogle Cloud CEOとして2015年11月就任、エンタープライズ基盤を構築。2019年1月にThomas Kurian（元Oracle幹部）が後任CEOに就任し、エンタープライズ営業の積極化とAnthosによるマルチクラウド戦略を推進
- **一次ソース**: Google Cloud Blog; CNBC, 2018
- **URL**: <https://cloud.google.com/blog/topics/inside-google-cloud/transitioning-google-cloud-after-three-great-years>, <https://www.cnbc.com/2018/11/16/google-cloud-ceo-greene-being-replaced-by-former-oracle-exec-kurian.html>
- **注意事項**: GreeneはVMware共同創業者でもある。KurianのOracle出身はエンタープライズ戦略転換の文脈で重要
- **記事での表現**: 「2019年、Thomas Kurian（元Oracle幹部）がGoogle Cloud CEOに就任し、エンタープライズ市場への積極的な営業体制を構築した」

## 10. BigQuery の公開日

- **結論**: 2010年5月のGoogle I/Oで発表。Dremel（Google内部技術）をベースとしたサーバーレスデータウェアハウス。GAは2012年頃（一部資料では2011年11月限定公開）
- **一次ソース**: BigQuery Wikipedia; Google Cloud Blog
- **URL**: <https://en.wikipedia.org/wiki/BigQuery>
- **注意事項**: Dremelの論文は2010年にVLDBで発表された
- **記事での表現**: 「2010年に発表されたBigQueryは、Google内部のDremel技術を外部提供したもので、ペタバイト規模のデータを数十秒でクエリできた」

## 11. GKE（Google Kubernetes Engine）の公開

- **結論**: 2015年にGA。Google Container Engineとして開始、後にGoogle Kubernetes Engineに改称。Kubernetesを開発したGoogle自身が提供する最初のマネージドKubernetesサービス
- **一次ソース**: 各種テックメディア
- **URL**: <https://www.techtarget.com/searchitoperations/definition/Google-Container-Engine-GKE>
- **注意事項**: ブループリントの「GKE（2015年）」は正確
- **記事での表現**: 「2015年、GoogleはKubernetes自体を開発した知見を活かし、GKE（Google Kubernetes Engine）をGAとした」

## 12. AWS の先行者優位とシェア推移

- **結論**: AWSは2006年にEC2を公開し、クラウドIaaS市場を事実上創出。市場シェアは2021年頃の約33%から2025年Q3の29%へ漸減。しかし収益額は成長を続けており、シェア低下は市場拡大に伴う相対的なもの。Azureの成長率がAWSを上回る傾向が続いている
- **一次ソース**: Synergy Research Group; Kinsta
- **URL**: <https://kinsta.com/aws-market-share/>
- **注意事項**: シェア低下は市場全体の急成長による相対値の変化であり、AWS収益自体は増加している
- **記事での表現**: 「AWSのシェアは2021年頃の約33%から2025年には約30%へ漸減した。だがこれは収益の減少ではなく、市場全体の急拡大——とりわけAzureの成長——による相対的な変化だ」

---

**検証結果サマリー**: 12項目中12項目が検証済み。品質ゲート（6項目以上）を満たしている。
