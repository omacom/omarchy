# GUIs

## Files

Files (Nautilus) はグラフィカルなファイルマネージャーだ。`Super + Shift + F` で開き、`Super + Shift + Alt + F` ならターミナルが今いるディレクトリで開くので、クリックの手間がかなり省ける。`Ctrl + L` でパスを入力でき、任意のファイルで `Space` を押せば、何も開かずにクイックプレビューできる。

USBメモリやSDカードを差し込めば自動でマウントされるので、サイドバーにそのまま表示される。ドライブのフォーマット、SMARTの健康状態の確認、パーティションの作成など、もっと本格的な作業にはアプリランチャー（`Super + Space`）から _Disks_ を起動しよう。

ダブルクリックは納得のいくデフォルトに従う。画像、動画、音楽は Omaview で、PDF は Document Viewer で、Markdown は Omawrite で、プレーンテキストは _Setup > Default > Editor_ で選んだエディタで開く。

## Disktree

ドライブがいっぱいになったのに何が食っているのか見当もつかないときは、アプリランチャー（`Super + Space`）から [Disktree](https://github.com/tobi/disktree) を起動しよう。ホームディレクトリをグラフィカルなツリーマップで表示してくれる。ブロックが大きいほど容量を食っている。キーボードやマウスでディレクトリに入っていき、削除すべきものに印を付け、何も削除する前に選択内容を確認しよう。`disktree --disk` を実行すればディスク全体をスキャンできる。

## Obsidian

[Obsidian](https://obsidian.md/) は、ストレージにシンプルな Markdown ファイルを使う、無料で拡張性の非常に高いノートアプリだ。

Obsidian は、個人、商用、非営利を含むすべての用途で無料だ。

Obsidian は、iOS と Android のモバイルアプリと同期するための[商用アドオン](https://obsidian.md/sync)も提供している。(https://obsidian.md/pricing)。

Obsidian は `Super + Shift + O` で起動する。テーマ同期を使うには、設定で `Omarchy` テーマを選択しなければならない。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) は、Omarchy 謹製のとにかくシンプルな Markdown 執筆アプリだ。vault もプラグインもない。あるのはあなたと言葉だけだ。

Omawrite は `Super + Shift + W` で起動する。

## Pinta

[Pinta](https://www.pinta-project.com/) は、切り抜き、リサイズ、その他の基本的な加工に最適な基本的な画像編集ツールだ。Photoshop の代替品だとは思わないこと。だが Magic Wand とレイヤーはちゃんとある！

Pinta はアプリランチャー（`Super + Space`）から起動する。

## Aether

[Aether](https://github.com/bjarneo/aether) は、背景画像から色を抽出して、まとまりのある完全なテーマに変えられるテーマ作成アプリだ。[自分だけのテーマを作る](43-making-your-own-theme.md)ための最も簡単な方法だ。

Aether はアプリランチャー（`Super + Space`）から起動する。

## LocalSend

[LocalSend](https://localsend.org/) を使えば、同じネットワーク上でこのアプリを実行している他のデバイスに、Apple の AirDrop のようにファイルを送れる。しかもクロスプラットフォームなので、Windows、macOS、Android、iOS、そしてもちろん Linux との間でファイルの送受信ができる。

Share メニューは `Super + Ctrl + S` で、または Omarchy メニューの _Trigger > Share_ から開ける。選択肢は4つある：

- **Clipboard** は、コピーしたものを何でもテキストファイルとして送る。自分宛てにメールしなくてもリンクやスニペットをスマホに送れるので便利だ。
- **File** はファイルピッカーを開き、一度に複数選択できる。
- **Folder** はディレクトリ全体を送る。
- **Receive** は LocalSend 本体を開き、別のデバイスからあなたへ何かを送れるようにする。

同じことはターミナルからも `omarchy share clipboard`、`omarchy share file [path]`、`omarchy share folder [path]` でできる。パスを省略すればピッカーが開く。

ファイルマネージャーから直接送ることもできる。Nautilus で任意の選択範囲を右クリックし、_Send via LocalSend_ を選ぶだけだ。

Omarchy のファイアウォールはデフォルトで LocalSend のポートを除いて閉じられているので、これは新規インストールでもそのまま使える。[セキュリティ](48-security.md) を参照。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) は、ワープロ、表計算、プレゼンテーション、描画アプリなどを備えた完全なオフィススイートだ。Microsoft Office のファイルと互換性があるので、あの Word ドキュメントを開けるようにするには最適の方法だ。

LibreOffice はアプリランチャー（`Super + Space`）から起動する。

## Hype

[Hype](https://github.com/omacom/hype) は、Omarchy 謹製のとにかくシンプルなプレゼンテーションアプリだ。デッキは単一の Markdown ファイルで、画像と動画はその隣に置く。各スライドをライブプレビューの下に書き、スライドをドラッグして並べ替え、あとは全画面でプレゼンするか、PDF や PowerPoint に書き出すだけだ。Omarchy テーマまで拾ってくれる。

Hype はアプリランチャー（`Super + Space`）から起動する。中で `?` を押せば、すべてのショートカットが見られる。

## Signed

[Signed](https://github.com/omacom/signed) は、PDF に署名したり入力したりするための、Omarchy 謹製のとにかくシンプルな手段だ。保存済みの署名、テキスト、今日の日付をページの好きな場所に置き、署名済みのコピーを元のファイルの隣に保存しよう。やり方は [PDFへの記入](27-filling-out-pdfs.md) を参照。

Signed はアプリランチャー（`Super + Space`）から起動するか、ファイルマネージャーから PDF をこれで開く。

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) は、Omarchy 謹製の 3D チェスゲームだ。同じコンピュータで友達と対戦するか、3つのレベルの内蔵の対戦相手と戦える。彫刻のような4種類のセットがあり、それぞれ独自のやり方で動く。軌道船、彫刻された木と象牙、森の生き物、キャンディだ。対局に時計はなく、一手ごとに保存される。

Checkmate はアプリランチャー（`Super + Space`）から起動し、そこでは Chess として掲載されている。中で `?` を押せば、すべてのショートカットが見られる。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) は、Omarchy 謹製のとにかくシンプルな電卓で、フローティングウィンドウで開く。

Omacalc は `Super + Shift + Q` で起動する（キーボードに電卓キーがあるならそれでもいい）。

## Signal

[Signal](https://signal.org/) は E2E 暗号化メッセージングの先駆者であり、巨大テック企業のいずれかを経由したくない人にとって優れたコミュニケーションの選択肢だ。

Signal は `Super + Shift + G` で起動する。ベースインストールには含まれていないので、初めてそのキーを押したときは、Omarchy がインストールを提案してくれる（Omarchy メニューの _Install > Service_ にもある）。

## Omaview

[Omaview](https://github.com/omacom/omaview) は、Omarchy 謹製のとにかくシンプルな画像ビューア兼メディアプレイヤーだ。写真、動画、音楽を1つのウィンドウで扱う。写真を開けば矢印キーでそのフォルダの残りを順にたどれるし、`N` と `P` なら何にでも同じことができる。`Ctrl + M` でフォルダ全体をグリッド表示する。HEIC、AVIF、JPEG XL の写真も表示でき、長いものなら前回止めたところから再開してくれる。

`F` で全画面、`E` で画像を Omasnap で編集するか動画を Omacut でトリミングし、`Ctrl + P` で画像を印刷し、`Delete` でファイルを Trash に移動する（`Ctrl + Z` で戻せる）。中で `?` を押せば、すべてのショートカットが見られる。

Omaview はアプリランチャー（`Super + Space`）から _Media Viewer_ として起動するか、ファイルマネージャーで画像、動画、曲をダブルクリックするだけでも開く。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) は、Omarchy 謹製のとにかくシンプルな動画トリマーだ。クリップの冒頭と末尾を切り落とすだけでいいなら、本格的な動画エディタを起動するよりずっとましだ。

Omacut はアプリランチャー（`Super + Space`）から起動する。

## Monologue

[Monologue](https://github.com/omacom/monologue) は、Omarchy 謹製のとにかくシンプルなウェブカメラレコーダーだ。カメラとマイクを一度選んだら、あとは `Space` を押して録画し、もう一度押して同じテイクを一時停止したり再開したりする。常にカメラの最高解像度で録画し、ライブのマイクメーターがあるので、始める前にレベルを確認できる。

テイクを止めると、すぐに内蔵エディタで開く。クリップをダブルクリックして分割し、ハンドルをドラッグして各部分をトリミングし、不要な部分を削除しよう。あとは MP4 として保存するだけだ。元の録画は破棄するまで残るので、いつでも戻ってきて違う切り方ができる。

Monologue はアプリランチャー（`Super + Space`）から起動する。
