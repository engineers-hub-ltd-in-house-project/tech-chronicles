#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/web-framework-handson-04"

echo "============================================"
echo " 第4回ハンズオン: 素のPHPでWebアプリケーション"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

# -------------------------------------------
# セクション1: 環境構築
# -------------------------------------------
echo ">>> セクション1: 環境構築"

mkdir -p "${WORKDIR}/templates"
cd "${WORKDIR}"

apt-get update -qq && apt-get install -y -qq \
  php-cli \
  php-sqlite3 \
  php-mbstring \
  curl > /dev/null 2>&1

echo "PHP version: $(php -v | head -1)"
echo ""

# -------------------------------------------
# セクション2: Hello World（ビルトインWebサーバ）
# -------------------------------------------
echo ">>> セクション2: PHPビルトインWebサーバで Hello World"

cat > "${WORKDIR}/hello.php" << 'PHP'
<?php
echo "<html><body>";
echo "<h1>Hello from raw PHP</h1>";
echo "<p>PHP Version: " . phpversion() . "</p>";
echo "<p>Server Time: " . date('Y-m-d H:i:s') . "</p>";
echo "<p>Request URI: " . htmlspecialchars($_SERVER['REQUEST_URI']) . "</p>";
echo "</body></html>";
PHP

php -S 0.0.0.0:8080 -t "${WORKDIR}" "${WORKDIR}/hello.php" &
PHP_PID=$!
sleep 1

echo "--- GET / ---"
curl -s http://localhost:8080/
echo ""

kill ${PHP_PID} 2>/dev/null || true
wait ${PHP_PID} 2>/dev/null || true
echo ""

# -------------------------------------------
# セクション3: データベース層
# -------------------------------------------
echo ">>> セクション3: データベース層の作成"

cat > "${WORKDIR}/database.php" << 'DB'
<?php
function getDatabase(): PDO {
    static $pdo = null;
    if ($pdo === null) {
        $dbPath = __DIR__ . '/tasks.db';
        $pdo = new PDO("sqlite:{$dbPath}");
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                description TEXT DEFAULT '',
                completed INTEGER DEFAULT 0,
                created_at TEXT DEFAULT (datetime('now'))
            )
        ");
    }
    return $pdo;
}

