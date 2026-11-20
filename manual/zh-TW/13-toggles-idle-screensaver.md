# 切換開關、閒置與螢幕保護程式

你每天常改的很多東西，其實不算是設定，而是一種開個一小時、之後再關掉的模式：熬夜工作時開夜間模式、簡報時開勿擾、看東西時保持喚醒。Omarchy 把這些叫做切換開關，而且它們的運作方式都一樣——快捷鍵、選單項目和指令，全部指向同一個開關。

### 切換開關選單

`Super + Ctrl + O` 會直接開啟 _Trigger > Toggle_，或者你可以從 Omarchy 選單（`Super + Space`）一路走過去。那份清單裡的每一項都是你可以隨手翻轉的開關，不用去想狀態到底存在哪裡。控制桌面外觀的開關就在它旁邊，位於 _Appearance_ 之下。

在終端機中，同樣的開關是 `omarchy toggle <thing>`。單獨執行 `omarchy toggle` 就能看到整組開關。

| 切換開關 | 快捷鍵 | 指令 |
| ------ | ------ | ------- |
| 夜間模式 | — | `omarchy toggle nightlight` |
| 靜音通知 | `Super + Ctrl + Alt + ,` | `omarchy toggle notification silencing` |
| 保持喚醒（不閒置鎖定） | `Super + Ctrl + I` | `omarchy toggle idle` |
| 崩潰擷取 | — | `omarchy toggle crash-capture` |
| 螢幕保護程式 | — | `omarchy toggle screensaver` |
| [Herdr](https://herdr.dev) 主題同步 | — | `omarchy toggle theme sync` |
| 選單列 | `Super + Shift + Space` | `omarchy toggle bar` |
| 觸控板 | `XF86TouchpadToggle` | `omarchy device touchpad` |
| 觸控螢幕 | — | `omarchy device touchscreen` |
| 暫停 | — | `omarchy toggle suspend` |
| 混合 GPU | — | `omarchy toggle hybrid gpu` |

觸控板、觸控螢幕和混合 GPU 的開關位於 _Trigger > Hardware_（`Super + Ctrl + H`）之下，而不是在 Toggle 之下，因為它們只有在你真的擁有該硬體時才會出現。觸控板和觸控螢幕的開關在 Hyprland 重新載入後依然有效——被停用裝置的名稱會儲存到一個小型狀態檔案，Hyprland 啟動時會讀取它，再次將該裝置停用。

_Appearance_ 裡有選單列和動畫，還有一些不是 `omarchy toggle` 指令、但行為相同的東西：列中的電池百分比、預設的工作區版面配置，以及 _Windows_ 之下的視窗間距（`Super + Shift + Backspace`）和單視窗方形比例（`Super + Ctrl + Backspace`）。

當 Hyprland 沒有 GPU 可供繪圖、改以 CPU 渲染（llvmpipe）時，例如在 GPU 尚未受支援的 Mac 上、在大多數虛擬機器中，或是圖形驅動程式載入失敗時，Omarchy 會在該工作階段關閉動畫、模糊和陰影，並以通知告知你一次。_Appearance > Animations On_ 可以把它們重新開啟，而且 Omarchy 也會為之後的工作階段記住這個選擇。

這些開關大多只是在 `~/.local/state/omarchy/toggles/` 之下的一個旗標檔案。如果你想在腳本中以其中之一作為分支條件，`omarchy-toggle-enabled` 會給你一個結束代碼，不用你自己去翻找：

```bash
omarchy-toggle-enabled screensaver-off && echo "screensaver is off"
```

這些旗標是以關閉狀態命名的——`screensaver-off`、`suspend-off`、`bar-off`——所以它們存在就表示該功能已停用。

### 列中的指示器

當某個模式開啟時，頂部列中間、時鐘旁邊會出現一個小圖示。那就是指示器小工具，它會顯示聽寫、螢幕錄影、待處理提醒、夜間模式、勿擾和保持喚醒。

未啟用的指示器會隱藏起來。將滑鼠游標移到列上的任何位置，它們就會以變暗的樣子淡入，讓你不用知道快捷鍵也能點一下將它開啟。點擊已啟用的指示器則會將它關閉。如果你寧願隨時都看到全部指示器，請在 `~/.config/omarchy/shell.json` 中 `omarchy.indicators` 項目的 `alwaysShow` 設為 `true`——關於列小工具的設定方式，請參見[頂部列](05-the-top-bar.md)。

### 夜間模式

夜間模式會將螢幕色溫調暖至 4000K，再切換一次則回到 6500K。你可以從切換開關選單（`Super + Ctrl + O`）翻轉它，或使用 `omarchy toggle nightlight`。它由 hyprsunset 驅動，若 hyprsunset 尚未執行，切換開關會為你啟動它。

預設情況下，hyprsunset 完全不會對你的螢幕做任何事。`~/.config/hypr/hyprsunset.conf` 附帶一個 identity 設定檔，正是為了讓顯示器在你要求變暖之前保持原樣不動。如果你寧願讓它依照時間切換，請將該設定檔換成時間設定檔：

```
profile {
    time = 20:00
    temperature = 4000
}
```

然後在登入時啟動 hyprsunset，方法是將 `o.launch_on_start("hyprsunset")` 加入 `~/.config/hypr/autostart.lua`。切換開關使用的 4000K/6500K 組合是固定的，所以如果你想要不同的色溫，就要去改設定檔。

### 勿擾

`Super + Ctrl + Alt + ,` 會讓通知靜音。開啟時不會跳出任何快顯通知，而且列中會出現劃掉的鈴鐺指示器，提醒你桌面為何安靜下來。

不過什麼都不會遺失。被靜音的通知會被保留下來：用 `Super + Shift + Alt + ,` 將最近幾則重新放回螢幕上。其餘內容請參見[通知](10-notices.md)。

有兩種訊息仍然能穿透：Omarchy 自己針對你剛完成的操作所顯示的確認快顯通知（"Theme changed"、"Screenshot saved"），以及從命令列送出的重大警示。把所有訊息都標記為重大、企圖強行跳到你面前的聊天應用程式，則不在此列。

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

這兩個數字都是從你進入閒置狀態的那一刻起算的秒數——不是彼此相加。所以使用預設值時，螢幕保護程式會在兩分半鐘後出現，而鎖定畫面會在五分鐘時接手，無論螢幕保護程式是否執行過。儲存檔案，shell 就會立即採用新的計時設定。

如果你在鎖定期限前關掉螢幕保護程式，那會算作一次活動，待定的鎖定就會被取消。你不會因為瞄一眼機器就被鎖在外面。

若要完全停止閒置鎖定，`Super + Ctrl + I`——或 `omarchy toggle idle`——會開啟保持喚醒，而且列中會出現咖啡杯指示器。在長時間簡報之前，或是開始一個你想盯著看的建置之前，就該按下它。再按一次即可回到正常狀態。`omarchy toggle idle status` 會以 JSON 格式印出目前狀態，方便你在腳本中使用。

這裡講的是鎖定和螢幕保護程式，不是電源。暫停和休眠有它們自己的設定，位於[系統睡眠](36-system-sleep.md)。

### 螢幕保護程式

Omarchy 的螢幕保護程式是 ASCII 藝術，透過隨機文字效果運行，每個顯示器各一個執行個體。按任何按鍵或移動滑鼠即可退出。

你可以從 _System > Screensaver_（`Super + Esc`）按需啟動它，就算你已關閉閒置螢幕保護程式，它也會強制開啟。預設沒有為它綁定快捷鍵。

如果你寧願直接從工作狀態進入鎖定狀態，`omarchy toggle screensaver` 就是用來關閉閒置螢幕保護程式的。按任何按鍵、點擊、捲動或移動滑鼠即可關閉它。

它所繪製的標誌可以由你自行變更，位於 _Appearance > Branding > Screensaver_ 之下。上傳一張 png 或 svg，Omarchy 就會將它轉換成 ASCII。請參見[品牌](41-branding.md)。

### 鎖定畫面

`Super + Ctrl + L` 會鎖定機器。這會執行 Omarchy shell 的鎖定畫面，關閉顯示器，將你的鍵盤版面配置重設為第一個，讓你不會用錯字母輸入密碼，而且——如果你正在執行它——會在離開時順便鎖定 1Password。

鎖定畫面接受密碼，等你設定好指紋後也會接受指紋。這一點，以及其他驗證方式，都在[硬體驗證](37-hardware-authentication.md)中說明。
