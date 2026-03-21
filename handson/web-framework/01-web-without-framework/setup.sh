#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/web-framework-handson-01"

echo "============================================"
echo " ハンズオン: フレームワークなしでWebを作れるか"
echo " 連載「フレームワークという幻想」第1回"
echo "============================================"
echo ""

# -----------------------------------------------
echo ">>> Step 1: 作業ディレクトリの作成"
# -----------------------------------------------
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

# -----------------------------------------------
echo ">>> Step 2: ルーターの作成 (router.js)"
# -----------------------------------------------
cat > router.js << 'ROUTER_EOF'
// router.js -- URLパターンマッチングによるルーティング

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
ROUTER_EOF
echo "router.js を作成しました"
echo ""

# -----------------------------------------------
echo ">>> Step 3: ボディパーサーの作成 (body-parser.js)"
# -----------------------------------------------
cat > body-parser.js << 'PARSER_EOF'
// body-parser.js -- リクエストボディのストリーム読み取りとJSONパース

function parseBody(req) {
  return new Promise((resolve, reject) => {
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
PARSER_EOF
echo "body-parser.js を作成しました"
echo ""

# -----------------------------------------------
echo ">>> Step 4: Todo APIアプリケーションの作成 (app.js)"
# -----------------------------------------------
cat > app.js << 'APP_EOF'
// app.js -- フレームワークなしのTodo REST API
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
  console.log('');
  console.log('動作確認:');
  console.log('  curl -s -X POST http://localhost:3000/todos \\');
  console.log('    -H "Content-Type: application/json" \\');
  console.log('    -d \'{"title": "フレームワークの歴史を学ぶ"}\' | jq .');
  console.log('  curl -s http://localhost:3000/todos | jq .');
});
APP_EOF
echo "app.js を作成しました"
echo ""

# -----------------------------------------------
echo ">>> Step 5: セットアップ完了"
# -----------------------------------------------
echo ""
echo "============================================"
echo " セットアップ完了"
echo "============================================"
echo ""
echo "以下のコマンドでサーバを起動してください:"
echo ""
echo "  cd ${WORKDIR}"
echo "  node app.js"
echo ""
echo "別のターミナルから動作確認:"
echo ""
echo "  curl -s -X POST http://localhost:3000/todos \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"title\": \"フレームワークの歴史を学ぶ\"}' | jq ."
echo "  curl -s http://localhost:3000/todos | jq ."
echo ""
