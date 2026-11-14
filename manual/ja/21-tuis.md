# TUIs

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) は、GitHub Desktop のようなアプリケーションの素敵な代替となるもので、ターミナル内ではたらく。

Git で管理されているディレクトリーに移動して `lazygit` を実行すれば、そのまま起動できる。Neovim の中で実行することもでき、その場合は `Space G G` で起動できる。

`Tab` を使って別のペインを行き来する。Files ペインでは、`Space` でステージングするファイルを選び、`c` で新しいコミットを作成できる。利用可能なコマンドはすべて `?` で確認できる。

## Btop

[Btop](https://github.com/aristocratos/btop) は、メモリー、CPU、ディスク、ネットワークの使用状況を表示する美しいリソースマネージャーだ。アクティブなプロセスをすべて一覧表示し、それらを管理することもできる。

Omarchy ではこれを Activity Monitor と呼んでおり、アプリランチャーから、または `Super + Shift + T` を押して起動する。フローティングウィンドウとして開くが、`Super + T` でタイリングできる。

## Herdr

[Herdr](https://github.com/omacom-io/herdr) はターミナルワークスペースマネージャーで、ワークスペース、タブ、ペインを提供し、それらすべてを永続セッションで動かし続けるため、デタッチしてあとで戻ってくることができる。

`Super + Ctrl + Return` で起動する（または既存のセッションに再接続する）。Omarchy には Tmux の設定を反映した Herdr の設定が同梱されているため、ここでもプレフィックスキーは `Ctrl + Space` だ。キーバインドはすべて `Super + Ctrl + K` で確認できる。

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) は、カーネルのバージョン、稼働時間、テーマ、CPU、メモリーなどのシステム情報を表示する。人気だった neofetch ツールの後継だ。

Omarchy はこれを Omarchy メニュー（`Super + Space`）の中で _About_ としてまとめている。

## Cliamp

[Cliamp](https://www.cliamp.stream/) は Winamp 2.x に着想を得たレトロなターミナル音楽プレイヤーで、ローファイビート向けのラジオステーションを内蔵している。`Super + Shift + Alt + M` で、または Omarchy メニューの _Apps_ から起動できる。キーバインドの完全な一覧は `?` を押すと表示される。

## Wi-Fi と Bluetooth は？

Wi-Fi や Bluetooth の TUI は見つからないだろう——それらの仕事は Omarchy シェルが担っている。トップバーにある Wi-Fi アイコンをクリックする（または `Super + Ctrl + N` を押す）するとネットワークを確認して接続でき、Bluetooth アイコンをクリックする（または `Super + Ctrl + B` を押す）とデバイスをペアリングして接続できる。全体像は [ネットワーク](35-networking.md) を参照のこと。

## 自分で追加する

どんなターミナルプログラムでも、立派なアプリとして扱える。Omarchy メニュー（`Super + Space`）で _Install > TUI_ に移動し、名前、起動コマンド、ウィンドウスタイル、アイコンを指定すれば、ほかのアプリケーションと同じようにアプリランチャーに表示されるようになる。再び削除したい場合は _Remove > TUI_ から行える。
