# ファクトチェック記録：第6回「VMwareの革命——一台の物理マシンに複数のOSを走らせる」

## 1. IBM CP-40/CMSの誕生年と仮想化の起源

- **結論**: CP-40/CMSの本番運用は1967年1月に開始。IBM System/360 Model 40の特別改造機上で動作した。完全仮想化を実装した最初のOSであり、14の同時仮想マシンをサポートした。IBM Cambridge Scientific Center（CSC）のスタッフがMITのProject MACおよびLincoln Laboratoryと協力して開発
- **一次ソース**: IBM, "z/VM History: Timeline"; Wikipedia, "IBM CP-40"
- **URL**: <https://www.vm.ibm.com/history/timeline.html>, <https://en.wikipedia.org/wiki/IBM_CP-40>
- **注意事項**: CP-40はCP-67の研究的前身であり、CP-67/CMSがIBM VMファミリの直接の親である
- **記事での表現**: 「1967年、IBM Cambridge Scientific CenterでCP-40/CMSの本番運用が開始された。完全仮想化を実装した最初のOSであり、1台のSystem/360上で14の仮想マシンを同時に動作させた」

## 2. IBM VM/370の発表年

- **結論**: IBMは1972年8月2日にVM/370をSystem/370向けに発表した。CP/CMSの再実装であり、仮想メモリハードウェアの追加とともに提供された
- **一次ソース**: IBM, "z/VM History"; R. J. Creasy, "The Origin of the VM/370 Time-sharing System"
- **URL**: <https://www.vm.ibm.com/history/>, <https://en.wikipedia.org/wiki/VM_(operating_system)>
- **注意事項**: 「1972年」はブループリント記載と一致。ソースコードが顧客に出荷されたことでカスタム修正が可能だった
- **記事での表現**: 「1972年、IBMはSystem/370向けにVM/370を正式発表した」

## 3. VMware創業の経緯（1998年、創業メンバー）

- **結論**: VMwareは1998年に設立。創業者はDiane Greene、Mendel Rosenblum、Scott Devine、Ellen Wang、Edouard Bugnionの5名。RosenblumはUC Berkeley出身で、創業時はStanford大学の准教授（OS・仮想化研究）。GreeneはRosenblumの配偶者
- **一次ソース**: Wikipedia, "VMware"; Wikipedia, "Diane Greene"; Wikipedia, "Mendel Rosenblum"
- **URL**: <https://en.wikipedia.org/wiki/VMware>, <https://en.wikipedia.org/wiki/Diane_Greene>
- **注意事項**: ブループリントでは「Diane Greene, Mendel Rosenblum」の2名のみ記載。実際は5名の共同創業。Bugnionが初代CTO/チーフアーキテクト
- **記事での表現**: 「1998年、Diane Greene、Mendel Rosenblum、Scott Devine、Ellen Wang、Edouard Bugnionの5名がVMwareを創業した」

## 4. VMware Workstationのリリース日

- **結論**: VMware Workstation 1.0は1999年5月15日にリリースされた。x86アーキテクチャの商用仮想化に成功した最初の製品。32ビットx86 CPUの仮想化を実現
- **一次ソース**: Wikipedia, "VMware Workstation"; ACM, "Bringing Virtualization to the x86 Architecture with the Original VMware Workstation"
- **URL**: <https://en.wikipedia.org/wiki/VMware_Workstation>, <https://dl.acm.org/doi/10.1145/2382553.2382554>
- **注意事項**: ブループリントの「1999年」と一致
- **記事での表現**: 「1999年5月、VMware Workstation 1.0がリリースされた。x86アーキテクチャ上で複数のOSを同時実行できる初の商用製品だった」

## 5. VMware ESX Serverのリリース日

- **結論**: VMware ESX 1.0 Serverは2001年3月にリリースされた。Type-1（ベアメタル）ハイパーバイザであり、Linuxベースのサービスコンソール（COS）を管理層として使用
- **一次ソース**: virtualg.uk, "The History of VMware ESXi (2001 to 2025)"; Wikipedia, "VMware ESX"
- **URL**: <https://virtualg.uk/the-history-of-vmware-esxi-2001-to-2025/>, <https://en.wikipedia.org/wiki/VMware_ESX>
- **注意事項**: ブループリントの「2001年」と一致。ESXはElastic Sky Xの略。後継のESXiはサービスコンソールを廃止
- **記事での表現**: 「2001年3月、VMwareはESX Server 1.0をリリースした。ホストOSを必要としないType-1ハイパーバイザ（ベアメタルハイパーバイザ）だった」

## 6. VMware vMotionのリリース年

- **結論**: vMotionは2002年に開発が始まり、2003年にVMware VirtualCenter 1.0とともにリリースされた。稼働中の仮想マシンを物理ホスト間でダウンタイムなしに移動する技術
- **一次ソース**: VMware Cloud Foundation Blog, "The vMotion Process Under the Hood"; Virtualization Review, "The Evolution of VMware's vMotion"
- **URL**: <https://blogs.vmware.com/cloud-foundation/2019/07/09/the-vmotion-process-under-the-hood/>, <https://virtualizationreview.com/articles/2016/09/14/evolution-of-vmware-vmotion.aspx>
- **注意事項**: ブループリントの「2003年」と一致。初期デモでは3D Pinballで移行中もゲームプレイに影響がないことを実演
- **記事での表現**: 「2003年、VMwareはvMotionをVirtualCenter 1.0とともにリリースした。稼働中の仮想マシンを別の物理ホストにダウンタイムなしで移動できる技術だ」

