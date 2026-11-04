# 切換開關、閒置與螢幕保護程式

你每天會改的很多東西，其實並不是真正的設定。它是一種你開啟一小時、之後再關掉的模式：熬夜工作時的夜燈、簡報時的勿擾、在看東西時保持喚醒。Omarchy 把這些叫做切換開關，而且它們全都以相同方式運作 — 一個快速鍵、一個選單項目和一個指令，全部打在同一個開關上。

### 切換選單

`Super + Ctrl + O` 會直接開啟 _觸發 > 切換_，或者你可以從 Omarchy 選單（`Super + Space`）一路走過去。那份清單裡的每一項，都是一個你不用去想狀態存在哪裡、就能直接翻動的開關。控制桌面外觀的開關就在它旁邊，位於 _外觀_ 底下。

從終端機來看，相同的開關就是 `omarchy toggle <thing>`。單獨執行 `omarchy toggle` 就能看到整組開關。

| 切換項目 | 快速鍵 | 指令 |
| ------ | ------ | ------- |
| 夜燈 | — | `omarchy toggle nightlight` |
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

觸控板、觸控螢幕和混合 GPU 的開關位於 _觸發 > 硬體_（`Super + Ctrl + H`）底下，而不是在切換底下，因為它們只有在你真的擁有該硬體時才會出現。觸控板和觸控螢幕的開關在 Hyprland 重新載入後依然有效 — 被停用的裝置名稱會存到一個小型狀態檔案，Hyprland 啟動時會讀取它，再次將該裝置停用。

_外觀_ 裡有選單列和動畫，還有一些不是 `omarchy toggle` 指令、但行為相同的東西：頂部列中的電池百分比、預設工作區版面配置，以及 _視窗_ 底下的視窗間距（`Super + Shift + Backspace`）和單視窗方形長寬比（`Super + Ctrl + Backspace`）。

當 Hyprland 沒有 GPU 可用來繪圖、而是改用 CPU 渲染（llvmpipe）時，例如在 GPU 尚未受支援的 Mac 上、在大多數虛擬機器中，或是圖形驅動程式載入失敗時，Omarchy 會在該工作階段關閉動畫、模糊和陰影，並用一則通知告訴你一次。_外觀 > 動畫開啟_ 可以把它們帶回來，而且 Omarchy 也會為之後的工作階段記住這個選擇。

其中大多數只不過是 `~/.local/state/omarchy/toggles/` 底下的一個旗標檔案。如果你想在腳本中根據其中一個來分支，`omarchy-toggle-enabled` 會給你一個結束碼，不用你自己去翻找：

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

這些旗標是以關閉狀態命名的 — `screensaver-off`、`suspend-off`、`bar-off` — 所以它們的存在就表示該功能已停用。

### 頂部列中的指示器

當某個模式開啟時，你會在頂部列中間、時鐘旁邊看到一個小圖示。那就是指示器小工具，它承載了聽寫、螢幕錄影、待處理提醒、夜燈、勿擾和保持喚醒。

未啟用的指示器會隱藏起來。把滑鼠懸停在頂部列的任何地方，它們就會以變暗的樣子淡入，所以你就算不知道它的快速鍵，也可以點其中一個來開啟它。點一個已啟用的指示器，就會把它關回去。如果你寧願一直看到全部指示器，就把 `~/.config/omarchy/shell.json` 中 `omarchy.indicators` 項目的 `alwaysShow` 設為 `true` — 關於頂部列小工具如何設定，請見 [頂部列](05-the-top-bar.md)。

### 夜燈

夜燈會把螢幕暖化到 4000K，再切換一次就會把它放回 6500K。從切換選單（`Super + Ctrl + O`）翻動它，或使用 `omarchy toggle nightlight`。它由 hyprsunset 驅動，如果它還沒在執行，切換開關會幫你啟動它。

