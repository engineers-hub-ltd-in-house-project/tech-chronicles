# フレームワークという幻想

## ——Webアプリケーションの「当たり前」を疑う

### 第1回：フレームワークなしでWebを作れるか

**連載「フレームワークという幻想——Webアプリケーションの『当たり前』を疑う」**
**著：佐藤裕介（Engineers Hub株式会社 CEO / Technical Lead）**

---

**この回で学べること：**

- フレームワークが「空気」になった世界で、私たちが見失っているもの
- Webアプリケーションの本質的な4つの構成要素——HTTPリクエストの受信、ルーティング、ビジネスロジック、レスポンスの生成
- CGIからNext.jsまで、30年のWebフレームワーク史の全体像
- Node.jsの`http`モジュールだけでWebアプリケーションを構築する方法

---

## 1. 「Next.jsなしでWebアプリを作って」

私は2024年のある日、社内の若手エンジニアにこう言った。「Next.jsを使わずに、TodoアプリのAPIを作ってくれないか」

彼は実務経験3年ほどで、React + Next.jsの案件をいくつもこなしてきた有能なエンジニアだった。TypeScriptは堪能で、App Routerの設計もServer Componentsの活用も的確にこなす。コードレビューで私が指摘することは少なかった。

だが、その日の彼の反応は忘れられない。

「Next.jsを使わないって、どういう意味ですか？」

最初、彼は質問の意図がわからなかったのだと思う。「Expressを使うということですか？」と聞き返してきた。

「いや、フレームワークもライブラリも使わない。Node.jsの標準モジュールだけで。`http`モジュールは使っていい」

彼はしばらく黙った。それから、正直にこう言った。「やったことがないです。`http.createServer`は知ってますけど、ルーティングとかJSON解析とか、自分で書いたことはないです」

私は彼を責めているのではない。むしろ、これは彼の世代にとって自然なことだ。彼がWeb開発を学び始めた2020年代、`npx create-next-app`はWeb開発の「スタート地点」だった。プロジェクトを初期化すれば、ルーティングはファイルシステムベースで自動生成され、APIルートは`app/api/`以下にファイルを置くだけで動く。HTTPリクエストのパースもレスポンスの組み立ても、フレームワークが全部やってくれる。

彼が知らないのは当然だ。教わっていないのだから。

だが、ここで考えてほしい。Stack Overflow Developer Survey 2024によれば、プロフェッショナル開発者の41.6%がReactを、40.7%がNode.jsを、18.6%がNext.jsを使っている。65,000人以上が回答したこの調査は、Web開発の現在地を映す鏡だ。Reactが4割を超え、Next.jsがExpressと肩を並べる世界——これは、フレームワークの存在を前提としなければ成り立たない世界である。

2025年2月、Reactチームはcreate-react-appを正式に非推奨とした。新規プロジェクトにはNext.jsなどのフレームワークの使用を推奨している。これは象徴的な出来事だ。Reactという「ライブラリ」ですら、単体で使うことはもう推奨されない。フレームワークの上に乗ることが前提になったのである。

フレームワークなしのWeb開発という選択肢は、公式に退場した。

だが、本当にそれでいいのだろうか。フレームワークが何をしているのかを知らないまま、フレームワークの上でコードを書き続ける。それは「使っている」のか、「依存している」のか。

この連載は、その問いから始まる。CGIの一行からNext.jsのApp Routerまで、30年のWebアプリケーション史を24回にわたって辿り直す。「フレームワークは答えではない。『HTTPリクエストをどう処理するか』という問いに対する、時代ごとのひとつの解である」——この一文を背骨として、フレームワークの本質を掘り下げていく。

あなたが今使っているフレームワーク——Next.jsでもRailsでもDjangoでもいい——を取り除いたとき、あなたはWebアプリケーションを作れるだろうか。HTTPリクエストを自分でパースし、ルーティングを自分で実装し、データベースに自分でクエリを投げ、HTMLを自分で組み立てて返す。できるだろうか。

できなくても恥ではない。だが、できないことを自覚しているかどうかは、エンジニアとしての分水嶺になる。

---

## 2. Webアプリケーションの「原型」を知る——CGIからNext.jsまでの30年

フレームワークの正体を理解するためには、フレームワークが存在しなかった時代を知る必要がある。Webアプリケーションの歴史は、「HTTPリクエストをどう処理するか」という問いに対する試行錯誤の歴史だ。

