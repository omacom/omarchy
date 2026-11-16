# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) は GitHub Desktop のようなアプリケーションに対する楽しい代替であり、ターミナル内で実行されます。

直接実行するには、git で管理されている任意のディレクトリに移動して `lazygit` を実行します。あるいは Neovim 内で実行することもでき、その場合は `Space G G` で起動できます。

`Tab` を使って異なるペイン間を移動します。Files ペインでは `Space` を使ってステージングするファイルを選択し、`c` で新しいコミットを作成できます。`?` を使うと利用 가능한すべてのコマンドを確認できます。

## Btop

[Btop](https://github.com/aristocratos/btop) は、メモリ、CPU、ディスク、ネットワークの使用状況を表示する美しいリソースマネージャーです。アクティブなプロセスをすべて一覧表示し、それらを管理することもできます。

Omarchy では Activity Monitor と呼ばれており、アプリランチャーから、または `Super + Shift + T` を押して起動します。フローティングウィンドウとして開きますが、`Super + T` でタイル表示できます。

## Herdr

[Herdr](https://github.com/omacom-io/herdr) は、ワークスペース、タブ、ペインを提供するターミナルワークスペースマネージャーであり、それらすべてを永続的なセッションで実行し続け、切り離して後で戻ってくることができます。

アプリランチャーから、または `Super + Ctrl + Return` で起動します（あるいは既存のセッションに再接続します）。Omarchy には Tmux の設定を反映した Herdr の設定が同梱されているため、ここでもプレフィックスキーは `Ctrl + Space` です。`Super + Ctrl + K` でキーバインドをすべて閲覧できます。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) は、カーネルバージョン、稼働時間、テーマ、CPU、メモリなどのシステム情報を表示します。人気のあった neofetch ツールの後継です。

Omarchy はこれを Omarchy メニュー（`Super + Space`）の _About_ として同梱しています。

## Cliamp

[Cliamp](https://www.cliamp.stream/) は Winamp 2.x に着想を得たレトロなターミナル音楽プレイヤーであり、lo-fi ビート向けのラジオ局が内蔵されています。`Super + Shift + Alt + M` で起動するか、Omarchy メニューの _Apps_ から起動します。`?` を押すとキーバインドの一覧全体が表示されます。

## Wi-Fi と Bluetooth は？

Wi-Fi と Bluetooth 向けの TUI は見つかりません — それらの仕事は Omarchy シェルの担当です。上部バーの Wi-Fi アイコンをクリックする（または `Super + Ctrl + N` を押す）とネットワークを表示して接続でき、Bluetooth アイコンをクリックする（または `Super + Ctrl + B` を押す）とデバイスをペアリングして接続できます。詳細は [ネットワーキング](35-networking.md) を参照してください。

## 独自のものを追加する

どんなターミナルプログラムでも、完全なアプリとしての扱いを受けられます。Omarchy メニュー（`Super + Space`）の _Install > TUI_ に移動し、名前、起動コマンド、ウィンドウスタイル、アイコンを指定すれば、他のどのアプリケーションとも同じようにアプリランチャーに表示されるようになります。再び削除するには _Remove > TUI_ から行えます。