預設情況下，hyprsunset 完全不會對你的螢幕做任何事。`~/.config/hypr/hyprsunset.conf` 附帶了一個 identity profile，正是為了讓顯示器在你要求暖化之前保持原封不動。如果你寧願讓它按時間切換，就把那個換成一個時間 profile：

```
profile {
    time = 20:00
    temperature = 4000
}
```

接著，透過把 `o.launch_on_start("hyprsunset")` 加入 `~/.config/hypr/autostart.lua`，讓 hyprsunset 在登入時啟動。切換開關使用的 4000K/6500K 這一對是固定的，所以如果你想要不同的色溫，該去的地方就是設定檔。

### 勿擾

`Super + Ctrl + Alt + ,` 會讓通知靜音。開啟期間不會彈出任何通知，而頂部列裡會停著一個劃掉的鈴鐺指示器，提醒你桌面為什麼安靜下來。

什麼都不會遺失。被靜音的通知會被保留下來：用 `Super + Shift + Alt + ,` 把最近幾則放回螢幕。其餘內容請見 [通知](10-notices.md)。

有兩種訊息仍然能穿透：Omarchy 自己針對你剛剛做的事情所發的確認彈出通知（「主題已變更」、「螢幕截圖已儲存」），以及從命令列送出的緊急警示。那些把每一則都標為緊急、想硬擠到你面前的聊天應用程式並不符合資格。

### 閒置

Omarchy shell 負責閒置行為，而計時設定是 `~/.config/omarchy/shell.json` 中一個頂層的 `idle` 區塊：

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  }
}
```

兩個數字都是從你進入閒置的那一刻起算的秒數 — 不是彼此相接著算。所以在預設值下，螢幕保護程式會在兩分半鐘後出現，而鎖定畫面會在五分鐘時接管，不管螢幕保護程式有沒有執行過。儲存檔案，shell 就會立刻採用新的計時。

如果你在鎖定期限之前關掉螢幕保護程式，那會算作一次活動，待處理的鎖定就會被取消。你不會因為瞥一眼機器就被鎖在外面。

要完全停止閒置鎖定，`Super + Ctrl + I` — 或是 `omarchy toggle idle` — 會開啟保持喚醒，而咖啡杯指示器會出現在頂部列。那就是在長時間簡報或你想盯著看的建置之前該按的那個。再按一次就會回到正常。`omarchy toggle idle status` 會以 JSON 印出目前狀態，如果你需要在腳本中使用它的話。

這講的是鎖定和螢幕保護程式，不是電源。暫停和休眠有它們自己的設定，在 [系統睡眠](36-system-sleep.md) 中。

### 螢幕保護程式

Omarchy 的螢幕保護程式是 ASCII 藝術，透過隨機文字效果運行，每個螢幕各一個執行個體。任何按鍵或滑鼠移動都會讓它退出。

你可以從 _系統 > 螢幕保護程式_（`Super + Esc`）按需啟動它，就算你已經關掉閒置螢幕保護程式，它也會強制出現。預設沒有為它綁定快速鍵。

`omarchy toggle screensaver` 是用來關掉閒置那一個的，如果你寧願直接從工作跳到鎖定的話。任何按鍵、點擊、捲動或滑鼠移動都會關閉它。

它所畫的標誌由你來改，位於 _外觀 > 品牌 > 螢幕保護程式_ 底下。上傳一張 png 或 svg，Omarchy 就會把它轉成 ASCII。請見 [品牌](41-branding.md)。

### 鎖定畫面

`Super + Ctrl + L` 會鎖定機器。那會執行來自 Omarchy shell 的鎖定畫面、讓顯示器變黑、把你的鍵盤配置重設為第一個，讓你不至於用錯字母系統輸入密碼，而且 — 如果你有在執行它的話 — 在離開時也鎖定 1Password。

鎖定畫面接受密碼，一旦你設定好指紋，它也會接受指紋。那一點，以及其他驗證方式，都在 [硬體驗證](37-hardware-authentication.md) 中說明。
