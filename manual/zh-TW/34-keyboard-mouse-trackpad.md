# 鍵盤、滑鼠、觸控板

Hyprland 讓你能非常細緻地設定所有輸入裝置。你可以把鍵盤重複速率調得飛快，或讓觸控板使用自然捲動。你可以在 `~/.config/hypr/input.lua` 中修改這一切，也可以透過 Omarchy 選單（`Super + Space`）中的 _Setup > Input_ 前往該處。你在那邊設定的任何內容，都會取代 Omarchy 的預設值。

以下是範例：

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

你可以在 Hyprland wiki 上[查看所有輸入選項](https://wiki.hypr.land/Configuring/Basics/Variables/#input)。

CapsLock 會如一般的 Caps Lock 般運作，而 `Shift + CapsLock` 是 compose 鍵，可用於[快速輸入 emoji](07-hotkeys.md#quick-emojis)和[其他補全](07-hotkeys.md#quick-completions)。如果你比較想把 compose 鍵放在別的位置，請將 `kb_options` 中的 `omarchy:shift_caps_compose` 換掉。舉例來說，這會將 compose 鍵移至 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 功能鍵

筆記型電腦鍵盤最上面一排預設送出的是媒體鍵（音量、亮度等等），按住 `Fn` 則可得到 F1-F12；`Fn + Esc` 會將其鎖定為相反模式，直到你再次按下為止。大多數鍵盤會自行記住該鎖定狀態。ASUS 筆記型電腦和 Apple 風格的鍵盤則交由 Linux 處理，每次開機時都會以媒體鍵開始。若你想讓它們改以 F1-F12 開始，請執行 `omarchy device keyboard toprow fnkeys`（若要改回來，則執行 `omarchy device keyboard toprow mediakeys`）；在某些筆記型電腦上，可能要重新開機後才會生效。Apple Silicon Mac 會保留它們自己的設定。

### 觸控板手勢

在觸控板上滑動，即可在桌面上移動：

| 手勢 | 動作 |
| --- | --- |
| 三指左滑 / 右滑 | 前一個 / 下一個工作區，包括空的工作區 |
| 三指上滑 | 切換 AI 主控台 |
| 三指下滑 | 開啟 Omarchy 選單 |
| 四指左滑 / 右滑 | 將目前使用的視窗移至前一個 / 下一個工作區 |
| 四指下滑 | 切換全螢幕 |

若要變更其中一項手勢，請先在 `~/.config/hypr/input.lua` 中將它 unset，再加入你自己的[觸控板手勢](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，因為 Hyprland 不會接受在相同手指數和方向上有兩個手勢：

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

若要關閉 Omarchy 的所有手勢，請在 `~/.config/hypr/hyprland.lua` 靠近頂部、Omarchy 預設值載入之前，設定 `omarchy_default_gestures = false`。

在配備觸覺回饋觸控板的 Dell XPS 筆記型電腦上，你也可以在 _Trigger > Hardware > Touchpad Haptics_ 之下，將按壓強度設為 low、mid 或 high。

### 以中文、日文和其他語言輸入

當安裝程式詢問你的鍵盤時，請選擇 Japanese、Korean、Chinese (Simplified, Pinyin)、Taiwan (Zhuyin) 或 Hong Kong (Cangjie)。Omarchy 會自動設定鍵盤和相符的輸入引擎，包括在離線的首次開機設定期間也是如此。日文使用 Mozc，韓文使用標準兩벌式 Hangul，簡體中文使用 Pinyin，台灣使用 Chewing 的標準 Zhuyin 配置，香港則使用 Cangjie 並搭配香港字形。Japanese (US keyboard) 提供搭配 US 鍵盤配置的 Mozc。即使你使用 Dvorak、Colemak 或 AZERTY 輸入拉丁字母，Hangul、Zhuyin 和 Cangjie 按鍵仍會維持在它們的標準位置。若你在此之前就已加入 Hangul 或 Chewing，請在 _Setup > Keyboard > Input Methods_ 之下取消選取再重新選取它，將其按鍵移至該處；對於你已經在使用輸入的引擎，Omarchy 不會去動它。

打字會以拉丁模式開始。按 `Super + I` 可循環切換已設定的輸入法，按 `Super + Shift + I` 則反向循環。單獨輕點 `Shift` 即可從 Pinyin 這類輸入法跳出至拉丁字母，再輕點一次即可回去，這和 Sogou、Microsoft Pinyin 以及 macOS 的運作方式相同；`Shift` 加字母仍會輸入大寫字母。在日文鍵盤上，全角/半角 會切換輸入，変換 會將其開啟，無変換 則將其關閉。使用韓文時，한/영 會切換 Hangul，한자 會轉換為 Hanja，不論你的鍵盤是否有專用按鍵，或如許多筆記型電腦那樣，透過 Right Alt 和 Right Ctrl 送出它們，因此在那類情況下，Right Alt 和 Right Ctrl 就不是單純的修飾鍵；聽寫的切換則改為使用 Alt + Space。`Ctrl + Space` 仍可供 Tmux 和 Herdr 使用；`Shift + CapsLock` 仍是 compose 鍵。

當你有多個鍵盤配置或輸入法時，鍵盤指示器會出現在列的右側。點一下它即可切換輸入語言；日文會以 あ 顯示平假名。關於日文字元選擇，請切換至日文，輸入例如 `nihongo` 的字詞，然後按 Space 兩次。按 Enter 接受你的選擇。若你同時有多個鍵盤配置，請以右鍵點一下指示器來循環切換它們。

使用 _Setup > Keyboard > Keyboard Inputs_ 來選擇如 English 和 French 的配置，可選擇的項目與安裝期間提供的相同。使用 _Setup > Keyboard > Input Methods_ 來選擇啟用哪些組字引擎。兩個選擇器都會在 Omarchy 選單內開啟，並勾選你目前的選擇。點一下或按 Enter 即可切換某個選項；每個變更都會立即生效。取消選取某個輸入法會將它從循環中移除，但不會將它解除安裝；鍵盤仍可使用。

執行 `omarchy setup keyboard` 或 `omarchy setup input` 即可開啟相同的選擇器。若要從指令列追加一種語言，請使用 `omarchy setup input mozc`、`hangul`、`pinyin`、`chewing` 或 `cangjie5`。Quick、Boshiamy 和 Array 與 Cangjie 包含在同一個套件中，並會出現在 Input Methods 選擇器中。你自訂的切換鍵會被保留。若需要其他的引擎配置或按鍵，請使用 `omarchy pkg add fcitx5-configtool` 安裝 `fcitx5-configtool`，並從終端機啟動它。選擇輸入語言不會變更桌面語言。在 _Setup > Region > Language_ 之下選擇 Japanese、Korean 或 Chinese 時，若你尚未有任何輸入法，將會加入其輸入法。

使用 `Super + I` 循環切換輸入法或鍵盤配置，使用 `Super + Shift + I` 則反向切換，因此當你設定了三個時，你可以在兩個相鄰項目之間移動。只有在設定了一個以上的輸入法或配置時，輸入指示器才會出現在列的右側。此桌面綁定可與你現有的 Fcitx 切換鍵一起運作；你可以在 `~/.config/hypr/bindings.lua` 中覆寫它。輸入引擎和 compose 序列會使用每個工作階段中都已在執行的 [Fcitx5](https://fcitx-im.org/) 服務。

### 以 ALT 代替 SUPER

在某些鍵盤上，將主要的 meta 鍵（Windows/cmd 鍵）用作 SUPER 並不方便。你可以使用這個變更，將其改為改用 ALT：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
