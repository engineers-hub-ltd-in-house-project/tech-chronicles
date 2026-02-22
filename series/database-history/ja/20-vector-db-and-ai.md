# データベースの地層

## ——RDBからNewSQLまで、データ管理50年の地殻変動

### 第20回：ベクトルDBとAI時代のデータ管理

**連載「データベースの地層——RDBからNewSQLまで、データ管理50年の地殻変動」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- SQLのLIKE検索では到達できない「意味の検索」——セマンティック検索とは何か
- Embeddingの仕組み——テキストや画像を高次元ベクトルに変換する技術の本質
- 近似最近傍探索（ANN）の理論的基盤——LSH（1998年）からHNSW（2016年）への進化
- 専用ベクトルDB（Pinecone, Qdrant, Milvus, Weaviate, Chroma）の設計思想と競争
- pgvectorによるRDB拡張——既存のPostgreSQLにベクトル検索を組み込む設計判断
- RAG（Retrieval-Augmented Generation）パターンとベクトルDBの関係

---

## 1. SQLのLIKEでは届かない場所

2023年の夏、私はあるプロジェクトでLLM（大規模言語モデル）を活用したチャットボットを構築していた。

社内ドキュメントの検索システムだ。数千件の技術文書、議事録、設計書をデータベースに格納し、ユーザーの質問に対して関連するドキュメントを検索し、その内容をもとにLLMが回答を生成する。いわゆるRAG（Retrieval-Augmented Generation）パターンである。

最初の実装は素朴だった。PostgreSQLのテキスト検索を使い、ユーザーの質問からキーワードを抽出し、`LIKE`句や全文検索インデックス（`tsvector`/`tsquery`）でドキュメントを検索する。

```sql
-- 素朴なキーワード検索
SELECT title, content
FROM documents
WHERE content LIKE '%認証%' AND content LIKE '%JWT%'
ORDER BY updated_at DESC
LIMIT 5;
```

この検索は「認証」と「JWT」という単語が含まれるドキュメントを返す。だが問題はすぐに明らかになった。

ユーザーが「ログイン処理のセキュリティを強化するにはどうすればいいか」と質問したとする。この質問には「認証」も「JWT」も含まれていない。だが本来検索されるべきドキュメント——JWTのリフレッシュトークン設計や、OAuth 2.0のPKCE実装ガイド、セッション管理のベストプラクティス——には「ログイン処理のセキュリティ強化」という文字列は存在しない。キーワードが一致しないのだ。

逆に、「認証」という単語を含むが無関係なドキュメント——たとえばSSL証明書の認証局に関する記事——がヒットする。キーワードは一致しているが、意味は異なる。

ここに、キーワード検索の根本的な限界がある。キーワード検索は「文字列の一致」を探す。だが人間が求めているのは「意味の近さ」だ。「ログインのセキュリティ強化」と「JWTリフレッシュトークン設計」は、文字列としては全く異なるが、意味的には密接に関連している。

この「意味の近さ」による検索——セマンティック検索——を実現するために、私はベクトルデータベースの世界に足を踏み入れることになった。

あなたが今使っているデータベースで、「意味の近い」データを検索できるだろうか。SQLの`WHERE`句で表現できる条件は、等価、大小比較、パターンマッチ、範囲指定——すべて「構造化された値」に対する操作だ。だが「意味」は構造化できない。少なくとも、従来のリレーショナルモデルでは。

---

## 2. ベクトル検索の学術的系譜——次元の呪いとの戦い

### Embeddingという革命

セマンティック検索を可能にする鍵が、Embedding（埋め込み）という技術だ。

Embeddingとは、テキスト、画像、音声などの非構造化データを、固定長の数値ベクトル（浮動小数点数の配列）に変換する処理である。このベクトルは高次元空間上の一点を表す。そして重要な性質がある——意味的に近いデータは、ベクトル空間上でも近い位置に配置される。

```
Embeddingの概念

テキスト                    ベクトル（簡略化した3次元表現）
─────────────────────      ─────────────────────────────
"犬が公園で走る"        →  [0.82, 0.15, 0.63]
"猫が庭で遊ぶ"          →  [0.79, 0.18, 0.58]  ← 意味的に近い
"データベースの設計"     →  [0.12, 0.91, 0.34]  ← 意味的に遠い

実際のEmbeddingモデルは1536次元（ada-002）や
3072次元（text-embedding-3-large）のベクトルを生成する
```

「犬が公園で走る」と「猫が庭で遊ぶ」は、キーワードとしては一つも一致しない。だがEmbeddingベクトルとしては近い位置にある。両者が「動物が屋外で活動する」という意味を共有しているからだ。一方、「データベースの設計」は意味的に全く異なるため、ベクトル空間上でも遠い位置にある。

二つのベクトルの「近さ」を測る指標として、コサイン類似度がよく使われる。二つのベクトルがなす角度のコサインを計算し、1に近いほど類似、-1に近いほど非類似、0は無関係を示す。

