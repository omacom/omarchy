# キーボード、マウス、トラックパッド

Hyprland では、すべての入力を細かく設定できます。キーボードのリピートを超高速にしたり、トラックパッドでナチュラルスクロールを使ったりできます。すべて `~/.config/hypr/input.lua` で変更します。Omarchy メニュー（`Super + Space`）の _Setup > Input_ からも開けます。そこで設定した内容は Omarchy のデフォルトを置き換えます。

例はこちらです:

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

Hyprland wiki で入力に関する [すべての入力オプションを見る](https://wiki.hypr.land/Configuring/Basics/Variables/#input) ことができます。

CapsLock は通常の Caps Lock として動作し、`Shift + CapsLock` は [クイック絵文字](07-hotkeys.md#quick-emojis) と [その他の補完](07-hotkeys.md#quick-completions) のための compose キーです。compose キーを別の場所にしたい場合は、`kb_options` の `omarchy:shift_caps_compose` を置き換えてください。たとえば、次で compose キーを Right Alt に移動します:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ファンクションキー

ノートパソコンのキーボードの最上段は、デフォルトではメディアキー（音量、明るさなど）を送信し、`Fn` を押しながらだと F1-F12 になります。`Fn + Esc` で逆にロックされ、もう一度押すまで維持されます。ほとんどのキーボードはそのロックを自体で覚えています。ASUS のノートパソコンや Apple スタイルのキーボードでは Linux に任されており、起動のたびにメディアキーから始まります。代わりに F1-F12 から始めるには、`omarchy device keyboard toprow fnkeys` を実行します（戻すには `omarchy device keyboard toprow mediakeys`）。一部のノートパソコンでは再起動後に有効になります。Apple Silicon Mac は独自の設定を保持します。

### トラックパッドジェスチャー

トラックパッドでスワイプしてデスクトップを移動します:

| ジェスチャー | アクション |
| --- | --- |
| 3 本指で左 / 右 | 前 / 次のワークスペース（空のものを含む） |
| 3 本指で上 | AI コンソールを切り替え |
| 3 本指で下 | Omarchy メニューを開く |
| 4 本指で左 / 右 | アクティブなウィンドウを前 / 次のワークスペースへ移動 |
| 4 本指で下 | フルスクリーンを切り替え |

変更するには、`~/.config/hypr/input.lua` でそれを解除してから、自分の [タッチパッドジェスチャー](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/) を追加してください。Hyprland は同じ指の本数と方向に 2 つのジェスチャーを受け付けません:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy のジェスチャーをすべてオフにするには、Omarchy のデフォルトが読み込まれる前に、`~/.config/hypr/hyprland.lua` の冒頭付近で `omarchy_default_gestures = false` を設定します。

ハプティックタッチパッド搭載の Dell XPS ノートパソコンでは、_Trigger > Hardware > Touchpad Haptics_ でクリックの強さを low、mid、high に設定することもできます。

### 中国語、日本語、その他の言語での入力

インストーラーがキーボードを尋ねてきたら、日本語、韓国語、中国語（簡体字、Pinyin）、台湾（Zhuyin）、または香港（Cangjie）を選択してください。Omarchy はキーボードと対応する入力エンジンを自動で設定します。オフラインの初回起動セットアップ中も含みます。日本語は Mozc、韓国語は標準の 2 式 Hangul、簡体字中国語は Pinyin、台湾は Chewing の標準 Zhuyin 配列、香港は香港字形の Cangjie を使います。Japanese (US keyboard) は US キーボードレイアウトで Mozc を提供します。Hangul、Zhuyin、Cangjie のキーは、Dvorak、Colemak、AZERTY でラテン文字を入力する場合でも標準位置のままです。これより前に Hangul や Chewing を追加していた場合は、_Setup > Keyboard > Input Methods_ で一度選択を解除して再選択すると、そのキーがそこへ移動します。Omarchy は、すでに使って入力しているエンジンには手を付けません。

入力はラテンモードから始まります。`Super + I` を押すと設定済みの入力方法を順に切り替え、`Super + Shift + I` で逆方向に切り替えます。`Shift` を単独でタップすると、Pinyin のような入力方法から抜けてラテン文字になり、もう一度タップすると戻ります。Sogou、Microsoft Pinyin、macOS と同じ方式です。`Shift` と文字キーの組み合わせでは通常通り大文字が入力されます。日本語キーボードでは、全角/半角 で入力を切り替え、変換 でオン、無変換 でオフになります。韓国語では、한/영 で Hangul を切り替え、한자 で Hanja に変換します。専用キーがあるキーボードでも、多くのノートパソコンのようにそれらの代わりに Right Alt と Right Ctrl を送信するキーボードでも動作します。そのため、そこでは Right Alt と Right Ctrl は単なる修飾キーではありません。代わりに音声入力は Alt + Space で切り替えます。`Ctrl + Space` は Tmux と Herdr 用に利用可能なままです。`Shift + CapsLock` は compose キーのままです。

複数のキーボードレイアウトや入力方法がある場合、バーの右側にキーボードインジケーターが表示されます。クリックすると入力言語を切り替えます。日本語ではひらがなに あ と表示されます。日本語の文字候補を選ぶには、日本語に切り替え、`nihongo` のような単語を入力し、Space を 2 回押します。Enter を押して選択を確定します。複数のキーボードレイアウトもある場合は、インジケーターを右クリックするとそれらを順に切り替えます。

_Setup > Keyboard > Keyboard Inputs_ を使って、インストール時に提示されるのと同じ選択肢から English や French などのレイアウトを選択します。_Setup > Keyboard > Input Methods_ を使って、アクティブな変換エンジンを選択します。どちらのピッカーも Omarchy メニュー内で開き、現在の選択にチェックが付いています。クリックするか Enter を押すと選択を切り替えます。各変更はすぐに適用されます。入力方法の選択を解除すると、アンインストールせずに切り替えの循環から外れます。キーボードは引き続き利用できます。

`omarchy setup keyboard` または `omarchy setup input` を実行すると、同じピッカーが開きます。コマンドラインから言語を 1 つ追加するには、`omarchy setup input mozc`、`hangul`、`pinyin`、`chewing`、または `cangjie5` を使います。Quick、Boshiamy、Array は Cangjie と同じパッケージに含まれ、Input Methods ピッカーに表示されます。カスタムの切り替えキーは保持されます。別のエンジンレイアウトやキーを使うには、`omarchy pkg add fcitx5-configtool` で `fcitx5-configtool` をインストールし、ターミナルから起動します。入力言語を選択してもデスクトップの言語は変わりません。まだ入力方法がない場合、_Setup > Language_ で Japanese、Korean、Chinese を選択すると、その入力方法が追加されます。

`Super + I` で入力方法またはキーボードレイアウトを順に切り替え、`Super + Shift + I` で逆方向に戻ります。そのため、3 つ設定している場合でも隣り合う 2 つの間を移動できます。入力インジケーターは、入力方法またはレイアウトが複数設定されている場合にのみバーの右側に表示されます。このデスクトップのバインドは既存の Fcitx 切り替えキーと併用できます。`~/.config/hypr/bindings.lua` で上書きできます。入力エンジンと compose シーケンスは、すべてのセッションですでに実行中の [Fcitx5](https://fcitx-im.org/) サービスを使います。

### ALT を SUPER として使う

一部のキーボードでは、主要なメタキー（Windows/cmd キー）を SUPER として使うのが不便です。次の変更で、代わりに ALT に変更できます:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
