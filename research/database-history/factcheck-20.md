# ファクトチェック記録：第20回「ベクトルDBとAI時代のデータ管理」

調査日：2026-02-22

---

## 1. Pineconeの設立と歴史

- **結論**: Pineconeは2019年にEdo Libertyによって設立された。LibertyはAWS研究ディレクター兼Amazon AI Labs責任者を務めた人物。2021年1月にパブリックベータとして公開され、シード資金1,000万ドル（Wing Venture Capital主導）を調達。2023年4月にAndreessen Horowitz主導のSeries Bで1億ドルを調達し、評価額7億5,000万ドルに達した
- **一次ソース**: Pinecone公式サイト; TechCrunch "Pinecone drops $100M investment on $750M valuation", 2023年4月
- **URL**: <https://www.pinecone.io/company/> / <https://techcrunch.com/2023/04/27/pinecone-drops-100m-investment-on-750m-valuation-as-vector-database-demand-grows/>
- **注意事項**: Libertyの肩書は「Amazon AI VP」ではなく「Director of Research at AWS / Head of Amazon AI Labs」が正確。2025年にはLibertyがCEOからChief Scientistに移行しAsh AshutoshがCEOに就任
- **記事での表現**: 「Pineconeは2019年、AWSの研究ディレクターを務めたEdo Libertyによって設立された。2021年1月にパブリックベータとして公開され、2023年4月にはSeries Bで1億ドルを調達した」

---

## 2. Weaviateの設立と歴史

- **結論**: Weaviateは2016年にオランダのBob van Luijtが開発を開始。Google I/O 2016でのAI-first宣言に触発された。共同創業者Etienne Dilockerとともにベクトル埋め込みをファーストクラス市民とするデータベースを構築。2020年1月にv1.0をリリース。2023年4月にIndex Ventures主導のSeries Bで5,000万ドルを調達
- **一次ソース**: Weaviate Blog "The History of Weaviate"; PRNewswire "Weaviate Raises $50 Million Series B Funding", 2023年4月
- **URL**: <https://weaviate.io/blog/history-of-weaviate> / <https://www.prnewswire.com/news-releases/weaviate-raises-50-million-series-b-funding-to-meet-soaring-demand-for-ai-native-vector-database-technology-301803296.html>
- **注意事項**: 開発開始は2016年だが法人としてのSeMI Technologiesは2018年設立
- **記事での表現**: 「Weaviateは2016年、オランダのBob van Luijtが開発を開始したオープンソースのベクトル検索エンジンで、2020年1月にv1.0をリリースした」

---

## 3. Milvusの設立と歴史

- **結論**: MilvusはZilliz社（2017年にCharles Xieが設立）が開発したオープンソースベクトルデータベース。2019年11月にApache 2.0ライセンスでオープンソース公開。2020年3月にLF AI & Data Foundation（Linux Foundation傘下）に加入。2022年1月にクラウドネイティブアーキテクチャのMilvus 2.0 GAをリリース
- **一次ソース**: Milvus Wikipedia; TechCrunch "Zilliz raises $60M, relocates to SF", 2022年8月
- **URL**: <https://en.wikipedia.org/wiki/Milvus_(vector_database)> / <https://techcrunch.com/2022/08/24/zilliz-the-startup-behind-the-milvus-open-source-vector-database-for-ai-applications-raises-60m-and-relocates-to-sf/>
- **注意事項**: Milvus 2.0にはRC版（2021年6月）とGA版（2022年1月）の2つの日付がある
- **記事での表現**: 「Milvusは、2017年設立のZilliz社が開発し、2019年11月にオープンソース公開したベクトルデータベースである。LF AI & Data Foundationに加入し、2022年1月にMilvus 2.0 GAをリリースした」

---

## 4. Qdrantの設立と歴史