```
コサイン類似度の直感的理解

        ↑ 次元2
        |
        |    ● B（類似度 高）
        |   /
        |  /  θ = 小さい → cos(θ) ≈ 1
        | /
        |/
   ─────●──────────→ 次元1
        A
        |\
        | \  θ = 大きい → cos(θ) ≈ 0
        |  \
        |   ● C（類似度 低）
        |

cos(A, B) = (A・B) / (||A|| × ||B||)

実際は1536次元以上の空間だが、原理は同じ
```

問題は、この類似度計算を大量のベクトルに対して効率的に行うことだ。100万件のドキュメントがあれば、100万個のベクトルすべてとの類似度を計算する必要がある。各ベクトルが1536次元なら、1回のクエリで15億回以上の浮動小数点演算が必要になる。線形探索（ブルートフォース）では、データ量に比例して検索時間が増大する。

### 次元の呪いとANN探索の誕生

高次元空間での効率的な最近傍探索は、計算幾何学における古典的な難問だ。

低次元（2次元、3次元）であれば、kd木（k-dimensional tree）のようなデータ構造で効率的な探索が可能だ。だが次元数が増えると、kd木の性能は急速に劣化する。これが「次元の呪い（Curse of Dimensionality）」と呼ばれる現象だ。高次元空間では、すべてのデータ点がほぼ等距離に配置される傾向があり、「近い」と「遠い」の区別が曖昧になる。

1998年、MITのPiotr IndykとスタンフォードのRajeev Motwaniは、ACM STOC（Symposium on Theory of Computing）で画期的な論文を発表した。「Approximate Nearest Neighbors: Towards Removing the Curse of Dimensionality」——次元の呪いを取り除くための近似最近傍探索。

IndykとMotwaniが導入した手法が、Locality-Sensitive Hashing（LSH、局所性鋭敏型ハッシュ）だ。核心的なアイデアは「正確な最近傍」を諦め、「近似的な最近傍」を許容することにある。近似率cを認めることで、高次元空間でも多項式空間・劣線形時間のクエリを実現した。

この「厳密解を諦めて近似解で妥協する」という発想の転換が、近似最近傍探索（ANN: Approximate Nearest Neighbor）研究の理論的基盤となった。完璧な答えを返す代わりに、「ほぼ正しい答え」を桁違いに速く返す。データベースの世界でいえば、第12回で語ったCAP定理と同じ構造だ——何かを諦めることで、別の何かを手に入れる。

### HNSWとIVF——実用的ANN探索の二大手法

LSHの理論的突破の後、実用的なANN探索アルゴリズムが次々と開発された。現在の主要ベクトルデータベースで広く採用されている二大手法が、HNSW（Hierarchical Navigable Small World）とIVF（Inverted File Index）だ。

**HNSW**は、MalkovとYashununが2016年にarXivに投稿し、2018年にIEEE TPAMIに掲載された論文で提案された手法である。「スモールワールドネットワーク」——6人の仲介者を経れば世界中の誰とでもつながれるという理論——をベクトル検索に応用した。

```
HNSWの階層構造（簡略図）

Layer 3 (最上位):  A ──────────── E
                   粗い接続、長距離ジャンプ

Layer 2:           A ──── C ──── E ──── G
                   中程度の接続

Layer 1:           A ─ B ─ C ─ D ─ E ─ F ─ G ─ H
                   密な接続、近距離ジャンプ

Layer 0 (最下位):  A B C D E F G H I J K L M N O P
                   全ノード、最も密な接続

検索の流れ:
1. Layer 3 から開始 → 最も近いノードへジャンプ
2. Layer 2 に降りる → より精密にジャンプ
3. Layer 1 に降りる → さらに精密に
4. Layer 0 で最終的な最近傍を特定

計算量: O(log n)  ← 線形探索の O(n) から劇的に改善
```

検索クエリが到着すると、最上位レイヤーから探索を開始する。粗い接続を使って大まかに近傍に移動し、下位レイヤーに降りるたびに精密に探索する。この階層的なアプローチにより、対数的な計算量スケーリングを実現する。第10回で語ったB+Treeインデックスが`O(log n)`で検索するのと、構造は異なるが発想は通じるものがある。

HNSWの利点は検索速度と精度の高さだ。欠点はインデックス構築に時間とメモリを要すること、そしてインデックスの動的な更新（挿入・削除）が完全に効率的ではないことだ。

**IVF**（Inverted File Index）は、INRIAのHerve Jegou、Matthijs Douze、Cordelia Schmidが2011年のIEEE TPAMI論文「Product Quantization for Nearest Neighbor Search」で体系化した手法だ。

