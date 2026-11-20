# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) は、GitHub Desktop のようなアプリに代わる楽しい選択肢で、ターミナル内で動作します。

直接実行するには、git で管理されている任意のディレクトリに移動して `lazygit` を実行します。あるいは Neovim の中でも実行でき、`Space G G` で起動できます。

`Tab` を使ってさまざまなペイン間を移動します。Files ペインでは `Space` を使ってステージングするファイルを選択し、`c` を使って新しいコミットを作成できます。利用可能なすべてのコマンドは `?` で確認できます。

## Btop

[Btop](https://github.com/aristocratos/btop) は、メモリ、CPU、ディスク、ネットワークの使用状況を表示する美しいリソースマネージャーです。アクティブなすべてのプロセスも一覧表示し、それらを管理できます。

Omarchy ではこれを Activity Monitor と呼んでおり、アプリランチャーから起動するか、`Super + Shift + T` を押して起動します。フローティングウィンドウとして開き、`Super + T` でタイリングできます。

## Herdr

[Herdr](https://github.com/omacom-io/herdr) は、ワークスペース、タブ、ペインを提供し、それらすべてを永続的なセッションの中で動かし続け、後から切り離して戻ってこられるターミナルワークスペースマネージャーです。

アプリランチャーから、または `Super + Ctrl + Return` で起動（または既存のセッションに再接続）します。Omarchy には Tmux の設定を反映した Herdr の設定が付属しているので、プレフィックスキーもこちらも `Ctrl + Space` です。すべてのキーバインドは `Super + Ctrl + K` で確認できます。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) は、カーネルのバージョン、稼働時間、テーマ、CPU、メモリなど、システム情報を表示します。人気のあった neofetch ツールの後継です。

Omarchy ではこれを Omarchy メニュー（`Super + Space`）の _System > About_ としてパッケージ化しています。

## Cliamp

[Cliamp](https://www.cliamp.stream/) は Winamp 2.x にインスパイアされたレトロなターミナル音楽プレイヤーで、lo-fi ビート向けのラジオステーションを内蔵しています。`Super + Shift + Alt + M` で起動するか、Omarchy メニューの _Apps_ から起動します。`?` を押すとキーバインドの一覧が表示されます。

## Wi-Fi と Bluetooth はどうなの？

Wi-Fi と Bluetooth には TUI はありません — それらの仕事は Omarchy シェルが担います。トップバーの Wi-Fi アイコンをクリックする（または `Super + Ctrl + N` を押す）ことでネットワークを確認して接続でき、Bluetooth アイコンをクリックする（または `Super + Ctrl + B` を押す）ことでデバイスのペアリングと接続ができます。詳細は [networking](35-networking.md) を参照してください。

## 自分で追加する

どんなターミナルプログラムでも、完全なアプリとしての扱いを受けられます。Omarchy メニュー（`Super + Space`）の _Install > TUI_ に移動し、名前、起動コマンド、ウィンドウスタイル、アイコンを指定すれば、他のアプリケーションと同じようにアプリランチャーに表示されます。再び削除するには _Remove > TUI_ から行えます。
