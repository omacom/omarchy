# GUIs

## Files

Files (Nautilus) はグラフィカルなファイルマネージャーだ。`Super + Shift + F` で開き、`Super + Shift + Alt + F` でターミナルが現在いるディレクトリで開くので、クリックの手間がかなり省ける。`Ctrl + L` でパスを入力でき、任意のファイルで `Space` を押すと、何も開かずにクイックプレビューが表示される。

USB スティックや SD カードを挿すと自動的にマウントされるので、サイドバーにそのまま表示される。ドライブのフォーマット、SMART の状態確認、パーティションの作成など、もっと本格的な作業には、アプリランチャー (`Super + Space`) から _Disks_ を起動しよう。

ダブルクリックは賢明なデフォルトに従う：画像、動画、音楽は Omaview で、PDF は Document Viewer で、Markdown は Omawrite で、プレーンテキストは _Setup > Default > Editor_ で選択したエディターで開く。

## Disktree

ドライブがいっぱいになって、何が容量を食っているのか見当もつかないときは、アプリランチャー (`Super + Space`) から [Disktree](https://github.com/tobi/disktree) を起動しよう。ホームディレクトリのグラフィカルなツリーマップを表示する。大きなブロックほど多くの容量を占めている。キーボードやマウスでディレクトリを辿り、削除すべきものをマークし、何も削除する前に選択内容を確認しよう。ディスク全体をスキャンするには `disktree --disk` を実行する。

## Obsidian

[Obsidian](https://obsidian.md/) は、ストレージにシンプルな Markdown ファイルを使う、無料で拡張性が非常に高いノート作成アプリケーションだ。

Obsidian は、個人、商用、非営利を含む、すべての用途で無料だ。

Obsidian は、iOS と Android のモバイルアプリと同期するための [商用アドオン](https://obsidian.md/sync) も提供している。(https://obsidian.md/pricing)。

Obsidian は `Super + Shift + O` で起動する。テーマの同期を使うには、設定で `Omarchy` テーマを選択しなければならない。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) は、Omarchy 独自の、驚くほどシンプルな Markdown 執筆アプリだ。ボルトもプラグインもなく、あるのは自分と言葉だけだ。

Omawrite は `Super + Shift + W` で起動する。

## Pinta

[Pinta](https://www.pinta-project.com/) は、切り抜き、リサイズ、その他の基本的な操作に最適な基本的な画像編集ツールだ。ただし Photoshop の代替だとは思わないこと。でも Magic Wand とレイヤーはちゃんとある！

Pinta はアプリランチャー (`Super + Space`) から起動する。

## Aether

[Aether](https://github.com/bjarneo/aether) は、背景画像から色を抽出して、完全で統一感のあるテーマに変換できるテーマ作成アプリケーションだ。[独自のテーマを作る](43-making-your-own-theme.md) 最も簡単な方法だ。

Aether はアプリランチャー (`Super + Space`) から起動する。

## LocalSend

[LocalSend](https://localsend.org/) を使えば、Apple の AirDrop のように、同じネットワーク上でアプリを実行している他のデバイスにファイルを送信できる。ただしクロスプラットフォームなので、Windows、macOS、Android、iOS、そしてもちろん Linux との間でもファイルの送受信ができる。

共有メニューは `Super + Ctrl + S` で、または Omarchy メニューの _Trigger > Share_ から開ける。4 つのオプションがある：

- **Clipboard** は、コピーしたものをテキストファイルとして送信する。自分宛てにメールを送らずに、リンクやスニペットをスマートフォンに渡すのに最適だ。
- **File** はファイルピッカーを開き、一度に複数選択できる。
- **Folder** はディレクトリ全体を送信する。
- **Receive** は LocalSend 本体を開き、他のデバイスから何かを送信してもらえるようにする。

ターミナルからも同じことが `omarchy share clipboard`、`omarchy share file [path]`、`omarchy share folder [path]` でできる。パスを省略するとピッカーが表示される。

ファイルマネージャーから直接送信することもできる：Nautilus で任意の選択項目を右クリックし、_Send via LocalSend_ を選ぶだけだ。

Omarchy のファイアウォールは、LocalSend のポートを除いてデフォルトで閉じられているので、新規インストールした状態でもそのまま使える。[セキュリティ](48-security.md) を参照。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) は、ワープロ、スプレッドシート、プレゼンテーション、描画アプリケーションなどを備えた完全なオフィススイートだ。Microsoft Office のファイルと互換性があるので、あの Word 文書を開くのに最適な方法だ。

LibreOffice はアプリランチャー (`Super + Space`) から起動する。

## Hype

[Hype](https://github.com/omacom/hype) は、Omarchy 独自の、驚くほどシンプルなプレゼンテーションアプリだ。デッキは単一の Markdown ファイルで、その横に画像や動画を置く：ライブプレビューの下で各スライドを書き、スライドをドラッグして順序を入れ替え、全画面でプレゼンするか、PDF や PowerPoint にエクスポートする。Omarchy のテーマまで反映される。

Hype はアプリランチャー (`Super + Space`) から起動する。すべてのショートカットを見るには、アプリ内で `?` を押す。

## Signed

[Signed](https://github.com/omacom/signed) は、PDF に署名して記入するための、Omarchy 独自の驚くほどシンプルな方法だ。保存した署名、テキスト、今日の日付をページ上の任意の場所に配置し、署名済みのコピーを元のファイルの横に保存する。方法は [PDF への記入](27-filling-out-pdfs.md) を参照。

Signed はアプリランチャー (`Super + Space`) から起動するか、ファイルマネージャーから PDF をこれで開く。

## Checkmate

[Checkmate](https://github.com/omacom/checkmate) は、Omarchy 独自の 3D チェスゲームだ。同じコンピュータで友人と対戦するか、3 段階の内蔵対戦相手と対戦できる。4 種類の彫刻のような駒セットがあり、それぞれ独自の方法で動く：軌道船、彫刻された木と象牙、森の生き物、そしてキャンディだ。ゲームには時計がなく、一手ごとに保存される。

Checkmate はアプリランチャー (`Super + Space`) から起動し、そこでは Chess として表示される。すべてのショートカットを見るには、アプリ内で `?` を押す。

## Cards

[Cards](https://github.com/omacom/cards) は、Omarchy 独自の Klondike ソリティアだ。3 枚引く形式で、パスの回数に制限はなく、4 種類のカードシリーズがある：1 つはテーマの色で描かれ、残りの 3 つはそれぞれ独自の見た目をしている。カードをクリックしてから移動先をクリックするか、ドラッグするか、ダブルクリックして最適な場所へ送る。ゲームは一手ごとに保存される。

Cards はアプリランチャー (`Super + Space`) から起動する。すべてのショートカットを見るには、その名前をクリックするか、`?` を押す。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) は、Omarchy 独自の驚くほどシンプルな電卓で、フローティングウィンドウで開く。

Omacalc は `Super + Shift + Q` で起動する（キーボードに電卓キーがある場合はそれでもよい）。

## Signal

[Signal](https://signal.org/) は E2E 暗号化メッセージングのパイオニアであり、大手テックコングロマリットを経由したくない人にとって最適なコミュニケーションの選択肢だ。

Signal は `Super + Shift + G` で起動する。基本インストールには含まれていないので、初めてそのキーを押すと、Omarchy が代わりにインストールを提案する（Omarchy メニューの _Install > Service_ からも利用できる）。

## Omaview

[Omaview](https://github.com/omacom/omaview) は、Omarchy 独自の驚くほどシンプルな画像ビューアー兼メディアプレイヤーだ：写真、動画、音楽を 1 つのウィンドウで扱える。写真を開くと矢印キーでそのフォルダ内の残りを順に表示でき、`N` と `P` は何に対しても同じことをし、`Ctrl + M` はフォルダ全体をグリッドで表示する。HEIC、AVIF、JPEG XL の写真も表示でき、長いものは中断した場所から再開する。

`F` を押すと全画面表示、`E` で Omasnap で画像を編集するか Omacut で動画をトリミングし、`Ctrl + P` で画像を印刷し、`Delete` でファイルを Trash に移動する（`Ctrl + Z` で戻す）。すべてのショートカットを見るには、アプリ内で `?` を押す。

Omaview はアプリランチャー (`Super + Space`) から _Media Viewer_ として起動するか、ファイルマネージャーで画像、動画、曲をダブルクリックするだけでも開ける。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) は、Omarchy 独自の驚くほどシンプルな動画トリマーだ。クリップの冒頭と末尾をカットするだけで十分なときに、本格的な動画エディターを起動するよりもはるかに優れている。

Omacut はアプリランチャー (`Super + Space`) から起動する。

## Monologue

[Monologue](https://github.com/omacom/monologue) は、Omarchy 独自の驚くほどシンプルなウェブカメラレコーダーだ。カメラとマイクを一度選択すれば、あとは `Space` を押して録画し、もう一度押して同じテイクを一時停止したり再開したりする。常にカメラの最高解像度で録画し、ライブのマイクメーターがあるので開始前にレベルを確認できる。

テイクを停止すると、内蔵エディターですぐに開く。クリップをダブルクリックして分割し、ハンドルをドラッグして各部分をトリミングし、不要な部分を削除する。そして MP4 として保存する。元の録画は破棄するまで保持されるので、いつでも戻って別の切り方で編集できる。

Monologue はアプリランチャー (`Super + Space`) から起動する。
