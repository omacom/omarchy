# GUI

## Files

Files (Folio) はグラフィカルなファイルマネージャーです。`Super + Shift + F` で開き、`Super + Shift + Alt + F` ではターミナルが現在いるディレクトリで開くので、クリックの手間がかなり省けます。`Ctrl + L` でパスを入力でき、ファイル上で `Space` を押すと、開かずにフルサイズでプレビューできます。

USB スティックや SD カードを挿すと自動的にマウントされるので、サイドバーにそのまま表示されます。もっと本格的な作業 — ドライブのフォーマット、SMART の状態確認、パーティションの作成 — には、アプリランチャー (`Super + Space`) から _Disks_ を起動してください。

暗号化されたドライブは、接続したときにパスワードを求めます。自動的にロック解除させたい場合は、`sudo cryptsetup luksAddKey /dev/sdX1 <keyfile>` でキーファイルを追加し、そのキーファイルを `~/.config/omarchy/drive-keys/<UUID>` に置いてください。名前は、暗号化されたパーティションについて `lsblk -dno UUID /dev/sdX1` が表示する UUID とし、自分だけが読めるようにしてください (`chmod 600`)。そのキーファイルがないか拒否された場合は、通常どおりパスワードが求められます。

ダブルクリックは賢明なデフォルトに従います: 画像、動画、音楽は Omaview で、PDF は Document Viewer で、Markdown は Omawrite で、プレーンテキストはお使いのエディターで開きます。_Setup > Defaults > Editor_ で別のものを選択しない限り Plain です。

## Disktree

