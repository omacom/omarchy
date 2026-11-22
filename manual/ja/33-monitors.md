# モニター

Omarchy は、デフォルトでは 2x 対応の Retina クラスのディスプレイを使っていることを前提にしている。これが、美しくシャープなプログラマー向けフォントを得るために必要なものだ。高解像度画面を備えたほぼすべての新しいプレミアムノートパソコンが最適化されているのもこれだ。27" 5K の [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) や、32" 6K の [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) で使いたくなるのもこれだ。

しかし、218 以上の PPI のディスプレイを使っていないなら、モニター設定を変更したくなるはずだ。たとえば、27" または 32" の 4K がある場合、トップバーのモニターパネルからその小数スケールを選択できるし、`~/.config/hypr/monitors.lua` を開いてその組み合わせ向けの推奨設定に切り替えることで、すべてのモニターのデフォルトを設定することもできる:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

1080p または 1440p のディスプレイを使っているなら、おそらく 1x スケーリングを使いたいだけだろう。GTK および X11 アプリについても同様だ。次のようにできる:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

`GDK_SCALE` への変更は、変更後に起動したアプリケーションに適用される (そして GTK は整数しか受け付けないので、モニタースケールに最も近い整数に保っておくこと)。だから、変更後に大きすぎるウィンドウは必ず終了させること (あるいは `Ctrl + Alt + Del` で全ウィンドウを閉じよ！)。

また、`Super + /` で大きく、`Super + Alt + /` で小さくして、主要なモニタースケーリング比率 (1x、1.25x、1.6x、2x、3x、4x) をすばやく切り替えたり、トップバーのモニターパネルから 1 つを選んだりもできる。これらはフォーカスしているモニターだけを変更するので、ノートパソコンの画面と外部ディスプレイでそれぞれ独自のスケールを持てる。パネルでは、各モニターの解像度、リフレッシュレート、回転も設定できる。選択内容は、その物理モニターについて `~/.local/state/omarchy/monitors/settings` に保存されるので、再起動後も維持され、次にそのモニターをどのポートやドックに接続してもついてくる。これらは、Omarchy が決して編集しない `~/.config/hypr/monitors.lua` 内の同じモニターに対するあらゆるルールより優先される。モニターを完全にそのファイルで設定したいなら、そのファイルに `omarchy_monitor_panel_settings = false` を追加すれば、パネルの変更は Hyprland がリロードされるまでしか持続しなくなる。`GDK_SCALE` は全画面で 1 つの値なので、選択したスケールでは最もスケールの低いモニターからそれが設定され、その結果、X11 アプリはもう一方で大きすぎるのではなく、高密度な画面で少し小さく表示される。

### テキストを大きくまたは小さくする

モニタースケーリングはすべてのサイズを変える。欲しいのが大きくまたは小さい _テキスト_ だけなら、そのためのつまみは 1 つだけだ:

```
omarchy display text size 14
```

これは 9 から 20 の間のピクセルサイズを取り、Omarchy シェル、GTK アプリケーション、ターミナルを一緒に動かすので、デスクトップ全体のバランスが保たれる。引数なしで実行すれば現在の値が分かり、`omarchy display text size reset` でデフォルトに戻せる。Foot だけが遅れてついてくるものだ: 設定をリロードする方法がないので、実行中のターミナルは新しいものを開くまで古いサイズのままになる。

### ノートパソコンのディスプレイの拡張とミラーリング

ノートパソコンに外部画面を接続すると、ディスプレイは自動的に拡張される。しかし、トップバーのモニターパネル内の _Extend_ | _Mirror_、Omarchy メニュー内の _Trigger > Hardware_、または `Super + Ctrl + Alt + Delete` で、代わりにミラーリングに変更できる。その外部画面がプロジェクターで、作業しながら何かを見せたい場合に特に役立つ。

拡張しているとき、ノートパソコンの蓋を閉じると内蔵画面が自動的にオフになる。蓋を開けると再びオンになる。Omarchy メニュー内の _Trigger > Hardware_ または `Super + Ctrl + Delete` を使って、手動で制御することもできる。