- **結論**: Qdrantは2021年にベルリンでAndre ZayarniとAndrey Vasnetsovが設立。Vasnetsovは2020年中頃からRustでの開発を開始し、2021年5月にGitHubで初版を公開。2024年1月にSpark Capital主導のSeries Aで2,800万ドルを調達
- **一次ソース**: Qdrant公式 "About Us"; TechCrunch "Open source vector database startup Qdrant raises $28M", 2024年1月
- **URL**: <https://qdrant.tech/about-us/> / <https://techcrunch.com/2024/01/23/qdrant-open-source-vector-database/>
- **注意事項**: 法人設立は2021年10月。GitHubでの初公開は2021年5月
- **記事での表現**: 「Qdrantは2021年、ベルリンでAndre ZayarniとAndrey Vasnetsovが設立したRust製のオープンソースベクトルデータベースである」

---

## 5. Chromaの設立と歴史

- **結論**: Chromaは2022年4月にJeff HuberとAnton Troynikovがサンフランシスコで設立。2022年10月にGitHubで初リリース。2023年4月にシードラウンドで1,800万ドルを調達（Quiet Capital主導）。開発者体験を重視したオープンソースベクトルデータベース
- **一次ソース**: SiliconANGLE "Chroma bags $18M", 2023年4月; Chroma公式ドキュメント
- **URL**: <https://siliconangle.com/2023/04/06/chroma-bags-18m-speed-ai-models-embedding-database/> / <https://docs.trychroma.com/about>
- **注意事項**: LLM向けに最適化された設計が差別化要因
- **記事での表現**: 「Chromaは2022年、Jeff HuberとAnton Troynikovが設立したオープンソースベクトルデータベースで、LLM時代の開発者体験を重視している」

---

## 6. pgvectorの歴史

- **結論**: pgvectorはAndrew Kaneによって開発され、2021年4月20日にバージョン0.1.0が初リリースされたPostgreSQL拡張。PostgreSQL 13以上をサポートし、HNSWおよびIVFFlatインデックスに対応
- **一次ソース**: pgvector GitHubリポジトリ; PostgreSQL公式ニュース
- **URL**: <https://github.com/pgvector/pgvector> / <https://www.postgresql.org/about/news/pgvector-080-released-2952/>
- **注意事項**: 既存PostgreSQLインフラを持つ組織にとって専用ベクトルDBの代替となりうる
- **記事での表現**: 「pgvectorは2021年4月にAndrew Kaneが公開したPostgreSQL拡張で、既存のリレーショナルデータベース上でベクトル類似度検索を実現する」

---

## 7. HNSWアルゴリズム

- **結論**: HNSWアルゴリズムは、Yu. A. MalkovとD. A. Yashununによる論文 "Efficient and robust approximate nearest neighbor search using Hierarchical Navigable Small World graphs" で提案。2016年にarXiv投稿（arXiv:1603.09320）、2018年にIEEE Transactions on Pattern Analysis and Machine Intelligence (TPAMI)に掲載
- **一次ソース**: Malkov, Yu. A. and Yashunin, D. A., IEEE TPAMI, 2018, Vol.42, No.4, pp.824-836
- **URL**: <https://arxiv.org/abs/1603.09320>
- **注意事項**: arXiv投稿は2016年、査読付きジャーナル掲載は2018年
- **記事での表現**: 「MalkovとYashununが2016年に提案し2018年にIEEE TPAMIに掲載されたHNSWは、階層的なナビガブルスモールワールドグラフを構築する近似最近傍探索手法である」

---

## 8. IVF（Inverted File Index）によるANN探索

- **結論**: IVFを近似最近傍探索に応用する手法は、Herve Jegou、Matthijs Douze、Cordelia Schmidによる論文 "Product Quantization for Nearest Neighbor Search"（IEEE TPAMI, 2011, Vol.33, No.1, pp.117-128）で体系化された。空間をボロノイセルに分割し逆ファイルインデックスを構築、プロダクト量子化（PQ）と組み合わせて大規模ベクトル検索を効率化。FAISSの基盤技術
- **一次ソース**: Jegou, H., Douze, M., and Schmid, C., IEEE TPAMI, 2011
- **URL**: <https://ieeexplore.ieee.org/document/5432202/>
- **注意事項**: 著者全員はINRIA所属。IVFの概念自体は情報検索分野で古くから存在するが、ANN探索への応用とPQの組み合わせはこの論文が確立
- **記事での表現**: 「Jegou、Douze、Schmidが2011年に発表したプロダクト量子化論文は、IVFとPQを組み合わせた大規模ベクトル検索の基盤を確立した」

