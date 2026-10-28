# モニター

Omarchy はデフォルトで、2x 対応の retina クラスのディスプレイで使っていることを前提にしている。あの美しくシャープなプログラマー向けフォントを出すにはこれが必要だ。最近のほぼすべての高解像度画面を備えたプレミアムノートパソコンが最適化されているのもこれだ。27" 5K の [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) や 32" 6K の [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) で使いたくなるのもこれだ。

ただし PPI が 218 以上のディスプレイを使っていないなら、モニター設定を変更した方がいい。たとえば 27" や 32" の 4K なら、`~/.config/hypr/monitors.lua` を開いて（Omarchy メニューの _Setup > Monitors_ から）、その組み合わせ向けの推奨設定に切り替えることでフラクショナルスケーリングを使える：

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

1080p や 1440p のディスプレイを使っているなら、おそらく 1x スケーリングで十分だろう。その場合はこうする：

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` の変更は、変更後に起動したアプリケーションに適用される（しかも GTK は整数しか受け付けないので、モニタースケールに最も近い整数にしておくこと）。だから変更後に大きすぎるウィンドウは必ず終了しておくこと（あるいは `Ctrl + Alt + Del` ですべてのウィンドウを閉じる！）。

`Super + /` で上げ、`Super + Alt + /` で下げることで、主要なモニタースケーリング比率（1x、1.25x、1.6x、2x、3x、4x）をすばやく切り替えることもできる。デフォルト設定なら、これらの変更は再起動後も保持される。

### テキストを大きくしたり小さくしたりする

モニタースケーリングはすべての大きさを変える。変えたいのが _テキスト_ の大きさだけなら、それ専用のつまみはひとつだけだ：

```
omarchy display text size 14
```

9 から 20 のピクセルサイズを指定すると、Omarchy シェル、GTK アプリケーション、ターミナルが一緒に動き、デスクトップ全体のバランスが保たれる。引数なしで実行すれば現在の値が分かり、`omarchy display text size reset` でデフォルトに戻せる。Foot だけが例外だ：設定を再読み込みする方法がないので、実行中のターミナルは新しいものを開くまで古いサイズのままになる。

### ノートパソコンのディスプレイを拡張・ミラーリングする

外部画面をノートパソコンに接続すると、ディスプレイは自動的に拡張される。だが Omarchy メニューの _Trigger > Hardware_ を使うか `Super + Ctrl + Alt + Delete` を使えば、代わりにミラーリングに変更できる。その外部画面がプロジェクターで、作業しながら何かを見せたいときに特に便利だ。

拡張しているときにノートパソコンの蓋を閉じると、内蔵画面は自動的にオフになる。蓋を開ければ再びオンになる。Omarchy メニューの _Trigger > Hardware_ を使うか `Super + Ctrl + Delete` を使って手動で制御することもできる。

### 複数の画面を配置する

Hyprland は複数の画面で快適に動作する。レイアウト方法の詳細は [Hyprland のモニタードキュメント](https://wiki.hypr.land/Configuring/Basics/Monitors/) を読むこと。Omarchy では、これらは `~/.config/hypr/monitors.lua` に `hl.monitor` エントリとして入る ― このファイルには、特定のモニターを解像度、位置、回転に固定するためのコメント付きの例が最初から入っている。

すべてのモニターがそれぞれ独自のワークスペース 1 から 10 を持つので、`Super + 1` は常に対象モニターの最初のワークスペースを意味する。裏側では Hyprland は依然としてすべてのモニター通しでワークスペースに番号を振っている：ノートパソコンの画面（または最初のモニター）が 1–10、次のモニターが 11–20 といった具合で、各モニターは接続するたびに自分のブロックを保持する。特定のモニター向けに [workspace rules](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) やウィンドウルールを書くときはそれらの番号を使うこと。たとえばワークスペース 12 は 2 台目のモニターの 2 番目のワークスペースだ。`~/.local/state/omarchy/monitor-workspaces` には各モニターがどのブロックを持っているかが列挙されている。

矢印キーは、レイアウトで辺を共有するモニター間で機能する。角でしか接していない画面や、間に隙間がある画面は隣接していないので、それらの間は `Ctrl + Alt + Tab` で移動すること。

| ホットキー | モニター間 |
| --- | --- |
| `Super + Arrow` | その方向にもうウィンドウがなくなると、その側にあるモニターへフォーカスを移動する |
| `Super + Shift + Arrow` | その側にあるモニター上のウィンドウと入れ替える |
| `Super + Alt + Arrow` | その側にあるモニター上のグループへウィンドウを移動する |
| `Super + Shift + Ctrl + Arrow` | その側にあるモニターへ、そのモニターが表示しているワークスペース上にウィンドウを移動する |
| `Super + Shift + Alt + Arrow` | その側にあるモニターへワークスペースを移動し、空いていればその番号を維持する |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | レイアウトに関係なく、次または前のモニターへフォーカスを移動する |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | 現在いるモニターにとどまる |

複数の画面の配置を助ける TUI が欲しいなら、[Hyprmon](https://github.com/erans/hyprmon/) もチェックしてみるといい。

### 明るさを制御する

モニターの明るさは専用の明るさアップ／ダウンのファンクションキーで制御する。これらを押しながら shift を押し続けると、最大または最小の明るさになる。このキーはフォーカスしているディスプレイを制御するので、DDC/CI に対応する外部モニターもノートパソコンの画面と同じ方法で調整される。

### Apple ディスプレイ

Apple ディスプレイを使っている場合、Apple ディスプレイにフォーカスしていれば通常のキーボードの明るさキーも自動的に機能する。これは `asdcontrol` コマンドによって行われる。

Apple 6K XDR ディスプレイを使っている場合、`hyprctl monitors` の一覧に幻の画面が表示されることがあることに注意すること。これは _Setup > Monitors_ から `hl.monitor({ output = "DP-2", disabled = true })` のような設定でオフにできる。

Intel マシンでは、Apple ディスプレイには通常の Thunderbolt ケーブルで接続すべきだ。Thunderbolt のない他のマシンでは、動作させるために通常 [DP + USB-A -> USB-C ケーブル](https://www.amazon.com/dp/B0BNX7MS6N) を使わなければならない。