### 複数画面の配置

Hyprland は複数画面で素晴らしく動作する。トップバーのモニターパネルは、画面が置かれている場所にそれらを描く: 1 つを別のものの側面にドラッグすればそこへ移動し、その配置は各モニターの他の設定と一緒に保存される。パネルでカバーできないことについては、[Hyprland のモニタードキュメント](https://wiki.hypr.land/Configuring/Basics/Monitors/) で配置方法を詳しく読むこと。Omarchy では、これらは `hl.monitor` エントリーとして `~/.config/hypr/monitors.lua` に入る — このファイルには、モニターをオフのままにすること、パネルが提供しないモード、10 ビットカラー、可変リフレッシュレートのためのコメントアウトされた例が同梱されている。

すべてのモニターが独自の 1 から 10 のワークスペースを持つので、`Super + 1` は常に対象モニターの最初のワークスペースを意味する。内部では、Hyprland は依然として全モニター通しでワークスペースに番号を付ける: ノートパソコンの画面 (または最初のモニター) は 1–10、次のモニターは 11–20、といった具合で、各モニターは接続するたびに自分のブロックを保持する。特定のモニター向けの [ワークスペースルール](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) やウィンドウルールを書く場合は、これらの番号を使うこと。つまり、ワークスペース 12 は 2 台目のモニターの 2 番目のワークスペースだ。`~/.local/state/omarchy/monitors/workspaces` には、各モニターがどのブロックを持っているかが列挙されている。

矢印キーは、レイアウト内で辺を共有するモニター間でも動作する。角でしか接していない画面や、間に隙間がある画面は隣り合っていないので、それらの間は `Ctrl + Alt + Tab` を使って移動すること。

| ホットキー | モニター間 |
| --- | --- |
| `Super + Arrow` | その方向にもうウィンドウがなくなると、その側のモニターへフォーカスを移動する |
| `Super + Shift + Arrow` | その側のモニター上のウィンドウと入れ替える |
| `Super + Alt + Arrow` | ウィンドウをその側のモニター上のグループへ移動する |
| `Super + Shift + Ctrl + Arrow` | ウィンドウをその側のモニターへ、そのモニターが表示しているワークスペース上へ移動する |
| `Super + Shift + Alt + Arrow` | ワークスペースをその側のモニターへ移動し、空いていればその番号を維持する |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | レイアウトに関係なく、次のモニターまたは前のモニターへフォーカスを移動する |
| `Super + 1-0`、`Super + Tab`、`Super + Scroll Wheel` | 今いるモニターにとどまる |

複数画面の配置を助ける TUI が欲しいなら、[Hyprmon](https://github.com/erans/hyprmon/) もチェックしてみるといい。

### 明るさの制御

モニターの明るさは、明るさアップ／ダウン専用のファンクションキーで制御する。これらを押しながら Shift を押し続けると、最大または最小の明るさになる。キーはフォーカスしているディスプレイを制御するので、DDC/CI を扱える外部モニターもノートパソコンの画面と同じ方法で調整される。

### Apple ディスプレイ

Apple ディスプレイを使っている場合、Apple ディスプレイにフォーカスしていれば、通常のキーボードの明るさキーも自動的に動作する。これは `asdcontrol` コマンドを通じて行われる。

Apple 6K XDR ディスプレイを使っている場合、`hyprctl monitors` の一覧に幻の画面が見えることがあるので注意すること。これは、`~/.config/hypr/monitors.lua` に `hl.monitor({ output = "DP-2", disabled = true })` のようなものを書くことでオフにできる。

Intel マシンでは、通常の Thunderbolt ケーブルを使って Apple ディスプレイに接続すべきだ。Thunderbolt のない他のマシンでは、通常、動作させるために [DP + USB-A -> USB-C ケーブル](https://www.amazon.com/dp/B0BNX7MS6N) を使う必要がある。
