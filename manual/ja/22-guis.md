# GUIs

## Files

Files (Nautilus) はグラフィカルなファイルマネージャーだ。`Super + Shift + F` で開き、`Super + Shift + Alt + F` でターミナルが今いるディレクトリで開くので、クリックの手間がかなり省ける。`Ctrl + L` でパスを入力でき、任意のファイルで `Space` を押せば、何も開かずにクイックプレビューできる。

USB スティックや SD カードを挿せば自動でマウントされるので、そのままサイドバーに表示される。ドライブのフォーマット、SMART の状態確認、パーティションの作成など、もう少し踏み込んだことをするなら、アプリランチャー (`Super + Space`) から _Disks_ を起動してほしい。

ダブルクリックは賢明なデフォルトに従う: 画像、動画、音楽は Omaview で、PDF は Document Viewer で、Markdown は Omawrite で、プレーンテキストは _Setup > Default > Editor_ で選んだエディタで開く。

## Disktree

ドライブがいっぱいになって、何が食いつぶしているのか見当もつかないときは、アプリランチャー (`Super + Space`) から [Disktree](https://github.com/tobi/disktree) を起動してほしい。ホームディレクトリのグラフィカルなツリーマップを表示する。大きいブロックほど多くの容量を使っている。キーボードかマウスでディレクトリに入り、消すべきものをマークし、選択を確認してから何かを削除する。ディスク全体をスキャンするには `disktree --disk` を実行する。

## Obsidian

[Obsidian](https://obsidian.md/) は無料で拡張性の高いノート作成アプリケーションだ。ストレージにはシンプルな Markdown ファイルを使う。

Obsidian は、個人利用、商用、非営利用を含め、あらゆる目的で無料だ。

Obsidian は iOS と Android のモバイルアプリと同期するための[商用アドオン](https://obsidian.md/sync)も提供している。 (https://obsidian.md/pricing).

Obsidian は `Super + Shift + O` で起動する。テーマ同期を使うには、設定で `Omarchy` テーマを選択しなければならない。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) は Omarchy 独自の、驚くほどシンプルな Markdown ライティングアプリだ。Vault もプラグインもない。あるのは自分と言葉だけだ。

Omawrite は `Super + Shift + W` で起動する。

## Pinta

[Pinta](https://www.pinta-project.com/) は基本的な画像編集ツールで、切り抜き、リサイズ、その他の基本的な操作に最適だ。Photoshop の代替になるとは思わないでほしい。とはいえ、Magic Wand とレイヤーはちゃんとある!

Pinta はアプリケーションランチャー (`Super + Space`) から起動する。

## Aether

[Aether](https://github.com/bjarneo/aether) はテーマ作成アプリケーションで、背景画像から色を抽出して、まとまりのある完全なテーマに変えることができる。[独自のテーマを作る](43-making-your-own-theme.md)最も簡単な方法だ。

Aether はアプリケーションランチャー (`Super + Space`) から起動する。

## LocalSend

[LocalSend](https://localsend.org/) を使えば、Apple の AirDrop のように、同じネットワーク上でアプリを実行している他のデバイスにファイルを送信できる。ただしクロスプラットフォームなので、Windows、macOS、Android、iOS、そしてもちろん Linux との間でファイルを送受信できる。

Share メニューは `Super + Ctrl + S` で、または Omarchy メニューの _Trigger > Share_ で開ける。4 つの選択肢がある:

- **Clipboard** はコピーしたものをテキストファイルとして送信する。自分にメールを送らずに、リンクやスニペットをスマートフォンに渡すのに最適だ。
- **File** はファイルピッカーを開き、複数のものを一度に選択できる。
- **Folder** はディレクトリ全体を送信する。
- **Receive** は LocalSend 本体を開き、他のデバイスから何かを送信してもらえるようにする。

ターミナルでも同じことが `omarchy share clipboard`、`omarchy share file [path]`、`omarchy share folder [path]` でできる。パスを省略すればピッカーが表示される。

ファイルマネージャーから直接送信することもできる: Nautilus で選択したものを右クリックし、_Send via LocalSend_ を選ぶ。

Omarchy のファイアウォールはデフォルトで閉じているが、LocalSend のポートだけは例外なので、新規インストール直後からそのまま使える。[セキュリティ](48-security.md) を参照してほしい。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) は完全なオフィススイートで、ワープロ、表計算、プレゼンテーション、描画アプリケーションなどが含まれている。Microsoft Office のファイルと互換性があるので、Word ドキュメントを開けるようにするのに最適な方法だ。

LibreOffice はアプリケーションランチャー (`Super + Space`) から起動する。

## Hype

[Hype](https://github.com/omacom/hype) は Omarchy 独自の、驚くほどシンプルなプレゼンテーションアプリだ。デッキは 1 つの Markdown ファイルで、その横に画像と動画を置く: ライブプレビューの下に各スライドを書き、スライドをドラッグして順序を決め、それから全画面でプレゼンするか、PDF と PowerPoint にエクスポートする。Omarchy テーマも自動で反映される。

Hype はアプリケーションランチャー (`Super + Space`) から起動する。中で `?` を押せば、すべてのショートカットが見られる。

## Signed

[Signed](https://github.com/omacom/signed) は Omarchy 独自の、驚くほどシンプルな PDF への署名と記入の方法だ。保存した署名、テキスト、今日の日付をページ上の任意の場所に配置し、署名済みのコピーをオリジナルの横に保存する。方法は [PDF への記入](27-filling-out-pdfs.md) を参照してほしい。

Signed はアプリケーションランチャー (`Super + Space`) から起動するか、ファイルマネージャーから PDF をこれで開く。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) は Omarchy 独自の、驚くほどシンプルな電卓で、フローティングウィンドウで開く。

Omacalc は `Super + Shift + Q` で起動する (キーボードに電卓キーがある場合はそれでもいい)。

## Signal

[Signal](https://signal.org/) は E2E 暗号化メッセージングのパイオニアであり、大手テクノロジーコングロマリットを経由したくない人にとって優れたコミュニケーションの選択肢だ。

Signal は `Super + Shift + G` で起動する。ベースインストールには含まれていないので、そのキーを初めて押すと、Omarchy がインストールを提案する (Omarchy メニューの _Install > Service_ にもある)。

## Omaview

[Omaview](https://github.com/omacom/omaview) は Omarchy 独自の、驚くほどシンプルな画像ビューア兼メディアプレイヤーだ: 写真、動画、音楽のための 1 つのウィンドウだ。写真を開けば、矢印キーでそのフォルダの残りを順に表示でき、`N` と `P` ではあらゆるものに対してそれができ、`Ctrl + M` でフォルダ全体をグリッド表示する。HEIC、AVIF、JPEG XL の写真も表示し、長尺のものでは中断したところから再開する。

`F` で全画面、`E` で Omasnap で画像を編集するか Omacut で動画をトリミングし、`Ctrl + P` で画像を印刷し、`Delete` でファイルを Trash に移動する (`Ctrl + Z` で戻せる)。中で `?` を押せば、すべてのショートカットが見られる。

Omaview はアプリケーションランチャー (`Super + Space`) から _Media Viewer_ として起動するか、ファイルマネージャーで画像、動画、曲をダブルクリックするだけで起動する。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) は Omarchy 独自の、驚くほどシンプルな動画トリマーだ。クリップの最初と最後を切り取るだけでいいなら、本格的な動画エディタを起動するよりずっとましだ。

Omacut はアプリケーションランチャー (`Super + Space`) から起動する。

## Monologue

[Monologue](https://github.com/omacom/monologue) は Omarchy 独自の、驚くほどシンプルなウェブカメラレコーダーだ。カメラとマイクを一度選べば、あとは `Space` を押して録画し、もう一度押して同じテイクを一時停止したり再開したりできる。常にカメラの最高解像度で録画し、ライブのマイクメーターがあるので、開始前にレベルを確認できる。

テイクを停止すると、すぐに内蔵エディタで開く。クリップをダブルクリックして分割し、ハンドルをドラッグして各部分をトリミングし、不要な部分を取り除く。それから MP4 として保存する。元の録画は破棄するまで保持されるので、いつでも戻って別の切り方をすることができる。

Monologue はアプリケーションランチャー (`Super + Space`) から起動する。
