# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) は、GitHub Desktop のようなアプリケーションに代わる快適な選択肢で、ターミナル内で動作します。

git で管理されている任意のディレクトリに移動して `lazygit` を実行すれば、そのまま起動できます。あるいは Neovim 内で実行することもでき、その場合は `Space G G` で起動します。

異なるペイン間の移動は `Tab` で行います。Files ペインでは `Space` でステージングするファイルを選択し、`c` で新しいコミットを作成できます。利用可能なすべてのコマンドは `?` で確認できます。

## Btop

[Btop](https://github.com/aristocratos/btop) は、メモリ、CPU、ディスク、ネットワークの使用状況を表示する美しいリソースマネージャーです。アクティブなすべてのプロセスも一覧表示し、それらを管理できます。

Omarchy では Activity と呼ばれており、`Super + Shift + T` を押して起動します。フローティングウィンドウとして開きますが、`Super + T` でタイル表示にできます。

## Herdr

[Herdr](https://github.com/omacom-io/herdr) は、ワークスペース、タブ、ペインを提供するターミナルワークスペースマネージャーで、それらすべてを永続セッションで動作させ続け、デタッチして後から戻ってくることができます。

起動する（または既存のセッションに再接続する）には `Super + Ctrl + Return` を使います。Omarchy には Tmux の設定を反映した Herdr の設定が同梱されているため、ここでもプレフィックスキーは `Ctrl + Space` です。すべてのキーバインドは `Super + Ctrl + K` で閲覧できます。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) は、カーネルのバージョン、稼働時間、テーマ、CPU、メモリなど、システム情報を表示します。人気のあった neofetch ツールの後継です。

Omarchy では、Omarchy メニュー（`Super + Space`）の _About_ としてこれが組み込まれています。

## Cliamp

[Cliamp](https://www.cliamp.stream/) は、Winamp 2.x にインスパイアされたレトロなターミナル音楽プレーヤーで、ローファイビート向けのラジオステーションを内蔵しています。`Super + Shift + Alt + M` で、または Omarchy メニューの _Apps_ から起動します。`?` を押すと、キーバインドの全リストが表示されます。

## Wi-Fi と Bluetooth は？

Wi-Fi と Bluetooth 用の TUI はありません — それらは Omarchy シェルの仕事です。上部バーの Wi-Fi アイコンをクリックする（または `Super + Ctrl + N` を押す）とネットワークを表示して接続でき、Bluetooth アイコンをクリックする（または `Super + Ctrl + B` を押す）とデバイスをペアリングして接続できます。詳細は[ネットワーク](35-networking.md)を参照してください。

## 独自のものを追加する

あらゆるターミナルプログラムを、完全なアプリとして扱うことができます。Omarchy メニュー（`Super + Space`）の _Install > TUI_ に移動し、名前、起動コマンド、ウィンドウスタイル、アイコンを指定すれば、他のアプリケーションと同じようにアプリランチャーに表示されるようになります。再び削除するには _Remove > TUI_ を使います。