### CGI——すべてはプロセスフォークから始まった

1993年、NCSAのRob McCoolがCommon Gateway Interface（CGI）の仕様を策定した。当初はCommon Gateway Protocolと呼ばれていたこの仕様は、同年12月にCGIに改称され、Webの歴史を決定的に変えた。

CGIの仕組みは原始的なまでにシンプルだった。Webサーバがリクエストを受け取ると、外部プログラム（CGIスクリプト）を新しいプロセスとして起動する。リクエストの情報は環境変数（`QUERY_STRING`、`REQUEST_METHOD`、`CONTENT_LENGTH`など）を通じて渡され、スクリプトの標準出力がそのままHTTPレスポンスになる。

```perl
#!/usr/bin/perl
print "Content-type: text/html\n\n";
print "<html><body>Hello, World!</body></html>";
```

たったこれだけで、動的なWebページが生成される。この素朴さの中に、Webアプリケーションの本質がすべて詰まっている。HTTPリクエストを受け取り、何らかの処理をして、HTTPレスポンスを返す。フレームワークが何千行、何万行のコードで実現していることの原型が、ここにある。

だが、CGIには致命的な問題があった。リクエストのたびにプロセスを起動するコストだ。PerlやPythonのインタプリタを毎回起動するオーバーヘッドは、同時接続が増えると壊滅的なパフォーマンス劣化を招いた。

この問題に対する解決策は複数同時に現れた。1996年、Doug MacEachernがmod_perlを開発し、PerlインタプリタをApacheのプロセスに組み込んだ。同年、Open Market社がFastCGIを公開し、CGIスクリプトを常駐プロセスとして動かすアプローチを提案した。どちらも「プロセスの起動コストをどう削減するか」という同じ問いに対する異なる解だった。

CGIの仕様が正式にRFC 3875として文書化されたのは2004年のことである。1993年の誕生から11年——それほど長い間、CGIは事実上の標準として、正式な規格なしに機能し続けた。

### サーバサイド言語の時代——PHP、Java Servlet、そしてテンプレートエンジン

1990年代後半から2000年代前半にかけて、Webアプリケーション開発は「どの言語でCGIを書くか」から「言語自体がWebに最適化される」段階へと移行した。

私は2002年頃、素のPHPでWebシステムを開発していた。フレームワークなし、テストなし、`<?php ?>`タグの中にHTMLとSQLが混在するコード。今にして思えば惨憺たるものだが、あれが当時の「普通」だった。PHPは1995年にRasmus Lerdorfが個人用ツール（Personal Home Page Tools）として作ったものが、1998年のPHP 3（Zeev SuraskiとAndi Gutmansが参加）で本格的な言語に進化し、Webの民主化を牽引した。

一方、エンタープライズの世界ではJava Servlet API（1997年、Sun Microsystems）がWeb開発に参入していた。`HttpServletRequest`と`HttpServletResponse`という抽象化は、CGIの環境変数よりもはるかに構造化されていたが、web.xmlの冗長な設定やWARファイルのデプロイなど、PHPの手軽さとは対極にあった。

この時代に生まれたもう一つの重要な概念がテンプレートエンジンだ。PHPのコード中にHTMLが混在する地獄を解消するため、Smarty（2001年、PHP）やVelocity（2001年、Java/Apache）がロジックとプレゼンテーションの分離を試みた。この「分離」への執念は、後にMVCフレームワークの基盤となる。

### Rails以後——フレームワークの爆発

2005年、Web開発の景色が一変した。

David Heinemeier Hansson（DHH）がブラジルの第6回FISLで録音した音声に合わせて、「15分でブログを作る」スクリーンキャストを公開した。Ruby on Railsを使って、スキャフォールド一発でCRUDアプリケーションが生成される。私がPHPで何日もかけて書いていたコードが、ものの数秒で出来上がる。

衝撃だった。だが同時に、警報が鳴った。「この便利さの裏で何が起きているのかを理解しないまま使ったら、いずれ痛い目に遭う」と。

Rails 1.0は2005年12月にリリースされた。Convention over Configuration、Don't Repeat Yourself（DRY）、ActiveRecordパターン——これらの思想は、Web開発のフレームワーク設計に決定的な影響を与えた。

