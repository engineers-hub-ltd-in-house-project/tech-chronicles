# ファクトチェック記録：第7回「Xen、KVM——オープンソース仮想化が切り拓いた道」

## 1. Xenの起源とSOSP 2003論文

- **結論**: Xenはケンブリッジ大学Computer LaboratoryのXenoServersプロジェクト（1999年開始）から生まれた。Ian Pratt（Senior Lecturer）とKeir Fraser（研究学生）が中心。2003年にSOSP（ACM Symposium on Operating Systems Principles）で「Xen and the Art of Virtualization」を発表。著者はPaul Barham, Boris Dragovic, Keir Fraser, Steven Hand, Tim Harris, Alex Ho, Rolf Neugebauer, Ian Pratt, Andrew Warfield。最初の公開リリースは2003年、v1.0は2004年
- **一次ソース**: Barham et al., "Xen and the Art of Virtualization", SOSP 2003
- **URL**: <https://www.cl.cam.ac.uk/research/srg/netos/papers/2003-xensosp.pdf>
- **注意事項**: ブループリントでは「2003年、Ian PrattとKeir Fraserが発表」とあるが、論文の筆頭著者はPaul Barhamであり、著者は9名。Prattが研究グループのリーダー、Fraserがハイパーバイザのコア実装を担当
- **記事での表現**: 「2003年、ケンブリッジ大学のIan Pratt率いるチーム（Keir Fraserがコア実装を担当）がSOSPで"Xen and the Art of Virtualization"を発表した」

## 2. Xenの準仮想化とハイパーコール

- **結論**: Xenの準仮想化では、ゲストOSのカーネルを修正し、特権操作をハイパーコール（hypercall）経由でハイパーバイザに委譲する。SOSP論文によれば、ハイパーコールのオーバーヘッドは1-3μs程度。ベンチマークではXenoLinux上のアプリケーション性能がネイティブLinuxとほぼ同等と報告
- **一次ソース**: Barham et al., "Xen and the Art of Virtualization", SOSP 2003
- **URL**: <https://dl.acm.org/doi/10.1145/945445.945462>
- **注意事項**: 準仮想化のオーバーヘッドが小さいのはCPU/メモリ操作の話。I/Oは別途最適化が必要
- **記事での表現**: 「Xenのハイパーコールのオーバーヘッドはわずか1-3マイクロ秒程度であり、SOSP論文のベンチマークではネイティブLinuxとほぼ同等の性能を達成した」

## 3. XenSourceの設立とCitrixによる買収

- **結論**: Ian Pratt、Keir Fraser、Simon Crosby、CEOのNick Gaultらケンブリッジ出身者がXenSource Inc.を設立し、Xenの商用化を推進。2007年にCitrix Systemsが約5億ドル（現金+株式の組み合わせ）でXenSourceを買収。買収にはXenSourceの約1.07億ドルの未確定ストックオプションの引き受けを含む
- **一次ソース**: Citrix Systems プレスリリース, HPCwire報道
- **URL**: <https://www.hpcwire.com/2007/08/20/citrix_acquires_xensource/>
- **注意事項**: ブループリントでは「2007年」とあり、これは正確。買収完了は2007年第4四半期
- **記事での表現**: 「2007年、Citrix SystemsがXenSourceを約5億ドルで買収した」

## 4. KVMの開発とLinuxカーネル統合

- **結論**: Avi KivityがQumranet社で2006年半ばにKVM開発を開始。2006年10月19日にLinuxカーネルメーリングリストで初めて発表。2006年12月10日にアップストリームカーネルにマージ。Linux 2.6.20（2007年2月5日リリース）に含まれて正式リリース。最初のパッチはIntel VMX命令のサポートのみで、AMD SVMサポートは後に追加
- **一次ソース**: LWN.net "Ten years of KVM", Wikipedia "Kernel-based Virtual Machine"
- **URL**: <https://lwn.net/Articles/705160/>
- **注意事項**: ブループリントでは「2007年」とあるが、開発は2006年半ばに開始、カーネルへのマージは2006年12月。リリースが2007年2月
- **記事での表現**: 「2006年10月、Avi KivityがLinuxカーネルメーリングリストにKVMのパッチを投稿した。わずか2ヶ月後の12月にカーネルにマージされ、2007年2月のLinux 2.6.20で正式リリースされた」

## 5. Red HatによるQumranet買収

- **結論**: 2008年9月4日、Red HatがQumranetを1.07億ドルで買収したと発表。Qumranetは2005年にCEO Benny Schnaider、Rami Tamir（President）、Moshe Bar（CTO）、Giora Yaron（Chairman）によって設立。KVMの発明者およびメインテナーを擁していた
- **一次ソース**: Red Hat プレスリリース
- **URL**: <https://www.redhat.com/en/about/press-releases/qumranet>
- **注意事項**: ブループリントでは「2008年」とあり正確。金額1.07億ドルも検証済み
- **記事での表現**: 「2008年、Red HatがQumranetを1億700万ドルで買収し、KVMの開発リソースを獲得した」

## 6. AWS EC2のXenからNitroへの移行

