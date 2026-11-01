# 切換開關、閒置與螢幕保護程式

你每天會改的很多東西，其實並不算是設定。它們是你開啟一小時、之後又關掉的模式：工作到很晚時的夜間光線、正在簡報時的勿擾模式、正在看東西時保持喚醒。Omarchy 把這些稱為切換開關，而且它們全都以相同方式運作——一個快捷鍵、一個選單項目和一個命令，操作的都是同一個開關。

### 切換開關選單

`Super + Ctrl + O` 會直接開啟 _Trigger > Toggle_，或者你可以從 Omarchy 選單（`Super + Space`）一路走到那裡。那份清單裡的每一項都是你不用去想狀態到底存在哪裡、就可以直接切換的開關。至於影響桌面外觀的開關，則放在它旁邊的 _Appearance_ 底下。

在終端機裡，相同的開關是 `omarchy toggle <thing>`。單獨執行 `omarchy toggle` 就可以看到整個群組。

| 切換開關 | 快捷鍵 | 命令 |
| ------ | ------ | ------- |
| 夜間光線 | — | `omarchy toggle nightlight` |
| 靜音通知 | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| 保持喚醒（不因閒置鎖定） | `Super + Ctrl + I` | `omarchy toggle idle` |
| 當機擷取 | — | `omarchy toggle crash-capture` |
| 螢幕保護程式 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 主題同步 | — | `omarchy toggle theme sync` |
| 選單列 | `Super + Shift + Space` | `omarchy toggle bar` |
| 觸控板 | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| 觸控螢幕 | — | `omarchy toggle touchscreen` |
| 暫停 | — | `omarchy toggle suspend` |
| 混合 GPU | — | `omarchy toggle hybrid gpu` |

觸控板、觸控螢幕和混合 GPU 開關並不放在 Toggle 底下，而是放在 _Trigger > Hardware_（`Super + Ctrl + H`）底下，因為它們只會在你真的有那種硬體時才出現。觸控板和觸控螢幕這兩個開關在 Hyprland 重新載入後依然有效——被停用裝置的名稱會儲存到一個小型狀態檔案，Hyprland 啟動時會讀取它，再次把該裝置停用。

_Appearance_ 裡有選單列和動畫，另外還有幾項不是 `omarchy toggle` 命令、但運作方式相同的東西：在列中顯示電池百分比、預設的工作區配置，以及在 _Windows_ 底下的視窗間距（`Super + Shift + Backspace`）和單一視窗正方形比例（`Super + Ctrl + Backspace`）。

這些大多只是 `~/.local/state/omarchy/toggles/` 底下的一個旗標檔案。如果你想在指令碼裡根據其中一個來決定分支，`omarchy-toggle-enabled` 會直接給你結束代碼，你不用自己去翻找：

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

這些旗標是以關閉狀態來命名的——`screensaver-off`、`suspend-off`、`bar-off`——所以只要檔案存在，就代表該功能已停用。

### 頂部列中的指示圖示

當某個模式開啟時，你會在頂部列中央、時鐘旁邊看到一個小圖示。那就是指示圖示 widget，它負責顯示聽寫、螢幕錄影、待處理的提醒、夜間光線、勿擾模式和保持喚醒。

未啟用的指示圖示會被隱藏起來。把滑鼠移到頂部列的任何位置，它們就會以變暗的樣子淡入，這樣你就算不知道快捷鍵，也可以點擊其中一個來開啟它。點擊已啟用的指示圖示則會把它再關掉。如果你希望隨時都能看到全部指示圖示，請在 `~/.config/omarchy/shell.json` 裡的 `omarchy.indicators` 項目上，把 `alwaysShow` 設為 `true`——頂部列 widget 的設定方式請參見[頂部列](05-the-top-bar.md)。

### 夜間光線

夜間光線會把螢幕色溫調暖到 4000K，再切換一次就會恢復到 6500K。你可以從切換開關選單（`Super + Ctrl + O`）切換它，或使用 `omarchy toggle nightlight`。它由 hyprsunset 驅動，如果 hyprsunset 尚未執行，這個切換開關會替你把它啟動起來。