ドライブが満杯になっているのに何が食っているのか見当もつかないときは、アプリランチャー (`Super + Space`) から [Disktree](https://github.com/tobi/disktree) を起動してください。ホームディレクトリのグラフィカルなツリーマップを表示します。ブロックが大きいほど容量を多く使っています。キーボードやマウスでディレクトリに入り、削除すべきものをマークし、実際に削除する前に選択内容を確認してください。ディスク全体をスキャンするには `disktree --disk` を実行します。

## Obsidian

[Obsidian](https://obsidian.md/) は、ストレージにシンプルな Markdown ファイルを使う、無料で高度に拡張可能なノート作成アプリケーションです。

Obsidian は、個人、商用、非営利用途を含むすべての目的で無料です。

Obsidian は、iOS と Android のモバイルアプリと同期するための[商用アドオン](https://obsidian.md/sync)も提供しています。(https://obsidian.md/pricing)。

Obsidian は `Super + Shift + O` で起動します。テーマ同期を使うには、設定で `Omarchy` テーマを選択しなければなりません。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) は、Omarchy 独自の非常にシンプルな Markdown ライティングアプリです。保管庫もプラグインもありません。あなたと文章だけです。

Omawrite は `Super + Shift + W` で起動します。

## Pinta

[Pinta](https://www.pinta-project.com/) は基本的な画像編集ツールで、切り抜き、サイズ変更、その他の基本的な操作に最適です。ただ、Photoshop の代替になるとは期待しないでください。それでも Magic Wand とレイヤーはあります!

Pinta はアプリケーションランチャー (`Super + Space`) から起動します。

## Aether

[Aether](https://github.com/bjarneo/aether) はテーマ作成アプリケーションで、背景画像から色を抽出し、完全でまとまりのあるテーマに変えることができます。[独自のテーマを作る](43-making-your-own-theme.md)最も簡単な方法です。

Aether はアプリケーションランチャー (`Super + Space`) から起動します。

## LocalSend

[LocalSend](https://localsend.org/) を使うと、同じネットワーク上でアプリを実行している他のデバイスにファイルを送信できます。Apple の AirDrop のようなものです。ただしクロスプラットフォームなので、Windows、macOS、Android、iOS、そしてもちろん Linux との間でファイルを送受信できます。

共有メニューは `Super + Ctrl + S` で、または Omarchy メニューの _Trigger > Share_ から開けます。4 つのオプションがあります:

- **Clipboard** は、コピーしたものをテキストファイルとして送信します。自分宛てにメールすることなく、リンクやスニペットをスマートフォンに送るのに最適です。
- **File** はファイルピッカーを開き、一度に複数選択できます。
- **Folder** はディレクトリ全体を送信します。
- **Receive** は LocalSend 本体を開き、他のデバイスから何かを送信してもらえるようにします。

同じことはターミナルからも `omarchy share clipboard`、`omarchy share file [path]`、`omarchy share folder [path]` でできます。パスを省略するとピッカーが表示されます。

ファイルマネージャーから直接送信することもできます: Files で選択項目を右クリックし、LocalSend で共有してください。

Omarchy のファイアウォールはデフォルトで閉じていますが、LocalSend のポートだけは例外なので、新規インストールでもそのまま使えます。[セキュリティ](48-security.md) を参照してください。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) は、ワープロ、表計算、プレゼンテーション、描画アプリケーションなどを備えた完全なオフィススイートです。Microsoft Office のファイルと互換性があるので、Word ドキュメントを開けるようにする素晴らしい方法です。

LibreOffice はアプリケーションランチャー (`Super + Space`) から起動します。

## Hype

[Hype](https://github.com/omacom/hype) は、Omarchy 独自の非常にシンプルなプレゼンテーションアプリです。デッキは単一の Markdown ファイルで、画像と動画はその横に置きます: ライブプレビューの下に各スライドを書き、スライドをドラッグして順序を決め、全画面でプレゼンテーションするか、PDF や PowerPoint にエクスポートします。Omarchy テーマも拾ってくれます。

Hype はアプリケーションランチャー (`Super + Space`) から起動します。中で `?` を押すと、すべてのショートカットが見られます。

## Signed

[Signed](https://github.com/omacom/signed) は、Omarchy 独自の非常にシンプルな PDF 署名・記入方法です。保存した署名、テキスト、今日の日付をページ上の好きな場所に置き、署名済みコピーを元のファイルの横に保存します。方法については [PDF への記入](27-filling-out-pdfs.md) を参照してください。

Signed はアプリケーションランチャー (`Super + Space`) から起動するか、ファイルマネージャーから PDF をこれで開きます。

## Game Vibes

アプリケーションランチャー (`Super + Space`) にある Game Vibes は、Omarchy の小さなゲームが集まっている場所です: 友人や内蔵の対戦相手と対戦する 3D チェスゲーム Checkmate、Klondike ソリティア Cards、トゲとノコギリでいっぱいの 10 部屋からなるピクセル単位の精度が求められるプラットフォーマー Death Wish、そしてアーケードシューター Neon Swarm です。どれもテーマに従う単一の Web ページです。矢印キーと `Enter` で 1 つを選び、ゲームのタイトル画面から `Esc`、一時停止中は `Q` でリストに戻ります。全画面で開きます: `Super + F` でウィンドウ化し、`Super + W` で閉じます。

エージェントで作ったゲームもここに表示されます: エージェントパネルで _Make something cool → Game_ を選び、ゲームを説明するか、Game Vibes にすでにあるゲームの名前を挙げて作業を続けてください。エージェントはそれを `~/Games/vibes` にコピーします。そこではあなたのもので変更でき、完成したら開きます。そのコピーは `omarchy games vibes copy <game>` で自分でも作れます。他の誰かが共有したゲームはテーマのようにインストールします: _Install > Gaming > Game Vibes_ を選び、その git アドレスを貼り付けるか、`omarchy games vibes install <git-repo-url>` を実行してください。_Remove > Gaming_ で再び削除でき、_Update > Game Vibes Games_ で新しいバージョンを取得します。ゲームは Web から three.js を読み込むため、起動には接続が必要です。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) は、Omarchy 独自の非常にシンプルな計算機で、フローティングウィンドウで開きます。

Omacalc は `Super + Shift + Q` で起動します (キーボードに電卓キーがある場合はそれでも)。

## Signal

[Signal](https://signal.org/) は E2E 暗号化メッセージングのパイオニアで、大手テックコングロマリットを経由したくない人にとって素晴らしい通信手段です。

Signal は `Super + Shift + G` で起動します。ベースインストールには含まれていないので、初めてそのキーを押したとき、Omarchy がインストールを提案します (Omarchy メニューの _Install > Service_ にもあります)。

## Omaview

[Omaview](https://github.com/omacom/omaview) は、Omarchy 独自の非常にシンプルな画像ビューアー兼メディアプレイヤーです: 写真、動画、音楽のための 1 つのウィンドウです。写真を開いて矢印キーでそのフォルダーの残りを順に移動でき、`N` と `P` は何に対しても同じことをし、`Ctrl + M` はフォルダー全体をグリッドで表示します。HEIC、AVIF、JPEG XL の写真も表示し、長いものでは中断したところから再開します。

`F` で全画面、`E` で Omasnap で写真を編集するか Omacut で動画をトリミング、`Ctrl + P` で写真を印刷、`Delete` でファイルを Trash に移動します (`Ctrl + Z` で元に戻ります)。中で `?` を押すと、すべてのショートカットが見られます。

Omaview はアプリケーションランチャー (`Super + Space`) から _Media Viewer_ として起動するか、ファイルマネージャーで写真、動画、曲をダブルクリックするだけです。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) は、Omarchy 独自の非常にシンプルな動画トリマーです。クリップの最初と最後を切り取るだけでよいときは、本格的な動画エディターを起動するより優れています。

Omacut はアプリケーションランチャー (`Super + Space`) から起動します。

## Monologue

[Monologue](https://github.com/omacom/monologue) は、Omarchy 独自の非常にシンプルな Web カメラレコーダーです。カメラとマイクを一度選んだら、`Space` を押して録画し、もう一度押して同じテイクを一時停止・再開します。カメラの最高解像度で常に録画し、ライブのマイクメーターがあるので、開始前にレベルを確認できます。

テイクを停止すると、内蔵エディターで直ちに開きます。クリップをダブルクリックして分割し、ハンドルをドラッグして各部分をトリミングし、不要な部分を取り除きます。その後、MP4 として保存します。元の録画は破棄するまで保持されるので、いつでも戻って別の切り方をできます。

Monologue はアプリケーションランチャー (`Super + Space`) から起動します。
