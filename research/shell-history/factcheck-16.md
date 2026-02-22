# ファクトチェック記録：第16回「シェルとセキュリティ――インジェクション、eval、権限昇格」

## 1. Shellshock（CVE-2014-6271）の発見と公表

- **結論**: Stephane Chazelasが2014年9月12日にbashメンテナのChet Rameyに報告。2014年9月24日にパッチとともに公表。Chazelasはこのバグを「Bashdoor」と呼んだ。Chazelasは英国ロボティクス企業SeeByte社のUnix/Linuxネットワーク・テレコム管理者だった
- **一次ソース**: Wikipedia, "Shellshock (software bug)"; NVD CVE-2014-6271; CISA Alert
- **URL**: <https://en.wikipedia.org/wiki/Shellshock_(software_bug)>, <https://nvd.nist.gov/vuln/detail/cve-2014-6271>, <https://www.cisa.gov/news-events/alerts/2014/09/25/gnu-bourne-again-shell-bash-shellshock-vulnerability-cve-2014-6271>
- **注意事項**: CVSSスコアはv2で10.0、v3で9.8。影響範囲はbash 1.14〜4.3（一部ソースでは1.03から）
- **記事での表現**: 「2014年9月12日、Stephane ChazelasがbashメンテナのChet Rameyにバグを報告した。9月24日にパッチとともに公表された」

## 2. Shellshockの技術的メカニズム

- **結論**: bashの「関数エクスポート」機能に起因。環境変数に格納された関数定義の末尾に付加されたコマンドを、bashが新プロセス起動時に意図せず実行してしまうバグ。`env x='() { :;}; echo vulnerable' bash -c "echo test"` で検証可能
- **一次ソース**: LWN.net, "Bash gets shellshocked", 2014; Wikipedia Shellshock記事
- **URL**: <https://lwn.net/Articles/614218/>, <https://en.wikipedia.org/wiki/Shellshock_(software_bug)>
- **注意事項**: パッチでは環境変数名に`BASH_FUNC_`プレフィックスと`()`サフィックスを要求する方式に変更
- **記事での表現**: 「bashは環境変数の値が`() {`で始まる場合、それを関数定義として解釈し、内部で評価する。問題は、関数定義の終了後に続くコマンドも実行してしまうことだった」

## 3. Shellshockが導入されたバージョン

- **結論**: Brian Foxが1989年8月5日に関数エクスポート機能を追加。bash 1.03（1989年9月1日リリース）に含まれた。つまり約25年間潜伏していた
- **一次ソース**: GNU bug-bash mailing list, 2014-10; Wikipedia Shellshock記事
- **URL**: <https://lists.gnu.org/archive/html/bug-bash/2014-10/msg00149.html>, <https://en.wikipedia.org/wiki/Shellshock_(software_bug)>
- **注意事項**: 影響を受けるバージョンについてはソースにより1.03、1.14等の表記の揺れがある。機能自体は1.03で導入されたがインポート処理は1.13で追加との情報も
- **記事での表現**: 「Brian Foxが1989年8月5日にbashに関数エクスポート機能を追加した。このコードに含まれていた欠陥が、25年後の2014年に発見されるまで潜伏し続けた」

## 4. Shellshockの攻撃ベクトル

- **結論**: 主要な攻撃ベクトルは(1) Apache CGIスクリプト（HTTP_USER_AGENT等の環境変数経由）、(2) DHCPクライアント（DHCPサーバからの応答経由）、(3) OpenSSH ForceCommand機能経由。CGI経由が最も広範に悪用された
- **一次ソース**: Huntress CVE-2014-6271分析; CISA Alert
- **URL**: <https://www.huntress.com/threat-library/vulnerabilities/cve-2014-6271>, <https://www.cisa.gov/news-events/alerts/2014/09/25/gnu-bourne-again-shell-bash-shellshock-vulnerability-cve-2014-6271>
- **注意事項**: CGI経由ではWebサーバがHTTPヘッダを環境変数として渡すため、リモートから容易に悪用可能だった
- **記事での表現**: 「CGIスクリプトを介した攻撃が最も深刻だった。ApacheはHTTPヘッダをHTTP_USER_AGENTなどの環境変数としてCGIプロセスに渡す。攻撃者はHTTPリクエストのヘッダに悪意ある関数定義を埋め込むだけで、サーバ上で任意のコマンドを実行できた」

## 5. setuidシェルスクリプトのセキュリティ問題

- **結論**: setuidシェルスクリプトには(1) カーネルがスクリプトを検査する時点とインタプリタがファイルを開く時点の間のTOCTOUレースコンディション、(2) IFS変数の操作による攻撃、(3) `-i`という名前のシンボリックリンクによる対話シェル取得、などの脆弱性がある。BSD系Unixはsetuidシェルスクリプトを無効化。Linuxカーネルもsetuidビットをスクリプトに対して無視する
- **一次ソース**: David Wheeler, "Avoid Creating Setuid/Setgid Scripts"; Wikipedia "Setuid"
- **URL**: <https://dwheeler.com/secure-programs/Secure-Programs-HOWTO/avoid-setuid.html>, <https://en.wikipedia.org/wiki/Setuid>
- **注意事項**: System Vは当初setuidスクリプトを許可していたがBSDは早期に無効化した
- **記事での表現**: 「BSD系Unixは早い段階でsetuidシェルスクリプトを無効化した。カーネルがスクリプトのsetuidビットを検査する時点と、インタプリタがファイルを実際に開く時点の間にレースコンディションが存在するためだ」

