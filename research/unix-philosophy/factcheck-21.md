# ファクトチェック記録：第21回「WSL――WindowsがUNIXに屈服した日」

## 1. Steve Ballmerの「Linux is a cancer」発言

- **結論**: 2001年6月1日、Chicago Sun-Timesのインタビューで発言。原文は "Linux is a cancer that attaches itself in an intellectual property sense to everything it touches."
- **一次ソース**: Chicago Sun-Times, 2001年6月1日付インタビュー
- **URL**: <https://www.theregister.com/2001/06/02/ballmer_linux_is_a_cancer/>
- **注意事項**: BallmerはGPLの「感染性」（コピーレフト）を批判していた。Linuxそのものの技術的品質を否定する文脈ではなく、知的財産権への影響を懸念する発言。同インタビューでLinuxを "good competition" とも評している
- **記事での表現**: 「2001年6月、MicrosoftのCEOスティーブ・バルマーはChicago Sun-Timesのインタビューで『Linuxは知的財産の観点から、触れるものすべてに取り付く癌だ』と発言した」

## 2. Satya Nadellaの「Microsoft loves Linux」宣言

- **結論**: 2014年10月、サンフランシスコでのクラウドイベントで "Microsoft ♥ Linux" のスライドを提示。当時Azure上のVMの20%がLinuxだった
- **一次ソース**: The Register, 2014年10月20日報道
- **URL**: <https://www.theregister.com/2014/10/20/microsoft_cloud_event/>
- **注意事項**: ナデラは2014年2月にCEO就任。「古い戦いに興味はない」と述べ、クラウドファーストへの転換を明確にした
- **記事での表現**: 「2014年10月、サティア・ナデラは "Microsoft ♥ Linux" と書かれたスライドを掲げ、Microsoftの方針転換を世界に宣言した」

## 3. WSL 1のリリースと技術アーキテクチャ

- **結論**: 2016年3月30日のBuild 2016でKevin Galloが発表。"Bash on Ubuntu on Windows" として告知。Windows 10 Anniversary Update（バージョン1607、2016年8月2日）でベータ提供開始。技術的にはpico processプロバイダ（lxss.sys/lxcore.sys）がLinux syscallをWindows NTカーネル上で変換
- **一次ソース**: Windows Developer Blog, 2016年3月30日; Tara Raj, "When We Brought Linux to Windows", Medium
- **URL**: <https://blogs.windows.com/windowsdeveloper/2016/03/30/run-bash-on-ubuntu-on-windows/>
- **注意事項**: 発表時の聴衆の反応は極めて大きく、Channel9の配信がDDoS攻撃と勘違いされるほどのアクセスを集めた
- **記事での表現**: 「2016年のBuild基調講演でKevin GalloがWSLを発表した瞬間、会場は沸き立った。Channel9チームはアクセス殺到をDDoS攻撃と誤認したほどだ」

## 4. WSL 2のリリースとアーキテクチャ

- **結論**: 2019年5月6日に発表。Windows 10バージョン2004で提供開始。Hyper-Vの軽量VMテクノロジーを使用し、実際のLinuxカーネル（初期はバージョン4.19）を搭載。WSL 1のsyscall変換レイヤーとは根本的に異なるアーキテクチャ
- **一次ソース**: Microsoft DevBlogs "Announcing WSL 2", 2019年5月6日
- **URL**: <https://devblogs.microsoft.com/commandline/announcing-wsl-2/>
- **注意事項**: 2018年のMicrosoft Igniteで軽量Hyper-V VMテクノロジーの概要が先に紹介されていた。Insider Preview向けには2019年6月末から利用可能
- **記事での表現**: 「2019年、WSL 2で根本的なアーキテクチャ転換が行われた。syscall変換レイヤーを廃止し、Hyper-Vの軽量VM上で実際のLinuxカーネル（バージョン4.19）を動かす方式に移行した」

## 5. Azure上のLinux VMの過半数超え

- **結論**: 2017年時点でAzure VMの40%がLinux。2018年にScott Guthrieが「わずかに半数超」と発言。2019年2月時点でAzureのデプロイ容量の54%がLinux
- **一次ソース**: Slashdot/ZDNet報道（2019年7月）; Build5Nines "Linux is Most Used OS in Microsoft Azure"
- **URL**: <https://build5nines.com/linux-is-most-used-os-in-microsoft-azure-over-50-percent-fo-vm-cores/>
- **注意事項**: 「過半数」の具体的な時期は2018年後半〜2019年初頭。比率の測定方法（VM数 vs VMコア数）で数値が異なる場合がある
- **記事での表現**: 「2019年の時点で、Azure上のVM容量の過半数がLinuxで稼働していた。Microsoftのクラウドプラットフォーム上で、LinuxがWindowsを上回ったのだ」

## 6. WSLgによるLinux GUIアプリサポート

- **結論**: 2021年のBuildで正式発表。Windows 10 Insider build 21364以降で利用可能。Windows 11で一般提供。WaylandとX11の両方をサポート。システムディストリビューション内でWeston（Waylandコンポジタ）とXWaylandを動作させ、OpenGLレンダリングはD3D12 Galliumドライバ経由でGPUアクセラレーション可能
- **一次ソース**: Microsoft DevBlogs, 2021年4月; GitHub microsoft/wslg
- **URL**: <https://devblogs.microsoft.com/commandline/the-initial-preview-of-gui-app-support-is-now-available-for-the-windows-subsystem-for-linux-2/>
- **注意事項**: WSLg はWSL 2でのみ動作。システムディストリはMicrosoft Azure Linux 3.0ベース
- **記事での表現**: 「2021年にはWSLgが登場し、Linux GUIアプリケーションをWindowsデスクトップ上でネイティブに近い形で実行可能になった」

