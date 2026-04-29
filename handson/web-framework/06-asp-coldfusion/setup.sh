#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/web-framework-handson-06"

echo "=========================================================="
echo " 第6回ハンズオン: ASP/ColdFusion ——選ばれなかった主流"
echo "=========================================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

mkdir -p "${WORKDIR}/asp-style"
mkdir -p "${WORKDIR}/cfml"
mkdir -p "${WORKDIR}/htmx"

# ------------------------------------------------------------
# 演習1: ASP Classic 風の <%...%> インライン文化を Node.js + EJS で再現
# ------------------------------------------------------------
echo ">>> 演習1: ASP Classic 風 <%...%> を Node.js + EJS で再現"

cd "${WORKDIR}/asp-style"

cat > server.js << 'JS'
const http = require('http');
const ejs = require('ejs');

const template = `<%@ Language="EJS-as-VBScript-emulator" %>
<html><body>
<h1>ASP Classic 風のインラインテンプレート</h1>
<p>現在時刻：<%= new Date().toISOString() %></p>
<%
    const items = ["apple", "banana", "cherry"];
    const username = (query.user || "guest");
%>
<p>ようこそ <%= username %> さん</p>
<ul>
<% for (const item of items) { %>
    <li><%= item %></li>
<% } %>
</ul>
</body></html>`;

http.createServer((req, res) => {
    const url = new URL(req.url, "http://localhost");
    const query = Object.fromEntries(url.searchParams);
    const html = ejs.render(template, { query });
    res.writeHead(200, { "Content-Type": "text/html; charset=UTF-8" });
    res.end(html);
}).listen(3000);

console.log("演習1サーバ起動: http://localhost:3000/?user=Yusuke");
JS

if ! [ -f package.json ]; then
  npm init -y > /dev/null
fi
npm install ejs > /dev/null 2>&1 || npm install ejs

# バックグラウンド起動（後で終了）
node server.js > /tmp/handson-06-asp.log 2>&1 &
ASP_PID=$!
sleep 1

echo "--- curl 'http://localhost:3000/?user=Yusuke' ---"
curl -s 'http://localhost:3000/?user=Yusuke' | head -20
echo ""

kill ${ASP_PID} 2>/dev/null || true
wait ${ASP_PID} 2>/dev/null || true

echo ""

# ------------------------------------------------------------
# 演習2: Lucee CE Docker で CFML タグベース構文を読み解く
# ------------------------------------------------------------
echo ">>> 演習2: Lucee CE Docker で CFML タグベース構文"

cat > "${WORKDIR}/cfml/index.cfm" << 'CFM'
<cfset users = [
    {id=1, name="Yusuke",  email="yusuke@example.com"},
    {id=2, name="Takeshi", email="takeshi@example.com"},
    {id=3, name="Hanako",  email="hanako@example.com"}
]>

<html><body>
<h1>CFML タグの世界</h1>

<cfif arrayLen(users) gt 0>
    <table border="1">
        <tr><th>ID</th><th>Name</th><th>Email</th></tr>
        <cfloop array="#users#" index="user">
            <tr>
                <td>#user.id#</td>
                <td>#user.name#</td>
                <td>#user.email#</td>
            </tr>
        </cfloop>
    </table>
<cfelse>
    <p>ユーザがいません</p>
</cfif>

<hr>
<p>※ #...# で囲まれた部分が変数の埋め込みになる</p>
</body></html>
CFM

if ! command -v docker > /dev/null 2>&1; then
  echo "WARNING: docker コマンドが見つかりません。"
  echo "Dockerインストール後、以下を手動で実行してください:"
  echo ""
  echo "  docker run -d --name lucee-handson -p 8888:8888 lucee/lucee:latest"
  echo "  docker cp ${WORKDIR}/cfml/index.cfm lucee-handson:/var/www/"
  echo "  curl http://localhost:8888/index.cfm"
else
  # 既存コンテナを掃除
  docker rm -f lucee-handson 2>/dev/null || true

  echo "Lucee CE コンテナを起動（数分かかります）..."
  docker run -d --name lucee-handson -p 8888:8888 lucee/lucee:latest > /dev/null
  echo "Tomcatの起動を待機（最大60秒）..."

  for i in $(seq 1 30); do
    if curl -s http://localhost:8888/ > /dev/null 2>&1; then
      echo "Lucee起動完了"
      break
    fi
    sleep 2
  done

  docker cp "${WORKDIR}/cfml/index.cfm" lucee-handson:/var/www/ > /dev/null

  echo ""
  echo "--- curl http://localhost:8888/index.cfm ---"
  curl -s http://localhost:8888/index.cfm | head -30
  echo ""
  echo ""
  echo "Luceeコンテナは継続稼働中（後片付け: docker stop lucee-handson）"
fi

echo ""

# ------------------------------------------------------------
# 演習3: HTMX で「サーバが主、クライアントが従」
# ------------------------------------------------------------
echo ">>> 演習3: HTMX で『サーバが主、クライアントが従』"

cd "${WORKDIR}/htmx"

cat > server.js << 'JS'
const http = require('http');

let counter = 0;

http.createServer((req, res) => {
    if (req.url === '/' && req.method === 'GET') {
        res.writeHead(200, { "Content-Type": "text/html; charset=UTF-8" });
        res.end(`<!DOCTYPE html>
<html><head>
    <script src="https://unpkg.com/htmx.org@2.0.4"></script>
</head><body>
    <h1>HTMX カウンタ</h1>
    <button hx-post="/increment"
            hx-target="#counter"
            hx-swap="innerHTML">+</button>
    <button hx-post="/decrement"
            hx-target="#counter"
            hx-swap="innerHTML">-</button>
    <p>現在値: <span id="counter">${counter}</span></p>
</body></html>`);
    } else if (req.url === '/increment' && req.method === 'POST') {
        counter++;
        res.writeHead(200, { "Content-Type": "text/html" });
        res.end(String(counter));
    } else if (req.url === '/decrement' && req.method === 'POST') {
        counter--;
        res.writeHead(200, { "Content-Type": "text/html" });
        res.end(String(counter));
    } else {
        res.writeHead(404);
        res.end();
    }
}).listen(3001);

console.log("演習3サーバ起動: http://localhost:3001/");
JS

# 動作確認のため一時的に起動
node server.js > /tmp/handson-06-htmx.log 2>&1 &
HTMX_PID=$!
sleep 1

echo "--- curl http://localhost:3001/ ---"
curl -s http://localhost:3001/ | head -15
echo ""
echo ""
echo "--- curl -X POST http://localhost:3001/increment ---"
curl -s -X POST http://localhost:3001/increment
echo " (← サーバが返したHTML断片)"
echo ""

kill ${HTMX_PID} 2>/dev/null || true
wait ${HTMX_PID} 2>/dev/null || true

echo ""
echo "=========================================================="
echo " ハンズオン完了"
echo " 作業ディレクトリ: ${WORKDIR}"
echo ""
echo " HTMXを手動で試す場合:"
echo "   cd ${WORKDIR}/htmx"
echo "   node server.js"
echo "   # ブラウザで http://localhost:3001/ を開く"
echo ""
echo " 後片付け:"
echo "   docker stop lucee-handson && docker rm lucee-handson"
echo "   rm -rf ${WORKDIR}"
echo "=========================================================="
