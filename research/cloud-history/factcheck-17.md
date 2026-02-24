# ファクトチェック記録：第17回「コンテナオーケストレーション——KubernetesがIaaSを再定義する」

## 1. DockerのPyCon 2013デモと公開

- **結論**: Solomon Hykesは2013年3月15日、PyCon US 2013のメインステージで5分間のライトニングトーク「The Future of Linux Containers」を行い、Dockerを初めて公開デモした。Dockerはフランスで設立されたPaaS企業dotCloud内部のプロジェクトとして開発された。dotCloud Inc.はKamel Founadi、Hykes、Sebastien Pahlにより、Y Combinator Summer 2010に参加し、2011年にローンチ。2013年にDocker Inc.に社名変更。Dockerは2013年3月にオープンソースとして公開され、当初はLXCをデフォルトの実行環境として使用していた。
- **一次ソース**: PyVideo.org, "Lightning Talk - The future of Linux Containers", PyCon US 2013; Docker Blog, "Docker: Nine Years YOUNG", 2022; Wikipedia, "Docker (software)"
- **URL**: <https://pyvideo.org/pycon-us-2013/the-future-of-linux-containers.html>, <https://www.docker.com/blog/docker-nine-years-young/>, <https://en.wikipedia.org/wiki/Docker_(software)>
- **注意事項**: ライトニングトークはメインステージで行われ、数百人の聴衆がいた。Hykes自身は30人程度の小部屋を想定していた。
- **記事での表現**: 「2013年3月、PyCon US 2013のメインステージで、Solomon Hykesは5分間のライトニングトーク『The Future of Linux Containers』でDockerを世界に初めて披露した」

## 2. Kubernetes発表とv1.0リリース

- **結論**: Kubernetesは2014年6月6日にGoogleが最初のコミットを行い、2014年6月10日にDockerCon 2014でGoogle社員Eric Brewerが基調講演で発表した。バージョン1.0は2015年7月21日にOSCONでリリースされた。プロジェクトの創設者はGoogle社員のJoe Beda、Brendan Burns、Craig McLuckieの3名。
- **一次ソース**: Kubernetes Blog, "10 Years of Kubernetes", June 2024; Google Cloud Blog, "How Kubernetes came to be: A co-founder shares the story"; Google Cloud Platform Blog, "Kubernetes V1 Released", July 2015
- **URL**: <https://kubernetes.io/blog/2024/06/06/10-years-of-kubernetes/>, <https://cloud.google.com/blog/products/containers-kubernetes/from-google-to-the-world-the-kubernetes-origin-story>, <https://cloudplatform.googleblog.com/2015/07/Kubernetes-V1-Released.html>
- **注意事項**: ブループリントでは「Kubernetes（2014年、Google）」とあり、発表年は2014年で正しい。v1.0は2015年7月。内部コードネームは「Project Seven of Nine」（Star Trek: Voyagerのキャラクター、元Borgドローン）。
- **記事での表現**: 「2014年6月、GoogleはDockerCon 2014でKubernetesを発表した。2015年7月21日にバージョン1.0がOSCONでリリースされた」

## 3. Google Borg論文（2015年）

- **結論**: "Large-scale cluster management at Google with Borg"は、Abhishek Verma、Luis Pedrosa、Madhukar R. Korupolu、David Oppenheimer、Eric Tune、John Wilkesにより、2015年のEuroSys（ACM European Conference on Computer Systems、フランス・ボルドー）で発表された。Borgは数万台のマシンからなるクラスタで数十万のジョブを管理するシステム。
- **一次ソース**: Google Research, "Large-scale cluster management at Google with Borg", 2015; ACM Digital Library, DOI: 10.1145/2741948.2741964
- **URL**: <https://research.google/pubs/large-scale-cluster-management-at-google-with-borg/>, <https://dl.acm.org/doi/10.1145/2741948.2741964>
- **注意事項**: Borgの論文公開は2015年だが、Borgシステム自体はそれ以前から10年以上Googleで稼働していた。
- **記事での表現**: 「Googleが社内で10年以上運用してきたクラスタ管理システムBorgは、2015年のEuroSysで論文として公開された」

## 4. Google Omega論文（2013年）

