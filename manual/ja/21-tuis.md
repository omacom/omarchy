# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) は GitHub Desktop アプリケーションのようなものの楽しい代替であり、ターミナル内で動作します。

git で管理されている任意のディレクトリへ移動して `lazygit` を実行すれば直接起動できます。あるいは Neovim 内で実行することもでき、`Space G G` で起動できます。

`Tab` で異なるペイン間を移動します。Files ペインでは `Space` でステージングするファイルを選択し、`c` で新しいコミットを作成できます。利用可能なすべてのコマンドは `?` で確認できます。

## Btop

[Btop](https://github.com/aristocratos/btop) はメモリ、CPU、ディスク、ネットワークの使用状況を表示する美しいリソースマネージャーです。すべての有効なプロセスも一覧表示し、管理できます。

Omarchy ではこれを Activity と呼び、`Super + Ctrl + T` を押して起動します。フローティングウィンドウとして開き、`Super + T` でタイルできます。

## Herdr

[Herdr](https://github.com/omacom-io/herdr) はターミナルのワークスペースマネージャーで、ワークスペース、タブ、ペインを提供し、それらすべてを、デタッチして後で戻ってこられる永続セッションで動かし続けます。

`Super + Ctrl + Return` で起動（または既存セッションへの再接続）します。Omarchy には Tmux の設定をミラーした Herdr の設定が同梱されているため、プレフィックスキーはここでも `Ctrl + Space` です。すべてのキーバインドは `Super + Ctrl + K` で閲覧できます。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) はカーネルのバージョン、アップタイム、テーマ、CPU、メモリなどのシステム情報を表示します。人気の neofetch ツールの後継です。

Omarchy ではこれを Omarchy メニュー（`Super + Space`）の _情報_ としてパッケージしています。

## Cliamp

[Cliamp](https://www.cliamp.stream/) は Winamp 2.x に触発されたレトロなターミナル音楽プレイヤーで、ローファイビート用のラジオステーションを内蔵しています。`Super + Shift + Alt + M` で起動するか、Omarchy メニューの _アプリ_ から起動してください。`?` を押すとキーバインドの完全なリストが表示されます。

## Wi-Fi と Bluetooth は？

Wi-Fi と Bluetooth 向けの TUI は見つかりません — それらの仕事は Omarchy シェルに属します。上部バー（メニューバー）の Wi-Fi アイコンをクリックするか（または `Super + Ctrl + W` を押すか）すればネットワークを表示して接続でき、Bluetooth アイコンをクリックするか（または `Super + Ctrl + B` を押すか）すればデバイスをペアリングして接続できます。詳しくは [ネットワーク](35-networking.md) を参照してください。

## 独自の TUI を追加する

どんなターミナルプログラムでも完全なアプリ待遇を受けられます。Omarchy メニュー（`Super + Space`）の _インストール > TUI_ へ移動し、名前、起動コマンド、ウィンドウスタイル、アイコンを指定すれば、他のアプリケーションと同様にアプリランチャーに表示されます。再び削除するには _削除 > TUI_ を使ってください。
