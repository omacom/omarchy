# GUIs

## Files

Files (Nautilus) はグラフィカルなファイルマネージャーだ。`Super + Shift + F` で開き、`Super + Shift + Alt + F` でターミナルが今いるディレクトリで開くので、クリックの手間がかなり省ける。`Ctrl + L` でパスを入力でき、任意のファイルで `Space` を押すと、何も開かずにクイックプレビューできる。

USBメモリやSDカードを差し込むと自動でマウントされるので、そのままサイドバーに表示される。ドライブのフォーマット、SMARTの健康状態の確認、パーティションの作成など、もっと本格的な作業には、アプリランチャー（`Super + Space`）から _Disks_ を起動しよう。

ダブルクリックは納得のいくデフォルトに従う：画像、動画、音楽は Omaview で、PDFは Document Viewer で、プレーンテキストは Neovim で開く。

## Disktree

ドライブが満杯なのに何が食っているのかさっぱり分からないときは、アプリランチャー（`Super + Space`）から [Disktree](https://github.com/tobi/disktree) を起動しよう。ホームディレクトリのグラフィカルなツリーマップを表示する。大きいブロックほど容量を食っている。キーボードやマウスでディレクトリの中に入り、消すものをマークし、実際に削除する前に選択内容を確認しよう。ディスク全体をスキャンするには `disktree --disk` を実行する。

## Obsidian

[Obsidian](https://obsidian.md/) は、ストレージにシンプルなMarkdownファイルを使う、無料で拡張性の高いノート作成アプリケーションだ。

Obsidianは、個人利用、商用利用、非営利利用を含むあらゆる目的で無料だ。

Obsidianは、iOSとAndroidのモバイルアプリと同期するための[商用アドオン](https://obsidian.md/sync)も提供している。(https://obsidian.md/pricing)。

Obsidianは `Super + Shift + O` で起動する。テーマの同期を使うには、設定で `Omarchy` テーマを選択しなければならない。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) は、Omarchy独自の超シンプルなMarkdown執筆アプリだ。保管庫もプラグインもない。あなたと文章だけだ。

Omawriteは `Super + Shift + W` で起動する。

## Pinta

[Pinta](https://www.pinta-project.com/) は、切り抜き、リサイズ、その他の基本的な加工に最適な基本的な画像編集ツールだ。Photoshopの代替になるとは期待しないこと。でもMagic Wandもレイヤーもある！

Pintaはアプリケーションランチャー（`Super + Space`）から起動する。

## Aether

[Aether](https://github.com/bjarneo/aether) は、背景画像から色を抽出して、まとまりのある完全なテーマに変えられるテーマ作成アプリケーションだ。[独自のテーマを作る](43-making-your-own-theme.md)最も簡単な方法だ。

Aetherはアプリケーションランチャー（`Super + Space`）から起動する。

## LocalSend

[LocalSend](https://localsend.org/) を使うと、同じネットワーク上でこのアプリを実行している他のデバイスにファイルを送れる。AppleのAirDropのようなものだ。ただしクロスプラットフォームなので、Windows、macOS、Android、iOS、そしてもちろんLinuxとの間でファイルを送れる。

Shareメニューは `Super + Ctrl + S` で、またはOmarchyメニューの _Trigger > Share_ から開ける。4つの選択肢がある：

- **Clipboard** は、コピーしたものをテキストファイルとして送る。自分宛てにメールしなくても、リンクやスニペットをスマホに送るのに最適だ。
- **File** はファイルピッカーを開き、一度に複数選択できる。
- **Folder** はディレクトリ全体を送る。
- **Receive** はLocalSend本体を開き、他のデバイスからあなたへ何かを送れるようにする。

同じことはターミナルでも `omarchy share clipboard`、`omarchy share file [path]`、`omarchy share folder [path]` でできる。パスを省略すればピッカーが開く。

ファイルマネージャーから直接送ることもできる：Nautilusで選択範囲を右クリックし、_Send via LocalSend_ を選ぶ。

Omarchyのファイアウォールはデフォルトで閉じているが、LocalSendのポートだけは例外なので、これは新規インストールでもそのまま使える。[セキュリティ](48-security.md)を参照。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) は、ワープロ、表計算、プレゼンテーション、描画アプリケーションなどを備えた完全なオフィスパッケージだ。Microsoft Officeのファイルと互換性があるので、Word文書を開けるようにするのに最適な方法だ。

LibreOfficeはアプリケーションランチャー（`Super + Space`）から起動する。

## Hype

[Hype](https://github.com/omacom/hype) は、Omarchy独自の超シンプルなプレゼンテーションアプリだ。デッキは単一のMarkdownファイルで、画像と動画はその横に置く：ライブプレビューの下で各スライドを書き、スライドをドラッグして並べ替え、全画面でプレゼンするか、PDFやPowerPointにエクスポートする。Omarchyテーマも拾ってくれる。

Hypeはアプリケーションランチャー（`Super + Space`）から起動する。中で `?` を押すとすべてのショートカットが見られる。

## Signed

[Signed](https://github.com/omacom/signed) は、Omarchy独自の、PDFに署名して記入するための超シンプルな方法だ。保存済みの署名、テキスト、今日の日付をページ上の任意の場所に置き、署名済みのコピーを元のファイルの横に保存する。やり方は[PDFへの記入](27-filling-out-pdfs.md)を参照。

Signedはアプリケーションランチャー（`Super + Space`）から起動するか、ファイルマネージャーからPDFをこれで開く。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) は、Omarchy独自の超シンプルな電卓で、フローティングウィンドウで開く。

Omacalcは `Super + Shift + Q` で起動する（キーボードに電卓キーがある場合はそれでも）。

## Signal

[Signal](https://signal.org/) はE2E暗号化メッセージングのパイオニアで、大手テック企業群を通りたくない人にとって素晴らしいコミュニケーションの選択肢だ。

Signalは `Super + Shift + G` で起動する。ベースインストールには含まれていないので、初めてそのキーを押すと、Omarchyがインストールを提案する（Omarchyメニューの _Install > Service_ にもある）。

## Omaview

[Omaview](https://github.com/omacom/omaview) は、Omarchy独自の超シンプルな画像ビューアー兼メディアプレイヤーだ：写真、動画、音楽のための1つのウィンドウだ。写真を開くと矢印キーでそのフォルダの残りを順に進み、`N` と `P` はあらゆるものに対してそれを行い、`Ctrl + M` はフォルダ全体をグリッドで表示する。HEIC、AVIF、JPEG XLの写真も表示し、長いものでは前回終了した場所から再開する。

`F` で全画面、`E` で画像をOmasnapで編集するか動画をOmacutでトリミング、`Ctrl + P` で画像を印刷、`Delete` でファイルをゴミ箱へ移動する（`Ctrl + Z` で戻す）。中で `?` を押すとすべてのショートカットが見られる。

Omaviewはアプリケーションランチャー（`Super + Space`）から _Media Viewer_ として起動するか、ファイルマネージャーで写真、動画、曲をダブルクリックするだけだ。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) は、Omarchy独自の超シンプルな動画トリマーだ。クリップの最初と最後を切り取るだけでいいときは、本格的な動画エディタを起動するよりずっとましだ。

Omacutはアプリケーションランチャー（`Super + Space`）から起動する。

## Monologue

[Monologue](https://github.com/omacom/monologue) は、Omarchy独自の超シンプルなウェブカメラレコーダーだ。カメラとマイクを一度選んだら、`Space` を押して録画し、もう一度押して同じテイクを一時停止して再開する。常にカメラの最高解像度で録画し、ライブのマイクメーターがあるので、開始前にレベルを確認できる。

テイクを停止すると、すぐに内蔵エディタで開く。クリップをダブルクリックして分割し、ハンドルをドラッグして各ピースをトリミングし、不要な部分を取り除く。そしてMP4として保存する。元の録画は破棄するまで保持されるので、いつでも戻って別の切り方をすることができる。

Monologueはアプリケーションランチャー（`Super + Space`）から起動する。