function getAllTasks(): array {
    $pdo = getDatabase();
    $stmt = $pdo->query("SELECT * FROM tasks ORDER BY created_at DESC");
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function createTask(string $title, string $description): int {
    $pdo = getDatabase();
    $stmt = $pdo->prepare("INSERT INTO tasks (title, description) VALUES (:title, :description)");
    $stmt->execute(['title' => $title, 'description' => $description]);
    return (int)$pdo->lastInsertId();
}

function toggleTask(int $id): void {
    $pdo = getDatabase();
    $stmt = $pdo->prepare("UPDATE tasks SET completed = NOT completed WHERE id = :id");
    $stmt->execute(['id' => $id]);
}

function deleteTask(int $id): void {
    $pdo = getDatabase();
    $stmt = $pdo->prepare("DELETE FROM tasks WHERE id = :id");
    $stmt->execute(['id' => $id]);
}
DB

echo "database.php を作成しました"
echo ""

# -------------------------------------------
# セクション4: テンプレートファイル
# -------------------------------------------
echo ">>> セクション4: テンプレートファイルの作成"

cat > "${WORKDIR}/templates/layout.php" << 'TPL'
<!DOCTYPE html>
<html lang="ja">
<head>
  <meta charset="UTF-8">
  <title><?= htmlspecialchars($title ?? 'タスク管理', ENT_QUOTES, 'UTF-8') ?></title>
  <style>
    body { font-family: sans-serif; max-width: 800px; margin: 2rem auto; padding: 0 1rem; }
    nav { margin-bottom: 2rem; padding: 1rem; background: #f0f0f0; }
    nav a { margin-right: 1rem; }
    .task { padding: 0.5rem; border-bottom: 1px solid #ddd; }
    .completed { text-decoration: line-through; color: #999; }
    form { margin: 1rem 0; }
    input[type="text"], textarea { width: 100%; padding: 0.5rem; margin: 0.25rem 0; }
    button { padding: 0.5rem 1rem; margin: 0.25rem; cursor: pointer; }
  </style>
</head>
<body>
  <nav>
    <a href="/">トップ</a>
    <a href="/tasks">タスク一覧</a>
    <a href="/tasks/new">新規タスク</a>
  </nav>
  <?= $content ?>
</body>
</html>
TPL

cat > "${WORKDIR}/templates/task_list.php" << 'TPL'
<h1>タスク一覧</h1>
<?php if (empty($tasks)): ?>
  <p>タスクはありません。</p>
<?php else: ?>
  <?php foreach ($tasks as $task): ?>
    <div class="task <?= $task['completed'] ? 'completed' : '' ?>">
      <strong><?= htmlspecialchars($task['title'], ENT_QUOTES, 'UTF-8') ?></strong>
      <p><?= htmlspecialchars($task['description'], ENT_QUOTES, 'UTF-8') ?></p>
      <small>作成日: <?= htmlspecialchars($task['created_at'], ENT_QUOTES, 'UTF-8') ?></small>
      <form method="POST" action="/tasks/toggle" style="display:inline">
        <input type="hidden" name="id" value="<?= (int)$task['id'] ?>">
        <button type="submit"><?= $task['completed'] ? '未完了に戻す' : '完了にする' ?></button>
      </form>
      <form method="POST" action="/tasks/delete" style="display:inline">
        <input type="hidden" name="id" value="<?= (int)$task['id'] ?>">
        <button type="submit" onclick="return confirm('削除しますか？')">削除</button>
      </form>
    </div>
  <?php endforeach; ?>
<?php endif; ?>
TPL

cat > "${WORKDIR}/templates/task_form.php" << 'TPL'
<h1>新規タスク</h1>
<form method="POST" action="/tasks">
  <div>
    <label>タイトル:</label>
    <input type="text" name="title" required>
  </div>
  <div>
    <label>説明:</label>
    <textarea name="description" rows="4"></textarea>
  </div>
  <button type="submit">作成</button>
</form>
TPL

echo "テンプレートファイルを作成しました"
echo ""

# -------------------------------------------
# セクション5: メインアプリケーション（ルーター）
# -------------------------------------------
echo ">>> セクション5: メインアプリケーションの作成"

cat > "${WORKDIR}/index.php" << 'APP'
<?php
require_once __DIR__ . '/database.php';

function render(string $template, array $vars = []): string {
    extract($vars);
    ob_start();
    include __DIR__ . "/templates/{$template}.php";
    $content = ob_get_clean();
    ob_start();
    include __DIR__ . '/templates/layout.php';
    return ob_get_clean();
}

$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

$routes = [
    'GET' => [
        '/'          => 'handleHome',
        '/tasks'     => 'handleTaskList',
        '/tasks/new' => 'handleTaskForm',
    ],
    'POST' => [
        '/tasks'        => 'handleTaskCreate',
        '/tasks/toggle' => 'handleTaskToggle',
        '/tasks/delete' => 'handleTaskDelete',
    ],
];

if (isset($routes[$method][$path])) {
    $handler = $routes[$method][$path];
    echo $handler();
} else {
    http_response_code(404);
    echo "<html><body><h1>404 Not Found</h1></body></html>";
}

function handleHome(): string {
    return render('task_list', ['title' => 'タスク管理', 'tasks' => getAllTasks()]);
}

function handleTaskList(): string {
    return render('task_list', ['title' => 'タスク一覧', 'tasks' => getAllTasks()]);
}

function handleTaskForm(): string {
    return render('task_form', ['title' => '新規タスク']);
}

function handleTaskCreate(): string {
    $title = trim($_POST['title'] ?? '');
    $description = trim($_POST['description'] ?? '');
    if ($title !== '') {
        createTask($title, $description);
    }
    header('Location: /tasks');
    exit;
}

function handleTaskToggle(): string {
    $id = (int)($_POST['id'] ?? 0);
    if ($id > 0) { toggleTask($id); }
    header('Location: /tasks');
    exit;
}

function handleTaskDelete(): string {
    $id = (int)($_POST['id'] ?? 0);
    if ($id > 0) { deleteTask($id); }
    header('Location: /tasks');
    exit;
}
APP

echo "index.php を作成しました"
echo ""

# -------------------------------------------
# セクション6: 動作確認
# -------------------------------------------
echo ">>> セクション6: 動作確認"

php -S 0.0.0.0:8080 -t "${WORKDIR}" "${WORKDIR}/index.php" &
PHP_PID=$!
sleep 1

echo "--- タスク作成 ---"
curl -s -X POST -d "title=PHPの歴史を学ぶ&description=1995年から2026年まで" \
  -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8080/tasks

curl -s -X POST -d "title=shared-nothingを理解する&description=リクエストごとに状態リセット" \
  -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8080/tasks

echo ""
echo "--- タスク一覧（HTML） ---"
curl -s http://localhost:8080/tasks | head -30
echo "..."
echo ""

kill ${PHP_PID} 2>/dev/null || true
wait ${PHP_PID} 2>/dev/null || true

echo ""
echo "============================================"
echo " ハンズオン完了"
echo " 作業ディレクトリ: ${WORKDIR}"
echo ""
echo " 手動で試す場合:"
echo "   cd ${WORKDIR}"
echo "   php -S 0.0.0.0:8080 -t . index.php"
echo "   # ブラウザで http://localhost:8080/ を開く"
echo "============================================"