## 6. CGI時代のシェルインジェクション

- **結論**: CGI（Common Gateway Interface）スクリプトはWeb初期から脆弱性の温床だった。ユーザー入力をフォームやクエリ文字列経由で受け取り、サニタイズ不足のままシェルコマンドに渡すパターンが典型的。W3CのWWW Security FAQでもCGIスクリプトの危険性が警告されていた
- **一次ソース**: W3C WWW Security FAQ: CGI Scripts; UC Davis SecLab "CGI-BIN Specific Vulnerabilities"
- **URL**: <https://www.w3.org/Security/Faq/wwwsf4.html>, <https://seclab.cs.ucdavis.edu/projects/testing/papers/cgi.html>
- **注意事項**: 1990年代後半にCGIスクリプトの脆弱性が多数報告された
- **記事での表現**: 「Web黎明期のCGIスクリプトは、シェルインジェクションの教科書的な例を数多く生み出した。ユーザーのフォーム入力を無検証のまま`system()`やバッククォートでシェルに渡すコードが、当時のWebサーバに溢れていた」

## 7. evalの危険性

- **結論**: evalはシェルの最も危険なビルトインの一つ。二重解析（シェルが一度パースし、evalが再度パースする）を行うため、外部入力が混入すると任意コマンド実行が可能になる。Greg's Wiki (wooledge.org) のBashFAQ/048でも「evalを避けるべき理由」が詳述されている
- **一次ソース**: Greg's Wiki BashFAQ/048; Apple Shell Script Security documentation; Baeldung "Safe Use of eval in Bash"
- **URL**: <https://mywiki.wooledge.org/BashFAQ/048>, <https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting/ShellScriptSecurity/ShellScriptSecurity.html>, <https://www.baeldung.com/linux/bash-safe-use-eval>
- **注意事項**: evalの代替として配列によるコマンド構築が推奨される
- **記事での表現**: 「evalは受け取った文字列をシェルコマンドとして再評価する。この二重解析が、外部入力を含む場合に致命的なインジェクション経路を開く」

## 8. ShellCheckの開発経緯

- **結論**: ShellCheckはVidar Holen（ハンドルネーム: koala_man）がHaskellで開発した静的解析ツール。Copyright表記は2012年から。GitHubで最もスターが多いHaskellプロジェクトとなった。SC2086（未クォートの変数展開）など、セキュリティに直結する警告を多数提供する
- **一次ソース**: GitHub koalaman/shellcheck; Vidar Holen's Blog "Lessons learned from writing ShellCheck"
- **URL**: <https://github.com/koalaman/shellcheck>, <https://www.vidarholen.net/contents/blog/?p=859>
- **注意事項**: コンパイルに2GBのRAMが必要
- **記事での表現**: 「2012年、Vidar HolenがHaskellで開発したShellCheckは、シェルスクリプトの静的解析ツールとして事実上の標準となった」

## 9. コマンドインジェクション対策のベストプラクティス

- **結論**: OWASP推奨事項: (1) OS コマンド実行を避ける（言語のAPIを使う）、(2) 入力をホワイトリストで検証する、(3) メタ文字のエスケープに頼らない。シェルスクリプト固有の対策: (1) 外部入力は必ずダブルクォートで囲む、(2) evalを使わない、(3) `--`でオプション終端を明示する
- **一次ソース**: OWASP OS Command Injection Defense Cheat Sheet; Apple Shell Script Security
- **URL**: <https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html>, <https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting/ShellScriptSecurity/ShellScriptSecurity.html>
- **注意事項**: `--`はPOSIXガイドライン10で規定されている
- **記事での表現**: 「POSIX Utility Syntax Guidelinesのガイドライン10は、最初の`--`引数をオプション終端として扱い、以降の引数はすべてオペランドとして処理すると規定している」

## 10. Shellshock関連CVEの全体像

- **結論**: CVE-2014-6271（Chazelasが発見、元のバグ）、CVE-2014-7169（Tavis Ormandy発見、不完全なパッチの回避）、CVE-2014-7186, CVE-2014-7187（Florian Weimer of Red Hat発見）、CVE-2014-6277, CVE-2014-6278（Michal Zalewski発見、関数定義パース関連）。合計6つのCVE
- **一次ソース**: CISA Alert; Wikipedia Shellshock
- **URL**: <https://www.cisa.gov/news-events/alerts/2014/09/25/gnu-bourne-again-shell-bash-shellshock-vulnerability-cve-2014-6271>, <https://en.wikipedia.org/wiki/Shellshock_(software_bug)>
- **注意事項**: 最初のパッチは不完全で、CVE-2014-7169として追加報告された
- **記事での表現**: 「Shellshockは単一の脆弱性ではなく、6つのCVEからなる脆弱性ファミリだった」