同じ2005年7月、カンザス州の新聞社Lawrence Journal-Worldから生まれたDjangoが公開された。Adrian HolovatyとSimon Willisonが開発した「バッテリー同梱」のPythonフレームワークは、Railsとは異なるアプローチで同じ問題に挑んでいた。

この後の歴史は雪崩のようだ。CakePHP、Symfony、Spring Boot、Express.js——各言語コミュニティが「Railsの何を取り入れ、何を拒否するか」を模索し、フレームワークの群雄割拠が始まった。

### フロントエンド革命——jQueryからReactへ

2005年2月18日、Jesse James Garrettが「Ajax: A New Approach to Web Applications」を発表し、Ajaxという用語を生み出した。Google Maps（2005年）やGmail（2004年）がページ遷移のないWebアプリケーションの可能性を証明し、フロントエンドは急速に複雑化していく。

2006年1月、John ResigがjQueryをリリースした。ブラウザ互換性地獄（IE6/7 vs Firefox vs Chrome）を解消し、DOM操作を簡素化したjQueryは爆発的に普及した。だが、アプリケーションの複雑化とともに「jQueryスパゲッティ」が生まれ、フロントエンドにもアーキテクチャが必要だという認識が広がった。

2010年にはBackbone.js（Jeremy Ashkenas）とAngularJS（Google、Misko Hevery）が登場し、フロントエンドMVCの時代が始まる。そして2013年5月、FacebookのJordan WalkeがJSConf USでReactを公開した。「UIは状態の関数である」（`UI = f(state)`）という思想と仮想DOMの導入は、フロントエンド開発のパラダイムを根底から変えた。

### フルスタック回帰——Node.jsとNext.js

2009年11月8日、Ryan DahlがJSConf EUでNode.jsを発表した。GoogleのV8エンジン上にイベントループと非同期I/Oを組み合わせたこのランタイムは、JavaScriptをサーバサイドに持ち込んだ。2010年にはTJ HolowaychukがRubyのSinatraに着想を得てExpress.jsを公開し、Node.jsのWebフレームワークの事実上の標準となった。

そして2016年10月25日、Guillermo RauchのZEIT（現Vercel）がNext.jsをオープンソースとして公開した。サーバサイドレンダリング、静的サイト生成、APIルート——Next.jsは「フロントエンドフレームワーク」と「バックエンドフレームワーク」の境界を曖昧にし、フルスタック回帰の象徴となった。

この30年の系譜を俯瞰すると、ひとつの明確なパターンが見える。Webフレームワークの歴史とは、「HTTPリクエストをどう処理するか」という不変の問いに対して、時代ごとの制約条件の中で最適解を模索してきた軌跡なのだ。

---

## 3. Webアプリケーションの「骨格」——4つの本質的構成要素

フレームワークが何を隠蔽しているかを理解するには、フレームワークが存在しない世界でWebアプリケーションを構築するとき、何が必要になるかを考えればよい。

あらゆるWebアプリケーション——CGIスクリプトであれ、Railsアプリであれ、Next.jsアプリであれ——は、以下の4つの構成要素に分解できる。

```
┌─────────────────────────────────────────────────────┐
│                  クライアント（ブラウザ）               │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP Request
                       ▼
┌─────────────────────────────────────────────────────┐
│  1. HTTPリクエストの受信・パース                       │
│     - メソッド (GET/POST/PUT/DELETE)                  │
│     - URL パス (/users/123)                          │
│     - ヘッダ (Content-Type, Authorization)           │
│     - ボディ (JSON, フォームデータ)                    │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  2. ルーティング                                      │
│     - URLパスとハンドラ関数のマッピング                  │
│     - パスパラメータの抽出 (/users/:id → id=123)      │
│     - HTTPメソッドによる分岐                           │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  3. ビジネスロジック                                   │
│     - データの取得・加工・保存                          │
│     - 認証・認可の検証                                 │
│     - バリデーション                                   │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  4. HTTPレスポンスの生成・送信                          │
│     - ステータスコード (200, 404, 500)                │
│     - レスポンスヘッダ (Content-Type, Set-Cookie)     │
│     - レスポンスボディ (HTML, JSON)                    │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP Response
                       ▼
┌─────────────────────────────────────────────────────┐
│                  クライアント（ブラウザ）               │
└─────────────────────────────────────────────────────┘
```

