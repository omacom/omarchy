# 切換、閒置與螢幕保護程式

你日常會改變的很多東西，說到底並不是設定。它是一種你開啟一小時然後再關掉的模式：熬夜工作時的夜光、簡報時的勿擾、看東西時的保持喚醒。Omarchy 稱這些為切換，而它們全都以相同的方式運作——一個快捷鍵、一個選單項目和一個指令，全部打在同一個開關上。

### 切換選單

`Super + Ctrl + O` 會直接開啟 _觸發 > 切換_，或者你可以從 Omarchy 選單（`Super + Space`）走過去。那份清單中的每一個東西，都是一個你可以不假思索其狀態存在何處就能撥動的開關。控制桌面外觀的開關就在它旁邊，位於 _觸發 > 外觀_ 底下。

從終端機，同樣的開關是 `omarchy toggle <thing>`。單獨執行 `omarchy toggle` 可以看到整個群組。

| 切換 | 快捷鍵 | 指令 |
| ------ | ------ | ------- |
| 夜光 | `Super + Ctrl + N` | `omarchy toggle nightlight` |
| 靜音通知 | `Super + Ctrl + ,` | `omarchy toggle notification silencing` |
| 保持喚醒（無閒置鎖定） | `Super + Ctrl + I` | `omarchy toggle idle` |
| 當機擷取 | — | `omarchy toggle crash-capture` |
| 螢幕保護程式 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 主題同步 | — | `omarchy toggle theme sync` |
| 選單列 | `Super + Shift + Space` | `omarchy toggle bar` |
| 觸控板 | `XF86TouchpadToggle` | `omarchy toggle touchpad` |
| 觸控螢幕 | — | `omarchy toggle touchscreen` |
| 睡眠 | — | `omarchy toggle suspend` |
| 混合 GPU | — | `omarchy toggle hybrid gpu` |

觸控板、觸控螢幕和混合 GPU 開關位於 _觸發 > 硬體_（`Super + Ctrl + H`）底下，而不是切換底下，因為它們只在你實際擁有該硬體時才會出現。觸控板和觸控螢幕這兩個開關在 Hyprland 重新載入後仍然有效——被停用裝置的名稱會被儲存到一個小的狀態檔中，Hyprland 在啟動時讀取它，再次將它停用。

_觸發 > 外觀_保存著選單列和動畫，外加一些不是 `omarchy toggle` 指令、但行為相同的東西：選單列中的電池百分比、預設工作區配置、視窗間距（`Super + Shift + Backspace`），以及單視窗正方形比例（`Super + Ctrl + Backspace`）。

這些東西大多只是位於 `~/.local/state/omarchy/toggles/` 底下的一個旗標檔案。如果你想在腳本中以其中一個作為分支條件，`omarchy-toggle-enabled` 會給你一個結束代碼，省得你自己去找：

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

這些旗標以關閉狀態來命名——`screensaver-off`、`suspend-off`、`bar-off`——所以它們的存在表示該功能已停用。

### 選單列中的指示

當一個模式開啟時，你會在選單列中間、時鐘旁邊看到一個小字形。那就是列指示小工具，它涵蓋聽寫、螢幕錄影、待處理的提醒、夜光、勿擾和保持喚醒。

未啟用的指示會被隱藏起來。將指標懸停在它們周圍的區域，它們就會以變淡的形式淡入，所以你可以點選其中一個來開啟它，而不需要知道它的快捷鍵。點選一個已啟用的指示則會把它關回去。如果你比較希望隨時看到全部，請在 `~/.config/omarchy/shell.json` 中的 `omarchy.indicators` 項目上把 `alwaysShow` 設為 `true`——有關選單列小工具如何設定，見[選單列](05-the-top-bar.md)。

### 夜光

`Super + Ctrl + N` 會把螢幕調暖到 4000K，再按一次則調回 6500K。它由 hyprsunset 驅動，如果它尚未在運行，切換會替你啟動它。

