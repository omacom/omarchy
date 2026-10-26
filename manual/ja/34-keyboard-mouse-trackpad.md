# キーボード、マウス、トラックパッド

Hyprland では、あらゆる入力を細かく設定できます。キーボードのリピートを超高速にしたり、トラックパッドでナチュラルスクロールを使ったりできます。すべて `~/.config/hypr/input.lua` で変更でき、Omarchy メニュー（`Super + Space`）の _Setup > Input_ からも開けます。そこで設定した内容が Omarchy のデフォルトを置き換えます。

次が例です。

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

入力に関するすべてのオプションは、Hyprland wiki の[入力に関するすべてのオプションを見る](https://wiki.hypr.land/Configuring/Basics/Variables/#input)で確認できます。

CapsLock は通常の Caps Lock として機能し、`Shift + CapsLock` は[クイック絵文字](07-hotkeys.md#quick-emojis)や[その他の補完](07-hotkeys.md#quick-completions)のための Compose キーです。Compose キーを別の場所にしたい場合は、`kb_options` の `omarchy:shift_caps_compose` を置き換えてください。たとえば、次で Compose キーを Right Alt に移動します。

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### トラックパッドジェスチャー

3本指でスワイプしてワークスペースを切り替えるなど、[タッチパッドジェスチャー](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)も有効化できます。

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

触覚タッチパッドを搭載した Dell XPS ノートパソコンでは、_Trigger > Hardware > Touchpad Haptics_ でクリックの強さを弱、中、強に設定することもできます。

### 中国語、日本語、その他の言語での入力

インストーラーがキーボードについて尋ねたときに、日本語、韓国語、中国語（簡体字、Pinyin）、台湾（Zhuyin）、または香港（Cangjie）を選択してください。Omarchy はキーボードと対応する入力エンジンを自動的に設定します。オフラインでの初回起動セットアップ中も同様です。日本語では Mozc、韓国語では標準的な2ボル式 Hangul、簡体字中国語では Pinyin、台湾では Chewing の標準的な Zhuyin 配列、香港では香港字形に対応した Cangjie を使用します。日本語（US キーボード）では、US キーボード配列で Mozc を利用できます。Dvorak、Colemak、AZERTY で Latin 文字を入力する場合でも、Hangul、Zhuyin、Cangjie のキーは標準位置のままになります。以前に Hangul または Chewing を追加していた場合は、_Setup > Typing > Input Methods_ で一度選択を解除してから再選択すると、そのキーがそこへ移動します。すでに使って入力しているエンジンについては、Omarchy はそのままにします。

入力は Latin モードで開始します。`Super + I` を押すと設定済みの入力方式を順に切り替え、`Super + Shift + I` を押すと逆方向に切り替えます。`Shift` を単独で押すと、Pinyin のような入力方式から抜けて Latin 文字に切り替わり、もう一度押すと戻ります。これは Sogou、Microsoft Pinyin、macOS と同じ動作です。`Shift` と文字キーを同時に押せば、引き続き大文字が入力されます。日本語キーボードでは、全角/半角 で入力を切り替え、変換 でオンにし、無変換 でオフにします。韓国語では、한/영 で Hangul を切り替え、한자 で Hanja に変換します。キーボードに専用キーがある場合も、多くのノートパソコンのようにそれらのキーとして Right Alt と Right Ctrl を送信する場合も同様です。そのため、そこでは Right Alt と Right Ctrl は単なる修飾キーではありません。音声入力のプッシュ・トゥ・トークは F9 のままです。`Ctrl + Space` は Tmux と Herdr のために利用でき、`Shift + CapsLock` は Compose キーのままです。

キーボードインジケーターは、複数のキーボード配列または入力方式がある場合にバーの右側に表示されます。クリックすると入力言語を切り替えられます。日本語ではひらがな用に あ が表示されます。日本語の文字候補を選択するには、日本語に切り替えて、`nihongo` のような単語を入力し、Space を2回押してください。Enter を押すと選択が確定します。複数のキーボード配列もある場合は、インジケーターを右クリックするとそれらを順に切り替えられます。

_Setup > Typing > Keyboard Layouts_ を使うと、インストール時に提示される同じ選択肢から英語やフランス語などの配列を選択できます。_Setup > Typing > Input Methods_ を使うと、どの入力エンジンを有効にするかを選択できます。どちらのピッカーも Omarchy メニュー内に開き、現在の選択にチェックが付いています。クリックするか Enter を押すと選択を切り替え、各変更は即座に適用されます。入力方式の選択を解除すると、アンインストールせずに切り替えサイクルから外れます。キーボードは引き続き利用できます。

`omarchy setup keyboard` または `omarchy setup input` を実行すると、同じピッカーを開けます。コマンドラインから言語を1つ追加するには、`omarchy setup input mozc`、`hangul`、`pinyin`、`chewing`、または `cangjie5` を使用してください。Quick、Boshiamy、Array は Cangjie と同じパッケージに含まれ、Input Methods ピッカーに表示されます。カスタムの切り替えキーは保持されます。別のエンジン配列やキーを使う場合は、`omarchy pkg add fcitx5-configtool` で `fcitx5-configtool` をインストールし、ターミナルから起動してください。入力言語を選択してもデスクトップ言語は変わりません。_Setup > Language_ で日本語、韓国語、中国語を選択すると、入力方式がまだない場合にその入力方式が追加されます。

`Super + I` を使うと入力方式またはキーボード配列を順に切り替え、`Super + Shift + I` を使うと逆方向に戻ります。そのため、3つ設定している場合でも隣り合う2つの間を行き来できます。入力インジケーターは、入力方式または配列が複数設定されている場合にのみバーの右側に表示されます。このデスクトップバインディングは、既存の Fcitx 切り替えキーと併用できます。`~/.config/hypr/bindings.lua` で上書きできます。入力エンジンと Compose シーケンスは、すべてのセッションですでに実行されている [Fcitx5](https://fcitx-im.org/) サービスを使用します。

### ALT を SUPER として使う

一部のキーボードでは、プライマリメタキー（Windows/cmd キー）を SUPER として使うのが不便です。次の変更で、代わりに ALT を使うように変更できます。

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
