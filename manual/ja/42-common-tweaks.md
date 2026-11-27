# よくある調整

これは Omarchy のセットアップによくあるカスタマイズを集めたものだ。システムアップデートのために、特定の設定を元の状態に戻す必要が時々生じることは知っておいてほしい。そうなった場合でも、変更が失われることはなく、元のファイルの隣に `.bak.<timestamp>` ファイルとして置かれる。

何かを台無しにしてしまった場合は、Omarchy メニューの _Update > Config_ から個別の設定を元のセットアップに復元できる。本当にすべてを台無しにしてしまった場合は、`omarchy reinstall configs` で全ての設定をリセットするか、`omarchy reinstall` で全てのデフォルトパッケージと設定を再インストールできる。

### 全てのトレイアイコンを常に表示する

デフォルトでは、Dropbox、1password、Steam のようなトレイアイコンはトレイ展開矢印の後ろに隠れており、その矢印にホバーすると表示される。常に表示しておきたい場合は、展開矢印を右クリックしてトレイアイコンマネージャーを開き、表示し続けたいアイコンをピン留めする（二度と見たくないアイコンを隠すこともできる）。

### ウィンドウの角を丸くする

Omarchy のデフォルトデザインは角張ったコーナーだが、少し柔らかくしたい場合は、Omarchy メニューの _Appearance > Windows > Window Corners > Rounded Corners_ を選ぶか、`omarchy hyprland corners rounded` を実行する。_Theme Corners_ にすると、テーマが使うものに戻る。自分で半径を指定するには、_Theme Corners_（`omarchy hyprland corners theme`）のままにしておく。Rounded と Sharp は自分の設定の後に読み込まれて上書きしてしまうからだ。その上で、`~/.config/hypr/looknfeel.lua` の rounding のコメントを解除する：

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### ウィンドウの隙間をなくす

ラップトップのディスプレイでは、ウィンドウの隙間（あるいは `Super + Shift + Space` でオフに切り替えられるトップバーでさえ）にピクセルを無駄にしたくない人もいる。`Super + Shift + Backspace` で全ての隙間と境界線をまとめてオフに切り替えるか、`~/.config/hypr/looknfeel.lua` のこのセクションのコメントを外して恒久的に取り除くことができる：

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
