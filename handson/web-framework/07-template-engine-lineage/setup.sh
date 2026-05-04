#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/web-framework-handson-07"

echo "=========================================================="
echo " 第7回ハンズオン: テンプレートエンジン3種を同時に動かす"
echo "=========================================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ------------------------------------------------------------
# 共通データ（3エンジンとも同じ JSON を参照する）
# ------------------------------------------------------------
echo ">>> 共通データ data.json を作成"

cat > data.json << 'JSON'
{
  "title": "今週のタスク",
  "user": "佐藤",
  "tasks": [
    {"id": 1, "title": "原稿レビュー <urgent>", "done": false, "priority": "high"},
    {"id": 2, "title": "ファクトチェック", "done": true, "priority": "high"},
    {"id": 3, "title": "ハンズオン作成 & 検証", "done": false, "priority": "medium"},
    {"id": 4, "title": "設計レビュー", "done": false, "priority": "low"}
  ]
}
JSON

# ランタイム確認
HAS_RUBY=0
HAS_PY=0
HAS_NODE=0
command -v ruby > /dev/null 2>&1 && HAS_RUBY=1 || true
command -v python3 > /dev/null 2>&1 && HAS_PY=1 || true
command -v node > /dev/null 2>&1 && command -v npm > /dev/null 2>&1 && HAS_NODE=1 || true

# ------------------------------------------------------------
# 演習1: ERB（Ruby）
# ------------------------------------------------------------
echo ""
echo ">>> 演習1: ERB（Ruby）でレンダリング"

cat > template.erb << 'ERB'
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title><%= data[:title] %></title></head>
<body>
<h1><%= data[:title] %></h1>
<p>担当: <%= data[:user] %></p>
<ul>
<% data[:tasks].each do |task| -%>
  <li class="<%= task[:done] ? 'done' : 'pending' %> p-<%= task[:priority] %>">
    [<%= task[:done] ? 'x' : ' ' %>] <%= task[:title] %>
  </li>
<% end -%>
</ul>
<p>未完了: <%= data[:tasks].count { |t| !t[:done] } %> / <%= data[:tasks].length %></p>
<p>優先度 high かつ未完了: <%= data[:tasks].count { |t| t[:priority] == 'high' && !t[:done] } %></p>
</body></html>
ERB

cat > render_erb.rb << 'RUBY'
require 'erb'
require 'json'

data = JSON.parse(File.read('data.json'), symbolize_names: true)
template = ERB.new(File.read('template.erb'), trim_mode: '-')
puts template.result_with_hash(data: data)
RUBY

if [ "${HAS_RUBY}" = "1" ]; then
  ruby render_erb.rb > out_erb.html
  echo "--- out_erb.html (head 15) ---"
  head -15 out_erb.html
  echo ""
else
  echo "WARNING: ruby が見つかりません。 apt-get install -y ruby ruby-erb 等を実行してください。"
fi

# ------------------------------------------------------------
# 演習2: Jinja2（Python）
# ------------------------------------------------------------
echo ""
echo ">>> 演習2: Jinja2（Python）でレンダリング"

cat > template.j2 << 'J2'
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>{{ title }}</title></head>
<body>
<h1>{{ title }}</h1>
<p>担当: {{ user }}</p>
<ul>
{% for task in tasks %}
  <li class="{{ 'done' if task.done else 'pending' }} p-{{ task.priority }}">
    [{{ 'x' if task.done else ' ' }}] {{ task.title }}
  </li>
{% endfor %}
</ul>
<p>未完了: {{ tasks | rejectattr('done') | list | length }} / {{ tasks | length }}</p>
<p>優先度 high かつ未完了: {{ tasks | selectattr('priority', 'equalto', 'high') | rejectattr('done') | list | length }}</p>
</body></html>
J2

cat > render_jinja.py << 'PY'
import json
from jinja2 import Environment, FileSystemLoader, select_autoescape

env = Environment(
    loader=FileSystemLoader('.'),
    autoescape=select_autoescape(['html', 'j2'])
)
template = env.get_template('template.j2')

with open('data.json', encoding='utf-8') as f:
    data = json.load(f)

print(template.render(**data))
PY

