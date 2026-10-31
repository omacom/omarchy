# モニター

Omarchy はデフォルトで、2x 対応の retina クラスのディスプレイで動作していることを前提にしています。くっきりと鮮明なプログラマー向けフォントを使うにはこれが必要です。ここ数年の高解像度スクリーンを備えたプレミアムなラップトップのほぼすべてが、これに最適化されています。27" 5K の [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) や、32" 6K の [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) で使いたい設定でもあります。

ただし、PPI が 218 以上のディスプレイを使っていないなら、モニター設定を変更した方がいいでしょう。たとえば 27" または 32" の 4K を使っているなら、トップバーのモニターパネルから小数倍のスケールを選べます。あるいは、すべてのモニターに対するデフォルトとして、`~/.config/hypr/monitors.lua` を開き、その組み合わせ向けの推奨設定に切り替えてください。

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

1080p または 1440p のディスプレイを使っているなら、おそらく 1x スケーリングで十分です。GTK アプリと X11 アプリについても同じです。次のように使ってください。

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` の変更は、変更後に起動したアプリケーションに適用されます（GTK は整数しか受け付けないため、モニターのスケールに最も近い整数にしてください）。変更後に大きすぎるウィンドウが残っていれば、必ず終了してください（あるいは `Ctrl + Alt + Del` ですべてのウィンドウを閉じてください！）。

`Super + /` で上げる、`Super + Alt + /` で下げることで、主要なモニタースケーリング比率（1x、1.25x、1.6x、2x、3x、4x）をすばやく切り替えることもできます。トップバーのモニターパネルから選ぶこともできます。これらはフォーカスのあるモニターだけを変更するため、ラップトップの画面と外部ディスプレイでそれぞれ異なるスケールを設定できます。パネルでは各モニターの解像度も設定します。選択内容はその物理モニター用に `~/.local/state/omarchy/monitors/settings` に保存されるため、再起動後も保持され、次にどのポートやドックに接続してもモニターに追従します。これらは `~/.config/hypr/monitors.lua` にある同じモニター向けのルールより優先され、Omarchy がそのファイルを編集することは決してありません。`GDK_SCALE` はすべての画面で共通の 1 つの値であるため、選択したスケールに応じて、最もスケールの小さいモニターから設定されます。これにより、X11 アプリは密度の低い方の画面で大きすぎるようになるのではなく、密度の高い方の画面で少し小さく表示されます。

### テキストを大きくする／小さくする

モニタースケーリングはすべてのサイズを変更します。本当に欲しいのが大きい、または小さい_テキスト_だけなら、それ専用のつまみが 1 つあります。

```
omarchy display text size 14
```

これは 9 から 20 の間のピクセルサイズを受け取り、Omarchy シェル、GTK アプリケーション、ターミナルを一緒に動かすため、デスクトップ全体のバランスが保たれます。引数なしで実行すれば現在の設定が分かり、`omarchy display text size reset` でデフォルトに戻せます。Foot だけが例外です。設定を再読み込みする方法がないため、起動中のターミナルは新しいものを開くまで古いサイズのままになります。

### ラップトップのディスプレイを拡張する／ミラーリングする

ラップトップに外部画面を接続すると、ディスプレイは自動的に拡張されます。ただし、Omarchy メニューの _Trigger > Hardware_、または `Super + Ctrl + Alt + Delete` を使って、代わりにミラーリングに変更できます。これは、その外部画面がプロジェクターで、何かを見せながら作業したいときに特に便利です。

拡張しているとき、ラップトップのふたを閉じると内部画面は自動的にオフになります。ふたを開けると再びオンになります。Omarchy メニューの _Trigger > Hardware_、または `Super + Ctrl + Delete` を使って、手動で制御することもできます。

### 複数の画面を配置する

Hyprland は複数の画面で優れた動作をします。トップバーのモニターパネルには、画面が実際に置かれている場所が描かれます。ある画面を別の画面の側面にドラッグすればそこへ移動でき、その配置は各モニターの他の設定と一緒に保存されます。パネルで対応できないことについては、[Hyprland のモニタードキュメント](https://wiki.hypr.land/Configuring/Basics/Monitors/) で配置方法を詳しく読んでください。Omarchy では、これらは `~/.config/hypr/monitors.lua` に `hl.monitor` エントリとして書き込みます。このファイルには、特定のモニターを解像度、位置、回転を指定して固定するためのコメント入りの例が同梱されています。

すべてのモニターには、それぞれ独自のワークスペース 1 から 10 があります。そのため、`Super + 1` は常に、現在いるモニターの最初のワークスペースを意味します。内部では、Hyprland は依然としてすべてのモニターを通してワークスペースに番号を付けています。ラップトップの画面（または最初のモニター）には 1–10、次のモニターには 11–20 という具合になり、各モニターは接続するたびに自分のブロックを維持します。特定のモニター向けに [workspace rules](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) やウィンドウルールを書く場合はこれらの番号を使ってください。たとえばワークスペース 12 は、2 台目のモニターの 2 番目のワークスペースです。`~/.local/state/omarchy/monitors/workspaces` には、各モニターがどのブロックを持っているかが記載されています。

矢印キーは、レイアウトで辺を共有しているモニター間では機能します。角だけで接している画面や、間に隙間がある画面は隣接していません。その間を移動するには `Ctrl + Alt + Tab` を使ってください。

| ホットキー | モニター間 |
| --- | --- |
| `Super + Arrow` | その方向にもうウィンドウがなくなった時点で、その側にあるモニターへフォーカスを移動する |
| `Super + Shift + Arrow` | その側にあるモニター上のウィンドウと入れ替える |
| `Super + Alt + Arrow` | その側にあるモニター上のグループへウィンドウを移動する |
| `Super + Shift + Ctrl + Arrow` | その側にあるモニターへ、表示中のワークスペース上にウィンドウを移動する |
| `Super + Shift + Alt + Arrow` | その側にあるモニターへワークスペースを移動し、空いていれば番号を維持する |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | レイアウトにかかわらず、次または前のモニターへフォーカスを移動する |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 現在いるモニターにとどまる |

複数画面の位置決めを助ける TUI が欲しいなら、[Hyprmon](https://github.com/erans/hyprmon/) もチェックしてみてください。

### 明るさを制御する

モニターの明るさは、明るさアップ／ダウン専用のファンクションキーで制御します。これらのキーを押しながら shift を押さえると、最大または最小の明るさになります。キーはフォーカスのあるディスプレイを制御するため、DDC/CI に対応した外部モニターもラップトップの画面と同じ方法で調整されます。

### Apple ディスプレイ

Apple のディスプレイを使っている場合、通常のキーボードの明るさキーも、Apple ディスプレイにフォーカスしていれば自動的に機能します。これは `asdcontrol` コマンドによって行われます。

Apple 6K XDR ディスプレイを使っている場合、`hyprctl monitors` の一覧に幽霊のような画面が表示されることがあります。`~/.config/hypr/monitors.lua` に `hl.monitor({ output = "DP-2", disabled = true })` のような記述を入れることで、これをオフにできます。

Intel マシンでは、Apple ディスプレイへの接続には通常の Thunderbolt ケーブルを使うべきです。Thunderbolt のない他のマシンでは、動作させるために通常 [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) を使わなければなりません。
