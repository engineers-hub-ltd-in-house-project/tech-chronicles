#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/unix-philosophy-handson-03"

echo "============================================"
echo " 第3回ハンズオン: C言語でUNIXシステムコールを呼ぶ"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# ============================================
echo ""
echo "--- 環境準備 ---"
echo ""
# ============================================

apt-get update -qq && apt-get install -y -qq gcc > /dev/null 2>&1
echo "gcc インストール完了"

# ============================================
echo ""
echo "============================================"
echo " 演習1: fork()とexec() — プロセス生成の基本"
echo "============================================"
echo ""
# ============================================

cat << 'CCODE' > fork_exec.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    printf("親プロセス PID=%d\n", getpid());
    pid_t pid = fork();
    if (pid < 0) { perror("fork"); return 1; }
    if (pid == 0) {
        printf("子プロセス PID=%d (親PID=%d)\n", getpid(), getppid());
        printf("子プロセスが /bin/ls に変身する...\n");
        execlp("ls", "ls", "-la", "/tmp", (char *)NULL);
        perror("exec");
        return 1;
    }
    int status;
    waitpid(pid, &status, 0);
    printf("親プロセス: 子プロセス(PID=%d)が終了コード%dで終了\n",
           pid, WEXITSTATUS(status));
    return 0;
}
CCODE

gcc -o fork_exec fork_exec.c
echo "--- 実行結果 ---"
./fork_exec
echo ""
echo "→ fork()でプロセスが分裂し、子プロセスがexec()で別プログラムに変身した"

# ============================================
echo ""
echo "============================================"
echo " 演習2: pipe() — プロセス間通信"
echo "============================================"
echo ""
# ============================================

cat << 'CCODE' > pipe_demo.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    int pipefd[2];
    if (pipe(pipefd) < 0) { perror("pipe"); return 1; }
    printf("パイプ作成: 読み取り端fd=%d, 書き込み端fd=%d\n",
           pipefd[0], pipefd[1]);
    pid_t pid = fork();
    if (pid < 0) { perror("fork"); return 1; }
    if (pid == 0) {
        close(pipefd[1]);
        char buf[256];
        ssize_t n;
        printf("[子] パイプからの読み取りを待機...\n");
        while ((n = read(pipefd[0], buf, sizeof(buf) - 1)) > 0) {
            buf[n] = '\0';
            printf("[子] 受信: %s", buf);
        }
        close(pipefd[0]);
        printf("[子] パイプが閉じられた。終了。\n");
        return 0;
    }
    close(pipefd[0]);
    const char *messages[] = {
        "Hello from parent process\n",
        "This is pipe communication\n",
        "Just like | in shell\n",
        NULL
    };
    for (int i = 0; messages[i] != NULL; i++) {
        write(pipefd[1], messages[i], strlen(messages[i]));
        printf("[親] 送信: %s", messages[i]);
        usleep(100000);
    }
    close(pipefd[1]);
    int status;
    waitpid(pid, &status, 0);
    printf("[親] 子プロセスが終了。\n");
    return 0;
}
CCODE

gcc -o pipe_demo pipe_demo.c
echo "--- 実行結果 ---"
./pipe_demo
echo ""
echo "→ pipe()でカーネル内にバッファが作られ、プロセス間でデータが流れた"

# ============================================
echo ""
echo "============================================"
echo " 演習3: シェルのパイプラインを自作する"
echo "============================================"
echo ""
# ============================================

cat << 'CCODE' > mini_pipeline.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    int pipe1[2], pipe2[2];
    if (pipe(pipe1) < 0 || pipe(pipe2) < 0) {
        perror("pipe"); return 1;
    }
    pid_t pid1 = fork();
    if (pid1 == 0) {
        dup2(pipe1[1], STDOUT_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        execlp("ls", "ls", "/etc", (char *)NULL);
        perror("exec ls"); _exit(1);
    }
    pid_t pid2 = fork();
    if (pid2 == 0) {
        dup2(pipe1[0], STDIN_FILENO);
        dup2(pipe2[1], STDOUT_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        execlp("grep", "grep", "conf", (char *)NULL);
        perror("exec grep"); _exit(1);
    }
    pid_t pid3 = fork();
    if (pid3 == 0) {
        dup2(pipe2[0], STDIN_FILENO);
        close(pipe1[0]); close(pipe1[1]);
        close(pipe2[0]); close(pipe2[1]);
        execlp("wc", "wc", "-l", (char *)NULL);
        perror("exec wc"); _exit(1);
    }
    close(pipe1[0]); close(pipe1[1]);
    close(pipe2[0]); close(pipe2[1]);
    waitpid(pid1, NULL, 0);
    waitpid(pid2, NULL, 0);
    waitpid(pid3, NULL, 0);
    printf("\n上記は ls /etc | grep conf | wc -l と同じ結果\n");
    printf("シェルの | は pipe() + fork() + dup2() + exec() の組み合わせ\n");
    return 0;
}
CCODE

gcc -o mini_pipeline mini_pipeline.c
echo "--- 実行結果 ---"
./mini_pipeline
echo ""

echo "--- シェルでの同等コマンド ---"
echo -n "ls /etc | grep conf | wc -l = "
ls /etc | grep conf | wc -l
echo ""
echo "→ シェルの | 記号の裏側で、同じシステムコールが動いている"

# ============================================
echo ""
echo "============================================"
echo " 演習4: open(), read(), write() — 統一インタフェース"
echo "============================================"
echo ""
# ============================================

cat << 'CCODE' > file_ops.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

int main(void) {
    const char *path = "/tmp/unix_test.txt";
    const char *data = "UNIXはCで書かれ、CはUNIXのために作られた。\n"
                       "この共進化が、両者の一貫性の源泉である。\n";
    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) { perror("open for write"); return 1; }
    printf("ファイル '%s' をfd=%dで開いた（書き込み用）\n", path, fd);
    write(fd, data, strlen(data));
    close(fd);
    fd = open(path, O_RDONLY);
    if (fd < 0) { perror("open for read"); return 1; }
    printf("ファイル '%s' をfd=%dで開いた（読み取り用）\n\n", path, fd);
    char buf[256];
    ssize_t n;
    while ((n = read(fd, buf, sizeof(buf) - 1)) > 0) {
        buf[n] = '\0';
        printf("read()が%zd バイト返した:\n%s", n, buf);
    }
    close(fd);
    printf("\n--- 同じread()でパイプからも読める ---\n");
    int pipefd[2];
    pipe(pipefd);
    const char *msg = "パイプもファイルも、read()は同じ\n";
    write(pipefd[1], msg, strlen(msg));
    close(pipefd[1]);
    n = read(pipefd[0], buf, sizeof(buf) - 1);
    buf[n] = '\0';
    printf("パイプからread(): %s", buf);
    close(pipefd[0]);
    printf("\n→ open/read/write/close の4つで、ファイルもパイプも扱える\n");
    printf("→ これがUNIXの「統一インタフェース」の設計原則\n");
    unlink(path);
    return 0;
}
CCODE

gcc -o file_ops file_ops.c
echo "--- 実行結果 ---"
./file_ops

# ============================================
echo ""
echo "============================================"
echo " 全演習完了"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""
echo "生成されたファイル:"
ls -la "${WORKDIR}"
echo ""
echo "UNIXのシステムコール fork(), exec(), pipe(), open(), read(), write() を"
echo "C言語から直接呼び出し、シェルの裏側で何が起きているかを体験した。"
