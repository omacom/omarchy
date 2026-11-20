# Mac または Windows から来た人へ

macOS または Windows で何年も過ごしてきた人は、指が覚えていることの方が、脳が覚えたと自覚していることよりずっと多い。この章は、そのための翻訳レイヤーだ。あなたの本能が Omarchy ではどこへ向かうのかを示す。機能そのものについては elsewhere で詳しく扱っている。ここにあるのは地図だけだ。

### Super がすべての中心

Cmd または Windows キーの周りに築いてきた指の記憶は、すべてこの一つのキーへ移る。Super だ。PC キーボードでは Windows キーのことで、Omarchy のほぼすべてのホットキーの基点になる。

Spotlight や Raycast や Start メニューを開きたくなる反射は `Super + Space` になる。これで Omarchy menu が開き、アプリを起動し、設定を変更し、ソフトウェアをインストールし、画面をキャプチャできる。ほぼ何でもだ。入力を始めれば絞り込める。`Super + Alt + Space` では Launchpad のようにすべてのアプリがグリッド状に表示される。[navigation](04-navigation.md) を参照。

### デスクトップアイコンはなく、ドックはフローティングのときだけ現れる

デスクトップに並べるアイコンはなく、タイリング workspace にはドックもない。ドックはフローティング workspace でのみ表示される（[navigation](04-navigation.md) を参照）。アプリはホットキー（ターミナルは `Super + Return`、ブラウザは `Super + Shift + Return`、割り当て済みのすべてのものの一覧は `Super + K`）または menu から起動する。常に存在する唯一の UI は [the top bar](05-the-top-bar.md) で、以前の menu bar、システムトレイ、Notification Center が担っていた役割をカバーする。その上のほぼすべての widget は、左クリック、右クリック、中クリックで何かしらの動作をする。

### ウィンドウは自分で配置される

最大の考え方の転換はこれだ。ウィンドウをドラッグしたり、画面の半分にスナップしたりはしない。ウィンドウを開けば画面全体を使う。2つ目を開けば画面を分割する。ウィンドウが重ならないので、別のウィンドウの下から探し出すことも決してない。

本当にフローティングウィンドウが必要なときは、`Super + T` でアクティブなウィンドウをタイリングの外へ切り替える（戻すこともできる）。だがまずはタイリングに本気でチャンスをやってくれ。全システムの心臓部だ。[Navigation](04-navigation.md) で一通り説明している。

Workspaces は馴染み深いはずだ。macOS の Spaces や Windows の仮想デスクトップと同じだが、実際によく使うようになる。`Super + 1/2/3/4` で直接ジャンプでき、`Super + Shift + 1/2/3/4` でアクティブなウィンドウをそこへ送れるからだ。アニメーションの遅延はなく、即座にジャンプする。つまり以前マルチモニターに慣れていた人でも、もう必要なくなるかもしれない。

### コピーとペーストはそのまま動く

Mac ではどこでも Cmd + C だった。Windows ではどこでも Ctrl + C だった。ターミナルだけは例外で、プログラムを終了させてしまう。Omarchy では `Super + C`、`Super + X`、`Super + V` があり、ターミナルを含めどこでも動く。シェル用に別の反射を覚える必要はない。

Windows の人へ。Win + V のクリップボード履歴は `Super + Ctrl + V` にあり、テキストだけでなく画像も保持する。[unified clipboard & history](08-unified-clipboard-history.md) を参照。

### 対訳表

| あなたが求めるもの | Omarchy では |
| ------------- | ---------- |
| Spotlight / Raycast / Start menu | `Super + Space` — Omarchy menu |
| AirDrop | LocalSend、`Super + Ctrl + S` 経由 — [GUIs](22-guis.md) を参照 |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` または `Print Screen` — [screenshots & recording](12-screenshots-recording.md) を参照 |
| Notification Center | 通知履歴は `Super + Shift + Alt + ,` |
| Time Machine（システム用） | 更新ごとに自動で [system snapshots](47-system-snapshots.md) |
| App Store / インストーラーのダウンロード | menu の _Install_、または `omarchy pkg add` — [other packages](29-other-packages.md) を参照 |
| System Settings / Control Panel | menu の _Setup_、プレーンな設定ファイルを編集する — [dotfiles](31-dotfiles.md) を参照 |
| Finder / File Explorer | Files、`Super + Shift + F` — [GUIs](22-guis.md) を参照 |
| Safari / Edge | Google Chrome は `Super + Shift + Return`、別のものは _Setup > Defaults > Browser_ で選択 — [browsers](23-browsers.md) を参照 |
| Preview / Photos | 画像、動画、音楽には Omaview、PDF には Document Viewer — [GUIs](22-guis.md) を参照 |
| TextEdit / Notepad | Plain、`Super + Shift + N`、別のものは _Setup > Defaults > Editor_ で選択 |

### 本当に違うこともある

多くの設定は、クリックして回るパネルではなく、編集するテキストファイルに存在する。原始的に聞こえるが、実際にはすべての調整が見え、次のマシンへコピーでき、バージョン管理に入れられるということだ。_Setup_ menu は適切なファイルへ直接連れて行き、終わったら再起動が必要なものを再起動してくれる。

更新は一つのコマンド、_Update > Omarchy_ 経由でやってくる。これで Omarchy 自体とシステム上のすべてのパッケージが更新され、その前に snapshot が取られる。ランダムに煩わせてくるアプリごとのアップデーターはない。[updates](30-updates.md) を参照。

ソフトウェアはダウンロードしたインストーラーからではなく、パッケージマネージャーからやってくる。

そしてウィンドウを閉じたら、アプリは実際に終了する。ウィンドウがないのにプログラムだけ動き続ける macOS の中途半端な状態はない。`Super + W`、あるいは到着したときの指の記憶がそちらなら `Super + Q` は、消えることを意味する。

### Mac ハードウェアについて

Omarchy は Intel Macs で問題なく動く。[Mac support](44-mac-support.md) を参照。キーボードも優しい。Omarchy は何も再割り当てせず、Linux は Command キーを Super として扱うので、Super は Cmd がいつもあった場所そのままに座る。親指は引っ越しに気づかないだろう。

### 2週間ください

本能の移行は思っているより速い。[hotkeys](07-hotkeys.md) の章を一度ざっと読み、割り当てを忘れたら `Super + K` を押してくれ。すべて表示される。本当に覚えなければならないホットキーはそれだけだ。
