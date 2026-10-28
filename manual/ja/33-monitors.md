# モニター

Omarchy はデフォルトで、2x 対応の Retina クラスのディスプレイで動作することを前提としている。これが、美しく鮮明なプログラマー向けフォントを得るために必要なものだ。ほぼすべての新しい高解像度画面を備えたプレミアムノートパソコンの最適化対象がこれだ。27" 5K の [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) や 32" 6K の [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) で動作させたいのもこれだ。

ただし、PPI が 218 以上のディスプレイを使っていないなら、モニター設定を変更した方がいい。たとえば 27" や 32" の 4K があるなら、`~/.config/hypr/monitors.lua` を開いて（Omarchy メニューの _Setup > Monitors_ から）、その組み合わせ向けの推奨設定に切り替えることで分数スケーリングを使える：

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

1080p や 1440p のディスプレイを使っているなら、おそらく 1x スケーリングで十分だろう。その場合は次を使える：

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` への変更は、変更後に起動したアプリケーションに適用される（そして GTK は整数しか受け付けないので、モニターのスケールに最も近い整数にしておくこと）。だから、変更後に大きすぎるままになっているウィンドウは必ず終了すること（あるいは `Ctrl + Alt + Del` で全ウィンドウを閉じること！）。

`Super + /` で高い方へ、`Super + Alt + /` で低い方へ進めていくことで、主要なモニタースケーリング比率（1x、1.25x、1.6x、2x、3x、4x）をすばやく切り替えることもできるし、トップバーのモニターパネルから選ぶこともできる。これらはフォーカスのあるモニターだけを変更するので、ノートパソコンの画面と外付けディスプレイでそれぞれ別のスケールを持てる。選択は `~/.config/hypr/monitors.lua` にそのモニター向けの `hl.monitor` ルールとして保存されるので、再起動後も維持され、すべてのモニター共通のスケールとして残る `omarchy_monitor_scale` よりも優先される。`GDK_SCALE` は全画面で 1 つの値しか持てないため、これらの変更ではスケールが最も小さいモニターに合わせて設定される。だから X11 アプリは、もう一方の画面で大きすぎるよりは、高密度な画面で少し小さく表示される。

### テキストを大きくしたり小さくしたりする

モニタースケーリングはすべてのサイズを変更する。単に _テキスト_ だけを大きくしたり小さくしたりしたいなら、それ専用のノブが 1 つある：

```
omarchy display text size 14
```

これは 9 から 20 の間のピクセルサイズを受け取り、Omarchy シェル、GTK アプリケーション、ターミナルをまとめて動かすので、デスクトップ全体のバランスが保たれる。引数なしで実行すれば現在の値がわかり、`omarchy display text size reset` でデフォルトに戻せる。Foot だけが唯一の遅れん坊だ：設定をリロードする方法がないので、実行中のターミナルは新しいものを開くまで古いサイズのままになる。

### ノートパソコンのディスプレイの拡張とミラーリング

ノートパソコンに外付け画面を接続すると、ディスプレイは自動的に拡張される。だが、Omarchy メニューの _Trigger > Hardware_ を使うか `Super + Ctrl + Alt + Delete` を押すことで、代わりにミラーリングへ変更できる。これは特に、その外付け画面がプロジェクターで、作業しながら何かを見せたい場合に役立つ。

拡張している場合、ノートパソコンの蓋を閉じると内蔵画面は自動的にオフになる。蓋を開けると再びオンになる。Omarchy メニューの _Trigger > Hardware_ や `Super + Ctrl + Delete` を使って手動で制御することもできる。

### 複数の画面を配置する

Hyprland は複数の画面で素晴らしく動作する。配置方法の詳細は [Hyprland のモニターに関するドキュメント](https://wiki.hypr.land/Configuring/Basics/Monitors/) を読むこと。Omarchy では、これらは `~/.config/hypr/monitors.lua` に `hl.monitor` エントリとして記述する — このファイルには、特定のモニターを解像度、位置、回転に固定するためのコメントアウトされた例が付属している。

すべてのモニターがそれぞれ独自のワークスペース 1 から 10 を持っているので、`Super + 1` は常に対象モニターの最初のワークスペースを意味する。裏側では、Hyprland は依然として全モニター通しでワークスペースに番号を振っている：ノートパソコンの画面（または最初のモニター）が 1–10、次のモニターが 11–20、という具合で、各モニターは接続するたびに自分のブロックを保持する。特定のモニター向けに [ワークスペースルール](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) やウィンドウルールを書く場合はこれらの番号を使うこと。たとえばワークスペース 12 は 2 台目のモニターの 2 番目のワークスペースだ。`~/.local/state/omarchy/monitor-workspaces` には各モニターがどのブロックを持っているかが列挙されている。

矢印キーは、レイアウトで辺を共有するモニター間では動作する。角でしか接していない画面や、間に隙間がある画面は隣り合っていないので、それらの間を行き来するには `Ctrl + Alt + Tab` を使うこと。

| ホットキー | モニター間 |
| --- | --- |
| `Super + Arrow` | その方向にもうウィンドウがなくなると、その側のモニターへフォーカスを移動する |
| `Super + Shift + Arrow` | その側のモニター上のウィンドウと入れ替える |
| `Super + Alt + Arrow` | ウィンドウをその側のモニター上のグループへ移動する |
| `Super + Shift + Ctrl + Arrow` | ウィンドウをその側のモニターへ、そのモニターが表示しているワークスペース上に移動する |
| `Super + Shift + Alt + Arrow` | ワークスペースをその側のモニターへ移動し、空いていればその番号を保持する |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | レイアウトに関係なく、次のモニターまたは前のモニターへフォーカスを移動する |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 現在のモニターにとどまる |

複数の画面の配置を手助けする TUI が欲しいなら、[Hyprmon](https://github.com/erans/hyprmon/) もチェックしてみるといい。

### 明るさを制御する

モニターの明るさは、明るさアップ／ダウン専用のファンクションキーで制御する。これらを押しながら shift を押さえ続けると、最大または最小の明るさになる。キーはフォーカスのあるディスプレイを制御するので、DDC/CI に対応した外付けモニターもノートパソコンの画面と同じように調整される。

### Apple ディスプレイ

Apple ディスプレイを使っている場合、Apple ディスプレイにフォーカスしていれば、通常のキーボードの明るさキーも自動的に機能する。これは `asdcontrol` コマンドを通じて行われる。

Apple 6K XDR ディスプレイを使っている場合、`hyprctl monitors` の一覧に幽霊画面が表示されることがある点に注意すること。これは _Setup > Monitors_ 経由で `hl.monitor({ output = "DP-2", disabled = true })` のような設定を行うことでオフにできる。

Intel マシンでは、通常の Thunderbolt ケーブルを使って Apple ディスプレイに接続すべきだ。Thunderbolt のない他のマシンでは、通常、動作させるために [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) を使わなければならない。