```
IVFの構造（簡略図）

Step 1: ベクトル空間をクラスタに分割（ボロノイ分割）
┌──────────────────────────────────┐
│  ┌─────┐   ┌─────┐   ┌─────┐   │
│  │ C1  │   │ C2  │   │ C3  │   │
│  │●● ● │   │● ●  │   │ ● ●●│   │
│  │ ●   │   │ ●●  │   │●  ● │   │
│  └─────┘   └─────┘   └─────┘   │
│  ┌─────┐   ┌─────┐   ┌─────┐   │
│  │ C4  │   │ C5  │   │ C6  │   │
│  │ ●●  │   │● ● ●│   │ ●   │   │
│  │●  ● │   │  ●  │   │●● ●●│   │
│  └─────┘   └─────┘   └─────┘   │
└──────────────────────────────────┘

Step 2: 各クラスタに転置インデックスを構築
C1 → [vec_1, vec_5, vec_12, vec_45, ...]
C2 → [vec_3, vec_8, vec_22, ...]
C3 → [vec_7, vec_15, vec_31, ...]
...

Step 3: 検索時はクエリに最も近いクラスタのみを探索
Query → C2が最も近い → C2内のベクトルのみを比較
       （nprobe=3 なら C2, C5, C3 の3クラスタを探索）

全ベクトルの1/6〜1/2のみを探索 → 大幅な高速化
```

IVFはまずベクトル空間をk-meansクラスタリングで複数のセル（ボロノイセル）に分割する。検索時は、クエリベクトルに最も近いセルを特定し、そのセル内のベクトルのみを比較する。全ベクトルを探索する必要がないため、検索が高速化される。`nprobe`パラメータで探索するセル数を調整し、速度と精度のトレードオフを制御する。

IVFはさらにプロダクト量子化（PQ: Product Quantization）と組み合わせることで、メモリ使用量を劇的に削減できる。ベクトルを部分空間に分割し、各部分空間をコードブックで量子化する。1536次元の32ビット浮動小数点ベクトル（6144バイト）を、数十バイトに圧縮できる。Jegouらが所属していたINRIAの研究グループは、後にFacebook AI Research（現Meta AI）でFAISS（Facebook AI Similarity Search）ライブラリを開発し、これらのアルゴリズムを実装した。

HNSWとIVFは対立するものではなく、補完的だ。多くのベクトルデータベースは両方をサポートし、ユースケースに応じた選択を可能にしている。

---

## 3. ベクトルデータベースの群雄割拠——2019年からの爆発

### 専用ベクトルDB vs RDB拡張

ベクトル検索を実現するアプローチは、大きく二つに分かれる。専用のベクトルデータベースを新たに構築するか、既存のRDBMSにベクトル検索機能を拡張するか。

この二分法は、データベースの歴史の中で繰り返し現れるパターンだ。第16回で語った時系列DBやグラフDBと同じ構図である。汎用RDBMSでも時系列データやグラフデータを扱えるが、専用DBは特定のワークロードに最適化されている。ベクトルDBでも同じ問いが立つ——専用DBの性能を取るか、既存インフラとの統合を取るか。

### Pinecone——マネージドベクトルDBの先駆者

2019年、AWSの研究ディレクターを務めたEdo Libertyが、Pineconeを設立した。Libertyはイエール大学で計算機科学のPh.D.を取得し、Yahoo Research NYラボ長を経てAmazon AI Labsを率いた人物だ。学術界と産業界の両方でベクトル検索の課題を熟知していた。

Pineconeは2021年1月にパブリックベータとして公開された。完全マネージドのベクトルデータベースサービスだ。ユーザーはインフラを管理する必要がない。APIにベクトルを送信し、類似検索を行う。それだけだ。

Pineconeの設計判断は明確だ——運用の複雑さをゼロにする。インデックスの構築、シャーディング、レプリケーション、スケーリング——すべてPinecone側が管理する。前回語ったサーバレスDBの思想と通じるものがある。2023年4月、PineconeはAndreessen Horowitz主導のSeries Bで1億ドルを調達し、評価額は7億5,000万ドルに達した。

だがPineconeの「マネージド」モデルには批判もある。データをサードパーティのクラウドに預けることへのセキュリティ懸念。ベンダーロックインのリスク。そしてコスト——大規模なベクトルデータを扱う場合、Pineconeの従量課金は高額になりうる。

### Milvus——オープンソースの旗手

Pineconeが「マネージド」の道を選んだのに対し、オープンソースの道を選んだのがMilvusだ。

2017年にCharles Xieが設立したZilliz社は、2019年11月にMilvusをApache 2.0ライセンスでオープンソース公開した。2020年にはLF AI & Data Foundation（Linux Foundation傘下）に加入し、2022年1月にクラウドネイティブアーキテクチャのMilvus 2.0 GAをリリースした。

Milvus 2.0のアーキテクチャは、マイクロサービス指向だ。クエリ処理、データ挿入、インデックス構築、メタデータ管理がそれぞれ独立したコンポーネントとして動作し、Kubernetesで水平にスケールする。ストレージ層はオブジェクトストレージ（S3等）を利用し、コンピュートとストレージを分離している。前回語ったNeonのアーキテクチャと同じ設計原則だ。