この4つの構成要素は、30年間変わっていない。CGIの時代も、今のNext.jsの時代も、Webアプリケーションの本質は「HTTPリクエストを受け取り、何らかの処理をして、HTTPレスポンスを返す」ことだ。

### 各構成要素をフレームワークがどう抽象化しているか

フレームワークの価値は、この4つの構成要素を開発者が意識しなくて済むように抽象化することにある。だが、抽象化の仕方はフレームワークごとに大きく異なる。

**1. HTTPリクエストの受信・パース**

CGI時代は環境変数（`QUERY_STRING`、`REQUEST_METHOD`）から自分で取り出していた。Java Servletは`HttpServletRequest`オブジェクトとして抽象化した。Expressは`req`オブジェクトに`req.body`、`req.params`、`req.query`をパース済みで提供する。Next.jsのApp Routerでは、関数の引数として渡される`Request`オブジェクトがWeb標準のFetch APIに準拠している。

```
CGI:          $query = $ENV{'QUERY_STRING'};
Servlet:      String query = request.getQueryString();
Express:      const query = req.query;
Next.js:      const { searchParams } = new URL(request.url);
```

抽象化のレベルが上がるにつれて、HTTPプロトコルの存在感は薄れていく。これは便利だが、問題が発生したときに「何が起きているのか」を理解する力を奪う。

**2. ルーティング**

CGI時代は、URLとスクリプトファイルが1対1で対応していた。`/cgi-bin/hello.pl`にアクセスすれば`hello.pl`が実行される。ルーティングという概念すら必要なかった。

Railsが`routes.rb`で宣言的なルーティングを導入し、Express.jsが`app.get('/users/:id', handler)`というメソッドチェーンのパターンを確立した。そしてNext.jsが、ファイルシステムベースのルーティングで「設定ファイルすら不要」という極地に到達した。

```
CGI:          /cgi-bin/users.pl?id=123  → users.pl が実行される
Rails:        get '/users/:id' => 'users#show'
Express:      app.get('/users/:id', showUser)
Next.js:      app/users/[id]/page.tsx  → ファイルの存在がルート定義
```

ファイルを置くだけでルーティングが成立する。これは革命的に便利だ。だが、ルーティングとは何かを知らない開発者にとって、`[id]`というディレクトリ名がなぜ動的パラメータになるのかは「魔法」でしかない。

**3. ビジネスロジック**

ここはフレームワークが最も関与しにくい領域だ。アプリケーション固有のデータ処理、ビジネスルール、ドメインロジックは、フレームワークが代行できるものではない。ただし、データベースアクセス（ORM）、認証（ミドルウェア）、バリデーション（スキーマ定義）などの「共通パターン」は、フレームワークやそのエコシステムが提供する。

**4. HTTPレスポンスの生成**

CGI時代は`print "Content-type: text/html\n\n";`から自分で書いた。Expressは`res.json()`や`res.render()`で一行でレスポンスを返せる。Next.jsのServer Componentsに至っては、Reactコンポーネントを返すだけで、HTMLへの変換もストリーミングも自動的に行われる。

### 抽象化の功罪

この進化を「進歩」と見るか「危険」と見るかは、視点による。

抽象化は明らかに開発効率を向上させた。CGI時代に半日かかっていたCRUDアプリケーションの構築が、Railsでは15分、Next.jsでは`npx create-next-app`の後の数分で完了する。

だが、抽象化には必ず代償がある。Joel Spolskyが2002年に「The Law of Leaky Abstractions（漏れのある抽象化の法則）」で指摘したように、すべての抽象化は、ある時点で「漏れ」を起こす。フレームワークが隠蔽しているHTTPの挙動が予期せぬ形で顔を出したとき——CORSエラー、CSRFトークンの不一致、ストリーミングレスポンスの中断——「フレームワークの使い方」しか知らない開発者は立ち往生する。

フレームワークを使うなとは言わない。だが、フレームワークが何を隠蔽しているかを知った上で使うのと、知らずに使うのでは、問題が発生したときの対処能力が根本的に異なる。

---

## 4. ハンズオン——Node.jsの`http`モジュールだけでWebアプリケーションを作る

ここからは手を動かそう。フレームワークを一切使わず、Node.jsの標準`http`モジュールだけでTodo APIを構築する。フレームワークが隠蔽している4つの構成要素を、すべて自分の手で実装する。

### 環境構築

Docker環境で実行する。Node.js 22のLTS版を使用する。