## 7. Popek-Goldberg仮想化要件（1974年）

- **結論**: Gerald J. PopekとRobert P. Goldbergが1974年にCommunications of the ACM（Vol.17, No.7, pp.412-421）に発表した論文「Formal Requirements for Virtualizable Third Generation Architectures」。「センシティブ命令の集合が特権命令の集合の部分集合であれば、効率的なVMMを構築できる」というのが中心定理
- **一次ソース**: Popek, G.J. and Goldberg, R.P., Communications of the ACM, 1974
- **URL**: <https://en.wikipedia.org/wiki/Popek_and_Goldberg_virtualization_requirements>
- **注意事項**: x86はこの要件を満たさなかった（17個のセンシティブかつ非特権の命令が存在）
- **記事での表現**: 「1974年、PopekとGoldbergはCommunications of the ACMで仮想化の形式的要件を定義した」

## 8. x86のセンシティブ非特権命令問題

- **結論**: x86-32アーキテクチャには17個のセンシティブかつ非特権の命令が存在。SGDT、SLDT、SIDT、SMSWは特権状態への読み取り専用アクセスを提供し、PUSHF、POPF、IRETは割り込みフラグへのアクセスを提供する。これらはtrap-and-emulateでは捕捉できないため、古典的仮想化手法が適用不可能
- **一次ソース**: Harvard CS161 Lecture 25; Studocu, "X86-Sensitive instructions Analysis"
- **URL**: <https://read.seas.harvard.edu/cs161/2018/lectures/lecture25/>, <https://en.wikipedia.org/wiki/Popek_and_Goldberg_virtualization_requirements>
- **注意事項**: VMwareはバイナリトランスレーションでこの問題を回避した
- **記事での表現**: 「x86-32アーキテクチャには17個のセンシティブかつ非特権の命令があり、Popek-Goldbergの仮想化要件を満たさなかった」

## 9. Intel VT-xとAMD-Vのリリース年

- **結論**: Intel VT-x: 2005年にPentium 4の2モデルで初めてサポート。AMD-V: 2004年に発表、2006年5月23日にAthlon 64で初めて実装。両技術によりx86がPopek-Goldberg要件を満たせるようになった
- **一次ソース**: Wikipedia, "x86 virtualization"; TechTarget, "AMD-V"
- **URL**: <https://en.wikipedia.org/wiki/X86_virtualization>, <https://www.techtarget.com/searchitoperations/definition/AMD-V-AMD-virtualization>
- **注意事項**: 初期のハードウェア仮想化支援は性能面でバイナリトランスレーションに劣るケースがあった。後続のプロセッサ世代で改善
- **記事での表現**: 「2005年にIntelがVT-xを、2006年にAMDがAMD-Vを導入し、x86プロセッサがハードウェアレベルで仮想化をサポートするようになった」

## 10. VirtualBoxの歴史

- **結論**: VirtualBoxは2007年1月にInnoTek Systemberatung GmbH（ドイツ・ヴァインシュタット）がOSE版をGPL v2でリリース。2008年2月にSun MicrosystemsがInnoTekを買収。2010年にOracleがSunを買収し、Oracle VirtualBoxとなった
- **一次ソース**: Wikipedia, "VirtualBox"
- **URL**: <https://en.wikipedia.org/wiki/VirtualBox>
- **注意事項**: ブループリントでは「VirtualBox（2007年、Sun/Oracle）」と記載されているが、正確にはInnoTek製でSunの買収は2008年
- **記事での表現**: 「2007年、InnoTek GmbHがVirtualBoxをオープンソースとして公開した。2008年にSun Microsystems、2010年にOracleへと所有者が移った」

## 11. VMwareの企業買収の系譜

- **結論**: 2004年1月9日にEMCがVMwareを6億2500万ドルで買収。2016年にDellがEMCを670億ドルで買収（VMwareも傘下に）。2021年11月1日にDellがVMwareをスピンオフ。2023年11月にBroadcomが690億ドルでVMwareを買収完了
- **一次ソース**: Dell Newsroom; Wikipedia, "VMware"
- **URL**: <https://www.dell.com/en-us/dt/corporate/newsroom/announcements/2004/01/20040109-2025.htm>, <https://en.wikipedia.org/wiki/VMware>
- **注意事項**: 記事では買収の詳細よりもVMwareの技術的貢献に焦点を当てる
- **記事での表現**: 買収の系譜は簡潔に触れる程度にとどめる

## 12. サーバ統合比率の実績

- **結論**: VMware仮想化により、サーバ利用率を5%程度から80%まで引き上げ可能。統合比率は15:1程度（1台の物理サーバに15VM）。サーバ1台あたり年間3,000ドル以上の節約。アプリケーションあたりコスト20-30%削減
- **一次ソース**: VMware公式ドキュメント; Consolidation ratio Wikipedia
- **URL**: <https://www.vmware.com/asean/solutions/consolidation.html>, <https://en.wikipedia.org/wiki/Consolidation_ratio>
- **注意事項**: 数値は時期とワークロードにより大きく変動する。記事では概数として使用
- **記事での表現**: 「仮想化以前、平均的なサーバの利用率は10-15%程度だった。VMwareの仮想化により、1台の物理サーバに10台以上の仮想マシンを収容し、利用率を60-80%まで引き上げることが可能になった」
