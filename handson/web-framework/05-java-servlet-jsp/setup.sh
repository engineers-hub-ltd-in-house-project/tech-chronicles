#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/web-framework-handson-05"

echo "================================================="
echo " 第5回ハンズオン: 素のServletでWebアプリケーション"
echo "================================================="
echo ""
echo "作業ディレクトリ: ${WORKDIR}"
echo ""

# -------------------------------------------
# セクション1: ディレクトリ構造の準備
# -------------------------------------------
echo ">>> セクション1: WARディレクトリ構造の作成"

mkdir -p "${WORKDIR}/WEB-INF/classes"
cd "${WORKDIR}"

echo "ディレクトリ構造:"
echo "  ${WORKDIR}/"
echo "    WEB-INF/"
echo "      classes/    -- コンパイル後の .class を配置する場所"
echo "      web.xml     -- 宣言的設定"
echo "    Dockerfile"
echo ""

# -------------------------------------------
# セクション2: 演習1 -- 最小の HttpServlet
# -------------------------------------------
echo ">>> セクション2: 演習1 -- 最小のHttpServlet"

cat > "${WORKDIR}/WEB-INF/classes/HelloServlet.java" << 'JAVA'
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class HelloServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Hello Servlet</title></head>");
        out.println("<body>");
        out.println("<h1>Hello from Java Servlet</h1>");
        out.println("<p>Method: " + request.getMethod() + "</p>");
        out.println("<p>URI: " + request.getRequestURI() + "</p>");
        out.println("<p>Query: " + request.getQueryString() + "</p>");
        out.println("<p>User-Agent: "
                + request.getHeader("User-Agent") + "</p>");
        out.println("</body></html>");
    }
}
JAVA

echo "HelloServlet.java を作成しました"
echo ""

# -------------------------------------------
# セクション3: 演習2 -- 追加 Servlet と web.xml
# -------------------------------------------
echo ">>> セクション3: 演習2 -- web.xmlでURLマッピングを定義"

cat > "${WORKDIR}/WEB-INF/classes/UserServlet.java" << 'JAVA'
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class UserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        // URI例: /handson/users/42 -> path = "/users/42"
        String path = request.getRequestURI()
                .substring(request.getContextPath().length());
        out.println("<!DOCTYPE html><html><body>");
        out.println("<h1>User Servlet</h1>");
        out.println("<p>Path: " + path + "</p>");
        out.println("</body></html>");
    }
}
JAVA

cat > "${WORKDIR}/WEB-INF/web.xml" << 'XML'
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee
           https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">

    <servlet>
        <servlet-name>hello</servlet-name>
        <servlet-class>HelloServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>hello</servlet-name>
        <url-pattern>/hello</url-pattern>
    </servlet-mapping>

    <servlet>
        <servlet-name>user</servlet-name>
        <servlet-class>UserServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>user</servlet-name>
        <url-pattern>/users/*</url-pattern>
    </servlet-mapping>

    <filter>
        <filter-name>logging</filter-name>
        <filter-class>LoggingFilter</filter-class>
    </filter>
    <filter-mapping>
        <filter-name>logging</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>
</web-app>
XML

echo "UserServlet.java と web.xml を作成しました"
echo ""

# -------------------------------------------
# セクション4: 演習3 -- フィルタチェーン
# -------------------------------------------
echo ">>> セクション4: 演習3 -- フィルタチェーンの実装"

cat > "${WORKDIR}/WEB-INF/classes/LoggingFilter.java" << 'JAVA'
import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;

public class LoggingFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("[LoggingFilter] initialized");
    }

    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        long start = System.currentTimeMillis();

        System.out.println("[LOG] >>> " + req.getMethod()
                + " " + req.getRequestURI());

        // 次のフィルタまたはServletに処理を委譲
        chain.doFilter(request, response);

        long elapsed = System.currentTimeMillis() - start;
        System.out.println("[LOG] <<< " + elapsed + "ms");
    }

    @Override
    public void destroy() {
        System.out.println("[LoggingFilter] destroyed");
    }
}
JAVA

echo "LoggingFilter.java を作成しました"
echo ""

# -------------------------------------------
# セクション5: 演習4 -- Dockerfile と Tomcat デプロイ
# -------------------------------------------
echo ">>> セクション5: 演習4 -- Dockerfileの作成"

cat > "${WORKDIR}/Dockerfile" << 'DOCKERFILE'
FROM eclipse-temurin:21-jdk AS builder

# Tomcat 10.1 のダウンロードと展開
RUN apt-get update && apt-get install -y wget && \
    wget -q https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.39/bin/apache-tomcat-10.1.39.tar.gz && \
    tar xzf apache-tomcat-10.1.39.tar.gz && \
    mv apache-tomcat-10.1.39 /opt/tomcat && \
    rm apache-tomcat-10.1.39.tar.gz

# Servletのコンパイル
WORKDIR /build
COPY WEB-INF/classes/*.java ./
RUN javac -cp /opt/tomcat/lib/servlet-api.jar -d ./classes *.java

FROM eclipse-temurin:21-jre

COPY --from=builder /opt/tomcat /opt/tomcat
COPY --from=builder /build/classes /opt/tomcat/webapps/handson/WEB-INF/classes
COPY WEB-INF/web.xml /opt/tomcat/webapps/handson/WEB-INF/web.xml

EXPOSE 8080
CMD ["/opt/tomcat/bin/catalina.sh", "run"]
DOCKERFILE

echo "Dockerfile を作成しました"
echo ""

# -------------------------------------------
# セクション6: ビルドと動作確認
# -------------------------------------------
echo ">>> セクション6: Dockerビルドと動作確認"

if ! command -v docker > /dev/null 2>&1; then
  echo "WARNING: docker コマンドが見つかりません。"
  echo "Dockerをインストール後、以下を手動で実行してください:"
  echo ""
  echo "  cd ${WORKDIR}"
  echo "  docker build -t servlet-handson ."
  echo "  docker run -d -p 8080:8080 --name servlet-handson servlet-handson"
  echo "  curl http://localhost:8080/handson/hello"
  echo ""
else
  echo "Dockerイメージをビルドします（数分かかります）..."
  cd "${WORKDIR}"
  docker build -t servlet-handson . > /tmp/servlet-handson-build.log 2>&1 || {
    echo "ビルド失敗。ログ: /tmp/servlet-handson-build.log"
    tail -20 /tmp/servlet-handson-build.log
    exit 1
  }
  echo "ビルド成功"

  # 既存コンテナを掃除
  docker rm -f servlet-handson 2>/dev/null || true

  docker run -d -p 8080:8080 --name servlet-handson servlet-handson > /dev/null
  echo "コンテナ起動中（Tomcatの起動を待機）..."
  sleep 8

  echo ""
  echo "--- GET /handson/hello ---"
  curl -s http://localhost:8080/handson/hello | head -20
  echo ""

  echo "--- GET /handson/hello?name=World ---"
  curl -s "http://localhost:8080/handson/hello?name=World" | head -10
  echo ""

  echo "--- GET /handson/users/42 ---"
  curl -s http://localhost:8080/handson/users/42 | head -10
  echo ""

  echo "--- フィルタチェーンのログ ---"
  docker logs servlet-handson 2>&1 | grep '\[LOG\]' | head -10
  echo ""

  echo "後片付けは以下を実行:"
  echo "  docker stop servlet-handson && docker rm servlet-handson"
fi

echo ""
echo "================================================="
echo " ハンズオン完了"
echo " 作業ディレクトリ: ${WORKDIR}"
echo "================================================="