### Qdrant——Rustの性能で勝負する

2021年、ベルリンでAndre ZayarniとAndrey Vasnetsovが設立したQdrantは、異なるアプローチで差別化を図った。Rustで書かれたベクトルデータベースだ。

VasnetsovはMail.ruグループやTinkoff Bankの検索部門長を務めた経歴を持ち、大規模検索システムの現場を知っている。2020年中頃からRustでの開発を開始し、2021年5月にGitHubで初版を公開した。

Rustを選んだ理由は性能だ。ガベージコレクションのオーバーヘッドがなく、メモリ安全性をコンパイル時に保証し、ゼロコスト抽象化により高レベルなコードでも低レベルの性能を発揮する。ベクトル検索はCPU集約的な処理であり、SIMDを活用した高速なベクトル距離計算が性能に直結する。

2024年1月、QdrantはSpark Capital主導のSeries Aで2,800万ドルを調達した。

### Weaviate——AIネイティブなデータベース

Weaviateは2016年にオランダのBob van Luijtが開発を開始した、最も歴史のあるベクトルデータベースの一つだ。Google I/O 2016でのSundar Pichai「mobile-firstからAI-firstへ」宣言に触発されたという。共同創業者のEtienne Dilockerとともに、ベクトル埋め込みをファーストクラス市民とするデータベースを構築した。

Weaviateの特徴は、Embeddingモデルとの統合をデータベース側で行うことだ。データを格納する際にEmbeddingモデルを指定すると、Weaviate自身がテキストをベクトルに変換する。ユーザーがEmbedding APIを別途呼び出す必要がない。OpenAI、Cohere、Hugging Face等の主要なEmbeddingモデルに対応し、モデルの切り替えもデータベース側で行える。

2020年1月にv1.0をリリースし、2023年4月にはIndex Ventures主導のSeries Bで5,000万ドルを調達した。

### Chroma——開発者体験という差別化

2022年、Jeff HuberとAnton Troynikovがサンフランシスコで設立したChromaは、最後発でありながら急速に支持を集めた。

Chromaの差別化要因は、圧倒的な開発者体験だ。Pythonの数行でベクトルデータベースが使える。

```python
import chromadb

# インメモリのChromaクライアント
client = chromadb.Client()

# コレクション（テーブルに相当）の作成
collection = client.create_collection("documents")

# ドキュメントの追加（Embedding自動生成）
collection.add(
    documents=["猫が庭で遊ぶ", "犬が公園で走る", "データベースの設計"],
    ids=["doc1", "doc2", "doc3"]
)

# セマンティック検索
results = collection.query(
    query_texts=["ペットの屋外活動"],
    n_results=2
)
# → ["猫が庭で遊ぶ", "犬が公園で走る"] が返る
```

この「手軽さ」は、MySQLがWeb時代に勝利した理由を彷彿とさせる。第8回で語ったように、技術的に「正しい」ものが普及するとは限らない。開発者が最初に触れるツール、プロトタイプを最速で作れるツールが、事実上の標準になることがある。

2023年4月、Chromaはシードラウンドで1,800万ドルを調達した。2022年10月の初リリースからわずか半年での大型調達だ。

### 2023年の投資集中——何が起きたのか

ここで一つの事実を指摘しておきたい。Pinecone Series B 1億ドル、Weaviate Series B 5,000万ドル、Chroma シード1,800万ドル——これらすべてが2023年4月に集中している。

何が起きたのか。二つの出来事が重なった。

一つ目は、2022年11月のChatGPTの公開だ。GPT-3.5をベースとしたチャットインターフェースは、LLMの可能性を世界に示した。だがLLMには「幻覚（Hallucination）」——事実に基づかない回答を生成する問題がある。この問題を軽減する手法として注目されたのがRAGだ。

RAG（Retrieval-Augmented Generation）は、2020年にFacebook AI Research（現Meta AI）のPatrick Lewisらが NeurIPS 2020で発表した論文「Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks」で確立された手法である。事前学習済みのモデルに外部知識の検索を組み合わせることで、幻覚を抑制し、最新の情報に基づいた回答を生成する。RAGの「検索」部分に、ベクトルデータベースが不可欠だった。

二つ目は、2022年12月のOpenAIによるtext-embedding-ada-002のリリースだ。従来5つに分かれていたEmbeddingモデルを1つに統合し、99.8%のコスト削減を実現した。Embeddingの生成コストが劇的に下がったことで、大量のテキストをベクトルに変換し、ベクトルデータベースに格納するワークフローが現実的になった。

ChatGPTの衝撃 + RAGパターンの注目 + Embeddingコストの劇的低下——この三つが同時期に重なり、ベクトルデータベース市場は爆発的に成長した。Grand View Researchによれば、ベクトルデータベース市場は2023年に約16億ドル規模となり、2030年には70億ドル超に達すると予測されている。

