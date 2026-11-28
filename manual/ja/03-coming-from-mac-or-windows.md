# MacやWindowsから来た人へ

macOSやWindowsを何年も使ってきたなら、指は脳が覚えたことすら忘れた百ものことを覚えている。この章はその翻訳レイヤーだ。そうした直感がOmarchyではどこへ行くのかを示す。機能そのものは elsewhere で詳しく扱っている。ここにあるのは地図だけだ。

### Superがすべての中心

CmdやWindowsキーの周りに築いてきた筋肉の記憶はすべて、1つのキーに引き継がれる。Superだ。PCキーボードではWindowsキーにあたり、Omarchyのほぼすべてのホットキーの軸になる。

SpotlightやRaycastやスタートメニューを開こうとする反射は、`Super + Space` になる。これでOmarchyメニューが開く。アプリの起動、設定の変更、ソフトウェアのインストール、画面のキャプチャ、ほぼ何でもここからだ。入力し始めれば絞り込める。`Super + Alt + Space` はすべてのアプリをLaunchpadのように1つのグリッドに表示する。[ナビゲーション](04-navigation.md)を参照。

### デスクトップアイコンはなく、ドックは邪魔にならない

デスクトップに並べるアイコンはなく、ドックはワークスペースにウィンドウがあると隠れる。ポインタを画面のその端、移動していなければ右端、まで押すまでは出てこない（[ナビゲーション](04-navigation.md)を参照）。アプリはホットキー（ターミナルは `Super + Return`、ブラウザは `Super + Shift + Return`、割り当てられているものすべてのリストは `Super + K`）か、メニューから起動する。常に見えているUIは[トップバー](05-the-top-bar.md)だけだ。これが以前のメニューバー、システムトレイ、Notification Centerの役割を担う。そして、その上のほぼすべてのウィジェットは左クリック、右クリック、中クリックで何かをする。

### ウィンドウは自分で配置される

一番大きな考え方の転換はこれだ。ウィンドウをドラッグして回ったり、画面の半分にスナップしたりはしない。ウィンドウを開けば画面全体を使う。2つ目を開けば画面を分け合う。ウィンドウが重ならないので、別のウィンドウの下から掘り出すことも決してない。

どうしてもフローティングウィンドウが必要なときは、`Super + T` でアクティブなウィンドウをタイリングから切り離せる（そして戻せる）。だが、まずタイリングに本気でチャンスを与えてほしい。それが全体の心臓だ。[ナビゲーション](04-navigation.md)が順に案内する。

ワークスペースは馴染み深く感じるはずだ。macOSのSpacesやWindowsの仮想デスクトップと同じだが、実際によく使うようになる。`Super + 1/2/3/4` で直接ジャンプし、`Super + Shift + 1/2/3/4` でアクティブなウィンドウをそこへ送れるからだ。アニメーションの遅延はなく、瞬時のジャンプだけだ。つまり、以前は複数モニターに慣れていた人でも、もはや必要ないかもしれない。

### コピーとペーストはそのまま使える

MacではどこでもCmd + Cだった。WindowsではどこでもCtrl + Cだった。ターミナルを除いて。そこではプログラムが死ぬ。Omarchyでは `Super + C`、`Super + X`、`Super + V` が使え、ターミナルを含めどこでも動く。シェル用に別の反射を覚える必要はない。

Windowsの人へ。Win + Vのクリップボード履歴は `Super + Ctrl + V` にあり、テキストだけでなく画像も保持する。[統合クリップボードと履歴](08-unified-clipboard-history.md)を参照。

### 翻訳表

| 手が伸びるもの | Omarchyでは |
| ------------- | ---------- |
| Spotlight / Raycast / スタートメニュー | `Super + Space` — Omarchyメニュー |
| AirDrop | LocalSend、`Super + Ctrl + S` 経由 — [GUI](22-guis.md)を参照 |
| Cmd + Shift + 4 / Win + Shift + S | `Super + Ctrl + Alt + C` または `Print Screen` — [スクリーンショットと録画](12-screenshots-recording.md)を参照 |
| Notification Center | `Super + Shift + Alt + ,` の通知履歴 |
| Time Machine（システム用） | アップデートごとの自動[システムスナップショット](47-system-snapshots.md) |
| App Store / インストーラーのダウンロード | メニューの _Install_、または `omarchy pkg add` — [その他のパッケージ](29-other-packages.md)を参照 |
| システム設定 / コントロールパネル | メニューの _Setup_、プレーンな設定ファイルを編集する — [dotfiles](31-dotfiles.md)を参照 |
| Finder / File Explorer | Files、`Super + Shift + F` — [GUI](22-guis.md)を参照 |
| Safari / Edge | `Super + Shift + Return` のGoogle Chrome。別のものは _Setup > Defaults > Browser_ で選ぶ — [ブラウザ](23-browsers.md)を参照 |
| Preview / Photos | 写真、動画、音楽はOmaview、PDFはDocument Viewer — [GUI](22-guis.md)を参照 |
| TextEdit / Notepad | Plain、`Super + Shift + N`。別のものは _Setup > Defaults > Editor_ で選ぶ |

### 本当に違うものもある

多くの設定は、クリックして回るパネルではなく、編集するテキストファイルの中にある。原始的に聞こえるが、すべての調整が見え、次のマシンにコピーでき、バージョン管理に入れられると気づくまではその印象だ。_Setup_ メニューは正しいファイルへ直接連れて行き、終わったら再起動が必要なものを再起動する。

アップデートは1つのコマンド、_Update > Omarchy_、から来る。これがOmarchy自体とシステム上のすべてのパッケージをアップデートし、まずスナップショットを取る。ランダムなタイミングでうるさく言ってくるアプリごとのアップデーターはない。[アップデート](30-updates.md)を参照。

ソフトウェアはダウンロードしたインストーラーからではなく、パッケージマネージャーから来る。

そしてウィンドウを閉じると、アプリは本当に終了する。ウィンドウがないのにプログラムが動き続けるmacOSの宙ぶらりん状態はない。`Super + W`、あるいは身についてきた指の記憶がそちらなら `Super + Q`、は消えたという意味だ。

### Macハードウェアについて

OmarchyはIntel Macで快適に動き、M1、M2、M3 MacではOmarchy for Apple Siliconで動く。[Macサポート](44-mac-support.md)を参照。キーボードも優しい。Omarchyは何も再割り当てせず、LinuxはCommandキーをSuperとして扱うので、SuperはCmdが常にあった場所にそのまま座る。親指は引っ越しに気づかないだろう。

### 2週間使ってみてほしい

直感は思ったより速く移る。[ホットキー](07-hotkeys.md)の章を一度さらっと読んで、割り当てを忘れたらいつでも `Super + K` を押してほしい。すべて表示される。本当に覚えなければならないホットキーはそれだけだ。
