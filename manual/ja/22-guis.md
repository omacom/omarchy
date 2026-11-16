# GUI

## Files

Files (Nautilus) はグラフィカルなファイルマネージャーです。`Super + Shift + F` で開き、`Super + Shift + Alt + F` でターミナルが現在いるディレクトリで開くので、クリックの手間がかなり省けます。`Ctrl + L` でパスを入力でき、任意のファイルで `Space` を押すと、何も開かずにクイックプレビューを表示できます。

USB メモリや SD カードを差し込むと自動的にマウントされるので、サイドバーにそのまま表示されます。ドライブのフォーマット、SMART の健全性チェック、パーティションの作成など、もう少し踏み込んだ作業には、アプリランチャー (`Super + Space`) から _Disks_ を起動してください。

ダブルクリックは賢明なデフォルトに従います: 画像、動画、音楽は Omaview で、PDF は Document Viewer で、Markdown は Omawrite で、プレーンテキストは _Setup > Default > Editor_ で選択したエディターで開きます。

## Disktree

ドライブがいっぱいになり、何が容量を食っているのか見当もつかないときは、アプリランチャー (`Super + Space`) から [Disktree](https://github.com/tobi/disktree) を起動してください。ホームディレクトリをグラフィカルなツリーマップで表示します。ブロックが大きいほど容量も大きく、キーボードやマウスでディレクトリの中へ進み、消すべきものに印を付け、何も削除する前に選択内容を確認できます。ディスク全体をスキャンするには `disktree --disk` を実行してください。

## Obsidian

[Obsidian](https://obsidian.md/) は、保存にシンプルな Markdown ファイルを使う、無料で拡張性の高いノート作成アプリケーションです。

Obsidian は、個人、商用、非営利用途を含むあらゆる目的で無料です。

Obsidian は、iOS と Android のモバイルアプリと同期するための[商用アドオン](https://obsidian.md/sync)も提供しています。(https://obsidian.md/pricing)。

Obsidian は `Super + Shift + O` で起動します。テーマの同期を使うには、設定で `Omarchy` テーマを選択する必要があります。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) は、Omarchy 独自のとことんシンプルな Markdown ライティングアプリです。Vault もプラグインもありません。あるのはあなたと文章だけです。

Omawrite は `Super + Shift + W` で起動します。

## Pinta

[Pinta](https://www.pinta-project.com/) は、切り抜き、リサイズ、その他の基本的な操作に最適な基本的な画像編集ツールです。Photoshop の代替になるとは期待しないでください。とはいえ、Magic Wand とレイヤーはあります！

Pinta はアプリケーションランチャー (`Super + Space`) から起動します。

## Aether

[Aether](https://github.com/bjarneo/aether) は、背景画像から色を抽出し、一貫性のある完全なテーマへと変えられるテーマ作成アプリケーションです。[自分だけのテーマを作る](43-making-your-own-theme.md)最も簡単な方法です。

Aether はアプリケーションランチャー (`Super + Space`) から起動します。

## LocalSend

[LocalSend](https://localsend.org/) を使うと、Apple の AirDrop のように、同じネットワーク上でアプリを実行している他のデバイスへファイルを送信できます。ただしクロスプラットフォームなので、Windows、macOS、Android、iOS、そしてもちろん Linux との間でファイルを送受信できます。

共有メニューは `Super + Ctrl + S` で、または Omarchy メニューの _Trigger > Share_ から開けます。4 つの選択肢があります:

- **Clipboard** は、コピーしたものをテキストファイルとして送信します。自分宛てにメールせずに、リンクやスニペットをスマートフォンへ送るのに最適です。
- **File** はファイルピッカーを開き、一度に複数選択できます。
- **Folder** はディレクトリ全体を送信します。
- **Receive** は LocalSend 本体を開き、他のデバイスから何かを送信してもらえるようにします。

同じことはターミナルでも `omarchy share clipboard`、`omarchy share file [path]`、`omarchy share folder [path]` でできます。パスを省略するとピッカーが表示されます。

ファイルマネージャーから直接送信することもできます: Nautilus で任意の選択範囲を右クリックし、_Send via LocalSend_ を選んでください。

Omarchy のファイアウォールは LocalSend のポートを除いてデフォルトで閉じているため、これは新規インストール直後からそのまま使えます。[セキュリティ](48-security.md)を参照してください。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) は、ワードプロセッサ、表計算、プレゼンテーション、描画アプリケーションなどを備えた完全なオフィススイートです。Microsoft Office のファイルと互換性があるため、Word 文書を開けるようにするのに最適です。

LibreOffice はアプリケーションランチャー (`Super + Space`) から起動します。

## Hype

[Hype](https://github.com/omacom/hype) は、Omarchy 独自のとことんシンプルなプレゼンテーションアプリです。デッキは 1 つの Markdown ファイルで、その横に画像と動画を置きます: ライブプレビューの下に各スライドを書き、スライドをドラッグして並べ替え、全画面でプレゼンテーションするか、PDF と PowerPoint へエクスポートします。Omarchy テーマも反映します。

Hype はアプリケーションランチャー (`Super + Space`) から起動します。内部で `?` を押すとすべてのショートカットを表示できます。

## Signed

[Signed](https://github.com/omacom/signed) は、PDF に署名し、記入するための Omarchy 独自のとことんシンプルな方法です。保存した署名、テキスト、今日の日付をページ上の好きな場所に配置し、署名済みのコピーを元のファイルの横に保存します。方法については[PDF への記入](27-filling-out-pdfs.md)を参照してください。

Signed はアプリケーションランチャー (`Super + Space`) から起動するか、ファイルマネージャーから PDF をこれで開きます。

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) は、Omarchy 独自の 3D チェスゲームです。同じコンピューターで友人と対戦するか、3 段階の内蔵対戦相手と対戦できます。それぞれ独自の方法で動く 4 つの彫刻のようなセットがあります: 軌道船、彫刻された木材と象牙、森の生き物、そしてキャンディです。ゲームに持ち時間はなく、一手ごとに保存されます。

Checkmate はアプリケーションランチャー (`Super + Space`) から起動します。内部で `?` を押すとすべてのショートカットを表示できます。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) は、Omarchy 独自のとことんシンプルな電卓で、フローティングウィンドウで開きます。

Omacalc は `Super + Shift + Q` で起動します（キーボードに電卓キーがある場合はそれでも起動できます）。

## Signal

[Signal](https://signal.org/) は E2E 暗号化メッセージングのパイオニアであり、大手テクノロジー企業群を通りたくない人にとって最適なコミュニケーションの選択肢です。

Signal は `Super + Shift + G` で起動します。基本インストールには含まれていないため、初めて押したときは Omarchy がインストールを提案します（Omarchy メニューの _Install > Service_ にもあります）。

## Omaview

[Omaview](https://github.com/omacom/omaview) は、Omarchy 独自のとことんシンプルな画像ビューアー兼メディアプレーヤーです: 写真、動画、音楽のための 1 つのウィンドウです。写真を開くと矢印キーでそのフォルダの残りを順に表示でき、`N` と `P` はあらゆるものでそれを行い、`Ctrl + M` はフォルダ全体をグリッドで表示します。HEIC、AVIF、JPEG XL の写真も表示でき、長いものでは前回終了したところから再開します。

`F` で全画面、`E` で Omasnap で画像を編集するか Omacut で動画をトリミングし、`Ctrl + P` で画像を印刷し、`Delete` でファイルを Trash へ移動します（`Ctrl + Z` で元に戻ります）。内部で `?` を押すとすべてのショートカットを表示できます。

Omaview はアプリケーションランチャー (`Super + Space`) から _Media Viewer_ として起動するか、ファイルマネージャーで写真、動画、曲をダブルクリックするだけで起動できます。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) は、Omarchy 独自のとことんシンプルな動画トリマーです。クリップの最初と最後を切り取るだけで十分なときは、本格的な動画エディターを起動するより優れています。

Omacut はアプリケーションランチャー (`Super + Space`) から起動します。

## Monologue

[Monologue](https://github.com/omacom/monologue) は、Omarchy 独自のとことんシンプルなウェブカメラレコーダーです。カメラとマイクを一度選択したら、`Space` を押して録画し、もう一度押して同じテイクを一時停止したり再開したりします。カメラの最高解像度で常に録画し、ライブのマイクメーターがあるので開始前にレベルを確認できます。

テイクを停止すると、内蔵エディターで直ちに開きます。クリップをダブルクリックして分割し、ハンドルをドラッグして各部分をトリミングし、不要な部分を取り除きます。次に MP4 として保存します。元の録画は破棄するまで保持されるため、いつでも戻って別の切り方をできます。

Monologue はアプリケーションランチャー (`Super + Space`) から起動します。
