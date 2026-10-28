# モニター

Omarchy はデフォルトで 2x 対応の Retina クラスのディスプレイで使われていると想定している。これなら、きれいでシャープなプログラマー向けフォントが得られる。最近の高解像度スクリーンを備えた高級ノートパソコンのほとんどが最適化されているのもこれだ。27" 5K の [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) や 32" 6K の [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) で使いたくなるのもこれだ。

しかし PPI が 218 以上のディスプレイを使っていないなら、モニター設定を変更した方がいい。たとえば 27" や 32" の 4K なら、`~/.config/hypr/monitors.lua`（Omarchy メニューの _Setup > Monitors_ から）を開いて、その組み合わせ向けの推奨設定に切り替えることで、分数スケーリングが使える：

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

1080p や 1440p のディスプレイを使っているなら、おそらく 1x スケーリングで十分だろう。その場合はこうする：

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` の変更は、変更後に起動したアプリケーションに適用される（そして GTK は整数しか受け付けないので、モニタースケールに最も近い整数にしておくこと）。だから、変更後に大きすぎるままになっているウィンドウは必ず終了させること（または `Ctrl + Alt + Del` ですべてのウィンドウを閉じること！）。

`Super + /` で大きく、`Super + Alt + /` で小さくというように、主なモニタースケール比（1x、1.25x、1.6x、2x、3x、4x）をすばやく切り替えることもできるし、トップバーのモニターパネルから選ぶこともできる。これで変わるのはフォーカスしているモニターだけなので、ノートパソコンの画面と外部ディスプレイにそれぞれ別のスケールを持たせられる。選択は `~/.config/hypr/monitors.lua` にそのモニター向けの `hl.monitor` ルールとして保存されるので、再起動後も残り、`omarchy_monitor_scale` よりも優先される。`omarchy_monitor_scale` は独自のルールを持たないすべてのモニターのスケールとして残る。

### テキストを大きくしたり小さくしたりする

モニタースケーリングはすべてのサイズを変える。大きな、または小さな _text_ だけが欲しいなら、そのためのつまみは一つだけだ：

```
omarchy display text size 14
```

これは 9 から 20 の間のピクセルサイズを取り、Omarchy シェル、GTK アプリケーション、ターミナルを一緒に動かすので、デスクトップ全体のバランスが保たれる。引数なしで実行すれば今の状態が分かり、`omarchy display text size reset` でデフォルトに戻せる。Foot だけは取り残される：設定を再読み込みする方法がないので、実行中のターミナルは新しいものを開くまで古いサイズのままになる。

### ノートパソコンのディスプレイの拡張とミラーリング

ノートパソコンに外部画面を接続すると、ディスプレイは自動的に拡張される。しかし Omarchy メニューの _Trigger > Hardware_ を使うか `Super + Ctrl + Alt + Delete` を押せば、代わりにミラーリングに変更できる。その外部画面がプロジェクターで、作業しながら何かを見せたい場合に特に役立つ。

拡張しているときにノートパソコンの蓋を閉じると、内蔵画面は自動的にオフになる。蓋を開けると再びオンになる。Omarchy メニューの _Trigger > Hardware_ を使うか `Super + Ctrl + Delete` を押せば、手動で制御することもできる。

### 複数画面の配置

Hyprland は複数画面でも素晴らしく動作する。配置方法については [Hyprland のモニターに関するドキュメント](https://wiki.hypr.land/Configuring/Basics/Monitors/) で詳しく読める。Omarchy では、これらは `hl.monitor` エントリとして `~/.config/hypr/monitors.lua` に入る。このファイルには、特定のモニターを解像度、位置、回転に固定するためのコメント付きの例が最初から入っている。

すべてのモニターが独自のワークスペース 1 から 10 を持つので、`Super + 1` は常に今いるモニターの最初のワークスペースを意味する。内部的には、Hyprland は依然としてすべてのモニターを通してワークスペースに番号を付ける：ノートパソコンの画面（または最初のモニター）が 1–10 を、次のモニターが 11–20 を、という具合に持ち、各モニターは接続するたびに自分のブロックを維持する。特定のモニター向けに [ワークスペースルール](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) やウィンドウルールを書く場合はこれらの番号を使うこと。つまりワークスペース 12 は 2 台目のモニターの 2 番目のワークスペースだ。`~/.local/state/omarchy/monitor-workspaces` に、各モニターがどのブロックを持っているかが列挙されている。

矢印キーは、レイアウトで辺を共有しているモニター間で動作する。角でしか接していない画面や、間に隙間がある画面は隣接していないので、それらの間を行き来するには `Ctrl + Alt + Tab` を使う。

| ホットキー | モニター間 |
| --- | --- |
| `Super + Arrow` | その方向にもうウィンドウがなくなったら、その側のモニターにフォーカスを移動する |
| `Super + Shift + Arrow` | その側のモニターにあるウィンドウと入れ替える |
| `Super + Alt + Arrow` | その側のモニターにあるグループにウィンドウを移動する |
| `Super + Shift + Ctrl + Arrow` | その側のモニターへ、そのモニターが表示しているワークスペース上にウィンドウを移動する |
| `Super + Shift + Alt + Arrow` | その側のモニターにワークスペースを移動し、番号が空いていればそのまま維持する |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | レイアウトにかかわらず、次または前のモニターにフォーカスを移動する |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | 今いるモニターにとどまる |

複数画面の位置決めを助ける TUI が欲しいなら、[Hyprmon](https://github.com/erans/hyprmon/) もチェックしてみるといい。

### 明るさの制御

モニターの明るさは、明るさを上げ下げする専用のファンクションキーで制御する。これらを押しながら shift を押し続けると、最大または最小の明るさになる。キーはフォーカスしているディスプレイを制御するので、DDC/CI に対応した外部モニターもノートパソコンの画面と同じ方法で調整される。

### Apple ディスプレイ

Apple ディスプレイを使っている場合、Apple ディスプレイにフォーカスしていれば、通常のキーボードの明るさキーも自動的に動作する。これは `asdcontrol` コマンドによって行われる。

Apple 6K XDR ディスプレイを使っている場合、`hyprctl monitors` の一覧に幻の画面が表示されることがある点に注意すること。_Setup > Monitors_ から `hl.monitor({ output = "DP-2", disabled = true })` のような設定でこれをオフにできる。

Intel マシンでは、通常の Thunderbolt ケーブルを使って Apple ディスプレイに接続すべきだ。Thunderbolt のない他のマシンでは、通常、動作させるために [DP + USB-A -> USB-C ケーブル](https://www.amazon.com/dp/B0BNX7MS6N) を使わなければならない。