```bash
# Docker環境を起動
docker run -it --rm -p 3000:3000 node:22-slim bash
```

### Todo APIの全体像

以下の機能を持つREST APIを、外部ライブラリなしで構築する。

| メソッド | パス       | 機能             |
| -------- | ---------- | ---------------- |
| GET      | /todos     | Todo一覧を取得   |
| POST     | /todos     | 新しいTodoを作成 |
| GET      | /todos/:id | 特定のTodoを取得 |
| PUT      | /todos/:id | Todoを更新       |
| DELETE   | /todos/:id | Todoを削除       |

### Step 1: HTTPサーバの起動——すべての始まり

まず、HTTPリクエストを受信するサーバを立てる。

```javascript
// server.js
const http = require('node:http');

const server = http.createServer((req, res) => {
  console.log(`${req.method} ${req.url}`);
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello, World!\n');
});

server.listen(3000, () => {
  console.log('Server running on http://localhost:3000');
});
```

`http.createServer`に渡すコールバック関数が、すべてのHTTPリクエストの入口だ。この関数は2つの引数を受け取る。`req`（`http.IncomingMessage`）がリクエストの情報を保持し、`res`（`http.ServerResponse`）がレスポンスの送信を担う。

Expressの`app.get('/', handler)`やNext.jsの`route.ts`が最終的に行っていることは、この`createServer`のコールバックと本質的に同じだ。フレームワークは、このコールバックの中で行うべき処理を整理し、構造化しているに過ぎない。

### Step 2: ルーティング——URLとハンドラのマッピング

次に、ルーティングを自分で実装する。URLのパスとHTTPメソッドに応じて、適切なハンドラ関数を呼び分ける。

```javascript
// router.js

// パスパラメータを抽出するための簡易マッチャー
function matchRoute(pattern, pathname) {
  const patternParts = pattern.split('/');
  const pathParts = pathname.split('/');

  if (patternParts.length !== pathParts.length) return null;

  const params = {};
  for (let i = 0; i < patternParts.length; i++) {
    if (patternParts[i].startsWith(':')) {
      params[patternParts[i].slice(1)] = pathParts[i];
    } else if (patternParts[i] !== pathParts[i]) {
      return null;
    }
  }
  return params;
}

class Router {
  constructor() {
    this.routes = [];
  }

  add(method, pattern, handler) {
    this.routes.push({ method: method.toUpperCase(), pattern, handler });
  }

  resolve(method, pathname) {
    for (const route of this.routes) {
      if (route.method !== method.toUpperCase()) continue;
      const params = matchRoute(route.pattern, pathname);
      if (params !== null) {
        return { handler: route.handler, params };
      }
    }
    return null;
  }
}

module.exports = { Router };
```

ここで実装している`matchRoute`関数がやっていることは、Expressの内部で`path-to-regexp`ライブラリが行っていることの簡易版だ。`/todos/:id`というパターンを`/todos/123`というパスに対してマッチングし、`{ id: '123' }`というオブジェクトを返す。

Expressの`app.get('/todos/:id', handler)`という一行の裏で、この種のパターンマッチングが動いている。Next.jsの`app/todos/[id]/route.ts`というファイル名も、ファイルシステムを走査して同等のルーティングテーブルを自動生成している。

### Step 3: リクエストボディのパース——JSONを読み取る

POSTやPUTリクエストのボディを読み取るには、ストリームからデータを手動で収集する必要がある。

```javascript
// body-parser.js

function parseBody(req) {
  return new Promise((resolve, reject) => {
    // GETやDELETEなどボディのないリクエスト
    if (req.method === 'GET' || req.method === 'DELETE') {
      return resolve(null);
    }

    const chunks = [];
    req.on('data', (chunk) => chunks.push(chunk));
    req.on('end', () => {
      const raw = Buffer.concat(chunks).toString();
      if (!raw) return resolve(null);

      const contentType = req.headers['content-type'] || '';
      if (contentType.includes('application/json')) {
        try {
          resolve(JSON.parse(raw));
        } catch (e) {
          reject(new Error('Invalid JSON'));
        }
      } else {
        resolve(raw);
      }
    });
    req.on('error', reject);
  });
}

module.exports = { parseBody };
```