### pgvector——「新しいDBは要らない」という選択

専用ベクトルDBの群雄割拠が続く一方で、全く異なるアプローチも存在する。既存のPostgreSQLにベクトル検索機能を追加するpgvectorだ。

pgvectorは2021年4月にAndrew Kaneが公開したPostgreSQL拡張で、`CREATE EXTENSION vector`の一行で既存のPostgreSQLにベクトル型とベクトルインデックスを追加する。

```sql
-- pgvectorの有効化
CREATE EXTENSION vector;

-- ベクトルカラムを持つテーブルの作成
CREATE TABLE documents (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  embedding vector(1536)  -- 1536次元のベクトル
);

-- HNSWインデックスの作成
CREATE INDEX ON documents
  USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64);

-- ベクトル類似度検索
SELECT title, content,
       1 - (embedding <=> query_embedding) AS similarity
FROM documents
ORDER BY embedding <=> query_embedding  -- <=> はコサイン距離
LIMIT 5;
```

pgvectorの強みは、既存のPostgreSQLインフラとの統合にある。リレーショナルデータとベクトルデータを同一データベースで管理でき、JOINやWHERE句と組み合わせたフィルタリングが可能だ。トランザクション、バックアップ、レプリケーション——PostgreSQLの運用ノウハウがそのまま使える。

```sql
-- pgvectorの真価：構造化データとベクトル検索の組み合わせ
SELECT d.title, d.content,
       1 - (d.embedding <=> :query_embedding) AS similarity
FROM documents d
JOIN categories c ON d.category_id = c.id
WHERE c.name = 'セキュリティ'
  AND d.published_at > '2024-01-01'
ORDER BY d.embedding <=> :query_embedding
LIMIT 5;
```

このクエリは「セキュリティカテゴリの2024年以降の文書から、意味的に近いものを検索する」——ベクトル類似度検索とリレーショナルなフィルタリングの組み合わせだ。専用ベクトルDBでこの種のフィルタリングを行うには、メタデータフィルタ機能を使うか、アプリケーション側で後処理する必要がある。

一方、pgvectorの限界もある。専用ベクトルDBと比較して、大規模データ（数億〜数十億ベクトル）でのスケーラビリティ、インデックスの構築速度、メモリ効率で劣る場合がある。PostgreSQLの共有バッファとベクトルインデックスがメモリを奪い合う問題もある。

この「専用DB vs RDB拡張」の判断基準は、明確に整理できる。

```
専用ベクトルDB vs pgvector の設計判断

専用ベクトルDB（Pinecone, Qdrant, Milvus等）を選ぶ場合:
・ベクトル数が数千万〜数十億規模
・ベクトル検索がシステムの中核機能
・最高の検索性能（レイテンシ、スループット）が必要
・既存のRDBMSとは独立したインフラを許容できる

pgvectorを選ぶ場合:
・ベクトル数が数十万〜数百万規模
・既存のPostgreSQLインフラを活用したい
・リレーショナルデータとの結合（JOIN）が頻繁
・運用するデータベースの数を増やしたくない
・トランザクション保証が必要
```

私の経験では、多くのプロジェクト——特にRAGの初期実装やプロトタイプ——ではpgvectorで十分だ。数十万件のドキュメントに対するセマンティック検索なら、pgvectorは実用的な性能を発揮する。専用ベクトルDBが必要になるのは、データ量が数千万件を超えるか、ミリ秒単位のレイテンシが要求される場合だ。

この判断は、第8回で語ったMySQL vs PostgreSQLの構図と似ている。「どちらが優れているか」ではなく「何を優先するか」の問題だ。

---

## 4. ハイブリッド検索とRAGパターン——実装の現実

### ハイブリッド検索——ベクトルとキーワードの融合

実務でセマンティック検索を実装すると、ベクトル検索だけでは不十分な場面に遭遇する。

たとえば、ユーザーが「RFC 7519」と検索した場合、これはJWT（JSON Web Token）の仕様書の番号だ。ベクトル検索ではRFC番号という「固有名詞」を正確に捕捉できない可能性がある。Embeddingモデルは意味の類似性を捉えるが、特定の識別子やコードの完全一致は苦手だ。

逆に「トークンの安全な管理方法」のような質問では、キーワード検索よりベクトル検索が適している。

この問題に対する解がハイブリッド検索——ベクトル検索とキーワード検索を組み合わせる手法だ。

```
ハイブリッド検索の構造

ユーザークエリ: "RFC 7519のセキュリティ考慮事項"
      │
      ├──→ ベクトル検索
      │    Embeddingを生成 → コサイン類似度で検索
      │    結果: セキュリティ関連の文書（意味的に近い）
      │
      ├──→ キーワード検索（BM25等）
      │    "RFC" "7519" でインデックス検索
      │    結果: RFC 7519を含む文書（完全一致）
      │
      └──→ スコア統合（Reciprocal Rank Fusion等）
           両方の結果をランク統合
           → 最終的な検索結果
```

