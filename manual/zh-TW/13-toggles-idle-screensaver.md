# 切換開關、閒置與螢幕保護程式

你每天改來改去的很多東西，其實算不上是設定。它們是你打開一小時、之後又關掉的模式：熬夜工作時開夜光、做簡報時開勿擾、看東西時保持喚醒。Omarchy 把這些叫做切換開關，而且它們全都用同一套方式運作——快捷鍵、選單項目和指令，打的都是同一個開關。

### 切換開關選單

`Super + Ctrl + O` 會直接開啟 _Trigger > Toggle_，你也可以從 Omarchy 選單（`Super + Space`）一路點過去。那份清單裡全都是你不用去想狀態存在哪裡、隨手就能翻的開關。控制桌面外觀的開關就在它旁邊，位在 _Appearance_ 底下。

在終端機裡，同樣的開關是 `omarchy toggle <thing>`。單獨執行 `omarchy toggle` 就能看到整組開關。

| 切換開關 | 快捷鍵 | 指令 |
| ------ | ------ | ------- |
| 夜光 | — | `omarchy toggle nightlight` |
| 通知靜音 | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| 保持喚醒（不閒置鎖定） | `Super + Ctrl + I` | `omarchy toggle idle` |
| 當機擷取 | — | `omarchy toggle crash-capture` |
| 螢幕保護程式 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 主題同步 | — | `omarchy toggle theme sync` |
| 選單列 | `Super + Shift + Space` | `omarchy toggle bar` |
| 觸控板 | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| 觸控螢幕 | — | `omarchy toggle touchscreen` |
| 暫停 | — | `omarchy toggle suspend` |
| 混合 GPU | — | `omarchy toggle hybrid gpu` |

觸控板、觸控螢幕和混合 GPU 的開關位在 _Trigger > Hardware_（`Super + Ctrl + H`）底下，而不是 Toggle 底下，因為它們只會在你真的有那種硬體時才出現。觸控板和觸控螢幕的開關在 Hyprland 重新載入後依然有效——被停用裝置的名稱會存到一個小的狀態檔案裡，Hyprland 啟動時會讀取它，再次把裝置停用。

_Appearance_ 裡有選單列和動畫，還有幾項不是 `omarchy toggle` 指令、但行為一樣的東西：頂部列中的電池百分比、預設工作區版面配置，以及 _Windows_ 底下的視窗間距（`Super + Shift + Backspace`）和單視窗方形比例（`Super + Ctrl + Backspace`）。

這些開關大多只是一個位在 `~/.local/state/omarchy/toggles/` 底下的旗標檔案。如果你想在 script 裡依其中一個開關分支，`omarchy-toggle-enabled` 會給你一個結束代碼，不用你自己去找：

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

這些旗標是以關閉狀態命名的——`screensaver-off`、`suspend-off`、`bar-off`——所以它們存在，就代表該功能已停用。

### 頂部列中的指示器

某個模式開啟時，頂部列中間、時鐘旁邊會出現一個小圖形。那就是指示器 widget，它包含聽寫、螢幕錄影、待處理提醒、夜光、勿擾和保持喚醒。

未啟用的指示器會隱藏起來。把滑鼠停在頂部列任意位置，它們就會以變暗的樣子淡入，所以你就算不知道快捷鍵，也能點其中一個把它打開。點已啟用的指示器就會把它關回去。如果你寧願隨時都看到全部指示器，就把 `~/.config/omarchy/shell.json` 裡 `omarchy.indicators` 項目的 `alwaysShow` 設為 `true`——頂部列 widget 的設定方式見[頂部列](05-the-top-bar.md)。

### 夜光

夜光會把螢幕調暖到 4000K，再切換一次就會回到 6500K。從切換開關選單（`Super + Ctrl + O`）翻它，或用 `omarchy toggle nightlight`。它由 hyprsunset 驅動，如果 hyprsunset 還沒在執行，這個開關會替你把它啟動。

