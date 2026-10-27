# 鍵盤、滑鼠、觸控板

Hyprland 讓你能非常細緻地設定所有輸入裝置。你可以把鍵盤重複速度調到快如音速，也可以讓觸控板使用自然捲動。所有設定都在 `~/.config/hypr/input.lua` 裡修改，你也可以透過 Omarchy 選單（`Super + Space`）中的 _Setup > Input_ 前往該檔案。你在那裡設定的任何內容，都會取代 Omarchy 的預設值。

以下是一個範例：

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

你可以在 Hyprland wiki 的輸入章節[查看所有輸入選項](https://wiki.hypr.land/Configuring/Basics/Variables/#input)。

CapsLock 的作用就是一般的 Caps Lock，而 `Shift + CapsLock` 則是[快速 emoji](07-hotkeys.md#quick-emojis) 與[其他補全](07-hotkeys.md#quick-completions) 的組合鍵。如果你想把組合鍵改到別的位置，請取代 `kb_options` 中的 `omarchy:shift_caps_compose`。例如，以下設定會把組合鍵移到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 觸控板手勢

你也可以開啟[觸控板手勢](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，例如用三指滑動來切換工作區：

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

在配備觸覺觸控板的 Dell XPS 筆電上，你也可以在 _Trigger > Hardware > Touchpad Haptics_ 下將點擊強度設定為低、中或高。

### 輸入中文、日文及其他語言

當安裝程式詢問你的鍵盤時，請選擇 Japanese、Korean、Chinese (Simplified, Pinyin)、Taiwan (Zhuyin) 或 Hong Kong (Cangjie)。Omarchy 會自動設定鍵盤與相符的輸入引擎，包括離線的首次開機設定期間。日文使用 Mozc，韓文使用標準兩式 Hangul，簡體中文使用 Pinyin，台灣使用 Chewing 的標準注音排列，香港則使用 Cangjie 並採用香港字形。Japanese (US keyboard) 提供 Mozc 搭配美式鍵盤配置。即使你使用 Dvorak、Colemak 或 AZERTY 輸入拉丁字母，Hangul、注音與 Cangjie 的按鍵仍會維持在標準位置。如果你在此之前已加入 Hangul 或 Chewing，請在 _Setup > Typing > Input Methods_ 下取消選取後再重新選取，讓它的按鍵移至該處；Omarchy 不會動你已經在用來打字的引擎。

輸入一開始會處於拉丁模式。按 `Super + I` 可循環切換已設定的輸入法，按 `Super + Shift + I` 則往回循環。單獨輕按 `Shift` 可從 Pinyin 這類輸入法中暫時跳出至拉丁字母，再按一次則回到原輸入法，就像 Sogou、Microsoft Pinyin 與 macOS 的作法一樣；`Shift` 加字母仍然會輸入大寫字母。在日文鍵盤上，全角/半角 切換輸入，変換 開啟輸入，無変換 則關閉輸入。使用韓文時，한/영 切換 Hangul，한자 轉換為 Hanja，不論你的鍵盤有專用按鍵，還是像許多筆電一樣為它們送出 Right Alt 與 Right Ctrl，因此在那裡 Right Alt 與 Right Ctrl 不是普通的修飾鍵；聽寫的按住說話功能仍保留在 F9。`Ctrl + Space` 仍可供 Tmux 與 Herdr 使用；`Shift + CapsLock` 仍是組合鍵。

當你有多個鍵盤配置或輸入法時，鍵盤指示器會出現在列的右側。點擊它即可切換輸入語言；日文會以 あ 表示平假名。若要選取日文字元，請切換至日文，輸入一個詞，例如 `nihongo`，然後按 Space 兩次。按 Enter 接受你的選擇。如果你同時有多個鍵盤配置，右鍵點擊該指示器即可循環切換這些配置。

使用 _Setup > Typing > Keyboard Layouts_ 來選取配置，例如 English 與 French，這些選項與安裝時提供的相同。使用 _Setup > Typing > Input Methods_ 來選取啟用哪些輸入引擎。兩個選取器都會在 Omarchy 選單內開啟，並勾選你目前的選擇。點擊或按 Enter 即可切換選項；每一項變更都會立即生效。取消選取某個輸入法會將它從循環中移除，但不會解除安裝它；鍵盤仍可使用。

執行 `omarchy setup keyboard` 或 `omarchy setup input` 可開啟相同的選取器。若要從命令列追加一種語言，請使用 `omarchy setup input mozc`、`hangul`、`pinyin`、`chewing` 或 `cangjie5`。Quick、Boshiamy 與 Array 與 Cangjie 屬於同一個套件，並會出現在 Input Methods 選取器中。你自訂的切換按鍵會被保留。若要使用其他引擎配置或按鍵，請以 `omarchy pkg add fcitx5-configtool` 安裝 `fcitx5-configtool`，並從終端機啟動它。選取輸入語言不會更改桌面語言。在 _Setup > Language_ 下選擇 Japanese、Korean 或 Chinese 時，如果你還沒有任何輸入法，系統會加入其輸入法。

使用 `Super + I` 循環切換輸入法或鍵盤配置，使用 `Super + Shift + I` 往反方向切換，因此當你設定了三個選項時，可以在相鄰的兩個之間來回移動。只有在設定了多個輸入法或配置時，輸入指示器才會出現在列的右側。這個桌面綁定可與你現有的 Fcitx 切換按鍵並行運作；你可以在 `~/.config/hypr/bindings.lua` 中覆寫它。輸入引擎與組合序列使用每个工作階段中已在執行的 [Fcitx5](https://fcitx-im.org/) 服務。

### 使用 ALT 作為 SUPER

在某些鍵盤上，使用主要 meta 鍵（Windows/cmd 鍵）作為 SUPER 並不方便。你可以使用以下變更，將它改為 ALT：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
