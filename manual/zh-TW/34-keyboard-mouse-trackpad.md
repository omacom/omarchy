# 鍵盤、滑鼠、觸控板

Hyprland 讓你非常細緻地設定所有的輸入。你可以將鍵盤重複改到超乎尋常的快，或讓觸控板使用自然捲動。你在 `~/.config/hypr/input.lua` 中更改這一切，也可以透過 Omarchy 選單（`Super + Space`）中的 _設定 > 輸入_ 抵達它。你在那裡設定的任何東西都會取代 Omarchy 的預設值。

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

你可以在 Hyprland wiki 的輸入頁面上[查看所有的輸入選項](https://wiki.hypr.land/Configuring/Basics/Variables/#input)。

CapsLock 作為一般的 Caps Lock 運作，而 `Shift + CapsLock` 是用於[快速表情符號](07-hotkeys.md#quick-emojis)和[其他完成](07-hotkeys.md#quick-completions)的組合鍵。如果你寧願把組合鍵放在其他地方，在 `kb_options` 中取代 `omarchy:shift_caps_compose`。例如，這將組合鍵移到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 觸控板手勢

你也可以開啟[觸控板手勢](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，例如用三根手指滑動來切換工作區：

```lua
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
```

在配備觸覺觸控板的 Dell XPS 筆記型電腦上，你還可以在 _觸發 > 硬體 > Touchpad Haptics_ 下將點擊強度設定為低、中或高。

### 以中文、日文和其他語言打字

當安裝程式詢問你的鍵盤時，選取 Japanese、Korean、Chinese (Simplified, Pinyin) 或 Chinese (Traditional, Zhuyin)。Omarchy 會自動設定鍵盤和相符的輸入引擎，包括在離線首次開機設定期間。日文使用 Mozc，韓文使用標準的二組式 Hangul，簡體中文使用 Pinyin，繁體中文使用 Chewing 的標準 Zhuyin 配置。Japanese (US keyboard) 提供搭配美式鍵盤配置的 Mozc。

打字從拉丁模式開始。按 `Super + I` 在已設定的輸入法之間循環，按 `Super + Shift + I` 往回循環。單獨輕按 `Shift` 可從 Pinyin 這類輸入法中跳出來進入拉丁字母，再按一次可回去，就像 Sogou、Microsoft Pinyin 和 macOS 的運作方式一樣；`Shift` 加一個字母仍然會打出大寫字母。在日文鍵盤上，全角/半角會切換輸入，変換會將它開啟，而無変換會將它關閉。在韓文鍵盤配置上，專用的 한/영 和 한자 鍵會切換 Hangul 並轉換為 Hanja。`Ctrl + Space` 仍可供 Tmux 和 Herdr 使用；`Shift + CapsLock` 仍是組合鍵。

當你有多個鍵盤配置或輸入法時，鍵盤指示器會出現在選單列右側。按一下它可切換輸入語言；日文會為平假名顯示 あ。要選擇日文字元，切換到日文，輸入一個像 `nihongo` 這樣的詞，然後按兩次 Space。按 Enter 接受你的選擇。如果你同時有多個鍵盤配置，右鍵按一下指示器在這些配置之間循環。

使用 _設定 > 打字 > Keyboard Layouts_ 來選取像 English 和 French 這樣的配置，這些與安裝期間提供的選擇相同。使用 _設定 > 打字 > Input Methods_ 來選取哪些組字引擎正在作用。兩個選擇器都會在 Omarchy 選單內開啟，並勾選你目前的選取。按一下或按 Enter 可切換一個選擇；每一次變更都會立即生效。取消選取一個輸入法會將其從循環中移除而不移除它；鍵盤仍然可用。

執行 `omarchy setup keyboard` 或 `omarchy setup input` 可開啟相同的選擇器。要從命令列附加一種語言，使用 `omarchy setup input mozc`、`hangul`、`pinyin` 或 `chewing`。你自訂的切換鍵將被保留。對於替代的引擎配置或按鍵，用 `omarchy pkg add fcitx5-configtool` 安裝 `fcitx5-configtool`，並從終端機啟動它。選取一種輸入語言不會改變桌面語言。

使用 `Super + I` 在輸入法或鍵盤配置之間循環，並用 `Super + Shift + I` 往另一個方向回去，所以在設定了三個的情況下，你可以在兩個相鄰的之間移動。只有在設定了多個輸入法或配置時，輸入指示器才會出現在選單列右側。這個桌面綁定與你現有的 Fcitx 切換鍵並行運作；你可以在 `~/.config/hypr/bindings.lua` 中覆寫它。輸入引擎和組合序列使用已在每個工作階段中執行的 [Fcitx5](https://fcitx-im.org/) 服務。

### 使用 ALT 作為 SUPER

在一些鍵盤上，使用主要 meta 鍵（Windows/cmd 鍵）作為 SUPER 並不方便。你可以使用以下變更改為使用 ALT：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