Expressの`express.json()`ミドルウェアが行っていることは、本質的にはこのコードと同じだ。ストリームからチャンクを収集し、`Buffer.concat`で結合し、JSONとしてパースする。Expressはこれに加えて、Content-Lengthの検証、文字エンコーディングの処理、サイズ制限、エラーハンドリングなどを行っている。だが骨格はここにある。

### Step 4: すべてを組み合わせる——Todo API

```javascript
// app.js
const http = require('node:http');
const { Router } = require('./router');
const { parseBody } = require('./body-parser');

// インメモリのデータストア
const todos = new Map();
let nextId = 1;

// ルーターの初期化
const router = new Router();

// レスポンスヘルパー
function sendJSON(res, statusCode, data) {
  res.writeHead(statusCode, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(data));
}

// GET /todos -- 一覧取得
router.add('GET', '/todos', (req, res) => {
  sendJSON(res, 200, Array.from(todos.values()));
});

// POST /todos -- 新規作成
router.add('POST', '/todos', async (req, res) => {
  const body = await parseBody(req);
  if (!body || !body.title) {
    return sendJSON(res, 400, { error: 'title is required' });
  }
  const todo = {
    id: nextId++,
    title: body.title,
    completed: false,
    createdAt: new Date().toISOString()
  };
  todos.set(todo.id, todo);
  sendJSON(res, 201, todo);
});

// GET /todos/:id -- 個別取得
router.add('GET', '/todos/:id', (req, res, params) => {
  const todo = todos.get(Number(params.id));
  if (!todo) return sendJSON(res, 404, { error: 'Not found' });
  sendJSON(res, 200, todo);
});

// PUT /todos/:id -- 更新
router.add('PUT', '/todos/:id', async (req, res, params) => {
  const todo = todos.get(Number(params.id));
  if (!todo) return sendJSON(res, 404, { error: 'Not found' });
  const body = await parseBody(req);
  if (body.title !== undefined) todo.title = body.title;
  if (body.completed !== undefined) todo.completed = body.completed;
  sendJSON(res, 200, todo);
});

// DELETE /todos/:id -- 削除
router.add('DELETE', '/todos/:id', (req, res, params) => {
  const id = Number(params.id);
  if (!todos.has(id)) return sendJSON(res, 404, { error: 'Not found' });
  todos.delete(id);
  sendJSON(res, 204, null);
});

// サーバの起動
const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const pathname = url.pathname;

  console.log(`${req.method} ${pathname}`);

  const match = router.resolve(req.method, pathname);
  if (!match) {
    return sendJSON(res, 404, { error: 'Route not found' });
  }

  try {
    await match.handler(req, res, match.params);
  } catch (err) {
    console.error('Internal error:', err);
    sendJSON(res, 500, { error: 'Internal Server Error' });
  }
});

server.listen(3000, () => {
  console.log('Todo API running on http://localhost:3000');
});
```

### Step 5: 動作確認

サーバを起動し、curlで各エンドポイントを叩いてみよう。

```bash
# サーバを起動（バックグラウンド）
node app.js &

# Todoを作成
curl -s -X POST http://localhost:3000/todos \
  -H 'Content-Type: application/json' \
  -d '{"title": "フレームワークの歴史を学ぶ"}' | jq .

# 出力:
# {
#   "id": 1,
#   "title": "フレームワークの歴史を学ぶ",
#   "completed": false,
#   "createdAt": "2026-03-21T10:00:00.000Z"
# }

# 一覧取得
curl -s http://localhost:3000/todos | jq .

# 個別取得
curl -s http://localhost:3000/todos/1 | jq .

# 更新
curl -s -X PUT http://localhost:3000/todos/1 \
  -H 'Content-Type: application/json' \
  -d '{"completed": true}' | jq .

# 削除
curl -s -X DELETE http://localhost:3000/todos/1
```

### 何が見えたか

このハンズオンで、フレームワークが隠蔽している4つの構成要素をすべて自分の手で実装した。

- **HTTPリクエストの受信**: `http.createServer`のコールバック
- **ルーティング**: `Router`クラスとパターンマッチング
- **リクエストボディのパース**: ストリームからのデータ収集とJSONパース
- **レスポンスの生成**: `res.writeHead`と`res.end`

合計しても150行に満たない。これがWebアプリケーションの骨格だ。

Expressを使えば、同じ機能が30行程度で書ける。Next.jsのAPI Routeを使えば、さらに少ない。その差の中に、フレームワークの価値がある。だが、その差が何を隠蔽しているかを知っているかどうかで、あなたがフレームワークの「利用者」であるか「依存者」であるかが決まる。