- **結論**: "Omega: flexible, scalable schedulers for large compute clusters"は、Malte Schwarzkopf、Andy Konwinski、Michael Abd-El-Malek、John Wilkesにより、2013年のEuroSys（ACM European Conference on Computer Systems）で発表された。Best Student Paper Awardを受賞。Omegaは共有状態とロックフリーの楽観的並行制御を用いた並列スケジューラアーキテクチャ。
- **一次ソース**: Google Research, "Omega: flexible, scalable schedulers for large compute clusters", 2013; UC Berkeley AMPLab
- **URL**: <https://research.google/pubs/omega-flexible-scalable-schedulers-for-large-compute-clusters/>, <https://amplab.cs.berkeley.edu/publication/omega-flexible-scalable-schedulers-for-large-compute-clusters/>
- **注意事項**: OmegaはBorgの第二世代スケジューラで、Kubernetesの設計にも影響を与えた。
- **記事での表現**: 「2013年、Googleは第二世代クラスタスケジューラOmegaの論文をEuroSysで発表した」

## 5. "Borg, Omega, and Kubernetes"論文（2016年）

- **結論**: Brendan Burns、Brian Grant、David Oppenheimer、Eric Brewer、John Wilkesにより、ACM Queue Volume 14（2016年）に発表。「3つのコンテナ管理システムから10年間で学んだ教訓」をまとめた論文。Communications of the ACM 2016年5月号にも掲載。
- **一次ソース**: ACM Queue, "Borg, Omega, and Kubernetes", 2016
- **URL**: <https://queue.acm.org/detail.cfm?id=2898444>, <https://dl.acm.org/doi/10.1145/2890784>
- **注意事項**: この論文はBorg→Omega→Kubernetesの系譜を明示的に記述した公式的なリファレンス。
- **記事での表現**: 「2016年、ACM Queueに発表された『Borg, Omega, and Kubernetes』論文で、Googleの3世代にわたるコンテナ管理システムの教訓が体系化された」

## 6. CNCF設立（2015年）

- **結論**: Cloud Native Computing Foundation（CNCF）は、2015年7月21日にLinux Foundation傘下の組織として設立が発表された（Kubernetes 1.0のリリースと同時）。正式な設立は2015年12月。創設メンバーにはGoogle、Docker、Mesosphere、Red Hat、Twitter、Huawei、Intel、Cisco、IBM、VMwareが含まれる。Kubernetesが最初の寄贈プロジェクト（seed technology）。
- **一次ソース**: CNCF Announcement, December 2015; Wikipedia, "Cloud Native Computing Foundation"
- **URL**: <https://www.cncf.io/announcements/2015/12/17/cloud-native-computing-foundation-announces-new-members-begins-accepting-technical-contributions/>, <https://en.wikipedia.org/wiki/Cloud_Native_Computing_Foundation>
- **注意事項**: 設立意向の発表は2015年のOSCON（7月）、正式な技術的貢献の受け入れ開始は2015年12月。
- **記事での表現**: 「2015年7月、Kubernetes 1.0のリリースと同時に、Linux Foundation傘下にCloud Native Computing Foundation（CNCF）の設立が発表された」

## 7. Docker Swarm（2015年）

- **結論**: Docker Swarm「Classic」は2015年にパブリックベータが開始され、2015年11月にGA（一般提供）となった。Docker 1.12（2016年）ではSwarm Modeが組み込みで導入された。GA時点で1,000ノード、30,000以上のコンテナのスケールをサポート。
- **一次ソース**: Docker Blog; Bret Fisher, "Future of Docker Swarm"; Docker Docs, "Swarm mode"
- **URL**: <https://docs.docker.com/engine/swarm/>, <https://www.bretfisher.com/the-future-of-docker-swarm/>
- **注意事項**: Swarm ClassicとSwarm Mode（Docker 1.12組み込み）は異なるもの。記事では両者の区別を明記する。
- **記事での表現**: 「2015年にDocker Swarmが登場し、2016年のDocker 1.12ではSwarm Modeとしてエンジンに組み込まれた」

## 8. Apache Mesos/Marathon

