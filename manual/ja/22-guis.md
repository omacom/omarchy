# GUI

## ファイル

ファイル（Nautilus）はグラフィカルファイルマネージャーです。`Super + Shift + F` で開き、`Super + Shift + Alt + F` でターミナルがいるディレクトリで開くため、クリックの手間を大幅に省けます。`Ctrl + L` でパスを入力でき、任意のファイルで `Space` を押せば、何も開かずにクイックプレビューが得られます。

USB スティックや SD カードを差し込めば自動でマウントされ、サイドバーに表示されます。ドライブのフォーマット、SMART の健康状態の確認、パーティションの作成など、より踏み込んだ作業が必要な場合は、アプリランチャー（`Super + Space`）から _Disks_ を起動してください。

ダブルクリックは妥当なデフォルトに従います。画像は imv、動画は mpv、PDF は Document Viewer、プレーンテキストは Neovim で開きます。

## Disktree

ドライブがいっぱいになって何が食いつぶしているか分からないときは、アプリランチャー（`Super + Space`）から [Disktree](https://github.com/tobi/disktree) を起動してください。ホームディレクトリのグラフィカルなツリーマップが表示されます。大きなブロックほど多くの容量を占めます。キーボードやマウスでディレクトリをたどり、削除すべきものをマークし、何かを取り除く前に選択内容を確認してください。ディスク全体をスキャンするには `disktree --disk` を実行してください。

## Obsidian

[Obsidian](https://obsidian.md/) は無料で高度に拡張可能なノートアプリケーションで、ストレージにシンプルな Markdown ファイルを使います。

Obsidian は個人、商用、非営利を含むすべての用途で無料です。

Obsidian は iOS と Android のモバイルアプリとの同期用の [商用アドオン](https://obsidian.md/sync) も提供しています。(https://obsidian.md/pricing)。

Obsidian は `Super + Shift + O` で起動します。テーマ同期を使うには、設定で `Omarchy` テーマを選択しなければなりません。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) は Omarchy 独自の、極めてシンプルな Markdown 執筆アプリです。Vault もプラグインもなく、あなたと文章だけです。

Omawrite は `Super + Shift + W` で起動します。

## Pinta

[Pinta](https://www.pinta-project.com/) は基本的な画像編集ツールで、切り抜き、リサイズ、その他の基本的な操作に最適です。ただし Photoshop の代替を期待しないでください。それでも Magic Wand とレイヤーがあります！

Pinta はアプリランチャー（`Super + Space`）から起動します。

## Aether

[Aether](https://github.com/bjarneo/aether) はテーマ作成アプリケーションで、背景画像から色を抽出して完成した一貫性のあるテーマに変えられます。[独自のテーマを作る](43-making-your-own-theme.md) 最も簡単な方法です。

Aether はアプリランチャー（`Super + Space`）から起動します。

## LocalSend

[LocalSend](https://localsend.org/) を使えば、Apple の AirDrop のように、同じネットワーク上でそのアプリを実行している他のデバイスへファイルを送信できます。ただしクロスプラットフォームなので、Windows、macOS、Android、iOS、そしてもちろん Linux との間でファイルを送受信できます。

共有メニューは `Super + Ctrl + S` で、または Omarchy メニューの _実行 > 共有_ で開けます。4つの選択肢があります：

- **クリップボード** はコピーしたものをテキストファイルとして送信します。リンクやスニペットを自分にメールすることなく電話に送るのに最適です。
- **ファイル** はファイルピッカーを開き、一度に複数選択できます。
- **フォルダ** はディレクトリ全体を送信します。
- **受信する** は LocalSend 本体を開くため、他のデバイスがあなたに何かを送信できます。

同じことはターミナルから `omarchy share clipboard`、`omarchy share file [path]`、`omarchy share folder [path]` でもできます。パスを省略すればピッカーが表示されます。

ファイルマネージャーから直接送信することもできます。Nautilus で任意の選択範囲を右クリックして _Send via LocalSend_ を選んでください。

Omarchy のファイアウォールはデフォルトで LocalSend のポート以外は閉じているため、新規インストールでもこれは最初から動作します。[セキュリティ](48-security.md) を参照してください。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) はワードプロセッサ、スプレッドシート、プレゼンテーション、描画アプリケーションなどを備えた完全なオフィスパッケージです。Microsoft Office のファイルと互換性があるため、それらの Word 文書を開くのに最適な方法です。

LibreOffice はアプリランチャー（`Super + Space`）から起動します。

## Hype

[Hype](https://github.com/omacom/hype) は Omarchy 独自の、極めてシンプルなプレゼンテーションアプリです。あなたのデッキは、画像と動画を隣に置いた単一の Markdown ファイルです。ライブプレビューの下に各スライドを書き、スライドをドラッグして並べ替え、それからフルスクリーンで発表するか、PDF と PowerPoint にエクスポートしてください。あなたの Omarchy テーマも拾います。

Hype はアプリランチャー（`Super + Space`）から起動します。中で `?` を押すとすべてのショートカットが表示されます。

## Signed

[Signed](https://github.com/omacom/signed) は Omarchy 独自の、極めてシンプルな PDF 署名と記入の方法です。保存済みの署名、テキスト、今日の日付をページ上のどこにでも置き、元のファイルの隣に署名済みコピーを保存してください。方法については [PDF への記入](27-filling-out-pdfs.md) を参照してください。

Signed はアプリランチャー（`Super + Space`）から起動するか、ファイルマネージャーから PDF をそれで開いてください。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) は Omarchy 独自の、極めてシンプルな電卓で、フローティングウィンドウで開きます。

Omacalc は `Super + Ctrl + Q` で起動します（またはキーボードにあれば電卓キーで）。

## Signal

[Signal](https://signal.org/) は E2E 暗号化メッセージングのパイオニアであり、大手テックコングロマリットを通したくない人にとって優れた連絡手段です。

Signal は `Super + Shift + G` で起動します。ベースインストールには含まれていないため、初めて押したときに Omarchy がインストールを提案します（Omarchy メニューの _インストール > Service_ にもあります）。

## mpv

[mpv](https://mpv.io/) はシンプルで高速なメディアプレイヤーで、あらゆるソースからほぼ何でも再生できます。動画を見るのに最適です。

mpv はアプリランチャー（`Super + Space`）から起動するか、ファイルマネージャーで動画をダブルクリックしてください。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) は Omarchy 独自の、極めてシンプルな動画トリマーです。クリップの先頭と末尾を切るだけなら、本格的な動画エディタを起動するより優れています。

Omacut はアプリランチャー（`Super + Space`）から起動します。

## Monologue

[Monologue](https://github.com/omacom/monologue) は Omarchy 独自の、極めてシンプルなウェブカメラレコーダーです。カメラとマイクを一度選んだら、`Space` を押して録画し、もう一度押して同じテイクを一時停止・再開してください。常にカメラの最高解像度で録画し、開始前にレベルを確認できるライブマイクメーターがあります。

テイクを停止すると、内蔵エディタですぐに開きます。クリップをダブルクリックして分割し、ハンドルをドラッグして各部分をトリミングし、要らない部分を取り除いてください。それから MP4 として保存してください。元の録画は破棄するまで保持されるため、いつでも戻って切り方を変えられます。

Monologue はアプリランチャー（`Super + Space`）から起動します。
