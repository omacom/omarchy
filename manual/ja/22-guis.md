# GUIs

## Files

Files (Folio) はグラフィカルなファイルマネージャーだ。`Super + Shift + F` で開き、`Super + Shift + Alt + F` でターミナルが現在いるディレクトリで開くので、クリックの手間がかなり省ける。`Ctrl + L` でパスを入力でき、任意のファイルで `Space` を押すと、開かずにフルサイズでプレビューできる。

USBメモリやSDカードを差し込めば自動的にマウントされるので、そのままサイドバーに表示される。ドライブのフォーマット、SMARTの状態確認、パーティションの作成など、もう少し踏み込んだ作業には、アプリランチャー（`Super + Space`）から _Disks_ を起動しよう。

ダブルクリックは賢明なデフォルトに従う：写真、動画、音楽は Omaview で、PDFは Document Viewer で、Markdownは Omawrite で、プレーンテキストはあなたのエディタで開く。_Setup > Defaults > Editor_ で別のものを選ばない限り Plain だ。

## Disktree

ドライブがいっぱいになって、何が容量を食っているのか見当もつかないときは、アプリランチャー（`Super + Space`）から [Disktree](https://github.com/tobi/disktree) を起動しよう。ホームディレクトリのグラフィカルなツリーマップを表示する。大きいブロックほど多くの容量を占めている；キーボードやマウスでディレクトリの中に入り、削除すべきものに印を付け、何も削除する前に選択内容を確認しよう。ディスク全体をスキャンするには `disktree --disk` を実行する。

## Obsidian

[Obsidian](https://obsidian.md/) は、ストレージにシンプルな Markdown ファイルを使う、無料で高度に拡張可能なノート作成アプリケーションだ。

Obsidian は、個人、商用、非営利を含むあらゆる用途で無料だ。

Obsidian は、iOS と Android のモバイルアプリと同期するための[商用アドオン](https://obsidian.md/sync)も提供している。(https://obsidian.md/pricing)。

Obsidian は `Super + Shift + O` で起動する。テーマの同期を使うには、設定で `Omarchy` テーマを選択しなければならない。

## Omawrite

[Omawrite](https://github.com/omacom-io/omawrite) は、Omarchy 独自の非常にシンプルな Markdown 執筆アプリだ。ボルトもプラグインもなく、あなたと言葉だけがある。

Omawrite は `Super + Shift + W` で起動する。

## Pinta

[Pinta](https://www.pinta-project.com/) は基本的な画像編集ツールで、切り抜き、リサイズ、その他の基本的な操作に最適だ。Photoshop の代替品だと期待しないこと。でも魔法の杖とレイヤーはちゃんとある！

Pinta はアプリケーションランチャー（`Super + Space`）で起動する。

## Aether

[Aether](https://github.com/bjarneo/aether) はテーマ作成アプリケーションで、背景画像から色を抽出して、完全で統一感のあるテーマに変えられる。[独自のテーマを作る](43-making-your-own-theme.md)最も簡単な方法だ。

Aether はアプリケーションランチャー（`Super + Space`）で起動する。

## LocalSend

[LocalSend](https://localsend.org/) を使うと、Apple の AirDrop のように、同じネットワーク上でアプリを実行している他のデバイスにファイルを送信できる。ただしクロスプラットフォームなので、Windows、macOS、Android、iOS、そしてもちろん Linux との間でファイルを送受信できる。

Share メニューは `Super + Ctrl + S` で、または Omarchy メニューの _Trigger > Share_ で開ける。4つの選択肢がある：

- **Clipboard** はコピーしたものを何でもテキストファイルとして送信する。自分にメールを送らずに、リンクや断片をスマートフォンに送るのに最適だ。
- **File** はファイルピッカーを開き、一度に複数選択できる。
- **Folder** はディレクトリ全体を送信する。
- **Receive** は LocalSend 本体を開き、他のデバイスからあなたへ何かを送信できるようにする。

ターミナルからも同じことが `omarchy share clipboard`、`omarchy share file [path]`、`omarchy share folder [path]` でできる。パスを省略するとピッカーが表示される。

ファイルマネージャーから直接送信することもできる：Files で任意の選択範囲を右クリックし、LocalSend で共有する。

Omarchy のファイアウォールは LocalSend のポートを除いてデフォルトで閉じられているので、これは新規インストールでもそのまま動作する。[セキュリティ](48-security.md)を参照。

## LibreOffice

[LibreOffice](https://www.libreoffice.org/) は、ワードプロセッサ、表計算、プレゼンテーション、描画アプリケーションなどを備えた完全なオフィスパッケージだ。Microsoft Office のファイルと互換性があるので、あの Word 文書を開けるようにするのに最適な方法だ。

LibreOffice はアプリケーションランチャー（`Super + Space`）で起動する。

## Hype

[Hype](https://github.com/omacom/hype) は Omarchy 独自の非常にシンプルなプレゼンテーションアプリだ。デッキは単一の Markdown ファイルで、その画像と動画はその隣にある：ライブプレビューの下に各スライドを書き、スライドをドラッグして並べ替え、フルスクリーンで発表するか、PDF と PowerPoint にエクスポートする。Omarchy テーマも反映される。

Hype はアプリケーションランチャー（`Super + Space`）で起動する。内部で `?` を押すとすべてのショートカットが見られる。

## Signed

[Signed](https://github.com/omacom/signed) は Omarchy 独自の非常にシンプルな PDF への署名と記入の方法だ。保存した署名、テキスト、今日の日付をページ上の任意の場所に配置し、署名済みのコピーを元のファイルの隣に保存する。方法については[PDFへの記入](27-filling-out-pdfs.md)を参照。

Signed はアプリケーションランチャー（`Super + Space`）で起動するか、ファイルマネージャーから PDF をそれで開く。

## Game Vibes

アプリケーションランチャー（`Super + Space`）にある Game Vibes は、Omarchy の小さなゲームが集まる場所だ：友人や内蔵の対戦相手と対戦する3Dチェスゲーム Checkmate；Klondike ソリティア Cards；トゲとノコギリでいっぱいの10の部屋からなるピクセル単位の精度が求められるプラットフォーマー Death Wish；アーケードシューター Neon Swarm。各ゲームはあなたのテーマに従う単一の Web ページだ。矢印と `Enter` で1つ選び、ゲームのタイトル画面から `Esc`、一時停止中は `Q` でリストに戻る。フルスクリーンで開く：`Super + F` でウィンドウ化し、`Super + W` で閉じる。

エージェントで作ったゲームもここに表示される：エージェントパネルで _Make something cool → Game_ を選び、ゲームを説明するか、Game Vibes に既にあるゲームの名前を挙げて作業を続けよう。エージェントはそれを `~/Games/vibes` にコピーし、そこでは自由に変更でき、完了したら開く。そのコピーは `omarchy games vibes copy <game>` で自分でも作れる。他の誰かが共有したゲームはテーマのようにインストールする：_Install > Gaming > Game Vibes_ を選び、その git アドレスを貼り付けるか、`omarchy games vibes install <git-repo-url>` を実行する。_Remove > Gaming_ で再び削除でき、_Update > Game Vibes Games_ で新しいバージョンを取得する。ゲームは Web から three.js を読み込むので、起動には接続が必要だ。

## Omacalc

[Omacalc](https://github.com/omacom-io/omacalc) は Omarchy 独自の非常にシンプルな電卓で、フローティングウィンドウで開く。

Omacalc は `Super + Shift + Q` で起動する（キーボードに電卓キーがある場合はそれでもよい）。

## Signal

[Signal](https://signal.org/) は E2E 暗号化メッセージングの先駆者であり、大手テクノロジー企業集団を通したくない人にとって素晴らしい通信手段だ。

Signal は `Super + Shift + G` で起動する。基本インストールには含まれていないので、初めてそのキーを押すと、Omarchy がインストールを提案する（Omarchy メニューの _Install > Service_ にもある）。

## Omaview

[Omaview](https://github.com/omacom/omaview) は Omarchy 独自の非常にシンプルな画像ビューア兼メディアプレイヤーだ：写真、動画、音楽のための1つのウィンドウだ。写真を開くと矢印キーでそのフォルダの残りを順に進み、`N` と `P` は何でもそうし、`Ctrl + M` はフォルダ全体をグリッドとして表示する。HEIC、AVIF、JPEG XL の写真も表示し、長いものでは前回終了したところから再開する。

`F` でフルスクリーン、`E` で写真を Omasnap で編集したり動画を Omacut でトリミングしたり、`Ctrl + P` で写真を印刷し、`Delete` でファイルをゴミ箱に移動する（`Ctrl + Z` で戻す）。内部で `?` を押すとすべてのショートカットが見られる。

Omaview はアプリケーションランチャー（`Super + Space`）で _Media Viewer_ として起動するか、ファイルマネージャーで写真、動画、曲をダブルクリックするだけだ。

## Omacut

[Omacut](https://github.com/omacom-io/omacut) は Omarchy 独自の非常にシンプルな動画トリマーだ。クリップの最初と最後を切り取るだけでよいときは、本格的な動画エディタを起動するより優れている。

Omacut はアプリケーションランチャー（`Super + Space`）で起動する。

## Monologue

[Monologue](https://github.com/omacom/monologue) は Omarchy 独自の非常にシンプルな Web カメラレコーダーだ。カメラとマイクを一度選択し、`Space` を押して録画し、もう一度押して同じテイクを一時停止したり再開したりする。常にカメラの最高解像度で録画し、ライブのマイクメーターがあるので開始前にレベルを確認できる。

テイクを停止すると、内蔵エディタですぐに開く。クリップをダブルクリックして分割し、ハンドルをドラッグして各部分をトリミングし、不要な部分を削除する。そして MP4 として保存する。元の録画は破棄するまで保持されるので、いつでも戻って別の切り取り方ができる。

Monologue はアプリケーションランチャー（`Super + Space`）で起動する。