---

## 9. OpenAI Embeddings APIの公開

- **結論**: OpenAIは2022年1月25日に初のEmbeddings APIを公開。2022年12月にtext-embedding-ada-002をリリースし、5モデルを1つに統合、99.8%のコスト削減を実現。2024年1月にtext-embedding-3-small/largeをリリース。ChatGPT公開（2022年11月）と近い時期に起き、RAGパターンの普及とともにベクトルDB市場が急成長した
- **一次ソース**: OpenAI Blog "New and improved embedding model", 2022年12月; OpenAI Blog "New embedding models and API updates", 2024年1月
- **URL**: <https://openai.com/index/new-and-improved-embedding-model/> / <https://openai.com/index/new-embedding-models-and-api-updates/>
- **注意事項**: text-embedding-ada-002の登場がベクトルDB需要爆発の直接的トリガー
- **記事での表現**: 「2022年12月、OpenAIがtext-embedding-ada-002をリリースし、99.8%のコスト削減を実現した。このモデルがベクトルデータベース需要の爆発的成長を牽引した」

---

## 10. k-NNとANN探索の学術的背景

- **結論**: 1998年、Piotr IndykとRajeev MotwaniがSTOC 1998で "Approximate Nearest Neighbors: Towards Removing the Curse of Dimensionality" を発表し、Locality-Sensitive Hashing（LSH）の概念を導入。近似率cを許容することで、高次元空間における劣線形時間のクエリを実現するANN探索の理論的基盤を築いた
- **一次ソース**: Indyk, P. and Motwani, R., STOC 1998, pp.604-613
- **URL**: <https://dl.acm.org/doi/10.1145/276698.276876>
- **注意事項**: LSHの後、グラフベース手法（NSW, HNSW）やツリーベース手法（Annoy等）が実用面で優勢に
- **記事での表現**: 「1998年、IndykとMotwaniはLocality-Sensitive Hashing（LSH）を導入し、高次元空間における近似最近傍探索の理論的基盤を築いた」

---

## 11. RAG（Retrieval-Augmented Generation）

- **結論**: RAGはPatrick Lewisらによる論文 "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks" で確立。2020年5月にarXiv投稿（arXiv:2005.11401）、NeurIPS 2020で発表。著者はFacebook AI Research（現Meta AI）所属。事前学習済みモデルに外部知識の検索を組み合わせる手法
- **一次ソース**: Lewis, P. et al., NeurIPS 2020
- **URL**: <https://arxiv.org/abs/2005.11401>
- **注意事項**: RAGの概念自体は検索と生成の組み合わせとして以前から存在したが、用語と枠組みを確立したのがこの論文
- **記事での表現**: 「RAGは、2020年にFacebook AI ResearchのPatrick Lewisらが NeurIPS 2020で発表した論文で確立された手法である」

---

## 12. ベクトルDB市場の成長と動向（2023-2025年）

- **結論**: ベクトルデータベース市場は2023年に約16億ドル規模、2030年には70億ドル超の予測（CAGR約24%、Grand View Research）。2023年に主要各社が大型調達を実施——Pinecone 1億ドル、Weaviate 5,000万ドル、Chroma 1,800万ドル。RAGは2025年時点で企業AI実装の51%を占める。Oracle等の既存大手もベクトル検索機能を統合
- **一次ソース**: Grand View Research "Vector Database Market Size, Share & Trends Report, 2030"
- **URL**: <https://www.grandviewresearch.com/industry-analysis/vector-database-market-report>
- **注意事項**: 市場規模データはリサーチ会社により幅がある（CAGR 23.7%〜27.5%）
- **記事での表現**: 「ベクトルデータベース市場は2023年に約16億ドル規模となり、2030年には70億ドル超に達すると予測されている」