hyprsunset 預設完全不會動你的螢幕。`~/.config/hypr/hyprsunset.conf` 附帶一個 identity 設定檔，目的就是讓顯示器在你要求變暖之前完全保持原樣。如果你寧願讓它依時間切換，就把那份設定換成時間設定檔：

```
profile {
    time = 20:00
    temperature = 4000
}
```

接著把 `o.launch_on_start("hyprsunset")` 加到 `~/.config/hypr/autostart.lua`，讓 hyprsunset 在登入時啟動。這個開關用的 4000K/6500K 組合是固定的，所以你想要不同的色溫，就得去改設定檔。

### 勿擾模式

`Super + Ctrl + Alt + ,` 會讓通知靜音。開啟時不會跳出任何 toast，頂部列裡會坐著一個劃掉的鈴鐺指示器，提醒你桌面為什麼安靜了下來。

不過什麼都不會遺失。被靜音的通知會被擋下來：用 `Super + Shift + Alt + ,` 把最近幾則重新放到畫面上。其餘內容見[通知](10-notices.md)。

有兩種訊息還是能穿透：Omarchy 自己針對你剛做的事送出的確認 toast（「Theme changed」、「Screenshot saved」），以及從命令列送出的緊急警示。那些把一切都標成緊急、想硬擠到你面前的聊天應用程式，不算在內。

### 閒置

Omarchy shell 負責閒置行為，相關時間是 `~/.config/omarchy/shell.json` 裡頂層的 `idle` 區塊：

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

這兩個數字都是從你進入閒置的那一刻起算的秒數——不是彼此接續計算。所以用預設值時，螢幕保護程式會在兩分半後出現，鎖定畫面則在五分鐘時接手，不管螢幕保護程式有沒有跑過。儲存檔案，shell 就會立刻套用新的時間。

如果你在鎖定期限之前關掉螢幕保護程式，那會算作一次活動，待處理的鎖定就會取消。你不會只因為瞥了機器一眼就被鎖在外面。

要完全停止閒置鎖定，按 `Super + Ctrl + I`——或用 `omarchy toggle idle`——翻開保持喚醒，頂部列裡就會出現咖啡杯指示器。長時間做簡報，或有個你想盯著看的 build 之前，就是按它。再按一次就會回到正常狀態。如果你需要從 script 取得目前狀態，`omarchy toggle idle status` 會以 JSON 印出。

這裡講的是鎖定和螢幕保護程式，不是電源。暫停和休眠有它們自己在[系統睡眠](36-system-sleep.md)裡的設定。

### 螢幕保護程式

Omarchy 的螢幕保護程式是 ASCII 藝術，跑著隨機的文字效果，每台螢幕各一個執行個體。按任意鍵或移動滑鼠就會退出。

你可以從 _System > Screensaver_（`Super + Esc`）隨需啟動它，就算你已經把閒置螢幕保護程式關掉，它也會強制出現。預設沒有綁定它的快捷鍵。

`omarchy toggle screensaver` 才是關掉閒置螢幕保護程式的開關，如果你寧願從工作直接進入鎖定就用它。它需要一個它知道如何設定的終端機——Alacritty、Foot、Ghostty 或 Kitty——如果你的預設終端機是別的，它會告訴你。

它畫的標誌可以由你更換，位在 _Appearance > Branding > Screensaver_ 底下。上傳一張 png 或 svg，Omarchy 就會把它轉成 ASCII。見[品牌標誌](41-branding.md)。

### 鎖定畫面

`Super + Ctrl + L` 會鎖定機器。那會執行 Omarchy shell 的鎖定畫面、讓顯示器變黑、把鍵盤版面配置重設回第一個，讓你不會用錯字母輸入密碼，而且——如果你有在跑 1Password——會在離開時順便把它鎖上。

鎖定畫面接受密碼，等你設定好指紋之後，也會接受指紋。這個部分，以及其他驗證方式，都在[硬體驗證](37-hardware-authentication.md)裡說明。
