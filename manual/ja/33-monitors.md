# モニター

Omarchy はデフォルトで、2x 対応の Retina クラスのディスプレイで動作していることを前提としている。これが、きれいで鮮明なプログラマー向けフォントを得るために必要なものだ。ほぼすべての新しい高解像度画面搭載のプレミアムノートパソコンが最適化されているのもこれだ。27" 5K の [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) や 32" 6K の [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) で使いたくなるのもこれだ。

しかし、PPI が 218 以上のディスプレイを使っていないなら、モニター設定を変更した方がいい。たとえば、27" または 32" の 4K があるなら、トップバーのモニターパネルからそのための小数スケールを選択できる。あるいは、`~/.config/hypr/monitors.lua` を開いて、その組み合わせ向けの推奨設定に切り替えることで、すべてのモニターのデフォルトを設定できる:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

1080p または 1440p のディスプレイを使っているなら、おそらく 1x スケーリングで十分だろう。GTK および X11 アプリも同様だ。その場合は次を使える:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` への変更は、変更後に起動したアプリケーションに適用される（そして GTK は整数しか受け付けないので、モニタースケールに最も近い整数にしておくこと）。だから、変更後に大きすぎるウィンドウは必ず終了すること（あるいは `Ctrl + Alt + Del` で全ウィンドウを閉じろ！）。

主要なモニタースケーリング比（1x、1.25x、1.6x、2x、3x、4x）を、`Super + /` で大きく、`Super + Alt + /` で小さくしながら素早く切り替えることもできるし、トップバーのモニターパネルから1つ選ぶこともできる。これらはフォーカスしているモニターだけを変更するので、ノートパソコンの画面と外部ディスプレイにそれぞれ独自のスケールを持たせることができる。パネルでは各モニターの解像度、リフレッシュレート、回転も設定できる。選択した内容は、その物理モニターについて `~/.local/state/omarchy/monitors/settings` に保存されるので、再起動後も維持され、次にどのポートやドックに接続してもモニターについてくる。これらは、`~/.config/hypr/monitors.lua` にある同じモニターに対するどのルールよりも優先される。Omarchy がそのファイルを編集することは決してない。モニターをすべてそのファイルで設定したいなら、そこに `omarchy_monitor_panel_settings = false` を追加すれば、パネルの変更は Hyprland が再読み込みされるまでしか持続しなくなる。`GDK_SCALE` は全画面で1つの値しか持てないので、選択されたスケールは最も小さいスケールのモニターからそれを設定する。そのため X11 アプリは、もう一方で大きすぎるのではなく、高密度な画面で少し小さく表示される。

### テキストを大きくしたり小さくしたりする

モニタースケーリングはすべてのサイズを変更する。_テキスト_ だけを大きくしたり小さくしたりしたいなら、そのための設定は1つだけだ:

```
omarchy display text size 14
```

これは 9 から 20 の間のピクセルサイズを指定でき、Omarchy シェル、GTK アプリケーション、ターミナルを一緒に動かすので、デスクトップ全体のバランスが保たれる。引数なしで実行すれば現在どこにいるか分かり、`omarchy display text size reset` でデフォルトに戻せる。Foot だけが取り残されている: 設定を再読み込みする方法がないので、実行中のターミナルは新しいものを開くまで古いサイズのままになる。

### ノートパソコンのディスプレイの拡張とミラーリング

外部画面をノートパソコンに接続すると、ディスプレイは自動的に拡張される。しかし、Omarchy メニューの _Trigger > Hardware_ または `Super + Ctrl + Alt + Delete` を使って、代わりにミラーリングに変更できる。外部画面がプロジェクターで、作業しながら何かを見せたい場合に特に役立つ。

拡張している場合、ノートパソコンの蓋を閉じると内蔵画面は自動的にオフになる。蓋を開けると再びオンになる。Omarchy メニューの _Trigger > Hardware_ または `Super + Ctrl + Delete` を使って、これを手動で制御することもできる。

### 複数画面の配置

Hyprland は複数画面で非常にうまく動作する。トップバーのモニターパネルは、画面が置かれている場所にそれらを描く: 1つを別の画面の側面にドラッグすればそこへ移動し、その配置は各モニターの他の設定と一緒に保存される。パネルでカバーできないことについては、[Hyprland のモニタードキュメント](https://wiki.hypr.land/Configuring/Basics/Monitors/)で配置方法を詳しく読んでほしい。Omarchy では、これらは `~/.config/hypr/monitors.lua` に `hl.monitor` エントリとして入る — このファイルには、モニターをオフのままにすること、パネルが提供しないモード、10-bit カラー、可変リフレッシュレートについてのコメント付きの例が付属している。

すべてのモニターにはそれぞれ 1 から 10 のワークスペースがあるので、`Super + 1` は常に対象モニターの最初のワークスペースを意味する。裏側では、Hyprland は依然として全モニターを通してワークスペースに番号を付けている: ノートパソコンの画面（または最初のモニター）には 1–10、次のモニターには 11–20、といった具合で、各モニターは接続するたびにそのブロックを維持する。特定のモニターに対する [ワークスペースルール](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) やウィンドウルールを書く場合はこれらの番号を使うこと。つまりワークスペース 12 は2台目のモニターの2番目のワークスペースだ。`~/.local/state/omarchy/monitors/workspaces` には、各モニターがどのブロックを持っているかが一覧で示されている。

矢印キーは、レイアウトで辺を共有するモニター間では機能する。角でしか接していない画面や、間に隙間がある画面は隣り合っていないので、その間を移動するには `Ctrl + Alt + Tab` を使うこと。

| ホットキー | モニター間 |
| --- | --- |
| `Super + Arrow` | その方向にもうウィンドウがなくなったら、その側のモニターにフォーカスを移動する |
| `Super + Shift + Arrow` | その側のモニター上のウィンドウと入れ替える |
| `Super + Alt + Arrow` | その側のモニター上のグループにウィンドウを移動する |
| `Super + Shift + Ctrl + Arrow` | その側のモニターへ、そのモニターが表示しているワークスペース上にウィンドウを移動する |
| `Super + Shift + Alt + Arrow` | その側のモニターにワークスペースを移動し、空いていればその番号を維持する |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | レイアウトにかかわらず、次または前のモニターにフォーカスを移動する |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 現在いるモニターにとどまる |

複数画面の配置を助ける TUI が欲しいなら、[Hyprmon](https://github.com/erans/hyprmon/) もチェックしてみるといい。

### 明るさの制御

モニターの明るさは、明るさ上げ／下げ専用のファンクションキーで制御される。これらを押しながら Shift を押し続けると、最大または最小の明るさになる。キーはフォーカスしているディスプレイを制御するので、DDC/CI に対応する外部モニターもノートパソコンの画面と同じように調整される。

### Apple ディスプレイ

Apple ディスプレイを使っている場合、Apple ディスプレイにフォーカスしていれば、通常のキーボードの明るさキーも自動的に機能する。これは `asdcontrol` コマンドによって実現されている。

Apple 6K XDR ディスプレイを使っている場合、`hyprctl monitors` の一覧に幻の画面が表示されることがある点に注意してほしい。これは `~/.config/hypr/monitors.lua` に `hl.monitor({ output = "DP-2", disabled = true })` のような記述を加えることでオフにできる。

Intel マシンでは、通常の Thunderbolt ケーブルを使って Apple ディスプレイに接続すべきだ。Thunderbolt のない他のマシンでは、動作させるために通常 [DP + USB-A -> USB-C ケーブル](https://www.amazon.com/dp/B0BNX7MS6N) を使う必要がある。
