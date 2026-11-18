# 鍵盤、滑鼠、觸控板

Hyprland 讓你能以非常細緻的程度設定所有輸入裝置。你可以把鍵盤重複速度調到快如音速，也可以讓觸控板使用自然捲動。你可以在 `~/.config/hypr/input.lua` 中變更這一切，也能透過 Omarchy 選單（`Super + Space`）的 _Setup > Input_ 進入。你在那裡設定的任何項目都會取代 Omarchy 的預設值。

這裡有一個範例：

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

你可以於 Hyprland wiki 上[查看所有輸入選項](https://wiki.hypr.land/Configuring/Basics/Variables/#input)以了解輸入設定。

CapsLock 的作用就是一般的 Caps Lock，而 `Shift + CapsLock` 是組合鍵，用於[快速 emoji](07-hotkeys.md#quick-emojis)和[其他補全](07-hotkeys.md#quick-completions)。如果你寧願把組合鍵放在別處，請在 `kb_options` 中取代 `omarchy:shift_caps_compose`。例如，以下設定會把組合鍵移到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 功能鍵

筆電鍵盤的最上排預設傳送的是媒體鍵（音量、亮度等等），按住 `Fn` 則會得到 F1-F12；`Fn + Esc` 會將它鎖定為相反模式，直到你再次按下為止。大多數鍵盤會自行記住該鎖定狀態。ASUS 筆電和 Apple 風格的鍵盤則交由 Linux 處理，每次開機時都會以媒體鍵模式啟動。若要讓它們改以 F1-F12 模式啟動，請執行 `omarchy keyboard toprow fnkeys`（執行 `omarchy keyboard toprow mediakeys` 則可切換回去）；在某些筆電上，變更會在重新開機後才生效。Apple Silicon Mac 會保留自己的設定。

### 觸控板手勢

在觸控板上滑動，即可在桌面間移動：

| 手勢 | 動作 |
| --- | --- |
| 三指左滑 / 右滑 | 前一個 / 下一個工作區，包括空白工作區 |
| 三指上滑 | 切換 AI 主控台 |
| 三指下滑 | 開啟 Omarchy 選單 |
| 四指左滑 / 右滑 | 將作用中的視窗移至前一個 / 下一個工作區 |
| 四指下滑 | 切換全螢幕 |

若要變更其中一項，請先在 `~/.config/hypr/input.lua` 中將它取消設定，然後再加入你自己的[觸控手勢](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，因為 Hyprland 不會接受以相同手指數量和相同方向設定的兩個手勢：

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

若要關閉 Omarchy 的所有手勢，請在 `~/.config/hypr/hyprland.lua` 頂部附近，在 Omarchy 的預設值載入之前，設定 `omarchy_default_gestures = false`。

在配備觸覺觸控板的 Dell XPS 筆電上，你也可以在 _Trigger > Hardware > Touchpad Haptics_ 下，將點擊強度設定為 low、mid 或 high。

### 以中文、日文及其他語言輸入

當安裝程式詢問你的鍵盤時，請選擇 Japanese、Korean、Chinese (Simplified, Pinyin)、Taiwan (Zhuyin) 或 Hong Kong (Cangjie)。Omarchy 會自動設定鍵盤和相符的輸入引擎，包括離線首次開機設定期間。Japanese 使用 Mozc，Korean 使用標準雙式 Hangul，Simplified Chinese 使用 Pinyin，Taiwan 使用 Chewing 的標準 Zhuyin 配置，Hong Kong 則使用 Cangjie 搭配香港字形。Japanese (US keyboard) 提供 Mozc 搭配美式鍵盤配置。即使你使用 Dvorak、Colemak 或 AZERTY 輸入拉丁字母，Hangul、Zhuyin 和 Cangjie 按鍵仍會保持在標準位置上。如果你先前已加入 Hangul 或 Chewing，請在 _Setup > Keyboard > Input Methods_ 下將它取消選取後再重新選取，使其按鍵移至該處；對於你已經在使用輸入的引擎，Omarchy 會保留現狀不予更動。

輸入一開始會以拉丁模式進行。按 `Super + I` 可循環切換已設定的輸入法，按 `Super + Shift + I` 則可反向循環。單獨輕觸 `Shift` 可從 Pinyin 這類輸入法跳出至拉丁字母，再輕觸一次即可返回，就像 Sogou、Microsoft Pinyin 和 macOS 的運作方式一樣；`Shift` 加上字母仍會輸入大寫字母。在日文鍵盤上，全角/半角可切換輸入，変換可開啟輸入，無変換可關閉輸入。在 Korean 方面，한/영可切換 Hangul，한자可轉換為 Hanja，無論你的鍵盤有專用按鍵，或像許多筆電那樣以 Right Alt 和 Right Ctrl 傳送這些按鍵都一樣，因此在該情況下 Right Alt 和 Right Ctrl 並非單純的修飾鍵；聽寫則改以 Alt + Space 切換。`Ctrl + Space` 仍可供 Tmux 和 Herdr 使用；`Shift + CapsLock` 仍是組合鍵。

當你有多種鍵盤配置或輸入法時，鍵盤指示器會出現在欄的右側。點擊它以切換輸入語言；Japanese 會將平假名顯示為 あ。若要挑選日文字元，請切換到 Japanese，輸入像是 `nihongo` 這樣的單字，然後按兩次 Space。按 Enter 接受你的選擇。如果你也有多種鍵盤配置，請以右鍵點擊指示器以循環切換。

使用 _Setup > Keyboard > Keyboard Inputs_ 選取例如 English 和 French 這類配置，選項與安裝時提供的相同。使用 _Setup > Keyboard > Input Methods_ 選取要啟用哪些組字引擎。兩個選取器都會在 Omarchy 選單內開啟，並已勾選你目前的選取項目。點擊或按 Enter 可切換某個選項；每個變更都會立即生效。取消選取某個輸入法會將它從循環中移除，但不會將它解除安裝；鍵盤仍可使用。

執行 `omarchy setup keyboard` 或 `omarchy setup input` 即可開啟相同的選取器。若要從命令列附加一種語言，請使用 `omarchy setup input mozc`、`hangul`、`pinyin`、`chewing` 或 `cangjie5`。Quick、Boshiamy 和 Array 與 Cangjie 包含在同一個套件中，會出現在 Input Methods 選取器裡。你自訂的切換按鍵會獲得保留。若要使用替代的引擎配置或按鍵，請以 `omarchy pkg add fcitx5-configtool` 安裝 `fcitx5-configtool`，並從終端機啟動它。選取輸入語言不會變更桌面語言。在 _Setup > Language_ 下選擇 Japanese、Korean 或 Chinese 時，若你尚無任何輸入法，則會新增其輸入法。

使用 `Super + I` 可在輸入法或鍵盤配置間循環切換，使用 `Super + Shift + I` 則可反向循環，如此一來，當你設定了三種項目時，就能在兩個相鄰項目之間移動。只有在已設定多於一個輸入法或配置時，輸入指示器才會出現在欄的右側。此桌面按鍵綁定會與你現有的 Fcitx 切換按鍵並行運作；你可以在 `~/.config/hypr/bindings.lua` 中覆寫它。輸入引擎和組合序列使用每個工作階段都已在執行的 [Fcitx5](https://fcitx-im.org/) 服務。

### 使用 ALT 作為 SUPER

在某些鍵盤上，使用主 meta 鍵（Windows/cmd 鍵）作為 SUPER 並不方便。你可以使用以下變更，將它改為 ALT：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