- **結論**: AWS EC2は2006年8月25日の限定パブリックベータからXenハイパーバイザを使用。その後10年間で27以上のインスタンスタイプをXenベースで提供。2017年11月6日にC5ファミリーで初のNitro（KVMベース）インスタンスを発表。NitroはKVMコアカーネルモジュールを使用するが、QEMUなど他のKVMコンポーネントは使わない独自アーキテクチャ
- **一次ソース**: Brendan Gregg "AWS EC2 Virtualization 2017: Introducing Nitro"、AWS公式ドキュメント
- **URL**: <https://www.brendangregg.com/blog/2017-11-29/aws-ec2-virtualization-2017.html>
- **注意事項**: NitroはKVMベースだが、大幅にカスタマイズされている。ネットワーク、ストレージ、セキュリティを専用ハードウェアカードにオフロード
- **記事での表現**: 「AWS EC2は2006年の開始からXenベースで運用され、2017年にKVMベースのNitroハイパーバイザへ移行を開始した」

## 7. Intel VT-xの最初のプロセッサ

- **結論**: 2005年11月14日、IntelはVT-x（コードネーム: Vanderpool）をサポートする最初のプロセッサとしてPentium 4（モデル662と672、それぞれ3.6GHzと3.8GHz）をリリース
- **一次ソース**: Wikipedia "x86 virtualization"
- **URL**: <https://en.wikipedia.org/wiki/X86_virtualization>
- **注意事項**: 第6回記事では「2005年にIntelがVT-xを導入」と記載済み。第7回ではKVMが「VT-x/AMD-Vの存在を前提とした設計」だった点を強調
- **記事での表現**: 「2005年11月にIntelがVT-xをサポートした最初のプロセッサをリリースし、2006年にはAMDがAMD-Vを導入した。KVMはこのハードウェア仮想化支援を前提条件として設計された」

## 8. libvirtとvirshの歴史

- **結論**: libvirtはDaniel Veillard（Red Hat、フランス・グルノーブル在住）が作成。最初のコミットは2005年11月2日。Red Hatがスポンサー。KVM、Xen、VMware ESXi、QEMUなど複数の仮想化技術を統一的に管理するAPIとデーモン。virshはlibvirtの主要なCLIインターフェース
- **一次ソース**: Daniel Veillard's Home Page, libvirt Wikipedia
- **URL**: <https://en.wikipedia.org/wiki/Libvirt>
- **注意事項**: libvirt 1.0.0は2012年11月にリリース（7周年記念）。Daniel P. Berrangéも重要な貢献者
- **記事での表現**: 「2005年にRed HatのDaniel Veillardが開発を開始したlibvirtは、KVM、Xen、VMware ESXiなど異なる仮想化技術を統一的に管理するAPIを提供する」

## 9. virtio（準仮想化I/Oフレームワーク）

- **結論**: Rusty Russell（IBM Research所属時）が2007年にlguestハイパーバイザのサポートのためにvirtioを開発。2008年にACM SIGOPS Operating Systems Review（Vol.42, No.5）に「virtio: towards a de-facto standard for virtual I/O devices」を発表。KVMの準仮想化I/Oのデファクトスタンダードとなった。vringというリングバッファトランスポートを使用
- **一次ソース**: Rusty Russell, "virtio: towards a de-facto standard for virtual I/O devices", ACM SIGOPS, 2008
- **URL**: <https://ozlabs.org/~rusty/virtio-spec/virtio-paper.pdf>
- **注意事項**: virtioはKVM専用ではなく、複数のハイパーバイザで利用可能な設計
- **記事での表現**: 「2008年、IBMのRusty Russellが発表したvirtioは、仮想化I/Oの標準フレームワークとなり、KVMのI/O性能を大幅に改善した」

## 10. QEMU（Fabrice Bellard）

- **結論**: Fabrice Bellard（フランスのプログラマ、FFmpegやTiny C Compilerの作者でもある）が2003年にQEMUの最初のコミットをプッシュ。v0.7.1（2005年）まで単独で開発。動的バイナリトランスレーションを使用してCPUエミュレーションを実現。KVMと組み合わせることで、QEMUがデバイスエミュレーション、KVMがCPU仮想化を担当する協調モデルが確立
- **一次ソース**: Wikipedia "Fabrice Bellard", Wikipedia "QEMU"
- **URL**: <https://en.wikipedia.org/wiki/QEMU>
- **注意事項**: QEMUは単体ではエミュレータだが、KVMと組み合わせるとハードウェア仮想化アクセラレータとして機能
- **記事での表現**: 「2003年にFabrice Bellardが開発したQEMUは、KVMと組み合わされることでデバイスエミュレーションを担当し、CPU仮想化はKVMに委ねるという協調モデルを確立した」

## 11. Xen Projectの Linux Foundation移管（2013年）

- **結論**: 2013年4月15日、XenプロジェクトがLinux FoundationのCollaborative Projectとして移管された。メンバーにはAmazon、AMD、Bromium、CA Technologies、Calxeda、Cisco、Citrix、Google、Intel、Oracle、Samsung、Verizonが含まれる。「Xen Project」という新しい商標が作られ、商用利用の「Xen」商標と区別
- **一次ソース**: Linux Foundation プレスリリース
- **URL**: <https://www.linuxfoundation.org/press/press-release/xen-to-become-linux-foundation-collaborative-project>
- **注意事項**: Citrix買収後のXenの発展において重要な転換点
- **記事での表現**: 「2013年、XenプロジェクトはLinux FoundationのCollaborative Projectとして移管され、ベンダー中立な立場での開発体制が確立された」
