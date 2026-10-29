# キーボード、マウス、トラックパッド

Hyprland では、すべての入力を細かく設定できる。キーボードのリピートを超高速にしたり、トラックパッドでナチュラルスクロールを使ったりできる。設定はすべて `~/.config/hypr/input.lua` で行う。Omarchy メニュー（`Super + Space`）の _設定 > 入力_ からも開ける。ここで設定した内容は、Omarchy のデフォルトを置き換える。

例を示す：

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

入力に関するすべてのオプションは、Hyprland wiki で[確認できる](https://wiki.hypr.land/Configuring/Basics/Variables/#input)。

CapsLock は通常の Caps Lock として動作し、`Shift + CapsLock` は[クイック絵文字](07-hotkeys.md#quick-emojis)や[その他の補完](07-hotkeys.md#quick-completions)のためのコンポーズキーになる。コンポーズキーを別の場所にしたい場合は、`kb_options` の `omarchy:shift_caps_compose` を置き換える。たとえば、次はコンポーズキーを Right Alt に移動する：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### トラックパッドのジェスチャー

トラックパッドをスワイプしてデスクトップを移動する：

| ジェスチャー | アクション |
| --- | --- |
| 3本指で左 / 右 | 空のワークスペースを含め、前 / 次のワークスペース |
| 3本指で上 | AI コンソールを切り替え |
| 3本指で下 | Omarchy メニューを開く |
| 4本指で左 / 右 | アクティブなウィンドウを前 / 次のワークスペースへ移動 |
| 4本指で下 | フルスクリーンを切り替え |

1つを変更するには、独自の[タッチパッドジェスチャー](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)を追加する前に、`~/.config/hypr/input.lua` でそれを解除する。Hyprland は、同じ本数と方向に2つのジェスチャーを割り当てられないためだ：

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchy のジェスチャーをすべてオフにするには、Omarchy のデフォルトが読み込まれる前に、`~/.config/hypr/hyprland.lua` の先頭付近で `omarchy_default_gestures = false` を設定する。

ハプティックタッチパッドを搭載した Dell XPS ノートパソコンでは、_トリガー > ハードウェア > タッチパッドハプティクス_ でクリックの強さを低、中、高に設定することもできる。

### 中国語、日本語、その他の言語での入力

インストーラーがキーボードについて尋ねてきたら、日本語、韓国語、中国語（簡体字、Pinyin）、台湾（Zhuyin）、香港（Cangjie）のいずれかを選択する。Omarchy はキーボードとそれに合った入力エンジンを自動で設定する。オフラインでの初回起動時のセットアップ中も同様だ。日本語では Mozc、韓国語では標準の2セット式 Hangul、簡体字中国語では Pinyin、台湾では Chewing の標準 Zhuyin 配列、香港では香港字形を用いる Cangjie を使う。Japanese (US keyboard) では、US キーボードレイアウトで Mozc が使える。Dvorak、Colemak、AZERTY でラテン文字を入力する場合でも、Hangul、Zhuyin、Cangjie のキーは標準位置のままになる。これより前に Hangul または Chewing を追加していた場合は、_設定 > 入力 > 入力方式_ でいったん選択を解除してから再選択すると、キーがそこへ移動する。すでに使って入力しているエンジンには、Omarchy は手を加えない。

入力はラテン文字モードで始まる。`Super + I` を押すと、設定した入力方式を順に切り替え、`Super + Shift + I` を押すと逆順に切り替える。`Shift` を単独でタップすると、Pinyin のような入力方式から抜けてラテン文字入力になり、もう一度タップすると元に戻る。Sogou、Microsoft Pinyin、macOS と同じ方式だ。`Shift` と文字キーを一緒に押せば、通常どおり大文字が入力される。日本語キーボードでは、全角/半角 で入力を切り替え、変換 でオンにし、無変換 でオフにする。韓国語では、한/영 で Hangul を切り替え、한자 で Hanja に変換する。専用キーがあるキーボードでも、多くのノートパソコンと同じようにそれらに Right Alt と Right Ctrl を送るキーボードでも同様だ。そのため、そこでは Right Alt と Right Ctrl は単なる修飾キーではない。音声入力のプッシュトゥトークは F9 のままである。`Ctrl + Space` は Tmux と Herdr のために引き続き使える。`Shift + CapsLock` は引き続きコンポーズキーである。

キーボードインジケーターは、複数のキーボードレイアウトまたは入力方式がある場合にバーの右側に表示される。クリックすると入力言語を切り替えられる。日本語では、ひらがなに あ と表示される。日本語の変換候補を選ぶには、日本語に切り替え、`nihongo` のような単語を入力して、Space を2回押す。Enter を押すと選択が確定する。複数のキーボードレイアウトもある場合は、インジケーターを右クリックするとそれらを順に切り替えられる。

_設定 > 入力 > キーボードレイアウト_ を使うと、インストール時に提示されるのと同じ選択肢から、English や French などのレイアウトを選択できる。_設定 > 入力 > 入力方式_ を使うと、有効な変換エンジンを選択できる。どちらのピッカーも Omarchy メニュー内に開き、現在の選択にチェックが付いている。クリックするか Enter を押すと選択を切り替えられ、各変更はすぐに適用される。入力方式の選択を解除すると、アンインストールすることなく切り替えサイクルから外れる。キーボードは引き続き利用できる。

同じピッカーを開くには、`omarchy setup keyboard` または `omarchy setup input` を実行する。コマンドラインから言語を1つ追加するには、`omarchy setup input mozc`、`hangul`、`pinyin`、`chewing`、`cangjie5` のいずれかを使う。Quick、Boshiamy、Array は Cangjie と同じパッケージに含まれており、入力方式ピッカーに表示される。カスタムの切り替えキーは保持される。別のエンジンレイアウトやキーを使うには、`omarchy pkg add fcitx5-configtool` で `fcitx5-configtool` をインストールし、ターミナルから起動する。入力言語を選択しても、デスクトップの言語は変わらない。まだ入力方式がない場合に _設定 > 言語_ で日本語、韓国語、中国語のいずれかを選ぶと、その入力方式が追加される。

`Super + I` を使うと入力方式またはキーボードレイアウトを順に切り替え、`Super + Shift + I` を使うと逆方向に戻る。そのため、3つ設定している場合でも、隣り合う2つの間を行き来できる。入力インジケーターは、入力方式またはレイアウトが複数設定されている場合にのみ、バーの右側に表示される。このデスクトップ用キーバインドは、既存の Fcitx 切り替えキーと併用できる。`~/.config/hypr/bindings.lua` で上書きすることも可能だ。入力エンジンとコンポーズシーケンスは、すべてのセッションですでに動作している [Fcitx5](https://fcitx-im.org/) サービスを使う。

### SUPER の代わりに ALT を使う

キーボードによっては、主要なメタキー（Windows/cmd キー）を SUPER として使うのが不便な場合がある。次の変更で、代わりに ALT を使うようにできる：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
