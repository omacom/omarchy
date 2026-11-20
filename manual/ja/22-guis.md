# GUIアプリ

## Files

Files (Folio) はグラフィカルなファイルマネージャーです。`Super + Shift + F` で開き、`Super + Shift + Alt + F` でターミナルが現在いるディレクトリで開けるので、クリックの手間がかなり省けます。`Ctrl + L` でパスを入力でき、ファイルを選択して `Space` を押すと、開かずにフルサイズでプレビューできます。

USBメモリやSDカードを差し込むと自動的にマウントされるので、そのままサイドバーに表示されます。ドライブのフォーマット、SMARTの状態確認、パーティションの作成など、もう少し踏み込んだ作業をする場合は、アプリランチャー（`Super + Space`）から _Disks_ を起動してください。

ダブルクリック時の動作はまともなデフォルトになっています。写真、動画、音楽は Omaview で、PDFは Document Viewer で、Markdownは Omawrite で、プレーンテキストは _Setup > Default > Editor_ で選んだエディタで開きます。

## Disktree

ドライブが満杯になっているのに何が食っているのか分からないときは、アプリランチャー（`Super + Space`）から [Disktree](https://github.com/tobi/disktree) を起動してください。ホームディレクトリをグラフィカルなツリーマップで表示します。大きいブロックほど容量を占めています。キーボードやマウスでディレクトリの中に入り、消すべきものにマークを付け、実際に削除する前に選択内容を確認してください。ディスク全体をスキャンするには `disktree --disk` を実行します。

## Obsidian

[Obsidian](https://obsidian.md/) は、保存形式にシンプルなMarkdownファイルを使う、無料で拡張性の高いノートアプリです。

Obsidian は、個人利用、商用利用、非営利利用を含むあらゆる用途で無料です。

Obsidian には、iOSとAndroidのモバイルアプリと同期するための[商用アドオン](https://obsidian.md/sync)もあります。(https://obsidian.md/pricing)。

Obsidian は `Super + Shift + O` で起動します。テーマの同期を使うには、設定で `Omarchy` テーマを選択する必要があります。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) は、Omarchy独自の超シンプルなMarkdown執筆アプリです。ボルトもプラグインもありません。あるのはあなたと文章だけです。

Omawrite は `Super + Shift + W` で起動します。

## Pinta

[Pinta](https://www.pinta-project.com/) は、切り抜き、リサイズ、そのほかの基本的な編集に最適な、基本的な画像編集ツールです。Photoshopの代わりを期待してはいけません。それでも Magic Wand とレイヤーはあります！

Pinta はアプリランチャー（`Super + Space`）から起動します。

## Aether

[Aether](https://github.com/bjarneo/aether) は、背景画像から色を抽出して、まとまりのある完全なテーマに変えられるテーマ作成アプリです。[自分でテーマを作る](43-making-your-own-theme.md)には一番簡単な方法です。

Aether はアプリランチャー（`Super + Space`）から起動します。

## LocalSend

[LocalSend](https://localsend.org/) を使うと、AppleのAirDropのように、同じネットワーク上でアプリを実行している他のデバイスにファイルを送れます。しかもクロスプラットフォームなので、Windows、macOS、Android、iOS、そしてもちろんLinuxとの間でファイルを送れます。

Shareメニューは `Super + Ctrl + S` で、または Omarchy メニューの _Trigger > Share_ から開けます。選択肢は4つあります。

- **Clipboard** は、コピーしたものをテキストファイルとして送ります。自分宛てにメールしなくても、リンクやスニペットをスマートフォンに送れるので便利です。
- **File** は、一度に複数選択できるファイルピッカーを開きます。
- **Folder** はディレクトリ全体を送ります。
- **Receive** は LocalSend 本体を開き、他のデバイスからあなたへ送れるようにします。

ターミナルでも同じことが `omarchy share clipboard`、`omarchy share file [path]`、`omarchy share folder [path]` でできます。パスを省略するとピッカーが開きます。

ファイルマネージャーから直接送ることもできます。Files で選択したものを右クリックして、LocalSend で共有してください。

Omarchy のファイアウォールは、LocalSend のポートを除いてデフォルトで閉じられているので、新規インストール直後からそのまま使えます。[セキュリティ](48-security.md)を参照してください。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) は、ワープロ、表計算、プレゼンテーション、描画アプリなどを備えた完全なオフィススイートです。Microsoft Office のファイルと互換性があるので、Word文書を開きたいときに最適です。

LibreOffice はアプリランチャー（`Super + Space`）から起動します。

## Hype

[Hype](https://github.com/omacom/hype) は、Omarchy独自の超シンプルなプレゼンテーションアプリです。デッキは単一のMarkdownファイルで、その横に画像と動画を置きます。各スライドをライブプレビューの下に書き、スライドをドラッグして順序を決めたら、全画面でプレゼンするか、PDFやPowerPointに書き出せます。Omarchy のテーマも反映されます。

Hype はアプリランチャー（`Super + Space`）から起動します。中で `?` を押すとすべてのショートカットが見られます。

## Signed

[Signed](https://github.com/omacom/signed) は、Omarchy独自の超シンプルなPDF署名・記入アプリです。保存済みの署名、テキスト、今日の日付をページ上の好きな場所に置き、署名済みのコピーを元のファイルの横に保存できます。方法は [PDFへの記入](27-filling-out-pdfs.md) を参照してください。

Signed はアプリランチャー（`Super + Space`）から起動するか、ファイルマネージャーからPDFを Signed で開いてください。

## Game Vibes

アプリランチャー（`Super + Space`）にある Game Vibes は、Omarchy の小さなゲームが集まる場所です。友人や内蔵の対戦相手と対戦する3Dチェスゲーム Checkmate、クロンダイク・ソリティアの Cards、アーケードシューターの Neon Swarm があります。どれもテーマに追従する単一のWebページです。矢印キーと `Enter` で1つを選んでください。ゲームのタイトル画面で `Esc` を押すか、一時停止中に `Q` を押すと一覧に戻ります。全画面で開きます。`Super + F` でウィンドウ化し、`Super + W` で閉じます。

エージェントと一緒に作ったゲームもここに表示されます。エージェントパネルで _Make something cool → Game_ を選んでゲームを説明するか、Game Vibes にすでにあるゲームの名前を挙げて作業を続けてください。エージェントはそのゲームを `~/Games/vibes` にコピーします。そこにあればあなたのもので、自由に変更でき、完成したら開いてくれます。そのコピーは `omarchy games vibes copy <game>` で自分で作ることもできます。誰かが共有したゲームはテーマのようにインストールできます。_Install > Gaming > Game Vibes_ を選んでそのgitアドレスを貼るか、`omarchy games vibes install <git-repo-url>` を実行してください。_Remove > Gaming_ で再び削除でき、_Update > Game Vibes Games_ で新しいバージョンを取得できます。ゲームはWebから three.js を読み込むので、起動には接続が必要です。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) は、Omarchy独自の超シンプルな電卓で、フローティングウィンドウで開きます。

Omacalc は `Super + Shift + Q` で起動します（キーボードに電卓キーがある場合はそれでも開けます）。

## Signal

[Signal](https://signal.org/) はE2E暗号化メッセージングの先駆者であり、大手テック conglomerate を経由したくない人にとって優れたコミュニケーション手段です。

Signal は `Super + Shift + G` で起動します。ベースインストールには含まれていないので、初めてそのキーを押したとき、Omarchy がインストールを提案します（Omarchy メニューの _Install > Service_ からも利用できます）。

## Omaview

[Omaview](https://github.com/omacom/omaview) は、Omarchy独自の超シンプルな画像ビューア兼メディアプレーヤーです。写真、動画、音楽を1つのウィンドウで扱えます。写真を開くと矢印キーでそのフォルダの残りを順に進み、`N` と `P` は何に対しても同じ動作をし、`Ctrl + M` でフォルダ全体をグリッド表示します。HEIC、AVIF、JPEG XL の写真も表示でき、長いものは中断したところから再開します。

`F` で全画面表示、`E` で写真を Omasnap で編集するか動画を Omacut でトリミングし、`Ctrl + P` で写真を印刷し、`Delete` でファイルをゴミ箱に移動します（`Ctrl + Z` で戻ります）。中で `?` を押すとすべてのショートカットが見られます。

Omaview はアプリランチャー（`Super + Space`）から _Media Viewer_ として起動するか、ファイルマネージャーで写真、動画、曲をダブルクリックするだけで起動できます。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) は、Omarchy独自の超シンプルな動画トリマーです。クリップの最初と最後を切り取るだけでいいなら、本格的な動画エディタを起動するよりずっと勝ります。

Omacut はアプリランチャー（`Super + Space`）から起動します。

## Monologue

[Monologue](https://github.com/omacom/monologue) は、Omarchy独自の超シンプルなWebカメラレコーダーです。カメラとマイクを一度選んだら、`Space` を押して録画し、もう一度押して同じテイクを一時停止したり再開したりできます。常にカメラの最高解像度で録画し、ライブのマイクメーターがあるので、開始前にレベルを確認できます。

テイクを停止すると、内蔵エディタですぐに開きます。クリップをダブルクリックして分割し、ハンドルをドラッグして各部分をトリミングし、不要な部分を削除してください。その後、MP4として保存します。元の録画は破棄するまで残るので、いつでも戻って別の切り方を試せます。

Monologue はアプリランチャー（`Super + Space`）から起動します。
