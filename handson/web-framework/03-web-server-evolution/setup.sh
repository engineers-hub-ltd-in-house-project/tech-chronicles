#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/web-framework-handson-03"

echo "============================================"
echo " 第3回ハンズオン: CGI vs FastCGI パフォーマンス比較"
echo "============================================"
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# -----------------------------------------------
echo ""
echo "--- 1. Docker環境の起動 ---"
echo ""

cat > Dockerfile << 'DOCKERFILE'
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    apache2 \
    perl \
    libcgi-pm-perl \
    libfcgi-perl \
    libapache2-mod-fcgid \
    curl \
    apache2-utils \
    procps \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod cgi cgid fcgid

COPY scripts/ /opt/scripts/
RUN chmod +x /opt/scripts/*.sh

EXPOSE 80
CMD ["/opt/scripts/entrypoint.sh"]
DOCKERFILE

# -----------------------------------------------
echo ""
echo "--- 2. スクリプトの作成 ---"
echo ""

mkdir -p scripts

# エントリポイント
cat > scripts/entrypoint.sh << 'ENTRY'
#!/bin/bash
set -euo pipefail

# CGIスクリプトの配置
cp /opt/scripts/bench_cgi.pl /usr/lib/cgi-bin/bench_cgi.pl
chmod 755 /usr/lib/cgi-bin/bench_cgi.pl

# FastCGIスクリプトの配置
mkdir -p /var/www/fcgi-bin
cp /opt/scripts/bench_fcgi.pl /var/www/fcgi-bin/bench_fcgi.pl
chmod 755 /var/www/fcgi-bin/bench_fcgi.pl

# FastCGI設定
cat > /etc/apache2/conf-available/fcgi-benchmark.conf << 'CONF'
FcgidWrapper /var/www/fcgi-bin/bench_fcgi.pl .fcgi
FcgidMaxRequestLen 1048576

<Directory "/var/www/fcgi-bin">
    AllowOverride None
    Options +ExecCGI
    Require all granted
    SetHandler fcgid-script
</Directory>

Alias /fcgi-bin/ /var/www/fcgi-bin/

<Location /fcgi-bin/>
    SetHandler fcgid-script
    Options +ExecCGI
</Location>
CONF

a2enconf fcgi-benchmark

echo "Apache起動中..."
apachectl start

echo ""
echo "=== 環境準備完了 ==="
echo "CGI:     http://localhost/cgi-bin/bench_cgi.pl"
echo "FastCGI: http://localhost/fcgi-bin/bench_fcgi.pl"
echo ""

# コンテナを維持
exec tail -f /var/log/apache2/error.log
ENTRY

# CGIスクリプト
cat > scripts/bench_cgi.pl << 'SCRIPT'
#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use POSIX qw(strftime);
use File::Basename;

my $q = CGI->new;
my $now = strftime("%Y-%m-%d %H:%M:%S", localtime);
my $pid = $$;

print $q->header('text/html');
print <<HTML;
<html>
<body>
<h1>CGI Benchmark</h1>
<p>Time: $now</p>
<p>PID: $pid</p>
<p>Mode: CGI (new process per request)</p>
</body>
</html>
HTML
SCRIPT

# FastCGIスクリプト
cat > scripts/bench_fcgi.pl << 'SCRIPT'
#!/usr/bin/perl
use strict;
use warnings;
use FCGI;
use POSIX qw(strftime);
use File::Basename;

my $request = FCGI::Request();
my $count = 0;

while ($request->Accept() >= 0) {
    $count++;
    my $now = strftime("%Y-%m-%d %H:%M:%S", localtime);
    my $pid = $$;

    print "Content-type: text/html\r\n\r\n";
    print <<HTML;
<html>
<body>
<h1>FastCGI Benchmark</h1>
<p>Time: $now</p>
<p>PID: $pid</p>
<p>Request count: $count</p>
<p>Mode: FastCGI (persistent process)</p>
</body>
</html>
HTML
}
SCRIPT

# ベンチマークスクリプト
cat > scripts/run_benchmark.sh << 'BENCH'
#!/bin/bash
set -euo pipefail

echo "============================================"
echo " CGI vs FastCGI ベンチマーク"
echo "============================================"

echo ""
echo "--- 基本テスト: 100リクエスト、同時接続数10 ---"
echo ""

echo "=== CGI ==="
ab -n 100 -c 10 http://localhost/cgi-bin/bench_cgi.pl 2>&1 | \
  grep -E '(Requests per second|Time per request|Failed requests|Complete requests)'

echo ""
echo "=== FastCGI ==="
ab -n 100 -c 10 http://localhost/fcgi-bin/bench_fcgi.pl 2>&1 | \
  grep -E '(Requests per second|Time per request|Failed requests|Complete requests)'

echo ""
echo "--- 高負荷テスト: 1000リクエスト、同時接続数50 ---"
echo ""

echo "=== CGI ==="
ab -n 1000 -c 50 http://localhost/cgi-bin/bench_cgi.pl 2>&1 | \
  grep -E '(Requests per second|Time per request|Failed requests|Complete requests)'

echo ""
echo "=== FastCGI ==="
ab -n 1000 -c 50 http://localhost/fcgi-bin/bench_fcgi.pl 2>&1 | \
  grep -E '(Requests per second|Time per request|Failed requests|Complete requests)'

echo ""
echo "============================================"
echo " ベンチマーク完了"
echo "============================================"
BENCH

chmod +x scripts/*.sh

# -----------------------------------------------
echo ""
echo "--- 3. Docker環境のビルドと起動 ---"
echo ""

docker build -t fcgi-lab "${WORKDIR}"
docker run -d --rm -p 8080:80 --name fcgi-lab fcgi-lab

echo ""
echo "コンテナ起動完了。数秒待ってからテストを実行します..."
sleep 3

# -----------------------------------------------
echo ""
echo "--- 4. 動作確認 ---"
echo ""

echo "CGI動作確認:"
curl -s http://localhost:8080/cgi-bin/bench_cgi.pl | grep -E '(PID|Mode)'

echo ""
echo "FastCGI動作確認:"
curl -s http://localhost:8080/fcgi-bin/bench_fcgi.pl | grep -E '(PID|Mode|Request count)'

# -----------------------------------------------
echo ""
echo "--- 5. ベンチマーク実行 ---"
echo ""

docker exec fcgi-lab /opt/scripts/run_benchmark.sh

# -----------------------------------------------
echo ""
echo "============================================"
echo " セットアップ完了"
echo "============================================"
echo ""
echo "手動でベンチマークを再実行するには:"
echo "  docker exec fcgi-lab /opt/scripts/run_benchmark.sh"
echo ""
echo "コンテナに入って操作するには:"
echo "  docker exec -it fcgi-lab bash"
echo ""
echo "後片付け:"
echo "  docker stop fcgi-lab"
echo "  rm -rf ${WORKDIR}"
