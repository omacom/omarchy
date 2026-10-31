# モニター

Omarchy は、デフォルトで 2x 対応の Retina クラスのディスプレイで動作していることを前提としています。美しくシャープなプログラマー向けフォントを使うにはこれが必要です。最新の高解像度スクリーンを搭載したほぼすべてのプレミアムノート PC が最適化されているのも、このクラスです。27" 5K の [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) や 32" 6K の [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) で使いたい構成でもあります。

ただし、PPI が 218 以上のディスプレイを使っていない場合は、モニター設定を変更する必要があります。たとえば 27" または 32" の 4K を使っている場合は、トップバーのモニターパネルから小数スケールを選択するか、`~/.config/hypr/monitors.lua` を開いて、その組み合わせ向けの推奨設定に切り替えることで、すべてのモニターのデフォルトを設定できます。

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

1080p または 1440p のディスプレイを使っている場合は、おそらく 1x スケーリングそのままがよく、GTK および X11 アプリも同様でよいはずなので、次のようにできます。

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` の変更は、変更後に起動したアプリケーションに適用されます（GTK は整数しか受け付けないため、モニタースケールに最も近い整数に保ってください）。そのため、変更後に大きすぎる状態になっているウィンドウは必ず終了してください（または `Ctrl + Alt + Del` ですべてのウィンドウを閉じてください！）。

`Super + /` で上へ、`Super + Alt + /` で下へと、主要なモニタースケーリング比率（1x、1.25x、1.6x、2x、3x、4x）をすばやく切り替えることもできますし、トップバーのモニターパネルから 1 つ選択することもできます。これらはフォーカスしているモニターのみを変更するので、ノート PC の画面と外部ディスプレイでそれぞれ異なるスケールにできます。パネルでは各モニターの解像度も設定します。選択内容はその物理モニター用に `~/.local/state/omarchy/monitors/settings` に保存されるため、再起動後も保持され、次にどのポートやドックに接続してもモニターに追従します。これらは `~/.config/hypr/monitors.lua` 内の同じモニター向けルールより優先され、Omarchy がそのファイルを編集することは決してありません。モニターをすべてそのファイルで設定したい場合は、`omarchy_monitor_panel_settings = false` を追加してください。パネルでの変更は Hyprland がリロードされるまでしか持続しなくなります。`GDK_SCALE` はすべての画面で 1 つの値しか持てないため、選択したスケールでは最もスケールの小さいモニターから設定されます。その結果、X11 アプリはもう一方で大きすぎになるのではなく、高密度な画面で少し小さくなります。

### テキストを大きくまたは小さくする

モニタースケーリングはすべてのサイズを変更します。もっと大きくまたは小さくしたいのが _テキスト_ だけなら、そのためのノブは 1 つだけです。

```
omarchy display text size 14
```

9 から 20 の間のピクセルサイズを指定すると、Omarchy シェル、GTK アプリケーション、ターミナルが一緒に移動するので、デスクトップ全体のバランスが保たれます。引数なしで実行すると現在の値が表示され、`omarchy display text size reset` でデフォルトに戻ります。Foot だけが例外です。設定をリロードする方法がないため、実行中のターミナルは新しいターミナルを開くまで古いサイズのままになります。

### ノート PC ディスプレイの拡張とミラーリング

外部画面をノート PC に接続すると、ディスプレイは自動的に拡張されます。ただし、Omarchy メニューの _Trigger > Hardware_ または `Super + Ctrl + Alt + Delete` を使って、代わりにミラーリングに変更できます。外部画面がプロジェクターで、作業しながら何かを表示したい場合に特に便利です。

拡張しているときにノート PC の蓋を閉じると、内蔵画面は自動的にオフになります。蓋を開くと再びオンになります。Omarchy メニューの _Trigger > Hardware_ または `Super + Ctrl + Delete` を使って手動で制御することもできます。

### 複数画面の配置

Hyprland は複数画面でも非常にうまく動作します。トップバーのモニターパネルには画面が実際に配置されている通りに描かれます。1 つを別の画面の側面にドラッグするとそこへ移動し、その配置は各モニターの他の設定と一緒に保存されます。パネルで対応できないことについては、[Hyprland モニター ドキュメント](https://wiki.hypr.land/Configuring/Basics/Monitors/) でレイアウト方法を詳しく読んでください。Omarchy では、これらは `~/.config/hypr/monitors.lua` に `hl.monitor` エントリとして記述します。このファイルには、特定のモニターを解像度、位置、回転に固定するためのコメント付きの例が入っています。

すべてのモニターがそれぞれ独自のワークスペース 1 から 10 を持っているため、`Super + 1` は常に今いるモニターの最初のワークスペースを意味します。内部では、Hyprland は依然としてすべてのモニターを通してワークスペースに番号を付けています。ノート PC の画面（または最初のモニター）が 1–10 を、次のモニターが 11–20 を、という具合に受け取り、各モニターは接続するたびにそのブロックを保持します。特定のモニター向けに [ワークスペース ルール](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) やウィンドウルールを書く場合はこれらの番号を使ってください。たとえばワークスペース 12 は 2 台目のモニターの 2 番目のワークスペースです。`~/.local/state/omarchy/monitors/workspaces` には、各モニターがどのブロックを持っているかが一覧表示されます。

矢印キーは、レイアウトで辺を共有するモニター間ではたらきます。角でしか接していない画面や、間に隙間がある画面は隣接していないため、それらの間を移動するには `Ctrl + Alt + Tab` を使ってください。

| ホットキー | モニター間 |
| --- | --- |
| `Super + Arrow` | その方向にもうウィンドウがなくなると、その側にあるモニターにフォーカスを移動する |
| `Super + Shift + Arrow` | その側にあるモニター上のウィンドウと入れ替える |
| `Super + Alt + Arrow` | ウィンドウをその側にあるモニター上のグループへ移動する |
| `Super + Shift + Ctrl + Arrow` | ウィンドウをその側にあるモニターへ、そのモニターが表示しているワークスペース上に移動する |
| `Super + Shift + Alt + Arrow` | ワークスペースをその側にあるモニターへ移動し、空いていればその番号を保持する |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | レイアウトに関係なく、次または前のモニターにフォーカスを移動する |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | 今いるモニターにとどまる |

複数画面の配置を支援する TUI がほしい場合は、[Hyprmon](https://github.com/erans/hyprmon/) もチェックしてみてください。

### 明るさの制御

モニターの明るさは、明るさを上げる／下げる専用のファンクションキーで制御します。これらのキーを押しながら Shift を押し続けると、最大または最小の明るさになります。これらのキーはフォーカスしているディスプレイを制御するため、DDC/CI に対応した外部モニターもノート PC の画面と同じ方法で調整されます。

### Apple ディスプレイ

Apple ディスプレイを使っている場合、Apple ディスプレイにフォーカスしていれば、通常のキーボードの明るさキーも自動的にはたらきます。これは `asdcontrol` コマンドによって実現されています。

Apple 6K XDR ディスプレイを使っている場合は、`hyprctl monitors` の一覧に幽霊画面が表示されることがある点に注意してください。これは `~/.config/hypr/monitors.lua` 内の `hl.monitor({ output = "DP-2", disabled = true })` のような記述でオフにできます。

Intel マシンでは、通常の Thunderbolt ケーブルを使って Apple ディスプレイに接続すべきです。Thunderbolt のない他のマシンでは、通常、動作させるために [DP + USB-A -> USB-C ケーブル](https://www.amazon.com/dp/B0BNX7MS6N) を使う必要があります。