## 7. WSLでのsystemdサポート

- **結論**: WSL バージョン0.67.6で公式にsystemdサポートが追加された。2022年にMicrosoftとCanonicalが共同で発表。/etc/wsl.confでsystemd=trueを設定することで有効化
- **一次ソース**: Microsoft DevBlogs "Systemd support is now available in WSL!", 2022年; GitHub Release 0.67.6
- **URL**: <https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/>
- **注意事項**: systemd以前のWSLはinitプロセスが独自のものだった。systemdサポートにより、snapパッケージやDockerデーモンなどsystemdに依存するサービスの実行が容易に
- **記事での表現**: 「2022年、WSL 0.67.6でsystemdの公式サポートが追加された。MicrosoftとCanonicalの共同作業の成果だ」

## 8. Windows NTカーネルとUNIXの設計思想の差異

- **結論**: UNIXは "Everything is a file"（統一インタフェースとしてのファイル）、Windows NTは "Everything is an object"（Object Managerによる型付きオブジェクト管理）。NTの設計者Dave CutlerはDEC VMS（1978年）の設計者でもあり、VMSのオブジェクト管理の思想をNTに持ち込んだ。NTカーネルではファイル、スレッド、レジストリキーなどすべてが名前付きオブジェクトとして管理され、個別のACLで保護される
- **一次ソース**: Windows NT Wikipedia; Dave Cutler Wikipedia; Microsoft News "The engineer's engineer"
- **URL**: <https://en.wikipedia.org/wiki/Windows_NT>
- **注意事項**: VMS→NTの直接的なコード移植はないが、設計哲学の継承は公知の事実。Dave Cutlerは1988年にDECからMicrosoftに移籍
- **記事での表現**: 「UNIXが『すべてはファイルである』を掲げた一方、Windows NTは『すべてはオブジェクトである』という設計哲学を採用した。Dave Cutlerが1978年のVAX/VMSから持ち込んだObject Manager機構だ」

## 9. WSL 1 vs WSL 2のトレードオフ

- **結論**: WSL 2はLinuxファイルシステム上で20倍高速（tarball展開）、git clone等で2-5倍高速。ただしWindowsファイルシステム（/mnt/c等NTFS）へのアクセスはWSL 1の約5倍遅い。WSL 2はNATベースの仮想ネットワーク（IPアドレスが再起動で変わる）を使用し、WSL 1はホストNICを直接共有
- **一次ソース**: Microsoft Learn "Comparing WSL Versions"
- **URL**: <https://learn.microsoft.com/en-us/windows/wsl/compare-versions>
- **注意事項**: WSL 2のファイルシステム性能の非対称性（Linux FS vs Windows FS）は開発者が知るべき重要なトレードオフ
- **記事での表現**: 「WSL 2はLinuxファイルシステム上の操作を劇的に高速化したが、Windowsファイルシステムへのクロスアクセスは逆に遅くなった。仮想化の境界がそのまま性能特性に現れている」

## 10. Visual Studio Code + Remote WSL統合

- **結論**: VS Code Remote - WSL拡張はVS Code 1.35（2019年5月リリース）以降で利用可能。WSL内のファイルシステムに対してフルのVS Code機能を提供。Windows側のVS CodeがWSL内のファイルを直接編集できる
- **一次ソース**: VS Code公式ドキュメント "Developing in WSL"
- **URL**: <https://code.visualstudio.com/docs/remote/wsl>
- **注意事項**: Remote Development Extension Packの一部として提供。SSH、コンテナ、WSLの3環境に対応
- **記事での表現**: 「VS CodeのRemote - WSL拡張により、Windows上のエディタからWSL内のファイルシステムをシームレスに編集できる」

## 11. MicrosoftのGitHub買収とOSS戦略転換

- **結論**: 2018年6月4日に75億ドルでの買収を発表。同年10月26日に完了。2014年11月12日に.NET Coreをオープンソース化しクロスプラットフォーム対応。2016年にはLinux Foundation加入。ナデラのCEO就任（2014年2月）以降、体系的にOSS戦略を転換
- **一次ソース**: Microsoft News "Microsoft to acquire GitHub for $7.5 billion", 2018年6月4日; Microsoft News ".NET open source", 2014年11月12日
- **URL**: <https://news.microsoft.com/source/2018/06/04/microsoft-to-acquire-github-for-7-5-billion/>
- **注意事項**: GitHub買収後もGitHubは独立運営を維持。2025年のBuild 2025でWSL自体もオープンソース化された
- **記事での表現**: 「2014年に.NETをオープンソース化し、2016年にLinux Foundationに加入し、2018年にGitHubを75億ドルで買収した。この一連の動きは、ナデラ体制下でのMicrosoftの根本的な方針転換を示している」

## 12. WSL開発の主要人物

- **結論**: Jack Hammons（Linux Systems Group プログラムマネージャー）、Ben Hillis（WSLリードソフトウェアエンジニア）、Tara Raj、Rich Turner、Craig Wilhite、Sunil Muthuswamy、Yosef Durrらが中心的役割を果たした。Linux Systems Groupを中心に複数チームが横断的に開発
- **一次ソース**: Microsoft DevBlogs; Tara Raj, "When We Brought Linux to Windows", Medium
- **URL**: <https://medium.com/microsoft-open-source-stories/when-linux-came-to-windows-204cf9abb3d6>
- **注意事項**: WSLの開発はMicrosoft内部でも当初は懐疑的に見られていた部分がある。Kevin GalloがBuild 2016の基調講演で発表
- **記事での表現**: 「WSLの開発にはJack Hammons、Ben Hillisらが中心的な役割を果たし、Microsoft内の複数チームが横断的に参加した」
