# GUI

## Files

Files (Nautilus) はグラフィカルなファイルマネージャーです。`Super + Shift + F` で開き、`Super + Shift + Alt + F` で、ターミナルが現在いるディレクトリで開きます。これでクリックの手間がかなり省けます。`Ctrl + L` でパスを入力でき、任意のファイルの上で `Space` を押すと、何も開かずにクイックプレビューを表示できます。

USB メモリや SD カードを差し込むと自動的にマウントされるので、そのままサイドバーに表示されます。ドライブのフォーマット、SMART による健全性の確認、パーティションの作成など、もう少し踏み込んだ作業をする場合は、アプリランチャー (`Super + Space`) から _Disks_ を起動してください。

ダブルクリック時の動作は、 sensible なデフォルトに従います。画像は imv、動画は mpv、PDF は Document Viewer、プレーンテキストは Neovim で開きます。

## Disktree

ドライブがいっぱいになったのに、何が容量を食っているのか見当もつかないときは、アプリランチャー (`Super + Space`) から [Disktree](https://github.com/tobi/disktree) を起動してください。ホームディレクトリをグラフィカルなツリーマップで表示します。ブロックが大きいほど、占有している容量も大きくなります。キーボードやマウスでディレクトリの中へ進み、削除するものをマークし、実際に削除する前に選択内容を確認してください。ディスク全体をスキャンするには `disktree --disk` を実行します。

## Obsidian

[Obsidian](https://obsidian.md/) は、保存形式にシンプルな Markdown ファイルを使う、無料で拡張性の高いノート作成アプリケーションです。

Obsidian は、個人利用、商用利用、非営利用を問わず、あらゆる目的で無料です。

Obsidian は、iOS や Android のモバイルアプリと同期するための[商用アドオン](https://obsidian.md/sync)も提供しています。(https://obsidian.md/pricing)。

Obsidian は `Super + Shift + O` で起動します。テーマの同期を使うには、設定で `Omarchy` テーマを選択する必要があります。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) は、Omarchy 独自の、驚くほどシンプルな Markdown ライティングアプリです。ボールトもプラグインもありません。あるのはあなたと文章だけです。

Omawrite は `Super + Shift + W` で起動します。

## Pinta

[Pinta](https://www.pinta-project.com/) は、切り抜きやリサイズ、そのほかの基本的な操作に最適な、基本的な画像編集ツールです。Photoshop の代替になるとは思わないでください。とはいえ、Magic Wand もレイヤーもあります！

Pinta はアプリケーションランチャー (`Super + Space`) から起動します。

## Aether

[Aether](https://github.com/bjarneo/aether) は、背景画像から色を抽出し、一貫性のある完全なテーマに仕立てるテーマ作成アプリケーションです。[独自のテーマを作る](43-making-your-own-theme.md)最も簡単な方法です。

Aether はアプリケーションランチャー (`Super + Space`) から起動します。

## LocalSend

[LocalSend](https://localsend.org/) を使うと、Apple の AirDrop のように、同じネットワーク上でアプリを実行している他のデバイスへファイルを送信できます。ただしクロスプラットフォームなので、Windows、macOS、Android、iOS、そしてもちろん Linux との間でファイルを送受信できます。

Share メニューは `Super + Ctrl + S` で開くか、Omarchy メニューの _Trigger > Share_ から開けます。4 つのオプションがあります。

- **Clipboard** は、コピーしたものをテキストファイルとして送信します。自分宛てにメールしなくても、リンクやスニペットをスマートフォンへ送るのに最適です。
- **File** はファイルピッカーを開き、一度に複数選択できます。
- **Folder** はディレクトリ全体を送信します。
- **Receive** は LocalSend 本体を開き、他のデバイスから何かを送信してもらえるようにします。

同じことはターミナルからも `omarchy share clipboard`、`omarchy share file [path]`、`omarchy share folder [path]` で実行できます。パスを省略するとピッカーが表示されます。

ファイルマネージャーから直接送信することもできます。Nautilus で選択範囲を右クリックし、_Send via LocalSend_ を選んでください。

Omarchy のファイアウォールは、デフォルトでは LocalSend のポートを除いて閉じられているので、新規インストール直後からそのまま使えます。[セキュリティ](48-security.md)を参照してください。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) は、ワープロ、表計算、プレゼンテーション、描画アプリケーションなどを備えた完全なオフィスパッケージです。Microsoft Office のファイルと互換性があるので、Word ドキュメントを開けるようにするには最適な方法です。

LibreOffice はアプリケーションランチャー (`Super + Space`) から起動します。

## Hype

[Hype](https://github.com/omacom/hype) は、Omarchy 独自の、驚くほどシンプルなプレゼンテーションアプリです。デッキは、画像や動画を横に配置した単一の Markdown ファイルです。各スライドをライブプレビューの下に書き、スライドをドラッグして順序を入れ替え、全画面でプレゼンするか、PDF や PowerPoint にエクスポートします。Omarchy のテーマも反映されます。

Hype はアプリケーションランチャー (`Super + Space`) から起動します。アプリ内で `?` を押すと、すべてのショートカットを表示できます。

## Signed

[Signed](https://github.com/omacom/signed) は、Omarchy 独自の、驚くほどシンプルな PDF への署名と記入の方法です。保存済みの署名、テキスト、今日の日付をページ上の任意の場所に配置し、署名済みのコピーを元のファイルの横に保存します。方法については [PDF への記入](27-filling-out-pdfs.md) を参照してください。

Signed はアプリケーションランチャー (`Super + Space`) から起動するか、ファイルマネージャーから PDF を Signed で開きます。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) は、Omarchy 独自の、驚くほどシンプルな電卓で、フローティングウィンドウで開きます。

Omacalc は `Super + Shift + Q` で起動します (キーボードに電卓キーがある場合はそれでも起動できます)。

## Signal

[Signal](https://signal.org/) は E2E 暗号化メッセージングの先駆者であり、大手テクノロジーコングロマリットを経由したくない人にとって最適なコミュニケーション手段です。

Signal は `Super + Shift + G` で起動します。基本インストールには含まれていないので、初めてそのキーを押すと、Omarchy がインストールを提案します (Omarchy メニューの _Install > Service_ からもインストールできます)。

## mpv

[mpv](https://mpv.io/) は、ほぼあらゆるソースからほぼ何でも再生できる、シンプルで高速なメディアプレイヤーです。動画の視聴に最適です。

mpv はアプリケーションランチャー (`Super + Space`) から起動するか、ファイルマネージャーで動画をダブルクリックして起動します。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) は、Omarchy 独自の、驚くほどシンプルな動画トリマーです。クリップの最初と最後を切り取るだけで十分なら、本格的な動画エディターを起動するよりずっと手軽です。

Omacut はアプリケーションランチャー (`Super + Space`) から起動します。

## Monologue

[Monologue](https://github.com/omacom/monologue) は、Omarchy 独自の、驚くほどシンプルなウェブカメラレコーダーです。カメラとマイクを一度選択したら、`Space` を押して録画し、もう一度押して同じテイクを一時停止したり再開したりします。常にカメラの最高解像度で録画し、ライブのマイクメーターがあるので、開始前にレベルを確認できます。

テイクを停止すると、内蔵エディターですぐに開きます。クリップをダブルクリックして分割し、ハンドルをドラッグして各部分をトリミングし、不要な部分を取り除きます。その後、MP4 として保存します。元の録画は破棄するまで保持されるので、いつでも戻って別の切り方をすることができます。

Monologue はアプリケーションランチャー (`Super + Space`) から起動します。
