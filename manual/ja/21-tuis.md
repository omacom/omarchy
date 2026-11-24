# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) は、GitHub Desktop のようなアプリに代わる楽しい選択肢で、ターミナル内で動作します。

直接実行するには、git で管理されている任意のディレクトリへ移動して `lazygit` を実行します。Neovim の中で実行することもでき、その場合は `Space G G` で起動します。

異なるペイン間の移動には `Tab` を使います。Files ペインでは `Space` でステージングするファイルを選択し、`c` で新しいコミットを作成できます。利用できるすべてのコマンドは `?` で確認できます。

## Btop

[Btop](https://github.com/aristocratos/btop) は、メモリ、CPU、ディスク、ネットワークの使用状況を表示する美しいリソースマネージャーです。アクティブなプロセスをすべて一覧表示し、それらを管理することもできます。

Omarchy では Activity Monitor と呼ばれており、アプリランチャーから、または `Super + Shift + T` を押して起動します。フローティングウィンドウとして開きますが、`Super + T` でタイリングできます。

## Herdr

[Herdr](https://herdr.dev) はターミナルワークスペースマネージャーで、ワークスペース、タブ、ペインを提供し、それらすべてを永続セッションで動かし続けます。そのため、セッションから切り離して後で戻ってくることができます。

アプリランチャーから、または `Super + Ctrl + Return` で起動できます（既存のセッションがある場合は再接続します）。Omarchy には Tmux の設定を踏襲した Herdr の設定が同梱されているため、ここでもプレフィックスキーは `Ctrl + Space` です。すべてのキーバインドは `Super + Ctrl + K` で確認できます。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) は、カーネルのバージョン、稼働時間、テーマ、CPU、メモリなどのシステム情報を表示します。人気のあった neofetch ツールの後継です。

Omarchy では、Omarchy メニュー（`Super + Space`）の _System > About_ としてまとめられています。

## Cliamp

[Cliamp](https://www.cliamp.stream/) は Winamp 2.x にインスパイアされたレトロなターミナル音楽プレーヤーで、lo-fi ビート向けのラジオステーションを内蔵しています。`Super + Shift + Alt + M` で、または Omarchy メニューの _Apps_ から起動します。`?` を押すとキーバインドの一覧が表示されます。

## Wi-Fi と Bluetooth は？

Wi-Fi や Bluetooth 向けの TUI はありません——それらの仕事は Omarchy シェルの担当です。上部バーの Wi-Fi アイコンをクリックする（または `Super + Ctrl + N` を押す）とネットワークを表示して接続でき、Bluetooth アイコンをクリックする（または `Super + Ctrl + B` を押す）とデバイスのペアリングと接続ができます。詳しくは [ネットワーク](35-networking.md) を参照してください。

## 自分で追加する

どんなターミナルプログラムでも、完全なアプリとして扱えます。Omarchy メニュー（`Super + Space`）で _Install > TUI_ へ移動し、名前、起動コマンド、ウィンドウスタイル、アイコンを指定すれば、他のアプリケーションと同じようにアプリランチャーに表示されるようになります。再び削除するには _Remove > TUI_ から行えます。