if [ "${HAS_PY}" = "1" ]; then
  if ! python3 -c 'import jinja2' > /dev/null 2>&1; then
    echo "Jinja2 をインストールします..."
    pip3 install --quiet --break-system-packages Jinja2 \
      || pip3 install --quiet --user Jinja2 \
      || pip3 install --quiet Jinja2
  fi

  python3 render_jinja.py > out_jinja.html
  echo "--- out_jinja.html (head 15) ---"
  head -15 out_jinja.html
  echo ""
else
  echo "WARNING: python3 が見つかりません。 apt-get install -y python3 python3-jinja2 等を実行してください。"
fi

# ------------------------------------------------------------
# 演習3: Handlebars（Node.js）
# ------------------------------------------------------------
echo ""
echo ">>> 演習3: Handlebars（Node.js）でレンダリング"

cat > template.hbs << 'HBS'
<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>{{title}}</title></head>
<body>
<h1>{{title}}</h1>
<p>担当: {{user}}</p>
<ul>
{{#each tasks}}
  <li class="{{cssState done}} p-{{priority}}">
    [{{check done}}] {{title}}
  </li>
{{/each}}
</ul>
<p>未完了: {{countPending tasks}} / {{tasks.length}}</p>
<p>優先度 high かつ未完了: {{countHighPending tasks}}</p>
</body></html>
HBS

cat > render_hbs.js << 'JS'
const fs = require('fs');
const Handlebars = require('handlebars');

Handlebars.registerHelper('check', (done) => done ? 'x' : ' ');
Handlebars.registerHelper('cssState', (done) => done ? 'done' : 'pending');
Handlebars.registerHelper('countPending', (tasks) =>
  tasks.filter(t => !t.done).length
);
Handlebars.registerHelper('countHighPending', (tasks) =>
  tasks.filter(t => t.priority === 'high' && !t.done).length
);

const tplSrc = fs.readFileSync('template.hbs', 'utf-8');
const data = JSON.parse(fs.readFileSync('data.json', 'utf-8'));

const template = Handlebars.compile(tplSrc);
process.stdout.write(template(data));
JS

if [ "${HAS_NODE}" = "1" ]; then
  if ! [ -f package.json ]; then
    npm init -y > /dev/null
  fi
  if ! [ -d node_modules/handlebars ]; then
    npm install handlebars > /dev/null 2>&1 || npm install handlebars
  fi

  node render_hbs.js > out_hbs.html
  echo "--- out_hbs.html (head 15) ---"
  head -15 out_hbs.html
  echo ""
else
  echo "WARNING: node/npm が見つかりません。 apt-get install -y nodejs npm 等を実行してください。"
fi

# ------------------------------------------------------------
# 演習4: 出力を比較
# ------------------------------------------------------------
echo ""
echo ">>> 演習4: 3 つの出力を比較する"

if [ -f out_erb.html ] && [ -f out_jinja.html ]; then
  echo "--- diff out_erb.html out_jinja.html ---"
  diff out_erb.html out_jinja.html || true
  echo ""
fi

if [ -f out_jinja.html ] && [ -f out_hbs.html ]; then
  echo "--- diff out_jinja.html out_hbs.html ---"
  diff out_jinja.html out_hbs.html || true
  echo ""
fi

# ------------------------------------------------------------
# 演習5: 自動エスケープの差を可視化
# ------------------------------------------------------------
echo ""
echo ">>> 演習5: '<urgent>' が各エンジンでどう出力されるかを確認"

if ls out_*.html > /dev/null 2>&1; then
  for f in out_*.html; do
    line=$(grep -n 'urgent' "$f" | head -1 || true)
    if [ -n "$line" ]; then
      echo "  ${f}: ${line}"
    fi
  done
fi

echo ""
echo "  期待される結果:"
echo "    - out_erb.html   : <urgent> がそのまま生で出力される（素の ERB は自動エスケープしない）"
echo "    - out_jinja.html : &lt;urgent&gt; に変換される（autoescape の効果）"
echo "    - out_hbs.html   : &lt;urgent&gt; に変換される（Handlebars はデフォルトで自動エスケープ）"

echo ""
echo "=========================================================="
echo " ハンズオン完了"
echo " 作業ディレクトリ: ${WORKDIR}"
echo ""
echo " 後片付け:"
echo "   rm -rf ${WORKDIR}"
echo "=========================================================="
