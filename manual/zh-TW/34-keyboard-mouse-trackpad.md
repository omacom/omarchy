# 鍵盤、滑鼠、觸控板

Hyprland 讓你可以非常詳細地設定所有輸入裝置。你可以把鍵盤重複輸入調得飛快，也可以讓觸控板使用自然捲動。所有設定都在 `~/.config/hypr/input.lua` 中更改，你也可以透過 Omarchy 選單（`Super + Space`）中的 _Setup > Input_ 前往該檔案。你在那邊設定的任何內容都會取代 Omarchy 的預設值。

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

CapsLock 的作用就是一般的 Caps Lock，而 `Shift + CapsLock` 則是 compose 鍵，用於[快速 emoji](07-hotkeys.md#quick-emojis)和[其他補齊功能](07-hotkeys.md#quick-completions)。如果你想把 compose 鍵放在其他位置，請取代 `kb_options` 中的 `omarchy:shift_caps_compose`。例如，這會把 compose 鍵移到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 觸控板手勢

在觸控板上滑動，即可在桌面上移動：

| 手勢 | 動作 |
| --- | --- |
| 三指向左 / 向右 | 上一個 / 下一個工作區，包含空白的工作區 |
| 三指向上 | 切換 AI 主控台 |
| 三指向下 | 開啟 Omarchy 選單 |
| 四指向左 / 向右 | 將作用中的視窗移到上一個 / 下一個工作區 |
| 四指向下 | 切換全螢幕 |

若要更改其中一個手勢，請先在 `~/.config/hypr/input.lua` 中將它取消設定，再加入你自己的[觸控板手勢](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，因為 Hyprland 不會接受相同手指數量和方向有兩個手勢：

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

若要關閉 Omarchy 的所有手勢，請在 `~/.config/hypr/hyprland.lua` 靠近頂部的地方，在 Omarchy 的預設值載入之前，將 `omarchy_default_gestures = false` 設定好。

在配備觸覺回饋觸控板的 Dell XPS 筆電上，你也可以在 _Trigger > Hardware > Touchpad Haptics_ 下，將點擊強度設定為 low、mid 或 high。

### 輸入中文、日文與其他語言

當安裝程式詢問你的鍵盤時，請選擇 Japanese、Korean、Chinese (Simplified, Pinyin)、Taiwan (Zhuyin) 或 Hong Kong (Cangjie)。Omarchy 會自動設定鍵盤和對應的輸入引擎，包括離線首次開機設定期間也一樣。Japanese 使用 Mozc，Korean 使用標準 two-set Hangul，Simplified Chinese 使用 Pinyin，Taiwan 使用 Chewing 的標準 Zhuyin 排列，Hong Kong 則使用 Cangjie 並採用 Hong Kong 字形。Japanese (US keyboard) 提供 Mozc 搭配 US 鍵盤配置。即使你用 Dvorak、Colemak 或 AZERTY 輸入 Latin 字母，Hangul、Zhuyin 和 Cangjie 按鍵仍會保持在標準位置。如果你在此之前已經加入 Hangul 或 Chewing，請在 _Setup > Typing > Input Methods_ 下取消選取後再重新選取它，讓它的按鍵移到那邊；對於你已經在使用的引擎，Omarchy 不會去動它。

輸入時一開始為 Latin 模式。按 `Super + I` 在已設定的輸入法之間循環切換，按 `Super + Shift + I` 則反向循環。單獨輕按 `Shift` 可以從 Pinyin 這類輸入法跳出到 Latin 字母，再按一次則返回，就像 Sogou、Microsoft Pinyin 和 macOS 的運作方式一樣；`Shift` 加上字母仍會輸入大寫字母。在 Japanese 鍵盤上，全角/半角 可切換輸入，変換 會開啟輸入，無変換 則會關閉輸入。使用 Korean 時，한/영 可切換 Hangul，한자 可轉換為 Hanja，不論你的鍵盤有專用按鍵，或像許多筆電一樣分別以 Right Alt 和 Right Ctrl 傳送這些按鍵都一樣，所以在那邊 Right Alt 和 Right Ctrl 並不是單純的修飾鍵；聽寫的按住說話功能仍在 F9 上。`Ctrl + Space` 仍保留給 Tmux 和 Herdr 使用；`Shift + CapsLock` 仍是 compose 鍵。

當你有多個鍵盤配置或輸入法時，鍵盤指示器會出現在列的右側。點選它即可切換輸入語言；Japanese 的平假名會顯示 あ。若要選取 Japanese 字元，請切換到 Japanese，輸入像是 `nihongo` 這樣的詞，然後按 Space 兩次。按 Enter 接受你的選擇。如果你同時有多個鍵盤配置，請以右鍵點選該指示器來循環切換這些配置。

使用 _Setup > Typing > Keyboard Layouts_ 選取 English 和 French 這類配置，選項與安裝時提供的相同。使用 _Setup > Typing > Input Methods_ 選取作用中的組字引擎。這兩個選取器都會在 Omarchy 選單內開啟，並勾選你目前的選取項目。點選或按 Enter 即可切換一個選項；每次變更都會立即套用。取消選取某個輸入法只會將它從循環中移除，不會解除安裝它；鍵盤仍然可用。

執行 `omarchy setup keyboard` 或 `omarchy setup input` 即可開啟相同的選取器。若要從命令列附加一種語言，請使用 `omarchy setup input mozc`、`hangul`、`pinyin`、`chewing` 或 `cangjie5`。Quick、Boshiamy 和 Array 與 Cangjie 在同一個套件中，會出現在 Input Methods 選取器中。你自訂的切換按鍵會被保留。若要使用替代的引擎配置或按鍵，請用 `omarchy pkg add fcitx5-configtool` 安裝 `fcitx5-configtool`，並從終端機啟動它。選取輸入語言不會改變桌面語言。在 _Setup > Language_ 下選擇 Japanese、Korean 或 Chinese 時，如果你還沒有任何輸入法，就會加入它的輸入法。

使用 `Super + I` 在輸入法或鍵盤配置之間循環切換，使用 `Super + Shift + I` 則反向切換，所以設定了三個時，你可以在兩個相鄰項目之間來回移動。只有在設定了不只一種輸入法或配置時，輸入指示器才會出現在列的右側。這個桌面綁定會與你現有的 Fcitx 切換按鍵並存；你可以在 `~/.config/hypr/bindings.lua` 中覆寫它。輸入引擎和 compose 序列使用的是每個 session 中都已在執行的 [Fcitx5](https://fcitx-im.org/) 服務。

### 使用 ALT 作為 SUPER

在某些鍵盤上，使用主要 meta 鍵（Windows/cmd 鍵）作為 SUPER 並不方便。你可以用以下變更，改用 ALT 來代替：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
