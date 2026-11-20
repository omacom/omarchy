# 鍵盤、滑鼠、觸控板

Hyprland 讓你能詳細設定所有輸入裝置。你可以把鍵盤重複速率調得飛快，或讓觸控板使用自然捲動。你可以在 `~/.config/hypr/input.lua` 中修改所有設定，也能透過 Omarchy 選單 (`Super + Space`) 中的 _Setup > Input_ 開啟這個檔案。你在那邊設定的任何內容，都會取代 Omarchy 的預設值。

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

CapsLock 的作用就是一般的 Caps Lock，而 `Shift + CapsLock` 則是組合鍵，用於[快速 emoji](07-hotkeys.md#quick-emojis)和[其他補全功能](07-hotkeys.md#quick-completions)。如果你想把組合鍵放在別的位置，請將 `kb_options` 中的 `omarchy:shift_caps_compose` 換掉。例如，以下設定會把組合鍵移到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 功能鍵

筆電鍵盤最上面一排預設送出的是媒體鍵（音量、亮度等等），按住 `Fn` 則會變成 F1-F12；`Fn + Esc` 會將它鎖定在相反的模式，直到你再次按下為止。大多數鍵盤會自己記住這個鎖定狀態。ASUS 筆電和 Apple 風格的鍵盤則交給 Linux 處理，每次開機時都會從媒體鍵模式啟動。若要改為從 F1-F12 啟動，請執行 `omarchy device keyboard toprow fnkeys`（若要改回來，則執行 `omarchy device keyboard toprow mediakeys`）；在某些筆電上，變更會在重新開機後生效。Apple Silicon Mac 則保留自己的設定。

### 觸控板手勢

在觸控板上滑動，即可在桌面間移動：

| 手勢 | 動作 |
| --- | --- |
| 三指向左 / 向右滑 | 上一個 / 下一個工作區，包括空的工作區 |
| 三指向上滑 | 切換 AI 主控台 |
| 三指向下滑 | 開啟 Omarchy 選單 |
| 四指向左 / 向右滑 | 將目前視窗移到上一個 / 下一個工作區 |
| 四指向下滑 | 切換全螢幕 |

若要變更其中一個手勢，請先在 `~/.config/hypr/input.lua` 中將它取消設定，再加入你自己的[觸控板手勢](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，因為 Hyprland 不接受相同手指數與相同方向的兩個手勢：

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

若要關閉 Omarchy 的所有手勢，請在 `~/.config/hypr/hyprland.lua` 靠近頂部的位置、在 Omarchy 預設值載入之前，設定 `omarchy_default_gestures = false`。

在配備觸覺觸控板的 Dell XPS 筆電上，你也可以在 _Trigger > Hardware > Touchpad Haptics_ 底下，將點擊強度設定為 low、mid 或 high。

### 輸入中文、日文及其他語言

當安裝程式詢問你的鍵盤時，請選擇 Japanese、Korean、Chinese (Simplified, Pinyin)、Taiwan (Zhuyin) 或 Hong Kong (Cangjie)。Omarchy 會自動設定鍵盤與相符的輸入引擎，包括離線首次開機設定期間也是如此。Japanese 使用 Mozc，Korean 使用標準的二式 Hangul，Simplified Chinese 使用 Pinyin，Taiwan 使用 Chewing 的標準注音排列，Hong Kong 則使用採用香港字形的 Cangjie。Japanese (US keyboard) 提供搭配 US 鍵盤配置的 Mozc。即使你使用 Dvorak、Colemak 或 AZERTY 輸入拉丁字母，Hangul、Zhuyin 與 Cangjie 的按鍵仍會維持在標準位置。如果你之前加入了 Hangul 或 Chewing，請在 _Setup > Keyboard > Input Methods_ 底下先取消選取再重新選取它，將其按鍵移到那些位置；Omarchy 不會動你已經在使用的引擎。

輸入時會從拉丁模式開始。按下 `Super + I` 可循環切換已設定的輸入法，按下 `Super + Shift + I` 則反向循環。單獨輕點 `Shift` 可跳出 Pinyin 這類輸入法進入拉丁字母模式，再點一次即可回去，就像 Sogou、Microsoft Pinyin 和 macOS 的運作方式一樣；`Shift` 加上字母仍會輸入大寫字母。在 Japanese 鍵盤上，全角/半角 可切換輸入，変換 可開啟，無変換 則可關閉。使用 Korean 時，한/영 可切換 Hangul，한자 可轉換為 Hanja，不論你的鍵盤有專用按鍵，還是像許多筆電那樣以 Right Alt 和 Right Ctrl 送出這些按鍵，因此在那種情況下 Right Alt 和 Right Ctrl 不是普通的修飾鍵；聽寫則改用 Alt + Space 切換。`Ctrl + Space` 仍保留給 Tmux 和 Herdr 使用；`Shift + CapsLock` 仍是組合鍵。

當你有多個鍵盤配置或輸入法時，鍵盤指示器會出現在狀態列右側。點選它即可切換輸入語言；Japanese 會以 あ 表示 hiragana。若要選擇 Japanese 字符，請切換到 Japanese，輸入像是 `nihongo` 這樣的詞，然後按兩次 Space。按下 Enter 接受你的選擇。如果你同時有多個鍵盤配置，請以右鍵點選該指示器來循環切換那些配置。

使用 _Setup > Keyboard > Keyboard Inputs_ 可選取 English 和 French 這類配置，選項與安裝期間提供的相同。使用 _Setup > Keyboard > Input Methods_ 可選取啟用哪些輸入引擎。兩個選取器都會在 Omarchy 選單內開啟，並勾選你目前的選項。點選或按下 Enter 即可切換一個選項；每次變更都會立即套用。取消選取某個輸入法只會將它從循環中移除，不會將它解除安裝；鍵盤仍可使用。

執行 `omarchy setup keyboard` 或 `omarchy setup input` 即可開啟相同的選取器。若要從指令列附加一種語言，請使用 `omarchy setup input mozc`、`hangul`、`pinyin`、`chewing` 或 `cangjie5`。Quick、Boshiamy 和 Array 與 Cangjie 來自同一個套件，並會出現在 Input Methods 選取器中。你自訂的切換按鍵會被保留。若需要其他引擎配置或按鍵，請以 `omarchy pkg add fcitx5-configtool` 安裝 `fcitx5-configtool`，並從終端機啟動它。選取輸入語言不會改變桌面語言。在 _Setup > Language_ 底下選擇 Japanese、Korean 或 Chinese 時，如果你還沒有任何輸入法，系統會加入它的輸入法。

使用 `Super + I` 可循環切換輸入法或鍵盤配置，使用 `Super + Shift + I` 則反向切換，因此當你設定了三個時，你可以在兩個相鄰選項之間移動。只有在設定了多個輸入法或配置時，輸入指示器才會出現在狀態列右側。此桌面綁定可與你現有的 Fcitx 切換按鍵並存；你可以在 `~/.config/hypr/bindings.lua` 中覆寫它。輸入引擎和組合序列使用每個工作階段中已在運行的 [Fcitx5](https://fcitx-im.org/) 服務。

### 使用 ALT 作為 SUPER

在某些鍵盤上，將主要的 meta 鍵（Windows/cmd 鍵）用作 SUPER 並不方便。你可以透過以下變更，改用 ALT 來代替：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