Reciprocal Rank Fusion（RRF）は、複数の検索結果リストを統合する手法だ。各結果のランク（順位）の逆数を合算し、最終的なスコアとする。ベクトル検索で上位かつキーワード検索でも上位の文書が、最終結果の上位に来る。

pgvectorとPostgreSQLの全文検索（`tsvector`/`tsquery`）を組み合わせれば、単一のデータベース内でハイブリッド検索を実現できる。

```sql
-- pgvectorでのハイブリッド検索（RRF方式）
WITH vector_search AS (
  SELECT id, title, content,
         ROW_NUMBER() OVER (
           ORDER BY embedding <=> :query_embedding
         ) AS vector_rank
  FROM documents
  ORDER BY embedding <=> :query_embedding
  LIMIT 20
),
keyword_search AS (
  SELECT id, title, content,
         ROW_NUMBER() OVER (
           ORDER BY ts_rank(tsv, query) DESC
         ) AS keyword_rank
  FROM documents,
       plainto_tsquery('japanese', :query_text) query
  WHERE tsv @@ query
  LIMIT 20
)
SELECT
  COALESCE(v.id, k.id) AS id,
  COALESCE(v.title, k.title) AS title,
  -- Reciprocal Rank Fusion
  COALESCE(1.0 / (60 + v.vector_rank), 0) +
  COALESCE(1.0 / (60 + k.keyword_rank), 0) AS rrf_score
FROM vector_search v
FULL OUTER JOIN keyword_search k ON v.id = k.id
ORDER BY rrf_score DESC
LIMIT 10;
```

### RAGパターンの全体像

ベクトルデータベースが最も広く使われているのが、RAG（Retrieval-Augmented Generation）パターンだ。改めて全体像を整理しよう。

```
RAGパターンのアーキテクチャ

【インデックス構築フェーズ】

ドキュメント群
  │
  ▼
チャンキング（文書をチャンクに分割）
  │  ・固定長（512トークン等）
  │  ・意味的区切り（段落、セクション）
  │  ・オーバーラップ付き分割
  ▼
Embedding生成
  │  ・OpenAI text-embedding-3-small
  │  ・Cohere embed-v3
  │  ・オープンソースモデル等
  ▼
ベクトルDB/pgvectorに格納
  ・ベクトル + メタデータ + 元テキスト


【クエリフェーズ】

ユーザーの質問
  │
  ▼
質問のEmbedding生成
  │
  ▼
ベクトルDB/pgvectorで類似検索
  │  ・上位k件のチャンクを取得
  ▼
コンテキスト構築
  │  ・検索結果をプロンプトに挿入
  ▼
LLMに送信
  │  ・「以下の情報をもとに回答してください」
  │  ・[検索結果のチャンク]
  │  ・[ユーザーの質問]
  ▼
回答生成
  ・ソース付きの回答
```

RAGの品質を左右する要因は、LLMの性能だけではない。チャンキングの粒度、Embeddingモデルの選択、検索のリコール（関連文書をどれだけ取り漏らさないか）、そしてプロンプト設計——これらすべてが回答の品質に影響する。私の実感としては、RAGの品質問題の大半は「検索の品質」に起因する。LLMに正しいコンテキストを渡せば、LLMは正しい回答を生成する。LLMに無関係なコンテキストを渡せば、LLMは無関係な回答を生成するか、幻覚を起こす。

つまり、RAGの核心はデータベースの問題なのだ。

---

## 5. ハンズオン: pgvectorでセマンティック検索を体験する

今回のハンズオンでは、PostgreSQL + pgvectorを使い、テキストデータに対するセマンティック検索を実装する。Docker環境で完結するため、外部サービスへの登録は不要だ。

### 演習概要

1. PostgreSQL + pgvectorをDockerで起動する
2. テキストデータを格納し、事前計算済みのEmbeddingベクトルを投入する
3. キーワード検索とセマンティック検索の結果を比較する
4. HNSWインデックスの効果を確認する
5. フィルタリング付きベクトル検索を実行する

### 環境構築

```bash
# handson/database-history/20-vector-db-and-ai/setup.sh を実行
bash setup.sh
```

### 演習1: PostgreSQL + pgvectorの起動と準備

```bash
# pgvector対応のPostgreSQLをDockerで起動
docker run -d \
  --name pgvector-handson \
  -e POSTGRES_PASSWORD=handson \
  -e POSTGRES_DB=vectordb \
  -p 5432:5432 \
  pgvector/pgvector:pg17

# 起動を待機
sleep 3

# 接続
docker exec -it pgvector-handson \
  psql -U postgres -d vectordb
```

