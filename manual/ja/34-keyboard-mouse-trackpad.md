# キーボード、マウス、トラックパッド

Hyprlandでは、すべての入力を細かく設定できます。キーボードのリピートを超高速にしたり、トラックパッドでナチュラルスクロールを使ったりできます。すべては `~/.config/hypr/input.lua` で変更します。これはOmarchyメニュー（`Super + Space`）の _Setup > Input_ からも開けます。そこで設定した内容は、Omarchyのデフォルトを置き換えます。

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

入力については、Hyprland wikiで[すべての入力オプションを確認](https://wiki.hypr.land/Configuring/Basics/Variables/#input)できます。

CapsLockは通常のCaps Lockとして動作し、`Shift + CapsLock` は[クイック絵文字](07-hotkeys.md#quick-emojis)や[その他の補完](07-hotkeys.md#quick-completions)のためのコンポーズキーです。コンポーズキーを別の場所に置きたい場合は、`kb_options` の `omarchy:shift_caps_compose` を置き換えてください。たとえば、次の設定でコンポーズキーをRight Altに移動します:

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### ファンクションキー

ノートパソコンのキーボードの最上段は、デフォルトではメディアキー（音量、明るさなど）を送信し、`Fn` を押しながらだとF1-F12になります。`Fn + Esc` を押すと逆にロックされ、もう一度押すまでその状態が続きます。ほとんどのキーボードはそのロックを自分で覚えます。ASUSのノートパソコンやApple風キーボードはそれをLinuxに任せるため、起動するたびにメディアキーから始まります。代わりにF1-F12から始めるには、`omarchy device keyboard toprow fnkeys` を実行してください（戻すには `omarchy device keyboard toprow mediakeys`）。一部のノートパソコンでは、再起動後に有効になります。Apple Silicon Macは独自の設定を保持します。

### トラックパッドジェスチャー

トラックパッドでスワイプしてデスクトップ内を移動します:

| ジェスチャー | アクション |
| --- | --- |
| 3本指で左 / 右 | 前 / 次のワークスペース（空のものも含む） |
| 3本指で上 | AIコンソールの切り替え |
| 3本指で下 | Omarchyメニューを開く |
| 4本指で左 / 右 | アクティブなウィンドウを前 / 次のワークスペースへ移動 |
| 4本指で下 | フルスクリーンの切り替え |

いずれかを変更するには、独自の[touchpad gesture](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)を追加する前に、`~/.config/hypr/input.lua` でそれを解除してください。Hyprlandは同じ本数の指と方向に2つのジェスチャーを受け付けないためです:

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

Omarchyのジェスチャーをすべてオフにするには、Omarchyのデフォルトが読み込まれる前に、`~/.config/hypr/hyprland.lua` の上の方で `omarchy_default_gestures = false` を設定してください。

触覚タッチパッドを搭載したDell XPSノートパソコンでは、_Trigger > Hardware > Touchpad Haptics_ でクリックの強さをlow、mid、highに設定することもできます。

### 中国語、日本語、その他の言語での入力

インストーラーがキーボードについて尋ねたら、Japanese、Korean、Chinese (Simplified, Pinyin)、Taiwan (Zhuyin)、Hong Kong (Cangjie)のいずれかを選択してください。Omarchyはキーボードとそれに対応する入力エンジンを自動で設定します。オフラインの初回起動セットアップ中も同様です。日本語はMozcを使い、韓国語は標準の2ボル式Hangul、簡体字中国語はPinyin、台湾はChewingの標準Zhuyin配列、香港は香港の字形を用いるCangjieを使います。Japanese (US keyboard)は、USキーボードレイアウトでMozcを提供します。Hangul、Zhuyin、Cangjieのキーは、Dvorak、Colemak、AZERTYでラテン文字を入力する場合でも標準の位置に留まります。これより前にHangulやChewingを追加していた場合は、_Setup > Keyboard > Input Methods_ で一度選択を解除してから再選択すると、そのキーがそこに移動します。すでに使って入力しているエンジンは、Omarchyが手を付けません。

入力はラテンモードから始まります。`Super + I` を押すと設定済みの入力メソッドを順に切り替え、`Super + Shift + I` を押すと逆方向に切り替えます。`Shift` を単独でタップすると、Pinyinのような入力メソッドから抜けてラテン文字になり、もう一度タップすると戻ります。Sogou、Microsoft Pinyin、macOSと同じやり方です。`Shift` と文字の組み合わせでは、引き続き大文字が入力されます。日本語キーボードでは、全角/半角で入力を切り替え、変換でオンにし、無変換でオフにします。韓国語では、한/영でHangulを切り替え、한자でHanjaに変換します。キーボードに専用キーがある場合も、多くのノートパソコンのようにそれらの代わりにRight AltとRight Ctrlを送信する場合も同様です。そのため、そこではRight AltとRight Ctrlは単なる修飾キーではありません。代わりに、音声入力はAlt + Spaceで切り替えます。`Ctrl + Space` はTmuxやHerdrのために引き続き利用でき、`Shift + CapsLock` は引き続きコンポーズキーです。

複数のキーボードレイアウトや入力メソッドがある場合、バーの右側にキーボードインジケーターが表示されます。クリックすると入力言語を切り替えます。日本語ではひらがなにあを表示します。日本語の文字候補を使うには、日本語に切り替えて、`nihongo` のような単語を入力し、Spaceを2回押してください。Enterを押すと選択が確定します。複数のキーボードレイアウトもある場合は、インジケーターを右クリックするとそれらを順に切り替えます。

_Setup > Keyboard > Keyboard Inputs_ を使うと、インストール時に提示されるのと同じ選択肢から、EnglishやFrenchなどのレイアウトを選択できます。_Setup > Keyboard > Input Methods_ を使うと、どの変換エンジンが有効かを選択できます。どちらのピッカーもOmarchyメニューの中に開き、現在の選択にチェックが付いています。クリックするかEnterを押すと選択が切り替わり、各変更は即座に適用されます。入力メソッドの選択を解除すると、アンインストールすることなく切り替えの循環から外れます。キーボードは引き続き利用できます。

`omarchy setup keyboard` または `omarchy setup input` を実行すると、同じピッカーを開けます。コマンドラインから言語を1つ追加するには、`omarchy setup input mozc`、`hangul`、`pinyin`、`chewing`、`cangjie5` のいずれかを使ってください。Quick、Boshiamy、ArrayはCangjieと同じパッケージに含まれており、Input Methodsピッカーに表示されます。カスタムの切り替えキーは保持されます。別のエンジンレイアウトやキーを使うには、`omarchy pkg add fcitx5-configtool` で `fcitx5-configtool` をインストールし、ターミナルから起動してください。入力言語を選択しても、デスクトップ言語は変わりません。まだ入力メソッドがない場合に _Setup > Region > Language_ でJapanese、Korean、Chineseのいずれかを選択すると、その入力メソッドが追加されます。

`Super + I` を使うと入力メソッドやキーボードレイアウトを順に切り替え、`Super + Shift + I` を使うと逆方向に戻ります。そのため、3つ設定していれば、隣り合う2つの間を行き来できます。入力インジケーターは、入力メソッドやレイアウトが複数設定されている場合にのみ、バーの右側に表示されます。このデスクトップバインディングは、既存のFcitx切り替えキーと併せて動作します。`~/.config/hypr/bindings.lua` で上書きできます。入力エンジンとコンポーズシーケンスは、すべてのセッションですでに動作している[Fcitx5](https://fcitx-im.org/)サービスを使います。

### ALTをSUPERとして使用する

一部のキーボードでは、主要なメタキー（Windows/cmdキー）をSUPERとして使うのが不便です。次の変更で、代わりにALTを使うように変えられます:

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
