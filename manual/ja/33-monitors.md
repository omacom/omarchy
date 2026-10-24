# モニター（ディスプレイ）

Omarchy はデフォルトで2x対応の Retina クラスディスプレイで動いていると想定します。これが、シャープできれいなプログラマー向けフォントを得るために必要なものです。ほぼすべての新しい高解像度画面付きプレミアムノートPCはこれ向けに最適化されています。27" 5K の [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) または 32" 6K の [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/) を動かしたいでしょう。

しかし、PPI が 218 以上のディスプレイで動かしていないなら、モニター設定を変えたくなるでしょう。たとえば、27" または 32" の 4K があれば、`~/.config/hypr/monitors.lua` を開き（Omarchy メニューの _設定 > Monitors_ 経由）、その組み合わせ向けの推奨に切り替えて分数スケーリングを使えます：

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

1080p または 1440p のディスプレイを使っているなら、恐らく 1x スケーリングだけを使うと良いでしょう。その場合は次を使えます：

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

`GDK_SCALE` への変更は、その変更後に開始したアプリケーションに適用されます（そして GTK は整数しか扱わないため、あなたのモニタースケールに最も近い整数に保ってください）。そのため、変更後に過大なウィンドウがあれば必ず閉じてください（または `Ctrl + Alt + Del` ですべてのウィンドウを閉じてください！）。

主要なモニタースケーリング比（1x、1.25x、1.6x、2x、3x、4x）を素早く行き来することもでき、`Super + /` でより大きく、`Super + Alt + /` でより小さくできます。デフォルト設定を持っている場合、これらの変更は再起動を超えて持続します。

### テキストを大きくする／小さくする

モニタースケーリングはすべての大きさを変えます。あなたが欲しいのが大きなまたは小さな _テキスト_ だけなら、それ用のノブが1つだけあります：

```
omarchy display text size 14
```

これは9〜20のピクセルサイズを取り、Omarchy シェル、GTK アプリケーション、あなたのターミナルを一緒に動かします。そのためデスクトップ全体は比率が保持されます。引数なしで実行すると現在どこにいるか表示され、`omarchy display text size reset` でデフォルトに戻ります。Foot は唯一の遅れがちです。その設定をリロードする方法はないため、実行中のターミナルは新しいのを開くまで古いサイズを保持します。

### ノートPCディスプレイの拡張とミラーリング

ノートPCに外付け画面を接続すると、ディスプレイは自動で拡張されます。が、それをミラーリングに変更でき、Omarchy メニューの _実行 > Hardware_ または `Super + Ctrl + Alt + Delete` を使って切り替えます。これはその外付け画面がプロジェクターで、作業しながら何かを見せたい場合に特に役立ちます。

拡張中、ノートPCの蓋を閉じると、自動で内蔵画面がオフになります。蓋を開けると、再びオンになります。これも Omarchy メニューの _実行 > Hardware_ または `Super + Ctrl + Delete` で手動でも制御できます。

### 複数画面の配置

Hyprland は複数画面で大いに動作します。それらのレイアウト方法については [Hyprland モニター文書](https://wiki.hypr.land/Configuring/Basics/Monitors/) でさらに読みましょう。[特定のワークスペースを特定のモニターに割り当て](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) ることもできます。Omarchy では、これらのルールは `~/.config/hypr/monitors.lua` に `hl.monitor` エントリとしてあります — ファイルには特定のモニターを解像度、位置、回転にピン留めするためのコメントアウト済みの例が同梱されています。

複数の画面の配置を助ける TUI がほしければ、[Hyprmon](https://github.com/erans/hyprmon/) もチェックしてください。

### 輝度の制御

モニターの輝度は輝度のアップ／ダウン用の専用ファンクションキーで制御されます。Shift を押したままこれらを押せば、最大または最小の輝度に移動します。キーはあなたがフォーカスしているディスプレイを制御します。そのため DDC/CI で通信する外付けモニターはノートPC画面と同じ方法で調整されます。

### Apple ディスプレイ

Apple ディスプレイを使っている場合、その Apple ディスプレイにフォーカスしている場合、通常のキーボード輝度キーは自動で動作します。これは `asdcontrol` コマンドを通じてなされます。

Apple 6K XDR ディスプレイを使っている場合、`hyprctl monitors` のリストに幻影画面が見える場合がある点に注意してください。これは _設定 > Monitors_ 経由の `hl.monitor({ output = "DP-2", disabled = true })` のようなものでオフにできます。

Intel マシン上では、通常の Thunderbolt ケーブルで Apple ディスプレイに接続すべきです。Thunderbolt がない他のマシン上では、それを動作させるために通常 [DP + USB-A -> USB-C ケーブル](https://www.amazon.com/dp/B0BNX7MS6N) を使わなければなりません。
