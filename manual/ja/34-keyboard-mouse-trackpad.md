# キーボード、マウス、トラックパッド

Hyprland では、すべての入力を細かく設定できます。キーボードのリピートを超高速にしたり、トラックパッドでナチュラルスクロールを使ったりできます。すべて `~/.config/hypr/input.lua` で変更します。Omarchy メニュー（`Super + Space`）の _Setup > Input_ からも開けます。そこで設定した内容は、Omarchy のデフォルトを置き換えます。

例を示します:

```lua
hl.config({
  input = {
    -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
    kb_layout = "us,dk",
    kb_options = "omarchy:shift_caps_compose,grp:alts_toggle",

    -- Change speed of keyboard repeat
    repeat_rate = 40,
    repeat_delay = 600,

    -- Increase sensitivity for mouse/trackpad (default: 0)
    sensitivity = 0.35,

    touchpad = {
      -- Use natural (inverse) scrolling
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner
      clickfinger_behavior = true,

      -- Control the speed of your scrolling
      scroll_factor = 0.3,
    },
  },
})

-- Scroll faster in the terminal
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
```

入力については、Hyprland wiki で[すべての入力オプションを確認](https://wiki.hypr.land/Configuring/Basics/Variables/#input)できます。

CapsLock は通常の Caps Lock として動作し、`Shift + CapsLock` は[クイック絵文字](07-hotkeys.md#quick-emojis)や[その他の補完](07-hotkeys.md#quick-completions)のためのコンポーズキーです。コンポーズキーを別の場所にしたい場合は、`kb_options` の `omarchy:shift_caps_compose` を置き換えてください。たとえば、次はコンポーズキーを Right Alt に移します:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### トラックパッドジェスチャー

トラックパッドをスワイプしてデスクトップを移動します:

| ジェスチャー | アクション |
| --- | --- |
| 3本指で左 / 右 | 空のワークスペースを含む、前 / 次のワークスペース |
| 3本指で上 | AI コンソールの切り替え |
| 3本指で下 | Omarchy メニューを開く |
| 4本指で左 / 右 | アクティブなウィンドウを前 / 次のワークスペースへ移動 |
| 4本指で下 | フルスクリーンの切り替え |

変更するには、Hyprland は同じ指と方向に2つのジェスチャーを受け付けないため、まず `~/.config/hypr/input.lua` でそのジェスチャーを解除してから、独自の[タッチパッドジェスチャー](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)を追加してください:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy のジェスチャーをすべてオフにするには、Omarchy のデフォルトが読み込まれる前に、`~/.config/hypr/hyprland.lua` の先頭付近で `omarchy_default_gestures = false` を設定します。

ハプティックタッチパッドを搭載した Dell XPS ノートパソコンでは、_Trigger > Hardware > Touchpad Haptics_ でクリックの強さを low、mid、high に設定することもできます。

### 中国語、日本語、その他の言語での入力

インストーラーがキーボードについて尋ねたら、Japanese、Korean、Chinese (Simplified, Pinyin)、Taiwan (Zhuyin)、Hong Kong (Cangjie) を選択します。Omarchy は、オフラインでの初回起動時のセットアップ中を含め、キーボードと一致する入力エンジンを自動で設定します。Japanese は Mozc、Korean は標準の2ボル式 Hangul、Simplified Chinese は Pinyin、Taiwan は Chewing の標準 Zhuyin 配列、Hong Kong は香港字形の Cangjie を使います。Japanese (US keyboard) は、US キーボード配列で Mozc を提供します。Dvorak、Colemak、AZERTY でラテン文字を入力する場合でも、Hangul、Zhuyin、Cangjie のキーは標準位置のままです。以前に Hangul または Chewing を追加したことがある場合は、_Setup > Typing > Input Methods_ で一度選択を解除してから再選択し、そのキーをそこへ移してください。すでに使って入力しているエンジンには、Omarchy は手を加えません。

入力はラテンモードで始まります。`Super + I` を押すと設定済みの入力メソッドを順に切り替え、`Super + Shift + I` を押すと逆順に切り替えます。`Shift` を単独でタップすると、Pinyin のような入力メソッドからラテン文字へ抜け出し、もう一度タップすると戻ります。Sogou、Microsoft Pinyin、macOS と同じやり方です。`Shift` と文字キーを押すと、引き続き大文字が入力されます。日本語キーボードでは、全角/半角 で入力を切り替え、変換 でオンにし、無変換 でオフにします。Korean では、한/영 が Hangul を切り替え、한자 が Hanja に変換します。これは、キーボードに専用キーがある場合でも、多くのノートパソコンがそうするように、それらの代わりに Right Alt と Right Ctrl を送信する場合でも同様です。そのため、そこでは Right Alt と Right Ctrl は単なる修飾キーではありません。代わりに、ディクテーションは Alt + Space で切り替えます。`Ctrl + Space` は Tmux と Herdr のために引き続き利用できます。`Shift + CapsLock` はコンポーズキーのままです。

複数のキーボード配列や入力メソッドがある場合、バーの右側にキーボードインジケーターが表示されます。クリックすると入力言語を切り替えられます。Japanese では、ひらがなとして あ と表示されます。Japanese の文字候補については、Japanese に切り替え、`nihongo` のような単語を入力し、Space を2回押します。Enter を押すと選択が確定します。複数のキーボード配列もある場合は、インジケーターを右クリックするとそれらを順に切り替えられます。

_Setup > Typing > Keyboard Layouts_ を使い、インストール時に提示されるのと同じ選択肢から、English や French などの配列を選択します。_Setup > Typing > Input Methods_ を使って、どの変換エンジンが有効かを選択します。どちらのピッカーも Omarchy メニュー内に開き、現在の選択にチェックが付いています。クリックするか Enter を押すと選択が切り替わります。各変更はすぐに適用されます。入力メソッドの選択を解除すると、アンインストールせずに切り替えサイクルから外れます。キーボードは引き続き利用できます。

同じピッカーを開くには、`omarchy setup keyboard` または `omarchy setup input` を実行します。コマンドラインから言語を1つ追加するには、`omarchy setup input mozc`、`hangul`、`pinyin`、`chewing`、`cangjie5` を使います。Quick、Boshiamy、Array は Cangjie と同じパッケージに入っており、Input Methods ピッカーに表示されます。カスタムの切り替えキーは保持されます。別のエンジン配列やキーを使うには、`omarchy pkg add fcitx5-configtool` で `fcitx5-configtool` をインストールし、ターミナルから起動します。入力言語を選択しても、デスクトップの言語は変わりません。_Setup > Language_ で Japanese、Korean、Chinese を選択すると、まだ何もない場合にその入力メソッドが追加されます。

`Super + I` を使うと入力メソッドやキーボード配列を順に切り替え、`Super + Shift + I` を使うと逆方向に戻ります。そのため、3つ設定している場合、隣り合う2つの間を行き来できます。入力インジケーターは、入力メソッドや配列が複数設定されている場合にのみ、バーの右側に表示されます。このデスクトップのバインドは、既存の Fcitx 切り替えキーと併用できます。`~/.config/hypr/bindings.lua` で上書きできます。入力エンジンとコンポーズシーケンスは、すべてのセッションですでに動作している [Fcitx5](https://fcitx-im.org/) サービスを使います。

### ALT を SUPER として使う

一部のキーボードでは、主要なメタキー（Windows/cmd キー）を SUPER として使うのが不便です。次の変更で、代わりに ALT を使うようにできます:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
