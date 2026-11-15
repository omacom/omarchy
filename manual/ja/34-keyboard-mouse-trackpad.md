# キーボード、マウス、トラックパッド

Hyprland では、すべての入力を細かく設定できます。キーボードのリピートを超高速にしたり、トラックパッドでナチュラルスクロールを使ったりできます。設定はすべて `~/.config/hypr/input.lua` で変更します。Omarchy メニュー（`Super + Space`）の _Setup > Input_ からも開けます。そこで設定した内容は Omarchy のデフォルトを置き換えます。

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

入力については、Hyprland wiki で[すべての入力オプションを確認できます](https://wiki.hypr.land/Configuring/Basics/Variables/#input)。

CapsLock は通常の Caps Lock として動作し、`Shift + CapsLock` は[クイック絵文字](07-hotkeys.md#quick-emojis)と[その他の補完](07-hotkeys.md#quick-completions)のためのコンポーズキーです。コンポーズキーを別の場所に置きたい場合は、`kb_options` の `omarchy:shift_caps_compose` を置き換えてください。たとえば、次のようにするとコンポーズキーは Right Alt に移動します:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ファンクションキー

ノートパソコンのキーボードの最上段は、デフォルトではメディアキー（音量、明るさなど）を送信し、`Fn` を押しながら使うと F1-F12 になります。`Fn + Esc` を押すと、もう一度押すまで逆向きにロックされます。ほとんどのキーボードはそのロックを自分で覚えています。ASUS のノートパソコンや Apple スタイルのキーボードでは Linux に任されるため、起動のたびにメディアキーから始まります。代わりに F1-F12 から始めるようにするには、`omarchy keyboard toprow fnkeys` を実行してください（戻すには `omarchy keyboard toprow mediakeys`）。一部のノートパソコンでは再起動後に有効になります。Apple Silicon Mac は独自の設定を保持します。

### トラックパッドジェスチャー

トラックパッドをスワイプしてデスクトップを移動します:

| ジェスチャー | アクション |
| --- | --- |
| 3 本指で左 / 右 | 前 / 次のワークスペース（空のものを含む） |
| 3 本指で上 | AI コンソールの切り替え |
| 3 本指で下 | Omarchy メニューを開く |
| 4 本指で左 / 右 | アクティブなウィンドウを前 / 次のワークスペースへ移動 |
| 4 本指で下 | フルスクリーンの切り替え |

1 つを変更するには、自分の[タッチパッドジェスチャー](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)を追加する前に、`~/.config/hypr/input.lua` でそれを解除してください。Hyprland は同じ指の本数と方向に 2 つのジェスチャーを受け付けないためです:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy のジェスチャーをすべてオフにするには、Omarchy のデフォルトが読み込まれる前に、`~/.config/hypr/hyprland.lua` の先頭付近で `omarchy_default_gestures = false` を設定してください。

ハプティックタッチパッドを搭載した Dell XPS ノートパソコンでは、_Trigger > Hardware > Touchpad Haptics_ でクリックの強さを low、mid、high のいずれかに設定することもできます。

### 中国語、日本語、その他の言語での入力

インストーラーでキーボードを聞かれたら、日本語、韓国語、中国語（簡体字、Pinyin）、台湾（Zhuyin）、香港（Cangjie）のいずれかを選択してください。Omarchy はキーボードとそれに合った入力エンジンを自動で設定します。オフラインでの初回起動時のセットアップ中も同様です。日本語では Mozc、韓国語では標準の 2 セット Hangul、簡体字中国語では Pinyin、台湾では Chewing の標準 Zhuyin 配列、香港では香港字形の Cangjie を使います。Japanese (US keyboard) では US キーボードレイアウトで Mozc を使えます。Dvorak、Colemak、AZERTY でラテン文字を入力する場合でも、Hangul、Zhuyin、Cangjie のキーは標準位置のままです。これより前に Hangul や Chewing を追加していた場合は、_Setup > Keyboard > Input Methods_ で一度選択を解除してから再選択すると、キーがそこへ移動します。すでに使って入力しているエンジンには、Omarchy は手を触れません。

入力はラテン文字モードから始まります。`Super + I` を押すと設定済みの入力方式を順に切り替え、`Super + Shift + I` を押すと逆方向に切り替えます。`Shift` を単独で軽く押すと、Pinyin のような入力方式から抜けてラテン文字になり、もう一度押すと戻ります。Sogou、Microsoft Pinyin、macOS と同じ方式です。`Shift` と文字キーの組み合わせでは引き続き大文字が入力されます。日本語キーボードでは、全角/半角で入力を切り替え、変換でオン、無変換でオフになります。韓国語では、한/영で Hangul を切り替え、한자で Hanja に変換します。キーボードに専用キーがある場合も、多くのノートパソコンのようにそれらの代わりに Right Alt と Right Ctrl を送信する場合も同様です。そのため、そこでは Right Alt と Right Ctrl は単なる修飾キーにはなりません。代わりに音声入力は Alt + Space で切り替えます。`Ctrl + Space` は Tmux と Herdr のために引き続き使え、`Shift + CapsLock` は引き続きコンポーズキーです。

キーボードインジケーターは、複数のキーボードレイアウトや入力方式がある場合にバーの右側に表示されます。クリックすると入力言語を切り替えられます。日本語ではひらがなに あ と表示されます。日本語の文字候補を使うには、日本語に切り替えて、`nihongo` のような単語を入力し、Space を 2 回押します。Enter を押すと選択が確定します。複数のキーボードレイアウトもある場合は、インジケーターを右クリックするとそれらを順に切り替えられます。

_Setup > Keyboard > Keyboard Inputs_ を使うと、English や French などのレイアウトを、インストール時に提示されるのと同じ選択肢から選べます。_Setup > Keyboard > Input Methods_ を使うと、有効にする変換エンジンを選べます。どちらのピッカーも Omarchy メニュー内に開き、現在の選択にチェックが付いています。クリックするか Enter を押すと選択が切り替わり、各変更はすぐに適用されます。入力方式の選択を解除すると、アンインストールせずに切り替えサイクルから外れます。キーボードは引き続き利用できます。

同じピッカーを開くには `omarchy setup keyboard` または `omarchy setup input` を実行します。コマンドラインから言語を 1 つ追加するには、`omarchy setup input mozc`、`hangul`、`pinyin`、`chewing`、`cangjie5` のいずれかを使います。Quick、Boshiamy、Array は Cangjie と同じパッケージに含まれ、Input Methods ピッカーに表示されます。カスタムの切り替えキーは保持されます。別のエンジンレイアウトやキーを使うには、`omarchy pkg add fcitx5-configtool` で `fcitx5-configtool` をインストールし、ターミナルから起動してください。入力言語を選択してもデスクトップの言語は変わりません。_Setup > Language_ で日本語、韓国語、中国語を選ぶと、まだ入力方式がない場合にその入力方式が追加されます。

`Super + I` を使うと入力方式やキーボードレイアウトを順に切り替え、`Super + Shift + I` を使うと逆方向に戻ります。そのため、3 つ設定している場合でも隣同士の 2 つの間を移動できます。入力インジケーターは、入力方式やレイアウトが複数設定されている場合にのみバーの右側に表示されます。このデスクトップのキーバインドは、既存の Fcitx 切り替えキーと併用できます。`~/.config/hypr/bindings.lua` で上書きできます。入力エンジンとコンポーズシーケンスは、すべてのセッションですでに動作している [Fcitx5](https://fcitx-im.org/) サービスを使います。

### ALT を SUPER として使用する

一部のキーボードでは、プライマリメタキー（Windows/cmd キー）を SUPER として使うのが不便です。次の変更で、代わりに ALT を使うように変更できます:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
