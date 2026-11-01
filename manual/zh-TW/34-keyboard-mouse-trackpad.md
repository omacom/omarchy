# 鍵盤、滑鼠、觸控板

Hyprland 讓你能非常細緻地設定所有輸入裝置。你可以把鍵盤重複速度調到快如超音速，或讓觸控板使用自然捲動。你可以在 `~/.config/hypr/input.lua` 中修改這一切，也可以透過 Omarchy 選單 (`Super + Space`) 中的 _設定 > 輸入_ 前往該檔案。你在那裡設定的任何內容，都會取代 Omarchy 的預設值。

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

你可以參閱 Hyprland wiki 上關於輸入的說明，[查看所有輸入選項](https://wiki.hypr.land/Configuring/Basics/Variables/#input)。

CapsLock 的作用就是一般的 Caps Lock，而 `Shift + CapsLock` 則是組字鍵，可用於[快速 emoji](07-hotkeys.md#quick-emojis) 和[其他補全功能](07-hotkeys.md#quick-completions)。如果你希望把組字鍵放在其他位置，請取代 `kb_options` 中的 `omarchy:shift_caps_compose`。例如，以下設定會把組字鍵移到 Right Alt：

```lua
hl.config({
  input = {
    kb_options = "compose:ralt",
  },
})
```

### 觸控板手勢

在觸控板上滑動，即可在桌面間移動：

| 手勢 | 動作 |
| --- | --- |
| 三指往左 / 往右 | 上一個 / 下一個工作區，包括空的工作區 |
| 三指往上 | 切換 AI 主控台 |
| 三指往下 | 開啟 Omarchy 選單 |
| 四指往左 / 往右 | 將目前視窗移到上一個 / 下一個工作區 |
| 四指往下 | 切換全螢幕 |

若要變更其中一個手勢，請先在 `~/.config/hypr/input.lua` 中取消設定該手勢，再加入你自己的[觸控板手勢](https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/)，因為 Hyprland 不接受相同手指數與相同方向的兩個手勢：

```lua
hl.gesture({ fingers = 3, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
```

若要關閉 Omarchy 的所有手勢，請在 `~/.config/hypr/hyprland.lua` 靠近頂部、Omarchy 預設值載入之前，設定 `omarchy_default_gestures = false`。

在配備觸覺回饋觸控板的 Dell XPS 筆電上，你也可以在 _觸發 > 硬體 > 觸控板觸覺回饋_ 下，將點按強度設定為低、中或高。

### 輸入中文、日文及其他語言

當安裝程式詢問你的鍵盤時，請選擇日文、韓文、中文（簡體，拼音）、台灣（注音）或香港（倉頡）。Omarchy 會自動設定鍵盤與相符的輸入引擎，包括離線首次開機設定期間也是如此。日文使用 Mozc，韓文使用標準兩式 Hangul，簡體中文使用拼音，台灣使用 Chewing 的標準注音排列，香港則使用採用香港字形的倉頡。日文（US 鍵盤）提供搭配 US 鍵盤配置的 Mozc。即使你使用 Dvorak、Colemak 或 AZERTY 輸入拉丁字母，Hangul、注音與倉頡的按鍵仍會維持在其標準位置。如果你在此之前就已加入 Hangul 或 Chewing，請在 _設定 > 打字 > 輸入法_ 下將其取消選取後再重新選取，即可把其按鍵移到該位置；Omarchy 不會動你已經在用來打字的引擎。

輸入一開始處於拉丁字母模式。按 `Super + I` 可依序切換已設定的輸入法，按 `Super + Shift + I` 則可反向切換。單獨輕按 `Shift` 可從 Pinyin 這類輸入法暫時跳出到拉丁字母，再輕按一次即可返回，就像 Sogou、Microsoft Pinyin 與 macOS 的運作方式一樣；`Shift` 加上字母仍然會輸入大寫字母。在日文鍵盤上，全角/半角 可切換輸入，変換 可開啟輸入，無変換 則可關閉輸入。使用韓文時，한/영 可切換 Hangul，한자 可轉換為 Hanja；無論你的鍵盤具有專用按鍵，或像許多筆電一樣為這些功能送出 Right Alt 與 Right Ctrl，這都適用，因此在那裡 Right Alt 與 Right Ctrl 並非單純的修飾鍵；聽寫則改以 Alt + Space 切換。`Ctrl + Space` 仍可供 Tmux 與 Herdr 使用；`Shift + CapsLock` 仍為組字鍵。

當你有多種鍵盤配置或輸入法時，鍵盤指示器會出現在列的右側。點擊它即可切換輸入語言；日文會以 あ 表示平假名。如需選擇日文字元，請切換到日文，輸入如 `nihongo` 的字詞，然後按 Space 兩次。按 Enter 即可接受你的選擇。如果你同時有多種鍵盤配置，請以滑鼠右鍵點擊該指示器，即可依序切換這些配置。

使用 _設定 > 打字 > 鍵盤配置_ 來選擇如英文與法文等配置，其選項與安裝期間提供的相同。使用 _設定 > 打字 > 輸入法_ 來選擇要啟用哪些組字引擎。這兩個選擇器都會在 Omarchy 選單內開啟，並勾選你目前的選擇。點擊或按 Enter 即可切換一項選擇；每個變更都會立即套用。取消選取某個輸入法會將其從切換循環中移除，但不會將其解除安裝；鍵盤仍然可用。

執行 `omarchy setup keyboard` 或 `omarchy setup input` 即可開啟相同的選擇器。若要從命令列追加一種語言，請使用 `omarchy setup input mozc`、`hangul`、`pinyin`、`chewing` 或 `cangjie5`。Quick、Boshiamy 與 Array 與 Cangjie 位於同一個套件中，並會出現在輸入法選擇器裡。你自訂的切換鍵會被保留。如需替代的引擎配置或按鍵，請使用 `omarchy pkg add fcitx5-configtool` 安裝 `fcitx5-configtool`，並從終端機啟動它。選擇輸入語言不會變更桌面語言。在 _設定 > 語言_ 下選擇日文、韓文或中文時，如果你尚未擁有其輸入法，便會加入該輸入法。

使用 `Super + I` 依序切換輸入法或鍵盤配置，使用 `Super + Shift + I` 則反向切換，因此當你設定了三種輸入方式時，你可以在相鄰的兩者之間移動。只有在設定了多於一種輸入法或配置時，輸入指示器才會出現在列的右側。這個桌面鍵盤綁定會與你現有的 Fcitx 切換鍵並行運作；你可以在 `~/.config/hypr/bindings.lua` 中覆寫它。輸入引擎與組字序列使用每個工作階段中都已在執行的 [Fcitx5](https://fcitx-im.org/) 服務。

### 使用 ALT 作為 SUPER

在某些鍵盤上，使用主要的 meta 鍵（Windows/cmd 鍵）作為 SUPER 並不方便。你可以使用以下變更，改用 ALT 來代替：

```lua
hl.config({
  input = {
    kb_options = "omarchy:shift_caps_compose,altwin:swap_alt_win",
  },
})
```