```sql
-- pgvector拡張の有効化
CREATE EXTENSION vector;

-- テーブル作成（3次元の簡易ベクトルで体験）
CREATE TABLE tech_articles (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT NOT NULL,
  published_at DATE NOT NULL,
  embedding vector(3)  -- 簡易的な3次元ベクトル
);
```

ここでは説明のために3次元ベクトルを使う。実際のEmbeddingモデルは1536次元以上のベクトルを生成するが、原理は同じだ。

### 演習2: データ投入とセマンティック検索

```sql
-- 技術記事データの投入
-- embeddingは概念的な類似性を表す簡易ベクトル
-- 実際にはEmbedding APIで生成するが、ここでは手動設定
INSERT INTO tech_articles (title, content, category, published_at, embedding)
VALUES
  ('JWT認証の実装ガイド',
   'JWTを使ったステートレス認証の設計パターンとリフレッシュトークンの実装方法',
   'security', '2024-06-15',
   '[0.85, 0.12, 0.72]'),

  ('OAuth 2.0 PKCEフロー解説',
   'パブリッククライアントにおけるOAuth 2.0 PKCEフローの実装とセキュリティ考慮事項',
   'security', '2024-07-20',
   '[0.82, 0.15, 0.68]'),

  ('PostgreSQLインデックス設計',
   'B-Treeインデックスの構造と複合インデックスの最左一致の法則',
   'database', '2024-05-10',
   '[0.10, 0.88, 0.35]'),

  ('Docker Compose入門',
   '開発環境をDockerComposeで構築するベストプラクティス',
   'infrastructure', '2024-04-01',
   '[0.15, 0.30, 0.90]'),

  ('セッション管理のベストプラクティス',
   'Webアプリケーションにおけるセッション管理のセキュリティ対策',
   'security', '2024-08-05',
   '[0.80, 0.18, 0.65]'),

  ('Kubernetesネットワーキング入門',
   'Pod間通信とServiceの仕組みを理解する',
   'infrastructure', '2024-03-15',
   '[0.18, 0.25, 0.88]'),

  ('SSL/TLS証明書の仕組み',
   'SSL/TLS証明書の認証局と証明書チェーンの解説',
   'security', '2024-09-10',
   '[0.55, 0.20, 0.45]');


-- キーワード検索: "認証" を含む記事
SELECT title, content
FROM tech_articles
WHERE content LIKE '%認証%'
ORDER BY published_at DESC;
-- → JWT認証、SSL/TLS証明書がヒット
-- → OAuthやセッション管理は "認証" を含まないためヒットしない
```

```sql
-- セマンティック検索: "ログインのセキュリティ強化"
-- この概念に近いベクトルを仮定: [0.83, 0.14, 0.70]
SELECT title, content,
       1 - (embedding <=> '[0.83, 0.14, 0.70]') AS similarity
FROM tech_articles
ORDER BY embedding <=> '[0.83, 0.14, 0.70]'
LIMIT 5;
-- → JWT認証、OAuth PKCE、セッション管理が上位に
-- → "認証" というキーワードを含まないOAuthやセッション管理もヒットする
-- → SSL/TLS証明書は意味的に離れているため下位に
```

キーワード検索では「認証」という文字列の有無でしか判断できない。セマンティック検索では、「ログインのセキュリティ強化」という意味に近い記事を、キーワードに依存せずに検索できる。

### 演習3: インデックスの作成と効果

```sql
-- HNSWインデックスの作成
CREATE INDEX ON tech_articles
  USING hnsw (embedding vector_cosine_ops);

-- インデックスを使った検索
EXPLAIN ANALYZE
SELECT title,
       1 - (embedding <=> '[0.83, 0.14, 0.70]') AS similarity
FROM tech_articles
ORDER BY embedding <=> '[0.83, 0.14, 0.70]'
LIMIT 3;
-- 少量のデータではSeq Scanの方が速いが、
-- 数万件以上でHNSWインデックスの効果が顕著になる
```

### 演習4: フィルタリング付きベクトル検索

pgvectorの強みは、リレーショナルなフィルタリングとの組み合わせだ。

```sql
-- セキュリティカテゴリの2024年6月以降の記事から、意味的に近いものを検索
SELECT title, content, category, published_at,
       1 - (embedding <=> '[0.83, 0.14, 0.70]') AS similarity
FROM tech_articles
WHERE category = 'security'
  AND published_at >= '2024-06-01'
ORDER BY embedding <=> '[0.83, 0.14, 0.70]'
LIMIT 3;
-- → セキュリティカテゴリに絞り込んだ上で、意味的に近い記事を検索
```

このクエリは、SQLの`WHERE`句によるフィルタリングとベクトル類似度検索を一つのクエリで実行している。専用ベクトルDBでは、メタデータフィルタとベクトル検索の組み合わせに制約がある場合もあるが、pgvectorではPostgreSQLの全機能を活用したフィルタリングが可能だ。

### 後片付け