- **結論**: Apache Mesosは2009年にUC BerkeleyのRAD Labで、PhD学生のBenjamin Hindman、Andy Konwinski、Matei Zaharia、教授Ion Stoicaにより開発が始まった。当初はNexusという名前だったが、名前の衝突によりMesosに改名。HotCloud '09で発表。Marathonはフレームワーク（コンテナオーケストレーション）として、Tobias KnaupとFlorian LeibertがMesosphere社で開発。2014年にDocker対応。
- **一次ソース**: Wikipedia, "Apache Mesos"; GitHub, d2iq-archive/marathon
- **URL**: <https://en.wikipedia.org/wiki/Apache_Mesos>, <https://github.com/d2iq-archive/marathon>
- **注意事項**: Andy KonwinskiはMesosとOmega論文の両方に関わっている。Matei ZahariaはApache Sparkの創設者でもある。
- **記事での表現**: 「Apache Mesosは2009年にUC BerkeleyのRAD Labで生まれた。Marathonはその上でコンテナオーケストレーションを実現するフレームワークだった」

## 9. マネージドKubernetes: GKE、AKS、EKS

- **結論**: GKE（Google Kubernetes Engine、当初はGoogle Container Engine）は2015年にローンチされ、最初のマネージドKubernetesサービスとなった。AKS（Azure Kubernetes Service）は2017年10月にプレビュー版公開、2018年6月にGA。EKS（Amazon Elastic Kubernetes Service）は2018年6月にGA。AKSとEKSはほぼ同時期にGAとなった。
- **一次ソース**: Pluralsight, "AKS vs EKS vs GKE"; InfoQ, "Microsoft Releases Preview of AKS", October 2017; InfoQ, "AKS Is Now Generally Available", June 2018; Wikipedia, "Kubernetes"
- **URL**: <https://www.pluralsight.com/resources/blog/cloud/aks-vs-eks-vs-gke-managed-kubernetes-services-compared>, <https://www.infoq.com/news/2017/10/azure-kubernetes-aks/>, <https://www.infoq.com/news/2018/06/kubernetes-microsoft-aks/>
- **注意事項**: ブループリントでは「EKS（2018年）、GKE（2015年）、AKS（2017年）」としているが、AKSの2017年はプレビュー版であり、GAは2018年6月。記事ではプレビューとGAの違いを明記する。
- **記事での表現**: 「GKE（2015年）、AKS（2017年プレビュー、2018年GA）、EKS（2018年GA）と、主要クラウドベンダーがマネージドKubernetesを提供した」

## 10. Kubernetesの宣言的設計・Reconciliation Loop

- **結論**: Kubernetesの設計哲学の核心は「宣言的設定（Declarative Configuration）」と「Reconciliation Loop（調整ループ）」にある。ユーザーはリソースマニフェストで望ましい状態（Desired State）を宣言し、コントローラが実際の状態（Actual State）との差分を検出して修正し続ける。コントローラは終了しないループ（Control Loop）で、APIサーバからの変更を監視し、ワークキューに入れ、Reconcile関数を呼び出す。失敗時は指数バックオフで再キューする。この「Record of Intent」パターンにより、インフラは「手続き的な指示」ではなく「あるべき状態の宣言」で管理される。
- **一次ソース**: Kubernetes Official Documentation, "Controllers"; ACM Queue, "Borg, Omega, and Kubernetes", 2016
- **URL**: <https://kubernetes.io/docs/concepts/architecture/controller/>, <https://queue.acm.org/detail.cfm?id=2898444>
- **注意事項**: 宣言的設計はKubernetes固有ではなく、CFEngine、Puppet等の構成管理ツールに先例がある。ただしKubernetesが大規模に普及させた。
- **記事での表現**: 「Kubernetesの設計の核心は、宣言的設定とReconciliation Loopにある。ユーザーは望ましい状態を宣言し、コントローラがその状態に近づけるよう自律的に動作し続ける」

## 11. GKEの正式名称変遷

- **結論**: 2015年のサービス開始時の名称は「Google Container Engine」で、2017年11月に「Google Kubernetes Engine」にリブランドされた。略称のGKEは変わらず。
- **一次ソース**: Wikipedia, "Google Kubernetes Engine"; Google Cloud Blog
- **URL**: <https://en.wikipedia.org/wiki/Kubernetes>
- **注意事項**: 記事ではリブランド後の名称「Google Kubernetes Engine（GKE）」を使用する。
- **記事での表現**: 「Google Container Engine（後にGoogle Kubernetes Engineにリブランド、GKE）」