---

## 5. まとめと次回予告

### この回の要点

第1回では、Webフレームワークの全体像を俯瞰し、その本質を掘り下げた。要点を整理する。

フレームワークが「空気」になった2020年代、Webアプリケーション開発の現場ではフレームワークの存在が前提となっている。Stack Overflow Developer Survey 2024ではReactが41.6%、Node.jsが40.7%の利用率を記録し、2025年にはcreate-react-appが正式に非推奨化された。フレームワークなしの開発は、もはや公式に推奨されていない。

Webフレームワークの歴史は、1993年のCGI仕様策定から始まる。Rob McCoolがNCSAで策定したこのシンプルなインターフェースは、「HTTPリクエストを受け取り、処理し、レスポンスを返す」というWebアプリケーションの原型を定義した。そこからmod_perl、FastCGI、PHP、Java Servlet、テンプレートエンジン、Rails、jQuery、React、Node.js、Next.jsへと至る30年の歴史は、同じ問いに対する解の変遷だ。

あらゆるWebアプリケーションは、4つの本質的構成要素——(1) HTTPリクエストの受信・パース、(2) ルーティング、(3) ビジネスロジック、(4) HTTPレスポンスの生成——に分解できる。フレームワークの価値は、これらの構成要素を抽象化し、開発者が本質的なビジネスロジックに集中できるようにすることにある。だが、抽象化は必ず「漏れ」を起こす。

Node.jsの`http`モジュールだけでTodo APIを構築するハンズオンを通じて、フレームワークが隠蔽している処理の実体を確認した。ルーティング、ボディパース、レスポンス生成——これらはフレームワークが「魔法」で実現しているのではなく、150行程度のコードで再現できる具体的な処理だ。

### 冒頭の問いに対する暫定回答

「フレームワークなしでWebを作れるか」——答えはYesだ。Node.jsの`http`モジュール、あるいはもっと遡ればCGIスクリプトの`print`文があれば、Webアプリケーションは作れる。

だが、現実のプロダクション環境で「フレームワークなし」を選ぶことは、ほとんどの場合、合理的ではない。フレームワークはセキュリティ対策、パフォーマンス最適化、エラーハンドリング、テスト支援など、150行のコードでは到底カバーできない膨大な機能を提供している。

重要なのは「フレームワークを使うか使わないか」ではない。「フレームワークが何をしているかを理解した上で使う」ことだ。

### 次回予告

第2回「CGIという原点——HTTPリクエストを手で受けた時代」では、1993年に生まれたCGIの仕組みを深く掘り下げる。プロセスフォーク、環境変数、標準入出力——CGIがどのようにWebサーバと外部プログラムを結びつけたのか、その設計思想と制約を、Apache + Perl CGIの環境をDockerで構築して体験する。

「最初のWebアプリケーションは、どのように作られていたのか？」——この問いの答えを、あなた自身の手で確かめてほしい。

---

## 参考文献

- Stack Overflow, "2024 Developer Survey - Technology" <https://survey.stackoverflow.co/2024/technology>
- Rob McCool, CGI仕様 (1993年、NCSA) — 参考: <https://en.wikipedia.org/wiki/Common_Gateway_Interface>
- RFC 3875, "The Common Gateway Interface (CGI) Version 1.1", D. Robinson, K. Coar, 2004年10月 <https://www.rfc-editor.org/rfc/rfc3875>
- Node.js HTTP Module Documentation <https://nodejs.org/api/http.html>
- DHH, "How to build a blog in 15 minutes with Rails" (2005年) — 参考: <https://avohq.io/glossary/15-minute-blog>
- Joel Spolsky, "The Law of Leaky Abstractions" (2002年11月) — 参考: <https://www.joelonsoftware.com/2002/11/11/the-law-of-leaky-abstractions/>
- Jesse James Garrett, "Ajax: A New Approach to Web Applications" (2005年2月18日)
- Next.js, Initial Release (2016年10月25日) <https://github.com/vercel/next.js/releases>
- React, Initial Open Source Release (2013年5月、JSConf US) <https://en.wikipedia.org/wiki/React_(software)>
- Ryan Dahl, Node.js presentation at JSConf EU (2009年11月8日) <https://en.wikipedia.org/wiki/Node.js>