預設情況下，hyprsunset 完全不會對你的螢幕做任何事。`~/.config/hypr/hyprsunset.conf` 隨附了一個 identity 設定檔，正是為了讓顯示器在你要求暖色之前完全保持原狀。如果你比較希望它依照時間自動切換，可以把它換成時間設定檔：

```
profile {
    time = 20:00
    temperature = 4000
}
```

然後把 `o.launch_on_start("hyprsunset")` 加入 `~/.config/hypr/autostart.lua`，讓 hyprsunset 在登入時啟動。切換開關使用的 4000K/6500K 這一對數值是固定的，所以如果你想要不同的色溫，就要去改設定檔。

### 勿擾模式

`Super + Ctrl + Alt + ,` 會將通知靜音。開啟期間不會跳出任何快顯通知，而且列裡會出現一個畫了斜線的鈴鐺指示圖示，提醒你桌面為什麼安靜了下來。

不過什麼都不會遺失。被靜音的通知會被保留下來：用 `Super + Shift + Alt + ,` 可以把最近幾則重新顯示到畫面上。其餘內容請參見[通知](10-notices.md)。

有兩種訊息仍然能穿透：Omarchy 自己針對你剛才所做操作的確認快顯通知（「Theme changed」、「Screenshot saved」），以及從命令列送出的緊急警示。那些把每一則訊息都標成緊急、只為了硬擠到你面前來的聊天應用程式，並不符合資格。

### 閒置

閒置行為由 Omarchy shell 負責，而時間設定是 `~/.config/omarchy/shell.json` 裡一個頂層的 `idle` 區塊：

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

這兩個數字都是從你開始閒置的那一刻起算的秒數——彼此之間不是接續計算的。所以使用預設值時，螢幕保護程式會在兩分半後出現，而鎖定畫面會在五分鐘時接管，不論螢幕保護程式有沒有執行過。儲存檔案後，shell 就會立刻採用新的時間設定。

如果你在鎖定期限到達之前關掉螢幕保護程式，這會被視為有活動，待處理的鎖定就會取消。你不會因為瞄了一眼電腦就被鎖在外面。

要完全停止因閒置而鎖定，按 `Super + Ctrl + I`——或執行 `omarchy toggle idle`——就會開啟保持喚醒，列裡也會出現咖啡杯指示圖示。在長時間的簡報、或你想盯著它跑的建置開始之前，就該按這一個。再按一次就會恢復正常。如果你需要從指令碼裡取得目前狀態，`omarchy toggle idle status` 會以 JSON 印出目前狀態。

這裡講的是鎖定和螢幕保護程式，不是電源。暫停和休眠有它們自己的設定，請參見[系統睡眠](36-system-sleep.md)。

### 螢幕保護程式

Omarchy 的螢幕保護程式是 ASCII 藝術，透過隨機的文字特效播放，每個螢幕各跑一個執行個體。按任何鍵或移動滑鼠就會離開它。

你可以從 _System > Screensaver_（`Super + Esc`）視需要啟動它，就算你已經關掉了閒置時的螢幕保護程式，它也會強制顯示出來。預設並沒有給它綁定快捷鍵。

如果你比較希望從工作狀態直接進入鎖定，`omarchy toggle screensaver` 就是用來關掉閒置時螢幕保護程式的開關。按任何鍵、點擊、捲動或移動滑鼠都會把它關掉。

它畫出的標誌你可以自己換，位置在 _Appearance > Branding > Screensaver_ 底下。上傳一個 png 或 svg，Omarchy 就會把它轉換成 ASCII。請參見[品牌標誌](41-branding.md)。

### 鎖定畫面

`Super + Ctrl + L` 會鎖定電腦。這會啟動 Omarchy shell 的鎖定畫面、讓顯示器變暗、把你的鍵盤配置重設為第一個，這樣你就不會用錯字母系統輸入密碼，而且——如果你正在執行它的話——離開時也會順便鎖定 1Password。

鎖定畫面接受密碼，一旦你設定好指紋，它也會接受指紋。這個部分以及其他驗證方式，在[硬體驗證](37-hardware-authentication.md)中都有說明。