```bash
docker stop pgvector-handson && docker rm pgvector-handson
```

---

## 6. 「SQLでは届かない検索」とデータベースの未来

第20回を振り返ろう。

**セマンティック検索は、データベースの「検索」の概念を拡張した。** キーワードの一致ではなく、意味の近さで検索する。この能力を支えるのがEmbedding技術であり、高次元ベクトル空間での効率的な最近傍探索（ANN）だ。1998年のIndykとMotwaniによるLSHの理論的基盤から、2016年のMalkovとYashununによるHNSW、2011年のJegouらによるIVF+PQ——ANN探索のアルゴリズムは20年以上かけて成熟してきた。

**ベクトルデータベース市場は2022-2023年に爆発的に成長した。** ChatGPTの衝撃、RAGパターンの普及、OpenAIのtext-embedding-ada-002によるEmbeddingコストの劇的低下——これらが同時に起き、Pinecone、Milvus、Qdrant、Weaviate、Chromaといった専用ベクトルDBが急成長した。2023年だけでPinecone（1億ドル）、Weaviate（5,000万ドル）、Chroma（1,800万ドル）が大型調達を実施している。

**専用ベクトルDB vs pgvectorは「どちらが優れているか」ではなく「何を優先するか」の判断だ。** 大規模データ×高性能を求めるなら専用ベクトルDB。既存PostgreSQLインフラの活用×リレーショナルデータとの統合を求めるならpgvector。多くのプロジェクトではpgvectorで十分であり、専用ベクトルDBが必要になるのはデータ量が数千万件を超えるか、ミリ秒単位のレイテンシが要求される場合だ。

**RAGの品質は「検索の品質」に左右される。** LLMに正しいコンテキストを渡せば正しい回答が返る。RAGの核心はデータベースの問題だ。ハイブリッド検索（ベクトル検索 + キーワード検索）の組み合わせが、実務上の精度向上に効果的である。

冒頭の問いに戻ろう。「AIの時代、データの検索は根本的に変わるのか？」

私の答えは、「変わる。だがSQLが不要になるわけではない」だ。

セマンティック検索は、SQLの`LIKE`や全文検索では到達できない「意味の近さ」による検索を可能にした。これはデータベースの歴史における明確な転換点だ。だが同時に、構造化データへの正確なフィルタリング——特定のカテゴリ、日付範囲、数値条件による絞り込み——はSQLの得意技であり、ベクトル検索で代替するものではない。

pgvectorのようなRDB拡張が示しているのは、「ベクトル検索はSQLの敵ではなく、SQLの拡張である」という可能性だ。`SELECT`文の中にベクトル類似度の`ORDER BY`が共存する。リレーショナルモデルの50年の蓄積と、ベクトル検索の新しい能力が、同じクエリの中で融合する。

次回「データレイクとLakehouse——分析基盤の進化」では、トランザクション処理と分析処理という、データベースのもう一つの大きな分断に目を向ける。OLTPとOLAPの分離はなぜ生まれ、Lakehouseアーキテクチャはどうやってこの分断を乗り越えようとしているのか。DuckDBやApache Icebergの設計思想とともに考える。

---

### 参考文献

- Indyk, P. and Motwani, R., "Approximate Nearest Neighbors: Towards Removing the Curse of Dimensionality", STOC 1998. <https://dl.acm.org/doi/10.1145/276698.276876>
- Jegou, H., Douze, M., and Schmid, C., "Product Quantization for Nearest Neighbor Search", IEEE TPAMI, 2011. <https://ieeexplore.ieee.org/document/5432202/>
- Malkov, Yu. A. and Yashunin, D. A., "Efficient and robust approximate nearest neighbor search using Hierarchical Navigable Small World graphs", IEEE TPAMI, 2018. <https://arxiv.org/abs/1603.09320>
- Lewis, P. et al., "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks", NeurIPS 2020. <https://arxiv.org/abs/2005.11401>
- OpenAI, "New and improved embedding model", 2022. <https://openai.com/index/new-and-improved-embedding-model/>
- pgvector GitHub Repository. <https://github.com/pgvector/pgvector>
- Pinecone, "Announcing the Pinecone Vector Database". <https://www.pinecone.io/blog/announcing-vector-database/>
- Weaviate, "The History of Weaviate". <https://weaviate.io/blog/history-of-weaviate>
- Grand View Research, "Vector Database Market Size, Share & Trends Report, 2030". <https://www.grandviewresearch.com/industry-analysis/vector-database-market-report>

---

**次回予告：** 第21回「データレイクとLakehouse——分析基盤の進化」では、トランザクション処理と分析処理の分離と統合を語る。OLTP用データベースから分析用データウェアハウスへのETLパイプライン、Hadoop/HDFSとデータレイクの栄枯盛衰、そしてDelta Lake・Apache Icebergによる Lakehouseアーキテクチャの台頭とDuckDBのインプロセス分析を考える。