預設情況下，hyprsunset 完全不會對你的螢幕做任何事。`~/.config/hypr/hyprsunset.conf` 附帶一個恆等設定檔，目的正是讓顯示器在你要求暖色之前保持原樣。如果你比較喜歡它依時鐘切換，請用一個時間設定檔取而代之：

```
profile {
    time = 20:00
    temperature = 4000
}
```

然後把 `o.launch_on_start("hyprsunset")` 加進 `~/.config/hypr/autostart.lua`，讓 hyprsunset 在登入時啟動。切換所使用的 4000K/6500K 配對是固定的，所以如果你想要不同的色溫，設定檔就是你要去的地方。

### 勿擾

`Super + Ctrl + ,` 會讓通知靜音。當它開啟時，不會有快訊彈出，而選單列中那個被畫上刪線的鈴鐺指示會待在那裡，提醒你桌面為何變安靜了。

不過，沒有任何東西會遺失。一則被靜音的通知會直接被寫進你的通知紀錄中，那正是你回來好奇自己錯過了什麼時所需要的紀錄。用 `Super + Shift + Alt + ,` 開啟它。通知故事的其餘部分見[通知快訊](10-notices.md)。

有兩種訊息仍然能通過：Omarchy 自己針對你剛做的事所發出的確認快訊（「主題已變更」、「螢幕截圖已儲存」），以及從命令列發出的嚴重警示。那些把一切都標記為嚴重、硬要擠到你面前的聊天應用程式並不符合資格。

### 閒置

Omarchy shell 掌管閒置行為，而計時是 `~/.config/omarchy/shell.json` 中的一個頂層 `idle` 區塊：

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

這兩個數字都是從你進入閒置那一刻起算的秒數——不是彼此相對。所以用預設值，螢幕保護程式在兩分半後出現，鎖定畫面在五分鐘時接管，無論螢幕保護程式是否運行過。儲存檔案，shell 就會立即採用新的計時。

如果你在鎖定截止時間之前關閉了螢幕保護程式，那會被算作活動，而待處理的鎖定就會被取消。你不會因為瞥了一眼自己的機器就被鎖在外面。

若要完全停止閒置時鎖定，`Super + Ctrl + I`——或 `omarchy toggle idle`——會開啟保持喚醒，而咖啡杯指示會出現在選單列中。那是在冗長簡報、或你想觀看的建置開始之前該按的那個鍵。再按一次則回到正常。如果你需要從腳本得知目前狀態，`omarchy toggle idle status` 會以 JSON 形式列印目前狀態。

這裡講的是鎖定和螢幕保護程式，不是電源。睡眠和休眠在[系統睡眠](36-system-sleep.md)中有它們自己的設定。

### 螢幕保護程式

Omarchy 的螢幕保護程式是 ASCII 藝術，運行著隨機文字特效，每台顯示器一個實例。任何按鍵或滑鼠移動都會結束它。

你可以從 _系統 > 螢幕保護程式_（`Super + Esc`）按需求啟動它，這會強制把它拉起來，即使你已經關閉了閒置螢幕保護程式。預設沒有綁定到它的快捷鍵。

`omarchy toggle screensaver` 是用來關閉閒置那個的，如果你比較喜歡直接從工作狀態進到鎖定。它需要一個它知道如何設定的終端機——Alacritty、Foot、Ghostty 或 Kitty——如果你的預設終端機是別的東西，它會告訴你。

它所繪製的標誌任由你更改，位於 _風格 > 螢幕保護程式_ 底下。上傳一個 png 或 svg，Omarchy 會把它轉換成 ASCII。見[品牌](41-branding.md)。

### 鎖定畫面

`Super + Ctrl + L` 會鎖定機器。那會運行來自 Omarchy shell 的鎖定畫面、把顯示器變黑、把你的鍵盤配置重設為第一個，以免你用錯誤的字母系統輸入密碼，並且——如果你正在運行它——在出去的路上把 1Password 也鎖上。

鎖定畫面接受密碼，一旦你設定了指紋，它也會接受指紋。那一點，以及其他的驗證方式，都在[硬體驗證](37-hardware-authentication.md)中有介紹。
